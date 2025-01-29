#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR08()          		            	      |
 | Func:  VACOMM08()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  21.12.2018	            	          	            	              |
 | Desc:  Função principal, chamada pelo MENU.           	            	      |
 '--------------------------------------------------------------------------------|
 | Obs.:  -	            	                                                      |
 | Alt:   Relatório para listagem dos documentos lançados 	.	            	  |
 '--------------------------------------------------------------------------------*/

user function VACOMR08()

Local cTimeIni	 	:= Time()
Local lTemDados		:= .T.
Local lTemExcel	    := .F.
Local cStyle		:= ""
Local cXML	   		:= ""
Local nTotQd2		:= 0 
Local nTotQd3		:= 0 
Local nTotQd7		:= 0
Local nTotQd8		:= 0
Local aDadDro8		:= {}

Private cPerg		:= "VACOMM08"
Private cTitulo  	:= "Relação dos documentos fiscais lançados"

Private cPath 	 	:= "C:\TOTVS_RELATORIOS\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
						
Private oExcelApp   := nil	
Private _cAliasG	:= GetNextAlias()   	
//Private _aDados 	:= {}

Private nHandle    	:= 0						


GeraX1(cPerg)
	
If Pergunte(cPerg, .T.)

	U_PrintSX1(cPerg)
	
	If Len( Directory(cPath + "*.*","D") ) == 0
		If Makedir(cPath) == 0
			ConOut('Diretorio Criado com Sucesso.')
		Else	
			ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
		EndIf
	EndIf
	
	nHandle := FCreate(cArquivo)
	if nHandle = -1
		conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	else
		
		cStyle := defStyle()
		
		// Processar SQL
		FWMsgRun(, {|| lTemExcel := lTemDados := VASqlR08("VACOMM08", @_cAliasG ) },'Por Favor Aguarde...' , 'Processando Banco de Dados')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			FWMsgRun(, {|| fQuadro1( ) },'Por Favor Aguarde...' , 'Gerando quadro de Valores Genericos')
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
			
			//(_cAliasE)->(DbCloseArea())
			
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
return


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR08()             	            	      |
 | Func:  VASqlR07()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  11.05.2018	            	          	            	              |
 | Desc:  Processamento do SQL, salvando em variavel PRIVADA;  	            	  |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function VASqlR08(cTipo, _cAliasG)
Local _cQry 		:= ""
Local cSQLInicio 	:= ""

