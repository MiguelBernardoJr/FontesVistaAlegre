#Include "Rwmake.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Totvs.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  08.02.2017                                                              |
 | Desc:  Relatorio de Lotação de Baias e Pastos.                                 |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function  VAEST014() // U_VAEST014()                                                    
Local nOpc 		:= 0
Local aRet 		:= {}
Local aCombo 	:= {"Curral", "Dt. de Abate"}
Local aParamBox := {}


Local cLoad     := ProcName(1) // Nome do perfil se caso for carregar
Local lCanSave  := .T. // Salvar os dados informados nos parâmetros por perfil
Local lUserSave := .T. // Configuração por usuário

Private cTitulo  := "Relatorio Baia e Pasto"        	
Private aSay 	 := {}
Private aButton  := {}

AAdd( aSay , "Este rotina irá gerar o Relatório de Baia x Pasto, no formato Excel.")
AAdd( aSay , "")
AAdd( aSay , "Ele esta divido em 2 planilhas: Tipo: 1-Currais; 4-Pastos")
AAdd( aSay , "")
AAdd( aSay, "Clique para continuar...")

aAdd( aButton, { 1,.T.,{|| nOpc := 1,FechaBatch()}})
aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cTitulo, aSay, aButton )

If nOpc == 1

	aAdd(aParamBox,{9 ,"Escolha uma das opções que segue: ",150,7,.T.})
	// aAdd(aParamBox,{1 ,"Matricula de:" ,Space(06),"","","SRA","",0,.F.}) // Tipo caractere
	// aAdd(aParamBox,{1 ,"Matricula Ate:" ,Space(06),"","","SRA","",0,.T.}) // Tipo caractere
	
	aAdd(aParamBox,{3 ,"Agrupamento:", 1, aCombo, 50, "",.T.})
	aAdd(aParamBox,{1 ,"Dias p/ Abate:", 100, "","","","",0,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Data Referencia:", dDataBase, "@D","","","",50,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Data Movimentação:", dDataBase-30, "@D","","","",50,.T.}) // Tipo caractere
	
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
		FWMsgRun(, {|| EST014VA(aRet[2], aRet[3], aRet[4], aRet[5]) }, 'Geração Relatório Baia x Pasto','Gerando excel, Por Favor Aguarde...')
	EndIF
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
Static Function EST014VA(nAgrup, nDiasAb, dDTReferencia, dDtMoviment)

Local aLinVazia	  := {}
Private aDadTp1   := {}
Private aDadTp4   := {}

Private cPath 	   := "C:\totvs_relatorios\"
Private cArquivo   := cPath + "VAEST014_"+; // __cUserID+"_"+;
								DtoS(dDataBase)+"_"+;
								StrTran(SubS(Time(),1,5),":","")+".xml"
Private oExcel 	   := nil

cTitulo += " - Dt. Referência: " + DtoC(dDTReferencia)
oExcel 	:= FWMsExcel():New()
oExcel:SetFont('Arial Narrow')
oExcel:SetBgColorHeader("#37752F") // cor de fundo linha cabeçalho
oExcel:SetLineBgColor("#FFFFFF")   // cor da linha 1
oExcel:Set2LineBgColor("#FFFFFF")  // cor da linha 2

If Len( Directory(cPath + "*.*","D") ) == 0
	If Makedir(cPath) == 0
		ConOut('Diretorio Criado com Sucesso.')
	Else	
		ConOut( "Nao foi possivel criar o diretorio. Erro: " + cValToChar( FError() ) )
	EndIf
EndIf
                                                                           
aLinVazia := fQuadro1(nAgrup, AllTrim(Str(nDiasAb)), dToS(dDTReferencia) )
fQuadro4( dToS(dDTReferencia) ) // (nAgrup)
fQuadro2( dToS(dDTReferencia) )
fQuadro3(aLinVazia)

fQuadro5(nAgrup, AllTrim(Str(nDiasAb)), dToS(dDTReferencia), dToS(dDtMoviment) )
fQuadro6( dToS(dDTReferencia), dToS(dDtMoviment)  )

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
Local cAlias     := CriaTrab(,.F.)   
Local cWorkSheet := "Lista Currais"

Local aDados 	 := Array(20)
Local aDadosA 	 := Array(20)
Local cAgrupa    := ""

Local nQATU		 := 0

Local aLinVazia  := {}

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)

	_cQry := "  WITH GERAL AS ( " + CRLF
	_cQry += "  	SELECT  B1_XANIMAL, IDADE_ATUAL, ORDEM, B1_COD, B1_X_CURRA, B1_XLOTE, B1_X_ERA, B2_LOCAL, B2_QATU, B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO,  " + CRLF
	_cQry += "  		Z09_GMDESP, B1_XDATACO, DiasAbate, Dias, PesoAtual, PrjecAba, Z09_RENESP, " + CRLF
	_cQry += " 		CASE" + CRLF
	_cQry += " 			WHEN DiasAbate > Dias" + CRLF
	_cQry += " 			THEN PesoFinal" + CRLF
	_cQry += " 			ELSE (DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+Dias))*Z09_GMDESP)+B1_XPESOCO  " + CRLF
	_cQry += " 		END PesoFinal," + CRLF
	_cQry += " 		CASE" + CRLF
	_cQry += " 			WHEN DiasAbate > Dias" + CRLF
	_cQry += " 			THEN PesoFinalTOTAL" + CRLF
	_cQry += " 			ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+Dias))*Z09_GMDESP)+B1_XPESOCO)*B2_QATU " + CRLF
	_cQry += " 		END PesoFinalTOTAL," + CRLF
	_cQry += " 		CASE" + CRLF
	_cQry += " 			WHEN DiasAbate > Dias" + CRLF
	_cQry += " 			THEN PesoCarcacaFinal" + CRLF
	_cQry += " 			ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+Dias))*Z09_GMDESP)+B1_XPESOCO)*(Z09_RENESP/100) " + CRLF
	_cQry += " 		END PesoCarcacaFinal,  " + CRLF
	_cQry += " 		SubString(PrjecAba,1,6) GRUPO2 FROM  " + CRLF
	_cQry += "  ( " + CRLF
	_cQry += "  		SELECT DISTINCT B1_XANIMAL, DATEDIFF(MONTH, CONVERT(DATETIME, B1_DTNASC, 103), CONVERT(DATETIME, '"+dDTReferencia+"', 103)) IDADE_ATUAL, " + CRLF
	_cQry += "  		ISNULL(Z08_TIPO+Z08_LINHA+Z08_SEQUEN,9999) ORDEM,  " + CRLF
	_cQry += "  		B1_COD,  " + CRLF
	_cQry += "  		CASE B1_X_CURRA " + CRLF
	_cQry += "  			WHEN ' '  " + CRLF
	_cQry += "  				THEN 'SEM CLASSIFICAÇÃO'  " + CRLF
	_cQry += "  				ELSE B1_X_CURRA  " + CRLF
	_cQry += "  		END B1_X_CURRA,  " + CRLF
	_cQry += "  		B1_XLOTE, B1_X_ERA, B2_LOCAL, B2_QATU, B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO,  " + CRLF
	_cQry += "  		Z09_GMDESP,  " + CRLF
	_cQry += " 		B1_XDATACO," + CRLF
	_cQry += " 		"+cDiasAb+" AS DiasAbate," + CRLF
	_cQry += " 		CASE B1_XDATACO " + CRLF
	_cQry += "  			WHEN ' ' THEN 0 " + CRLF
	_cQry += "  			ELSE DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '"+dDTReferencia+"', 103))  " + CRLF
	_cQry += "  		END AS Dias,  " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE (DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '"+dDTReferencia+"', 103))*Z09_GMDESP)+B1_XPESOCO  " + CRLF
	_cQry += "  		END PesoAtual, " + CRLF
	_cQry += "  		CASE B1_XDATACO " + CRLF
	_cQry += "  			WHEN ' ' THEN ' ' " + CRLF
	_cQry += "  			ELSE CONVERT( VARCHAR, CONVERT(DATETIME, B1_XDATACO, 103)+"+cDiasAb+", 112) " + CRLF
	_cQry += "  		END 'PrjecAba',  " + CRLF
	_cQry += "  		Z09_RENESP, " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE (DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+"+cDiasAb+"))*Z09_GMDESP)+B1_XPESOCO  " + CRLF
	_cQry += "  		END PesoFinal, " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+"+cDiasAb+"))*Z09_GMDESP)+B1_XPESOCO)*B2_QATU " + CRLF
	_cQry += "  		END PesoFinalTOTAL, " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+"+cDiasAb+"))*Z09_GMDESP)+B1_XPESOCO)*(Z09_RENESP/100) " + CRLF
	_cQry += "  		END PesoCarcacaFinal " + CRLF
	_cQry += "  		FROM SB1010 B1  " + CRLF
	_cQry += "  		LEFT JOIN SB2010 B2 ON B1_FILIAL='  ' AND B2_FILIAL='01' AND B1_COD=B2_COD  " + CRLF
	//AND B2_QATU>0 
	_cQry += "  		AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '  " + CRLF
	_cQry += "  		LEFT JOIN Z08010 Z8 ON Z08_FILIAL=' ' AND RTRIM(UPPER(Z08_CODIGO))=RTRIM(UPPER(B1_X_CURRA)) AND Z8.D_E_L_E_T_=' '  " + CRLF
	_cQry += "  		LEFT JOIN Z09010 Z9 ON Z09_FILIAL=' ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '  " + CRLF
	_cQry += "  		WHERE B1_GRUPO='BOV' AND ISNULL(Z08_TIPO,'1') = '1' " + CRLF
	_cQry += "  ) AS BYPASTO " + CRLF
