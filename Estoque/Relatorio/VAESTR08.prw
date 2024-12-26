#include "totvs.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"
#INCLUDE "RptDef.ch"
#INCLUDE "FWPrintSetup.ch"

user function VaEstR08()
	local nOpc		:= GD_UPDATE
	local cLinOk	:= "AllwaysTrue"
	local cTudoOk	:= "AllwaysTrue"
	local cIniCpos	:= "B1_COD"
	local nFreeze	:= 000
	local nMax		:= 999
	local cFieldOk	:= "AllwaysTrue"
	local cSuperDel	:= ""
	local cDelOk	:= "AllwaysFalse"
	local cSta		:= ""
	Local nX        := 0
	
	Local aSize		  := {}
	Local aObjects    := {}
	Local aInfo		  := {}
	Local aPObjs      := {}
	Local aButtons	  := {}
	 
	Private aHeadSin := {}
	Private aColsSin := {}
	Private nUsadoSin:= 0
	
	Private aHeadAna := {}
	Private aColsAna := {}
	Private nUsadoAna:= 0
	
	Private oFont    := TFont():New('Trebuchet MS',,-14,,.T.)
	Private oBusca, oSeek, oBtnMrk, oBtnImp
	Private cBusca 	 := space(255)
	
	SetKEY(VK_F5, {|| })
	
	aAdd(aHeadSin,{ " "				, "cStat"      		,"@BMP"         			,1,0,"","","C","","V","","","","V","","",""})
	//aAdd(aHeadSin,{ "Prod.Estoque"	, "B1_X_PRDES"		, X3Picture("B1_X_PRDES")	,TamSX3("B1_X_PRDES")[1]  , 0,"AllwaysTrue()", X3Uso("B1_X_PRDES"), "C", "", "V" } )
	aAdd(aHeadSin,{ "Codigo"		, "B1_COD    "		, X3Picture("B1_COD    ")	,TamSX3("B1_COD    ")[1]  , 0,"AllwaysTrue()", X3Uso("B1_COD    "), "C", "", "V" } )
	aAdd(aHeadSin,{ "Descrição" 	, "B1_DESC   "		, X3Picture("B1_DESC   ")	,TamSX3("B1_DESC   ")[1]-20  , 0,"AllwaysTrue()", X3Uso("B1_DESC   "), "C", "", "V" } )
	aAdd(aHeadSin,{ "Unidade"		, "B1_UM     "		, X3Picture("B1_UM     ")	,TamSX3("B1_UM     ")[1]  , 0,"AllwaysTrue()", X3Uso("B1_UM     "), "C", "", "V" } )
	aAdd(aHeadSin,{ "Armazém"		, "B1_LOCPAD "		, X3Picture("B1_LOCPAD ") 	,TamSX3("B1_LOCPAD ")[1]  , 0,"AllwaysTrue()", X3Uso("B1_LOCPAD "), "C", "", "V" } )
	aAdd(aHeadSin,{ "Grupo"			, "B1_GRUPO  "		, X3Picture("B1_GRUPO  ")	,TamSX3("B1_GRUPO  ")[1]  , 0,"AllwaysTrue()", X3Uso("B1_GRUPO  "), "C", "", "V" } )
	aAdd(aHeadSin,{ "Rua"			, "B1_X_RUA  "		, X3Picture("B1_X_RUA  ")	,TamSX3("B1_X_RUA  ")[1]  , 0,"AllwaysTrue()", X3Uso("B1_X_RUA  "), "C", "", "V" } )
	aAdd(aHeadSin,{ "MOD"			, "B1_X_MODUL"		, X3Picture("B1_X_MODUL")	,TamSX3("B1_X_MODUL")[1]  , 0,"AllwaysTrue()", X3Uso("B1_X_MODUL"), "C", "", "V" } )
	aAdd(aHeadSin,{ "Nivel"			, "B1_X_NIVEL"		, X3Picture("B1_X_NIVEL")	,TamSX3("B1_X_NIVEL")[1]  , 0,"AllwaysTrue()", X3Uso("B1_X_NIVEL"), "C", "", "V" } )
	aAdd(aHeadSin,{ "POS"			, "B1_X_POSIC"		, X3Picture("B1_X_POSIC")	,TamSX3("B1_X_POSIC")[1]  , 0,"AllwaysTrue()", X3Uso("B1_X_POSIC"), "C", "", "V" } )
	nUsadoSin := len(aHeadSin)
	
	beginSQL alias "QRY"
		%noParser%
		select B1_X_PRDES, B1_COD, B1_DESC, B1_UM, B1_LOCPAD, B1_GRUPO, B1_X_RUA, B1_X_MODUL, B1_X_NIVEL, B1_X_POSIC
		  from %table:SB1% sb1
		 where sb1.B1_FILIAL=%xFilial:SB1% and sb1.%notDel%
		   and sb1.B1_X_PRDES='1' and sb1.B1_GRUPO not in ('BOV','01 ','05 ')
		 order by B1_COD
	endSQL
	
	aColsSin	:= {}
	if !QRY->(Eof())
		nUsadoSin := len(aHeadSin)
		
		While !QRY->(eof())
			aAdd(aColsSin,Array(nUsadoSin+1))
			aColsSin[Len(aColsSin),1]:= "LBNO"
			For nX:=2 to nUsadoSin
				aColsSin[Len(aColsSin),nX]:=QRY->( FieldGet(FieldPos(aHeadSin[nX,2])) )
			Next		
			aColsSin[Len(aColsSin),nUsadoSin+1]:=.F.		
			QRY->(dbSkip())
		End
	else
		aAdd(aColsSin,Array(nUsadoSin+1))
		aColsSin[len(aColsSin),nUsadoSin+1] := .F.
	endIf	
	QRY->(dbCloseArea())
	
	aSize := MsAdvSize( .T. )
	AAdd( aObjects, { 100 , 10, .T. , .T. , .F. } )
	AAdd( aObjects, { 100 , 90, .T. , .T. , .F. } )
	//AAdd( aObjects, { 100 , 40, .T. , .T. , .F. } )
	aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
	aPObjs := MsObjSize(aInfo, aObjects, .T., .F.) 
	
	DEFINE MSDIALOG oDlgTmp TITLE OemToAnsi("Impressão de Etiquetas de Estoque") From 0,0 to aSize[6],aSize[5] PIXEL of oMainWnd
		// oDlg:lMaximized := .T.
		
		nPosAux := Round(aPObjs[2,4]/5*4,0)
		oGrp1  := TGroup():New(aPObjs[1,1],aPObjs[1,2],aPObjs[1,3],aPObjs[1,4],"Seleção de Produtos",oDlgTmp,,, .T.,)
		oGrp2a := TGroup():New(aPObjs[2,1],aPObjs[2,2],aPObjs[2,3], nPosAux, "Produtos",oDlgTmp,,, .T.,)
		oGrp2b := TGroup():New(aPObjs[2,1],nPosAux+2,aPObjs[2,3],aPObjs[2,4],"Ações",oDlgTmp,,, .T.,)
		//oGrp3  := TGroup():New(aPObjs[3,1],aPObjs[3,2],aPObjs[3,3],aPObjs[3,4],"Produtos selecionaos",oDlg,,, .T.,)
		
		//oGrp1
		tSay():New(aPObjs[1,1]+12, aPObjs[1,2]+5  ,{||'Procurar:' },oGrp1,,/*oFont*/,,,,.T.,,,200,100)
		@ aPObjs[1,1]+10, aPObjs[1,2]+45  MSGET oBusca  VAR cBusca PICTURE "@!" SIZE 200,010 OF oGrp1 PIXEL
		oSeek	:= TButton():New( aPObjs[1,1]+8, aPObjs[1,2]+45+200+5, "Buscar" ,oGrp1, {|| SeekVal(cBusca) },45,15,,,.F.,.T.,.F.,,.F.,,,.F.)
		
		//oGrp2a
		oGetSin := MsNewGetDados():New( 0, 0, 0, 0, nOpc, cLinOk, cTudoOk, cIniCpos, {}, nFreeze, nMax, cFieldOk, cSuperDel, cDelOk, oGrp2a, aClone(aHeadSin), aClone(aColsSin) )
		oGetSin:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGetSin:oBrowse:BlDblClick := { || If( oGetSin:oBrowse:nColPos == 1 , SetMark(oGetSin, , 1), .T. ) }
		
		//oGrp2b
		oBtnMrk	:= TButton():New( aPObjs[2,1]+7, nPosAux+4, "Marcar/Desmarcar Todos" ,oGrp2b, {|| SetMark(oGetSin, , 1, .T.) },80,16,,,.F.,.T.,.F.,,.F.,,,.F.)
		oBtnImp	:= TButton():New( aPObjs[2,1]+25, nPosAux+4, "Imprimir Etiquetas" ,oGrp2b, {|| Imprimir() },80,16,,,.F.,.T.,.F.,,.F.,,,.F.)
						
		SetKEY(VK_F5, {|| SeekVal(cBusca) })
				
		//AAdd( aButtons, { "AUTOM", { ||  Alert("Impressão de Etiquetas") }, "Imprimir Etiquetas"   } )
		
	ACTIVATE MSDIALOG oDlgTmp ;
	          ON INIT EnchoiceBar(oDlgTmp,;
	                              { || nOpcA := 1, oDlgTmp:End() },;
	                              { || nOpcA := 0, oDlgTmp:End() },, aButtons )
	SetKEY(VK_F5, {|| })
