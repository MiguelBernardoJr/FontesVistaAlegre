#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static oBmpVerde    := LoadBitmap( GetResources(), "BR_VERDE")
Static oBmpVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
Static oBmpPreto    := LoadBitmap( GetResources(), "BR_PRETO")
User Function CT030BUT()
    Local aBotoes := ParamIXB
    
    IF SX2->X2_MODO == 'E' .and. SX2->X2_MODOUN == 'E' .and. SX2->X2_MODOEMP == 'E'
        aAdd(aBotoes,{ "Replicar nas Filiais" , "Processa( { || U_VACTBI1() })", 0, 0} )
    ENDIF
 
Return aBotoes

User Function VACTBI1()
    Local lRet          := .T. 
    Local aSize         := MsAdvSize(.F.)
    local nTamLin       := 16
    local nOpc          := GD_UPDATE
	local cLinOk        := "AllwaysTrue"
	local cTudoOk       := "AllwaysTrue"
	local cIniCpos      := "B8_LOTECTL"
	local nFreeze       := 000
	local nMax          := 999
	local cFieldOk      := "AllwaysTrue"
	local cSuperDel     := ""
	local cDelOk        := "AllwaysFalse"
	local nLinIni       := 03
	local nLinAtu       := nLinIni
    Local cQry          := ""
    Local cAlias        := GetNextAlias()

    Private oDlgMrk     := nil
    Private oGetMrk     := nil
    Private oBmpAux     := nil
    Private aHeadMrk    := {}
    Private aColsMrk	:= {}
    Private nUsadMrk

    aAdd(aHeadMrk,{ " "      , "XX_COR"     , "@BMP", 2 , 0,".F.","","C","","V","","","","V"})
    aAdd(aHeadMrk,{ " "		 , "cLb"        , "@BMP", 1 , 0,"","","C","","V","","","","V","","",""})
	aAdd(aHeadMrk,{ "Empresa", "cEmpresa"	, "@!"	, 2	, 0, "AllwaysTrue()",.T., "C", "", "V" } )
	aAdd(aHeadMrk,{ "Filial" , "cFilial"	, "@!"	, 7	, 0, "AllwaysTrue()",.T., "C", "", "V" } )
	aAdd(aHeadMrk,{ "Nome"	 , "cNome"	    , "@!"	, 50, 0, "AllwaysTrue()",.T., "C", "", "V" } )
	aAdd(aHeadMrk,{ "CC"	 , "cCC"	    , "@!"	, 10, 0, "AllwaysTrue()",.T., "C", "", "V" } )
	
    nUsadMrk := len(aHeadMrk)

    cQry := "SELECT M0_CODIGO " + CRLF
    cQry += " 	, M0_CODFIL " + CRLF
    cQry += " 	, M0_FILIAL " + CRLF
    cQry += " 	, CTT_CUSTO " + CRLF
	cQry += "   , ISNULL(CTT_BLOQ,'') AS CTT_BLOQ" + CRLF
    cQry += " FROM SYS_COMPANY SM0 " + CRLF
    cQry += " LEFT JOIN "+RetSqlName("CTT")+" CTT ON M0_CODFIL = CTT_FILIAL " + CRLF
    cQry += " AND CTT.CTT_CUSTO = '"+AllTrim(CTT->CTT_CUSTO)+"' " + CRLF
    cQry += " AND CTT.D_E_L_E_T_ = '' " + CRLF
    cQry += " WHERE SM0.D_E_L_E_T_ = '' " + CRLF
    cQry += " AND M0_CODIGO = '"+cEmpAnt+"' " + CRLF
    cQry += " ORDER BY 1,2 " + CRLF

    MpSysOpenQuery(cQry,cAlias)
    
    While !(cALias)->(EOF())
        aAdd(aColsMrk, array(nUsadMrk+1))
        
        if (cAlias)->CTT_BLOQ == '2'
            oBmpAux := oBmpVerde
        elseif (cAlias)->CTT_BLOQ == '1'
            oBmpAux := oBmpVermelho
        else
            oBmpAux := oBmpPreto
        endif
        
        aColsMrk[LEN(aColsMrk),1] :=  oBmpAux // SE FOR BLOQUEADO
        aColsMrk[LEN(aColsMrk),2] :=  "LBTIK" // SE FOR BLOQUEADO
        aColsMrk[LEN(aColsMrk),3] :=  (cAlias)->M0_CODIGO
        aColsMrk[LEN(aColsMrk),4] :=  (cAlias)->M0_CODFIL
        aColsMrk[LEN(aColsMrk),5] :=  (cAlias)->M0_FILIAL
        aColsMrk[LEN(aColsMrk),6] :=  CTT->CTT_CUSTO
        aColsMrk[LEN(aColsMrk),7] :=  .F.
        
        (cALias)->(DbSkip())
    EndDo
    (cALias)->(DbCloseArea())

    define msDialog oDlgMrk title "Seleção de Filiais" /*STYLE DS_MODALFRAME*/ From aSize[1], aSize[2] To 600,635 OF oMainWnd PIXEL
	oDlgMrk:lMaximized := .F.
	oDlgMrk:lCentered  := .T.

    oBtMrk	:= TButton():New( nLinAtu, 02, "Inverter seleção" ,oDlgMrk, {|| MarcaDes(oGetMrk,"T") },60, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)

    oSeek	:= TButton():New( nLinAtu, 260, "Confirmar" ,oDlgMrk, {|| ConfirmAdd() },55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)

    nLinAtu += nTamLin + 8

	oGetMrk:= MsNewGetDados():New(nLinAtu, 01, 300,320, nOpc, cLinOk, cTudoOk, cIniCpos, {}, nFreeze, nMax, cFieldOk, cSuperDel, cDelOk, oDlgMrk, aHeadMrk, aColsMrk)
	oGetMrk:oBrowse:blDblClick := {|| MarcaDes(oGetMrk,"L")}

	Activate dialog oDlgMrk centered
