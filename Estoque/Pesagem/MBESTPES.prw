#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#include "TOPCONN.CH"
#include "RWMAKE.CH"
#Include "TryException.ch"

#DEFINE oFBar      TFont():New( "Courier New"/*cName*/, /*uPar2*/, -04/*nHeight*/, /*uPar4*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFTitLabel TFont():New( "Courier New"/*cName*/, /*uPar2*/, -16/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFLabel    TFont():New( "Courier New"/*cName*/, /*uPar2*/, -08/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFInfo     TFont():New( "Arial"      /*cName*/, /*uPar2*/, -12/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFInfoOBS  TFont():New( "Arial"      /*cName*/, /*uPar2*/, -09/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFontRecor TFont():New( "Tahoma"     /*cName*/, /*uPar2*/, -07/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )

#DEFINE CSSLABEL "QLabel {" +;
    "font-size:12px;" +;
    "font: 12px Arial;" +;
    "}"

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  MBESTPES 	            	          	            	                  |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  23.09.2020                   	          	            	              |
 | Desc:  Esta rotina irá gerar as telas para o controle de pesagem;              |
 |        Estará presente nesta rotina a impressao do ticket de pesagem;          |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
User Function MBESTPES()

    // Private oMBSaveLog	:= MBSaveLog():New() as object
    Private cF3CodCFPes  := ""
    Private cF3LojCFPes  := ""
    Private cF3NomCFPes  := ""
    Private cPlacaTGet   := Iif(ValType(cPlacaTGet)=="U", CriaVar( 'DA3_PLACA' , .F.), cPlacaTGet )
    Private nQualPesagem := 0

    Private cCadastro    := "Cadastro de Peso do Balanção"
    Private cAlias       := "ZPB"
    Private aRotina      := MenuDef()
    /*
    Private aGets       := {}
    Private aTela       := {}
    */
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias( cAlias )
    oBrowse:SetMenuDef("MBESTPES")
    oBrowse:SetDescription( cCadastro )

    oBrowse:AddLegend( "ZPB->ZPB_STATUS <> 'F'", "GREEN" , "Aberto" )
    oBrowse:AddLegend( "ZPB->ZPB_STATUS == 'F'", "RED"   , "Finalizada" )

    oBrowse:Activate()

Return nil


Static Function MenuDef()
    Local aRotina := {}
    //aAdd( aRotina, { 'Visualizar'           , 'U_COMM12VA', 0, 2, 0, nil  } )
    aAdd( aRotina, { 'Pesquisar'            , 'AxPesqui'      , 0, 1, 0 } )
    aAdd( aRotina, { 'Visualizar'           , 'AxVisual'      , 0, 2, 0 } )
    aAdd( aRotina, { 'Pesagens'         	, 'U_Tela1Pesagem', 0, 3, 0 } ) // aAdd( aRotina, { 'Incluir'              , 'AxInclui'      , 0, 3, 0, nil  } )
    aAdd( aRotina, { 'Alterar'              , 'U_Tela2Pesagem', 0, 4, 0 } ) // aAdd( aRotina, { 'Alterar'              , 'AxAltera'      , 0, 4, 0 } )
    aAdd( aRotina, { 'Excluir'              , 'AxDeleta'      , 0, 5, 0 } )
    aAdd( aRotina, { 'Incluir'              , 'AxInclui'      , 0, 6, 0 } )
    aAdd( aRotina, { 'Imprimir Ticket'      , 'StaticCall(MBESTPES, mbPesoPrint)', 0, 7, 0 } )
    aAdd( aRotina, { 'Legenda'         		, 'U_LegPesagem', 0, 9, 0 } )
Return aRotina

user Function LegPesagem()
    local aLegenda := {}

    //Monta as cores
    AAdd(aLegenda, {"BR_VERDE"		, "Aberto"  })
    AAdd(aLegenda, {"BR_VERMELHO"	, "Pesagem Finalizada"})

    BrwLegenda("Transferências", "Procedencia", aLegenda, 30)

Return nil

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_Tela1Pesagem()          		              |
 | Func:  Tela1Pesagem 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  23.09.2020                   	          	            	              |
 | Desc:  Captura inicial, neste momento sera feito manualmente;                  |
 |        projeto futuro é fazer a leitura automatica via RFID;                   |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
User Function Tela1Pesagem(cAlias, nReg, nOpc)
    Local nOpcA := 0
    Local oDlg1 := nil
    Local nDlgLinFim, nDlgColFim
    Local nTS1Row   , nTS1Col, nTSWidth
    Local nTG1Row   , nTG1Col, nTGWidth
    Local nTBRow    , nTBCol , nTBWidth

    Private __cBorderMB := ""
    // Private __cCorFundo := ""

    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))

    DbSelectArea("DA4")
    DA4->(DbSetOrder(1))

    DEFINE DIALOG oDlg1 TITLE OemToAnsi("Definição do Caminhão") FROM 0,0 TO nLinFim:=470, nColFim:=622 PIXEL;
        STYLE nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )  // tirar o X da tela | tirar o botao X da tela |

    oPanel := tPanel():New( 01, 01, /*cText*/, oDlg1,,,, /*CLR_YELLOW*/, /*CLR_BLUE*/, nDlgLinFim, nDlgColFim, /* lLowered */, .T. /* lRaised */)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    oPanel:SetCss("QLabel {" + (__cCorFundo:=" background: #e6ffe6; " ) + "}")

    oSay     := TSay():New(nTS1Row:=35, nTS1Col:=115, {|| "PLACA"}, oPanel, /*cPicture*/, /*oFont*/, , , , .T., , , nTSWidth:=110, 60)
    oSay:SetCss("QLabel {" + __cCorFundo + "color: #00ff00; font-size: 36pt}")

    /*  https://tdn.totvs.com/display/tec/Construtor+TGet%3ANew#
    TGet():New( [ nRow ], [ nCol ], [ bSetGet ], [ oWnd ], [ nWidth ], [ nHeight ], [ cPict ], [ bValid ], [ nClrFore ], [ nClrBack ], [ oFont ], [ uParam12 ], [ uParam13 ], [ lPixel ], [ uParam15 ], [ uParam16 ], [ bWhen ], [ uParam18 ], [ uParam19 ], [ bChange ], [ lReadOnly ], [ lPassword ], [ uParam23 ], [ cReadVar ], [ uParam25 ], [ uParam26 ], [ uParam27 ], [ lHasButton ], [ lNoButton ], [ uParam30 ], [ cLabelText ], [ nLabelPos ], [ oLabelFont ], [ nLabelColor ], [ cPlaceHold ], [ lPicturePriority ], [ lFocSel ] )  */
    oTGet := TGet():New( nTG1Row:=85 /*nRow*/, nTG1Col:=40/*nCol*/, {|u|If(PCount()>0,cPlacaTGet:=u,cPlacaTGet)} /*bSetGet*/, oPanel/*oWnd*/,;
        nTGWidth:=240/*nWidth*/, /*nHeight*/ 50, "@! AAA-9N99"/*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/,/*lPixel*/.T., /*uParam15*/, /*uParam16*/, /*bWhen*/, /*uParam18*/, /*uParam19*/, /*bChange*/, .F. /*lReadOnly*/, .F./*lPassword*/, /*uParam23*/,;
        "cPlacaTGet" /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, /*lHasButton*/,;
        /*lNoButton*/, /*uParam30*/, /*cLabelText*/, /*nLabelPos Indica a posição da label, sendo 1=Topo e 2=Esquerda*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/, /*lPicturePriority*/, /*lFocSel*/.F. )
    oTGet:SetCss("QLineEdit {" + __cCorFundo + "color: #000; font-weight: bold; font-size: 72pt;" + (__cBorderMB:=" border: 2px solid green; border-radius: 20px; ") + "}")

    // https://tdn.totvs.com/display/tec/TButton
    oT1_1Button := tButton():New(nTBRow:=170, nTBCol:=30, "CONFIRMAR (F10)", oPanel,;
        {|| nOpcA := 1,  U_Tela2Pesagem(cAlias, nReg, nOpc)/*, oDlg1:End()*/}, nTBWidth:=120, 40/*nHeight*/,,,, .T./*lPixel*/)
    oT1_1Button:SetCss("QPushButton { background: #2C2; color: #FFF; margin: 2px; font-weight: bold; font-size: 14pt; border-radius: 15px; }")

    oT1_2Button := tButton():New(nTBRow, nTBCol+nTBWidth+15, "SAIR (ESC)", oPanel,;
        {|| nOpcA := 1, oDlg1:End() }, nTBWidth, 40/*nHeight*/,,,, .T./*lPixel*/)
    oT1_2Button:SetCss(oT1_1Button:GetCss())

    SetKey( VK_F10, {|| U_Tela2Pesagem(cAlias, nReg, nOpc)/* , oDlg1:End() */ } )

    MBSaveLog():FULLWrite(, .F., "Carregado Tela 1")

    ACTIVATE DIALOG oDlg1 CENTERED // ON INIT EnchoiceBar(oDlg1,;
    //                     {|| nOpcA := 1, oDlg1:End()},;
    //                     {|| nOpcA := 0, oDlg1:End()} ) CENTERED
    If nOpcA == 0
        cPlacaTGet   := CriaVar( 'DA3_PLACA' , .F.)
        MBSaveLog():FULLWrite(, .F., cPlacaTGet)
        nQualPesagem := 0
        // Else
        //      Alert('[T1] CONFIRMAR')
    EndIf
