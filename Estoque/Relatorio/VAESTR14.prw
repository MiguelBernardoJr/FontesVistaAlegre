#Include "Totvs.ch"
#Include "Rwmake.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  08.02.2017                                                              |
 | Desc:  Relatorio de Lotação de Baias e Pastos.                                 |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function  VAEST14R() // U_VAEST014()                                                    
Local cTimeIni	 := Time()
Local nOpc 		 := 0
Local aRet 		 := {}
Local aCombo 	 := {"Curral", "Dt. de Abate", "Lote"}
Local aParamBox  := {}

Local cLoad      := ProcName(1) // Nome do perfil se caso for carregar
Local lCanSave   := .T. // Salvar os dados informados nos parâmetros por perfil
Local lUserSave  := .T. // Configuração por usuário

Private cTitulo  := "Relatorio Baia e Pasto"        	
Private aSay 	 := {}
Private aButton  := {}

AAdd( aSay , "Este rotina irá gerar o Relatório de Baia x Pasto, no formato Excel.")
AAdd( aSay , "")
AAdd( aSay , "Com as formas de agrupamento: 1-Curral; 2-Dt. Abate; 3-Lote;")
AAdd( aSay , "")
AAdd( aSay , "Ele esta divido nas planilhas: Tipo: 1-Currais; 2-Currais Sintetico;")
AAdd( aSay , "3-Pastos; 4-Pastos Sintetico; 5-Resumo Por Era;")
AAdd( aSay , "6-Currais Vazios; 7-Currais-Movimentação; 8-Pastos-Movimentação;")
AAdd( aSay , "")
AAdd( aSay , "Clique para continuar...")

aAdd( aButton, { 1,.T.,{|| nOpc := 1,FechaBatch()}})
aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cTitulo, aSay, aButton )

If nOpc == 1

	aAdd(aParamBox,{9 ,"Escolha uma das opções que segue: ",150,7,.T.})
	// aAdd(aParamBox,{1 ,"Matricula de:" ,Space(06),"","","SRA","",0,.F.}) // Tipo caractere
	// aAdd(aParamBox,{1 ,"Matricula Ate:" ,Space(06),"","","SRA","",0,.T.}) // Tipo caractere
	
	/* 02 */ aAdd(aParamBox,{3 ,"Agrupamento:", 1, aCombo, 50, "",.T.})
	/* 03 */ aAdd(aParamBox,{1 ,"Dias p/ Abate:", 100, "","","","",0,.T.}) // Tipo caractere
	/* 04 */ aAdd(aParamBox,{1 ,"Data Referencia:", dDataBase, "@D","","","",50,.T.}) // Tipo caractere
	/* 05 */ aAdd(aParamBox,{1 ,"Data Movimentação:", dDataBase-30, "@D","","","",50,.T.}) // Tipo caractere
	
	/* 06 */ aAdd(aParamBox,{1,"R$ @ Boi"    , 155, "@E 9,999.99","mv_par06>0","","",20,.F.}) // Tipo numérico
	/* 07 */ aAdd(aParamBox,{1,"R$ @ Garrote", 155, "@E 9,999.99","mv_par07>0","","",20,.F.}) // Tipo numérico
	/* 08 */ aAdd(aParamBox,{1,"R$ @ Bezerro", 155, "@E 9,999.99","mv_par08>0","","",20,.F.}) // Tipo numérico
	/* 09 */ aAdd(aParamBox,{1,"R$ @ Touro"  , 155, "@E 9,999.99","mv_par09>0","","",20,.F.}) // Tipo numérico
	
	/* 10 */ aAdd(aParamBox,{1,"R$ @ Vaca"   , 155, "@E 9,999.99","mv_par10>0","","",20,.F.}) // Tipo numérico
	/* 11 */ aAdd(aParamBox,{1,"R$ @ Novilha", 155, "@E 9,999.99","mv_par11>0","","",20,.F.}) // Tipo numérico
	/* 12 */ aAdd(aParamBox,{1,"R$ @ Bezerra", 155, "@E 9,999.99","mv_par12>0","","",20,.F.}) // Tipo numérico
	
	/* 13 */ aAdd(aParamBox,{1,"R$ @ Bufalo" , 155, "@E 9,999.99","mv_par13>0","","",20,.F.}) // Tipo numérico
	// VENDA
	/* 14 */ aAdd(aParamBox,{1,"R$ Venda @ Boi"    , 163, "@E 9,999.99","mv_par14>0","","",20,.F.}) // Tipo numérico
	/* 15 */ aAdd(aParamBox,{1,"R$ Venda @ Garrote", 163, "@E 9,999.99","mv_par15>0","","",20,.F.}) // Tipo numérico
	/* 16 */ aAdd(aParamBox,{1,"R$ Venda @ Bezerro", 163, "@E 9,999.99","mv_par16>0","","",20,.F.}) // Tipo numérico
	/* 17 */ aAdd(aParamBox,{1,"R$ Venda @ Touro"  , 163, "@E 9,999.99","mv_par17>0","","",20,.F.}) // Tipo numérico

	/* 18 */ aAdd(aParamBox,{1,"R$ Venda @ Vaca"   , 163, "@E 9,999.99","mv_par18>0","","",20,.F.}) // Tipo numérico
	/* 19 */ aAdd(aParamBox,{1,"R$ Venda @ Novilha", 163, "@E 9,999.99","mv_par19>0","","",20,.F.}) // Tipo numérico
	/* 20 */ aAdd(aParamBox,{1,"R$ Venda @ Bezerra", 163, "@E 9,999.99","mv_par20>0","","",20,.F.}) // Tipo numérico

	/* 21 */ aAdd(aParamBox,{1,"R$ Venda @ Bufalo" , 163, "@E 9,999.99","mv_par21>0","","",20,.F.}) // Tipo numérico

	// aAdd(aParamBox,{11,"Observação" ,"",".T.",".T.",.T.})
	// aAdd(aParamBox,{1 ,"Nome do Arquivo" ,Space(15),"@!","","","",0,.F.}) // Tipo caractere
	// http://www.blacktdn.com.br/2012/05/para-quem-precisar-desenvolver-uma.html
	If ParamBox(aParamBox,"Parâmetros...",@aRet, /* [ bOk ] */, /* [ aButtons ] */, /* [ lCentered ] */, /* [ nPosX ] */, /* [ nPosy ] */, /* [ oDlgWizard ] */,  cLoad, lCanSave, lUserSave )
		If aRet[4] > MsDate()
			Aviso("Aviso", "A data de referência informada [" + dToC(aRet[4]) + "]" + ;
						   " não pode ser maior que a data atual ["+dToC(MsDate())+"]." + CRLF + ;
						   "Data de referência atualizada para data do sistema.", {"Ok"}, 2 )
			aRet[4] := MsDate()
		EndIf
		FWMsgRun(, {|| EST014VA(aRet[2], aRet[3], aRet[4], aRet[5], aRet) }, 'Geração Relatório Baia x Pasto','Gerando excel, Por Favor Aguarde...')
	EndIF
EndIf

If cUserName == 'mbernardo'
	Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
EndIf

Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  08.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function EST014VA(nAgrup, nDiasAb, dDTReferencia, dDtMoviment, aRet )

Local aLinVazia	  := {}
Private aDadTp1   := {}
Private aDadTp4   := {}
Private aCurSint  := {}
Private aPasSint  := {}

Private cPath 	   := "C:\totvs_relatorios\"
Private cArquivo   := cPath + "VAEST014_"+; // __cUserID+"_"+;
								DtoS(dDataBase)+"_"+;
								StrTran(SubS(Time(),1,5),":","")+".xml"
Private oExcel 	   := nil

// utilizados em todo o processo
Private cAliasEST  := CriaTrab(,.F.)   
Private cAliasMOV  := CriaTrab(,.F.)   
Private aMov 	   := {}

cTitulo += " - Dt. Referência: " + DtoC(dDTReferencia)
oExcel 	:= FWMsExcel():New()
oExcel:SetFont('Arial Narrow')
oExcel:SetBgColorHeader("#37752F") // cor de fundo linha cabeçalho
oExcel:SetLineBgColor("#FFFFFF")   // cor da linha 1
oExcel:Set2LineBgColor("#FFFFFF")  // cor da linha 2
// MJ : 20.04.2018
oExcel:SetBorderTop(.T.)                                                                      
oExcel:SetAllBorders(.T.)     

If Len( Directory(cPath + "*.*","D") ) == 0
	If Makedir(cPath) == 0
		ConOut('Diretorio Criado com Sucesso.')
	Else	
		ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
	EndIf
EndIf

ConOut('Quadro 1: ' + Time())
aLinVazia := fQuadro1(nAgrup, AllTrim(Str(nDiasAb)), dToS(dDTReferencia) )

// Lista Currais - Sintetico
aCurSint := sQuadro1s(nAgrup, AllTrim(Str(nDiasAb)), dToS(dDTReferencia), aRet )

ConOut('Quadro 4: ' + Time())
fQuadro4( dToS(dDTReferencia), AllTrim(Str(nDiasAb)), nAgrup )

// Lista Pastos - Sintetico
aPasSint := sQuadro4s( dToS(dDTReferencia), AllTrim(Str(nDiasAb)), nAgrup, aRet )

// resumo por era
ConOut('Quadro 2: ' + Time())
fQuadro2( dToS(dDTReferencia), aCurSint, aPasSint )

ConOut('Quadro 3: ' + Time())
fQuadro3(aLinVazia)

ConOut('Quadro 5: ' + Time())
fQuadro5(nAgrup, AllTrim(Str(nDiasAb)), dToS(dDTReferencia), dToS(dDtMoviment) )

ConOut('Quadro 6: ' + Time())
fQuadro6( dToS(dDTReferencia), dToS(dDtMoviment), AllTrim(Str(nDiasAb))  )

ConOut('Activate: ' + Time())
oExcel:Activate()                                                
oExcel:GetXMLFile( cArquivo )

If ApOleClient("MSExcel")
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open( cArquivo )
	oExcelApp:SetVisible(.T.) 	
	oExcelApp:Destroy()	
	// ou >  ShellExecute( "Open", cNameFile , '', '', 1 ) //Abre o arquivo na tela após salvar 
Else
	MsgAlert("O Excel não foi encontrado. Arquivo " + cArquivo + " gerado em " + cPath + ".", "MsExcel não encontrado" )
EndIf

(cAliasEST)->(DbCloseArea())
(cAliasMOV)->(DbCloseArea())
ConOut('FIM: ' + Time())

Return Nil


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  06.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1(nAgrup, cDiasAb, dDTReferencia)

Local _cQry      := ""
Local cWorkSheet := "Lista Currais"

Local aDados 	 := Array(21)
Local aDadosA 	 := Array(21)
Local cAgrupa    := ""

Local nQATU		 := 0

Local aLinVazia  := {}

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)

