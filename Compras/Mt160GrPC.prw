#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} Mt160GrPC
    Ponto de entrada disponibilizado para gravação de valores e campos específicos do Pedido de Compra (SC7).
    Executado durante a geração do pedido de compra na análise da cotação.
    Gravação da marca utilizada para cotação.
/*/
user function Mt160GrPC()
// local aVencedor := ParamIXB[1]
// local aSC8 := ParamIXB[2]

    SC7->C7_XMARCA := SC8->C8_XMARCA 
	
return nil

/*
	MJ : 10.08.2017
		Grava Item de Solicitacao na tabela de Log
*/
User function MT160OK()
	RecLock("COI",.T.)
		COI->COI_FILIAL := xFilial("COI")
		COI->COI_NUMSC  := SC8->C8_NUMSC
		COI->COI_ITEM   := SC8->C8_ITEM
		COI->COI_DTHSOL := DtoC(Date()) + ' ' + Time()
		COI->COI_USOL   := cUserName
		COI->COI_DOCSC  := SC8->C8_NUM
	COI->(MsUnlock())
Return .T.