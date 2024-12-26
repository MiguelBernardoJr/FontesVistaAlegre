#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
// #Include "Rwmake.ch" 
// #Include "Protheus.ch"
// #Include "TopConn.ch"
// #INCLUDE "XMLXFUN.CH"


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  20.04.2018                                                              |
 | Desc:  Relatorio de Lotação de Baias e Pastos.                                 |
 |                                                                                |
 | Obs.:  Este relatorio é uma re-leitura do fonte VAEST14R ;                     |
 |	      Neste formato o XML esta escrito manualmente;                           |
 '--------------------------------------------------------------------------------*/
User Function VARELM01() // U_VARELM01()                                                    
Local cTimeIni     := Time()
Local nOpc         := 0
// Local aRet      := {}
// Local aParamBox := {}

// Local cLoad     := ProcName(1) // Nome do perfil se caso for carregar
// Local lCanSave  := .T. // Salvar os dados informados nos parâmetros por perfil
// Local lUserSave := .T. // Configuração por usuário

Private cPerg      := "VARELM01"

Private cTitulo    := "Relatorio Baia e Pasto"
Private aSay       := {}
Private aButton    := {}

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
	
	GeraX1(cPerg)
	
	If Pergunte( cPerg, .T.)
		
		If MV_PAR04 > MsDate()
			Aviso("Aviso", "A data de referência informada [" + dToC(MV_PAR05) + "]" + ;
						   " não pode ser maior que a data atual ["+dToC(MsDate())+"]." + CRLF + ;
						   "Data de referência atualizada para data do sistema.", {"Ok"}, 2 )
			// aRet[4] := MsDate()
			MV_PAR04 := MsDate()
		EndIf
		FWMsgRun(, {|| RELM01VA( /* aRet[2], aRet[3], aRet[4], aRet[5], aRet */ ) }, 'Geração Relatório Baia x Pasto','Gerando excel, Por Favor Aguarde...')
		
	EndIf
EndIf

If lower(cUserName) $ 'mbernardo,atoshio,admin'
	Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
EndIf

Return nil
// FIM DA FUNCAO: VARELM01

/*--------------------------------------------------------------------------------,
 | Func:  			                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  08.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function RELM01VA( /* nAgrup, nDiasAb, dDTReferencia, dDtMoviment, _aParam */ )

Local aLinVazia	  	:= {}
Local cStyle		:= ""
Local cXML	   		:= ""
Local lTemDados		:= .T.

Private nHandle    	:= 0

Private aDadTp1     := {}
Private aDadTp4     := {}
Private aCurSint    := {}
Private aPasSint    := {}

Private cPath 	    := "C:\totvs_relatorios\"
Private cArquivo    := cPath + "VARELM01_"+; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil

// utilizados em todo o processo
Private _cAliaEST  := CriaTrab(,.F.)   
Private _cAliaMOV  := CriaTrab(,.F.)   
Private _cAliaRAC  := CriaTrab(,.F.)   
Private aMov 	   := {}

// variaveis privadas para guardar posicao da planilha 2 sintetica : Lita de currais
Private nFimParC   := 0 // Currais
Private nQtLinC	   := 0 // Currais
Private nFimParP   := 0 // Pastos
Private nQtLinP	   := 0 // Pastos

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

	cStyle := ' <Style ss:ID="s16" ss:Name="Vírgula">'+CRLF
	cStyle += '   <NumberFormat ss:Format="_-* #,##0.00_-;\-* #,##0.00_-;_-* &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s98" ss:Name="Vírgula 2">
	cStyle += ' 	<NumberFormat ss:Format="_-* #,##0.00_-;\-* #,##0.00_-;_-* &quot;-&quot;??_-;_-@_-"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="s62">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+CRLF
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
	cStyle += '  <Style ss:ID="s66">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '     ss:Color="#000000"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '  <Style ss:ID="s67">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '     ss:Color="#000000"/>'+CRLF
	cStyle += '    <NumberFormat ss:Format="Short Date"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '<Style ss:ID="s68" ss:Parent="s16">'+CRLF
	cStyle += '   <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '    ss:Color="#000000"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '  <Style ss:ID="s69">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '     ss:Color="#000000"/>'+CRLF
	cStyle += '    <NumberFormat'+CRLF
	cStyle += '     ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += '  </Style>'+CRLF
	cStyle += '  <Style ss:ID="s70">'+CRLF
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
	cStyle += ' <Style ss:ID="s71">'+CRLF
	cStyle += ' 	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += ' 		ss:Color="#000000"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s72" ss:Parent="s16">'+CRLF
	cStyle += '     <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '      ss:Color="#000000"/>'+CRLF
	cStyle += '     <NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += ' </Style>'+CRLF
    cStyle += ' <Style ss:ID="s81">'+CRLF
    cStyle += ' <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+CRLF
    cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
    cStyle += ' ss:Color="#000000" ss:Bold="1"/>'+CRLF
    cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s82">'+CRLF
	cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += ' ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s83">'+CRLF
	cStyle += ' <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += ' ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s84" ss:Parent="s16">'+CRLF
	cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += ' ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += ' <NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s85">'+CRLF
	cStyle += ' <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
	cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += ' ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += ' <NumberFormat'+CRLF
	cStyle += ' ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s86" ss:Parent="s16">'+CRLF
	cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += ' ss:Color="#000000" ss:Bold="1"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s90">'+CRLF
	cStyle += '    <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF
	cStyle += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="12"'+CRLF
	cStyle += '     ss:Color="#333399" ss:Bold="1"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s91">'+CRLF
	cStyle += ' 	<Alignment ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += ' </Style>'+CRLF
    cStyle += ' <Style ss:ID="s93">'+CRLF
    cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+CRLF
    cStyle += '  <Borders>'+CRLF
    cStyle += '  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"'+CRLF
    cStyle += '  ss:Color="#37752F"/>'+CRLF
    cStyle += '  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="3"'+CRLF
    cStyle += '  ss:Color="#FFFFFF"/>'+CRLF
    cStyle += '  </Borders>'+CRLF
    cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="12"'+CRLF
    cStyle += '  	ss:Color="#333399" ss:Bold="1"/>'+CRLF
    cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s106">'+CRLF
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '  ss:Color="#FFFFFF" ss:Bold="1"/>'+CRLF
	cStyle += '  <Interior ss:Color="#00B0F0" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' </Style>	'+CRLF
	cStyle += ' <Style ss:ID="s112">'+CRLF
	cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
	cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += '  ss:Color="#FFFFFF" ss:Bold="1"/>'+CRLF
	cStyle += '  <Interior ss:Color="#0070C0" ss:Pattern="Solid"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s107" ss:Parent="s16">'+CRLF
    cStyle += ' <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
    cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
    cStyle += '   ss:Color="#000000"/>'+CRLF
    cStyle += ' <NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>'+CRLF
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
	cStyle += ' <Style ss:ID="s102">'+CRLF
	cStyle += ' <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>'+CRLF
	cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF
	cStyle += ' 		ss:Color="#000000"/>'+CRLF
	cStyle += ' </Style>'+CRLF
	cStyle += ' <Style ss:ID="s205" ss:Parent="s16">
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"/>
	cStyle += ' 	<Interior ss:Color="#808080" ss:Pattern="Solid"/>
	cStyle += ' 	<NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="s206">
	cStyle += ' 	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"/>
	cStyle += ' 	<Interior ss:Color="#808080" ss:Pattern="Solid"/>
	cStyle += ' 	<NumberFormat
	cStyle += ' 	ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="s207">
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"/>
	cStyle += ' 	<Interior ss:Color="#808080" ss:Pattern="Solid"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="s208" ss:Parent="s98">
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"/>
	cStyle += ' 	<Interior ss:Color="#808080" ss:Pattern="Solid"/>
	cStyle += ' 	<NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>
	cStyle += ' </Style>
	cStyle += ' <Style ss:ID="s209" ss:Parent="s16">
	cStyle += ' 	<Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"/>
	cStyle += ' 	<Interior ss:Color="#808080" ss:Pattern="Solid"/>
	cStyle += ' </Style>

	cXML := U_CabXMLExcel(cStyle)

	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
		cXML := ""
	EndIf
	
	VASQLEST( MV_PAR01, MV_PAR02, dToS(MV_PAR04)) // u_VARELM01()
	
	aLinVazia := fQuadro1( MV_PAR01, MV_PAR02, dToS(MV_PAR04) ) // u_VARELM01()
	
	aCurSint := sQuadro1s( MV_PAR01, MV_PAR02, dToS(MV_PAR04) )

	fQuadro4( dToS(MV_PAR04), MV_PAR02, MV_PAR01 )
	
	// Lista Pastos - Sintetico
	aPasSint := sQuadro4s( MV_PAR01, MV_PAR02, dToS(MV_PAR04) )

	// resumo por era
	fQuadro2( dToS(MV_PAR04), aCurSint, aPasSint )

	fQuadro3(aLinVazia)

	If MV_PAR07 == 1
		fQuadro5( MV_PAR01, MV_PAR02, dToS(MV_PAR04), dToS(MV_PAR05) )

		fQuadro6( dToS(MV_PAR04), dToS(MV_PAR05), MV_PAR02  )
		
		(_cAliaMOV)->(DbCloseArea())
	EndIf
	
	// Processar SQL
	FWMsgRun(, {|| lTemDados := VASqlM01("Racao", @_cAliaRAC ) }, 'Processando Banco de Dados','Por Favor Aguarde...')
	If lTemDados
		fQuadro7()
	EndIf
	
	// Final - encerramento do arquivo
	FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )
	
	ConOut('Activate: ' + Time())

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

	(_cAliaEST)->(DbCloseArea())
	(_cAliaRAC)->(DbCloseArea())
	
	ConOut('FIM: ' + Time())
EndIf

Return Nil
// FIM DA FUNCAO: RELM01VA

User Function CabXMLExcel(cStyle)
Local   cRet   := ""
Default cStyle := ""

cRet := '<?xml version="1.0"?>' + CRLF
cRet += '<?mso-application progid="Excel.Sheet"?>' + CRLF
cRet += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' + CRLF
cRet += '  xmlns:o="urn:schemas-microsoft-com:office:office"' + CRLF
cRet += '  xmlns:x="urn:schemas-microsoft-com:office:excel"' + CRLF
cRet += '  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"' + CRLF
cRet += '  xmlns:html="http://www.w3.org/TR/REC-html40">' + CRLF
cRet += '  <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">' + CRLF
cRet += '   <Author>Miguel Bernardo</Author>' + CRLF
cRet += '   <LastAuthor>Miguel Bernardo</LastAuthor>' + CRLF
cRet += '   <Created>' + U_TimeStamp() + 'Z</Created>' + CRLF
cRet += '   <Version>16.00</Version>' + CRLF
cRet += '  </DocumentProperties>' + CRLF
cRet += '  <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">' + CRLF
cRet += '   <AllowPNG/>' + CRLF
cRet += '  </OfficeDocumentSettings>' + CRLF
cRet += '   <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
cRet += '     <WindowHeight>14190</WindowHeight>' + CRLF
cRet += '     <WindowWidth>28800</WindowWidth>' + CRLF
cRet += '     <WindowTopX>32767</WindowTopX>' + CRLF
cRet += '     <WindowTopY>32767</WindowTopY>' + CRLF
// cRet += '     <ActiveSheet>1</ActiveSheet>' + CRLF
cRet += '     <ProtectStructure>False</ProtectStructure>' + CRLF
cRet += '     <ProtectWindows>False</ProtectWindows>' + CRLF
cRet += '  </ExcelWorkbook>' + CRLF
cRet += '  <Styles>' + CRLF
cRet += '   <Style ss:ID="Default" ss:Name="Normal">' + CRLF
cRet += '    <Alignment ss:Vertical="Bottom"/>' + CRLF
cRet += '    <Borders/>' + CRLF
cRet += '    <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF
cRet += '    <Interior/>' + CRLF
cRet += '    <NumberFormat/>' + CRLF
cRet += '    <Protection/>' + CRLF
cRet += '   </Style>' + CRLF
cRet += cStyle
cRet += '  </Styles>' + CRLF

Return cRet
// FIM DA FUNCAO: CabXMLExcel


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  06.05.2018                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function VASQLEST( nAgrup, cDiasAb, dDTReferencia )
Local _cQry := ""

_cQry := " WITH SALDO_ATUAL AS ( " + CRLF
_cQry += " 	SELECT DISTINCT B2_FILIAL, B2_COD, B2_LOCAL, '' B8_LOTECTL, B1_X_CURRA, B1_XANIMAL, B1_XANIITE, B1_X_ERA, B1_XLOTE, " + CRLF
_cQry += " 			CASE B1_RASTRO WHEN 'L' THEN 'L' ELSE 'N' END B1_RASTRO, " + CRLF
_cQry += " 			B1_XPESOCO, B1_XLOTCOM, B1_XRACA, B1_X_SEXO, B1_XDENTIC, B1_XDATACO, " + CRLF
_cQry += " 			100 AS DiasAbate, " + CRLF
_cQry += "  			CASE B1_XDATACO " + CRLF
_cQry += "   				WHEN ' ' THEN 0 " + CRLF
_cQry += "   				ELSE DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '" + dDTReferencia + "', 103)) " + CRLF
_cQry += "   			END AS Dias, " + CRLF
_cQry += "   			CASE B1_XDATACO " + CRLF
_cQry += "   				WHEN ' ' THEN ' ' " + CRLF
_cQry += "   				ELSE CONVERT( VARCHAR, CONVERT(DATETIME, B1_XDATACO, 103)+"+cDiasAb+", 112) " + CRLF
_cQry += "   			END PrjecAba, " + CRLF
_cQry += " 			SUM(B2_QATU) B2_QATU, --A2_NOME " + CRLF
_cQry += " 			A2_NOME --ISNULL(A2_NOME, ' ' ) A2_NOME " + CRLF
//_cQry += "          --ISNULL((SELECT DISTINCT A2_NOME FROM SA2010 SA2 WHERE SA2.D_E_L_E_T_ = ' ' AND A2_COD+A2_LOJA IN (SELECT C7_FORNECE+C7_LOJA FROM SC7010 WHERE C7_FILIAL+C7_NUM = B1_XLOTCOM AND D_E_L_E_T_ = ' ' AND C7_PRODUTO LIKE 'BOV0%' )),'') A2_NOME  " + CRLF
_cQry += "          --ISNULL((SELECT DISTINCT A2_NOME FROM " + RetSqlName('SA2') + " SA2 WHERE SA2.D_E_L_E_T_ = ' ' AND A2_COD = (SELECT DISTINCT C7_FORNECE FROM " + RetSqlName('SC7') + " WHERE C7_FILIAL+C7_NUM = B1_XLOTCOM AND C7_PRODUTO LIKE 'BOV%' AND D_E_L_E_T_ = ' ' AND C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA)),'') A2_NOME  " + CRLF
_cQry += " 	FROM " + RetSqlName('SB1') + "  B1 " + CRLF
_cQry += " 	JOIN " + RetSqlName('SB2') + " B2 ON B1_FILIAL=' ' AND B2_FILIAL='"+FWxFilial('SB2')+"' AND B1_COD=B2_COD AND B1.D_E_L_E_T_= ' ' AND B2.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	LEFT JOIN " + RetSqlName('SC7') + " C7 ON C7_FILIAL+C7_NUM = B1_XLOTCOM AND B1.D_E_L_E_T_=' ' AND C7_PRODUTO LIKE 'BOV0%'  AND C7.D_E_L_E_T_=' ' " + CRLF 
_cQry += " 	LEFT JOIN " + RetSqlName('SA2') + " A2 ON A2_FILIAL=' ' AND A2_COD=C7_FORNECE AND A2_LOJA=C7_LOJA AND A2.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	WHERE B1_GRUPO IN ('BOV') " + CRLF
_cQry += " 	  AND B1_RASTRO = 'L' AND B2_QATU > 0 " + CRLF
_cQry += " 	GROUP BY B2_FILIAL, B2_COD, B2_LOCAL, B1_RASTRO, B1_X_CURRA, B1_XANIMAL, B1_XANIITE, B1_X_ERA, B1_XLOTE, B1_XPESOCO, B1_XLOTCOM " + CRLF
_cQry += "         , B1_XRACA, B1_X_SEXO, B1_XDENTIC, B1_XDATACO, A2_NOME " + CRLF
_cQry += " ), " + CRLF
_cQry += " " + CRLF
_cQry += " SALDO_LOTE AS ( " + CRLF
_cQry += " 	SELECT DISTINCT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, 'L' B1_RASTRO, " + CRLF
_cQry += " 			B8_XPESOCO, B8_GMD, B8_XRENESP, " + CRLF
_cQry += " 			B8_DIASCO DiasAbate, B8_XDATACO, " + CRLF
_cQry += "     			CASE B8_XDATACO " + CRLF
_cQry += " 				WHEN ' ' THEN 0 " + CRLF
_cQry += " 				ELSE DATEDIFF(DAY, CONVERT(DATETIME, B8_XDATACO, 103), CONVERT(DATETIME, '" + dDTReferencia + "', 103))" + CRLF
_cQry += " 			END AS Dias," + CRLF
_cQry += " 			CASE B8_XDATACO " + CRLF
_cQry += " 				WHEN ' ' THEN ' ' " + CRLF
_cQry += " 				ELSE CONVERT( VARCHAR, CONVERT(DATETIME, B8_XDATACO, 103)+B8_DIASCO, 112) " + CRLF
_cQry += "          END PrjecAba," + CRLF
_cQry += " 			SUM(B8_SALDO) B8_SALDO, --A2_NOME " + CRLF
_cQry += " 			 --ISNULL(A2_NOME, ' ' ) A2_NOME " + CRLF
//_cQry += "          ISNULL((SELECT DISTINCT A2_NOME FROM SA2010 WHERE D_E_L_E_T_ = ' ' AND A2_COD+A2_LOJA = (SELECT DISTINCT C7_FORNECE+C7_LOJA FROM " + RetSqlName('SC7') + " WHERE C7_FILIAL+C7_NUM = B1_XLOTCOM AND C7_PRODUTO LIKE 'BOV%' AND D_E_L_E_T_ = ' ' )),'') A2_NOME  " + CRLF
_cQry += "          ISNULL((SELECT DISTINCT A2_NOME FROM " + RetSqlName('SA2') + " WHERE D_E_L_E_T_ = ' ' AND A2_COD = (SELECT DISTINCT C7_FORNECE FROM " + RetSqlName('SC7') + " WHERE C7_FILIAL+C7_NUM = B1_XLOTCOM AND C7_PRODUTO LIKE 'BOV%' AND D_E_L_E_T_ = ' ' AND C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA)),'') A2_NOME  " + CRLF
_cQry += " 	FROM " + RetSqlName('SB1') + "  B1 " + CRLF
_cQry += " 	JOIN " + RetSqlName('SB8') + "  B8 ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B8_FILIAL='"+FWxFilial('SB8')+"' AND B1_COD=B8_PRODUTO AND B1.D_E_L_E_T_= ' ' AND B8.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	--LEFT JOIN " + RetSqlName('SC7') + " C7 ON C7_FILIAL+C7_NUM = B1_XLOTCOM AND B1.D_E_L_E_T_=' ' AND C7_PRODUTO LIKE 'BOV0%'  AND C7.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	--LEFT JOIN " + RetSqlName('SA2') + " A2 ON A2_FILIAL=' ' AND A2_COD=C7_FORNECE AND A2_LOJA=C7_LOJA AND A2.D_E_L_E_T_=' ' " + CRLF 
_cQry += " 	WHERE B1_GRUPO IN ('BOV')  AND B1.D_E_L_E_T_ = ' ' AND B8_SALDO > 0" + CRLF
_cQry += " 	GROUP BY B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B1_RASTRO, B8_XPESOCO, B8_GMD, " + CRLF
_cQry += " 	 		 B8_XRENESP, B8_DIASCO, B8_XDATACO, B1_XLOTCOM " + CRLF
_cQry += " ), " + CRLF
_cQry += CRLF
_cQry += " CURRAL AS ( " + CRLF
_cQry += " 		SELECT DISTINCT SB8.B8_FILIAL, SB8.B8_PRODUTO, SB8.B8_LOCAL, SB8.B8_LOTECTL, SB8.B8_X_CURRA, SB8.D_E_L_E_T_ " + CRLF
_cQry += " 		FROM " + RetSqlName('SB8') + " SB8 "+ CRLF
_cQry += " 	    JOIN SALDO_LOTE SL ON  "+ CRLF
_cQry += "  	     SL.B8_FILIAL = SB8.B8_FILIAL "+ CRLF
_cQry += "	     AND SL.B8_PRODUTO = SB8.B8_PRODUTO "+ CRLF
_cQry += "		 AND SL.B8_LOCAL = SB8.B8_LOCAL "+ CRLF
_cQry += "		 AND SL.B8_LOTECTL = SB8.B8_LOTECTL "+ CRLF
//_cQry += " 		WHERE SB8.D_E_L_E_T_ = ' ' AND B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL IN ( SELECT DISTINCT B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL FROM SALDO_LOTE ) " + CRLF
_cQry += " 		WHERE SB8.D_E_L_E_T_ = ' ' " +CRLF
//_cQry += "        AND SB8.B8_LOTECTL = (SELECT DISTINCT B8_LOTECTL FROM SALDO_LOTE SL WHERE SB8.B8_FILIAL = SL.B8_FILIAL AND SB8.B8_PRODUTO = SL.B8_PRODUTO AND SB8.B8_LOTECTL = SL.B8_LOTECTL ) " + CRLF
_cQry += " 		  AND SB8.B8_X_CURRA<>' ' " + CRLF
_cQry += " 		  AND SB8.B8_SALDO > 0 " + CRLF
_cQry += " ) " + CRLF
_cQry += CRLF
_cQry += " , DADOS AS ( " + CRLF
_cQry += " SELECT --CASE ISNULL(Z08_TIPO,'*') WHEN '*' THEN 'SEM CLASSIFICAÇÃO' ELSE Z08_TIPO END Z08_TIPO, " + CRLF
_cQry += " CASE WHEN ISNULL(L.B8_LOTECTL, A.B1_XLOTE) IN (SELECT Z0F_LOTE FROM Z0F010 WHERE Z0F_FILIAL = '"+FwxFilial("ZF0")+"' AND Z0F_LOTE = ISNULL(L.B8_LOTECTL, A.B1_XLOTE) AND D_E_L_E_T_ = ' ') THEN '1' " + CRLF
_cQry += " 		ELSE " + CRLF
_cQry += "           CASE ISNULL(Z08_TIPO,'*') WHEN '*' THEN 'SEM CLASSIFICAÇÃO' ELSE Z08_TIPO END " + CRLF
_cQry += " 		END Z08_TIPO, " + CRLF
_cQry += " 		ISNULL(L.B1_RASTRO,A.B1_RASTRO) B1_RASTRO, " + CRLF
_cQry += " 		 CASE WHEN ISNULL(L.B8_LOTECTL, A.B1_XLOTE) IN (SELECT Z0F_LOTE FROM Z0F010 WHERE Z0F_FILIAL = '"+FwxFilial("ZF0")+"' AND Z0F_LOTE = ISNULL(L.B8_LOTECTL, A.B1_XLOTE) AND D_E_L_E_T_ = ' ') THEN ('1'+RTRIM(Z08_LINHA)+Z08_SEQUEN) ELSE " + CRLF
_cQry += "		ISNULL(Z08_TIPO+RTRIM(Z08_LINHA)+Z08_SEQUEN,9999) END  ORDEM, " + CRLF
_cQry += " 		 " + CRLF
//_cQry += " 		ISNULL(Z08_TIPO+RTRIM(Z08_LINHA)+Z08_SEQUEN,9999) ORDEM, " + CRLF
_cQry += " 		B2_COD, B2_LOCAL, " + CRLF
_cQry += " 		ISNULL(C.B8_X_CURRA, B1_X_CURRA) B1_X_CURRA, " + CRLF
_cQry += " 		ISNULL(L.B8_LOTECTL, A.B1_XLOTE) B1_XLOTE, " + CRLF
_cQry += " 		CASE B1_X_ERA WHEN ' ' THEN 'SEM CLASSIFICAÇÃO' ELSE B1_X_ERA END B1_X_ERA, " + CRLF
_cQry += " 		ISNULL(B8_SALDO,0) B2_QATU, " + CRLF
_cQry += " 		ISNULL(L.B8_XPESOCO, A.B1_XPESOCO) B1_XPESOCO, " + CRLF
_cQry += " 		B1_XLOTCOM, B1_XRACA, B1_X_SEXO, B1_XDENTIC, " + CRLF
_cQry += " 		--CASE B8_GMD WHEN 0 THEN Z09_GMDESP ELSE B8_GMD END Z09_GMDESP, Z09_VLREST, Z09_DIAABT, " + CRLF
_cQry += " 		Z09_GMDESP, Z09_VLREST, Z09_DIAABT, " + CRLF
_cQry += " 		ISNULL(L.B8_XDATACO, A.B1_XDATACO) B1_XDATACO, " + CRLF
_cQry += " 		CASE L.DiasAbate WHEN 0 THEN A.DiasAbate ELSE L.DiasAbate END DiasAbate," + CRLF
_cQry += " 		ISNULL(L.Dias, A.Dias) Dias," + CRLF
_cQry += " 		CASE ISNULL(L.B8_XPESOCO, A.B1_XPESOCO) " + CRLF
_cQry += "   			WHEN 0 THEN 0 " + CRLF
_cQry += "   			ELSE (DATEDIFF(DAY, CONVERT(DATETIME, ISNULL(L.B8_XDATACO, A.B1_XDATACO), 103), CONVERT(DATETIME, '" + dDTReferencia + "', 103))*(CASE B8_GMD WHEN 0 THEN Z09_GMDESP ELSE B8_GMD END))+ISNULL(L.B8_XPESOCO, A.B1_XPESOCO) " + CRLF
_cQry += "   		END PesoAtual, " + CRLF
_cQry += " 		ISNULL(L.PrjecAba, A.PrjecAba) PrjecAba, " + CRLF
_cQry += " 		--CASE B8_XRENESP WHEN 0 THEN Z09_RENESP ELSE B8_XRENESP END Z09_RENESP, " + CRLF
_cQry += " 		Z09_RENESP, " + CRLF
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
_cQry += " FROM	 SALDO_LOTE L " + CRLF
_cQry += " LEFT JOIN SALDO_ATUAL A ON B2_FILIAL=B8_FILIAL AND B2_COD=B8_PRODUTO AND B2_LOCAL=B8_LOCAL " + CRLF
_cQry += " LEFT JOIN CURRAL     C ON L.B8_FILIAL=C.B8_FILIAL AND L.B8_PRODUTO=C.B8_PRODUTO AND L.B8_LOCAL=C.B8_LOCAL AND L.B8_LOTECTL=C.B8_LOTECTL AND C.D_E_L_E_T_=' ' " + CRLF
_cQry += " LEFT JOIN " + RetSqlName('Z08') + " Z8 ON Z08_FILIAL='"+FWxFilial('Z08')+"' AND RTRIM(UPPER(Z08_CODIGO))=RTRIM(UPPER(ISNULL(C.B8_X_CURRA, A.B1_X_CURRA))) AND Z8.D_E_L_E_T_=' ' " + CRLF
_cQry += " LEFT JOIN " + RetSqlName('Z09') + " Z9 ON Z09_FILIAL='"+FWxFilial('Z09')+"' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' ' " + CRLF
_cQry += " ), " + CRLF
_cQry += "" + CRLF
_cQry += " ENTRADA AS ( " + CRLF
_cQry += " 		SELECT	D1_FILIAL, D1_COD, D1_LOCAL, SUM(D1_X_PESCH) / SUM(D1_QUANT) MEDIA " + CRLF
_cQry += " 		FROM	" + RetSqlName('SD1') + " " + CRLF
_cQry += " 		WHERE	D_E_L_E_T_=' ' " + CRLF
_cQry += " 			AND D1_X_PESCH > 0 AND D1_QUANT > 0 " + CRLF
_cQry += " 		GROUP BY D1_FILIAL, D1_COD, D1_LOCAL " + CRLF
_cQry += " ) " + CRLF
_cQry += "" + CRLF
_cQry += " , FINAL AS (" + CRLF
_cQry += " SELECT DISTINCT Z08_TIPO," + CRLF
_cQry += " 			B1_RASTRO," + CRLF
_cQry += " 			ORDEM," + CRLF
_cQry += " 			B2_COD, B2_LOCAL," + CRLF
_cQry += " 			B1_X_CURRA," + CRLF
_cQry += " 			B1_XLOTE," + CRLF
_cQry += " 			B1_X_ERA," + CRLF
_cQry += " 			B2_QATU," + CRLF
_cQry += "			CASE" + CRLF
_cQry += "				WHEN B1_XPESOCO = 0 AND Z08_TIPO<>'1' " + CRLF
_cQry += "					THEN MEDIA " + CRLF
_cQry += "					ELSE B1_XPESOCO " + CRLF
_cQry += "			END B1_XPESOCO, " + CRLF
_cQry += " 			B1_XLOTCOM, B1_XRACA, B1_X_SEXO, B1_XDENTIC," + CRLF
_cQry += " 			Z09_GMDESP, Z09_VLREST, Z09_DIAABT," + CRLF
_cQry += " 			B1_XDATACO," + CRLF
_cQry += " 			DiasAbate, " + CRLF
_cQry += " 			Dias, " + CRLF
_cQry += " 			PesoAtual," + CRLF
_cQry += " 			PrjecAba," + CRLF
_cQry += " 			Z09_RENESP," + CRLF
_cQry += "   			PesoFinal," + CRLF
_cQry += "   			PesoFinalTOTAL," + CRLF
_cQry += "   			PesoCarcacaFinal," + CRLF
_cQry += "			A2_NOME," + CRLF
_cQry += " 			GRUPO2" + CRLF
_cQry += " FROM DADOS " + CRLF
_cQry += " LEFT JOIN ENTRADA ON D1_FILIAL='"+FWxFilial("SD1")+"' AND D1_COD=B2_COD AND D1_LOCAL=B2_LOCAL " + CRLF
_cQry += " ) " + CRLF
/*
MB : 02.09.2020
	levei a ordenação para o SQL; a pedido do toshio
	*/
