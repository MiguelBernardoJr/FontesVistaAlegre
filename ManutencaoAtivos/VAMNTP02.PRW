#Include "Protheus.ch"
#include "Tbiconn.ch"
#include "TopConn.ch"
#include "Totvs.ch"

// ###############################################################################################
// Projeto: 
// Fonte  : VAMNTP02.prw
// ---------+------------------------------------+------------------------------------------------
// Data     | Autor                              | Descricao
// ---------+------------------------------------+------------------------------------------------
//  15/03/22|  Manoel Filho                      | Apuração de Preços de Compra de Combustiveis  
// ---------+------------------------------------+------------------------------------------------
User Function VAMNTP02()
	Local aArea 	:= FwGetArea()
	Local aParamBox := {}
	Local aRet      := {}
	Local dDatCorte := GetMv("VA_RECCMB",,cTod("01/01/2021")) // Data de Minima para Recálculo de Abastecimentos
	Local cAlias	:= GetNextAlias()
	Local cQry 		:= ""

	Private dDatIni := cTod("")
	Private dDatFin := cTod("")
	Private cFilde  := ""
	Private cFilAte := ""
	Private cFilBak := cFilant

	aAdd(aParamBox,{1,"Data Inicial",Ctod(""),"@D","","","",50,.f.})
	aAdd(aParamBox,{1,"Data Final"  ,Ctod(""),"@D","","","",50,.f.})
	aAdd(aParamBox,{1,"Filial De"	,"'0101001'","","","","",50,.f.})
	aAdd(aParamBox,{1,"Filial Ate"  ,"'ZZZZZZZ'","","","","",50,.f.})

	While .t.
		If ParamBox(aParamBox,"",@aRet,,,,,,,,.F.)
			dDatIni := aRet[1]
			dDatFin := aRet[2]
			cFilde  := aRet[3]
			cFilAte := aRet[4]
		Else
			Return
		EndIf

		If Empty(dDatIni) .or. Empty(dDatFin) .or. (dDatFin<dDatIni) .or. ;
			Empty(cFilde) .or. Empty(cFilAte) .or. (cFilAte<cFilde)
				MsgStop("Parâmetro(s) inválido(s)! Favor informar corretamente!")
			Loop
		Endif

		If (dDatIni<dDatCorte)
			MsgStop("Data Inicial MENOR que a Data de Corte informada no parâmetro VA_RECCMB! Favor informar corretamente!")
			Loop
		Endif

		Exit
	Enddo

	cQry := "select TQN_FILIAL " + CRLF
	cQry += " from "+RetSqlName("TQN")+" TQN " + CRLF
	cQry += " WHERE TQN.D_E_L_E_T_ =''  " + CRLF
	cQry += " AND TQN_FILIAL BETWEEN '"+aRet[3]+"' AND '"+aRet[4]+"'  " + CRLF
	cQry += " GROUP BY TQN_FILIAL " + CRLF

	MpSysOpenQuery(cQry, cAlias)

	While !(cAlias)->(EOF())

		cFilant := (cAlias)->TQN_FILIAL
		
		oProcTTP := MsNewProcess():New({ |lEnd| FS_Proc01() }," ","",.f.)
		oProcTTP:Activate()

		(cAlias)->(DbSkip())
	Enddo

	(cAlias)->(dbCloseArea())

	cFilant := cFilBak

	FwRestArea(aArea)
Return

Static Function FS_Proc01()
Local lProcess  := .f.
Local nAcres    := GetMv("VA_ACCMBI",,0.20) // Valor do Acescimo no preço do litro Combustivel do Prestadores de Serviço
Local lRecLock  := .T.

DbSelectArea("ZAU")

// Abastecimentos
If Select("TMPTQN") > 0
	TMPTQN->(dbCloseArea())
EndIf

