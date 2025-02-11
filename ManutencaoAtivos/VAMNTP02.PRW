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

Local aParamBox := {}
Local aRet      := {}
Local dDatCorte := GetMv("VA_RECCMB",,cTod("01/01/2021")) // Data de Minima para Recálculo de Abastecimentos
Private dDatIni := cTod("")
Private dDatFin := cTod("")

aAdd(aParamBox,{1,"Data Inicial",Ctod(""),"@D","","","",50,.f.})
aAdd(aParamBox,{1,"Data Final",Ctod(""),"@D","","","",50,.f.})

While .t.
	If ParamBox(aParamBox,"",@aRet,,,,,,,,.F.)
		dDatIni  := aRet[1]
		dDatFin  := aRet[2]
	Else
		Return
	EndIf

	If Empty(dDatIni) .or. Empty(dDatFin) .or. (dDatFin<dDatIni)
		MsgStop("Data(s) Inválida(s)! Favor informar corretamente!")
		Loop
	Endif

	If (dDatIni<dDatCorte)
		MsgStop("Data Inicial MENOR que a Data de Corte informada no parâmetro VA_RECCMB! Favor informar corretamente!")
		Loop
	Endif

	Exit
Enddo

oProcTTP := MsNewProcess():New({ |lEnd| FS_Proc01() }," ","",.f.)
oProcTTP:Activate()

Return


Static Function FS_Proc01()
Local lProcess  := .f.
Local nAcres    := GetMv("VA_ACCMBI",,0.20) // Valor do Acescimo no preço do litro Combustivel do Prestadores de Serviço
Local cAlias    := ""
Local cAliasS    := ""
Local cAlias1    := ""

DbSelectArea("ZAU")

// Abastecimentos
//If Select(cAlias) > 0
//	(cAlias)->(dbCloseArea())
//EndIf

cQuery := "SELECT DISTINCT TQN.TQN_CODCOM, TQI.TQI_PRODUT "
cQuery += " FROM "+RetSqlName("TQN")+" TQN "
cQuery += " JOIN "+RetSqlName("ST9")+" ST9 ON ST9.T9_FILIAL = '"+xFilial("ST9")+"' AND TQN.TQN_FROTA = ST9.T9_CODBEM "
cQuery += "  AND ST9.D_E_L_E_T_ = ' ' AND ST9.T9_PROPRIE = '2' AND ST9.T9_XTPTER = '1' "
cQuery += " JOIN "+RetSqlName("TQI")+" TQI ON TQI.TQI_FILIAL = '"+xFilial("TQI")+"' AND TQN.TQN_CODCOM = TQI.TQI_CODCOM "
cQuery += "  AND TQI.D_E_L_E_T_ = ' ' "
cQuery += " WHERE TQN.TQN_FILIAL = '"+xFilial("TQN")+"' AND TQN.D_E_L_E_T_ = ' ' AND TQN.TQN_DTABAS BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"' "

cAlias := GetNextAlias()
MpSysOpenQry(cQuery, cAlias)

oProcTTP:IncRegua1("Apuração de Preços de Compra de Combustiveis  ..")
oProcTTP:SetRegua2(1000)

Begin Transaction