_cQry += CRLF
_cQry += " , ORDENACAO AS ( " + CRLF
_cQry += "  	SELECT B1_XLOTE, B1_X_CURRA, " + CRLF
_cQry += "	-- MAX(CONVERT(DATE,B1_XDATACO)) " + CRLF
_cQry += "		MAX( CASE B1_XDATACO  " + CRLF
_cQry += " 				WHEN ' ' THEN 0  " + CRLF
_cQry += " 				ELSE DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '" + dDTReferencia + "', 103)) " + CRLF
_cQry += " 			END) AS  " + CRLF
_cQry += "		MAIOR_DATA " + CRLF
_cQry += "  	FROM FINAL " + CRLF
_cQry += "  	GROUP BY B1_XLOTE, B1_X_CURRA " + CRLF
_cQry += CRLF
_cQry += " ) " + CRLF
_cQry += "  " + CRLF
_cQry += " SELECT    F.*  " + CRLF
_cQry += " FROM      FINAL     F " + CRLF
_cQry += "      JOIN ORDENACAO O ON O.B1_X_CURRA=F.B1_X_CURRA AND F.B1_XLOTE = O.B1_XLOTE" + CRLF
_cQry += CRLF

_cQry += " ORDER BY " + CRLF

_cQry += " 	Z08_TIPO, " + CRLF

if MV_PAR08 == 2
	_cQry += " O.MAIOR_DATA DESC, " + CRLF
	_cQry += " O.B1_X_CURRA, " + CRLF
EndIf

If nAgrup == 2
	_cQry += " PrjecAba, " + CRLF
EndIf
	
_cQry += " ORDEM, " + CRLF
_cQry += " B1_X_ERA, B2_COD, B2_LOCAL, " + CRLF

if MV_PAR08 <> 2
	_cQry += " B1_X_CURRA, " + CRLF
EndIf

_cQry += " B2_QATU DESC " + CRLF

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"Quadro1.sql" , _cQry)
EndIf
dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAliaEST),.F.,.F.) 

TcSetField(_cAliaEST, "B1_XDATACO", "D")
TcSetField(_cAliaEST, "PrjecAba"  , "D")

Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  06.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1(nAgrup, cDiasAb, dDTReferencia )

Local cXML 		 := ""
Local cWorkSheet := "1-Lista Currais"

Local aDados 	 := Array(21)
Local aDadosA 	 := Array(21)
Local cAgrupa    := ""

Local nQATU		 := 0

Local aLinVazia  := {}

	
	(_cAliaEST)->(DbGoTop())
	If !(_cAliaEST)->(Eof())  // U_VARELM01()
	
		cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		cXML += '  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
        cXML += '   <Column ss:AutoFitWidth="0" ss:Width="102"/>
        cXML += '   <Column ss:Width="42.75"/>
        cXML += '   <Column ss:Width="31.5"/>
        cXML += '   <Column ss:Width="51.75"/>
        cXML += '   <Column ss:Width="53.25"/>
        cXML += '   <Column ss:Width="50.25"/>
        cXML += '   <Column ss:Width="51"/>
        cXML += '   <Column ss:AutoFitWidth="0" ss:Width="54"/>
        cXML += '   <Column ss:AutoFitWidth="0" ss:Width="57" ss:Span="1"/>
        cXML += '   <Column ss:Index="11" ss:AutoFitWidth="0" ss:Width="42.75"/>
        cXML += '   <Column ss:AutoFitWidth="0" ss:Width="40.5"/>
        cXML += '   <Column ss:Width="27.75"/>
        cXML += '   <Column ss:Width="51"/>
        cXML += '   <Column ss:Width="51.75"/>
        cXML += '   <Column ss:Width="74.25"/>
        cXML += '   <Column ss:Width="50.25"/>
        cXML += '   <Column ss:AutoFitWidth="0" ss:Width="77.25" ss:Span="2"/>
        cXML += '   <Column ss:Index="21" ss:AutoFitWidth="0" ss:Width="197.25" ss:Span="1"/>
        cXML += '   <Row ss:AutoFitHeight="0">
        cXML += '     <Cell ss:MergeAcross="20" ss:StyleID="s62">
        cXML += '       <Data ss:Type="String">' + cTitulo + " - Dt. Referência: " + DtoC(MV_PAR04) + '</Data>
        cXML += '     </Cell>
        cXML += '   </Row>
		cXML += '   <Row ss:AutoFitHeight="0">' + CRLF
/*01 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Produto</Data></Cell>' + CRLF
/*02 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Linha</Data></Cell>' + CRLF
/*03 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Lote</Data></Cell>' + CRLF
/*04 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Entrada</Data></Cell>' + CRLF
/*05 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Era</Data></Cell>' + CRLF
/*06 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Qtde ' + SubS(dToC(sToD(dDTReferencia)),1,5)+'</Data></Cell>' + CRLF
/*07 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Media (Kg)</Data></Cell>' + CRLF
/*08 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Origem</Data></Cell>' + CRLF
/*09 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Raça</Data></Cell>' + CRLF
/*10 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Sexo</Data></Cell>' + CRLF
/*11 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Dentição</Data></Cell>' + CRLF
/*12 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Dias</Data></Cell>' + CRLF
/*13 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">GMD</Data></Cell>' + CRLF
/*14 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Atual(Kg)</Data></Cell>' + CRLF
/*15 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Dias p/ Abate</Data></Cell>' + CRLF
/*16 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Data Abate</Data></Cell>' + CRLF
/*17 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Rend. Esperado</Data></Cell>' + CRLF
/*18 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Final</Data></Cell>' + CRLF
/*19 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Final Total</Data></Cell>' + CRLF
/*20 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Final Carcaça</Data></Cell>' + CRLF
/*21 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Fornecedor</Data></Cell>' + CRLF
/*22 */ cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Observação</Data></Cell>' + CRLF
		cXML += '   </Row>' + CRLF

		aDados[02]  := 0
		aDados[06]  := 0
		aDados[18]  := 0
		aDadosA[02] := 0
		aDadosA[06] := 0
		aDadosA[18] := 0
		
		If nAgrup == 2				// U_VARELM01()
			cAgrupa := (_cAliaEST)->GRUPO2
		ElseIf nAgrup == 3
			cAgrupa	:= (_cAliaEST)->ORDEM
		EndIf
		
		// aSaldos := CalcEst( "BOV000000000003", "01" , StoD("20170101")  )		
		While !(_cAliaEST)->(Eof())
			
			If (_cAliaEST)->Z08_TIPO <> '4' .and. (_cAliaEST)->ORDEM <> '9999'
			
				If nAgrup == 2
					If cAgrupa <> (_cAliaEST)->GRUPO2 .and. aDadosA[06] <> 0
						
						cXML += '<Row ss:AutoFitHeight="0">' + CRLF
						cXML += '<Cell ss:StyleID="s72" ss:Index="2"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDadosA[02]) +'</Data></Cell>' + CRLF
						cXML += '<Cell ss:StyleID="s72" ss:Index="6"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDadosA[06]) +'</Data></Cell>' + CRLF
						cXML += '<Cell ss:StyleID="s68" ss:Index="18"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDadosA[18]) +'</Data></Cell>' + CRLF
						cXML += '</Row>' + CRLF
						
						// pular linha						
						cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
						// pular linha						
						cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
						
						aDadosA[02] := 0
						aDadosA[06] := 0
						aDadosA[18] := 0
					EndIf
					
				ElseIf nAgrup == 3
					If cAgrupa <> (_cAliaEST)->ORDEM .and. aDadosA[06] <> 0
						cXML += '<Row ss:AutoFitHeight="0">' + CRLF
						cXML += '<Cell ss:StyleID="s72" ss:Index="2"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDadosA[02]) +'</Data></Cell>' + CRLF
						cXML += '<Cell ss:StyleID="s72" ss:Index="6"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDadosA[06]) +'</Data></Cell>' + CRLF
						cXML += '<Cell ss:StyleID="s68" ss:Index="18"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDadosA[18]) +'</Data></Cell>' + CRLF
						cXML += '</Row>' + CRLF
						
						// pular linha						
						cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
						// pular linha						
						cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF

						aDadosA[02] := 0
						aDadosA[06] := 0
						aDadosA[18] := 0
					EndIf
				EndIf
				
				// http://www.helpfacil.com/forum/display_topic_threads.asp?ForumID=1&TopicID=28421&PagePosition=1
				// CalcEstL(cProduto, cAlmox, dData, cLote, cSubLote, cEnder, cSerie, lRastro) 
				
				nQATU := Iif(dDTReferencia == dToS(dDataBase), (_cAliaEST)->B2_QATU, CalcEstL( (_cAliaEST)->B2_COD, (_cAliaEST)->B2_LOCAL, sToD(dDTReferencia)+1, (_cAliaEST)->B1_XLOTE)[1] )
				If nQATU == 0	// U_varelm01()
					// guardar no vetor de listas vazias  
					if aScan(aLinVazia, { |x| AllTrim(x[1]) == AllTrim((_cAliaEST)->B1_X_CURRA) } ) == 0 ;
						.AND. (_cAliaEST)->ORDEM<>'9999'
						aAdd( aLinVazia, { (_cAliaEST)->B1_X_CURRA, .T.} )
					EndIf
				else
					
					If ( nPosLV := aScan(aLinVazia, { |x| AllTrim(x[1]) == AllTrim((_cAliaEST)->B1_X_CURRA) } ) ) > 0
						aLinVazia[nPosLV,2] := .F.
					EndIf

					cXML += '<Row>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B2_COD)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_X_CURRA)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XLOTE)+'</Data></Cell>' + CRLF
					If Empty((_cAliaEST)->B1_XDATACO)
						cXML += '  <Cell><Data ss:Type="String"></Data></Cell>' + CRLF
					Else
						cXML += '  <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'+U_FrmtVlrExcel((_cAliaEST)->B1_XDATACO)+'</Data></Cell>' + CRLF
					EndIf
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_X_ERA)+'</Data></Cell>' + CRLF
					cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel(nQATU)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->B1_XPESOCO)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XLOTCOM)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XRACA)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_X_SEXO)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XDENTIC)+'</Data></Cell>' + CRLF
					cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->Dias)+'</Data></Cell>' + CRLF
					cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->Z09_GMDESP)+'</Data></Cell>' + CRLF
					cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->PesoAtual)+'</Data></Cell>' + CRLF
					cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->DiasAbate)+'</Data></Cell>' + CRLF
					If Empty( (_cAliaEST)->PrjecAba )
						cXML += '  <Cell><Data ss:Type="String"></Data></Cell>' + CRLF
					Else
						cXML += '  <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'+U_FrmtVlrExcel((_cAliaEST)->PrjecAba)+'</Data></Cell>' + CRLF
					EndIf					
					cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->Z09_RENESP)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->PesoFinal)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->PesoFinalTOTAL)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->PesoCarcacaFinal)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->A2_NOME)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(PegaOBSB8((_cAliaEST)->B2_COD))+'</Data></Cell>' + CRLF
					cXML += '</Row>' + CRLF
					
					aAdd( aDadTp1, { (_cAliaEST)->B2_COD, ;
									  (_cAliaEST)->B1_X_CURRA, ;
									  (_cAliaEST)->B1_XLOTE, ;
									  (_cAliaEST)->B1_XDATACO, ;
									  (_cAliaEST)->B1_X_ERA, ;
									  nQATU , ;
									  (_cAliaEST)->B1_XPESOCO, ;
									  (_cAliaEST)->B1_XLOTCOM, ;
									  (_cAliaEST)->B1_XRACA, ;
									  (_cAliaEST)->B1_X_SEXO, ;
									  (_cAliaEST)->B1_XDENTIC, ;
									  (_cAliaEST)->Dias, ;
									  (_cAliaEST)->Z09_GMDESP, ;
									  (_cAliaEST)->PesoAtual, ;
									  (_cAliaEST)->DiasAbate, ;
									  (_cAliaEST)->PrjecAba, ;
									  (_cAliaEST)->Z09_RENESP, ;
									  (_cAliaEST)->PesoFinal, ;
									  (_cAliaEST)->PesoFinalTOTAL, ;
									  (_cAliaEST)->PesoCarcacaFinal } )
									  
					If nAgrup == 2
						cAgrupa := (_cAliaEST)->GRUPO2
						
						aDadosA[02] += 1		           // Curral : Qtde de registros
						aDadosA[06] += nQATU // Qtde
						aDadosA[18] += (_cAliaEST)->PesoFinalTOTAL // Qtde
					
					ElseIf nAgrup == 3
						cAgrupa := (_cAliaEST)->ORDEM
						
						aDadosA[02] += 1		           // Curral : Qtde de registros
						aDadosA[06] += nQATU // Qtde
						aDadosA[18] += (_cAliaEST)->PesoFinalTOTAL // Qtde
					EndIf

					aDados[02] += 1		           // Curral : Qtde de registros
					aDados[06] += nQATU // Qtde
					aDados[18] += (_cAliaEST)->PesoFinalTOTAL // Qtde
					
				EndIf
			EndIf
			
			(_cAliaEST)->(DbSkip())
		EndDo

		cXML += '<Row ss:AutoFitHeight="0">' + CRLF+;
				'<Cell ss:StyleID="s72" ss:Index="2"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDadosA[02]) +'</Data></Cell>' + CRLF+;
				'<Cell ss:StyleID="s72" ss:Index="6"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDadosA[06]) +'</Data></Cell>' + CRLF+;
				'<Cell ss:StyleID="s68" ss:Index="18"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDadosA[18]) +'</Data></Cell>' + CRLF+;
				'</Row>' + CRLF
		
		// pular linha						
		cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
		// pular linha						
		cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
		
		cXML += '<Row ss:AutoFitHeight="0">' + CRLF+;
				'<Cell ss:StyleID="s72" ss:Index="2"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDados[02]) +'</Data></Cell>' + CRLF+;
				'<Cell ss:StyleID="s72" ss:Index="6"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDados[06]) +'</Data></Cell>' + CRLF+;
				'<Cell ss:StyleID="s68" ss:Index="18"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDados[18]) +'</Data></Cell>' + CRLF+;
				'</Row>' + CRLF
	
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
        cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
        cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
        cXML += '  </WorksheetOptions>' + CRLF
        cXML += ' </Worksheet>' + CRLF
		
		If !Empty(cXML) .and. MV_PAR06 == 1
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""	
	EndIf
	
	// (_cAlia)->(DbCloseArea()) // nao fechar alias, pois usarei ele no proximo quadro
	
	// Final da Planilha
Return aLinVazia	// U_VARELM01()
// FIM DA FUNCAO: fQuadro1


/* MJ : 04.04.2018
	# Processamento do quadro 1 - sintetico 
		-> 26.04.2018: Alteracao, inclusao de quadro de parametros
*/
Static Function sQuadro1s(nAgrup, cDiasAb, dDTReferencia )