Return nil
// Tela1Pesagem()


/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  Tela2Pesagem 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  30.10.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
User Function Tela2Pesagem(cAlias, nReg, nOpc)
    Local aArea          := GetArea()
    Local nOpcA          := 0
    Local oDlg2          := nil
    Local aSize          :={}, aObjects := {}, aInfo := {}, aPObjs := {}
    Local aMGetCpos      := {}
    Local _aMotorista    := {}

    Private oT2MGet      := nil
    Private aGets        := {}
    Private aTela        := {}

    Private _cNotaFiscal := CriaVar( 'D2_DOC', .F.)

    If IsInCallStack("U_TELA1PESAGEM")
        If (AllTrim(cPlacaTGet) == "-" .OR. Empty(cPlacaTGet))
            _cHTML := '<h3><span style="color: #00ff00;">Placa n&atilde;o informada</span></h3>'+;
                '<p>Esta opera&ccedil;&atilde;o ser&aacute; cancelada.</p>'

            MBSaveLog():FULLWrite(, .F., _cHTML)

            MsgInfo(_cHTML)
            return nil
        EndIf
    EndIf

    If nOpc == 3 // nao pode ter o nReg aqui ....
        If (nQualPesagem:=fDefinePessagem())>0
            (cAlias)->(DbGoTo(nReg := nQualPesagem))
            nOpc := 4
            INCLUI := .F.
            ALTERA := .T.
        Else
            nOpc := 3
            nReg := 0
            INCLUI := .T.
            ALTERA := .F.
        EndIf
    Else
        nQualPesagem := nReg
    EndIf

    RegToMemory( cAlias, nQualPesagem==0 /* nOpc == 3 */ )

    If (nQualPesagem==0)
        M->ZPB_PLACA := cPlacaTGet
        _aMotorista  := UltPesagemXPlaca(cPlacaTGet)
        If (!Empty(_aMotorista)) // preenchimento de campos automaticamente de acordo com a ultima pesagem do caminhao
            M->ZPB_CODMOT := _aMotorista[01, 01]
            M->ZPB_CPFMOT := _aMotorista[01, 02]
            M->ZPB_NOMMOT := _aMotorista[01, 03]
            M->ZPB_PRODUT := _aMotorista[01, 04]
            M->ZPB_DESC   := _aMotorista[01, 05]
            M->ZPB_CLIFOR := _aMotorista[01, 06]
            M->ZPB_CODFOR := _aMotorista[01, 07]
            M->ZPB_LOJFOR := _aMotorista[01, 08]
            M->ZPB_NOMFOR := _aMotorista[01, 09]
            M->ZPB_LOCAL  := _aMotorista[01, 10]
            M->ZPB_BAIA   := _aMotorista[01, 11]
            M->ZPB_OBSERV := _aMotorista[01, 12]
        EndIf
        // U_PegaPeso(.T.)
    EndIf

    aSize := MsAdvSize(.T.)
    aSize[5] := int(aSize[5]*0.63) // Direita
    aSize[6] := int(aSize[6]*0.785) // Embaixo

    AAdd( aObjects, { 100, 100, .T., .T., .F. } )
    AAdd( aObjects, { 100,  17, .T., .T., .F. } )
    aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
    aPObjs := MsObjSize(aInfo, aObjects, .T., .F.)

    oDlg2 := MsDialog():New( 0/*nTop*/, 0/*nLeft*/, aSize[6]+20/*nBottom*/, aSize[5]/*nRight*/,;
        OemToAnsi("Dados da Pesagem do Caminhão")/*cCaption*/,/*uParam6*/, /*uParam7*/, /*uParam8*/,;
        /* nOr(WS_VISIBLE,  WS_POPUP) *//*uParam9*/, /*nClrText*/, /*nClrBack*/,/*uParam12*/,;
    /*oWnd*/, .T./*lPixel*/, /*uParam15*/, /*uParam16*/, /*uParam17*/,.F./*lTransparent*/ )
    oDlg2:lEscClose := .T.
    // ficou definido a permissao de sair no ESC sem salvar

    __cCorFundo:=" background: #e6ffe6; "
    __cBorderMB:=" border: 2px solid green; border-radius: 20px; "
    o1Group := TGroup():New( nDist:=1/*nTop*/, nDist/*nLeft*/,;
        nG1Bottom:=aSize[6]*0.445 /*nBottAom*/, nG1Right:=aSize[5]*0.5 /*nRight*/,;
        /*cCaption*/, oDlg2/*oWnd*/, /*nClrText*/, /*nClrPane*/, .T./*lPixel*/, /*uParam10*/ )
    o1Group:SetCss("QGroupBox {" + __cCorFundo + __cBorderMB + "}")

    o1Panel := tPanel():New( 0, 0, /*cText*/, o1Group,,,, /*CLR_YELLOW*/, /*CLR_BLUE*/, 0, 0, /* lLowered */, .T. /* lRaised */)
    o1Panel:Align := CONTROL_ALIGN_ALLCLIENT
    o1Panel:SetCss("QLabel { border-style: none; }")

    _cCSS   := "QLineEdit {" + __cCorFundo + "color: #000; font-weight: bold; font-size: 24pt;" + __cBorderMB + "} "/* +; // TGet
        "QTextEdit {" + __cCorFundo + "color: #000; font-weight: bold; font-size: 24pt;" + __cBorderMB + "} " */
    AddCSSRule("MsmGet"   , _cCSS)
    AddCSSRule("TGet"     , "QLineEdit {" + __cCorFundo + "color: #000; font-weight: bold; font-size: 24pt;" + __cBorderMB + "}")
    AddCSSRule("TMultiGet", "QTextEdit {" + __cCorFundo + "color: #000; font-weight: bold; font-size: 24pt;" + __cBorderMB + "}")
    AddCSSRule("TSAY"     , CSSLABEL)
    aMGetCpos    := aPObjs[1]
    aMGetCpos[4] *= 0.6
    oT2MGet  := MsmGet():New( cAlias, nReg/*uPar2*/, iif(nQualPesagem==0, 3, 4)/*nOpc*/, /*uPar4*/, /*uPar5*/,;
        /*uPar6*/, /*aAcho*/, aMGetCpos /*aPos*/ , /*aCpos*/, /*nModelo*/, /*uPar11*/, /*uPar12*/, /*uPar13*/,;
        o1Panel/*oWnd*/, /*lF3*/, /*lMemoria*/, /*lColumn*/, /*caTela*/, /*lNoFolder*/, /*lProperty*/,;
        /*aField*/, /*aFolder*/, /*lCreate*/, .F./*lNoMDIStretch*/, /*uPar25*/ )
    oT2MGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT
    // xVarM := ClassMethArr( o1ZBCGDad , .T. ) // Magica
    // xVarD := ClassDataArr( o1ZBCGDad , .T. ) // Magica

    o2Group := TGroup():New( nG2Bottom:=nG1Bottom+nDist, nDist/*nLeft*/,;
        nG2Bottom+47/*nBottom*/, nG1Right/*nRight*/,;
        /*cCaption*/, oDlg2/*oWnd*/, /*nClrText*/, /*nClrPane*/, .T./*lPixel*/, /*uParam10*/ )
    o2Group:SetCss("QGroupBox {" + __cCorFundo + __cBorderMB + "}")

    o2Panel := tPanel():New( 0, 0, /*cText*/, o2Group,,,, /*CLR_YELLOW*/, /*CLR_BLUE*/, 0, 0, /* lLowered */, .T. /* lRaised */)
    o2Panel:Align := CONTROL_ALIGN_ALLCLIENT
    // o2Panel:SetCss("QLabel { background: #e6f7ff; }")
    o2Panel:SetCss("QLabel { border-style: none; }")

    // https://tdn.totvs.com/display/tec/TButton
    oBtCaptura := tButton():New(nTB1Row:=5, nTB1Col:=45, "CAPTURA PESO (F10)", o2Panel,;
        {|| U_PegaPeso(.T.) }, nTBWidth:=135, nB1Height:=35,,,, .T./*lPixel*/)
    oBtCaptura:SetCss("QPushButton { background: #2C2; color: #FFF; margin: 2px; font-weight: bold; font-size: 16pt;" + __cBorderMB + "}")

    oBtImprimir := tButton():New(nTB1Row, nTB2Col:=nTB1Col+(nTamCol:=120)+(nDisBot:=70), "IMPRIMIR (F11)", o2Panel,;
        {|| nOpcA := 1, Iif(ZADSalvar(), mbPesoPrint(), .T.) }, nTBWidth, nB1Height/*nHeight*/,,,, .T./*lPixel*/)
    oBtImprimir:SetCss( oBtCaptura:GetCss() )

    oBtSair := tButton():New(nTB1Row, nTB3Col:=nTB2Col+nTamCol+nDisBot, "SAIR (F4)", o2Panel,;
        {|| nOpcA := 2, Iif(ZADSalvar(.F.), (AtualPsgemNF(), oDlg2:End()), .T.) }, nTBWidth, nB1Height/*nHeight*/,,,, .T./*lPixel*/)
    oBtSair:SetCss( oBtCaptura:GetCss() )

    SetKey( VK_F10, { || U_PegaPeso(.T.) } )
    SetKey( VK_F11, { || Iif(ZADSalvar(), mbPesoPrint(), .T.) } )
    SetKey( VK_F4 , { || Iif(ZADSalvar(.F.), (AtualPsgemNF(), oDlg2:End()), .T.) } )

    oDlg2:Activate( /*uParam1*/, /*uParam2*/, /*uParam3*/, .T./*lCentered*/, /* {|| nOpcA := 1, .T.	} *//*bValid*/,;
    /*uParam6*/, /* {||msgStop('iniciando ...')} *//*bInit*/, /*uParam8*/, /*uParam9*/ )
    If nOpcA == 0
        Processa({|| ZADSalvar(.F.) },"Salvando Pesagem")
    EndIf
    RestArea(aArea)
