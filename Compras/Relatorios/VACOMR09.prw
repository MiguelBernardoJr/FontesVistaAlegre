#Include "Rwmake.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  29.01.2018                                                              |
 | Desc:  Relatório de apuração de resultados.                                    |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VACOMR09() // U_VACOMR09()

Local   aArea		:= GetArea()
Local oReport                 

Private nRegistros	:= 0
Private cPerg		:= "VACOMR09"
Private cAlias    := CriaTrab(,.F.)   
Private cTitulo 	:= "Relatório de apuração de resultados"

	GeraX1(cPerg)

	If !Pergunte(cPerg, .T.)
		Return Nil
	EndIf

	cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01)

	oReport := ReportDef()
	oReport:PrintDialog()
	
	(cAlias)->(DbCloseArea())
	
	RestArea(aArea)
	
Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  26.01.2017                                                              |
 | Desc:  Relatorio de Lotação de Baias e Pastos.                                 |
 |        Este relatorio faz exportacao direta para execel.                       |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function ReportDef(cCodigo)
	
	Local oReport	:= nil
	Local oSection1	:= nil, oBreak1 := nil
	
	fQuadro1() // Quantidade

	oReport := TReport():New(cPerg+DtoS(dDataBase)+SubS(StrTran(Time(),":",""),1,4), cTitulo, cPerg, {|oReport| PrintReport(oReport) },"Este relatorio ira listar os produtos em suas Baias e Pastos" , .T./* lLandscape */,/* uTotalText */, /* .T.  lTotalInLine */, /* cPageTText */,/* lPageTInLine */,.F. /* lTPageBreak */,/* nColSpace */)
	oReport:nFontBody := 8
	oReport:cFontBody := 'Arial Narrow'
	oReport:lParamPage := .F. // nao imprimir pagina de parametros
	
	oSection1 := TRSection():New(oReport, OemToAnsi(cTitulo) )//, /* uTable */,/* aOrder */,/* lLoadCells */,/* lLoadOrder */,/* uTotalText */,/* lTotalInLine */, .F. /* lHeaderPage */, .F. /* lHeaderBreak */, .F. /* lPageBreak */, .F. /* lLineBreak */, /* nLeftMargin */, /* lLineStyle */, /* nColSpace */, .T. /* lAutoSize */,/* cCharSeparator */, /* nLinesBefore */, /* nCols */, /* nClrBack */, /* nClrFore */, /* nPercentage */)
	TRCell():New(oSection1, "_PAR01" , , "Filial"			, , TamSX3("NNR_DESCRI")[1] )
	TRCell():New(oSection1, "_PAR02" , , "Bezerro Mamando"  , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR03" , , "Bezerro Desmama"  , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR04" , , "Garrote"          , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR05" , , "Boi"              , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR06" , , "Touro"            , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR07" , , "Bezzerra Mamando" , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR08" , , "Bezzerra Desmama" , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR09" , , "Novilha"          , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR10" , , "Vaca"             , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR11" , , "TOTAL"            , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR12" , , "Macho"            , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR13" , , "Capão"            , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR14" , , "Femea"            , "@E 999,999", TamSX3("B2_QATU")[1] )