Local cWorkSheet := "2-Currais - Sintetico"
// Local aDados 	 := Array(26)
// Local aDados 	 := Array(26)
// Local aDadosA 	 := Array(26)
Local aDadSint	 := {} // Array(26)
//Local aDadCont	 := {}
Local cLinha     := ""
Local cEra    	 := ""

Local nQATU		 := 0, nI := 1, nQtLinCLT := 0
Local nRSPadArb	 := GetMV('VA_VLRAROB',,155)//, nVlrArrob := 0
// Local nPesCarc	 := 0, nVlrTotEst := 0
Local cXMLCab	 := "" // Cabeçalho
Local cXML 	 	 := "" // Quadro Principal

// Qadro Parametros
Local aQuaPar	 := {}
Local aQuaRes	 := {}

	TcSetField(_cAliaEST, "B1_XDATACO", "D")
	TcSetField(_cAliaEST, "PrjecAba"  , "D")
	
	(_cAliaEST)->(DbGoTop())
	If (_cAliaEST)->(Eof())	 // U_VARELM01()
		MsgAlert("Não foi localizado informacao para o Quadro: " + cWorkSheet )
	Else
	
		// cLinha	:= (_cAliaEST)->ORDEM
		cLinha	:= ""
		cEra	:= ""
		aDadSint := {}		
		
		// proccessando dados - agrupando informacoes
		While !(_cAliaEST)->(Eof())
			If (_cAliaEST)->Z08_TIPO <> '4' .and. (_cAliaEST)->ORDEM <> '9999'
				nQATU := Iif(dDTReferencia == dToS(dDataBase), (_cAliaEST)->B2_QATU, CalcEstL( (_cAliaEST)->B2_COD, (_cAliaEST)->B2_LOCAL, sToD(dDTReferencia)+1, (_cAliaEST)->B1_XLOTE)[1] )
				If nQATU <> 0
			
					// if AllTrim((_cAliaEST)->B1_X_CURRA) == 'E07'
						// Alert('Debugando')
					// EndIf
					
					If cLinha <> (_cAliaEST)->ORDEM .or. cEra <> (_cAliaEST)->B1_X_ERA 
						aAdd( aDadSint		 , {} 								)  
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_X_CURRA          )  // 01
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_XLOTE            )  // 02
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_XDATACO          )  // 03
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_X_ERA            )  // 04
						aAdd( aTail(aDadSint), nQATU                            )  // 05
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_XPESOCO          )  // 06
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_XLOTCOM          )  // 07
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_XRACA            )  // 08
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_X_SEXO           )  // 09
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_XDENTIC          )  // 09
						aAdd( aTail(aDadSint), (_cAliaEST)->Dias                )  // 10 
						aAdd( aTail(aDadSint), (_cAliaEST)->Z09_GMDESP          )  // 11
						aAdd( aTail(aDadSint), (_cAliaEST)->PesoAtual           )  // 12
						
						aAdd( aTail(aDadSint), 0			            		)  // 13
						aAdd( aTail(aDadSint), 0 								)  // 14
						aAdd( aTail(aDadSint), 0 								)  // 15
						
						aAdd( aTail(aDadSint), (_cAliaEST)->DiasAbate           )  // 16
						aAdd( aTail(aDadSint), (_cAliaEST)->PrjecAba            )  // 17
						aAdd( aTail(aDadSint), (_cAliaEST)->Z09_RENESP          )  // 18
						aAdd( aTail(aDadSint), (_cAliaEST)->PesoFinal           )  // 19
						aAdd( aTail(aDadSint), (_cAliaEST)->PesoFinalTOTAL      )  // 20
						aAdd( aTail(aDadSint), (_cAliaEST)->PesoCarcacaFinal    )  // 21
						
						aAdd( aTail(aDadSint), 0					            )  // 22
						aAdd( aTail(aDadSint), 0 								)  // 23
						
						aAdd( aTail(aDadSint), AllTrim( (_cAliaEST)->A2_NOME )  )  // 24
						aAdd( aTail(aDadSint), AllTrim( PegaOBSB8((_cAliaEST)->B2_COD) ) )  // 25
						aAdd( aTail(aDadSint), AllTrim( (_cAliaEST)->B2_COD	)	)  // 26
						
						// Controlar a quantidade de registros UNIFICADOS para calculo da MEDIA
						aAdd( aTail(aDadSint), 1								)  // 27
						// nao musar este cara da posicao 27
						
						// Contador - Agrupamento - Media
						//aAdd( aDadCont, 1 ) 
						
						// ADICIONAR RESUMO PARA O QUADRO DOS PARAMETROS
						if aScan( aQuaPar, { |x| x[1] == AllTrim((_cAliaEST)->B1_X_ERA)+AllTrim((_cAliaEST)->B1_XRACA)+AllTrim((_cAliaEST)->B1_X_SEXO)/* +AllTrim((_cAliaEST)->B1_XDENTIC) */ } ) == 0
							aAdd( aQuaPar		 , {} 								)  
							aAdd( aTail(aQuaPar) , AllTrim((_cAliaEST)->B1_X_ERA)+AllTrim((_cAliaEST)->B1_XRACA)+AllTrim((_cAliaEST)->B1_X_SEXO)/* +AllTrim((_cAliaEST)->B1_XDENTIC) */ )  // 01
							aAdd( aTail(aQuaPar) , (_cAliaEST)->B1_X_ERA            )  // 02
							aAdd( aTail(aQuaPar) , (_cAliaEST)->B1_XRACA            )  // 03
							aAdd( aTail(aQuaPar) , (_cAliaEST)->B1_X_SEXO           )  // 04
							// aAdd( aTail(aQuaPar) , (_cAliaEST)->B1_XDENTIC           )  // 04
							aAdd( aTail(aQuaPar) , iIf( Empty((_cAliaEST)->Z09_VLREST), nRSPadArb , (_cAliaEST)->Z09_VLREST ) )  // 05
							aAdd( aTail(aQuaPar) , (_cAliaEST)->Z09_GMDESP			)  // 06
							aAdd( aTail(aQuaPar) , (_cAliaEST)->Z09_RENESP			)  // 07
							aAdd( aTail(aQuaPar) , iIf( Empty((_cAliaEST)->Z09_DIAABT), Val(cDiasAb) , (_cAliaEST)->Z09_DIAABT ) )  // 08
						EndIf
						
						if aScan( aQuaRes, { |x| x[1] == AllTrim((_cAliaEST)->B1_X_ERA) } ) == 0
							aAdd( aQuaRes		 , {} 							  )  
							aAdd( aTail(aQuaRes) , AllTrim((_cAliaEST)->B1_X_ERA) )  // 01
						EndIf
						
					Else
						
						// aDadCont[len(aDadCont)] += 1
						aDadSint[ Len(aDadSint), 28 ] += 1
						
						// "Qtde "
						aDadSint[ Len(aDadSint), 5] += nQATU
						// "Média (Kg)" 	     	
						aDadSint[ Len(aDadSint), 6] += (_cAliaEST)->B1_XPESOCO
						// "Origem" 
						If Empty(aDadSint[ Len(aDadSint), 7])
							aDadSint[ Len(aDadSint), 7] := (_cAliaEST)->B1_XLOTCOM

						EndIf
						// "Peso Atual(Kg)"	 	
						aDadSint[ Len(aDadSint), 13] += (_cAliaEST)->PesoAtual
						
						// Data Abate
						If Empty( aDadSint[ Len(aDadSint), 18] )
							aDadSint[ Len(aDadSint), 18] := (_cAliaEST)->PrjecAba
						EndIF
						
						// "Peso Final Total"	
						aDadSint[ Len(aDadSint), 21] += (_cAliaEST)->PesoFinalTOTAL
						// "Peso Final Carcaça"	
						aDadSint[Len(aDadSint),22] += (_cAliaEST)->PesoCarcacaFinal
						
						// "Fornecedor"			
						xAux := AllTrim( (_cAliaEST)->A2_NOME )
						If Empty( xAux $ aDadSint[Len(aDadSint),25] ) 
							aDadSint[Len(aDadSint),25] += Iif(Empty(aDadSint[Len(aDadSint),25]), "", Iif(Empty(xAux), "", " | ")) + xAux
						EndIf
						// "Observação"
						xAux := AllTrim( PegaOBSB8((_cAliaEST)->B2_COD) )
						If Empty( xAux $ aDadSint[Len(aDadSint),26] )
							aDadSint[Len(aDadSint),26] += Iif(Empty(aDadSint[Len(aDadSint),26]), "", Iif(Empty(xAux), "", " | ")) + xAux
						EndIf						
						// "Produto"	
						aDadSint[ Len(aDadSint), 27] += Iif(Empty(aDadSint[Len(aDadSint), 27]), "", " | ") + AllTrim( (_cAliaEST)->B2_COD )
					EndIf
					cLinha := (_cAliaEST)->ORDEM 
					cEra   := (_cAliaEST)->B1_X_ERA
				EndIf
			EndIf
			
			(_cAliaEST)->(DbSkip())
		EndDo
		
		nQtLinC := Len(aQuaPar) + 4
		
		cXML := '   <Row ss:AutoFitHeight="0">' + CRLF
		cXML += ' 		<Cell ss:Index="15" ss:MergeAcross="4" ss:StyleID="s106"><Data ss:Type="String">A T U A L</Data></Cell>' + CRLF
		cXML += ' 		<Cell ss:Index="20" ss:MergeAcross="5" ss:StyleID="s112"><Data ss:Type="String">F I N A L</Data></Cell>' + CRLF
		cXML += '   </Row>' + CRLF
		nQtLinC += 1
		
		// impressao do titulo do QUADRO PRINCIPAL
		cXML += '   <Row ss:Height="54" ss:StyleID="s91">' + CRLF
/* 02 */ 	cXML += '    <Cell ss:Index="2" ss:StyleID="s65"><Data ss:Type="String">Linha</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Lote</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Entrada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Era</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Qtde ' + SubS(dToC(sToD(dDTReferencia)),1,5)+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">GMD</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ @</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Rend. Esperado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Apartação Média (Kg)</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Origem</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Raça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Sexo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Dentição</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 14 */ 	cXML += '    <Cell ss:StyleID="s106"><Data ss:Type="String">Dias</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 15 */ 	cXML += '    <Cell ss:StyleID="s106"><Data ss:Type="String">Peso Atual(Kg)</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 16 */ 	cXML += '    <Cell ss:StyleID="s106"><Data ss:Type="String">Peso Final Atual</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 17 */ 	cXML += '    <Cell ss:StyleID="s106"><Data ss:Type="String">Peso Carcaça Atual</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 18 */ 	cXML += '    <Cell ss:StyleID="s106"><Data ss:Type="String">R$ Total Estoque Atual</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 19 */ 	cXML += '    <Cell ss:StyleID="s112"><Data ss:Type="String">Dias p/ Abate</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 20 */ 	cXML += '    <Cell ss:StyleID="s112"><Data ss:Type="String">Data Abate</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 21 */ 	cXML += '    <Cell ss:StyleID="s112"><Data ss:Type="String">Peso Final</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 22 */ 	cXML += '    <Cell ss:StyleID="s112"><Data ss:Type="String">Peso Final Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 23 */ 	cXML += '    <Cell ss:StyleID="s112"><Data ss:Type="String">Peso Final Carcaça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 24 */ 	cXML += '    <Cell ss:StyleID="s112"><Data ss:Type="String">R$ Total Venda Abate</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 25 */ 	cXML += '    <Cell ss:StyleID="s70"><Data ss:Type="String">Fornecedor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 26 */ 	cXML += '    <Cell ss:StyleID="s70"><Data ss:Type="String">Observacao</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 27 */ 	cXML += '    <Cell ss:StyleID="s70"><Data ss:Type="String">Produto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '   </Row>' + CRLF
		nQtLinC += 1
		/*
			MB : 02.09.2020
				levei a ordenação para o SQL; a pedido do toshio
		if MV_PAR08 == 2
			aSort( aDadSint ,,, {|x,y| DtoS(x[3])+AllTrim(x[1])+AllTrim(x[2]) < DtoS(y[3])+AllTrim(y[1])+AllTrim(y[2]) } )
		EndIf
		*/
		// impressao do QUADRO PRINCIPAL
		nI 		:= 1
		While nI <= Len( aDadSint )
			
			cXML += '<Row>' + CRLF
/* 02 */   	cXML += '  <Cell ss:Index="2" ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 01])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 02])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
           	If Empty( aDadSint[ nI, 03] )
/* 04 */   		cXML += '  <Cell><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
           	Else
/* 04 */   		cXML += '  <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'+U_FrmtVlrExcel(aDadSint[ nI, 03])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
           	EndIf
