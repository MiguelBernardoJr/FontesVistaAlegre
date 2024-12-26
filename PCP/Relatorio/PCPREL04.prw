#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "TOPCONN.CH"
#include 'FILEIO.CH'

/*--------------------------------------------------------------------------------,
 | Principal: 			            U_PCPREL04()            		              |
 | Func:  PCPREL04()	            	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  09.09.2019	            	          	            	              |
 | Desc:  Gestão do Trato                                          	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
User Function PCPREL04()
Local cTimeIni	 	:= Time()
Local cStyle		:= ""
Local cXML	   		:= ""
Local lTemDados		:= .T.

Private cPerg		:= "PCPREL02"  // SubS(ProcName(),3) // Usando as mesmas perguntas do outro relatório.
Private cTitulo  	:= "Relatorio de Gestão de Trato"

Private cPath 	 	:= "C:\TOTVS_RELATORIOS\"
Private cArquivo   	:= cPath + "PCPREL04" +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()   

Private nHandle    	:= 0

&('StaticCall(PCPREL02, GeraX1, cPerg)')
	
If Pergunte(cPerg, .T.)
	U_PrintSX1(cPerg)
	
	If Len( Directory(cPath + "*.*","D") ) == 0
		If Makedir(cPath) == 0
			ConOut('Diretorio Criado com Sucesso.')
			MsgAlert('Diretorio Criado com Sucesso: ' + cPath, 'Aviso')
		Else	
			ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
			MsgAlert( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ), 'Aviso' )
		EndIf
	EndIf
	
	nHandle := FCreate(cArquivo)
	if nHandle = -1
		conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	else
		
		cStyle := U_defStyle()
		
		// Processar SQL
		FWMsgRun(, {|| lTemDados := fLoadSql("Geral", @_cAliasG ) },'Por Favor Aguarde...',;
							'Processando Banco de Dados - Gestão do Trato')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...',;
										'Geração do quadro de Gestão do Trato')
			
			// Final - encerramento do arquivo
			FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )
			
			FClose(nHandle)

			If ApOleClient("MSExcel")				//	 U_VARELM01()
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( cArquivo )
				oExcelApp:SetVisible(.T.) 	
				oExcelApp:Destroy()	
				// ou >  ShellExecute( "Open", cNameFile , '', '', 1 ) //Abre o arquivo na tela após salvar 
			Else
				MsgAlert("O Excel não foi encontrado. Arquivo " + cArquivo + " gerado em " + cPath + ".", "MsExcel não encontrado" )
			EndIf
		Else
			MsgAlert("Os parametros informados não retornou nenhuma informação do banco de dados." + CRLF + ;
					 "Por isso o excel não sera aberto automaticamente.", "Dados não localizados")
		EndIf
		
		(_cAliasG)->(DbCloseArea())
		
		If lower(cUserName) $ 'mbernardo,atoshio,admin, administrador'
			Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
		EndIf
		
		ConOut('Activate: ' + Time())
	EndIf
EndIf

Return nil



/*--------------------------------------------------------------------------------,
 | Principal: 			            U_PCPREL04()            		              |
 | Func:  PCPREL04()	            	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  09.09.2019	            	          	            	              |
 | Desc:  Gestão do Trato                                          	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
Static Function fLoadSql(cTipo, _cAlias)
Local _cQry 		:= ""

If cTipo   == "Geral"

	_cQry  +="SELECT Z05_FILIAL " + CRLF
	_cQry  +=	   "	 , Z05_DATA " + CRLF
	_cQry  +=	   "	 , Z05_CURRAL " + CRLF
	_cQry  +=	   "	 , Z05_LOTE " + CRLF
	_cQry  +=	   "	 , Z05_CABECA " + CRLF
	_cQry  +=	   "	 , Z05_DIETA  " + CRLF
	_cQry  +=	   "	 , COUNT(Z06_TRATO) QTD_TRATO 	     " + CRLF
	_cQry  +=	   "	 , ISNULL(Z0U_NOME,'') Z0U_NOME " + CRLF
	_cQry  +=	   "	 , ISNULL(ZV0_DESC,'') ZV0_DESC " + CRLF
	_cQry  +=	   "	 , SUM(ISNULL(Z0W_QTDPRE,0)) PREVISTO " + CRLF
	_cQry  +=	   "	 , SUM(ISNULL(Z0W_QTDPRE,0))/COUNT(Z06_TRATO) PRE_TRATO 	     " + CRLF
	_cQry  +=	   "	 , SUM(ISNULL(CASE WHEN Z0W_PESDIG <> 0 THEN Z0W_PESDIG ELSE Z0W_QTDREA END ,0)) REALIZADO " + CRLF
	_cQry  +=	   "	 , SUM(ISNULL(CASE WHEN Z0W_PESDIG <> 0 THEN Z0W_PESDIG ELSE Z0W_QTDREA END ,0))/COUNT(Z06_TRATO) RE_TRATO " + CRLF
	_cQry  +=	   "FROM   " + RetSqlName("Z05") + " Z05 " + CRLF
	_cQry  +=	   "  JOIN " + RetSqlName("Z06") + " Z06 ON Z06_FILIAL='"+xFilial('Z06')+"' " + CRLF
	_cQry  +=	   "				 AND Z05_FILIAL=Z06_FILIAL " + CRLF
	_cQry  +=	   "				 AND Z05_DATA  =Z06_DATA " + CRLF
	_cQry  +=	   "				 AND Z05_VERSAO=Z06_VERSAO " + CRLF
	_cQry  +=	   "				 AND Z05_CURRAL=Z06_CURRAL " + CRLF
	_cQry  +=	   "				 AND Z05_LOTE	= Z06_LOTE  " + CRLF
	_cQry  +=	   "				 AND Z05.D_E_L_E_T_=' ' " + CRLF
	_cQry  +=	   "				 AND Z06.D_E_L_E_T_=' ' " + CRLF
	_cQry  +=	   "LEFT JOIN " + RetSqlName("Z0W") + " Z0W ON Z0W.Z0W_FILIAL='"+xFilial('Z0W')+"' " + CRLF
	_cQry  +=	   "				AND Z05.Z05_FILIAL=Z0W.Z0W_FILIAL " + CRLF
	_cQry  +=	   "				AND Z05_DATA = Z0W_DATA  " + CRLF
	_cQry  +=	   "				AND Z05.Z05_LOTE = Z0W_LOTE  " + CRLF
	_cQry  +=	   "				AND Z06_TRATO=Z0W_TRATO " + CRLF
	_cQry  +=	   "				AND Z06_DIETA=Z0W_RECEIT " + CRLF
	_cQry  +=	   "				AND Z0W.D_E_L_E_T_ = ' '	-- cabeçalho de programacao do Trato " + CRLF
	_cQry  +=	   "LEFT JOIN " + RetSqlName("Z0I") + " DIA ON DIA.Z0I_FILIAL='"+xFilial('Z0I')+"' " + CRLF
	_cQry  +=	   "				AND Z0I_DATA=Z0W_DATA " + CRLF
	_cQry  +=	   "				AND Z0I_CURRAL=Z0W_CURRAL " + CRLF
	_cQry  +=	   "				AND Z0I_LOTE=Z0W_LOTE " + CRLF
	_cQry  +=	   "				AND DIA.D_E_L_E_T_=' ' " + CRLF
	_cQry  +=	   "LEFT JOIN " + RetSqlName("Z0I") + " ONTEM ON ONTEM.Z0I_FILIAL='"+xFilial('Z0I')+"' " + CRLF
	_cQry  +=	   "				AND ONTEM.Z0I_DATA+1=Z0W_DATA " + CRLF
	_cQry  +=	   "				AND ONTEM.Z0I_CURRAL=Z0W_CURRAL " + CRLF
	_cQry  +=	   "				AND ONTEM.Z0I_LOTE=Z0W_LOTE " + CRLF
	_cQry  +=	   "				AND ONTEM.D_E_L_E_T_=' ' " + CRLF
	_cQry  +=	   " JOIN " + RetSqlName("Z0X") + " Z0X ON Z0W_FILIAL='"+xFilial('Z0W')+"' " + CRLF
	_cQry  +=	   "				AND Z0W.Z0W_FILIAL=Z0X.Z0X_FILIAL " + CRLF
	_cQry  +=	   "				AND Z0W.Z0W_CODEI = Z0X.Z0X_CODIGO " + CRLF
	_cQry  +=	   "				AND Z0X.D_E_L_E_T_ = ' '	-- cabeçalho TRATO " + CRLF
	_cQry  +=	   " JOIN " + RetSqlName("ZV0") + " ZV0 ON ZV0.ZV0_CODIGO = Z0X.Z0X_EQUIP " + CRLF
	_cQry  +=	   "				AND ZV0.D_E_L_E_T_ = ' '  " + CRLF
	_cQry  +=	   "LEFT JOIN " + RetSqlName("Z0U") + " Z0U ON Z0U_FILIAL='"+xFilial('Z0U')+"' " + CRLF
	_cQry  +=	   "				AND Z0U_CODIGO=Z0X_OPERAD " + CRLF
	_cQry  +=	   "				AND Z0U.D_E_L_E_T_=' ' " + CRLF
	_cQry  +=	   "WHERE Z05_FILIAL='"+xFilial('Z05')+"' " + CRLF
	_cQry  +=	   " AND Z05_DATA   BETWEEN '" + DToS(MV_PAR01) + "' and '" + DToS(MV_PAR02) + "'" + CRLF
	_cQry  +=	   " AND Z06_LOTE   BETWEEN '" + MV_PAR03 + "' and '" + MV_PAR04 + "'" + CRLF
	_cQry  +=	   "GROUP BY Z05_FILIAL " + CRLF
	_cQry  +=	   "   , Z05_DATA " + CRLF
	_cQry  +=	   "   , Z05_CURRAL " + CRLF
	_cQry  +=	   "   , Z05_LOTE " + CRLF
	_cQry  +=	   "   , Z05_CABECA " + CRLF
	_cQry  +=	   "   , Z05_DIETA -- Z05_DIETA " + CRLF
	_cQry  +=	   "   , Z05_DIASDI " + CRLF
	_cQry  +=	   "   , ONTEM.Z0I_NOTTAR " + CRLF
	_cQry  +=	   "   , DIA.Z0I_NOTNOI " + CRLF
	_cQry  +=	   "   , DIA.Z0I_NOTMAN " + CRLF
	_cQry  +=	   "   , Z0U_NOME " + CRLF
	_cQry  +=	   "   , ZV0_DESC " + CRLF
	_cQry  +=	   "ORDER BY 1, 2, 3, CAST(REPLACE(SUBSTRING(Z05_LOTE, 1, CHARINDEX('-',Z05_LOTE)),'-','') AS INT) " 

EndIf

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

Return !(_cAlias)->(Eof())
// FIM: fLoadSql()




/*--------------------------------------------------------------------------------,
 | Principal: 			            U_PCPREL04()            		              |
 | Func:  PCPREL04()	            	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  09.09.2019	            	          	            	              |
 | Desc:  Gestão do Trato                                          	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1()

Local nRegistros	:= 0
Local cXML 			:= ""
Local cWorkSheet 	:= ""

Local cLote  		:= ""

// Controle Quebra/ABA
Local sDataAtual	:= ""//StoD("")

(_cAliasG)->(DbEval({|| nRegistros++ }))

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	cWorkSheet := "Geral"
	
	//fQuadro1
	While !(_cAliasG)->(Eof())
	
		If sDataAtual <> (_cAliasG)->Z05_DATA
			sDataAtual := (_cAliasG)->Z05_DATA

			cXML += U_prtCellXML( 'Worksheet', /* cWorkSheet */ StrTran(dToC(StoD(sDataAtual)),"/","-") )
			cXML += U_prtCellXML( 'Table' )
			
			cXML += '<Column ss:Width="54" ss:Span="2"/>'+CRLF
			cXML += '<Column ss:Index="4" ss:Width="104.25" ss:Span="2"/>'+CRLF
			cXML += '<Column ss:Index="7" ss:Width="54" ss:Span="4"/>'+CRLF
   
			cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '10'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)
			
			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTextoN', 'String', /*cFormula*/, 'Filial: '                              ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_FILIAL ),,.T. )
			cXML += U_prtCellXML( '</Row>' )
			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTextoN', 'String', /*cFormula*/, 'Data: '                                      ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData', 'DateTime', /*cFormula*/, U_FrmtVlrExcel( SToD( (_cAliasG)->Z05_DATA ) ),,.T. ) // DATA
			cXML += U_prtCellXML( '</Row>' )
		
			cXML += U_prtCellXML( 'pulalinha','1' )
			
			// Titulo
			cXML += U_prtCellXML( 'Row',,'33' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Curral'		 ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Lote'		 ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtde Cabeças' ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dietas'		 ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Veiculo'		 ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Operador'	 ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Tratos'	     ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Previsto por Trato'   ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Realizado por Trato'    ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Previsto'     ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Realizado'    ,,.T. )
			cXML += U_prtCellXML( '</Row>' )
			
		EndIf
		
		cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_CURRAL ),,.T. ) // CURRAL
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_LOTE   ),,.T. ) // LOTE
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_CABECA ),,.T. ) // NRO CABEÇAS
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_DIETA  ),,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->ZV0_DESC   ),,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0U_NOME   ),,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->QTD_TRATO  ),,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->PRE_TRATO   ),,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->RE_TRATO  ),,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->PREVISTO  ),,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->REALIZADO   ),,.T. )
		
		cXML += U_prtCellXML( '</Row>' )
		
		(_cAliasG)->(DbSkip())
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
	
		If (_cAliasG)->(Eof()) .or. sDataAtual <> (_cAliasG)->Z05_DATA
			// cXML += U_prtCellXML( 'pulalinha','1' )
		
			// Final da Planilha
			cXML += '  </Table>' + CRLF
			cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
			cXML += '   <PageSetup>' + CRLF
			cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
			cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
			cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
			cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
			cXML += '   </PageSetup>' + CRLF
			cXML += '   <TabColorIndex>13</TabColorIndex>' + CRLF
			cXML += '   <Selected/>' + CRLF
			cXML += '   <Panes>' + CRLF
			cXML += '    <Pane>' + CRLF
			cXML += '     <Number>3</Number>' + CRLF
			cXML += '     <ActiveRow>17</ActiveRow>' + CRLF
			cXML += '     <ActiveCol>9</ActiveCol>' + CRLF
			cXML += '    </Pane>' + CRLF
			cXML += '   </Panes>' + CRLF
			cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
			cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
			cXML += '  </WorksheetOptions>' + CRLF
			cXML += ' </Worksheet>' + CRLF
		 
			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
			EndIf
			cXML := ""
		EndIf
	EndDo

	
EndIf	

Return nil
// FIM: fQuadro1
