
// #########################################################################################
// Projeto: Trato
// Fonte  : vapcpa08
// ---------+------------------------------+------------------------------------------------
// Data     | Autor                        | Descrição
// ---------+------------------------------+------------------------------------------------
// 20190815 | jrscatolon@jrscatolon.com.br | Resumo de trato
//          |                              | 
//          |                              | 
// ---------+------------------------------+------------------------------------------------

#include 'Protheus.ch'
#include 'ParmType.ch'
#include "FWMVCDef.ch"

#define _MODEL .t.
#define _VIEW  .f.

static aCposCab := { "Z0S_EQUIP", "ZV0_IDENT", "Z0U_NOME", "Z0T_ROTA", "Z05_KGMNDI" }
static aCposItens := { "Z0T_ROTA", "Z06_TRATO", "Z06_DIETA", "Z05_KGMNDI" }
static cEquip := ""
static cRota := ""
static aCab := {}
static nItem := 0

/*/{Protheus.doc} vapcpa08
Explode o Resumo de trato.
@author guima
@since 18/09/2019
@version 1.0
@return nil
@param dDataTrato, date, Data de referencia do trato
@param cVersao, characters, Versão de referencia do trato
@param cFilterPar, characters, Filtro para a query que carrega os dados do trato
@type function
/*/
user function vapcpa08(dDataTrato, cVersao, cFilterPar)
local aParm := {mv_par01, mv_par02}
local lInclui := nil
local lAltera := nil
local aArea := GetArea()
local aEnButt := { {.f., nil},;         // 1 - Copiar
                   {.f., nil},;         // 2 - Recortar
                   {.f., nil},;         // 3 - Colar
                   {.f., nil},;         // 4 - Calculadora
                   {.f., nil},;         // 5 - Spool
                   {.f., nil},;         // 6 - Imprimir
                   {.f., nil},;         // 7 - Confirmar
                   {.t., "Fechar"},;    // 8 - Cancelar
                   {.f., nil},;         // 9 - WalkTrhough
                   {.f., nil},;         // 10 - Ambiente
                   {.f., nil},;         // 11 - Mashup
                   {.t., nil},;         // 12 - Help
                   {.f., nil},;         // 13 - Formulário HTML
                   {.f., nil},;         // 14 - ECM
                   {.f., nil} }         // 15 - Salvar e Criar novo
local cPerg := "VAPCPA08"
local lContinua
local cMsg := ""

private cFilter := Iif(cFilterPar == nil, "", cFilterPar)

    if Type("Inclui") == 'U'
        private Inclui := .f.
    else
        lInclui := Inclui
        Inclui := .f.
    endif
    
    if Type("Altera") == 'U'
        private Altera := .f.
    else
        lAltera := Altera
        Altera := .f.
    endif

    AtuSX1(@cPerg)

    if dDataTrato == nil
        lContinua := Pergunte(cPerg)
    else
        mv_par01 := dDataTrato
        mv_par02 := cVersao
    endif

    DbUseArea(.t., "TOPCONN", TCGenQry(,,;
             " select Z0T_ROTA, Z06_TRATO, count(Z06_DIETA) NroDietas" +;
               " from (" +;
                     " select distinct Z0T_ROTA, Z06_TRATO, Z06_DIETA" +;
                       " from " + RetSqlName("Z0T") + " Z0T" +;
                       " join " + RetSqlName("Z06") + " Z06" +;
                         " on Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                        " and Z06.Z06_DATA   = Z0T.Z0T_DATA" +;
                        " and Z06.Z06_VERSAO = Z0T.Z0T_VERSAO" +;
                        " and Z06.Z06_CURRAL = Z0T.Z0T_CURRAL" +;
                        " and Z06.D_E_L_E_T_ = ' '" +;
                      " where Z0T.Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" +;
                        " and Z0T.Z0T_DATA   = '" + DToS(mv_par01) + "'" +;
                        " and Z0T.Z0T_VERSAO = '" + mv_par02 + "'" +;
                        " and Z0T.Z0T_ROTA   <> '      '" +;
                        " and Z0T.D_E_L_E_T_ = ' '" +;
                    " ) ROTA" +;
           " group by Z0T_ROTA, Z06_TRATO" +;
             " having count(Z06_DIETA) > 1" ;
                                         ),"ROTA", .f., .t.)

    while !ROTA->(Eof())
        cMsg += Iif(!Empty(cMsg), CRLF, "") + "Rota: " + ROTA->Z0T_ROTA + " - Trato: " + ROTA->Z06_TRATO
        ROTA->(DbSkip())
    end
    ROTA->(DbCloseArea())

    if !Empty(cMsg)
        U_MsgInf("A(s) rota(s) abaixo possue(m) mais de uma dieta no trato. Por favor verifique." + CRLF + cMsg, "Atenção", "Rotas inválidas.")
    endif

    FWExecView('Resumo', 'VAPCPA08', MODEL_OPERATION_VIEW,, { || .t. },,,aEnButt)

    SetKey(VK_F4, nil)

