#Include "Totvs.ch"

#IFNDEF _ENTER_
	#DEFINE _ENTER_ (Chr(13)+Chr(10))
	// Alert("miguel")
#ENDIF

Static cSEMAFORO := "MYIPC1" 
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
    Local lRet          := .F.

	If Type("__DATA") == "U"
		Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsdDataBase, dDataBase)
	EndIf
	If Type("cFile") == "U"
		Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
	EndIf
    
    Private oZ02SEQ 	:= Nil
    Private oZ0YQry 	:= Nil
    Private oZ0YQry1 	:= Nil
    Private oZ0WQry 	:= Nil
    Private oZ0WSel 	:= Nil

    MontaQuery()

    //__DATA := cToD("22/04/2025")
    //dDataBase := __DATA

	_cQry := " WITH DADOS AS ( " + CRLF
   	_cQry += " select TOP 1 Z0Y_CODEI, Z0X.R_E_C_N_O_ RECNO, Z0X_OPERAC OPERACAO " + CRLF 
   	//_cQry += " select Z0Y_CODEI, Z0X.R_E_C_N_O_ RECNO, Z0X_OPERAC OPERACAO " + CRLF 
   	_cQry += "   FROM "+RetSqlName("Z0Y")+" Z0Y " + CRLF 
	_cQry += " 	 JOIN "+RetSqlName("Z0X")+" Z0X ON Z0X_FILIAL = Z0Y_FILIAL AND Z0X_CODIGO = Z0Y_CODEI AND Z0X_DATA = Z0Y_DATA AND Z0X.D_E_L_E_T_ =' ' --AND Z0X_OPERAC <> '1' " + CRLF 
	_cQry += " 	 WHERE ( Z0Y_QTDREA > 0 OR Z0Y_PESDIG > 0)  " + CRLF 
	_cQry += " 	   AND Z0Y_DATPRC = ' '  " + CRLF 
	_cQry += " 	   AND Z0Y_CONFER = 'T' " + CRLF 
	_cQry += " 	   AND Z0Y_DATA = '" +DTOS(__DATA)+ "' " + CRLF 
	_cQry += " 	   AND Z0Y.D_E_L_E_T_ =' '  " + CRLF
	_cQry += " 	UNION  " + CRLF
	_cQry += " select TOP(1) Z0Y_CODEI, Z0X.R_E_C_N_O_ RECNO, Z0X_OPERAC OPERACAO " + CRLF 
   	_cQry += "   FROM "+RetSqlName("Z0Y")+" Z0Y " + CRLF 
	_cQry += " 	 JOIN "+RetSqlName("Z0X")+" Z0X ON Z0X_FILIAL = Z0Y_FILIAL AND Z0X_CODIGO = Z0Y_CODEI AND Z0X_DATA = Z0Y_DATA AND Z0X.D_E_L_E_T_ =' ' --AND Z0X_OPERAC = '1' " + CRLF 
	_cQry += " 	 WHERE ( Z0Y_QTDREA > 0 OR Z0Y_PESDIG > 0)  " + CRLF 
	_cQry += " 	   AND Z0Y_DATPRC = ' '  " + CRLF
	_cQry += " 	   AND Z0Y_CONFER = 'T' " + CRLF
	_cQry += " 	   AND Z0Y_DATA = '" +DTOS(__DATA)+ "' " + CRLF 
	_cQry += " 	   AND Z0Y.D_E_L_E_T_ =' '  " + CRLF 
	_cQry += " 	UNION  " + CRLF 
   	_cQry += " select TOP(1) Z0W_CODEI, Z0X.R_E_C_N_O_ RECNO, Z0X_OPERAC OPERACAO " + CRLF 
   	_cQry += "   FROM "+RetSqlName("Z0W")+" Z0W " + CRLF 
	_cQry += " 	 JOIN "+RetSqlName("Z0X")+" Z0X ON Z0X_FILIAL = Z0W_FILIAL AND Z0X_CODIGO = Z0W_CODEI AND Z0X_DATA = Z0W_DATA AND Z0X.D_E_L_E_T_ =' '  --AND Z0X_OPERAC = '1'" + CRLF 
	_cQry += " 	 WHERE ( Z0W_QTDREA > 0 OR Z0W_PESDIG > 0)  " + CRLF 
	_cQry += " 	   AND Z0W_DATPRC = ' '  " + CRLF 
	_cQry += " 	   AND Z0W_CONFER = 'T' " + CRLF 
	_cQry += " 	   AND Z0W_DATA = '" +DTOS(__DATA)+ "'" + CRLF 
	_cQry += " 	   AND Z0W.D_E_L_E_T_ =' '  " + CRLF 
	_cQry += " 	   ) " + CRLF 
	_cQry += " 	   SELECT DISTINCT RECNO, OPERACAO FROM DADOS ORDER BY OPERACAO DESC " + CRLF
	
	cAlias := MpSysOpenQuery(_cQry)

	MEMOWRITE("C:\TOTVS_RELATORIOS\EXPPRC_" + DTOS(__DATA) + ".sql", _cQry)
	
	aParRet := {}
	AAdd(aParRet, __DATA)
	
	If (Len(aParRet) == 1)
		AAdd(aParRet, "")
	EndIf

	DBSelectArea("Z0X")
	Z0X->(DBSetOrder(1))
	

	While !((cAlias)->(EOF()))
		Z0X->(DbGoTo((cAlias)->RECNO))
		aParRet[2] := Z0X->Z0X_CODIGO
		
		U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
					"[" + AllTrim(Z0X->Z0X_CODIGO) + "]" +_ENTER_+;
					"Função: fPrcLote" + _ENTER_ +;
					"Processando os dados [" + Z0X->Z0X_CODIGO + "]",;
					.T./* lConOut */,;
					/* lAlert */ )
		
        lRet := u_start_oc()
        lRet := u_ConnOne((cAlias)->RECNO)
		//u_connIPC()
		//FWMsgRun(, {|| U_PrcBatTrt() }, "Processando", "Processando os dados [" + Z0X->Z0X_CODIGO + "]" )
		
		(cAlias)->(DBSkip())
	EndDo
	(cAlias)->(DBCloseArea())

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

    RestArea(aArea)

    Final("Thread finalizando: " + cValToChar(ThreadId())  + cValToChar(time()) + " " + ProcName() + " -> " + cSEMAFORO)
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

	oZ0YQry1 := FwExecStatement():New(_cQry)

	_cQry := " SELECT Z0W.Z0W_CURRAL AS CURRAL, Z0W.Z0W_LOTE AS LOTE, SUM(Z0W.Z0W_QTDPRE) AS QTDPRE, SUM(CASE Z0W.Z0W_PESDIG WHEN 0 THEN Z0W.Z0W_QTDREA ELSE Z0W.Z0W_PESDIG END) AS QTDREA, Z0W.Z0W_RECEIT AS DIETA " + _ENTER_
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
	_cQry += "   AND Z0W.Z0W_LOTE IN (SELECT SB8.B8_LOTECTL FROM " + RetSqlName("SB8") + " SB8 WHERE SB8.B8_FILIAL = ? AND SB8.B8_SALDO > 0 AND SB8.D_E_L_E_T_ = ' ' ) "
	_cQry += " GROUP BY Z0W.Z0W_CURRAL, Z0W.Z0W_LOTE, Z0W.Z0W_RECEIT, Z0W.Z0W_ORDEM, Z0W.Z0W_DATA " + _ENTER_
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
/*
 * uso:
 *      Para criar o servico chame: u_start_oc ( sera executado somente a funcao de "connect" uma vez para cada thread minima na ativacao )
 */
 
/*
 * Cria o ManualJob
 */
Function u_start_oc()
    Local cEnv := GetEnvServer()
    
    ConOut("Thread: " + cValToChar(ThreadId()) + " ManualJob: " + cRunOnce)
    ManualJob(cRunOnce, cEnv, "", "", "u_ConnOne", "", "", 1000, 0, 10, 10, 1) 
    
Return .T.
 
/*
 * Funcao que sera chamada uma vez
 */
Function u_ConnOne(nRecno)
    local aArea := FWGetArea()
    
    ConOut("Thread executando: " + cValToChar(ThreadId()) + " Data atual " + cValToChar(date()) + " " + cValToChar(time()) + " " + ProcName() + " -> " + cRunOnce)
    
    conout("Recno: " + cValToChar(nRecno)) 

    DBSelectArea("Z0X")
	Z0X->(DBSetOrder(1))

    Z0X->(DbGoTo(nRecno))

    FWMsgRun(, {|| U_PrcBatTrt()}, "Processando", "Processando os dados [" + Z0X->Z0X_CODIGO + "]")
    
	Z0X->( DBCloseArea() )
    
    FwRestArea(aArea)
Return .T.
