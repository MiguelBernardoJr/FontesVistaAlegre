#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Evoluir Era do Gado"
/*/{Protheus.doc} VAFATI08
    (long_description)
    @type  Function
    @author Igor Oliveira
    @since 16/08/2023
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function VAFATI08()
    Local aArea		 := FWGetArea()
	Local oBrowse
    Private aLotes   := {}
    Private aBovs    := {}
    Private aPreco   := {}
	Private cE1HIST  := ""
    Private nQtdAnt  := 0
    Private cTimeINI :=  Time()
	Private cArquivo := "C:\TOTVS_RELATORIOS\"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZVD")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 	:= nil
 //  Local oMaster   := FWFormStruct(1, 'ZVD', {|cCampo| AllTrim(cCampo) $ "ZVD_FILIAL|ZVD_COD|ZVD_LOTE|ZVD_TIPOLA" })
 //  Local oGrid     := FWFormStruct(1, 'ZVD', {|cCampo| !(AllTrim(cCampo) $ "ZVD_FILIAL|ZVD_COD|ZVD_LOTE|ZVD_TIPOLA") })
    Local oMaster   := FWFormStruct(1, 'ZVD')
    Local oGrid     := FWFormStruct(1, 'ZVD')
    Local bPre      := {|| zVldMD()}
    Local aZVDRel   := {}

    //oGrid:SetProperty('ZVD_ITZ09'    ,   MODEL_FIELD_VALID, {|| FAT08G()})

	oModel := MPFormModel():New("FATI08M", /*Pre-Validacao*/,bPre/*Pos-Validacao*/,{|| bSaveCom()},/*Cancel*/)

	oModel:AddFields("ZVDMASTER",/*cOwner*/  ,oMaster		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddGrid('ZVDDETAIL', 'ZVDMASTER'	, oGrid, /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,/* {|| LoadGPrincipal()} */  )

    aAdd(aZVDRel, {'ZVD_FILIAL', 'FWxFilial("ZVD")'} )
	aAdd(aZVDRel, {'ZVD_COD'   , 'ZVD->ZVD_COD'} )

	oModel:SetRelation('ZVDDETAIL', aZVDRel, ZVD->(IndexKey(1)))

    oModel:SetPrimaryKey({"ZVD_FILIAL"+"ZVD_COD","ZVD_ITEM"})
	//oModel:GetModel('ZVDDETAIL'):SetUniqueLine({ "ZVD_FILIAL" ,"ZVD_COD", "ZVD_ITEM" })
    
    oMaster:SetProperty('ZVD_LOTE', MODEL_FIELD_VALID, {|| FI08LT()})

    oGrid:SetProperty('ZVD_BOV', MODEL_FIELD_VALID, {|| FI08PR()})
    oGrid:SetProperty('ZVD_IDADEP', MODEL_FIELD_VALID, {|| FAT08G()})
    
	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZVDMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
    
    oModel:InstallEvent("VLD_MODEL", , cFati08():New(oModel))
Return oModel

Static Function ViewDef()
	Local oModel    := FWLoadModel("VAFATI08")
//    Local oMaster   := FWFormStruct(2, 'ZVD', {|cCampo| AllTrim(cCampo) $ "ZVD_FILIAL|ZVD_COD|ZVD_LOTE|ZVD_TIPOLA" })
//    Local oGrid     := FWFormStruct(2, 'ZVD', {|cCampo| !(AllTrim(cCampo) $ "ZVD_FILIAL|ZVD_COD|ZVD_LOTE|ZVD_TIPOLA") })
    Local oMaster   := FWFormStruct(2, 'ZVD')
    Local oGrid     := FWFormStruct(2, 'ZVD')
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZVD", oMaster, "ZVDMASTER")
	oView:AddGrid('GRID_ZVD', oGrid , 'ZVDDETAIL')
    
	oView:CreateHorizontalBox('CABEC', 15 )
	oView:CreateHorizontalBox('GRID', 85 )
	
	oView:SetOwnerView("VIEW_ZVD"	 , "CABEC")
	oView:SetOwnerView("GRID_ZVD"	 , "GRID")
	
    oView:AddUserButton( 'Replicar linhas (F10)' 	,'', {|oView| ReplicaLinha()} )
    oView:AddUserButton( 'Transferir Lotes (F11)' 	,'', {|oView| VldTransf()} )
    SetKey( VK_F10, {|oView| ReplicaLinha()} )
    SetKey( VK_F11, {|oView| VldTransf()} )

	//oView:EnableTitleView('VIEW_ZVD'  , cTitulo)
    
    oMaster:RemoveField('ZVD_ITEM'  )
    oMaster:RemoveField('ZVD_BOV'   )
    oMaster:RemoveField('ZVD_DESCA' )
    oMaster:RemoveField('ZVD_SEXO'  )
    oMaster:RemoveField('ZVD_IDADE' )
    oMaster:RemoveField('ZVD_Z09ANT')
    oMaster:RemoveField('ZVD_9ITANT')
    oMaster:RemoveField('ZVD_PRODES')
    oMaster:RemoveField('ZVD_IDADEP')
    oMaster:RemoveField('ZVD_CODZ09')
    oMaster:RemoveField('ZVD_ITZ09')
    oMaster:RemoveField('ZVD_DESCP')

	oGrid:RemoveField('ZVD_FILIAL'  )
	oGrid:RemoveField('ZVD_COD'     )
	oGrid:RemoveField('ZVD_LOTE'    )
	oGrid:RemoveField('ZVD_TIPOLA'  )

    oView:AddIncrementField( 'GRID_ZVD', 'ZVD_ITEM' )
	
	oView:SetCloseOnOk( { |oView| .T. } )
Return oView

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAFATI08' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VAFATI08' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VAFATI08' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 
Return aRotina

Static Function bSaveCom()
    Local aArea     := GetArea()
    Local oModel    := FWModelActive()
    Local oCab      := oModel:GetModel("ZVDMASTER")
    Local oGrid     := oModel:GetModel("ZVDDETAIL")
    Local oMdSB1    := nil
    Local oSB1Mod   := nil
	Local nOpc      := oModel:GetOperation()
    Local lRet      := .T.
    Local nI        := 0
    Local cBov      := GETMV("MV_BOVPADR")

    DBSELECTAREA( "SB1" )
    SB1->(DBSETORDER( 1 ))

    If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
        For nI := 1 To oGrid:Length()
            oGrid:GoLine(nI)
            If !oGrid:isDeleted()
                
                RecLock('ZVD', lRecLock := !ZVD->(DbSeek( FWxFilial("ZVD") +;
                                                          oCab:GetValue('ZVD_COD') +;
                                                          oGrid:GetValue('ZVD_ITEM'))))

                ZVD->ZVD_FILIAL    	:= FWxFilial("ZVD")
                ZVD->ZVD_COD 	   	:= oCab:GetValue('ZVD_COD')
                ZVD->ZVD_LOTE    	:= oCab:GetValue('ZVD_LOTE')
                ZVD->ZVD_ITEM    	:= oGrid:GetValue('ZVD_ITEM')
                ZVD->ZVD_BOV    	:= oGrid:GetValue('ZVD_BOV')
                ZVD->ZVD_IDADE   	:= oGrid:GetValue('ZVD_IDADE')
                ZVD->ZVD_Z09ANT     := oGrid:GetValue('ZVD_Z09ANT')
                ZVD->ZVD_9ITANT     := oGrid:GetValue('ZVD_9ITANT')
                ZVD->ZVD_IDADEP    	:= oGrid:GetValue('ZVD_IDADEP') 
                ZVD->ZVD_CODZ09   	:= oGrid:GetValue('ZVD_CODZ09')
                ZVD->ZVD_ITZ09      := oGrid:GetValue('ZVD_ITZ09')

                if ZVD->ZVD_IDADEP != 0 .and. !(AllTrim(ZVD->ZVD_BOV) $ cBov)
                    if SB1->(DbSeek(FwXFilial("SB1")+ALLTRIM( ZVD->ZVD_BOV )))
                        If ZVD->ZVD_IDADEP < 36
                            cDesc := "BOVINO " + IIF(ALLTRIM( SB1->B1_X_SEXO ) == 'CAPAO','MACHO',ALLTRIM( SB1->B1_X_SEXO )) +;
                                    " DE " + ALLTRIM( STR(POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_IDAINI"))) +;
                                    " A "  + ALLTRIM( STR(POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_IDAFIM")))+;
                                    " MESES"
                        else
                            cDesc := "BOVINO " + IIF(ALLTRIM( SB1->B1_X_SEXO ) == 'CAPAO','MACHO',ALLTRIM( SB1->B1_X_SEXO )) +;
                                    " ACIMA DE " + ALLTRIM( STR(POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_IDAINI"))) +;
                                    " MESES"
                        endif

                        oMdSB1 := FWLoadModel("MATA010")
                        oMdSB1:SetOperation(4)
                        oMdSB1:Activate()
                        
                        //Pegando o model e setando os campos
                        oSB1Mod := oMdSB1:GetModel("SB1MASTER")
                        oSB1Mod:SetValue("B1_XANIMAL", ZVD->ZVD_CODZ09              ) 
                        oSB1Mod:SetValue("B1_XANIITE", ZVD->ZVD_ITZ09               ) 
                        oSB1Mod:SetValue("B1_XIDADE" , ALLTRIM(Str(ZVD->ZVD_IDADEP))) 
                        oSB1Mod:SetValue("B1_DESC"   , cDesc                        ) 
                        oSB1Mod:SetValue("B1_X_ERA"  , ALLTRIM( POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_DESCRI"))   ) 

                        If oMdSB1:VldData()
                            //Tenta realizar o Commit
                            If oMdSB1:CommitData()
                                lOk := .T.
                            //Se não deu certo, altera a variável para false
                            Else
                                lOk := .F.
                            EndIf
                        //Se não conseguir validar as informações, altera a variável para false
                        Else
                            lOk := .F.
                        EndIf
                        
                        //Se não deu certo a inclusão, mostra a mensagem de erro
                        If ! lOk
                            //Busca o Erro do Modelo de Dados
                            aErro := oMdSB1:GetErrorMessage()
                            
                            //Monta o Texto que será mostrado na tela
                            cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
                            cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
                            cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
                            cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
                            cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
                            cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
                            cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
                            cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
                            cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
                            
                            //Mostra mensagem de erro
                            MsgStop(cMessage)
                        EndIf

                        oMdSB1:DeActivate()

                        oMdSB1  := nil
                        oSB1Mod := nil 
                    ENDIF
                EndIf
            Else		
                If ZVD->(DbSeek( FWxFilial("ZVD") +;
                        oCab:GetValue('ZVD_COD') +;
                        oGrid:GetValue('ZVD_ITEM')))

                    RecLock('ZVD', .F.)
                        ZVD->(DbDelete())
                    ZVD->(MsUnlock())
                EndIf
            EndIf
        Next nI 
    endif 

    ZVD->(DBCLOSEAREA(  ))
    SB1->(DBCLOSEAREA(  ))

    //Se não for inclusão, volta o INCLUI para .T. (bug ao utilizar a Exclusão, antes da Inclusão)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

    RestArea(aArea)
Return lRet

Static Function FI08PR()
    Local aArea     := GetArea()
    Local oModel    := FWModelActive()
    Local oView     := FWViewActive()
    Local oCab      := oModel:GetModel("ZVDMASTER")
    Local oGrid     := oModel:GetModel("ZVDDETAIL")
    Local lRet      := .T.
    Local cQry      := ""
    Local cValue    := &(ReadVar())
    Local cBov      := GETMV("MV_BOVPADR")
    Local cAlias    := ""
    //IF oCab:GetValue("ZVD_TIPOLA") == '1'
    //    oModel:SetErrorMessage("","","","","Não permitido", 'Não é permitido inserir esse campo no Tipo 1 - [Evoluir Era]!', "") 
    //    lRet := .F.
    //endif

    if lRet
        DBSelectArea("SB1")
        SB1->(DBSETORDER(1))

        if SB1->(DbSeek(FwXFilial("SB1")+PadR(AllTrim(cValue),TamSx3("B1_COD")[1])))
            if AllTrim(SB1->B1_GRUPO) == 'BMS'

                if AllTrim(SB1->B1_COD) $ cBov
                    MsgStop("Era do Produto ["+AllTrim(SB1->B1_COD)+"] não pode ser alterada!")
                    lRet := .F.
                endif

                if "BOVINO" $ AllTrim(SB1->B1_DESC)
                    oModel:SetErrorMessage("","","","","Produto inválido", 'Produto não é Bovino!', "") 
                    lRet := .F.
                endif
            else
                oModel:SetErrorMessage("","","","","Produto inválido", 'Produto deve pertencer!', "") 
                lRet := .F.
            endif
        else
            oModel:SetErrorMessage("","","","","Produto inválido", 'Produto não encontrado!', "") 
            lRet := .F.
        endif
    endif

    if lRet
        If !(oGrid:IsEmpty())
            if oGrid:CanClearData()
                oGrid:ClearData()
            endif
        endif
        
        cQry := " SELECT B8_PRODUTO, B1_DESC, B8_SALDO,B1_XIDADE,B1_XANIMAL,B1_XANIITE,B1_X_SEXO, Z09_IDAINI, Z09_IDAFIM" + CRLF 
        cQry += " FROM "+RetSqlName("SB8")+" SB8 " + CRLF 
        cQry += " JOIN "+RetSqlName("SB1")+" SB1 ON  B8_PRODUTO = B1_COD  " + CRLF
        cQry += " AND SB1.D_E_L_E_T_ = ''  " + CRLF
        cQry += " JOIN "+RetSqlName("Z09")+" Z09 ON B1_XANIMAL = Z09_CODIGO " + CRLF 
        cQry += " AND B1_XANIITE = Z09_ITEM " + CRLF 
        cQry += " AND Z09.D_E_L_E_T_ = '' " + CRLF 
        cQry += " WHERE B8_PRODUTO LIKE 'BOV%'  " + CRLF 
        cQry += " and B8_LOTECTL = '"+oCab:GetValue("ZVD_LOTE")+"'  " + CRLF 
        cQry += " AND B8_SALDO > 0  " + CRLF 
        cQry += " AND SB8.D_E_L_E_T_ = ' '   " + CRLF 
        cQry += " ORDER BY B1_DESC,B8_SALDO " + CRLF 

        cAlias:= MpSysOpenQuery(cQry)
        
        oGrid:SetNoInsertLine(.F.)
        oGrid:SetNoDeleteLine(.F.)
        while !(cAlias)->(EOF())
            oGrid:AddLine()
            oGrid:LoadValue("ZVD_BOV"    ,ALLTRIM((cAlias)->B8_PRODUTO))
            oGrid:SetValue("ZVD_IDADE"  ,Val((cAlias)->B1_XIDADE))
            IF (cAlias)->Z09_IDAINI < 36
                oGrid:SetValue("ZVD_DESCA","BOVINO " + IIF(ALLTRIM( (cAlias)->B1_X_SEXO ) == 'CAPAO','MACHO',ALLTRIM( (cAlias)->B1_X_SEXO )) +;
                                            " DE " + ALLTRIM( STR((cAlias)->Z09_IDAINI )) +;
                                            " A "  + ALLTRIM( STR((cAlias)->Z09_IDAFIM ))+;
                                            " MESES")
            ELSE 
                oGrid:SetValue("ZVD_DESCA","BOVINO " + IIF(ALLTRIM( (cAlias)->B1_X_SEXO ) == 'CAPAO','MACHO',ALLTRIM( (cAlias)->B1_X_SEXO )) +;
                                            " ACIMA DE " + ALLTRIM( STR((cAlias)->Z09_IDAINI )) +;
                                            " MESES")
            ENDIF 
            oGrid:SetValue("ZVD_SEXO  " ,IIF(ALLTRIM((cAlias)->B1_X_SEXO) == 'CAPAO','MACHO',ALLTRIM( (cAlias)->B1_X_SEXO )))
            oGrid:SetValue("ZVD_Z09ANT" ,(cAlias)->B1_XANIMAL)
            oGrid:SetValue("ZVD_9ITANT" ,(cAlias)->B1_XANIITE)
            oGrid:SetValue("ZVD_CODZ09" ,(cAlias)->B1_XANIMAL)
            oGrid:SetValue("ZVD_ITZ09"  ,(cAlias)->B1_XANIITE)

            (cAlias)->(DBSKIP())
        enddo
        
        if oGrid:GetQtdLine() > 1
            oGrid:GoLine(1)
        endif

        oGrid:SetNoInsertLine(.T.)
        oGrid:SetNoDeleteLine(.T.)

        oView:Refresh()
        (cAlias)->(DBCLOSEAREA(  ))
    endif
    RestArea(aArea)
Return lRet

Static Function FI08LT()
    Local aArea := GetArea()
    Local oModel    := FWModelActive()
    Local oView     := FWViewActive()
    Local oCab      := oModel:GetModel("ZVDMASTER")
    Local oGrid     := oModel:GetModel("ZVDDETAIL")
    Local lRet      := .T.
    Local cQry      := ""
    Local cAlias    := ""
    Local cBov      := GETMV("MV_BOVPADR")

    If !(oGrid:IsEmpty())
        oGrid:ClearData()
    endif
    
    cQry := " SELECT B8_PRODUTO, B1_DESC, B8_SALDO,B1_XIDADE,B1_XANIMAL,B1_XANIITE,B1_X_SEXO, Z09_IDAINI, Z09_IDAFIM" + CRLF 
    cQry += " FROM "+RetSqlName("SB8")+" SB8 " + CRLF 
    cQry += " JOIN "+RetSqlName("SB1")+" SB1 ON  B8_PRODUTO = B1_COD  " + CRLF 
    cQry += " AND SB1.D_E_L_E_T_ = ''  " + CRLF
    cQry += " JOIN "+RetSqlName("Z09")+" Z09 ON B1_XANIMAL = Z09_CODIGO " + CRLF 
    cQry += " AND B1_XANIITE = Z09_ITEM " + CRLF 
    cQry += " AND Z09.D_E_L_E_T_ = '' " + CRLF 
    cQry += " WHERE B8_PRODUTO LIKE 'BOV%'  " + CRLF 
    cQry += " and B8_LOTECTL = '"+oCab:GetValue("ZVD_LOTE")+"'  " + CRLF 
    cQry += " AND B8_SALDO > 0  " + CRLF 
    cQry += " AND SB8.D_E_L_E_T_ = ' '   " + CRLF
    cQry += " ORDER BY B1_DESC,B8_SALDO " + CRLF

    cAlias := MpSysOpenQuery(cQry)
    
    oGrid:SetNoInsertLine(.F.)
    oGrid:SetNoDeleteLine(.F.)
    while !(cAlias)->(EOF())
        if ALLTRIM((cAlias)->B8_PRODUTO) $ cBov
            MsgALert("O Produto [" + ALLTRIM((cAlias)->B8_PRODUTO) + "] Não será adicionado pois está bloqueado para evoluir era! " + CRLF +;
                        "Faça a transferência para outro BOV com a idade correta!")
        else
            oGrid:AddLine()
            oGrid:LoadValue("ZVD_BOV"    ,ALLTRIM((cAlias)->B8_PRODUTO))
            oGrid:SetValue("ZVD_IDADE"  ,Val((cAlias)->B1_XIDADE))
            IF (cAlias)->Z09_IDAINI < 36
                oGrid:SetValue("ZVD_DESCA","BOVINO " + IIF(ALLTRIM( (cAlias)->B1_X_SEXO ) == 'CAPAO','MACHO',ALLTRIM( (cAlias)->B1_X_SEXO )) +;
                                            " DE " + ALLTRIM( STR((cAlias)->Z09_IDAINI )) +;
                                            " A "  + ALLTRIM( STR((cAlias)->Z09_IDAFIM ))+;
                                            " MESES")
            ELSE 
                oGrid:SetValue("ZVD_DESCA","BOVINO " + IIF(ALLTRIM( (cAlias)->B1_X_SEXO ) == 'CAPAO','MACHO',ALLTRIM( (cAlias)->B1_X_SEXO )) +;
                                            " ACIMA DE " + ALLTRIM( STR((cAlias)->Z09_IDAINI )) +;
                                            " MESES")
            ENDIF 
            oGrid:SetValue("ZVD_SEXO  " ,IIF(ALLTRIM((cAlias)->B1_X_SEXO) == 'CAPAO','MACHO',ALLTRIM( (cAlias)->B1_X_SEXO )))
            oGrid:SetValue("ZVD_Z09ANT" ,(cAlias)->B1_XANIMAL)
            oGrid:SetValue("ZVD_9ITANT" ,(cAlias)->B1_XANIITE)
            oGrid:SetValue("ZVD_CODZ09" ,(cAlias)->B1_XANIMAL)
            oGrid:SetValue("ZVD_ITZ09"  ,(cAlias)->B1_XANIITE)
        endif
        (cAlias)->(DBSKIP())
    enddo
    (cAlias)->(DBCLOSEAREA(  ))
    
    if oGrid:GetQtdLine() > 1
        oGrid:GoLine(1)
    endif 

    oGrid:SetNoInsertLine(.T.)
    oGrid:SetNoDeleteLine(.T.)

    oView:Refresh()
    RestArea(aArea)
Return lRet 

Static Function FAT08G()
    Local aArea     := GetArea()
    Local oModel    := FWModelActive()
	Local oGrid     := oModel:GetModel('ZVDDETAIL')
    Local cQry 
    Local lRet      := .T.
    local cDesc     
    Local cAlias    := ""
    
    cQry := "  SELECT *  " + CRLF 
    cQry += " FROM "+RetSqlName("Z09")+" " + CRLF 
    cQry += " WHERE Z09_CODIGO = '"+oGrid:GetValue("ZVD_CODZ09")+"' " + CRLF 
    cQry += " and Z09_IDAINI <= "+ALLTRIM(Str(oGrid:GetValue("ZVD_IDADEP")))+" " + CRLF 
    cQry += " AND Z09_IDAFIM >= "+ALLTRIM(Str(oGrid:GetValue("ZVD_IDADEP")))+" " + CRLF 
    cQry += " AND D_E_L_E_T_ = '' " + CRLF

    cAlias := MpSysOpenQuery(cQry)

    IF !(cAlias)->(EOF())
        if (cAlias)->Z09_IDAINI < 36
            cDesc := "BOVINO " + IIF(ALLTRIM( (cAlias)->Z09_SEXO ) == 'CAPAO','MACHO',ALLTRIM( (cAlias)->Z09_SEXO ))  + " DE " + ALLTRIM( STR((cAlias)->Z09_IDAINI)) + " A " + ALLTRIM( STR((cAlias)->Z09_IDAFIM) )  + " MESES"
        else 
            cDesc := "BOVINO " + IIF(ALLTRIM( (cAlias)->Z09_SEXO ) == 'CAPAO','MACHO',ALLTRIM( (cAlias)->Z09_SEXO )) + " ACIMA DE " + ALLTRIM( STR((cAlias)->Z09_IDAINI)) + " MESES"
        endif
        oGrid:SetValue("ZVD_DESCP"  , cDesc)
        oGrid:SetValue("ZVD_CODZ09" ,ALLTRIM( (cAlias)->Z09_CODIGO ))
        oGrid:SetValue("ZVD_ITZ09"  ,ALLTRIM( (cAlias)->Z09_ITEM ))
    else
        oModel:SetErrorMessage("","","","","Idade Inválida", 'Valor não encontrado no intervalo de idade permitido!', "") 
        lRet := .F.
    endif

    RestArea(aArea)
Return lRet

Static Function VldTransf()
    Local oModel    := FWModelActive()
	Local oGrid     := oModel:GetModel('ZVDDETAIL')
    Local nLinhas   := oGrid:GetQtdLine()
    Local nBakLin   := 0
    Local nI

    oGrid:Goline(1)
    nBakId      := oGrid:GetValue("ZVD_IDADEP")
    cDescA      := oGrid:GetValue("ZVD_DESCA")
    cDescP      := oGrid:GetValue("ZVD_DESCP")
    cCodZ09     := oGrid:GetValue("ZVD_CODZ09")
    cItZ09      := oGrid:GetValue("ZVD_ITZ09")
    nBakLin     := oGrid:GetLine()

    For nI := 1 to nLinhas
        oGrid:Goline(nI)
        If nI != 1 .and. cDescA != oGrid:GetValue("ZVD_DESCA")
            nBakId      := oGrid:GetValue("ZVD_IDADEP")
            cDescA      := oGrid:GetValue("ZVD_DESCA")
            cDescP      := oGrid:GetValue("ZVD_DESCP")
            cCodZ09     := oGrid:GetValue("ZVD_CODZ09")
            cItZ09      := oGrid:GetValue("ZVD_ITZ09")
            nBakLin     := oGrid:GetLine()
        endif
        
        if cDescA ==  oGrid:GetValue("ZVD_DESCA") .and. nBakLin != oGrid:GetLine()
            oGrid:SetValue("ZVD_IDADEP" , nBakId)
            oGrid:SetValue("ZVD_DESCP"  , cDescP)
            oGrid:SetValue("ZVD_CODZ09" , cCodZ09)
            oGrid:SetValue("ZVD_ITZ09"  , cItZ09)
        endif
    Next nI

    oGrid:Goline(1)
Return 

Static Function ReplicaLinha()
    Local oModel    := FWModelActive()
	Local oGrid     := oModel:GetModel('ZVDDETAIL')
    Local nLinhas   := oGrid:GetQtdLine()
    Local nBakId    := 0
    Local cDescA    := ''
    Local cDescP    := ''
    Local cCodZ09   := ''
    Local cItZ09    := ''
    Local nBakLin   := 0
    Local nI 

    oGrid:Goline(1)
    nBakId      := oGrid:GetValue("ZVD_IDADEP")
    cDescA      := oGrid:GetValue("ZVD_DESCA")
    cDescP      := oGrid:GetValue("ZVD_DESCP")
    cCodZ09     := oGrid:GetValue("ZVD_CODZ09")
    cItZ09      := oGrid:GetValue("ZVD_ITZ09")
    nBakLin     := oGrid:GetLine()

    For nI := 1 to nLinhas
        oGrid:Goline(nI)
        If nI != 1 .and. cDescA != oGrid:GetValue("ZVD_DESCA")
            nBakId      := oGrid:GetValue("ZVD_IDADEP")
            cDescA      := oGrid:GetValue("ZVD_DESCA")
            cDescP      := oGrid:GetValue("ZVD_DESCP")
            cCodZ09     := oGrid:GetValue("ZVD_CODZ09")
            cItZ09      := oGrid:GetValue("ZVD_ITZ09")
            nBakLin     := oGrid:GetLine()
        endif
        
        if cDescA ==  oGrid:GetValue("ZVD_DESCA") .and. nBakLin != oGrid:GetLine()
            oGrid:SetValue("ZVD_IDADEP" , nBakId )
            oGrid:SetValue("ZVD_DESCP"  , cDescP )
            oGrid:SetValue("ZVD_CODZ09" , cCodZ09)
            oGrid:SetValue("ZVD_ITZ09"  , cItZ09 )
        endif
    Next nI 

    oGrid:Goline(1)
Return 

/*/
{Protheus.doc} cFati08
Declara a Classe vinda da FWModelEvent e os métodos que serão utilizados
@author Atilio
@since 27/01/2023
@version version
@see https://tdn.totvs.com/pages/releaseview.action?pageId=269552294
/*/

Class cFati08 From FWModelEvent
    Method New() CONSTRUCTOR
    Method BeforeTTS()
    Method InTTS()
    Method AfterTTS()
    Method After()
EndClass
/*/{Protheus.doc} New
Método para "instanciar" um observador
@author Atilio
@since 27/01/2023
@version version
@param oModel, Objeto, Objeto instanciado do Modelo de Dados
/*/
 
Method New(oModel) CLASS cFati08
Return

/*/{Protheus.doc} After
Método que é chamado pelo MVC quando ocorrer as ações do commit
depois da gravação de cada submodelo (field ou cada linha de uma grid)
@author Atilio
@since 27/01/2023
@version version
@param oModel, Objeto, Objeto instanciado do Modelo de Dados
/*/

Method After(oModel) Class cFati08
    //Local aArea := GetArea()
    //Local cDesc := ''
    //Local cBov  := GETMV("MV_BOVPADR")
//
    //Local oMdSB1  := nil
    //Local oSB1Mod := nil 
//
    ////Campos de controle, para registrar oq estava registrado na SB1 antes de altera-lá
    //DBSELECTAREA( "SB1" )
    //SB1->(DBSETORDER( 1 ))
//
    //if oModel:cId == 'ZVDDETAIL'
    //    if ZVD->ZVD_IDADEP != 0 .and. !(AllTrim(ZVD->ZVD_BOV) $ cBov)
    //        if SB1->(DbSeek(FwXFilial("SB1")+ALLTRIM( ZVD->ZVD_BOV )))
    //            If ZVD->ZVD_IDADEP < 36
    //                cDesc := "BOVINO " + IIF(ALLTRIM( SB1->B1_X_SEXO ) == 'CAPAO','MACHO',ALLTRIM( SB1->B1_X_SEXO )) +;
    //                         " DE " + ALLTRIM( STR(POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_IDAINI"))) +;
    //                         " A "  + ALLTRIM( STR(POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_IDAFIM")))+;
    //                         " MESES"
    //            else
    //                cDesc := "BOVINO " + IIF(ALLTRIM( SB1->B1_X_SEXO ) == 'CAPAO','MACHO',ALLTRIM( SB1->B1_X_SEXO )) +;
    //                         " ACIMA DE " + ALLTRIM( STR(POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_IDAINI"))) +;
    //                         " MESES"
    //            endif
//
    //            //RECLOCK( "SB1", .F. )
    //            //    SB1->B1_XANIMAL := ZVD->ZVD_CODZ09
    //            //    SB1->B1_XANIITE := ZVD->ZVD_ITZ09
    //            //    SB1->B1_XIDADE  := ALLTRIM(Str(ZVD->ZVD_IDADEP))
    //            //    SB1->B1_DESC    := cDesc
    //            //    SB1->B1_X_ERA   := ALLTRIM( POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_DESCRI"))
    //            //SB1->(MSUNLOCK())
//
    //            oMdSB1 := FWLoadModel("MATA010")
    //            oMdSB1:SetOperation(4)
    //            oMdSB1:Activate()
    //            
    //            //Pegando o model e setando os campos
    //            oSB1Mod := oMdSB1:GetModel("SB1MASTER")
    //            oSB1Mod:SetValue("B1_XANIMAL", ZVD->ZVD_CODZ09              ) 
    //            oSB1Mod:SetValue("B1_XANIITE", ZVD->ZVD_ITZ09               ) 
    //            oSB1Mod:SetValue("B1_XIDADE" , ALLTRIM(Str(ZVD->ZVD_IDADEP))) 
    //            oSB1Mod:SetValue("B1_DESC"   , cDesc                        ) 
    //            oSB1Mod:SetValue("B1_X_ERA"  , ALLTRIM( POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_DESCRI"))   ) 
//
    //            If oMdSB1:VldData()
    //                //Tenta realizar o Commit
    //                If oMdSB1:CommitData()
    //                    lOk := .T.
    //                //Se não deu certo, altera a variável para false
    //                Else
    //                    lOk := .F.
    //                EndIf
    //            //Se não conseguir validar as informações, altera a variável para false
    //            Else
    //                lOk := .F.
    //            EndIf
    //            
    //            //Se não deu certo a inclusão, mostra a mensagem de erro
    //            If ! lOk
    //                //Busca o Erro do Modelo de Dados
    //                aErro := oMdSB1:GetErrorMessage()
    //                
    //                //Monta o Texto que será mostrado na tela
    //                cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
    //                cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
    //                cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
    //                cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
    //                cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
    //                cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
    //                cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
    //                cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
    //                cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
    //                
    //                //Mostra mensagem de erro
    //                MsgStop(cMessage)
    //            EndIf
//
    //            oMdSB1:DeActivate()
//
    //            oMdSB1  := nil
    //            oSB1Mod := nil 
    //        ENDIF
    //    ENDIF
    //ENDIF
    //
    //SB1->(DBCLOSEAREA(  ))
//
    //RestArea(aArea)
    //Aqui você pode fazer as operações antes de gravar
Return

/*/{Protheus.doc} BeforeTTS
Método acionado antes de fazer as gravações da transação
@author Atilio
@since 27/01/2023
@version version
@param oModel, Objeto, Objeto instanciado do Modelo de Dados
/*/
 
Method BeforeTTS(oModel) Class cFati08
    //Aqui você pode fazer as operações antes de gravar
Return
 
/*/{Protheus.doc} InTTS
Método acionado durante as gravações da transação
@author Atilio
@since 27/01/2023
@version version
@param oModel, Objeto, Objeto instanciado do Modelo de Dados
/*/
 
Method InTTS(oModel) Class cFati08
    /* Local oGrid := oModel:GetModel("ZVDDETAIL")
    Local nI 
    
    For nI := 1 to oGrid:GetQtdLine()
        oGrid:GoLine(nI)

        If !oGrid:isDeleted()
            RecLock('ZVD', lRecLock := !ZVD->(DbSeek( FWxFilial("ZVD") +;
                                                        oCab:GetValue('ZVD_COD') +;
                                                        oGrid:GetValue('ZVD_ITEM'))))

            ZVD->ZVD_FILIAL    	:= FWxFilial("ZVD")
            ZVD->ZVD_LOTE 	   	:= oCab:GetValue('ZVD_LOTE')
            ZVD->ZVD_COD 	   	:= oGrid:GetValue('ZVD_COD')
            ZVD->ZVD_ITEM    	:= oGrid:GetValue('ZVD_ITEM')
            ZVD->ZVD_LOTE      	:= oGrid:GetValue('ZVD_LOTE')
            ZVD->ZVD_BOV      	:= oGrid:GetValue('ZVD_BOV')
            ZVD->ZVD_IDADE      := oGrid:GetValue('ZVD_IDADE')
            ZVD->ZVD_IDADEP     := oGrid:GetValue('ZVD_IDADEP')
            ZVD->ZVD_CODZ09    	:= oGrid:GetValue('ZVD_CODZ09')
            ZVD->ZVD_ITZ09    	:= oGrid:GetValue('ZVD_ITZ09')
        Else		
            If ZVD->(DbSeek( FWxFilial("ZVD") +;
                    oCab:GetValue('ZVD_COD') +;
                    oGrid:GetValue('ZVD_ITEM')))

                RecLock('ZVD', .F.)
                    ZVD->(DbDelete())
                ZVD->(MsUnlock())
            EndIf
        EndIf 
    Next nI  */

Return
 
/*/{Protheus.doc} AfterTTS
Método acionado após as gravações da transação
@author Atilio
@since 27/01/2023
@version version
@param oModel, Objeto, Objeto instanciado do Modelo de Dados
/*/
 
Method AfterTTS(oModel) Class cFati08
    //Aqui você pode fazer as operações após gravar
    //Exibe uma mensagem, caso não esteja sendo executado via job ou ws
/*     If ! IsBlind()
        ShowLog("Passei pelo Commit de forma nova (FWModelEvent)")
    EndIf */
Return

User Function F08INIT(cCampo)
    Local cRet := ''
    Local aArea := GetArea()
    
    IF cCampo == 'ZVD_DESCP'
        if ZVD->ZVD_IDADE < 36
            cRet :=  "BOVINO " + iif(ALLTRIM( POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_SEXO")) == 'CAPAO','MACHO',ALLTRIM( POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_SEXO"))) +;
                                " DE " + ALLTRIM( STR(POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_IDAINI"))) +;
                                " A "  + ALLTRIM( STR(POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_IDAFIM")))+;
                                " MESES"
        ELSE
            cRet := "BOVINO " + iif(ALLTRIM( POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_SEXO")) == 'CAPAO','MACHO',ALLTRIM( POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_SEXO"))) +;
                    " ACIMA DE " + ALLTRIM( STR(POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_CODZ09+ZVD->ZVD_ITZ09,"Z09_IDAINI"))) +;
                    " MESES"
        ENDIF 
    ELSE
        if ZVD->ZVD_IDADE < 36
        
            cRet :=  "BOVINO " + iif(ALLTRIM( POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_Z09ANT+ZVD->ZVD_9ITANT,"Z09_SEXO")) == 'CAPAO','MACHO',ALLTRIM( POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_Z09ANT+ZVD->ZVD_9ITANT,"Z09_SEXO"))) +;
                                " DE " + ALLTRIM( STR(POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_Z09ANT+ZVD->ZVD_9ITANT,"Z09_IDAINI"))) +;
                                " A "  + ALLTRIM( STR(POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_Z09ANT+ZVD->ZVD_9ITANT,"Z09_IDAFIM")))+;
                                " MESES"
        ELSE
            cRet := "BOVINO " + iif(ALLTRIM( POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_Z09ANT+ZVD->ZVD_9ITANT,"Z09_SEXO")) == 'CAPAO','MACHO',ALLTRIM( POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_Z09ANT+ZVD->ZVD_9ITANT,"Z09_SEXO"))) +;
                    " ACIMA DE " + ALLTRIM( STR(POSICIONE("Z09",1,FWxFilial("Z09")+ZVD->ZVD_Z09ANT+ZVD->ZVD_9ITANT,"Z09_IDAINI"))) +;
                    " MESES"
        ENDIF 
    ENDIF 
    RestArea(aArea)
Return cRet 

Static Function zVldMD()
    Local lRet := .T. 
    Local oModel    := FWModelActive()
	Local oCab     := oModel:GetModel('ZVDMASTER')

    if Empty(oCab:GetValue("ZVD_LOTE"))
        MsgStop("Informe o Lote")
        lRet := .F.
    endif

Return lRet 
