// #########################################################################################
// Projeto: JRModelos
// Fonte  : JRMOD2
// ---------+------------------------------+------------------------------------------------
// Data     | Autor: JRScatolon            | Descricao: Rotina de Rotas do Trato 
// ---------+------------------------------+------------------------------------------------
// aaaammdd | <email>                      | <Descricao da rotina>
//          |                              |  
//          |                              |  
// ---------+------------------------------+------------------------------------------------

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"

Static dLastClickTime := JurTime(.f., .T.) // Global ou estática

User Function VAPCPA09()
Local lConstroi 	:= .T.
Local cQry     		:= ""
Local cPrgRot     	:= "VAPCPA09"
Local cAlias    	:= ""
Private lShwZer   	:= .F.
Private lShwGer   	:= .T.
Private nOpcRotas 	:= 1
Private aDadSel   	:= {}
Private aLinAlf   	:= {}
Private aParRet   	:= {}
Private aTik    := {LoadBitmap( GetResources(), "LBTIK" ), LoadBitmap( GetResources(), "LBNO" )}
Private __dDtPergunte := StoD("")

Private oTFldr		:= nil
Private oTFntGr     := TFont():New('Courier new', , 16, .T., .T.)
Private oTFntLC     := TFont():New('Courier new', , 48, .T., .T.)
Private oTFntPs     := TFont():New('Courier new', , 18, .T., .T.)
Private oTFntSb     := TFont():New('Courier new', , 16, .T., .T., , , , , .T.) // Sublinhado
Private oTFntTC     := TFont():New('Courier new', , 26, .T., .T.)
Private oTFntLg     := TFont():New('Courier new', , 18, .T., .T.)
Private oTFntLgN    := TFont():New('Courier new', , 19, .T., .T.)
Private oTFntLgT    := TFont():New('Courier new', , 26, .T., .T.)
Private aCorTl 	 	:= {}
Private aCrDBs 	 	:= {}
Private aCrDBR 	 	:= {}
Private aRot 	 	:= {}
Private aRotCmb  	:= {}
Private aCrDie	  	:= {}
Private aCrDieR		:= {}
Private aDadRD1		:= {}
Private aRotD1		:= {}
//Querys
Private oRtMain := nil
Private oCorDie := nil 
Private oCorRot := nil 
Private oProRot := nil 

Private aDadTl             := {} //Dados dos currais em linhas
Private aDdTlC             := {} //Dados dos currais em pastos
Private aLinCnf            := {}
Private aLinPst            := {}
Private aCurLin            := {}
Private aCurPst            := {}
Private nTotTrt            := 0
Private nQtdTrt            := 0
Private _cCurral           := ""
Private _NroCurral         := 0

Private aClsRes            := {}
Private aClsRTr            := {}
Private oGrdRes, oGrdRTr
Private nTotCur            := 0
Private nTotCRt            := 0

Private nTotCSR            := 0

Private aDadRotZao         := {}
Private nContSelCur 	   := 0

aDadSel := {"ROTA01", dDataBase, "0001", ""}

U_PosSX1({{cPrgRot, "01", dDataBase}})

While ((nOpcRotas > 0))

	If (Len(aParRet) < 1)
		If (!Pergunte(cPrgRot, .T.))
			Return (Nil)
		EndIf
		__dDtPergunte := MV_PAR01
		
		AAdd(aParRet, MV_PAR01)
	EndIf

	cQry := " SELECT MAX(Z0R.Z0R_VERSAO) AS DATVER" + CRLF
	cQry += " FROM " + RetSqlName("Z0R") + " Z0R " + CRLF
	cQry += " WHERE Z0R.Z0R_FILIAL = '" + xFilial("Z0R") + "' " + CRLF
	cQry += "   AND Z0R.Z0R_DATA = '" + DTOS(aParRet[1]) + "' "
	cQry += "   AND Z0R.D_E_L_E_T_ = ' ' " + CRLF
	
	cALias := MpSysOpenQuery(cQry)
	
	If (!((cAlias)->(EOF())))
		If (!Empty((cAlias)->DATVER))
			aDadSel[3] := (cAlias)->DATVER
		EndIf
	EndIf
	
	(cAlias)->(DBCloseArea())
	
	if lConstroi
		aDadSel[2] := aParRet[1]

		VAPCPA09A(lShwZer, lShwGer)
		lConstroi := .F. 
	endif

	If (Len(aParRet) > 0)
		VAPCPA09B(lShwZer, lShwGer)
	Else
		nOpcRotas := 0
	EndIf
EndDo

Return (Nil)

Static Function VAPCPA09A(lPShwZer, lPShwGer)
	Local nCrAux := 1
	Local aInSQL := {}

	MontaQuery(lShwZer, lShwGer)

	cQry := " SELECT Z08_CONFNA FROM "+RetSqlName("Z08")+"   " + CRLF
 	cQry += "WHERE Z08_FILIAL = '"+FwXFilial("Z08")+"' " + CRLF
 	cQry += "AND D_E_L_E_T_ = ' '  " + CRLF
 	cQry += "AND Z08_CONFNA <> '' " + CRLF
 	cQry += "GROUP BY Z08_CONFNA  " + CRLF

	cAlias := MpSysOpenQuery(cQry)
	while !(cAlias)->(EOF())
		AAdd(aInSQL, rTrim((cAlias)->Z08_CONFNA))
		(cAlias)->(DBSkip())
	Enddo
	(cAlias)->(DbCloseArea())

	//ADICIONAR 99
	dbSelectArea("Z05")
	Z05->(DBSetOrder(1))
	If (!Z05->(DBSeek(xFilial("Z05") + DTOS(aDadSel[2]) + aDadSel[3])))
		
		If (MsgYesNo("Nao foi identificado nenhum trato para a data " + DTOC(aDadSel[2]) + ". Deseja criar?", "Trato nao encontrado."))
			//----------------------------
			//Cria o trato caso necessário
			//----------------------------
			FWMsgRun(, { || U_CriaTrat(aDadSel[2])}, "Geracao de trato", "Gerando trato para o dia " + DTOC(aDadSel[2]) + "...")
			if (!Z05->(DBSeek(xFilial("Z05") + DTOS(aDadSel[2]) + aDadSel[3])))
				nOpcRotas := 0
				Return (Nil)
			endif
		Else
			Help(,,"SELECAO DE TRATO",/**/,"Nao existe trato para o dia " + DTOC(aDadSel[2]) + ". ", 1, 1,,,,,.F.,{"Por favor, crie o trato para prosseguir." })
			nOpcRotas := 0
			Return (Nil)
		EndIf
	EndIf

	AAdd(aCorTl, &("U_CORROTA(" + GETMV("VA_ROTBCKG") + ")")) // cor de fundo das abas
	AAdd(aCorTl, &("U_CORROTA(" + GETMV("VA_ROTBLIN") + ")")) // cor de fundo das linhas
	AAdd(aCorTl, &("U_CORROTA(" + GETMV("VA_ROTBCUR") + ")")) // cor de fundo dos currais
	AAdd(aCorTl, &("U_CORROTA(" + GETMV("VA_ROTFTLC") + ")")) // cor fonte letra linha e numero curral
	AAdd(aCorTl, &("U_CORROTA(" + GETMV("VA_ROTFCUR") + ")")) // cor fonte conteudo curral
	AAdd(aCorTl, &("U_CORROTA(" + GETMV("VA_ROTCSEL") + ")")) // cor fonte curral selecionado

	SX6->(DBSetOrder(1))
	While (SX6->(DBSeek(xFilial("SX6") + "VA_CRDIE" + StrZero(nCrAux,2))))
		AAdd(aCrDBs, &("U_CORROTA(" + GETMV("VA_CRDIE" + StrZero(nCrAux,2)) + ")")) //01 // 077, 074, 060
		AAdd(aCrDBR, ALLTRIM(GETMV("VA_CRDIE" + StrZero(nCrAux,2))) ) //01 // 077, 074, 060
		nCrAux++
	EndDo

	ZRT->(DBSetOrder(1))
	ZRT->(DBGoTop())

	While (!(ZRT->(EOF())))
		If (aScan(aRot , { |x| x[1] == ZRT->ZRT_ROTA }) < 1)
			AAdd(aRot, {ZRT->ZRT_ROTA, &("U_CORROTA(" + ZRT->ZRT_COR + ")"),Alltrim(ZRT->ZRT_COR)})
			AAdd(aRotCmb, ZRT->ZRT_ROTA)
		EndIf
		ZRT->(DBSkip())
	EndDo

	//oCorDie 
	oCorDie:SetIn(1,aInSQL)
	cAlias := oCorDie:OpenAlias()
	nCrAux  := 1
	While !((cALias)->(EOF()))

		aAdd( aDadRotZao, { AllTrim((cALias)->CURRAL),;  // 01
							AllTrim((cALias)->LOTE)  ,;  // 02
							(cALias)->QTD_POR_TRATO  ,;  // 03
							AllTrim((cALias)->DIETA) ,;  // 04
							.F.					  } ) 	// 05
		If (aScan(aCrDie , { |x| x[1] == (cALias)->DIETA}) == 0)
			If (nCrAux < Len(aCrDBs))
				// https://shdo.wordpress.com/online/tabela-de-cores-rgb/
				AAdd(aCrDie , { (cALias)->DIETA, aCrDBs[nCrAux] })
				AAdd(aCrDieR, { (cALias)->DIETA, aCrDBR[nCrAux] })
				nCrAux++
			Else
				MsgInfo("Nao existem mais cores disponiveis para as dietas! (VA_CRDIEXX). Abortando...")
				nOpcRotas := 0
				Return (Nil)
			EndIf
		EndIf

		(cALias)->(DBSkip())
	EndDo
	(cALias)->(DBCloseArea())
	
	//oCorRot
	oCorRot:SetIn(1,aInSQL)
	cAlias := oCorRot:OpenAlias()

	While (!(cAlias)->(EOF()))
		AAdd(aDadRD1, {ALLTRIM((cAlias)->LOTE), (cAlias)->CONF, (cAlias)->LINHA, (cAlias)->SEQ, (cAlias)->Z08_CODIGO, (cAlias)->DIETA, (cAlias)->ROTA, (cAlias)->KGMN})
		(cAlias)->(DBSkip())
	EndDo
	(cAlias)->(DBCloseArea())

Return

