#Include 'Protheus.ch'

User Function MA161BAR()
    Local aItens    := Paramixb[1]
    Local oBrowse1  := Paramixb[2]
    Local aButtons  := {}

    aadd(aButtons,{"PREV", {|| U_MT161BAR(aItens,oBrowse1) },"MPRECO" ,"Menor Preço (F10)"})
    aadd(aButtons,{"NEXT", {|| u_vacomr05(SC8->C8_NUM) }    ,"MCOMR05","Exporta Excel (F11)"})

    SetKey( VK_F10, {|| U_MT161BAR(aItens,oBrowse1) } )
    SetKey( VK_F11, {|| u_vacomr05(SC8->C8_NUM) } )

    //AAdd(aButtons,{"Exporta Excel", "u_vacomr05", 0 , 4, 0, .f.})
Return (aButtons )

User Function MT161BAR(aItens,oBrowse1)
    Local aArea := GetArea()
    Local oSize
    //Objetos da Janela
    Private oDlgPvt
    Private oMsGetSBM
    Private oBtnFech
    Private aHeadSC8        := {}
    Private aColsSC8        := {}
    Private nTotCot         := 0 
    //Tamanho da Janela
    Private    nJanLarg     := 1500
    Private    nJanAltu     := 650
    //Fontes
    Private    cFontUti     := "Tahoma"
    Private    oFontAno     := TFont():New(cFontUti,,-38)
    Private    oFontSub     := TFont():New(cFontUti,,-20)
    Private    oFontSubN    := TFont():New(cFontUti,,-20,,.T.)
    Private    oFontBtn     := TFont():New(cFontUti,,-14)

    //Criando o cabeçalho da Grid
    //              Título               Campo        Máscara                        Tamanho                   Decimal              Valid Usado  Tipo F3 Combo
    //aAdd(aHeadSC8, {"Filial"            ,"C8_FILIAL"    , X3PICTURE("C8_FILIAL") ,  TamSX3("C8_FILIAL")[01]  , TamSX3("C8_FILIAL")[01]  , ""    , ".T.", "C", "",    ""} )
    aAdd(aHeadSC8, {"Num Cotacao"       ,"C8_NUM"       , X3PICTURE("C8_NUM")    , 06                     , TamSX3("C8_NUM")[02]    , "", ".T.", "C", "", ""} )
    aAdd(aHeadSC8, {"Item"              ,"C8_ITEM"      , X3PICTURE("C8_ITEM")   , TamSX3("C8_ITEM")[01]  , TamSX3("C8_ITEM")[02]   , "", ".T.", "C", "", ""} )
    aAdd(aHeadSC8, {"Produto"           ,"C8_PRODUTO"   , X3PICTURE("C8_PRODUTO"), 06                     , TamSX3("C8_PRODUTO")[02], "", ".T.", "C", "", ""} )
    aAdd(aHeadSC8, {"Descrição"         ,"B1_DESC"      , X3PICTURE("B1_DESC")   , 40                     , TamSX3("B1_DESC")[02]   , "", ".T.", "C", "", ""} )
    aAdd(aHeadSC8, {"Quantidade"        ,"C8_QUANT"     , X3PICTURE("C8_QUANT")  , TamSX3("C8_QUANT")[01] , TamSX3("C8_QUANT")[02]  , "", ".T.", "N", "", ""} )
    aAdd(aHeadSC8, {"Preco"             ,"C8_PRECO"     , X3PICTURE("C8_PRECO")  , TamSX3("C8_PRECO")[01] , 02                      , "", ".T.", "N", "", ""} )
    aAdd(aHeadSC8, {"Total"             ,"TOTAL"        , X3PICTURE("C8_PRECO")  , TamSX3("C8_PRECO")[01] , 02                      , "", ".T.", "N", "", ""} )
    aAdd(aHeadSC8, {"Fornecedor"        ,"C8_FORNECE"   , X3PICTURE("C8_FORNECE"), 06                     , TamSX3("C8_FORNECE")[02], "", ".T.", "C", "", ""} )
    aAdd(aHeadSC8, {"Nome"              ,"C8_FORNOME"   , X3PICTURE("C8_FORNOME"), 50                     , TamSX3("C8_FORNOME")[02], "", ".T.", "C", "", ""} )
    aAdd(aHeadSC8, {"Data Prevista"     ,"C8_DATPRF"    , X3PICTURE("C8_DATPRF") , TamSX3("C8_DATPRF")[01], TamSX3("C8_DATPRF")[02] , "", ".T.", "D", "", ""} )
    aAdd(aHeadSC8, {"Prazo"             ,"C8_PRAZO"     , X3PICTURE("C8_PRAZO")  , TamSX3("C8_PRAZO")[01] , TamSX3("C8_PRAZO")[02]  , "", ".T.", "D", "", ""} )
    aAdd(aHeadSC8, {"Municipio"         ,"A2_MUN"       , X3PICTURE("A2_MUN")    , TamSX3("A2_MUN")[01]   , TamSX3("A2_MUN")[02]    , "", ".T.", "C", "", ""} )
 
    Processa({|| fCarAcols()}, "Processando")
 
    oSize := FwDefSize():New(.F.) 
    oSize:lLateral     := .F.  // Calculo vertical
    oSize:AddObject( "FOLDER",100, 100, .T., .T. ) // Adiciona Folder 
    oSize:Process()
    //Criação da tela com os dados que serão informados

    DEFINE MSDIALOG oDlgPvt TITLE "Grupos de Produto" FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] COLORS 0, 16777215 PIXEL
        //Labels gerais
        @ 004, 003 SAY "V@"                           SIZE 200, 030 FONT oFontAno  OF oDlgPvt COLORS RGB(0,100,0) PIXEL
        @ 004, 050 SAY "Listagem de"                  SIZE 200, 030 FONT oFontSub  OF oDlgPvt COLORS RGB(152,251,152) PIXEL
        @ 014, 050 SAY "Menor preço por Fornecedor"   SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(0,100,0) PIXEL
        @ 014,(oSize:aWindSize[4]/2-001)-(0200*01) SAY "Total: " + TRANSFORM( nTotCot, "@E 999,999.99")   SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(0,100,0) PIXEL
         
        //Botões
        @ 006, (oSize:aWindSize[4]/2-001)-(0067*01) BUTTON oBtnFech  PROMPT "Fechar"        SIZE 065, 018 OF oDlgPvt ACTION (oDlgPvt:End())                               FONT oFontBtn PIXEL
         
        //Grid dos grupos
        oMsGetSBM := MsNewGetDados():New(    029,;                //nTop      - Linha Inicial
                                            003,;                //nLeft     - Coluna Inicial
                                            (oSize:aWindSize[3]/2)-3,;     //nBottom   - Linha Final
                                            (oSize:aWindSize[4]/2)-3,;     //nRight    - Coluna Final
                                            ,;                   //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
                                            "AllwaysTrue()",;    //cLinhaOk  - Validação da linha
                                            ,;                   //cTudoOk   - Validação de todas as linhas
                                            "",;                 //cIniCpos  - Função para inicialização de campos
                                            {},;                 //aAlter    - Colunas que podem ser alteradas
                                            ,;                   //nFreeze   - Número da coluna que será congelada
                                            9999,;               //nMax      - Máximo de Linhas
                                            ,;                   //cFieldOK  - Validação da coluna
                                            ,;                   //cSuperDel - Validação ao apertar '+'
                                            ,;                   //cDelOk    - Validação na exclusão da linha
                                            oDlgPvt,;            //oWnd      - Janela que é a dona da grid
                                            aHeadSC8,;           //aHeader   - Cabeçalho da Grid
                                            aColsSC8)            //aCols     - Dados da Grid


        //Desativa as manipulações
        oMsGetSBM:lActive := .F.
         
    ACTIVATE MSDIALOG oDlgPvt CENTERED
     
    RestArea(aArea)