_cQry := " WITH SALDO_ATUAL AS ( " + CRLF
_cQry += " 	SELECT B2_FILIAL, B2_COD, B2_LOCAL, '' B8_LOTECTL, B1_X_CURRA, B1_XANIMAL, B1_XANIITE, B1_X_ERA, B1_XLOTE, " + CRLF
_cQry += " 			CASE B1_RASTRO WHEN 'L' THEN 'L' ELSE 'N' END B1_RASTRO, " + CRLF
_cQry += " 			B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO, B1_XDATACO, " + CRLF
_cQry += " 			100 AS DiasAbate, " + CRLF
_cQry += "  			CASE B1_XDATACO " + CRLF
_cQry += "   				WHEN ' ' THEN 0 " + CRLF
_cQry += "   				ELSE DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '" + dDTReferencia + "', 103)) " + CRLF
_cQry += "   			END AS Dias, " + CRLF
_cQry += "   			CASE B1_XDATACO " + CRLF
_cQry += "   				WHEN ' ' THEN ' ' " + CRLF
_cQry += "   				ELSE CONVERT( VARCHAR, CONVERT(DATETIME, B1_XDATACO, 103)+"+cDiasAb+", 112) " + CRLF
_cQry += "   			END PrjecAba, " + CRLF
_cQry += " 			SUM(B2_QATU) B2_QATU, A2_NOME " + CRLF
_cQry += " 	FROM " + RetSqlName('SB1') + "  B1 " + CRLF
_cQry += " 	JOIN " + RetSqlName('SB2') + " B2 ON B1_FILIAL=' ' AND B2_FILIAL='"+xFilial('SB2')+"' AND B1_COD=B2_COD AND B1.D_E_L_E_T_= ' ' AND B2.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	LEFT JOIN SC7010 C7 ON C7_FILIAL+C7_NUM = B1_XLOTCOM AND C7_PRODUTO=B2_COD AND B1.D_E_L_E_T_=' ' AND C7.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	LEFT JOIN SA2010 A2 ON A2_FILIAL=' ' AND A2_COD=C7_FORNECE AND A2_LOJA=C7_LOJA AND A2.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	WHERE B1_GRUPO IN ('BOV','01') " + CRLF
_cQry += " 	GROUP BY B2_FILIAL, B2_COD, B2_LOCAL, B1_RASTRO, B1_X_CURRA, B1_XANIMAL, B1_XANIITE, B1_X_ERA, B1_XLOTE, B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO, B1_XDATACO, A2_NOME " + CRLF
_cQry += " ), " + CRLF
_cQry += " " + CRLF
_cQry += " SALDO_LOTE AS ( " + CRLF
_cQry += " 	SELECT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, 'L' B1_RASTRO, " + CRLF
_cQry += " 			B8_XPESOCO, B8_GMD, B8_XRENESP, " + CRLF
_cQry += " 			B8_DIASCO DiasAbate, B8_XDATACO, " + CRLF
_cQry += "     			CASE B8_XDATACO   " + CRLF
_cQry += " 				WHEN ' ' THEN 0   " + CRLF
_cQry += " 				ELSE DATEDIFF(DAY, CONVERT(DATETIME, B8_XDATACO, 103), CONVERT(DATETIME, '" + dDTReferencia + "', 103))    " + CRLF
_cQry += " 			END AS Dias,  " + CRLF
_cQry += " 			CASE B8_XDATACO   " + CRLF
_cQry += " 				WHEN ' ' THEN ' '   " + CRLF
_cQry += " 				ELSE CONVERT( VARCHAR, CONVERT(DATETIME, B8_XDATACO, 103)+B8_DIASCO, 112)   " + CRLF
_cQry += "          END PrjecAba,  " + CRLF
_cQry += " 			SUM(B8_SALDO) B8_SALDO, A2_NOME " + CRLF
_cQry += " 	FROM " + RetSqlName('SB1') + "  B1 " + CRLF
_cQry += " 	JOIN " + RetSqlName('SB8') + "  B8 ON B1_FILIAL='"+xFilial('SB1')+"' AND B8_FILIAL='"+xFilial('SB8')+"' AND B1_COD=B8_PRODUTO AND B1.D_E_L_E_T_= ' ' AND B8.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	LEFT JOIN SC7010 C7 ON C7_FILIAL+C7_NUM = B1_XLOTCOM AND C7_PRODUTO=B8_PRODUTO AND B1.D_E_L_E_T_=' ' AND C7.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	LEFT JOIN SA2010 A2 ON A2_FILIAL=' ' AND A2_COD=C7_FORNECE AND A2_LOJA=C7_LOJA AND A2.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	WHERE B1_GRUPO IN ('BOV','01') " + CRLF
_cQry += " 	GROUP BY B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B1_RASTRO, B8_XPESOCO, B8_GMD, " + CRLF
_cQry += " 	 		 B8_XRENESP, B8_DIASCO, B8_XDATACO, A2_NOME " + CRLF
_cQry += " ), " + CRLF
_cQry += " " + CRLF
_cQry += " CURRAL AS ( " + CRLF
_cQry += " 		SELECT DISTINCT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_X_CURRA, D_E_L_E_T_ " + CRLF
_cQry += " 		FROM " + RetSqlName('SB8') + CRLF
_cQry += " 		WHERE B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL IN ( SELECT DISTINCT B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL FROM SALDO_LOTE ) " + CRLF
_cQry += " 		  AND B8_X_CURRA<>' ' " + CRLF
_cQry += " 		  AND B8_SALDO > 0 " + CRLF
_cQry += " ) " + CRLF
_cQry += " " + CRLF
_cQry += " SELECT CASE ISNULL(Z08_TIPO,'*') WHEN '*' THEN 'SEM CLASSIFICAÇÃO' ELSE Z08_TIPO END Z08_TIPO, " + CRLF
_cQry += " 		ISNULL(L.B1_RASTRO,A.B1_RASTRO) B1_RASTRO, " + CRLF
_cQry += " 		ISNULL(Z08_TIPO+RTRIM(Z08_LINHA)+Z08_SEQUEN,9999) ORDEM, " + CRLF
_cQry += " 		B2_COD, B2_LOCAL, " + CRLF
_cQry += " 		ISNULL(C.B8_X_CURRA, B1_X_CURRA) B1_X_CURRA, " + CRLF
_cQry += " 		ISNULL(L.B8_LOTECTL, A.B1_XLOTE) B1_XLOTE, " + CRLF
_cQry += " 		CASE B1_X_ERA WHEN ' ' THEN 'SEM CLASSIFICAÇÃO' ELSE B1_X_ERA END B1_X_ERA, " + CRLF
_cQry += " 		ISNULL(B8_SALDO,0) B2_QATU, " + CRLF
_cQry += " 		ISNULL(L.B8_XPESOCO, A.B1_XPESOCO) B1_XPESOCO, " + CRLF
_cQry += " 		B1_XLOTCOM, B1_XRACA, B1_X_SEXO, " + CRLF
_cQry += " 		CASE B8_GMD WHEN 0 THEN Z09_GMDESP ELSE B8_GMD END Z09_GMDESP, " + CRLF
_cQry += " 		ISNULL(L.B8_XDATACO, A.B1_XDATACO) B1_XDATACO, " + CRLF
_cQry += " 		CASE L.DiasAbate WHEN 0 THEN A.DiasAbate ELSE L.DiasAbate END DiasAbate,  " + CRLF
_cQry += " 		ISNULL(L.Dias, A.Dias) Dias,  " + CRLF
_cQry += " 		CASE ISNULL(L.B8_XPESOCO, A.B1_XPESOCO) " + CRLF
_cQry += "   			WHEN 0 THEN 0 " + CRLF
_cQry += "   			ELSE (DATEDIFF(DAY, CONVERT(DATETIME, ISNULL(L.B8_XDATACO, A.B1_XDATACO), 103), CONVERT(DATETIME, '" + dDTReferencia + "', 103))*(CASE B8_GMD WHEN 0 THEN Z09_GMDESP ELSE B8_GMD END))+ISNULL(L.B8_XPESOCO, A.B1_XPESOCO) " + CRLF
_cQry += "   		END PesoAtual, " + CRLF
_cQry += " 		ISNULL(L.PrjecAba, A.PrjecAba) PrjecAba, " + CRLF
_cQry += " 		CASE B8_XRENESP WHEN 0 THEN Z09_RENESP ELSE B8_XRENESP END Z09_RENESP, " + CRLF
_cQry += "   		CASE ISNULL(L.B8_XPESOCO, A.B1_XPESOCO) " + CRLF
_cQry += "   		  WHEN 0 THEN 0 " + CRLF
_cQry += "   		  ELSE (DATEDIFF(DAY, CONVERT(DATETIME, ISNULL(L.B8_XDATACO, A.B1_XDATACO), 103), (CONVERT(DATETIME, ISNULL(L.B8_XDATACO, A.B1_XDATACO), 103)+"+cDiasAb+"))*(CASE B8_GMD WHEN 0 THEN Z09_GMDESP ELSE B8_GMD END))+ISNULL(L.B8_XPESOCO, A.B1_XPESOCO) " + CRLF
_cQry += "   		END PesoFinal, " + CRLF
_cQry += "   		CASE ISNULL(L.B8_XPESOCO, A.B1_XPESOCO) " + CRLF
_cQry += "   		  WHEN 0 THEN 0 " + CRLF
_cQry += "   		  ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, ISNULL(L.B8_XDATACO, A.B1_XDATACO), 103), (CONVERT(DATETIME, ISNULL(L.B8_XDATACO, A.B1_XDATACO), 103)+"+cDiasAb+"))*(CASE B8_GMD WHEN 0 THEN Z09_GMDESP ELSE B8_GMD END))+ISNULL(L.B8_XPESOCO, A.B1_XPESOCO)) * ISNULL(B8_SALDO,0) " + CRLF
_cQry += "   		END PesoFinalTOTAL, " + CRLF
_cQry += "   		CASE ISNULL(L.B8_XPESOCO, A.B1_XPESOCO) " + CRLF
_cQry += "   		  WHEN 0 THEN 0 " + CRLF
_cQry += "   		  ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, ISNULL(L.B8_XDATACO, A.B1_XDATACO), 103), (CONVERT(DATETIME, ISNULL(L.B8_XDATACO, A.B1_XDATACO), 103)+"+cDiasAb+"))*(CASE B8_GMD WHEN 0 THEN Z09_GMDESP ELSE B8_GMD END))+ISNULL(L.B8_XPESOCO, A.B1_XPESOCO))*( (CASE B8_XRENESP WHEN 0 THEN Z09_RENESP ELSE B8_XRENESP END) /100) " + CRLF
_cQry += "   		END PesoCarcacaFinal, ISNULL(L.A2_NOME, A.A2_NOME) A2_NOME, " + CRLF
_cQry += " 		SubString(ISNULL(L.PrjecAba, A.PrjecAba),1,6) GRUPO2 " + CRLF
_cQry += " " + CRLF
_cQry += " FROM	 SALDO_ATUAL A " + CRLF
_cQry += " LEFT JOIN SALDO_LOTE L ON B2_FILIAL=B8_FILIAL AND B2_COD=B8_PRODUTO AND B2_LOCAL=B8_LOCAL " + CRLF
_cQry += " LEFT JOIN CURRAL     C ON L.B8_FILIAL=C.B8_FILIAL AND L.B8_PRODUTO=C.B8_PRODUTO AND L.B8_LOCAL=C.B8_LOCAL AND L.B8_LOTECTL=C.B8_LOTECTL AND C.D_E_L_E_T_=' ' " + CRLF
_cQry += " LEFT JOIN " + RetSqlName('Z08') + " Z8 ON Z08_FILIAL='"+xFilial('Z08')+"' AND RTRIM(UPPER(Z08_CODIGO))=RTRIM(UPPER(ISNULL(C.B8_X_CURRA, A.B1_X_CURRA))) AND Z8.D_E_L_E_T_=' ' " + CRLF
_cQry += " LEFT JOIN " + RetSqlName('Z09') + " Z9 ON Z09_FILIAL='"+xFilial('Z09')+"' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' ' " + CRLF
_cQry += " " + CRLF
_cQry += " ORDER BY " + CRLF
_cQry += " Z08_TIPO, " + CRLF

If nAgrup == 2
	_cQry += " PrjecAba, " + CRLF
EndIf
	
