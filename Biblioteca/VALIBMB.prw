#INCLUDE 'PROTHEUS.CH' 

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 01.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Fun��o para buscar um lote disponivel na SB8; 					   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   : 1- Lotes que ja foram utilizados, mas atualmente estao zerados, in-  |
 |                crementa um ap�s o tra�o.                                        |
 |            2- Se todos os lotes tiverem em uso, entao cria novo lote:           |
 |                EX: XXXXX-01.                                                    |
 |---------------------------------------------------------------------------------|
 | Param:     tpRetorno : 1-TABELA; 2=UNICO                                        |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_DispLoteSB8()                                                      |
 '---------------------------------------------------------------------------------*/
User Function DispLoteSB8( tpRetorno, cMovimento, cTipoMov )
Local cLote	     := ""
Local _cQry 	 := ""

Default cTipoMov := ""

/*
	MB : 05.05.2020
		# Limpar reserva na SX5 de lotes que nao possuem mais SALDO na SB8;
*/
_cQry := " UPDATE "+RetSqlName("SX5")+" SET D_E_L_E_T_='*', R_E_C_D_E_L_ = R_E_C_N_O_  " + CRLF
_cQry += " WHERE	R_E_C_N_O_ IN ( " + CRLF
_cQry += " 	SELECT  X5.R_E_C_N_O_ " + CRLF
_cQry += " 	FROM	" + RetSqlName("SX5") + " X5 " + CRLF
_cQry += " 	WHERE	X5_TABELA='Z8' " + CRLF
_cQry += " 		AND EXISTS ( " + CRLF
_cQry += " 			SELECT 1 " + CRLF
_cQry += " 			FROM " + RetSqlName("SB8") + " B8 " + CRLF
_cQry += " 			WHERE B8_LOTECTL=X5_DESCRI " + CRLF
_cQry += " 			  AND B8.D_E_L_E_T_=' ' " + CRLF
_cQry += " 			HAVING SUM(B8_SALDO)=0 " + CRLF
_cQry += " 		) " + CRLF
_cQry += " 		AND D_E_L_E_T_=' ' " + CRLF
_cQry += " -- 	ORDER BY CAST(REPLACE(SUBSTRING(X5_DESCRI, 1, CHARINDEX('-',X5_DESCRI)),'-','') AS INT) " + CRLF
_cQry += " ) " + CRLF

MemoWrite("C:\totvs_relatorios\DispLoteSB8-DeleteSX5.sql" , _cQry)

if (TCSqlExec(_cQry) < 0)
	Alert("TCSQLError(): " + TCSQLError())
EndIf

_cQry := " WITH"+CRLF
_cQry += " PRINCIPAL AS ("+CRLF
_cQry += " 	SELECT	  B8_LOTECTL"+CRLF
_cQry += " 			, CAST(REPLACE(SUBSTRING(B8_LOTECTL, 1, CHARINDEX('-',B8_LOTECTL)),'-','') AS INT) PRINCIPAL"+CRLF
_cQry += " 			, SUBSTRING(B8_LOTECTL, CHARINDEX('-',B8_LOTECTL)+1, LEN(B8_LOTECTL)) SECUNDARIO"+CRLF
_cQry += " 			, SUM(B8_SALDO) SALDO"+CRLF
_cQry += " 	FROM	" + RetSqlName("SB8") + ""+CRLF
_cQry += " 	WHERE	--B8_FILIAL='"+FwxFilial("SB8")+"'"+CRLF
_cQry += " 		    B8_LOTECTL NOT LIKE 'AUTO%'"+CRLF
_cQry += " 		AND B8_LOTECTL NOT LIKE 'SOBRA%'"+CRLF
_cQry += " 		AND B8_LOTECTL NOT LIKE '5000%'"+CRLF
_cQry += " 		AND B8_LOTECTL NOT LIKE '%.%'"+CRLF
_cQry += " 		AND B8_LOTECTL NOT LIKE '%,%'"+CRLF
_cQry += " 		AND REPLACE(SUBSTRING(B8_LOTECTL, 1, CHARINDEX('-',B8_LOTECTL)),'-','') <> ''"+CRLF
_cQry += " 		AND D_E_L_E_T_=' '"+CRLF
_cQry += " 	GROUP BY B8_LOTECTL"+CRLF
_cQry += " )"+CRLF
_cQry += CRLF
_cQry += " , ZERO AS ("+CRLF
_cQry += " 	SELECT   PRINCIPAL ZERO--, SUM(SALDO) SALDO"+CRLF
_cQry += " 	FROM	 PRINCIPAL P"+CRLF
_cQry += "  WHERE	 NOT EXISTS ("+CRLF
_cQry += "  		-- REGRAS DE SX5 - CONFIRM SX8"+CRLF
_cQry += "  		SELECT 1"+CRLF
_cQry += "  		FROM " + RetSqlName("SX5") + " X"+CRLF
_cQry += "  		WHERE	X5_FILIAL=' '"+CRLF
_cQry += "  			AND X5_TABELA='Z8'"+CRLF
_cQry += "  			AND P.PRINCIPAL=CAST(X5_CHAVE AS INT)"+CRLF
_cQry += "  			and X.D_E_L_E_T_=' '"+CRLF
_cQry += "  	)"+CRLF
_cQry += " 		-- AND PRINCIPAL NOT IN (4,52,57)"+CRLF
_cQry += CRLF