Return nil
// Tela2Pesagem

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  VldNotFis	            	          	            	                  |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  07.12.2020                                                              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
User Function VldNotFis()
    Local lRet := .T.
    if At(&(ReadVar()), M->ZPB_NOTFIS) > 0
        Return .F.
    EndIf
Return lRet

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  AtualPsgemNF	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  02.12.2020                                                              |
 | Desc:  Atualizar dados da pesagem apos a finalizacao da pesagem;               |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function AtualPsgemNF()
    Local aArea   := GetArea()
    Local _cQry   := ""
    Local nI      := 0
    Local aNotFis := StrToKarr(AllTrim(M->ZPB_NOTFIS),";")
    Local nLinAtu := 0

    If Empty(M->ZPB_NOTFIS) .OR.;
            M->ZPB_CLIFOR <> 'C' .OR.;
            !(AllTrim(M->ZPB_CODFOR)==GetMV("MB_PSGCFOR",,"000001") .AND. (M->ZPB_PESOE>0.AND.M->ZPB_PESOS>0))// MB_PSGCFOR : Cliente/Fornecedor na pesagem
        Return nil
    EndIf

    For nI:=1 to Len(aNotFis)

        _cQry := " WITH " + CRLF +;
            "  SD2 AS ( " + CRLF +;
            " 		SELECT R_E_C_N_O_ RECNO, D2_QUANT  " + CRLF +;
            " 		FROM SD2010   " + CRLF +;
            " 		WHERE D2_FILIAL  = '"  + xFilial("SD2") + "' " + CRLF +;
            " 		AND D2_DOC     = '"  + aNotFis[nI]    + "' " + CRLF +;
            " 		AND D2_CLIENTE = '"  + M->ZPB_CODFOR  + "' " + CRLF +;
            " 		AND D2_QUANT   > 0  " + CRLF +;
            " 		AND D_E_L_E_T_ = ' '  " + CRLF +;
            " ) " + CRLF +;
            "" + CRLF +;
            " , SOMA_QTD_SD2 AS ( " + CRLF +;
            " 	SELECT SUM(D2_QUANT) QTD_TOTAL " + CRLF +;
            " 	FROM SD2 " + CRLF +;
            " ) " + CRLF +;
            "" + CRLF +;
            " SELECT *, '" + cValToChar(M->ZPB_PESOL) + "'*(( D2_QUANT*100)/QTD_TOTAL/100) PESO_RATEADO " + CRLF +;
            " FROM SD2 " + CRLF +;
            " CROSS JOIN SOMA_QTD_SD2 "

        If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
            MemoWrite("C:\totvs_relatorios\AtualPsgemNF.sql" , _cQry)
        EndIf
        dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)
        While !TEMPSQL->(Eof())
            nLinAtu += 1
            SD2->(DbGoTo(TEMPSQL->RECNO))
            RecLock("SD2", .F.)
            SD2->D2_XNRPSAG := xFilial("ZPB")+DtoS(M->ZPB_DATA)+M->ZPB_CODIGO
            SD2->D2_XPESLIQ := TEMPSQL->PESO_RATEADO
            SD2->D2_XDTABAT := DataValida(M->ZPB_DATAF+1, .T.)
            SD2->(MsUnlock())

            TEMPSQL->(DBSkip())
        EndDo
        TEMPSQL->(DbCloseArea())
    Next nI

    If nLinAtu>0
        MsgInfo("Em " + cValToChar(Len(aNotFis)) + " notas fiscais foram atualizadas " + cValToChar(nLinAtu) + " linhas." )
    EndIf

    RestArea(aArea)
