#INCLUDE "protheus.ch" 
#INCLUDE "TOTVS.CH"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± ∫Programa: Classe ARSexcel  								 																	   										Data:   09/04/2014  ±±
±± ∫Autor: Artur Antunes Rainha Da Silveira                                                                                                            										±±
±± ∫Obs: FunÁ„o de exemplo no final do arquivo																										    									±±
±± ∫Email: silveiraartur@gmail.com																										    												±±
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Class ARSexcel 

	Data cIniXML   
	Data cFimXML   
	Data cIniPlan  
	Data cFimPlan  
	Data cIniLin   
	Data cFimLin   
	Data lJob		
	Data aPlanilha 
	Data aLinha    
	Data aCelula    
	Data aStyle    

	Method New(lJob) Constructor
	Method AddPlanilha(cTitulo,aColuna,nLinCong) 
	Method AddLinha(nAltura) 
	Method AddCelula(qConteudo,nDecimal,cAlinhamento,cFonte,nFonTam,cFonteCor,lNegrito,lItalico,cInterCor,lTopBor,lLeftBor,lBottomBor,lRightBor,lMescla,nIniMescla,nFimMescla,cFormNum,cAlinVert,lWrapText)  
	Method SaltaCelula(nSalta)
	Method SaveXml(cDestino,cNomeArq,lConvXlsx)

EndClass  
   
 

Method New(lJobAt) Class ARSexcel

local cDtXml := SubStr(DTOS(Date()),1,4) + "-" + SubStr(DTOS(Date()),5,2) + "-" + SubStr(DTOS(Date()),7,2)	  
Default lJobAt := .F.

	::cIniXML := '<?xml version="1.0"?>'+CRLF;
				+'<?mso-application progid="Excel.Sheet"?>'+CRLF;
				+'<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'+CRLF;
				+' xmlns:o="urn:schemas-microsoft-com:office:office"'+CRLF;
				+' xmlns:x="urn:schemas-microsoft-com:office:excel"'+CRLF;
				+' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'+CRLF;
				+' xmlns:html="http://www.w3.org/TR/REC-html40">'+CRLF;
				+' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'+CRLF;
				+'  <Author>'+AllTrim(UsrFullName(__cUserId))+'</Author>'+CRLF;
				+'  <LastAuthor>'+AllTrim(UsrFullName(__cUserId))+'</LastAuthor>'+CRLF;
				+'  <Created>'+cDtXml+'T'+Time()+'Z</Created>'+CRLF;
				+'  <LastSaved>'+cDtXml+'T'+Time()+'T'+Time()+'Z</LastSaved>'+CRLF;
				+'  <Company>Microsoft</Company>'+CRLF;
				+'  <Version>14.00</Version>'+CRLF;
				+' </DocumentProperties>'+CRLF;
				+' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">'+CRLF;
				+'  <AllowPNG/>'+CRLF;
				+' </OfficeDocumentSettings>'+CRLF;
				+' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF;
				+'  <WindowHeight>7995</WindowHeight>'+CRLF;
				+'  <WindowWidth>20115</WindowWidth>'+CRLF;
				+'  <WindowTopX>240</WindowTopX>'+CRLF;
				+'  <WindowTopY>150</WindowTopY>'+CRLF;
				+'  <ProtectStructure>False</ProtectStructure>'+CRLF;
				+'  <ProtectWindows>False</ProtectWindows>'+CRLF;
				+' </ExcelWorkbook>'+CRLF 

	::cFimXML := '</Workbook>'+CRLF 
	
	::lJob 		 := lJobAt
	::aLinha  	 := {}
	::aPlanilha  := {}
	::aStyle  	 := {}
	::aCelula 	 := {}	
	
Return

        

Method AddPlanilha(cTitulo,aColuna,nLinCong) Class ARSexcel
Local nx 		 := 0
Default aColuna  := {50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50}
Default nLinCong := 0