If cTipoMov == "2"
	_cQry += " 		AND PRINCIPAL <= 300"+CRLF
ELseIf cTipoMov == "1"
	_cQry += " 		AND PRINCIPAL > 300"+CRLF
EndIf

_cQry += CRLF
_cQry += " 	GROUP BY PRINCIPAL"+CRLF
_cQry += " 	HAVING SUM(SALDO)=0"+CRLF
_cQry += " 	-- ORDER BY PRINCIPAL"+CRLF
_cQry += " )"+CRLF
_cQry += CRLF
_cQry += " , TEM AS ("+CRLF
_cQry += " 	SELECT   PRINCIPAL TEM --, SUM(SALDO) SALDO"+CRLF
_cQry += " 	FROM	 PRINCIPAL"+CRLF
_cQry += " 	GROUP BY PRINCIPAL"+CRLF
_cQry += " 	HAVING SUM(SALDO)>0"+CRLF
_cQry += " 	-- ORDER BY PRINCIPAL"+CRLF
_cQry += " )"+CRLF
_cQry += CRLF
_cQry += " , UTILIZAR AS ("+CRLF

_cQry += " 	SELECT "+CRLF

If tpRetorno=="UNICO"
	_cQry += " 		MIN(ZERO) UTILIZAR"+CRLF
ElseIf tpRetorno=="TABELA"
	_cQry += " 		ZERO UTILIZAR"+CRLF
EndIf

_cQry += " 	FROM ZERO A"+CRLF
_cQry += " 	WHERE  NOT EXISTS ("+CRLF
_cQry += " 				SELECT 1"+CRLF
_cQry += " 				FROM TEM B"+CRLF
_cQry += " 				WHERE	ZERO=TEM"+CRLF
_cQry += " 			)"+CRLF
_cQry += " 	-- ORDER BY ZERO"+CRLF
_cQry += " )"+CRLF
_cQry += CRLF
_cQry += " , DISPONIVEL AS ("+CRLF
_cQry += " 	SELECT CONVERT(VARCHAR,PRINCIPAL) + '-' + CONVERT(VARCHAR,MAX(CAST(SECUNDARIO AS INT))+1) LOTE_DISPONIVEL"+CRLF
_cQry += " 	FROM PRINCIPAL A"+CRLF
_cQry += " 	JOIN UTILIZAR  B ON PRINCIPAL=UTILIZAR"+CRLF
_cQry += " 	GROUP BY PRINCIPAL"+CRLF
_cQry += " )"+CRLF
_cQry += CRLF
_cQry += " , NAO_ENCONTROU AS ("+CRLF
_cQry += " 	SELECT CONVERT(VARCHAR,MAX(TEM)+1)+'-1' NOVO_LOTE"+CRLF
_cQry += " 	FROM ("+CRLF
_cQry += " 		SELECT ZERO TEM FROM ZERO"+CRLF
_cQry += " 		UNION"+CRLF
_cQry += " 		SELECT TEM FROM TEM"+CRLF
_cQry += " 	) TEM"+CRLF
_cQry += " )"+CRLF
_cQry += CRLF
_cQry += " SELECT LOTE, ORDEM"+CRLF
_cQry += " FROM ("+CRLF
_cQry += "  SELECT LOTE_DISPONIVEL LOTE, 1 ORDEM FROM DISPONIVEL"+CRLF
_cQry += "  UNION"+CRLF
_cQry += "  SELECT NOVO_LOTE, 2 FROM NAO_ENCONTROU"+CRLF
_cQry += " ) FINAL"+CRLF
_cQry += " ORDER BY 2, CAST(REPLACE(SUBSTRING(LOTE, 1, CHARINDEX('-',LOTE)),'-','') AS INT)"

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite("C:\totvs_relatorios\SQL_newLote.sql" , _cQry)
EndIf

