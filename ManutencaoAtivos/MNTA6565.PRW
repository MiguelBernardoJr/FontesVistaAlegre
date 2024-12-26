#Include "Protheus.ch"
#include "Tbiconn.ch"
#include "TopConn.ch"

/*/{Protheus.doc} User Function MNTA6565
	Validação da Linha do Acols (linhOk) ou na confirmação final (TudoOk)
	@type  Function
	@author Manoel Filho
	@since 21/02/2022
	@param1	nPar  , Númerico, 1 - LinhaOK / 2 - TudoOK
	@param7	nLinha
	@return lRet 
/*/
User Function MNTA6565()
local nPar := ParamIxb[1]
local nLinha := ParamIxb[7]
local nCntFor := 0
local lRet := .t.
local cQuery := ""
local nPOSNRABAS:= 0

If nLanca == "Produto"

	nPOSTTABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_VTTABA"})
	nPOSVUABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_VUNABA"})

Else

	nPOSTTABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_VTTABA"})
	nPOSVUABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_VUNABA"})

Endif


If nLanca == "Produto"

	If nPar == 2 .and. ProcName(1) == "MNTA656INC" .and. ALTERA
		nPOSTITABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_TITABA"})
		For nCntFor := 1 to Len(aCols)
			If aCols[nCntFor,Len(aHeader)] .and. !Empty(aCols[nCntFor,nPOSTITABA])
				MsgInfo("Não é permitida a exclusão de registros de abastecimento que estiverem com o campo TL_TITABA preenchido. Linha: "+Strzero(nCntFor,2),"Atenção")
				lRet := .f.
			Endif
		Next
	Endif

	If lRet
		// Verifica se é de terceiro
		If Select("TMPST9") > 0
			TMPST9->(dbCloseArea())
		EndIf

		cQuery := "SELECT T9_PROPRIE "
		cQuery += " FROM "+RetSqlName("ST9")+" ST9 "
		cQuery += " WHERE ST9.T9_FILIAL='"+xFilial("ST9")+"' AND ST9.T9_CODBEM = '"+aCols[nLinha][nPOSFROTA]+"'"
		cQuery += "  AND ST9.D_E_L_E_T_ = ' '"
		cQuery += "  AND ST9.T9_CODBEM LIKE 'TERCEIRO%'"
		DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPST9", .f., .f.)

		If !TMPST9->(Eof()) // é veículo de Terceiro

			If TMPST9->T9_PROPRIE <> '2' 
				MsgInfo("Este veículo está cadastrado com nome TERCEIRO, porém o Proprietário está como Próprio! Favor corrigir o cadastro do veículo!","Atenção")
				lRet := .f.
			Endif

			If lRet 

				// Busca preço vigente do combustivel
				If Select("TMPZAT") > 0
					TMPZAT->(dbCloseArea())
				EndIf

				cQuery := "SELECT ZAT_VALCOM "
				cQuery += " FROM "+RetSqlName("ZAT")+" ZAT "
				cQuery += " WHERE ZAT.ZAT_FILIAL='"+xFilial("ZAT")+"' AND ZAT.ZAT_CODCOM = '007'"
				cQuery += " AND ZAT.ZAT_DATCAD <= '"+Dtos(aCols[nLinha][nPOSDATAB])+"' AND ZAT.D_E_L_E_T_ = ' '"
				DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPZAT", .f., .f.)

				If TMPZAT->(Eof())
					If MsgYesNo("Não existe Preço do Arla cadastrado para esta data informmada na linha  "+StrZero(nLinha,2) +".  Deseja Continuar?", "Atenção")
						aCols[nlinha][nPOSVUABA] := 0
						aCols[nlinha][nPOSTTABA] := 0
						lRet := .t.
					Else
						lRet := .f.
					Endif
				Endif
				TMPZAT->(dbCloseArea())

				If lRet 

					nPOSNRABAS := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_NRABAS"})

					If 	Empty(aCols[nLinha][nPOSNRABAS])
						
						MsgInfo("Favor Informar o campo TL_NRABAS na grid de Abastecimento! Linha: "+StrZero(nLinha,2),"Atenção")
						lRet := .f.

					Endif

					nPOSCOBABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_COBABA"})

					If 	lRet .and. Empty(aCols[nLinha][nPOSCOBABA])
						
						MsgInfo("Favor Informar o campo TL_COBABA na grid de Abastecimento! Linha: "+StrZero(nLinha,2),"Atenção")
						lRet := .f.

					Endif

				Endif
				
			Endif

		EndIf

	EndIf