If cTipo == "VACOMM08"

	_cQry := "    " + CRLF
	_cQry += "  SELECT D1_FILIAL, D1_EMISSAO, D1_DTDIGIT, F1_X_DTINC, D1_DOC+'-'+D1_SERIE NOTA, A2_COD+'-'+A2_LOJA+'- '+RTRIM(A2_NOME) NOME,   " + CRLF
	_cQry += "  	   RTRIM(D1_COD)+'-'+B1_DESC PRODUTO, D1_GRUPO, D1_QUANT, D1_LOCAL, D1_VUNIT, D1_TOTAL, D1_TES+'-'+F4_TEXTO TES, CASE WHEN F4_ESTOQUE = 'S' THEN 'SIM' WHEN F4_ESTOQUE = 'N' THEN 'NAO' END AS F4_ESTOQUE, D1_CC, D1_ITEMCTA, " +CRLF
	_cQry += "    	   D1_CF, F1_ESPECIE, F4_SITTRIB, D1_PICM, D1_BASEICM, D1_VALICM, D1_VALPIS, D1_VALCOF, F4_CSTCOF, F4_CSTPIS" + CRLF
	_cQry += "    FROM SD1010 D1  " + CRLF
	_cQry += "    JOIN SF1010 F1 ON  " + CRLF
	_cQry += "  	   F1_FILIAL = D1_FILIAL  " + CRLF
	_cQry += "     AND F1_DOC = D1_DOC  " + CRLF
	_cQry += "     AND F1_SERIE = D1_SERIE  " + CRLF
	_cQry += "     AND F1_FORNECE = D1_FORNECE  " + CRLF
	_cQry += "     AND F1_LOJA = D1_LOJA  " + CRLF
	_cQry += "     AND F1_EMISSAO = D1_EMISSAO   " + CRLF
	_cQry += "     AND F1.D_E_L_E_T_ = ' '   " + CRLF
	_cQry += "    JOIN SB1010 B1 ON  " + CRLF
	_cQry += "  	   B1_COD = D1_COD   " + CRLF
	_cQry += "     AND B1.D_E_L_E_T_ = ' '   " + CRLF
	_cQry += "    JOIN SF4010 F4 ON  " + CRLF
	_cQry += "  	   F4_CODIGO = D1_TES   " + CRLF
	_cQry += "     AND F4.D_E_L_E_T_ = ' '   " + CRLF
	_cQry += "    JOIN SA2010 A2 ON  " + CRLF
	_cQry += "  	   A2_FILIAL = ' '   " + CRLF
	_cQry += "     AND A2_COD = D1_FORNECE   " + CRLF
	_cQry += "     AND A2_LOJA = D1_LOJA  " + CRLF
	_cQry += "     AND A2.D_E_L_E_T_ = ' '   " + CRLF
	_cQry += "     WHERE F1_X_DTINC BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' AND D1.D_E_L_E_T_ = ' '  " + CRLF
	_cQry += "       AND D1_TIPO <> 'D'   " + CRLF
	_cQry += "  UNION ALL   " + CRLF
	_cQry += "  SELECT D1_FILIAL, D1_EMISSAO, D1_DTDIGIT, F1_X_DTINC, D1_DOC+'-'+D1_SERIE NOTA, A1_COD+'-'+A1_LOJA+'- '+RTRIM(A1_NOME) NOME,   " + CRLF
	_cQry += "  	   RTRIM(D1_COD)+'-'+B1_DESC PRODUTO, D1_GRUPO, D1_QUANT, D1_LOCAL, D1_VUNIT, D1_TOTAL, D1_TES+'-'+F4_TEXTO TES, CASE WHEN F4_ESTOQUE = 'S' THEN 'SIM' WHEN F4_ESTOQUE = 'N' THEN 'NAO' END AS F4_ESTOQUE, D1_CC, D1_ITEMCTA, " +CRLF
	_cQry += "    	   D1_CF, F1_ESPECIE, F4_SITTRIB, D1_PICM, D1_BASEICM, D1_VALICM, D1_VALPIS, D1_VALCOF, F4_CSTCOF, F4_CSTPIS" + CRLF
	_cQry += "    FROM SD1010 D1  " + CRLF
	_cQry += "    JOIN SF1010 F1 ON  " + CRLF
	_cQry += "  	   F1_FILIAL = D1_FILIAL  " + CRLF
	_cQry += "     AND F1_DOC = D1_DOC  " + CRLF
	_cQry += "     AND F1_SERIE = D1_SERIE  " + CRLF
	_cQry += "     AND F1_FORNECE = D1_FORNECE  " + CRLF
	_cQry += "     AND F1_LOJA = D1_LOJA  " + CRLF
	_cQry += "     AND F1_EMISSAO = D1_EMISSAO   " + CRLF
	_cQry += "     AND F1.D_E_L_E_T_ = ' '   " + CRLF
	_cQry += "    JOIN SB1010 B1 ON  " + CRLF
	_cQry += "  	   B1_COD = D1_COD   " + CRLF
	_cQry += "     AND B1.D_E_L_E_T_ = ' '   " + CRLF
	_cQry += "    JOIN SF4010 F4 ON  " + CRLF
	_cQry += "  	   F4_CODIGO = D1_TES   " + CRLF
	_cQry += "     AND F4.D_E_L_E_T_ = ' '   " + CRLF
	_cQry += "    JOIN SA1010 A1  ON  " + CRLF
	_cQry += "  	   A1_FILIAL = ' '   " + CRLF
	_cQry += "     AND A1_COD = D1_FORNECE   " + CRLF
	_cQry += "     AND A1_LOJA = D1_LOJA  " + CRLF
	_cQry += "     AND A1.D_E_L_E_T_ = ' '   " + CRLF
	_cQry += "     WHERE F1_X_DTINC BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' AND D1.D_E_L_E_T_ = ' '  " + CRLF
	_cQry += "       AND D1_TIPO = 'D'   " + CRLF
	//_cQry += "     WHERE F1_X_DTINC BETWEEN '"+DToS(MVPAR01)+"' AND '"+DToS(MVPAR02)+"'  " + CRLF
