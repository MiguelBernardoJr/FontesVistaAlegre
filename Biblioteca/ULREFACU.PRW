#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#DEFINE MAXPASSO 16

//Posições das tabelas no array aFilTabs
#DEFINE TabelaSA1 1 
#DEFINE TabelaSB2 2 
#DEFINE TabelaSB8 3
#DEFINE TabelaSBF 4
#DEFINE TabelaSC1 5
#DEFINE TabelaSC7 6
#DEFINE TabelaSC2 7
#DEFINE TabelaSD4 8
#DEFINE TabelaSDD 9
#DEFINE TabelaSCQ 10
#DEFINE TabelaSDA 11
#DEFINE TabelaSD1 12
#DEFINE TabelaSC0 13
#DEFINE TabelaSC6 14
#DEFINE TabelaSB6 15

//-------------------------------------------------------------------
/*/{Protheus.doc} ULREFACU

Programa para permitir refazer acumulado para  intervalo de produtos

@author	Joaquim Novaes Junior
@since	04/08/2020
@version P12

/*/
//-------------------------------------------------------------------

User Function ULREFACU()

    Local oDlg5
    
    Private cProd_De := Space(15)
    Private cProd_Ate := Space(15)

    #IFDEF TOP
        TCInternal(5,"*OFF")   // Desliga Refresh no Lock do Top
    #ENDIF

    @ 96,42 TO 380,505 DIALOG oDlg5 TITLE "Rotina de Refaz Acumulados Por Produto"
    @ 111,168 BMPBUTTON TYPE 1 ACTION UL215Do()// Substituido pelo assistente de conversao do AP5 IDE em 07/06/01 ==> @ 91,168 BMPBUTTON TYPE 1 ACTION Execute(OkProc)
    @ 111,196 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
    @ 23,14 SAY "Este programa refaz acumulados de um intervalo de produtos                 "
    @ 33,14 SAY "Os arquivos devem estar abertos em modo exclusivo"
    @ 53,14 SAY "Do Produto "
    @ 53,60 GET cProd_De PICTURE "@!" VALID .t. F3 "SB1" SIZE 100,10
    @ 73,14 SAY "Ate Produto "
    @ 73,60 GET cProd_Ate PICTURE "@!" VALID .t. F3 "SB1" SIZE 100,10
    @ 8,10 TO 104,222
    ACTIVATE DIALOG oDlg5 CENTERED

Return


Static Function UL215Do()
    
    Local oObj
    Local lNewProc := .F.
    Local lBat := .F.

    /*
    If oCenterPanel <> NIL
        oObj     := oCenterPanel
        lNewProc := .T.
    EndIf

    If lBat
        Ma215Proc(lBat,oObj)
    Else
        If !lNewProc
            oObj := MsNewProcess():New({|lEnd| Ma215Proc(lBat,oObj,lNewProc)},"","",.F.)
            oObj :Activate()
        Else
            Ma215Proc(lBat,oObj,lNewProc)
        EndIf
    EndIf
    */

    oObj := MsNewProcess():New({|lEnd| UL215Proc(lBat,oObj,lNewProc)},"","",.F.)
	oObj :Activate()

Return

Static Function UL215Proc(lBat,oObj,lNewProc)
Local aStru     := {}
Local aSaldos   := {}
Local aTravas   := {}
Local aAreaSB8  := {}
Local aAreaSB6  := {}
Local cQuery    := ""
Local cChave    := ""
Local lContinua := .F.
Local lLiberOk	:= .T.
Local lResidOk	:= .T.
Local lFaturOk	:= .F.
Local lAchou    := .F.
Local lGravaEmp := .F.
Local cQuebra   := ""
Local cAliasSA1 := "SA1"
Local cAliasSB2 := "SB2"
Local cAliasSB6 := "SB6"
Local cAliasSB8 := "SB8"
Local cAliasSBF := "SBF"
Local cAliasSC0 := "SC0"
Local cAliasSC1 := "SC1"
Local cAliasSC2 := "SC2"
Local cAliasSC6 := "SC6"
Local cAliasSC7 := "SC7"
Local cAliasSC9 := "SC9"
Local cAliasSD4 := "SD4"
Local cAliasAFJ := "AFJ"
Local cAliasSDC := "SDC"
Local cAliasSDD := "SDD"
Local cAliasSD1 := "SD1"
Local cAliasSD2 := "SD2"
Local cAliasSL2 := "SL2"
Local cAliasSCQ := "SCQ"
Local cAliasSDA := "SDA"
Local cSavFil   := cFilAnt
Local cFirst    := ""
Local nX        := 0
Local nMax      := 0
Local nMin      := 0
Local nQtdLib2  := 0
Local nRegSB6	:= 0

Local nEmpenho  := 0
Local nEmpenh2  := 0
Local nBaixaEmp := 0
Local nBaixaEm2 := 0
Local nQuantDc  := 0
Local nQtdDifDc := 0

Local cSeek     := ""
Local cSeekSDC  := ""
Local cCompara  := ""
Local cMensagem := ""
Local cEstoque  := ""
Local nTempoIni := 0
Local nTempoFim := 0
Local cTempo    := ""
Local dDataIni  := StoD("")
Local dDataFim  := StoD("")
Local cLocOriSB6:= ""
Local lEmpPrev  := If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)
Local lNegEstr  := SuperGetMV("MV_NEGESTR",.F.,.F.)
Local lPCFilEnt := SuperGetMv("MV_PCFILEN",.F.,.F.)
Local aTabs     := {}
Local lLockTabs := .T.
Local lAtuRes   := .T.                       // Define se atualiza a reserva (TPL OTC)
Local aAreaSM0  := {}
Local lM215SC	:= ExistBlock("M215SC")
Local lMA215SD1	:= ExistBlock("MA215SD1")
Local lMA215SD2	:= ExistBlock("MA215SD2")
Local lMT215EXC	:= ExistBlock("MT215EXC")
Local lCompraFut:= AliasInDic("DHQ") .And. SF4->(ColumnPos("F4_EFUTUR") > 0) .And. FindFunction("A103Refaz")
Local oRegSC9	:= NIL
Local oRegSD2	:= NIL
Local cFilialSC9:= ""
Local cFilialSC6:= ""
Local cFilialSD2:= ""
Local aStruSC9	:= {}
Local aStruSD2	:= {}
Local cFilialLida := ""

Local aFilTabs := {{ cAliasSA1, "" /*cFilAnterior*/},;
				   { cAliasSB2, "" /*cFilAnterior*/},;
				   { cAliasSB8, "" /*cFilAnterior*/},;
				   { cAliasSBF, "" /*cFilAnterior*/},;
				   { cAliasSC1, "" /*cFilAnterior*/},;
				   { cAliasSC7, "" /*cFilAnterior*/},;
				   { cAliasSC2, "" /*cFilAnterior*/},;
				   { cAliasSD4, "" /*cFilAnterior*/},;
				   { cAliasSDD, "" /*cFilAnterior*/},;
				   { cAliasSCQ, "" /*cFilAnterior*/},;
				   { cAliasSDA, "" /*cFilAnterior*/},;
				   { cAliasSD1, "" /*cFilAnterior*/},;
				   { cAliasSC0, "" /*cFilAnterior*/},;
				   { cAliasSC6, "" /*cFilAnterior*/},;
				   { cAliasSB6, "" /*cFilAnterior*/}}

DEFAULT lNewProc := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Semaforo para controle de execucao da rotina                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !MA215Lock(cEmpAnt)
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para controlar execucao da rotina de acumuladores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MT215PRO" )
	lRet := ExecBlock("MT215PRO",.F.,.F.)
	If ValType(lRet) <> "L"
		lRet:=.T.
	EndIf

	If !lRet
		Return
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogAtu("INICIO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre todos os arquivos de forma exclusiva                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aTabs,"SA1");AADD(aTabs,"SB1");AADD(aTabs,"SB2");AADD(aTabs,"SB8");AADD(aTabs,"SC0");AADD(aTabs,"SC6")
AADD(aTabs,"SC7");AADD(aTabs,"SC9");AADD(aTabs,"SD2");AADD(aTabs,"SD1");AADD(aTabs,"SD4");AADD(aTabs,"SDC")
AADD(aTabs,"SDD");AADD(aTabs,"SC1");AADD(aTabs,"SC2");AADD(aTabs,"SB6");AADD(aTabs,"SBF");AADD(aTabs,"SDA")
AADD(aTabs,"SL2");AADD(aTabs,"SCQ");AADD(aTabs,"DH1");AADD(aTabs,"D0G")
If lCompraFut
	AADD(aTabs,"DHQ")
EndIf

/*
For nX := 1 To Len(aTabs)
	If !MA280FLock(aTabs[nX],,!IsBlind())
		lLockTabs := .F.
		Exit
	Endif
Next
*/

If !lLockTabs
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha todos os arquivos e reabre-os de forma compartilhada   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aTabs)
		dbSelectArea(aTabs[nX])
		dbCloseArea()
	Next
	OpenFile(SubStr(cNumEmp,1,2),"")
	MA215UnLock(cEmpAnt) //Retorna o Semaforo para o estado inicial, pois a rotina não será executada
	Return
Else
	For nX := 1 To Len(aTabs)
		OpenIndx(aTabs[nX])
	Next
EndIf