if !empty(::aCelula) 
    if empty(::cIniLin) .and. empty(::cFimLin) 
		::cIniLin  := '   <Row ss:AutoFitHeight="0" ss:Height="15">'+CRLF
		::cFimLin  := '   </Row>'+CRLF
    endif
	AADD(::aLinha,{ {::cIniLin,::cFimLin},::aCelula } ) 
	::aCelula := {}
	::cIniLin := ""
	::cFimLin := ""
endif

if !empty(::aLinha) 
	AADD(::aPlanilha,{ {::cIniPlan,::cFimPlan},::aLinha } ) 
	::aLinha := {}
endif

Default cTitulo := 'Plan'+cvaltochar(len(::aPlanilha)+1)
::cIniLin  := ''
::cFimLin  := ''

::cIniPlan  := ' <Worksheet ss:Name="'+cTitulo+'">'+CRLF;
   			  +'  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="12">'+CRLF   
   			  
for nx:= 1 to len(aColuna)
	::cIniPlan  +='   <Column ss:AutoFitWidth="0" ss:Width="'+cvaltochar(aColuna[nx])+'"/>'+CRLF
next nx	  
		   
::cFimPlan  := '  </Table>'+CRLF
::cFimPlan  += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
::cFimPlan  += '   <PageSetup>'+CRLF
::cFimPlan  += '    <Header x:Margin="0.31496062000000002"/>'+CRLF
::cFimPlan  += '    <Footer x:Margin="0.31496062000000002"/>'+CRLF
::cFimPlan  += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"'+CRLF
::cFimPlan  += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>'+CRLF
::cFimPlan  += '   </PageSetup>'+CRLF

if nLinCong > 0
   ::cFimPlan  += '   <Unsynced/>'+CRLF
   ::cFimPlan  += '   <Selected/>'+CRLF
   ::cFimPlan  += '   <FreezePanes/>'+CRLF
   ::cFimPlan  += '   <FrozenNoSplit/>'+CRLF
   ::cFimPlan  += '   <SplitHorizontal>'+Alltrim(Str(nLinCong))+'</SplitHorizontal>'+CRLF
   ::cFimPlan  += '   <TopRowBottomPane>'+Alltrim(Str(nLinCong))+'</TopRowBottomPane>'+CRLF
   ::cFimPlan  += '   <ActivePane>2</ActivePane>'+CRLF
endif

::cFimPlan  += '   <ProtectObjects>False</ProtectObjects>'+CRLF
::cFimPlan  += '   <ProtectScenarios>False</ProtectScenarios>'+CRLF
::cFimPlan  += '  </WorksheetOptions>'+CRLF
::cFimPlan  += ' </Worksheet>'+CRLF

return 



Method AddLinha(nAltura) Class ARSexcel

Default nAltura := 15  

if !empty(::aCelula) .or. !empty(::cIniLin) 
    if empty(::cIniLin) .and. empty(::cFimLin) 
		::cIniLin  := '   <Row ss:AutoFitHeight="0" ss:Height="15">'+CRLF
		::cFimLin  := '   </Row>'+CRLF
    endif
	AADD(::aLinha,{ {::cIniLin,::cFimLin},::aCelula } ) 
	::cIniLin  := ''
	::cFimLin  := ''
	::aCelula := {}
endif

::cIniLin  := '   <Row ss:AutoFitHeight="0" ss:Height="'+cvaltochar(nAltura)+'">'+CRLF
::cFimLin  := '   </Row>'+CRLF

return
 
      

Method AddCelula(qConteudo,nDecimal,cAlinhamento,cFonte,nFonTam,cFonteCor,lNegrito,lItalico,cInterCor,lTopBor,lLeftBor,lBottomBor,lRightBor,lMescla,nIniMescla,nFimMescla,cFormNum,cAlinVert,lWrapText) Class ARSexcel 

