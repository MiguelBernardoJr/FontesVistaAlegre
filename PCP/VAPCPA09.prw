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

User Function VAPCPA09()

//Local aParBox     := {}
Local cQryDtV     := ""
Local cPrgRot     := "VAPCPA09"

Private lShwZer   := .F.
Private lShwGer   := .T.
Private nOpcRotas := 1
Private aDadSel   := {}
Private aLinAlf   := {}
Private aParRet   := {}
//Private aChgDie   := {}
//Private aChgCur   := {}
//Private cChgDie   := ""
//Private cChgCur   := ""
//Private aAlf      := {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'}
Private aTik    := {LoadBitmap( GetResources(), "LBTIK" ), LoadBitmap( GetResources(), "LBNO" )}
Private __dDtPergunte := StoD("")

//AAdd(aParBox,{1,"Data      ", dDataBase, "", "", ""   , "", 50, .F.}) // aParRet[1]

//If (Len(aDadSel) == 0)
//	If (ParamBox(aParBox, "Data da Roteirizacao", @aParRet))
aDadSel := {"ROTA01", dDataBase, "0001", "03"}
//	EndIf
//EndIf

U_PosSX1({{cPrgRot, "01", DTOS(dDataBase)}})

While ((nOpcRotas > 0))

	If (Len(aParRet) < 1)
//		If (!ParamBox(aParBox, "Data da Roteirizacao", @aParRet))
		If (!Pergunte(cPrgRot, .T.))
			Return (Nil)
		EndIf
		__dDtPergunte := MV_PAR01
		
		AAdd(aParRet, MV_PAR01)
	EndIf

	cQryDtV := " SELECT MAX(Z0R.Z0R_VERSAO) AS DATVER" + CRLF
	cQryDtV += " FROM " + RetSqlName("Z0R") + " Z0R " + CRLF
	cQryDtV += " WHERE Z0R.Z0R_FILIAL = '" + xFilial("Z0R") + "' " + CRLF
	cQryDtV += "   AND Z0R.Z0R_DATA = '" + DTOS(aParRet[1]) + "' "
	cQryDtV += "   AND Z0R.D_E_L_E_T_ = ' ' " + CRLF
	
	TCQUERY cQryDtV NEW ALIAS "QRYDTV"
	
	If (!(QRYDTV->(EOF())))
		If (!Empty(QRYDTV->DATVER))
			aDadSel[3] := QRYDTV->DATVER
		EndIf
	EndIf
	
	QRYDTV->(DBCloseArea())
	
	//If (nOpcRotas = 0)
	//	aChgDie := {}
	//	aChgCur := {}
	//EndIf
	
	If (Len(aParRet) > 0)
		aDadSel[2] := aParRet[1]
		VAPCPA09A(lShwZer, lShwGer)
	Else
		nOpcRotas := 0
	EndIf
EndDo

Return (Nil)

Static Function VAPCPA09A(lPShwZer, lPShwGer)

//Local aArea := GetArea()
Local cQryRot              := ""
Local cQryRD1              := ""
Local cQryRes              := ""
Local nChvCnf              := 0
Local nChvCur              := 0
// Local QRYDIE  := GetNextAlias()
Local nCntAll              := 0
Local /*nCntCnf,*/ nCntLin := 2, nCntCur := 2
Local nRtAux               := 0
Local cChvCnf, cChvLin
//Local cSktBox, cSktCur
Local cShwZer              := ""
//Local cShwVis := ""
Local aSize                :={}, aObjects := {}, aInfo := {}, aPObjs := {}
Local aTFldr               := {}
Local oTFldr
Local oTFntGr              := TFont():New('Courier new', , 16, .T., .T.)
Local oTFntLC              := TFont():New('Courier new', , 48, .T., .T.)
Local oTFntPs              := TFont():New('Courier new', , 18, .T., .T.)
Local oTFntSb              := TFont():New('Courier new', , 16, .T., .T., , , , , .T.) // Sublinhado
Local oTFntTC              := TFont():New('Courier new', , 26, .T., .T.)
Local oTFntLg              := TFont():New('Courier new', , 18, .T., .T.)
Local oTFntLgN             := TFont():New('Courier new', , 19, .T., .T.)
Local oTFntLgT             := TFont():New('Courier new', , 22, .T., .T.)

//TFont():New( [ cName ], [ uPar2 ], [ nHeight ], [ uPar4 ], [ lBold ], [ uPar6 ], [ uPar7 ], [ uPar8 ], [ uPar9 ], [ lUnderline ], [ lItalic ] )
Local nLinLin              := 001
Local aScrCnf              := {}
Local aPnlCnf              := {}
Local nCurLin, nCurCol
Local oPnlPst
//Local oScrRot
Local aPnlRot              := {}
Local aRotCmb              := {}
//Local aVei    := {}
//Local nTmHgt  := 0
Local cDscDie              := ""
Local cLote                := ""
Local cLtCur               := ""
//Local cQtCur     := ""
Local cPlCur               := ""
//Local cDsCur     := ""
Local cDiCur               := ""
Local nCrFnt               := .F.
Local aCrDBs               := {}
Local nCrAux               := 1
Local nIndPRt              := 1
//Local nTotRD1    := 0
Local dDtTrt               := aDadSel[2]
//Local lHasButton := .T.
Local lRotD1               := .T.
Local cRotTrt              := aDadSel[1]
Local aHdrRes              := {}
Local aHdrRTr              := {}
Local aDadRD1              := {}
Local aRotD1               := {}
Local oTSTotTr/*, oTSChgCur, oTSChgDie*/
Local oTCRot
Local dDtRD1               := dDataBase
//Local cStts      := ""
Local cRotAux              := ""
Local lParRotD1            := GETMV("VA_ROTD1")
//Local cShwGer    := "asd"

Private aCrDie             := {}
Private aDadTl             := {} //Dados dos currais em linhas
Private aDdTlC             := {} //Dados dos currais em pastos
Private aLinCnf            := {}
Private aCurLin            := {}
Private aCurPst            := {}
Private aCorTl             := {}
Private aRot               := {}
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

AAdd(aCorTl, &("U_CORROTA(" + GETMV("VA_ROTBCKG") + ")")) // cor de fundo das abas
AAdd(aCorTl, &("U_CORROTA(" + GETMV("VA_ROTBLIN") + ")")) // cor de fundo das linhas
AAdd(aCorTl, &("U_CORROTA(" + GETMV("VA_ROTBCUR") + ")")) // cor de fundo dos currais
AAdd(aCorTl, &("U_CORROTA(" + GETMV("VA_ROTFTLC") + ")")) // cor fonte letra linha e numero curral
AAdd(aCorTl, &("U_CORROTA(" + GETMV("VA_ROTFCUR") + ")")) // cor fonte conteudo curral
AAdd(aCorTl, &("U_CORROTA(" + GETMV("VA_ROTCSEL") + ")")) // cor fonte curral selecionado

DBSelectArea("SX6")
SX6->(DBSetOrder(1))
While (SX6->(DBSeek(xFilial("SX6") + "VA_CRDIE" + StrZero(nCrAux,2))))
	AAdd(aCrDBs, &("U_CORROTA(" + GETMV("VA_CRDIE" + StrZero(nCrAux,2)) + ")")) //01 // 077, 074, 060
	nCrAux++
EndDo

DBSelectArea("ZRT")
ZRT->(DBSetOrder(1))
ZRT->(DBGoTop())

While (!(ZRT->(EOF())))
	If (aScan(aRot , { |x| x[1] == ZRT->ZRT_ROTA }) < 1)
		AAdd(aRot, {ZRT->ZRT_ROTA, &("U_CORROTA(" + ZRT->ZRT_COR + ")")})
		AAdd(aRotCmb, ZRT->ZRT_ROTA)
	EndIf
	ZRT->(DBSkip())
EndDo

DBSelectArea("Z05")
Z05->(DBSetOrder(1))
If (!Z05->(DBSeek(xFilial("Z05") + DTOS(aDadSel[2]) + aDadSel[3])))
	
	If (MsgYesNo("Nao foi identificado nenhum trato para a data " + DTOC(aDadSel[2]) + ". Deseja criar?", "Trato nao encontrado."))
//	(MsgYesNo("Nao existe Trato configurado para a data selecionada (" + DTOC(aDadSel[2]) + "), deseja criar? "))
	
		//U_PosSX1({{"VAPCPA05", "01", DTOS(aDadSel[2])}/*, {"VAPCPA05", "02", .T.}*/})
		//If Pergunte("VAPCPA05", .T.)		
			//----------------------------
			//Cria o trato caso necessário
			//----------------------------
			FWMsgRun(, { || U_CriaTrato(aDadSel[2])}, "Geracao de trato", "Gerando trato para o dia " + DTOC(aDadSel[2]) + "...")
			if (!Z05->(DBSeek(xFilial("Z05") + DTOS(aDadSel[2]) + aDadSel[3])))
			    nOpcRotas := 0
			    Return (Nil)
			endif
		//Else
		//	Help(,,"SELECAO DE TRATO",/**/,"Nao existe trato para o dia " + DTOC(aDadSel[2]) + ". ", 1, 1,,,,,.F.,{"Por favor, crie o trato para prosseguir." })
		//	nOpcRotas := 0
		//	Return (Nil)
		//EndIf
	Else
		Help(,,"SELECAO DE TRATO",/**/,"Nao existe trato para o dia " + DTOC(aDadSel[2]) + ". ", 1, 1,,,,,.F.,{"Por favor, crie o trato para prosseguir." })
		nOpcRotas := 0
		Return (Nil)
	EndIf
EndIf

aSize := MsAdvSize(.T.)
aObjects := {}	

AAdd( aObjects, { aSize[5], aSize[6], .F., .F. })
//AAdd( aObjects, { 100, 085, .F., .F. })

aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T.)

cQryRot := " SELECT DISTINCT Z08.Z08_CONFNA AS CONF, Z08.Z08_TIPO AS TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA AS LINHA, Z08.Z08_SEQUEN AS SEQ " + CRLF
cQryRot += "      , ISNULL(SB8.B8_LOTECTL, 'SEM LOTE') AS LOTE, Z05.Z05_CABECA AS QUANT, (SELECT MAX(Z0M1.Z0M_VERSAO) FROM " + RetSqlName("Z0M") + " Z0M1 WHERE Z0M1.Z0M_CODIGO = Z0O.Z0O_CODPLA AND Z0M1.D_E_L_E_T_ = ' ') AS PLANO " + CRLF
cQryRot += "      , DATEDIFF(day, (SELECT MIN(SB8A.B8_XDATACO) FROM " + RetSqlName("SB8") + " SB8A WHERE SB8A.B8_LOTECTL = SB8.B8_LOTECTL AND SB8A.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8A.B8_SALDO > 0 AND SB8A.D_E_L_E_T_ <> '*'),  GETDATE()) AS DIAS " + CRLF //DATEDIFF(day, SB8.B8_XDATACO,  GETDATE()) AS DIAS, 
cQryRot += "      --, Z05.Z05_DIETA AS DIETA " + CRLF
cQryRot += "      , Z0R.Z0R_DATA AS DTTRT, Z0R.Z0R_VERSAO AS VERSAO, Z0T.Z0T_ROTA AS ROTA " + CRLF 
cQryRot += "      , (SELECT DISTINCT(SB1.B1_DESC) FROM " + RetSqlName("SB1") + " SB1 WHERE SB1.B1_COD = Z05.Z05_DIETA) AS DIEDSC " + CRLF //AND Z06.Z06_CURRAL = Z08.Z08_CODIGO
cQryRot += "      , Z05_DIETA DIETA" + CRLF
//cQryRot += "      , (SELECT STRING_AGG(CONVERT(VARCHAR(1), Z06_TRATO)+'-'+RTRIM(Z06_DIETA), ';') DIETA  " + CRLF
/*cQryRot += "      		 FROM ( " + CRLF
cQryRot += "      				SELECT COUNT (Z06A.Z06_TRATO) Z06_TRATO, Z06A.Z06_DIETA  " + CRLF
cQryRot += "      				FROM "+RetSqlName("Z06")+" Z06A " + CRLF
cQryRot += "      				WHERE Z05.Z05_FILIAL = Z06A.Z06_FILIAL AND Z05.Z05_DATA = Z06A.Z06_DATA AND Z05.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05.Z05_LOTE = Z06A.Z06_LOTE AND Z06A.D_E_L_E_T_ = ' '  " + CRLF
cQryRot += "      				GROUP BY Z06A.Z06_FILIAL, Z06A.Z06_LOTE, Z06A.Z06_DIETA " + CRLF
cQryRot += "      			  ) AS TRATO  " + CRLF
cQryRot += "      	    ) DIETA " + CRLF*/
cQryRot += "      , (SELECT COUNT(Z06.Z06_TRATO)  FROM " + RetSqlName("Z06") + " Z06 WHERE Z06.D_E_L_E_T_ <> '*' AND Z06.Z06_FILIAL = '" + xFilial('Z06') + "' AND Z06.Z06_DATA = Z0R.Z0R_DATA AND Z06.Z06_VERSAO = Z0R.Z0R_VERSAO AND Z06.Z06_LOTE = SB8.B8_LOTECTL) AS NRTRT " + CRLF
cQryRot += "      , (SELECT SUM(Z04.Z04_TOTREA)   FROM " + RetSqlName("Z04") + " Z04 WHERE Z04.Z04_DTIMP  = DATEADD(dd, -1, cast('" + DTOS(aDadSel[2]) + "' as datetime)) AND Z04.Z04_FILIAL = '" + xFilial('Z04') + "' AND Z04.D_E_L_E_T_ <> '*' AND Z04.Z04_LOTE = SB8.B8_LOTECTL) AS Z04_TOTREA " + CRLF
cQryRot += "      , (SELECT Z05A.Z05_KGMNDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMN " + CRLF
cQryRot += "      , (SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMS " + CRLF
cQryRot += "      , (SELECT Z05A.Z05_KGMNDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMNDIA " + CRLF
cQryRot += "      , (SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMSDIA " + CRLF
cQryRot += " FROM " + RetSqlName("Z08") + " Z08 " + CRLF
cQryRot += " LEFT JOIN " + RetSqlName("SB8") + " SB8 ON SB8.B8_X_CURRA = Z08.Z08_CODIGO AND SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8.D_E_L_E_T_ <> '*' AND SB8.B8_SALDO > 0 " + CRLF
cQryRot += " LEFT JOIN " + RetSqlName("Z0O") + " Z0O ON Z0O.Z0O_LOTE = SB8.B8_LOTECTL AND ('" + DTOS(aDadSel[2]) + "' BETWEEN Z0O.Z0O_DATAIN AND Z0O.Z0O_DATATR OR (Z0O.Z0O_DATAIN <= '" + DTOS(aDadSel[2]) + "' AND Z0O.Z0O_DATATR = '        ')) AND Z0O.Z0O_FILIAL = '" + xFilial("Z0O") + "' AND Z0O.D_E_L_E_T_ <> '*' " + CRLF
cQryRot += " LEFT JOIN " + RetSqlName("Z0R") + " Z0R ON Z0R.Z0R_DATA = '" + DTOS(aDadSel[2]) + "' AND Z0R.Z0R_VERSAO = '" + aDadSel[3] + "' AND Z0R.Z0R_FILIAL = '" + xFilial("Z0R") + "' AND Z0R.D_E_L_E_T_ <> '*' " + CRLF
cQryRot += " LEFT JOIN " + RetSqlName("Z05") + " Z05 ON Z05.Z05_DATA = Z0R.Z0R_DATA AND Z05.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05.Z05_LOTE = SB8.B8_LOTECTL AND Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.D_E_L_E_T_ <> '*' " + CRLF //AND Z05.Z05_CURRAL = SB8.B8_X_CURRA
cQryRot += " LEFT JOIN " + RetSqlName("Z0T") + " Z0T ON Z0T.Z0T_DATA = Z0R.Z0R_DATA AND Z0T.Z0T_VERSAO = Z0R.Z0R_VERSAO AND Z0T.Z0T_CURRAL = Z08_CODIGO AND Z0T.Z0T_FILIAL = '" + xFilial("Z0T") + "' AND Z0T.D_E_L_E_T_ <> '*' " + CRLF //Z0T.Z0T_LINHA = Z08.Z08_LINHA AND Z0T.Z0T_SEQUEN = Z08.Z08_SEQUEN
cQryRot += " WHERE Z08.D_E_L_E_T_ <> '*' " + CRLF
cQryRot += "   AND Z08.Z08_FILIAL = '" + xFilial("Z08") + "' AND Z08.Z08_CONFNA <> '' " + CRLF
cQryRot += "   AND Z08.Z08_MSBLQL <> '1' " + CRLF
cQryRot += IIf(!lShwZer, " AND SB8.B8_SALDO > 0 ", "") + CRLF
cQryRot += " GROUP BY Z08.Z08_CONFNA, Z08.Z08_TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA, Z08.Z08_SEQUEN, SB8.B8_LOTECTL, Z05.Z05_CABECA, Z0O.Z0O_CODPLA, Z05.Z05_DIETA, Z05.Z05_KGMNDI, Z05.Z05_KGMSDI, Z0R.Z0R_DATA, Z0R.Z0R_VERSAO, Z0T.Z0T_ROTA, Z05_FILIAL, Z05_VERSAO, Z05_DATA, Z05_LOTE" + CRLF //SB8.B8_XDATACO,
cQryRot += " ORDER BY Z08.Z08_TIPO, Z08.Z08_CONFNA, Z08.Z08_LINHA, Z08.Z08_SEQUEN, Z08.Z08_CODIGO " + CRLF

MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_ROTAMAIN.SQL", cQryRot)

TCQUERY cQryRot NEW ALIAS "QRYROT"

nCrAux  := 1
nLinLeg := 030
While !(QRYROT->(EOF()))
	// MONTA ESTRUTURA DE COR DA DIETA
	/*
	-> levando para outro lugar,
	-> sql criado pelo toshio
	If (ALLTRIM(QRYROT->LOTE) != 'SEM LOTE')
		If (aScan(aCrDie , { |x| x[1] == QRYROT->DIETA}) < 1)
			If (nCrAux < Len(aCrDBs))
				AAdd(aCrDie, {QRYROT->DIETA, aCrDBs[nCrAux]})
				nCrAux++
			Else
				MsgInfo("Nao existem mais cores disponiveis para as dietas! (VA_CRDIEXX). Abortando...")
				nOpcRotas := 0
				Return (Nil)
			EndIf
		EndIf
	EndIf
	*/
	// TIPO - 1 = CURRAL / 4 = PASTO 
	If (QRYROT->TIPO == '1')
		// CONF - 01 = BLOCO VELHO / 02 = BLOCO NOVO / 99 = PASTO
		If (cChvCnf != QRYROT->CONF)
			
			if Val(QRYROT->CONF)==2 .and. Empty(aDadTl)
				aadd(aTFldr, "CONFINAMENTO 01")	
				aadd(aDadTl, { "01" })
			EndIf
			
			aadd(aDadTl, {QRYROT->CONF})
			nLinCnf := Len(aDadTl)
			cChvCnf := QRYROT->CONF

			aadd(aTFldr, "CONFINAMENTO " + cChvCnf)	
			AAdd(aDadTl[nLinCnf], {QRYROT->LINHA})

			nLinCur := Len(aDadTl[nLinCnf])
			cChvLin := QRYROT->LINHA
			If (aScan(aLinAlf, { |x| x = QRYROT->LINHA}) = 0)
				AAdd(aLinAlf, QRYROT->LINHA)
			EndIf
			
			AAdd(aDadTl[nLinCnf][nLinCur], {QRYROT->SEQ, ALLTRIM(QRYROT->LOTE), QRYROT->QUANT, QRYROT->PLANO, QRYROT->DIAS, QRYROT->DIETA, IIf(QRYROT->DIAS = 1, QRYROT->KGMN, QRYROT->KGMNDIA ), IIf(QRYROT->DIAS == 1, QRYROT->KGMS, QRYROT->KGMSDIA ), QRYROT->ROTA, QRYROT->CONF, QRYROT->Z08_CODIGO, QRYROT->DIEDSC})
		Else
			If (cChvLin != QRYROT->LINHA)
				AAdd(aDadTl[nLinCnf], {QRYROT->LINHA})
				nLinCur := Len(aDadTl[nLinCnf])
				cChvLin := QRYROT->LINHA
				If (aScan(aLinAlf, { |x| x = QRYROT->LINHA}) = 0)
					AAdd(aLinAlf, QRYROT->LINHA)
				EndIf
				AAdd(aDadTl[nLinCnf][nLinCur], {QRYROT->SEQ, ALLTRIM(QRYROT->LOTE), QRYROT->QUANT, QRYROT->PLANO, QRYROT->DIAS, QRYROT->DIETA, IIf(QRYROT->DIAS = 1, QRYROT->KGMN, QRYROT->KGMNDIA ), IIf(QRYROT->DIAS == 1, QRYROT->KGMS, QRYROT->KGMSDIA ), QRYROT->ROTA, QRYROT->CONF, QRYROT->Z08_CODIGO, QRYROT->DIEDSC})
			Else	
				AAdd(aDadTl[nLinCnf][nLinCur], {QRYROT->SEQ, ALLTRIM(QRYROT->LOTE), QRYROT->QUANT, QRYROT->PLANO, QRYROT->DIAS, QRYROT->DIETA, IIf(QRYROT->DIAS = 1, QRYROT->KGMN, QRYROT->KGMNDIA ), IIf(QRYROT->DIAS == 1, QRYROT->KGMS, QRYROT->KGMSDIA ), QRYROT->ROTA, QRYROT->CONF, QRYROT->Z08_CODIGO, QRYROT->DIEDSC})
			EndIf
		EndIf
	ElseIf (QRYROT->TIPO == '4')
		
		AAdd(aDdTlC, {QRYROT->LINHA, QRYROT->SEQ, ALLTRIM(QRYROT->LOTE), QRYROT->QUANT, QRYROT->PLANO, QRYROT->DIAS, QRYROT->DIETA, IIf(QRYROT->DIAS == 1, QRYROT->KGMN, QRYROT->KGMNDIA), IIf(QRYROT->DIAS == 1, QRYROT->KGMS, QRYROT->KGMSDIA), QRYROT->ROTA, QRYROT->CONF, QRYROT->Z08_CODIGO, QRYROT->DIEDSC})
	EndIf
	
	If (!Empty(QRYROT->ROTA))
		nTotCRt := nTotCRt + 1
	EndIf
	
	nTotCur := nTotCur + 1
	
	QRYROT->(DBSkip())
EndDo
QRYROT->(DBCloseArea())

If (Len(aTFldr)==1)
	aAdd(aTFldr, "CONFINAMENTO 02")
EndIf

// MONTA ESTRUTURA DE COR DA DIETA E MONTA O ARRAY PARA PROCESAMENTO DA ROTEIRIZACAO
_cQry := " WITH DADOS AS ( " + CRLF+;
		 " 	 SELECT Z08.Z08_CONFNA AS CONF, Z08.Z08_TIPO AS TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA AS LINHA, Z08.Z08_SEQUEN AS SEQ  " + CRLF+;
		 " 		  , ISNULL(SB8.B8_LOTECTL, 'SEM LOTE') AS LOTE, Z05.Z05_CABECA AS QUANT, (SELECT DISTINCT(Z0M.Z0M_DESCRI) FROM Z0M010 Z0M WHERE Z0M.Z0M_CODIGO = Z0O.Z0O_CODPLA) AS PLANO  " + CRLF+;
		 " 		  , DATEDIFF(day, (SELECT MIN(SB8A.B8_XDATACO) FROM SB8010 SB8A WHERE SB8A.B8_LOTECTL = SB8.B8_LOTECTL AND SB8A.B8_FILIAL = '"+FWxFilial("SB8")+"' AND SB8A.B8_SALDO > 0 AND SB8A.D_E_L_E_T_ <> '*'),  GETDATE()) AS DIAS  " + CRLF+;
		 "        , Z05.Z05_DIETA DIETA " + CRLF +;
		 "		  , Z0R.Z0R_DATA AS DTTRT" + CRLF+;
		 "		  , Z0R.Z0R_VERSAO AS VERSAO" + CRLF+;
		 "		  , Z0T.Z0T_ROTA AS ROTA  " + CRLF+;
		 " 		  , (SELECT DISTINCT(SB1.B1_DESC) FROM SB1010 SB1 WHERE SB1.B1_COD = Z05.Z05_DIETA) AS DIEDSC  " + CRLF+;
		 " 		  , (SELECT COUNT(Z06.Z06_TRATO)  FROM Z06010 Z06 WHERE Z06.D_E_L_E_T_ <> '*' AND Z06.Z06_FILIAL = '"+FWxFilial("Z06")+"' AND Z06.Z06_DATA = Z0R.Z0R_DATA AND Z06.Z06_VERSAO = Z0R.Z0R_VERSAO AND Z06.Z06_LOTE = SB8.B8_LOTECTL) AS NRTRT  " + CRLF+;
		 " 		  , (SELECT SUM(Z04.Z04_TOTREA)   FROM Z04010 Z04 WHERE Z04.Z04_DTIMP  = DATEADD(dd, -1, cast('" + dToS( __dDtPergunte ) + "' as datetime)) AND Z04.Z04_FILIAL = '"+FWxFilial("Z04")+"' AND Z04.D_E_L_E_T_ <> '*' AND Z04.Z04_LOTE = SB8.B8_LOTECTL) AS Z04_TOTREA  " + CRLF+;
		 " 		  , (SELECT Z05A.Z05_KGMNDI FROM Z05010 Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '"+FWxFilial("Z05")+"' AND Z05A.D_E_L_E_T_ <> '*') AS KGMN  " + CRLF+;
		 " 		  , (SELECT Z05A.Z05_KGMSDI FROM Z05010 Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '"+FWxFilial("Z05")+"' AND Z05A.D_E_L_E_T_ <> '*') AS KGMS  " + CRLF+;
		 " 		  , (SELECT Z05A.Z05_KGMNDI FROM Z05010 Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '"+FWxFilial("Z05")+"' AND Z05A.D_E_L_E_T_ <> '*') AS KGMNDIA  " + CRLF+;
		 " 		  , (SELECT Z05A.Z05_KGMSDI FROM Z05010 Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '"+FWxFilial("Z05")+"' AND Z05A.D_E_L_E_T_ <> '*') AS KGMSDIA  " + CRLF+;
		 " 	 FROM Z08010 Z08  " + CRLF+;
		 " 	 LEFT JOIN SB8010 SB8 ON SB8.B8_X_CURRA = Z08.Z08_CODIGO AND SB8.B8_FILIAL = '"+FWxFilial("SB8")+"' AND SB8.D_E_L_E_T_ <> '*' AND SB8.B8_SALDO > 0  " + CRLF+;
		 " 	 LEFT JOIN Z0O010 Z0O ON Z0O.Z0O_LOTE = SB8.B8_LOTECTL AND ('" + dToS( __dDtPergunte ) + "' BETWEEN Z0O.Z0O_DATAIN AND Z0O.Z0O_DATATR OR (Z0O.Z0O_DATAIN <= '" + dToS( __dDtPergunte ) + "' AND Z0O.Z0O_DATATR = '        ')) AND Z0O.Z0O_FILIAL = '"+FWxFilial("Z0O")+"' AND Z0O.D_E_L_E_T_ <> '*'  " + CRLF+;
		 " 	 LEFT JOIN Z0R010 Z0R ON Z0R.Z0R_DATA = '" + dToS( __dDtPergunte ) + "' AND Z0R.Z0R_VERSAO = '0001' AND Z0R.Z0R_FILIAL = '"+FWxFilial("Z0R")+"' AND Z0R.D_E_L_E_T_ <> '*'  " + CRLF+;
		 " 	 LEFT JOIN Z05010 Z05 ON Z05.Z05_DATA = Z0R.Z0R_DATA AND Z05.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05.Z05_LOTE = SB8.B8_LOTECTL AND Z05.Z05_FILIAL = '"+FWxFilial("Z05")+"' AND Z05.D_E_L_E_T_ <> '*'  " + CRLF+;
		 " 	 LEFT JOIN Z0T010 Z0T ON Z0T.Z0T_DATA = Z0R.Z0R_DATA AND Z0T.Z0T_VERSAO = Z0R.Z0R_VERSAO AND Z0T.Z0T_CURRAL = Z08_CODIGO AND Z0T.Z0T_FILIAL = '"+FWxFilial("Z0T")+"' AND Z0T.D_E_L_E_T_ <> '*'  " + CRLF+;
		 " 	 WHERE Z08.D_E_L_E_T_ <> '*'  " + CRLF+;
		 " 	   AND Z08.Z08_FILIAL = '"+FWxFilial("Z08")+"' " + CRLF+;
		 "	   AND Z08.Z08_CONFNA <> ' '  " + CRLF+;
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

