#Include "Totvs.ch"

#IFNDEF _ENTER_
	#DEFINE _ENTER_ (Chr(13)+Chr(10))
	// Alert("miguel")
#ENDIF

Static cSEMAFORO := Upper("VAJOB20"+cValToChar(ThreadId()))
Static cRunOnce := "RUNONCEJOB" 

User Function VAJOB20()

    ConOut('VAJOB20(): ' + Time())
	
	If Type("oMainWnd") == "U"
		ConOut('oMainWnd: ' + Time())
		U_RunFunc("U_JOB20VA()",'01','01',3) 
	Else
		ConOut('Else oMainWnd: ' + Time())
		U_JOB20VA()
	EndIf

Return

User Function JOB20VA()
   	Local aArea	   		:= GetArea()
	Local _cQry    		:= ""
	Local cAlias 		:= ""
	Local cSSKey     	:= cEmpAnt+CHR(255)+cFilAnt+CHR(255)
	local nThreads		:= 1
	Local nI			:= 0
	Local cIDThread		:= cValToChar(ThreadId())

	If Type("__DATA") == "U"
		Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsdDataBase, dDataBase)
	EndIf
	If Type("cFile") == "U"
		Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
	EndIf

	_cQry := " WITH DADOS AS ( " + CRLF
   	_cQry += " select Z0Y_CODEI, Z0Y_ROTA  AS ROTAS , Z0X.R_E_C_N_O_ RECNO, Z0X_OPERAC OPERACAO " + CRLF 
   	_cQry += "   FROM "+RetSqlName("Z0Y")+" Z0Y " + CRLF 
	_cQry += " 	 JOIN "+RetSqlName("Z0X")+" Z0X ON Z0X_FILIAL = Z0Y_FILIAL AND Z0X_CODIGO = Z0Y_CODEI AND Z0X_DATA = Z0Y_DATA AND Z0X.D_E_L_E_T_ =' ' --AND Z0X_OPERAC <> '1' " + CRLF 
	_cQry += " 	 WHERE ( Z0Y_QTDREA > 0 OR Z0Y_PESDIG > 0)  " + CRLF 
	_cQry += " 	   AND Z0Y_DATPRC = ' '  " + CRLF 
	_cQry += " 	   AND Z0Y_CONFER = 'T' " + CRLF 
	_cQry += " 	   AND Z0Y_DATA = '" +DTOS(__DATA)+ "' " + CRLF 
	_cQry += " 	   AND Z0Y.D_E_L_E_T_ =' '  " + CRLF
	_cQry += " 	UNION  " + CRLF
	_cQry += " select TOP(1) Z0Y_CODEI, Z0Y_ROTA  AS ROTAS, Z0X.R_E_C_N_O_ RECNO, Z0X_OPERAC OPERACAO " + CRLF
   	_cQry += "   FROM "+RetSqlName("Z0Y")+" Z0Y " + CRLF 
	_cQry += " 	 JOIN "+RetSqlName("Z0X")+" Z0X ON Z0X_FILIAL = Z0Y_FILIAL AND Z0X_CODIGO = Z0Y_CODEI AND Z0X_DATA = Z0Y_DATA AND Z0X.D_E_L_E_T_ =' ' --AND Z0X_OPERAC = '1' " + CRLF 
	_cQry += " 	 WHERE ( Z0Y_QTDREA > 0 OR Z0Y_PESDIG > 0)  " + CRLF
	_cQry += " 	   AND Z0Y_DATPRC = ' '  " + CRLF
	_cQry += " 	   AND Z0Y_CONFER = 'T' " + CRLF
	_cQry += " 	   AND Z0Y_DATA = '" +DTOS(__DATA)+ "' " + CRLF
	_cQry += " 	   AND Z0Y.D_E_L_E_T_ =' '  " + CRLF 
	_cQry += " 	UNION  " + CRLF 
   	_cQry += " select TOP(1) Z0W_CODEI, Z0W_ROTA  AS ROTAS ,Z0X.R_E_C_N_O_ RECNO, Z0X_OPERAC OPERACAO " + CRLF 
   	_cQry += "   FROM "+RetSqlName("Z0W")+" Z0W " + CRLF 
	_cQry += " 	 JOIN "+RetSqlName("Z0X")+" Z0X ON Z0X_FILIAL = Z0W_FILIAL AND Z0X_CODIGO = Z0W_CODEI AND Z0X_DATA = Z0W_DATA AND Z0X.D_E_L_E_T_ =' '  --AND Z0X_OPERAC = '1'" + CRLF 
	_cQry += " 	 WHERE ( Z0W_QTDREA > 0 OR Z0W_PESDIG > 0)  " + CRLF 
	_cQry += " 	   AND Z0W_DATPRC = ' '  " + CRLF 
	_cQry += " 	   AND Z0W_CONFER = 'T' " + CRLF 
	_cQry += " 	   AND Z0W_DATA = '" +DTOS(__DATA)+ "'" + CRLF 
	_cQry += " 	   AND Z0W.D_E_L_E_T_ =' '  " + CRLF
	_cQry += " 	   ) " + CRLF 
	_cQry += " 	   SELECT DISTINCT RECNO, ROTAS, OPERACAO FROM DADOS ORDER BY OPERACAO DESC " + CRLF
	
	cAlias := MpSysOpenQuery(_cQry)

	DBSelectArea("Z0X")
	Z0X->(DBSetOrder(1))

	cIDThread := cValToChar(ThreadID())
	cSemaforo := Upper("VAJOB20"+cIDThread+"_"+cEmpAnt)
	
	i := 1

	While !((cAlias)->(EOF()))
		Z0X->(DbGoTo((cAlias)->RECNO))
		
		U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
					"[" + AllTrim(Z0X->Z0X_CODIGO) + "]" +_ENTER_+;
					"Função: JOB20VA" + _ENTER_ +;
					"Processando os dados [" + Z0X->Z0X_CODIGO + "]",;
					.T./* lConOut */,;
					/* lAlert */ )
		
		A330JobManual('1', cSemaforo, 'u_ConnOne', nThreads, cSSKey)
		
		ConOut("Contador: " + cValToChar(i))
		
		ConOut("Thread Iniciada: " + cValToChar(ThreadId())  + cValToChar(time()) + " " + ProcName())
		
		While !IpcGo(cSemaforo, .F., (cAlias)->RECNO,(cAlias)->Z0Y_ROTA)
			Sleep(500)
		EndDo
		
		lLoop      := .T.
		nCntThread := 0

		While lLoop 
			aUsers := GetUserInfoArray()
			For nI := 1 to len(aUsers)
				If aUsers[nI][1] == cSemaforo // semaforo
					cIDSubThr := cValToChar(aUsers[nI][3])  // ID da working thread
					cGlbName := "cThrWrk"+cIDSubThr // define o nome da variavel global
					cGlbValue := GetGlbValue(cGlbName) // Verifica valor da variável

					If cGlbValue == "1"
						nCntThread++ // conta qtas working threads abertas e executando
					EndIf
				EndIf
			Next nI

			If nCntThread == 0
				lLoop := .F. //Todas processadas, encerra o loop
			EndIf
			nCntThread := 0
			sleep(2000)

			//Limpa array
			For nI := 1 To Len(aUsers)
				aSize(aUsers[nI], 0)
			Next nI
			aUsers := aSize(aUsers,0)
		EndDo

		ConOut("Thread processada: " + cValToChar(ThreadId())  + cValToChar(time()) + " " + ProcName())

		A330JobManual('2', cSemaforo, 'u_ConnOne', nThreads, cSSKey )
		
		ConOut("Thread finalizada: " + cValToChar(ThreadId())  + cValToChar(time()) + " " + ProcName())
		
		(cAlias)->(DBSkip())
		i++
	EndDo
	(cAlias)->(DBCloseArea())

	Z0X->( DBCloseArea() )

    RestArea(aArea)