Return lRet
Static Function ConfirmAdd()
	local aArea     := GetArea()
	local nPosFil   := aScan( aHeadMrk, { |x| AllTrim(x[2]) == "cFilial"})
	Local nI        := 0
	Local nJ        := 0
    Local nQt       := 0
    Local cFilMrk   := ""
    Local lRecLock  := .T.
    Local aCusto    := {}
    Local cQry      := ""
    Local cAlias    := ""
    
    for nI := 1 to len(oGetMrk:aCols)
		If oGetMrk:aCols[ nI,2]=="LBTIK"
            if oGetMrk:aCols[ nI,nPosFil] == CTT->CTT_FILIAL
                oGetMrk:aCols[ nI,2] := "LBNO"
            endif
			nQt++
		EndIf
	Next

    If nQt == 0
        msgAlert("Nenhuma filial selecionada, escolha pelo menos 1 para continuar.")
		Return .F.
	EndIf

    cQry := "SELECT X3_CAMPO,X3_ORDEM FROM "+RetSqlName("SX3")+" WHERE X3_ARQUIVO = 'CTT' AND X3_CONTEXT <> 'V' ORDER BY 2"
    
    cAlias := GetNextAlias()

    MpSysOpenQuery(cQry,cAlias)

    aAdd(aCusto,CTT->CTT_CUSTO)
    aAdd(aCusto,{})
    
    While !(cAlias)->(EOF())
        aAdd(aCusto[2],{alltrim((cAlias)->X3_CAMPO), CTT->&(Alltrim((cAlias)->X3_CAMPO))}) 
        (cAlias)->(dbSkip())
    EndDo
    (cAlias)->(DBCLOSEAREA())
    
    DBSelectArea("CTT")
    CTT->(DbSetOrder(1))

    Begin Transaction
        For nI := 1 to len(oGetMrk:aCols)
            if oGetMrk:aCols[ nI,1]:cName == 'BR_VERDE'
                If oGetMrk:aCols[ nI,2]=="LBTIK"
                    cFilMrk     := alltrim(oGetMrk:aCols[ nI,nPosFil])
                    
                    RecLock("CTT",lRecLock := !(CTT->(DBSeek(cFilMrk + aCusto[1]))))
                        CTT->CTT_BLOQ := '1'
                    CTT->(MsUnLock())
                endif 
            elseif oGetMrk:aCols[ nI,1]:cName == 'BR_VERMELHO'
                If oGetMrk:aCols[ nI,2]=="LBTIK"
                    cFilMrk     := alltrim(oGetMrk:aCols[ nI,nPosFil])
                    
                    RecLock("CTT",lRecLock := !(CTT->(DBSeek(cFilMrk + aCusto[1]))))
                        CTT->CTT_BLOQ := '2'
                    CTT->(MsUnLock())
                endif 
            elseif oGetMrk:aCols[ nI,1]:cName == 'BR_PRETO'
                cFilMrk     := alltrim(oGetMrk:aCols[ nI,nPosFil])

                RecLock("CTT",lRecLock := !(CTT->(DBSeek(cFilMrk + aCusto[1]))))
                    For nJ := 1 to Len(aCusto[2])
                        CTT->&(aCusto[2,nJ,1]) := aCusto[2,nJ,2]
                    Next nJ

                    CTT->CTT_BLOQ := '2'
                    CTT->CTT_FILIAL := cFilMrk
                CTT->(MsUnLock())
            endif

            If oGetMrk:aCols[ nI,1]=="LBTIK"
            endif 
        Next nI
    End Transaction

    oDlgMrk:END()

    MsgInfo("Operação concluida!")

    RestArea(aArea)
Return 
Static Function MarcaDes(oObj,cTipo)
	Local k := 0
	If cTipo <> "T"
		If oObj:aCols[oObj:oBrowse:nAt,2] == "LBNO"
			oObj:aCols[oObj:oBrowse:nAt,2] := "LBTIK"
		Else
			oObj:aCols[oObj:oBrowse:nAt,2] := "LBNO"
		EndIf
	Else
		FOR k:= 1 TO len(oObj:aCols)
			If oObj:aCols[k,2] == "LBNO"
				oObj:aCols[k,2] := "LBTIK"
			Else
				oObj:aCols[k,2] := "LBNO"
			EndIf
		Next

	EndIf
Return(NIL)
