#Include "PROTHEUS.CH"           
#Include "TOPCONN.CH"
          
#DEFINE GD_NOME     1
#DEFINE GD_CONTEUDO 2
/*
___________________________________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ PesqLote ¦         Autor  ¦ Igor Gomes Oliveira                        ¦ Data ¦ 12/04/23  ¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ Rotina de pesquisa personalizada de Lote                              		 	    	¦¦¦
¦¦¦Descrição ¦ Utilizado na Rotina VAESTI03 - Manejo Sanitario                        		 	    	¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ Generico										                                	        ¦¦¦
¦¦+-----------------------------------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function PesqLote(cQry,nQry)
	Local aArea		:= GetArea()
    Local nI 
	Private lRet    := .F.
	Private nOpcQry := nQry
	Private cQuery1 := cQry
	Private cFiltro := ""
	
	Private oPrinc
	Private aColsPri     := {}
	Private aFields      := {} //Campos que aparecerão na grid principal

	Private oSecund
	Private	aColsSec 
	Private aFields2 := {} //Campos que aparecerão na grid secundária
	
	Private oDlg   
	     
	Private cTxtBusca   := Space(30)
	
	Private cTxtAplic   := Space(30)
	Private cCmbInd     := "Nome"
    Private aCamposGrid := {}
    Private cRetorno 

    aCamposGrid := GetFields()
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
    For nI := 1 to len(aCamposGrid)
		SX3->(DbSeek(aCamposGrid[nI]))
        aAdd(aFields,{ iif( UPPER(AllTrim(aCamposGrid[nI])) == 'SB8RECNO','RECNO SB8',AllTrim(X3TITULO())), "_QRY1->"+aCamposGrid[nI]})
    Next nI 
	SX3->(DBCLOSEAREA( ))

	DEFINE MSDIALOG oDlg TITLE "Pesquisa - Lote" FROM 000, 000  TO 445, 950 COLORS 0, 16777215 PIXEL

	    @ 004, 005 MSCOMBOBOX oCmbInd VAR cCmbInd ITEMS {"LOTE","CURRAL","BOV","DESCRICAO"} SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 004, 065 MSGET oTxtBusca VAR cTxtBusca 			SIZE 155, 010 OF oDlg COLORS 0,16777215 PIXEL //Valid(Filtro(3))
	    
	    @ 004, 228 BUTTON oBtnPesq PROMPT "Filtrar" 		SIZE 040, 012 OF oDlg PIXEL ACTION Processa({|| Filtro(1) }, "Aguarde...") 
	    @ 004, 278 BUTTON oBtnLimp PROMPT "&Limpar (F4)"	SIZE 040, 012 OF oDlg PIXEL ACTION Limpar(1) 	    
		SetKey( VK_F4, {|| Limpar(1)} )
		@ 004, 328 BUTTON oBtnSelC PROMPT "Sel. Lote"	    SIZE 040, 012 OF oDlg ACTION (SetRetor(1), lRet := .T.) PIXEL
    	@ 004, 428 BUTTON oBtnSair PROMPT "Sair" 			SIZE 040, 012 OF oDlg ACTION (oDlg:End(), lRet := .F.) PIXEL    	

  		@ 020, 003 SCROLLBOX oScrollB1 HORIZONTAL VERTICAL SIZE 200, 468 OF oDlg BORDER
	    GridPrin()                                                                     
       	    
	ACTIVATE MSDIALOG oDlg CENTERED
	
	SetKey( VK_F4,  Nil )
	RestArea(aArea)
Return cRetorno
/* Limpar grid */
Static Function Limpar()
		cTxtBusca := SPACE(30)
		Processa({|| Filtro(2) }, "Aguarde...") 
		oTxtBusca:SetFocus()		
Return
/* Selecionar Lote */
Static Function SetRetor(cEntidade)
	If aColsPri[oPrinc:nAt][1] <> nil
	if nOpcQry == 1
        cRetorno := aColsPri[oPrinc:nAt][04] // pegar recno
	else 
        cRetorno := aColsPri[oPrinc:nAt][10] // pegar recno
	endif
		oDlg:End()
	Else
		cEntidade	:= ""
		Alert("Nao há registros filtrados para seleção!")
	Endif