Return .T.
/*
Static Function Backup(aItens,oBrowse1)
    Local aArea := GetArea()
    //Objetos da Janela
    Private oDlgPvt
    Private oMsGetSBM
    Private aHeadSC8 := {}
    Private aColsSC8 := {}
    Private oBtnFech
    Private nTotCot  := 0 
    //Tamanho da Janela
    Private    nJanLarg    := 1500
    Private    nJanAltu    := 650
    //Fontes
    Private    cFontUti   := "Tahoma"
    Private    oFontAno   := TFont():New(cFontUti,,-38)
    Private    oFontSub   := TFont():New(cFontUti,,-20)
    Private    oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
    Private    oFontBtn   := TFont():New(cFontUti,,-14)
     
    //Criando o cabeçalho da Grid
    //              Título               Campo        Máscara                        Tamanho                   Decimal              Valid Usado  Tipo F3 Combo
    //aAdd(aHeadSC8, {"Filial"            ,"C8_FILIAL"    , X3PICTURE("C8_FILIAL") ,  TamSX3("C8_FILIAL")[01]  , TamSX3("C8_FILIAL")[01]  , ""    , ".T.", "C", "",    ""} )
    aAdd(aHeadSC8, {"Num Cotacao"       ,"C8_NUM"       , X3PICTURE("C8_NUM")    , 06                     , TamSX3("C8_NUM")[02]    , "", ".T.", "C", "", ""} )
    aAdd(aHeadSC8, {"Item"              ,"C8_ITEM"      , X3PICTURE("C8_ITEM")   , TamSX3("C8_ITEM")[01]  , TamSX3("C8_ITEM")[02]   , "", ".T.", "C", "", ""} )
    aAdd(aHeadSC8, {"Produto"           ,"C8_PRODUTO"   , X3PICTURE("C8_PRODUTO"), 06                     , TamSX3("C8_PRODUTO")[02], "", ".T.", "C", "", ""} )
    aAdd(aHeadSC8, {"Descrição"         ,"B1_DESC"      , X3PICTURE("B1_DESC")   , 40                     , TamSX3("B1_DESC")[02]   , "", ".T.", "C", "", ""} )
    aAdd(aHeadSC8, {"Quantidade"        ,"C8_QUANT"     , X3PICTURE("C8_QUANT")  , TamSX3("C8_QUANT")[01] , TamSX3("C8_QUANT")[02]  , "", ".T.", "N", "", ""} )
    aAdd(aHeadSC8, {"Preco"             ,"C8_PRECO"     , X3PICTURE("C8_PRECO")  , TamSX3("C8_PRECO")[01] , 02                      , "", ".T.", "N", "", ""} )
    aAdd(aHeadSC8, {"Total"             ,"TOTAL"        , X3PICTURE("C8_PRECO")  , TamSX3("C8_PRECO")[01] , 02                      , "", ".T.", "N", "", ""} )
    aAdd(aHeadSC8, {"Fornecedor"        ,"C8_FORNECE"   , X3PICTURE("C8_FORNECE"), 06                     , TamSX3("C8_FORNECE")[02], "", ".T.", "C", "", ""} )
    aAdd(aHeadSC8, {"Nome"              ,"C8_FORNOME"   , X3PICTURE("C8_FORNOME"), 50                     , TamSX3("C8_FORNOME")[02], "", ".T.", "C", "", ""} )
    aAdd(aHeadSC8, {"Data Prevista"     ,"C8_DATPRF"    , X3PICTURE("C8_DATPRF") , TamSX3("C8_DATPRF")[01], TamSX3("C8_DATPRF")[02] , "", ".T.", "D", "", ""} )
    aAdd(aHeadSC8, {"Prazo"             ,"C8_PRAZO"     , X3PICTURE("C8_PRAZO")  , TamSX3("C8_PRAZO")[01] , TamSX3("C8_PRAZO")[02]  , "", ".T.", "D", "", ""} )
    aAdd(aHeadSC8, {"Municipio"         ,"A2_MUN"       , X3PICTURE("A2_MUN")    , TamSX3("A2_MUN")[01]   , TamSX3("A2_MUN")[02]    , "", ".T.", "C", "", ""} )
 
    Processa({|| fCarAcols()}, "Processando")
 
    //Criação da tela com os dados que serão informados
    DEFINE MSDIALOG oDlgPvt TITLE "Grupos de Produto" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Labels gerais
        @ 004, 003 SAY "V@"                     SIZE 200, 030 FONT oFontAno  OF oDlgPvt COLORS RGB(0,100,0) PIXEL
        @ 004, 050 SAY "Listagem de"            SIZE 200, 030 FONT oFontSub  OF oDlgPvt COLORS RGB(152,251,152) PIXEL
        @ 014, 050 SAY "Preço por Fornecedor"   SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(0,100,0) PIXEL
        @ 014,(nJanLarg/2-001)-(0200*01) SAY "Total: " + TRANSFORM( nTotCot, "@E 999,999.99")   SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(0,100,0) PIXEL
         
        //Botões
        @ 006, (nJanLarg/2-001)-(0067*01) BUTTON oBtnFech  PROMPT "Fechar"        SIZE 065, 018 OF oDlgPvt ACTION (oDlgPvt:End())                               FONT oFontBtn PIXEL
         
        //Grid dos grupos
        oMsGetSBM := MsNewGetDados():New(   029,;                //nTop      - Linha Inicial
                                            003,;                //nLeft     - Coluna Inicial
                                            (nJanAltu/2)-3,;     //nBottom   - Linha Final
                                            (nJanLarg/2)-3,;     //nRight    - Coluna Final
                                            ,;                   //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
                                            "AllwaysTrue()",;    //cLinhaOk  - Validação da linha
                                            ,;                   //cTudoOk   - Validação de todas as linhas
                                            "",;                 //cIniCpos  - Função para inicialização de campos
                                            {},;                 //aAlter    - Colunas que podem ser alteradas
                                            ,;                   //nFreeze   - Número da coluna que será congelada
                                            9999,;               //nMax      - Máximo de Linhas
                                            ,;                   //cFieldOK  - Validação da coluna
                                            ,;                   //cSuperDel - Validação ao apertar '+'
                                            ,;                   //cDelOk    - Validação na exclusão da linha
                                            oDlgPvt,;            //oWnd      - Janela que é a dona da grid
                                            aHeadSC8,;           //aHeader   - Cabeçalho da Grid
                                            aColsSC8)            //aCols     - Dados da Grid


        //Desativa as manipulações
        oMsGetSBM:lActive := .F.
         
    ACTIVATE MSDIALOG oDlgPvt CENTERED
     
    RestArea(aArea)
Return .T.
*/
/*------------------------------------------------*
 | Func.: fCarAcols                               |
 | Desc.: Função que carrega o aCols              |
 *------------------------------------------------*/
 
