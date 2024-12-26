// #########################################################################################
// Projeto: Trato
// Fonte  : vapcpa10
// ---------+------------------------------+------------------------------------------------
// Data     | Autor: JRScatolon            | Descrição
// ---------+------------------------------+------------------------------------------------
// 20190227 | jrscatolon@jrscatolon.com.br | Planejamento de Fábrica 
//          |                              |  
//          |                              |  
// ---------+------------------------------+------------------------------------------------
//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
/*/{Protheus.doc} vapcpa10
Planejamento da Fábrica de Ração
@author André Cruz
@since 27/02/2019
@version 1.0
/*/
 
user function vapcpa10()
local oBrowse 

    DbSelectArea("SB1")
    DbSetOrder(1) // B1_FILIAL+B1_COD

    DbSelectArea("ZV0")
    DbSetOrder(1) // ZV0_FILIAL+ZV0_CODIGO

    DbSelectArea("Z0J")
    DbSetOrder(1) // Z0J_FILIAL+Z0J_DATA+Z0J_VERSAO+Z0J_EQUIPA+Z0J_PRODUT

    DbSelectArea("Z0K")
    DbSetOrder(1) // Z0K_FILIAL+Z0K_DATA+Z0K_VERSAO

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("Z0K")
    oBrowse:SetDescription("Programação de Fábrica")
    oBrowse:Activate()
     
return nil
 
static function MenuDef()
local aRot := {}

    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar'   ACTION 'VIEWDEF.vapcpa10'   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'      ACTION 'VIEWDEF.vapcpa10'   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'      ACTION 'VIEWDEF.vapcpa10'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Criar Versao' ACTION 'VIEWDEF.u_vpcp10vr' OPERATION 9                      ACCESS 0 //OPERATION 9
    ADD OPTION aRot TITLE 'Excluir'      ACTION 'VIEWDEF.vapcpa10'   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
return aRot
 
static function ModelDef()
local oModel  := nil
local oStrZ0K := FWFormStruct(1, 'Z0K')
local oStrZ0J := FWFormStruct(1, 'Z0J')
local aRelation := {}
local oEvent := vapcp10Evt():New()

    oModel := MPFormModel():New('MDVAPCPA10')
    oModel:AddFields('MdFieldZ0K',/*cOwner*/,oStrZ0K)
    oModel:AddGrid('MdGridZ0J','MdFieldZ0K',oStrZ0J,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPos*/,/*bLoad*/)

    AAdd(aRelation, {'Z0J_FILIAL', 'FWxFilial("Z0J")'} )
    AAdd(aRelation, {'Z0J_DATA',   'Z0K_DATA'}) 
    AAdd(aRelation, {'Z0J_VERSAO', 'Z0K_VERSAO'}) 

    oModel:SetRelation('MdGridZ0J', aRelation, Z0J->(IndexKey(1)))
    // oModel:GetModel('MdGridZ0J'):SetUniqueLine({'Z0J_EQUIPA','Z0J_PRODUT'})
    oModel:SetPrimaryKey({'Z0J_FILIAL', 'Z0J_DATA', 'Z0J_VERSAO', 'Z0J_EQUIPA'})

    oModel:SetDescription("Programação de Fábrica")
    oModel:GetModel('MdFieldZ0K'):SetDescription('Data e Programação')
    oModel:GetModel('MdGridZ0J'):SetDescription('Equipamentos')
    
    oModel:InstallEvent("vapcp10Evt",,oEvent)
return oModel
 
static function ViewDef()
local oView   := nil
local oModel  := nil
local oStrZ0K := nil
local oStrZ0J := nil

    oModel  := FWLoadModel('vapcpa10')

        oStrZ0K := FWFormStruct(2, 'Z0K')
        oStrZ0J := FWFormStruct(2, 'Z0J')
        
        oView := FWFormView():New()
        oView:SetModel(oModel)
        
        oView:AddField('VwFiledZ0K',oStrZ0K,'MdFieldZ0K')
        oView:AddGrid('VwGridZ0J',oStrZ0J,'MdGridZ0J')
        
        oView:CreateHorizontalBox('TOP', 40)
        oView:CreateHorizontalBox('CENTER', 60)
        
        oView:SetOwnerView('VwFiledZ0K','TOP')
        oView:SetOwnerView('VwGridZ0J','CENTER')
        
        oView:EnableTitleView('VwFiledZ0K','Data e Programação')
        oView:EnableTitleView('VwGridZ0J','Equipamentos')
        
        oStrZ0J:RemoveField("Z0J_DATA")
        oStrZ0J:RemoveField("Z0J_VERSAO")

