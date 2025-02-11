// #########################################################################################
// Projeto: Trato
// Fonte  : vapcpa06
// ---------+------------------------------+------------------------------------------------
// Data     | Autor: JRScatolon            | Descrição
// ---------+------------------------------+------------------------------------------------
// 20190221 | jrscatolon@jrscatolon.com.br | Cadastro de plano nutricional 
//          |                              |  
//          |                              |  
// ---------+------------------------------+------------------------------------------------

#include "protheus.ch"  
#include "rwmake.ch"
#include "topconn.ch"
#include "parmtype.ch"
#include "fwmvcdef.ch"

static _MODEL_FIELD := 1
static _MODEL_GRID := 2
static lAjuChange := .f.

static aCposCab := {'Z0M_CODIGO', 'Z0M_VERSAO', 'Z0M_DESCRI', 'Z0M_DATA  ', 'Z0M_PESO  '}
static cCposCab := 'Z0M_CODIGO|Z0M_VERSAO|Z0M_DESCRI|Z0M_DATA  |Z0M_PESO  '
static aCposGrid := {} // 'Z0M_DIA   ', 'Z0M_DIETA ', 'Z0M_QUANT '

/*/{Protheus.doc} VAPCPA06
Cadastro de Plano Nutricional
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
/*/
user function VAPCPA06()
local oBrowse := nil

local aFields := {}
local aBrowse := {}
local aIndex := {}

private oTmpZ0M := nil
private cAlias := "Z0M"
private cAliasTMP := CriaTrab(,.f.)
private cPerg := "VAPCPA06"
private nNroTrato := 0
private oView := nil

AtuSX1(@cPerg)

DbSelectArea("SX3")
DbSetOrder(2) // X3_CAMPO

DbSelectArea("SB1")
DbsetOrder(1) // B1_FILIAL+B1_COD

DbSelectArea("Z0M")
DbSetOrder(1) // Z0M_FILIAL+Z0M_CODIGO+Z0M_VERSAO

