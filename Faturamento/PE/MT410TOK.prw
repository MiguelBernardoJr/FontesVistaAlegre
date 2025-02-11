#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  05.01.2018                                                              |
 | Desc:  Este PE tem como objetivo, validar o preenchimento do campo Lote, caso  |
 |       o produto esteja marcado como tal.                                       |
 | Obs.:  -                                                                       |
'--------------------------------------------------------------------------------*/

User Function MT410TOK()
	Local aArea			:= GetArea()
	Local lRet          := .T.				// Conteudo de retorno
	// Local cMsg         	:= ""				// Mensagem de alerta
	// Local nOpc         	:= PARAMIXB[1]	// Opcao de manutencao
	// Local aRecTiAdt 	:= PARAMIXB[2]	// Array com registros de adiantamentoc
	// Msg := "Entrou no PE(MT410TOK) após acionamento do botão de OK, passando os seguintes parâmetros:"+Chr(10)+Chr(10)+Chr(13)+"nOpc: "+AllTrim(Str(nOpc));
	//              +"    e   aRecTiAdt: "+AllTrim(Str(Len(aRecTiAdt)))+" elementos"
	// Aviso("Teste PE - A410VldTOK",cMsg,{"OK"})
	Local nPos			:= 0
	Local nI			:= 0

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	DbSelectArea("SB8")
	SB8->(DbSetOrder(3))

	For nI := 1 to len(aCols)
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek( xFilial("SB1") + GdFieldGet("C6_PRODUTO", nI) )) .AND.  SB1->B1_RASTRO == "L" .AND. ;
				Posicione('SF4', 1, xFilial('SF4')+GdFieldGet("C6_TES", nI), 'F4_ESTOQUE')=="S"
			If !(lRet := !Empty( GdFieldGet("C6_LOTECTL", nI) ))
				Aviso( "Campo Lote nao informado",;
					"Não foi localizado Endereço do Lote para o produto: " + AllTrim(SB1->B1_COD) + ;
					" informado na linha: " + cValToChar(nI) , {"OK"})
				Exit
			EndIf

			SB8->(DbSetOrder(3))
			If !( lRet := SB8->(DbSeek( xFilial("SB8")+GdFieldGet("C6_PRODUTO", nI)+GdFieldGet("C6_LOCAL", nI)+GdFieldGet("C6_LOTECTL", nI) )) )
				Aviso( "Lote não localizado",;
					"O Lote " + AllTrim(GdFieldGet("C6_LOTECTL", nI)) + " não foi localizado para o produto: " + AllTrim(SB1->B1_COD) + ;
					" informado na linha: " + cValToChar(nI) , {"OK"})
				Exit
			EndIf
		EndIf
	Next nI

	// IsInCallStack("A311TRANSF") // deu erro na transferencia do LEANDRO // ROTINA: "MATA311"
	/* MB: 17.01.2025
	-> PE para bloquear cancelamento */
	If IsInCallStack("A410DEVOK") // VALIDAR SOMENTE QDO FOR DEVOLUCAO NA ROTINA DE PEDIDO DE VENDA
		If (SF1->F1_EMISSAO + GetMV("MB_DIASBLQ",, 5)) < MsDate() .AND. Empty( SF1->F1_XCANCEL )
			// lRet := !MsgYesNo("NF " + SF1->F1_DOC + " com mais de " + cValToChar(GetMV("MV_DIASBLQ",,20)) + " não pode ser Cancelada. Por favor procurar a CAMILA.", "Bloqueio de NF de Entrada")
			MsgStop("NF " + AllTrim(SF1->F1_DOC) + " com entrada no dia: " + dToC(SF1->F1_EMISSAO) + " (" + cValToChar(MsDate()-SF1->F1_EMISSAO) + " dias) não pode ser devolvida.<br/><b>Por favor procurar a CAMILA para autorizar a emissao da NF de devolução.</b>", "Bloqueio de NF de Entrada")
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)
Return lRet //  := MsgYesNo('MT410TOK' + CRLF + 'Deseja continuar ???', 'Atenção' )


// Ponto de entrada na abertura do pedido
/*
User Function M410ALOK()
Return lRet := MsgYesNo('M410ALOK' + CRLF + 'Deseja continuar ???', 'Atenção' )
*/