Return

Static Function MontaQuery()
	Local _cQry := ""

	_cQry := " SELECT MAX(Z02.Z02_SEQUEN) AS SEQ " + _ENTER_
	_cQry += " FROM " + RetSqlName("Z02") + " Z02 " + _ENTER_
	_cQry += " WHERE Z02.Z02_FILIAL = ? " + _ENTER_
	_cQry += "   AND Z02.D_E_L_E_T_ = ' ' " + _ENTER_
		
	oZ02SEQ := FwExecStatement():New(_cQry)
	
	_cQry := " SELECT Z0Y.Z0Y_ORDEM AS ORDEM, Z0Y.Z0Y_RECEIT AS RECEITA, Z0Y.Z0Y_COMP AS COMP, Z0Y.Z0Y_ROTA AS ROTA, Z0X.Z0X_OPERAD AS OPERAD, SUM(Z0Y.Z0Y_QTDPRE) AS QTDPRE, SUM(CASE Z0Y.Z0Y_PESDIG WHEN 0 THEN Z0Y.Z0Y_QTDREA ELSE Z0Y.Z0Y_PESDIG END) AS QTDREA " + _ENTER_
	_cQry += "     , (SELECT SUM(CASE Z0Y2.Z0Y_PESDIG WHEN 0 THEN Z0Y2.Z0Y_QTDREA ELSE Z0Y2.Z0Y_PESDIG END) FROM " + RetSqlName("Z0Y") + " Z0Y2 WHERE Z0Y2.Z0Y_FILIAL = '" + fwxFilial("Z0Y") + "' AND Z0Y2.Z0Y_ORDEM = Z0Y.Z0Y_ORDEM AND Z0Y2.Z0Y_RECEIT = Z0Y.Z0Y_RECEIT AND Z0Y2.Z0Y_DATINI <> '' AND Z0Y2.Z0Y_DATPRC = '' AND Z0Y2.Z0Y_CONFER = 'T' AND Z0Y2.D_E_L_E_T_ = ' ' ) AS TOT " + _ENTER_
	_cQry += " FROM " + RetSqlName("Z0X") + " Z0X " + _ENTER_
	_cQry += " LEFT JOIN " + RetSqlName("Z0Y") + " Z0Y ON Z0Y.Z0Y_CODEI = Z0X.Z0X_CODIGO AND Z0Y.Z0Y_FILIAL = '" + fwxFilial("Z0Y") + "' AND Z0Y.D_E_L_E_T_ = ' ' " + _ENTER_ 
	_cQry += " WHERE Z0X.Z0X_FILIAL = ? " + _ENTER_
	_cQry += "   AND Z0X.D_E_L_E_T_ = ' ' " + _ENTER_
	_cQry += "   AND Z0X.Z0X_CODIGO = ? " + _ENTER_
	_cQry += "   AND Z0X.Z0X_DATA = ? " + _ENTER_
	_cQry += "   AND Z0Y.Z0Y_DATINI <> '' " + _ENTER_
	_cQry += "   AND Z0Y.Z0Y_DATPRC = '' " + _ENTER_
	_cQry += "   AND Z0Y.Z0Y_CONFER = 'T' " + _ENTER_
	_cQry += "   AND Z0Y.Z0Y_ROTA   = ? " + _ENTER_
	_cQry += " GROUP BY Z0Y.Z0Y_ORDEM, Z0Y.Z0Y_RECEIT, Z0Y.Z0Y_COMP, Z0Y.Z0Y_ROTA, Z0X.Z0X_OPERAD " + _ENTER_
	_cQry += " ORDER BY Z0Y.Z0Y_ORDEM, Z0Y.Z0Y_RECEIT, Z0Y.Z0Y_COMP, Z0Y.Z0Y_ROTA " + _ENTER_
	
	MEMOWRITE("C:\TOTVS_RELATORIOS\EXPIMPPRCC.sql", _cQry)
	
	oZ0YQry := FwExecStatement():New(_cQry)
	
	_cQry := " SELECT * " + _ENTER_
	_cQry += " FROM " + RetSqlName("Z0Y") + " Z0Y " + _ENTER_
	_cQry += " WHERE Z0Y.Z0Y_FILIAL = ? " + _ENTER_
	_cQry += "   AND Z0Y.D_E_L_E_T_ = ' ' " + _ENTER_
	_cQry += "   AND Z0Y.Z0Y_CODEI = ? " + _ENTER_
	_cQry += "   AND Z0Y.Z0Y_DATPRC = '' " + _ENTER_
	//_cQry += "   AND Z0Y.Z0Y_ROTA = ? " + _ENTER_

	oZ0YQry1 := FwExecStatement():New(_cQry)

	_cQry := " SELECT Z0W_ROTA, Z0W.Z0W_CURRAL AS CURRAL, Z0W.Z0W_LOTE AS LOTE, SUM(Z0W.Z0W_QTDPRE) AS QTDPRE, SUM(CASE Z0W.Z0W_PESDIG WHEN 0 THEN Z0W.Z0W_QTDREA ELSE Z0W.Z0W_PESDIG END) AS QTDREA, Z0W.Z0W_RECEIT AS DIETA " + _ENTER_
	_cQry += "      , (SELECT Z05.Z05_CABECA FROM " + RetSqlName("Z05") + " Z05 WHERE Z05.Z05_FILIAL = ? AND Z05.D_E_L_E_T_ = ' ' AND Z05.Z05_DATA = ? AND Z05.Z05_CURRAL = Z0W.Z0W_CURRAL) AS CBC "  + _ENTER_
	_cQry += "      , (SELECT SUM(CASE Z0Y.Z0Y_PESDIG WHEN 0 THEN Z0Y.Z0Y_QTDREA ELSE Z0Y.Z0Y_PESDIG END) FROM " + RetSqlName("Z0Y") + " Z0Y WHERE Z0Y.Z0Y_FILIAL = ? AND Z0Y.D_E_L_E_T_ = ' ' AND Z0Y.Z0Y_ORDEM = Z0W.Z0W_ORDEM AND Z0Y.Z0Y_RECEIT = Z0W.Z0W_RECEIT AND Z0Y.Z0Y_DATPRC <> '' AND Z0Y.Z0Y_CONFER = 'T' AND Z0W.Z0W_DATA = Z0Y.Z0Y_DATA) AS TOTBAT "  + _ENTER_
	_cQry += "      , (SELECT SUM(CASE Z0WA.Z0W_PESDIG WHEN 0 THEN Z0WA.Z0W_QTDREA ELSE Z0WA.Z0W_PESDIG END) FROM " + RetSqlName("Z0W") + " Z0WA WHERE Z0WA.Z0W_FILIAL = ? AND Z0WA.D_E_L_E_T_ = ' ' AND Z0WA.Z0W_ORDEM = Z0W.Z0W_ORDEM AND Z0WA.Z0W_RECEIT = Z0W.Z0W_RECEIT AND Z0WA.Z0W_DATINI <> '' AND Z0WA.Z0W_DATPRC = '' AND Z0WA.Z0W_CONFER = 'T' AND Z0WA.Z0W_LOTE IN (SELECT DISTINCT SB8.B8_LOTECTL FROM " + RetSqlName("SB8") + " SB8 WHERE SB8.B8_FILIAL = ? AND SB8.B8_SALDO > 0 AND SB8.D_E_L_E_T_ = ' ' )) AS TOTTRT "  + _ENTER_
	_cQry += " FROM " + RetSqlName("Z0X") + " Z0X " + _ENTER_
	_cQry += " LEFT JOIN " + RetSqlName("Z0W") + " Z0W ON Z0W.Z0W_CODEI = Z0X.Z0X_CODIGO AND Z0W.Z0W_FILIAL = ? AND Z0W.D_E_L_E_T_ = ' ' " + _ENTER_ 
	_cQry += " WHERE Z0X.Z0X_FILIAL = ? " + _ENTER_
	_cQry += "   AND Z0X.D_E_L_E_T_ = ' ' " + _ENTER_
	_cQry += "   AND Z0X.Z0X_CODIGO = ? " + _ENTER_
	_cQry += "   AND Z0X.Z0X_DATA = ? " + _ENTER_
	_cQry += "   AND Z0W.Z0W_DATINI <> '' " + _ENTER_
	_cQry += "   AND Z0W.Z0W_DATPRC = '' " + _ENTER_
	_cQry += "   AND Z0W.Z0W_CONFER = 'T' " + _ENTER_
	_cQry += "   AND Z0W.Z0W_ROTA = ? " + _ENTER_
	_cQry += "   AND Z0W.Z0W_LOTE IN (SELECT SB8.B8_LOTECTL FROM " + RetSqlName("SB8") + " SB8 WHERE SB8.B8_FILIAL = ? AND SB8.B8_SALDO > 0 AND SB8.D_E_L_E_T_ = ' ' ) "+ _ENTER_
	_cQry += " GROUP BY Z0W.Z0W_ROTA,Z0W.Z0W_CURRAL, Z0W.Z0W_LOTE, Z0W.Z0W_RECEIT, Z0W.Z0W_ORDEM, Z0W.Z0W_DATA " + _ENTER_
	_cQry += " ORDER BY Z0W.Z0W_CURRAL, Z0W.Z0W_LOTE, Z0W.Z0W_RECEIT " + _ENTER_

	oZ0WQry := FwExecStatement():New(_cQry)

	_cQry := " SELECT * " + _ENTER_
	_cQry += " FROM " + RetSqlName("Z0W") + " Z0W " + _ENTER_
	_cQry += " WHERE Z0W.Z0W_FILIAL = ? " + _ENTER_
	_cQry += "   AND Z0W.D_E_L_E_T_ = ' ' " + _ENTER_
	_cQry += "   AND Z0W.Z0W_CODEI = ? " + _ENTER_
	_cQry += "   AND Z0W.Z0W_DATPRC = ' ' " + _ENTER_

	oZ0WSel := FwExecStatement():New(_cQry)