return


Static Function SetMark(oGD, nLinha, nColuna, lAll)
	Local lMark
	Local i
	Local nLen  	:= Len(oGD:aCols)
	Local cMark
	
	Default nLinha  := oGD:nAt
	Default nColuna := 1
	Default lAll	:= .F.
	
	lMark := oGD:aCols[nLinha, nColuna] == 'LBNO'
	cMark := Iif(lMark, 'LBTIK', 'LBNO')
	oGD:aCols[nLinha, nColuna] := cMark
	
	If lAll
		For i := 1 To nLen
			oGD:aCols[i, nColuna] := cMark
		Next
	EndIf
	oGD:Refresh()

Return .T.


Static Function SeekVal(pBusca)
Local nPos  := 0
Local nPosAtuSin := oGetSin:oBrowse:nAt
Local lAchou := .F.
Local nI:= 0
Local nJ:= 0


for nI := nPosAtuSin+1 to len(oGetSin:aCols)
	oGetSin:oBrowse:nAt := nI
	
	for nJ := 1 to len(aHeadSin)-1
		if valtype(pBusca)==valtype(oGetSin:aCols[nI,nJ])
			if at(allTrim(pBusca), oGetSin:aCols[nI,nJ])
				lAchou := .T.
				nI := len(oGetSin:aCols)+1
				nJ := len(aHeadSin)+1
			endIf
		endIf
	next	
