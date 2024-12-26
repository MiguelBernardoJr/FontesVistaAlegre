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
/* local nI,nJ 
local cMsg

	if !lDeleta .and. Type("aCBrMT103") <> 'U'
		For nI := 1 to Len(aCBrMT103)
			IF aCBrMT103[nI,3]
				loop
			endif

			For nJ := 1 to Len(aCBrMT103)
				IF nI == nJ 
					loop
				endif
				
				IF aCBrMT103[nJ,3]
					loop 
				endif

				if aCBrMT103[nJ,2] == aCBrMT103[nI,2] 
					cMsg := "Código inserido já está na " 
					cMsg += "linha: " + AllTrim(Str(nI)) + " e " + AllTrim(Str(nJ))
					
					lRet := .F.
					exit
				endif 

			next nJ
			
			if !lRet
				exit 
			endif 
		Next nI

		if !lRet
			MsgStop(cMsg,"Boleto Invalido!")
		else
			
			For nI := 1 to Len(aCBrMT103)
				nValBol := SubStr(aCBrMT103[nI,2],Len(aCBrMT103[nI,2])-9,Len(aCBrMT103[nI,2]))
				nValBol := SubStr(nValBol,1,8) + '.' + SubStr(nValBol,9,2)
				nValBol := Val(nValBol)

				if aCBrMT103[nI,1] <> nValBol
					cMsg := "Código de boleto inválido!" + CRLF
					cMsg += "Valor do boleto não corresponde ao valor do titulo!"+ CRLF
					cMsg += "Valor do boleto: " + cValToChar(nValBol) + CRLF
					cMsg += "Valor do titulo: " + aCBrMT103[nI,2] + CRLF
					
					lRet := .F.
					
					MsgStop(cMsg,"Boleto Invalido!")
					
					exit
				endif

			next nI 

		endif
	endif */

	If /* lRet .and. */ lDeleta
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