local nStyle		:= 0 
local cStyle		:= ''  
local cType			:= ''  
local cCelula		:= ''
Default	qConteudo	:= nil
Default nDecimal	:= 0 
Default cAlinhamento:= 'L' 
Default cFonte 		:= 'Arial'
Default nFonTam		:= 8
Default	cFonteCor	:= '000000'
Default lNegrito	:= .F.
Default lItalico	:= .F.
Default	cInterCor	:= ''
Default lTopBor		:= .F.
Default lLeftBor	:= .F.
Default lBottomBor	:= .F. 
Default lRightBor	:= .F.
Default lMescla		:= .F.
Default nIniMescla	:= 0
Default nFimMescla  := 0 
Default cFormNum    := ''
Default cAlinVert   := 'B' 
Default lWrapText   := .f.

Do case
	case upper(cAlinhamento) == 'R' 
		cAlinhamento := 'Right'
	case upper(cAlinhamento) == 'C' 
		cAlinhamento := 'Center'
    Otherwise
    	cAlinhamento := 'Left'
Endcase

Do case
	case upper(cAlinVert) == 'T' 
		cAlinVert := 'Top'
	case upper(cAlinVert) == 'C' 
		cAlinVert := 'Center'
    Otherwise
    	cAlinVert := 'Bottom'
Endcase

cType := valtype(qConteudo)
if cType = 'N'
	qConteudo := alltrim( StrTran( str( qConteudo ),",","." ) )   
endif 

cFonteCor := StrTran(cFonteCor,'#','')
cInterCor := StrTran(cInterCor,'#','') 

//Adiciona estiloc					
if (nStyle := ASCANX(::aStyle, {|x| cvaltochar(nDecimal) + cAlinhamento + cFonte + cvaltochar(nFonTam) + cFonteCor + cvaltochar(lNegrito) + cvaltochar(lItalico);
									+ cInterCor + cvaltochar(lTopBor) + cvaltochar(lLeftBor) + cvaltochar(lBottomBor) + cvaltochar(lRightBor);
									+ cvaltochar(lMescla) + cvaltochar(nIniMescla) + cvaltochar(nFimMescla) + cFormNum + cAlinVert + cvaltochar(lWrapText) + cType;
							    ==  cvaltochar(x[1]) + x[2] + x[3] + cvaltochar(x[4]) + x[5] + cvaltochar(x[6]) + cvaltochar(x[7]) ;
							        + x[8] + cvaltochar(x[9]) + cvaltochar(x[10]) + cvaltochar(x[11]) + cvaltochar(x[12]) + cvaltochar(x[13]);
							        + cvaltochar(x[14]) + cvaltochar(x[15]) + x[16] + x[17] + cvaltochar(x[18]) + x[19]   } ) ) == 0 
							    
    nStyle  := iif(len(::aStyle)>0,len(::aStyle)+1,1)
    cStyle	:= 	   '	<Style ss:ID="s'+strzero(nStyle,3)+'">'+CRLF
    
    cStyle	+=	   '     <Alignment ss:Horizontal="'+cAlinhamento+'" ss:Vertical="'+cAlinVert+'" '+ iif(lWrapText,'ss:WrapText="1" ','') +'/>'+CRLF
	
	if lTopBor .or. lLeftBor .or. lBottomBor .or. lRightBor
		cStyle	+= '     <Borders>'+CRLF
		if lBottomBor
			cStyle	+= '      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
		endif
		if lLeftBor 
			cStyle	+= '      <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
		endif
		if lRightBor
			cStyle	+= '      <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
		endif
		if lTopBor	
			cStyle	+= '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
		endif
		cStyle	+= '     </Borders>'+CRLF
	endif	
    
	cStyle	+= 	   '     <Font ss:FontName="'+cFonte+'" x:Family="Swiss" ss:Size="'+cvaltochar(nFonTam)+'" ss:Color="#'+cFonteCor+'" '+iif(lNegrito,'ss:Bold="1"','')+' '+iif(lItalico,'ss:Italic="1"','')+' />'+CRLF
	if !empty(cInterCor) 
		cStyle	+= '     <Interior ss:Color="#'+cInterCor+'" ss:Pattern="Solid"/>'+CRLF
	endif
	
	Do case
		case cType == 'N'  
			cStyle	+= '     <NumberFormat ss:Format="#,##0'
			if nDecimal > 0 
				cStyle	+= '.'+strzero(0,nDecimal)  
			endif
			if !empty(cFormNum) .and. ValType(cFormNum) == 'C'    
				if upper(cFormNum) == 'P' 
			    	cStyle	+= '%'
			    endif	
			endif	
			cStyle	+= '"/>'+CRLF
   		case cType == 'D'  	
	        cStyle	+= '     <NumberFormat ss:Format="Short Date"/>'+CRLF  
   		case cType == 'C'  	
	        cStyle	+= '     <NumberFormat ss:Format="@"/>'+CRLF
	    Otherwise
	        cStyle	+= '     <NumberFormat/>'+CRLF
	Endcase
	
	cStyle	+= 	   '	</Style>'+CRLF 

	AADD(::aStyle,{nDecimal,cAlinhamento,cFonte,nFonTam,cFonteCor,lNegrito,lItalico,cInterCor,lTopBor,lLeftBor,lBottomBor,lRightBor,lMescla,nIniMescla,nFimMescla,cFormNum,cAlinVert,lWrapText,cType,cStyle})