next

if !lAchou
	for nI := 1 to len(oGetSin:aCols)
		oGetSin:oBrowse:nAt := nI
		
		for nJ := 1 to len(aHeadSin)-1
			if valtype(pBusca)==valtype(oGetSin:aCols[nI,nJ])
				if at(allTrim(pBusca), oGetSin:aCols[nI,nJ])
					lAchou := .T.
					nI := len(oGetSin:aCols)+1
					nJ := len(aHeadSin)+1
				endIf
			endIf
		next		
	next
endIf

if !lAchou
	oGetSin:oBrowse:nAt := nPosAtuSin
	msgInfo("Nenhuma ocorrência encontrada.")
endIf
oGetSin:oBrowse:Refresh()
ObjectMethod(oDlgTmp,"Refresh()")
Return


static function Imprimir()
Local nI        := 0
Local aProdutos := {}
	for nI := 1 to len(oGetSin:aCols)
		oGetSin:oBrowse:nAt := nI
		
		if oGetSin:aCols[nI, 1]=="LBTIK"
			aAdd(aProdutos, oGetSin:aCols[nI])
		endIf
	next
    
	if len(aProdutos) > 0 
		PreparaImp(aProdutos)
	else
		msgInfo("Nenhum produto selecionado.", "ATENÇÃO")
	endIf
return


