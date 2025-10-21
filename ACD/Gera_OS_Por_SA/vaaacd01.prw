#include "Protheus.ch"
#include "TopConn.ch"
#include "DbTree.ch"

/*

vaaacd0100
mv_par01 - Opcao: Pedidos de Venda / Notas Fiscais / Ordens de Producao / Solicitação ao Armazem / Todos
mv_par02 - Atualiza automaticamente o browse?


Geração:
--------
vaaacd0101
mv_par01 - Opcao: Pedidos de Venda / Notas Fiscais / Ordens de Producao / Solicitação ao Armazem


Pedidos de Venda:
-----------------

vaaacd0106   - Parametros 
mv_par01 - Confere Lote        ? Sim/Nao
mv_par02 - Embal Simultanea    ? Sim/Nao
mv_par03 - Embalagem           ? Sim/Nao
mv_par04 - Gera Nota           ? Sim/Nao
mv_par05 - Imprime Nota        ? Sim/Nao
mv_par06 - Imprime Etiq.Volume ? Sim/Nao
mv_par07 - Embarque            ? Sim/Nao
mv_par08 - Aglutina Pedido     ? Sim/Nao
mv_par09 - Aglutina Armazem    ? Sim/Nao

vaaacd0102   - Filtros
mv_par01 - Separador           ?
mv_par02 - Pedido de           ?
mv_par03 - Pedido ate          ?
mv_par04 - Cliente de          ?
mv_par05 - Loja Cliente de     ?
mv_par06 - Cliente ate         ?
mv_par07 - Loja Cliente ate    ?
mv_par08 - Data Liberacao de   ?
mv_par09 - Data Liberacao ate  ?
mv_par10 - Pre-Separacao       ? Sim/Nao


Notas Fiscais:
--------------

vaaacd0107   - Parametros
mv_par01 - Embal Simultanea    ? Sim/Nao
mv_par02 - Embalagem           ? Sim/Nao
mv_par03 - Imprime Nota        ? Sim/Nao
mv_par04 - Imprime Etiq.Volume ? Sim/Nao
mv_par05 - Embarque            ? Sim/Nao

vaaacd0103   - Filtros
mv_par01 - Separador           ?
mv_par02 - Nota de             ?
mv_par03 - Serie de            ?
mv_par04 - Nota ate            ?
mv_par05 - Serie ate           ?
mv_par06 - Cliente de          ?
mv_par07 - Loja Cliente de     ?
mv_par08 - Cliente ate         ?
mv_par09 - Loja Cliente ate    ?
mv_par10 - Data emissao de     ?
mv_par11 - Data emissao ate    ?


Ordens de Producao:
-------------------

vaaacd0108   - Parametros
mv_par01 - Requisita material  ? Sim/Nao
mv_par02 - Aglutina Armazem    ? Sim/Nao

vaaacd0104   - Filtros
mv_par01 - Separador           ?
mv_par02 - Op de               ?
mv_par03 - Op ate              ?
mv_par04 - Data emissao de     ?
mv_par05 - Data emissao ate    ?
mv_par06 - Pre-Separacao       ?

Solicitação ao Armazem:
----------------------

vaaacd0105   - Filtros
mv_par01 - Separador           ?
mv_par02 - Pré-Separação       ?
mv_par03 - Separação de        ?
mv_par04 - Separação ate       ?
mv_par05 - Dt emissão de       ?
mv_par06 - Dt emissão ate      ?
mv_par07 - Dt PRF de           ?
mv_par08 - Dt PRF ate          ?
*/
user function VAAACD01()
local oBrw := nil
local nRefreTela := SuperGetMV('VA_BRWREFS', .f., 60) // Tempo de atualização de tela do browse em segundos

private aRotina := MenuDef()
private aRecno := {}

//Configuracoes da pergunte vaaacd0106 (Pedidos de Venda), ativado pela tecla F12:

private nConfLote
private nEmbSimul
private nEmbalagem
private nGeraNota
private nImpNota
private nImpEtVol
private nEmbarque
private nAglutPed
private nAglutArm

//Configuracoes da pergunte vaaacd0107 (Notas Fiscais), ativado pela tecla F12:
private nEmbSimuNF
private nEmbalagNF
private nImpNotaNF
private nImpVolNF
private nEmbarqNF

//Configuracoes da pergunte vaaacd0108 (Ordens de Producao), ativado pela tecla F12:
private nReqMatOP
private nAglutArmOP
private nPreSep

//Configuracoes da pergunte vaaacd0109 (Solicitação ao Armazém), ativado pela tecla F12:
private nReqMatSA
private nAglutArmSA

    Pergunte("VAAACD0100",.f.)

    SetKey( VK_F12, {|| AtivaF12()} )
    
    oBrw := FWMBrowse():New()
    
    oBrw:SetAlias("CB7")
    oBrw:SetDescription("Ordens de separacao")
    
//    oBrw:AddLegend("CB7->CB7_DIVERG == '1'",       "DISABLE",    "Divergencia")
    oBrw:AddLegend("CB7->CB7_STATUS == '9'",       "DISABLE",    "Baixado")
    oBrw:AddLegend("CB7->CB7_STATPA == '1'",       "BR_CINZA",   "Pausa")
//    oBrw:AddLegend("CB7->CB7_STATUS == '9'",       "ENABLE",     "Finalizado")
    oBrw:AddLegend("CB7->CB7_STATUS $ '12345678'", "BR_AMARELO", "Em andamento")
    oBrw:AddLegend("CB7->CB7_STATUS == '0'",       "BR_AZUL",    "Nao iniciado")
    
    if mv_par02==1
        oBrw:SetTimer({|| oBrw:Refresh() }, Iif(nRefreTela<=0, 3600, nRefreTela) * 1000)
        oBrw:SetIniWindow({||oBrw:oTimer:lActive := mv_par02==1})
    endif
    
    oBrw:Activate()
    
    SetKey(VK_F12,nil)

return nil


static function MenuDef()
local aRotina := {    {"Pesquisar",  "AxPesqui",  0, 1, 0},;
                      {"Visualizar", "u_macd01vs", 0, 2, 0},;
                      {"Alterar",    "u_macd01al", 0, 4, 0},;
                      {"Estornar",   "u_macd01es", 0, 5, 5},;
                      {"Gerar",      "u_macd01gr", 0, 3, 0},;
                      {"Impressao",  "u_macd01im", 0, 4, 0}}
return aRotina


user function macd01vs(cAlias,nReg,nOpcx)
local oDlg
local oGet

local cSeekCB8 := CB8->(xFilial("CB8")) + CB7->CB7_ORDSEP
local aSize := {}
local aInfo := {}
local aObjects := {}
local aButtons := {}
local lEmbal := ("01" $ CB7->CB7_TIPEXP) .OR. ("02" $ CB7->CB7_TIPEXP)

private oTimer
private Altera := .f.
private Inclui := .f.
private aHeader := {}
private aCols := {}
private aTela := {}, aGets := {}

private cBmp1 := "PMSEDT3"
private cBmp2 := "PMSDOC"

    SX3->(DbSetOrder(1))
    CB8->(DbSetOrder(1))
    
    if CB8->( DbSeek( cSeekCB8 ) )
        if lEmbal
            AAdd(aButtons, {'AVGBOX1', {|| MsgRun("Carregando consulta, aguarde...", "Ordem de Separação", {|| ConsEmb() })}, "Embalagens", "Embalagens"})
        endif
    
        RegToMemory("CB7")
    
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Monta o cabecalho                                            ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
        DbSelectArea("SX3")
        DbSeek( "CB8" )
        while !Eof() .And. ( x3_arquivo == "CB8" )
            if X3USO(x3_usado) .And. cNivel >= x3_nivel .And. AllTrim( x3_campo ) <> "CB8_ORDSEP"
                AAdd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
                x3_tamanho, x3_decimal, x3_valid,;
                x3_usado, x3_tipo, x3_arquivo, x3_context } )
            endif
            dbSkip()
        end
    
        MontaCols(cSeekCB8)
    
        aSize := MsAdvSize()
        AAdd(aObjects, {100, 130, .t., .f.})
        AAdd(aObjects, {100, 200, .t., .t.})
        aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
        aPosObj := MsObjSize(aInfo, aObjects)
    
        DEFINE MSDIALOG oDlg TITLE OemToAnsi("Ordens de separacao - Visualizacao") From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
        oEnc:=MsMget():New(cAlias,nReg,nOpcx,,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.t.)
        oGet:=MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpcx,"AllWaysTrue","AllWaysTrue",,.f.)
    
        DEFINE TIMER oTimer INTERVAL 1000 ACTION MontaCols(cSeekCB8,oGet) OF oDlg
        oTimer:Activate()
    
        ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()},,aButtons)
    endif

return nil


user function macd01al(cAlias,nReg,nOpcx)
local oDlg
local cSeekCB8 := xFilial("CB8") + CB7->CB7_ORDSEP
local nOpca := 0
local nI,nJ
local nPosDel:=0
local lAltEmp:=(CB7->CB7_ORIGEM $ '1|3')
local nDel

local aSize := {}
local aInfo := {}
local aObjects := {}
local aButtons := {}

private oGet
private Altera := .t.
private Inclui := .f.
private aHeader := {}
private aCols := {}
private aAcolsOri := {}
private lAlterouEmp := .f.
private lDiverg := .f.
private nItensCB8 := 0

    CB8->(DbSetOrder(1))
    if CB7->CB7_STATUS == "9" .or. ! CB8->( DbSeek( cSeekCB8 ) )
        MsgAlert( "Ordem de separacao concluida.", "Aviso" )
        return nil
    endif

    if lAltEmp
        AAdd(aButtons, {'RELOAD',{||AltEmp(aHeader,aCols)},"Alt.Empenhos","Alt.Empenhos"})
    endif
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Adiciona botoes do usuario na EnchoiceBar                              ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    RegToMemory("CB7")

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Monta o cabecalho                                            ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    DbSelectArea("SX3")
    DbSeek( "CB8" )
    while !Eof() .And. ( x3_arquivo == "CB8" )
        if X3USO(x3_usado) .And. cNivel >= x3_nivel
            AAdd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,x3_tamanho, x3_decimal, x3_valid,x3_usado, x3_tipo, x3_arquivo, x3_context})
        endif
        dbSkip()
    end

    MontaCols(cSeekCB8)
    aColsOri := aClone(aCols)

    aSize := MsAdvSize()
    AAdd(aObjects, {100, 130, .t., .f.})
    AAdd(aObjects, {100, 200, .t., .t.})
    aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
    aPosObj := MsObjSize(aInfo, aObjects)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Ponto de entrada para validar a abertura do dialog de alteracao ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    DEFINE MSDIALOG oDlg TITLE OemToAnsi("Ordens de separacao - Alteracao") From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL

    oEnc := MsMget():New(cAlias,nReg,nOpcx,,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.t.)
    oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpcx,"u_lokmoacd01","u_tokmoacd01",,.t.,nil,nil,nil,Len(aCols))

    ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()},,aButtons)

    if nOpca == 1

        // -----------------------------------------------------------------------
        //Valida se todas as linhas foram excluidas, nao permitindo via alteracao:
        nPosDel := Len(aHeader)+1
        nDel := 0
        aEval(aCols,{|x| if(x[nPosDel],nDel++,nil)})

        if nDel == Len(aCols)
            MsgAlert( "Para excluir todos os itens acessar a rotina de Estorno da Ordem de Separacao!", "Aviso" )
            return nil
        endif

        lDiverg := .f.
        nItensCB8 := 0
        Begin Transaction

            if !lAlterouEmp

                //----------------------------------------------------------------------------------------------
                //Estorna as informacoes sobre a Ordem de Separacao nas tabelas do sistema caso itens deletados:
                LimpaInfoOS()

                //---------------------------------------------------------------------------
                // Caso houve apenas alteracoes em campos do CB8, sem alteracoes de empenhos:
                CB8->(DbSetOrder(1))
                for nI := 1 to Len(aCols)
                    if aCols[nI,nPosDel]
                        loop
                    endif
                    ++nItensCB8
                    CB8->(DbGoto(aRecno[nI]))
                    CB8->(RecLock("CB8"))
                    for nJ := 1 to len(aHeader)
                        if aHeader[nJ,10] == "V"
                            loop
                        endif
                        CB8->&(AllTrim(aHeader[nJ,2])) := aCols[nI,nJ]
                    next
                    if !Empty(CB8->CB8_OCOSEP) .and. (CB8->CB8_SALDOS-CB8->CB8_QTECAN) > 0
                        lDiverg := .t.
                    endif
                    CB8->(MsUnlock())
                next

            else

                //----------------------------------------------------------------------------------------------
                //Estorna as informacoes sobre a Ordem de Separacao nas tabelas do sistema caso itens deletados:
                LimpaInfoOS()

                //--------------------------------------------
                //Estorna os empenhos de todos os itens da OS:
                AutoGrLog("    MANUTENÇÃO AUTOMÁTICA DOS EMPENHOS") // 
                AutoGrLog("-------------------------------------------")
                AutoGrLog("Atualizações da Ordem de Separação: " + Alltrim (CB7->CB7_ORDSEP))
                AutoGrLog("   *** EXCLUSÃO DOS EMPENHOS")
                AutoGrLog(" ")

                if !ProcAtuEmp(aColsOri,.t.)
                    AutoGrLog("Ocorreu um erro no estorno dos empenhos da OS!")
                    AutoGrLog("Processo abortado!")
                    DisarmTransaction()
                    break
                endif

                //--------------------------------------------------------------------------------------
                //Deleta os itens da Ordem de Separacao e grava novos registros com base nas alteracoes:
                GravaCB8()

                //---------------------------------------
                //Refaz empenhos de todos os itens da OS:
                AutoGrLog("   *** INCLUSÃO DOS EMPENHOS")
                AutoGrLog(" ")

                if !ProcAtuEmp(aCols,.f.)
                    AutoGrLog("Ocorreu um erro no estorno dos empenhos da OS!") //"Ocorreu um erro no estorno dos empenhos da OS!"
                    AutoGrLog("Processo abortado!") //"Processo abortado!"
                    DisarmTransaction()
                    break
                endif

                AutoGrLog(" ")
                AutoGrLog("Manutenção dos Lotes Finalizada.")
                MostraErro()

            endif

            //----------------------------
            //Atualiza informacoes em CB7:
            AtuCB7()

        End Transaction

    endif

return nil


user function lokmoacd01()
local lRet := .f.
local lPreSep :=("09*" $ CB7->CB7_TIPEXP)
local nPosDel := Len(aHeader)+1

    if aCols[n,nPosDel] //item deletado...
        lRet := .f.
        if CB7->CB7_STATUS == "0"
            lRet := .t.
        elseif CB7->CB7_STATPA == '1'
            if aCols[n,6] == aCols[n,7] //O produto ainda nao foi separado...
                lRet := .t.
            else
                if lPreSep
                    MsgAlert( "A Ordem de Pre-Separacao "+CB7->CB7_ORDSEP+" possui produtos separados!", "Aviso" )
                else
                    MsgAlert( "A Ordem de Separacao "+CB7->CB7_ORDSEP+" possui produtos separados!", "Aviso" )
                endif
            endif
        elseif CB7->CB7_STATPA != '1'
            if lPreSep
                MsgAlert( "A Ordem de Pre-Separacao "+CB7->CB7_ORDSEP+" esta em andamento!", "Aviso" )
            else
                MsgAlert( "A Ordem de Separacao "+CB7->CB7_ORDSEP+" esta em andamento!", "Aviso" )
            endif
        endif
    else
        lRet:= .t.
    endif

return lRet


user function TOKMOACD01()
local nX
local nLinhas := 0
local nPosDel := Len(aHeader)+1
local lRet := .t.

    for nX:= 1 to Len(aCols)
        if ! aCols[nX,nPosDel]
            nLinhas++
        endif
    next

    if nLinhas < 1 // Tem que ter no minimo uma linha
        lRet := .f.
    endif

return lRet


user function macd01es(cAlias,nReg,nOpcx)
local oDlg
local oGet
local cSeekCB8 := xFilial("CB8") + CB7->CB7_ORDSEP
local nI
local nOpca := 0

local aSize := {}
local aInfo := {}
local aObjects := {}