endif	

//adiciona celula
Do Case    
	case Empty(qConteudo)
		cCelula	+=	'    <Cell '+iif(lMescla,' ss:MergeAcross="'+Alltrim(str(nFimMescla))+'"','')+' ss:StyleID="s'+strzero(nStyle,3)+'"/>'+CRLF	
	Case cType == 'N' 
		cCelula	+=	'    <Cell '+iif(lMescla,' ss:MergeAcross="'+Alltrim(str(nFimMescla))+'"','')+' ss:StyleID="s'+strzero(nStyle,3)+'"><Data ss:Type="Number">'+qConteudo+'</Data></Cell>'+CRLF	
	Case cType == "D" 
		cCelula	+=	'    <Cell '+iif(lMescla,' ss:MergeAcross="'+Alltrim(str(nFimMescla))+'"','')+' ss:StyleID="s'+strzero(nStyle,3)+'"><Data ss:Type="DateTime">'+fXmlData(qConteudo)+'</Data></Cell>'+CRLF
	Otherwise
		cCelula	+=	'    <Cell '+iif(lMescla,' ss:MergeAcross="'+Alltrim(str(nFimMescla))+'"','')+' ss:StyleID="s'+strzero(nStyle,3)+'"><Data ss:Type="String">'+fTxtXML(qConteudo)+'</Data></Cell>'+CRLF								
End Case

AADD( ::aCelula, cCelula )
       	
return    
 


Method SaltaCelula(nSalta) Class ARSexcel 
local nr       := 0
Default nSalta := 1 

if ValType(nSalta) <> "N"
	nSalta := 1
endif

if nSalta > 0
	for nr:=1 to nSalta
		::AddCelula()
	next nr	
endif 
return



Method SaveXml(cDestino,cNomeArq,lConvXlsx) Class ARSexcel  

private lEnd		:= .F.
private cArqDest 	:= ''
Default cDestino	:= AllTrim(GetTempPath()) 
Default cNomeArq	:= DTOS(Date())+StrTran(Time(),":","")  
Default lConvXlsx	:= .F.
cNomeArq += ".xml" 

