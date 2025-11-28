#include "protheus.ch"
#include "topconn.ch" //-- Adicionado para a função de e-mail

//-------------------------------------------------------------------
/*/{Protheus.doc} U_MNTFINCC
@description Rotina para alterar o Centro de Custo de documentos obrigatórios a pagar.
@author      Especialista ERP Totvs Protheus
@since       16/09/2025
@version     4.0 - Adição de notificação de alteração por e-mail
/*/
//-------------------------------------------------------------------
User Function MNTFINCC()

    Private oTReport
    Private cTitulo := "Gestão de Centro de Custo de Documentos Obrigatórios"

    oTReport := TReport():New( cTitulo, "Documentos com saldo em aberto no Financeiro", {|| .T. },,, .T. )
    oTReport:SetTotalFunction( .F. )

    oTReport:Activate()

Return

//-------------------------------------------------------------------
// As funções MODELDEF e VIEWDEF permanecem as mesmas da versão anterior
//-------------------------------------------------------------------
Static Function MODELDEF( oTReport )

    Local oModel    := oTReport:GetModel()
    Local cQuery    := ""

    oModel:AddColumn( "TS1_CODBEM", "C", "Veículo"      , 10 )
    oModel:AddColumn( "T9_NOME",    "C", "Nome Veículo" , 25 )
    oModel:AddColumn( "T9_PLACA",   "C", "Placa"        , 8 )
    oModel:AddColumn( "TS1_DOCTO",  "C", "Documento"    , 15 )
    oModel:AddColumn( "E2_PREFIXO", "C", "Prefixo"      , 3 )
    oModel:AddColumn( "E2_NUM",     "C", "Título"       , TamSX3("E2_NUM")[1] ) // Adicionando o numero do titulo para o email
    oModel:AddColumn( "E2_PARCELA", "C", "Par."         , 3 )
    oModel:AddColumn( "E2_NATUREZ", "C", "Natureza"     , 10)
    oModel:AddColumn( "E2_VENCTO",  "D", "Vencimento"   , 8  )
    oModel:AddColumn( "E2_VALOR",   "N", "Valor Título" , 12, 2 )
    oModel:AddColumn( "E2_SALDO",   "N", "Saldo Título" , 12, 2 )
    oModel:AddColumn( "TS1_VALPAG", "N", "Valor Pago"   , 12, 2 )
    oModel:AddColumn( "E2_FORNECE", "C", "Fornecedor"   , 6  )
    oModel:AddColumn( "A2_NOME",    "C", "Nome Forn."   , 25 )
    oModel:AddColumn( "E2_CCD",     "C", "C. Custo"     , TamSX3("E2_CCD")[1] )
    oModel:AddColumn( "CTT_DESC01", "C", "Desc. CC"     , 20 )
    oModel:AddColumn( "RECNO_SE2",  "N", "RECNO SE2"    , 15, 0 )

    cQuery := " SELECT                                                                                              "
    cQuery += "     TS1.TS1_CODBEM, T9.T9_NOME, TS1.TS1_DOCTO, TS1.TS1_VALPAG, T9.T9_PLACA,                           "
    cQuery += "     SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_NATUREZ, SE2.E2_PARCELA, SE2.E2_VENCTO, SE2.E2_VALOR, SE2.E2_FORNECE, "
    cQuery += "     A2.A2_NOME, SE2.E2_CCD, CTT.CTT_DESC01, SE2.E2_SALDO,                                             "
    cQuery += "     SE2.R_E_C_N_O_ AS RECNO_SE2                                                                      "
    cQuery += " FROM " + RetSqlName("TS1") + " TS1                                                                  "
    cQuery += " JOIN " + RetSqlName("SE2") + " SE2 ON ( SE2.E2_FILIAL = TS1.TS1_FILIAL AND                           "
    cQuery += "                                      SE2.E2_PREFIXO = TS1.TS1_PREFIX AND                           "
    cQuery += "                                      SE2.E2_NUM = TS1.TS1_NUMSE2 AND                               "
    cQuery += "                                      SE2.E2_TIPO = TS1.TS1_TIPO AND                                "
    cQuery += "                                      SE2.E2_FORNECE = TS1.TS1_FORNEC AND                           "
    cQuery += "                                      SE2.E2_LOJA = TS1.TS1_LOJA AND                                "
    cQuery += "                                      SE2.D_E_L_E_T_ = '' )                                         "
    cQuery += " LEFT JOIN " + RetSqlName("ST9") + " T9 ON ( T9.T9_CODBEM = TS1.TS1_CODBEM AND T9.D_E_L_E_T_ = '' AND T9.T9_FILIAL = '" + xFilial("ST9") + "' )"
    cQuery += " LEFT JOIN " + RetSqlName("SA2") + " A2 ON ( A2.A2_COD = SE2.E2_FORNECE AND A2.A2_LOJA = SE2.E2_LOJA AND A2.D_E_L_E_T_ = '' AND A2.A2_FILIAL = '" + FWxFilial("SA2") + "' )"
    cQuery += " LEFT JOIN " + RetSqlName("CTT") + " CTT ON ( CTT.CTT_CUSTO = SE2.E2_CCD AND CTT.D_E_L_E_T_ = '' AND CTT.CTT_FILIAL = '" + xFilial("CTT") + "' )"
    cQuery += " WHERE                                                                                               "
    cQuery += "     TS1.TS1_FILIAL = '" + xFilial("TS1") + "' AND                                                   "
    cQuery += "     TS1.D_E_L_E_T_ = '' AND                                                                         "
    cQuery += "     SE2.E2_SALDO > 0                                                                                "

    oModel:SetQuery( cQuery )
    oModel:SetPrimaryKey( {"RECNO_SE2"} )

