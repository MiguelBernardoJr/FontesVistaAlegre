#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Análise de GL"
/*/{Protheus.doc} VAUSIN07
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
User Function VAUSIN07()
    Local aArea		 := FWGetArea()
	Local oBrowse
	Private aCTE 	 := {}

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZGL")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 		:= nil
    Local oCab   		:= FWFormStruct(1, 'ZGL')

	oModel := MPFormModel():New("USIN07M",,/* bSaveZGL */)

	oModel:AddFields("ZGLMASTER",/*cOwner*/  ,oCab		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	//oModel:AddGrid('ZGLDETAIL', 'ZGLMASTER'	, oGrid, /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,{|| I06LOAD()})

	oModel:SetPrimaryKey({"ZGL_FILIAL"+"ZGL_CODIGO"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZGLMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	
Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAUSIN07")
	Local oCab   		:= FWFormStruct(2, 'ZGL')
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZGL", oCab  , "ZGLMASTER")
    
	oView:CreateHorizontalBox('CABEC', 100 )
	
	oView:SetOwnerView("VIEW_ZGL"	 , "CABEC")
	
	oView:EnableTitleView('VIEW_ZGL'  , cTitulo)
	
	oView:SetCloseOnOk( { |oView| .T. } )
Return oView

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAUSIN07' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VAUSIN07' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VAUSIN07' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VAUSIN07' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 
Return aRotina

