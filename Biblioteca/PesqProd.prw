#INCLUDE "PROTHEUS.CH"           
#INCLUDE "TOPCONN.CH"     
#INCLUDE "FONT.CH"                                    
#INCLUDE "RWMAKE.CH"
#DEFINE GD_NOME     1
#DEFINE GD_CONTEUDO 2

User Function PesqProd()
	Private lRet           := .F.

	Private cQuery1 := ""
	Private cFiltro := ""
	Private cOrdem  := " ORDER BY SB1.B1_COD"	
	
	Private oPrinc
	Private aColsPri     := {{nil,nil,nil,nil,nil,nil,nil,nil}}
	Private aFields      := {} //Campos que aparecerão na grid principal

	Private oDlg   
	     
	If FunName() = "U_XMLNFE"
		Private cTxtBusca := Iif(ValType(cPRDPesq)<>"C", Space(30),Substr(cPRDPesq+Space(30),1,30)) //	PRDPesq // variavel publica
	Else    
		Private cTxtBusca := Space(30)
	EndIf

	Private cTxtAplic := Space(30)
	Private cCmbInd  := "Descrição"
  
	cQuery1 := "SELECT  TOP 50  SB1.B1_COD, SB1.B1_CODBAR, SB1.B1_DESC, SB1.B1_GRUPO, BM_DESC, SB1.B1_UM "
	cQuery1 += " FROM " + RetSqlName("SB1") + " SB1 LEFT JOIN " + RetSqlName("SBM") + " SBM ON B1_GRUPO=BM_GRUPO AND SB1.D_E_L_E_T_='' AND SBM.D_E_L_E_T_='' "
	cQuery1 += " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_<> '*' "

	
	AADD(aFields, {"Codigo"		, "_QRY1->B1_COD"    		   })
	AADD(aFields, {"Cod. Barras", "_QRY1->B1_CODBAR"   		   })
	AADD(aFields, {"Descricao"	, "_QRY1->B1_DESC"   		   })
	AADD(aFields, {"Grupo/Marca", "_QRY1->BM_DESC"	           })	
	AADD(aFields, {"UM"			, "_QRY1->B1_UM"   		       })
	AADD(aFields, {"Estoque"	, "RetEst(_QRY1->B1_COD)"      })	
	AADD(aFields, {"Preço"		, "RetPreco(_QRY1->B1_COD)"    })

	DEFINE MSDIALOG oDlg TITLE "Pesquisa - Produtos" FROM 000, 000  TO 555, 947 COLORS 0, 16777215 PIXEL

	    @ 004, 005 MSCOMBOBOX oCmbInd VAR cCmbInd		 ITEMS {"Código","Descrição","Cód. Barras","Grupo/Marca"} SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 004, 065 MSGET oTxtBusca VAR cTxtBusca		 SIZE 170, 010 OF oDlg COLORS 0,16777215 PIXEL //Valid(Filtro(3))

	    @ 004, 210 BUTTON oBtnPesq PROMPT "Filtrar"		 SIZE 040, 012 OF oDlg PIXEL ACTION Processa({|| Filtro(1) }, "Aguarde...") 

	    @ 004, 250 BUTTON oBtnLimp PROMPT "&Limpar (F4)"	 SIZE 040, 012 OF oDlg PIXEL ACTION Limpar(1)	    
		SetKey( VK_F4, {|| Limpar(1)} ) //Atilio, colocando a opção de limpar F4, 11/09/14

    	@ 004, 290 BUTTON oButton1 PROMPT "Sel. Produto" SIZE 040, 012 OF oDlg ACTION (SetRetor(1), lRet := .T.) PIXEL

    	@ 004, 330 BUTTON oButton7 PROMPT "Imagem" SIZE 040, 012 OF oDlg ACTION (fMosImagem(), lRet := .T.) PIXEL
		//SetKey( VK_F5, {|| fMosImagem()} )
 
    	@ 004, 370 BUTTON oButton8 PROMPT "Saldos" SIZE 040, 012 OF oDlg ACTION (fMosSaldos(), lRet := .T.) PIXEL
		//SetKey( VK_F6, {|| fMosSaldos()} )

    	@ 004, 410 BUTTON oButton3 PROMPT "Sair" 		 SIZE 040, 012 OF oDlg ACTION (oDlg:End(), lRet := .F.) PIXEL    	

  		@ 020, 003 SCROLLBOX oScrollB1 HORIZONTAL VERTICAL SIZE 250, 468 OF oDlg BORDER
	    GridPrin()                                                                     

		Filtro(1) //Atilio, já trazendo os dados filtrados, 11/09/2014
		oTxtBusca:SetFocus() //Atilio, já deixando o foco no get a pedido do Jonas, 23/10/2014
	ACTIVATE MSDIALOG oDlg CENTERED
	SetKey( VK_F4, Nil ) //Atilio, limpando a opção de limpar F4, 11/09/14