/* 	
	oBreak1 := TRBreak():New(oSection1, "", "Total Rebanho", .F. )
	TRFunction():New(oSection1:Cell( "_PAR02" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR03" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR04" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR05" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR06" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR07" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR08" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR09" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR10" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR11" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR12" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR13" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR14" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )	
 */
 Return oReport

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  26.01.2017                                                              |
 | Desc:  Relatorio de Lota??o de Baias e Pastos.                                 |
 |        Este relatorio faz exportacao direta para execel.                       |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function PrintReport(oReport)

	Local oSection1    := oReport:Section(1)

	Local aDados 	   := Array(14)
	
	Local nQuant	   := 0

	oReport:SetMeter(nRegistros)

	oSection1:Cell( "_PAR01" ):SetBlock( { || aDados[01] } )
    oSection1:Cell( "_PAR02" ):SetBlock( { || aDados[02] } )
    oSection1:Cell( "_PAR03" ):SetBlock( { || aDados[03] } )
    oSection1:Cell( "_PAR04" ):SetBlock( { || aDados[04] } )
    oSection1:Cell( "_PAR05" ):SetBlock( { || aDados[05] } )
    oSection1:Cell( "_PAR06" ):SetBlock( { || aDados[06] } )
    oSection1:Cell( "_PAR07" ):SetBlock( { || aDados[07] } )
    oSection1:Cell( "_PAR08" ):SetBlock( { || aDados[08] } )
    oSection1:Cell( "_PAR09" ):SetBlock( { || aDados[09] } )
    oSection1:Cell( "_PAR10" ):SetBlock( { || aDados[10] } )
    oSection1:Cell( "_PAR11" ):SetBlock( { || aDados[11] } )
    oSection1:Cell( "_PAR12" ):SetBlock( { || aDados[12] } )
    oSection1:Cell( "_PAR13" ):SetBlock( { || aDados[13] } )
    oSection1:Cell( "_PAR14" ):SetBlock( { || aDados[14] } )
	
	oSection1:Init()  
	oReport:PrintText(cTitulo)	
	
	While !oReport:Cancel() .And. !(cAlias)->(Eof())
		
		oReport:IncMeter()
		
		if  (cAlias)->BEZERROMAMANDO > 0 .or. ;
			(cAlias)->BEZERRODESMAMA > 0 .or. ;
			(cAlias)->GARROTE > 0 .or. ;
			(cAlias)->BOI > 0 .or. ;
			(cAlias)->TOURO > 0 .or. ;
			(cAlias)->BEZERRAMAMANDO > 0 .or. ;
			(cAlias)->BEZERRADESMAMA > 0 .or. ;
			(cAlias)->NOVILHA > 0 .or. ;
			(cAlias)->VACA > 0
	
			aDados[01] := (cAlias)->FILIAL
			aDados[02] := (cAlias)->BEZERROMAMANDO
			aDados[03] := (cAlias)->BEZERRODESMAMA
			aDados[04] := (cAlias)->GARROTE
			aDados[05] := (cAlias)->BOI
			aDados[06] := (cAlias)->TOURO
			aDados[07] := (cAlias)->BEZERRAMAMANDO
			aDados[08] := (cAlias)->BEZERRADESMAMA
			aDados[09] := (cAlias)->NOVILHA
			aDados[10] := (cAlias)->VACA
			aDados[11] :=  aDados[02]+;
							 aDados[03]+;
							 aDados[04]+;
							 aDados[05]+;
							 aDados[06]+;
							 aDados[07]+;
							 aDados[08]+;
							 aDados[09]+;
							 aDados[10]
			aDados[12] := (cAlias)->MACHO
			aDados[13] := (cAlias)->CAPAO
			aDados[14] := (cAlias)->FEMEA
			
			oSection1:PrintLine()		
		EndIf
		(cAlias)->(DbSkip())	
	EndDo
		
	EndIf
	
	oSection1:Finish()
	oReport:SkipLine() // oReport:SetStartPage(.T.)

Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.02.2017                                                              |
 | Desc:  Processa informaçao de quantidade dos bois por ERA;                     |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1()
