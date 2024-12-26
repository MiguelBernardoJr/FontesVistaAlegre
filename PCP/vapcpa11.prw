// #########################################################################################
// Projeto: Trato
// Fonte  : vapcpa11
// ---------+------------------------------+------------------------------------------------
// Data     | Autor                        | Descrição
// ---------+------------------------------+------------------------------------------------
// 20190227 | jrscatolon@jrscatolon.com.br | Explosão da estrutura do trato
//          |                              |  
//          |                              |  
// ---------+------------------------------+------------------------------------------------
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'

static aCpoZG1Fld := { "ZG1_COD", "B1_DESC", "B1_QB", "ZG1_SEQ", "QTDREF" }
static aCpoZG1Grd := { "ZG1_TRT", "ZG1_COMP", "B1_DESC", "ZG1_QUANT", "Z0H_INDMS", "QTDMS", "QTDMN", "Z0H_DATA", "Z0H_HORA" }

user function vapcpa11(cDieta, cVersao, dDtRef, cHrRef, nQuantMS)
local aArea := GetArea()
local aParam := {mv_par01, mv_par02, mv_par03, mv_par04, mv_par05}
local i, nLen 
local cPerg := "VAPCPA11"
local lContinua := .t.

default dDtRef := dDataBase
default cHrRef := Time()
default nQuantMS := 1

DbSelectArea("SB1")
DbSetOrder(1) // B1_FILIAL + B1_COD

DbSelectArea("ZG1")
DbSetOrder(6) // ZG1_FILIAL + ZG1_COD + ZG1_SEQ
    
AtuSX1(@cPerg)

while lContinua
    if cDieta == nil
        u_PosSX1( {;
                  {cPerg, "01", dDataBase};
                , {cPerg, "02", Time()};
                , {cPerg, "05", 1};
                } )
        lContinua := Pergunte(cPerg, .t.)
    else
        Pergunte(cPerg, .f.)
        mv_par01 := dDtRef
        mv_par02 := cHrRef
        mv_par03 := cDieta
        mv_par04 := cVersao
        mv_par05 := nQuantMS
    endif

    if lContinua
        if !SB1->(DbSeek(FWxFilial("SB1")+mv_par03))
            Help(/*Descontinuado*/,/*Descontinuado*/,"PRODUTO INVÁLIDO",/**/,"O produto " + AllTrim(mv_par03) + " não foi identificado.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, digite um produto válido ou selecione." + CRLF + "<F3 Disponível>" })
            lContinua := .f.
        elseif SB1->B1_X_TRATO <> '1'
            Help(/*Descontinuado*/,/*Descontinuado*/,"PRODUTO INVÁLIDO",/**/,"O produto " + AllTrim(mv_par03) + " não está definido como trato no cadastro de produtos.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, digite um produto válido ou selecione." + CRLF + "<F3 Disponível>" })
            lContinua := .f.
        elseif !ZG1->(DbSeek(FWxFilial("ZG1")+mv_par03+mv_par04)) 
            Help(/*Descontinuado*/,/*Descontinuado*/,"VERSÃO NÃO IDENTIFICADA",/**/,"A versão " + mv_par04 + " não foi encontrada para o produto " + AllTrim(mv_par03) + ".", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, digite uma versão válida para o produto ou selecione." + CRLF + "<F3 Disponível>" })
            lContinua := .f.
        elseif mv_par05 <= 0
            Help(/*Descontinuado*/,/*Descontinuado*/,"QUANTIDADE INVÁLIDA",/**/,"A quantidade deve ser superior e 0.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, digite uma quantidade válida."})
            lContinua := .f.
        endif
    endif

    if lContinua 
        FWExecView('Receita', 'VAPCPA11', MODEL_OPERATION_VIEW)
        lContinua := "VAPCPA11"$FunName()
    endif
end

nLen := Len(aParam)
for i := 1 to nLen
    &("mv_par"+StrZero(i,2)) := aParam[i]
next

if !Empty(aArea)
    RestArea(aArea)
endif
return nil

static function MenuDef()
local aRotina := {} 

//ADD OPTION aRotina TITLE OemToAnsi("Pesquisar")     ACTION "PesqBrw"             OPERATION 1 ACCESS 0 // "Pesquisar"
  ADD OPTION aRotina TITLE OemToAnsi("Visualizar")    ACTION "u_vapcpa11"          OPERATION 2 ACCESS 0 // "Visualizar"