Return nil

Static Function A330JobManual(cStatus, cIdentificador, cJobConnect, nTotThread, cSessionKey )
	LOCAL nMinThread
	LOCAL nMaxThread
	LOCAL nFreeThread
	LOCAL nIncThread

	Default nTotThread  := SuperGetMV("MV_M330THR",.F.,1)
	Default cSessionKey := cEmpAnt+CHR(255)+cFilAnt+CHR(255)

	// inicia o manualJob
	If cStatus == "1"
		If nTotThread > 10
			nTotThread := 10
		ElseIf nTotThread == 9
			nTotThread := 10
		Else
			nTotThread := nTotThread+2
		EndIf
		
		nMinThread := 1 //Val(GetSrvProfString( "ThreadMinOrdem", cValToChar(nTotThread) ))
		nMaxThread := 1 //Val(GetSrvProfString( "ThreadMaxOrdem", "30" ))
		nFreeThread := 1
		nIncThread := 1
	EndIf

	// encerra o manualJob
	If cStatus == "2"
		nMinThread := 0
		nMaxThread := 0
		nFreeThread := 0
		nIncThread := 0
	EndIf

   ManualJob(	cIdentificador/*Nome do indentificador do job*/,;
				GetEnvServer()/*Ambiente que vc vai abrir este cara*/,;
				"IPC"/*Tipo do job. Mantenha como Ipc*/,;
				"M330JOBSTART"/*Função que será chamada quando uma nova thread subir*/,;
				cJobConnect/*Função que será chamada toda vez que vc mandar um ipcgo para ela*/,;
				"M330JOBEXIT"/*Função que será invocada quando a thread cair pelo timeout dela*/,;
				cSessionKey/*Não alterar. É o SessionKey*/,;
				300 /*Tempo em segundos que a thread será reavaliada e irá cair. Vamos manter 5 minutos. Se não receber nada ela morre*/,;
				nMinThread /*Minimo de threads inicias. Vamos deixar 0 para que quando cair por timeout ele acabe*/,;
				nMaxThread /*máximo de threads que ele vai subir*/,;
				nFreeThread /*mínimo de threads livres*/,;
				nIncThread /*incremento de threads livres*/,;
      		)

	If cStatus == "2"
		DownThread(cIdentificador)
	EndIf