private Altera := .f.
private Inclui := .f.
private aHeader := {}
private aCols := {}
private aTela := {}, aGets := {}

    CB8->(DbSetOrder(1)) // Forca a utilizacao do indice de ordem 1, pois o programa estava se perdendo (by Erike)
    CB9->(DbSetOrder(1))
    if CB7->CB7_STATUS # "0" .and. Empty(CB7->CB7_STATPA)
        MsgAlert("Esta Ordem de separacao nao pode ser estornada pois a mesma esta sendo executada neste momento","Aviso")
        return nil
    elseif CB7->CB7_STATUS # "0" .and. CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
        MsgAlert( "A Ordem de Separacao nao pode ter nenhuma movimentacao para ser estornada.", "Aviso" )
        return nil
    endif
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica se existe algum dado no arquivo de Itens            ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
    if ! CB8->( DbSeek( cSeekCB8 ) )
        return .t.
    endif
    
    RegToMemory("CB7")
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Monta o cabecalho                                            ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
    DbSelectArea("SX3")
    DbSeek( "CB8" )
    while !Eof() .And. ( x3_arquivo == "CB8" )
        if X3USO(x3_usado) .And. cNivel >= x3_nivel .And. AllTrim( x3_campo ) <> "CB8_ORDSEP"
            AAdd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
            x3_tamanho, x3_decimal, x3_valid,;
            x3_usado, x3_tipo, x3_arquivo, x3_context } )
        endif
        dbSkip()
    end
    
    MontaCols(cSeekCB8)
    
    aSize := MsAdvSize()
    AAdd(aObjects, {100, 130, .t., .f.})
    AAdd(aObjects, {100, 200, .t., .t.})
    aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
    aPosObj := MsObjSize(aInfo, aObjects)
    
    DEFINE MSDIALOG oDlg TITLE OemToAnsi("Ordens de separacao - Estorno") From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
    oEnc:=MsMget():New(cAlias,nReg,nOpcx,,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.t.)
    oGet:=MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpcx,"AllWaysTrue","AllWaysTrue",,.f.)
    
    DEFINE TIMER oTimer INTERVAL 1000 ACTION MontaCols(cSeekCB8,oGet) OF oDlg
    oTimer:Activate()
    
    ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()})
    
    DbSelectArea( cAlias )
    
    if nOpca == 1
    
        Begin Transaction
    
        SC9->(DbSetOrder(1))
        CB8->(DbSetOrder(1))
        DbSelectArea("CB7")
        for nI := 1 to Len(aCols)
            CB8->(DbGoto(aRecno[nI]))
    
            if CB7->CB7_ORIGEM == "1"
                SC9->(DbSetOrder(1))
                SF2->(DbSetOrder(1))
                SD2->(DbSetOrder(3))
                if SC9->( DbSeek( xFilial("SC9")+CB8->CB8_PEDIDO+CB8->CB8_ITEM+CB8->CB8_SEQUEN+CB8->CB8_PROD    ) )
                    if ! Empty(SC9->C9_ORDSEP)
                        SC9->(RecLock("SC9",.f.))
                        SC9->C9_ORDSEP := ""
                        SC9->(MsUnlock())
                    endif
                endif
                if SF2->(DbSeek(xFilial("SF2")+CB7->(CB7_NOTA+CB7_SERIE)))
                    if ! Empty(SF2->F2_ORDSEP)
                        SF2->(RecLock("SF2",.f.))
                        SF2->F2_ORDSEP := ""
                        SF2->(MsUnlock())
                    endif
                endif
                if SD2->( DbSeek( xFilial("SD2")+CB7->(CB7_NOTA+CB7_SERIE+CB7_CLIENTE+CB7_LOJA)+acols[ni,4]+acols[ni,2] ) )
                    if !Empty(SD2->D2_ORDSEP)
                        SD2->(RecLock("SD2",.f.))
                        SD2->D2_ORDSEP := ""
                        SD2->(MsUnlock())
                    endif
                endif
            elseif CB7->CB7_ORIGEM == "2"
                SF2->(DbSetOrder(1))
                SD2->(DbSetOrder(3))
                if SF2->(DbSeek(xFilial("SF2")+CB7->(CB7_NOTA+CB7_SERIE)))
                    if ! Empty(SF2->F2_ORDSEP)
                        SF2->(RecLock("SF2",.f.))
                        SF2->F2_ORDSEP := ""
                        SF2->(MsUnlock())
                    endif
                endif
                if SD2->( DbSeek( xFilial("SD2")+CB7->(CB7_NOTA+CB7_SERIE+CB7_CLIENTE+CB7_LOJA)+acols[ni,4]+acols[ni,2] ) )
                    if !Empty(SD2->D2_ORDSEP)
                        SD2->(RecLock("SD2",.f.))
                        SD2->D2_ORDSEP := ""
                        SD2->(MsUnlock())
                    endif
                endif
            elseif CB7->CB7_ORIGEM == "3"
                SC2->(DbSetOrder(1))
                if SC2->(DbSeek(xFilial("SC2")+CB8->CB8_OP))
                    if ! Empty(SC2->C2_ORDSEP)
                        SC2->(RecLock("SC2",.f.))
                        SC2->C2_ORDSEP := ""
                        SC2->(MsUnlock())
                    endif
                endif
            endif
            CB8->(RecLock( "CB8",.f.))
            CB8->(dbDelete())
            CB8->(MsUnLock())
    
            if !Empty(CB7->CB7_PRESEP)
                if CB8->(DbSeek(xFilial("CB8")+CB7->CB7_PRESEP+CB8_ITEM+CB8_SEQUEN+CB8_PROD))
                    if CB8->CB8_SLDPRE == 0
                        CB8->(RecLock( "CB8",.f.))
                        CB8->CB8_SLDPRE := CB8->CB8_QTDORI
                        CB8->(MsUnLock())
                        CB8->(DbSkip())
                    endif
                endif
            endif
    
        next nI
    
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Exclui linha da tabela CB7 ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
        CB7->(RecLock("CB7", .f.))
        CB7->(dbDelete())
        CB7->(MsUnlock())

        if ! empty( CB7->CB7_NUMSA )
            SCP->( dbSetOrder(1) )
            if SCP->( dbSeek( xFilial("SCP") + CB7->CB7_NUMSA ) )
                recLock( "SCP", .F. )
                SCP->CP_ORDSEP := ""
                msUnlock()
            endif
        endif

        End Transaction
    
    endif

return nil

user function macd01gr( )
local aRotBack := {}
local cArqInd := ""
local cChaveInd := ""
local cCondicao := ""
local lMark := .f.
//local cFilSC2 := ".t."
local cSerie

private nOrigExp := ""
private cSeparador := Space(6) 

 //   if Pergunte("VAAACD0101",.t.)
 //       nOrigExp := mv_par01
        nOrigExp := 4
        AtivaF12(nOrigExp) // carrega os valores das perguntes relacionados a configuracoes
        
        aRotBack := aClone( aRotina )
        aRotina := {{"Gerar","u_macd01_gera",0,1} } //"Gerar"
        //--- P.E. utilizado para adicionar itens no Menu da MarkBrowse
        
        if nOrigExp == 1
            if Pergunte("VAAACD0102",.t.)
                cSeparador := mv_par01
                nPreSep := mv_par10
                DbSelectArea("SC9")
                DbSetOrder(1)
                cCondicao := 'C9_PEDIDO  >="'+mv_par02+'".And.C9_PEDIDO <="'+mv_par03+'".And.'
                cCondicao += 'C9_CLIENTE >="'+mv_par04+'".And.C9_CLIENTE<="'+mv_par06+'".And.'
                cCondicao += 'C9_LOJA    >="'+mv_par05+'".And.C9_LOJA   <="'+mv_par07+'".And.'
                cCondicao += 'DTOS(C9_DATALIB)>="'+DTOS(mv_par08)+'".And.DTOS(C9_DATALIB)<="'+DTOS(mv_par09)+'".And.'
                cCondicao += 'Empty(C9_ORDSEP) .And.'
                cCondicao += ' C9_FILIAL = xFilial("SC9") .And. '
                SC9->(MsSeek(xFilial("SC9")))
                MarkBrow("SC9","C9_OK","SC9->C9_BLEST+SC9->C9_BLCRED",,lMark,GetMark(,"SC9","C9_OK"),,,,,,,,,,,,    cCondicao )
                SC9->(DbClearFil())
                RetIndex("SC9")
            endif
        elseif nOrigExp == 2 // nota fiscal saida
            if Pergunte("VAAACD0103",.t.)
                cSeparador := mv_par01
                DbSelectArea("SD2")
                DbSetOrder(3)
                cArqInd := CriaTrab(, .f.)
                cSerie := SerieNfId("SD2",3,"D2_SERIE")
                cChaveInd := 'D2_FILIAL+D2_ORDSEP+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+DTOS(D2_EMISSAO)' //IndexKey()
                cCondicao := 'D2_DOC >="'          +mv_par02+'" .And. D2_DOC<="'    +mv_par04+'"'
                cCondicao += '.And. '+cSerie+' >="' +mv_par03+'" .And. '+cSerie+' <= "'  +mv_par05+'"'
                cCondicao += '.And. D2_CLIENTE>="' +mv_par06+'" .And. D2_CLIENTE<="'+mv_par08+'"'
                cCondicao += '.And. D2_LOJA>="'    +mv_par07+'" .And. D2_LOJA<="'   +mv_par09+'"'
                cCondicao += '.And. DTOS(D2_EMISSAO)>="'+DTOS(mv_par10)+'".And.DTOS(D2_EMISSAO)<="'+DTOS(mv_par11)+'"'
                cCondicao += '.And. Empty(D2_ORDSEP) .And. '
                cCondicao += ' D2_FILIAL = xFilial("SD2") .And. '
                if Pergunte("VAAACD0107",.t.)
                    IndRegua("SD2", cArqInd, cChaveInd,, cCondicao, "Criando indice de trabalho")
                    DbSetOrder(3)
                    SD2->(MsSeek(xFilial("SD2")))
                    MarkBrow("SD2","D2_OK",'D2_ORDSEP',,lMark, GetMark(,"SD2","D2_OK") )
                    SD2->(DbClearFil())
                    RetIndex("SD2")
                endif
            endif
        elseif nOrigExp == 3 // producao
            if Pergunte("VAAACD0104",.t.)
                cSeparador := mv_par01
                nPreSep := mv_par06
                DbSelectArea("SC2")
                DbSetOrder(1)
                cArqInd := CriaTrab(, .f.)
                cChaveInd := IndexKey()
                cCondicao := 'C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD >="'    +mv_par02+'".And.C2_NUM+C2_ITEM+C2_SEQUEN    +C2_ITEMGRD <="'+mv_par03+'"'
                cCondicao += '.And. DTOS(C2_EMISSAO)>="'+DTOS(mv_par04)+'".And.DTOS(C2_EMISSAO)<="'+DTOS(mv_par05)+'"'
                cCondicao += '.And. Empty(C2_ORDSEP)'
                cCondicao += '.And. Empty(C2_DATRF) .And. '
                cCondicao += ' C2_FILIAL = xFilial("SC2") .And. '
                if Pergunte("VAAACD0108",.t.)
                    IndRegua("SC2", cArqInd, cChaveInd,, cCondicao, "Criando indice de trabalho" )
                    DbSetOrder(1)
                    SC2->(MsSeek(xFilial("SC2")))
                    MarkBrow("SC2","C2_OK",'C2_ORDSEP',,lMark, GetMark(,"SC2","C2_OK"))
                    SC2->(DbClearFil())
                    RetIndex("SC2")
                endif
            endif
        elseif nOrigExp == 4 // solicitação ao armazem
            if Pergunte("VAAACD0105", .t.)
                cSeparador := mv_par01
                nPreSep := mv_par02
                DbSelectArea("SCP")
                DbSetOrder(1)
                cArqInd := CriaTrab(, .f.)
                cChaveInd := IndexKey()
                cCondicao :=       'CP_FILIAL = "' + xFilial("SCP") +'"' +;
                            ' .and. CP_NUM >="'+mv_par03+'"' +;
                            ' .and. CP_NUM <="'+mv_par04+'"' +;
                            ' .and. DTOS(CP_EMISSAO)>="'+DTOS(mv_par05)+'"' +;
                            ' .and. DTOS(CP_EMISSAO)<="'+DTOS(mv_par06)+'"' +;
                            ' .and. DTOS(CP_DATPRF)>="'+DTOS(mv_par07)+'"' +;
                            ' .and. DTOS(CP_DATPRF)<="'+DTOS(mv_par08)+'"' +;
                            ' .and. CP_STATUS <> "E"' +;
                            ' .and. CP_QUANT > CP_QUJE'
                IndRegua("SCP", cArqInd, cChaveInd,, cCondicao, "Criando indice de trabalho" )
                DbSetOrder(1)
                SCP->(MsSeek(xFilial("SCP")))
                //MarkBrow("SCP","CP_OK",'CP_XORDSEP',,lMark, GetMark(,"SCP","CP_OK"))
                MarkBrow("SCP","CP_OK",'CP_ORDSEP',,lMark, GetMark(,"SCP","CP_OK"))
                SCP->(DbClearFilter())
                RetIndex("SCP")
            endif
        endif
        aRotina := aClone( aRotBack )
   // endif
    
return nil


user function macd01_gera(cAlias,cCampo,nOpcE,cMarca,lInverte,lNoDupl)
private aLogOS := {}

    if nOrigExp==1
        Processa( { || GeraOSepPedido( cMarca, lInverte ) } )
    elseif nOrigExp==2
        Processa( { || GeraOSepNota( cMarca, lInverte ) } )
    elseif nOrigExp==3
        Processa( { || GeraOSepProducao( cMarca, lInverte ) } )
    elseif nOrigExp==4
        Processa( { || GeraOSepRequisicao( cMarca, lInverte ) } )
    endif

return nil


static function GeraOSepPedido( cMarca, lInverte, cPedidoPar)
local nI
local cCodOpe
local aRecSC9 := {}
local aOrdSep := {}

local cArm := Space(Tamsx3("B1_LOCPAD")[1])
local cPedido := Space(Tamsx3("C9_PEDIDO")[1])
local cCliente := Space(Tamsx3("C6_CLI")[1])
local cLoja := Space(Tamsx3("C6_LOJA")[1])
local cCondPag := Space(Tamsx3("C5_CONDPAG")[1])
local cLojaEnt := Space(Tamsx3("C5_LOJAENT")[1])
local cAgreg := Space(Tamsx3("C9_AGREG")[1])
local cOrdSep := Space(Tamsx3("CB7_ORDSEP")[1])

local cTipExp := ""
local nPos := 0
local nMaxItens := GETMV("MV_NUMITEN") //Numero maximo de itens por nota (neste caso por ordem de separacao)- by Erike
local lConsNumIt := SuperGetMV("MV_CBCNITE",.f.,.t.) //Parametro que indica se deve ou nao considerar o conteudo do MV_NUMITEN
local lLocOrdSep := .f.

