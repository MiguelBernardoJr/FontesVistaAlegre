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
	Local nCC    		:= aScan( aHeader, { |x| AllTrim(x[2])=="D3_CC"} )
	Local nClVl 		:= aScan( aHeader, { |x| AllTrim(x[2])=="D3_CLVL"} )

	if cTM $ GetMV("MV_M241TM",,"512|519")
		For nI := 1 to Len(aCols)
			IF SB1->(DBSEEK( FwxFilial("SB1")+aCols[nI][nD3COD]))
				if  !(AllTrim(SB1->B1_GRUPO) $ GETMV("MV_GRPBLQ"))
					IF !EMPTY(SB1->B1_X_DEBIT)
						IF CT1->(DBSEEK( FwxFilial("CT1")+SB1->B1_X_DEBIT))
							IF CT1->CT1_CCOBRG == '1' .AND. EMPTY( IIF( IsInCallStack("MNTA670") .or. IsInCallStack("MNTA650"),;
																		TQN->TQN_CCUSTO,;
																		IIF(IsInCallStack("MATA241"),cCC, IIF(nCC > 0,ALLTRIM(aCols[nI][nCC]),"") )) )
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

					IF lRet 
						SBM->(DBSEEK( FwxFilial("SBM")+SB1->B1_GRUPO))
						
						cMsgPrd := ""
						cMsgGrp := ""

						if Alltrim(SB1->B1_CONTA) != Alltrim(SBM->BM_X_CONTA)
							cMsgPrd := 'Cta Contábil:'   + Alltrim(SB1->B1_CONTA) + CRLF
							cMsgGrp := 'Cta Contábil:'   + Alltrim(SBM->BM_X_CONTA)  +CRLF
						endif 
						if Alltrim(SB1->B1_X_DEBIT) != Alltrim(SBM->BM_X_DEBIT)
							cMsgPrd := 'Cta Deb Cons:'     + Alltrim(SB1->B1_X_DEBIT)  +CRLF
							cMsgGrp := 'Cta Deb Cons:'     + Alltrim(SBM->BM_X_DEBIT)  +CRLF
						endif 
						if Alltrim(SB1->B1_X_CRED)  != Alltrim(SBM->BM_X_CCREV)
							cMsgPrd := 'Conta Cred:'      + Alltrim(SB1->B1_X_CRED)   +CRLF
							cMsgGrp := 'Conta Cred:'      + Alltrim(SBM->BM_X_CCREV)   +CRLF
						endif 
						if Alltrim(SB1->B1_X_CUSTO)  != Alltrim(SBM->BM_X_CCUS)
							cMsgPrd := 'Cta Custo:'   + Alltrim(SB1->B1_X_CUSTO)
							cMsgGrp := 'Cta Custo:'   + Alltrim(SBM->BM_X_CCUS)
						endif

						if cMsgPrd != ""
							lRet := .F.

							MsgAlert('Produto: ' + AllTrim(SB1->B1_COD) + '- ' + AllTrim(SB1->B1_DESC) +CRLF +;
									CRLF +;
									CRLF +;
									'Cadastro de Produtos:' +CRLF +;
									'-----------------------------------------------' +CRLF +;
									cMsgPrd +;
									CRLF +;
									CRLF +;
									'Cadastro de Grupos:' +CRLF +;
									'-----------------------------------------------' +CRLF +;
									cMsgGrp+;
									CRLF +;
									CRLF +;
									"CORRIGIR CADASTRO DE PRODUTO OU GRUPO ANTES DE PROSSEGUIR";
									,"Campos divergentes Produto x Grupo")
						endif

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
			
			if Posicione("SB1", 1, xFilial("SB1")+GdFieldGet("D3_COD", nI), "B1_RASTRO")=="L" .and. Empty( GdFieldGet("D3_LOTECTL", nI) )
				_cMsg += iIf(Empty(_cMsg),"",CRLF) + "Campo LOTE nao informado na linha: " + cValToChar(nI)
			EndIf
		Next nI

		If !Empty( _cMsg )
			Aviso("Aviso", "Campos obrigatórios nao preenchidos: " + CRLF + _cMsg + CRLF + "Esta operacao será cancelada.", {"Sair"} )
			lRet := .F.
		EndIf
	endif 

	RestArea(aArea)
Return lRet