cQuery := "SELECT DISTINCT TQN.TQN_CODCOM, TQI.TQI_PRODUT "
cQuery += " FROM "+RetSqlName("TQN")+" TQN "
cQuery += " JOIN "+RetSqlName("ST9")+" ST9 ON ST9.T9_FILIAL = '"+xFilial("ST9")+"' AND TQN.TQN_FROTA = ST9.T9_CODBEM "
cQuery += "  AND ST9.D_E_L_E_T_ = ' ' AND ST9.T9_PROPRIE = '2' AND ST9.T9_XTPTER = '1' "
cQuery += " JOIN "+RetSqlName("TQI")+" TQI ON TQI.TQI_FILIAL = '"+xFilial("TQI")+"' AND TQN.TQN_CODCOM = TQI.TQI_CODCOM "
cQuery += "  AND TQI.D_E_L_E_T_ = ' ' "
cQuery += " WHERE TQN.TQN_FILIAL = '"+xFilial("TQN")+"' AND TQN.D_E_L_E_T_ = ' ' AND TQN.TQN_DTABAS BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"' "
DbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), "TMPTQN", .f., .f.)

oProcTTP:IncRegua1("Apuração de Preços de Compra de Combustiveis  ..")
oProcTTP:SetRegua2(1000)

Begin Transaction

While !TMPTQN->(Eof())

	oProcTTP:IncRegua2()

	//cQuery := "   SELECT SD1.R_E_C_N_O_ RECSD1, D1_DTDIGIT, D1_COD, D1_VUNIT " + CRLF
	cQuery := "   SELECT SD1.R_E_C_N_O_ RECSD1 "
	cQuery += "     FROM "+RetSqlName("SD1")+" SD1 " + CRLF
	cQuery += "    JOIN  "+RetSqlName("SF4")+" SF4 ON ( F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' '  ) " + CRLF
	cQuery += "    WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D1_COD = '"+TMPTQN->TQI_PRODUT+"'" + CRLF
	cQuery += "      AND SD1.D_E_L_E_T_ = ' ' AND SD1.D1_DTDIGIT BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"' " + CRLF
	cQuery += " ORDER BY 1 DESC "

	DbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), "TMPSD1", .f., .f.)

//	nRecSD1 := FM_Sql(cQuery)

//	If nRecSD1 > 0

	While !TMPSD1->(Eof())
		SD1->(DbGoto(TMPSD1->(RECSD1)))
		lProcess := .t.
		DbSelectArea("ZAU")
			RecLock("ZAU", lRecLock := !DbSeek(xFilial("ZAU")+TMPTQN->TQN_CODCOM+Dtos(SD1->D1_DTDIGIT)))
				ZAU->ZAU_FILIAL := xFilial("ZAU")
				ZAU->ZAU_CODCOM := TMPTQN->TQN_CODCOM
				ZAU->ZAU_PRODUT := TMPTQN->TQI_PRODUT
				ZAU->ZAU_DATCPA := SD1->D1_DTDIGIT
				ZAU->ZAU_DOC    := SD1->D1_DOC
				ZAU->ZAU_SERIE  := SD1->D1_SERIE
				ZAU->ZAU_FORNEC := SD1->D1_FORNECE
				ZAU->ZAU_LOJA   := SD1->D1_LOJA
				ZAU->ZAU_VALUNI := SD1->D1_VUNIT
				ZAU->ZAU_VALACR := nAcres
				ZAU->ZAU_VALCOM := SD1->D1_VUNIT + nAcres
			MsUnlock()                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
		TMPSD1->(DbSkip())	
	Enddo
	TMPSD1->(dbCloseArea())

	TMPTQN->(DbSkip())

Enddo
TMPTQN->(dbCloseArea())

// Lançamentos do ARLA
If Select("TMPSTL") > 0
	TMPSTL->(dbCloseArea())
EndIf

