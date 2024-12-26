// #########################################################################################
// Projeto: JRModelos
// Fonte  : JRMOD1
// ---------+------------------------------+------------------------------------------------
// Data     | Autor: JRScatolon            | Descricao: Cadastro de Nota de Manejo
// ---------+------------------------------+------------------------------------------------
// aaaammdd | <email>                      | <Descricao da rotina>
//          |                              |  
//          |                              |  
// ---------+------------------------------+------------------------------------------------

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

User Function VAPCPA02()

Local aArea := GetArea()
Local oBrowse
             
Private aRotina	:= MenuDef()
Private cAlias  := "Z0G"
Private cDescri := Posicione("SX2", 1, cAlias, "X2_NOME")


DbSelectArea("Z0G")
DbsetOrder(1) // Z0G_FILIAL+Z0G_CODIGO+Z0G_DISPON

DbSelectArea("SB1")
DbSetOrder(1) // B1_FILIAL+B1_COD

oBrowse := FwmBrowse():New()
oBrowse:SetAlias(cAlias)
oBrowse:SetDescription(cDescri)
oBrowse:Activate()		
	
Return


Static Function MenuDef()

Local aRotina := {} 

ADD OPTION aRotina TITLE OemToAnsi("Pesquisar")  ACTION "PesqBrw"       	  OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi("Visualizar") ACTION "VIEWDEF.VAPCPA02"    OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE OemToAnsi("Incluir")    ACTION "VIEWDEF.VAPCPA02"    OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE OemToAnsi("Alterar")    ACTION "VIEWDEF.VAPCPA02"    OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE OemToAnsi("Excluir")    ACTION "VIEWDEF.VAPCPA02"    OPERATION 5 ACCESS 0 // "Excluir" 
ADD OPTION aRotina TITLE OemToAnsi("Copiar")     ACTION "VIEWDEF.VAPCPA02"    OPERATION 9 ACCESS 0 // "Copiar" 

Return aRotina


Static Function ModelDef()

Local oModel := Nil
Local oField := Nil

oField := FwFormStruct(1,cAlias)
oModel := MpFormModel():New("U_VAPCPA02", /*bPreValid*/,,,/*Cancel*/) 

//-- campos
oModel:AddFields("MdField" + cAlias,,oField,/*bPreValid*/, /*bPosValid*/,)
oModel:SetPrimaryKey({"Z0G_FILIAL", "Z0G_CODIGO"})

Return oModel


Static Function ViewDef()

Local oField := FwFormStruct(2,cAlias,,)
Local oModel := FwLoadModel("VAPCPA02")

oView := FwFormView():New()
oView:SetModel(oModel)

//View X Model
oView:AddField("VwField" + cAlias, oField, "MdField" + cAlias )

//separaï¿½ï¿½o da tela
oView:CreateHorizontalBox("CABECALHO", 100)

//visoes da tela
oView:SetOwnerView("VwField" + cAlias, "CABECALHO")

Return oView


User Function VLDNTDSP()

Local oMdlAt  := FWModelActive()
Local lVldNtPrd := .T.

DBSelectArea("Z0G")
Z0G->(DBSetOrder(1))

If (Z0G->(DBSeek(FWxFilial("Z0G") + oMdlAt:GetValue("MdField" + cAlias, "Z0G_CODIGO") + oMdlAt:GetValue("MdField" + cAlias, "Z0G_DISPON"))))
	MsgInfo("Nota ja cadastrada no periodo selecionado.")
	lVldNtPrd := .F.
EndIf
Return (lVldNtPrd)


user function vpcp02vl()
local lRet := .t. 

    if Empty(M->Z0G_DIETA)
        Help(,, "Dieta Inválida",, "O campo Dieta é obrigatório.", 1, 0,,,,,, {"Por favor digite uma dieta válida ou selecione." + CRLF + "<F3 Disponível>."})
        lRet := .f.
    elseif !SB1->(DbSeek(FWxFilial("SB1")+M->Z0G_DIETA)) .or. SB1->B1_X_TRATO!='1'
        Help(,, "Dieta Inválida",, "O código digitado não pertence a um produto válido ou esse produto não é uma dieta.", 1, 0,,,,,, {"Por favor digite uma dieta válida ou selecione." + CRLF + "<F3 Disponível>."})
        lRet := .f.
    endif


return lRet