private aLogOS := {}

    nMaxItens := if(Empty(nMaxItens),99,nMaxItens)
    
    // analisar a pergunta '00-Separacao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque,07-Aglutina Pedido,08-Aglutina     local,09-Pre-Separacao'
    if nEmbSimul == 1 // Separacao com Embalagem Simultanea
        cTipExp := "01*"
    else
        cTipExp := "00*" // Separacao Simples
    EndIF
    if nEmbalagem == 1 // Embalagem
        cTipExp += "02*"
    EndIF
    if nGeraNota == 1 // Gera Nota
        cTipExp += "03*"
    EndIF
    if nImpNota == 1 // Imprime Nota
        cTipExp += "04*"
    EndIF
    if nImpEtVol == 1 // Imprime Etiquetas Oficiais de Volume
        cTipExp += "05*"
    EndIF
    if nEmbarque == 1 // Embarque
        cTipExp += "06*"
    EndIF
    if nAglutPed == 1 // Aglutina pedido
        cTipExp +="11*"
    endif
    if nAglutArm == 1 // Aglutina armazem
        cTipExp +="08*"
    endif
    if nPreSep == 1 // pre-separacao - Trocar mv_par10 para nPreSep
        cTipExp +="09*"
    endif
    if nConfLote == 1 // confere lote
        cTipExp +="10*"
    endif
    
    ProcRegua( SC9->( LastRec() ), "oook" )
    cCodOpe := cSeparador
    
    SC5->(DbSetOrder(1))
    SC6->(DbSetOrder(1))
    SDC->(DbSetOrder(1))
    CB7->(DbSetOrder(2))
    CB8->(DbSetOrder(2))
    
    SC9->(dbGoTop())
    while !SC9->(Eof())
        if ! SC9->(IsMark("C9_OK",ThisMark(),ThisInv()))
            SC9->(DbSkip())
            IncProc()
            loop
        endif
        if !Empty(SC9->(C9_BLEST+C9_BLCRED+C9_BLOQUEI))
            SC9->(DbSkip())
            IncProc()
            loop
        endif
        //pesquisa se este item tem saldo a separar, caso tenha, nao gera ordem de separacao
        if CB8->(DbSeek(xFilial('CB8')+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_PRODUTO)) .and. CB8->CB8_SALDOS > 0
            //Grava o historico das geracoes:
            AAdd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_local,"Existe saldo a separar deste item",    "NAO_GEROU_OS"})
            SC9->(DbSkip())
            IncProc()
            loop
        endif
    
        if ! SC5->(DbSeek(xFilial('SC5')+SC9->C9_PEDIDO))
            // neste caso a base tem sc9 e nao tem sc5, problema de incosistencia de base
            //Grava o historico das geracoes:
            AAdd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_local,"Inconsistencia de base (SC5 x SC9)",    "NAO_GEROU_OS"})
            SC9->(DbSkip())
            IncProc()
            loop
        endif
        if ! SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO))
            // neste caso a base tem sc9,sc5 e nao tem sc6,, problema de incosistencia de base
            //Grava o historico das geracoes:
            AAdd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_local,"Inconsistencia de base (SC6 x SC9)",    "NAO_GEROU_OS"})
            SC9->(DbSkip())
            IncProc()
            loop
        endif
    
        if !("08*" $ cTipExp)  // gera ordem de separacao por armazem
            cArm :=SC6->C6_local
        else  // gera ordem de separa com todos os armazens
            cArm :=Space(Tamsx3("B1_LOCPAD")[1])
        endif
        if "11*" $ cTipExp //AGLUTINA TODOS OS PEDIDOS DE UM MESMO CLIENTE
            cPedido := Space(Tamsx3("C9_PEDIDO")[1])
        else   // Nao AGLUTINA POR PEDIDO
            cPedido := SC9->C9_PEDIDO
        endif
        if "09*" $ cTipExp // AGLUTINA PARA PRE-SEPARACAO
            cPedido := Space(Tamsx3("C9_PEDIDO")[1]) // CASO SEJA PRE-SEPARACAO TEM QUE CONSIDERAR TODOS OS PEDIDOS
            cCliente := Space(Tamsx3("C6_CLI")[1])
            cLoja := Space(Tamsx3("C6_LOJA")[1])
            cCondPag := Space(Tamsx3("C5_CONDPAG")[1])
            cLojaEnt := Space(Tamsx3("C5_LOJAENT")[1])
            cAgreg := Space(Tamsx3("C9_AGREG")[1])
        else   // NAO AGLUTINA PARA PRE-SEPARACAO
            cCliente := SC6->C6_CLI
            cLoja := SC6->C6_LOJA
            cCondPag := SC5->C5_CONDPAG
            cLojaEnt := SC5->C5_LOJAENT
            cAgreg := SC9->C9_AGREG
        endif
    
        lLocOrdSep := .f.
        if CB7->(DbSeek(xFilial("CB7")+cPedido+cArm+" "+cCliente+cLoja+cCondPag+cLojaEnt+cAgreg))
            while CB7->(!Eof() .and. CB7_FILIAL+CB7_PEDIDO+CB7_local+CB7_STATUS+CB7_CLIENT+CB7_LOJA+CB7_COND+CB7_LOJENT+CB7_AGREG==xFilial("CB7")+cPedido+cArm+" "+cCliente+cLoja+cCondPag+cLojaEnt+cAgreg)
                if AScan(aOrdSep, CB7->CB7_ORDSEP) > 0
                    lLocOrdSep := .t.
                    exit
                endif
                CB7->(DbSkip())
            end
        endif
    
        if localiza(SC9->C9_PRODUTO)
            if ! SDC->( DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_local+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN))
                // neste caso nao existe composicao de empenho
                //Grava o historico das geracoes:
                AAdd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_local,"Nao existe composicao de empenho (SDC)","NAO_GEROU_OS"})
                SC9->(DbSkip())
                IncProc()
                loop
            endif
        endif
    

        if !lLocOrdSep .or. (("03*" $ cTipExp) .and. !("09*" $ cTipExp) .and. lConsNumIt .And. CB7->CB7_NUMITE >=nMaxItens)
    
            cOrdSep := CB_SXESXF("CB7","CB7_ORDSEP",,1)
            ConfirmSX8()
    
            CB7->(RecLock( "CB7",.t.))
            CB7->CB7_FILIAL := xFilial( "CB7" )
            CB7->CB7_ORDSEP := cOrdSep
            CB7->CB7_PEDIDO := cPedido
            CB7->CB7_CLIENT := cCliente
            CB7->CB7_LOJA := cLoja
            CB7->CB7_COND := cCondPag
            CB7->CB7_LOJENT := cLojaEnt
            CB7->CB7_local := cArm
            CB7->CB7_DTEMIS := dDataBase
            CB7->CB7_HREMIS := Time()
            CB7->CB7_STATUS := " "
            CB7->CB7_CODOPE := cCodOpe
            CB7->CB7_PRIORI := "1"
            CB7->CB7_ORIGEM := "1"
            CB7->CB7_TIPEXP := cTipExp
            CB7->CB7_TRANSP := SC5->C5_TRANSP
            CB7->CB7_AGREG := cAgreg
            CB7->(MsUnlock())
    
            AAdd(aOrdSep,CB7->CB7_ORDSEP)
        endif
        //Grava o historico das geracoes:
        nPos := AScan(aLogOS,{|x| x[01]+x[02]+x[03]+x[04]+x[05]+x[10] == ("1"+"Pedido"+SC9->(C9_PEDIDO+C9_CLIENTE+C9_LOJA)+CB7->CB7_ORDSEP)})
        if nPos == 0
            AAdd(aLogOS,{"1","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,"","",cArm,"",CB7->CB7_ORDSEP}) //"Pedido"
        endif
    
        if localiza(SC9->C9_PRODUTO)
            while SDC->(! Eof() .and. DC_FILIAL+DC_PRODUTO+DC_local+DC_ORIGEM+DC_PEDIDO+;
                DC_ITEM+DC_SEQ==xFilial("SDC")+SC9->(C9_PRODUTO+C9_local+"SC6"+C9_PEDIDO+C9_ITEM+C9_SEQUEN))
    
                SB1->(DbSetOrder(1))
                if SB1->(DbSeek(xFilial("SB1")+SDC->DC_PRODUTO)) .And. IsProdMOD(SDC->DC_PRODUTO)
                    SDC->(DbSkip())
                    loop
                endif
    
                CB8->(RecLock("CB8",.t.))
                CB8->CB8_FILIAL := xFilial("CB8")
                CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
                CB8->CB8_ITEM := SC9->C9_ITEM
                CB8->CB8_PEDIDO := SC9->C9_PEDIDO
                CB8->CB8_PROD := SDC->DC_PRODUTO
                CB8->CB8_local := SDC->DC_local
                CB8->CB8_QTDORI := SDC->DC_QUANT
                if "09*" $ cTipExp
                    CB8->CB8_SLDPRE := SDC->DC_QUANT
                endif
                CB8->CB8_SALDOS := SDC->DC_QUANT
                if ! "09*" $ cTipExp .AND. nEmbalagem == 1
                    CB8->CB8_SALDOE := SDC->DC_QUANT
                endif
                CB8->CB8_LCALIZ := SDC->DC_localIZ
                CB8->CB8_NUMSER := SDC->DC_NUMSERI
                CB8->CB8_SEQUEN := SC9->C9_SEQUEN
                CB8->CB8_LOTECT := SC9->C9_LOTECTL
                CB8->CB8_NUMLOT := SC9->C9_NUMLOTE
                CB8->CB8_CFLOTE := if("10*" $ cTipExp,"1","2")
                CB8->CB8_TIPSEP := if("09*" $ cTipExp,"1"," ")
                CB8->(MsUnLock())
                //Atualizacao do controle do numero de itens a serem impressos
                RecLock("CB7",.f.)
                CB7->CB7_NUMITE++
                CB7->(MsUnLock())
                SDC->( dbSkip() )
            end
        else
            CB8->(RecLock("CB8",.t.))
            CB8->CB8_FILIAL := xFilial("CB8")
            CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
            CB8->CB8_ITEM := SC9->C9_ITEM
            CB8->CB8_PEDIDO := SC9->C9_PEDIDO
            CB8->CB8_PROD := SC9->C9_PRODUTO
            CB8->CB8_local := SC9->C9_local
            CB8->CB8_QTDORI := SC9->C9_QTDLIB
            if "09*" $ cTipExp
                CB8->CB8_SLDPRE := SC9->C9_QTDLIB
            endif
            CB8->CB8_SALDOS := SC9->C9_QTDLIB
            if ! "09*" $ cTipExp .AND. nEmbalagem == 1
                CB8->CB8_SALDOE := SC9->C9_QTDLIB
            endif
            CB8->CB8_LCALIZ := ""
            CB8->CB8_NUMSER := SC9->C9_NUMSERI
            CB8->CB8_SEQUEN := SC9->C9_SEQUEN
            CB8->CB8_LOTECT := SC9->C9_LOTECTL
            CB8->CB8_NUMLOT := SC9->C9_NUMLOTE
            CB8->CB8_CFLOTE := if("10*" $ cTipExp,"1","2")
            CB8->CB8_TIPSEP := if("09*" $ cTipExp,"1"," ")
            CB8->(MsUnLock())
    
            //Atualizacao do controle do numero de itens a serem impressos
            RecLock("CB7",.f.)
            CB7->CB7_NUMITE++
            CB7->(MsUnLock())
        endif
        AAdd(aRecSC9,{SC9->(Recno()),CB7->CB7_ORDSEP})
        IncProc()
        SC9->( dbSkip() )
    end
    
    CB7->(DbSetOrder(1))
    for nI := 1 to len(aOrdSep)
        CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
        CB7->(RecLock("CB7"))
        CB7->CB7_STATUS := "0"  // nao iniciado
        CB7->(MsUnlock())
    next
    for nI := 1 to len(aRecSC9)
        SC9->(DbGoto(aRecSC9[nI,1]))
        SC9->(RecLock("SC9"))
        SC9->C9_ORDSEP := aRecSC9[nI,2]
        SC9->(MsUnlock())
    next
    if !Empty(aLogOS)
        lgvaaacd01()
    endif
return nil


static function GeraOSepNota( cMarca, lInverte, cNotaSerie)
local cChaveDB
local cTipExp
local nI
local cCodOpe
local aRecSD2 := {}
local aOrdSep := {}

private aLogOS:= {}

    // analisar a pergunta '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque'
    if nEmbSimuNF == 1
        cTipExp := "01*"
    else
        cTipExp := "00*"
    EndIF
    if nEmbalagNF == 1
        cTipExp += "02*"
    EndIF
    if nImpNotaNF == 1
        cTipExp += "04*"
    EndIF
    if nImpVolNF == 1
        cTipExp += "05*"
    EndIF
    if nEmbarqNF == 1
        cTipExp += "06*"
    EndIF
    
    SF2->(DbSetOrder(1))
    SD2->(DbSetOrder(3))
    SD2->( dbGoTop() )
    
    if cNotaSerie == nil
        ProcRegua( SD2->( LastRec() ), "oook" )
        cCodOpe := cSeparador
    else
        SD2->(DbSetOrder(3))
        SD2->(DbSeek(xFilial("SD2")+cNotaSerie))
        cCodOpe := Space(06)
    endif
    
    ProcRegua( SD2->( LastRec() ), "oook" )
    cCodOpe := cSeparador
    
    while !SD2->( Eof() ) .and. (cNotaSerie == nil .or. cNotaSerie == SD2->(D2_DOC+D2_SERIE))
        if (cNotaSerie==nil) .and. ! (SD2->(IsMark("D2_OK",ThisMark(),ThisInv())))
            SD2->( dbSkip() )
            IncProc()
            loop
        endif
        cChaveDB :=xFilial("SDB")+SD2->(D2_COD+D2_local+D2_NUMSEQ+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
        if localiza(SD2->D2_COD)
            SDB->(DbSetOrder(1))
            if ! SDB->(DbSeek( cChaveDB ))
                // neste caso nao existe composicao de empenho
                //Grava o historico das geracoes:
                AAdd(aLogOS,{"2","Nota",SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA,"Inconsistencia de base, nao existe registro de movimento (SDB)",    "NAO_GEROU_OS"})
                SD2->(DbSkip())
                if cNotaSerie==nil
                    IncProc()
                endif
                loop
            endif
        endif
    
        CB7->(DbSetOrder(4))
        if ! CB7->(DbSeek(xFilial("CB7")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_local+" "))
            CB7->(RecLock( "CB7", .t. ))
            CB7->CB7_FILIAL := xFilial( "CB7" )
            CB7->CB7_ORDSEP := GetSX8Num( "CB7", "CB7_ORDSEP" )
            CB7->CB7_NOTA := SD2->D2_DOC
            //CB7->CB7_SERIE := SD2->D2_SERIE
            SerieNfId ("CB7",1,"CB7_SERIE",,,,SD2->D2_SERIE)
            CB7->CB7_CLIENT := SD2->D2_CLIENTE
            CB7->CB7_LOJA := SD2->D2_LOJA
            CB7->CB7_local := SD2->D2_local
            CB7->CB7_DTEMIS := dDataBase
            CB7->CB7_HREMIS := Time()
            CB7->CB7_STATUS := " "   // gravar STATUS de nao iniciada somente depois do processo
            CB7->CB7_CODOPE := cCodOpe
            CB7->CB7_PRIORI := "1"
            CB7->CB7_ORIGEM := "2"
            CB7->CB7_TIPEXP := cTipExp
            if SF2->(DbSeek(xFilial("SF2")+SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)))
                CB7->CB7_TRANSP := SF2->F2_TRANSP
            endif
            CB7->(MsUnLock())
            ConfirmSX8()
            //Grava o historico das geracoes:
            AAdd(aLogOS,{"1","Nota",SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA,"",CB7->CB7_ORDSEP})
            AAdd(aOrdSep,CB7->CB7_ORDSEP)
        endif
        if localiza(SD2->D2_COD)
            while SDB->(!Eof() .And. cChaveDB == DB_FILIAL+DB_PRODUTO+DB_local+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA)
                if SDB->DB_ESTORNO == "S"
                    SDB->(dbSkip())
                    loop
                endif
                CB8->(DbSetOrder(4))
                if ! CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP+SD2->(D2_ITEM+D2_COD+D2_local+SDB->DB_localIZ+D2_LOTECTL+D2_NUMLOTE+D2_NUMSERI)))
                    CB8->(RecLock( "CB8", .t. ))
                    CB8->CB8_FILIAL := xFilial( "CB8" )
                    CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
                    CB8->CB8_ITEM := SD2->D2_ITEM
                    CB8->CB8_PEDIDO := SD2->D2_PEDIDO
                    CB8->CB8_NOTA := SD2->D2_DOC
                    //CB8->CB8_SERIE := SD2->D2_SERIE
                    SerieNfId ("CB8",1,"CB8_SERIE",,,,SD2->D2_SERIE)
                    CB8->CB8_PROD := SD2->D2_COD
                    CB8->CB8_local := SD2->D2_local
                    CB8->CB8_LCALIZ := SDB->DB_localIZ
                    CB8->CB8_SEQUEN := SDB->DB_ITEM
                    CB8->CB8_LOTECT := SD2->D2_LOTECTL
                    CB8->CB8_NUMLOT := SD2->D2_NUMLOTE
                    CB8->CB8_NUMSER := SD2->D2_NUMSERI
                    CB8->CB8_CFLOTE := "1"
                    AAdd(aRecSD2,{SD2->(Recno()),CB7->CB7_ORDSEP})
                else
                    CB8->(RecLock( "CB8", .f. ))
                endif
                CB8->CB8_QTDORI += SDB->DB_QUANT
                CB8->CB8_SALDOS += SDB->DB_QUANT
                if nEmbalagem == 1
                    CB8->CB8_SALDOE += SDB->DB_QUANT
                endif
                CB8->(MsUnLock())
                SDB->(dbSkip())
            end
        else
            CB8->(DbSetOrder(4))
            if ! CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP+SD2->(D2_ITEM+D2_COD+D2_local+Space(15)+D2_LOTECTL+D2_NUMLOTE+D2_NUMSERI)))
                CB8->(RecLock( "CB8", .t. ))
                CB8->CB8_FILIAL := xFilial( "CB8" )
                CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
                CB8->CB8_ITEM := SD2->D2_ITEM
                CB8->CB8_PEDIDO := SD2->D2_PEDIDO
                CB8->CB8_NOTA := SD2->D2_DOC
                //CB8->CB8_SERIE := SD2->D2_SERIE
                SerieNfId ("CB8",1,"CB8_SERIE",,,,SD2->D2_SERIE)
                CB8->CB8_PROD := SD2->D2_COD
                CB8->CB8_local := SD2->D2_local
                CB8->CB8_LCALIZ := Space(15)
                CB8->CB8_SEQUEN := SD2->D2_ITEM
                CB8->CB8_LOTECT := SD2->D2_LOTECTL
                CB8->CB8_NUMLOT := SD2->D2_NUMLOTE
                CB8->CB8_NUMSER := SD2->D2_NUMSERI
                CB8->CB8_CFLOTE := "1"
                AAdd(aRecSD2,{SD2->(Recno()),CB7->CB7_ORDSEP})
            else
                CB8->(RecLock( "CB8", .f. ))
            endif
            CB8->CB8_QTDORI += SD2->D2_QUANT
            CB8->CB8_SALDOS += SD2->D2_QUANT
            if nEmbalagem == 1
                CB8->CB8_SALDOE += SD2->D2_QUANT
            endif
            CB8->(MsUnLock())
        endif
    
        if cNotaSerie==nil
            IncProc()
        endif
        SD2->( dbSkip() )
    end
    
    CB7->(DbSetOrder(1))
    for nI := 1 to len(aOrdSep)
        CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
        CB7->(RecLock("CB7"))
        CB7->CB7_STATUS := "0"  // nao iniciado
        CB7->(MsUnlock())
    next
    for nI := 1 to len(aRecSD2)
        SD2->(DbGoto(aRecSD2[nI,1]))
        SD2->(RecLock("SD2",.f.))
        SD2->D2_ORDSEP := aRecSD2[nI,2]
        SD2->(MsUnlock())
    next
    if !Empty(aLogOS)
        lgvaaacd01()
    endif
return nil