Else // nLanca == "Abastecimento"

	If nPar == 2 .and. ProcName(1) == "MNTA656INC" .and. ALTERA
		nPOSTITABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_TITABA"})
		For nCntFor := 1 to Len(aCols)
			If aCols[nCntFor,Len(aHeader)] .and. !Empty(aCols[nCntFor,nPOSTITABA])
				MsgInfo("Não é permitida a exclusão de registros de abastecimento que estiverem com o campo TQN_TITABA preenchido. Linha: "+Strzero(nCntFor,2),"Atenção")
				lRet := .f.
			Endif
		Next
	Endif

	If lRet
		// Verifica se é de terceiro
		If Select("TMPST9") > 0
			TMPST9->(dbCloseArea())
		EndIf

		cQuery := "SELECT T9_PROPRIE "
		cQuery += " FROM "+RetSqlName("ST9")+" ST9 "
		cQuery += " WHERE ST9.T9_FILIAL='"+xFilial("ST9")+"' AND ST9.T9_CODBEM = '"+aCols[nLinha][nPOSFROTA]+"'"
		cQuery += "  AND ST9.D_E_L_E_T_ = ' '"
		cQuery += "  AND ST9.T9_CODBEM LIKE 'TERCEIRO%'"
		DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPST9", .f., .f.)

		If !TMPST9->(Eof()) // é veículo de Terceiro

			If TMPST9->T9_PROPRIE <> '2' 
				MsgInfo("Este veículo está cadastrado com nome TERCEIRO, porém o Proprietário está como Próprio! Favor corrigir o cadastro do veículo!","Atenção")
				lRet := .f.
			Endif

			If lRet 

				// Busca preço vigente do combustivel
				If Select("TMPZAT") > 0
					TMPZAT->(dbCloseArea())
				EndIf

				cQuery := "SELECT ZAT_VALCOM "
				cQuery += " FROM "+RetSqlName("ZAT")+" ZAT "
				cQuery += " WHERE ZAT.ZAT_FILIAL='"+xFilial("ZAT")+"' AND ZAT.ZAT_CODCOM = '"+cCODCOM+"'"
				cQuery += " AND ZAT.ZAT_DATCAD <= '"+Dtos(aCols[nLinha][nPOSDATAB])+"' AND ZAT.D_E_L_E_T_ = ' '"
				DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPZAT", .f., .f.)

				If TMPZAT->(Eof())
					If MsgYesNo("Não existe Preço de Combustível cadastrado para esta data informmada na linha  "+StrZero(nLinha,2) +".  Deseja Continuar?", "Atenção")
						aCols[nlinha][nPOSVUABA] := 0
						aCols[nlinha][nPOSTTABA] := 0
						lRet := .t.
					Else
						lRet := .f.
					Endif
				Endif
				TMPZAT->(dbCloseArea())

				If lRet 

					nPOSNRABAS := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_NRABAS"})

					If 	Empty(aCols[nLinha][nPOSNRABAS])
						
						MsgInfo("Favor Informar o campo TQN_NRABAS na grid de Abastecimento! Linha: "+StrZero(nLinha,2),"Atenção")
						lRet := .f.

					Endif

					nPOSCOBABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_COBABA"})

					If 	lRet .and. Empty(aCols[nLinha][nPOSCOBABA])
						
						MsgInfo("Favor Informar o campo TQN_COBABA na grid de Abastecimento! Linha: "+StrZero(nLinha,2),"Atenção")
						lRet := .f.

					Endif

				Endif
				
			Endif

		EndIf

	EndIf

Endif

Return lRet
