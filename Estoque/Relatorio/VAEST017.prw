#INCLUDE "RWMAKE.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.03.2017                                                              |
 | Desc:  Relatorio de Entrada e Saidas com ICMS e Frete - DMG                    |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAEST017() // U_VAEST017()

Local   aArea		:= GetArea()
Local oReport       := nil

Private nRegistros	:= 0
Private cPerg		:= "VAEST017"
Private _cAlias     := CriaTrab(,.F.)   
Private cTitulo 	:= "Relatorio Auxiliar de registro de entrada/saida - DMG"

GeraX1(cPerg)

If !Pergunte(cPerg, .T.)
	Return Nil
EndIf

oReport := ReportDef()
oReport:PrintDialog()

(_cAlias)->(DbCloseArea())

RestArea(aArea)

Return nil
 
 /*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.03.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function ReportDef()
Local oReport	:= nil
Local oSection1	:= nil
Local oBreak	:= nil

oReport := TReport():New(cPerg+DtoS(dDataBase)+SubS(StrTran(Time(),":",""),1,4), cTitulo, cPerg, ;
		{|oReport| PrintReport(oReport) },"Este relatorio ira listar os registros de Entrada/Saída - DMG", ;
		.T./* lLandscape */,/* uTotalText */, /* .T.  lTotalInLine */, /* cPageTText */,/* lPageTInLine */,;
		.F. /* lTPageBreak */,/* nColSpace */)				
oReport:nFontBody := 8
oReport:cFontBody := 'Arial Narrow'
oReport:lParamPage := .F. // nao imprimir pagina de parametros

oSection1 := TRSection():New(oReport, OemToAnsi(cTitulo) )//, /* uTable */,/* aOrder */,/* lLoadCells */,/* lLoadOrder */,/* uTotalText */,/* lTotalInLine */, .F. /* lHeaderPage */, .F. /* lHeaderBreak */, .F. /* lPageBreak */, .F. /* lLineBreak */, /* nLeftMargin */, /* lLineStyle */, /* nColSpace */, .T. /* lAutoSize */,/* cCharSeparator */, /* nLinesBefore */, /* nCols */, /* nClrBack */, /* nClrFore */, /* nPercentage */)
TRCell():New(oSection1, "_PAR01" , , "Filial"	       , X3Picture("D1_FILIAL" ), TamSX3("D1_FILIAL" )[1] )
TRCell():New(oSection1, "_PAR02" , , "Origem"	       , , )
TRCell():New(oSection1, "_PAR03" , , "Serie"	       , X3Picture("D1_SERIE"  ), TamSX3("D1_SERIE"  )[1] )
TRCell():New(oSection1, "_PAR04" , , "Doc"	           , X3Picture("D1_DOC"    ), TamSX3("D1_DOC"    )[1] )
TRCell():New(oSection1, "_PAR05" , , "Data "	       , X3Picture("D1_EMISSAO"), TamSX3("D1_EMISSAO")[1] )
TRCell():New(oSection1, "_PAR06" , , "Entrada"	       , X3Picture("D1_QUANT"  ), TamSX3("D1_QUANT"  )[1] )
TRCell():New(oSection1, "_PAR07" , , "Saida"	       , X3Picture("D1_QUANT"  ), TamSX3("D1_QUANT"  )[1] )
TRCell():New(oSection1, "_PAR08" , , "Codigo"	       , X3Picture("A2_COD"    ), TamSX3("A2_COD"    )[1] )
TRCell():New(oSection1, "_PAR09" , , "Nome"	           , X3Picture("A2_NOME"   ), TamSX3("A2_NOME"   )[1] )
TRCell():New(oSection1, "_PAR10" , , "Inscr. Est."     , X3Picture("A2_INSCR"  ), TamSX3("A2_INSCR"  )[1] )
TRCell():New(oSection1, "_PAR11" , , "Municipio"       , X3Picture("A2_MUN"    ), TamSX3("A2_MUN"    )[1] )
TRCell():New(oSection1, "_PAR12" , , "UF"              , X3Picture("A2_EST"    ), TamSX3("A2_EST"    )[1] )
TRCell():New(oSection1, "_PAR13" , , "Unitario"        , X3Picture("D1_VUNIT"  ), TamSX3("D1_VUNIT"  )[1] )
TRCell():New(oSection1, "_PAR14" , , "Total"           , X3Picture("D1_TOTAL"  ), TamSX3("D1_TOTAL"  )[1] )
TRCell():New(oSection1, "_PAR15" , , "ICMS Gado"       , X3Picture("D1_VALICM" ), TamSX3("D1_VALICM" )[1] )
TRCell():New(oSection1, "_PAR16" , , "Total Frete"     , X3Picture("D1_TOTAL"  ), TamSX3("D1_TOTAL" )[1] )
TRCell():New(oSection1, "_PAR17" , , "ICMS Frete"      , X3Picture("D1_VALICM" ), TamSX3("D1_VALICM" )[1] )
TRCell():New(oSection1, "_PAR18" , , "Touro"		   , X3Picture("D1_QUANT"  ), TamSX3("D1_QUANT"  )[1] )
TRCell():New(oSection1, "_PAR19" , , "Boi"			   , X3Picture("D1_QUANT"  ), TamSX3("D1_QUANT"  )[1] )
TRCell():New(oSection1, "_PAR20" , , "Vaca"	    	   , X3Picture("D1_QUANT"  ), TamSX3("D1_QUANT"  )[1] )
TRCell():New(oSection1, "_PAR21" , , "Garrote"    	   , X3Picture("D1_QUANT"  ), TamSX3("D1_QUANT"  )[1] )
TRCell():New(oSection1, "_PAR22" , , "Novilha"   	   , X3Picture("D1_QUANT"  ), TamSX3("D1_QUANT"  )[1] )
TRCell():New(oSection1, "_PAR23" , , "Bezerro" 		   , X3Picture("D1_QUANT"  ), TamSX3("D1_QUANT"  )[1] )
TRCell():New(oSection1, "_PAR24" , , "Bezerra" 		   , X3Picture("D1_QUANT"  ), TamSX3("D1_QUANT"  )[1] )
TRCell():New(oSection1, "_PAR25" , , "Bufalo" 		   , X3Picture("D1_QUANT"  ), TamSX3("D1_QUANT"  )[1] )
TRCell():New(oSection1, "_PAR26" , , "Bufala" 		   , X3Picture("D1_QUANT"  ), TamSX3("D1_QUANT"  )[1] )
TRCell():New(oSection1, "_PAR27" , , "Soma" 		   , X3Picture("D1_QUANT"  ), TamSX3("D1_QUANT"  )[1] )
oBreak := TRBreak():New(oSection1, oSection1:Cell("_PAR02") ,"",.T. , , .T.)  
TRFunction():New(oSection1:Cell( "_PAR02" ) , "", "COUNT", oBreak , "" , /* "@R 999,999.99" */ , , .F. , .F. , .F. , oSection1 )    