//ADD OPTION aRotina TITLE OemToAnsi("Criar/Recriar") ACTION "u_RecriaTrato"       OPERATION 3 ACCESS 0 // "Copiar" 
//ADD OPTION aRotina TITLE OemToAnsi("Manutenção")    ACTION "u_vap05man"          OPERATION 4 ACCESS 0 // "Alterar"
//ADD OPTION aRotina TITLE OemToAnsi("Excluir")       ACTION "VIEWDEF.VAPCPA05"    OPERATION 5 ACCESS 0 // "Excluir" 
//ADD OPTION aRotina TITLE OemToAnsi("Copiar")        ACTION "VIEWDEF.VAPCPA05"    OPERATION 9 ACCESS 0 // "Copiar" 

return aRotina

static function ModelDef
local oModel := nil
local oStrZG1MFl := ZG1FldMStr()
local oStrZG1Grd := ZG1GrdMStr()

local bLoadForm := {|oModel, lCopia| LoadZG1F(oModel, lCopia) }
local bLoadGrid := {|oModel, lCopia| LoadZG1G(oModel, lCopia) }

oModel := MPFormModel():New('MDVAPCPA11', /*bPreValid*/, /*bPostValid*/, /*bCommit*/, /*bCancel*/)
oModel:SetDescription("Estrutura de Produtos")

oModel:AddFields('MdFieldZG1',/*cOwner*/, oStrZG1MFl,/*bPreValid*/, /*bPosValid*/, bLoadForm)
oModel:AddGrid('MdGridZG1', 'MdFieldZG1', oStrZG1Grd, /*bLinePre*/,/*bLinePost*/,/*bPre */,/*bPost*/, bLoadGrid)

oModel:GetModel("MdFieldZG1"):SetDescription("Dieta")
oModel:GetModel("MdGridZG1"):SetDescription("Estrutura")

oModel:SetOnlyQuery('MdFieldZG1', .t.)
oModel:SetOnlyQuery('MdGridZG1', .t.)

oModel:GetModel("MdGridZG1"):SetNoInsertLine(.t.)
oModel:GetModel("MdGridZG1"):SetNoDeleteLine(.t.)

oModel:SetPrimaryKey({"ZG1_COD"})

return oModel

static function ZG1GrdMStr()
local aArea := GetArea()
local oStruct := FWFormModelStruct():New()
local i, nLen
local aCBox

    // {"ZG1_COMP", "B1_DESC", "ZG1_QUANT", "Z0H_INDMS", "QTDMS", "QTDMN", "Z0H_DATA", "Z0H_HORA"}
    nLen := Len(aCpoZG1Grd)
    for i := 1 to nLen
        SX3->(DbSetOrder(2))
        if aCpoZG1Grd[i]$"QTDMN|QTDMS"
            SX3->(DbSeek("ZG1_QUANT ")) 
            oStruct:AddField(;
                 Iif(aCpoZG1Grd[i]$"QTDMN", "Qtd Mat Natu", "Qtd Mat Seca"),; // [01]  C   Titulo do campo
                 Iif(aCpoZG1Grd[i]$"QTDMN", "Quant de Matéria Natural ", "Quant de Matéria seca    "),; // [02]  C   ToolTip do campo
                 AllTrim(aCpoZG1Grd[i]),;   // [03]  C   Id do Field
                 TamSX3(SX3->X3_CAMPO)[3],; // [04]  C   Tipo do campo
                 TamSX3(SX3->X3_CAMPO)[1],; // [05]  N   Tamanho do campo
                 TamSX3(SX3->X3_CAMPO)[2],; // [06]  N   Decimal do campo
                 nil,;                      // [07]  B   Code-block de validação do campo
                 nil,;                      // [08]  B   Code-block de validação When do campo
                 nil,;                      // [09]  A   Lista de valores permitido do campo
                 .f.,;                      // [10]  L   Indica se o campo tem preenchimento obrigatório
                 Iif(!Empty(X3CBox()),StrToKArr(X3CBox(), ";"),nil),; // [11]  B   Code-block de inicializacao do campo
                 .f.,;                      // [12]  L   Indica se trata-se de um campo chave
                 .f.,;                      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                 .f.)                       // [14]  L   Indica se o campo é virtual
        else
            SX3->(DbSeek(Padr(aCpoZG1Grd[i], Len(SX3->X3_CAMPO)))) 
            aCBox := Iif(!Empty(X3CBox()),StrToKArr(X3CBox(), ";"),{})
            oStruct:AddField(;
                 X3Titulo(),;               // [01]  C   Titulo do campo
                 X3Descric(),;              // [02]  C   ToolTip do campo
                 AllTrim(aCpoZG1Grd[i]),;   // [03]  C   Id do Field
                 TamSX3(SX3->X3_CAMPO)[3],; // [04]  C   Tipo do campo
                 Iif(aCpoZG1Grd[i]$"B1_DESC",40,TamSX3(SX3->X3_CAMPO)[1]),; // [05]  N   Tamanho do campo
                 TamSX3(SX3->X3_CAMPO)[2],; // [06]  N   Decimal do campo
                 nil,;                      // [07]  B   Code-block de validação do campo
                 nil,;                      // [08]  B   Code-block de validação When do campo
                 aCbox,;                    // [09]  A   Lista de valores permitido do campo
                 .f.,;                      // [10]  L   Indica se o campo tem preenchimento obrigatório
                 nil,;                      // [11]  B   Code-block de inicializacao do campo
                 .f.,;                      // [12]  L   Indica se trata-se de um campo chave
                 .f.,;                      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                 .f.)                       // [14]  L   Indica se o campo é virtual
        endif
    next