/* 
MJ : 15.01.2020
tiramos o lock pois estava travando a rotina
quando chegar o servidor, vamos voltar, acho que � problema com a lentidao que esta travando o sistema
 */
// While !LockByName("SB8_DispLote", .t., .t.)
// 	Alert('Rotina em uso por outro usu�rio. Favor aguarde ...')
//  	Sleep(3000)
// EndDo

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.) 
	
	if tpRetorno=="TABELA"
		
		cLote := ShowTabSB8Disp()
		
	ElseIf tpRetorno=="UNICO"
		If !TEMPSQL->(Eof())
			cLote := TEMPSQL->LOTE
		EndIf
	EndIf
	
	if !Empty( cLote )
		RecLock('SX5', .T.)
			SX5->X5_FILIAL 	:= ' '
			SX5->X5_TABELA 	:= 'Z8'
			SX5->X5_CHAVE  	:= SubS(cLote, 1, At("-", cLote)-1)
			SX5->X5_DESCRI 	:= Alltrim(cLote)
			SX5->X5_DESCSPA	:= cMovimento
			SX5->X5_DESCENG	:= dToS(dDataBase)
		SX5->(MsUnLock())
	EndIf
	
	TEMPSQL->(DbCloseArea())

// UnlockByName("SB8_DispLote")

Return cLote
// U_DispLoteSB8()


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 08.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Esta fun��o ira mostrar uma tabela com lotes disponiveis na SB8,     |
 |              de acordo com o sql da funcao anterior;                            |
 |            As funcoes estao assim implementadas pois foi pedido esse lance da   |
 |              depois que a funcao de retorno unico estava desenvolvido.          |
 |            Ricardinho sugeriu o modelo tabela e o Hugo concordou.               |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
Static Function ShowTabSB8Disp()
Local oDlgSB8 := nil
Local nGDOpc  := 0 // GD_INSERT + GD_UPDATE + GD_DELETE
Local oDados  := nil
Local aHeader := {}, aCols   := {}
Local cLote   := ""

DEFINE MSDIALOG oDlgSB8 TITLE OemToAnsi("Lotes Disponiveis para uso") ;
			From 0,0 to 300,150 PIXEL // STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |

aHeader := {}
aCols   := {}
       // AAdd(aGZBCHead, { " ", Padr("ZBC_MARK", 10), "@BMP", 1, 0, .F., "", "C", "", "V", "", "", "", "V", "", "", "" } )	