Return .T.
/*/{Protheus.doc} DownThread
	Baixa das working thread abertas, onde o controle é feito através de variaveis globais
	@type  Function
	@author reynaldo
	@since 30/06/2020
	@version 1.0
	@param cIdentificador, caracter, Nome do semaforo
	@return Sempre retorno NIL
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function DownThread(cIdentificador)
	LOCAL lLoop
	LOCAL nI
	LOCAL nCntThread
	LOCAL aUsers
	LOCAL cGlbName
	LOCAL cGlbValue
	LOCAL cIDThread

	lLoop := .T.
	nI := 0
	aUsers := {}

	//M330PrcLog("MENSAGEM",OemToAnsi(I18N(STR0217,{cIdentificador})),OemToAnsi(I18N(STR0217,{cIdentificador}))) // ## "Encerramento das working threads #1[A330TT2B2_37688_01]# - (0) Inicio"
	//ConOut("[MATA330] "+dtoc(Date())+" "+Time()+" " +I18N(STR0217,{cIdentificador}) ) // ## "Encerramento das working threads #1[A330TT2B2_37688_01]# - (0) Inicio"

	While lLoop // loop de controle para encerramento de todas as working threads
		aUsers := GetUserInfoArray()
		For nI := 1 to len(aUsers)
			If aUsers[nI][1] == cIdentificador // semaforo

				nCntThread++ // conta qtas working threads abertas

				cIDThread := cValToChar(aUsers[nI][3])  // ID da working thread

				cGlbName := "cThrWrk"+cIDThread // define o nome da variavel global

				cGlbValue := GetGlbValue(cGlbName) // Verifica valor da variável

				If cGlbValue == "0"
					IPCGO( cIdentificador,.T.)
				EndIf
			EndIf
		Next nI
		aUsers := aSize(aUsers,0)
		If nCntThread ==0
			lLoop := .F.
		EndIf
		nCntThread := 0
		sleep(1000)
	EndDo

RETURN NIL

USER FUNCTION M330JOBSTART(cParam)
	LOCAL cGlbName
	//LOCAL cLFil
	//LOCAL cLEmp
	//Local cParam3  := '' As Character
	//Local nIndex   := 0  As Numeric

	cGlbName  := "cThrWrk"+cValToChar(ThreadId())
	
	A330LckGlb(cGlbName)
   	PutGlbValue(cGlbName,"1")
	A330ULckGlb(cGlbName)
	
	RpcSetType(3)
	RpcSetEnv( "01","01",,,'EST',,aTabelas)

	A330LckGlb(cGlbName)
   	PutGlbValue(cGlbName,"0")
	A330ULckGlb(cGlbName)
RETURN .T.

USER FUNCTION M330JOBEXIT()
RETURN .T.

/*/{Protheus.doc} A330LckGlb
	Função responsável por garantir o uso da varável global em atualização
	@type  Function
	@author Nilton Rodrigues
	@since 05/09/2022
	@param cNameGlobal , character, Nome da variável global
	@version 1.0
