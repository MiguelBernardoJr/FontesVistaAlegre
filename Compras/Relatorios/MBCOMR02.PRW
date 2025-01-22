#INCLUDE "PROTHEUS.CH"


/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBCOMR02()          		            	  |
 | Func:  MBCOMR02()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  31.08.2020	            	          	            	              |
 | Desc:  Relatório criado para listar as configurações definidas para o Contrato |
 |      do milho; Especifica os campos com as definições de descontos a partir da |
 |      medção de UMIDADE e IMPURESAS;                                            |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
 '--------------------------------------------------------------------------------*/
User Function MBCOMR02()

Local cTimeIni	 	:= Time()
Local lTemDados		:= .T.
Local cStyle		:= ""
Local cXML	   		:= ""

Private cPerg		:= "MBCOMR01"
Private cTitulo  	:= "Relatorio Lotes de Compra - Analise"

Private cPath 	 	:= "C:\totvs_relatorios\"

Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()
Private _nRegAba1	:= 0

Private nHandle    	:= 0
Private nHandAux	:= 0

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
		
		cStyle := U_defStyle()
		
		// Processar SQL
		FWMsgRun(, {|| lTemDados := procesaSQL("Geral", @_cAliasG ) },;
                        'Por Favor Aguarde...',;
                        'Processando Banco de Dados')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fPrintAba1() },'Gerando excel, Por Favor Aguarde...',;
                                     'Geração do quadro de Notas Fiscais')
			
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
		
		If lower(cUserName) $ 'mbernardo,atoshio,admin,administrador'
			Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
		EndIf
		
		ConOut('Activate: ' + Time())
	EndIf
EndIf

Return nil


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAFINM01()                                      |
 | Func:  defStyle()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  17.10.2018                                                              |
 | Desc:  Gerar variavel para SQL;                                                |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function defStyle()
	
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
	cStyle += ' <Style ss:ID="s65Data">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += ' 	<Borders>'+CRLF
	cStyle += ' 		<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#37752F"/>'+CRLF
	cStyle += ' 		<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#37752F"/>'+CRLF
	cStyle += ' 	</Borders>'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>'+CRLF
	cStyle += ' 	<Interior ss:Color="#37752F" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' 	<NumberFormat ss:Format="Short Date"/>'+CRLF
	cStyle += ' </Style>'+CRLF
    cStyle += ' <Style ss:ID="s86">'+CRLF
    cStyle += '     <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
    cStyle += '     <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
    cStyle += '      ss:Color="#000000" ss:Bold="1"/>'+CRLF
    cStyle += ' </Style>'+CRLF
    cStyle += ' <Style ss:ID="s87">'+CRLF
    cStyle += '     <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
    cStyle += '     <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
    cStyle += '      ss:Color="#000000" ss:Bold="1"/>'+CRLF
    cStyle += '     <NumberFormat ss:Format="Short Date"/>'+CRLF
    cStyle += ' </Style>'+CRLF
    cStyle += '<Style ss:ID="s80" ss:Parent="s16">'+CRLF
    cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
    cStyle += '  ss:Color="#000000" ss:Bold="1"/>'+CRLF
    cStyle += '</Style>	'+CRLF
    cStyle += '<Style ss:ID="s82" ss:Parent="s16">'+CRLF
    cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
    cStyle += '  ss:Color="#000000" ss:Bold="1"/>'+CRLF
    cStyle += ' <NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>'+CRLF
    cStyle += '</Style>	'+CRLF

    cStyle += '<Style ss:ID="s88">'+CRLF
    cStyle += '     <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
    cStyle += '     ss:Color="#000000" ss:Bold="1"/>'+CRLF
    cStyle += '</Style>'+CRLF
	cStyle += ' <Style ss:ID="sFundoAzul">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += '    <Borders>'+CRLF
	cStyle += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"'+CRLF
	cStyle += '      ss:Color="#37752F"/>'+CRLF
	cStyle += '     <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"'+CRLF
	cStyle += '      ss:Color="#37752F"/>'+CRLF
	cStyle += '    </Borders>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '     ss:Color="#FFFFFF" ss:Bold="1"/>'+CRLF
	cStyle += '    <Interior ss:Color="#4472C4" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += '  <Style ss:ID="sTexto">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '  <Style ss:ID="sTextoRot">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:Rotate="90"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
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
	cStyle += ' <Style ss:ID="sTextoSC">'+CRLF // Sem Cor
    cStyle += '   <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"/>'+CRLF
    cStyle += '   <NumberFormat ss:Format="@"/>'+CRLF
    cStyle += ' </Style>'+CRLF
	cStyle += '  <Style ss:ID="sData">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '     ss:Color="#000000"/>'+CRLF
	cStyle += '    <NumberFormat ss:Format="Short Date"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '  <Style ss:ID="sDataMMMAAAA" ss:Parent="s16">'+CRLF
    cStyle += '    <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>'+CRLF
    cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
    cStyle += '    <NumberFormat ss:Format="mmm/yyyy"/>'+CRLF
    cStyle += '  </Style>'+CRLF
	cStyle += ' <Style ss:ID="sHoraCurta">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += ' 	<NumberFormat ss:Format="h:mm;@"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sHoraCurtaN">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += ' 	<NumberFormat ss:Format="h:mm;@"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sHoraCurtaH">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += ' 	<NumberFormat ss:Format="[h]:mm"/>'+CRLF
	cStyle += ' </Style>'+CRLF
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
	cStyle += ' <Style ss:ID="s75">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += ' 	<Borders/>'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>'+CRLF
	cStyle += ' 	<Interior ss:Color="#37752F" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s77">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sDataHoraFull">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
	cStyle += ' 	<NumberFormat ss:Format="dd/mm/yyyy\ hh:mm;@"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="sDataCenter">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+CRLF
	cStyle += ' 	<Borders/>'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="20" ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += ' 	<NumberFormat ss:Format="Short Date"/>'+CRLF
	cStyle += ' </Style>'+CRLF