EndIf 

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAliasG),.F.,.F.) 

 TcSetField(_cAliasG, "D1_EMISSAO", "D")
 TcSetField(_cAliasG, "D1_DTDIGIT", "D")
 TcSetField(_cAliasG, "F1_X_DTINC", "D")

Return !(_cAliasG)->(Eof())
// FIM: VASqlR07()

Static Function fQuadro1()

Local cXML 			:= ""
Local cWorkSheet 	:= "Relação das NFs"
Local nLin			:= 0
Local cAux		  	:= ""

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
	cXML += '  <Column ss:Width="28.5"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="54.75" ss:Span="1"/>
	cXML += '     <Column ss:Index="4" ss:AutoFitWidth="0" ss:Width="66.75"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="74"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="158.75"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="131.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="49.5"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="62.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="76.5"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="76.5"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="141"/>
	cXML += '     <Column ss:Width="42.75"/>
	cXML += '     <Column ss:Width="43.5"/>
	cXML += '     <Column ss:Width="44.25"/>
	cXML += '  <Row ss:AutoFitHeight="0" ss:Height="36">' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Emissão</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Data Base Protheus</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Data Real Lançamento</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal/Serie</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Razao Social</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Produto</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Grupo</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Qtde</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Armazem</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Valor Unit</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Valor Total</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">TES</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Estoque</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">C. Custo</Data></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Item Contabil</Data></Cell>' + CRLF
	iF MV_PAR03 == 2
		cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">CFOP</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Especie</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">CST ICMS</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Aliq ICMS</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Base ICMS</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Valor ICMS</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Valor PIS</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Valor COFINS</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Aliq. PIS</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Aliq. COFINS</Data></Cell>' + CRLF
	EndIf

	cXML += '</Row>' + CRLF
	While !(_cAliasG)->(Eof())	
		cXML += '<Row>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->D1_FILIAL ) + '</Data></Cell>' + CRLF	
		cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel(  (_cAliasG)->D1_EMISSAO )+  '</Data></Cell>' + CRLF	
		cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel(  (_cAliasG)->D1_DTDIGIT )+  '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel(  (_cAliasG)->F1_X_DTINC )+  '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->NOTA ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->NOME ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->PRODUTO ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->D1_GRUPO ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel(  (_cAliasG)->D1_QUANT ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="String">' + U_FrmtVlrExcel(  (_cAliasG)->D1_LOCAL ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">'   + U_FrmtVlrExcel(  (_cAliasG)->D1_VUNIT ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">'   + U_FrmtVlrExcel(  (_cAliasG)->D1_TOTAL ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->TES ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->F4_ESTOQUE ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->D1_CC ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->D1_ITEMCTA ) + '</Data></Cell>' + CRLF
	If MV_PAR03 == 2
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->D1_CF ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->F1_ESPECIE ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->F4_SITTRIB ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->D1_PICM ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">'  + U_FrmtVlrExcel(  (_cAliasG)->D1_BASEICM ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">'  + U_FrmtVlrExcel(  (_cAliasG)->D1_VALICM ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">'  + U_FrmtVlrExcel(  (_cAliasG)->D1_VALPIS ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">'  + U_FrmtVlrExcel(  (_cAliasG)->D1_VALCOF ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->F4_CSTCOF ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->F4_CSTPIS ) + '</Data></Cell>' + CRLF
	EndIf
		cXML += '</Row>' + CRLF

		(_cAliasG)->(DbSkip())
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
	
	EndDo
	
	cXML += '  </Table>
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
	cXML += '   <PageSetup>
	cXML += '    <Header x:Margin="0.31496062000000002"/>
	cXML += '    <Footer x:Margin="0.31496062000000002"/>
	cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"
	cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>
	cXML += '   </PageSetup>
	cXML += '   <TabColorIndex>13</TabColorIndex>
	cXML += '   <Selected/>
	cXML += '   <Panes>
	cXML += '    <Pane>
	cXML += '     <Number>3</Number>
	cXML += '     <ActiveRow>17</ActiveRow>
	cXML += '     <ActiveCol>9</ActiveCol>
	cXML += '    </Pane>
	cXML += '   </Panes>
	cXML += '   <ProtectObjects>False</ProtectObjects>
	cXML += '   <ProtectScenarios>False</ProtectScenarios>
	cXML += '  </WorksheetOptions>
	cXML += ' </Worksheet>
 
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
	
EndIf	

Return nil
// fQuadro1

Static Function defStyle()
	
Local cStyle := ""
	
	cStyle := ' <Style ss:ID="s16" ss:Name="Vírgula">'+CRLF
	cStyle += '   <NumberFormat ss:Format="_-* #,##0.00_-;\-* #,##0.00_-;_-* &quot;-&quot;??_-;_-@_-"/> '+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s62">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="12"'+CRLF
	cStyle += '     ss:Color="#333399" ss:Bold="1"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '  <Style ss:ID="s65">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += '    <Borders>'+CRLF
	cStyle += '      <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"'+CRLF
	cStyle += '       ss:Color="#37752F"/>'+CRLF
	cStyle += '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"'+CRLF
	cStyle += '       ss:Color="#37752F"/>'+CRLF
	cStyle += '    </Borders>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '     ss:Color="#FFFFFF" ss:Bold="1"/>'+CRLF
	cStyle += '    <Interior ss:Color="#37752F" ss:Pattern="Solid"/>'+CRLF
	cStyle += '  </Style>'+CRLF	
	cStyle += '  <Style ss:ID="sTexto">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '     ss:Color="#000000"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '  <Style ss:ID="sTextoC">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '     ss:Color="#000000"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '  <Style ss:ID="sTextoN">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '     ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '  <Style ss:ID="sData">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '     ss:Color="#000000"/>'+CRLF
	cStyle += '    <NumberFormat ss:Format="Short Date"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '  <Style ss:ID="sDataC">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '     ss:Color="#000000"/>'+CRLF
	cStyle += '    <NumberFormat ss:Format="Short Date"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '<Style ss:ID="sComDig" ss:Parent="s16">'+CRLF
	cStyle += '   <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '    ss:Color="#000000"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '<Style ss:ID="sComDigC" ss:Parent="s16">'+CRLF
	cStyle += '	<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+CRLF
	cStyle += '	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += '	<NumberFormat ss:Format="#,##0.00_ ;\-#,##0.00\ "/>'+CRLF
	cStyle += '</Style>'+CRLF
	cStyle += ' <Style ss:ID="sComDigC3" ss:Parent="s16">'+CRLF
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+CRLF
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += '  <NumberFormat ss:Format="#,##0.000_ ;\-#,##0.000\ "/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += '<Style ss:ID="sComDigN" ss:Parent="s16">'+CRLF
	cStyle += '   <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '  <Style ss:ID="sReal">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '     ss:Color="#000000"/>'+CRLF
	cStyle += '    <NumberFormat'+CRLF
	cStyle += '     ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += '  </Style>'+CRLF		
	cStyle += ' <Style ss:ID="sRealFundoVerdeClaro">'+CRLF
	cStyle += ' <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
	cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += ' <Interior ss:Color="#92D050" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' <NumberFormat ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += ' </Style> '+CRLF
	cStyle += ' <Style ss:ID="sRealFundoAmareloClaro">'+CRLF
	cStyle += ' <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
	cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += ' <Interior ss:Color="#FFFF00" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' <NumberFormat ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sRealFundoAzulOcean">'+CRLF
	cStyle += ' <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
	cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += ' <Interior ss:Color="#00B0F0" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' <NumberFormat ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += '  <Style ss:ID="sRealN">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += '    <NumberFormat'+CRLF
	cStyle += '     ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += '  </Style>'+CRLF		
	cStyle += ' <Style ss:ID="sSemDig" ss:Parent="s16">'+CRLF
	cStyle += '     <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '      ss:Color="#000000"/>'+CRLF
	cStyle += '     <NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sSemDigC" ss:Parent="s16">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
	cStyle += ' 	<NumberFormat ss:Format="#,##0_ ;\-#,##0\ "/>
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sSemDigN" ss:Parent="s16">'+CRLF
	cStyle += '     <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '      ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += '     <NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s98">
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>
	cStyle += '  <Borders>
	cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '  </Borders>
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"
	cStyle += '   ss:Color="#FFFFFF" ss:Bold="1"/>
	cStyle += '  <Interior ss:Color="#37752F" ss:Pattern="Solid"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="s99">
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>
	cStyle += '  <Borders>
	cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '  </Borders>
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"
	cStyle += '   ss:Color="#FFFFFF" ss:Bold="1"/>
	cStyle += '  <Interior ss:Color="#37752F" ss:Pattern="Solid"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="s100">
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>
	cStyle += '  <Borders>
	cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '  </Borders>
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>
	cStyle += '  <Interior ss:Color="#0070C0" ss:Pattern="Solid"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="s101">
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>
	cStyle += '  <Borders>
	cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
	cStyle += '  </Borders>
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>
	cStyle += '  <Interior ss:Color="#0070C0" ss:Pattern="Solid"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="sPorcent">
	cStyle += '   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
	cStyle += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
	cStyle += '   <NumberFormat ss:Format="Percent"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="s90" ss:Name="Normal 5">
	cStyle += ' <Alignment ss:Vertical="Bottom"/>
	cStyle += ' <Borders/>
	cStyle += ' <Font ss:FontName="Arial"/>
	cStyle += ' <Interior/>
	cStyle += ' <NumberFormat/>
	cStyle += ' <Protection/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="s97">
	cStyle += ' 	<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="TitRacao">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += ' 	<Borders>'+CRLF
	cStyle += ' 		<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"'+CRLF
	cStyle += ' 		ss:Color="#37752F"/>'+CRLF
	cStyle += ' 		<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"'+CRLF
	cStyle += ' 		ss:Color="#37752F"/>'+CRLF
	cStyle += ' 		<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="3"'+CRLF
	cStyle += ' 		ss:Color="#FFFFFF"/>'+CRLF
	cStyle += ' 	</Borders>'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += ' 		ss:Color="#FFFFFF" ss:Bold="1"/>'+CRLF
	cStyle += ' 	<Interior ss:Color="#37752F" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' 	<NumberFormat ss:Format="Short Date"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sHora">
	cStyle += ' 	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
	cStyle += ' 	<NumberFormat ss:Format="Short Time"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="sTextoNFundoVerdeClaroApuracao" ss:Parent="s16">
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
	cStyle += ' 	<Interior ss:Color="#A9D08E" ss:Pattern="Solid"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="sTextoNFundoAzulClaroApuracao">
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
	cStyle += ' 	<Interior ss:Color="#D6DCE4" ss:Pattern="Solid"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="sComDigFundoVerdeClaroApuracao" ss:Parent="s16">
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
	cStyle += ' 	<Interior ss:Color="#A9D08E" ss:Pattern="Solid"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="sComDigC3FundoVerdeClaroApuracao" ss:Parent="s16">
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
	cStyle += ' 	<Interior ss:Color="#A9D08E" ss:Pattern="Solid"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="sRealFundoAzulClaroApuracao">
	cStyle += ' 	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
	cStyle += ' 	<Interior ss:Color="#D6DCE4" ss:Pattern="Solid"/>
	cStyle += ' 	<NumberFormat ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>
	cStyle += ' </Style>
Return cStyle
// defStyle

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAFINM02()                                      |
 | Func:  GeraX1()                                                                |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  11.05.2018                                                              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local i         := 0
Local J         := 0
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

aAdd(aRegs,{cPerg, "01", "Data do Lancamento De?"      , "", "", "MV_CH1", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR01", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Data do Lancamento Ate?"     , "", "", "MV_CH2", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR02", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "03", "Informações Fiscais ?"       , "", "", "MV_CH3", "N", 					   1,					    0, 2, "C", ""        , "MV_PAR03", "Não", "","",""      ,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})


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
// FIM: GeraX1