Return nil

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  BuscaCurral	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  02.12.2020                                                              |
 | Desc:  Localiza curral na nota fiscal SD2                                      |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
User Function BuscaCurral()
    Local aArea   := GetArea()
    Local cCurral := CriaVar( 'ZPB_BAIA', .F.)
    Local _cQry   := ""
    _cQry := " SELECT  DISTINCT D2_LOTECTL " + CRLF+;
        " FROM    SD2010 " + CRLF+;
        " WHERE   D2_FILIAL='" + xFilial('SD2') + "' " + CRLF+;
        " 	   AND D2_DOC IN (" + U_cValToSQL(M->ZPB_NOTFIS, ";") + ") " + CRLF+;
        " 	   AND D2_CLIENTE = '" + AllTrim(M->ZPB_CODFOR) + "' " + CRLF+;
        " 	   AND D_E_L_E_T_=' '"
    If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
        MemoWrite("C:\totvs_relatorios\BuscaCurral.sql" , _cQry)
    EndIf
    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)
    if !TEMPSQL->(Eof())
        cCurral := TEMPSQL->D2_LOTECTL
    EndIf
    TEMPSQL->(DbCloseArea())
    RestArea(aArea)
Return PadR(cCurral, TamSX3('ZPB_BAIA')[1])

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  VldPesagem	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:                                                                          |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function VldPesagem()
    Local lRet := .T.

    If AllTrim(M->ZPB_PRODUT) $ GetMV("MB_PSGARM",,"030001,020023,020017") // os produtos configurados obrigam o preenchimento do campo armazem;
        // se VAZIO entao nao continuar o processo
        If Empty(M->ZPB_LOCAL)
            /* ShowHelpDlg("ERRO", ;
				{"Para o produto selecionado é preciso informar o campo armazem."},,;
                    {"Esta operacao foi cancelada."},5)  */

            Alert("Para o produto selecionado é preciso informar o campo armazem." + CRLF + "Esta operacao foi cancelada.")
        Return .F.
    EndIf
EndIf

/* MB : 08.06.2021
-> Validação obrigar o preenchimento do campo de QUANT. DE ANIMAIS. */
If !Empty(M->ZPB_NROGTA) .AND. Empty(M->ZPB_QTANIM)
    Alert("O campo de quant. de animal [ZPB_QTANIM] não foi informado. O mesmo é obrigatório" + CRLF +;
        "Esta operacao foi cancelada.")
    Return .F.
EndIf

Return lRet

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  ZADSalvar	            	          	            	                  |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:                                                                          |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function ZADSalvar(lAuto)
    Local aAreaZPB := ZPB->(GetArea())
    Local lRecLock := nQualPesagem==0 // .T.
    Local cChave   := ""

    Default lAuto  := .T.

    MBSaveLog():FULLWrite(, .F., "ZADSALVAR Entrada: " + AllTrim( cValToChar(M->ZPB_PESOE) ) )
    MBSaveLog():FULLWrite(, .F., "ZADSALVAR Saida  : " + AllTrim( cValToChar(M->ZPB_PESOS) ) )

    If M->ZPB_PESOE == 0
        Alert("Saida da Rotina Bloqueada. Peso nao informado.")
        Return .F.
    EndIf

    If lAuto .OR. M->ZPB_PESOE>0.AND.M->ZPB_PESOS>0
        If !Obrigatorio(aGets, aTela) .OR. !VldPesagem()
            Return .F.
        EndIf
    EndIf

    If INCLUI
        cChave := dToS(M->ZPB_DATA)+M->ZPB_CODIGO
    Else
        cChave := dToS(ZPB->ZPB_DATA)+ZPB->ZPB_CODIGO
    EndIf

    BeginTran()
    TryException
        ZPB->( DbSetOrder(1) )
        lRecLock:=!ZPB->(DbSeek( xFilial("ZPB") + cChave))
        RecLock( "ZPB", lRecLock )
        ZPB->ZPB_FILIAL	:= xFilial('ZPB')
        U_GrvCpo("ZPB")
        ZPB->ZPB_STATUS := IiF(M->ZPB_PESOE>0.AND.M->ZPB_PESOS>0, "F", "1")
        ZPB->(MsUnlock())

        // While __lSX8
        // ZPB->( ConfirmSX8() )
        // EndDo
        MSUnlockAll()
        oBrowse:Refresh()

        If !lAuto
            cPlacaTGet   := CriaVar( 'DA3_PLACA' , .F.)
            nQualPesagem := 0
        EndIf

    CatchException Using oException
        Alert("Erro ao Gravar Pessagem: " + CRLF + oException:Description)
        u_ShowException(oException)
        DisarmTransaction()
    EndException
    EndTran()
    RestArea(aAreaZPB)