Static Function PreparaImp(aProdutos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local tamanho		:= "G"
Local titulo		:= "Impressão de Etiquetas de Produtos"
Local cDesc1		:= "Impressão de Etiquetas de Produtos"
Local cDesc2		:= " "
Local cDesc3		:= " "
Local cTitulo		:= ""
Local cErro			:= ""
Local cSolucao		:= ""                         

Local lPrinter		:= .T.
Local lOk			:= .F.
Local aSays     	:= {}, aButtons := {}, nOpcB := 0

Private nomeprog 	:= "VaEstR08"
Private nLastKey 	:= 0
Private cPerg

Private oPrint

Private aProds := aProdutos

cString := "SB1"
wnrel   := nomeprog
cPerg   := "VAER08"

/*AADD(aSays,cDesc1) 

AADD(aButtons, { 1,.T.,{|| nOpcB := 1, FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| nOpcB := 0, FechaBatch() }} )  

FormBatch( Titulo, aSays, aButtons,, 160 )

If nOpcB == 0
   Return
EndIf*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracoes para impressao grafica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lAdjustToLegacy := .T. 
lDisableSetup  := .T.
oPrint := FWMSPrinter():New("VaEstR08.rel", IMP_SPOOL, lAdjustToLegacy, , lDisableSetup)
// Ordem obrigátoria de configuração do relatório
//oPrint:SetResolution(72)
oPrint:SetPortrait()
oPrint:SetPaperSize(DMPAPER_LETTER)
//oPrint:SetMargin(60,60,60,60)

oPrint := TMSPrinter():New(titulo)		
oPrint:SetPortrait()					// Modo retrato
oPrint:SetPaperSize(1)					// Papel Letter

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracoes para codigo de barras ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFontes := "Arial"//"Courier New"

If nLastKey = 27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| PrintRel(@lEnd,wnRel,cString)},Titulo)

//oPrint:Setup()
//if oPrint:nModalResult == PD_OK
 oPrint:Preview() // Visualiza impressao grafica antes de imprimir
//EndIf

Return

//Função de preparação para a impressão
Static Function PrintRel(lEnd,wnRel,cString)

Local aAreaRPS		:= {}
Local aPrintServ	:= {}
Local aPrintObs		:= {}
                            
Local cTime			:= "" 
Local cLogo			:= ""
Local cAlias		:= "QRYREL"
Local cCampos		:= ""     

Local nValDed		:= 0
Local nCopias		:= 2
Local nX			:= 1
Local nY			:= 1

Local nTamLim		:= 40
Local nLinIni		:= 50  
Local nColIni		:= 100
Local nColFim		:= 1200
Local nLinFim		:= 3250
Local nLinha		:= 0

Local oFont8 	:= TFont():New(aFontes,6,6,,.F.,,,,.T.,.F.)
Local oFont10 	:= TFont():New(aFontes,8,8,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFont10n	:= TFont():New(aFontes,8,8,,.T.,,,,.T.,.F.)	//Negrito
Local oFont11 	:= TFont():New(aFontes,9,9,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFont12	:= TFont():New(aFontes,10,10,,.F.,,,,.T.,.F.)	//Negrito
Local oFont12n	:= TFont():New(aFontes,10,10,,.T.,,,,.T.,.F.)	//Negrito
Local oFont14n	:= TFont():New(aFontes,14,14,,.T.,,,,.T.,.F.)	//Negrito

nLinIni := 50
nRegs := 0
oPrint:StartPage()
	For nX := 1 to len(aProds)
        nRegs++
        if nRegs > 10
			oPrint:EndPage()
			oPrint:StartPage()
			nRegs := 1
		endIf
			
		if nX%2 > 0 .and. nX > 1
			nLinIni := 50+(635*(((nX%10)/2)-0.5))
		endIf
		
		nLinha := nLinIni+nTamLim
		
		nColIni	:= 110+(1340*(nX%2))
		nColFim	:= 1200+(1340*(nX%2))
		
		//oPrint:Line(nLinha,nColIni,nLinha,nColFim)
		//oPrint:Line(nLinha,nColIni,nLinha+nTamLim*14,nColIni)
		//oPrint:Line(nLinha,nColFim,nLinha+nTamLim*14,nColFim)
		//oPrint:Line(nLinha+nTamLim*14,nColIni,nLinha+nTamLim*14,nColFim)
		
		nLinha+=nTamLim
		oPrint:Say(nLinha+=nTamLim,nColIni+10, aProds[nX,aScan(aHeadSin, {|x| x[2]="B1_COD" })] ,oFont14n)
		cProdImp := AllTrim(aProds[nX,aScan(aHeadSin, {|x| x[2]="B1_DESC" })])
		if len(cProdImp) <= 30
			oPrint:Say(nLinha,nColIni+200,cProdImp,oFont12n)
		else
			oPrint:Say(nLinha,nColIni+200,left(cProdImp,35),oFont12n)
			oPrint:Say(nLinha+nTamLim,nColIni+200,substr(cProdImp,36),oFont12n)
		endIf
		
		nLinha+=nTamLim*2
		oPrint:Say(nLinha+=nTamLim,nColIni+10,"Unidade: "+aProds[nX,aScan(aHeadSin, {|x| x[2]="B1_UM" })],oFont12)
		oPrint:Say(nLinha,nColIni+400,"Armazém: "+aProds[nX,aScan(aHeadSin, {|x| x[2]="B1_LOCPAD" })],oFont12)
		
		nLinha+=nTamLim
		oPrint:Say(nLinha+=nTamLim,nColIni+10,"RUA: "+aProds[nX,aScan(aHeadSin, {|x| x[2]="B1_X_RUA" })],oFont12)
		oPrint:Say(nLinha,nColIni+200,"MOD: "+aProds[nX,aScan(aHeadSin, {|x| x[2]="B1_X_MODUL" })],oFont12)
		oPrint:Say(nLinha,nColIni+400,"NVL: "+aProds[nX,aScan(aHeadSin, {|x| x[2]="B1_X_NIVEL" })],oFont12)
		oPrint:Say(nLinha,nColIni+600,"POS: "+aProds[nX,aScan(aHeadSin, {|x| x[2]="B1_X_POSIC" })],oFont12)
		
		nLinha += nTamLim*2
		//MSBAR4('INT25',nLinha,nColIni+300,aProds[nX,aScan(aHeadSin, {|x| x[2]="B1_COD" })],oPrint,.F.,,.T.,0.028,2.2,.F.,,'INT25',.F.)
		//oPrint:FwMsBar("INT25" /*cTypeBar*/,nLinha/*nRow*/ ,nColIni+300/*nCol*/, aProds[nX,aScan(aHeadSin, {|x| x[2]="B1_COD" })]/*cCode*/,oPrint/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.02/*nWidth*/,0.8/*nHeigth*/,.T./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
		//aPosX := {12.4, 1.1, 12.4, 1.1, 12.4, 1.1, 12.4, 1.1, 12.4, 1.1}
		aPosX := {13.8, 2.4, 13.8, 2.4, 13.8, 2.4, 13.8, 2.4, 13.8, 2.4}
		aPosY := {3.8, 3.8, 9, 9, 14.3, 14.3, 19.85, 19.85, 25.1, 25.1}
		MSBAR4('INT25', aPosY[nRegs], aPosX[nRegs], AllTrim(aProds[nX,aScan(aHeadSin, {|x| x[2]="B1_COD" })]), oPrint, .F.,, .T., 4, 0.8,,,,.F.)
	Next
	
	oPrint:EndPage()

return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GeraSX1  ºAutor  ³Microsiga           º Data ³  04/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Gera perguntas "Parametros"                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GeraSX1()
	Local aArea 	:= GetArea()
	Local i	  		:= 0
	Local j     	:= 0
	Local lInclui	:= .F.
	Local aHelpPor	:= {}
	Local aHelpSpa	:= {}
	Local aHelpEng	:= {}
	Local cTexto    := ''
	
	aRegs := {}

	AADD(aRegs,{cPerg,"01","Emissão?                  ","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","      ","N","","",""})
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 To Len(aRegs)
	 If lInclui := !dbSeek(cPerg + aRegs[i,2])
		 RecLock("SX1", lInclui)
		  For j := 1 to FCount()
		   If j <= Len(aRegs[i])
		    FieldPut(j,aRegs[i,j])
		   Endif
		  Next
		 MsUnlock()
		EndIf

		aHelpPor := {}; aHelpSpa := {}; aHelpEng := {}
		
		if i==1
			AADD(aHelpPor,"Data de emissao das vendas ")
			AADD(aHelpPor,"de cartao. ")
		endIf
		PutSX1Help("P."+AllTrim(cPerg)+strzero(i,2)+".",aHelpPor,aHelpEng,aHelpSpa)

	Next
	
	RestArea(aArea)
Return('SX1: ' + cTexto  + CHR(13) + CHR(10))
