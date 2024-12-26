#Include "Rwmake.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Totvs.ch"
#Include "TryException.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  05.05.2017                                                              |
 | Desc:  Este fonte implementa um relatorio de Comissão; 						  |
 |		  Utilizado objeto: TReport                         					  |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VACOMM04()	// U_VACOMM04()

Local   aArea		:= GetArea()
Local oReport                 

Private nRegistros	:= 0
Private cPerg		:= "VACOMM04"
Private _cAlias		:= CriaTrab(,.F.)   

Private cTitulo 	:= "Relatório de Comissão"

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
 | Data:  05.05.2017                                                              |
 | Desc:                                                  						  |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function ReportDef()
	
	Local oReport	:= nil
	Local oSection1	:= nil, oSection2 := nil, oSection3 := nil
	Local oBreak1 	:= nil
	
	fQuadro1() // Quantidade
	
	oReport := TReport():New(cPerg+DtoS(dDataBase)/*+SubS(StrTran(Time(),":",""),1,4)*/, cTitulo, ;
					cPerg, {|oReport| PrintReport(oReport) },"Este relatorio ira listar titulos de comissões." , ;
					.T./* lLandscape */,/* uTotalText */, /* .T.  lTotalInLine */, /* cPageTText */, ;
					/* lPageTInLine */,.F. /* lTPageBreak */,/* nColSpace */)
					
	oReport:nFontBody := 8
	oReport:cFontBody := 'Arial Narrow'
	oReport:lParamPage := .F. // imprimir pagina de parametros
	
	// --------------------------------------------------------------------------------------------------------------
	oSection1 := TRSection():New(oReport, OemToAnsi(cTitulo) )//, /* uTable */,/* aOrder */,/* lLoadCells */,/* lLoadOrder */,/* uTotalText */,/* lTotalInLine */, .F. /* lHeaderPage */, .F. /* lHeaderBreak */, .F. /* lPageBreak */, .F. /* lLineBreak */, /* nLeftMargin */, /* lLineStyle */, /* nColSpace */, .T. /* lAutoSize */,/* cCharSeparator */, /* nLinesBefore */, /* nCols */, /* nClrBack */, /* nClrFore */, /* nPercentage */)
	TRCell():New(oSection1, "_PAR01" , , "Vendedor"  	  , 					   , TamSX3("E3_VEND")[1]+TamSX3("A3_NOME")[1] )
	
	// --------------------------------------------------------------------------------------------------------------
	oSection2 := TRSection():New(oSection1, OemToAnsi(cTitulo) )//, /* uTable */,/* aOrder */,/* lLoadCells */,/* lLoadOrder */,/* uTotalText */,/* lTotalInLine */, .F. /* lHeaderPage */, .F. /* lHeaderBreak */, .F. /* lPageBreak */, .F. /* lLineBreak */, /* nLeftMargin */, /* lLineStyle */, /* nColSpace */, .T. /* lAutoSize */,/* cCharSeparator */, /* nLinesBefore */, /* nCols */, /* nClrBack */, /* nClrFore */, /* nPercentage */)
	TRCell():New(oSection2, "_PAR01" , , "Filial"	      , 					   , TamSX3("E3_FILIAL")[1]  )
	TRCell():New(oSection2, "_PAR02" , , "Nota Fiscal"    , 					   , TamSX3("E3_NUM")[1] 	 )
	//TRCell():New(oSection2, "_PAR03" , , "Serie"	      , 					   , TamSX3("E3_SERIE")[1]   )
	TRCell():New(oSection2, "_PAR04" , , "Dt. Emissao"    ,                        , TamSX3("E3_EMISSAO")[1] )
	TRCell():New(oSection2, "_PAR05" , , "Produto"        , 					   , TamSX3("E3_DESCPRO")[1])
	TRCell():New(oSection2, "_PAR06" , , "Qtd. Prod."     , X3Picture("E3_QTDPROD"), TamSX3("E3_QTDPROD")[1] )
	TRCell():New(oSection2, "_PAR07" , , "Valor Prod."    , X3Picture("E3_VLRPROD"), TamSX3("E3_VLRPROD")[1] )
	TRCell():New(oSection2, "_PAR08" , , "Comissao Unit." , X3Picture("E3_COMIS")  , TamSX3("E3_COMIS")[1]   )
	TRCell():New(oSection2, "_PAR09" , , "Comissao"    	  , X3Picture("E3_COMIS")  , TamSX3("E3_COMIS")[1]   )
	TRCell():New(oSection2, "_PAR10" , , "Paga Comissao"  , 					   , TamSX3("A3_PAGACOM")[1] )
	TRCell():New(oSection2, "_PAR11" , , "Cod. Forn"      , 					   , TamSX3("A2_COD")[1] )
	TRCell():New(oSection2, "_PAR12" , , "Nome Fornece"   , 					   , TamSX3("A2_NOME")[1] )
	TRCell():New(oSection2, "_PAR13" , , "Num Pedido"     , 					   , TamSX3("C7_NUM")[1] )
	TRCell():New(oSection2, "_PAR14" , , "Peso"           , 					   , TamSX3("C7_X_PESO")[1] )
	TRCell():New(oSection2, "_PAR15" , , "Rendi Negoci"   , 					   , TamSX3("C7_X_REND")[1] )
	TRCell():New(oSection2, "_PAR16" , , "Valor @"        , 					   , TamSX3("C7_X_ARROV")[1] )
	TRCell():New(oSection2, "_PAR17" , , "Valor Comiss"   , 					   , TamSX3("C7_TOTAL")[1] )
	TRCell():New(oSection2, "_PAR18" , , "Comis Unit"     , 					   , TamSX3("C7_X_COMIS")[1] )
	TRCell():New(oSection2, "_PAR19" , , "Ped. Compra"    , 					   , TamSX3("E3_XCODPED")[1] )
	TRCell():New(oSection2, "_PAR20" , , "Fornecedor"	  , 					   , 25 /*TamSX3("A2_NOME")[1] 	 */)
	TRCell():New(oSection2, "_PAR21" , , "Dt. Pgto"       , 					   , TamSX3("E3_XDTPGTO")[1] )
	
	//TRFunction():New(oSection1:Cell("E3_COMIS")	,"Total Comis"			,"SUM",oBreak1,,PesqPict('SE3',"E3_COMIS"),,.F.,.T.)
	// --------------------------------------------------------------------------------------------------------------	
	oSection3 := TRSection():New(oSection2, OemToAnsi(cTitulo) ) //, /* uTable */,/* aOrder */,/* lLoadCells */,/* lLoadOrder */,/* uTotalText */,/* lTotalInLine */, .F. /* lHeaderPage */, .F. /* lHeaderfk */, .F. /* lPageBreak */, .F. /* lLineBreak */, /* nLeftMargin */, /* lLineStyle */, /* nColSpace */, .F. /* lAutoSize */,/* cCharSeparator */, /* nLinesBefore */, /* nCols */, /* nClrBack */, /* nClrFore */, /* nPercentage */)
	TRCell():New(oSection3, "_PAR01" , , ""     		  , , 20  )	
	TRCell():New(oSection3, "_PAR02" , , "Observação"     , , 255 )	
	
	//retirar legenda / titulo da secao
	oSection3:SetHeaderBreak(.F.) 	
	oSection3:SetHeaderPage(.F.) 	
	oSection3:SetHeaderSection(.F.) 	
	
	// --------------------------------------------------------------------------------------------------------------
	//oBreak1 := TRBreak():New(oSection1, oSection1:Cell("_PAR01") ,"",.T. , , Iif(MV_PAR09==1, .T., .F.) )  
	