Return oReport

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.03.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function PrintReport(oReport)

	Local oSection1    := oReport:Section(1)
	Local aDados	   := Array(27)
	
	If !fQuadro1()
		Return nil
	EndIf
	
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
	oSection1:Cell( "_PAR15" ):SetBlock( { || aDados[15] } )
	oSection1:Cell( "_PAR16" ):SetBlock( { || aDados[16] } )
	oSection1:Cell( "_PAR17" ):SetBlock( { || aDados[17] } )
	oSection1:Cell( "_PAR18" ):SetBlock( { || aDados[18] } )
	oSection1:Cell( "_PAR19" ):SetBlock( { || aDados[19] } )
	oSection1:Cell( "_PAR20" ):SetBlock( { || aDados[20] } )
	oSection1:Cell( "_PAR21" ):SetBlock( { || aDados[21] } )
	oSection1:Cell( "_PAR22" ):SetBlock( { || aDados[22] } )
	oSection1:Cell( "_PAR23" ):SetBlock( { || aDados[23] } )
	oSection1:Cell( "_PAR24" ):SetBlock( { || aDados[24] } )
	oSection1:Cell( "_PAR25" ):SetBlock( { || aDados[25] } )
	oSection1:Cell( "_PAR26" ):SetBlock( { || aDados[26] } )
	oSection1:Cell( "_PAR27" ):SetBlock( { || aDados[27] } )
	oSection1:Init()  
	oReport:PrintText(cTitulo)	
	
	While !oReport:Cancel() .And. !(_cAlias)->(Eof())

		oReport:IncMeter()
		
		aDados[01] := (_cAlias)->FILIAL
		aDados[02] := (_cAlias)->ORIGEM
		aDados[03] := (_cAlias)->SERIE
		aDados[04] := (_cAlias)->NUMERO
		aDados[05] := (_cAlias)->EMISSAO
		aDados[06] := (_cAlias)->ENTRADA
		aDados[07] := (_cAlias)->SAIDA
		aDados[08] := (_cAlias)->CODIGO
		aDados[09] := (_cAlias)->NOME
		aDados[10] := (_cAlias)->INSCRI_EST
		aDados[11] := (_cAlias)->MUNICIPIO
		aDados[12] := (_cAlias)->UF
		aDados[13] := (_cAlias)->UNITARIO
		aDados[14] := (_cAlias)->TOTAL
		aDados[15] := (_cAlias)->ICMS_GADO
		aDados[16] := (_cAlias)->TOTAL_FRETE
		aDados[17] := (_cAlias)->ICMS_FRETE
		aDados[18] := (_cAlias)->TOURO
		aDados[19] := (_cAlias)->BOI
		aDados[20] := (_cAlias)->VACA
		aDados[21] := (_cAlias)->GARROTE
		aDados[22] := (_cAlias)->NOVILHA
		aDados[23] := (_cAlias)->BEZERRO
		aDados[24] := (_cAlias)->BEZERRA
		aDados[25] := (_cAlias)->BUFALOS
		aDados[26] := (_cAlias)->BUFALAS
		aDados[27] := (_cAlias)->TOURO + (_cAlias)->BOI+ (_cAlias)->VACA + (_cAlias)->GARROTE + (_cAlias)->NOVILHA + (_cAlias)->BEZERRO + (_cAlias)->BEZERRA + (_cAlias)->BUFALOS  + (_cAlias)->BUFALAS 
		oSection1:PrintLine()		

		(_cAlias)->(DbSkip())	
	EndDo

	oSection1:Finish()
	oReport:IncMeter()