return oView

user function vpcp10vl()
local aArea := GetArea()
local aAreaZ0K := Z0K->(GetArea())
local lRet := .t.
local cVar := ReadVar()
local oModel := FwModelActive()

if oModel:GetOperation() == MODEL_OPERATION_INSERT 
    if "M->Z0K_DATA"$cVar
        DbSelectArea("Z0K")
        DbSetOrder(1) // 
        if Z0K->(DbSeek(FWxFilial("Z0K")+DToS(M->Z0K_DATA)))
            Help(/*Descontinuado*/,/*Descontinuado*/,"PROGRAMAÇÃO JÁ EXISTE",/**/,"Já existe programação para a fábrica nessa data.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, digite uma data em que não exista programação." })
            lRet := .f.
        endif
    endif
endif
if "M->Z0J_EQUIPA"$cVar
    if !ZV0->(DbSeek(FWxFilial("ZV0")+M->Z0J_EQUIPA))
        Help(/*Descontinuado*/,/*Descontinuado*/,"EQUIPAMENTO NÃO ENCONTRADO",/**/,"Não foi encontrado o equipamento digitado no cadastro de equipamentos.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, digite um código de equipamento válido ou selecione um." + CRLF + "<F3 Disponível>"})
        lRet := .f.
    elseif ZV0->ZV0_TIPO <> '1'
        Help(/*Descontinuado*/,/*Descontinuado*/,"EQUIPAMENTO NÃO É BALANÇA",/**/,"O equipamento digitado não é do tipo balança.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, digite um código de equipamento válido ou selecione um." + CRLF + "<F3 Disponível>"})
        lRet := .f.
    endif
elseif "M->Z0J_PRODUT"$cVar
    if !SB1->(DbSeek(FWxFilial("SB1")+M->Z0J_PRODUT))
        Help(/*Descontinuado*/,/*Descontinuado*/,"PRODUTO NÃO ENCONTRADO",/**/,"Não foi encontrado o produto digitado no cadastro de produtos.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, digite um código de produto válido ou selecione um." + CRLF + "<F3 Disponível>"})
        lRet := .f.
    elseif SB1->B1_GRUPO <> '03'
        Help(/*Descontinuado*/,/*Descontinuado*/,"PODUTO NÃO É ",/**/,"O equipamento digitado não é do tipo " + AllTrim(Posicione("SBM", 1, FWxFilial("SBM")+SB1->B1_GRUPO,"BM_DESC")) + ".", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, digite um código de produto válido ou selecione um." + CRLF + "<F3 Disponível>"})
        lRet := .f.
    endif
endif

Z0K->(RestArea(aAreaZ0K))
RestArea(aArea)
return lRet

user function vpcp10vr()
local aArea := GetArea()
local oModel, oFieldModel

if Z0K->Z0K_LOCK == '2'
    __lCopia := .t.
    oModel := FWLoadModel("vapcpa10")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate(.t.)

    oFieldModel := oModel:GetModel("MdFieldZ0K")
    oFieldModel:SetValue("Z0K_VERSAO", Versao( oFieldModel:GetValue("Z0K_DATA") ))

    FWExecView( "Programação de Fábrica" , "vapvpa10", MODEL_OPERATION_INSERT, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )

    oModel:DeActivate()
    __lCopia := .F.
    
elseif Z0K->Z0K_LOCK == '0'
    Help(/*Descontinuado*/,/*Descontinuado*/,"PROGRAMAÇÃO ABERTA",/**/,"A programação para a data " + DToS(Z0K->Z0K_DATA) + " está aberta. O versionamento é permitido apenas para programações que tenham gerado arquivos de programação para os Equipamentos e não tenham sido encerradas.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Não é possivel versionar a programação." })
elseif Z0K->Z0K_LOCK == '1'
    Help(/*Descontinuado*/,/*Descontinuado*/,"PROGRAMAÇÃO EM USO",/**/,"A programação para a data " + DToS(Z0K->Z0K_DATA) + " está em uso por outro usuário. O versionamento é permitido apenas para programações que tenham gerado arquivos de programação para os Equipamentos e não tenham sido encerradas.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Não é possivel versionar a programação." })
elseif Z0K->Z0K_LOCK == '3'
    Help(/*Descontinuado*/,/*Descontinuado*/,"PROGRAMAÇÃO ENCERRADA",/**/,"A programação para a data " + DToS(Z0K->Z0K_DATA) + " já foi encerrada. O versionamento é permitido apenas para programações que tenham gerado arquivos de programação para os Equipamentos e não tenham sido encerradas.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Não é possivel versionar a programação." })
