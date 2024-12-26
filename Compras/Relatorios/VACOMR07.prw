// -> este fonte esta sendo substituido pelo fonte: MBCOMR01

#INCLUDE "FILEIO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
/*
#IFNDEF _ENTER_
	#DEFINE _ENTER_ (Chr(13)+Chr(10))
	// Alert("miguel")
#ENDIF 
*/

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()          		            	      |
 | Func:  VACOMR07()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  11.05.2018	            	          	            	              |
 | Desc:  Função principal, chamada pelo MENU.           	            	      |
 '--------------------------------------------------------------------------------|
 | Alt:   No dia 25.06.2018 converti o relatorio para formulas.	            	  |
 | Obs.:  -	            	                                                      |
 '--------------------------------------------------------------------------------*/
User function VACOMR07()

Local cTimeIni	 	:= Time()
Local lTemDados		:= .T.
Local lTemExcel	    := .F.
Local cStyle		:= ""
Local cXML	   		:= ""
Local nTotQd2		:= 0 
Local nTotQd3		:= 0 
Local nTotQd7		:= 0
Local nTotQd8		:= 0
Local n10fTotQd		:= 3 // posicoes iniciais ate comecar os dados
Local aDadDro8		:= {}

Private cPerg		:= "VACOMR07"
Private cTitulo  	:= "Relatorio Lotes de Compra - Analise"

Private cPath 	 	:= "C:\totvs_relatorios\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()   
Private _cAliasF	:= GetNextAlias()   
Private _cAliasC	:= GetNextAlias()   
//Private _cAliasX	:= GetNextAlias()
Private _cAliasA	:= GetNextAlias()
Private _cAliasQ	:= GetNextAlias()
Private _cAliasE	:= GetNextAlias()
Private _cAliasR	:= GetNextAlias()
Private _cAliasP	:= GetNextAlias()
Private _cAliasO	:= GetNextAlias()
Private _cForAlias	:= GetNextAlias()
Private _cGenAlias	:= GetNextAlias()
Private _cCRDAlias	:= GetNextAlias() // Consumo Ração por data
Private _aDados 	:= {}

Private nHandle    	:= 0
Private nHandAux	:= 0

Private dDIni11F   := sToD("")// := MV_PAR13-7 // (30*1) // 6 Meses, 30 Dias
Private nTTColQ9 	:= 0

GeraX1(cPerg)
	