Inclui := lInclui
Altera := lAltera
mv_par01 := aParm[1]
mv_par02 := aParm[2]
return nil

/*/{Protheus.doc} ModelDef
Modelo de dados da rotina
@author jr.andre
@since 18/09/2019
@version 1.0
@return MPFormModel, Modelo de dados

@type function
/*/
static function ModelDef()
local oModel := nil
local oStrCabG := GridStruct(_MODEL, aCposCab)
local oStrIteG := GridStruct(_MODEL, aCposItens)

local bLoadFld := {|oModel, lCopia| LoadForm(oModel, lCopia) }
local bLoadCab := {|oFormGrid, lCopia| LoadCabec(oFormGrid, lCopia) }
local bLoadIte := {|oFormGrid, lCopia| LoadItens(oFormGrid, lCopia) }

oModel := MPFormModel():New("MDVAPCPA08", /*bPreValid*/, /*bPostValid*/, /*bCommit*/, /*bCancel*/)
oModel:SetDescription("Resumo de Trato")

oModel:AddFields("MdField", /*cOwner*/, oStrCabG, /*bPreValid*/, /*bPosValid*/, bLoadFld)
oModel:AddGrid("MdGridCab", "MdField", oStrCabG, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, bLoadCab)
oModel:AddGrid("MdGridIte", "MdGridCab", oStrIteG, /*bLinePre*/,/*bLinePost*/,/*bPre */,/*bPost*/, bLoadIte)

// Definição de Descrição 
oModel:GetModel("MdField"):SetDescription("nao_aparece")
oModel:GetModel("MdGridCab"):SetDescription("Equipamento")
oModel:GetModel("MdGridIte"):SetDescription("Detalhe")

oModel:GetModel("MdGridCab"):SetNoDeleteLine(.t.)
oModel:GetModel("MdGridIte"):SetNoDeleteLine(.t.)

oModel:GetModel("MdGridCab"):SetNoInsertLine(.t.)
oModel:GetModel("MdGridIte"):SetNoInsertLine(.t.)

// Cria a chave primária 
oModel:SetPrimaryKey({})

oModel:SetRelation("MdGridIte", {{"Z0T_ROTA", "Z0T_ROTA"}}, "Z0T_ROTA+Z06_TRATO")

return oModel

/*/{Protheus.doc} ViewDef
Definição da interface da rotina
@author jr.andre
@since 18/09/2019
@version 1.0
@return FwFormView, Interface da tela
@type function
/*/
static function ViewDef()
local oView := nil
local oModel := ModelDef()
local oStrCabG := GridStruct(_VIEW, aCposCab)
local oStrIteG := GridStruct(_VIEW, aCposItens)

    oView := FwFormView():New()
    oView:SetModel(oModel)

    oView:AddGrid("VwGridCab", oStrCabG, "MdGridCab")
    oView:AddGrid("VwGridIte", oStrIteG, "MdGridIte")

    oStrCabG:SetProperty("*",   MVC_VIEW_CANCHANGE, .f.)
    oStrIteG:SetProperty("*",   MVC_VIEW_CANCHANGE, .f.)

    oView:CreateVerticalBox("CABGRID", 60)
    oView:CreateVerticalBox("ITEMGRID", 40)

    oView:SetOwnerView("VwGridCab", "CABGRID")
    oView:SetOwnerView("VwGridIte", "ITEMGRID")

    oView:SetCloseOnOk({||.t.})

    oView:SetNoInsertLine("VwGridCab")
    oView:SetNoInsertLine("VwGridIte")

    oView:SetNoDeleteLine("VwGridCab")
    oView:SetNoDeleteLine("VwGridIte")

    oView:EnableTitleView('VwGridCab', "Equipamento")
    oView:EnableTitleView('VwGridIte', "Detalhe")

    oStrIteG:RemoveField("Z0T_ROTA")

    SetKey(VK_F4, {|| Exportar()})
    oView:AddUserButton( 'Gerar Arquivo', 'CLIPS', {|oView| Exportar()}, "Gera o arquivo de trato <F4>.", VK_F4,,.t.)

return oView

/*/{Protheus.doc} GridStruct
Monta estrutura das grids
@author jr.andre
@since 18/09/2019
@version 1.0
@return objeto, estrutura do model ou da view
@param lTipo, logical, _MODEL ou _VIEW
@param aCpos, array, Lista dos campos que pertencem a estrutura
@type function
/*/
static function GridStruct(lTipo, aCpos)
local aArea := GetArea()
local oStruct
local i, nLen
local aCBox