Return cStyle
// defStyle


/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBCOMR02()          		            	  |
 | Func:  GeraX1(cPerg)	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  31.08.2020	            	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
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

aAdd(aRegs,{cPerg, "01", "Data Compra De?" , "", "", "MV_CH1", "D", TamSX3("D1_EMISSAO")[1], TamSX3("D1_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR01", "", "", "", ""      , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", "", "", "", "", ""})
aAdd(aRegs,{cPerg, "02", "Data Compra Ate?", "", "", "MV_CH2", "D", TamSX3("D1_EMISSAO")[1], TamSX3("D1_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR02", "", "", "", ""      , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", "", "", "", "", ""})
aAdd(aRegs,{cPerg, "03", "Armazem De?"     , "", "", "MV_CH3", "C", TamSX3("D1_LOCAL")[1]  , TamSX3("D1_LOCAL")[2]  , 0, "G", ""		, "MV_PAR03", "", "", "", ""      , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", "", "", "", "", ""})
aAdd(aRegs,{cPerg, "04", "Armazem Ate?"    , "", "", "MV_CH4", "C", TamSX3("D1_LOCAL")[1]  , TamSX3("D1_LOCAL")[2]  , 0, "G", "NaoVazio", "MV_PAR04", "", "", "", "ZZ"    , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", "", "", "", "", ""})
aAdd(aRegs,{cPerg, "05", "Contrato De?"    , "", "", "MV_CH5", "C", TamSX3("ZBC_CODIGO")[1], TamSX3("ZBC_CODIGO")[2], 0, "G", ""		, "MV_PAR05", "", "", "", ""      , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "ZBC", "", "", "", "", ""})
aAdd(aRegs,{cPerg, "06", "Contrato Ate?"   , "", "", "MV_CH6", "C", TamSX3("ZBC_CODIGO")[1], TamSX3("ZBC_CODIGO")[2], 0, "G", "NaoVazio", "MV_PAR06", "", "", "", "ZZZZZZ", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "ZBC", "", "", "", "", ""})
aAdd(aRegs,{cPerg, "07", "Fornecedor De?"  , "", "", "MV_CH7", "C", TamSX3("D1_FORNECE")[1], TamSX3("D1_FORNECE")[2], 0, "G", ""		, "MV_PAR05", "", "", "", ""      , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA2", "", "", "", "", ""})
aAdd(aRegs,{cPerg, "08", "Fornecedor Ate?" , "", "", "MV_CH8", "C", TamSX3("D1_FORNECE")[1], TamSX3("D1_FORNECE")[2], 0, "G", "NaoVazio", "MV_PAR06", "", "", "", "ZZZZZZ", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA2", "", "", "", "", ""})

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
 | Principal: 					     U_MBCOMR02()          		            	  |
 | Func:  procesaSQL(cTipo, _cAlias)            	          	            	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  31.08.2020	            	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
 '--------------------------------------------------------------------------------*/
Static Function procesaSQL(cTipo, _cAlias)
Local _cQry 		:= ""

_cQry := "     SELECT D1_FILIAL, ZBC_CODIGO AS NCONTRATO, D1_FORNECE, A2_NOME, A2_MUN, A2_EST,  --, ZBC_VLRSAC,  " + CRLF
_cQry += "             D1_EMISSAO, D1_DTDIGIT, D1_DOC, D1_SERIE, D1_COD, B1_DESC, D1_QUANT, D1_TOTAL, D1_X_PESOB, D1_X_UMIDA, D1_XPERDUM, D1_XPAVAIR, D1_XKGAVAI, D1_X_KGUMI, D1_X_IMPUR, D1_X_KGIMP, D1_X_PESOL, D1_LOCAL, NNR_DESCRI, " + CRLF
_cQry += "             D1_VLSENAR, D1_VALINS, D1_VALFUN, F1_MENNOTA " + CRLF
_cQry += "           , CASE WHEN F1_ESPECIE = 'S' THEN 'PROPRIA' ELSE  'NF PRODUTOR' END F1_ESPECIE  " + CRLF
_cQry += "             --SFT.FT_VLSENAR, SFT.FT_VALINS, FT_VALFUN " + CRLF
_cQry += CRLF
_cQry += "     FROM  SD1010 D1 " + CRLF
_cQry += "      JOIN SF1010 F1  ON F1.F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_EMISSAO = D1.D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_EMISSAO AND F1.D_E_L_E_T_ = ' ' " + CRLF
_cQry += "      JOIN SA2010 A2  ON A2_COD+A2_LOJA = D1_FORNECE+D1_LOJA AND A2.D_E_L_E_T_ = ' '  " + CRLF
_cQry += "      JOIN SB1010 B1  ON D1_COD = B1_COD AND B1.D_E_L_E_T_ = ' ' " + CRLF
_cQry += "      JOIN NNR010 NNR ON D1_FILIAL = NNR_FILIAL AND NNR_CODIGO = D1_LOCAL AND NNR.D_E_L_E_T_ = ' '  " + CRLF
_cQry += "      -- JOIN SFT010 SFT ON FT_FILIAL = D1_FILIAL AND FT_CLIEFOR = D1_FORNECE AND FT_LOJA = D1_LOJA AND FT_NFISCAL = D1_DOC AND FT_EMISSAO = D1_EMISSAO AND FT_ITEM = D1_ITEM AND SFT.D_E_L_E_T_ = ' ' " + CRLF
_cQry += " LEFT JOIN ZBC010 ZBC ON ZBC_FILIAL = D1_FILIAL AND D1_FORNECE+D1_LOJA = ZBC_CODFOR+ZBC_LOJFOR AND D1_PEDIDO = ZBC_PEDIDO AND ZBC.D_E_L_E_T_ = ' '  " + CRLF
_cQry += CRLF
_cQry += "     WHERE D1_FILIAL = '" + xFilial("SD1") + "'  " + CRLF
_cQry += "       AND D1_EMISSAO BETWEEN '" + dToS(MV_PAR01) + "' AND '" + dToS(MV_PAR02) + "' " + CRLF
_cQry += "       AND D1_COD = '" + GetMV("MB_COMM12B",,"020017") + "' " + CRLF
_cQry += "       AND D1.D1_LOCAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + CRLF
_cQry += "       AND ZBC_CODIGO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CRLF

if !(Empty(MV_PAR07) .and. (Empty(MV_PAR08) .or. MV_PAR08=="ZZZZZZ"))
    _cQry += "       -- SE PARAMETRO FOR VAZIO NAO CONSIDERA  " + CRLF
    _cQry += "       AND D1_FORNECE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " + CRLF
EndIf

_cQry += "       AND D1.D_E_L_E_T_ = ' '  " + CRLF
_cQry += CRLF
_cQry += " ORDER BY D1_FILIAL, ZBC_CODIGO, D1_FORNECE, D1_DTDIGIT "

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

TcSetField(_cAlias, "D1_EMISSAO", "D")
TcSetField(_cAlias, "D1_DTDIGIT", "D")
// TcSetField(_cAlias	, "D1_X_CHEDT", "D")

Return !(_cAlias)->(Eof())
// FIM: procesaSQL()



/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBCOMR02()          		            	  |
 | Func: fPrintAba1()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  31.08.2020	            	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
 '--------------------------------------------------------------------------------*/
Static Function fPrintAba1()

Local cXML 			:= ""
Local cWorkSheet 	:= "Notas Fiscais"
Local cChave        := ""
local nLin 			:= 0

(_cAliasG)->(DbEval({|| _nRegAba1++ }))

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	cXML := U_prtCellXML( 'Worksheet', cWorkSheet )
	cXML += U_prtCellXML( 'Table' )
	
    cXML += '<Column ss:Width="60.75"/>'
    cXML += '<Column ss:Width="51.75"/>'
    cXML += '<Column ss:Width="60"/>'
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="45"/>'
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="45"/>'
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="45"/>'
    cXML += '<Column ss:Width="45.75"/>'
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="57.75"/>'
    cXML += '<Column ss:Width="47.25"/>'
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="48.75"/>'
    cXML += '<Column ss:Width="54"/>'
    cXML += '<Column ss:Width="45"/>'
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="60.75" ss:Span="1"/>'
    cXML += '<Column ss:Index="15" ss:Width="52.5"/>'
    cXML += '<Column ss:Width="70.5"/>'
    cXML += '<Column ss:Index="18" ss:AutoFitWidth="0" ss:Width="58.5"/>'
    cXML += '<Column ss:Width="47.25"/>'
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="57.75" ss:Span="2"/>'
    cXML += '<Column ss:Index="23" ss:AutoFitWidth="0" ss:Width="257.25"/>'
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="58.5"/>'
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="405"/>'
    cXML += '<Column ss:Width="60"/>'

	cXML += U_prtCellXML( 'Titulo',,'33',,'20','s62','String', /*cFormula*/, cTitulo )
	
	//fPrintAba1
	While !(_cAliasG)->(Eof())	 // U_MBCOMR01()
		If nLin > 0 .And. cChave <> (_cAliasG)->D1_FILIAL+(_cAliasG)->NCONTRATO+(_cAliasG)->D1_FORNECE
			cXML += U_prtCellXML( 'Row')
			cXML += '<Cell ss:StyleID="s86"/>'
            cXML += '<Cell ss:StyleID="s87"/>'
            cXML +=  U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s82', 'Number', "=SUM(R[-"+Alltrim(str(nLin))+"]C:R[-1]C)" /*cFormula*/,,,.T. )//'<Cell ss:StyleID="s80" ss:Formula="=SUM(R[-8]C:R[-1]C)"><Data ss:Type="Number">416260</Data></Cell>'
            cXML += '<Cell ss:StyleID="s80"/>'
            cXML += '<Cell ss:StyleID="s80"/>'
            cXML += '<Cell ss:StyleID="s80"/>'
            cXML +=  U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s82', 'Number', "=SUM(R[-"+Alltrim(str(nLin))+"]C:R[-1]C)" /*cFormula*/,,,.T. )
            cXML += '<Cell ss:StyleID="s80"/>'
            cXML += '<Cell ss:StyleID="s80" ss:Formula="=SUM(R[-8]C:R[-1]C)"><Data ss:Type="Number">10192.86</Data></Cell>'
            cXML += '<Cell ss:StyleID="s80"/>'
            cXML += '<Cell ss:StyleID="s80"/>'
            cXML +=  U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s82', 'Number', "=SUM(R[-"+Alltrim(str(nLin))+"]C:R[-1]C)" /*cFormula*/,,,.T. )
			cXML +=  U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s82', 'Number', "=SUM(R[-"+Alltrim(str(nLin))+"]C:R[-1]C)" /*cFormula*/,,,.T. )
			cXML +=  U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sRealN', 'Number', "=SUM(R[-"+Alltrim(str(nLin))+"]C:R[-1]C)" /*cFormula*/,,,.T. )
            cXML += '<Cell ss:StyleID="s80"/>'
            cXML += '<Cell ss:StyleID="s80"/>'
            cXML += '<Cell ss:StyleID="s86"/>'
            cXML +=  U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sRealN', 'Number', "=SUM(R[-"+Alltrim(str(nLin))+"]C:R[-1]C)" /*cFormula*/,,,.T. )
            cXML +=  U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sRealN', 'Number', "=SUM(R[-"+Alltrim(str(nLin))+"]C:R[-1]C)" /*cFormula*/,,,.T. )
            cXML +=  U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sRealN', 'Number', "=SUM(R[-"+Alltrim(str(nLin))+"]C:R[-1]C)" /*cFormula*/,,,.T. )
            cXML += '<Cell ss:StyleID="s86"/>'
			cXML += '</Row>'
			cXML += U_prtCellXML( 'Row' )
			cXML += '</Row>'
			cXML += U_prtCellXML( 'Row' )
			cXML += '</Row>'
			nLin = 0
		EndIf
        
		If cChave <> (_cAliasG)->D1_FILIAL+(_cAliasG)->NCONTRATO+(_cAliasG)->D1_FORNECE
            
			
            cChave := (_cAliasG)->D1_FILIAL+(_cAliasG)->NCONTRATO+(_cAliasG)->D1_FORNECE
            
            cXML += U_prtCellXML( 'Row',,'33' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s65', 'String', /*cFormula*/, 'Filial' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s65', 'String', /*cFormula*/, 'Numero Contrato' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s65', 'String', /*cFormula*/, 'Cod Fornecedor' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/"3",'s65', 'String', /*cFormula*/, 'Fornecedor' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/"2",'s65', 'String', /*cFormula*/, 'Municipio' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s65', 'String', /*cFormula*/, 'Estado' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s65', 'String', /*cFormula*/, 'Cod. Prod.' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/"2",'s65', 'String', /*cFormula*/, 'Desc. Prod.' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s65', 'String', /*cFormula*/, 'Nota Própria?' )
            cXML += U_prtCellXML( '</Row>' )

       		cXML += U_prtCellXML( 'Row' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   , 'sTexto', 'String'  , /*cFormula*/, (_cAliasG)->D1_FILIAL )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   , 'sTexto', 'String'  , /*cFormula*/, (_cAliasG)->NCONTRATO )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   , 'sTexto', 'String'  , /*cFormula*/, (_cAliasG)->D1_FORNECE )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/"3", 'sTexto', 'String'  , /*cFormula*/, (_cAliasG)->A2_NOME )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/"2", 'sTexto', 'String'  , /*cFormula*/, (_cAliasG)->A2_MUN )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   , 'sTexto', 'String'  , /*cFormula*/, (_cAliasG)->A2_EST )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   , 'sTexto' , 'String' , /*cFormula*/, (_cAliasG)->D1_COD     )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/"2", 'sTexto' , 'String' , /*cFormula*/, (_cAliasG)->B1_DESC    )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/"2", 'sTexto' , 'String' , /*cFormula*/, (_cAliasG)->F1_ESPECIE    )
			cXML += U_prtCellXML( '</Row>' )
			
            
            cXML += U_prtCellXML( 'Row',,'33' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Nota Fiscal' )
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Serie NF' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dt. Emissao' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Quant NF.' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Bruto' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtde de Sacas' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, '% Umidade' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, '% Desconto Umidade' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'KG Umidade' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, '% Impureza' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'KG Impureza' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, '% Avaria' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'KG Avaria' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Liquido' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtde de Sacas' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$  Total' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$  KG' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$  Saca' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Armazém' )
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Arm. Descri.' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$ Senar' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$ INSS' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$ GILRAT' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Observação' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dt Lancto NF' )
            cXML += U_prtCellXML( '</Row>' )
        
		EndIf

		cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto' , 'String'  , /*cFormula*/, (_cAliasG)->D1_DOC+"-"+(_cAliasG)->D1_SERIE )
		//cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto' , 'String'  , /*cFormula*/, (_cAliasG)->D1_SERIE)
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sData'  , 'DateTime', /*cFormula*/,  (_cAliasG)->D1_EMISSAO)
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sSemDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_QUANT   )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_X_PESOB )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_QUANT-(_cAliasG)->D1_X_PESOB )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_X_PESOB/60 )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_X_UMIDA )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_XPERDUM )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_X_KGUMI )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_X_IMPUR )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_X_KGIMP )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_XPAVAIR )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_XKGAVAI )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_X_PESOL )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_X_PESOL/60 )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasG)->D1_TOTAL   )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sReal', 'Number'  , /*cFormula*/, (_cAliasG)->D1_TOTAL/(_cAliasG)->D1_X_PESOL   )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sReal', 'Number'  , /*cFormula*/, (_cAliasG)->D1_TOTAL/((_cAliasG)->D1_X_PESOL/60)   )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto' , 'String'  , /*cFormula*/, (_cAliasG)->D1_LOCAL   )
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto' , 'String'  , /*cFormula*/, (_cAliasG)->NNR_DESCRI )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sReal', 'Number'  , /*cFormula*/, (_cAliasG)->D1_VLSENAR )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sReal', 'Number'  , /*cFormula*/, (_cAliasG)->D1_VALINS  )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sReal', 'Number'  , /*cFormula*/, (_cAliasG)->D1_VALFUN  )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto' , 'String'  , /*cFormula*/, (_cAliasG)->F1_MENNOTA )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sData'  , 'DateTime', /*cFormula*/,  (_cAliasG)->D1_DTDIGIT)
        cXML += U_prtCellXML( '</Row>' )
	    nLin++
        (_cAliasG)->(DbSkip())
		
    EndDo
    
	// cPanes := '   <Selected/>' + CRLF
	// cPanes += '   <Panes>' + CRLF
	// cPanes += '    <Pane>' + CRLF
	// cPanes += '     <Number>3</Number>' + CRLF
	// cPanes += '     <ActiveRow>5</ActiveRow>' + CRLF
	// cPanes += '    </Pane>' + CRLF
	// cPanes += '   </Panes>' + CRLF
    cXML += U_prtCellXML( 'WorksheetOptions',,,,,,,,, /* cPanes */ )
	
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
	
EndIf

Return nil
// FIM: fPrintAba1
