#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Análise Levedo Tanque Circulação"
/*/{Protheus.doc} VAUSIN02
    (long_description)
    @type  Function VAUSIN02
    @author Igor Oliveira
    @since 16/08/2023
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function VAUSIN02()
    Local aArea		:= FWGetArea()
	Local oBrowse
	Private aCTE 	:= {}

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZAL")
	oBrowse:SetOnlyFields({'ZAL_CODIGO','ZAL_HORA','ZAL_DATA','ZAL_TURNO','ZAL_TFERM','ZAL_TALCOL','ZAL_MATSEX','ZAL_PESOF'})
	oBrowse:SetFilterDefault("ZAL->ZAL_TIPO == '2'")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 		:= nil
	Local oCab   		:= FWFormStruct(1, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_CODIGO|ZAL_HORA|ZAL_TIPO|ZAL_DATA|ZAL_TURNO|ZAL_TFERM|ZAL_TALCOL|ZAL_MATSEX|ZAL_PESOF" })
	Local aGatilhos 	:= {}
	Local nI

	oCab:SetProperty("ZAL_MATSEX", MODEL_FIELD_WHEN, {|| .F.})


/*     aAdd(aGatilhos, FWStruTriggger( "ZAL_PESOF"	,"ZAL_MATSEX" ,"",.f.,"",,"100-M->ZAL_PESOF",NIL,"01"))

	For nI := 1 To Len(aGatilhos)
        oCab:AddTrigger(  aGatilhos[nI][01],; //Campo Origem
							aGatilhos[nI][02],; //Campo Destino
							aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
							aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next */

	oModel := MPFormModel():New("USIN02M",,/* bSaveZAL */)

	oModel:AddFields("ZALMASTER",/*cOwner*/  ,oCab		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	//oModel:AddGrid('ZALDETAIL', 'ZALMASTER'	, oGrid, /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,{|| I06LOAD()})

	oModel:SetPrimaryKey({"ZAL_FILIAL"+"ZAL_CODIGO"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZALMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	
Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAUSIN02")
	Local oCab   		:= FWFormStruct(2, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_CODIGO|ZAL_HORA|ZAL_TIPO|ZAL_DATA|ZAL_TURNO|ZAL_TFERM|ZAL_TALCOL|ZAL_MATSEX|ZAL_PESOF" })
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

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAUSIN02' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VAUSIN02' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VAUSIN02' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VAUSIN02' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 
Return aRotina