Return nil
 
 /*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.03.2017                                                              |
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

aAdd(aRegs,{cPerg,"01","Filial De?           ","","","mv_ch1","C",02,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Filial Ate?          ","","","mv_ch2","C",02,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Transferencia por:   ","","","mv_ch3","N",08,0,0,"C","","MV_PAR03","Emissao","","","","","Escrituracao","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Emissao de?          ","","","mv_ch4","D",08,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Emissao ate?         ","","","mv_ch5","D",08,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Livro? 	             ","","","mv_ch6","N",08,0,0,"C","","MV_PAR06","Entrada","","","","","Saida","","","","","Ambos","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Descons. CFOP (Sep ;)","","","mv_ch7","C",30,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.03.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1()
Local aArea := GetArea()
Local _cQry := ""
Private cCFOP := ""

If ValType(MV_PAR06) == 'C'
	Return .F.
EndIf

_cQry := " WITH DADOS AS ( " + CRLF

If MV_PAR06 <> 2
	_cQry += " 	SELECT  " + CRLF
	_cQry += " 	'NF_ENTR_TR'	    AS		ORIGEM, " + CRLF
	_cQry += " 	D1_FILIAL	    AS		FILIAL,  " + CRLF
	_cQry += " 	D1_DOC		    AS		NUMERO,  " + CRLF
	_cQry += " 	D1_SERIE	    AS		SERIE,  " + CRLF
	
	if MV_PAR03 == 1
		_cQry += " 	D1_EMISSAO " 
	Else
		_cQry += " 	D1_DTDIGIT " 
	EndIf
	_cQry += " 	AS EMISSAO, " + CRLF
	
	_cQry += " 	D1_QUANT	    AS		ENTRADA,  " + CRLF
	_cQry += " 	0			    AS		SAIDA,  " + CRLF
	_cQry += " 	A2_COD			AS		CODIGO, " + CRLF
	_cQry += " 	RTRIM(A2_NOME)	AS		NOME,  " + CRLF
	_cQry += " 	A2_INSCR 		AS		INSCRI_EST,  " + CRLF
	_cQry += " 	A2_MUN			AS		MUNICIPIO,  " + CRLF
	_cQry += " 	A2_EST			AS		UF,  " + CRLF
	_cQry += " 	D1_VUNIT		AS		UNITARIO, " + CRLF
	_cQry += " 	D1_TOTAL		AS		TOTAL, " + CRLF
	_cQry += " 	D1_VALICM		AS		ICMS_GADO, " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BEZERRO%'			THEN D1_QUANT END AS 'BEZERRO',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'GARROTE'		    THEN D1_QUANT END AS 'GARROTE',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'BOI'				THEN D1_QUANT END AS 'BOI',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'TOURO'			THEN D1_QUANT END AS 'TOURO',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BEZERRA%'			THEN D1_QUANT END AS 'BEZERRA',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'NOVILHA'			THEN D1_QUANT END AS 'NOVILHA',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'VACA%'			THEN D1_QUANT END AS 'VACA', " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BUFALO%'			THEN D1_QUANT END AS 'BUFALOS', " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BUFALA%'			THEN D1_QUANT END AS 'BUFALAS' " + CRLF
	_cQry += " 	FROM " + RetSqlName('SF1') + " F " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SD1') + " D ON F1_FILIAL=D1_FILIAL AND F.F1_FORNECE = D.D1_FORNECE AND F.F1_LOJA = D.D1_LOJA AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SF4') + " F4 ON D1_TES = F4_CODIGO AND F4.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SB1') + " B ON B1_FILIAL=' ' AND B1_COD=D1_COD AND B.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SA2') + " A ON A2_FILIAL=' ' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND A.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	LEFT JOIN " + RetSqlName('Z09') + " Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " + CRLF
	_cQry += " 	LEFT JOIN " + RetSqlName('SF2') + " F2 ON D1_FILIAL=F2_FILIAL AND D1_NFORI=F2_DOC AND D1_SERIORI=F2_SERIE AND F2.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	WHERE D1_FILIAL <> ' '  " + CRLF
	_cQry += " 	AND F4_TRANFIL = '1' " + CRLF
	_cQry += " 	  AND D1_GRUPO IN ('01','05','BOV','BMS')  " + CRLF
	_cQry += " 	  AND D1_TIPO <> 'C'  " + CRLF
	
	If !Empty(MV_PAR07)
		cCFOP := MV_PAR07
		cCFOP := StrTran(cCFOP, " ", "")
		cCFOP := StrTran(cCFOP, ';', "','")
		_cQry+="	AND D1_CF NOT IN ('"+cCFOP+"') "
	EndIf
	_cQry += " 	  AND F1_TIPO = 'N'  " + CRLF
	_cQry += " 	  AND ISNULL(F2_TIPO,'S') NOT IN ('B') " + CRLF
	_cQry += "  " + CRLF
	
	_cQry += " 	UNION ALL " + CRLF
	
	_cQry += " 	SELECT  " + CRLF
	_cQry += " 	'NF_ENTR_COMPRA'	    AS		ORIGEM, " + CRLF
	_cQry += " 	D1_FILIAL	    AS		FILIAL,  " + CRLF
	_cQry += " 	D1_DOC		    AS		NUMERO,  " + CRLF
	_cQry += " 	D1_SERIE	    AS		SERIE,  " + CRLF
	_cQry += " 	D1_DTDIGIT    	AS 		EMISSAO, " + CRLF
	_cQry += " 	D1_QUANT	    AS		ENTRADA,  " + CRLF
	_cQry += " 	0			    AS		SAIDA,  " + CRLF
	_cQry += " 	A2_COD			AS		CODIGO, " + CRLF
	_cQry += " 	RTRIM(A2_NOME)	AS		NOME,  " + CRLF
	_cQry += " 	A2_INSCR 		AS		INSCRI_EST,  " + CRLF
	_cQry += " 	A2_MUN			AS		MUNICIPIO,  " + CRLF
	_cQry += " 	A2_EST			AS		UF,  " + CRLF
	_cQry += " 	D1_VUNIT		AS		UNITARIO, " + CRLF
	_cQry += " 	D1_TOTAL		AS		TOTAL, " + CRLF
	_cQry += " 	D1_VALICM		AS		ICMS_GADO, " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BEZERRO%'			THEN D1_QUANT END AS 'BEZERRO',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'GARROTE'		    THEN D1_QUANT END AS 'GARROTE',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'BOI'				THEN D1_QUANT END AS 'BOI',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'TOURO'			THEN D1_QUANT END AS 'TOURO',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BEZERRA%'			THEN D1_QUANT END AS 'BEZERRA',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'NOVILHA'			THEN D1_QUANT END AS 'NOVILHA',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'VACA%'			THEN D1_QUANT END AS 'VACA', " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BUFALO%'			THEN D1_QUANT END AS 'BUFALOS', " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BUFALA%'			THEN D1_QUANT END AS 'BUFALAS' " + CRLF
	_cQry += " 	FROM " + RetSqlName('SF1') + " F " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SD1') + " D ON F1_FILIAL=D1_FILIAL AND F.F1_FORNECE = D.D1_FORNECE AND F.F1_LOJA = D.D1_LOJA AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SF4') + " F4 ON D1_TES = F4_CODIGO AND F4.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SB1') + " B ON B1_FILIAL=' ' AND B1_COD=D1_COD AND B.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SA2') + " A ON A2_FILIAL=' ' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND A.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	LEFT JOIN " + RetSqlName('Z09') + " Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " + CRLF
	_cQry += " 	LEFT JOIN " + RetSqlName('SF2') + " F2 ON D1_FILIAL=F2_FILIAL AND D1_NFORI=F2_DOC AND D1_SERIORI=F2_SERIE AND F2.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	WHERE D1_FILIAL <> ' '  " + CRLF
	_cQry += " 	AND F4_TRANFIL = '2' " + CRLF
	_cQry += " 	  AND D1_GRUPO IN ('01','05','BOV','BMS')  " + CRLF
	_cQry += " 	  AND D1_TIPO <> 'C'  " + CRLF
	_cQry += " 	  AND F1_FORMUL = 'S'  " + CRLF
	
	If !Empty(MV_PAR07)
		_cQry+="	AND D1_CF NOT IN ('"+cCFOP+"') "
	EndIf
	_cQry += " 	  AND F1_TIPO = 'N'  " + CRLF
	_cQry += " 	  AND ISNULL(F2_TIPO,'S') NOT IN ('B') " + CRLF
	_cQry += "  " + CRLF

		_cQry += " 	UNION ALL " + CRLF
	
	_cQry += " 	SELECT  " + CRLF
	_cQry += " 	'NF_ENTR_COMPRA'	    AS		ORIGEM, " + CRLF
	_cQry += " 	D1_FILIAL	    AS		FILIAL,  " + CRLF
	_cQry += " 	D1_DOC		    AS		NUMERO,  " + CRLF
	_cQry += " 	D1_SERIE	    AS		SERIE,  " + CRLF
	_cQry += " 	D1_DTDIGIT    	AS 		EMISSAO, " + CRLF
	_cQry += " 	D1_QUANT	    AS		ENTRADA,  " + CRLF
	_cQry += " 	0			    AS		SAIDA,  " + CRLF
	_cQry += " 	A2_COD			AS		CODIGO, " + CRLF
	_cQry += " 	RTRIM(A2_NOME)	AS		NOME,  " + CRLF
	_cQry += " 	A2_INSCR 		AS		INSCRI_EST,  " + CRLF
	_cQry += " 	A2_MUN			AS		MUNICIPIO,  " + CRLF
	_cQry += " 	A2_EST			AS		UF,  " + CRLF
	_cQry += " 	D1_VUNIT		AS		UNITARIO, " + CRLF
	_cQry += " 	D1_TOTAL		AS		TOTAL, " + CRLF
	_cQry += " 	D1_VALICM		AS		ICMS_GADO, " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BEZERRO%'			THEN D1_QUANT END AS 'BEZERRO',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'GARROTE'		    THEN D1_QUANT END AS 'GARROTE',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'BOI'				THEN D1_QUANT END AS 'BOI',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'TOURO'			THEN D1_QUANT END AS 'TOURO',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BEZERRA%'			THEN D1_QUANT END AS 'BEZERRA',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'NOVILHA'			THEN D1_QUANT END AS 'NOVILHA',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'VACA%'			THEN D1_QUANT END AS 'VACA', " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BUFALO%'			THEN D1_QUANT END AS 'BUFALOS', " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BUFALA%'			THEN D1_QUANT END AS 'BUFALAS' " + CRLF
	_cQry += " 	FROM " + RetSqlName('SF1') + " F " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SD1') + " D ON F1_FILIAL=D1_FILIAL AND F.F1_FORNECE = D.D1_FORNECE AND F.F1_LOJA = D.D1_LOJA AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SF4') + " F4 ON D1_TES = F4_CODIGO AND F4.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SB1') + " B ON B1_FILIAL=' ' AND B1_COD=D1_COD AND B.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SA2') + " A ON A2_FILIAL=' ' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND A.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	LEFT JOIN " + RetSqlName('Z09') + " Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " + CRLF
	_cQry += " 	LEFT JOIN " + RetSqlName('SF2') + " F2 ON D1_FILIAL=F2_FILIAL AND D1_NFORI=F2_DOC AND D1_SERIORI=F2_SERIE AND F2.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	WHERE D1_FILIAL <> ' '  " + CRLF
	_cQry += " 	AND F4_TRANFIL = '2' " + CRLF
	_cQry += " 	  AND D1_GRUPO IN ('01','05','BOV','BMS')  " + CRLF
	_cQry += " 	  AND D1_TIPO <> 'C'  " + CRLF
	_cQry += " 	  AND F1_FORMUL <> 'S'  " + CRLF
	
	If !Empty(MV_PAR07)
		_cQry+="	AND D1_CF NOT IN ('"+cCFOP+"') "
	EndIf
	_cQry += " 	  AND F1_TIPO = 'N'  " + CRLF
	_cQry += " 	  AND ISNULL(F2_TIPO,'S') NOT IN ('B') " + CRLF
	_cQry += "  " + CRLF
EndIf

If MV_PAR06 == 3
	_cQry += " 	UNION ALL " + CRLF
EndIf

If MV_PAR06 <> 1
	_cQry += "  " + CRLF
	_cQry += " 	SELECT  " + CRLF
	_cQry += " 	'NF_SAID'	   AS		ORIGEM, " + CRLF
	_cQry += " 	D2_FILIAL	   AS		FILIAL,  " + CRLF
	_cQry += " 	D2_DOC		   AS		NUMERO,  " + CRLF
	_cQry += " 	D2_SERIE	   AS		SERIE,  " + CRLF
	_cQry += " 	D2_EMISSAO	   AS		EMISSAO,  " + CRLF
	_cQry += " 	''			   AS		ENTRADA,  " + CRLF
	_cQry += " 	D2_QUANT	   AS		SAIDA, " + CRLF
	_cQry += " 	A1_COD		   AS		CODIGO,  " + CRLF
	_cQry += " 	RTRIM(A1_NOME) AS		NOME,  " + CRLF
	_cQry += " 	A1_INSCR	   AS		INSCRI_EST,  " + CRLF
	_cQry += " 	A1_MUN		   AS		MUNICIPIO,  " + CRLF
	_cQry += " 	A1_EST		   AS		UF,  " + CRLF
	_cQry += " 	D2_PRCVEN	   AS		UNITARIO, " + CRLF
	_cQry += " 	D2_TOTAL	   AS		TOTAL, " + CRLF
	_cQry += " 	D2_VALICM	   AS		ICMS_GADO, " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BEZERRO%'			THEN D2_QUANT END AS 'BEZERRO',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'GARROTE'		    THEN D2_QUANT END AS 'GARROTE',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'BOI'				THEN D2_QUANT END AS 'BOI',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'TOURO'			THEN D2_QUANT END AS 'TOURO',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BEZERRA%'			THEN D2_QUANT END AS 'BEZERRA',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)	   = 'NOVILHA'			THEN D2_QUANT END AS 'NOVILHA',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'VACA%'			THEN D2_QUANT END AS 'VACA', " + CRLF	
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BUFALO%'			THEN D2_QUANT END AS 'BUFALOS', " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BUFALA%'			THEN D2_QUANT END AS 'BUFALAS' " + CRLF
	_cQry += " 	FROM " + RetSqlName('SF2') + " F " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SD2') + " D ON F2_FILIAL=D2_FILIAL AND F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' ' AND F.F2_CLIENTE = D.D2_CLIENTE AND F.F2_LOJA = D.D2_LOJA " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SB1') + " B ON B1_FILIAL=' ' AND B1_COD=D2_COD AND B.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SA1') + " A1 ON A1_FILIAL=' ' AND D2_CLIENTE = A1.A1_COD AND D2_LOJA = A1_LOJA  " + CRLF
	_cQry += " 	LEFT JOIN " + RetSqlName('Z09') + " Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " + CRLF
	_cQry += " 	LEFT JOIN " + RetSqlName('SF1') + " F1 ON D2_FILIAL=F1_FILIAL AND D2_NFORI=F1_DOC AND D2_SERIORI=F1_SERIE AND F1.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	WHERE D2_FILIAL <> ' '  " + CRLF
	//_cQry += " 	  AND D2_EMISSAO BETWEEN '20170201' AND '20170331'  " + CRLF
	_cQry += " 	  AND D2_GRUPO IN ('01','05','BOV','BMS')  " + CRLF
	_cQry += " 	  AND D2_TIPO <> 'C'  " + CRLF
	
	If !Empty(MV_PAR07)
		cCFOP := MV_PAR07
		cCFOP := StrTran(cCFOP, " ", "")
		cCFOP := StrTran(cCFOP, ';', "','")
		
		//If SubStr(cCFOP, Len(cCFOP)-1, 4) == ",'"
			//cCFOP := "'"+SubStr(cCFOP, 1, Len(cCFOP)-2)
		//EndIf
		_cQry+="	AND D2_CF NOT IN ('"+cCFOP+"') "
	EndIf
	_cQry += " 	  AND F2_TIPO = 'N'  " + CRLF
	_cQry += " 	  AND ISNULL(F1_TIPO,'S') NOT IN ('B') " + CRLF
	_cQry += "  " + CRLF
	
	_cQry += " 	UNION ALL " + CRLF
	
	_cQry += " 	SELECT  " + CRLF
	_cQry += " 	'NF_SAID'	   AS		ORIGEM, " + CRLF
	_cQry += " 	D2_FILIAL	   AS		FILIAL,  " + CRLF
	_cQry += " 	D2_DOC		   AS		NUMERO,  " + CRLF
	_cQry += " 	D2_SERIE	   AS		SERIE,  " + CRLF
	_cQry += " 	D2_EMISSAO	   AS		EMISSAO,  " + CRLF
	_cQry += " 	''			   AS		ENTRADA,  " + CRLF
	_cQry += " 	D2_QUANT	   AS		SAIDA, " + CRLF
	_cQry += " 	A2_COD		   AS		CODIGO,  " + CRLF
	_cQry += " 	RTRIM(A2_NOME) AS		NOME,  " + CRLF
	_cQry += " 	A2_INSCR	   AS		INSCRI_EST,  " + CRLF
	_cQry += " 	A2_MUN		   AS		MUNICIPIO,  " + CRLF
	_cQry += " 	A2_EST		   AS		UF,  " + CRLF
	_cQry += " 	D2_PRCVEN	   AS		UNITARIO, " + CRLF
	_cQry += " 	D2_TOTAL	   AS		TOTAL, " + CRLF
	_cQry += " 	D2_VALICM	   AS		ICMS_GADO, " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BEZERRO%'			THEN D2_QUANT END AS 'BEZERRO',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'GARROTE'		    THEN D2_QUANT END AS 'GARROTE',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'BOI'				THEN D2_QUANT END AS 'BOI',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)    = 'TOURO'			THEN D2_QUANT END AS 'TOURO',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BEZERRA%'			THEN D2_QUANT END AS 'BEZERRA',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI)	   = 'NOVILHA'			THEN D2_QUANT END AS 'NOVILHA',  " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'VACA%'			THEN D2_QUANT END AS 'VACA', " + CRLF	
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BUFALO%'			THEN D2_QUANT END AS 'BUFALOS', " + CRLF
	_cQry += " 	CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BUFALA%'			THEN D2_QUANT END AS 'BUFALAS' " + CRLF
	_cQry += " 	FROM " + RetSqlName('SF2') + " F " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SD2') + " D ON F2_FILIAL=D2_FILIAL AND F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' ' AND F.F2_CLIENTE = D.D2_CLIENTE AND F.F2_LOJA = D.D2_LOJA " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SB1') + " B ON B1_FILIAL=' ' AND B1_COD=D2_COD AND B.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	JOIN " + RetSqlName('SA2') + " A2 ON A2_FILIAL=' ' AND D2_CLIENTE = A2.A2_COD AND D2_LOJA = A2_LOJA  " + CRLF
	_cQry += " 	LEFT JOIN " + RetSqlName('Z09') + " Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " + CRLF
	_cQry += " 	LEFT JOIN " + RetSqlName('SF1') + " F1 ON D2_FILIAL=F1_FILIAL AND D2_NFORI=F1_DOC AND D2_SERIORI=F1_SERIE AND F1.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	WHERE D2_FILIAL <> ' '  " + CRLF
	//_cQry += " 	  AND D2_EMISSAO BETWEEN '20170201' AND '20170331'  " + CRLF
	_cQry += " 	  AND D2_GRUPO IN ('01','05','BOV','BMS')  " + CRLF
	_cQry += " 	  AND D2_TIPO = 'D'  " + CRLF
	
	If !Empty(MV_PAR07)
		cCFOP := MV_PAR07
		cCFOP := StrTran(cCFOP, " ", "")
		cCFOP := StrTran(cCFOP, ';', "','")
		
		//If SubStr(cCFOP, Len(cCFOP)-1, 4) == ",'"
			//cCFOP := "'"+SubStr(cCFOP, 1, Len(cCFOP)-2)
		//EndIf
		_cQry+="	AND D2_CF NOT IN ('"+cCFOP+"') "
	EndIf

	_cQry += "  " + CRLF
EndIf

_cQry += " 	UNION ALL " + CRLF
_cQry += " " + CRLF

_cQry += "  SELECT   " + CRLF
_cQry += "   'DEVOLUCAO_VENDAS'     AS  ORIGEM,  " + CRLF
_cQry += "   D1_FILIAL     AS  FILIAL,   " + CRLF
_cQry += "   D1_DOC      AS  NUMERO,   " + CRLF
_cQry += "   D1_SERIE     AS  SERIE,   " + CRLF
_cQry += "   D1_EMISSAO     AS   EMISSAO,  " + CRLF
_cQry += "   D1_QUANT     AS  ENTRADA,   " + CRLF
_cQry += "   ''       AS  SAIDA,   " + CRLF
_cQry += "   A1_COD   AS  CODIGO,  " + CRLF
_cQry += "   RTRIM(A1_NOME) AS  NOME,   " + CRLF
_cQry += "   A1_INSCR   AS  INSCRI_EST,   " + CRLF
_cQry += "   A1_MUN   AS  MUNICIPIO,   " + CRLF
_cQry += "   A1_EST   AS  UF,   " + CRLF
_cQry += "   D1_VUNIT  AS  UNITARIO,  " + CRLF
_cQry += "   D1_TOTAL  AS  TOTAL,  " + CRLF
_cQry += "   D1_VALICM  AS  ICMS_GADO,  " + CRLF
_cQry += "   CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BEZERRO%'   THEN D1_QUANT END AS 'BEZERRO',   " + CRLF
_cQry += "   CASE WHEN RTRIM(Z09_DESCRI)    = 'GARROTE'      THEN D1_QUANT END AS 'GARROTE',   " + CRLF
_cQry += "   CASE WHEN RTRIM(Z09_DESCRI)    = 'BOI'    THEN D1_QUANT END AS 'BOI',   " + CRLF
_cQry += "   CASE WHEN RTRIM(Z09_DESCRI)    = 'TOURO'   THEN D1_QUANT END AS 'TOURO',   " + CRLF
_cQry += "   CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BEZERRA%'   THEN D1_QUANT END AS 'BEZERRA',   " + CRLF
_cQry += "   CASE WHEN RTRIM(Z09_DESCRI)    = 'NOVILHA'   THEN D1_QUANT END AS 'NOVILHA',   " + CRLF
_cQry += "   CASE WHEN RTRIM(Z09_DESCRI) LIKE 'VACA%'   THEN D1_QUANT END AS 'VACA',  " + CRLF
_cQry += "   CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BUFALO%'   THEN D1_QUANT END AS 'BUFALOS',  " + CRLF
_cQry += "   CASE WHEN RTRIM(Z09_DESCRI) LIKE 'BUFALA%'   THEN D1_QUANT END AS 'BUFALAS'  " + CRLF
_cQry += "   FROM SF1010 F  " + CRLF
_cQry += "   JOIN SD1010 D ON F1_FILIAL=D1_FILIAL AND F.F1_FORNECE = D.D1_FORNECE AND F.F1_LOJA = D.D1_LOJA AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' '  " + CRLF
_cQry += "   JOIN SF4010 F4 ON D1_TES = F4_CODIGO AND F4.D_E_L_E_T_ = ' '  " + CRLF
_cQry += "   JOIN SB1010 B ON B1_FILIAL=' ' AND B1_COD=D1_COD AND B.D_E_L_E_T_=' '  " + CRLF
_cQry += "   LEFT JOIN SA1010 A ON A1_FILIAL=' ' AND D1_FORNECE = A1_COD AND D1_LOJA = A1_LOJA AND A.D_E_L_E_T_=' '  " + CRLF
_cQry += "   LEFT JOIN Z09010 Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '    " + CRLF
_cQry += "   LEFT JOIN SF2010 F2 ON D1_FILIAL=F2_FILIAL AND D1_NFORI=F2_DOC AND D1_SERIORI=F2_SERIE AND F2.D_E_L_E_T_=' '  " + CRLF
_cQry += "   WHERE D1_FILIAL <> ' '   " + CRLF
_cQry += "   AND F4_TRANFIL = '2'     AND D1_GRUPO IN ('01','05','BOV','BMS')   " + CRLF
_cQry += "     --AND D1_TIPO <> 'C'   " + CRLF
_cQry += "    AND D1_TIPO = 'D' " + CRLF
_cQry += "  AND D1_CF NOT IN ('5623')    -- AND F1_TIPO = 'N'   " + CRLF
_cQry += "     AND ISNULL(F2_TIPO,'S') NOT IN ('B')  " + CRLF
_cQry += " " + CRLF 

_cQry += " ), " + CRLF
_cQry += "  " + CRLF
_cQry += " FRETE AS " + CRLF
_cQry += " ( " + CRLF
_cQry += " 	 SELECT FILIAL, NUMERO, SERIE, CODIGO, SUM(D1_TOTAL) TOTAL_FRETE, SUM(D1_VALICM) ICMS_FRETE  " + CRLF
_cQry += "	 FROM ( SELECT DISTINCT FILIAL, NUMERO, SERIE, CODIGO FROM DADOS )  " + CRLF
_cQry += "	     CHAVE  " + CRLF
_cQry += "	JOIN " + RetSQLName('SF8') + " F8 ON FILIAL = F8_LOJTRAN AND NUMERO = F8_NFORIG AND SERIE  = F8_SERORIG AND CODIGO = F8_FORNECE AND F8.D_E_L_E_T_=' '  " + CRLF
_cQry += " 	JOIN " + RetSQLName('SF1') + " F1 ON F1_FILIAL=F8_FILIAL AND F1_DOC=F8_NFDIFRE AND F1_SERIE=F8_SEDIFRE AND F1_FORNECE=F8_TRANSP AND F1_TIPO='C'  " + CRLF
_cQry += " 				AND F1_ESPECIE='CTE' AND F1.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	JOIN " + RetSQLName('SD1') + " D1 ON F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE  " + CRLF
_cQry += "						AND D1_TES IN ( SELECT F4_CODIGO FROM " + RetSQLName('SF4') + " WHERE F4_TEXTO LIKE '%FRETE%' ) AND D1.D_E_L_E_T_=' '  " + CRLF
_cQry += " 	GROUP BY FILIAL, NUMERO, SERIE, CODIGO " + CRLF
_cQry += " ) " + CRLF
_cQry += "  " + CRLF
_cQry += " SELECT D.*, TOTAL_FRETE, ICMS_FRETE " + CRLF
_cQry += " FROM DADOS D " + CRLF
_cQry += " LEFT JOIN FRETE F ON D.FILIAL=F.FILIAL AND D.NUMERO=F.NUMERO AND D.SERIE=F.SERIE AND D.CODIGO=F.CODIGO  " + CRLF
_cQry += "  " + CRLF
_cQry += " WHERE D.FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + CRLF
_cQry += "   AND D.EMISSAO BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' " + CRLF
_cQry += " ORDER BY FILIAL, ORIGEM, EMISSAO, NUMERO " + CRLF

If Select(_cAlias) > 0
	(_cAlias)->(DbCloseArea())
EndIf
//If cUserName == 'mbernardo'
	MemoWrite("C:\totvs_relatorios\"+cPerg+"Quadro1.sql" , _cQry)
//EndIf
dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

TcSetField(_cAlias, "EMISSAO"  , "D")

(_cAlias)->(DbEval({|| nRegistros++ }))
(_cAlias)->( DbGoTop() )

RestArea(aArea)	

Return .T.