Return .T.

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  fDefinePessagem 	            	          	            	          |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  25.09.2020                   	          	            	              |
 | Desc:  0=Nao localizado pensagem                                               |
 |        1=Existe pesagem, portanto agora é a 2ª pensagem, ou seja, peso de saida|
 |        PROGRAMAR SQL DE VERIFICACAO DA EXISTENCIA DE PESAGEM                   |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
            '--------------------------------------------------------------------------------*/
            Static Function fDefinePessagem()

                Local _cQry    := ""
                Local nRetorno := 0

                _cQry := " SELECT TOP 1 * -- ZPB_PESOE, ZPB_PESOS " + CRLF
                _cQry += " FROM ZPB010 " + CRLF
                _cQry += " WHERE ZPB_FILIAL='"+FWxFilial("ZPB")+"' " + CRLF
                _cQry += "   AND ZPB_PLACA='" + cPlacaTGet + "' " + CRLF
                _cQry += "   AND ZPB_STATUS<>'F' " + CRLF
                _cQry += "   AND D_E_L_E_T_=' ' " + CRLF
                _cQry += " ORDER BY R_E_C_N_O_ DESC " + CRLF
                If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
                    MemoWrite("C:\totvs_relatorios\fDefinePessagem "+cPlacaTGet+".sql" , _cQry)
                EndIf
                dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)
                if !TEMPSQL->(Eof())
                    If TEMPSQL->ZPB_PESOE > 0 // .AND. TEMPSQL->ZPB_PESOS == 0
                        nRetorno := TEMPSQL->R_E_C_N_O_
                    EndIf
                EndIf
                TEMPSQL->(DbCloseArea())

            Return nRetorno // 0 = nao localizado pesagem


            /*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		              |
 | Func:  fDefinePessagem 	            	          	            	          |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  25.09.2020                   	          	            	              |
 | Desc:  0=Nao localizado pensagem                                               |
 |        1=Existe pesagem, portanto agora é a 2ª pensagem, ou seja, peso de saida|
 |        PROGRAMAR SQL DE VERIFICACAO DA EXISTENCIA DE PESAGEM                   |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
            '--------------------------------------------------------------------------------*/
            Static Function UltPesagemXPlaca(cPlaca)
                Local aArea    := GetArea()
                Local _cQry    := ""
                Local aRetorno := {}

                _cQry := " SELECT	TOP 1 R_E_C_N_O_ RECNO--, * " + CRLF
                _cQry += " FROM	ZPB010 " + CRLF
                _cQry += " WHERE	ZPB_PLACA = '"+ cPlaca +"' " + CRLF
                _cQry += "     AND D_E_L_E_T_=' ' " + CRLF
                _cQry += " ORDER BY R_E_C_N_O_ DESC "
                If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
                    MemoWrite("C:\totvs_relatorios\UltPesagemXPlaca "+cPlacaTGet+".sql" , _cQry)
                EndIf
                dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)
                if !TEMPSQL->(Eof())
                    ZPB->(DbGoTo(TEMPSQL->RECNO))
                    aAdd( aRetorno, { ZPB->ZPB_CODMOT,;
                        ZPB->ZPB_CPFMOT,;
                        ZPB->ZPB_NOMMOT,;
                        ZPB->ZPB_PRODUT,;
                        ZPB->ZPB_DESC  ,;
                        ZPB->ZPB_CLIFOR,;
                        ZPB->ZPB_CODFOR,;
                        ZPB->ZPB_LOJFOR,;
                        ZPB->ZPB_NOMFOR,;
                        ZPB->ZPB_LOCAL ,;
                        ZPB->ZPB_BAIA  ,;
                        ZPB->ZPB_OBSERV } )
                EndIf
                TEMPSQL->(DbCloseArea())
                RestArea(aArea)
            Return aRetorno

            /*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  PegaPeso 	            	          	            	                  |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  25.09.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
            '--------------------------------------------------------------------------------*/
            User Function PegaPeso( lGravPeso )
                Local nRetorno := 0 // U_ToledoSocket(.T.)
                nRetorno := U_ToledoSocket(.T.)
                // // durante desenvolvimento
                // If GetServerIP() == "192.168.0.250" .AND. nRetorno==0
                //     nRetorno := Randomize( 5000, 20000 )
                // EndIf
                if lGravPeso
                    If INCLUI
                        if nQualPesagem == 0 // entao 1ª pesagem
                            M->ZPB_HORA   := Time()
                            M->ZPB_OPESOE := nRetorno
                            M->ZPB_PESOE  := nRetorno
                            M->ZPB_PESOL  := ABS(nRetorno - iIf(ValType(M->ZPB_PESOS)=="U", 0, M->ZPB_PESOS))
                        Else
                            ZPB->ZPB_DATAF  := Date()
                            ZPB->ZPB_HORAF  := Time()
                                ZPB->ZPB_OPESOS := nRetorno
                            ZPB->ZPB_PESOS  := nRetorno
                            ZPB->ZPB_PESOL  := ABS( iIf(ValType(ZPB->ZPB_PESOE)=="U", 0, ZPB->ZPB_PESOE) - nRetorno)
                        EndIf
                    Else
                        If M->ZPB_PESOE == 0 // nQualPesagem == 0 // entao 1ª pesagem
                            M->ZPB_HORA   := Time()
                            M->ZPB_OPESOE := nRetorno
                            M->ZPB_PESOE  := nRetorno
                            M->ZPB_PESOL  := ABS( nRetorno - iIf(ValType(M->ZPB_PESOS)=="U", 0, M->ZPB_PESOS) )
                        Else
                            M->ZPB_DATAF  := Date()
                            M->ZPB_HORAF  := Time()
                            M->ZPB_OPESOS := nRetorno
                            M->ZPB_PESOS  := nRetorno
                            M->ZPB_PESOL  := ABS( iIf(ValType(M->ZPB_PESOE)=="U", 0, M->ZPB_PESOE) - nRetorno )
                        EndIf
                    EndIf
                EndIf
            Return nRetorno


            /*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		              |
 | Func:  ReLoadLiquido 	            	          	            	          |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  23.09.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
            '--------------------------------------------------------------------------------*/
            User Function ReLoadLiquido()
                Local nValor := 0

                // If INCLUI // (nQualPesagem==0)
                nValor := M->ZPB_PESOL := ABS(M->ZPB_PESOE - M->ZPB_PESOS)
                //Else
                // nValor := ZPB->ZPB_PESOL := ABS(ZPB->ZPB_PESOE - ZPB->ZPB_PESOS)
                // EndIf

            Return nValor
            // Tela2Pesagem()


            /*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  mbPesoPrint 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  29.09.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
            '--------------------------------------------------------------------------------*/
            Static Function mbPesoPrint()

                // Local cFilePrinter := "Ticket-" + AllTrim(cPlacaTGet) + "-" + DtoS(dDataBase) + '-' + StrTran(Time(),":","") + ".rel"
                Local cFilePrinter := "Ticket-" + AllTrim(iIf(INCLUI, M->ZPB_PLACA, ZPB->ZPB_PLACA)) + "-" + DtoS(dDataBase) + "-" + AllTrim(iIf(INCLUI, M->ZPB_CODIGO, ZPB->ZPB_CODIGO)) + iIf(GetServerIP()=="192.168.0.250", " " + StrTran(Time(),":",""), "") + ".rel"
                Private oPrinter   := nil

                oPrinter := FWMSPrinter():New( cFilePrinter, IMP_PDF/*nDevice*/ , .F./*lAdjustToLegacy*/, /*cPathInServer*/, .T./*lDisabeSetup*/,;
                    /*lTReport*/, /*@oPrintSetup*/, /*cPrinter*/, /*lServer*/, .F./*lPDFAsPNG*/, /*lRaw*/,;
                    .T. /*lViewPDF*/, /*nQtdCopy*/ )
                oPrinter:StartPage()
                // oPrinter:SetResolution(72)
                oPrinter:SetPortrait()
                oPrinter:SetPaperSize(DMPAPER_A4) // DMPAPER_A4 = A4 210 x 297 mm
                oPrinter:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior
                oPrinter:cPathPDF := "C:\TOTVS_RELATORIOS\" // Caso seja utilizada impressão em IMP_PDF

                RptStatus({|lEnd| ImpTicket(@lEnd)}, "Imprimindo relatorio...") //"A imprimir relatório..."

            Return nil


            /*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  ImpTicket 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  29.09.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
            '--------------------------------------------------------------------------------*/
            Static Function ImpTicket( lEnd )
                // Local nSizePage    := 0
                Local _cBaia       := ""

                Private nRow       := 30, nColLabel:=30, nColInfo :=110
                Private cTxtAux    := ""
                Private cLogo      := "\system\lgrl" + AllTrim(cEmpAnt) + ".bmp"
                // Private nBckTamLin := nTamLin
                Private cReplc     := 65
                Private nTotLinOBS := 4

                Private cUltTrato  := ""

                _cBaia := iIf(INCLUI, M->ZPB_BAIA, ZPB->ZPB_BAIA)
                If ( iIf(INCLUI, M->ZPB_CLIFOR, ZPB->ZPB_CLIFOR) == "C" ) .AND.;
                        (iIf(INCLUI, M->ZPB_CODFOR, ZPB->ZPB_CODFOR) == GetMV("MB_PSGCFOR",,"000001")) .AND.;
                        !Empty(_cBaia)
                    cUltTrato := fQryUltTrato( _cBaia )
                EndIf

                nTotLinha := (14/* linhas de textos */+3 /* linhas graficas de separacao */+nTotLinOBS/*linhas do campo de observacao*/)+2
                nTamLin   := /* 20 */ /* 19 */ 18.5

                // nSizePage := oPrinter:nPageWidth / oPrinter:nFactorHor //Largura da página em cm dividido pelo fator horizontal, retorna tamanho da página em pixels

                oPrinter:Box( nRow*0.6, nBoxCol:=nColLabel*0.6, nBoxBottom:=(nTamLin*nTotLinha)*0.95, nBoxRight:=int(oPrinter:nPageWidth/4.15), cBoxPixel:="-4" )// ( 130, 10, 600, 900, "-4")
                fQuadro(1)

                // nRow+=nTamLin
                cTxtAux := Replicate("-", cReplc) + "recorte-aqui" + Replicate("-", cReplc)
                // oPrinter:Say ( nRow+=nTamLin/* *0.8 */, nColLabel    ,  cTxtAux /*cText>*/, oFontRecor/*oFont*/, /*nWidth*/, RGB(255,0,0)/*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow:=nBoxBottom+(nTamLin/2)+(nTamLin/5), nColLabel    ,  cTxtAux /*cText>*/, oFontRecor/*oFont*/, /*nWidth*/, RGB(255,0,0)/*nClrText*/, /*nAngle*/ )

                oPrinter:Box( nRow+=(nTamLin/2), nBoxCol, nBoxBottom*2, nBoxRight/*nRight*/, "-4"/*cPixel*/ )// ( 130, 10, 600, 900, "-4")
                nRow+=(nTamLin/2)+(nTamLin/5)
                fQuadro(2)

                oPrinter:EndPage()
                oPrinter:Preview()
                FreeObj(oPrinter)
                oPrinter := Nil

                /// nTamLin := nBckTamLin

            Return nil

            // ##########################################################################
            Static Function fQuadro( nQuadro )
                Local cAux      := ""
                Local nCol2     := 305
                Default nQuadro := 0

                oPrinter:Say ( nRow         , nColLabel, PADC(AllTrim(upper(SM0->M0_NOMECOM)), cReplc*1.1 )/*cText>*/, oFTitLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
                oPrinter:Line( nRow+=nTamLin-10/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )

                oPrinter:Say ( nRow+=nTamLin, nColLabel, "CNPJ...........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo , Transform(SM0->M0_CGC, X3Picture("A2_CGC"))/*cText>*/,oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                oPrinter:Say ( nRow         , nColLabel+nCol2, "Inscr. Estadual:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo +nCol2, Transform(SM0->M0_INSC, X3Picture("@R 999.999.999.999"))/*cText>*/,oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                oPrinter:Say ( nRow+=nTamLin, nColLabel, "Fone...........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo , "(18) 99658-4721 / (18) 99665-4013"/*SM0->M0_TEL*/ /*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                oPrinter:Say ( nRow         , nColLabel+nCol2, "E-Mail.........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo +nCol2, "balanca@vistaalegre.agr.br"/*cText>*/,oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                cTxtAux := AllTrim( SM0->M0_ENDENT )+" - "+AllTrim(SM0->M0_BAIRENT)+" - CEP: "+AllTrim(SM0->M0_CEPENT)
                oPrinter:Say ( nRow+=nTamLin, nColLabel, "Endereço.......:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo , cTxtAux/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                // ----------------------------------------------------------------------------------------------------------------------------
                // Linha
                oPrinter:Line( nRow+=nTamLin-5/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )
                oPrinter:Say ( nRow+=nTamLin, nColLabel      , "Ticket.........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow       , nColInfo , dToS(iIf(INCLUI, M->ZPB_DATA, ZPB->ZPB_DATA))+'-'+iIf(INCLUI, M->ZPB_CODIGO, ZPB->ZPB_CODIGO);
                    /*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                oPrinter:Say ( nRow         , nColLabel+nCol2, "Impressão......:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo+nCol2, DtoC(MsDate())+" às "+SubS(Time(),1,5) /*cText>*/,oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Line( nRow+=nTamLin-5/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )
                // Linha
                // ----------------------------------------------------------------------------------------------------------------------------

                if nQuadro==2
                    nBitMWidth:=150
                    oPrinter:SayBitmap ( nRow+10/* -nColLabel *//*nRow*/, nBoxRight-nBitMWidth-5/* -nColLabel *//*nCol*/, cLogo/*cBitmap*/, nBitMWidth, int(nBitMWidth/2)/*nHeight*/ )
                EndIf

                oPrinter:Say ( nRow+=nTamLin, nColLabel, "Placa de cavalo:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo , iIf(INCLUI, M->ZPB_PLACA, ZPB->ZPB_PLACA)/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                If ( iIf(INCLUI, M->ZPB_CLIFOR, ZPB->ZPB_CLIFOR) == "C" )
                    cAux := "Cliente........:"
                Else
                    cAux := "Fornecedor.....:"
                EndIf
                oPrinter:Say ( nRow+=nTamLin, nColLabel, cAux/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo , iIf(INCLUI, M->ZPB_NOMFOR, ZPB->ZPB_NOMFOR)/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                oPrinter:Say ( nRow+=nTamLin, nColLabel, "CPF / CNPJ.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                If !Empty(iIf(INCLUI, M->ZPB_CPFMOT, ZPB->ZPB_CPFMOT))
                    oPrinter:Say ( nRow     , nColInfo , Transform(iIf(INCLUI, M->ZPB_CPFMOT, ZPB->ZPB_CPFMOT), X3Picture("ZPB_CPFMOT"))/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                EndIf

                oPrinter:Say ( nRow+=nTamLin, nColLabel, "Motorista......:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo , iIf(INCLUI, M->ZPB_NOMMOT, ZPB->ZPB_NOMMOT)/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                oPrinter:Say ( nRow+=nTamLin, nColLabel, "Notas Fiscais..:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo , iIf(INCLUI, M->ZPB_NOTFIS, ZPB->ZPB_NOTFIS)/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                oPrinter:Say ( nRow+=nTamLin, nColLabel, "Produto........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo , iIf(INCLUI, M->ZPB_DESC, ZPB->ZPB_DESC)/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                oPrinter:Say ( nRow         , nColLabel+nCol2, "Baia........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo+nCol2 , iIf(INCLUI, M->ZPB_BAIA, ZPB->ZPB_BAIA)/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                oPrinter:Say ( nRow+=nTamLin, nColLabel, "Peso Entrada...:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo ,  AllTrim(Transform( iIf(INCLUI, M->ZPB_PESOE, ZPB->ZPB_PESOE), X3Picture("ZBC_PESO") ) )/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                If !Empty(StrTran(DtoC(iIf(INCLUI, M->ZPB_DATAF, ZPB->ZPB_DATAF)),"/","")+StrTran(iIf(INCLUI, M->ZPB_HORAF, ZPB->ZPB_HORAF),":",""))
                    cAux := DtoC(iIf(INCLUI, M->ZPB_DATA, ZPB->ZPB_DATA))+" - "+SubS(iIf(INCLUI, M->ZPB_HORA, ZPB->ZPB_HORA),1,5)
                    oPrinter:Say ( nRow         , nColInfo+nCol2, cAux /*cText>*/, oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                EndIf

                oPrinter:Say ( nRow+=nTamLin, nColLabel, "Peso Saida.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo ,  AllTrim(Transform( iIf(INCLUI, M->ZPB_PESOS, ZPB->ZPB_PESOS), X3Picture("ZBC_PESO") ) )/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                If !Empty(StrTran(DtoC(iIf(INCLUI, M->ZPB_DATAF, ZPB->ZPB_DATAF)),"/","")+StrTran(iIf(INCLUI, M->ZPB_HORAF, ZPB->ZPB_HORAF),":",""))
                    cAux := DtoC(iIf(INCLUI, M->ZPB_DATAF, ZPB->ZPB_DATAF))+" - "+SubS(iIf(INCLUI, M->ZPB_HORAF, ZPB->ZPB_HORAF),1,5)
                    oPrinter:Say ( nRow         , nColInfo+nCol2, cAux /*cText>*/, oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                EndIf

                oPrinter:Say ( nRow+=nTamLin, nColLabel, "Peso Líquido...:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo , AllTrim(Transform( iIf(INCLUI, M->ZPB_PESOL, ZPB->ZPB_PESOL), X3Picture("ZBC_PESO") ) )/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

                If !Empty( cUltTrato )
                    oPrinter:Say ( nRow     , nColLabel+nCol2, "Ultimo Trato:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                    oPrinter:Say ( nRow     , nColInfo+nCol2 , cUltTrato/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                EndIf

                oPrinter:Say ( nRow+=nTamLin, nColLabel, "Observação.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                nCountLinOBS := 0
                cTamOBS      := 123
                cTexto       := StrTran( AllTrim(iIf(INCLUI, M->ZPB_OBSERV, ZPB->ZPB_OBSERV)), Chr(13)+Chr(10), " ")
                nRow         -= nTamLin
                While .T.
                    nCountLinOBS += 1
                    oPrinter:Say ( nRow +=nTamLin, nColInfo , SubS(Upper(cTexto),1,cTamOBS)/*cText>*/, oFInfoOBS/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                    cTexto := SubS(cTexto, cTamOBS+1)
                    if (nCountLinOBS==nTotLinOBS) .OR. Empty(cTexto)
                        exit
                    Endif
                EndDo
                nRow += (nTamLin*(nTotLinOBS-nCountLinOBS))
                oPrinter:Say ( nRow+=nTamLin, nColLabel, "Responsável pela Pesagem.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                oPrinter:Say ( nRow         , nColInfo+65 , cUsername/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
            Return


            /*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  ToledoSocket 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  22.10.2020                   	          	            	              |
 | Desc:  Conecta na balanca e pega o resultado;                                  |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
            '--------------------------------------------------------------------------------*/
            User Function ToledoSocket( lConverte )
                Local oObj        := tSocketClient():New()
                Local nX          := 0
                Local nIp         := GetMV("MB_BalTolI",, '192.168.0.147' )
                Local nPort       := GetMV("MB_BAlTolP",, 9000)
                Local cBuffer     := ""
                Local xRetorno

                Default lConverte := .T.

                xRetorno          := iIf(lConverte, 0, "0")

                // -------------------------------
                // Tenta conectar 3 vezes
                // -------------------------------
                For nX := 1 to GetMV("MB_BAlTolT",, 3)
                    nResp := oObj:Connect( nPort,nIp,10 )
                    if(nResp == 0 )
                        exit
                    else
                        conout("--> Tentativa de Conexão: " + StrZero(nX,3))
                        Sleep(2000)
                        // continue
                        Alert("Sem conectividade com a balança para a coleta do peso, tentativa nº " +cValtoChar(nX)+ ". Esta mensagem aparece quando o sistema solicita o peso para a balança e não ocore a resposta. Verificar se a balança está ligada e se o cabo de comunicação está ok.")
                    endif
                Next

                // --------------------------------------
                // Verifica se a conexão foi bem sucedida
                // --------------------------------------
                if( !oObj:IsConnected() )
                    conout("--> Falha na conexão")
                    return xRetorno
                else
                    conout("--> Conexão OK")
                endif

                // -------------------------------
                // Teste de envio para o socket
                // -------------------------------
                cSend := OemToAnsi("Nao precisa ser enviado nada.") // Dados enviados pelo AdvPL..."
                nResp := oObj:Send( cSend )
                if( nResp != len( cSend ) )
                    conout( "--> Erro! Dado nao transmitido" )
                else
                    conout( "-- > Dado Enviado - Retorno: " +StrZero(nResp,5) )
                endif

                // -------------------------------
                // Teste de recebimento do socket
                // -------------------------------
                nResp = oObj:Receive( @cBuffer, 10000 )
                if( nResp >= 0 )
                    conout( "--> Dados Recebidos " + StrZero(nResp,5) )
                    conout( "--> ["+cBuffer+"]" )

                    If lConverte
                        if !Empty(cBuffer)
                            cBuffer := SubS(cBuffer, 5, Len(SubS(cBuffer, 5))-1)
                            xRetorno    := Val( SubS( cBuffer, 1, 6)+'.'+SubS( cBuffer, 7) )

                            If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
                                MemoWrite( "C:\totvs_relatorios\Pesagem_" + AllTrim(cPlacaTGet) + "_" + DtoS(MsDate()) + "_" + StrTran(Time(),":","") + ".txt",;
                                    cBuffer+/* CRLF+ */cValToChar(xRetorno) )
                            EndIf
                        EndIf
                    EndIf
                else
                    conout( "--> Nao recebi dados" )
                endif

                // -------------------------------
                // Fecha conexão
                // -------------------------------
                oObj:CloseConnection()
                conout( "--> Conexão fechada" )

            Return xRetorno// Return cBuffer


            /*  BIBLIOTECA

    Picture, Mascara
    https://tdn.totvs.com/pages/releaseview.action?pageId=469450707

    palheta de cores HEXADECIMAL
    https://www.w3schools.com/colors/colors_picker.asp

    setCSS
    https://tdn.totvs.com/display/tec/SetCSS

    atalhos
    https://tdn.totvs.com/display/tec/SetKey
            */
            /*
PICTURE VAR
OMSA040TIP()
            */

            /*
    MB : 30.11.2020
        -> Consulta Especifica
            De acordo com o definido no campo: ZPB_CLIFOR, fazer SQL de Cliente ou Fornecedor;
            */
            User Function F3CliForPes()
                Local lRet   := .F.

                If M->ZPB_CLIFOR == "C"
                    If lRet := U_PesqCli()
                        cF3CodCFPes := SA1->A1_COD
                        cF3LojCFPes := SA1->A1_LOJA
                        cF3NomCFPes := SA1->A1_NOME
                    EndIf
                ElseIf M->ZPB_CLIFOR == "F"
                    If lRet := U_PesqFor()
                        cF3CodCFPes := SA2->A2_COD
                        cF3LojCFPes := SA2->A2_LOJA
                        cF3NomCFPes := SA2->A2_NOME
                    EndIf
                Else
                    Alert("Por favor selecione o campo CLIENTE/FORNECEDOR !!!")
                EndIf
            Return lRet

            /*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  ceDocBaia             	          	            	                  |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  15.12.2020                                                              |
 | Desc:  Consulta Especifica de Notas Fiscais de Saida x Baia;                   |
 |         Doc x Baia;                                                            |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
            '--------------------------------------------------------------------------------*/
            User Function ceDocBaia()
                Local oDlg, oLbx
                Local aCpos  := {}
                Local aRet   := {}
                Local _cQry := ""
                Local cAlias := GetNextAlias()
                Local lRet   := .F.

                _cQry := " SELECT D2_LOTECTL, " + CRLF+;
                    "        D2_DOC, " + CRLF+;
                    "        SUM(D2_QUANT) QTDE " + CRLF+;
                    "  FROM SD2010 " + CRLF+;
                    "  WHERE D2_FILIAL  = '" + xFilial('SD2')         + "'" + CRLF+;
                    "    AND D2_EMISSAO = '" + DtoS(M->ZPB_DATA)      + "'" + CRLF+;
                    "    AND D2_CLIENTE = '" + AllTrim(M->ZPB_CODFOR) + "'" + CRLF+;
                    "    AND D2_QUANT > 0 " + CRLF+;
                    "    AND D2_GRUPO IN ('BOV','01')" + CRLF+;
                    "    AND D2_LOTECTL NOT IN (" + CRLF+;
                    "		                SELECT ZPB_BAIA " + CRLF+;
                    "						  FROM ZPB010 " + CRLF+;
                    "						 WHERE ZPB_FILIAL = D2_FILIAL" + CRLF+;
                    "						   AND ZPB_BAIA = D2_LOTECTL " + CRLF+;
                    "						   AND ZPB_NOTFIS LIKE '%' + D2_DOC + '%'" + CRLF+;
                    "						   AND D_E_L_E_T_ = ' ' " + CRLF+;
                    "						)" + CRLF+;
                    "    AND D_E_L_E_T_ = ' '" + CRLF+;
                    " GROUP BY D2_DOC, D2_LOTECTL" + CRLF+;
                    " ORDER BY CAST(REPLACE(SUBSTRING(D2_LOTECTL, 1, CHARINDEX('-',D2_LOTECTL)),'-','') AS INT), 2"

                // _cQry := ChangeQuery(_cQry)
                dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAlias,.T.,.T.)

                While (cAlias)->(!Eof())
                    aAdd(aCpos,{(cAlias)->D2_LOTECTL, (cAlias)->D2_DOC, (cAlias)->QTDE })
                    (cAlias)->(dbSkip())
                End
                (cAlias)->(dbCloseArea())

                If Len(aCpos) < 1
                    aAdd(aCpos,{" "," "," "})
                EndIf

                DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Listagem de Notas Fiscais x Baia" FROM 0,0 TO 240,500 PIXEL

                @ 10,10 LISTBOX oLbx FIELDS HEADER 'Lote x Baia' /*"Roteiro"*/,;
                    'N. Fiscal' /*"Produto"*/,;
                    'Quant.' SIZE 230,95 OF oDlg PIXEL

                oLbx:SetArray( aCpos )
                oLbx:bLine     := {|| {aCpos[oLbx:nAt,1],;
                    aCpos[oLbx:nAt,2],;
                    aCpos[oLbx:nAt,3]}}
                oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],;
                    oLbx:aArray[oLbx:nAt,2],;
                    oLbx:aArray[oLbx:nAt,3]}}}

                DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T.,;
                    aRet := {oLbx:aArray[oLbx:nAt,1],;
                    oLbx:aArray[oLbx:nAt,2],;
                    oLbx:aArray[oLbx:nAt,3]})  ENABLE OF oDlg
                ACTIVATE MSDIALOG oDlg CENTER

                If Len(aRet) > 0 .And. lRet
                    If Empty(aRet[1])
                        lRet := .F.
                    Else
                        _cNotaFiscal := aRet[2]
                    EndIf
                EndIf
            Return lRet


            /*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  fQryUltTrato 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  15.12.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
            '--------------------------------------------------------------------------------*/
            Static Function fQryUltTrato( cBaia )
                Local cRetorno := ""

                _cQry := " SELECT Z0W_LOTE, " + CRLF +;
                    " 	      MAX(Z0W_DATA) DATA," + CRLF +;
                    " 	      SUBSTRING(MAX(Z0W_DATA+Z0W_HORFIN),9,5) HORA" + CRLF +;
                    " FROM Z0W010" + CRLF +;
                    " WHERE Z0W_FILIAL = '" + xFilial('Z0W') + "'" + CRLF +;
                    " AND Z0W_LOTE = '" + cBaia + "'" + CRLF +;
                    " AND (Z0W_QTDREA > 0 OR Z0W_PESDIG > 0)" + CRLF +;
                    " AND D_E_L_E_T_ = ' '" + CRLF +;
                    " GROUP BY Z0W_LOTE"
                dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)
                If !TEMPSQL->(Eof())
                    cRetorno := /*AllTrim(TEMPSQL->Z0W_LOTE) + ': ' +*/dToC(sToD(TEMPSQL->DATA)) + ' - ' + TEMPSQL->HORA
                    // TEMPSQL->(DBSkip())
                EndIf
                TEMPSQL->(DbCloseArea())

            Return cRetorno