cQuery := "SELECT DISTINCT STL.TL_CODIGO "
cQuery += " FROM "+RetSqlName("STL")+" STL "
cQuery += "	 JOIN "+RetSqlName("STJ")+" STJ ON "
cQuery += "	     STJ.TJ_FILIAL = '"+xFilial("STJ")+ "' "
cQuery += "	 AND STJ.TJ_ORDEM = STL.TL_ORDEM "
cQuery += "	 AND STJ.TJ_PLANO = STL.TL_PLANO AND STJ.D_E_L_E_T_ = ' '"
cQuery += " JOIN "+RetSqlName("ST9")+" ST9 ON ST9.T9_FILIAL = '"+xFilial("ST9")+"' AND STJ.TJ_CODBEM = ST9.T9_CODBEM "
cQuery += "  AND ST9.D_E_L_E_T_ = ' ' AND ST9.T9_PROPRIE = '2' AND ST9.T9_XTPTER = '1' "
cQuery += " WHERE STL.TL_FILIAL = '"+xFilial("STL")+"' AND STL.TL_CODIGO = '130011' AND STL.D_E_L_E_T_ = ' ' AND STJ.TJ_DTORIGI BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"' "
cQuery += " AND STJ.D_E_L_E_T_ = ' ' "
cQuery += " AND STJ.TJ_SERVICO = 'C00014' "
DbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), "TMPSTL", .f., .f.)

oProcTTP:IncRegua1("Apuração de Preços de Compra de ARLA  ..")
oProcTTP:SetRegua2(1000)

While !TMPSTL->(Eof())

	oProcTTP:IncRegua2()

	cQuery := "   SELECT SD1.R_E_C_N_O_, D1_DTDIGIT, D1_COD, D1_VUNIT " + CRLF
	cQuery += "     FROM "+RetSqlName("SD1")+" SD1 " + CRLF
	cQuery += "    JOIN  "+RetSqlName("SF4")+" SF4 ON ( F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' '  ) " + CRLF
	cQuery += "    WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D1_COD = '130011'" + CRLF
	cQuery += "      AND SD1.D_E_L_E_T_ = ' ' AND SD1.D1_DTDIGIT BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"' " + CRLF
	cQuery += " ORDER BY 2,1 DESC "

	DbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), "TMPSD1", .f., .f.)

//	nRecSD1 := FM_Sql(cQuery)

//	If nRecSD1 > 0

	While !TMPSD1->(Eof())
		SD1->(DbGoto(TMPSD1->(RECSD1)))
		lProcess := .t.
		DbSelectArea("ZAU")
		If !DbSeek(xFilial("ZAU")+"007"+Dtos(SD1->D1_DTDIGIT))
			RecLock("ZAU",!Found())
			ZAU->ZAU_FILIAL := xFilial("ZAU")
			ZAU->ZAU_CODCOM := "007"
			ZAU->ZAU_PRODUT := "130011"
			ZAU->ZAU_DATCPA := SD1->D1_DTDIGIT
			ZAU->ZAU_DOC    := SD1->D1_DOC
			ZAU->ZAU_SERIE  := SD1->D1_SERIE
			ZAU->ZAU_FORNEC := SD1->D1_FORNECE
			ZAU->ZAU_LOJA   := SD1->D1_LOJA
			ZAU->ZAU_VALUNI := SD1->D1_VUNIT
			ZAU->ZAU_VALACR := nAcres
			ZAU->ZAU_VALCOM := SD1->D1_VUNIT + nAcres
			MsUnlock()
		Endif
		TMPSD1->(DbSkip())
	Enddo
	TMPSD1->(dbCloseArea())

	TMPSTL->(DbSkip())

Enddo
TMPSTL->(dbCloseArea())

End Transaction

If lProcess
	MsgInfo("Apuração de Preços de Compra de Combustiveis da Filial "+SubStr(FwxFilial("TQN"),6,2)+" ocorrida com sucesso!","Atenção")
Else
	MsgInfo("Não foram encontrados registros de compra na Filial "+SubStr(FwxFilial("TQN"),6,2)+" no periodo informado!","Atenção")
Endif

Return