//	_cQry += " WHERE Dias >= 0 " + CRLF
	_cQry += " ), " + CRLF
	_cQry += "  " + CRLF
	_cQry += " ERA_ATUALIZADA AS " + CRLF
	_cQry += " ( " + CRLF
	_cQry += " 	SELECT DISTINCT B1_COD, Z09_DESCRI " + CRLF
	_cQry += " 	FROM GERAL G " + CRLF
	_cQry += " 	LEFT JOIN Z09010 Z9 ON Z09_FILIAL=' ' AND B1_XANIMAL=Z09_CODIGO AND Z9.D_E_L_E_T_=' '   " + CRLF
	_cQry += " 	WHERE IDADE_ATUAL BETWEEN Z09_IDAINI AND Z09_IDAFIM  " + CRLF
	_cQry += " ) " + CRLF
	_cQry += "  " + CRLF
	_cQry += " SELECT  " + CRLF
	_cQry += " 		ORDEM, G.B1_COD, B1_X_CURRA, B1_XLOTE, " + CRLF
	_cQry += " 		ISNULL(Z09_DESCRI,'SEM CLASSIFICAÇÃO') B1_X_ERA, B2_LOCAL, B2_QATU, B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO,   " + CRLF
	_cQry += "   		Z09_GMDESP, B1_XDATACO, DiasAbate, Dias, PesoAtual, PrjecAba, Z09_RENESP,  " + CRLF
	_cQry += " 		PesoFinal, " + CRLF
	_cQry += "  		PesoFinalTOTAL, " + CRLF
	_cQry += "  		PesoCarcacaFinal, " + CRLF
	_cQry += "  		SubString(PrjecAba,1,6) GRUPO2 " + CRLF
	_cQry += " FROM GERAL G " + CRLF    
	_cQry += " LEFT JOIN ERA_ATUALIZADA E ON G.B1_COD=E.B1_COD " + CRLF
	// _cQry += " WHERE G.B1_COD IN ('BOV000000000166               ','BOV000000000191               ','BOV000000000035               ','BOV000000000293               ','BOV000000000294               ','BOV000000000295               ','BOV000000000298               ') " + CRLF
	_cQry += " ORDER BY " + CRLF	
	
	If nAgrup == 2
		_cQry += " PrjecAba, " + CRLF
	EndIf
	_cQry += " ORDEM, B2_QATU "
	// _cQry := ChangeQuery(_cQry)

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	If cUserName == 'mbernardo'
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro1.sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "B1_XDATACO", "D")
	TcSetField(cAlias, "PrjecAba"  , "D")
	
	If !(cAlias)->(Eof())
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
		/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dias Abate"         , 1, 1 )
		/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Abate"   	     , 1, 1 )
		/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Rend. Esperado"     , 1, 1 )
		/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Final" 	     , 1, 1 )
		/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Final Total"   , 1, 1 )
		/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Final Carcaça" , 1, 1 )
		/* 20 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observação" 		 , 1, 1 )
		
		aDados[02]  := 0
		aDados[06]  := 0
		aDados[18]  := 0
		aDadosA[02] := 0
		aDadosA[06] := 0
		aDadosA[18] := 0
		
		cAgrupa := (cAlias)->GRUPO2
		
		// aSaldos := CalcEst( "BOV000000000003", "01" , StoD("20170101")  )		
		While !(cAlias)->(Eof())
		
			If nAgrup == 2
				If cAgrupa <> (cAlias)->GRUPO2 .and. aDadosA[06] <> 0
					oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDadosA) )
					oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
					oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
					
					aDadosA[02] := 0
					aDadosA[06] := 0
					aDadosA[18] := 0
				EndIf
			EndIf
			
			nQATU := Iif(dDTReferencia == dToS(dDataBase), (cAlias)->B2_QATU, CalcEst( (cAlias)->B1_COD, (cAlias)->B2_LOCAL, sToD(dDTReferencia)+1)[1] )
			If nQATU == 0
				// guardar no vetor de listas vazias  
				if aScan(aLinVazia, { |x| AllTrim(x[1]) == AllTrim((cAlias)->B1_X_CURRA) } ) == 0 ;
					.AND. (cAlias)->ORDEM<>'9999'
					aAdd( aLinVazia, { (cAlias)->B1_X_CURRA, .T.} )
				EndIf
			else
				
				If ( nPosLV := aScan(aLinVazia, { |x| AllTrim(x[1]) == AllTrim((cAlias)->B1_X_CURRA) } ) ) > 0
					aLinVazia[nPosLV,2] := .F.
				EndIf
			                                             
				oExcel:AddRow( cWorkSheet, cTitulo, ;
								{ (cAlias)->B1_COD, ;
								  (cAlias)->B1_X_CURRA, ;
								  (cAlias)->B1_XLOTE, ;
								  (cAlias)->B1_XDATACO, ;
								  (cAlias)->B1_X_ERA, ;
								  nQATU , ;
								  (cAlias)->B1_XPESOCO, ;
								  (cAlias)->B1_XLOTCOM, ;
								  (cAlias)->B1_XRACA, ;
								  (cAlias)->B1_X_SEXO, ;
								  (cAlias)->Dias, ;
								  (cAlias)->Z09_GMDESP, ;
								  (cAlias)->PesoAtual, ;
								  (cAlias)->DiasAbate, ;
								  (cAlias)->PrjecAba, ;
								  (cAlias)->Z09_RENESP, ;
								  (cAlias)->PesoFinal, ;
								  (cAlias)->PesoFinalTOTAL, ;
								  (cAlias)->PesoCarcacaFinal, ;
								  PegaOBSB1((cAlias)->B1_COD) } )
								  
				aAdd( aDadTp1, { (cAlias)->B1_COD, ;
								  (cAlias)->B1_X_CURRA, ;
								  (cAlias)->B1_XLOTE, ;
								  (cAlias)->B1_XDATACO, ;
								  (cAlias)->B1_X_ERA, ;
								  nQATU , ;
								  (cAlias)->B1_XPESOCO, ;
								  (cAlias)->B1_XLOTCOM, ;
								  (cAlias)->B1_XRACA, ;
								  (cAlias)->B1_X_SEXO, ;
								  (cAlias)->Dias, ;
								  (cAlias)->Z09_GMDESP, ;
								  (cAlias)->PesoAtual, ;
								  (cAlias)->DiasAbate, ;
								  (cAlias)->PrjecAba, ;
								  (cAlias)->Z09_RENESP, ;
								  (cAlias)->PesoFinal, ;
								  (cAlias)->PesoFinalTOTAL, ;
								  (cAlias)->PesoCarcacaFinal } )
								  
				If nAgrup == 2
					cAgrupa := (cAlias)->GRUPO2
					
					aDadosA[02] += 1		           // Curral : Qtde de registros
					aDadosA[06] += nQATU // Qtde
					aDadosA[18] += (cAlias)->PesoFinalTOTAL // Qtde
				EndIf

				aDados[02] += 1		           // Curral : Qtde de registros
				aDados[06] += nQATU // Qtde
				aDados[18] += (cAlias)->PesoFinalTOTAL // Qtde
				
			EndIf
			
			(cAlias)->(DbSkip())
		EndDo

		oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDadosA) )

		oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, aDados )
		
	EndIf
	
Return aLinVazia

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  06.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro2(dDTReferencia)

Local _cQry      := ""
Local cAlias     := CriaTrab(,.F.)   
Local cWorkSheet := "Resumo Por Era"

Local aDados 	 := Array(2)
Local nTotal 	 := 0
Local nTotalT 	 := 0
Local cAgrupa    := ""

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)

//Adiciona uma coluna a tabela de uma Worksheet.
// AddColumn( cWorkSheet, cTable, < cColumn > , nAlign, nFormat, lTotal)
//nAlign > Alinhamento da coluna ( 1-Left,2-Center,3-Right )
//nFormat > Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
//lTotal > Indica se a coluna deve ser totalizada
/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Era"		  , 1, 1 )
/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qt. Cabeças" , 1, 1 )

If dDTReferencia == dToS(dDataBase)
	_cQry := " WITH DADOS AS " + CRLF
	_cQry += " ( " + CRLF
	_cQry += "    SELECT B1_X_ERA, SUM(B2_QATU) SOMA " + CRLF
	_cQry += "    FROM " + RetSqlName('SB1') + " B1 " + CRLF
	_cQry += "    LEFT JOIN " + RetSqlName('SB2') + " B2 ON B1_FILIAL='"+xFilial('SB1')+"' AND B2_FILIAL='"+xFilial('SB2')+"' AND B1_COD=B2_COD AND B1_GRUPO='BOV' 
	//AND B2_QATU>0 
	_cQry += "  		AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	  LEFT JOIN Z08010 Z8 ON Z08_FILIAL=' ' AND RTRIM(UPPER(Z08_CODIGO))=RTRIM(UPPER(B1_X_CURRA)) AND Z8.D_E_L_E_T_=' '  " + CRLF
	_cQry += "    LEFT JOIN " + RetSqlName('Z09') + " Z9 ON Z09_FILIAL='"+xFilial('Z09')+"' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' ' " + CRLF
	_cQry += "    WHERE Z08_TIPO = '1' " + CRLF
	_cQry += "    GROUP BY B1_X_ERA " + CRLF
	_cQry += " ), " + CRLF
	_cQry += "  " + CRLF
 	_cQry += " RESULTADO AS  " + CRLF
 	_cQry += " ( " + CRLF
	_cQry += " 	 SELECT  B1_X_ERA, SUM(SOMA) SOMA  " + CRLF
	_cQry += " 	 FROM DADOS  " + CRLF
	_cQry += " 	 GROUP BY B1_X_ERA  " + CRLF
	_cQry += " ) " + CRLF
	_cQry += "  " + CRLF
	_cQry += " SELECT *  " + CRLF
	_cQry += " FROM RESULTADO " + CRLF
	_cQry += " WHERE SOMA > 0 " 
	// _cQry := ChangeQuery(_cQry)
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	If cUserName == 'mbernardo'
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro2-1.sql" , _cQry)
	EndIf	
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry),(cAlias),.F.,.F.) 
	
	If (cAlias)->(Eof())
		MsgAlert("Não foi localizado informacao para o Quadro 1: Lista-Tipo1" )
	Else
		
		aDados[02] := 0
		
		While !(cAlias)->(Eof())
			
			oExcel:AddRow( cWorkSheet, cTitulo, ;
								{ (cAlias)->B1_X_ERA, ; 
								  (cAlias)->SOMA } )
			
			aDados[02] += (cAlias)->SOMA
			
			(cAlias)->(DbSkip())
		EndDo
		
		nTotal := aDados[02]
		oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDados) )
		
	EndIf
	
	/* ------------------------------------------------------------------------ */
	
	_cQry := " WITH DADOS AS " + CRLF
	_cQry += " ( " + CRLF
	_cQry += "    SELECT B1_X_ERA, SUM(B2_QATU) SOMA " + CRLF
	_cQry += "    FROM " + RetSqlName('SB1') + " B1 " + CRLF
	_cQry += "    LEFT JOIN " + RetSqlName('SB2') + " B2 ON B1_FILIAL='"+xFilial('SB1')+"' AND B2_FILIAL='"+xFilial('SB2')+"' AND B1_COD=B2_COD AND B1_GRUPO='BOV' 
	//AND B2_QATU>0 
	_cQry += "  		AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	  LEFT JOIN Z08010 Z8 ON Z08_FILIAL=' ' AND RTRIM(UPPER(Z08_CODIGO))=RTRIM(UPPER(B1_X_CURRA)) AND Z8.D_E_L_E_T_=' '  " + CRLF
	_cQry += "    LEFT JOIN " + RetSqlName('Z09') + " Z9 ON Z09_FILIAL='"+xFilial('Z09')+"' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' ' " + CRLF
	_cQry += "    WHERE Z08_TIPO = '4' " + CRLF
	_cQry += "    GROUP BY B1_X_ERA " + CRLF
	_cQry += " ), " + CRLF
	_cQry += "  " + CRLF
 	_cQry += " RESULTADO AS  " + CRLF
 	_cQry += " ( " + CRLF
	_cQry += " 	 SELECT  B1_X_ERA, SUM(SOMA) SOMA  " + CRLF
	_cQry += " 	 FROM DADOS  " + CRLF
	_cQry += " 	 GROUP BY B1_X_ERA  " + CRLF
	_cQry += " ) " + CRLF
	_cQry += "  " + CRLF
	_cQry += " SELECT *  " + CRLF
	_cQry += " FROM RESULTADO " + CRLF
	_cQry += " WHERE SOMA > 0 " 
	// _cQry := ChangeQuery(_cQry)
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	If cUserName == 'mbernardo'
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro2-2.sql" , _cQry)
	EndIf	
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry),(cAlias),.F.,.F.) 
	
	If (cAlias)->(Eof())
		MsgAlert("Não foi localizado informacao para o Quadro 1: Lista-Tipo1" )
	Else
		oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )

		oExcel:AddRow( cWorkSheet, cTitulo, {"Tipo 4", ""} )
		oExcel:AddRow( cWorkSheet, cTitulo, {"Era", "Qt. Cabeças"} )
   		aDados[02] := 0
		
		While !(cAlias)->(Eof())
			
			oExcel:AddRow( cWorkSheet, cTitulo, ;
								{ (cAlias)->B1_X_ERA, ; 
								  (cAlias)->SOMA } )
			
			aDados[02] += (cAlias)->SOMA
			
			(cAlias)->(DbSkip())
		EndDo
		
		oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDados) )
		oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )

		aDados[01] := "Total Geral"
		aDados[02] += nTotal
		oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDados) )
	EndIf