/* 05 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 04])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */   	cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel(aDadSint[ nI, 05])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */   	cXML += '  <Cell ss:Formula="=IFERROR(VLOOKUP(CONCATENATE(RC5,RC12,RC13),R5C1:R'+AllTrim(Str(Len(aQuaPar)+4))+'C8,6,),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */   	cXML += '  <Cell ss:StyleID="s69" ss:Formula="=IFERROR(VLOOKUP(CONCATENATE(RC5,RC12,RC13),R5C1:R'+AllTrim(Str(Len(aQuaPar)+4))+'C8,5,),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */   	cXML += '  <Cell ss:Formula="=IFERROR(VLOOKUP(CONCATENATE(RC5,RC12,RC13),R5C1:R'+AllTrim(Str(Len(aQuaPar)+4))+'C8,7,),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */   	cXML += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel( aDadSint[ nI, 06] / aDadSint[ nI, 28 ] )+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 07])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 08])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 09])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 14 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 10])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 15 */   	cXML += '  <Cell ss:Formula="=IFERROR(R5C11-RC4,&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 16 */   	cXML += '  <Cell ss:StyleID="s68" ss:Formula="=IFERROR(RC[-6]+(RC[-1]*RC[-9]),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 17 */   	cXML += '  <Cell ss:StyleID="s68" ss:Formula="=IFERROR(RC[-1]*RC[-11],&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 18 */   	cXML += '  <Cell ss:StyleID="s68" ss:Formula="=IFERROR(RC[-2]*(RC[-9]/100),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 19 */   	cXML += '  <Cell ss:StyleID="s69" ss:Formula="=IFERROR((RC[-1]/15)*RC[-11]*RC[-13],&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 20 */   	cXML += '  <Cell ss:Formula="=IFERROR(IF(RC[-5]&gt;VLOOKUP(CONCATENATE(RC5,RC12,RC13),R5C1:R'+AllTrim(Str(Len(aQuaPar)+4))+'C8,8,),RC[-5],VLOOKUP(CONCATENATE(RC5,RC12,RC13),R5C1:R'+AllTrim(Str(Len(aQuaPar)+4))+'C8,8,)),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 21 */   	cXML += '  <Cell ss:StyleID="s67" ss:Formula="=IFERROR(RC[-1]+RC[-17],&quot;&quot;)"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 22 */   	cXML += '  <Cell ss:StyleID="s68" ss:Formula="=IFERROR(RC[-12]+(RC[-2]*RC[-15]),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 23 */   	cXML += '  <Cell ss:StyleID="s68" ss:Formula="=IFERROR(RC[-1]*RC[-17],&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 24 */   	cXML += '  <Cell ss:StyleID="s68" ss:Formula="=IFERROR(RC[-2]*(RC[-15]/100),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 25 */   	cXML += '  <Cell ss:StyleID="s69" ss:Formula="=IFERROR((RC[-1]/15)*RC[-17]*RC[-19],&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 26 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 25])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 27 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 26])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 28 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 27])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF			
           	cXML += '</Row>' + CRLF
			nQtLinCLT += 1
			nQtLinC   += 1

			// U_VARELM01()
			if nI < Len( aDadSint ) // estou no ULTIMO
				If AllTrim( aDadSint[nI+1, 1] ) <> AllTrim( aDadSint[nI, 1] ) // .AND. aDadSint[nI+1, 4] <> aDadSint[nI, 4]
					// proxima linha diferente, entao mudou a LINHA; colocar soma
					cXML += '<Row ss:AutoFitHeight="0">' + CRLF
					cXML += '	<Cell ss:StyleID="s72" ss:Index="06" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinCLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					cXML += '	<Cell ss:StyleID="s68" ss:Index="17" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinCLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					cXML += '	<Cell ss:StyleID="s69" ss:Index="19" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinCLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					cXML += '	<Cell ss:StyleID="s68" ss:Index="23" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinCLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					cXML += '	<Cell ss:StyleID="s69" ss:Index="25" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinCLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					cXML += '</Row>' + CRLF				
					nQtLinCLT := 0
					nQtLinC   += 1	
					
					cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF	; nQtLinC += 1
				EndIf
			Else
				// proxima linha diferente, entao mudou a LINHA; colocar soma
				cXML += '<Row ss:AutoFitHeight="0">' + CRLF
				cXML += '	<Cell ss:StyleID="s72" ss:Index="06" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinCLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s68" ss:Index="17" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinCLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s69" ss:Index="19" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinCLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s68" ss:Index="23" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinCLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s69" ss:Index="25" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinCLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '</Row>' + CRLF				
				// nQtLinCLT := 0
				nQtLinC   += 1
				
				// acabou o Vetor .. imprimir a soma total
				cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF 	; nQtLinC += 1
				cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF   ; nQtLinC += 1
				cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF   ; nQtLinC += 1
				
				// TOTAL GERAL => Final do relatorio
				cXML += '<Row ss:AutoFitHeight="0">' + CRLF
				cXML += '	<Cell ss:StyleID="s84" ss:Index="06" ss:Formula="=SUMIF(R[-'+AllTrim(Str(nQtLinC-Len(aQuaPar)  ))+']C5:R[-1]C5,&quot;&quot;,R[-'+AllTrim(Str(nQtLinC-Len(aQuaPar)  ))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s86" ss:Index="16" ss:Formula="=RC[1]/RC[-10]"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s86" ss:Index="17" ss:Formula="=SUMIF(R[-'+AllTrim(Str(nQtLinC-Len(aQuaPar)  ))+']C5:R[-1]C5,&quot;&quot;,R[-'+AllTrim(Str(nQtLinC-Len(aQuaPar)  ))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s85" ss:Index="19" ss:Formula="=SUMIF(R[-'+AllTrim(Str(nQtLinC-Len(aQuaPar)  ))+']C5:R[-1]C5,&quot;&quot;,R[-'+AllTrim(Str(nQtLinC-Len(aQuaPar)  ))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s86" ss:Index="22" ss:Formula="=RC[1]/RC[-16]"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s86" ss:Index="23" ss:Formula="=SUMIF(R[-'+AllTrim(Str(nQtLinC-Len(aQuaPar)  ))+']C5:R[-1]C5,&quot;&quot;,R[-'+AllTrim(Str(nQtLinC-Len(aQuaPar)  ))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s85" ss:Index="25" ss:Formula="=SUMIF(R[-'+AllTrim(Str(nQtLinC-Len(aQuaPar)  ))+']C5:R[-1]C5,&quot;&quot;,R[-'+AllTrim(Str(nQtLinC-Len(aQuaPar)  ))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '</Row>' + CRLF				
			EndIf
			nI += 1
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
        cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
        cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
        cXML += '  </WorksheetOptions>' + CRLF
		cXML += '  <AutoFilter x:Range="R'+AllTrim(Str(Len(aQuaPar)+7))+'C1:R'+AllTrim(Str(nQtLinC+2))+'C27" xmlns="urn:schemas-microsoft-com:office:excel"></AutoFilter>
        cXML += ' </Worksheet>' + CRLF
		
		/* O CABECALHO PRECISA SER FEITO NO FINAL, pois para fazer o filtro automatico, preciso do numero total de linhas. */
		// Cabeçalho XML	//  "2-Currais - Sintetico"
		cXMLCab := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		cXMLCab += ' <Names>
		cXMLCab += ' 	<NamedRange ss:Name="_FilterDatabase"

		cAux := "'2-Currais - Sintetico'"
		cXMLCab += ' 		ss:RefersTo="='+ cAux +'!R'+AllTrim(Str(Len(aQuaPar)+7))+'C1:R'+AllTrim(Str(nQtLinC+2))+'C27" ss:Hidden="1"/>
		cXMLCab += ' </Names>
		cXMLCab += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
		cXMLCab += ' <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="168.75"/>
		cXMLCab += ' <Column ss:Width="97.875"/>
		cXMLCab += ' <Column ss:Width="67.875"/>
		cXMLCab += ' <Column ss:Width="60.75"/>
		cXMLCab += ' <Column ss:Width="97.875"/>
		cXMLCab += ' <Column ss:Width="49.5"/>
		cXMLCab += ' <Column ss:Width="73.125"/>
		cXMLCab += ' <Column ss:Width="61.125"/>
		cXMLCab += ' <Column ss:Index="11" ss:Width="57.75"/>
		cXMLCab += ' <Column ss:Width="55.5"/>
		cXMLCab += ' <Column ss:Width="97.875"/>
		cXMLCab += ' <Column ss:Width="55.875"/>
		cXMLCab += ' <Column ss:Width="104.25"/>
		cXMLCab += ' <Column ss:Width="75"/>
		cXMLCab += ' <Column ss:Width="97.5"/>
		cXMLCab += ' <Column ss:Width="59.625"/>
		cXMLCab += ' <Column ss:Width="103.125"/>
		cXMLCab += ' <Column ss:Width="33.75"/>
		cXMLCab += ' <Column ss:Width="60.75"/>
		cXMLCab += ' <Column ss:Width="49.5"/>
		cXMLCab += ' <Column ss:Width="61.875"/>
		cXMLCab += ' <Column ss:Width="49.5"/>
		cXMLCab += ' <Column ss:Width="103.125"/>
		cXMLCab += ' <Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="198.375" ss:Span="2"/>
		
		// Cabeçalho XML	//  "2-Currais - Sintetico"
		cXMLCab += ' <Row ss:Height="15.375">
		cXMLCab += '   <Cell ss:Index="2" ss:MergeAcross="25" ss:StyleID="s62">
        cXMLCab += '   	<Data ss:Type="String">' + cTitulo + " - Dt. Referência: " + DtoC(MV_PAR04) + '</Data>
        cXMLCab += '   </Cell>
        cXMLCab += ' </Row>
		nQtLinC += 1
		
		// Parametros
		cXMLCab += ' <Row ss:Height="15.375">
		cXMLCab += ' 	<Cell ss:Index="2"  ss:MergeAcross="6" ss:StyleID="s93"><Data ss:Type="String">Parâmetros</Data></Cell>
		cXMLCab += ' 	<Cell ss:Index="13" ss:MergeAcross="5" ss:StyleID="s93"><Data ss:Type="String">Resumo por Era</Data></Cell>
		cXMLCab += ' </Row>
		nQtLinC += 1
		
		cXMLCab += ' <Row ss:Height="15">
        cXMLCab += '   <Cell ss:Index="2" ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        
		cXMLCab += '   <Cell ss:Index="11" ss:StyleID="s65"><Data ss:Type="String">Data</Data></Cell>
		
		cXMLCab += '   <Cell ss:Index="13" ss:MergeAcross="1" ss:StyleID="s65"><Data ss:Type="String">B A I A S</Data></Cell>' + CRLF
		cXMLCab += '   <Cell               ss:MergeAcross="1" ss:StyleID="s106"><Data ss:Type="String">A T U A L</Data></Cell>' + CRLF
		cXMLCab += '   <Cell               ss:MergeAcross="1" ss:StyleID="s112"><Data ss:Type="String">F I N A L</Data></Cell>' + CRLF
	
		cXMLCab += ' </Row>
		nQtLinC += 1
		
		// colunas titulos parametros
		cXMLCab += ' <Row ss:Height="15">
        cXMLCab += '   <Cell ss:Index="2" ss:StyleID="s65"><Data ss:Type="String">Era</Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Raça</Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Sexo</Data></Cell>
        // cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Dentição</Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">R$ @</Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">GMD</Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Rend. Esperado</Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Dias p/ Abate</Data></Cell>
		
		cXMLCab += '   <Cell ss:Index="11" ss:StyleID="s65"><Data ss:Type="String">Referência</Data></Cell>
		
		cXMLCab += '   <Cell ss:Index="13" ss:StyleID="s65"><Data ss:Type="String">Era</Data></Cell>
		cXMLCab += '   <Cell               ss:StyleID="s65"><Data ss:Type="String">Qt. Cabecas</Data></Cell>
		cXMLCab += '   <Cell               ss:StyleID="s106"><Data ss:Type="String">R$ Total Estoque Atual</Data></Cell>
		cXMLCab += '   <Cell               ss:StyleID="s106"><Data ss:Type="String">R$ / Cabeças</Data></Cell>
		cXMLCab += '   <Cell               ss:StyleID="s112"><Data ss:Type="String">R$ Total Venda Abate</Data></Cell>
		cXMLCab += '   <Cell               ss:StyleID="s112"><Data ss:Type="String">R$ / Cabeças</Data></Cell>	
		cXMLCab += ' </Row>
		nQtLinC += 1
		
		// Imprimir quadros com os parametros
		aSort( aQuaRes ,,, {|x,y| x[1] < y[1] } )	// na posicao 1, esta conctenado ERA + RAÇA + SEXO
		aSort( aQuaPar ,,, {|x,y| x[1] < y[1] } )	// na posicao 1, esta conctenado ERA + RAÇA + SEXO
		For nI := 1 to Len(aQuaPar)
			cXMLCab += '<Row>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aQuaPar[ nI, 01])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aQuaPar[ nI, 02])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aQuaPar[ nI, 03])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aQuaPar[ nI, 04])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s69"><Data ss:Type="Number">'+U_FrmtVlrExcel(aQuaPar[ nI, 05])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel(aQuaPar[ nI, 06])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel(aQuaPar[ nI, 07])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel(aQuaPar[ nI, 08])+'</Data></Cell>' + CRLF
			
			if nI == 1
				If sToD(dDTReferencia) == dDataBase
					cXMLCab += ' 	<Cell ss:Index="11" ss:StyleID="s67" ss:Formula="=TODAY()"><Data ss:Type="DateTime"></Data></Cell>
				Else
					cXMLCab += ' 	<Cell ss:Index="11" ss:StyleID="s67"><Data ss:Type="DateTime">'+U_FrmtVlrExcel(sToD(dDTReferencia))+'</Data></Cell>
				EndIf				
			EndIf
			
			if nI <= Len(aQuaRes)
				cXMLCab += '   <Cell ss:Index="13" ss:StyleID="s66"><Data ss:Type="String">' + U_FrmtVlrExcel( aQuaRes[nI, 01] ) +'</Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s72" ss:Formula="=SUMIF(R'+AllTrim(Str(Len(aQuaPar)+8))+'C5:R'+AllTrim(Str(nQtLinC-3))+'C5,RC13,R'+AllTrim(Str(Len(aQuaPar)+8))+'C6:R'+AllTrim(Str(nQtLinC-3))+'C6)"><Data ss:Type="Number"></Data></Cell>'+CRLF
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=SUMIF(R'+AllTrim(Str(Len(aQuaPar)+8))+'C5:R'+AllTrim(Str(nQtLinC-3))+'C5,RC13,R'+AllTrim(Str(Len(aQuaPar)+8))+'C19:R'+AllTrim(Str(nQtLinC-3))+'C19)"><Data ss:Type="Number"></Data></Cell>'+CRLF
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=SUMIF(R'+AllTrim(Str(Len(aQuaPar)+8))+'C5:R'+AllTrim(Str(nQtLinC-3))+'C5,RC13,R'+AllTrim(Str(Len(aQuaPar)+8))+'C25:R'+AllTrim(Str(nQtLinC-3))+'C25)"><Data ss:Type="Number"></Data></Cell>'+CRLF
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-4]"><Data ss:Type="Number"></Data></Cell>
			
			ElseIf nI == Len(aQuaRes)+1
				cXMLCab += '   <Cell ss:Index="13" ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s72" ss:Formula="=SUM(R[-'+AllTrim(Str(Len(aQuaRes)))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=SUM(R[-'+AllTrim(Str(Len(aQuaRes)))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=SUM(R[-'+AllTrim(Str(Len(aQuaRes)))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-4]"><Data ss:Type="Number"></Data></Cell>
			EndIf
			
			cXMLCab += '</Row>' + CRLF
		next nI
		nFimParC	:= Len(aQuaPar)
		
		cXMLCab += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXMLCab + cXML ) )
			cXMLCab	:= ""
			cXML 	:= ""
		EndIf
		
	EndIf

Return aDadSint		// U_VARELM01()
// FIM DA FUNCAO: sQuadro1s

/*--------------------------------------------------------------------------------,
 | Func:  		                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  06.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro4( dDTReferencia, cDiasAb, nAgrup )
Local cXML	     := ""
// Local _cQry      := ""
// Local _cAlia     := CriaTrab(,.F.)   
Local cWorkSheet := "3-Lista Pastos"
Local nQATU		 := 0

Local aDados 	 := Array(15)
Local aDadosA 	 := Array(15)
Local cAgrupa    := ""

	(_cAliaEST)->(DbGoTop())
	If (_cAliaEST)->(Eof())  	 // U_VARELM01()
		MsgAlert("Não foi localizado informacao para o Quadro 1: Lista-Tipo1" )
	Else
		cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth="45" ss:DefaultRowHeight="13.5">
        cXML += ' <Column ss:Width="82.125"/>
        cXML += ' <Column ss:Width="53.25"/>
        cXML += ' <Column ss:Width="58.5"/>
        cXML += ' <Column ss:Width="48.375"/>
        cXML += ' <Column ss:Width="97.875"/>
        cXML += ' <Column ss:Width="49.5"/>
        cXML += ' <Column ss:Width="50.25"/>
        cXML += ' <Column ss:Width="43.125"/>
        cXML += ' <Column ss:Width="67.875"/>
        cXML += ' <Column ss:Width="37.5"/>
        cXML += ' <Column ss:Width="22.875"/>
        cXML += ' <Column ss:Width="25.125"/>
        cXML += ' <Column ss:Width="69"/>
        cXML += ' <Column ss:StyleID="s69" ss:AutoFitWidth="0" ss:Width="198.375" ss:Span="1"/>
        cXML += ' <Row ss:Height="15.375">
        cXML += '  <Cell ss:MergeAcross="14" ss:StyleID="s62">
        cXML += '       <Data ss:Type="String">' + cTitulo + " - Dt. Referência: " + DtoC(MV_PAR04) + '</Data>
        cXML += '     </Cell>
        cXML += '   </Row>
		cXML += '<Row ss:Height="13.875">
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">Produto</Data></Cell> ' // 01
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">Linha</Data></Cell>' 	// 02
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">Lote</Data></Cell>' 	// 03
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">Entrada</Data></Cell>' 	// 04
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">Era</Data></Cell>' 		// 05
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">Qtde '+ SubS(dToC(sToD(dDTReferencia)),1,5)+'</Data></Cell>
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">Média (Kg)</Data></Cell>' // 07
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">Origem</Data></Cell>'     // 08
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">Raça</Data></Cell>'       // 09
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">Sexo</Data></Cell>'       // 10
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">Dentição</Data></Cell>'   // 11
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">Dias</Data></Cell>'       // 12
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">GMD</Data></Cell>'        // 13
        cXML += ' <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Atual(Kg)</Data></Cell>'// 14
        cXML += ' <Cell ss:StyleID="s70"><Data ss:Type="String">Fornecedor</Data></Cell>' // 15
        cXML += ' <Cell ss:StyleID="s70"><Data ss:Type="String">Observacao</Data></Cell>' // 16
        cXML += '</Row>' + CRLF
		
		aDados[02]  := 0
		aDados[06]  := 0
		aDadosA[02]  := 0
		aDadosA[06]  := 0
		
		cAgrupa := (_cAliaEST)->GRUPO2
		
		While !(_cAliaEST)->(Eof())
			
			If (_cAliaEST)->Z08_TIPO <> '1'
			
				If nAgrup == 3
					If cAgrupa <> (_cAliaEST)->ORDEM .and. aDadosA[06] <> 0
					
						cXML += '<Row ss:AutoFitHeight="0">' + CRLF
						cXML += '	<Cell ss:StyleID="s72" ss:Index="02"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDadosA[02]) +'</Data></Cell>' + CRLF
						cXML += '	<Cell ss:StyleID="s72" ss:Index="06"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDadosA[06]) +'</Data></Cell>' + CRLF
						cXML += '</Row>' + CRLF				
					
						cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF 
						cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF 
						
						aDadosA[02] := 0
						aDadosA[06] := 0
					EndIf
				EndIf
			
				nQATU := Iif(dDTReferencia == dToS(dDataBase), (_cAliaEST)->B2_QATU, CalcEstL( (_cAliaEST)->B2_COD, (_cAliaEST)->B2_LOCAL, sToD(dDTReferencia)+1, (_cAliaEST)->B1_XLOTE)[1] )
				If nQATU <> 0
					
					cXML += '<Row>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B2_COD)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_X_CURRA)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XLOTE)+'</Data></Cell>' + CRLF
					If Empty((_cAliaEST)->B1_XDATACO)
						cXML += '  <Cell><Data ss:Type="String"></Data></Cell>' + CRLF
					Else
						cXML += '  <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'+U_FrmtVlrExcel((_cAliaEST)->B1_XDATACO)+'</Data></Cell>' + CRLF
					EndIf
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_X_ERA)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s72"><Data ss:Type="Number">'+U_FrmtVlrExcel(nQATU)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->B1_XPESOCO)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XLOTCOM)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XRACA)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_X_SEXO)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XDENTIC)+'</Data></Cell>' + CRLF
					cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->Dias)+'</Data></Cell>' + CRLF
					cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->Z09_GMDESP)+'</Data></Cell>' + CRLF
					cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->PesoAtual)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->A2_NOME)+'</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(PegaOBSB8((_cAliaEST)->B2_COD))+'</Data></Cell>' + CRLF
					cXML += '</Row>' + CRLF
					
					aAdd( aDadTp4, { (_cAliaEST)->B2_COD, ;
									 (_cAliaEST)->B1_X_CURRA, ;
									 (_cAliaEST)->B1_XLOTE, ;
									 (_cAliaEST)->B1_XDATACO, ;
									 (_cAliaEST)->B1_X_ERA, ;
									 nQATU, ;
									 (_cAliaEST)->B1_XPESOCO, ;
									 (_cAliaEST)->B1_XLOTCOM, ;
									 (_cAliaEST)->B1_XRACA, ;
									 (_cAliaEST)->B1_X_SEXO, ;
									 (_cAliaEST)->B1_XDENTIC, ;
									 (_cAliaEST)->Dias, ;
									 (_cAliaEST)->Z09_GMDESP, ;
									 (_cAliaEST)->PesoAtual } )
					
					If nAgrup == 3
						cAgrupa := (_cAliaEST)->ORDEM
						
						aDadosA[02] += 1		           // Curral : Qtde de registros
						aDadosA[06] += nQATU // Qtde
						// aDadosA[18] += (_cAliaEST)->PesoFinalTOTAL // Qtde
					EndIf
					
					aDados[02] += 1		// Curral : Qtde de registros
					aDados[06] += nQATU // Qtde

				EndIf
			endIf
			
			(_cAliaEST)->(DbSkip())
		EndDo

		cXML += '<Row ss:AutoFitHeight="0">' + CRLF
		cXML += '	<Cell ss:StyleID="s72" ss:Index="02"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDados[02]) +'</Data></Cell>' + CRLF
		cXML += '	<Cell ss:StyleID="s72" ss:Index="06"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDados[06]) +'</Data></Cell>' + CRLF
		cXML += '</Row>' + CRLF				
		
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
        cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
        cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
        cXML += '  </WorksheetOptions>' + CRLF
        cXML += ' </Worksheet>' + CRLF
		
		If !Empty(cXML) .and. MV_PAR06 == 1
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""	
	
	EndIf

	// (_cAliaEST)->(DbCloseArea()) // nao fechar alias, pois usarei ele no proximo quadro
Return nil
// FIM DA FUNCAO: fQuadro4


/* MJ : 02.05.2018 
	# Copia do quadro Quadro 1 sintetico, mudando apenas a validacao no inicio do where. */
Static Function sQuadro4s(nAgrup, cDiasAb, dDTReferencia )

Local cWorkSheet := "4-Pastos - Sintetico"
// Local aDados 	 := Array(26)
// Local aDados 	 := Array(26)
// Local aDadosA 	 := Array(26)
Local aDadSint	 := {} // Array(26)
//Local aDadCont	 := {}
Local cLinha     := ""
Local cEra    	 := ""

Local nQATU		 := 0, nI := 1, nQtLinPLT := 0
Local nRSPadArb	 := GetMV('VA_VLRAROB',,155)//, nVlrArrob := 0
//Local nPesCarc	 := 0, nVlrTotEst := 0
Local cXMLCab	 := "" // Cabeçalho
Local cXML 	 	 := "" // Quadro Principal

// Qadro Parametros
Local aQuaPar	 := {}
Local aQuaRes	 := {}

	(_cAliaEST)->(DbGoTop())
	If (_cAliaEST)->(Eof())	 // U_VARELM01()
		MsgAlert("Não foi localizado informacao para o Quadro: " + cWorkSheet )
	Else
	
		// cLinha	:= (_cAliaEST)->ORDEM
		cLinha	 := ""
		cEra	 := ""
		aDadSint := {}		
		
		// proccessando dados - agrupando informacoes
		While !(_cAliaEST)->(Eof())
			If (_cAliaEST)->Z08_TIPO <> '1'
				nQATU := Iif(dDTReferencia == dToS(dDataBase), (_cAliaEST)->B2_QATU, CalcEstL( (_cAliaEST)->B2_COD, (_cAliaEST)->B2_LOCAL, sToD(dDTReferencia)+1, (_cAliaEST)->B1_XLOTE)[1] )
				If nQATU <> 0
			
					If cLinha <> (_cAliaEST)->ORDEM .or. cEra <> (_cAliaEST)->B1_X_ERA 
						aAdd( aDadSint		 , {} 								)  
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_X_CURRA          )  // 01
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_XLOTE            )  // 02
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_XDATACO          )  // 03
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_X_ERA            )  // 04
						aAdd( aTail(aDadSint), nQATU                            )  // 05
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_XPESOCO          )  // 06
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_XLOTCOM          )  // 07
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_XRACA            )  // 08
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_X_SEXO           )  // 09
						aAdd( aTail(aDadSint), (_cAliaEST)->B1_XDENTIC           )  // 09
						aAdd( aTail(aDadSint), (_cAliaEST)->Dias                )  // 10 
						aAdd( aTail(aDadSint), (_cAliaEST)->Z09_GMDESP          )  // 11
						aAdd( aTail(aDadSint), (_cAliaEST)->PesoAtual           )  // 12
						
						aAdd( aTail(aDadSint), 0			            		)  // 13
						aAdd( aTail(aDadSint), 0 								)  // 14
						aAdd( aTail(aDadSint), 0 								)  // 15
						
						aAdd( aTail(aDadSint), (_cAliaEST)->DiasAbate           )  // 16
						aAdd( aTail(aDadSint), (_cAliaEST)->PrjecAba            )  // 17
						aAdd( aTail(aDadSint), (_cAliaEST)->Z09_RENESP          )  // 18
						aAdd( aTail(aDadSint), (_cAliaEST)->PesoFinal           )  // 19
						aAdd( aTail(aDadSint), (_cAliaEST)->PesoFinalTOTAL      )  // 20
						aAdd( aTail(aDadSint), (_cAliaEST)->PesoCarcacaFinal    )  // 21
						
						aAdd( aTail(aDadSint), 0					            )  // 22
						aAdd( aTail(aDadSint), 0 								)  // 23
						
						aAdd( aTail(aDadSint), AllTrim( (_cAliaEST)->A2_NOME )  )  // 24
						aAdd( aTail(aDadSint), AllTrim( PegaOBSB8((_cAliaEST)->B2_COD) ) )  // 25
						aAdd( aTail(aDadSint), AllTrim( (_cAliaEST)->B2_COD	)	)  // 26
						
						// Controlar a quantidade de registros UNIFICADOS para calculo da MEDIA
						aAdd( aTail(aDadSint), 1								)  // 27
						// nao musar este cara da posicao 27
						
						// Contador - Agrupamento - Media
						//aAdd( aDadCont, 1 ) 
						
						// ADICIONAR RESUMO PARA O QUADRO DOS PARAMETROS
						if aScan( aQuaPar, { |x| x[1] == AllTrim((_cAliaEST)->B1_X_ERA)+AllTrim((_cAliaEST)->B1_XRACA)+AllTrim((_cAliaEST)->B1_X_SEXO)/* +AllTrim((_cAliaEST)->B1_XDENTIC) */ } ) == 0
							aAdd( aQuaPar		 , {} 								)  
							aAdd( aTail(aQuaPar) , AllTrim((_cAliaEST)->B1_X_ERA)+AllTrim((_cAliaEST)->B1_XRACA)+AllTrim((_cAliaEST)->B1_X_SEXO)/* +AllTrim((_cAliaEST)->B1_XDENTIC) */ )  // 01
							aAdd( aTail(aQuaPar) , (_cAliaEST)->B1_X_ERA            )  // 02
							aAdd( aTail(aQuaPar) , (_cAliaEST)->B1_XRACA            )  // 03
							aAdd( aTail(aQuaPar) , (_cAliaEST)->B1_X_SEXO           )  // 04
							// aAdd( aTail(aQuaPar) , (_cAliaEST)->B1_XDENTIC           )  // 04
							aAdd( aTail(aQuaPar) , iIf( Empty((_cAliaEST)->Z09_VLREST), nRSPadArb , (_cAliaEST)->Z09_VLREST ) )  // 05
							aAdd( aTail(aQuaPar) , (_cAliaEST)->Z09_GMDESP			)  // 06
							aAdd( aTail(aQuaPar) , (_cAliaEST)->Z09_RENESP			)  // 07
							aAdd( aTail(aQuaPar) , iIf( Empty((_cAliaEST)->Z09_DIAABT), Val(cDiasAb) , (_cAliaEST)->Z09_DIAABT ) )  // 08
						EndIf
						
						if aScan( aQuaRes, { |x| x[1] == AllTrim((_cAliaEST)->B1_X_ERA) } ) == 0
							aAdd( aQuaRes		 , {} 							  )  
							aAdd( aTail(aQuaRes) , AllTrim((_cAliaEST)->B1_X_ERA) )  // 01
						EndIf
						
					Else
						
						// aDadCont[len(aDadCont)] += 1
						aDadSint[ Len(aDadSint), 28 ] += 1
						
						// "Qtde "
						aDadSint[ Len(aDadSint), 5] += nQATU
						// "Média (Kg)" 	     	
						aDadSint[ Len(aDadSint), 6] += (_cAliaEST)->B1_XPESOCO
						// "Origem" 
						If Empty(aDadSint[ Len(aDadSint), 7])
							aDadSint[ Len(aDadSint), 7] := (_cAliaEST)->B1_XLOTCOM
						EndIf
						// "Peso Atual(Kg)"	 	
						aDadSint[ Len(aDadSint), 13] += (_cAliaEST)->PesoAtual
						
						// Data Abate
						If Empty( aDadSint[ Len(aDadSint), 18] )
							aDadSint[ Len(aDadSint), 18] := (_cAliaEST)->PrjecAba
						EndIF
						
						// "Peso Final Total"	
						aDadSint[ Len(aDadSint), 21] += (_cAliaEST)->PesoFinalTOTAL
						// "Peso Final Carcaça"	
						aDadSint[Len(aDadSint),22] += (_cAliaEST)->PesoCarcacaFinal
						
						// "Fornecedor"			
						xAux := AllTrim( (_cAliaEST)->A2_NOME )
						If Empty( xAux $ aDadSint[Len(aDadSint),25] ) 
							aDadSint[Len(aDadSint),25] += Iif(Empty(aDadSint[Len(aDadSint),25]), "", Iif(Empty(xAux), "", " | ")) + xAux
						EndIf

						// "Observação"
						xAux := AllTrim( PegaOBSB8((_cAliaEST)->B2_COD) )
						If Empty( xAux $ aDadSint[Len(aDadSint),26] )
							aDadSint[Len(aDadSint),26] += Iif(Empty(aDadSint[Len(aDadSint),26]), "", Iif(Empty(xAux), "", " | ")) + xAux
						EndIf						
						// "Produto"	
						aDadSint[ Len(aDadSint), 27] += Iif(Empty(aDadSint[Len(aDadSint), 27]), "", " | ") + AllTrim( (_cAliaEST)->B2_COD )
					EndIf
					cLinha := (_cAliaEST)->ORDEM 
					cEra   := (_cAliaEST)->B1_X_ERA
				EndIf
			EndIf
			
			(_cAliaEST)->(DbSkip())
		EndDo
		
		nQtLinP := Len(aQuaPar) + 4
		
		cXML := '   <Row ss:AutoFitHeight="0">' + CRLF
		cXML += ' 		<Cell ss:Index="15" ss:MergeAcross="4" ss:StyleID="s106"><Data ss:Type="String">A T U A L</Data></Cell>' + CRLF
		cXML += ' 		<Cell ss:Index="20" ss:MergeAcross="5" ss:StyleID="s112"><Data ss:Type="String">F I N A L</Data></Cell>' + CRLF
		cXML += '   </Row>' + CRLF
		nQtLinP += 1
		
		// impressao do titulo do QUADRO PRINCIPAL
			cXML += '   <Row ss:Height="54" ss:StyleID="s91">' + CRLF