if !Empty(aArea)
    RestArea(aArea)
endif
return oStruct

static function ZG1FldMStr()
local aArea := GetArea()
local oStruct := FWFormModelStruct():New()
local i, nLen

    // aCpoZG1Fld := { "ZG1_COD", "B1_DESC", "B1_QB", "QTDREF" }
    nLen := Len(aCpoZG1Fld)
    for i := 1 to nLen
        SX3->(DbSetOrder(2))
        if aCpoZG1Fld[i]$"QTDREF"
            oStruct:AddField(;
                 "Qt Referenci",;              // [01]  C   Titulo do campo
                 "Quantidade de referência ",; // [02]  C   ToolTip do campo
                 AllTrim(aCpoZG1Fld[i]),;      // [03]  C   Id do Field
                 TamSX3(SX3->X3_CAMPO)[3],;    // [04]  C   Tipo do campo
                 TamSX3(SX3->X3_CAMPO)[1],;    // [05]  N   Tamanho do campo
                 TamSX3(SX3->X3_CAMPO)[2],;    // [06]  N   Decimal do campo
                 nil,;                         // [07]  B   Code-block de validação do campo
                 nil,;                         // [08]  B   Code-block de validação When do campo
                 nil,;                         // [09]  A   Lista de valores permitido do campo
                 .f.,;                         // [10]  L   Indica se o campo tem preenchimento obrigatório
                 nil,;                         // [11]  B   Code-block de inicializacao do campo
                 .f.,;                         // [12]  L   Indica se trata-se de um campo chave
                 .f.,;                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                 .f.)                          // [14]  L   Indica se o campo é virtual
        else
            SX3->(DbSeek(Padr(aCpoZG1Fld[i], Len(SX3->X3_CAMPO)))) 
            aCBox := Iif(!Empty(X3CBox()),StrToKArr(X3CBox(), ";"),{})
            oStruct:AddField(;
                 X3Titulo(),;               // [01]  C   Titulo do campo
                 X3Descric(),;              // [02]  C   ToolTip do campo
                 AllTrim(aCpoZG1Fld[i]),;   // [03]  C   Id do Field
                 TamSX3(SX3->X3_CAMPO)[3],; // [04]  C   Tipo do campo
                 TamSX3(SX3->X3_CAMPO)[1],; // [05]  N   Tamanho do campo
                 TamSX3(SX3->X3_CAMPO)[2],; // [06]  N   Decimal do campo
                 nil,;                      // [07]  B   Code-block de validação do campo
                 nil,;                      // [08]  B   Code-block de validação When do campo
                 aCbox,;                    // [09]  A   Lista de valores permitido do campo
                 .f.,;                      // [10]  L   Indica se o campo tem preenchimento obrigatório
                 nil,;                      // [11]  B   Code-block de inicializacao do campo
                 .f.,;                      // [12]  L   Indica se trata-se de um campo chave
                 .f.,;                      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                 .f.)                       // [14]  L   Indica se o campo é virtual
        endif
    next

if !Empty(aArea)
    RestArea(aArea)
