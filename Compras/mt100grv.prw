#include 'protheus.ch'
#include 'parmtype.ch'

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  04.05.2017                                                              |
 | Desc:  PE na confirmação do DOCUMENTO DE ENTRADA;                              |
 |                                                                                |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User function MT100Grv()
local lDeleta 	:= ParamIXB[1]
local lRet 		:= .T.

If lDeleta
	If !(lRet := U_M01VldDel())
		Aviso('AVISO', 'Este Documento de Entrada não pode ser excluído, devido a já ter tido processado sua comissão.', {'Ok'})
	EndIf
EndIf

If lRet
	lRet 		:= U_VACOMM01(lDeleta)
EndIf

/*
04.05.2017
Precisa confirmar com o Toshio e com o Andre, se funcao abaixo ainda esta
em uso;

Pois foi necessario utilizar este ponto de entrada;

if lDeleta
    u_EstVE001()
endif
*/

Return lRet