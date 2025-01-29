#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAMNTR01()          		            	      |
 | Func:  VACOMR01()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  21.12.2018	            	          	            	              |
 | Desc:  Função principal, chamada pelo MENU.           	            	      |
 '--------------------------------------------------------------------------------|
 | Obs.:  -	            	                                                      |
 | Alt:   Relatório para listagem dos documentos lançados 	.	            	  |
 '--------------------------------------------------------------------------------*/

user function VAMNTR01()
	
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

Private cPerg		:= "VAMNTR01"
Private cTitulo  	:= "Apontamento de operação por Centro de Custos "

Private cPath 	 	:= "C:\totvs_relatorios\"
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
		FWMsgRun(, {|| lTemExcel := lTemDados := VASqlR01("VAMNTR01", @_cAliasG ) },'Por Favor Aguarde...' , 'Processando Banco de Dados')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf

			FWMsgRun(, {|| fQuadro1( ) },'Por Favor Aguarde...' , 'Gerando planilha com os apontamentos do período selecionado')

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


//U_VAMNTR01()                                                                                                                           
/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAMNTR01()             	            	      |
 | Func:  VASqlR01()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  11.05.2018	            	          	            	              |
 | Desc:  Processamento do SQL, salvando em variavel PRIVADA;  	            	  |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function VASqlR01(cTipo, _cAliasG)
Local _cQry 		:= ""
Local cSQLInicio 	:= ""

If cTipo == "VAMNTR01"

	_cQry := "  SELECT ZAD_FILIAL, ZAD_CODIGO, ZAD_ITEM, T9_CODBEM, ZAD_EQUIPA, ZAD_DATA, ZAD_INICIO, ZAD_FINAL, ZAD_CC, CTT_DESC01, ZAD_OPERAD, RA_NOME " + CRLF
	_cQry += "  FROM "+RetSqlName("ZAD")+" ZAD" + CRLF
	_cQry += "  	JOIN "+RetSqlName("CTT")+" CTT ON CTT_FILIAL = ' ' AND CTT_CUSTO = ZAD_CC AND CTT.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "  	JOIN "+RetSqlName("SRA")+" RA ON RA_MAT = ZAD_OPERAD AND RA.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "  	LEFT JOIN ST9010 T9 ON T9_ITEMCTA = ZAD_ITEM AND T9.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "  WHERE ZAD_ITEM BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + CRLF
	_cQry += "  AND ZAD_DATA BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' " + CRLF
	_cQry += "  AND ZAD.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "  ORDER BY ZAD_ITEM, ZAD_DATA" + CRLF

EndIf 

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAliasG),.F.,.F.) 

TcSetField(_cAliasG, "ZAD_DATA", "D")
 
Return !(_cAliasG)->(Eof())
// VASqlR01


Static Function fQuadro1()	// U_VAMNTR01()

Local cXML 			:= ""
Local cWorkSheet 	:= "Apontamento"
Local nLin			:= 0
Local cAux		  	:= ""
Local cCodigo		:= ""
(_cAliasG)->(DbGoTop()) 