Else //  dDTReferencia <> dToS(dDataBase)

	aSort(aDadTp1,,,{|x,y| x[5] < y[5] })
	aSort(aDadTp4,,,{|x,y| x[5] < y[5] })
	
	aDados[02]  := 0
	nTotal		:= 0
	cAgrupa 	:= aDadTp1[1, 5]
	For nI := 1 to Len(aDadTp1)
	
		If cAgrupa <> aDadTp1[nI, 5]
			oExcel:AddRow( cWorkSheet, cTitulo, { cAgrupa, aDados[02] } )
			aDados[02] := 0
			cAgrupa    := aDadTp1[ nI, 05]
		EndIf
		
		aDados[02]  += aDadTp1[nI, 06]
		nTotal  	+= aDadTp1[nI, 06]
	Next nI
	oExcel:AddRow( cWorkSheet, cTitulo, { cAgrupa, aDados[02] } )
	oExcel:AddRow( cWorkSheet, cTitulo, { ""     , nTotal     } )
	nTotalT := nTotal
	
	// imprimir Quadro 2 : Tipo 4
	aDados 	 := Array(2)
	oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
	oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
	oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )

	oExcel:AddRow( cWorkSheet, cTitulo, {"Tipo 4", ""} )
	oExcel:AddRow( cWorkSheet, cTitulo, {"Era", "Qt. Cabeças"} )
	
	aDados[02]  := 0
	nTotal		:= 0
	cAgrupa 	:= aDadTp4[1, 5]
	For nI := 1 to Len(aDadTp4)
	
		If cAgrupa <> aDadTp4[nI, 5]
			oExcel:AddRow( cWorkSheet, cTitulo, { cAgrupa, aDados[02] } )
			aDados[02] := 0
			cAgrupa    := aDadTp4[nI, 05]
		EndIf	
		
		aDados[02]  += aDadTp4[nI, 06]
		nTotal  	+= aDadTp4[nI, 06]
	Next nI
	oExcel:AddRow( cWorkSheet, cTitulo, { cAgrupa, aDados[02] } )
	oExcel:AddRow( cWorkSheet, cTitulo, { ""     , nTotal     } )

	aDados 	 := Array(2)
	aDados[01] := "Total Geral"
	aDados[02] := nTotalT + nTotal
	oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDados) )
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
Static Function fQuadro3( aLinVazia )