/* 02 */ 	cXML += '    <Cell ss:Index="2" ss:StyleID="s65"><Data ss:Type="String">Linha</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Lote</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 04 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Entrada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 05 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Era</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Qtde ' + SubS(dToC(sToD(dDTReferencia)),1,5)+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">GMD</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">R$ @</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Rend. Esperado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Apartação Média (Kg)</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Origem</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Raça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Sexo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */ 	cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Dentição</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 14 */ 	cXML += '    <Cell ss:StyleID="s106"><Data ss:Type="String">Dias</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 15 */ 	cXML += '    <Cell ss:StyleID="s106"><Data ss:Type="String">Peso Atual(Kg)</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 16 */ 	cXML += '    <Cell ss:StyleID="s106"><Data ss:Type="String">Peso Final Atual</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 17 */ 	cXML += '    <Cell ss:StyleID="s106"><Data ss:Type="String">Peso Carcaça Atual</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 18 */ 	cXML += '    <Cell ss:StyleID="s106"><Data ss:Type="String">R$ Total Estoque Atual</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 19 */ 	cXML += '    <Cell ss:StyleID="s112"><Data ss:Type="String">Dias p/ Abate</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 20 */ 	cXML += '    <Cell ss:StyleID="s112"><Data ss:Type="String">Data Abate</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 21 */ 	cXML += '    <Cell ss:StyleID="s112"><Data ss:Type="String">Peso Final</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 22 */ 	cXML += '    <Cell ss:StyleID="s112"><Data ss:Type="String">Peso Final Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 23 */ 	cXML += '    <Cell ss:StyleID="s112"><Data ss:Type="String">Peso Final Carcaça</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 24 */ 	cXML += '    <Cell ss:StyleID="s112"><Data ss:Type="String">R$ Total Venda Abate</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 25 */ 	cXML += '    <Cell ss:StyleID="s70"><Data ss:Type="String">Fornecedor</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 26 */ 	cXML += '    <Cell ss:StyleID="s70"><Data ss:Type="String">Observacao</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 27 */ 	cXML += '    <Cell ss:StyleID="s70"><Data ss:Type="String">Produto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '   </Row>' + CRLF
		nQtLinP += 1
		
		/* 
			MJ : Pramos de ordernar a aba de pastos no dia 30/07/2018, conforme solicitacao do CHEFE ARTHUR TOSHIO VANVUNZELA.
		if MV_PAR08 == 2
			aSort( aDadSint ,,, {|x,y| DtoS(x[3])+AllTrim(x[1])+AllTrim(x[2]) < DtoS(y[3])+AllTrim(y[1])+AllTrim(y[2]) } )
		EndIf */
		
		// impressao do QUADRO PRINCIPAL
		nI 		:= 1
		While nI <= Len( aDadSint )
			
			cXML += '<Row>' + CRLF
/* 02 */   	cXML += '  <Cell ss:Index="2" ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 01])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 03 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 02])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
           	If Empty( aDadSint[ nI, 03] )
/* 04 */   		cXML += '  <Cell><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
           	Else
/* 04 */   		cXML += '  <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'+U_FrmtVlrExcel(aDadSint[ nI, 03])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
           	EndIf