//-----------------------------------------------
//Monta os campos da tabela temporária e o browse
//-----------------------------------------------
SX3->(DbSeek("Z0M_CODIGO"))
AAdd(aFields,{SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
AAdd(aBrowse, {X3Titulo(), SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})

SX3->(DbSeek("Z0M_VERSAO"))
AAdd(aFields,{SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
AAdd(aBrowse, {X3Titulo(), SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})

SX3->(DbSeek("Z0M_DESCRI"))
AAdd(aFields,{SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
AAdd(aBrowse, {X3Titulo(), SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})

//-------------------
//Criação do objeto
//-------------------
oTmpZ0M := FWTemporaryTable():New(cAliasTMP)
oTmpZ0M:SetFields(aFields)

//-------------------
//Ajuste dos índices
//-------------------
oTmpZ0M:AddIndex(cAliasTMP + "1", {"Z0M_CODIGO", "Z0M_VERSAO"})
oTmpZ0M:AddIndex(cAliasTMP + "2", {"Z0M_DESCRI"})
AAdd(aIndex, "Z0M_CODIGO+Z0M_VERSAO")
AAdd(aIndex, "Z0M_DESCRI")

//------------------
//Criação da tabela
//------------------
oTmpZ0M:Create()

TCSqlExec(;
           " insert into " + oTmpZ0M:GetRealName() + "(Z0M_CODIGO, Z0M_VERSAO, Z0M_DESCRI)" +;
           " select Z0M.Z0M_CODIGO, max(Z0M.Z0M_VERSAO) Z0M_VERSAO, Z0M.Z0M_DESCRI" +;
             " from " + RetSqlName("Z0M") + " Z0M" +;
            " where Z0M.Z0M_FILIAL = '" + xFilial("Z0M") + "'" +;
              " and Z0M.D_E_L_E_T_ = ' '" +;
         " group by Z0M.Z0M_CODIGO, Z0M.Z0M_DESCRI" ;
         ) 

DbSelectArea("SX2")
DbSetOrder(1)
DbSeek(cAlias)

    //Cria um browse para a SX5, filtrando somente a tabela 00 (cabeçalho das tabelas
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAliasTMP)
    oBrowse:SetQueryIndex(aIndex)
    oBrowse:SetTemporary(.t.)
    oBrowse:SetFields(aBrowse)
    oBrowse:DisableDetails()    
    oBrowse:SetDescription(SX2->X2_NOME)
    oBrowse:Activate()

(cAliasTMP)->(DbCloseArea())

if oTmpZ0M <> nil
    oTmpZ0M:Delete()
    oTmpZ0M := nil
endif

return nil

/*/{Protheus.doc} MenuDef
Retorna um array com o menu da rotina VAPcpA06 
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@return array, array contendo as rotinas para o programa VAPcpA06

@type function
/*/
static function MenuDef()

Local aRotina := {} 

ADD OPTION aRotina TITLE OemToAnsi("Pesquisar")  ACTION "PesqBrw"             OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi("Visualizar") ACTION "VIEWDEF.VAPCPA06"    OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE OemToAnsi("Incluir")    ACTION "VIEWDEF.VAPCPA06"    OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE OemToAnsi("Alterar")    ACTION "VIEWDEF.VAPCPA06"    OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE OemToAnsi("Excluir")    ACTION "VIEWDEF.VAPCPA06"    OPERATION 5 ACCESS 0 // "Excluir" 
//ADD OPTION aRotina TITLE OemToAnsi("Copiar")     ACTION "VIEWDEF.VAPCPA06"    OPERATION 9 ACCESS 0 // "Copiar" 

return aRotina


/*/{Protheus.doc} ModelDef
Criação do modelo de dados para a rotina VAPcpA06
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@return object, Objeto do tipo MpFormModel contendo as definições do modelo de dados da rotina VAPcpA06  
/*/
static function ModelDef()
local oModel := nil
local oFieldModel := nil
local oGridModel := nil

local bLoadForm := {|oFormField, lCopia| LoadZ0M(oFormField, lCopia)}
local bPostValid := {|oModel| ModelValid(oModel)}

local bLoadGrid := {|oGridModel, lCopia| LoadZ0MGrid(oGridModel, lCopia)}
local bLinePre := {|oGridModel, nLin, cOperacao| LinePreZ0MGrid(oGridModel, nLin, cOperacao)}
local bLinePost := {|oGridModel, nLin| LinePosZM0Grid(oGridModel, nLin)}

local bPre := {|oGridModel, nLin| PreZ0MGrid(oGridModel, nLin)}

local bCommit := { |oModel| CommitZ0M(oModel)} 

//oFieldModel := getModelStruct(_MODEL_FIELD)
oFieldModel := FWFormStruct(1, cAlias, { |cField| cField$cCposCab})
oGridModel := GetModelStruct(_MODEL_GRID)

oModel := MpFormModel():New('U_VAPCPA06', /*bPreValid*/, bPostValid, bCommit, /*Cancel*/) 

//-- campos
oModel:AddFields('MdField' + cAlias,,oFieldModel,/*bPreValid*/, /*bPosValid*/, bLoadForm)
oModel:AddGrid( 'MdGrid' + cAlias, 'MdField' + cAlias, oGridModel, bLinePre,bLinePost,bPre,/*bPost*/,bLoadGrid)

oModel:SetDescription("Plano Nutricional")
oModel:GetModel('MdField' + cAlias):SetDescription("Cabeçalho")
oModel:GetModel('MdGrid' + cAlias):SetDescription("Grid")

oModel:SetPrimaryKey({'Z0M_FILIAL','Z0M_CODIGO'})

Return oModel

/*/{Protheus.doc} GetModelStruct
Carrega as estruturas para o formulário
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@return object, objeto do tipo FWFormModelStruct com os detalhes da rotina
@param nType, numeric, identifica se será criada a estrutura do cabeçalho ou da grid
/*/
static function GetModelStruct(nType)
local oStruct := nil
local cValid := ""
local cWhen := ""
local i, nLen

if nType == _MODEL_FIELD
    oStruct := FWFormModelStruct():New()
    oStruct:AddTable('Z0M', {'Z0M_FILIAL', 'Z0M_CODIGO', 'Z0M_VERSAO'}, SX2->X2_NOME)
    
    nLen := Len(aCposCab)
    for i := 1 to nLen
        SX3->(DbSetOrder(2)) // X3_CAMPO
        if SX3->(DbSeek(Padr(aCposCab[i], Len(SX3->X3_CAMPO)))) 
            cValid := Iif(!Empty(SX3->X3_VLDUSER), "(" + AllTrim(SX3->X3_VLDUSER) + ")", "") + Iif(!Empty(SX3->X3_VLDUSER).and.!Empty(SX3->X3_VALID), ".and.", "") + Iif(!EMpty(SX3->X3_VALID), "(" + AllTrim(SX3->X3_VALID) + ")", "")
            cWhen := Iif(!AllTrim(SX3->X3_CAMPO)$'Z0M_VERSAO', ".t.", ".f.")
            oStruct:AddField(;
                X3Titulo(),;               // [01]  C   Titulo do campo
                X3Descric(),;              // [02]  C   ToolTip do campo
                AllTrim(aCposCab[i]),;     // [03]  C   Id do Field
                TamSX3(SX3->X3_CAMPO)[3],; // [04]  C   Tipo do campo
                TamSX3(SX3->X3_CAMPO)[1],; // [05]  N   Tamanho do campo
                TamSX3(SX3->X3_CAMPO)[2],; // [06]  N   Decimal do campo
                Iif(!Empty(cValid), FWBuildFeature(STRUCT_FEATURE_VALID, cValid), nil),; // [07]  B   Code-block de validação do campo
                Iif(!Empty(cWhen), FWBuildFeature(STRUCT_FEATURE_WHEN, cWhen), nil),; // [08]  B   Code-block de validação When do campo
                nil,;                      // [09]  A   Lista de valores permitido do campo
                X3Obrigat(SX3->X3_CAMPO),; // [10]  L   Indica se o campo tem preenchimento obrigatório
                FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!Inclui," + cAlias + "->"+AllTrim(SX3->X3_CAMPO)+",CriaVar('" + AllTrim(SX3->X3_CAMPO) + "',.t.))" ),; // [11]  B   Code-block de inicializacao do campo
                AllTrim(aCposCab[i])$'Z0M_FILIAL|Z0M_CODIGO|Z0M_VERSAO',; // [12]  L   Indica se trata-se de um campo chave
                .t.,;                      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                .f.)                       // [14]  L   Indica se o campo é virtual
        endif
    next
else

    nNroTrato := u_GetNroTrato()
    // aCposGrid // {'Z0M_DIA   ', 'Z0M_DIETA ', 'Z0M_QUANT '}
    oStruct := FWFormModelStruct():New()
    SX3->(DbSetOrder(2)) // X3_CAMPO

    // Carrega o campo dia
    SX3->(DbSeek(PadR('Z0M_DIA', Len(SX3->X3_CAMPO))))
    cValid := Iif(!Empty(SX3->X3_VLDUSER), "(" + AllTrim(SX3->X3_VLDUSER) + ")", "") + Iif(!Empty(SX3->X3_VLDUSER).and.!Empty(SX3->X3_VALID), ".and.", "") + Iif(!Empty(SX3->X3_VALID), "(" + AllTrim(SX3->X3_VALID) + ")", "")
    cWhen := SX3->X3_WHEN
    oStruct:AddField(;
        X3Titulo(),;               // [01]  C   Titulo do campo
        X3Descric(),;              // [02]  C   ToolTip do campo
        'Z0M_DIA',;                // [03]  C   Id do Field
        TamSX3(SX3->X3_CAMPO)[3],; // [04]  C   Tipo do campo
        TamSX3(SX3->X3_CAMPO)[1],; // [05]  N   Tamanho do campo
        TamSX3(SX3->X3_CAMPO)[2],; // [06]  N   Decimal do campo
        Iif(!Empty(cValid), FWBuildFeature(STRUCT_FEATURE_VALID, cValid), nil),; // [07]  B   Code-block de validação do campo
        Iif(!Empty(cWhen), FWBuildFeature(STRUCT_FEATURE_WHEN, cWhen), nil),; // [08]  B   Code-block de validação When do campo
        {},;                       // [09]  A   Lista de valores permitido do campo
        .t.,;                      // [10]  L   Indica se o campo tem preenchimento obrigatório
        Iif(!Empty(SX3->X3_RELACAO), FwBuildFeature( STRUCT_FEATURE_INIPAD, SX3->X3_RELACAO), nil),; // [11]  B   Code-block de inicializacao do campo
        .f.,;                      // [12]  L   Indica se trata-se de um campo chave
        .t.,;                      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .f.)                       // [14]  L   Indica se o campo é virtual
    AAdd(aCposGrid, Padr('Z0M_DIA', Len(SX3->X3_CAMPO)))

    for i := 1 to nNroTrato
        SX3->(DbSeek('Z0M_DIETA '))
        cValid := Iif(!Empty(SX3->X3_VLDUSER), "(" + AllTrim(SX3->X3_VLDUSER) + ")", "") + Iif(!Empty(SX3->X3_VLDUSER).and.!Empty(SX3->X3_VALID), ".and.", "") + Iif(!Empty(SX3->X3_VALID), "(" + AllTrim(SX3->X3_VALID) + ")", "")
        cValid := if(At(AllTrim('Z0M_DIETA'), cValid) > 0, StrTran(cValid, AllTrim('Z0M_DIETA'), AllTrim('Z0M_DIETA') + Str(i, 1)), cValid) 
        cWhen := SX3->X3_WHEN
        cWhen := if(At(AllTrim('Z0M_DIETA'), cWhen) > 0, StrTran(cWhen, AllTrim('Z0M_DIETA'), AllTrim('Z0M_DIETA') + Str(i, 1)), cWhen) 
        oStruct:AddField(;
            AllTrim(X3Titulo()) + " " + Str(i, 1),;               // [01]  C   Titulo do campo
            X3Descric(),;              // [02]  C   ToolTip do campo
            AllTrim('Z0M_DIETA') + Str(i, 1),;    // [03]  C   Id do Field
            TamSX3(SX3->X3_CAMPO)[3],; // [04]  C   Tipo do campo
            TamSX3(SX3->X3_CAMPO)[1],; // [05]  N   Tamanho do campo
            TamSX3(SX3->X3_CAMPO)[2],; // [06]  N   Decimal do campo
            Iif(!Empty(cValid), FWBuildFeature(STRUCT_FEATURE_VALID, cValid), nil),; // [07]  B   Code-block de validação do campo
            Iif(!Empty(cWhen), FWBuildFeature(STRUCT_FEATURE_WHEN, cWhen), nil),; // [08]  B   Code-block de validação When do campo
            {},;                       // [09]  A   Lista de valores permitido do campo
            .f.,;                      // [10]  L   Indica se o campo tem preenchimento obrigatório
            nil,;                      // [11]  B   Code-block de inicializacao do campo
            .f.,;                      // [12]  L   Indica se trata-se de um campo chave
            .t.,;                      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
            .f.)                       // [14]  L   Indica se o campo é virtual
        AAdd(aCposGrid, Padr('Z0M_DIETA' + Str(i, 1), Len(SX3->X3_CAMPO)))

        SX3->(DbSeek('Z0M_QUANT'))
        cValid := Iif(!Empty(SX3->X3_VLDUSER), "(" + AllTrim(SX3->X3_VLDUSER) + ")", "") + Iif(!Empty(SX3->X3_VLDUSER).and.!Empty(SX3->X3_VALID), ".and.", "") + Iif(!Empty(SX3->X3_VALID), "(" + AllTrim(SX3->X3_VALID) + ")", "")
        cValid := if(At('Z0M_QUANT', cValid) > 0, StrTran(cValid, 'Z0M_QUANT', 'Z0M_QUANT' + Str(i, 1)), cValid) 
        cWhen := SX3->X3_WHEN
        cWhen := if(At('Z0M_QUANT', cWhen) > 0, StrTran(cWhen, 'Z0M_QUANT', 'Z0M_QUANT' + Str(i, 1)), cWhen) 
        oStruct:AddField(;
                AllTrim(X3Titulo()) + " " + Str(i, 1),;               // [01]  C   Titulo do campo
                X3Descric(),;              // [02]  C   ToolTip do campo
                'Z0M_QUANT' + Str(i, 1),;     // [03]  C   Id do Field
                TamSX3(SX3->X3_CAMPO)[3],; // [04]  C   Tipo do campo
                TamSX3(SX3->X3_CAMPO)[1],; // [05]  N   Tamanho do campo
                TamSX3(SX3->X3_CAMPO)[2],; // [06]  N   Decimal do campo
                Iif(!Empty(cValid), FWBuildFeature(STRUCT_FEATURE_VALID, cValid), nil),; // [07]  B   Code-block de validação do campo
                Iif(!Empty(cWhen), FWBuildFeature(STRUCT_FEATURE_WHEN, cWhen), nil),; // [08]  B   Code-block de validação When do campo
                {},;                       // [09]  A   Lista de valores permitido do campo
                .f.,;                      // [10]  L   Indica se o campo tem preenchimento obrigatório
                Iif(!Empty(SX3->X3_RELACAO), FwBuildFeature( STRUCT_FEATURE_INIPAD, SX3->X3_RELACAO), nil),; // [11]  B   Code-block de inicializacao do campo
                .f.,;                      // [12]  L   Indica se trata-se de um campo chave
                .t.,;                      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                .f.)                       // [14]  L   Indica se o campo é virtual
        AAdd(aCposGrid, Padr('Z0M_QUANT' + Str(i, 1), Len(SX3->X3_CAMPO)))
        
    next
    
endif

return oStruct

/*/{Protheus.doc} LoadZ0M
Carrega os dados da Z0M para o cabeçalho da rotina
@author guima
@since 22/02/2019
@version 1.0
@return Array, Array com os dados
@param oFormField, object, descricao
@param lCopia, logical, descricao

/*/
static function LoadZ0M(oFormField, lCopia)
local aDados := {} // {{}, 0}
local i, nLen
local cMaxVer := ""

cMaxVer := u_vpcp06ver((cAliasTMP)->Z0M_CODIGO)

DbSelectArea("Z0M")
DbSetOrder(1) // Z0M_FILIAL+Z0M_CODIGO+Z0M_VERSAO 
Z0M->(DbSeek(FWxFilial("Z0M") + (cAliasTMP)->Z0M_CODIGO + cMaxVer))

nLen := Len(aCposCab)
for i := 1 to nLen
    if AllTrim(aCposCab[i]) == "Z0M_VERSAO" .and. oFormField:oFormModel:nOperation == MODEL_OPERATION_UPDATE
        AAdd(aDados, Soma1(cMaxVer))
    elseif AllTrim(aCposCab[i]) == "Z0M_DATA  " .and. oFormField:oFormModel:nOperation == MODEL_OPERATION_UPDATE
        AAdd(aDados, Date())
    else
        AAdd(aDados, Z0M->&(AllTrim(aCposCab[i])))
    endif
next

return aDados

/*/{Protheus.doc} LinePreZ0MGrid
//Configura o bloco código de pré validação da linha do grid.
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@return logic, implementado apenas a validação do undelete
@param oGridModel, object, objeto do tipo FWFormGridModel contendo os dados da grid
@param nLin, numeric, número da linha atualmente posicionada 
@param cOperacao, characters, A Identificação da ação
@type function
/*/
static function LinePreZ0MGrid(oGridModel, nLin, cOperacao)
local lRet := .t.
local i, nLen
local cDia

if cOperacao == "UNDELETE"

    cDia := oGridModel:GetValue("Z0M_DIA")
    for i := 1 to oGridModel:Length()
        oGridModel:GoLine(i)
        if i <> nLin
            if !oGridModel:IsDeleted() .and. oGridModel:GetValue("Z0M_DIA") == cDia 
                Help(,, "Operação não pode ser realizada.",, "Não é possível voltar o registro pois já existe outro para esse dia.", 1, 0,,,,,, {"Edite a linha que está com o dia correto."})
                lRet := .f.
                exit
            endIf
        endIf
    next
    oGridModel:GoLine(nLin)
    
endif

return lRet

/*/{Protheus.doc} PreZ0MGrid

@author guima
@since 25/02/2019
@version 1.0
@return logico, 
@param oGridModel, object, descricao
@type function
/*/
static function PreZ0MGrid(oGridModel)
local lRet := .t.
local nOperation := oGridModel:GetOperation()
local i

if nOperation == MODEL_OPERATION_UPDATE
//------------------------------------------------------------
// Controles do aDataModel
// FormGrid
//------------------------------------------------------------
//#DEFINE MODEL_GRID_DATA      1
//#DEFINE MODEL_GRID_VALID     2
//#DEFINE MODEL_GRID_DELETE    3
//#DEFINE MODEL_GRID_ID        4
//#DEFINE MODEL_GRID_CHILDREN  5
//#DEFINE MODEL_GRID_MODIFY    6
//#DEFINE MODEL_GRID_INSERT    7
//#DEFINE MODEL_GRID_UPDATE    8
//#DEFINE MODEL_GRID_CHILDLOAD 9

    for i := 1 to oGridModel:Length()
        if oGridModel:aDataModel[i][MODEL_GRID_INSERT] == .t. .and. oGridModel:aDataModel[i][MODEL_GRID_UPDATE] == .t.
            exit
        endif
        oGridModel:aDataModel[i][MODEL_GRID_INSERT] := .t.
        oGridModel:aDataModel[i][MODEL_GRID_UPDATE] := .t.
    next
endif

return lRet

/*/{Protheus.doc} LinePosZM0Grid
Bloco de código de pós validação da linha do grid, equivale ao "LINHAOK"
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@return logic, verifica se o preenchimento da linha está correto
@param oGridModel, object, objeto do tipo FWFormGridModel contendo os dados da grid
@param nLin, numeric, número da linha atualmente posicionada 
@type function
/*/
static function LinePosZM0Grid(oGridModel, nLin)
local lRet := .t.
local cDia := ""
local i, nLen

if !FWIsInCallStack("PREENCHEAUTO")
    default nLin := oGridModel:GetLine()
    cDia := oGridModel:GetValue("Z0M_DIA")
    if !oGridModel:IsDeleted(nLin)
    
        if Empty(cDia)
            SX3->(DbSetOrder(2))	     
            SX3->(DbSeek(Padr("Z0M_DIA", Len(SX3->X3_CAMPO))))
            Help(,, "Linha inválida.",, "O campo " + X3Titulo() + " é obrigatório.", 1, 0,,,,,, {"Por favor, preencha o campo " + X3Titulo() + "."})
            lRet := .f.
        else
            lRet := .f.
            for i := 1 to nNroTrato
                if !Empty(oGridModel:GetValue("Z0M_DIETA" + Str(i, 1))) .and. !Empty(oGridModel:GetValue("Z0M_QUANT" + Str(i, 1)))
                    lRet := .t.
                    exit 
                endif 
            next
            if !lRet
                Help(,, "Obrigatório o preenchimento pelo menos um trato por linha.",, "Não existe nenhum trato com Dieta e Qtde MS preenchidos.", 1, 0,,,,,, {"Por favor, preencha os campos Dieta e Qtde MS de pelo menos um trato."})
            else
                nLen := oGridModel:Length()
                for i := 1 to nLen 
                    oGridModel:GoLine(i)
                    if i <> nLin
                        if !oGridModel:IsDeleted() .and. oGridModel:GetValue("Z0M_DIA") == cDia 
                            Help(,, "Dia já existe.",, "O dia '" + cDia + "' preenchido já existe na gride na linha " + AllTrim(Str(i)) + ".", 1, 0,,,,,, {"Edite a linha " + AllTrim(Str(i)) + " com os valores desejados."})
                            lRet := .f.
                            exit
                        endIf
                    endIf
                next
                oGridModel:GoLine(nLin)
            endif
        endif
    endif
    if lRet
        u_Bouble('MdGrid' + cAlias, 'Z0M_DIA')
        oView:Refresh('VwGrid' + cAlias)
    endif
endif
return lRet

/*/{Protheus.doc} VldDia
Verifica se o dia já foi preenchido e trata a grid para ordenar os dados conforme o ultimo dia preenchido 
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@return logic, retorna se o dia digitado pode ser usado

@type function
/*/
user function VldDia()
local lRet := .t.
local oModel := FWModelActive()
local oGridModel := oModel:GetModel('MdGrid' + cAlias)
local cDia := ""
local i, nLen

    nLin := oGridModel:GetLine()

    if !FWIsInCallStack("PREENCHEAUTO")
        nLen := oGridModel:Length()
        cDia := oGridModel:GetValue("Z0M_DIA")
        for i := 1 to nLen 
            oGridModel:GoLine(i)
            if i <> nLin
                if !oGridModel:IsDeleted() .and. oGridModel:GetValue("Z0M_DIA") == cDia 
                    Help(,, "Dia já existe.",, "O dia '" + cDia + "' preenchido já existe na gride na linha " + AllTrim(Str(i)) + ".", 1, 0,,,,,, {"Edite a linha " + AllTrim(Str(i)) + " com os valores desejados."})
                    lRet := .f.
                    exit
                endIf
            endIf
        next
        oGridModel:GoLine(nLin)
    endif
return lRet

/*/{Protheus.doc} LoadZ0MGrid
Carrega os dados da grid
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@return A, Array com os dados para preenchimento da grid
@param oFormGrid, object, descricao
@param lCopia, logical, descricao
@type function
/*/
static function LoadZ0MGrid(oFormGrid, lCopia)
local aDados := {}
local i, nLen := Len(aCposGrid)
local aTemplate := {0, Array(nLen)}
local nPosTrato := 0
local cDia := ""

// aTemplate := {0, {Z0M_DIA, Z0M_DIETAx, Z0M_QUANTx}}
aTemplate[2][1] := StrZero(1, TamSX3("Z0M_DIA")[1])
for i := 2 to nLen
    aTemplate[2][i] := Iif(i%2 == 0, "", 0)
next

DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                          " select Z0M.Z0M_DIA, Z0M.Z0M_TRATO, Z0M.Z0M_DIETA, Z0M.Z0M_QUANT, Z0M.R_E_C_N_O_ RECNO" +;
                            " from " + RetSqlName("Z0M") + " Z0M" +;
                           " where Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" +;
                             " and Z0M.Z0M_CODIGO = '" + (cAliasTMP)->Z0M_CODIGO + "'" +;
                             " and Z0M.Z0M_VERSAO = (" +;
                                 " select max(Z0MMAX.Z0M_VERSAO)" +; 
                                   " from " + RetSqlName("Z0M") + " Z0MMAX" +;
                                  " where Z0MMAX.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" +;
                                    " and Z0MMAX.Z0M_CODIGO = '" + (cAliasTMP)->Z0M_CODIGO + "'" +;
                                    " and Z0MMAX.D_E_L_E_T_ = ' '" +;
                             " )" +;
                             " and Z0M.D_E_L_E_T_ = ' '" +;
                        " order by Z0M.Z0M_DIA, Z0M.Z0M_TRATO"), "GRIDZ0M", .f., .f.)

while !GRIDZ0M->(Eof())
    
    if cDia <> GRIDZ0M->Z0M_DIA
        AAdd(aDados, aClone(aTemplate))
        aDados[Len(aDados)][1] := GRIDZ0M->RECNO 
        aDados[Len(aDados)][2][1] := GRIDZ0M->Z0M_DIA
        cDia := GRIDZ0M->Z0M_DIA
    endif

    nPosTrato := GetPos(GRIDZ0M->Z0M_TRATO)
    aDados[Len(aDados)][2][nPosTrato] := GRIDZ0M->Z0M_DIETA
    aDados[Len(aDados)][2][nPosTrato + 1] := GRIDZ0M->Z0M_QUANT

    GRIDZ0M->(DbSkip())

end

GRIDZ0M->(DbCloseArea())

return aDados

/*/{Protheus.doc} GetPos
Retorna a ´posição referente ao campo dieta para o trato passado no parametro
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@return number, Posição do campo dieta para o trato na matriz aCposGrid 
@param cTrato, characters, Número do trato a ser pesquisado
/*/
static function GetPos(cTrato)
return aScan(aCposGrid, {|aMat| Right(aMat, 1) == cTrato})

/*/{Protheus.doc} ViewDef
Montagem do view para a rotina VAPcpA06
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@return O, Objeto FwFormView para a rotina VAPcpA06

@type function
/*/
static function ViewDef()
local oModel := FwLoadModel('VAPCPA06')
local oFieldView := FWFormStruct(2, cAlias, { |cField| cField$cCposCab}) 
local oGridView := getViewStruct(_MODEL_GRID) //FwFormStruct(2,cAlias,,)

// Seta 
oGridView:SetProperty("*", MVC_VIEW_CANCHANGE, .t.)

// Criação do objeto
oView := FwFormView():New()

//Criação do Modelo
oView:SetModel(oModel)
oView:SetDescription("Cad. Plano Nutricional")

//View X Model
oView:AddField('VwField' + cAlias, oFieldView, 'MdField' + cAlias )
oView:AddGrid('VwGrid' + cAlias, oGridView, 'MdGrid' + cAlias )

//separação da tela
oView:CreateHorizontalBox('CABECALHO', 20)
oView:CreateHorizontalBox('ITEM', 80)

//visões da tela
oView:SetOwnerView('VwField' + cAlias, 'CABECALHO')
oView:SetOwnerView('VwGrid' + cAlias, 'ITEM')

// Seta auto incremento
oView:AddIncrementField('VwGrid' + cAlias, 'Z0M_DIA' ) 

// Adiciona Botão Plano Automaticamente 
oView:AddUserButton( 'Plano Automatico', 'CLIPS', {|oView| PreencheAuto(oView)} )

return oView

/*/{Protheus.doc} getViewStruct
Retorna as estruturas customizadas para a rotina
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@return O, Objeto FWFormViewStruct 
@param nType, numeric, Indentifica qual estrutura deve retornar (form ou grid)
/*/
static function getViewStruct(nType)
local oStruct := FWFormViewStruct():New()
local cCpo, i, nLen

if nType == _MODEL_FIELD
    nLen := Len(aCposCab)
    for i := 1 to nLen
        SX3->(DbSetOrder(2))
        if SX3->(DbSeek(Padr(aCposCab[i], Len(SX3->X3_CAMPO))))
            oStruct:AddField(;
                AllTrim(aCposCab[i]),;          // [01]  C   Nome do Campo
                StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                X3Titulo(),;                    // [03]  C   Titulo do campo
                X3Descric(),;                   // [04]  C   Descricao do campo
                {"Help"},;                      // [05]  A   Array com Help
                TamSX3(SX3->X3_CAMPO)[3],;      // [06]  C   Tipo do campo
                X3Picture(SX3->X3_CAMPO),;      // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                SX3->X3_F3,;                    // [09]  C   Consulta F3
                .t.,;                           // [10]  L   Indica se o campo é alteravel
                nil,;                           // [11]  C   Pasta do campo
                nil,;                           // [12]  C   Agrupamento do campo
                nil,;                           // [13]  A   Lista de valores permitido do campo (Combo)
                nil,;                           // [14]  N   Tamanho maximo da maior opção do combo
                nil,;                           // [15]  C   Inicializador de Browse
                nil,;                           // [16]  L   Indica se o campo é virtual
                nil,;                           // [17]  C   Picture Variavel
                nil)                            // [18]  L   Indica pulo de linha após o campo
        endif
    next
else
    nLen := Len(aCposGrid)
    for i := 1 to nLen
        SX3->(DbSetOrder(2))
        cCpo := Iif('Z0M_DIA'$aCposGrid[i],'Z0M_DIA',Iif('Z0M_DIETA'$aCposGrid[i],'Z0M_DIETA','Z0M_QUANT'))
        if SX3->(DbSeek(Padr(cCpo, Len(SX3->X3_CAMPO))))
            cTitulo := AllTrim(X3Titulo()) + Iif('Z0M_DIA'$aCposGrid[i], '', ' ' + Right(aCposGrid[i], 1))
            oStruct:AddField(;
                AllTrim(aCposGrid[i]),;         // [01]  C   Nome do Campo
                StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                cTitulo,;                       // [03]  C   Titulo do campo
                X3Descric(),;                   // [04]  C   Descricao do campo
                {"Help"},;                           // [05]  A   Array com Help
                TamSX3(SX3->X3_CAMPO)[3],;      // [06]  C   Tipo do campo
                X3Picture(SX3->X3_CAMPO),;      // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                SX3->X3_F3,;                    // [09]  C   Consulta F3
                .t.,;                           // [10]  L   Indica se o campo é alteravel
                nil,;                           // [11]  C   Pasta do campo
                nil,;                           // [12]  C   Agrupamento do campo
                nil,;                           // [13]  A   Lista de valores permitido do campo (Combo)
                nil,;                           // [14]  N   Tamanho maximo da maior opção do combo
                nil,;                           // [15]  C   Inicializador de Browse
                nil,;                           // [16]  L   Indica se o campo é virtual
                nil,;                           // [17]  C   Picture Variavel
                nil)                            // [18]  L   Indica pulo de linha após o campo
        endif
    next
endif

return oStruct

/*/{Protheus.doc} PreencheAuto
Wizard para preenchimento dos campos da grid
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
/*/
static function PreencheAuto()
local oModel := FWModelActive()
local oView := FWViewActive()
local oGridModel := oModel:GetModel('MdGrid' + cAlias)
local nLenGrid := 0
local nLinIni := 0
local nQuant := 0
local nDia := 0
local nLin := 0

    if Pergunte(cPerg)
        if mv_par01 < 1 .or. mv_par01 > 999
            Help(/*Descontinuado*/,/*Descontinuado*/,/*cCampo*/,"","Dia de inicio inválido.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"O dia de início deve ser maior ou igual a 1 e menor que ou igual a 999." })
        elseif mv_par02 < mv_par01 .or. mv_par02 > 999
            Help(/*Descontinuado*/,/*Descontinuado*/,/*cCampo*/,"","Dia de fim inválido.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"O dia de fim do trato deve ser maior ou igual ao dia de inicio e menor que ou igual a 999." })
        elseif mv_par03 < 1 .or. mv_par03 > nNroTrato
            Help(/*Descontinuado*/,/*Descontinuado*/,/*cCampo*/,"","Trato inicial inválido.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"O trato inicial deve ser maior ou igual 1 e menor que ou igual a " + AllTrim(Str(nNroTrato)) + "." })
        elseif mv_par04 < mv_par03 .or. mv_par04 > nNroTrato
            Help(/*Descontinuado*/,/*Descontinuado*/,/*cCampo*/,"","Trato final inválido.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"O trato final deve ser maior ou igual ao trato inicial e e menor que ou igual a " + AllTrim(Str(nNroTrato)) + "." })
        elseif !SB1->(DbSeek(FWxFilial("SB1")+mv_par05)) // .or. SB1-><B1_PROD> != '1'
            Help(/*Descontinuado*/,/*Descontinuado*/,/*cCampo*/,"","Dieta inválida.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"A dieta deve ser um produto cadastrado no cadastro de produtos com o campo <Identificar campo> preenchido como Sim." })
        elseif mv_par06 == 0 .and. mv_par07 == 0
            Help(/*Descontinuado*/,/*Descontinuado*/,/*cCampo*/,"","Quantidade de ração ou incremento inválidos.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Pelo menos a quantidade de ração a ser servida no dai incial ou a variação deve ser superior a 0. Ambos os campos não podem ter conteúdo 0." })
        else
            // se a primeira linha ainda não foi prenchida
            nLinIni := oGridModel:GetLine()
            if oGridModel:IsEmpty()
                nQuant := mv_par06
                for nDia := mv_par01 to mv_par02
                    oGridModel:AddLine()
                    oView:Refresh()
                    oGridModel:GoLine(oGridModel:Length())
                    oGridModel:SetValue("Z0M_DIA", StrZero(nDia, TamSX3("Z0M_DIA")[1]))
                    oView:Refresh()
                    FillTrato(oGridModel, mv_par03, mv_par04, mv_par05, nQuant)
                    nQuant += mv_par07
                end
            else
                nQuant := mv_par06
                for nDia := mv_par01 to mv_par02
                    // Se encontrou a linha sobrescreve os valores dela pelos novos
                    if oGridModel:SeekLine({{"Z0M_DIA",StrZero(nDia, TamSX3("Z0M_DIA")[1])}})
                        FillTrato(oGridModel, mv_par03, mv_par04, mv_par05, nQuant)
                    else
                        // verifica se não existe valor maior que o da linha na grid
                        oGridModel:GoLine(oGridModel:Length())
                        if oGridModel:GetValue("Z0M_DIA") < StrZero(nDia, TamSX3("Z0M_DIA")[1])
                            oGridModel:AddLine()
                            oView:Refresh()
                            oGridModel:GoLine(oGridModel:Length())
                            oGridModel:SetValue("Z0M_DIA", StrZero(nDia, TamSX3("Z0M_DIA")[1]))
                            FillTrato(oGridModel, mv_par03, mv_par04, mv_par05, nQuant)
                        else
                            // Abre espaço na grid para o dia
                            oGridModel:AddLine()
                            oView:Refresh()
                            nLin := oGridModel:Length()-1
                            oGridModel:GoLine(nLin)
                            while oGridModel:GetValue("Z0M_DIA") > StrZero(nDia, TamSX3("Z0M_DIA")[1])
                                oGridModel:LineShift(nLin,nLin+1)
                                oGridModel:GoLine(--nLin)
                            end
                            oGridModel:GoLine(nLin + 1)
                            oGridModel:SetValue("Z0M_DIA", StrZero(nDia, TamSX3("Z0M_DIA")[1]))
                            FillTrato(oGridModel, mv_par03, mv_par04, mv_par05, nQuant)
                        endif
                    endif
                    nQuant += mv_par07
                next
            endif
        endif
    endif
    oGridModel:GoLine(nLinIni)
return nil

/*/{Protheus.doc} Bouble
Ordena a grid de acordo com os parametros passados.
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@param cGridModel, characters, Nome do modelo da grid a ser ordenada
@param cCampo, characters, Campo que será usado para ordenar a grid 
/*/
user function Bouble(cGridModel, cCampo)
local oModel := FWModelActive()
local oGridModel := nil
local nLinIni, nLen, i, j

if oModel:isActive()
    oGridModel := oModel:GetModel( cGridModel )
    nLinIni := oGridModel:GetLine()
    nLen := oGridModel:Length()
    if nLen > 1
        for i := nLen to 2 step -1
            for j := 1 to i - 1
                if oGridModel:GetValue(cCampo, j) > oGridModel:GetValue(cCampo, j+1)
                    oGridModel:LineShift(j, j+1)
                endif 
            next
        next
    endif
    oGridModel:GoLine(nLinIni)
endif

return nil

static function FillTrato(oGridModel, nTratoIni, nTratoFim, cDieta, nTotalTrato)
local lRet := .t.
local i := 0
local nQtdTrato := Noround(nTotalTrato/(nTratoFim-nTratoIni+1), TamSX3("Z0M_QUANT")[2])
local nQuant := 0

    // Esvazia o conteúdo da tabela
    for i := 1 to nNroTrato
        if !oGridModel:SetValue("Z0M_DIETA" + Str(i, 1), CriaVar("Z0M_DIETA", .f.))
            Help(/*Descontinuado*/,/*Descontinuado*/,/*cCampo*/,"Z0M_DIETA" + Str(i, 1),"Não foi possível atribuir o valor " + cDieta + " a Dieta " + Str(i, 1) + ".", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor verifique." })
            lRet := .f.
            exit
        endif
        if !oGridModel:SetValue("Z0M_QUANT" + Str(i, 1), Criavar("Z0M_QUANT", .f.))
            Help(/*Descontinuado*/,/*Descontinuado*/,/*cCampo*/,"Z0M_QUANT" + Str(i, 1),"Não foi possível atribuir o valor " + AllTrim(Transform(nQtdTrato, PesqPict("Z0M","Z0M_QUANT"))) + " a Qtde MS " + Str(i, 1) + ".", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor verifique." })
            lRet := .f.
            exit
        endif
    next 
    
    for i := nTratoFim to nTratoIni step -1 
        if !oGridModel:SetValue("Z0M_DIETA" + Str(i, 1), cDieta)
            Help(/*Descontinuado*/,/*Descontinuado*/,/*cCampo*/,"Z0M_DIETA" + Str(i, 1),"Não foi possível atribuir o valor " + cDieta + " a Dieta " + Str(i, 1) + ".", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor verifique." })
            lRet := .f.
            exit
        endif
        if i > nTratoIni
            if !oGridModel:SetValue("Z0M_QUANT" + Str(i, 1), nQtdTrato)
                Help(/*Descontinuado*/,/*Descontinuado*/,/*cCampo*/,"Z0M_QUANT" + Str(i, 1),"Não foi possível atribuir o valor " + AllTrim(Transform(nQtdTrato, PesqPict("Z0M","Z0M_QUANT"))) + " a Qtde MS " + Str(i, 1) + ".", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor verifique." })
                lRet := .f.
                exit
            endif
            nQuant += nQtdTrato
        else
            if !oGridModel:SetValue("Z0M_QUANT" + Str(i, 1), nTotalTrato-nQuant)
                Help(/*Descontinuado*/,/*Descontinuado*/,/*cCampo*/,"Z0M_QUANT" + Str(i, 1),"Não foi possível atribuir o valor " + AllTrim(Transform(nQtdTrato, PesqPict("Z0M","Z0M_QUANT"))) + " a Qtde MS " + Str(i, 1) + ".", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor verifique." })
                lRet := .f.
                exit
            endif
        endif
    next

return lRet

//static function FindValue(cCampo, xValor)
//local oGridModel := FWModelActive():GetModel('MdGrid' + cAlias)
//local nPosLine := 0
//local i, nLen
//
//    nLen := oGridModel:Length()
//    for i := 1 to nLen
//        oGridModel:GoLine(i)
//        if oGridModel:GetValue(cCampo) == xValor
//            nPosLine := oGridModel:GetLine()
//            exit
//        endif
//    next
//
//return nPosLine

/*/{Protheus.doc} AtuSX1
Cria a(s) pergunta(s) usada(s) ´por essa rotina 
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@param cPerg, characters, Grupo da pergunta a ser criada
/*/
static function AtuSX1(cPerg)
local aArea    := GetArea()
local aAreaDic := SX1->( GetArea() )
local aEstrut  := {}
local aStruDic := SX1->( dbStruct() )
local aDados   := {}
local i       := 0
local j       := 0
local nTam1    := Len( SX1->X1_GRUPO )
local nTam2    := Len( SX1->X1_ORDEM )

cPerg := PadR(cPerg, Len(SX1->X1_GRUPO))

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }
                         //123456789012345678901234567890 
AAdd( aDados, {cPerg,'01','Dia inicial?                  ','Dia inicial?                  ','Dia inicial?                  ','mv_ch1','N', 3,0,0,'G','','mv_par01','','','','','','','','','','','','','','','','','','','','','','','','','     ','S','','','','', {"Informe o dia de que será iniciado o trato com a dieta selecionada.", "Informe o dia de que será iniciado o trato com a dieta selecionada.", "Informe o dia de que será iniciado o trato com a dieta selecionada."}} )
AAdd( aDados, {cPerg,'02','Dia final?                    ','Dia final?                    ','Dia final?                    ','mv_ch2','N', 3,0,0,'G','','mv_par02','','','','','','','','','','','','','','','','','','','','','','','','','     ','S','','','','', {"Informe o dia de que será finalizado o trato com a dieta selecionada.", "Informe o dia de que será finalizado o trato com a dieta selecionada.", "Informe o dia de que será finalizado o trato com a dieta selecionada."}} )
AAdd( aDados, {cPerg,'03','Trato inicial?                ','Trato inicial?                ','Trato inicial?                ','mv_ch3','N', 1,0,0,'G','','mv_par03','','','','','','','','','','','','','','','','','','','','','','','','','     ','S','','','','', {"Informe o trato inicial para essa dieta.", "Informe o trato inicial para essa dieta.", "Informe o trato inicial para essa dieta."}} )
AAdd( aDados, {cPerg,'04','Trato final?                  ','Trato final?                  ','Trato final?                  ','mv_ch4','N', 1,0,0,'G','','mv_par04','','','','','','','','','','','','','','','','','','','','','','','','','     ','S','','','','', {"Informe o trato final para esse dieta.", "Informe o trato final para esse dieta.", "Informe o trato final para esse dieta."}} )
AAdd( aDados, {cPerg,'05','Dieta?                        ','Dieta?                        ','Dieta?                        ','mv_ch5','C',30,0,0,'G','','mv_par05','','','','','','','','','','','','','','','','','','','','','','','','','DIETA','S','','','','', {"Informe ou selecione a dieta para o trato." + CRLF + "<F3 Disponível>", "Informe ou selecione a dieta para o trato." + CRLF + "<F3 Disponível>", "Informe ou selecione a dieta para o trato." + CRLF + "<F3 Disponível>"}} )
AAdd( aDados, {cPerg,'06','Peso inicial?                 ','Peso inicial?                 ','Peso inicial?                 ','mv_ch6','N', 6,2,0,'G','','mv_par06','','','','','','','','','','','','','','','','','','','','','','','','','     ','S','','','','', {"Informe a quantidade de ração que será servida no primeiro dia.", "Informe a quantidade de ração que será servida no primeiro dia.", "Informe a quantidade de ração que será servida no primeiro dia."}} )
AAdd( aDados, {cPerg,'07','Variação?                     ','Variação?                     ','Variação?                     ','mv_ch7','N', 6,2,0,'G','','mv_par07','','','','','','','','','','','','','','','','','','','','','','','','','     ','S','','','','', {"Variação de peso a ser acrescentada nos proximos dias.", "Variação de peso a ser acrescentada nos proximos dias.", "Variação de peso a ser acrescentada nos proximos dias."}} )

DbSelectArea( "SX1" )
SX1->( DbSetOrder( 1 ) )

nLenLin := Len( aDados )
for i := 1 to nLenLin
    if !SX1->( DbSeek( PadR( aDados[i][1], nTam1 ) + PadR( aDados[i][2], nTam2 ) ) )
        RecLock( "SX1", .t. )
        nLenCol := Len( aEstrut )
        for j := 1 to nLenCol
            if aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[j], 10 ) } ) > 0
                SX1->( FieldPut( FieldPos( aEstrut[j] ), aDados[i][j] ) )
            endif
        next
        MsUnLock()
        AtuSX1Hlp("P." + AllTrim(SX1->X1_GRUPO) + AllTrim(SX1->X1_ORDEM) + ".", aDados[i][nLenCol+1], .t.)
    endif
next

RestArea( aAreaDic )
RestArea( aArea )

return nil

/*/{Protheus.doc} AtuSX1Hlp
Função de processamento da gravação dos Helps de Perguntas

@author jrscatolon@jrscatolon.com.br
@since  21/11/2018
@version 1.0
/*/
static function AtuSX1Hlp(cKey, aHelp, lUpdate)
local cFilePor := "SIGAHLP.HLP"
local cFileEng := "SIGAHLE.HLE"
local cFileSpa := "SIGAHLS.HLS"
local nRet := 0
local cHelp := ""
local i, nLen
default cKey := ""
default aHelp := nil
default lUpdate := .F.
     
if !Empty(cKey) 
     
    // Português
    cHelp := ""

    if ValType(aHelp[1]) == "C"
        cHelp := aHelp[1]
    elseif ValType(aHelp[1]) == "A"
        nLen := Len(aHelp[1])
        for i := 1 to nLen
            cHelp += Iif(!Empty(cHelp), CRLF, "") + Iif(ValType(aHelp[1][i]) == "C", aHelp[1][i], "")
        next
    endif

    if !Empty(cHelp)
        nRet := SPF_SEEK(cFilePor, cKey, 1)
        if nRet < 0
            SPF_INSERT(cFilePor, cKey, , , cHelp)
        else
            if lUpdate
                SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
            endif
        endif
    endif
    
    // Espanhol
    cHelp := ""

    if ValType(aHelp[2]) == "C"
        cHelp := aHelp[2]
    elseif ValType(aHelp[2]) == "A"
        nLen := Len(aHelp[2])
        for i := 1 to nLen
            cHelp += Iif(!Empty(cHelp), CRLF, "") + Iif(ValType(aHelp[2][i]) == "C", aHelp[2][i], "")
        next
    endif

    if !Empty(cHelp)
        nRet := SPF_SEEK(cFileSpa, cKey, 1)
        if nRet < 0
            SPF_INSERT(cFileSpa, cKey, , , cHelp)
        else
            if lUpdate
                SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
            endif
        endif
    endif

    // Inglês
    cHelp := ""

    if ValType(aHelp[3]) == "C"
        cHelp := aHelp[3]
    elseif ValType(aHelp[3]) == "A"
        nLen := Len(aHelp[3])
        for i := 1 to nLen
            cHelp += Iif(!Empty(cHelp), CRLF, "") + Iif(ValType(aHelp[3][i]) == "C", aHelp[3][i], "")
        next
    endif

    if !Empty(cHelp)
        nRet := SPF_SEEK(cFileEng, cKey, 1)
        if nRet < 0
            SPF_INSERT(cFileEng, cKey, , , cHelp)
        else
            if lUpdate
                SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
            endif
        endif
    endif
endif

return nil


/*/{Protheus.doc} GetNroTrato
Retorna o numero de tratos parametrizado no sistema.
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@return N, Numero de tratos parametrizado
/*/
user function GetNroTrato()
local nNroTrt := 0

    DbUseArea(.t., "TOPCONN", TCGenQry(,,;
        " select max(qtde_trato) max_trato" +;
          " from (" +;
             " select Z0M.Z0M_FILIAL, Z0M.Z0M_CODIGO, Z0M.Z0M_VERSAO, Z0M.Z0M_DIA, count(Z0M.Z0M_TRATO) qtde_trato" +; 
               " from " + RetSqlName("Z0M") + " Z0M " +;
              " where Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" +;
                " and Z0M.D_E_L_E_T_ = ' '" +;
           " group by Z0M.Z0M_FILIAL, Z0M.Z0M_CODIGO, Z0M.Z0M_VERSAO, Z0M.Z0M_DIA " +;
               " ) qtde_trato"), "TMPTBL", .f., .f.)
    if (nNroTrt := GetMV("VA_NTRATO",,4)) < TMPTBL->MAX_TRATO
        Help(,, "Nro de tratos",, "O parâmetro 'VA_NTRATO' que define o número máximo de tratos é menor que a maior quandidade de tratos prevista para um dia já gravada pela rotina. O parâmetro será ignorado e será utilizado a quantidade de " + AllTrim(Str(TMPTBL->MAX_TRATO)) + " para a rotina.", 1, 0,,,,,, {"Por favor, altere o parametro VA_NTRATO para um valor superior ou igual a " + AllTrim(Str(TMPTBL->MAX_TRATO)) + "."})
        nNroTrt := TMPTBL->MAX_TRATO
    elseif nNroTrt > 9
        Help(,, "Nro de tratos",, "O parâmetro 'VA_NTRATO' que define o número máximo de tratos é maior que 9.", 1, 0,,,,,, {"Por favor, altere o parametro 'VA_NTRATO' para um valor menor que ou igual a 9."})
        nNroTrt := 9
    endif
    TMPTBL->(DbCloseArea())

return nNroTrt

/*/{Protheus.doc} vpcp06ver
Calcula a última versão de um 
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@return C, A última versão do plano nutricional passado como parametro 
@param cCodigo, characters, Código do plano nutricional a ser consultado
/*/
user function vpcp06ver(cCodigo)
local aArea := GetArea()
local cMaxVersao := ""

DbUseArea(.t., "TOPCONN", TCGenQry(,,"select max(Z0M.Z0M_VERSAO) Z0M_VERSAO" +;
                                      " from " + RetSqlName("Z0M") + " Z0M" +;
                                     " where Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" +;
                                       " and Z0M.Z0M_CODIGO = '" + cCodigo + "'" +;
                                       " and Z0M.D_E_L_E_T_ = ' ' "),"MAXVER", .f., .f.)

    cMaxVersao :=  Iif(MAXVER->(Eof()), StrZero(1, TamSX3("Z0M_VERSAO")[1]), MAXVER->Z0M_VERSAO)

MAXVER->(DbCloseArea())
if !Empty(aArea)
    RestArea(aArea)
endif
return cMaxVersao

/*/{Protheus.doc} CommitZ0M
Grava os dados na tabela ZM0

@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@param oModel, object, Modelo de dados da tela
/*/
static function CommitZ0M(oModel)
local nOperation := oModel:GetOperation()
local lRet := .t.
local lFound := .f.
local oFieldModel, oGridModel
local i, j, nLen

DbSelectArea("Z0M")
DbSetOrder(1) // Z0M_FILIAL+Z0M_CODIGO+Z0M_VERSAO+Z0M_DIA+Z0M_TRATO

if nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE 
    oFieldModel := oModel:GetModel('MdField' + cAlias)
    oGridModel :=  oModel:GetModel('MdGrid' + cAlias)
    
    nLen := oGridModel:Length()
    for i := 1 to nLen
        oGridModel:GoLine(i)
        for j := 1 to nNroTrato
            if !Empty(oGridModel:GetValue("Z0M_DIETA" + Str(j, 1))) .and. !Empty(oGridModel:GetValue("Z0M_QUANT" + Str(j, 1)))
                if nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE
                    lFound := Z0M->(DbSeek(FWxFilial("Z0M")+;
                                    oFieldModel:GetValue("Z0M_CODIGO")+;
                                    oFieldModel:GetValue("Z0M_VERSAO")+;
                                    oGridModel:GetValue("Z0M_DIA")+;
                                    Str(j, 1)))
                    if lFound .and. oGridModel:IsDeleted()
                        RecLock("Z0M", !lFound)
                            DbDelete()
                        MsUnlock()
                    else
                        RecLock("Z0M", !lFound)
                           Z0M->Z0M_FILIAL := FWxFilial("Z0M")
                           Z0M->Z0M_CODIGO := oFieldModel:GetValue("Z0M_CODIGO")
                           Z0M->Z0M_VERSAO := oFieldModel:GetValue("Z0M_VERSAO")
                           Z0M->Z0M_DESCRI := oFieldModel:GetValue("Z0M_DESCRI")
                           Z0M->Z0M_DATA   := oFieldModel:GetValue("Z0M_DATA")  
                           Z0M->Z0M_PESO   := oFieldModel:GetValue("Z0M_PESO")  
                           Z0M->Z0M_DIA    := oGridModel:GetValue("Z0M_DIA")
                           Z0M->Z0M_TRATO  := Str(j, 1)
                           Z0M->Z0M_DIETA  := oGridModel:GetValue("Z0M_DIETA" + Str(j, 1))
                           Z0M->Z0M_QUANT  := oGridModel:GetValue("Z0M_QUANT" + Str(j, 1))
                        MsUnlock()
                    endif
                elseif nOperation == MODEL_OPERATION_DELETE
                    if Z0M->(DbSeek(FWxFilial("Z0M")+;
                             oFieldModel:GetValue("Z0M_CODIGO")+;
                             oFieldModel:GetValue("Z0M_VERSAO")+;
                             oGridModel:GetValue("Z0M_DIA")+;
                             Str(j, 1)))
                        RecLock("Z0M", .f.)
                            DbDelete()
                        MsUnlock()
                    endif
                endif
            endif 
        next
    next


    TCSqlExec(" delete from " + oTmpZ0M:GetRealName() ) 
    TCSqlExec(;
               " insert into " + oTmpZ0M:GetRealName() + "(Z0M_CODIGO, Z0M_VERSAO, Z0M_DESCRI)" +;
               " select Z0M.Z0M_CODIGO, max(Z0M.Z0M_VERSAO) Z0M_VERSAO, Z0M.Z0M_DESCRI" +;
                 " from " + RetSqlName("Z0M") + " Z0M" +;
                " where Z0M.Z0M_FILIAL = '" + xFilial("Z0M") + "'" +;
                  " and Z0M.D_E_L_E_T_ = ' '" +;
             " group by Z0M.Z0M_CODIGO, Z0M.Z0M_DESCRI" ;
             ) 

endif
return lRet

/*/{Protheus.doc} ModelValid
Valida o modelo 

@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@return Logico, Retorna a validação do modelo
@param oModel, object, Objeto com o modelo de dados
/*/
static function ModelValid(oModel)
local lRet := .t.
local nOperation := oModel:GetOperation()
local oGridModel := oModel:GetModel('MdGrid' + cAlias)

if lRet .and. nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_INSERT 
    if oGridModel:IsEmpty()
        Help(,, "Obrigatório o preenchimento dos dias de dieta.",, "Nenhum dia de dieta foi preenchido.", 1, 0,,,,,, {"Por favor, preencha os dias de dieta."})
        lRet := .f.
    endif 
endif

return lRet