Static Function VAPCPA09B(lPShwZer, lPShwGer)
	Local dDtRD1        := dDataBase
	Local cRotAux       := ""
	Local lParRotD1     := GETMV("VA_ROTD1")
	Local nCntLin := 3, nCntCur := 3
	Local cQry              	:= ""
	Local nChvCnf              := 0
	Local nChvCur              := 0
	Local nCntAll              := 0
	Local nRtAux               := 0
	Local cChvCnf, cChvLin
	Local cShwZer              := ""
	Local aSize                := {}, aObjects := {}, aInfo := {}, aPObjs := {}
	Local aTFldr               := {}
	Local nLinLin              := 001
	Local aScrCnf              := {}
	Local aPnlCnf              := {}
	Local nCurLin, nCurCol
	Local aPnlRot              := {}
	Local cDscDie              := ""
	Local cLote                := ""
	Local cLtCur               := ""
	Local cPlCur               := ""
	Local cDiCur               := ""
	Local nCrFnt               := .F.
	Local nCrAux               := 1
	Local nIndPRt              := 1
	Local dDtTrt               := aDadSel[2]
	Local cRotTrt              := aDadSel[1]
	Local aHdrRes              := {}
	Local aHdrRTr              := {}
	Local oTSTotTr/*, oTSChgCur, oTSChgDie*/
	Local oTCRot
	Local aInSQL 				:= {}
	Local lSplitter 			:= .T.

	aLinCnf := {}
	aCurLin := {}
	aLinCnf := {}

	cQry := " SELECT Z08_CONFNA FROM "+RetSqlName("Z08")+"   " + CRLF
 	cQry += "WHERE Z08_FILIAL = '"+FwXFilial("Z08")+"' " + CRLF
 	cQry += "AND D_E_L_E_T_ = ' '  " + CRLF
 	cQry += "AND Z08_CONFNA <> '99' " + CRLF
 	cQry += "AND Z08_CONFNA <> '' " + CRLF
 	cQry += "GROUP BY Z08_CONFNA  " + CRLF

	cAlias := MpSysOpenQuery(cQry)
	while !(cAlias)->(EOF())
		AAdd(aTFldr, "CONFINAMENTO " + rTrim((cAlias)->Z08_CONFNA))
		AAdd(aInSQL, rTrim((cAlias)->Z08_CONFNA))
		(cAlias)->(DBSkip())
	Enddo
	(cAlias)->(DbCloseArea())

	AAdd(aTFldr, "VISAO GERAL")
	AAdd(aTFldr, "PASTO")
	AAdd(aTFldr, "RESUMO")

	if Empty((aDadSel[4]))
		aDadSel[4] := StrZero(Len(aTFldr) - 2,2)
	endif

	if Val(aDadSel[4]) == Len(aTFldr) - 2
		aAdd(aInSQL,"99")
	elseif Val(aDadSel[4]) == Len(aTFldr) - 1
		aInSQL := {"99"}
	else
		aInSQL := {aDadSel[4]}
	endif

	aSize := MsAdvSize(.T.)
	aObjects := {}

	AAdd( aObjects, { aSize[5], aSize[6], .F., .F. })

	aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
	aPObjs := MsObjSize(aInfo, aObjects, .T.)

	//Montar query apenas de acordo com aba selecionada
	oRtMain:SetIn(1,aInSQL)
	cAlias := oRtMain:OpenAlias()

	nCrAux  := 1
	nLinLeg := 030
	nChvCnf := 0
	aDadTl := {}
	aDdTlC := {}

	//Verificar quantos paineis serão criados para calcular o tamanho das linhas.
	nLenPanel := Len(aInSQL)

	While !((cAlias)->(EOF()))
		If (cChvCnf != (cAlias)->CONF)
			
			nChvFol := Val((cAlias)->CONF)
			
			aadd(aDadTl, {(cAlias)->CONF,++nChvCnf,nChvFol})
			nLinCnf := Len(aDadTl)
			cChvCnf := (cAlias)->CONF

			AAdd(aDadTl[nLinCnf], {(cAlias)->LINHA})

			nLinCur := Len(aDadTl[nLinCnf])
			cChvLin := (cAlias)->LINHA
			If (aScan(aLinAlf, { |x| x = (cAlias)->LINHA}) = 0)
				AAdd(aLinAlf, (cAlias)->LINHA)
			EndIf
			
			AAdd(aDadTl[nLinCnf][nLinCur], {(cAlias)->SEQ, ALLTRIM((cAlias)->LOTE), (cAlias)->QUANT, (cAlias)->PLANO, (cAlias)->DIAS, (cAlias)->DIETA, IIf((cAlias)->DIAS = 1, (cAlias)->KGMN, (cAlias)->KGMNDIA ), IIf((cAlias)->DIAS == 1, (cAlias)->KGMS, (cAlias)->KGMSDIA ), (cAlias)->ROTA, (cAlias)->CONF, (cAlias)->Z08_CODIGO, (cAlias)->DIEDSC})
		Else
			//Verificar quantos paineis serão criados para calcular o tamanho das linhas.
			if nLenPanel > 1
				lQuebra := 35 * LEN(aDadTl[nLinCnf][nLinCur]) > ((aPObjs[1][4]/2) / nLenPanel )  - 20
			else
				lQuebra := 70 * LEN(aDadTl[nLinCnf][nLinCur]) > (aPObjs[1][4]/2) - 20
			endif

			IF lQuebra
				AAdd(aDadTl[nLinCnf], {(cAlias)->LINHA})
				nLinCur := Len(aDadTl[nLinCnf])
				cChvLin := (cAlias)->LINHA
				If (aScan(aLinAlf, { |x| x = (cAlias)->LINHA}) = 0)
					AAdd(aLinAlf, (cAlias)->LINHA)
				EndIf
				AAdd(aDadTl[nLinCnf][nLinCur], {(cAlias)->SEQ, ALLTRIM((cAlias)->LOTE), (cAlias)->QUANT, (cAlias)->PLANO, (cAlias)->DIAS, (cAlias)->DIETA, IIf((cAlias)->DIAS = 1, (cAlias)->KGMN, (cAlias)->KGMNDIA ), IIf((cAlias)->DIAS == 1, (cAlias)->KGMS, (cAlias)->KGMSDIA ), (cAlias)->ROTA, (cAlias)->CONF, (cAlias)->Z08_CODIGO, (cAlias)->DIEDSC})
			ELSE
				If (cChvLin != (cAlias)->LINHA)
					AAdd(aDadTl[nLinCnf], {(cAlias)->LINHA})
					nLinCur := Len(aDadTl[nLinCnf])
					cChvLin := (cAlias)->LINHA
					If (aScan(aLinAlf, { |x| x == (cAlias)->LINHA}) == 0)
						AAdd(aLinAlf, (cAlias)->LINHA)
					EndIf
					AAdd(aDadTl[nLinCnf][nLinCur], {(cAlias)->SEQ, ALLTRIM((cAlias)->LOTE), (cAlias)->QUANT, (cAlias)->PLANO, (cAlias)->DIAS, (cAlias)->DIETA, IIf((cAlias)->DIAS = 1, (cAlias)->KGMN, (cAlias)->KGMNDIA ), IIf((cAlias)->DIAS == 1, (cAlias)->KGMS, (cAlias)->KGMSDIA ), (cAlias)->ROTA, (cAlias)->CONF, (cAlias)->Z08_CODIGO, (cAlias)->DIEDSC})
				Else	
					AAdd(aDadTl[nLinCnf][nLinCur], {(cAlias)->SEQ, ALLTRIM((cAlias)->LOTE), (cAlias)->QUANT, (cAlias)->PLANO, (cAlias)->DIAS, (cAlias)->DIETA, IIf((cAlias)->DIAS = 1, (cAlias)->KGMN, (cAlias)->KGMNDIA ), IIf((cAlias)->DIAS == 1, (cAlias)->KGMS, (cAlias)->KGMSDIA ), (cAlias)->ROTA, (cAlias)->CONF, (cAlias)->Z08_CODIGO, (cAlias)->DIEDSC})
				EndIf
			EndIf
		EndIf
		
		If (!Empty((cAlias)->ROTA))
			nTotCRt := nTotCRt + 1
		EndIf

		nTotCur := nTotCur + 1

		(cAlias)->(DBSkip())
	EndDo
	(cAlias)->(DBCloseArea())

	cAlias := oProRot:OpenAlias()

	Z0S->(DBSetOrder(1))
	If (!(Z0S->(DBSeek(xFilial("Z0S") + DTOS(aDadSel[2]) + aDadSel[3])))) //+aDadSel[1]
		If (Z0S->(DBSeek(xFilial("Z0S") + DTOS(DaySub(aDadSel[2],1)) + aDadSel[3])))
			
			dDtRD1 := Z0S->Z0S_DATA
			
			While (Z0S->Z0S_DATA == dDtRD1 .AND. Z0S->Z0S_VERSAO == aDadSel[3])
				While (!(cALias)->(EOF())) // ADICIOANR REGISTROS
					AAdd(aRotD1, {(cALias)->ROTA, (cALias)->EQUIP, 0, (cALias)->DIETA, (cALias)->OPERAD})
					(cALias)->(DBSkip())
				EndDo
				Z0S->(DbCloseArea())
			EndDo
		Else
			For nCntAll := 1 To Len(aRot)
				AAdd(aRotD1, {aRot[nCntAll][1], Space(6), 0, Space(20), Space(30)})
			Next nCntAll    
		EndIf

		For nCntAll := 1 To Len(aRotD1)
		
			RecLock("Z0S", .T.)
				Z0S->Z0S_FILIAL := xFilial("Z0S")
				Z0S->Z0S_DATA   := aDadSel[2]
				Z0S->Z0S_VERSAO := aDadSel[3]
				Z0S->Z0S_ROTA   := aRotD1[nCntAll][1] //aDadSel[1]
				Z0S->Z0S_EQUIP  := aRotD1[nCntAll][2]
				Z0S->Z0S_TOTTRT := aRotD1[nCntAll][3]
				Z0S->Z0S_DIETA  := aRotD1[nCntAll][4]
				Z0S->Z0S_OPERAD := aRotD1[nCntAll][5]		
			Z0S->(MSUnlock())

		Next nCntAll
		
		nTotTrt := 0
		DBSelectArea("Z0T")
		
		If (!(Z0T->(DBSeek(xFilial("Z0T")+DTOS(aDadSel[2])+aDadSel[3]))))
		
			For nCntAll := 1 To Len(aDadTl)
			
				For nCntLin := 4 To Len(aDadTl[nCntAll])
				
					If (cChvLin != aDadTl[nCntAll][nCntLin][01])
						cChvLin := aDadTl[nCntAll][nCntLin][01]
					EndIf
				
					For nCntCur := 2 To Len(aDadTl[nCntAll][nCntLin])

						lRotD1 := .T.
						If ((nRtAux := aScan(aDadRD1, { |x| x[1] = aDadTl[nCntAll][nCntLin][nCntCur][02]})) > 0)
							If (ALLTRIM(aDadRD1[nRtAux][05]) != ALLTRIM(aDadTl[nCntAll][nCntLin][nCntCur][11]))
								If (!lParRotD1) 
									lRotD1 := .F.
								EndIf
							EndIf
							
							If (ALLTRIM(aDadRD1[nRtAux][06]) != ALLTRIM(aDadTl[nCntAll][nCntLin][nCntCur][06]))
								If (!lParRotD1)
									lRotD1 := .F.
								EndIf
							EndIf
						EndIf
						
						If (nRtAux > 0)
							If (lRotD1)
								cRotAux := aDadRD1[nRtAux][07] 
							Else
								cRotAux := Space(6)
							EndIf
						Else
							cRotAux := Space(6)
						EndIf
					
						RecLock("Z0T", .T.)
							Z0T->Z0T_FILIAL := xFilial("Z0T")
							Z0T->Z0T_DATA   := aDadSel[2]
							Z0T->Z0T_VERSAO := aDadSel[3]
							Z0T->Z0T_ROTA   := cRotAux
							Z0T->Z0T_CONF   := aDadTl[nCntAll][01]
							Z0T->Z0T_LINHA  := cChvLin
							Z0T->Z0T_SEQUEN := aDadTl[nCntAll][nCntLin][nCntCur][01]
							Z0T->Z0T_CURRAL := aDadTl[nCntAll][nCntLin][nCntCur][11]
							Z0T->Z0T_LOTE   := aDadTl[nCntAll][nCntLin][nCntCur][02]
						Z0T->(MSUnlock())
						
						If (lRotD1)
							If (Z0S->(DBSeek(xFilial("Z0S") + DTOS(aDadSel[2]) + aDadSel[3] + cRotAux)))
								RecLock("Z0S", .F.)
									Z0S->Z0S_TOTTRT := Z0S->Z0S_TOTTRT + aDadRD1[nRtAux][08]
								Z0S->(MSUnlock())
							EndIf
							
							aDadTl[nCntAll][nCntLin][nCntCur][09] := aDadRD1[nRtAux][07]
						EndIf
					Next nCntCur
				Next nCntLin
			Next nCntAll
		EndIf
	ElseIf (Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+aDadSel[1])))
		nTotTrt := Z0S->Z0S_TOTTRT
	Else
		nTotTrt := 0
	EndIf
	(cALias)->(DbCloseArea())

	nTotCSR := nTotCur - nTotCRt
	
	Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+aDadSel[1]))
	nTotTrt := Z0S->Z0S_TOTTRT

	SetKey(VK_F2, {|| ShwCur()})
	SetKey(VK_F4, {|| ShwChg()})
	SetKey(VK_F12, {|| ShwLeg()})

	If (lPShwZer)
		cShwZer := "Esconde Zerados ?"
	Else
		cShwZer := "Mostra Zerados ?"
	EndIf

	oTFntGr := TFont():New('Courier new',,14,.T.,.T.)
	oTFntLC := TFont():New('Courier new',,18,.T.,.T.)
	oTFntPs := TFont():New('Courier new',,16,.T.,.T.)
	oTFntSb := TFont():New('Courier new',,14,.T.,.T.,,,,,.T.)

	if (nPos := aScan(aDadTl,{ |x| Alltrim(x[1]) == "99"})) > 0 
		aDadTl[nPos][3] := Len(aTFldr) - 1
	endif

	nColLeg 	:= (aPObjs[1][4]/2) - 080 - 20 //nColLeg := aSize[6] - 460
	aOperador 	:= StrTokArr(GetMV("MV_OPERADO") + ";",";")
	cOper1 		:= AllTrim(Posicione("Z0U",1,xFilial("Z0U")+aOperador[1],"Z0U_NOME"))
	cOper2 		:= AllTrim(Posicione("Z0U",1,xFilial("Z0U")+aOperador[2],"Z0U_NOME"))

	DEFINE MSDIALOG oDlgRotas TITLE OemToAnsi("Rotas do Trato") From aPObjs[1][1], aPObjs[1][2] To aPObjs[1][3], aPObjs[1][4] of oDlgRotas PIXEL 

		oTSTotTr := TSay():New(001, (aPObjs[1][4]/2) - 250, {|| "Operador 1: "+AllTrim(cOper1)+" / Operador 2: "+AllTrim(cOper2)}, oDlgRotas,,oTFntLg,,,,.T., CLR_RED, CLR_WHITE, 200, 20)
		oTSTotTr:SetCss("background-color: RGB(255, 255, 255); color: RGB(255,2,0);")

		TSay():New(005, 005, {|| "Data Trato"}, oDlgRotas,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
		TGet():New(015, 005, {|| dDtTrt}, oDlgRotas, 100, 016, "@D",,,,oTFntGr,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"dDtTrt")
	
		TSay():New(005, 110, {|| "Rotas"}, oDlgRotas,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
		oTCRot := TComboBox():New(015, 110, {|u| iIf(PCount() == 0, cRotTrt, cRotTrt := u)}, aRotCmb, 100, 20, oDlgRotas,,,, CLR_BLACK, CLR_WHITE,.T.,,,,,,,,,"cRotTrt")
		oTCRot:bChange := {|| aDadSel[1] := cRotTrt, nOpcRotas := 3, oDlgRotas:End()}
	
		_nLin := 35
		TSay():New(_nLin, nCol:=005, {|| "Total Selecionado Trato:"}, oDlgRotas,,oTFntLg,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
		oTSTotTr := TSay():New(_nLin, nCol+=110, {|| TRANSFORM(nTotTrt, "@E 999,999,999.99")}, oDlgRotas,,oTFntLg,,,,.T., CLR_RED, CLR_WHITE, 200, 20)
		oTSTotTr:SetCss("background-color: RGB(255, 255, 255); color: RGB(255,2,0);")

		nQtdTrt := fQtdTrato(aParRet[1], aDadSel[1])
		TSay():New(_nLin, nCol+=65, {|| "Qtd de Tratos:"}, oDlgRotas,,oTFntLg,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
		oTSTotTr := TSay():New(_nLin, nCol+60, {|| TRANSFORM(nQtdTrt, "@E 99")}, oDlgRotas,,oTFntLg,,,,.T., CLR_RED, CLR_WHITE, 200, 20)
		oTSTotTr:SetCss("background-color: RGB(255, 255, 255); color: RGB(255,2,0);")

		_cCurral := fLoadCurrais(aParRet[1], aDadSel[1])
		_nLin := 45
		TSay():New(_nLin, 005, {|| "Currais Selecionados:"}, oDlgRotas,,oTFntLg,,,,.T.		, CLR_BLACK	, CLR_WHITE, 200, 20)
		oTSTotTr := TSay():New(_nLin, 100, {|| AllTrim(_cCurral)}, oDlgRotas,,oTFntLg,,,,.T., CLR_RED	, CLR_WHITE, 260, 30)
		oTSTotTr:SetCss("background-color: RGB(255, 255, 255); color: RGB(255,2,0);")
	
		tButton():New(010, (aPObjs[1][4]/2) - 280, "Sugerir Rotas"      , oDlgRotas, {|| nOpcRotas := 3, SugRotas(), oDlgRotas:End()}, 60, 15,,,, .T.) // "Cria\Recria Trato"
		tButton():New(010, (aPObjs[1][4]/2) - 220, "Zerar Rota"       , oDlgRotas, {|| nOpcRotas := 3, ZERROT(), oDlgRotas:End()}, 60, 15,,,, .T.) // "Cria\Recria Trato"
		tButton():New(010, (aPObjs[1][4]/2) - 160, "Operador Pá"       , oDlgRotas, {|| nOpcRotas := 3, U_ALTOPER(), oDlgRotas:End()}, 60, 15,,,, .T.) // "Cria\Recria Trato"
		tButton():New(010, (aPObjs[1][4]/2) - 100, cShwZer            , oDlgRotas, {|| nOpcRotas := 1, oDlgRotas:End()}          , 60, 15,,,, .T.) // "Mostra Zerados ?" "Esconde Zerados ?"
		tButton():New(010, (aPObjs[1][4]/2) - 040, "Fechar"           , oDlgRotas, {|| nOpcRotas := 0, oDlgRotas:End()}          , 32, 15,,,,.T.) // "Fechar"

		nColDieta := 1
		For nCntAll := 1 To Len(aCrDie)
		
			If (Empty(aCrDie[nCntAll][1]))
				cDscDie := "SEM DIETA"
			Else
				cDscDie := aCrDie[nCntAll][1] //IIf(POSICIONE("SB1", 1, xFilial("SB1") + aCrDie[nCntAll][1], "B1_DESC"), SB1->B1_DESC, aCrDie[nCntAll][1])
			EndIf
			
			If nColDieta == 1
				oTSRacH := TSay():New(nLinLeg, nColLeg-(90*3), &("{|| '" + ALLTRIM(cDscDie) + "'}"), oDlgRotas,,oTFntLgT,,,,.T.,;
								aCrDie[nCntAll][2], CLR_WHITE, 140, 15)
				oTSRacH:SetCss("color: RGB("+aCrDieR[nCntAll][2]+");")
				nColDieta++
			ElseIf nColDieta == 2
				oTSRacH := TSay():New(nLinLeg, nColLeg-(90*2), &("{|| '" + ALLTRIM(cDscDie) + "'}"), oDlgRotas,,oTFntLgT,,,,.T.,;
							aCrDie[nCntAll][2], CLR_WHITE, 140, 15)
				oTSRacH:SetCss("color: RGB("+aCrDieR[nCntAll][2]+");")
				nColDieta++
			ElseIf nColDieta == 3
				oTSRacH := TSay():New(nLinLeg, nColLeg-(90*1), &("{|| '" + ALLTRIM(cDscDie) + "'}"), oDlgRotas,,oTFntLgT,,,,.T.,;
							aCrDie[nCntAll][2], CLR_WHITE, 140, 15)
				oTSRacH:SetCss("color: RGB("+aCrDieR[nCntAll][2]+");")
				nColDieta++
			Else
				oTSRacH :=TSay():New(nLinLeg, nColLeg, &("{|| '" + ALLTRIM(cDscDie) + "'}"), oDlgRotas,,oTFntLgT,,,,.T.,;
							aCrDie[nCntAll][2], CLR_WHITE, 140, 15)
				oTSRacH:SetCss("color: RGB("+aCrDieR[nCntAll][2]+");")
				nColDieta := 1
				nLinLeg += 009
			EndIf
		
		Next nCntAll
		
		nLinLeg += 20
		
		Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+aDadSel[1]))
	
		oTFldr := TFolder():New(070, 000, aTFldr,, oDlgRotas, VAL(aDadSel[4]),,, .T.,, (aPObjs[1][4]/2),  (aPObjs[1][3]/2))
		oTFldr:bChange := {|| IIf(U_CRRGABA(oTFldr:nOption), oDlgRotas:End(), .T.)}
		oTFldr:SetOption(VAL(aDadSel[4]))

		// Monta as abas e conteudo dos CONFINAMENTOS
		For nCntAll := 1 To Len(aDadTl)
			
			nCntLin := 2
			nLinLin := 010
			nCurLin := 005
			nCurCol := 005

			If (cChvCnf != aDadTl[nCntAll][01]) .OR. Empty(aPnlRot) //27-05-2022
				cChvCnf := aDadTl[nCntAll][01]
				cChvLin := ""
				nChvCnf := aDadTl[nCntAll][02]
				nChvFol := aDadTl[nCntAll][03]

				If (lPShwGer)
					if lSplitter
						oSplitter := tSplitter():New( 005,;
													((((aPObjs[1][4]/2)/Len(aDadTl))) * Len(aPnlRot)) + 10,;
													oTFldr:aDialogs[Len(oTFldr:aDialogs) - 2],;
													aInfo[3],;
													aInfo[4] )
						lSplitter := .F.
					endif
					AAdd(aScrCnf, TScrollArea():New(oSplitter, 005, ((((aPObjs[1][4]/2)/Len(aDadTl))) * Len(aPnlRot)) + 10, (aPObjs[1][3]/2) - 150, (((aPObjs[1][4]/2)/Len(aDadTl))), .T., .T.))
					
					oPanel := nil 
					oPanel := TPanel():New(010, ((((aPObjs[1][4]/2)/Len(aDadTl))) * Len(aPnlRot)) + 10, iif(cChvCnf == "99","RECEPÇÃO",aTFldr[nChvCnf]), aScrCnf[nChvCnf], oTFntTC, .F.,, aCorTl[4], aCorTl[1], (((aPObjs[1][4]/2)/Len(aDadTl))), (065 * (Len(aDadTl[nCntAll]))) - 015)
					oPanel:SetCss("background-color: RGB(255, 255, 255);")
					
					AAdd(aPnlRot, oPanel)
					AAdd(aLinCnf, {})
					AAdd(aCurLin, {})
					nIndPRt := Len(aPnlRot)
					
					aScrCnf[nChvCnf]:SetFrame(aPnlRot[nIndPRt])
					
					nLinLin := 020
				Else
					AAdd(aScrCnf, TScrollArea():New(oTFldr:aDialogs[nChvFol], 001, 001, (aPObjs[1][3]/2), (aPObjs[1][4]/2), .T., .T.)) 
					
					oPanel := nil 
					oPanel := TPanel():New(001, 001,, aScrCnf[nChvCnf], oTFntGr, .T.,, aCorTl[4], aCorTl[1], (aPObjs[1][4]/2), (160 * (Len(aDadTl[nCntAll]) + 1)))
					oPanel:SetCss("background-color: RGB(255, 255, 255);")

					AAdd(aPnlCnf, oPanel)//
					AAdd(aLinCnf, {})
					AAdd(aCurLin, {})
					
					aScrCnf[nChvCnf]:SetFrame(aPnlCnf[nChvCnf])
				EndIf
			EndIf
			
			For nCntLin := 4 To Len(aDadTl[nCntAll])
			
				cChvLin := aDadTl[nCntAll][nCntLin][01]
				
				if Len(Alltrim(cChvLin)) > 1
					nSpacePanel := 50
				else
					nSpacePanel := 10
				endif

				If (lPShwGer)
					oPanel := nil
					oPanel := TPanel():New(nLinLin, 005, ALLTRIM(cChvLin), aPnlRot[nIndPRt], oTFntLC, .T.,, aCorTl[4], aCorTl[1], nSpacePanel, 040)
					oPanel:SetCss("background-color: RGB(255, 255, 255);")

					AAdd(aLinCnf[nChvCnf], oPanel) //painel inicio da linha
					
					aLinCnf[nChvCnf][Len(aLinCnf[nChvCnf])]:bLClicked := &("{|| (U_SelLin('" + cChvCnf + "', '" + STR(nCntLin - 3) + "'))}")

					oPanel := nil
					oPanel := TPanel():New(nLinLin, nSpacePanel+5,, aPnlRot[nIndPRt], oTFntGr, .T.,, aCorTl[4], aCorTl[2], (030 * (Len(aDadTl[nCntAll][nCntLin]) - 1)) + 001, 040)
					oPanel:SetCss("background-color: rgb(054, 054, 054);")

										//linha inicial, coluna inicial                                       //tamanho coluna, tamanho linha
					AAdd(aLinCnf[nChvCnf], oPanel) //painel da linha
					AAdd(aCurLin[nChvCnf], {})
				Else
					oPanel := nil
					oPanel := TPanel():New(nLinLin, 005, ALLTRIM(cChvLin), aPnlCnf[nChvCnf], oTFntLC, .T.,, aCorTl[4], aCorTl[1], nSpacePanel, 090)
					oPanel:SetCss("background-color: RGB(255, 255, 255);")

					AAdd(aLinCnf[nChvCnf], oPanel) //painel inicio da linha
					
					aLinCnf[nChvCnf][Len(aLinCnf[nChvCnf])]:bLClicked := &("{|| (U_SelLin('" + cChvCnf + "', '" + STR(nCntLin - 3) + "'))}")
					
					oPanel := nil
					oPanel := TPanel():New(nLinLin, nSpacePanel+5,, aPnlCnf[nChvCnf], oTFntGr, .T.,, aCorTl[4], aCorTl[2], (065 * (Len(aDadTl[nCntAll][nCntLin]) - 1)) + 005, 090)
					oPanel:SetCss("background-color: rgb(054, 054, 054);")

											//linha inicial, coluna inicial                                       //tamanho coluna, tamanho linha
					AAdd(aLinCnf[nChvCnf], oPanel) //painel da linha
					AAdd(aCurLin[nChvCnf], {})
				EndIf
					
				For nCntCur := 2 To Len(aDadTl[nCntAll][nCntLin])
					
					cLote  := aDadTl[nCntAll][nCntLin][nCntCur][02]
					cLtCur := aDadTl[nCntAll][nCntLin][nCntCur][09] + "' + Chr(10) + '" + aDadTl[nCntAll][nCntLin][nCntCur][02]
					cQtCab := ALLTRIM(STR(aDadTl[nCntAll][nCntLin][nCntCur][03], 4)) + "' + Chr(10) + '"
					cPlCur := ALLTRIM(aDadTl[nCntAll][nCntLin][nCntCur][12]) + "' + Chr(10) + '" + ALLTRIM(STR(aDadTl[nCntAll][nCntLin][nCntCur][05])) + "' + Chr(10) + '" + TRANSFORM((aDadTl[nCntAll][nCntLin][nCntCur][07] * aDadTl[nCntAll][nCntLin][nCntCur][03]), "@E 999,999.99")
					cDiCur := aDadTl[nCntAll][nCntLin][nCntCur][06]

					If(aDadTl[nCntAll][nCntLin][nCntCur][09] == aDadSel[1])
						if (aScan(aRot, {|x| x[1] = aDadSel[1]}) == 0)
							nCrFnt := CLR_WHITE
						Else
							nCrFnt := aRot[aScan(aRot, {|x| x[1] == aDadSel[1]})][2] //aCorTl[6]
							cCrFnt := aRot[aScan(aRot, {|x| x[1] == aDadSel[1]})][3] //aCorTl[6]
						EndIf
					ElseIf (Empty(aDadTl[nCntAll][nCntLin][nCntCur][09]))
						nCrFnt := CLR_WHITE //aCorTl[4]
					Else
						nCrFnt := CLR_WHITE//aRot[aScan(aRot, {|x| x[1] = aDadTl[nCntAll][nCntLin][nCntCur][09]})][2] //CLR_RED
					EndIf
					
					nCrAux := aScan(aCrDie, {|x| x[1] = cDiCur})
					
					// aba resumo
					If (lPShwGer)
						
						oPanel := nil 
						oPanel := TPanel():New(000, nCurCol-005, aDadTl[nCntAll][nCntLin][nCntCur][01], aLinCnf[nChvCnf][Len(aLinCnf[nChvCnf])], oTFntLC, .T.,, IIf(nCrFnt = CLR_WHITE, CLR_BLACK, CLR_WHITE)/*nCrFnt*/, nCrFnt/*aCorTl[1]*/, 032, 010)
						oPanel:SetCss("background-color: RGB("+IIF(nCrFnt == CLR_WHITE, "255,255,255" ,cCrFnt)+");")
						AAdd(aCurLin[nChvCnf][nCntLin - 3], oPanel) //cabecalho curral com o numero

						oPanel := nil
						oPanel := TPanel():New(012, nCurCol-003,, aLinCnf[nChvCnf][Len(aLinCnf[nChvCnf])], oTFntGr, .T.,, aCorTl[5], IIf(cLtCur = 'SEM LOTE' .OR. nCrAux < 1, CLR_GRAY, aCrDie[nCrAux][2]), 026, 026)
						IF cLtCur == 'SEM LOTE' .OR. nCrAux < 1 // CLR_GRAY
							oPanel:SetCss("background-color: RGB(169,169,169);")
						ELSE //aCrDie[nCrAux][2]
							oPanel:SetCss("background-color: RGB("+aCrDieR[nCrAux][2]+");")
						ENDIF
						AAdd(aCurLin[nChvCnf][nCntLin - 3], oPanel) //interior do curral onde sao apresentados os dados
						
						nChvCur := Len(aCurLin[nChvCnf][nCntLin - 3])
						
						If (cQtCab != '0')
						
							cLtCur += "' + Chr(10) + '" + cQtCab + ALLTRIM(STR(aDadTl[nCntAll][nCntLin][nCntCur][05]))
							oSay := nil
							oSay := TSay():New(002, 002, &("{|| '" + cLtCur + "'}"), aCurLin[nChvCnf][nCntLin - 3][nChvCur],,oTFntPs,,,,.T., aCorTl[5], IIf(cLtCur = 'SEM LOTE' .OR. nCrAux < 1, CLR_GRAY, aCrDie[nCrAux][2]), 200, 050)
							IF cLtCur == 'SEM LOTE' .OR. nCrAux < 1 // CLR_GRAY
								oSay:SetCss("background-color: RGB(169,169,169);")
							ELSE //aCrDie[nCrAux][2]
								oSay:SetCss("background-color: RGB("+aCrDieR[nCrAux][2]+");")
							ENDIF
							
							aCurLin[nChvCnf][nCntLin - 3][nChvCur]:bLClicked 	:= &("{|| (U_SelCur('" + cChvCnf + "', '" + STR(nCntLin - 3) + "', '" + STR(nChvCur) + "'))}")
							aCurLin[nChvCnf][nCntLin - 3][nChvCur - 1]:TagGroup := 1

							AAdd(aCurLin[nChvCnf][nCntLin - 3][nChvCur]:aControls, (aDadTl[nCntAll][nCntLin][nCntCur][07] * aDadTl[nCntAll][nCntLin][nCntCur][03]))
							AAdd(aCurLin[nChvCnf][nCntLin - 3][nChvCur]:aControls, cChvLin)
							AAdd(aCurLin[nChvCnf][nCntLin - 3][nChvCur]:aControls, aDadTl[nCntAll][nCntLin][nCntCur][01])
							AAdd(aCurLin[nChvCnf][nCntLin - 3][nChvCur]:aControls, cDiCur )
							AAdd(aCurLin[nChvCnf][nCntLin - 3][nChvCur]:aControls, aDadTl[nCntAll][nCntLin][nCntCur][02])
							AAdd(aCurLin[nChvCnf][nCntLin - 3][nChvCur]:aControls, aDadTl[nCntAll][nCntLin][nCntCur][11])
						EndIf
					
						nCurCol := nCurCol + 030
					//aba RESUMO ou CONFINAMENTOS
					ElseIf (IIf(oTFldr:nOption == (Len(oTFldr:aDialogs) - 1), aDadTl[nCntAll][nCntLin][nCntCur][10] == "99", aDadTl[nCntAll][nCntLin][nCntCur][10] == aDadSel[4]))

						oPanel := nil
						oPanel := TPanel():New(000, nCurCol-005, aDadTl[nCntAll][nCntLin][nCntCur][01], aLinCnf[nChvCnf][Len(aLinCnf[nChvCnf])], oTFntLC, .T.,, IIf(nCrFnt = CLR_WHITE, CLR_BLACK, CLR_WHITE), nCrFnt/*aCorTl[1]*/, 072, 015)
						oPanel:SetCss("background-color: RGB("+IIF(nCrFnt == CLR_WHITE, "255,255,255" ,cCrFnt)+");")

						AAdd(aCurLin[nChvCnf][nCntLin - 3], oPanel)

						oPanel := nil
						oPanel := TPanel():New(018, nCurCol,, aLinCnf[nChvCnf][Len(aLinCnf[nChvCnf])], oTFntGr, .T.,, aCorTl[5], IIf(cLtCur = 'SEM LOTE' .OR. nCrAux < 1, CLR_GRAY, aCrDie[nCrAux][2]), 060, 068)
						if cLtCur == 'SEM LOTE' .OR. nCrAux < 1 // CLR_GRAY
							oPanel:SetCss("background-color: RGB(169,169,169);")
						else //aCrDie[nCrAux][2]
							oPanel:SetCss("background-color:RGB("+aCrDieR[nCrAux][2]+");")
						endif

						AAdd(aCurLin[nChvCnf][nCntLin - 3], oPanel)
						
						nChvCur := Len(aCurLin[nChvCnf][nCntLin - 3])
						
						If (cQtCab != '0')

							oSay := nil
							oSay := TSay():New(005, 005, &("{|| '" + cLtCur + "' + ' - ' + '" + cQtCab + "' + '" + cPlCur + "'}"), aCurLin[nChvCnf][nCntLin - 3][nChvCur],,oTFntPs,,,,.T., aCorTl[5], IIf(cLtCur == 'SEM LOTE' .OR. nCrAux < 1, CLR_GRAY, aCrDie[nCrAux][2]), 200, 100)
							IF cLtCur == 'SEM LOTE' .OR. nCrAux < 1 // CLR_GRAY
								oSay:SetCss("background-color: RGB(169,169,169);")
							ELSE //aCrDie[nCrAux][2]
								oSay:SetCss("background-color: RGB("+aCrDieR[nCrAux][2]+");")
							ENDIF

							aCurLin[nChvCnf][nCntLin - 3][nChvCur]:bLClicked := &("{|| (U_SelCur('" + cChvCnf + "', '" + STR(nCntLin - 3) + "', '" + STR(nChvCur) + "'))}")
							aCurLin[nChvCnf][nCntLin - 3][nChvCur - 1]:TagGroup := 1
							AAdd(aCurLin[nChvCnf][nCntLin - 3][nChvCur]:aControls, (aDadTl[nCntAll][nCntLin][nCntCur][07] * aDadTl[nCntAll][nCntLin][nCntCur][03]))
							AAdd(aCurLin[nChvCnf][nCntLin - 3][nChvCur]:aControls, cChvLin)
							AAdd(aCurLin[nChvCnf][nCntLin - 3][nChvCur]:aControls, aDadTl[nCntAll][nCntLin][nCntCur][01])
							AAdd(aCurLin[nChvCnf][nCntLin - 3][nChvCur]:aControls, cDiCur)
							AAdd(aCurLin[nChvCnf][nCntLin - 3][nChvCur]:aControls, aDadTl[nCntAll][nCntLin][nCntCur][02])
							AAdd(aCurLin[nChvCnf][nCntLin - 3][nChvCur]:aControls, aDadTl[nCntAll][nCntLin][nCntCur][11])
						
							tButton():New(050, 001, "TRT", aCurLin[nChvCnf][nCntLin - 3][nChvCur], &("{|| U_VP05Form(aDadSel[2], aDadSel[3], '" + ALLTRIM(cChvLin) + ALLTRIM(aDadTl[nCntAll][nCntLin][nCntCur][01]) + "', '" + cLote + "')}"), 15, 15,,oTFntGr,, .T.)
							tButton():New(050, 022, "KDX", aCurLin[nChvCnf][nCntLin - 3][nChvCur], &("{|| U_VAESTR16({{'" + cLote + "', '" + AllTrim(cChvLin) + aDadTl[nCntAll][nCntLin][nCntCur][01] + "'}}) }"), 15, 15,,oTFntGr,, .T.) 
							tButton():New(050, 044, "INF", aCurLin[nChvCnf][nCntLin - 3][nChvCur], &("{|| U_VAPCPM01('" + cLote + "') }"), 15, 15,,oTFntGr,, .T.)
						EndIf
					
						nCurCol := nCurCol + 065
					EndIf
				Next nCntCur

				If (lPShwGer)
					nLinLin := nLinLin + 50
				Else
					nLinLin := nLinLin + 100
				EndIf
				
				nCurLin := 005
				nCurCol := 005	
		
			Next nCntLin
		Next nCntAll
		
		nCurLin := 005
		nCurCol := 005

		// Preenche a aba de Resumo
		If (!lPShwGer)
			If (oTFldr:nOption == Len(oTFldr:aDialogs))
		
				TSay():New(010, 005, {|| "Total Currais:"}, oTFldr:aDialogs[Len(oTFldr:aDialogs)],,oTFntLg,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
				TSay():New(010, 120, {|| TRANSFORM(nTotCur, "@E 999,999,999.99")}, oTFldr:aDialogs[Len(oTFldr:aDialogs)],,oTFntLg,,,,.T., CLR_RED, CLR_WHITE, 200, 20)
				
				TSay():New(025, 005, {|| "Total Currais em Rotas:"}, oTFldr:aDialogs[Len(oTFldr:aDialogs)],,oTFntLg,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
				TSay():New(025, 120, {|| TRANSFORM(nTotCRt, "@E 999,999,999.99")}, oTFldr:aDialogs[Len(oTFldr:aDialogs)],,oTFntLg,,,,.T., CLR_RED, CLR_WHITE, 200, 20)
				
				TSay():New(040, 005, {|| "Total Currais SEM Rotas:"}, oTFldr:aDialogs[Len(oTFldr:aDialogs)],,oTFntLg,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
				TSay():New(040, 120, {|| TRANSFORM(nTotCSR, "@E 999,999,999.99")}, oTFldr:aDialogs[Len(oTFldr:aDialogs)],,oTFntLg,,,,.T., CLR_RED, CLR_WHITE, 200, 20)
				
				AAdd(aHdrRes, {"Rota"         , "ROTA"       , ""                 , 10, 0, ""                      , "", "C", "ZRT"   , "R", "", "", "", "V"})
				AAdd(aHdrRes, {"Dieta"        , "DIETA"      , ""                 , 20, 0, ""                      , "", "C", ""      , "R", "", "", "", "V"})
				AAdd(aHdrRes, {"Total Trato"  , "TOTTRT"     , "@E 999,999,999.99", 14, 2, ""                      , "", "N", ""      , "R", "", "", "", "V"})
				AAdd(aHdrRes, {"Veiculo"      , "VEIC"       , ""                 , 06, 0, "U_GRVVEI(&(ReadVar()))", "", "C", "ZV0VEI", "R", "", "", "", "A"})
				AAdd(aHdrRes, {"Descricao"    , "DSCVEI"     , ""                 , 20, 0, ""                      , "", "C", ""      , "R", "", "", "", "V"})
				AAdd(aHdrRes, {"Capacidade"   , "CPVEIC"     , "@E 999,999.999   ", 10, 3, ""                      , "", "N", ""      , "R", "", "", "", "V"})
				AAdd(aHdrRes, {"Operador"     , "OPVEIC"     , ""                 , 14, 0, "U_GRVOPR(&(ReadVar()))", "", "C", "Z0U"   , "R", "", "", "", "A"})
				AAdd(aHdrRes, {"Descricao"    , "DSCOPE"     , ""                 , 20, 0, ""                      , "", "C", ""      , "R", "", "", "", "V"})
				AAdd(aHdrRes, {"Lista Currais", "CURRAIS"     , ""                 , 40, 0, ""                      , "", "C", ""      , "R", "", "", "", "V"})
				
				AAdd(aHdrRTr, {"Trato"      , "TRATO" , ""                 , 10, 0, ""                      , "", "C", ""      , "R", "", "", "", "V"})
				AAdd(aHdrRTr, {"Total Trato", "TOTTRT" , "@E 999,999,999.99", 14, 2, ""                      , "", "N", ""      , "R", "", "", "", "V"})
		
				aClsRes := {}
				aClsRTr := {}
				
				// Atualizar Z0S
				cQry := " with ROT as ( " + CRLF +;
						" 	select Z0T.Z0T_ROTA, Z05.Z05_DIETA, sum(Z05.Z05_KGMNDI*Z05.Z05_CABECA) TOTTRT " + CRLF +;
						" 	, ISNULL((SELECT STRING_AGG(RTRIM(Z0T_CURRAL), '; ') CURRAL  " + CRLF +;
						" 				FROM (SELECT Z0T_CURRAL  " + CRLF +;
						" 						FROM " +RetSqlName("Z0T")+ " Z0T1  " + CRLF +;
						" 						WHERE Z0T1.Z0T_FILIAL = Z0T_FILIAL  " + CRLF +;
						" 						AND Z0T1.Z0T_DATA   = Z0T.Z0T_DATA   " + CRLF +;
						" 						AND Z0T1.Z0T_ROTA   = Z0T.Z0T_ROTA  " + CRLF +;
						" 					 " + CRLF +;
						" 						AND Z0T1.D_E_L_E_T_ = ' '   " + CRLF +;
						" 					GROUP BY Z0T1.Z0T_DATA, Z0T1.Z0T_CURRAL, Z0T1.Z0T_LOTE " + CRLF +;
						" 					) AS  CURRAL),0) CURRAIS " + CRLF +;
						" 	from " +RetSqlName("Z05")+ " Z05 " + CRLF +;
						" 	join " +RetSqlName("Z0T")+ " Z0T " + CRLF +;
						" 	  on Z0T.Z0T_FILIAL = Z05.Z05_FILIAL " + CRLF +;
						" 	 and Z0T.Z0T_DATA   = Z05.Z05_DATA " + CRLF +;
						" 	 and Z0T.Z0T_VERSAO = Z05.Z05_VERSAO " + CRLF +;
						" 	 and Z0T.Z0T_CURRAL = Z05.Z05_CURRAL " + CRLF +;
						" 	 and Z0T.Z0T_ROTA   <> '      ' " + CRLF +;
						" 	 and Z0T.D_E_L_E_T_ = ' ' " + CRLF +;
						" 	where Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "' " + CRLF +;
						" 	and Z05.Z05_DATA   = '" + DTOS(aDadSel[2]) + "' " + CRLF +;
						" 	and Z05.Z05_VERSAO = '" + aDadSel[3] + "' " + CRLF +;
						" 	and Z05.D_E_L_E_T_ = ' ' " + CRLF +;
						" 	group by Z0T.Z0T_ROTA, Z05.Z05_DIETA,  Z0T_DATA " + CRLF +;
						" 	--ORDER BY 1 " + CRLF +;
						" )" + CRLF +;
						"" + CRLF +;
						", DADOS AS (" + CRLF +;
						" 	select DISTINCT Z0S.Z0S_ROTA AS ROTA " + CRLF +;
						"        , ROT.Z05_DIETA AS DIETA "  + CRLF +;
						" 		, case Z0S.Z0S_DIETA when '' then ROT.TOTTRT    else Z0S.Z0S_TOTTRT end AS TOTTRT " + CRLF +;
						" 		, Z0S.Z0S_EQUIP AS EQUIP " + CRLF +;
						" 		, case ROT.Z05_DIETA when '' then '                              '  " + CRLF +;
						" 									else Z0S.Z0S_OPERAD end AS OPERAD " + CRLF +;
						" 		, case Z0S.Z0S_DIETA when '' then 0 else ZV0.ZV0_CAPACI end AS CAPAC, ROT.CURRAIS " + CRLF +;
						" 	from " +RetSqlName("Z0S")+ " Z0S " + CRLF +;
						" 	left join " +RetSqlName("ZV0")+ " ZV0 on ZV0.ZV0_FILIAL = '" + FWxFilial("ZV0") + "' " + CRLF +;
						" 						and ZV0.ZV0_CODIGO = Z0S.Z0S_EQUIP " + CRLF +;
						" 						and ZV0.ZV0_STATUS = 'A' " + CRLF +;
						" 						and ZV0.D_E_L_E_T_ = ' ' " + CRLF +;
						" 	left join ROT on ROT.Z0T_ROTA   = Z0S.Z0S_ROTA " + CRLF +;
						" 	where Z0S.Z0S_FILIAL = '" + FWxFilial("Z0S") + "' " + CRLF +;
						" 	and Z0S.Z0S_DATA   = '" + DTOS(aDadSel[2]) + "' " + CRLF +;
						" 	and Z0S.Z0S_VERSAO = '" + aDadSel[3] + "'  " + CRLF +;
						" 	and ( Z0S.Z0S_TOTTRT <> 0  " + CRLF +;
						" 		AND Z0S.Z0S_TOTTRT  IS NOT NULL " + CRLF +;
						" 		or  Z0S_ROTA in ( " + CRLF +;
						" 							select distinct Z0T_ROTA  " + CRLF +;
						" 							from "+RetSqlName("Z0T")+" " + CRLF +;
						" 							where Z0T_FILIAL = '" + FWxFilial("Z0T") + "' " + CRLF +;
						" 							and Z0T_DATA = '" + DTOS(aDadSel[2]) + "' " + CRLF +;
						" 							and Z0T_VERSAO = '" + aDadSel[3] + "' " + CRLF +;
						" 							and D_E_L_E_T_ = ' ' " + CRLF +;
						" 						) " + CRLF +;
						" 	) " + CRLF +;
						" 	and Z0S.D_E_L_E_T_ = ' ' " + CRLF +;
						" )" + CRLF +;
						"" + CRLF +;
						"  SELECT ROTA" + CRLF +;
						" 	   , DIETA DIETA" + CRLF +;
						" 	   , TOTTRT" + CRLF +;
						" 	   , EQUIP" + CRLF +;
						" 	   , OPERAD" + CRLF +;
						" 	   , CAPAC" + CRLF +;
						" 	   , CURRAIS" + CRLF +;
						"  FROM DADOS"

				MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_Resumo.SQL", cQry)
				
				cALias := MpSysOpenQuery(cQry)
				
				While (!(cALias)->(EOF()))
					AAdd(aClsRes, {(cALias)->ROTA,;
								(cALias)->DIETA,; // POSICIONE("SB1", 1, FWxFilial("SB1") + (cALias)->DIETA, "B1_DESC"),;
								(cALias)->TOTTRT,; 
								(cALias)->EQUIP,;
								POSICIONE("ZV0", 1, FWxFilial("ZV0") + (cALias)->EQUIP, "ZV0_DESC"),;
								(cALias)->CAPAC,;
								(cALias)->OPERAD,;
								POSICIONE("Z0U", 1, FWxFilial("Z0U") + (cALias)->OPERAD, "Z0U_NOME"),;
								; //cStts,;
								; //(cALias)->CODARQ,;
								(cALias)->CURRAIS,;
								.F.})
				
					(cALias)->(DBSkip()) 
				EndDo
				(cALias)->(DBCloseArea())
				//MsNewGetDados():New( Top, Left                   , Bottom         ,  Right  , [ nStyle], [ cLinhaOk]  , [ cTudoOk]   , [ cIniCpos]  , [ aAlter]         , F, Max, [ cFieldOk]  ,   ,              , [ oWnd]                              , [ aPartHeader], [ aParCols], [ uChange], [ cTela], [ aColsSize] )
				oGrdRTr := MsNewGetDados():New( 005, (aPObjs[1][4]/2) - 100, 085             , (aPObjs[1][4]/2),          , "AllwaysTrue", "AllwaysTrue",              ,                   , 0, 999, "AllwaysTrue", "", "AllwaysTrue", oTFldr:aDialogs[Len(oTFldr:aDialogs)], aHdrRTr       , aClsRTr)
				oGrdRes := MsNewGetDados():New( 090, 005                   , (aPObjs[1][3]/2), (aPObjs[1][4]/2), GD_UPDATE, "AllwaysTrue", "AllwaysTrue",              , {"VEIC", "OPVEIC"}, 0, 999, "AllwaysTrue", "", "AllwaysTrue", oTFldr:aDialogs[Len(oTFldr:aDialogs)], aHdrRes       , aClsRes, {|| U_ChgTrR(n)})
				oGrdRes:oBrowse:SetBlkBackColor({|| SetClrResumo(oGrdRes) })
			EndIf
		EndIf
		
	ACTIVATE MSDIALOG oDlgRotas CENTERED

	If (nOpcRotas == 1)
		lShwZer := !lShwZer
	EndIf

Return (Nil)
/*
	MB : 20.07.2021
		-> Setar linha de acordo com a paleta de cor
*/
Static Function SetClrResumo(oObj)
	Local nCor		:= RGB(254,254,254)
	/*
	Local aColsAux  := oObj:aCols
	Local nAt		:= oObj:nAt
	Local nPos	    := 0
	If (nPos:=aScan(aCrDie , { |x| AllTrim(x[1]) == AllTrim(aColsAux[ nAt, 2]) })) > 0
		nCor := aCrDie[nPos, 2]
	EndIf
	*/
Return nCor

/* =================================================================================================================== */
User Function SelLin(cChvCnf, cChvLin)
	Local nIndCnf := VAL(cChvCnf)
	Local nIndLin := VAL(cChvLin)
	Local nCntCur := 1
	Local lCnt    := .T.
	Local cRot    := ""
	Local cRotSub := ""
	Local nVlrSub := 0
	Local cChvTab := ""
	Local cDiCur  := ""
	Local nCrRot  := aRot[aScan(aRot, {|x| x[1] = aDadSel[1]})][2]
	Local cCrRot  := aRot[aScan(aRot, {|x| x[1] = aDadSel[1]})][3]

	if Len(aDadTl) == 1
		nIndCnf := 1
	endif

	if cChvCnf == "99"
		nIndCnf := Len(aDadTl)
	endif

	Z0T->(DBSetOrder(3))

	For nCntCur := 1 To Len(aCurLin[nIndCnf][nIndLin])
	
		If (aCurLin[nIndCnf][nIndLin][nCntCur]:TagGroup == 1)

			cDiCur := aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[4]
		
			If (!Empty(Z0S->Z0S_DIETA))
				If (!(Z0S->Z0S_DIETA $ cDiCur))
					MsgInfo("Dieta '" + AllTRIM(POSICIONE("SB1", 1, xFilial("SB1") + cDiCur, "B1_DESC")) + "' nao e a mesma dos outros currais na " + aDadSel[1] + ". Curral nao selecionado")
					Return (Nil)
				EndIf
			EndIf
			
			cChvTab := xFilial("Z0T") + DTOS(aDadSel[2]) + aDadSel[3] + cChvCnf + aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[2] + aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[3]
	
			If (Z0T->(DBSeek(cChvTab)))
				If (!Empty(Z0T->Z0T_ROTA) .AND. Z0T->Z0T_ROTA != aDadSel[1])
					If (MsgYesNo("O curral " + ALLTRIM(STR(nCntCur/2)) + " na linha " + ALLTRIM(aLinAlf[nIndLin]) + " do confinamento " + ALLTRIM(cChvCnf) + " esta associado a Rota: '" + Z0T->Z0T_ROTA + "' . Deseja susbstituir pela '" + aDadSel[1] + "' ?", "Curral encontrado em outra Rota."))
						cRotSub := Z0T->Z0T_ROTA
						nTotCRt := nTotCRt - 1
					Else
						lCnt := .F.
					EndIf
				EndIf
			Else
				RecLock("Z0T", .T.)
					Z0T->Z0T_FILIAL := xFilial("Z0T")
					Z0T->Z0T_DATA   := aDadSel[2]
					Z0T->Z0T_VERSAO := aDadSel[3]
					Z0T->Z0T_ROTA   := aDadSel[1]
					Z0T->Z0T_CONF   := cChvCnf
					Z0T->Z0T_LINHA  := aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[2]
					Z0T->Z0T_SEQUEN := aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[3]
					Z0T->Z0T_CURRAL := ALLTRIM(aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[6])
					Z0T->Z0T_LOTE   := aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[5]
				Z0T->(MSUnlock())
				nTotCRt := nTotCRt - 1
			EndIf
			
			If (lCnt)
				cLote := aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[5]

				If ((aCurLin[nIndCnf][nIndLin][nCntCur]:nClrPane != nCrRot)) //aCorTl[4]
					aCurLin[nIndCnf][nIndLin][nCntCur]:nClrPane := nCrRot
					aCurLin[nIndCnf][nIndLin][nCntCur]:SetCss("background-color: RGB("+cCrRot+");")
					nTotTrt += aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[1]
					nVlrSub := aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[1]
					cRot := aDadSel[1]
					nTotCRt := nTotCRt + 1
				ElseIf ((aCurLin[nIndCnf][nIndLin][nCntCur]:nClrPane == nCrRot))
					aCurLin[nIndCnf][nIndLin][nCntCur]:nClrPane := aCorTl[1] //aCorTl[4]
					aCurLin[nIndCnf][nIndLin][nCntCur]:SetCss("background-color: RGB(255,255,255);")
					nTotTrt -= aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[1]
					cRot := Space(6)
					nTotCRt := nTotCRt - 1
				EndIf
				
				RecLock("Z0S", .F.)
					Z0S->Z0S_DIETA  := cDiCur
					Z0S->Z0S_TOTTRT := nTotTrt
				Z0S->(MSUnlock())
						
				RecLock("Z0T", .F.)
					Z0T->Z0T_ROTA := cRot
					Z0T->Z0T_LOTE := cLote
				Z0T->(MSUnlock())
	
				If (!Empty(cRotSub))
					If (Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+cRotSub)))
						RecLock("Z0S", .F.)
							Z0S->Z0S_TOTTRT := Z0S->Z0S_TOTTRT - nVlrSub
						Z0S->(MSUnlock())
						
						If (Z0S->Z0S_TOTTRT = 0)
							RecLock("Z0S", .F.)
								Z0S->Z0S_EQUIP := ""
								Z0S->Z0S_DIETA := ""
							Z0S->(MSUnlock())
						EndIf
						
						Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+cRot))

						cRotSub := ""
					EndIf
				EndIf
			EndIf
		EndIf
		
	Next nCntCur

	nTotCSR := nTotCur - nTotCRt

	If (nTotTrt == 0)
		RecLock("Z0S", .F.)
			Z0S->Z0S_DIETA := ""
		Z0S->(MSUnlock())
	EndIf

	_cCurral := fLoadCurrais(aParRet[1], aDadSel[1])
Return (Nil)
User Function SelCur(cChvCnf, cChvLin, cChvCur )

	Local nIndCnf := VAL(cChvCnf)
	Local nIndLin := VAL(cChvLin)
	Local nIndCur := VAL(cChvCur)
	Local lCnt    := .T.
	Local cRot    := ""
	Local cRotSub := ""
	Local nVlrSub := 0
	Local cChvTab := ""
	Local cDiCur  := ""
	Local nCrRot  := aRot[aScan(aRot, {|x| x[1] = aDadSel[1]})][2]
	Local cCrRot  := aRot[aScan(aRot, {|x| x[1] = aDadSel[1]})][3]
	Local cCur    := ""
	Local cLote   := ""
	Local cCurrentTime := JurTime(.f., .T.)

	// Se o tempo entre o último clique e o atual for muito pequeno, ignora`
	if Val(SubStr(ltrim(dLastClickTime),1,2)) == Val(SubStr(ltrim(cCurrentTime),1,2))
		if Val(SubStr(ltrim(dLastClickTime),4,2)) == Val(SubStr(ltrim(cCurrentTime),4,2))
			If Abs(Val(SubStr(ltrim(dLastClickTime),7,2)) - Val(SubStr(ltrim(cCurrentTime),7,2))) < 1
				if abs(Val(SubStr(ltrim(dLastClickTime),10,3)) - Val(SubStr(ltrim(cCurrentTime),10,3))) < 500
					Return Nil // Ignora a segunda chamada muito rápida
				EndIf
			EndIf
		EndIf
	EndIf
	dLastClickTime := cCurrentTime // Atualiza o tempo do último clique

	if Len(aDadTl) == 1
		nIndCnf := 1
	endif

	if cChvCnf == "99"
		nIndCnf := Len(aDadTl)
	endif

	Z0S->(DBSetOrder(1))

	If (!(Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+aDadSel[1]))))
		Return (Nil)
	EndIf

	Z0T->(DBSetOrder(3))

	cDiCur := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[4]
	cCur   := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[2] + aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[3]

	If (!Empty(Z0S->Z0S_DIETA))
		If !(Z0S->Z0S_DIETA $ cDiCur)
			MsgInfo("Dieta '" + ALLTRIM(POSICIONE("SB1", 1, xFilial("SB1") + cDiCur, "B1_DESC")) + "' nao e a mesma dos outros currais na " + aDadSel[1] + ". Curral nao selecionado")
			Return (Nil)
		EndIf
	EndIf

	cChvTab := xFilial("Z0T") + DTOS(aDadSel[2]) + aDadSel[3] + cChvCnf + cCur //aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[2] + aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[3]

	If (Z0T->(DBSeek(cChvTab)))
		If (!Empty(Z0T->Z0T_ROTA) .AND. Z0T->Z0T_ROTA != aDadSel[1])
			If (MsgYesNo("O curral " + ALLTRIM(STR(nIndCur/2)) + " na linha " + ALLTRIM(aLinAlf[nIndLin]) + " do confinamento esta associado a Rota: '" + Z0T->Z0T_ROTA + "' . Deseja susbstituir pela '" + aDadSel[1] + "' ?", "Curral encontrado em outra Rota."))
				cRotSub := Z0T->Z0T_ROTA
				nTotCRt := nTotCRt - 1
			Else
				lCnt := .F.
			EndIf
		EndIf
	Else
		RecLock("Z0T", .T.)
			Z0T->Z0T_FILIAL := xFilial("Z0T")
			Z0T->Z0T_DATA   := aDadSel[2]
			Z0T->Z0T_VERSAO := aDadSel[3]
			Z0T->Z0T_ROTA   := aDadSel[1]
			Z0T->Z0T_CONF   := cChvCnf
			Z0T->Z0T_LINHA  := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[2]
			Z0T->Z0T_SEQUEN := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[3]
			Z0T->Z0T_CURRAL := ALLTRIM(aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[6])
			Z0T->Z0T_LOTE   := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[5]
		Z0T->(MSUnlock())
		
		nTotCRt := nTotCRt - 1
	EndIf

	If lCnt
		cLote := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[5]
	
		If ((aCurLin[nIndCnf][nIndLin][nIndCur - 1]:nClrPane != nCrRot))
			aCurLin[nIndCnf][nIndLin][nIndCur - 1]:nClrPane := nCrRot
			aCurLin[nIndCnf][nIndLin][nIndCur - 1]:SetCss("background-color: RGB("+cCrRot+");")
			nTotTrt += aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[1]
			nVlrSub := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[1]
			cRot 	:= aDadSel[1]
			nTotCRt := nTotCRt + 1
		ElseIf ((aCurLin[nIndCnf][nIndLin][nIndCur - 1]:nClrPane == nCrRot))
			aCurLin[nIndCnf][nIndLin][nIndCur - 1]:nClrPane := aCorTl[1] //aCorTl[4]
			aCurLin[nIndCnf][nIndLin][nIndCur - 1]:SetCss("background-color: RGB(255,255,255);")
			nTotTrt -= aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[1]
			cRot 	:= Space(6)
			nTotCRt := nTotCRt - 1
			nTotCRt := nTotCRt + 1
		EndIf
			
		RecLock("Z0S", .F.)
			Z0S->Z0S_DIETA := cDiCur
			Z0S->Z0S_TOTTRT := nTotTrt
		Z0S->(MSUnlock())

		RecLock("Z0T", .F.)
			Z0T->Z0T_ROTA := cRot
			Z0T->Z0T_LOTE := cLote
		Z0T->(MSUnlock())
		
		If (!Empty(cRotSub))
			If (Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+cRotSub)))
				RecLock("Z0S", .F.)
					Z0S->Z0S_TOTTRT := Z0S->Z0S_TOTTRT - nVlrSub
				Z0S->(MSUnlock())
				
				If (Z0S->Z0S_TOTTRT == 0)
					RecLock("Z0S", .F.)
						Z0S->Z0S_EQUIP := ""
						Z0S->Z0S_DIETA := ""
					Z0S->(MSUnlock())
				EndIf
				
				Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+cRot))
				
			EndIf
		EndIf
	EndIf

	nTotCSR := nTotCur - nTotCRt

	If (nTotTrt == 0)
		RecLock("Z0S", .F.)
			Z0S->Z0S_DIETA := ""
			Z0S->Z0S_EQUIP := ""
			Z0S->Z0S_OPERAD:= ""
		Z0S->(MSUnlock())
	EndIf

	_cCurral := fLoadCurrais(aParRet[1], aDadSel[1])