/*01*/ aAdd(aHeader,{ "Lote", "LOTE", PesqPict("SB8", "B8_LOTECTL"), TamSX3("B8_LOTECTL")[1], TamSX3("B8_LOTECTL")[2],"AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})

// Carregar Vetor
aCols := {}
while !TEMPSQL->(Eof())
	aAdd(aCols, array(Len(aHeader)+1))   
	
	aCols[Len(aCols), 			   1] := TEMPSQL->LOTE
	aCols[len(aCols), Len(aHeader)+1] := .F.
	
	TEMPSQL->(DbSkip())
EndDo

oDados := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , /* "+ZBC_ITEM" */ , , , , , , /* "u_ZBCDelOk(o1ZBCGDad)" */, ;
				oDlgSB8, aClone(aHeader), aClone( aCols ) )
oDados:oBrowse:Align 	  := CONTROL_ALIGN_ALLCLIENT
oDados:oBrowse:BlDblClick := { || cLote:=oDados:aCols[ oDados:oBrowse:nAt, 01 ], oDlgSB8:End() }

ACTIVATE MSDIALOG oDlgSB8 CENTER

// If nOpcA == 1
// 
// EndIf

Return cLote


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 01.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Fun��o para buscar um lote disponivel na SB8; 					   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   : 1- Liberar lote da SX5 = tabela Z8; Quando o processo nao chega ao   |
 |                final.                                                           |
 |            2- Se o processo for completo, ou seja for criado SB8, nao se faz    |
 |                obrigatorio deletar na SX5.                                      |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_DelLoteSB8( cLote )                                                |
 '---------------------------------------------------------------------------------*/
User Function DelLoteSB8(cMovimento) // cLote)

Local aArea 	:= GetArea()
Local _cQry		:= "" 

If Empty( cMovimento )
	Return nil
EndIf

/* tirei no dia 08.07.2020 -> estava travando durante os testes.*/
// While !LockByName("DelLoteSB8"+AllTrim(cMovimento), .t., .t.)
// 	Sleep(1000)
// EndDo

	// _cQry := "DELETE FROM " + RetSqlName("SX5") +;
	//          " WHERE X5_FILIAL=' '" +;
	// 		 "	 AND X5_TABELA='Z8'" +;
	//          "   AND rTrim(X5_DESCRI) = '"+AllTrim(cLote)+"'"
	_cQry := " DELETE "+CRLF+;
			 " 	FROM "+RetSqlName("SX5")+""+CRLF+;
			 " WHERE X5_DESCRI IN ("+CRLF+;
			 " 		SELECT	X5_DESCRI"+CRLF+;
			 " 		FROM	"+RetSqlName("SX5")+" A"+CRLF+;
			 " 		WHERE	X5_FILIAL=' '"+CRLF+;
			 " 			AND X5_TABELA='Z8'"+CRLF+;
			 " 			AND X5_DESCSPA='"+cMovimento+"'"+CRLF+;
			 " 			AND NOT EXISTS ("+CRLF+;
			 " 				SELECT	1"+CRLF+;
			 " 				FROM	"+RetSqlName("ZV2")+" B"+CRLF+;
			 " 				WHERE	ZV2_FILIAL<>' '"+CRLF+;
			 " 					AND ZV2_MOVTO='"+cMovimento+"'"+CRLF+;
			 " 					AND ZV2_LOTE=X5_DESCRI"+CRLF+;
			 " 					AND B.D_E_L_E_T_=' '"+CRLF+;
			 " 			)"+CRLF+;
			 " 			AND NOT EXISTS ("+CRLF+;
			 " 				SELECT	1"+CRLF+;
			 " 				FROM	"+RetSqlName("SB8")+" C"+CRLF+;
			 " 				WHERE	B8_FILIAL<>' '"+CRLF+;
			 " 					AND B8_LOTECTL=X5_DESCRI"+CRLF+;
			 " 					AND C.D_E_L_E_T_=' '"+CRLF+;
			 " 			)"+CRLF+;
			 " 			AND NOT EXISTS ("+CRLF+;
			 " 				SELECT	1"+CRLF+;
			 " 				FROM	"+RetSqlName("Z0E")+" D"+CRLF+;
			 " 				WHERE	Z0E_FILIAL<>' '"+CRLF+;
			 " 					AND Z0E_CODIGO='"+cMovimento+"'"+CRLF+;
			 " 					AND Z0E_LOTE=X5_DESCRI"+CRLF+;
			 " 					AND D.D_E_L_E_T_=' '"+CRLF+;
			 " 			)"+CRLF+;
			 " 			AND D_E_L_E_T_=' '"+CRLF+;
			 " )"

	// Alert(_cQry)
	MemoWrite( GetTempPath()+"\SB8DelLote.SQL", _cQry )

	if (TCSqlExec(_cQry) < 0)
		Alert("TCSQLError(): " + TCSQLError())
	EndIf

// UnlockByName( "DelLoteSB8"+AllTrim(cMovimento) )

RestArea(aArea)

Return nil


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 05.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Validar caracteres no texto do lote. Ser�o permitidos o tra�o "-"	   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function libVldLote( cLote, lExiste/* , cTpMov  */)
Local lOk       := .T.
Local nI        := 0
Local oModel:=NIL
Default lExiste := .F.

	If Empty(cLote)
		If ReadVar() == "M->Z0E_LOTE"
			FWFldPut("Z0E_LOTE", Space(TamSX3('B8_LOTECTL')[1]) )
		ElseIf ReadVar() == "M->ZV2_LOTE"
			// FWFldPut("ZV2_LOTE", cLote )
			&(ReadVar()) := Space(TamSX3('B8_LOTECTL')[1])
		ElseIf IsInCallStack( 'SELECAO' )
			oGetDadRan:aCols[ oGetDadRan:nAt, 4/*LOTE*/] := Space(TamSX3('B8_LOTECTL')[1])
		EndIf
	Else
		For nI := 1 to Len( cLote )
			cByte := Upper(Subs( cLote, nI, 1))
			If !(Asc(cByte) >= 48 .And. Asc(cByte) <= 57) // .Or. ;	// 0 a 9
				// (Asc(cByte) >= 65 .And. Asc(cByte) <= 90) .Or. ;	// A a Z
				If cByte <> "-"
					Alert('Caracter nao permitido: ' + cByte + ' na posi��o: ' + cValToChar(nI) )
					//If !(ReadVar() == "M->Z0E_LOTE")
						lOk :=  .F.
					//EndIf	
					// cLote := ""
					exit
				EndIf
			EndIf
		Next nI
		
		// Retirar 0 a Esquerda; Valida��o solicitado pelo Ricardo Santana;
		If lOk
			If lExiste

				BeginSQL alias "qTMP"
					%noParser%
					SELECT B8_LOTECTL, SUM(B8_SALDO) SALDO
					FROM  %table:SB8%
					WHERE B8_LOTECTL=%exp:cLote%
					  AND %notDel%
					GROUP BY B8_LOTECTL
				EndSQL
				If !qTMP->(Eof()) .and. qTMP->SALDO==0 
					// if cTpMov $ ('2,5') // APART��O/RECEBIMENTO
					// Elseif cTpMov $ ('3,4')
					msgInfo("O Lote selecionado ( "+cLote+" ) est� com SALDO ZERADO, atente-se para que a DATA DE INICIO e o PESO DO LOTE sejam mantidos.  .",;
							"ATEN��O")
					
					//lOK := .F.
				EndIf
				qTMP->(dbCloseArea())
			EndIf

			If lOk .and. !Empty(ReadVar())
				While SubS(cLote, 1, 1) == "0"
					cLote := SubS(cLote, 2)	
				EndDo
				
				If ReadVar() == "M->Z0E_LOTE"
					FWFldPut("Z0E_LOTE", cLote )
				ElseIf ReadVar() == "M->ZV2_LOTE"
					// FWFldPut("ZV2_LOTE", cLote )
					&(ReadVar()) := cLote
				ElseIf IsInCallStack( 'SELECAO' )
					oGetDadRan:aCols[ oGetDadRan:nAt, 4/*LOTE*/] := cLote
				ElseIf IsInCallStack( 'NEWLOTES' )
					oModel    := FWModelActive()
					oModel:GetModel( 'Z0EDETAIL' ):SetValue("Z0E_LOTE", cLote)
				Else
					GdFieldPut( cLote )
				EndIf
			EndIf
		EndIf
	/*
	/*
		If lOk := IsAlpha( cLote )
			Alert('Caracter')
			Return nil
		EndIf  
	*/
	endIf
Return lOK // cLote
