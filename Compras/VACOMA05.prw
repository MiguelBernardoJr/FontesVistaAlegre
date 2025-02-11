#include 'Protheus.ch'
#include 'ParmType.ch'
#include "FwMBrowse.ch"
#include "FwMVCDef.ch"

user function vacoma05()
local oBrowse := nil
local cAlias := "Z0A"
private cTitulo := AllTrim(Posicione("SX2", 1, cAlias, "X2_NOME")) 
private aRotina := MenuDef()
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAlias)
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()
	
return nil

/*/{Protheus.doc}ModelDef
     Cria o modelo de dados MVC para a rotina vacoma05
@since 20170328
@author jrscatolon
@return Objeto, Objeto do tipo FWFormStruct   
/*/
static function ModelDef()
local oModel := Nil                        //Criação do objeto do modelo de dados
local b_Commit := {|oMdl| Z0ACommit(oMdl)} //Bloco de Código do Commit do Modelo
local b_Pos := {|oMdl| Z0AValid(oMdl)}     //Bloco de Código do Commit do Modelo
local oStZ0A := FWFormStruct(1, "Z0A")     //Criação da estrutura de dados utilizada na interface
	
	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("COMA05M",/*bPre*/, b_Pos, b_Commit ,/*bCancel*/) 
	
	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMZ0A",/*cOwner*/,oStZ0A)
	
	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({"Z0A_FILIAL", "Z0A_SEQ", "Z0A_USERID"})
	
	//Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)
	
	//Setando a descrição do formulário
	oModel:GetModel("FORMZ0A"):SetDescription(cTitulo)

return oModel

/*/{Protheus.doc}ViewDef
    Cria da visão MVC para a rotina vacoma05.
@since 20170328
@author jrscatolon
@return Objeto, Objeto do tipo FWFormView   
/*/
static function ViewDef()
local oModel := FWLoadModel("VACOMA05")  //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
local oStZ0A := FWFormStruct(2, "Z0A")  //Criação da estrutura de dados utilizada na interface do cadastro de Autor. Pode-se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
local oView := Nil //Criando oView como nulo

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formulários para interface
	oView:AddField("VIEW_Z0A", oStZ0A, "FORMZ0A")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA", 100)
	
	//Colocando título do formulário
	oView:EnableTitleView('VIEW_Z0A', cTitulo )  
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_Z0A", "TELA")
Return oView

static function MenuDef()
local aRotina := {}
	
	//Adicionando opções
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VACOMA05' OPERATION  2 ACCESS 0 //MODEL_OPERATION_VIEW   
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VACOMA05' OPERATION  3 ACCESS 0 //MODEL_OPERATION_INSERT 
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VACOMA05' OPERATION  4 ACCESS 0 //MODEL_OPERATION_UPDATE 
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VACOMA05' OPERATION  5 ACCESS 0 //MODEL_OPERATION_DELETE 

return aRotina

/*/{Protheus.doc}u_VC05VUsr
    Valida o conteúdo do campo Z0A_USERID, verificando se existe o ID do usuário cadastrado no Protheus. 
@since 20170328
@author jrscatolon
@return Lógico, Retorna .t. se o usuário está cadastrado no Protheus. Caso contrário retornará .f.
/*/
user function VC05VUsr()
local lRet := .t.

    PswOrder(1) // 1 - ID do usuário/grupo; 2 - Nome do usuário/grupo; 3 - Senha do usuário; 4 - E-mail do usuário
    if !Empty(M->Z0A_USERID) .and. !PswSeek(AllTrim(M->Z0A_USERID))
        ShowHelpDlg("VC05VUSR", {"O usuário não foi identificado no cadastro de usuários."}, 1, {"Por favor, digite ou selecione um usuário válido. " + CRLF + "<F3> Disponível!"}, 1)
        lRet := .f.
    else
        M->Z0A_NOME := UsrRetName (AllTrim(M->Z0A_USERID)) 
    endif

return lRet

/*/{Protheus.doc}Z0ACommit
    Realiza a gravação dos campos da Z0A.
@param oModel, Objeto, Objeto do tipo MPFormModel usado para validar o conteúdo do modelo de dados.
@since 20170328
@author jrscatolon
@return Lógico, 
/*/
static function Z0ACommit(oModel)
local aArea := GetArea()
local nOperation := oModel:GetOperation()
local lRet := .t.
local cSql := ""
local cNextSeq := ""

if nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_INSERT
    /* Cria região crítica */
    while !LockByName("Z0ACommit")
        Sleep(1000)
    end
    
    cSql := " select max(Z0A_SEQ) Z0A_SEQ" +;
              " from " + RetSqlName("Z0A") + " Z0A" +;
             " where Z0A.Z0A_FILIAL = '" + xFilial("Z0A") + "'" +;
               " and Z0A.D_E_L_E_T_ = ' '"
    
    DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cSql)), "MAXZ0A", .f., .f.)
    cNextSeq := Iif(!MAXZ0A->(Eof()), Soma1(MAXZ0A->Z0A_SEQ), StrZero(1, TamSX3("Z0A_SEQ")[1])) 
    MAXZ0A->(DbCloseArea())
    
    RecLock("Z0A", nOperation == MODEL_OPERATION_INSERT)
        u_GrvCpo("Z0A")
        Z0A->Z0A_SEQ := cNextSeq
        Z0A->Z0A_FILIAL := xFilial("Z0A")
    MsUnlock()
    UnlockByName("Z0ACommit")
    /* Finaliza Região Crítics */
elseif nOperation == MODEL_OPERATION_DELETE
    RecLock("Z0A", .f.)
        DbDelete()
    MsUnlock()
endif

RestArea(aArea)
return lRet

/*/{Protheus.doc}Z0AValid
    Valida a operação executada na tabela Z0A.
@param oModel, Objeto, Objeto do tipo MPFormModel usado para validar o conteúdo do modelo de dados.
@since 20170328
@author jrscatolon
@return Lógico, 
/*/
static function Z0AValid(oModel)
local aArea := GetArea()
local aAreaZ0B := Z0B->(GetArea())
local nOperation := oModel:GetOperation()
local lRet := .t.

if nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_INSERT
    if Empty(M->Z0A_USERID)
        SX3->(DbSetOrder(2)) // X3_CAMPO
        SX3->(DbSeek("Z0A_USERID"))
        ShowHelpDlg("Z0AVALID", {"O campo " + X3Titulo() + " não foi preenchido."}, 1, {"Por favor, preencha o campo " + X3Titulo() + "."}, 1)
        lRet := .f.
    endif
elseif nOperation == MODEL_OPERATION_DELETE
    Z0B->(DbSetOrder(2)) // Z0B_FILIAL+Z0B_USUARI+Z0B_DATA+Z0B_HORA+Z0B_SOLICI
    if Z0B->(DbSeek(xFilial("Z0B")+Z0A->Z0A_USERID))
        ShowHelpDlg("Z0AVALID", {"Não é possivel excluir o liberador " + Z0A->Z0A_NOME + " pois existem lançamentos de liberação de solicitação de compras em seu nome."}, 1, {"Caso seja necessário opte por bloquear o Liberador."}, 1)
        lRet := .f.
    endif
endif
Z0B->(RestArea(aAreaZ0B))
RestArea(aArea)
return lRet
