// #########################################################################################
// Projeto: JRModelos
// Fonte  : JRMOD1
// ---------+------------------------------+------------------------------------------------
// Data     | Autor: JRScatolon            | Descricao: Cadastro de Indice de Massa Seca
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

User Function VAPCPA03()
Local oBrwIMS
             
Private aRotina	:= MenuDef()
Private cAlias  := "Z0H"
Private cDescri := Posicione("SX2", 1, cAlias, "X2_NOME")

oBrwIMS := FwmBrowse():New()
oBrwIMS:SetAlias(cAlias)
oBrwIMS:SetDescription(cDescri)
oBrwIMS:Activate()

Return


Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE OemToAnsi("Pesquisar")  ACTION "PesqBrw"       	  OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi("Visualizar") ACTION "VIEWDEF.VAPCPA03"    OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE OemToAnsi("Incluir")    ACTION "VIEWDEF.VAPCPA03"    OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE OemToAnsi("Alterar")    ACTION "U_BTNALTIM"    OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE OemToAnsi("Excluir")    ACTION "VIEWDEF.VAPCPA03"    OPERATION 5 ACCESS 0 // "Excluir"
ADD OPTION aRotina TITLE OemToAnsi("Copiar")     ACTION "VIEWDEF.VAPCPA03"    OPERATION 9 ACCESS 0 // "Copiar"

Return aRotina


User Function BTNALTIM()

//O array aEnableButtons tem por padrÃ£o 14 posicoes:
//1 - Copiar, 2 - Recortar, 3 - Colar, 4 - Calculadora, 5 - Spool, 6 - Imprimir, 7 - Confirmar, 8 - Cancelar, 9 - WalkTrhough, 10 - Ambiente, 11 - Mashup, 12 - Help, 13 - Formulario HTML, 14 - ECM

Local aEnButt := {{.F., NIL},{.F., NIL},{.F., NIL},{.F., NIL},{.F., NIL},{.F., NIL},{.T., "Salvar"},{.T., "Sair"},{.F., NIL},{.F., NIL},{.F., NIL},{.T., NIL},{.F., NIL},{.F., NIL}}

If (Z0H->Z0H_VALEND != "1")

	FWExecView(cDescri, 'VAPCPA03', MODEL_OPERATION_UPDATE, , { || .T. },,, aEnButt)

Else

	MsgInfo("Não é possível alterar um item que está marcado como 'Valendo'.")

EndIf

Return (Nil) 


Static Function ModelDef()

Local oModel := Nil
Local oField := Nil

oField := FwFormStruct(1,cAlias)
oModel := MpFormModel():New("U_VAPCPA03", /*bPreValid*/,,,/*Cancel*/)

//-- campos
oModel:AddFields("MdField" + cAlias,,oField,/*bPreValid*/, /*bPosValid*/,)
oModel:SetPrimaryKey({"Z0H_FILIAL", "Z0H_CODIGO"})

Return oModel


Static Function ViewDef()

Local oField := FwFormStruct(2,cAlias,,)
Local oModel := FwLoadModel("VAPCPA03")

oView := FwFormView():New()
oView:SetModel(oModel)

//View X Model
oView:AddField("VwField" + cAlias, oField, "MdField" + cAlias)

//separacao da tela
oView:CreateHorizontalBox("CABECALHO", 100)

//visoes da tela
oView:SetOwnerView("VwField" + cAlias, "CABECALHO")

Return oView


User Function VLDDTHRP()
Local oMdlAt  := FWModelActive()
Local lVldDtHrP := .T.

DBSelectArea("Z0H")
Z0H->(DBSetOrder(1)) // 

if !Empty(oMdlAt:GetValue("MdField" + cAlias, "Z0H_DATA")) .and. !Empty(oMdlAt:GetValue("MdField" + cAlias, "Z0H_HORA")) .and. !Empty(oMdlAt:GetValue("MdField" + cAlias, "Z0H_PRODUT"))
    If (Z0H->(DBSeek(xFilial("Z0H") + DTOS(oMdlAt:GetValue("MdField" + cAlias, "Z0H_DATA")) + oMdlAt:GetValue("MdField" + cAlias, "Z0H_HORA") + oMdlAt:GetValue("MdField" + cAlias, "Z0H_PRODUT"))))
	    Help(/*Descontinuado*/,/*Descontinuado*/,"PRODUTO JA CADASTRADO",/**/,"Produto ja cadastrado na data e hora selecionados.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, para alterar o indice de materia seca use a opção alterar." })
	    lVldDtHrP := .F.
    EndIf
endif
Return (lVldDtHrP)


Static Function GRVDTHR()

Local lVldGDH := .T.

//RecLock("Z0H", .F.)
M->Z0H_DATLOG := Date()
M->Z0H_HORLOG := SUBSTR(TIME(), 1, 5) 
//MsUnlock()

Return (lVldGDH)


User Function VLDDATMS()

Local lVldDat := .T.

If (M->Z0H_DATA > Date())
	Help(/*Descontinuado*/,/*Descontinuado*/,"DATA DE MEDICAÇÃO",/**/,"Data de medição inválida.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, digite uma data de medição menor ou igual a data de hoje." })
	lVldDat := .F.
EndIf

Return (lVldDat)


User Function VLDHORMS()

Local lVldHor := .T.
Local cHor    := SUBSTR(M->Z0H_HORA, 1, 2)
Local cMin    := SUBSTR(M->Z0H_HORA, 4, 2)
Local cHorAux := SUBSTR(Time(), 1, 2)
Local cMinAux := SUBSTR(Time(), 4, 2)

If ((cHor < "00") .OR. (cHor > "23") .OR. (Date() = M->Z0H_DATA .AND. cHor > cHorAux))
	lVldHor := .F.
EndIf

If ((cMin < "00") .OR. (cMin > "59") .OR. (Date() = M->Z0H_DATA .AND. cHor = cHorAux .AND. cMin > cMinAux))
	lVldHor := .F.
EndIf

If !(lVldHor)
	Help(/*Descontinuado*/,/*Descontinuado*/,"HORA DA MEDIÇÃO",/**/,"Valor da hora inválido.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, revise o valor do campo." })
EndIf

Return (lVldHor)