if !empty(::aCelula) 
    if empty(::cIniLin) .and. empty(::cFimLin) 
		::cIniLin  := '   <Row ss:AutoFitHeight="0" ss:Height="15">'+CRLF
		::cFimLin  := '   </Row>'+CRLF
    endif
	AADD(::aLinha,{ {::cIniLin,::cFimLin},::aCelula } ) 
	::aCelula := {}
	::cIniLin := ""
	::cFimLin := ""
endif

if !empty(::aLinha) 
	AADD(::aPlanilha,{ {::cIniPlan,::cFimPlan},::aLinha } ) 
	::aLinha := {}    
	::cIniPlan := ""
	::cFimPlan := ""
endif  

if ::lJob
	GeraXML(cDestino+cNomeArq,::aStyle,::aPlanilha,::cIniXML,::cFimXML,lEnd,.T.,lConvXlsx) 
   	if !file(cArqDest) .and. !file(cDestino+cNomeArq)
		Conout("Erro ao criar o arquvio. Favor verificar a configura?o de acesso ao diretorio selecionado.")   	
   	endif
else
    Processa({ |lEnd| GeraXML(cDestino+cNomeArq,::aStyle,::aPlanilha,::cIniXML,::cFimXML,@lEnd,.F.,lConvXlsx) },"Aguarde...","Montando Planilha",.T.)
   	if file(cArqDest)
		If ApOleClient("MsExcel")
			oExcelApp := MsExcel():New() 
			oExcelApp:SetVisible(.T.)
			oExcelApp:WorkBooks:Open(cArqDest) 
			oExcelApp:Destroy() 
		endif
	elseif file(cDestino+cNomeArq)
		If ApOleClient("MsExcel")
			oExcelApp := MsExcel():New() 
			oExcelApp:SetVisible(.T.)
			oExcelApp:WorkBooks:Open(cDestino+cNomeArq) 
			oExcelApp:Destroy() 
		else
			ShellExecute("open", Alltrim(cNomeArq), "", Alltrim(cDestino), 1)
		endif
	else 
		MsgAlert("Erro ao criar o arquvio. Favor verificar a configura?o de acesso ao diretorio selecionado.","Atencao!")
	endif	
endif

return    



Static Function fXmlData(dDtInfo)
Local cNovo     := ""
DEFAULT dDtInfo := stod("")
if ValType(dDtInfo)=="D"
	cNovo := dtos(dDtInfo)
	cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7,2)+"T00:00:00.000"
endif
Return(cNovo)



//Tratamento para texto
Static Function fTxtXML(cString)
Local cByte     := ""
local ni        := 0
Local s1		:= "·ÈÌÛ˙" + "¡…Õ”⁄" + "‚ÍÓÙ˚" + "¬ Œ‘€" + "‰ÎÔˆ¸" + "ƒÀœ÷‹" + "‡ËÏÚ˘" + "¿»Ã“Ÿ"  + "„ı√’" + "Á«ø" + "™∫∞<>&*'" + '"'
Local s2		:= "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU"  + "aoAO" + "cCC" + "        " + " "
Local nPos   	:= 0
Local cMaiorMin := "&lt;"
Local cMenorMin := "&gt;"  
Local cMaiorMai := "&LT;"
Local cMenorMai := "&GT;"
Local cRet   	:= ""
local nByte 
default cString := "" 

if "¬∞" $ cString
	return cString
endif	

If cMaiorMin $ cString .or. cMenorMin $ cString .or. cMaiorMai $ cString .or. cMenorMai $ cString 
	cString := strTran( cString, cMaiorMin, " " ) 
	cString := strTran( cString, cMenorMin, " " ) 
	cString := strTran( cString, cMaiorMai, " " ) 
	cString := strTran( cString, cMenorMai, " " )
EndIf

For ni := 1 To Len(cString)
	cByte := Substr(cString,ni,1)
 	nByte := ASC(cByte)
  	nPos  := At(cByte,s1)
   	If nPos > 0
    	cByte := Substr(s2,nPos,1)
    EndIf
    cRet += cByte
Next 
 
Return(AllTrim(cRet))



