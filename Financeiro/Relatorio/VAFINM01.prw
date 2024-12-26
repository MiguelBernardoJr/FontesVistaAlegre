#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

// #DEFINE DMPAPER_A4 	9
// #DEFINE PAD_RIGHT 	1 

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAFINM01()                                      |
 | Func:  VAFINM01()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  17.10.2018                                                              |
 | Desc:  Impressão Relatorio: Compra Gado - Projeção Pagamento Futuro;           |
 '--------------------------------------------------------------------------------|
 | Alt:                                                                           |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAFINM01()	// U_VAFINM01()
Local cTimeIni	 	:= Time()
Local lTemDados		:= .T.

Private cPerg		:= "VAFINM01"
Private cTitulo  	:= "Relatorio Lotes de Compra"

Private cPath 	 	:= "C:\totvs_relatorios\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()   

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
		conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	else
		
		cStyle := defStyle()
		
		// Processar SQL
		FWMsgRun(, {|| lTemDados := VASqlM01("Geral", @_cAliasG ) },'Por Favor Aguarde...' , 'Processando Banco de Dados')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Lotes Analitico')
			
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
 | Principal: 					U_VAFINM01()                                      |
 | Func:  defStyle()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  17.10.2018                                                              |
 | Desc:  Gerar variavel para SQL;                                                |
 |                                                                                |
 | Obs.:  -                                                                       |
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
	cStyle += ' <Style ss:ID="s75">
	cStyle += ' 	<Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>
	cStyle += ' 	<Borders/>
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>
	cStyle += ' 	<Interior ss:Color="#37752F" ss:Pattern="Solid"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="s77">
	cStyle += ' 	<Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
	cStyle += ' </Style>
	
Return cStyle
// defStyle


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAFINM01()                                      |
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

