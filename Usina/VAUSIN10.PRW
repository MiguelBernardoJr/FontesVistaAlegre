#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "An·lise Carregamento Levedura"
/*/{Protheus.doc} VAUSIN10
    (long_description)
    @type  Function VAUSIN10
    @author Igor Oliveira
    @since 16/08/2023
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function VAUSIN10()
    Local aArea		:= FWGetArea()
	Local oBrowse
    Private _cRet :=  CriaVar('A2_COD'  , .F.)
    Private cPerg := funname()


	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZCL")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 		:= nil
	Local oCab   		:= FWFormStruct(1, 'ZCL', {|cCampo| AllTrim(cCampo) $ "ZCL_FILIAL|ZCL_COD|ZCL_NOME|ZCL_FORNEC|ZCL_LOJA" })
	Local oGrid   		:= FWFormStruct(1, 'ZCL', {|cCampo| AllTrim(cCampo) $ "ZCL_NUMNF|ZCL_EMISSA|ZCL_SERIE|ZCL_PESO|ZCL_DENSID|ZCL_TEOR|ZCL_MS" })
    Local aZCLRel       := {}
    Local bSaveZCL      := {|| SaveZCL()}

	oModel := MPFormModel():New("USIN10M",/*Pre-Validacao*/, /*Pos-Validacao*/,bSaveZCL/* bVldCom Commit*/,/*Cancel*/)

	oModel:AddFields("ZCLMASTER",/*cOwner*/  ,oCab		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddGrid('ZCLDETAIL', 'ZCLMASTER'	, oGrid, /*bLinePre*/, /*bLinePos*//* {|| VldLinha()} */,/* bPre */,/* bPos */,{|| LoadGrid()})
	
	aAdd(aZCLRel, {'ZCL_FILIAL', 'Iif(!INCLUI, ZCL->ZCL_FILIAL, FWxFilial("ZCL"))'} )
	aAdd(aZCLRel, {'ZCL_COD', 'Iif(!INCLUI, ZCL->ZCL_COD , ZCL->ZCL_COD)'} )
	aAdd(aZCLRel, {'ZCL_NUMNF','Iif(!INCLUI, ZCL->ZCL_NUMNF , ZCL->ZCL_NUMNF)'} )
	
	//Criando o relacionamento
	oModel:SetRelation('ZCLDETAIL', aZCLRel, ZCL->(IndexKey(1)))
	oModel:SetPrimaryKey({"ZCL_FILIAL"+"ZCL_COD+ZCL_NUMNF"})

	//Setando outras informaÁıes do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZCLMASTER"):SetDescription("Formul·rio do Cadastro "+cTitulo)
	
Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAUSIN10")
    Local oCab   		:= FWFormStruct(2, 'ZCL', {|cCampo| AllTrim(cCampo) $ "ZCL_FILIAL|ZCL_COD|ZCL_NOME|ZCL_FORNEC|ZCL_LOJA" })
	Local oGrid   		:= FWFormStruct(2, 'ZCL', {|cCampo| AllTrim(cCampo) $ "ZCL_NUMNF|ZCL_EMISSA|ZCL_SERIE|ZCL_PESO|ZCL_DENSID|ZCL_TEOR|ZCL_MS"})
	Local oView         

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZCL", oCab  , "ZCLMASTER")
	oView:AddGrid("GRID_ZCL", oGrid  , "ZCLDETAIL")
    
	oView:CreateHorizontalBox('CABEC', 30 )
	oView:CreateHorizontalBox('GRID', 70 )

	oView:SetOwnerView("VIEW_ZCL"	 , "CABEC")
	oView:SetOwnerView("GRID_ZCL"	 , "GRID")
	
	oView:EnableTitleView('VIEW_ZCL'  , cTitulo)
	oView:EnableTitleView('GRID_ZCL'  , "Itens")
    
    oView:SetCloseOnOk( { |oView| .T. } )
Return oView

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAUSIN10' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VAUSIN10' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VAUSIN10' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VAUSIN10' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 
Return aRotina

Static Function SaveZCL()
    Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local nOpc      := oModel:GetOperation()
	Local oGrid     := oModel:GetModel('ZCLDETAIL')/* :SetUniqueLine({'ZCL_CODIGO'}) */
	Local oCab      := oModel:GetModel('ZCLMASTER')/* :SetUniqueLine({'ZCL_CODIGO'}) */
	Local nI        := 0
    Local nLinhas

	DbSelectArea('ZCL')
	ZCL->(DbSetOrder(1))
	//Se for Exclus„o
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
        DbSelectArea('ZCL')
        ZCL->(DbSetOrder(1)) //ZDM_FILIAL + ZDM_CODIGO + ZDM_CODIGO
        nLinhas := oGrid:GetQtdLine()
        For nI := 1 To nLinhas
            oGrid:GoLine(nI)
            If !oGrid:isDeleted()
                RecLock('ZCL', lRecLock := !DbSeek( FWxFilial("ZCL") +;
                                            oCab:GetValue('ZCL_COD') +;
                                            oGrid:GetValue('ZCL_NUMNF')))

                    ZCL->ZCL_FILIAL    	:= FWxFilial("ZCL")
                    ZCL->ZCL_COD 	   	:= oCab:GetValue('ZCL_COD') 
                    ZCL->ZCL_FORNEC    	:= oCab:GetValue('ZCL_FORNEC')
                    ZCL->ZCL_LOJA    	:= oCab:GetValue('ZCL_LOJA')
                    ZCL->ZCL_NUMNF   	:= oGrid:GetValue('ZCL_NUMNF')
                    ZCL->ZCL_EMISSA     := oGrid:GetValue('ZCL_EMISSA')
                    ZCL->ZCL_SERIE   	:= oGrid:GetValue('ZCL_SERIE') 
                    ZCL->ZCL_PESO   	:= oGrid:GetValue('ZCL_PESO') 
                    ZCL->ZCL_DENSID   	:= oGrid:GetValue('ZCL_DENSID') 
                    ZCL->ZCL_MS     	:= oGrid:GetValue('ZCL_MS')

                ZCL->(MsUnlock())
            Else		
                If ZCL->(DbSeek( FWxFilial("ZCL") +;
                        oCab:GetValue('ZCL_COD') +;
                        oGrid:GetValue('ZCL_NUMNF')))

                    RecLock('ZCL', .F.)
                        ZCL->(DbDelete())
                    ZCL->(MsUnlock())
                EndIf
            EndIf
        Next nI
	elseIf nOpc == MODEL_OPERATION_DELETE
		For nI := 1 To oGrid:GetQtdLine()
			oGrid:GoLine(nI)
			//Se conseguir posicionar, exclui o registro
			If ZCL->(DbSeek( FWxFilial("ZCL") + oCab:GetValue('ZCL_COD') + oGrid:GetValue('ZCL_NUMNF')))
				RecLock('ZCL', .F.)
					ZCL->(DbDelete())
				ZCL->(MsUnlock())
			EndIf
		Next nI
	EndIf

	//Se n„o for inclus„o, volta o INCLUI para .T. (bug ao utilizar a Exclus„o, antes da Inclus„o)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

	RestArea(aArea)
Return 

User Function ZCLSD1()
    Local oView      := FWViewActive()
    Local oModel    := FWModelActive()
    Local oCab      := oModel:GetModel("ZCLMASTER")
    Local oGrid     := oModel:GetModel("ZCLDETAIL")
    Local aArea     := GetArea()
	Local cQry 		:= ""
    Local lRet      := .T. 

    IF !(oGrid:IsEmpty())
        oGrid:ClearData()
    endif

	oGrid:SetNoInsertLine(.F.)

    GeraX1(cPerg)

    if pergunte(cPerg, .T.)
        cQry := "SELECT D1_FORNECE,  " + CRLF
        cQry += "        D1_LOJA,  " + CRLF
        cQry += "        A2_NOME,  " + CRLF
        cQry += "        D1_DOC,  " + CRLF
        cQry += "        D1_SERIE,  " + CRLF
        cQry += "        D1_DTDIGIT,  " + CRLF
        cQry += "        D1_QUANT,  " + CRLF
        cQry += "        D1_COD  " + CRLF
        cQry += "FROM "+RetSqlName("SD1")+" SD1  " + CRLF
        cQry += "	JOIN "+RetSqlName("SA2")+" A2 ON A2_COD = D1_FORNECE " + CRLF
        cQry += "    AND A2_LOJA = D1_LOJA " + CRLF
        cQry += "    AND A2.D_E_L_E_T_ = '' " + CRLF
        cQry += "WHERE D1_FORNECE = '"+MV_PAR03+"' " + CRLF
        cQry += "AND D1_LOJA = '"+iif(EMPTY(MV_PAR04),'01',MV_PAR04)+"' " + CRLF
        cQry += "AND D1_DTDIGIT BETWEEN '"+dToS(MV_PAR05)+"' AND '"+dToS(MV_PAR06)+"' " + CRLF
        cQry += "AND D1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + CRLF
        cQry += "AND D1_FILIAL + D1_FORNECE + D1_LOJA + D1_DOC + D1_SERIE + D1_DTDIGIT NOT IN ( " + CRLF
        cQry += "	SELECT ZCL_FILIAL + ZCL_FORNEC + ZCL_LOJA + ZCL_NUMNF + ZCL_SERIE + ZCL_EMISSA " + CRLF
        cQry += "	 FROM "+RetSqlName("ZCL")+" ZCL " + CRLF
        cQry += "	 WHERE D1_FILIAL = ZCL_FILIAL " + CRLF
        cQry += "	   AND D1_FORNECE = ZCL_FORNEC " + CRLF
        cQry += "	   AND D1_LOJA = ZCL_LOJA " + CRLF
        cQry += "	   AND D1_DOC = ZCL_NUMNF " + CRLF
        cQry += "	   AND D1_SERIE = ZCL_SERIE " + CRLF
        cQry += "	   AND D1_DTDIGIT = ZCL_EMISSA " + CRLF
        cQry += "	   AND ZCL.D_E_L_E_T_ = '') " + CRLF
        cQry += "AND SD1.D_E_L_E_T_ = '' " + CRLF

        IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
            MemoWrite("C:\totvs_relatorios\"+"ZCL_.sql" , cQry)
        ENDIF

        MpSysOpenQuery(cQry, "TMP")
        
        _cRet := MV_PAR03
        oCab:LoadValue("ZCL_LOJA",MV_PAR04)
        
        if !TMP->(EOF())

            while !TMP->(EOF())
                oGrid:AddLine()
                oGrid:LoadValue("ZCL_NUMNF"   ,TMP->D1_DOC)
                oGrid:LoadValue("ZCL_SERIE"   ,TMP->D1_SERIE)
                oGrid:LoadValue("ZCL_EMISSA"  ,sToD(TMP->D1_DTDIGIT))
                oGrid:LoadValue("ZCL_PESO"    ,TMP->D1_QUANT)

                TMP->(dbSkip())
            ENDDO
            oGrid:SetNoInsertLine(.T.)
        else
            lRet := .F. 
            oModel:SetErrorMessage("","","","","N„o h· dados", 'N„o h· dados para os par‚metros informados!', "")
        EndIf
        TMP->(DBCLOSEAREA(  ))
    endif
    oGrid:GoLine(1)
    oView:Refresh()
    FWRestArea(aArea)
Return lRet 

Static Function LoadGrid()
    Local aArea := GetArea()
    Local cQry  := ""
    Local aRet  := {}
    Local nI    := 1

    cQry := "SELECT  " + CRLF 
    cQry += " * FROM "+RetSqlName("ZCL")+" " + CRLF 
    cQry += " WHERE ZCL_FILIAL = '"+ZCL->ZCL_FILIAL+"' " + CRLF 
    cQry += " AND ZCL_COD = '"+ZCL->ZCL_COD+"' " + CRLF 
    cQry += " AND D_E_L_E_T_ = ''  " + CRLF 

    MpSysOpenQuery(cQry,"TMP")

	While !TMP->(EOF())
        aAdd(aRet,{nI,{ TMP->ZCL_NUMNF,;
                        TMP->ZCL_SERIE,;
                        sToD(TMP->ZCL_EMISSA),;
                        TMP->ZCL_PESO,;
                        TMP->ZCL_DENSID,;
                        TMP->ZCL_TEOR,;
                        TMP->ZCL_MS}})
        nI += 1 
        TMP->(DBSKIP())
    End
    
    if Len(aRet) == 0
        aAdd(aRet,{ 1,{ "",;
                        "",;
                        sToD(""),;
                        0,;
                        0,;
                        0,;
                        0}})
    EndIf

    TMP->(DBCLOSEAREA())
    
    RestArea(aArea)
Return aRet

Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local i, j

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

aAdd(aRegs,{cPerg, "01", "Produto de:  " , "", "", "MV_CH1", "C", TamSX3("B1_COD")[1]    , TamSX3("B1_COD")[2]    , 0, "G", "", "MV_PAR01" , "", "","",""      ,"","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
aAdd(aRegs,{cPerg, "02", "Produto ate: " , "", "", "MV_CH2", "C", TamSX3("B1_COD")[1]    , TamSX3("B1_COD")[2]    , 0, "G", "", "MV_PAR02" , "", "","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
aAdd(aRegs,{cPerg, "03", "Fornecedor:  " , "", "", "MV_CH3", "C", TamSX3("A2_COD")[1]    , TamSX3("A2_COD")[2]    , 0, "G", "", "MV_PAR03" , "", "","",""      ,"","","","","","","","","","","","","","","","","","","","","SA2","","","","",""})
aAdd(aRegs,{cPerg, "04", "Loja:        " , "", "", "MV_CH4", "C", TamSX3("A2_LOJA")[1]   , TamSX3("A2_LOJA")[2]   , 0, "G", "", "MV_PAR04" , "", "","",""      ,"","","","","","","","","","","","","","","","","","","","",""   ,"","","","",""})
aAdd(aRegs,{cPerg, "05", "Data de:     " , "", "", "MV_CH5", "D", TamSX3("D2_DTDIGIT")[1], TamSX3("D2_DTDIGIT")[2], 0, "G", "", "MV_PAR05" , "", "","",""	   ,"","","","","","","","","","","","","","","","","","","","",""   ,"","","","",""})
aAdd(aRegs,{cPerg, "06", "Data atÈ:    " , "", "", "MV_CH6", "D", TamSX3("D2_DTDIGIT")[1], TamSX3("D2_DTDIGIT")[2], 0, "G", "", "MV_PAR06" , "", "","",""      ,"","","","","","","","","","","","","","","","","","","","",""   ,"","","","",""})

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

// grava√ß√£o das perguntas na tabela SX1
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
/* 
User Function ZCLSD1()
    Local oModel := FWModelActive()
    Local oCab   := oModel:GetModel("ZCLMASTER")
    Local oGrid     := oModel:GetModel("ZCLDETAIL")
    Local aArea
	Local cQry 		:= ""
    Local aParamBox := {}
    Local aCpos     := {}
    Local aRetParam := {}
    Local aRet      := {}
    Local lRet      := .T. 
    
    IF !(oGrid:IsEmpty())
        oGrid:ClearData()
    endif 

    aAdd(aParamBox,{1,"Produto de:  "  ,Space(TamSX3("B1_COD")[1]) ,"" ,"ExistCpo('SB1')","SB1","",50,.T.}) // Tipo data
    aAdd(aParamBox,{1,"Produto ate: "  ,Space(TamSX3("B1_COD")[1]) ,"" ,"ExistCpo('SB1')","SB1","",50,.F.}) // Tipo data
    aAdd(aParamBox,{1,"Fornecedor:  "  ,Space(TamSX3("A2_COD")[1]) ,"" ,"ExistCpo('SA2')","SA2","",50,.T.}) // Tipo data
    aAdd(aParamBox,{1,"Loja:        "  ,Space(TamSX3("A2_LOJA")[1]),"" ,""               ,""   ,"",50,.F.}) // Tipo data
    aAdd(aParamBox,{1,"Data de:     "  ,Ctod(Space(8))             ,"" ,""               ,""   ,"",50,.T.}) // Tipo data
    aAdd(aParamBox,{1,"Data atÈ:    "  ,Ctod(Space(8))             ,"" ,""               ,""   ,"",50,.F.}) // Tipo data
    
    If ParamBox(aParamBox,"Selecionar Fornecedor...",@aRetParam)
    
        aArea := GetArea()

        cQry := "SELECT D1_FORNECE,  " + CRLF
        cQry += "        D1_LOJA,  " + CRLF
        cQry += "        A2_NOME,  " + CRLF
        cQry += "        D1_DOC,  " + CRLF
        cQry += "        D1_SERIE,  " + CRLF
        cQry += "        D1_DTDIGIT,  " + CRLF
        cQry += "        D1_QUANT,  " + CRLF
        cQry += "        D1_COD  " + CRLF
        cQry += "FROM "+RetSqlName("SD1")+" SD1  " + CRLF
        cQry += "	JOIN "+RetSqlName("SA2")+" A2 ON A2_COD = D1_FORNECE " + CRLF
        cQry += "    AND A2_LOJA = D1_LOJA " + CRLF
        cQry += "    AND A2.D_E_L_E_T_ = '' " + CRLF
        cQry += "WHERE D1_FORNECE = '"+aRetParam[3]+"' " + CRLF
        cQry += "AND D1_LOJA = '"+IIF(EMPTY(aRetParam[4]),'01',aRetParam[4])+"' " + CRLF
        cQry += "AND D1_DTDIGIT BETWEEN '"+dToS(aRetParam[5])+"' AND '"+dToS(aRetParam[6])+"' " + CRLF
        cQry += "AND D1_FILIAL + D1_FORNECE + D1_LOJA + D1_DOC + D1_SERIE + D1_DTDIGIT NOT IN ( " + CRLF
        cQry += "	SELECT ZCL_FILIAL + ZCL_FORNEC + ZCL_LOJA + ZCL_NUMNF + ZCL_SERIE + ZCL_EMISSA " + CRLF
        cQry += "	 FROM "+RetSqlName("ZCL")+" ZCL " + CRLF
        cQry += "	 WHERE D1_FILIAL = ZCL_FILIAL " + CRLF
        cQry += "	   AND D1_FORNECE = ZCL_FORNEC " + CRLF
        cQry += "	   AND D1_LOJA = ZCL_LOJA " + CRLF
        cQry += "	   AND D1_DOC = ZCL_NUMNF " + CRLF
        cQry += "	   AND D1_SERIE = ZCL_SERIE " + CRLF
        cQry += "	   AND D1_DTDIGIT = ZCL_EMISSA " + CRLF
        cQry += "	   AND ZCL.D_E_L_E_T_ = '') " + CRLF
        cQry += "AND SD1.D_E_L_E_T_ = '' " + CRLF

        IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
            MemoWrite("C:\totvs_relatorios\"+"ZCL_"+cValToChar(dDataBase)+".sql" , cQry)
        ENDIF

        MpSysOpenQuery(cQry, "TMP")

        while !TMP->(EOF())
            aAdd(aCPos, {TMP->D1_FORNECE,;
                        TMP->D1_LOJA,;
                        TMP->A2_NOME,;
                        TMP->D1_DOC,;
                        TMP->D1_SERIE,;
                        TMP->D1_DTDIGIT,;
                        TMP->D1_QUANT})
            TMP->(dbSkip())
        ENDDO

            If Len(aCpos) < 1
                aAdd(aCpos,{"","","","","",""})
            EndIf

            DEFINE MSDIALOG oDlg TITLE "Listagem das Pesagens" FROM 0,0 TO 325,1000 PIXEL

            @ 0,0 LISTBOX oLbx FIELDS HEADER 'COD FORNEC' ,;
                'LOJA',;
                'FORNECEDOR',;
                'NOTA FISCAL',;
                'SERIE',;
                'DATA' ,;
                'PESO' SIZE 500,150 OF oDlg PIXEL

            oLbx:SetArray( aCpos )
            oLbx:bLine     := {|| { aCpos[oLbx:nAt,1],;
                                    aCpos[oLbx:nAt,2],;
                                    aCpos[oLbx:nAt,3],;
                                    aCpos[oLbx:nAt,4],;
                                    aCpos[oLbx:nAt,5],;
                                    sToD(aCpos[oLbx:nAt,6]),;
                                    aCpos[oLbx:nAt,7]}}
            oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],;
                                    oLbx:aArray[oLbx:nAt,2],;
                                    oLbx:aArray[oLbx:nAt,3],;
                                    oLbx:aArray[oLbx:nAt,4],;
                                    oLbx:aArray[oLbx:nAt,5],;
                                    sToD(oLbx:aArray[oLbx:nAt,6]),;
                                    oLbx:aArray[oLbx:nAt,7]}}}
            DEFINE SBUTTON FROM 150,474 TYPE 1 ACTION (oDlg:End(), lRet:=.T.,;
                aRet := {oLbx:aArray[oLbx:nAt,1],;
                        oLbx:aArray[oLbx:nAt,2],;
                        oLbx:aArray[oLbx:nAt,3],;
                        oLbx:aArray[oLbx:nAt,4],;
                        oLbx:aArray[oLbx:nAt,5],;
                        sToD(oLbx:aArray[oLbx:nAt,6]),;
                        oLbx:aArray[oLbx:nAt,7]}) ENABLE OF oDlg
            ACTIVATE MSDIALOG oDlg CENTER

            If Len(aRet) > 0 .And. lRet
                oCab:SetValue("ZCL_FORNEC"   ,aRet[1])
                oCab:SetValue("ZCL_LOJA"     ,aRet[2])
                oCab:SetValue("ZCL_NOME"     ,aRet[3])
                _cRet := aRet[4]
                oCab:SetValue("ZCL_SERIE"    ,aRet[5])
                oCab:SetValue("ZCL_EMISSA"   ,aRet[6])
                oCab:SetValue("ZCL_PESO"     ,aRet[7])
            EndIf

        TMP->(DBCLOSEAREA(  ))
        FWRestArea(aArea)
    endif
Return lRet 
 */

/* Static Function CABEXT(oPanel)
    Local oView    := FWViewActive()
    Local oModel   := FWModelActive()
    Local oFont8N  := TFONT():New("ARIAL",08,-11,,.T.,,,,.T.,.F.) ///Fonte 8 Negrito

    if oModel:GetOperation() > 1
        SetKey(VK_F10, {|| IncGrid(1)})
    Endif

    SX3->(DbSetOrder(2))

    oScrSco:= TScrollBox():Create(oPanel,01,01,oPanel:nClientHeight - 40,oPanel:nClientWidth / 2,.F.,.T.,.F.)
    oScrSco:Align := CONTROL_ALIGN_ALLCLIENT

    oPanel1 := oPanel
    oView:Refresh()

    oBtn  := TButton():New( 010, 010, "Buscar (F10)",oScrSco,{||IncGrid()}, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    
    //Cria CSS Defualt para os Botoes
    cCSSBtn1 := " QPushButton {"
    cCSSBtn1 += " background-color: rgb(46, 169, 200);"
    cCSSBtn1 += " border-style: outset; "
    cCSSBtn1 += " border-width: 1px;"
    cCSSBtn1 += " border-color: rgb(46, 169, 200);"
    cCSSBtn1 += " border-radius: 10px;"
    cCSSBtn1 += " font-weight: bold;"
    cCSSBtn1 += " }"

    oBtn:setCSS(cCSSBtn1)
    oBtn:Refresh()
Return  */
