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
 | Principal: 					U_VAFINM02()                                      |
 | Func:  VAFINM02()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  31.10.2018                                                              |
 | Desc:  Impressão Relatorio: Custos da Ração;							          |
 '--------------------------------------------------------------------------------|
 | Alt:                                                                           |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAFINM02()	// U_VAFINM02()
Local cTimeIni	 	:= Time()
Local lTemDados		:= .T.

Private cPerg		:= "VAFINM02"
Private cTitulo  	:= "Relatorio dos Custos da Ração"

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
		FWMsgRun(, {|| lTemDados := VASqlM02("Geral", @_cAliasG ) },'Por Favor Aguarde...' , 'Processando Banco de Dados')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro do financeiro de custo de ração')
			
			// Final - encerramento do arquivo
			FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )
			
			FClose(nHandle)

			If ApOleClient("MSExcel")			
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
 | Principal: 					U_VAFINM02()                                      |
 | Func:  defStyle()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  31.10.2018                                                              |
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
	cStyle += ' <Style ss:ID="sDataCenter">
	cStyle += ' 	<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
	cStyle += ' 	<Borders/>
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="20" ss:Color="#000000" ss:Bold="1"/>
	cStyle += ' 	<NumberFormat ss:Format="Short Date"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="sTxtBranco">
	cStyle += ' 	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"/>
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