static function GeraOSepProducao( cMarca, lInverte )
local cOrdSep,aOrdSep := {},nI
local cCodOpe
local aRecSC2 := {}
local cTipExp
local aItemCB8 := {}
local lSai := .f.
local cArm := Space(Tamsx3("B1_LOCPAD")[1])
local cTM := GetMV("MV_CBREQD3")
local lConsEst := SuperGetMV("MV_CBRQEST",,.f.)  //Considera a Estrutura do Produto x Saldo na geracao da Ordem de Separacao
local lParcial := SuperGetMV("MV_CBOSPRC",,.f.)  //Permite ou nao gerar Ordens de Separacoes parciais
local lGera := .t.
local nSalTotIt := 0
local nSaldoEmp := 0
local aSaldoSBF := {}
local aSaldoSDC := {}
local nSldGrv := 0
local nRetSldEnd:= 0
local nRetSldSDC:= 0
local nSldAtu := 0
local nQtdEmpOS := 0
local nPosEmp
local nX
private aLogOS := {}
private aEmp := {}

    // analisar a pergunta '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque,07-Requisita'
    cTipExp := "00*"
    
    if nReqMatOP == 1
        cTipExp += "07*" //Requisicao
    endif
    
    if nAglutArmOP == 1 // Aglutina armazem
        cTipExp +="08*"
    endif
    
    if nPreSep == 1 // Pre-Separacao
        cTipExp +="09*"
    endif
    
    SC2->( dbGoTop() )
    ProcRegua( SC2->( LastRec() ), "oook" )
    cCodOpe := cSeparador
    
    SB2->(DbSetOrder(1))
    SD4->(DbSetOrder(2))
    SDC->(DbSetOrder(2))
    CB7->(DbSetOrder(1))
    while !SC2->( Eof() )
    
        if ! SC2->(IsMark("C2_OK",ThisMark(),ThisInv()))
            IncProc()
            SC2->(dbSkip())
            loop
        endif
    
        CB8->(DbSetOrder(6))
        if CB8->(DbSeek(xFilial("CB8")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
            if CB7->(DbSeek(xFilial("CB7")+CB8->CB8_ORDSEP)) .and. CB7->CB7_STATUS # "9" // Ordem em aberto
                //Grava o historico das geracoes:
                AAdd(aLogOS,{"2","OP",SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),"","","Existe uma Ordem de Separacao em aberto para esta Ordem de Producao","NAO_GEROU_OS"})
                IncProc()
                SC2->(dbSkip())
                loop
            endif
        endif
        lSai := .f.
        aEmp := {}
        SD4->(DbSeek(xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
        while SD4->(! Eof() .And. D4_FILIAL+Left(D4_OP,11) == xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
            if Empty(SD4->D4_QUANT)
                SD4->(DbSkip())
                loop
            endif
            if lParcial .And. localiza(SD4->D4_COD)// Se permitir parcial, controlar localização e nao existir composição de empenho, passa para o proximo.
                if !CBArmProc(SD4->D4_COD,cTM)
                    aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_local,SD4->D4_OP,.f.,"","",SD4->D4_TRT)
                    if Empty(aSaldoSDC)
                        SD4->(DbSkip())
                     endif
                else
                    aSaldoSBF := RetSldEnd(SD4->D4_COD,.f.)
                    if Empty(aSaldoSBF)
                        SD4->(DbSkip())
                    endif
                endif
            endif
            SB1->(DbSetOrder(1))
            if SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD)) .And. IsProdMOD(SD4->D4_COD)
                SD4->(DbSkip())
                loop
            endif
            if !localiza(SD4->D4_COD) // Nao controla endereco
                SB2->(DbSeek(xFilial("SB2")+SD4->(D4_COD+D4_local)))
                nSldAtu := if(CBArmProc(SD4->D4_COD,cTM),SB2->B2_QATU,SaldoSB2())
                nPosEmp := AScan(aEmp,{|x| x[02] == SD4->D4_COD})
                if nPosEmp == 0
                    AAdd(aEmp,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT,nSldAtu,0,0,0})
                else
                    aEmp[nPosEmp,03] += SD4->D4_QUANT
                endif
                SD4->(DbSkip())
                loop
            endif
            if !CBArmProc(SD4->D4_COD,cTM) .AND. if(!lParcial,(SD4->D4_QUANT > (nRetSldSDC := RetSldSDC(SD4->D4_COD,SD4->D4_local,SD4->D4_OP,.t.,"","",SD4->D4_TRT)    )),.f.) .AND. !lConsEst
                //Grava o historico das geracoes:
                AAdd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao encontra-se empenhado (SD4 x SDC)","NAO_GEROU_OS"}) 
                lSai := .t.
            elseif CBArmProc(SD4->D4_COD,cTM) .AND. if(!lParcial,(SD4->D4_QUANT > (nRetSldEnd := RetSldEnd(SD4->D4_COD,.t.))),.f.) .AND. !lConsEst
                //Grava o historico das geracoes:
                AAdd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao possui saldo enderecado suficiente."+CHR(13)+CHR(10)    +"        (ou existem Ordens de Separacao ainda nao requisitadas)","NAO_GEROU_OS"})
                lSai := .t.
            endif
            nPosEmp := AScan(aEmp,{|x| x[02] == SD4->D4_COD})
            if nPosEmp == 0
                AAdd(aEmp,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT,if(CBArmProc(SD4->D4_COD,cTM),nRetSldEnd,nRetSldSDC),0,0,0})
            else
                aEmp[nPosEmp,03] += SD4->D4_QUANT
            endif
            SD4->(DbSkip())
        end
        if lConsEst  //Considera a Estrutura do Produto x Saldo na geracao da Ordem de Separacao
            if SemSldOS()
                //Grava o historico das geracoes:
                AAdd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","Os itens empenhados nao possuem saldo em estoque suficiente para a producao de uma unidade do     produto da OP","NAO_GEROU_OS"})
                lSai := .t.
            endif
        endif
        if lSai
            IncProc()
            SC2->(dbSkip())
            loop
        endif
    
        SD4->(DbSeek(xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
        while SD4->(!Eof() .And. D4_FILIAL+Left(D4_OP,11) == xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
            if Empty(SD4->D4_QUANT)
                SD4->(DbSkip())
                loop
            endif
            if lParcial .And. localiza(SD4->D4_COD)// Se permitir parcial, controlar localização e nao existir composição de empenho, passa para o proximo.
                if !CBArmProc(SD4->D4_COD,cTM)
                    aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_local,SD4->D4_OP,.f.,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_TRT)
                    if Empty(aSaldoSDC)
                        AAdd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao encontra-se empenhado (SD4 x SDC)","NAO_GEROU_OS"}    ) //"OP"###"O produto "###" nao encontra-se empenhado (SD4 x SDC)"
                        SD4->(DbSkip())
                        loop
                     endif
                else
                    aSaldoSBF := RetSldEnd(SD4->D4_COD,.f.)
                    if Empty(aSaldoSBF)
                        AAdd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" nao possui saldo enderecado suficiente."+CHR(13)+CHR    (10)+"        (ou existem Ordens de Separacao ainda nao requisitadas)","NAO_GEROU_OS"}) //"OP"###"O produto " //" nao possui saldo     enderecado suficiente."###"        (ou existem Ordens de Separacao ainda nao requisitadas)"
                        SD4->(DbSkip())
                        loop
                    endif
                endif
            endif
            SB1->(DbSetOrder(1))
            if SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD)) .And. IsProdMOD(SD4->D4_COD)
                SD4->(DbSkip())
                loop
            endif
    
            if !("08*" $ cTipExp)  // gera ordem de separacao por armazem
                cArm :=if(CBArmProc(SD4->D4_COD,cTM),SB1->B1_LOCPAD,SD4->D4_local)
            else  // gera ordem de separa com todos os armazens
                cArm :=Space(Tamsx3("B1_LOCPAD")[1])
            endif
            if "09*" $ cTipExp // AGLUTINA PARA PRE-SEPARACAO
                cOP:= Space(Len(SD4->D4_OP))
            else
                cOP:= SD4->D4_OP
            endif
                CB7->(DbSetOrder(5))
            if ! CB7->(DbSeek(xFilial("CB7")+cOP+cArm+" "))
                cOrdSep := GetSX8Num( "CB7", "CB7_ORDSEP" )
                CB7->(RecLock( "CB7", .t. ))
                CB7->CB7_FILIAL := xFilial( "CB7" )
                CB7->CB7_ORDSEP := cOrdSep
                CB7->CB7_OP := cOP
                CB7->CB7_local := cArm
                CB7->CB7_DTEMIS := dDataBase
                CB7->CB7_HREMIS := Time()
                CB7->CB7_STATUS := " "   // gravar STATUS de nao iniciada somente depois do processo
                CB7->CB7_CODOPE := cCodOpe
                CB7->CB7_PRIORI := "1"
                CB7->CB7_ORIGEM := "3"
                CB7->CB7_TIPEXP := cTipExp
                ConfirmSX8()
                //Grava o historico das geracoes:
                AAdd(aLogOS,{"1","OP",SD4->D4_OP,"",cArm,"",CB7->CB7_ORDSEP})
                AAdd(aOrdSep,cOrdSep)
            endif
    
            if localiza(SD4->D4_COD) //controla endereco
    
                if !CBArmProc(SD4->D4_COD,cTM)
                    aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_local,SD4->D4_OP,.f.,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_TRT)
                    nSalTotIt := 0
                    for nX:=1 to Len(aSaldoSDC)
                        nSalTotIt+=aSaldoSDC[nX,7]
                    next
                     if lConsEst
                         nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
                     endif
    
                    // Separacoes sao geradas conf. empenhos nos enderecos (SDC)
                    for nX:=1 to Len(aSaldoSDC)
                        lGera := .t.
                         if !lConsEst
                             nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,aSaldoSDC[nX,7])
                        endif
                        if (!lConsEst .And. !lParcial) .And. SD4->D4_QTDEORI <> nSalTotIt
                            exit
                        elseif lConsEst .And. nSaldoEmp == 0
                            lGera := .f.
                        else
                            nSldGrv := aSaldoSDC[nX,7]
                            nSaldoEmp -= aSaldoSDC[nX,7]
                        endif
                        if lGera
                            cOrdSep := CB7->CB7_ORDSEP
                            CB8->(RecLock( "CB8", .t. ))
                            CB8->CB8_FILIAL := xFilial( "CB8" )
                            CB8->CB8_ORDSEP := cOrdSep
                            CB8->CB8_OP := SD4->D4_OP
                            CB8->CB8_ITEM := RetItemCB8(cOrdSep,aItemCB8)
                            CB8->CB8_PROD := SD4->D4_COD
                            CB8->CB8_local := aSaldoSDC[nX,2]
                            CB8->CB8_QTDORI := nSldGrv
                            CB8->CB8_SALDOS := nSldGrv
                            if nEmbalagem == 1
                                CB8->CB8_SALDOE := nSldGrv
                            endif
                            CB8->CB8_LCALIZ := aSaldoSDC[nX,3]
                            CB8->CB8_SEQUEN := ""
                            CB8->CB8_LOTECT := aSaldoSDC[nX,4]
                            CB8->CB8_NUMLOT := aSaldoSDC[nX,5]
                            CB8->CB8_NUMSER := aSaldoSDC[nX,6]
                            CB8->CB8_CFLOTE := "1"
                            if "09*" $ cTipExp
                                CB8->CB8_SLDPRE := nSldGrv
                            endif
                            CB8->(MsUnLock())
                        endif
                    next
                    SD4->(DbSkip())
                else
                    aSaldoSBF := RetSldEnd(SD4->D4_COD,.f.)
                     if lConsEst
                         nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
                     endif
                    for nX:=1 to Len(aSaldoSBF)
                         if !lConsEst
                             nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
                        endif
                        if lConsEst .And. nSaldoEmp == 0
                            SD4->(DbSkip())
                            exit
                            nSaldoEmp -= aSaldoSDC[nX,7]
                        endif
                        cOrdSep := CB7->CB7_ORDSEP
                        CB8->(RecLock( "CB8", .t. ))
                        CB8->CB8_FILIAL := xFilial( "CB8" )
                        CB8->CB8_ORDSEP := cOrdSep
                        CB8->CB8_OP := SD4->D4_OP
                        CB8->CB8_ITEM := RetItemCB8(cOrdSep,aItemCB8)
                        CB8->CB8_PROD := SD4->D4_COD
                        CB8->CB8_local := aSaldoSBF[nX,2]
                        CB8->CB8_QTDORI := SD4->D4_QTDEORI
                        CB8->CB8_SALDOS := nSaldoEmp
                        if nEmbalagem == 1
                            CB8->CB8_SALDOE := nSaldoEmp
                        endif
                        CB8->CB8_LCALIZ := aSaldoSBF[nX,3]
                        CB8->CB8_SEQUEN := ""
                        CB8->CB8_LOTECT := aSaldoSBF[nX,4]
                        CB8->CB8_NUMLOT := aSaldoSBF[nX,5]
                        CB8->CB8_NUMSER := aSaldoSBF[nX,6]
                        CB8->CB8_CFLOTE := "1"
                        if "09*" $ cTipExp
                            CB8->CB8_SLDPRE := nSaldoEmp
                        endif
                        CB8->(MsUnLock())
                        SD4->(DbSkip())
                    next Nx
                endif
            else
                cOrdSep := CB7->CB7_ORDSEP
                nQtdEmpOS := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
                CB8->(RecLock( "CB8", .t. ))
                CB8->CB8_FILIAL := xFilial( "CB8" )
                CB8->CB8_ORDSEP := cOrdSep
                CB8->CB8_OP := SD4->D4_OP
                CB8->CB8_ITEM := RetItemCB8(cOrdSep,aItemCB8)
                CB8->CB8_PROD := SD4->D4_COD
                CB8->CB8_local := if(CBArmProc(SD4->D4_COD,cTM),SB1->B1_LOCPAD,SD4->D4_local)
                CB8->CB8_QTDORI := nQtdEmpOS
                CB8->CB8_SALDOS := nQtdEmpOS
                if nEmbalagem == 1
                    CB8->CB8_SALDOE := nQtdEmpOS
                endif
                CB8->CB8_LCALIZ := Space(15)
                CB8->CB8_SEQUEN := ""
                CB8->CB8_LOTECT := SD4->D4_LOTECTL
                CB8->CB8_NUMLOT := SD4->D4_NUMLOTE
                CB8->CB8_CFLOTE := "1"
                if "09*" $ cTipExp
                    CB8->CB8_SLDPRE := nQtdEmpOS
                endif
                CB8->(MsUnLock())
                SD4->(DbSkip())
            endif
        end
        AAdd(aRecSC2,SC2->(Recno()))
        IncProc()
        SC2->( dbSkip() )
    end
    
    CB7->(DbSetOrder(1))
    for nI := 1 to len(aOrdSep)
        CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
        CB7->(RecLock("CB7"))
        CB7->CB7_STATUS := "0"  // nao iniciado
        CB7->(MsUnlock())
    next
    for nI := 1 to len(aRecSC2)
        SC2->(DbGoto(aRecSC2[nI]))
        SC2->(RecLock("SC2"))
        SC2->C2_ORDSEP := cOrdSep
        SC2->(MsUnlock())
    next
    
    if lParcial .and. Empty(aOrdSep) .and. !Empty(aLogOS) // Quando permitir parcial somente gera log se nao existir nenhuma item na OS
        lgvaaacd01()
    elseif !lparcial .and.!Empty(aLogOS)
        lgvaaacd01()
    endif

return nil

static function GeraOSepRequisicao( cMarca, lInverte )
Local cTipExp := ""
local cCodOpe := ""
local aRecSCP := {}
local aOrdSep := {}
local nI

//Local lParcial  := SuperGetMV("MV_CBOSPRC",,.F.)  //Permite ou nao gerar Ordens de Separacoes parciais

cTipExp := "00*01*"

If nReqMatSA == 1
	cTipExp += "07*" //Requisicao
EndIf

If nAglutArmSA == 1 // Aglutina armazem
	cTipExp +="08*"
EndIf

SCP->( dbGoTop() )
ProcRegua( SCP->( LastRec() ), "oook" )
cCodOpe	 := cSeparador

while !SCP->(Eof())

    if SCP->(IsMark("CP_OK",ThisMark(),ThisInv()))
    
        //CB8->(DbOrderNickname("CB8SCP"))
        CB8->(DbSetOrder(10))
        if CB8->(DbSeek(FWxFilial("CB8")+SCP->CP_NUM+SCP->CP_ITEM))
            if CB7->(DbSeek(FWxFilial("CB7")+CB8->CB8_ORDSEP)) .and. CB7->CB7_STATUS != "9"
                AAdd(aLogSA, {"2", "SA", SCP->CP_NUM+SCP->CP_ITEM, "", "", "Existe uma Ordem de Separacao em aberto para esta Solicitação ao Armazém", "NAO_GEROU_OS"})
                IncProc()
                SCP->(DbSkip())
                loop
            endif
        endif

        // Grava CB7, caso não exista
        //CB7->(DbOrderNickname("CB7SCP"))
        CB7->(DbSetOrder(10))
        if !CB7->(DbSeek(FWxFilial("CB7")+SCP->CP_NUM))
            cOrdSep := GetSX8Num( "CB7", "CB7_ORDSEP" )
		    RecLock( "CB7", .t. )
		    CB7->CB7_FILIAL := xFilial( "CB7" )
		    CB7->CB7_ORDSEP := cOrdSep
            CB7->CB7_NUMSA  := SCP->CP_NUM
		    CB7->CB7_LOCAL  := SCP->CP_LOCAL  
		    CB7->CB7_DTEMIS := dDataBase
		    CB7->CB7_HREMIS := Time()
		    CB7->CB7_STATUS := " "   // gravar STATUS de nao iniciada somente depois do processo
		    CB7->CB7_CODOPE := cCodOpe
		    CB7->CB7_PRIORI := "1"
		    CB7->CB7_ORIGEM := "4"
		    CB7->CB7_TIPEXP := cTipExp
		    CB7->(MsUnLock())
		    ConfirmSX8()
		    //Grava o historico das geracoes:
		    aadd(aLogOS,{"1","SA",SCP->CP_NUM,"",CB7->CB7_ORDSEP})
		    aadd(aOrdSep,CB7->CB7_ORDSEP)
        endif

		cOrdSep   := CB7->CB7_ORDSEP
		CB8->(RecLock( "CB8", .T. ))
		CB8->CB8_FILIAL := FWxFilial( "CB8" )
		CB8->CB8_ORDSEP := cOrdSep
		CB8->CB8_NUMSA	:= SCP->CP_NUM
		CB8->CB8_ITEM   := SCP->CP_ITEM
		CB8->CB8_PROD   := SCP->CP_PRODUTO
		CB8->CB8_LOCAL  := SCP->CP_LOCAL
		CB8->CB8_QTDORI := SCP->CP_QUANT
		CB8->CB8_SALDOS := SCP->CP_QUANT
		CB8->CB8_LCALIZ := Space(15)
		CB8->CB8_SEQUEN := ""
		CB8->CB8_LOTECT := SCP->CP_LOTE
		CB8->CB8_CFLOTE := If("10*" $ cTipExp,"1","2")
		If CB8->(ColumnPos("CB8_TRT")) > 0
			CB8->CB8_TRT	:= SCP->CP_TRT
		EndIf
		CB8->(MsUnLock())

        recLock("SCP", .F.)
        SCP->CP_ORDSEP := cOrdSep
        SCP->CP_OK     := ""
        msUnlock()

		aadd(aRecSCP,{SCP->(Recno()),cOrdSep})
    endif

    IncProc()
    SCP->(DbSkip())
endDo

CB7->(DbSetOrder(1))
For nI := 1 to len(aOrdSep)
    CB7->(DbSeek(FWxFilial("CB7")+aOrdSep[nI]))
    CB7->(RecLock("CB7"))
    CB7->CB7_STATUS := "0"  // nao iniciado
    CB7->(MsUnlock())
Next
For nI := 1 to len(aRecSCP)
    SCP->(DbGoto(aRecSCP[nI][1]))
    SCP->(RecLock("SCP", .F.))
    SCP->CP_ORDSEP := aRecSCP[nI][2]
    SCP->(MsUnlock())
Next

return nil



static function RetItemCB8(cOrdSep,aItemCB8)

local nPos := AScan(aItemCB8,{|x| x[1] == cOrdSep})
local cItem :=' '

    if Empty(nPos )
        AAdd(aItemCB8,{cOrdSep,'00'})
        nPos := len(aItemCB8)
    EndIF
    
    cItem := Soma1(aItemcb8[nPos,2])
    aItemcb8[nPos,2]:= cItem

return cItem


user function macd01im()
local lContinua := .t.
local lACDR100 := SuperGetMV("MV_ACDR100",.f.,.f.)

private cString := "CB7"
private aOrd := {}
private cDesc1 := "Este programa tem como objetivo imprimir informacoes das"
private cDesc2 := "Ordens de separacao"
private cPict := ""
private lEnd := .f.
private lAbortPrint := .f.
private limite := 132
private tamanho := "M"
private nomeprog := "ACDA100R" // Coloque aqui o nome do programa para impressao no cabecalho
private nTipo := 18
private aReturn := {"Zebrado", 1, "Administracao",2,2,1,"",1}
private nLastKey := 0
private cPerg := "ACD100"
private titulo := "Impressao das Ordens de Separacao"
private nLin := 06
private Cabec1 := ""
private Cabec2 := ""
private cbtxt := "Regsitro(s) lido(s)"
private cbcont := 0
private CONTFL := 01
private m_pag := 01
private lRet := .t.
private imprime := .t.
private wnrel := "ACDA100R" // Coloque aqui o nome do arquivo usado para impressao em disco

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas como Parametros                                ³
//³ mv_par01 = Ordem de Separacao de       ?                            ³
//³ mv_par02 = Ordem de Separacao Ate      ?                            ³
//³ mv_par03 = Data de Emissao de          ?                            ³
//³ mv_par04 = Data de Emissao Ate         ?                            ³
//³ mv_par05 = Considera Ordens encerradas ?                            ³
//³ mv_par06 = Imprime Codigo de barras    ?                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    if lACDR100
        ACDR100()
    else
        wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,nil,.f.,aOrd,.f.,Tamanho,,.t.)
    
        Pergunte(cPerg,.f.)
    
        if nLastKey == 27
            lContinua := .f.
        endif
    
        if lContinua
            SetDefault(aReturn,cString)
        endif
    
        if nLastKey == 27
            lContinua := .f.
        endif
    
        if lContinua
            RptStatus({|| Relatorio() },Titulo)
        endif
    
        CB7->(DbClearFilter())
    endif
return nil

static function Relatorio()

    CB7->(DbSetOrder(1))
    CB7->(DbSeek(xFilial("CB7")+mv_par01,.t.)) // Posiciona no 1o.reg. satisfatorio
    SetRegua(RecCount()-Recno())
    
    while ! CB7->(EOF()) .and. (CB7->CB7_ORDSEP >= mv_par01 .and. CB7->CB7_ORDSEP <= mv_par02)
        if CB7->CB7_DTEMIS < mv_par03 .or. CB7->CB7_DTEMIS > mv_par04 // Nao considera as ordens que nao tiver dentro do range de datas
            CB7->(DbSkip())
            loop
        endif
        if mv_par05 == 2 .and. CB7->CB7_STATUS == "9" // Nao Considera as Ordens ja encerradas
            CB7->(DbSkip())
            loop
        endif
        CB8->(DbSetOrder(1))
        if ! CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP))
            CB7->(DbSkip())
            loop
        endif
        IncRegua("Imprimindo")
        if lAbortPrint
            @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
            exit
        endif
        Imprime()
        CB7->(DbSkip())
    end
    Fim()
return nil