Return oReport // U_VACOMM04()


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  05.05.2017                                                              |
 | Desc:                                                  						  |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function PrintReport(oReport)

	Local cVendedor	   := ""
	Local oSection1    := oReport:Section(1)
	Local oSection2    := oReport:Section(1):Section(1)
	Local oSection3    := oReport:Section(1):Section(1):Section(1)
	
	Local aDadosCom	   := Array(01)
	Local aDados 	   := Array(21)
	Local aDadosOBS    := Array(02)
	
	oReport:SetMeter(nRegistros)

	oSection1:Cell( "_PAR01" ):SetBlock( { || aDadosCom[01] } )
	
	oSection2:Cell( "_PAR01" ):SetBlock( { || aDados[01] } )
    oSection2:Cell( "_PAR02" ):SetBlock( { || aDados[02] } )
    //oSection2:Cell( "_PAR03" ):SetBlock( { || aDados[03] } )
    oSection2:Cell( "_PAR04" ):SetBlock( { || aDados[04] } )
    oSection2:Cell( "_PAR05" ):SetBlock( { || aDados[05] } )
    oSection2:Cell( "_PAR06" ):SetBlock( { || aDados[06] } )
    oSection2:Cell( "_PAR07" ):SetBlock( { || aDados[07] } )
    oSection2:Cell( "_PAR08" ):SetBlock( { || aDados[08] } )
    oSection2:Cell( "_PAR09" ):SetBlock( { || aDados[09] } )
    oSection2:Cell( "_PAR10" ):SetBlock( { || aDados[10] } )
    oSection2:Cell( "_PAR11" ):SetBlock( { || aDados[11] } )
    oSection2:Cell( "_PAR12" ):SetBlock( { || aDados[12] } )
    oSection2:Cell( "_PAR13" ):SetBlock( { || aDados[13] } )
    oSection2:Cell( "_PAR14" ):SetBlock( { || aDados[14] } ) // COD+ LOJA FORNECEDOR
    oSection2:Cell( "_PAR15" ):SetBlock( { || aDados[15] } ) // NOME FORNECEDOR 
    oSection2:Cell( "_PAR16" ):SetBlock( { || aDados[16] } ) // PEDIDO GADO
    oSection2:Cell( "_PAR17" ):SetBlock( { || aDados[17] } ) // PESO NEGOCIADO
    oSection2:Cell( "_PAR18" ):SetBlock( { || aDados[18] } ) // RENDIMENTO NEGOCIADO
    oSection2:Cell( "_PAR19" ):SetBlock( { || aDados[19] } ) // VALOR @
    oSection2:Cell( "_PAR20" ):SetBlock( { || aDados[20] } ) // VALOR COMISS NEGOCIADO
    oSection2:Cell( "_PAR21" ):SetBlock( { || aDados[21] } ) // COMISSAO UNITÁRIO
    
	oSection3:Cell( "_PAR01" ):SetBlock( { || aDadosOBS[01] } )
	oSection3:Cell( "_PAR02" ):SetBlock( { || aDadosOBS[02] } )
	
	oSection1:Init()  
	oSection2:Init()  
	oSection3:Init()  // U_VACOMM04()
	//oReport:PrintText(cTitulo)	

	While !oReport:Cancel() .And. !(_cAlias)->(Eof())
		
		If MV_PAR08 == 1 // Imprime Observação == Sim
			SE3->(DbGoTo((_cAlias)->R_E_C_N_O_))
		EndIf
		
		oReport:IncMeter()
		
		aDadosCom[01] := AllTrim((_cAlias)->E3_VEND) + '-' + AllTrim((_cAlias)->A3_NOME)
		If (cVendedor <> aDadosCom[01])
			cVendedor := aDadosCom[01]
			oSection1:PrintLine()
			oReport:SkipLine()
		EndIf
		
		aDados[01] := (_cAlias)->E3_FILIAL
        aDados[02] := AllTrim((_cAlias)->E3_NUM) + '-' + AllTrim((_cAlias)->E3_SERIE) 
        //aDados[03] := (_cAlias)->E3_SERIE
		aDados[04] := (_cAlias)->E3_EMISSAO
        aDados[05] := AllTrim((_cAlias)->E3_CODPROD) + '-' + AllTrim((_cAlias)->E3_DESCPRO)
        aDados[06] := (_cAlias)->E3_QTDPROD
        aDados[07] := (_cAlias)->E3_VLRPROD
        aDados[09] := (_cAlias)->COMIS_UNIT
        aDados[08] := (_cAlias)->E3_COMIS
        aDados[10] := Iif((_cAlias)->A3_PAGACOM=='S',"Sim", Iif( (_cAlias)->A3_PAGACOM=='N', "Não", "" ) )
        aDados[11] := AllTrim((_cAlias)->FORN) + '-' + AllTrim((_cAlias)->LOJA)
        aDados[12] := (_cAlias)->NOME
        aDados[13] := (_cAlias)->C7_NUM
        aDados[14] := (_cAlias)->C7_X_PESO
        aDados[15] := (_cAlias)->C7_X_REND
        aDados[16] := (_cAlias)->C7_X_ARROV
        aDados[17] := (_cAlias)->C7_X_COMIS
        aDados[18] := (_cAlias)->COMISUNIT
        aDados[19] := (_cAlias)->E3_XCODPED
        aDados[20] := AllTrim((_cAlias)->E3_XCODFOR) + '-' + AllTrim((_cAlias)->A2_NOME)
        aDados[21] := (_cAlias)->E3_XDTPGTO
		oSection2:PrintLine()
		
		If MV_PAR08 == 1 // Imprime Observação == Sim
			If !Empty( aDadosOBS[02] := AllTrim(SE3->E3_XOBSERV) )	// U_VACOMM04()
				aDadosOBS[01] := ""
				oSection3:PrintLine()	
				oReport:SkipLine()
			EndIf
		EndIf
		
		(_cAlias)->(DbSkip())	
	EndDo
	
	oSection1:Finish()
	oSection2:Finish()
	oSection3:Finish()