aAdd(aRegs,{cPerg, "01", "Data Fabricação De?"      , "", "", "MV_CH1", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR01", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Data Fabricação Ate?"     , "", "", "MV_CH2", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR02", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
// aAdd(aRegs,{cPerg, "03", "Data Valor?"		    , "", "", "MV_CH3", "D", TamSX3("ZSI_DATA")[1]  , TamSX3("ZSI_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR03", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","ZSI","","","","",""})
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



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAFINM02()                                      |
 | Func:  VASqlM02()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  31.10.2018                                                              |
 | Desc:  Processamento do SQL, salvando em variavel PRIVADA;                     |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function VASqlM02(cTipo, _cAlias)
Local _cQry 		:= ""

If cTipo == "Geral"

	// _cQry := " -- USE Totvs12 " + CRLF
	_cQry := " WITH" + CRLF
	_cQry += " PROD_RACAO AS (		 " + CRLF
	_cQry += " 	SELECT D3.D3_FILIAL					    FILIAL," + CRLF
	_cQry += " 			D3.D3_COD					    CODIGO," + CRLF
	_cQry += " 			B1.B1_DESC					    DESCRICAO, 		 " + CRLF
	_cQry += " 			D3.D3_UM						    UM,    					 " + CRLF
	_cQry += " 			D3.D3_OP							OP," + CRLF
	_cQry += " 			D3.D3_EMISSAO					EMISSAO,     		 " + CRLF
	_cQry += " 			SUM(D3.D3_QUANT)					QTD," + CRLF
	_cQry += " 			SUM(D3.D3_CUSTO1)				CUSTO		 " + CRLF
	_cQry += " 		, B1_X_TRATO " + CRLF
	_cQry += " 	FROM SD3010 D3		 " + CRLF
	_cQry += " 	JOIN SB1010 B1 ON B1_FILIAL=' ' AND D3_COD = B1_COD" + CRLF
	_cQry += " 						AND D3.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' 		 " + CRLF
	_cQry += " 	WHERE D3.D3_TM = '001'		 " + CRLF
	_cQry += " 	  AND D3.D3_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'" + CRLF
	_cQry += " 	  AND B1_X_TRATO = '1'		 " + CRLF
	//_cQry += " 	  --AND D3.D3_COD = '030013'		 " + CRLF
	_cQry += " 	GROUP BY D3.D3_FILIAL, D3.D3_COD, B1_DESC, D3.D3_UM, D3.D3_EMISSAO, D3.D3_OP, B1_X_TRATO " + CRLF
	//_cQry += " 	--ORDER BY D3.D3_COD, D3.D3_EMISSAO " + CRLF
	_cQry += " 	) " + CRLF
	_cQry += " 	 " + CRLF
	_cQry += " , INS_CARR AS (		 " + CRLF
	_cQry += " 	SELECT P.FILIAL, P.CODIGO, D3.D3_FILIAL, D3_COD, B1_DESC, B1_UM, D3.D3_EMISSAO, SUM(D3_QUANT) QTD, SUM(D3_CUSTO1) CUSTO, B1_CUSTD, D3.D3_OP FROM SD3010 D3		 " + CRLF
	_cQry += " 		JOIN PROD_RACAO P ON		 " + CRLF
	_cQry += " 			D3.D3_FILIAL				=			P.FILIAL		 " + CRLF
	_cQry += " 		AND D3.D3_OP					=			P.OP		 " + CRLF
	_cQry += " 		AND D3.D3_EMISSAO			=			P.EMISSAO		 " + CRLF
	_cQry += " 		AND D3.D3_COD				<>			P.CODIGO		 " + CRLF
	_cQry += " 		AND D3_CF					LIKE		'RE%'		 " + CRLF
	_cQry += " 		JOIN SB1010 B1 ON B1_FILIAL=' ' AND B1_COD = D3.D3_COD AND B1.D_E_L_E_T_ = ' '" + CRLF
	_cQry += " 		WHERE D3.D_E_L_E_T_			=			' ' 		 " + CRLF
	_cQry += " 		GROUP BY P.FILIAL, P.CODIGO, D3.D3_FILIAL, D3.D3_COD, B1_DESC, B1_UM, D3_EMISSAO, B1_CUSTD, D3.D3_OP		 " + CRLF
	_cQry += " 	) " + CRLF
	_cQry += " 				 " + CRLF
	_cQry += " 	SELECT  P.FILIAL," + CRLF
	_cQry += " 			P.CODIGO, 		 " + CRLF
	_cQry += " 			P.DESCRICAO," + CRLF
	_cQry += " 			P.UM," + CRLF
	_cQry += " 			SUM(P.QTD) QUANTIDADE," + CRLF
	//_cQry += " 			-- SUM(P.CUSTO)/SUM(P.QTD) CUSTO_MEDIO, " + CRLF
	_cQry += " 			SUM(P.CUSTO) CUSTO_TOTAL, " + CRLF
	_cQry += " 			P.B1_X_TRATO, " + CRLF
	_cQry += " 			P.EMISSAO, " + CRLF
	_cQry += " 			I.D3_COD, " + CRLF
	_cQry += " 			I.B1_DESC, " + CRLF
	_cQry += " 			I.B1_UM, " + CRLF
	_cQry += " 			SUM(I.QTD) INS_QUANT," + CRLF
	//_cQry += " 			-- SUM(I.CUSTO)/SUM(I.QTD) CUSTO_UNIT, " + CRLF
	_cQry += " 			B1_CUSTD CUSTOPADRAO, " + CRLF
	//_cQry += " 			--TRATAR " + CRLF
	//_cQry += " 			--ISNULL(ISNULL(SUM(I.CUSTO)/SUM(I.QTD),0)/ISNULL(B1_CUSTD,1),0) VARIACAO, " + CRLF
	_cQry += " 			SUM(I.CUSTO) CUSTOTOAL " + CRLF
	//_cQry += " 			--, SUM(I.QTD)/SUM(P.QTD)*100 PERCEN " + CRLF
	_cQry += " 	FROM PROD_RACAO P " + CRLF
	//_cQry += " 	--WHERE	 CODIGO NOT IN ('030006','030007')" + CRLF
	_cQry += "" + CRLF
	_cQry += " 	JOIN INS_CARR I ON P.FILIAL = I.D3_FILIAL AND P.CODIGO = I.CODIGO" + CRLF
	_cQry += " 						AND P.EMISSAO = I.D3_EMISSAO" + CRLF
	_cQry += " 						AND P.OP = I.D3_OP " + CRLF
	_cQry += " 	 " + CRLF
	_cQry += " 	GROUP BY P.B1_X_TRATO, P.FILIAL, P.CODIGO, P.DESCRICAO, P.UM, P.EMISSAO, " + CRLF
	_cQry += " 				I.D3_COD, I.B1_DESC, I.B1_UM, I.B1_CUSTD " + CRLF
	_cQry += " 	ORDER BY P.B1_X_TRATO, P.FILIAL, P.CODIGO, D3_COD, P.EMISSAO " + CRLF
	// _cQry := ChangeQuery(_cQry)
EndIf

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

//TcSetField(_cAlias, "D3_EMISSAO", "D")

Return !(_cAlias)->(Eof()) // U_VAFINM02()
// FIM: VASqlM02()



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAFINM02()                                      |
 | Func:  fQuadro1()	                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  01.11.2018                                                              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1()	 // U_VAFINM02()

Local cXMLCab 		:= "", cXML := ""
Local cWorkSheet 	:= "Custo da Ração"
Local cProduto		:= "", cInsumo := ""
// Local _aVetor1		:= {}
// Local _aVetor2		:= {}
// Local _aMatriz		:= {}

Local dDia_nI		:= MV_PAR01
Local nQtDias 		:= MV_PAR02 - MV_PAR01
Local nLin 			:= 0

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	// Inicio // fQuadro1 -> "Custo da Ração"
	cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
	cXML += '     <Column ss:Width="31.5"/>' + CRLF
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="56.25"/>' + CRLF
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="186"/>' + CRLF
	cXML += '     <Column ss:Width="36.75"/>' + CRLF
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="72"/>' + CRLF
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="72" ss:Span="2"/>' + CRLF
	cXML += '     <Column ss:Index="9" ss:AutoFitWidth="0" ss:Width="72" ss:Span="2"/>' + CRLF
	cXML += '     <Column ss:Index="12" ss:AutoFitWidth="0" ss:Width="72" ss:Span="4"/>' + CRLF
	cXML += '     <Column ss:Index="17" ss:AutoFitWidth="0" ss:Width="72" ss:Span="2"/>' + CRLF
	cXML += ' <Row ss:Height="36">' + CRLF
	cXML += '   <Cell ss:MergeAcross="18" ss:StyleID="s62">' + CRLF
	cXML += '     <Data ss:Type="String">RELATÓRIO DE CUSTOS DA RAÇÃO</Data>' + CRLF
	cXML += '   </Cell>' + CRLF
	cXML += ' </Row>' + CRLF
	cXML += ' <Row ss:Height="33">' + CRLF
	cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
	cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
	cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
	cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
	For dDia_nI := MV_PAR01 to MV_PAR02
		cXML += '   <Cell ss:StyleID="sDataCenter" ss:MergeAcross="4"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( dDia_nI ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	Next dDia_nI
	cXML += ' </Row>' + CRLF
	nLin += 1
	
	//fQuadro1
	While !(_cAliasG)->(Eof())	 // U_VAFINM02()
		nLin += 1
 
		if cProduto <> (_cAliasG)->CODIGO
			If nLin > 2
				cXML += '<Row>' + CRLF
				cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
				cXML += '</Row>' + CRLF // pular linha
			EndIf
			cProduto := (_cAliasG)->CODIGO
			
			cXML += ' <Row ss:Height="33">' + CRLF
			cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Codigo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Produto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">UN</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

			For dDia_nI := MV_PAR01 to MV_PAR02
				cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Quant.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Custo Medio</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Custo Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
				cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
			Next dDia_nI
			cXML += ' </Row>' + CRLF
			
			cXML += '<Row>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAliasG)->FILIAL    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAliasG)->CODIGO    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAliasG)->DESCRICAO ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAliasG)->UM 	   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			
			// formula na linha do produto final
			For dDia_nI := MV_PAR01 to MV_PAR02
				cXML += '  <Cell ss:StyleID="sComDig" ss:Formula="=SUMIF(R[2]C1:R[20]C1,RC2,R[2]C:R[20]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="sReal"   ss:Formula="=IFERROR(RC[1]/RC[-1],0)"><Data ss:Type="Number"></Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="sReal"   ss:Formula="=SUMIF(R[2]C1:R[20]C1,RC2,R[2]C[1]:R[20]C[1])"><Data ss:Type="Number"></Data></Cell>' + CRLF
				cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
				cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
			Next dDia_nI
			cXML += '</Row>' + CRLF
			
			cXML += '<Row>' + CRLF
			cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
			cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Código</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Insumo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">UN</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			
			For dDia_nI := MV_PAR01 to MV_PAR02
				cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Quant.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Custo Unit.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Custo Padrao</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Custo Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Percent</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			Next dDia_nI
			cXML += '</Row>' + CRLF
			
			cInsumo := ""
			nLinPerc	:= 2
		EndIf 

		if cInsumo <> (_cAliasG)->D3_COD
			cXML += '<Row>' + CRLF
			cXML += '  <Cell ss:StyleID="sTxtBranco"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAliasG)->CODIGO    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAliasG)->D3_COD  ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAliasG)->B1_DESC ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAliasG)->B1_UM   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cInsumo := (_cAliasG)->D3_COD
			dDia_nI := MV_PAR01
		EndIf
		
		While dDia_nI <= sToD( (_cAliasG)->EMISSAO )
			if dDia_nI == sToD( (_cAliasG)->EMISSAO )
				cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->INS_QUANT ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[2]/RC[-1],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s16"/>' + CRLF
				cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->CUSTOTOAL   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s16" ss:Formula="=IFERROR(RC[-4]/R[-'+AllTrim(Str(nLinPerc))+']C[-4]*100,0)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			Else
				cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
				cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
				cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
				cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
				cXML += '   <Cell ss:StyleID="s16"/>' + CRLF
			EndIf
			dDia_nI += 1
		EndDo
		
		(_cAliasG)->(DbSkip())		// U_vafinm02()
		
		if cInsumo <> (_cAliasG)->D3_COD .or. (_cAliasG)->(Eof())
			cXML += '</Row>' + CRLF
			nLinPerc+=1
		EndIf
	EndDo
	
	// Final da Planilha
	cXML += ' </Table>' + CRLF
	cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += ' 	<PageSetup>' + CRLF
	cXML += ' 		<Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += ' 	</PageSetup>' + CRLF
	cXML += ' 	<Unsynced/>' + CRLF
	cXML += ' 	<Selected/>' + CRLF
	cXML += ' 	<FreezePanes/>' + CRLF
	cXML += ' 	<FrozenNoSplit/>' + CRLF
	cXML += ' 	<SplitHorizontal>2</SplitHorizontal>' + CRLF
	cXML += ' 	<TopRowBottomPane>2</TopRowBottomPane>' + CRLF
	cXML += ' 	<SplitVertical>4</SplitVertical>' + CRLF
	cXML += ' 	<LeftColumnRightPane>20</LeftColumnRightPane>' + CRLF
	cXML += ' 	<ActivePane>0</ActivePane>' + CRLF
	cXML += ' 	<Panes>' + CRLF
	cXML += ' 		<Pane>' + CRLF
	cXML += ' 			<Number>3</Number>' + CRLF
	cXML += ' 		</Pane>' + CRLF
	cXML += ' 		<Pane>' + CRLF
	cXML += ' 			<Number>1</Number>' + CRLF
	cXML += ' 			<ActiveCol>4</ActiveCol>' + CRLF
	cXML += ' 		</Pane>' + CRLF
	cXML += ' 		<Pane>' + CRLF
	cXML += ' 			<Number>2</Number>' + CRLF
	cXML += ' 		</Pane>' + CRLF
	cXML += ' 		<Pane>' + CRLF
	cXML += ' 			<Number>0</Number>' + CRLF
	cXML += ' 			<ActiveRow>5</ActiveRow>' + CRLF
	cXML += ' 			<ActiveCol>24</ActiveCol>' + CRLF
	cXML += ' 		</Pane>' + CRLF
	cXML += ' 	</Panes>' + CRLF
	cXML += ' 	<ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += ' 	<ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += ' 	</WorksheetOptions>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
	
EndIf	

Return nil
// FIM: fQuadro1

// U_VAFINM02()