static function Imprime(lRet)
local cOrdSep := Alltrim(CB7->CB7_ORDSEP)
local cPedido := Alltrim(CB7->CB7_PEDIDO)
local cCliente:= Alltrim(CB7->CB7_CLIENT)
local cLoja := Alltrim(CB7->CB7_LOJA    )
local cNota := Alltrim(CB7->CB7_NOTA)
local cSerie := Alltrim(CB7->&(SerieNfId("CB7",3,"CB7_SERIE")))
local cOP := Alltrim(CB7->CB7_OP)
local cStatus := RetStatus(CB7->CB7_STATUS)
local nWidth := 0.050
local nHeigth := 0.75
local oPr

    Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
    
    @ 06, 000 Psay "Ordem de Separacao: "+cOrdSep
    
    if CB7->CB7_ORIGEM == "1" // Pedido de Venda
        @ 06, 035 Psay "Pedido de Venda: "+cPedido
        @ 06, 065 Psay "Cliente: "+cCliente+" - "+"Loja: "+cLoja
        @ 06, 095 Psay "Status: "+cStatus
    elseif CB7->CB7_ORIGEM == "2" // Nota Fiscal de Saida
        @ 06, 035 Psay "Nota Fiscal: "+cNota+" - Serie: "+cSerie
        @ 06, 075 Psay "Cliente: "+cCliente+" - "+"Loja: "+cLoja
        @ 06, 105 Psay "Status: "+cStatus
    elseif CB7->CB7_ORIGEM == "3" // Ordem de Producao
        @ 06, 035 Psay "Ordem de Producao: "+cOP
        @ 06, 070 Psay "Status: "+cStatus
    endif
    
    if mv_par06 == 1 .And. aReturn[5] # 1
        oPr:= ReturnPrtObj()
          MSBAR3("CODE128",2.8,0.8,cOrdSep,oPr,nil,nil,nil,nWidth,nHeigth,.t.,nil,"B",nil,nil,nil,.f.)
          nLin := 11
    else
        nLin := 07
    endif
    
    @ ++nLin, 000 Psay Replicate("=",147)
    nLin++
    
    @nLin, 000 Psay "Produto"
    @nLin, 032 Psay "Armazem"
    @nLin, 042 Psay "Endereco"
    @nLin, 058 Psay "Lote"
    @nLin, 070 Psay "SubLote"
    @nLin, 079 Psay "Numero de Serie"
    @nLin, 101 Psay "Qtd Original"
    @nLin, 116 Psay "Qtd a Separar"
    @nLin, 132 Psay "Qtd a Embalar"
    
    CB8->(DbSetOrder(1))
    CB8->(DbSeek(xFilial("CB8")+cOrdSep))
    
    while ! CB8->(EOF()) .and. (CB8->CB8_ORDSEP == cOrdSep)
        nLin++
        if nLin > 59 // Salto de Página. Neste caso o formulario tem 55 linhas...
            Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
            nLin := 06
            @nLin, 000 Psay "Produto" //"Produto"
            @nLin, 032 Psay "Armazem" //"Armazem"
            @nLin, 042 Psay "Endereco" //"Endereco"
            @nLin, 058 Psay "Lote" //"Lote"
            @nLin, 070 Psay "SubLote" //"SubLote"
            @nLin, 079 Psay "Numero de Serie" //"Numero de Serie"
            @nLin, 101 Psay "Qtd Original" //"Qtd Original"
            @nLin, 116 Psay "Qtd a Separar" //"Qtd a Separar"
            @nLin, 132 Psay "Qtd a Embalar" //"Qtd a Embalar"
        endif
        @nLin, 000 Psay CB8->CB8_PROD
        @nLin, 032 Psay CB8->CB8_local
        @nLin, 042 Psay CB8->CB8_LCALIZ
        @nLin, 058 Psay CB8->CB8_LOTECT
        @nLin, 070 Psay CB8->CB8_NUMLOT
        @nLin, 079 Psay CB8->CB8_NUMSER
        @nLin, 099 Psay CB8->CB8_QTDORI Picture "@E 999,999,999.99"
        @nLin, 114 Psay CB8->CB8_SALDOS Picture "@E 999,999,999.99"
        @nLin, 130 Psay CB8->CB8_SALDOE Picture "@E 999,999,999.99"
        CB8->(DbSkip())
    end

return nil

static function Fim()

    SET DEVICE TO SCREEN
    if aReturn[5]==1 
        dbCommitAll() 
        SET PRINTER TO 
        OurSpool(wnrel) 
    endif 
    MS_FLUSH() 

return nil


static function RetStatus(cStatus)
local cDescri:= " "

    if Empty(cStatus) .or. cStatus == "0"
        cDescri:= "Nao iniciado"
    elseif cStatus == "1"
        cDescri:= "Em separacao"
    elseif cStatus == "2"
        cDescri:= "Separacao finalizada"
    elseif cStatus == "3"
        cDescri:= "Em processo de embalagem"
    elseif cStatus == "4"
        cDescri:= "Embalagem Finalizada"
    elseif cStatus == "5"
        cDescri:= "Nota gerada"
    elseif cStatus == "6"
        cDescri:= "Nota impressa"
    elseif cStatus == "7"
        cDescri:= "Volume impresso"
    elseif cStatus == "8"
        cDescri:= "Em processo de embarque"
    elseif cStatus == "9"
        cDescri:= "Finalizado"
    endif

return(cDescri)


static function MontaCols(cSeekCB8,oGet)
local nCnt,nUsado

    if Type("oTimer") == "O"
        oTimer:Deactivate()
    endif
    
    aCols := {}
    aRecno:={}
    
    nCnt := 0
    CB8->(DbSetOrder(1))
    CB8->( DbSeek( cSeekCB8 ) )
    while !CB8->( Eof() ) .And. cSeekCB8 == CB8->CB8_FILIAL + CB8->CB8_ORDSEP
    
        nCnt++
        nUsado := 0
        AAdd(aCols,Array(Len(aHeader)+1))
        AAdd(aRecno,CB8->(Recno()))
        DbSelectArea("SX3")
        DbSeek( "CB8" )
    
        while !Eof() .And. x3_arquivo == "CB8"
            if X3USO(x3_usado) .And. cNivel >= x3_nivel .And. AllTrim( x3_campo ) <> "CB8_ORDSEP"
                nUsado++
                if x3_context # "V"
                    cField := X3_CAMPO
                    DbSelectArea("CB8")
                    aCols[ nCnt, nUsado ] := FieldGet( FieldPos( cField ) )
                    DbSelectArea("SX3")
                elseif x3_context == "V"
                    aCols[ nCnt, nUsado ] := CriaVar( AllTrim( x3_campo ) )
                    // Processa Gatilhos
                    EvalTrigger()
                endif
            endif
    
            aCols[ nCnt, nUsado + 1 ] := .f.
    
            DbSelectArea("SX3")
            dbSkip()
    
        end
    
        DbSelectArea( "CB8" )
        dbSkip()
    
    end
    if oGet # nil
        oGet:oBrowse:Refresh()
    endif
    if Type("oTimer") = "O"
        oTimer:Activate()
    endif
return nil


static function lgvaaacd01()
local i, j, k
local cChaveAtu, cPedCli, cOPAtual

    //Cabecalho do Log de processamento:
    AutoGRLog(Replicate("=",75))
    AutoGRLog("                         I N F O R M A T I V O")
    AutoGRLog("               H I S T O R I C O   D A S   G E R A C O E S")
    
    //Detalhes do Log de processamento:
    AutoGRLog(Replicate("=",75))
    AutoGRLog("I T E N S   P R O C E S S A D O S :")
    AutoGRLog(Replicate("=",75))
    if aLogOS[1,2] == "Pedido" //"Pedido"
        aLogOS := ASort(aLogOS,,,{|x,y| x[01]+x[10]+x[03]+x[04]+x[05]+x[06]+x[07]+x[08]<y[01]+y[10]+y[03]+y[04]+y[05]+y[06]+y[07]+y[08]})
        // Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Pedido + Cliente + Loja + Item + Produto + local
        cChaveAtu := ""
        cPedCli := ""
        for i:=1 to len(aLogOs)
            if aLogOs[i,10] <> cChaveAtu .OR. (aLogOs[i,03]+aLogOs[i,04] <> cPedCli)
                if !Empty(cChaveAtu)
                    AutoGRLog(Replicate("-",75))
                endif
                j:=0
                k:=i  //Armazena o conteudo do contador do laco logico principal (i) pois o "for" j altera o valor de i;
                cChaveAtu := aLogOs[i,10]
                for j:=k to len(aLogOs)
                    if aLogOs[j,10] <> cChaveAtu
                        exit
                    endif
                    if Empty(aLogOs[j,08]) //Aglutina Armazem
                        AutoGRLog("Pedido: "+aLogOs[j,03]+" - Cliente: "+aLogOs[j,04]+"-"+aLogOs[j,05])
                    else
                        AutoGRLog("Pedido: "+aLogOs[j,03]+" - Cliente: "+aLogOs[j,04]+"-"+aLogOs[j,05]+" - local: "+aLogOs[j,08]) 
                    endif
                    cPedCli := aLogOs[j,03]+aLogOs[j,04]
                    if aLogOs[j,10] == "NAO_GEROU_OS"
                        exit
                    endif
                    i:=j
                next
                AutoGRLog("Ordem de Separacao: "+if(aLogOs[i,01]=="1",aLogOs[i,10],"N A O  G E R A D A"))
                if aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
                    AutoGRLog("Motivo: ")
                endif
            endif
            if aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
                AutoGRLog("Item: "+aLogOs[i,06]+" - Produto: "+AllTrim(aLogOs[i,07])+" - local: "+aLogOs[i,08]+" ---> "+aLogOs[i,09])
            endif
        next
    elseif aLogOS[1,2] == "Nota" //"Nota"
        aLogOS := ASort(aLogOS,,,{|x,y| x[01]+x[08]+x[03]+x[04]+x[05]+x[06]<y[01]+y[08]+y[03]+y[04]+y[05]+y[06]})
        // Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Nota + Serie + Cliente + Loja
        cChaveAtu := ""
        for i:=1 to len(aLogOs)
            if aLogOs[i,08] <> cChaveAtu
                if !Empty(cChaveAtu)
                    AutoGRLog(Replicate("-",75))
                endif
                cChaveAtu := aLogOs[i,08]
                AutoGRLog("Nota: "+aLogOs[i,3]+"/"+aLogOs[i,04]+" - Cliente: "+aLogOs[i,05]+"-"+aLogOs[i,06])
                AutoGRLog("Ordem de Separacao: "+if(aLogOs[i,01]=="1",aLogOs[i,08],"N A O  G E R A D A"))
                if aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
                    AutoGRLog("Motivo: ")
                endif
            endif
        next
    else  //Ordem de Producao
        aLogOS := ASort(aLogOS,,,{|x,y| x[01]+x[07]+x[03]+x[04]<y[01]+y[07]+y[03]+y[04]})
        // Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Ordem Producao + Produto
        cChaveAtu := ""
        cOPAtual := ""
        for i:=1 to len(aLogOs)
            if aLogOs[i,07] <> cChaveAtu .OR. aLogOs[i,03] <> cOPAtual
                if !Empty(cChaveAtu)
                    AutoGRLog(Replicate("-",75) )
                endif
                j:=0
                k:=i  //Armazena o conteudo do contador do laco logico principal (i) pois o "for" j altera o valor de i;
                cChaveAtu := aLogOs[i,07]
                for j:=k to len(aLogOs)
                    if aLogOs[j,07] <> cChaveAtu
                        exit
                    endif
                    if Empty(aLogOs[j,05]) //Aglutina Armazem
                        AutoGRLog("Ordem de Producao: "+aLogOs[i,03]) //"Ordem de Producao: "
                    else
                        AutoGRLog("Ordem de Producao: "+aLogOs[i,03]+" - local: "+aLogOs[j,05]) //"Ordem de Producao: "###" - local: "
                    endif
                    cOPAtual := aLogOs[j,03]
                    if aLogOs[j,07] == "NAO_GEROU_OS"
                        exit
                    endif
                    i:=j
                next
                AutoGRLog("Ordem de Separacao: "+if(aLogOs[i,01]=="1",aLogOs[i,07],"N A O  G E R A D A")) //"Ordem de Separacao: "###"N A O  G E R A D A"
                if aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
                    AutoGRLog("Motivo: ") //"Motivo: "
                endif
            endif
            if aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
                AutoGRLog(" ---> "+aLogOs[i,06])
            endif
        next
    endif
    MostraParam(aLogOS[1,2])
    MostraErro()
return nil


static function MostraParam(cTipGer)
local cPergParam := ""
local cPergConfig := ""
local cDescTipGer := ""
local nTamSX1 := Len(SX1->X1_GRUPO)
local aPerg := {}
local aParam := {}
local ni := 0
local ci := 0
local aLogs := {}

    if cTipGer == "Pedido" //"Pedido"
        cPergParam := PADR('VAAACD0102',nTamSX1)
        cPergConfig := PADR('vaaacd0106',nTamSX1)
        cDescTipGer := "PEDIDO DE VENDA"
        AAdd(aParam,nConfLote)
        AAdd(aParam,nEmbSimul)
        AAdd(aParam,nEmbalagem)
        AAdd(aParam,nGeraNota)
        AAdd(aParam,nImpNota)
        AAdd(aParam,nImpEtVol)
        AAdd(aParam,nEmbarque)
        AAdd(aParam,nAglutPed)
        AAdd(aParam,nAglutArm)
    elseif cTipGer == "Nota" //"Nota"
        cPergParam := PADR('vaaacd0103',nTamSX1)
        cPergConfig := PADR('vaaacd0107',nTamSX1)
        cDescTipGer := 'NOTA FISCAL'
        AAdd(aParam,nEmbSimuNF)
        AAdd(aParam,nEmbalagNF)
        AAdd(aParam,nImpNotaNF)
        AAdd(aParam,nImpVolNF)
        AAdd(aParam,nEmbarqNF)
    else //OP
        cPergParam := PADR('vaaacd0104',nTamSX1)
        cPergConfig := PADR('vaaacd0108',nTamSX1)
        cDescTipGer := 'ORDEM DE PRODUCAO'
        AAdd(aParam,nReqMatOP)
        AAdd(aParam,nAglutArmOP)
    endif
    
    AAdd(aPerg,{"P A R A M E T R O S : "+cDescTipGer,cPergParam}) 
    AAdd(aPerg,{"C O N F I G U R A C O E S : "+cDescTipGer,cPergConfig})
    //-- Carrega parametros SX1
    SX1->(DbSetOrder(1))
    for ni := 1 To Len(aPerg)
        ci := 1
        AAdd(aLogs,{aPerg[ni,2],{}})
        SX1->(DbSeek(aPerg[ni,2]))
        while SX1->(!Eof() .AND. X1_GRUPO == aPerg[ni,2])
            if SX1->X1_GSC == 'G'
                cTexto := SX1->("Pergunta "+X1_ORDEM+": "+X1_PERGUNT+Alltrim(X1_CNT01))
            else
                if ni == 1
                    cTexto := SX1->("Pergunta "+X1_ORDEM+": "+X1_PERGUNT+if(X1_PRESEL==1,'Sim','Nao'))
                else
                    cTexto := SX1->("Pergunta "+X1_ORDEM+": "+X1_PERGUNT+if(aParam[ci++]==1,'Sim','Nao'))
                endif
            endif
            AAdd(aLogs[ni,2],cTexto)
            SX1->(dbSkip())
        end
    next
    //-- Gera Log
    for ni := 1 To Len(aPerg)
        AutoGRLog(Replicate("=",75))
        AutoGRLog(aPerg[ni,1])
        AutoGRLog(Replicate("=",75))
        for ci := 1 To Len(aLogs[ni,2])
            AutoGRLog(aLogs[ni,2,ci])
        next
    next
    AutoGRLog(Replicate("=",75))
return nil


static function AtivaF12(nOrigExp)
local lPerg := .f.
local lRet := .t.

    if nOrigExp == nil
        lPerg := .t.
        if (lRet:=Pergunte("VAAACD0101",.t.))
            nOrigExp := mv_par01
        endif
    endif

    if lRet
        if nOrigExp == 1  //Origem: Pedidos de Venda

            if Pergunte("VAAACD0106",lPerg) .Or. !lPerg
                nConfLote := mv_par01
                nEmbSimul := mv_par02
                nEmbalagem := mv_par03
                nGeraNota := mv_par04
                nImpNota := mv_par05
                nImpEtVol := mv_par06
                nEmbarque := mv_par07
                nAglutPed := mv_par08
                nAglutArm := mv_par09
            endif

        elseif nOrigExp == 2  //Origem: Notas Fiscais

            if Pergunte("VAAACD0107",lPerg) .Or. !lPerg
                nEmbSimuNF := mv_par01
                nEmbalagNF := mv_par02
                nEmbalagem := mv_par02
                nImpNotaNF := mv_par03
                nImpVolNF := mv_par04
                nEmbarqNF := mv_par05
            endif
        else  //Origem: Ordens de Producao
            if Pergunte("VAAACD0108",lPerg) .Or. !lPerg
                nReqMatOP := mv_par01
                nAglutArmOP := mv_par02
            endif
        endif
    endif

return nil


static function RetSldSDC(cProd,clocal,cOP,lRetSaldo,cLote,cSublote,cSequen)
local aArea := GetArea()
local aAreaSDC := SDC->(GetArea())
local nSaldoSDC := 0
local aSaldoSDC := {}
local cQuerySDC
local lQuery :=.f.
local cAliasSDC := "SDC"

DEFAULT cLote := ''
DEFAULT cSubLote := ''

    lQuery :=.t.
    cQuerySDC := "SELECT * FROM " + RetSqlName("SDC")
    cQuerySDC += " WHERE DC_PRODUTO = '" + cProd + "' AND DC_local = '" + clocal + "' AND DC_OP = '" + cOP + "' AND "
    if !Empty(cLote)
        cQuerySDC += " DC_LOTECTL = '" + cLote + "' AND "
    endif
    if !Empty(cSubLote)
        cQuerySDC += " DC_NUMLOTE = '" + cSubLote + "' AND "
    endif
    if !Empty(cSequen)
        cQuerySDC += " DC_TRT = '" + cSequen + "' AND "
    endif
    cQuerySDC += " DC_FILIAL = '" + xFilial("SDC") + "' AND " + RetSQLName("SDC") + ".D_E_L_E_T_ <> '*'"
    cQuerySDC += " ORDER BY R_E_C_N_O_"
    cQuerySDC := ChangeQuery( cQuerySDC )
    TCQUERY cQuerySDC NEW ALIAS "SDCTMP"
    DbSelectArea("SDCTMP")
    cAliasSDC := "SDCTMP"
    
    while (cAliasSDC)->(!Eof() .AND. DC_FILIAL+DC_PRODUTO+DC_local+DC_OP == xFilial("SDC")+cProd+clocal+cOP)
        nSaldoSDC += (cAliasSDC)->DC_QUANT
        AAdd(aSaldoSDC,{(cAliasSDC)->DC_PRODUTO,(cAliasSDC)->DC_local,(cAliasSDC)->DC_localIZ,(cAliasSDC)->DC_LOTECTL,(cAliasSDC)->DC_NUMLOTE,(cAliasSDC)    ->DC_NUMSERI,(cAliasSDC)->DC_QUANT,(cAliasSDC)->(recno())})
        (cAliasSDC)->(DbSkip())
    end
    if lQuery
        (cAliasSDC)->( DbCloseArea() )
    endif
    ASort(aSaldoSDC,,,{|x,y| x[08]<y[08]})
    
    RestArea(aAreaSDC)
    RestArea(aArea)
return if(lRetSaldo, nSaldoSDC, aSaldoSDC)


static function RetSldEnd(cProd,lRetSaldo,aVarAlt)
local aArea := GetArea()
local aAreaSBF := SBF->(GetArea())
local cArmProc := GetMV("MV_LOCPROC")
local nSaldoAtu := 0
local nSaldoCB8 := 0
local nSaldoSBF := 0
local aSaldoSBF := {}
local cQuerySBF
local lQuery :=.f.
local cAliasSBF := "SBF"

local cTM := GetMV("MV_CBREQD3")
local lApropInd := CBArmProc(cProd,cTM)