Return (Nil)

/* ==================================================================================================================== */
User Function CORROTA(nRed, nGreen, nBlue)
	Local nCrRt := 0
	nCrRt   := (nRed + (nGreen * 256) + (nBlue * 65536))
Return (nCrRt)

/* ==================================================================================================================== */
User Function CRRGABA(nAba)
	Local lRetCrA := .F.

	If (aDadSel[4] != STRZERO(nAba, 2))
		aDadSel[4] := STRZERO(nAba, 2)
		lRetCrA := .T.
		
		If (nAba == Len(oTFldr:aDialogs)-2)
			nOpcRotas := 2
			lShwGer := .T.
		Else
			nOpcRotas := 3
			lShwGer := .F.
		EndIf
	EndIf
Return (lRetCrA)

/* ==================================================================================================================== */
User Function GRVVEI(cVeic)
	Local lVldVei := .T.

	If (Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+aCols[n][1])))
		RecLock("Z0S", .F.)
			Z0S->Z0S_EQUIP := cVeic
			
		Z0S->(MSUnlock())
	Else
		lVldVei := .F.
	EndIf
Return (lVldVei)

/* ==================================================================================================================== */
User Function GRVOPR(cOper)
	Local lVldOpr := .T.

	If (Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+aCols[n][1])))
		RecLock('Z0S', .F.)
			Z0S->Z0S_OPERAD := cOper
		Z0S->(MSUnlock())
	Else
		lVldOpr := .F.
	EndIf