TCQUERY _cQry NEW ALIAS "QRYESTR"
MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_Estrutura_E_Roteirizacao.SQL", _cQry)

nCrAux  := 1
While !(QRYESTR->(EOF()))

	aAdd( aDadRotZao, { AllTrim(QRYESTR->CURRAL),;  // 01
					    AllTrim(QRYESTR->LOTE)  ,;  // 02
					    QRYESTR->QTD_POR_TRATO  ,;  // 03
					    AllTrim(QRYESTR->DIETA) ,;  // 04
					    .F.					  } ) // 05
	If (aScan(aCrDie , { |x| x[1] == QRYESTR->DIETA}) == 0)
		If (nCrAux < Len(aCrDBs))
			// https://shdo.wordpress.com/online/tabela-de-cores-rgb/
			AAdd(aCrDie, { QRYESTR->DIETA, aCrDBs[nCrAux] })
			nCrAux++
		Else
			MsgInfo("Nao existem mais cores disponiveis para as dietas! (VA_CRDIEXX). Abortando...")
			nOpcRotas := 0
			Return (Nil)
		EndIf
	EndIf

	QRYESTR->(DBSkip())
EndDo
QRYESTR->(DBCloseArea())
// aSort(aCrDie,,, {|x, y| cValToChar(x[4])+x[1] < cValToChar(y[4])+y[1] })

cQryRD1 := "   WITH PROGRAMA AS (  " + CRLF
cQryRD1 += "      SELECT DISTINCT Z08.Z08_CONFNA AS CONF, Z08.Z08_TIPO AS TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA AS LINHA, Z08.Z08_SEQUEN AS SEQ,   " + CRLF
cQryRD1 += "             ISNULL(SB8.B8_LOTECTL, 'SEM LOTE') LOTE, Z05_DIETA DIETA, (Z05_KGMNDI*Z05_CABECA) KGMN, Z0R_DATA DTTRT  " + CRLF
cQryRD1 += "        FROM "+RetSqlName("Z08")+" Z08       " + CRLF
cQryRD1 += "   LEFT JOIN " + RetSqlName("SB8") + " SB8 ON   " + CRLF
cQryRD1 += "   	         SB8.B8_X_CURRA = Z08.Z08_CODIGO   " + CRLF
cQryRD1 += "   	     AND SB8.B8_FILIAL = '" + xFilial("SB8") + "'   " + CRLF
cQryRD1 += "   	     AND SB8.D_E_L_E_T_ <> '*'   " + CRLF
cQryRD1 += "   	     AND SB8.B8_SALDO > 0   " + CRLF
cQryRD1 += "   LEFT JOIN " + RetSqlName("Z0R") + " Z0R ON   " + CRLF
cQryRD1 += "             Z0R.Z0R_DATA = '" + DTOS(aDadSel[2]) + "'  " + CRLF
cQryRD1 += "         AND Z0R.Z0R_FILIAL = '" + xFilial("SB8") + "'  " + CRLF
cQryRD1 += "   	     AND Z0R.Z0R_VERSAO = '" + aDadSel[3] + "'  " + CRLF
cQryRD1 += "   	     AND Z0R.D_E_L_E_T_ <> '*'   " + CRLF
cQryRD1 += "   LEFT JOIN " + RetSqlName("Z05") + " Z05 ON   " + CRLF
cQryRD1 += "             Z05.Z05_FILIAL = '" + xFilial("Z05") + "'   " + CRLF
cQryRD1 += "         AND Z05.Z05_DATA = Z0R.Z0R_DATA   " + CRLF
cQryRD1 += "   	     AND Z05.Z05_VERSAO = Z0R.Z0R_VERSAO   " + CRLF
cQryRD1 += "   	     AND Z05.Z05_LOTE = SB8.B8_LOTECTL   " + CRLF
cQryRD1 += "   	     AND Z05.Z05_CURRAL = SB8.B8_X_CURRA   " + CRLF
cQryRD1 += "   	     AND Z05.D_E_L_E_T_ <> '*'  " + CRLF
cQryRD1 += "       WHERE Z08_FILIAL = '" + xFilial("Z08") + "'   " + CRLF
cQryRD1 += "         AND Z08.Z08_CONFNA <> ''   " + CRLF
cQryRD1 += "         AND Z08.Z08_MSBLQL <> '1'   " + CRLF
cQryRD1 += "   	  AND B8_SALDO > 0  " + CRLF
cQryRD1 += "   	  AND Z08.D_E_L_E_T_ = ' '   " + CRLF
cQryRD1 += "     )  " + CRLF
cQryRD1 += "     , DIAANT AS (  " + CRLF
cQryRD1 += "      SELECT DISTINCT Z0T_ROTA, Z05.Z05_LOTE, Z05.Z05_CURRAL, Z05.Z05_DIETA, Z051.Z05_DIETA DIETAD1  " + CRLF
cQryRD1 += "        FROM " + RetSqlName("Z05") + " Z05  " + CRLF
cQryRD1 += "        JOIN " + RetSqlName("Z0T") + " Z0T ON   " + CRLF
cQryRD1 += "             Z0T_FILIAL = '" + xFilial("Z0T") + "'   " + CRLF
cQryRD1 += "         AND Z05.Z05_LOTE = Z0T_LOTE   " + CRLF
cQryRD1 += "         AND Z0T_DATA = DATEADD(DAY, -1, '" + DTOS(aDadSel[2]) + "')   " + CRLF
cQryRD1 += "         AND Z05.D_E_L_E_T_ = ' '   " + CRLF
cQryRD1 += "   LEFT JOIN " + RetSqlName("Z05") + " Z051 ON   " + CRLF
cQryRD1 += "             Z051.Z05_FILIAL = '" + xFilial("Z05") + "'   " + CRLF
cQryRD1 += "   	  AND Z05.Z05_LOTE = Z051.Z05_LOTE   " + CRLF
cQryRD1 += "   	  AND Z051.Z05_DATA = DATEADD(DAY, -1, '" + DTOS(aDadSel[2]) + "')   " + CRLF
cQryRD1 += "   	  AND Z051.D_E_L_E_T_ = ' '   " + CRLF
cQryRD1 += "       WHERE Z05.Z05_FILIAL = '" + xFilial("Z05") + "'   " + CRLF
cQryRD1 += "         AND Z05.Z05_DATA = '" + DTOS(aDadSel[2]) + "' " + CRLF
cQryRD1 += "         AND Z05.D_E_L_E_T_ = ' '   " + CRLF
cQryRD1 += "         AND Z0T.D_E_L_E_T_ = ' '   " + CRLF
cQryRD1 += "    GROUP BY Z0T_ROTA, Z05.Z05_DIETA, Z051.Z05_DIETA, Z05.Z05_LOTE, Z05.Z05_CURRAL  " + CRLF
cQryRD1 += "   	)  " + CRLF
cQryRD1 += "   	, ROTANDIETAS AS (   " + CRLF
cQryRD1 += "      SELECT DISTINCT ZRT_ROTA, COUNT(DISTINCT Z05_DIETA) QTDDIETAS  " + CRLF
cQryRD1 += "   	 FROM " + RetSqlName("ZRT") + "   " + CRLF
cQryRD1 += "   	 JOIN DIAANT ON   " + CRLF
cQryRD1 += "   	      ZRT_ROTA = Z0T_ROTA   " + CRLF
cQryRD1 += "   	WHERE ZRT_FILIAL = '" + xFilial("ZRT") + "'  " + CRLF
cQryRD1 += "    GROUP BY ZRT_ROTA  " + CRLF
cQryRD1 += "    )   " + CRLF
cQryRD1 += "       SELECT P.*,   " + CRLF //D.Z0T_ROTA ROTA
cQryRD1 += "         CASE WHEN  QTDDIETAS = 1  AND P.DIETA = D.DIETAD1	 THEN Z0T_ROTA   " + CRLF
cQryRD1 += "	          WHEN QTDDIETAS > 1 AND P.DIETA = D.DIETAD1	THEN  Z0T_ROTA " + CRLF
cQryRD1 += "			  WHEN QTDDIETAS = 1 AND P.DIETA <> D.DIETAD1	THEN  Z0T_ROTA " + CRLF
cQryRD1 += "			  ELSE ' '   END ROTA " + CRLF
cQryRD1 += "         FROM PROGRAMA P  " + CRLF
cQryRD1 += "    LEFT JOIN DIAANT D ON  " + CRLF
cQryRD1 += "      		  P.LOTE = D.Z05_LOTE   " + CRLF
cQryRD1 += "    LEFT JOIN ROTANDIETAS R ON  " + CRLF
cQryRD1 += "			  D.Z0T_ROTA = R.ZRT_ROTA " + CRLF
cQryRD1 += "     ORDER BY 2,3,4  " + CRLF
    
MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_ROTAD1.SQL", cQryRD1)

TCQUERY cQryRD1 NEW ALIAS "QRYRD1"

While (!QRYRD1->(EOF()))
	AAdd(aDadRD1, {ALLTRIM(QRYRD1->LOTE), QRYRD1->CONF, QRYRD1->LINHA, QRYRD1->SEQ, QRYRD1->Z08_CODIGO, QRYRD1->DIETA, QRYRD1->ROTA, QRYRD1->KGMN})
	QRYRD1->(DBSkip())
EndDo
QRYRD1->(DBCloseArea())

nTotCSR := nTotCur - nTotCRt

cQryDie := "   WITH PROGRAMA AS (  " + CRLF
cQryDie += "      SELECT DISTINCT Z08.Z08_CONFNA AS CONF, Z08.Z08_TIPO AS TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA AS LINHA, Z08.Z08_SEQUEN AS SEQ,   " + CRLF
cQryDie += "             ISNULL(SB8.B8_LOTECTL, 'SEM LOTE') LOTE, Z05_DIETA DIETA, (Z05_KGMNDI*Z05_CABECA) KGMN, Z0R_DATA DTTRT  " + CRLF
cQryDie += "        FROM " + RetSqlName("Z08") + " Z08       " + CRLF
cQryDie += "   LEFT JOIN " + RetSqlName("SB8") + " SB8 ON   " + CRLF
cQryDie += "   	         SB8.B8_X_CURRA = Z08.Z08_CODIGO AND SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8.D_E_L_E_T_ <> '*' AND SB8.B8_SALDO > 0   " + CRLF
cQryDie += "   LEFT JOIN " + RetSqlName("Z0R") + " Z0R ON   " + CRLF
cQryDie += "             Z0R.Z0R_DATA = '" + DTOS(aDadSel[2]) + "' AND Z0R.Z0R_FILIAL = '" + xFilial("Z0R") + "' AND Z0R.Z0R_VERSAO = '0001' AND Z0R.D_E_L_E_T_ <> '*'   " + CRLF
cQryDie += "   LEFT JOIN " + RetSqlName("Z05") + " Z05 ON   " + CRLF
cQryDie += "             Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.Z05_DATA = Z0R.Z0R_DATA   " + CRLF
cQryDie += "   	     AND Z05.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05.Z05_LOTE = SB8.B8_LOTECTL AND Z05.Z05_CURRAL = SB8.B8_X_CURRA AND Z05.D_E_L_E_T_ <> '*'  " + CRLF
cQryDie += "       WHERE Z08.Z08_FILIAL = '" + xFilial("Z08") + "' AND  Z08.Z08_CONFNA <> '' AND Z08.Z08_MSBLQL <> '1' AND B8_SALDO > 0 AND Z08.D_E_L_E_T_ = ' '   " + CRLF
cQryDie += "     )  " + CRLF
cQryDie += "     , DIAANT AS (  " + CRLF
cQryDie += "      SELECT DISTINCT Z0T_ROTA, Z05.Z05_LOTE, Z05.Z05_CURRAL, Z05.Z05_DIETA, Z051.Z05_DIETA DIETAD1  " + CRLF
cQryDie += "        FROM " + RetSqlName("Z05") + " Z05  " + CRLF
cQryDie += "        JOIN " + RetSqlName("Z0T") + " Z0T ON Z0T_FILIAL = '" + xFilial("Z0T") + "' AND Z05.Z05_LOTE = Z0T_LOTE AND Z0T_DATA = DATEADD(DAY, -1, '" + DTOS(aDadSel[2]) + "') AND Z05.D_E_L_E_T_ = ' '   " + CRLF
cQryDie += "   LEFT JOIN " + RetSqlName("Z05") + " Z051 ON   " + CRLF
cQryDie += "             Z051.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.Z05_LOTE = Z051.Z05_LOTE AND Z051.Z05_DATA = DATEADD(DAY, -1, '" + DTOS(aDadSel[2]) + "') AND Z051.D_E_L_E_T_ = ' '   " + CRLF
cQryDie += "       WHERE Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.Z05_DATA = '" + DTOS(aDadSel[2]) + "' AND Z05.D_E_L_E_T_ = ' ' AND Z0T.D_E_L_E_T_ = ' '   " + CRLF
cQryDie += "    GROUP BY Z0T_ROTA, Z05.Z05_DIETA, Z051.Z05_DIETA, Z05.Z05_LOTE, Z05.Z05_CURRAL  " + CRLF
cQryDie += "   	)  " + CRLF
cQryDie += "   	, ROTANDIETAS AS (   " + CRLF
cQryDie += "      SELECT DISTINCT ZRT_ROTA, COUNT(DISTINCT Z05_DIETA) QTDDIETAS  " + CRLF
cQryDie += "   	 FROM " + RetSqlName("ZRT") + "   " + CRLF
cQryDie += "   	 JOIN DIAANT ON   " + CRLF   
cQryDie += "   	      ZRT_ROTA = Z0T_ROTA   " + CRLF
cQryDie += "   	WHERE ZRT_FILIAL = '" + xFilial("ZRT") + "'  " + CRLF
cQryDie += "    GROUP BY ZRT_ROTA  " + CRLF
cQryDie += "    )   " + CRLF
cQryDie += ",  ROTEIRO AS ( " + CRLF
cQryDie += "SELECT P.*,   " + CRLF
cQryDie += "         CASE WHEN  QTDDIETAS = 1 AND P.DIETA = D.DIETAD1  THEN Z0T_ROTA  " + CRLF
cQryDie += "	          WHEN QTDDIETAS  > 1 AND P.DIETA = D.DIETAD1  THEN  Z0T_ROTA " + CRLF
cQryDie += "			  WHEN QTDDIETAS  = 1 AND P.DIETA <> D.DIETAD1 THEN  Z0T_ROTA " + CRLF
cQryDie += "			  ELSE ' '   END ROTA " + CRLF
cQryDie += "         FROM PROGRAMA P  " + CRLF
cQryDie += "    LEFT JOIN DIAANT D ON  " + CRLF
cQryDie += "      		  P.LOTE = D.Z05_LOTE   " + CRLF
cQryDie += "    LEFT JOIN ROTANDIETAS R ON  " + CRLF
cQryDie += "			  D.Z0T_ROTA = R.ZRT_ROTA " + CRLF
cQryDie += "     --ORDER BY 2,3,4  " + CRLF
cQryDie += "	 )" + CRLF
cQryDie += "	 " + CRLF
cQryDie += "    SELECT DISTINCT ZRT_ROTA ROTA, ISNULL(R.DIETA, '')DIETA, ISNULL(Z0S_OPERAD, ' ') OPERAD, ISNULL(Z0S_EQUIP, ' ') EQUIP" + CRLF
cQryDie += "	  FROM " + RetSqlName("ZRT") + " ZRT" + CRLF
cQryDie += " LEFT JOIN ROTEIRO R ON " + CRLF
cQryDie += "		   R.ROTA = ZRT_ROTA" + CRLF
cQryDie += " LEFT JOIN "+RetSqlName("Z0S")+" Z0S ON " + CRLF
cQryDie += "           Z0S_FILIAL = '" + xFilial("Z0S") + "' AND " + CRLF
cQryDie += "		   Z0S_DATA = DATEADD(DAY, -1, R.DTTRT) AND " + CRLF
cQryDie += "		   Z0S_ROTA = ZRT_ROTA AND " + CRLF
cQryDie += "		   Z0S.D_E_L_E_T_ = ' '" + CRLF
cQryDie += "     WHERE ZRT_FILIAL = '" + xFilial("ZRT") + "' AND ZRT.D_E_L_E_T_ = ' ' " + CRLF

MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_ROTAS_PROGR-"+ DTOS(aDadSel[2]) +".SQL", cQryDie)

if Select("QRYDIE") > 0
	QRYDIE->( dbCloseArea() )
endif

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, cQryDie ),"QRYDIE",.F.,.F.)

//TCQUERY cQryDie NEW ALIAS "QRYDIE"

DBSelectArea("Z0S")
Z0S->(DBSetOrder(1))

If (!(Z0S->(DBSeek(xFilial("Z0S") + DTOS(aDadSel[2]) + aDadSel[3])))) //+aDadSel[1]
	
	DBSelectArea("Z0S")
	Z0S->(DBSetOrder(1))
	
	If (Z0S->(DBSeek(xFilial("Z0S") + DTOS(DaySub(aDadSel[2],1)) + aDadSel[3])))
		
		dDtRD1 := Z0S->Z0S_DATA
		
		While (Z0S->Z0S_DATA == dDtRD1 .AND. Z0S->Z0S_VERSAO == aDadSel[3])

			While (!QRYDIE->(EOF())) // ADICIOANR REGISTROS 
		/*
			27/05/2020 - Arthur Toshio
			Alteração Para verificar se no dia anterior o trato = 0 durante a geração da Z0S
		*/
				AAdd(aRotD1, {QRYDIE->ROTA, QRYDIE->EQUIP, 0, QRYDIE->DIETA, QRYDIE->OPERAD})
				QRYDIE->(DBSkip())
			EndDo	
			Z0S->(DbCloseArea())
		EndDo
		QRYDIE->(DbCloseArea())
		
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
		
			For nCntLin := 2 To Len(aDadTl[nCntAll])
			
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
		
		For nCntAll := 1 To Len(aDdTlC)

			lRotD1 := .T.
			If ((nRtAux := aScan(aDadRD1, { |x| x[1] = aDdTlC[nCntAll][03]})) > 0)
				
				If (aDadRD1[nRtAux][05] != aDdTlC[nCntAll][12])
					If (!lParRotD1)
						lRotD1 := .F.
					EndIf
				EndIf
				
				If (aDadRD1[nRtAux][06] != aDdTlC[nCntAll][07])
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
				Z0T->Z0T_CONF   := aDdTlC[nCntAll][11]
				Z0T->Z0T_LINHA  := aDdTlC[nCntAll][01]
				Z0T->Z0T_SEQUEN := aDdTlC[nCntAll][02]
				Z0T->Z0T_CURRAL := aDdTlC[nCntAll][12]
				Z0T->Z0T_LOTE   := aDdTlC[nCntAll][03]
			Z0T->(MSUnlock())

			If (lRotD1)
				If (Z0S->(DBSeek(xFilial("Z0S") + DTOS(aDadSel[2]) + aDadSel[3] + cRotAux)))
					RecLock("Z0S", .F.)
						Z0S->Z0S_TOTTRT := Z0S->Z0S_TOTTRT + aDadRD1[nRtAux][08]
					Z0S->(MSUnlock())
				EndIf
				
				aDdTlC[nCntAll][10] := aDadRD1[nRtAux][07]
			EndIf
		Next nCntAll
	EndIf
	
ElseIf (Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+aDadSel[1])))
	nTotTrt := Z0S->Z0S_TOTTRT
Else
	nTotTrt := 0
EndIf
		
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

AAdd(aTFldr, "VISAO GERAL")
AAdd(aTFldr, "PASTO")
AAdd(aTFldr, "RESUMO")


nColLeg := (aPObjs[1][4]/2) - 080 - 20 //nColLeg := aSize[6] - 460
aOperador 		:= StrTokArr(GetMV("MV_OPERADO") + ";",";") 
cOper1 := AllTrim(Posicione("Z0U",1,xFilial("Z0U")+aOperador[1],"Z0U_NOME"))
cOper2 := AllTrim(Posicione("Z0U",1,xFilial("Z0U")+aOperador[2],"Z0U_NOME"))

DEFINE MSDIALOG oDlgRotas TITLE OemToAnsi("Rotas do Trato") From aPObjs[1][1], aPObjs[1][2] To aPObjs[1][3], aPObjs[1][4] of oDlgRotas PIXEL 
 
