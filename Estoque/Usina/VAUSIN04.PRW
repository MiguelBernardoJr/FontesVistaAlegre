#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Análise do Tanque Estabilizado"
/*/{Protheus.doc} VAUSIN04
    (long_description)
    @type  Function VAUSIN04
    @author Igor Oliveira
    @since 16/08/2023
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function VAUSIN04()
    Local aArea		:= FWGetArea()
	Local oBrowse
	Private aCTE 	:= {}

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZAL")
	oBrowse:SetOnlyFields({'ZAL_CODIGO','ZAL_HORA','ZAL_DATA','ZAL_TURNO','ZAL_TFERM','ZAL_TALCOL','ZAL_MATSEX','ZAL_PESOL','ZAL_KGM3'})
    oBrowse:SetFilterDefault("ZAL->ZAL_TIPO == '4'")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 		:= nil
	Local oCab   		:= FWFormStruct(1, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_CODIGO|ZAL_HORA|ZAL_TIPO|ZAL_DATA|ZAL_TURNO|ZAL_KGM3|ZAL_TFERM|ZAL_TALCOL|ZAL_MATSEX|ZAL_PESOL" })

	oCab:SetProperty("ZAL_MATSEX", MODEL_FIELD_WHEN, {|| .F.})

	oModel := MPFormModel():New("USIN04M")

	oModel:AddFields("ZALMASTER",/*cOwner*/  ,oCab		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )

	oModel:SetPrimaryKey({"ZAL_FILIAL"+"ZAL_CODIGO"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZALMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	
Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAUSIN04")
	Local oCab   		:= FWFormStruct(2, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_TIPO|ZAL_HORA|ZAL_DATA|ZAL_TURNO|ZAL_KGM3|ZAL_TFERM|ZAL_TALCOL|ZAL_MATSEX|ZAL_PESOL" })
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZAL", oCab  , "ZALMASTER")
    
	oView:CreateHorizontalBox('CABEC', 100 )
	
	oView:SetOwnerView("VIEW_ZAL"	 , "CABEC")
	
	oView:EnableTitleView('VIEW_ZAL'  , cTitulo)
	
	oView:SetCloseOnOk( { |oView| .T. } )
Return oView

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAUSIN04' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VAUSIN04' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VAUSIN04' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VAUSIN04' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRotina
