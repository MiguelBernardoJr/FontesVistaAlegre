// #########################################################################################
// Projeto: JRModelos
// Fonte  : JRMOD1
// ---------+------------------------------+------------------------------------------------
// Data     | Autor: JRScatolon            | Descricao: Log de Alteracao da Estrutura de Produtos 
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

User Function VAPCPA15()

Local aArea := GetArea()
Local oBrowse, oTbTmp
Local cQryBrw := ""
Local aBrwTmp := {}
Local aFldBrw := {}
Local aIndBrw := {}

Private aRotina	:= MenuDef()
Private cAlias  := "ZG1"
Private cAlsTmp := CriaTrab(,.F.)
Private cDescri := Posicione("SX2", 1, cAlias, "X2_NOME")
Private aCrrgAb := {.F., .F., .F., .F.,.F., .F., .F.}

DBSelectArea("SX3")
SX3->(DBSetOrder(2)) //X3_CAMPO

SX3->(DBSeek("ZG1_FILIAL"))
AAdd(aFldBrw,{SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
AAdd(aBrwTmp, {X3Titulo(), SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})

SX3->(DBSeek("ZG1_COD"))
AAdd(aFldBrw,{SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
AAdd(aBrwTmp, {X3Titulo(), SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})

SX3->(DBSeek("ZG1_SEQ"))
AAdd(aFldBrw,{SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
AAdd(aBrwTmp, {X3Titulo(), SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})

oTbTmp := FWTemporaryTable():New(cAlsTmp)
oTbTmp:SetFields(aFldBrw)

oTbTmp:AddIndex(cAlsTmp + "1", {"ZG1_FILIAL", "ZG1_COD", "ZG1_SEQ"})
AAdd(aIndBrw, "ZG1_FILIAL+ZG1_COD+ZG1_SEQ")

//------------------
//Criação da tabela
//------------------
oTbTmp:Create()

TCSqlExec(;
			" INSERT INTO " + oTbTmp:GetRealName() + "(ZG1_FILIAL, ZG1_COD, ZG1_SEQ)" +;
            " SELECT ZG1.ZG1_FILIAL, ZG1.ZG1_COD, ZG1.ZG1_SEQ " +;
			" FROM " + RetSqlName("ZG1") + " ZG1 " +;
			" WHERE ZG1.ZG1_FILIAL = '" + xFilial("ZG1") + "' " +;
			"   AND ZG1.D_E_L_E_T_ <> '*' " +;
			" GROUP BY ZG1.ZG1_FILIAL, ZG1.ZG1_COD, ZG1.ZG1_SEQ " +;
			" ORDER BY ZG1.ZG1_FILIAL, ZG1.ZG1_COD, ZG1.ZG1_SEQ " )


oBrowse := FwmBrowse():New()
oBrowse:SetAlias(cAlsTmp)
oBrowse:SetDescription(cDescri)
oBrowse:SetTemporary(.T.)
oBrowse:SetQueryIndex(aIndBrw)
oBrowse:SetFields(aBrwTmp)
oBrowse:DisableDetails()
oBrowse:Activate()

(cAlsTmp)->(DBCloseArea())

If oTbTmp <> Nil
	oTbTmp:Delete()
	oTbTmp := Nil
Endif
	
Return


Static Function MenuDef()

Local aRotina := {} 

//ADD OPTION aRotina TITLE OemToAnsi("Pesquisar")  ACTION "PesqBrw"       	  OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi("Visualizar") ACTION "VIEWDEF.VAPCPA15"    OPERATION 2 ACCESS 0 // "Visualizar"
//ADD OPTION aRotina TITLE OemToAnsi("Incluir")    ACTION "VIEWDEF.VAPCPA15"    OPERATION 3 ACCESS 0 // "Incluir"
//ADD OPTION aRotina TITLE OemToAnsi("Alterar")    ACTION "VIEWDEF.VAPCPA15"    OPERATION 4 ACCESS 0 // "Alterar"
//ADD OPTION aRotina TITLE OemToAnsi("Excluir")    ACTION "VIEWDEF.VAPCPA15"    OPERATION 5 ACCESS 0 // "Excluir" 
//ADD OPTION aRotina TITLE OemToAnsi("Copiar")     ACTION "VIEWDEF.VAPCPA15"    OPERATION 9 ACCESS 0 // "Copiar" 

Return aRotina


Static Function ModelDef()

Local oModel
Local oStrCabc := FWFormStruct(1,"ZG1", {|cCampo| AllTrim(cCampo)+"|" $ "ZG1_FILIAL|ZG1_COD|ZG1_SEQ|"})
Local oStrEstr := FWFormStruct(1,"ZG1")

oModel := MpFormModel():New("U_VAPCPA15", /*bPreValid*/,,,/*Cancel*/) 

//-- campos
oModel:AddFields("MASTER",, oStrCabc,/*bPreValid*/, /*bPosValid*/,)
oModel:AddGrid("GRIDESTR" , "MASTER", oStrEstr , /*bLnVldVl*/,,,,)

oModel:SetRelation("GRIDESTR",{{"ZG1_FILIAL",'xFilial("ZG1")'},{"ZG1_COD", (cAlsTmp)->ZG1_COD},{"ZG1_SEQ",(cAlsTmp)->ZG1_SEQ}},&(cAlias)->(IndexKey(1)))
oModel:SetPrimaryKey({"ZG1_FILIAL", "ZG1_COD", "ZG1_SEQ"})

Return oModel


Static Function ViewDef()

Local oModel := ModelDef()
Local oView 
Local oStrCabc := FWFormStruct(2,"ZG1", {|cCampo| AllTrim(cCampo)+"|" $ "ZG1_FILIAL|ZG1_COD|ZG1_SEQ|"})
Local oStrEstr := FWFormStruct(2,"ZG1")
oView := FwFormView():New()
oView:SetModel(oModel)

//View X Model
oView:AddField("VWCABEC", oStrCabc, "MASTER")
oView:AddGrid("VWESTR", oStrEstr, "GRIDESTR")

oView:CreateHorizontalBox("CABECALHO",20)
oView:CreateHorizontalBox("ESTRUTURA",80)

oView:SetOwnerView("MASTER", "CABECALHO")
oView:SetOwnerView("VWESTR", "ESTRUTURA")

oStrEstr:RemoveField("ZG1_FILIAL")
oStrEstr:RemoveField("ZG1_COD")
oStrEstr:RemoveField("ZG1_SEQ")

Return oView