Return nil   // U_VACOMM04()


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  05.05.2017                                                              |
 | Desc:                                                  						  |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1()
Local aArea   := GetArea()
Local _cQry   := ""

	_cQry := " SELECT E3_VEND, A3_NOME, E3_FILIAL, E3_NUM, E3_SERIE, E3_XCODPED, E3_EMISSAO, E3_XCODFOR, A2.A2_NOME, E3_CODPROD, " + CRLF
	_cQry += " 	   E3_DESCPRO, E3_QTDPROD, E3_VLRPROD, E3_COMIS, E3_COMIS/E3_QTDPROD COMIS_UNIT, A3_PAGACOM, " + CRLF
	_cQry += " 	   E3_XDTPGTO, E3.R_E_C_N_O_, " + CRLF
	_cQry += " A21.A2_COD AS FORN, A21.A2_LOJA AS LOJA, A21.A2_NOME AS NOME, C7_NUM, C7_X_PESO, C7_X_REND, C7_X_ARROV, C7_X_COMIS, C7_X_COMIS/C7_QUANT AS COMISUNIT " + CRLF
	_cQry += " FROM " + RetSqlName('SE3') + " E3 " + CRLF
	_cQry += " JOIN " + RetSqlName('SA3') + " A3 ON A3_FILIAL=' ' AND A3_COD=E3_VEND AND A3.D_E_L_E_T_=' ' AND E3.D_E_L_E_T_=' ' " + CRLF
	
	_CQry += " JOIN " + RetSqlName('SD1') + " D1 ON E3_NUM = D1_DOC AND D1_SERIE = E3_SERIE AND E3_EMISSAO = D1_EMISSAO AND D1_COD = E3_CODPROD AND D1_QUANT = E3_QTDPROD AND D1.D_E_L_E_T_ = ' '  " + CRLF
	_CQry += " JOIN " + RetSqlName('SA2') + " A21 ON A21.A2_COD = D1_FORNECE AND A21.D_E_L_E_T_ = ' '  " + CRLF
	_CQry += " JOIN " + RetSqlName('SC7') + " C7 ON D1_PEDIDO = C7.C7_NUM AND D1_FILIAL = C7_FILENT AND D1_COD = C7_PRODUTO AND D1_ITEMPC = C7_ITEM AND C7.D_E_L_E_T_ = ' '  " + CRLF
	
	_cQry += " LEFT JOIN " + RetSqlName('SA2') + " A2 ON A2.A2_FILIAL=' ' AND A2.A2_COD+A2.A2_LOJA=E3_XCODFOR AND A2.D_E_L_E_T_=' ' " + CRLF
	_cQry += " WHERE  " + CRLF
	_cQry += " 		E3_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + CRLF
	_cQry += " AND E3_EMISSAO BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"' " + CRLF
	_cQry += " AND E3_VEND BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + CRLF
	//_cQry += " AND E3_PREFIXO = 'COM' " + CRLF
	
	
	If MV_PAR07 == 1
		_cQry += " AND A3_PAGACOM = 'S' "
	ElseIf MV_PAR07 == 2
		_cQry += " AND A3_PAGACOM = 'N' "
	EndIf

	_cQry += " ORDER BY E3_VEND, E3_XCODFOR, E3_FILIAL, E3_NUM, E3_SERIE " + CRLF
	
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 
	memowrite("C:\TOTVS_RELATORIOS\VACOMM04.txt", _cQry)
	TcSetField(_cAlias, "E3_EMISSAO", "D")
	TcSetField(_cAlias, "E3_XDTPGTO", "D")
	
	(_cAlias)->(DbEval({|| nRegistros++ }))
	(_cAlias)->( DbGoTop() )
	