If !(_cAliasG)->(Eof())
	cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
	cXML += '     <Column ss:Width="51.75"/>'+CRLF
	cXML += '     <Column ss:Width="52.5" ss:Span="1"/>'+CRLF
	cXML += '     <Column ss:Index="4" ss:AutoFitWidth="0" ss:Width="66.75"/>'+CRLF
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="63.75"/>'+CRLF
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="134.25"/>'+CRLF
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="69.75"/>'+CRLF
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="144"/>'+CRLF
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="62.25"/>'+CRLF
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="76.5"/>'+CRLF
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="141"/>'+CRLF
	cXML += '     <Column ss:Width="42.75"/>'+CRLF
	cXML += '     <Column ss:Width="43.5"/>'+CRLF
	cXML += '     <Column ss:Width="44.25"/>'+CRLF
	cXML += ' <Row ss:Height="36">' + CRLF
	cXML += '     <Cell ss:MergeAcross="7" ss:StyleID="s62">' + CRLF
	cXML += '     	<Data ss:Type="String">Relatório de Apontamentos</Data>' + CRLF
	cXML += '     </Cell>' + CRLF
	cXML += ' </Row>' + CRLF
	
	While !(_cAliasG)->(Eof())
	
		If AllTrim(cCodigo) <> AllTrim((_cAliasG)->ZAD_ITEM )
			cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
			
			cXML += '<Row ss:AutoFitHeight="0" ss:Height="36">' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Item Contabil</Data></Cell>' + CRLF
			cXML += '  <Cell ss:MergeAcross="2" ss:StyleID="s65"><Data ss:Type="String">Equipamento</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Codigo do Bem</Data></Cell>' + CRLF
			cXML += '</Row>' + CRLF
			cXML += '<Row>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel(  (_cAliasG)->ZAD_FILIAL ) + '</Data></Cell>' + CRLF	
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel(  (_cAliasG)->ZAD_ITEM )+  '</Data></Cell>' + CRLF	
			cXML += '  <Cell ss:MergeAcross="2" ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel(  (_cAliasG)->ZAD_EQUIPA )+  '</Data></Cell>' + CRL
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel(  (_cAliasG)->T9_CODBEM )+  '</Data></Cell>' + CRL
			cXML += '</Row>' + CRLF

			cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF

			cXML += '<Row>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Data</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Inicio</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Fim</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Qtde</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Cod Cent. Custos</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Descrição</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Operador</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Nome</Data></Cell>' + CRLF
			cXML += '</Row>' + CRLF
		EndIf 

		cXML += '<Row>' + CRLF
		cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel(  (_cAliasG)->ZAD_DATA )+  '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel(  (_cAliasG)->ZAD_INICIO ) + '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel(  (_cAliasG)->ZAD_FINAL ) + '</Data></Cell>' + CRLF
		
		// INSERIR FORMULA ZAD_IFINAL-ZAD_INICIO
		cXML += '  <Cell ss:StyleID="sSemDig" ss:Formula="=RC[-1]-RC[-2]"><Data ss:Type="Number"></Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel(  (_cAliasG)->ZAD_CC )+  '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel(  (_cAliasG)->CTT_DESC01 )+  '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel(  (_cAliasG)->ZAD_OPERAD )+  '</Data></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel(  (_cAliasG)->RA_NOME )+  '</Data></Cell>' + CRLF
		cXML += '</Row>' + CRLF
		
		cCodigo := (_cAliasG)->ZAD_ITEM
		(_cAliasG)->(dbSkip())
	EndDo

	cXML += '  </Table>'+CRLF
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
	cXML += '   <PageSetup>'+CRLF
	cXML += '    <Header x:Margin="0.31496062000000002"/>'+CRLF
	cXML += '    <Footer x:Margin="0.31496062000000002"/>'+CRLF
	cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"'+CRLF
	cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>'+CRLF
	cXML += '   </PageSetup>'+CRLF
	cXML += '   <TabColorIndex>13</TabColorIndex>'+CRLF
	cXML += '   <Selected/>'+CRLF
	cXML += '   <Panes>'+CRLF
	cXML += '    <Pane>'+CRLF
	cXML += '     <Number>3</Number>'+CRLF
	cXML += '     <ActiveRow>17</ActiveRow>'+CRLF
	cXML += '     <ActiveCol>9</ActiveCol>'+CRLF
	cXML += '    </Pane>'+CRLF
	cXML += '   </Panes>'+CRLF
	cXML += '   <ProtectObjects>False</ProtectObjects>'+CRLF
	cXML += '   <ProtectScenarios>False</ProtectScenarios>'+CRLF
	cXML += '  </WorksheetOptions>'+CRLF
	cXML += ' </Worksheet>'+CRLF

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
    cStyle += '  <Style ss:ID="s74"> '+CRLF
    cStyle += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/> '+CRLF
    cStyle += '   <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" '+CRLF
    cStyle += '    ss:Color="#000000"/> '+CRLF
    cStyle += '  </Style> '+CRLF
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
	cStyle += ' 	<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += ' 	<NumberFormat ss:Format="#,##0_ ;\-#,##0\ "/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sSemDigN" ss:Parent="s16">'+CRLF
	cStyle += '     <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '      ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += '     <NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s98">'+CRLF
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += '  <Borders>'+CRLF
	cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '  </Borders>'+CRLF
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '   ss:Color="#FFFFFF" ss:Bold="1"/>'+CRLF
	cStyle += '  <Interior ss:Color="#37752F" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s99">'+CRLF
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += '  <Borders>'+CRLF
	cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '  </Borders>'+CRLF
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '   ss:Color="#FFFFFF" ss:Bold="1"/>'+CRLF
	cStyle += '  <Interior ss:Color="#37752F" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s100">'+CRLF
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += '  <Borders>'+CRLF
	cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '  </Borders>'+CRLF
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>'+CRLF
	cStyle += '  <Interior ss:Color="#0070C0" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s101">'+CRLF
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += '  <Borders>'+CRLF
	cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
	cStyle += '  </Borders>'+CRLF
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>'+CRLF
	cStyle += '  <Interior ss:Color="#0070C0" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sPorcent">'+CRLF
	cStyle += '   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+CRLF
	cStyle += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += '   <NumberFormat ss:Format="Percent"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s90" ss:Name="Normal 5">'+CRLF
	cStyle += ' <Alignment ss:Vertical="Bottom"/>'+CRLF
	cStyle += ' <Borders/>'+CRLF
	cStyle += ' <Font ss:FontName="Arial"/>'+CRLF
	cStyle += ' <Interior/>'+CRLF
	cStyle += ' <NumberFormat/>'+CRLF
	cStyle += ' <Protection/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s97">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>'+CRLF
	cStyle += ' </Style>'+CRLF
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
	cStyle += ' <Style ss:ID="sHora">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += ' 	<NumberFormat ss:Format="Short Time"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sTextoNFundoVerdeClaroApuracao" ss:Parent="s16">'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += ' 	<Interior ss:Color="#A9D08E" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sTextoNFundoAzulClaroApuracao">'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += ' 	<Interior ss:Color="#D6DCE4" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sComDigFundoVerdeClaroApuracao" ss:Parent="s16">'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += ' 	<Interior ss:Color="#A9D08E" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sComDigC3FundoVerdeClaroApuracao" ss:Parent="s16">'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += ' 	<Interior ss:Color="#A9D08E" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sRealFundoAzulClaroApuracao">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += ' 	<Interior ss:Color="#D6DCE4" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' 	<NumberFormat ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += ' </Style>'+CRLF