aAreaSM0 := SM0->(GetArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na Primeira Filial                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTempoIni := Seconds()
dDataIni  := Date()
dbSelectArea("SM0")
dbSetOrder(1)
If Empty(xFilial("SA1")) .Or. Empty(xFilial("SB2")) .Or. lPCFilEnt
	MsSeek(cEmpAnt)
	cFirst := FWGETCODFILIAL //cFirst é a primeira filial do grupo de empresa
Else
	MsSeek(cEmpAnt+cFilAnt)
	cFirst := FWGETCODFILIAL
EndIf
While !Eof() .And. cEmpAnt == SM0->M0_CODIGO
	
	If !lBat
		oObj:SetRegua2(MAXPASSO)
		oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera a Filial do Sistema                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilAnt := FWGETCODFILIAL
	If !lBat
		If (oObj <> NIL) .And. lNewProc
			oObj:SaveLog(OemToAnsi("Início do processamento."))
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("MENSAGEM","Inicio Filial: "+cFilAnt,"Inicio Filial: "+cFilAnt) // "Inicio Filial: "

	oRegSC9	:= NIL
	oRegSD2	:= NIL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se há registros pendentes no SC9                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FtVldJobFt()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Zerar os dados a ser atualizado                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//Se a filial retornada pela função xFilial já tiver sido executada não executa novamente

		cFilialLida := xFilial("SA1")

		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSA1][2]) .Or. (cFilAnt == cFirst)
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SA1")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
			cAliasSA1 := "SA1MA215PROC"

			cQuery := "SELECT MIN(R_E_C_N_O_) MINRECNO,"
			cQuery += "MAX(R_E_C_N_O_) MAXRECNO "
			cQuery += "FROM "+RetSqlName("SA1")+" "
			cQuery += "WHERE A1_FILIAL='"+xFilial("SA1")+"' AND "
			cQuery += "D_E_L_E_T_=' '"
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA1)
			nMax := (cAliasSA1)->MAXRECNO
			nMin := (cAliasSA1)->MINRECNO
			dbCloseArea()
			dbSelectArea("SA1")
			cQuery := "UPDATE "
			cQuery += RetSqlName("SA1")+" "
			cQuery += "SET A1_SALPED = 0, "
			cQuery += "A1_SALPEDL = 0, "
			cQuery += "A1_SALPEDB = 0 "
			cQuery += "WHERE A1_FILIAL='"+xFilial("SA1")+"' AND "
			cQuery += "D_E_L_E_T_=' ' AND "
			If !lBat
				oObj:SetRegua1(Int(nMax/4096)+1)
			EndIf
			For nX := nMin To nMax+4096 STEP 4096
				cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+4096,10,0)+""
				TcSqlExec(cQuery+cChave)
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			Next nX

			aFilTabs[TabelaSA1][2] := cFilialLida

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A tabela eh fechada para restaurar o buffer da aplicacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA1")
			dbCloseArea()
			ChkFile("SA1",.T.)
		EndIf

		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		cFilialLida := xFilial("SB2")

		If (Iif(lPCFilEnt, .F., !Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSB2][2])) .Or. (cFilAnt == cFirst)

			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SB2")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
			cAliasSB2 := "SB2MA215PROC"

			cQuery := "SELECT MIN(R_E_C_N_O_) MINRECNO,"
			cQuery += "MAX(R_E_C_N_O_) MAXRECNO "
			cQuery += "FROM "+RetSqlName("SB2")+" "
			If lPCFilEnt
				cQuery += "WHERE "
			Else
				cQuery += "WHERE B2_FILIAL='"+xFilial("SB2")+"' AND "
			EndIf
            cQuery += "B2_COD >= '"+cProd_De+"' AND B2_COD <= '"+cProd_Ate+"' AND "
			cQuery += "D_E_L_E_T_=' '"
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB2)
			nMax := (cAliasSB2)->MAXRECNO
			nMin := (cAliasSB2)->MINRECNO
			dbCloseArea()
			dbSelectArea("SB2")
			cQuery := "UPDATE "
			cQuery += RetSqlName("SB2")+" "
			cQuery += "SET B2_RESERVA = 0,"
			cQuery += "B2_RESERV2 = 0,"
			cQuery += "B2_QEMP    = 0,"
			cQuery += "B2_QEMP2   = 0,"
			cQuery += "B2_QEMPN   = 0,"
			cQuery += "B2_QEMPN2  = 0,"
			cQuery += "B2_NAOCLAS = 0,"
			cQuery += "B2_SALPEDI = 0,"
			cQuery += "B2_SALPED2 = 0,"
			cQuery += "B2_QPEDVEN = 0,"
			cQuery += "B2_QPEDVE2 = 0,"
			cQuery += "B2_QTNP    = 0,"
			cQuery += "B2_QNPT    = 0,"
			cQuery += "B2_QTER    = 0,"
			cQuery += "B2_QEMPPRE = 0,"
			cQuery += "B2_SALPPRE = 0,"
			cQuery += "B2_QACLASS = 0,"
			cQuery += "B2_QEMPPRJ = 0,"
			cQuery += "B2_QEMPPR2 = 0,"
			cQuery += "B2_QEMPSA  = 0 "
			If lPCFilEnt
				cQuery += "WHERE "
			Else
				cQuery += "WHERE B2_FILIAL='"+xFilial("SB2")+"' AND "
			EndIf
            cQuery += "B2_COD >= '"+cProd_De+"' AND B2_COD <= '"+cProd_Ate+"' AND "
			cQuery += "D_E_L_E_T_=' ' AND "
			If !lBat
				oObj:SetRegua1(Int(nMax/4096)+1)
			EndIf
			For nX := nMin To nMax+4096 STEP 4096
				cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+4096,10,0)+""
				TcSqlExec(cQuery+cChave)
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			Next nX

			aFilTabs[TabelaSB2][2] := cFilialLida

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A tabela eh fechada para restaurar o buffer da aplicacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SB2")
			dbCloseArea()
			ChkFile("SB2",.T.)
		EndIf

		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		cFilialLida := xFilial("SB8")

		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSB8][2]) .Or. (cFilAnt == cFirst)
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SB8")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
			cAliasSB8 := "SB8MA215PROC"
			cQuery := "SELECT MIN(R_E_C_N_O_) MINRECNO,"
			cQuery += "MAX(R_E_C_N_O_) MAXRECNO "
			cQuery += "FROM "+RetSqlName("SB8")+" "
			cQuery += "WHERE B8_FILIAL='"+xFilial("SB8")+"' AND "
            cQuery += "B8_PRODUTO >= '"+cProd_De+"' AND B8_PRODUTO <= '"+cProd_Ate+"' AND "
			cQuery += "D_E_L_E_T_=' '"
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB8)
			nMax := (cAliasSB8)->MAXRECNO
			nMin := (cAliasSB8)->MINRECNO
			dbCloseArea()
			dbSelectArea("SB8")
			cQuery := "UPDATE "
			cQuery += RetSqlName("SB8")+" "
			cQuery += "SET B8_EMPENHO = 0, "
			cQuery += "B8_EMPENH2 = 0, "
			cQuery += "B8_QACLASS = 0, "
			cQuery += "B8_QACLAS2 = 0, "
			cQuery += "B8_QEMPPRE = 0 "
			cQuery += "WHERE B8_FILIAL='"+xFilial("SB8")+"' AND "
            cQuery += "B8_PRODUTO >= '"+cProd_De+"' AND B8_PRODUTO <= '"+cProd_Ate+"' AND "
			cQuery += "D_E_L_E_T_=' ' AND "
			If !lBat
				oObj:SetRegua1(Int(nMax/4096)+1)
			EndIf
			For nX := nMin To nMax+4096 STEP 4096
				cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+4096,10,0)+""
				TcSqlExec(cQuery+cChave)
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			Next nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A tabela eh fechada para restaurar o buffer da aplicacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			aFilTabs[TabelaSB8][2] := cFilialLida

			dbSelectArea("SB8")
			dbCloseArea()
			ChkFile("SB8",.T.)
		EndIf

		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		cFilialLida := xFilial("SBF")

		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSBF][2]) .Or. (cFilAnt == cFirst)
			dbSelectArea("SBF")
			dbSetOrder(1)
			MsSeek("SBF")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
			cAliasSBF := "SBFMA215PROC"

			cQuery := "SELECT MIN(R_E_C_N_O_) MINRECNO,"
			cQuery += "MAX(R_E_C_N_O_) MAXRECNO "
			cQuery += "FROM "+RetSqlName("SBF")+" "
			cQuery += "WHERE BF_FILIAL='"+xFilial("SBF")+"' AND "
            cQuery += "BF_PRODUTO >= '"+cProd_De+"' AND BF_PRODUTO <= '"+cProd_Ate+"' AND "
			cQuery += "D_E_L_E_T_=' '"
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSBF)
			nMax := (cAliasSBF)->MAXRECNO
			nMin := (cAliasSBF)->MINRECNO
			dbCloseArea()
			dbSelectArea("SBF")
			cQuery := "UPDATE "
			cQuery += RetSqlName("SBF")+" "
			cQuery += "SET BF_EMPENHO = 0, "
			cQuery += "BF_EMPEN2 = 0, "
			cQuery += "BF_QEMPPRE = 0, "
			cQuery += "BF_QEPRE2 = 0 "
			cQuery += "WHERE BF_FILIAL='"+xFilial("SBF")+"' AND "
            cQuery += "BF_PRODUTO >= '"+cProd_De+"' AND BF_PRODUTO <= '"+cProd_Ate+"' AND "
			cQuery += "D_E_L_E_T_=' ' AND "
			If !lBat
				oObj:SetRegua1(Int(nMax/4096)+1)
			EndIf
			For nX := nMin To nMax+4096 STEP 4096
				cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+4096,10,0)+""
				TcSqlExec(cQuery+cChave)
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			Next nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A tabela eh fechada para restaurar o buffer da aplicacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			aFilTabs[TabelaSBF][2] := cFilialLida
			
			dbSelectArea("SBF")
			dbCloseArea()
			ChkFile("SBF",.T.)
		EndIf

		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		cFilialLida := xFilial("SC1")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os dados acumulados da Solicitacao de Compra         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSC1][2]) .Or. (cFilAnt == cFirst)
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SC1")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
			dbSelectArea("SC1")
			dbSetOrder(1)
			If !lBat
				oObj:SetRegua1(SC1->(LastRec()))
				oObj:IncRegua1(cMensagem)
			EndIf
			aStru	  := SC1->(dbStruct())
			cAliasSC1 := "SC1MA215PROC"

			cQuery := ""
			For nX := 1 To Len(aStru)
				cQuery += ","+aStru[nX][1]
			Next nX
			cQuery := "SELECT SB1.B1_FILIAL,"+SubStr(cQuery,2)+",SC1.D_E_L_E_T_,SC1.R_E_C_N_O_ SC1RECNO "
			cQuery += "FROM "+RetSqlName("SC1")+" SC1,"
			cQuery += RetSqlName("SB1")+" SB1 "
			cQuery += "WHERE SC1.C1_FILIAL='"+xFilial("SC1")+"' AND "
			cQuery += "SC1.C1_QUJE < SC1.C1_QUANT AND "
			cQuery += "SC1.D_E_L_E_T_=' ' AND "
            cQuery += "C1_PRODUTO >= '"+cProd_De+"' AND C1_PRODUTO <= '"+cProd_Ate+"' AND "
			cQuery += "SC1.C1_RESIDUO='"+Space(Len(SC1->C1_RESIDUO))+"' AND "
			cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
			cQuery += "SB1.B1_COD=SC1.C1_PRODUTO AND "
			cQuery += "SB1.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY SC1.C1_FILIAL,SC1.C1_PRODUTO,SC1.C1_LOCAL"

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC1,.T.,.T.)
			For nX := 1 To Len(aStru)
				If ( aStru[nX][2] <> "C" .And. aStru[nX][2] <> "M" )
					TcSetField(cAliasSC1,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os dados acumulados da Solicitacao de compra         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While !Eof() .And. (cAliasSC1)->C1_FILIAL == xFilial("SC1")
				lContinua := .T.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada para Tratamentos Especiais         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lM215SC
					dbSelectArea("SC1")
					dbGoto((cAliasSC1)->SC1RECNO)
					If ExecBlock("M215SC",.f.,.f.)
						lContinua := .F.
					EndIf
				EndIf
				If lContinua
					MaAvalSC(cAliasSC1,1,,,.T.)
				EndIf
				SEA215SKIP(cAliasSC1)
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			EndDo

			aFilTabs[TabelaSC1][2] := cFilialLida

			dbSelectArea(cAliasSC1)
			dbCloseArea()
			dbSelectArea("SC1")
		EndIf
		
		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		cFilialLida := xFilial("SC7")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os dados acumulados do Pedido de Compra              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSC7][2]) .Or. (cFilAnt == cFirst)
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SC7")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)

			dbSelectArea("SC7")
			dbSetOrder(1)
			aStru     := SC7->(dbStruct())
			cAliasSC7 := "SC7MA215PROC"

			cQuery := "SELECT C7_FILIAL,C7_PRODUTO,C7_LOCAL,C7_QUJE,C7_QUANT,C7_RESIDUO,C7_FILENT,C7_TPOP,C7_QTSEGUM,C7_FORNECE,C7_LOJA,C7_NUM,C7_ITEM,C7_OP,C7_SEQMRP,C7_DATPRF,C7_TIPO,C7_NUMCOT,C7_TES,C7_ESTOQUE,SB1.B1_FILIAL "
			cQuery += "FROM "+RetSqlName("SC7")+" SC7,"
			cQuery += RetSqlName("SB1")+" SB1 "
			cQuery += "WHERE SC7.C7_FILIAL='"+xFilial("SC7")+"' AND "
            cQuery += "C7_PRODUTO >= '"+cProd_De+"' AND C7_PRODUTO <= '"+cProd_Ate+"' AND "
			cQuery += "SC7.C7_FILENT IN('  ','"+xFilial("SC7")+"') AND "
			cQuery += "SC7.C7_QUJE < C7_QUANT AND "
			cQuery += "SC7.C7_RESIDUO='"+Space(Len(SC7->C7_RESIDUO))+"' AND "
			cQuery += "SC7.D_E_L_E_T_=' ' AND "
			cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
			cQuery += "SB1.B1_COD=SC7.C7_PRODUTO AND "
			cQuery += "SB1.D_E_L_E_T_=' ' "
			cQuery += "UNION ALL "
			cQuery += "SELECT C7_FILIAL,C7_PRODUTO,C7_LOCAL,C7_QUJE,C7_QUANT,C7_RESIDUO,C7_FILENT,C7_TPOP,C7_QTSEGUM,C7_FORNECE,C7_LOJA,C7_NUM,C7_ITEM,C7_OP,C7_SEQMRP,C7_DATPRF,C7_TIPO,C7_NUMCOT,C7_TES,C7_ESTOQUE,SB1.B1_FILIAL "
			cQuery += "FROM "+RetSqlName("SC7")+" SC7,"
			cQuery += RetSqlName("SB1")+" SB1 "
			cQuery += "WHERE SC7.C7_FILENT='"+xFilial("SC7")+"' AND "
            cQuery += "C7_PRODUTO >= '"+cProd_De+"' AND C7_PRODUTO <= '"+cProd_Ate+"' AND "
			cQuery += "SC7.C7_FILIAL<>'"+xFilial("SC7")+"' AND "
			cQuery += "SC7.C7_QUJE < C7_QUANT AND "
			cQuery += "SC7.C7_RESIDUO='"+Space(Len(SC7->C7_RESIDUO))+"' AND "
			cQuery += "SC7.D_E_L_E_T_=' ' AND "
			cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
			cQuery += "SB1.B1_COD=SC7.C7_PRODUTO AND "
			cQuery += "SB1.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY 1,2,3 "

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)
			For nX := 1 To Len(aStru)
				If ( aStru[nX][2] <> "C" )
					TcSetField(cAliasSC7,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX
			If !lBat
				oObj:SetRegua1(SC7->(LastRec()))
				oObj:IncRegua1(cMensagem)
			EndIf
			While !Eof()
				lContinua := .T.
				If lContinua
					MaAvalPC(cAliasSC7,1,,.T.)
				EndIf
				SEA215SKIP(cAliasSC7)
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			EndDo

			aFilTabs[TabelaSC7][2] := cFilialLida

			dbSelectArea(cAliasSC7)
			dbCloseArea()
			dbSelectArea("SC7")
		EndIf

		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		// Atualiza os dados acumulados de compras com entrega futura
		If lCompraFut
			A103Refaz(cFilAnt, cFirst, lBat, oObj)
			If !lBat
				oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
			EndIf
		EndIf

		cFilialLida := xFilial("SC2")

		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSC2][2]) .Or. (cFilAnt == cFirst)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os dados acumulados das Ordens de Producao           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SC2")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)

			dbSelectArea("SC2")
			dbSetOrder(1)
			aStru     := SC2->(dbStruct())
			cAliasSC2 := "SC2MA215PROC"

			cQuery := "SELECT SC2.C2_FILIAL,SC2.C2_DATRF,SC2.C2_QUANT,SC2.C2_QUJE,SC2.C2_PERDA,SC2.C2_PRODUTO,SC2.C2_LOCAL,SC2.C2_TPOP,SB1.B1_FILIAL "
			cQuery += "FROM "+RetSqlName("SC2")+" SC2,"
			cQuery += RetSqlName("SB1")+" SB1 "
			cQuery += "WHERE SC2.C2_FILIAL='"+xFilial("SC2")+"' AND "
            cQuery += "C2_PRODUTO >= '"+cProd_De+"' AND C2_PRODUTO <= '"+cProd_Ate+"' AND "
			cQuery += "((SC2.C2_DATRF='"+Dtos(Ctod(""))+"' AND "
			cQuery += "SC2.C2_QUANT-SC2.C2_QUJE-SC2.C2_PERDA>0) OR "
			cQuery += "(SC2.C2_DATRF<>'"+Dtos(Ctod(""))+"')) AND "
			cQuery += "SC2.D_E_L_E_T_=' ' AND "
			cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
			cQuery += "SB1.B1_COD=SC2.C2_PRODUTO AND "
			cQuery += "SB1.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY C2_FILIAL,C2_PRODUTO,C2_LOCAL "

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC2,.T.,.T.)
			For nX := 1 To Len(aStru)
				If ( aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0 )
					TcSetField(cAliasSC2,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX

			If !lBat
				oObj:SetRegua1(SC2->(LastRec()))
				oObj:IncRegua1(cMensagem)
			EndIf

			While ( !Eof() .And. (cAliasSC2)->C2_FILIAL == xFilial("SC2") )
				lContinua := .T.
				If lContinua
					dbSelectArea("SB2")
					dbSetOrder(1)
					If !MsSeek(xFilial("SB2")+(cAliasSC2)->C2_PRODUTO+(cAliasSC2)->C2_LOCAL)
						CriaSB2((cAliasSC2)->C2_PRODUTO,(cAliasSC2)->C2_LOCAL)
					EndIf
					GravaB2Pre("+",IF(Empty((cAliasSC2)->C2_DATRF),aSC2Sld(cAliasSC2),0),(cAliasSC2)->C2_TPOP)
				EndIf
				SEA215SKIP(cAliasSC2)
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			EndDo

			aFilTabs[TabelaSC2][2] := cFilialLida

			dbSelectArea(cAliasSC2)
			dbCloseArea()
			dbSelectArea("SC2")
		EndIf

		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os dados acumulados dos empenhos da OP               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cFilialLida := xFilial("SD4")

		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSD4][2]) .Or. (cFilAnt == cFirst)
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SD4")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)

			dbSelectArea("SD4")
			dbSetOrder(1)
			aStru     := SD4->(dbStruct())
			cAliasSD4 := "SD4MA215PROC"

			cQuery := "SELECT SD4.*,SB1.B1_FILIAL "
			cQuery += "FROM "+RetSqlName("SD4")+" SD4,"
			cQuery += RetSqlName("SB1")+" SB1 "
			cQuery += "WHERE SD4.D4_FILIAL='"+xFilial("SD4")+"' AND "
            cQuery += "D4_COD >= '"+cProd_De+"' AND D4_COD <= '"+cProd_Ate+"' AND "
			// MV_NEGESTR - Parametro utilizado para considerar empenho negativo
			If lNegEstr
				cQuery += " SD4.D4_QUANT <> 0 AND "
			Else
				cQuery += "SD4.D4_QUANT > 0 AND "
			EndIf
			cQuery += "SD4.D_E_L_E_T_=' ' AND "
			cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
			cQuery += "SB1.B1_COD=SD4.D4_COD AND "
			cQuery += "SB1.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY D4_FILIAL,D4_COD,D4_LOCAL"

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD4,.T.,.T.)
			For nX := 1 To Len(aStru)
				If ( aStru[nX][2] <> "C" .And. aStru[nX][2] <> "M" )
					TcSetField(cAliasSD4,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX
			If !lBat
				oObj:SetRegua1(SD4->(LastRec()))
				oObj:IncRegua1(cMensagem)
			EndIf
			While !Eof() .And. (cAliasSD4)->D4_FILIAL == xFilial("SD4")
				nQuantDc :=0
				nQtdDifDc:=0
				lContinua := .T.
				If lContinua
					If Localiza((cAliasSD4)->D4_COD)
						aStru     := SDC->(dbStruct())
						cAliasSDC := "SDCMA215PROC1"

						cQuery := "SELECT * "
						cQuery += "FROM "+RetSqlName("SDC")+" SDC "
						cQuery += "WHERE SDC.DC_FILIAL='"+xFilial("SDC")+"' AND "
						cQuery += "SDC.DC_PRODUTO='"+(cAliasSD4)->D4_COD+"' AND "
						cQuery += "SDC.DC_LOCAL='"+(cAliasSD4)->D4_LOCAL+"' AND "
						cQuery += "SDC.DC_OP='"+(cAliasSD4)->D4_OP+"' AND "
						cQuery += "SDC.DC_TRT='"+(cAliasSD4)->D4_TRT+"' AND "
						cQuery += "SDC.DC_LOTECTL='"+(cAliasSD4)->D4_LOTECTL+"' AND "
						cQuery += "SDC.DC_NUMLOTE='"+(cAliasSD4)->D4_NUMLOTE+"' AND "
						cQuery += "SDC.D_E_L_E_T_=' ' "
						cQuery += "ORDER BY "+SqlOrder(SDC->(IndexKey()))

						cQuery := ChangeQuery(cQuery)

						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSDC,.T.,.T.)
						For nX := 1 To Len(aStru)
							If ( aStru[nX][2] <> "C" .And. aStru[nX][2] <> "M" )
								TcSetField(cAliasSDC,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
							EndIf
						Next nX
						lAchou := .F.
						While !Eof() .And. (cAliasSDC)->DC_FILIAL == xFilial("SDC") .And.;
						(cAliasSDC)->DC_PRODUTO == (cAliasSD4)->D4_COD .And.;
						(cAliasSDC)->DC_LOCAL == (cAliasSD4)->D4_LOCAL .And.;
						(cAliasSDC)->DC_OP == (cAliasSD4)->D4_OP .And.;
						(cAliasSDC)->DC_TRT == (cAliasSD4)->D4_TRT .And.;
						(cAliasSDC)->DC_LOTECTL == (cAliasSD4)->D4_LOTECTL .And.;
						(cAliasSDC)->DC_NUMLOTE == (cAliasSD4)->D4_NUMLOTE
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza arquivo de empenhos               ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nQuantDc+=(cAliasSDC)->DC_QUANT
							lAchou := .T.
							GravaEmp(	(cAliasSDC)->DC_PRODUTO,;
										(cAliasSDC)->DC_LOCAL,;
										(cAliasSDC)->DC_QUANT,;
										(cAliasSDC)->DC_QTSEGUM,;
										(cAliasSDC)->DC_LOTECTL,;
										(cAliasSDC)->DC_NUMLOTE,;
										(cAliasSDC)->DC_LOCALIZ,;
										(cAliasSDC)->DC_NUMSERIE,;
										(cAliasSDC)->DC_OP,;
										(cAliasSDC)->DC_TRT,;
										NIL,;
										NIL,;
										"SC2",;
										NIL,;
										NIL,;
										NIL,;
										.F.,;
										.F.,;
										.T.,;
										.F.,;
										NIL,;
										.T.,;
										.F.)
							SEA215SKIP(cAliasSDC)
						EndDo

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Tratamento para verificar se existe diference entre valores da SDC e SD4 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nQuantDc < (cAliasSD4)->D4_QUANT
							nQtdDifDc := (cAliasSD4)->D4_QUANT - nQuantDc
							lAchou :=.F.
						EndIf

						dbSelectArea(cAliasSDC)
						dbCloseArea()
						dbSelectArea("SDC")
						If !lAchou
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza arquivo de empenhos               ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							GravaEmp(	(cAliasSD4)->D4_COD,;
										(cAliasSD4)->D4_LOCAL,;
										IIf(QtdComp((cAliasSD4)->D4_QUANT) <> QtdComp(nQuantDc),nQtdDifDc,(cAliasSD4)->D4_QUANT),;
										(cAliasSD4)->D4_QTSEGUM,;
										(cAliasSD4)->D4_LOTECTL,;
										(cAliasSD4)->D4_NUMLOTE,;
										NIL,;
										NIL,;
										(cAliasSD4)->D4_OP,;
										(cAliasSD4)->D4_TRT,;
										NIL,;
										NIL,;
										"SC2",;
										(cAliasSD4)->D4_OPORIG,;
										(cAliasSD4)->D4_DATA,;
										@aTravas,;
										.F.,;
										.F.,;
										.T.,;
										.F.,;
										NIL,;
										.T.,;
										.F.)
						EndIf
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza arquivo de empenhos               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						GravaEmp(	(cAliasSD4)->D4_COD,;
									(cAliasSD4)->D4_LOCAL,;
									(cAliasSD4)->D4_QUANT,;
									(cAliasSD4)->D4_QTSEGUM,;
									(cAliasSD4)->D4_LOTECTL,;
									(cAliasSD4)->D4_NUMLOTE,;
									NIL,;
									NIL,;
									(cAliasSD4)->D4_OP,;
									(cAliasSD4)->D4_TRT,;
									NIL,;
									NIL,;
									"SC2",;
									(cAliasSD4)->D4_OPORIG,;
									(cAliasSD4)->D4_DATA,;
									NIL,;
									.F.,;
									.F.,;
									.T.,;
									.F.,;
									NIL,;
									.T.,;
									.F.)
					EndIf
				EndIf
				SEA215SKIP(cAliasSD4)
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			EndDo

			aFilTabs[TabelaSD4][2] := cFilialLida

			dbSelectArea(cAliasSD4)
			dbCloseArea()
			dbSelectArea("SD4")
		EndIf

		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Varre o SDD e refaz os bloqueios existentes                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cFilialLida := xFilial("SDD")

		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSDD][2]) .Or. (cFilAnt == cFirst)
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SDD")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
			dbSelectArea("SDD")
			dbSetOrder(1)
			MsSeek(xFilial())
			If !lBat
				oObj:SetRegua1(SDD->(LastRec()))
				oObj:IncRegua1(cMensagem)
			EndIf
			While !Eof() .And. DD_FILIAL == xFilial()
            	If SDD->DD_PRODUTO >= cProd_De .AND. SDD->DD_PRODUTO <= cProd_Ate .AND. SDD->DD_SALDO > 0 .And. A215FilOk(SDD->DD_PRODUTO)
					Reclock("SDD",.F.)
					Replace DD_QUANT With DD_SALDO
					MsUnlock()
					cSeekSDC := xFilial("SDC")+SDD->DD_PRODUTO+SDD->DD_LOCAL+SDD->DD_LOTECTL+;
					SDD->DD_NUMLOTE+If(!Empty(SDD->DD_LOCALIZ),SDD->DD_LOCALIZ,"")+If(!Empty(SDD->DD_NUMSERI),SDD->DD_NUMSERI,"")
					SDC->(dbSetOrder(3))
					aTravas  := {}
					If Localiza(SDD->DD_PRODUTO) .And. SDC->(MsSeek(cSeekSDC))
						dbSelectArea("SDC")
						While !Eof() .And. DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_LOTECTL+;
						DC_NUMLOTE+If(!Empty(SDD->DD_LOCALIZ),SDC->DC_LOCALIZ,"")+;
						If(!Empty(SDD->DD_NUMSERI),SDC->DC_NUMSERI,"") == cSeekSDC

							lGravaEmp := .F.
							If !Empty(SDD->DD_IDSDD) .And. !Empty(SDC->DC_IDSDD)
								If AllTrim(SDD->DD_IDSDD) == AllTrim(SDC->DC_IDSDD)
									lGravaEmp := .T.
								Else
									lGravaEmp := .F.
								EndIf
							ElseIf Len(AllTrim(SDD->DD_DOC)) == Len(AllTrim(SDC->DC_PEDIDO))
								If AllTrim(SDD->DD_DOC) == AllTrim(SDC->DC_PEDIDO)
									lGravaEmp := .T.
								Else
									lGravaEmp := .F.
								EndIf
							ElseIf Len(AllTrim(SDD->DD_DOC)) <> Len(AllTrim(SDC->DC_PEDIDO))
								lGravaEmp := .T.
							EndIf

							If DC_ORIGEM == 'SDD' .And. lGravaEmp
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Atualiza arquivo de empenhos               ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								GravaEmp(	SDC->DC_PRODUTO,;
											SDC->DC_LOCAL,;
											SDC->DC_QUANT,;
											SDC->DC_QTSEGUM,;
											SDC->DC_LOTECTL,;
											SDC->DC_NUMLOTE,;
											SDC->DC_LOCALIZ,;
											SDC->DC_NUMSERI,;
											Nil,;
											Nil,;
											SDC->DC_PEDIDO,;
											Nil,;
											"SDD",;
											Nil,;
											Nil,;
											Nil,;
											.F.,;
											.F.,;
											.T.,;
											.F.,;
											.T.,;
											.T.,;
											.F.)
								SEA215SKIP('SDC')
							Else
								SEA215SKIP('SDC')
							EndIf
						EndDo
					Else
						ProcSDD(.F.)
					EndIf
				EndIf

				SEA215SKIP('SDD')

				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			EndDo

			aFilTabs[TabelaSDD][2] := cFilialLida

		EndIf

		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		cFilialLida	:= xFilial("SCQ")

		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSCQ][2]) .Or. (cFilAnt == cFirst)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corre SCQ para Atualizar B2_QEMP  em Produtos SB2.           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SCQ")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
			dbSelectArea("SCQ")
			cFilSCQ := 'CQ_QTDISP > 0 .AND. CQ_PRODUTO >= "'+cProd_De+'" .AND. CQ_PRODUTO <= "'+cProd_Ate+'"'
			MsFilter(cFilSCQ)
			dbSetOrder(1)
			MsSeek(xFilial())
			If !lBat
				oObj:SetRegua1(SCQ->(LastRec()))
				oObj:IncRegua1(cMensagem)
			EndIf
			While !Eof() .And. CQ_FILIAL == xFilial()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualizar Qtde Empenhada  em Produtos SB2.          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If SCQ->CQ_PRODUTO >= cProd_De .AND. SCQ->CQ_PRODUTO <= cProd_Ate .AND. SCQ->CQ_QTDISP > 0 .And. Empty(SCQ->CQ_NUMREQ) .And. A215FilOk(SCQ->CQ_PRODUTO)
					dbSelectArea("SB2")
					cSeek := xFilial()+SCQ->CQ_PRODUTO+SCQ->CQ_LOCAL
					MsSeek(cSeek)
					If Eof()
						CriaSB2(SCQ->CQ_PRODUTO,SCQ->CQ_LOCAL)
					Else
						RecLock("SB2",.F.)
					EndIf
					Replace B2_QEMPSA     With B2_QEMPSA + (SCQ->CQ_QTDISP)
					MsUnLock()
				EndIf
				SEA215SKIP('SCQ')
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			EndDo

			aFilTabs[TabelaSCQ][2] := cFilialLida

			RETINDEX("SCQ")
			dbClearFilter()
		EndIf

		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		If (!Empty(xFilial("DH1")) .Or. cFilAnt == cFirst ) //-- Corre DH1 para Atualizar B2_RESERV  em Produtos SB2.
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("DH1")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
			dbSelectArea("DH1")
			cFilDH1 :=	 'DH1_TM > "500" .And. DH1_QUANT > 0 .And. DH1_STATUS = "1" .AND. DH1_PRODUT >= "'+cProd_De+'" .AND. DH1_PRODUT <= "'+cProd_Ate+'"'
			MsFilter(cFilDH1)
			dbSetOrder(1)
			MsSeek(xFilial("DH1"))
			If !lBat
				oObj:SetRegua1(DH1->(LastRec()))
				oObj:IncRegua1(cMensagem)
			EndIf
			While DH1->(!Eof()) .And. DH1->DH1_FILIAL == xFilial("DH1") //--  Atualizar Qtde Empenhada  em Produtos SB2.
				If DH1_QUANT > 0 .And. A215FilOk(DH1->DH1_PRODUT)
					dbSelectArea("SB2")
					cSeek := xFilial("DH1")+DH1->DH1_PRODUT+DH1->DH1_LOCAL
					MsSeek(cSeek)
					If SB2->(Eof())
						CriaSB2(DH1->DH1_PRODUT,DH1->DH1_LOCAL)
					Else
						RecLock("SB2",.F.)
					EndIf
					SB2->B2_RESERVA := SB2->B2_RESERVA + DH1->DH1_QUANT
					MsUnLock()
					//-- Caso use rastreabilidade, GRAVA a quantidade do DH1
					//-- no SB8 para que o Saldo por Sub-Lote fique bloqueado
					If Rastro(DH1->DH1_PRODUT)
						dbSelectArea("SB8")
						aAreaSB8:=GetArea()
						dbSetOrder(3)
						If Rastro(DH1->DH1_PRODUT,"S")
							cSeek:=xFilial("SB8")+DH1->DH1_PRODUT+DH1->DH1_LOCAL+DH1->DH1_LOTECT+DH1->DH1_NUMLOT
						Else
							cSeek:=xFilial("SB8")+DH1->DH1_PRODUT+DH1->DH1_LOCAL+DH1->DH1_LOTECT
						EndIf
						If SB8->(MsSeek(cSeek))
							RecLock("SB8",.F.)
							SB8->B8_EMPENHO := SB8->B8_EMPENHO + DH1->DH1_QUANT
							SB8->B8_EMPENH2 := SB8->B8_EMPENH2 + DH1->DH1_QTSEGU
							MsUnlock()
						EndIf
						RestArea(aAreaSB8)
					EndIf
				EndIf
				SEA215SKIP("DH1")
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			EndDo
			RETINDEX("DH1")
			dbClearFilter()
		EndIf

		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		If AliasIndic("D0G")
			If (!Empty(xFilial("D0G")) .Or. cFilAnt == cFirst ) //-- Corre D0G para Atualizar B2_QACLASS em Produtos SB2.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ A partir do D0G atualiza B2_QACLASS e B8_QACLASS             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SX2->(dbSetOrder(1))
				SX2->(MsSeek("D0G"))
				cMensagem := AllTrim(SX2->(X2Nome()))
				cMensagem := Lower(cMensagem)
				cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
				dbSelectArea("D0G")
				cFilD0G := 'D0G_SALDO > 0 .AND. D0G_PRODUT >= "'+cProd_De+'" .AND. D0G_PRODUT <= "'+cProd_Ate+'"'
				MsFilter(cFilD0G)
				dbSetOrder(1)
				MsSeek(xFilial())
				If !lBat
					oObj:SetRegua1(D0G->(LastRec()))
					oObj:IncRegua1(cMensagem)
				EndIf
				While !Eof() .And. D0G_FILIAL == xFilial()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualizar Qtde Prevista de Produtos SB2.            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If D0G_SALDO > 0 .And. A215FilOk(D0G->D0G_PRODUT)
						dbSelectArea("SB2")
						cSeek := xFilial()+D0G->D0G_PRODUT+D0G->D0G_LOCAL
						MsSeek(cSeek)
						If Eof()
							CriaSB2(D0G->D0G_PRODUT,D0G->D0G_LOCAL)
						EndIf
						Reclock("SB2",.F.)
						Replace B2_QACLASS With B2_QACLASS + D0G->D0G_SALDO
						MsUnlock()
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Caso use rastreabilidade, GRAVA a quantidade do D0G   ³
						//³ no SB8 para que o Saldo por Sub-Lote fique bloqueado  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Rastro(D0G->D0G_PRODUT)
							dbSelectArea("SB8")
							aAreaSB8:=GetArea()
							dbSetOrder(3)
							If Rastro(D0G->D0G_PRODUT,"S")
								cSeek:=xFilial()+D0G->D0G_PRODUT+D0G->D0G_LOCAL+D0G->D0G_LOTECTL+D0G->D0G_NUMLOTE
								cCompara:="B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE"
							Else
								cSeek:=xFilial()+D0G->D0G_PRODUT+D0G->D0G_LOCAL+D0G->D0G_LOTECTL
								cCompara:="B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL"
							EndIf
							MsSeek(cSeek)
							nEmpenho:=D0G->D0G_SALDO
							nEmpenh2:=D0G->D0G_QTSEUM
							Do While !Eof() .And. nEmpenho > 0 .And. cSeek == &(cCompara)
								nBaixaEmp:=Min(nEmpenho,SB8Saldo(Nil,.T.,Nil,Nil,Nil,lEmpPrev))
								nBaixaEm2:=Min(nEmpenh2,SB8Saldo(Nil,.T.,Nil,.T.,Nil,lEmpPrev))
								RecLock("SB8",.F.)
								Replace B8_QACLASS With B8_QACLASS + nBaixaEmp
								Replace B8_QACLAS2 With B8_QACLAS2 + nBaixaEm2
								nEmpenho -= nBaixaEmp
								nEmpenh2 -= nBaixaEm2
								MsUnlock()
								SEA215SKIP()
							EndDo
							RestArea(aAreaSB8)
						EndIf
					EndIf
					SEA215SKIP('D0G')
					If !lBat
						oObj:IncRegua1(cMensagem)
					EndIf
				EndDo
				RETINDEX("D0G")
				dbClearFilter()
			EndIf
			If !lBat
				oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
			EndIf
		EndIf

		cFilialLida := xFilial("SDA")

		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSDA][2]) .Or. (cFilAnt == cFirst)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ A partir do SDA atualiza B2_QACLASS e B8_QACLASS             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SDA")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
			dbSelectArea("SDA")
			cFilSDA := 'DA_SALDO > 0 .AND. DA_PRODUTO >= "'+cProd_De+'" .AND. DA_PRODUTO <= "'+cProd_Ate+'"'
			MsFilter(cFilSDA)
			dbSetOrder(1)
			MsSeek(xFilial())
			If !lBat
				oObj:SetRegua1(SDA->(LastRec()))
				oObj:IncRegua1(cMensagem)
			EndIf
			While !Eof() .And. DA_FILIAL == xFilial()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualizar Qtde Prevista de Produtos SB2.            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If DA_SALDO > 0 .And. A215FilOk(SDA->DA_PRODUTO)
					dbSelectArea("SB2")
					cSeek := xFilial()+SDA->DA_PRODUTO+SDA->DA_LOCAL
					MsSeek(cSeek)
					If Eof()
						CriaSB2(SDA->DA_PRODUTO,SDA->DA_LOCAL)
					EndIf
					Reclock("SB2",.F.)
					Replace B2_QACLASS With B2_QACLASS + SDA->DA_SALDO
					MsUnlock()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso use rastreabilidade, GRAVA a quantidade do SDA   ³
					//³ no SB8 para que o Saldo por Sub-Lote fique bloqueado  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Rastro(SDA->DA_PRODUTO)
						dbSelectArea("SB8")
						aAreaSB8:=GetArea()
						dbSetOrder(3)
						If Rastro(SDA->DA_PRODUTO,"S")
							cSeek:=xFilial()+SDA->DA_PRODUTO+SDA->DA_LOCAL+SDA->DA_LOTECTL+SDA->DA_NUMLOTE
							cCompara:="B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE"
						Else
							cSeek:=xFilial()+SDA->DA_PRODUTO+SDA->DA_LOCAL+SDA->DA_LOTECTL
							cCompara:="B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL"
						EndIf
						MsSeek(cSeek)
						nEmpenho:=SDA->DA_SALDO
						nEmpenh2:=SDA->DA_QTSEGUM
						Do While !Eof() .And. nEmpenho > 0 .And. cSeek == &(cCompara)
							nBaixaEmp:=Min(nEmpenho,SB8Saldo(Nil,.T.,Nil,Nil,Nil,lEmpPrev))
							nBaixaEm2:=Min(nEmpenh2,SB8Saldo(Nil,.T.,Nil,.T.,Nil,lEmpPrev))
							RecLock("SB8",.F.)
							Replace B8_QACLASS With B8_QACLASS + nBaixaEmp
							Replace B8_QACLAS2 With B8_QACLAS2 + nBaixaEm2
							nEmpenho -= nBaixaEmp
							nEmpenh2 -= nBaixaEm2
							MsUnlock()
							SEA215SKIP()
						EndDo
						RestArea(aAreaSB8)
					EndIf
				EndIf
				SEA215SKIP('SDA')
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			EndDo

			aFilTabs[TabelaSDA][2] := cFilialLida	

			RETINDEX("SDA")
			dbClearFilter()
		EndIf

		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		cFilialLida := xFilial("SD1")

		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSD1][2]) .Or. (cFilAnt == cFirst)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os dados acumulados da Pre-Nota de Entrada           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SD1")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
			dbSelectArea("SD1")
			dbSetOrder(1)
			cAliasSD1 := "SD1MA215PROC"

			cQuery := "SELECT MIN(R_E_C_N_O_) MINRECNO,"
			cQuery += "MAX(R_E_C_N_O_) MAXRECNO "
			cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
			cQuery += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
            cQuery += "D1_COD >= '"+cProd_De+"' AND D1_COD <= '"+cProd_Ate+"' AND "
			cQuery += "SD1.D1_IDENTB6<>'"+Space(Len(SD1->D1_IDENTB6))+"' AND "
			cQuery += "( SD1.D1_QTDEDEV > 0 OR SD1.D1_VALDEV > 0 ) AND "
			cQuery += "SD1.D_E_L_E_T_=' ' "
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1)
			nMax := (cAliasSD1)->MAXRECNO
			nMin := (cAliasSD1)->MINRECNO
			dbCloseArea()
			dbSelectArea("SD1")
			cQuery := "UPDATE "
			cQuery += RetSqlName("SD1")+" "
			cQuery += "SET D1_QTDEDEV = 0, D1_VALDEV = 0 "
			cQuery += "WHERE D1_FILIAL='"+xFilial("SD1")+"' AND "
            cQuery += "D1_COD >= '"+cProd_De+"' AND D1_COD <= '"+cProd_Ate+"' AND "
			cQuery += "D1_IDENTB6<>'"+Space(Len(SD1->D1_IDENTB6))+"' AND "
			cQuery += "( D1_QTDEDEV > 0 OR D1_VALDEV > 0 ) AND "
			cQuery += "D_E_L_E_T_=' ' AND "
			For nX := nMin To nMax+4096 STEP 4096
				cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+4096,10,0)+""
				TcSqlExec(cQuery+cChave)
			Next nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A tabela eh fechada para restaurar o buffer da aplicacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SD1")
			dbCloseArea()
			ChkFile("SD1",.T.)

			aStru     := SD1->(dbStruct())
			cAliasSD1 := "SD1MA215PROC"

			cQuery := "SELECT SD1.*,SB1.B1_FILIAL "
			cQuery += "FROM "+RetSqlName("SD1")+" SD1,"
			cQuery += RetSqlName("SB1")+" SB1 "
			cQuery += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
            cQuery += "D1_COD >= '"+cProd_De+"' AND D1_COD <= '"+cProd_Ate+"' AND "
			cQuery += "SD1.D1_TES = '"+Space(Len(SD1->D1_TES))+"' AND "
			cQuery += "SD1.D_E_L_E_T_=' ' AND "
			cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
			cQuery += "SB1.B1_COD=SD1.D1_COD AND "
			cQuery += "SB1.D_E_L_E_T_=' ' "

			If lMA215SD1
				cQuery := ExecBlock("MA215SD1",.F.,.F.,cQuery)
			EndIf

			cQuery += "ORDER BY D1_FILIAL,D1_COD,D1_LOCAL"

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
			For nX := 1 To Len(aStru)
				If ( aStru[nX][2] <> "C" .And. aStru[nX][2] <> "M" )
					TcSetField(cAliasSD1,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX

			If !lBat
				oObj:SetRegua1(SD1->(LastRec()))
				oObj:IncRegua1(cMensagem)
			EndIf

			While !Eof() .And. (cAliasSD1)->D1_FILIAL == xFilial("SD1")
				lContinua := .T.
				If lContinua
					dbSelectArea("SB2")
					dbSetOrder(1)
					If !MsSeek(xFilial("SB2")+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_LOCAL)
						CriaSB2((cAliasSD1)->D1_COD,(cAliasSD1)->D1_LOCAL)
					EndIf
					RecLock("SB2",.F.)
					Replace B2_NAOCLAS With B2_NAOCLAS + (cAliasSD1)->D1_QUANT
					MsUnLock()
				EndIf
				SEA215SKIP(cAliasSD1)
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			EndDo

			aFilTabs[TabelaSD1][2] := cFilialLida

			dbSelectArea(cAliasSD1)
			dbCloseArea()
			dbSelectArea("SD1")
		EndIf
		
		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf
				
		cFilialLida := xFilial("SC0")

		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSC0][2]) .Or. (cFilAnt == cFirst)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os dados acumulados das Reserva de Faturamento       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SC0")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
			dbSelectArea("SC0")
			dbSetOrder(1)
			aStru     := SC0->(dbStruct())
			cAliasSC0 := "SC0MA215PROC"

			cQuery := "SELECT SC0.*,SB1.B1_FILIAL "
			cQuery += "FROM "+RetSqlName("SC0")+" SC0,"
			cQuery += RetSqlName("SB1")+" SB1 "
			cQuery += "WHERE SC0.C0_FILIAL='"+xFilial("SC0")+"' AND "
            cQuery += "C0_PRODUTO >= '"+cProd_De+"' AND C0_PRODUTO <= '"+cProd_Ate+"' AND "
			If !HasTemplate("OTC")
				cQuery += "SC0.C0_QUANT > 0 AND "
			Endif
			cQuery += "SC0.D_E_L_E_T_=' ' AND "
			cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
			cQuery += "SB1.B1_COD=SC0.C0_PRODUTO AND "
			cQuery += "SB1.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY C0_FILIAL,C0_PRODUTO,C0_LOCAL "

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC0,.T.,.T.)
			For nX := 1 To Len(aStru)
				If ( aStru[nX][2] <> "C" .And. aStru[nX][2] <> "M" )
					TcSetField(cAliasSC0,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX

			If !lBat
				oObj:SetRegua1(SC0->(LastRec()))
				oObj:IncRegua1(cMensagem)
			EndIf

			While !Eof() .And. (cAliasSC0)->C0_FILIAL == xFilial("SC0")
				lContinua := .T.
				If lContinua
					Ma215Res(cAliasSC0, (cAliasSC0)->C0_QUANT, (cAliasSC0)->C0_QTDPED)
				EndIf

				SEA215SKIP(cAliasSC0)
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			EndDo

			aFilTabs[TabelaSC0][2] := cFilialLida

			dbSelectArea(cAliasSC0)
			dbCloseArea()
			dbSelectArea("SC0")
		EndIf

		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		cFilialLida := xFilial("SC6")

		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSC6][2]) .Or. (cFilAnt == cFirst)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os dados acumulados do PV e seus anexos              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SC6")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
			dbSelectArea("SC6")
			dbSetOrder(1)
			cAliasSC6 := "SC6MA215PROC"

			cQuery := "SELECT MIN(R_E_C_N_O_) MINRECNO,"
			cQuery += "MAX(R_E_C_N_O_) MAXRECNO "
			cQuery += "FROM "+RetSqlName("SC6")+" SC6 "
			cQuery += "WHERE SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
            cQuery += "C6_PRODUTO >= '"+cProd_De+"' AND C6_PRODUTO <= '"+cProd_Ate+"' AND "
			cQuery += "C6_BLQ <> 'S"+Space(Len(SC6->C6_BLQ)-1)+"' AND "
			cQuery += "C6_BLQ <> 'R"+Space(Len(SC6->C6_BLQ)-1)+"' AND "
			cQuery += "(C6_QTDVEN > C6_QTDENT OR (C6_QTDVEN <= C6_QTDENT AND C6_ENTREG>='"+DTOS(dDataBase-31)+"')) AND "
			cQuery += "SC6.D_E_L_E_T_=' ' "
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC6)
			nMax := (cAliasSC6)->MAXRECNO
			nMin := (cAliasSC6)->MINRECNO
			dbCloseArea()
			dbSelectArea("SC6")
			cQuery := "UPDATE "
			cQuery += RetSqlName("SC6")+" "
			cQuery += "SET C6_QTDEMP = 0, C6_QTDENT = 0, C6_QTDEMP2 = 0, C6_QTDENT2 = 0 "
			cQuery += "WHERE C6_FILIAL='"+xFilial("SC6")+"' AND "
            cQuery += "C6_PRODUTO >= '"+cProd_De+"' AND C6_PRODUTO <= '"+cProd_Ate+"' AND "
			cQuery += "C6_BLQ <> 'S"+Space(Len(SC6->C6_BLQ)-1)+"' AND "
			cQuery += "C6_BLQ <> 'R"+Space(Len(SC6->C6_BLQ)-1)+"' AND "
			cQuery += "(C6_QTDVEN > C6_QTDENT OR (C6_QTDVEN <= C6_QTDENT AND C6_ENTREG>='"+Dtos(dDataBase-31)+"')) AND "
			cQuery += "D_E_L_E_T_=' ' AND "
			For nX := nMin To nMax+4096 STEP 4096
				cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+4096,10,0)+""
				TcSqlExec(cQuery+cChave)
			Next nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A tabela eh fechada para restaurar o buffer da aplicacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SC6")
			dbCloseArea()
			ChkFile("SC6",.T.)

			aStru     := SC6->(dbStruct())
			cAliasSC6 := "SC6MA215PROC"

			cQuery := "SELECT SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_ITEM,SC6.C6_PRODUTO,SC6.C6_BLQ,"
			cQuery += "SC6.C6_NUMOS,SC6.C6_QTDEMP,SC6.C6_NUMOSFA,"
			cQuery += "SC6.C6_QTDENT,SC6.C6_RESERVA,SC6.C6_TES,SC6.C6_NUMLOTE,"
			cQuery += "SC6.C6_CLI,SC6.C6_LOCAL,SC6.C6_LOTECTL,SC6.C6_LOJA,SC6.C6_QTDVEN,"
			cQuery += "SC6.C6_OP,SC6.C6_NUMSERI,SC6.C6_LOCALIZ,SC6.C6_QTDRESE,SC6.C6_DTVALID,"
			cQuery += "SC6.C6_QTDLIB,SC6.C6_PRCVEN,"
			cQuery += "SC6.C6_PRUNIT,SC6.C6_VALDESC,"
			cQuery += "SC6.C6_VALOR,SC6.C6_UNSVEN,SC6.C6_ENTREG,SC6.C6_DATFAT, "
			cQuery += "SC6.C6_DESCONT,SC6.C6_QTDLIB2,"
			cQuery += "SC6.R_E_C_N_O_ SC6RECNO,SB1.B1_FILIAL "

			cQuery += ",SC6.C6_QTDEMP2 "

			cQuery += ",SC6.C6_QTDENT2 "
			If cPaisLoc <> "BRA"
				cQuery += ",SC6.C6_GERANF,SC6.C6_CONTRAT,SC6.C6_ITEMCON "
			EndIf
			cQuery += "FROM "+RetSqlName("SC6")+" SC6, "+RetSqlName("SB1")+" SB1 "
			cQuery += "WHERE SC6.C6_FILIAL='" + xFilial( "SC6" ) + "' AND "
            cQuery += "C6_PRODUTO >= '"+cProd_De+"' AND C6_PRODUTO <= '"+cProd_Ate+"' AND "
			cQuery += "SC6.C6_BLQ <> 'S ' AND SC6.C6_BLQ <> 'R ' AND "
			cQuery += "(SC6.C6_QTDVEN > SC6.C6_QTDENT OR (SC6.C6_QTDVEN <= SC6.C6_QTDENT AND SC6.C6_ENTREG>='"+DTOS(dDataBase-31)+"')) AND "
			cQuery += "SC6.D_E_L_E_T_=' ' AND "
			cQuery += "SB1.B1_FILIAL='" + xFilial( "SB1" ) + "' AND "
			cQuery += "SB1.B1_COD=SC6.C6_PRODUTO AND "
			cQuery += "SB1.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY C6_FILIAL,C6_NUM,C6_ITEM,C6_PRODUTO "
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC6,.T.,.T.)
			For nX := 1 To Len(aStru)
				If ( aStru[nX][2] <> "C" )
					TcSetField(cAliasSC6,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX

			lLiberOk  := .T.
			lResidOk  := .T.
			lFaturOk  := .F.

			If !lBat
				oObj:SetRegua1(SC6->(LastRec()))
				oObj:IncRegua1(cMensagem)
			EndIf

			cFilialSC9 := xFilial("SC9")
			cFilialSC6 := xFilial("SC6")
			cFilialSD2 := xFilial("SD2")

			While !(cAliasSC6)->(Eof()) .And. (cAliasSC6)->C6_FILIAL == cFilialSC6 .And. cFilialSC6 != aFilTabs[TabelaSC6][2]
				lContinua := .T.
				cQuebra   := (cAliasSC6)->C6_NUM
				BEGIN TRANSACTION
					If lContinua
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza os acumulados dos pedidos de venda entregue          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("SD2")
						dbSetOrder(8)
						If oRegSD2 == Nil
							aStruSD2  := SD2->(dbStruct())
							cAliasSD2 := "SD2MA215PROC1"

							cQuery := "SELECT D2_FILIAL,D2_PEDIDO,D2_ITEMPV,D2_QUANT,D2_QTSEGUM,D2_COD,D2_DOC,D2_SERIE,D2_EMISSAO,D2_REMITO "
							cQuery += "FROM "+RetSqlName("SD2")+" SD2 "

							If !Empty(cFilialSC6)
								cQuery += "WHERE SD2.D2_FILIAL='"+cFilialSD2+"' "
								cQuery += " AND "
							Else
								cQuery += "WHERE "
							EndIf

							If lMA215SD2
								cQuery += " SD2.D2_PEDIDO = '"+(cAliasSC6)->C6_NUM+"' "
								cQuery += " AND SD2.D2_ITEMPV = '"+(cAliasSC6)->C6_ITEM+"' "
								cQuery += " AND SD2.D2_COD = '"+(cAliasSC6)->C6_PRODUTO+"' "

								cQuery := ExecBlock("MA215SD2",.F.,.F.,cQuery)
							Else
								cQuery += " SD2.D2_PEDIDO = ? "
								cQuery += " AND SD2.D2_ITEMPV = ? "
								cQuery += " AND SD2.D2_COD = ? "

							EndIf
							cQuery += " AND SD2.D_E_L_E_T_=' ' "

							cQuery += "ORDER BY "+SqlOrder(SD2->(IndexKey()))
							cQuery := ChangeQuery(cQuery)

							// deve criar somente se não tiver o ponto de entrada
							If ! lMA215SD2
								oRegSD2 := FWPreparedStatement():New(cQuery)
							EndIf
						EndIf

						// Com ponto de entrada deve fazer a abertura normal da query
						If lMA215SD2
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
						Else
							oRegSD2:SetString(1 ,(cAliasSC6)->C6_NUM)
							oRegSD2:SetString(2 ,(cAliasSC6)->C6_ITEM)
							oRegSD2:SetString(3 ,(cAliasSC6)->C6_PRODUTO)

							cQuery := oRegSD2:GetFixQuery()
							MpSysOpenQuery(cQuery ,cAliasSD2)
							dbSelectArea(cAliasSD2)
						EndIf

						For nX := 1 To Len(aStruSD2)
							If ( aStruSD2[nX][2] <> "C" .And. FieldPos(aStruSD2[nX][1])<>0 )
								TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
							EndIf
						Next nX
						While !Eof()
							SC6->(MsGoto((cAliasSC6)->SC6RECNO))
							MaAvalSC6("SC6",5,"SC5",.F.,.F.,@lLiberOk,@lResidOk,@lFaturOk,.T.,,cAliasSD2)
							dbSelectArea(cAliasSD2)
							dbSkip()
						EndDo
						dbSelectArea(cAliasSD2)
						dbCloseArea()
						dbSelectArea("SD2")

						SC6->(MsGoto((cAliasSC6)->SC6RECNO))

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Passa as variaveis lLiberok, lResidOk e lFaturOk sem referencia para nao modificar o conteudo ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						If !Empty((cAliasSC6)->C6_RESERVA) .And.(cAliasSC6)->C6_QTDRESE > 0
							SC0->(dbSetOrder(1))
							If SC0->(MsSeek(xFilial("SC0")+(cAliasSC6)->C6_RESERVA+(cAliasSC6)->C6_PRODUTO+(cAliasSC6)->C6_LOCAL))
								Ma215Res("SC0",(cAliasSC6)->C6_QTDRESE)
							Endif
						Endif

						MaAvalSC6("SC6",1,"SC5",.F.,.F.,lLiberOk,lResidOk,lFaturOk,.T.)

						dbSelectArea("SC9")
						dbSetOrder(1)
						If oRegSC9 == Nil
							aStruSC9  := SC9->(dbStruct())
							cAliasSC9 := "SC9MA215PROC1"

							cQuery := " SELECT * "
							cQuery += " FROM "+RetSqlName("SC9")+" SC9 "
							cQuery += " WHERE SC9.C9_FILIAL= '" + cFilialSC9 + "' "
							cQuery += " AND SC9.C9_PEDIDO = ? "
							cQuery += " AND SC9.C9_ITEM = ? "
							cQuery += " AND SC9.C9_PRODUTO = ? "
							cQuery += " AND SC9.C9_NFISCAL = '"+Space(Len(SC9->C9_NFISCAL))+"' "
							cQuery += " AND SC9.C9_REMITO = '"+Space(Len(SC9->C9_REMITO))+"' "
							cQuery += " AND SC9.D_E_L_E_T_=' ' "
							cQuery += "ORDER BY "+SqlOrder(SC9->(IndexKey()))
							cQuery := ChangeQuery(cQuery)
							oRegSC9 := FWPreparedStatement():New(cQuery)
						EndIf

						oRegSC9:SetString(1 ,(cAliasSC6)->C6_NUM)
						oRegSC9:SetString(2 ,(cAliasSC6)->C6_ITEM)
						oRegSC9:SetString(3 ,(cAliasSC6)->C6_PRODUTO)

						cQuery := oRegSC9:GetFixQuery()
						MpSysOpenQuery(cQuery,cAliasSC9)
						dbSelectArea(cAliasSC9)

						For nX := 1 To Len(aStruSC9)
							If ( aStruSC9[nX][2] <> "C" .And. aStruSC9[nX][2] <> "M" )
								TcSetField(cAliasSC9,aStruSC9[nX][1],aStruSC9[nX][2],aStruSC9[nX][3],aStruSC9[nX][4])
							EndIf
						Next nX
						While !Eof() .And. cFilialSC9 == (cAliasSC9)->C9_FILIAL ;
						.And. (cAliasSC6)->C6_NUM == (cAliasSC9)->C9_PEDIDO ;
						.And. (cAliasSC6)->C6_ITEM == (cAliasSC9)->C9_ITEM

							If Empty((cAliasSC9)->C9_NFISCAL) .And. Empty((cAliasSC9)->C9_REMITO)
								If (cAliasSC9)->C9_PRODUTO == (cAliasSC6)->C6_PRODUTO
									aSaldos := {}
									If Localiza((cAliasSC9)->C9_PRODUTO) .And. ;
									(!IntWms((cAliasSC9)->C9_PRODUTO) .Or. !((cAliasSC9)->C9_BLWMS$'01;02;03'))
										cAliasSDC := "SDC"
										dbSelectArea("SDC")
										dbSetOrder(1)
										cSeekSDC := xFilial("SDC")+;
										(cAliasSC9)->C9_PRODUTO+;
										(cAliasSC9)->C9_LOCAL+;
										"SC6"+;
										(cAliasSC9)->C9_PEDIDO+;
										(cAliasSC9)->C9_ITEM
										MsSeek(cSeekSDC)
										aStru     := SDC->(dbStruct())
										cAliasSDC := "SDCMA215PROC2"

										cQuery := "SELECT * "
										cQuery += "FROM "+RetSqlName("SDC")+" SDC "
										cQuery += "WHERE SDC.DC_FILIAL='"+xFilial("SDC")+"' AND "
										cQuery += "SDC.DC_PRODUTO = '"+(cAliasSC9)->C9_PRODUTO+"' AND "
										cQuery += "SDC.DC_LOCAL = '"+(cAliasSC9)->C9_LOCAL+"' AND "
										cQuery += "SDC.DC_ORIGEM = 'SC6' AND "
										cQuery += "SDC.DC_PEDIDO = '"+(cAliasSC9)->C9_PEDIDO+"' AND "
										cQuery += "SDC.DC_ITEM = '"+(cAliasSC9)->C9_ITEM+"' AND "
										cQuery += "SDC.DC_SEQ = '"+(cAliasSC9)->C9_SEQUEN+"' AND "
										cQuery += "SDC.D_E_L_E_T_=' ' "
										cQuery += "ORDER BY "+SqlOrder(SDC->(IndexKey()))
										cQuery := ChangeQuery(cQuery)

										dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSDC,.T.,.T.)
										For nX := 1 To Len(aStru)
											If ( aStru[nX][2] <> "C" .And. aStru[nX][2] <> "M" )
												TcSetField(cAliasSDC,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
											EndIf
										Next nX
										While !Eof() .And. DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM == cSeekSDC
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Atualiza arquivo de empenhos               ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

											If (cAliasSDC)->DC_SEQ == (cAliasSC9)->C9_SEQUEN

												aadd(aSaldos,{	(cAliasSDC)->DC_LOTECTL,;
																(cAliasSDC)->DC_NUMLOTE,;
																(cAliasSDC)->DC_LOCALIZ,;
																(cAliasSDC)->DC_NUMSERI,;
																(cAliasSDC)->DC_QUANT,;
																If( Empty( (cAliasSDC)->DC_QTSEGUM ), ConvUm((cAliasSDC)->DC_PRODUTO,(cAliasSDC)->DC_QUANT,0,2),(cAliasSDC)->DC_QTSEGUM ),;
																(cAliasSC9)->C9_DTVALID,;
																"",;
																"",;
																"",;
																(cAliasSDC)->DC_LOCAL})

											EndIf
											dbSelectArea(cAliasSDC)
											dbSkip()
										EndDo
										dbSelectArea(cAliasSDC)
										dbCloseArea()
										dbSelectArea("SDC")
									Else
										nQtdLib2 := If(Empty((cAliasSC9)->C9_QTDLIB2),ConvUm((cAliasSC9)->C9_PRODUTO,(cAliasSC9)->C9_QTDLIB,0,2),(cAliasSC9)->C9_QTDLIB2)
										aSaldos := {{ "","","","",(cAliasSC9)->C9_QTDLIB,nQtdLib2,	Ctod(""),"","","",(cAliasSC9)->C9_LOCAL}}
									EndIf
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Atualiza os acumulados da liberacao do pedido de venda        ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

									MaAvalSC9(cAliasSC9,1,aSaldos,,.T.)
								EndIf
							EndIf
							dbSelectArea(cAliasSC9)
							dbSkip()
						EndDo

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza os acumulados do item do pedido de venda             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SC6->(MsGoto((cAliasSC6)->SC6RECNO))

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verificacao dos acumulados do SC5                                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ( SC6->C6_QTDVEN > (SC6->C6_QTDEMP+SC6->C6_QTDENT) .And. AllTrim(SC6->C6_BLQ)<>"R")
							lLiberOk := .F.
						EndIf
						If (! "R" $ SC6->C6_BLQ )
							lResidOk := .F.
						EndIf
						If ( SC6->C6_QTDVEN > SC6->C6_QTDENT .And. AllTrim(SC6->C6_BLQ)<>"R")
							lFaturOk := .T.
						EndIf

						dbSelectArea(cAliasSC9)
						dbCloseArea()
						dbSelectArea("SC9")
					EndIf
					dbSelectArea(cAliasSC6)
					dbSkip()
					If !lBat
						oObj:IncRegua1(cMensagem)
					EndIf
					If cQuebra <> (cAliasSC6)->C6_NUM
						dbSelectArea("SC5")
						dbSetOrder(1)
						If MsSeek(xFilial("SC5")+cQuebra)
							MaAvalSC5("SC5",1,.F.,.F.,@lLiberOk,@lResidOk,@lFaturOk,.T.)
						EndIf
						lLiberOk  := .T.
						lResidOk  := .T.
						lFaturOk  := .F.
					EndIf

				End Transaction
			EndDo

			aFilTabs[TabelaSC6][2] := cFilialSC6

			dbSelectArea(cAliasSC6)
			dbCloseArea()
			dbSelectArea("SC6")
		EndIf
		
		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os dados acumulados do PODER de 3 e EM 3.            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cFilialLida := xFilial("SB6")

		If (!Empty(cFilialLida) .AND. cFilialLida != aFilTabs[TabelaSB6][2]) .Or. (cFilAnt == cFirst)
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("SB6")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
			dbSelectArea("SB6")
			dbSetOrder(1)
			aStru     := SB6->(dbStruct())
			cAliasSB6 := "SB6MA215PROC"

			cQuery := "SELECT SB6.*,SB1.B1_FILIAL "
			cQuery += "FROM "+RetSqlName("SB6")+" SB6, "
			cQuery += RetSqlName("SB1")+" SB1 "
			cQuery += "WHERE SB6.B6_FILIAL='"+xFilial("SB6")+"' AND "
            cQuery += "B6_PRODUTO >= '"+cProd_De+"' AND B6_PRODUTO <= '"+cProd_Ate+"' AND "
			cQuery += "SB6.B6_QUANT > 0 AND "
			cQuery += "SB6.D_E_L_E_T_=' ' AND "
			cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
			cQuery += "SB1.B1_COD=SB6.B6_PRODUTO AND "
			cQuery += "SB1.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY B6_FILIAL,B6_PRODUTO,B6_LOCAL "
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB6,.T.,.T.)
			For nX := 1 To Len(aStru)
				If ( aStru[nX][2] <> "C" .And. aStru[nX][2] <> "M" )
					TcSetField(cAliasSB6,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX

			If !lBat
				oObj:SetRegua1(SB6->(LastRec()))
				oObj:IncRegua1(cMensagem)
			EndIf
			
			While !Eof() .And. xFilial("SB6") == (cAliasSB6)->B6_FILIAL
				lContinua := .T.
				cLocOriSB6:= ""

				dbSelectArea("SF4")
				dbSetOrder(1)
				MsSeek(xFilial("SF4")+(cAliasSB6)->B6_TES)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando for devolucao de material que estava em terceiros,     ³
				//|posicionar sempre no local de origem da remessa. 			 |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF4->F4_PODER3 == "D" .And. (cAliasSB6)->B6_TES < "501"
					nRegSB6 := SB6->(RecNo())
					aAreaSB6:= SB6->(GetArea())
					dbSelectArea("SB6")
					dbSetOrder(3)
					If SB6->(MsSeek(xFilial("SB6")+(cAliasSB6)->B6_IDENT+(cAliasSB6)->B6_PRODUTO+"R"))
						cLocOriSB6 := SB6->B6_LOCAL //Local de Origem
					EndIf
					RestArea(aAreaSB6)
					SB6->(MsGoto(nRegSB6))
				EndIf

				dbSelectArea("SB2")
				dbSetOrder(1)
				If MsSeek(xFilial("SB2")+(cAliasSB6)->B6_PRODUTO+IIf(Empty(cLocOriSB6),(cAliasSB6)->B6_LOCAL,cLocOriSB6))
					RecLock("SB2",.F.)
				Else
					CriaSB2((cAliasSB6)->B6_PRODUTO,(cAliasSB6)->B6_LOCAL)
				EndIf
				RecLock("SB2")

				cEstoque := (cAliasSB6)->B6_ESTOQUE

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza os Campos B2_QTER, B2_QNPT, B2_QTNP.                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				IF SF4->F4_CODIGO <= "500"   // Documentos de Entrada.
					If ( SF4->F4_PODER3 $ "DR" )
						If ( SF4->F4_PODER3 == "D" ) // Devolucoes.
							If IIf(Empty(cEstoque),SF4->F4_ESTOQUE,cEstoque)=="N"
								Replace B2_QTER with B2_QTER - (cAliasSB6)->B6_QUANT
							Else
								Replace B2_QNPT With B2_QNPT - (cAliasSB6)->B6_QUANT
							EndIf
						Else  // Remessas.
							If IIf(Empty(cEstoque),SF4->F4_ESTOQUE,cEstoque)=="N"
								Replace B2_QTER With B2_QTER + (cAliasSB6)->B6_QUANT
							Else
								Replace B2_QTNP With B2_QTNP + (cAliasSB6)->B6_QUANT
							EndIf
						EndIf
					EndIf
				Else  // Doucmentos de Saida.
					If ( SF4->F4_PODER3 $ "DR" )
						If ( SF4->F4_PODER3 == "D" )  // Devolucoes.
							If IIf(Empty(cEstoque),SF4->F4_ESTOQUE,cEstoque)=="N"
								Replace B2_QTER With B2_QTER - (cAliasSB6)->B6_QUANT
							Else
								Replace B2_QTNP With B2_QTNP - (cAliasSB6)->B6_QUANT
							EndIf
						Else  //Remessas
							If IIf(Empty(cEstoque),SF4->F4_ESTOQUE,cEstoque)=="N"
								Replace B2_QTER With B2_QTER + (cAliasSB6)->B6_QUANT
							Else
								Replace B2_QNPT With B2_QNPT + (cAliasSB6)->B6_QUANT
							EndIf
						EndIf
					EndIf
				Endif

				SB2->(MsUnLock())
				SEA215SKIP(cAliasSB6)
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			EndDo

			aFilTabs[TabelaSB6][2] := cFilialLida

			dbSelectArea(cAliasSB6)
			dbCloseArea()
			dbSelectArea("SB6")
		EndIf

		If !lBat
			oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os dados acumulados dos empenhos do SIGAPMS          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (!Empty(xFilial("AFJ")) .Or. cFilAnt == cFirst )
			dbSelectArea("SX2")
			dbSetOrder(1)
			MsSeek("AFJ")
			cMensagem := AllTrim(X2Nome())
			cMensagem := Lower(cMensagem)
			cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)

			dbSelectArea("AFJ")
			dbSetOrder(1)
			aStru     := AFJ->(dbStruct())
			cAliasAFJ := "AFJMA215PROC"

			cQuery := "SELECT AFJ.*,SB1.B1_FILIAL "
			cQuery += "FROM "+RetSqlName("AFJ")+" AFJ,"
			cQuery += RetSqlName("SB1")+" SB1 "
			cQuery += "WHERE AFJ.AFJ_FILIAL='"+xFilial("AFJ")+"' AND "
            cQuery += "AFJ_COD >= '"+cProd_De+"' AND AFJ_COD <= '"+cProd_Ate+"' AND "
			cQuery += "AFJ.AFJ_QEMP > (AFJ.AFJ_QATU + AFJ.AFJ_EMPEST) AND "
			cQuery += "AFJ.D_E_L_E_T_=' ' AND "
			cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
			cQuery += "SB1.B1_COD=AFJ.AFJ_COD AND "
			cQuery += "SB1.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY AFJ_FILIAL,AFJ_COD,AFJ_LOCAL"

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAFJ,.T.,.T.)
			For nX := 1 To Len(aStru)
				If ( aStru[nX][2] <> "C" .And. aStru[nX][2] <> "M" )
					TcSetField(cAliasAFJ,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX
			If !lBat
				oObj:SetRegua1(AFJ->(LastRec()))
				oObj:IncRegua1(cMensagem)
			EndIf
			While !Eof() .And. (cAliasAFJ)->AFJ_FILIAL == xFilial("AFJ")
				lContinua := .T.
				If lContinua
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza arquivo de empenhos               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PmsAtuEmp(	(cAliasAFJ)->AFJ_PROJET,;
								(cAliasAFJ)->AFJ_TAREFA,;
								(cAliasAFJ)->AFJ_COD,;
								(cAliasAFJ)->AFJ_LOCAL,;
								(cAliasAFJ)->AFJ_QEMP-((cAliasAFJ)->AFJ_QATU + (cAliasAFJ)->AFJ_EMPEST),;
								"+",;
								.F.,;
								(cAliasAFJ)->AFJ_QEMP2-((cAliasAFJ)->AFJ_QATU2 + (cAliasAFJ)->AFJ_EMPES2),;
								(cAliasAFJ)->AFJ_TRT)

					PmsAtuEmp(	(cAliasAFJ)->AFJ_PROJET,;
								(cAliasAFJ)->AFJ_TAREFA,;
								(cAliasAFJ)->AFJ_COD,;
								(cAliasAFJ)->AFJ_LOCAL,;
								(cAliasAFJ)->AFJ_QEMPPR,;
								"+",;
								.F.,;
								(cAliasAFJ)->AFJ_QEMPP2,;
								(cAliasAFJ)->AFJ_TRT,;
								,,,;
								.T.)
				EndIf
				SEA215SKIP(cAliasAFJ)
				If !lBat
					oObj:IncRegua1(cMensagem)
				EndIf
			EndDo
			dbSelectArea(cAliasAFJ)
			dbCloseArea()
			dbSelectArea("AFJ")
		EndIf
	EndIf

	// atualiza os acumulados da transferencia de materiais
	m215NNS(oObj,cFirst,lBat)

	If !lBat
		oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
	EndIf
	If (!Empty(xFilial("SL2")) .Or. cFilAnt == cFirst )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os dados acumulados das Reservas do SigaLoja         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX2")
		dbSetOrder(1)
		DbSeek("SL2")
		cMensagem := AllTrim(X2Nome())
		cMensagem := Lower(cMensagem)
		cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)
		dbSelectArea("SL2")
		dbSetOrder(1)
		cAliasSL2 := "SL2RES"

		// retorna a estrutura do campo L2_QUANT
		aStru := StruSL2()

		cQuery := "SELECT SUM(L2_QUANT) L2_QUANT, L2_PRODUTO, L2_FILIAL, L2_LOCAL, L2_NUM, L1_DOC, L1_SERIE , L1_ECFLAG, C5_PEDECOM  "
		cQuery += "FROM " + RetSqlName("SL2") + " SL2, " + RetSqlName("SL1") +  " SL1 "
		cQuery += "LEFT OUTER JOIN " + RetSqlName("SC5") + " SC5 ON ( SL1.L1_FILRES = SC5.C5_FILIAL AND SL1.L1_PEDRES = SC5.C5_NUM AND SC5.D_E_L_E_T_= ' ' ) "
		cQuery += "WHERE SL2.L2_FILIAL = '" + xFilial("SL2") + "' "
        cQuery += "AND L2_PRODUTO >= '"+cProd_De+"' AND L2_PRODUTO <= '"+cProd_Ate+"' "
		cQuery += "AND SL2.L2_PDV = '' "
		cQuery += "AND SL2.L2_RESERVA <> '' "
		cQuery += "AND SL2.L2_ORCRES = '' "
		cQuery += "AND SL2.L2_PEDRES = ' '"
		cQuery += "AND SL1.L1_NUM =  SL2.L2_NUM "
		cQuery += "AND SL1.L1_FILIAL = '" + xFilial("SL1") + "' "
		cQuery += "AND SL1.D_E_L_E_T_= ' ' "
		cQuery += "AND SL2.L2_VENDIDO <> 'S'"
		cQuery += "AND SL2.D_E_L_E_T_=' ' "
		cQuery += "GROUP BY SL2.L2_FILIAL, SL2.L2_PRODUTO, SL2.L2_LOCAL, SL2.L2_NUM, SL1.L1_DOC, SL1.L1_SERIE, SL1.L1_ECFLAG, SC5.C5_PEDECOM "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSL2,.T.,.T.)
		If Len(aStru) > 0
			TcSetField( cAliasSL2, aStru[1], aStru[2], aStru[3], aStru[4] )
		EndIf
		If !lBat
			oObj:SetRegua1(SL2->(LastRec()))
			oObj:IncRegua1(cMensagem)
		EndIf
		While !Eof() .And. (cAliasSL2)->L2_FILIAL == xFilial("SL2")
			lContinua := .T.
			lAtuRes   := .T.
			If RTrim((cAliasSL2)->L1_ECFLAG)  == "1"
				If !Empty((cAliasSL2)->L1_DOC) .AND. !Empty((cAliasSL2)->L1_SERIE)
					//Pedido e-commerce faturado, não atualiza a reserva
					lContinua := .F.
				ElseIf !Empty((cAliasSL2)->C5_PEDECOM)
					//Pedido e-commerce CiaShop, quantidade em reserva já foi apurada pela SC6
					lContinua := .F.
				EndIf
			EndIf

			If HasTemplate("OTC")
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek( xFilial("SB1") + (cAliasSL2)->L2_PRODUTO )
				If SB1->B1_TIPO == "LG"
					lAtuRes  := .F.
				EndIf
			EndIf

			If lContinua .AND. lAtuRes
				Ma215LjAtuRes( cAliasSL2 )
			EndIf

			SEA215SKIP(cAliasSL2)
			If !lBat
				oObj:IncRegua1(cMensagem)
			EndIf
		End

		dbSelectArea(cAliasSL2)
		dbCloseArea()
		dbSelectArea("SL2")
	EndIf
	If !lBat
		oObj:IncRegua2("Atualizando acumulados"+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL) //"Atualizando acumulados"
	EndIf

	If !lBat
		If (oObj <> NIL) .And. lNewProc
			oObj:SaveLog(OemToAnsi("Término do processamento."))
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("MENSAGEM","Final Filial: "+cFilAnt,"Final Filial: "+cFilAnt) //"Final Filial: "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve continuar a atualizar as demais filiais     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(xFilial("SA1")) .And. !Empty(xFilial("SB2")) .And. !lPCFilEnt)
		Exit
	EndIf

	//Ponto de entrada executado após o calculo para validações
	If lMT215EXC
		ExecBlock("MT215EXC",.F.,.F.)
	EndIf

	dbSelectArea("SM0")
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura o posicionamento do SIGAMAT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSM0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha todos os arquivos e reabre-os de forma compartilhada   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTempoFim := Seconds()
dDataFim  := Date()
cFilAnt := cSavFil
For nX := 1 To Len(aTabs)
	dbSelectArea(aTabs[nX])
	dbCloseArea()