Return

/* Montagem da grid principal */
Static Function GridPrin()
	Local aCab    := {}
	Local nX      := 0

	for nX := 1 to Len(aFields)
		AADD(aColsPri, {nil})
		AADD(aCab, aFields[nX][1])
	next nX
        
    @ 002, 002 LISTBOX oPrinc Fields HEADER "INIT" SIZE 462, 194 OF oScrollB1 PIXEL ColSizes 50,50,150,100,50,20,60 ON DBLCLICK (SetRetor(1), lRet := .T.)
    oPrinc:aHeaders := aCab

	if nOpcQry == 1
		aColsPri := {{nil,nil,nil,nil}}
		oPrinc:SetArray(aColsPri)
		oPrinc:bLine := {|oPrinc| {;
			aColsPri[oPrinc:nAt,1],;
			aColsPri[oPrinc:nAt,2],;
			aColsPri[oPrinc:nAt,3],;
			aColsPri[oPrinc:nAt,4];
		}}
	else
		aColsPri := {{nil,nil,nil,nil,nil,nil,nil,nil,nil,nil}}
		oPrinc:SetArray(aColsPri)
		oPrinc:bLine := {|oPrinc| {;
			aColsPri[oPrinc:nAt,1],;
			aColsPri[oPrinc:nAt,2],;
			aColsPri[oPrinc:nAt,3],;
			aColsPri[oPrinc:nAt,4],;
			aColsPri[oPrinc:nAt,5],;
			aColsPri[oPrinc:nAt,6],;
			aColsPri[oPrinc:nAt,7],;
			aColsPri[oPrinc:nAt,8],;
			aColsPri[oPrinc:nAt,9],;
			aColsPri[oPrinc:nAt,10],;
		}}
	endif

	oPrinc:Refresh()	    
	    