_cQry += " ORDEM, " + CRLF
_cQry += " B1_X_ERA, B2_COD, B2_LOCAL, " + CRLF
_cQry += " B1_X_CURRA, " + CRLF
_cQry += " B2_QATU DESC " + CRLF

	// _cQry := ChangeQuery(_cQry)

	// nao fechar alias, pois usarei ele no proximo quadro
	// If Select(cAlias) > 0
		// (cAlias)->(DbCloseArea())
	// EndIf
	If cUserName == 'mbernardo'
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro1.sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliasEST),.F.,.F.) 
	
	TcSetField(cAliasEST, "B1_XDATACO", "D")
	TcSetField(cAliasEST, "PrjecAba"  , "D")
	
	If !(cAliasEST)->(Eof())
		//Adiciona uma coluna a tabela de uma Worksheet.
		// AddColumn( cWorkSheet, cTable, < cColumn > , nAlign, nFormat, lTotal)
		//nAlign > Alinhamento da coluna ( 1-Left,2-Center,3-Right )
		//nFormat > Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
		//lTotal > Indica se a coluna deve ser totalizada
		/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Produto"		     	, 1, 1 )
		/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Linha" 		     	, 1, 1 )
		/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"			 	, 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Entrada"		     	, 1, 1 )
		/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Era"			     	, 1, 1 )
		/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde " + SubS(dToC(sToD(dDTReferencia)),1,5), 1, 1 )
		/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Média (Kg)" 	     	, 1, 1 )
		/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Origem" 		     	, 1, 1 )
		/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Raça" 			 	, 1, 1 )
		/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Sexo" 			 	, 1, 1 )
		/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dias"			 	, 1, 1 )
		/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "GMD" 			 	, 1, 1 )
		/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Atual(Kg)"	 	, 1, 1 )
		/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dias Abate"		 	, 1, 1 )
		/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Abate"   	 	, 1, 1 )
		/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Rend. Esperado"	 	, 1, 1 )
		/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Final" 	     	, 1, 2 )
		/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Final Total"	, 1, 2 )
		/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Final Carcaça"	, 1, 2 )
		/* 20 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Fornecedor"			, 1, 1 )
		/* 21 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observação"			, 1, 1 )
		
		aDados[02]  := 0
		aDados[06]  := 0
		aDados[18]  := 0
		aDadosA[02] := 0
		aDadosA[06] := 0
		aDadosA[18] := 0
		
		If nAgrup == 2
			cAgrupa := (cAliasEST)->GRUPO2
		ElseIf nAgrup == 3
			cAgrupa	:= (cAliasEST)->ORDEM
		EndIf
		
		// aSaldos := CalcEst( "BOV000000000003", "01" , StoD("20170101")  )		
		While !(cAliasEST)->(Eof())
			
			If (cAliasEST)->Z08_TIPO <> '4' .and. (cAliasEST)->ORDEM <> '9999'
			
				If nAgrup == 2
					If cAgrupa <> (cAliasEST)->GRUPO2 .and. aDadosA[06] <> 0
						oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDadosA) )
						oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
						oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
						
						aDadosA[02] := 0
						aDadosA[06] := 0
						aDadosA[18] := 0
					EndIf
					
				ElseIf nAgrup == 3
					If cAgrupa <> (cAliasEST)->ORDEM .and. aDadosA[06] <> 0
						oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDadosA) )
						oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
						oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
						
						aDadosA[02] := 0
						aDadosA[06] := 0
						aDadosA[18] := 0
					EndIf
				EndIf
				
				// http://www.helpfacil.com/forum/display_topic_threads.asp?ForumID=1&TopicID=28421&PagePosition=1
				// CalcEstL(cProduto, cAlmox, dData, cLote, cSubLote, cEnder, cSerie, lRastro) 
				
				nQATU := Iif(dDTReferencia == dToS(dDataBase), (cAliasEST)->B2_QATU, CalcEstL( (cAliasEST)->B2_COD, (cAliasEST)->B2_LOCAL, sToD(dDTReferencia)+1, (cAliasEST)->B1_XLOTE)[1] )
				If nQATU == 0
					// guardar no vetor de listas vazias  
					if aScan(aLinVazia, { |x| AllTrim(x[1]) == AllTrim((cAliasEST)->B1_X_CURRA) } ) == 0 ;
						.AND. (cAliasEST)->ORDEM<>'9999'
						aAdd( aLinVazia, { (cAliasEST)->B1_X_CURRA, .T.} )
					EndIf
				else
					
					If ( nPosLV := aScan(aLinVazia, { |x| AllTrim(x[1]) == AllTrim((cAliasEST)->B1_X_CURRA) } ) ) > 0
						aLinVazia[nPosLV,2] := .F.
					EndIf

					oExcel:AddRow( cWorkSheet, cTitulo, ;
									{ (cAliasEST)->B2_COD, ;
									  (cAliasEST)->B1_X_CURRA, ;
									  (cAliasEST)->B1_XLOTE, ;
									  (cAliasEST)->B1_XDATACO, ;
									  (cAliasEST)->B1_X_ERA, ;
									  nQATU , ;
									  (cAliasEST)->B1_XPESOCO, ;
									  (cAliasEST)->B1_XLOTCOM, ;
									  (cAliasEST)->B1_XRACA, ;
									  (cAliasEST)->B1_X_SEXO, ;
									  (cAliasEST)->Dias, ;
									  (cAliasEST)->Z09_GMDESP, ;
									  (cAliasEST)->PesoAtual, ;
									  (cAliasEST)->DiasAbate, ;
									  (cAliasEST)->PrjecAba, ;
									  (cAliasEST)->Z09_RENESP, ;
									  (cAliasEST)->PesoFinal, ;
									  (cAliasEST)->PesoFinalTOTAL, ;
									  (cAliasEST)->PesoCarcacaFinal, ;
									  (cAliasEST)->A2_NOME, ;
									  PegaOBSB8((cAliasEST)->B2_COD) } )
									  
					aAdd( aDadTp1, { (cAliasEST)->B2_COD, ;
									  (cAliasEST)->B1_X_CURRA, ;
									  (cAliasEST)->B1_XLOTE, ;
									  (cAliasEST)->B1_XDATACO, ;
									  (cAliasEST)->B1_X_ERA, ;
									  nQATU , ;
									  (cAliasEST)->B1_XPESOCO, ;
									  (cAliasEST)->B1_XLOTCOM, ;
									  (cAliasEST)->B1_XRACA, ;
									  (cAliasEST)->B1_X_SEXO, ;
									  (cAliasEST)->Dias, ;
									  (cAliasEST)->Z09_GMDESP, ;
									  (cAliasEST)->PesoAtual, ;
									  (cAliasEST)->DiasAbate, ;
									  (cAliasEST)->PrjecAba, ;
									  (cAliasEST)->Z09_RENESP, ;
									  (cAliasEST)->PesoFinal, ;
									  (cAliasEST)->PesoFinalTOTAL, ;
									  (cAliasEST)->PesoCarcacaFinal } )
									  
					If nAgrup == 2
						cAgrupa := (cAliasEST)->GRUPO2
						
						aDadosA[02] += 1		           // Curral : Qtde de registros
						aDadosA[06] += nQATU // Qtde
						aDadosA[18] += (cAliasEST)->PesoFinalTOTAL // Qtde
					
					ElseIf nAgrup == 3
						cAgrupa := (cAliasEST)->ORDEM
						
						aDadosA[02] += 1		           // Curral : Qtde de registros
						aDadosA[06] += nQATU // Qtde
						aDadosA[18] += (cAliasEST)->PesoFinalTOTAL // Qtde
					EndIf

					aDados[02] += 1		           // Curral : Qtde de registros
					aDados[06] += nQATU // Qtde
					aDados[18] += (cAliasEST)->PesoFinalTOTAL // Qtde
					
				EndIf
			EndIf
			
			(cAliasEST)->(DbSkip())
		EndDo

		oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDadosA) )

		oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, aDados )
		
	EndIf
	
	// (cAlias)->(DbCloseArea()) // nao fechar alias, pois usarei ele no proximo quadro
	
Return aLinVazia


/* MJ : 04.04.2018
	# Processamento do quadro 1 - sintetico 
*/
Static Function sQuadro1s(nAgrup, cDiasAb, dDTReferencia, aRet)

Local cWorkSheet := "Currais - Sintetico"
Local aDados 	 := Array(26)
Local aDadosA 	 := Array(26)
Local aDadSint	 := Array(26)
Local aDadCont	 := {}
Local cLinha     := ""
Local cEra    	 := ""