aAdd(aRegs,{cPerg, "01", "Data Vencto De?"      , "", "", "MV_CH1", "D", TamSX3("ZCC_DTVCTO")[1], TamSX3("ZCC_DTVCTO")[2], 0, "G", "NaoVazio", "MV_PAR01", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Data Vencto Ate?"     , "", "", "MV_CH2", "D", TamSX3("ZCC_DTVCTO")[1], TamSX3("ZCC_DTVCTO")[2], 0, "G", "NaoVazio", "MV_PAR02", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "03", "Data Valor?"		    , "", "", "MV_CH3", "D", TamSX3("ZSI_DATA")[1]  , TamSX3("ZSI_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR03", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","ZSI","","","","",""})
aAdd(aRegs,{cPerg, "04", "Codigo?"        		, "", "", "MV_CH4", "C", TamSX3("ZCI_CODIGO")[1], TamSX3("ZCI_CODIGO")[2], 0, "G", "NaoVazio", "MV_PAR04", ""   , "","",""  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "05", "Valor?"        		, "", "", "MV_CH5", "C", TamSX3("ZSI_VALOR")[1] , TamSX3("ZSI_VALOR")[2] , 0, "G", "NaoVazio", "MV_PAR05", ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
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



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAFINM01()                                      |
 | Func:  VASqlM01()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  17.10.2018                                                              |
 | Desc:  Processamento do SQL, salvando em variavel PRIVADA;                     |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function VASqlM01(cTipo, _cAlias)
Local _cQry 		:= ""

If cTipo == "Geral"

	_cQry := " " + CRLF
	_cQry += "   WITH PRINCIPAL AS (  " +CRLF
	_cQry += "   SELECT  DISTINCT  " +CRLF
	_cQry += "   		  ZBC_FILIAL  " +CRLF
	_cQry += "  		, ZBC_CODFOR  " +CRLF
	_cQry += "  		, ZBC_LOJFOR  " +CRLF
	_cQry += "   		, ZCC_NOMFOR   " +CRLF
	_cQry += "  		, ZBC_PEDIDO  " +CRLF
	_cQry += "   		, SUM(ZBC_QUANT)ZBC_QUANT  " +CRLF
	_cQry += "  		--, SUM(ZBC_QUANT) QTD_CONTRATO  " +CRLF
	_cQry += "  		--, AVG(ZCC_QTTTAN) ZCC_QTTTAN   " +CRLF
	_cQry += "   		--, AVG(ZCC_QTDRES) ZCC_QTDRES   " +CRLF
	_cQry += "   		, ZBC_DTENTR   " +CRLF
	_cQry += "   		, ZCC_DTVCTO   " +CRLF
	_cQry += "   		, ZCC_CODIGO, ZCC_STATUS   " +CRLF
	_cQry += "   		-- , ZBC_PESO   " +CRLF
	_cQry += "   		, SUM(ZBC_PESO) ZBC_PESO -- , SUM(CAST(REPLACE(ZBC_PESO,',','.') AS decimal(15,2))) ZBC_PESO   " +CRLF
	_cQry += "   		, ZBC_REND    " +CRLF
	_cQry += "  		  " +CRLF
	_cQry += "   		, ZBC_ARROV = (SELECT ZSI_VALOR   " +CRLF
	_cQry += "   				FROM ZSI010 SI   " +CRLF
	_cQry += "   				JOIN ZCI010 CI ON ZSI_FILIAL=ZCI_FILIAL AND ZSI_CODIGO=ZCI_CODIGO     " +CRLF
	_cQry += "   									AND ZCI_COTGAD='S' AND SI.D_E_L_E_T_=' ' AND CI.D_E_L_E_T_=' '   " +CRLF
	_cQry += "   				WHERE	ZSI_DATA='" + DtoS(MV_PAR03) + "' " + CRLF
	_cQry += "   					AND ZCI_CODIGO='" + MV_PAR04 + "' " + CRLF
	_cQry += "   		)   " +CRLF
	_cQry += "   		-- CALCULADOS   " +CRLF
	_cQry += "   		-- , SUM(ZBC_PESO) * (ZBC_REND/100) * (AVG(ZBC_ARROV)/15) VALOR   " +CRLF
	_cQry += "   		-- , SUM(ZBC_PESO) * (ZBC_REND/100) * (AVG(ZBC_ARROV)/15) / SUM(ZCC_QTTTAN) 'R$ CABEÇA'   " +CRLF
	_cQry += "   FROM ZCC010 CC   " +CRLF
	_cQry += "   JOIN ZBC010 BC ON ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO AND ZCC_VERSAO=ZBC_VERSAO   " +CRLF
	_cQry += "   					AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN    " +CRLF
	_cQry += "   						(    " +CRLF
	_cQry += "   							SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED)    " +CRLF
	_cQry += "   							FROM ZBC010    " +CRLF
	_cQry += "   							WHERE D_E_L_E_T_=' '    " +CRLF
	_cQry += "   							GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC    " +CRLF
	_cQry += "   						)    " +CRLF
	_cQry += "   					AND CC.D_E_L_E_T_=' '   " +CRLF
	_cQry += "   					AND BC.D_E_L_E_T_=' '   " +CRLF
	_cQry += "    " +CRLF
	_cQry += "    " +CRLF
	_cQry += "  				  " +CRLF
	_cQry += "   WHERE	ZCC_PAGFUT='S' AND    " +CRLF
	_cQry += "   		(   " +CRLF
	_cQry += "   			ZCC_DTVCTO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'  " + CRLF
	_cQry += "   			OR   " +CRLF
	_cQry += "   			ZCC_DTVCTO = ' '    " +CRLF
	_cQry += "   		)   " +CRLF
	_cQry += "   GROUP BY   ZBC_FILIAL, ZBC_CODFOR, ZBC_LOJFOR, ZBC_PEDIDO, ZBC_CODIGO  " +CRLF
	_cQry += "   	, ZCC_NOMFOR   " +CRLF
	_cQry += "   	, ZBC_DTENTR   " +CRLF
	_cQry += "   	, ZCC_DTVCTO   " +CRLF
	_cQry += "   	, ZCC_CODIGO, ZCC_STATUS  " +CRLF
	_cQry += "   	, ZBC_REND   " +CRLF
	_cQry += "     " +CRLF
	_cQry += "   ),  " +CRLF
	_cQry += "    " +CRLF
	_cQry += "   DOC_ENTRADA AS (  " +CRLF
	_cQry += "   SELECT ZBC_FILIAL,  ZBC_CODFOR, ZBC_LOJFOR, ZCC_NOMFOR, SUM(D1_QUANT) QTDE, ZBC_QUANT,  ZBC_DTENTR, ZCC_DTVCTO, ZCC_CODIGO, ZCC_STATUS, ZBC_PESO, ZBC_REND, ZBC_ARROV  " +CRLF
	_cQry += "   --P.*--,   " +CRLF
	_cQry += "   FROM SD1010  D1  " +CRLF
	_cQry += "   JOIN PRINCIPAL P ON D1_FILIAL = P.ZBC_FILIAL   " +CRLF
	_cQry += "  			    AND D1_FORNECE = P.ZBC_CODFOR  " +CRLF
	_cQry += "  				AND D1_LOJA = P.ZBC_LOJFOR  " +CRLF
	_cQry += "  			    AND D1_PEDIDO = P.ZBC_PEDIDO  " +CRLF
	_cQry += "  				--AND D1_COD = ZBC_PROD  " +CRLF
	_cQry += "  				AND D1.D_E_L_E_T_ = ' '  " +CRLF
	_cQry += "  				 GROUP BY ZBC_FILIAL, ZBC_CODFOR, ZBC_LOJFOR, ZCC_NOMFOR, ZBC_QUANT, ZBC_DTENTR, ZCC_DTVCTO, ZCC_CODIGO, ZCC_STATUS, ZBC_PESO, ZBC_REND, ZBC_ARROV   " +CRLF
	_cQry += "    )  " +CRLF
	_cQry += "    " +CRLF
	_cQry += "    SELECT * FROM DOC_ENTRADA  " +CRLF
	_cQry += " ORDER BY ZCC_DTVCTO, ZCC_NOMFOR, ZBC_DTENTR " + CRLF
	

EndIf

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

TcSetField(_cAlias, "ZBC_DTENTR", "D")
TcSetField(_cAlias, "ZCC_DTVCTO", "D")

Return !(_cAlias)->(Eof())
// FIM: VASqlM01()



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()                                      |
 | Func:  fQuadro1()	                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  11.05.2018                                                              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1()	 // U_VACOMR07()

Local cXMLCab 		:= "", cXML := ""
Local cWorkSheet 	:= "Projeção Pagamento"

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	//fQuadro1
	While !(_cAliasG)->(Eof())	 // U_VACOMR07()

		 cXML += '<Row>' + CRLF
/* 06 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAliasG)->ZCC_CODIGO ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
/* 01 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAliasG)->ZBC_CODFOR + "-" + (_cAliasG)->ZCC_NOMFOR ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
/* 02 */ cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->QTDE ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 04 */ cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( (_cAliasG)->ZBC_DTENTR ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

If Empty((_cAliasG)->ZCC_DTVCTO)
/* 05 */ cXML += '  <Cell><Data ss:Type="String"></Data></Cell>' + CRLF
Else
/* 05 */ cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( (_cAliasG)->ZCC_DTVCTO ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
EndIf

/* 07 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->ZBC_PESO   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->ZBC_REND   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->ZBC_ARROV  ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=RC[-3]*RC[-2]/100*RC[-1]/15"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=RC[-1]/RC[-7]"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[-2]/RC[-5],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
/* 03 */ cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->ZBC_QUANT ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( iIf((_cAliasG)->ZCC_STATUS=="F","Fechado",iIf((_cAliasG)->ZCC_STATUS=="N","Lib. p/ Pedido","Aberto") ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
		 cXML += '</Row>' + CRLF
		 
		(_cAliasG)->(DbSkip())
	EndDo
	
	// Final da Planilha
	cXML += '</Table>
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
	cXML += '  <PageSetup>
	cXML += '  <Header x:Margin="0.31496062000000002"/>
	cXML += '  <Footer x:Margin="0.31496062000000002"/>
	cXML += '  <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>
	cXML += '  </PageSetup>
	cXML += '  <Unsynced/>
	cXML += '  <Selected/>
	cXML += '  <FreezePanes/>
	cXML += '  <FrozenNoSplit/>
	cXML += '  <SplitHorizontal>8</SplitHorizontal>
	cXML += '  <TopRowBottomPane>8</TopRowBottomPane>
	cXML += '  <ActivePane>2</ActivePane>
	cXML += '  <Panes>
	cXML += '  <Pane>
	cXML += '  <Number>3</Number>
	cXML += '  </Pane>
	cXML += '  <Pane>
	cXML += '  <Number>2</Number>
	cXML += '  <ActiveRow>12</ActiveRow>
	cXML += '  <ActiveCol>1</ActiveCol>
	cXML += '  </Pane>
	cXML += '  </Panes>
	cXML += '  <ProtectObjects>False</ProtectObjects>
	cXML += '  <ProtectScenarios>False</ProtectScenarios>
	cXML += '  </WorksheetOptions>
	cXML += '  <AutoFilter x:Range="R8C1:R1000C13" xmlns="urn:schemas-microsoft-com:office:excel">
	cXML += '  </AutoFilter>
	cXML += '</Worksheet>
	
	// Inicio // fQuadro1 -> "Projeção Pagto Futuro"
		 cXMLCab := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		 cXMLCab += '   <Names>
		 cXMLCab += '   	<NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=' + "'Projecao Pagamento'" +'!R8C1:R1000C13" ss:Hidden="1"/>
		 cXMLCab += '   </Names>
		 cXMLCab += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
		 cXMLCab += '    <Column ss:Width="69"/>
		 cXMLCab += '    <Column ss:Width="225.75"/>
		 cXMLCab += '    <Column ss:AutoFitWidth="0" ss:Width="65.25" ss:Span="4"/>
		 cXMLCab += '    <Column ss:Index="8" ss:Width="80.25" ss:Span="2"/>
		 cXMLCab += '    <Column ss:Index="11" ss:AutoFitWidth="0" ss:Width="89.25"/>
		 cXMLCab += '    <Column ss:Width="61.5"/>
		 cXMLCab += ' <Row ss:Height="36">' + CRLF
		 cXMLCab += '   <Cell ss:MergeAcross="11" ss:StyleID="s62">' + CRLF
		 cXMLCab += '     <Data ss:Type="String">Contrato de Compra - Projeção Pagamento Futuro</Data>' + CRLF
		 cXMLCab += '   </Cell>' + CRLF
		 cXMLCab += ' </Row>' + CRLF
		 cXMLCab += ' <Row ss:Height="24.75">
		 cXMLCab += '    <Cell ss:MergeAcross="1" ss:StyleID="s75"><Data ss:Type="String">Parâmetros:</Data></Cell>
		 cXMLCab += ' </Row>' + CRLF
		 cXMLCab += ' <Row ss:Height="16.5">
		 cXMLCab += '    <Cell ss:MergeAcross="1" ss:StyleID="s77"><Data ss:Type="String">Data Vencimento de: ' + DtoC(MV_PAR01) + ' até ' + DtoC(MV_PAR02) + '</Data></Cell>
		 cXMLCab += ' </Row>' + CRLF
		 cXMLCab += ' <Row ss:Height="16.5">
		 cXMLCab += '    <Cell ss:MergeAcross="1" ss:StyleID="s77"><Data ss:Type="String">Data Indice x Valor: ' + DtoC(MV_PAR03) + '</Data></Cell>
		 cXMLCab += ' </Row>' + CRLF		 
		 cXMLCab += ' <Row ss:Height="16.5">
		 cXMLCab += '    <Cell ss:MergeAcross="1" ss:StyleID="s77"><Data ss:Type="String">Indice: ' + MV_PAR04 + '-' + POSICIONE('ZCI', 1, xFilial('ZCI')+MV_PAR04,'ZCI_INDICE') + '</Data></Cell>
		 cXMLCab += ' </Row>' + CRLF
		 cXMLCab += ' <Row ss:Height="16.5">
		 cXMLCab += '    <Cell ss:MergeAcross="1" ss:StyleID="s77"><Data ss:Type="String">Valor da @: ' + cValToChar(MV_PAR05) + '</Data></Cell>
		 cXMLCab += ' </Row>' + CRLF
		 cXMLCab += ' <Row ss:Height="16.5">
		 cXMLCab += ' </Row>' + CRLF		 
		 cXMLCab += ' <Row ss:Height="33">' + CRLF
/* 06 */ cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 01 */ cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Produtor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 02 */ cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Qtd Recebida</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Contrato</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Vencto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Saida</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Rendimento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Vlr @</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Valor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Vlr x Cabeça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">R$ x KG</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Qtd Comprada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Status</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		 cXMLCab += ' </Row>' + CRLF
		 
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXMLCab + cXML ) )
	EndIf
	cXML := ""	
	
EndIf	

Return nil
// FIM: fQuadro1

// U_VAFINM01()