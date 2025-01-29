#INCLUDE 'PROTHEUS.CH'

User Function MT103SE2()
	Local aRet:= {}// Customizações desejadas para adição do campo no grid de informações

	aAdd(aRet,{;
				AllTrim(GetSx3Cache("E2_LINDIG","X3_TITULO")),;
				"E2_LINDIG",;
				AllTrim(GetSx3Cache("E2_LINDIG","X3_PICTURE")),;
				GetSx3Cache("E2_LINDIG","X3_TAMANHO"),;
				GetSx3Cache("E2_LINDIG","X3_DECIMAL"),;
				"Vazio() .OR. ( VldCodBar(M->E2_LINDIG) .and. U_M103VDB() )",;
				GetSx3Cache("E2_LINDIG","X3_USADO"),;
				GetSx3Cache("E2_LINDIG","X3_TIPO"),;
				"",;
				"",;
				"",;
				"",;
				".T.";
				})
				//"Vazio() .OR. VldCodBar(M->E2_LINDIG) ",;

	aAdd(aRet,{;
				AllTrim(GetSx3Cache("E2_CODBAR","X3_TITULO")),;
				"E2_CODBAR",;
				AllTrim(GetSx3Cache("E2_CODBAR","X3_PICTURE")),;
				GetSx3Cache("E2_CODBAR","X3_TAMANHO"),;
				GetSx3Cache("E2_CODBAR","X3_DECIMAL"),;
				GetSx3Cache("E2_CODBAR","X3_VALID"),;
				GetSx3Cache("E2_CODBAR","X3_USADO"),;
				GetSx3Cache("E2_CODBAR","X3_TIPO"),;
				"",;
				"",;
				"",;
				"",;
				".F.";
				})
				//"Vazio() .OR. VldCodBar(M->E2_LINDIG) ",;
				//"Vazio() .OR. ( VldCodBar(M->E2_LINDIG) .and. U_M103VDB() )",;
Return aRet

User Function M103VDB()
	Local lRet := .T.
	Local cMsg := ""
	Local nI
	Local cLinDig := AllTrim(M->E2_LINDIG)
	Local cQry   := ""
	Local cAlias := ""

	if Type("aCBrMT103") <> 'U'
		For nI := 1 to Len(aCBrMT103)
			if aCBrMT103[nI,1] == cLinDig
				cMsg := "Código inserido já está na "
				cMsg += "linha: " + AllTrim(Str(nI))
				
				lRet := .F.
				exit
			endif
		Next nI

		cQry += " select * from "+RetSqlName("SE2")+" " + CRLF
		cQry += " WHERE E2_LINDIG = '"+cLinDig+"' " + CRLF
		cQry += " AND D_E_L_E_T_ = ''" + CRLF

		cAlias := GetNextAlias()
		MpSysOpenQry(cQry,cAlias)
		
		if !(cAlias)->(EOF())
			cMsg := "Boleto já cadastrado no Titulo: "+(cAlias)->E2_NUM + CRLF
			if AllTrim((cAlias)->E2_PARCELA) != ""
				cMsg += "Parcela: " + (cAlias)->E2_PARCELA + CRLF
			endif
			cMsg += "Filial: " + (cAlias)->E2_FILIAL

			lRet := .F.
		endif

		(cAlias)->(DbCloseArea())

		if !lRet
			MsgStop(cMsg,"Boleto Invalido!")
		else
			nValBol := SubStr(cLinDig,Len(cLinDig)-9,Len(cLinDig))
			nValBol := SubStr(nValBol,1,8) + '.' + SubStr(nValBol,9,2)
			nValBol := Val(nValBol)

			if nValBol > 0 .and. aCols[n,3] <> nValBol
				cMsg := "Código de boleto inválido!" + CRLF
				cMsg += "Valor do boleto não corresponde ao valor do titulo!"+ CRLF
				cMsg += "Valor do boleto: " + cValToChar(nValBol) + CRLF
				cMsg += "Valor do titulo: " + cValToChar(aCols[n,3]) + CRLF
				
				lRet := .F.
			endif
			
			if !lRet
				MsgStop(cMsg,"Boleto Invalido!")
			endif

		endif
	endif
Return lRet

User Function M103VAL()
	Local nRet    := M->E2_VALOR
	
	//if Type("aCBrMT103") <> "U" 
	//	M->E2_LINDIG := ""
	//	M->E2_CODBAR := ""
	//endif

Return nRet
//85850000001782201851124059018392008120240924
//00190000090315010700500251639175998470000037600