Return lRet
                                                                                        
Static Function SetRetor(nOpRet)
If (nOpRet = 1 .and. aColsPri[oPrinc:nAt][GD_NOME] <> nil)
   
	If nOpRet = 1 
		cProd	:= aColsPri[oPrinc:nAt][GD_NOME]	  
	Endif
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+cProd)

	oDlg:End()     
Else
	cProd := ""
	Alert("Nao há registros filtrados para seleção!")	
Endif

Return

/* Montagem da grid principal */
Static Function GridPrin()
	Local aAux    := {}
	Local aCab    := {}
	Local nx      := 0
		
	AADD(aFields, {"Codigo"		, "_QRY1->B1_COD"    		  })
	AADD(aFields, {"Cod. Barras", "_QRY1->B1_CODBAR"   		  })
	AADD(aFields, {"Descricao"	, "_QRY1->B1_DESC"   		  })
	AADD(aFields, {"Grupo/Marca", "_QRY1->BM_DESC"	 		  })	
	AADD(aFields, {"UM"	        , "_QRY1->B1_UM"   			 })	
	AADD(aFields, {"Estoque"	, "RetEst(_QRY1->B1_COD)"      })	
	AADD(aFields, {"Preço"		, "RetPreco(_QRY1->B1_COD)"    })
		
	for nX := 1 to Len(aFields)
		AADD(aCab, aFields[nX][GD_NOME])	
	next nX
        
    @ 002, 002 LISTBOX oPrinc Fields HEADER "INIT" SIZE 462, 244 OF oScrollB1 PIXEL ColSizes 50,50,150,100 ON DBLCLICK (SetRetor(1), lRet := .T.)
    oPrinc:aHeaders := aCab

    oPrinc:SetArray(aColsPri)
    oPrinc:bLine := {|| {;
    	aColsPri[oPrinc:nAt,1],;
	    aColsPri[oPrinc:nAt,2],;
	    aColsPri[oPrinc:nAt,3],;
    	aColsPri[oPrinc:nAt,4],;
	    aColsPri[oPrinc:nAt,5],;
	    aColsPri[oPrinc:nAt,6],;
	    aColsPri[oPrinc:nAt,7];
    }}
	oPrinc:Refresh()	    
	    
	If FunName() = "U_XMLNFE"
		If ValType(cPRDPesq)=="C"  // quando a rotina for executada e houver campo publico  cPRDPesq om conteudo
			If !Empty(cPRDPesq)
				Filtro(1)
				cPRDPesq := space(30)
			Endif
	    Endif
	EndIf
Return


Static Function RetEst(cProd)                               

	Local aArea  := GetArea()
	Local nValor := 0
	Local cRet   := ""
	               
	dbSelectArea("SB2")
	dbSetOrder(1)
	if dbseek(xFilial("SB2")+cProd) 
		nValor := SaldoSB2()
	endif
	
	cRet := Transform(nValor, "@E 99,999,999,999.99")
	
	RestArea(aArea)	
Return cRet

Static Function RetPreco(cProd)
	Local aArea  := GetArea()
	Local nValor := 0
	Local cRet   := ""  
	
	dbSelectArea('SB1')
	dbSetOrder(1)
	dbSeek(xFilial('SB1') + cProd)
	
	nValor := SB1->B1_PRV1
	
//	If !empty(SB1->B1_X_TABGER) 
		
//		dbSelectArea("DA1")
//		dbSetOrder(1)
//		if dbSeek(xFilial("DA1") + SB1->B1_X_TABGER + cProd)
//			nValor := DA1->DA1_PRCVEN   		
//		endif            
		               
//	Endif		
		
	cRet := Transform(nValor, "@E 999,999.99")
	
	RestArea(aArea)                           
	
return cRet