/* 05 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 04])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 06 */   	cXML += '  <Cell ss:StyleID="s72"><Data ss:Type="Number">'+U_FrmtVlrExcel(aDadSint[ nI, 05])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 07 */   	cXML += '  <Cell ss:Formula="=IFERROR(VLOOKUP(CONCATENATE(RC5,RC12,RC13),R5C1:R'+AllTrim(Str(Len(aQuaPar)+4))+'C8,6,),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 08 */   	cXML += '  <Cell ss:StyleID="s69" ss:Formula="=IFERROR(VLOOKUP(CONCATENATE(RC5,RC12,RC13),R5C1:R'+AllTrim(Str(Len(aQuaPar)+4))+'C8,5,),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 09 */   	cXML += '  <Cell ss:Formula="=IFERROR(VLOOKUP(CONCATENATE(RC5,RC12,RC13),R5C1:R'+AllTrim(Str(Len(aQuaPar)+4))+'C8,7,),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 10 */   	cXML += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel( aDadSint[ nI, 06] / aDadSint[ nI, 28 ] )+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 11 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 07])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 12 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 08])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 13 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 09])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 14 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 10])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/* 15 */   	cXML += '  <Cell ss:Formula="=IFERROR(R5C10-RC[-11],&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 16 */   	cXML += '  <Cell ss:StyleID="s68" ss:Formula="=IFERROR(RC[-6]+(RC[-1]*RC[-9]),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 17 */   	cXML += '  <Cell ss:StyleID="s68" ss:Formula="=IFERROR(RC[-1]*RC[-11],&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 18 */   	cXML += '  <Cell ss:StyleID="s68" ss:Formula="=IFERROR(RC[-2]*(RC[-9]/100),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 19 */   	cXML += '  <Cell ss:StyleID="s69" ss:Formula="=IFERROR((RC[-1]/15)*RC[-11]*RC[-13],&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 20 */   	cXML += '  <Cell ss:Formula="=IFERROR(IF(RC[-5]&gt;VLOOKUP(CONCATENATE(RC5,RC12,RC13),R5C1:R'+AllTrim(Str(Len(aQuaPar)+4))+'C8,8,),RC[-5],VLOOKUP(CONCATENATE(RC5,RC12,RC13),R5C1:R'+AllTrim(Str(Len(aQuaPar)+4))+'C8,8,)),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 21 */   	cXML += '  <Cell ss:StyleID="s67" ss:Formula="=IFERROR(RC[-1]+RC[-17],&quot;&quot;)"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 22 */   	cXML += '  <Cell ss:StyleID="s68" ss:Formula="=IFERROR(RC[-12]+(RC[-2]*RC[-15]),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 23 */   	cXML += '  <Cell ss:StyleID="s68" ss:Formula="=IFERROR(RC[-1]*RC[-17],&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 24 */   	cXML += '  <Cell ss:StyleID="s68" ss:Formula="=IFERROR(RC[-2]*(RC[-15]/100),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 25 */   	cXML += '  <Cell ss:StyleID="s69" ss:Formula="=IFERROR((RC[-1]/15)*RC[-17]*RC[-19],&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 26 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 25])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 27 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 26])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/* 28 */   	cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aDadSint[ nI, 27])+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF			
           	cXML += '</Row>' + CRLF
			nQtLinPLT += 1
			nQtLinP   += 1

			// U_VARELM01()
			if nI < Len( aDadSint ) // estou no ULTIMO
				If AllTrim( aDadSint[nI+1, 1] ) <> AllTrim( aDadSint[nI, 1] ) // .AND. aDadSint[nI+1, 4] <> aDadSint[nI, 4]
					// proxima linha diferente, entao mudou a LINHA; colocar soma
					cXML += '<Row ss:AutoFitHeight="0">' + CRLF
					cXML += '	<Cell ss:StyleID="s72" ss:Index="06" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinPLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					cXML += '	<Cell ss:StyleID="s68" ss:Index="17" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinPLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					cXML += '	<Cell ss:StyleID="s69" ss:Index="19" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinPLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					cXML += '	<Cell ss:StyleID="s68" ss:Index="23" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinPLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					cXML += '	<Cell ss:StyleID="s69" ss:Index="25" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinPLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					cXML += '</Row>' + CRLF				
					nQtLinPLT := 0
					nQtLinP   += 1	
					
					cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF	; nQtLinP += 1
				EndIf
			Else
				// proxima linha diferente, entao mudou a LINHA; colocar soma
				cXML += '<Row ss:AutoFitHeight="0">' + CRLF
				cXML += '	<Cell ss:StyleID="s72" ss:Index="06" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinPLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s68" ss:Index="17" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinPLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s69" ss:Index="19" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinPLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s68" ss:Index="23" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinPLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s69" ss:Index="25" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtLinPLT))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '</Row>' + CRLF				
				// nQtLinPLT := 0
				nQtLinP   += 1
				
				// acabou o Vetor .. imprimir a soma total
				cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF 	; nQtLinP += 1
				cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF   ; nQtLinP += 1
				cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF   ; nQtLinP += 1
				
				// TOTAL GERAL => Final do relatorio
				cXML += '<Row ss:AutoFitHeight="0">' + CRLF
				cXML += '	<Cell ss:StyleID="s84" ss:Index="06" ss:Formula="=SUMIF(R[-'+AllTrim(Str(nQtLinP-Len(aQuaPar)  ))+']C5:R[-1]C5,&quot;&quot;,R[-'+AllTrim(Str(nQtLinP-Len(aQuaPar)  ))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s86" ss:Index="16" ss:Formula="=RC[1]/RC[-10]"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s86" ss:Index="17" ss:Formula="=SUMIF(R[-'+AllTrim(Str(nQtLinP-Len(aQuaPar)  ))+']C5:R[-1]C5,&quot;&quot;,R[-'+AllTrim(Str(nQtLinP-Len(aQuaPar)  ))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s85" ss:Index="19" ss:Formula="=SUMIF(R[-'+AllTrim(Str(nQtLinP-Len(aQuaPar)  ))+']C5:R[-1]C5,&quot;&quot;,R[-'+AllTrim(Str(nQtLinP-Len(aQuaPar)  ))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s86" ss:Index="22" ss:Formula="=RC[1]/RC[-16]"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s86" ss:Index="23" ss:Formula="=SUMIF(R[-'+AllTrim(Str(nQtLinP-Len(aQuaPar)  ))+']C5:R[-1]C5,&quot;&quot;,R[-'+AllTrim(Str(nQtLinP-Len(aQuaPar)  ))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '	<Cell ss:StyleID="s85" ss:Index="25" ss:Formula="=SUMIF(R[-'+AllTrim(Str(nQtLinP-Len(aQuaPar)  ))+']C5:R[-1]C5,&quot;&quot;,R[-'+AllTrim(Str(nQtLinP-Len(aQuaPar)  ))+']C:R[-1]C)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '</Row>' + CRLF				
			EndIf
			nI += 1
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
        cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
        cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
        cXML += '  </WorksheetOptions>' + CRLF
		cXML += '  <AutoFilter x:Range="R'+AllTrim(Str(Len(aQuaPar)+7))+'C1:R'+AllTrim(Str(nQtLinP+2))+'C27" xmlns="urn:schemas-microsoft-com:office:excel"></AutoFilter>
        cXML += ' </Worksheet>' + CRLF
		
		/* O CABECALHO PRECISA SER FEITO NO FINAL, pois para fazer o filtro automatico, preciso do numero total de linhas. */
		// Cabeçalho XML	//  "2-Currais - Sintetico"
		cXMLCab := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		cXMLCab += ' <Names>
		cXMLCab += ' 	<NamedRange ss:Name="_FilterDatabase"

		cAux := "'4-Pastos - Sintetico'"
		cXMLCab += ' 		ss:RefersTo="='+ cAux +'!R'+AllTrim(Str(Len(aQuaPar)+7))+'C1:R'+AllTrim(Str(nQtLinP+2))+'C27" ss:Hidden="1"/>
		cXMLCab += ' </Names>
		cXMLCab += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
		cXMLCab += '    <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="145.5"/>
        cXMLCab += '    <Column ss:Width="97.5"/>
        cXMLCab += '    <Column ss:Width="64.5" ss:Span="1"/>
        cXMLCab += '    <Column ss:Index="5" ss:Width="97.5"/>
        cXMLCab += '    <Column ss:Width="52.5"/>
        cXMLCab += '    <Column ss:Width="51.75"/>
        cXMLCab += '    <Column ss:Width="52.5"/>
        cXMLCab += '    <Column ss:Width="72.75"/>
        cXMLCab += '    <Column ss:Width="75.75"/>
        cXMLCab += '    <Column ss:Width="63"/>
        cXMLCab += '    <Column ss:Width="72.75"/>
        cXMLCab += '    <Column ss:Width="59.25"/>
        cXMLCab += '    <Column ss:Width="69.75"/>
        cXMLCab += '    <Column ss:Width="63"/>
        cXMLCab += '    <Column ss:Width="97.5"/>
        cXMLCab += '    <Column ss:Width="104.25"/>
        cXMLCab += '    <Column ss:Width="66"/>
        cXMLCab += '    <Column ss:Width="107.25"/>
        cXMLCab += '    <Column ss:Width="55.5"/>
        cXMLCab += '    <Column ss:Width="78"/>
        cXMLCab += '    <Column ss:Width="52.5"/>
        cXMLCab += '    <Column ss:Width="77.25"/>
        cXMLCab += '    <Column ss:Width="66"/>
        cXMLCab += '    <Column ss:Width="126.75"/>
        cXMLCab += '    <Column ss:StyleID="s62" ss:Width="199.5"/>
        cXMLCab += '    <Column ss:StyleID="s62" ss:Width="180.75"/>
        cXMLCab += '    <Column ss:StyleID="s62" ss:Width="184.5"/>
		
		// Cabeçalho XML	//  "2-Currais - Sintetico"
		cXMLCab += ' <Row ss:Height="15.375">
		cXMLCab += '   <Cell ss:Index="2" ss:MergeAcross="25" ss:StyleID="s62">
        cXMLCab += '   	<Data ss:Type="String">' + cTitulo + " - Dt. Referência: " + DtoC(MV_PAR04) + '</Data>
        cXMLCab += '   </Cell>
        cXMLCab += ' </Row>
		nQtLinP += 1
		
		// Parametros
		cXMLCab += ' <Row ss:Height="15.375">
		cXMLCab += ' 	<Cell ss:Index="2"  ss:MergeAcross="6" ss:StyleID="s93"><Data ss:Type="String">Parâmetros</Data></Cell>
		cXMLCab += ' 	<Cell ss:Index="12" ss:MergeAcross="5" ss:StyleID="s93"><Data ss:Type="String">Resumo por Era</Data></Cell>
		cXMLCab += ' </Row>
		nQtLinP += 1
		
		cXMLCab += ' <Row ss:Height="15">
        cXMLCab += '   <Cell ss:Index="2" ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String"></Data></Cell>
        
		cXMLCab += '   <Cell ss:Index="10" ss:StyleID="s65"><Data ss:Type="String">Data</Data></Cell>
		
		cXMLCab += '   <Cell ss:Index="12" ss:MergeAcross="1" ss:StyleID="s65"><Data ss:Type="String">B A I A S</Data></Cell>' + CRLF
		cXMLCab += '   <Cell               ss:MergeAcross="1" ss:StyleID="s106"><Data ss:Type="String">A T U A L</Data></Cell>' + CRLF
		cXMLCab += '   <Cell               ss:MergeAcross="1" ss:StyleID="s112"><Data ss:Type="String">F I N A L</Data></Cell>' + CRLF
	
		cXMLCab += ' </Row>
		nQtLinP += 1
		
		// colunas titulos parametros
		cXMLCab += ' <Row ss:Height="15">
        cXMLCab += '   <Cell ss:Index="2" ss:StyleID="s65"><Data ss:Type="String">Era</Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Raça</Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Sexo</Data></Cell>
        // cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Dentição</Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">R$ @</Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">GMD</Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Rend. Esperado</Data></Cell>
        cXMLCab += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Dias p/ Abate</Data></Cell>
		
		cXMLCab += '   <Cell ss:Index="10" ss:StyleID="s65"><Data ss:Type="String">Referência</Data></Cell>
		
		cXMLCab += '   <Cell ss:Index="12" ss:StyleID="s65"><Data ss:Type="String">Era</Data></Cell>
		cXMLCab += '   <Cell               ss:StyleID="s65"><Data ss:Type="String">Qt. Cabecas</Data></Cell>
		cXMLCab += '   <Cell               ss:StyleID="s106"><Data ss:Type="String">R$ Total Estoque Atual</Data></Cell>
		cXMLCab += '   <Cell               ss:StyleID="s106"><Data ss:Type="String">R$ / Cabeças</Data></Cell>
		cXMLCab += '   <Cell               ss:StyleID="s112"><Data ss:Type="String">R$ Total Venda Abate</Data></Cell>
		cXMLCab += '   <Cell               ss:StyleID="s112"><Data ss:Type="String">R$ / Cabeças</Data></Cell>	
		cXMLCab += ' </Row>
		nQtLinP += 1
		
		// Imprimir quadros com os parametros
		aSort( aQuaPar ,,, {|x,y| x[1] < y[1] } )	// na posicao 1, esta conctenado ERA + RAÇA + SEXO
		aSort( aQuaRes ,,, {|x,y| x[1] < y[1] } )	// na posicao 1, esta conctenado ERA + RAÇA + SEXO
		For nI := 1 to Len(aQuaPar)
			cXMLCab += '<Row>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aQuaPar[ nI, 01])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aQuaPar[ nI, 02])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aQuaPar[ nI, 03])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(aQuaPar[ nI, 04])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel(aQuaPar[ nI, 05])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel(aQuaPar[ nI, 06])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel(aQuaPar[ nI, 07])+'</Data></Cell>' + CRLF
			cXMLCab += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel(aQuaPar[ nI, 08])+'</Data></Cell>' + CRLF
			
			if nI == 1
				If sToD(dDTReferencia) == dDataBase
					cXMLCab += ' 	<Cell ss:Index="10" ss:StyleID="s67" ss:Formula="=TODAY()"><Data ss:Type="DateTime"></Data></Cell>
				Else
					cXMLCab += ' 	<Cell ss:Index="10" ss:StyleID="s67"><Data ss:Type="DateTime">'+U_FrmtVlrExcel(sToD(dDTReferencia))+'</Data></Cell>
				EndIf				
			EndIf
			
			if nI <= Len(aQuaRes)
				cXMLCab += '   <Cell ss:Index="12" ss:StyleID="s66"><Data ss:Type="String">' + U_FrmtVlrExcel( aQuaRes[nI, 01] ) +'</Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s72" ss:Formula="=SUMIF(R'+AllTrim(Str(Len(aQuaPar)+8))+'C5:R'+AllTrim(Str(nQtLinP-3))+'C5,RC12,R'+AllTrim(Str(Len(aQuaPar)+8))+'C6:R'+AllTrim(Str(nQtLinP-3))+'C6)"><Data ss:Type="Number"></Data></Cell>'+CRLF
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=SUMIF(R'+AllTrim(Str(Len(aQuaPar)+8))+'C5:R'+AllTrim(Str(nQtLinP-3))+'C5,RC12,R'+AllTrim(Str(Len(aQuaPar)+8))+'C19:R'+AllTrim(Str(nQtLinP-3))+'C19)"><Data ss:Type="Number"></Data></Cell>'+CRLF
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=SUMIF(R'+AllTrim(Str(Len(aQuaPar)+8))+'C5:R'+AllTrim(Str(nQtLinP-3))+'C5,RC12,R'+AllTrim(Str(Len(aQuaPar)+8))+'C25:R'+AllTrim(Str(nQtLinP-3))+'C25)"><Data ss:Type="Number"></Data></Cell>'+CRLF
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-4]"><Data ss:Type="Number"></Data></Cell>
			
			ElseIf nI == Len(aQuaRes)+1
				cXMLCab += '   <Cell ss:Index="12" ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s72" ss:Formula="=SUM(R[-'+AllTrim(Str(Len(aQuaRes)))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=SUM(R[-'+AllTrim(Str(Len(aQuaRes)))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=SUM(R[-'+AllTrim(Str(Len(aQuaRes)))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
				cXMLCab += '   <Cell               ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-4]"><Data ss:Type="Number"></Data></Cell>
			EndIf
			
			cXMLCab += '</Row>' + CRLF
		next nI
		nFimParP	:= Len(aQuaPar)
		
		cXMLCab += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXMLCab + cXML ) )
			cXMLCab	:= ""
			cXML 	:= ""
		EndIf
		
	EndIf

Return aDadSint		// U_VARELM01()
// FIM DA FUNCAO: sQuadro4s


/*--------------------------------------------------------------------------------,
 | Func:  			                                                             |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  06.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro2(dDTReferencia, aCurSint, aPasSint )
Local cXML	   	 := ""
// Local _cQry      := ""
//Local _cAlia     := CriaTrab(,.F.)   
Local cWorkSheet := "5-Resumo Por Era"

// Local aDados 	 := Array(04)
// Local nTotal 	 := 0
// Local nTotalT 	 := 0
Local cAgrupa    := ""
// Local nValTotEst := 0
// Local nGTotEst   := 0
Local cAux		 := ""
Local nQtRLinC	 := 0
Local nQtRLinP	 := 0
Local nI

	cXML := ' <Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth="45" ss:DefaultRowHeight="15">
	cXML += ' <Column ss:Width="97.875"/>
	cXML += ' <Column ss:Width="56.25"/>
	cXML += ' <Column ss:Width="98.25"/>
	cXML += ' <Column ss:Width="64.125"/>
	cXML += ' <Column ss:Width="81"/>
	cXML += ' <Column ss:Width="63.75"/>	
	cXML += ' <Row ss:AutoFitHeight="0">
	cXML += '  <Cell ss:MergeAcross="5"  ss:StyleID="s62">
	cXML += '   	<Data ss:Type="String">' + cTitulo + " - Dt. Referência: " + DtoC(MV_PAR04) + '</Data>
	cXML += '   </Cell>
	cXML += ' </Row>
	nQtRLinC += 1
	
	cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF ; 	nQtRLinC += 1

	cXML += '   <Row ss:AutoFitHeight="0">' + CRLF
	cXML += ' 		<Cell ss:Index="1" ss:MergeAcross="1" ss:StyleID="s65"><Data ss:Type="String">B A I A S</Data></Cell>' + CRLF
	cXML += ' 		<Cell ss:Index="3" ss:MergeAcross="1" ss:StyleID="s106"><Data ss:Type="String">A T U A L</Data></Cell>' + CRLF
	cXML += ' 		<Cell ss:Index="5" ss:MergeAcross="1" ss:StyleID="s112"><Data ss:Type="String">F I N A L</Data></Cell>' + CRLF
	cXML += '   </Row>' + CRLF
	nQtRLinC += 1
	
	cXML += ' <Row ss:Height="35">' + CRLF
	cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Era</Data></Cell>
	cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Qt. Cabecas</Data></Cell>
	cXML += '   <Cell ss:StyleID="s106"><Data ss:Type="String">R$ Total Estoque Atual</Data></Cell>
	cXML += '   <Cell ss:StyleID="s106"><Data ss:Type="String">R$ / Cabeças</Data></Cell>
	cXML += '   <Cell ss:StyleID="s112"><Data ss:Type="String">R$ Total Venda Abate</Data></Cell>
	cXML += '   <Cell ss:StyleID="s112"><Data ss:Type="String">R$ / Cabeças</Data></Cell>
	cXML += ' </Row>' + CRLF
	nQtRLinC += 1
	
	aSort(aDadTp1,,,{|x,y| x[5] < y[5] })
	aSort(aDadTp4,,,{|x,y| x[5] < y[5] })
	
	// aDados[02]  := 0
	// aDados[03]  := 0
	// nTotal		:= 0
	cAgrupa 	:= aDadTp1[1, 5]
	For nI := 1 to Len(aDadTp1)
	
		If cAgrupa <> aDadTp1[nI, 5]		// U_VARELM01()
			
			// nValTotEst := SomaValEst(cAgrupa, aCurSint, 15)
			
			cXML += ' <Row ss:AutoFitHeight="0">
			cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String">' + U_FrmtVlrExcel( cAgrupa ) +'</Data></Cell>
			
			cAux := "'2-Currais - Sintetico'"
			cXML += '   <Cell ss:StyleID="s72" ss:Formula="=SUMIF(' + cAux + '!R'+AllTrim(Str(nFimParC+4))+'C5:R'+AllTrim(Str(nQtLinC+4))+'C5,RC1,' + cAux + '!R'+AllTrim(Str(nFimParC+4))+'C6:R'+AllTrim(Str(nQtLinC+4))+'C6)"><Data ss:Type="Number"></Data></Cell>'+CRLF
			cXML += '   <Cell ss:StyleID="s69" ss:Formula="=SUMIF(' + cAux + '!R'+AllTrim(Str(nFimParC+4))+'C5:R'+AllTrim(Str(nQtLinC+4))+'C5,RC1,' + cAux + '!R'+AllTrim(Str(nFimParC+4))+'C19:R'+AllTrim(Str(nQtLinC+4))+'C19)"><Data ss:Type="Number"></Data></Cell>'+CRLF
			cXML += '   <Cell ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>
			cXML += '   <Cell ss:StyleID="s69" ss:Formula="=SUMIF(' + cAux + '!R'+AllTrim(Str(nFimParC+4))+'C5:R'+AllTrim(Str(nQtLinC+4))+'C5,RC1,' + cAux + '!R'+AllTrim(Str(nFimParC+4))+'C25:R'+AllTrim(Str(nQtLinC+4))+'C25)"><Data ss:Type="Number"></Data></Cell>'+CRLF
			cXML += '   <Cell ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-4]"><Data ss:Type="Number"></Data></Cell>
		    cXML += ' </Row>
			nQtRLinC += 1
			
			// aDados[02] := 0
			// aDados[03] += nValTotEst
			cAgrupa    := aDadTp1[ nI, 05]
		EndIf
		
		// aDados[02]  += aDadTp1[nI, 06]
		// nTotal  	+= aDadTp1[nI, 06]
	Next nI
	// nValTotEst := SomaValEst(cAgrupa, aCurSint, 15)
	// aDados[03] += nValTotEst
	
	cXML += ' <Row ss:AutoFitHeight="0">
	cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String">' + U_FrmtVlrExcel( cAgrupa ) +'</Data></Cell>
	cXML += '   <Cell ss:StyleID="s72" ss:Formula="=SUMIF(' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C5:R'+AllTrim(Str(nQtLinP+4))+'C5,RC1,' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C6:R'+AllTrim(Str(nQtLinP+4))+'C6)"><Data ss:Type="Number"></Data></Cell>'+CRLF
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=SUMIF(' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C5:R'+AllTrim(Str(nQtLinP+4))+'C5,RC1,' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C19:R'+AllTrim(Str(nQtLinP+4))+'C19)"><Data ss:Type="Number"></Data></Cell>'+CRLF
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=SUMIF(' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C5:R'+AllTrim(Str(nQtLinP+4))+'C5,RC1,' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C25:R'+AllTrim(Str(nQtLinP+4))+'C25)"><Data ss:Type="Number"></Data></Cell>'+CRLF
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-4]"><Data ss:Type="Number"></Data></Cell>
	cXML += ' </Row>
	nQtRLinC += 1
	
	cXML += ' <Row ss:AutoFitHeight="0">
	cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String">' + "" +'</Data></Cell>
	cXML += '   <Cell ss:StyleID="s72" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtRLinC))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtRLinC))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtRLinC))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-4]"><Data ss:Type="Number"></Data></Cell>
	cXML += ' </Row>
	nQtRLinC += 1
	
	// nTotalT := nTotal
	// nGTotEst := aDados[03]
	
	// imprimir Quadro 2 : Tipo 4
	// aDados 	 := Array(04)
	cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF 
	cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF 

	cXML += '   <Row ss:AutoFitHeight="0">' + CRLF
	cXML += ' 		<Cell ss:Index="1" ss:MergeAcross="1" ss:StyleID="s65"><Data ss:Type="String">P A S T O S</Data></Cell>' + CRLF
	cXML += ' 		<Cell ss:Index="3" ss:MergeAcross="1" ss:StyleID="s106"><Data ss:Type="String">A T U A L</Data></Cell>' + CRLF
	cXML += ' 		<Cell ss:Index="5" ss:MergeAcross="1" ss:StyleID="s112"><Data ss:Type="String">F I N A L</Data></Cell>' + CRLF
	cXML += '   </Row>' + CRLF
	nQtRLinP += 1
	
	cXML += ' <Row ss:Height="35">' + CRLF
	cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Era</Data></Cell>
	cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Qt. Cabecas</Data></Cell>
	cXML += '   <Cell ss:StyleID="s106"><Data ss:Type="String">R$ Total Estoque Atual</Data></Cell>
	cXML += '   <Cell ss:StyleID="s106"><Data ss:Type="String">R$ / Cabeças</Data></Cell>
	cXML += '   <Cell ss:StyleID="s112"><Data ss:Type="String">R$ Total Venda Abate</Data></Cell>
	cXML += '   <Cell ss:StyleID="s112"><Data ss:Type="String">R$ / Cabeças</Data></Cell>
	cXML += ' </Row>' + CRLF
	nQtRLinP += 1
	// aDados[02]  := 0
	// aDados[03]  := 0
	// nTotal		:= 0
	cAgrupa 	:= aDadTp4[1, 5]
	For nI := 1 to Len(aDadTp4)
	
		If cAgrupa <> aDadTp4[nI, 5]
			// nValTotEst := SomaValEst(cAgrupa, aPasSint, 16)

			cXML += ' <Row ss:AutoFitHeight="0">
			cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String">' + U_FrmtVlrExcel( cAgrupa ) +'</Data></Cell>
			
			cAux := "'4-Pastos - Sintetico'"
			cXML += '   <Cell ss:StyleID="s72" ss:Formula="=SUMIF(' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C5:R'+AllTrim(Str(nQtLinP+4))+'C5,RC1,' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C6:R'+AllTrim(Str(nQtLinP+4))+'C6)"><Data ss:Type="Number"></Data></Cell>'+CRLF
			cXML += '   <Cell ss:StyleID="s69" ss:Formula="=SUMIF(' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C5:R'+AllTrim(Str(nQtLinP+4))+'C5,RC1,' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C19:R'+AllTrim(Str(nQtLinP+4))+'C19)"><Data ss:Type="Number"></Data></Cell>'+CRLF
			cXML += '   <Cell ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>
			cXML += '   <Cell ss:StyleID="s69" ss:Formula="=SUMIF(' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C5:R'+AllTrim(Str(nQtLinP+4))+'C5,RC1,' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C25:R'+AllTrim(Str(nQtLinP+4))+'C25)"><Data ss:Type="Number"></Data></Cell>'+CRLF
			cXML += '   <Cell ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-4]"><Data ss:Type="Number"></Data></Cell>
			cXML += ' </Row>
			nQtRLinP += 1
			
			// aDados[02] := 0
			// aDados[03]  += nValTotEst
			cAgrupa    := aDadTp4[nI, 05]
		EndIf	
		
		// aDados[02]  += aDadTp4[nI, 06]
		// nTotal  	+= aDadTp4[nI, 06]
	Next nI
	// nValTotEst 	:= SomaValEst(cAgrupa, aPasSint, 16)
	// aDados[03] 	+= nValTotEst
	
	cXML += ' <Row ss:AutoFitHeight="0">
	cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String">' + U_FrmtVlrExcel( cAgrupa ) +'</Data></Cell>
	cXML += '   <Cell ss:StyleID="s72" ss:Formula="=SUMIF(' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C5:R'+AllTrim(Str(nQtLinP+4))+'C5,RC1,' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C6:R'+AllTrim(Str(nQtLinP+4))+'C6)"><Data ss:Type="Number"></Data></Cell>'+CRLF
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=SUMIF(' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C5:R'+AllTrim(Str(nQtLinP+4))+'C5,RC1,' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C19:R'+AllTrim(Str(nQtLinP+4))+'C19)"><Data ss:Type="Number"></Data></Cell>'+CRLF
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=SUMIF(' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C5:R'+AllTrim(Str(nQtLinP+4))+'C5,RC1,' + cAux + '!R'+AllTrim(Str(nFimParP+4))+'C25:R'+AllTrim(Str(nQtLinP+4))+'C25)"><Data ss:Type="Number"></Data></Cell>'+CRLF
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-4]"><Data ss:Type="Number"></Data></Cell>
	cXML += ' </Row>
	nQtRLinP += 1
	
	cXML += ' <Row ss:AutoFitHeight="0">
	cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String">' + "" +'</Data></Cell>
	cXML += '   <Cell ss:StyleID="s72" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtRLinP))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+CRLF
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtRLinP))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+CRLF
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=SUM(R[-'+AllTrim(Str(nQtRLinP))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+CRLF
	cXML += '   <Cell ss:StyleID="s69" ss:Formula="=RC[-1]/RC[-4]"><Data ss:Type="Number"></Data></Cell>
	cXML += ' </Row>
	nQtRLinP += 1
	
	// nGTotEst 	+= aDados[03]
	
	// pular linha						
	cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
	
	// aDados 	 := Array(04)
	// aDados[01] := "Total Geral"
	// aDados[02] := nTotalT + nTotal
	// aDados[03] := nGTotEst
	// aDados[04] := aDados[03] / aDados[02]
	
	cXML += ' <Row ss:AutoFitHeight="0">
	cXML += '   <Cell ss:StyleID="s83"><Data ss:Type="String">'+ U_FrmtVlrExcel( "Total Geral" ) +'</Data></Cell>
	cXML += '   <Cell ss:StyleID="s84" ss:Formula="=SUMIF(R3C1:R[-1]C1,&quot;&quot;,R3C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
	cXML += '   <Cell ss:StyleID="s85" ss:Formula="=SUMIF(R3C1:R[-1]C1,&quot;&quot;,R3C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
	cXML += '   <Cell ss:StyleID="s85" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>
	cXML += '   <Cell ss:StyleID="s85" ss:Formula="=SUMIF(R3C1:R[-1]C1,&quot;&quot;,R3C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
	cXML += '   <Cell ss:StyleID="s85" ss:Formula="=RC[-1]/RC[-4]"><Data ss:Type="Number"></Data></Cell>
	cXML += ' </Row>
// EndIf

// (_cAlia)->(DbCloseArea())

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
	cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += '  </WorksheetOptions>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
		cXML := ""
	EndIf
	
Return nil
// FIM DA FUNCAO: fQuadro2

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  06.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro3( aLinVazia )
Local cXML	   	 := ""
//Local _cQry      := ""
Local cWorkSheet := "6-Lista Currais Vazios"
Local aDados 	 := Array(1)
Local nI		 := 0

	If Len(aLinVazia) > 0
		
		cXML := ' <Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth="45" ss:DefaultRowHeight="15">
		cXML += ' <Column ss:Width="123"/>
		cXML += ' <Row ss:AutoFitHeight="0">
		cXML += '    <Cell ss:StyleID="s62"><Data ss:Type="String">' + cTitulo + " - Dt. Referência: " + DtoC(MV_PAR04) + '</Data>
		cXML += '   </Cell>
		cXML += ' </Row>
		cXML += ' <Row ss:AutoFitHeight="0">' + CRLF
		cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Linhas Vazias</Data></Cell>
		cXML += ' </Row>' + CRLF

		aDados[01] := 0
		
		For nI := 1 to Len(aLinVazia)
			If aLinVazia[nI,2]
				cXML += ' <Row ss:AutoFitHeight="0">
				cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String">'+ aLinVazia[nI,1] +'</Data></Cell>
				cXML += ' </Row>

				aDados[01] += 1
			EndIf
		Next nI
		
		// pular linha						
		cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
		
		aDados[01] := "Total: " + StrZero(aDados[01],2)
		cXML += ' <Row ss:AutoFitHeight="0">
		cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String">'+ aDados[01] +'</Data></Cell>
		cXML += ' </Row>
		
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
        cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
        cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
        cXML += '  </WorksheetOptions>' + CRLF
        cXML += ' </Worksheet>' + CRLF
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
			cXML := ""
		EndIf
	
	EndIf
	
Return nil
// FIM DA FUNCAO; fQuadro3


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  13.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro5(nAgrup, cDiasAb, dDTReferencia, dDtMoviment )
Local cXML	   	 := ""
Local _cQry      := ""
// Local _cAlia     := CriaTrab(,.F.)   
Local cWorkSheet := "7-Lista Currais-Movimentação"
Local aDados 	 := Array(22)
Local nQATU		 := 0
Local aPrintSD3  := {}
Local nI		 := 0
Local cChave	 := ""

_cQry := " WITH SALDO_ATUAL AS ( " + CRLF
_cQry += " 	SELECT  DISTINCT B2_FILIAL, B2_COD, B2_LOCAL, B1_XLOTE, B1_X_CURRA " + CRLF
_cQry += " 	FROM " + RetSqlName('SB1') + "  B1 " + CRLF
_cQry += " 	JOIN " + RetSqlName('SB2') + " B2 ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL='"+FWxFilial('SB2')+"' AND B1_COD=B2_COD AND B1.D_E_L_E_T_= ' ' AND B2.D_E_L_E_T_=' ' " + CRLF
// _cQry += " 	WHERE B1_GRUPO='BOV' AND B1_RASTRO <> 'L' " + CRLF
_cQry += " 	WHERE B1_GRUPO IN ('BOV','01') " + CRLF
_cQry += " ), " + CRLF
_cQry += " " + CRLF
_cQry += " SALDO_LOTE AS ( " + CRLF
_cQry += " 	SELECT DISTINCT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_X_CURRA, B8_LOTECTL " + CRLF
_cQry += " 	FROM " + RetSqlName('SB1') + "  B1 " + CRLF
_cQry += " 	JOIN " + RetSqlName('SB8') + "  B8 ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B8_FILIAL='"+FWxFilial('SB8')+"' AND B1_COD=B8_PRODUTO AND B1.D_E_L_E_T_= ' ' AND B8.D_E_L_E_T_=' ' " + CRLF
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
_cQry += "  JOIN SALDO_LOTE L ON B2_FILIAL=B8_FILIAL AND B2_COD=B8_PRODUTO AND B2_LOCAL=B8_LOCAL " + CRLF
_cQry += "  JOIN " + RetSqlName('Z08') + " Z8 ON Z08_FILIAL='"+FWxFilial('Z08')+"' AND RTRIM(UPPER(Z08_CODIGO))=RTRIM(UPPER(ISNULL(L.B8_X_CURRA, A.B1_X_CURRA))) AND Z8.D_E_L_E_T_=' ' " + CRLF
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
_cQry += " 	 FROM " + RetSqlName('SD2') + " D " + CRLF
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
_cQry += " 	 FROM " + RetSqlName('SD1') + " D " + CRLF
_cQry += " 	 JOIN " + RetSqlName('SB1') + "  B ON B1_FILIAL=' ' AND B1_COD=D1_COD AND B.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' ' " + CRLF
_cQry += "      JOIN PRODUTOS P ON D1_FILIAL=B2_FILIAL AND D1_COD=B2_COD AND D1_LOCAL=B2_LOCAL AND D1_LOTECTL=P.B1_XLOTE AND D.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	 WHERE D1_EMISSAO BETWEEN '"+ dDtMoviment +"' AND '"+ dDTReferencia + "' " + CRLF
_cQry += " ) " + CRLF
_cQry += " " + CRLF
_cQry += " SELECT * " + CRLF
_cQry += " FROM MOVIMENTOS " + CRLF
_cQry += " WHERE D3_FILIAL = '"+FWxFilial('SD3')+"' " + CRLF
_cQry += " ORDER BY Z08_TIPO, D3_FILIAL, D3_COD, D3_LOCAL, D3_EMISSAO, NUMSEQ, SEQ " + CRLF
	
	// If Select(_cAlia) > 0
		// (_cAlia)->(DbCloseArea())
	// EndIf
	If lower(cUserName) $ 'mbernardo,atoshio,admin'
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro5.sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAliaMOV),.F.,.F.) 
	
	aMov := {}
	While !(_cAliaMOV)->(Eof())
		aAdd( aMov		 , {} 						)
		aAdd( aTail(aMov), (_cAliaMOV)->NUMSEQ  	) // 01
		aAdd( aTail(aMov), (_cAliaMOV)->TIPO_MOV  	) // 02
		aAdd( aTail(aMov), (_cAliaMOV)->MOTIVO  	) // 03
		aAdd( aTail(aMov), (_cAliaMOV)->D3_FILIAL  	) // 04
		aAdd( aTail(aMov), (_cAliaMOV)->D3_QUANT 	) // 05
		aAdd( aTail(aMov), (_cAliaMOV)->D3_EMISSAO	) // 06
		aAdd( aTail(aMov), (_cAliaMOV)->D3_COD  	) // 07
		aAdd( aTail(aMov), (_cAliaMOV)->B1_DESC		) // 08
		aAdd( aTail(aMov), (_cAliaMOV)->D3_LOTECTL	) // 09
		aAdd( aTail(aMov), ""						) // 10
		aAdd( aTail(aMov), ""						) // 11
		aAdd( aTail(aMov), ""						) // 12
		aAdd( aTail(aMov), (_cAliaMOV)->D3_USUARIO	) // 13
		aAdd( aTail(aMov), (_cAliaMOV)->D3_X_OBS 	) // 14
		
		(_cAliaMOV)->(DbSkip())
	EndDo
	
	// TcSetField(_cAlia, "B1_XDATACO", "D")
	// TcSetField(_cAlia, "PrjecAba"  , "D")
	
	(_cAliaEST)->(DbGoTop())
	If !(_cAliaEST)->(Eof())
		
		cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth="45" ss:DefaultRowHeight="15">
        cXML += ' <Column ss:Width="82.125"/>
        cXML += ' <Column ss:Width="79.875"/>
        cXML += ' <Column ss:Width="58.5"/>
        cXML += ' <Column ss:Width="48.375"/>
        cXML += ' <Column ss:Width="97.875"/>
        cXML += ' <Column ss:Width="82.125"/>
        cXML += ' <Column ss:Width="75.75"/>
        cXML += ' <Column ss:Width="82.125"/>
        cXML += ' <Column ss:Width="43.125"/>
        cXML += ' <Column ss:Width="67.875"/>
        cXML += ' <Column ss:Width="37.5"/>
        cXML += ' <Column ss:Width="38.25"/>
        cXML += ' <Column ss:Width="110.25"/>
        cXML += ' <Column ss:Width="69"/>
        cXML += ' <Column ss:Width="50.25"/>
        cXML += ' <Column ss:Width="50.625"/>
        cXML += ' <Column ss:Width="73.125"/>
        cXML += ' <Column ss:Width="49.5"/>
        cXML += ' <Column ss:Width="74.25"/>
        cXML += ' <Column ss:Width="87"/>
        cXML += ' <Column ss:Width="230.625"/>
        cXML += ' <Column ss:Width="165.75"/>
        cXML += ' <Row ss:AutoFitHeight="0">
        cXML += '  <Cell ss:MergeAcross="21" ss:StyleID="s62">
        cXML += '       <Data ss:Type="String">' + cTitulo + " - Dt. Referência: " + DtoC(MV_PAR04) + '</Data>
        cXML += '  </Cell>
        cXML += ' </Row>
		cXML += ' <Row ss:AutoFitHeight="0">
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Produto</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Linha</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Lote</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Entrada</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Era</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Qtde '+ SubS(dToC(sToD(dDtMoviment)),1,5) +'</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Qtde '+ SubS(dToC(sToD(dDTReferencia)),1,5) +'</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Média (Kg)</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Origem</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Raça</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Sexo</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Dentição</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Dias</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">GMD</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Atual(Kg)</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Dias p/ Abate</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Data Abate</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Rend. Esperado</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Final</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Final Total</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Final Carcaça</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Fornecedor</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Observacao</Data></Cell>
        cXML += ' </Row>
		
		aDados[02]  := 0
		aDados[06]  := 0
		aDados[07]  := 0
		aDados[19]  := 0
		
		// cAgrupa := (_cAlia)->GRUPO2
		
		nLin := '0'
		(_cAliaEST)->(DbGoTop())
		While !(_cAliaEST)->(Eof())
			
			If (_cAliaEST)->Z08_TIPO <> '4'
				If cChave <> (_cAliaEST)->B2_COD+(_cAliaEST)->B1_X_CURRA+(_cAliaEST)->B1_XLOTE
					nQATU    := Iif(dDTReferencia == dToS(dDataBase), (_cAliaEST)->B2_QATU, CalcEstL( (_cAliaEST)->B2_COD, (_cAliaEST)->B2_LOCAL, sToD(dDTReferencia)+1, (_cAliaEST)->B1_XLOTE)[1] )
					nQATUMOV := Iif(dDtMoviment == dDTReferencia, nQATU, CalcEstL( (_cAliaEST)->B2_COD, (_cAliaEST)->B2_LOCAL, sToD(dDtMoviment), (_cAliaEST)->B1_XLOTE )[1] )
					If nQATU <> 0
						
						// ConOut(nLin:=Soma1(nLin)+': Inicio PrintSD3: ['+AllTrim((_cAliaEST)->B2_COD)+'] ' + Time())
						if Len( aPrintSD3 := PrintSD3(cWorkSheet, (_cAliaEST)->B2_COD, (_cAliaEST)->B1_XLOTE, Len(aDados), dDTReferencia, dDtMoviment ) ) > 0
						
							cXML += '<Row>' + CRLF
							cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel( (_cAliaEST)->B2_COD )+'</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel( (_cAliaEST)->B1_X_CURRA )+'</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel( (_cAliaEST)->B1_XLOTE )+'</Data></Cell>' + CRLF
							If Empty((_cAliaEST)->B1_XDATACO)
								cXML += '  <Cell><Data ss:Type="String"></Data></Cell>' + CRLF
							Else
								cXML += '  <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'+U_FrmtVlrExcel( (_cAliaEST)->B1_XDATACO )+'</Data></Cell>' + CRLF
							EndIf
							cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_X_ERA)+'</Data></Cell>' + CRLF
							cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel(nQATUMOV)+'</Data></Cell>' + CRLF
							cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel(nQATU)+'</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->B1_XPESOCO)+'</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XLOTCOM)+'</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XRACA)+'</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_X_SEXO)+'</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XDENTIC)+'</Data></Cell>' + CRLF
							cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->Dias)+'</Data></Cell>' + CRLF
							cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->Z09_GMDESP)+'</Data></Cell>' + CRLF
							cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->PesoAtual)+'</Data></Cell>' + CRLF
							cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->DiasAbate)+'</Data></Cell>' + CRLF
							If Empty( (_cAliaEST)->PrjecAba )
								cXML += '  <Cell><Data ss:Type="String"></Data></Cell>' + CRLF
							Else
								cXML += '  <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'+U_FrmtVlrExcel((_cAliaEST)->PrjecAba)+'</Data></Cell>' + CRLF
							EndIf					
							cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->Z09_RENESP)+'</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->PesoFinal)+'</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->PesoFinalTOTAL)+'</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->PesoCarcacaFinal)+'</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->A2_NOME)+'</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(PegaOBSB8((_cAliaEST)->B2_COD))+'</Data></Cell>' + CRLF
							cXML += '</Row>' + CRLF
							
							cXML += ' <Row ss:AutoFitHeight="0">
							cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Tipo Mov.</Data></Cell>
							cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Motivo</Data></Cell>
							cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Filial</Data></Cell>
							cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Quant.</Data></Cell>
							cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Data</Data></Cell>
							cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Origem</Data></Cell>
							cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Era</Data></Cell>
							cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Destino</Data></Cell>
							cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Era Dest.</Data></Cell>
							cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Lote</Data></Cell>
							cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String"></Data></Cell>
							cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Usuario</Data></Cell>
							cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Observacao</Data></Cell>
							cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += ' </Row>
							
							For nI := 1 to Len(aPrintSD3)
								cXML += '<Row ss:AutoFitHeight="0">
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,01] ) +'</Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,02] ) +'</Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,03] ) +'</Data></Cell>
								If Empty( aPrintSD3[nI,04] )
									cXML += ' <Cell><Data ss:Type="String"></Data></Cell>' + CRLF
								Else
									cXML += ' <Cell ss:StyleID="s72"><Data ss:Type="Number">'+ U_FrmtVlrExcel( aPrintSD3[nI,04] ) +'</Data></Cell>
								EndIf
								If Empty( aPrintSD3[nI,05] )
									cXML += '  <Cell><Data ss:Type="String"></Data></Cell>' + CRLF
								Else
									cXML += ' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'+ U_FrmtVlrExcel( sToD(aPrintSD3[nI,05]) ) +'</Data></Cell>
								EndIf
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,06] ) +'</Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,07] ) +'</Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,08] ) +'</Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,09] ) +'</Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,10] ) +'</Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,11] ) +'</Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,12] ) +'</Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,13] ) +'</Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
								cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
								cXML += '</Row>
							Next nI

							// pular linha						
							cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
							// pular linha						
							cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
							// pular linha						
							cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF

							EndIf	  		// U_VARELM01()
							
							aDados[02] += 1		           // Curral : Qtde de registros
							aDados[06] += nQATUMOV // Qtde
							aDados[07] += nQATU // Qtde
							aDados[19] += (_cAliaEST)->PesoFinalTOTAL // Qtde
					EndIf
				EndIf
				
				cChave := (_cAliaEST)->B2_COD+(_cAliaEST)->B1_X_CURRA+(_cAliaEST)->B1_XLOTE
			endIf
			
			(_cAliaEST)->(DbSkip())
		EndDo

		// pular linha						
		cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
		
		cXML += '<Row ss:AutoFitHeight="0">' + CRLF
		cXML += '<Cell ss:StyleID="s72" ss:Index="2"><Data ss:Type="Number">' + U_FrmtVlrExcel(aDados[02]) +'</Data></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="s72" ss:Index="6"><Data ss:Type="Number">' + U_FrmtVlrExcel(aDados[06]) +'</Data></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="s72" ss:Index="7"><Data ss:Type="Number">' + U_FrmtVlrExcel(aDados[07]) +'</Data></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="s68" ss:Index="18"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDados[19]) +'</Data></Cell>' + CRLF
		cXML += '</Row>' + CRLF
		
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
        cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
        cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
        cXML += '  </WorksheetOptions>' + CRLF
        cXML += ' </Worksheet>' + CRLF
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
			cXML := ""
		EndIf
	
	EndIf
	
	// (_cAliaEST)->(DbCloseArea())
Return nil
// FIM DA FUNCAO: fQuadro5


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  14.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro6( dDTReferencia, dDtMoviment, cDiasAb )
Local cXML	   	 := ""
Local cWorkSheet := "8-Lista Pastos-Movimentação"
Local nQATU		 := 0
Local aDados 	 := Array(16)
Local aPrintSD3  := {}
Local nI		 := 0

	(_cAliaEST)->(DbGoTop())
	If (_cAliaEST)->(Eof())
		MsgAlert("Não foi localizado informacao para o Quadro " + cWorkSheet )
	Else
		
		cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth="45" ss:DefaultRowHeight="15">
        cXML += ' <Column ss:Width="99"/>
        cXML += ' <Column ss:Width="85.875"/>
        cXML += ' <Column ss:Width="66" ss:Span="1"/>
        cXML += ' <Column ss:Index="5" ss:Width="99" ss:Span="2"/>
        cXML += ' <Column ss:Index="8" ss:Width="118.875"/>
        cXML += ' <Column ss:Width="59.25"/>
        cXML += ' <Column ss:Width="66"/>
        cXML += ' <Column ss:Width="33"/>
        cXML += ' <Column ss:Width="85.875"/>
        cXML += ' <Column ss:Width="79.125"/>
        cXML += ' <Column ss:Width="118.875"/>
        cXML += ' <Column ss:Width="264"/>
        cXML += ' <Column ss:Width="231"/>
        cXML += ' <Row ss:AutoFitHeight="0">
        cXML += '  <Cell ss:MergeAcross="15" ss:StyleID="s62">
        cXML += '       <Data ss:Type="String">' + cTitulo + " - Dt. Referência: " + DtoC(MV_PAR04) + '</Data>
        cXML += '  </Cell>
        cXML += ' </Row>
		cXML += ' <Row ss:AutoFitHeight="0">
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Produto</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Linha</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Lote</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Entrada</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Era</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Qtde '+ SubS(dToC(sToD(dDtMoviment)),1,5) +'</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Qtde '+ SubS(dToC(sToD(dDTReferencia)),1,5) +'</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Média (Kg)</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Origem</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Raça</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Sexo</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Dentição</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Dias</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">GMD</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Peso Atual(Kg)</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Fornecedor</Data></Cell>
        cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Observacao</Data></Cell>
        cXML += ' </Row>
	
		aDados[02]  := 0
		aDados[06]  := 0
		aDados[07]  := 0
		
		cAgrupa := (_cAliaEST)->GRUPO2
		
		nLin := '0'
		(_cAliaEST)->(DbGoTop())
		While !(_cAliaEST)->(Eof())
			
			If (_cAliaEST)->Z08_TIPO <> '1'
				nQATU    := Iif(dDTReferencia == dToS(dDataBase), (_cAliaEST)->B2_QATU, CalcEstL( (_cAliaEST)->B2_COD, (_cAliaEST)->B2_LOCAL, sToD(dDTReferencia)+1, (_cAliaEST)->B1_XLOTE)[1] )
				nQATUMOV := Iif(dDtMoviment == dDTReferencia, nQATU, CalcEstL( (_cAliaEST)->B2_COD, (_cAliaEST)->B2_LOCAL, sToD(dDtMoviment), (_cAliaEST)->B1_XLOTE )[1] )
				If nQATU <> 0

					ConOut(nLin:=Soma1(nLin)+': Inicio PrintSD3: ['+AllTrim((_cAliaEST)->B2_COD)+'] ' + Time())
					If Len( aPrintSD3 := PrintSD3(cWorkSheet, (_cAliaEST)->B2_COD, (_cAliaEST)->B1_XLOTE, Len(aDados), dDTReferencia, dDtMoviment ) ) > 0
						
						cXML += '<Row>' + CRLF
						cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel( (_cAliaEST)->B2_COD )+'</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel( (_cAliaEST)->B1_X_CURRA )+'</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel( (_cAliaEST)->B1_XLOTE )+'</Data></Cell>' + CRLF
						If Empty((_cAliaEST)->B1_XDATACO)
							cXML += '  <Cell><Data ss:Type="String"></Data></Cell>' + CRLF
						Else
							cXML += '  <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'+U_FrmtVlrExcel( (_cAliaEST)->B1_XDATACO )+'</Data></Cell>' + CRLF
						EndIf
						cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_X_ERA)+'</Data></Cell>' + CRLF
						cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel(nQATUMOV)+'</Data></Cell>' + CRLF
						cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel(nQATU)+'</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s68"><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->B1_XPESOCO)+'</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XLOTCOM)+'</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XRACA)+'</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_X_SEXO)+'</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->B1_XDENTIC)+'</Data></Cell>' + CRLF
						cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->Dias)+'</Data></Cell>' + CRLF
						cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->Z09_GMDESP)+'</Data></Cell>' + CRLF
						cXML += '  <Cell><Data ss:Type="Number">'+U_FrmtVlrExcel((_cAliaEST)->PesoAtual)+'</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel((_cAliaEST)->A2_NOME)+'</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel(PegaOBSB8((_cAliaEST)->B2_COD))+'</Data></Cell>' + CRLF
						cXML += '</Row>' + CRLF

						cXML += ' <Row ss:AutoFitHeight="0">
						cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Tipo Mov.</Data></Cell>
						cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Motivo</Data></Cell>
						cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Filial</Data></Cell>
						cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Quant.</Data></Cell>
						cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Data</Data></Cell>
						cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Origem</Data></Cell>
						cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Era</Data></Cell>
						cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Destino</Data></Cell>
						cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Era Dest.</Data></Cell>
						cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Lote</Data></Cell>
						cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String"></Data></Cell>
						cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Usuario</Data></Cell>
						cXML += '   <Cell ss:StyleID="s81"><Data ss:Type="String">Observacao</Data></Cell>
						cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
						cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
						cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
						cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
						cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
						cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
						cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
						cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
						cXML += '   <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
						cXML += ' </Row>
						
						For nI := 1 to Len(aPrintSD3)
							cXML += '<Row ss:AutoFitHeight="0">
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,01] ) +'</Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,02] ) +'</Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,03] ) +'</Data></Cell>
							If Empty( aPrintSD3[nI,04] )
								cXML += ' <Cell><Data ss:Type="String"></Data></Cell>' + CRLF
							Else
								cXML += ' <Cell ss:StyleID="s72"><Data ss:Type="Number">'+ U_FrmtVlrExcel( aPrintSD3[nI,04] ) +'</Data></Cell>
							EndIf
							If Empty( aPrintSD3[nI,05] )
								cXML += '  <Cell><Data ss:Type="String"></Data></Cell>' + CRLF
							Else
								cXML += ' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'+ U_FrmtVlrExcel( sToD(aPrintSD3[nI,05]) ) +'</Data></Cell>
							EndIf
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,06] ) +'</Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,07] ) +'</Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,08] ) +'</Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,09] ) +'</Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,10] ) +'</Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,11] ) +'</Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,12] ) +'</Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String">'+ U_FrmtVlrExcel( aPrintSD3[nI,13] ) +'</Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += ' <Cell ss:StyleID="s66"><Data ss:Type="String"></Data></Cell>
							cXML += '</Row>
						Next nI

						// pular linha						
						cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
						// pular linha						
						cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
						// pular linha						
						cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
						
					EndIf
					
					aAdd( aDadTp4, { (_cAliaEST)->B2_COD, ;
									 (_cAliaEST)->B1_X_CURRA, ;
									 (_cAliaEST)->B1_XLOTE, ;
									 (_cAliaEST)->B1_XDATACO, ;
									 (_cAliaEST)->B1_X_ERA, ;
									 nQATUMOV, ;
									 nQATU, ;
									 (_cAliaEST)->B1_XPESOCO, ;
									 (_cAliaEST)->B1_XLOTCOM, ;
									 (_cAliaEST)->B1_XRACA, ;
									 (_cAliaEST)->B1_X_SEXO, ;
									 (_cAliaEST)->B1_XDENTIC, ;
									 (_cAliaEST)->Dias, ;
									 (_cAliaEST)->Z09_GMDESP, ;
									 (_cAliaEST)->PesoAtual } )
									  
					aDados[02] += 1		           // Curral : Qtde de registros
					aDados[06] += nQATUMOV // Qtde
					aDados[07] += nQATU // Qtde

				EndIf
			endIf
			(_cAliaEST)->(DbSkip())
		EndDo

		// pular linha						
		cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
		
		cXML += '<Row ss:AutoFitHeight="0">' + CRLF
		cXML += '<Cell ss:StyleID="s72" ss:Index="2"><Data ss:Type="Number">' + U_FrmtVlrExcel(aDados[02]) +'</Data></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="s72" ss:Index="6"><Data ss:Type="Number">' + U_FrmtVlrExcel(aDados[06]) +'</Data></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="s72" ss:Index="7"><Data ss:Type="Number">' + U_FrmtVlrExcel(aDados[07]) +'</Data></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="s68" ss:Index="18"><Data ss:Type="Number">'+ U_FrmtVlrExcel(aDados[19]) +'</Data></Cell>' + CRLF
		cXML += '</Row>' + CRLF
		
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
        cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
        cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
        cXML += '  </WorksheetOptions>' + CRLF
        cXML += ' </Worksheet>' + CRLF
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
			cXML := ""
		EndIf
	
	EndIf
	
	// (_cAliaEST)->(DbCloseArea())
Return nil
// FIM DA FUNCAO: fQuadro6


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
Local nI		 := 0, nJ := 0

nPos := aScan( aMov, { |x| x[7]+x[9] == cProduto+cLote } )
While nPos > 0 // !(_cAliaD3)->(Eof())

	if Len(aAUXAlias) > 0 .and. ;
		aAUXAlias[ Len(aAUXAlias), 1] == aMov[nPos, 1] // (_cAliaD3)->NUMSEQ
		
		If aAUXAlias[ Len(aAUXAlias), 02 ] <> aMov[nPos, 2] // (_cAliaD3)->TIPO_MOV
			aAUXAlias[ Len(aAUXAlias), 02 ] += "/" + aMov[nPos, 2] // (_cAliaD3)->TIPO_MOV
		EndIf 
		
		If aAUXAlias[ Len(aAUXAlias), 03 ] <> AllTrim(aMov[nPos, 3]) // (_cAliaD3)->MOTIVO)
			aAUXAlias[ Len(aAUXAlias), 03 ] += "/" + aMov[nPos, 3] // (_cAliaD3)->MOTIVO
		Else
			If aAUXAlias[ Len(aAUXAlias), 03 ] == "TRANSFERENCIA"
				If cProduto == aAUXAlias[ Len(aAUXAlias), 07 ]
					aAUXAlias[ Len(aAUXAlias), 03 ] := "SAIDA POR TRANSFERENCIA"
				else
					aAUXAlias[ Len(aAUXAlias), 03 ] := "ENTRADA POR TRANSFERENCIA"
				EndIf
			EndIf
		EndIf

		If aAUXAlias[ Len(aAUXAlias), 04 ] <> aMov[nPos, 4] // (_cAliaD3)->D3_FILIAL
			aAUXAlias[ Len(aAUXAlias), 04 ] += "/" + aMov[nPos, 4] // (_cAliaD3)->D3_FILIAL
		EndIf
		
		aAUXAlias[ Len(aAUXAlias), 09 ] := aMov[nPos, 7] // (_cAliaD3)->D3_COD
		aAUXAlias[ Len(aAUXAlias), 10 ] := aMov[nPos, 8] // (_cAliaD3)->B1_DESC
		aAUXAlias[ Len(aAUXAlias), 11 ] := aMov[nPos, 9] // (_cAliaD3)->B1_XLOTE
		
	Else

		aAdd( aAUXAlias, aMov[nPos] )
	EndIf 
	
	nPos+=1
	If ( nPos > Len(aMov) ) .or. ( aMov[nPos, 7] <> cProduto )
		nPos := 0 // zero para sair do laço
	endIf
	// (_cAliaD3)->(DbSkip())
	
EndDo

if Len(aAUXAlias) > 0
	
	// as colunas vou imprimir fora do vetor, estava dando erro de tipo
	// // oExcel:SetLineBold(.T.)
	// _aColunas := {}
	// aAdd( _aColunas , "Tipo Mov." 	)  // 01
	// aAdd( _aColunas , "Motivo" 		)  // 02
	// aAdd( _aColunas , "Filial" 		)  // 03
	// aAdd( _aColunas , "Quant." 		)  // 04
	// aAdd( _aColunas , "Data" 		)  // 05
	// aAdd( _aColunas , "Origem" 		)  // 06
	// aAdd( _aColunas , "Era" 	)  // 07
	// aAdd( _aColunas , "Destino" 		)  // 08
	// aAdd( _aColunas , "Era Dest." 	)  // 09
	// aAdd( _aColunas , "Lote" 	)  // 10
	// aAdd( _aColunas , "" 		)  // 11
	// aAdd( _aColunas , "Usuario" 	)  // 12
	// aAdd( _aColunas , "Observação" 	)  // 13
	
	// For nJ := Len(_aColunas)+1 to nQtCol
		// aAdd( _aColunas , "" )
	// Next nJ
	
	// // Legendas
	// aAdd( aRet, _aColunas )
	// // oExcel:SetLineBold(.F.)
	
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
	// aAdd( aRet, Array(nQtCol) )
	// aAdd( aRet, Array(nQtCol) )
	// aAdd( aRet, Array(nQtCol) )

EndIf

// (_cAliaD3)->(DbCloseArea())

RestArea(aArea)
Return aRet
// FIM DA FUNCAO: PrintSD3


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


User function FrmtVlrExcel( xVar )	// u_varelm01()
local cRet  := ""
local cType := ""

	If Empty(xVar)
		cRet := ""
	Else
		cType := ValType(xVar)
		
	    if cType == "U"
	        cRet := ""
	    elseif cType == "C"
	        cRet := U_Formata( xVar ) 
	    elseif cType == "N"
	        if xVar == 0
	            cRet := ""
	        else
	            cRet := AllTrim( Str( xVar ) )
	        endif
	    elseif cType == "D"
	        xVar := DToS( xVar )
	        cRet := SubStr(xVar, 1, 4) + "-" + SubStr(xVar, 5, 2) + "-" + SubStr(xVar, 7, 2) + "T00:00:00.000"
	    else
	        cRet := Iif(xVar , "=VERDADEIRO" ,  "=FALSO") 
	    endif
    EndIf
return AllTrim( cRet )

/*/{Protheus.doc} TimeStamp
/*/
User function TimeStamp(dData, cTime)
return FWTimeStamp(3, Iif(Empty(dData), Date(), dData), Iif(Empty(cTime), Time(), cTime))

/*/{Protheus.doc} Formata
/*/
User function Formata( cVar )
local nLen := 0
local i    := 0
local aPad := { { 'ã', 'a' }, { 'á' , 'a' }, { 'â', 'a' }, { 'ä', 'a' }, ;
                { 'Ã', 'A' }, { 'Á' , 'A' }, { 'Â', 'A' }, { 'Ä', 'A' }, ;
                { 'é', 'e' }, { 'ê' , 'e' }, { 'ë', 'e' }, ;
                { 'É', 'E' }, { 'Ê' , 'E' }, { 'Ë', 'E' }, ;
                { 'í', 'i' }, { 'î' , 'i' }, { 'ï', 'i' }, ; 
                { 'õ', 'o' }, { 'ó' , 'o' }, { 'ô', 'o' }, { 'ö', 'o' },;
                { 'Õ', 'O' }, { 'Ó' , 'O' }, { 'Ô', 'O' }, { 'Ö', 'O' },;
                { 'ú', 'u' }, { 'û' , 'u' }, { 'ü', 'u' }, ;
                { 'Ú', 'U' }, { 'Û' , 'U' }, { 'Ü', 'U' }, ;
                { 'ç', 'c' }, ;
                { 'Ç', 'C' }, ;
                { '&', '' } }
                
    nLen := Len(aPad)
    for i := 1 to nLen
       cVar := StrTran(cVar, aPad[i][1], aPad[i][2])
    next
return AllTrim(cVar)

/* MJ : 10.04.2018
	# Roda matriz em busca de Era */
/*
Static Function SomaValEst( cAgrupa, aMatriz, nCol ) 
Local nRet  := 0
Local nI	:= 0

	For nI := 1 to Len(aMatriz)
		If allTrim(cAgrupa) == 	AllTrim( aMatriz[nI, 4] )
			nRet += aMatriz[nI, nCol] 
		EndIf
	next nI
	
return nRet
*/


Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local i		 	:= 0, j := 0

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

aAdd(aRegs,{cPerg, "01", "Agrupamento?"           , "", "", "MV_CH1", "N", 					    1,					        0, 3, "C", "", "MV_PAR01" , "Curral","","","","","Dt. de Abate","","","","","Lote","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "02", "Dias p/ Abate?"	      , "", "", "MV_CH2", "C",                      3,                          0, 0, "G", "", "MV_PAR02" , "", "","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg, "03", "Dias de Ração?"	      , "", "", "MV_CH3", "N",                      3,                          0, 0, "G", "", "MV_PAR03" , "", "","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg, "04", "Data Referencia?"       , "", "", "MV_CH4", "D", TamSX3("D3_EMISSAO")[1]  , TamSX3("D3_EMISSAO")[2], 0, "G", "", "MV_PAR04" , "", "","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg, "05", "Data Movimentacao?"     , "", "", "MV_CH5", "D", TamSX3("D3_EMISSAO")[1]  , TamSX3("D3_EMISSAO")[2], 0, "G", "", "MV_PAR05" , "", "","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg, "06", "Imprime Analitico?"     , "", "", "MV_CH6", "N", 					    1,					        0, 2, "C", "", "MV_PAR06" , "Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "07", "Imprime Movimentação?"  , "", "", "MV_CH7", "N", 					    1,					        0, 2, "C", "", "MV_PAR07" , "Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "08", "Ordenação?"             , "", "", "MV_CH8", "N", 					    1,					        0, 2, "C", "", "MV_PAR08" , "Linha","","","","","Tempo/Confinamento","","","","","","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "09", "Reprocessa Saldo Total?", "", "", "MV_CH9", "N", 					    1,					        0, 2, "C", "", "MV_PAR09" , "Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","U","","","",""})

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

/* MJ : 28.05.2018 
	# Funcao para Processar SQL
		- Incluido a pedido do Marquinhos, Planilha para informar a Racao, a mesma vem com Dia -1; 
*/
Static Function VASqlM01(cTipo, _cAlias)
Local _cQry 	  := ""
Local cProdIgnora := GetMV('VA_PRDIGNR',, "'030006','030007'") // LISTA DE PRODUTOS PARA IGNORAR NO SQL

_cQry := "  WITH PROD_RACAO		 " + CRLF
_cQry += "  AS (		 " + CRLF
_cQry += "      SELECT D3.D3_FILIAL					    FILIAL,		 " + CRLF
_cQry += "      	   D3.D3_COD					    CODIGO,		 " + CRLF
_cQry += "      	   B1.B1_DESC					    DESCRICAO, 		 " + CRLF
_cQry += "      	   D3.D3_UM						    UM,    					 " + CRLF
_cQry += "         	   D3.D3_OP							OP,		 " + CRLF
_cQry += "  		   D3.D3_EMISSAO					EMISSAO,     		 " + CRLF
_cQry += "      	   SUM(D3.D3_QUANT)					QTD,		 " + CRLF
_cQry += "      	   SUM(D3.D3_CUSTO1)				CUSTO		 " + CRLF
_cQry += "		   , B1_X_TRATO " + CRLF
_cQry += "      FROM SD3010 D3		 " + CRLF
_cQry += "      JOIN " + RetSQLName('SB1') + " B1 ON 		 " + CRLF
_cQry += "      D3_COD = B1_COD 		 " + CRLF
_cQry += "      WHERE D3.D3_TM = '001'		 " + CRLF
_cQry += "      AND D3.D3_EMISSAO BETWEEN '" + dToS( MV_PAR04-MV_PAR03 ) + "' AND '" + dToS( MV_PAR04-1 ) + "' " + CRLF
_cQry += "      AND D3.D_E_L_E_T_ = ' '  		 " + CRLF
_cQry += "      AND B1.D_E_L_E_T_ = ' ' 		 " + CRLF
_cQry += "      AND B1_X_TRATO = '1'		 " + CRLF
_cQry += "      --AND D3.D3_COD = '030013'		 " + CRLF
_cQry += "      GROUP BY D3.D3_FILIAL, D3.D3_COD, B1_DESC, D3.D3_UM, D3.D3_EMISSAO, D3.D3_OP		 " + CRLF
_cQry += "	  , B1_X_TRATO " + CRLF
_cQry += "      --ORDER BY D3.D3_COD,  			 " + CRLF
_cQry += "      	   --D3.D3_EMISSAO					 " + CRLF
_cQry += "  	),		 " + CRLF
_cQry += "  INS_CARR		 " + CRLF
_cQry += "  AS (		 " + CRLF
_cQry += "  	SELECT P.FILIAL, P.CODIGO, D3.D3_FILIAL, D3_COD, D3.D3_EMISSAO, SUM(D3_QUANT) QTD, SUM(D3_CUSTO1) CUSTO FROM SD3010 D3		 " + CRLF
_cQry += "  	  JOIN PROD_RACAO P ON		 " + CRLF
_cQry += "  	       D3.D3_FILIAL				=			P.FILIAL		 " + CRLF
_cQry += "  	   AND D3.D3_OP					=			P.OP		 " + CRLF
_cQry += "  	   AND D3.D3_EMISSAO			=			P.EMISSAO		 " + CRLF
_cQry += "  	   AND D3.D3_COD				<>			P.CODIGO		 " + CRLF
_cQry += "  	   AND D3_CF					LIKE		'RE%'		 " + CRLF
_cQry += "  	 WHERE D3.D_E_L_E_T_			=			' ' 		 " + CRLF
_cQry += "  	 GROUP BY P.FILIAL, P.CODIGO, D3.D3_FILIAL, D3.D3_COD, D3_EMISSAO		 " + CRLF
_cQry += "  	)		 " + CRLF
_cQry += " " + CRLF
_cQry += "  	SELECT P.B1_X_TRATO, " + CRLF
_cQry += "		   P.FILIAL,		 " + CRLF
_cQry += "  		   P.CODIGO, 		 " + CRLF
_cQry += "			   P.DESCRICAO,		 " + CRLF
_cQry += "  		   P.UM,		 " + CRLF
_cQry += "  		   P.EMISSAO, 		 " + CRLF
_cQry += "  		   SUM(P.QTD) QTD, 		 " + CRLF
_cQry += "  		   SUM(P.CUSTO) CUSTO 		 " + CRLF
_cQry += "  	FROM PROD_RACAO P		 " + CRLF
_cQry += "  	WHERE	 CODIGO NOT IN (" + cProdIgnora + ") " + CRLF
_cQry += "  	GROUP BY P.B1_X_TRATO, " + CRLF
_cQry += "			 P.FILIAL, 		 " + CRLF
_cQry += "  		     P.CODIGO, 		 " + CRLF
_cQry += "			 P.DESCRICAO,	 " + CRLF
_cQry += "  			 P.UM,		 " + CRLF
_cQry += "  			 P.EMISSAO		 " + CRLF
_cQry += "  	ORDER BY P.B1_X_TRATO,
_cQry += "  	 		 P.FILIAL,	
_cQry += "  			 P.CODIGO, 	
_cQry += "  	 		 P.EMISSAO	

If lower(cUserName) $ 'mbernardo,atoshio,admin'
	MemoWrite(StrTran(cArquivo,".xml","")+"Quadro" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

TcSetField(_cAlias, "EMISSAO", "D")

Return !(_cAlias)->(Eof())


Static _nPFilial := 1
Static _nPCODIGO := 2
Static _nPDescri := 3
Static _nPUm     := 4


/* MJ : 28.05.2018
	# Processa planilha de custo da racao; 
*/
Static Function fQuadro7()

Local cXML 		 := ""
Local cWorkSheet := "7-Resumo Producao Racao"
Local nTotLin	 := 0
Local nCol		 := 2

Local nQtDias    := DateDiffDay(MV_PAR04-MV_PAR03, MV_PAR04)
Local dDia 		 := MV_PAR04-1
Local aDados	 := {} // Array(4+(3*nQtdias))
Local aMatriz	 := {}
Local nI		 := 0, nJ := 0

	(_cAliaRAC)->(DbGoTop())
	If !(_cAliaRAC)->(Eof())  // U_VARELM01()
		
		aMatriz := U_GetMatrizSaldoErasPorDia( xFilial('SB2'), MV_PAR04-MV_PAR03, MV_PAR04-1, Iif(MV_PAR09==1,.T.,.F.), {,,,,,,"BOV","BOV","01","01"} )
	
		aDados 	:= Array(4+(3*nQtdias))

		cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
		cXML += '  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF
		
		cXML += '  <Column ss:Width="25.125"/>
		cXML += '  <Column ss:Width="35.625"/>
		cXML += '  <Column ss:Width="102.75"/>
		cXML += '  <Column ss:Width="61.875"/>
		nI := 5 
		while nI <= len(aDados)+1
			cXML += ' <Column ss:Width="56"/>
			cXML += ' <Column ss:Width="52.5"/>
			cXML += ' <Column ss:Width="85"/>
			nI+=3
		EndDo

		cXML += '   <Row ss:AutoFitHeight="0">
        cXML += '     <Cell ss:MergeAcross="' + AllTrim(Str( nQtDias*3+6 )) + '" ss:StyleID="s62">
        cXML += '       <Data ss:Type="String">' + cTitulo + " - Dt. Referência de " + DtoC(MV_PAR04-MV_PAR03) + ' ate ' + DtoC(MV_PAR04-1) + '</Data>
        cXML += '     </Cell>
        cXML += '   </Row>

		cXML += ' <Row ss:AutoFitHeight="0">' + CRLF
		For dDia := MV_PAR04-MV_PAR03 to MV_PAR04-1
			cXML += ' <Cell ss:StyleID="TitRacao"
			cXML += '     ss:MergeAcross="2"
			cXML += '     ss:Index="' + AllTrim( Str(nCol+=3) ) + '">
			cXML += ' <Data ss:Type="DateTime">' + U_FrmtVlrExcel(dDia) + '</Data></Cell>' + CRLF
		Next dDia
		cXML += '     <Cell ss:StyleID="TitRacao"
		cXML += '         ss:MergeAcross="2"
		cXML += '         ss:Index="' + AllTrim( Str(nCol+=3) ) + '">
		cXML += '     <Data ss:Type="String">TOTAL PERIODO</Data></Cell>' + CRLF
		cXML += ' </Row>' + CRLF

		cXML += ' <Row ss:AutoFitHeight="0">' + CRLF
		cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data></Cell>' + CRLF
		cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Codigo</Data></Cell>' + CRLF
		cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Descricao</Data></Cell>' + CRLF
		cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">UM</Data></Cell>' + CRLF
		
		For dDia := MV_PAR04-MV_PAR03 to MV_PAR04-1
			cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Qtd.</Data></Cell>' + CRLF
			cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Custo Unit.</Data></Cell>' + CRLF
			cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Custo Total</Data></Cell>' + CRLF
		Next dDia
		cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Qtd.</Data></Cell>' + CRLF
		cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Custo Unit.</Data></Cell>' + CRLF
		cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Custo Total</Data></Cell>' + CRLF
		cXML += ' </Row>' + CRLF
		
		While !(_cAliaRAC)->(Eof())
			
			If Empty ( aDados[ _nPCODIGO ] )
				aDados[ _nPFilial ] := (_cAliaRAC)->FILIAL
				aDados[ _nPCODIGO ] := (_cAliaRAC)->CODIGO
				aDados[ _nPDescri ] := (_cAliaRAC)->DESCRICAO
				aDados[ _nPUm     ] := (_cAliaRAC)->UM
			EndIf

			nPos := (_cAliaRAC)->EMISSAO-(MV_PAR04-MV_PAR03)
			nPosCol := Iif(nPos==0, nPos, nPos*3 )
			aDados[5+nPosCol ] := (_cAliaRAC)->QTD
			aDados[6+nPosCol ] := 0//(_cAliaRAC)->CUSTO/(_cAliaRAC)->QTD
			aDados[7+nPosCol ] := (_cAliaRAC)->CUSTO

			(_cAliaRAC)->(DbSkip())
		
			If (_cAliaRAC)->(Eof()) .or. aDados[ _nPCODIGO ] <> (_cAliaRAC)->CODIGO
				// imprimir
				// oExcel:AddRow( cWorkSheet, cTitulo, aDados )	
				
				// imprimi dados
				cXML += ' <Row>' + CRLF
				cXML += '		<Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel( aDados[ _nPFilial ] )+'</Data></Cell>' + CRLF
				cXML += '		<Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel( aDados[ _nPCODIGO ] )+'</Data></Cell>' + CRLF
				cXML += '		<Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel( aDados[ _nPDescri ] )+'</Data></Cell>' + CRLF
				cXML += '		<Cell ss:StyleID="s66"><Data ss:Type="String">'+U_FrmtVlrExcel( aDados[ _nPUm     ] )+'</Data></Cell>' + CRLF
				
				nI := 5 
				while nI <= len(aDados)
					cXML += '		<Cell ss:StyleID="s72"><Data ss:Type="Number">'+ U_FrmtVlrExcel( aDados[nI] ) +'</Data></Cell>' + CRLF
					cXML += '		<Cell ss:StyleID="s69" ss:Formula="=IFERROR(RC[1]/RC[-1],&quot;&quot;)"><Data ss:Type="Number"></Data></Cell>' + CRLF
					cXML += '		<Cell ss:StyleID="s69"><Data ss:Type="Number">'+ U_FrmtVlrExcel( aDados[nI+2] ) +'</Data></Cell>' + CRLF
					nI+=3
				EndDo
				
				cXML += ' <Cell ss:StyleID="s205"
				cXML += ' 		ss:Formula="=SUMIF(R3C[-' + AllTrim(Str(nCol-5)) + ']:R3C[-1],R3C,RC[-' + AllTrim(Str(nCol-5)) + ']:RC[-1])"><Data
				cXML += ' 		ss:Type="Number"></Data></Cell>
				cXML += ' <Cell ss:StyleID="s206" ss:Formula="=IFERROR(RC[1]/RC[-1],&quot;&quot;)"><Data
				cXML += '		ss:Type="Number"></Data></Cell>
				cXML += ' <Cell ss:StyleID="s206"
				cXML += ' 		ss:Formula="=SUMIF(R3C[-' + AllTrim(Str(nCol-3)) + ']:R3C[-3],R3C,RC[-' + AllTrim(Str(nCol-3)) + ']:RC[-3])"><Data
				cXML += ' 		ss:Type="Number"></Data></Cell>
				
				cXML += ' </Row>' + CRLF
				
				nTotLin += 1
				aDados	:= Array(4+(3*nQtdias))
			EndIf
		EndDo

		// SOMATORIAS por data 
		cXML += ' <Row>' + CRLF
		cXML += '		<Cell ss:StyleID="s66"/>' + CRLF
		cXML += '		<Cell ss:StyleID="s66"/>' + CRLF
		cXML += '		<Cell ss:StyleID="s66"/>' + CRLF
		cXML += '		<Cell ss:StyleID="s66"/>' + CRLF
		nI := 5 
		while nI <= len(aDados)+1
			cXML += '		<Cell ss:StyleID="s72" ss:Formula="=IFERROR(SUM(R[-'+AllTrim(Str(nTotLin))+']C:R[-1]C),&quot;&quot;)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXML += '		<Cell ss:StyleID="s69" ss:Formula="=IFERROR(RC[1]/RC[-1],&quot;&quot;)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXML += '		<Cell ss:StyleID="s69" ss:Formula="=IFERROR(SUM(R[-'+AllTrim(Str(nTotLin))+']C:R[-1]C),&quot;&quot;)"><Data ss:Type="Number"></Data></Cell>' + CRLF			
			nI+=3
		EndDo
		cXML += ' </Row>' + CRLF
		// F I M - SOMATORIAS por data 
		
		// pular linha						
		cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
		
		
		// Total Rebanho
		// cXML += ' <Row ss:Height="27">' + CRLF
		cXML += ' <Row>' + CRLF
		cXML += '		<Cell ss:Index="4" 
		cXML += '			  ss:StyleID="s102"><Data ss:Type="String">Total Rebanho</Data></Cell>' + CRLF
		
		nCol 	:= 1
		nI 		:= 5 
		while nI <= len(aDados)	
			nCol    += 1
			_nTotal := 0
			for nJ := 1 to len( aMatriz )-1
				_nTotal += aMatriz[ nJ, nCol ]
			next nJ
		
			cXML += '		<Cell ss:StyleID="s66"/>' + CRLF
			cXML += '		<Cell ss:StyleID="s66"/>' + CRLF
			cXML += '		<Cell ss:StyleID="s72"><Data ss:Type="Number">' + AllTrim(Str( _nTotal )) + '</Data></Cell>' + CRLF
			
			nI+=3
		EndDo
		cXML += '		<Cell ss:StyleID="s207"/>' + CRLF
		cXML += '		<Cell ss:StyleID="s207"/>' + CRLF
		cXML += '		<Cell ss:StyleID="s208" ss:Formula="=SUM(RC5:RC[-3])"><Data ss:Type="Number"></Data></Cell>' + CRLF
		cXML += ' </Row>' + CRLF
		
		
		// Kg x Cabeca
		cXML += ' <Row>' + CRLF
		cXML += '		<Cell ss:Index="4" 
		cXML += '			  ss:StyleID="s102"><Data ss:Type="String">Kg x Cabeca</Data></Cell>' + CRLF
		nI := 5 
		while nI <= len(aDados)
			cXML += '		<Cell ss:StyleID="s66"/>' + CRLF
			cXML += '		<Cell ss:StyleID="s66"/>' + CRLF
			cXML += '		<Cell ss:StyleID="s68" ss:Formula="=R[-3]C[-2]/R[-1]C"><Data ss:Type="Number"></Data></Cell>' + CRLF
			nI+=3
		EndDo
		cXML += '		<Cell ss:StyleID="s207"/>' + CRLF
		cXML += '		<Cell ss:StyleID="s207"/>' + CRLF
		cXML += '		<Cell ss:StyleID="s209" ss:Formula="=R[-3]C[-2]/R[-1]C"><Data ss:Type="Number"></Data></Cell>' + CRLF		
		cXML += ' </Row>' + CRLF

		
		// Custo Trato x Cabeca
		cXML += ' <Row>' + CRLF
		cXML += '		<Cell ss:Index="4" 
		cXML += '			  ss:StyleID="s102"><Data ss:Type="String">Custo Trato x Cabeca</Data></Cell>' + CRLF
		nI := 5 
		while nI <= len(aDados)
			cXML += '		<Cell ss:StyleID="s66"/>' + CRLF
			cXML += '		<Cell ss:StyleID="s66"/>' + CRLF
			cXML += '		<Cell ss:StyleID="s69" ss:Formula="=R[-4]C/R[-2]C"><Data ss:Type="Number"></Data></Cell>' + CRLF
			nI+=3
		EndDo
		cXML += '		<Cell ss:StyleID="s207"/>' + CRLF
		cXML += '		<Cell ss:StyleID="s207"/>' + CRLF
		cXML += '		<Cell ss:StyleID="s209" ss:Formula="=R[-4]C/R[-2]C"><Data ss:Type="Number"></Data></Cell>' + CRLF
		cXML += ' </Row>' + CRLF

		// pular linha						
		cXML += '<Row ss:AutoFitHeight="0" />' + CRLF		
		
		// aMatriz - Resultados
		For nI := 1 to Len(aMatriz)-1
			cXML += ' <Row>' + CRLF
			cXML += '		<Cell ss:StyleID="s66"/>' + CRLF
			For nJ := 1 to Len(aMatriz[nI])
				If nJ > 1
					If nJ < Len(aMatriz[nI])
						cXML += ' <Cell ss:StyleID="s72"><Data ss:Type="Number">' + U_FrmtVlrExcel(aMatriz[nI, nJ]) + '</Data></Cell>' + CRLF
					Else
						cXML += ' <Cell ss:StyleID="s208"><Data ss:Type="Number">' + U_FrmtVlrExcel(aMatriz[nI, nJ]) + '</Data></Cell>' + CRLF
					EndIf
				Else
					cXML += ' <Cell ss:StyleID="s102"><Data ss:Type="String">' + U_FrmtVlrExcel(aMatriz[nI, nJ]) + '</Data></Cell>' + CRLF
				EndIf
				cXML += '		<Cell ss:StyleID="s66"/>' + CRLF
				cXML += '		<Cell ss:StyleID="s66"/>' + CRLF
			Next nJ
			cXML += ' </Row>' + CRLF
		Next nI
		
		// pular linha						
		// cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF

		// Final da Planilha
		cXML += '</Table>' + CRLF
		cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel"> ' + CRLF
		cXML += ' <PageSetup> ' + CRLF
		cXML += ' <Header x:Margin="0.31496062000000002"/> ' + CRLF
		cXML += ' <Footer x:Margin="0.31496062000000002"/> ' + CRLF
		cXML += ' <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" ' + CRLF
		cXML += ' x:Right="0.511811024" x:Top="0.78740157499999996"/> ' + CRLF
		cXML += ' </PageSetup> ' + CRLF
		cXML += ' <Unsynced/> ' + CRLF
		cXML += ' <Print> ' + CRLF
		cXML += ' <ValidPrinterInfo/> ' + CRLF
		cXML += ' <PaperSizeIndex>9</PaperSizeIndex> ' + CRLF
		cXML += ' <HorizontalResolution>600</HorizontalResolution> ' + CRLF
		cXML += ' <VerticalResolution>600</VerticalResolution> ' + CRLF
		cXML += ' </Print> ' + CRLF
		cXML += ' <Selected/> ' + CRLF
		cXML += ' <FreezePanes/> ' + CRLF
		cXML += ' <FrozenNoSplit/> ' + CRLF
		cXML += ' <SplitHorizontal>3</SplitHorizontal> ' + CRLF
		cXML += ' <TopRowBottomPane>3</TopRowBottomPane> ' + CRLF
		cXML += ' <SplitVertical>4</SplitVertical> ' + CRLF
		cXML += ' <LeftColumnRightPane>4</LeftColumnRightPane> ' + CRLF
		cXML += ' <ActivePane>0</ActivePane> ' + CRLF
		cXML += ' <Panes> ' + CRLF
		cXML += ' <Pane> ' + CRLF
		cXML += ' <Number>3</Number> ' + CRLF
		cXML += ' </Pane> ' + CRLF
		cXML += ' <Pane> ' + CRLF
		cXML += ' <Number>1</Number> ' + CRLF
		cXML += ' </Pane> ' + CRLF
		cXML += ' <Pane> ' + CRLF
		cXML += ' <Number>2</Number> ' + CRLF
		cXML += ' </Pane> ' + CRLF
		cXML += ' <Pane> ' + CRLF
		cXML += ' <Number>0</Number> ' + CRLF
		cXML += ' </Pane> ' + CRLF
		cXML += ' </Panes> ' + CRLF
		cXML += ' <ProtectObjects>False</ProtectObjects> ' + CRLF
		cXML += ' <ProtectScenarios>False</ProtectScenarios> ' + CRLF
		cXML += ' </WorksheetOptions> ' + CRLF
        cXML += ' </Worksheet>' + CRLF
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""	
		
	EndIf
	
Return nil