local cArmOri
local cEndOri
local cLoteOri
local cSLoteOri
local cNumSerOri
local nSldSepOri

    if aVarAlt<>nil
        cArmOri := aVarAlt[1]
        cEndOri := aVarAlt[2]
        cLoteOri := aVarAlt[3]
        cSLoteOri := aVarAlt[4]
        cNumSerOri := aVarAlt[5]
        nSldSepOri := aVarAlt[6]
    endif
    
    lQuery :=.t.
    cQuerySBF := "SELECT * FROM " + RetSqlName("SBF")
    cQuerySBF += " WHERE BF_PRODUTO = '" + cProd + "' AND "
    cQuerySBF += " BF_FILIAL = '" + xFilial("SBF") + "' AND "
    cQuerySBF += RetSQLName("SBF") + ".D_E_L_E_T_ <> '*'"
    cQuerySBF += " ORDER BY BF_PRODUTO,BF_local,BF_LOTECTL,BF_NUMLOTE"
    cQuerySBF := ChangeQuery( cQuerySBF )
    TCQUERY cQuerySBF NEW ALIAS "SBFTMP"
    DbSelectArea("SBFTMP")
    cAliasSBF := "SBFTMP"
    
    while (cAliasSBF)->(!Eof() .AND. BF_FILIAL+BF_PRODUTO == xFilial("SBF")+cProd)
        if (cAliasSBF)->BF_local == cArmProc
            (cAliasSBF)->(DbSkip())
            loop
        endif
        if lApropInd
            nSaldoAtu := (cAliasSBF)->(SaldoSBF(BF_local,BF_localIZ,BF_PRODUTO,BF_NUMSERI,BF_LOTECTL,BF_NUMLOTE))
            nSaldoCB8 := (cAliasSBF)->(RetSldCB8(BF_PRODUTO,BF_local,BF_localIZ,BF_NUMSERI,BF_LOTECTL,BF_NUMLOTE))
            if (nSaldoAtu-nSaldoCB8) > 0
                nSaldoSBF += (nSaldoAtu-nSaldoCB8)
                AAdd(aSaldoSBF,{(cAliasSBF)->BF_PRODUTO,(cAliasSBF)->BF_local,(cAliasSBF)->BF_localIZ,(cAliasSBF)->BF_LOTECTL,(cAliasSBF)->BF_NUMLOTE,(cAliasSBF)    ->BF_NUMSERI,(nSaldoAtu-nSaldoCB8)})
            endif
        else
            nSaldoAtu := (cAliasSBF)->(SaldoSBF(BF_local,BF_localIZ,BF_PRODUTO,BF_NUMSERI,BF_LOTECTL,BF_NUMLOTE))
            if aVarAlt<> nil .and. (cProd+cArmOri+cEndOri+cLoteOri+cSLoteOri+cNumSerOri) == (cAliasSBF)->(BF_PRODUTO+BF_local+BF_localIZ+BF_LOTECTL+BF_NUMLOTE    +BF_NUMSERI)
                //Se a chave SBF corresponder a chave do CB8, permitir que o usuario possa seleciona-la com o saldo a ser separado:
                nSaldoAtu := nSldSepOri
            endif
    
            if nSaldoAtu > 0
                nSaldoSBF += nSaldoAtu
                AAdd(aSaldoSBF,{(cAliasSBF)->BF_PRODUTO,(cAliasSBF)->BF_local,(cAliasSBF)->BF_localIZ,(cAliasSBF)->BF_LOTECTL,(cAliasSBF)->BF_NUMLOTE,(cAliasSBF)    ->BF_NUMSERI,nSaldoAtu})
            endif
        endif
        (cAliasSBF)->(DbSkip())
    end
    if lQuery
        (cAliasSBF)->( DbCloseArea() )
    endif
    ASort(aSaldoSBF,,,{|x,y| x[01]+x[02]+x[03]+x[04]+x[05]+x[06]<y[01]+y[02]+y[03]+y[04]+y[05]+y[06]})
    
    RestArea(aAreaSBF)
    RestArea(aArea)
return if(lRetSaldo,nSaldoSBF,aSaldoSBF)


static function RetSldCB8(cProd,clocal,clocaliz,cNumSerie,cLote,cSubLote)
local aArea := GetArea()
local aAreaCB7 := CB7->(GetArea())
local nSaldoCB8 := 0

    cQueryCB8 := "SELECT SUM(CB8_SALDOS) AS SALDOSEP FROM " + RetSqlName("CB7") + " CB7, " + RetSqlName("CB8") + " CB8"
    cQueryCB8 += " WHERE CB7.CB7_ORDSEP = CB8.CB8_ORDSEP AND CB7.CB7_OP <> '' AND CB7.CB7_REQOP <> '1' AND"
    cQueryCB8 += " CB8.CB8_local = '" + clocal + "' AND CB8.CB8_LCALIZ = '" + clocaliz + "' AND"
    cQueryCB8 += " CB8.CB8_NUMSER = '" + cNumSerie + "' AND CB8.CB8_LOTECT = '" + cLote + "' AND CB8.CB8_NUMLOT = '" + cSubLote + "' AND"
    cQueryCB8 += " CB8.CB8_PROD = '" + cProd + "' AND CB8.CB8_SALDOS > 0 AND"
    cQueryCB8 += " CB7.CB7_FILIAL = '" + xFilial("CB7") + "' AND CB8.CB8_FILIAL = '" + xFilial("CB8") + "' AND "
    cQueryCB8 += " CB7.D_E_L_E_T_ <> '*' AND CB8.D_E_L_E_T_ <> '*'"
    cQueryCB8 := ChangeQuery( cQueryCB8 )
    TCQUERY cQueryCB8 NEW ALIAS "CB8TMP"
    DbSelectArea("CB8TMP")
    CB8TMP->(DbGoTop())
    if CB8TMP->(!Eof())
        nSaldoCB8 := CB8TMP->SALDOSEP
    endif
    CB8TMP->( DbCloseArea() )
    
    RestArea(aAreaCB7)
    RestArea(aArea)
return nSaldoCB8


static function SemSldOS()
local lRet := .f.
local nUnPA := 0
local nX

    //aEmp:
    // [01] - OP
    // [02] - Produto
    // [03] - Quantidade
    // [04] - Saldo em Estoque
    // [05] - Quantidade na estrutura
    // [06] - Quantidade disponivel para a producao de um PA
    // [07] - Nova quantidade a ser definida para a meteria-prima (com base na estrutura)
    
    SG1->(DbSetOrder(1))
    //Calcula quantos produtos acabados podem ser gerados com as materias-primas empenhadas:
    for nX:=1 to Len(aEmp)
        if SG1->(DbSeek(xFilial("SG1")+SC2->C2_PRODUTO+aEmp[nX,02]))
            aEmp[nX,05] := SG1->G1_QUANT
            if aEmp[nX,04] >= aEmp[nX,03]  //Se tem saldo suficiente para atender a quantidade da OP:
                aEmp[nX,06] := SC2->C2_QUANT-(SC2->C2_QUJE+SC2->C2_PERDA)
            else  //Se saldo insuficiente, encontrar o coeficiente para producao de um PA
                aEmp[nX,06] := (aEmp[nX,04]/SG1->G1_QUANT)
                if aEmp[nX,06] == 0
                    aEmp[nX,06] := 0.1 //Se zero, novo valor deve ter residuo para processar abaixo
                endif
            endif
        endif
    next
    ASort(aEmp,,,{|x,y| x[06]<y[06]})
    
    //Verifico qual a menor unidade para producao de um produto acabado:
    //(descartando as materias-primas que nao fazem parte da estrutura e foram incluidas manualmente):
    for nX:=1 to Len(aEmp)
        if !Empty(aEmp[nX,06])
            nUnPA := Int(aEmp[nX,06])
            exit
        endif
    next
    
    if nUnPA <= 0
        lRet := .t.
    else
        //Refaco a quantidade de materias-primas necessarias com base no coeficiente encontrado para producao do PA:
        for nX:=1 to Len(aEmp)
            if !Empty(aEmp[nX,05])  //Se empenho nao incluido manualmente
                aEmp[nX,07] := aEmp[nX,05] * nUnPA
            else
                aEmp[nX,07] := aEmp[nX,03]
            endif
        next
    endif

return lRet


static function RetEmpOS(lConsEst,cProdEmp,nQtdEmp)
local nRet := 0

    if !lConsEst
        nRet := nQtdEmp
    else    
        nRet := aEmp[AScan(aEmp,{|x| x[02] == cProdEmp}), 07]
    endif

return nRet


static function AltEmp(aHeaderEmp,aColsEmp)
local nOpcao := 0
local cPictCB8 := PesqPict('CB8','CB8_SALDOS')
local oDlgEmp
local oNewGetDados
local cProdAtu
local oDescPrd
local cDescPrd
local oArmOri
local cArmOri
local oEndOri
local cEndOri
local oLoteOri
local cLoteOri
local oSLoteOri
local cSLoteOri
local oNumSerOri
local cNumSerOri
local oQtdOri
local nQtdOri
local oQtdSep
local lJaSeparou

// variaveis private, necessario dependencia dentro da GetDados.
private aHeaderAtu := aClone(aHeaderEmp)
private aColsAtu := aClone(aColsEmp)
private nAtaCols := n
private aHeadForm := {}
private aColsForm := {}
private aHeader := {}
private aCols := {}
private cLoteSug := Space(TamSx3("CB8_LOTECT")[1])
private cSLoteSug := Space(TamSx3("CB8_NUMLOT")[1])
private nQtdSug := 0
private cLocSug := Space(TamSx3("CB8_local")[1])
private cEndSug := Space(TamSx3("CB8_local")[1])
private cNumSerSug := Space(TamSx3("CB8_NUMSER")[1])
private oQtdSldInf
private nQtdSldInf := GDFGet2("CB8_SALDOS")
private nQtdSep

    cProdAtu := GDFGet2("CB8_PROD")
    cArmOri := GDFGet2("CB8_local")
    cEndOri := GDFGet2("CB8_LCALIZ")
    cLoteOri := GDFGet2("CB8_LOTECT")
    cSLoteOri := GDFGet2("CB8_NUMLOT")
    cNumSerOri := GDFGet2("CB8_NUMSER")
    nQtdOri := GDFGet2("CB8_QTDORI")
    nQtdSep := GDFGet2("CB8_QTDORI")-GDFGet2("CB8_SALDOS")
    lJaSeparou := nQtdSep > 0
    
    if GdDeleted(nAtaCols,aHeaderEmp,aColsEmp)
        Alert("Nao e permitida a alteracao de empenhos de itens deletados!")
        aHeader := aClone(aHeaderAtu)
        aCols := aClone(aColsAtu)
        return nil
    endif
    
    if !localiza(cProdAtu)
        Alert("So e permitida a alteracao de empenhos da Ordem de Separacao quando o produto controlar enderecamento!")
        aHeader := aClone(aHeaderAtu)
        aCols := aClone(aColsAtu)
        return nil
    endif
    
    if nQtdOri == nQtdSep
        Alert("O produto "+AllTrim(cProdAtu)+" ja foi totalmente separado!")
        aHeader := aClone(aHeaderAtu)
        aCols := aClone(aColsAtu)
        return nil
    endif
    
    SB1->(DbSetOrder(1))
    SB1->(DbSeek(xFilial("SB1")+cProdAtu))
    cDescPrd := AllTrim(cProdAtu)+" - "+AllTrim(SB1->B1_DESC)
    
    aHeadForm := RetHeaderForm()
    aColsForm := RetColsForm()
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Ativa tecla F4 para comunicacao com Saldos Empenhados        ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    SetKey( VK_F4, {|| ShowF4()} )
    
    DEFINE MSDIALOG oDlgEmp TITLE "Substituicao de Empenhos - <F4 - Consulta Empenhos>"From 50,50 to 450,855 PIXEL
        @ 15,05 TO 65,400 LABEL "" OF oDlgEmp PIXEL
        @ 47,05 TO 05,400 LABEL "" OF oDlgEmp PIXEL
        @ 22,010 SAY "Produto:" SIZE 200,8 OF oDlgEmp PIXEL
        @ 34,010 SAY "Local:" SIZE 20,8 OF oDlgEmp PIXEL
        @ 34,055 SAY "Endereco:" SIZE 25,8 OF oDlgEmp PIXEL
        @ 34,155 SAY "Lote:" SIZE 200,8 OF oDlgEmp PIXEL
        @ 34,225 SAY "Sublote:" SIZE 20,8 OF oDlgEmp PIXEL
        @ 34,292 SAY "Num.Serie:" SIZE 40,8 OF oDlgEmp PIXEL
    
        @ 52,010 SAY "Quantidade Original:" SIZE 150,8 OF oDlgEmp PIXEL
        @ 52,160 SAY "Saldo Separado:" SIZE 150,8 OF oDlgEmp PIXEL
        @ 52,300 SAY "Saldo a Informar:" SIZE 150,8 OF oDlgEmp PIXEL
    
        @ 21,032 MSGET oDescPrd VAR cDescPrd PICTURE "@!" SIZE 222,06 WHEN .f. OF oDlgEmp PIXEL
        @ 33,032 MSGET oArmOri VAR cArmOri PICTURE "@!" SIZE 15,06 WHEN .f. OF oDlgEmp PIXEL
        @ 33,085 MSGET oEndOri VAR cEndOri PICTURE "@!" SIZE 60,06 WHEN .f. OF oDlgEmp PIXEL
        @ 33,175 MSGET oLoteOri VAR cLoteOri PICTURE "@!" SIZE 38,06 WHEN .f. OF oDlgEmp PIXEL
        @ 33,250 MSGET oSLoteOri VAR cSLoteOri PICTURE "@!" SIZE 30,06 WHEN .f. OF oDlgEmp PIXEL
        @ 33,325 MSGET oNumSerOri VAR cNumSerOri PICTURE "@!" SIZE 70,06 WHEN .f. OF oDlgEmp PIXEL
        @ 51,062 MSGET oQtdOri VAR nQtdOri PICTURE cPictCB8 SIZE 50,06 WHEN .f. OF oDlgEmp PIXEL
        @ 51,203 MSGET oQtdSep VAR nQtdSep PICTURE cPictCB8 SIZE 50,06 WHEN .f. OF oDlgEmp PIXEL
        @ 51,345 MSGET oQtdSldInf VAR nQtdSldInf PICTURE cPictCB8 SIZE 50,06 WHEN .f. OF oDlgEmp PIXEL
        AtuSldInf(.f.,nQtdOri)
        oNewGetDados := MsNewGetDados():New(025,005,160,280,GD_INSERT+GD_UPDATE+GD_DELETE,"u_lokmoa01l()",,/*inicpos*/,,/*freeze*/,50,/*fieldok*/,/*superdel*/,/*delok*/,oDlgEmp,aHeadForm,aColsForm)
        oNewGetDados:oBrowse:bDelete := {|| VldLinDel(oNewGetDados:aCols,oNewGetDados:nAt,oNewGetDados,nQtdSep,nQtdOri) }
        oNewGetDados:oBrowse:Align := CONTROL_ALIGN_BOTTOM
    ACTIVATE DIALOG oDlgEmp ON INIT EnchoiceBar(oDlgEmp,{||(nOpcao:=VldItens(),if(nOpcao==1,oDlgEmp:End(),0))},{||oDlgEmp:End()}) CENTERED
    
    if nOpcao == 1
        Begin Transaction
            AtuNovosEmp(aHeaderEmp,aColsEmp,nAtaCols)
        End Transaction
    else
        aHeader := aClone(aHeaderAtu)
        aCols := aClone(aColsAtu)
    endif
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Desativa tecla F4 para comunicacao com Saldos Empenhados     ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    SET KEY VK_F4 TO
return nil


static function RetHeaderForm()
local aHeaderTMP := {}

    AAdd(aHeaderTMP,{ "Local","cLocSug","@!",02,0,,,"C","","","",,".f."})
    AAdd(aHeaderTMP,{ "Endereco","cEndSug","@!",15,0,,,"C","","","",,".f."})
    AAdd(aHeaderTMP,{ "Quantidade","nQtdSug",PesqPict('CB8','CB8_SALDOS'),12,2,"u_A100VQt(,.t.)",,"N","","","",0,".t."})
    AAdd(aHeaderTMP,{ "Lote","cLoteSug","@!",10,0,,,"C","","","",,".f."})
    AAdd(aHeaderTMP,{ "SubLote","cSLoteSug","@!",06,0,,,"C","","","","",".f."})
    AAdd(aHeaderTMP,{ "Numero de Serie","cNumSerSug","@!",20,0,,,"C","","","",,".f."})

return aClone( aHeaderTMP )


static function RetColsForm()
local cArmOri := GDFGet2("CB8_local")
local cEndOri := GDFGet2("CB8_LCALIZ")
local cLoteOri := GDFGet2("CB8_LOTECT")
local cSLoteOri := GDFGet2("CB8_NUMLOT")
local cNumSerOri:= GDFGet2("CB8_NUMSER")
local nQtdSep := GDFGet2("CB8_QTDORI")-GDFGet2("CB8_SALDOS")

local aColsTMP := {}
local lJaSeparou := nQtdSep > 0

    AAdd(aColsTMP,Array(Len(aHeadForm)+1))
    aColsTMP[1,1] := cArmOri
    aColsTMP[1,2] := cEndOri
    if lJaSeparou
        aColsTMP[1,3] := nQtdSep
    else
        aColsTMP[1,3] := nQtdSldInf
    endif
    aColsTMP[1,4] := cLoteOri
    aColsTMP[1,5] := cSLoteOri
    aColsTMP[1,6] := cNumSerOri
    aColsTMP[1,7] := .f.

return aClone( aColsTMP )


user function A100VQt(nQtde,lAtualiza)
local lRet := .t.
local cProduto := GDFGet2("CB8_PROD")
local cArmOri := GDFGet2("CB8_local")
local cEndOri := GDFGet2("CB8_LCALIZ")
local cLoteOri := GDFGet2("CB8_LOTECT")
local cSLoteOri := GDFGet2("CB8_NUMLOT")
local cNumSerOri:= GDFGet2("CB8_NUMSER")
local nQtdSep := GDFGet2("CB8_QTDORI")-GDFGet2("CB8_SALDOS")
local nQtdOri := GDFGet2("CB8_QTDORI")

