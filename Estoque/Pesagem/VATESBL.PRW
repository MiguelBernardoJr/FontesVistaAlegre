#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'fileio.ch'

#define F_BLOCK 128

User Function VATESBL() //        
    DEFINE DIALOG oDlg TITLE "Exemplo TFolder" FROM 180,180 TO 230,480 PIXEL
    // Cria a Folder
    
    // Insere um TGet em cada aba da folder
    oTButton := TButton():New( 001, 002, "Pesar",oDlg,{|| PegaPeso()}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )

   //cTGet1 := ""
   //oTGet1 := TGet():New( 001,55,{||cTGet1},oDlg,096,017,;
   //    "",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet1,,,, )

    oFont := TFont():New('Courier new',,-18,.T.)
    
    // Usando o método New
    oSay1:= TSay():New(01,01,{||'Peso informado'},oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
    
    // Métodos
    oSay1:SetTextAlign( 2, 2 )
    
    // Propriedades
    oSay1:lTransparent = .T.

    ACTIVATE DIALOG oDlg CENTERED
Return

Static Function PegaPeso()

    Local nPeso := 10// Pesar()//u_zLeBalanca()

    oSay1:SetText( LTrim(Str(nPeso)))

    oSay1:CtrlRefresh()

Return

User Function PesTeste()
    Local cPorta    := ""
    Local cVelocid  := ""
    Local cParidade := ""
    Local cBits     := ""
    Local cStopBits := ""
    Local cFluxo    := ""
    Local nTempo    := ""
    Local cConfig   := ""
    Local lRet      := .T.
    Local nH        := 0
    Local cBuffer   := SPACE(F_BLOCK)
    Local nPosFim   := 0
    Local nPosIni   := 0
    Local nAux      := 0
    Local nX        := 0
    Local cPesoLido := ""
    Local nHandle

    cPorta    := SuperGetMV("MV_X_PORTA",.F.,"COM1")
    
    cVelocid  := SuperGetMV("MV_X_VELOC", .F.,"115200")     //Velocidade
    cParidade := SuperGetMV("MV_X_PARID", .F.,"N")          //Paridade
    cBits     := SuperGetMV("MV_X_BITS",  .F.,"8")          //Bits
    cStopBits := SuperGetMV("MV_X_SBITS", .F.,"1")          //Stop Bit
    cFluxo    := SuperGetMV("MV_X_FLUXO", .F.,"")           //Controle de Fluxo
    nTempo    := SuperGetMV("MV_X_TEMPO", .F.,5)            //Tempo
    
    cConfig := cPorta+":"+cVelocid+","+cParidade+","+cBits+","+cStopBits
    
    nHandle := FOPENPORT(cPorta+":", cVelocid+","+cParidade+","+cBits+","+cStopBits, FO_READ)

    IF FERROR() != 0
        MsgStop( "Impossivel comunicar com a porta "+cPorta+", Erro : ", FERROR())
        FCLOSE(nHandle)
        Return 0
    ENDIF

    FSEEK(nHandle, 0, FS_END)

    IF FREAD(nHandle, @cBuffer, F_BLOCK) <> F_BLOCK
        MsgStop("Erro ao capturar peso")
        FCLOSE(nHandle)
        Return 0
    ENDIF

    FClose(nHandle)
Return