Static Function Filtro(nOPFil)
	Local nPos 		:= 1
	Local nX        := 0
	Local i         := 0
	Local cTxtLike 	:= Upper(AllTrim(cTxtBusca))
	Local aTxtLike	:= {}
	
	If " "$cTxtLike              
		aTxtLike := FilWord(cTxtLike)
	Endif

	//Atilio, 29/10/14, zerando a variável do filtro para poder alterar a pesquisa quando necessária
	cFiltro := ""

	If !Empty(cTxtBusca)
		If cCmbInd == "Código"
			cFiltro += " AND UPPER(SB1.B1_COD) LIKE '%" + Upper(AllTrim(cTxtBusca)) + "%'"
			cOrdem := " ORDER BY SB1.B1_COD "
		ElseIf cCmbInd == "Descrição"
			If len(aTxtLike)>=1 
			 	for i:=1 to len(aTxtLike)
			 		if !(Upper(AllTrim(aTxtLike[i]))$cFiltro)
			 			cFiltro += " AND UPPER(SB1.B1_DESC) LIKE '%" + Upper(AllTrim(aTxtLike[i])) + "%'"
			 		endif
			 	next i			
			Else
				If !(Upper(AllTrim(cTxtLike))$cFiltro)
					cFiltro += " AND UPPER(SB1.B1_DESC) LIKE '%" + Upper(AllTrim(cTxtLike)) + "%'"
				Endif	
			Endif
			cOrdem := " ORDER BY SB1.B1_DESC"			
		ElseIf cCmbInd == "Cód. Barras"
			cFiltro += " AND UPPER(SB1.B1_CODBAR) LIKE '%" + Upper(AllTrim(cTxtBusca)) + "%'"
			cOrdem := " ORDER BY SB1.B1_CODBAR "
		ElseIf cCmbInd == "Grupo/Marca"
			If len(aTxtLike)>=1 
			 	for i:=1 to len(aTxtLike)
			 		if !(Upper(AllTrim(aTxtLike[i]))$cFiltro)
			 			cFiltro += " AND UPPER(SBM.BM_DESC) LIKE '%" + Upper(AllTrim(aTxtLike[i])) + "%'"
			 		endif
			 	next i			
			Else
				If !(Upper(AllTrim(cTxtLike))$cFiltro)
					cFiltro += " AND UPPER(SBM.BM_DESC) LIKE '%" + Upper(AllTrim(cTxtLike)) + "%'"
				Endif	
			Endif
			cOrdem := " ORDER BY SBM.BM_DESC, SB1.B1_DESC"			
		Endif
	else 
	    cFiltro += " "
	endif	                                 

	If select("_QRY1") > 0
		_QRY1->(DbCloseArea())
	endif
	
	TcQuery cQuery1 + cFiltro + cOrdem NEW Alias "_QRY1"

	Count to nCont
	_QRY1->(DbGoTop())
	ProcRegua(nCont)
		
	aColsPri := {{nil,nil,nil,nil,nil,nil,nil}}
	If nOPFil = 2
		cFiltro := ''
	
	Else
		DbSelectArea("_QRY1")
		_QRY1->(DbGoTop())
		Do While !_QRY1->(Eof())
			IncProc("Carregando registros...")
			aAux := {}
			for nX := 1 to Len(aFields)
				AADD(aAux, &(aFields[nX][GD_CONTEUDO]) )
			next nX
			Aadd(aColsPri, aAux)	
			
			if aColsPri[1][1] == nil
				ADEL(aColsPri, 1)
				ASIZE(aColsPri, len(aColsPri) - 1)		
			endif
			
			_QRY1->(DbSkip())			
		Enddo		
	Endif
	
	if len(aColsPri) == 0
	   	MsgInfo("Registro não encontrado!")
	  
		oPrinc:SetArray(aColsPri)
		oPrinc:Refresh()
	else
		oPrinc:SetArray(aColsPri)
	    oPrinc:bLine := {|| {;
    		aColsPri[oPrinc:nAt,1],;
		    aColsPri[oPrinc:nAt,2],;
		    aColsPri[oPrinc:nAt,3],;
	    	aColsPri[oPrinc:nAt,4],;
		    aColsPri[oPrinc:nAt,5],;
		    aColsPri[oPrinc:nAt,6],;
	    	aColsPri[oPrinc:nAt,7]}}		
		oPrinc:Refresh()
		oPrinc:GoTop()
		oPrinc:SetFocus()		
	endif		
	If nOPFil = 3
 		Return .t.
	Endif
Return
	
Static Function Limpar()
		cTxtBusca := SPACE(30)
		Processa({|| Filtro(2) }, "Aguarde...") 
		oTxtBusca:SetFocus()		
Return