Local aArea := GetArea()
Local _cQry := ""

	_cQry := " WITH PRODUTOS AS ( " + CRLF
	_cQry += " 	SELECT DISTINCT B1_XLOTCOM,  " + CRLF
	_cQry += " 	rTrim(Replicate(' ', 6 - Len(B1_XLOTE) ) + B1_XLOTE) " + CRLF
	_cQry += " 	B1_XLOTE,  " + CRLF
	_cQry += " 	B1_COD,  " + CRLF
	_cQry += " 	B1_XPESOCO, B1_XDATACO, " + CRLF
	_cQry += " 	B1_X_PESOC, " + CRLF
	_cQry += " 	B1_X_SEXO, " + CRLF
	_cQry += " 	B1_XRACA " + CRLF
	_cQry += " 	FROM SB1010 B1  " + CRLF
	_cQry += " 	WHERE	B1_FILIAL=' ' " + CRLF
	_cQry += " 		AND B1_COD IN (SELECT C7_PRODUTO FROM SC7010 WHERE D_E_L_E_T_=' '  " + CRLF
	_cQry += " 				AND C7_FILENT='01' " + CRLF
	_cQry += " 				AND C7_NUM='010701' " + CRLF
	_cQry += " 				AND C7_ITEM='0001') " + CRLF
	_cQry += " 		AND B1.D_E_L_E_T_=' '  " + CRLF
	_cQry += " ), " + CRLF
	_cQry += "  " + CRLF
	_cQry += " SALDOATUAL AS ( " + CRLF
	_cQry += " 	SELECT B2_COD, SUM(B2_QATU) SALDOATUAL " + CRLF
	_cQry += " 	FROM SB2010 B2  " + CRLF
	_cQry += " 	JOIN PRODUTOS ON B2_COD=B1_COD AND B2.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	GROUP BY B2_COD " + CRLF
	_cQry += " ), " + CRLF
	_cQry += "  " + CRLF
	_cQry += " SALDOLOTE AS ( " + CRLF
	_cQry += " 	SELECT B8_PRODUTO, B8_LOTECTL, B8_XDATACO, B8_XPESOCO, " + CRLF
	_cQry += " 	SUM(B8_QTDORI) B8_QTDORI, SUM(B8_SALDO) B8_SALDO " + CRLF
	_cQry += " 	FROM SB8010 B2  " + CRLF
	_cQry += " 	JOIN PRODUTOS ON B8_PRODUTO=B1_COD AND B2.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	GROUP BY B8_PRODUTO, B8_LOTECTL, B8_XDATACO, B8_XPESOCO " + CRLF
	_cQry += " ), " + CRLF
	_cQry += "  " + CRLF
	_cQry += " PEDIDOCOMPRA AS (  " + CRLF
	_cQry += " 	SELECT DISTINCT C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO, C7_QUANT, C7_TOTAL, C7_X_PESO, C7_X_REND, C7_X_RENDP, C7_X_ARROV, C7_X_ARROQ, C7_X_TOTAL, C7_X_VLUNI,  " + CRLF
	_cQry += " 	C7_VALICM, C7_X_TOICM,  " + CRLF
	_cQry += " 	C7_X_CORRE, A3_NOME, " + CRLF
	_cQry += " 	C7_OBS     " + CRLF
	_cQry += " 	FROM SC7010 C7 " + CRLF
	_cQry += " 	JOIN PRODUTOS  ON B1_XLOTCOM=C7_FILENT+C7_NUM  " + CRLF
	_cQry += " 	AND C7.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	JOIN SA3010 A3 ON A3_FILIAL=' ' AND A3_COD=C7_X_CORRE AND A3.D_E_L_E_T_=' ' " + CRLF
	_cQry += " ), " + CRLF
	_cQry += "  " + CRLF
	_cQry += " BASECONTRATUAL AS ( " + CRLF
	_cQry += " 	SELECT ZBC_FILIAL, ZBC_PEDIDO, ZBC_ITEMPC, ZBC_PESO, ZBC_ARROV, ZBC_VLFRPG,	ZBC_REND, ZBC_RENDP " + CRLF
	_cQry += " 	FROM ZBC010 Z " + CRLF
	_cQry += " 	JOIN PEDIDOCOMPRA P ON Z.ZBC_FILIAL=P.C7_FILIAL AND Z.ZBC_PEDIDO=P.C7_NUM AND Z.ZBC_ITEMPC=P.C7_ITEM  " + CRLF
	_cQry += " 			AND Z.D_E_L_E_T_=' ' " + CRLF
	_cQry += " ), " + CRLF
	_cQry += "  " + CRLF
	_cQry += " NOTAENTRADA AS ( " + CRLF
	_cQry += " 	SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_PEDIDO, D1_EMISSAO, SUM(D1_QUANT) D1_QUANT, D1_X_PESCH, D1_X_KM " + CRLF
	_cQry += " 	FROM SD1010 D1 " + CRLF
	_cQry += " 	JOIN PRODUTOS ON B1_XLOTCOM=D1_FILIAL+D1_PEDIDO AND D1.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	GROUP BY D1_FILIAL, D1_DOC, D1_SERIE, D1_PEDIDO, D1_EMISSAO, D1_X_PESCH, D1_X_KM " + CRLF
	_cQry += " ), " + CRLF
	_cQry += "  " + CRLF
	_cQry += " FATURADO AS ( " + CRLF
	_cQry += " 	SELECT D2_COD, D2_EMISSAO, SUM(D2_QUANT) FATURADO " + CRLF
	_cQry += " 	FROM SD2010 D2 " + CRLF
	_cQry += " 	JOIN PRODUTOS ON D2_COD=B1_COD AND D2.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	GROUP BY D2_COD, D2_EMISSAO " + CRLF
	_cQry += " ), " + CRLF
	_cQry += "  " + CRLF
	_cQry += " BASE1 AS( " + CRLF
	_cQry += " 	SELECT DISTINCT  " + CRLF
	_cQry += " 	B1_XLOTCOM,  " + CRLF
	_cQry += " 	ISNULL(D2_EMISSAO,'') D2_EMISSAO, " + CRLF
	_cQry += " 	CASE  " + CRLF
	_cQry += " 	 WHEN B8_LOTECTL = ' ' " + CRLF
	_cQry += " 	  THEN B1_XLOTE ELSE B8_LOTECTL END B8_LOTECTL, " + CRLF
	_cQry += " 	B8_QTDORI, " + CRLF
	_cQry += " 	B8_SALDO, " + CRLF
	_cQry += " 	ISNULL(FATURADO,0) FATURADO, " + CRLF
	_cQry += " 	CASE  " + CRLF
	_cQry += " 	 WHEN B8_XDATACO = ' ' " + CRLF
	_cQry += " 		THEN B1_XDATACO ELSE B8_XDATACO END B8_XDATACO, " + CRLF
	_cQry += " 	B1_X_SEXO Sexo, " + CRLF
	_cQry += " 	B1_XRACA Raca, " + CRLF
	_cQry += " 	CASE  " + CRLF
	_cQry += " 		WHEN B1_X_PESOC=0 " + CRLF
	_cQry += " 		 THEN ZBC_PESO " + CRLF
	_cQry += " 		 ELSE B1_X_PESOC " + CRLF
	_cQry += " 	END PESOORIGEM, " + CRLF
	_cQry += " 	CASE " + CRLF
	_cQry += " 		WHEN B8_XPESOCO=0 " + CRLF
	_cQry += " 			THEN B1_XPESOCO " + CRLF
	_cQry += " 			ELSE B1_XPESOCO " + CRLF
	_cQry += " 	END B8_XPESOCO, " + CRLF
	_cQry += " 	D1_X_PESCH,	 " + CRLF
	_cQry += " 	CASE " + CRLF
	_cQry += " 		WHEN C7_X_ARROV=0  " + CRLF
	_cQry += " 			THEN ZBC_ARROV  " + CRLF
	_cQry += " 			ELSE C7_X_ARROV  " + CRLF
	_cQry += " 	END VALORARROBA, " + CRLF
	_cQry += " 	CASE " + CRLF
	_cQry += " 	 WHEN ZBC_REND=0 " + CRLF
	_cQry += " 		THEN C7_X_REND " + CRLF
	_cQry += " 		ELSE ZBC_REND " + CRLF
	_cQry += " 	END ZBC_REND, " + CRLF
	_cQry += " 	ZBC_RENDP,  " + CRLF
	_cQry += " 	( (CASE  " + CRLF
	_cQry += " 		WHEN B1_X_PESOC=0 " + CRLF
	_cQry += " 		 THEN ZBC_PESO " + CRLF
	_cQry += " 		 ELSE B1_X_PESOC " + CRLF
	_cQry += " 	END)  " + CRLF
	_cQry += " 	 - D1_X_PESCH ) / B8_QTDORI AS QUEBRA, " + CRLF
	_cQry += " 	D1_X_KM,  " + CRLF
	_cQry += " 	ZBC_VLFRPG " + CRLF
	_cQry += " 	FROM PRODUTOS " + CRLF
	_cQry += " 	LEFT JOIN SALDOATUAL		ON B1_COD=B2_COD " + CRLF
	_cQry += " 	LEFT JOIN PEDIDOCOMPRA		ON B1_XLOTCOM=C7_FILIAL+C7_NUM " + CRLF
	_cQry += " 	LEFT JOIN BASECONTRATUAL	ON C7_FILIAL+C7_NUM+C7_ITEM=ZBC_FILIAL+ZBC_PEDIDO+ZBC_ITEMPC " + CRLF
	_cQry += " 	LEFT JOIN NOTAENTRADA		ON B1_XLOTCOM=D1_FILIAL+D1_PEDIDO " + CRLF
	_cQry += " 	LEFT JOIN FATURADO			ON D2_COD=B1_COD " + CRLF
	_cQry += " 	LEFT JOIN SALDOLOTE			ON B1_COD=B8_PRODUTO " + CRLF
	_cQry += " 	-- WHERE FATURADO > 0 " + CRLF
	_cQry += " ) " + CRLF
	_cQry += "  " + CRLF
	_cQry += " -- numeracao da linha no excel " + CRLF
	_cQry += " SELECT  /* 03 */ B1_XLOTCOM				'Lote Compras', " + CRLF
	_cQry += " 		/* 04 */ D2_EMISSAO				'Data da Saída', " + CRLF
	_cQry += " 		/* 05 */ B8_LOTECTL				'Baia', " + CRLF
	_cQry += " 		/* 06 */ B8_QTDORI				'Quant. de animais na baia', " + CRLF
	_cQry += " 		/* 07 */ FATURADO				'Quant. de Animais Abatidos', " + CRLF
	_cQry += " 		/* 08 */ B8_XDATACO				'Data a Entrada', " + CRLF
	_cQry += " 		/* 09 */ PESOORIGEM / B8_QTDORI AS 'PesonaOrigem', " + CRLF
	_cQry += " 		/* 10 */ B8_XPESOCO				'Peso na Apartação', " + CRLF
	_cQry += " 		/* 11 */ PESOORIGEM				'Peso Total Origem', " + CRLF
	_cQry += " 		/* 12 */ ZBC_REND				'Compra rend. %', " + CRLF
	_cQry += " 		/* 13 */ ZBC_RENDP / B8_QTDORI	AS 'PesoCompraOrigem', " + CRLF
	_cQry += " 		/* 14 */ QUEBRA					'Quebra (kg)', " + CRLF
	_cQry += " 		/* 15 */ B8_XPESOCO+QUEBRA		AS 'PesonaApartaçãoQuebra', " + CRLF
	_cQry += " FROM BASE1 " + CRLF
	_cQry += " ORDER BY B1_XLOTCOM, B8_LOTECTL "

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	If cUserName == 'mbernardo'
		MemoWrite( GetTempPath() + cPerg + '_' + dToS(dDataBase) + '_' + StrTran(Time(), ':', '') + ".sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	// TcSetField(cAlias, "B1_XDATACO"  , "D")
	
	(cAlias)->(DbEval({|| nRegistros++ }))
	(cAlias)->( DbGoTop() )
	
RestArea(aArea)	
Return nil


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  21.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local aRegs		:= {}
Local i         := 0
Local J         := 0

//Conta quantas perguntas existem ualmente.
DbSelectArea('SX1')
DbSetOrder(1)
SX1->(DbGoTop())
If SX1->(DbSeek(cPerg))
	While !SX1->(Eof()) .And. X1_GRUPO = cPerg
		nPergs++
		SX1->(DbSkip())
	EndDo
EndIf

aAdd(aRegs,{cPerg,"01","Dt. Referencia:            ","","","MV_CH1","D",TamSX3("B1_DTNASC")[1],0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","@!"})
//AADD(aRegs,{cPerg,"05","Considera Devolução?","","","mv_ch5","C",03,0,2,"C","","mv_par05","Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","U","","","",""})

//Se quantidade de perguntas for diferente, apago todas
SX1->(DbGoTop())  
If nPergs <> Len(aRegs)
	For nX:=1 To nPergs
		If SX1->(DbSeek(cPerg))		
			If RecLock('SX1',.F.)
				SX1->(DbDelete())
				SX1->(MsUnlock())
			EndIf
		EndIf
	Next nX
EndIf

// gravação das perguntas na tabela SX1
If nPergs <> Len(aRegs)
	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
				For j := 1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next j
			MsUnlock()
		EndIf
	Next i
EndIf

RestArea(_aArea)

Return nil