Local _cQry      := ""
// Local cAlias     := CriaTrab(,.F.)   
Local cWorkSheet := "Lista Currais Vazios"

Local aDados 	 := Array(1)

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)

	// _cQry := " SELECT DISTINCT UPPER(Z08_CODIGO) Z08_CODIGO  " + CRLF
	// _cQry += " FROM " + RetSqlName('Z08') + CRLF
	// _cQry += " WHERE " + CRLF
	// _cQry += " 	   Z08_FILIAL='"+xFilial('Z08')+"' " + CRLF
	// _cQry += " AND UPPER(Z08_CODIGO) NOT IN " + CRLF
	// _cQry += " ( " + CRLF
				// // 	Linhas ocupadas
	// _cQry += " 	SELECT DISTINCT UPPER(B1_X_CURRA) " + CRLF
	// _cQry += "    FROM " + RetSqlName('SB1') + " B1 " + CRLF
	// _cQry += "    LEFT JOIN " + RetSqlName('SB2') + " B2 ON B1_FILIAL='"+xFilial('SB1')+"' AND B2_FILIAL='"+xFilial('SB2')+"' AND B1_COD=B2_COD AND B1_GRUPO='BOV' 
	// //AND B2_QATU>0 
	// _cQry += "  		AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' ' " + CRLF
	// _cQry += "    LEFT JOIN " + RetSqlName('Z09') + " Z9 ON Z09_FILIAL='"+xFilial('Z09')+"' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' ' " + CRLF
	// _cQry += " ) " + CRLF
	// _cQry += " AND Z08_TIPO='1' " + CRLF
	// _cQry += " AND D_E_L_E_T_=' ' " + CRLF
	// _cQry += " ORDER BY 1 "
	// // _cQry := ChangeQuery(_cQry)
	
	// If Select(cAlias) > 0
		// (cAlias)->(DbCloseArea())
	// EndIf
	// If cUserName == 'mbernardo'
		// MemoWrite(StrTran(cArquivo,".xml","")+"Quadro3.sql" , _cQry)
	// EndIf	
	// dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry),(cAlias),.F.,.F.) 
	
	// If !(cAlias)->(Eof())
	
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
Static Function fQuadro4( dDTReferencia ) // (nAgrup)

Local _cQry      := ""
Local cAlias     := CriaTrab(,.F.)   
Local cWorkSheet := "Lista Pastos"
Local nQATU		 := 0

Local aDados 	 := Array(14)
Local cAgrupa    := ""

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)

	_cQry := "  WITH GERAL AS ( " + CRLF
	_cQry += "  	SELECT  B1_XANIMAL, IDADE_ATUAL, ORDEM, B1_COD, B1_X_CURRA, B1_XLOTE, B1_X_ERA, B2_LOCAL, B2_QATU, B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO,  " + CRLF
	_cQry += "  		Z09_GMDESP, B1_XDATACO, DiasAbate, Dias, PesoAtual, PrjecAba, Z09_RENESP, " + CRLF
	_cQry += " 		CASE" + CRLF
	_cQry += " 			WHEN DiasAbate > Dias" + CRLF
	_cQry += " 			THEN PesoFinal" + CRLF
	_cQry += " 			ELSE (DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+Dias))*Z09_GMDESP)+B1_XPESOCO  " + CRLF
	_cQry += " 		END PesoFinal," + CRLF
	_cQry += " 		CASE" + CRLF
	_cQry += " 			WHEN DiasAbate > Dias" + CRLF
	_cQry += " 			THEN PesoFinalTOTAL" + CRLF
	_cQry += " 			ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+Dias))*Z09_GMDESP)+B1_XPESOCO)*B2_QATU " + CRLF
	_cQry += " 		END PesoFinalTOTAL," + CRLF
	_cQry += " 		CASE" + CRLF
	_cQry += " 			WHEN DiasAbate > Dias" + CRLF
	_cQry += " 			THEN PesoCarcacaFinal" + CRLF
	_cQry += " 			ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+Dias))*Z09_GMDESP)+B1_XPESOCO)*(Z09_RENESP/100) " + CRLF
	_cQry += " 		END PesoCarcacaFinal, " + CRLF
	_cQry += " 		SubString(PrjecAba,1,6) GRUPO2 FROM  " + CRLF
	_cQry += "  ( " + CRLF
	_cQry += "  		SELECT DISTINCT B1_XANIMAL, DATEDIFF(MONTH, CONVERT(DATETIME, B1_DTNASC, 103), CONVERT(DATETIME, '"+dDTReferencia+"', 103)) IDADE_ATUAL, " + CRLF
	_cQry += "  		ISNULL(Z08_TIPO+Z08_LINHA+Z08_SEQUEN,9999) ORDEM,  " + CRLF
	_cQry += "  		B1_COD,  " + CRLF
	_cQry += "  		CASE B1_X_CURRA " + CRLF
	_cQry += "  			WHEN ' '  " + CRLF
	_cQry += "  				THEN 'SEM CLASSIFICAÇÃO'  " + CRLF
	_cQry += "  				ELSE B1_X_CURRA  " + CRLF
	_cQry += "  		END B1_X_CURRA,  " + CRLF
	_cQry += "  		B1_XLOTE, B1_X_ERA, B2_LOCAL, B2_QATU, B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO,  " + CRLF
	_cQry += "  		Z09_GMDESP,  " + CRLF
	_cQry += " 		B1_XDATACO," + CRLF
	_cQry += " 		100 as 'DiasAbate',  " + CRLF
	_cQry += " 		CASE B1_XDATACO " + CRLF
	_cQry += "  			WHEN ' ' THEN 0 " + CRLF
	_cQry += "  			ELSE DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '"+dDTReferencia+"', 103))  " + CRLF
	_cQry += "  		END AS Dias,  " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE (DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '"+dDTReferencia+"', 103))*Z09_GMDESP)+B1_XPESOCO  " + CRLF
	_cQry += "  		END PesoAtual, " + CRLF
	_cQry += "  		CASE B1_XDATACO " + CRLF
	_cQry += "  			WHEN ' ' THEN ' ' " + CRLF
	_cQry += " 			ELSE CONVERT( VARCHAR, CONVERT(DATETIME, B1_XDATACO, 103)+100, 112) " + CRLF
	_cQry += "  		END 'PrjecAba',  " + CRLF
	_cQry += "  		Z09_RENESP, " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE (DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+100))*Z09_GMDESP)+B1_XPESOCO  " + CRLF
	_cQry += "  		END PesoFinal, " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+100))*Z09_GMDESP)+B1_XPESOCO)*B2_QATU " + CRLF
	_cQry += "  		END PesoFinalTOTAL, " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+100))*Z09_GMDESP)+B1_XPESOCO)*(Z09_RENESP/100) " + CRLF
	_cQry += "  		END PesoCarcacaFinal " + CRLF
	_cQry += "  		FROM SB1010 B1 " + CRLF
	_cQry += "  		LEFT JOIN SB2010 B2 ON B1_FILIAL='  ' AND B2_FILIAL='01' AND B1_COD=B2_COD  " + CRLF
	//AND B2_QATU>0 
	_cQry += "  		AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '  " + CRLF
	_cQry += "  		LEFT JOIN Z08010 Z8 ON Z08_FILIAL=' ' AND RTRIM(UPPER(Z08_CODIGO))=RTRIM(UPPER(B1_X_CURRA)) AND Z8.D_E_L_E_T_=' '  " + CRLF
	_cQry += "  		LEFT JOIN Z09010 Z9 ON Z09_FILIAL=' ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '  " + CRLF
	_cQry += "  		WHERE B1_GRUPO='BOV' AND Z08_TIPO = '4' " + CRLF
	_cQry += "  ) AS BYPASTO " + CRLF
