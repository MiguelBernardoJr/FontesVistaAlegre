#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Análise do Medidor de Etanol"
/*/{Protheus.doc} VAUSIN05
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
User Function VAUSIN05()
    Local aArea		 := FWGetArea()
	Local oBrowse
	Private aCTE 	 := {}

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZAE")
    oBrowse:SetFilterDefault("ZAE->ZAE_TIPO == '1'")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 		:= nil
    Local oCab   		:= FWFormStruct(1, 'ZAE', {|cCampo| !(AllTrim(cCampo) $ "ZAE_TANQUE") })

	oModel := MPFormModel():New("USIN05M",,/* bSaveZAE */)

	oModel:AddFields("ZAEMASTER",/*cOwner*/  ,oCab		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	//oModel:AddGrid('ZAEDETAIL', 'ZAEMASTER'	, oGrid, /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,{|| I06LOAD()})

	oModel:SetPrimaryKey({"ZAE_FILIAL"+"ZAE_CODIGO"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZAEMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	
Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAUSIN05")
	Local oCab   		:= FWFormStruct(2, 'ZAE', {|cCampo| !(AllTrim(cCampo) $ "ZAE_TANQUE")})
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZAE", oCab  , "ZAEMASTER")
    
	oView:CreateHorizontalBox('CABEC', 100 )
	
	oView:SetOwnerView("VIEW_ZAE"	 , "CABEC")
	
	oView:EnableTitleView('VIEW_ZAE'  , cTitulo)
	
	oView:SetCloseOnOk( { |oView| .T. } )
Return oView

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAUSIN05' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VAUSIN05' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VAUSIN05' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VAUSIN05' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 
Return aRotina

User Function US05TIPO()
    Local cRet := ""

    if FunName() == "VAUSIN05" //1 - Análise do Medidor de Etanol
        cRet := "1"
    elseIf FunName() == "VAUSIN06" //2 - Análise do Tanque Depósito de Etanol
        cRet := "2"
    EndIF 
Return cRet 