Static Function FilWord(cWord)
Local cTxtPesq	:= Alltrim(cWord)
Local cTxtAux 	:= ""
Local i         := 0
Local aRetTxt	:= {}
	For i:=1 to len(cTxtPesq)
		If !(Substr(cTxtPesq,i,1) == " ")
			cTxtAux := cTxtAux+Substr(cTxtPesq,i,1)
		Else  
			if !Empty(cTxtAux) 
				Aadd(aRetTxt,cTxtAux)
			Endif
			cTxtAux:= ""
		Endif  
	next i
	If !Empty(cTxtAux)
		Aadd(aRetTxt,cTxtAux)
		cTxtAux:= ""
	Endif
             
 
Return aRetTxt                  


Static Function fMosImagem()             

Local cBmpPict := ""
Local oDlg
Local oBmp
local aArea := getarea ()                        

oTFont := TFont():New('Courier new',,-16,.T.)     

oFontNormal  := TFont():New( "Tahoma",0,-13,,.T.,0,,400,.F.,.F.,,,,,, )
oFontTitulo  := TFont():New( "Courier New",0,-10.5,,.F.,0,,400,.F.,.F.,,,,,, )

cProd	:= aColsPri[oPrinc:nAt][GD_NOME]	  

If empty(cProd)
	return
Endif	

dbSelectArea('SB1')
dbSetOrder(1)
dbSeek(xFilial('SB1') + cProd)

//dbSelectArea('SZ1')
//dbSetOrder(1)
//dbSeek(xFilial('SZ1') + SB1->B1_X_PAI)

   
cBmpPict := Upper( AllTrim(SB1->B1_BITMAP))
               
DEFINE MSDIALOG oDlg   FROM 0,0 TO 460,860 PIXEL 

@ 000, 000 REPOSITORY oBmp SIZE 160, 180 OF oDlg    
oBmp:LoadBmp(cBmpPict)

@ 000,165 Say 'Descrição:' FONT oFontTitulo  PIXEL OF oDlg
@ 010,165 Say substr(SB1->B1_DESC,1,50) FONT oFontNormal  PIXEL OF oDlg	
@ 020,165 Say substr(SB1->B1_DESC,51,100) FONT oFontNormal  PIXEL OF oDlg	
@ 030,165 Say substr(SB1->B1_DESC,101,150) FONT oFontNormal  PIXEL OF oDlg	

//@ 040,165 Say 'Descrição Web:' FONT oFontTitulo PIXEL OF oDlg		
//@ 050,165 Say substr(SZ1->Z1_DESCWEB,1,50)  FONT oFontNormal PIXEL OF oDlg	
//@ 060,165 Say substr(SZ1->Z1_DESCWEB,51,100)  FONT oFontNormal PIXEL OF oDlg	
//@ 070,165 Say substr(SZ1->Z1_DESCWEB,101,150)  FONT oFontNormal PIXEL OF oDlg	
//@ 080,165 Say substr(SZ1->Z1_DESCWEB,151,200)  FONT oFontNormal PIXEL OF oDlg	

//@ 090,165 Say 'Altura:' FONT oFontTitulo        PIXEL OF oDlg		
//@ 100,165 Say SB1->B1_X_ALTUR FONT oFontNormal  PIXEL OF oDlg	

//@ 110,165 Say 'Largura:' FONT oFontTitulo      PIXEL OF oDlg		
//@ 120,165 Say SB1->B1_X_LARGU FONT oFontNormal PIXEL OF oDlg	

//@ 130,165 Say 'Profundidade:' FONT oFontTitulo PIXEL OF oDlg		
//@ 140,165 Say SB1->B1_X_PROFU FONT oFontNormal PIXEL OF oDlg	  

//@ 180, 290 BUTTON oButton11 PROMPT "WEB" SIZE 040, 012 OF oDlg ACTION (fMosWEB(), lRet := .T.) PIXEL 

@ 180, 330 BUTTON oButton12 PROMPT "Sair" SIZE 040, 012 OF oDlg ACTION (oDlg:End(), lRet := .F.) PIXEL    	

ACTIVATE MSDIALOG oDlg ON INIT (oBmp:lStretch := .T.) 

RestArea (aArea)

Return

//Static Function fMosWEB()

//msgInfo(SZ1->Z1_HTML)
//msgbox(SZ1->Z1_HTML,'WEB','INFO')

//Return

//Mostra Saldos do produto selecionado 
Static Function fMosSaldos()

cProd	:= aColsPri[oPrinc:nAt][GD_NOME]	  

If empty(cProd)
	return
Endif	

//Set Key VK_F6 TO MaViewSB2(cProd)
//Set Key VK_F6 TO fMosSaldos()

Return
