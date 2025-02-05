#Include "Protheus.ch"
#include "Tbiconn.ch"
#include "TopConn.ch"
#include "Totvs.ch"

// ###############################################################################################
// Projeto: 
// Fonte  : VAMNTP01.prw
// ---------+------------------------------------+------------------------------------------------
// Data     | Autor                              | Descricao
// ---------+------------------------------------+------------------------------------------------
//  22/02/22|  Manoel Filho                      | Reprocessamento dos Abastecimento de Veiculos  
//          |                                    |  de Terceiros
// ---------+------------------------------------+------------------------------------------------
User Function VAMNTP01()

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
Local nValComb  := 0
Local lCombZERO := .f.

// Reprocessando Abastecimentos
If Select("TMPTQN") > 0
	TMPTQN->(dbCloseArea())
EndIf

cQuery := "SELECT TQN.TQN_DTABAS, TQN.TQN_CODCOM, TQN.R_E_C_N_O_  AS RECTQN, ST9.T9_FORNECE, ST9.T9_LOJA, ST9.T9_XTPTER "
cQuery += " FROM "+RetSqlName("TQN")+" TQN " 
cQuery += " JOIN "+RetSqlName("ST9")+" ST9 ON TQN.TQN_FILIAL = ST9.T9_FILIAL AND TQN.TQN_FROTA = ST9.T9_CODBEM "
cQuery += "  AND ST9.D_E_L_E_T_ = ' ' AND ST9.T9_PROPRIE = '2'
cQuery += "  WHERE TQN.D_E_L_E_T_ = ' ' AND TQN.TQN_DTABAS BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"' "
DbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), "TMPTQN", .f., .f.)

Begin Transaction

oProcTTP:IncRegua1("Reprocessando abastecimentos..")
oProcTTP:SetRegua2(1000)

While !TMPTQN->(Eof())
	
	oProcTTP:IncRegua2()
	
	if TMPTQN->(T9_XTPTER) $ "1" // Prestador de Serviço
		cQuery := "SELECT TOP 1 ZAU.ZAU_VALCOM FROM "+RetSqlName("ZAU")+" ZAU WHERE ZAU.ZAU_FILIAL = '"+FWXFILIAL("ZAU")+"' AND ZAU.D_E_L_E_T_ = ' ' AND ZAU.ZAU_CODCOM = '"+TMPTQN->(TQN_CODCOM)+"' AND ZAU.ZAU_DATCPA <= (SELECT Max(ZAU_DATCPA) FROM "+RetSqlName("ZAU")+" WHERE D_E_L_E_T_ = ' ' AND ZAU_DATCPA <= '"+TMPTQN->(TQN_DTABAS)+"' AND ZAU_CODCOM = '"+TMPTQN->(TQN_CODCOM)+"') ORDER BY ZAU.ZAU_DATCPA DESC"
	ElseIf TMPTQN->(T9_XTPTER) $ "23" // Transportadora
		cQuery := "SELECT ZAT.ZAT_VALCOM FROM "+RetSqlName("ZAT")+" ZAT WHERE ZAT.D_E_L_E_T_ = ' ' AND ZAT.ZAT_CODCOM = '"+TMPTQN->(TQN_CODCOM)+"' AND ZAT.ZAT_DATCAD = (SELECT Max(ZAT_DATCAD) FROM "+RetSqlName("ZAT")+" WHERE D_E_L_E_T_ = ' ' AND ZAT_DATCAD <= '"+TMPTQN->(TQN_DTABAS)+"' AND ZAT_CODCOM = '"+TMPTQN->(TQN_CODCOM)+"')"
	Endif
	nValComb := FM_Sql(cQuery)
	// Atualiza Campo Titulo da Tabela TQN
	
	If nValComb > 0
		dbSelectArea("TQN")

		TQN->(DbGoto(TMPTQN->(RECTQN)))
		RecLock("TQN", .f.)
		TQN->TQN_VUNABA := nValComb
		TQN->TQN_VTTABA := TQN->TQN_VUNABA * TQN->TQN_QUANT
		If Empty(TQN->TQN_FORST9)
			TQN->TQN_FORST9 := TMPTQN->(T9_FORNECE)
			TQN->TQN_LOJST9 := TMPTQN->(T9_LOJA)
		Endif
		MsUnlock()
		lProcess := .t.
	Else
		lCombZERO := .t.
	Endif
	TMPTQN->(DbSkip())

Enddo
TMPTQN->(dbCloseArea())

// Reprocessando Lançamentos ARLA
If Select("TMPSTL") > 0
	TMPSTL->(dbCloseArea())
EndIf

