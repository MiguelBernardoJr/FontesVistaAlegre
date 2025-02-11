#Include "PROTHEUS.CH"           
#Include "TOPCONN.CH"
          
#DEFINE GD_NOME     1
#DEFINE GD_CONTEUDO 2
/*
___________________________________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ PESQCLI ¦         Autor  ¦ Henrique Magalhaes / Fábio Avallone        ¦ Data ¦ 10/02/11  ¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ Rotina de pesquisa personalizada de clientes / locais de entrega 		 				¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ Generico										                                	        ¦¦¦
¦¦+-----------------------------------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function PesqNfE()
	Private lRet           := .F.
	Private cQuery1 := ""
	Private cFiltro := ""
	Private cOrdem  := " ORDER BY SF1.F1_FILIAL,SF1.F1_DOC,SA2.A2_NOME"	
	
	Private oPrinc
	Private aColsPri     := {{nil,nil,nil,nil,nil,nil,nil}}
	Private aFields      := {} //Campos que aparecerão na grid principal

	Private oSecund
	Private	aColsSec := {{nil,nil,nil,nil,nil,nil,nil}}
	Private aFields2 := {} //Campos que aparecerão na grid secundária
	
	Private oDlg   
	     
	Private cTxtBusca := Space(30)
	
	Private cTxtAplic := Space(30)
	Private cCmbInd  := "Nome"
  
//	cQuery1 := "SELECT *  "
	cQuery1 := " SELECT F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,A2_NOME" + CRLF 
    cQuery1 += " FROM " + RetSqlName("SF1") + " SF1" + CRLF 
    cQuery1 += " JOIN " + RetSqlName("SA2") + " A2 ON A2_COD = F1_FORNECE" + CRLF 
    cQuery1 += " AND A2_LOJA = F1_LOJA" + CRLF 
    cQuery1 += " AND A2.D_E_L_E_T_ = ''" + CRLF 
    cQuery1 += " WHERE SF1.D_E_L_E_T_ = '' " + CRLF 
    cQuery1 += " AND SF1.F1_EMISSAO >  DATEADD(DAY, -60, GETDATE()) " + CRLF 
    
	AADD(aFields, {"Filial"    	, "_QRY1->F1_FILIAL"})
	AADD(aFields, {"Doc"  		, "_QRY1->F1_DOC"	})	
	AADD(aFields, {"Serie" 		, "_QRY1->F1_SERIE"	})	
	AADD(aFields, {"Forncedor" 	, "_QRY1->F1_FORNECE"})	
	AADD(aFields, {"Loja"	    , "_QRY1->F1_LOJA"	})	
	AADD(aFields, {"Nome"   	, "_QRY1->A2_NOME"	})	
	AADD(aFields, {"CPF/CNPJ"   , "_QRY1->A2_CGC"	}) 
		
	DEFINE MSDIALOG oDlg TITLE "Pesquisa - Clientes" FROM 000, 000  TO 445, 950 COLORS 0, 16777215 PIXEL

	    @ 004, 005 MSCOMBOBOX oCmbInd VAR cCmbInd ITEMS {"DOC","CPF/CNPJ","NOME"} SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 004, 065 MSGET oTxtBusca VAR cTxtBusca 			SIZE 155, 010 OF oDlg COLORS 0,16777215 PIXEL //Valid(Filtro(3))
	    
	    @ 004, 228 BUTTON oBtnPesq PROMPT "Filtrar" 		SIZE 040, 012 OF oDlg PIXEL ACTION Processa({|| Filtro(1) }, "Aguarde...") 
	    @ 004, 278 BUTTON oBtnLimp PROMPT "&Limpar (F4)"	SIZE 040, 012 OF oDlg PIXEL ACTION Limpar(1)	    
		SetKey( VK_F4, {|| Limpar(1)} )
    	@ 004, 328 BUTTON oBtnSelC PROMPT "Sel. Doc" 	SIZE 040, 012 OF oDlg ACTION (SetRetor(1), lRet := .T.) PIXEL
    	//@ 004, 378 BUTTON oBtnIncC PROMPT "Inc. Cliente"	SIZE 040, 012 OF oDlg ACTION (U_FSLOJA01()) PIXEL    	

    	@ 004, 428 BUTTON oBtnSair PROMPT "Sair" 			SIZE 040, 012 OF oDlg ACTION (oDlg:End(), lRet := .F.) PIXEL    	

  		@ 020, 003 SCROLLBOX oScrollB1 HORIZONTAL VERTICAL SIZE 200, 468 OF oDlg BORDER
	    GridPrin()                                                                     
       	    
	ACTIVATE MSDIALOG oDlg CENTERED
Return lRet
                                                                                        

/* Montagem da grid principal */
Static Function GridPrin()
	//Local aAux    := {}
	Local aCab    := {}
	Local nX      := 0

	AADD(aFields, {"Filial"    	, "_QRY1->F1_FILIAL"})
	AADD(aFields, {"Doc"  		, "_QRY1->F1_DOC"	})	
	AADD(aFields, {"Serie" 		, "_QRY1->F1_SERIE"	})	
	AADD(aFields, {"Forncedor" 	, "_QRY1->F1_FORNECE"})	
	AADD(aFields, {"Loja"	    , "_QRY1->F1_LOJA"	})	
	AADD(aFields, {"Nome"   	, "_QRY1->A2_NOME"	})	
	AADD(aFields, {"CPF/CNPJ"   , "_QRY1->A2_CGC"	}) 
		
	for nX := 1 to Len(aFields)
		AADD(aCab, aFields[nX][GD_NOME])	
	next nX
        
    @ 002, 002 LISTBOX oPrinc Fields HEADER "INIT" SIZE 462, 194 OF oScrollB1 PIXEL ColSizes 50,50,150,100,50,20,60 ON DBLCLICK (SetRetor(1), lRet := .T.)
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
	    
    // Evento do click
    // oPrinc:bChange := {|| SetRetor(1) }
