//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
 
//Variveis Estaticas
Static cTitulo := "Artistas (com FWModelEvent)"
Static cAliasMVC := "ZD1"
 
/*/{Protheus.doc} User Function zMVC01c
Cadastro de Artistas
@author Daniel Atilio
@since 21/01/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
 
User Function zMVC01c()
    Local aArea   := GetArea()
    Local oBrowse
    Private aRotina := {}
 
    //Definicao do menu
    aRotina := MenuDef()
 
    //Instanciando o browse
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAliasMVC)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()
 
    //Ativa a Browse
    oBrowse:Activate()
 
    RestArea(aArea)
Return Nil
 
/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao zMVC01c
@author Daniel Atilio
@since 21/01/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
 
Static Function MenuDef()
    Local aRotina := {}
 
    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.zMVC01c" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.zMVC01c" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.zMVC01c" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.zMVC01c" OPERATION 5 ACCESS 0
 
Return aRotina
 
/*/{Protheus.doc} ModelDef
Modelo de dados na funcao zMVC01c
@author Daniel Atilio
@since 21/01/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
 
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, cAliasMVC)
    Local oModel
    Local bPre := Nil
    Local bPos := Nil
    Local bCommit := Nil
    Local bCancel := Nil
 
    //Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("zMVC01cM", bPre, bPos, bCommit, bCancel)
    oModel:AddFields("ZD1MASTER", /*cOwner*/, oStruct)
    oModel:SetDescription("Modelo de dados - " + cTitulo)
    oModel:GetModel("ZD1MASTER"):SetDescription( "Dados de - " + cTitulo)
    oModel:SetPrimaryKey({})
 
    //Instala um evento no modelo de dados que irá ficar "observando" as alterações do formulário
    oModel:InstallEvent("VLD_ARTISTA", , zClassArtistas():New(oModel))
Return oModel
 
/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao zMVC01c
@author Daniel Atilio
@since 21/01/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
 
Static Function ViewDef()
    Local oModel := FWLoadModel("zMVC01c")
    Local oStruct := FWFormStruct(2, cAliasMVC)
    Local oView
 
    //Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_ZD1", oStruct, "ZD1MASTER")
    oView:CreateHorizontalBox("TELA" , 100 )
    oView:SetOwnerView("VIEW_ZD1", "TELA")
 
Return oView

