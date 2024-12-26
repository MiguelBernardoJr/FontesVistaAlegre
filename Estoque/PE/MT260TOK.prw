#Include "Rwmake.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"

/*
	MJ : 27.12.2017
		# TRANSFERENCIA SIMPLES
			* Pergunta se deseja continuar caso os produtos sejam diferentes
*/
User Function MT260TOK()
// Local aArea 	:= GetArea()
Local lRet		:= .T.

If GetMV('MV_RASTRO') == 'S' .and. SubS(cCodOrig,1,3)=="BOV" .and. SubS(cCodDest,1,3)=="BOV"
	if SB1->B1_RASTRO=="L" .and. cCodOrig<>cCodDest
		lRet := MsgYesNo('O produto: ' + AllTrim(cCodOrig) + ' está sendo transferido para o produto: ' + AllTrim(cCodDest) + CRLF + ;
					     'Deseja continuar ???','Atenção')
	EndIf
EndIf
/* 
MsgInfo("Ponto de entrada: <b> MT260TOK </b> gerado.","Atenção")
	 */
// RestArea(aArea)
Return lRet


// /* ==========================================================================================  */
// User Function A260GRV()
// 	MsgInfo("Ponto de entrada: <b><h1> A260GRV </h1></b> gerado.","Atsenção")
// Return .T.

// /* ==========================================================================================  */
// User Function MA260D3()
// 	MsgInfo("Ponto de entrada: <b> MA260D3 </b> gerado.","Atenção")
// Return .T.