Return


Static Function SetRetor(cEntidade)
	If aColsPri[oPrinc:nAt][GD_NOME] <> nil
		cEntidade := aColsPri[oPrinc:nAt][GD_NOME]+aColsPri[oPrinc:nAt][2]
		oDlg:End()
	Else
		cEntidade	:= ""
		Alert("Nao há registros filtrados para seleção!")
	Endif
Return


Static Function Filtro(nOPFil)
	//Local nPos 		:= 1
	Local i         := 0
	Local nX        := 0
	Local cTxtLike 	:= Upper(AllTrim(cTxtBusca))
	Local aTxtLike	:= {}
	
	If " "$cTxtLike              
		aTxtLike := FilWord(cTxtLike)
	Endif

	If !Empty(cTxtBusca)
		If cCmbInd == "DOC"
			cFiltro += " AND UPPER(SF1.F1_DOC) LIKE '%" + Upper(AllTrim(cTxtBusca)) + "%'"
			cOrdem := " ORDER BY SF1.F1_FILIAL,SF1.F1_DOC,SA2.A2_NOME"	
		ElseIf cCmbInd == "NOME"
			If len(aTxtLike)>=1 
			 	for i:=1 to len(aTxtLike)
			 		if !(Upper(AllTrim(aTxtLike[i]))$cFiltro)
			 			cFiltro += " AND UPPER(SA2.A2_NOME) LIKE '%" + Upper(AllTrim(aTxtLike[i])) + "%'"
			 		endif
			 	next i			
			Else
				If !(Upper(AllTrim(cTxtLike))$cFiltro)
					cFiltro += " AND UPPER(SA2.A2_NOME) LIKE '%" + Upper(AllTrim(cTxtLike)) + "%'"
				Endif	
			Endif
			cOrdem := "SA2.A2_NOME"		
		Else
			cFiltro += " AND UPPER(SA2.A2_CGC) LIKE '%" + Upper(AllTrim(cTxtBusca)) + "%'"
			cOrdem := " ORDER BY SA2.A2_NOME "
		Endif
	else 
	    cFiltro += ""
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
		cFiltro := ""	
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
	  
    	aColsSec := {{nil,nil,nil,nil,nil,nil,nil}}
	    oSecund:SetArray(aColsSec)
	    	  
	   	aAux := {}
		for nX := 1 to Len(aFields2)
	    	AADD(aAux, cValToChar(nX))
		next nX
		Aadd(aColsSec,aAux)	
		
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
	    	aColsPri[oPrinc:nAt,7];
	    }}		
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
Local i         := 0
Local cTxtAux 	:= ""
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