Local nQATU		 := 0, nI := 1
Local nRSPadArb	 := GetMV('VA_VLRAROB',,155), nVlrArrob := 0
Local nVndPadArb := GetMV('VA_AROBBND',,163), nArrobVnd := 0
Local nPesCarc	 := 0, nVlrTotEst := 0

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)
	
	TcSetField(cAliasEST, "B1_XDATACO", "D")
	TcSetField(cAliasEST, "PrjecAba"  , "D")
	
	(cAliasEST)->(DbGoTop())
	If !(cAliasEST)->(Eof())
		//Adiciona uma coluna a tabela de uma Worksheet.
		// AddColumn( cWorkSheet, cTable, < cColumn > , nAlign, nFormat, lTotal)
		//nAlign > Alinhamento da coluna ( 1-Left,2-Center,3-Right )
		//nFormat > Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
		//lTotal > Indica se a coluna deve ser totalizada
		/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Linha" 		     	   	, 1, 1 )
		/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"			 	   	, 1, 1 )
		/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Entrada"		     	   	, 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Era"			     	   	, 1, 1 )
		/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde " + SubS(dToC(sToD(dDTReferencia)),1,5), 1, 1 )
		/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Média (Kg)" 	     	   	, 1, 2 )
		/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Origem" 		     	   	, 1, 1 )
		/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Raça" 			 	   	, 1, 1 )
		/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Sexo" 			 	   	, 1, 1 )
		/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dias"			 	   	, 1, 1 )
		/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "GMD" 			 	   	, 1, 1 )
		/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Atual(Kg)"	 	   	, 1, 2 )
	
		/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor @ Estoque"	 	   	, 1, 3 )
		/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Carcaça"	 	   	, 1, 2 )
		/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "R$ Total Estoque" 	   	, 1, 3 )
	
		/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dias Abate"		 	   	, 1, 1 )
		/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Abate"   	 	   	, 1, 1 )
		/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Rend. Esperado"	 	   	, 1, 1 )
		/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Final" 	     	   	, 1, 2 )
		/* 20 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Final Total"	   	, 1, 2 )
		/* 21 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Final Carcaça"	   	, 1, 2 )

		/* 22 */ oExcel:AddColumn( cWorkSheet, cTitulo, "R$ Venda @"		   		, 1, 3 )	
		/* 23 */ oExcel:AddColumn( cWorkSheet, cTitulo, "R$ Total Venda Final"	, 1, 3 )	
		
		/* 24 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Fornecedor"			    , 1, 1 )
		/* 25 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observação"			    , 1, 1 )
		/* 26 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Produto"		     	    , 1, 1 )
		
		// aDados[01]  := 0
		aDados[05]  := 0
		aDados[15]  := 0
		aDados[20]  := 0
		aDados[23]  := 0
		// aDadosA[01] := 0
		aDadosA[05] := 0
		aDadosA[15] := 0
		aDadosA[20] := 0
		aDadosA[23] := 0

		// cLinha	:= (cAliasEST)->ORDEM
		cLinha	:= ""
		cEra	:= ""
		aDadSint := {}		
		
		// proccessando dados - agrupando informacoes
		While !(cAliasEST)->(Eof())
			If (cAliasEST)->Z08_TIPO <> '4' .and. (cAliasEST)->ORDEM <> '9999'
				nQATU := Iif(dDTReferencia == dToS(dDataBase), (cAliasEST)->B2_QATU, CalcEstL( (cAliasEST)->B2_COD, (cAliasEST)->B2_LOCAL, sToD(dDTReferencia)+1, (cAliasEST)->B1_XLOTE)[1] )
				If nQATU <> 0
			
					If cLinha <> (cAliasEST)->ORDEM .or. cEra <> (cAliasEST)->B1_X_ERA 
						aAdd( aDadSint		 , {} 								)  
						aAdd( aTail(aDadSint), (cAliasEST)->B1_X_CURRA          )  // 01
						aAdd( aTail(aDadSint), (cAliasEST)->B1_XLOTE            )  // 02
						aAdd( aTail(aDadSint), (cAliasEST)->B1_XDATACO          )  // 03
						aAdd( aTail(aDadSint), (cAliasEST)->B1_X_ERA            )  // 04
						aAdd( aTail(aDadSint), nQATU                            )  // 05
						aAdd( aTail(aDadSint), (cAliasEST)->B1_XPESOCO          )  // 06
						aAdd( aTail(aDadSint), (cAliasEST)->B1_XLOTCOM          )  // 07
						aAdd( aTail(aDadSint), (cAliasEST)->B1_XRACA            )  // 08
						aAdd( aTail(aDadSint), (cAliasEST)->B1_X_SEXO           )  // 09
						aAdd( aTail(aDadSint), (cAliasEST)->Dias                )  // 10 
						aAdd( aTail(aDadSint), (cAliasEST)->Z09_GMDESP          )  // 11
						aAdd( aTail(aDadSint), (cAliasEST)->PesoAtual           )  // 12
						
						aAdd( aTail(aDadSint), 0			            		)  // 13
						aAdd( aTail(aDadSint), 0 								)  // 14
						aAdd( aTail(aDadSint), 0 								)  // 15
						
						aAdd( aTail(aDadSint), (cAliasEST)->DiasAbate           )  // 16
						aAdd( aTail(aDadSint), (cAliasEST)->PrjecAba            )  // 17
						aAdd( aTail(aDadSint), (cAliasEST)->Z09_RENESP          )  // 18
						aAdd( aTail(aDadSint), (cAliasEST)->PesoFinal           )  // 19
						aAdd( aTail(aDadSint), (cAliasEST)->PesoFinalTOTAL      )  // 20
						aAdd( aTail(aDadSint), (cAliasEST)->PesoCarcacaFinal    )  // 21
						
						aAdd( aTail(aDadSint), 0					            )  // 22
						aAdd( aTail(aDadSint), 0 								)  // 23
						
						aAdd( aTail(aDadSint), AllTrim( (cAliasEST)->A2_NOME )  )  // 24
						aAdd( aTail(aDadSint), AllTrim( PegaOBSB8((cAliasEST)->B2_COD) ) )  // 25
						aAdd( aTail(aDadSint), AllTrim( (cAliasEST)->B2_COD	)	)  // 26
						
						// Contador - Agrupamento - Media
						aAdd( aDadCont, 1 )
						 
					Else
					
						aDadCont[len(aDadCont)] += 1
					
						// "Qtde "
						aDadSint[ len(aDadCont), 5] += nQATU
						// "Média (Kg)" 	     	
						aDadSint[ len(aDadCont), 6] += (cAliasEST)->B1_XPESOCO
						// "Origem" 
						If Empty(aDadSint[ len(aDadCont), 7])
							aDadSint[ len(aDadCont), 7] := (cAliasEST)->B1_XLOTCOM
						EndIf
						// "Peso Atual(Kg)"	 	
						aDadSint[ len(aDadCont), 12] += (cAliasEST)->PesoAtual
						
						// "Peso Final Total"	
						aDadSint[ len(aDadCont), 20] += (cAliasEST)->PesoFinalTOTAL
						// "Peso Final Carcaça"	
						aDadSint[len(aDadCont),21] += (cAliasEST)->PesoCarcacaFinal
						
						// "Fornecedor"			
						xAux := AllTrim( (cAliasEST)->A2_NOME )
						If !( xAux $ aDadSint[len(aDadCont),24] ) 
							aDadSint[len(aDadCont),24] += Iif(Empty(aDadSint[len(aDadCont),24]), "", Iif(Empty(xAux), "", " | ")) + xAux
						EndIf
						// "Observação"
						xAux := AllTrim( PegaOBSB8((cAliasEST)->B2_COD) )
						If !( xAux $ aDadSint[len(aDadCont),25] )
							aDadSint[len(aDadCont),25] += Iif(Empty(aDadSint[len(aDadCont),25]), "", Iif(Empty(xAux), "", " | ")) + xAux
						EndIf						
						// "Produto"	
						aDadSint[ len(aDadCont), 26] += Iif(Empty(aDadSint[len(aDadCont), 26]), "", " | ") + AllTrim( (cAliasEST)->B2_COD )
					EndIf
					cLinha := (cAliasEST)->ORDEM 
					cEra   := (cAliasEST)->B1_X_ERA
				EndIf
			EndIf
			
			(cAliasEST)->(DbSkip())
		EndDo
		
		nI 		:= 1
		While nI <= Len( aDadSint )
			
			DO CASE
				CASE "BOI" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[06]
					nArrobVnd := aRet[14]
				CASE "GARROTE" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[07]
					nArrobVnd := aRet[15]
				CASE "BEZERRO" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[08]
					nArrobVnd := aRet[16]
				CASE "TOURO" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[09]
					nArrobVnd := aRet[17]
				CASE "VACA" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[10]
					nArrobVnd := aRet[18]
				CASE "NOVILHA" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[11]
					nArrobVnd := aRet[19]
				CASE "BEZERRA" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[12]
					nArrobVnd := aRet[20]
				CASE "BUFAL" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[13]
					nArrobVnd := aRet[21]
				OTHERWISE
					nVlrArrob := nRSPadArb
					nArrobVnd := nVndPadArb
			ENDCASE
			
			aDadSint[ nI, 13]	:= nVlrArrob
			
			nPesCarc := (aDadSint[ nI, 12]/aDadCont[nI]) * (aDadSint[ nI, 18] / 100)
			aDadSint[ nI, 14]	:= nPesCarc
			
			nVlrTotEst := (nPesCarc/15) * nVlrArrob * aDadSint[ nI, 05 ]
			aDadSint[ nI, 15]	:= nVlrTotEst
			
			aDadSint[ nI, 22]	:= nArrobVnd
			
			aDadSint[ nI, 23]	:= ((aDadSint[ nI, 21]/aDadCont[nI])/15)*nArrobVnd*aDadSint[ nI, 05 ]
		
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ aDadSint[ nI, 01] ,;
							  aDadSint[ nI, 02] ,;
							  aDadSint[ nI, 03] ,;
							  aDadSint[ nI, 04] ,;
							  aDadSint[ nI, 05] ,;
							  aDadSint[ nI, 06] / aDadCont[nI] ,;
							  aDadSint[ nI, 07] ,;
							  aDadSint[ nI, 08] ,;
							  aDadSint[ nI, 09] ,;
							  aDadSint[ nI, 10] ,;
							  aDadSint[ nI, 11] ,;
							  aDadSint[ nI, 12] / aDadCont[nI] ,;
							  aDadSint[ nI, 13] ,;
							  aDadSint[ nI, 14] ,;
							  aDadSint[ nI, 15] ,;
							  aDadSint[ nI, 16] ,;
							  aDadSint[ nI, 17] ,;
							  aDadSint[ nI, 18] ,;
							  aDadSint[ nI, 19] ,;
							  aDadSint[ nI, 20] ,;
							  aDadSint[ nI, 21] / aDadCont[nI] ,;
							  aDadSint[ nI, 22] ,;
							  aDadSint[ nI, 23] ,;
							  aDadSint[ nI, 24] ,;
							  aDadSint[ nI, 25] ,;
							  aDadSint[ nI, 26] } )
							  
			// soma por LINHA - AGRUPADA
			// aDadosA[01] += 1		           // Curral : Qtde de registros
			aDadosA[05] += aDadSint[ nI, 05] // Qtde
			aDadosA[15] += aDadSint[ nI, 15] // Qtde
			aDadosA[20] += aDadSint[ nI, 20]
			aDadosA[23] += aDadSint[ nI, 23]
			
			// contador soma total
			// aDados[01] += 1		           // Curral : Qtde de registros
			aDados[05] += aDadSint[ nI, 05] // Qtde
			aDados[15] += aDadSint[ nI, 15]
			aDados[20] += aDadSint[ nI, 20]
			aDados[23] += aDadSint[ nI, 23]
			
			if nI == Len( aDadSint )
				// proxima linha diferente, entao mudou a LINHA; colocar soma
				oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDadosA) )
		
				// acabou o betor .. imprimir a soma total
				oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )	
				oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )	
				oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
				oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDados) )
			Else 
				If AllTrim( aDadSint[nI+1, 1] ) <> AllTrim( aDadSint[nI, 1] ) // .AND. aDadSint[nI+1, 4] <> aDadSint[nI, 4]
					// proxima linha diferente, entao mudou a LINHA; colocar soma
					oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDadosA) )
					oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
					// aDadosA[01] := 0
					aDadosA[05] := 0
					aDadosA[15] := 0
					aDadosA[20] := 0
					aDadosA[23] := 0
				EndIf
			EndIf
			nI += 1
		EndDo		
	EndIf
	
Return aDadSint


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  06.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro2(dDTReferencia, aCurSint, aPasSint )

Local _cQry      := ""
Local cAlias     := CriaTrab(,.F.)   
Local cWorkSheet := "Resumo Por Era"

Local aDados 	 := Array(04)
Local nTotal 	 := 0
Local nTotalT 	 := 0
Local cAgrupa    := ""
Local nValTotEst := 0
Local nGTotEst   := 0

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)

//Adiciona uma coluna a tabela de uma Worksheet.
// AddColumn( cWorkSheet, cTable, < cColumn > , nAlign, nFormat, lTotal)
//nAlign > Alinhamento da coluna ( 1-Left,2-Center,3-Right )
//nFormat > Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
//lTotal > Indica se a coluna deve ser totalizada
/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Era"		  		    , 1, 1 )
/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qt. Cabeças" 		, 1, 1 )
/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "R$ Total Estoque" 	, 1, 3 )
/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "R$ / Cabeças" 		, 1, 3 )

	aSort(aDadTp1,,,{|x,y| x[5] < y[5] })
	aSort(aDadTp4,,,{|x,y| x[5] < y[5] })
	
	aDados[02]  := 0
	aDados[03]  := 0
	nTotal		:= 0
	cAgrupa 	:= aDadTp1[1, 5]
	For nI := 1 to Len(aDadTp1)
	
		If cAgrupa <> aDadTp1[nI, 5]
			
			nValTotEst := SomaValEst(cAgrupa, aCurSint, 15)
			oExcel:AddRow( cWorkSheet, cTitulo, { cAgrupa, aDados[02], nValTotEst, nValTotEst/aDados[02]  } )
			
			aDados[02] := 0
			aDados[03] += nValTotEst
			cAgrupa    := aDadTp1[ nI, 05]
		EndIf
		
		aDados[02]  += aDadTp1[nI, 06]
		nTotal  	+= aDadTp1[nI, 06]
	Next nI
	nValTotEst := SomaValEst(cAgrupa, aCurSint, 15)
	aDados[03] += nValTotEst
	oExcel:AddRow( cWorkSheet, cTitulo, { cAgrupa, aDados[02], nValTotEst, nValTotEst/aDados[02] } )
	oExcel:AddRow( cWorkSheet, cTitulo, { ""     , nTotal    , aDados[3], aDados[3]/nTotal 		 } )
	nTotalT := nTotal
	nGTotEst := aDados[03]
	
	// imprimir Quadro 2 : Tipo 4
	aDados 	 := Array(04)
	oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
	oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
	oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )

	oExcel:AddRow( cWorkSheet, cTitulo, {"Tipo 4", ""			, ""				, ""			 } )
	oExcel:AddRow( cWorkSheet, cTitulo, {"Era"	 , "Qt. Cabeças", "R$ Total Estoque", "R@ / Cabeças" } )
	
	aDados[02]  := 0
	aDados[03]  := 0
	nTotal		:= 0
	cAgrupa 	:= aDadTp4[1, 5]
	For nI := 1 to Len(aDadTp4)
	
		If cAgrupa <> aDadTp4[nI, 5]
			nValTotEst := SomaValEst(cAgrupa, aPasSint, 16)
			oExcel:AddRow( cWorkSheet, cTitulo, { cAgrupa, aDados[02], nValTotEst, nValTotEst/aDados[02] } )
			aDados[02] := 0
			aDados[03]  += nValTotEst
			cAgrupa    := aDadTp4[nI, 05]
		EndIf	
		
		aDados[02]  += aDadTp4[nI, 06]
		nTotal  	+= aDadTp4[nI, 06]
	Next nI
	nValTotEst 	:= SomaValEst(cAgrupa, aPasSint, 16)
	aDados[03] 	+= nValTotEst
	oExcel:AddRow( cWorkSheet, cTitulo, { cAgrupa, aDados[02], nValTotEst, nValTotEst/aDados[02] } )
	oExcel:AddRow( cWorkSheet, cTitulo, { ""     , nTotal    , aDados[3] , aDados[3]/nTotal 		 } )

	nGTotEst 	+= aDados[03]
	
	oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
	aDados 	 := Array(04)
	aDados[01] := "Total Geral"
	aDados[02] := nTotalT + nTotal
	aDados[03] := nGTotEst
	aDados[04] := aDados[03] / aDados[02]
	
	oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDados) )
// EndIf

// (cAlias)->(DbCloseArea())
	
Return nil

/* MJ : 10.04.2018
	# Roda matriz em busca de Era */