endif
return oStruct

static function ViewDef()
local oModel := ModelDef() 
local oView := nil
local oStrZG1VFl := ZG1FldVStr()
local oStrZG1Grd := ZG1GrdVStr()

    oView := FwFormView():New()
    oView:SetModel(oModel)
    
    oView:AddField("VwFieldZG1", oStrZG1VFl, "MdFieldZG1")
    oView:AddGrid("VwGridZG1", oStrZG1Grd, "MdGridZG1")
    
    oView:CreateHorizontalBox("CABECALHO", 18)
    oView:CreateHorizontalBox("ITENS",     82)

    oView:SetOwnerView("VwFieldZG1", "CABECALHO")
    oView:SetOwnerView("VwGridZG1",  "ITENS")

    oView:SetCloseOnOk({||.T.})

    oView:EnableTitleView("VwFieldZG1", "Dieta")
    oView:EnableTitleView("VwGridZG1", "Estrutura")

return oView


static function ZG1GrdVStr()
local aArea := GetArea()
local oStruct := FWFormViewStruct():New()
local i, nLen

DbSelectArea("SX3")
DbSetOrder(2)  // X3_CAMPO

    // {"ZG1_COMP", "B1_DESC", "ZG1_QUANT", "Z0H_INDMS", "QTDMS", "QTDMN", "Z0H_DATA", "Z0H_HORA"}
    nLen := Len(aCpoZG1Grd)
    for i := 1 to nLen
        SX3->(DbSetOrder(2))
        
        if aCpoZG1Grd[i]$"QTDMN|QTDMS"
            SX3->(DbSeek("ZG1_QUANT "))
            oStruct:AddField(;
                AllTrim(aCpoZG1Grd[i]),;        // [01]  C   Nome do Campo
                StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                Iif(aCpoZG1Grd[i]$"QTDMN", "Qtd Mat Natu", "Qtd Mat Seca"),; // [03]  C   Titulo do campo
                Iif(aCpoZG1Grd[i]$"QTDMN", "Quant de Materia Natural ", "Quant de Materia seca    "),; // [04]  C   Descricao do campo
                nil,;                           // [05]  A   Array com Help
                TamSX3(SX3->X3_CAMPO)[3],;      // [06]  C   Tipo do campo
                Iif(!Empty(SX3->X3_CAMPO), AllTrim(X3Picture(SX3->X3_CAMPO)), nil),;      // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                nil,;                           // [09]  C   Consulta F3
                .f.,;                           // [10]  L   Indica se o campo é alteravel
                nil,;                           // [11]  C   Pasta do campo
                nil,;                           // [12]  C   Agrupamento do campo
                nil,;                           // [13]  A   Lista de valores permitido do campo (Combo)
                nil,;                           // [14]  N   Tamanho maximo da maior opção do combo
                nil,;                           // [15]  C   Inicializador de Browse
                nil,;                           // [16]  L   Indica se o campo é virtual
                nil,;                           // [17]  C   Picture Variavel
                nil;                            // [18]  L   Indica pulo de linha após o campo
            )
        else
            SX3->(DbSeek(Padr(aCpoZG1Grd[i], Len(SX3->X3_CAMPO))))
            oStruct:AddField(;
                AllTrim(aCpoZG1Grd[i]),;        // [01]  C   Nome do Campo
                StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                AllTrim(X3Titulo()),;           // [03]  C   Titulo do campo
                X3Descric(),;                   // [04]  C   Descricao do campo
                nil,;                           // [05]  A   Array com Help
                TamSX3(SX3->X3_CAMPO)[3],;      // [06]  C   Tipo do campo
                Iif(!Empty(SX3->X3_CAMPO), AllTrim(X3Picture(SX3->X3_CAMPO)), nil),;      // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                nil,;                           // [09]  C   Consulta F3
                .f.,;                           // [10]  L   Indica se o campo é alteravel
                nil,;                           // [11]  C   Pasta do campo
                nil,;                           // [12]  C   Agrupamento do campo
                nil,;                           // [13]  A   Lista de valores permitido do campo (Combo)
                nil,;                           // [14]  N   Tamanho maximo da maior opção do combo
                nil,;                           // [15]  C   Inicializador de Browse
                nil,;                           // [16]  L   Indica se o campo é virtual
                nil,;                           // [17]  C   Picture Variavel
                nil;                            // [18]  L   Indica pulo de linha após o campo
            )
        endif
    next

    oStruct:SetProperty("ZG1_COMP", MVC_VIEW_WIDTH, 100)
    oStruct:SetProperty("B1_DESC", MVC_VIEW_WIDTH, 200)