Static Function fCarAcols()
    Local aArea  := GetArea()
    Local cQry   := ""
    Local nAtual := 0
    Local nTotal := 0
     
    //Seleciona dados do documento de entrada
    cQry := " WITH DADOS AS ( " + CRLF 
    cQry += " select C8_FILIAL, C8_NUM, C8_ITEM, C8_PRODUTO, B1_DESC, C8_QUANT, MIN(C8_PRECO) C8_PRECO , C8_QUANT * MIN(C8_PRECO)TOTAL " + CRLF 
    cQry += "   from "+RetSqlName("SC8")+" SC8 " + CRLF 
    cQry += "   Join "+RetSqlName("SB1")+" SB1 ON  " + CRLF 
    cQry += "        SB1.B1_COD = C8_PRODUTO  " + CRLF 
    cQry += "    AND SB1.D_E_L_E_T_ = ' '  " + CRLF 
    cQry += "   WHERE C8_FILIAL = '"+SC8->C8_FILIAL+"'  " + CRLF 
    cQry += "     AND C8_NUM = '"+SC8->C8_NUM+"'  " + CRLF 
    cQry += "     AND C8_PRECO > 0 " + CRLF 
    cQry += "     AND SC8.D_E_L_E_T_ = ' '  " + CRLF 
    cQry += " --ORDER BY C8_FILIAL, C8_NUM, C8_FORNECE, C8_ITEM " + CRLF 
    cQry += " GROUP BY C8_FILIAL, C8_NUM, C8_ITEM, C8_PRODUTO, B1_DESC , C8_PRODUTO, C8_QUANT " + CRLF 
    cQry += " )  " + CRLF 
    cQry += "  SELECT D.*, C8.C8_FORNECE, C8.C8_FORNOME, C8.C8_DATPRF, C8_PRAZO, SA2.A2_MUN + ' - ' + SA2.A2_EST A2_MUN " + CRLF 
    cQry += "    FROM DADOS D " + CRLF 
    cQry += "    JOIN "+RetSqlName("SC8")+" C8 ON  " + CRLF 
    cQry += "         D.C8_FILIAL = C8.C8_FILIAL " + CRLF 
    cQry += "     AND D.C8_NUM = C8.C8_NUM " + CRLF 
    cQry += " 	AND D.C8_ITEM   = C8.C8_ITEM " + CRLF 
    cQry += " 	AND D.C8_PRODUTO = C8.C8_PRODUTO " + CRLF 
    cQry += " 	AND D.C8_PRECO = C8.C8_PRECO " + CRLF 
    cQry += " 	AND C8.D_E_L_E_T_ = ' '  " + CRLF 
    cQry += "    JOIN "+RetSqlName("SA2")+" SA2 ON  " + CRLF 
    cQry += "         SA2.A2_COD = C8.C8_FORNECE " + CRLF 
    cQry += " 	AND SA2.A2_LOJA = C8_LOJA " + CRLF 
    cQry += "     AND SA2.D_E_L_E_T_ = ' '  " + CRLF 

    If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador,ioliveira'
        MemoWrite("C:\totvs_relatorios\"+"MT161BAR.sql" , cQry)
    EndIf

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, cQry ),"QRY_SC8",.F.,.F.) 

    //Setando o tamanho da régua
    Count To nTotal
    ProcRegua(nTotal)
     
    //Enquanto houver dados
    QRY_SC8->(DbGoTop())
    While ! QRY_SC8->(EoF())
     
        //Atualizar régua de processamento
        nAtual++
        IncProc("Adicionando " + Alltrim(QRY_SC8->C8_PRODUTO) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
        nTotCot += QRY_SC8->TOTAL
        //Adiciona o item no aCols
        aAdd(aColsSC8, { ;
            QRY_SC8->C8_NUM,;
            QRY_SC8->C8_ITEM,;
            QRY_SC8->C8_PRODUTO,;
            QRY_SC8->B1_DESC,;
            QRY_SC8->C8_QUANT,;
            QRY_SC8->C8_PRECO,;
            QRY_SC8->TOTAL,;
            QRY_SC8->C8_FORNECE,;
            QRY_SC8->C8_FORNOME,;
            sToD(QRY_SC8->C8_DATPRF),;
            QRY_SC8->C8_PRAZO,;
            STRTRAN(AllTrim(QRY_SC8->A2_MUN),"  ",""),;
            .F.;
        })
         
        QRY_SC8->(DbSkip())
    EndDo
    QRY_SC8->(DbCloseArea())
     
    RestArea(aArea)
Return