Static Function SomaValEst( cAgrupa, aMatriz, nCol ) 
Local nRet  := 0
Local nI	:= 0

	For nI := 1 to Len(aMatriz)
		If allTrim(cAgrupa) == 	AllTrim( aMatriz[nI, 4] )
			nRet += aMatriz[nI, nCol] 
		EndIf
	next nI
	
return nRet


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  06.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro3( aLinVazia )

Local _cQry      := ""
// Local cAlias     := CriaTrab(,.F.)   
Local cWorkSheet := "Lista Currais Vazios"

Local aDados 	 := Array(1)

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)

	If Len(aLinVazia) > 0
	
		//Adiciona uma coluna a tabela de uma Worksheet.
		// AddColumn( cWorkSheet, cTable, < cColumn > , nAlign, nFormat, lTotal)
		//nAlign > Alinhamento da coluna ( 1-Left,2-Center,3-Right )
		//nFormat > Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
		//lTotal > Indica se a coluna deve ser totalizada
		/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Linhas Vazias"	, 1, 1 )
	
		aDados[01] := 0
		
		// While !(cAlias)->(Eof())
		For nI := 1 to Len(aLinVazia)
			// oExcel:AddRow( cWorkSheet, cTitulo, { (cAlias)->Z08_CODIGO } )
			
			If aLinVazia[nI,2]
				oExcel:AddRow( cWorkSheet, cTitulo, { aLinVazia[nI,1] } )
				aDados[01] += 1
			EndIf
			// (cAlias)->(DbSkip())
		Next nI
		// EndDo
		
		oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		aDados[01] := "Total: " + StrZero(aDados[01],2)
		oExcel:AddRow( cWorkSheet, cTitulo, aDados )
	EndIf
	
Return nil


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  06.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro4( dDTReferencia, cDiasAb, nAgrup )

Local _cQry      := ""
Local cAlias     := CriaTrab(,.F.)   
Local cWorkSheet := "Lista Pastos"
Local nQATU		 := 0

Local aDados 	 := Array(15)
Local aDadosA 	 := Array(15)
Local cAgrupa    := ""

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)
	
	(cAliasEST)->(DbGoTop())
	If (cAliasEST)->(Eof())
		MsgAlert("Não foi localizado informacao para o Quadro 1: Lista-Tipo1" )
	Else
		//Adiciona uma coluna a tabela de uma Worksheet.
		// AddColumn( cWorkSheet, cTable, < cColumn > , nAlign, nFormat, lTotal)
		//nAlign > Alinhamento da coluna ( 1-Left,2-Center,3-Right )
		//nFormat > Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
		//lTotal > Indica se a coluna deve ser totalizada
		/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Produto"		     , 1, 1 )
		/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Linha" 		     , 1, 1 )
		/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"			     , 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Entrada"		     , 1, 1 )
		/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Era"			     , 1, 1 )
		/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde " + SubS(dToC(sToD(dDTReferencia)),1,5), 1, 1 )
		/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Média (Kg)" 	     , 1, 1 )
		/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Origem" 		     , 1, 1 )
		/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Raça" 			     , 1, 1 )
		/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Sexo" 			     , 1, 1 )
		/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dias"			     , 1, 1 )
		/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "GMD" 			     , 1, 1 )
		/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Atual(Kg)"     , 1, 1 )
		/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Fornecedor"     , 1, 1 )
		/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observação"         , 1, 1 )
		
		aDados[02]  := 0
		aDados[06]  := 0
		aDadosA[02]  := 0
		aDadosA[06]  := 0
		
		cAgrupa := (cAliasEST)->GRUPO2
		
		While !(cAliasEST)->(Eof())
			
			If (cAliasEST)->Z08_TIPO <> '1'
			
				If nAgrup == 3
					If cAgrupa <> (cAliasEST)->ORDEM .and. aDadosA[06] <> 0
						oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDadosA) )
						oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
						oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
						
						aDadosA[02] := 0
						aDadosA[06] := 0
					EndIf
				EndIf
			
				nQATU := Iif(dDTReferencia == dToS(dDataBase), (cAliasEST)->B2_QATU, CalcEstL( (cAliasEST)->B2_COD, (cAliasEST)->B2_LOCAL, sToD(dDTReferencia)+1, (cAliasEST)->B1_XLOTE)[1] )
				If nQATU <> 0
					
					oExcel:AddRow( cWorkSheet, cTitulo, ;
									{ (cAliasEST)->B2_COD, ;
									  (cAliasEST)->B1_X_CURRA, ;
									  (cAliasEST)->B1_XLOTE, ;
									  (cAliasEST)->B1_XDATACO, ;
									  (cAliasEST)->B1_X_ERA, ;
									  nQATU, ;
									  (cAliasEST)->B1_XPESOCO, ;
									  (cAliasEST)->B1_XLOTCOM, ;
									  (cAliasEST)->B1_XRACA, ;
									  (cAliasEST)->B1_X_SEXO, ;
									  (cAliasEST)->Dias, ;
									  (cAliasEST)->Z09_GMDESP, ;
									  (cAliasEST)->PesoAtual, ;
									  (cAliasEST)->A2_NOME, ;
									  PegaOBSB8((cAliasEST)->B2_COD) } )

					aAdd( aDadTp4, { (cAliasEST)->B2_COD, ;
									 (cAliasEST)->B1_X_CURRA, ;
									 (cAliasEST)->B1_XLOTE, ;
									 (cAliasEST)->B1_XDATACO, ;
									 (cAliasEST)->B1_X_ERA, ;
									 nQATU, ;
									 (cAliasEST)->B1_XPESOCO, ;
									 (cAliasEST)->B1_XLOTCOM, ;
									 (cAliasEST)->B1_XRACA, ;
									 (cAliasEST)->B1_X_SEXO, ;
									 (cAliasEST)->Dias, ;
									 (cAliasEST)->Z09_GMDESP, ;
									 (cAliasEST)->PesoAtual } )
					
					If nAgrup == 3
						cAgrupa := (cAliasEST)->ORDEM
						
						aDadosA[02] += 1		           // Curral : Qtde de registros
						aDadosA[06] += nQATU // Qtde
						// aDadosA[18] += (cAliasEST)->PesoFinalTOTAL // Qtde
					EndIf
					
					aDados[02] += 1		// Curral : Qtde de registros
					aDados[06] += nQATU // Qtde

				EndIf
			endIf
			
			(cAliasEST)->(DbSkip())
		EndDo

		oExcel:AddRow( cWorkSheet, cTitulo, aDados )
		
	EndIf

	// (cAliasEST)->(DbCloseArea()) // nao fechar alias, pois usarei ele no proximo quadro
Return nil


/* MJ : 05.04.2018 
	# Sintetico 
*/
Static Function sQuadro4s( dDTReferencia, cDiasAb, nAgrup, aRet )

Local cWorkSheet := "Pastos - Sintetico"
Local aDados 	 := Array(19)
Local aDadosA 	 := Array(19)
Local aDadSint	 := Array(19)
Local aDadCont	 := {}
Local cLinha     := ""
Local cEra    	 := ""