if !Empty(aArea)
    RestArea(aArea)
endif
return oStruct

static function ZG1FldVStr()
local aArea := GetArea()
local oStruct := FWFormViewStruct():New()
local i, nLen

DbSelectArea("SX3")
DbSetOrder(2)  // X3_CAMPO

    // aCpoZG1Fld := { "ZG1_COD", "B1_DESC", "QTDREF" }
    nLen := Len(aCpoZG1Fld)
    for i := 1 to nLen
        SX3->(DbSetOrder(2))
        
        if aCpoZG1Fld[i]$"QTDREF"
            SX3->(DbSeek("ZG1_QUANT "))
            oStruct:AddField(;
                AllTrim(aCpoZG1Fld[i]),;        // [01]  C   Nome do Campo
                StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                "Qt Referenci",;                // [03]  C   Titulo do campo
                "Quantidade de referencia ",;   // [04]  C   Descricao do campo
                nil,;                           // [05]  A   Array com Help
                TamSX3(SX3->X3_CAMPO)[3],;      // [06]  C   Tipo do campo
                Iif(!Empty(SX3->X3_CAMPO), AllTrim(X3Picture(SX3->X3_CAMPO)), nil),;      // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                nil,;                           // [09]  C   Consulta F3
                .f.,;                           // [10]  L   Indica se o campo é alteravel
                nil,;                           // [11]  C   Pasta do campo
                nil,;                           // [12]  C   Agrupamento do campo
                nil,;                           // [13]  A   Lista de valores permitido do campo (Combo)
                nil,;                           // [14]  N   Tamanho maximo da maior opção do combo
                nil,;                           // [15]  C   Inicializador de Browse
                nil,;                           // [16]  L   Indica se o campo é virtual
                nil,;                           // [17]  C   Picture Variavel
                nil;                            // [18]  L   Indica pulo de linha após o campo
            )
        else
            SX3->(DbSeek(Padr(aCpoZG1Fld[i], Len(SX3->X3_CAMPO))))
            oStruct:AddField(;
                AllTrim(aCpoZG1Fld[i]),;        // [01]  C   Nome do Campo
                StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                AllTrim(X3Titulo()),;           // [03]  C   Titulo do campo
                X3Descric(),;                   // [04]  C   Descricao do campo
                nil,;                           // [05]  A   Array com Help
                TamSX3(SX3->X3_CAMPO)[3],;      // [06]  C   Tipo do campo
                Iif(!Empty(SX3->X3_CAMPO), AllTrim(X3Picture(SX3->X3_CAMPO)), nil),;      // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                nil,;                           // [09]  C   Consulta F3
                .f.,;                           // [10]  L   Indica se o campo é alteravel
                nil,;                           // [11]  C   Pasta do campo
                nil,;                           // [12]  C   Agrupamento do campo
                nil,;                           // [13]  A   Lista de valores permitido do campo (Combo)
                nil,;                           // [14]  N   Tamanho maximo da maior opção do combo
                nil,;                           // [15]  C   Inicializador de Browse
                nil,;                           // [16]  L   Indica se o campo é virtual
                nil,;                           // [17]  C   Picture Variavel
                nil;                            // [18]  L   Indica pulo de linha após o campo
            )
        endif
    next

if !Empty(aArea)
    RestArea(aArea)
endif
return oStruct

static function LoadZG1F(oModel, lCopia)
    // aCpoZG1Fld := { "ZG1_COD", "B1_DESC", "B1_QB", "ZG1_SEQ", "QTDREF" }
return {{mv_par03, Posicione("SB1", 1, FWxFilial("SB1")+mv_par03, "B1_DESC"), SB1->B1_QB, mv_par04, mv_par05}, 0}

