#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Motivo Sanitario" 

User Function VAESTI04()
    Local aArea   		:= GetArea()
    Local oModel  		:= NIL
	Local cFunBkp 		:= FunName()  

    SetFunName("VAESTI04")

    oModel := FWMBrowse():New()
	oModel:SetAlias( "ZSM" )   
	oModel:SetDescription( cTitulo )
	oModel:Activate()
	
    SetFunName(cFunBkp)
	RestArea(aArea)
Return NIL  

Static Function MenuDef()
	Local aRot := {}
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' 		ACTION 'VIEWDEF.VAESTI04' 			OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    		ACTION 'VIEWDEF.VAESTI04' 			OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    		ACTION 'VIEWDEF.VAESTI04' 			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    		ACTION 'VIEWDEF.VAESTI04' 			OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	//ADD OPTION aRot TITLE 'Copiar'    		ACTION 'VIEWDEF.VAFATI01' 			OPERATION 9						 ACCESS 0 //OPERATION 5
Return aRot

Static Function ModelDef()
	Local oStZSM   := FWFormStruct(1, 'ZSM')
	Local bVldPos  := {|| zVldZSMTab()}
	//Criando o FormModel, adicionando o Cabeçalho e Grid
	oModel := MPFormModel():New("ESTI04M",/*Pre-Validacao*/, bVldPos /*Pos-Validacao*/,/* bVldCom Commit*/,/*Cancel*/)

	oModel:AddFields("ZSMMASTER",/*cOwner*/ ,oStZSM, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )

	oModel:SetPrimaryKey({ })

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZSMMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()
	Local oModel     := FWLoadModel("VAESTI04")
    Local oStZSM     := FWFormStruct(2, "ZSM")
	Local oView      := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_ZSM" , oStZSM  , "ZSMMASTER")
	//Habilitando título
	oView:EnableTitleView('VIEW_ZSM', cTitulo)

    oView:CreateHorizontalBox("SCREEN",100)
	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk( { |oView| .T. } )
	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZSM","SCREEN")

Return oView

Static Function zVldZSMTab()
	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local nOpc      := oModel:GetOperation()
	Local lRet      := .T.

	//Se for InclusÃ£o
	If nOpc == MODEL_OPERATION_INSERT

		if Empty(oModel:GetValue("ZSMMASTER", "ZSM_COD"))
			VaGetX8('ZSM', 'ZSM_COD')
		ENDIF
		
		DbSelectArea('ZSM')
		ZSM->(DbSetOrder(1)) //ZDM_FILIAL + ZDM_CODIGO + ZDM_CODIGO

		//Se conseguir posicionar, tabela jÃ¡ existe
		If ZSM->(DbSeek( xFilial("ZSM") +;
				oModel:GetValue('ZSMMASTER', 'ZSM_COD')))
               // dToS(oModel:GetValue('ZSMMASTER', 'ZSM_DATA'))))
			Aviso('Atenção', 'Esse código de tabela já existe!', {'OK'}, 02)
			lRet := .F.
		EndIf

	EndIf

	RestArea(aArea)
Return lRet

Static Function VaGetX8(cAlias, cCampo)
	Local aArea 	:= GetArea() 
	Local oView		:= FWViewActive()
	Local oModel  	:= FWModelActive()
	Local cCod 		:= ''
	Local lRet		:= .F.
	Local _cQry 	:= ''
	DbSelectArea(cAlias)
	
	_cQry := " select MAX(ZSM_COD) cMAX FROM " + RetSqlName("ZSM") + ""

 	DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(_cQry)), "__TMP", .t., .f.)

	If !__TMP->(Eof())
		cCod := __TMP->cMAX
	EndIF

	if (cCod == StrZero(0, TamSX3(cCampo)[1]))
		cCod := StrZero(1, TamSX3(cCampo)[1])
	else 
		cCod := StrZero(Val(cCod)+1, TamSX3(cCampo)[1])
	ENDIF

	if oModel:SetValue("ZSMMASTER", "ZSM_COD", cCod)
		lRet := .T.
	ENDIF

	oView:Refresh()

	__TMP->(DbCloseArea())
	RestArea(aArea)

RETURN lRet
 