cQuery := "SELECT STJ.TJ_DTORIGI, STL.R_E_C_N_O_  AS RECSTL, ST9.T9_FORNECE, ST9.T9_LOJA, ST9.T9_XTPTER "
cQuery += " FROM "+RetSqlName("STL")+" STL " 
cQuery += "	 JOIN "+RetSqlName("STJ")+" STJ ON STJ.TJ_FILIAL = '"+xFilial("STJ")+ "' "
cQuery += "	 AND STJ.TJ_ORDEM = STL.TL_ORDEM "
cQuery += "	 AND STJ.TJ_PLANO = STL.TL_PLANO AND STJ.D_E_L_E_T_ = ' '"
cQuery += " JOIN "+RetSqlName("ST9")+" ST9 ON STL.TL_FILIAL = ST9.T9_FILIAL AND STJ.TJ_CODBEM = ST9.T9_CODBEM "
cQuery += "  AND ST9.D_E_L_E_T_ = ' ' AND ST9.T9_PROPRIE = '2'
cQuery += "  WHERE STL.D_E_L_E_T_ = ' ' AND STJ.TJ_DTORIGI BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"' "
cQuery += "  AND STL.TL_CODIGO = '130011' "
cQuery += "  AND STJ.D_E_L_E_T_ = ' ' "
cQuery += "  AND STJ.TJ_SERVICO = 'C00014' "
DbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), "TMPSTL", .f., .f.)

oProcTTP:IncRegua1("Reprocessando abastecimentos..")
oProcTTP:SetRegua2(1000)

While !TMPSTL->(Eof())

	oProcTTP:IncRegua2()
	
	if TMPSTL->(T9_XTPTER) == "1" // Prestador de Serviço
		cQuery := "SELECT ZAU.ZAU_VALCOM FROM "+RetSqlName("ZAU")+" ZAU WHERE ZAU.D_E_L_E_T_ = ' ' AND ZAU.ZAU_CODCOM = '007' AND ZAU.ZAU_DATCPA = (SELECT Max(ZAU_DATCPA) FROM "+RetSqlName("ZAU")+" WHERE D_E_L_E_T_ = ' ' AND ZAU_DATCPA <= '"+TMPSTL->(TJ_DTORIGI)+"' AND ZAU_CODCOM = 'ARL')"
	ElseIf TMPSTL->(T9_XTPTER) $ "23" // Transportadora
		cQuery := "SELECT ZAT.ZAT_VALCOM FROM "+RetSqlName("ZAT")+" ZAT WHERE ZAT.D_E_L_E_T_ = ' ' AND ZAT.ZAT_CODCOM = '007' AND ZAT.ZAT_DATCAD = (SELECT Max(ZAT_DATCAD) FROM "+RetSqlName("ZAT")+" WHERE D_E_L_E_T_ = ' ' AND ZAT_DATCAD <= '"+TMPSTL->(TJ_DTORIGI)+"' AND ZAT_CODCOM = '007')"
	Endif
	nValComb := FM_Sql(cQuery)

	If nValComb > 0
		STL->(DbGoto(TMPSTL->(RECSTL)))
		RecLock("STL", .f.)
		STL->TL_VUNABA := nValComb
		STL->TL_VTTABA := STL->TL_VUNABA * STL->TL_QUANTID
		If Empty(STL->TL_FORST9)
			STL->TL_FORST9 := TMPSTL->(T9_FORNECE)
			STL->TL_LOJST9 := TMPSTL->(T9_LOJA)
		Endif
		MsUnlock()
		lProcess := .t.
	Else
		lCombZERO := .t.
	Endif
		
	TMPSTL->(DbSkip())

Enddo
TMPSTL->(dbCloseArea())

End Transaction

If lProcess
	MsgInfo("Reprocessamento realizado com sucesso!!!"+IIf(lCombZERO,CRLF+CRLF+"Porém alguns abastecimentos não foram reprocessados por não haver Preço do Combustivel vigente na data do evento!",""), "Atenção")
Else
	MsgInfo("Não houve reprocessamento porque não há dados a serem processados ou não há preço de combustivel vigente nesta data!!!", "Atenção")
Endif

Return

/*
SELECT TJ_CODBEM, TJ_DTORIGI,  TJ_TIPOOS, TL_FILIAL, TL_CODIGO, TL_QUANTID, TJ_CODBEM
    FROM STL010 STL
	JOIN STJ010 STJ ON
	     TJ_FILIAL = '01'
	 AND TJ_ORDEM= TL_ORDEM
	 AND TJ_PLANO = TL_PLANO
	-- AND TJ_CODBEM = TL_CODBEM
	 AND STL.D_E_L_E_T_ = ' ' 
	JOIN TZZ010 TZZ ON
	     TZZ_FILIAL = '01' 
	 AND TZZ_PRODUT = TL_CODIGO
	JOIN ST9010 ST9 ON ( ST9.T9_FILIAL = '01' 
	 AND ST9.T9_CODBEM = STJ.TJ_CODBEM AND ST9.T9_PROPRIE = '1' AND ST9.D_E_L_E_T_ = ' ' )
   WHERE TL_FILIAL = '01'
     AND TL_CODIGO = '130011' -- PRODUTO
	 AND STJ.D_E_L_E_T_ = ' '
	 AND TJ_SERVICO = 'C00014' -- MESMO PREENCHIDO NA TELA DE ABASTECIMENTO EM PRODUTOS
     AND STJ.TJ_DTORIGI BETWEEN '20220101' AND '20220210' AND STL.D_E_L_E_T_ = ' '
	 ORDER BY STJ.R_E_C_N_O_ DESC
*/