if lTipo // Model
    oStruct := FWFormModelStruct():New()
    SX3->(DbSetOrder(2)) // X3_CAMPO
    nLen := Len(aCpos)
    for i := 1 to nLen
        SX3->(DbSeek(aCpos[i]))
        aCBox := Iif(!Empty(X3CBox()),StrToKArr(X3CBox(), ";"),nil)
        oStruct:AddField(;
             X3Titulo(),;               // [01]  C   Titulo do campo
             X3Descric(),;              // [02]  C   ToolTip do campo
             AllTrim(SX3->X3_CAMPO),;   // [03]  C   Id do Field
             TamSX3(SX3->X3_CAMPO)[3],; // [04]  C   Tipo do campo
             TamSX3(SX3->X3_CAMPO)[1],; // [05]  N   Tamanho do campo
             TamSX3(SX3->X3_CAMPO)[2],; // [06]  N   Decimal do campo
             nil,;                      // [07]  B   Code-block de validação do campo
             nil,;                      // [08]  B   Code-block de validação When do campo
             aCBox,;                    // [09]  A   Lista de valores permitido do campo
             .f.,;                      // [10]  L   Indica se o campo tem preenchimento obrigatorio
             nil,;                      // [11]  B   Code-block de inicializacao do campo
             .f.,;                      // [12]  L   Indica se trata-se de um campo chave
             .t.,;                      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
             .f.)                       // [14]  L   Indica se o campo é virtual
    next
else // View
    oStruct := FWFormViewStruct():New()
    nLen := Len(aCpos)
    for i := 1 to nLen
        SX3->(DbSetOrder(2))
        if SX3->(DbSeek(Padr(aCpos[i], Len(SX3->X3_CAMPO))))
            oStruct:AddField(;
                AllTrim(aCpos[i]),;             // [01]  C   Nome do Campo
                StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                AllTrim(X3Titulo()),;           // [03]  C   Titulo do campo
                X3Descric(),;                   // [04]  C   Descricao do campo
                {"Help"},;                      // [05]  A   Array com Help
                TamSX3(SX3->X3_CAMPO)[3],;      // [06]  C   Tipo do campo
                AllTrim(SX3->X3_PICTURE),;      // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                SX3->X3_F3,;                    // [09]  C   Consulta F3
                .f.,;                           // [10]  L   Indica se o campo é alteravel
                nil,;                           // [11]  C   Pasta do campo
                nil,;                           // [12]  C   Agrupamento do campo
                nil,;                           // [13]  A   Lista de valores permitido do campo (Combo)
                nil,;                           // [14]  N   Tamanho máximo da maior opção do combo
                nil,;                           // [15]  C   Inicializador de Browse
                nil,;                           // [16]  L   Indica se o campo é virtual
                nil,;                           // [17]  C   Picture Variável
                nil;                            // [18]  L   Indica pulo de linha após o campo
            )
        endif
    next
endif

RestArea(aArea)
return oStruct

/*/{Protheus.doc} LoadForm
Retorna array com dados vazios para o formulario que é obrigatório. 
@author jr.andre
@since 18/09/2019
@version 1.0
@return arrya, { "", "", "", "", 0 }
@type function
/*/
static function LoadForm(); return { "", "", "", "", 0 }

/*/{Protheus.doc} LoadCabec
Carrega os dados da grid de cabeçalho
@author jr.andre
@since 18/09/2019
@version 1.0
@return array, retorna os dados do cabeçalho
@param oFormGrid, object, objeto FWFormGrid passado pelo loader
@param lCopia, logical, informa se trata-se de uma cópia
@type function
/*/
static function LoadCabec(oFormGrid, lCopia)
local aArea := GetArea()