While !(cAlias)->(Eof())

	oProcTTP:IncRegua2()

	cQuery := "   SELECT SD1.R_E_C_N_O_ RECSD1 "
	cQuery += "     FROM "+RetSqlName("SD1")+" SD1 " + CRLF
	cQuery += "    JOIN  "+RetSqlName("SF4")+" SF4 ON ( F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' '  ) " + CRLF
	cQuery += "    WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D1_COD = '"+(cAlias)->TQI_PRODUT+"'" + CRLF
	cQuery += "      AND SD1.D_E_L_E_T_ = ' ' AND SD1.D1_DTDIGIT BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"' " + CRLF
	cQuery += " ORDER BY 1 DESC"

	cAliasS := GetNextAlias()
	MpSysOpenQry(cQuery, cAliasS)

	While !(cAliasS)->(Eof())
		SD1->(DbGoto((cAliasS)->(RECSD1)))
		lProcess := .t.

		DbSelectArea("ZAU")
		ZAU->(DbSetOrder(1))

		IF SD1->D1_FORNECE == '000025' // V@ 
			// REGRE PARA SE O FORNECEDOR DE COMBUSTIVEL FOR OUTRA FILIAL DA V@, BUSCAR A NOTA DE COMPRA NAQUELA FILIAL.
			cQuery := "   SELECT top 1 SD1.R_E_C_N_O_ RECSD1 "
			cQuery += "     FROM "+RetSqlName("SD1")+" SD1 " + CRLF
			cQuery += "    JOIN  "+RetSqlName("SF4")+" SF4 ON ( F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' '  ) " + CRLF
			cQuery += "    WHERE SD1.D1_FILIAL = '"+ "01010"+SD1->D1_LOJA+"' AND SD1.D1_COD = '"+(cAlias)->TQI_PRODUT+"'" + CRLF
			cQuery += "      AND SD1.D_E_L_E_T_ = ' ' 
			cQuery += "	  	AND SD1.D1_DTDIGIT <= '"+dToS(SD1->D1_EMISSAO)+"' " + CRLF
	  		cQuery += "		AND SD1.D1_FORNECE <> '"+SD1->D1_FORNECE+"' " + CRLF
			cQuery += " ORDER BY SD1.R_E_C_N_O_ DESC"

			cAlias1 := GetNextAlias()
			MpSysOpenQry(cQuery, cAlias1)

				SD1->(DbGoto((cAlias1)->RECSD1))

			(cAlias1)->(dbCloseArea())

		ENDIF

		RecLock("ZAU",lRecLock := !DbSeek(xFilial("ZAU")+(cAlias)->TQN_CODCOM+Dtos(SD1->D1_DTDIGIT))) 
			ZAU->ZAU_FILIAL := xFilial("ZAU")
			ZAU->ZAU_CODCOM := (cAlias)->TQN_CODCOM
			ZAU->ZAU_PRODUT := (cAlias)->TQI_PRODUT
			ZAU->ZAU_DATCPA := SD1->D1_DTDIGIT
			ZAU->ZAU_DOC    := SD1->D1_DOC
			ZAU->ZAU_SERIE  := SD1->D1_SERIE
			ZAU->ZAU_FORNEC := SD1->D1_FORNECE
			ZAU->ZAU_LOJA   := SD1->D1_LOJA
			ZAU->ZAU_VALUNI := SD1->D1_VUNIT
			ZAU->ZAU_VALACR := nAcres
			ZAU->ZAU_VALCOM := SD1->D1_VUNIT + nAcres
		MsUnlock()

		(cAliasS)->(DbSkip())	
	Enddo
	(cAliasS)->(dbCloseArea())

	(cAlias)->(DbSkip())

Enddo
(cAlias)->(dbCloseArea())

// Lançamentos do ARLA

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
cQuery += " AND STJ.TJ_SERVICO = 'C00014' 

cALias := GetNextAlias()
MpSysOpenQry(cQuery, cAlias)

oProcTTP:IncRegua1("Apuração de Preços de Compra de ARLA  ..")
oProcTTP:SetRegua2(1000)

While !(cAlias)->(Eof())

	oProcTTP:IncRegua2()

	cQuery := "   SELECT SD1.R_E_C_N_O_, D1_DTDIGIT, D1_COD, D1_VUNIT " + CRLF
	cQuery += "     FROM "+RetSqlName("SD1")+" SD1 " + CRLF
	cQuery += "    JOIN  "+RetSqlName("SF4")+" SF4 ON ( F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' '  ) " + CRLF
	cQuery += "    WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D1_COD = '130011'" + CRLF
	cQuery += "      AND SD1.D_E_L_E_T_ = ' ' AND SD1.D1_DTDIGIT BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"' " + CRLF
	cQuery += " ORDER BY 2,1 DESC "

	cAliasS := GetNextAlias()
	MpSysOpenQry(cQuery, cAliasS)

	While !(cAliasS)->(Eof())
		SD1->(DbGoto((cAliasS)->(RECSD1)))
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
		(cAliasS)->(DbSkip())	
	Enddo
	(cAliasS)->(dbCloseArea())

	(cAlias)->(DbSkip())

Enddo
(cAlias)->(dbCloseArea())

End Transaction

If lProcess
	MsgInfo("Apuração de Preços de Compra de Combustiveis ocorrida com sucesso!","Atenção")
Else
	MsgInfo("Não foram encontrados registros de compra no periodo informado!","Atenção")
Endif

Return