Return

Static Function VIEWDEF( oTReport )

    Local oView  := oTReport:GetView()
    Local oModel := oTReport:GetModel()

    oView:CreateHorizontalBox( "BOX_TOP", 100 )
    oView:AddGrid( "GRID_DOCS", "BOX_TOP", oModel,, .T., .T.,, 100 )

    oTReport:AddToolBarAction( "Alterar C. Custo", { || oTReport:GetController():Execute("ALTERAR_CC") } , "fluigicon-financial" )

    oView:GetGrid():SetColumnVisible("RECNO_SE2", .F.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CONTROLLERDEF
@description Define o Controlador (Ações do Usuário)
/*/
//-------------------------------------------------------------------
Static Function CONTROLLERDEF( oTReport )

    Local oController := oTReport:GetController()

    @ oController:AddUserAction( "ALTERAR_CC" )
    Method Execute( oAction ) Class TReportController
        Local oModel      := Self:GetModel()
        Local aLinhasSel  := oModel:GetSelection()
        Local cNovoCC     := Space( TamSX3("E2_CCD")[1] )
        Local nI          := 0
        Local nRecnoSE2   := 0
        Local aDadosEmail := {} //-- Array para armazenar os dados para o e-mail
        Local cOldCC      := ""

        If Len(aLinhasSel) == 0
            Help(,, "Atenção",, "Nenhum título foi selecionado para alteração.",, 1, 0 )
            Return
        Endif

        @ 0,0 FWGetCell oNovoCC Title "Informe o NOVO Centro de Custo" Message "Pressione F3 para consultar" Valid { |o| FWValidCtt(o) }
        If LastKey() == 27
            Return
        Endif

        cNovoCC := oNovoCC:GetResult()

        If MsgYesNo("Confirma a alteração do Centro de Custo para '" + cNovoCC + "' para os " + cValToChar(Len(aLinhasSel)) + " título(s) selecionado(s)?", "Confirmação")

            BeginTrans()
            For nI := 1 To Len(aLinhasSel)
                nRecnoSE2 := oModel:GetValue( "RECNO_SE2", aLinhasSel[nI] )

                If nRecnoSE2 > 0
                    //-- Coleta dados para o e-mail ANTES de alterar o registro
                    dbSelectArea("SE2")
                    dbGoTo(nRecnoSE2)
                    cOldCC := SE2->E2_CCD

                    AAdd(aDadosEmail, {;
                        oModel:GetValue("TS1_CODBEM", aLinhasSel[nI]),;
                        oModel:GetValue("T9_PLACA"  , aLinhasSel[nI]),;
                        oModel:GetValue("TS1_DOCTO" , aLinhasSel[nI]),;
                        oModel:GetValue("E2_PREFIXO", aLinhasSel[nI]),;
                        oModel:GetValue("E2_NUM"    , aLinhasSel[nI]),;
                        oModel:GetValue("E2_PARCELA", aLinhasSel[nI]),;
                        oModel:GetValue("E2_VENCTO" , aLinhasSel[nI]),;
                        oModel:GetValue("E2_VALOR"  , aLinhasSel[nI]),;
                        cOldCC,;
                        cNovoCC})

                    //-- Efetua a alteração
                    RecLock( "SE2", .F. )
                    dbSelectArea("SE2")
                    dbGoTo(nRecnoSE2)
                    SE2->E2_CCD := cNovoCC
                    MsUnlock()
                Endif
            Next nI
            EndTrans()

            //-- Envia o e-mail de notificação se houver dados coletados
            If Len(aDadosEmail) > 0
                EnviaEmailAlteracaoCC(aDadosEmail)
            Endif

            oModel:Refresh()
            MsgInfo("Centro(s) de Custo alterado(s) com sucesso!", cTitulo)
        Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} EnviaEmailAlteracaoCC
@description Monta e envia o e-mail notificando a alteração de C.Custo.
@param       aAlteracoes, Array com os dados dos títulos alterados.
@return      Nil
/*/
//-------------------------------------------------------------------
Static Function EnviaEmailAlteracaoCC(aAlteracoes)

    Local xAssunto  := "Alteração de Centro de Custo - Documentos Obrigatórios"
    Local cTitulo   := "Notificação de Alteração de Centro de Custo"
    Local xHTM		:= ""
    Local nI        := 0

    //-- Utiliza o mesmo parâmetro da rotina FECHAMES para centralizar os destinatários
    Local xEmail	:= GetMV("MB_FCHAMES",,"seu_email@dominio.com.br")

    //-- Montagem do corpo do e-mail em HTML
    xHTM := '<HTML><BODY style="font-family: Verdana, sans-serif; font-size: 10pt;">'
    xHTM += '<p><b><font SIZE=3>' + SM0->M0_NOMECOM + '</b></p>'
    xHTM += '<hr>'
    xHTM += '<p><b><font SIZE=3>' + cTitulo + '</b></p>'
    xHTM += '<hr>'
    xHTM += '<p>Data: ' + dtoc(date()) + ' | Hora: ' + time() + '</p>'
    xHTM += '<p>O(s) centro(s) de custo do(s) título(s) abaixo foram alterados por: <b>' + AllTrim(cUserName) + '</b></p>'
    xHTM += '<br>'

    //-- Tabela com os detalhes da alteração
    xHTM += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; font-size: 9pt;">'
    xHTM += '<tr bgcolor="#f2f2f2">'
    xHTM += '<th>Veículo</th>'
    xHTM += '<th>Placa</th>'
    xHTM += '<th>Documento</th>'
    xHTM += '<th>Título</th>'
    xHTM += '<th>Vencimento</th>'
    xHTM += '<th>Valor</th>'
    xHTM += '<th>C.Custo Antigo</th>'
    xHTM += '<th>C.Custo Novo</th>'
    xHTM += '</tr>'

    For nI := 1 to Len(aAlteracoes)
        xHTM += '<tr>'
        xHTM += '<td>' + aAlteracoes[nI][1] + '</td>' // Veículo
        xHTM += '<td>' + aAlteracoes[nI][2] + '</td>' // Placa
        xHTM += '<td>' + aAlteracoes[nI][3] + '</td>' // Documento
        xHTM += '<td>' + aAlteracoes[nI][4] + '/' + aAlteracoes[nI][5] + '-' + aAlteracoes[nI][6] + '</td>' // Prefixo/Num-Parc
        xHTM += '<td align="center">' + DtoC(aAlteracoes[nI][7]) + '</td>' // Vencimento
        xHTM += '<td align="right">' + Transform(aAlteracoes[nI][8], "@E 999,999,999.99") + '</td>' // Valor
        xHTM += '<td align="center">' + aAlteracoes[nI][9] + '</td>' // CC Antigo
        xHTM += '<td align="center" style="background-color:#d4edda;"><b>' + aAlteracoes[nI][10] + '</b></td>' // CC Novo
        xHTM += '</tr>'
    Next nI

    xHTM += '</table>'
    xHTM += '</BODY></HTML>'

    //-- Dispara o envio do e-mail em background
    Processa({ || u_EnvMail(xEmail, "", "", xAssunto, {}, xHTM, .T.) }, "Enviando e-mail de notificação...")

Return