Return (lVldOpr)

/* ==================================================================================================================== */
User Function ChgTrR(nLin)
	Local lVldChg := .T.
	Local cQry := ""
	Local cAlias := ""

	If (Len(aClsRes) > 0)

		cQry := " SELECT Z06.Z06_TRATO AS TRATO, SUM(Z06_KGMNT) TOTAL " + CRLF +;
				"  FROM " + RetSqlName("Z06") + " Z06  " + CRLF +;
				"  RIGHT JOIN " + RetSqlName("Z0T") + " Z0T ON Z0T.Z0T_DATA = Z06.Z06_DATA AND Z0T.Z0T_VERSAO = Z06.Z06_VERSAO AND Z0T.Z0T_FILIAL = '" + xFilial("Z0T") + "' AND Z0T.D_E_L_E_T_ <> '*' AND Z0T.Z0T_ROTA = '" + aClsRes[nLin][1] + "'  " + CRLF +;
				"  										  AND Z0T_CURRAL = Z06_CURRAL AND Z06_LOTE = Z0T_LOTE " + CRLF +;
				"  WHERE Z06.Z06_FILIAL = '" + xFilial("Z06") + "' AND Z06.D_E_L_E_T_ <> '*'  " + CRLF +;
				"    AND Z06.Z06_DATA = '" + dToS(aDadSel[2]) + "' " + CRLF +; // DATEADD(dd, -1, cast('" + DTOS(aDadSel[2]) + "' as datetime)) " + CRLF +;
				"    AND Z06.Z06_VERSAO = '" + aDadSel[3] + "' " + CRLF +;
				"    AND Z06.Z06_TRATO <> ''  " + CRLF +;
				"  GROUP BY Z06.Z06_TRATO  " + CRLF +;
				"  ORDER BY Z06.Z06_TRATO "
		
		cAlias := MpSysOpenQuery(cQry)
		
		aClsRTr := {}
		
		While (!((cAlias)->(EOF())))
			AAdd(aClsRTr, {(cAlias)->TRATO, (cAlias)->TOTAL, .F.})
			
			(cAlias)->(DBSkip())
		EndDo
		
		(cAlias)->(DBCloseArea())
	Else
		AAdd(aClsRTr, {'', 0, .F.})
	EndIf

	oGrdRTr:SetArray(aClsRTr)
	oGrdRTr:Refresh()