/*Toshio - 20220921
Operador
*/ 
	//TSay():New(005, 380, {|| "Qtd de Tratos:"}, oDlgRotas,,oTFntLg,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
 	oTSTotTr := TSay():New(001, (aPObjs[1][4]/2) - 250, {|| "Operador1: "+AllTrim(cOper1)+" / Operador2: "+AllTrim(cOper2)}, oDlgRotas,,oTFntLg,,,,.T., CLR_RED, CLR_WHITE, 200, 20)

 	TSay():New(005, 005, {|| "Data Trato"}, oDlgRotas,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
 	TGet():New(015, 005, {|| dDtTrt}, oDlgRotas, 100, 016, "@D",,,,oTFntGr,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"dDtTrt")
 
 	TSay():New(005, 110, {|| "Rotas"}, oDlgRotas,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
 	oTCRot := TComboBox():New(015, 110, {|u| If(PCount() == 0, cRotTrt, cRotTrt := u)}, aRotCmb, 100, 20, oDlgRotas,,,, CLR_BLACK, CLR_WHITE,.T.,,,,,,,,,"cRotTrt")
 	oTCRot:bChange := {|| aDadSel[1] := cRotTrt, nOpcRotas := 3, oDlgRotas:End()}
 
	_nLin := 35
 	TSay():New(_nLin, nCol:=005, {|| "Total Selecionado Trato:"}, oDlgRotas,,oTFntLg,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
 	oTSTotTr := TSay():New(_nLin, nCol+=110, {|| TRANSFORM(nTotTrt, "@E 999,999,999.99")}, oDlgRotas,,oTFntLg,,,,.T., CLR_RED, CLR_WHITE, 200, 20)
	nQtdTrt := fQtdTrato(aParRet[1], aDadSel[1])
	TSay():New(_nLin, nCol+=65, {|| "Qtd de Tratos:"}, oDlgRotas,,oTFntLg,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
 	oTSTotTr := TSay():New(_nLin, nCol+60, {|| TRANSFORM(nQtdTrt, "@E 99")}, oDlgRotas,,oTFntLg,,,,.T., CLR_RED, CLR_WHITE, 200, 20)


	_cCurral := fLoadCurrais(aParRet[1], aDadSel[1])
	_nLin := 45
	TSay():New(_nLin, 005, {|| "Currais Selecionados:"}, oDlgRotas,,oTFntLg,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
 	oTSTotTr := TSay():New(_nLin, 100, {|| AllTrim(_cCurral)}, oDlgRotas,,oTFntLg,,,,.T., CLR_RED, CLR_WHITE, 260, 30)
  
 	tButton():New(010, (aPObjs[1][4]/2) - 280, "Sugerir Rotas"      , oDlgRotas, {|| nOpcRotas := 3, SugRotas(), oDlgRotas:End()}, 60, 15,,,, .T.) // "Cria\Recria Trato"
 	//tButton():New(010, (aPObjs[1][4]/2) - 220, "Cria\Recria Trato", oDlgRotas, {|| nOpcRotas := 3, U_RecriaTrato(), oDlgRotas:End()}, 60, 15,,,, .T.) // "Cria\Recria Trato"
 	tButton():New(010, (aPObjs[1][4]/2) - 220, "Zerar Rota"       , oDlgRotas, {|| nOpcRotas := 3, ZERROT(), oDlgRotas:End()}, 60, 15,,,, .T.) // "Cria\Recria Trato"
 	tButton():New(010, (aPObjs[1][4]/2) - 160, "Operador Pá"       , oDlgRotas, {|| nOpcRotas := 3, U_AltOpePC(), oDlgRotas:End()}, 60, 15,,,, .T.) // "Cria\Recria Trato"
 	//tButton():New(010, (aPObjs[1][4]/2) - 160, cShwGer            , oDlgRotas, {|| nOpcRotas := 2, oDlgRotas:End()}          , 60, 15,,,, .T.) // "Visao Geral ?" "Visao Detalhada ?"
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
			TSay():New(nLinLeg, nColLeg-(90*3), &("{|| '" + ALLTRIM(cDscDie) + "'}"), oDlgRotas,,oTFntLgT,,,,.T.,;
						aCrDie[nCntAll][2], CLR_WHITE, 140, 15)
			nColDieta++
		ElseIf nColDieta == 2
			TSay():New(nLinLeg, nColLeg-(90*2), &("{|| '" + ALLTRIM(cDscDie) + "'}"), oDlgRotas,,oTFntLgT,,,,.T.,;
						aCrDie[nCntAll][2], CLR_WHITE, 140, 15)
			nColDieta++
		ElseIf nColDieta == 3
			TSay():New(nLinLeg, nColLeg-(90*1), &("{|| '" + ALLTRIM(cDscDie) + "'}"), oDlgRotas,,oTFntLgT,,,,.T.,;
						aCrDie[nCntAll][2], CLR_WHITE, 140, 15)
			nColDieta++
		Else
			TSay():New(nLinLeg, nColLeg, &("{|| '" + ALLTRIM(cDscDie) + "'}"), oDlgRotas,,oTFntLgT,,,,.T.,;
						aCrDie[nCntAll][2], CLR_WHITE, 140, 15)
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
			nChvCnf := VAL(cChvCnf)
			
			If (lPShwGer)
				AAdd(aScrCnf, TScrollArea():New(oTFldr:aDialogs[Len(oTFldr:aDialogs) - 2], 005, ((((aPObjs[1][4]/2)/Len(aDadTl))) * Len(aPnlRot)) + 10, (aPObjs[1][3]/2) - 150, (((aPObjs[1][4]/2)/Len(aDadTl))), .T., .T.))
				AAdd(aPnlRot, TPanel():New(010, ((((aPObjs[1][4]/2)/Len(aDadTl))) * Len(aPnlRot)) + 10, aTFldr[nChvCnf], aScrCnf[nChvCnf], oTFntTC, .F.,, aCorTl[4], aCorTl[1], (((aPObjs[1][4]/2)/Len(aDadTl))), (065 * (Len(aDadTl[nCntAll]))) - 015)) // , 
				AAdd(aLinCnf, {})
				AAdd(aCurLin, {})
				nIndPRt := Len(aPnlRot)
				
				aScrCnf[nChvCnf]:SetFrame(aPnlRot[nIndPRt])
				
				nLinLin := 020
			Else
				//ScrollArea:New([aoWnd], [anTop], [anLeft], [anHeight], [anWidth], [alVertical], [alHorizontal], [alBorder])
				AAdd(aScrCnf, TScrollArea():New(oTFldr:aDialogs[nChvCnf], 001, 001, (aPObjs[1][3]/2), (aPObjs[1][4]/2), .T., .T.)) 
				AAdd(aPnlCnf, TPanel():New(001, 001,, aScrCnf[nChvCnf], oTFntGr, .T.,, aCorTl[4], aCorTl[1], (aPObjs[1][4]/2), (160 * (Len(aDadTl[nCntAll]) + 1)))) //
				AAdd(aLinCnf, {})
				AAdd(aCurLin, {})
				
				aScrCnf[nChvCnf]:SetFrame(aPnlCnf[nChvCnf])
			EndIf  
			
		EndIf
		
		For nCntLin := 2 To Len(aDadTl[nCntAll])
			
			If (cChvLin != aDadTl[nCntAll][nCntLin][01])
			
				cChvLin := aDadTl[nCntAll][nCntLin][01]
				
				If (lPShwGer)
					AAdd(aLinCnf[nChvCnf], TPanel():New(nLinLin, 005, ALLTRIM(cChvLin), aPnlRot[nIndPRt], oTFntLC, .T.,, aCorTl[4], aCorTl[1], 010, 040)) //painel inicio da linha
					
					aLinCnf[nChvCnf][Len(aLinCnf[nChvCnf])]:bLClicked := &("{|| (U_SelLin('" + cChvCnf + "', '" + STR(nCntLin - 1) + "'))}")
					
					                         //linha inicial, coluna inicial                                       //tamanho coluna, tamanho linha
					AAdd(aLinCnf[nChvCnf], TPanel():New(nLinLin, 015,, aPnlRot[nIndPRt], oTFntGr, .T.,, aCorTl[4], aCorTl[2], (030 * (Len(aDadTl[nCntAll][nCntLin]) - 1)) + 001, 040)) //painel da linha
					AAdd(aCurLin[nChvCnf], {})
				Else
					AAdd(aLinCnf[nChvCnf], TPanel():New(nLinLin, 005, ALLTRIM(cChvLin), aPnlCnf[nChvCnf], oTFntLC, .T.,, aCorTl[4], aCorTl[1], 010, 090)) //painel inicio da linha
					
					aLinCnf[nChvCnf][Len(aLinCnf[nChvCnf])]:bLClicked := &("{|| (U_SelLin('" + cChvCnf + "', '" + STR(nCntLin - 1) + "'))}")
					
					                         //linha inicial, coluna inicial                                       //tamanho coluna, tamanho linha
					AAdd(aLinCnf[nChvCnf], TPanel():New(nLinLin, 020,, aPnlCnf[nChvCnf], oTFntGr, .T.,, aCorTl[4], aCorTl[2], (065 * (Len(aDadTl[nCntAll][nCntLin]) - 1)) + 005, 090)) //painel da linha
					AAdd(aCurLin[nChvCnf], {})
				EndIf
				
			EndIf
			
			For nCntCur := 2 To Len(aDadTl[nCntAll][nCntLin])
				
				cLote  := aDadTl[nCntAll][nCntLin][nCntCur][02]
				cLtCur := aDadTl[nCntAll][nCntLin][nCntCur][09] + "' + Chr(10) + '" + aDadTl[nCntAll][nCntLin][nCntCur][02]
				cQtCab := ALLTRIM(STR(aDadTl[nCntAll][nCntLin][nCntCur][03], 4)) + "' + Chr(10) + '"
				cPlCur := ALLTRIM(aDadTl[nCntAll][nCntLin][nCntCur][12]) + "' + Chr(10) + '" + ALLTRIM(STR(aDadTl[nCntAll][nCntLin][nCntCur][05])) + "' + Chr(10) + '" + TRANSFORM((aDadTl[nCntAll][nCntLin][nCntCur][07] * aDadTl[nCntAll][nCntLin][nCntCur][03]), "@E 999,999.99")
//				cDsCur := ALLTRIM(STR(aDadTl[nCntAll][nCntLin][nCntCur][05]))
				cDiCur := aDadTl[nCntAll][nCntLin][nCntCur][06] 
				
				If(aDadTl[nCntAll][nCntLin][nCntCur][09] = aDadSel[1])
					if (aScan(aRot, {|x| x[1] = aDadSel[1]}) == 0)
						nCrFnt := CLR_WHITE
					Else
						nCrFnt := aRot[aScan(aRot, {|x| x[1] = aDadSel[1]})][2] //aCorTl[6]
					EndIf
					//nCrFnt := aRot[aScan(aRot, {|x| x[1] = aDadSel[1]})][2] //aCorTl[6]
				ElseIf (Empty(aDadTl[nCntAll][nCntLin][nCntCur][09]))
					nCrFnt := CLR_WHITE //aCorTl[4]
				Else
					nCrFnt := CLR_WHITE//aRot[aScan(aRot, {|x| x[1] = aDadTl[nCntAll][nCntLin][nCntCur][09]})][2] //CLR_RED
				EndIf
				
				nCrAux := aScan(aCrDie, {|x| x[1] = cDiCur})
				
				//nCrFnt := CLR_WHITE
				// aba resumo
				If (lPShwGer)
										
					AAdd(aCurLin[nChvCnf][nCntLin - 1], TPanel():New(000, nCurCol-005, aDadTl[nCntAll][nCntLin][nCntCur][01], aLinCnf[nChvCnf][Len(aLinCnf[nChvCnf])], oTFntLC, .T.,, IIf(nCrFnt = CLR_WHITE, CLR_BLACK, CLR_WHITE)/*nCrFnt*/, nCrFnt/*aCorTl[1]*/, 032, 010)) //cabecalho curral com o numero
					AAdd(aCurLin[nChvCnf][nCntLin - 1], TPanel():New(012, nCurCol-003,, aLinCnf[nChvCnf][Len(aLinCnf[nChvCnf])], oTFntGr, .T.,, aCorTl[5], IIf(cLtCur = 'SEM LOTE' .OR. nCrAux < 1, CLR_GRAY, aCrDie[nCrAux][2]), 026, 026)) //interior do curral onde sao apresentados os dados
					
					nChvCur := Len(aCurLin[nChvCnf][nCntLin - 1])
					
					If (cQtCab != '0')
					
						cLtCur += "' + Chr(10) + '" + cQtCab + ALLTRIM(STR(aDadTl[nCntAll][nCntLin][nCntCur][05]))
						
						TSay():New(002, 002, &("{|| '" + cLtCur + "'}"), aCurLin[nChvCnf][nCntLin - 1][nChvCur],,oTFntPs,,,,.T., aCorTl[5], IIf(cLtCur = 'SEM LOTE' .OR. nCrAux < 1, CLR_GRAY, aCrDie[nCrAux][2]), 200, 050)
					
						aCurLin[nChvCnf][nCntLin - 1][nChvCur]:bLClicked := &("{|| (U_SelCur('" + cChvCnf + "', '" + STR(nCntLin - 1) + "', '" + STR(nChvCur) + "'))}")
						aCurLin[nChvCnf][nCntLin - 1][nChvCur - 1]:TagGroup := 1

						AAdd(aCurLin[nChvCnf][nCntLin - 1][nChvCur]:aControls, (aDadTl[nCntAll][nCntLin][nCntCur][07] * aDadTl[nCntAll][nCntLin][nCntCur][03]))
						AAdd(aCurLin[nChvCnf][nCntLin - 1][nChvCur]:aControls, cChvLin)
						AAdd(aCurLin[nChvCnf][nCntLin - 1][nChvCur]:aControls, aDadTl[nCntAll][nCntLin][nCntCur][01])
						AAdd(aCurLin[nChvCnf][nCntLin - 1][nChvCur]:aControls, cDiCur)
						AAdd(aCurLin[nChvCnf][nCntLin - 1][nChvCur]:aControls, aDadTl[nCntAll][nCntLin][nCntCur][02])
					EndIf
				
					nCurCol := nCurCol + 030
				// aba RESUMO ou CONFINAMENTOS
				ElseIf (IIf(oTFldr:nOption == (Len(oTFldr:aDialogs) - 1), aDadTl[nCntAll][nCntLin][nCntCur][10] == "99", aDadTl[nCntAll][nCntLin][nCntCur][10] == aDadSel[4]))
				
					AAdd(aCurLin[nChvCnf][nCntLin - 1], TPanel():New(000, nCurCol-005, aDadTl[nCntAll][nCntLin][nCntCur][01], aLinCnf[nChvCnf][Len(aLinCnf[nChvCnf])], oTFntLC, .T.,, IIf(nCrFnt = CLR_WHITE, CLR_BLACK, CLR_WHITE), nCrFnt/*aCorTl[1]*/, 072, 015))
					AAdd(aCurLin[nChvCnf][nCntLin - 1], TPanel():New(018, nCurCol,, aLinCnf[nChvCnf][Len(aLinCnf[nChvCnf])], oTFntGr, .T.,, aCorTl[5], IIf(cLtCur = 'SEM LOTE' .OR. nCrAux < 1, CLR_GRAY, aCrDie[nCrAux][2]), 060, 068))
					
					nChvCur := Len(aCurLin[nChvCnf][nCntLin - 1])
					
					If (cQtCab != '0')
					
						TSay():New(005, 005, &("{|| '" + cLtCur + "' + ' - ' + '" + cQtCab + "' + '" + cPlCur + "'}"), aCurLin[nChvCnf][nCntLin - 1][nChvCur],,oTFntPs,,,,.T., aCorTl[5], IIf(cLtCur = 'SEM LOTE' .OR. nCrAux < 1, CLR_GRAY, aCrDie[nCrAux][2]), 200, 100)
					
						aCurLin[nChvCnf][nCntLin - 1][nChvCur]:bLClicked := &("{|| (U_SelCur('" + cChvCnf + "', '" + STR(nCntLin - 1) + "', '" + STR(nChvCur) + "'))}")
						aCurLin[nChvCnf][nCntLin - 1][nChvCur - 1]:TagGroup := 1
						AAdd(aCurLin[nChvCnf][nCntLin - 1][nChvCur]:aControls, (aDadTl[nCntAll][nCntLin][nCntCur][07] * aDadTl[nCntAll][nCntLin][nCntCur][03]))
						AAdd(aCurLin[nChvCnf][nCntLin - 1][nChvCur]:aControls, cChvLin)
						AAdd(aCurLin[nChvCnf][nCntLin - 1][nChvCur]:aControls, aDadTl[nCntAll][nCntLin][nCntCur][01])
						AAdd(aCurLin[nChvCnf][nCntLin - 1][nChvCur]:aControls, cDiCur)
						AAdd(aCurLin[nChvCnf][nCntLin - 1][nChvCur]:aControls, aDadTl[nCntAll][nCntLin][nCntCur][02])
					
//						TSay():New(005, 040, &("{|| '" + cQtCab + "'}"), aCurLin[nChvCnf][nCntLin - 1][nChvCur],,oTFntSb,,,,.T., aCorTl[5], IIf(cLtCur = 'SEM LOTE', CLR_GRAY, aCrDie[nCrAux][2]), 200, 20)
//						TSay():New(015, 005, &("{|| '" + cPlCur + "'}"), aCurLin[nChvCnf][nCntLin - 1][nChvCur],,oTFntGr,,,,.T., aCorTl[5], IIf(cLtCur = 'SEM LOTE', CLR_GRAY, aCrDie[nCrAux][2]), 200, 40)
//						TSay():New(025, 005, &("{|| '" + cDsCur + "'}"), aCurLin[nChvCnf][nCntLin - 1][nChvCur],,oTFntGr,,,,.T., aCorTl[5], IIf(cLtCur = 'SEM LOTE', CLR_GRAY, aCrDie[nCrAux][2]), 200, 20)
						
						tButton():New(050, 001, "TRT", aCurLin[nChvCnf][nCntLin - 1][nChvCur], &("{|| U_VP05Form(aDadSel[2], aDadSel[3], '" + ALLTRIM(cChvLin) + ALLTRIM(aDadTl[nCntAll][nCntLin][nCntCur][01]) + "', '" + cLote + "')}"), 15, 15,,oTFntGr,, .T.)
						tButton():New(050, 022, "KDX", aCurLin[nChvCnf][nCntLin - 1][nChvCur], &("{|| U_VAESTR16({{'" + cLote + "', '" + AllTrim(cChvLin) + aDadTl[nCntAll][nCntLin][nCntCur][01] + "'}}) }"), 15, 15,,oTFntGr,, .T.) 
						tButton():New(050, 044, "INF", aCurLin[nChvCnf][nCntLin - 1][nChvCur], &("{|| U_VAPCPM01('" + cLote + "') }"), 15, 15,,oTFntGr,, .T.) 
//						tButton():New([anRow], [anCol], [acCaption], [aoWnd], [abAction], [anWidth], [anHeight], [nPar8], [aoFont], [lPar10], [alPixel],[lPar12],[cPar13], [lPar14], [abWhen], [bPar16], [lPar17]) 
	
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
	
	// Preenche a aba de Pastos
	If (lPShwGer)	
		AAdd(aScrCnf, TScrollArea():New(oTFldr:aDialogs[Len(oTFldr:aDialogs) - 2], (aPObjs[1][3]/2) - 100, 001      , 100        , (aPObjs[1][4]/2), .T., .T.))
		oPnlPst := TPanel():New(010, 010,, aScrCnf[Len(aScrCnf)], oTFntPs, .T.,, CLR_BLACK, aCorTl[1], (aPObjs[1][4]/2), (160 * ((Len(aDdTlC)/(((085 * aPObjs[1][3])/100)/060)+1)))) //, (aPObjs[1][3]/2))
	Else
		AAdd(aScrCnf, TScrollArea():New(oTFldr:aDialogs[Len(oTFldr:aDialogs) - 1], 001, 001, aPObjs[1][3], (aPObjs[1][4]/2), .T., .T.))		
		oPnlPst := TPanel():New(001, 001,, aScrCnf[Len(aScrCnf)], oTFntPs, .T.,, CLR_BLACK, aCorTl[1], (aPObjs[1][4]/2), (350 * ((Len(aDdTlC)/(((085 * aPObjs[1][3])/100)/060)+1))))
	EndIf
	
	oPnlPst:bLClicked := {|| U_SelLin("99", "", .T.)}
	aScrCnf[Len(aScrCnf)]:SetFrame(oPnlPst)
	
	AAdd(aPnlCnf, oPnlPst)
	
	nCurLin := 005
	nCurCol := 005
	
	For nCntAll := 1 To Len(aDdTlC)

		cLtCur := aDdTlC[nCntAll][10] + "' + Chr(10) + '" + aDdTlC[nCntAll][03]
		cQtCab := ALLTRIM(STR(aDdTlC[nCntAll][04], 4)) + "' + Chr(10) + '"
		cPlCur := ALLTRIM(aDdTlC[nCntAll][13]) + "' + Chr(10) + '" + ALLTRIM(STR(aDdTlC[nCntAll][06])) + "' + Chr(10) + '" + TRANSFORM((aDdTlC[nCntAll][08] * aDdTlC[nCntAll][04]), "@E 999,999.99")
//		cDsCur := ALLTRIM(STR(aDdTlC[nCntAll][06]))
		cDiCur := aDdTlC[nCntAll][07] 
						
		If(aDdTlC[nCntAll][10] == aDadSel[1])
			nCrFnt := aRot[aScan(aRot, {|x| x[1] = aDadSel[1]})][2] //aCorTl[6]
		ElseIf (Empty(aDdTlC[nCntAll][10]))
			nCrFnt := CLR_WHITE //aCorTl[4]
		Else
			nCrFnt := CLR_WHITE //aRot[aScan(aRot, {|x| x[1] = aDdTlC[nCntAll][10]})][2] //CLR_RED
		EndIf
				
		nCrAux := aScan(aCrDie, {|x| x[1] = cDiCur})
		// aba resumo
		If (lPShwGer)

			AAdd(aCurPst, TPanel():New(nCurLin, nCurCol + 005, ALLTRIM(aDdTlC[nCntAll][12]), oPnlPst, oTFntPs, .T.,, IIf(nCrFnt = CLR_WHITE, CLR_BLACK, CLR_WHITE)/*nCrFnt*/, nCrFnt/*aCorTl[1]*/, 030, 010))
			AAdd(aCurPst, TPanel():New(nCurLin + 010, nCurCol + 005,, oPnlPst, oTFntGr, .T.,, aCorTl[5], IIf(cLtCur = 'SEM LOTE' .OR. nCrAux < 1, CLR_GRAY, aCrDie[nCrAux][2]), 030, 030))
		
			nChvCur := Len(aCurPst)
			
			If (cQtCab != '0')
	
				cLtCur += "' + Chr(10) + '" + cQtCab + ALLTRIM(STR(aDdTlC[nCntAll][06])) 
	
				TSay():New(002, 005, &("{|| '" + cLtCur + "'}"), aCurPst[nChvCur],,oTFntGr,,,,.T., aCorTl[5], IIf(cLtCur = 'SEM LOTE' .OR. nCrAux < 1, CLR_GRAY, aCrDie[nCrAux][2]), 200, 050)
				
				aCurPst[nChvCur]:bLClicked := &("{|| (U_SelCur('" + aDdTlC[nCntAll][11] + "', '" + aDdTlC[nCntAll][01] + "', '" + STR(nChvCur) + "', .T.))}")
				aCurPst[nChvCur - 1]:TagGroup := 1

				AAdd(aCurPst[nChvCur]:aControls, (aDdTlC[nCntAll][08] * aDdTlC[nCntAll][04]))
				AAdd(aCurPst[nChvCur]:aControls, (aDdTlC[nCntAll][01]))
				AAdd(aCurPst[nChvCur]:aControls, (aDdTlC[nCntAll][02]))
				AAdd(aCurPst[nChvCur]:aControls, cDiCur)
				AAdd(aCurPst[nChvCur]:aControls, aDdTlC[nCntAll][03])
				AAdd(aCurPst[nChvCur]:aControls, aDdTlC[nCntAll][12])
				
			EndIf
			
			nCurCol := nCurCol + 035
		
			If ((aPObjs[1][4]/2) < (nCurCol + 035))
				nCurCol := 005
				nCurLin := nCurLin + 050
			EndIf
		
		ElseIf (IIf(oTFldr:nOption == (Len(oTFldr:aDialogs) - 1), aDdTlC[nCntAll][11] == "99", aDdTlC[nCntAll][11] == aDadSel[4]))
				
			AAdd(aCurPst, TPanel():New(nCurLin, nCurCol, ALLTRIM(aDdTlC[nCntAll][12]), oPnlPst, oTFntPs, .T.,, IIf(nCrFnt = CLR_WHITE, CLR_BLACK, CLR_WHITE)/*nCrFnt*/, nCrFnt/*aCorTl[1]*/, 060, 015))
			AAdd(aCurPst, TPanel():New(nCurLin + 015, nCurCol,, oPnlPst, oTFntGr, .T.,, aCorTl[5], IIf(cLtCur = 'SEM LOTE' .OR. nCrAux < 1, CLR_GRAY, aCrDie[nCrAux][2]), 060, 068))
		
			nChvCur := Len(aCurPst)
			
			If (cQtCab != '0')
			
				TSay():New(005, 005, &("{|| '" + cLtCur + "' + ' - ' + '" + cQtCab + "' + '" + cPlCur + "'}"), aCurPst[nChvCur],,oTFntGr,,,,.T., aCorTl[5], IIf(cLtCur = 'SEM LOTE' .OR. nCrAux < 1, CLR_GRAY, aCrDie[nCrAux][2]), 200, 100)
				
				aCurPst[nChvCur]:bLClicked := &("{|| (U_SelCur('" + aDdTlC[nCntAll][11] + "', '" + aDdTlC[nCntAll][01] + "', '" + STR(nChvCur) + "', .T.))}")
				aCurPst[nChvCur - 1]:TagGroup := 1

				AAdd(aCurPst[nChvCur]:aControls, (aDdTlC[nCntAll][08] * aDdTlC[nCntAll][04]))
				AAdd(aCurPst[nChvCur]:aControls, (aDdTlC[nCntAll][01]))
				AAdd(aCurPst[nChvCur]:aControls, (aDdTlC[nCntAll][02]))
				AAdd(aCurPst[nChvCur]:aControls, cDiCur)
				AAdd(aCurPst[nChvCur]:aControls, aDdTlC[nCntAll][03])
				AAdd(aCurPst[nChvCur]:aControls, aDdTlC[nCntAll][12])
	
				tButton():New(050, 001, "TRT", aCurPst[nChvCur], &("{|| U_VP05Form(aDadSel[2], aDadSel[3], '" + ALLTRIM(aDdTlC[nCntAll][01]) + ALLTRIM(aDdTlC[nCntAll][02]) + "', '" + cLtCur + "')}"), 15, 15,,oTFntGr,, .T.) 
				tButton():New(050, 022, "KDX", aCurPst[nChvCur], &("{|| U_VAESTR16({{'" + cLtCur + "', '" + aDdTlC[nCntAll][01] + aDdTlC[nCntAll][02] + "'}}) }"), 15, 15,,oTFntGr,, .T.) 
				tButton():New(050, 044, "INF", aCurPst[nChvCur], &("{|| U_VAPCPM01('" + cLtCur + "') }"), 15, 15,,oTFntGr,, .T.) 
				
			EndIf
			
			nCurCol := nCurCol + 065
		
			If ((aPObjs[1][4]/2) < (nCurCol + 070))
				nCurCol := 005
				nCurLin := nCurLin + 100
			EndIf
			
		EndIf
		
	Next nCntAll
	
	// Preenche a aba de Resumo
	If (!lPShwGer)
	
		If (oTFldr:nOption = Len(oTFldr:aDialogs))
	
		 	TSay():New(010, 005, {|| "Total Currais:"}, oTFldr:aDialogs[Len(oTFldr:aDialogs)],,oTFntLg,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
		 	TSay():New(010, 120, {|| TRANSFORM(nTotCur, "@E 999,999,999.99")}, oTFldr:aDialogs[Len(oTFldr:aDialogs)],,oTFntLg,,,,.T., CLR_RED, CLR_WHITE, 200, 20)
		 	
		 	TSay():New(025, 005, {|| "Total Currais em Rotas:"}, oTFldr:aDialogs[Len(oTFldr:aDialogs)],,oTFntLg,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
		 	TSay():New(025, 120, {|| TRANSFORM(nTotCRt, "@E 999,999,999.99")}, oTFldr:aDialogs[Len(oTFldr:aDialogs)],,oTFntLg,,,,.T., CLR_RED, CLR_WHITE, 200, 20)
		 	
		 	TSay():New(040, 005, {|| "Total Currais SEM Rotas:"}, oTFldr:aDialogs[Len(oTFldr:aDialogs)],,oTFntLg,,,,.T., CLR_BLACK, CLR_WHITE, 200, 20)
		 	TSay():New(040, 120, {|| TRANSFORM(nTotCSR, "@E 999,999,999.99")}, oTFldr:aDialogs[Len(oTFldr:aDialogs)],,oTFntLg,,,,.T., CLR_RED, CLR_WHITE, 200, 20)
		 	
		 	AAdd(aHdrRes, {"Rota"         , "ROTA"       , ""                 , 10, 0, ""                      , "", "C", "ZRT"   , "R", "", "", "", "V"})
			AAdd(aHdrRes, {"Dieta"        , "DIETA"      , ""                 , 20, 0, ""                      , "", "C", ""      , "R", "", "", "", "V"})
//			AAdd(aHdrRes, {"Descricao"    , "DSCDIE"     , ""                 , 40, 0, ""                      , "", "C", ""      , "R", "", "", "", "V"})
			AAdd(aHdrRes, {"Total Trato"  , "TOTTRT"     , "@E 999,999,999.99", 14, 2, ""                      , "", "N", ""      , "R", "", "", "", "V"})
			AAdd(aHdrRes, {"Veiculo"      , "VEIC"       , ""                 , 06, 0, "U_GRVVEI(&(ReadVar()))", "", "C", "ZV0VEI", "R", "", "", "", "A"})
			AAdd(aHdrRes, {"Descricao"    , "DSCVEI"     , ""                 , 20, 0, ""                      , "", "C", ""      , "R", "", "", "", "V"})
			AAdd(aHdrRes, {"Capacidade"   , "CPVEIC"     , "@E 999,999.999   ", 10, 3, ""                      , "", "N", ""      , "R", "", "", "", "V"})
			AAdd(aHdrRes, {"Operador"     , "OPVEIC"     , ""                 , 14, 0, "U_GRVOPR(&(ReadVar()))", "", "C", "Z0U"   , "R", "", "", "", "A"})
			AAdd(aHdrRes, {"Descricao"    , "DSCOPE"     , ""                 , 20, 0, ""                      , "", "C", ""      , "R", "", "", "", "V"})
			//AAdd(aHdrRes, {"Quant. Trato" , "Z05_NROTRA" , "@E 99"            , 02, 2, ""                      , "", "N", ""      , "R", "", "", "", "V"})
			AAdd(aHdrRes, {"Lista Currais", "CURRAIS"     , ""                 , 40, 0, ""                      , "", "C", ""      , "R", "", "", "", "V"})
			//AAdd(aHdrRes, {"Status"     , "STATUS" , ""                 , 20, 0, ""                      , "", "C", ""      , "R", "", "", "", "V"})
			//AAdd(aHdrRes, {"Cod.Arquivo", "CODARQ" , ""                 , 10, 0, ""                      , "", "C", ""      , "R", "", "", "", "V"})
			
			AAdd(aHdrRTr, {"Trato"      , "TRATO" , ""                 , 10, 0, ""                      , "", "C", ""      , "R", "", "", "", "V"})
			AAdd(aHdrRTr, {"Total Trato", "TOTTRT" , "@E 999,999,999.99", 14, 2, ""                      , "", "N", ""      , "R", "", "", "", "V"})
	
			aClsRes := {}
			aClsRTr := {}
			
            // Atualizar Z0S
			cQryRes := " with ROT as ( " + CRLF +;
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

			MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_Resumo.SQL", cQryRes)
			
			TCQUERY cQryRes NEW ALIAS "QRYRES"
			
			While (!QRYRES->(EOF()))
				AAdd(aClsRes, {QRYRES->ROTA,;
				 			   QRYRES->DIETA,; // POSICIONE("SB1", 1, FWxFilial("SB1") + QRYRES->DIETA, "B1_DESC"),;
				 			   QRYRES->TOTTRT,; 
				 			   QRYRES->EQUIP,;
				 			   POSICIONE("ZV0", 1, FWxFilial("ZV0") + QRYRES->EQUIP, "ZV0_DESC"),;
				 			   QRYRES->CAPAC,;
				 			   QRYRES->OPERAD,;
				 			   POSICIONE("Z0U", 1, FWxFilial("Z0U") + QRYRES->OPERAD, "Z0U_NOME"),;
				 			   ; //cStts,;
				 			   ; //QRYRES->CODARQ,;
				 			   QRYRES->CURRAIS,;
				 			   .F.})
			
				QRYRES->(DBSkip()) 
			EndDo
			QRYRES->(DBCloseArea())
	//				   MsNewGetDados():New( Top, Left                   , Bottom         ,  Right  , [ nStyle], [ cLinhaOk]  , [ cTudoOk]   , [ cIniCpos]  , [ aAlter]         , F, Max, [ cFieldOk]  ,   ,              , [ oWnd]                              , [ aPartHeader], [ aParCols], [ uChange], [ cTela], [ aColsSize] )
			oGrdRTr := MsNewGetDados():New( 005, (aPObjs[1][4]/2) - 100, 085             , (aPObjs[1][4]/2),          , "AllwaysTrue", "AllwaysTrue",              ,                   , 0, 999, "AllwaysTrue", "", "AllwaysTrue", oTFldr:aDialogs[Len(oTFldr:aDialogs)], aHdrRTr       , aClsRTr)
			oGrdRes := MsNewGetDados():New( 090, 005                   , (aPObjs[1][3]/2), (aPObjs[1][4]/2), GD_UPDATE, "AllwaysTrue", "AllwaysTrue",              , {"VEIC", "OPVEIC"}, 0, 999, "AllwaysTrue", "", "AllwaysTrue", oTFldr:aDialogs[Len(oTFldr:aDialogs)], aHdrRes       , aClsRes, {|| U_ChgTrR(n)})
			oGrdRes:oBrowse:SetBlkBackColor({|| SetClrResumo(oGrdRes) })
		EndIf
	EndIf
	
ACTIVATE MSDIALOG oDlgRotas CENTERED

If (nOpcRotas == 1)
	lShwZer := !lShwZer
EndIf

If (nOpcRotas == 2)
	lShwGer := !lShwGer
EndIf

Return (Nil)

/*
	MB : 20.07.2021
		-> Setar linha de acordo com a paleta de cor
*/
Static Function SetClrResumo(oObj)
Local nCor		:= RGB(254,254,254)
Local aColsAux  := oObj:aCols
Local nAt		:= oObj:nAt
Local nPos	    := 0
/*
If (nPos:=aScan(aCrDie , { |x| AllTrim(x[1]) == AllTrim(aColsAux[ nAt, 2]) })) > 0
	nCor := aCrDie[nPos, 2]
EndIf
*/
Return nCor

/* =================================================================================================================== */
User Function SelLin(cChvCnf, cChvLin, lPasto)

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

Default lPasto := .F.

//DBSelectArea("Z0S")
//Z0S->(DBSetOrder(1))

DBSelectArea("Z0T")
Z0T->(DBSetOrder(3))

If (!lPasto)

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
					Z0T->Z0T_CURRAL := ALLTRIM(aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[2]) + ALLTRIM(aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[3])
					Z0T->Z0T_LOTE   := aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[5]
				Z0T->(MSUnlock())
				nTotCRt := nTotCRt - 1
			EndIf
			
			If (lCnt)
		
				If ((aCurLin[nIndCnf][nIndLin][nCntCur]:nClrPane != nCrRot)) //aCorTl[4]
					aCurLin[nIndCnf][nIndLin][nCntCur]:nClrPane := nCrRot
					nTotTrt += aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[1]
					nVlrSub := aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[1]
					cRot := aDadSel[1]
					nTotCRt := nTotCRt + 1
					
					//U_ChgDieCur(ALLTRIM(aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[2]) + ALLTRIM(aCurLin[nIndCnf][nIndLin][nCntCur + 1]:aControls[3]))
					
				ElseIf ((aCurLin[nIndCnf][nIndLin][nCntCur]:nClrPane == nCrRot))
					aCurLin[nIndCnf][nIndLin][nCntCur]:nClrPane := aCorTl[1] //aCorTl[4]
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
								/*Toshio - Verificar seleção*/ 
							Z0S->(MSUnlock())
						EndIf
						
						Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+cRot))

						cRotSub := ""
					EndIf
				EndIf
				
			EndIf
			
		EndIf
		
	Next nCntCur

Else

	For nCntCur := 1 To Len(aCurPst)
	
		If (aCurPst[nCntCur]:TagGroup == 1)
	
			cDiCur := aCurPst[nCntCur + 1]:aControls[4]
	
			If (!Empty(Z0S->Z0S_DIETA))
				If (!(Z0S->Z0S_DIETA $ cDiCur))
					MsgInfo("Dieta '" + ALLTRIM(POSICIONE("SB1", 1, xFilial("SB1") + cDiCur, "B1_DESC")) + "' nao e a mesma dos outros currais na " + aDadSel[1] + ". Curral nao selecionado")
					Return (Nil)
				EndIf
			EndIf
	
			cChvTab := xFilial("Z0T") + DTOS(aDadSel[2]) + aDadSel[3] + cChvCnf + aCurPst[nCntCur + 1]:aControls[2] + aCurPst[nCntCur + 1]:aControls[3]
		
			If (Z0T->(DBSeek(cChvTab)))
				If (!Empty(Z0T->Z0T_ROTA) .AND. Z0T->Z0T_ROTA != aDadSel[1])
					If (MsgYesNo("O curral " + ALLTRIM(STR(nCntCur/2)) + " esta associado a Rota: '" + Z0T->Z0T_ROTA + "' . Deseja susbstituir pela '" + aDadSel[1] + "' ?", "Curral encontrado em outra Rota."))
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
					Z0T->Z0T_LINHA  := aCurPst[nCntCur + 1]:aControls[2]
					Z0T->Z0T_SEQUEN := aCurPst[nCntCur + 1]:aControls[3]
					Z0T->Z0T_CURRAL := aCurPst[nCntCur + 1]:aControls[6]
					Z0T->Z0T_LOTE   := aCurPst[nCntCur + 1]:aControls[5]
				Z0T->(MSUnlock())
				nTotCRt := nTotCRt - 1
			EndIf
			
			If (lCnt)
	
				If ((aCurPst[nCntCur]:nClrPane != nCrRot)) //aCorTl[4]
					aCurPst[nCntCur]:nClrPane := nCrRot
					nTotTrt += aCurPst[nCntCur + 1]:aControls[1]
					nVlrSub := aCurPst[nCntCur + 1]:aControls[1]
					cRot := aDadSel[1]
					nTotCRt := nTotCRt + 1
				elseIf ((aCurPst[nCntCur]:nClrPane == nCrRot))
					aCurPst[nCntCur]:nClrPane := aCorTl[1] //aCorTl[4]
					nTotTrt -= aCurPst[nCntCur + 1]:aControls[1]
					cRot := Space(6)
					nTotCRt := nTotCRt - 1
				EndIf
	
				RecLock("Z0S", .F.)
					Z0S->Z0S_DIETA  := cDiCur
					Z0S->Z0S_TOTTRT := nTotTrt
				Z0S->(MSUnlock())
						
				RecLock("Z0T", .F.)
					Z0T->Z0T_ROTA := cRot
					Z0T->Z0T_LOTE   := aCurPst[nCntCur + 1]:aControls[5]
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
EndIf

nTotCSR := nTotCur - nTotCRt

If (nTotTrt = 0)
	RecLock("Z0S", .F.)
		Z0S->Z0S_DIETA := ""
		//Z0S->Z0S_EQUIP := ""
		//Z0S->Z0S_OPERAD:= ""
	Z0S->(MSUnlock())
EndIf

// MB : 27.11.2020
_cCurral := fLoadCurrais(aParRet[1], aDadSel[1])

Return (Nil)


User Function SelCur(cChvCnf, cChvLin, cChvCur, lPasto)

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
Local cCur    := ""
Local cLote    := ""

Default lPasto := .F.

//DBSelectArea("Z0S")
//Z0S->(DBSetOrder(1))

If (!(Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+aDadSel[1]))))
	Return (Nil)
EndIf

DBSelectArea("Z0T")
Z0T->(DBSetOrder(3))

If (!lPasto)
	cDiCur := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[4]
	cCur   := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[2] + aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[3]
Else
	cDiCur := aCurPst[nIndCur]:aControls[4]
	cCur   := aCurPst[nIndCur]:aControls[2] + aCurPst[nIndCur]:aControls[3]
EndIf

If (!Empty(Z0S->Z0S_DIETA))
	If (!(Z0S->Z0S_DIETA $ cDiCur))
		MsgInfo("Dieta '" + ALLTRIM(POSICIONE("SB1", 1, xFilial("SB1") + cDiCur, "B1_DESC")) + "' nao e a mesma dos outros currais na " + aDadSel[1] + ". Curral nao selecionado")
		Return (Nil)
	EndIf
EndIf

//If (!lPasto)
	cChvTab := xFilial("Z0T") + DTOS(aDadSel[2]) + aDadSel[3] + cChvCnf + cCur //aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[2] + aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[3]
//Else
//	cChvTab := xFilial("Z0T") + DTOS(aDadSel[2]) + aDadSel[3] + cChvCnf + cCur //aCurPst[nIndCur]:aControls[2] + aCurPst[nIndCur]:aControls[3]
//EndIf

If (Z0T->(DBSeek(cChvTab)))
	If (!Empty(Z0T->Z0T_ROTA) .AND. Z0T->Z0T_ROTA != aDadSel[1])
		If (MsgYesNo("O curral " + ALLTRIM(STR(nIndCur/2)) + If (!lPasto, " na linha " + ALLTRIM(aLinAlf[nIndLin]) + " do confinamento " + ALLTRIM(cChvCnf), " do Pasto ") + " esta associado a Rota: '" + Z0T->Z0T_ROTA + "' . Deseja susbstituir pela '" + aDadSel[1] + "' ?", "Curral encontrado em outra Rota."))
			cRotSub := Z0T->Z0T_ROTA
			nTotCRt := nTotCRt - 1
		Else
			lCnt := .F.
		EndIf
	EndIf
Else
	If (!lPasto)
		RecLock("Z0T", .T.)
			Z0T->Z0T_FILIAL := xFilial("Z0T")
			Z0T->Z0T_DATA   := aDadSel[2]
			Z0T->Z0T_VERSAO := aDadSel[3]
			Z0T->Z0T_ROTA   := aDadSel[1]
			Z0T->Z0T_CONF   := cChvCnf
			Z0T->Z0T_LINHA  := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[2]
			Z0T->Z0T_SEQUEN := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[3]
			Z0T->Z0T_CURRAL := ALLTRIM(aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[2]) + ALLTRIM(aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[3])
			Z0T->Z0T_LOTE   := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[5]
		Z0T->(MSUnlock())
	Else
		RecLock("Z0T", .T.)
			Z0T->Z0T_FILIAL := xFilial("Z0T")
			Z0T->Z0T_DATA   := aDadSel[2]
			Z0T->Z0T_VERSAO := aDadSel[3]
			Z0T->Z0T_ROTA   := aDadSel[1]
			Z0T->Z0T_CONF   := cChvCnf
			Z0T->Z0T_LINHA  := aCurPst[nIndCur]:aControls[2]
			Z0T->Z0T_SEQUEN := aCurPst[nIndCur]:aControls[3]
			Z0T->Z0T_CURRAL := aCurPst[nIndCur]:aControls[6]
			Z0T->Z0T_LOTE   := aCurPst[nIndCur]:aControls[5]
		Z0T->(MSUnlock())
	EndIf
	nTotCRt := nTotCRt - 1
EndIf

//If (lCnt)
	If (!lPasto)
		cLote := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[5]
	
		If ((aCurLin[nIndCnf][nIndLin][nIndCur - 1]:nClrPane != nCrRot) .AND. (aCurLin[nIndCnf][nIndLin][nIndCur - 1]:TagGroup == 1)) //aCorTl[4]
			aCurLin[nIndCnf][nIndLin][nIndCur - 1]:nClrPane := nCrRot //aCorTl[6]
			nTotTrt += aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[1]
			cRot := aDadSel[1]
			nVlrSub := aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[1]
			nTotCRt := nTotCRt + 1
			//U_ChgDieCur(cCur)
		ElseIf ((aCurLin[nIndCnf][nIndLin][nIndCur - 1]:nClrPane == nCrRot) .AND. (aCurLin[nIndCnf][nIndLin][nIndCur - 1]:TagGroup == 1))
			aCurLin[nIndCnf][nIndLin][nIndCur - 1]:nClrPane := aCorTl[1] //aCorTl[4]
			nTotTrt -= aCurLin[nIndCnf][nIndLin][nIndCur]:aControls[1]
			cRot := Space(6)
			nTotCRt := nTotCRt - 1
		EndIf
		
	Else
		cLote := aCurPst[nIndCur]:aControls[5]
		
		If ((aCurPst[nIndCur - 1]:nClrPane != nCrRot) .AND. (aCurPst[nIndCur - 1]:TagGroup == 1)) //aCorTl[4]
			aCurPst[nIndCur - 1]:nClrPane := nCrRot //aCorTl[6]
			nTotTrt += aCurPst[nIndCur]:aControls[1]
			cRot := aDadSel[1]
			nVlrSub := aCurPst[nIndCur]:aControls[1]
			nTotCRt := nTotCRt + 1
		elseIf ((aCurPst[nIndCur - 1]:nClrPane == nCrRot) .AND. (aCurPst[nIndCur - 1]:TagGroup == 1))
			aCurPst[nIndCur - 1]:nClrPane := aCorTl[1] //aCorTl[4]
			nTotTrt -= aCurPst[nIndCur]:aControls[1]
			cRot := Space(6)
			nTotCRt := nTotCRt - 1
		EndIf
	
	EndIf
	//if(!lPasto)

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
			
			If (Z0S->Z0S_TOTTRT = 0)
				RecLock("Z0S", .F.)
					Z0S->Z0S_EQUIP := ""
					Z0S->Z0S_DIETA := ""
				Z0S->(MSUnlock())
			EndIf
			
			Z0S->(DBSeek(xFilial("Z0S")+DTOS(aDadSel[2])+aDadSel[3]+cRot))
			
		EndIf
	EndIf
//EndIf

nTotCSR := nTotCur - nTotCRt

If (nTotTrt = 0)
	RecLock("Z0S", .F.)
		Z0S->Z0S_DIETA := ""
		Z0S->Z0S_EQUIP := ""
		Z0S->Z0S_OPERAD:= ""
	Z0S->(MSUnlock())
EndIf

// MB : 27.11.2020
_cCurral := fLoadCurrais(aParRet[1], aDadSel[1])

Return (Nil)

/* ==================================================================================================================== */
User Function CORROTA(nRed, nGreen, nBlue)
Local nCrRt := 0
	nCrRt   := (nRed + (nGreen * 256) + (nBlue * 65536))
Return (nCrRt)

/* ==================================================================================================================== */
User Function CRRGABA(nAbaSel)
Local lRetCrA := .F.

If (aDadSel[4] != STRZERO(nAbaSel, 2))
	aDadSel[4] := STRZERO(nAbaSel, 2)
	lRetCrA := .T.
	
	If (nAbaSel = 3)
		nOpcRotas := 2
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
Local cQryTrR := ""

If (Len(aClsRes) > 0)

/*
	cQryTrR := " SELECT Z06.Z06_TRATO AS TRATO, ROUND(SUM(Z06.Z06_KGMSTR), 2) AS TOTAL" + CRLF +;
			   " FROM " + RetSqlName("Z06") + " Z06 " + CRLF +;
			   " RIGHT JOIN " + RetSqlName("Z0T") + " Z0T ON Z0T.Z0T_DATA = Z06.Z06_DATA AND Z0T.Z0T_VERSAO = Z06.Z06_VERSAO AND Z0T.Z0T_FILIAL = '" + xFilial("Z0T") + "' AND Z0T.D_E_L_E_T_ <> '*' AND Z0T.Z0T_ROTA = '" + aClsRes[nLin][1] + "' " + CRLF +;
			   " WHERE Z06.Z06_FILIAL = '" + xFilial("Z06") + "' AND Z06.D_E_L_E_T_ <> '*' " + CRLF +;
			   "   AND Z06.Z06_DATA = DATEADD(dd, -1, cast('" + DTOS(aDadSel[2]) + "' as datetime)) " + CRLF +;
			   "   AND Z06.Z06_VERSAO = '" + aDadSel[3] + "' " + CRLF +;
			   "   AND Z06.Z06_TRATO <> '' " + CRLF +;
			   " GROUP BY Z06.Z06_TRATO " + CRLF +;
			   " ORDER BY Z06.Z06_TRATO "
*/
	cQryTrR := " SELECT Z06.Z06_TRATO AS TRATO, SUM(Z06_KGMNT) TOTAL " + CRLF +;
			   "  FROM " + RetSqlName("Z06") + " Z06  " + CRLF +;
			   "  RIGHT JOIN " + RetSqlName("Z0T") + " Z0T ON Z0T.Z0T_DATA = Z06.Z06_DATA AND Z0T.Z0T_VERSAO = Z06.Z06_VERSAO AND Z0T.Z0T_FILIAL = '" + xFilial("Z0T") + "' AND Z0T.D_E_L_E_T_ <> '*' AND Z0T.Z0T_ROTA = '" + aClsRes[nLin][1] + "'  " + CRLF +;
			   "  										  AND Z0T_CURRAL = Z06_CURRAL AND Z06_LOTE = Z0T_LOTE " + CRLF +;
			   "  WHERE Z06.Z06_FILIAL = '" + xFilial("Z06") + "' AND Z06.D_E_L_E_T_ <> '*'  " + CRLF +;
			   "    AND Z06.Z06_DATA = '" + dToS(aDadSel[2]) + "' " + CRLF +; // DATEADD(dd, -1, cast('" + DTOS(aDadSel[2]) + "' as datetime)) " + CRLF +;
			   "    AND Z06.Z06_VERSAO = '" + aDadSel[3] + "' " + CRLF +;
			   "    AND Z06.Z06_TRATO <> ''  " + CRLF +;
			   "  GROUP BY Z06.Z06_TRATO  " + CRLF +;
			   "  ORDER BY Z06.Z06_TRATO "
	TCQUERY cQryTrR NEW ALIAS "QRYTRR"
	
	aClsRTr := {}
	
	While (!(QRYTRR->(EOF())))
		AAdd(aClsRTr, {QRYTRR->TRATO, QRYTRR->TOTAL, .F.})
		
		QRYTRR->(DBSkip())
	EndDo
	
	QRYTRR->(DBCloseArea())
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
Local cQryRot := ""
Local aHdrRot := {}
Local aClsRot := {}
Local nCntRot := 0 
Local nOpcRot := 0
Local lVldZer := .T.

Private oGrdF3R

AAdd(aHdrRot, {"Sel."    ,"Selecionado", "@BMP"         , 01, 0, "", "", "C", "", "R", "", "", "", "V"})
AAdd(aHdrRot, {"Rota"    ,"Rota"       , ""             , 06, 0, "", "", "C", "", "R", "", "", "", "V"})
AAdd(aHdrRot, {"Total"   ,"Total"      , "@R 999,999.99", 10, 2, "", "", "N", "", "R", "", "", "", "V"})
AAdd(aHdrRot, {"Operador","Operador"   , ""             , 20, 0, "", "", "C", "", "R", "", "", "", "V"})

cQryRot := " SELECT Z0S.Z0S_ROTA AS ROTA, Z0S.Z0S_TOTTRT AS TOTAL, Z0S.Z0S_OPERAD AS OPERAD" + CRLF
cQryRot += " FROM " + RetSqlName("Z0S") +  " Z0S " + CRLF
cQryRot += " WHERE Z0S.Z0S_FILIAL = '" + xFilial("Z0S") + "' " + CRLF
cQryRot += "   AND Z0S.Z0S_DATA = '" + DTOS(MV_PAR01) + "' " + CRLF
cQryRot += "   AND Z0S.D_E_L_E_T_ <> '*' " + CRLF
cQryRot += "   AND Z0S.Z0S_TOTTRT > 0 "
cQryRot += " ORDER BY Z0S.Z0S_ROTA "

TCQUERY cQryRot NEW ALIAS "QRYROT"

While !(QRYROT->(EOF()))

	AAdd(aClsRot, {aTik[2], QRYROT->ROTA, QRYROT->TOTAL, POSICIONE("Z0U", 1, xFilial("Z0U") + QRYROT->OPERAD, "Z0U_NOME"), .F.})
	
	QRYROT->(DBSkip())

EndDo

QRYROT->(DBCloseArea())

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
		//		lVldZer := .F.
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
		//		lVldZer := .F.
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
Local cQrySCR := ""
Local aHdrSCR := {}
Local aClsSCR := {}
Local cCntCur := "000"
Local nUniKMN := 0
Local nTotKMN := 0
Local nTotCab := 0
Local oTFntGr := TFont():New('Courier new',,16,.T.,.T.)

cQrySCR := " SELECT Z0T.Z0T_CONF AS CONF, Z0T.Z0T_LINHA AS LINHA, Z0T.Z0T_SEQUEN AS SEQ, Z0T.Z0T_CURRAL AS CURRAL, Z05.Z05_CABECA AS QTDCAB, Z05.Z05_NROTRA AS NROTRT " + CRLF +;
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

MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_CURROTA.SQL", cQrySCR)

TCQUERY cQrySCR NEW ALIAS "QRYSCR"

While (!(QRYSCR->(EOF())))

	AAdd(aClsSCR, {QRYSCR->CONF, QRYSCR->CURRAL, QRYSCR->NROTRT, QRYSCR->TOTCAB, QRYSCR->TOTKMN, (QRYSCR->TOTCAB * QRYSCR->TOTKMN), .F.})
	cCntCur := Soma1(cCntCur)
	nTotCab += QRYSCR->TOTCAB
	nUniKMN += QRYSCR->TOTKMN
	nTotKMN += (QRYSCR->QTDCAB * QRYSCR->TOTKMN)
	QRYSCR->(DBSkip())

EndDo

QRYSCR->(DBCloseArea())

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
//Local oGrdSLG
//Local cQrySLG := ""
//Local aHdrSLG := {}
//Local aClsSLG := {}
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
// Local cCntCur := 1
Local oTFntGr := TFont():New('Courier new',,16,.T.,.T.)
//Local cQryChC := ""

cQryChg := " SELECT Z05.Z05_CURRAL AS CURRAL, Z05.Z05_LOTE AS LOTE " + CRLF 
cQryChg += " FROM " + RetSqlName("Z05") + " Z05 " + CRLF
cQryChg += " JOIN " + RetSqlName("Z05") + " Z05A ON Z05A.Z05_DATA = DATEADD(dd, -1, cast(Z05.Z05_DATA as datetime)) AND Z05A.Z05_VERSAO = Z05.Z05_VERSAO AND Z05A.Z05_LOTE = Z05.Z05_LOTE AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' " + CRLF
cQryChg += " WHERE Z05.Z05_FILIAL = '" + xFilial("Z05") + "' " + CRLF
cQryChg += "   AND Z05.D_E_L_E_T_ <> '*' " + CRLF
cQryChg += "   AND Z05.Z05_DATA = '" + DTOS(aParRet[1]) + "' " + CRLF
cQryChg += "   AND Z05.Z05_CURRAL <> Z05A.Z05_CURRAL " + CRLF

TCQUERY cQryChg NEW ALIAS "QRYCHG"

While (!(QRYCHG->(EOF())))
	AAdd(aClsSCHC, {QRYCHG->LOTE, QRYCHG->CURRAL, .F.})
	QRYCHG->(DBSkip())
EndDo

QRYCHG->(DBCloseArea())

cQryChg := " SELECT Z05.Z05_CURRAL AS CURRAL, Z05.Z05_LOTE AS LOTE " + CRLF 
cQryChg += " FROM " + RetSqlName("Z05") + " Z05 " + CRLF
cQryChg += " JOIN " + RetSqlName("Z05") + " Z05A ON Z05A.Z05_DATA = DATEADD(dd, -1, cast(Z05.Z05_DATA as datetime)) AND Z05A.Z05_VERSAO = Z05.Z05_VERSAO AND Z05A.Z05_LOTE = Z05.Z05_LOTE AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' " + CRLF
cQryChg += " WHERE Z05.Z05_FILIAL = '" + xFilial("Z05") + "' " + CRLF
cQryChg += "   AND Z05.D_E_L_E_T_ <> '*' " + CRLF
cQryChg += "   AND Z05.Z05_DATA = '" + DTOS(aParRet[1]) + "' " + CRLF
cQryChg += "   AND Z05.Z05_DIETA <> Z05A.Z05_DIETA " + CRLF

TCQUERY cQryChg NEW ALIAS "QRYCHG"

While (!(QRYCHG->(EOF())))
	AAdd(aClsSCHD, {QRYCHG->LOTE, QRYCHG->CURRAL, .F.})
	QRYCHG->(DBSkip())
EndDo

QRYCHG->(DBCloseArea())

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

// Local lCtrJump    := .T.
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
		/* qTMP->DIETA */ // RACAO
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
		TCQUERY _cQry NEW ALIAS "qTMPz0t"
		if (!qTMPz0t->(Eof()))
			Z0T->(DbGoTo( qTMPz0t->recno ) )
			If Z0T->(Recno()) == qTMPz0t->recno
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
		qTMPz0t->(DbCloseArea())
	
		//ANTERIOR
		_cLinAnt := Left(aDados[nI, 01], 1)
		cDietAnt := aDados[ nI, 04] // qTMP->DIETA
	EndIf

	If nI == Len(aDados)
		nI := 0
	EndIf
EndDo

/* versao do toshio */
_cQryZ0S := " WITH TRATO_DIA AS ( " + CRLF
_cQryZ0S += "		SELECT Z0T_FILIAL, Z0T_DATA, Z0T_VERSAO, Z0T_ROTA, Z0T_CURRAL, Z05_DIETA, Z05_KGMNDI, Z05_CABECA, Z05_KGMNDI*Z05_CABECA TOTAL, Z05_NROTRA " + CRLF
_cQryZ0S += "		  FROM " + RetSqlName("Z0T") + " Z0T" + CRLF
_cQryZ0S += "	 LEFT JOIN " + RetSqlName("Z05") + " Z05 ON " + CRLF
_cQryZ0S += "		       Z0T_FILIAL = Z05_FILIAL  " + CRLF
_cQryZ0S += "		   AND Z0T_DATA = Z05_DATA " + CRLF
_cQryZ0S += "		   AND Z0T_VERSAO = Z05_VERSAO " + CRLF
_cQryZ0S += "		   AND Z0T_CURRAL = Z05_CURRAL  " + CRLF
_cQryZ0S += "		   AND Z05.D_E_L_E_T_ = ' '  " + CRLF
_cQryZ0S += "	     WHERE Z0T_FILIAL = '"+FWxFilial("Z0T")+"' AND  Z0T_DATA = '" + dToS( __dDtPergunte ) + "'  " + CRLF
_cQryZ0S += "		   AND Z0T.D_E_L_E_T_ = ' '  " + CRLF
_cQryZ0S += "		   ) " + CRLF
_cQryZ0S += "		SELECT Z0S_DATA, Z0S_VERSAO, Z0S_ROTA, Z05_DIETA, SUM(TOTAL) TOTAL, Z0S.R_E_C_N_O_ RECNO" + CRLF
_cQryZ0S += "		  FROM " + RetSqlName("Z0S") + " Z0S " + CRLF
_cQryZ0S += "     LEFT JOIN TRATO_DIA Z0T " + CRLF
_cQryZ0S += "		    ON Z0T_FILIAL = Z0S_FILIAL " + CRLF
_cQryZ0S += "		   AND Z0T_DATA	= Z0S_DATA  " + CRLF
_cQryZ0S += "		   AND Z0T_VERSAO = Z0S_VERSAO " + CRLF
_cQryZ0S += "		   AND Z0T_ROTA = Z0S_ROTA " + CRLF
_cQryZ0S += "	     WHERE Z0S_DATA = '" + dToS( __dDtPergunte ) + "' " + CRLF
_cQryZ0S += "		   AND D_E_L_E_T_ = ' '  " + CRLF
_cQryZ0S += "	  GROUP BY Z0S_DATA, Z0S_VERSAO, Z0S_ROTA, Z05_DIETA, R_E_C_N_O_ " + CRLF
_cQryZ0S += "	  ORDER BY Z0S_ROTA  " + CRLF

MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_Totaliza_rota.SQL", _cQryZ0S)

TCQUERY _cQryZ0S NEW ALIAS "qTMPZ0S"
While (!qTMPZ0S->(Eof()))
	If!Empty(qTMPZ0S->Z05_DIETA)
		Z0S->(DbGoTo( qTMPZ0S->RECNO ) )
		RecLock("Z0S", .F.)
			Z0S->Z0S_DIETA := qTMPZ0S->Z05_DIETA
			Z0S->Z0S_TOTTRT := qTMPZ0S->TOTAL
		Z0S->(MSUnlock())
	EndIf
	qTMPZ0S->(DBSkip())
EndDo
qTMPZ0S->(DbCloseArea())

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
// Local lTodPreenchidos := .T.

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
Local cRet := ""

	_cQry := " SELECT STRING_AGG(RTRIM(Z0T_CURRAL), '; ') WITHIN GROUP(ORDER BY Z0T_CURRAL) CURRAL " + CRLF
	_cQry += " FROM " + RetSqlName("Z0T") + CRLF
	_cQry += " WHERE Z0T_FILIAL = '" + FWxFilial("Z0T") + "' " + CRLF
	_cQry += "   AND Z0T_DATA   = '" + DtoS(dData) + "' " + CRLF
	_cQry += "   AND Z0T_ROTA   = '" + cRota + "' " + CRLF
	_cQry += "   AND D_E_L_E_T_ = ' ' " + CRLF
	TCQUERY _cQry NEW ALIAS "cTMP"
				
	If (!cTMP->(EOF()))
		cRet := AllTrim(cTMP->CURRAL)
	EndIf
	cTMP->(DBCloseArea())

Return cRet


/* MB : 26.11.2020 */
Static Function fQtdTrato(dData, cRota)
Local nRet := 0

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
	TCQUERY _cQry NEW ALIAS "cTMP"
				
	If (!cTMP->(EOF()))
		nRet := cTMP->Z05_NROTRA
	EndIf
	cTMP->(DBCloseArea())

Return nRet