Return
/* 
	Filtro da Grid
*/
Static Function Filtro(nOPFil)
	Local cTxtLike 	:= Upper(AllTrim(cTxtBusca))
	Local aTxtLike	:= {}
	Local i         := 0
	Local nX        := 0

	If " "$cTxtLike
		aTxtLike := FilWord(cTxtLike)
	Endif

	If !Empty(cTxtBusca)
		If cCmbInd == "LOTE"
			cFiltro := " AND UPPER(B8_LOTECTL) LIKE '%" + Upper(AllTrim(cTxtBusca)) + "%'"
		ElseIf cCmbInd == "CURRAL"
			If len(aTxtLike)>=1
			 	for i:=1 to len(aTxtLike)
			 		if !(Upper(AllTrim(aTxtLike[i]))$cFiltro)
			 			cFiltro := " AND UPPER(B8_X_CURRA) LIKE '%" + Upper(AllTrim(aTxtLike[i])) + "%'"
			 		endif
			 	next i
			Else
				If !(Upper(AllTrim(cTxtLike))$cFiltro)
					cFiltro := " AND UPPER(B8_X_CURRA) LIKE '%" + Upper(AllTrim(cTxtLike)) + "%'"
				Endif	
			Endif
		ElseIF cCmbInd == "BOV"
			cFiltro := " AND UPPER(B8_PRODUTO) LIKE '%" + Upper(AllTrim(cTxtBusca)) + "%'"
		ElseIF cCmbInd == "DESCRICAO"
			cFiltro := " AND UPPER(B1_DESC) LIKE '%" + Upper(AllTrim(cTxtBusca)) + "%' AND B1_XIDADE <= 8"
		Endif

		if nOpcQry == 1
			cOrdem :=  " ORDER BY B8_LOTECTL"
		elseif nOpcQry == 2
			cOrdem :=  " ORDER BY B8_DATA"
		else
			if IsInCallStack("U_VAESTI03")
				IF cCmbInd != "DESCRICAO"
					cFiltro += "AND B1_DESC in ('BOVINO MACHO DE 0 A 3 MESES','BOVINO MACHO DE 0 A 03 MESES','BOVINO MACHO DE 0 A 8 MESES','BOVINO MACHO DE 0 A 08 MESES','BOVINO FEMEA DE 0 A 3 MESES','BOVINO FEMEA DE 0 A 03 MESES','BOVINO FEMEA DE 0 A 8 MESES','BOVINO FEMEA DE 0 A 08 MESES')"
				endif 
				cOrdem :=  " ORDER BY B1_DESC"
			else 
				cOrdem :=  " ORDER BY B8_DATA"
			endif
		endif

	else 
		if IsInCallStack("U_VAESTI03") .and. nOpcQry == 3
			cFiltro := "AND B1_DESC in ('BOVINO MACHO DE 0 A 3 MESES','BOVINO MACHO DE 0 A 03 MESES','BOVINO MACHO DE 0 A 8 MESES','BOVINO MACHO DE 0 A 08 MESES','BOVINO FEMEA DE 0 A 3 MESES','BOVINO FEMEA DE 0 A 03 MESES','BOVINO FEMEA DE 0 A 8 MESES','BOVINO FEMEA DE 0 A 08 MESES')"
			cOrdem :=  " ORDER BY B1_DESC"
		else
			cOrdem :=  " ORDER BY B8_LOTECTL"
	    	cFiltro := " "
		endif
	endif

	If select("_QRY1") > 0
		_QRY1->(DbCloseArea())
	endif

	TcQuery cQuery1 + cFiltro + cOrdem NEW Alias "_QRY1"

	Count to nCont
	_QRY1->(DbGoTop())
	ProcRegua(nCont)
	
	if nOpcQry == 1
		aColsPri := {{nil,nil,nil,nil}}
		aColsSec := {{nil,nil,nil,nil}}
	else
		aColsPri := {{nil,nil,nil,nil,nil,nil,nil,nil,nil,nil}}
		aColsSec := {{nil,nil,nil,nil,nil,nil,nil,nil,nil,nil}}
	endif

	If nOPFil = 2
		cFiltro := ''
	Else
		DbSelectArea("_QRY1")
		_QRY1->(DbGoTop())
		Do While !_QRY1->(Eof())
			IncProc("Carregando registros...")
			aAux := {}
			for nX := 1 to Len(aFields)
				AADD(aAux, &(aFields[nX][2]) )
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
	    if nOpcQry == 1
			oPrinc:bLine := {|oPrinc| {;
				aColsPri[oPrinc:nAt,1],;
				aColsPri[oPrinc:nAt,2],;
				aColsPri[oPrinc:nAt,3],;
				aColsPri[oPrinc:nAt,4];
			}}
		else
			oPrinc:bLine := {|oPrinc| {;
				aColsPri[oPrinc:nAt,1],;
				aColsPri[oPrinc:nAt,2],;
				aColsPri[oPrinc:nAt,3],;
				aColsPri[oPrinc:nAt,4],;
				aColsPri[oPrinc:nAt,5],;
				aColsPri[oPrinc:nAt,6],;
				aColsPri[oPrinc:nAt,7],;
				aColsPri[oPrinc:nAt,8],;
				aColsPri[oPrinc:nAt,9],;
				aColsPri[oPrinc:nAt,10],;
			}}
		endif 

		oPrinc:Refresh()
		oPrinc:GoTop()
		oPrinc:SetFocus()		
	endif		
	If nOPFil = 3
 		Return .t.
	Endif
Return
/* 
	Pega os Campos do SQL 
*/
Static Function GetFields()
    Local aCampos := {}
    Local nI

    for nI := 1 to len(AllTrim(cQuery1))
        if SubStr(cQuery1,nI,3) $ 'B1_|B8_'
            aAdd(aCampos, AllTrim( SubStr(cQuery1,nI,At(" ",cQuery1,nI)-nI)))
        elseif SubStr(cQuery1,nI,8) == "SB8RECNO"
            aAdd(aCampos, AllTrim( SubStr(cQuery1,nI,At(" ",cQuery1,nI)-nI)))
        endif

        if Upper(SubStr(cQuery1,nI,4)) == 'FROM'
            exit 
        EndIf
    Next nI 
Return aCampos