local aRetSld := {}
local nSldTMP := 0
local cChaveAtu := ""
local nPos
local nX
local lJaSeparou := nQtdSep > 0

    if nQtde == nil
        if Empty(ReadVar())
            nQtde:= GDFieldGet('nQtdSug',n)
        else
            nQtde:= M->nQtdSug
        endif
    endif
    
    if Empty(nQtde)
        MsgAlert("Quantidade invalida!!!")
        lRet := .f.
    elseif lJaSeparou .AND. (n == 1)
        MsgAlert("A linha nao pode ser editada pois ja foi separada!!!")
        lRet := .f.
    else
    
        aRetSld := RetSldEnd(cProduto,.f.,{cArmOri,cEndOri,cLoteOri,cSLoteOri,cNumSerOri,nQtde})
        cChaveAtu := GDFieldGet('cLocSug',n)+GDFieldGet('cEndSug',n)+GDFieldGet('cLoteSug',n)+GDFieldGet('cSLoteSug',n)+GDFieldGet    ('cNumSerSug',n)
        nPos := AScan(aRetSld,{|x| x[02]+x[03]+x[04]+x[05]+x[06] == cChaveAtu})
        if nPos == 0
            MsgAlert("Saldo indisponivel!!!")
            lRet := .f.
        else
        
            for nX:=1 to Len(aColsForm)
                if (nX <> n) .AND. (aColsForm[nX,01]+aColsForm[nX,02]+aColsForm[nX,04]+aColsForm[nX,05]+aColsForm[nX,06]==cChaveAtu) .AND.     !aColsForm[nX,07]
                    MsgAlert("A chave: local+Endereco+Lote+Sublote+Num.Serie ja foi informada em outra linha!!!")
                    lRet := .f.
                    exit
                endif
            next
        
            if lRet
                if nQtde > aRetSld[nPos,07]
                    MsgAlert("A quantidade digitada e superior ao saldo disponivel!!!")
                    lRet := .f.
                else
            
                    for nX:=1 to Len(aColsForm)
                        if (nX <> n) .AND. !aColsForm[nX,07]
                            nSldTMP += aColsForm[nX,03]
                        endif
                    next
                
                    if nQtde > (nQtdOri-nSldTMP)
                        MsgAlert("A quantidade digitada e superior ao saldo a ser informado!!!")
                        lRet := .f.
                    else
                        if lAtualiza
                            //Atualiza a informacao da array:
                            if n > Len(aColsForm)
                                AAdd(aColsForm,Array(Len(aHeadForm)+1))
                                aColsForm[Len(aColsForm),01] := GDFieldGet('cLocSug',n)
                                aColsForm[Len(aColsForm),02] := GDFieldGet('cEndSug',n)
                                aColsForm[Len(aColsForm),03] := nQtde
                                aColsForm[Len(aColsForm),04] := GDFieldGet('cLoteSug',n)
                                aColsForm[Len(aColsForm),05] := GDFieldGet('cSLoteSug',n)
                                aColsForm[Len(aColsForm),06] := GDFieldGet('cNumSerSug',n)
                                aColsForm[Len(aColsForm),07] := .f.
                            else
                                aColsForm[n,01] := GDFieldGet('cLocSug',n)
                                aColsForm[n,02] := GDFieldGet('cEndSug',n)
                                aColsForm[n,03] := nQtde
                                aColsForm[n,04] := GDFieldGet('cLoteSug',n)
                                aColsForm[n,05] := GDFieldGet('cSLoteSug',n)
                                aColsForm[n,06] := GDFieldGet('cNumSerSug',n)
                            endif
                        endif
                        AtuSldInf(.t., nQtdOri)  //Atualiza o saldo a ser informado
                    endif
                endif
            endif 
        endif
    endif
return lRet

user function lokmoa01l()
local lRet := .t.

    if !aColsForm[n,7] .and. (nQtdSep <= 0 .or. n != 1) .and. !u_A100VQt(,.f.)
        lRet := .f.
    endif

return lRet

static function VldLinDel(aCols,nPosAtu,oGetDados,nQtdSep,nQtdOri)
local lRet := .t.

    if !aCols[nPosAtu,7]
        if nQtdSep > 0 .AND. (nPosAtu == 1)
            MsgAlert("A linha nao pode ser excluida pois a quantidade ja foi separada!!!")
            lRet := .f.
        else
            //Nao estava deletado antes...
            aCols[nPosAtu,7] := .t.
            aColsForm[nPosAtu,7] := .t.
            AtuSldInf(.t.,nQtdOri)  //Atualiza o saldo a ser informado
        endif
    else
        //Estava deletado antes...
        //Verifica se ainda existe saldo a ser informado:
        if aCols[nPosAtu,3] > nQtdSldInf
            MsgAlert("A quantidade definida para este lote e superior ao saldo a ser informado!!!")
            lRet := .f.
        else
            aCols[nPosAtu,7] := .f.
            aColsForm[nPosAtu,7] := .f.
            AtuSldInf(.t.,nQtdOri)  //Atualiza o saldo a ser informado
        endif
    endif
    oGetDados:Refresh()

return lRet


static function VldItens()
local cArmOri := GDFGet2("CB8_local")
local cEndOri := GDFGet2("CB8_LCALIZ")
local cLoteOri := GDFGet2("CB8_LOTECT")
local cSLoteOri := GDFGet2("CB8_NUMLOT")
local cNumSerOri:= GDFGet2("CB8_NUMSER")

local nQtdTMP := 0
local nX

    for nX:=1 to Len(aColsForm)
        if aColsForm[nX,07]
            loop
        endif
        nQtdTMP += aColsForm[nX,03]
    next
    
    if nQtdSldInf == 0
        if (Len(aColsForm) == 1) .AND. (aColsForm[1,1] == cArmOri) .AND. (aColsForm[1,2] == cEndOri) .AND. (aColsForm[1,4] == cLoteOri) .AND.;
              (aColsForm[1,5] == cSLoteOri) .AND. (aColsForm[1,6] == cNumSerOri)
            return 1
        endif
        if !MsgYesNo("Confirma a substituicao dos empenhos?")
            return 0
        endif
        lAlterouEmp := .t.
        return 1
    endif
    
    if nQtdTMP <> nQtdSldInf
        MsgAlert("Ainda existe saldo a ser informado. Verifique!!!")
        return 0
    endif

return 1


static function AtuSldInf(lAtuTela,nQtdOri)
local nQtdInfo := 0
local nX

    for nX:=1 to Len(aColsForm)
        if !aColsForm[nX,07]
            nQtdInfo += aColsForm[nX,03]
        endif
    next
    nQtdSldInf :=(nQtdOri-nQtdInfo)
    if lAtuTela
        oQtdSldInf:Refresh()
    endif

return nil


static function ShowF4()
local lRet := .t.
local cProdAtu := GDFGet2("CB8_PROD")
local cArmOri := GDFGet2("CB8_local")
local cEndOri := GDFGet2("CB8_LCALIZ")
local cLoteOri := GDFGet2("CB8_LOTECT")
local cSLoteOri := GDFGet2("CB8_NUMLOT")
local cNumSerOri:= GDFGet2("CB8_NUMSER")
local nQtdSep := GDFGet2("CB8_QTDORI")-GDFGet2("CB8_SALDOS")

local cCampo := AllTrim(Upper(ReadVar()))
local oDlgEnd
local nOpcEnd := 0
local nAtEnd
local aListAux := {}
local lJaSeparou := nQtdSep > 0

private oListEnd
private aListEnd := {}
private cVarEnd

    if cCampo == "M->NQTDSUG"
    
        aListAux := RetSldEnd(cProdAtu,.f.,{cArmOri,cEndOri,cLoteOri,cSLoteOri,cNumSerOri,nQtdSldInf})
        if Empty(aListAux)
            MsgAlert("Produto sem saldo disponivel!!!")
            lRet := .f.
        else
            aEval(aListAux,{|x| AAdd(aListEnd,{x[2],x[3],x[7],x[4],x[5],x[6]})})
        
            DEFINE MSDIALOG oDlgEnd TITLE ":: Saldos disponiveis ::" From 50,50 to 300,390 PIXEL
                @ 00,00 LISTBOX oListEnd VAR cVarEnd Fields HEADER 'Local', "Endereco:", 'Quantidades',"Lote:", "Sublote:", "Num. Serie:" SIZE 50,110 PIXEL of oDlgEnd 
                oListEnd:Align := CONTROL_ALIGN_TOP
                oListEnd:SetArray( aListEnd )
                oListEnd:bLine := { || { aListEnd[oListEnd:nAT,1], aListEnd[oListEnd:nAT,2], aListEnd[oListEnd:nAT,3], aListEnd    [oListEnd:nAT,4], aListEnd[oListEnd:nAT,    5], aListEnd[oListEnd:nAT,6] } }
                oListEnd:Refresh()
                DEFINE SBUTTON FROM 113,115 TYPE 1 ACTION (nOpcEnd:=1,nAtEnd:=oListEnd:nAT,oDlgEnd:End()) ENABLE Of oDlgEnd
                DEFINE SBUTTON FROM 113,143 TYPE 2 ACTION oDlgEnd:End() ENABLE Of oDlgEnd
            ACTIVATE DIALOG oDlgEnd CENTERED
        
            if nOpcEnd == 1
                if lJaSeparou .AND. (n == 1)
                    MsgAlert("A linha nao pode ser editada pois ja foi separada!!!")
                    lRet := .f.
                else
                    //Atualiza informacoes da variavel de memoria:
                    GDFieldPut("cLocSug", aListEnd[nAtEnd][01], n)
                    GDFieldPut("cEndSug", aListEnd[nAtEnd][02], n)
                    &(ReadVar()) := Iif(nQtdSldInf<=aListEnd[nAtEnd][03], nQtdSldInf, aListEnd[nAtEnd][03])
                    GDFieldPut("cLoteSug", aListEnd[nAtEnd][04], n)
                    GDFieldPut("cSLoteSug", aListEnd[nAtEnd][05], n)
                    GDFieldPut("cNumSerSug", aListEnd[nAtEnd][06], n)
                endif
            endif
        endif
    endif

return lRet


static function AtuNovosEmp(aHeaderEmp,aColsEmp,nAtaCols)
local nPosPROD := AScan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_PROD" })
local nPoslocal := AScan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_local" })
local nPosLCALIZ := AScan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_LCALIZ" })
local nPosQTDORI := AScan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_QTDORI" })
local nPosSALDOS := AScan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_SALDOS" })
local nPosSALDOE := AScan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_SALDOE" })
local nPosLOTECT := AScan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_LOTECT" })
local nPosNUMLOT := AScan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_NUMLOT" })
local nPosNUMSER := AScan(aHeaderEmp,{|x| UPPER(AllTrim(x[2]))=="CB8_NUMSER" })

local nQtdSep := aColsEmp[nAtaCols,nPosQTDORI]-aColsEmp[nAtaCols,nPosSALDOS]
local lJaSeparou := nQtdSep > 0

local cTipExp := CB7->CB7_TIPEXP
local aColsLinha
local nLen
local nX

    //Atualiza as arrays de controle do MSGetDados:
    aHeader := aClone(aHeaderEmp)
    aCols := {}
    aColsLinha := aClone(aColsEmp[nAtaCols])
    
    if lJaSeparou
        aColsEmp[nAtaCols,nPosQTDORI] := nQtdSep
        aColsEmp[nAtaCols,nPosSALDOS] := 0
        aColsEmp[nAtaCols,nPosSALDOE] := 0
    else
        aDel(aColsEmp,nAtaCols)
        aSize(aColsEmp,Len(aColsEmp)-1)
    endif
    
    //Inclui os itens sugeridos:
    for nX:=1 to Len(aColsForm)
        if aColsForm[nX,07] .OR. (lJaSeparou .AND. nX == 1)
            loop
        endif
        AAdd(aColsEmp,aClone(aColsLinha))
        nLen:= len(aColsEmp)
        aColsEmp[nLen,nPoslocal] := aColsForm[nX,01]
        aColsEmp[nLen,nPosLCALIZ] := aColsForm[nX,02]
        aColsEmp[nLen,nPosQTDORI] := aColsForm[nX,03]
        aColsEmp[nLen,nPosSALDOS] := aColsForm[nX,03]
        if !("09*" $ cTipExp) .AND. ("02*" $ cTipExp)
            aColsEmp[nLen,nPosSALDOE] := aColsForm[nX,03]
        else
            aColsEmp[nLen,nPosSALDOE] := 0
        endif
        aColsEmp[nLen,nPosLOTECT] := aColsForm[nX,04]
        aColsEmp[nLen,nPosNUMLOT] := aColsForm[nX,05]
        aColsEmp[nLen,nPosNUMSER] := aColsForm[nX,06]
    next
    ASort(aColsEmp,,,{|x,y| x[nPosPROD]+x[nPoslocal]+x[nPosLCALIZ]+x[nPosLOTECT]+x[nPosNUMLOT]+x[nPosNUMSER] < ;
                             y[nPosPROD]+y[nPoslocal]+y[nPosLCALIZ]+y[nPosLOTECT]+y[nPosNUMLOT]+y[nPosNUMSER] })
    
    aCols :=aClone(aColsEmp)
    
    //Atualiza o getdados:
    n:=1
    oGet:Refresh()

return nil


static function GravaCB8()
local nX
local nJ

    CB8->(DbSetOrder(1))
    while CB8->(DbSeek(xFilial('CB8')+CB7->CB7_ORDSEP))
        CB8->(RecLock("CB8",.f.))
        CB8->(dbDelete())
        CB8->(MsUnLock())
    end
    for nX:=1 to Len(aCols)
        if GdDeleted(nX,aHeader,aCols)
            loop
        endif
        ++nItensCB8
        CB8->(RecLock("CB8",.t.))
        CB8->CB8_FILIAL := xFilial("CB8")
        CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
        for nJ := 1 to len(aHeader)
            if aHeader[nJ,10] == "V"
                loop
            endif
            CB8->&(AllTrim(aHeader[nJ,2])) := aCols[nX,nJ]
        next
        if !Empty(CB8->CB8_OCOSEP) .and. (CB8->CB8_SALDOS-CB8->CB8_QTECAN) > 0
            lDiverg := .t.
        endif
        CB8->(MsUnlock())
    next

return nil


static function ProcAtuEmp(aItensEmp,lEstorno)

//    Parametros para a chamada da Funcao GravaEmp ------------------------------------------
local lEmpSB2 := .t.                                   //    Indica se Empenha Material no SB2
local lEmpSB8SBF := .t.                                //    Indica se Empenha Material em SB8/SBF
local lCriaSDC := .t.                                  //    Indica se cria Registro no SDC
local lGravaSD4 := (CB7->CB7_ORIGEM=="3")              //    Indica se grava registro no SD4
local cOrigem := if(CB7->CB7_ORIGEM=="1","SC6","SD3")  // Indica a Origem do Empenho (SC6,SD3...)
local cProduto := ''                                   // Produto
local clocal := ''                                     // Armazem
local nQtd := 0                                        // Quantidade Empenhada
local nQtd2UM := 0                                     // Quantidade Empenhada na Segunda Unidade de Medida
local cLote := ''                                      // Lote
local cNumLote := ''                                   // Sub-Lote
local cOp := CB7->CB7_OP                               // Codigo da OP
local cTrt := ''                                       // Sequencia do Empenho / Liberacao do Pedido de Vendas
local cPedido := CB7->CB7_PEDIDO                       // Pedido de vendas
local cItem := ''                                      // Item do Pedido de Vendas
local cOpOrig := ''                                    // OP Original
local dEntrega := cTod("//")                           // Data de Entrega do Empenho
local aTravas := {}                                    //    Array para Travamento dos Saldos, Se = {}, nao ha travamento
local lProj := .f.                                     //    Informa se e chamada da Projecao de Estoque
local lConsVenc := .t.                                 // Indica se considera lote vencido
local lEncerrOp := .f.                                 // Indica se Encerra Empenho de OP
local cIdDCF := ''                                     // Identificador do DFC
local dVldLote := cTod("//")                           // Data de Validade do Lote
//----------------------------------------------------------------------------------------

local msg1 := if(lEstorno,"   [Exclusao]","   [Inclusao]")
local msg2 := if(lEstorno,"   Exclusao do Empenho OK","   Inclusao do Empenho OK")
local nX := 0
local aEmp := {}

    for nX:= 1 to len(aItensEmp)
    
        cProduto := GDFieldGet("CB8_PROD", nX,,, aItensEmp)
        cItem := GDFieldGet("CB8_ITEM", nX,,, aItensEmp)
        clocal := GDFieldGet("CB8_local", nX,,, aItensEmp)
        cLote := GDFieldGet("CB8_LOTECT", nX,,, aItensEmp)
        cNumLote := GDFieldGet("CB8_NUMLOT", nX,,, aItensEmp)
        clocaliz := GDFieldGet("CB8_LCALIZ", nX,,, aItensEmp)
        cNumSer := GDFieldGet("CB8_NUMSER", nX,,, aItensEmp)
        nQtd := GDFieldGet("CB8_QTDORI", nX,,, aItensEmp)
        cTrt := GDFieldGet("CB8_SEQUEN", nX,,, aItensEmp)
    
        nQtd2UM :=ConvUm(cProduto,nQtd,nQtd2UM,2)
    
       if AScan(aEmp,{|x| x[1]+x[2]+x[3]+x[4]+x[5] == cProduto+cItem+clocal+cLote+cNumLote+cNumSer}) == 0
            AAdd(aEmp,{cProduto,cItem,clocal,cLote,cNumLote,cPedido,nQtd,nQtd2UM,clocaliz,cNumSer,cTrt})
       endif
    
    next
    
    for nX:=1 to Len(aEmp)
    
        AutoGrLog(msg1)
        AutoGrLog("   Produto...: "+aEmp[nX,1])
        AutoGrLog("   Item......: "+aEmp[nX,2])
        AutoGrLog("   Quantidade: "+Alltrim(Str(aEmp[nX,7])))
        AutoGrLog("   Armazem...: "+aEmp[nX,3])
        AutoGrLog("   Lote......: "+aEmp[nX,4])
        AutoGrLog("   Num.Serie.: "+aEmp[nX,10])
        if !Empty(cPedido)
            AutoGrLog("   Pedido....: "+cPedido    )
        else
            AutoGrLog("   Op........: "+cOp    )
        endif
    
        SB8->(DbSetOrder(3))
        if SB8->(DbSeek(xFilial("SB8") + aEmp[nX,1] + aEmp[nX,3] + aEmp[nX,4]))
            dVldLote := SB8->B8_DTVALID
        endif
    
        GravaEmp(aEmp[nX,1],aEmp[nX,3],aEmp[nX,7],nQtd2UM,aEmp[nX,4],aEmp[nX,5],aEmp[nX,9],aEmp[nX,10],cOp,aEmp[nX,11],cPedido,aEmp[nX,2],cOrigem,cOpOrig,dEntrega,    aTravas,lEstorno,lProj,lEmpSB2,lGravaSD4,lConsVenc,lEmpSB8SBF,lCriaSDC,lEncerrOp,cIdDCF)
    
        AutoGrLog(msg2)
        AutoGrLog("   ")
    
    next

return .t.