Local nQATU		 := 0, nI := 1
Local nRSPadArb	 := GetMV('VA_VLRAROB',,155), nVlrArrob := 0
Local nVndPadArb := GetMV('VA_AROBBND',,163), nArrobVnd := 0
Local nPesCarc	 := 0, nVlrTotEst := 0

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)
	
	(cAliasEST)->(DbGoTop())
	If (cAliasEST)->(Eof())
		MsgAlert("Não foi localizado informacao para o Quadro 1: Lista-Tipo1" )
	Else
		//Adiciona uma coluna a tabela de uma Worksheet.
		// AddColumn( cWorkSheet, cTable, < cColumn > , nAlign, nFormat, lTotal)
		//nAlign > Alinhamento da coluna ( 1-Left,2-Center,3-Right )
		//nFormat > Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
		//lTotal > Indica se a coluna deve ser totalizada
		/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Linha"				, 1, 1 )
		/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"				, 1, 1 )
		/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Entrada"				, 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Era"					, 1, 1 )
		/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde " + SubS(dToC(sToD(dDTReferencia)),1,5), 1, 1 )
		/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Média (Kg)"			, 1, 1 )
		/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Origem"				, 1, 1 )
		/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Raça"				, 1, 1 )
		/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Sexo"				, 1, 1 )
		/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dias"				, 1, 1 )
		/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "GMD" 				, 1, 1 )
		/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Atual(Kg)"		, 1, 1 )
		/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Rend. Esperado"	 	   	, 1, 1 )
		
		/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor @ Estoque"		, 1, 3 )
		/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Carcaça"		, 1, 2 )
		/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "R$ Total Estoque"	, 1, 3 )
		
		/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Fornecedor"			, 1, 1 )
		/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observação"			, 1, 1 )
		/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Produto"				, 1, 1 )
		
		// aDados[01]  := 0
		aDados[05]  := 0
		aDados[16]  := 0
		// aDadosA[01] := 0
		aDadosA[05] := 0
		aDadosA[16] := 0

		// cLinha	:= (cAliasEST)->ORDEM
		cLinha	:= ""
		cEra	:= ""
		aDadSint := {}		
		
		// proccessando dados - agrupando informacoes
		While !(cAliasEST)->(Eof())
			If (cAliasEST)->Z08_TIPO <> '1' 
				nQATU := Iif(dDTReferencia == dToS(dDataBase), (cAliasEST)->B2_QATU, CalcEstL( (cAliasEST)->B2_COD, (cAliasEST)->B2_LOCAL, sToD(dDTReferencia)+1, (cAliasEST)->B1_XLOTE)[1] )
				If nQATU <> 0
					If cLinha <> (cAliasEST)->ORDEM .or. cEra <> (cAliasEST)->B1_X_ERA 
						aAdd( aDadSint		 , {} 								)  
						aAdd( aTail(aDadSint), (cAliasEST)->B1_X_CURRA          )  // 01
						aAdd( aTail(aDadSint), (cAliasEST)->B1_XLOTE            )  // 02
						aAdd( aTail(aDadSint), (cAliasEST)->B1_XDATACO          )  // 03
						aAdd( aTail(aDadSint), (cAliasEST)->B1_X_ERA            )  // 04
						aAdd( aTail(aDadSint), nQATU                            )  // 05
						aAdd( aTail(aDadSint), (cAliasEST)->B1_XPESOCO          )  // 06
						aAdd( aTail(aDadSint), (cAliasEST)->B1_XLOTCOM          )  // 07
						aAdd( aTail(aDadSint), (cAliasEST)->B1_XRACA            )  // 08
						aAdd( aTail(aDadSint), (cAliasEST)->B1_X_SEXO           )  // 09
						aAdd( aTail(aDadSint), (cAliasEST)->Dias                )  // 10 
						aAdd( aTail(aDadSint), (cAliasEST)->Z09_GMDESP          )  // 11
						aAdd( aTail(aDadSint), (cAliasEST)->PesoAtual           )  // 12
						aAdd( aTail(aDadSint), (cAliasEST)->Z09_RENESP          )  // 13
						
						aAdd( aTail(aDadSint), 0			            		)  // 14
						aAdd( aTail(aDadSint), 0 								)  // 15
						aAdd( aTail(aDadSint), 0 								)  // 16
						
						aAdd( aTail(aDadSint), AllTrim( (cAliasEST)->A2_NOME )  )  // 17 -  13
						aAdd( aTail(aDadSint), AllTrim( PegaOBSB8((cAliasEST)->B2_COD) ) )  // 18 - 14
						aAdd( aTail(aDadSint), AllTrim( (cAliasEST)->B2_COD	)	)  // 19 - 15
						
						// Contador - Agrupamento - Media
						aAdd( aDadCont, 1 ) 
					Else
						aDadCont[len(aDadCont)] += 1
					
						// "Qtde "
						aDadSint[ len(aDadCont), 5] += nQATU
						// "Média (Kg)" 	     	
						aDadSint[ len(aDadCont), 6] += (cAliasEST)->B1_XPESOCO
						// "Origem" 
						If Empty(aDadSint[ len(aDadCont), 7])
							aDadSint[ len(aDadCont), 7] := (cAliasEST)->B1_XLOTCOM
						EndIf
						// "Peso Atual(Kg)"	 	
						aDadSint[ len(aDadCont), 12] += (cAliasEST)->PesoAtual
						// "Fornecedor"			
						xAux := AllTrim( (cAliasEST)->A2_NOME )
						If !( xAux $ aDadSint[len(aDadCont),17] ) 
							aDadSint[len(aDadCont),17] += Iif(Empty(aDadSint[len(aDadCont),17]), "", Iif(Empty(xAux), "", " | ")) + xAux
						EndIf
						// "Observação"
						xAux := AllTrim( PegaOBSB8((cAliasEST)->B2_COD) )
						If !( xAux $ aDadSint[len(aDadCont),18] )
							aDadSint[len(aDadCont),18] += Iif(Empty(aDadSint[len(aDadCont),18]), "", Iif(Empty(xAux), "", " | ")) + xAux
						EndIf						
						// "Produto"	
						aDadSint[ len(aDadCont), 19] += Iif(Empty(aDadSint[len(aDadCont), 19]), "", " | ") + AllTrim( (cAliasEST)->B2_COD )
					EndIf
					cLinha := (cAliasEST)->ORDEM 
					cEra   := (cAliasEST)->B1_X_ERA
				EndIf
			EndIf
			
			(cAliasEST)->(DbSkip())
		EndDo
		
		nI 		:= 1
		While nI <= Len( aDadSint )
		
			DO CASE
				CASE "BOI" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[06]
					nArrobVnd := aRet[14]
				CASE "GARROTE" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[07]
					nArrobVnd := aRet[15]
				CASE "BEZERRO" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[08]
					nArrobVnd := aRet[16]
				CASE "TOURO" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[09]
					nArrobVnd := aRet[17]
				CASE "VACA" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[10]
					nArrobVnd := aRet[18]
				CASE "NOVILHA" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[11]
					nArrobVnd := aRet[19]
				CASE "BEZERRA" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[12]
					nArrobVnd := aRet[20]
				CASE "BUFAL" $ aDadSint[ nI, 04] // (cAliasEST)->B1_X_ERA
					nVlrArrob := aRet[13]
					nArrobVnd := aRet[21]
				OTHERWISE
					nVlrArrob := nRSPadArb
					nArrobVnd := nVndPadArb
			ENDCASE
			
			aDadSint[ nI, 14]	:= nVlrArrob
			
			nPesCarc := (aDadSint[ nI, 12]/aDadCont[nI]) * (aDadSint[ nI, 13] / 100)
			aDadSint[ nI, 15]	:= nPesCarc
			
			nVlrTotEst := (nPesCarc/15) * nVlrArrob * aDadSint[ nI, 05 ]
			aDadSint[ nI, 16]	:= nVlrTotEst
		
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ aDadSint[ nI, 01] ,;
							  aDadSint[ nI, 02] ,;
							  aDadSint[ nI, 03] ,;
							  aDadSint[ nI, 04] ,;
							  aDadSint[ nI, 05] ,;
							  aDadSint[ nI, 06] / aDadCont[nI] ,;
							  aDadSint[ nI, 07] ,;
							  aDadSint[ nI, 08] ,;
							  aDadSint[ nI, 09] ,;
							  aDadSint[ nI, 10] ,;
							  aDadSint[ nI, 11] ,;
							  aDadSint[ nI, 12] / aDadCont[nI] ,;
							  aDadSint[ nI, 13] ,;
							  aDadSint[ nI, 14] ,;
							  aDadSint[ nI, 15] ,;
							  aDadSint[ nI, 16] ,;
							  aDadSint[ nI, 17] ,;
							  aDadSint[ nI, 18] ,;
							  aDadSint[ nI, 19] } )
			// soma por LINHA - AGRUPADA
			// aDadosA[01] += 1		           // Curral : Qtde de registros
			aDadosA[05] += aDadSint[ nI, 05] // Qtde
			aDadosA[16] += aDadSint[ nI, 16] 
			
			// contador soma total
			// aDados[01] += 1		           // Curral : Qtde de registros
			aDados[05] += aDadSint[ nI, 05] // Qtde
			aDados[16] += aDadSint[ nI, 16]
			
			if nI == Len( aDadSint )
				// proxima linha diferente, entao mudou a LINHA; colocar soma
				oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDadosA) )
		
				// acabou o betor .. imprimir a soma total
				oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )	
				oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )	
				oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
				oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDados) )
			Else 
				If AllTrim( aDadSint[nI+1, 1] ) <> AllTrim( aDadSint[nI, 1] ) // .AND. aDadSint[nI+1, 4] <> aDadSint[nI, 4]
					// proxima linha diferente, entao mudou a LINHA; colocar soma
					oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDadosA) )
					oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
					// aDadosA[01] := 0
					aDadosA[05] := 0
					aDadosA[16] := 0
				EndIf
			EndIf
			nI += 1
		EndDo		
	EndIf
	
Return aDadSint


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  13.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro5(nAgrup, cDiasAb, dDTReferencia, dDtMoviment )
Local _cQry      := ""
Local cAlias     := CriaTrab(,.F.)   
Local cWorkSheet := "Lista Currais-Movimentação"
Local aDados 	 := Array(22)
// Local aDadosA 	 := Array(21)
// Local cAgrupa    := ""
Local nQATU		 := 0
Local aPrintSD3  := {}

Local cChave	 := ""

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)

