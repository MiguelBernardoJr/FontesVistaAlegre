#include "totvs.ch"
#include "fwmvcdef.ch"

/****************************************
*****************************************
                                         
Browse Principal

*****************************************
****************************************/
user function VAMVCZV0()
	private oBrowse := FwMBrowse():New()
	
	oBrowse:setAlias("ZV0")
	oBrowse:setDescription("Cadastro de Equipamentos")
	
	oBrowse:addLegend("ZV0->ZV0_STATUS=='A'","GREEN","Ativo")
	oBrowse:addLegend("ZV0->ZV0_STATUS=='I'","RED"  ,"Inativo")
	oBrowse:addLegend("ZV0->ZV0_STATUS=='M'","BLUE" ,"Manutencao")
	
	oBrowse:setWalkThru(.T.)
	
	oBrowse:DisableDetails()
	
	//oBrowse:setFilterDefault(" <filtro em ADVPL> ")
	oBrowse:Activate()
return                                        


/****************************************
*****************************************
                                         
Menu da Rotina

*****************************************
****************************************/
static function MenuDef()
	local aMenu := {}
	
	ADD OPTION aMenu TITLE 'PESQUISAR'	ACTION 'PesqBrw'				OPERATION 1 ACCESS 0
	ADD OPTION aMenu TITLE 'Visualizar'	ACTION 'VIEWDEF.VAMVCZV0'		OPERATION 2 ACCESS 0
	ADD OPTION aMenu TITLE 'Incluir'	ACTION 'VIEWDEF.VAMVCZV0'		OPERATION 3 ACCESS 0
	ADD OPTION aMenu TITLE 'Alterar'	ACTION 'VIEWDEF.VAMVCZV0'		OPERATION 4 ACCESS 0
	ADD OPTION aMenu TITLE 'Excluir'	ACTION 'VIEWDEF.VAMVCZV0'		OPERATION 5 ACCESS 0
	ADD OPTION aMenu TITLE 'Imprimir'	ACTION 'VIEWDEF.VAMVCZV0'		OPERATION 8 ACCESS 0
	ADD OPTION aMenu TITLE 'Copiar'		ACTION 'VIEWDEF.VAMVCZV0'		OPERATION 9 ACCESS 0
	
return (aMenu)                           

/****************************************
*****************************************
                                         
Modelo de dados

*****************************************
****************************************/
static function ModelDef()
	local oStruct := FwFormStruct(1,"ZV0")
	local oModel
	
	oModel := MpFormModel():new("MDLZV0",/*Pre-validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	
	oModel:AddFields("MD_FLD_MVCZV0",/* cOwner*/,oStruct,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:SetPrimaryKey( { "ZV0_FILIAL", "ZV0_CODIGO" } )
	oModel:SetDescription("Cadastro de Equipamentos")
	
	oModel:GetModel("MD_FLD_MVCZV0"):SetDescription("Cadastro de Equipamentos")
return oModel

/****************************************
*****************************************
                                         
View

*****************************************
****************************************/
static function ViewDef()
	local oStruct := FwFormStruct(2,"ZV0")
	local oModel  := FWLoadModel("VAMVCZV0")
	local oView   := FwFormView():New()
	
	oView:SetModel(oModel)
	
	oView:AddField("VW_FLD_MVCZV0", oStruct, "MD_FLD_MVCZV0")
	oView:CreateHorizontalBox("ID_HBOX",100)
	
	oView:setOwnerView("VW_FLD_MVCZV0","ID_HBOX")
return oView