//	_cQry += " WHERE Dias >= 0 " + CRLF
	_cQry += " ), " + CRLF
	_cQry += "  " + CRLF
	_cQry += " ERA_ATUALIZADA AS " + CRLF
	_cQry += " ( " + CRLF
	_cQry += " 	SELECT DISTINCT B1_COD, Z09_DESCRI " + CRLF
	_cQry += " 	FROM GERAL G " + CRLF
	_cQry += " 	LEFT JOIN Z09010 Z9 ON Z09_FILIAL=' ' AND B1_XANIMAL=Z09_CODIGO AND Z9.D_E_L_E_T_=' '   " + CRLF
	_cQry += " 	WHERE IDADE_ATUAL BETWEEN Z09_IDAINI AND Z09_IDAFIM  " + CRLF
	_cQry += " ) " + CRLF
	_cQry += "  " + CRLF
	_cQry += " SELECT " + CRLF
	_cQry += " 		G.B1_COD, B1_X_CURRA, B1_XLOTE, " + CRLF
	_cQry += " 		ISNULL(Z09_DESCRI,'SEM CLASSIFICAÇÃO') B1_X_ERA, B2_LOCAL, B2_QATU, B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO,   " + CRLF
	_cQry += "   		Z09_GMDESP, B1_XDATACO, DiasAbate, Dias, PesoAtual, PrjecAba, Z09_RENESP,  " + CRLF
	_cQry += " 		PesoFinal, " + CRLF
	_cQry += "  		PesoFinalTOTAL, " + CRLF
	_cQry += "  		PesoCarcacaFinal, " + CRLF
	_cQry += "  		SubString(PrjecAba,1,6) GRUPO2 " + CRLF
	_cQry += " FROM GERAL G " + CRLF
	_cQry += " LEFT JOIN ERA_ATUALIZADA E ON G.B1_COD=E.B1_COD " + CRLF
	_cQry += " ORDER BY " + CRLF	
	_cQry += " ORDEM "
	// _cQry := ChangeQuery(_cQry)

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	If cUserName == 'mbernardo'
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro4.sql" , _cQry)
	EndIf	
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "B1_XDATACO", "D")
	TcSetField(cAlias, "PrjecAba"  , "D")
	
	If (cAlias)->(Eof())
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
		/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observação"         , 1, 1 )
		
		aDados[02]  := 0
		aDados[06]  := 0
		
		cAgrupa := (cAlias)->GRUPO2
		
		While !(cAlias)->(Eof())
			
			nQATU := Iif(dDTReferencia == dToS(dDataBase), (cAlias)->B2_QATU, CalcEst( (cAlias)->B1_COD, (cAlias)->B2_LOCAL, sToD(dDTReferencia)+1)[1] )
			If nQATU <> 0
				
				oExcel:AddRow( cWorkSheet, cTitulo, ;
								{ (cAlias)->B1_COD, ;
								  (cAlias)->B1_X_CURRA, ;
								  (cAlias)->B1_XLOTE, ;
								  (cAlias)->B1_XDATACO, ;
								  (cAlias)->B1_X_ERA, ;
								  nQATU, ;
								  (cAlias)->B1_XPESOCO, ;
								  (cAlias)->B1_XLOTCOM, ;
								  (cAlias)->B1_XRACA, ;
								  (cAlias)->B1_X_SEXO, ;
								  (cAlias)->Dias, ;
								  (cAlias)->Z09_GMDESP, ;
								  (cAlias)->PesoAtual, ;
								  PegaOBSB1((cAlias)->B1_COD) } )

				aAdd( aDadTp4, { (cAlias)->B1_COD, ;
								 (cAlias)->B1_X_CURRA, ;
								 (cAlias)->B1_XLOTE, ;
								 (cAlias)->B1_XDATACO, ;
								 (cAlias)->B1_X_ERA, ;
								 nQATU, ;
								 (cAlias)->B1_XPESOCO, ;
								 (cAlias)->B1_XLOTCOM, ;
								 (cAlias)->B1_XRACA, ;
								 (cAlias)->B1_X_SEXO, ;
								 (cAlias)->Dias, ;
								 (cAlias)->Z09_GMDESP, ;
								 (cAlias)->PesoAtual } )
								  
				aDados[02] += 1		           // Curral : Qtde de registros
				aDados[06] += nQATU // Qtde

			EndIf
			(cAlias)->(DbSkip())
		EndDo

		//oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, aDados )
		
	EndIf

Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  09.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function PegaOBSB1(cCodigo)
Local aArea := GetArea()
Local cRet  := ""

SB1->(DbSetOrder(1))
if SB1->(DbSeek( xFilial('SB1')+cCodigo ))
	If !Empty(SB1->B1_X_OBS)
		cRet := AllTrim( SB1->B1_X_OBS)
	EndIf
EndIf

RestArea(aArea)
Return OemToAnsi(cRet)

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

Local aDados 	 := Array(21)
// Local aDadosA 	 := Array(21)
// Local cAgrupa    := ""
Local nQATU		 := 0

Local aPrintSD3  := {}

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)

	_cQry := "  WITH GERAL AS ( " + CRLF
	_cQry += "  	SELECT  B1_XANIMAL, IDADE_ATUAL, ORDEM, B1_COD, B1_X_CURRA, B1_XLOTE, B1_X_ERA, B2_LOCAL, B2_QATU, B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO,  " + CRLF
	_cQry += "  		Z09_GMDESP, B1_XDATACO, DiasAbate, Dias, PesoAtual, PrjecAba, Z09_RENESP, " + CRLF
	_cQry += " 		CASE" + CRLF
	_cQry += " 			WHEN DiasAbate > Dias" + CRLF
	_cQry += " 			THEN PesoFinal" + CRLF
	_cQry += " 			ELSE (DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+Dias))*Z09_GMDESP)+B1_XPESOCO  " + CRLF
	_cQry += " 		END PesoFinal," + CRLF
	_cQry += " 		CASE" + CRLF
	_cQry += " 			WHEN DiasAbate > Dias" + CRLF
	_cQry += " 			THEN PesoFinalTOTAL" + CRLF
	_cQry += " 			ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+Dias))*Z09_GMDESP)+B1_XPESOCO)*B2_QATU " + CRLF
	_cQry += " 		END PesoFinalTOTAL," + CRLF
	_cQry += " 		CASE" + CRLF
	_cQry += " 			WHEN DiasAbate > Dias" + CRLF
	_cQry += " 			THEN PesoCarcacaFinal" + CRLF
	_cQry += " 			ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+Dias))*Z09_GMDESP)+B1_XPESOCO)*(Z09_RENESP/100) " + CRLF
	_cQry += " 		END PesoCarcacaFinal,  " + CRLF
	_cQry += " 		SubString(PrjecAba,1,6) GRUPO2 FROM  " + CRLF
	_cQry += "  ( " + CRLF
	_cQry += "  		SELECT DISTINCT B1_XANIMAL, DATEDIFF(MONTH, CONVERT(DATETIME, B1_DTNASC, 103), CONVERT(DATETIME, '"+dDTReferencia+"', 103)) IDADE_ATUAL, " + CRLF
	_cQry += "  		ISNULL(Z08_TIPO+Z08_LINHA+Z08_SEQUEN,9999) ORDEM,  " + CRLF
	_cQry += "  		B1_COD,  " + CRLF
	_cQry += "  		CASE B1_X_CURRA " + CRLF
	_cQry += "  			WHEN ' '  " + CRLF
	_cQry += "  				THEN 'SEM CLASSIFICAÇÃO'  " + CRLF
	_cQry += "  				ELSE B1_X_CURRA  " + CRLF
	_cQry += "  		END B1_X_CURRA,  " + CRLF
	_cQry += "  		B1_XLOTE, B1_X_ERA, B2_LOCAL, B2_QATU, B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO,  " + CRLF
	_cQry += "  		Z09_GMDESP,  " + CRLF
	_cQry += " 		B1_XDATACO," + CRLF
	_cQry += " 		"+cDiasAb+" AS DiasAbate," + CRLF
	_cQry += " 		CASE B1_XDATACO " + CRLF
	_cQry += "  			WHEN ' ' THEN 0 " + CRLF
	_cQry += "  			ELSE DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '"+dDTReferencia+"', 103))  " + CRLF
	_cQry += "  		END AS Dias,  " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE (DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '"+dDTReferencia+"', 103))*Z09_GMDESP)+B1_XPESOCO  " + CRLF
	_cQry += "  		END PesoAtual, " + CRLF
	_cQry += "  		CASE B1_XDATACO " + CRLF
	_cQry += "  			WHEN ' ' THEN ' ' " + CRLF
	_cQry += "  			ELSE CONVERT( VARCHAR, CONVERT(DATETIME, B1_XDATACO, 103)+"+cDiasAb+", 112) " + CRLF
	_cQry += "  		END 'PrjecAba',  " + CRLF
	_cQry += "  		Z09_RENESP, " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE (DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+"+cDiasAb+"))*Z09_GMDESP)+B1_XPESOCO  " + CRLF
	_cQry += "  		END PesoFinal, " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+"+cDiasAb+"))*Z09_GMDESP)+B1_XPESOCO)*B2_QATU " + CRLF
	_cQry += "  		END PesoFinalTOTAL, " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+"+cDiasAb+"))*Z09_GMDESP)+B1_XPESOCO)*(Z09_RENESP/100) " + CRLF
	_cQry += "  		END PesoCarcacaFinal " + CRLF
	_cQry += "  		FROM SB1010 B1  " + CRLF
	_cQry += "  		LEFT JOIN SB2010 B2 ON B1_FILIAL='  ' AND B2_FILIAL='01' AND B1_COD=B2_COD  " + CRLF
	//AND B2_QATU>0 
	_cQry += "  		AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '  " + CRLF
	_cQry += "  		LEFT JOIN Z08010 Z8 ON Z08_FILIAL=' ' AND RTRIM(UPPER(Z08_CODIGO))=RTRIM(UPPER(B1_X_CURRA)) AND Z8.D_E_L_E_T_=' '  " + CRLF
	_cQry += "  		LEFT JOIN Z09010 Z9 ON Z09_FILIAL=' ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '  " + CRLF
	_cQry += "  		WHERE B1_GRUPO='BOV' AND ISNULL(Z08_TIPO,'1') = '1' " + CRLF
	_cQry += "  ) AS BYPASTO " + CRLF