_cQry := " WITH SALDO_ATUAL AS ( " + CRLF
_cQry += " 	SELECT  DISTINCT B2_FILIAL, B2_COD, B2_LOCAL, B1_XLOTE, B1_X_CURRA " + CRLF
_cQry += " 	FROM " + RetSqlName('SB1') + "  B1 " + CRLF
_cQry += " 	JOIN " + RetSqlName('SB2') + " B2 ON B1_FILIAL='"+xFilial('SB1')+"' AND B2_FILIAL='"+xFilial('SB2')+"' AND B1_COD=B2_COD AND B1.D_E_L_E_T_= ' ' AND B2.D_E_L_E_T_=' ' " + CRLF
// _cQry += " 	WHERE B1_GRUPO='BOV' AND B1_RASTRO <> 'L' " + CRLF
_cQry += " 	WHERE B1_GRUPO IN ('BOV','01') " + CRLF
_cQry += " ), " + CRLF
_cQry += " " + CRLF
_cQry += " SALDO_LOTE AS ( " + CRLF
_cQry += " 	SELECT DISTINCT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_X_CURRA, B8_LOTECTL " + CRLF
_cQry += " 	FROM " + RetSqlName('SB1') + "  B1 " + CRLF
_cQry += " 	JOIN " + RetSqlName('SB8') + "  B8 ON B1_FILIAL='"+xFilial('SB1')+"' AND B8_FILIAL='"+xFilial('SB8')+"' AND B1_COD=B8_PRODUTO AND B1.D_E_L_E_T_= ' ' AND B8.D_E_L_E_T_=' ' " + CRLF
// _cQry += " 	WHERE B1_GRUPO='BOV' AND B1_RASTRO = 'L' " + CRLF
_cQry += " 	WHERE B1_GRUPO IN ('BOV','01') " + CRLF
_cQry += " ), " + CRLF
_cQry += " " + CRLF
_cQry += " PRODUTOS AS ( " + CRLF
_cQry += " 	SELECT DISTINCT " + CRLF
_cQry += " 	CASE ISNULL(Z08_TIPO,'*') WHEN '*' THEN 'SEM CLASSIFICAÇÃO' ELSE Z08_TIPO END Z08_TIPO, " + CRLF
_cQry += " 	B2_FILIAL, B2_COD, B2_LOCAL, " + CRLF
_cQry += " 	ISNULL(L.B8_LOTECTL, A.B1_XLOTE) B1_XLOTE, " + CRLF
_cQry += " 	ISNULL(L.B8_X_CURRA, A.B1_X_CURRA) B1_X_CURRA " + CRLF
_cQry += " 	FROM	 SALDO_ATUAL A " + CRLF
_cQry += " 	LEFT JOIN SALDO_LOTE L ON B2_FILIAL=B8_FILIAL AND B2_COD=B8_PRODUTO AND B2_LOCAL=B8_LOCAL " + CRLF
_cQry += " 	LEFT JOIN " + RetSqlName('Z08') + " Z8 ON Z08_FILIAL='"+xFilial('Z08')+"' AND RTRIM(UPPER(Z08_CODIGO))=RTRIM(UPPER(ISNULL(L.B8_X_CURRA, A.B1_X_CURRA))) AND Z8.D_E_L_E_T_=' ' " + CRLF
_cQry += " ), " + CRLF
_cQry += " " + CRLF
_cQry += " MOVIMENTOS AS ( " + CRLF
_cQry += " 	 SELECT " + CRLF
_cQry += " 	 DISTINCT " + CRLF
_cQry += " 	 Z08_TIPO, " + CRLF
_cQry += " 	 D3_FILIAL, D3_COD, D3_LOCAL, " + CRLF
_cQry += " 	 D3_NUMSEQ NUMSEQ, D3_SEQCALC SEQ, " + CRLF
_cQry += " 	 CASE " + CRLF
_cQry += "  		WHEN D3_TM < '500' " + CRLF
_cQry += "  		THEN 'ENTRADA' " + CRLF
_cQry += "  		ELSE 'SAIDA' " + CRLF
_cQry += " 	 END TIPO_MOV, " + CRLF
_cQry += " 	 CASE " + CRLF
_cQry += "  		WHEN SUBSTRING(D3_CF,3,1) = '4' " + CRLF
_cQry += "  			THEN 'TRANSFERENCIA' " + CRLF
_cQry += "  			ELSE F5_TEXTO " + CRLF
_cQry += " 	 END MOTIVO, " + CRLF
_cQry += " 	 D3_TM,  B1_DESC, " + CRLF
_cQry += " 	 D3_LOTECTL, " + CRLF
_cQry += " 	 P.B1_X_CURRA, " + CRLF
_cQry += " 	 D3_GRUPO, D3_QUANT, D3_EMISSAO, D3_USUARIO, D3_X_OBS " + CRLF
_cQry += " 	 FROM SD3010 D " + CRLF
_cQry += " 	 LEFT JOIN SF5010 F ON F5_FILIAL=' ' AND F5_CODIGO=D3_TM AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	 JOIN " + RetSqlName('SB1') + "  B ON B1_FILIAL=' ' AND B1_COD=D3_COD AND B.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	 JOIN PRODUTOS P ON D3_FILIAL=B2_FILIAL AND D3_COD=B2_COD AND D3_LOCAL=B2_LOCAL AND D3_LOTECTL=P.B1_XLOTE " + CRLF
_cQry += " 	WHERE " + CRLF
_cQry += " 	     D3_EMISSAO BETWEEN '"+ dDtMoviment +"' AND '"+ dDTReferencia + "' " + CRLF
_cQry += " 	 AND (D3_TM NOT IN ('001','002') AND D3_GRUPO NOT IN ('02','03') AND (D3_TM <> '999' AND D3_CF <> 'RE')) " + CRLF
_cQry += " 	 " + CRLF
_cQry += " 	 UNION ALL " + CRLF
_cQry += " " + CRLF
_cQry += " 	 SELECT " + CRLF
_cQry += " 	 Z08_TIPO, " + CRLF
_cQry += " 	 D2_FILIAL, D2_COD, D2_LOCAL, " + CRLF
_cQry += " 	 D2_DOC+D2_SERIE, CONVERT(VARCHAR,D.R_E_C_N_O_), 'SAIDA', 'VENDAS', '', B1_DESC, " + CRLF
_cQry += " 	 D2_LOTECTL, " + CRLF
_cQry += " 	 P.B1_X_CURRA, " + CRLF
_cQry += " 	 D2_GRUPO, D2_QUANT, D2_EMISSAO, '', '' " + CRLF
_cQry += " 	 FROM SD2010 D " + CRLF
_cQry += " 	 JOIN " + RetSqlName('SB1') + "  B ON B1_FILIAL=' ' AND B1_COD=D2_COD AND B.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' ' " + CRLF
_cQry += "      JOIN PRODUTOS P ON D2_FILIAL=B2_FILIAL AND D2_COD=B2_COD AND D2_LOCAL=B2_LOCAL  AND D2_LOTECTL=P.B1_XLOTE AND D.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	 WHERE D2_EMISSAO BETWEEN '"+ dDtMoviment +"' AND '"+ dDTReferencia + "' " + CRLF
_cQry += " " + CRLF
_cQry += " 	 UNION ALL " + CRLF
_cQry += " " + CRLF
_cQry += " 	 SELECT " + CRLF
_cQry += " 	 Z08_TIPO, " + CRLF
_cQry += " 	 D1_FILIAL, D1_COD, D1_LOCAL, " + CRLF
_cQry += " 	 D1_DOC+D1_SERIE, CONVERT(VARCHAR,D.R_E_C_N_O_), 'ENTRADA', 'COMPRAS', '', B1_DESC, " + CRLF
_cQry += " 	 D1_LOTECTL, " + CRLF
_cQry += " 	 P.B1_X_CURRA, " + CRLF
_cQry += " 	 D1_GRUPO, D1_QUANT, D1_EMISSAO, '', '' " + CRLF
_cQry += " 	 FROM SD1010 D " + CRLF
_cQry += " 	 JOIN " + RetSqlName('SB1') + "  B ON B1_FILIAL=' ' AND B1_COD=D1_COD AND B.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' ' " + CRLF
_cQry += "      JOIN PRODUTOS P ON D1_FILIAL=B2_FILIAL AND D1_COD=B2_COD AND D1_LOCAL=B2_LOCAL AND D1_LOTECTL=P.B1_XLOTE AND D.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	 WHERE D1_EMISSAO BETWEEN '"+ dDtMoviment +"' AND '"+ dDTReferencia + "' " + CRLF
_cQry += " ) " + CRLF
_cQry += " " + CRLF
_cQry += " SELECT * " + CRLF
_cQry += " FROM MOVIMENTOS " + CRLF
_cQry += " WHERE D3_FILIAL = '"+xFilial('SD3')+"' " + CRLF
_cQry += " ORDER BY Z08_TIPO, D3_FILIAL, D3_COD, D3_LOCAL, D3_EMISSAO, NUMSEQ, SEQ " + CRLF
	
	// If Select(cAlias) > 0
		// (cAlias)->(DbCloseArea())
	// EndIf
	If cUserName == 'mbernardo'
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro5.sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliasMOV),.F.,.F.) 
	
	aMov := {}
	While !(cAliasMOV)->(Eof())
		aAdd( aMov		 , {} 						)
		aAdd( aTail(aMov), (cAliasMOV)->NUMSEQ  	) // 01
		aAdd( aTail(aMov), (cAliasMOV)->TIPO_MOV  	) // 02
		aAdd( aTail(aMov), (cAliasMOV)->MOTIVO  	) // 03
		aAdd( aTail(aMov), (cAliasMOV)->D3_FILIAL  	) // 04
		aAdd( aTail(aMov), (cAliasMOV)->D3_QUANT 	) // 05
		aAdd( aTail(aMov), (cAliasMOV)->D3_EMISSAO	) // 06
		aAdd( aTail(aMov), (cAliasMOV)->D3_COD  	) // 07
		aAdd( aTail(aMov), (cAliasMOV)->B1_DESC		) // 08
		aAdd( aTail(aMov), (cAliasMOV)->D3_LOTECTL	) // 09
		aAdd( aTail(aMov), ""						) // 10
		aAdd( aTail(aMov), ""						) // 11
		aAdd( aTail(aMov), ""						) // 12
		aAdd( aTail(aMov), (cAliasMOV)->D3_USUARIO	) // 13
		aAdd( aTail(aMov), (cAliasMOV)->D3_X_OBS 	) // 14
		
		(cAliasMOV)->(DbSkip())
	EndDo
	
	
	// TcSetField(cAlias, "B1_XDATACO", "D")
	// TcSetField(cAlias, "PrjecAba"  , "D")
	
	(cAliasEST)->(DbGoTop())
	If !(cAliasEST)->(Eof())
		
		//Adiciona uma coluna a tabela de uma Worksheet.
		// AddColumn( cWorkSheet, cTable, < cColumn > , nAlign, nFormat, lTotal)
		//nAlign > Alinhamento da coluna ( 1-Left,2-Center,3-Right )
		//nFormat > Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
		//lTotal > Indica se a coluna deve ser totalizada
		/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Produto"		     , 1, 1 )
		/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Linha" 		     , 1, 1 )
		/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"			     , 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Entrada"		     , 1, 1 )
		/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Era"			     , 1, 1 )
		/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde " + SubS(dToC(sToD(dDtMoviment)),1,5), 1, 1 )
		/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde " + SubS(dToC(sToD(dDTReferencia)),1,5), 1, 1 )
		/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Média (Kg)" 	     , 1, 1 )
		/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Origem" 		     , 1, 1 )
		/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Raça" 			     , 1, 1 )
		/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Sexo" 			     , 1, 1 )
		/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dias"			     , 1, 1 )
		/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "GMD" 			     , 1, 1 )
		/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Atual(Kg)"     , 1, 1 )
		/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dias Abate"         , 1, 1 )
		/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Abate"   	     , 1, 1 )
		/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Rend. Esperado"     , 1, 1 )
		/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Final" 	     , 1, 1 )
		/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Final Total"   , 1, 1 )
		/* 20 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Final Carcaça" , 1, 1 )
		/* 21 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Fornecedor" , 1, 1 )
		/* 22 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observação" 		 , 1, 1 )
		
		aDados[02]  := 0
		aDados[06]  := 0
		aDados[07]  := 0
		aDados[19]  := 0
		
		// cAgrupa := (cAlias)->GRUPO2
		
		nLin := '0'
		(cAliasEST)->(DbGoTop())
		While !(cAliasEST)->(Eof())
			
			If (cAliasEST)->Z08_TIPO <> '4'
				If cChave <> (cAliasEST)->B2_COD+(cAliasEST)->B1_X_CURRA+(cAliasEST)->B1_XLOTE
					nQATU := Iif(dDTReferencia == dToS(dDataBase), (cAliasEST)->B2_QATU, CalcEstL( (cAliasEST)->B2_COD, (cAliasEST)->B2_LOCAL, sToD(dDTReferencia)+1, (cAliasEST)->B1_XLOTE)[1] )
					nQATUMOV := Iif(dDtMoviment == dDTReferencia, nQATU, CalcEstL( (cAliasEST)->B2_COD, (cAliasEST)->B2_LOCAL, sToD(dDtMoviment), (cAliasEST)->B1_XLOTE )[1] )
					If nQATU <> 0
						
						// ConOut(nLin:=Soma1(nLin)+': Inicio PrintSD3: ['+AllTrim((cAliasEST)->B2_COD)+'] ' + Time())
						
						if Len( aPrintSD3 := PrintSD3(cWorkSheet, (cAliasEST)->B2_COD, (cAliasEST)->B1_XLOTE, Len(aDados), dDTReferencia, dDtMoviment ) ) > 0
						
							oExcel:AddRow( cWorkSheet, cTitulo, ;
											{ (cAliasEST)->B2_COD, ;
											  (cAliasEST)->B1_X_CURRA, ;
											  (cAliasEST)->B1_XLOTE, ;
											  (cAliasEST)->B1_XDATACO, ;
											  (cAliasEST)->B1_X_ERA, ;
											  nQATUMOV , ;
											  nQATU , ;
											  (cAliasEST)->B1_XPESOCO, ;
											  (cAliasEST)->B1_XLOTCOM, ;
											  (cAliasEST)->B1_XRACA, ;
											  (cAliasEST)->B1_X_SEXO, ;
											  (cAliasEST)->Dias, ;
											  (cAliasEST)->Z09_GMDESP, ;
											  (cAliasEST)->PesoAtual, ;
											  (cAliasEST)->DiasAbate, ;
											  (cAliasEST)->PrjecAba, ;
											  (cAliasEST)->Z09_RENESP, ;
											  (cAliasEST)->PesoFinal, ;
											  (cAliasEST)->PesoFinalTOTAL, ;
											  (cAliasEST)->PesoCarcacaFinal, ;
											  (cAliasEST)->A2_NOME, ;
											  PegaOBSB8((cAliasEST)->B2_COD) } )
							
							For nI := 1 to Len(aPrintSD3)
								oExcel:AddRow( cWorkSheet, cTitulo, aPrintSD3[nI] )
							Next nI
							
						EndIf	  
						
						aDados[02] += 1		           // Curral : Qtde de registros
						aDados[06] += nQATUMOV // Qtde
						aDados[07] += nQATU // Qtde
						aDados[19] += (cAliasEST)->PesoFinalTOTAL // Qtde
						
					EndIf
				EndIf
				
				cChave := (cAliasEST)->B2_COD+(cAliasEST)->B1_X_CURRA+(cAliasEST)->B1_XLOTE
			endIf
			
			(cAliasEST)->(DbSkip())
		EndDo

		// oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDadosA) )

		// oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, aDados )
		
	EndIf
	
	// (cAliasEST)->(DbCloseArea())
Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  14.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro6( dDTReferencia, dDtMoviment, cDiasAb )
Local cWorkSheet := "Lista Pastos-Movimentação"
Local nQATU		 := 0
Local aDados 	 := Array(16)
Local aPrintSD3  := {}

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)

	(cAliasEST)->(DbGoTop())
	If (cAliasEST)->(Eof())
		MsgAlert("Não foi localizado informacao para o Quadro 1: Lista-Tipo1" )
	Else
		//Adiciona uma coluna a tabela de uma Worksheet.
		// AddColumn( cWorkSheet, cTable, < cColumn > , nAlign, nFormat, lTotal)
		//nAlign > Alinhamento da coluna ( 1-Left,2-Center,3-Right )
		//nFormat > Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
		//lTotal > Indica se a coluna deve ser totalizada
		/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Produto"		     , 1, 1 )
		/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Linha" 		     , 1, 1 )
		/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"			     , 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Entrada"		     , 1, 1 )
		/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Era"			     , 1, 1 )
		/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde " + SubS(dToC(sToD(dDtMoviment)),1,5), 1, 1 )
		/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde " + SubS(dToC(sToD(dDTReferencia)),1,5), 1, 1 )
		/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Média (Kg)" 	     , 1, 1 )
		/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Origem" 		     , 1, 1 )
		/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Raça" 			     , 1, 1 )
		/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Sexo" 			     , 1, 1 )
		/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dias"			     , 1, 1 )
		/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "GMD" 			     , 1, 1 )
		/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Atual(Kg)"     , 1, 1 )
		/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Fornecedor"         , 1, 1 )
		/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observação"         , 1, 1 )
		
		aDados[02]  := 0
		aDados[06]  := 0
		aDados[07]  := 0
		
		cAgrupa := (cAliasEST)->GRUPO2
		
		nLin := '0'
		(cAliasEST)->(DbGoTop())
		While !(cAliasEST)->(Eof())
			
			If (cAliasEST)->Z08_TIPO <> '1'
				nQATU := Iif(dDTReferencia == dToS(dDataBase), (cAliasEST)->B2_QATU, CalcEstL( (cAliasEST)->B2_COD, (cAliasEST)->B2_LOCAL, sToD(dDTReferencia)+1, (cAliasEST)->B1_XLOTE)[1] )
				nQATUMOV := Iif(dDtMoviment == dDTReferencia, nQATU, CalcEstL( (cAliasEST)->B2_COD, (cAliasEST)->B2_LOCAL, sToD(dDtMoviment), (cAliasEST)->B1_XLOTE )[1] )
				If nQATU <> 0

					ConOut(nLin:=Soma1(nLin)+': Inicio PrintSD3: ['+AllTrim((cAliasEST)->B2_COD)+'] ' + Time())
					If Len( aPrintSD3 := PrintSD3(cWorkSheet, (cAliasEST)->B2_COD, (cAliasEST)->B1_XLOTE, Len(aDados), dDTReferencia, dDtMoviment ) ) > 0
					
						oExcel:AddRow( cWorkSheet, cTitulo, ;
										{ (cAliasEST)->B2_COD, ;
										  (cAliasEST)->B1_X_CURRA, ;
										  (cAliasEST)->B1_XLOTE, ;
										  (cAliasEST)->B1_XDATACO, ;
										  (cAliasEST)->B1_X_ERA, ;
										  nQATUMOV, ;
										  nQATU, ;
										  (cAliasEST)->B1_XPESOCO, ;
										  (cAliasEST)->B1_XLOTCOM, ;
										  (cAliasEST)->B1_XRACA, ;
										  (cAliasEST)->B1_X_SEXO, ;
										  (cAliasEST)->Dias, ;
										  (cAliasEST)->Z09_GMDESP, ;
										  (cAliasEST)->PesoAtual, ;
										  (cAliasEST)->A2_NOME, ;
										  PegaOBSB8((cAliasEST)->B2_COD) } )
										  
						For nI := 1 to Len(aPrintSD3)
							oExcel:AddRow( cWorkSheet, cTitulo, aPrintSD3[nI] )
						Next nI

					EndIf
					
					aAdd( aDadTp4, { (cAliasEST)->B2_COD, ;
									 (cAliasEST)->B1_X_CURRA, ;
									 (cAliasEST)->B1_XLOTE, ;
									 (cAliasEST)->B1_XDATACO, ;
									 (cAliasEST)->B1_X_ERA, ;
									 nQATUMOV, ;
									 nQATU, ;
									 (cAliasEST)->B1_XPESOCO, ;
									 (cAliasEST)->B1_XLOTCOM, ;
									 (cAliasEST)->B1_XRACA, ;
									 (cAliasEST)->B1_X_SEXO, ;
									 (cAliasEST)->Dias, ;
									 (cAliasEST)->Z09_GMDESP, ;
									 (cAliasEST)->PesoAtual } )
									  
					aDados[02] += 1		           // Curral : Qtde de registros
					aDados[06] += nQATUMOV // Qtde
					aDados[07] += nQATU // Qtde

				EndIf
			endIf
			(cAliasEST)->(DbSkip())
		EndDo

		//oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, aDados )
		
	EndIf
	
	// (cAliasEST)->(DbCloseArea())
Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  13.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function PrintSD3( cWorkSheet, cProduto, cLote, nQtCol, dDTReferencia, dDtMoviment )
Local aArea     := GetArea()
Local aAUXAlias := {}
Local aRet		:= {}
Local _aColunas := {}
Local nPos		:= 0

nPos := aScan( aMov, { |x| x[7]+x[9] == cProduto+cLote } )
While nPos > 0 // !(cAliasD3)->(Eof())

	if Len(aAUXAlias) > 0 .and. ;
		aAUXAlias[ Len(aAUXAlias), 1] == aMov[nPos, 1] // (cAliasD3)->NUMSEQ
		
		If aAUXAlias[ Len(aAUXAlias), 02 ] <> aMov[nPos, 2] // (cAliasD3)->TIPO_MOV
			aAUXAlias[ Len(aAUXAlias), 02 ] += "/" + aMov[nPos, 2] // (cAliasD3)->TIPO_MOV
		EndIf 
		
		If aAUXAlias[ Len(aAUXAlias), 03 ] <> AllTrim(aMov[nPos, 3]) // (cAliasD3)->MOTIVO)
			aAUXAlias[ Len(aAUXAlias), 03 ] += "/" + aMov[nPos, 3] // (cAliasD3)->MOTIVO
		Else
			If aAUXAlias[ Len(aAUXAlias), 03 ] == "TRANSFERENCIA"
				If cProduto == aAUXAlias[ Len(aAUXAlias), 07 ]
					aAUXAlias[ Len(aAUXAlias), 03 ] := "SAIDA POR TRANSFERENCIA"
				else
					aAUXAlias[ Len(aAUXAlias), 03 ] := "ENTRADA POR TRANSFERENCIA"
				EndIf
			EndIf
		EndIf

		If aAUXAlias[ Len(aAUXAlias), 04 ] <> aMov[nPos, 4] // (cAliasD3)->D3_FILIAL
			aAUXAlias[ Len(aAUXAlias), 04 ] += "/" + aMov[nPos, 4] // (cAliasD3)->D3_FILIAL
		EndIf
		
		aAUXAlias[ Len(aAUXAlias), 09 ] := aMov[nPos, 7] // (cAliasD3)->D3_COD
		aAUXAlias[ Len(aAUXAlias), 10 ] := aMov[nPos, 8] // (cAliasD3)->B1_DESC
		aAUXAlias[ Len(aAUXAlias), 11 ] := aMov[nPos, 9] // (cAliasD3)->B1_XLOTE
		
	Else

		/* aAdd( aAUXAlias, {  (cAliasD3)->NUMSEQ ,;		 
							AllTrim((cAliasD3)->TIPO_MOV) ,;		 
							AllTrim((cAliasD3)->MOTIVO) ,;        
							(cAliasD3)->D3_FILIAL ,;
							(cAliasD3)->D3_QUANT ,;      
							(cAliasD3)->D3_EMISSAO ,;    
							(cAliasD3)->D3_COD ,;        
							(cAliasD3)->B1_DESC ,;       
							(cAliasD3)->B1_XLOTE ,;      
							"" ,;                        
							"" ,;                        
							"" ,;                        
							(cAliasD3)->D3_USUARIO,;
							(cAliasD3)->D3_X_OBS } )
		*/
		aAdd( aAUXAlias, aMov[nPos] )
	EndIf 
	
	nPos+=1
	If ( nPos > Len(aMov) ) .or. ( aMov[nPos, 7] <> cProduto )
		nPos := 0 // zero para sair do laço
	endIf
	// (cAliasD3)->(DbSkip())
	
