// #########################################################################################
// Projeto: Trato
// Fonte  : vapcpa05
// ---------+------------------------------+------------------------------------------------
// Data     | Autor                        | Descrição
// ---------+------------------------------+------------------------------------------------
// 20190227 | jrscatolon@jrscatolon.com.br | Planejamento de trato    
//          |                              |  
//          |                              |  
// ---------+------------------------------+------------------------------------------------

 /*
 Parâmetro
 VA_REGHIST
 N
 Parâmetro Customizado. Usado pela função vapcpa05. Identifica a quantidade de registros históricos que deve ser mostradas na rotina VAPCPA05
 Padrão 5

 VA_MXVALTR
 N
 Parâmetro Customizado. Usado pela função vapcpa05. Valor máximo possível para o trato por animal.
 Padrão 15

 VA_GRTRATO
 C
 Parâmetro Customizado. Usado pela função vapcpa05. Idenfica os grupos de produtos produzidos para atender o trato. (formato do cmd in do SQL)

 VA_CRTRDAN 
 L
 Parâmetro Customizado. Usado pela função vapcpa05. Cria trato baseado na quantidade de trato do dia anterior, mesmo para os dias do plano nutricional.
 Padrão .F.
 
 VA_AJUDAN
 N
 Parametro Customizado. Usado pela função vapcpa05 para definir se realiza o ajuste do trato com base no KG absoluto ou no % definido no cadastro da nota de Cocho.

 VA_TRTCNHG
 N
 Parâmetro Customizado. Usado pela função vapcpa05. Numero de tratos a considerar para mostrar na legenda de dias sem modificação.
 padrão: 3
 */

#include "Protheus.ch"
#include "RWMake.ch"
#include "TopConn.ch"
#include "ParmType.ch"
#include "FWMVCDef.ch"
#include "FWEditPanel.ch"

#define MODEL_FIELD 1
#define MODEL_GRID 2

#IFNDEF _ENTER_
	#DEFINE _ENTER_ (Chr(13)+Chr(10))
	// Alert("miguel")
#ENDIF

static nNroTratos := 0
static aIMS := {}
static dDtIMS := SToD("")
static aFldBrw := {}
static cFldBrw := ""

static nQtdUltTrt := GetMV("VA_TRTCNHG",,3) 

static cPath      := "C:\totvs_relatorios\"
static lDebug     := ExistDir(cPath) .and. GetMV("VA_DBGTRTO",,.T.)

static aCpoMdZ05F := { "Z05_DATA",   "Z05_VERSAO", "Z05_CURRAL", "Z05_LOTE",   "Z05_CABECA", "Z05_ORIGEM";
                     , "Z05_DIAPRO", "Z05_DIASDI", "Z05_MANUAL", "Z05_TOTMSC", "Z05_TOTMNC", "Z05_TOTMSI";
                     , "Z05_TOTMNI", "Z05_PESMAT", "Z05_CMSPN",  "Z05_PESOCO";
                     , "Z05_MEGCAL", "Z05_MCALPR" }
static aCpoMdZ0IG := { "Z0I_DATA",   "Z0I_NOTMAN", "Z0I_NOTTAR", "Z0I_NOTNOI" }
static aCpoMdZ05G := { "Z05_DATA",   "Z05_DIETA",  "Z05_CABECA", "Z05_KGMSDI", "Z05_KGMNDI", "Z04_KGMSRE" ;
                     , "Z04_KGMNRE", "Z05_MEGCAL" }
static aCpoMdZ06G := { "Z06_TRATO",  "Z06_DIETA",  "Z06_KGMSTR", "Z06_KGMNTR", "Z06_MEGCAL","Z06_KGMNT", "Z06_RECNO" }

static nMaxDiasDi := (10^TamSX3("Z05_DIASDI")[1])-1

static aSeekFiltr := {}


/*/{Protheus.doc} VAPCPA05
Rotina de criação/manutenção de trato.
@author jr.andre
@since 08/04/2019
@version 1.0
@return nil

@type function
/*/
user function VAPCPA05()
local cPerg        := "VAPCPA05"
local i, nLen
local lRet         := .F.
local aFields      := {}
local aBrowse      := {}
local aIndex       := {}
//local aFieFilter := {}
local aSeek        := {}
local nTrato       := 0

private oTmpZ06    := nil
private cTrbBrowse := CriaTrab(,.F.)
private oBrowse    := nil

EnableKey(.T.)

nNroTratos := u_GetNroTrato()

AtuSX1(@cPerg)
U_PosSX1({{cPerg, "01", Date() }})

    DbSelectArea("SX3")
    DbSetOrder(2) // X3_CAMPO
    
    DbSelectArea("Z0H")
    DbSetOrder(1) //Z0H_FILIAL+Z0H_DATA+Z0H_HORA+Z0H_PRODUT
    
    DbSelectArea("SB1") // Produtos
    DbsetOrder(1) // B1_FILIAL+B1_COD
    
    DbSelectArea("Z0M") // Plano Nutricional             
    DbSetOrder(1) // Z0M_FILIAL+Z0M_CODIGO+Z0M_VERSAO+Z0M_DIA+Z0M_TRATO
    
    DbSelectArea("Z05") // Trato
    DbSetOrder(1) // Z05_FILIAL+Z05_DATA+Z05_VERSAO+Z05_CURRAL+Z05_LOTE

    DbSelectArea("Z0O") // Lote x Plano Nutricional      
    DbSetOrder(1) // Z0O_FILIAL+Z0O_LOTE+Z0O_CODPLA+DToS(Z0O_DATAIN)
    
    DbSelectArea("Z08") // Cadastro de Currais
    DbSetOrder(1) // Z08_FILIAL+Z08_CODIGO

    DbSelectArea("Z0R") // Cabeçalho do trato
    DbSetOrder(1) // Z0R_FILIAL+Z0R_DATA+Z0R_VERSAO

    DbSelectArea("Z0T") // Cabeçalho do trato
    DbSetOrder(1) // Z0R_FILIAL+Z0R_DATA+Z0R_VERSAO

    DbSelectArea("Z06") // Programação                   
    DbSetOrder(1) // Z06_FILIAL+DToS(Z06_DATA)+Z06_VERSAO+Z06_CURRAL+Z06_LOTE+Z06_TRATO

    if Pergunte(cPerg, .T.)

        //----------------------------
        //Cria o trato caso necessário
        //----------------------------
        if !Z0R->(DbSeek(FWxFilial("Z0R")+DToS(mv_par01)))
            if MsgYesNo("Não foi identificado nenhum trato para a data " + DToC(mv_par01) + ". Deseja criar?", "Trato não encontrado.")
                FWMsgRun(, { || u_CriaTrat(mv_par01)}, "Geração de trato", "Gerando trato para o dia " + DToC(mv_par01) + "...")
            else
                Help(/*Descontinuado*/,/*Descontinuado*/,"SELEÇÃO DE TRATO",/**/,"Não existe trato para o dia " + DToC(mv_par01) + ". ", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, crie o trato para prosseguir." })
            endif
        else
        
            //----------------------------------
            //Carrega os íncidices de massa seca
            //----------------------------------
            if Empty(aIMS) .or. dDtIMS <> mv_par01
                CarregaIMS()
            endif
        endif

        if !Z0R->(Eof())
            
            //--------------------------
            //Define os campos da browse
            //--------------------------
            CriaCpsBrw()

            if !Empty(aIMS)
                //-----------------------------------------------
                //Monta os campos da tabela temporária e o browse
                //-----------------------------------------------
                nLen := Len(aFldBrw)
                for i := 1 to nLen
                    if "LEGEND" $ aFldBrw[i]
                        AAdd(aFields, {aFldBrw[i], "C", 10, 0})
                        AAdd(aBrowse, {"CMS/PV", aFldBrw[i], "C", 10, 0, ""})
                        // AAdd(aFieFilter, {aFldBrw[i], "CMS/PV", "C", 10, 0, ""})
                    elseif "PROGANTMS" $ aFldBrw[i]
                        SX3->(DbSeek("Z06_KGMSTR"))
                        AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
                        AAdd(aBrowse, {"Progr MS Ant", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
                        // AAdd(aFieFilter, {aFldBrw[i], "Progr MS Ant   ", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
                    elseif "PROGANTMN" $ aFldBrw[i]
                        SX3->(DbSeek("Z06_KGMSTR"))
                        AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
                        AAdd(aBrowse, {"Progr MN Ant", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
                        // AAdd(aFieFilter, {aFldBrw[i], "Progr MN Ant", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
                    elseif "PROG_MS" $ aFldBrw[i]
                        SX3->(DbSeek("Z06_KGMSTR"))
                        AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
                        AAdd(aBrowse, {"Progr MS Dia", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
                        // AAdd(aFieFilter, {aFldBrw[i], "Progr MS Dia", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
                    elseif "PROG_MN" $ aFldBrw[i]
                        SX3->(DbSeek("Z06_KGMSTR"))
                        AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
                        AAdd(aBrowse, {"Progr MN Dia", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
                        // AAdd(aFieFilter, {aFldBrw[i], "Progr MN Dia", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
                    elseif "NR_TRATOS" $ aFldBrw[i]
                        SX3->(DbSeek("Z06_TRATO"))
                        AAdd(aFields, {aFldBrw[i], "N", 1, 0})
                        AAdd(aBrowse, {"Nro Tratos", aFldBrw[i], "N", 1, 0, "@E 9"})
                        // AAdd(aFieFilter, {aFldBrw[i], "Nro Tratos", "N", 1, 0, "@E 9"})
                    elseif "CMS_PV" $ aFldBrw[i]
                        AAdd(aFields, {aFldBrw[i], "N", 9, 3})
                        AAdd(aBrowse, {"CMS/PV", aFldBrw[i], "N", 9, 3, "@E 99,999.999"})
                        // AAdd(aFieFilter, {aFldBrw[i], "CMS/PV", "N", 9, 3, "@E 99,999.999"})
                    elseif "Z05_MEGCAL" $ aFldBrw[i]
                        AAdd(aFields, {aFldBrw[i], "N", 6, 2})
                        AAdd(aBrowse, {"Mega Caloria", aFldBrw[i], "N", 6, 2, "@E 999.99"})
                        // AAdd(aFieFilter, {aFldBrw[i], "CMS/PV", "N", 9, 3, "@E 99,999.999"})
                    elseif "Z06_DIETA" $ aFldBrw[i] 
                        SX3->(DbSeek("Z06_DIETA"))
                        AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
                        AAdd(aBrowse, {AllTrim(X3Titulo()) + " " + AllTrim(Str(++nTrato)), aFldBrw[i], SX3->X3_TIPO, 10, 0, SX3->X3_PICTURE})
                        // AAdd(aFieFilter, {aFldBrw[i], AllTrim(X3Titulo()) + " " + AllTrim(Str(nTrato)) , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
                    elseif "Z06_KGMS" $ aFldBrw[i]
                        SX3->(DbSeek("Z06_KGMSTR"))
                        AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
                        AAdd(aBrowse, {AllTrim(X3Titulo())  + " " + AllTrim(Str(nTrato)), aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
                        // AAdd(aFieFilter, {aFldBrw[i], AllTrim(X3Titulo()) + " " + AllTrim(Str(nTrato)), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
                    elseif "Z06_KGMN" $ aFldBrw[i]
                        SX3->(DbSeek("Z06_KGMNTR"))
                        AAdd(aFields,{aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
                        AAdd(aBrowse, {AllTrim(X3Titulo()) + " " + AllTrim(Str(nTrato)), aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
                        // AAdd(aFieFilter, {aFldBrw[i], AllTrim(X3Titulo()) + " " + AllTrim(Str(nTrato)), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
                    elseif "Z05_MNTOT" $ aFldBrw[i]
                        // AAdd(aFields, {aFldBrw[i], "N", 7, 1})
                        AAdd(aFields, {aFldBrw[i], "N", TamSX3('Z05_TOTMNI')[1], TamSX3('Z05_TOTMNI')[2] })
                        AAdd(aBrowse, {"MN Total", aFldBrw[i], "N", 6, 2, "@E 99999.9"})
                        // AAdd(aBrowse, {"MN Total", aFldBrw[i], "N", TamSX3('Z05_TOTMNI')[1], TamSX3('Z05_TOTMNI')[2], AllTrim(X3Picture("Z05_TOTMNI")) })
                        // AAdd(aFieFilter, {aFldBrw[i], "CMS/PV", "N", 9, 3, "@E 99,999.999"})
                    elseif "NOTA_MANHA" $ aFldBrw[i]
                        SX3->(DbSeek("Z0I_NOTMAN"))
                        AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
                        AAdd(aBrowse, {"NtChMan", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
                        // AAdd(aFieFilter, {aFldBrw[i],"NtChMan", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
                    elseif "NOTA_MADRU" $ aFldBrw[i]
                        SX3->(DbSeek("Z0I_NOTNOI"))
                        AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
                        AAdd(aBrowse, {"NtChMad", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
                        // AAdd(aFieFilter, {aFldBrw[i],"NtChMad", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
                    elseif "NOTA_NOITE" $ aFldBrw[i]
                        SX3->(DbSeek("Z0I_NOTTAR"))
                        AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
                        AAdd(aBrowse, {"NtChNoi", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
                        // AAdd(aFieFilter, {aFldBrw[i],"NtChNoi", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
                    elseif "B8_SALDO" $ aFldBrw[i]
                        SX3->(DbSeek("B8_SALDO"))
                        AAdd(aFields, {"B8_SALDO", "N", 6, 0})
                        AAdd(aBrowse, {"Saldo Lote", "B8_SALDO", "N", 1, 0, "@E 999,999"})
                        // AAdd(aFieFilter, {"B8_SALDO", "Saldo Lote", "N", 6, 0, "@E 999,999"})
                    elseif "Z05_MANUAL" $ aFldBrw[i]
                        SX3->(DbSeek("Z05_MANUAL"))
                        AAdd(aFields, {SX3->X3_CAMPO, SX3->X3_TIPO, 3, SX3->X3_DECIMAL})
                        AAdd(aBrowse, {AllTrim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
                        // AAdd(aFieFilter, {SX3->X3_CAMPO, AllTrim(X3Titulo()), SX3->X3_TIPO, 3, SX3->X3_DECIMAL, SX3->X3_PICTURE})
                    elseif "QTDTRATO" $ aFldBrw[i]
                        AAdd(aFields, {"QTDTRATO", "N", 4, 0})
                        // AAdd(aFieFilter, {"QTDTRATO", "Qtd Trat Repet ", "N", 4, 0, "@E 9,999"})
                    else
                        SX3->(DbSeek(aFldBrw[i]))
                        AAdd(aFields, {SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
                        AAdd(aBrowse, {AllTrim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
                        // AAdd(aFieFilter, {SX3->X3_CAMPO, AllTrim(X3Titulo()), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
                    endif
                next
                
                if lDebug .and. lower(cUserName) $ 'mbernardo,atoshio,admin,administrador,rsantana'
                    MemoWrite(cPath + "Struct" + DtoS(dDataBase) + "_" + StrTran(SubS(Time(),1,5),":","") + ".txt", U_ATOS(aFields) + CRLF + U_ATOS(aBrowse) /*+ CRLF + U_ATOS(aFieFilter)*/)
                endif

                //-------------------
                //Criação do objeto
                //-------------------
                oTmpZ06 := FWTemporaryTable():New(cTrbBrowse)
                oTmpZ06:SetFields(aFields)
                
                //-------------------
                //Ajuste dos índices
                //-------------------
                oTmpZ06:AddIndex(cTrbBrowse + "1", {"Z08_CODIGO"})
                oTmpZ06:AddIndex(cTrbBrowse + "2", {"B8_LOTECTL"})
                oTmpZ06:AddIndex(cTrbBrowse + "3", {"Z0T_ROTA"})
                oTmpZ06:AddIndex(cTrbBrowse + "4", {"ZV0_DESC"})

                AAdd(aIndex, "Z08_CODIGO")
                AAdd(aIndex, "B8_LOTECTL")
                AAdd(aIndex, "Z0T_ROTA")
                AAdd(aIndex, "ZV0_DESC")
                
                //----------------------------
                //Criação da tabela Temporária
                //----------------------------
                oTmpZ06:Create()
    
                //----------------------------
                //Campos que irão compor o combo de pesquisa na tela principal
                //----------------------------
                AAdd(aSeek,{"Curral",      {{"", TamSX3("Z08_CODIGO")[3], TamSX3("Z08_CODIGO")[1], TamSX3("Z08_CODIGO")[2], "Z08_CODIGO", "@!"}}, 1, .T. })
                AAdd(aSeek,{"Lote",        {{"", TamSX3("B8_LOTECTL")[3], TamSX3("B8_LOTECTL")[1], TamSX3("B8_LOTECTL")[2], "B8_LOTECTL", "@!"}}, 2, .T. })
                AAdd(aSeek,{"Rota",        {{"", TamSX3("Z0T_ROTA")[3],   TamSX3("Z0T_ROTA")[1],   TamSX3("Z0T_ROTA")[2],   "Z0T_ROTA",   "@!"}}, 3, .T. })
                AAdd(aSeek,{"Equipamento", {{"", TamSX3("ZV0_DESC")[3],   TamSX3("ZV0_DESC")[1],   TamSX3("ZV0_DESC")[2],   "ZV0_DESC",   "@!"}}, 4, .T. })
                
                //------------------------------------------------
                //Povoa a tabela temporária com os dados do filtro
                //------------------------------------------------
                FWMsgRun(, { || LoadTrat(mv_par01) }, "Carregamento do trato", "Carregando trato")
        
                //------------------------------------------------
                //Cria o browse
                //------------------------------------------------
                oBrowse := FWMBrowse():New()
                oBrowse:SetAlias(cTrbBrowse)
                oBrowse:SetQueryIndex(aIndex)
                oBrowse:SetTemporary(.T.)
                oBrowse:SetFields(aBrowse)
                oBrowse:AddStatusColumns( { || BrwStatus() }, { || BrwLegend() } )

                oBrowse:SetUseFilter(.F.)
                oBrowse:SetUseCaseFilter(.F.)
 
                // oBrowse:SetFilterDefault("Z0T_ROTA='ROTA05'") //Exemplo de como inserir um filtro padrão >>> "TR_ST == 'A'"
                // oBrowse:SetFieldFilter(aFieFilter)
                oBrowse:DisableDetails()
                oBrowse:SetDescription("Programação do Trato - " + DToC(mv_par01))
                oBrowse:SetSeek(.T.,aSeek)

                oBrowse:AddLegend(cTrbBrowse+"->PROG_MS < " + cTrbBrowse + "->PROGANTMS", "RED",      "Diminuiu consumo")
                oBrowse:AddLegend(cTrbBrowse+"->PROG_MS = " + cTrbBrowse + "->PROGANTMS", "YELLOW",   "Mateve consumo")
                oBrowse:AddLegend(cTrbBrowse+"->PROG_MS > " + cTrbBrowse + "->PROGANTMS", "GREEN",    "Aumentou consumo")

                oBrowse:SetTimer( {|| UpdStatus() }, 1000)

                oBrowse:Activate()
                
                (cTrbBrowse)->(DbCloseArea())
                
                if oTmpZ06 <> nil
                    oTmpZ06:Delete()
                    oTmpZ06 := nil
                endif
    
            endif

        endif
    endif

    EnableKey(.F.)

return nil


/*/{Protheus.doc} UpdStatus
Chamado pelo timer para ser executado apenas na primeira chamada. Usado para alterar o bloco de código oBrowse:oBrowseUI:oFWSeek:bAction
@author jr.andre
@since 21/08/2019
@version 1.0
@return nil

@type function
/*/
static function UpdStatus()

    oBrowse:oBrowseUI:oFWSeek:bAction := &("{||oBrowse:SeekAction(),oBrowse:SetFocus(),u_SeekDeta()}")
    oBrowse:SetTimer({|| .T.}, 0)

return nil


/*/{Protheus.doc} SeekDeta
Grava na variável estatica o conteudo do fwseek quando usado como filtro. Usado na rotina vap05arq como parametro de filtragem
@author jr.andre
@since 21/08/2019
@version 1.0
@return nil

@type function
/*/
user function SeekDeta()
    if oBrowse:oBrowseUI:oFWSeek:oTFolder:nOption == 2
        aSeekFiltr := { oBrowse:oBrowseUI:oFWSeek:cSeek,;
                        oBrowse:oBrowseUI:oFWSeek:lSeekAllFields,;
                        aClone(oBrowse:oBrowseUI:oFWSeek:aFldChecks),;
                        aClone(oBrowse:oBrowseUI:oFWSeek:aDetails) }
    endif
return nil


/*/{Protheus.doc} BrwStatus
Define a cor da coluna de status definida no browse
@author jr.andre
@since 16/08/2019
@version 1.0
@return Caracter, Código da cor

@type function
/*/
static function BrwStatus(); return Iif((cTrbBrowse)->QTDTRATO == nQtdUltTrt, "BR_CINZA", "BR_AZUL")


/*/{Protheus.doc} BrwLegend
Mostra a legenda para a coluna de status definida no browse
@author jr.andre
@since 16/08/2019
@version 1.0
@return nil

@type function
/*/
static function BrwLegend()
local oLegend := FWLegend():New()

    oLegend:Add("","BR_AZUL" , "Houve alteração de trato nos últimos 3 dias" ) 
    oLegend:Add("","BR_CINZA", "Este lote está a " + AllTrim(Str(nQtdUltTrt)) + " ou mais dias sem alteração." )
    oLegend:Activate()
    oLegend:View()
    oLegend:DeActivate()

return nil


/*/{Protheus.doc} CriaCpsBrw
Carrega no array aFldBrw os campos que serão apresentados no browse.
@author jr.andre
@since 08/04/2019
@version 1.0
@return nil

@type function
/*/
static function CriaCpsBrw()
local i, nLen

    //-----------------------------------------------------------------------------
    // PROGRAMAÇÃO DE TRATO 
    //-----------------------------------------------------------------------------
    aFldBrw := { ;// "Z08_LINHA",;     // LINHA
                 "Z08_CODIGO",;    // COCHO
                 "Z0T_ROTA",;      // ROTA   
                 "B8_LOTECTL",;    // LOTE
                 "Z05_PESMAT",;    // PESO MED AUAL
                 "CMS_PV",;        // Consumo de materia seca por peso
                 "Z05_MEGCAL",;    // Mega Caloria (Energia)
                 "B8_SALDO",;      // SALDO  
                 "Z05_DIASDI",;    // DIA DA DIETA
                 "NOTA_NOITE",;    // NOTAS DE COCHO
                 "NOTA_MADRU",;    // NOTAS DE COCHO
                 "NOTA_MANHA",;    // NOTAS DE COCHO 
                 "PROGANTMS",;     // PROGRAMAÇÃO ANTERIOR - KG de MS / Cabeça       
                 "PROG_MS",;       // PROGRAMAÇÃO DE TRATO - KG de MS / Cabeça
                 "NR_TRATOS",;     // Qtde Tratos
                 "PROGANTMN",;     // PROGRAMAÇÃO ANTERIOR - KG de MS / Cabeça       
                 "PROG_MN",;       // PROGRAMAÇÃO DE TRATO - KG de MN / Cabeça
                 "Z05_MNTOT",;     // QUANTIDADE TOTAL DE MN
                 "QTDTRATO" }      // QUANTIDADE DE TRATOS REPETIDOS NOS ULTIMOS N DIAS

    for i := 1 to nNroTratos
        AAdd(aFldBrw, "Z06_DIETA" + StrZero(i, 1)) 
        AAdd(aFldBrw, "Z06_KGMS" + StrZero(i, 1)) // Z06_KGMSTR
        AAdd(aFldBrw, "Z06_KGMN" + StrZero(i, 1)) // Z06_KGMNT
    next

    AAdd(aFldBrw, "Z0S_EQUIP") 
    AAdd(aFldBrw, "ZV0_DESC") // Z06_KGMSTR

    nLen := Len(aFldBrw)
    for i := 1 to nLen
        cFldBrw += Iif(Empty(cFldBrw), "", ", ") + aFldBrw[i]
    next

return nil 


/*/{Protheus.doc} CarregaIMS
Carrega o índice de matéria seca utilizado no trato e salva na tabela Z0V os índices usados.
@author jr.andre
@since 09/04/2019
@version 1.0
@return nil

@type function
/*/
static function CarregaIMS(lRecria, dDtTrato, cVersao)
local aArea      := GetArea()
local lRet       := .T.
local cIMSProb   := ""
local cAliasQry  := GetNextAlias()

default lRecria  := .F.
default dDtTrato := Z0R->Z0R_DATA
default cVersao  := Z0R->Z0R_VERSAO

    aIMS         := {}
    dDtIMS       := dDtTrato

    DbSelectArea("Z0V")
    DbSetOrder(1) // 

    if !lRecria .and. Z0V->(DbSeek(FWxFilial("Z0V") + DToS(dDtTrato) + cVersao))
        while !Z0V->(Eof()) .and. Z0V->Z0V_FILIAL = FWxFilial("Z0V") .and.;
                Z0V->Z0V_DATA == dDtTrato .and. Z0V->Z0V_VERSAO == cVersao
            AAdd(aIMS, { Z0V->Z0V_COMP,;
                         Z0V->Z0V_DTLEI,;
                         Z0V->Z0V_HORA,;
                         Z0V->Z0V_INDMS } )
            Z0V->(DbSkip())
        end
    else
        if lRecria
            //TCSqlExec() // TODO Update na Z0H para definir que o índice não foi utilizado..... 
            //            // Tomar cuidado para não voltar um indice que tenha sido usado em outro trato.....
            TCSqlExec("update " + RetSqlName("Z0V") + ; 
                        " set D_E_L_E_T_ = '*'" +;
                      " where Z0V_FILIAL = '" + FWxFilial("Z0V") + "'" +;
                        " and Z0V_DATA   = '" + DToS(dDtTrato) + "'" +;
                        " and Z0V_VERSAO = '" + cVersao + "'" +;
                        " and D_E_L_E_T_ = ' '")
        endif

        DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                               _cQry := " select COMPONENTES.G1_COMP" + _ENTER_ +;
                                        "               , case when INDICES.Z0H_DATA is null then 'N' else 'S' end DIGITADO" + _ENTER_ +;
                                        "               , INDICES.Z0H_DATA" + _ENTER_ +;
                                        "               , INDICES.Z0H_HORA" + _ENTER_ +;
                                        "               , INDICES.Z0H_INDMS" + _ENTER_ +;
                                        "               , INDICES.Z0H_RECNO" + _ENTER_ +;
                                        "               , G1_ORIGEM" + _ENTER_ +;
                                        " from (" + _ENTER_ +;
                                        "           select distinct G1_COMP, G1_ORIGEM" + _ENTER_ +;
                                        "           from " + RetSqlName("SG1") + " COMP" + _ENTER_ +;
                                        "           join " + RetSqlName("SB1") + " SB1 on SB1.B1_FILIAL = '" + FwxFilial("SB1") + "'" + _ENTER_ +;
                                        "                                               and SB1.B1_COD     = COMP.G1_COD " + _ENTER_ +;
                                        "												and SB1.B1_X_TRATO = '1'" + _ENTER_ +;
                                        "                                               and SB1.B1_GRUPO   in (" + GetMV("VA_GRTRATO") + ")" + _ENTER_ +;
                                        "                                               and SB1.D_E_L_E_T_ = ' '" + _ENTER_ +;
                                        "           where COMP.G1_FILIAL  = '" + FWxFilial("SG1") + "'" + _ENTER_ +;
                                        "             -- and COMP.G1_ORIGEM <> 'P'" + _ENTER_ +;
                                        "             and COMP.D_E_L_E_T_ = ' '" + _ENTER_ +;
                                        " ) COMPONENTES" + _ENTER_ +;
                                        " left join (" + _ENTER_ +;
                                        "           select Z0H.Z0H_PRODUT, Z0H.Z0H_DATA, Z0H.Z0H_HORA, Z0H_INDMS, R_E_C_N_O_ Z0H_RECNO" + _ENTER_ +;
                                        "           from " + RetSqlName("Z0H") + " Z0H" + _ENTER_ +;
                                        "           where Z0H.Z0H_FILIAL = '" + FWxFilial("Z0H") + "'" + _ENTER_ +;
                                        "             and Z0H.Z0H_VALEND = '1'" + _ENTER_ +;
                                        "             and Z0H.Z0H_PRODUT + Z0H.Z0H_DATA + Z0H.Z0H_HORA in (" + _ENTER_ +;
                                        "                                            select MAXZ0H.Z0H_PRODUT + max(MAXZ0H.Z0H_DATA+MAXZ0H.Z0H_HORA)" + _ENTER_ +;
                                        "                                            from " + RetSqlName("Z0H") + " MAXZ0H" + _ENTER_ +;
                                        "                                            where MAXZ0H.Z0H_FILIAL = '" + FWxFilial("Z0H") + "'" + _ENTER_ +;
                                        "                                              and MAXZ0H.Z0H_DATA  <= '" + DToS(dDtTrato) + "'" + _ENTER_ +;
                                        "                                              and MAXZ0H.Z0H_VALEND = '1'" + _ENTER_ +;
                                        "                                              and MAXZ0H.D_E_L_E_T_ = ' '" + _ENTER_ +;
                                        "                                            group by MAXZ0H.Z0H_PRODUT" + _ENTER_ +;
                                        "                   )" + _ENTER_ +;
                                        "              and Z0H.D_E_L_E_T_ = ' '" + _ENTER_ +;
                                        " ) INDICES" + _ENTER_ +;
                                        " on COMPONENTES.G1_COMP = INDICES.Z0H_PRODUT" ;
                                      ), cAliasQry, .F., .F.)

			MEMOWRITE("C:\TOTVS_RELATORIOS\CarregaIMS_" + DToS(dDtTrato) + ".sql", _cQry)

            while !(cAliasQry)->(Eof())
                if (cAliasQry)->DIGITADO == 'S'

                    Z0V->(DbSetOrder(1)) // Z0V_FILIAL+Z0V_DATA+Z0V_VERSAO+Z0V_COMP
                    If !Z0V->(DbSeek( FWxFilial("Z0V") + DToS(dDtTrato) + cVersao + (cAliasQry)->G1_COMP ))
                        If (cAliasQry)->G1_ORIGEM == "P"
                            GeraZ0VComp( (cAliasQry)->G1_COMP, dDtTrato, cVersao)
                        EndIf
                    
                        RecLock("Z0V", .T.)
                            Z0V->Z0V_FILIAL := FWxFilial("Z0V")
                            Z0V->Z0V_DATA   := dDtTrato
                            Z0V->Z0V_VERSAO := cVersao
                            Z0V->Z0V_COMP   := (cAliasQry)->G1_COMP
                            Z0V->Z0V_DTLEI  := SToD((cAliasQry)->Z0H_DATA)
                            Z0V->Z0V_HORA   := (cAliasQry)->Z0H_HORA
                            Z0V->Z0V_INDMS  := (cAliasQry)->Z0H_INDMS
                        MsUnlock()
                    EndIf

                    Z0H->(DbGoTo((cAliasQry)->Z0H_RECNO))
                    RecLock("Z0H", .F.)
                        Z0H->Z0H_STATUS := '1'
                    MsUnlock()

                    AAdd(aIMS, { (cAliasQry)->G1_COMP,;
                                 (cAliasQry)->Z0H_DATA,;
                                 (cAliasQry)->Z0H_HORA,;
                                 (cAliasQry)->Z0H_INDMS } )
                else
                    cIMSProb += Iif(Empty(cIMSProb), "", ", ") + AllTrim((cAliasQry)->G1_COMP) 
                endif
                (cAliasQry)->(DbSkip())
            end

            if !Empty(cIMSProb)
                LogTrato("Ocorreu um erro ao carregar o índice de matéria seca.", "IMS Não Identificado." + CRLF + "O(s) produto(s) " + cIMSProb + " não possuem índice de matéria seca cadastrado. Não será possível gerar o trato até que esses índices estejam devidamente cadastrados." + CRLF)
                Help(/*Descontinuado*/,/*Descontinuado*/,"IMS Não Identificado",/**/,"O(s) produto(s) " + cIMSProb + " não possuem índice de matéria seca cadastrado. Não será possível gerar o trato até que esses índices estejam devidamente cadastrados.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, verifique." })
                Final("O protheus será finalizado para garantir sua integridade.")
                Disarmtransaction()
            endif

            LogTrato("Carregamento do índice da matéria seca para a tabela Z0V realizado com sucesso.", U_AToS(aIMS))  
            
    endif

    if !Empty(aArea)
        RestArea(aArea)
    endif
return lRet


/*/{Protheus.doc} vap05cri
Cria um plano de trato já existente ou carrega um plano já existente.
@author jr.andre
@since 25/04/2019
@version 1.0
@return nil
@type function
/*/
user function vap05cri() 
local aParam :={mv_par01}
local i, nLen
local cPerg  := "VAPCPA05"
local lRet   := .T.

    EnableKey(.F.)

    AtuSX1(@cPerg)
    U_PosSX1({ { cPerg, "01", Z0R->Z0R_DATA } })
    if Pergunte(cPerg, .T.)
        //----------------------------
        //Cria o trato caso necessário
        //----------------------------
        if !Z0R->(DbSeek(FWxFilial("Z0R")+DToS(mv_par01)))
            if (lRet := MsgYesNo("Não foi identificado nenhum trato para a data " + DToC(mv_par01) + ". Deseja criar?", "Trato não encontrado."))
                FWMsgRun(, { || u_CriaTrat(mv_par01)}, "Geração de trato", "Gerando trato para o dia " + DToC(mv_par01) + "...")
            endif
        endif
        if lRet
            FWMsgRun(, { || LoadTrat(mv_par01) }, "Carregamento do trato", "Carregando trato...")
        endif
    endif

    EnableKey(.T.)

nLen := Len(aParam)
for i := 1 to nLen
    &("mv_par" + StrZero(i, 2)) := aParam[i]
next
return nil


/*/{Protheus.doc} vap05rcr
Cria caso não exista, recria um plano de trato já existente ou carrega um plano já existente.
@author jr.andre
@since 25/04/2019
@version 1.0
@return nil
@type function
/*/
user function vap05rcr()
local aParam :={mv_par01, mv_par02, mv_par03, mv_par04, mv_par05, mv_par06, mv_par07, mv_par08}
local i, nLen
local lRet   := .T.
local cPerg  := "VAPCPA055"

    EnableKey(.F.)

    AtuSX1(@cPerg)
    U_PosSX1({ { cPerg, "01", Space(TamSX3("Z05_ROTEIR")[1]) };
             , { cPerg, "02", Replicate("Z", TamSX3("Z05_ROTEIR")[1]) };
             , { cPerg, "03", Space(TamSX3("Z05_CURRAL")[1]) };
             , { cPerg, "04", Replicate("Z", TamSX3("Z05_CURRAL")[1]) };
             , { cPerg, "05", Space(TamSX3("Z05_LOTE")[1]) };
             , { cPerg, "06", Replicate("Z", TamSX3("Z05_LOTE")[1]) };
             , { cPerg, "07", Space(TamSX3("ZV0_CODIGO")[1]) };
             , { cPerg, "08", Replicate("Z", TamSX3("ZV0_CODIGO")[1]) } })
    if Pergunte(cPerg, .T.)
        //----------------------------
        //Cria o trato caso necessário
        //----------------------------
        if !Z0R->(DbSeek(FWxFilial("Z0R")+DToS(Z0R->Z0R_DATA)))
            if (lRet := MsgYesNo("Não foi identificado nenhum trato para a data " + DToC(Z0R->Z0R_DATA) + ". Deseja criá-lo?", "Trato não encontrado."))
                FWMsgRun(, { || u_CriaTrat(Z0R->Z0R_DATA)}, "Geração de trato", "Gerando trato para o dia " + DToC(Z0R->Z0R_DATA) + "...")
            endif
        else
            if (lRet := MsgYesNo("Já existe trato para a data " + DToC(Z0R->Z0R_DATA) + ". Confirma a recriação do trato conforme com os filtros selecionados?", "Recriar trato?."))
                FWMsgRun(, { || RecrTrato(mv_par01, mv_par02, mv_par03, mv_par04, mv_par05, mv_par06, mv_par07, mv_par08)}, "Recriação de trato", "Recriação trato para o dia " + DToC(Z0R->Z0R_DATA) + "...")
            endif
        endif
        FWMsgRun(, { || LoadTrat(Z0R->Z0R_DATA) }, "Carregamento do trato", "Carregando trato...")
    endif

    EnableKey(.T.)

nLen := Len(aParam)
for i := 1 to nLen
    &("mv_par" + StrZero(i, 2)) := aParam[i]
next
return lRet


/*/{Protheus.doc} RecrTrato
Recria/Versiona o trato da na data definida, conforme os parâmetros.
@author jr.andre
@since 25/04/2019
@version 1.0
@return nil
@param dDtTrato, date, Data do trato a ser criado

@type function
/*/
static function RecrTrato(cRotaDe, cRotaAte, cCurralDe, cCurralAte, cLoteDe, cLoteAte, cVeicDe, cVeicAte)
local cVerAnt    := StrZero(1, TamSX3("Z0R_VERSAO")[1])
local cVersao    := StrZero(1, TamSX3("Z0R_VERSAO")[1])
local cSql       := ""
local cLogName   := ""
local nRecno     := 0
local lVersiona  := .F.
local lContinua  := .T.
local nTotMN     := 0
local nQuantMN   := 0
local cCposIns   := ""
local cCposSel   := ""
local cCurraDupl := ""
local cLoteDupl  := ""
local cLoteSBov  := ""

    DbSelectArea("Z0R")
    DbSetOrder(1) // Z0R_FILIAL+DToS(Z0R_DATA)+Z0R_VERSAO

    DbSelectArea("Z06")
    DbSetOrder(1) // Z06_FILIAL+DToS(Z06_DATA)+Z06_VERSAO+Z06_CURRAL+Z06_LOTE+Z06_TRATO

    DbSelectArea("Z05")
    DbSetOrder(1) // Z06_FILIAL+DToS(Z06_DATA)+Z06_VERSAO+Z06_CURRAL+Z06_LOTE+Z06_TRATO

    DbSelectArea("Z0G")
    DbSetOrder(2) // Z0G_FILIAL+Z0G_DIETA+Z0G_CODIGO

    // Avalia se pode ser recriado o trato sem versionar 

    DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                            _cSql := " with LOTES as (" +;
                                      " select B8_LOTECTL, B8_X_CURRA" +;
                                        " from " + RetSqlName("SB8") + " SB8" +;
                                       " where SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                                         " and SB8.B8_SALDO   > 0" +;
                                         " and SB8.B8_X_CURRA <> ' '" +;
                                         " and SB8.D_E_L_E_T_ = ' '" +;
                                    " group by B8_LOTECTL, B8_X_CURRA" +;
                              " )" +;
                                      " select LOTES.B8_LOTECTL, count(*) QTDE" +;
                                        " from LOTES" +;
                                    " group by LOTES.B8_LOTECTL" +;
                                      " having count(*) > 1";
                                         ), "TMPSB8", .F., .F.)
        while !TMPSB8->(Eof())
            if At(TMPSB8->B8_LOTECTL, cLoteDupl) == 0
                cLoteDupl += Iif(Empty(cLoteDupl), "", ",") + TMPSB8->B8_LOTECTL
            endif
            TMPSB8->(DbSkip())
        end
    TMPSB8->(DbCloseArea())

    DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                            _cSql := " with LOTES as (" +;
                                      " select B8_LOTECTL, B8_X_CURRA" +;
                                        " from " + RetSqlName("SB8") + " SB8" +;
                                       " where SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                                         " and SB8.B8_SALDO   > 0" +;
                                         " and SB8.B8_X_CURRA <> ' '" +;
                                         " and SB8.D_E_L_E_T_ = ' '" +;
                                    " group by B8_LOTECTL, B8_X_CURRA" +;
                              " )" +;
                                      " select LOTES.B8_X_CURRA, count(*) QTDE" +;
                                        " from LOTES" +;
                                    " group by LOTES.B8_X_CURRA" +;
                                      " having count(*) > 1";
                                         ), "TMPSB8", .F., .F.)
        while !TMPSB8->(Eof())
            if At(TMPSB8->B8_X_CURRA, cLoteDupl) == 0
                cCurraDupl += Iif(Empty(cCurraDupl), "", ",") + TMPSB8->B8_X_CURRA
            endif
            TMPSB8->(DbSkip())
        end
    TMPSB8->(DbCloseArea())

    /*
        28/05/2020 - Arthur Toshio
        Checar se tem algum produto / lote sem preenchimento de data de Início (B8_XDATACO)
    */

	DbUseArea(.T., "TOPCONN", TCGenQry(,,;
						_cSql := " with LOTES as (" +;
									" select B8_PRODUTO, B8_LOTECTL, B8_X_CURRA" +;
										" from " + RetSqlName("SB8") + " SB8" +;
									" where SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
										" and SB8.B8_SALDO   > 0" +;
										" and SB8.B8_X_CURRA <> ' '" +;
										" and SB8.B8_XDATACO = ' ' " +;
										" and SB8.D_E_L_E_T_ = ' '" +;
									" group by B8_PRODUTO, B8_LOTECTL, B8_X_CURRA" +;
							" )" +;
									" select LOTES.B8_PRODUTO, LOTES.B8_LOTECTL, LOTES.B8_X_CURRA, count(*) QTDE" +;
										" from LOTES" +;
									" group by LOTES.B8_PRODUTO, LOTES.B8_LOTECTL, LOTES.B8_X_CURRA" +;
									" having count(*) > 0";
										), "TMPSB8", .F., .F.)
		while !TMPSB8->(Eof())
			if At(TMPSB8->B8_PRODUTO, cLoteSBov) == 0
				cLoteSBov += Iif(Empty(cLoteSBov), "", ",") + "Produto: "+ AllTrim(TMPSB8->B8_PRODUTO) + " - Lote: " + AllTrim(TMPSB8->B8_LOTECTL + CRLF)
			endif
			TMPSB8->(DbSkip())
		end
	TMPSB8->(DbCloseArea())

    if !Empty(cCurraDupl) .or. !Empty(cLoteDupl)
        Help(/*Descontinuado*/,/*Descontinuado*/,"RECRIAÇÃO DO TRATO",/**/,"Existem lotes que estão em mais de um curral e/ou currais que possuem mais de um lote." , 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, verifique " + Iif(!Empty(cCurraDupl), "o(s) curral(is) " + AllTrim(cCurraDupl), "") + Iif(!Empty(cCurraDupl) .and. !Empty(cLoteDupl), " e ", "" ) + Iif(!Empty(cLoteDupl), "o(s) lote(s) " + AllTrim(cLoteDupl), "" ) + "."})
    elseIf !Empty(cLotesBov)
        Help(/*Descontinuado*/,/*Descontinuado*/,"RECRIAÇÃO DO TRATO",/**/,"Existem Produtos / Lote sem data de início preenchido, Utilizar rotina de Manutenção de Lotes para correção." , 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor verifique: " + AllTrim (cLotesBov) +  "."})
    Else 
        LogTrato("Versionamento do trato.", "Paramtros: " + CRLF + "cRotaDe = '" + cRotaDe + "'" + CRLF +;
                             "cRotaAte = '" + cRotaAte + "'" + CRLF +;
                             "cCurralDe = " + cCurralDe + "'" + CRLF +; 
                             "cCurralAte = '" + cCurralAte + "'" + CRLF +;
                             "cLoteDe = '" + cLoteDe + "'" + CRLF +;
                             "cLoteAte = '" + cLoteAte + "'" + CRLF +;
                             "cVeicDe = '" + cVeicDe + "'" + CRLF +;
                             "cVeicAte = '" + cVeicAte + "'")

        DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                _cSql := " select Z05.Z05_CURRAL, Z05.Z05_LOTE" +CRLF+;
                                         " from " + oTmpZ06:GetRealName() + " TMP" +CRLF+;
                                         " join " + RetSqlName("Z05") + " Z05" +CRLF+;
                                         "     on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" +CRLF+;
                                         "    and Z05.Z05_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" +CRLF+;
                                         "    and Z05.Z05_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +CRLF+;
                                         "    and Z05.Z05_LOTE   = TMP.B8_LOTECTL" +CRLF+;
                                         "    and Z05.Z05_LOCK   = '2'" +CRLF+;
                                         "    and Z05.D_E_L_E_T_ = ' '" +CRLF+;
                                         " where TMP.Z0T_ROTA   between '" + cRotaDe + "' and '" + cRotaAte + "'" +CRLF+;
                                         "   and TMP.Z08_CODIGO between '" + cCurralDe + "' and '" + cCurralAte + "'" +CRLF+;
                                         "   and TMP.B8_LOTECTL between '" + cLoteDe + "' and '" + cLoteAte + "'" +CRLF+;
                                         "   and TMP.Z0S_EQUIP  between '" + cVeicDe + "' and '" + cVeicAte + "'" ;
                                             ), "Z05USA", .F., .F.)

        if !Z05USA->(Eof()) .or. Z0R->Z0R_LOCK = '2' 

            if (lContinua := MsgYesNo("Existem arquivos gerado que fazem referência a um ou mais currais no filtro. Para continuar é necessário versionar o trato. Deseja continuar?", "Recriação de trato"))
                // Cria cópia versionada do último trato do dia

                begin transaction 
                LogTrato("Versionamento do trato.", "Criação da versão " + Z0R->Z0R_VERSAO + " do trato " + DToC(Z0R->Z0R_DATA) + ".")

                cVerAnt := Z0R->Z0R_VERSAO
                cVersao := Soma1(Z0R->Z0R_VERSAO)
                RecLock("Z0R", .F.)
                    Z0R->Z0R_VERSAO := cVersao
                    Z0R->Z0R_LOCK := '1'
                MsUnlock()

                lVersiona := .T.
                LogTrato("Versionamento do trato.", "Versionando Indice de Materia Seca. Data " + DToC(Z0R->Z0R_DATA) + ", versão " + Z0R->Z0R_VERSAO + ".")

                CarregaIMS(.T.)

                LogTrato("Versionamento do trato.", "Versionando cabeçalho e item do trato. Trato " + DToC(Z0R->Z0R_DATA) + ", versão " + Z0R->Z0R_VERSAO + ".")

                DbUseArea(.T., "TOPCONN", TCGenQry(,, "select max(R_E_C_N_O_) RECNO from " + RetSqlName("Z06")), "CNTREC", .F., .F.)
                    nRecno := CNTREC->RECNO
                CNTREC->(DbCloseArea())

                cCposIns := ""
                cCposSel := ""
                DbSelectArea("SX3")
                DbSetOrder(1) // X3_ARQUIVO+X3_ORDEM
                SX3->(DbSeek("Z06"))

                while !SX3->(Eof()) .and. SX3->X3_ARQUIVO == "Z06"
                    if SX3->X3_CONTEXT != "V"
                        cCposIns += Iif(!Empty(cCposIns), ",", "") + SX3->X3_CAMPO
                        cCposSel += Iif(!Empty(cCposSel), ",", "") + Iif("Z06_VERSAO" $ SX3->X3_CAMPO, "'" + cVersao + "'", SX3->X3_CAMPO)
                    endif
                    SX3->(DbSkip())
                end

                if TCSqlExec(_cSql := "insert into " + RetSqlName("Z06") + "(" + cCposIns + ", R_E_C_N_O_)" +;
                                " select " + cCposSel + ", row_number() over ( order by Z06_FILIAL, Z06_DATA, Z06_CURRAL, Z06_LOTE) + " + AllTrim(Str(nRecno)) + " R_E_C_N_O_" +;
                                  " from " + RetSqlName("Z06") +;
                                  " join (" +;
                                        " select B8_LOTECTL, sum(B8_SALDO) B8_SALDO" +;
                                          " from " + RetSqlName("SB8") +;
                                         " where B8_FILIAL = '" + FWxFilial("SB8") + "'" +;
                                           " and B8_SALDO  > 0" +;
                                           " and D_E_L_E_T_ = ' '" +;
                                      " group by B8_FILIAL, B8_LOTECTL" +;
                                       " ) SB8" +;
                                    " on SB8.B8_LOTECTL = Z06_LOTE" +;
                                 " where Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                                   " and Z06_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                                   " and Z06_VERSAO = '" + cVerAnt + "'" +;
                                   " and D_E_L_E_T_ = ' '" ) < 0
                    
                    cLogName := FunName() + DtoS(dDataBase) + "_" + StrTran(SubS(Time(),1,5),":","") + ".log"
                    MemoWrite(Iif(ExistDir(cPath), cPath, "") + cLogName, TCSQLError())
                    Help(/*Descontinuado*/,/*Descontinuado*/,"RECRIAÇÃO DO TRATO",/**/,"Ocorreu um erro ao criar a nova versao da tabela Z06. O Trato não pode ser recriado", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Para mais detalhes veja o arquivo " + cLogName + ". O sistema retornará ao status anterior para garantir a integridade dos dados." })
                    DisarmTransaction()
                    break
                endif

                DbUseArea(.T., "TOPCONN", TCGenQry(,, "select max(R_E_C_N_O_) RECNO from " + RetSqlName("Z05")), "CNTREC", .F., .F.)
                    nRecno := CNTREC->RECNO
                CNTREC->(DbCloseArea())

                cCposIns := ""
                cCposSel := ""
                DbSelectArea("SX3")
                DbSetOrder(1) // X3_ARQUIVO+X3_ORDEM
                SX3->(DbSeek("Z05"))

                while !SX3->(Eof()) .and. SX3->X3_ARQUIVO == "Z05"
                    if SX3->X3_CONTEXT != "V"
                        cCposIns += Iif(!Empty(cCposIns), ",", "") + SX3->X3_CAMPO
                        cCposSel += Iif(!Empty(cCposSel), ",", "") + Iif("Z05_VERSAO" $ SX3->X3_CAMPO, "'" + cVersao + "'", Iif("Z05_LOCK" $ SX3->X3_CAMPO,"'" + Space(TamSX3("Z05_LOCK")[1]) + "'",SX3->X3_CAMPO))
                    endif
                    SX3->(DbSkip())
                end

                if TCSqlExec(_cSql := "insert into " + RetSqlName("Z05") + "(" + cCposIns + ", R_E_C_N_O_)" +;
                                " select " + cCposSel + ", row_number() over ( order by Z05_FILIAL, Z05_DATA, Z05_CURRAL, Z05_LOTE) + " + AllTrim(Str(nRecno)) + " R_E_C_N_O_" +;
                                  " from " + RetSqlName("Z05") +;
                                  " join (" +;
                                        " select B8_LOTECTL, sum(B8_SALDO) B8_SALDO" +;
                                          " from " + RetSqlName("SB8") +;
                                         " where B8_FILIAL = '" + FWxFilial("SB8") + "'" +;
                                           " and B8_SALDO  > 0" +;
                                           " and D_E_L_E_T_ = ' '" +;
                                      " group by B8_FILIAL, B8_LOTECTL" +;
                                       " ) SB8" +;
                                    " on SB8.B8_LOTECTL = Z05_LOTE" +;
                                 " where Z05_FILIAL = '" + FWxFilial("Z05") + "'" +;
                                   " and Z05_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                                   " and Z05_VERSAO = '" + cVerAnt + "'" +;
                                   " and D_E_L_E_T_ = ' '") < 0
                    cLogName := FunName() + DtoS(dDataBase) + "_" + StrTran(SubS(Time(),1,5),":","") + ".log"
                    MemoWrite(Iif(ExistDir(cPath), cPath, "") + cLogName, TCSQLError())
                    Help(/*Descontinuado*/,/*Descontinuado*/,"RECRIAÇÃO DO TRATO",/**/,"Ocorreu um erro ao criar a nova versao da tabela Z05. O Trato não pode ser recriado", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Para mais detalhes veja o arquivo " + cLogName + ". O sistema retornará ao status anterior para garantir a integridade dos dados." })
                    DisarmTransaction()
                    break
                endif

                LogTrato("Versionamento do trato.", "Versionando Currais da Rota do Trato. Data " + DToC(Z0R->Z0R_DATA) + ", versão " + Z0R->Z0R_VERSAO + ".")
                DbUseArea(.T., "TOPCONN", TCGenQry(,, "select max(R_E_C_N_O_) RECNO from " + RetSqlName("Z0T")), "CNTREC", .F., .F.)
                    nRecno := CNTREC->RECNO
                CNTREC->(DbCloseArea())

                cCposIns := ""
                cCposSel := ""
                DbSelectArea("SX3")
                DbSetOrder(1) // X3_ARQUIVO+X3_ORDEM
                SX3->(DbSeek("Z0T"))

                while !SX3->(Eof()) .and. SX3->X3_ARQUIVO == "Z0T"
                    if SX3->X3_CONTEXT != "V"
                        cCposIns += Iif(!Empty(cCposIns), ",", "") + SX3->X3_CAMPO
                        cCposSel += Iif(!Empty(cCposSel), ",", "") + Iif("Z0T_VERSAO" $ SX3->X3_CAMPO, "'" + cVersao + "'", SX3->X3_CAMPO)
                    endif
                    SX3->(DbSkip())
                end

                if TCSqlExec(_cSql := "insert into " + RetSqlName("Z0T") + "(" + cCposIns + ", R_E_C_N_O_)" +;
                                " select " + cCposSel + ", row_number() over(order by Z0T_FILIAL, Z0T_DATA, Z0T_VERSAO, Z0T_ROTA) + " + AllTrim(Str(nRecno)) + " R_E_C_N_O_" +;
                                  " from " + RetSqlName("Z0T") + " Z0T" +;
                                  " join (" +;
                                        " select B8_X_CURRA, sum(B8_SALDO) B8_SALDO" +;
                                          " from " + RetSqlName("SB8") +;
                                         " where B8_FILIAL = '" + FWxFilial("SB8") + "'" +;
                                           " and B8_SALDO  > 0" +;
                                           " and D_E_L_E_T_ = ' '" +;
                                      " group by B8_FILIAL, B8_X_CURRA" +;
                                       " ) SB8" +;
                                    " on SB8.B8_X_CURRA = Z0T.Z0T_CURRAL" +;
                                 " where Z0T.Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" +;
                                   " and Z0T.Z0T_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                                   " and Z0T.Z0T_VERSAO = '" + cVerAnt + "'" +;
                                   " and Z0T.D_E_L_E_T_ = ' '") < 0
                    cLogName := FunName() + DtoS(dDataBase) + "_" + StrTran(SubS(Time(),1,5),":","") + ".log"
                    MemoWrite(Iif(ExistDir(cPath), cPath, "") + cLogName, TCSQLError())
                    Help(/*Descontinuado*/,/*Descontinuado*/,"RECRIAÇÃO DO TRATO",/**/,"Ocorreu um erro ao criar a nova versao da tabela Z0T. O Trato não pode ser recriado", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Para mais detalhes veja o arquivo " + cLogName + ". O sistema retornará ao status anterior para garantir a integridade dos dados." })
                    DisarmTransaction()
                    break
                endif

                LogTrato("Versionamento do trato.", "Versionando Currais da Rota do Trato. Data " + DToC(Z0R->Z0R_DATA) + ", versão " + Z0R->Z0R_VERSAO + ".")
                DbUseArea(.T., "TOPCONN", TCGenQry(,, "select max(R_E_C_N_O_) RECNO from " + RetSqlName("Z0S")), "CNTREC", .F., .F.)
                    nRecno := CNTREC->RECNO
                CNTREC->(DbCloseArea())

                cCposIns := ""
                cCposSel := ""
                DbSelectArea("SX3")
                DbSetOrder(1) // X3_ARQUIVO+X3_ORDEM
                SX3->(DbSeek("Z0S"))

                while !SX3->(Eof()) .and. SX3->X3_ARQUIVO == "Z0S"
                    if SX3->X3_CONTEXT != "V"
                        cCposIns += Iif(!Empty(cCposIns), ",", "") + SX3->X3_CAMPO
                        cCposSel += Iif(!Empty(cCposSel), ",", "") + Iif("Z0S_VERSAO" $ SX3->X3_CAMPO, "'" + cVersao + "'", SX3->X3_CAMPO)
                    endif
                    SX3->(DbSkip())
                end

                if TCSqlExec(_cSql := "insert into " + RetSqlName("Z0S") + "(" + cCposIns + ", R_E_C_N_O_)" +;
                                " select " + cCposSel + ", row_number() over(order by Z0S_FILIAL, Z0S_DATA, Z0S_VERSAO, Z0S_ROTA) + " + AllTrim(Str(nRecno)) + " R_E_C_N_O_" +;
                                  " from " + RetSqlName("Z0S") + " Z0S" +;
                                 " where Z0S.Z0S_FILIAL = '" + FWxFilial("Z0T") + "'" +;
                                   " and Z0S.Z0S_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                                   " and Z0S.Z0S_VERSAO = '" + cVerAnt + "'" +;
                                   " and Z0S.D_E_L_E_T_ = ' '") < 0
                    cLogName := FunName() + DtoS(dDataBase) + "_" + StrTran(SubS(Time(),1,5),":","") + ".log"
                    MemoWrite(Iif(ExistDir(cPath), cPath, "") + cLogName, TCSQLError())
                    Help(/*Descontinuado*/,/*Descontinuado*/,"RECRIAÇÃO DO TRATO",/**/,"Ocorreu um erro ao criar a nova versao da tabela Z0S. O Trato não pode ser recriado", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Para mais detalhes veja o arquivo " + cLogName + ". O sistema retornará ao status anterior para garantir a integridade dos dados." })
                    DisarmTransaction()
                    break
                endif

                LogTrato("Versionamento do trato.", "Ajustando as quantidades de materia natural de acordo com o trato.")

                // Atualiza quantidade de materia natural
                DbSelectArea("Z06")
                DbSetOrder(1) // Z06_FILIAL+DToS(Z06_DATA)+Z06_VERSAO+Z06_CURRAL+Z06_LOTE+Z06_TRATO
                Z06->(DbSeek(FWxFilial("Z06")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO))

                DbSelectArea("Z05")
                DbSetOrder(1) // Z05_FILIAL+DToS(Z05_DATA)+Z05_VERSAO+Z05_CURRAL+Z05_LOTE
                Z05->(DbSeek(FWxFilial("Z05")+DToS(Z06->Z06_DATA)+Z06->Z06_VERSAO+Z06->Z06_CURRAL+Z06->Z06_LOTE))

                while !Z06->(Eof()) .and. Z06->Z06_FILIAL == FWxFilial("Z06") .and. Z06->Z06_DATA == Z0R->Z0R_DATA .and. Z06->Z06_VERSAO == Z0R->Z0R_VERSAO
                    if Z06->Z06_FILIAL+DToS(Z06->Z06_DATA)+Z06->Z06_VERSAO+Z06->Z06_CURRAL+Z06->Z06_LOTE != Z05->Z05_FILIAL+DToS(Z05->Z05_DATA)+Z05->Z05_VERSAO+Z05->Z05_CURRAL+Z05->Z05_LOTE
                        RecLock("Z05", .F.)
                            Z05->Z05_TOTMSC := Z05->Z05_KGMSDI
                            Z05->Z05_TOTMSI := 0
                            Z05->Z05_TOTMNC := Z05->Z05_KGMNDI := nTotMN
                            Z05->Z05_TOTMNI := 0
                        MsUnlock()
                        Z05->(DbSeek(FWxFilial("Z05")+DToS(Z06->Z06_DATA)+Z06->Z06_VERSAO+Z06->Z06_CURRAL+Z06->Z06_LOTE))
                        nTotMN := 0
                    endif
                    nQuantMN := u_CalcQtMN(Z06->Z06_DIETA, Z06->Z06_KGMSTR)
                    RecLock("Z06", .F.)
                        Z06_KGMNTR := nQuantMN
                        Z05_KGMNT  := nQuantMN * Z05->Z05_CABECA
                    MsUnlock()
                    nTotMN += nQuantMN
                    Z06->(DbSkip())
                end

                if Z06->Z06_FILIAL+DToS(Z06->Z06_DATA)+Z06->Z06_VERSAO+Z06->Z06_CURRAL+Z06->Z06_LOTE != Z05->Z05_FILIAL+DToS(Z05->Z05_DATA)+Z05->Z05_VERSAO+Z05->Z05_CURRAL+Z05->Z05_LOTE
                    RecLock("Z05")
                        Z05->Z05_TOTMSC := Z05->Z05_KGMSDI
                        Z05->Z05_TOTMSI := 0
                        Z05->Z05_TOTMNC := Z05->Z05_KGMNDI := nTotMN
                        Z05->Z05_TOTMNI := 0
                    MsUnlock()
                    Z05->(DbSeek(FWxFilial("Z05")+DToS(Z06->Z06_DATA)+Z06->Z06_VERSAO+Z06->Z06_CURRAL+Z06->Z06_LOTE))
                endif
                end transaction
            endif

        else
   
            if !LockByName("CriaTrat" + DToS(Z0R->Z0R_DATA), .T., .T.)
                Help(/*Descontinuado*/,/*Descontinuado*/,"RECRIAÇÃO DO TRATO",/**/,"O trato na data " + DToC(Z0R->Z0R_DATA) + " está em criação ou recriação.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Não é possível manipular o trato durante a sua criação/recriação. Por favor, aguarde alguns instantes até que o processamento seja finalizado." })
            else
                begin sequence
                BeginTran()

                // Se estiver liberado recriar com a mesma versão
                if Z0R->Z0R_LOCK <= '1'
                    if InUseZ05(cRotaDe, cRotaAte, cCurralDe, cCurralAte, cLoteDe, cLoteAte, cVeicDe, cVeicAte)
                        LogTrato("RECRIAÇÃO DO TRATO", "Existem tratos em edição ou foi gerado algum arquivo de trato nessa data ou o trato já está ecerrado. Não é possível continuar a recriação do trato.")
                        Help(/*Descontinuado*/,/*Descontinuado*/,"RECRIAÇÃO DO TRATO",/**/,"Existem tratos em edição ou foi gerado algum arquivo de trato nessa data ou o trato já está ecerrado." , 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Não é possível continuar a recriação do trato."})
                        DisarmTransaction()
                        break
                    else
                        if TCSqlExec(;
                           " delete Z06" +;
                             " from " + RetSqlName("Z06") + " Z06" +;
                             " join " + oTmpZ06:GetRealName() +;
                               " on Z06.Z06_LOTE = " + oTmpZ06:GetRealName() + ".B8_LOTECTL" +;
                            " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                              " and Z06.Z06_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                              " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                              " and " + oTmpZ06:GetRealName() + ".Z0T_ROTA   between '" + cRotaDe + "' and '" + cRotaAte + "'" +;
                              " and " + oTmpZ06:GetRealName() + ".Z08_CODIGO between '" + cCurralDe + "' and '" + cCurralAte + "'" +;
                              " and " + oTmpZ06:GetRealName() + ".B8_LOTECTL between '" + cLoteDe + "' and '" + cLoteAte + "'" +;
                              " and " + oTmpZ06:GetRealName() + ".Z0S_EQUIP  between '" + cVeicDe + "' and '" + cVeicAte + "'" +;
                              " and Z06.D_E_L_E_T_ = ' '" ;
                                    ) < 0 
                            Help(/*Descontinuado*/,/*Descontinuado*/,"RECRIAÇÃO DO TRATO",/**/,"Ocorreu um problema durante a recriação do trato:" + CRLF + TCSQLError(), 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, entrem em contato com o TI e mostre o erro apresentado. O sistema retornará ao status anterior para garantir a integridade dos dados." })
                            DisarmTransaction()
                            LogTrato("Recriação do trato.", "Ocorreu um problema durante a recriação da tabela Z06:" + CRLF + TCSQLError())
                            break
                        endif
                        if TCSqlExec(;
                                _cSql := " delete Z05" +CRLF+;
                                         " from " + RetSqlName("Z05") + " Z05" +CRLF+;
                                         " join " + oTmpZ06:GetRealName() +CRLF+;
                                         "      on Z05.Z05_LOTE = " + oTmpZ06:GetRealName() + ".B8_LOTECTL" +CRLF+;
                                         " where Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" +CRLF+;
                                         "   and Z05.Z05_DATA   = '"  + DToS(Z0R->Z0R_DATA) +  "'" +CRLF+;
                                         "   and Z05.Z05_VERSAO >= '" + Z0R->Z0R_VERSAO + "'" +CRLF+;
                                         "   and " + oTmpZ06:GetRealName() + ".Z0T_ROTA   between '" + cRotaDe + "' and '" + cRotaAte + "'" +CRLF+;
                                         "   and " + oTmpZ06:GetRealName() + ".Z08_CODIGO between '" + cCurralDe + "' and '" + cCurralAte + "'" +CRLF+;
                                         "   and " + oTmpZ06:GetRealName() + ".B8_LOTECTL between '" + cLoteDe + "' and '" + cLoteAte + "'" +CRLF+;
                                         "   and " + oTmpZ06:GetRealName() + ".Z0S_EQUIP  between '" + cVeicDe + "' and '" + cVeicAte + "'" +CRLF+;
                                         "   and Z05.D_E_L_E_T_ = ' '" ;
                                    ) < 0 
                            Help(/*Descontinuado*/,/*Descontinuado*/,"RECRIAÇÃO DO TRATO",/**/,"Ocorreu um problema durante a recriação do trato:" + CRLF + TCSQLError(), 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, entrem em contato com o TI e mostre o erro apresentado. O sistema retornará ao status anterior para garantir a integridade dos dados." })
                            DisarmTransaction()
                            LogTrato("Recriação do trato.", "Ocorreu um problema durante a recriação da tabela Z05:" + CRLF + TCSQLError())
                            break
                        endif
                        LogTrato("Recriação do trato.", "Foram excluidos os registros do trato " + DToS(Z0R->Z0R_DATA) + " - " + Z0R->Z0R_VERSAO + ".")
                    endif
                // caso contrario é necessário versionar os itens
                elseif Z0R->Z0R_LOCK == '3' 
                    Help(/*Descontinuado*/,/*Descontinuado*/,"RECRIAÇÃO DO TRATO",/**/,"O trato na data " + DToC(Z0R->Z0R_DATA) + " foi finalizado. Não é possível recriá-lo.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"O sistema retornará ao status anterior para garantir a integridade dos dados." })
                    DisarmTransaction()
                    break
                // caso contrario é necessário versionar os itens
                endif

                // recria a IMS somente quando todos os currais forem recriados
                if       cRotaDe == Space(TamSX3("Z05_ROTEIR")[1]) ;
                   .and. cRotaAte == Replicate("Z", TamSX3("Z05_ROTEIR")[1]) ;
                   .and. cCurralDe == Space(TamSX3("Z05_CURRAL")[1]) ;
                   .and. cCurralAte == Replicate("Z", TamSX3("Z05_CURRAL")[1]) ;
                   .and. cLoteDe == Space(TamSX3("Z05_LOTE")[1]) ;
                   .and. cLoteAte == Replicate("Z", TamSX3("Z05_LOTE")[1]) ;
                   .and. cVeicDe == Space(TamSX3("ZV0_CODIGO")[1]) ;
                   .and. cVeicAte == Replicate("Z", TamSX3("ZV0_CODIGO")[1])
                    CarregaIMS(.T.)
                endif
                
                LogTrato("Recriação de trato", "Recriando trato " + DToS(Z0R->Z0R_DATA) + " versao " + cVersao + ".")
                if !Empty(aIMS)
                    LogTrato("Utilizando tabela de Indice de Matéria Seca", u_AToS(aIMS))

                    cSql := " with Lotes as (" + CRLF +;
                            "       select Z08_FILIAL" + CRLF +;
                            "            , Z08_CONFNA" + CRLF +;
                            ;//" , Z08.Z08_LINHA" + CRLF +;
                            "            , Z08.Z08_CODIGO" + CRLF +;
                            "            , SB8.B8_LOTECTL" + CRLF +;
                            "            , round(sum(SB8.B8_XPESOCO*SB8.B8_SALDO)/sum(SB8.B8_SALDO), 2) B8_XPESOCO" + CRLF +;
                            "            , sum(SB8.B8_SALDO) B8_SALDO" + CRLF +;
                            "            , min(SB8.B8_XDATACO) DT_ENTRADA" + CRLF +;
                            "            , cast(convert(datetime, '" + DToS(Z0R->Z0R_DATA) + "', 103) - convert(datetime, min(SB8.B8_XDATACO), 103) as numeric)+1 DIAS_NO_CURRAL -- Dias Cocho" + CRLF +;
                            "       from " + RetSqlName("Z08") + " Z08" + CRLF +;
                            "       join " + RetSqlName("SB8") + " SB8" + CRLF +;
                            "            on SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" + CRLF +;
                            "           and SB8.B8_X_CURRA = Z08.Z08_CODIGO" + CRLF +;
                            "           and SB8.B8_SALDO   > 0" + CRLF +;
                            "           and SB8.D_E_L_E_T_ = ' '" + CRLF +;
                            "       where Z08.Z08_FILIAL = '" + FWxFilial("Z08") + "'" + CRLF +;
                            "         and Z08.Z08_MSBLQL <> '1'" + CRLF +;
                            "         and Z08.D_E_L_E_T_ = ' '" + CRLF +;
                            "       group by Z08_FILIAL" + CRLF +;
                            "              , Z08_CONFNA" + CRLF +;
                            ;//" , Z08.Z08_LINHA" + CRLF +;
                            "              , Z08.Z08_CODIGO" + CRLF +;
                            "              , B8_LOTECTL" + CRLF +;
                            " )" + CRLF
                    cSql += " , UltDiaPlanNut as (" + CRLF +;
                            "           select Z0M_CODIGO" + CRLF +;
                            "                , Z0M_DESCRI" + CRLF +;
                            "                , Z0M_PESO" + CRLF +;
                            "                , max(Z0M_DIA) MAIORDIAPL" + CRLF +;
                            "           from " + RetSqlName("Z0M") + " Z0M" + CRLF +;
                            "           where Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" + CRLF +;
                            "             and Z0M.Z0M_VERSAO = (" + CRLF +;
                            "                       select max(VER.Z0M_VERSAO)" + CRLF +;
                            "                       from " + RetSqlName("Z0M") + " VER" + CRLF +;
                            "                       where VER.Z0M_FILIAL = Z0M.Z0M_FILIAL" + CRLF +;
                            "                         and VER.Z0M_CODIGO = Z0M.Z0M_CODIGO" + CRLF +;
                            "                         and VER.Z0M_CODIGO <> '999999'" + CRLF +;
                            "                         and VER.D_E_L_E_T_ = ' '" + CRLF +;
                            "             )" + CRLF +;
                            "             and Z0M.Z0M_CODIGO <> '999999' " + CRLF +;
                            "             and Z0M.D_E_L_E_T_ = ' '" + CRLF +;
                            "           group by Z0M_CODIGO" + CRLF +;
                            "                  , Z0M_DESCRI" + CRLF +;
                            "                  , Z0M_PESO" + CRLF +;
                            " )" + CRLF
                    cSql += " , NotaCocho as (" + CRLF +;
                            "           select Z0I.Z0I_LOTE, Z0I.Z0I_NOTMAN" + CRLF +;
                            "           from " + RetSqlName("Z0I") + " Z0I" + CRLF +;
                            "           where Z0I.Z0I_FILIAL = '" + FWxFilial("Z0I") + "'" + CRLF +;
                            "             and Z0I.Z0I_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                            "             and Z0I.D_E_L_E_T_ = ' '" + CRLF +;
                            " )" + CRLF
                    cSql += " , InicTrato as (" + CRLF +;
                            "           select Z0O.Z0O_FILIAL" + CRLF +;
                            "                , Z0O.Z0O_LOTE" + CRLF +;
                            "                , Z0O.Z0O_CODPLA" + CRLF +;
                            "                , Z0O.Z0O_DIAIN" + CRLF +;
                            "                , MinReg.Z0O_DATAIN" + CRLF +;
                            "                , Z0O.Z0O_DATATR" + CRLF +;
                            "                , Z0O.Z0O_GMD" + CRLF +;
                            "                , Z0O.Z0O_DCESP" + CRLF +;
                            "                , Z0O.Z0O_RENESP" + CRLF +;
                            "           from " + RetSqlName("Z0O") + " Z0O" + CRLF +;
                            "           join (" + CRLF +;
                            "                   select Z0O_FILIAL, Z0O_LOTE, min(Z0O_DATAIN) Z0O_DATAIN" + CRLF +;
                            "                   from " + RetSqlName("Z0O") + CRLF +;
                            "                   where D_E_L_E_T_ = ' '" + CRLF +;
                            "                   group by Z0O_FILIAL, Z0O_LOTE" + CRLF +;
                            "                   ) MinReg" + CRLF +;
                            "               on MinReg.Z0O_FILIAL = Z0O.Z0O_FILIAL" + CRLF +;
                            "              and MinReg.Z0O_LOTE   = Z0O.Z0O_LOTE" + CRLF +;
                            "           where Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" + CRLF +;
                            "             and (('" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR) or (Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        '))" + CRLF +;
                            "             and Z0O.Z0O_CODPLA  <> '999999'" + CRLF +;
                            "             and Z0O.D_E_L_E_T_ = ' '" + CRLF +;
                            " )" + CRLF 
                    cSql += " ,  DiasPlano as (" + CRLF +;
                            "           select Z0O.Z0O_FILIAL" + CRLF +;
                            "                , Z0O.Z0O_LOTE" + CRLF +;
                            "                , Z0O.Z0O_CODPLA" + CRLF +;
                            "                , Z0O.Z0O_DIAIN" + CRLF +;
                            "                , Z0O.Z0O_DATAIN" + CRLF +;
                            "                , Z0O.Z0O_DATATR" + CRLF +;
                            "                , Z0O.Z0O_GMD" + CRLF +;
                            "                , Z0O.Z0O_DCESP" + CRLF +;
                            "                , Z0O.Z0O_RENESP" + CRLF +;
                            "           from " + RetSqlName("Z0O") + " Z0O" + CRLF +;
                            "           where Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" + CRLF +;
                            "             and (('" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR) or (Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        '))" + CRLF +;
                            "             and Z0O.Z0O_CODPLA  <> '999999'" + CRLF +;
                            "             and Z0O.D_E_L_E_T_ = ' '" + CRLF +;
                            " )"  + CRLF + CRLF

                    cSql += " select Lotes.Z08_CONFNA" + CRLF +; //", Lotes.Z08_LINHA" + CRLF +;
                            "      , Lotes.Z08_CODIGO" + CRLF +;
                            "      , Lotes.B8_LOTECTL" + CRLF +;
                            "      , Lotes.B8_XPESOCO" + CRLF +;
                            "      , Lotes.B8_SALDO" + CRLF +;
                            "      , Lotes.DT_ENTRADA" + CRLF +;
                            "      , Lotes.DIAS_NO_CURRAL" + CRLF +;
                            "      , InicTrato.Z0O_DATAIN" + CRLF +;
                            "      , case when Z0O.Z0O_CODPLA = '999999'  then null " + CRLF +;
                            "      	      when Z0O.Z0O_DATATR <> ' ' AND Z0O.Z0O_DATATR < GETDATE() then null  " + CRLF +;
                            "      		  else Z0O.Z0O_CODPLA " + CRLF +;
                            "      		  end Z0O_CODPLA" + CRLF +;
                            "      , case when Z0O.Z0O_CODPLA = '999999'  then null " + CRLF +;
                            "      	      when Z0O.Z0O_DATATR <> ' ' AND Z0O.Z0O_DATATR < GETDATE() then null  " + CRLF +;
                            "      		  else Z0O.Z0O_DIAIN " + CRLF +;
                            "      		  end Z0O_DIAIN" + CRLF +;
                            "      , DIAS_NO_CURRAL DIAS_COCHO" + CRLF +;  
                            "      , CASE " + CRLF +;
                            "           when cast(UltDiaPlanNut.MAIORDIAPL as numeric) <= cast(convert(datetime, '" + DToS(Z0R->Z0R_DATA) + "', 103) - convert(datetime, DiasPlano.Z0O_DATAIN, 103) as numeric) + cast(Z0O.Z0O_DIAIN as numeric)" + CRLF +; // O primeiro dia é o dia 1 e não o dia 0
                            "           then right('000' + UltDiaPlanNut.MAIORDIAPL, 3)" + CRLF +;
                            "           else right('000' + cast((cast(convert(datetime, '" + DToS(Z0R->Z0R_DATA) + "', 103) - convert(datetime, DiasPlano.Z0O_DATAIN, 103) as numeric) + cast(Z0O.Z0O_DIAIN as numeric)) as varchar(3)), 3)" + CRLF +;
                            "       END DIA_PLNUTRI" + CRLF +;
                            "      , right('000' + cast((cast(convert(datetime, '" + DToS(Z0R->Z0R_DATA) + "', 103) - convert(datetime, DiasPlano.Z0O_DATAIN, 103) as numeric) + cast(Z0O.Z0O_DIAIN as numeric)) as varchar(3)), 3) DIAS_NO_PLANO" + CRLF +;
                            "      , Z0O.Z0O_GMD" + CRLF +;
                            "      , Z0O.Z0O_DCESP" + CRLF +;
                            "      , Z0O.Z0O_RENESP" + CRLF +;
                            "      , Z0O.Z0O_PESO" + CRLF +;
                            "      , Z0O.Z0O_CMSPRE" + CRLF +;
                            "      , UltDiaPlanNut.Z0M_DESCRI" + CRLF +;
                            "      , UltDiaPlanNut.Z0M_PESO" + CRLF +;
                            "      , UltDiaPlanNut.MAIORDIAPL" + CRLF +;
                            "      , isnull(NotaCocho.Z0I_NOTMAN, '" + Space(TamSX3("Z0I_NOTMAN")[1]) + "') NOTA_MANHA" + CRLF +;
                            " from Lotes" + CRLF +;
                            " left join " + oTmpZ06:GetRealName() + " TMP" + CRLF +;
                            "       on TMP.B8_LOTECTL = Lotes.B8_LOTECTL" + CRLF +;
                            "      and TMP.Z08_CODIGO = Lotes.Z08_CODIGO" + CRLF +;
                            " left join " + RetSqlName("Z0O") + " Z0O" + CRLF +;
                            "       on Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" + CRLF +;
                            "      and Z0O.Z0O_LOTE   = Lotes.B8_LOTECTL" + CRLF +;
                            "      --and ('" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR or ( Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        ')) " + CRLF +;
                            "      --and Z0O.Z0O_CODPLA <> '999999' " + CRLF +;
                            "      and Z0O.D_E_L_E_T_ = ' '" + CRLF +;
                            " left join UltDiaPlanNut" + CRLF +;
                            "       on UltDiaPlanNut.Z0M_CODIGO = Z0O.Z0O_CODPLA" + CRLF +;
                            "      and UltDiaPlanNut.Z0M_CODIGO <> '999999'" + CRLF +;
                            " left join NotaCocho" + CRLF +;
                            "       on NotaCocho.Z0I_LOTE = Lotes.B8_LOTECTL" + CRLF +;
                            " left join InicTrato" + CRLF +;
                            "       on InicTrato.Z0O_LOTE = Lotes.B8_LOTECTL" + CRLF +;
                            " left join DiasPlano" + CRLF +;
                            "       on DiasPlano.Z0O_LOTE = Lotes.B8_LOTECTL" + CRLF +;
                            "      and DiasPlano.Z0O_CODPLA <> '999999'" + CRLF +;
                            " where TMP.Z0T_ROTA between '" + cRotaDe + "' and '" + cRotaAte + "'" + CRLF +;
                            "   and Lotes.Z08_CODIGO between '" + cCurralDe + "' and '" + cCurralAte + "'" + CRLF +;
                            "   and Lotes.B8_LOTECTL between '" + cLoteDe + "' and '" + cLoteAte + "'" + CRLF +;
                            "   and TMP.Z0S_EQUIP between '" + cVeicDe + "' and '" + cVeicAte + "'" + CRLF +;
                            " order by Z08_CONFNA" + CRLF +;
                            "        , Z08_CODIGO"
                
                    if lDebug .and. lower(cUserName) $ 'mbernardo,atoshio,admin,administrador,rsantana'
                        MemoWrite(cPath + FunName() + DtoS(dDataBase) + "_" + StrTran(SubS(Time(),1,5),":","") + "_RecrTrato.sql", cSql)
                    endif

                    if Select("LOTES") > 0
                        LOTES->(DbCloseArea())
                    endif
                    DbUseArea(.T., "TOPCONN", TCGenQry(,,cSql),"LOTES", .F., .F.)

                    while !LOTES->(Eof())
                        CriaZ05()
                        LOTES->(DbSkip())
                    end
                    LOTES->(DbCloseArea())
                endif
                EndTran()
                recover
                    if FWinTTSBreak()
                        DisarmTransaction()
                    endif
                end sequence
    
                UnLockByName("CriaTrat" + DToS(Z0R->Z0R_DATA), .T., .T.)
            endif
        endif

        if Type("oBrowse") == "O"
            oBrowse:SetDescription("Programação do Trato - " + DToC(Z0R->Z0R_DATA))
        endif

        Z05USA->(DbCloseArea())
    endif


return nil


/*/{Protheus.doc} CriaTrat
Cria ou recria o trato da na data definida, conforme os parâmetros.
@author jr.andre
@since 25/04/2019
@version 1.0
@return nil
@param dDtTrato, date, Data do trato a ser criado
@param lRecria, logical, Indice se trata-se da recriação do trato. Nesse caso serão excluidas todas as definições do trato existente e os dados recriados de acordo com os parâmetros.

@type function
/*/
user function CriaTrat(dDtTrato, lRecria)
local cVersao    := StrZero(1, TamSX3("Z0R_VERSAO")[1])
local cSql       := ""
local nRecno     := 0
local cCurraDupl := ""
local cLoteDupl  := ""
local cLoteSBov  := ""

default lRecria  := .F.

DbSelectArea("Z0R")
DbSetOrder(1) // Z0R_FILIAL+DToS(Z0R_DATA)+Z0R_VERSAO

DbSelectArea("Z06")
DbSetOrder(1) // Z06_FILIAL+DToS(Z06_DATA)+Z06_VERSAO+Z06_CURRAL+Z06_LOTE+Z06_TRATO

DbSelectArea("Z05")
DbSetOrder(1) // Z06_FILIAL+DToS(Z06_DATA)+Z06_VERSAO+Z06_CURRAL+Z06_LOTE+Z06_TRATO

DbSelectArea("Z0G")
DbSetOrder(2) // Z0G_FILIAL+Z0G_DIETA+Z0G_CODIGO

if !LockByName("CriaTrat" + DToS(dDtTrato), .T., .T.)
    Help(/*Descontinuado*/,/*Descontinuado*/,"CRIAÇÃO/RECRIAÇÃO DO TRATO",/**/,"O trato na data " + DToC(mv_par01) + " está em criação.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Não é possível manipular o trato durante a sua criação. Por favor, aguarde alguns instantes até que o trato seja criado." })
else

    DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                              " with LOTES as (" +;
                                      " select B8_LOTECTL, B8_X_CURRA" +;
                                        " from " + RetSqlName("SB8") + " SB8" +;
                                       " where SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                                         " and SB8.B8_SALDO   > 0" +;
                                         " and SB8.B8_X_CURRA <> ' '" +;
                                         " and SB8.D_E_L_E_T_ = ' '" +;
                                    " group by B8_LOTECTL, B8_X_CURRA" +;
                              " )" +;
                                      " select LOTES.B8_LOTECTL, count(*) QTDE" +;
                                        " from LOTES" +;
                                    " group by LOTES.B8_LOTECTL" +;
                                      " having count(*) > 1";
                                         ), "TMPSB8", .F., .F.)
        while !TMPSB8->(Eof())
            if At(TMPSB8->B8_LOTECTL, cLoteDupl) == 0
                cLoteDupl  += Iif(Empty(cLoteDupl), "", ",") + TMPSB8->B8_LOTECTL
            endif
            TMPSB8->(DbSkip())
        end
    TMPSB8->(DbCloseArea())

    DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                              " with LOTES as (" +;
                                      " select B8_LOTECTL, B8_X_CURRA" +;
                                        " from " + RetSqlName("SB8") + " SB8" +;
                                       " where SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                                         " and SB8.B8_SALDO   > 0" +;
                                         " and SB8.B8_X_CURRA <> ' '" +;
                                         " and SB8.D_E_L_E_T_ = ' '" +;
                                    " group by B8_LOTECTL, B8_X_CURRA" +;
                              " )" +;
                                      " select LOTES.B8_X_CURRA, count(*) QTDE" +;
                                        " from LOTES" +;
                                    " group by LOTES.B8_X_CURRA" +;
                                      " having count(*) > 1";
                                         ), "TMPSB8", .F., .F.)
        while !TMPSB8->(Eof())
            if At(TMPSB8->B8_X_CURRA, cLoteDupl) == 0
                cCurraDupl += Iif(Empty(cCurraDupl), "", ",") + TMPSB8->B8_X_CURRA
            endif
            TMPSB8->(DbSkip())
        end
    TMPSB8->(DbCloseArea())

    /*
        28/05/2020 - Arthur Toshio
        Checar se tem algum produto / lote sem preenchimento de data de Início (B8_XDATACO)
    */

	DbUseArea(.T., "TOPCONN", TCGenQry(,,;
							" with LOTES as (" +;
									" select B8_PRODUTO, B8_LOTECTL, B8_X_CURRA" +;
										" from " + RetSqlName("SB8") + " SB8" +;
									" where SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
										" and SB8.B8_SALDO   > 0" +;
										" and SB8.B8_X_CURRA <> ' '" +;
										" and SB8.B8_XDATACO = ' ' " +;
										" and SB8.D_E_L_E_T_ = ' '" +;
									" group by B8_PRODUTO, B8_LOTECTL, B8_X_CURRA" +;
							" )" +;
									" select LOTES.B8_PRODUTO, LOTES.B8_LOTECTL, LOTES.B8_X_CURRA, count(*) QTDE" +;
										" from LOTES" +;
									" group by LOTES.B8_PRODUTO, LOTES.B8_LOTECTL, LOTES.B8_X_CURRA" +;
									" having count(*) > 0";
										), "TMPSB8", .F., .F.)
		while !TMPSB8->(Eof())
			if At(TMPSB8->B8_PRODUTO, cLoteSBov) == 0
				cLoteSBov += Iif(Empty(cLoteSBov), "", ",") + "Produto: "+ AllTrim(TMPSB8->B8_PRODUTO) + " - Lote: " + AllTrim(TMPSB8->B8_LOTECTL)
			endif
			TMPSB8->(DbSkip())
		end
	TMPSB8->(DbCloseArea())

    if !Empty(cCurraDupl) .or. !Empty(cLoteDupl)
        Help(/*Descontinuado*/,/*Descontinuado*/,"CRIAÇÃO DO TRATO",/**/,"Existem lotes que estão em mais de um curral e/ou currais que possuem mais de um lote." , 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, verifique " + Iif(!Empty(cCurraDupl), "o(s) curral(is) " + AllTrim(cCurraDupl), "") + Iif(!Empty(cCurraDupl) .and. !Empty(cLoteDupl), " e ", "" ) + Iif(!Empty(cLoteDupl), "o(s) lote(s) " + AllTrim(cLoteDupl), "" ) + "."})
    elseIf !Empty(cLotesBov)
        Help(/*Descontinuado*/,/*Descontinuado*/,"CRIAÇÃO DO TRATO",/**/,"Existem Produtos / Lote sem preenchimento da DATA DE INÍCIO, Utilizar rotina de Manutenção de Lotes para correção." , 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor verifique os produto(s) e Lote (s): " + AllTrim (cLotesBov) +  "."})
    elseif Z0R->(DbSeek(FWxFilial("Z0R")+DToS(dDtTrato)))
        Help(/*Descontinuado*/,/*Descontinuado*/,"CRIAÇÃO DO TRATO",/**/,"O trato já foi criado na data " + DToC(dDtTrato) + "." , 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Para recriar o trato use o botão recriar."})
    else

        begin sequence
        BeginTran()

        RecLock("Z0R", .T.)
            Z0R->Z0R_FILIAL := FWxFilial("Z0R")
            Z0R->Z0R_DATA   := dDtTrato
            Z0R->Z0R_VERSAO := cVersao
            Z0R->Z0R_HORA   := Time()
            Z0R->Z0R_LOG    := MsgLog("Criação do trato.", "Criado por [" + cUserName + "] através da rotina [" + FunName() + "]. ")
            Z0R->Z0R_USER   := cUserName
            Z0R->Z0R_LOCK   := "0"
        MsUnlock()
        
        CarregaIMS()

        LogTrato("Criação de trato", "Criando trato " + DToS(Z0R->Z0R_DATA) + " versao " + Z0R->Z0R_VERSAO + ".")
        if !Empty(aIMS)
            LogTrato("Utilizando tabela de Indice de Matéria Seca", u_AToS(aIMS))

            cSql := " with Lotes as (" + CRLF +;
                              " select Z08_FILIAL" + CRLF +;
                                   " , Z08_CONFNA" + CRLF +;
                                   ;//" , Z08.Z08_LINHA" + CRLF +;
                                   " , Z08.Z08_CODIGO" + CRLF +;
                                   " , SB8.B8_LOTECTL" + CRLF +;
                                   " , round(sum(SB8.B8_XPESOCO*SB8.B8_SALDO)/sum(SB8.B8_SALDO), 2) B8_XPESOCO" + CRLF +;
                                   " , sum(SB8.B8_SALDO) B8_SALDO" + CRLF +;
                                   " , min(SB8.B8_XDATACO) DT_ENTRADA" + CRLF +;
                                   " , cast(convert(datetime, '" + DToS(Z0R->Z0R_DATA) + "', 103) - convert(datetime, min(SB8.B8_XDATACO), 103) as numeric)+1 DIAS_NO_CURRAL -- Dias Cocho" + CRLF +;
                                " from " + RetSqlName("Z08") + " Z08" + CRLF +;
                                " join " + RetSqlName("SB8") + " SB8" + CRLF +;
                                  " on SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" + CRLF +;
                                 " and SB8.B8_X_CURRA = Z08.Z08_CODIGO" + CRLF +;
                                 " and SB8.B8_SALDO    > 0" + CRLF +;
                                 " and SB8.D_E_L_E_T_ = ' '" + CRLF +;
                               " where Z08.Z08_FILIAL = '" + FWxFilial("Z08") + "'" + CRLF +;
                                 " and Z08.Z08_MSBLQL <> '1'" + CRLF +;
                                 " and Z08.D_E_L_E_T_ = ' '" + CRLF +;
                            " group by Z08_FILIAL" + CRLF +;
                                   " , Z08_CONFNA" + CRLF +;
                                   ;//" , Z08.Z08_LINHA" + CRLF +;
                                   " , Z08.Z08_CODIGO" + CRLF +;
                                   " , B8_LOTECTL" + CRLF +;
                    " )" + CRLF
            cSql += " , UltDiaPlanNut as (" + CRLF +;
                              " select Z0M_CODIGO" + CRLF +;
                                   " , Z0M_DESCRI" + CRLF +;
                                   " , Z0M_PESO" + CRLF +;
                                   " , max(Z0M_DIA) MAIORDIAPL" + CRLF +; //" , Z0M_GMD" 
                                " from " + RetSqlName("Z0M") + " Z0M" + CRLF +;
                               " where Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" + CRLF +;
                                 " and Z0M.Z0M_VERSAO = (" + CRLF +;
                                     " select max(VER.Z0M_VERSAO)" + CRLF +;
                                       " from " + RetSqlName("Z0M") + " VER" + CRLF +;
                                      " where VER.Z0M_FILIAL = Z0M.Z0M_FILIAL" + CRLF +;
                                        " and VER.Z0M_CODIGO = Z0M.Z0M_CODIGO" + CRLF +;
                                        " and VER.Z0M_CODIGO <> '999999' " + CRLF +;
                                        " and VER.D_E_L_E_T_ = ' '" + CRLF +;
                                     " )" + CRLF +;
                                 " and Z0M.Z0M_CODIGO <> '999999' " + CRLF +;
                                 " and Z0M.D_E_L_E_T_ = ' '" + CRLF +;
                            " group by Z0M_CODIGO" + CRLF +;
                                   " , Z0M_DESCRI" + CRLF +;
                                   " , Z0M_PESO" + CRLF +; //" , Z0M_GMD" 
                    " )" + CRLF
            cSql += " , NotaCocho as (" + CRLF +;
                              " select Z0I.Z0I_LOTE, Z0I.Z0I_NOTMAN" + CRLF +;
                                " from " + RetSqlName("Z0I") + " Z0I" + CRLF +;
                               " where Z0I.Z0I_FILIAL = '" + FWxFilial("Z0I") + "'" + CRLF +;
                                 " and Z0I.Z0I_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                                 " and Z0I.D_E_L_E_T_ = ' '" + CRLF +;
                    " )" + CRLF
            cSql += " , InicTrato as (" + CRLF +;
                              " select Z0O.Z0O_FILIAL" + CRLF +;
                                   " , Z0O.Z0O_LOTE" + CRLF +;
                                   " , Z0O.Z0O_CODPLA" + CRLF +;
                                   " , Z0O.Z0O_DIAIN" + CRLF +;
                                   " , MinReg.Z0O_DATAIN" + CRLF +;
                                   " , Z0O.Z0O_DATATR" + CRLF +;
                                   " , Z0O.Z0O_GMD" + CRLF +;
                                   " , Z0O.Z0O_DCESP" + CRLF +;
                                   " , Z0O.Z0O_RENESP" + CRLF +;
                                " from " + RetSqlName("Z0O") + " Z0O" + CRLF +;
                                " join (" + CRLF +;
                                      " select Z0O_FILIAL, Z0O_LOTE, min(Z0O_DATAIN) Z0O_DATAIN" + CRLF +;
                                      " from " + RetSqlName("Z0O") + CRLF +;
                                      " where D_E_L_E_T_ = ' '" + CRLF +;
                                      " group by Z0O_FILIAL, Z0O_LOTE" + CRLF +;
                                     " ) MinReg" + CRLF +;
                                  " on MinReg.Z0O_FILIAL = Z0O.Z0O_FILIAL" + CRLF +;
                                 " and MinReg.Z0O_LOTE   = Z0O.Z0O_LOTE" + CRLF +;
                               " where Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" + CRLF +;
                                 " and (('" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR) or (Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        '))" + CRLF +;
                                 " and Z0O.Z0O_CODPLA <> '999999'"  + CRLF +;
                                 " and Z0O.D_E_L_E_T_ = ' '" + CRLF +;
                    " )" + CRLF
            cSql += " ,  DiasPlano as (" + CRLF +;
                         " select Z0O.Z0O_FILIAL" + CRLF +;
                              " , Z0O.Z0O_LOTE" + CRLF +;
                              " , Z0O.Z0O_CODPLA" + CRLF +;
                              " , Z0O.Z0O_DIAIN" + CRLF +;
                              " , Z0O.Z0O_DATAIN" + CRLF +;
                              " , Z0O.Z0O_DATATR" + CRLF +;
                              " , Z0O.Z0O_GMD" + CRLF +;
                              " , Z0O.Z0O_DCESP" + CRLF +;
                              " , Z0O.Z0O_RENESP" + CRLF +;
                           " from " + RetSqlName("Z0O") + " Z0O" + CRLF +;
                          " where Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" + CRLF +;
                            " and (('" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR) or (Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        '))" + CRLF +;
                            " and Z0O.Z0O_CODPLA <> '999999'" + CRLF +;
                            " and Z0O.D_E_L_E_T_ = ' '" + CRLF +;
                     " )"  + CRLF 
            cSql +=           " select Lotes.Z08_CONFNA" + CRLF +; //", Lotes.Z08_LINHA" 
                                    ", Lotes.Z08_CODIGO" + CRLF +;
                                    ", Lotes.B8_LOTECTL" + CRLF +;
                                    ", Lotes.B8_XPESOCO" + CRLF +;
                                    ", Lotes.B8_SALDO" + CRLF +;
                                    ", Lotes.DT_ENTRADA" + CRLF +;
                                    ", Lotes.DIAS_NO_CURRAL" + CRLF +;
                                    ", InicTrato.Z0O_DATAIN" + CRLF +;
                                    ", case when Z0O.Z0O_CODPLA = '999999'  then null " + CRLF +;
                                    "       when Z0O.Z0O_DATATR <> ' ' AND Z0O.Z0O_DATATR < GETDATE() then null  " + CRLF +;
                                    "       else Z0O.Z0O_CODPLA " + CRLF +;
                                    "       end Z0O_CODPLA" + CRLF +;
                                    ", case when Z0O.Z0O_CODPLA = '999999'  then null " + CRLF +;
                                    "	    when Z0O.Z0O_DATATR <> ' ' AND Z0O.Z0O_DATATR < GETDATE() then null " + CRLF +;
                                    "		else Z0O.Z0O_DIAIN " + CRLF +;
                                    "		end Z0O_DIAIN" + CRLF +;
                                    ", DIAS_NO_CURRAL DIAS_COCHO" + CRLF +; 
                                   " , case " + CRLF +;
                                          " when cast(UltDiaPlanNut.MAIORDIAPL as numeric) <= cast(convert(datetime, '" + DToS(Z0R->Z0R_DATA) + "', 103) - convert(datetime, DiasPlano.Z0O_DATAIN, 103) as numeric) + cast(Z0O.Z0O_DIAIN as numeric)" + CRLF +; // O primeiro dia é o dia 1 e não o dia 0
                                          " then right('000' + UltDiaPlanNut.MAIORDIAPL, 3)" + CRLF +;
                                          " else right('000' + cast((cast(convert(datetime, '" + DToS(Z0R->Z0R_DATA) + "', 103) - convert(datetime, DiasPlano.Z0O_DATAIN, 103) as numeric) + cast(Z0O.Z0O_DIAIN as numeric)) as varchar(3)), 3)" + CRLF +;
                                      " end DIA_PLNUTRI" + CRLF +;
                                   " , right('000' + cast((cast(convert(datetime, '" + DToS(Z0R->Z0R_DATA) + "', 103) - convert(datetime, DiasPlano.Z0O_DATAIN, 103) as numeric) + cast(Z0O.Z0O_DIAIN as numeric)) as varchar(3)), 3) DIAS_NO_PLANO" + CRLF +;
                                   " , Z0O.Z0O_GMD" + CRLF +;
                                   " , Z0O.Z0O_DCESP" + CRLF +;
                                   " , Z0O.Z0O_RENESP" + CRLF +;
                                   " , Z0O.Z0O_PESO" + CRLF +;
                                   " , Z0O.Z0O_CMSPRE" + CRLF +;
                                   " , UltDiaPlanNut.Z0M_DESCRI" + CRLF +;
                                   " , UltDiaPlanNut.Z0M_PESO" + CRLF +;
                                   " , UltDiaPlanNut.MAIORDIAPL" + CRLF +;
                                   " , isnull(NotaCocho.Z0I_NOTMAN, '" + Space(TamSX3("Z0I_NOTMAN")[1]) + "') NOTA_MANHA" + CRLF +; //" , UltDiaPlanNut.Z0M_GMD" 
                                " from Lotes" + CRLF +;
                           " left join " + RetSqlName("Z0O") + " Z0O" + CRLF +;
                                  " on Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" + CRLF +;
                                 " and Z0O.Z0O_LOTE   = Lotes.B8_LOTECTL" + CRLF +;
                                 " and ('" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR or ( Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        ')) " + CRLF +;
                                 " --and Z0O.Z0O_CODPLA <> '999999' " + CRLF +;
                                 " and Z0O.D_E_L_E_T_ = ' '" + CRLF +;
                           " left join UltDiaPlanNut" + CRLF +;
                                  " on UltDiaPlanNut.Z0M_CODIGO = Z0O.Z0O_CODPLA" + CRLF +;
                                 " and UltDiaPlanNut.Z0M_CODIGO <> '999999' " + CRLF +;
                           " left join NotaCocho" + CRLF +;
                                  " on NotaCocho.Z0I_LOTE = Lotes.B8_LOTECTL" + CRLF +;
                           " left join InicTrato" + CRLF +;
                                  " on InicTrato.Z0O_LOTE = Lotes.B8_LOTECTL" + CRLF +;
                           " left join DiasPlano" + CRLF +;
                                  " on DiasPlano.Z0O_LOTE = Lotes.B8_LOTECTL" + CRLF +;
                           " order by Z08_CONFNA" + CRLF +; // ;//", Z08_LINHA" + CRLF +;
                                   ", Z08_CODIGO"

            if lDebug .and. lower(cUserName) $ 'mbernardo,atoshio,admin,administrador,rsantana'
                MemoWrite(cPath + FunName() + DtoS(dDataBase) + "_" + StrTran(SubS(Time(),1,5),":","") + "_CriaTrat.sql", cSql)
            endif

            if Select("LOTES") > 0
                LOTES->(DbCloseArea())
            endif

            DbUseArea(.T., "TOPCONN", TCGenQry(,,cSql),"LOTES", .F., .F.)

            while !LOTES->(Eof())
                CriaZ05()
                LOTES->(DbSkip())
            end
            LOTES->(DbCloseArea())
        endif
        
        RecLock("Z0R", .F.)
            Z0R->Z0R_LOCK   := "1"
        MsUnlock()

        if Type("oBrowse") == "O"
            oBrowse:SetDescription("Programação do Trato - " + DToC(Z0R->Z0R_DATA))
        endif

        EndTran()
        recover
            if FWinTTSBreak()
                DisarmTransaction()
            endif
        end sequence

    endif
    UnLockByName("CriaTrat" + DToS(Z0R->Z0R_DATA), .T., .T.)
endif

return nil


/*/{Protheus.doc} CriaZ05
Cria os registros de trato na Z05 e Z06 para o currap posicionado
@author jr.andre
@since 13/09/2019
@version 1.0
@return nil
@type function
/*/
static function CriaZ05()
local aChave     := {}
local cDtTrAnt   := ""
local cVerTrAnt  := ""
local nTotMS     := 0
local nTotMN     := 0
local cNroTrato  := ""
local cDieta     := ""
local nQtdTrato  := 0
local nQuantMN   := 0
local nTotTrtClc := 0
local cSeq       := ""
local nMegaCal   := 0
local nMCalTrat  := 0
local nTotMCal   := 0
local i          := 0
Local _nMCALPR   := 0

    // Verifica se não existe plano de trato associado ao lote 
    if Empty(LOTES->Z0O_CODPLA)
        // se existir trato anterior copiar
        if !Empty(aChave := MaxVerTrat(LOTES->B8_LOTECTL, Z0R->Z0R_DATA))
            cDtTrAnt := aChave[1]
            cVerTrAnt := aChave[2]
            DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                      " select *" +; 
                                        " from " + RetSqlName("Z05") + " Z05" +;
                                       " where Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" +;
                                         " and Z05.Z05_DATA   = '" + cDtTrAnt + "'" +;
                                         " and Z05.Z05_VERSAO = '" + cVerTrAnt + "'" +;
                                         " and Z05.Z05_LOTE   = '" + LOTES->B8_LOTECTL + "'" +;
                                         " and Z05.D_E_L_E_T_ = ' '";
                                                 ), "TMPZ05", .F., .F.)
            if !TMPZ05->(Eof())
                nTotMS    := 0
                nTotMN    := 0
                nTotMCal  := 0
                cNroTrato := ""
                cDieta    := ""

                // quando existir mais de uma dieta considerar a ultima para calculo do ajuste
                Z0G->(DbSeek(FWxFilial("Z0G")+PadR(AllTrim(Iif(','$TMPZ05->Z05_DIETA,SubStr(TMPZ05->Z05_DIETA,RAt(',', TMPZ05->Z05_DIETA)+1),TMPZ05->Z05_DIETA)),TamSX3("B1_COD")[1])+LOTES->NOTA_MANHA))

                DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                          " with QTDTRAT as (" +;
                                            " select Z06.Z06_FILIAL" +;
                                                   ", Z06.Z06_DATA" +;
                                                   ", Z06.Z06_VERSAO" +;
                                                   ", Z06.Z06_LOTE" +;
                                                   ", count(*) QTD" +;
                                             " from " + RetSqlName("Z06") + " Z06" +; 
                                            " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +; 
                                              " and Z06.Z06_DATA   = '" + cDtTrAnt + "'" +;
                                              " and Z06.Z06_VERSAO = '" + cVerTrAnt + "'" +;
                                              " and Z06.Z06_LOTE   = '" + LOTES->B8_LOTECTL + "'" +;
                                              " and Z06.D_E_L_E_T_ = ' '" +;
                                         " group by Z06.Z06_FILIAL, Z06.Z06_DATA, Z06.Z06_VERSAO, Z06.Z06_LOTE" +;
                                          " )" +;
                                           " select Z06.*, QTDTRAT.QTD" +; 
                                             " from " + RetSqlName("Z06") + " Z06" +;
                                             " join QTDTRAT" +;
                                               " on QTDTRAT.Z06_FILIAL = Z06.Z06_FILIAL" +;
                                              " and QTDTRAT.Z06_DATA   = Z06.Z06_DATA" +;
                                              " and QTDTRAT.Z06_VERSAO = Z06.Z06_VERSAO" +;
                                              " and QTDTRAT.Z06_LOTE   = Z06.Z06_LOTE" +;
                                            " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +; 
                                              " and Z06.Z06_DATA   = '" + cDtTrAnt + "'" +;
                                              " and Z06.Z06_VERSAO = '" + cVerTrAnt + "'" +;
                                              " and Z06.Z06_LOTE   = '" + LOTES->B8_LOTECTL + "'" +;
                                              " and Z06.D_E_L_E_T_ = ' '" +;
                                         " order by Z06.Z06_FILIAL" +;
                                                 ", Z06.Z06_DATA" +;
                                                 ", Z06.Z06_VERSAO" +;
                                                 ", Z06.Z06_LOTE" +;
                                                 ", Z06.Z06_TRATO " ;
                                                      ), "TMPZ06", .F., .F.)

                    /*05-08-2020 
                    Alteração Arthur Toshio
                    Ajuste do KG da matéria seca considerando o ganho de peso do animal
                    */ 
                    
                    
                    If GetMV("VA_AJUDAN") == "K" // Ajuste da nota de Cocho em KG (Z0G_AJSTKG)
                        nQtdTrato := NoRound((TMPZ05->Z05_KGMSDI+Z0G->Z0G_AJSTKG)/TMPZ06->QTD, TamSX3("Z06_KGMSTR")[2])
                    ElseIf GetMV("VA_AJUDAN") == "P" // Se Ajuste for em Percentual (Z0G_PERAJU)
                        nQtdTrato := NoRound((TMPZ05->Z05_KGMSDI+((TMPZ05->Z05_KGMSDI*Z0G->Z0G_PERAJU)/100))/TMPZ06->QTD, TamSX3("Z06_KGMSTR")[2])
                    EndIf
                    nQuantMN := u_CalcQtMN(TMPZ06->Z06_DIETA, nQtdTrato)
                                
                    while !TMPZ06->(Eof())
                        if (++i == TMPZ06->QTD)
                            If GetMV("VA_AJUDAN") == "K"
                                nQtdTrato := TMPZ05->Z05_KGMSDI + Z0G->Z0G_AJSTKG - nTotTrtClc
                            ElseIf GetMV("VA_AJUDAN") == "P" // Se Ajuste for em Percentual (Z0G_PERAJU)
                                nQtdTrato := TMPZ05->Z05_KGMSDI + ((TMPZ05->Z05_KGMSDI * Z0G->Z0G_PERAJU ) / 100) - nTotTrtClc
                            EndIf
                        endif
                        cSeq := GetSeq(TMPZ06->Z06_DIETA)
                        nMegaCal := GetMegaCal(TMPZ06->Z06_DIETA)
                        nMCalTrat := Round(nMegaCal * nQtdTrato,2)
                        
                        RecLock("Z06", .T.)
                            Z06->Z06_FILIAL := FWxFilial("Z06")
                            Z06->Z06_DATA   := Z0R->Z0R_DATA    
                            Z06->Z06_VERSAO := Z0R->Z0R_VERSAO
                            Z06->Z06_CURRAL := LOTES->Z08_CODIGO
                            Z06->Z06_LOTE   := LOTES->B8_LOTECTL  
                            Z06->Z06_TRATO  := TMPZ06->Z06_TRATO 
                            Z06->Z06_DIETA  := TMPZ06->Z06_DIETA 
                            Z06->Z06_KGMSTR := nQtdTrato
                            Z06->Z06_KGMNTR := nQuantMN
                            Z06->Z06_DIAPRO := LOTES->DIA_PLNUTRI
                            Z06->Z06_HORA   := TMPZ06->Z06_HORA
                            Z06->Z06_MEGCAL := nMcalTrat
                            Z06->Z06_KGMNT  := nQuantMN * LOTES->B8_SALDO
                            Z06->Z06_SEQ    := cSeq
                        MsUnlock()

                        nTotTrtClc += nQtdTrato
                        nTotMS += Z06->Z06_KGMSTR
                        nTotMCal += Z06->Z06_MEGCAL
                        nTotMN += Z06->Z06_KGMNTR
                        cNroTrato := Iif(cNroTrato < Z06->Z06_TRATO, Z06->Z06_TRATO, cNroTrato)
                        if !AllTrim(Z06->Z06_DIETA)$cDieta
                            cDieta += Iif(Empty(cDieta), "", ",") + AllTrim(Z06->Z06_DIETA)
                        endif

                        TMPZ06->(DbSkip())
                    end
                TMPZ06->(DbCloseArea())

                if !TMPZ05->(Eof())
                    cRoteiro := UlrRoteiro(Z0R->Z0R_DATA, Z0R->Z0R_VERSAO, LOTES->B8_LOTECTL, LOTES->Z08_CODIGO)
                    
                    // If AllTrim(LOTES->Z08_CODIGO) == "B08" .OR.;
                    //    AllTrim(LOTES->Z08_CODIGO) == "B14"
                    //     ConOut("BreakPoint")
                    // EndIf
                    
                    _nMCALPR := 0
                     DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                 _cSql := " SELECT distinct " + cValToChar( LOTES->Z0O_PESO ) +;
                                          " * G1_ENERG * (" + cValToChar( LOTES->Z0O_CMSPRE ) + "/100) AS MEGACAL"+CRLF+;
                                          " FROM SG1010 "+CRLF+;
                                          " WHERE G1_FILIAL = '" + xFilial('SG1') + "' "+CRLF+;
                                          "   AND G1_COD = '" + GetMV("VA_PCP07MC",,'FINAL') + "'"+CRLF+;
                                          "   AND D_E_L_E_T_ = ' '";
                                    ),"TMPmgCal", .F., .F.)
                    MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa05_Z05_MCALPR.SQL", _cSql)
                    if (!TMPmgCal->(Eof()))
                        _nMCALPR := TMPmgCal->MEGACAL
                    EndIf
                    TMPmgCal->(DbCloseArea())    

                    RecLock("Z05", .T.)
                        Z05->Z05_FILIAL := FWxFilial("Z05")
                        Z05->Z05_DATA   := Z0R->Z0R_DATA
                        Z05->Z05_VERSAO := Z0R->Z0R_VERSAO
                        Z05->Z05_CURRAL := LOTES->Z08_CODIGO
                        Z05->Z05_LOTE   := LOTES->B8_LOTECTL
                        Z05->Z05_CABECA := LOTES->B8_SALDO
                        Z05->Z05_ORIGEM := "2"
                        Z05->Z05_MANUAL := "2"
                        Z05->Z05_DIETA  := cDieta
                        Z05->Z05_DIASDI := LOTES->DIAS_COCHO // N 4,0 - Dias de cocho
                        Z05->Z05_DIAPRO := LOTES->DIA_PLNUTRI // C 3,0 - Dia do plano nutricional
                        Z05->Z05_ROTEIR := cRoteiro
                        Z05->Z05_KGMSDI := nTotMS
                        Z05->Z05_KGMNDI := nTotMN
                        Z05->Z05_NROTRA := Val(cNroTrato)
                        Z05->Z05_TOTMSC := nTotMS
                        Z05->Z05_TOTMNC := nTotMN
                        Z05->Z05_TOTMSI := 0
                        Z05->Z05_TOTMNI := 0
                        Z05->Z05_PESOCO := LOTES->B8_XPESOCO
                        Z05->Z05_PESMAT := LOTES->B8_XPESOCO + LOTES->DIAS_COCHO * LOTES->Z0O_GMD
                        Z05->Z05_CMSPN  := Iif(Z05->Z05_PESMAT == 0, 1, Z05->Z05_KGMSDI/Z05->Z05_PESMAT*100)
                        Z05->Z05_MEGCAL := nTotMCal 
                        Z05->Z05_MCALPR := _nMCALPR
                    MsUnlock()
                endif
            TMPZ05->(DbCloseArea())
            endif
        // se não existir a ação terá que ser manual
        endif

    else

        // Se o plano está nos dias anteriores ao último dia de trato
        if LOTES->DIAS_NO_PLANO <= LOTES->MAIORDIAPL
            // verifica se o trato será criado com base na quantidade de trato do ultimo dia + nota de cocho, mesmo nos casos onde exista o plano nutricional.
            if GetMV("VA_CRTRDAN",,.F.) .and. !Empty(aChave := MaxVerTrat(LOTES->B8_LOTECTL, Z0R->Z0R_DATA))

                DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                          " with QTDTRAT as (" +;
                                            " select Z0M.Z0M_CODIGO, Z0O.Z0O_LOTE, count(*) QTD" +;
                                              " from " + RetSqlName("Z0O") + " Z0O" +;
                                              " join " + RetSqlName("Z0M") + " Z0M" +;
                                                " on Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" +;
                                               " and Z0M.Z0M_CODIGO = Z0O.Z0O_CODPLA" +;
                                               " and Z0M.Z0M_VERSAO = (SELECT MAX(Z0M_VERSAO) FROM " + RetSqlName("Z0M") + " Z0MV WHERE Z0MV.Z0M_CODIGO = Z0M.Z0M_CODIGO AND Z0MV.D_E_L_E_T_ = ' ' )" +;
                                               " and Z0M.Z0M_DIA    = '" + LOTES->DIA_PLNUTRI + "'" +;
                                               " and Z0M.D_E_L_E_T_ = ' '" +;
                                             " where Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" +;
                                               " and Z0O.Z0O_LOTE   = '" + LOTES->B8_LOTECTL + "'" +;
                                               " and (('" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR) or (Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        '))" +;
                                               " and Z0O.D_E_L_E_T_ = ' '" +;
                                          " group by Z0M.Z0M_CODIGO, Z0O.Z0O_LOTE" +;
                                        " )" +;
                                        " select Z0O.*, Z0M.*, QTDTRAT.QTD, Z05.Z05_KGMSDI QTDTRATO" +;
                                          " from " + RetSqlName("Z0O") + " Z0O" +;
                                          " join " + RetSqlName("Z0M") + " Z0M" +;
                                            " on Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" +;
                                           " and Z0M.Z0M_CODIGO = Z0O.Z0O_CODPLA" +;
                                           " and Z0M.Z0M_VERSAO = (SELECT MAX(Z0M_VERSAO) FROM " + RetSqlName("Z0M") + " Z0M1 WHERE Z0M1.Z0M_FILIAL = Z0M.Z0M_FILIAL AND Z0M1.Z0M_CODIGO = Z0M.Z0M_CODIGO AND Z0M1.D_E_L_E_T_ = ' ' )" +;
                                           " and Z0M.Z0M_DIA    = '" + LOTES->DIA_PLNUTRI + "'" +;
                                           " and Z0M.D_E_L_E_T_ = ' '" +;
                                          " join QTDTRAT" +;
                                            " on Z0M.Z0M_CODIGO = QTDTRAT.Z0M_CODIGO" +;
                                           " and Z0O.Z0O_LOTE   = QTDTRAT.Z0O_LOTE" +;
                                          " join " + RetSqlName("Z05") + " Z05" +;
                                            " on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" +;
                                           " and Z05.Z05_DATA   = '" + aChave[1] + "'" +;
                                           " and Z05.Z05_VERSAO = '" + aChave[2] + "'" +;
                                           " and Z05.Z05_LOTE   = QTDTRAT.Z0O_LOTE" +;
                                           " and Z05.D_E_L_E_T_ = ' '" +;
                                         " where Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" +;
                                           " and Z0O.Z0O_LOTE   = '" + LOTES->B8_LOTECTL + "'" +;
                                           " and (('" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR) or (Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        '))" +;
                                           " and Z0O.D_E_L_E_T_ = ' '" +;
                                      " order by Z0M.Z0M_TRATO ";
                                                     ), "TMPZ0M", .F., .F.)

                    Z0G->(DbSeek(FWxFilial("Z0G")+TMPZ0M->Z0M_DIETA+LOTES->NOTA_MANHA))

                    nTotMS := 0
                    nTotMN := 0
                    nTotTrtClc := 0
                    nMegaCal := 0
                    nMCalTrat := 0
                    i := 0
                    If GetMV("VA_AJUDAN") == "K" // Ajuste da nota de Cocho em KG (Z0G_AJSTKG)
                        nQtdTrato := Noround((TMPZ0M->QTDTRATO+Z0G->Z0G_AJSTKG)/TMPZ0M->QTD, TamSX3("Z06_KGMSTR")[2])
                    ElseIf GetMV("VA_AJUDAN") == "P" // Se Ajuste for em Percentual (Z0G_PERAJU)
                        nQtdTrato := Noround((TMPZ0M->QTDTRATO+(TMPZ0M->QTDTRATO*Z0G->Z0G_PERAJU)/100)/TMPZ0M->QTD, TamSX3("Z06_KGMSTR")[2])
                    EndIf
                    cDieta := ""
                    cNroTrato := ""

                    while !TMPZ0M->(Eof())
                        // Remove o erro de arredontamento
                        if (++i == TMPZ0M->QTD)
                            If GetMV("VA_AJUDAN") == "K"
                                nQtdTrato := TMPZ0M->QTDTRATO + Z0G->Z0G_AJSTKG - nTotTrtClc
                            ElseIf GetMV("VA_AJUDAN") == "P" // Se Ajuste for em Percentual (Z0G_PERAJU)
                                nQtdTrato := TMPZ0M->QTDTRATO + ((TMPZ0M->QTDTRATO * Z0G->Z0G_PERAJU ) / 100) - nTotTrtClc
                            EndIf
                        endif
                        
                        nQuantMN := u_CalcQtMN(TMPZ0M->Z0M_DIETA, nQtdTrato)
                        cSeq := GetSeq(TMPZ0M->Z0M_DIETA)
                        nMegaCal := GetMegaCal(TMPZ0M->Z0M_DIETA)
                        nMCalTrat := Round(nMegaCal * nQtdTrato,2)

                        RecLock("Z06", .T.)
                            Z06->Z06_FILIAL := FWxFilial("Z06")
                            Z06->Z06_DATA   := Z0R->Z0R_DATA    
                            Z06->Z06_VERSAO := Z0R->Z0R_VERSAO
                            Z06->Z06_CURRAL := LOTES->Z08_CODIGO
                            Z06->Z06_LOTE   := LOTES->B8_LOTECTL  
                            Z06->Z06_TRATO  := TMPZ0M->Z0M_TRATO 
                            Z06->Z06_DIETA  := TMPZ0M->Z0M_DIETA 
                            Z06->Z06_KGMSTR := nQtdTrato
                            Z06->Z06_KGMNTR := nQuantMN 
                            Z06->Z06_DIAPRO := LOTES->DIA_PLNUTRI
                            Z06->Z06_SEQ    := cSeq
                            Z06->Z06_MEGCAL := nMCalTrat
                            Z06->Z06_KGMNT  := nQuantMN * LOTES->B8_SALDO
                        MsUnlock()
                    
                        nTotTrtClc += nQtdTrato
                        nTotMS += Z06->Z06_KGMSTR
                        nTotMCal += Z06->Z06_MEGCAL
                        nTotMN += Z06->Z06_KGMNTR
                        cNroTrato := Iif(cNroTrato < Z06->Z06_TRATO, Z06->Z06_TRATO, cNroTrato)
                        if !AllTrim(Z06->Z06_DIETA)$cDieta
                            cDieta += Iif(Empty(cDieta), "", ",") + AllTrim(Z06->Z06_DIETA) 
                        endif
                    
                        TMPZ0M->(DbSkip())
                    end
                
                TMPZ0M->(DbCloseArea())

                cRoteiro := UlrRoteiro(Z0R->Z0R_DATA, Z0R->Z0R_VERSAO, LOTES->B8_LOTECTL, LOTES->Z08_CODIGO)

                // If AllTrim(LOTES->Z08_CODIGO) == "B08" .OR.;
                //    AllTrim(LOTES->Z08_CODIGO) == "B14"
                //     ConOut("BreakPoint")
                // EndIf
                
                _nMCALPR := 0
                DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                            _cSql := " SELECT distinct " + cValToChar( LOTES->Z0O_PESO ) +;
                                    " * G1_ENERG * (" + cValToChar( LOTES->Z0O_CMSPRE ) + "/100) AS MEGACAL"+CRLF+;
                                    " FROM SG1010 "+CRLF+;
                                    " WHERE G1_FILIAL = '" + xFilial('SG1') + "' "+CRLF+;
                                    "   AND G1_COD = '" + GetMV("VA_PCP07MC",,'FINAL') + "'"+CRLF+;
                                    "   AND D_E_L_E_T_ = ' '";
                            ),"TMPmgCal", .F., .F.)
                MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa05_Z05_MCALPR.SQL", _cSql)
                if (!TMPmgCal->(Eof()))
                    _nMCALPR := TMPmgCal->MEGACAL
                EndIf
                TMPmgCal->(DbCloseArea())    

                RecLock("Z05", .T.)    
                    Z05->Z05_FILIAL := FWxFilial("Z05") 
                    Z05->Z05_DATA   := Z0R->Z0R_DATA  
                    Z05->Z05_VERSAO := Z0R->Z0R_VERSAO
                    Z05->Z05_CURRAL := LOTES->Z08_CODIGO
                    Z05->Z05_LOTE   := LOTES->B8_LOTECTL
                    Z05->Z05_CABECA := LOTES->B8_SALDO
                    Z05->Z05_ORIGEM := '1'
                    Z05->Z05_MANUAL := "2"
                    Z05->Z05_DIETA  := cDieta
                    Z05->Z05_DIASDI := LOTES->DIAS_COCHO // N 4,0 - Dias de cocho
                    Z05->Z05_DIAPRO := LOTES->DIA_PLNUTRI // C 3,0 - Dia do plano nutricional
                    Z05->Z05_ROTEIR := cRoteiro
                    Z05->Z05_KGMSDI := nTotMS
                    Z05->Z05_KGMNDI := nTotMN
                    Z05->Z05_NROTRA := Val(cNroTrato)
                    Z05->Z05_TOTMSC := nTotMS
                    Z05->Z05_TOTMNC := nTotMN
                    Z05->Z05_TOTMSI := 0
                    Z05->Z05_TOTMNI := 0
                    Z05->Z05_PESOCO := LOTES->B8_XPESOCO
                    Z05->Z05_PESMAT := LOTES->B8_XPESOCO + LOTES->DIAS_COCHO * LOTES->Z0O_GMD  
                    Z05->Z05_CMSPN  := Iif(Z05->Z05_PESMAT == 0, 1, Z05->Z05_KGMSDI/Z05->Z05_PESMAT*100)
                    Z05->Z05_MEGCAL := nTotMCal
                    Z05->Z05_MCALPR := _nMCALPR
                MsUnlock()

            else

                DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                          " with QTDTRAT as (" +;
                                            " select Z0M.Z0M_CODIGO, Z0O.Z0O_LOTE, count(*) QTD" +;
                                              " from " + RetSqlName("Z0O") + " Z0O" +;
                                              " join " + RetSqlName("Z0M") + " Z0M" +;
                                                " on Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" +;
                                               " and Z0M.Z0M_CODIGO = Z0O.Z0O_CODPLA" +;
                                               " and Z0M_VERSAO = (SELECT MAX(Z0M_VERSAO) FROM " + RetSqlName("Z0M") + " Z0MV WHERE Z0MV.Z0M_CODIGO = Z0M.Z0M_CODIGO AND Z0MV.D_E_L_E_T_ = ' ' )" +;
                                               " and Z0M.Z0M_DIA    = '" + LOTES->DIA_PLNUTRI + "'" +;
                                               " and Z0M.D_E_L_E_T_ = ' '" +;
                                             " where Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" +;
                                               " and Z0O.Z0O_LOTE   = '" + LOTES->B8_LOTECTL + "'" +;
                                               " and (('" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR) or (Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        '))" +;
                                               " and Z0O.D_E_L_E_T_ = ' '" +;
                                          " group by Z0M.Z0M_CODIGO, Z0O.Z0O_LOTE" +;
                                        " )" +;
                                        " select Z0O.*, Z0M.*, QTDTRAT.QTD" +;
                                          " from " + RetSqlName("Z0O") + " Z0O" +;
                                          " join " + RetSqlName("Z0M") + " Z0M" +;
                                            " on Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" +;
                                           " and Z0M.Z0M_CODIGO = Z0O.Z0O_CODPLA" +;
                                           " and Z0M_VERSAO = (SELECT MAX(Z0M_VERSAO) FROM " + RetSqlName("Z0M") + " Z0M1 WHERE Z0M1.Z0M_FILIAL = Z0M.Z0M_FILIAL AND Z0M1.Z0M_CODIGO = Z0M.Z0M_CODIGO AND Z0M1.D_E_L_E_T_ = ' ' )" +;
                                           " and Z0M.Z0M_DIA    = '" + LOTES->DIA_PLNUTRI + "'" +;
                                           " and Z0M.D_E_L_E_T_ = ' '" +;
                                          " join QTDTRAT" +;
                                            " on Z0M.Z0M_CODIGO = QTDTRAT.Z0M_CODIGO" +;
                                           " and Z0O.Z0O_LOTE   = QTDTRAT.Z0O_LOTE" +;
                                         " where Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" +;
                                           " and Z0O.Z0O_LOTE   = '" + LOTES->B8_LOTECTL + "'" +;
                                           " and (('" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR) or (Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        '))" +;
                                           " and Z0O.D_E_L_E_T_ = ' '" +;
                                      " order by Z0M.Z0M_TRATO ";
                                                      ), "TMPZ0M", .F., .F.)

                    Z0G->(DbSeek(FWxFilial("Z0G")+TMPZ0M->Z0M_DIETA+LOTES->NOTA_MANHA))

                    nTotMS := 0
                    nTotMCal := 0
                    nTotMN := 0
                    If GetMV("VA_AJUDAN") == "K" // Ajuste da nota de Cocho em KG (Z0G_AJSTKG)
                        nQtdTrato := NoRound((TMPZ0M->Z0M_QUANT+Z0G->Z0G_AJSTKG)/TMPZ0M->QTD, TamSX3("Z06_KGMSTR")[2])
                    ElseIf GetMV("VA_AJUDAN") == "P" // Se Ajuste for em Percentual (Z0G_PERAJU)
                        nQtdTrato := NoRound((TMPZ0M->Z0M_QUANT+((TMPZ0M->Z0M_QUANT*Z0G->Z0G_PERAJU)/100))/TMPZ0M->QTD, TamSX3("Z06_KGMSTR")[2])
                    EndIf

                    
                    cDieta := ""
                    cNroTrato := ""

                    while !TMPZ0M->(Eof())
                        nQuantMN := u_CalcQtMN(TMPZ0M->Z0M_DIETA, nQtdTrato)
                        cSeq := GetSeq(TMPZ0M->Z0M_DIETA)
                        nMegaCal := GetMegaCal(TMPZ0M->Z0M_DIETA)
                        nMCalTrat := Round(nMegaCal * nQtdTrato,2)

                        RecLock("Z06", .T.)
                            Z06->Z06_FILIAL := FWxFilial("Z06")
                            Z06->Z06_DATA   := Z0R->Z0R_DATA  
                            Z06->Z06_VERSAO := Z0R->Z0R_VERSAO
                            Z06->Z06_CURRAL := LOTES->Z08_CODIGO
                            Z06->Z06_LOTE   := LOTES->B8_LOTECTL  
                            Z06->Z06_TRATO  := TMPZ0M->Z0M_TRATO 
                            Z06->Z06_DIETA  := TMPZ0M->Z0M_DIETA 
                            Z06->Z06_KGMSTR := nQtdTrato
                            Z06->Z06_KGMNTR := nQuantMN 
                            Z06->Z06_DIAPRO := LOTES->DIA_PLNUTRI // C 3,0 - Dia do plano nutricional
                            Z06->Z06_SEQ    := cSeq
                            Z06->Z06_MEGCAL := nMCalTrat
                            Z06->Z06_KGMNT  := nQuantMN * LOTES->B8_SALDO
                        MsUnlock()
                    
                        nTotMS += Z06->Z06_KGMSTR
                        nTotMN += Z06->Z06_KGMNTR
                        nTotMCal += Z06->Z06_MEGCAL
                        cNroTrato := Iif(cNroTrato < Z06->Z06_TRATO, Z06->Z06_TRATO, cNroTrato)
                        if !AllTrim(Z06->Z06_DIETA)$cDieta
                            cDieta += Iif(Empty(cDieta), "", ",") + AllTrim(Z06->Z06_DIETA) 
                        endif
                    
                        TMPZ0M->(DbSkip())
                    end
                
                TMPZ0M->(DbCloseArea())

                cRoteiro := UlrRoteiro(Z0R->Z0R_DATA, Z0R->Z0R_VERSAO, LOTES->B8_LOTECTL, LOTES->Z08_CODIGO)

                // If AllTrim(LOTES->Z08_CODIGO) == "B08" .OR.;
                //    AllTrim(LOTES->Z08_CODIGO) == "B14"
                //     ConOut("BreakPoint")
                // EndIf
                
                _nMCALPR := 0
                DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                            _cSql := " SELECT distinct " + cValToChar( LOTES->Z0O_PESO ) +;
                                    " * G1_ENERG * (" + cValToChar( LOTES->Z0O_CMSPRE ) + "/100) AS MEGACAL"+CRLF+;
                                    " FROM SG1010 "+CRLF+;
                                    " WHERE G1_FILIAL = '" + xFilial('SG1') + "' "+CRLF+;
                                    "   AND G1_COD = '" + GetMV("VA_PCP07MC",,'FINAL') + "'"+CRLF+;
                                    "   AND D_E_L_E_T_ = ' '";
                            ),"TMPmgCal", .F., .F.)
                MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa05_Z05_MCALPR.SQL", _cSql)
                if (!TMPmgCal->(Eof()))
                    _nMCALPR := TMPmgCal->MEGACAL
                EndIf
                TMPmgCal->(DbCloseArea())    

                RecLock("Z05", .T.)
                    Z05->Z05_FILIAL := FWxFilial("Z05") 
                    Z05->Z05_DATA   := Z0R->Z0R_DATA
                    Z05->Z05_VERSAO := Z0R->Z0R_VERSAO
                    Z05->Z05_CURRAL := LOTES->Z08_CODIGO
                    Z05->Z05_LOTE   := LOTES->B8_LOTECTL
                    Z05->Z05_CABECA := LOTES->B8_SALDO
                    Z05->Z05_ORIGEM := '1'
                    Z05->Z05_MANUAL := "2"
                    Z05->Z05_DIETA  := cDieta
                    Z05->Z05_DIASDI := LOTES->DIAS_COCHO // N 4,0 - Dias de cocho
                    Z05->Z05_DIAPRO := LOTES->DIA_PLNUTRI // C 3,0 - Dia do plano nutricional
                    Z05->Z05_ROTEIR := cRoteiro
                    Z05->Z05_KGMSDI := nTotMS
                    Z05->Z05_KGMNDI := nTotMN
                    Z05->Z05_NROTRA := Val(cNroTrato)
                    Z05->Z05_TOTMSC := nTotMS
                    Z05->Z05_TOTMNC := nTotMN
                    Z05->Z05_TOTMSI := 0
                    Z05->Z05_TOTMNI := 0
                    Z05->Z05_PESOCO := LOTES->B8_XPESOCO
                    Z05->Z05_PESMAT := LOTES->B8_XPESOCO + LOTES->DIAS_COCHO * LOTES->Z0O_GMD  
                    Z05->Z05_CMSPN  := Iif(Z05->Z05_PESMAT == 0, 1, Z05->Z05_KGMSDI/Z05->Z05_PESMAT*100)
                    Z05->Z05_MEGCAL := nTotMCal
                    Z05->Z05_MCALPR := _nMCALPR
                MsUnlock()

            endif

        else // se o plano for posterior aos dias do trato
            
            if !Empty(aChave := MaxVerTrat(LOTES->B8_LOTECTL, Z0R->Z0R_DATA))
                cDtTrAnt := aChave[1]
                cVerTrAnt := aChave[2]
                
                       
                DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                    " select *" +; 
                      " from " + RetSqlName("Z05") + " Z05" +;
                     " where Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" +;
                       " and Z05.Z05_LOTE   = '" + LOTES->B8_LOTECTL + "'" +;
                       " and Z05.Z05_DATA   = '" + cDtTrAnt + "'" +;
                       " and Z05.Z05_VERSAO = '" + cVerTrAnt + "'" +;
                       " and Z05.D_E_L_E_T_ = ' '";
                                                     ), "TMPZ05", .F., .F.)
                

                if !TMPZ05->(Eof())
                
                    DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                              " with QTDTRAT as (" +;
                                                " select Z06.Z06_FILIAL, Z06.Z06_DATA, Z06.Z06_VERSAO, Z06.Z06_LOTE, count(*) QTD" +;
                                                 " from " + RetSqlName("Z06") + " Z06" +; 
                                                " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +; 
                                                  " and Z06.Z06_DATA   = '" + cDtTrAnt + "'" +;
                                                  " and Z06.Z06_VERSAO = '" + cVerTrAnt + "'" +;
                                                  " and Z06.Z06_LOTE   = '" + LOTES->B8_LOTECTL + "'" +;
                                                  " and Z06.D_E_L_E_T_ = ' '" +;
                                             " group by Z06.Z06_FILIAL, Z06.Z06_DATA, Z06.Z06_VERSAO, Z06.Z06_LOTE" +;
                                              " )" +;
                                               " select Z06.*, QTDTRAT.QTD" +; 
                                                 " from " + RetSqlName("Z06") + " Z06" +;
                                                 " join QTDTRAT" +;
                                                   " on QTDTRAT.Z06_FILIAL = Z06.Z06_FILIAL" +;
                                                  " and QTDTRAT.Z06_DATA   = Z06.Z06_DATA" +;
                                                  " and QTDTRAT.Z06_VERSAO = Z06.Z06_VERSAO" +;
                                                  " and QTDTRAT.Z06_LOTE   = Z06.Z06_LOTE" +;
                                                " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +; 
                                                  " and Z06.Z06_DATA   = '" + cDtTrAnt + "'" +;
                                                  " and Z06.Z06_VERSAO = '" + cVerTrAnt + "'" +;
                                                  " and Z06.Z06_LOTE   = '" + LOTES->B8_LOTECTL + "'" +;
                                                  " and Z06.D_E_L_E_T_ = ' '" +;
                                             " order by Z06.Z06_FILIAL" +;
                                                     ", Z06.Z06_DATA" +;
                                                     ", Z06.Z06_VERSAO" +;
                                                     ", Z06.Z06_LOTE" +;
                                                     ", Z06.Z06_TRATO " ;
                                                          ), "TMPZ06", .F., .F.)
                    
                        Z0G->(DbSeek(FWxFilial("Z0G")+TMPZ06->Z06_DIETA+LOTES->NOTA_MANHA))

                        nTotMS := 0
                        nTotMN := 0
                        cNroTrato := ""
                        cDieta := ""
                        
                        If GetMV("VA_AJUDAN") == "K" // Ajuste da nota de Cocho em KG (Z0G_AJSTKG)
                            nQtdTrato := NoRound((TMPZ05->Z05_KGMSDI+Z0G->Z0G_AJSTKG)/TMPZ06->QTD, TamSX3("Z06_KGMSTR")[2])
                        ElseIf GetMV("VA_AJUDAN") == "P" // Se Ajuste for em Percentual (Z0G_PERAJU)
                            nQtdTrato := NoRound((TMPZ05->Z05_KGMSDI+((TMPZ05->Z05_KGMSDI*Z0G->Z0G_PERAJU)/100))/TMPZ06->QTD, TamSX3("Z06_KGMSTR")[2])
                        EndIf
                        //nQtdTrato := NoRound((TMPZ05->Z05_KGMSDI+Z0G->Z0G_AJSTKG)/TMPZ06->QTD, TamSX3("Z06_KGMSTR")[2])
                        
                        while !TMPZ06->(Eof())
                            if (++i == TMPZ06->QTD)
                                If GetMV("VA_AJUDAN") == "K"
                                    nQtdTrato := TMPZ05->Z05_KGMSDI + Z0G->Z0G_AJSTKG - nTotTrtClc
                                ElseIf GetMV("VA_AJUDAN") == "P" // Se Ajuste for em Percentual (Z0G_PERAJU)
                                    nQtdTrato := TMPZ05->Z05_KGMSDI + ((TMPZ05->Z05_KGMSDI * Z0G->Z0G_PERAJU ) / 100) - nTotTrtClc
                                EndIf
                                //nQtdTrato := TMPZ05->Z05_KGMSDI + Z0G->Z0G_AJSTKG - nTotTrtClc
                            endif

                            nQuantMN := u_CalcQtMN(TMPZ06->Z06_DIETA, nQtdTrato)
                            cSeq := GetSeq(TMPZ06->Z06_DIETA)
                            nMegaCal := GetMegaCal(TMPZ06->Z06_DIETA)
                            nMCalTrat := Round(nMegaCal * nQtdTrato,2)

                            RecLock("Z06", .T.)
                                Z06->Z06_FILIAL := FWxFilial("Z06")
                                Z06->Z06_DATA   := Z0R->Z0R_DATA  
                                Z06->Z06_VERSAO := Z0R->Z0R_VERSAO
                                Z06->Z06_CURRAL := LOTES->Z08_CODIGO
                                Z06->Z06_LOTE   := LOTES->B8_LOTECTL  
                                Z06->Z06_TRATO  := TMPZ06->Z06_TRATO 
                                Z06->Z06_DIETA  := TMPZ06->Z06_DIETA 
                                Z06->Z06_KGMSTR := nQtdTrato
                                Z06->Z06_KGMNTR := nQuantMN
                                Z06->Z06_DIAPRO := LOTES->DIA_PLNUTRI
                                Z06->Z06_HORA   := TMPZ06->Z06_HORA  
                                Z06->Z06_SEQ    := cSeq
                                Z06->Z06_MEGCAL := nMCalTrat
                                Z06->Z06_KGMNT  := nQuantMN * LOTES->B8_SALDO
                            MsUnlock()
                
                            nTotTrtClc += nQtdTrato
                            nTotMS += Z06->Z06_KGMSTR
                            nTotMN += Z06->Z06_KGMNTR
                            nTotMCal += Z06_MEGCAL
                            cNroTrato := Iif(cNroTrato < Z06->Z06_TRATO, Z06->Z06_TRATO, cNroTrato)
                            if !AllTrim(Z06->Z06_DIETA)$cDieta
                                cDieta += Iif(Empty(cDieta), "", ",") + AllTrim(Z06->Z06_DIETA) 
                            endif
                    
                            TMPZ06->(DbSkip())
                        end
                    TMPZ06->(DbCloseArea())
                
                    if !TMPZ05->(Eof())
                        cRoteiro := UlrRoteiro(Z0R->Z0R_DATA, Z0R->Z0R_VERSAO, LOTES->B8_LOTECTL, LOTES->Z08_CODIGO)
                        
                        // If AllTrim(LOTES->Z08_CODIGO) == "B08" .OR.;
                        //    AllTrim(LOTES->Z08_CODIGO) == "B14"
                        //     ConOut("BreakPoint")
                        // EndIf
                        
                        _nMCALPR := 0
                        DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                    _cSql := " SELECT distinct " + cValToChar( LOTES->Z0O_PESO ) +;
                                            " * G1_ENERG * (" + cValToChar( LOTES->Z0O_CMSPRE ) + "/100) AS MEGACAL"+CRLF+;
                                            " FROM SG1010 "+CRLF+;
                                            " WHERE G1_FILIAL = '" + xFilial('SG1') + "' "+CRLF+;
                                            "   AND G1_COD = '" + GetMV("VA_PCP07MC",,'FINAL') + "'"+CRLF+;
                                            "   AND D_E_L_E_T_ = ' '";
                                        ),"TMPmgCal", .F., .F.)
                        MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa05_Z05_MCALPR.SQL", _cSql)
                        if (!TMPmgCal->(Eof()))
                            _nMCALPR := TMPmgCal->MEGACAL
                        EndIf
                        TMPmgCal->(DbCloseArea())    
                        
                        RecLock("Z05", .T.)
                            Z05->Z05_FILIAL := FWxFilial("Z05")
                            Z05->Z05_DATA   := Z0R->Z0R_DATA  
                            Z05->Z05_VERSAO := Z0R->Z0R_VERSAO 
                            Z05->Z05_CURRAL := LOTES->Z08_CODIGO
                            Z05->Z05_LOTE   := LOTES->B8_LOTECTL  
                            Z05->Z05_CABECA := LOTES->B8_SALDO
                            Z05->Z05_ORIGEM := "2"
                            Z05->Z05_MANUAL := "2"
                            Z05->Z05_DIETA  := cDieta 
                            Z05->Z05_DIASDI := LOTES->DIAS_COCHO // N 4,0 - Dias de cocho
                            Z05->Z05_DIAPRO := LOTES->DIA_PLNUTRI // C 3,0 - Dia do plano nutricional
                            Z05->Z05_ROTEIR := cRoteiro
                            Z05->Z05_KGMSDI := nTotMS
                            Z05->Z05_KGMNDI := nTotMN
                            Z05->Z05_NROTRA := Val(cNroTrato)
                            Z05->Z05_TOTMSC := nTotMS
                            Z05->Z05_TOTMNC := nTotMN
                            Z05->Z05_TOTMSI := 0
                            Z05->Z05_TOTMNI := 0
                            Z05->Z05_PESOCO := LOTES->B8_XPESOCO
                            Z05->Z05_PESMAT := LOTES->B8_XPESOCO + LOTES->DIAS_COCHO * LOTES->Z0O_GMD
                            Z05->Z05_CMSPN  := Iif(Z05->Z05_PESMAT == 0, 1, Z05->Z05_KGMSDI/Z05->Z05_PESMAT*100)
                            Z05->Z05_MEGCAL := nTotMCal
                            Z05->Z05_MCALPR := _nMCALPR
                        MsUnlock()
                    endif
                endif
                TMPZ05->(DbCloseArea())
            // se não existir quantidade anterior não é possivel calcular. tem que ser preechido manualmente.
            endif
        endif 
    endif

    FillEmpty()

return nil


/*/{Protheus.doc} FillEmpty
Preenche com quantidade 0 os tratos menores que o ultimo trato que não foram criados.
@author jr.andre
@since 17/09/2019
@version 1.0
@return nil
@type function
/*/
static function FillEmpty()
local nMaxTrato := u_GetNroTrato()
local i
local cSql      := ""

    for i := 1 to nMaxTrato
        cSql += Iif(Empty(cSql), "", ", ") + "('" + StrZero(i, 1) + "')"
    next
    cSql := "(values " + cSql + ") as TRT (TRATO)"

    DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                              " select *" +;
                                " from (" +;
                                  " select '" + FWxFilial("Z06") + "' Z06_FILIAL" +;
                                       " , '" + DToS(Z0R->Z0R_DATA) + "' Z06_DATA" +;
                                       " , '" + Z0R->Z0R_VERSAO + "' Z06_VERSAO" +;
                                       " , '" + Z05->Z05_CURRAL + "' Z06_CURRAL" +;
                                       " , '" + Z05->Z05_LOTE + "' Z06_LOTE" +;
                                       " , TRT.TRATO Z06_TRATO" +;
                                       " , (" +;
                                             " select substring(min(Z06_TRATO + Z06_DIETA), 2, " + AllTrim(Str(TamSX3("Z06_DIETA")[1] + 1)) + ")" +;
                                               " from " + RetSqlName("Z06") + " Z06" +;
                                              " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                                                " and Z06.Z06_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                                                " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                                                " and Z06.Z06_LOTE   = '" + Z05->Z05_LOTE + "'" +;
                                                " and Z06.Z06_TRATO  >= TRT.TRATO" +;
                                                " and Z06.D_E_L_E_T_ = ' '" +;
                                         " ) Z06_DIETA" +;
                                       " , 0 Z06_KGMSTR" +;
                                       " , 0 Z06_KGMNTR" +;
                                       " , (" +;
                                             " select min(Z06_DIAPRO)" +; 
                                               " from " + RetSqlName("Z06") + " Z06" +;
                                              " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                                                " and Z06.Z06_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                                                " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                                                " and Z06.Z06_LOTE   = '" + Z05->Z05_LOTE + "'" +;
                                                " and Z06.D_E_L_E_T_ = ' '" +;
                                         " ) Z06_DIAPRO" +;
                                       " , (" +;
                                             " select substring(min(Z06_TRATO + Z06_SEQ), 2, " + AllTrim(Str(TamSX3("Z06_SEQ")[1] + 1)) + ")" +;
                                               " from " + RetSqlName("Z06") + " Z06" +;
                                              " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                                                " and Z06.Z06_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                                                " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                                                " and Z06.Z06_LOTE   = '" + Z05->Z05_LOTE + "'" +;
                                                " and Z06.Z06_TRATO  >= TRT.TRATO" +;
                                                " and Z06.D_E_L_E_T_ = ' '" +;
                                         " ) Z06_SEQ" +;
                                    " from " + cSql +;
                               " left join " + RetSqlName("Z06") + " Z06" +;
                                      " on Z06.Z06_TRATO = TRT.TRATO" +;
                                     " and Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                                     " and Z06.Z06_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                                     " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                                     " and Z06.Z06_LOTE = '" + Z05->Z05_LOTE + "'" +;
                                     " and D_E_L_E_T_ = ' '" +;
                                   " where Z06.Z06_FILIAL is null" +;
                                     " ) DIETAS" +;
                               " where DIETAS.Z06_DIETA is not null" ;
                                         ), "TMPZ06", .T., .F.)
    TCSetField("TMPZ06", "Z06_DATA", "D")
    while !TMPZ06->(Eof())
        RecLock("Z06", .T.)
            Z06->Z06_FILIAL := TMPZ06->Z06_FILIAL
            Z06->Z06_DATA   := TMPZ06->Z06_DATA
            Z06->Z06_VERSAO := TMPZ06->Z06_VERSAO
            Z06->Z06_CURRAL := TMPZ06->Z06_CURRAL
            Z06->Z06_LOTE   := TMPZ06->Z06_LOTE
            Z06->Z06_TRATO  := TMPZ06->Z06_TRATO
            Z06->Z06_DIETA  := TMPZ06->Z06_DIETA
            Z06->Z06_KGMSTR := TMPZ06->Z06_KGMSTR
            Z06->Z06_KGMNTR := TMPZ06->Z06_KGMNTR
            Z06->Z06_KGMNT  := TMPZ06->Z06_KGMNTR * Z05->Z05_CABECA
            Z06->Z06_DIAPRO := TMPZ06->Z06_DIAPRO
            Z06->Z06_SEQ    := TMPZ06->Z06_SEQ
            //Z06->Z06_KGMNT  := nQuantMN * LOTES->B8_SALDO
        MsUnlock()
        TMPZ06->(DbSkip())
    end
    TMPZ06->(DbCloseArea())

return nil


/*/{Protheus.doc} LoadTrat
Lista os dados do trato e carrega na tabela temporária do browse.
@author jr.andre
@since 25/04/2019
@version 1.0
@return nil
@param dDtTrato, date, descricao
@type function
/*/
static function LoadTrat(dDtTrato)
local cSql       := ""
local i, nQtdTr  := u_GetNroTrato()
local cInsertCab := ""
local cSelectCab := ""
local cKgMnTot   := ""

cInsertCab := " Z08_CODIGO" +;              // COCHO
             ", Z0T_ROTA" +;                // ROTA
             ", Z0S_EQUIP" +;               // CAMINHAO 
             ", ZV0_DESC" +;                // DESCRIÇÃO DO CAMINHAO
             ", B8_LOTECTL" +;              // LOTE
             ", Z05_PESMAT" +;              // PESO MED AUAL
             ", CMS_PV" +;                  // Consumo de materia seca por peso
             ", Z05_MEGCAL" +;              // Mega Caloria
             ", B8_SALDO" +;                // SALDO
             ", Z05_DIASDI" +;              // Dias de Cocho
             ", NOTA_MANHA" +;              // NOTAS DE COCHO
             ", NOTA_MADRU" +;              // NOTAS DE COCHO
             ", NOTA_NOITE" +;              // NOTAS DE COCHO
             ", PROGANTMS" +;               // PROGRAMAÇÃO ANTERIOR - KG de MS / Cabeça       
             ", PROG_MS" +;                 // PROGRAMAÇÃO DE TRATO - KG de MS / Cabeça
             ", NR_TRATOS" +;               // Qtde Tratos
             ", PROGANTMN" +;               // PROGRAMAÇÃO ANTERIOR - KG de MS / Cabeça       
             ", PROG_MN" +;                 // PROGRAMAÇÃO DE TRATO - KG de MN / Cabeça
             ", QTDTRATO"

cSelectCab := " CURRAIS.Z08_CODIGO CODIGO" +;                                                 // COCHO
             ", isnull(ROTAS.Z0T_ROTA, '" + Space(TamSX3("Z0T_ROTA")[1]) + "') Z0T_ROTA" +;   // ROTA
             ", isnull(ROTAS.Z0S_EQUIP, '" + Space(TamSX3("Z0S_EQUIP")[1]) + "') Z0S_EQUIP" +; // Caminhão 
             ", isnull(ROTAS.ZV0_DESC, '" + Space(TamSX3("ZV0_DESC")[1]) + "') ZV0_DESC" +; // Descrição do Caminhão
             ", isnull(Z05.Z05_LOTE, isnull(CURRAIS.B8_LOTECTL,'" + Space(TamSX3("B8_LOTECTL")[1]) + "')) LOTE" +;  // LOTE
             ", isnull(Z05.Z05_PESMAT, (CURRAIS.B8_XPESOCO)+(isnull(Z0O_GMD, 0)* (DATEDIFF(D,CURRAIS.B8_XDATACO,'" + DtoS(dDtTrato) + "')+1))) Z05_PESMAT" +; // Peso Médio Atual
             ", isnull(Z05.Z05_KGMSDI, 0)/case isnull(CURRAIS.B8_XPESOCO, 0) + isnull(Z05.Z05_DIASDI,0) * isnull(Z0O_GMD, 0) when 0 then 1 else isnull(CURRAIS.B8_XPESOCO, 0) + isnull(Z05.Z05_DIASDI,0) * isnull(Z0O_GMD, 0) end * 100 CMS_PV " +; // Consumo de materia seca por peso
             ", isnull(Z05.Z05_MEGCAL, 0) Z05_MEGCAL" +;
             ", isnull(CURRAIS.B8_SALDO,0) SALDO" +;                                          // SALDO
             ", isnull(Z05.Z05_DIASDI, DATEDIFF(D,CURRAIS.B8_XDATACO,'" + DtoS(dDtTrato) + "')+1) DIA_COCHO" +; // Dias de Cocho
             ", isnull(NOTA_MANHA.Z0I_NOTMAN,'" + Space(TamSX3("Z0I_NOTMAN")[1]) + "') NOTA_MANHA" +; // NOTAS DE COCHO
             ", isnull(NOTA_MANHA.Z0I_NOTNOI,'" + Space(TamSX3("Z0I_NOTNOI")[1]) + "') NOTA_MADRU" +; // NOTAS DE COCHO
             ", isnull(NOTA_MANHA.Z0I_NOTTAR,'" + Space(TamSX3("Z0I_NOTTAR")[1]) + "') NOTA_NOITE" +; // NOTAS DE COCHO
             ", isnull(Z05ANT.Z05_KGMSDI,0) MS_D1" +; // PROGRAMAÇÃO ANTERIOR - KG de MS / Cabeça 
             ", isnull(Z05.Z05_KGMSDI,0) MS" +; // PROGRAMAÇÃO DE TRATO - KG de MS / Cabeça
             ", isnull(TRATOS.QTDE_TRATOS,0) QTDE_TRATOS" +; // Qtde Tratos
             ", isnull(Z05ANT.Z05_KGMNDI,0) MN_D1" +; // PROGRAMAÇÃO ANTERIOR - KG de MS / Cabeça 
             ", isnull(Z05.Z05_KGMNDI,0) MN" +; // PROGRAMAÇÃO DE TRATO - KG de MN / Cabeça
             ", isnull(REPETE.QTDTRATO, 0) QTDTRATO"

for i := 1 to nQtdTr
    cInsertCab += ", Z06_DIETA" + StrZero(i, 1) + ", Z06_KGMS" + StrZero(i, 1) + ", Z06_KGMN" + StrZero(i, 1)

    cSelectCab += ", isnull(DI" + StrZero(i, 1) + ", '" + Space(TamSX3("B1_COD")[1]) + "') DI" + StrZero(i, 1) +;
                  ", isnull(MS" + StrZero(i, 1) + ", 0) MS" + StrZero(i, 1) +;
                  ", isnull(MN" + StrZero(i, 1) + ", 0) MN" + StrZero(i, 1) 
    if !Empty(cKgMnTot)
        cKgMnTot  +=  " + (isnull(MN" + StrZero(i, 1) + ", 0) *  isnull(B8_SALDO,0))" 
    Else
        cKgMnTot  +=  ", ((isnull(MN" + StrZero(i, 1) + ", 0) *  isnull(B8_SALDO,0))" 
    EndIf
next
cInsertCab += ", Z05_MNTOT" 

cKgMnTot += ") AS Z05_MNTOT"    
cSelectCab += cKgMnTot
DbSelectArea("Z0R")
DbSetOrder(1) // Z0R_FILIAL+DTOS(Z0R_DATA)
if Z0R->(DbSeek(FWxFilial("Z0R")+DToS(dDtTrato)))

    //-----------------------------------------------
    //Monta a query que carrega os dados dos lotes de 
    //acordo com os parâmetros passados
    //-----------------------------------------------
    TCSqlExec( "delete from " + oTmpZ06:GetRealName() )
    cSql := " with" + CRLF +; 
            " CURRAIS as (" + CRLF +;
                    " select Z08.Z08_FILIAL" + CRLF +;
                         " , Z08.Z08_CONFNA" + CRLF +;
                         " , Z08.Z08_SEQUEN" + CRLF +;
                         " , Z08.Z08_CODIGO" + CRLF +;
                         " , SB8.B8_LOTECTL" + CRLF +;
                         " , sum(B8_XPESOCO*B8_SALDO)/sum(B8_SALDO) B8_XPESOCO" + CRLF +; 
                         " , sum(B8_SALDO) B8_SALDO" + CRLF +;
                         " , min(B8_XDATACO) B8_XDATACO" + CRLF +;
                      " from " + RetSqlName("Z08") + " Z08" + CRLF +;
                      " join " + RetSqlName("SB8") + " SB8" + CRLF +;
                        " on SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" + CRLF +;
                       " and SB8.B8_X_CURRA = Z08.Z08_CODIGO" + CRLF +;
                       " and SB8.B8_SALDO   <> 0" + CRLF +;
                       " and SB8.D_E_L_E_T_ = ' '" + CRLF +;
                     " where Z08.Z08_FILIAL = '" + FWxFilial("Z08") + "'" + CRLF +;
                       " and Z08.Z08_CONFNA <> '  '" + CRLF +;
                       " and Z08.D_E_L_E_T_ = ' '" + CRLF +;
                  " group by Z08.Z08_FILIAL" + CRLF +;
                         " , Z08.Z08_CONFNA" + CRLF +;
                         " , Z08.Z08_SEQUEN" + CRLF +;
                         " , Z08.Z08_CODIGO" + CRLF +;
                         " , SB8.B8_LOTECTL" + CRLF +;
                     " union all" + CRLF +;
                    " select Z08.Z08_FILIAL" + CRLF +;
                         " , Z08.Z08_CONFNA" + CRLF +;
                         " , Z08.Z08_SEQUEN" + CRLF +;
                         " , Z08.Z08_CODIGO" + CRLF +;
                         " , SB8.B8_LOTECTL" + CRLF +;
                         " , sum(B8_XPESOCO*B8_SALDO)/sum(B8_SALDO) B8_XPESOCO" + CRLF +; 
                         " , sum(B8_SALDO) B8_SALDO" + CRLF +;
                         " , min(B8_XDATACO) B8_XDATACO" + CRLF +;
                      " from " + RetSqlName("Z08") + " Z08" + CRLF +;
                      " join " + RetSqlName("Z05") + " Z05" +;
                        " on Z05.Z05_FILIAL = '" +  FWxFilial("Z05") + "'" + CRLF +;
                       " and Z05.Z05_CURRAL = Z08.Z08_CODIGO" + CRLF +;
                       " and Z05.Z05_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                       " and Z05.D_E_L_E_T_ = ' '" + CRLF +;
                 " left join " + RetSqlName("SB8") + " SB8" + CRLF +;
                        " on SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" + CRLF +;
                       " and SB8.B8_X_CURRA = Z08.Z08_CODIGO" + CRLF +;
                       " and SB8.B8_SALDO   <> 0" + CRLF +;
                       " and SB8.D_E_L_E_T_ = ' '" + CRLF +;
                     " where Z08.Z08_FILIAL = '" + FWxFilial("Z08") + "'" + CRLF +;
                       " and Z08.Z08_CONFNA <> '  '" + CRLF +;
                       " and Z08.Z08_MSBLQL <> '1'" + CRLF +;
                       " and Z08.D_E_L_E_T_ = ' '" + CRLF +;
                       " and SB8.B8_LOTECTL is null" + CRLF +;
                  " group by Z08.Z08_FILIAL" + CRLF +;
                         " , Z08.Z08_CONFNA" + CRLF +;
                         " , Z08.Z08_SEQUEN" + CRLF +;
                         " , Z08.Z08_CODIGO" + CRLF +; 
                         " , SB8.B8_LOTECTL" + CRLF +;
            " )" + CRLF
    cSql += ", TRATOS as (" + CRLF +;
                    " select Z06.Z06_LOTE" + CRLF +;
                         " , count(Z06_FILIAL) QTDE_TRATOS" + CRLF +;
                      " from " + RetSqlName("Z06") + " Z06" + CRLF +;
                     " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" + CRLF +;
                       " and Z06.Z06_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                       " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" + CRLF +;
                       " and Z06.D_E_L_E_T_ = ' '" + CRLF +;
                  " group by Z06.Z06_LOTE" + CRLF +;
            " )" + CRLF
    cSql += ", DIETA as (" + CRLF +;
                    " select MS.Z06_LOTE" + CRLF +;
                          ", DI1, MS1, MN1" + CRLF +;
                          ", DI2, MS2, MN2" + CRLF +;
                          ", DI3, MS3, MN3" + CRLF +;
                          ", DI4, MS4, MN4" + CRLF +;
                          ", DI5, MS5, MN5" + CRLF +;
                          ", DI6, MS6, MN6" + CRLF +;
                          ", DI7, MS7, MN7" + CRLF +;
                          ", DI8, MS8, MN8" + CRLF +;
                          ", DI9, MS9, MN9" + CRLF +;
                      " from (" + CRLF +;
                           " select PVT.Z06_LOTE, PVT.[1] MS1, PVT.[2] MS2, PVT.[3] MS3, PVT.[4] MS4" + CRLF +;
                                 ", PVT.[5] MS5, PVT.[6] MS6, PVT.[7] MS7, PVT.[8] MS8, PVT.[9] MS9" + CRLF +;
                             " from (" + CRLF +;
                                  " select Z06.Z06_LOTE, Z06.Z06_TRATO, Z06.Z06_KGMSTR" + CRLF +;
                                    " from " + RetSqlName("Z06") + " Z06" + CRLF +;
                                   " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" + CRLF +;
                                     " and Z06.Z06_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                                     " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" + CRLF +;
                                     " and Z06.D_E_L_E_T_ = ' '" + CRLF +;
                                  " ) as DADOS" + CRLF +;
                            " pivot (" + CRLF +;
                                    " sum(Z06_KGMSTR)" + CRLF +;
                                    " for Z06_TRATO in ([1], [2], [3], [4], [5], [6], [7], [8], [9])" + CRLF +;
                                  " ) as PVT" + CRLF +;
                           " ) MS" + CRLF +;
                      " join (" + CRLF +;
                           " select PVT.Z06_LOTE, PVT.[1] MN1, PVT.[2] MN2, PVT.[3] MN3, PVT.[4] MN4" + CRLF +;
                                 ", PVT.[5] MN5, PVT.[6] MN6, PVT.[7] MN7, PVT.[8] MN8, PVT.[9] MN9" + CRLF +;
                             " from (" + CRLF +;
                                  " select Z06.Z06_LOTE, Z06.Z06_TRATO, Z06.Z06_KGMNTR" + CRLF +;
                                    " from " + RetSqlName("Z06") + " Z06" + CRLF +;
                                   " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" + CRLF +;
                                     " and Z06.Z06_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                                     " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" + CRLF +;
                                     " and Z06.D_E_L_E_T_ = ' '" + CRLF +;
                                  " ) as DADOS" + CRLF +;
                            " pivot (" + CRLF +;
                                    " sum(Z06_KGMNTR)" + CRLF +;
                                    " for Z06_TRATO in ([1], [2], [3], [4], [5], [6], [7], [8], [9])" + CRLF +;
                                  " ) as PVT" + CRLF +;
                           " ) MN" + CRLF +;
                        " on MN.Z06_LOTE = MS.Z06_LOTE" + CRLF +;
                      " join (" + CRLF +;
                           " select PVT.Z06_LOTE, PVT.[1] DI1, PVT.[2] DI2, PVT.[3] DI3, PVT.[4] DI4" + CRLF +;
                                 ", PVT.[5] DI5, PVT.[6] DI6, PVT.[7] DI7, PVT.[8] DI8, PVT.[9] DI9" + CRLF +;
                             " from (" + CRLF +;
                                  " select Z06.Z06_LOTE, Z06.Z06_TRATO, Z06.Z06_DIETA" + CRLF +;
                                    " from " + RetSqlName("Z06") + " Z06" + CRLF +;
                                   " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" + CRLF +;
                                     " and Z06.Z06_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                                     " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" + CRLF +;
                                     " and Z06.D_E_L_E_T_ = ' '" + CRLF +;
                                  " ) as DADOS" + CRLF +;
                            " pivot (" + CRLF +;
                                    " min(Z06_DIETA)" + CRLF +;
                                    " for Z06_TRATO in ([1], [2], [3], [4], [5], [6], [7], [8], [9])" + CRLF +;
                                  " ) as PVT" + CRLF +;
                           " ) DIETA" + CRLF +;
                        " on DIETA.Z06_LOTE = MS.Z06_LOTE" + CRLF +;
            " )" + CRLF
    cSql += ", NOTA_MANHA as (" + CRLF +;
                    " select Z0I.Z0I_LOTE" + CRLF +;
                          ", Z0I.Z0I_NOTMAN" + CRLF +;
                          ", Z0I.Z0I_NOTNOI" + CRLF +;
                          ", Z0I.Z0I_NOTTAR" + CRLF +;
                      " from " + RetSqlName("Z0I") + " Z0I" + CRLF +;
                     " where Z0I.Z0I_FILIAL = '" + FWxFilial("Z0I") + "'" + CRLF +;
                       " and Z0I.Z0I_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                       " and Z0I.D_E_L_E_T_ = ' '" + CRLF +;
            " )" + CRLF
    cSql += ", ROTAS as (" + CRLF +;
                    " select Z0T.Z0T_CONF" + CRLF +;
                          ", Z0T.Z0T_SEQUEN" + CRLF +;
                          ", Z0T.Z0T_CURRAL" + CRLF +;
                          ", Z0T.Z0T_LOTE" + CRLF +;
                          ", Z0T.Z0T_ROTA" + CRLF +;
                          ", isnull(Z0S.Z0S_EQUIP,'" + Space(TamSX3("Z0S_EQUIP")[1]) + "') Z0S_EQUIP" + CRLF +;
                          ", isnull(ZV0.ZV0_DESC,'" + Space(TamSX3("ZV0_DESC")[1]) + "') ZV0_DESC" + CRLF +;
                      " from " + RetSqlName("Z0T") + " Z0T" + CRLF +;
                 " left join " + RetSqlName("Z0S") + " Z0S" + CRLF +;
                        " on Z0S.Z0S_FILIAL = '" + FWxFilial("Z0S") + "'" + CRLF +;
                       " and Z0S.Z0S_DATA   = Z0T.Z0T_DATA" + CRLF +;
                       " and Z0S.Z0S_VERSAO = Z0T.Z0T_VERSAO" + CRLF +;
                       " and Z0S.Z0S_ROTA   = Z0T.Z0T_ROTA" + CRLF +;
                       " and Z0S.D_E_L_E_T_ = ' '" + CRLF +;
                 " left join " + RetSqlName("ZV0") + " ZV0" + CRLF +;
                        " on ZV0.ZV0_FILIAL = '" + FWxFilial("ZV0") + "'" + CRLF +;
                       " and ZV0.ZV0_CODIGO = Z0S.Z0S_EQUIP" + CRLF +;
                       " and ZV0.D_E_L_E_T_ = ' '" + CRLF +;
                     " where Z0T.Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" + CRLF +;
                       " and Z0T.Z0T_DATA + Z0T.Z0T_VERSAO = (" + CRLF +;
                           " select max(MAXVER) MAXVER" + CRLF +;
                             " from (" + CRLF +;
                                  " select Z0T.Z0T_DATA + Z0T.Z0T_VERSAO MAXVER" + CRLF +;
                                    " from " + RetSqlName("Z0T") + " Z0T" + CRLF +;
                                   " where Z0T.Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" + CRLF +;
                                     " and Z0T.Z0T_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                                     " and Z0T.Z0T_VERSAO = '" + Z0R->Z0R_VERSAO + "'" + CRLF +;
                                     " and Z0T.D_E_L_E_T_ = ' '" + CRLF +;
                                   " union all" + CRLF +;
                                  " select max(Z0T.Z0T_DATA + Z0T.Z0T_VERSAO)" + CRLF +;
                                    " from " + RetSqlName("Z0T") + " Z0T" + CRLF +;
                                   " where Z0T.Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" + CRLF +;
                                     " and Z0T.Z0T_DATA + Z0T.Z0T_VERSAO <= '" + DToS(Z0R->Z0R_DATA) + Z0R->Z0R_VERSAO + "'" + CRLF +;
                                     " and Z0T.D_E_L_E_T_ = ' '" + CRLF +;
                                  " ) ROTA" + CRLF +;
                           " )" + CRLF +;
                       " and Z0T.D_E_L_E_T_ = ' '" + CRLF +;
            " )" + CRLF
    cSql += ", REPETE as (" + CRLF +;
                    " select QTT.Z05_LOTE" + CRLF +;
                          ", max(QTT.QTDTRATO) QTDTRATO" + CRLF +;
                      " from (" + CRLF +;
                            " select Z05.Z05_LOTE" + CRLF +;
                                  ", Z05.Z05_KGMSDI" + CRLF +;
                                  ", count(*) QTDTRATO" + CRLF +;
                             " from " + RetSqlName("Z05") + " Z05" + CRLF +;
                            " where Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" + CRLF +;
                              " and Z05.Z05_DATA   > '" + DToS(Z0R->Z0R_DATA - GetMV("VA_TRTCNHG",,3)) + "'" + CRLF +;
                              " and Z05.D_E_L_E_T_ = ' '" + CRLF +;
                         " group by Z05.Z05_LOTE, Z05.Z05_KGMSDI" + CRLF +;
                           " ) QTT" + CRLF +;
                  " group by QTT.Z05_LOTE" + CRLF +;
            " )" + CRLF
    cSql += "  insert into " + oTmpZ06:GetRealName() + "(" + CRLF+; 
                cInsertCab + CRLF +;
            " )" + CRLF +;           
            " select " + CRLF +;
                cSelectCab + CRLF +;
              " from CURRAIS" + CRLF +;
         " left join " + RetSqlName("Z05") + " Z05" + CRLF +;
                " on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" + CRLF +;
               " and Z05.Z05_CURRAL = CURRAIS.Z08_CODIGO" + CRLF+; 
               " and Z05.Z05_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
               " and Z05.Z05_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
               " and Z05.D_E_L_E_T_ = ' '" + CRLF +;
         " left join " + RetSqlName("Z05") + " Z05ANT" + CRLF +;
                " on Z05ANT.Z05_FILIAL = '" + FWxFilial("Z05") + "'" + CRLF +;
               " and Z05ANT.Z05_LOTE   = Z05.Z05_LOTE" + CRLF+; 
               " and Z05ANT.Z05_DATA   = '" + DToS(Z0R->Z0R_DATA-1) + "'" + CRLF +;
               " and Z05ANT.Z05_VERSAO    = (" + CRLF  +;
                   " select Z0R_VERSAO " + CRLF  +;
                     " from " + RetSqlName("Z0R") + " Z0R" + CRLF  +;
                    " where Z0R.Z0R_FILIAL = Z05ANT.Z05_FILIAL" + CRLF  +;
                      " and Z0R.Z0R_DATA   = '" + DToS(Z0R->Z0R_DATA-1) + "'" + CRLF +;
                      " and Z0R.D_E_L_E_T_ = ' '" + CRLF +;
                   " )" + CRLF  +;
               " and Z05ANT.D_E_L_E_T_ = ' '" + CRLF +;
         " left join " + RetSqlName("Z0O") + " Z0O" + CRLF +;
                " on Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" + CRLF +;
               " and Z0O.Z0O_LOTE   = Z05.Z05_LOTE" + CRLF +;
               " and (" + CRLF +;
                      " '" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR" + CRLF +;
                   " or (Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        ')" + CRLF +;
                   " )" + CRLF +;
              " and Z0O.D_E_L_E_T_ = ' '" + CRLF +;
        " left join TRATOS" + CRLF +;
               " on TRATOS.Z06_LOTE = Z05.Z05_LOTE" + CRLF +;
        " left join DIETA" + CRLF +;
               " on DIETA.Z06_LOTE = Z05.Z05_LOTE" + CRLF +;
        " left join NOTA_MANHA" + CRLF +;
               " on NOTA_MANHA.Z0I_LOTE = Z05.Z05_LOTE" + CRLF +;
        " left join ROTAS" + CRLF +;
              "on ROTAS.Z0T_LOTE = CURRAIS.B8_LOTECTL " + CRLF +;
        " left join REPETE" + CRLF +;
               " on REPETE.Z05_LOTE = Z05.Z05_LOTE" + CRLF +;
         " order by CODIGO"

    if lDebug .and. lower(cUserName) $ 'mbernardo,atoshio,admin,administrador,rsantana'
        MemoWrite(cPath + "LoadTrat" + DtoS(dDataBase) + "_" + StrTran(SubS(Time(),1,5),":","") + ".sql", cSql)
    endif

    if TCSqlExec(cSql) < 0
        Help(/*Descontinuado*/,/*Descontinuado*/,"SELEÇÃO DE TRATO",/**/,"Ocorreu um problema ao carregar o trato de " + DToC(mv_par01) + "." + CRLF + TCSQLError(), 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, entre em contato com o TI para averiguar o problema." })
        LogTrato("Erro durante carregamento do trato", "Ocorreu um problema ao carregar o trato de " + DToC(mv_par01) + "." + CRLF + TCSQLError())
        if lDebug .and. lower(cUserName) $ 'mbernardo,atoshio,admin,administrador,rsantana'
            MemoWrite(cPath + "TRATO_" + DToS(Z0R->Z0R_DATA) + ".log", DToS(Date()) + "-" + Time() + CRLF + "Ocorreu um problema ao carregar o trato de " + DToC(Z0R->Z0R_DATA) + "." + CRLF + TCSQLError())
        endif
    endif
    
    if Type("oBrowse") <> 'U'
        oBrowse:ChangeTopBot(.T.)
        oBrowse:SetDescription("Programação do Trato - " + DToC(Z0R->Z0R_DATA))
        oBrowse:Refresh()
    endif

endif

return nil


/*/{Protheus.doc} 'MenuDef'
Detalhamento dos menus da rotina
@author jr.andre
@since 25/04/2019
@version 1.0
@return aRotina, matriz contendo os detalhes dos menus.
@type function
/*/
static function MenuDef()
local aRotina := {} 

    ADD OPTION aRotina TITLE OemToAnsi("Visualizar")          ACTION "u_vap05man" OPERATION 2 ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE OemToAnsi("Trato <F12>")         ACTION "u_vap05cri" OPERATION 3 ACCESS 0 // "Copiar" 
    ADD OPTION aRotina TITLE OemToAnsi("Recarrega <F11>")     ACTION "u_vap05rec" OPERATION 3 ACCESS 0 // "Copiar" 
    ADD OPTION aRotina TITLE OemToAnsi("Recria <F5>")         ACTION "u_vap05rcr" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Manutenção <F6>")     ACTION "u_vap05man" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Gerar Arquivos <F7>") ACTION "u_vap05arq" OPERATION 2 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Nro Tratos <F8>")     ACTION "u_vap05tra" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Matéria Seca <F9>")   ACTION "u_vap05msc" OPERATION 4 ACCESS 0 // "Alterar" 
    ADD OPTION aRotina TITLE OemToAnsi("Dietas <F10>")        ACTION "u_vap05trt" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Incluir")             ACTION "u_vap05nov" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Excluir")             ACTION "u_vap05rem" OPERATION 5 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Transf. Curral")      ACTION "u_vap05tcu" OPERATION 4 ACCESS 0 // "Alterar"

return aRotina


/*/{Protheus.doc} vap05man
Faz a chamada do viewdef trazendo apenas os botões Confirmar e Fechar
@author jr.andre
@since 25/04/2019
@version 1.0
@return Nil
@param cAlias, characters, descricao
@param nReg, numeric, descricao
@param nOpc, numeric, descricao
@type function
/*/
user function vap05man(cAlias, nReg, nOpc)
local aArea   := GetArea()
local aEnButt := {{.F., nil},;      // 1 - Copiar
                  {.F., nil},;      // 2 - Recortar
                  {.F., nil},;      // 3 - Colar
                  {.F., nil},;      // 4 - Calculadora
                  {.F., nil},;      // 5 - Spool
                  {.F., nil},;      // 6 - Imprimir
                  {.T., "Confirmar"},; // 7 - Confirmar
                  {.T., "Fechar"},;    // 8 - Cancelar
                  {.F., nil},;      // 9 - WalkTrhough
                  {.F., nil},;      // 10 - Ambiente
                  {.F., nil},;      // 11 - Mashup
                  {.T., nil},;      // 12 - Help
                  {.F., nil},;      // 13 - Formulário HTML
                  {.F., nil},;      // 14 - ECM
                  {.F., nil}}       // 15 - Salvar e Criar novo

    if Type("Inclui") == 'U'
        private Inclui := .F.
    endif
    
    if Type("Altera") == 'U'
        private Altera := .T.
    endif

    EnableKey(.F.)

    DbSelectAre("Z0R")
    DbSetOrder(1) // Z0R_FILIAL+DToS(Z0R_DATA)+Z0R_VERSAO


    if nOpc == 1
        DbSelectArea("Z05")
        DbSetOrder(1) // Z05_FILIAL+Z05_DATA+Z05_VERSAO+Z05_CURRAL+Z05_LOTE

        if Z05->(DbSeek(FWxFilial("Z05")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO+(cTrbBrowse)->Z08_CODIGO+(cTrbBrowse)->B8_LOTECTL)) 
            FWExecView('Manutenção', 'VAPCPA05', MODEL_OPERATION_VIEW,, { || .T. },,,aEnButt )
        else
            Help(/*Descontinuado*/,/*Descontinuado*/,"NAO EXISTE TRATO",/**/,"Não existe trato para este curral.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Não é possível visualizar o registro."})
        endif
        
    elseif Z0R->Z0R_LOCK <= '1'
        DbSelectArea("Z05")
        DbSetOrder(1) // Z05_FILIAL+Z05_DATA+Z05_VERSAO+Z05_CURRAL+Z05_LOTE
    
        if Z05->(DbSeek(FWxFilial("Z05")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO+(cTrbBrowse)->Z08_CODIGO+(cTrbBrowse)->B8_LOTECTL)) 
            if CanUseZ05()
                FWExecView('Manutenção', 'VAPCPA05', MODEL_OPERATION_UPDATE,, { || .T. },,,aEnButt )
                ReleaseZ05()
            endif
        elseif !Empty((cTrbBrowse)->B8_LOTECTL)
            if FillTrato()
                FWExecView('Manutenção', 'VAPCPA05', MODEL_OPERATION_UPDATE,, { || .T. },,,aEnButt)
                ReleaseZ05()
            endif
        endif
    elseif Z0R->Z0R_LOCK = '2' 
        Help(,, "OPERACAO NAO PERMITDA.",, "Não é possível alterar o trato pois ele já foi Publicado.", 1, 0,,,,,, {"Operação não permitida."})
    elseif Z0R->Z0R_LOCK = '3' 
        Help(,, "OPERACAO NAO PERMITDA.",, "Não é possível alterar o trato pois ele foi Encerrado.", 1, 0,,,,,, {"Operação não permitida."})
    endif

    EnableKey(.T.)

    if !Empty(aArea)
        RestArea(aArea)
    endif
    
    //teste aqui
    UpdTrbTmp()
    //u_vap05rec()
return nil


/*/{Protheus.doc} vap05nov
Cria um novos registros na Z05 e Z06 carrega a a interface para alteração.
@author jr.andre
@since 20/08/2019
@version 1.0
@return nil

@type function
/*/
user function vap05nov()
local aEnButt := {{.F., nil},;      // 1 - Copiar
                  {.F., nil},;      // 2 - Recortar
                  {.F., nil},;      // 3 - Colar
                  {.F., nil},;      // 4 - Calculadora
                  {.F., nil},;      // 5 - Spool
                  {.F., nil},;      // 6 - Imprimir
                  {.T., "Confirmar"},; // 7 - Confirmar
                  {.F., nil},;    // 8 - Cancelar
                  {.F., nil},;      // 9 - WalkTrhough
                  {.F., nil},;      // 10 - Ambiente
                  {.F., nil},;      // 11 - Mashup
                  {.T., nil},;      // 12 - Help
                  {.F., nil},;      // 13 - Formulário HTML
                  {.F., nil},;      // 14 - ECM
                  {.F., nil}}       // 15 - Salvar e Criar novo

    if Type("Inclui") == 'U'
        private Inclui := .F.
    endif
    
    if Type("Altera") == 'U'
        private Altera := .T.
    endif

    if CurrVazio()
        FWExecView('Incluir', 'VAPCPA05', MODEL_OPERATION_UPDATE,, { || .T. },,,aEnButt)
        ReleaseZ05()
    endif

    EnableKey(.T.)

return nil


/*/{Protheus.doc} VP05Form
Carrega o trato para
@author jr.andre
@since 25/04/2019
@version 1.0
@return nil
@param dDtTrato, date, descricao
@param cVersao, characters, descricao
@param cCurral, characters, descricao
@param cLote, characters, descricao

@type function
/*/
user function VP05Form(dDtTrato, cVersao, cCurral, cLote)
local aArea   := GetArea()
local aEnButt := {{.F., nil},;      // 1 - Copiar
                  {.F., nil},;      // 2 - Recortar
                  {.F., nil},;      // 3 - Colar
                  {.F., nil},;      // 4 - Calculadora
                  {.F., nil},;      // 5 - Spool
                  {.F., nil},;      // 6 - Imprimir
                  {.T., "Confirmar"},;      // 7 - Confirmar
                  {.T., "Fechar"},; // 8 - Cancelar
                  {.F., nil},;      // 9 - WalkTrhough
                  {.F., nil},;      // 10 - Ambiente
                  {.F., nil},;      // 11 - Mashup
                  {.T., nil},;      // 12 - Help
                  {.F., nil},;      // 13 - Formulário HTML
                  {.F., nil},;      // 14 - ECM
                  {.F., nil}}       // 15 - Salvar e Criar novo

if Type("INCLUI") != "L"
    Private Inclui := .F.
endif

if Type("ALTERA") != "L"
    Private Altera := .T.
endif

cVersao := PadR(cVersao, TamSX3("Z05_VERSAO")[1])
cCurral := PadR(cCurral, TamSX3("Z05_CURRAL")[1])
cLote := PadR(cLote, TamSX3("Z05_LOTE")[1])

    DbSelectAre("Z0R")
    DbSetOrder(1) // Z0R_FILIAL+DToS(Z0R_DATA)+Z0R_VERSAO
    if Z0R->(DbSeek(FWxFilial("Z0R")+DToS(dDtTrato)+cVersao))
        if Z0R->Z0R_LOCK <= '1'

            DbSelectArea("Z05")
            DbSetOrder(1) // Z05_FILIAL+Z05_DATA+Z05_VERSAO+Z05_CURRAL+Z05_LOTE

            if Z05->(DbSeek(FWxFilial("Z05")+DToS(dDtTrato)+cVersao+cCurral+cLote)) 
                if CanUseZ05()
                    FWExecView('Manutenção', 'VAPCPA05', MODEL_OPERATION_UPDATE,, { || .T. },,,aEnButt )
                    ReleaseZ05()
                endif
            elseif !Empty(cLote)
                if FillTrato(cCurral, cLote)
                    FWExecView('Manutenção', 'VAPCPA05', MODEL_OPERATION_UPDATE,, { || .T. },,,aEnButt)
                    ReleaseZ05()
                endif
            else
                Help(/*Descontinuado*/,/*Descontinuado*/,"Não existe lote",/**/,"No momento da geração do trato não existia lote vinculado a esse curral.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Não é possível vincular um trato."})
            endif

        elseif Z0R->Z0R_LOCK $ '23'
            DbSelectArea("Z05")
            DbSetOrder(1) // Z05_FILIAL+Z05_DATA+Z05_VERSAO+Z05_CURRAL+Z05_LOTE

            if Z05->(DbSeek(FWxFilial("Z05")+DToS(dDtTrato)+cVersao+cCurral+cLote)) 
                if CanUseZ05()
                    FWExecView('Manutenção', 'VAPCPA05', MODEL_OPERATION_VIEW,, { || .T. },,,aEnButt )
                    ReleaseZ05()
                endif
            else
                Help(/*Descontinuado*/,/*Descontinuado*/,"Não existe lote",/**/,"Não foi gerado trato vinculado a esse curral.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Não é possível visualizar o trato."})
            endif
        endif
    else
        Help(,, "Trato não encontrado.",, "Não foi encontrado o trato de " + DToC(dDtTrato) + " versão " + cVersao + ".", 1, 0,,,,,, {"Por favor, verifique."})
    endif

if !Empty(aArea)
    RestArea(aArea)
endif
return nil


/*/{Protheus.doc} ModelDef
//Cria o modelo de dados da rotina
@author jr.andre
@since 25/04/2019
@version 1.0
@return oModel, Objeto MPFormModel com os detalhes do modelo de dados da rotina

@type function
/*/
static function ModelDef()
local oModel

local oStrZ05C   := Z05FldMStr()
local oStrZ0IG   := Z0IGrdMStr()
local oStrZ05G   := Z05GrdMStr()
local oStrZ06G   := Z06GrdMStr()

local bLoadZ05   := {|oModel, lCopia| LoadZ05(oModel, lCopia) }
local bLoadZ0I   := {|oFormGrid, lCopia| LoadZ0I(oFormGrid, lCopia) }
local bLoadZ05An := {|oFormGrid, lCopia| LoadZ05Ant(oFormGrid, lCopia) }

local bZ06LinePr := {|oGridModel, nLin, cOperacao, cCampo, xValAtr, xValAnt| Z06LinPreG(oGridModel, nLin, cOperacao, cCampo, xValAtr, xValAnt)}
local bZ06Pre    := {|oGridModel, nLin, cAction| Z06Pre(oGridModel, nLin, cAction)}
local bZ06LinePo := {|oGridModel, nLin| Z06LinPost(oGridModel, nLin)}
local bLoadZ06   := {|oFormGrid, lCopia| LoadZ06(oFormGrid, lCopia) }

//local bPreValid  := {|oModel| FrmPreVld(oModel)}
//local bPostValid := {|oModel| FrmPostVld(oModel)}
local bCommit    := {|oModel| FormCommit(oModel)}
local bCancel    := {|oModel| FormCancel(oModel)}

local oEvent := vapcp05Evt():New()

EnableKey(.F.)

oModel := MPFormModel():New('MDVAPCPA05', /*bPreValid*/, /*bPostValid*/, bCommit, bCancel)
oModel:SetDescription("Plano de Trato")

// Criação dos sub-modelos
oModel:AddFields("MdFieldZ05",/*cOwner*/, oStrZ05C,/*bPreValid*/, /*bPosValid*/, bLoadZ05)
oModel:AddGrid("MdGridZ0I", "MdFieldZ05", oStrZ0IG, /*bLinePre*/,/*bLinePost*/,/*bPre */,/*bPost*/, bLoadZ0I)
oModel:AddGrid("MdGridZ05", "MdFieldZ05", oStrZ05G, /*bLinePre*/,/*bLinePost*/,/*bPre */,/*bPost*/, bLoadZ05An)
oModel:AddGrid("MdGridZ06", "MdFieldZ05", oStrZ06G, bZ06LinePr, bZ06LinePo, bZ06Pre,/*bPost*/, bLoadZ06)

// Definição de Descrição 
oModel:GetModel("MdFieldZ05"):SetDescription("Plano de Trato")
oModel:GetModel("MdGridZ0I"):SetDescription("Manejo de Cocho")
oModel:GetModel("MdGridZ05"):SetDescription("Programacao Anterior")
oModel:GetModel("MdGridZ06"):SetDescription("Programacao")

// Definição de atributos
oModel:SetOnlyQuery('MdFieldZ05', .T.)
oModel:SetOnlyQuery('MdGridZ0I', .T.)
oModel:SetOnlyQuery('MdGridZ05', .T.)
oModel:SetOnlyQuery('MdGridZ06', .T.)

// Permite exclusão de todas as linhas 
oModel:getModel("MdGridZ0I"):SetDelAllLine(.T.)
oModel:getModel("MdGridZ05"):SetDelAllLine(.T.)
oModel:getModel("MdGridZ06"):SetDelAllLine(.T.)

// remove a permissão de inclusão e exclusão de linhas 
oModel:getModel("MdGridZ0I"):SetNoInsertLine(.T.)
oModel:getModel("MdGridZ05"):SetNoInsertLine(.T.)
oModel:getModel("MdGridZ06"):SetNoInsertLine(.T.)
oModel:getModel("MdGridZ0I"):SetNoDeleteLine(.T.)
oModel:getModel("MdGridZ05"):SetNoDeleteLine(.T.)
oModel:getModel("MdGridZ06"):SetNoDeleteLine(.T.)

// Cria a chave primária 
oModel:SetPrimaryKey({"Z05_DATA", "Z05_VERSAO", "Z05_CURRAL", "Z05_LOTE"})

oModel:InstallEvent("vapcp05Evt",,oEvent)

return oModel


/*/{Protheus.doc} Z06LinPreG
Bloco de Código de pré-edição da linha do grid no modelo. Foram implementadas as operações UNDELETE e SETVALUE.
@author jr.andre
@since 25/04/2019
@version 1.0
@return lRet, Indica se a pre validação do modelo foi efetuada com sucesso.
@param oGridModel, object, descricao
@param nLin, numeric, descricao
@param cOperacao, characters, descricao
@param cCampo, characters, descricao
@param xValAtr, , descricao
@param xValAnt, , descricao

@type function
/*/
static function Z06LinPreG(oGridModel, nLin, cOperacao, cCampo, xValAtr, xValAnt)
local aArea       := GetArea()
local lRet        := .T.
local i, nLen
local oActiveView := nil
local cTrato      := ""
local nRegZ06     := 0

if cOperacao == "UNDELETE"
    cTrato := oGridModel:GetValue("Z06_TRATO")
    for i := 1 to oGridModel:Length()
        oGridModel:GoLine(i)
        if i <> nLin
            if !oGridModel:IsDeleted() .and. oGridModel:GetValue("Z06_TRATO") == cTrato 
                Help(,, "Operação não pode ser realizada.",, "Não é possível voltar o registro pois já existe outro para esse trato.", 1, 0,,,,,, {"Edite a linha que está com o dia correto."})
                lRet := .F.
                exit
            endIf
        endIf
    next
    oGridModel:GoLine(nLin)

elseif cOperacao == "SETVALUE"
    DbSelectArea("Z06")
    DbSetOrder(1) // Z06_FILIAL+DToS(Z06_DATA)+Z06_VERSAO+Z06_CURRAL+Z06_LOTE+Z06_TRATO

    oActiveView := FWViewActive()

    // A gravação de um registro novo ocorre na validação da linha
    // se ainda não foi gravado não atualizar.
    if !"Z06_RECNO" $ cCampo .and. (nRegZ06 := oGridModel:GetValue("Z06_RECNO")) > 0
        Z06->(DbGoTo(nRegZ06))
        if Z06->(RecNo()) == nRegZ06

            // Atualiza o campo
            Persiste("Z06", cCampo, xValAtr)

            if oActiveView:oModel:GetModel("MdFieldZ05"):GetValue("Z05_MANUAL") != "1"
                // Muda o estado da Z05 para 1
                Persiste("Z05", "Z05_MANUAL", "1")

                // Muda o estado do que está na tela 
                oActiveView:oModel:GetModel("MdFieldZ05"):SetValue("Z05_MANUAL", "1")

            endif
        endif
    endif
endif

if!Empty(aArea)
    RestArea(aArea)
endif
return lRet


/*/{Protheus.doc} Z06LinPost
Bloco de código de pós-validação da linha do grid. 
@author jr.andre
@since 25/04/2019
@version 1.0
@return lRet, .T. se conteúdo do modelo foi validado.
@param oGridModel, object, descricao
@param nLin, numeric, descricao
@type function
/*/
static function Z06LinPost(oGridModel, nLin)
local lRet   := .T.
local cTrato := ""
local i, nLen
local oModel := FWModelActive()

default nLin := oGridModel:GetLine()

    if !oGridModel:IsInserted(nLin) //.and. oGridModel:Length()
    SX3->(DbSetOrder(2))
    
        if !oGridModel:IsDeleted(nLin) //.and. !oGridModel:IsInserted(nLin) 
            cTrato := oGridModel:GetValue("Z06_TRATO")
            if Empty(cTrato)
                SX3->(DbSeek(Padr("Z06_TRATO", Len(SX3->X3_CAMPO))))
                Help(,, "Linha inválida.",, "O campo " + X3Titulo() + " é obrigatório.", 1, 0,,,,,, {"Por favor, preencha o campo " + X3Titulo() + "."})
                lRet := .F.
            elseif Val(cTrato) > u_GetNroTrato() 
                SX3->(DbSeek(Padr("Z06_TRATO", Len(SX3->X3_CAMPO))))
                Help(,, "Linha inválida.",, "O campo " + X3Titulo() + " Não deve ser maior que " + AllTrim(Str(u_GetNroTrato())) +", Por favor verifique o numero de tratos do lote.", 1, 0,,,,,, {"Por favor, verifique o campo " + X3Titulo() + "."})
                lRet := .F.
            elseif Empty(oGridModel:GetValue("Z06_DIETA"))
                SX3->(DbSeek(Padr("Z06_DIETA", Len(SX3->X3_CAMPO))))
                Help(,, "Linha inválida.",, "O campo " + X3Titulo() + " é obrigatório.", 1, 0,,,,,, {"Por favor, preencha o campo " + X3Titulo() + "."})
                lRet := .F.
//            elseif Empty(oGridModel:GetValue("Z06_KGMSTR"))
//                SX3->(DbSeek(Padr("Z06_KGMSTR", Len(SX3->X3_CAMPO))))
//                Help(,, "Linha inválida.",, "O campo " + X3Titulo() + " é obrigatório.", 1, 0,,,,,, {"Por favor, preencha o campo " + X3Titulo() + "."})
//                lRet := .F.
            elseif oGridModel:GetValue("Z06_KGMSTR") < 0
                SX3->(DbSeek(Padr("Z06_KGMSTR", Len(SX3->X3_CAMPO))))
                Help(,, "Linha inválida.",, "O  valor do campo " + X3Titulo() + " deve ser maior que 0.", 1, 0,,,,,, {"Por favor, preencha o campo " + X3Titulo() + " com um valor adequado."})
                lRet := .F.
            elseif oGridModel:GetValue("Z06_KGMNTR") < 0
                SX3->(DbSeek(Padr("Z06_KGMNTR", Len(SX3->X3_CAMPO))))
            elseif oGridModel:GetValue("Z06_MEGCAL") < 0
                SX3->(DbSeek(Padr("Z06_MEGCAL", Len(SX3->X3_CAMPO))))
            elseif oGridModel:GetValue("Z06_KGMNT") < 0
                SX3->(DbSeek(Padr("Z06_KGMNT", Len(SX3->X3_CAMPO))))
                /// todo
                Help(,, "Linha inválida.",, "O  valor do campo " + X3Titulo() + " deve ser maior que 0.", 1, 0,,,,,, {"Por favor, preencha o campo " + X3Titulo() + " com um valor adequado."})
                lRet := .F.
            else
                nLen := oGridModel:Length()
                for i := 1 to nLen
                    oGridModel:GoLine(i)
                    if !oGridModel:IsDeleted() .and. nLin <> i .and. oGridModel:GetValue("Z06_TRATO") == cTrato
                        Help(,, "Linha inválida.",, "Já existe o trato " + cTrato + " na linha " + AllTrim(Str(i)) + ".", 1, 0,,,,,, {"Por favor, verifique."})
                        lRet := .F.
                        exit 
                    endif 
                next
            endif
        endif
    EndIf
return lRet


/*/{Protheus.doc} Z06Pre
Bloco de Código de pré-validação do submodelo. Implementadas as Actions "ISENABLE", "ADDLINE", "UNDELETE" e "DELETE" apensa duarente a operação de alteração do modelo. 
@author jr.andre
@since 25/04/2019
@version 1.0
@return lRet, .T. se o 
@param oGridModel, object, descricao
@param nLin, numeric, descricao
@param cAction, characters, descricao
@type function
/*/
static function Z06Pre(oGridModel, nLin, cAction)
local lRet       := .T.
local nOperation := oGridModel:GetOperation()
local i
local cSeq       := ""

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

    if cAction == "ISENABLE"
        for i := 1 to oGridModel:Length()
            if oGridModel:aDataModel[i][MODEL_GRID_INSERT] == .T. .and. oGridModel:aDataModel[i][MODEL_GRID_UPDATE] == .T.
                loop
            endif
            oGridModel:aDataModel[i][MODEL_GRID_INSERT] := .T.
            oGridModel:aDataModel[i][MODEL_GRID_UPDATE] := .T.
        next
    elseif cAction == "ADDLINE"
        // Disposiciona a Z06 para adicionar sempre uma nova linha
        Z06->(DbSeek('ZZ'))
        if oGridModel:Length() == u_GetNroTrato()
            Help(,, "Atingiu máximo de tratos.",, "O número máximo de tratos foi atingido.", 1, 0,,,,,, {"Não é possível adicionar um novo trato."})
            lRet := .F.
        endif
    elseif cAction == "UNDELETE"
    // verifica se já existe o numero do trato antes de recriar a linha
        nLen := oGridModel:Length()
        for i := 1 to nLen
            if i <> nLin .and. !oGridModel:IsDeleted(i)
                if oGridModel:GetValue("Z06_TRATO", i) == oGridModel:GetValue("Z06_TRATO", nLin)
                    Help(,, "Trato já existe.",, "Não é possível recuperar a linha pois o trato " + oGridModel:GetValue("Z06_TRATO", nLin) + " já existe na linha " + AllTrim(Str(i)) + ".", 1, 0,,,,,, {"Por favor, verifique."})
                    lRet := .F.
                    exit
                endif
            endif 
        next
        // Se não existir recria o trato e atribui numero do trato no recno
        if lRet
            // {"Z05_DATA", "Z05_VERSAO", "Z05_CURRAL", "Z05_LOTE", "Z05_CABECA", "Z05_DIAPRO", "Z05_DIASDI", "Z05_MANUAL"}
            if oGridModel:GetValue("Z06_RECNO", nLin) <> 0
                Z06->(DbGoTo(oGridModel:GetValue("Z06_RECNO", nLin)))
                cSeq := GetSeq(oGridModel:GetValue("Z06_DIETA"))
                nMegaCal := GetMegaCal(oGridModel:GetValue("Z06_DIETA"))
                nMCalTrat := nMegaCal * Z06->Z06_KGMSTR

                RecLock("Z06", .F.)
                    DbRecall()
                    Z06->Z06_FILIAL := FWxFilial("Z06")
                    Z06->Z06_DATA   := Z05->Z05_DATA
                    Z06->Z06_VERSAO := Z05->Z05_VERSAO
                    Z06->Z06_CURRAL := Z05->Z05_CURRAL
                    Z06->Z06_LOTE   := Z05->Z05_LOTE
                    Z06->Z06_DIAPRO := Z05->Z05_DIAPRO
                    Z06->Z06_TRATO  := oGridModel:GetValue("Z06_TRATO")
                    Z06->Z06_DIETA  := oGridModel:GetValue("Z06_DIETA")
                    Z06->Z06_KGMSTR := oGridModel:GetValue("Z06_KGMSTR")
                    Z06->Z06_KGMNTR := oGridModel:GetValue("Z06_KGMNTR")
                    Z06->Z06_KGMNT  := oGridModel:GetValue("Z06_KGMNTR") * Z05->Z05_CABECA
                    Z06->Z06_SEQ    := cSeq
                    Z06->Z06_MEGCAL := nMegaCal
                MsUnlock()
                LogTrato("Inclusão de registro", "incluido o registro " + AllTrim(Str(oGridModel:GetValue("Z06_RECNO"))) + " - {" + Z06->Z06_FILIAL + "|" + DToS(Z06->Z06_DATA) + "|" + Z06->Z06_VERSAO + "|" + Z06->Z06_CURRAL + "|" + Z06->Z06_LOTE + "|" + Z06->Z06_DIAPRO + "|" + Z06->Z06_TRATO + "|" + Z06->Z06_DIETA + "|" + AllTrim(Str(Z06->Z06_KGMSTR)) + "|" + AllTrim(Str(Z06->Z06_KGMNTR )) + "}")
                oGridModel:LoadValue("Z06_RECNO", Z06->(RecNo()))
            endif
        endif
    elseif cAction == "DELETE"
        if !Empty(oGridModel:GetValue("Z06_RECNO"))
            Z06->(DbGoTo(oGridModel:GetValue("Z06_RECNO")))
            if Z06->(RecNo()) == oGridModel:GetValue("Z06_RECNO")
                LogTrato("Exclusão de registro", "Excluido o registro " + AllTrim(Str(oGridModel:GetValue("Z06_RECNO"))) + " - {" + Z06->Z06_FILIAL + "|" + DToC(Z06->Z06_DATA) + "|" + AllTrim(Z06->Z06_VERSAO) + "|" + AllTrim(Z06->Z06_CURRAL) + "|" + AllTrim(Z06->Z06_LOTE) + "|" + AllTrim(Z06->Z06_DIAPRO) + "|" + AllTrim(Z06->Z06_TRATO) + "|" + AllTrim(Z06->Z06_DIETA) + "|" + AllTrim(Str(Z06->Z06_KGMSTR)) + "|" + AllTrim(Str(Z06->Z06_KGMNTR )) + "}")
                RecLock("Z06", .F.)
                Z06->(DbDelete())
                MsUnlock()
            endif
        endif
    endif
endif

return lRet


/* /{Protheus.doc} FrmPreVld
Bloco de código de pré-validação do modelo. 
@author jr.andre
@since 25/04/2019
@version 1.0
@return lRet, Pre validação efetuada com sucesso
@param oModel, object, descricao
@type function

static function FrmPreVld(oModel)
local lRet := .T.
return lRet
/*/


/* /{Protheus.doc} FrmPostVld
Bloco de código de pós-validação do modelo, equilave ao "TUDOOK".
@author jr.andre
@since 25/04/2019
@version 1.0
@return lRet, Pos validação efetuada com sucesso
@param oModel, object, descricao
@type function

static function FrmPostVld(oModel)
local lRet := .T.
return lRet
/*/


/*/{Protheus.doc} FormCommit
Bloco de código de persistência dos dados, invocado pelo método CommitData. 
Aqui deve apenas retornar .T. pois a gravação dos registro é feita no momento da alteração
@author jr.andre
@since 25/04/2019
@version 1.0
@return lRet, Retorna se os dados foram persistidos com sucesso
@param oModel, object, descricao
@type function
/*/

static function FormCommit(oModel)
local lRet       := .T.
local oFormModel := oModel:GetModel("MdFieldZ05")
local lAtuZ06    := .F.

    // verifica se exitem registros intermediários sem dieta e grava-os com quantidade 0
    DbSelectArea("Z05")
    DbSetOrder(1) // // Z05_FILIAL+Z05_DATA+Z05_VERSAO+Z05_CURRAL+Z05_LOTE

    if Z05->Z05_FILIAL != FWxFilial("Z05") .or. Z05->Z05_DATA != oFormModel:GetValue("Z05_DATA") .or. Z05->Z05_VERSAO != oFormModel:GetValue("Z05_VERSAO") .or. Z05->Z05_LOTE != oFormModel:GetValue("Z05_LOTE")
        lAtuZ06 := Z05->(DbSeek(FWxFilial("Z05")+oFormModel:GetValue("Z05_DATA")+oFormModel:GetValue("Z05_VERSAO")+oFormModel:GetValue("Z05_CURRAL")+oFormModel:GetValue("Z05_LOTE")))
    endif

    if lAtuZ06
        FillEmpty()
    endif

    if FunName() == "VAPCPA05"
        UpdTrbTmp()
    endif
return lRet


/*/{Protheus.doc} FormCancel
Bloco de código de cancelamento da edição, invocado pelo método CancelData. 
Aqui deve apenas retornar .T. pois a gravação dos registro é feita no momento da alteração

@author jr.andre
@since 25/04/2019
@version 1.0
@return L, Indica se o calcelamento pode ser efetuado com sucesso
@param oModel, object, descricao
@type function
/*/
static function FormCancel(oModel)
local lRet := .T.
return lRet


/*/{Protheus.doc} LoadZ05
Carrega os dados da tabela Z05 de acordo com o registro posicinado
@author jr.andre
@since 25/04/2019
@version 1.0
@return aRet, Array com os dados da tabela
@param oModel, object, descricao
@param lCopia, logical, descricao
@type function
/*/
static function LoadZ05(oModel, lCopia)
local aArea    := GetArea()
local aRet     := {}
local i, nLen
local aCposUsu := {}

DbSelectArea("SB8")
DbSetOrder(7) // B8_FILIAL+B8_LOTECTL+B8_X_CURRA

DbSelectArea("Z08")
DbSetOrder(1) // Z08_FILIAL+Z08_CODIGO 

DbSelectArea("Z05")
DbSetOrder(1) // Z05_FILIAL+Z05_DATA+Z05_VERSAO+Z05_CURRAL+Z05_LOTE 

if Type("cTrbBrowse") <> "U" .and. Select(cTrbBrowse) > 0
    Z05->(DbSeek(FWxFilial("Z05")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO+(cTrbBrowse)->Z08_CODIGO+(cTrbBrowse)->B8_LOTECTL))
    Z08->(DbSeek(FWxFilial("Z08")+(cTrbBrowse)->Z08_CODIGO))
    SB8->(DbSeek(FWxFilial("SB8")+(cTrbBrowse)->B8_LOTECTL+(cTrbBrowse)->Z08_CODIGO))
endif

if !Z05->(Eof())

    SX3->(DbSetOrder(1)) // X3_ARQUIVO + X3_ORDEM
    SX3->(DbSeek("Z0501"))

    while !SX3->(Eof()) .and. SX3->X3_ARQUIVO == 'Z05'
        if aScan(aCpoMdZ05F, {|aMat| AllTrim(aMat) == AllTrim(SX3->X3_CAMPO)}) > 0 
            AAdd(aCposUsu, SX3->X3_CAMPO)
            if "Z05_TOTMSC" $ SX3->X3_CAMPO
                AAdd(aRet, if(!Empty(Z05->Z05_TOTMSC),Z05->Z05_TOTMSC,Z05->Z05_KGMSDI))
            elseif "Z05_TOTMNC" $ SX3->X3_CAMPO
                AAdd(aRet, Iif(!Empty(Z05->Z05_TOTMNC),Z05->Z05_TOTMNC,Z05->Z05_KGMNDI))
            else
                if TamSX3(SX3->X3_CAMPO)[3] == 'C'
                    AAdd(aRet, AllTrim(&("Z05->" + SX3->X3_CAMPO)))
                else
                    AAdd(aRet, &("Z05->" + SX3->X3_CAMPO))
                endif
            endif

        endif
        SX3->(DbSkip())
    end

else
    DbUseArea(.T., "TOPCONN", TCGenQRY(,,;
                              " select Z08.Z08_FILIAL" +;
                                    ", Z08.Z08_CONFNA" +;
                                   ;//" , Z08.Z08_LINHA" +;
                                    ", Z08.Z08_CODIGO" +;
                                    ", SB8.B8_LOTECTL" +;
                                    ", sum(B8_SALDO) B8_SALDO" +;
                                    ", min(SB8.B8_XDATACO) DT_INI_PROG" +;
                                " from " + RetSqlName("Z08") + " Z08" +;
                           " left join " + RetSqlName("SB8") + " SB8" +;
                                  " on SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                                 " and SB8.B8_X_CURRA = Z08.Z08_CODIGO" +;
                                 " and SB8.B8_SALDO   <> 0" +;
                                 " and SB8.B8_LOTECTL = '" + SB8->B8_LOTECTL + "'" +;
                                 " and SB8.D_E_L_E_T_ = ' '" +;
                               " where Z08.Z08_FILIAL = '" + FWxFilial("Z08") + "'" +;
                                 " and Z08.Z08_CODIGO = '" + Z08->Z08_CODIGO + "'" +;
                                 " and Z08.Z08_CONFNA <> '  '" +;
                                 " and Z08.D_E_L_E_T_ = ' '" +;
                            " group by Z08.Z08_FILIAL" +;
                                    ", Z08.Z08_CONFNA" +;
                                    ;//", Z08.Z08_LINHA" +;
                                    ", Z08.Z08_CODIGO" +;
                                    ", SB8.B8_LOTECTL" ;
                                          ), "CURRAIS", .F., .F.)

    SX3->(DbSetOrder(1)) // X3_ARQUIVO + X3_ORDEM
    SX3->(DbSeek("Z0501"))

    while !SX3->(Eof()) .and. SX3->X3_ARQUIVO == 'Z05'
        if aScan(aCpoMdZ05F, {|aMat| AllTrim(aMat) == AllTrim(SX3->X3_CAMPO)}) > 0
            AAdd(aCposUsu, SX3->X3_CAMPO)
            if "Z05_DATA" == AllTrim(SX3->X3_CAMPO)
                AAdd(aRet, Z0R->Z0R_DATA)
            elseif "Z05_VERSAO" == AllTrim(SX3->X3_CAMPO)
                AAdd(aRet, Z0R->Z0R_VERSAO)
            elseif "Z05_CURRAL" == AllTrim(SX3->X3_CAMPO)
                AAdd(aRet, Z08->Z08_CODIGO)
            elseif "Z05_LOTE" == AllTrim(SX3->X3_CAMPO)
                AAdd(aRet, SB8->B8_LOTECTL)
            elseif "Z05_CABECA" == AllTrim(SX3->X3_CAMPO)
                AAdd(aRet, CURRAIS->B8_SALDO)
            elseif "Z05_ORIGEM" == AllTrim(SX3->X3_CAMPO)
                AAdd(aRet, '3')
            elseif "Z05_DIAPRO" == AllTrim(SX3->X3_CAMPO)
                AAdd(aRet, CriaVar("Z05_DIAPRO", .F.))
            elseif "Z05_DIASDI" == AllTrim(SX3->X3_CAMPO)
                AAdd(aRet, Z0R->Z0R_DATA - SToD(CURRAIS->DT_INI_PROG))
            elseif "Z05_MANUAL" == AllTrim(SX3->X3_CAMPO)
                AAdd(aRet, "1")
            else
                AAdd(aRet, CriaVar(SX3->X3_CAMPO, .F.))
            endif
        endif
        SX3->(DbSkip())
    end
endif

if !Empty(aArea)
    RestArea(aArea)
endif
return aRet


/*/{Protheus.doc} LoadZ0I
Carrega as notas de cocho para a grid
@author jr.andre
@since 20/08/2019
@version 1.0
@return aRet, Array com as ultimas notas de cocho conforme parametro VA_REGHIST
@param oFormGrid, object, descricao
@param lCopia, logical, descricao
@type function
/*/
static function LoadZ0I(oFormGrid, lCopia)
local aArea  := GetArea()
local aRet   := {}
local i, nLen
local cDatas := ""

//aCpoMdZ0IG := {"Z0I_DATA", "Z0I_NOTMAN", "Z0I_NOTTAR"}
nLen := GetMV("VA_REGHIST",,5) // Identifica a quantidade de registros históricos que devem ser mostradas na rotina VAPCPA05  
for i := 0 to nLen-1
    cDatas += Iif(Empty(cDatas),"", ", ") + "('" + DToS(Z05->Z05_DATA-i) + "')"
next

DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                          " select DIA_NOTA" +;
                               " , Z0I.Z0I_NOTMAN" +;
                               " , Z0I.Z0I_NOTTAR" +;
                               " , Z0I.Z0I_NOTNOI" +;
                            " from ( values " + cDatas + ") TMPTBL (DIA_NOTA)" +;
                       " left join " + RetSqlName("Z0I") + " Z0I" +;
                              " on Z0I.Z0I_FILIAL = '" + FwXFilial("Z0I") + "'" +;
                             " and Z0I.Z0I_DATA   = TMPTBL.DIA_NOTA" +;
                             " and Z0I.Z0I_LOTE   = '" + Z05->Z05_LOTE + "'" +;
                             " and Z0I.D_E_L_E_T_ = ' '" ;
                                     ),"TMPZ0I", .F., .F.)

while !TMPZ0I->(Eof())
    AAdd(aRet, {0, {SToD(TMPZ0I->DIA_NOTA), TMPZ0I->Z0I_NOTMAN, TMPZ0I->Z0I_NOTTAR, TMPZ0I->Z0I_NOTNOI}})
    TMPZ0I->(DbSkip())
end

TMPZ0I->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif
return aRet

static function LoadZ06(oFormGrid, lCopia)
local aArea     := GetArea()
local aTemplate :={0, {}}
local aRet      := {}
// aCpoMdZ06G := {"Z06_TRATO", "Z06_DIETA", "Z06_KGMSTR", "Z06_KGMNTR", "Z06_RECNO"}

DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                          " select Z06.Z06_TRATO" +;
                                ", Z06.Z06_DIETA" +;
                                ", Z06.Z06_KGMSTR" +;
                                ", Z06.Z06_KGMNTR" +;
                                ", Z06.Z06_MEGCAL" +;
                                ", Z06.Z06_KGMNT" +;
                                ", Z06.R_E_C_N_O_ Z06_RECNO" +;
                            " from " + RetSqlName("Z06") + " Z06" +;
                           " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                             " and Z06.Z06_DATA   = '" + DToS(Z05->Z05_DATA) + "'" +;
                             " and Z06.Z06_VERSAO = '" + Z05->Z05_VERSAO + "'" +;
                             " and Z06.Z06_LOTE   = '" + Z05->Z05_LOTE + "'" +;
                             " and Z06.D_E_L_E_T_ = ' '" +;
                        " order by Z06.Z06_TRATO" ;
                                      ),"TMPZ06", .F., .F.) 

    while !TMPZ06->(Eof())
        AAdd(aRet, aClone(aTemplate))
        aRet[Len(aRet)][1] := 0
        aRet[Len(aRet)][2] := {TMPZ06->Z06_TRATO;   // Z06_TRATO
                             , TMPZ06->Z06_DIETA;   // Z06_DIETA
                             , TMPZ06->Z06_KGMSTR;  // Z06_KGMSTR
                             , TMPZ06->Z06_KGMNTR;  // Z06_KGMNTR
                             , TMPZ06->Z06_MEGCAL;  // Z06_MEGCAL
                             , TMPZ06->Z06_KGMNT;   // Z06_KGMNT
                             , TMPZ06->Z06_RECNO}   // Z06_RECNO
        TMPZ06->(DbSkip())
    end

TMPZ06->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif
return aRet


/*/{Protheus.doc} LoadZ05Ant
Carrega na tela os detalhes dos tratos anteriores.
@author jr.andre
@since 13/09/2019
@version 1.0
@return Array, ${return_description}
@param oFormGrid, object, objeto da grid
@param lCopia, logical, indica se se trata de uma opção de cópia
@type function
/*/
static function LoadZ05Ant(oFormGrid, lCopia)
local aArea     := GetArea()
local oView     := FWViewActive()
local aTemplate :={0, {}}
local aRet      := {}
local i, nLen
local cDatas    := ""

nLen := GetMV("VA_REGHIST",,5) // Identifica a quantidade de reguistros históricos que deve ser mostradas na rotina VAPCPA05  
for i := 1 to nLen
    cDatas += Iif(Empty(cDatas),"", ", ") + "('" + DToS(Z05->Z05_DATA-i) + "')"
next

DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                           " with PRODU AS (" +;
                                 " select Z0Y.Z0Y_ORDEM, Z0Y.Z0Y_TRATO, case when Z0Y_PESDIG > 0 THEN Z0Y_PESDIG ELSE Z0Y_QTDREA  END AS PRD_QTD_REA, Z0Y_QTDPRE PRD_QTD_PRV" +;
                                   " from " + RetSqlName("Z0Y") + " Z0Y" +;
                                  " where Z0Y.Z0Y_FILIAL = '" + FWxFilial("Z0Y") + "'" +;
                                    " and Z0Y.Z0Y_DATINI <> '        '" +; // Descarta as linhas que não foram efetivadas
                                    " and Z0Y.D_E_L_E_T_ = ' '" +;
                               " group by Z0Y.Z0Y_ORDEM, Z0Y.Z0Y_TRATO, Z0Y_PESDIG, Z0Y_QTDREA, Z0Y_QTDPRE" +;
                           " ), QTDPROD as (" +;
                                 " select PRD.Z0Y_ORDEM, PRD.Z0Y_TRATO, sum(PRD.PRD_QTD_REA) PRD_QTD_REA, sum(PRD.PRD_QTD_PRV) PRD_QTD_PRV" +;
                                   " from PRODU PRD" +;
                               " group by PRD.Z0Y_ORDEM, PRD.Z0Y_TRATO" +;
                           " ), TRATO AS (" +;
                                 " select Z0W.Z0W_ORDEM, Z0W.Z0W_TRATO, CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END  TRT_QTD_REA, Z0W.Z0W_QTDPRE TRT_QTD_PRV" +;
                                   " from " + RetSqlName("Z0W") + " Z0W" +;
                                  " where Z0W.Z0W_FILIAL = '" + FWxFilial("Z0W") + "'" +;
                                    " and Z0W.Z0W_DATINI <> '        '" +;
                                    " and Z0W.D_E_L_E_T_ = ' '" +;
                               " group by Z0W.Z0W_ORDEM, Z0W.Z0W_TRATO, Z0W_PESDIG, Z0W_QTDREA, Z0W_QTDPRE" +;
                          " ), QTDTRATO as (" +;
                                " select Z0W.Z0W_ORDEM, Z0W.Z0W_TRATO, sum(Z0W.TRT_QTD_REA) TRT_QTD_REA, sum(Z0W.TRT_QTD_PRV) TRT_QTD_PRV" +;
                                  " from TRATO Z0W" +;
                              " group by Z0W.Z0W_ORDEM, Z0W.Z0W_TRATO     " +;
                          " ), RECEITA as (" +;
                                " select Z0Y_ORDEM, Z0Y_TRATO, Z0Y_COMP, CASE WHEN Z0Y_PESDIG > 0 THEN Z0Y_PESDIG ELSE  Z0Y_QTDREA END AS Z0Y_QTDREA, Z0Y_QTDPRE" +;
                                  " from " + RetSqlName("Z0Y") + " Z0Y" +;
                                 " where Z0Y.Z0Y_FILIAL = '" + FWxFilial("Z0Y") + "'" +;
                                   " and Z0Y.Z0Y_DATINI <> '        ' " +;
                                   " and Z0Y.D_E_L_E_T_ = ' '" +;
                          " )," +;
                          " REALIZADO as (" +;
                                " select Z0W.Z0W_ORDEM" +; // OP
                                     " , Z0W.Z0W_DATA" +; // Data do trato
                                     " , Z0W.Z0W_VERSAO" +; // versão do trato
                                     " , Z0W.Z0W_ROTA" +; // Rota a que o curral pertence
                                     " , Z0W.Z0W_CURRAL" +; // Curral
                                     " , Z0W.Z0W_LOTE" +; // Lote
                                     " , Z0W.Z0W_TRATO" +; // Numero do trato
                                     " , REC.Z0Y_COMP" +; // Componente da receita do trato
                                     " , Z0W.Z0W_QTDREA" +; // Quantidade distribuida no cocho para a baia
                                     " , Z05.Z05_CABECA" +; // Numero de cabeças da baia no momento do trato
                                     " , PRD.PRD_QTD_PRV" +; // Qunatidade total produzida prevista
                                     " , PRD.PRD_QTD_REA" +; // Quantidade total produzida aferida na balança
                                     " , TRT.TRT_QTD_PRV" +; // Quantidade total distribuida prevista
                                     " , TRT.TRT_QTD_REA" +; // Quantidade total distribuida aferida na balança
                                     " , REC.Z0Y_QTDREA" +; // Quantidade do componente usado na fabricação da dieta
                                     " , Z0V.Z0V_INDMS" +; // Indice de materia seca no dia/versao do trato
                                     " , Z0W_QTDREA/TRT_QTD_REA*PRD_QTD_REA QTD_MN" +; // Quantidade total de materia natural distribuida no cocho
                                     " , ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*PRD_QTD_REA)/(TRT_QTD_REA*Z05_CABECA) QTD_MN_CABECA" +; // Quantidade total de materia natural distribuida no cocho por cabeça
                                     " , ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*Z0Y_QTDREA)/TRT_QTD_REA QTD_MN_COMPONENTE" +; // quantidade de materia natural do componente
                                     " , ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*Z0Y_QTDREA)/(TRT_QTD_REA*Z05_CABECA) QTD_MN_COMPONENTE_CABECA" +; // quantidade de materia natural do componente por cabeça
                                     " , ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*Z0Y_QTDREA*Z0V_INDMS)/(100*TRT_QTD_REA) QTD_MS_COMPONENTE" +; // quantidade calculada de materia seca do componente de acordo com o indice de materia seca utilizado no trato
                                     " , ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*Z0Y_QTDREA*Z0V_INDMS)/(100*TRT_QTD_REA*Z05_CABECA) QTD_MS_COMP_CABECA" +; // quantidade calculada de materia seca do componente por cabeça de acordo com o indice de materia seca utilizado no trato
                                  " from " + RetSqlName("Z0W") + " Z0W" +;
                                  " join QTDPROD PRD" +;
                                    " on PRD.Z0Y_ORDEM = Z0W.Z0W_ORDEM" +;
                                   " and PRD.Z0Y_TRATO = Z0W.Z0W_TRATO" +;
                                  " join QTDTRATO TRT" +;
                                    " on TRT.Z0W_ORDEM = Z0W.Z0W_ORDEM" +;
                                   " and TRT.Z0W_TRATO = Z0W.Z0W_TRATO" +;
                                  " join RECEITA REC" +;
                                    " on REC.Z0Y_ORDEM = Z0W.Z0W_ORDEM" +;
                                   " and REC.Z0Y_TRATO = Z0W.Z0W_TRATO" +;
                                  " join " + RetSqlName("Z05") + " Z05" +;
                                    " on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" +;
                                   " and Z05.Z05_DATA   = Z0W.Z0W_DATA" +;
                                   " and Z05.Z05_VERSAO = Z0W.Z0W_VERSAO" +;
                                   " and Z05.Z05_LOTE   = Z0W.Z0W_LOTE" +;
                                   " and Z05.D_E_L_E_T_ = ' '" +;
                                  " join " + RetSqlName("Z0V") + " Z0V" +;
                                    " on Z0V.Z0V_FILIAL = '" + FWxFilial("Z0V") + "'" +;
                                   " and Z0V.Z0V_DATA   = Z0W.Z0W_DATA" +;
                                   " and Z0V.Z0V_VERSAO = Z0W.Z0W_VERSAO" +;
                                   " and Z0V.Z0V_COMP   = REC.Z0Y_COMP" +;
                                   " and Z0V.D_E_L_E_T_ = ' '" +;
                                 " where Z0W.Z0W_FILIAL = '" + FWxFilial("Z0W") + "' " +;
                                   " and Z0W.Z0W_DATINI <> '        '" +;
                                   " and Z0W.D_E_L_E_T_ = ' '" +;
                          " )" +;
                                " select PERIODO.DIA" +;
                                     " , Z05.Z05_DIETA" +;
                                     " , Z05.Z05_CABECA" +;
                                     " , Z05.Z05_KGMSDI" +;
                                     " , Z05.Z05_KGMNDI" +;
                                     " , Z05.Z05_MEGCAL" +;
                                     " , isnull(round(sum(QTD_MN_COMPONENTE_CABECA), 3), 0) QTD_MN" +;
                                     " , isnull(round(sum(QTD_MS_COMP_CABECA), 3), 0) QTD_MS" +;
                                  " from (values " + cDatas + ") PERIODO (DIA)" +;
                             " left join " + RetSqlName("Z0R") + " Z0R" +;
                                    " on Z0R.Z0R_FILIAL = '" + FWxFilial("Z0R") + "'" +;
                                   " and Z0R.Z0R_DATA   = PERIODO.DIA" +;
                                   " and Z0R.D_E_L_E_T_ = ' '" +;
                             " left join " + RetSqlName("Z05") + " Z05" +;
                                    " on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "' " +;
                                   " and Z05.Z05_DATA   = PERIODO.DIA" +;
                                   " and Z05.Z05_VERSAO = Z0R.Z0R_VERSAO" +;
                                   " and Z05.Z05_LOTE   = '" + Z05->Z05_LOTE + "'" +;
                                   " and Z05.D_E_L_E_T_ = ' '" +;
                             " left join REALIZADO REA" +;
                                    " on REA.Z0W_DATA   = Z05.Z05_DATA" +;
                                   " and REA.Z0W_LOTE   = Z05.Z05_LOTE" +;
                              " group by PERIODO.DIA" +;
                                     " , Z05.Z05_DIETA" +;
                                     " , Z05.Z05_CABECA" +;
                                     " , Z05.Z05_KGMSDI" +;
                                     " , Z05.Z05_MEGCAL" +;
                                     " , Z05.Z05_KGMNDI" +;
                              " order by PERIODO.DIA desc, Z05.Z05_DIETA" ;
                                      ),"TMPZ05", .F., .F.)

    while !TMPZ05->(Eof())
            AAdd(aRet, aClone(aTemplate))
            aRet[Len(aRet)][1] := 0
            aRet[Len(aRet)][2] := { SToD(TMPZ05->DIA); 
                                  , TMPZ05->Z05_DIETA;
                                  , TMPZ05->Z05_CABECA;
                                  , TMPZ05->Z05_KGMSDI;
                                  , TMPZ05->Z05_KGMNDI;
                                  , TMPZ05->QTD_MS;
                                  , TMPZ05->QTD_MN;
                                  , TMPZ05->Z05_MEGCAL } 
        TMPZ05->(DbSkip())
    end

TMPZ05->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif
return aRet


/*/{Protheus.doc} ViewDef
Tratamento da interface com o usuário
@author jr.andre
@since 13/09/2019
@version 1.0
@return object, objeto do tipo FwFormView
@type function
/*/
static function ViewDef()
local oModel   := nil
local oView    := nil

local oStrZ05C := nil
local oStrZ0IG := nil
local oStrZ05G := nil
local oStrZ06G := nil

if FunName() != "VAPCPA05" .or. !Empty((cTrbBrowse)->B8_LOTECTL) 

    PosCpoSX3(aCpoMdZ05F)

    oModel := ModelDef()

    oStrZ05C   := Z05FldVStr()
    oStrZ0IG   := Z0IGrdVStr()
    oStrZ05G   := Z05GrdVStr()
    oStrZ06G   := Z06GrdVStr()

    oView := FwFormView():New()
    oView:SetModel(oModel)
    
    oView:AddField("VwFieldZ05", oStrZ05C, "MdFieldZ05")
    oView:AddGrid("VwGridZ0I", oStrZ0IG, "MdGridZ0I")
    oView:AddGrid("VwGridZ05", oStrZ05G, "MdGridZ05")
    oView:AddGrid("VwGridZ06", oStrZ06G, "MdGridZ06")
    
    //static aCpoMdZ05F := { "Z05_DATA",   "Z05_VERSAO", "Z05_CURRAL", "Z05_LOTE",   "Z05_CABECA", "Z05_ORIGEM", "Z05_DIAPRO", "Z05_DIASDI", "Z05_MANUAL", "Z05_TOTMSC", "Z05_TOTMNC", "Z05_TOTMSI", "Z05_TOTMNI" }
    oStrZ05C:SetProperty("*",   MVC_VIEW_CANCHANGE, .F.)
    // oStrZ05C:SetProperty("Z05_TOTMSI", MVC_VIEW_CANCHANGE, .T.)
    
    oStrZ0IG:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
    oStrZ05G:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

    oView:CreateHorizontalBox("CABECALHO", 35)
    oView:CreateHorizontalBox("ITENS",     50)
    oView:CreateHorizontalBox("DETALHE",   15)

    oView:CreateVerticalBox("PROG", 50, "ITENS")
    oView:CreateVerticalBox("ANT",    50, "ITENS")

    oView:CreateHorizontalBox("COCHO",   50, "ANT")
    oView:CreateHorizontalBox("PRGANT",  50, "ANT")

    oView:SetOwnerView("VwFieldZ05", "CABECALHO")
    oView:SetOwnerView("VwGridZ0I",  "COCHO")
    oView:SetOwnerView("VwGridZ05", "PRGANT")
    oView:SetOwnerView("VwGridZ06",  "PROG")

    oView:SetCloseOnOk({||.T.})

    // Não permite remover linhas
    oView:SetNoInsertLine("VwGridZ0I")
    oView:SetNoInsertLine("VwGridZ05")
    oView:SetNoInsertLine("VwGridZ06")

    // Não permite excluir linhas
    oView:SetNoDeleteLine("VwGridZ0I")
    oView:SetNoDeleteLine("VwGridZ05")
    oView:SetNoDeleteLine("VwGridZ06")

    // Seta auto incremento
    // oView:AddIncrementField("VwGridZ06", "Z06_TRATO" ) 

    oView:EnableTitleView('VwFieldZ05', "Dados do Lote")
    oView:EnableTitleView('VwGridZ0I', "Manejo de Cocho")
    oView:EnableTitleView('VwGridZ05', "Programacao Anterior")
    oView:EnableTitleView('VwGridZ06', "Programacao")

    oView:AddUserButton( 'Mat Natural', 'CLIPS', {|oView| u_MatNat()}, "Mostra o detalhamento do calculo de matéria natural <F4>.", VK_F4,,.T.)
    SetKey(VK_F4, {|| u_MatNat()})
    if Inclui .or. Altera
        oView:AddUserButton( 'Reprogramar', 'CLIPS', {|oView| Reprograma()}, "Reprograma o trato de acordo com parâmetros <F5>.", VK_F5,,.T.)
        SetKey(VK_F5, {|| Reprograma()})
        if FunName() == "VAPCPA05" .and. IsInCallStack("u_vap05man")
            oView:AddUserButton( '<< Anterior', 'CLIPS', {|oView| Anterior(oView)}, "Carrega dados do trato do curral anterior <F6>.", VK_F6,,.T.)
            SetKey(VK_F6, {|| Anterior()})
            oView:AddUserButton( 'Próximo >>', 'CLIPS', {|oView| Proximo(oView)}, "Carrega dados do trato do próximo curral <F7>.", VK_F7,,.T.)
            SetKey(VK_F7, {|| Proximo()})
        endif
    endif


else
    Help(/*Descontinuado*/,/*Descontinuado*/,"SEM LOTE",/**/,"Não existe lote vinculado ao curral.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Não é possível atribuir um trato ao curral selecionado."})
endif

return oView


/*/{Protheus.doc} Anterior
Carrega o registro de trato anterior
@author guima
@since 13/09/2019
@version 1.0
@return nil
@param oView, object, descricao
@type function
/*/
static function Anterior(oView)
local nRecNo   := 0
local oModel   := FWModelActive()
local aAreaTMP := (cTrbBrowse)->(GetArea())
local aAreaZ05 := Z05->(GetArea())

default oView  := FWViewActive()

    while .T.

        nRecNo := (cTrbBrowse)->(RecNo())
        (cTrbBrowse)->(DbSkip(-1))
        if nRecNo == (cTrbBrowse)->(RecNo())

            Alert("Atingiu o primeiro registro...")

            // Reposiociona no primeiro Z05 Válido
            Z05->(RestArea(aAreaZ05))

            // Confirma a trava para edição
            CanUseZ05()

            // Reposiciona no browse
            (cTrbBrowse)->(RestArea(aAreaTMP))
            exit

        elseif Empty((cTrbBrowse)->B8_LOTECTL)
            // Não existe trato. Tentar pegar o próximo.
            loop
        else
            // Existe Lote
            DbSelectArea("Z05")
            DbSetOrder(1) // Z05_FILIAL+Z05_DATA+Z05_VERSAO+Z05_CURRAL+Z05_LOTE

            // Grava a posição da SX5
            aAreaZ05 := Z05->(GetArea())

            // Libera registro para edição
            ReleaseZ05()

            // Posiciona na Z05
            if Z05->(DbSeek(FWxFilial("Z05")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO+(cTrbBrowse)->Z08_CODIGO+(cTrbBrowse)->B8_LOTECTL)) 
                if CanUseZ05()
                    RecarTrato()
                    oBrowse:nAt--
                else
                    // Registro está em uso por outro usuário.
                    // Reposiociona no último Z05 Válido
                    Z05->(RestArea(aAreaZ05))
                    
                    // Confirma a trava para edição
                    CanUseZ05()

                    // Emite aviso de erro 
                    Help(/*Descontinuado*/,/*Descontinuado*/,"EM USO",/**/,"O registro selecionado na tabela Z05 está em uso.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Não é possível alterar o próximo registro até que ele seja liberado."})
                endif
            else
                // Não existe Trato para o registro
                // Chama a interface para criação
                
                /* Arthur Toshio - 13/07/2021 
                   Alteração na rotina para deixar semelhante a Função Proximo
                */
                /*
                if FillTrato()
                    RecarTrato()
                    ReleaseZ05()
                else
                */
                 if MsgYesNo("Não existe trato criado para o lote " + (cTrbBrowse)->B8_LOTECTL + " no curral " + (cTrbBrowse)->Z08_CODIGO + ". Deseja criar?", "Trato não encontrado.") .and. FillTrato()
                    RecarTrato()
                    ReleaseZ05()
                else
                    // Se for clicado no botão cancelar 
                    // Reposiociona no último Z05 Válido
                    Z05->(RestArea(aAreaZ05))
                    // Confirma a trava para edição
                    CanUseZ05()
                endif
            endif
            exit
        endif 

    end

return nil


/*/{Protheus.doc} Proximo
Carrega o proximo registro válido de trato
@author guima
@since 13/09/2019
@version 1.0
@return nil
@param oView, object, descricao
@type function
/*/
static function Proximo(oView)
local oModel   := FWModelActive()
local aAreaTMP := (cTrbBrowse)->(GetArea())
local aAreaZ05 := Z05->(GetArea())

default oView  := FWViewActive()

    while .T.
        (cTrbBrowse)->(DbSkip())
        if (cTrbBrowse)->(Eof())

            Alert("Atingiu o último registro...")

            // Reposiociona no último Z05 Válido
            Z05->(RestArea(aAreaZ05))
            
            // Confirma a trava para edição
            CanUseZ05()
            
            // Reposiciona no browse
            (cTrbBrowse)->(RestArea(aAreaTMP))
            exit

        elseif Empty((cTrbBrowse)->B8_LOTECTL)
            // Não existe trato. Tentar pegar o próximo.
            loop
        else
            // Existe Lote
            DbSelectArea("Z05")
            DbSetOrder(1) // Z05_FILIAL+Z05_DATA+Z05_VERSAO+Z05_CURRAL+Z05_LOTE

            // Grava a posição da SX5
            aAreaZ05 := Z05->(GetArea())

            // Libera registro para edição
            ReleaseZ05()

            // Posiciona na Z05
            if Z05->(DbSeek(FWxFilial("Z05")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO+(cTrbBrowse)->Z08_CODIGO+(cTrbBrowse)->B8_LOTECTL)) 
                if CanUseZ05()
                    RecarTrato()
                    oBrowse:nAt++ 
                else
                    // Registro está em uso por outro usuário.
                    // Reposiociona no último Z05 Válido
                    Z05->(RestArea(aAreaZ05))
                    // Confirma a trava para edição
                    CanUseZ05()

                    // Emite aviso de erro 
                    Help(/*Descontinuado*/,/*Descontinuado*/,"EM USO",/**/,"O registro selecionado na tabela Z05 está em uso.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Não é possível alterar o próximo registro até que ele seja liberado."})
                endif
            else
                // Não existe Trato para o registro
                // Chama a interface para criação
                if MsgYesNo("Não existe trato criado para o lote " + (cTrbBrowse)->B8_LOTECTL + " no curral " + (cTrbBrowse)->Z08_CODIGO + ". Deseja criar?", "Trato não encontrado.") .and. FillTrato()
                    RecarTrato()
                    ReleaseZ05()
                else
                    // Se for clicado no botão cancelar 
                    // Reposiociona no último Z05 Válido
                    Z05->(RestArea(aAreaZ05))
                    // Confirma a trava para edição
                    CanUseZ05()
                endif
            endif
            exit
        endif 
    end

return nil


/*/{Protheus.doc} RecarTrato
Recarrega os detalhes do trato 
@author guima
@since 13/09/2019
@version 1.0
@return nil
@type function
/*/
static function RecarTrato()
local oView  := FWViewActive()
local oModel := oView:GetModel()
local oFormModel, oGridModel
local i, j, nLen, nCpo

    oModel:getModel("MdGridZ0I"):SetNoInsertLine(.F.)
    oModel:getModel("MdGridZ05"):SetNoInsertLine(.F.)
    oModel:getModel("MdGridZ06"):SetNoInsertLine(.F.)
    oModel:getModel("MdGridZ0I"):SetNoDeleteLine(.F.)
    oModel:getModel("MdGridZ05"):SetNoDeleteLine(.F.)
    oModel:getModel("MdGridZ06"):SetNoDeleteLine(.F.)

    oFormModel := oModel:GetModel("MdFieldZ05")
    //static aCpoMdZ05F := { "Z05_DATA",   "Z05_VERSAO", "Z05_CURRAL", "Z05_LOTE",   "Z05_CABECA", "Z05_ORIGEM", "Z05_DIAPRO", "Z05_DIASDI", "Z05_MANUAL", "Z05_TOTMSC", "Z05_TOTMNC", "Z05_TOTMSI", "Z05_TOTMNI" }
    aDadosZ05 := LoadZ05()
    nCpo := Len(aCpoMdZ05F)
    for i := 1 to nCpo
        oFormModel:SetValue(aCpoMdZ05F[i], aDadosZ05[i])
    next

    // aCpoMdZ0IG := {"Z0I_DATA", "Z0I_NOTMAN", "Z0I_NOTTAR"}
    oGridModel := oModel:GetModel("MdGridZ0I")
    oGridModel:ClearData()
    
    aDadosZ0I := LoadZ0I()
    nLen := Len(aDadosZ0I)
    nCpo := Len(aCpoMdZ0IG)

    for i := 1 to nLen
        oGridModel:AddLine()
        oGridModel:GoLine(i)
        for j := 1 to nCpo
            oGridModel:SetValue(aCpoMdZ0IG[j], aDadosZ0I[i][2][j])
        next 
    next
    oGridModel:GoLine(1)

    // aCpoMdZ05G := {"Z05_DATA", "Z05_DIETA", "Z05_CABECA", "Z05_KGMSDI", "Z05_KGMNDI", "Z04_KGMSRE", "Z04_KGMNRE"}
    oGridModel := oModel:GetModel("MdGridZ05")
    oGridModel:ClearData()

    aDadosZ05Ant := LoadZ05Ant()
    nLen := Len(aDadosZ05Ant)
    nCpo := Len(aCpoMdZ05G)

    for i := 1 to nLen
        oGridModel:AddLine()
        oGridModel:GoLine(i)
        for j := 1 to nCpo
            oGridModel:SetValue(aCpoMdZ05G[j], aDadosZ05Ant[i][2][j])
        next 
    next
    oGridModel:GoLine(1)

    oGridModel := oModel:GetModel("MdGridZ06")
    oGridModel:ClearData()

    aDadosZ06 := LoadZ06()
    nLen := Len(aDadosZ06)
    nCpo := Len(aCpoMdZ06G)

    for i := 1 to nLen
        if !oGridModel:IsEmpty()
            oGridModel:AddLine()
            oView:Refresh()
        endif
        oGridModel:GoLine(i)
        for j := 1 to nCpo
            oGridModel:LoadValue(aCpoMdZ06G[j], aDadosZ06[i][2][j])
        next 
    next
    oGridModel:GoLine(1)

    oModel:getModel("MdGridZ0I"):SetNoInsertLine(.T.)
    oModel:getModel("MdGridZ05"):SetNoInsertLine(.T.)
    oModel:getModel("MdGridZ06"):SetNoInsertLine(.T.)
    oModel:getModel("MdGridZ0I"):SetNoDeleteLine(.T.)
    oModel:getModel("MdGridZ05"):SetNoDeleteLine(.T.)
    oModel:getModel("MdGridZ06"):SetNoDeleteLine(.T.)

    oView:Refresh()
return nil


/*/{Protheus.doc} Z05FldMStr
Cria a estrutura para o modelo do form Z05 na tela
@author jr.andre
@since 13/09/2019
@version 1.0
@return Object, modelo do form Z05 para a tela
@type function
/*/
static function Z05FldMStr()
local aArea   := GetArea()
local oStruct := FWFormModelStruct():New()
local i, nLen
local cValid, bValid, bWhen, aCbox, bRelacao
local aCpos   := {}

    SX3->(DbSetOrder(1)) // X3_ARQUIVO + X3_ORDEM
    SX3->(DbSeek("Z0501"))

    // AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL
    while !SX3->(Eof()) .and. SX3->X3_ARQUIVO == 'Z05'
        if aScan(aCpoMdZ05F, {|aMat| AllTrim(aMat) == AllTrim(SX3->X3_CAMPO)}) > 0 
            AAdd(aCpos, SX3->X3_CAMPO)
            cValid := Iif(!Empty(SX3->X3_VLDUSER), "(" + AllTrim(SX3->X3_VLDUSER) + ")", "") + Iif(!Empty(SX3->X3_VLDUSER).and.!Empty(SX3->X3_VALID), ".and.", "") + Iif(!EMpty(SX3->X3_VALID), "(" + AllTrim(SX3->X3_VALID) + ")", "")
            bValid := Iif(!Empty(cValid), FWBuildFeature(STRUCT_FEATURE_VALID, cValid), nil)
            bWhen := Iif(!Empty(SX3->X3_WHEN), FWBuildFeature(STRUCT_FEATURE_WHEN, SX3->X3_WHEN), nil)
            aCBox := Iif(!Empty(X3CBox()),StrToKArr(X3CBox(), ";"),nil)
            bRelacao := FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!Inclui," + SX3->X3_ARQUIVO + "->" + AllTrim(SX3->X3_CAMPO) + ",CriaVar('" + AllTrim(SX3->X3_CAMPO) + "',.T.))" )
            oStruct:AddField(;
                 X3Titulo(),;               // [01]  C   Titulo do campo
                 X3Descric(),;              // [02]  C   ToolTip do campo
                 AllTrim(SX3->X3_CAMPO),;   // [03]  C   Id do Field
                 TamSX3(SX3->X3_CAMPO)[3],; // [04]  C   Tipo do campo
                 TamSX3(SX3->X3_CAMPO)[1],; // [05]  N   Tamanho do campo
                 TamSX3(SX3->X3_CAMPO)[2],; // [06]  N   Decimal do campo
                 bValid,;                   // [07]  B   Code-block de validação do campo
                 bWhen,;                    // [08]  B   Code-block de validação When do campo
                 aCBox,;                    // [09]  A   Lista de valores permitido do campo
                 X3Obrigat(SX3->X3_CAMPO),; // [10]  L   Indica se o campo tem preenchimento obrigatório
                 bRelacao,;                 // [11]  B   Code-block de inicializacao do campo
                 .F.,;                      // [12]  L   Indica se trata-se de um campo chave
                 .F.,;                      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                 .F.)                       // [14]  L   Indica se o campo é virtual
        endif
        SX3->(DbSkip())
    end

    ConOut("Z05FldMStr: " + u_AToS(aCpos))

if !Empty(aArea)
    RestArea(aArea)
endif
return oStruct


/*/{Protheus.doc} Z0IGrdMStr
Cria a estrutura para o modelo da grid Z0I na tela
@author jr.andre
@since 13/09/2019
@version 1.0
@return Object, modelo da grid Z0I para a tela
@type function
/*/
static function Z0IGrdMStr()
local aArea   := GetArea()
local oStruct := FWFormModelStruct():New()
local i, nLen
local aCBox

    SX3->(DbSetOrder(2)) // X3_CAMPO
    nLen := Len(aCpoMdZ0IG)
    for i := 1 to nLen
        // AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL
        SX3->(DbSeek(aCpoMdZ0IG[i]))
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
             aCbox,;                    // [09]  A   Lista de valores permitido do campo
             .F.,;                      // [10]  L   Indica se o campo tem preenchimento obrigatorio
             nil,;                      // [11]  B   Code-block de inicializacao do campo
             .F.,;                      // [12]  L   Indica se trata-se de um campo chave
             .T.,;                      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
             .F.)                       // [14]  L   Indica se o campo é virtual
    next

return oStruct


/*/{Protheus.doc} Z05GrdMStr
Cria a estrutura para o modelo da grid Z05 na tela
@author jr.andre
@since 13/09/2019
@version 1.0
@return Object, modelo da grid Z0I para a tela
@type function
/*/
static function Z05GrdMStr()
local aArea   := GetArea()
local oStruct := FWFormModelStruct():New()
local aCBox
local i, nLen

    nLen := Len(aCpoMdZ05G)
    for i := 1 to nLen
        // AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL
        if aCpoMdZ05G[i]$"Z04_KGMSRE"
            oStruct:AddField(;
                 "Mat Seca Rea",;               // [01]  C   Titulo do campo
                 "Matéria Seca em KG Realis",;  // [02]  C   ToolTip do campo
                 "Z04_KGMSRE",;                 // [03]  C   Id do Field
                 "N",;                          // [04]  C   Tipo do campo
                  8,;                           // [05]  N   Tamanho do campo
                  2,;                           // [06]  N   Decimal do campo
                 nil,;                          // [07]  B   Code-block de validação do campo
                 nil,;                          // [08]  B   Code-block de validação When do campo
                 nil,;                          // [09]  A   Lista de valores permitido do campo
                 .F.,;                          // [10]  L   Indica se o campo tem preenchimento obrigatório
                 nil,;                          // [11]  B   Code-block de inicializacao do campo
                 .F.,;                          // [12]  L   Indica se trata-se de um campo chave
                 .T.,;                          // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                 .T.)                           // [14]  L   Indica se o campo é virtual
        elseif aCpoMdZ05G[i]$"Z04_KGMNRE"
            oStruct:AddField(;
                 "Mat Natu Rea",;               // [01]  C   Titulo do campo
                 "Mat Natural em KG Realis ",;  // [02]  C   ToolTip do campo
                 "Z04_KGMNRE",;                 // [03]  C   Id do Field
                 "N",;                          // [04]  C   Tipo do campo
                  8,;                           // [05]  N   Tamanho do campo
                  2,;                           // [06]  N   Decimal do campo
                 nil,;                          // [07]  B   Code-block de validação do campo
                 nil,;                          // [08]  B   Code-block de validação When do campo
                 nil,;                          // [09]  A   Lista de valores permitido do campo
                 .F.,;                          // [10]  L   Indica se o campo tem preenchimento obrigatório
                 nil,;                          // [11]  B   Code-block de inicializacao do campo
                 .F.,;                          // [12]  L   Indica se trata-se de um campo chave
                 .T.,;                          // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                 .T.)                           // [14]  L   Indica se o campo é virtual
        else
            SX3->(DbSetOrder(2))
            if SX3->(DbSeek(aCpoMdZ05G[i])) 
                aCBox := Iif(!Empty(X3CBox()),StrToKArr(X3CBox(), ";"),nil)
                oStruct:AddField(;
                     X3Titulo(),;               // [01]  C   Titulo do campo
                     X3Descric(),;              // [02]  C   ToolTip do campo
                     AllTrim(aCpoMdZ05G[i]),;   // [03]  C   Id do Field
                     TamSX3(SX3->X3_CAMPO)[3],; // [04]  C   Tipo do campo
                     TamSX3(SX3->X3_CAMPO)[1],; // [05]  N   Tamanho do campo
                     TamSX3(SX3->X3_CAMPO)[2],; // [06]  N   Decimal do campo
                     nil,;                      // [07]  B   Code-block de validação do campo
                     nil,;                      // [08]  B   Code-block de validação When do campo
                     aCBox,;                    // [09]  A   Lista de valores permitido do campo
                     .F.,;                      // [10]  L   Indica se o campo tem preenchimento obrigatório
                     nil,;                      // [11]  B   Code-block de inicializacao do campo
                     .F.,;                      // [12]  L   Indica se trata-se de um campo chave
                     .T.,;                      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                     .F.)                       // [14]  L   Indica se o campo é virtual
            else
                Help(/*Descontinuado*/,/*Descontinuado*/,"CAMPO NAO ENCONTRADO",/**/,"O campo " + aCpoMdZ05G[i] + " não foi encontrado no banco de dados. ", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, entre em contato com o TI." })
            endif
        endif
    next

return oStruct


/*/{Protheus.doc} Z06GrdMStr
Cria a estrutura para o modelo da grid Z06 na tela
@author jr.andre
@since 13/09/2019
@version 1.0
@return Object, modelo da grid Z06 para a tela
@type function
/*/
static function Z06GrdMStr()
local aArea   := GetArea()
local oStruct := FWFormModelStruct():New()
local i, nLen

    nLen := Len(aCpoMdZ06G)
    for i := 1 to nLen
        // AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL
        if aCpoMdZ06G[i]$"Z06_RECNO"
            oStruct:AddField(;
                 "Registro    ",;               // [01]  C   Titulo do campo
                 "Número do registro no ban",;  // [02]  C   ToolTip do campo
                 "Z06_RECNO",;                  // [03]  C   Id do Field
                 "N",;                          // [04]  C   Tipo do campo
                  14,;                          // [05]  N   Tamanho do campo
                  0,;                           // [06]  N   Decimal do campo
                 nil,;                          // [07]  B   Code-block de validação do campo
                 nil,;                          // [08]  B   Code-block de validação When do campo
                 nil,;                          // [09]  A   Lista de valores permitido do campo
                 .F.,;                          // [10]  L   Indica se o campo tem preenchimento obrigatório
                 nil,;                          // [11]  B   Code-block de inicializacao do campo
                 .F.,;                          // [12]  L   Indica se trata-se de um campo chave
                 .F.,;                          // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                 .T.)                           // [14]  L   Indica se o campo é virtual
        else
            SX3->(DbSetOrder(2))
            if SX3->(DbSeek(aCpoMdZ06G[i])) 
                if "Z06_" $ SX3->X3_CAMPO
                    cValid := Iif(!Empty(SX3->X3_VLDUSER), ;
                                  "(" + AllTrim(SX3->X3_VLDUSER) + ")",;
                                  ""); 
                            + Iif(!Empty(SX3->X3_VLDUSER).and.!Empty(SX3->X3_VALID),; 
                                  ".and.",; 
                                  ""); 
                            + Iif(!Empty(SX3->X3_VALID),;
                                  "(" + AllTrim(SX3->X3_VALID) + ")",;
                                  "") 
                endif
                oStruct:AddField(X3Titulo(),;                   // [01]  C   Titulo do campo
                                 X3Descric(),;                  // [02]  C   ToolTip do campo
                                 AllTrim(SX3->X3_CAMPO),;       // [03]  C   Id do Field
                                 TamSX3(SX3->X3_CAMPO)[3],;     // [04]  C   Tipo do campo
                                 TamSX3(SX3->X3_CAMPO)[1],;     // [05]  N   Tamanho do campo
                                 TamSX3(SX3->X3_CAMPO)[2],;     // [06]  N   Decimal do campo
                                 Iif(!Empty(cValid), FWBuildFeature(STRUCT_FEATURE_VALID, cValid), nil),; // [07]  B   Code-block de validação do campo
                                 Iif(!Empty(SX3->X3_WHEN), FWBuildFeature(STRUCT_FEATURE_WHEN, SX3->X3_WHEN), nil),; // [08]  B   Code-block de validação When do campo
                                 Iif(!Empty(X3CBox()),StrToKArr(X3CBox(), ";"),nil),; // [09]  A   Lista de valores permitido do campo
                                 X3Obrigat(SX3->X3_CAMPO),;     // [10]  L   Indica se o campo tem preenchimento obrigatório
                                 FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!Inclui," + SX3->X3_ARQUIVO + "->" + AllTrim(SX3->X3_CAMPO) + ",CriaVar('" + AllTrim(SX3->X3_CAMPO) + "',.T.))" ),; // [11]  B   Code-block de inicializacao do campo
                                 .F.,;                          // [12]  L   Indica se trata-se de um campo chave
                                 SX3->X3_VISUAL == 'A',;        // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                                 SX3->X3_CONTEXT == 'V')        // [14]  L   Indica se o campo é virtual
            else
                Help(/*Descontinuado*/,/*Descontinuado*/,"CAMPO NAO ENCONTRADO",/**/,"O campo " + aCpoMdZ06G[i] + " não foi encontrado no banco de dados. ", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, entre em contato com o TI." })
            endif
        endif
    next

return oStruct


/*/{Protheus.doc} Z05FldVStr
Cria a estrutura para o view do form Z05 na tela
@author jr.andre
@since 13/09/2019
@version 1.0
@return Object, view do form Z05 para a tela
@type function
/*/
static function Z05FldVStr()
local aArea   := GetArea()
local oStruct := FWFormViewStruct():New()
local i       := 0
local aCpos   := {}

// aCpoMdZ05F := { "Z05_DATA",   "Z05_VERSAO", "Z05_CURRAL", "Z05_LOTE",   "Z05_CABECA", "Z05_DIAPRO", "Z05_DIASDI", "Z05_MANUAL", "Z05_TOTMS",  "Z05_TOTMN" }
    SX3->(DbSetOrder(1))  // X3_CAMPO
    SX3->(DbSeek("Z0501"))
    
    while !SX3->(Eof()) .and. SX3->X3_ARQUIVO == "Z05"
        if AScan(aCpoMdZ05F, {|aMat| aMat == AllTrim(SX3->X3_CAMPO)}) > 0
            AAdd(aCpos, SX3->X3_CAMPO)
            oStruct:AddField(;
                AllTrim(SX3->X3_CAMPO),;        // [01]  C   Nome do Campo
                StrZero(++i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                X3Titulo(),;                    // [03]  C   Titulo do campo
                X3Descric(),;                   // [04]  C   Descricao do campo
                nil,;                           // [05]  A   Array com Help
                TamSX3(SX3->X3_CAMPO)[3],;      // [06]  C   Tipo do campo
                Iif(!Empty(SX3->X3_CAMPO), AllTrim(X3Picture(SX3->X3_CAMPO)), nil),;      // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                SX3->X3_F3,;                    // [09]  C   Consulta F3
                .T.,;                           // [10]  L   Indica se o campo é alteravel
                nil,;                           // [11]  C   Pasta do campo
                nil,;                           // [12]  C   Agrupamento do campo
                Iif(!Empty(X3CBox()),StrToKArr(X3CBox(), ";"),nil),; // [13]  A   Lista de valores permitido do campo (Combo)
                Iif(!Empty(X3CBox()), 10, nil),; // [14]  N   Tamanho máximo da maior opção do combo
                nil,;                           // [15]  C   Inicializador de Browse
                nil,;                           // [16]  L   Indica se o campo é virtual
                nil,;                           // [17]  C   Picture Variável
                nil;                            // [18]  L   Indica pulo de linha após o campo
            )
        endif
        SX3->(DbSkip())
    end

    ConOut("Z05FldVStr: " + u_AToS(aCpos))

if !Empty(aArea)
    RestArea(aArea)
endif
return oStruct


/*/{Protheus.doc} Z0IGrdVStr
Cria a estrutura para o view da grid Z0I na tela
@author jr.andre
@since 13/09/2019
@version 1.0
@return Object, view da grid Z0I para a tela
@type function
/*/
static function Z0IGrdVStr()
local aArea   := GetArea()
local oStruct := FWFormViewStruct():New()
local i, nLen

DbSelectArea("SX3")
DbSetOrder(2)  // X3_CAMPO

// aCpoMdZ0IG := { "Z0I_DATA",   "Z0I_NOTMAN", "Z0I_NOTTAR" }
    nLen := Len(aCpoMdZ0IG)
    for i := 1 to nLen
        SX3->(DbSetOrder(2))
        if SX3->(DbSeek(Padr(aCpoMdZ0IG[i], Len(SX3->X3_CAMPO))))
            oStruct:AddField(;
                AllTrim(aCpoMdZ0IG[i]),;        // [01]  C   Nome do Campo
                StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                AllTrim(X3Titulo()),;           // [03]  C   Titulo do campo
                X3Descric(),;                   // [04]  C   Descricao do campo
                {"Help"},;                      // [05]  A   Array com Help
                TamSX3(SX3->X3_CAMPO)[3],;      // [06]  C   Tipo do campo
                Iif(!Empty(SX3->X3_CAMPO), AllTrim(X3Picture(SX3->X3_CAMPO)), nil),;      // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                SX3->X3_F3,;                    // [09]  C   Consulta F3
                .F.,;                           // [10]  L   Indica se o campo é alteravel
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

if !Empty(aArea)
    RestArea(aArea)
endif
return oStruct


/*/{Protheus.doc} Z05GrdVStr
Cria a estrutura para o view da grid Z05 na tela
@author jr.andre
@since 13/09/2019
@version 1.0
@return Object, view da grid Z05 para a tela
@type function
/*/
static function Z05GrdVStr()
local aArea   := GetArea()
local oStruct := FWFormViewStruct():New()
local i, nLen

DbSelectArea("SX3")
DbSetOrder(2)  // X3_CAMPO

// aCpoMdZ05G := { "Z05_DATA",   "Z05_DIETA",  "Z05_CABECA", "Z05_KGMSDI", "Z05_KGMNDI", "Z04_KGMSRE", "Z04_KGMNRE" }
    nLen := Len(aCpoMdZ05G)
    for i := 1 to nLen
        SX3->(DbSetOrder(2))
        if aCpoMdZ05G[i]$"Z04_KGMSRE"
            oStruct:AddField(;
                "Z04_KGMSRE",;                  // [01]  C   Nome do Campo
                StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                "Mat Seca Rea",;                // [03]  C   Titulo do campo
                "Matéria Seca em KG Realis",;   // [04]  C   Descricao do campo
                {"Help"},;                      // [05]  A   Array com Help
                "N",;                           // [06]  C   Tipo do campo
                "@E 99,999.99",;                // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                nil,;                           // [09]  C   Consulta F3
                .F.,;                           // [10]  L   Indica se o campo é alteravel
                nil,;                           // [11]  C   Pasta do campo
                nil,;                           // [12]  C   Agrupamento do campo
                nil,;                           // [13]  A   Lista de valores permitido do campo (Combo)
                nil,;                           // [14]  N   Tamanho máximo da maior opção do combo
                nil,;                           // [15]  C   Inicializador de Browse
                nil,;                           // [16]  L   Indica se o campo é virtual
                nil,;                           // [17]  C   Picture Variável
                nil;                            // [18]  L   Indica pulo de linha após o campo
            )
        elseif aCpoMdZ05G[i]$"Z04_KGMNRE"
            oStruct:AddField(;
                "Z04_KGMNRE",;                  // [01]  C   Nome do Campo
                StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                "Mat Natu Rea",;                // [03]  C   Titulo do campo
                "Mat Natural em KG Realis ",;   // [04]  C   Descricao do campo
                {"Help"},;                      // [05]  A   Array com Help
                "N",;                           // [06]  C   Tipo do campo
                "@E 99,999.99",;                // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                nil,;                           // [09]  C   Consulta F3
                .F.,;                           // [10]  L   Indica se o campo é alteravel
                nil,;                           // [11]  C   Pasta do campo
                nil,;                           // [12]  C   Agrupamento do campo
                nil,;                           // [13]  A   Lista de valores permitido do campo (Combo)
                nil,;                           // [14]  N   Tamanho máximo da maior opção do combo
                nil,;                           // [15]  C   Inicializador de Browse
                nil,;                           // [16]  L   Indica se o campo é virtual
                nil,;                           // [17]  C   Picture Variável
                nil;                            // [18]  L   Indica pulo de linha após o campo
            )
        elseif SX3->(DbSeek(Padr(aCpoMdZ05G[i], Len(SX3->X3_CAMPO))))
            oStruct:AddField(;
                AllTrim(aCpoMdZ05G[i]),;             // [01]  C   Nome do Campo
                StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                AllTrim(X3Titulo()),;           // [03]  C   Titulo do campo
                X3Descric(),;                   // [04]  C   Descricao do campo
                {"Help"},;                      // [05]  A   Array com Help
                TamSX3(SX3->X3_CAMPO)[3],;      // [06]  C   Tipo do campo
                Iif(!Empty(SX3->X3_CAMPO), AllTrim(X3Picture(SX3->X3_CAMPO)), nil),;      // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                SX3->X3_F3,;                    // [09]  C   Consulta F3
                .F.,;           // [10]  L   Indica se o campo é alteravel
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

    oStruct:SetProperty("Z05_DIETA", MVC_VIEW_WIDTH, 200)

if !Empty(aArea)
    RestArea(aArea)
endif
return oStruct


/*/{Protheus.doc} Z06GrdVStr
Cria a estrutura para o view da grid Z06 na tela
@author jr.andre
@since 13/09/2019
@version 1.0
@return Object, view da grid Z06 para a tela
@type function
/*/
static function Z06GrdVStr()
local aArea   := GetArea()
local oStruct := FWFormViewStruct():New()
local i, nLen

DbSelectArea("SX3")
DbSetOrder(2)  // X3_CAMPO

    // aCpoMdZ06G := { "Z06_TRATO",  "Z06_DIETA",  "Z06_KGMSTR", "Z06_KGMNTR", "Z06_RECNO" }
    nLen := Len(aCpoMdZ06G)
    for i := 1 to nLen
        SX3->(DbSetOrder(2))
        if aCpoMdZ06G[i]$"Z06_RECNO"
            oStruct:AddField(;
                "Z06_RECNO",;                   // [01]  C   Nome do Campo
                StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                "Reg no Banco",;                // [03]  C   Titulo do campo
                "Posic do Registro no Banco",;  // [04]  C   Descricao do campo
                {"Help"},;                      // [05]  A   Array com Help
                "N",;                           // [06]  C   Tipo do campo
                "",;                            // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                nil,;                           // [09]  C   Consulta F3
                .F.,;                           // [10]  L   Indica se o campo é alteravel
                nil,;                           // [11]  C   Pasta do campo
                nil,;                           // [12]  C   Agrupamento do campo
                nil,;                           // [13]  A   Lista de valores permitido do campo (Combo)
                nil,;                           // [14]  N   Tamanho máximo da maior opção do combo
                nil,;                           // [15]  C   Inicializador de Browse
                nil,;                           // [16]  L   Indica se o campo é virtual
                nil,;                           // [17]  C   Picture Variável
                nil;                            // [18]  L   Indica pulo de linha após o campo
            )
        elseif SX3->(DbSeek(Padr(aCpoMdZ06G[i], Len(SX3->X3_CAMPO))))
            oStruct:AddField(;
                AllTrim(aCpoMdZ06G[i]),;        // [01]  C   Nome do Campo
                StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
                AllTrim(X3Titulo()),;           // [03]  C   Titulo do campo
                X3Descric(),;                   // [04]  C   Descricao do campo
                {"Help"},;                      // [05]  A   Array com Help
                TamSX3(SX3->X3_CAMPO)[3],;      // [06]  C   Tipo do campo
                Iif(!Empty(SX3->X3_CAMPO), AllTrim(X3Picture(SX3->X3_CAMPO)), nil),;      // [07]  C   Picture
                nil,;                           // [08]  B   Bloco de PictTre Var
                SX3->X3_F3,;                    // [09]  C   Consulta F3
                !AllTrim(SX3->X3_CAMPO)$"Z06_KGMNTR",;//!AllTrim(SX3->X3_CAMPO)$"Z06_KGMNTR|Z06_TRATO",;  // [10]  L   Indica se o campo é alteravel
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

if !Empty(aArea)
    RestArea(aArea)
endif
return oStruct


/*/{Protheus.doc} Persiste
Atualiza o campo passado por parametro no registro posicionado
@author jr.andre
@since 13/09/2019
@version 1.0
@return nil
@param cTbl, characters, Alias da tabela
@param cCampo, characters, Campo
@param xValor, , Valor a ser atualizado
@type function
/*/
static function Persiste(cTbl, cCampo, xValor)
local aArea := GetArea()
    RecLock(cTbl, .F.)
        &(cTbl + "->" + cCampo) := xValor
    MsUnlock()
    if !Empty(aArea)
        RestArea(aArea)
    endif
return nil


/*/{Protheus.doc} AtuSX1
Cria dinamicamente as perguntas usadas pela rotina
@author jr.andre
@since 13/09/2019
@version 1.0
@return nil
@param cPerg, characters, Código da pergunta a ser criada
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

cPerg          := PadR(cPerg, Len(SX1->X1_GRUPO))

if !SX1->( DbSeek( cPerg ) )

    aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
                 "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
                 "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
                 "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
                 "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
                 "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
                 "X1_IDFIL"  }
    
    if cPerg == "VAPCPA05  "
                                 //123456789012345678901234567890 
        AAdd( aDados, {cPerg,'01','Data do trato?                ','Data do trato?                ','Data do trato?                ','mv_ch1','D', 8,0,0,'G','','mv_par01','','','','','','','','','','','','','','','','','','','','','','','','','      ','S','','','',            '', {"Informe a data do trato.", "Informe a data do trato.", "Informe a data do trato."}} )
        
    elseif cPerg == "VAPCPA051 "
    
        AAdd( aDados, {cPerg,'01','Dieta?                        ','Dieta?                        ','Dieta?                        ','mv_ch1','C',30,0,0,'G','','mv_par01','','','','','','','','','','','','','','','','','','','','','','','','','DIETA ','S','','','',            '', {"Informe ou selecione a dieta para o trato." + CRLF + "<F3 Disponível>", "Informe ou selecione a dieta para o trato." + CRLF + "<F3 Disponível>", "Informe ou selecione a dieta para o trato." + CRLF + "<F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'02','Qtde Mat Seca em Kg?          ','Qtde Mat Seca em Kg?          ','Qtde Mat Seca em Kg?          ','mv_ch2','N', 8,2,0,'G','','mv_par02','','','','','','','','','','','','','','','','','','','','','','','','','      ','S','','','@E 99,999.99','', {"Informe a quantidade total de ração que será servida no dia.", "Informe a quantidade total de ração que será servida no dia.", "Informe a quantidade total de ração que será servida no dia."}} )
        AAdd( aDados, {cPerg,'03','Número de tratos?             ','Número de tratos?             ','Número de tratos?             ','mv_ch3','N', 1,0,0,'G','','mv_par03','','','','','','','','','','','','','','','','','','','','','','','','','      ','S','','','@E 9',        '', {"Informe em quantos tratos a ração que será servida durante o dia.", "Informe em quantos tratos a ração que será servida durante o dia.", "Informe em quantos tratos a ração que será servida durante o dia."}} )
    
    elseif cPerg == "VAPCPA052 "
    
        AAdd( aDados, {cPerg,'01','Qtde Mat Seca em Kg?          ','Qtde Mat Seca em Kg?          ','Qtde Mat Seca em Kg?          ','mv_ch1','N', 8,2,0,'G','','mv_par01','','','','','','','','','','','','','','','','','','','','','','','','','      ','S','','','@E 99,999.99','', {"Informe a quantidade total de ração que será servida entre os tratos do dia.", "Informe a quantidade total de ração que será servida entre os tratos do dia.", "Informe a quantidade total de ração que será servida entre os tratos do dia."}} )
    
    elseif cPerg == "VAPCPA053 "
    
        AAdd( aDados, {cPerg,'01','Número de tratos?             ','Número de tratos?             ','Número de tratos?             ','mv_ch1','N', 1,0,0,'G','','mv_par01','','','','','','','','','','','','','','','','','','','','','','','','','      ','S','','','@E 9',        '', {"Informe em quantos tratos a ração que será servida durante o dia.", "Informe em quantos tratos a ração que será servida durante o dia.", "Informe em quantos tratos a ração que será servida durante o dia."}} )
        AAdd( aDados, {cPerg,'02','Rota de?                      ','Rota de?                      ','Rota de?                      ','mv_ch2','C',TamSX3('ZRT_ROTA')[1],0,0,'G','','mv_par02','','','','','','','','','','','','','','','','','','','','','','','','','ZRT   ','S','','','',            '', {"Informe a rota inicial para o filtro. <F3 Disponível>", "Informe a rota inicial para o filtro. <F3 Disponível>", "Informe a rota inicial para o filtro. <F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'03','Rota até?                     ','Rota até?                     ','Rota até?                     ','mv_ch3','C',TamSX3('ZRT_ROTA')[1],0,0,'G','','mv_par03','','','','','','','','','','','','','','','','','','','','','','','','','ZRT   ','S','','','',            '', {"Informe a rota final para o filtro. <F3 Disponível>", "Informe a rota final para o filtro. <F3 Disponível>", "Informe a rota final para o filtro. <F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'04','Curral de?                    ','Curral de?                    ','Curral de?                    ','mv_ch4','C',20,0,0,'G','','mv_par02','','','','','','','','','','','','','','','','','','','','','','','','','Z08   ','S','','','',            '', {"Informe o curral inicial para o filtro. <F3 Disponível>", "Informe o curral inicial para o filtro. <F3 Disponível>", "Informe o curral inicial para o filtro. <F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'05','Curral até?                   ','Curral até?                   ','Curral até?                   ','mv_ch5','C',20,0,0,'G','','mv_par03','','','','','','','','','','','','','','','','','','','','','','','','','Z08   ','S','','','',            '', {"Informe o curral final para o filtro. <F3 Disponível>", "Informe o curral final para o filtro. <F3 Disponível>", "Informe o curral final para o filtro. <F3 Disponível>"}} )

    elseif cPerg == "VAPCPA054 "
    
        AAdd( aDados, {cPerg,'01','Curral?                       ','Curral?                       ','Curral?                       ','mv_ch1','C',20,0,0,'G','','mv_par01','','','','','','','','','','','','','','','','','','','','','','','','','Z08LIV','S','','','',            '', {"Informe ou selecione um curral vazio." + CRLF + "<F3 Disponível>", "Informe ou selecione um curral vazio." + CRLF + "<F3 Disponível>", "Informe ou selecione um curral vazio." + CRLF + "<F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'02','Lote?                         ','Lote?                         ','Lote?                         ','mv_ch2','C',10,0,0,'G','','mv_par02','','','','','','','','','','','','','','','','','','','','','','','','','SB8P05','S','','','',            '', {"Informe ou selecione um lote que tenha pertencido a esse curral." + CRLF + "<F3 Disponível>", "Informe ou selecione um lote que tenha pertencido a esse curral." + CRLF + "<F3 Disponível>", "Informe ou selecione um lote que tenha pertencido a esse curral." + CRLF + "<F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'03','Dieta?                        ','Dieta?                        ','Dieta?                        ','mv_ch3','C',30,0,0,'G','','mv_par03','','','','','','','','','','','','','','','','','','','','','','','','','DIETA ','S','','','',            '', {"Informe ou selecione a dieta para o trato." + CRLF + "<F3 Disponível>", "Informe ou selecione a dieta para o trato." + CRLF + "<F3 Disponível>", "Informe ou selecione a dieta para o trato." + CRLF + "<F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'04','Qtde Mat Seca em Kg?          ','Qtde Mat Seca em Kg?          ','Qtde Mat Seca em Kg?          ','mv_ch4','N', 8,2,0,'G','','mv_par04','','','','','','','','','','','','','','','','','','','','','','','','','      ','S','','','@E 99,999.99','', {"Informe a quantidade total de ração que será servida no dia.", "Informe a quantidade total de ração que será servida no dia.", "Informe a quantidade total de ração que será servida no dia."}} )
        AAdd( aDados, {cPerg,'05','Número de tratos?             ','Número de tratos?             ','Número de tratos?             ','mv_ch5','N', 1,0,0,'G','','mv_par05','','','','','','','','','','','','','','','','','','','','','','','','','      ','S','','','@E 9',        '', {"Informe em quantos tratos a ração que será servida durante o dia.", "Informe em quantos tratos a ração que será servida durante o dia.", "Informe em quantos tratos a ração que será servida durante o dia."}} )
        AAdd( aDados, {cPerg,'06','Qtde de Cabeças?              ','Quantidade de Cabeças?        ','Quantidade de Cabeças?        ','mv_ch6','N', 3,0,0,'G','','mv_par06','','','','','','','','','','','','','','','','','','','','','','','','','      ','S','','','@E 999',      '', {"Informe a quantidade de cabeças que estão no curral.", "Informe a quantidade de cabeças que estão no curral.", "Informe a quantidade de cabeças que estão no curral."}} )
    
    elseif cPerg == "VAPCPA055 "

        AAdd( aDados, {cPerg,'01','Rota de?                      ','Rota de?                      ','Rota de?                      ','mv_ch1','C',TamSX3("Z05_ROTEIR")[1],0,0,'G','','mv_par01','','','','','','','','','','','','','','','','','','','','','','','','','ZRT   ','S','','','','', {"Informe a rota inicial para o filtro." + CRLF + "<F3 Disponível>", "Informe a rota inicial para o filtro.", "Informe a data do trato para o filtro."}} )
        AAdd( aDados, {cPerg,'02','Rota até?                     ','Rota até?                     ','Rota até?                     ','mv_ch2','C',TamSX3("Z05_ROTEIR")[1],0,0,'G','','mv_par02','','','','','','','','','','','','','','','','','','','','','','','','','ZRT   ','S','','','','', {"Informe a rota final para o filtro." + CRLF + "<F3 Disponível>", "Informe a rota final para o filtro." + CRLF + "<F3 Disponível>", "Informe a data do trato para o filtro." + CRLF + "<F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'03','Curral de?                    ','Curral de?                    ','Curral de?                    ','mv_ch3','C',20,0,0,'G','','mv_par03','','','','','','','','','','','','','','','','','','','','','','','','','Z08   ','S','','','','', {"Informe o curral inicial para o filtro." + CRLF + "<F3 Disponível>", "Informe o curral inicial para o filtro." + CRLF + "<F3 Disponível>", "Informe o curral inicial para o filtro." + CRLF + "<F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'04','Curral até?                   ','Curral até?                   ','Curral até?                   ','mv_ch4','C',20,0,0,'G','','mv_par04','','','','','','','','','','','','','','','','','','','','','','','','','Z08   ','S','','','','', {"Informe o curral final para o filtro." + CRLF + "<F3 Disponível>", "Informe o curral final para o filtro." + CRLF + "<F3 Disponível>", "Informe o curral final para o filtro." + CRLF + "<F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'05','Lote de?                      ','Lote de?                      ','Lote de?                      ','mv_ch5','C',10,0,0,'G','','mv_par05','','','','','','','','','','','','','','','','','','','','','','','','','LOTES ','S','','','','', {"Informe o lote inicial para o filtro." + CRLF + "<F3 Disponível>", "Informe o lote inicial para o filtro." + CRLF + "<F3 Disponível>", "Informe o lote inicial para o filtro." + CRLF + "<F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'06','Lote até?                     ','Lote até?                     ','Lote até?                     ','mv_ch6','C',10,0,0,'G','','mv_par06','','','','','','','','','','','','','','','','','','','','','','','','','LOTES ','S','','','','', {"Informe o lote final para o filtro." + CRLF + "<F3 Disponível>", "Informe o lote final para o filtro." + CRLF + "<F3 Disponível>", "Informe o lote final para o filtro." + CRLF + "<F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'07','Veículo de?                   ','Veículo de?                   ','Veículo de?                   ','mv_ch7','C', 6,0,0,'G','','mv_par07','','','','','','','','','','','','','','','','','','','','','','','','','ZV0VEI','S','','','','', {"Informe o veículo inicial para o filtro." + CRLF + "<F3 Disponível>", "Informe o veículo inicial para o filtro." + CRLF + "<F3 Disponível>", "Informe o veículo inicial para o filtro." + CRLF + "<F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'08','Veículo até?                  ','Veículo até?                  ','Veículo até?                  ','mv_ch8','C', 6,0,0,'G','','mv_par08','','','','','','','','','','','','','','','','','','','','','','','','','ZV0VEI','S','','','','', {"Informe o veículo final para o filtro." + CRLF + "<F3 Disponível>", "Informe o veículo final para o filtro." + CRLF + "<F3 Disponível>", "Informe o veículo final para o filtro." + CRLF + "<F3 Disponível>"}} )
        
    elseif cPerg == "VAPCPA05A "
        AAdd( aDados, {cPerg,'01','Curral de?                    ','Curral de?                    ','Curral de?                    ','mv_ch1','C',20,0,0,'G','','mv_par01','','','','','','','','','','','','','','','','','','','','','','','','','Z08   ','S','','','','', {"Informe o curral inicial para o filtro." + CRLF + "<F3 Disponível>", "Informe o curral inicial para o filtro." + CRLF + "<F3 Disponível>", "Informe o curral inicial para o filtro." + CRLF + "<F3 Disponível>"}} )
        AAdd( aDados, {cPerg,'02','Curral Ate?                   ','Curral de?                    ','Curral de?                    ','mv_ch2','C',20,0,0,'G','','mv_par02','','','','','','','','','','','','','','','','','','','','','','','','','Z08   ','S','','','','', {"Informe o curral inicial para o filtro." + CRLF + "<F3 Disponível>", "Informe o curral inicial para o filtro." + CRLF + "<F3 Disponível>", "Informe o curral inicial para o filtro." + CRLF + "<F3 Disponível>"}} )
        
    endif

    DbSelectArea( "SX1" )
    SX1->( DbSetOrder( 1 ) )
    
    nLenLin := Len( aDados )
    for i := 1 to nLenLin
        if !SX1->( DbSeek( PadR( aDados[i][1], nTam1 ) + PadR( aDados[i][2], nTam2 ) ) )
            RecLock( "SX1", .T. )
            nLenCol := Len( aEstrut )
            for j := 1 to nLenCol
                if aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[j], 10 ) } ) > 0
                    SX1->( FieldPut( FieldPos( aEstrut[j] ), aDados[i][j] ) )
                endif
            next
            MsUnLock()
            u_UpSX1Hlp("P." + AllTrim(SX1->X1_GRUPO) + AllTrim(SX1->X1_ORDEM) + ".", aDados[i][nLenCol+1], .T.)
        endif
    next
endif

Pergunte(cPerg, .F.)

RestArea( aAreaDic )
RestArea( aArea )

return nil


/*/{Protheus.doc} vpcp05f3
Monta interface para o F3 baseado em query
@author guima
@since 13/09/2019
@version 1.0
@return Logico, .T. se pressionado o botão OK

@type function
/*/
user function vpcp05f3()
local lRet   := .F.
local aArea  := GetArea()
local cQuery := ""
local cCampo := ReadVar()
//local oModel := nil
//local oGridModel := nil

if Type("uRetorno") == 'U' 
    public uRetorno
endif
uRetorno := ''

/*
if "Z08_LINHA" $ cCampo

    cQuery := " select Z08.Z08_LINHA, min(Z08.R_E_C_N_O_) Z08RECNO" +;
                " from " + RetSqlName("Z08") + " Z08" +;
               " where Z08.Z08_FILIAL = '" + FWxFilial("Z08") + "'" +;
                 " and Z08.Z08_CONFNA <> '  '" +;
                 " and Z08.D_E_L_E_T_ = ' '" +;
            " group by Z08.Z08_LINHA" +;
            " order by Z08.Z08_LINHA"
    
    if u_F3Qry( cQuery, 'VPCA05', 'Z08RECNO', @uRetorno,, { "Z08_LINHA" } )
        Z08->(DbGoto( uRetorno ))
        lRet := .T.
    endif
    
else
*/
if "MV_PAR02" $ cCampo

    cQuery := " select SB8.B8_LOTECTL, max(SB8.R_E_C_N_O_) SB8RECNO" +;
                " from " + RetSqlName("SB8") + " SB8" +;
           " left join (" +;
                      " select distinct B8_LOTECTL" +;
                        " from " + RetSqlName("SB8") +;
                        " where B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                          " and B8_SALDO   > 0" +;
                          " and D_E_L_E_T_ = ' '" +;
                     " ) SLD" +;
                  " on SB8.B8_LOTECTL = SLD.B8_LOTECTL" +;
               " where SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                 " and SB8.B8_SALDO   = 0" +;
                 " and SB8.B8_X_CURRA = '" + mv_par01 + "'" +;
                 " and SLD.B8_LOTECTL is null" +;
                 " and SB8.D_E_L_E_T_ = ' '" +;
            " group by SB8.B8_LOTECTL" +;
            " order by SB8.B8_LOTECTL"

    if u_F3Qry( cQuery, 'SB8P05', 'SB8RECNO', @uRetorno,, { "B8_LOTECTL, SB8RECNO" } )
        SB8->(DbGoto( uRetorno ))
        lRet := .T.
    endif

elseif "MV_PAR01" $ cCampo

    cQuery := " select Z08_CODIGO, Z08.R_E_C_N_O_ Z08RECNO" + CRLF +;
                " from " + RetSqlName("Z08") + " Z08" + CRLF +;
           " left join (" + CRLF +;
                       " select B8_FILIAL, B8_LOTECTL, B8_X_CURRA" + CRLF +;
                         " from " + RetSqlName("SB8") + " SB8" + CRLF +;
                         " where SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" + CRLF +;
                          " and SB8.D_E_L_E_T_ = ' '" + CRLF +;
                     " group by B8_FILIAL, B8_LOTECTL, B8_X_CURRA" + CRLF +;
                       " having sum(B8_SALDO) > 0" + CRLF +;
                     " ) SB8" + CRLF +;
                  " on SB8.B8_X_CURRA = Z08.Z08_CODIGO" + CRLF +;
           " left join " + RetSqlName("Z05") + " Z05" + CRLF +;
                  " on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" + CRLF +;
                 " and Z05.Z05_CURRAL = Z08.Z08_CODIGO" + CRLF +;
                 " and Z05.Z05_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                 " and Z05.Z05_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                 " and Z05.D_E_L_E_T_ = ' '" + CRLF +;
               " where Z08.Z08_FILIAL = '" + FWxFilial("Z08") + "'" + CRLF +;
                 " and Z08.Z08_MSBLQL <> '1'" + CRLF +;
                 " and Z05.Z05_FILIAL is null" + CRLF +;
                 " and SB8.B8_FILIAL is null" + CRLF +;
                 " and Z08.D_E_L_E_T_ = ' '" + CRLF +;
            " order by 1"

    if u_F3Qry( cQuery, 'Z08LIV', 'Z08RECNO', @uRetorno,, { "Z08_CODIGO, Z08RECNO" } )
        Z08->(DbGoto( uRetorno ))
        lRet := .T.
    endif

endif

if aArea[1] <> "Z0M"
    RestArea( aArea )
endif
return lRet


/*/{Protheus.doc} UpSX1Hlp
Função de processamento da gravação dos Helps de Perguntas
@author jr.andre
@since  21/11/2018
@version 1.0
/*/
user function UpSX1Hlp(cKey, aHelp, lUpdate)
local cFilePor  := "SIGAHLP.HLP"
local cFileEng  := "SIGAHLE.HLE"
local cFileSpa  := "SIGAHLS.HLS"
local nRet      := 0
local cHelp     := ""
local i, nLen
default cKey    := ""
default aHelp   := nil
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

    // InglÃªs
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


/*/{Protheus.doc} LogTrato
Grava log das operações realizadas no trato no campo Z0R_LOG.
@author jr.andre
@since 13/09/2019
@version 1.0
@return nil
@param cTitulo, characters, titulo do log
@param cMsg, characters, descrição do log
@type function
/*/
static function LogTrato(cTitulo, cMsg)
local aArea := GetArea()
    RecLock("Z0R", .F.)
    Z0R->Z0R_LOG += MsgLog(cTitulo, cMsg)
    MsUnlock()
    if !Empty(aArea)
        RestArea(aArea)
    endif
return nil 


/*/{Protheus.doc} MsgLog
Formata a mensagem de log
@author guima
@since 13/09/2019
@version 1.0
@return character, Mensagem de log formatada
@param cTitulo, characters, Titulo do log
@param cMsg, characters, descricao do log
@type function
/*/
static function MsgLog(cTitulo, cMsg)
return Replicate("#", 80) + CRLF +;
       DToS(Date()) + "-" + Time() + CRLF +;
       cUserName + CRLF +;
       cTitulo + CRLF +;
       cMsg + CRLF + CRLF

user function CalcQtMS(cLote, dDtTrato, cVersao) 
local aArea  := GetArea()
local nQtdMS := 0

    DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                              " with QTDPROD as (" +;
                                " select Z0Y.Z0Y_ORDEM, Z0Y.Z0Y_TRATO, sum(Z0Y_QTDREA) PRD_QUANT" +;
                                  " from " + RetSqlName("Z0Y") + " Z0Y" +;
                                 " where Z0Y.Z0Y_FILIAL = '" + FWxFilial("Z0Y") + "'" +;
                                   " and Z0Y.Z0Y_DATINI <> '        '" +;
                                   " and Z0Y.Z0Y_DATA   = '" + DToS(dDtTrato) + "'" +;
                                   " and Z0Y.D_E_L_E_T_ = ' '" +;
                              " group by Z0Y.Z0Y_ORDEM, Z0Y.Z0Y_TRATO" +;
                          " )," +;
                          " QTDTRATO as (" +;
                                " select Z0W.Z0W_ORDEM, Z0W.Z0W_TRATO, sum(Z0W.Z0W_QTDREA) TRT_QUANT" +;
                                  " from " + RetSqlName("Z0W") + " Z0W" +;
                                 " where Z0W.Z0W_FILIAL = '" + FWxFilial("Z0W") + "'" +;
                                   " and Z0W.Z0W_DATINI <> '        '" +;
                                   " and Z0W.Z0W_DATA   = '" + DToS(dDtTrato) + "'" +;
                                   " and Z0W.D_E_L_E_T_ = ' '" +;
                              " group by Z0W.Z0W_ORDEM, Z0W.Z0W_TRATO" +;
                          " )," +;
                          " RECEITA as (" +;
                                " select Z0Y_ORDEM, Z0Y_TRATO, Z0Y_COMP, Z0Y_QTDREA" +;
                                  " from " + RetSqlName("Z0Y") + " Z0Y" +;
                                 " where Z0Y.Z0Y_FILIAL = '" + FWxFilial("Z0Y") + "'" +;
                                   " and Z0Y.Z0Y_DATINI <> '        '" +;
                                   " and Z0Y.Z0Y_DATA   = '" + DToS(dDtTrato) + "'" +;
                                   " and Z0Y.D_E_L_E_T_ = ' '" +;
                          " )" +;
                                " select Z0W.Z0W_ORDEM" +;
                                     " , Z0W.Z0W_DATA" +;
                                     " , Z0W.Z0W_VERSAO" +;
                                     " , Z0W.Z0W_ROTA" +;
                                     " , Z0W.Z0W_CURRAL" +;
                                     " , Z0W.Z0W_LOTE" +;
                                     " , sum((Z0W_QTDREA*Z0Y_QTDREA*Z0V_INDMS)/(100*TRT_QUANT*Z05_CABECA)) QTD_MS_COMP_CABECA" +;
                                  " from " + RetSqlName("Z0W") + " Z0W" +;
                                  " join QTDPROD PRD" +;
                                    " on PRD.Z0Y_ORDEM = Z0W.Z0W_ORDEM" +;
                                   " and PRD.Z0Y_TRATO = Z0W.Z0W_TRATO" +;
                                  " join QTDTRATO TRT" +;
                                    " on TRT.Z0W_ORDEM = Z0W.Z0W_ORDEM" +;
                                   " and TRT.Z0W_TRATO = Z0W.Z0W_TRATO" +;
                                  " join RECEITA REC" +;
                                    " on REC.Z0Y_ORDEM = Z0W.Z0W_ORDEM" +;
                                   " and REC.Z0Y_TRATO = Z0W.Z0W_TRATO" +;
                                  " join " + RetSqlName("Z05") + " Z05" +;
                                    " on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" +;
                                   " and Z05.Z05_DATA   = Z0W.Z0W_DATA" +;
                                   " and Z05.Z05_VERSAO = Z0W.Z0W_VERSAO" +;
                                   " and Z05.Z05_LOTE   = Z0W.Z0W_LOTE" +;
                                   " and Z05.D_E_L_E_T_ = ' '" +;
                                  " join " + RetSqlName("Z0V") + " Z0V" +;
                                    " on Z0V.Z0V_FILIAL = '" + FWxFilial("Z0V") + "'" +;
                                   " and Z0V.Z0V_DATA   = Z0W.Z0W_DATA" +;
                                   " and Z0V.Z0V_VERSAO = Z0W.Z0W_VERSAO" +;
                                   " and Z0V.Z0V_COMP   = Z0Y_COMP" +;
                                   " and Z0V.D_E_L_E_T_ = ' '" +;
                                 " where Z0W.Z0W_FILIAL = '" + FWxFilial("Z0W") + "'" +;
                                   " and Z0W.Z0W_DATA   = '" + DToS(dDtTrato) + "'" +;
                                   " and Z0W.Z0W_LOTE   = '" + cLote + "'" +;
                                   " and Z0W.Z0W_DATINI <> '        '" +;
                                   " and Z0W.D_E_L_E_T_ = ' '" +;
                              " group by Z0W.Z0W_ORDEM" +;
                                     " , Z0W.Z0W_DATA" +;
                                     " , Z0W.Z0W_VERSAO" +;
                                     " , Z0W.Z0W_ROTA" +;
                                     " , Z0W.Z0W_CURRAL" +;
                                     " , Z0W.Z0W_LOTE"), "TRBMS", .F., .F.)
        nQtdMS := TRBMS->QTD_MS_COMP_CABECA
    TRBMS->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif
return nQtdMS


/*/{Protheus.doc} CalcQtMN
Calcula a quatidade de materia natural com base na data de processamento do trato
@author jr.andre
@since 13/09/2019
@version 1.0
@return numeric, quantidade de materia natural
@param cDieta, characters, código da dieta
@param nQtdMS, numeric, quantidade de materia seca
@param dDtTrato, date, data do tato
@param cVersao, characters, versao do trato
@type function
/*/
user function CalcQtMN(cDieta, nQtdMS, dDtTrato, cVersao) 
local aArea      := GetArea()
local nPosSG1    := 0
local nQtdMN     := 0
local nPosReg    := 0

default dDtTrato := Z0R->Z0R_DATA
default cVersao  := Z0R->Z0R_VERSAO

    if Empty(aIMS) .or. dDtIMS <> dDtTrato
        CarregaIMS(,dDtTrato, cVersao)
    endif

    if !Empty(aIMS)
        // calcula o indice de matéria seca baseado na SG1

        DbSelectArea("SG1")
        DbSetOrder(1) // G1_FILIAL+G1_COD+G1_COMP+G1_TRT
        SG1->(DbSeek(FWxFilial("SG1") + cDieta))
        while !SG1->(Eof()) .and. SG1->G1_FILIAL == FWxFilial("SG1") .and. SG1->G1_COD == cDieta
            nPosReg := SG1->(RecNo())

            if (nPosSG1 := aScan(aIMS, {|aMat| aMat[1] == SG1->G1_COMP})) <> 0
                nQtdMN += (SG1->G1_QUANT * nQtdMS)/(aIMS[nPosSG1][4]/100)
            else
                nQtdMN += u_CalcQtMN(SG1->G1_COMP, nQtdMS)
            endif

            SG1->(DbGoTo(nPosReg))
            SG1->(DbSkip())
        end
    endif

if !Empty(aArea)
    RestArea(aArea)
endif
return nQtdMN


/*/{Protheus.doc} vpcp05vl
Validação de campos editaveis. Usado pelo dicionario de dados
@author jr.andre
@since 13/09/2019
@version 1.0
@return logical, .T. se o conteudo do campo for valido
@type function
/*/
user function vpcp05vl()
local aArea      := GetArea()
local lRet       := .T.
local i, nLen
local oView      := FWViewActive()
local oModel     := FWModelActive()
local oGridModel := oModel:GetModel("MdGridZ06")
local nLin       := oGridModel:GetLine()
local cVar       := ReadVar()
local cLog       := ""
local cSeq       := ""
local nMegaCal   := 0
local nMCalTrat  := 0

if !oGridModel:IsDeleted()

    if "M->Z06_TRATO" $ cVar

        nLin := oGridModel:GetLine()
        nLen := oGridModel:Length()
        for i := 1 to nLen
            if i <> nLin .and. !oGridModel:IsDeleted(i)
                if M->Z06_TRATO == oGridModel:GetValue("Z06_TRATO", i)
                    Help(,, "Trato inválido",, "O trato digitado já existe na linha " + AllTrim(Str(i)) + ".", 1, 0,,,,,, {"Por favor, verifique."})
                    lRet := .F. 
                    exit
                endif
            endif
        next
        if lRet
            cLog += "Alteração do conteúdo do campo Z06_TRATO. " + CRLF
            if oGridModel:GetValue("Z06_RECNO") == 0
                cLog += "Novo registro " + AllTrim(Str(Z06->(RecNo()))) + " Criado." + CRLF + "{" + DToS(Z05->Z05_DATA) + "|" + Z05->Z05_VERSAO + "|" + Z05->Z05_CURRAL + "|" + Z05->Z05_LOTE + "|" + Z05->Z05_DIAPRO + "|" + oGridModel:GetValue("Z06_TRATO") + "}" + CRLF
                RecLock("Z06", .T.)
                Z06->Z06_FILIAL := FWxFilial("Z06")
                Z06->Z06_DATA   := Z05->Z05_DATA
                Z06->Z06_VERSAO := Z05->Z05_VERSAO
                Z06->Z06_CURRAL := Z05->Z05_CURRAL
                Z06->Z06_LOTE   := Z05->Z05_LOTE
                Z06->Z06_DIAPRO := Z05->Z05_DIAPRO
                Z06->Z06_KGMNT  := nQuantMN * LOTES->B8_SALDO
                oGridModel:SetValue("Z06_RECNO", Z06->(RecNo()))
            else
                Z06->(DbGoTo(oGridModel:GetValue("Z06_RECNO")))
                cLog += "Registro " + AllTrim(Str(Z06->(RecNo()))) + " Alterado." + CRLF
                RecLock("Z06", .F.)
            endif
                cLog += "Valor anterior: " + Z06->Z06_TRATO + CRLF
                cLog += "Novo valor: " + M->Z06_TRATO + CRLF
                Z06->Z06_TRATO := M->Z06_TRATO 
            MsUnlock()
            u_Bouble("MdGridZ06", "Z06_TRATO")
        endif

    elseif "M->Z06_DIETA" $ cVar

        if Empty(M->Z06_DIETA)
            Help(,, "Dieta Inválida",, "O campo Dieta é obrigatório.", 1, 0,,,,,, {"Por favor digite uma dieta válida ou selecione." + CRlLF + "<F3 Disponível>."})
            lRet := .F.
        elseif !SB1->(DbSeek(FWxFilial("SB1")+M->Z06_DIETA)) .or. SB1->B1_X_TRATO!='1'
            Help(,, "Dieta Inválida",, "O código digitado não pertence a um produto válido ou esse produto não é uma dieta.", 1, 0,,,,,, {"Por favor digite uma dieta válida ou selecione." + CRLF + "<F3 Disponível>."})
            lRet := .F.
        endif
        if lRet

            if oGridModel:GetValue("Z06_KGMSTR") > 0
                oGridModel:SetValue("Z06_KGMNTR", u_CalcQtMN(M->Z06_DIETA, oGridModel:GetValue("Z06_KGMSTR")))
                oGridModel:SetValue("Z06_MEGCAL", (GetMegaCal(M->Z06_DIETA) * oGridModel:GetValue("Z06_KGMSTR")))
                oGridModel:SetValue("Z06_KGMNT" , u_CalcQtMN(M->Z06_DIETA, oGridModel:GetValue("Z06_KGMSTR"))*Z05->Z05_CABECA)
            endif
            
            cLog += "Alteração do conteúdo do campo Z06_DIETA. " + CRLF
            cSeq := GetSeq(M->Z06_DIETA)
            nMegaCal := GetMegaCal(M->Z06_DIETA)
            nMCalTrat := nMegaCal * oGridModel:GetValue("Z06_KGMSTR") //M->Z06_KGMSTR
            if oGridModel:GetValue("Z06_RECNO") == 0
                cLog += "Novo registro " + AllTrim(Str(Z06->(RecNo()))) + " Criado." + CRLF + "{" + DToS(Z05->Z05_DATA) + "|" + Z05->Z05_VERSAO + "|" + Z05->Z05_CURRAL + "|" + Z05->Z05_LOTE + "|" + Z05->Z05_DIAPRO + "|" + oGridModel:GetValue("Z06_TRATO") + "}" + CRLF
                RecLock("Z06", .T.)
                Z06->Z06_FILIAL := FWxFilial("Z06")
                Z06->Z06_DATA   := Z05->Z05_DATA
                Z06->Z06_VERSAO := Z05->Z05_VERSAO
                Z06->Z06_CURRAL := Z05->Z05_CURRAL
                Z06->Z06_LOTE   := Z05->Z05_LOTE
                Z06->Z06_DIAPRO := Z05->Z05_DIAPRO
                Z06->Z06_TRATO  := oGridModel:GetValue("Z06_TRATO")
                oGridModel:SetValue("Z06_RECNO", Z06->(RecNo()))
            else
                Z06->(DbGoTo(oGridModel:GetValue("Z06_RECNO")))
                cLog += "Registro " + AllTrim(Str(Z06->(RecNo()))) + " Alterado." + CRLF
                RecLock("Z06", .F.)
            endif
                cLog += "Valor anterior: " + Z06->Z06_DIETA + CRLF
                cLog += "Novo valor: " + M->Z06_DIETA + CRLF
                cLog += "Valor Matéria Natural anterior: " + AllTrim(Str(Z06->Z06_KGMNTR)) + CRLF
                cLog += "Novo valor de Matéria Natural: " + AllTrim(Str(oGridModel:GetValue("Z06_KGMNTR"))) + CRLF
                Z06->Z06_DIETA := M->Z06_DIETA 
                Z06->Z06_KGMNTR := oGridModel:GetValue("Z06_KGMNTR")
                Z06->Z06_KGMNT  := oGridModel:GetValue("Z06_KGMNTR") * Z05->Z05_CABECA
                Z06->Z06_SEQ := cSeq
            MsUnlock()

            AjuMateria(oModel)
            if FunName() == "VAPCPA05"
                UpdTrbTmp()
            endif
        endif

    elseif "M->Z06_KGMSTR" $ cVar

        if M->Z06_KGMSTR < 0
            Help(,, "Valor inválido",, "O campo Dieta é obrigatório e deve ser igual ou superior a 0.", 1, 0,,,,,, {"Por favor digite um valor válido."})
            lRet := .F.
        elseif M->Z06_KGMSTR < 0
            lRet := MsgYesNo("A quantidade de trato digitada é 0. Confirma a quantidade?", "Quantidade Zero")
        elseif M->Z06_KGMSTR > GetMV("VA_MXVALTR",,15.0) 
            Help(,, "Valor pode estar errado",, "O valor digitado é considerado muito grande para um trato mas será aceito pela rotina.", 1, 0,,,,,, {"Por favor, certifique-se que o valor digitado está correto."})
            // Trata-se de uma mensagem de aviso. não bloqueia o valor.
        endif

        if lRet

            cLog += "Alteração do conteúdo do campo Z06_KGMSTR. " + CRLF
            if !Empty(oGridModel:GetValue("Z06_DIETA"))
                oGridModel:SetValue("Z06_KGMNTR", u_CalcQtMN(oGridModel:GetValue("Z06_DIETA"), M->Z06_KGMSTR))
                oGridModel:SetValue("Z06_MEGCAL",  GetMegaCal(oGridModel:GetValue("Z06_DIETA")) * M->Z06_KGMSTR , M->Z06_MEGCAL)
                oGridModel:SetValue("Z06_KGMNT" , (u_CalcQtMN(oGridModel:GetValue("Z06_DIETA"), M->Z06_KGMSTR) * Z05->Z05_CABECA))
            endif

            if oGridModel:GetValue("Z06_RECNO") == 0
                cLog += "Novo registro " + AllTrim(Str(Z06->(RecNo()))) + " Criado." + CRLF + "{" + DToS(Z05->Z05_DATA) + "|" + Z05->Z05_VERSAO + "|" + Z05->Z05_CURRAL + "|" + Z05->Z05_LOTE + "|" + Z05->Z05_DIAPRO + "|" + oGridModel:GetValue("Z06_TRATO") + "}" + CRLF
                RecLock("Z06", .T.)
                Z06->Z06_FILIAL := FWxFilial("Z06")
                Z06->Z06_DATA   := Z05->Z05_DATA
                Z06->Z06_VERSAO := Z05->Z05_VERSAO
                Z06->Z06_CURRAL := Z05->Z05_CURRAL
                Z06->Z06_LOTE   := Z05->Z05_LOTE
                Z06->Z06_DIAPRO := Z05->Z05_DIAPRO
                Z06->Z06_TRATO  := oGridModel:GetValue("Z06_TRATO")
                oGridModel:SetValue("Z06_RECNO", Z06->(RecNo()))
            else
                Z06->(DbGoTo(oGridModel:GetValue("Z06_RECNO")))
                RecLock("Z06", .F.)
            endif
                cLog += "Valor anterior: " + AllTrim(Str(Z06->Z06_KGMSTR)) + CRLF
                cLog += "Novo valor: " + AllTrim(Str(M->Z06_KGMSTR)) + CRLF
                cLog += "Valor Matéria Natural anterior: " + AllTrim(Str(Z06->Z06_KGMNTR)) + CRLF
                cLog += "Novo valor de Matéria Natural: " + AllTrim(Str(oGridModel:GetValue("Z06_KGMNTR"))) + CRLF
                Z06->Z06_KGMSTR := M->Z06_KGMSTR
                Z06->Z06_KGMNTR := oGridModel:GetValue("Z06_KGMNTR")
                Z06->Z06_KGMNT  := oGridModel:GetValue("Z06_KGMNTR") * Z05->Z05_CABECA
                Z06->Z06_MEGCAL := oGridModel:GetValue("Z06_MEGCAL")

            MsUnlock()

            AjuMateria(oModel)
            if FunName() == "VAPCPA05"
                UpdTrbTmp()
            endif
        endif
            
        if !Empty(cLog)
            LogTrato("Alteração de campo.", cLog)
        endif

    endif
    
    oView:Refresh()
    
endif

if !Empty(aArea)
    RestArea(aArea)
endif
return lRet


/*/{Protheus.doc} AjuMateria
Atualiza as quantidade de materia seca e natural na tabela Z05
@author guima
@since 13/09/2019
@version 1.0
@return nil
@param oModel, object, Modelo da tela
@type function
/*/
static function AjuMateria(oModel)
local aArea      := GetArea()
local oFormModel := oModel:GetModel("MdFieldZ05")
local oGridModel := oModel:GetModel("MdGridZ06")
local cDieta     := ""
local nQtdeMs    := 0
local nQtdeMn    := 0
local nMegCal    := 0
local nCmsPn     := 0
local i, nLen

    nLen := oGridModel:Length()
    for i := 1 to nLen
        if !oGridModel:IsDeleted(i)
            if !Empty(oGridModel:GetValue("Z06_DIETA", i)) .and. !AllTrim(oGridModel:GetValue("Z06_DIETA", i))$cDieta
                cDieta += Iif(Empty(cDieta), "", ",") +  AllTrim(oGridModel:GetValue("Z06_DIETA", i)) 
            endif
            nQtdeMs += oGridModel:GetValue("Z06_KGMSTR", i)
            nQtdeMn += oGridModel:GetValue("Z06_KGMNTR", i)
            nMegCal += oGridModel:GetValue("Z06_MEGCAL", i)
        endif
    next
    
    nCmsPn := (nQtdeMs / Z05->Z05_PESMAT) *100

    oFormModel:SetValue("Z05_TOTMSI", nQtdeMs)
    oFormModel:SetValue("Z05_TOTMNI", nQtdeMn)
    oFormModel:SetValue("Z05_MEGCAL", nMegCal)
    oFormModel:SetValue("Z05_CMSPN" , nCmsPn)
    oFormModel:SetValue("Z05_MANUAL", "1")

    RecLock("Z05", .F.)
        Z05->Z05_DIETA := cDieta
        Z05->Z05_KGMSDI := nQtdeMs
        Z05->Z05_KGMNDI := nQtdeMn
        Z05->Z05_TOTMSI := nQtdeMs
        Z05->Z05_TOTMNI := nQtdeMn
        Z05->Z05_MEGCAL := nMegcal
        Z05->Z05_CMSPN  := (nQtdeMs / Z05->Z05_PESMAT) *100
        Z05->Z05_MANUAL := "1"
    MsUnlock()

if !Empty(aArea)
    RestArea(aArea)
endif
return nil


/*/{Protheus.doc} FillTrato
Preenche o trato para um lote num determinado curral
@author guima
@since 13/09/2019
@version 1.0
@return Logical, .T. se o trato foi criado com sucesso
@param cCurral, characters, Código do curral onde o trato será criado
@param cLote, characters, Lote onde o trato será criado
@type function
/*/
static function FillTrato(cCurral, cLote)
local aParam    :={mv_par01, mv_par02, mv_par03}
local lRet      := .T.
local cFillPerg := "VAPCPA051"
local oModel    := FWModelActive(), oGridModel, oFormModel
local nMaxTrato := u_GetNroTrato()
local cTrbAlias := ""
local i
local cSeq      := ""
local nMCalTrt  := 0

default cCurral :=  Iif(FunName() == 'VAPCPA09', Z05->Z05_CURRAL, (cTrbBrowse)->Z08_CODIGO)
default cLote :=  Iif(FunName() == 'VAPCPA09', Z05->Z05_LOTE, (cTrbBrowse)->B8_LOTECTL)

    AtuSX1(@cFillPerg)
    if (lRet := Pergunte(cFillPerg))

        DbSelectArea("Z08")
        DbSetOrder(1) // Z08_FILIAL+Z08_CODIGO
        Z08->(DbSeek(FWxFilial("Z08")+cCurral)) 

        DbSelectArea("SB8")
        DbSetOrder(7) //B8_FILIAL+B8_LOTECTL+B8_X_CURRA
        SB8->(DbSeek(FWxFilial("SB8")+cLote)) 

        // Valida se os parâmetros estão OK.  
        DbSelectArea("SB1")
        DbSetOrder(1) // B1_FILIAL + B1_COD
        if !SB1->(DbSeek(FWxFilial("SB1")+mv_par01)) .or. SB1->B1_X_TRATO!='1'
            Help(,, "Dieta Inválida",, "O código digitado não pertence a um produto válido ou esse produto não é uma dieta.", 1, 0,,,,,, {"Por favor digite uma dieta válida ou selecione." + CRLF + "<F3 Disponível>."})
            lRet := .F.
        endif

        if lRet .and. mv_par02 <= 0
            Help(,, "Quantidade Inválida",, "A quantidade digitada deve ser superior a 0.", 1, 0,,,,,, {"Por favor, digite uma quantidade válida."})
            lRet := .F.
        endif

        if lRet .and. mv_par02 > GetMV("VA_MXVALTR",,15.0) 
            lRet := MsgYesNo("O valor digitado " + AllTrim(Str(mv_par02)) + " é considerado muito grande para um trato. Pode ser que esse valor esteja errado. Confirma esse valor para o trato?", "Valor pode estar errado.")
        endif
        
        if lRet .and. mv_par03 == 0
            Help(,, "Nro de Tratos Inválido",, "O número de tratos deve ser superior a 0.", 1, 0,,,,,, {"Por favor, digite uma um numero de tratos válido válida."})
            lRet := .F.
        endif

        if lRet .and. mv_par03 > nMaxTrato
            Help(,, "Nro de Tratos Inválido",, "O número de tratos deve ser menor que ou igual a " + AllTrim(Str(nMaxTrato)) + " de acordo com o parametrizado em VA_NTRATO.", 1, 0,,,,,, {"Por favor, digite uma um número de tratos válido."})
            lRet := .F.
        endif

        if lRet 

            begin transaction

            if !Z05->(DbSeek(FWxFilial("Z05")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO+cCurral+cLote))
              cTrbAlias := CriaTrab(, .f.)
                                    _cSql := " select SB8.B8_LOTECTL" + _ENTER_ +;
                                             "       , Z0O.Z0O_GMD" + _ENTER_ +;
                                             "       , Z0O.Z0O_PESO" + _ENTER_ +;
                                             "       , Z0O.Z0O_CMSPRE" + _ENTER_ +;
                                             "       , sum(SB8.B8_SALDO) B8_SALDO" + _ENTER_ +;
                                             "       , sum(B8_XPESOCO*B8_SALDO)/sum(B8_SALDO) B8_XPESOCO" + _ENTER_ +;
                                             "       , min(SB8.B8_XDATACO) DT_INI_PROG" + _ENTER_ +;
                                             "       , cast(convert(datetime, '" + DToS(Z0R->Z0R_DATA) + "', 103) - convert(datetime, min(SB8.B8_XDATACO), 103) as numeric) DIAINI" + _ENTER_ +;
                                             " from " + RetSqlName("SB8") + " SB8" + _ENTER_ +;
                                             " left join " + RetSqlName("Z0O") + " Z0O on Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" + _ENTER_ +;
                                             "                               and Z0O.Z0O_LOTE   = SB8.B8_LOTECTL" + _ENTER_ +;
                                             "                               and (" + _ENTER_ +;
                                             "                                       '" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR" + _ENTER_ +;
                                             "                                       or (Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        ')" + _ENTER_ +;
                                             "                               )" + _ENTER_ +;
                                             "                               and Z0O.D_E_L_E_T_ = ' '" + _ENTER_ +;
                                             " where SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" + _ENTER_ +;
                                             "   and SB8.B8_SALDO    > 0" + _ENTER_ +;
                                             "   and SB8.D_E_L_E_T_ = ' '" + _ENTER_ +;
                                             "   and SB8.B8_X_CURRA = '" +cCurral+ "'" + _ENTER_ +;
                                             "   and SB8.B8_LOTECTL = '" +cLote+ "'" + _ENTER_ +;
                                             " group by SB8.B8_LOTECTL, Z0O.Z0O_GMD, Z0O_PESO, Z0O_CMSPRE"
                DbUseArea(.T., "TOPCONN", TCGenQry(,, _cSql), (cTrbAlias), .F., .F.)
                nPesoCo := (cTrbAlias)->B8_XPESOCO
                nGMD    := (cTrbAlias)->Z0O_GMD
            
                // If AllTrim(LOTES->Z08_CODIGO) == "B08" .OR.;
                //     AllTrim(LOTES->Z08_CODIGO) == "B14"
                //     ConOut("BreakPoint")
                // EndIf
                _nMCALPR := 0
                If !Empty((cTrbAlias)->Z0O_PESO) .AND. !Empty((cTrbAlias)->Z0O_CMSPRE)
                    DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                _cSql := " SELECT distinct " + cValToChar( (cTrbAlias)->Z0O_PESO ) +;
                                         " * G1_ENERG * (" + cValToChar( (cTrbAlias)->Z0O_CMSPRE ) + "/100) AS MEGACAL"+_ENTER_+;
                                         " FROM SG1010 "+CRLF+;
                                         " WHERE G1_FILIAL = '" + xFilial('SG1') + "' "+CRLF+;
                                         "   AND G1_COD = '" + GetMV("VA_PCP07MC",,'FINAL') + "'"+CRLF+;
                                         "   AND D_E_L_E_T_ = ' '";
                                    ),"TMPmgCal", .F., .F.)
                    MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa05_Z05_MCALPR.SQL", _cSql)
                    if (!TMPmgCal->(Eof()))
                        _nMCALPR := TMPmgCal->MEGACAL
                    EndIf
                    TMPmgCal->(DbCloseArea())    
                EndIf
                (cTrbAlias)->(DbCloseArea())       

                RecLock("Z05", .T.)
                    Z05->Z05_FILIAL := FWxFilial("Z05")
                    Z05->Z05_DIETA  := MV_PAR01
                    Z05->Z05_DATA   := Z0R->Z0R_DATA
                    Z05->Z05_VERSAO := Z0R->Z0R_VERSAO
                    Z05->Z05_CURRAL := cCurral
                    Z05->Z05_LOTE   := cLote
                    Z05->Z05_CABECA := QtdCabecas(cLote)
                    Z05->Z05_DIASDI := DiasDieta(cLote, Z0R->Z0R_DATA)+1
                    Z05->Z05_PESOCO := nPesoCo
                    Z05->Z05_PESMAT := nPesoCo + Z05->Z05_DIASDI * nGMD
                    Z05->Z05_CMSPN  := Iif(Z05->Z05_PESMAT == 0, 1, Z05->Z05_KGMSDI/Z05->Z05_PESMAT*100)
                    Z05->Z05_MCALPR := _nMCALPR
            else
                TCSqlExec(;
                    "update " + RetSqlName("Z06") +;
                      " set D_E_L_E_T_ = '*'" +;
                    " where Z06_FILIAL = '" + Z05->Z05_FILIAL + "'" +;
                      " and Z06_DATA   = '" + DToS(Z05->Z05_DATA) + "'" +;
                      " and Z06_VERSAO = '" + Z05->Z05_VERSAO + "'" +;
                      " and Z06_CURRAL = '" + Z05->Z05_CURRAL + "'" +;
                      " and Z06_LOTE   = '" + Z05->Z05_LOTE + "'" +;
                      " and D_E_L_E_T_ = ' '" ;
                )
                RecLock("Z05", .F.)
            endif

                Z05->Z05_MANUAL := '1'
                Z05->Z05_KGMSDI := mv_par02
                Z05->Z05_KGMNDI := u_CalcQtMN(mv_par01, mv_par02)
                Z05->Z05_TOTMSI := Z05->Z05_KGMSDI
                Z05->Z05_TOTMNI := Z05->Z05_KGMNDI
                Z05->Z05_NROTRA := mv_par03
                Z05->Z05_MEGCAL := GetMegaCal(mv_par01) * mv_par02

                MsUnlock()

            CanUseZ05()

            aKgMS := DivTrato(mv_par02, mv_par03)
            cSeq := GetSeq(mv_par01)
            nMCalTrt := GetMegaCal(mv_par01)    

            // "Z06_TRATO",  "Z06_DIETA",  "Z06_KGMSTR", "Z06_KGMNTR", "Z06_RECNO"
            for i := 1 to mv_par03
                RecLock("Z06", .T.)
                    Z06->Z06_FILIAL := FwxFilial("Z06")
                    Z06->Z06_DATA   := Z0R->Z0R_DATA
                    Z06->Z06_VERSAO := Z0R->Z0R_VERSAO
                    Z06->Z06_CURRAL := Z05->Z05_CURRAL
                    Z06->Z06_LOTE   := Z05->Z05_LOTE
                    Z06->Z06_DIAPRO := Z05->Z05_DIAPRO
                    Z06->Z06_TRATO  := AllTrim(Str(i))
                    Z06->Z06_DIETA  := mv_par01
                    Z06->Z06_KGMSTR := aKgMS[i]
                    Z06->Z06_KGMNTR := u_CalcQtMN(mv_par01, aKgMS[i])
                    Z06->Z06_SEQ    := cSeq
                    Z06->Z06_MEGCAL := nMCalTrt * aKgMS[i]
                    Z06->Z06_KGMNT  := u_CalcQtMN(mv_par01, aKgMS[i]) * Z05->Z05_CABECA
                MsUnlock()
            next

            end transaction
        endif

        if FunName() == "VAPCPA05"
            UpdTrbTmp() // Atualiza a quantidade de trato tabela temporária
        endif

    endif

    mv_par01 := aParam[1]
    mv_par02 := aParam[2]
    mv_par03 := aParam[3]

return lRet


/*/{Protheus.doc} MatNat
Explode extrutura do trato mostrando a materia natural por componente 
@author jr.andre
@since 13/09/2019
@version 1.0
@return nil
@type function
/*/
user function MatNat()
local aAreaZ06   := Z06->(GetArea())
local oModel     := FWModelActive()
local oFormModel := oModel:GetModel("MdFieldZ05")
local oGridModel := oModel:GetModel("MdGridZ06")
local cDieta
local cVersao    := ""
local nQtde

    SetKey(VK_F4, nil)
    SetKey(VK_F5, nil)
    SetKey(VK_F6, nil)
    SetKey(VK_F7, nil)

    // { "Z06_TRATO",  "Z06_DIETA",  "Z06_KGMSTR", "Z06_KGMNTR", "Z06_RECNO" }
    if !oGridModel:IsEmpty()
        nLin := oGridModel:GetLine()
        if !Empty(cDieta := oGridModel:GetValue("Z06_DIETA")) 

            if (nQtde := Iif(oFormModel:GetValue("Z05_TOTMSC") == 0, oFormModel:GetValue("Z05_TOTMSI"), oFormModel:GetValue("Z05_TOTMSC"))) == 0
                nQtde := 1
            endif

            // Identifica o SEQ usado pela estrutura
            if (nRegZ06 := oGridModel:GetValue("Z06_RECNO")) <> 0
                if Z06->(RecNo()) <> nRegZ06
                    Z06->(DbGoTo(nRegZ06))
                endif
                cVersao := Z06->Z06_SEQ
            endif
            
            if Empty(cVersao)
                DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                          "select max(ZG1_SEQ) ZG1_SEQ" +; 
                                           " from " + RetSqlName("ZG1") + " ZG1" +;
                                          " where ZG1_FILIAL = '" + FWxFilial("ZG1") + "'" +;
                                            " and ZG1_COD = '" + cDieta + "'" +; 
                                            " and D_E_L_E_T_ = ' '";
                                                     ), "TMPZG1", .F., .F.)
                    cVersao := TMPZG1->ZG1_SEQ
                TMPZG1->(DbCloseArea())
            endif

            // caso não encontre pega último
            if !Empty(cVersao)
                u_vapcpa11(cDieta, cVersao, Z0R->Z0R_DATA, Z0R->Z0R_HORA, nQtde)
            else
                Help(/*Descontinuado,/*Descontinuado,"DIETA NAO ENCONTRADA",/**/,"Não foi encontrada estrutura para a dieta " + cDieta + ". ", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, digite uma dieta ou selecione uma dieta válida." })
            endif

        endif 
    else
        Help(/*Descontinuado*/,/*Descontinuado*/,"DIETA NAO ENCONTRADA",/**/,"Não existe trato na linha selecionada. ", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, digite ou selecione uma linha com dieta válida." })
    endif

    SetKey(VK_F4, {|| u_MatNat()})
    SetKey(VK_F5, {|| Reprograma()})
    SetKey(VK_F6, {|| Anterior()})
    SetKey(VK_F7, {|| Proximo()})
if !Empty(aAreaZ06)
    Z06->(RestArea(aAreaZ06))
endif
return nil


/*/{Protheus.doc} DivTrato
Distribui a quantidade de materia seca prevista para o trato entre os tratos do dia.
@author guima
@since 13/09/2019
@version 1.0
@return Array, Array com as quantidade de materia seca por trato
@param nKgTrato, numeric, Quantidade de materia seca a ser distribuida nos tratos
@param nQtdTrato, numeric, Quantidade de tratos
@type function
/*/
static function DivTrato(nKgTrato, nQtdTrato)
local aTrato    := Array(nQtdTrato)
local nTrato    := NoRound(nKgTrato/nQtdTrato, TamSX3("Z06_KGMSTR")[2])
local nTotTrato := 0
local i

for i := nQtdTrato to 1 step -1
    if i == 1
        aTrato[i] := nKgTrato - nTotTrato
    else
        nTotTrato += aTrato[i] := nTrato
    endif
next

return aTrato 


/*/{Protheus.doc} QtdCabecas
Retorna a quantidade de cabeças do lote
@author jr.andre
@since 13/09/2019
@version 1.0
@return Numeric, Retorna o saldo do lote
@param cLote, characters, Lote a ser consultado
@type function
/*/
static function QtdCabecas(cLote)
local aArea    := GetArea()
local nQtdeCab := 0
    
    DbUseArea(.T., "TOPCONN", TcGenQry(,,;
                              " select sum(B8_SALDO) B8_SALDO" +;
                                " from " + RetSqlName("SB8") + " SB8" +;
                               " where SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                                 " and SB8.B8_LOTECTL = '" + cLote + "'" +;
                                 " and SB8.B8_SALDO   <> 0" +;
                                 " and SB8.D_E_L_E_T_ = ' '" ;
                                         ), "TMPTRB", .F., .F.)
    nQtdeCab := TMPTRB->B8_SALDO
    TMPTRB->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif
return nQtdeCab


/*/{Protheus.doc} DiasDieta
Retorna o numero de dias de cocho do lote
@author jr.andre
@since 13/09/2019
@version 1.0
@return Numeric, numero de dias
@param cLote, characters, código do lote
@param dData, date, data de referência
@type function
/*/
static function DiasDieta(cLote, dData)
local aArea      := GetArea()
local nDiasDieta := 0
local cAlias     := CriaTrab(,.F.)

default dData    := dDataBase

    DbUseArea(.T., "TOPCONN", TcGenQry(,,;
                              " select   CASE WHEN Z0O_DINITR = ' ' THEN min(SB8.B8_XDATACO) " +;
	                                   "      WHEN Z0O_DINITR <> ' ' THEN Z0O_DINITR " +;
									   "      ELSE min(SB8.B8_XDATACO) END B8_XDATACO " +;
                                " from " + RetSqlName("SB8") + " SB8" +;
                            " left join Z0O010 Z0O ON " +;
						              " Z0O_FILIAL = '" + FWxFilial("SB8") + "'" +;
								   "and Z0O_LOTE = '" + cLote + "'"  +;
								   "and Z0O_DATATR = ' ' " +;
								   "and Z0O.D_E_L_E_T_ = ' ' " +;
                               " where SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                                 " and SB8.B8_LOTECTL = '" + cLote + "'" +;
                                 " and SB8.B8_SALDO   <> 0" +;
                                 " and SB8.D_E_L_E_T_ = ' '" +;
                            " GROUP BY Z0O.Z0O_DINITR   " ;
                                         ), cAlias, .F., .F.)
    if !(cAlias)->(Eof())
        nDiasDieta := dData-SToD((cAlias)->B8_XDATACO)
    endif
    (cAlias)->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif
return Iif(nDiasDieta > nMaxDiasDi, nMaxDiasDi, nDiasDieta)


/*/{Protheus.doc} CanUseZ05
Verifica se um registro está sendo usado por outra instancia e caso não esteja bloqueia
@author guima
@since 13/09/2019
@version 1.0
@return Logical, .T. se registro puder ser alterado
@type function
/*/
static function CanUseZ05()
local lRet := .T.

    // valida se o registro já foi utilizado para gerar arquivo
    if (lRet := (Z05->Z05_LOCK <= '1')) 
        // Trata o lock como semáforo para o registro
        if !LockByName("Z05" + StrZero(Z05->(RecNo()),10), .T., .T.)
            lRet := .F.
            Help(,, "CANUSEZ05.",, "Curral " + AllTrim(Z05->Z05_CURRAL) + " - Lote " + AllTrim(Z05->Z05_LOTE) + "  em uso. A operação será cancelada.", 1, 0,,,,,, {"Aguarde o registro ser liberado para alterá-lo."})
        endif
    else
        Help(,, "CANUSEZ05.",, "Curral " + AllTrim(Z05->Z05_CURRAL) + " - Lote " + AllTrim(Z05->Z05_LOTE) + " já foi utilizado num arquivo de programação.", 1, 0,,,,,, {"Para alterar esse registro é necessário criar uma nova versão do trato."})
    endif
return lRet


/*/{Protheus.doc} ReleaseZ05
Destrava a o registro da tabela Z05 posicionada
@author jr.andre
@since 13/09/2019
@version 1.0
@return logical, .T. se o registro foi destravado com sucesso

@type function
/*/
static function ReleaseZ05()
local lRet 

    if (lRet := UnlockByName("Z05" + StrZero(Z05->(RecNo()),10), .T., .T.))
//        RecLock("SX5", .T.)
//            SX5->X5_FILIAL := 'UK'
//            SX5->X5_DESCRI := "Z05" + StrZero(Z05->(RecNo()),10)
//        MsUnlock()
    endif
return lRet


/*/{Protheus.doc} InUseZ05
Informa se algum registro da Z05 está sendo usado.
@author jr.andre
@since 13/09/2019
@version 1.0
@return Logical, .T. se algum registro da Z05 estiver em uso.
@type function
/*/
static function InUseZ05(cRotaDe, cRotaAte, cCurralDe, cCurralAte, cLoteDe, cLoteAte, cVeicDe, cVeicAte)
local lRet         := .F.
local cFilter      := ""

default cRotaDe    := Space(TamSX3("Z05_ROTEIR")[1])
default cRotaAte   := Replicate("Z", TamSX3("Z05_ROTEIR")[1])
default cCurralDe  := Space(TamSX3("Z05_CURRAL")[1])
default cCurralAte := Replicate("Z", TamSX3("Z05_CURRAL")[1])
default cLoteDe    := Space(TamSX3("Z05_LOTE")[1])
default cLoteAte   := Replicate("Z", TamSX3("Z05_LOTE")[1])
default cVeicDe    := Space(TamSX3("ZV0_CODIGO")[1])
default cVeicAte   := Replicate("Z", TamSX3("ZV0_CODIGO")[1])

//---------------------------------------------
// Atualiza as rotas na tabela Z05 e temporária
//---------------------------------------------

DbSelectArea(cTrbBrowse)
DbSetOrder(1) // Z08_CODIGO

DbSelectArea("Z05")
DbSetOrder(1) // Z05_FILIAL+Z05_DATA+Z05_VERSAO+Z05_CURRAL+Z05_LOTE

if Z05->(DbSeek(FWxFilial("Z05")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO))
    while !Z05->(Eof()) .and. Z05->Z05_DATA == Z0R->Z0R_DATA .and. Z05->Z05_VERSAO == Z0R->Z0R_VERSAO
        if AllTrim(Z05->Z05_ROTEIR) != (cRoteiro:= UlrRoteiro(Z0R->Z0R_DATA, Z0R->Z0R_VERSAO, Z05->Z05_LOTE, Z05->Z05_CURRAL))
            if (cTrbBrowse)->(DbSeek(Z05->Z05_CURRAL))
                RecLock(cTrbBrowse, .F.)
                    (cTrbBrowse)->Z0T_ROTA := cRoteiro
                MsUnlock()
                RecLock("Z05", .F.)
                    Z05->Z05_ROTEIR := cRoteiro
                MsUnlock()
            endif
        endif 
        Z05->(DbSkip())
    end
endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                          " select Z0S_ROTA" +;
                            " from " + RetSqlName("Z0S") + " Z0S" +;
                           " where Z0S.Z0S_FILIAL = '" + FWxFilial("Z0S") + "'" +;
                             " and Z0S.Z0S_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                             " and Z0S.Z0S_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                             " and Z0S.Z0S_EQUIP  between '" + cVeicDe + "' and '" + cVeicAte + "'" +;
                             " and Z0S.D_E_L_E_T_ = ' '" ;
                                     ), "TMPZ0S", .T., .F.)
while !TMPZ0S->(Eof())
    cFilter += Iif(Empty(cFilter), "", ", ") + "'" + TMPZ0S->Z0S_ROTA + "'"
    TMPZ0S->(DbSkip())
end
TMPZ0S->(DbCloseArea())

DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                          " select Z05.R_E_C_N_O_ RecNo" +;
                            " from " + RetSqlName("Z05") + " Z05" +;
                           " where Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" +;
                             " and Z05.Z05_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                             " and Z05.Z05_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                             " and Z05.Z05_ROTEIR   between '" + cRotaDe + "' and '" + cRotaAte + "'" +;
                             " and Z05.Z05_CURRAL between '" + cCurralDe + "' and '" + cCurralAte + "'" +;
                             " and Z05.Z05_LOTE   between '" + cLoteDe + "' and '" + cLoteAte + "'" +;
                             Iif(Empty(cFilter), "", " and Z05.Z05_ROTEIR   in (" + cFilter + ")") +;
                             " and Z05.D_E_L_E_T_ = ' '";
                                     ), "TMPZ05", .T., .F.)

    while !TMPZ05->(Eof())
        Z05->(DbGoTo(TMPZ05->(RECNO)))
        if !CanUseZ05()
            lRet := .T.
            exit
        endif
        ReleaseZ05()
        TMPZ05->(DbSkip())
    end

TMPZ05->(DbCloseArea())
return lRet


/*/{Protheus.doc} UpdTrbTmp
Atualiza o registro corrente da tabela temporária .
@author jr.andre
@since 13/09/2019
@version 1.0
@return nil
@param lExclui, logical, Informa se o registro da tabela temporária deve ser excluído ou atualizado
@type function
/*/
static function UpdTrbTmp(lExclui)
local aArea      := GetArea()
local aAreaTrb   := (cTrbBrowse)->(GetArea())
local aAreaZ06   := Z06->(GetArea())
local i          := 0
local cTrbAlias  := CriaTrab(,.F.)
local nPos       := oBrowse:nAt
local lNaoExtLot := .F.
local nKgMnTot   := 0

default lExclui  := .F.

    DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                              " select count(*) QTDREG" +;
                                " from " + RetSqlName("SB8") + " SB8" +;
                               " where SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                                 " and SB8.B8_LOTECTL = '" + (cTrbBrowse)->B8_LOTECTL + "'" +;
                                 " and SB8.B8_SALDO   > 0" +;
                                 " and SB8.D_E_L_E_T_ = ' '";
                                         ), cTrbAlias, .F., .F.)
        lNaoExtLot := (cTrbAlias)->QTDREG == 0
    (cTrbAlias)->(DbCloseArea())
    // Posiocina no registro para garantir que caso ele tenha sido excluido não atualize a cTrbBrowse com dados errados
    Z05->(DbSeek(FWxFilial("Z05")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO+(cTrbBrowse)->Z08_CODIGO+(cTrbBrowse)->B8_LOTECTL))

    RecLock(cTrbBrowse, .F.)
        if lExclui .and. lNaoExtLot
            DbDelete()
        else
            (cTrbBrowse)->Z05_DIASDI := Z05->Z05_DIASDI
            (cTrbBrowse)->PROG_MS    := Z05->Z05_KGMSDI
            (cTrbBrowse)->PROG_MN    := Z05->Z05_KGMNDI
            (cTrbBrowse)->NR_TRATOS  := Z05->Z05_NROTRA
            (cTrbBrowse)->CMS_PV     := Z05->Z05_CMSPN
            (cTrbBrowse)->Z05_MEGCAL := Z05->Z05_MEGCAL
            

            for i := 1 to nNroTratos
                if Z06->(DbSeek(FWxFilial("Z06")+DToS(Z05->Z05_DATA)+Z05->Z05_VERSAO+Z05->Z05_CURRAL+Z05->Z05_LOTE+AllTrim(Str(i))))
                    (cTrbBrowse)->&("Z06_DIETA" + StrZero(i, 1)) := Z06->Z06_DIETA
                    (cTrbBrowse)->&("Z06_KGMS" + StrZero(i, 1))  := Z06->Z06_KGMSTR
                    (cTrbBrowse)->&("Z06_KGMN" + StrZero(i, 1))  := Z06->Z06_KGMNTR
                else
                    (cTrbBrowse)->&("Z06_DIETA" + StrZero(i, 1)) := Space(TamSX3("Z06_DIETA")[1])
                    (cTrbBrowse)->&("Z06_KGMS" + StrZero(i, 1))  := 0
                    (cTrbBrowse)->&("Z06_KGMN" + StrZero(i, 1))  := 0
                endif
                nKgMnTot += Z06->Z06_KGMNTR * (cTrbBrowse)->B8_SALDO
            next

            (cTrbBrowse)->Z05_MNTOT  := Round(nKgMnTot, TamSX3('Z05_TOTMNI')[2] )
        endif

    MsUnlock()

    (cTrbBrowse)->(RestArea(aAreaTrb))
    oBrowse:nAt := nPos
    oBrowse:Refresh()

Z06->(RestArea(aAreaZ06))
RestArea(aArea)
return nil


/*/{Protheus.doc} Reprograma
Reprograma o trato de acordo com parâmetros
@author jr.andre
@since 13/09/2019
@version 1.0
@return nil
@type function
/*/
static function Reprograma()
local aArea  := GetArea()
local oView  := FWViewActive()
local oModel := oView:GetModel()
local oFormModel, oGridModel
local i, j, nCpo, nLen
local aDadosZ05, aDadosZ06
local cDieta := ""

if FillTrato()
//    RecarTrato()
//    ReleaseZ05()

    oModel:getModel("MdGridZ06"):SetNoInsertLine(.F.)
    oModel:getModel("MdGridZ06"):SetNoDeleteLine(.F.)

    aDadosZ05 := LoadZ05()
    oFormModel := oModel:GetModel("MdFieldZ05")
    nCpo := Len(aCpoMdZ05F)
    for i := 1 to nCpo
        if !oFormModel:SetValue(aCpoMdZ05F[i], aDadosZ05[i])
            ConOut("Erro " + aCpoMdZ05F[i] + ":" + cValToChar(aDadosZ05[i]))
        endif
    next

    // aCpoMdZ06G := {"Z06_TRATO", "Z06_DIETA", "Z06_KGMSTR", "Z06_KGMNTR", "Z06_RECNO"}
    oGridModel := oModel:GetModel("MdGridZ06")
    oGridModel:ClearData()

    aDadosZ06 := LoadZ06()
    nLen := Len(aDadosZ06)
    nCpo := Len(aCpoMdZ06G)

    for i := 1 to nLen
        if !oGridModel:IsEmpty()
            oGridModel:AddLine()
            oView:Refresh()
        endif
        oGridModel:GoLine(i)
        for j := 1 to nCpo
            oGridModel:LoadValue(aCpoMdZ06G[j], aDadosZ06[i][2][j])
        next 
        if !AllTrim(aDadosZ06[i][2][2])$cDieta
            cDieta += Iif(Empty(cDieta), "", ",") + AllTrim(aDadosZ06[i][2][2])
        endif
    next
    oGridModel:GoLine(1)

    RecLock("Z05", .F.)
        Z05->Z05_DIETA  := cDieta
    MsUnlock()

    oModel:getModel("MdGridZ06"):SetNoInsertLine(.T.)
    oModel:getModel("MdGridZ06"):SetNoDeleteLine(.T.)

    oView:Refresh()
endif

return nil


/*/{Protheus.doc} PosCpoSX3
Ordena os campos conform o SX3.
@author jr.andre
@since 13/09/2019
@version 1.0
@return Array, Array ordenado de acordo com a SX3.
@param aCpos, Array, Array com os campos
@type function
/*/
static function PosCpoSX3(aCpos)
local aArea    := GetArea()
local aAreaSX3 := SX3->(GetArea())
local aTmpCpos := {}
local aCposAju := {}
local i, nLen

SX3->(DbsetOrder(2))

nLen := Len(aCpos)
for i := 1 to nLen
    if SX3->(DbSeek(aCpos[i]))
        AAdd(aCposAju, {SX3->X3_ARQUIVO, SX3->X3_ORDEM, aCpos[i]})
    endif
next

aTmpCpos := aSort(aCposAju,,, {|X, Y| X[1] + X[2] < Y[1] + Y[2] })

aCposAju := {}
nLen := Len(aTmpCpos)
for i := 1 to nLen
    AAdd(aCposAju, aTmpCpos[i][3])
next

aCpos := aClone(aCposAju)

SX3->(RestArea(aAreaSX3))
if !Empty(aArea)
    RestArea(aArea)
endif

return aCpos


/*/{Protheus.doc} MaxVerTrat
Retorna a útima versão do trato
@author jr.andre
@since 13/09/2019
@version 1.0
@return Array, Última versão do trato no último dia criado de trato para o lote
@param cLote, Characters, Lote
@param dDtTrato, Date, data do trato
@type function
/*/
static function MaxVerTrat(cLote, dDtTrato)
local aArea  := GetArea()
local aChave := {}

DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                          " select top(1) Z05.Z05_DATA, Z05.Z05_VERSAO" +;
                            " from " + RetSqlName("Z05") + " Z05" +;
                           " where Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" +;
                             " and Z05.Z05_DATA   < '" + DToS(dDtTrato) + "'" +;
                             " and Z05.Z05_LOTE   = '" + cLote + "'" +;
                             " and Z05.D_E_L_E_T_ = ' '" +;
                        " order by Z05.Z05_DATA desc, Z05.Z05_VERSAO desc";
                                     ), "MAXVERZ05", .F., .F.)
    if !MAXVERZ05->(Eof())
        aChave := { MAXVERZ05->Z05_DATA, MAXVERZ05->Z05_VERSAO }
    endif
MAXVERZ05->(DbCloseArea())

RestArea(aArea)
return aChave


/*/{Protheus.doc} UlrRoteiro
Identifica a qual foi o ultimo roteiro usado pelo lote no curral passado.
@author jr.andre
@since 30/08/2019
@version 1.0
@return Character, último roteiro usado pelo lote.
@param dDtTrato, Date, Data do trato
@param cVersao, Characters, Versao atual do trato
@param cLote, Characters, Código do lote
@param cCurral, Characters, Código do curral
@type function
/*/
static function UlrRoteiro(dDtTrato, cVersao, cLote, cCurral)
local aArea    := GetArea()
local cRoteiro := CriaVar("Z05_ROTEIR", .F.)

    DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                              " select Z05.Z05_DATA, Z05.Z05_VERSAO, Z05.Z05_ROTEIR, Z0T.Z0T_ROTA" +;
                                " from " +  RetSqlName("Z05") + " Z05" +;
                           " left join " +  RetSqlName("Z0T") + " Z0T" +;
                                  " on Z0T.Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" +;
                                 " and Z0T.Z0T_DATA   = Z05.Z05_DATA" +;
                                 " and Z0T_CURRAL     = Z05.Z05_CURRAL" +;
                                 " and Z0T.D_E_L_E_T_ = ' '" +;
                               " where Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" +;
                                 " and Z05.Z05_LOTE   = '" + cLote + "'" +;
                                 " and Z05.Z05_CURRAL = '" + cCurral + "'" +;
                                 " and Z05.Z05_DATA+Z05.Z05_VERSAO   <= '" + DToS(dDtTrato) + cVersao + "'" +;
                                 " and (" +;
                                          " Z05.Z05_ROTEIR <> '                    '" +;
                                       " or isnull(Z0T.Z0T_ROTA, '      ') <> '      '" +;
                                     " )" +;
                                 " and Z05.D_E_L_E_T_ = ' '" +;
                            " order by Z05.Z05_DATA desc, Z05.Z05_VERSAO desc" ;
                                         ), "TMPROT", .F., .F.)

    if !TMPROT->(Eof())
        cRoteiro := Iif(Empty(TMPROT->Z0T_ROTA), TMPROT->Z05_ROTEIR, TMPROT->Z0T_ROTA)
    endif

    TMPROT->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif

return cRoteiro


/*/{Protheus.doc} vap05tra
Altera a quantidade de tratos de acordo com a pergunta VAPCPA053
@author jr.andre
@since 30/08/2019
@version 1.0
@return nil 
@type function
/*/
user function vap05tra()
local aAreaTrb    := (cTrbBrowse)->(GetArea())
local aParam      := {mv_par01, mv_par02, mv_par03, mv_par04, mv_par05}
local cFillPerg   := "VAPCPA053"
local nMaxTrato   := u_GetNroTrato()
local nPos        := oBrowse:nAt
local aPosSX1     := {{ cFillPerg, "01", 0},;
                      { cFillPerg, "02", Replicate(" ", TamSX3("ZRT_ROTA")[1])},;
                      { cFillPerg, "03", Replicate("Z", TamSX3("ZRT_ROTA")[1])},;
                      { cFillPerg, "04", Replicate(" ", TamSX3("Z08_CODIGO")[1])},;
                      { cFillPerg, "05", Replicate("Z", TamSX3("Z08_CODIGO")[1]) }}
private cCodDieta := ""

EnableKey(.T.)

    if Z0R->Z0R_LOCK <= '1'
        AtuSX1(@cFillPerg)
        U_PosSX1(aPosSX1)
        if Pergunte(cFillPerg)
            if mv_par01 <= 0
                Help(/*Descontinuado*/,/*Descontinuado*/,"QTDE TRATO INVALIDA",/**/,"A quantidade de tratos deve ser maior que 0.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, digite uma quatidade de tratos válida." })
            elseif mv_par01 > nMaxTrato
                Help(/*Descontinuado*/,/*Descontinuado*/,"QTDE TRATO INVALIDA",/**/,"A quantidade de tratos deve ser menor que " + AllTrim(Str(nMaxTrato)) +".", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, digite uma quatidade de tratos válida." })
            else    
                FWMsgRun(, { || ProcTrato()}, "Nro de Tratos", "Ajustando numero de tratos para " + AllTrim(Str(mv_par01))+ "...")
            endif
        endif
        mv_par01 := aParam[1]; mv_par02 := aParam[2]; mv_par03 := aParam[3]; mv_par04 := aParam[4]; mv_par05 := aParam[5]
    elseif Z0R->Z0R_LOCK = '2' 
        Help(,, "OPERACAO NAO PERMITDA.",, "Não é possível alterar o trato pois ele já foi Publicado.", 1, 0,,,,,, {"Operação não permitida."})
    elseif Z0R->Z0R_LOCK = '3' 
        Help(,, "OPERACAO NAO PERMITDA.",, "Não é possível alterar o trato pois ele foi Encerrado.", 1, 0,,,,,, {"Operação não permitida."})
    endif

    (cTrbBrowse)->(RestArea(aAreaTrb))
    oBrowse:nAt := nPos 
    oBrowse:Refresh()

EnableKey(.T.)
    
return nil

/*04-01-2021
Arthur Toshio
Realiza Transferencia entre currais
*/
user function vap05tcu()
local aAreaTrb    := (cTrbBrowse)->(GetArea())
local aParam      := {mv_par01, mv_par02}
local cFillPerg   := "VAPCPA05A"
local nPos        := oBrowse:nAt
local aPosSX1     :={{ cFillPerg, "01", Replicate(" ", TamSX3("B8_X_CURRA")[1])},;
                     { cFillPerg, "02", Replicate("Z", TamSX3("B8_X_CURRA")[1]) }}
private cCodDieta := ""

EnableKey(.T.)

    if !Z0R->Z0R_LOCK == '1'
        
        Help(,, "ATENÇÃO.",, "A operação de Transferencia NÃO atualiza os arquivos de Meta do trato.. Caso Necessário, deve-se exportar/gerar novamente o arquivo ", 1, 0,,,,,, {"Será atualizado apenas a Localização do Lote, Roteirização e Planejaento de Trato"})
    EndIf 
        AtuSX1(@cFillPerg)
        U_PosSX1(aPosSX1)
        if Pergunte(cFillPerg)
            if Empty(mv_par01) .or. Empty(mv_par02)
                Help(/*Descontinuado*/,/*Descontinuado*/,"",/**/,"Deve-se informar o curral de origem e curral de destino para realizar a transferencia", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, digite os parâmetros corretamente." })
            ElseIf mv_par01 == mv_par02
                Help(,, "OPERACAO NAO PERMITDA.",, "Foi selecionado o mesmo curral para origem e destino.", 1, 0,,,,,, {"Operação não permitida."})
            ElseIf !Empty(mv_par01) .and. !Empty(mv_par02)
                FWMsgRun(, { || ProcTransf()}, "Transferencia de Currais", "Ajustando os currais " + AllTrim(mv_par01)+ "...")
            endif
        endif
        mv_par01 := aParam[1]; mv_par02 := aParam[2]
    /*
    elseif Z0R->Z0R_LOCK = '2' 
        Help(,, "OPERACAO NAO PERMITDA.",, "Não é possível alterar o trato pois ele já foi Publicado.", 1, 0,,,,,, {"Operação não permitida."})
    elseif Z0R->Z0R_LOCK = '3' 
        Help(,, "OPERACAO NAO PERMITDA.",, "Não é possível alterar o trato pois ele foi Encerrado.", 1, 0,,,,,, {"Operação não permitida."})
    endif
    */
    (cTrbBrowse)->(RestArea(aAreaTrb))
    LoadTrat(Z0R->Z0R_DATA)
    oBrowse:nAt := nPos 
    oBrowse:Refresh()

EnableKey(.T.)
    
return nil


/*/{Protheus.doc} ProcTrato
Filtra os registros do browse que deverão sofrer alteração na quantidade de tratos
@author jr.andre
@since 30/08/2019
@version 1.0
@return nil
@type function
/*/
static function ProcTrato()

    DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                              " select R_E_C_N_O_ RECNO" +; 
                                " from " + oTmpZ06:GetRealName() +;
                               " where Z0T_ROTA between '" + mv_par02 + "' and '" + mv_par03 + "'" +; 
                                 " and Z08_CODIGO between '" + mv_par04 + "' and '" + mv_par05 + "'" +;
                                 " and B8_LOTECTL <> '" + Space(TamSX3("B8_LOTECTL")[1]) + "'" +;
                                 " and D_E_L_E_T_ = ' '" ;
                                         ), "TRBTMP", .F., .F.)

    begin transaction
        while !TRBTMP->(Eof())
            (cTrbBrowse)->(DbGoTo(TRBTMP->RECNO))
            if Z05->(DbSeek(FWxFilial("Z05")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO+(cTrbBrowse)->Z08_CODIGO+(cTrbBrowse)->B8_LOTECTL)) 
                if !AjuNroTrat(mv_par01)
                    Help(,, "CANUSEZ05.",, "Curral " + AllTrim((cTrbBrowse)->Z08_CODIGO) + " - Lote " + ((cTrbBrowse)->B8_LOTECTL) + "  em uso.", 1, 0,,,,,, {"A operação será cancelada."})
                    DisarmTransaction()
                    break
                endif
            else
                Help(/*Descontinuado*/,/*Descontinuado*/,"NAO EXISTE TRATO",/**/,"Não existe trato para o curral " + (cTrbBrowse)->Z08_CODIGO + ". É necessário criar o trato manualmente para ele.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"O trato não foi alterado."})
            endif
            TRBTMP->(DbSkip())
        end
    end transaction

    TRBTMP->(DbCloseArea())

return nil


/*04-01-2021
Arthur Toshio
*/
static function procTransf()
    //verifica se o Curral de destino já está ocupado com um lote
    DbUseArea(.T., "TOPCONN", TCGenQry(,,;                            
                                " SELECT DISTINCT B8_X_CURRA, B8_LOTECTL " +;
                                "   FROM " + RetSqlName("SB8")+ " " +;
                                "  WHERE B8_FILIAL = '" +FwXFilial("SB8")+ "' " +;
                                "    AND B8_SALDO > 0 " +;
                                "	AND B8_X_CURRA = '"+MV_PAR02+"' " +;
                                "	AND D_E_L_E_T_ = ' '" ), "TMPSB81", .F., .F.)
    
        If !TMPSB81->(Eof())
            Help(,, "CURRAL OCUPADO.",, "O Curral  " + AllTrim(MV_PAR02) + " Está ocupado com o Lote " + alltrim((TMPSB81->B8_LOTECTL)) + "  Verifique e tente novamente.", 1, 0,,,,,, {"A operação será cancelada."})
        
        //Caso não esteja, permite fazer a transferencia.
        ElseIf TMPSB81->(Eof())
            // levantar dados da Z08 para inserir na 
            DbUseArea(.T., "TOPCONN", TCGenQry(,,;                            
                                "SELECT Z08_FILIAL, Z08_CODIGO, Z08_LINHA, Z08_SEQUEN, Z08_CONFNA" +;
                                "  FROM " + RetSqlName("Z08010")+ " " +;
                                " WHERE Z08_FILIAL = '" +FwXFilial("Z08")+ "' " +;
                                "   AND Z08_CODIGO = '"+MV_PAR02+"' " +;
                                "   AND D_E_L_E_T_ = ' ' " ), "TMPSZ08", .F., .F.)

            //Valida lote de origem
            DbUseArea(.T., "TOPCONN", TCGenQry(,,;                            
                                    " SELECT DISTINCT B8_X_CURRA, B8_LOTECTL " +;
                                    "   FROM " + RetSqlName("SB8")+ " " +;
                                    "  WHERE B8_FILIAL = '" +FwXFilial("SB8")+ "' " +;
                                    "    AND B8_SALDO > 0 " +;
                                    "	AND B8_X_CURRA = '"+MV_PAR01+"' " +;
                                    "	AND D_E_L_E_T_ = ' '" ), "TMPSB82", .F., .F.)
            
            DbUseArea(.T., "TOPCONN", TCGenQry(,,;                            
                                    " SELECT Z0T_DATA, Z0T_CURRAL, Z0T_LOTE, Z0T_ROTA " +;
                                    "  FROM " + RetSqlName("Z0T")+ " " +; 
                                    " WHERE Z0T_FILIAL = '" +FwXFilial("SB8")+ "' " +;
                                    "   AND Z0T_DATA = '" +DToS(Z0R->Z0R_DATA)+ "' " +;
                                    "   AND Z0T_CURRAL = '" +TMPSB82->B8_X_CURRA+ "' " +;
                                    "   AND Z0T_LOTE = '" +TMPSB82->B8_LOTECTL+ "' " +;
                                    "   AND D_E_L_E_T_ = ' ' " ), "TMPZ0T", .F., .F.)

            DbUseArea(.T., "TOPCONN", TCGenQry(,,;                            
                                    " SELECT Z0T_DATA, Z0T_CURRAL, Z0T_LOTE, Z0T_ROTA " +;
                                    "  FROM " + RetSqlName("Z0T")+ " " +; 
                                    " WHERE Z0T_FILIAL = '" +FwXFilial("SB8")+ "' " +;
                                    "   AND Z0T_DATA = '" +DToS(Z0R->Z0R_DATA)+ "' " +;
                                    "   AND Z0T_CURRAL = '" +mv_par02+ "' " +;
                                    "   AND D_E_L_E_T_ = ' ' " ), "TMPZ0TD", .F., .F.)                                    


            If !TMPSB82->(Eof())
            
                If MsgYesno ("Deseja mesmo transferir o lote " + alltrim((TMPSB82->B8_LOTECTL)) + " do Curral " +ALLTRIM(mv_par01)+ " para o curral " +ALLTRIM(mv_par02)+ "??", "Transferencia de Currais")                
                
                //SB8 - SALDOS DOS LOTES
                    Begin Transaction
                        if TCSqlExec("UPDATE " + RetSqlName("SB8")+ " " +;
                                    "   SET B8_X_CURRA = '" +mv_par02+ "' " +;
                                    " WHERE B8_FILIAL = '" +FwXFilial("SB8")+ "' " +;
                                    "   AND B8_LOTECTL = '" +TMPSB82->B8_LOTECTL+ "'" +;
                                    "   AND D_E_L_E_T_ = ' ' " ) <0
                    
                            cErro := TCSQLError()
                            Help(/*Descontinuado*/,/*Descontinuado*/,"EXCLUSÃO DE TRATO",/**/,"Ocorreu um problema durante a exclusão dos ítens do trato do lote " + ALLTRIM(TMPSB82->B8_LOTECTL) + "." + CRLF + SubStr(cErro, 1, 250) + "...", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, tente novamente e caso o problema persista entre em contato com o TI-(2)." })
                            DisarmTransaction()
                            break
                        endif
                        
                        //Z05010  - PROGRAMAÇÃO DO DIA ATUAL
                        if TCSqlExec(" UPDATE " + RetSqlName("Z05")+ " " +;
                                        " SET Z05_CURRAL = '"+mv_par02+"' " +;
                                    " WHERE Z05_FILIAL = '" +FwXFilial("Z05")+ "' " +;
                                        " AND Z05_DATA =  '" +DToS(Z0R->Z0R_DATA)+ "' " +;
                                        " AND Z05_LOTE = '" +TMPSB82->B8_LOTECTL+ "' "+;
                                        " AND Z05_CURRAL = '" +TMPSB82->B8_X_CURRA+ "' "+; 
                                        " AND D_E_L_E_T_ = ' '") < 0
                            cErro := TCSQLError()
                            Help(/*Descontinuado*/,/*Descontinuado*/,"EXCLUSÃO DE TRATO",/**/,"Ocorreu um problema durante a exclusão dos ítens do trato do lote " + (TMPSB82)->B8_LOTECTL + "." + CRLF + SubStr(cErro, 1, 250) + "...", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, tente novamente e caso o problema persista entre em contato com o TI-(2)." })
                            DisarmTransaction()
                            break
                        endif
                        //Z06010  - PROGRAMAÇÃO DO DIA ATUAL - DETALHE
                        if TCSqlExec(" UPDATE " + RetSqlName("Z06")+ " " +;
                                        " SET Z06_CURRAL = '"+mv_par02+"' " +;
                                      " WHERE Z06_FILIAL = '" +FwXFilial("Z06")+ "' " +;
                                        " AND Z06_DATA =  '" +DToS(Z0R->Z0R_DATA)+ "' " +;
                                        " AND Z06_LOTE = '" +TMPSB82->B8_LOTECTL+ "' "+;
                                        " AND Z06_CURRAL = '" +TMPSB82->B8_X_CURRA+ "' "+; 
                                        " AND D_E_L_E_T_ = ' '") < 0
                            cErro := TCSQLError()
                            Help(/*Descontinuado*/,/*Descontinuado*/,"EXCLUSÃO DE TRATO",/**/,"Ocorreu um problema durante a exclusão dos ítens do trato do lote " + (TMPSB82)->B8_LOTECTL + "." + CRLF + SubStr(cErro, 1, 250) + "...", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, tente novamente e caso o problema persista entre em contato com o TI-(2)." })
                            DisarmTransaction()
                            break
                        endif

                        // ZOT - ROTEIRIZAÇÃO
                        if TCSqlExec("UPDATE " + RetSqlName("Z0T")+ " " +;  
                                    "   SET Z0T_LOTE = ' ' " +;
                                    "     , Z0T_ROTA = ' ' " +;
                                    " WHERE Z0T_FILIAL = '" +FwXFilial("Z0T")+ "' " +;
                                    "   AND Z0T_LOTE = '" +TMPSB82->B8_LOTECTL+ "'" +;
                                    "   AND Z0T_DATA = '" +DToS(Z0R->Z0R_DATA)+ "' " +;
                                    "   AND D_E_L_E_T_ = ' ' " ) < 0
                            cErro := TCSQLError()
                            Help(/*Descontinuado*/,/*Descontinuado*/,"EXCLUSÃO DE TRATO",/**/,"Ocorreu um problema durante a exclusão dos ítens do trato do lote " + (TMPSB82)->B8_LOTECTL + "." + CRLF + SubStr(cErro, 1, 250) + "...", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, tente novamente e caso o problema persista entre em contato com o TI-(2)." })
                            DisarmTransaction()
                            break
                        endif


                        If !TMPZ0TD->(Eof())
                            If MsgYesno ("Deseja manter o lote " + alltrim((TMPSB82->B8_LOTECTL)) + " do Curral " +ALLTRIM(mv_par01)+ " no roteiro " +ALLTRIM(TMPZ0T->Z0T_ROTA)+ "??", "Transferencia de Currais")                
                                //SE MANTEM NO MESMO ROTEIRO
                                if TCSqlExec("UPDATE " + RetSqlName("Z0T")+ " " +;
                                        "   SET Z0T_LOTE = '" +TMPZ0T->Z0T_LOTE+ "' " +;
                                        "     , Z0T_ROTA = '" +TMPZ0T->Z0T_ROTA+ "' " +;
                                        " WHERE Z0T_FILIAL = '" +FwXFilial("Z0T")+ "' " +;
                                        "   AND Z0T_CURRAL = '" +mv_par02+ "'" +;
                                        "   AND Z0T_DATA = '" +DToS(Z0R->Z0R_DATA)+ "' " +;
                                        "   AND Z0T_VERSAO = '" +Z0R->Z0R_VERSAO+ "' " +;
                                        "   AND D_E_L_E_T_ = ' ' " ) < 0
                                cErro := TCSQLError()
                                Help(/*Descontinuado*/,/*Descontinuado*/,"EXCLUSÃO DE TRATO",/**/,"Ocorreu um problema durante a exclusão dos ítens do trato do lote " + (TMPSB82)->B8_LOTECTL + "." + CRLF + SubStr(cErro, 1, 250) + "...", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, tente novamente e caso o problema persista entre em contato com o TI-(2)." })
                                DisarmTransaction()
                                break
                                endif   
                            Else 
                                if TCSqlExec("UPDATE " + RetSqlName("Z0T")+ " " +;
                                        "   SET Z0T_LOTE = '" +TMPZ0T->Z0T_LOTE+ "' " +;
                                        " WHERE Z0T_FILIAL = '" +FwXFilial("Z0T")+ "' " +;
                                        "   AND Z0T_CURRAL = '" +mv_par02+ "'" +;
                                        "   AND Z0T_DATA = '" +DToS(Z0R->Z0R_DATA)+ "' " +;
                                        "   AND Z0T_VERSAO = '" +Z0R->Z0R_VERSAO+ "' " +;
                                        "   AND D_E_L_E_T_ = ' ' " ) < 0
                                cErro := TCSQLError()
                                Help(/*Descontinuado*/,/*Descontinuado*/,"EXCLUSÃO DE TRATO",/**/,"Ocorreu um problema durante a exclusão dos ítens do trato do lote " + (TMPSB82)->B8_LOTECTL + "." + CRLF + SubStr(cErro, 1, 250) + "...", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, tente novamente e caso o problema persista entre em contato com o TI-(2)." })
                                DisarmTransaction()
                                break
                                endif
                            EndIf   

                        Else    
                              DbUseArea(.T., "TOPCONN", TCGenQry(,,;                            
                                    " SELECT Z0T_DATA, Z0T_CURRAL, Z0T_LOTE, Z0T_ROTA " +;
                                    "  FROM " + RetSqlName("Z0T")+ " " +; 
                                    " WHERE Z0T_FILIAL = '" +FwXFilial("SB8")+ "' " +;
                                    "   AND Z0T_DATA = '" +DToS(Z0R->Z0R_DATA)+ "' " +;
                                    "   AND D_E_L_E_T_ = ' ' " ), "TMPZ0TU", .F., .F.)

                            If !TMPZ0TU->(EOF())
                            ////If !Z0V->(DbSeek( FWxFilial("Z0V") + DToS(dDtTrato) + cVersao + (cAliasCmpQry)->G1_COMP ))
                                If MsgYesno ("Deseja manter o lote " + alltrim((TMPSB82->B8_LOTECTL)) + " do Curral " +ALLTRIM(mv_par01)+ " no roteiro " +ALLTRIM(TMPZ0T->Z0T_ROTA)+ "??", "Transferencia de Currais")                
                                    DBSelectArea("Z0T")
                                    Z0T->(DBSetOrder(1))        
                                    
                                    RecLock("Z0T", .T.)
                                        Z0T->Z0T_FILIAL := xFilial("Z0X")
                                        Z0T->Z0T_DATA   := Z0R->Z0R_DATA
                                        Z0T->Z0T_VERSAO := Z0R->Z0R_VERSAO
                                        Z0T->Z0T_ROTA   := TMPZ0T->Z0T_ROTA
                                        Z0T->Z0T_CONF   := TMPSZ08->Z08_CONFNA
                                        Z0T->Z0T_LINHA  := TMPSZ08->Z08_LINHA
                                        Z0T->Z0T_SEQUEN := TMPSZ08->Z08_SEQUEN
                                        Z0T->Z0T_CURRAL := TMPSZ08->Z08_CODIGO
                                        Z0T->Z0T_LOTE   := TMPZ0T->Z0T_LOTE
                                    MSUnlock()
                                Else
                                    DBSelectArea("Z0T")
                                    Z0T->(DBSetOrder(1))        

                                    RecLock("Z0T", .T.)
                                        Z0T->Z0T_FILIAL := xFilial("Z0X")
                                        Z0T->Z0T_DATA   := Z0R->Z0R_DATA
                                        Z0T->Z0T_VERSAO := Z0R->Z0R_VERSAO
                                        Z0T->Z0T_ROTA   := ""
                                        Z0T->Z0T_CONF   := TMPSZ08->Z08_CONFNA
                                        Z0T->Z0T_LINHA  := TMPSZ08->Z08_LINHA
                                        Z0T->Z0T_SEQUEN := TMPSZ08->Z08_SEQUEN
                                        Z0T->Z0T_CURRAL := TMPSZ08->Z08_CODIGO
                                        Z0T->Z0T_LOTE   := TMPZ0T->Z0T_LOTE
                                    MSUnlock()
                                EndIf
                            EndIf
                        TMPZ0TU->(DbCloseArea())
                        EndIf 
                    End Transaction
                EndIf
            EndIf
            TMPSB82->(DbCloseArea())
        TMPZ0T->(DbCloseArea())
        TMPZ0TD->(DbCloseArea())
        TMPSZ08->(DbCloseArea())
        
        EndIf
    TMPSB81->(DbCloseArea())
    
return nil



/*/{Protheus.doc} AjuNroTrat
Altera a quantidade tratos no lote posicionado
@author jr.andre
@since 30/08/2019
@version 1.0
@return logical, informa que a operação ocorreu com sucesso.
@param nQtdTrato, numeric, novo numero de tratos
@type function
/*/
static function AjuNroTrat(nQtdTrato)
local aArea   := GetArea()
local lRet    := .T.
local aKgMS   := {}
local i       := 0
local cSeq    := ""
local nMegCal := 0

    DbSelectArea("Z05")
    DbsetOrder(1) // Z05_FILIAL+DToS(Z05_DATA)+Z05_VERSAO+Z05_CURRAL+Z05_LOTE
    Z05->(DbSeek(FWxFilial("Z05")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO+(cTrbBrowse)->Z08_CODIGO+(cTrbBrowse)->B8_LOTECTL))

    if (lRet := CanUseZ05())

        DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                  " select count(*) QTDREG" +;
                                    " from (" +;
                                          " select distinct Z06_DIETA" +;
                                            " from " + RetSqlName("Z06") + " Z06" +;
                                           " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                                             " and Z06.Z06_DATA   = '" + DToS(Z0R->Z0R_DATA)+ "'" +;
                                             " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                                             " and Z06.Z06_CURRAL = '" + (cTrbBrowse)->Z08_CODIGO + "'" +;
                                             " and Z06.Z06_LOTE   = '" + (cTrbBrowse)->B8_LOTECTL + "'" +;
                                             " and Z06.D_E_L_E_T_ = ' '"  +;
                                         " ) Z06";
                                             ), "TMPZ06", .F., .F.)
            if TMPZ06->QTDREG > 1
                Help(/*Descontinuado*/,/*Descontinuado*/,"MULTIPLOS TRATOS",/**/,"Existe mais de um trato no filtro aplicado.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Não é possível alterar a quantidade de tratos em lotes com mais de um tipo de trato." })
                lRet := .F.
            endif
        TMPZ06->(DbCloseArea())

        if lRet
            DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                      " select distinct Z06_DIETA" +;
                                        " from " + RetSqlName("Z06") + " Z06" +;
                                       " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                                         " and Z06.Z06_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                                         " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                                         " and Z06.Z06_CURRAL = '" + (cTrbBrowse)->Z08_CODIGO + "'" +;
                                         " and Z06.Z06_LOTE   = '" + (cTrbBrowse)->B8_LOTECTL + "'" +;
                                         " and Z06.D_E_L_E_T_ = ' '"; 
                                                 ), "TMPZ06", .F., .F.)
                if Empty(cCodDieta)
                    cCodDieta := TMPZ06->Z06_DIETA
                elseif cCodDieta <> TMPZ06->Z06_DIETA
                    Help(/*Descontinuado*/,/*Descontinuado*/,"MULTIPLOS TRATOS",/**/,"Existe mais de um trato no filtro aplicado.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Não é possível alterar a quantidade de tratos para o filtro aplicado." })
                    lRet := .F.
                endif
            TMPZ06->(DbCloseArea())
        endif

        if lRet
            if TCSqlExec(" update " + RetSqlName("Z06") +;
                            " set D_E_L_E_T_ = '*'" +;
                          " where Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                            " and Z06_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                            " and Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                            " and Z06_CURRAL = '" + (cTrbBrowse)->Z08_CODIGO + "'" +;
                            " and Z06_LOTE   = '" + (cTrbBrowse)->B8_LOTECTL + "'" +;
                            " and D_E_L_E_T_ = ' '") < 0
                Help(/*Descontinuado*/,/*Descontinuado*/,"RECRIAÇÃO DO TRATO",/**/,"Ocorreu um problema durante a recriação do trato:" + CRLF + TCSQLError(), 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, entrem em contato com o TI e mostre o erro apresentado. O sistema retornará ao status anterior para garantir a integridade dos dados." })
                lRet := .F.
            endif

            if lRet
                aKgMS := DivTrato(Z05->Z05_KGMSDI, nQtdTrato)
                for i := 1 to nQtdTrato
                    nQuantMN := u_CalcQtMN(cCodDieta, aKgMS[i])
                    nMegCal := GetMegaCal(cCodDieta) * aKgMS[i]
                    cSeq := GetSeq(cCodDieta)
                    
                    RecLock("Z06", .T.)
                        Z06->Z06_FILIAL := FWxFilial("Z06")
                        Z06->Z06_DATA   := Z0R->Z0R_DATA
                        Z06->Z06_VERSAO := Z0R->Z0R_VERSAO
                        Z06->Z06_CURRAL := (cTrbBrowse)->Z08_CODIGO
                        Z06->Z06_LOTE   := (cTrbBrowse)->B8_LOTECTL
                        Z06->Z06_TRATO  := StrZero(i, TamSX3("Z06_TRATO")[1]) 
                        Z06->Z06_DIETA  := cCodDieta 
                        Z06->Z06_KGMSTR := aKgMS[i]
                        Z06->Z06_KGMNTR := nQuantMN
                        Z06->Z06_MEGCAL := nMegCal
                        Z06->Z06_KGMNT  := nQuantMN * Z05->Z05_CABECA
                        Z06->Z06_DIAPRO := Z05->Z05_DIAPRO
                        Z06->Z06_SEQ    := cSeq
                    MsUnlock()
                next

                RecLock("Z05", .F.)
                    Z05->Z05_MANUAL := "1"
                    Z05->Z05_NROTRA := nQtdTrato
                MsUnlock()

            endif
            if FunName() == "VAPCPA05"
                UpdTrbTmp() // Atualiza a quantidade de trato tabela temporária
            endif
        endif

    endif
    RestArea(aArea)
return lRet


/*/{Protheus.doc} vap05msc
Altera a quantidade de materia seca do lote posicionado
@author jr.andre
@since 30/08/2019
@version 1.0
@return nil
@type function
/*/
user function vap05msc()
local aParam    :={mv_par01}
local lRet      := .F.
local cFillPerg := "VAPCPA052"

EnableKey(.F.)

    if Empty((cTrbBrowse)->B8_LOTECTL)
        Help(,, "OPERACAO NAO PERMITDA.",, "Não é possível alterar o trato pois não existe lote viculado ao curral posicionado.", 1, 0,,,,,, {"Operação não permitida."})
    elseif Z0R->Z0R_LOCK <= '1'
        if Z05->(DbSeek(FWxFilial("Z05")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO+(cTrbBrowse)->Z08_CODIGO+(cTrbBrowse)->B8_LOTECTL)) 
            EnableKey(.F.)
            AtuSX1(@cFillPerg)
            U_PosSX1({{cFillPerg, "01", (cTrbBrowse)->PROG_MS}})
            if (lRet := Pergunte(cFillPerg))
                if lRet .and. mv_par01 > GetMV("VA_MXVALTR",,15.0) 
                    lRet := MsgYesNo("O valor digitado " + AllTrim(Str(mv_par01)) + " é considerado muito grande para um trato. Pode ser que esse valor esteja errado. Confirma esse valor para o trato?", "Valor pode estar errado.")
                endif
                if lRet 
                    FWMsgRun(, { || AtuMatSec()}, "Materia Seca", "Ajustando a quantidade de materia seca para " + AllTrim(Str(mv_par01))+ "...")
                endif
                if FunName() == "VAPCPA05"
                    UpdTrbTmp() // Atualiza a quantidade de trato tabela temporária
                endif
            endif
            mv_par01 := aParam[1]
            EnableKey(.T.)
        else
            Help(/*Descontinuado*/,/*Descontinuado*/,"NAO EXISTE TRATO",/**/,"Não existe trato para o curral posicionado.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Utilize o botão manutenção para criar o trato."})
        endif
    elseif Z0R->Z0R_LOCK = '2' 
        Help(,, "OPERACAO NAO PERMITDA.",, "Não é possível alterar o trato pois ele já foi Publicado.", 1, 0,,,,,, {"Operação não permitida."})
    elseif Z0R->Z0R_LOCK = '3' 
        Help(,, "OPERACAO NAO PERMITDA.",, "Não é possível alterar o trato pois ele foi Encerrado.", 1, 0,,,,,, {"Operação não permitida."})
    endif

EnableKey(.T.)

return lRet


/*/{Protheus.doc} AtuMatSec
Ajusta a quantidade de materia seca para o lote de acordo com a pergunta VAPCPA052.
@author jr.andre
@since 30/08/2019
@version 1.0
@return nil
@type function
/*/
static function AtuMatSec()
local aArea     := GetArea()
local i         := 1
local nQtdTrato := 0
local aKgMS     := {}
local nQtdeMS   := 0
local nQtdeMN   := 0
local nQtdMCal  := 0

    DbSelectArea("Z05")
    DbsetOrder(1) // Z05_FILIAL+DToS(Z05_DATA)+Z05_VERSAO+Z05_CURRAL+Z05_LOTE
    if Z05->(DbSeek(FWxFilial("Z05")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO+(cTrbBrowse)->Z08_CODIGO+(cTrbBrowse)->B8_LOTECTL))

        if CanUseZ05()

            DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                      " select count(*) NRTRAT" +;
                                        " from " + RetSqlName("Z06") + " Z06" +;
                                       " where Z06.Z06_FILIAL  = '" + FWxFilial("Z06") + "'" +;
                                         " and Z06.Z06_DATA    = '" + DToS(Z0R->Z0R_DATA) + "'" +; 
                                         " and Z06.Z06_VERSAO  = '" + Z0R->Z0R_VERSAO + "'" +;
                                         " and Z06.Z06_CURRAL  = '" + (cTrbBrowse)->Z08_CODIGO + "'" +;
                                         " and Z06.Z06_LOTE    = '" + (cTrbBrowse)->B8_LOTECTL + "'" +;
                                         " and Z06.D_E_L_E_T_  = ' '";
                                                 ),"TMPZ06",.F.,.F.)
                nQtdTrato := TMPZ06->NRTRAT
                aKgMS := DivTrato(mv_par01, TMPZ06->NRTRAT)
            TMPZ06->(DbCloseArea())
    
            DbSelectArea("Z06")
            DbSetOrder(1) // Z06_FILIAL+DToS(Z06_DATA)+Z06_VERSAO+Z06_CURRAL+Z06_LOTE+Z06_TRATO
            if Z06->(DbSeek(FWxFilial("Z06")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO+(cTrbBrowse)->Z08_CODIGO+(cTrbBrowse)->B8_LOTECTL))
                while !Z06->(Eof()) .and. Z06->Z06_FILIAL == FWxFilial("Z06") .and. Z06->Z06_DATA == Z0R->Z0R_DATA .and. Z06->Z06_VERSAO == Z0R->Z0R_VERSAO .and. Z06->Z06_CURRAL == (cTrbBrowse)->Z08_CODIGO .and. Z06->Z06_LOTE == (cTrbBrowse)->B8_LOTECTL
                    RecLock("Z06", .F.)
                        Z06->Z06_KGMSTR := aKgMS[i]
                        Z06->Z06_KGMNTR := u_CalcQtMN(Z06->Z06_DIETA, aKgMS[i])
                        Z06->Z06_MEGCAL := GetMegaCal(Z06->Z06_DIETA) * aKgMS[i]
                        Z06->Z06_KGMNT  := u_CalcQtMN(Z06->Z06_DIETA, aKgMS[i]) * (cTrbBrowse)->B8_SALDO
                    MsUnlock()
                    nQtdeMS += Z06->Z06_KGMSTR
                    nQtdeMN += Z06->Z06_KGMNTR
                    nQtdMCal += Z06->Z06_MEGCAL
                    i++
                    Z06->(DbSkip())
                end
            endif
            
            RecLock("Z05", .F.)
                Z05->Z05_KGMSDI := Z05->Z05_TOTMSI := mv_par01 
                Z05->Z05_KGMNDI := Z05->Z05_TOTMNI := nQtdeMN
                Z05->Z05_CMSPN  := (mv_par01 / Z05->Z05_PESMAT) *100
                Z05->Z05_MEGCAL := nQtdMCal

                Z05->Z05_MANUAL := '1'
                Z05->Z05_ORIGEM := '3'
            MsUnlock()
            ReleaseZ05()
        endif
    else
        u_vap05man()
    endif

RestArea(aArea)
return nil


/*/{Protheus.doc} vapcp05Evt
Classe para tratament dos eventos da tela
@author jr.andre
@since 30/08/2019
@version 1.0
@type class
/*/
class vapcp05Evt from FWmodelEvent
    method New() constructor
    method DeActivate(oModel) // quando ocorrer a desativação do Model.
end class


/*/{Protheus.doc} New
Instancia a classe vapcp05Evt
@author jr.andre
@since 30/08/2019
@version 1.0
@return nil
@type function
/*/
method New() class vapcp05Evt
return


/*/{Protheus.doc} DeActivate
Executado após a liberação da interface. Remove os atalhos e atualiza o browse.
@author jr.andre
@since 30/08/2019
@version 1.0
@return nil
@param oModel, object, descricao
@type method
/*/
method DeActivate(oModel) class vapcp05Evt

SetKey(VK_F4, nil)
SetKey(VK_F5, nil)
SetKey(VK_F6, nil) 
SetKey(VK_F7, nil) 

EnableKey(.T.)

if Type("oBrowse") <> 'U'
    oBrowse:Refresh()
endif

return nil


/*/{Protheus.doc} EnableKey
Habilita e desabilita as teclas de atalho da rotina
@author jr.andre
@since 29/08/2019
@version 1.0
@return nil
@param lEnable, logical, Indica se deve habilitar as teclas de atalho (.T.) ou desabilitar (.F.)
@type function
/*/
static function EnableKey(lEnable)
    if lEnable
        //SetKey(VK_F4,  {|| u_vap05tcu()}) // Transf. Currais
        SetKey(VK_F5,  {|| u_vap05rcr()}) // Recria Trato
        SetKey(VK_F6,  {|| u_vap05man()}) // Manutenção
        SetKey(VK_F7,  {|| u_vap05arq()}) // Gerar Arquivos
        SetKey(VK_F8,  {|| u_vap05tra()}) // Nro Tratos
        SetKey(VK_F9,  {|| u_vap05msc()}) // Matéria Seca
        SetKey(VK_F10, {|| u_vap05trt()}) // Dietas
        SetKey(VK_F11, {|| u_vap05rec()}) // Recarrega Browse
        SetKey(VK_F12, {|| u_vap05cri()}) // Criar trato
    else
        //SetKey(VK_F4,  nil) // Transf. Currais
        SetKey(VK_F5,  nil) // Recria Trato
        SetKey(VK_F6,  nil) // Manutenção
        SetKey(VK_F7,  nil) // Gerar Arquivos
        SetKey(VK_F8,  nil) // Nro Tratos
        SetKey(VK_F9,  nil) // Matéria Seca
        SetKey(VK_F10, nil) // Dietas
        SetKey(VK_F11, nil) // Recarrega Browse
        SetKey(VK_F12, nil) // Criar trato
    endif
return nil


/*/{Protheus.doc} vap05rem
Exclui o trato do curral posicionado
@author jr.andre
@since 29/08/2019
@version 1.0
@return nil
@type function
/*/
user function vap05rem()
local cErro := ""

if MsgYesNo("O curral " + AllTrim((cTrbBrowse)->Z08_CODIGO) + ", lote " + AllTrim((cTrbBrowse)->B8_LOTECTL) + " será excluido. Confirma a exclusão?", "Exclusão de registro.")
    begin transaction 

        if TCSqlExec(" update " + RetSqlName("Z05") +;
                        " set D_E_L_E_T_ = '*'" +;
                      " where Z05_FILIAL = '" + FWxFilial("Z05") + "'" +;
                        " and Z05_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                        " and Z05_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                        " and Z05_CURRAL = '" + (cTrbBrowse)->Z08_CODIGO + "'" +;
                        " and Z05_LOTE   = '" + (cTrbBrowse)->B8_LOTECTL + "'" +;
                        " and D_E_L_E_T_ = ' '" ;
                                ) < 0 
            cErro := TCSQLError()
            Help(/*Descontinuado*/,/*Descontinuado*/,"EXCLUSÃO DE TRATO",/**/,"Ocorreu um problema durante a exclusão dos ítens do trato do lote " + (cTrbBrowse)->B8_LOTECTL + "." + CRLF + SubStr(cErro, 1, 250) + "...", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, tente novamente e caso o problema persista entre em contato com o TI-(2)." })
            DisarmTransaction()
            break
        endif

        if TCSqlExec(" update " + RetSqlName("Z06") +;
                        " set D_E_L_E_T_ = '*'" +;
                      " where Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                        " and Z06_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                        " and Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                        " and Z06_CURRAL = '" + (cTrbBrowse)->Z08_CODIGO + "'" +;
                        " and Z06_LOTE   = '" + (cTrbBrowse)->B8_LOTECTL + "'" +;
                        " and D_E_L_E_T_ = ' '") < 0
            cErro := TCSQLError()
            Help(/*Descontinuado*/,/*Descontinuado*/,"EXCLUSÃO DE TRATO",/**/,"Ocorreu um problema durante a exclusão dos ítens do trato do lote " + (cTrbBrowse)->B8_LOTECTL + "." + CRLF + SubStr(cErro, 1, 250) + "...", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, tente novamente e caso o problema persista entre em contato com o TI-(2)." })
            DisarmTransaction()
            break
        endif
        /* 21-12-2020 - Arthur Toshio
           Liberar o curral na roteirizçaão para receber outro lote (quando utilizar a exclusão).
        */
        if TCSqlExec(" update " + RetSqlName("Z0T") +;
                        " set Z0T_LOTE = ' '," +;
                            " Z0T_ROTA = ' '" +;
                      " where Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" +;
                        " and Z0T_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                        " and Z0T_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                        " and Z0T_CURRAL = '" + (cTrbBrowse)->Z08_CODIGO + "'" +;
                        " and Z0T_LOTE   = '" + (cTrbBrowse)->B8_LOTECTL + "'" +;
                        " and D_E_L_E_T_ = ' '") < 0
            cErro := TCSQLError()
            Help(/*Descontinuado*/,/*Descontinuado*/,"EXCLUSÃO DE TRATO",/**/,"Ocorreu um problema durante a exclusão dos ítens do trato do lote " + (cTrbBrowse)->B8_LOTECTL + "." + CRLF + SubStr(cErro, 1, 250) + "...", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, tente novamente e caso o problema persista entre em contato com o TI-(3)." })
            DisarmTransaction()
            break
        endif

        if FunName() == "VAPCPA05"
            UpdTrbTmp(.T.)
        endif
    end transaction

    LogTrato("Exclusão do trato para o lote" + (cTrbBrowse)->B8_LOTECTL + ".", Iif(Empty(cErro), "Trato excluido com sucesso.", "Ocorreu um problema durante a exclusão do cabeçalho do trato do lote " + (cTrbBrowse)->B8_LOTECTL + "." + CRLF + cErro))
endif

return nil 


/*/{Protheus.doc} CurrVazio
Cria o trato para um curral vazio
@author jr.andre
@since 29/08/2019
@version 1.0
@return nil
@type function
/*/
static function CurrVazio()
local aParam    := {mv_par01, mv_par02, mv_par03, mv_par04, mv_par05}
local lRet      := .T.
local cFillPerg := "VAPCPA054 "
local nMaxTrato := u_GetNroTrato()
local cTrbAlias := ""
local nPos      := oBrowse:nAt
local nQtdTrato := 0
local i
local cSeq      := ""
local nKgMnTot  := 0

    EnableKey(.F.)
    AtuSX1(@cFillPerg)
    U_PosSX1({{cFillPerg, "01", Space(TamSX3("Z08_CODIGO")[1])},;
              {cFillPerg, "02", Space(TamSX3("B8_LOTECTL")[1])},;
              {cFillPerg, "03", Space(TamSX3("B8_X_CURRA")[1])},;
              {cFillPerg, "04", 0},;
              {cFillPerg, "05", 0},;
              {cFillPerg, "06", 0}})
    if (lRet := Pergunte(cFillPerg))

        DbSelectArea("Z05")
        DbSetOrder(2) // Z05_FILIAL+Z05_LOTE
        
        DbSelectArea("Z08")
        DbSetOrder(1) // Z08_FILIAL+Z08_CODIGO

        DbSelectArea("SB8")
        DbSetOrder(7) //B8_FILIAL+B8_LOTECTL+B8_X_CURRA

        // Valida se os parâmetros estão OK.  
        DbSelectArea("SB1")
        DbSetOrder(1) // B1_FILIAL + B1_COD

        if !Z08->(DbSeek(FWxFilial("Z08")+mv_par01))
            Help(,, "Curral inválido",, "O código digitado não pertence a um curral válido.", 1, 0,,,,,, {"Por favor digite um curral válido ou selecione." + CRLF + "<F3 Disponível>."})
            lRet := .F.
        endif

        if lRet .and. !SB8->(DbSeek(FWxFilial("Z08")+mv_par02))
            Help(,, "Lote inválido",, "O código digitado não pertence a um lote válido.", 1, 0,,,,,, {"Por favor digite um lote válido ou selecione." + CRLF + "<F3 Disponível>."})
            lRet := .F.
        endif

        if lRet .and. mv_par06 <= 0
            Help(,, "Quantidade de cabeças inválida",, "A quantidade de cabeças deve ser maior que 0.", 1, 0,,,,,, {"Por favor digite uma quantidade válida."})
            lRet := .F.
        endif

        if lRet
            cTrbAlias := CriaTrab(, .F.)
            DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                      "select count(*) QTDREG " +;
                                        "from " + RetSqlName("SB8") +;
                                      " where B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                                        " and B8_LOTECTL = '" + mv_par02 + "'" +;
                                        " and B8_SALDO   <> 0 " +;
                                        " and D_E_L_E_T_ = ' '";
                                                 ), cTrbAlias, .F., .F.)
                if (cTrbAlias)->QTDREG > 0
                    Help(,, "Lote inválido",, "O código do lote digitado possui saldo. Para alterar as quantidades desse lote selecione-o no browse. ", 1, 0,,,,,, {"Por favor digite um lote válido ou selecione." + CRLF + "<F3 Disponível>."})
                    lRet := .F.
                endif
            (cTrbAlias)->(DbCloseArea())
        endif

        if lRet .and. !SB1->(DbSeek(FWxFilial("SB1")+mv_par03)) .or. SB1->B1_X_TRATO!='1'
            Help(,, "Dieta Inválida",, "O código digitado não pertence a um produto válido ou esse produto não é uma dieta.", 1, 0,,,,,, {"Por favor digite uma dieta válida ou selecione." + CRLF + "<F3 Disponível>."})
            lRet := .F.
        endif

        if lRet .and. mv_par04 <= 0
            Help(,, "Quantidade Inválida",, "A quantidade digitada deve ser superior a 0.", 1, 0,,,,,, {"Por favor, digite uma quantidade válida."})
            lRet := .F.
        endif

        if lRet .and. mv_par05 == 0
            Help(,, "Nro de Tratos Inválido",, "O número de tratos deve ser superior a 0.", 1, 0,,,,,, {"Por favor, digite uma um numero de tratos válido válida."})
            lRet := .F.
        endif

        if lRet .and. mv_par05 > nMaxTrato
            Help(,, "Nro de Tratos Inválido",, "O número de tratos deve ser menor que ou igual a " + AllTrim(Str(nMaxTrato)) + " de acordo com o parametrizado em VA_NTRATO.", 1, 0,,,,,, {"Por favor, digite uma um número de tratos válido."})
            lRet := .F.
        endif

        if lRet 
            cTrbAlias := CriaTrab(, .F.)
            DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                      " select SB8.B8_LOTECTL" +;
                                           " , Z0O.Z0O_GMD" +;
                                           " , sum(SB8.B8_QTDORI) B8_QTDORI" +;
                                           " , sum(B8_XPESOCO*B8_QTDORI)/sum(B8_QTDORI) B8_XPESOCO" +;
                                           " , min(SB8.B8_XDATACO) DT_INI_PROG" +;
                                           " , cast(convert(datetime, '" + DToS(Z0R->Z0R_DATA) + "', 103) - convert(datetime, min(SB8.B8_XDATACO), 103) as numeric) DIAINI" +;
                                       " from " + RetSqlName("SB8") + " SB8" +;
                                  " left join " + RetSqlName("Z0O") + " Z0O" +;
                                         " on Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" +;
                                        " and Z0O.Z0O_LOTE   = SB8.B8_LOTECTL" +;
                                        " and (" +;
                                                " '" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR" +;
                                             " or (Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        ')" +;
                                        " )" +;
                                        " and Z0O.D_E_L_E_T_ = ' '" +;  
                                      " where SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                                        " and B8_LOTECTL = '" + mv_par02 + "'" +;
                                        " and SB8.D_E_L_E_T_ = ' '" +;
                                   " group by SB8.B8_LOTECTL, Z0O.Z0O_GMD" ;
                                                 ), cTrbAlias, .F., .F.)

            begin transaction

                aKgMS := DivTrato(mv_par04, mv_par05)
                cSeq := GetSeq(mv_par03)
                for i := 1 to mv_par05
                    RecLock("Z06", .T.)
                        Z06->Z06_FILIAL := FwxFilial("Z06")
                        Z06->Z06_DATA   := Z0R->Z0R_DATA
                        Z06->Z06_VERSAO := Z0R->Z0R_VERSAO
                        Z06->Z06_CURRAL := Z05->Z05_CURRAL
                        Z06->Z06_LOTE   := Z05->Z05_LOTE
                        Z06->Z06_DIAPRO := Z05->Z05_DIAPRO
                        Z06->Z06_TRATO  := AllTrim(Str(i))
                        Z06->Z06_DIETA  := mv_par03
                        Z06->Z06_KGMSTR := aKgMS[i]
                        Z06->Z06_KGMNTR := u_CalcQtMN(mv_par03, aKgMS[i])
                        Z06->Z06_SEQ    := cSeq
                    MsUnlock()
                    nKgMnTot +=  Z06->Z06_KGMNTR * Z05->Z05_CABECA
                next
                
                // If AllTrim(LOTES->Z08_CODIGO) == "B08" .OR.;
                //     AllTrim(LOTES->Z08_CODIGO) == "B14"
                //     ConOut("BreakPoint")
                // EndIf
                
                _nMCALPR := 0
                DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                            _cSql := " SELECT distinct " + cValToChar( LOTES->Z0O_PESO ) +;
                                    " * G1_ENERG * (" + cValToChar( LOTES->Z0O_CMSPRE ) + "/100) AS MEGACAL"+CRLF+;
                                    " FROM SG1010 "+CRLF+;
                                    " WHERE G1_FILIAL = '" + xFilial('SG1') + "' "+CRLF+;
                                    "   AND G1_COD = '" + GetMV("VA_PCP07MC",,'FINAL') + "'"+CRLF+;
                                    "   AND D_E_L_E_T_ = ' '";
                            ),"TMPmgCal", .F., .F.)
                MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa05_Z05_MCALPR.SQL", _cSql)
                if (!TMPmgCal->(Eof()))
                    _nMCALPR := TMPmgCal->MEGACAL
                EndIf
                TMPmgCal->(DbCloseArea())    

                RecLock("Z05", .T.)
                    Z05->Z05_FILIAL := FWxFilial("Z05")
                    Z05->Z05_DIETA  := mv_par03
                    Z05->Z05_DATA   := Z0R->Z0R_DATA
                    Z05->Z05_VERSAO := Z0R->Z0R_VERSAO
                    Z05->Z05_CURRAL := mv_par01
                    Z05->Z05_LOTE   := mv_par02
                    Z05->Z05_CABECA := mv_par06 // (cTrbAlias)->B8_QTDORI
                    Z05->Z05_DIASDI := DiasDieta(mv_par02, Z0R->Z0R_DATA)
                    Z05->Z05_PESOCO := (cTrbAlias)->B8_XPESOCO
                    Z05->Z05_PESMAT := Iif((cTrbAlias)->B8_XPESOCO + Z05->Z05_DIASDI * (cTrbAlias)->Z0O_GMD > 9999.99, 9999.99, (cTrbAlias)->B8_XPESOCO + Z05->Z05_DIASDI * (cTrbAlias)->Z0O_GMD)
                    Z05->Z05_CMSPN  := Iif(Z05->Z05_PESMAT == 0, 1, Z05->Z05_KGMSDI/Z05->Z05_PESMAT*100)
                    Z05->Z05_MANUAL := '1'
                    Z05->Z05_KGMSDI := mv_par04
                    Z05->Z05_KGMNDI := u_CalcQtMN(mv_par03, mv_par04)
                    Z05->Z05_TOTMSI := Z05->Z05_KGMSDI
                    Z05->Z05_TOTMNI := Z05->Z05_KGMNDI
                    Z05->Z05_NROTRA := mv_par05
                    Z05->Z05_KGMNT  := nKgMnTot
                    Z05->Z05_MCALPR := _nMCALPR
                MsUnlock()

                CanUseZ05()

            end transaction

            // Ajusta TRB
            RecLock(cTrbBrowse, .T.)
                //(cTrbBrowse)->Z08_LINHA  := Posicione("Z08",1,FWxFilial("Z08")+Z05->Z05_CURRAL,"Z08_LINHA")
                (cTrbBrowse)->Z08_CODIGO := Z05->Z05_CURRAL
                (cTrbBrowse)->Z0T_ROTA   := CriaVar("Z0T_ROTA", .F.)
                (cTrbBrowse)->B8_LOTECTL := Z05->Z05_LOTE
                (cTrbBrowse)->Z05_PESMAT := Z05->Z05_PESMAT
                (cTrbBrowse)->CMS_PV     := Z05->Z05_CMSPN
                (cTrbBrowse)->B8_SALDO   := Z05->Z05_CABECA
                (cTrbBrowse)->Z05_DIASDI := Z05->Z05_DIASDI
                (cTrbBrowse)->NOTA_NOITE := CriaVar("Z0I_NOTTAR", .F.)
                (cTrbBrowse)->NOTA_MADRU := CriaVar("Z0I_NOTNOI", .F.)
                (cTrbBrowse)->NOTA_MANHA := CriaVar("Z0I_NOTMAN", .F.)
                (cTrbBrowse)->PROGANTMS  := 0
                (cTrbBrowse)->PROG_MS    := Z05->Z05_KGMSDI
                (cTrbBrowse)->NR_TRATOS  := Z05->Z05_NROTRA
                (cTrbBrowse)->PROGANTMN  := 0
                (cTrbBrowse)->PROG_MN    := Z05->Z05_KGMNDI

                for i := 1 to nNroTratos
                    if Z06->(DbSeek(FWxFilial("Z06")+DToS(Z05->Z05_DATA)+Z05->Z05_VERSAO+Z05->Z05_CURRAL+Z05->Z05_LOTE+AllTrim(Str(i))))
                        (cTrbBrowse)->&("Z06_DIETA" + StrZero(i, 1)) := Z06->Z06_DIETA
                        (cTrbBrowse)->&("Z06_KGMS" + StrZero(i, 1))  := Z06->Z06_KGMSTR
                        (cTrbBrowse)->&("Z06_KGMN" + StrZero(i, 1))  := Z06->Z06_KGMNTR
                        nQtdTrato++
                    else
                        (cTrbBrowse)->&("Z06_DIETA" + StrZero(i, 1)) := Space(TamSX3("Z06_DIETA")[1])
                        (cTrbBrowse)->&("Z06_KGMS" + StrZero(i, 1))  := 0
                        (cTrbBrowse)->&("Z06_KGMN" + StrZero(i, 1))  := 0
                    endif            
                    nKgMnTot += Z06->Z06_KGMNTR * (cTrbBrowse)->B8_SALDO
                next

                (cTrbBrowse)->Z05_MNTOT  := Round(nKgMnTot, TamSX3('Z05_TOTMNI')[2] )

                (cTrbBrowse)->QTDTRATO   := nQtdTrato

            MsUnlock()

            oBrowse:nAt := (cTrbBrowse)->(RecNo())
            oBrowse:Refresh()
        endif

    endif

    EnableKey(.T.)
    for i := 1 to Len(aParam)
        &("mv_par" + StrZero(i, 2)) := aParam[i]
    next

return lRet


/*/{Protheus.doc} vap05rec
Recarrega o browse
@author jr.andre
@since 29/08/2019
@version 1.0
@return nil
@type function
/*/
user function vap05rec()
    FWMsgRun(, { || LoadTrat(Z0R->Z0R_DATA) }, "Carregamento do trato", "Carregando trato")  
return nil

/*
    aSeekFiltr := { oBrowse:oBrowseUI:oFWSeek:cSeek,;
                    oBrowse:oBrowseUI:oFWSeek:lSeekAllFields,;
                    aClone(oBrowse:oBrowseUI:oFWSeek:aFldChecks),;
                    aClone(oBrowse:oBrowseUI:oFWSeek:aDetails) }
 */


/*/{Protheus.doc} vap05arq
Chama a rotina de geração de arquivos de acordo com o filtro passado
@author jr.andre
@since 22/08/2019
@version 1.0
@return nil
@type function
/*/
user function vap05arq()
local i, nLen
local cFilter := ""

    EnableKey(.F.)
    if !Empty(aSeekFiltr)
        if !aSeekFiltr[2] .and. !Empty(aSeekFiltr[1])
            for i := 1 to len(aSeekFiltr[3]) 
                if aSeekFiltr[3][i][1] 
                    if AllTrim(aSeekFiltr[4][i][1][5])$"Z0T_ROTA"
                        cFilter += Iif(!Empty(cFilter), " and ", "") + " Z0T_ROTA like '%" + AllTrim(aSeekFiltr[1]) + "%'"
                    elseif AllTrim(aSeekFiltr[4][i][1][5])$"ZV0_DESC"
                        DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                                                  " select ZV0.ZV0_CODIGO " +;
                                                    " from " + RetSqlName("ZV0") + " ZV0" +;
                                                   " where ZV0.ZV0_FILIAL = '" + FWxFilial("ZV0") + "'" +;
                                                     " and ZV0.ZV0_DESC   like '%" + AllTrim(aSeekFiltr[1]) + "%'" +;
                                                     " and ZV0.D_E_L_E_T_ = ' ' " ;
                                                             ),"TMPZV0")
                        if !TMPZV0->(Eof())
                            while !TMPZV0->(Eof())
                                cFilter += Iif(!Empty(cFilter), " or ", "(") + "ZV0_CODIGO = '" + TMPZV0->ZV0_CODIGO + "'"
                                TMPZV0->(DbSkip())
                            end
                            cFilter += ")"
                        endif
                        TMPZV0->(DbCloseArea())
                    endif
                endif
            next
        endif
    endif

    FWMsgRun(, { || u_vapcpa08(Z0R->Z0R_DATA, Z0R->Z0R_VERSAO, cFilter) }, "Carregando resumo", "Resumo de trato")
    EnableKey(.T.)

return nil


/*/{Protheus.doc} vap05trt
Altera as dietas dos currais de acordo com os parametros passados
@author jr.andre
@since 13/09/2019
@version 1.0
@return nil
@type function
/*/
user function vap05trt()
local aMVPar      := {}
local i, nQtdTr   := u_GetNroTrato()
local aParamBox   := {}
local lRet        := .F.

private nQtdTrato := 0

EnableKey(.F.)

    DbSelectArea("Z05")
    DbSetOrder(1) // Z05_FILIAL+DToS(Z05_DATA)+Z05_VERSAO+Z05_CURRAL+Z05_LOTE

    if Z0R->Z0R_LOCK <= '1'

        u_vap05rec()

        for i := 1 to 13
            AAdd(aMVPar, &("mv_par" + StrZero(i, 2)))
        next

        aParamBox := {{1, "Rota de", Space(TamSX3("Z0T_ROTA")[1]),,, "ZRT",, 40, .F.};
                     ,{1, "Rota até", Replicate("Z", TamSX3("Z0T_ROTA")[1]),,, "ZRT",, 40, .F.};
                     ,{1, "Curral de", Space(TamSX3("Z08_CODIGO")[1]),,, "Z08",, 80, .F.};
                     ,{1, "Curral até", Replicate("Z", TamSX3("Z08_CODIGO")[1]),,, "Z08",, 80, .F.};
                     }

        for i := 1 to nQtdTr
            AAdd(aParamBox, {1, "Dieta trato " + StrZero(i, 1), Space(TamSX3("Z06_DIETA")[1]),,, "DIETA",, 60, .F.})
        next

        if ParamBox(aParamBox, "Dietas", /*<@aRet>*/, {|| u_VldPBox()}, /*<aButtons >*/, /*<lCentered>*/, /*<nPosX>*/, /*<nPosY>*/, /*<oDlgWizard>*/, "VAP05TRT", .T., .F. )
            EnableKey(.F.)
                FWMsgRun(, { || u_RunDieta() }, "Ajustando Dietas", "Ajustando Dietas")
            EnableKey(.T.)
        endif

        nLen := Len(aMVPar)
        for i := 1 to nLen
            &("mv_par" + StrZero(i, 2)) := aMVPar[i]
        next

    elseif Z0R->Z0R_LOCK = '2' 
        Help(,, "OPERACAO NAO PERMITDA.",, "Não é possível alterar o trato pois ele já foi Publicado.", 1, 0,,,,,, {"Operação não permitida."})
    elseif Z0R->Z0R_LOCK = '3' 
        Help(,, "OPERACAO NAO PERMITDA.",, "Não é possível alterar o trato pois ele foi Encerrado.", 1, 0,,,,,, {"Operação não permitida."})
    endif

EnableKey(.T.)
    u_vap05rec()
return nil 


/*/{Protheus.doc} VldPBox
Valida os parametros da rotina vap05trt
@author guima
@since 13/09/2019
@version 1.0
@return Logical, .T. se os parametros foram validados
@type function
/*/
user function VldPBox()
local aArea    := GetArea()
local lRet     := .T.
local lExistTr := .F.
local cVar     := ""
local i
local nQtdTr   := u_GetNroTrato()

DbSelectArea("SB1")
DbSetOrder(1) // B1_FILIAL+B1_COD

for i := 1 to nQtdTr
    if !Empty(cVar := &("mv_par" + StrZero(4+i,2))) 
        if (!SB1->(DbSeek(FWxFilial("SB1")+cVar)) .or. SB1->B1_X_TRATO!='1' )
            Help(,, "Dieta Inválida",, "O código digitado no parametro " + StrZero(i+4,2) + " não pertence a um produto válido ou esse produto não é uma dieta.", 1, 0,,,,,, {"Por favor digite uma dieta válida ou selecione." + CRLF + "<F3 Disponível>."})
            lRet := .F.
            exit
        else
            lExistTr := .T.
        endif
    endif
next

if lRet .and. !lExistTr
    Help(,, "Dieta Inválida",, "Nenhum trato foi digitado.", 1, 0,,,,,, {"Por favor digite pelo menos um trato válido ou selecione." + CRLF + "<F3 Disponível>."})
    lRet := .F.
endif

return lRet


/*/{Protheus.doc} RunDieta
Percorre os currais selecionado e altera os tratos de acordo com os parametros da rotina vap05trt.
@author guima
@since 13/09/2019
@version 1.0
@return nil
@type function
/*/
user function RunDieta()
local i 
local nQtdTr := u_GetNroTrato()
local cTrato := ""
local aTrato := {}

    for i := 1 to nQtdTr
        if !Empty(cTrato := &("mv_par" + StrZero(i+4, 2)))
            AAdd(aTrato, {i, cTrato})
        endif
    next

    DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                    " select R_E_C_N_O_ RECNO" +;
                      " from " + oTmpZ06:GetRealName() +;
                     " where Z0T_ROTA between '" + mv_par01 + "' and '" + mv_par02 + "'" +;
                       " and Z08_CODIGO between '" + mv_par03 + "' and '" + mv_par04 + "'";
                                         ), "TRBTMP", .F., .F.)
    begin transaction
        while !TRBTMP->(Eof())
            (cTrbBrowse)->(DbGoTo(TRBTMP->RECNO))
            if Z05->(DbSeek(FWxFilial("Z05")+DToS(Z0R->Z0R_DATA)+Z0R->Z0R_VERSAO+(cTrbBrowse)->Z08_CODIGO+(cTrbBrowse)->B8_LOTECTL)) 
                if !AjuNroDiet(aTrato)
                    DisarmTransaction()
                    break
                endif
            else
                Help(/*Descontinuado*/,/*Descontinuado*/,"NAO EXISTE TRATO",/**/,"Não existe trato para o curral " + (cTrbBrowse)->Z08_CODIGO + ". É necessário criar o trato manualmente para ele.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"O trato não foi alterado."})
            endif
            TRBTMP->(DbSkip())
        end
    end transaction
    TRBTMP->(DbCloseArea())

return nil


/*/{Protheus.doc} AjuNroDiet
Altera os tratos do lote posicionado na tabela temporária de acordo com os parametros
@author jr.andre
@since 13/09/2019
@version 1.0
@return Logical, Retorna se a atualizão da dieta foi feita com sucesso
@param aTrato, Array, Array com as dietas a serem substituidas no formato { {nNroTrato, cDieta} [, {nNroTrato, cDieta}]}
@type function
/*/
static function AjuNroDiet(aTrato)
local aArea     := GetArea()
local lRet      := .T.
local aKgMS     := {}
local nTotMN    := 0
local i, nQtdTrato
local nMaxTrato := 0
local cDieta    := ""
local cSeq      := ""
local nMegCal   := 0
local nMCalTrt  := 0

    if (lRet := CanUseZ05())
        if TCSqlExec(" update " + RetSqlName("Z06") +;
                        " set D_E_L_E_T_ = '*'" +;
                      " where Z06_FILIAL = '" + FWxFilial("Z06") + "'" +;
                        " and Z06_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" +;
                        " and Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
                        " and Z06_CURRAL = '" + (cTrbBrowse)->Z08_CODIGO + "'" +;
                        " and Z06_LOTE   = '" + (cTrbBrowse)->B8_LOTECTL + "'" +;
                        " and D_E_L_E_T_ = ' '") < 0
            Help(/*Descontinuado*/,/*Descontinuado*/,"RECRIAÇÃO DO TRATO",/**/,"Ocorreu um problema durante a recriação do trato:" + CRLF + TCSQLError(), 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, entrem em contato com o TI e mostre o erro apresentado. O sistema retornará ao status anterior para garantir a integridade dos dados." })
            lRet := .F.
        else
            
            nQtdTrato := Len(aTrato)
            aKgMS := DivTrato(Z05->Z05_KGMSDI, nQtdTrato)

            for i := 1 to nQtdTrato
                nQuantMN := u_CalcQtMN(aTrato[i][2], aKgMS[i])
                nMCalTrt := GetMegaCal(aTrato[i][2]) * aKgMS[i]
                cSeq := GetSeq(aTrato[i][2])
                
                RecLock("Z06", .T.)
                    Z06->Z06_FILIAL := FWxFilial("Z06")
                    Z06->Z06_DATA   := Z05->Z05_DATA
                    Z06->Z06_VERSAO := Z05->Z05_VERSAO
                    Z06->Z06_CURRAL := Z05->Z05_CURRAL
                    Z06->Z06_LOTE   := Z05->Z05_LOTE
                    Z06->Z06_TRATO  := StrZero(aTrato[i][1], TamSX3("Z06_TRATO")[1]) 
                    Z06->Z06_DIETA  := aTrato[i][2]
                    Z06->Z06_KGMSTR := aKgMS[i]
                    Z06->Z06_KGMNTR := nQuantMN
                    Z06->Z06_MEGCAL := nMCalTrt
                    Z06->Z06_KGMNT  := nQuantMN * Z05->Z05_CABECA
                    Z06->Z06_DIAPRO := Z05->Z05_DIAPROF
                    Z06->Z06_SEQ    := cSeq
                MsUnlock()
                if nMaxTrato < aTrato[i][1]
                    nMaxTrato := aTrato[i][1]
                endif
                if !AllTrim(Z06->Z06_DIETA)$cDieta
                    cDieta += Iif(Empty(cDieta), "", ",") + AllTrim(Z06->Z06_DIETA) 
                endif
                nTotMN += Z06->Z06_KGMNTR
                nMegCal += nMCalTrt
            next

            RecLock("Z05", .F.)
                Z05->Z05_MANUAL := "1"
                Z05->Z05_NROTRA := nMaxTrato
                Z05->Z05_DIETA  := cDieta
                Z05->Z05_MANUAL := '1'
                Z05->Z05_KGMNDI := nTotMN
                Z05->Z05_MEGCAL := nMegCal
                Z05->Z05_TOTMNI := Z05->Z05_KGMNDI
            MsUnlock()
        endif

        FillEmpty()
        ReleaseZ05()
        if FunName() == "VAPCPA05"
            UpdTrbTmp() // Atualiza a quantidade de trato tabela temporária
        endif
    endif

    RestArea(aArea)
return lRet


/*/{Protheus.doc} GetSeq
Retorna o numero da sequencia da Estrutura de produtos
@author jr.andre
@since 13/09/2019
@version 1.0
@return cSeq, Numero da sequencia da Estrutura de produtos
@param cDieta, characters, descricao
@type function
/*/
static function GetSeq(cDieta)
local aArea := GetArea()
local cSeq  := ""

DbSelectArea("SG1")
SG1->(DbSetOrder(1)) // G1_FILIAL+G1_COD+G1_COMP+G1_TRT
SG1->(DbSeek(FWxFilial("SG1")+cDieta))
cSeq := SG1->G1_SEQ

if !Empty(aArea)
    RestArea(aArea)
endif
return cSeq

static function GetMegaCal(cDieta)
local aArea    := GetArea()
local nMegaCal := ""

DbSelectArea("SG1")
SG1->(DbSetOrder(1)) // G1_FILIAL+G1_COD+G1_COMP+G1_TRT
SG1->(DbSeek(FWxFilial("SG1")+cDieta))
nMegaCal := SG1->G1_ENERG

if !Empty(aArea)
    RestArea(aArea)
endif
return nMegaCal

/* MB : 04.03.2021
    -> Gera Z0V dos componentes quando produto gerado pela Phibro; */
Static Function GeraZ0VComp( _cComp, dDtTrato, cVersao)
Local aArea        := GetArea()
local cAliasCmpQry := GetNextAlias()

    DbUseArea(.T., "TOPCONN", TCGenQry(,,;
                        _cQry := " select COMPONENTES.G1_COMP" + _ENTER_ +;
                                "               , case when INDICES.Z0H_DATA is null then 'N' else 'S' end DIGITADO" + _ENTER_ +;
                                "               , INDICES.Z0H_DATA" + _ENTER_ +;
                                "               , INDICES.Z0H_HORA" + _ENTER_ +;
                                "               , INDICES.Z0H_INDMS" + _ENTER_ +;
                                "               , INDICES.Z0H_RECNO" + _ENTER_ +;
                                "               , G1_ORIGEM" + _ENTER_ +;
                                " from (" + _ENTER_ +;
                                "           select distinct G1_COMP, G1_ORIGEM" + _ENTER_ +;
                                "           from " + RetSqlName("SG1") + " COMP" + _ENTER_ +;
                                "           join " + RetSqlName("SB1") + " SB1 on SB1.B1_FILIAL  = '" + FwxFilial("SB1") + "'" + _ENTER_ +;
                                "                                               and SB1.B1_COD   = COMP.G1_COD -- AND SB1.B1_X_TRATO = '1'" + _ENTER_ +;
                                "                                               and SB1.B1_GRUPO in (" + GetMV("VA_GRTRATO") + ")" + _ENTER_ +;
                                "                                               and SB1.D_E_L_E_T_ = ' '" + _ENTER_ +;
                                "           where COMP.G1_FILIAL  = '" + FWxFilial("SG1") + "'" + _ENTER_ +;
                                "             -- and COMP.G1_ORIGEM <> 'P'" + _ENTER_ +;
                                "             AND G1_COD = '" + _cComp + "'" + _ENTER_ +;
                                "             and COMP.D_E_L_E_T_ = ' '" + _ENTER_ +;
                                " ) COMPONENTES" + _ENTER_ +;
                                " left join (" + _ENTER_ +;
                                "           select Z0H.Z0H_PRODUT, Z0H.Z0H_DATA, Z0H.Z0H_HORA, Z0H_INDMS, R_E_C_N_O_ Z0H_RECNO" + _ENTER_ +;
                                "           from " + RetSqlName("Z0H") + " Z0H" + _ENTER_ +;
                                "           where Z0H.Z0H_FILIAL = '" + FWxFilial("Z0H") + "'" + _ENTER_ +;
                                "             and Z0H.Z0H_VALEND = '1'" + _ENTER_ +;
                                "             and Z0H.Z0H_PRODUT + Z0H.Z0H_DATA + Z0H.Z0H_HORA in (" + _ENTER_ +;
                                "                                            select MAXZ0H.Z0H_PRODUT + max(MAXZ0H.Z0H_DATA+MAXZ0H.Z0H_HORA)" + _ENTER_ +;
                                "                                            from " + RetSqlName("Z0H") + " MAXZ0H" + _ENTER_ +;
                                "                                            where MAXZ0H.Z0H_FILIAL = '" + FWxFilial("Z0H") + "'" + _ENTER_ +;
                                "                                              and MAXZ0H.Z0H_DATA  <= '" + DToS(dDtTrato) + "'" + _ENTER_ +;
                                "                                              and MAXZ0H.Z0H_VALEND = '1'" + _ENTER_ +;
                                "                                              and MAXZ0H.D_E_L_E_T_ = ' '" + _ENTER_ +;
                                "                                            group by MAXZ0H.Z0H_PRODUT" + _ENTER_ +;
                                "                   )" + _ENTER_ +;
                                "              and Z0H.D_E_L_E_T_ = ' '" + _ENTER_ +;
                                " ) INDICES" + _ENTER_ +;
                                " on COMPONENTES.G1_COMP = INDICES.Z0H_PRODUT" ;
                                ), cAliasCmpQry, .F., .F.)

    MEMOWRITE("C:\TOTVS_RELATORIOS\CarregaIMS_" + DToS(dDtTrato) + "_comp.sql", _cQry)
    while !(cAliasCmpQry)->(Eof())

        Z0V->(DbSetOrder(1)) // Z0V_FILIAL+Z0V_DATA+Z0V_VERSAO+Z0V_COMP
        If !Z0V->(DbSeek( FWxFilial("Z0V") + DToS(dDtTrato) + cVersao + (cAliasCmpQry)->G1_COMP ))
            RecLock("Z0V", .T.)
                Z0V->Z0V_FILIAL := FWxFilial("Z0V")
                Z0V->Z0V_DATA   := dDtTrato
                Z0V->Z0V_VERSAO := cVersao
                Z0V->Z0V_COMP   := (cAliasCmpQry)->G1_COMP
                Z0V->Z0V_DTLEI  := SToD((cAliasCmpQry)->Z0H_DATA)
                Z0V->Z0V_HORA   := (cAliasCmpQry)->Z0H_HORA
                Z0V->Z0V_INDMS  := (cAliasCmpQry)->Z0H_INDMS
            MsUnlock()
        EndIf

        (cAliasCmpQry)->(DbSkip())
    EndDo
    (cAliasCmpQry)->(DbCloseArea())

RestArea(aArea)
Return nil