Return (lVldChg)

/* ==================================================================================================================== */
// Botão zerar trato
Static Function ZerRot()
	Local oDlgZRt
	Local cQry := ""
	Local aHdrRot := {}
	Local aClsRot := {}
	Local nCntRot := 0 
	Local nOpcRot := 0
	Local lVldZer := .T.
	Local cAlias  := ""

	Private oGrdF3R

	AAdd(aHdrRot, {"Sel."    ,"Selecionado", "@BMP"         , 01, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrRot, {"Rota"    ,"Rota"       , ""             , 06, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrRot, {"Total"   ,"Total"      , "@R 999,999.99", 10, 2, "", "", "N", "", "R", "", "", "", "V"})
	AAdd(aHdrRot, {"Operador","Operador"   , ""             , 20, 0, "", "", "C", "", "R", "", "", "", "V"})

	cQry := " SELECT Z0S.Z0S_ROTA AS ROTA, Z0S.Z0S_TOTTRT AS TOTAL, Z0S.Z0S_OPERAD AS OPERAD" + CRLF
	cQry += " FROM " + RetSqlName("Z0S") +  " Z0S " + CRLF
	cQry += " WHERE Z0S.Z0S_FILIAL = '" + xFilial("Z0S") + "' " + CRLF
	cQry += "   AND Z0S.Z0S_DATA = '" + DTOS(MV_PAR01) + "' " + CRLF
	cQry += "   AND Z0S.D_E_L_E_T_ <> '*' " + CRLF
	cQry += "   AND Z0S.Z0S_TOTTRT > 0 "
	cQry += " ORDER BY Z0S.Z0S_ROTA "

	cALias := MpSysOpenQuery(cQry)

	While !((cAlias)->(EOF()))

		AAdd(aClsRot, {aTik[2], (cAlias)->ROTA, (cAlias)->TOTAL, POSICIONE("Z0U", 1, xFilial("Z0U") + (cAlias)->OPERAD, "Z0U_NOME"), .F.})
		
		(cAlias)->(DBSkip())

	EndDo

	(cAlias)->(DBCloseArea())

	DEFINE MSDIALOG oDlgZRt TITLE "Rotas para Exportar" FROM 000, 000 To 400, 500 PIXEL

		oGrdF3R := MsNewGetDados():New(015, 005, 150, 250,, "AllwaysTrue", "AllwaysTrue",,, 0, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgZRt, aHdrRot, aClsRot)
		oGrdF3R:oBrowse:bLDblClick := {|| MarkRot(1), oGrdF3R:Refresh()}
		
		tButton():New(160, 010, "Desmarcar Todos" , oDlgZRt, {|| MarkRot(2)}    , 100, 15,,,, .T.)
		tButton():New(180, 010, "Selecionar Todos", oDlgZRt, {|| MarkRot(3)}    , 100, 15,,,, .T.)
		
		tButton():New(180, 115, "Cancelar"        , oDlgZRt, {|| nOpcRot := 0, oDlgZRt:End()}, 060, 15,,,, .T.)
		tButton():New(180, 180, "Confirmar"       , oDlgZRt, {|| nOpcRot := 1, oDlgZRt:End()}, 060, 15,,,, .T.)

		oDlgZRt:lEscClose := .T.
		
	ACTIVATE MSDIALOG oDlgZRt CENTERED

	cRotSel := ""

	If (nOpcRot = 1)

		For nCntRot := 1 To Len(aClsRot)
		
			If (oGrdF3R:aCols[nCntRot, 1] = aTik[1])

				cRotSel := oGrdF3R:aCols[nCntRot][2]
			
				cQryZer := " UPDATE " + RetSqlName("Z0S")
				cQryZer += " SET Z0S_EQUIP = '' "
				cQryZer += "   , Z0S_DIETA = '' "
				cQryZer += "   , Z0S_OPERAD = '' "
				cQryZer += "   , Z0S_TOTTRT = 0 "
				cQryZer += " WHERE Z0S_FILIAL = '" + xFilial("Z0S") + "' "
				cQryZer += "   AND Z0S_DATA = '" + DTOS(aDadSel[2]) + "' "
				cQryZer += "   AND Z0S_VERSAO = '" + aDadSel[3] + "' "
				cQryZer += "   AND Z0S_ROTA = '" + cRotSel + "' "
				cQryZer += "   AND D_E_L_E_T_ <> '*' "
				
				If (TCSqlExec(cQryZer) < 0)
					MsgInfo(TCSqlError())
				EndIf
				
				cQryZer := " UPDATE " + RetSqlName("Z0T")
				cQryZer += " SET Z0T_ROTA = '' "
				cQryZer += " WHERE Z0T_FILIAL = '" + xFilial("Z0T") + "' "
				cQryZer += "   AND Z0T_DATA = '" + DTOS(aDadSel[2]) + "' "
				cQryZer += "   AND Z0T_VERSAO = '" + aDadSel[3] + "' "
				cQryZer += "   AND Z0T_ROTA = '" + cRotSel + "' "
				cQryZer += "   AND D_E_L_E_T_ <> '*' "
				
				If (TCSqlExec(cQryZer) < 0)
					MsgInfo(TCSqlError())
				EndIf
			EndIf  
		
		Next nCntRot
		
	EndIf

Return (lVldZer)


Static Function MarkRot(nTpOpr)

	Local lVldSRt := .T.
	Local nCntRot := 1

	If (nTpOpr = 1) //marcar unico

		If (oGrdF3R:aCols[oGrdF3R:nAt, 1] = aTik[1])
			oGrdF3R:aCols[oGrdF3R:nAt, 1] := aTik[2]
		Else
			oGrdF3R:aCols[oGrdF3R:nAt, 1] := aTik[1]
		EndIf
		
	ElseIf (nTpOpr = 2) //Desmarcar Todos

		For nCntRot := 1 To Len(oGrdF3R:aCols)
			oGrdF3R:aCols[nCntRot][1] := aTik[2]
		Next nCntRot
		
	ElseIf (nTpOpr = 3) //Selecionar Todos

		For nCntRot := 1 To Len(oGrdF3R:aCols)
			oGrdF3R:aCols[nCntRot][1] := aTik[1]
		Next nCntRot	
		
	EndIf

	oGrdF3R:Refresh(.T.)
	
Return (lVldSRt)	

Static Function ShwCur()
	Local lVldSCR := .T.
	Local oDlgSCR
	Local oGrdSCR
	Local cQry := ""
	Local aHdrSCR := {}
	Local aClsSCR := {}
	Local cCntCur := "000"
	Local nUniKMN := 0
	Local nTotKMN := 0
	Local nTotCab := 0
	Local oTFntGr := TFont():New('Courier new',,16,.T.,.T.)
	Local cALias  := ""

	cQry := " SELECT Z0T.Z0T_CONF AS CONF, Z0T.Z0T_LINHA AS LINHA, Z0T.Z0T_SEQUEN AS SEQ, Z0T.Z0T_CURRAL AS CURRAL, Z05.Z05_CABECA AS QTDCAB, Z05.Z05_NROTRA AS NROTRT " + CRLF +;
			"      , (SELECT Z05A.Z05_KGMNDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0T.Z0T_DATA) AND Z05A.Z05_VERSAO = Z0T.Z0T_VERSAO AND Z05A.Z05_LOTE = Z0T.Z0T_LOTE AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS TOTKMN " + CRLF +;
			"      , (SELECT Z05B.Z05_CABECA FROM " + RetSqlName("Z05") + " Z05B WHERE Z05B.Z05_DATA = DATEADD(DAY, -1, Z0T.Z0T_DATA) AND Z05B.Z05_VERSAO = Z0T.Z0T_VERSAO AND Z05B.Z05_LOTE = Z0T.Z0T_LOTE AND Z05B.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05B.D_E_L_E_T_ <> '*') AS TOTCAB " + CRLF +;
			" FROM      " + RetSqlName("Z0T") + " Z0T " + CRLF +;
			" LEFT JOIN " + RetSqlName("Z05") + " Z05 ON Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.Z05_DATA = Z0T.Z0T_DATA " + CRLF +;
			"                                        AND Z05.Z05_VERSAO = Z0T.Z0T_VERSAO AND Z05.Z05_LOTE = Z0T.Z0T_LOTE " + CRLF +;
			"                                        AND Z05.D_E_L_E_T_ <> '*' " + CRLF +;
			" WHERE Z0T.Z0T_FILIAL = '" + xFilial("Z0T") + "' " + CRLF +;
			"   AND Z0T.Z0T_DATA   = '" + DTOS(aDadSel[2]) + "' " + CRLF +;
			"   AND Z0T.Z0T_VERSAO = '" + aDadSel[3] + "' " + CRLF +;
			"   AND Z0T.Z0T_ROTA   = '" + aDadSel[1] + "' " + CRLF +;
			"   AND Z0T.D_E_L_E_T_ = ' ' " + CRLF +;
			" ORDER BY Z0T.Z0T_CURRAL "

	MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_CURROTA.SQL", cQry)

	cAlias := MpSysOpenQuery(cQry)

	While (!((cAlias)->(EOF())))

		AAdd(aClsSCR, {(cAlias)->CONF, (cAlias)->CURRAL, (cAlias)->NROTRT, (cAlias)->TOTCAB, (cAlias)->TOTKMN, ((cAlias)->TOTCAB * (cAlias)->TOTKMN), .F.})
		cCntCur := Soma1(cCntCur)
		nTotCab += (cAlias)->TOTCAB
		nUniKMN += (cAlias)->TOTKMN
		nTotKMN += ((cAlias)->QTDCAB * (cAlias)->TOTKMN)
		(cAlias)->(DBSkip())

	EndDo

	(cAlias)->(DBCloseArea())

	AAdd(aHdrSCR, {"Confinamento", "CONFNA" , ""              , 06, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrSCR, {"Curral"      , "CURRAL" , ""              , 06, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrSCR, {"Qtd. Trato"  , "NROTRT" , "@E 99"         , 02, 0, "", "", "N", "", "R", "", "", "", "V"})
	AAdd(aHdrSCR, {"Qtd. Cabeca" , "QTDCAB" , ""              , 06, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrSCR, {"Unit. KG MN" , "TOTKMN" , "@E 999.999"    , 06, 3, "", "", "N", "", "R", "", "", "", "V"})
	AAdd(aHdrSCR, {"Total KG MN" , "TOTKMN" , "@E 999,999.999", 06, 3, "", "", "N", "", "R", "", "", "", "V"})

	SetKey(VK_F2, {|| oDlgSCR:End()})

	DEFINE MSDIALOG oDlgSCR TITLE "Currais da Rota" FROM 000, 000 To 400, 500 PIXEL

		TSay():New(005, 005, {|| "Total Currais "}, oDlgSCR,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 065, 20)
		TSay():New(015, 010, {|| cCntCur}, oDlgSCR,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 065, 20)
		
		TSay():New(005, 070, {|| "Total Cabecas "}, oDlgSCR,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 065, 20)
		TSay():New(015, 075, {|| ALLTRIM(TRANSFORM(nTotCab, "@E 999,999,999.999"))}, oDlgSCR,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 065, 20)
		
		TSay():New(005, 135, {|| "Unit. KG MN: "}, oDlgSCR,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 065, 20)
		TSay():New(015, 140, {|| ALLTRIM(TRANSFORM(nUniKMN, "@E 999,999,999.999"))}, oDlgSCR,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 065, 20)
		
		TSay():New(005, 200, {|| "Total KG MN: "}, oDlgSCR,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 065, 20)
		TSay():New(015, 205, {|| ALLTRIM(TRANSFORM(nTotKMN, "@E 999,999,999.999"))}, oDlgSCR,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 065, 20)
		
		oGrdSCR := MsNewGetDados():New(030, 005, 200, 250,, "AllwaysTrue", "AllwaysTrue",,, 0, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgSCR, aHdrSCR, aClsSCR)
		oDlgSCR:lEscClose := .T.
		
	ACTIVATE MSDIALOG oDlgSCR CENTERED

	SetKey(VK_F2, {|| ShwCur()})

Return (lVldSCR)


Static Function ShwLeg()
	Local lVldSLG := .T.
	Local oDlgSLG
	Local oTFntGr := TFont():New('Courier new',,16,.T.,.T.)

	SetKey(VK_F12, {|| oDlgSLG:End()})

	DEFINE MSDIALOG oDlgSLG TITLE "Legenda Curral" FROM 000, 000 To 400, 500 PIXEL

		TSay():New(005, 005, {|| "Curral Visão Geral"}, oDlgSLG,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 100, 20)

		TSay():New(110, 005, {|| "Curral Visão Detalhada"}, oDlgSLG,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 100, 20)
		
			
		oDlgSLG:lEscClose := .T.
		
	ACTIVATE MSDIALOG oDlgSLG CENTERED

	SetKey(VK_F12, {|| ShwLeg()})

Return (lVldSLG)


Static Function ShwChg()
	Local lVldSCH := .T.
	Local oDlgSCH
	Local oGrdSCHC
	Local aHdrSCHC := {}
	Local aClsSCHC := {}
	Local oGrdSCHD
	Local aHdrSCHD := {}
	Local aClsSCHD := {}
	Local oTFntGr := TFont():New('Courier new',,16,.T.,.T.)
	Local cAlias := ""
	Local cQry   := ""


	cQry := " SELECT Z05.Z05_CURRAL AS CURRAL, Z05.Z05_LOTE AS LOTE " + CRLF 
	cQry += " FROM " + RetSqlName("Z05") + " Z05 " + CRLF
	cQry += " JOIN " + RetSqlName("Z05") + " Z05A ON Z05A.Z05_DATA = DATEADD(dd, -1, cast(Z05.Z05_DATA as datetime)) AND Z05A.Z05_VERSAO = Z05.Z05_VERSAO AND Z05A.Z05_LOTE = Z05.Z05_LOTE AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' " + CRLF
	cQry += " WHERE Z05.Z05_FILIAL = '" + xFilial("Z05") + "' " + CRLF
	cQry += "   AND Z05.D_E_L_E_T_ <> '*' " + CRLF
	cQry += "   AND Z05.Z05_DATA = '" + DTOS(aParRet[1]) + "' " + CRLF
	cQry += "   AND Z05.Z05_CURRAL <> Z05A.Z05_CURRAL " + CRLF

	cAlias := MpSysOpenQuery(cQry)

	While (!((cAlias)->(EOF())))
		AAdd(aClsSCHC, {(cAlias)->LOTE, (cAlias)->CURRAL, .F.})
		(cAlias)->(DBSkip())
	EndDo

	(cAlias)->(DBCloseArea())

	cQry := " SELECT Z05.Z05_CURRAL AS CURRAL, Z05.Z05_LOTE AS LOTE " + CRLF 
	cQry += " FROM " + RetSqlName("Z05") + " Z05 " + CRLF
	cQry += " JOIN " + RetSqlName("Z05") + " Z05A ON Z05A.Z05_DATA = DATEADD(dd, -1, cast(Z05.Z05_DATA as datetime)) AND Z05A.Z05_VERSAO = Z05.Z05_VERSAO AND Z05A.Z05_LOTE = Z05.Z05_LOTE AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' " + CRLF
	cQry += " WHERE Z05.Z05_FILIAL = '" + xFilial("Z05") + "' " + CRLF
	cQry += "   AND Z05.D_E_L_E_T_ <> '*' " + CRLF
	cQry += "   AND Z05.Z05_DATA = '" + DTOS(aParRet[1]) + "' " + CRLF
	cQry += "   AND Z05.Z05_DIETA <> Z05A.Z05_DIETA " + CRLF

	cAlias := MpSysOpenQuery(cQry)

	While (!((cAlias)->(EOF())))
		AAdd(aClsSCHD, {(cAlias)->LOTE, (cAlias)->CURRAL, .F.})
		(cAlias)->(DBSkip())
	EndDo

	(cAlias)->(DBCloseArea())

	AAdd(aHdrSCHC, {"Lote"        , "CNROTRT" , "", 10, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrSCHC, {"Curral"      , "CCURRAL" , "", 10, 0, "", "", "C", "", "R", "", "", "", "V"})

	AAdd(aHdrSCHD, {"Lote"        , "DNROTRT" , "", 10, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrSCHD, {"Curral"      , "DCURRAL" , "", 10, 0, "", "", "C", "", "R", "", "", "", "V"})

	SetKey(VK_F4, {|| oDlgSCH:End()})

	DEFINE MSDIALOG oDlgSCH TITLE "Lotes com Mudança" FROM 000, 000 To 400, 500 PIXEL

		TSay():New(005, 005, {|| "Transferência de Curral"}, oDlgSCH,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 100, 20)
		oGrdSCHC := MsNewGetDados():New(015, 005, 090, 250,, "AllwaysTrue", "AllwaysTrue",,, 0, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgSCH, aHdrSCHC, aClsSCHC)

		TSay():New(110, 005, {|| "Mudança de Dieta"}, oDlgSCH,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 100, 20)
		oGrdSCHD := MsNewGetDados():New(120, 005, 195, 250,, "AllwaysTrue", "AllwaysTrue",,, 0, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgSCH, aHdrSCHD, aClsSCHD)
		
		oDlgSCH:lEscClose := .T.
		
	ACTIVATE MSDIALOG oDlgSCH CENTERED

	SetKey(VK_F4, {|| ShwChg()})
 
Return (lVldSCH)

/* 
	MB : 29.10.2020
		# Sugerir Rotas
*/
Static Function SugRotas()
	FWMsgRun(, {|| CursorWait(), ProcSugRotas(), CursorArrow() },;
				 "Aguarde ...",;
				 "Gerando sugestão de rotas ...")
Return nil

/* 
	MB : 17.11.2020
		# Criado para mostrar a barra de processamento;
*/
Static Function ProcSugRotas()
	Local aArea      := GetArea()
	Local nRotaAtual := 1
	Local cProdAtual := 0
	Local nI         := 0
	Local aDados     := aDadRotZao
	Local nComplet   := 0
	Local nRegistros := Len(aDados)
	Local lContinua  := .F.

	GeraSX1( "PCPA09ROTA" )
	If !Pergunte( "PCPA09ROTA", .T.)
		Return 
	EndIf

	_cLinAnt  := Left(aDados[01, 01], 1) // qTMP->CURRAL
	cDietAnt  := aDados[ 01, 04] // qTMP->DIETA
	lContinua := .T.
	nI        := 0
	While nComplet < nRegistros
		
		nI += 1

		If aDados[nI, 05]
			loop
		EndIf

		// ATUAL
		_cLinAtual      := Left(aDados[nI, 01], 1)

		If MV_PAR03 == 1
			lContinua := .F.	

			// MUDOU A RACAO
			If SubS(cDietAnt,3) <> SubS(aDados[nI, 04],3) // .AND. nTodosPreenchidos(aDados, cDietAnt )
				nRet := nTodosPreenchidos(aDados, cDietAnt )
				if nRet > 0
					nI := nRet
				EndIf
				lContinua := .T.
			Else
				If _cLinAnt == _cLinAtual .OR.; // enquanto estiver na mesma racao
					Asc(_cLinAtual)-Asc(_cLinAnt) >= 2 .OR.; // pular linha
					Asc(_cLinAtual)-Asc(_cLinAnt) < 0		 // troca de confinamento ou retorno da matriz: aDados
					lContinua := .T.
				EndIf
			EndIf
		EndIf
		If lContinua
			
			_cQry := " SELECT R_E_C_N_O_ recno " + CRLF +;
					" FROM "+RetSqlName("Z0T")+" " + CRLF +;
					" WHERE Z0T_FILIAL = '"+FWxFilial("Z0T")+"' AND Z0T_DATA   = '" + dToS( __dDtPergunte ) + "'" + CRLF +;
					"   AND Z0T_CURRAL = '" +  aDados[nI, 01] /* qTMP->CURRAL */ + "'" + CRLF +;
					"   AND Z0T_LOTE   = '" +  aDados[nI, 02] /* qTMP->LOTE */   + "'" + CRLF +;
					"   AND D_E_L_E_T_ = ' '"
			
			cALias := MpSysOpenQuery(_cQry)

			if (!(cAlias)->(Eof()))
				Z0T->(DbGoTo( (cAlias)->recno ) )
				If Z0T->(Recno()) == (cAlias)->recno
					// =SE(E(I2+J1<=$R$1;F2=F1);I2+J1;I2)
					If cProdAtual+aDados[nI, 03]/* qTMP->QTD_POR_TRATO */ <= (MV_PAR01+MV_PAR02) .AND.;
							cDietAnt == aDados[nI, 04] /* qTMP->DIETA */ 

						cProdAtual += aDados[nI, 03] // qTMP->QTD_POR_TRATO
					Else
						nRotaAtual += 1
						cProdAtual := aDados[nI, 03]
					EndIf
					RecLock("Z0T", .F.)
						Z0T->Z0T_ROTA := "ROTA" + StrZero(nRotaAtual,2)
						Z0T->Z0T_LOTE := aDados[nI, 02]
					Z0T->(MSUnlock())

					nComplet += 1 // tesando aqui pois tem lote que nao esta recebendo ROTEIRO
					aDados[nI, 05] := .T.
				EndIf
			EndIf
			(cAlias)->(DbCloseArea())
		
			//ANTERIOR
			_cLinAnt := Left(aDados[nI, 01], 1)
			cDietAnt := aDados[ nI, 04] // qTMP->DIETA
		EndIf

		If nI == Len(aDados)
			nI := 0
		EndIf
	EndDo

	/* versao do toshio */
	_cQry := " WITH TRATO_DIA AS ( " + CRLF
	_cQry += "		SELECT Z0T_FILIAL, Z0T_DATA, Z0T_VERSAO, Z0T_ROTA, Z0T_CURRAL, Z05_DIETA, Z05_KGMNDI, Z05_CABECA, Z05_KGMNDI*Z05_CABECA TOTAL, Z05_NROTRA " + CRLF
	_cQry += "		  FROM " + RetSqlName("Z0T") + " Z0T" + CRLF
	_cQry += "	 LEFT JOIN " + RetSqlName("Z05") + " Z05 ON " + CRLF
	_cQry += "		       Z0T_FILIAL = Z05_FILIAL  " + CRLF
	_cQry += "		   AND Z0T_DATA = Z05_DATA " + CRLF
	_cQry += "		   AND Z0T_VERSAO = Z05_VERSAO " + CRLF
	_cQry += "		   AND Z0T_CURRAL = Z05_CURRAL  " + CRLF
	_cQry += "		   AND Z05.D_E_L_E_T_ = ' '  " + CRLF
	_cQry += "	     WHERE Z0T_FILIAL = '"+FWxFilial("Z0T")+"' AND  Z0T_DATA = '" + dToS( __dDtPergunte ) + "'  " + CRLF
	_cQry += "		   AND Z0T.D_E_L_E_T_ = ' '  " + CRLF
	_cQry += "		   ) " + CRLF
	_cQry += "		SELECT Z0S_DATA, Z0S_VERSAO, Z0S_ROTA, Z05_DIETA, SUM(TOTAL) TOTAL, Z0S.R_E_C_N_O_ RECNO" + CRLF
	_cQry += "		  FROM " + RetSqlName("Z0S") + " Z0S " + CRLF
	_cQry += "     LEFT JOIN TRATO_DIA Z0T " + CRLF
	_cQry += "		    ON Z0T_FILIAL = Z0S_FILIAL " + CRLF
	_cQry += "		   AND Z0T_DATA	= Z0S_DATA  " + CRLF
	_cQry += "		   AND Z0T_VERSAO = Z0S_VERSAO " + CRLF
	_cQry += "		   AND Z0T_ROTA = Z0S_ROTA " + CRLF
	_cQry += "	     WHERE Z0S_DATA = '" + dToS( __dDtPergunte ) + "' " + CRLF
	_cQry += "		   AND D_E_L_E_T_ = ' '  " + CRLF
	_cQry += "	  GROUP BY Z0S_DATA, Z0S_VERSAO, Z0S_ROTA, Z05_DIETA, R_E_C_N_O_ " + CRLF
	_cQry += "	  ORDER BY Z0S_ROTA  " + CRLF

	MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_Totaliza_rota.SQL", _cQry)

	cAlias := MpSysOpenQuery(_cQry)

	While (!(cAlias)->(Eof()))
		If!Empty((cAlias)->Z05_DIETA)
			Z0S->(DbGoTo( (cAlias)->RECNO ) )
			RecLock("Z0S", .F.)
				Z0S->Z0S_DIETA := (cAlias)->Z05_DIETA
				Z0S->Z0S_TOTTRT := (cAlias)->TOTAL
			Z0S->(MSUnlock())
		EndIf
		(cAlias)->(DBSkip())
	EndDo
	(cAlias)->(DbCloseArea())

	// MB : 26.11.2020 -> Limpando rotas que nao foram utilizadas
	nRotaAtual += 1
	_cQryUpd := " UPDATE "+RetSqlName("Z0S")+" " + CRLF
	_cQryUpd += " 	SET Z0S_EQUIP='' " + CRLF
	_cQryUpd += " 	  , Z0S_TOTTRT=0 " + CRLF
	_cQryUpd += " 	  , Z0S_DIETA='' " + CRLF
	_cQryUpd += " 	  , Z0S_OPERAD='' " + CRLF
	_cQryUpd += " -- SELECT * " + CRLF
	_cQryUpd += " -- FROM "+RetSqlName("Z0S")+" " + CRLF
	_cQryUpd += " WHERE Z0S_FILIAL = '"+FwXFilial("Z0S")+"' "  + CRLF
	_cQryUpd += "   AND Z0S_DATA='" + dToS( __dDtPergunte ) + "'  " + CRLF
	_cQryUpd += "   AND Z0S_ROTA >= '" + "ROTA" + StrZero(nRotaAtual,2) + "' " + CRLF
	_cQryUpd += "   AND D_E_L_E_T_=' ' " + CRLF
	_cQryUpd += " -- ORDER BY Z0S_ROTA " + CRLF

	If (TCSQLExec(_cQryUpd) < 0)
		Alert("Erro ao zerar as rotas nao utilizadas: " + TCSQLError())
	Else
		MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_Update_Z0S.SQL", _cQryUpd)
	EndIf

	RestArea(aArea)
Return nil

/* 
	MB : 09.11.2020
		# Parametros para definir o processo de sugestao da ROTEIRIZAÇÃO;
*/
Static Function GeraSX1( cPerg )
	Local aArea 	:= GetArea()
	Local i	  		:= 0
	Local j     	:= 0
	Local lInclui	:= .F.
	Local aRegs		:= {}
	Local aHelpPor	:= {}
	Local aHelpSpa	:= {}
	Local aHelpEng	:= {}

	aAdd(aRegs, { cPerg, "01","Limite Produção:"    , "", "", "MV_CH1", "N",05,0,0,"G","Positivo()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","     ","N","","",""})
	aAdd(aRegs, { cPerg, "02","Tolerancia Produção:", "", "", "MV_CH2", "N",04,0,0,"G","Positivo()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","     ","N","","",""})
	aAdd(aRegs, { cPerg, "03","Pular linha:"        , "", "", "MV_CH3", "N",01,0,0,"C","          ","mv_par03","1=Sim","","","","","2=Não","","","","","","","","","","","","","","","","","","","     ","N","","",""})

	dbSelectArea("SX1")
	dbSetOrder(1)
    For i := 1 To Len(aRegs)

        If lInclui := !SX1->(dbSeek( PadR(cPerg, 10, " ") + aRegs[i,2]))
            RecLock("SX1", lInclui)
            For j := 1 to FCount()
                If j <= Len(aRegs[i])
                    FieldPut(j,aRegs[i,j])
                Endif
            Next
            MsUnlock()

            aHelpPor := {}; aHelpSpa := {}; aHelpEng := {}
            
            IF i==1
                AADD(aHelpPor,"Informe o nome do arquivo")
                AADD(aHelpPor,"a ser lido")
                AADD(aHelpPor,"")
            ElseIf i==2
                AADD(aHelpPor,"Informe o nome do arquivo")
                AADD(aHelpPor,"a ser gerado")
                AADD(aHelpPor,"")
            ENDIF
            PutSX1Help("P."+AllTrim(cPerg)+strzero(i,2)+".",aHelpPor,aHelpEng,aHelpSpa)
        EndIf

    Next
	
	RestArea(aArea)
Return

/* MB : 18.11.2020
	- validar todos foram preenchidos;
	- ao mudar de produto alterar posicao nI : vetor aDados 
	- cDietAnt : Ja acabou ? 
*/
Static Function nTodosPreenchidos( __aDads, cDieta )
Local nI := aScan( __aDads, { |x| x[4] == cDieta } )

If nI>0
	While nI <= Len(__aDads) // .and. lTodPreenchidos
		If __aDads[nI, 04] == cDieta .and. !__aDads[nI, 05]
			// lTodPreenchidos := .F.
			exit
		EndIf
		nI += 1
	EndDo
	if nI>len(__aDads)
		nI := 0
	EndIf
EndIf

return nI // lTodPreenchidos

/* MB : 26.11.2020 */
Static Function fLoadCurrais(dData, cRota)
	Local cRet   := ""
	Local cALias := ""
	Local _cQry  := ""

	_cQry := " SELECT STRING_AGG(RTRIM(Z0T_CURRAL), '; ') WITHIN GROUP(ORDER BY Z0T_CURRAL) CURRAL " + CRLF
	_cQry += " FROM " + RetSqlName("Z0T") + CRLF
	_cQry += " WHERE Z0T_FILIAL = '" + FWxFilial("Z0T") + "' " + CRLF
	_cQry += "   AND Z0T_DATA   = '" + DtoS(dData) + "' " + CRLF
	_cQry += "   AND Z0T_ROTA   = '" + cRota + "' " + CRLF
	_cQry += "   AND D_E_L_E_T_ = ' ' " + CRLF
	
	cAlias := MpSysOpenQuery(_cQry)

	If (!(cAlias)->(EOF()))
		cRet := AllTrim((cAlias)->CURRAL)
	EndIf
	(cAlias)->(DBCloseArea())

Return cRet


/* MB : 26.11.2020 */
Static Function fQtdTrato(dData, cRota)
	Local nRet := 0
	Local cALias := ""
	Local _cQry  := ""

	_cQry := " SELECT DISTINCT Z0T_ROTA, Z05_NROTRA " + CRLF
	_cQry += "  FROM " + RetSqlName("Z0T") + " Z0T" + CRLF
	_cQry += "  JOIN " + RetSqlName("Z05") + " Z05 " + CRLF
	_cQry += "        ON Z0T_FILIAL = Z05_FILIAL " + CRLF
	_cQry += "       AND Z05_DATA   = Z0T_DATA " + CRLF
	_cQry += "       AND Z0T_CURRAL = Z05_CURRAL  " + CRLF
	_cQry += "       AND Z05.D_E_L_E_T_ = ' '" + CRLF
	_cQry += " WHERE Z0T_FILIAL = '" + FwXFilial("Z0T") + "' " + CRLF
	_cQry += "   AND Z05_DATA   = '" + DtoS(dData) + "' " + CRLF
	_cQry += "   AND Z0T_ROTA   = '" + cRota + "' " + CRLF
	_cQry += "   AND Z0T.D_E_L_E_T_ = ' '" + CRLF
	
	cAlias := MpSysOpenQuery(_cQry)
				
	If (!(cAlias)->(EOF()))
		nRet := (cAlias)->Z05_NROTRA
	EndIf
	(cAlias)->(DBCloseArea())

Return nRet

Static Function MontaQuery(lShwZer, lShwGer)
	Local cQry := ""

	Default lShwZer := .T.
	Default lShwGer := .T. 

	cQry := " SELECT DISTINCT Z08.Z08_CONFNA AS CONF, Z08.Z08_TIPO AS TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA AS LINHA, Z08.Z08_SEQUEN AS SEQ " + CRLF
	cQry += "      , ISNULL(SB8.B8_LOTECTL, 'SEM LOTE') AS LOTE, Z05.Z05_CABECA AS QUANT, (SELECT MAX(Z0M1.Z0M_VERSAO) FROM " + RetSqlName("Z0M") + " Z0M1 WHERE Z0M1.Z0M_CODIGO = Z0O.Z0O_CODPLA AND Z0M1.D_E_L_E_T_ = ' ') AS PLANO " + CRLF
	cQry += "      , DATEDIFF(day, (SELECT MIN(SB8A.B8_XDATACO) FROM " + RetSqlName("SB8") + " SB8A WHERE SB8A.B8_LOTECTL = SB8.B8_LOTECTL AND SB8A.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8A.B8_SALDO > 0 AND SB8A.D_E_L_E_T_ <> '*'),  GETDATE()) AS DIAS " + CRLF //DATEDIFF(day, SB8.B8_XDATACO,  GETDATE()) AS DIAS, 
	cQry += "      --, Z05.Z05_DIETA AS DIETA " + CRLF
	cQry += "      , Z0R.Z0R_DATA AS DTTRT, Z0R.Z0R_VERSAO AS VERSAO, Z0T.Z0T_ROTA AS ROTA " + CRLF 
	cQry += "      , (SELECT DISTINCT(SB1.B1_DESC) FROM " + RetSqlName("SB1") + " SB1 WHERE SB1.B1_COD = Z05.Z05_DIETA) AS DIEDSC " + CRLF //AND Z06.Z06_CURRAL = Z08.Z08_CODIGO
	cQry += "      , Z05_DIETA DIETA" + CRLF
	cQry += "      , (SELECT COUNT(Z06.Z06_TRATO)  FROM " + RetSqlName("Z06") + " Z06 WHERE Z06.D_E_L_E_T_ <> '*' AND Z06.Z06_FILIAL = '" + xFilial('Z06') + "' AND Z06.Z06_DATA = Z0R.Z0R_DATA AND Z06.Z06_VERSAO = Z0R.Z0R_VERSAO AND Z06.Z06_LOTE = SB8.B8_LOTECTL) AS NRTRT " + CRLF
	cQry += "      , (SELECT SUM(Z04.Z04_TOTREA)   FROM " + RetSqlName("Z04") + " Z04 WHERE Z04.Z04_DTIMP  = DATEADD(dd, -1, cast('" + DTOS(aDadSel[2]) + "' as datetime)) AND Z04.Z04_FILIAL = '" + xFilial('Z04') + "' AND Z04.D_E_L_E_T_ <> '*' AND Z04.Z04_LOTE = SB8.B8_LOTECTL) AS Z04_TOTREA " + CRLF
	cQry += "      , (SELECT Z05A.Z05_KGMNDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMN " + CRLF
	cQry += "      , (SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMS " + CRLF
	cQry += "      , (SELECT Z05A.Z05_KGMNDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMNDIA " + CRLF
	cQry += "      , (SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMSDIA " + CRLF
	cQry += " FROM " + RetSqlName("Z08") + " Z08 " + CRLF
	cQry += " LEFT JOIN " + RetSqlName("SB8") + " SB8 ON SB8.B8_X_CURRA = Z08.Z08_CODIGO AND SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8.D_E_L_E_T_ <> '*' AND SB8.B8_SALDO > 0 " + CRLF
	cQry += " LEFT JOIN " + RetSqlName("Z0O") + " Z0O ON Z0O.Z0O_LOTE = SB8.B8_LOTECTL AND ('" + DTOS(aDadSel[2]) + "' BETWEEN Z0O.Z0O_DATAIN AND Z0O.Z0O_DATATR OR (Z0O.Z0O_DATAIN <= '" + DTOS(aDadSel[2]) + "' AND Z0O.Z0O_DATATR = '        ')) AND Z0O.Z0O_FILIAL = '" + xFilial("Z0O") + "' AND Z0O.D_E_L_E_T_ <> '*' " + CRLF
	cQry += " LEFT JOIN " + RetSqlName("Z0R") + " Z0R ON Z0R.Z0R_DATA = '" + DTOS(aDadSel[2]) + "' AND Z0R.Z0R_VERSAO = '" + aDadSel[3] + "' AND Z0R.Z0R_FILIAL = '" + xFilial("Z0R") + "' AND Z0R.D_E_L_E_T_ <> '*' " + CRLF
	cQry += " LEFT JOIN " + RetSqlName("Z05") + " Z05 ON Z05.Z05_DATA = Z0R.Z0R_DATA AND Z05.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05.Z05_LOTE = SB8.B8_LOTECTL AND Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.D_E_L_E_T_ <> '*' " + CRLF //AND Z05.Z05_CURRAL = SB8.B8_X_CURRA
	cQry += " LEFT JOIN " + RetSqlName("Z0T") + " Z0T ON Z0T.Z0T_DATA = Z0R.Z0R_DATA AND Z0T.Z0T_VERSAO = Z0R.Z0R_VERSAO AND Z0T.Z0T_CURRAL = Z08_CODIGO AND Z0T.Z0T_FILIAL = '" + xFilial("Z0T") + "' AND Z0T.D_E_L_E_T_ <> '*' " + CRLF //Z0T.Z0T_LINHA = Z08.Z08_LINHA AND Z0T.Z0T_SEQUEN = Z08.Z08_SEQUEN
	cQry += " WHERE Z08.D_E_L_E_T_ <> '*' " + CRLF
	cQry += "   AND Z08.Z08_FILIAL = '" + xFilial("Z08") + "' AND Z08.Z08_CONFNA <> '' " + CRLF
	cQry += "   AND Z08.Z08_MSBLQL <> '1' " + CRLF
	cQry += "   AND Z08.Z08_CONFNA IN (?) " + CRLF
	cQry += IIf(!lShwZer, " AND SB8.B8_SALDO > 0 ", "") + CRLF
	cQry += " GROUP BY Z08.Z08_CONFNA, Z08.Z08_TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA, Z08.Z08_SEQUEN, SB8.B8_LOTECTL, Z05.Z05_CABECA, Z0O.Z0O_CODPLA, Z05.Z05_DIETA, Z05.Z05_KGMNDI, Z05.Z05_KGMSDI, Z0R.Z0R_DATA, Z0R.Z0R_VERSAO, Z0T.Z0T_ROTA, Z05_FILIAL, Z05_VERSAO, Z05_DATA, Z05_LOTE" + CRLF //SB8.B8_XDATACO,
	cQry += " ORDER BY Z08.Z08_TIPO, Z08.Z08_CONFNA, Z08.Z08_LINHA, Z08.Z08_SEQUEN, Z08.Z08_CODIGO " + CRLF

	MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_ROTAMAIN.SQL", cQry)

	oRtMain := FwExecStatement():New(cQry)

	cQry := " WITH DADOS AS ( " + CRLF+;
		" 	 SELECT Z08.Z08_CONFNA AS CONF, Z08.Z08_TIPO AS TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA AS LINHA, Z08.Z08_SEQUEN AS SEQ  " + CRLF+;
		" 		  , ISNULL(SB8.B8_LOTECTL, 'SEM LOTE') AS LOTE, Z05.Z05_CABECA AS QUANT, (SELECT DISTINCT(Z0M.Z0M_DESCRI) FROM Z0M010 Z0M WHERE Z0M.Z0M_CODIGO = Z0O.Z0O_CODPLA) AS PLANO  " + CRLF+;
		" 		  , DATEDIFF(day, (SELECT MIN(SB8A.B8_XDATACO) FROM "+RetSqlName("SB8")+" SB8A WHERE SB8A.B8_LOTECTL = SB8.B8_LOTECTL AND SB8A.B8_FILIAL = '"+FWxFilial("SB8")+"' AND SB8A.B8_SALDO > 0 AND SB8A.D_E_L_E_T_ <> '*'),  GETDATE()) AS DIAS  " + CRLF+;
		"        , Z05.Z05_DIETA DIETA " + CRLF +;
		"		  , Z0R.Z0R_DATA AS DTTRT" + CRLF+;
		"		  , Z0R.Z0R_VERSAO AS VERSAO" + CRLF+;
		"		  , Z0T.Z0T_ROTA AS ROTA  " + CRLF+;
		" 		  , (SELECT DISTINCT(SB1.B1_DESC) FROM SB1010 SB1 WHERE SB1.B1_COD = Z05.Z05_DIETA) AS DIEDSC  " + CRLF+;
		" 		  , (SELECT COUNT(Z06.Z06_TRATO)  FROM Z06010 Z06 WHERE Z06.D_E_L_E_T_ <> '*' AND Z06.Z06_FILIAL = '"+FWxFilial("Z06")+"' AND Z06.Z06_DATA = Z0R.Z0R_DATA AND Z06.Z06_VERSAO = Z0R.Z0R_VERSAO AND Z06.Z06_LOTE = SB8.B8_LOTECTL) AS NRTRT  " + CRLF+;
		" 		  , (SELECT SUM(Z04.Z04_TOTREA)   FROM Z04010 Z04 WHERE Z04.Z04_DTIMP  = DATEADD(dd, -1, cast('" + dToS( __dDtPergunte ) + "' as datetime)) AND Z04.Z04_FILIAL = '"+FWxFilial("Z04")+"' AND Z04.D_E_L_E_T_ <> '*' AND Z04.Z04_LOTE = SB8.B8_LOTECTL) AS Z04_TOTREA  " + CRLF+;
		" 		  , (SELECT Z05A.Z05_KGMNDI FROM "+RetSqlName("Z05")+" Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '"+FWxFilial("Z05")+"' AND Z05A.D_E_L_E_T_ <> '*') AS KGMN  " + CRLF+;
		" 		  , (SELECT Z05A.Z05_KGMSDI FROM "+RetSqlName("Z05")+" Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '"+FWxFilial("Z05")+"' AND Z05A.D_E_L_E_T_ <> '*') AS KGMS  " + CRLF+;
		" 		  , (SELECT Z05A.Z05_KGMNDI FROM "+RetSqlName("Z05")+" Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '"+FWxFilial("Z05")+"' AND Z05A.D_E_L_E_T_ <> '*') AS KGMNDIA  " + CRLF+;
		" 		  , (SELECT Z05A.Z05_KGMSDI FROM "+RetSqlName("Z05")+" Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '"+FWxFilial("Z05")+"' AND Z05A.D_E_L_E_T_ <> '*') AS KGMSDIA  " + CRLF+;
		" 	 FROM Z08010 Z08  " + CRLF+;
		" 	 LEFT JOIN "+RetSqlName("SB8")+" SB8 ON SB8.B8_X_CURRA = Z08.Z08_CODIGO AND SB8.B8_FILIAL = '"+FWxFilial("SB8")+"' AND SB8.D_E_L_E_T_ <> '*' AND SB8.B8_SALDO > 0  " + CRLF+;
		" 	 LEFT JOIN "+RetSqlName("Z0O")+" Z0O ON Z0O.Z0O_LOTE = SB8.B8_LOTECTL AND ('" + dToS( __dDtPergunte ) + "' BETWEEN Z0O.Z0O_DATAIN AND Z0O.Z0O_DATATR OR (Z0O.Z0O_DATAIN <= '" + dToS( __dDtPergunte ) + "' AND Z0O.Z0O_DATATR = '        ')) AND Z0O.Z0O_FILIAL = '"+FWxFilial("Z0O")+"' AND Z0O.D_E_L_E_T_ <> '*'  " + CRLF+;
		" 	 LEFT JOIN "+RetSqlName("Z0R")+" Z0R ON Z0R.Z0R_DATA = '" + dToS( __dDtPergunte ) + "' AND Z0R.Z0R_VERSAO = '0001' AND Z0R.Z0R_FILIAL = '"+FWxFilial("Z0R")+"' AND Z0R.D_E_L_E_T_ <> '*'  " + CRLF+;
		" 	 LEFT JOIN "+RetSqlName("Z05")+" Z05 ON Z05.Z05_DATA = Z0R.Z0R_DATA AND Z05.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05.Z05_LOTE = SB8.B8_LOTECTL AND Z05.Z05_FILIAL = '"+FWxFilial("Z05")+"' AND Z05.D_E_L_E_T_ <> '*'  " + CRLF+;
		" 	 LEFT JOIN "+RetSqlName("Z0T")+" Z0T ON Z0T.Z0T_DATA = Z0R.Z0R_DATA AND Z0T.Z0T_VERSAO = Z0R.Z0R_VERSAO AND Z0T.Z0T_CURRAL = Z08_CODIGO AND Z0T.Z0T_FILIAL = '"+FWxFilial("Z0T")+"' AND Z0T.D_E_L_E_T_ <> '*'  " + CRLF+;
		" 	 WHERE Z08.D_E_L_E_T_ <> '*'  " + CRLF+;
		" 	   AND Z08.Z08_FILIAL = '"+FWxFilial("Z08")+"' " + CRLF+;
		"	   AND Z08.Z08_CONFNA IN (?)  " + CRLF+;
		" 	   AND Z08.Z08_MSBLQL <> '1'  " + CRLF+;
		" 	   AND SB8.B8_SALDO > 0  " + CRLF+;
		"		--AND Z05_CURRAL IN ('H01','H02','A01')" + CRLF+;
		" 	 GROUP BY Z08.Z08_CONFNA, Z08.Z08_TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA, Z08.Z08_SEQUEN, SB8.B8_LOTECTL, Z05.Z05_CABECA, Z0O.Z0O_CODPLA, Z05.Z05_DIETA, " + CRLF+;
		"			  Z05.Z05_KGMNDI, Z05.Z05_KGMSDI, Z0R.Z0R_DATA, Z0R.Z0R_VERSAO, Z0T.Z0T_ROTA, Z05_FILIAL, Z05_VERSAO, Z05_DATA, Z05_LOTE" + CRLF+;
		" ) " + CRLF+;
		"  " + CRLF+;
		" SELECT CASE	 " + CRLF+;
		" 			WHEN RTRIM(DIETA) LIKE 'FINAL'				 THEN 1  " + CRLF+;
		" 			WHEN RTRIM(DIETA) LIKE '%ADAPTACAO03%FINAL%' THEN 2 " + CRLF+;
		" 			WHEN RTRIM(DIETA) LIKE 'ADAPTACAO03'		 THEN 3 " + CRLF+;
		" 			WHEN RTRIM(DIETA) LIKE 'ADAPTACAO02'		 THEN 4 " + CRLF+;
		" 			WHEN RTRIM(DIETA) LIKE 'ADAPTACAO01'		 THEN 5 " + CRLF+;
		" 			WHEN RTRIM(DIETA) LIKE 'RECEPCAO'			 THEN 6 " + CRLF+;
		" 																		 ELSE 7 " + CRLF+;
		" 		  END ORDEM_POR_RACAO " + CRLF+;
		" 		  , CONF " + CRLF+;
		" 		  , KGMNDIA " + CRLF+;
		" 		  , NRTRT " + CRLF+;
		" 		  , QUANT " + CRLF+;
		" 		  , DIETA " + CRLF+;
		" 		  , Z08_CODIGO CURRAL " + CRLF+;
		" 		  , LOTE " + CRLF+;
		" 		  , ROUND( (KGMNDIA/NRTRT)*QUANT, 2) QTD_POR_TRATO " + CRLF+;
		" FROM DADOS " + CRLF+;
		" ORDER BY 1, 2, DIETA DESC, Z08_CODIGO "

	MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_Estrutura_E_Roteirizacao.SQL", cQry)

	oCorDie := FwExecStatement():New(cQry)

	cQry := "   WITH PROGRAMA AS (  " + CRLF
	cQry += "      SELECT DISTINCT Z08.Z08_CONFNA AS CONF, Z08.Z08_TIPO AS TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA AS LINHA, Z08.Z08_SEQUEN AS SEQ,   " + CRLF
	cQry += "             ISNULL(SB8.B8_LOTECTL, 'SEM LOTE') LOTE, Z05_DIETA DIETA, (Z05_KGMNDI*Z05_CABECA) KGMN, Z0R_DATA DTTRT  " + CRLF
	cQry += "        FROM "+RetSqlName("Z08")+" Z08       " + CRLF
	cQry += "   LEFT JOIN " + RetSqlName("SB8") + " SB8 ON   " + CRLF
	cQry += "   	         SB8.B8_X_CURRA = Z08.Z08_CODIGO   " + CRLF
	cQry += "   	     AND SB8.B8_FILIAL = '" + xFilial("SB8") + "'   " + CRLF
	cQry += "   	     AND SB8.D_E_L_E_T_ <> '*'   " + CRLF
	cQry += "   	     AND SB8.B8_SALDO > 0   " + CRLF
	cQry += "   LEFT JOIN " + RetSqlName("Z0R") + " Z0R ON   " + CRLF
	cQry += "             Z0R.Z0R_DATA = '" + DTOS(aDadSel[2]) + "'  " + CRLF
	cQry += "         AND Z0R.Z0R_FILIAL = '" + xFilial("SB8") + "'  " + CRLF
	cQry += "   	     AND Z0R.Z0R_VERSAO = '" + aDadSel[3] + "'  " + CRLF
	cQry += "   	     AND Z0R.D_E_L_E_T_ <> '*'   " + CRLF
	cQry += "   LEFT JOIN " + RetSqlName("Z05") + " Z05 ON   " + CRLF
	cQry += "             Z05.Z05_FILIAL = '" + xFilial("Z05") + "'   " + CRLF
	cQry += "         AND Z05.Z05_DATA = Z0R.Z0R_DATA   " + CRLF
	cQry += "   	     AND Z05.Z05_VERSAO = Z0R.Z0R_VERSAO   " + CRLF
	cQry += "   	     AND Z05.Z05_LOTE = SB8.B8_LOTECTL   " + CRLF
	cQry += "   	     AND Z05.Z05_CURRAL = SB8.B8_X_CURRA   " + CRLF
	cQry += "   	     AND Z05.D_E_L_E_T_ <> '*'  " + CRLF
	cQry += "       WHERE Z08_FILIAL = '" + xFilial("Z08") + "'   " + CRLF
	cQry += "         AND Z08.Z08_CONFNA IN (?)   " + CRLF
	cQry += "         AND Z08.Z08_MSBLQL <> '1'   " + CRLF
	cQry += "   	  AND B8_SALDO > 0  " + CRLF
	cQry += "   	  AND Z08.D_E_L_E_T_ = ' '   " + CRLF
	cQry += "     )  " + CRLF
	cQry += "     , DIAANT AS (  " + CRLF
	cQry += "      SELECT DISTINCT Z0T_ROTA, Z05.Z05_LOTE, Z05.Z05_CURRAL, Z05.Z05_DIETA, Z051.Z05_DIETA DIETAD1  " + CRLF
	cQry += "        FROM " + RetSqlName("Z05") + " Z05  " + CRLF
	cQry += "        JOIN " + RetSqlName("Z0T") + " Z0T ON   " + CRLF
	cQry += "             Z0T_FILIAL = '" + xFilial("Z0T") + "'   " + CRLF
	cQry += "         AND Z05.Z05_LOTE = Z0T_LOTE   " + CRLF
	cQry += "         AND Z0T_DATA = DATEADD(DAY, -1, '" + DTOS(aDadSel[2]) + "')   " + CRLF
	cQry += "         AND Z05.D_E_L_E_T_ = ' '   " + CRLF
	cQry += "   LEFT JOIN " + RetSqlName("Z05") + " Z051 ON   " + CRLF
	cQry += "             Z051.Z05_FILIAL = '" + xFilial("Z05") + "'   " + CRLF
	cQry += "   	  AND Z05.Z05_LOTE = Z051.Z05_LOTE   " + CRLF
	cQry += "   	  AND Z051.Z05_DATA = DATEADD(DAY, -1, '" + DTOS(aDadSel[2]) + "')   " + CRLF
	cQry += "   	  AND Z051.D_E_L_E_T_ = ' '   " + CRLF
	cQry += "       WHERE Z05.Z05_FILIAL = '" + xFilial("Z05") + "'   " + CRLF
	cQry += "         AND Z05.Z05_DATA = '" + DTOS(aDadSel[2]) + "' " + CRLF
	cQry += "         AND Z05.D_E_L_E_T_ = ' '   " + CRLF
	cQry += "         AND Z0T.D_E_L_E_T_ = ' '   " + CRLF
	cQry += "    GROUP BY Z0T_ROTA, Z05.Z05_DIETA, Z051.Z05_DIETA, Z05.Z05_LOTE, Z05.Z05_CURRAL  " + CRLF
	cQry += "   	)  " + CRLF
	cQry += "   	, ROTANDIETAS AS (   " + CRLF
	cQry += "      SELECT DISTINCT ZRT_ROTA, COUNT(DISTINCT Z05_DIETA) QTDDIETAS  " + CRLF
	cQry += "   	 FROM " + RetSqlName("ZRT") + "   " + CRLF
	cQry += "   	 JOIN DIAANT ON   " + CRLF
	cQry += "   	      ZRT_ROTA = Z0T_ROTA   " + CRLF
	cQry += "   	WHERE ZRT_FILIAL = '" + xFilial("ZRT") + "'  " + CRLF
	cQry += "    GROUP BY ZRT_ROTA  " + CRLF
	cQry += "    )   " + CRLF
	cQry += "       SELECT P.*,   " + CRLF //D.Z0T_ROTA ROTA
	cQry += "         CASE WHEN  QTDDIETAS = 1  AND P.DIETA = D.DIETAD1	 THEN Z0T_ROTA   " + CRLF
	cQry += "	          WHEN QTDDIETAS > 1 AND P.DIETA = D.DIETAD1	THEN  Z0T_ROTA " + CRLF
	cQry += "			  WHEN QTDDIETAS = 1 AND P.DIETA <> D.DIETAD1	THEN  Z0T_ROTA " + CRLF
	cQry += "			  ELSE ' '   END ROTA " + CRLF
	cQry += "         FROM PROGRAMA P  " + CRLF
	cQry += "    LEFT JOIN DIAANT D ON  " + CRLF
	cQry += "      		  P.LOTE = D.Z05_LOTE   " + CRLF
	cQry += "    LEFT JOIN ROTANDIETAS R ON  " + CRLF
	cQry += "			  D.Z0T_ROTA = R.ZRT_ROTA " + CRLF
	cQry += "     ORDER BY 2,3,4  " + CRLF
	
	MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_ROTAD1.SQL", cQry)

	oCorRot := FwExecStatement():New(cQry)

	cQry := "   WITH PROGRAMA AS (  " + CRLF
	cQry += "      SELECT DISTINCT Z08.Z08_CONFNA AS CONF, Z08.Z08_TIPO AS TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA AS LINHA, Z08.Z08_SEQUEN AS SEQ,   " + CRLF
	cQry += "             ISNULL(SB8.B8_LOTECTL, 'SEM LOTE') LOTE, Z05_DIETA DIETA, (Z05_KGMNDI*Z05_CABECA) KGMN, Z0R_DATA DTTRT  " + CRLF
	cQry += "        FROM " + RetSqlName("Z08") + " Z08       " + CRLF
	cQry += "   LEFT JOIN " + RetSqlName("SB8") + " SB8 ON   " + CRLF
	cQry += "   	         SB8.B8_X_CURRA = Z08.Z08_CODIGO AND SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8.D_E_L_E_T_ <> '*' AND SB8.B8_SALDO > 0   " + CRLF
	cQry += "   LEFT JOIN " + RetSqlName("Z0R") + " Z0R ON   " + CRLF
	cQry += "             Z0R.Z0R_DATA = '" + DTOS(aDadSel[2]) + "' AND Z0R.Z0R_FILIAL = '" + xFilial("Z0R") + "' AND Z0R.Z0R_VERSAO = '0001' AND Z0R.D_E_L_E_T_ <> '*'   " + CRLF
	cQry += "   LEFT JOIN " + RetSqlName("Z05") + " Z05 ON   " + CRLF
	cQry += "             Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.Z05_DATA = Z0R.Z0R_DATA   " + CRLF
	cQry += "   	     AND Z05.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05.Z05_LOTE = SB8.B8_LOTECTL AND Z05.Z05_CURRAL = SB8.B8_X_CURRA AND Z05.D_E_L_E_T_ <> '*'  " + CRLF
	cQry += "       WHERE Z08.Z08_FILIAL = '" + xFilial("Z08") + "' AND  Z08.Z08_CONFNA <> '' AND Z08.Z08_MSBLQL <> '1' AND B8_SALDO > 0 AND Z08.D_E_L_E_T_ = ' '   " + CRLF
	cQry += "     )  " + CRLF
	cQry += "     , DIAANT AS (  " + CRLF
	cQry += "      SELECT DISTINCT Z0T_ROTA, Z05.Z05_LOTE, Z05.Z05_CURRAL, Z05.Z05_DIETA, Z051.Z05_DIETA DIETAD1  " + CRLF
	cQry += "        FROM " + RetSqlName("Z05") + " Z05  " + CRLF
	cQry += "        JOIN " + RetSqlName("Z0T") + " Z0T ON Z0T_FILIAL = '" + xFilial("Z0T") + "' AND Z05.Z05_LOTE = Z0T_LOTE AND Z0T_DATA = DATEADD(DAY, -1, '" + DTOS(aDadSel[2]) + "') AND Z05.D_E_L_E_T_ = ' '   " + CRLF
	cQry += "   LEFT JOIN " + RetSqlName("Z05") + " Z051 ON   " + CRLF
	cQry += "             Z051.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.Z05_LOTE = Z051.Z05_LOTE AND Z051.Z05_DATA = DATEADD(DAY, -1, '" + DTOS(aDadSel[2]) + "') AND Z051.D_E_L_E_T_ = ' '   " + CRLF
	cQry += "       WHERE Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.Z05_DATA = '" + DTOS(aDadSel[2]) + "' AND Z05.D_E_L_E_T_ = ' ' AND Z0T.D_E_L_E_T_ = ' '   " + CRLF
	cQry += "    GROUP BY Z0T_ROTA, Z05.Z05_DIETA, Z051.Z05_DIETA, Z05.Z05_LOTE, Z05.Z05_CURRAL  " + CRLF
	cQry += "   	)  " + CRLF
	cQry += "   	, ROTANDIETAS AS (   " + CRLF
	cQry += "      SELECT DISTINCT ZRT_ROTA, COUNT(DISTINCT Z05_DIETA) QTDDIETAS  " + CRLF
	cQry += "   	 FROM " + RetSqlName("ZRT") + "   " + CRLF
	cQry += "   	 JOIN DIAANT ON   " + CRLF   
	cQry += "   	      ZRT_ROTA = Z0T_ROTA   " + CRLF
	cQry += "   	WHERE ZRT_FILIAL = '" + xFilial("ZRT") + "'  " + CRLF
	cQry += "    GROUP BY ZRT_ROTA  " + CRLF
	cQry += "    )   " + CRLF
	cQry += ",  ROTEIRO AS ( " + CRLF
	cQry += "SELECT P.*,   " + CRLF
	cQry += "         CASE WHEN  QTDDIETAS = 1 AND P.DIETA = D.DIETAD1  THEN Z0T_ROTA  " + CRLF
	cQry += "	          WHEN QTDDIETAS  > 1 AND P.DIETA = D.DIETAD1  THEN  Z0T_ROTA " + CRLF
	cQry += "			  WHEN QTDDIETAS  = 1 AND P.DIETA <> D.DIETAD1 THEN  Z0T_ROTA " + CRLF
	cQry += "			  ELSE ' '   END ROTA " + CRLF
	cQry += "         FROM PROGRAMA P  " + CRLF
	cQry += "    LEFT JOIN DIAANT D ON  " + CRLF
	cQry += "      		  P.LOTE = D.Z05_LOTE   " + CRLF
	cQry += "    LEFT JOIN ROTANDIETAS R ON  " + CRLF
	cQry += "			  D.Z0T_ROTA = R.ZRT_ROTA " + CRLF
	cQry += "     --ORDER BY 2,3,4  " + CRLF
	cQry += "	 )" + CRLF
	cQry += "	 " + CRLF
	cQry += "    SELECT DISTINCT ZRT_ROTA ROTA, ISNULL(R.DIETA, '')DIETA, ISNULL(Z0S_OPERAD, ' ') OPERAD, ISNULL(Z0S_EQUIP, ' ') EQUIP" + CRLF
	cQry += "	  FROM " + RetSqlName("ZRT") + " ZRT" + CRLF
	cQry += " LEFT JOIN ROTEIRO R ON " + CRLF
	cQry += "		   R.ROTA = ZRT_ROTA" + CRLF
	cQry += " LEFT JOIN "+RetSqlName("Z0S")+" Z0S ON " + CRLF
	cQry += "           Z0S_FILIAL = '" + xFilial("Z0S") + "' AND " + CRLF
	cQry += "		   Z0S_DATA = DATEADD(DAY, -1, R.DTTRT) AND " + CRLF
	cQry += "		   Z0S_ROTA = ZRT_ROTA AND " + CRLF
	cQry += "		   Z0S.D_E_L_E_T_ = ' '" + CRLF
	cQry += "     WHERE ZRT_FILIAL = '" + xFilial("ZRT") + "' AND ZRT.D_E_L_E_T_ = ' ' " + CRLF

	MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_ROTAS_PROGR-.SQL", cQry)

	oProRot := FwExecStatement():New(cQry)

Return