Static function GeraXML(cNomeArq,aStyle,aPlanilha,cIniXML,cFimXML,lEnd,lJob,lConvXlsx) 

local aAreaXml	 := GetArea() 
local nHandle    := fCreate(cNomeArq) 
local nTotItens	 := 0 
local nContItens := 0 
local cTempTxt	 := ""  
local nLimitCarc := 1000000
local nC		 := 0 
Local nL		 := 0
Local nP		 := 0
Local nV		 := 0
Local nCont		 := 0

ProcRegua(0)

If nHandle == -1 
	if lJob
	    ConOut("Aten?o","Erro ao criar o arquvio " + cNomeArq + ". Favor verificar a configura?o do micro.")
	else 
		MsgAlert("Aten?o","Erro ao criar o arquvio " + cNomeArq + ". Favor verificar a configura?o do micro.","Atencao!")
	endif
	RestArea(aAreaXml)
	Return
EndIf 

//FWrite(nHandle,cIniXML)
cTempTxt += cIniXML 
cTempTxt += '<Styles>'+CRLF 
cTempTxt += '	<Style ss:ID="Default" ss:Name="Normal">'+CRLF  
cTempTxt += '	 <Alignment ss:Vertical="Bottom"/>'+CRLF
cTempTxt += '	 <Borders/>'+CRLF
cTempTxt += '	 <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
cTempTxt += '	 <Interior/>'+CRLF
cTempTxt += '	 <NumberFormat/>'+CRLF
cTempTxt += '	 <Protection/>'+CRLF
cTempTxt += '	</Style>'+CRLF
FWrite(nHandle,cTempTxt)
cTempTxt := ""

if !lJob //conta registros
	nTotItens := len(aStyle)
	for nCont:=1 to len(aPlanilha) 
		nTotItens += len(aPlanilha[nCont,2]) 
    next nCont
endif 
nTotItens++              
ProcRegua(nTotItens)
 
//Estilos
for nv:=1 to len(aStyle)
    if (len(cTempTxt)+len(aStyle[nv,20])) > nLimitCarc
      	FWrite(nHandle,cTempTxt)
      	cTempTxt := ""
    endif 
	cTempTxt += aStyle[nv,20]
	if !lJob
		nContItens++  	
		IncProc("Montando Planilha...  - Status: " + IIF((nContItens/nTotItens)*100 <= 99, StrZero((nContItens/nTotItens)*100,2), STRZERO(99,2)) + "%")	
	endif      
next nv	
cTempTxt += '</Styles>'+CRLF
FWrite(nHandle,cTempTxt) 
cTempTxt := ""

//sheet
for nP:=1 to len(aPlanilha)

	if lEnd 
		Exit
	endif
	
	cTempTxt += aPlanilha[nP,1,1] //Inicio da planilha 
    
	for nL:=1 to len(aPlanilha[nP,2]) //adiciona linhas 
	
		if lEnd 
			Exit
		endif
		
        if (len(cTempTxt)+len(aPlanilha[nP,2,nL,1,1])) > nLimitCarc
            FWrite(nHandle,cTempTxt)
            cTempTxt := ""
        endif
        cTempTxt += aPlanilha[nP,2,nL,1,1] //Inicio da linha
        
		for nC:=1 to len(aPlanilha[nP,2,nL,2]) //adiciona celulas
			
  	        if (len(cTempTxt)+len(aPlanilha[nP,2,nL,2,nC])) > nLimitCarc
            	FWrite(nHandle,cTempTxt)
            	cTempTxt := ""
            endif 
			cTempTxt += aPlanilha[nP,2,nL,2,nC] 
			
		next nC
        
        if (len(cTempTxt)+len(aPlanilha[nP,2,nL,1,2])) > nLimitCarc
            FWrite(nHandle,cTempTxt)
            cTempTxt := ""
        endif  
        cTempTxt += aPlanilha[nP,2,nL,1,2] //Fim da linha

		if !lJob
			nContItens++  	
			IncProc("Montando Planilha...  - Status: " + IIF((nContItens/nTotItens)*100 <= 99, StrZero((nContItens/nTotItens)*100,2), STRZERO(99,2)) + "%")	
		endif
    next nL

    if (len(cTempTxt)+len(aPlanilha[nP,1,2])) > nLimitCarc
        FWrite(nHandle,cTempTxt)
        cTempTxt := ""
    endif  
	cTempTxt += aPlanilha[nP,1,2] //Fim da planilha

	FWrite(nHandle,cTempTxt)
	cTempTxt := ""