static function LimpaInfoOS()
local nPosPed := AScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_PEDIDO" })
local nPosItPed := AScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_ITEM"   })
local nPosSeqPed := AScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_SEQUEN" })
local nPosPrdPed := AScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_PROD"   })
local nPosNSPed := AScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_NUMSER" })
local nPosNota := AScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_NOTA"   })
local nPosSerie := AScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_SERIE"  })
local nPosOP := AScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_OP"     })
local nPosDel := Len(aHeader)+1
local cPedAtu, cChavePV
local i, nQ, nItens

    for i:=1 to Len(aCols)
        if aCols[i,nPosDel]
            if CB7->CB7_ORIGEM == "1"  //Por pedido
                if Empty(aCols[i,nPosPed])
                    loop
                endif
                cPedAtu := aCols[i,nPosPed]
                CB8->(DbGoto(aRecno[i]))
                CB8->(RecLock( "CB8",.f.))
                CB8->(dbDelete())
                CB8->(MsUnLock())
                //Verifica se o item possui N.Serie, neste caso, avaliar se existem itens com mesma chave que nao foram excluidos...
                if !Empty(aCols[i,nPosNSPed])
                    cChavePV := aCols[i,nPosPed]+aCols[i,nPosItPed]+aCols[i,nPosSeqPed]+aCols[i,nPosPrdPed]
                    nItens := 0
                    aEval(aCols,{|x| if(x[nPosPed]+x[nPosItPed]+x[nPosSeqPed]+x[nPosPrdPed]==cChavePV .AND. !x[nPosDel],nItens++,nil)})
                    if nItens > 0
                        loop
                    endif
                endif
                SC9->(DbSetOrder(1))
                if SC9->( DbSeek( xFilial("SC9")+cPedAtu+aCols[i,nPosItPed]+aCols[i,nPosSeqPed]+aCols[i,nPosPrdPed]    ) )
                    if ! Empty(SC9->C9_ORDSEP)
                        SC9->(RecLock("SC9",.f.))
                        SC9->C9_ORDSEP := ""
                        SC9->(MsUnlock())
                    endif
                endif
            elseif CB7->CB7_ORIGEM == "2"  //Por Nota
                if Empty(aCols[i,nPosNota]+aCols[i,nPosSerie])
                    loop
                endif
                cNotaAtu := aCols[i,nPosNota]
                cSeriAtu := aCols[i,nPosSerie]
                nQ := 0
                aEval(aCols,{|x| if(x[nPosNota]+x[nPosSerie]==cNotaAtu+cSeriAtu,nQ++,nil)})
                aCols[i,nPosNota] := ""
                aCols[i,nPosSerie] := ""
                CB8->(DbGoto(aRecno[i]))
                CB8->(RecLock( "CB8",.f.))
                CB8->(dbDelete())
                CB8->(MsUnLock())
                if nQ == 1
                    SF2->(DbSetOrder(1))
                    if SF2->(DbSeek(xFilial("SF2")+cNotaAtu+cSeriAtu))
                        if ! Empty(SF2->F2_ORDSEP)
                            SF2->(RecLock("SF2",.f.))
                            SF2->F2_ORDSEP := ""
                            SF2->(MsUnlock())
                        endif
                    endif
                endif
            elseif CB7->CB7_ORIGEM == "3"  //Por OP
                if Empty(aCols[i,nPosOP])
                    loop
                endif
                cOPAtu := aCols[i,nPosOP]
                nQ := 0
                aEval(aCols,{|x| if(x[nPosOP]==cOPAtu,nQ++,nil)})
                aCols[i,nPosOP] := ""
                CB8->(DbGoto(aRecno[i]))
                CB8->(RecLock( "CB8",.f.))
                CB8->(dbDelete())
                CB8->(MsUnLock())
                if nQ == 1
                    SC2->(DbSetOrder(1))
                    if SC2->(DbSeek(xFilial("SC2")+cOPAtu))
                        if ! Empty(SC2->C2_ORDSEP)
                            SC2->(RecLock("SC2",.f.))
                            SC2->C2_ORDSEP := ""
                            SC2->(MsUnlock())
                        endif
                    endif
                endif
            endif
        endif
    next

return nil


static function AtuCB7()
local nPosSaldoS := AScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="CB8_SALDOS" })
local nPosDel := Len(aHeader)+1
local lPreSep := ("09*" $ CB7->CB7_TIPEXP)
local lOK := .t.
local i

    for i:=1 to Len(aCols)
        if !aCols[i,nPosDel] .and. ! Empty(aCols[i,nPosSaldoS]) // Linha nao esta Deletada e o produto tem saldo a separar ...
            lOK:= .f.
            exit
        endif
    next
    
    CB7->(RecLock( "CB7", .f. ))
    CB7->CB7_CODOPE := M->CB7_CODOPE
    CB7->CB7_DIVERG := if(lDiverg,"1"," ")
    CB7->CB7_NUMITE := nItensCB8
    
    if lOK // Nao tem nada pendente para separacao
        RecLock("CB7",.f.)
        if lPreSep
            CB7->CB7_STATPA := " "
            CB7->CB7_STATUS := "9"    // Processo de Expedicao finalizado
        else
            CB7->CB7_STATPA := "1"
            CB7->CB7_STATUS := "2"  // Processo de separacao finalizado
        endif
    endif
    
    CB7->(MsUnLock())

return nil


static function ConsEmb()
local oDlgVol
local aButtons := {}
local aSize := MsAdvSize()
local lTemVol := .f.
local lImpEtiq := if(("05") $ CB7->CB7_TIPEXP,VldImpEtiq(),.t.)
local lEncEtap := .t.
local nI := 0
local oPanEsq
local oPanDir
local oPanelCB3
local oTreeVol
local oEncCB3
local oEncCB6
local oEncCB9

private aVolumes := {}
private aSubVols := {}

    CB9->(DbSetOrder(1))
    CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
    while CB9->(!Eof() .AND. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+CB7->CB7_ORDSEP)
        if !Empty(CB9->CB9_VOLUME)
            lTemVol := .t.
            exit
        endif
        CB9->(DbSkip())
    end
    if !lTemVol
        MsgStop("Volumes não encontrados!")
        return nil
    endif
    
    if lImpEtiq
        //Adiciona botao de impressao de etiquetas:
        AAdd(aButtons, {'RPMNEW',{|| ImpEtiqVol(oTreeVol:GetCargo())},"Impr.Etiq.Vol.","Impr.Etiq.Vol."})
    endif
    
    DEFINE MSDIALOG oDlgVol TITLE "Consulta de volumes - Ordem de Separação: "+CB7->CB7_ORDSEP FROM aSize[07],0 TO aSize[06],aSize[05] PIXEL //OF oMainWnd PIXEL
    
        @ 000,000 SCROLLBOX oPanEsq  HORIZONTAL SIZE 200,270 OF oDlgVol BORDER
        oPanEsq:Align := CONTROL_ALIGN_LEFT
    
        oTreeVol := DbTree():New(0, 0, 0, 0, oPanEsq,,,.t.)
        oTreeVol:bChange := {|| AtuEncDir(oTreeVol:GetCargo(),oPanelCB3,oEncCB3,oEncCB6,oEncCB9)}
        oTreeVol:blDblClick := {|| AtuEncDir(oTreeVol:GetCargo(),oPanelCB3,oEncCB3,oEncCB6,oEncCB9)}
        oTreeVol:Align := CONTROL_ALIGN_ALLCLIENT
    
        @ 000,000 MsPanel oPanDir  Of oDlgVol
        oPanDir:Align := CONTROL_ALIGN_ALLCLIENT
    
        oPanelCB3 := TPanel():New( 028, 072,,oPanDir,,,,,, 200, 80, .f.,.t. )
        oPanelCB3 :Align:= CONTROL_ALIGN_TOP
        oPanelCB3:Hide()
    
        oEncCB3 := MsMGet():New("CB3",1,2,,,,,{015,002,100,100},,,,,,oPanelCB3,,,.f.,nil,,.t.)
        oEncCB3:oBox:Align := CONTROL_ALIGN_ALLCLIENT
        oEncCB3:Hide()
    
        oEncCB6 := MsMGet():New("CB6",1,2,,,,,{015,002,100,100},,,,,,oPanDir,,,.f.,nil,,.t.)
        oEncCB6:oBox:Align := CONTROL_ALIGN_ALLCLIENT
        oEncCB6:Hide()
    
        oEncCB9 := MsMGet():New("CB9",1,2,,,,,{015,002,100,100},,,,,,oPanDir,,,.f.,nil,,.t.)
        oEncCB9:oBox:Align := CONTROL_ALIGN_ALLCLIENT
        oEncCB9:Hide()
    
        AtuTreeVol(oPanelCB3,oTreeVol,oPanelCB3,oEncCB3,oEncCB6,oEncCB9)
    
    ACTIVATE MSDIALOG oDlgVol ON INIT EnchoiceBar(oDlgVol,{||oDlgVol:End()},{||oDlgVol:End()},,aButtons) CENTERED
    
    if lImpEtiq
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Atualiza o status do expedicao            ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        for nI := 1 To Len(aVolumes)
            if CB6->(DbSeek(xFilial("CB6")+aVolumes[nI,1])) .And. CB6->CB6_STATUS == "1"
                lEncEtap := .f.
                exit
            endif
        next nI
    
        CB7->(RecLock('CB7',.f.))
        if lEncEtap
            CB7->CB7_VOLEMI :="1"
            if "05" $ CBUltExp(CB7->CB7_TIPEXP)
                CB7->CB7_STATUS := "9"  // finalizou
            else
                CB7->CB7_STATUS := "7"  // imprimiu volume
                CB7->CB7_STATPA := "1"  // pausa
            endif
        else
            if !IsInCallStack('u_macd01vs')
                CB7->CB7_STATUS := CBAntProc(CB7->CB7_TIPEXP,"05*") // estorno
            endif
        endif
        CB7->(MsUnlock())
    endif

return nil


static function AtuTreeVol(oPanelCB3,oTreeVol,oPanelCB3,oEncCB3,oEncCB6,oEncCB9)
local aAreaCB9 := CB9->(GetArea())
local cDescItem
local cSubVolAtu
local nPosVol
local lFechaTree
local nX, nY

    aVolumes := {}
    CB9->(DbSetOrder(1))
    CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
    while CB9->(!Eof() .AND. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+CB7->CB7_ORDSEP)
        if !Empty(CB9->CB9_VOLUME)
            nPosVol := AScan(aVolumes,{|x| x[01] == CB9->CB9_VOLUME})
            cDescItem := CB9->CB9_PROD+if(!Empty(CB9->CB9_LOTECT)," - Lote: "+CB9->CB9_LOTECT,"")+if(!Empty(CB9->CB9_NUMLOT)," - SubLote: "+CB9->CB9_NUMLOT,"")+if    (!Empty(CB9->CB9_NUMSER)," - Num.Serie: "+CB9->CB9_NUMSER,"")
            if nPosVol == 0
                AAdd(aVolumes,{CB9->CB9_VOLUME,{}})
                nPosVol := Len(aVolumes)
            endif
            AAdd(aVolumes[nPosVol,02],{CB9->CB9_SUBVOL,CB9->CB9_PROD,cDescItem,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_NUMSER,StrZero(CB9->(Recno()),10)})
        endif
        CB9->(DbSkip())
    end
    
    //Reorganiza a array de volumes e subvolumes:
    ASort(aVolumes,,,{|x,y| x[01]<y[01]})
    for nX:=1 to Len(aVolumes)
        ASort(aVolumes[nX,02],,,{|x,y| x[01]+x[04]+x[05]+x[06]<y[01]+y[04]+y[05]+y[06]})
    next
    
    oTreeVol:BeginUpdate()
    oTreeVol:Reset()
    
    for nX:=1 to Len(aVolumes)
        oTreeVol:AddTree("Volume: "+aVolumes[nX,01]+Space(70),.f.,cBmp1,cBmp1,,,aVolumes[nX,01]+Space(TamSx3("B1_COD")[1]+20))
        cSubVolAtu := ""
        for nY:=1 to Len(aVolumes[nX,02])
            if !Empty(aVolumes[nX,02,nY,01]) .AND. Empty(cSubVolAtu)
                cSubVolAtu := aVolumes[nX,02,nY,01]
            elseif !Empty(aVolumes[nX,02,nY,01]) .AND. !Empty(cSubVolAtu) .AND. (cSubVolAtu<>aVolumes[nX,02,nY,01])
                oTreeVol:EndTree()
                cSubVolAtu := aVolumes[nX,02,nY,01]
                lFechaTree := .f.
            endif
            if Empty(aVolumes[nX,02,nY,01])
                //Adiciona produto no volume:
                oTreeVol:AddTreeItem(aVolumes[nX,02,nY,03],cBmp2,,aVolumes[nX,01]+Space(10)+aVolumes[nX,02,nY,02]+aVolumes[nX,02,nY,07])
            elseif !oTreeVol:TreeSeek(AllTrim(aVolumes[nX,01]+aVolumes[nX,02,nY,01]))
                //Adiciona subvolume:
                oTreeVol:AddTree("SubVolume: "+aVolumes[nX,02,nY,01]+Space(60),.f.,cBmp1,cBmp1,,,aVolumes[nX,01]+aVolumes[nX,02,nY,01]+Space(25))
                lFechaTree := .t.
                //Adiciona produto no subvolume:
                oTreeVol:AddTreeItem(aVolumes[nX,02,nY,03],cBmp2,,aVolumes[nX,01]+aVolumes[nX,02,nY,01]+aVolumes[nX,02,nY,02]+aVolumes[nX,02,nY,07])
            else
                //Adiciona produto no subvolume:
                oTreeVol:AddTreeItem(aVolumes[nX,02,nY,03],cBmp2,,aVolumes[nX,01]+aVolumes[nX,02,nY,01]+aVolumes[nX,02,nY,02]+aVolumes[nX,02,nY,07])
            endif
            oTreeVol:TreeSeek("")
        next
        if lFechaTree
            oTreeVol:EndTree()
            lFechaTree := .f.
        endif
        oTreeVol:EndTree()
    next
    
    oTreeVol:EndUpdate()
    oTreeVol:Refresh()
    oTreeVol:TreeSeek("")
    
    AtuEncDir(oTreeVol:GetCargo(),oPanelCB3,oEncCB3,oEncCB6,oEncCB9)  //Atualiza enchoice direita
    
    RestArea(aAreaCB9)
return nil


static function AtuEncDir(cCargoAtu,oPanelCB3,oEncCB3,oEncCB6,oEncCB9)
local nTamVol := TamSX3("CB9_VOLUME")[01]
local nTamSubVol := TamSX3("CB9_SUBVOL")[01]
local cVolume

    if Len(AllTrim(cCargoAtu)) == nTamVol .OR. Len(AllTrim(cCargoAtu)) == (nTamVol+nTamSubVol)  //Volume ou Subvolume
        CB6->(DbSetOrder(1))
        cVolume := if(Len(AllTrim(cCargoAtu))==nTamVol,AllTrim(cCargoAtu),SubStr(cCargoAtu,nTamVol+1,nTamSubVol))
        CB6->(DbSeek(xFilial("CB6")+cVolume))
        CB3->(DbSetOrder(1))
        CB3->(DbSeek(xFilial("CB3")+CB6->CB6_TIPVOL))
        oEncCB9:Hide()
        oEncCB3:Refresh()
        oEncCB6:Refresh()
        oPanelCB3:Show()
        oEncCB3:Show()
        oEncCB6:Show()
    else
         CB9->(Dbgoto(Val(Right(cCargoAtu,10))))
        oEncCB3:Hide()
        oEncCB6:Hide()
        oPanelCB3:Hide()
        oEncCB9:Refresh()
        oEncCB9:Show()
    endif

return nil

static function ImpEtiqVol(cCargoAtu)
local nTamVol := TamSX3("CB9_VOLUME")[01]
local nTamSubVol := TamSX3("CB9_SUBVOL")[01]
local aRet := {}
local aParamBox := {}
local aAreaCB6 := {}
local cIDVol := ""
local cVolume := ""
local cSubVol := ""
local nVolAtu := 1
local nTotVol := Len(aVolumes)
local nPosParam := 1
local nTpEtqVol := 1
local nAtuStaCB7 := 1
local lEtqOfi := ("05" $ CB7->CB7_TIPEXP)

    if !Empty(SubStr(cCargoAtu,nTamVol+1,nTamSubVol))
        cVolume := Left(cCargoAtu,nTamVol)
        cSubVol := SubStr(cCargoAtu,nTamVol+1,nTamSubVol)
        cIDVol := cSubVol
    else
        cVolume := Left(cCargoAtu,nTamVol)
        cIDVol := cVolume
    endif
    nVolAtu := AScan(aVolumes,{|x| x[01] == cVolume})
    
    if lEtqOfi
        AAdd(aParamBox,{3,"Tipo de identificação de volumes:",1,{"Temporaria","Oficial"},50,"",.t.})
    endif
    AAdd(aParamBox,{1,"Local de Impressao",Space(06),"","","CB5","",0,.t.})
    
    if ParamBox(aParamBox,"Volume: "+cIDVol,@aRet,,,,,,,,.f.)
        if lEtqOfi
            nTpEtqVol := aRet[nPosParam]
            ++nPosParam
        endif
    
        if ExistBlock(if(nTpEtqVol==1,"IMG05","IMG05OFI")) .AND. CB5SetImp(aRet[nPosParam],.t.)
            if nTpEtqVol==1  //Volume temporario
                ExecBlock("IMG05",,,{cIDVol,CB7->CB7_PEDIDO,CB7->CB7_NOTA,CB7->CB7_SERIE})
            else  //Volume oficial
                ExecBlock("IMG05OFI",,,{nTotVol,nVolAtu})
    
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Atualiza o status do volume                ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                aAreaCB6 := CB6->(GetArea())
                CB6->(DbSetOrder(1))
    
                if CB6->(DbSeek(xFilial("CB6")+cVolume)) .And. CB6->CB6_STATUS == "3" // Volume encerrado
                    nAtuStaCB7 := Aviso("Aviso","A etiqueta oficial do volume selecionado já foi impressa, gostaria de:",{"Imprimir","Estornar","Cancelar"})
                endif
    
                if nAtuStaCB7 != 3
                    RecLock("CB6",.f.)
                    if nAtuStaCB7 == 1
                        CB6->CB6_STATUS := "3" // Encerrado
                    else
                        CB6->CB6_STATUS := "1" // Aberto
                    endif
                    CB6->(MsUnlock())
                endif
    
                CB6->(RestArea(aAreaCB6))
            endif
            MSCBCLOSEPRINTER()
        endif
    endif

return nil


static function GDFGet2(cCampo)
local nPosCmp := AScan(aHeaderAtu,{|x| Upper(Alltrim(x[2]))==cCampo})
local xRet

    if nPosCmp > 0
        xRet := aColsAtu[nAtaCols,nPosCmp]
    endif

return xRet


static function VldImpEtiq()
return ! ( (CB7->CB7_STATUS == "0" .Or. CB7->CB7_STATUS == "1") .Or. ;
        ("02" $ CB7->CB7_TIPEXP .And. (CB7->CB7_STATUS == "2" .Or. CB7->CB7_STATUS == "3")) .Or. ;
        ("03" $ CB7->CB7_TIPEXP .And. Empty(CB7->(CB7_NOTA+CB7_SERIE))) .Or. ;
        (!ACDGet170() .And. "04" $ CB7->CB7_TIPEXP .And. (CB7->CB7_STATUS != "6")) .Or. ;
        (CB7->CB7_STATUS  == "8") .Or. ;
        (CB7->CB7_STATUS == "9" .And. !("05" $ CBUltExp(CB7->CB7_TIPEXP))) )
