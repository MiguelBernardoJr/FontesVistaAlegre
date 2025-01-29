#INCLUDE "TOTVS.CH"

/* MB : 23.02.2022
	-> Testando esse ponto de entrada;
		-> Funcao de movimentacao sera descontinuada no dia: 04/04/2022;
			* https://tdn.totvs.com/pages/releaseview.action?pageId=606431987 
*/
User Function MT241TOK()
	Local nI     	:= 1
	Local _cMsg  	:= ""
	Local lRet		:= .T. 
	Local aArea 	:= GetArea()

	Local nD3COD     	:= aScan( aHeader, { |x| AllTrim(x[2])=="D3_COD"} )
	Local nItemCta    	:= aScan( aHeader, { |x| AllTrim(x[2])=="D3_ITEMCTA"} )
	Local nClVl 		:= aScan( aHeader, { |x| AllTrim(x[2])=="D3_CLVL"} )

	if cTM $ GetMV("MV_M241TM",,"512|519")
		For nI := 1 to Len(aCols)
			IF SB1->(DBSEEK( FwxFilial("SB1")+aCols[nI][nD3COD]))
				IF !EMPTY(SB1->B1_X_DEBIT)
					IF CT1->(DBSEEK( FwxFilial("CT1")+SB1->B1_X_DEBIT))
						IF CT1->CT1_CCOBRG == '1' .AND. EMPTY(cCC)
							lRet := .F.
							Alert('OBRIGATÓRIO PREENCHIMENTO DO CAMPO CENTRO DE CUSTOS.')
							exit
						ENDIF

						IF lRet .and. CT1->CT1_ITOBRG == '1' .AND. EMPTY(aCols[nI][nItemCta])
							lRet := .F.
							Alert('OBRIGATÓRIO PREENCHIMENTO DO CAMPO ITEM CONTÁBIL.')
							exit
						ENDIF

						IF lRet .and. CT1->CT1_CLOBRG == '1' .AND. EMPTY(aCols[nI][nClVl])
							lRet := .F. 
							Alert('OBRIGATÓRIO PREENCHIMENTO DO CAMPO CLASSE DE VALOR')
							exit
						ENDIF
					ENDIF
				ENDIF 
			ENDIF
		Next nI
	else
		For nI := 1 to Len( aCols )
			// TM DA MORTE
			If cTM == GetMV("JR_TMMORTE",,"511") .and. Empty( GdFieldGet("D3_X_OBS", nI) )
				_cMsg += iIf(Empty(_cMsg),"",CRLF) + "Campo OBSERVACAO nao informado na linha: " + cValToChar(nI)
			EndIf
			
			/*if Posicione("SB1", 1, xFilial("SB1")+GdFieldGet("D3_COD", nI), "B1_RASTRO")=="L" .and. Empty( GdFieldGet("D3_LOTECTL", nI) )
				_cMsg += iIf(Empty(_cMsg),"",CRLF) + "Campo LOTE nao informado na linha: " + cValToChar(nI)
			EndIf*/
		Next nI

		If !Empty( _cMsg )
			Aviso("Aviso", "Campos obrigatórios nao preenchidos: " + CRLF + _cMsg + CRLF + "Esta operacao será cancelada.", {"Sair"} )
			lRet := .F.
		EndIf
	endif 

	RestArea(aArea)
Return lRet
