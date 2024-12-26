// #########################################################################################
// Projeto: JRModelos
// Fonte  : JRMOD1
// ---------+------------------------------+------------------------------------------------
// Data     | Autor: JRScatolon            | Descricao: Cadastro de Esquipamentos 
// ---------+------------------------------+------------------------------------------------
// aaaammdd | <email>                      | <Descricao da rotina>
//          |                              |  
//          |                              |  
// ---------+------------------------------+------------------------------------------------

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

User Function VAPCPA01()

Local aArea := GetArea()
Local oBrowse
             
Private aRotina	:= MenuDef()
Private cAlias  := "ZV0"
Private cDescri := Posicione("SX2", 1, cAlias, "X2_NOME")

oBrowse := FwmBrowse():New()
oBrowse:SetAlias(cAlias)
oBrowse:SetDescription(cDescri)
oBrowse:Activate()		
	
Return


Static Function MenuDef()

Local aRotina := {} 

ADD OPTION aRotina TITLE OemToAnsi("Pesquisar")  ACTION "PesqBrw"       	  OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi("Visualizar") ACTION "VIEWDEF.VAPCPA01"    OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE OemToAnsi("Incluir")    ACTION "VIEWDEF.VAPCPA01"    OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE OemToAnsi("Alterar")    ACTION "VIEWDEF.VAPCPA01"    OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE OemToAnsi("Excluir")    ACTION "VIEWDEF.VAPCPA01"    OPERATION 5 ACCESS 0 // "Excluir" 
ADD OPTION aRotina TITLE OemToAnsi("Copiar")     ACTION "VIEWDEF.VAPCPA01"    OPERATION 9 ACCESS 0 // "Copiar" 

Return aRotina


Static Function ModelDef()

Local oModel := Nil
Local oField := Nil

oField := FwFormStruct(1,cAlias)
oModel := MpFormModel():New('U_VAPCPA01', /*bPreValid*/,,,/*Cancel*/) 

//-- campos
oModel:AddFields('MdField' + cAlias,,oField,/*bPreValid*/, /*bPosValid*/,)
oModel:SetPrimaryKey({'ZV0_FILIAL','ZV0_CODIGO'})

Return oModel


Static Function ViewDef()

Local oField := FwFormStruct(2,cAlias,,)
Local oModel := FwLoadModel('VAPCPA01')

oView := FwFormView():New()
oView:SetModel(oModel)

//View X Model
oView:AddField('VwField' + cAlias, oField, 'MdField' + cAlias )

//separa��o da tela
oView:CreateHorizontalBox('CABECALHO',100)

//vis�es da tela
oView:SetOwnerView('VwField' + cAlias,'CABECALHO')

Return oView