next nP
FWrite(nHandle,cFimXML) 
fClose(nHandle) 

if lEnd .and. file(cNomeArq)
	if lJob
	    ConOut("Relatorio Cancelado pelo usuario")
	else 
		MsgAlert("Relatorio Cancelado pelo usuario","Atencao!")
	endif
	FErase(cNomeArq) 
endif   
      
if file(cNomeArq)
	if lConvXlsx      
		if lJob
			ConvertXlsx(cNomeArq,lJob)
		else
		   	Processa({ || ConvertXlsx(cNomeArq,lJob)},"Gerando arquivo, aguarde...","Planilha Excel") 
		endif		   	
	endif    
endif		

if !lJob
	nContItens++  	
	IncProc("Montando Planilha...  - Status: " + IIF((nContItens/nTotItens)*100 <= 99, StrZero((nContItens/nTotItens)*100,2), STRZERO(100,3)) + "%")	
endif 

RestArea(aAreaXml)
return     



static Function ConvertXlsx(cArqOri,lJob)
Local nHandler 
Local cVbs 		:= ''
Local cDrive 	:= ''
Local cDir   	:= ''
Local cNome  	:= ''
Local cExt   	:= '' 
local cArqVbs 	:= '' 
local lContinua := .F.    
if !lJob
	ProcRegua(0) 
endif	
if !empty(cArqOri) .and. ApOleClient('MsExcel') 
	lContinua := .T.
	SplitPath(cArqOri,@cDrive,@cDir,@cNome,@cExt)
	cArqDest := cDrive+cDir+cNome+".xlsx"
	cArqVbs := AllTrim(GetTempPath())+GetNextAlias()+ALLTrim( DTOS(DATE())+StrTran( time(),':',''))+".vbs"
endif
cVbs := 'Dim objXLApp, objXLWb '+CRLF
cVbs += 'Set objXLApp = CreateObject("Excel.Application") '+CRLF
cVbs += 'objXLApp.Visible = False '+CRLF
cVbs += 'Set objXLWb = objXLApp.Workbooks.Open("'+cArqOri+'") '+CRLF
cVbs += 'objXLWb.SaveAs "'+cArqDest+'", 51 '+CRLF
cVbs += 'objXLWb.Close (true) '+CRLF
cVbs += 'Set objXLWb = Nothing '+CRLF
cVbs += 'objXLApp.Quit '+CRLF
cVbs += 'Set objXLApp = Nothing '+CRLF
if lContinua
	nHandler := FCreate(cArqVbs)
	If nHandler <> -1 
		FWrite(nHandler, cVbs)
		FClose(nHandler)                                   
		if WaitRun('cscript.exe '+cArqVbs,0) == 0 
			if file(cArqDest)
				if file(cArqOri)
					FErase(cArqOri)
				endif
				if file(cArqVbs)
					FErase(cArqVbs)
				endif
			else
		    	lContinua := .F.
		    endif
		else
		   	lContinua := .F.
		endif
	else
	   	lContinua := .F.	  	 
	endif
endif 
if !lContinua
	if file(cArqDest)
		FErase(cArqDest)
	endif
	if file(cArqVbs)
		FErase(cArqVbs)
	endif
endif
Return              