static function LoadZG1G(oModel, lCopia)
local aArea := GetArea()
local aGrid := {}
local nTotMS := 0
local nTotMN := 0
local nTotEst := 0

    DbUseArea(.t., "TOPCONN", TCGenQry(,,;
             " select ZG1.ZG1_TRT" +;
                   ", ZG1.ZG1_COMP" +;
                   ", substring(SB1.B1_DESC, 1, 40) B1_DESC" +;
                   ", ZG1.ZG1_QUANT" +;
                   ", Z0H.Z0H_INDMS" +;
                   ", Z0H.Z0H_DATA" +;
                   ", Z0H.Z0H_HORA" +; 
               " from " + RetSqlName("ZG1") + " ZG1" +;
               " join " + RetSqlName("SB1") + " SB1" +;
                 " on SB1.B1_FILIAL  = '" + FWxFilial("SB1") + "'" +;
                " and SB1.B1_COD     = ZG1.ZG1_COMP" +;
                " and SB1.D_E_L_E_T_ = ' '" +;
               " join (" +;
                    " select Z0H_PRODUT, Z0H_INDMS, Z0H_DATA, Z0H_HORA" +;
                      " from " + RetSqlName("Z0H") + " Z0H" +;
                     " where Z0H_FILIAL+Z0H_PRODUT+Z0H_DATA+Z0H_HORA in (" +;
                                " select Z0H_FILIAL+Z0H_PRODUT+max(Z0H_DATA+Z0H_HORA)" +;
                                  " from Z0H010 Z0H" +;
                                 " where Z0H.Z0H_FILIAL = '" + FWxFilial("Z0H") + "'" +;
                                   " and Z0H.Z0H_DATA   <= '" + DToS(mv_par01) + SubStr(mv_par02, 1, TamSX3("Z0H_HORA")[1]) + "'" +;
                                   " and Z0H.D_E_L_E_T_ = ' '" +;
                              " group by Z0H_FILIAL, Z0H_PRODUT" +;
                           " )" +;
                       " and Z0H.D_E_L_E_T_ = ' '" +;
                    " ) Z0H" +;
                 " on Z0H.Z0H_PRODUT = ZG1.ZG1_COMP" +;
              " where ZG1.ZG1_FILIAL = '" + FWxFilial("ZG1") + "'" +;
                " and ZG1.ZG1_COD    = '" + mv_par03 + "'" +;
                " and ZG1.ZG1_SEQ    = '" + mv_par04 + "'" +;
                " and ZG1.D_E_L_E_T_ = ' '" +;
           " order by ZG1.ZG1_TRT, ZG1_COD";
                                         ), "TMPZG1", .f., .f.)
        while !TMPZG1->(Eof())
           // { "ZG1_TRT", "ZG1_COMP", "B1_DESC", "ZG1_QUANT", "Z0H_INDMS", "QTDMS", "QTDMN", "Z0H_DATA", "Z0H_HORA" }

            AAdd(aGrid, {0, { TMPZG1->ZG1_TRT; 
                            , TMPZG1->ZG1_COMP;
                            , TMPZG1->B1_DESC;
                            , TMPZG1->ZG1_QUANT;
                            , TMPZG1->Z0H_INDMS;
                            , Round(TMPZG1->ZG1_QUANT * (mv_par05/SB1->B1_QB), TamSX3("ZG1_QUANT")[2]); // QTDMS
                            , Round((TMPZG1->ZG1_QUANT * (mv_par05/SB1->B1_QB))/(TMPZG1->Z0H_INDMS/100), TamSX3("ZG1_QUANT")[2]); //QTDMN
                            , SToD(TMPZG1->Z0H_DATA);
                            , TMPZG1->Z0H_HORA } } )

            nTotEst += Round(TMPZG1->ZG1_QUANT, 2)
            nTotMS += Round(TMPZG1->ZG1_QUANT * (mv_par05/SB1->B1_QB), TamSX3("ZG1_QUANT")[2])
            nTotMN += Round((TMPZG1->ZG1_QUANT * (mv_par05/SB1->B1_QB))/(TMPZG1->Z0H_INDMS/100), TamSX3("ZG1_QUANT")[2])

            TMPZG1->(DbSkip())
        end

        AAdd(aGrid, {0, { CriaVar("ZG1_TRT", .f.);
                        , CriaVar("ZG1_COMP", .f.);
                        , "TOTAL";
                        , nTotEst;
                        , nTotMS/nTotMN * 100;
                        , nTotMS; // QTDMS
                        , nTotMN; //QTDMN
                        , CriaVar("Z0H_DATA", .f.);
                        , Criavar("Z0H_HORA", .f.) } } )
    TMPZG1->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif
return aGrid


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
AAdd( aDados, {cPerg, '01', 'Data de referencia?           ', 'Data de referencia?           ', 'Data de referencia?           ', 'mv_ch1', 'D', 8, 0, 0, 'G','','mv_par01','',   '',   '',   '','','',   '',   '',   '','','','','','','','','','','','','','','','','      ','S','   ','','','', {"Informe a data de referencia para a dieta.", "Informe a data de referencia para a dieta.", "Informe a data de referencia para a dieta."}} )
AAdd( aDados, {cPerg, '02', 'Hora de referencia?           ', 'Hora de referencia?           ', 'Hora de referencia?           ', 'mv_ch2', 'C', 5, 0, 0, 'G','','mv_par02','',   '',   '',   '','','',   '',   '',   '','','','','','','','','','','','','','','','','      ','S','   ','','','', {"Informe a hora de referencia para a dieta.", "Informe a data de referencia para a dieta.", "Informe a data de referencia para a dieta."}} )
AAdd( aDados, {cPerg, '03', 'Dieta?                        ', 'Dieta?                        ', 'Dieta?                        ', 'mv_ch3', 'C',30, 0, 0, 'G','','mv_par03','',   '',   '',   '','','',   '',   '',   '','','','','','','','','','','','','','','','','DIETA ','S','   ','','','', {"Informe a dieta ou selecione." + CRLF + "<F3 Disponível>.", "Informe a dieta ou selecione." + CRLF + "<F3 Disponível>.", "Informe a dieta ou selecione." + CRLF + "<F3 Disponível>."}} )
AAdd( aDados, {cPerg, '04', 'Versão?                       ', 'Versão?                       ', 'Versão?                       ', 'mv_ch4', 'C', 4, 0, 0, 'G','','mv_par04','',   '',   '',   '','','',   '',   '',   '','','','','','','','','','','','','','','','','VERSAO','S','   ','','','', {"Informe a versão para a dieta ou selecione." + CRLF + "<F3 Disponível>.", "Informe a versão para a dieta ou selecione." + CRLF + "<F3 Disponível>.", "Informe a versão para a dieta ou selecione." + CRLF + "<F3 Disponível>."}} )
AAdd( aDados, {cPerg, '05', 'Quantidade?                   ', 'Quantidade?                   ', 'Quantidade?                   ', 'mv_ch5', 'N', 4, 0, 0, 'G','','mv_par05','',   '',   '',   '','','',   '',   '',   '','','','','','','','','','','','','','','','','      ','S','   ','','','', {"Informe a quandidade de matéria usada como referência. Se não for preenchido será definido como 1.", "Informe a quandidade de matéria usada como referência. Se não for preenchido será definido como 1.", "Informe a quandidade de matéria usada como referência. Se não for preenchido será definido como 1."}} )

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

user function vpcp11f3()
local lRet := .f.
local aArea := GetArea()
local cQuery := ""

if Type("uRetorno") == 'U' 
    public uRetorno
endif
uRetorno := ''

    cQuery := " select SEQ.ZG1_COD, SB1.B1_DESC, SEQ.ZG1_DTALT, SEQ.ZG1_SEQ, Min(SEQ.R_E_C_N_O_) ZG1RECNO" +;
                " from " + RetSqlName("ZG1") + " SEQ" +;
                " join " + RetSqlName("SB1") + " SB1" +;
                  " on SB1.B1_FILIAL  = '" + FWxFilial("SB1") + "'" +;
                 " and SB1.B1_COD     = SEQ.ZG1_COD" +;
                 " and SB1.D_E_L_E_T_ = ' '" +;
               " where SEQ.ZG1_FILIAL = '" + FWxFilial("ZG1") + "'" +;
                 " and SEQ.ZG1_COD    = '" + mv_par03 + "'" +;
                 " and SEQ.D_E_L_E_T_ = ' '" +;
            " group by SEQ.ZG1_COD, SB1.B1_DESC, SEQ.ZG1_DTALT, SEQ.ZG1_SEQ" +;
            " order by SEQ.ZG1_COD, SEQ.ZG1_SEQ"

    
    if u_F3Qry( cQuery, 'PLANUT', 'ZG1RECNO', @uRetorno,, { "ZG1_COD", "B1_DESC", "ZG1_SEQ", "ZG1_DTALT" } )
        ZG1->(DbGoto( uRetorno ))
        lRet := .t.
    endif

if aArea[1] <> "ZG1"
    RestArea( aArea )
endif
return lRet