Next
OpenFile(SubStr(cNumEmp,1,2),"")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia mensagem de aviso apos termino da rotina               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTempo:=StrZero(((nTempoFim+((dDataFim-dDataIni)*86400))-nTempoIni)/60,5,0)
MEnviaMail("021",{CUSERNAME,SubStr(cNumEmp,1,2),SubStr(cNumEmp,3,2),cTempo})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha o semaforo de execucao da rotina                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MA215UnLock(cEmpAnt)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogAtu("FIM")

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A215FilOk   ³ Autor ³Rodrigo de A Sartorio³ Data ³ 01/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica no SB1 a existencia do produto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A215FilOk(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Codigo do produto a ser pesquisado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. = encontrou o produto em SB1, .F.= nao encontrou       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA215                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Function A215FilOk(cProd)
//Return SB1->(MsSeek(xFilial("SB1")+cProd))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SEA215SKIP    ³ Autor ³Fernando Joly Siquini³ Data ³ 26/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Se apos o dbSkip um dos Campos Chave (Filial, Produto ou   ³±±
±±³          ³ Armazem) for alterado, a funcao MsUnlockAll() e executada. ³±±
±±³          ³ Este procedimento evita a sobrecarga de LOCKS em ambientes ³±±
±±³          ³ CDX e ADS(Em ambientes TOP a funcao nunca sera executada). ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SEA215SKIP(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Alias no qual o "dbSkip" sera executado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. caso o MsUnlockAll() seja executado, .F. caso contrario³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA215                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SEA215SKIP(c215Alias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cChaveA    := ''
Local cChaveB    := ''
Local cPrefix    := ''
Local cCpoFil    := ''
Local cCpoCod    := ''
Local cCpoLoc    := ''
Local lRet       := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefine Variaveis passadas como parametros                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default c215Alias  := Alias()

If Select(c215Alias) > 0
	dbSelectArea(c215Alias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Strings com nomes dos campos FILIAL, PRODUTO e LOCAL   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPrefix := If(SubStr(Upper(c215Alias),1,1)=='S',SubStr(Upper(c215Alias),2,2),SubStr(Upper(c215Alias),1,3))+'_'
	cCpoFil := If(FieldPos(cCpoFil:=cPrefix+'FILIAL')>0,cCpoFil,'')
	cCpoCod := If(FieldPos(cCpoCod:=cPrefix+'PRODUTO')>0,cCpoCod,If(FieldPos(cCpoCod:=cPrefix+'COD')>0,cCpoCod,''))
	cCpoLoc := If(FieldPos(cCpoLoc:=cPrefix+'LOCAL')>0,cCpoLoc,If(FieldPos(cCpoLoc:=cPrefix+'ALMOX')>0,cCpoLoc,''))
	If !((cCpoFil+cCpoCod+cCpoLoc)=='')
		cChaveA  := IIf(!Empty(cCpoFil),FieldGet(FieldPos(cCpoFil)),'')
		cChaveA  += IIf(!Empty(cCpoCod),FieldGet(FieldPos(cCpoCod)),'')
		cChaveA  += IIf(!Empty(cCpoLoc),FieldGet(FieldPos(cCpoLoc)),'')
		dbSkip()
		cChaveB := IIf(!Empty(cCpoFil),FieldGet(FieldPos(cCpoFil)),'')
		cChaveB += IIf(!Empty(cCpoCod),FieldGet(FieldPos(cCpoCod)),'')
		cChaveB += IIf(!Empty(cCpoLoc),FieldGet(FieldPos(cCpoLoc)),'')
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa o MsUnlockAll caso o dbSkip tenha alterado a Chave   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(cChaveA==cChaveB)
			MsUnLockall()
			lRet := .T.
		EndIf
	Else
		dbSkip()
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Ma215Res   ³ Autor ³Henry Fila           ³ Data ³ 19/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Avaliacao da reserva por pedido de venda ou SC9            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma215Res(ExpC1,ExpN1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do SC0 		                              ³±±
±±³          ³ ExpN2-Quantidade a reservar  			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA215                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Ma215Res(cAliasSC0,nQtdRes,nQtdPed)

Local aArea    := GetArea()
Local aAreaSC0 := SC0->(GetArea())
Local aAreaSDC := SDC->(GetArea())

Local cSeekSDC := ""
Local cAliasSDC:= "SDC"
Local aStru    := {}
Local nX       := 0
Local cQuery   := ""

DEFAULT nQtdPed  := 0

If HasTemplate("OTC")
	nQtdRes  := nQtdPed
EndIf
If Localiza((cAliasSC0)->C0_PRODUTO) .And. !IntWms((cAliasSC0)->C0_PRODUTO)
	cSeekSDC := xFilial("SDC")+;
				(cAliasSC0)->C0_PRODUTO+;
				(cAliasSC0)->C0_LOCAL+"SC0"+;
				(cAliasSC0)->C0_NUM+;
				Criavar("DC_ITEM")+;
				Criavar("DC_SEQ")+;
				(cAliasSC0)->C0_LOTECTL+;
				(cAliasSC0)->C0_NUMLOTE

	dbSelectArea("SDC")
	dbSetOrder(1)
	aStru     := SDC->(dbStruct())
	cAliasSDC := "SDCMA215PROC1"

	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SDC")+" SDC "
	cQuery += "WHERE SDC.DC_FILIAL='"+xFilial("SDC")+"' AND "
	cQuery += "SDC.DC_PRODUTO='"+(cAliasSC0)->C0_PRODUTO+"' AND "
	cQuery += "SDC.DC_LOCAL='"+(cAliasSC0)->C0_LOCAL+"' AND "
	cQuery += "SDC.DC_ORIGEM='SC0' AND "
	cQuery += "SDC.DC_PEDIDO='"+(cAliasSC0)->C0_NUM+"' AND "
	cQuery += "SDC.DC_ITEM='"+Criavar("DC_ITEM")+"' AND "
	cQuery += "SDC.DC_SEQ='"+Criavar("DC_SEQ")+"' AND "
	cQuery += "SDC.DC_LOTECTL='"+(cAliasSC0)->C0_LOTECTL+"' AND "
	cQuery += "SDC.DC_NUMLOTE='"+(cAliasSC0)->C0_NUMLOTE+"' AND "
	cQuery += "SDC.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(SDC->(IndexKey()))

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSDC,.T.,.T.)
	For nX := 1 To Len(aStru)
		If ( aStru[nX][2] <> "C" .And. aStru[nX][2] <> "M" )
			TcSetField(cAliasSDC,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX
	While !Eof() .And. DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE == cSeekSDC
		GravaEmp(	(cAliasSDC)->DC_PRODUTO,;
					(cAliasSDC)->DC_LOCAL,;
					(cAliasSDC)->DC_QUANT,;
					(cAliasSDC)->DC_QTSEGUM,;
					(cAliasSDC)->DC_LOTECTL,;
					(cAliasSDC)->DC_NUMLOTE,;
					(cAliasSDC)->DC_LOCALIZ,;
					(cAliasSDC)->DC_NUMSERI,;
					Nil,;
					Nil,;
					(cAliasSDC)->DC_PEDIDO,;
					Nil,;
					"SC0",;
					Nil,;
					Nil,;
					Nil,;
					.F.,;
					.F.,;
					.T.,;
					.F.,;
					NIL,;
					.T.,;
					.F.)
		SEA215SKIP(cAliasSDC)
	EndDo
	dbSelectArea(cAliasSDC)
	dbCloseArea()
	dbSelectArea("SDC")
Else
	GravaEmp(	(cAliasSC0)->C0_PRODUTO,;
				(cAliasSC0)->C0_LOCAL,;
				nQtdRes,;
				NIL,;
				(cAliasSC0)->C0_LOTECTL,;
				(cAliasSC0)->C0_NUMLOTE,;
				(cAliasSC0)->C0_LOCALIZ,;
				(cAliasSC0)->C0_NUMSERI,;
				Nil,;
				Nil,;
				(cAliasSC0)->C0_NUM,;
				Nil,;
				"SC0",;
				Nil,;
				Nil,;
				Nil,;
				.F.,;
				.F.,;
				.T.,;
				.F.,;
				Nil,;
				!Empty((cAliasSC0)->C0_LOTECTL+(cAliasSC0)->C0_NUMLOTE+(cAliasSC0)->C0_LOCALIZ+(cAliasSC0)->C0_NUMSERI),; //22
				.F.)
EndIf

RestArea(aAreaSC0)
RestArea(aAreaSDC)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ma215LjAtuResºAutor  ³Marcio Lopes        º Data ³  15/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a atualizacao do campo B2_RESERVA, para o modulo      º±±
±±º          ³ SIGALOJA.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpC1 -> Alias do arquivos a ser utilizado                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ma215LjAtuRes( cAliasSL2 )

Local aAreaSB2 := SB2->(GetArea())			// Guarda a area atual do SB2

SB2->(dbSetOrder(1))
If SB2->( dbSeek(xFilial("SB2") + (cAliasSL2)->L2_PRODUTO + (cAliasSL2)->L2_LOCAL ) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o produto é uma reserva na base do SIGALOJA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SB2", .F.)
	SB2->B2_RESERVA += (cAliasSL2)->L2_QUANT
	MsUnlock()
EndIf
Restarea(aAreaSB2)
dbSelectArea(cAliasSL2)

Return(.T.)

/*
Function Ma215Check()
Local aTabs     := {}
Local nX        := 0
Local lContinua := .T.
Local cAliasTab := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente validar se as tabelas estao exclusivas se a rotina 'Refaz        |
//|Acumulados (MATA215)' estiver em execucao.                               |
//|O parametro MV_A215CHK devera ser utilizado somente para contingencia.   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LockByName("MT215"+AllTrim(cEmpAnt),.T.,.F.) .And. SuperGetMv("MV_A215CHK",.F.,.T.)

	//Tabelas utilizadas pela rotina
	AADD(aTabs,"SA1");AADD(aTabs,"SB1");AADD(aTabs,"SB2")
	AADD(aTabs,"SB8");AADD(aTabs,"SC0");AADD(aTabs,"SC6")
	AADD(aTabs,"SC7");AADD(aTabs,"SC9");AADD(aTabs,"SD2")
	AADD(aTabs,"SD1");AADD(aTabs,"SD4");AADD(aTabs,"SDC")
	AADD(aTabs,"SDD");AADD(aTabs,"SC1");AADD(aTabs,"SC2")
	AADD(aTabs,"SB6");AADD(aTabs,"SBF");AADD(aTabs,"SDA")
	AADD(aTabs,"SL2");AADD(aTabs,"SCQ")
	AADD(aTabs,"DH1");AADD(aTabs,"D0G")

	//Verifica se as tabelas estao em modo exclusivo
	For nX := 1 to Len(aTabs)
		If !(ChkFile(aTabs[nX],.T.))
			cAliasTab := aTabs[nX]
			lContinua := .F.
			Exit
		EndIf
		(aTabs[nX])->(dbCloseArea())
		ChkFile(aTabs[nX],.F.)
	Next nX

	//Mensagem para o usuario
	If !lContinua
		Help(" ",1,"MA215CHK")

		FINAL(STR0014 + Space(1) + cAliasTab,,.F.)	//"MA215CHECK: Não foi possivel a abertura da tabela"

	EndIf

Else

	// Desbloqueia o Lock
	MA215UnLock(cEmpAnt)

EndIf
Return
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³MA215Lock   ³ Autor ³ TOTVS S/A           ³ Data ³ 20.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Bloqueio de Empresas para o processamento da rotina        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Empresa                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA215                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MA215Lock(cEmpresa)
Local lRet       := .T.
Local nTentativa := 0

nTentativa := 0
// Trava arquivo para somente este usuario utilizar rotina
While !LockByName("MT215"+AllTrim(cEmpresa),.T.,.F.) .And. nTentativa <= 50
	nTentativa++
	Sleep(100)
End

// Tenta travar somente 50 vezes, e se nao conseguir coloca na lista de filiais com concorrencia
If nTentativa > 50
	If !IsBlind()
		Aviso("Concorrência","A empresa corrente já esta sendo utilizadas no processo de refaz acumulados: "+cEmpresa,{"Ok"},2) // ##"Concorrência"##"A empresa corrente já esta sendo utilizadas no processo de refaz acumulados: "
	EndIf
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MA215UnLock ³ Autor ³ TOTVS S/A           ³ Data ³ 20.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Desbloqueio de Empresa                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Empresa                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA215                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MA215UnLock(cEmpresa)

// Destrava o bloqueio de filiais
UnLockByName("MT215"+AllTrim(cEmpresa),.T.,.F.)

Return

/*/{Protheus.doc} m215NNS
//Atualizacao dos emepnehos efetuados na rotina MATA311.
@author reynaldo
@since 24/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oObj, object, descricao
@param cFirst, characters, descricao
@param lBat, logical, descricao
@type function
/*/
Static Function m215NNS(oObj,cFirst,lBat)
Local cMensagem := ""
Local cAliasNNT	:= ""
Local cQuery	:= ""
Local aStru		:= {}
Local nX		:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza os dados acumulados dos empenhos da MATA311          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(xFilial("NNS")) .Or. cFilAnt == cFirst )
		dbSelectArea("SX2")
		dbSetOrder(1)
		MsSeek("NNS")
		cMensagem := AllTrim(X2Nome())
		cMensagem := Lower(cMensagem)
		cMensagem := Upper(SubStr(cMensagem,1,1))+SubStr(cMensagem,2)

		dbSelectArea("NNT")
		dbSetOrder(1)
		aStru     := NNT->(dbStruct())
		cAliasNNT := "NNTMA215PROC"

		cQuery := "SELECT NNT.*, SB1.R_E_C_N_O_ AS SB1RECNO "
		cQuery += "FROM "+RetSqlName("NNT")+" NNT "
		cQuery += " INNER JOIN " + RetSqlName("NNS")+" NNS "
		cQuery += "ON NNS.NNS_FILIAL = '"+xFilial("NNS")+"' AND NNS.NNS_COD = NNT.NNT_COD "
		cQuery += "AND NNS.NNS_STATUS = '1' AND NNS.D_E_L_E_T_= ' ' "
		cQuery += " INNER JOIN " + RetSqlName("SB1")+" SB1 "
		cQuery += "ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = NNT.NNT_PROD "
		cQuery += "AND SB1.D_E_L_E_T_= ' ' "
		cQuery += "WHERE NNT.NNT_FILIAL = '"+xFilial("NNT")+"' "
		cQuery += "AND NNT.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNNT,.T.,.T.)
		For nX := 1 To Len(aStru)
			If ( aStru[nX][2] <> "C" .And. aStru[nX][2] <> "M" )
				TcSetField(cAliasNNT,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX
		If !lBat
			oObj:SetRegua1(NNT->(LastRec()))
			oObj:IncRegua1(cMensagem)
		EndIf
		While (cAliasNNT)->(!Eof())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza arquivo de empenhos               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Localiza((cAliasNNT)->NNT_PROD)
				//Gera empenho do produto por endereço
				SBF->( DbSetOrder(1) ) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
				If SBF->( DbSeek(xFilial('SBF',(cAliasNNT)->NNT_FILORI)+(cAliasNNT)->(NNT_LOCAL+NNT_LOCALI+NNT_PROD+NNT_NSERIE+NNT_LOTECT+NNT_NUMLOT)) )
					GravaBFEmp("+",(cAliasNNT)->NNT_QUANT,"F",,(cAliasNNT)->NNT_QTSEG)
				Endif
			EndIf
			If Rastro((cAliasNNT)->NNT_PROD)
				//Gera empenho do produto por lote ou sub-lote
				SB8->( DbSetOrder(3) )
				If SB8->( DbSeek(xFilial('SB8',(cAliasNNT)->NNT_FILORI)+(cAliasNNT)->(NNT_PROD+NNT_LOCAL+NNT_LOTECT+NNT_NUMLOT)) )
					GravaB8Emp("+",(cAliasNNT)->NNT_QUANT,"F",NIL,(cAliasNNT)->NNT_QTSEG)
				Endif
			EndIf
			//Gera do produto por armazém
			SB2->( DbSetOrder(1) )
			If SB2->( DbSeek(xFilial('SB2',(cAliasNNT)->NNT_FILORI)+(cAliasNNT)->(NNT_PROD+NNT_LOCAL)) )
				GravaB2Emp("+",(cAliasNNT)->NNT_QUANT,"F",NIL,(cAliasNNT)->NNT_QTSEG)
			Endif
			//Gera previsão de Entrada na Filial de Destino
			SB2->( DbSetOrder(1) )
			If SB2->( DbSeek(xFilial("SB2",(cAliasNNT)->NNT_FILDES)+(cAliasNNT)->(NNT_PRODD+NNT_LOCLD)) )
				GravaB2Pre('+',(cAliasNNT)->NNT_QUANT,"F",(cAliasNNT)->NNT_QTSEG)
			Endif
			(cAliasNNT)->(dbSkip())
			If !lBat
				oObj:IncRegua1(cMensagem)
			EndIf
		EndDo
		dbSelectArea(cAliasNNT)
		dbCloseArea()
		dbSelectArea("NNT")
	EndIf
Return

/*/{Protheus.doc} StruSL2
Returna a estrutura do campo L2_QUANT
@author reynaldo
@since 12/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function StruSL2()
Local aRetStru	:= {}
Local aSL2Stru	:= {}
Local nPosField	:= 0

dbSelectArea("SL2")
aSL2Stru := SL2->(dbStruct())
nPosField := AScan( aSL2Stru ,{|aField|aField[1]=="L2_QUANT"})
If nPosField >0
	aRetStru := aSL2Stru[nPosField]
EndIf

Return aRetStru