endif


if!Empty(aArea)
    RestArea(aArea)
endif
return nil

static function Versao(dDataProg)
local aArea := GetArea()
local cVersao := StrZero(1, TamSX3("Z0K_VERSAO"[1]))

DbUseArea(.t., "TOPCONN", TcGenQry(,,;
           " select max(Z0K_VERSAO) Z0K_VERSAO" +;
             " from " + RetSqlName("Z0K") + " Z0K" +;
            " where Z0K.Z0K_FILIAL = '" + FWxFilial("Z0K") + "'" +;
              " and Z0K.Z0K_DATA   = '" + DToS("Z0K_DATA") + "'" +;
              " and Z0K.D_E_L_E_T_ = ' '" ;
                                     ), "VERZ0K", .f., .f.)

    if !VERZ0K->(Eof())
        cVersao := Soma1(VERZ0K->Z0K_VERSAO)
    endif

VERZ0K->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif
return cVersao

class vapcp10Evt from FWmodelEvent
    method New()
    method Activate(oModel, lCopy) // quando ocorrer a ativação do Model.
    method VldActivate(oModel, cModelId)
    method After(oSubModel, cModelId, cAlias, lNewRecord)
end class

method New() class vapcp10Evt
return self

method Activate(oModel, lCopy) class vapcp10Evt

    if Z0K->Z0K_LOCK == '0'
        RecLock("Z0K", .f.)
            Z0K->Z0K_LOCK := '1'
        MsUnlock()
    endif

return nil
 
method After(oSubModel, cModelId, cAlias, lNewRecord) class vapcp10Evt

    if Z0K->Z0K_LOCK == '1'
        RecLock("Z0K", .f.)
            Z0K->Z0K_LOCK := '0'
        MsUnlock()
    endif

return nil

method VldActivate(oModel, cModelId) class vapcp10Evt
local lRet := .t.

    if oModel:GetOperation() == MODEL_OPERATION_UPDATE 
        if Z0K->Z0K_LOCK == '1'
            Help(/*Descontinuado*/,/*Descontinuado*/,"PROGRAMAÇÃO EM USO",/**/,"A programação para a data " + DToS(Z0K->Z0K_DATA) + " está em uso por outro usuário.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Não é possivel alterar a programação." })
            lRet := .f.
        elseif Z0K->Z0K_LOCK == '2'
            Help(/*Descontinuado*/,/*Descontinuado*/,"PROGRAMAÇÃO GERADA",/**/,"A programação para a data " + DToS(Z0K->Z0K_DATA) + " já foi gerada.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, para alterar esse programação crie uma nova versao." })
            lRet := .f.
        elseif Z0K->Z0K_LOCK == '3'
            Help(/*Descontinuado*/,/*Descontinuado*/,"PROGRAMAÇÃO ENCERRADA",/**/,"A programação para a data " + DToS(Z0K->Z0K_DATA) + " já foi encerrada.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Não é possivel alterar a programação." })
            lRet := .f.
        endif
    elseif oModel:GetOperation() == 9
        if Z0K->Z0K_LOCK == '0'
            Help(/*Descontinuado*/,/*Descontinuado*/,"PROGRAMAÇÃO ABERTA",/**/,"A programação para a data " + DToS(Z0K->Z0K_DATA) + " está aberta. O versionamento é permitido apenas para programações que tenham gerado arquivos de programação para os Equipamentos e não tenham sido encerradas.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Não é possivel versionar a programação." })
            lRet := .f.
        elseif Z0K->Z0K_LOCK == '1'
            Help(/*Descontinuado*/,/*Descontinuado*/,"PROGRAMAÇÃO EM USO",/**/,"A programação para a data " + DToS(Z0K->Z0K_DATA) + " está em uso por outro usuário. O versionamento é permitido apenas para programações que tenham gerado arquivos de programação para os Equipamentos e não tenham sido encerradas.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Não é possivel versionar a programação." })
            lRet := .f.
        elseif Z0K->Z0K_LOCK == '3'
            Help(/*Descontinuado*/,/*Descontinuado*/,"PROGRAMAÇÃO ENCERRADA",/**/,"A programação para a data " + DToS(Z0K->Z0K_DATA) + " já foi encerrada. O versionamento é permitido apenas para programações que tenham gerado arquivos de programação para os Equipamentos e não tenham sido encerradas.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Não é possivel versionar a programação." })
            lRet := .f.
        endif

    endif

return lRet

user function CriaPrgF(cEquip)
    
return nil