/*/
USER Function A330LckGlb(cNameGlobal)
	//- Garante que apenas um pegue o ID
	While !KillApp()
		//- Valida se peguei a chave
		If GlbNmLock(cNameGlobal)
			Exit
		EndIf
		Sleep(175)
	EndDo
Return

/*/{Protheus.doc} A330ULckGlb
	Função responsável por liberar o uso da varável global em atualização
	@type  Function
	@author Nilton Rodrigues
	@since 05/09/2022
	@param cNameGlobal , character, Nome da variável global
	@version 1.0
/*/
USER Function A330ULckGlb(cNameGlobal)
	GlbNmUnlock(cNameGlobal)
Return

/*
 * Funcao que sera chamada uma vez
*/
Function u_ConnOne(lBreak,nRecno,cRota)
    LOCAL cGlbName as Character
	LOCAL lThread as Logical

	If lBreak
		killapp(.T.)
	EndIf

	Private oZ02SEQ 	:= Nil
    Private oZ0YQry 	:= Nil
    Private oZ0YQry1 	:= Nil
    Private oZ0WQry 	:= Nil
    Private oZ0WSel 	:= Nil
	Private aParRet 	:= {}

    MontaQuery()

	cGlbName  := "cThrWrk"+cValToChar(ThreadId())
	A330LckGlb(cGlbName)
	PutGlbValue(cGlbName,"1")
	A330ULckGlb(cGlbName)
	
	ConOut("Executando U_PrcBatTrt")

	lThread := .T.
	ConOut("Thread executando: " + cValToChar(ThreadId()) + " Data atual " + cValToChar(date()) + " " + cValToChar(time()) + " " + ProcName() + " -> " + cRunOnce)
	
	conout("Recno: " + cValToChar(nRecno))

	If Type("__DATA") == "U"
		Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsdDataBase, dDataBase)
	EndIf
	If Type("cFile") == "U"
		Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
	EndIf

	aParRet := {}
	AAdd(aParRet, __DATA)
	
	If (Len(aParRet) == 1)
		AAdd(aParRet, "")
		AAdd(aParRet, "")
	EndIf

	DBSelectArea("Z0X")
	Z0X->(DBSetOrder(1))

	Z0X->(DbGoTo(nRecno))
	
	aParRet[2] := Z0X->Z0X_CODIGO
	aParRet[3] := cRota

	FWMsgRun(, {|| U_PrcBatTrt()}, "Processando", "Processando os dados [" + Z0X->Z0X_CODIGO + "]")
	
	Z0X->( DBCloseArea() )

	if oZ0WSel != nil 
		
		oZ0WQry:Destroy()
		oZ0WQry := nil

		oZ0WSel:Destroy()
		oZ0WSel := nil

		oZ0YQry1:Destroy()
		oZ0YQry1 := nil

		oZ0YQry:Destroy()
		oZ0YQry := nil

		oZ02SEQ:Destroy()
		oZ02SEQ := nil
	endif

	ConOut("Finalizou U_PrcBatTrt")

	A330LckGlb(cGlbName)
    PutGlbValue(cGlbName,"0")
	A330ULckGlb(cGlbName)


Return .T.