//	_cQry += " WHERE Dias >= 0 " + CRLF
	_cQry += " ), " + CRLF
	_cQry += "  " + CRLF
	_cQry += " ERA_ATUALIZADA AS " + CRLF
	_cQry += " ( " + CRLF
	_cQry += " 	SELECT DISTINCT B1_COD, Z09_DESCRI " + CRLF
	_cQry += " 	FROM GERAL G " + CRLF
	_cQry += " 	LEFT JOIN Z09010 Z9 ON Z09_FILIAL=' ' AND B1_XANIMAL=Z09_CODIGO AND Z9.D_E_L_E_T_=' '   " + CRLF
	_cQry += " 	WHERE IDADE_ATUAL BETWEEN Z09_IDAINI AND Z09_IDAFIM  " + CRLF
	_cQry += " ) " + CRLF
	_cQry += "  " + CRLF
	_cQry += " SELECT  " + CRLF
	_cQry += " 		G.B1_COD, B1_X_CURRA, B1_XLOTE, " + CRLF
	_cQry += " 		ISNULL(Z09_DESCRI,'SEM CLASSIFICAÇÃO') B1_X_ERA, B2_LOCAL, B2_QATU, B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO,   " + CRLF
	_cQry += "   		Z09_GMDESP, B1_XDATACO, DiasAbate, Dias, PesoAtual, PrjecAba, Z09_RENESP,  " + CRLF
	_cQry += " 		PesoFinal, " + CRLF
	_cQry += "  		PesoFinalTOTAL, " + CRLF
	_cQry += "  		PesoCarcacaFinal, " + CRLF
	_cQry += "  		SubString(PrjecAba,1,6) GRUPO2 " + CRLF
	_cQry += " FROM GERAL G " + CRLF    
	_cQry += " LEFT JOIN ERA_ATUALIZADA E ON G.B1_COD=E.B1_COD " + CRLF
	// _cQry += " WHERE G.B1_COD IN ('BOV000000000166               ','BOV000000000191               ','BOV000000000035               ','BOV000000000293               ','BOV000000000294               ','BOV000000000295               ','BOV000000000298               ') " + CRLF
	_cQry += " ORDER BY " + CRLF	
	
	// If nAgrup == 2
		// _cQry += " PrjecAba, " + CRLF
	// EndIf
	_cQry += " ORDEM "
	// _cQry := ChangeQuery(_cQry)

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	If cUserName == 'mbernardo'
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro5.sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "B1_XDATACO", "D")
	TcSetField(cAlias, "PrjecAba"  , "D")
	
	If !(cAlias)->(Eof())
		
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
		/* 21 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observação" 		 , 1, 1 )
		
		aDados[02]  := 0
		aDados[06]  := 0
		aDados[07]  := 0
		aDados[19]  := 0
		// aDadosA[02] := 0
		// aDadosA[06] := 0
		// aDadosA[07] := 0
		// aDadosA[19] := 0
		
		// cAgrupa := (cAlias)->GRUPO2
		
		// aSaldos := CalcEst( "BOV000000000003", "01" , StoD("20170101")  )		
		While !(cAlias)->(Eof())
		
			// If nAgrup == 2
				// If cAgrupa <> (cAlias)->GRUPO2 .and. aDadosA[07] <> 0
					// oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDadosA) )
					// oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
					// oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
					
					// aDadosA[02] := 0
					// aDadosA[06] := 0
					// aDadosA[07] := 0
					// aDadosA[19] := 0
				// EndIf
			// EndIf
			
			nQATU := Iif(dDTReferencia == dToS(dDataBase), (cAlias)->B2_QATU, CalcEst( (cAlias)->B1_COD, (cAlias)->B2_LOCAL, sToD(dDTReferencia)+1)[1] )
			nQATUMOV := Iif(dDtMoviment == dDTReferencia, nQATU, CalcEst( (cAlias)->B1_COD, (cAlias)->B2_LOCAL, sToD(dDtMoviment))[1] )
			If nQATU <> 0
				
				If Len( aPrintSD3 := PrintSD3(cWorkSheet, (cAlias)->B1_COD, Len(aDados), dDTReferencia, dDtMoviment ) ) > 0
				
					oExcel:AddRow( cWorkSheet, cTitulo, ;
									{ (cAlias)->B1_COD, ;
									  (cAlias)->B1_X_CURRA, ;
									  (cAlias)->B1_XLOTE, ;
									  (cAlias)->B1_XDATACO, ;
									  (cAlias)->B1_X_ERA, ;
									  nQATUMOV , ;
									  nQATU , ;
									  (cAlias)->B1_XPESOCO, ;
									  (cAlias)->B1_XLOTCOM, ;
									  (cAlias)->B1_XRACA, ;
									  (cAlias)->B1_X_SEXO, ;
									  (cAlias)->Dias, ;
									  (cAlias)->Z09_GMDESP, ;
									  (cAlias)->PesoAtual, ;
									  (cAlias)->DiasAbate, ;
									  (cAlias)->PrjecAba, ;
									  (cAlias)->Z09_RENESP, ;
									  (cAlias)->PesoFinal, ;
									  (cAlias)->PesoFinalTOTAL, ;
									  (cAlias)->PesoCarcacaFinal, ;
									  PegaOBSB1((cAlias)->B1_COD) } )
							
					For nI := 1 to Len(aPrintSD3)
						oExcel:AddRow( cWorkSheet, cTitulo, aPrintSD3[nI] )
					Next nI
				EndIf	  
				
								  
				// If nAgrup == 2
					// cAgrupa := (cAlias)->GRUPO2
					
					// aDadosA[02] += 1		           // Curral : Qtde de registros
					// aDadosA[06] += nQATUMOV // Qtde
					// aDadosA[07] += nQATU // Qtde
					// aDadosA[19] += (cAlias)->PesoFinalTOTAL // Qtde
				// EndIf

				aDados[02] += 1		           // Curral : Qtde de registros
				aDados[06] += nQATUMOV // Qtde
				aDados[07] += nQATU // Qtde
				aDados[19] += (cAlias)->PesoFinalTOTAL // Qtde
				
			EndIf
			
			(cAlias)->(DbSkip())
		EndDo

		// oExcel:AddRow( cWorkSheet, cTitulo, aClone(aDadosA) )

		// oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, aDados )
		
	EndIf

Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  14.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro6( dDTReferencia, dDtMoviment )

Local _cQry      := ""
Local cAlias     := CriaTrab(,.F.)   
Local cWorkSheet := "Lista Pastos-Movimentação"
Local nQATU		 := 0

Local aDados 	 := Array(15)
// Local cAgrupa    := ""

oExcel:AddworkSheet(cWorkSheet) 
oExcel:AddTable(cWorkSheet, cTitulo)

	_cQry := "  WITH GERAL AS ( " + CRLF
	_cQry += "  	SELECT  B1_XANIMAL, IDADE_ATUAL, ORDEM, B1_COD, B1_X_CURRA, B1_XLOTE, B1_X_ERA, B2_LOCAL, B2_QATU, B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO,  " + CRLF
	_cQry += "  		Z09_GMDESP, B1_XDATACO, DiasAbate, Dias, PesoAtual, PrjecAba, Z09_RENESP, " + CRLF
	_cQry += " 		CASE" + CRLF
	_cQry += " 			WHEN DiasAbate > Dias" + CRLF
	_cQry += " 			THEN PesoFinal" + CRLF
	_cQry += " 			ELSE (DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+Dias))*Z09_GMDESP)+B1_XPESOCO  " + CRLF
	_cQry += " 		END PesoFinal," + CRLF
	_cQry += " 		CASE" + CRLF
	_cQry += " 			WHEN DiasAbate > Dias" + CRLF
	_cQry += " 			THEN PesoFinalTOTAL" + CRLF
	_cQry += " 			ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+Dias))*Z09_GMDESP)+B1_XPESOCO)*B2_QATU " + CRLF
	_cQry += " 		END PesoFinalTOTAL," + CRLF
	_cQry += " 		CASE" + CRLF
	_cQry += " 			WHEN DiasAbate > Dias" + CRLF
	_cQry += " 			THEN PesoCarcacaFinal" + CRLF
	_cQry += " 			ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+Dias))*Z09_GMDESP)+B1_XPESOCO)*(Z09_RENESP/100) " + CRLF
	_cQry += " 		END PesoCarcacaFinal, " + CRLF
	_cQry += " 		SubString(PrjecAba,1,6) GRUPO2 FROM  " + CRLF
	_cQry += "  ( " + CRLF
	_cQry += "  		SELECT DISTINCT B1_XANIMAL, DATEDIFF(MONTH, CONVERT(DATETIME, B1_DTNASC, 103), CONVERT(DATETIME, '"+dDTReferencia+"', 103)) IDADE_ATUAL, " + CRLF
	_cQry += "  		ISNULL(Z08_TIPO+Z08_LINHA+Z08_SEQUEN,9999) ORDEM,  " + CRLF
	_cQry += "  		B1_COD,  " + CRLF
	_cQry += "  		CASE B1_X_CURRA " + CRLF
	_cQry += "  			WHEN ' '  " + CRLF
	_cQry += "  				THEN 'SEM CLASSIFICAÇÃO'  " + CRLF
	_cQry += "  				ELSE B1_X_CURRA  " + CRLF
	_cQry += "  		END B1_X_CURRA,  " + CRLF
	_cQry += "  		B1_XLOTE, B1_X_ERA, B2_LOCAL, B2_QATU, B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO,  " + CRLF
	_cQry += "  		Z09_GMDESP,  " + CRLF
	_cQry += " 		B1_XDATACO," + CRLF
	_cQry += " 		100 as 'DiasAbate',  " + CRLF
	_cQry += " 		CASE B1_XDATACO " + CRLF
	_cQry += "  			WHEN ' ' THEN 0 " + CRLF
	_cQry += "  			ELSE DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '"+dDTReferencia+"', 103))  " + CRLF
	_cQry += "  		END AS Dias,  " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE (DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '"+dDTReferencia+"', 103))*Z09_GMDESP)+B1_XPESOCO  " + CRLF
	_cQry += "  		END PesoAtual, " + CRLF
	_cQry += "  		CASE B1_XDATACO " + CRLF
	_cQry += "  			WHEN ' ' THEN ' ' " + CRLF
	_cQry += " 			ELSE CONVERT( VARCHAR, CONVERT(DATETIME, B1_XDATACO, 103)+100, 112) " + CRLF
	_cQry += "  		END 'PrjecAba',  " + CRLF
	_cQry += "  		Z09_RENESP, " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE (DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+100))*Z09_GMDESP)+B1_XPESOCO  " + CRLF
	_cQry += "  		END PesoFinal, " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+100))*Z09_GMDESP)+B1_XPESOCO)*B2_QATU " + CRLF
	_cQry += "  		END PesoFinalTOTAL, " + CRLF
	_cQry += "  		CASE B1_XPESOCO " + CRLF
	_cQry += "  		  WHEN 0 THEN 0 " + CRLF
	_cQry += "  		  ELSE ((DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), (CONVERT(DATETIME, B1_XDATACO, 103)+100))*Z09_GMDESP)+B1_XPESOCO)*(Z09_RENESP/100) " + CRLF
	_cQry += "  		END PesoCarcacaFinal " + CRLF
	_cQry += "  		FROM SB1010 B1 " + CRLF
	_cQry += "  		LEFT JOIN SB2010 B2 ON B1_FILIAL='  ' AND B2_FILIAL='01' AND B1_COD=B2_COD  " + CRLF
	//AND B2_QATU>0 
	_cQry += "  		AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '  " + CRLF
	_cQry += "  		LEFT JOIN Z08010 Z8 ON Z08_FILIAL=' ' AND RTRIM(UPPER(Z08_CODIGO))=RTRIM(UPPER(B1_X_CURRA)) AND Z8.D_E_L_E_T_=' '  " + CRLF
	_cQry += "  		LEFT JOIN Z09010 Z9 ON Z09_FILIAL=' ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '  " + CRLF
	_cQry += "  		WHERE B1_GRUPO='BOV' AND Z08_TIPO = '4' " + CRLF
	_cQry += "  ) AS BYPASTO " + CRLF
//	_cQry += " WHERE Dias >= 0 " + CRLF
	_cQry += " ), " + CRLF
	_cQry += "  " + CRLF
	_cQry += " ERA_ATUALIZADA AS " + CRLF
	_cQry += " ( " + CRLF
	_cQry += " 	SELECT DISTINCT B1_COD, Z09_DESCRI " + CRLF
	_cQry += " 	FROM GERAL G " + CRLF
	_cQry += " 	LEFT JOIN Z09010 Z9 ON Z09_FILIAL=' ' AND B1_XANIMAL=Z09_CODIGO AND Z9.D_E_L_E_T_=' '   " + CRLF
	_cQry += " 	WHERE IDADE_ATUAL BETWEEN Z09_IDAINI AND Z09_IDAFIM  " + CRLF
	_cQry += " ) " + CRLF
	_cQry += "  " + CRLF
	_cQry += " SELECT " + CRLF
	_cQry += " 		G.B1_COD, B1_X_CURRA, B1_XLOTE, " + CRLF
	_cQry += " 		ISNULL(Z09_DESCRI,'SEM CLASSIFICAÇÃO') B1_X_ERA, B2_LOCAL, B2_QATU, B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO,   " + CRLF
	_cQry += "   		Z09_GMDESP, B1_XDATACO, DiasAbate, Dias, PesoAtual, PrjecAba, Z09_RENESP,  " + CRLF
	_cQry += " 		PesoFinal, " + CRLF
	_cQry += "  		PesoFinalTOTAL, " + CRLF
	_cQry += "  		PesoCarcacaFinal, " + CRLF
	_cQry += "  		SubString(PrjecAba,1,6) GRUPO2 " + CRLF
	_cQry += " FROM GERAL G " + CRLF
	_cQry += " LEFT JOIN ERA_ATUALIZADA E ON G.B1_COD=E.B1_COD " + CRLF
	_cQry += " ORDER BY " + CRLF	
	_cQry += " ORDEM "
	// _cQry := ChangeQuery(_cQry)

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	If cUserName == 'mbernardo'
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro6.sql" , _cQry)
	EndIf	
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "B1_XDATACO", "D")
	TcSetField(cAlias, "PrjecAba"  , "D")
	
	If (cAlias)->(Eof())
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
		/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observação"         , 1, 1 )
		
		aDados[02]  := 0
		aDados[06]  := 0
		aDados[07]  := 0
		
		cAgrupa := (cAlias)->GRUPO2
		
		While !(cAlias)->(Eof())
			
			nQATU := Iif(dDTReferencia == dToS(dDataBase), (cAlias)->B2_QATU, CalcEst( (cAlias)->B1_COD, (cAlias)->B2_LOCAL, sToD(dDTReferencia)+1)[1] )
			nQATUMOV := Iif(dDtMoviment == dDTReferencia, nQATU, CalcEst( (cAlias)->B1_COD, (cAlias)->B2_LOCAL, sToD(dDtMoviment))[1] )
			If nQATU <> 0

				If Len( aPrintSD3 := PrintSD3(cWorkSheet, (cAlias)->B1_COD, Len(aDados), dDTReferencia, dDtMoviment ) ) > 0
				
					oExcel:AddRow( cWorkSheet, cTitulo, ;
									{ (cAlias)->B1_COD, ;
									  (cAlias)->B1_X_CURRA, ;
									  (cAlias)->B1_XLOTE, ;
									  (cAlias)->B1_XDATACO, ;
									  (cAlias)->B1_X_ERA, ;
									  nQATUMOV, ;
									  nQATU, ;
									  (cAlias)->B1_XPESOCO, ;
									  (cAlias)->B1_XLOTCOM, ;
									  (cAlias)->B1_XRACA, ;
									  (cAlias)->B1_X_SEXO, ;
									  (cAlias)->Dias, ;
									  (cAlias)->Z09_GMDESP, ;
									  (cAlias)->PesoAtual, ;
									  PegaOBSB1((cAlias)->B1_COD) } )
									  
					For nI := 1 to Len(aPrintSD3)
						oExcel:AddRow( cWorkSheet, cTitulo, aPrintSD3[nI] )
					Next nI

				EndIf
								  
				aAdd( aDadTp4, { (cAlias)->B1_COD, ;
								 (cAlias)->B1_X_CURRA, ;
								 (cAlias)->B1_XLOTE, ;
								 (cAlias)->B1_XDATACO, ;
								 (cAlias)->B1_X_ERA, ;
								 nQATUMOV, ;
								 nQATU, ;
								 (cAlias)->B1_XPESOCO, ;
								 (cAlias)->B1_XLOTCOM, ;
								 (cAlias)->B1_XRACA, ;
								 (cAlias)->B1_X_SEXO, ;
								 (cAlias)->Dias, ;
								 (cAlias)->Z09_GMDESP, ;
								 (cAlias)->PesoAtual } )
								  
				aDados[02] += 1		           // Curral : Qtde de registros
				aDados[06] += nQATUMOV // Qtde
				aDados[07] += nQATU // Qtde

			EndIf
			(cAlias)->(DbSkip())
		EndDo

		//oExcel:AddRow( cWorkSheet, cTitulo, Array(Len(aDados)) )
		oExcel:AddRow( cWorkSheet, cTitulo, aDados )
		
	EndIf

Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  13.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function PrintSD3( cWorkSheet, cProduto, nQtCol, dDTReferencia, dDtMoviment )
Local aArea     := GetArea()
Local _cQry     := ""                                                  	
Local cAliasD3  := CriaTrab(,.F.)   
Local aAUXAlias := {}
Local aRet		:= {}
Local _aColunas := {}

_cQry := " SELECT D3_NUMSEQ NUMSEQ, D3_SEQCALC SEQ, D3_FILIAL, " + CRLF
_cQry += " CASE  " + CRLF
_cQry += " 	WHEN D3_TM < '500' " + CRLF
_cQry += " 	THEN 'ENTRADA' " + CRLF
_cQry += " 	ELSE 'SAIDA' " + CRLF
_cQry += " END TIPO_MOV, " + CRLF
_cQry += " CASE  " + CRLF
_cQry += " 	WHEN SUBSTRING(D3_CF,3,1) = '4'  " + CRLF
_cQry += " 		THEN 'TRANSFERENCIA' " + CRLF
_cQry += " 		ELSE F5_TEXTO " + CRLF
_cQry += " END MOTIVO,  " + CRLF
_cQry += " D3_TM, D3_COD, B1_DESC, B1_XLOTE, " + CRLF
_cQry += " D3_LOCAL, D3_GRUPO, D3_QUANT, D3_EMISSAO, D3_USUARIO, D3_X_OBS " + CRLF
_cQry += " FROM SD3010 D " + CRLF
_cQry += " LEFT JOIN SF5010 F ON F5_FILIAL=' ' AND F5_CODIGO=D3_TM AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' ' " + CRLF
_cQry += " JOIN SB1010 B ON B1_FILIAL=' ' AND B1_COD=D3_COD AND B.D_E_L_E_T_=' ' " + CRLF
_cQry += " WHERE D3_FILIAL <> ' ' " + CRLF
_cQry += "   AND D3_NUMSEQ IN (SELECT DISTINCT D3_NUMSEQ FROM SD3010 WHERE D3_FILIAL <> '  ' AND D3_COD='"+cProduto+"' AND D_E_L_E_T_=' ') " + CRLF
_cQry += "   AND D3_EMISSAO BETWEEN '"+dDtMoviment+"' AND '" + dDTReferencia +"' " + CRLF
_cQry += " AND (D3_TM <> '001' AND D3_GRUPO NOT IN ('02','03') AND (D3_TM <> '999' AND D3_CF <> 'RE')) " + CRLF
_cQry += "  " + CRLF
_cQry += " UNION ALL " + CRLF
_cQry += "  " + CRLF
_cQry += " SELECT D2_DOC+D2_SERIE, CONVERT(VARCHAR,D.R_E_C_N_O_), D2_FILIAL, 'SAIDA', 'VENDAS', '', D2_COD, B1_DESC, B1_XLOTE, D2_LOCAL, D2_GRUPO, D2_QUANT, D2_EMISSAO, '', '' " + CRLF
_cQry += " FROM SD2010 D " + CRLF
_cQry += " JOIN SB1010 B ON B1_FILIAL=' ' AND B1_COD=D2_COD AND B.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' ' " + CRLF
_cQry += " WHERE  " + CRLF
_cQry += " 	D2_FILIAL <> ' ' " + CRLF
_cQry += " AND D2_COD = '"+cProduto+"'  " + CRLF
_cQry += " AND D2_EMISSAO BETWEEN '"+dDtMoviment+"' AND '" + dDTReferencia +"' " + CRLF
_cQry += "  " + CRLF
_cQry += " UNION ALL " + CRLF
_cQry += "  " + CRLF
_cQry += " SELECT D1_DOC+D1_SERIE, CONVERT(VARCHAR,D.R_E_C_N_O_), D1_FILIAL, 'ENTRADA', 'COMPRAS', '', D1_COD, B1_DESC, B1_XLOTE, D1_LOCAL, D1_GRUPO, D1_QUANT, D1_EMISSAO, '', '' " + CRLF
_cQry += " FROM SD1010 D " + CRLF
_cQry += " JOIN SB1010 B ON B1_FILIAL=' ' AND B1_COD=D1_COD AND B.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' ' " + CRLF
_cQry += " WHERE  " + CRLF
_cQry += " 	D1_FILIAL <> ' ' " + CRLF
_cQry += " AND D1_COD = '"+cProduto+"'  " + CRLF
_cQry += " AND D1_EMISSAO BETWEEN '"+dDtMoviment+"' AND '" + dDTReferencia +"' " + CRLF
_cQry += "  " + CRLF
_cQry += " ORDER BY 13, 1, 2, 3 "

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliasD3),.F.,.F.) 

TcSetField(cAliasD3, "D3_EMISSAO", "D")
MEMOWRITE("C:\TOTVS_RELATORIOS\VAESTR14.TXT", _cQry)
While !(cAliasD3)->(Eof())

	if Len(aAUXAlias) > 0 .and. ;
		aAUXAlias[ Len(aAUXAlias), 1] == (cAliasD3)->NUMSEQ
		
		If aAUXAlias[ Len(aAUXAlias), 02 ] <> (cAliasD3)->TIPO_MOV
			aAUXAlias[ Len(aAUXAlias), 02 ] += "/" + (cAliasD3)->TIPO_MOV
		EndIf 
		
		If aAUXAlias[ Len(aAUXAlias), 03 ] <> AllTrim((cAliasD3)->MOTIVO)
			aAUXAlias[ Len(aAUXAlias), 03 ] += "/" + (cAliasD3)->MOTIVO
		Else
			If aAUXAlias[ Len(aAUXAlias), 03 ] == "TRANSFERENCIA"
				If cProduto == aAUXAlias[ Len(aAUXAlias), 07 ]
					aAUXAlias[ Len(aAUXAlias), 03 ] := "SAIDA POR TRANSFERENCIA"
				else
					aAUXAlias[ Len(aAUXAlias), 03 ] := "ENTRADA POR TRANSFERENCIA"
				EndIf
			EndIf
		EndIf

		If aAUXAlias[ Len(aAUXAlias), 04 ] <> (cAliasD3)->D3_FILIAL
			aAUXAlias[ Len(aAUXAlias), 04 ] += "/" + (cAliasD3)->D3_FILIAL
		EndIf
		
		aAUXAlias[ Len(aAUXAlias), 09 ] := (cAliasD3)->D3_COD
		aAUXAlias[ Len(aAUXAlias), 10 ] := (cAliasD3)->B1_DESC
		aAUXAlias[ Len(aAUXAlias), 11 ] := (cAliasD3)->B1_XLOTE
		
	Else
        		
		aAdd( aAUXAlias, {  (cAliasD3)->NUMSEQ ,;		 
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
	EndIf
	
	(cAliasD3)->(DbSkip())
	
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

(cAliasD3)->(DbCloseArea())

RestArea(aArea)
Return aRet