aCab := {}
nItem := 0

    DbUseArea(.t., "TOPCONN", TCGenQry(,,;
             " with QBASE as (" +;
                  " select ZG1_COD, sum(ZG1_QUANT) QUANT" +;
                    " from " + RetSqlName("ZG1") + " ZG1" +;
                   " where ZG1.ZG1_FILIAL = '" + FWxFilial("ZG1") + "'" +;
                     " and ZG1.ZG1_DTALT  <= '" + DToS(mv_par01) + "'" +;
                     " and ZG1.ZG1_SEQ    = (" +;
                         " select max(ZG1_SEQ)" +;
                           " from (" +;
                                " select max(ZG1_SEQ) ZG1_SEQ" +;
                                  " from " + RetSqlName("ZG1") + " MAXZG1" +;
                                 " where MAXZG1.ZG1_FILIAL = ZG1.ZG1_FILIAL" +;
                                   " and MAXZG1.ZG1_COD    = ZG1.ZG1_COD" +;
                                   " and MAXZG1.ZG1_DTALT  <= '" + DToS(mv_par01) + "'" +;
                                   " and MAXZG1.D_E_L_E_T_ = ' '" +;
                                " ) ZG1" +;
                         " )" +;
                     " and ZG1.D_E_L_E_T_ = ' '" +;
                " group by ZG1_COD" +;
             " )" +;
             " , MAXSEQ as (" +;
                  " select ZG1.ZG1_COD, ZG1.ZG1_COMP, max(ZG1.ZG1_SEQ) ZG1_SEQ" +;
                    " from " + RetSqlName("ZG1") + " ZG1" +;
                   " where ZG1.ZG1_FILIAL = '" + FWxFilial("ZG1") + "'" +;
                     " and ZG1.ZG1_COD    = ZG1.ZG1_COD" +;
                     " and ZG1.ZG1_DTALT  <= '" + DToS(mv_par01) + "'" +;
                     " and ZG1.ZG1_SEQ    = (" +;
                         " select max(ZG1_SEQ)" +;
                           " from (" +;
                                " select max(ZG1_SEQ) ZG1_SEQ" +;
                                  " from " + RetSqlName("ZG1") + " MAXZG1" +;
                                 " where MAXZG1.ZG1_FILIAL = ZG1.ZG1_FILIAL" +;
                                   " and MAXZG1.ZG1_COD    = ZG1.ZG1_COD" +;
                                   " and MAXZG1.ZG1_DTALT  <= '" + DToS(mv_par01) + "'" +;
                                   " and MAXZG1.D_E_L_E_T_ = ' '" +;
                                " ) ZG1" +;
                         " )" +;
                     " and ZG1.D_E_L_E_T_ = ' '" +;
                " group by ZG1.ZG1_COD, ZG1.ZG1_COMP" +;
             " )" +;
             " , ZG1 as (" +;
                  " select ZG1.ZG1_COD, ZG1.ZG1_COMP, ZG1_QUANT" +;
                    " from " + RetSqlName("ZG1") + " ZG1" +;
                    " join MAXSEQ" +;
                      " on ZG1.ZG1_COD    = MAXSEQ.ZG1_COD" +;
                     " and ZG1.ZG1_COMP   = MAXSEQ.ZG1_COMP" +;
                     " and ZG1.ZG1_SEQ    = MAXSEQ.ZG1_SEQ" +;
                   " where ZG1.ZG1_FILIAL = '" + FWxFilial("ZG1") + "'" +;
                     " and ZG1.D_E_L_E_T_ = ' '" +;
                     " and ZG1.ZG1_DTALT  <= '" + DToS(mv_par01) + "'" +;
                     " and ZG1.ZG1_COD in (" +;
                             " select distinct Z06_DIETA" +;
                               " from " + RetSqlName("Z06") + " Z06" +;
                              " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                                " and Z06.Z06_DATA   = '" + DToS(mv_par01) + "'" +;
                                " and Z06.Z06_VERSAO = '" + mv_par02 + "'" +;
                                " and Z06.D_E_L_E_T_ = ' '" +;
                         " )" +;
             " )" +;
             " , CARREGAMENTO as (" +;
                            " select Z0S.Z0S_EQUIP" +;
                                 " , isnull(ZV0.ZV0_IDENT, '          ') ZV0_IDENT" +;
                                 " , Z0S.Z0S_OPERAD" +;
                                 " , isnull(Z0U.Z0U_NOME, '                                                                                                    ') Z0U_NOME" +;
                                 " , Z0T.Z0T_ROTA" +;
                                 " , Z06.Z06_TRATO" +;
                                 " , Z06.Z06_DIETA" +;
                                 " , case " +;
                                        " when log10(ZV0.ZV0_DIVISA) - floor(log10(ZV0.ZV0_DIVISA)) = 0 " +;
                                        " then round(sum((100*Z06.Z06_KGMSTR*ZG1.ZG1_QUANT*Z05.Z05_CABECA)/(QBASE.QUANT*Z0V.Z0V_INDMS)), -1*log10(ZV0.ZV0_DIVISA))" +;
                                        " else round(sum((100*Z06.Z06_KGMSTR*ZG1.ZG1_QUANT*Z05.Z05_CABECA)/(QBASE.QUANT*Z0V.Z0V_INDMS))*2, -1*round(log10(ZV0.ZV0_DIVISA*2), 0))/2" +;
                                    " end  QTDMNCOMP" +;
                              " from " + RetSqlName("Z0T") + " Z0T" +;
                              " join " + RetSqlName("Z05") + " Z05" +;
                                " on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" +;
                               " and Z05.Z05_DATA   = Z0T.Z0T_DATA" +;
                               " and Z05.Z05_VERSAO = Z0T.Z0T_VERSAO" +;
                               " and Z05.Z05_CURRAL = Z0T.Z0T_CURRAL" +;
                               " and Z05.D_E_L_E_T_ = ' '" +;
                              " join " + RetSqlName("Z06") + " Z06" +;
                                " on Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                               " and Z06.Z06_DATA   = Z05.Z05_DATA" +;
                               " and Z06.Z06_VERSAO = Z05.Z05_VERSAO" +;
                               " and Z06.Z06_LOTE   = Z05.Z05_LOTE" +;
                               " and Z06.D_E_L_E_T_ = ' '" +;
                              " join ZG1" +;
                                " on ZG1.ZG1_COD    = Z06.Z06_DIETA" +;
                              " join QBASE" +;
                                " on QBASE.ZG1_COD = Z06.Z06_DIETA" +;
                              " join " + RetSqlName("Z0V") + " Z0V" +;
                                " on Z0V.Z0V_FILIAL = '" + FWxFilial("Z0V") + "'" +;
                               " and Z0V.Z0V_COMP   = ZG1.ZG1_COMP" +;
                               " and Z0V.Z0V_DATA   = Z0T.Z0T_DATA" +;
                               " and Z0V_VERSAO     = Z0T.Z0T_VERSAO" +;
                               " and Z0V.D_E_L_E_T_ = ' '" +;
                         " left join " + RetSqlName("Z0S") + " Z0S" +;
                                " on Z0S.Z0S_FILIAL = '" + FWxFilial("Z0S") + "'" +;
                               " and Z0S.Z0S_DATA   = Z0T.Z0T_DATA" +;
                               " and Z0S.Z0S_VERSAO = Z0T.Z0T_VERSAO" +;
                               " and Z0S.Z0S_ROTA   = Z0T.Z0T_ROTA" +;
                               " and Z0S.D_E_L_E_T_ = ' '" +;
                         " left join " + RetSqlName("ZV0") + " ZV0" +;
                                " on ZV0.ZV0_FILIAL = '" + FWxFilial("ZV0") + "'" +;
                               " and ZV0.ZV0_CODIGO = Z0S.Z0S_EQUIP" +;
                               " and ZV0.D_E_L_E_T_ = ' '" +;
                         " left join " + RetSqlName("Z0U") + " Z0U" +;
                                " on Z0U.Z0U_FILIAL = '" + FWxFilial("Z0U") + "'" +;
                               " and Z0U.Z0U_CODIGO = Z0S.Z0S_OPERAD" +;
                               " and Z0U.D_E_L_E_T_ = ' '" +;
                             " where Z0T.Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" +;
                               " and Z0T.Z0T_DATA   = '" + DToS(mv_par01) + "'" +;
                               " and Z0T.Z0T_VERSAO = '" + mv_par02 + "'" +;
                               " and Z0T.Z0T_ROTA   <> '      '" +;
                               Iif(Empty(cFilter), "", " and (" + cFilter + ")") +;
                               " and Z0T.D_E_L_E_T_ = ' '" +;
                          " group by Z0S.Z0S_EQUIP" +;
                                 " , ZV0.ZV0_IDENT" +;
                                 " , Z0S.Z0S_OPERAD" +;
                                 " , Z0U.Z0U_NOME" +;
                                 " , Z0T.Z0T_ROTA" +;
                                 " , Z06.Z06_TRATO" +;
                                 " , Z06.Z06_DIETA" +;
                                 " , ZV0.ZV0_DIVISA" +;
             ")" +;
                   " select Z0S_EQUIP" +;
                        " , ZV0_IDENT" +;
                        " , Z0S_OPERAD" +;
                        " , Z0U_NOME" +;
                        " , Z0T_ROTA" +;
                        " , sum(QTDMNCOMP) QTDMNCOMP" +;
                     " from CARREGAMENTO" +;
                 " group by Z0S_EQUIP" +;
                        " , ZV0_IDENT" +;
                        " , Z0S_OPERAD" +;
                        " , Z0U_NOME" +;
                        " , Z0T_ROTA";
                                         ),"ROTAS", .f., .f.)

        while !ROTAS->(Eof())
            if !Empty(cEquip)
                cEquip := ROTAS->ZV0_IDENT
                cRota := ROTAS->Z0T_ROTA
            endif
            AAdd(aCab, {0, {ROTAS->Z0S_EQUIP, ROTAS->ZV0_IDENT, ROTAS->Z0U_NOME, ROTAS->Z0T_ROTA, Round(ROTAS->QTDMNCOMP, TamSX3("Z05_KGMNDI")[2])}})
            ROTAS->(DbSkip())
        end
    ROTAS->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif
return aCab

/*/{Protheus.doc} LoadItens
Carrega os dados da grid de itens
@author jr.andre
@since 18/09/2019
@version 1.0
@return array, retorna os dados dos itens
@param oFormGrid, object, objeto FWFormGrid passado pelo loader
@param lCopia, logical, informa se trata-se de uma cópia
@type function
/*/
static function LoadItens(oFormGrid, lCopia)
local aArea := GetArea()
local aDados := {}
local oModel := FWModelActive()

    nItem++

if !Empty(aCab)
    DbUseArea(.t., "TOPCONN", TCGenQry(,,;
             " with QBASE as (" +;
                  " select ZG1_COD, sum(ZG1_QUANT) QUANT" +;
                    " from " + RetSqlName("ZG1") + " ZG1" +;
                   " where ZG1.ZG1_FILIAL = '" + FWxFilial("ZG1") + "'" +;
                     " and ZG1.ZG1_DTALT  <= '" + DToS(mv_par01) + "'" +;
                     " and ZG1.ZG1_SEQ    = (" +;
                         " select max(ZG1_SEQ)" +;
                           " from (" +;
                                " select max(ZG1_SEQ) ZG1_SEQ" +;
                                  " from " + RetSqlName("ZG1") + " MAXZG1" +;
                                 " where MAXZG1.ZG1_FILIAL = ZG1.ZG1_FILIAL" +;
                                   " and MAXZG1.ZG1_COD    = ZG1.ZG1_COD" +;
                                   " and MAXZG1.ZG1_DTALT  <= '" + DToS(mv_par01) + "'" +;
                                   " and MAXZG1.D_E_L_E_T_ = ' '" +;
                                " ) ZG1" +;
                         " )" +;
                     " and ZG1.D_E_L_E_T_ = ' '" +;
                " group by ZG1_COD" +;
             " )" +;
             " , MAXSEQ as (" +;
                  " select ZG1.ZG1_COD, ZG1.ZG1_COMP, max(ZG1.ZG1_SEQ) ZG1_SEQ" +;
                    " from " + RetSqlName("ZG1") + " ZG1" +;
                   " where ZG1.ZG1_FILIAL = '" + FWxFilial("ZG1") + "'" +;
                     " and ZG1.ZG1_COD    = ZG1.ZG1_COD" +;
                     " and ZG1.ZG1_DTALT  <= '" + DToS(mv_par01) + "'" +;
                     " and ZG1.ZG1_SEQ    = (" +;
                         " select max(ZG1_SEQ)" +;
                           " from (" +;
                                " select max(ZG1_SEQ) ZG1_SEQ" +;
                                  " from " + RetSqlName("ZG1") + " MAXZG1" +;
                                 " where MAXZG1.ZG1_FILIAL = ZG1.ZG1_FILIAL" +;
                                   " and MAXZG1.ZG1_COD    = ZG1.ZG1_COD" +;
                                   " and MAXZG1.ZG1_DTALT  <= '" + DToS(mv_par01) + "'" +;
                                   " and MAXZG1.D_E_L_E_T_ = ' '" +;
                                " ) ZG1" +;
                         " )" +;
                     " and ZG1.D_E_L_E_T_ = ' '" +;
                " group by ZG1.ZG1_COD, ZG1.ZG1_COMP" +;
             " )" +;
             " , ZG1 as (" +;
                  " select ZG1.ZG1_COD, ZG1.ZG1_COMP, ZG1_QUANT" +;
                    " from " + RetSqlName("ZG1") + " ZG1" +;
                    " join MAXSEQ" +;
                      " on ZG1.ZG1_COD    = MAXSEQ.ZG1_COD" +;
                     " and ZG1.ZG1_COMP   = MAXSEQ.ZG1_COMP" +;
                     " and ZG1.ZG1_SEQ    = MAXSEQ.ZG1_SEQ" +;
                   " where ZG1.ZG1_FILIAL = '" + FWxFilial("ZG1") + "'" +;
                     " and ZG1.D_E_L_E_T_ = ' '" +;
                     " and ZG1.ZG1_DTALT  <= '" + DToS(mv_par01) + "'" +;
                     " and ZG1.ZG1_COD in (" +;
                             " select distinct Z06_DIETA" +;
                               " from " + RetSqlName("Z06") + " Z06" +;
                              " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                                " and Z06.Z06_DATA   = '" + DToS(mv_par01) + "'" +;
                                " and Z06.Z06_VERSAO = '" + mv_par02 + "'" +;
                                " and Z06.D_E_L_E_T_ = ' '" +;
                         " )" +;
             " )" +;
             " , CARREGAMENTO as (" +;
                  " select Z0S.Z0S_EQUIP" +;
                       " , isnull(ZV0.ZV0_IDENT, '          ') ZV0_IDENT" +;
                       " , Z0S.Z0S_OPERAD" +;
                       " , isnull(Z0U.Z0U_NOME, '                                                                                                    ') Z0U_NOME" +;
                       " , Z0T.Z0T_ROTA" +;
                       " , Z06.Z06_TRATO" +;
                       " , Z06.Z06_DIETA" +;
                       " , case " +;
                              " when log10(ZV0.ZV0_DIVISA) - floor(log10(ZV0.ZV0_DIVISA)) = 0 " +;
                              " then round(sum((100*Z06.Z06_KGMSTR*ZG1.ZG1_QUANT*Z05.Z05_CABECA)/(QBASE.QUANT*Z0V.Z0V_INDMS)), -1*log10(ZV0.ZV0_DIVISA))" +;
                              " else round(sum((100*Z06.Z06_KGMSTR*ZG1.ZG1_QUANT*Z05.Z05_CABECA)/(QBASE.QUANT*Z0V.Z0V_INDMS))*2, -1*round(log10(ZV0.ZV0_DIVISA*2), 0))/2" +;
                          " end  QTDMNCOMP" +;
                    " from " + RetSqlName("Z0T") + " Z0T" +;
                    " join " + RetSqlName("Z05") + " Z05" +;
                      " on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" +;
                     " and Z05.Z05_DATA   = Z0T.Z0T_DATA" +;
                     " and Z05.Z05_VERSAO = Z0T.Z0T_VERSAO" +;
                     " and Z05.Z05_CURRAL = Z0T.Z0T_CURRAL" +;
                     " and Z05.D_E_L_E_T_ = ' '" +;
                    " join " + RetSqlName("Z06") + " Z06" +;
                      " on Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                     " and Z06.Z06_DATA   = Z05.Z05_DATA" +;
                     " and Z06.Z06_VERSAO = Z05.Z05_VERSAO" +;
                     " and Z06.Z06_LOTE   = Z05.Z05_LOTE" +;
                     " and Z06.D_E_L_E_T_ = ' '" +;
                    " join ZG1" +;
                      " on ZG1.ZG1_COD    = Z06.Z06_DIETA" +;
                    " join QBASE" +;
                      " on QBASE.ZG1_COD = Z06.Z06_DIETA" +;
                    " join " + RetSqlName("Z0V") + " Z0V" +;
                      " on Z0V.Z0V_FILIAL = '" + FWxFilial("Z0V") + "'" +;
                     " and Z0V.Z0V_COMP   = ZG1.ZG1_COMP" +;
                     " and Z0V.Z0V_DATA   = Z0T.Z0T_DATA" +;
                     " and Z0V_VERSAO     = Z0T.Z0T_VERSAO" +;
                     " and Z0V.D_E_L_E_T_ = ' '" +;
               " left join " + RetSqlName("Z0S") + " Z0S" +;
                      " on Z0S.Z0S_FILIAL = '" + FWxFilial("Z0S") + "'" +;
                     " and Z0S.Z0S_DATA   = Z0T.Z0T_DATA" +;
                     " and Z0S.Z0S_VERSAO = Z0T.Z0T_VERSAO" +;
                     " and Z0S.Z0S_ROTA   = Z0T.Z0T_ROTA" +;
                     " and Z0S.D_E_L_E_T_ = ' '" +;
               " left join " + RetSqlName("ZV0") + " ZV0" +;
                      " on ZV0.ZV0_FILIAL = '" + FWxFilial("ZV0") + "'" +;
                     " and ZV0.ZV0_CODIGO = Z0S.Z0S_EQUIP" +;
                     " and ZV0.D_E_L_E_T_ = ' '" +;
               " left join " + RetSqlName("Z0U") + " Z0U" +;
                      " on Z0U.Z0U_FILIAL = '" + FWxFilial("Z0U") + "'" +;
                     " and Z0U.Z0U_CODIGO = Z0S.Z0S_OPERAD" +;
                     " and Z0U.D_E_L_E_T_ = ' '" +;
                   " where Z0T.Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" +;
                     " and Z0T.Z0T_DATA   = '" + DToS(mv_par01) + "'" +;
                     " and Z0T.Z0T_VERSAO = '" + mv_par02 + "'" +;
                     " and Z0T.Z0T_ROTA   <> '      '" +;
                     " and Z0T.D_E_L_E_T_ = ' '" +;
                " group by Z0S.Z0S_EQUIP" +;
                       " , ZV0.ZV0_IDENT" +;
                       " , Z0S.Z0S_OPERAD" +;
                       " , Z0U.Z0U_NOME" +;
                       " , Z0T.Z0T_ROTA" +;
                       " , Z06.Z06_TRATO" +;
                       " , Z06.Z06_DIETA" +;
                       " , ZV0.ZV0_DIVISA" +;
             ")" +;
                   " select Z0S_EQUIP" +;
                         ", ZV0_IDENT" +;
                         ", Z0S_OPERAD" +;
                         ", Z0U_NOME" +;
                         ", Z0T_ROTA" +;
                         ", Z06_TRATO" +;
                         ", Z06_DIETA" +;
                         ", sum(QTDMNCOMP) QTDMNCOMP" +;
                     " from CARREGAMENTO" +;
                    " where Z0S_EQUIP = '" + aCab[nItem][2][1] + "'" +;
                      " and Z0T_ROTA  = '" + aCab[nItem][2][4] + "'" +;
                 " group by Z0S_EQUIP" +;
                        " , ZV0_IDENT" +;
                        " , Z0S_OPERAD" +;
                        " , Z0U_NOME" +;
                        " , Z0T_ROTA" +;
                        " , Z06_TRATO" +;
                        " , Z06_DIETA" ;
                                         ),"ROTAS", .f., .f.)
        while !ROTAS->(Eof())
            AAdd(aDados, {0, {ROTAS->Z0T_ROTA, ROTAS->Z06_TRATO, ROTAS->Z06_DIETA, Round(ROTAS->QTDMNCOMP, TamSX3("Z05_KGMNDI")[2])}})
            ROTAS->(DbSkip())
        end
    ROTAS->(DbCloseArea())