If Pergunte(cPerg, .T.)

	If MV_PAR20 == 0
		MV_PAR20 := MV_PAR13-MV_PAR12
	EndIf

	dDIni11F   := MV_PAR13-MV_PAR20 // (30*1) // 6 Meses, 30 Dias
	
	U_PrintSX1(cPerg)
	
	If Len( Directory(cPath + "*.*","D") ) == 0
		If Makedir(cPath) == 0
			ConOut('Diretorio Criado com Sucesso.')
		Else	
			ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
		EndIf
	EndIf
	
	nHandle := FCreate(cArquivo)
	if nHandle == -1
		conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	else
		
		cStyle := defStyle()
		
		// Processar SQL
		FWMsgRun(, {|| lTemExcel := lTemDados := VASqlR07("Geral", @_cAliasG ) },'Por Favor Aguarde...' , 'Processando Banco de Dados')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			If MV_PAR23 == 2 // SIM
				FWMsgRun(, {|| lTemDados := VASqlR07("Generico", @_cGenAlias ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Generico')
				If lTemDados
					FWMsgRun(, {|| n10fTotQd := Quadro10f( ) },'Por Favor Aguarde...' , 'Gerando quadro de Valores Genericos')
				EndIf
				(_cGenAlias)->(DbCloseArea())
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Lotes Analitico')
			
			// Gerar segunda planilha
			FWMsgRun(, {|| nTotQd2 := fQuadro2() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Lotes Sintetico')
			
			// Gerar terceira planilha
			FWMsgRun(, {|| nTotQd3 := fQuadro3() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Notas Fiscais')
			
			// Processar SQL
			FWMsgRun(, {|| lTemDados := VASqlR07("Frete", @_cAliasF ) },'Por Favor Aguarde...' , 'Processando Banco de Dados Frete')
			If lTemDados
				FWMsgRun(, {|| fQuadro4() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro 4')
			EndIf
			
			// Processar SQL
			FWMsgRun(, {|| lTemDados := VASqlR07("Complemento", @_cAliasC ) },'Por Favor Aguarde...' , 'Processando Banco de Dados Complemento')
			If lTemDados
				FWMsgRun(, {|| fQuadro5() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro 5')
			EndIf
			/*
			// Processar SQL
			FWMsgRun(, {|| lTemDados := VASqlR07("Faixa", @_cAliasX ) },'Por Favor Aguarde...' , 'Processando Banco de Dados Faixa')
			If lTemDados
				FWMsgRun(, {|| fQuadro6() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro 6')
			EndIf
			*/
			
			// Processar SQL
			FWMsgRun(, {|| lTemDados := VASqlR07("Custo", @_cAliasA ) },'Por Favor Aguarde...' , 'Processando Banco de Dados Custo de Aquisição')
			If lTemDados
				FWMsgRun(, {|| VASqlR07("CustoQuant", @_cAliasQ ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Quantidades')
				
				FWMsgRun(, {|| nTotQd7 := fQuadro7( nTotQd2 ) },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro 7')
				FWMsgRun(, {|| nTotQd8 := fQuadro8( n10fTotQd, nTotQd7, @aDadDro8 ) },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro 8')
				(_cAliasQ)->(DbCloseArea())
			EndIf
		
			If MV_PAR23 == 2 // SIM
				/* MJ : 21/08/2018 : Inicio desenvolvimento
					-> Relatorio Analise - Apuracao; 
				*/
				FWMsgRun(, {|| lTemDados := VASqlR07("Analise", @_cAliasE ) },'Por Favor Aguarde...' , 'Processando Banco de Dados Custo de Aquisição')
				If lTemDados
					FWMsgRun(, {|| VASqlR07("Racao", @_cAliasR ) },'Por Favor Aguarde...' , 'Processando de Dados do Custos com Ração')
					FWMsgRun(, {|| VASqlR07("Peso",  @_cAliasP ) },'Por Favor Aguarde...' , 'Processando de Dados dos Pesos')
					
					FWMsgRun(, {|| VASqlR07("CustoOpera",  @_cAliasO ) },'Por Favor Aguarde...' , 'Processando de Dados dos Pesos')
					FWMsgRun(, {|| VASqlR07("Fornecedor",  @_cForAlias ) },'Por Favor Aguarde...' , 'Processando de Dados dos Pesos')
					
					FWMsgRun(, {|| fQuadro9( nTotQd2, nTotQd3, nTotQd8, aDadDro8 ) },'Por Favor Aguarde...' , 'Gerando quadro de Analise')
					
					(_cAliasR)->(DbCloseArea())
					(_cAliasP)->(DbCloseArea())
					(_cAliasO)->(DbCloseArea())
					(_cForAlias)->(DbCloseArea())
				EndIf
				
				// ########################################################################################################
				FWMsgRun(, {|| lTemDados := VASqlR07("ConsumoxData", @_cCRDAlias ) }, 'Por Favor Aguarde...',;
														'Processando Banco de Dados - Consumo Racao por Data')
				If lTemDados
					FWMsgRun(, {|| Quadro11f( ) },'Por Favor Aguarde...' , 'Gerando quadro do Consumo por Data')
				EndIf
				(_cCRDAlias)->(DbCloseArea())
			EndIf	
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
			
			(_cAliasF)->(DbCloseArea())
			(_cAliasC)->(DbCloseArea())
			// (_cAliasX)->(DbCloseArea())
			(_cAliasA)->(DbCloseArea())
			If MV_PAR23 == 2 // SIM
				(_cAliasE)->(DbCloseArea())
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

return nil	// U_VACOMR07()
// FIM VACOMR07


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:  defStyle()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  25.09.2018	            	          	            	              |
 | Desc:  Gerar variavel para SQL;	            	            				  |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
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
	cStyle += ' <Style ss:ID="s98">' + CRLF
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>' + CRLF
	cStyle += '  <Borders>' + CRLF
	cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '  </Borders>' + CRLF
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"' + CRLF
	cStyle += '   ss:Color="#FFFFFF" ss:Bold="1"/>' + CRLF
	cStyle += '  <Interior ss:Color="#37752F" ss:Pattern="Solid"/>' + CRLF
	cStyle += ' </Style>' + CRLF
	cStyle += ' <Style ss:ID="s99">' + CRLF
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>' + CRLF
	cStyle += '  <Borders>' + CRLF
	cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '  </Borders>' + CRLF
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"' + CRLF
	cStyle += '   ss:Color="#FFFFFF" ss:Bold="1"/>' + CRLF
	cStyle += '  <Interior ss:Color="#37752F" ss:Pattern="Solid"/>' + CRLF
	cStyle += ' </Style>' + CRLF
	cStyle += ' <Style ss:ID="s100">' + CRLF
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>' + CRLF
	cStyle += '  <Borders>' + CRLF
	cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '  </Borders>' + CRLF
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF
	cStyle += '  <Interior ss:Color="#0070C0" ss:Pattern="Solid"/>' + CRLF
	cStyle += ' </Style>' + CRLF
	cStyle += ' <Style ss:ID="s101">' + CRLF
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>' + CRLF
	cStyle += '  <Borders>' + CRLF
	cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
	cStyle += '  </Borders>' + CRLF
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF
	cStyle += '  <Interior ss:Color="#0070C0" ss:Pattern="Solid"/>' + CRLF
	cStyle += ' </Style>' + CRLF
	cStyle += ' <Style ss:ID="sPorcent">' + CRLF
	cStyle += '   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF
	cStyle += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
	cStyle += '   <NumberFormat ss:Format="Percent"/>' + CRLF
	cStyle += ' </Style>' + CRLF
	cStyle += ' <Style ss:ID="s90" ss:Name="Normal 5">' + CRLF
	cStyle += ' <Alignment ss:Vertical="Bottom"/>' + CRLF
	cStyle += ' <Borders/>' + CRLF
	cStyle += ' <Font ss:FontName="Arial"/>' + CRLF
	cStyle += ' <Interior/>' + CRLF
	cStyle += ' <NumberFormat/>' + CRLF
	cStyle += ' <Protection/>' + CRLF
	cStyle += ' </Style>' + CRLF
	cStyle += ' <Style ss:ID="s97">' + CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>' + CRLF
	cStyle += ' </Style>' + CRLF
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
	cStyle += ' <Style ss:ID="sHora">' + CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>' + CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
	cStyle += ' 	<NumberFormat ss:Format="Short Time"/>' + CRLF
	cStyle += ' </Style>' + CRLF
	cStyle += ' <Style ss:ID="sTextoNFundoVerdeClaroApuracao" ss:Parent="s16">' + CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>' + CRLF
	cStyle += ' 	<Interior ss:Color="#A9D08E" ss:Pattern="Solid"/>' + CRLF
	cStyle += ' </Style>' + CRLF
	cStyle += ' <Style ss:ID="sTextoNFundoAzulClaroApuracao">' + CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>' + CRLF
	cStyle += ' 	<Interior ss:Color="#D6DCE4" ss:Pattern="Solid"/>' + CRLF
	cStyle += ' </Style>' + CRLF
	cStyle += ' <Style ss:ID="sComDigFundoVerdeClaroApuracao" ss:Parent="s16">' + CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
	cStyle += ' 	<Interior ss:Color="#A9D08E" ss:Pattern="Solid"/>' + CRLF
	cStyle += ' </Style>' + CRLF
	cStyle += ' <Style ss:ID="sComDigC3FundoVerdeClaroApuracao" ss:Parent="s16">' + CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>' + CRLF
	cStyle += ' 	<Interior ss:Color="#A9D08E" ss:Pattern="Solid"/>' + CRLF
	cStyle += ' </Style>' + CRLF
	cStyle += ' <Style ss:ID="sRealFundoAzulClaroApuracao">' + CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>' + CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
	cStyle += ' 	<Interior ss:Color="#D6DCE4" ss:Pattern="Solid"/>' + CRLF
	cStyle += ' 	<NumberFormat ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>' + CRLF
	cStyle += ' </Style>' + CRLF
Return cStyle
// defStyle


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:   	            	            										  |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  13.09.2018	            	          	            	              |
 | Desc:   	            	            										  |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
User Function PrintSX1(cPerg)

Local cPrint := ""

DbSelectArea('SX1')
DbSetOrder(1)
SX1->(DbGoTop())
If SX1->(DbSeek(cPerg))
	While !SX1->(Eof()) .And. X1_GRUPO = cPerg 
		
		cPrint += IIf(Empty(cPrint),"",CRLF) + ;
				  PadR(AllTrim(SX1->X1_PERGUNT), 30, "_") + ;
				  ": " + ;
				  cValToChar( &(SX1->X1_VAR01) )
		
		SX1->(DbSkip())
	EndDo
EndIf

// If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Parametros.txt" , cPrint)
// EndIf

Return nil


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:  GeraX1()  	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  11.05.2018	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local i         := 0
Local j         := 0
Local nX		:= 0
Local nPergs	:= 0

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

aAdd(aRegs,{cPerg, "01", "Data Compra De?"              , "", "", "MV_CH1", "D", TamSX3("D1_EMISSAO")[1], TamSX3("D1_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR01", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Data Compra Ate?"             , "", "", "MV_CH2", "D", TamSX3("D1_EMISSAO")[1], TamSX3("D1_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR02", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "03", "Filial De?"    		        , "", "", "MV_CH3", "C", TamSX3("D1_FILIAL")[1] , TamSX3("D1_FILIAL")[2] , 0, "G", ""		 , "MV_PAR03", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "04", "Filial Ate?"    		        , "", "", "MV_CH4", "C", TamSX3("D1_FILIAL")[1] , TamSX3("D1_FILIAL")[2] , 0, "G", "NaoVazio", "MV_PAR04", ""   , "","","ZZ"	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "05", "Contrato De?"    		        , "", "", "MV_CH5", "C", TamSX3("ZBC_CODIGO")[1], TamSX3("ZBC_CODIGO")[2], 0, "G", ""		 , "MV_PAR05", ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "06", "Contrato Ate?"   		        , "", "", "MV_CH6", "C", TamSX3("ZBC_CODIGO")[1], TamSX3("ZBC_CODIGO")[2], 0, "G", "NaoVazio", "MV_PAR06", ""   , "","","ZZZZZZ","",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "07", "Ped. Compra De?"		        , "", "", "MV_CH7", "C", TamSX3("ZBC_PEDIDO")[1], TamSX3("ZBC_PEDIDO")[2], 0, "G", ""		, "mv_par07" , ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","SC7","","","","",""})
aAdd(aRegs,{cPerg, "08", "Ped. Compra Ate?"		        , "", "", "MV_CH8", "C", TamSX3("ZBC_PEDIDO")[1], TamSX3("ZBC_PEDIDO")[2], 0, "G", "NaoVazio", "mv_par08", ""   , "","","ZZZZZZ","",""   ,"","","","","","","","","","","","","","","","","","","SC7","","","","",""})
aAdd(aRegs,{cPerg, "09", "Fornecedor De?"		        , "", "", "MV_CH9", "C", TamSX3("ZBC_CODFOR")[1], TamSX3("ZBC_CODFOR")[2], 0, "G", ""		, "mv_par09" , ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","SA2","","","","",""})
aAdd(aRegs,{cPerg, "10", "Fornecedor Ate?"		        , "", "", "MV_CHA", "C", TamSX3("ZBC_CODFOR")[1], TamSX3("ZBC_CODFOR")[2], 0, "G", "NaoVazio", "mv_par10", ""   , "","","ZZZZZZ","",""   ,"","","","","","","","","","","","","","","","","","","SA2","","","","",""})
aAdd(aRegs,{cPerg, "11", "Baia: (Separado por virgula)" , "", "", "MV_CHB", "C", 					  99, 					    0, 0, "G", ""		, "mv_par11" , ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "12", "Data Abate De?"               , "", "", "MV_CHC", "D", TamSX3("D2_EMISSAO")[1], TamSX3("D2_EMISSAO")[2], 0, "G", "        ", "MV_PAR12", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "13", "Data Abate Ate?"              , "", "", "MV_CHD", "D", TamSX3("D2_EMISSAO")[1], TamSX3("D2_EMISSAO")[2], 0, "G", "        ", "MV_PAR13", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "14", "Imprime Emergencia?"          , "", "", "MV_CHE", "N", 					   1,					    0, 1, "C", ""        , "MV_PAR14", "Não", "","",""      ,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "15", "Imprime Outras Movimentacoes?", "", "", "MV_CHF", "N", 					   1,					    0, 1, "C", ""        , "MV_PAR15", "Não", "","",""      ,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "16", "Exibe Auxiliares?"			, "", "", "MV_CHG", "N", 					   1,					    0, 1, "C", ""        , "MV_PAR16", "Não", "","",""      ,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "17", "Data Valor?"		    		, "", "", "MV_CHH", "D", TamSX3("ZSI_DATA")[1]  , TamSX3("ZSI_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR17", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","ZSI","","","","",""})
aAdd(aRegs,{cPerg, "18", "Codigo?"        				, "", "", "MV_CHI", "C", TamSX3("ZCI_CODIGO")[1], TamSX3("ZCI_CODIGO")[2], 0, "G", "NaoVazio", "MV_PAR18", ""   , "","",""  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "19", "Valor?"        				, "", "", "MV_CHJ", "N", TamSX3("ZSI_VALOR")[1] , TamSX3("ZSI_VALOR")[2] , 0, "G", "NaoVazio", "MV_PAR19", ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "20", "Qt. Dias Ração x Data ?"      , "", "", "MV_CHK", "N",                       3,                       0, 0, "G", "NaoVazio", "MV_PAR20", ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "21", "ICMS a recuperar? %"			, "", "", "MV_CHL", "N",                       3,                       0, 0, "G", "NaoVazio", "MV_PAR21", ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "22", "Somente os Faturados?"		, "", "", "MV_CHM", "N",                       1,                       0, 2, "C", "NaoVazio", "MV_PAR22", "Não", "","",""	  	,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "23", "INCLUIR Analise e Outros?"	, "", "", "MV_CHN", "N",                       1,                       0, 2, "C", "NaoVazio", "MV_PAR23", "Não", "","",""	  	,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})

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


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:  VASqlR07()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  11.05.2018	            	          	            	              |
 | Desc:  Processamento do SQL, salvando em variavel PRIVADA;  	            	  |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function VASqlR07(cTipo, _cAlias)
Local _cQry 		:= ""
Local cSQLInicio 	:= ""

If cTipo == "Generico"

	_cQry := " WITH " + CRLF
	_cQry += "	ENTRADA AS " + CRLF
	_cQry += "	( " + CRLF
	_cQry += "			SELECT B1_X_SEXO SEXO " + CRLF
	_cQry += "			, B1_DESC DESCRICAO " + CRLF
	_cQry += "			, B1_XRACA RACA " + CRLF
	_cQry += "			, D1_FILIAL " + CRLF
	_cQry += "			, D1_FORNECE " + CRLF
	_cQry += "			, D1_LOJA " + CRLF
	_cQry += "			, D1_DOC	 " + CRLF
	_cQry += "			, D1_SERIE " + CRLF
	_cQry += "			, ZBC_PRODUT CODIGO_BOV " + CRLF
	_cQry += "			, D1_QUANT QTD_NF " + CRLF
	_cQry += "			, D1_TOTAL " + CRLF
	_cQry += "			, ZBC_VLFRPG FRETE " + CRLF
	_cQry += " 			, ZBC_VLRCOM COMISSAO " + CRLF
	_cQry += " 			, ZBC_ICFRVL ICMS_FRETE_GADO " + CRLF
	_cQry += " 			, D1_VALICM " + CRLF
	_cQry += "			FROM SD1010 D1 " + CRLF
	_cQry += "			JOIN ZBC010 BC ON ZBC_FILIAL=D1_FILIAL AND ZBC_PRODUT=D1_COD " + CRLF
	_cQry += "								AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
	_cQry += "									( " + CRLF
	_cQry += "										SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
	_cQry += "										FROM ZBC010 " + CRLF
	_cQry += "										WHERE D_E_L_E_T_=' ' " + CRLF
	_cQry += "										GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
	_cQry += "									) " + CRLF
	_cQry += "								AND BC.D_E_L_E_T_=' ' AND D1.D_E_L_E_T_=' ' " + CRLF
	_cQry += "			JOIN " + RetSQLName('SB1') + " B1 ON B1_FILIAL=' ' AND B1_COD=D1_COD AND D1.D_E_L_E_T_=' ' " + CRLF
	_cQry += "			WHERE D1_EMISSAO >= CONVERT(VARCHAR, GETDATE()-120, 112) " + CRLF
	_cQry += "			  AND D1_TIPO='N' " + CRLF
	_cQry += "			-- AND B1_X_SEXO='MACHO' " + CRLF
	_cQry += "			-- AND B1_XRACA='NELORE' " + CRLF
	_cQry += "			AND B1_XRACA<>' ' " + CRLF
	_cQry += "			-- AND B1_X_ERA='BOI' " + CRLF
	_cQry += "			-- ORDER BY 1,2,3 " + CRLF
	_cQry += "	) " + CRLF
	_cQry += CRLF
	_cQry += " , COMPLEMENTO AS " + CRLF
	_cQry += "  	( " + CRLF
	_cQry += "  	    SELECT DISTINCT D1.D1_FILIAL, D1.D1_DOC, D1.D1_SERIE, D1.D1_EMISSAO, D1.D1_FORNECE, D1.D1_LOJA, A2.A2_NOME, D1.D1_COD, " + CRLF
	_cQry += "						B1.B1_DESC, D1.D1_VALICM, D1.D1_TOTAL " + CRLF
	_cQry += "  	    		, CASE " + CRLF
	_cQry += "  	    		   	WHEN D1_TIPO = 'C' " + CRLF
	_cQry += "  	    		   	   	THEN  'VALOR' " + CRLF
	_cQry += "  	    		   	   	ELSE CASE WHEN D1_TIPO = 'I' THEN 'ICMS' ELSE '' END " + CRLF
	_cQry += "  	    		END TIPO_COMPLEMENTO " + CRLF
	_cQry += "  	    	FROM ENTRADA E " + CRLF
	_cQry += "        LEFT JOIN SD1010 D1 ON " + CRLF
	_cQry += "  	    	    E.D1_FILIAL		=	D1.D1_FILIAL " + CRLF
	_cQry += "  	    	AND E.D1_FORNECE	=	D1.D1_FORNECE " + CRLF
	_cQry += "  	    	AND E.D1_LOJA		=	D1.D1_LOJA " + CRLF
	_cQry += "  	    	AND E.D1_DOC		=	D1.D1_NFORI " + CRLF
	_cQry += "  	    	AND E.D1_SERIE		=	D1.D1_SERIORI " + CRLF
	_cQry += "  	    	AND D1.D1_TIPO		<>	'N' " + CRLF
	_cQry += " 	    	AND D1.D_E_L_E_T_	=	' ' " + CRLF
	_cQry += " 	  	INNER JOIN SA2010 A2 ON " + CRLF
	_cQry += "    		        A2.A2_FILIAL =	' ' " + CRLF
	_cQry += "  		  	    AND A2.A2_COD					=		D1.D1_FORNECE " + CRLF
	_cQry += "  		  		AND A2.A2_LOJA					=		D1.D1_LOJA " + CRLF
	_cQry += "  		 	 	AND A2.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " 		INNER JOIN " + RetSQLName('SB1') + " B1 ON " + CRLF
	_cQry += "          			B1_FILIAL	= ' ' " + CRLF
	_cQry += "          		AND B1_COD = CODIGO_BOV " + CRLF
	_cQry += " 				AND B1_RASTRO = 'L' " + CRLF
	_cQry += " 				AND B1.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	    WHERE D1.D1_DOC IS NOT NULL  AND D1.D1_DOC <> ' ' " + CRLF
	_cQry += "  	) " + CRLF
	_cQry += CRLF
	_cQry += ", DADOS AS ( " + CRLF
	_cQry += "	SELECT	  SEXO " + CRLF
	_cQry += "			, DESCRICAO " + CRLF
	_cQry += "			, RACA " + CRLF
	_cQry += "			, QTD_NF " + CRLF
	_cQry += "			, ISNULL( E.D1_TOTAL , 0) TOTAL_NF " + CRLF
	_cQry += "			, ISNULL( NC.D1_TOTAL, 0) TOTAL_NF_COMPL " + CRLF
	_cQry += "			, FRETE " + CRLF
	_cQry += " 			, COMISSAO " + CRLF
	_cQry += " 			, ICMS_FRETE_GADO " + CRLF
	_cQry += " 			, E.D1_VALICM " + CRLF
	_cQry += "			, ISNULL( NC.D1_VALICM,0) ICMS_COMPL " + CRLF
	_cQry += CRLF
	_cQry += "	FROM	ENTRADA E " + CRLF
	_cQry += "		LEFT JOIN COMPLEMENTO NC " + CRLF
	_cQry += "  					ON NC.D1_FILIAL			=	E.D1_FILIAL " + CRLF
	_cQry += "  					AND NC.D1_FORNECE		=	E.D1_FORNECE " + CRLF
	_cQry += "  					AND NC.D1_LOJA			=	E.D1_LOJA " + CRLF
	_cQry += "  					AND NC.D1_DOC		=	E.D1_DOC " + CRLF
	_cQry += "  					AND RTRIM(NC.D1_COD)	=	RTRIM(E.CODIGO_BOV) " + CRLF
	_cQry += CRLF
	_cQry += "	GROUP BY SEXO, DESCRICAO, RACA, QTD_NF, E.D1_TOTAL, NC.D1_TOTAL,  FRETE " + CRLF
	_cQry += " 			, COMISSAO " + CRLF
	_cQry += " 			, ICMS_FRETE_GADO " + CRLF
	_cQry += " 			, E.D1_VALICM " + CRLF
	_cQry += "			, NC.D1_VALICM " + CRLF
	_cQry += " ) " + CRLF
	_cQry += CRLF
	_cQry += " SELECT	  SEXO " + CRLF
	_cQry += "  	    , DESCRICAO " + CRLF
	_cQry += "  		, RACA " + CRLF
	_cQry += "  	    , SUM( QTD_NF	) QTD_NF			 " + CRLF
	_cQry += "  	    , SUM( TOTAL_NF ) TOTAL_NF " + CRLF
	_cQry += "  	    , SUM( TOTAL_NF ) + SUM( TOTAL_NF_COMPL ) TOTAL_NF_MAIS_COMPL			 " + CRLF
	_cQry += " 		    , SUM( FRETE ) FRETE " + CRLF
	_cQry += " 		    , SUM (COMISSAO ) COMISSAO " + CRLF
	_cQry += " 		    , SUM ( ICMS_FRETE_GADO ) ICMS_FRETE_GADO " + CRLF
	_cQry += " 		    , SUM( D1_VALICM ) + SUM( ICMS_COMPL ) ICMS_GADO_MAIS_COMPL " + CRLF
	_cQry += " FROM DADOS " + CRLF
	_cQry += " GROUP BY   SEXO " + CRLF
	_cQry += "  	    , DESCRICAO " + CRLF
	_cQry += "  		, RACA " + CRLF
	_cQry += " ORDER BY 1,2,3 " + CRLF


ElseIf cTipo == "CustoOpera"

	/* carregar o email, para pegar o CUSTO OPERACIONAL do mes,
	cadastrado na tabela SX% -> ZC; */	
	_cQry := " SELECT X5_CHAVE, X5_DESCRI " + CRLF
	_cQry += " FROM SX5010 " + CRLF
	_cQry += " WHERE " + CRLF
	_cQry += " 	D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	AND X5_TABELA = 'ZC' " + CRLF
	_cQry += " ORDER BY X5_CHAVE " + CRLF

ElseIf cTipo $ ("Racao,ConsumoxData")

	_cQry := " WITH TRATO_ANIMAL AS ( " + CRLF
	_cQry += " 		SELECT D3.D3_FILIAL											 AS		FILIAL, " + CRLF
	_cQry += " 			   D3.D3_LOTECTL				  AS		LOTE, " + CRLF
	_cQry += " 			   D31.D3_COD											 AS		COD_INSUMO, " + CRLF
	_cQry += " 			   D31.D3_LOCAL, " + CRLF
	_cQry += " 			   D3.D3_EMISSAO										 AS		DATA_TRATO, " + CRLF
	_cQry += " 			   SUM(D31.D3_QUANT)					                 AS		QT_INSUMO " + CRLF
	_cQry += " 		  FROM SD3010 D3 " + CRLF
	_cQry += " 	INNER JOIN SD3010 D31 ON    D31.D3_FILIAL			=				D3.D3_FILIAL " + CRLF
	_cQry += " 							AND D31.D3_OP				=				D3.D3_OP " + CRLF
	_cQry += " 							AND D31.D3_GRUPO				=				'03' " + CRLF
	_cQry += " 							AND D31.D_E_L_E_T_			=				' ' " + CRLF
	_cQry += " 	INNER JOIN SF5010 F5 ON F5.F5_FILIAL=' ' " + CRLF
	_cQry += " 						AND F5_CODIGO = D3.D3_TM " + CRLF
	_cQry += " 						AND F5.D_E_L_E_T_			=				' ' " + CRLF
	_cQry += " 		 WHERE D3.D3_FILIAL				BETWEEN			'  '		AND			'ZZ' " + CRLF
	// _cQry += " 		   AND D3.D3_LOTECTL			IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
	If cTipo == "Racao"
		_cQry += " 		   AND D3.D3_EMISSAO			BETWEEN	'"+ DtoS(MV_PAR01) +"' AND '"+ DtoS(MV_PAR02) + "'" + CRLF
	Else
		_cQry += " 		   AND D3.D3_EMISSAO			BETWEEN	'"+ DtoS(dDIni11F) +"' AND '"+ DtoS(MV_PAR13-1) + "'" + CRLF
	EndIF
	_cQry += " 		   AND D3.D3_CF					=				'PR0' " + CRLF
	_cQry += " 		   AND D3.D3_LOTECTL <> ' '" + CRLF
	_cQry += " 		   AND D3.D3_ESTORNO			<>				'S' " + CRLF
	_cQry += " 		   AND D3.D_E_L_E_T_			=				' ' " + CRLF
	_cQry += " 	 GROUP BY D3.D3_FILIAL, D3.D3_LOTECTL, D31.D3_COD, D31.D3_LOCAL, D3.D3_EMISSAO " + CRLF
	_cQry += " ), " + CRLF
    _cQry += CRLF
	_cQry += " RACAO AS ( " + CRLF
	_cQry += " 	   SELECT D3C.D3_FILIAL, D3C.D3_COD, D3C.D3_LOCAL, D3C.D3_EMISSAO, D3C.D3_OP, SUM(D3C.D3_QUANT) QT_RACAO," + CRLF
	_cQry += " 	   				SUM(D3C.D3_CUSTO1) CUSTO, SUM(D3C.D3_CUSTO1)/SUM(D3C.D3_QUANT) CM " + CRLF
	_cQry += " 		 FROM SD3010 D3C " + CRLF
	_cQry += " 		 JOIN TRATO_ANIMAL T ON	D3C.D3_FILIAL	= T.FILIAL " + CRLF
	_cQry += " 							AND D3C.D3_TM		= '001' " + CRLF
	_cQry += " 							AND D3C.D3_COD		= T.COD_INSUMO " + CRLF
	_cQry += " 							AND D3C.D3_LOCAL	= T.D3_LOCAL " + CRLF
	_cQry += " 							AND D3C.D3_EMISSAO	= T.DATA_TRATO " + CRLF
	_cQry += " 							AND D_E_L_E_T_		= ' ' " + CRLF
	_cQry += " 	  GROUP BY D3C.D3_FILIAL, D3C.D3_COD, D3C.D3_LOCAL, D3C.D3_EMISSAO, D3C.D3_OP " + CRLF
	_cQry += " ), " + CRLF
	_cQry += CRLF
	_cQry += " FEIJAO AS ( " + CRLF
	_cQry += " 		SELECT D3.D3_OP, ISNULL(SUM(D3_QUANT),0) QT_FEIJAO, ISNULL(SUM(D3_CUSTO1),0) CST_FEIJAO " + CRLF
	_cQry += " 		FROM SD3010 D3 " + CRLF
	_cQry += " 		LEFT JOIN RACAO R ON " + CRLF
	_cQry += " 		R.D3_FILIAL = D3.D3_FILIAL AND" + CRLF
	_cQry += " 		R.D3_OP = D3.D3_OP " + CRLF
	_cQry += " 		WHERE D3.D3_FILIAL<>' '" + CRLF
	_cQry += " 		  AND D3.D3_TM	='999' " + CRLF
	_cQry += " 		  AND D3.D3_CF='RE1' " + CRLF
	_cQry += " 		  AND D3.D3_COD IN ('020156') " + CRLF
	_cQry += " 		  AND D_E_L_E_T_ =	' '" + CRLF
	_cQry += " 		GROUP BY D3.D3_OP " + CRLF
    _cQry += "  ), " + CRLF
	_cQry += CRLF
	_cQry += " PROD_RACAO AS ( " + CRLF
	_cQry += " 		SELECT P.D3_FILIAL, P.D3_COD, P.D3_LOCAL, P.D3_EMISSAO," + CRLF
	_cQry += " 				SUM(QT_RACAO) QT_RACAO, SUM(CUSTO)-ISNULL(SUM(F.CST_FEIJAO),0) CUSTO," + CRLF
	_cQry += "				(SUM(CUSTO)-ISNULL(SUM(F.CST_FEIJAO),0))/SUM(QT_RACAO) CM" + CRLF
	_cQry += " 		FROM RACAO P " + CRLF
	_cQry += " 		LEFT JOIN FEIJAO F ON P.D3_OP=F.D3_OP " + CRLF
	_cQry += " 		GROUP BY P.D3_FILIAL, P.D3_COD, P.D3_LOCAL, P.D3_EMISSAO " + CRLF
    _cQry += " ), " + CRLF
	_cQry += CRLF
	_cQry += " LOTE AS ( " + CRLF
	_cQry += " 	SELECT T.LOTE, T.DATA_TRATO, T.QT_INSUMO, ROUND(P.CM*T.QT_INSUMO,2) AS CUSTO " + CRLF
	_cQry += " 	FROM TRATO_ANIMAL T " + CRLF
	_cQry += " 	JOIN PROD_RACAO P ON T.FILIAL = P.D3_FILIAL " + CRLF
	_cQry += " 					 AND T.COD_INSUMO	= P.D3_COD " + CRLF
	_cQry += " 					 AND T.D3_LOCAL		= P.D3_LOCAL " + CRLF
	_cQry += " 					 AND T.DATA_TRATO	= P.D3_EMISSAO " + CRLF
	_cQry += " ) " + CRLF
    _cQry += CRLF
	
	If cTipo == "Racao"
		_cQry += " SELECT		LOTE, sum(CUSTO)  CUSTO " + CRLF
	Else
		_cQry += " SELECT	LOTE, DATA_TRATO " + CRLF
		_cQry += " 			, SUM(CUSTO)  CUSTO" + CRLF
		_cQry += " 		    , SUM(QT_INSUMO) QT_INSUMO " + CRLF
		_cQry += " 			, SUM(CUSTO) / SUM(QT_INSUMO) CM " + CRLF
	EndIf
	
	_cQry += " FROM		LOTE " + CRLF
	
	If cTipo == "Racao"
		_cQry += " GROUP BY	LOTE " + CRLF
	Else
		_cQry += " GROUP BY	LOTE, DATA_TRATO " + CRLF
		_cQry += " ORDER BY	LOTE, DATA_TRATO " + CRLF
	EndIf
	
ElseIf cTipo == "Peso"

	_cQry := " WITH FATURAMENTO  AS ( " + CRLF
	_cQry += "     	SELECT DISTINCT D2_FILIAL FILIAL, " + CRLF
	_cQry += "    	    --D2_XCODABT CODIGO_ABATE, " + CRLF
	_cQry += "    		D2_LOTECTL LOTE, " + CRLF
	_cQry += "    		D2_EMISSAO EMISSAO_NF, " + CRLF
	_cQry += "    		B8_XDATACO DAT_INICIO, " + CRLF
	_cQry += "    		B8_XPESOCO PESO_INICIO, " + CRLF
	_cQry += "     		--ZBC_PESO, " + CRLF
	_cQry += "     		D2_XDTABAT DATA_ABATE, " + CRLF
	_cQry += "     		datediff(DAY, B8_XDATACO,D2_EMISSAO) DIAS_CONF, " + CRLF
	_cQry += "     		ROUND((SUM(D2_XPESLIQ)/SUM(D2_QUANT)-B8_XPESOCO)/datediff(DAY, B8_XDATACO,D2_EMISSAO) ,3) AS GMD, " + CRLF
	_cQry += "     		SUM(D2_XPESLIQ) PESO , SUM(D2_QUANT) QTD, " + CRLF
	_cQry += "     		ROUND(SUM(D2_XPESLIQ)/SUM(D2_QUANT),2) PESO_MEDIO " + CRLF
	_cQry += "     	FROM SD2010 D2 " + CRLF
	_cQry += "     	JOIN SB8010 B8 ON B8_PRODUTO = D2_COD AND B8_LOTECTL = D2_LOTECTL AND B8.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "		JOIN SF4010 F4 ON D2_TES = F4.F4_CODIGO AND F4.D_E_L_E_T_ = ' ' AND D2.D_E_L_E_T_=' ' " + CRLF
	_cQry += "		   								AND F4_TRANFIL <> '1' " + CRLF
	_cQry += "     	WHERE D2_XPESLIQ > 0 " + CRLF
	_cQry += "		  AND D2_LOTECTL <> ' ' " + CRLF
	_cQry += "     	GROUP BY D2_FILIAL, D2_LOTECTL, D2_EMISSAO, D2_XDTABAT, B8_XDATACO, B8_XPESOCO " + CRLF
	_cQry += " ), " + CRLF
	_cQry += CRLF
	_cQry += " ABATE AS ( " + CRLF
	_cQry += "     SELECT ZAB_FILIAL FILIAL, " + CRLF
	_cQry += "    	    ZAB_BAIA LOTE, " + CRLF
	_cQry += "     		ZAB_DTABAT DATA_ABATE, " + CRLF
	_cQry += "     		SUM(ZAB_PESOLQ) PESO_ABATE, " + CRLF
	_cQry += "    		SUM(ZAB_QTABAT) QTD, " + CRLF
	_cQry += "     		SUM(ZAB_VLRTOT) VALOR_TOTAL," + CRLF
	_cQry += " 		    ZAB_VLRARR VLR_ARROB, " + CRLF
	_cQry += " 		    SUM(ZAB_VLRECE) ZAB_VLRECE " + CRLF
	_cQry += "    		FROM ZAB010 " + CRLF
	_cQry += "    		WHERE " + CRLF
	_cQry += " 		--ZAB_DTABAT BETWEEN '20180827' AND '20180904' " + CRLF
	_cQry += "    		--AND " + CRLF
	_cQry += " 		ZAB010.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "    		GROUP BY ZAB_FILIAL, ZAB_BAIA, ZAB_DTABAT, ZAB_VLRARR" + CRLF
	_cQry += " ), " + CRLF
	_cQry += CRLF
	_cQry += " FILIAISA AS ( " + CRLF
	_cQry += " 		SELECT ZAB_FILIAL, ZAB_CODIGO, ZAB_DTABAT, ZAB_PESOLQ, ZAB_VLRTOT " + CRLF
	_cQry += " 		FROM ZAB010 " + CRLF
	_cQry += " 		WHERE ZAB_FILIAL <> '01' " + CRLF
	_cQry += " 		--AND ZAB_DTABAT BETWEEN '20180827' AND '20180904' AND D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " ), " + CRLF
	_cQry += CRLF
	_cQry += " FILIAISD2 AS ( " + CRLF
	_cQry += " 		SELECT D2_FILIAL FILIAL, D2_XCODABT, '' AS LOTE, '' AS EMISSAO_NF, '' DAT_INICIO, '' PESO_INICIO, '' DIAS_CONF, '' GMD, " + CRLF
	_cQry += " 			  SUM(D2_XPESLIQ) PESO, SUM(D2_QUANT) QTD, ROUND(SUM(D2_XPESLIQ)/SUM(D2_QUANT),2) PESO_MEDIO " + CRLF
	_cQry += " 		FROM SD2010 " + CRLF
	_cQry += " 		WHERE D2_FILIAL <> '01' " + CRLF
	_cQry += "		  AND D2_LOTECTL <> ' ' " + CRLF
	_cQry += " 		GROUP BY D2_FILIAL, D2_XCODABT " + CRLF
	_cQry += " )," + CRLF
	_cQry += CRLF
	_cQry += " DADOS AS (" + CRLF
	_cQry += " 	SELECT F.FILIAL, F.LOTE, F.EMISSAO_NF, F.DAT_INICIO, F.PESO_INICIO, F.DATA_ABATE, F.DIAS_CONF, F.GMD, " + CRLF
	_cQry += "		   F.PESO, A.QTD, F.PESO_MEDIO, A.PESO_ABATE, A.VALOR_TOTAL, VLR_ARROB, A.ZAB_VLRECE " + CRLF
	_cQry += " 	FROM FATURAMENTO F " + CRLF
	_cQry += " 	JOIN ABATE A ON	F.FILIAL = A.FILIAL " + CRLF
	_cQry += " 				AND F.LOTE = A.LOTE " + CRLF
	_cQry += " 				AND F.DATA_ABATE = A.DATA_ABATE " + CRLF
	_cQry += CRLF
	_cQry += "    UNION " + CRLF
	_cQry += CRLF
	_cQry += " 	SELECT FILIAL, '' AS LOTE, EMISSAO_NF, '' DAT_INICIO, '' PESO_INICIO, ZAB_DTABAT, '' DIAS_CONF, '' GMD, " + CRLF
	_cQry += "         PESO, QTD, PESO_MEDIO,  ZAB_PESOLQ, ZAB_VLRTOT, 0 VLR_ARROB, 0 ZAB_VLRECE " + CRLF
	_cQry += " 	FROM FILIAISD2 SD2 " + CRLF
	_cQry += " 	JOIN FILIAISA A ON SD2.FILIAL = A.ZAB_FILIAL " + CRLF
	_cQry += " 				   AND SD2.D2_XCODABT = ZAB_CODIGO " + CRLF
	_cQry += CRLF
	_cQry += " UNION ALL " + CRLF
	_cQry += CRLF
	_cQry += " 	SELECT D2_FILIAL FILIAL, D2_LOTECTL LOTE, D2_EMISSAO, B8_XDATACO DATA_INICIO, B8_XPESOCO PESO_INICIO, D2_XDTABAT DATA_ABATE, " + CRLF
	_cQry += " 		   DateDiff(DAY, B8_XDATACO,D2_EMISSAO) DIAS_CONF, ROUND((SUM(D2_XPESLIQ)/SUM(D2_QUANT)-B8_XPESOCO)/datediff(DAY, B8_XDATACO,D2_EMISSAO) ,3) AS GMD, " + CRLF
	_cQry += " 		   SUM(D2_XPESLIQ) PESO, SUM(D2_QUANT) QTD, SUM(D2_XPESLIQ)/SUM(D2_QUANT) PESO_MEDIO, " + CRLF
	_cQry += " 		   ROUND(SUM(ZAB_PESOLQ)/SUM(ZAB_QTABAT),2)*SUM(D2_QUANT) PESO_ABATE, " + CRLF
	_cQry += " 		   ROUND(SUM(ZAB_VLRTOT)/SUM(ZAB_QTABAT)*SUM(D2_QUANT),2) VALOR_TOTAL, " + CRLF
	_cQry += " 		   0 VLR_ARROB, 0 ZAB_VLRECE " + CRLF
	_cQry += " 	FROM ZAB010 AB " + CRLF
	_cQry += " 	JOIN SD2010 D2 ON D2.D2_XCODABT = ZAB_CODIGO AND D2.D2_XDTABAT = ZAB_DTABAT AND D2.D2_LOTECTL <> ' ' " + CRLF
	_cQry += " 	JOIN SB8010    ON B8_FILIAL = D2_FILIAL AND B8_PRODUTO = D2_COD AND B8_LOTECTL = D2_LOTECTL " + CRLF
	_cQry += " 	WHERE ZAB_BAIA = ' ' " + CRLF
	_cQry += " 	GROUP BY D2_FILIAL, D2_LOTECTL, D2_EMISSAO, B8_XDATACO, B8_XPESOCO, D2_XDTABAT, " + CRLF
	_cQry += " 			 ZAB_CODIGO, ZAB_DTABAT, ZAB_VLRECE " + CRLF
	_cQry += " )" + CRLF
	_cQry += CRLF
	_cQry += "  , VLR_RECEBIDO AS ( " + CRLF
	_cQry += " 	 SELECT	LOTE, DATA_ABATE, SUM(PESO_ABATE) PES_TTABATE, SUM(ZAB_VLRECE) ZAB_VR_VLRECE " + CRLF
	_cQry += " 	 /* FILIAL,		LOTE,		EMISSAO_NF,	 DAT_INICIO, PESO_INICIO, DATA_ABATE, DIAS_CONF, GMD, PESO, QTD, " + CRLF
	_cQry += " 			PESO_MEDIO, PESO_ABATE, VALOR_TOTAL, VLR_ARROB,  ZAB_VLRECE " + CRLF
	_cQry += " 			*/ " + CRLF
	_cQry += " 	FROM		DADOS " + CRLF
	_cQry += " 	GROUP BY LOTE, DATA_ABATE " + CRLF
	_cQry += " ) " + CRLF
	_cQry += CRLF
	_cQry += " SELECT D.* " + CRLF
	_cQry += " 		, V.PES_TTABATE " + CRLF
	_cQry += " 		, V.ZAB_VR_VLRECE ZAB_TT_VLRECE " + CRLF
	_cQry += " FROM DADOS		  D " + CRLF
	_cQry += " JOIN VLR_RECEBIDO V ON D.LOTE=V.LOTE AND D.DATA_ABATE=V.DATA_ABATE " + CRLF
	_cQry += " WHERE	-- LOTE IN (" + U_cValToSQL(MV_PAR11,",") + ")" + CRLF
	// _cQry += " 		AND EMISSAO_NF BETWEEN	'"+ DtoS(MV_PAR01) +"' AND '"+ DtoS(MV_PAR02) + "'" + CRLF
	_cQry += " 		    EMISSAO_NF BETWEEN	'"+ DtoS(MV_PAR01) +"' AND '"+ DtoS(MV_PAR02) + "'" + CRLF
	_cQry += " 		AND D.DATA_ABATE BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13+1) + "'" + CRLF
	_cQry += " ORDER BY	DATA_ABATE, LOTE, QTD DESC " + CRLF
	// "Peso"
	
Else
 
	cSQLInicio := " CONTRATO AS " + CRLF
	cSQLInicio += " 		( " + CRLF
	cSQLInicio += "       SELECT ZBC_FILIAL					   	   FILIAL, " + CRLF
	cSQLInicio += " 			 ZBC_CODIGO						   COD_CONTRATO, " + CRLF
	cSQLInicio += " 			 ZBC_PEDIDO					       NUMERO_LOTE, " + CRLF
	cSQLInicio += "			 	 ZBC_ITEMPC, " + CRLF
	cSQLInicio += " 			 ZBC_CODFOR					       CODIGO_FORNEC, " + CRLF
	cSQLInicio += " 			 ZBC_LOJFOR						   LOJA_FORNEC, " + CRLF
	cSQLInicio += " 			 A2.A2_NOME					       VENDEDOR, " + CRLF
	cSQLInicio += " 			 A2_MUN						       ORIGEM, " + CRLF
	cSQLInicio += " 			 A2_EST						       ESTADO, " + CRLF
	cSQLInicio += " 			 ZBC_X_CORR					       COD_CORRETOR, " + CRLF
	cSQLInicio += " 			 A3_NOME					       CORRETOR, " + CRLF
	cSQLInicio += " 			 ZBC_PRODUT					       CODIGO_BOV, " + CRLF
	cSQLInicio += " 			 ZBC_PRDDES					       DESCRICAO, " + CRLF
	cSQLInicio += " 			 BC.ZBC_QUANT				       QTD_COMPRA, " + CRLF
	cSQLInicio += " 			 CASE WHEN BC.ZBC_RACA = 'N' THEN 'NELORE'" + CRLF
	cSQLInicio += " 			 	  WHEN BC.ZBC_RACA = 'A' THEN 'ANGUS'" + CRLF
	cSQLInicio += " 			 	  WHEN BC.ZBC_RACA = 'M' THEN 'MESTICO'" + CRLF
	cSQLInicio += " 			 							 ELSE 'VERIFICAR'" + CRLF
	cSQLInicio += " 			 						     END AS RACA," + CRLF
	cSQLInicio += " 			 CASE WHEN BC.ZBC_SEXO = 'M' THEN 'MACHO'" + CRLF
	cSQLInicio += " 			 	  WHEN BC.ZBC_SEXO = 'F' THEN 'FEMEA'" + CRLF
	cSQLInicio += " 			 						     ELSE 'VERIFICAR'" + CRLF
	cSQLInicio += " 			 							 END AS SEXO," + CRLF	
	cSQLInicio += "			     CASE WHEN ZCC_PAGFUT = 'S'   THEN 'SIM' " + CRLF
	cSQLInicio += "			     							  ELSE 'NÃO' " + CRLF
	cSQLInicio += "			     							  END AS PGTO_FUTURO, " + CRLF
	cSQLInicio += " 			 CASE WHEN BC.ZBC_TPNEG	= 'P' THEN 'PESO'" + CRLF
	cSQLInicio += " 			 	  WHEN BC.ZBC_TPNEG	= 'K' THEN 'KG'" + CRLF
	cSQLInicio += " 			 	  WHEN BC.ZBC_TPNEG	= 'Q' THEN 'CABECA'" + CRLF
	cSQLInicio += " 			 							  ELSE 'VERIFICAR'" + CRLF
	cSQLInicio += " 			 						      END AS TIPO_NEGOCIA," + CRLF
	cSQLInicio += " 			 CASE WHEN ZBC_PEDPOR = 'P'   THEN 'PAUTA' " + CRLF
	cSQLInicio += " 			 							  ELSE 'NEGOCIACAO' " + CRLF
	cSQLInicio += " 			 							  END AS PEDIDO_POR, " + CRLF
	cSQLInicio += " 			 CASE WHEN ZBC_TEMFXA = 'S'   THEN 'SIM' " + CRLF
	cSQLInicio += " 			  						      ELSE 'NÁO' " + CRLF
	cSQLInicio += " 			  						      END AS TEM_FAIXA, ZBC_FAIXA, " + CRLF
	cSQLInicio += " 			 ZBC_PESO			                PESO_COMPRA, " + CRLF
	cSQLInicio += " 			 SUM(D1.D1_X_PESCH)	                PESO_CHEGADA, " + CRLF
	cSQLInicio += " 			 ZBC_PESO-SUM(D1.D1_X_PESCH)        QUEBRA, " + CRLF
	cSQLInicio += " 			 D1.D1_X_EMBDT		                DATA_EMBARQUE, " + CRLF
	cSQLInicio += " 			 D1.D1_X_EMBHR		                HORA_EMBARQUE, " + CRLF
	cSQLInicio += " 			 CASE D1.D1_X_CHEDT " + CRLF
	cSQLInicio += " 			 	WHEN ' ' " + CRLF
	cSQLInicio += " 			 		THEN D1.D1_EMISSAO " + CRLF
	cSQLInicio += " 			 		ELSE D1.D1_X_CHEDT " + CRLF
	cSQLInicio += " 			 END DATA_CHEGADA, " + CRLF
	cSQLInicio += " 			 D1.D1_X_CHEHR		                HORA_CHEGADA, " + CRLF
	cSQLInicio += " 			 D1.D1_X_KM			                KM_NF_ENTRADA, " + CRLF
	cSQLInicio += " 			 D1.D1_QUANT		                QTD_NF, " + CRLF
	cSQLInicio += " 			 ZBC_ARROV			                VALOR_ARROB, " + CRLF
	cSQLInicio += " 			 ZBC_REND			                RENDIMENTO, " + CRLF
	cSQLInicio += " 			 ZBC_TTSICM			                TOTAL_SEM_ICMS, " + CRLF
	cSQLInicio += " 			 ZBC_TOTICM			                TOTAL_ICMS, " + CRLF
	cSQLInicio += " 			 ZBC_TTSICM+ZBC_TOTICM				GADO_ICMS_TOTAL_CONTRATO, " + CRLF
	cSQLInicio += " 			 ZBC_VLFRPG, ZBC_ICFRVL, " + CRLF
	cSQLInicio += " 			 ZBC_VLRCOM							VLR_COM " + CRLF
	cSQLInicio += " 		--   SUM(D1.D1_TOTAL)-SUM(D1.D1_VALICM)	VALOR_TOTAL_NF_ENTRADA, " + CRLF
	cSQLInicio += " 		--	 SUM(D1.D1_VALICM)					ICMS_NF_ENTRADA " + CRLF
	cSQLInicio += " 		--	 SUM(D1C.D1_TOTAL)-SUM(D1.D1_VALICM)VALOR_NF_COMPLEM, " + CRLF
	cSQLInicio += " 		--	 SUM(D1C.D1_VALICM)					ICMS_NF_COMPLEMENTO " + CRLF
	cSQLInicio += " 			-- NOTAS " + CRLF
	cSQLInicio += " 			, D1.D1_FILIAL, D1.D1_DOC, D1.D1_SERIE, D1.D1_EMISSAO, D1.D1_FORNECE, D1.D1_LOJA, A2.A2_NOME, " + CRLF
	cSQLInicio += "  			D1.D1_COD, B1_DESC, D1.D1_QUANT, " + CRLF
	cSQLInicio += "  			SUM( D1.D1_TOTAL ) D1_TOTAL, " + CRLF
	cSQLInicio += "				SUM( D1.D1_VALICM) D1_VALICM, " + CRLF
	cSQLInicio += " 			D1.D1_PEDIDO PEDORIG, D1.D1_ITEMPC ITEMPCORIG " + CRLF
	cSQLInicio += " 			, ZBC_STATUS " + CRLF
	cSQLInicio += " 			, CASE WHEN ZCC_NEGENC='S' THEN 'SIM' ELSE 'NÃO' END ZCC_NEGENC" + CRLF
	cSQLInicio += "         FROM " + RetSQLName('ZBC') + " BC " + CRLF
	cSQLInicio += "         JOIN ZCC010 CC ON ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO " + CRLF
	cSQLInicio += "         			  AND ZCC_DTCONT BETWEEN '"+ DtoS(MV_PAR01) +"' AND '"+ DtoS(MV_PAR02) + "'" + CRLF 
	cSQLInicio += " " + CRLF
	cSQLInicio += "AND ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO AND ZCC_VERSAO=ZBC_VERSAO " + CRLF
 	cSQLInicio += "			AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
 	cSQLInicio += "				( " + CRLF
 	cSQLInicio += "					SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
 	cSQLInicio += "					FROM ZBC010 " + CRLF
 	cSQLInicio += "					WHERE D_E_L_E_T_=' ' " + CRLF
 	cSQLInicio += "					GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
 	cSQLInicio += "				) " + CRLF
	cSQLInicio += "		AND CC.D_E_L_E_T_=' ' " + CRLF
	cSQLInicio += "		AND BC.D_E_L_E_T_=' ' " + CRLF
	cSQLInicio += CRLF
	cSQLInicio += "   INNER JOIN " + RetSQLName('SA2') + " A2 ON " + CRLF
	cSQLInicio += " 			 A2.A2_FILIAL =	' ' " + CRLF
	cSQLInicio += " 		 AND A2.A2_COD					=		ZBC_CODFOR " + CRLF
	cSQLInicio += " 		 AND A2.A2_LOJA					=		ZBC_LOJFOR " + CRLF
	cSQLInicio += " 		 AND A2.D_E_L_E_T_ = ' ' " + CRLF
	cSQLInicio += "--    INNER JOIN ZIC010	IC ON " + CRLF
	cSQLInicio += "--  			 IC.ZIC_FILIAL				=		ZBC_FILIAL " + CRLF
	cSQLInicio += "--  		 AND IC.ZIC_CODIGO				=		BC.ZBC_CODIGO " + CRLF
	cSQLInicio += "--  		 AND IC.ZIC_ITEM				=		BC.ZBC_ITEZIC " + CRLF
	cSQLInicio += CRLF
	cSQLInicio += "--        AND ZIC_FILIAL=ZBC_FILIAL AND ZIC_CODIGO=ZBC_CODIGO AND ZIC_VERSAO=ZBC_VERSAO " + CRLF
 	cSQLInicio += "       	 AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
 	cSQLInicio += "       		( " + CRLF
 	cSQLInicio += "       			SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
 	cSQLInicio += "       			FROM ZBC010 " + CRLF
 	cSQLInicio += "       			WHERE D_E_L_E_T_=' ' " + CRLF
 	cSQLInicio += "       			GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
 	cSQLInicio += "       		) " + CRLF
	cSQLInicio += CRLF
	cSQLInicio += "--  		 AND IC.D_E_L_E_T_=' ' " + CRLF
	cSQLInicio += "    LEFT JOIN SD1010 D1 ON " + CRLF
	cSQLInicio += " 			 D1.D1_FILIAL				=		BC.ZBC_FILIAL " + CRLF
	cSQLInicio += " 		 AND D1.D1_COD					=		BC.ZBC_PRODUT " + CRLF
	cSQLInicio += " 		 AND D1.D1_FORNECE				=		BC.ZBC_CODFOR " + CRLF
	cSQLInicio += " 		 AND D1.D1_LOJA					=		BC.ZBC_LOJFOR " + CRLF
	cSQLInicio += " 		 AND D1.D1_EMISSAO BETWEEN '"+ DtoS(MV_PAR01) +"' AND '"+ DtoS(MV_PAR02) + "'" + CRLF
	cSQLInicio += " 		 AND D1.D1_TIPO					=		'N' " + CRLF
	cSQLInicio += " 		 AND D1.D_E_L_E_T_= ' ' " + CRLF
	cSQLInicio += "    INNER JOIN SA3010 A3 ON " + CRLF
	cSQLInicio += "				 A3_FILIAL=' ' " + CRLF
	cSQLInicio += " 		 AND A3.A3_COD					=		ZCC_CODCOR " + CRLF
	cSQLInicio += " 		 AND A3.D_E_L_E_T_=' ' " + CRLF
	cSQLInicio += "	-- ALTERADO " + CRLF
	cSQLInicio += "	INNER JOIN " + RetSQLName('SB1') + " B1 ON " + CRLF
	cSQLInicio += "         			B1_FILIAL	= ' ' " + CRLF
	cSQLInicio += "         		AND B1_COD = " + CRLF
	cSQLInicio += "          				   BC.ZBC_PRODUT " + CRLF
	cSQLInicio += "          				-- D1.D1_COD " + CRLF
	cSQLInicio += "				    AND B1_RASTRO = 'L' " + CRLF
	cSQLInicio += "					AND B1.D_E_L_E_T_ = ' ' " + CRLF
	cSQLInicio += "        WHERE " + CRLF
	cSQLInicio += " 			 ZBC_FILIAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'" + CRLF
	cSQLInicio += " 		 AND ZBC_CODIGO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'" + CRLF
	cSQLInicio += " 		 AND ZBC_PEDIDO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'" + CRLF
	
	If MV_PAR22 == 2 // SIM
		If !Empty(MV_PAR11) .or. ( !Empty(MV_PAR12) .and. !Empty(MV_PAR13))

			cSQLInicio += " AND ZBC_PEDIDO IN ( " + CRLF
			cSQLInicio += "		SELECT DISTINCT ZBC_PEDIDO FROM ZBC010 " + CRLF
			cSQLInicio += "      WHERE ZBC_PRODUT IN ( " + CRLF
			cSQLInicio += " 		       SELECT DISTINCT D2_COD FROM SD2010 D2 " + CRLF
			cSQLInicio += "					JOIN SF4010 F4 ON D2_TES = F4.F4_CODIGO AND F4.D_E_L_E_T_ = ' ' AND D2.D_E_L_E_T_=' ' " + CRLF
			cSQLInicio += "		   								AND F4_TRANFIL <> '1' " + CRLF
			cSQLInicio += " 		       WHERE 	D2_TIPO='N' " + CRLF
		
			If !Empty(MV_PAR11)
				cSQLInicio += " 	 		AND D2_LOTECTL IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
			EndIf
			
			If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
				cSQLInicio += " 	 		AND D2_EMISSAO BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
			EndIf
			
			cSQLInicio += "				AND D2_LOTECTL <> ' ' " + CRLF
			
			cSQLInicio += " 	 ) ) " + CRLF
		
		EndIf
	EndIf
	
	cSQLInicio += " 		 AND ZBC_CODFOR BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "'" + CRLF
	cSQLInicio += "           AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
	cSQLInicio += "                  ( " + CRLF
	cSQLInicio += "          	    	SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
	cSQLInicio += "          	    	FROM ZBC010 " + CRLF
	cSQLInicio += "          	    	WHERE D_E_L_E_T_=' ' " + CRLF
	cSQLInicio += "          	    	GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
	cSQLInicio += "          	    ) " + CRLF
	cSQLInicio += "  GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_PEDIDO, ZBC_ITEMPC, ZBC_CODFOR, ZBC_LOJFOR, A2.A2_NOME, A2_MUN, A2_EST, ZBC_X_CORR, A3_NOME, ZBC_PRODUT, " + CRLF
	cSQLInicio += "   			 ZBC_PRDDES, ZBC_QUANT, BC.ZBC_RACA, BC.ZBC_SEXO, ZCC_PAGFUT, BC.ZBC_TPNEG, ZBC_PEDPOR, ZBC_TEMFXA, ZBC_FAIXA, ZBC_PESO,D1.D1_X_EMBDT, D1.D1_X_EMBHR, D1.D1_X_CHEDT, " + CRLF
	cSQLInicio += "   			 D1.D1_X_CHEHR, D1.D1_X_KM, D1.D1_QUANT, ZBC_ARROV, ZBC_PESO, ZBC_REND, ZBC_TTSICM, ZBC_TOTICM, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM " + CRLF
	cSQLInicio += "  			 , D1.D1_FILIAL, D1.D1_DOC, D1.D1_SERIE, D1.D1_EMISSAO, D1.D1_FORNECE, D1.D1_LOJA, A2.A2_NOME, " + CRLF
	cSQLInicio += "   				D1.D1_COD, B1_DESC, D1.D1_QUANT, " + CRLF
	cSQLInicio += "   				D1.D1_VALICM, -- D1.D1_TOTAL, D1.D1_VALICM, " + CRLF
	cSQLInicio += "   				D1.D1_X_PESCH, " + CRLF
	cSQLInicio += "  				D1.D1_PEDIDO, D1.D1_ITEMPC " + CRLF
	cSQLInicio += " 			    , ZBC_STATUS, ZCC_NEGENC " + CRLF
	cSQLInicio += " 		) " + CRLF

	_cQry := " WITH " + CRLF
	_cQry += cSQLInicio
	_cQry += ", " + CRLF // esse kra nao pode sair daqui, por conta da variavel acima (sqlInicio) que foi adicionada agora
	
	If cTipo == "CustoQuant"

		_cQry := "  WITH " + CRLF
		_cQry += " CONTRATO AS " + CRLF
		_cQry += " 		( " + CRLF
		_cQry += "       SELECT ZBC_FILIAL					   FILIAL, " + CRLF
		_cQry += " 			 ZBC_CODIGO						   COD_CONTRATO, " + CRLF
		_cQry += " 			 ZBC_PEDIDO					       NUMERO_LOTE, " + CRLF
		_cQry += "			 ZBC_ITEMPC, " + CRLF
		_cQry += " 			 ZBC_CODFOR					       CODIGO_FORNEC, " + CRLF
		_cQry += " 			 ZBC_LOJFOR						   LOJA_FORNEC, " + CRLF
		_cQry += " 			 A2.A2_NOME					       VENDEDOR, " + CRLF
		_cQry += " 			 A2_MUN						       ORIGEM, " + CRLF
		_cQry += " 			 A2_EST						       ESTADO, " + CRLF
		_cQry += " 			 ZBC_X_CORR					       COD_CORRETOR, " + CRLF
		_cQry += " 			 A3_NOME					       CORRETOR, " + CRLF
		_cQry += " 			 ZBC_PRODUT					       CODIGO_BOV, " + CRLF
		_cQry += " 			 ZBC_PRDDES					       DESCRICAO, " + CRLF
		_cQry += " 			 BC.ZBC_QUANT				       QTD_COMPRA, " + CRLF
		_cQry += " 			 CASE WHEN BC.ZBC_RACA = 'N' THEN 'NELORE' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_RACA = 'A' THEN 'ANGUS' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_RACA = 'M' THEN 'MESTICO' " + CRLF
		_cQry += " 										 ELSE 'VERIFICAR' " + CRLF
		_cQry += " 									     END AS RACA, " + CRLF
		_cQry += " 			 CASE WHEN BC.ZBC_SEXO = 'M' THEN 'MACHO' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_SEXO = 'F' THEN 'FEMEA' " + CRLF
		_cQry += " 									     ELSE 'VERIFICAR' " + CRLF
		_cQry += " 										 END AS SEXO, " + CRLF
		_cQry += "			CASE WHEN ZCC_PAGFUT = 'S'   THEN 'SIM' " + CRLF
		_cQry += "										 ELSE 'NÃO' " + CRLF
		_cQry += "										 END AS PGTO_FUTURO, " + CRLF
		_cQry += " 			 CASE WHEN BC.ZBC_TPNEG	= 'P' THEN 'PESO' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_TPNEG	= 'K' THEN 'KG' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_TPNEG	= 'Q' THEN 'CABECA' " + CRLF
		_cQry += " 										  ELSE 'VERIFICAR' " + CRLF
		_cQry += " 									      END AS TIPO_NEGOCIA, " + CRLF
		_cQry += " 			 CASE WHEN ZBC_PEDPOR = 'P'   THEN 'PAUTA' " + CRLF
		_cQry += " 			 							  ELSE 'NEGOCIACAO' " + CRLF
		_cQry += " 			 							  END AS PEDIDO_POR, " + CRLF
		_cQry += " 			 CASE WHEN ZBC_TEMFXA = 'S'   THEN 'SIM' " + CRLF
		_cQry += " 			  						      ELSE 'NÁO' " + CRLF
		_cQry += " 			  						      END AS TEM_FAIXA, ZBC_FAIXA, " + CRLF
		_cQry += " 			 ZBC_PESO			                PESO_COMPRA, " + CRLF
		_cQry += " 			 ZBC_ARROV			                VALOR_ARROB, " + CRLF
		_cQry += " 			 ZBC_REND			                RENDIMENTO, " + CRLF
		_cQry += " 			 ZBC_TTSICM			                TOTAL_SEM_ICMS, " + CRLF
		_cQry += " 			 ZBC_TOTICM			                TOTAL_ICMS, " + CRLF
		_cQry += " 			 ZBC_TTSICM+ZBC_TOTICM				GADO_ICMS_TOTAL_CONTRATO, " + CRLF
		_cQry += " 			 ZBC_VLFRPG, ZBC_ICFRVL, " + CRLF
		_cQry += " 			 ZBC_VLRCOM							VLR_COM " + CRLF
		_cQry += "         FROM ZBC010 BC " + CRLF
		_cQry += "         JOIN ZCC010 CC ON ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO " + CRLF
		_cQry += CRLF
		_cQry += "AND ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO AND ZCC_VERSAO=ZBC_VERSAO " + CRLF
 		_cQry += "			AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
 		_cQry += "				( " + CRLF
 		_cQry += "					SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
 		_cQry += "					FROM ZBC010 " + CRLF
 		_cQry += "					WHERE D_E_L_E_T_=' ' " + CRLF
 		_cQry += "					GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
 		_cQry += "				) " + CRLF
		_cQry += "		AND CC.D_E_L_E_T_=' ' " + CRLF
		_cQry += "		AND BC.D_E_L_E_T_=' ' " + CRLF
		_cQry += "	 " + CRLF
		_cQry += "   INNER JOIN SA2010 A2 ON " + CRLF
		_cQry += "   		 A2.A2_FILIAL =	' ' " + CRLF
		_cQry += " 		 AND A2.A2_COD					=		ZBC_CODFOR " + CRLF
		_cQry += " 		 AND A2.A2_LOJA					=		ZBC_LOJFOR " + CRLF
		_cQry += " 		 AND A2.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += "--    INNER JOIN ZIC010	IC ON " + CRLF
		_cQry += "--  			 IC.ZIC_FILIAL				=		ZBC_FILIAL " + CRLF
		_cQry += "--  		 AND IC.ZIC_CODIGO				=		BC.ZBC_CODIGO " + CRLF
		_cQry += "--  		 AND IC.ZIC_ITEM				=		BC.ZBC_ITEZIC " + CRLF
		_cQry += CRLF
		_cQry += "--       AND ZIC_FILIAL=ZBC_FILIAL AND ZIC_CODIGO=ZBC_CODIGO AND ZIC_VERSAO=ZBC_VERSAO " + CRLF
 		_cQry += "       			AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
 		_cQry += "       				( " + CRLF
 		_cQry += "       					SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
 		_cQry += "       					FROM ZBC010 " + CRLF
 		_cQry += "       					WHERE D_E_L_E_T_=' ' " + CRLF
 		_cQry += "       					GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
 		_cQry += "       				) " + CRLF
		_cQry += "       			 " + CRLF
		_cQry += "--  	     AND IC.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += CRLF
		_cQry += "    INNER JOIN SA3010 A3 ON " + CRLF
		_cQry += "			 A3_FILIAL=' ' " + CRLF
		_cQry += " 		 AND A3.A3_COD					=		ZBC_X_CORR " + CRLF
		_cQry += " 		 AND A3.D_E_L_E_T_=' ' " + CRLF
		_cQry += "	-- ALTERADO " + CRLF
		_cQry += "	INNER JOIN " + RetSQLName('SB1') + " B1 ON " + CRLF
		_cQry += "					B1_FILIAL					= ' ' " + CRLF
		_cQry += "				AND B1_COD 						= ZBC_PRODUT " + CRLF
		_cQry += "				AND B1_RASTRO = 'L' " + CRLF
		_cQry += "				AND B1.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += "        WHERE " + CRLF
		_cQry += " 			 ZBC_FILIAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'" + CRLF
		_cQry += " 		 AND ZBC_CODIGO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'" + CRLF
		_cQry += " 		 AND ZBC_PEDIDO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'" + CRLF
		
		If MV_PAR22 == 2 // SIM
			If !Empty(MV_PAR11) .or. ( !Empty(MV_PAR12) .and. !Empty(MV_PAR13))
		
				_cQry += " AND ZBC_PEDIDO IN ( " + CRLF
				_cQry += "		SELECT DISTINCT ZBC_PEDIDO FROM ZBC010 " + CRLF
				_cQry += "      WHERE ZBC_PRODUT IN ( " + CRLF
				_cQry += " 		       SELECT DISTINCT D2_COD FROM SD2010 D2" + CRLF
				_cQry += "				JOIN SF4010 F4 ON D2_TES = F4.F4_CODIGO AND F4.D_E_L_E_T_ = ' ' AND D2.D_E_L_E_T_=' ' " + CRLF
				_cQry += "		   								AND F4_TRANFIL <> '1' " + CRLF
				_cQry += " 		       WHERE 	D2_TIPO='N' " + CRLF
			
				If !Empty(MV_PAR11)	
					_cQry += " 	 		AND D2_LOTECTL  IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
				EndIf
				
				If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
					_cQry += " 	 		AND D2_EMISSAO BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
				EndIf
				
				_cQry += "				AND D2_LOTECTL <> ' ' " + CRLF
				
				_cQry += " 	 ) ) " + CRLF
			
			EndIf
		EndIf
		
		_cQry += " 		 AND ZBC_CODFOR BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "'" + CRLF
		_cQry += "       AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
		_cQry += "              ( " + CRLF
		_cQry += "           		SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
		_cQry += "           		FROM ZBC010 " + CRLF
		_cQry += "           		WHERE D_E_L_E_T_=' ' " + CRLF
		_cQry += "           		GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
		_cQry += "              ) " + CRLF
		_cQry += " 		 AND A2.D_E_L_E_T_				=		' ' " + CRLF
		_cQry += "" + CRLF
		_cQry += " 		 AND A3.D_E_L_E_T_				=		' ' " + CRLF
		_cQry += "  GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_PEDIDO, ZBC_ITEMPC, ZBC_CODFOR, ZBC_LOJFOR, A2.A2_NOME, A2_MUN, A2_EST, ZBC_X_CORR, A3_NOME, ZBC_PRODUT, " + CRLF
		_cQry += "   			 ZBC_PRDDES, ZBC_QUANT, BC.ZBC_RACA, BC.ZBC_SEXO, ZCC_PAGFUT, BC.ZBC_TPNEG, ZBC_PEDPOR, ZBC_TEMFXA, ZBC_FAIXA, ZBC_PESO, " + CRLF
		_cQry += "   			 ZBC_ARROV, ZBC_PESO, ZBC_REND, ZBC_TTSICM, ZBC_TOTICM, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM, " + CRLF
		_cQry += "  			 A2.A2_NOME " + CRLF
		_cQry += " 		) " + CRLF
		_cQry += CRLF
		_cQry += " , CONTRATO_DISTINCT AS ( " + CRLF
		_cQry += " 		SELECT FILIAL, CODIGO_BOV, NUMERO_LOTE, SUM(QTD_COMPRA) QTD_COMPRA " + CRLF
		_cQry += " 		FROM CONTRATO " + CRLF
		_cQry += " 		GROUP BY FILIAL, CODIGO_BOV, NUMERO_LOTE " + CRLF
		_cQry += " ) " + CRLF
		_cQry += CRLF
		_cQry += ", ESTOQUE AS ( " + CRLF
		_cQry += " 	SELECT DISTINCT B8_FILIAL, B8.B8_PRODUTO, SUM(B8.B8_SALDO) SALDO " + CRLF
		_cQry += " 	FROM SB8010 B8 " + CRLF
		_cQry += " 	JOIN CONTRATO_DISTINCT C ON C.CODIGO_BOV = B8_PRODUTO AND B8.D_E_L_E_T_ = ' ' " + CRLF
		// _cQry += "	WHERE 
		// 
		// If !Empty(MV_PAR11)	
		// 	_cQry += " 	 		B8_LOTECTL  IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
		// EndIf
		
		_cQry += " 	GROUP BY B8_FILIAL, B8.B8_PRODUTO " + CRLF
		_cQry += "	HAVING SUM(B8.B8_SALDO) > 0 " + CRLF
		_cQry += " ), " + CRLF
		_cQry += "" + CRLF
		
		_cQry += "" + CRLF
		_cQry += " FATURAMENTO AS ( " + CRLF // CustoQuant
		_cQry += " 	SELECT D2_FILIAL, D2_COD, SUM(D2_QUANT) SALDO " + CRLF
		_cQry += " 	  FROM SD2010 D2 " + CRLF
		_cQry += " 	  JOIN CONTRATO_DISTINCT C ON D2_FILIAL=C.FILIAL AND D2_COD = C.CODIGO_BOV AND  D2.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += " 	  WHERE  D2_QUANT > 0 " + CRLF
		_cQry += "		 AND D2_TIPO='N' " + CRLF
		_cQry += "		 AND SUBSTRING(D2_LOTECTL,1,4) <> 'AUTO' " + CRLF
		//If !Empty(MV_PAR11)	
		//	_cQry += " 	 		AND D2_LOTECTL  IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
		//EndIf
		// If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
		// 	_cQry += " 	 		AND D2_EMISSAO BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
		// EndIf
		_cQry += " 	  GROUP BY D2_FILIAL, D2_COD " + CRLF
		_cQry += " ), " + CRLF
		_cQry += CRLF
		_cQry += " MORTE AS ( " + CRLF
		_cQry += " 	SELECT D3M.D3_FILIAL, D3M.D3_COD, SUM(D3M.D3_QUANT) MORTE " + CRLF
		_cQry += " 	FROM SD3010 D3M " + CRLF
		_cQry += " 	JOIN CONTRATO_DISTINCT C ON	C.CODIGO_BOV = D3_COD AND D3M.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += " 	WHERE D3M.D3_ESTORNO <> 'S' " + CRLF
		_cQry += " 	  AND D3M.D3_TM IN ("+GetMV("VA_COMR07A",,"'511'")+") " + CRLF
		//If !Empty(MV_PAR11)	
		//	_cQry += " 	 		AND D3_LOTECTL  IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
		//EndIf
		_cQry += " 	GROUP BY D3M.D3_FILIAL, D3M.D3_COD " + CRLF
		_cQry += " ), " + CRLF
		_cQry += CRLF
		_cQry += " NASCIMENTO AS ( " + CRLF
		_cQry += " 	SELECT D3M.D3_FILIAL, D3M.D3_COD, SUM(D3M.D3_QUANT) NASCIMENTO " + CRLF
		_cQry += " 	FROM SD3010 D3M " + CRLF
		_cQry += " 	JOIN CONTRATO_DISTINCT C ON C.CODIGO_BOV = D3_COD AND D3M.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += " 	WHERE D3M.D3_ESTORNO <> 'S' " + CRLF
		_cQry += " 	  AND D3M.D3_TM IN ("+GetMV("VA_COMR07B",,"'011'")+") " + CRLF
		//If !Empty(MV_PAR11)	
		//	_cQry += " 	 		AND D3_LOTECTL  IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
		//EndIf
		_cQry += " 	GROUP BY D3M.D3_FILIAL, D3M.D3_COD " + CRLF
		_cQry += " ), " + CRLF
		_cQry += CRLF
		
		// _cQry += " MOVBOI AS ( " + CRLF
		// _cQry += " 	SELECT D3_FILIAL, D3_COD, SUM(D3.D3_QUANT) QTD_TRANSF " + CRLF
		// _cQry += " 	FROM SD3010 D3 " + CRLF
		// _cQry += " 	JOIN CONTRATO_DISTINCT C ON FILIAL = D3.D3_FILIAL AND CODIGO_BOV = D3.D3_COD " + CRLF
		// _cQry += " 	WHERE  D3_TM IN ('499') -- D3_FILIAL = '"+xFilial("SD3")+ "'" + CRLF
		// // If !Empty(MV_PAR11)
		// // 	_cQry += " 		AND D3_LOTECTL IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
		// // EndIf
		// // If !Empty(MV_PAR01) .and. !Empty(MV_PAR13)
		// // 	_cQry += " 		AND D3_EMISSAO BETWEEN '" + dToS(MV_PAR01) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
		// // EndIf
		// _cQry += " 		AND D3_CF = 'DE4' " + CRLF
		// _cQry += " 		AND D3_GRUPO = 'BOV' " + CRLF
		// _cQry += " 		AND D3_NUMSEQ IN (SELECT D3_NUMSEQ FROM SD3010 X WHERE D3_CF = 'RE4' AND D3_COD <> D3.D3_COD AND X.D_E_L_E_T_= ' ') " + CRLF
		// _cQry += " 		AND D_E_L_E_T_ = ' ' " + CRLF
		// _cQry += " 	 GROUP BY D3_FILIAL, D3_COD " + CRLF
		// _cQry += "  ), " + CRLF
		
		_cQry += " MOVBOIA AS (" + CRLF
		_cQry += " 	SELECT D3_FILIAL, D3_COD, SUM(D3.D3_QUANT) QTD_TRANSF" + CRLF
		_cQry += " 	FROM SD3010 D3" + CRLF
		_cQry += " 	JOIN CONTRATO C ON FILIAL = D3.D3_FILIAL AND CODIGO_BOV = D3.D3_COD" + CRLF
		_cQry += " 	WHERE  D3_TM IN ('499') -- D3_FILIAL = '01'" + CRLF
		_cQry += " 		AND D3_CF = 'DE4'" + CRLF
		_cQry += " 		AND D3_GRUPO = 'BOV'" + CRLF
		_cQry += " 		AND D3_NUMSEQ IN (SELECT D3_NUMSEQ FROM SD3010 X WHERE D3_CF = 'RE4' AND D3_COD <> D3.D3_COD AND X.D_E_L_E_T_= ' ')" + CRLF
		_cQry += " 		AND D_E_L_E_T_ = ' '" + CRLF
		_cQry += " 	 GROUP BY D3_FILIAL, D3_COD" + CRLF
		_cQry += "  )," + CRLF
		_cQry += " " + CRLF
		_cQry += " MOVBOIB AS (" + CRLF
		_cQry += " 	SELECT D3_FILIAL, D3_COD, SUM(D3.D3_QUANT) QTD_TRANSF" + CRLF
		_cQry += " 	FROM SD3010 D3" + CRLF
		_cQry += " 	JOIN CONTRATO C ON FILIAL = D3.D3_FILIAL AND CODIGO_BOV = D3.D3_COD" + CRLF
		_cQry += " 	WHERE  D3_TM IN ('999') -- D3_FILIAL = '01'" + CRLF
		_cQry += " 		AND D3_CF = 'RE4'" + CRLF
		_cQry += " 		AND D3_GRUPO = 'BOV'" + CRLF
		_cQry += " 		AND D3_NUMSEQ IN (SELECT D3_NUMSEQ FROM SD3010 X WHERE D3_CF = 'DE4' AND D3_COD <> D3.D3_COD AND X.D_E_L_E_T_= ' ')" + CRLF
		_cQry += " 		AND D_E_L_E_T_ = ' '" + CRLF
		_cQry += " 	 GROUP BY D3_FILIAL, D3_COD" + CRLF
		_cQry += "  ), " + CRLF
		_cQry += " " + CRLF
		_cQry += " MOVBOI AS (" + CRLF
		_cQry += "  SELECT A.D3_FILIAL, A.D3_COD, ISNULL(A.QTD_TRANSF,0)-ISNULL(B.QTD_TRANSF,0) QTD_TRANSF " + CRLF
		_cQry += " 	FROM MOVBOIA A " + CRLF
		_cQry += "	LEFT JOIN MOVBOIB B ON" + CRLF
		_cQry += "	A.D3_FILIAL = B.D3_FILIAL AND" + CRLF
		_cQry += "	A.D3_COD = B.D3_COD" + CRLF
		_cQry += "	WHERE (ISNULL(A.QTD_TRANSF,0)-ISNULL(B.QTD_TRANSF,0)) <> 0 " + CRLF
		_cQry += " " + CRLF
		_cQry += ")," + CRLF
		
		_cQry += " DADOS AS ( " + CRLF
		_cQry += "	 	SELECT  C.NUMERO_LOTE, ISNULL(QTD_COMPRA,0) ZBC_COMPRA, ISNULL(E.SALDO,0) SALDO_B8, " + CRLF
		_cQry += "				CASE WHEN ISNULL(SUM(MOV.QTD_TRANSF),0)> 0 " + CRLF
		_cQry += "					THEN ISNULL(F.SALDO,0)-ISNULL(SUM(MOV.QTD_TRANSF),0) " + CRLF
		_cQry += "					ELSE ISNULL(F.SALDO,0) " + CRLF
		_cQry += "				END AS FATURADO, " + CRLF
		_cQry += "				ISNULL(M.MORTE,0) MORTE, ISNULL(N.NASCIMENTO,0) NASCIMENTO, " + CRLF
		_cQry += "				ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0) TOTAL, " + CRLF
		_cQry += "				CASE WHEN SUM(MOV.QTD_TRANSF) > 0 AND ISNULL(QTD_COMPRA,0)-(ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0)) < 0 " + CRLF
		_cQry += "					THEN ISNULL(QTD_COMPRA,0)-(ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0))+ISNULL(SUM(MOV.QTD_TRANSF),0) " + CRLF
		_cQry += "							ELSE ISNULL(QTD_COMPRA,0)-(ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0)) " + CRLF
		_cQry += "				END AS DIFERE " + CRLF
		_cQry += "		FROM CONTRATO_DISTINCT C " + CRLF
		_cQry += "		LEFT JOIN ESTOQUE 	  E	  ON C.FILIAL=E.B8_FILIAL AND C.CODIGO_BOV = E.B8_PRODUTO " + CRLF
		_cQry += "		LEFT JOIN FATURAMENTO F	  ON C.FILIAL=D2_FILIAL   AND C.CODIGO_BOV = D2_COD " + CRLF
		_cQry += "		LEFT JOIN MORTE 	  M	  ON C.FILIAL=M.D3_FILIAL AND C.CODIGO_BOV = M.D3_COD " + CRLF
		_cQry += "		LEFT JOIN NASCIMENTO  N	  ON C.FILIAL=N.D3_FILIAL AND C.CODIGO_BOV = N.D3_COD " + CRLF
		_cQry += "		LEFT JOIN MOVBOI      MOV ON C.FILIAL=MOV.D3_FILIAL AND C.CODIGO_BOV = MOV.D3_COD " + CRLF
		_cQry += "		GROUP BY C.NUMERO_LOTE, QTD_COMPRA, E.SALDO, F.SALDO, M.MORTE, N.NASCIMENTO " + CRLF
		_cQry += "		-- HAVING ISNULL(QTD_COMPRA,0)-(ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0)) <> 0 " + CRLF
		_cQry += " ) " + CRLF
		_cQry += CRLF
		_cQry += " SELECT	CASE WHEN NUMERO_LOTE IS NULL or NUMERO_LOTE='' THEN 'SEM CONTRATO' ELSE NUMERO_LOTE END NUMERO_LOTE, " + CRLF
		_cQry += " 			SUM(ZBC_COMPRA) ZBC_COMPRA, " + CRLF
		_cQry += " 			SUM(SALDO_B8) SALDO_B8, " + CRLF
		_cQry += " 			SUM(FATURADO) FATURADO, " + CRLF
		_cQry += " 			SUM(MORTE) MORTE, " + CRLF
		_cQry += " 			SUM(NASCIMENTO) NASCIMENTO, " + CRLF
		_cQry += " 			SUM(TOTAL) TOTAL, " + CRLF
		_cQry += " 			SUM(DIFERE) DIFERE " + CRLF
		_cQry += " FROM		DADOS " + CRLF
		_cQry += " GROUP BY	NUMERO_LOTE " + CRLF
		_cQry += " ORDER BY	NUMERO_LOTE " + CRLF
	
	ElseIf cTipo $ "Custo"

		_cQry := "  WITH LOTES AS ( " + CRLF
		_cQry += "  	SELECT	B8_FILIAL, B8_PRODUTO, B8_LOTECTL, B8_SALDO, " + CRLF
		
		_cQry += "  			CASE B8_XPESTOT " + CRLF
		_cQry += "  			WHEN 0 THEN B8_XPESOCO " + CRLF
		_cQry += "  				   ELSE B8_XPESTOT END PESO_MEDIO " + CRLF
		
		// _cQry += " B8_XPESOCO PESO_MEDIO " + CRLF
		
		_cQry += CRLF
		_cQry += "  	FROM SB8010 B8 "+CRLF+" WHERE D_E_L_E_T_=' '" + CRLF
		_cQry += "  ) " + CRLF
		_cQry += CRLF
		_cQry += " , FATURAMENTO AS ( " + CRLF
		_cQry += "  	SELECT D2_FILIAL, D2_COD, D2_LOTECTL, D2_EMISSAO, SUM(D2_QUANT) D2_QUANT " + CRLF
		_cQry += "  	FROM	SD2010 D2 " + CRLF
		_cQry += "  	JOIN	LOTES ON B8_FILIAL=D2_FILIAL AND B8_PRODUTO=D2_COD AND B8_LOTECTL=D2_LOTECTL " + CRLF
		_cQry += "  						AND D2.D_E_L_E_T_=' ' " + CRLF
		// _cQry += CRLF
		// _cQry += "  	LEFT JOIN ZAB010 AB ON ZAB_FILIAL=D2_FILIAL AND ZAB_CODIGO=D2_XCODABT " + CRLF
		// _cQry += "  							AND ZAB_OUTMOV <> 1 " + CRLF
		// _cQry += "  							AND AB.D_E_L_E_T_=' ' " + CRLF
		// _cQry += CRLF
		_cQry += "  	WHERE   D2_FILIAL <> ' ' " + CRLF
		_cQry += "  		AND D2_TIPO='N' " + CRLF
		_cQry += "			AND D2_LOTECTL <> ' ' " + CRLF
		_cQry += CRLF
		_cQry += "          AND NOT EXISTS ( " + CRLF
		_cQry += "          	SELECT 1 " + CRLF
		_cQry += "          	FROM ZAB010 AB " + CRLF
		_cQry += "          	WHERE ZAB_FILIAL=D2_FILIAL AND ZAB_CODIGO=D2_XCODABT " + CRLF
		_cQry += "          			AND ZAB_OUTMOV = 1 " + CRLF
		_cQry += "          			AND AB.D_E_L_E_T_=' ' " + CRLF
		_cQry += "          ) " + CRLF
		_cQry += CRLF
		/* 25/09/18
			o custo deve ser analisado na totalidade dos animais formados para a baia*/
		// If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
			// _cQry += " 	 AND D2_EMISSAO BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
		// EndIf
		_cQry += " GROUP BY D2_FILIAL, D2_COD, D2_LOTECTL, D2_EMISSAO " + CRLF
		_cQry += "  ) " + CRLF
		_cQry += CRLF
		_cQry += " , MOVBOI AS ( " + CRLF
		_cQry += " 		SELECT D3_FILIAL, D3_COD, D3_LOTECTL, SUM(D3.D3_QUANT) QTD_TRANSF " + CRLF
		_cQry += " 		FROM SD3010 D3 " + CRLF
		_cQry += " 		JOIN LOTES  ON B8_FILIAL=D3.D3_FILIAL AND B8_PRODUTO=D3.D3_COD AND B8_LOTECTL=D3_LOTECTL " + CRLF
		_cQry += "	 		AND D3.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += " 		WHERE   D3_FILIAL <> ' ' " + CRLF
		_cQry += " 			AND D3_TM IN ('499') " + CRLF
		
		// If !Empty(MV_PAR11)
		// 	_cQry += " 		AND D3_LOTECTL IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
		// EndIf
		// If !Empty(MV_PAR01) .and. !Empty(MV_PAR13)
		// 	_cQry += " 		AND D3_EMISSAO BETWEEN '" + dToS(MV_PAR01) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
		// EndIf
		
		_cQry += "	 		AND D3_CF = 'DE4' " + CRLF
		_cQry += "	 		AND D3_GRUPO = 'BOV' " + CRLF
		_cQry += "	 		AND D3_NUMSEQ IN (SELECT D3_NUMSEQ FROM SD3010 X WHERE X.D3_FILIAL <> ' ' " + CRLF
		_cQry += " 							AND D3_CF = 'RE4' AND D3_COD <> D3.D3_COD AND X.D_E_L_E_T_= ' ') " + CRLF
		_cQry += "	 	 GROUP BY D3_FILIAL, D3_COD, D3_LOTECTL " + CRLF
		_cQry += "  ) " + CRLF
		
		_cQry += CRLF
		_cQry += " , PESO AS ( " + CRLF
        _cQry += " SELECT	B8_FILIAL, B8_PRODUTO, B8_LOTECTL " + CRLF
        _cQry += " 			, B8_SALDO+ISNULL(D2_QUANT,0)-ISNULL(SUM(MOV.QTD_TRANSF),0) QUANT " + CRLF
        _cQry += " 			, PESO_MEDIO " + CRLF
        _cQry += " 			, (B8_SALDO+ISNULL(D2_QUANT,0)-ISNULL(SUM(MOV.QTD_TRANSF),0))*PESO_MEDIO PESO_TOTAL " + CRLF
        _cQry += "  		, D2_EMISSAO " + CRLF
        _cQry += " FROM		 LOTES LT " + CRLF
        _cQry += " LEFT JOIN FATURAMENTO FT ON B8_FILIAL=D2_FILIAL AND B8_PRODUTO=D2_COD AND B8_LOTECTL=D2_LOTECTL " + CRLF
        _cQry += " LEFT JOIN MOVBOI MOV ON B8_FILIAL=MOV.D3_FILIAL AND B8_PRODUTO=MOV.D3_COD AND B8_LOTECTL=D3_LOTECTL " + CRLF
		_cQry += " 								AND D2_QUANT=QTD_TRANSF" + CRLF
        _cQry += " GROUP BY B8_FILIAL, B8_PRODUTO, B8_LOTECTL, B8_SALDO, D2_QUANT, PESO_MEDIO, D2_EMISSAO " + CRLF
		_cQry += "  ), " + CRLF
		_cQry += CRLF
		
		_cQry += cSQLInicio
		_cQry += CRLF
		
		_cQry += ", DADOS1F AS( " + CRLF
		_cQry += "  	SELECT B8_FILIAL, B8_PRODUTO, B8_LOTECTL, " + CRLF
		_cQry += " 					D2_EMISSAO, " + CRLF
		_cQry += " 					SUM(QUANT) QUANT, " + CRLF
		_cQry += "					SUM(PESO_MEDIO) PESO_MEDIO, " + CRLF
		_cQry += "  				SUM(PESO_TOTAL) PESO_TOTAL " + CRLF
		_cQry += "  	FROM PESO P " + CRLF
		_cQry += "  	WHERE QUANT > 0 " + CRLF
		_cQry += "  	-- AND B8_PRODUTO = 'BOV000000001453               ' " + CRLF
		_cQry += "  	GROUP BY B8_FILIAL, B8_PRODUTO, B8_LOTECTL, D2_EMISSAO " + CRLF
		_cQry += "  ), " + CRLF
		_cQry += CRLF
		
		_cQry += " DADOS2F AS ( " + CRLF
		_cQry += " 		 SELECT DISTINCT  CASE WHEN NUMERO_LOTE IS NULL THEN 'SEM CONTRATO' ELSE NUMERO_LOTE END NUMERO_LOTE, " + CRLF
		_cQry += " 		  B8_FILIAL, B8_PRODUTO, B8_LOTECTL, " + CRLF
		_cQry += " 		  QUANT, PESO_MEDIO, PESO_TOTAL, -- QUANT_TOTAL_LOTE, PESO_TT_LOTE, " + CRLF
		_cQry += " 		  ISNULL(COUNT(DISTINCT RACA),0) QT_RACA, " + CRLF 
 		_cQry += " 		  ISNULL(COUNT(DISTINCT SEXO),0) QT_SEXO " + CRLF
		_cQry += " 		  , D2_EMISSAO " + CRLF
		_cQry += " 		  FROM	  DADOS1F D1F " + CRLF
		_cQry += " 		  LEFT JOIN CONTRATO    ON FILIAL=B8_FILIAL AND CODIGO_BOV=B8_PRODUTO " + CRLF
		_cQry += " 		 GROUP BY NUMERO_LOTE, B8_FILIAL, B8_PRODUTO, B8_LOTECTL, " + CRLF
		_cQry += " 		          QUANT, PESO_MEDIO, PESO_TOTAL, -- QUANT_TOTAL_LOTE, PESO_TT_LOTE, " + CRLF
		_cQry += " 		          D2_EMISSAO " + CRLF
		_cQry += " ) " + CRLF
		_cQry += CRLF
		
		_cQry += " SELECT DISTINCT D2F.NUMERO_LOTE, " + CRLF
		_cQry += " 		D2F.B8_FILIAL, D2F.B8_PRODUTO, D2F.B8_LOTECTL, " + CRLF
		_cQry += " 		QUANT, PESO_MEDIO, " + CRLF
		_cQry += " 		PESO_TOTAL, -- QUANT_TOTAL_LOTE, -- PESO_TT_LOTE, " + CRLF
		_cQry += " 		CASE " + CRLF
 		_cQry += "			WHEN QT_RACA = 0 " + CRLF
		_cQry += "				THEN B1.B1_XRACA " + CRLF
		_cQry += "				ELSE CASE WHEN QT_RACA > 1 " + CRLF
 		_cQry += "							THEN 'MISTO' " + CRLF
 		_cQry += "							ELSE RACA END END RACA, " + CRLF
 		_cQry += "	    CASE " + CRLF
 		_cQry += "	    	WHEN QT_SEXO = 0 " + CRLF
		_cQry += "	    		THEN B1.B1_X_SEXO " + CRLF
 		_cQry += "	    		ELSE CASE WHEN QT_SEXO > 1 " + CRLF
 		_cQry += "	    					THEN 'MISTO' " + CRLF
 		_cQry += "	    					ELSE SEXO END END SEXO " + CRLF
		_cQry += " 		, B8.B8_XDATACO " + CRLF
		_cQry += CRLF
		_cQry += " 		, CASE B8_XPESTOT " + CRLF
		_cQry += " 		  WHEN 0 THEN B8_XPESOCO " + CRLF
		_cQry += " 			     ELSE B8_XPESTOT END B8_XPESOCO " + CRLF
		_cQry += CRLF
		_cQry += " 		, ISNULL(D2F.D2_EMISSAO,'') D2_EMISSAO " + CRLF
		_cQry += " 		FROM	   DADOS2F D2F " + CRLF
		_cQry += " 		 LEFT JOIN CONTRATO C ON FILIAL=B8_FILIAL AND CODIGO_BOV=B8_PRODUTO " + CRLF
		_cQry += "            JOIN SB8010  B8 ON   D2F.B8_FILIAL	 = B8.B8_FILIAL " + CRLF
		_cQry += " 		AND D2F.B8_PRODUTO = B8.B8_PRODUTO " + CRLF
		_cQry += " 		AND D2F.B8_LOTECTL = B8.B8_LOTECTL " + CRLF
		_cQry += " 			  JOIN " + RetSQLName('SB1') + " B1 ON B1_FILIAL=' ' AND B1_COD=D2F.B8_PRODUTO AND B1.D_E_L_E_T_=' ' " + CRLF
		_cQry += CRLF
		_cQry += " WHERE	SUBSTRING(D2F.B8_LOTECTL,1,4) <> 'AUTO' " + CRLF
		// _cQry += " WHERE -- B8.B8_LOTECTL IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
		// If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
		// 	// _cQry += " 	 AND D2F.D2_EMISSAO BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
		// 	_cQry += " 	 D2F.D2_EMISSAO BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
		// EndIf
		
		_cQry += CRLF
		_cQry += " ORDER BY B8_FILIAL, B8_LOTECTL " + CRLF
	
	ElseIf cTipo $ "Analise"
	
		_cQry := "  WITH  FATURAMENTO AS ( " + CRLF
		_cQry += "  		SELECT D2_FILIAL, D2_COD, D2_LOTECTL, D2_EMISSAO " + CRLF
		_cQry += "  			, SUM(D2_QUANT) D2_QUANT " + CRLF
		_cQry += "  			, ISNULL(SUM(D1_QUANT),0) QUANT_DEVOL " + CRLF
		_cQry += "  		FROM	SD2010 D2 " + CRLF
		_cQry += "" + CRLF
		_cQry += "		JOIN ZAB010 AB ON ZAB_FILIAL=D2_FILIAL AND ZAB_CODIGO=D2_XCODABT " + CRLF
		
		if MV_PAR14 == 1 // nao
			_cQry += "					AND AB.ZAB_EMERGE <> '1' " + CRLF
		EndIf
		
		if MV_PAR15 == 1 // nao
			_cQry += "					AND AB.ZAB_OUTMOV <> '1' " + CRLF
		EndIf
		
		// _cQry += "						-- AND AB.ZAB_OUTMOV='1' " + CRLF
		_cQry += "						AND D2.D2_LOTECTL <> ' ' " + CRLF
		_cQry += "						AND D2.D_E_L_E_T_=' ' AND AB.D_E_L_E_T_=' ' " + CRLF
		_cQry += CRLF
		_cQry += "    LEFT JOIN SD1010 D1 ON D2_FILIAL		= D1_FILORI  AND D2_DOC			= D1_NFORI " + CRLF
		_cQry += "    				   	 AND D2_SERIE		= D1_SERIORI AND D2_EMISSAO		= D1_DATORI " + CRLF
		_cQry += "    				   	 AND D2_LOTECTL		= D1_LOTECTL " + CRLF
		_cQry += "    				   	 AND D1_TIPO 		= 'D' 	     AND D1.D_E_L_E_T_	= ' ' " + CRLF
		_cQry += CRLF
		_cQry += "  		WHERE   D2_TIPO='N' " + CRLF
		If !Empty(MV_PAR11)	
			_cQry += " 	 		AND D2_LOTECTL  IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
		EndIf
		If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
			_cQry += " 	 		AND D2_EMISSAO BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
		EndIf
		_cQry += " 	GROUP BY D2_FILIAL, D2_COD, D2_LOTECTL, D2_EMISSAO " + CRLF
		_cQry += "  ), " + CRLF
		_cQry += CRLF

		_cQry += " CONTRATO AS " + CRLF
		_cQry += " 		( " + CRLF
		_cQry += "       SELECT ZBC_FILIAL					   FILIAL, " + CRLF
		_cQry += " 			 ZBC_CODIGO						   COD_CONTRATO, " + CRLF
		_cQry += " 			 ZBC_PEDIDO					       NUMERO_LOTE, " + CRLF
		_cQry += "			 ZBC_ITEMPC, " + CRLF
		_cQry += " 			 ZBC_CODFOR					       CODIGO_FORNEC, " + CRLF
		_cQry += " 			 ZBC_LOJFOR						   LOJA_FORNEC, " + CRLF
		_cQry += " 			 A2.A2_NOME					       VENDEDOR, " + CRLF
		_cQry += " 			 A2_MUN						       ORIGEM, " + CRLF
		_cQry += " 			 A2_EST						       ESTADO, " + CRLF
		_cQry += " 			 ZBC_X_CORR					       COD_CORRETOR, " + CRLF
		_cQry += " 			 A3_NOME					       CORRETOR, " + CRLF
		_cQry += " 			 ZBC_PRODUT					       CODIGO_BOV, " + CRLF
		_cQry += " 			 ZBC_PRDDES					       DESCRICAO, " + CRLF
		_cQry += " 			 BC.ZBC_QUANT				       QTD_COMPRA, " + CRLF
		_cQry += " 			 CASE WHEN BC.ZBC_RACA = 'N' THEN 'NELORE' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_RACA = 'A' THEN 'ANGUS' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_RACA = 'M' THEN 'MESTICO' " + CRLF
		_cQry += " 										 ELSE 'VERIFICAR' " + CRLF
		_cQry += " 									     END AS RACA, " + CRLF
		_cQry += " 			 CASE WHEN BC.ZBC_SEXO = 'M' THEN 'MACHO' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_SEXO = 'F' THEN 'FEMEA' " + CRLF
		_cQry += " 									     ELSE 'VERIFICAR' " + CRLF
		_cQry += " 										 END AS SEXO, " + CRLF
		_cQry += "			CASE WHEN ZCC_PAGFUT = 'S'   THEN 'SIM' " + CRLF
		_cQry += "										 ELSE 'NÃO' " + CRLF
		_cQry += "										 END AS PGTO_FUTURO, " + CRLF
		_cQry += " 			 CASE WHEN BC.ZBC_TPNEG	= 'P' THEN 'PESO' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_TPNEG	= 'K' THEN 'KG' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_TPNEG	= 'Q' THEN 'CABECA' " + CRLF
		_cQry += " 										  ELSE 'VERIFICAR' " + CRLF
		_cQry += " 									      END AS TIPO_NEGOCIA, " + CRLF
		_cQry += " 			 CASE WHEN ZBC_PEDPOR = 'P'   THEN 'PAUTA' " + CRLF
		_cQry += " 			 							  ELSE 'NEGOCIACAO' " + CRLF
		_cQry += " 			 							  END AS PEDIDO_POR, " + CRLF
		_cQry += " 			 CASE WHEN ZBC_TEMFXA = 'S'   THEN 'SIM' " + CRLF
		_cQry += " 			  						      ELSE 'NÁO' " + CRLF
		_cQry += " 			  						      END AS TEM_FAIXA, ZBC_FAIXA, " + CRLF
		_cQry += " 			 ZBC_PESO			                PESO_COMPRA, " + CRLF
		_cQry += " 			 ZBC_ARROV			                VALOR_ARROB, " + CRLF
		_cQry += " 			 ZBC_REND			                RENDIMENTO, " + CRLF
		_cQry += " 			 ZBC_TTSICM			                TOTAL_SEM_ICMS, " + CRLF
		_cQry += " 			 ZBC_TOTICM			                TOTAL_ICMS, " + CRLF
		_cQry += " 			 ZBC_TTSICM+ZBC_TOTICM				GADO_ICMS_TOTAL_CONTRATO, " + CRLF
		_cQry += " 			 ZBC_VLFRPG, ZBC_ICFRVL, " + CRLF
		_cQry += " 			 ZBC_VLRCOM							VLR_COM " + CRLF
		_cQry += "         FROM ZBC010 BC " + CRLF
		_cQry += "         JOIN ZCC010 CC ON ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO " + CRLF
		_cQry += CRLF
		_cQry += " AND ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO AND ZCC_VERSAO=ZBC_VERSAO " + CRLF
 		_cQry += "			AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
 		_cQry += "				( " + CRLF
 		_cQry += "					SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
 		_cQry += "					FROM ZBC010 " + CRLF
 		_cQry += "					WHERE D_E_L_E_T_=' ' " + CRLF
 		_cQry += "					GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
 		_cQry += "				) " + CRLF
		_cQry += "		AND CC.D_E_L_E_T_=' ' " + CRLF
		_cQry += "		AND BC.D_E_L_E_T_=' ' " + CRLF
		_cQry += "	 " + CRLF
		_cQry += "   INNER JOIN SA2010 A2 ON " + CRLF
		_cQry += "   		 A2.A2_FILIAL =	' ' " + CRLF
		_cQry += " 		 AND A2.A2_COD						=		ZBC_CODFOR " + CRLF
		_cQry += " 		 AND A2.A2_LOJA						=		ZBC_LOJFOR " + CRLF
		_cQry += " 		 AND A2.D_E_L_E_T_ 					= ' ' " + CRLF
		_cQry += "--   INNER JOIN ZIC010	IC ON " + CRLF
		_cQry += "-- 			 IC.ZIC_FILIAL				=		ZBC_FILIAL " + CRLF
		_cQry += "-- 		 AND IC.ZIC_CODIGO				=		BC.ZBC_CODIGO " + CRLF
		_cQry += "-- 		 AND IC.ZIC_ITEM				=		BC.ZBC_ITEZIC " + CRLF
		_cQry += CRLF
		_cQry += "--       AND ZIC_FILIAL=ZBC_FILIAL AND ZIC_CODIGO=ZBC_CODIGO AND ZIC_VERSAO=ZBC_VERSAO " + CRLF
 		_cQry += "       			AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
 		_cQry += "       				( " + CRLF
 		_cQry += "       					SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
 		_cQry += "       					FROM ZBC010 " + CRLF
 		_cQry += "       					WHERE D_E_L_E_T_=' ' " + CRLF
 		_cQry += "       					GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
 		_cQry += "       				) " + CRLF
		_cQry += "       			 " + CRLF
		_cQry += "-- 	     AND IC.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += CRLF
		_cQry += "    INNER JOIN SA3010 A3 ON " + CRLF
		_cQry += "			 A3_FILIAL=' ' " + CRLF
		_cQry += " 		 AND A3.A3_COD					=		ZBC_X_CORR " + CRLF
		_cQry += " 		 AND A3.D_E_L_E_T_=' ' " + CRLF
		//_cQry += "	-- ALTERADO " + CRLF
		_cQry += "	INNER JOIN " + RetSQLName('SB1') + " B1 ON " + CRLF
		_cQry += "					B1_FILIAL					= ' ' " + CRLF
		_cQry += "				AND B1_COD 						= ZBC_PRODUT " + CRLF
		_cQry += "				AND B1_RASTRO = 'L' " + CRLF
		_cQry += "				AND B1.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += "        WHERE " + CRLF
		_cQry += " 			 ZBC_FILIAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'" + CRLF
		_cQry += " 		 AND ZBC_CODIGO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'" + CRLF
		_cQry += " 		 AND ZBC_PEDIDO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'" + CRLF
		
		If !Empty(MV_PAR11) .or. ( !Empty(MV_PAR12) .and. !Empty(MV_PAR13))
	
			_cQry += " AND ZBC_PEDIDO IN ( " + CRLF
			_cQry += "		SELECT DISTINCT ZBC_PEDIDO FROM ZBC010 " + CRLF
			_cQry += "      WHERE ZBC_PRODUT IN ( " + CRLF
			_cQry += " 		       SELECT DISTINCT D2_COD FROM SD2010 D2 " + CRLF
			_cQry += "				JOIN SF4010 F4 ON D2_TES = F4.F4_CODIGO AND F4.D_E_L_E_T_ = ' ' AND D2.D_E_L_E_T_=' ' " + CRLF
			_cQry += "		   								AND F4_TRANFIL <> '1' " + CRLF
			_cQry += " 		       WHERE 	D2_TIPO='N' " + CRLF
		
			If !Empty(MV_PAR11)	
				_cQry += " 	 		AND D2_LOTECTL  IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
			EndIf
			
			If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
				_cQry += " 	 		AND D2_EMISSAO BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
			EndIf
			
			_cQry += "				AND D2_LOTECTL <> ' ' " + CRLF
			_cQry += " 	 ) )" + CRLF
		
		EndIf
		
		_cQry += " 		 AND ZBC_CODFOR BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "'" + CRLF
		/*
		If !Empty(MV_PAR11) .or. ( !Empty(MV_PAR12) .and. !Empty(MV_PAR13))
	
			_cQry += " AND ZBC_PRODUT IN ( " +
			CRLF
			_cQry += " 		SELECT DISTINCT D2_COD FROM SD2010 " + CRLF
			_cQry += " 		WHERE 	D2_TIPO='N' " + CRLF
		
			If !Empty(MV_PAR11)	
				_cQry += " 	 		AND D2_LOTECTL  IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
			EndIf
			
			If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
				_cQry += " 	 		AND D2_EMISSAO BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
			EndIf
			
			_cQry += " 		AND D_E_L_E_T_ =' ' " + CRLF
			_cQry += " 	 ) " + CRLF
		
		EndIf
		*/
		_cQry += " 		 AND A2.D_E_L_E_T_				=		' ' " + CRLF
		_cQry += "" + CRLF
		_cQry += " 		 AND A3.D_E_L_E_T_				=		' ' " + CRLF
		_cQry += "  GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_PEDIDO, ZBC_ITEMPC, ZBC_CODFOR, ZBC_LOJFOR, A2.A2_NOME, A2_MUN, A2_EST, ZBC_X_CORR, A3_NOME, ZBC_PRODUT, " + CRLF
		_cQry += "   			 ZBC_PRDDES, ZBC_QUANT, BC.ZBC_RACA, BC.ZBC_SEXO, ZCC_PAGFUT, BC.ZBC_TPNEG, ZBC_PEDPOR, ZBC_TEMFXA, ZBC_FAIXA, ZBC_PESO, " + CRLF
		_cQry += "   			 ZBC_ARROV, ZBC_PESO, ZBC_REND, ZBC_TTSICM, ZBC_TOTICM, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM, " + CRLF
		_cQry += "  			 A2.A2_NOME " + CRLF
		_cQry += " 		) " + CRLF
		_cQry += CRLF
		_cQry += "  , CONTRATO_DISTINCT AS ( " + CRLF
		_cQry += " 		SELECT FILIAL, CODIGO_BOV, NUMERO_LOTE, RACA, SEXO, SUM(QTD_COMPRA) QTD_COMPRA " + CRLF
		_cQry += " 		FROM CONTRATO " + CRLF
		_cQry += " 		GROUP BY FILIAL, CODIGO_BOV, NUMERO_LOTE, RACA, SEXO " + CRLF
		_cQry += " ) " + CRLF
		_cQry += CRLF
		_cQry += " , DADOS1 AS ( " + CRLF
		_cQry += "  		SELECT 	ISNULL(FT.D2_EMISSAO,'') D2_EMISSAO, " + CRLF
		_cQry += "  			   	COUNT(DISTINCT RACA) QT_RACA, " + CRLF
		_cQry += " 		   			COUNT(DISTINCT SEXO) QT_SEXO, " + CRLF
		_cQry += "  			   	SUM(D2_QUANT) QT_FAT, " + CRLF
		_cQry += "					SUM(QUANT_DEVOL) QUANT_DEVOL, " + CRLF
		_cQry += " 		   			D2_LOTECTL " + CRLF
		_cQry += " 		      FROM	FATURAMENTO FT " + CRLF
		_cQry += " 		   LEFT JOIN CONTRATO_DISTINCT  C  ON FILIAL=D2_FILIAL AND CODIGO_BOV=D2_COD " + CRLF
		_cQry += "  	   GROUP BY FT.D2_EMISSAO, D2_LOTECTL " + CRLF
		_cQry += " ) " + CRLF
		_cQry += CRLF
		_cQry += "  , ANALISE AS ( " + CRLF
		_cQry += " 	 SELECT D2_EMISSAO, D2_LOTECTL" + CRLF
		_cQry += "  		, SUM(QT_RACA) QT_RACA" + CRLF
		_cQry += "  		, SUM(QT_SEXO) QT_SEXO" + CRLF
		_cQry += "  		, QT_FAT - QUANT_DEVOL QT_FAT" + CRLF
		_cQry += " 	 FROM	DADOS1" + CRLF
		_cQry += " 	 WHERE D2_LOTECTL IS NOT NULL AND D2_LOTECTL <> ' '" + CRLF
		_cQry += "  				AND SUBSTRING(D2_LOTECTL,1,4) <> 'AUTO'" + CRLF
		_cQry += " 	 GROUP BY D2_EMISSAO, D2_LOTECTL, QT_FAT, QUANT_DEVOL" + CRLF
		_cQry += "  ) " + CRLF
		_cQry += CRLF
		_cQry += "  ,  MOVI_SALDO_INICIAL AS ( " + CRLF
		_cQry += " 	 SELECT * " + CRLF
		_cQry += " 	 FROM SD3010 " + CRLF
		_cQry += " 	 WHERE D3_FILIAL	<> ' ' " + CRLF
		_cQry += " 	   AND D3_NUMSEQ NOT IN ( " + CRLF
		_cQry += " 			 SELECT D3_NUMSEQ" + CRLF
		_cQry += " 			 FROM SD3010" + CRLF
		_cQry += " 			 WHERE	D3_FILIAL	<> ' ' " + CRLF
		// _cQry += " 				-- AND D3_LOTECTL	= '139-29' -- AND D3_TM = '001'
		_cQry += " 				AND D3_TM		= '002' " + CRLF
		_cQry += " 				AND D_E_L_E_T_	= ' '" + CRLF
		_cQry += " 		) " + CRLF
		// _cQry += " 		-- AND D3_LOTECTL	= '139-29' -- AND D3_TM = '001'
		_cQry += " 		AND D_E_L_E_T_	= ' ' " + CRLF
		_cQry += " ) " + CRLF
		_cQry += CRLF
		_cQry += " , SALDO_LOTE AS ( " + CRLF
		_cQry += " 	SELECT	D3.D3_LOTECTL " + CRLF
		_cQry += " 	  , SUM(D3.D3_QUANT) SLD_LOTE " + CRLF
		_cQry += " 	FROM SD3010 D3 " + CRLF
		_cQry += " 	JOIN MOVI_SALDO_INICIAL M ON D3.D3_FILIAL=M.D3_FILIAL AND D3.D3_NUMSEQ=M.D3_NUMSEQ" + CRLF
		_cQry += " 					AND D3.D3_LOTECTL=M.D3_LOTECTL " + CRLF
		_cQry += " 					AND D3.D_E_L_E_T_	= ' '" + CRLF
		_cQry += " 	WHERE	M.D3_FILIAL	<> ' ' " + CRLF
		_cQry += " 		AND M.D3_TM	= '499' " + CRLF
		_cQry += " 	GROUP BY D3.D3_LOTECTL " + CRLF
		_cQry += " ) " + CRLF
		_cQry += CRLF
		_cQry += "  SELECT		A.*, S.SLD_LOTE " + CRLF
		_cQry += "  FROM		ANALISE    A " + CRLF
		_cQry += "  JOIN		SALDO_LOTE S ON D2_LOTECTL=D3_LOTECTL " + CRLF
		// _cQry += "  WHERE		D2_LOTECTL = '141-18'
		_cQry += " ORDER BY D2_EMISSAO " + CRLF
		
	ElseIf cTipo $ "Fornecedor"
	
		_cQry := "  WITH  FATURAMENTO AS ( " + CRLF
		_cQry += "  		SELECT D2_FILIAL, D2_COD, D2_LOTECTL, D2_EMISSAO, D2_XDTABAT, SUM(D2_QUANT) D2_QUANT " + CRLF
		_cQry += "  		FROM	SD2010 D2 " + CRLF
		_cQry += "  		WHERE   D_E_L_E_T_=' ' " + CRLF
		_cQry += "  			AND D2_TIPO='N' " + CRLF
		If !Empty(MV_PAR11)	
			_cQry += " 	 		AND D2_LOTECTL  IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
		EndIf
		If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
			// _cQry += " 	 		AND D2_EMISSAO BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
			_cQry += " 	 		AND D2_XDTABAT BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
		EndIf
		_cQry += "				AND D2_LOTECTL <> ' ' " + CRLF
		_cQry += " 	GROUP BY D2_FILIAL, D2_COD, D2_LOTECTL, D2_EMISSAO, D2_XDTABAT " + CRLF
		_cQry += "  ), " + CRLF
		_cQry += CRLF

		_cQry += " CONTRATO AS " + CRLF
		_cQry += " 		( " + CRLF
		_cQry += "       SELECT ZBC_FILIAL					   FILIAL, " + CRLF
		_cQry += " 			 ZBC_CODIGO						   COD_CONTRATO, " + CRLF
		_cQry += " 			 ZBC_PEDIDO					       NUMERO_LOTE, " + CRLF
		_cQry += "			 ZBC_ITEMPC, " + CRLF
		_cQry += " 			 ZBC_CODFOR					       CODIGO_FORNEC, " + CRLF
		_cQry += " 			 ZBC_LOJFOR						   LOJA_FORNEC, " + CRLF
		_cQry += " 			 A2.A2_NOME					       VENDEDOR, " + CRLF
		_cQry += " 			 A2_MUN						       ORIGEM, " + CRLF
		_cQry += " 			 A2_EST						       ESTADO, " + CRLF
		_cQry += " 			 ZBC_X_CORR					       COD_CORRETOR, " + CRLF
		_cQry += " 			 A3_NOME					       CORRETOR, " + CRLF
		_cQry += " 			 ZBC_PRODUT					       CODIGO_BOV, " + CRLF
		_cQry += " 			 ZBC_PRDDES					       DESCRICAO, " + CRLF
		_cQry += " 			 BC.ZBC_QUANT				       QTD_COMPRA, " + CRLF
		_cQry += " 			 CASE WHEN BC.ZBC_RACA = 'N' THEN 'NELORE' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_RACA = 'A' THEN 'ANGUS' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_RACA = 'M' THEN 'MESTICO' " + CRLF
		_cQry += " 										 ELSE 'VERIFICAR' " + CRLF
		_cQry += " 									     END AS RACA, " + CRLF
		_cQry += " 			 CASE WHEN BC.ZBC_SEXO = 'M' THEN 'MACHO' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_SEXO = 'F' THEN 'FEMEA' " + CRLF
		_cQry += " 									     ELSE 'VERIFICAR' " + CRLF
		_cQry += " 										 END AS SEXO, " + CRLF
		_cQry += "			CASE WHEN ZCC_PAGFUT = 'S'   THEN 'SIM' " + CRLF
		_cQry += "										 ELSE 'NÃO' " + CRLF
		_cQry += "										 END AS PGTO_FUTURO, " + CRLF
		_cQry += " 			 CASE WHEN BC.ZBC_TPNEG	= 'P' THEN 'PESO' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_TPNEG	= 'K' THEN 'KG' " + CRLF
		_cQry += " 				  WHEN BC.ZBC_TPNEG	= 'Q' THEN 'CABECA' " + CRLF
		_cQry += " 										  ELSE 'VERIFICAR' " + CRLF
		_cQry += " 									      END AS TIPO_NEGOCIA, " + CRLF
		_cQry += " 			 CASE WHEN ZBC_PEDPOR = 'P'   THEN 'PAUTA' " + CRLF
		_cQry += " 			 							  ELSE 'NEGOCIACAO' " + CRLF
		_cQry += " 			 							  END AS PEDIDO_POR, " + CRLF
		_cQry += " 			 CASE WHEN ZBC_TEMFXA = 'S'   THEN 'SIM' " + CRLF
		_cQry += " 			  						      ELSE 'NÁO' " + CRLF
		_cQry += " 			  						      END AS TEM_FAIXA, ZBC_FAIXA, " + CRLF
		_cQry += " 			 ZBC_PESO			                PESO_COMPRA, " + CRLF
		_cQry += " 			 ZBC_ARROV			                VALOR_ARROB, " + CRLF
		_cQry += " 			 ZBC_REND			                RENDIMENTO, " + CRLF
		_cQry += " 			 ZBC_TTSICM			                TOTAL_SEM_ICMS, " + CRLF
		_cQry += " 			 ZBC_TOTICM			                TOTAL_ICMS, " + CRLF
		_cQry += " 			 ZBC_TTSICM+ZBC_TOTICM				GADO_ICMS_TOTAL_CONTRATO, " + CRLF
		_cQry += " 			 ZBC_VLFRPG, ZBC_ICFRVL, " + CRLF
		_cQry += " 			 ZBC_VLRCOM							VLR_COM " + CRLF
		_cQry += "         FROM ZBC010 BC " + CRLF
		_cQry += "         JOIN ZCC010 CC ON ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO " + CRLF
		_cQry += CRLF
		_cQry += "AND ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO AND ZCC_VERSAO=ZBC_VERSAO " + CRLF
 		_cQry += "			AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
 		_cQry += "				( " + CRLF
 		_cQry += "					SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
 		_cQry += "					FROM ZBC010 " + CRLF
 		_cQry += "					WHERE D_E_L_E_T_=' ' " + CRLF
 		_cQry += "					GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
 		_cQry += "				) " + CRLF
		_cQry += "		AND CC.D_E_L_E_T_=' ' " + CRLF
		_cQry += "		AND BC.D_E_L_E_T_=' ' " + CRLF
		_cQry += "	 " + CRLF
		_cQry += "   INNER JOIN SA2010 A2 ON " + CRLF
		_cQry += "   		 A2.A2_FILIAL =	' ' " + CRLF
		_cQry += " 		 AND A2.A2_COD					=		ZBC_CODFOR " + CRLF
		_cQry += " 		 AND A2.A2_LOJA					=		ZBC_LOJFOR " + CRLF
		_cQry += " 		 AND A2.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += "--   INNER JOIN ZIC010	IC ON " + CRLF
		_cQry += "-- 			 IC.ZIC_FILIAL				=		ZBC_FILIAL " + CRLF
		_cQry += "-- 		 AND IC.ZIC_CODIGO				=		BC.ZBC_CODIGO " + CRLF
		_cQry += "-- 		 AND IC.ZIC_ITEM				=		BC.ZBC_ITEZIC " + CRLF
		_cQry += CRLF
		_cQry += "--       AND ZIC_FILIAL=ZBC_FILIAL AND ZIC_CODIGO=ZBC_CODIGO AND ZIC_VERSAO=ZBC_VERSAO " + CRLF
 		_cQry += "       			AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
 		_cQry += "       				( " + CRLF
 		_cQry += "       					SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
 		_cQry += "       					FROM ZBC010 " + CRLF
 		_cQry += "       					WHERE D_E_L_E_T_=' ' " + CRLF
 		_cQry += "       					GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
 		_cQry += "       				) " + CRLF
		_cQry += "       			 " + CRLF
		_cQry += "-- 	     AND IC.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += CRLF
		_cQry += "    INNER JOIN SA3010 A3 ON " + CRLF
		_cQry += "			 A3_FILIAL=' ' " + CRLF
		_cQry += " 		 AND A3.A3_COD					=		ZBC_X_CORR " + CRLF
		_cQry += " 		 AND A3.D_E_L_E_T_=' ' " + CRLF
		//_cQry += "	-- ALTERADO " + CRLF
		_cQry += "	INNER JOIN " + RetSQLName('SB1') + " B1 ON " + CRLF
		_cQry += "					B1_FILIAL					= ' ' " + CRLF
		_cQry += "				AND B1_COD 						= ZBC_PRODUT " + CRLF
		_cQry += "				AND B1_RASTRO = 'L' " + CRLF
		_cQry += "				AND B1.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += "        WHERE " + CRLF
		_cQry += " 			 ZBC_FILIAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'" + CRLF
		_cQry += " 		 AND ZBC_CODIGO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'" + CRLF
		_cQry += " 		 AND ZBC_PEDIDO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'" + CRLF
		
		If !Empty(MV_PAR11) .or. ( !Empty(MV_PAR12) .and. !Empty(MV_PAR13))
	
			_cQry += " AND ZBC_PEDIDO IN ( " + CRLF
			_cQry += "		SELECT DISTINCT ZBC_PEDIDO FROM ZBC010 " + CRLF
			_cQry += "      WHERE ZBC_PRODUT IN ( " + CRLF
			_cQry += " 		       SELECT DISTINCT D2_COD " + CRLF
			_cQry += "				FROM SD2010 D2 " + CRLF
			_cQry += "				JOIN SF4010 F4 ON D2_TES = F4.F4_CODIGO AND F4.D_E_L_E_T_ = ' '   AND D2.D_E_L_E_T_=' ' " + CRLF
			_cQry += "		   								AND F4_TRANFIL <> '1' " + CRLF
			_cQry += " 		       WHERE 	D2_TIPO='N' " + CRLF
		
			If !Empty(MV_PAR11)	
				_cQry += " 	 		AND D2_LOTECTL  IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
			EndIf
			
			If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
				// _cQry += " 	 		AND D2_EMISSAO BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
				_cQry += " 	 		AND D2_XDTABAT BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
			EndIf
			
			_cQry += "				AND D2_LOTECTL <> ' ' " + CRLF
			_cQry += " 	 ) )" + CRLF
		
		EndIf
		
		_cQry += " 		 AND ZBC_CODFOR BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "'" + CRLF
		
		/*
		If !Empty(MV_PAR11) .or. ( !Empty(MV_PAR12) .and. !Empty(MV_PAR13))
	
			_cQry += " AND ZBC_PRODUT IN ( " +
			CRLF
			_cQry += " 		SELECT DISTINCT D2_COD FROM SD2010 " + CRLF
			_cQry += " 		WHERE 	D2_TIPO='N' " + CRLF
		
			If !Empty(MV_PAR11)	
				_cQry += " 	 		AND D2_LOTECTL  IN (" + U_cValToSQL(MV_PAR11,",") + ") " + CRLF
			EndIf
			
			If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
				_cQry += " 	 		AND D2_EMISSAO BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
			EndIf
			
			_cQry += " 		AND D_E_L_E_T_ =' ' " + CRLF
			_cQry += " 	 ) " + CRLF
		
		EndIf
		*/
		_cQry += "  GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_PEDIDO, ZBC_ITEMPC, ZBC_CODFOR, ZBC_LOJFOR, A2.A2_NOME, A2_MUN, A2_EST, ZBC_X_CORR, A3_NOME, ZBC_PRODUT, " + CRLF
		_cQry += "   			 ZBC_PRDDES, ZBC_QUANT, BC.ZBC_RACA, BC.ZBC_SEXO, ZCC_PAGFUT, BC.ZBC_TPNEG, ZBC_PEDPOR, ZBC_TEMFXA, ZBC_FAIXA, ZBC_PESO, " + CRLF
		_cQry += "   			 ZBC_ARROV, ZBC_PESO, ZBC_REND, ZBC_TTSICM, ZBC_TOTICM, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM, " + CRLF
		_cQry += "  			 A2.A2_NOME " + CRLF
		_cQry += " 		) " + CRLF
		_cQry += CRLF
		_cQry += " , DADOS1 AS ( " + CRLF
		_cQry += "  	SELECT 	DISTINCT D2_LOTECTL " + CRLF
  		_cQry += "  	FROM CONTRATO  C " + CRLF
  		_cQry += "  	LEFT JOIN FATURAMENTO FT ON FILIAL=D2_FILIAL AND CODIGO_BOV=D2_COD " + CRLF
  		_cQry += "  	GROUP BY FT.D2_EMISSAO, D2_LOTECTL " + CRLF
		_cQry += " ) " + CRLF
		_cQry += CRLF
		_cQry += " , FORNECEDOR AS ( " + CRLF
		_cQry += " 		SELECT DISTINCT B8_LOTECTL, ZCC_NOMFOR " + CRLF
		_cQry += " 		FROM ZCC010 C " + CRLF
		_cQry += " 		JOIN ZBC010 B  ON ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO " + CRLF
		_cQry += "						AND ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO AND ZCC_VERSAO=ZBC_VERSAO " + CRLF
 		_cQry += "			AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
 		_cQry += "				( " + CRLF
 		_cQry += "					SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
 		_cQry += "					FROM ZBC010 " + CRLF
 		_cQry += "					WHERE D_E_L_E_T_=' ' " + CRLF
 		_cQry += "					GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
 		_cQry += "				) " + CRLF
		_cQry += "				AND C.D_E_L_E_T_=' ' AND B.D_E_L_E_T_=' ' " + CRLF
		_cQry += " 		JOIN SB8010 B8 ON ZBC_FILIAL=B8_FILIAL  AND ZBC_PRODUT=B8_PRODUTO AND B8.D_E_L_E_T_=' ' " + CRLF
		_cQry += " 		LEFT JOIN ZAB010 AB ON ZAB_FILIAL=B8_FILIAL  AND ZAB_BAIA=B8_LOTECTL " + CRLF
		_cQry += " 		JOIN FATURAMENTO FT ON ZBC_FILIAL=D2_FILIAL AND B8_PRODUTO=D2_COD " + CRLF
		If !Empty(MV_PAR12) .and. !Empty(MV_PAR13) 
			_cQry += " 						AND D2_XDTABAT BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "'" + CRLF
		EndIf
		_cQry += " ) " + CRLF
		_cQry += CRLF
		_cQry += " SELECT F.* " + CRLF
		_cQry += " FROM	DADOS1 " + CRLF
		_cQry += " JOIN FORNECEDOR F ON B8_LOTECTL=D2_LOTECTL " + CRLF
		_cQry += " WHERE D2_LOTECTL IS NOT NULL AND D2_LOTECTL <> ' ' " + CRLF
		_cQry += " ORDER BY F.B8_LOTECTL, F.ZCC_NOMFOR " + CRLF

	Else
		
		_cQry += " FRETE AS " + CRLF
		_cQry += " 		( " + CRLF
		_cQry += " 		SELECT DISTINCT D1_FILIAL, D1_DOC, D1_SERIE, D1_EMISSAO, D1_FORNECE, D1_LOJA, A2.A2_NOME, D1_COD, B1_DESC, D1_VALICM, D1_TOTAL " + CRLF
		_cQry += " 		  FROM 		   SD1010 D1 " + CRLF
		_cQry += "         	INNER JOIN SA2010 A2 ON " + CRLF
		_cQry += "   		 		    A2.A2_FILIAL =	' ' " + CRLF
		_cQry += "          		AND A2.A2_COD					=		D1_FORNECE " + CRLF
		_cQry += "          	    AND A2.A2_LOJA					=		D1_LOJA AND A2.D_E_L_E_T_=' ' AND D1.D_E_L_E_T_=' '" + CRLF
		_cQry += "          INNER JOIN " + RetSQLName('SB1') + " B1 ON " + CRLF
		_cQry += "         				B1_FILIAL	= ' ' " + CRLF
		_cQry += "         			AND B1_COD = D1.D1_COD " + CRLF
		_cQry += "				    AND B1_RASTRO = 'L' " + CRLF
		_cQry += "					AND B1.D_E_L_E_T_=' ' " + CRLF
		_cQry += CRLF
		_cQry += " 		 WHERE D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA " + CRLF
		_cQry += " 		    IN ( " + CRLF
		_cQry += " 	        	SELECT F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_TRANSP+F8_LOJTRAN  CHAVE" + CRLF
		// --, F8_FILIAL, F8_NFDIFRE, F8_SEDIFRE, F8_DTDIGIT, F8_TRANSP, F8_LOJTRAN " + CRLF
		_cQry += " 	        	  FROM CONTRATO C" + CRLF
		_cQry += " 	         LEFT JOIN SF8010 F8 " + CRLF
		_cQry += " 	        		ON F8.F8_FILIAL				=			C.D1_FILIAL " + CRLF
		_cQry += " 	        	   AND F8.F8_FORNECE			=			C.D1_FORNECE " + CRLF
		_cQry += " 	        	   AND F8_LOJA					=			C.D1_LOJA " + CRLF
		_cQry += " 	        	   AND F8_NFORIG				=			C.D1_DOC " + CRLF
		_cQry += " 	        	   AND F8_SERORIG				=			C.D1_SERIE " + CRLF
		_cQry += " 			     WHERE F8.D_E_L_E_T_			=			' ' " + CRLF
		_cQry += " 				   AND F8_TIPO					=			'F' " + CRLF
		_cQry += " 			    ) " + CRLF
		_cQry += " 			    AND D1.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += " 		), " + CRLF
		_cQry += CRLF
		_cQry += " COMPLEMENTO AS " + CRLF
		_cQry += " 		( " + CRLF
		_cQry += " 	    	SELECT DISTINCT D1.D1_FILIAL, D1.D1_DOC, D1.D1_SERIE, D1.D1_EMISSAO, D1.D1_FORNECE, D1.D1_LOJA, A2.A2_NOME, D1.D1_COD, B1.B1_DESC, D1.D1_VALICM, D1.D1_TOTAL " + CRLF
		_cQry += " 	    		   , CASE " + CRLF
		_cQry += " 	    		   	   WHEN D1_TIPO = 'C'" + CRLF
		_cQry += " 	    		   	   		THEN  'VALOR'" + CRLF
		_cQry += " 	    		   	   		ELSE CASE WHEN D1_TIPO = 'I' THEN 'ICMS' ELSE '' END" + CRLF
		_cQry += " 	    		   	END TIPO_COMPLEMENTO" + CRLF
		_cQry += " 	    	  FROM CONTRATO C" + CRLF
		_cQry += "          LEFT JOIN SD1010 D1 ON " + CRLF
		_cQry += " 	    	       C.D1_FILIAL					=			D1.D1_FILIAL " + CRLF
		_cQry += " 	    	   AND C.D1_FORNECE					=			D1.D1_FORNECE " + CRLF
		_cQry += " 	    	   AND C.D1_LOJA					=			D1.D1_LOJA " + CRLF
		_cQry += " 	    	   AND C.D1_DOC						=			D1.D1_NFORI " + CRLF
		_cQry += " 	    	   AND C.D1_SERIE					=			D1.D1_SERIORI " + CRLF
		_cQry += " 	    	   AND D1.D1_TIPO					<>			'N' " + CRLF
		_cQry += "	    	   AND D1.D_E_L_E_T_				=			' ' " + CRLF
		_cQry += "	  	    INNER JOIN SA2010 A2 ON " + CRLF
		_cQry += "   		         A2.A2_FILIAL =	' ' " + CRLF
		_cQry += " 		  	     AND A2.A2_COD					=		D1.D1_FORNECE " + CRLF
		_cQry += " 		  		 AND A2.A2_LOJA					=		D1.D1_LOJA " + CRLF
		_cQry += " 		 	 	 AND A2.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += "		    INNER JOIN " + RetSQLName('SB1') + " B1 ON " + CRLF
		_cQry += "         				B1_FILIAL	= ' ' " + CRLF
		_cQry += "         			AND B1_COD = D1.D1_COD " + CRLF
		_cQry += "				    AND B1_RASTRO = 'L' " + CRLF
		_cQry += "					AND B1.D_E_L_E_T_=' ' " + CRLF
		_cQry += "	    	WHERE D1.D1_DOC IS NOT NULL  AND D1.D1_DOC <> ' '" + CRLF
		_cQry += " 		) " + CRLF
		_cQry += CRLF
		_cQry += " , FRETE_SUM AS ( " + CRLF
		_cQry += " 	SELECT" + CRLF
		_cQry += " 		  D1_FILIAL " + CRLF
		_cQry += " 		, D1_COD " + CRLF
		_cQry += " 		, SUM(F.D1_TOTAL)-SUM(F.D1_VALICM) TT_FRETE " + CRLF
		_cQry += " 		, SUM(F.D1_VALICM) TT_ICMS_FRETE" + CRLF
		_cQry += " 	FROM FRETE F " + CRLF
		_cQry += " 	GROUP BY D1_FILIAL " + CRLF
		_cQry += " 		   , D1_COD " + CRLF
		_cQry += " ) " + CRLF
		_cQry += CRLF
		
		If cTipo $ "Geral,Notas"

			_cQry += " 		SELECT " + CRLF
			_cQry += "          	  F.TT_FRETE " + CRLF
			_cQry += "          	, F.TT_ICMS_FRETE " + CRLF
			_cQry += "          	, SUM(NC.D1_TOTAL) TOTAL_COMPL " + CRLF
			_cQry += "          	, SUM(NC.D1_VALICM) ICMS_COMPL " + CRLF
			_cQry += "          	, C.* " + CRLF
			_cQry += " 		  FROM CONTRATO C " + CRLF
			_cQry += CRLF
			_cQry += " 	 LEFT JOIN COMPLEMENTO NC " + CRLF
			_cQry += " 			ON NC.D1_FILIAL					=			C.D1_FILIAL " + CRLF
			_cQry += " 		   AND NC.D1_FORNECE				=			C.D1_FORNECE " + CRLF
			_cQry += " 		   AND NC.D1_LOJA					=			C.D1_LOJA " + CRLF
			// _cQry += " 		   -- AND NC.D1_DOC					=			C.D1_DOC " + CRLF
			_cQry += " 	       AND RTRIM(NC.D1_COD)				=			RTRIM(C.CODIGO_BOV) " + CRLF
			_cQry += CRLF
			// _cQry += " 	 LEFT JOIN FRETE F " + CRLF
			_cQry += " 	 LEFT JOIN FRETE_SUM F " + CRLF
			_cQry += " 			ON C.D1_FILIAL					=			F.D1_FILIAL " + CRLF
			_cQry += " 		   AND C.D1_COD						=			F.D1_COD " + CRLF
			// _cQry += " 		   --AND N.D1_FORNECE				=			F.D1_FORNECE " + CRLF
			// _cQry += " 		   --AND N.D1_LOJA					=			F.D1_LOJA " + CRLF		
			_cQry += CRLF
			_cQry += " GROUP BY 	   F.TT_FRETE
			_cQry += "               , F.TT_ICMS_FRETE
			_cQry += "               , FILIAL, COD_CONTRATO, NUMERO_LOTE, ZBC_ITEMPC, " + CRLF
			_cQry += "  			 CODIGO_FORNEC, LOJA_FORNEC, VENDEDOR, " + CRLF
			_cQry += "  			 ORIGEM, ESTADO, COD_CORRETOR, " + CRLF
			_cQry += "  			 CORRETOR, CODIGO_BOV, DESCRICAO, " + CRLF
			_cQry += "  			 QTD_COMPRA, RACA, SEXO, " + CRLF
			_cQry += "  			 PGTO_FUTURO, " + CRLF
			_cQry += "  			 TIPO_NEGOCIA, " + CRLF
			_cQry += "  			 PEDIDO_POR, " + CRLF
			_cQry += "  			 TEM_FAIXA, ZBC_FAIXA, " + CRLF
			_cQry += "  			 PESO_COMPRA, " + CRLF
			_cQry += "  			 PESO_CHEGADA, " + CRLF
			_cQry += "  			 QUEBRA, " + CRLF
			_cQry += "  			 DATA_EMBARQUE, " + CRLF
			_cQry += "  			 HORA_EMBARQUE, " + CRLF
			_cQry += "  			 DATA_CHEGADA, " + CRLF
			_cQry += "  			 HORA_CHEGADA, " + CRLF
			_cQry += "  			 KM_NF_ENTRADA, " + CRLF
			_cQry += "  			 QTD_NF, " + CRLF
			_cQry += "  			 VALOR_ARROB, " + CRLF
			_cQry += "  			 RENDIMENTO, " + CRLF
			_cQry += "  			 TOTAL_SEM_ICMS, " + CRLF
			_cQry += "  			 TOTAL_ICMS, " + CRLF
			_cQry += "  			 GADO_ICMS_TOTAL_CONTRATO, " + CRLF
			_cQry += " 			 ZBC_VLFRPG, ZBC_ICFRVL, VLR_COM " + CRLF
			_cQry += " 			  , C.D1_FILIAL, C.D1_DOC, C.D1_SERIE, C.D1_EMISSAO, C.D1_FORNECE, C.D1_LOJA, " + CRLF
			_cQry += " 			    C.A2_NOME, " + CRLF
			_cQry += "  			C.D1_COD, C.B1_DESC, D1_QUANT, " + CRLF
			_cQry += "  			C.D1_VALICM, C.D1_TOTAL, " + CRLF
			_cQry += " 				PEDORIG, ITEMPCORIG " + CRLF
			_cQry += " 				, ZBC_STATUS, ZCC_NEGENC " + CRLF
			_cQry += " 			 ORDER BY VENDEDOR, NUMERO_LOTE " + CRLF

		ElseIf cTipo == "Frete"

			_cQry += " 		SELECT * FROM FRETE " + CRLF

		ElseIf cTipo == "Complemento"

			_cQry += " 		SELECT * FROM COMPLEMENTO " + CRLF

		ElseIf cTipo == "Faixa"

			_cQry += " SELECT  FILIAL, COD_CONTRATO, NUMERO_LOTE, CODIGO_FORNEC+LOJA_FORNEC FORNECEDOR, VENDEDOR, " + CRLF
			_cQry += " 		   CODIGO_BOV, DESCRICAO, QTD_COMPRA, ZBC_FAIXA, ZFX_ITEM, ZFX_FXATE, ZFX_PREMIO " + CRLF
			_cQry += " FROM CONTRATO " + CRLF
			_cQry += " JOIN ZFX010 FX ON ZFX_FILIAL=FILIAL AND ZFX_CODIGO=ZBC_FAIXA AND FX.D_E_L_E_T_=' ' " + CRLF
			
		EndIf
	EndIf
EndIf

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

// TcSetField(_cAlias, "D1_X_EMBDT", "D")
// TcSetField(_cAlias	, "D1_X_CHEDT", "D")

Return !(_cAlias)->(Eof())
// FIM: VASqlR07()



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:  SomaTotCab()            	            	            				  |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  28.05.2018	            	          	            	              |
 | Desc:  Processa quant total para o Lote; 						              |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function SomaTotCab( nI, aDro2Dad, cAgrup )
Local nI 	 := 1
Local _nSoma := 0

While nI <= Len( aDro2Dad )

	if aDro2Dad[nI, 02 ] + aDro2Dad[nI, 33 ] == cAgrup
		// _nSoma += aDro2Dad[nI, 19 ]
		_nSoma += aDro2Dad[nI, 34 ]
	EndIf
	
	nI += 1
EndDo

Return _nSoma


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:  cValToSQL()	            	            	            	          |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  24.08.2018	            	          	            	              |
 | Desc:  Gerar variavel para SQL;	            	            				  |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
User Function cValToSQL(cTexto, cSeparador)
Local cRet	 := ""
Local nI      :=0
Local aVetor := StrToKarr( cTexto, cSeparador )	

For nI := 1 to Len( aVetor )
	cRet += Iif(Empty(cRet),"",",") + "'" + AllTrim(aVetor[nI]) + "'"
Next nI

Return cRet


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:  fQuadro1()	            	            	            	          |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  11.05.2018	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1()	 // U_VACOMR07()

Local cXMLCab 		:= "", cXML := "", cXMLDo:= ""
Local cWorkSheet 	:= "Lotes - Analitico"
Local aDro1Dad		:= {}
Local cAgrup        := ""
Local nTotCabe	    := 0
Local nI			:= 0
Local aDadTMP		:= {}
Local cHora			:= ""
Local nHandAux 		:= 0, cPathBuff := cPath+'FileTMP.txt'

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	nHandAux := FCreate( cPathBuff )
	if nHandAux == -1
		Alert("Erro ao criar arquivo: " + cPathBuff + CRLF + Str(Ferror()))
		Return nil
	EndIf
	
	//fQuadro1
	While !(_cAliasG)->(Eof())	 // U_VACOMR07()

			aAdd( aDro1Dad		 , {} 									)
/* 01 */	aAdd( aTail(aDro1Dad), Iif( Empty((_cAliasG)->DATA_CHEGADA), "", sToD( (_cAliasG)->DATA_CHEGADA ) ) ) 
/* 02 */	aAdd( aTail(aDro1Dad), (_cAliasG)->NUMERO_LOTE  										)
/* 03 */	aAdd( aTail(aDro1Dad), "Compra" 														)
/* 04 */	aAdd( aTail(aDro1Dad), "Entrada"  														)
/* 05 */	aAdd( aTail(aDro1Dad), (_cAliasG)->VENDEDOR 											)  
/* 06 */	aAdd( aTail(aDro1Dad), AllTrim((_cAliasG)->ORIGEM)+"/"+AllTrim((_cAliasG)->ESTADO)      ) 							  
/* 07 */	aAdd( aTail(aDro1Dad), (_cAliasG)->CORRETOR 											)
/* 08 */	aAdd( aTail(aDro1Dad), (_cAliasG)->PESO_CHEGADA											)
/* 09 */	aAdd( aTail(aDro1Dad), (_cAliasG)->PESO_COMPRA 											)
/* 10 */	aAdd( aTail(aDro1Dad), (_cAliasG)->QUEBRA        										)
/* 11 */	aAdd( aTail(aDro1Dad), (_cAliasG)->KM_NF_ENTRADA 										)                     
//			If Empty((_cAliasG)->HORA_EMBARQUE)
///* 12 */		aAdd( aTail(aDro1Dad), (_cAliasG)->HORA_EMBARQUE )
//			Else
/* 12 */		aAdd( aTail(aDro1Dad), SubS((_cAliasG)->HORA_EMBARQUE ,1,2)	+ ":" + SubS((_cAliasG)->HORA_EMBARQUE ,3,2) )                     
//			EndIf
//			If Empty((_cAliasG)->HORA_CHEGADA)
///* 13 */		aAdd( aTail(aDro1Dad), (_cAliasG)->HORA_CHEGADA )
//			Else
/* 13 */		aAdd( aTail(aDro1Dad), SubS((_cAliasG)->HORA_CHEGADA  ,1,2)	+ ":" + SubS((_cAliasG)->HORA_CHEGADA  ,3,2) ) 
//			EndIf
/* 14 */	aAdd( aTail(aDro1Dad), "-" 						 										) 
/* 15 */	aAdd( aTail(aDro1Dad), (_cAliasG)->RACA          										)
/* 16 */	aAdd( aTail(aDro1Dad), (_cAliasG)->SEXO          										)
/* 17 */	aAdd( aTail(aDro1Dad), (_cAliasG)->DESCRICAO 	 										)   
/* 18 */	aAdd( aTail(aDro1Dad), "Boa" 					 										)
/* 19 */	aAdd( aTail(aDro1Dad), (_cAliasG)->QTD_NF 		 										)	
/* 20 */	aAdd( aTail(aDro1Dad), (_cAliasG)->VALOR_ARROB   										)
/* 21 */	aAdd( aTail(aDro1Dad), (_cAliasG)->PESO_COMPRA   										)
/* 22 */	aAdd( aTail(aDro1Dad), (_cAliasG)->RENDIMENTO 	 										)
/* 23 */	aAdd( aTail(aDro1Dad), (_cAliasG)->D1_TOTAL ) // TOTAL_NF ) // TOTAL_SEM_ICMS )

///* 24 */	aAdd( aTail(aDro1Dad), (_cAliasG)->ZBC_VLFRPG ) // TT_FRETE  	 )
/* MJ : 22.11 
	* ficou definido pelo sergio que a informacao seria pegado das notas e nao mais do contrato (Luana) 
*/
/* 24 */	aAdd( aTail(aDro1Dad), (_cAliasG)->TT_FRETE  	 )

/* 25 */	aAdd( aTail(aDro1Dad), (_cAliasG)->VLR_COM 		 										)

// /* 26 */	aAdd( aTail(aDro1Dad), (_cAliasG)->ZBC_ICFRVL ) // TT_ICMS_FRETE )
/* MJ : 22.11 
	* ficou definido pelo sergio que a informacao seria pegado das notas e nao mais do contrato (Luana) 
*/
/* 26 */	aAdd( aTail(aDro1Dad), (_cAliasG)->TT_ICMS_FRETE )

/* 27 */	aAdd( aTail(aDro1Dad), (_cAliasG)->D1_VALICM ) // TOTAL_ICMS )	// TOTAL_ICMS )
/* 28 */	aAdd( aTail(aDro1Dad), (_cAliasG)->FILIAL 												)
/* 29 */	aAdd( aTail(aDro1Dad), (_cAliasG)->COD_CONTRATO 										)
/* 30 */	aAdd( aTail(aDro1Dad), (_cAliasG)->CODIGO_FORNEC										)                     
/* 31 */	aAdd( aTail(aDro1Dad), (_cAliasG)->LOJA_FORNEC  										)    
/* 32 */	aAdd( aTail(aDro1Dad), (_cAliasG)->COD_CORRETOR 										)
/* 33 */	aAdd( aTail(aDro1Dad), (_cAliasG)->CODIGO_BOV   										)
/* 34 */	aAdd( aTail(aDro1Dad), (_cAliasG)->QTD_COMPRA   										)
/* 35 */	aAdd( aTail(aDro1Dad), (_cAliasG)->PGTO_FUTURO											)
/* 36 */	aAdd( aTail(aDro1Dad), (_cAliasG)->TIPO_NEGOCIA 										)
/* 37 */	aAdd( aTail(aDro1Dad), (_cAliasG)->PEDIDO_POR											)
/* 38 */	aAdd( aTail(aDro1Dad), (_cAliasG)->TEM_FAIXA											)
/* 39 */	aAdd( aTail(aDro1Dad), Iif( Empty((_cAliasG)->DATA_EMBARQUE), "", sToD( (_cAliasG)->DATA_EMBARQUE ) ) )
/* 40 */	aAdd( aTail(aDro1Dad), (_cAliasG)->TOTAL_ICMS   										)
/* 41 */	aAdd( aTail(aDro1Dad), (_cAliasG)->GADO_ICMS_TOTAL_CONTRATO 							)          
// /* 42 */	aAdd( aTail(aDro1Dad), (_cAliasG)->D1_TOTAL ) // TOTAL_NF     										)
/* 42 */	aAdd( aTail(aDro1Dad), (_cAliasG)->ZBC_STATUS										    )          

/* 43 */	aAdd( aTail(aDro1Dad), (_cAliasG)->ZCC_NEGENC										    )          
/* 44 */	aAdd( aTail(aDro1Dad), MV_PAR19                            							    )          

		(_cAliasG)->(DbSkip())
	EndDo
	
	// fQuadro1
	nI 		:= 1
	While nI <= Len( aDro1Dad )
		// 				numero lote    +    cod. bov
		If cAgrup <> aDro1Dad[nI, 02 ] + aDro1Dad[nI, 33 ]
			nTotCabe := SomaTotCab( nI, aDro1Dad, (cAgrup := aDro1Dad[nI, 02 ] + aDro1Dad[nI, 33 ]) )
		EndIf
		
		 aDadTMP := {}
/* 01 */ aAdd( aDadTMP , aDro1Dad[nI, 01 ] )
/* 02 */ aAdd( aDadTMP , aDro1Dad[nI, 02 ] )  // (_cAliasG)->NUMERO_LOTE
/* 03 */ aAdd( aDadTMP , aDro1Dad[nI, 03 ] )
/* 04 */ aAdd( aDadTMP , aDro1Dad[nI, 04 ] )
/* 05 */ aAdd( aDadTMP , aDro1Dad[nI, 05 ] )
/* 06 */ aAdd( aDadTMP , aDro1Dad[nI, 06 ] )
/* 07 */ aAdd( aDadTMP , aDro1Dad[nI, 07 ] )
/* 08 */ aAdd( aDadTMP , aDro1Dad[nI, 08 ] )
/* 09 */ aAdd( aDadTMP , aDro1Dad[nI, 09 ] )
/* 10 */ aAdd( aDadTMP , aDro1Dad[nI, 09 ] - aDro1Dad[nI, 08 ] )
/* 11 */ aAdd( aDadTMP , aDro1Dad[nI, 11 ] ) //	 / aDro1Dad[nI, L en(aDro1Dad[Len(aDro1Dad)]) ], ;
/* 12 */ aAdd( aDadTMP , aDro1Dad[nI, 12 ] )
/* 13 */ aAdd( aDadTMP , aDro1Dad[nI, 13 ] )
/* 14 */ aAdd( aDadTMP , aDro1Dad[nI, 14 ] )
/* 15 */ aAdd( aDadTMP , aDro1Dad[nI, 15 ] )
/* 16 */ aAdd( aDadTMP , aDro1Dad[nI, 16 ] )
/* 17 */ aAdd( aDadTMP , aDro1Dad[nI, 17 ] )
/* 18 */ aAdd( aDadTMP , aDro1Dad[nI, 18 ] ) 	

///* 19 */ aAdd( aTail(aDadTMP) , nTotCabe ) // aDro1Dad[nI, 19 ], ; // "Cabeças NF" 	
/* 19 */ aAdd( aDadTMP , aDro1Dad[nI, 19 ] )
/* 	MJ : 21.11.18
	* Mudei a linha acima por erros no contrato: 000254, 000263;
	estava gerando produtos carteziado;
	* Acredito que a funcao: SOMATOTCAB pode ser usada apenas no SINTETICO;
*/

/* 20 */ aAdd( aDadTMP , aDro1Dad[nI, 20 ] )
/* 21 */ aAdd( aDadTMP , aDro1Dad[nI, 21 ] )
/* 22 */ aAdd( aDadTMP , aDro1Dad[nI, 22 ] )
/* 23 */ aAdd( aDadTMP , aDro1Dad[nI, 23 ]-aDro1Dad[nI, 27 ] ) // aDro1Dad[nI, 23 ] * aDro1Dad[nI, 19 ] / nTotCabe, ; // "R$ Gado"	
/* 24 */ aAdd( aDadTMP , aDro1Dad[nI, 24 ] * aDro1Dad[nI, 19 ] / nTotCabe )
/* 25 */ aAdd( aDadTMP , aDro1Dad[nI, 25 ] * aDro1Dad[nI, 19 ] / nTotCabe )
/* 26 */ aAdd( aDadTMP , aDro1Dad[nI, 26 ] * aDro1Dad[nI, 19 ] / nTotCabe )
/* 27 */ aAdd( aDadTMP , aDro1Dad[nI, 27 ] * aDro1Dad[nI, 19 ] / nTotCabe )
/* 28 */ aAdd( aDadTMP , aDro1Dad[nI, 28 ] )
/* 29 */ aAdd( aDadTMP , aDro1Dad[nI, 29 ] )
/* 30 */ aAdd( aDadTMP , aDro1Dad[nI, 30 ] )
/* 31 */ aAdd( aDadTMP , aDro1Dad[nI, 31 ] )
/* 32 */ aAdd( aDadTMP , aDro1Dad[nI, 32 ] )
/* 33 */ aAdd( aDadTMP , aDro1Dad[nI, 33 ] )
/* 34 */ aAdd( aDadTMP , aDro1Dad[nI, 34 ] ) // QTD_COMPRA
/* 35 */ aAdd( aDadTMP , aDro1Dad[nI, 35 ] )
/* 36 */ aAdd( aDadTMP , aDro1Dad[nI, 36 ] )
/* 37 */ aAdd( aDadTMP , aDro1Dad[nI, 37 ] )
/* 38 */ aAdd( aDadTMP , aDro1Dad[nI, 38 ] )
/* 39 */ aAdd( aDadTMP , aDro1Dad[nI, 39 ] )
/* 40 */ aAdd( aDadTMP , aDro1Dad[nI, 40 ] )
/* 41 */ aAdd( aDadTMP , aDro1Dad[nI, 41 ] )
/* 42 */ aAdd( aDadTMP , aDro1Dad[nI, 42 ] )
/* 43 */ aAdd( aDadTMP , aDro1Dad[nI, 43 ] )
/* 44 */ aAdd( aDadTMP , aDro1Dad[nI, 44 ] )
	
		// fQuadro1
		// oExcel:AddRow( cWorkSheet, cTitulo, aDadTMP )
		 cXML += '<Row>' + CRLF
/* 01 */ cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( aDadTMP[01] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[02] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[03] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[04] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[05] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[06] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[07] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[08] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[09] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[10] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[11] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		
		If aDadTMP[12] == "  :  "
/* 12 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
		 cHora := "1899-12-31T"+aDadTMP[12]+":00.000"
/* 12 */ cXML += '  <Cell ss:StyleID="sHora"><Data ss:Type="DateTime">'  + cHora + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf
	
		If aDadTMP[13] == "  :  "
/* 13 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
		 cHora := "1899-12-31T"+aDadTMP[13]+":00.000"
/* 13 */ cXML += '  <Cell ss:StyleID="sHora"><Data ss:Type="DateTime">'  + cHora + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf
		
/* 14 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[14] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 15 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[15] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 16 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[16] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 17 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[17] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 18 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[18] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 19 */ cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[19] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 20 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[20] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 21 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[21] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 22 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[22] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 23 */ cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">'   + U_FrmtVlrExcel( aDadTMP[23] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 24 */ cXML += '  <Cell ss:StyleID="sRealFundoVerdeClaro" ss:Formula="=IFERROR(RC[-1]+IFERROR(SUMIFS(Complemento!R3C10:R100000C10,Complemento!R3C7:R100000C7,RC[-10],Complemento!R3C11:R100000C11,&quot;VALOR&quot;),0),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 25 */ cXML += '  <Cell ss:StyleID="sRealFundoVerdeClaro"><Data ss:Type="Number">'   + U_FrmtVlrExcel( aDadTMP[24] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 26 */ cXML += '  <Cell ss:StyleID="sRealFundoVerdeClaro"><Data ss:Type="Number">'   + U_FrmtVlrExcel( aDadTMP[25] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 27 */ cXML += '  <Cell ss:StyleID="sRealFundoAmareloClaro"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[26] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 28 */ cXML += '  <Cell ss:StyleID="sRealFundoAmareloClaro"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[27] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 29 */ cXML += '  <Cell ss:StyleID="sRealFundoAzulOcean" ss:Formula="=SUM(RC[-5]:RC[-1])"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 30 */ cXML += '  <Cell ss:StyleID="sRealFundoAzulOcean" ss:Formula="=RC[-1]/RC[-11]"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 31 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=(RC[-3]/RC[-12])+(RC[-4]/RC[-12])"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 32 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[-3]/(RC[-24]/30),)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 33 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[28] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 34 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[29] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 35 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[30] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 36 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[31] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 37 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[32] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 38 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[33] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 39 */ cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[34] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 40 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[35] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 41 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[36] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 42 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[37] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 43 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[38] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 44 */ cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( aDadTMP[39] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 45 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[43] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 46 */ cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">'   + U_FrmtVlrExcel( aDadTMP[44] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

         cXML += '</Row>' + CRLF

		aAdd( _aDados, aDadTMP )
		
		// cXMLDo += EncodeUTF8(cXML)
		If !Empty( cXML )
			FWrite( nHandAux, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
		
		nI += 1
	EndDo
	
	// fQuadro1
	// Final da Planilha
	cXML += '</Table>' + CRLF
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <PageSetup>' + CRLF
	cXML += '   <Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '   <Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '   <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += '   </PageSetup>' + CRLF
	cXML += '   <Unsynced/>' + CRLF
	If MV_PAR16 == 1
	cXML += '   <Visible>SheetHidden</Visible>' + CRLF
	EndIf
	cXML += '   <FreezePanes/>' + CRLF
	cXML += '   <FrozenNoSplit/>' + CRLF
	cXML += '   <SplitHorizontal>3</SplitHorizontal>' + CRLF
	cXML += '   <TopRowBottomPane>3</TopRowBottomPane>' + CRLF
	cXML += '   <ActivePane>2</ActivePane>' + CRLF
	cXML += '   <Panes>' + CRLF
    cXML += '    <Pane>' + CRLF
    cXML += '     <Number>3</Number>' + CRLF
    cXML += '    </Pane>' + CRLF
    cXML += '    <Pane>' + CRLF
    cXML += '     <Number>2</Number>' + CRLF
    cXML += '     <ActiveRow>24</ActiveRow>' + CRLF
    cXML += '     <ActiveCol>4</ActiveCol>' + CRLF
    cXML += '    </Pane>' + CRLF
    cXML += '   </Panes>' + CRLF
	cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += '   </WorksheetOptions>' + CRLF
	cXML += '  <AutoFilter x:Range="R3C1:R' + AllTrim(Str( Len(_aDados)+3 )) + 'C44" xmlns="urn:schemas-microsoft-com:office:excel"></AutoFilter>' + CRLF
	cXML += '  <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += "  <Range>R4C9:R" + AllTrim(Str( Len(_aDados)+3 )) + "C9</Range>" + CRLF
	cXML += "  <Condition>" + CRLF
	cXML += "  		<Qualifier>Equal</Qualifier>" + CRLF
	cXML += "  		<Value1>0</Value1>" + CRLF
	cXML += "  		<Format Style='font-weight:700;background:#A6A6A6'/>" + CRLF
	cXML += "  </Condition>" + CRLF
	cXML += "  </ConditionalFormatting>" + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	// cXMLDo += EncodeUTF8(cXML)
	// cXML := ""
	
	If !Empty( cXML )
		FWrite( nHandAux, EncodeUTF8( cXML ) )
	EndIf
	fClose(nHandAux)
	cXML := ""
	
		 // Inicio // fQuadro1 -> "Lotes - Analitico"
		 cXMLCab := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		 cXMLCab += ' <Names>'
		 cXMLCab += '   <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=' + "'Lotes - Analitico'" + '!R3C1:R' + AllTrim(Str( Len(_aDados)+3 )) + 'C44" ss:Hidden="1"/>'
		 cXMLCab += ' </Names>'
		 cXMLCab += '  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
		 cXMLCab += ' 		<Column ss:Width="55.5"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="41.25"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="45"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="50.25"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="122.25"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="84.75"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="71.25"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="65.25"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="62.25"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="52.5"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="39.75"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="70.5"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="64.5"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="30.75"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="48.75"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="37.5"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="51.75"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="25.5"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="54"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="39.75"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="52.5"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="37.5"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="72.75"/>' + CRLF
		 cXMLCab += ' 		<Column ss:Width="111"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="66.75"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="61.5"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="65.25"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="70.5"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="80.25"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="61.5"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="72.75"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="91.5"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="26.25"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="41.25"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="60"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="57"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="63.75"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="87.75"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="60"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="63.75"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="51"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="63.75"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="71.25"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="62.25"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="66.75"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="99"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="72.75"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="89.25"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="115.5"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="72.75"/>' + CRLF
		 cXMLCab += '       <Column ss:Width="105"/>' + CRLF
		 cXMLCab += ' <Row ss:Height="36">' + CRLF
		 cXMLCab += '   <Cell ss:MergeAcross="47" ss:StyleID="s62">' + CRLF
		 // cXMLCab += '     <Data ss:Type="String">' + cTitulo + " de " + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>' + CRLF
		 cXMLCab += '     <Data ss:Type="String">Lote de Compra - Análitico</Data>' + CRLF
		 cXMLCab += '   </Cell>' + CRLF
		 cXMLCab += ' </Row>' + CRLF
		 cXMLCab += ' <Row ss:Height="16.5">' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  </Row>' + CRLF
		 cXMLCab += '   <Row ss:Height="33">' + CRLF
/* 01 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Chegada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Nro Lote</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Operação</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Ent / Saída</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Vendedor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Origem/Estado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Corretor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Chegada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Compra</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Quebra</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">KM</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Hora Embarque</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Hora Chegada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 14 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Jejum</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 15 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Raça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 16 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Sexo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 17 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Era</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 18 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Tipo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 19 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cabeças NF</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 20 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Valor @</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 21 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Pagar</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 22 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Rend %</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 23 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Gado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 24 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Gado + Complemento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 25 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Frete</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 26 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Comissão</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 27 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ ICMS Frete</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 28 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ ICMS GADO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 29 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ TOTAL GADO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 30 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ CABECA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 31 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">ICMS x Cabeça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 32 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total @ Chegada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 33 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 34 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 35 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Fornec.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 36 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Loja Fornec.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 37 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Corretor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 38 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. BOV</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 39 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Qtd Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 40 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Pagto. Futuro</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 41 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Tp. Negoc.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 42 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Pedido Por</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 43 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Tem Premiacao</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 44 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Embarque</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 45 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Finalizado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 46 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Valor @</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

// /* 45 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Total ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 46 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Total Gado com ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 47 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total NF</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 48 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total NF Compl.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 49 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total NF Compl. ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 50 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Frete</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 51 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total NF Frete ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
	
	FWrite(nHandle, EncodeUTF8( cXMLCab ) )
	U_Unir2Arqs( nHandle, nHandAux, cPathBuff )
	
	// cXML := EncodeUTF8(cXMLCab) + cXMLDo
	// 
	// If !Empty(cXML)
	// 	// FWrite(nHandle, EncodeUTF8( cXMLCab + cXML ) )
	// 	FWrite(nHandle, cXML )
	// EndIf
	cXML := ""	
	
EndIf

Return nil
// FIM: fQuadro1


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:  fQuadro2()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  15.05.2018	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |        Processamento de dados Sinteticos;             	            	      |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro2()	 // U_VACOMR07()

Local cWorkSheet := "Lotes - Sintetico"
Local cXMLCab 		:= "", cXML := "", cXMLDo:= ""
Local lContinua  := .T.
Local aDro2Dad	 := {}
Local cAgrup	 := ""
Local xAux		 := ""
Local aDadTMP	 := {}

Local nTotCabe	 := 0
Local nTotQd2	 := 3
Local nHandAux 		:= 0, cPathBuff := cPath+'FileTMP.txt'

// (_cAliasG)->(DbGoTop()) 
// If !(_cAliasG)->(Eof())
If Len( _aDados ) > 0
	
	nHandAux := FCreate( cPathBuff )
	if nHandAux == -1
		Alert("Erro ao criar arquivo: " + cPathBuff + CRLF + Str(Ferror()))
		Return nil
	EndIf
	
	// While !(_cAliasG)->(Eof())	 // U_VACOMR07()
	nI 		:= 1
	While nI <= Len( _aDados )
	
		// fQuadro2
		If AllTrim( cAgrup ) <> _aDados[nI, 05 ] + _aDados[nI, 33 ]
		// If AllTrim( cAgrup ) <> AllTrim( _aDados[ nI, 1] ) + AllTrim( _aDados[ nI, 5] ) + _aDados[ nI, 2] + _aDados[ nI, 35]
		// If AllTrim( cAgrup ) <> AllTrim( (_cAliasG)->DATA_CHEGADA ) + AllTrim( (_cAliasG)->VENDEDOR ) + (_cAliasG)->NUMERO_LOTE + (_cAliasG)->ZBC_ITEMPC + AllTrim( (_cAliasG)->CODIGO_BOV )
			
			aAdd( aDro2Dad		 , {} 				 )
/* 01 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 01 ] )
/* 02 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 02 ] )
/* 03 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 03 ] )
/* 04 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 04 ] )
/* 05 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 05 ] )
/* 06 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 06 ] )
/* 07 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 07 ] )
/* 08 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 08 ] )
/* 09 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 09 ] )
/* 10 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 10 ] )
/* 11 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 11 ] )
/* 12 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 12 ] )
/* 13 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 13 ] )
/* 14 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 14 ] )
/* 15 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 15 ] )
/* 16 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 16 ] )
/* 17 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 17 ] )
/* 18 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 18 ] )
/* 19 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 19 ] )
/* 20 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 20 ] )
/* 21 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 21 ] )
/* 22 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 22 ] )
/* 23 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 23 ] )
/* 24 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 24 ] )
/* 25 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 25 ] )
/* 26 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 26 ] )
/* 27 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 27 ] )
/* 28 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 28 ] )
/* 29 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 29 ] )
/* 30 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 30 ] )
/* 31 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 31 ] )
/* 32 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 32 ] )
/* 33 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 33 ] )
/* 34 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 34 ] )
/* 35 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 35 ] )
/* 36 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 36 ] )
/* 37 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 37 ] )
/* 38 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 38 ] )
/* 39 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 39 ] )
/* 40 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 40 ] )
/* 41 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 41 ] )
/* 42 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 42 ] )
/* 43 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 43 ] )
/* 44 */	aAdd( aTail(aDro2Dad), _aDados[ nI, 44 ] )
		
			// Controlar a quantidade de registros UNIFICADOS para calculo da MEDIA
			aAdd( aTail(aDro2Dad), 1				 )						
		
		Else
			
			// fQuadro2
			aDro2Dad[ Len(aDro2Dad), Len(aDro2Dad[Len(aDro2Dad)]) ] += 1
		
			// Nro Lote
			xAux := AllTrim( _aDados[ nI, 02 ] )
			If !(xAux $ aDro2Dad[ Len(aDro2Dad), 02 ] )  // OU If AT( xAux, aDro2Dad[ Len(aDro2Dad), 2 ] ) == 0
				aDro2Dad[ Len(aDro2Dad), 02 ]  += Iif( Empty(aDro2Dad[ Len(aDro2Dad), 02 ]), "", Iif(Empty(xAux), "", " | ")) + xAux
			EndIf
			
			// Peso Chegada
			aDro2Dad[ Len(aDro2Dad), 08 ]  += _aDados[ nI, 08 ]
			
			// Peso Compra
			if Empty(aDro2Dad[ Len(aDro2Dad), 09 ])
				aDro2Dad[ Len(aDro2Dad), 09 ]  += _aDados[ nI, 09 ]
			EndIf

			// Quebra
			// sera qualculado na hora da impressao
			// aDro2Dad[ Len(aDro2Dad), 10 ]  += (_cAliasG)->PESO_CHEGADA-(_cAliasG)->PESO_COMPRA
			
			// MEDIA
			// KM
			if Empty(aDro2Dad[ Len(aDro2Dad), 11 ])
				aDro2Dad[ Len(aDro2Dad), 11 ]  += _aDados[ nI, 11 ]
			EndIf
			
			/* 	MJ : 21.11.18
				* Mudei a linha acima por erros no contrato: 000254, 000263;
				estava gerando produtos carteziado;
				* Acredito que a funcao: SOMATOTCAB pode ser usada apenas no SINTETICO;
				
				abaixo estava comentado
			*/
			// Cabeças	
			aDro2Dad[ Len(aDro2Dad), 19 ] += _aDados[ nI, 19 ]
			
			// Valor @	
			if Empty( aDro2Dad[ Len(aDro2Dad), 20 ] )
				aDro2Dad[ Len(aDro2Dad), 20 ] += _aDados[ nI, 20 ]
			EndIf
			
			// Peso Pagar	
			if Empty( aDro2Dad[ Len(aDro2Dad), 21 ] )
				aDro2Dad[ Len(aDro2Dad), 21 ] += _aDados[ nI, 21 ]
			EndIf
			
			// Rend %	
			if empty( aDro2Dad[ Len(aDro2Dad), 22 ] )
				aDro2Dad[ Len(aDro2Dad), 22 ] += _aDados[ nI, 22 ] // (_cAliasG)->RENDIMENTO*(_cAliasG)->PESO_COMPRA
			EndIf
			
			// R$ Gado	
			// If Empty( aDro2Dad[ Len(aDro2Dad), 23 ] )
			If _aDados[ nI, 42 ] <> 'R' // R = Renegociação
				aDro2Dad[ Len(aDro2Dad), 23 ] += _aDados[ nI, 23 ] // (_cAliasG)->TOTAL_SEM_ICMS
			EndIf
			// EndIf
			
			// R$ Frete	
			// if empty( aDro2Dad[ Len(aDro2Dad), 24 ] )
				aDro2Dad[ Len(aDro2Dad), 24 ] += _aDados[ nI, 24 ] // (_cAliasG)->TT_FRETE
			// EndIf
			
			// R$ Comissão
			// if empty( aDro2Dad[ Len(aDro2Dad), 25 ] )
				aDro2Dad[ Len(aDro2Dad), 25 ] += _aDados[ nI, 25 ] // (_cAliasG)->VLR_COM
			// EndIf
			
			// R$ ICMS Frete	
			// if empty( aDro2Dad[ Len(aDro2Dad), 26 ] )
				aDro2Dad[ Len(aDro2Dad), 26 ] += _aDados[ nI, 26 ] // (_cAliasG)->TT_ICMS_FRETE
			// EndIf
			
			// R$ ICMS GADO
			// if empty( aDro2Dad[ Len(aDro2Dad), 27 ] )
				aDro2Dad[ Len(aDro2Dad), 27 ] += _aDados[ nI, 27 ] // (_cAliasG)->TOTAL_ICMS
			// EndIf
			
			
			/* 	MJ : 21.11.18
				* Mudei a linha acima por erros no contrato: 000254, 000263;
				estava gerando produtos carteziado;
				* Acredito que a funcao: SOMATOTCAB pode ser usada apenas no SINTETICO;
				
				abaixo ele estava somando/concatenando, agora eu deixei comentado;
				varios pontos do fonte foram alterados
			*/

			// Qtd Contrato 34 */ => Coluna 40
			// aDro2Dad[ Len(aDro2Dad), 34 ] += _aDados[ nI, 34 ] // (_cAliasG)->QTD_COMPRA
		EndIf
		
		// NAO PODE MUDAR A ORDEM DAS LINHAS ABAIXO
		// 1
		cAgrup := _aDados[nI, 05 ] + _aDados[nI, 33 ]
		// 2
		// (_cAliasG)->(DbSkip())
		nI += 1
	EndDo

	// impressao do QUADRO PRINCIPAL
	nI 		:= 1
	While nI <= Len( aDro2Dad )
		
		// fQuadro2
		If cAgrup <> aDro2Dad[nI, 02 ] + aDro2Dad[nI, 33 ]
			nTotCabe := SomaTotCab( nI, aDro2Dad, (cAgrup := aDro2Dad[nI, 02 ] + aDro2Dad[nI, 33 ]) )
		EndIf
	
		aDadTMP := {}
/* 01 */ aAdd( aDadTMP , aDro2Dad[nI, 01 ] )
/* 02 */ aAdd( aDadTMP , aDro2Dad[nI, 02 ] )  // (_cAliasG)->NUMERO_LOTE
/* 03 */ aAdd( aDadTMP , aDro2Dad[nI, 03 ] )
/* 04 */ aAdd( aDadTMP , aDro2Dad[nI, 04 ] )
/* 05 */ aAdd( aDadTMP , aDro2Dad[nI, 05 ] )
/* 06 */ aAdd( aDadTMP , aDro2Dad[nI, 06 ] )
/* 07 */ aAdd( aDadTMP , aDro2Dad[nI, 07 ] )
/* 08 */ aAdd( aDadTMP , aDro2Dad[nI, 08 ] )
/* 09 */ aAdd( aDadTMP , aDro2Dad[nI, 09 ] )
/* 10 */ aAdd( aDadTMP , aDro2Dad[nI, 09 ] - aDro2Dad[nI, 08 ] )
/* 11 */ aAdd( aDadTMP , aDro2Dad[nI, 11 ] ) //	 / aDro2Dad[nI, Len(aDro2Dad[Len(aDro2Dad)]) ], ;
/* 12 */ aAdd( aDadTMP , aDro2Dad[nI, 12 ] )
/* 13 */ aAdd( aDadTMP , aDro2Dad[nI, 13 ] )
/* 14 */ aAdd( aDadTMP , aDro2Dad[nI, 14 ] )
/* 15 */ aAdd( aDadTMP , aDro2Dad[nI, 15 ] )
/* 16 */ aAdd( aDadTMP , aDro2Dad[nI, 16 ] )
/* 17 */ aAdd( aDadTMP , aDro2Dad[nI, 17 ] )
/* 18 */ aAdd( aDadTMP , aDro2Dad[nI, 18 ] )
/* 19 */ aAdd( aDadTMP , aDro2Dad[nI, 19 ] )
/* 20 */ aAdd( aDadTMP , aDro2Dad[nI, 20 ] )
/* 21 */ aAdd( aDadTMP , aDro2Dad[nI, 21 ] )
/* 22 */ aAdd( aDadTMP , aDro2Dad[nI, 22 ] )
/* 23 */ aAdd( aDadTMP , aDro2Dad[nI, 23 ] ) // aDro2Dad[nI, 23 ] * aDro2Dad[nI, 19 ] / nTotCabe, ;
/* 24 */ aAdd( aDadTMP , aDro2Dad[nI, 24 ] * aDro2Dad[nI, 19 ] / nTotCabe )
/* 25 */ aAdd( aDadTMP , aDro2Dad[nI, 25 ] * aDro2Dad[nI, 19 ] / nTotCabe )
/* 26 */ aAdd( aDadTMP , aDro2Dad[nI, 26 ] * aDro2Dad[nI, 19 ] / nTotCabe )
/* 27 */ aAdd( aDadTMP , aDro2Dad[nI, 27 ] * aDro2Dad[nI, 19 ] / nTotCabe )
/* 28 */ aAdd( aDadTMP , aDro2Dad[nI, 28 ] )
/* 29 */ aAdd( aDadTMP , aDro2Dad[nI, 29 ] )
/* 30 */ aAdd( aDadTMP , aDro2Dad[nI, 30 ] )
/* 31 */ aAdd( aDadTMP , aDro2Dad[nI, 31 ] )
/* 32 */ aAdd( aDadTMP , aDro2Dad[nI, 32 ] )
/* 33/* 33 */ aAdd( aDadTMP , aDro2Dad[nI, 33 ] )
/* 34 */ aAdd( aDadTMP , aDro2Dad[nI, 34 ] )
/* 35 */ aAdd( aDadTMP , aDro2Dad[nI, 35 ] )
/* 36 */ aAdd( aDadTMP , aDro2Dad[nI, 36 ] )
/* 37 */ aAdd( aDadTMP , aDro2Dad[nI, 37 ] )
/* 38 */ aAdd( aDadTMP , aDro2Dad[nI, 38 ] )
/* 39 */ aAdd( aDadTMP , aDro2Dad[nI, 39 ] )
/* 40 */ aAdd( aDadTMP , aDro2Dad[nI, 40 ] )
/* 41 */ aAdd( aDadTMP , aDro2Dad[nI, 41 ] )
/* 42 */ aAdd( aDadTMP , aDro2Dad[nI, 42 ] )
/* 43 */ aAdd( aDadTMP , aDro2Dad[nI, 43 ] )
/* 44 */ aAdd( aDadTMP , aDro2Dad[nI, 44 ] )

		// fQuadro2
		cXML += '<Row>' + CRLF
/* 01 */ cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( aDadTMP[01] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[02] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=VLOOKUP(RC[-1],' + "'Custo Baia'" + '!R4C1:R65000C2,2,0)"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[03] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[04] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[05] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[06] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[07] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[08] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[09] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[10] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[11] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

		If aDadTMP[12] == "  :  "
/* 13 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
		 cHora := "1899-12-31T"+aDadTMP[12]+":00.000"
/* 13 */ cXML += '  <Cell ss:StyleID="sHora"><Data ss:Type="DateTime">'  + cHora + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf
		
		If aDadTMP[13] == "  :  "
/* 13 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
		 cHora := "1899-12-31T"+aDadTMP[13]+":00.000"
/* 14 */ cXML += '  <Cell ss:StyleID="sHora"><Data ss:Type="DateTime">'  + cHora + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf
		
/* 15 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[14] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 16 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[15] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 17 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[16] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 18 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[17] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 19 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[18] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 20 */ cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[19] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 21 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[20] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 22 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[21] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 23 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[22] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 24 */ cXML += '  <Cell ss:StyleID="sRealFundoVerdeClaro"><Data ss:Type="Number">'   + U_FrmtVlrExcel( aDadTMP[23] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 25 */ cXML += '  <Cell ss:StyleID="sRealFundoVerdeClaro" ss:Formula="=IFERROR(RC[-1]+IFERROR(SUMIFS(Complemento!R3C10:R100000C10,Complemento!R3C7:R100000C7,RC[14],Complemento!R3C11:R100000C11,&quot;VALOR&quot;),0),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 26 */ cXML += '  <Cell ss:StyleID="sRealFundoVerdeClaro"><Data ss:Type="Number">'   + U_FrmtVlrExcel( aDadTMP[24] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 27 */ cXML += '  <Cell ss:StyleID="sRealFundoVerdeClaro"><Data ss:Type="Number">'   + U_FrmtVlrExcel( aDadTMP[25] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 28 */ cXML += '  <Cell ss:StyleID="sRealFundoAmareloClaro"><Data ss:Type="Number">'   + U_FrmtVlrExcel( aDadTMP[26] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 29 */ cXML += '  <Cell ss:StyleID="sRealFundoAmareloClaro" ss:Formula="=SUMIF(' + "'Notas Fiscais de Entrada'" + '!R3C7:R100000C7,' + "'Lotes - Sintetico'" + '!RC[10],' + "'Notas Fiscais de Entrada'" + '!R3C11:R100000C11)+IFERROR(SUMIFS(Complemento!R3C10:R100000C10,Complemento!R3C7:R100000C7,RC[10],Complemento!R3C11:R100000C11,&quot;ICMS&quot;),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 29 */ cXML += '  <Cell ss:StyleID="sRealFundoAmareloClaro"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[27] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 30 */ cXML += '  <Cell ss:StyleID="sRealFundoAzulOcean" ss:Formula="=SUM(RC[-5]:RC[-1])"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 31 */ cXML += '  <Cell ss:StyleID="sRealFundoAzulOcean" ss:Formula="=RC[-1]/RC[-11]"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 32 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=(RC[-3]/RC[-12])+(RC[-4]/RC[-12])"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 33 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[-3]/(RC[-11]/30),)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 34 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[28] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 35 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[29] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 36 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[30] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 37 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[31] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 38 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[32] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 39 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[33] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 40 */ cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[34] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 41 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[35] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 42 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[36] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 43 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[37] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 44 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[38] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 45 */ cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( aDadTMP[39] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 46 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[43] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 47 */ cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">'   + U_FrmtVlrExcel( aDadTMP[44] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

// /* 46 */ cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">'   + U_FrmtVlrExcel( aDadTMP[40] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 47 */ cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">'   + U_FrmtVlrExcel( aDadTMP[41] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 48 */ cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">'   + U_FrmtVlrExcel( aDadTMP[42] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 49 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(SUMIFS(Complemento!R3C10:R100000C10,Complemento!R3C7:R100000C7,RC[-10],Complemento!R3C11:R100000C11,&quot;VALOR&quot;),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 50 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(SUMIFS(Complemento!R3C10:R100000C10,Complemento!R3C7:R100000C7,RC[-11],Complemento!R3C11:R100000C11,&quot;ICMS&quot;),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 51 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(SUMIF(Frete!R3C7:R100000C7,RC38,Frete!R3C11:R100000C11),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 52 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(SUMIF(Frete!R3C7:R100000C7,RC38,Frete!R3C10:R100000C10),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXML += '</Row>' + CRLF
// fQuadro2
		nI += 1
		nTotQd2 += 1
		
		// cXMLDo += EncodeUTF8(cXML)
		If !Empty( cXML )
			FWrite( nHandAux, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
		
	EndDo
//fQuadro2
	// Final da Planilha
	cXML += '</Table>' + CRLF
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <PageSetup>' + CRLF
	cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
	cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += '   </PageSetup>' + CRLF
	cXML += '   <Unsynced/>' + CRLF
	cXML += '   <Selected/>' + CRLF
	cXML += '   <FreezePanes/>' + CRLF
	cXML += '   <FrozenNoSplit/>' + CRLF
	cXML += '   <SplitHorizontal>3</SplitHorizontal>' + CRLF
	cXML += '   <TopRowBottomPane>3</TopRowBottomPane>' + CRLF
	cXML += '   <ActivePane>2</ActivePane>' + CRLF
	cXML += '   <Panes>' + CRLF
	cXML += '   <Pane>' + CRLF
	cXML += '   	<Number>3</Number>' + CRLF
	cXML += '   </Pane>' + CRLF
	cXML += '   <Pane>' + CRLF
	cXML += '   	<Number>2</Number>' + CRLF
	cXML += '   <ActiveRow>4</ActiveRow>' + CRLF
	cXML += '   </Pane>' + CRLF
	cXML += '   </Panes>' + CRLF
	cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += '  </WorksheetOptions>' + CRLF
	cXML += '  <AutoFilter x:Range="R3C1:R' + AllTrim(Str( nTotQd2+3 )) + 'C45" xmlns="urn:schemas-microsoft-com:office:excel"></AutoFilter>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	// cXMLDo += EncodeUTF8(cXML)
	If !Empty( cXML )
		FWrite( nHandAux, EncodeUTF8( cXML ) )
	EndIf
	fClose(nHandAux)
	cXML := ""
	
		 // Inicio // fQuadro2 -> "Lotes - Sintetico"
		 cXMLCab := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		 cXMLCab += ' <Names>'
		 cXMLCab += '   <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=' + "'Lotes - Sintetico'" + '!R3C1:R' + AllTrim(Str( nTotQd2+3 )) + 'C45" ss:Hidden="1"/>'
		 cXMLCab += ' </Names>'
		 cXMLCab += '  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
		 cXMLCab += ' 		<Column ss:Width="51.75"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="36.75"/>' + CRLF
		 cXMLCab += '      <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="34.5"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="49.5"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="52.5"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="124.5"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="115.5"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="111"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="57.75" ss:Span="2"/>' + CRLF
		 cXMLCab += '      <Column ss:Index="12" ss:Width="52.5"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="51.75"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="45.75"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="33"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="37.5"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="39.75"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="24.75"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="26.25"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="44.25"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="39.75"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="63"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="39.75"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="82.5" ss:Span="9"/>' + CRLF
		 cXMLCab += '      <Column ss:Index="34" ss:Width="28.5"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="45"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="39.75"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="62.25"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="66.75"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="87.75"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="63.75"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="36"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="53.25"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="66.75"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="53.25"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="66"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="66.75"/>' + CRLF
		 // cXMLCab += '      <Column ss:Width="78"/>
		 // cXMLCab += '      <Column ss:Width="72.75"/>
		 // cXMLCab += '      <Column ss:Width="93.75" ss:Span="1"/>
		 // cXMLCab += '      <Column ss:Index="51" ss:Width="45"/>
		 // cXMLCab += '      <Column ss:Width="84"/>
		 cXMLCab += ' <Row ss:Height="36">' + CRLF
		 cXMLCab += '     <Cell ss:MergeAcross="47" ss:StyleID="s62">' + CRLF
		 // cXMLCab += '       <Data ss:Type="String">' + cTitulo + " de " + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>' + CRLF
		 cXMLCab += '     <Data ss:Type="String">Lote de Compra - Sintético</Data>' + CRLF
		 cXMLCab += '     </Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
		 cXMLCab += ' <Row ss:Height="16.5">' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 // cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  </Row>' + CRLF
		 cXMLCab += '   <Row ss:Height="33">' + CRLF
/* 01 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Chegada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Nro Lote</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Baia</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Operação</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Ent / Saída</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Vendedor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Origem/Estado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Corretor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Chegada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Compra</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Quebra</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">KM</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Hora Embarque</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 14 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Hora Chegada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 15 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Jejum</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 16 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Raça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 17 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Sexo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 18 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Era</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 19 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Tipo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 20 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cabeças NF</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 21 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Valor @</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 22 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Pagar</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 23 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Rend %</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 24 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Gado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 25 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Gado + Complemento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 26 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Frete</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 27 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Comissão</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 28 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ ICMS Frete</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 29 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ ICMS GADO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 30 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ TOTAL GADO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 31 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ CABECA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 32 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">ICMS x Cabeça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 33 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total @ Compra</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 34 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 35 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 36 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Fornec.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 37 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Loja Fornec.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 38 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Corretor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 39 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. BOV</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 40 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Qtd Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 41 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Pagto. Futuro</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 42 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Tp. Negoc.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 43 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Pedido Por</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 44 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Tem Premiacao</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 45 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Embarque</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 46 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Finalizado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 47 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Valor @</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

// /* 45 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Total ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 46 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Total Gado com ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 47 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total NF</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 48 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total NF Compl.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 49 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total NF Compl. ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 50 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Frete</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// /* 51 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total NF Frete ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
		 
	FWrite(nHandle, EncodeUTF8( cXMLCab ) )
	U_Unir2Arqs( nHandle, nHandAux, cPathBuff )
	
	//cXML := EncodeUTF8(cXMLCab) + cXMLDo
	//
	//If !Empty(cXML)
	//	// FWrite(nHandle, EncodeUTF8( cXMLCab + cXML ) )
	//	FWrite(nHandle, cXML )
	//EndIf
	cXML := ""	

	
EndIf

Return nTotQd2
// FIM: fQuadro2



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()               						  |
 | Func:  fQuadro3()                											  |
 | Autor: Miguel Martins Bernardo Junior                 						  |
 | Data:  18.05.2018                											  |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |        Processamento de dados Sinteticos;               						  |
 | Obs.:  -  																	  |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro3()	 // U_VACOMR07()

Local cWorkSheet 	:= "Notas Fiscais de Entrada"
Local cXMLCab 		:= "", cXML := "", cXMLDo:= ""
Local aDadTMP		:= {}
Local nTotQd3		:= 2
Local nHandAux 		:= 0, cPathBuff := cPath+'FileTMP.txt'

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	nHandAux := FCreate( cPathBuff )
	if nHandAux == -1
		Alert("Erro ao criar arquivo: " + cPathBuff + CRLF + Str(Ferror()))
		Return nil
	EndIf
	
	While !(_cAliasG)->(Eof())	 // U_VACOMR07()

		If  !(!Empty(aDadTMP) ;
			.and. aDadTMP[01] == (_cAliasG)->D1_FILIAL ;
			.and. aDadTmp[02] == (_cAliasG)->D1_DOC ;
			.and. aDadTmp[03] == (_cAliasG)->D1_SERIE ;
			.and. aDadTmp[04] == Iif( Empty((_cAliasG)->D1_EMISSAO), "", sToD( (_cAliasG)->D1_EMISSAO ) ) ;
			.and. aDadTmp[05] == (_cAliasG)->D1_FORNECE + (_cAliasG)->D1_LOJA ;
			.and. aDadTmp[06] == (_cAliasG)->A2_NOME ;
			.and. aDadTmp[07] == (_cAliasG)->D1_COD ;
			.and. aDadTmp[08] == (_cAliasG)->B1_DESC ;
			.and. aDadTmp[09] == (_cAliasG)->D1_QUANT  ;                     
			.and. aDadTmp[10] == (_cAliasG)->D1_TOTAL-(_cAliasG)->D1_VALICM ;
			.and. aDadTmp[11] == (_cAliasG)->D1_VALICM ;
			.and. aDadTmp[12] == (_cAliasG)->D1_TOTAL ;
			.and. aDadTmp[13] == (_cAliasG)->PESO_CHEGADA ;
			.and. aDadTmp[14] == Iif( Empty((_cAliasG)->DATA_EMBARQUE), "", sToD( (_cAliasG)->DATA_EMBARQUE ) ) ;
			.and. aDadTmp[15] == (_cAliasG)->HORA_EMBARQUE ;
			.and. aDadTmp[16] == Iif( Empty((_cAliasG)->DATA_CHEGADA), "", sToD( (_cAliasG)->DATA_CHEGADA ) ) ;
			.and. aDadTmp[17] == (_cAliasG)->HORA_CHEGADA ;
			.and. aDadTmp[18] == (_cAliasG)->KM_NF_ENTRADA ;
			.and. aDadTmp[19] == (_cAliasG)->NUMERO_LOTE )
	
			aDadTMP := { (_cAliasG)->D1_FILIAL, ;  
	/* 02 */		     (_cAliasG)->D1_DOC, ;
	/* 03 */		     (_cAliasG)->D1_SERIE, ;
	/* 04 */		     Iif( Empty((_cAliasG)->D1_EMISSAO), "", sToD( (_cAliasG)->D1_EMISSAO ) ), ;
	/* 05 */		     (_cAliasG)->D1_FORNECE + (_cAliasG)->D1_LOJA, ;
	/* 06 */		     (_cAliasG)->A2_NOME, ;
	/* 07 */		     (_cAliasG)->D1_COD, ;
	/* 08 */		     (_cAliasG)->B1_DESC, ;
	/* 09 */		     (_cAliasG)->D1_QUANT, ;
	/* 10 */		     (_cAliasG)->D1_TOTAL-(_cAliasG)->D1_VALICM, ;
	/* 11 */		     (_cAliasG)->D1_VALICM, ;
	/* 12 */		     (_cAliasG)->D1_TOTAL, ;
	/* 13 */		     (_cAliasG)->PESO_CHEGADA, ;
	/* 14 */		     Iif( Empty((_cAliasG)->DATA_EMBARQUE), "", sToD( (_cAliasG)->DATA_EMBARQUE ) ), ;
	/* 15 */		     (_cAliasG)->HORA_EMBARQUE, ;
	/* 16 */		     Iif( Empty((_cAliasG)->DATA_CHEGADA), "", sToD( (_cAliasG)->DATA_CHEGADA ) ), ;
	/* 17 */		     (_cAliasG)->HORA_CHEGADA, ;
	/* 18 */		     (_cAliasG)->KM_NF_ENTRADA, ;
	/* 19 */		     (_cAliasG)->NUMERO_LOTE }
		
			cXML += '<Row>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[01] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[02] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[03] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( aDadTMP[04] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[05] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[06] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[07] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[08] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[09] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[10] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[11] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[12] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[13] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( aDadTMP[14] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[15] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( aDadTMP[16] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[17] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[18] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[19] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			// cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=VLOOKUP(RC[-1],' + "'Custo Baia'" + '!R4C1:R65000C2,2,0)"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '</Row>' + CRLF
			nTotQd3 += 1
			
		EndIf
		
		// cXMLDo += EncodeUTF8(cXML)
		If !Empty( cXML )
			FWrite( nHandAux, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
		
		(_cAliasG)->(DbSkip())
	EndDo
	
	// Final da Planilha
	cXML += '</Table>' + CRLF
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <PageSetup>' + CRLF
	cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
	cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += '   </PageSetup>' + CRLF
	cXML += '   <Unsynced/>' + CRLF
	
	If MV_PAR16 == 1
		cXML += '  <Visible>SheetHidden</Visible> ' + CRLF
	EndIf
	
	cXML += '   <Selected/>' + CRLF
	cXML += '   <FreezePanes/>' + CRLF
	cXML += '   <FrozenNoSplit/>' + CRLF
	cXML += '   <SplitHorizontal>2</SplitHorizontal>' + CRLF
	cXML += '   <TopRowBottomPane>2</TopRowBottomPane>' + CRLF
	cXML += '   <ActivePane>2</ActivePane>' + CRLF
	cXML += '   <Panes>' + CRLF
	cXML += '   <Pane>' + CRLF
	cXML += '   	<Number>3</Number>' + CRLF
	cXML += '   </Pane>' + CRLF
	cXML += '   <Pane>' + CRLF
	cXML += '   <Number>2</Number>' + CRLF
	cXML += '   <ActiveRow>11</ActiveRow>' + CRLF
	cXML += '   <ActiveCol>3</ActiveCol>' + CRLF
	cXML += '   </Pane>' + CRLF
	cXML += '   </Panes>' + CRLF
	cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += '  </WorksheetOptions>' + CRLF
	cXML += '  <AutoFilter x:Range="R2C1:R' + AllTrim(Str( nTotQd3+3 )) + 'C19" xmlns="urn:schemas-microsoft-com:office:excel"></AutoFilter>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	// cXMLDo += EncodeUTF8(cXML)
	If !Empty( cXML )
		FWrite( nHandAux, EncodeUTF8( cXML ) )
	EndIf
	fClose(nHandAux)
	cXML := ""
	
		 // Inicio // fQuadro3 -> "Notas Fiscais de Entrada"
		 cXMLCab := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		 cXMLCab += ' <Names>'
		 cXMLCab += '   <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=' + "'Notas Fiscais de Entrada'" + '!R2C1:R' + AllTrim(Str( nTotQd3+3 )) + 'C19" ss:Hidden="1"/>'
		 cXMLCab += ' </Names>'
		 cXMLCab += '  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
		 cXMLCab += '     <Column ss:Width="25.125"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="53.625"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="25.875"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="55.5"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="76.125"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="215.625"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="82.125"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="75.75"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="33"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="61.875"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="49.5"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="61.875"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="66.375"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="63"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="63.375"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="56.625"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="57"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="69"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="69"/>' + CRLF
		 cXMLCab += ' <Row ss:Height="36">' + CRLF
		 cXMLCab += '     <Cell ss:MergeAcross="19" ss:StyleID="s62">' + CRLF
		 //cXMLCab += '       <Data ss:Type="String">' + cTitulo + " de " + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>
		 cXMLCab += '       <Data ss:Type="String">Relação de Notas Fiscais - Periodo de ' + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>
		 cXMLCab += '     </Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
		 cXMLCab += '   <Row ss:Height="33">' + CRLF
/* 01 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Documento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Serie</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Emissao</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cod Fornec/Loja</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Fornecedor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Prod.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Desc. Prod.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Quant.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ S/ ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Chegada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 14 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Embarque</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 15 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Hr. Embarque</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 16 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Chegada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 17 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Hr. Chegada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 18 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">KM NF Entrada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 19 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Nro Pedido (Lote Compra)</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '   </Row>
	
	
	FWrite(nHandle, EncodeUTF8( cXMLCab ) )
	U_Unir2Arqs( nHandle, nHandAux, cPathBuff )
	
	//cXML := EncodeUTF8(cXMLCab) + cXMLDo
	//
	//If !Empty(cXML)
	//	// FWrite(nHandle, EncodeUTF8( cXMLCab + cXML ) )
	//	FWrite(nHandle, cXML )
	//EndIf
	cXML := ""	

EndIf

Return nTotQd3
// FIM: fQuadro3


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()           	            	          |
 | Func:  fQuadro4()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  18.05.2018	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |        Processamento de dados Sinteticos;             	            	      |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro4()	 // U_VACOMR07()

Local cWorkSheet 	:= "Frete"
Local cXMLCab 		:= "", cXML := ""
Local aDadTMP		:= {}
Local nTotQd4		:= 3 // Total Linhas Geral
Local nHandAux 		:= 0, cPathBuff := cPath+'FileTMP.txt'

(_cAliasF)->(DbGoTop()) 
If !(_cAliasF)->(Eof())

	nHandAux := FCreate( cPathBuff )
	if nHandAux == -1
		Alert("Erro ao criar arquivo: " + cPathBuff + CRLF + Str(Ferror()))
		Return nil
	EndIf
	
	While !(_cAliasF)->(Eof())	 // U_VACOMR07()

 		aDadTMP:= { (_cAliasF)->D1_FILIAL, ;  
/* 02 */  		    (_cAliasF)->D1_DOC, ;
/* 03 */  		    (_cAliasF)->D1_SERIE, ;
/* 04 */  		    Iif( Empty((_cAliasF)->D1_EMISSAO), "", sToD( (_cAliasF)->D1_EMISSAO ) ), ;
/* 05 */  		    (_cAliasF)->D1_FORNECE + (_cAliasF)->D1_LOJA, ;
/* 06 */  		    (_cAliasF)->A2_NOME, ;
/* 07 */  		    (_cAliasF)->D1_COD, ;
/* 08 */  		    (_cAliasF)->B1_DESC, ;
/* 09 */  		    (_cAliasF)->D1_TOTAL-(_cAliasF)->D1_VALICM, ;
/* 10 */  		    (_cAliasF)->D1_VALICM, ;
/* 11 */  		    (_cAliasF)->D1_TOTAL }
		
		cXML += '<Row>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[01] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[02] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[03] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( aDadTMP[04] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[05] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[06] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[07] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[08] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[09] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[10] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[11] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '</Row>' + CRLF
		nTotQd4 += 1
		
		If !Empty( cXML )
			FWrite( nHandAux, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
		(_cAliasF)->(DbSkip())
	EndDo
	
	// Final da Planilha
	cXML += '</Table>' + CRLF
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <PageSetup>' + CRLF
	cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
	cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += '   </PageSetup>' + CRLF
	cXML += '   <Unsynced/>' + CRLF
	
	If MV_PAR16 == 1
		cXML += '  <Visible>SheetHidden</Visible> ' + CRLF
	EndIf
	
	cXML += '   <Selected/>' + CRLF
	cXML += '   <FreezePanes/>' + CRLF
	cXML += '   <FrozenNoSplit/>' + CRLF
	cXML += '   <SplitHorizontal>2</SplitHorizontal>' + CRLF
	cXML += '   <TopRowBottomPane>2</TopRowBottomPane>' + CRLF
	cXML += '   <ActivePane>2</ActivePane>' + CRLF
	cXML += '   <Panes>' + CRLF
	cXML += '   <Pane>' + CRLF
	cXML += '   	<Number>3</Number>' + CRLF
	cXML += '   </Pane>' + CRLF
	cXML += '   <Pane>' + CRLF
	cXML += '   <Number>2</Number>' + CRLF
	cXML += '   <ActiveRow>11</ActiveRow>' + CRLF
	cXML += '   <ActiveCol>3</ActiveCol>' + CRLF
	cXML += '   </Pane>' + CRLF
	cXML += '   </Panes>' + CRLF
	cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += '  </WorksheetOptions>' + CRLF
	cXML += '  <AutoFilter x:Range="R2C1:R' + AllTrim(Str( nTotQd4+3 )) + 'C11" xmlns="urn:schemas-microsoft-com:office:excel"></AutoFilter>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	If !Empty( cXML )
		FWrite( nHandAux, EncodeUTF8( cXML ) )
	EndIf
	fClose(nHandAux)
	cXML := ""
	
		 // Inicio // fQuadro4 -> "Frete"
		 cXMLCab := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		 cXMLCab += ' <Names>'
		 cXMLCab += '   <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=' + "'Frete'" + '!R2C1:R' + AllTrim(Str( nTotQd4+3 )) + 'C11" ss:Hidden="1"/>'
		 cXMLCab += ' </Names>'
		 cXMLCab += '  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
		 cXMLCab += '     <Column ss:Width="25.125"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="53.625"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="25.875"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="55.5"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="76.125"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="237.375"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="82.125"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="53.625"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="51.75"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="44.625"/>' + CRLF
		 cXMLCab += '     <Column ss:Width="49.5"/>		 ' + CRLF
		 cXMLCab += ' <Row ss:Height="36">' + CRLF
		 cXMLCab += '     <Cell ss:MergeAcross="10" ss:StyleID="s62">' + CRLF
		 // cXMLCab += '       <Data ss:Type="String">' + cTitulo + " de " + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>' + CRLF
		 cXMLCab += '       <Data ss:Type="String">Relação dos CTEs Vinculados com as Notas Fiscais - Periodo de ' + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>' + CRLF
		 cXMLCab += '     </Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
		 cXMLCab += '   <Row ss:Height="33">' + CRLF
/* 01 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Documento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Serie</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Emissao</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Cod Fornec/Loja</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Fornecedor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Prod.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Desc. Prod.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">R$ S/ ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">R$ ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
	
	FWrite(nHandle, EncodeUTF8( cXMLCab ) )
	U_Unir2Arqs( nHandle, nHandAux, cPathBuff )
	
	// If !Empty(cXML)
	// 	FWrite(nHandle, EncodeUTF8( cXMLCab + cXML ) )
	// EndIf
	cXML := ""	

EndIf

Return nil
// FIM: fQuadro4


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()           	            	          |
 | Func:  fQuadro5()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  18.05.2018	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |        Processamento de dados Sinteticos;             	            	      |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro5()	 // U_VACOMR07()

Local cWorkSheet 	:= "Complemento"
Local cXMLCab 		:= "", cXML := ""
Local aDadTMP		:= {}
Local nTotQd5		:= 3 // Total Linhas Geral
Local nHandAux 		:= 0, cPathBuff := cPath+'FileTMP.txt'

(_cAliasC)->(DbGoTop()) 
If !(_cAliasC)->(Eof())

	nHandAux := FCreate( cPathBuff )
	if nHandAux == -1
		Alert("Erro ao criar arquivo: " + cPathBuff + CRLF + Str(Ferror()))
		Return nil
	EndIf
	
	While !(_cAliasC)->(Eof())	 // U_VACOMR07()

 		aDadTMP := { (_cAliasC)->D1_FILIAL, ;  
/* 02 */			 (_cAliasC)->D1_DOC, ;
/* 03 */			 (_cAliasC)->D1_SERIE, ;
/* 04 */			 Iif( Empty((_cAliasC)->D1_EMISSAO), "", sToD( (_cAliasC)->D1_EMISSAO ) ), ;
/* 05 */			 (_cAliasC)->D1_FORNECE + (_cAliasC)->D1_LOJA, ;
/* 06 */			 (_cAliasC)->A2_NOME, ;
/* 07 */			 (_cAliasC)->D1_COD, ;
/* 08 */			 (_cAliasC)->B1_DESC, ;
/* 09 */			 (_cAliasC)->D1_VALICM, ;
/* 10 */			 (_cAliasC)->D1_TOTAL, ;
/* 11 */			 (_cAliasC)->TIPO_COMPLEMENTO } 
		
		cXML += '<Row>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[01] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[02] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[03] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( aDadTMP[04] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[05] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[06] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[07] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[08] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[09] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[10] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[11] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '</Row>' + CRLF
		nTotQd5 += 1
		
		If !Empty( cXML )
			FWrite( nHandAux, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
		
		(_cAliasC)->(DbSkip())
	EndDo
	
	// Final da Planilha
	cXML += '</Table>' + CRLF
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <PageSetup>' + CRLF
	cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
	cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += '   </PageSetup>' + CRLF
	cXML += '   <Unsynced/>' + CRLF
	
	If MV_PAR16 == 1
		cXML += '  <Visible>SheetHidden</Visible> ' + CRLF
	EndIf
	
	cXML += '   <Selected/>' + CRLF
	cXML += '   <FreezePanes/>' + CRLF
	cXML += '   <FrozenNoSplit/>' + CRLF
	cXML += '   <SplitHorizontal>2</SplitHorizontal>' + CRLF
	cXML += '   <TopRowBottomPane>2</TopRowBottomPane>' + CRLF
	cXML += '   <ActivePane>2</ActivePane>' + CRLF
	cXML += '   <Panes>' + CRLF
	cXML += '   <Pane>' + CRLF
	cXML += '   	<Number>3</Number>' + CRLF
	cXML += '   </Pane>' + CRLF
	cXML += '   <Pane>' + CRLF
	cXML += '   <Number>2</Number>' + CRLF
	cXML += '   <ActiveRow>11</ActiveRow>' + CRLF
	cXML += '   <ActiveCol>3</ActiveCol>' + CRLF
	cXML += '   </Pane>' + CRLF
	cXML += '   </Panes>' + CRLF
	cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += '  </WorksheetOptions>' + CRLF
	cXML += '  <AutoFilter x:Range="R2C1:R' + AllTrim(Str( nTotQd5+3 )) + 'C11" xmlns="urn:schemas-microsoft-com:office:excel"></AutoFilter>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	If !Empty( cXML )
		FWrite( nHandAux, EncodeUTF8( cXML ) )
	EndIf
	fClose(nHandAux)
	cXML := ""
	
		// Inicio // fQuadro5 -> "Complemento"
		 cXMLCab := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		 cXMLCab += ' <Names>'
		 cXMLCab += '   <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=' + "'Complemento'" + '!R2C1:R' + AllTrim(Str( nTotQd5+3 )) + 'C11" ss:Hidden="1"/>'
		 cXMLCab += ' </Names>'
		 cXMLCab += '  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
		 cXMLCab += '      <Column ss:Width="25.125"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="53.625"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="25.875"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="55.5"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="76.125"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="195"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="82.125"/>' + CRLF
		 cXMLCab += '      <Column ss:Width="53.625"/>		 ' + CRLF
		 cXMLCab += '      <Column ss:Width="53.625"/>		 ' + CRLF
		 cXMLCab += '      <Column ss:Width="53.625"/>		 ' + CRLF
		 cXMLCab += '      <Column ss:Width="80"/>		 ' + CRLF
		 cXMLCab += ' <Row ss:Height="36">' + CRLF
		 cXMLCab += '     <Cell ss:MergeAcross="9" ss:StyleID="s62">' + CRLF
		 // cXMLCab += '       <Data ss:Type="String">' + cTitulo + " de " + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>' + CRLF
		 cXMLCab += '       <Data ss:Type="String">Notas Fiscais Complementares - Periodo de ' + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>' + CRLF
		 cXMLCab += '     </Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
		 cXMLCab += '   <Row ss:Height="33">' + CRLF
/* 01 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Documento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Serie</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Emissao</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Cod Fornec/Loja</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Fornecedor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Prod.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Desc. Prod.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">R$ ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Tipo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
		 
	FWrite(nHandle, EncodeUTF8( cXMLCab ) )
	U_Unir2Arqs( nHandle, nHandAux, cPathBuff )

	// If !Empty(cXML)
	// 	FWrite(nHandle, EncodeUTF8( cXMLCab + cXML ) )
	// EndIf
	cXML := ""	

EndIf

Return nil
// FIM: fQuadro5


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:  fQuadro6()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  15.06.2018	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |        Processamento de dados Sinteticos;             	            	      |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro6()	 // U_VACOMR07()

Local cWorkSheet    := "Faixa"
Local cXMLCab 		:= "", cXML := ""
Local aDadTMP		:= {}
Local nTotQd6		:= 3 // Total Linhas Geral
Local nHandAux 		:= 0, cPathBuff := cPath+'FileTMP.txt'

(_cAliasX)->(DbGoTop()) 
If !(_cAliasX)->(Eof())

	nHandAux := FCreate( cPathBuff )
	if nHandAux == -1
		Alert("Erro ao criar arquivo: " + cPathBuff + CRLF + Str(Ferror()))
		Return nil
	EndIf
	
	While !(_cAliasX)->(Eof())	 // U_VACOMR07()

 		aDadTMP := { (_cAliasX)->FILIAL, ;  
/* 02 */			 (_cAliasX)->COD_CONTRATO, ;
/* 03 */			 (_cAliasX)->NUMERO_LOTE, ;
/* 04 */			 (_cAliasX)->FORNECEDOR, ;
/* 05 */			 (_cAliasX)->VENDEDOR, ;
/* 06 */			 (_cAliasX)->CODIGO_BOV, ;
/* 07 */			 (_cAliasX)->DESCRICAO, ;
/* 08 */			 (_cAliasX)->QTD_COMPRA, ;
/* 09 */			 (_cAliasX)->ZBC_FAIXA, ;
/* 10 */			 (_cAliasX)->ZFX_ITEM, ;
/* 11 */			 (_cAliasX)->ZFX_FXATE, ;
/* 12 */			 (_cAliasX)->ZFX_PREMIO }
		
		cXML += '<Row>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[01] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[02] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[03] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[04] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[05] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[06] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[07] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[08] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[09] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[10] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[11] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[12] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '</Row>' + CRLF
		nTotQd6 += 1
		
		If !Empty( cXML )
			FWrite( nHandAux, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
		(_cAliasX)->(DbSkip())
	EndDo
	
	// Final da Planilha
	cXML += '</Table>' + CRLF
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <PageSetup>' + CRLF
	cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
	cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += '   </PageSetup>' + CRLF
	cXML += '   <Unsynced/>' + CRLF
	
	If MV_PAR16 == 1
		cXML += '  <Visible>SheetHidden</Visible> ' + CRLF
	EndIf
	
	cXML += '   <Selected/>' + CRLF
	cXML += '   <FreezePanes/>' + CRLF
	cXML += '   <FrozenNoSplit/>' + CRLF
	cXML += '   <SplitHorizontal>2</SplitHorizontal>' + CRLF
	cXML += '   <TopRowBottomPane>2</TopRowBottomPane>' + CRLF
	cXML += '   <ActivePane>2</ActivePane>' + CRLF
	cXML += '   <Panes>' + CRLF
	cXML += '   <Pane>' + CRLF
	cXML += '   	<Number>3</Number>' + CRLF
	cXML += '   </Pane>' + CRLF
	cXML += '   <Pane>' + CRLF
	cXML += '   <Number>2</Number>' + CRLF
	cXML += '   <ActiveRow>11</ActiveRow>' + CRLF
	cXML += '   <ActiveCol>3</ActiveCol>' + CRLF
	cXML += '   </Pane>' + CRLF
	cXML += '   </Panes>' + CRLF
	cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += '  </WorksheetOptions>' + CRLF
	cXML += '  <AutoFilter x:Range="R2C1:R' + AllTrim(Str( nTotQd6+3 )) + 'C12" xmlns="urn:schemas-microsoft-com:office:excel"></AutoFilter>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	If !Empty( cXML )
		FWrite( nHandAux, EncodeUTF8( cXML ) )
	EndIf
	fClose(nHandAux)
	cXML := ""
	
		 // Inicio // fQuadro6 -> "Faixa"
		 cXMLCab := ' <Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		 cXMLCab += ' <Names>'
		 cXMLCab += '   <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=' + "'Faixa'" + '!R2C1:R' + AllTrim(Str( nTotQd6+3 )) + 'C12" ss:Hidden="1"/>'
		 cXMLCab += ' </Names>'
		 cXMLCab += '  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
		 cXMLCab += ' <Row ss:Height="36">' + CRLF
		 cXMLCab += '     <Cell ss:MergeAcross="11" ss:StyleID="s62">' + CRLF
		 // cXMLCab += '       <Data ss:Type="String">' + cTitulo + " de " + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>' + CRLF
		 cXMLCab += '       <Data ss:Type="String">Faixas - Periodo de ' + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>' + CRLF
		 cXMLCab += '     </Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
		 cXMLCab += '   <Row ss:Height="33">' + CRLF
/* 01 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Lote</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Fornecedor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Fornecedor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Prod.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Desc. Prod.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Qtd. Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Faixa</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Item Faixa</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXMLCab += '      <Cell ss:Style ID="s65"><Data ss:Type="String">Faixa Ate</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */ cXMLCab += '      <Cell ss:StyleID="s65"><Data ss:Type="String">Premio</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
	
	FWrite(nHandle, EncodeUTF8( cXMLCab ) )
	U_Unir2Arqs( nHandle, nHandAux, cPathBuff )
	
	// If !Empty(cXML)
	// 	FWrite(nHandle, EncodeUTF8( cXMLCab + cXML ) )
	// EndIf
	cXML := ""	

EndIf

Return nTotQd6
// FIM: fQuadro6

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:  fQuadro7()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  26.06.2018	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |        Processamento de dados Sinteticos;             	            	      |
 | Obs.:  -	            	            										  |
 '-------------------------------------------------------------------------------*/
Static Function fQuadro7( nTotQd2 )	 // U_VACOMR07()

Local cWorkSheet    := "Custo Lt Compra"
Local cXMLCab 		:= "", cXML := "", cXMLDo:= ""
Local cLote 		:= ""
Local nQuant		:= 0
Local nPeso			:= 0
Local aMatriz		:= {}
Local aMatQtd		:= {}, nPQtd := 0, nAux := 0
Local nHandAux 		:= 0, cPathBuff := cPath+'FileTMP.txt'

(_cAliasA)->(DbGoTop()) 
If !(_cAliasA)->(Eof())

	nHandAux := FCreate( cPathBuff )
	if nHandAux == -1
		Alert("Erro ao criar arquivo: " + cPathBuff + CRLF + Str(Ferror()))
		Return nil
	EndIf
	
	While !(_cAliasQ)->(Eof())
		aAdd( aMatQtd, { (_cAliasQ)->NUMERO_LOTE, ; 
				/* 02 */ (_cAliasQ)->ZBC_COMPRA, ;
				/* 03 */ (_cAliasQ)->SALDO_B8, ;
				/* 04 */ (_cAliasQ)->FATURADO, ;
				/* 05 */ (_cAliasQ)->MORTE, ;
				/* 06 */ (_cAliasQ)->NASCIMENTO, ;
				/* 07 */ (_cAliasQ)->DIFERE } )
		(_cAliasQ)->(DbSkip())
	EndDo
	
	While !(_cAliasA)->(Eof())	 // U_VACOMR07()
		aAdd( aMatriz, { (_cAliasA)->NUMERO_LOTE, (_cAliasA)->QUANT, (_cAliasA)->PESO_TOTAL } )
		(_cAliasA)->(DbSkip())
	EndDo
	aSort( aMatriz ,,, {|x,y| x[1] < y[1] } )
	
	nI := 1
	While nI <= Len( aMatriz )
		
		cLote   := aMatriz[ nI, 01 ] // (_cAliasA)->NUMERO_LOTE
		nQuant  += aMatriz[ nI, 02 ] // (_cAliasA)->QUANT
		nPeso 	+= aMatriz[ nI, 03 ] // (_cAliasA)->PESO_TOTAL
		
		nPQtd 	:= aScan( aMatQtd , { |x| AllTrim(x[1]) == AllTrim(cLote) } )
		
		// Imprimir uma linha por Lote Compra + LoteCTL
		// if (_cAliasA)->(Eof()) .or. cLote <> (_cAliasA)->NUMERO_LOTE
		if nI+1 > Len( aMatriz ) .or. cLote <> aMatriz[ nI+1, 01 ] // (_cAliasA)->NUMERO_LOTE
		
			cLote := aMatriz[ nI, 01 ] // (_cAliasA)->NUMERO_LOTE
		
    		cXML += ' <Row>' + CRLF
			// Lote Compra
   /* 01 */ cXML += '   <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( cLote ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

			cXML += '   <Cell ss:StyleID="sTexto" ss:Formula="=VLOOKUP(RC[-1],' + "'Lotes - Sintetico'" + '!R4C2:R' + AllTrim(Str(nTotQd2)) + 'C7,5,FALSE)"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '   <Cell ss:StyleID="sTexto" ss:Formula="=VLOOKUP(RC[-2],' + "'Lotes - Sintetico'" + '!R4C2:R' + AllTrim(Str(nTotQd2)) + 'C8,6,FALSE)"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '   <Cell ss:StyleID="sTexto" ss:Formula="=VLOOKUP(RC[-3],' + "'Lotes - Sintetico'" + '!R4C2:R' + AllTrim(Str(nTotQd2)) + 'C8,7,FALSE)"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	  
			// Cabeças Compradas
   /* 02 */ cXML += '   <Cell ss:StyleID="sSemDig" ss:Formula="=SUMIF(' + "'Lotes - Sintetico'" + '!R3C[-3]:R' + AllTrim(Str(Len( aMatriz ))) + 'C[-3],RC[-4],' + "'Lotes - Sintetico'" + '!R3C[15]:R' + AllTrim(Str(Len( aMatriz ))) + 'C[15])"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   
			// Total Movimentado
   /* 03 */ cXML += '   <Cell ss:StyleID="sSemDig" ss:Formula="=SUM(RC[1]:RC[5])"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			
			// Saldo em Estoque
			nAux := 0
			If nPQtd > 0
				nAux := aMatQtd[ nPQtd, 03 ] // SALDO_B8
			EndIf
   /* 04 */ cXML += '   <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( nAux ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			
			// Faturado
			nAux := 0
			If nPQtd > 0
				nAux := aMatQtd[ nPQtd, 04 ] // FATURADO
			EndIf
   /* 05 */ cXML += '   <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( nAux ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			
			// Mortes
			nAux := 0
			If nPQtd > 0
				nAux := aMatQtd[ nPQtd, 05 ] // MORTE
			EndIf
   /* 06 */ cXML += '   <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( nAux ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			
			// Nascimentos
			nAux := 0
			If nPQtd > 0
				nAux := aMatQtd[ nPQtd, 06 ] // NASCIMENTO
			EndIf
   /* 07 */ cXML += '   <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( nAux ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			
			// Outras Movim.
			nAux := 0
			If nPQtd > 0
				nAux := aMatQtd[ nPQtd, 07 ] // DIFERE
			EndIf
   /* 08 */ cXML += '   <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( nAux ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			
   // /* 09 */ cXML += '   <Cell ss:StyleID="sRealFundoVerdeClaro" ss:Formula="=SUMIF(' + "'Lotes - Sintetico'" + '!R3C[-7]:R' + AllTrim(Str(nTotQd2)) + 'C[-7],' + "'Custo Lt Compra'" + '!RC1,'    + "'Lotes - Sintetico'" + '!R3C[16]:R' + AllTrim(Str(nTotQd2)) + 'C[16])+SUMIF(' + "'Lotes - Sintetico'" + '!R3C[-7]:R' + AllTrim(Str(nTotQd2)) + 'C[-7],' + "'Custo Lt Compra'" + '!RC1,' + "'Lotes - Sintetico'" + '!R3C[17]:R' + AllTrim(Str(nTotQd2)) + 'C[17])+SUMIF(' + "'Lotes - Sintetico'" + '!R3C[-7]:R' + AllTrim(Str(nTotQd2)) + 'C[-7],' + "'Custo Lt Compra'" + '!RC1,' + "'Lotes - Sintetico'" + '!R3C[18]:R' + AllTrim(Str(nTotQd2)) + 'C[18])"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 09 */ cXML += '   <Cell ss:StyleID="sRealFundoVerdeClaro" ss:Formula="=IF(AND(RC[10]=&quot;SIM&quot;,RC[11]=&quot;NAO&quot;),RC[12]*(SUMIF(' + "'Lotes - Sintetico'" + '!R3C[-10]:R' + AllTrim(Str(nTotQd2)) + 'C[-2],' + "'Custo Lt Compra'" + '!RC[-11],' + "'Lotes - Sintetico'" + '!R3C[-2]:R' + AllTrim(Str(nTotQd2)) + 'C[-2])/30)+SUMIF(' + "'Lotes - Sintetico'" + '!R3C[-10]:R' + AllTrim(Str(nTotQd2)) + 'C[-10],' + "'Custo Lt Compra'" + '!RC1,' + "'Lotes - Sintetico'" + '!R3C[14]:R' + AllTrim(Str(nTotQd2)) + 'C[14])+SUMIF(' + "'Lotes - Sintetico'" + '!R3C[-10]:R' + AllTrim(Str(nTotQd2)) + 'C[-10],' + "'Custo Lt Compra'" + '!RC1,' + "'Lotes - Sintetico'" + '!R3C[15]:R' + AllTrim(Str(nTotQd2)) + 'C[15]),SUMIF(' + "'Lotes - Sintetico'" + '!R3C[-10]:R' + AllTrim(Str(nTotQd2)) + 'C[-10],' + "'Custo Lt Compra'" + '!RC1,' + "'Lotes - Sintetico'" + '!R3C[13]:R' + AllTrim(Str(nTotQd2)) + 'C[13])+SUMIF(' + "'Lotes - Sintetico'" + '!R3C[-10]:R' + AllTrim(Str(nTotQd2)) + 'C[-10],' + "'Custo Lt Compra'" + '!RC1,' + "'Lotes - Sintetico'" + '!R3C[14]:R' + AllTrim(Str(nTotQd2)) + 'C[14])+SUMIF(' + "'Lotes - Sintetico'" + '!R3C[-10]:R' + AllTrim(Str(nTotQd2)) + 'C[-10],' + "'Custo Lt Compra'" + '!RC1,' + "'Lotes - Sintetico'" + '!R3C[15]:R' + AllTrim(Str(nTotQd2)) + 'C[15]))"><Data ss:Type="Number">19695.5</Data><NamedCell ss:Name="_FilterDatabase"/></Cell> ' + CRLF 
   /* 10 */ cXML += '   <Cell ss:StyleID="sRealFundoAmareloClaro" ss:Formula="=SUMIF(' + "'Lotes - Sintetico'" + '!R3C2:R' + AllTrim(Str(nTotQd2)) + 'C2,' + "'Custo Lt Compra'" + '!RC[-12],' + "'Lotes - Sintetico'" + '!R3C28:R' + AllTrim(Str(nTotQd2)) + 'C28)+SUMIF(' + "'Lotes - Sintetico'" + '!R4C2:R' + AllTrim(Str(nTotQd2)) + 'C2,' + "'Custo Lt Compra'" + '!RC[-12],' + "'Lotes - Sintetico'" + '!R4C29:R' + AllTrim(Str(nTotQd2)) + 'C29)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 11 */ cXML += '   <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( nPeso ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 12 */ cXML += '   <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[-3]/RC[-1],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 13 */ cXML += '   <Cell ss:StyleID="sReal" ss:Formula="=RC[-1]*30"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '   <Cell ss:StyleID="sReal" ss:Formula="=IFERROR((RC[-5]+RC[-4])/RC[-3],0)*30"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 14 */ cXML += '   <Cell ss:StyleID="sComDig" ss:Formula="=IFERROR(RC[-4]/RC[-12],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF   
   
   /* 15 */ cXML += '   <Cell ss:StyleID="sComDig" ss:Formula="=SUMIF(' + "'Lotes - Sintetico'" + '!R3C[-17]:R' + AllTrim(Str(nTotQd2)) + 'C[-17],RC[-18],' + "'Lotes - Sintetico'" + '!R3C[-9]:R' + AllTrim(Str(nTotQd2)) + 'C[-9])"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 16 */ cXML += '   <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC12/RC[-1],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 17 */ cXML += '   <Cell ss:StyleID="sReal" ss:Formula="=RC[-1]*30"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   
   /* 18 */ cXML += '   <Cell ss:StyleID="sTexto" ss:Formula="=VLOOKUP(RC[-21],' + "'Lotes - Sintetico'" + '!R4C2:R' + AllTrim(Str(nTotQd2)) + 'C41,40,FALSE)"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 19 */ cXML += '   <Cell ss:StyleID="sTexto" ss:Formula="=IFERROR(VLOOKUP(RC[-22],' + "'Lotes - Sintetico'" + '!R4C2:R' + AllTrim(Str(nTotQd2)) + 'C46,45,FALSE),&quot;&quot;)"><Data ss:Type="String"></Data></Cell>' + CRLF
   /* 20 */ cXML += '   <Cell ss:StyleID="sReal"  ss:Formula="=IFERROR(VLOOKUP(' + "'Custo Lt Compra'" + '!RC[-23],' + "'Lotes - Sintetico'" + '!R4C2:R' + AllTrim(Str(nTotQd2)) + 'C47,46,FALSE),0)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXML += ' </Row>' + CRLF
			
			nQuant  := 0
			nPeso	:= 0
		EndIf
		
		nI += 1 // (_cAliasA)->(DbSkip())
		
		// cXMLDo += EncodeUTF8(cXML)
		If !Empty( cXML )
			FWrite( nHandAux, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
		
	EndDo
	
	// Final da Planilha
	cXML += '</Table>' + CRLF
	cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += ' <PageSetup>' + CRLF
	cXML += ' 	<Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 	<Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 	<PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += ' </PageSetup>' + CRLF
	cXML += ' <Unsynced/>' + CRLF
	cXML += ' <TabColorIndex>13</TabColorIndex>' + CRLF
	cXML += ' <FreezePanes/>' + CRLF
	cXML += ' <FrozenNoSplit/>' + CRLF
	cXML += ' <SplitHorizontal>3</SplitHorizontal>' + CRLF
	cXML += ' <TopRowBottomPane>3</TopRowBottomPane>' + CRLF
	cXML += ' <SplitVertical>1</SplitVertical>' + CRLF
	cXML += ' <LeftColumnRightPane>1</LeftColumnRightPane>' + CRLF
	cXML += ' <ActivePane>0</ActivePane>' + CRLF
	cXML += ' <Panes>' + CRLF
	cXML += ' 	<Pane>' + CRLF
	cXML += ' 		<Number>3</Number>' + CRLF
	cXML += ' 	</Pane>' + CRLF
	cXML += ' 	<Pane>' + CRLF
	cXML += ' 		<Number>1</Number>' + CRLF
	cXML += ' 	</Pane>' + CRLF
	cXML += ' 	<Pane>' + CRLF
	cXML += ' 		<Number>2</Number>' + CRLF
	cXML += ' 	</Pane>' + CRLF
	cXML += ' 	<Pane>' + CRLF
	cXML += ' 		<Number>0</Number>' + CRLF
	cXML += ' 		<ActiveRow>21</ActiveRow>' + CRLF
	cXML += ' 		<ActiveCol>4</ActiveCol>' + CRLF
	cXML += ' 		<RangeSelection>R22C4:R22C5</RangeSelection>' + CRLF
	cXML += ' 	</Pane>' + CRLF
	cXML += ' </Panes>' + CRLF
	cXML += ' <ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += ' <ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += ' </WorksheetOptions>' + CRLF
	cXML += ' <AutoFilter x:Range="R3C1:R' + AllTrim(Str(Len( aMatriz )+3)) + 'C24" xmlns="urn:schemas-microsoft-com:office:excel"></AutoFilter>' + CRLF
	cXML += ' <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += ' 	<Range>R4C19:R' + AllTrim(Str(Len( aMatriz )+3)) + 'C19,C18</Range>' + CRLF
	cXML += ' 	<Condition>' + CRLF
	cXML += ' 		<Qualifier>Equal</Qualifier>' + CRLF
	cXML += ' 		<Value1>&quot;&quot;&quot;SIM&quot;&quot;&quot;</Value1>' + CRLF
	cXML += " 		<Format Style='font-weight:700;background:#DDEBF7'/>" + CRLF
	cXML += ' 	</Condition>' + CRLF
	cXML += ' </ConditionalFormatting>' + CRLF
	cXML += ' <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += ' 	<Range>R4C18:R' + AllTrim(Str(Len( aMatriz )+3)) + 'C19</Range>' + CRLF
	cXML += ' 	<Condition>' + CRLF
	cXML += ' 		<Qualifier>Equal</Qualifier>' + CRLF
	cXML += ' 		<Value1>&quot;SIM&quot;</Value1>' + CRLF
	cXML += " 		<Format Style='background:#A9D08E'/>" + CRLF
	cXML += ' 	</Condition>' + CRLF
	cXML += ' 	<Condition>' + CRLF
	cXML += ' 		<Value1>NOT(ISERROR(SEARCH(&quot;&quot;&quot;SIM&quot;&quot;&quot;,RC)))</Value1>' + CRLF
	cXML += " 		<Format Style='background:#BDD7EE'/>" + CRLF
	cXML += ' 	</Condition>' + CRLF
	cXML += ' </ConditionalFormatting>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	// cXMLDo += EncodeUTF8(cXML)
	If !Empty( cXML )
		FWrite( nHandAux, EncodeUTF8( cXML ) )
	EndIf
	fClose(nHandAux)
	cXML := ""
	
		 // Inicio // fQuadro7 -> "Custo Lt Compra"
		 cXMLCab := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		 cXMLCab += ' <Names>'
		 cXMLCab += '   <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=' + "'Custo Lt Compra'" + '!R3C1:R' + AllTrim(Str(Len( aMatriz )+3)) + 'C24" ss:Hidden="1"/>'
		 cXMLCab += ' </Names>'
		 cXMLCab += '  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
		 cXMLCab += '     <Column ss:Width="87.75"/>' + CRLF
		 cXMLCab += '     <Column ss:AutoFitWidth="0" ss:Width="198.75"/>' + CRLF
		 cXMLCab += '     <Column ss:AutoFitWidth="0" ss:Width="87.75" ss:Span="1"/>' + CRLF
		 cXMLCab += '     <Column ss:Index="5" ss:AutoFitWidth="0" ss:Width="63" ss:Span="6"/>' + CRLF
		 cXMLCab += '     <Column ss:Index="12" ss:AutoFitWidth="0" ss:Width="81" ss:Span="9"/>' + CRLF
		 cXMLCab += '     <Column ss:Index="22" ss:AutoFitWidth="0" ss:Width="57.75" ss:Span="1"/>' + CRLF
		 cXMLCab += '     <Column ss:Index="24" ss:AutoFitWidth="0" ss:Width="68.25"/>' + CRLF
		 cXMLCab += ' <Row ss:Height="36">' + CRLF
		 cXMLCab += '     <Cell ss:MergeAcross="23" ss:StyleID="s62">' + CRLF
		 // cXMLCab += '       <Data ss:Type="String">' + cTitulo + " de " + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>' + CRLF
		 cXMLCab += '       <Data ss:Type="String">Formação dos Custos dos Lotes de Compras</Data>' + CRLF
		 cXMLCab += '     </Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
		 cXMLCab += '   <Row ss:AutoFitHeight="0">' + CRLF
		 cXMLCab += '      <Cell ss:Index="11" ss:MergeAcross="3" ss:StyleID="s98"><Data ss:Type="String">Apartação</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '      <Cell               ss:MergeAcross="3" ss:StyleID="s100"><Data ss:Type="String">Compra</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
		 cXMLCab += '   <Row ss:Height="33">' + CRLF
/* 01 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Lote Compra</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 01 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Vendedor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 01 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Origem/Estado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 01 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Corretor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Cabeças Compradas</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Total Movimentado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Saldo em Estoque</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Faturado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Mortes</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Nascimentos</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Outras Movimentações</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">R$ Total Compra S/ ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Total ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Peso Kg Apartação</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">R$ / Kg</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">R$ / @</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">R$ / @ COM ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Peso x Cabeça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 14 */ cXMLCab += '      <Cell ss:StyleID="s101"><Data ss:Type="String">Peso Kg Compra</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 15 */ cXMLCab += '      <Cell ss:StyleID="s101"><Data ss:Type="String">R$ / Kg</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 16 */ cXMLCab += '      <Cell ss:StyleID="s101"><Data ss:Type="String">R$ / @</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 17 */ cXMLCab += '      <Cell ss:StyleID="s101"><Data ss:Type="String">Pagamento Futuro</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 18 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Fechamento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 19 */ cXMLCab += '      <Cell ss:StyleID="s99" ><Data ss:Type="String">Valor @ Estimado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
	
	FWrite(nHandle, EncodeUTF8( cXMLCab ) )
	U_Unir2Arqs( nHandle, nHandAux, cPathBuff )
	
	//cXML := EncodeUTF8(cXMLCab) + cXMLDo
	//
	//If !Empty(cXML)
	//	// FWrite(nHandle, EncodeUTF8( cXMLCab + cXML ) )
	//	FWrite(nHandle, cXML )
	//EndIf
	cXML := ""	

EndIf

Return Len( aMatriz )
// FIM: fQuadro7


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()               						  |
 | Func:  fQuadro8()                											  |
 | Autor: Miguel Martins Bernardo Junior                   						  |
 | Data:  26.06.2018                											  |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |        Processamento de dados Sinteticos;               						  |
 | Obs.:  -  																	  |
 '-------------------------------------------------------------------------------*/
Static Function fQuadro8( n10fTotQd, nTotQd7, aDadDro8 )	 // U_VACOMR07()

Local cWorkSheet    := "Custo Baia"
Local cXMLCab 		:= "", cXML := "", cXMLDo:= ""
Local aDadTMP		:= {}
Local cChave		:= "", cLote := ""
Local nQuant		:= 0
Local nPeso			:= 0
Local nTLinGrp		:= 0 // Total Linhas Grupo
Local nTotQd8		:= 3 // Total Linhas Geral
Local nHandAux 		:= 0, cPathBuff := cPath+'FileTMP.txt'

(_cAliasA)->(DbGoTop()) 
If !(_cAliasA)->(Eof())

	nHandAux := FCreate( cPathBuff )
	if nHandAux == -1
		Alert("Erro ao criar arquivo: " + cPathBuff + CRLF + Str(Ferror()))
		Return nil
	EndIf
	
	While !(_cAliasA)->(Eof())	 // U_VACOMR07()
		
		cLote   := (_cAliasA)->B8_LOTECTL
		cChave  := (_cAliasA)->NUMERO_LOTE+cLote 
		nQuant  += (_cAliasA)->QUANT
		nPeso 	+= (_cAliasA)->PESO_TOTAL
		
 		aDadTMP := { (_cAliasA)->NUMERO_LOTE, ;  
/* 02 */			 (_cAliasA)->B8_LOTECTL , ;
/* 03 */			 (_cAliasA)->RACA, ;
/* 04 */			 (_cAliasA)->SEXO,;
/* 05 */			 (_cAliasA)->B8_XDATACO,;
/* 06 */			 (_cAliasA)->B8_XPESOCO }
		
		aAdd( aDadDro8, aDadTMP )
		
		(_cAliasA)->(DbSkip())
		
		// Imprimir uma linha por Lote Compra + LoteCTL
		if (_cAliasA)->(Eof()) .or. cChave <> (_cAliasA)->NUMERO_LOTE+(_cAliasA)->B8_LOTECTL
		
			cChave := (_cAliasA)->NUMERO_LOTE+(_cAliasA)->B8_LOTECTL
		
    		cXML += '<Row>' + CRLF
   /* 01 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[01] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 02 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[02] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 03 */ cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( nQuant      ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 04 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( nPeso	     ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 05 */ cXML += '  <Cell ss:StyleID="sComDig" ss:Formula="=IFERROR(RC[-1]/RC[-2],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 06 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IF(RC[-5]=&quot;SEM CONTRATO&quot;,RC[1]/RC[-2],SUMIF(' + "'Custo Lt Compra'" + '!R4C[-5]:R'+cValToChar(nTotQd7)+'C[-5],RC[-5],' + "'Custo Lt Compra'" + '!R4C[9]:R'+cValToChar(nTotQd7)+'C[9]))"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 07 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IF(RC[-6]=&quot;SEM CONTRATO&quot;,SUMIF(' + "'Compras - Genericos'" + '!R4C[-6]:R'+cValToChar(n10fTotQd)+'C[-6],CONCATENATE(' + "'Custo Baia'" + '!RC[8],' + "'Custo Baia'" + '!RC[9]),' + "'Compras - Genericos'" + '!R4C[5]:R'+cValToChar(n10fTotQd)+'C[5])/SUMIF(' + "'Compras - Genericos'" + '!R4C[-6]:R'+cValToChar(n10fTotQd)+'C[-6],CONCATENATE(' + "'Custo Baia'" + '!RC[8],' + "'Custo Baia'" + '!RC[9]),' + "'Compras - Genericos'" + '!R4C[-2]:R'+cValToChar(n10fTotQd)+'C[-2])*RC[-4],IFERROR(RC[-3]*RC[-1],0))"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 08 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[-1]/RC[-5],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 09 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IF(RC[-8]=&quot;SEM CONTRATO&quot;,VLOOKUP(CONCATENATE(' + "'Custo Baia'" + '!RC[6],' + "'Custo Baia'" + '!RC[7]),' + "'Compras - Genericos'" + '!R4C[-8]:R'+cValToChar(n10fTotQd)+'C[5],14,FALSE)*RC[-6],IFERROR(VLOOKUP(RC1,' + "'Custo Lt Compra'" + '!R3C1:R'+cValToChar(nTotQd7)+'C[4],13,FALSE)/VLOOKUP(RC1,' + "'Custo Lt Compra'" + '!R3C1:R'+cValToChar(nTotQd7)+'C14,14,FALSE)*RC4,0))"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 10 */ cXML += '  <Cell ss:StyleID="sComDig" ss:Formula="=IFERROR((SUMIF(' + "'Lotes - Sintetico'" + '!R3C[-8]:R' + AllTrim(Str(Len(_aDados)+3)) + 'C[-8],RC[-9],' + "'Lotes - Sintetico'" + '!R3C[-1]:R' + AllTrim(Str(Len(_aDados)+3)) + 'C[-1])/VLOOKUP(RC[-9],' + "'Custo Lt Compra'" + '!R4C1:R' + AllTrim(Str( nTotQd7 )) + 'C3,3,FALSE))*RC[-7],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
   /* 11 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(SUMIF(' + "'Custo Lt Compra'" + '!R4C[-10]:R' + AllTrim(Str( nTotQd7 )) + 'C[-9],RC[-10],'+ "'Custo Lt Compra'"+ '!R4C[1]:R' + AllTrim(Str( nTotQd7 )) + 'C[1]),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 12 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[-2]*RC[-1],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 13 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[-1]/RC[-10],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF   
   /* 14 */	cXML += '  <Cell ss:Formula="=RC[-13]"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell> ' + CRLF
   /* 15 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[03] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 16 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( aDadTMP[04] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 17 */ cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sTod( aDadTMP[05]) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 18 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aDadTMP[06] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   		    cXML += '</Row>' + CRLF
			
			nQuant   := 0
			nPeso	 := 0
			nTLinGrp += 1
			nTotQd8  += 1
		EndIf
		
		// S O M A
		if (_cAliasA)->(Eof()) .or. cLote <> (_cAliasA)->B8_LOTECTL
			cXML += '<Row>' + CRLF
   /* 01 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">Total Baia</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 02 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 03 */ cXML += '  <Cell ss:StyleID="sSemDig" ss:Formula="=SUM(R[-' + AllTrim(Str( nTLinGrp )) + ']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 04 */ cXML += '  <Cell ss:StyleID="sComDig" ss:Formula="=SUM(R[-' + AllTrim(Str( nTLinGrp )) + ']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 05 */ cXML += '  <Cell ss:StyleID="sComDig" ss:Formula="=AVERAGE(R[-' + AllTrim(Str( nTLinGrp )) + ']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 06 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[1]/RC[-2],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 07 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(SUM(R[-' + AllTrim(Str( nTLinGrp )) + ']C:R[-1]C),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 08 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=RC[-1]/RC[-5]"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF 
   /* 09 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=SUM(R[-' + AllTrim(Str( nTLinGrp )) + ']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 10 */ cXML += '  <Cell ss:StyleID="sComDig" ss:Formula="=SUM(R[-' + AllTrim(Str( nTLinGrp )) + ']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 11 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[1]/RC[-1],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 12 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=SUM(R[-' + AllTrim(Str( nTLinGrp )) + ']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   /* 13 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[-1]/RC[-10],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
   			cXML += '</Row>' + CRLF
			nTotQd8 += 1
			cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
			nTotQd8 += 1
			
			nTLinGrp := 0
		EndIf
		
		// cXMLDo += EncodeUTF8(cXML)
		If !Empty( cXML )
			FWrite( nHandAux, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
		
	EndDo
	
		 cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
		 nTotQd8 += 1
	     cXML += '<Row> ss:Height="35"' + CRLF
/* 01 */ cXML += '  <Cell ss:StyleID="sTextoN"><Data ss:Type="String">TOTAL GERAL</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */ cXML += '  <Cell ss:StyleID="sTextoN"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXML += '  <Cell ss:StyleID="sSemDigN" ss:Formula="=SUMIF(R4C[-2]:R[-1]C[-2],&quot;Total Baia&quot;,R4C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ cXML += '  <Cell ss:StyleID="sComDigN" ss:Formula="=SUMIF(R4C[-3]:R[-1]C[-3],&quot;Total Baia&quot;,R4C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ cXML += '  <Cell ss:StyleID="sRealN" ss:Formula="=IFERROR(AVERAGEIF(R4C[-4]:R[-1]C[-4],&quot;Total Baia&quot;,R4C:R[-1]C),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXML += '  <Cell ss:StyleID="sRealN" ss:Formula="=IFERROR(AVERAGEIF(R4C[-5]:R[-1]C[-5],&quot;Total Baia&quot;,R4C:R[-1]C),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ cXML += '  <Cell ss:StyleID="sRealN" ss:Formula="=IFERROR(AVERAGEIF(R4C[-6]:R[-1]C[-6],&quot;Total Baia&quot;,R4C:R[-1]C),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXML += '  <Cell ss:StyleID="sRealN" ss:Formula="=IFERROR(RC[-1]/RC[-5],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXML += '  <Cell ss:StyleID="sRealN" ss:Formula="=SUMIF(R3C1:R[-1]C1,&quot;Total Baia&quot;,R3C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXML += '  <Cell ss:StyleID="sComDigN" ss:Formula="=SUMIF(R4C1:R[-1]C1,&quot;Total Baia&quot;,R4C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXML += '  <Cell ss:StyleID="sRealN" ss:Formula="=IFERROR(AVERAGEIF(R4C1:R[-1]C1,&quot;Total Baia&quot;,R4C:R[-1]C),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */ cXML += '  <Cell ss:StyleID="sRealN" ss:Formula="=IFERROR(RC[-2]*RC[-1],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */ cXML += '  <Cell ss:StyleID="sRealN" ss:Formula="=IFERROR(RC[-1]/RC[-8],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXML += '</Row>' + CRLF
		
		// cXMLDo += EncodeUTF8(cXML)
		If !Empty( cXML )
			FWrite( nHandAux, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
		
	
	// Final da Planilha
	cXML += '</Table>' + CRLF
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <PageSetup>' + CRLF
	cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
	cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += '   </PageSetup>' + CRLF
	cXML += '   <Unsynced/>' + CRLF
	cXML += '   <TabColorIndex>13</TabColorIndex>' + CRLF
	cXML += '   <Selected/>' + CRLF
	cXML += '   <FreezePanes/>' + CRLF
	cXML += '   <FrozenNoSplit/>' + CRLF
	cXML += '   <SplitHorizontal>3</SplitHorizontal>' + CRLF
	cXML += '   <TopRowBottomPane>3</TopRowBottomPane>' + CRLF
	cXML += '   <ActivePane>2</ActivePane>' + CRLF
	cXML += '   <Panes>' + CRLF
	cXML += '   <Pane>' + CRLF
	cXML += '   	<Number>3</Number>' + CRLF
	cXML += '   </Pane>' + CRLF
	cXML += '   <Pane>' + CRLF
	cXML += '   	<Number>2</Number>' + CRLF
	cXML += '   <ActiveRow>4</ActiveRow>' + CRLF
	cXML += '   </Pane>' + CRLF
	cXML += '   </Panes>' + CRLF
	cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += '  </WorksheetOptions>' + CRLF
	cXML += '  <AutoFilter x:Range="R3C1:R' + AllTrim(Str(nTotQd8+3)) + 'C18" xmlns="urn:schemas-microsoft-com:office:excel"></AutoFilter>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	// cXMLDo += EncodeUTF8(cXML)
	If !Empty( cXML )
		FWrite( nHandAux, EncodeUTF8( cXML ) )
	EndIf
	fClose(nHandAux)
	cXML := ""
		
		 // Inicio // fQuadro8 -> "Custo Baia"
		 cXMLCab := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		 cXMLCab += ' <Names>' + CRLF
		 cXMLCab += ' 		<NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=' + "'Custo Baia'" + '!R3C1:R' + AllTrim(Str(nTotQd8+3)) + 'C18" ss:Hidden="1"/>' + CRLF
		 cXMLCab += ' </Names>' + CRLF
		 cXMLCab += '  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
		 cXMLCab += '     <Column ss:Width="87.75"/>' + CRLF
		 cXMLCab += '     <Column ss:AutoFitWidth="0" ss:Width="69" ss:Span="1"/>' + CRLF
		 cXMLCab += '     <Column ss:Index="4" ss:AutoFitWidth="0" ss:Width="81" ss:Span="7"/>' + CRLF
		 cXMLCab += '     <Column ss:Index="12" ss:Width="85.5"/>' + CRLF
		 cXMLCab += '     <Column ss:AutoFitWidth="0" ss:Width="81"/>' + CRLF
		 cXMLCab += '     <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="41.25"/>' + CRLF
		 cXMLCab += '     <Column ss:AutoFitWidth="0" ss:Width="69" ss:Span="3"/>' + CRLF
		 cXMLCab += ' <Row ss:Height="36">' + CRLF
		 cXMLCab += '     <Cell ss:MergeAcross="14" ss:StyleID="s62">' + CRLF
		 // cXMLCab += '       <Data ss:Type="String">' + cTitulo + " de " + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>' + CRLF
		 cXMLCab += '       <Data ss:Type="String">Formação dos Custos das Baias</Data>' + CRLF
		 cXMLCab += '     </Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
		 cXMLCab += '   <Row ss:AutoFitHeight="0">' + CRLF
		 cXMLCab += '      <Cell ss:Index="4" ss:MergeAcross="5" ss:StyleID="s98"><Data ss:Type="String">Apartação</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '      <Cell              ss:MergeAcross="3" ss:StyleID="s100"><Data ss:Type="String">Compra</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
		 cXMLCab += '   <Row ss:Height="33">' + CRLF
/* 01 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">Lote Compra</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">Baia</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">Cabeças</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">Peso Kg Apartação</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">Peso / Animal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">R$ / Kg</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">R$ Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">R$ / Cabeça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">ICMS Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXMLCab += '      <Cell ss:StyleID="s100"><Data ss:Type="String">Peso Kg Compra</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXMLCab += '      <Cell ss:StyleID="s100"><Data ss:Type="String">R$ / Kg</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */ cXMLCab += '      <Cell ss:StyleID="s100"><Data ss:Type="String">R$ Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */ cXMLCab += '      <Cell ss:StyleID="s100"><Data ss:Type="String">R$ / Cabeça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 14 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">Lote Compra</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 15 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">RAÇA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 16 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">SEXO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 16 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">Dt. Confinamento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 16 */ cXMLCab += '      <Cell ss:StyleID="s98"><Data ss:Type="String">Peso Confinamento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF
	
	
	FWrite(nHandle, EncodeUTF8( cXMLCab ) )
	U_Unir2Arqs( nHandle, nHandAux, cPathBuff )
	
	//cXML := EncodeUTF8(cXMLCab) + cXMLDo
	//
	//If !Empty(cXML)
	//	// FWrite(nHandle, EncodeUTF8( cXMLCab + cXML ) )
	//	FWrite(nHandle, cXML )
	//EndIf
	cXML := ""	

EndIf

Return nTotQd8
// FIM: fQuadro8


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()               						  |
 | Func:  fQuadro9()                											  |
 | Autor: Miguel Martins Bernardo Junior                   						  |
 | Data:  21.08.2018                											  |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |        Processamento de dados Sinteticos;               						  |
 | Obs.:  -  																	  |
 '-------------------------------------------------------------------------------*/
Static Function fQuadro9( nTotQd2, nTotQd3, nTotQd8, aDadDro8 )
Local cWorkSheet    := "Analise - Apuracao"
Local cXML 		 	:= "", cXMLDo:= ""
Local nI			:= 0
Local cXML			:= ""

Local _aIndQd9		:= {}
Local _aMatQd9		:= {}
Local nPos			:= 0, xVar := 0
Local nValor 		:= 0
// Local aCstRacao		:= {}
Local _aMatCOD		:= {} // Custo operacional diario

	nTTColQ9 		:= 0
	While !(_cAliasE)->(Eof())	 // U_VACOMR07()
		nTTColQ9 += 1
		(_cAliasE)->(DbSkip())
	EndDo 

	if nTTColQ9 == 0
		return nil
	EndIf
	
	cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	cXML += '  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
	cXML += '     <Column ss:Width="250"/>
    cXML += '     <Column ss:Width="75" ss:Span="'+AllTrim(Str(nTTColQ9-1))+'"/>
	cXML += ' <Row ss:Height="36">' + CRLF
	cXML += '     <Cell ss:MergeAcross="'+AllTrim(Str(nTTColQ9))+'" ss:StyleID="s62">' + CRLF
	// cXML += '       <Data ss:Type="String">' + cTitulo + " de " + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>' + CRLF
	cXML += '       <Data ss:Type="String">Relatório de Análise de Resultados</Data>' + CRLF
	cXML += '     </Cell>' + CRLF
	cXML += '   </Row>' + CRLF
	
// 	cXML += '<Row>' + CRLF
// 	cXML += '	<Cell><Data ss:Type="String">DATA SAÍDA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// 	(_cAliasE)->(DbGoTop())
// 	If !(_cAliasE)->(Eof())
// 		aAdd( _aMatQd9, {} ) // 1a. linha
// 	EndIf
// 	While !(_cAliasE)->(Eof())	 // U_VACOMR07()
// 		If Empty( (_cAliasE)->D2_EMISSAO ) 
// 			cXML += ' <Cell><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// 		Else
// 			cXML += ' <Cell ss:StyleID="sDataC"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sToD( (_cAliasE)->D2_EMISSAO ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// 		EndIf
// 		aAdd( aTail(_aMatQd9), (_cAliasE)->D2_EMISSAO )
// 		(_cAliasE)->(DbSkip())
// 	EndDo 
// 	cXML += '</Row>' + CRLF

	(_cAliasE)->(DbGoTop())
	If !(_cAliasE)->(Eof())
		aAdd( _aMatQd9, {} ) // 1a. linha
	EndIf
	While !(_cAliasE)->(Eof())	 // U_VACOMR07()
		aAdd( aTail(_aMatQd9), (_cAliasE)->D2_EMISSAO )
		(_cAliasE)->(DbSkip())
	EndDo 
	
	(_cAliasE)->(DbGoTop())
	If !(_cAliasE)->(Eof())
		aAdd( _aMatQd9, {} ) // 2a. linha
	EndIf
	While !(_cAliasE)->(Eof())	 // U_VACOMR07()
		aAdd( aTail(_aMatQd9), (_cAliasE)->D2_LOTECTL )
		(_cAliasE)->(DbSkip())
	EndDo 
	
	cXML += ' <Row> ' + CRLF
	cXML += '	<Cell ss:StyleID="sTextoN"><Data ss:Type="String">SEQUÊNCIA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' 	<Cell ss:StyleID="s97" ss:Formula="=COLUMN()-1"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell> ' + CRLF
	Next nI
	cXML += ' </Row>' + CRLF
	
	_aMatCOD := {} // usando TMP
	(_cForAlias)->(DbGoTop())
	While !(_cForAlias)->(Eof())	 // U_VACOMR07()
		aAdd( _aMatCOD, { (_cForAlias)->B8_LOTECTL, (_cForAlias)->ZCC_NOMFOR } )
		(_cForAlias)->(DbSkip())
	EndDo 
	
	cXML += ' <Row ss:Height="65"> ' + CRLF
	cXML += '	<Cell ss:StyleID="sTextoN"><Data ss:Type="String">FORNECEDORES</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		
		nValor := defFornecedor( _aMatCOD, _aMatQd9[ 2, nI ] )
	
		cXML += ' 	<Cell ss:StyleID="sTextoC"><Data ss:Type="String">' + U_FrmtVlrExcel( nValor ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell> ' + CRLF
	Next nI
	cXML += ' </Row>' + CRLF
	// usando TMP
	
	// new
	cXML += '<Row>' + CRLF
	cXML += '	<Cell ss:StyleID="sTextoN"><Data ss:Type="String">DATA SAÍDA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		If Empty( _aMatQd9[ 1, nI] )  // linha 1
			cXML += ' <Cell><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
			cXML += ' <Cell ss:StyleID="sDataC"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sToD( _aMatQd9[ 1, nI] ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf
	Next nI
	cXML += '</Row>' + CRLF
	
	cXMLDo += EncodeUTF8(cXML)
	cXML := ""

// 	cXML += '<Row>' + CRLF
// 	cXML += '	<Cell><Data ss:Type="String">BAIA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// 	(_cAliasE)->(DbGoTop())
// 	If !(_cAliasE)->(Eof())
// 		aAdd( _aMatQd9, {} ) // 2a. linha
// 	EndIf
// 	While !(_cAliasE)->(Eof())	 // U_VACOMR07()
// 		aAdd( aTail(_aMatQd9), (_cAliasE)->D2_LOTECTL )
// 		cXML += ' <Cell ss:StyleID="sTextoC"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasE)->D2_LOTECTL ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
// 		(_cAliasE)->(DbSkip())
// 	EndDo 
// 	cXML += '</Row>' + CRLF
	
	// new
	cXML += '<Row>' + CRLF
	cXML += '	<Cell ss:StyleID="sTextoN"><Data ss:Type="String">BAIA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sTextoC"><Data ss:Type="String">' + U_FrmtVlrExcel( _aMatQd9[ 2, nI] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row ss:Hidden="1">' + CRLF
	cXML += ' 	<Cell ss:StyleID="sTextoN"><Data ss:Type="String">QUANTIDADE DE ANIMAIS DO LOTE</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += '  <Cell ss:StyleID="sSemDigC" ss:Formula="=SUMIF(' + "'Custo Baia'" + '!R4C2:R' + AllTrim(Str( nTotQd8 )) + 'C2,R5C,' + "'Custo Baia'" + '!R4C3:R' + AllTrim(Str( nTotQd8 )) + 'C3)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += '	<Cell ss:StyleID="sTextoN"><Data ss:Type="String">QUANTIDADE DE ANIMAIS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	(_cAliasE)->(DbGoTop())
	While !(_cAliasE)->(Eof())	 // U_VACOMR07()
		cXML += ' <Cell ss:StyleID="sSemDigC"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasE)->QT_FAT ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		(_cAliasE)->(DbSkip())
	EndDo 
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">SEXO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	(_cAliasE)->(DbGoTop())
	While !(_cAliasE)->(Eof())	 // U_VACOMR07()
		If (_cAliasE)->QT_SEXO > 1
			cXML += ' <Cell><Data ss:Type="String">Misto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
			cXML += ' <Cell ss:Formula="=VLOOKUP(R5C,' + "'Custo Baia'" + '!R3C2:R' + AllTrim(Str( nTotQd8 )) + 'C16,15,0)"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf
		(_cAliasE)->(DbSkip())
	EndDo 
	cXML += '</Row>' + CRLF 
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">RAÇA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	(_cAliasE)->(DbGoTop())
	While !(_cAliasE)->(Eof())	 // U_VACOMR07()
		If (_cAliasE)->QT_RACA> 1
			cXML += ' <Cell><Data ss:Type="String">Misto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
			cXML += ' <Cell ss:Formula="=VLOOKUP(R5C,' + "'Custo Baia'" + '!R3C2:R' + AllTrim(Str( nTotQd8 )) + 'C16,14,0)"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf
		(_cAliasE)->(DbSkip())
	EndDo 
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">DATA DA ENTRADA DO ANIMAL</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sData" ss:Formula="=VLOOKUP(R5C,' + "'Custo Baia'" + '!R3C2:R' + AllTrim(Str( nTotQd8 )) + 'C18,16,0)"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	
	cXMLDo += EncodeUTF8(cXML)
	cXML := ""
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoNFundoVerdeClaroApuracao"><Data ss:Type="String">PESO ENTRADA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sComDigFundoVerdeClaroApuracao" ss:Formula="=VLOOKUP(R5C,' + "'Custo Baia'" + '!R3C2:R' + AllTrim(Str( nTotQd8 )) + 'C18,17,0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">COMPRA PERCENTUAL</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sPorcent"><Data ss:Type="Number">0.5</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoNFundoVerdeClaroApuracao"><Data ss:Type="String">PESO DA COMPRA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sComDigFundoVerdeClaroApuracao" ss:Formula="=IFERROR(ROUND(R[-2]C*R[-1]C,2),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">VALOR DA @ NA HORA DA COMPRA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(ROUND(R[1]C/R[-3]C*30,2),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">VALOR DO ANIMAL NA ENTRADA DO CONFINAMENTO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(SUMIF(' + "'Custo Baia'" + '!R4C2:R' + AllTrim(Str( nTotQd8 )) + 'C2,R5C,' + "'Custo Baia'" + '!R4C7:R' + AllTrim(Str( nTotQd8 )) + 'C7)/R6C,0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">QUANTIDADE DE DIAS NO CONFINAMENTO (MEDIA)</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sSemDigC" ss:Formula="=IF(R[-12]C=&quot;&quot;,TODAY()-R[-6]C,R[-12]C-R[-6]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoNFundoVerdeClaroApuracao"><Data ss:Type="String">GANHO DIARIO DE PESO - GMD</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sComDigC3FundoVerdeClaroApuracao" ss:Formula="=ROUND((R[10]C-R[-6]C)/R[-1]C,3)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXMLDo += EncodeUTF8(cXML)
	cXML := ""
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">TOTAL DE DIARIAS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sSemDigC" ss:Formula="=R[-2]C*R[-11]C"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	// aCstRacao := {}
	aAdd( _aMatQd9, Array( len(_aMatQd9[1]) ) ) // 3a. linha
	// Carregar vetor de custo pelo SQL
	(_cAliasR)->(DbGoTop())
	While !(_cAliasR)->(Eof())	 // U_VACOMR07()
		
		// aAdd( aCstRacao, { (_cAliasR)->LOTE, (_cAliasR)->CUSTO } )
		If ( nPos := aScan( _aMatQd9[2], { |x| AllTrim(x) == AllTrim((_cAliasR)->LOTE) } ) ) > 0
			
			_aMatQd9[ 3, nPos ] := (_cAliasR)->CUSTO
		EndIf

		(_cAliasR)->(DbSkip())
	EndDo 

	cXML += '<Row ss:Hidden="1">' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">CUSTO DA RAÇÃO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		nValor := 0
		If (nPos := aScan( _aMatQd9[2], { |x| AllTrim(x) == AllTrim(_aMatQd9[ 2, nI ]) } ) ) > 0
			nValor := _aMatQd9[ 3, nPos ]
		EndIf
		cXML += ' <Cell ss:StyleID="sReal"><Data ss:Type="Number">' + U_FrmtVlrExcel( nValor ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF

	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">CUSTO DA RAÇÃO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=(R19C/R6C*R7C)/R18C"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	(_cAliasO)->(DbGoTop())
	While !(_cAliasO)->(Eof())	 // U_VACOMR07()
		aAdd( _aMatCOD, { (_cAliasO)->X5_CHAVE, (_cAliasO)->X5_DESCRI } ) // custo operacional diario
		(_cAliasO)->(DbSkip())
	EndDo 
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">CUSTO OPERACIONAL DIÁRIA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		xVar := 0
		if (nPos := aScan( aDadDro8, { |x| AllTrim(x[2]) == AllTrim(_aMatQd9[2, nI]) } )) > 0
			xVar := CalculaCusto( aDadDro8[nPos, 5], Iif(Empty(_aMatQd9[ 1, nI]),DtoS(dDataBase),_aMatQd9[ 1, nI]), _aMatCOD )
		EndIf
		cXML += ' <Cell ss:StyleID="sReal"><Data ss:Type="Number">' + U_FrmtVlrExcel( xVar ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	 
	cXMLDo += EncodeUTF8(cXML)
	cXML := ""
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">CUSTO DA RAÇÃO COM OPERAÇÃO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=ROUND(R[-1]C+R[-2]C,2)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">CUSTO DA @ PRODUZIDA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(R[1]C/(((R[4]C*R[7]C)-(R[-12]C*50%))/15),3)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">CUSTO DA ENGORDA POR BOI</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(R[2]C/R[-17]C,0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">VALOR REAL DA DIARIA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=R[-1]C/R[-9]C"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">TOTAL DAS DIARIAS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=R[-4]C*R[-8]C"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	aAdd( _aMatQd9, Array( len(_aMatQd9[1]) ) ) // 4a. linha => PESO_VIVO
	aAdd( _aMatQd9, Array( len(_aMatQd9[1]) ) ) // 5a. linha => PESO_MORTO
	aAdd( _aMatQd9, Array( len(_aMatQd9[1]) ) ) // 6a. linha => VLR ARROB
	
	_aIndQd9 := Array( len(_aMatQd9[1]) )       // Indice 1a. + 2a.
	For nI:=1 to len(_aMatQd9[1])
		_aIndQd9[nI] := _aMatQd9[ 1, nI] + AllTrim( _aMatQd9[ 2, nI] )
	Next nI
	
	// Carregar vetor de Peso pelo SQL
	(_cAliasP)->(DbGoTop())
	While !(_cAliasP)->(Eof())	 // U_VACOMR07()
		
		If ( nPos := aScan( _aIndQd9, { |x| x == (_cAliasP)->EMISSAO_NF + AllTrim((_cAliasP)->LOTE) } ) ) > 0
			_aMatQd9[ 4, nPos ] := (_cAliasP)->PESO_MEDIO
			
			// If ValType( _aMatQd9[ 5, nPos ] ) == "U"
				// _aMatQd9[ 5, nPos ] := 0
			// EndIf
			// _aMatQd9[ 5, nPos ] += (_cAliasP)->PESO_ABATE // /(_cAliasP)->QTD 
			_aMatQd9[ 5, nPos ] := (_cAliasP)->PES_TTABATE

			// _aMatQd9[ 6, nPos ] := (_cAliasP)->VLR_ARROB
			_aMatQd9[ 6, nPos ] := (_cAliasP)->ZAB_TT_VLRECE // (_cAliasP)->ZAB_VLRECE
		EndIf

		(_cAliasP)->(DbSkip())
	EndDo 
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoNFundoVerdeClaroApuracao"><Data ss:Type="String">PESO VIVO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		nValor := 0
		If ( nPos := aScan( _aIndQd9, { |x| x == _aMatQd9[ 1, nI ] + AllTrim(_aMatQd9[ 2, nI ]) } ) ) > 0
			nValor := _aMatQd9[ 4, nPos ]
		EndIf
		cXML += ' <Cell ss:StyleID="sComDigFundoVerdeClaroApuracao"><Data ss:Type="Number">' + U_FrmtVlrExcel( nValor ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXMLDo += EncodeUTF8(cXML)
	cXML := ""
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoNFundoVerdeClaroApuracao"><Data ss:Type="String">PESO MORTO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	/*  MJ : 30.11
		Toshio pediu pra mudar a logica,
		invertido a relacao com o campo PESO TOTAL (ultima linha do relatorio)
		
	For nI := 1 to nTTColQ9
		nValor := 0
		If ( nPos := aScan( _aIndQd9, { |x| x == _aMatQd9[ 1, nI ] + AllTrim(_aMatQd9[ 2, nI ]) } ) ) > 0
			nValor := _aMatQd9[ 5, nPos ]
		EndIf
		cXML += ' <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( nValor ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI */
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sComDigFundoVerdeClaroApuracao" ss:Formula="=R[18]C/R[-21]C"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoNFundoVerdeClaroApuracao"><Data ss:Type="String">TOTAL DE ENGORDA - PESO MORTO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sComDigFundoVerdeClaroApuracao" ss:Formula="=R[-2]C-R[-16]C"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">RENDIMENTO DE CARCAÇA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sPorcent" ss:Formula="=IFERROR(R[-2]C/R[-3]C,0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">VALOR DE VENDA POR @</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sComDig" ss:Formula="=IFERROR((R[4]C/R[-3]C)/R[-24]C*15,0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">VALOR DE VENDA POR ANIMAL</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=R[-1]C*R[-4]C/15"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">VALOR DE COMPRA + DESPESAS DE ENGORDA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=R[-18]C+R[-9]C"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">ICMS SOBRE A COMPRA GADO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=IFERROR((SUMIF(' + "'Custo Baia'" + '!R4C2:R' + AllTrim(Str( nTotQd8 )) + 'C2,R5C,' + "'Custo Baia'" + '!R4C9:R' + AllTrim(Str( nTotQd8 )) + 'C9)/SUMIF(' + "'Custo Baia'" + '!R4C2:R' + AllTrim(Str( nTotQd8 )) + 'C2,R5C,' + "'Custo Baia'" + '!R4C3:R' + AllTrim(Str( nTotQd8 )) + 'C3))*R7C,0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoNFundoAzulClaroApuracao"><Data ss:Type="String">VALOR TOTAL DE VENDA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		nValor := 0
		If ( nPos := aScan( _aIndQd9, { |x| x == _aMatQd9[ 1, nI ] + AllTrim(_aMatQd9[ 2, nI ]) } ) ) > 0
			nValor := _aMatQd9[ 6, nPos ]
		EndIf
		cXML += ' <Cell ss:StyleID="sRealFundoAzulClaroApuracao"><Data ss:Type="Number">' + U_FrmtVlrExcel( nValor ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXMLDo += EncodeUTF8(cXML)
	cXML := ""
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoNFundoAzulClaroApuracao"><Data ss:Type="String">VALOR TOTAL DA COMPRA + DIARIAS+ICMS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sRealFundoAzulClaroApuracao" ss:Formula="=ROUND((R[-21]C*R[-29]C)+R[-10]C+R[-2]C,2)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">LUCRO BRUTO POR LOTE R$</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=ROUND(R[-2]C-R[-1]C,2)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">NO PERIODO - VALOR BRUTO </Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sPorcent" ss:Formula="=R[-1]C/R[-2]C"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">APURAÇÃO POR ANIMAL VALOR LIQUIDO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(ROUND(R[-2]C/R[-32]C,2),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">POR MÊS - VALOR BRUTO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sPorcent" ss:Formula="=R[-2]C/R[-24]C*30"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoNFundoVerdeClaroApuracao"><Data ss:Type="String"> @ GANHA POR ANIMAL</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sComDigFundoVerdeClaroApuracao" ss:Formula="=ABS(ROUND((R[-13]C-R[-30]C/2)/15,2))"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	// COMENTADO NO DIA 10.01.2019
	// cXML += '<Row>' + CRLF
	// cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">IMPOSTO POR CABEÇA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	// For nI := 1 to nTTColQ9
	// 	cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=IF(R[-3]C&lt;0,0,ROUND(0.35*R[-3]C,2))"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	// Next nI
	// cXML += '</Row>' + CRLF
	// 
	// cXML += '<Row>' + CRLF
	// cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">APURAÇÃO LIQUIDA POR BOI</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	// For nI := 1 to nTTColQ9
	// 	cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=R[-4]C-R[-1]C"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	// Next nI
	// cXML += '</Row>' + CRLF
	
	cXMLDo += EncodeUTF8(cXML)
	cXML := ""
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">NO PERIODO - VALOR LIQUIDO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sPorcent" ss:Formula="=R[-3]C/R[-9]C"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">POR MÊS - VALOR LIQUIDO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sPorcent" ss:Formula="=R[-1]C/R[-27]C*30"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	// COMENTADO NO DIA 10.01.2019
	// cXML += '<Row>' + CRLF
	// cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">IMPOSTO TOTAL</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	// For nI := 1 to nTTColQ9
	// 	cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(ROUND(R[-4]C*R[-39]C,2),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	// Next nI
	// cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">ICMS RECUPERAR '+cValToChar(MV_PAR21)+'%</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(ROUND('+cValToChar(MV_PAR21/100)+'*R[-10]C/R[-37]C,2),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">RESULTADO POR CABEÇA COM ICMS </Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(R[-6]C+R[-1]C,0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next nI
	cXML += '</Row>' + CRLF
	cXML += '<Row>' + CRLF
	cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">PESO TOTAL</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	/* MJ : 30.11
		-> Toshio pediu pra mudar;
			vai vir aqui a linha do PESO MORTO (MATQD9 linha 5), sem dividir pela QTD
	For nI := 1 to nTTColQ9
		cXML += ' <Cell ss:StyleID="sComDig" ss:Formula="=R[-21]C*R[-42]C"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI */
	For nI := 1 to nTTColQ9
		nValor := 0
		If ( nPos := aScan( _aIndQd9, { |x| x == _aMatQd9[ 1, nI ] + AllTrim(_aMatQd9[ 2, nI ]) } ) ) > 0
			nValor := _aMatQd9[ 5, nPos ]
		EndIf
		cXML += ' <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( nValor ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	Next nI
	cXML += '</Row>' + CRLF
	
	// COMENTADO NO DIA 10.01.2019
	// // MJ : 03.11.2018
	// // 7a. linha => SLD_LOTE
	// (_cAliasE)->(DbGoTop())
	// If !(_cAliasE)->(Eof())
	// 	aAdd( _aMatQd9, {} ) // 2a. linha
	// EndIf
	// While !(_cAliasE)->(Eof())	 // U_VACOMR07()
	// 	aAdd( aTail(_aMatQd9), (_cAliasE)->SLD_LOTE )
	// 	(_cAliasE)->(DbSkip())
	// EndDo 
	// 
	// cXML += '<Row>' + CRLF
	// cXML += ' <Cell ss:StyleID="sTextoN"><Data ss:Type="String">QUANT. CRIACAO DO LOTE</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	// For nI := 1 to nTTColQ9
	// 	cXML += ' <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( _aMatQd9[ 7, nI ] ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	// Next nI
	// cXML += '</Row>' + CRLF
	
	
	cXMLDo += EncodeUTF8(cXML)
	cXML := ""
	
	// Final da Planilha
	cXML += '  </Table>' + CRLF
    cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += ' <PageSetup>' + CRLF
	cXML += ' <Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' <Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += ' </PageSetup>' + CRLF
	cXML += ' <Unsynced/>' + CRLF
	cXML += ' <TabColorIndex>50</TabColorIndex>' + CRLF
	cXML += ' <Print>' + CRLF
	cXML += ' <ValidPrinterInfo/>' + CRLF
	cXML += ' <PaperSizeIndex>9</PaperSizeIndex>' + CRLF
	cXML += ' <HorizontalResolution>600</HorizontalResolution>' + CRLF
	cXML += ' <VerticalResolution>600</VerticalResolution>' + CRLF
	cXML += ' </Print>' + CRLF
	cXML += ' <Selected/>' + CRLF
	cXML += ' <FreezePanes/>' + CRLF
	cXML += ' <FrozenNoSplit/>' + CRLF
	cXML += ' <SplitHorizontal>7</SplitHorizontal>' + CRLF
	cXML += ' <TopRowBottomPane>20</TopRowBottomPane>' + CRLF
	cXML += ' <SplitVertical>1</SplitVertical>' + CRLF
	cXML += ' <LeftColumnRightPane>5</LeftColumnRightPane>' + CRLF
	cXML += ' <ActivePane>0</ActivePane>' + CRLF
	cXML += ' <Panes>' + CRLF
	cXML += ' 	<Pane>' + CRLF
	cXML += ' 		<Number>3</Number>' + CRLF
	cXML += ' 	</Pane>' + CRLF
	cXML += ' 	<Pane>' + CRLF
	cXML += ' 		<Number>1</Number>' + CRLF
	cXML += ' 		<ActiveCol>1</ActiveCol>' + CRLF
	cXML += ' 	</Pane>' + CRLF
	cXML += ' 	<Pane>' + CRLF
	cXML += ' 		<Number>2</Number>' + CRLF
	cXML += ' 		<ActiveRow>7</ActiveRow>' + CRLF
	cXML += ' 	</Pane>' + CRLF
	cXML += ' 	<Pane>' + CRLF
	cXML += ' 		<Number>0</Number>' + CRLF
	cXML += ' 		<ActiveRow>29</ActiveRow>' + CRLF
	cXML += ' 		<ActiveCol>9</ActiveCol>' + CRLF
	cXML += ' 	</Pane>' + CRLF
	cXML += ' </Panes>' + CRLF
	cXML += ' <ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += ' <ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += ' </WorksheetOptions>' + CRLF
	
	cXML += ' <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">
	cXML += ' 	<Range>R37C2:R37C'+cValToChar(nTTColQ9+1)+'</Range>
	cXML += ' 	<Condition>
	cXML += ' 		<Qualifier>Less</Qualifier>
	cXML += ' 		<Value1>0</Value1>
	cXML += ' 		<Format Style="color:red;text-line-through:none;mso-background-source:auto"/>
	cXML += ' 	</Condition>
	cXML += ' </ConditionalFormatting>
	
	cXML += ' <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">
	cXML += ' 	<Range>R38C2:R38C'+cValToChar(nTTColQ9+1)+'</Range>
	cXML += ' 	<Condition>
	cXML += ' 		<Qualifier>Less</Qualifier>
	cXML += ' 		<Value1>0</Value1>
	cXML += ' 		<Format Style="color:red;text-line-through:none;mso-background-source:auto"/>
	cXML += ' 	</Condition>
	cXML += ' </ConditionalFormatting>
	
	cXML += ' <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">
	cXML += ' 	<Range>R39C2:R39C'+cValToChar(nTTColQ9+1)+'</Range>
	cXML += ' 	<Condition>
	cXML += ' 		<Qualifier>Less</Qualifier>
	cXML += ' 		<Value1>0</Value1>
	cXML += ' 		<Format Style="color:red;text-line-through:none;mso-background-source:auto"/>
	cXML += ' 	</Condition>
	cXML += ' </ConditionalFormatting>
	
	cXML += ' <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">
	cXML += ' 	<Range>R40C2:R40C'+cValToChar(nTTColQ9+1)+'</Range>
	cXML += ' 	<Condition>
	cXML += ' 		<Qualifier>Less</Qualifier>
	cXML += ' 		<Value1>0</Value1>
	cXML += ' 		<Format Style="color:red;text-line-through:none;mso-background-source:auto"/>
	cXML += ' 	</Condition> 
	cXML += ' </ConditionalFormatting>
	
	cXML += ' <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">
	cXML += ' 	<Range>R43C2:R43C'+cValToChar(nTTColQ9+1)+'</Range>
	cXML += ' 	<Condition>
	cXML += ' 		<Qualifier>Less</Qualifier>
	cXML += ' 		<Value1>0</Value1>.+
	cXML += ' 		<Format Style="color:red;text-line-through:none;mso-background-source:auto"/>
	cXML += ' 	</Condition>
	cXML += ' </ConditionalFormatting>
	
	cXML += ' <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">
	cXML += ' 	<Range>R48C2:R48C'+cValToChar(nTTColQ9+1)+'</Range>
	cXML += ' 	<Condition>
	cXML += ' 		<Qualifier>Less</Qualifier>
	cXML += ' 		<Value1>0</Value1>
	cXML += ' 		<Format Style="color:red;text-line-through:none;mso-background-source:auto"/>
	cXML += ' 	</Condition>
	cXML += ' </ConditionalFormatting>
    
	cXML += '</Worksheet>' + CRLF
	
	cXMLDo += EncodeUTF8(cXML)
	cXML := cXMLDo
	
	If !Empty(cXML)
		// FWrite(nHandle, EncodeUTF8( cXML ) )
		FWrite(nHandle, cXML )
	EndIf
	cXML := ""	

return nil
// fQuadro9 - "Analise - Apuracao"


Static _nPBaia := 1
Static _nPSexo := 2
Static _nPRaca := 3

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:  fQuadro9()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  21.08.2018	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |        Processamento de dados Sinteticos;             	            	      |
 | Obs.:  -	            	            										  |
 '-------------------------------------------------------------------------------*/
Static Function Quadro11f( )

Local cWorkSheet    := "Consumo Ração x Data"
Local cXMLCab 		:= "", cXML := "", cXMLDo:= ""
Local nQtDias       := 0
Local aDados	 	:= {}
Local nCol		 	:= 1, nI := 0
Local nTotLin       := 0
Local dDia          := DtoS("")
Local cLinha		:= ""
Local cPathBuff		:= StrTran(cArquivo , ".xml","")+;
								"_buffer.txt"

if nTTColQ9 == 0
	return nil
EndIf

// dDIni11F   := MV_PAR13-MV_PAR20
nQtDias     := DateDiffDay(dDIni11F, MV_PAR13)
 
(_cCRDAlias)->(DbGoTop()) 
If !(_cCRDAlias)->(Eof())
	
	nHandAux := FCreate( cPathBuff )
	if nHandAux == -1
		conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	else
	
		aDados 	:= Array(3+(3*nQtdias))
		
		// Quadro11f
		While !(_cCRDAlias)->(Eof())	 // U_VACOMR07()
		
			If Empty ( aDados[ _nPBaia ] )
				aDados[ _nPBaia ] := (_cCRDAlias)->LOTE
				aDados[ _nPSexo ] := ""
				aDados[ _nPRaca ] := ""
			EndIf
			
			nPos := sToD((_cCRDAlias)->DATA_TRATO)-dDIni11F
			nPosCol := Iif(nPos==0,  nPos, nPos*3 )
			aDados[4+nPosCol ] := (_cCRDAlias)->QT_INSUMO
			aDados[5+nPosCol ] := (_cCRDAlias)->CUSTO
			aDados[6+nPosCol ] := 0
		
			(_cCRDAlias)->(DbSkip())
			
			If (_cCRDAlias)->(Eof()) .or. aDados[ _nPBaia ] <> (_cCRDAlias)->LOTE

				cXML += ' <Row>' + CRLF
				cXML += ' 	<Cell ss:StyleID="sTexto"><Data ss:Type="String">'+U_FrmtVlrExcel( aDados[ _nPBaia ] )+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += ' 	<Cell ss:StyleID="sTexto" ss:Formula="=IFERROR(HLOOKUP(RC1,'+ "'Analise - Apuracao'" + '!R5C2:R9C9,4,FALSE),&quot;&quot;)"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += ' 	<Cell ss:StyleID="sTexto" ss:Formula="=IFERROR(HLOOKUP(RC1,'+ "'Analise - Apuracao'" + '!R5C2:R9C9,5,FALSE),&quot;&quot;)"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			
				nI := 4
				while nI <= len(aDados)-1
					cXML += ' <Cell ss:StyleID="sComDig"><Data ss:Type="Number">'+ U_FrmtVlrExcel( aDados[nI]   ) +'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					cXML += ' <Cell ss:StyleID="sReal"><Data ss:Type="Number">'  + U_FrmtVlrExcel( aDados[nI+1] ) +'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					cXML += ' <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[-1]/RC[-2],&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					nI+=3
				EndDo
				cXML += ' </Row>' + CRLF

				nTotLin += 1
				aDados	:= Array(3+(3*nQtdias))
				
				// cXMLDo += EncodeUTF8(cXML)
				FWrite( nHandAux, EncodeUTF8( cXML ) )
				cXML := ""
			
			EndIf
		EndDo
		fClose(nHandAux)
		
		cXML   := ""
		// cXMLDo := ""
		
		// pular linha						
		cXML := '<Row ss:AutoFitHeight="0"></Row>' + CRLF
		
		// Quadro11f - "Consumo Ração x Data"
		
		// Final da Planilha
		cXML += '</Table>' + CRLF
		cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
		cXML += ' 	<PageSetup>' + CRLF
		cXML += ' 		<Header x:Margin="0.31496062000000002"/>' + CRLF
		cXML += ' 		<Footer x:Margin="0.31496062000000002"/>' + CRLF
		cXML += ' 		<PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
		cXML += ' 	</PageSetup>' + CRLF
		cXML += ' 	<Unsynced/>' + CRLF
		cXML += '   <Selected/>' + CRLF
		cXML += '   <FreezePanes/>' + CRLF
		cXML += '   <FrozenNoSplit/>' + CRLF
		cXML += '   <FilterOn/>' + CRLF
		cXML += '   <SplitHorizontal>38</SplitHorizontal>' + CRLF
		cXML += '   <TopRowBottomPane>38</TopRowBottomPane>' + CRLF
		cXML += '   <SplitVertical>3</SplitVertical>' + CRLF
		cXML += '   <LeftColumnRightPane>3</LeftColumnRightPane>' + CRLF
		cXML += '   <ActivePane>0</ActivePane>' + CRLF
		cXML += '   <Panes>' + CRLF
		cXML += '   	<Pane>' + CRLF
		cXML += '   		<Number>3</Number>' + CRLF
		cXML += '   	</Pane>' + CRLF
		cXML += '   	<Pane>' + CRLF
		cXML += '   		<Number>1</Number>' + CRLF
		cXML += '   	</Pane>' + CRLF
		cXML += '   	<Pane>' + CRLF
		cXML += '   		<Number>2</Number>' + CRLF
		cXML += '   	</Pane>' + CRLF
		cXML += '   	<Pane>' + CRLF
		cXML += '   		<Number>0</Number>' + CRLF
		cXML += '   		<ActiveRow>411</ActiveRow>' + CRLF
		cXML += '   		<ActiveCol>4</ActiveCol>' + CRLF
		cXML += '   	</Pane>' + CRLF
		cXML += '   </Panes>' + CRLF
		cXML += ' 	<ProtectObjects>False</ProtectObjects>' + CRLF
		cXML += ' 	<ProtectScenarios>False</ProtectScenarios>' + CRLF
		cXML += ' </WorksheetOptions>' + CRLF
		cXML += ' <AutoFilter x:Range="R3C1:R'+cValToChar(nTotLin+3)+'C'+cValToChar(nTTColQ9)+'" xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
		// cXML += ' 	<AutoFilterColumn x:Index="2" x:Type="NonBlanks"/>' + CRLF
		cXML += ' </AutoFilter>' + CRLF
		cXML += ' </Worksheet>' + CRLF

		// cXMLDo += EncodeUTF8(cXML)
		// cXML := ""
		
		cXMLCab := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		cXMLCab += ' <Names>' + CRLF
		cXMLCab += ' 	<NamedRange ss:Name="_FilterDatabase" ' + CRLF
		cXMLCab += ' 		ss:RefersTo="=' + "'Consumo Racao Data'" + '!R3C1:R'+cValToChar(nTotLin+3)+'C'+cValToChar(nTTColQ9)+'" ss:Hidden="1"/>' + CRLF
		cXMLCab += ' </Names>' + CRLF
		cXMLCab += '  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
		cXMLCab += '  <Column ss:Width="51"/>' + CRLF
		cXMLCab += '  <Column ss:Width="60.75" ss:Span="1"/>' + CRLF
		
		nI := 4
		while nI <= len(aDados)
			cXMLCab += ' <Column ss:Width="75"/>' + CRLF
			cXMLCab += ' <Column ss:Width="90"/>' + CRLF
			cXMLCab += ' <Column ss:Width="75"/>' + CRLF
			nI+=3
		EndDo
		
		cXMLCab += '   <Row ss:AutoFitHeight="0">' + CRLF
		cXMLCab += '     <Cell ss:MergeAcross="' + AllTrim(Str( nQtDias*3+5 )) + '" ss:StyleID="s62">' + CRLF
		cXMLCab += '       <Data ss:Type="String">' + "Consumo de Ração por Data" + " - Dt. Referência de " + DtoC(dDIni11F) + ' ate ' + DtoC(MV_PAR13-1) + '</Data>' + CRLF
		cXMLCab += '     </Cell>' + CRLF
		cXMLCab += '   </Row>' + CRLF

		cXMLCab += ' <Row ss:AutoFitHeight="0">' + CRLF
		For dDia := dDIni11F to MV_PAR13-1
			cXMLCab += ' <Cell ss:StyleID="TitRacao"
			cXMLCab += '     ss:MergeAcross="2"
			cXMLCab += '     ss:Index="' + AllTrim( Str(nCol+=3) ) + '">' + CRLF
			cXMLCab += ' <Data ss:Type="DateTime">' + U_FrmtVlrExcel(dDia) + '</Data></Cell>' + CRLF
		Next dDia
		cXMLCab += ' </Row>' + CRLF
		
		cXMLCab += ' <Row ss:AutoFitHeight="0">' + CRLF
		cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Baia</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Sexo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Raça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		For dDia := dDIni11F to MV_PAR13-1
			cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Qtd.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Custo Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Custo Médio</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Next dDia
		cXMLCab += ' </Row>' + CRLF
		
		FWrite( nHandle, EncodeUTF8(cXMLCab) )

		// FT_FUse fopen buffer nHandAux
		U_Unir2Arqs( nHandle, nHandAux, cPathBuff )

		FWrite( nHandle, EncodeUTF8(cXML) )

		cXML := ""	
		FClose(nHandAux)
	EndIf
EndIf

return nil
// Quadro11f - "Consumo Ração x Data"
	

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:            	            	            	            	          |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  26.06.2019	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
User Function Unir2Arqs( nHandle, nHandAux, cPathBuff )
Local aArea := GetArea()
Local nTamBuff		:= 2048
Local cContLinha	:= '000000000000'
Local nTotalLin		:= 0
Local nI			:= 0
Local cLinha		:= Space(nTamBuff)

nHandAux := FOpen( cPathBuff ) // , FO_READWRITE + FO_SHARED )
If nHandAux > 0
	
	nTotalLin := FSEEK( nHandAux, 0, FS_END)
	ProcRegua(nTotalLin)
	
	fSeek( nHandAux, 0, FS_SET)
	fRead( nHandAux, @cLinha, nTamBuff)
	While !Empty(cLinha)
	
		cContLinha := Soma1(cContLinha)
		IncProc("Lendo arquivo a vista "+CRLF+"Registros Lidos: " + cContLinha )
		
		FWrite( nHandle, cLinha )
		fRead( nHandAux, @cLinha, nTamBuff)
	EndDo
	fClose(nHandAux)
	
	FERASE( cPathBuff )
	
EndIf
RestArea(aArea)
Return nil


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:  fQuadro9()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  21.08.2018	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |        Processamento de dados Sinteticos;             	            	      |
 | Obs.:  -	            	            										  |
 '-------------------------------------------------------------------------------*/
Static Function Quadro10f( )

Local cWorkSheet    := "Compras - Genericos"
Local cXML			:= "", cXMLDo:= ""
Local n10fTotQd		:= 3 

(_cGenAlias)->(DbGoTop()) 
If !(_cGenAlias)->(Eof())

	//fQuadro10f
	While !(_cGenAlias)->(Eof())	 // U_VACOMR07()

		n10fTotQd += 1
		
		cXML += '<Row>' + CRLF
		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(OR(RC[2]=&quot;BEZERRO&quot;,RC[2]=&quot;BEZERRA&quot;),&quot;&quot;,CONCATENATE(RC[3],RC[1]))"><Data ss:Type="String"></Data></Cell>' + CRLF
/* 01 */cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cGenAlias)->SEXO 	  ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cGenAlias)->DESCRICAO  ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cGenAlias)->RACA 	  ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cGenAlias)->QTD_NF 	  ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */cXML += '  <Cell ss:StyleID="sRealFundoVerdeClaro"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cGenAlias)->TOTAL_NF ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */cXML += '  <Cell ss:StyleID="sRealFundoVerdeClaro"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cGenAlias)->TOTAL_NF_MAIS_COMPL ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */cXML += '  <Cell ss:StyleID="sRealFundoVerdeClaro"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cGenAlias)->FRETE ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */cXML += '  <Cell ss:StyleID="sRealFundoVerdeClaro"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cGenAlias)->COMISSAO ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */cXML += '  <Cell ss:StyleID="sRealFundoAmareloClaro"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cGenAlias)->ICMS_FRETE_GADO ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */cXML += '  <Cell ss:StyleID="sRealFundoAmareloClaro"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cGenAlias)->ICMS_GADO_MAIS_COMPL ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */cXML += '  <Cell ss:StyleID="sRealFundoAzulOcean" ss:Formula="=SUM(RC[-5]:RC[-1])"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */cXML += '  <Cell ss:StyleID="sRealFundoAzulOcean" ss:Formula="=RC[-1]/RC[-8]"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=(RC[-3]/RC[-9])+(RC[-4]/RC[-9])"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '</Row>' + CRLF
		(_cGenAlias)->(DbSkip())
		
		cXMLDo += EncodeUTF8(cXML)
		cXML := ""
		
	EndDo
	
	// Final da Planilha
	cXML += '</Table>' + CRLF
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <PageSetup>' + CRLF
	cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
	cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += '   </PageSetup>' + CRLF
	cXML += '   <Unsynced/>' + CRLF
	cXML += '   <Selected/>' + CRLF
	cXML += '   <FreezePanes/>' + CRLF
	cXML += '   <FrozenNoSplit/>' + CRLF
	cXML += '   <SplitHorizontal>3</SplitHorizontal>' + CRLF
	cXML += '   <TopRowBottomPane>3</TopRowBottomPane>' + CRLF
	cXML += '   <SplitVertical>4</SplitVertical>' + CRLF
	cXML += '   <LeftColumnRightPane>4</LeftColumnRightPane>' + CRLF
	cXML += '   <ActivePane>0</ActivePane>' + CRLF
	cXML += '   <Panes>' + CRLF
	cXML += '    <Pane>' + CRLF
	cXML += '     <Number>3</Number>' + CRLF
	cXML += '    </Pane>' + CRLF
	cXML += '    <Pane>' + CRLF
	cXML += '     <Number>1</Number>' + CRLF
	cXML += '    </Pane>' + CRLF
	cXML += '    <Pane>' + CRLF
	cXML += '     <Number>2</Number>' + CRLF
	cXML += '    </Pane>' + CRLF
	cXML += '    <Pane>' + CRLF
	cXML += '     <Number>0</Number>' + CRLF
	cXML += '    </Pane>' + CRLF
	cXML += '   </Panes>' + CRLF
	cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += '  </WorksheetOptions>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	cXMLDo += EncodeUTF8(cXML)
	cXML := ""
	
	// Inicio // fQuadro10f -> "Compras - Genericos"
		 cXMLCab := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		 // cXMLCab += ' <Names>'
		 // cXMLCab += '   <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=' + "'Lotes - Analitico'" + '!R3C1:R' + AllTrim(Str( Len(_aDados)+3 )) + 'C51" ss:Hidden="1"/>'
		 // cXMLCab += ' </Names>'
		 cXMLCab += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
		 cXMLCab += '    <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="129.75"/>' + CRLF
		 cXMLCab += '    <Column ss:AutoFitWidth="0" ss:Width="58.5" ss:Span="3"/>' + CRLF
		 cXMLCab += '    <Column ss:Index="6" ss:AutoFitWidth="0" ss:Width="88.5" ss:Span="8"/>' + CRLF
		 cXMLCab += ' <Row ss:Height="36">' + CRLF
		 cXMLCab += '   <Cell ss:MergeAcross="12" ss:StyleID="s62">' + CRLF
		 // cXMLCab += '     <Data ss:Type="String">' + cTitulo + " de " + DtoC(MV_PAR01) + " até " + DtoC(MV_PAR02) + '</Data>' + CRLF
		 cXMLCab += '     <Data ss:Type="String">Formação do Preço Médio das Compras nos Últimos 120 dias</Data>' + CRLF
		 cXMLCab += '   </Cell>' + CRLF
		 cXMLCab += ' </Row>' + CRLF
		 cXMLCab += ' <Row ss:Height="16.5">' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s62"/>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  	<Cell ss:StyleID="s65"><Data ss:Type="String">Nota Fiscal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '  </Row>' + CRLF
		 cXMLCab += '   <Row ss:Height="33">' + CRLF
/* 01 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Concatenado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 01 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Sexo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Descricao</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Raca</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cabeças NF</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Gado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Gado + Complemento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Frete</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ Comissão</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ ICMS Frete</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ ICMS GADO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ TOTAL GADO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ CABECA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */ cXMLCab += '    <Cell ss:StyleID="s65"><Data ss:Type="String">ICMS x Cabeça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += '   </Row>' + CRLF

	cXML := EncodeUTF8(cXMLCab) + cXMLDo
	If !Empty(cXML)
		// FWrite(nHandle, EncodeUTF8( cXMLCab + cXML ) )
		FWrite(nHandle, cXML )
	EndIf
	cXML := ""	
	
EndIf

return n10fTotQd
// Quadro10f

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:  CalculaCusto()          	            	            				  |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  20/09/2018	            	          	            	              |
 | Desc:  Gerar variavel para SQL;	            	            				  |
 |         	            	                                                      |
 | Obs.:  -	            	                                                      |
 '-------------------------------------------------------------------------------*/
Static Function CalculaCusto( dtEntrada, dtAbate, _aMatCOD )
Local xCalendar := { { 01, "31/01/XXXX"} ,;
					 { 02, "28/02/XXXX"} ,;
					 { 03, "31/03/XXXX"} ,;
					 { 04, "30/04/XXXX"} ,;
					 { 05, "31/05/XXXX"} ,;
					 { 06, "30/06/XXXX"} ,;
					 { 07, "31/07/XXXX"} ,;
					 { 08, "31/08/XXXX"} ,;
					 { 09, "30/09/XXXX"} ,;
					 { 10, "31/10/XXXX"} ,;
					 { 11, "30/11/XXXX"} ,;
					 { 12, "31/12/XXXX"} }
Local nCusto    := 0
Local nMesIni   := 0 // Val( SubS( dtEntrada, 5,2 ) )
Local nMesFim   := 0 // Val( SubS( dtAbate  , 5,2 ) )
Local nI 	    := 0 // nMesIni

Local nTot 		:= 0, nToDias := 0
Local aMat      := {}
Local lContinua := .T.
Local cAno		:= SubS(dtEntrada, 1 ,4)
Local nDiaria	:= 0

If !Empty(dtEntrada) .and. !Empty(dtAbate) 

    nMesIni := Val( SubS( dtEntrada, 5, 2 ) )
    nMesFim := Val( SubS( dtAbate  , 5, 2 ) )
    nI 	  	:= nMesIni

	While lContinua // nI <= nMesFim

		If nI == nMesIni // é o primeiro
			
			If SubS(dtEntrada,1,6) == SubS(dtAbate,1,6)
				nQtDias := sToD(dtAbate) - sToD(dtEntrada)
			Else
				nQtDias := cToD( StrTran(xCalendar[nI,2], "XXXX", cAno ) ) - sToD(dtEntrada)
			EndIf
		
		ElseIf nI == nMesFim // é o ultimo
			
			if nI == 1 // é o mes de JANEIRO
				nQtDias := sToD(dtAbate) - sToD( AllTrim(Str(Val(SubS(dtAbate,1,4))-1)) + "1231" )
			Else
				nQtDias := sToD(dtAbate) - cToD( StrTran(xCalendar[nI-1,2], "XXXX", cAno ) )
			EndIf
			
		Else
			
			if nI == 1 // é o mes de JANEIRO
				nQtDias := 31
			Else
				nQtDias := cToD( StrTran(xCalendar[nI,2], "XXXX", cAno ) ) - cToD( StrTran(xCalendar[nI-1,2], "XXXX", cAno) )
			EndIf
			
		EndIf
		
		// nPos := aScan( _aMatCOD, { |x| x[1] == SubS( dtEntrada, 1, 4) + StrZero(nI,2) } ) 
		nPos := aScan( _aMatCOD, { |x| x[1] == cAno + StrZero(nI,2) } )
		If nPos>0 .AND. nPos<=Len(_aMatCOD)
			If AT( ",", _aMatCOD[ nPos, 2 ]) == 0
				nDiaria := Val(_aMatCOD[ nPos, 2 ])
			Else
				nDiaria := Val( StrTran( _aMatCOD[ nPos, 2 ], ",", "." ) )
			EndIf
			
			aAdd( aMat, { nQtDias, Iif( nPos==0, 0, nQtDias * nDiaria ) } )
		// Else
			// Alert('Pos: '+cValToChar(nPos) + ' - Len(_aMatCOD): ' + cValTochar(Len(_aMatCOD)))
		EndIf
		lContinua := nI <> nMesFim // Qdo for igual, sera a ultima vez que vai calcular
		
		nI += 1
		If nI == 13
			nI := 1
			cAno := Soma1(cAno)
		EndIf
		
	EndDo

	For nI := 1 to Len( aMat )
		nTot    += aMat[ nI, 02]
		nToDias += aMat[ nI, 01]
	Next nI

	nCusto := nTot / nToDias
EndIf

Return nCusto



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()             	            	      |
 | Func:  defFornecedor()         	            	            				  |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  26.09.2018	            	          	            	              |
 | Desc:  Gerar variavel para SQL;	            	            				  |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '-------------------------------------------------------------------------------*/
Static Function defFornecedor( _aMatCOD, cBaia )
Local cRet 		:= ""
Local cFornec 	:= ""

if ( nI := aScan( _aMatCOD, { |x| AllTrim(x[1]) == AllTrim(cBaia) } ) ) > 0
	While nI <= Len(_aMatCOD) .and. AllTrim(_aMatCOD[ nI, 1 ]) == AllTrim(cBaia)
		
		cFornec := AllTrim(SubS( _aMatCOD[ nI, 2], 1, At( " ", _aMatCOD[ nI, 2],(At( " ", _aMatCOD[ nI, 2] )+1) ) ))
		If Subs(cFornec, -2) $ ("DA,DE,DO")
			cFornec := AllTrim(SubS( _aMatCOD[ nI, 2], 1, At( " ", _aMatCOD[ nI, 2],(At( " ", _aMatCOD[ nI, 2] )+1)+(At( " ", _aMatCOD[ nI, 2] )+1) ) ) )
		EndIf
		If At( cFornec, cRet) == 0
			cRet += Iif(Empty(cRet),"", " | " ) + cFornec
		EndIf

		nI += 1
	EndDo
EndIf	

Return cRet

// 902888149

// [\r\n]\s[\r\n]
// 01515117001831541398410