RestArea(aArea)	
Return nil	// U_VACOMM04()


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  05.05.2017                                                              |
 | Desc:                                                  						  |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
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

AADD( aRegs, { cPerg, "01", "Filial de:          "        , "", "", "mv_ch1", TamSX3("E3_FILIAL")[3] , TamSX3("E3_FILIAL")[1] , TamSX3("E3_FILIAL")[2] , 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0", "S", "" ,"" ,"", "", {"Informe o código da filial desejada ou deixe em branco."  , "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "02", "Filial Ate:         "        , "", "", "mv_ch2", TamSX3("E3_FILIAL")[3] , TamSX3("E3_FILIAL")[1] , TamSX3("E3_FILIAL")[2] , 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0", "S", "" ,"" ,"", "", {"Informe o código da filial desejada ou deixe em branco."  , "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "03", "Dt. Emissao De:     "        , "", "", "mv_ch3", TamSX3("E3_EMISSAO")[3], TamSX3("E3_EMISSAO")[1], TamSX3("E3_EMISSAO")[2], 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", "S", "" ,"" ,"", "", {"Informe a Dt. de Emissao Inicial                       "  , "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "04", "Dt. Emissao Ate:    "        , "", "", "mv_ch4", TamSX3("E3_EMISSAO")[3], TamSX3("E3_EMISSAO")[1], TamSX3("E3_EMISSAO")[2], 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", "S", "" ,"" ,"", "", {"Informe a Dt. de Emissao Final                         "  , "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "05", "Vendedor De:        "        , "", "", "mv_ch5", TamSX3("E3_VEND")[3]   , TamSX3("E3_VEND")[1]   , TamSX3("E3_VEND")[2]   , 0, "G", "", "mv_par05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA3", "S", "" ,"" ,"", "", {"Informe o código do Vendedor desejada ou deixe em branco.", "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "06", "Vendedor: Ate:      "        , "", "", "mv_ch6", TamSX3("E3_VEND")[3]   , TamSX3("E3_VEND")[1]   , TamSX3("E3_VEND")[2]   , 0, "G", "", "mv_par06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA3", "S", "" ,"" ,"", "", {"Informe o código do Vendedor desejada ou deixe em branco.", "<F3 Disponivel>"}, {""}, {""} } )
aAdd( aRegs, { cPerg ,"07", "Paga Comissao:	     "        , "", "", "mv_ch7", "C", 1, 0, 2, 														        "C", "", "mv_par07","Sim","","","","","Não","","","","","Ambos","","","","","","","","","","","","","","","U","","","",""})
aAdd( aRegs, { cPerg ,"08", "Imprime Observação: "        , "", "", "mv_ch8", "C", 1, 0, 2, 														        "C", "", "mv_par08","Sim","","","","","Não","","","","",""     ,"","","","","","","","","","","","","","","U","","","",""})
aAdd( aRegs, { cPerg ,"09", "Imprime Vendedor por pagina:", "", "", "mv_ch9", "C", 1, 0, 2, 														        "C", "", "mv_par09","Sim","","","","","Não","","","","",""     ,"","","","","","","","","","","","","","","U","","","",""})

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

Return nil	// U_VACOMM04()