endif

if !Empty(aArea)
    RestArea(aArea)
endif
return aDados

/*/{Protheus.doc} AtuSX1
Cria pergunta VAPCPA08 no SX1
@author jr.andre
@since 18/09/2019
@version 1.0
@return nil
@param cPerg, characters, descricao
@type function
/*/
static function AtuSX1(cPerg)
local aArea    := GetArea()
local aAreaDic := SX1->( GetArea() )
local aEstrut  := {}
local aStruDic := SX1->( dbStruct() )
local aDados   := {}
local i        := 0
local j        := 0
local nTam1    := Len( SX1->X1_GRUPO )
local nTam2    := Len( SX1->X1_ORDEM )

cPerg := PadR(cPerg, Len(SX1->X1_GRUPO))

if !SX1->( DbSeek( cPerg ) )

    aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
                 "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
                 "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
                 "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
                 "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
                 "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
                 "X1_IDFIL"  }
    
    if cPerg == "VAPCPA08  "
                                 //123456789012345678901234567890 
        AAdd( aDados, {cPerg,'01','Data?                         ','Data?                         ','Data?                         ','mv_ch1','D', 8,0,0,'G','','mv_par01','','','','','','','','','','','','','','','','','','','','','','','','','Z0R   ','S','','','','', {"Informe a data do trato." + CRLF + "<F3 Disponível>", "Informe a data do trato." + CRLF + "<F3 Disponível>", "Informe a data do trato." + CRLF + "<F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'02','Versão?                       ','Versão?                       ','Versão?                       ','mv_ch2','C', 4,0,0,'G','','mv_par02','','','','','','','','','','','','','','','','','','','','','','','','','      ','S','','','','', {"Informe a versão do trato." + CRLF + "<F3 Disponível>", "Informe a versão do trato" + CRLF + "<F3 Disponível>", "Informe a versão do trato." + CRLF + "<F3 Disponível>"}} )
    
    endif

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
//            u_UpSX1Hlp( "P." + AllTrim(SX1->X1_GRUPO) + AllTrim(SX1->X1_ORDEM) + ".", aDados[i][nLenCol+1], .t.)
        endif
    next
endif

Pergunte(cPerg, .f.)

RestArea( aAreaDic )
RestArea( aArea )

return nil

/*/{Protheus.doc} Exportar
Chama a rotina de exportação dos arquivios
@author jr.andre
@since 18/09/2019
@version 1.0
@return nil
@type function
/*/
static function Exportar()
local aParam := {mv_par01, mv_par02, mv_par03, mv_par04, mv_par05}
local aEnButt := { {.f., nil},;         // 1 - Copiar
                   {.f., nil},;         // 2 - Recortar
                   {.f., nil},;         // 3 - Colar
                   {.f., nil},;         // 4 - Calculadora
                   {.f., nil},;         // 5 - Spool
                   {.f., nil},;         // 6 - Imprimir
                   {.f., nil},;         // 7 - Confirmar
                   {.t., "Fechar"},;    // 8 - Cancelar
                   {.f., nil},;         // 9 - WalkTrhough
                   {.f., nil},;         // 10 - Ambiente
                   {.f., nil},;         // 11 - Mashup
                   {.t., nil},;         // 12 - Help
                   {.f., nil},;         // 13 - Formulário HTML
                   {.f., nil},;         // 14 - ECM
                   {.f., nil} }         // 15 - Salvar e Criar novo
local cPrgExp := "VAPCPA13X"
local oModel := FWModelActive()
local cVeiculo := oModel:GetModel("MdGridCab"):GetValue("Z0S_EQUIP")
local i, nLen

private aParRet := {}
private cRotSel  := ""
Private aTik    := {LoadBitmap( GetResources(), "LBTIK" ), LoadBitmap( GetResources(), "LBNO" )}


U_PosSX1({{"VAPCPA13X", "01", DTOS(mv_par01)}, {"VAPCPA13X", "02", 1}, {"VAPCPA13X", "03", cVeiculo}, {"VAPCPA13X", "04", Space(60)},  {"VAPCPA13X", "05", 2}})

if (Pergunte(cPrgExp, .t.))
    AAdd(aParRet, mv_par01)
    AAdd(aParRet, "0001")
    AAdd(aParRet, mv_par03)
    AAdd(aParRet, mv_par02)
    AAdd(aParRet, mv_par05)
    IF mv_par06 == 0
      mv_par06 := 1
    EndIf 
      AAdd(aParRet, mv_par06)
    //FWMsgRun(, {|| U_ExpBatTrt()}, "Processando", "Gerando arquivo...")
    U_ExpBatTrt()
endif

nLen := Len(aParam)
for i := 1 to nLen
    &("mv_par"+StrZero(i, 2)) := aParam[i]
next

return nil