EndDo

if Len(aAUXAlias) > 0
	
	// oExcel:SetLineBold(.T.)
	_aColunas := {}
	aAdd( _aColunas , "Tipo Mov." 	)  // 01
	aAdd( _aColunas , "Motivo" 		)  // 02
	aAdd( _aColunas , "Filial" 		)  // 03
	aAdd( _aColunas , "Quant." 		)  // 04
	aAdd( _aColunas , "Data" 		)  // 05
	aAdd( _aColunas , "Origem" 		)  // 06
	aAdd( _aColunas , "Era" 	)  // 07
	aAdd( _aColunas , "Destino" 		)  // 08
	aAdd( _aColunas , "Era Dest." 	)  // 09
	aAdd( _aColunas , "Lote" 	)  // 10
	aAdd( _aColunas , "" 		)  // 11
	aAdd( _aColunas , "Usuario" 	)  // 12
	aAdd( _aColunas , "Observação" 	)  // 13
	
	For nJ := Len(_aColunas)+1 to nQtCol
		aAdd( _aColunas , "" )
	Next nJ
	
	// Legendas
	aAdd( aRet, _aColunas )
	// oExcel:SetLineBold(.F.)
	
	For nI := 1 to Len(aAUXAlias)

		_aColunas := {}
		aAdd( _aColunas , aAUXAlias[ nI, 02 ] )
		aAdd( _aColunas , aAUXAlias[ nI, 03 ] )
		aAdd( _aColunas , aAUXAlias[ nI, 04 ] )
		aAdd( _aColunas , aAUXAlias[ nI, 05 ] )
		aAdd( _aColunas , aAUXAlias[ nI, 06 ] )
		aAdd( _aColunas , aAUXAlias[ nI, 07 ] )
		aAdd( _aColunas , aAUXAlias[ nI, 08 ] )
		aAdd( _aColunas , aAUXAlias[ nI, 09 ] )
		aAdd( _aColunas , aAUXAlias[ nI, 10 ] )
		aAdd( _aColunas , aAUXAlias[ nI, 11 ] )
		aAdd( _aColunas , aAUXAlias[ nI, 12 ] )
		aAdd( _aColunas , aAUXAlias[ nI, 13 ] )
		aAdd( _aColunas , aAUXAlias[ nI, 14 ] )
		
		For nJ := Len(_aColunas)+1 to nQtCol
			aAdd( _aColunas , "" )
		Next nJ
		
		//oExcel:AddRow( cWorkSheet, cTitulo, _aColunas )
		aAdd( aRet, _aColunas )
	Next nI                         

	// pular linha
	//oExcel:AddRow( cWorkSheet, cTitulo, Array(nQtCol) )
	aAdd( aRet, Array(nQtCol) )
	aAdd( aRet, Array(nQtCol) )
	aAdd( aRet, Array(nQtCol) )

EndIf

// (cAliasD3)->(DbCloseArea())

RestArea(aArea)
Return aRet

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  09.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function PegaOBSB8(cCodigo)
Local aArea := GetArea()
Local cRet  := ""

SB8->(DbSetOrder(1))
if SB8->(DbSeek( xFilial('SB8')+cCodigo ))
	If !Empty(SB8->B8_X_OBS)
		cRet := AllTrim( SB8->B8_X_OBS)
	EndIf
EndIf

if !Empty(cRet)
	cRet += CRLF + CRLF
EndIf

SB1->(DbSetOrder(1))
if SB1->(DbSeek( xFilial('SB1')+cCodigo ))
	If !Empty(SB1->B1_X_OBS)
		cRet := AllTrim( SB1->B1_X_OBS)
	EndIf
EndIf

RestArea(aArea)
Return OemToAnsi(cRet)