return cStyle
// defStyle

/*
 |--------------------------------------------------------------------------------,
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
Local j         := 0
Local i         := 0
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

aAdd(aRegs,{cPerg, "01", "Data do Lancamento De?"      , "", "", "MV_CH1", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR01", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Data do Lancamento Ate?"     , "", "", "MV_CH2", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR02", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "03", "Equipamentos De?"		       , "", "", "MV_CH3", "C", TamSX3("ZAD_ITEM")[1]  , TamSX3("ZAD_ITEM")[2]  , 0, "G", "NaoVazio", "MV_PAR03", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","CTD","","","","",""})
aAdd(aRegs,{cPerg, "04", "Equipamentos Ate?"		   , "", "", "MV_CH4", "C", TamSX3("ZAD_ITEM")[1]  , TamSX3("ZAD_ITEM")[2]  , 0, "G", "NaoVazio", "MV_PAR04", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","CTD","","","","",""})
// aAdd(aRegs,{cPerg, "04", "Codigo?"        		, "", "", "MV_CH4", "C", TamSX3("ZCI_CODIGO")[1], TamSX3("ZCI_CODIGO")[2], 0, "G", "NaoVazio", "MV_PAR04", ""   , "","",""  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
// aAdd(aRegs,{cPerg, "05", "Valor?"        		, "", "", "MV_CH5", "C", TamSX3("ZSI_VALOR")[1] , TamSX3("ZSI_VALOR")[2] , 0, "G", "NaoVazio", "MV_PAR05", ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
// aAdd(aRegs,{cPerg, "15", "Imprime Outras Movimentacoes?", "", "", "MV_CHF", "N", 					   1,					    0, 2, "C", ""        , "MV_PAR15", "Não", "","",""      ,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})

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
