#INCLUDE "PROTHEUS.CH"           
#INCLUDE "TOPCONN.CH"     
#INCLUDE "RWMAKE.CH"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  CmpAutTit  ºAutor  ³Henrique Magalhaes  º Data ³  18/02/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para realizacao de compensacao automatica de titulosº±±
±±º          ³de RA/PA                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico Vista Alegre p/compensacao automatica de titulosº±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*

>>> Exemplos de Utilizacao em Ponto de Entradas de Saida/Entrada de Documentos
 ->Documento de Entrada  - MT103FIM
		u_CmpAutTit('P',SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA)

 ->Documento de Saida - MT460FIM
		u_CmpAutTit('S',SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA)

// ** 28/07/2015 - cTitTipo - NDF ou NCC, para casos novos onde a compensacao sera automatica, na sequencia do lancamentos das devolucoes
*/       

User Function CmpAutTit(cDocTp, cDocFil, cDocNum, cDocSer, cDocCli, cDocLoja, cTitTipo)
Local aArea		 := GetArea()
Local aArea2	 := GetArea()	
Local aTitRA	 := {}
Local aTitulos	 := {}
Local aCompensar := {}
Local cQryRa  	 := ""
Local cQryTit  	 := ""
	
	If cDocTp=='R'
		// Selecionando o(s) RA(s) do Contrato com Saldo para Compensacao em aberto
		cQryRa := " SELECT R_E_C_N_O_, E1_SALDO AS TITSALDO, E1_VALOR AS TITVALOR "
		cQryRa += " FROM " + RETSQLNAME('SE1') + " " + " WITH (NOLOCK) "
		cQryRa += " WHERE D_E_L_E_T_ <> '*' "
		cQryRa += "   AND E1_CLIENTE = '" + cDocCli   + "' "
		cQryRa += "   AND E1_LOJA    = '" + cDocLoja  + "' "
		If cTitTipo == 'NCC'
			cQryRa += "   AND E1_PREFIXO = '" + cDocSer  	+ "' "    
			cQryRa += "   AND E1_NUM     = '" + cDocNum  	+ "' "    
			cQryRa += "   AND E1_FILIAL  = '" + cDocFil  	+ "' "    
			cQryRa += "   AND E1_TIPO IN ('NCC')  AND E1_SALDO > 0  "
		Else
			cQryRa += "   AND E1_TIPO IN ('RA')  AND E1_SALDO > 0  "
		Endif
		cQryRa += " ORDER BY E1_EMISSAO, E1_FILIAL, E1_TIPO, E1_PREFIXO, E1_NUM, E1_PARCELA "

		// Selecionando o(s) Titulo(s) A Receber da(s) Nota Fiscal(is) Selecionada(s)

		cQryTit := " SELECT R_E_C_N_O_, E1_SALDO AS TITSALDO, E1_VALOR AS TITVALOR "
		cQryTit += " FROM " + RETSQLNAME('SE1') + " " + " WITH (NOLOCK) "
		cQryTit += " WHERE D_E_L_E_T_ <> '*' "
		cQryTit += "   AND E1_CLIENTE = '" + cDocCli  	+ "' "
		cQryTit += "   AND E1_LOJA    = '" + cDocLoja 	+ "' "    
		cQryTit += "   AND E1_PREFIXO = '" + cDocSer  	+ "' "    
		cQryTit += "   AND E1_NUM     = '" + cDocNum  	+ "' "    
		cQryTit += "   AND E1_FILIAL  = '" + cDocFil  	+ "' "    
		cQryTit += "   AND E1_TIPO IN ('NF')  AND E1_SALDO > 0  "
		cQryTit += " ORDER BY E1_EMISSAO, E1_FILIAL, E1_TIPO, E1_PREFIXO, E1_NUM, E1_PARCELA "

	Elseif cDocTp=='P'
			// Selecionando o(s) PA(s) do Contrato com Saldo para Compensacao em aberto
		cQryRa := " SELECT R_E_C_N_O_, E2_SALDO AS TITSALDO, E2_VALOR AS TITVALOR "
		cQryRa += " FROM " + RETSQLNAME('SE2') + " " + " WITH (NOLOCK) "
		cQryRa += " WHERE D_E_L_E_T_ <> '*' "
		cQryRa += "   AND E2_FORNECE = '" + cDocCli   + "' "
		cQryRa += "   AND E2_LOJA    = '" + cDocLoja  + "' "
		If cTitTipo == 'NDF'
			cQryRa += "   AND E2_PREFIXO = '" + cDocSer  	+ "' "    
			cQryRa += "   AND E2_NUM     = '" + cDocNum  	+ "' "    
			cQryRa += "   AND E2_FILIAL  = '" + cDocFil  	+ "' "    
			cQryRa += "   AND E2_TIPO IN ('NDF')  AND E2_SALDO > 0  "
		Else
			cQryRa += "   AND E2_TIPO IN ('PA')  AND E2_SALDO > 0  "
		Endif
		cQryRa += " ORDER BY E2_EMISSAO, E2_FILIAL, E2_TIPO, E2_PREFIXO, E2_NUM, E2_PARCELA "

		// Selecionando o(s) Titulo(s) A Pagar da(s) Nota Fiscal(is) Selecionada(s)
		cQryTit := " SELECT R_E_C_N_O_, E2_SALDO AS TITSALDO, E2_VALOR AS TITVALOR  "
		cQryTit += " FROM " + RETSQLNAME('SE2') + " " + " WITH (NOLOCK) "
		cQryTit += " WHERE D_E_L_E_T_ <> '*' "
		cQryTit += "   AND E2_FORNECE = '" + cDocCli  	+ "' "
		cQryTit += "   AND E2_LOJA    = '" + cDocLoja 	+ "' "    
		cQryTit += "   AND E2_PREFIXO = '" + cDocSer  	+ "' "    
		cQryTit += "   AND E2_NUM     = '" + cDocNum  	+ "' "    
		cQryTit += "   AND E2_FILIAL  = '" + cDocFil  	+ "' "    
		cQryTit += "   AND E2_TIPO IN ('NF')  AND E2_SALDO > 0  "
		cQryTit += " ORDER BY E2_EMISSAO, E2_FILIAL, E2_TIPO, E2_PREFIXO, E2_NUM, E2_PARCELA "
	
	EnDif	
	
	If SELECT("QTITRA") > 0
		QTITRA->(dbCloseArea())
	Endif
	TcQuery cQryRa New Alias 'QTITRA'
	
	QTITRA->(dbGoTop())
	
	While !QTITRA->(EOF())
		aAdd(aTitRA, {QTITRA->R_E_C_N_O_ , QTITRA->TITSALDO})	
		QTITRA->(dbSkip())
	EndDo          
	
	
	If SELECT("QTITNF") > 0
		QTITNF->(dbCloseArea())
	Endif
	TcQuery cQryTit New Alias "QTITNF"

		
	//Begin Transaction

		For i:=1 to Len(aTitRA)
			aTitulos	:= {0,0,0,0}
			aCompensar	:= {}

			If SELECT('QTITNF') > 0
				QTITNF->(dbCloseArea())
			Endif
			TcQuery cQryTit New Alias 'QTITNF'		
			QTITNF->(dbGoTop())
			
			nSaldoRA	:= aTitRA[i,2] 	// Saldo do RA a Compensar		
			While !QTITNF->(EOF()) 
				if QTITNF->TITSALDO < nSaldoRA
					If cDocTp=='R'
						aAdd(aCompensar,{QTITNF->R_E_C_N_O_, QTITNF->TITSALDO, 0,,,,,,,,0})	
					ElseIf cDocTp=='P'
						aAdd(aCompensar,{QTITNF->R_E_C_N_O_, QTITNF->TITSALDO, 0,,,,,,,0,.F.})	
	                Endif												
					nSaldoRA := nSaldoRA - QTITNF->TITSALDO
				Else
					If nSaldoRA > 0 .and.  QTITNF->TITSALDO >= nSaldoRA 
						If cDocTp=='R'
							aAdd(aCompensar,{QTITNF->R_E_C_N_O_, nSaldoRA, 0,,,,,,,,0})	
						ElseIf cDocTp=='P'
							aAdd(aCompensar,{QTITNF->R_E_C_N_O_, nSaldoRA, 0,,,,,,,0,.F.})	
		                Endif												
						nSaldoRA := 0
					Endif		
				Endif 
				QTITNF->(dbSkip())
			EndDo 
			If len(aCompensar) > 0
				aArea2	 := GetArea()
				If cDocTp=='R'
					dbSelectArea('SE1')
					MsGoTo(aTitRA[i,1]) 		// Posiciona no RA para compensar
					FaCmpCR(aTitulos, aCompensar,,,"MATA465")
				ElseIf cDocTp=='P'
					dbSelectArea('SE2')
					MsGoTo(aTitRA[i,1]) 		// Posiciona no PA para compensar
					FaCmpCP(aTitulos, aCompensar,,"MATA465") // incluido rotina MATA465 para que tipodoc do se5 seja gravado corretamente
                Endif
				RestArea(aArea2)
			Endif 					
		Next i
//	End Transaction

	RestArea(aArea)

Return



// Gravar Campo Moeda nos registros SE5 apos compensacao, devido a problemas de estornos por conta da falta do campo e5_moeda
User function SE5FI340()
	Reclock("SE5",.F.)
		E5_MOEDA = '01'
	MsUnlock()
Return

// Gravar Campo Moeda nos registros SE5 apos compensacao, devido a problemas de estornos por conta da falta do campo e5_moeda
User function SE5FI341()
	Reclock("SE5",.F.)
		E5_MOEDA = '01'
	MsUnlock()
Return


/*
User Function TstCmpCR()

Local aArea		 := GetArea()
Local aTitRA	 := {}
Local aTitulos	 := {}
Local aCompensar := {}

		
	aTitulos	:= {0,0,0,0}
		aCompensar	:= {}
		aAdd(aCompensar,{898, 15750.00,0,,,,,,,0,.F.})	
		aAdd(aCompensar,{899, 15750.00,0,,,,,,,0,.F.})	
		dbSelectArea('SE2')
		MsGoTo(894) 		// Posiciona no RA para compensar
		FaCmpCP(aTitulos, aCompensar)
Return
*/

