#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Preço M.S da Levedura"
/*/{Protheus.doc} VAUSIN09
    (long_description)
    @type  Function VAUSIN09
    @author Igor Oliveira
    @since 16/08/2023
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function VAUSIN09()
    Local aArea		:= FWGetArea()
	Local oBrowse
	Private aCTE 	:= {}

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZML")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 		:= nil
	Local oCab   		:= FWFormStruct(1, 'ZML', {|cCampo| AllTrim(cCampo) $ "ZML_FILIAL|ZML_COD|ZML_FORNEC|ZML_NOME|ZML_LOJA|ZML_DATAD|ZML_DATAF" })
	Local oGrid   		:= FWFormStruct(1, 'ZML', {|cCampo| AllTrim(cCampo) $ "ZML_FERM|ZML_TONMS" })
    Local aZMLRel       := {}
    
	oModel := MPFormModel():New("USIN09M",,/* bSaveZML */)

	oModel:AddFields("ZMLMASTER",/*cOwner*/  ,oCab		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddGrid('ZMLDETAIL', 'ZMLMASTER'	, oGrid, /*bLinePre*/, /*bLinePos*/{|| VldLinha()},/* bPre */,/* bPos */,{|| LoadGrid()})
	
	aAdd(aZMLRel, {'ZML_FILIAL', 'Iif(!INCLUI, ZML->ZML_FILIAL, FWxFilial("ZML"))'} )
	aAdd(aZMLRel, {'ZML_COD', 'Iif(!INCLUI, ZML->ZML_COD , ZML->ZML_COD)'             } )
	
	//Criando o relacionamento
	oModel:SetRelation('ZMLDETAIL', aZMLRel, ZML->(IndexKey(2)))
	oModel:SetPrimaryKey({"ZML_FILIAL"+"ZML_COD"+"ZML_FERM"})

	oGrid:SetProperty('ZML_FERM', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID,   'U_N09FVAL()'))//Validação de Campo

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZMLMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	
Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAUSIN09")
    Local oCab   		:= FWFormStruct(2, 'ZML', {|cCampo| AllTrim(cCampo) $ "ZML_FILIAL|ZML_COD|ZML_NOME|ZML_FORNEC|ZML_LOJA|ZML_DATAD|ZML_DATAF" })
	Local oGrid   		:= FWFormStruct(2, 'ZML', {|cCampo| AllTrim(cCampo) $ "ZML_FERM|ZML_TONMS" })
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZML", oCab  , "ZMLMASTER")
	oView:AddGrid("GRID_ZML", oGrid  , "ZMLDETAIL")
    
	oView:CreateHorizontalBox('CABEC', 30 )
	oView:CreateHorizontalBox('GRID', 70 )
	
	oView:SetOwnerView("VIEW_ZML"	 , "CABEC")
	oView:SetOwnerView("GRID_ZML"	 , "GRID")
	
	oView:EnableTitleView('VIEW_ZML'  , cTitulo)
	oView:EnableTitleView('VIEW_ZML'  , "Itens")
	
	oView:SetCloseOnOk( { |oView| .T. } )
Return oView

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAUSIN09' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VAUSIN09' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VAUSIN09' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VAUSIN09' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 
Return aRotina

Static Function VldLinha()
    Local oModel     := FWModelActive()
    Local oGrid      := oModel:GetModel("ZMLDETAIL")
    Local lRet       := .T. 
    Local aSaveLines := FWSaveRows()

    if oGrid:GetValue("ZML_FERM") == 0
        lRet := .F. 
        oModel:SetErrorMessage("","","","","Valor Inválida", 'Valor do campo Fermento não pode ser zero: ' + StrZero(oGrid:GetLine(),2) + '', "") 
    elseif oGrid:GetValue("ZML_TONMS") == 0
        lRet := .F.
        oModel:SetErrorMessage("","","","","Valor Inválida", 'Valor do campo Tonenalada não pode ser zero: ' + StrZero(oGrid:GetLine(),2) + '', "") 
    endif 
    FWRestRows( aSaveLines )
Return lRet

User Function N09FVAL()
    Local oModel     := FWModelActive()
    Local oGrid      := oModel:GetModel("ZMLDETAIL")
    Local nI    
    Local nTamTot
    Local lRet       := .T. 
    Local nValor     := oGrid:GetValue("ZML_FERM")
    Local aSaveLines := FWSaveRows()

    nTamTot := oGrid:GetQtdLine()
    For nI := 1 to nTamTot - 1
        oGrid:GoLine(nI)
        if nValor == oGrid:GetValue("ZML_FERM")
            lRet := .F. 
            oModel:SetErrorMessage("","","","","Valor Inválida", 'Valor já está inserido na grid na linha: ' + StrZero(nI,2) + '', "") 
            exit
        endif
    Next nI

    FWRestRows( aSaveLines )
Return lRet

Static Function LoadGrid()
    Local aArea := GetArea()
    Local cQry  := ""
    Local aRet  := {}
    Local nI    := 1

    cQry := "SELECT  " + CRLF 
    cQry += " * FROM "+RetSqlName("ZML")+" " + CRLF 
    cQry += " WHERE ZML_FILIAL = '"+ZML->ZML_FILIAL+"' " + CRLF 
    cQry += " AND ZML_COD = '"+ZML->ZML_COD+"' " + CRLF 
    cQry += " AND D_E_L_E_T_ = ''  " + CRLF 

    MpSysOpenQuery(cQry,"TMP")

	While !TMP->(EOF())
        aAdd(aRet,{nI,{  TMP->ZML_FERM,;
                         TMP->ZML_TONMS}})
        nI += 1 
        TMP->(DBSKIP())
    End
    
    if Len(aRet) == 0
        aAdd(aRet,{ 1,{ 0,;
                        0}})
    EndIf

    TMP->(DBCLOSEAREA())
    
    RestArea(aArea)
Return aRet
