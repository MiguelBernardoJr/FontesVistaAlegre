#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "GPER150.CH"
#INCLUDE "REPORT.CH"

#DEFINE cEol CHR(13)+CHR(10)


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Gera CNAB para os Bancos Itau                                        |
 |                                                                       		   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
User Function MBHoleri()	// U_MBHoleri()

	/* Declaracao de Variaveis */
	Private cPerg     	:= 'MBHoleri'
	// Private cString   	:= 'SRA'
	// Private cSeqReBb	:= ''
	Private cLin		:= ''
	Private cNomeArq	:= ''
	//Private nQtFunc		:= 0
	Private nHdl		:= 0
	Private lLiq		:= .F.
	Private lData		:= .F.
	Private lHeader		:= .F.
	Private lContinua	:= .T.

	Private cCodAgenc   := "0203"
	Private cCodConta   := "70650"
	Private cDigConta   := "2"

	fAsrPerg()
	pergunte(cPerg, .F.)

	dbSelectArea( "SRA" )
	dbSetOrder(1)

	/* Montagem da tela de processamento. */
	@ 200, 001 TO 410, 480 DIALOG oDlgHol TITLE OemToAnsi( "Geracao do Arquivo de Pagamento" )
	@ 002, 010 TO 095, 230
	@ 010, 018 Say " Este programa ira gerar o arquivo de demonstrativo de pagamento    "
	@ 018, 018 Say " para o Banco Itau                       				   		   "
	@ 026, 018 Say "                                                                    "

	@ 070, 128 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg, .T.)
	@ 070, 158 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
	@ 070, 188 BMPBUTTON TYPE 02 ACTION oDlgHol:End() // Close(oDlgHol)

	Activate Dialog oDlgHol Centered

	If lLiq
		Aviso("Atenção", "Valor liquido de alguns funcionarios com diferenças", {"Continuar"})
	Endif

	If nHdl > 0
		If fClose(nHdl)
			If lContinua .And. lData
				ApMsgInfo( 'Arquivo Gerado.  Processamento Concluido. ',  'ATENÇÃO' )
			Else
				If fErase(cNomeArq) == 0
					If !lContinua .Or. !lData
						ApMsgInfo( 'Nao Existem Registros a Serem Gravados. Processamento Concluido.',  'ATENÇÃO' )
					EndIf
				Else
					MsgAlert('Ocorreram problemas na tentativa de deleção do arquivo ' + AllTrim(cNomeArq)+'.')
				EndIf
			EndIf
		Else
			MsgAlert('Ocorreram problemas no fechamento do arquivo '+AllTrim(cNomeArq)+'.')
		EndIf
	Else
		If !lContinua
			ApMsgInfo( 'Processamento Abortado.',  'ATENÇÃO' )
		Endif
	EndIf

Return



/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Funcao chamada pelo botao OK na tela inicial de processamen          |
 |            to. Executa a geracao do arquivo texto.                              |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function OkGeraTxt
	Processa({|| RunCont() }, "Processando...")
	// Close(oDlgHol)
	oDlgHol:End()
Return


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA            |
 |            monta a janela com a regua de processamento.                         |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function RunCont 	// U_MBHoleri()

	//Local lIgual                 //Variavel de retorno na comparacao do SRC
	//Local cArqNew                //Variavel de retorno caso SRC # SX3
	Local cMesArqRef
	//Local aOrdBag     := {}
	//Local cArqMov     := ""
	//Local cAliasMov   := ""
	Local nReg		  := 0
	Local cAcessaSR1  := &("{ || " + ChkRH("GPER030", "SR1", "2") + "}")
	Local cAcessaSRA  := &("{ || " + ChkRH("GPER030", "SRA", "2") + "}")
	Local cAcessaSRC  := &("{ || " + ChkRH("GPER030", "SRC", "2") + "}")
	Local cAcessaSRD  := &("{ || " + ChkRH("GPER030", "SRD", "2") + "}")
	Local cAcessaSRR  := &("{ || " + ChkRH("GPER030", "SRR", "2") + "}")
	// Local cAcessaSRI  := &("{ || " + ChkRH("GPER030", "SRI", "2") + "}")

	//Variaveis para emissao do arquivo de ferias
	Local cDataBas	:= ""
	Local cDBaseAt	:= ""
	Local cDFerias	:= ""
	Local cDAbonPe	:= ""

	Private dDataRef,  cEsc,  nEsc,  Semana,  cFilDe,  cFilAte,  cCcDe,  cCcAte,  cMatDe
	Private cMatAte,  Mensag1,  Mensag2,  Mensag3,  cSit,  cCat
	Private cMesAnoRef,  dDtBusFer,  dDtFerIni// , lAtual
	Private cBancoDe,  cBancoAte,  cContaDe,  cContaAte

	Private cFinPgt,  nSequenc,  dDataPagto,  dDataDe,  dDataAte

	Private aTotLote := {0, 0}

	Private TOTVENC,  TOTDESC,  FLAG,  CHAVE
	Private Desc_Fil,  Desc_End,  DESC_CGC,  DESC_FUNC
	Private DESC_MSG1,  DESC_MSG2,  DESC_MSG3
	Private cFilialAnt,  cFuncaoAnt,  cCcAnt,  Vez,  OrdemZ

	Private nAteLim,  nBaseFgts,  nFgts,  nBaseIr,  nBaseIrFe,  nLiquido

	Private aLanca := {}
	Private aProve := {}
	Private aDesco := {}
	Private aBases := {}
	Private aInfo  := {}
	Private aCodFol:= {}
	// Private cFolMes_ := GETMV("MV_FOLMES")

	// Pergunte(cPerg, .F.)		// U_MBHoleri()
	dDataRef   := mv_par01
	cEsc       := mv_par02
	Semana     := mv_par03
	cFilDe     := mv_par04
	cFilAte    := mv_par05
	cCcDe      := mv_par06
	cCcAte     := mv_par07
	cMatDe     := mv_par08
	cMatAte    := mv_par09
	Mensag1    := mv_par10
	Mensag2    := mv_par11
	Mensag3    := mv_par12
	cSit       := mv_par13
	cCat       := mv_par14
	cNomeArq   := Alltrim(mv_par15)
	dDataPagto := mv_par16
	cBancoDe   := mv_par17
	cBancoAte  := mv_par18
	cContaDe   := mv_par19
	cContaAte  := mv_par20
	dDataDe	   := mv_par21
	dDataAte   := mv_par22

	// Gravar no MAC, nao consegui fazer gravar no MAC, somente no servidor, na pasta SYSTEM.
	If GetRemoteType() == 2 // UNIX ou LINUX -> salvar no servidor, criar pasta "system\tmp\"
		cNomeArq := "system\tmp\" + cNomeArq
	EndIf

	For nReg := 1 to Len(cEsc)
		If !("*" == Substr(cEsc, nReg, 1))
			nEsc	:= Val(Substr(cEsc, nReg, 1))
			Exit
		EndIf
	Next nReg

	//Cria o arquivo texto
	While .T.
		If File(cNomeArq)
			If (nAviso := Aviso('AVISO', 'Deseja substituir o ' + AllTrim(cNomeArq) + ' existente ?',  {'Sim', 'Não', 'Cancela'})) == 1
			If fErase(cNomeArq) == 0
				Exit
			Else
				MsgAlert('Ocorreram problemas na tentativa de deleção do arquivo '+AllTrim(cNomeArq)+'.')
			EndIf
		ElseIf nAviso == 2
			Pergunte(cPerg, .T.)
			Loop
		Else
			lContinua := .F.
			Return
		EndIf
		Else
		Exit
		EndIf
	EndDo

	nHdl := fCreate(cNomeArq)

	If nHdl == -1
		MsgAlert("O arquivo de nome "+cNomeArq+" nao pode ser executado! Verifique os parametros.", "Atenção!")
		Return
	Endif

	cMesAnoRef := StrZero(Month(dDataRef), 2) + StrZero(Year(dDataRef), 4)
	cMesArqRef  := If(nEsc == 4, "13"+Right(cMesAnoRef, 4), cMesAnoRef)

	/* Selecionando a Ordem de impressao escolhida no parametro. */
	// dbSelectArea( "SI3" )
	// SI3->(dbSetOrder(1))
	// dbSelectArea( "SRF" )
	// SRF->(dbSetOrder(1))
	// dbSelectArea( "SRH" )
	// SRH->(dbSetOrder(1))
	// dbSelectArea( "SRJ" )
	// SRJ->(dbSetOrder(1))
	// dbSelectArea( "SRR" )
	// SRR->(dbSetOrder(1))
	// dbSelectArea( "SRA" )
	// SRA->(dbSetOrder(1))
	// dbSelectArea("RCN")
	// RCN->(dbSetOrder(1))
	// dbSelectArea("CTT")
	// CTT->( dbSetOrder(1) )
	// dbGoTop()

	/* Selecionando o Primeiro Registro e montando Filtro. */
	dbSeek(cFilDe + cMatDe, .T.)
	cCond := "SRA->RA_FILIAL + SRA->RA_MAT <= cFilAte + cMatAte"

	ProcRegua(RecCount(0))

	TOTVENC    := TOTDESC   := FLAG      := CHAVE     := 0
	Desc_Fil   := Desc_End  := DESC_CGC   := DESC_FUNC := ""
	DESC_MSG1  := DESC_MSG2 := DESC_MSG3 := Space(01)
	cFilialAnt := "  "
	cFuncaoAnt := "    "
	cCcAnt     := Space(9)
	Vez        := 0
	OrdemZ     := 0
	nSequenc   := 0

	If nEsc == 1			// Adiantamento
		cFinPgt := "02"
	ElseIf nEsc == 2		// Folha
		cFinPgt := "01"
	ElseIf nEsc == 3		// 1a Parcela
		cFinPgt := "04"
	ElseIf nEsc == 4		// 2a Parcela
		cFinPgt := "04"
	ElseIf nEsc	== 5		// Extras
		cFinPgt := "10"
	ElseIf nEsc == 6		// Ferias
		cFinPgt := "07"
	EndIf

	//Filtra Banco 341 (Itau)
	If Subst(cBancoDe, 1, 3) != '341'.Or. Subst(cBancoAte, 1, 3) != '341'
		Aviso("Atenção BANCO ITAU", "Banco/Agencia De ou Banco/Agencia Ate Diferente de 341", {"Continuar"})
		Return
	Endif

	// dbSelectArea("SRA")
	// SRA->(DbSetOrder(1))
	Do While SRA->(!Eof()) .And. &cCond .And. lContinua
		/*
		If AllTrim(SRA->RA_FILIAL)+AllTrim(SRA->RA_MAT) == '12900017'
		SRA->(dbSkip())
		Loop
		alert('Miguel')
		EndIf
		*/
		IncProc("Fil: " + SRA->RA_FILIAL + "  Matr: " + SRA->RA_MAT)

		/*

		If  !(SRA->RA_FILIAL+SRA->RA_MAT == '01000053' .or. ;
		SRA->RA_FILIAL+SRA->RA_MAT == '01000066' .or. ;
		SRA->RA_FILIAL+SRA->RA_MAT == '01000161' .or. ;
		SRA->RA_FILIAL+SRA->RA_MAT == '13000008')

		SRA->(dbSkip())
		Loop
			EndIf
		*/

		If (SRA->RA_FILIAL   < cFilDe)  .Or. (SRA->RA_FILIAL   > cFilAte) .Or. ;
				(SRA->RA_CC  < cCcDe)   .Or. (SRA->RA_CC       > cCcAte)  .Or. ;
				(SRA->RA_MAT < cMatDe)  .Or. (SRA->RA_MAT      > cMatAte)
			SRA->(dbSkip())
			Loop
		EndIf

		/* Verifica Data Demissao */
		cSitFunc := SRA->RA_SITFOLH
		dDtPesqAf:= CTOD("01/" + Left(cMesAnoRef, 2) + "/" + Right(cMesAnoRef, 4), "DDMMYY")
		If cSitFunc == "D" .And. (!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) > MesAno(dDtPesqAf))
			cSitFunc := " "
		Endif

		/* Consiste situacao e categoria dos funcionarios */
		If !( cSitFunc $ cSit ) .OR.  ! ( SRA->RA_CATFUNC $ cCat )
			SRA->(dbSkip())
			Loop
		Endif
		If cSitFunc $ "D" .And. Mesano(SRA->RA_DEMISSA) # Mesano(dDataRef)
			SRA->(dbSkip())
			Loop
		Endif

		// Filtra Bancos e Contas
		If (SRA->RA_BCDEPSA < cBancoDe  .Or. SRA->RA_BCDEPSA > cBancoAte) .Or. ;
				(SRA->RA_CTDEPSA < cContaDe  .Or. SRA->RA_CTDEPSA > cContaAte)
			SRA->(dbSkip())
			Loop
		EndIf

		If SRA->RA_MSBLQL == "1" // RA_BLQPAG == "1"
			SRA->(dbSkip())
			Loop
		EndIf

		aLanca  := {}
		aProve  := {}
		aDesco  := {}
		aBases  := {}

		cDataBas	:= ""
		cDBaseAt	:= ""
		cDFerias	:= ""
		cDAbonPe	:= ""

		nAteLim := nBaseFgts := nFgts := nBaseIr := nBaseIrFe := nLiquido := 0.00

		/* Consiste controle de acessos e filiais validas */
		If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
			SRA->(dbSkip())
			Loop
		EndIf

		If SRA->RA_CODFUNC # cFuncaoAnt           // Descricao da Funcao
			DescFun(Sra->Ra_Codfunc, SRA->RA_FILIAL)
			cFuncaoAnt := Sra->Ra_CodFunc
		Endif

		If SRA->RA_CC # cCcAnt                   // Centro de Custo
			DescCC(Sra->Ra_Cc, SRA->RA_FILIAL)
			cCcAnt := SRA->RA_CC
		Endif

		If SRA->RA_FILIAL # cFilialAnt
			If !Fp_CodFol(@aCodFol, SRA->RA_FILIAL) .Or. ! fInfo(@aInfo, SRA->RA_FILIAL)
				lContinua := .F.
				Exit
			Endif
			Desc_Fil := aInfo[3]
			Desc_End := aInfo[4]                // Dados da Filial
			Desc_CGC := aInfo[8]
			DESC_MSG1:= DESC_MSG2 := DESC_MSG3 := Space(01)

			// MENSAGENS
			If MENSAG1 # SPACE(1)
				If FPHIST82(SRA->RA_FILIAL, "06", SRA->RA_FILIAL+MENSAG1)
					DESC_MSG1 := Left(SRX->RX_TXT, 30)
				ElseIf FPHIST82(SRA->RA_FILIAL, "06", "  "+MENSAG1)
					DESC_MSG1 := Left(SRX->RX_TXT, 30)
				Endif
			Endif

			If MENSAG2 # SPACE(1)
				If FPHIST82(SRA->RA_FILIAL, "06", SRA->RA_FILIAL+MENSAG2)
					DESC_MSG2 := Left(SRX->RX_TXT, 30)
				ElseIf FPHIST82(SRA->RA_FILIAL, "06", "  "+MENSAG2)
					DESC_MSG2 := Left(SRX->RX_TXT, 30)
				Endif
			Endif

			If MENSAG3 # SPACE(1)
				If FPHIST82(SRA->RA_FILIAL, "06", SRA->RA_FILIAL+MENSAG3)
					DESC_MSG3 := Left(SRX->RX_TXT, 30)
				ElseIf FPHIST82(SRA->RA_FILIAL, "06", "  "+MENSAG3)
					DESC_MSG3 := Left(SRX->RX_TXT, 30)
				Endif
			Endif

			// dbSelectArea("SRA")

			cFilialAnt := SRA->RA_FILIAL
		Endif

		Totvenc := Totdesc := 0

		CTT->(dbSeek( xFilial("CTT", SRA->RA_FILIAL)+SRA->RA_CC ))
		SRJ->(dbSeek( xFilial("SRJ", SRA->RA_FILIAL)+SRA->RA_CODFUNC ))
		SRH->(dbSeek( xFilial("SRH", SRA->RA_FILIAL)+SRA->RA_MAT ))

		If nEsc == 1 .OR. nEsc == 2

			DbUseArea(.t., "TOPCONN", TCGenQry(,,;
				" SELECT RCH_STATUS, R_E_C_N_O_ FROM RCH010 " + CRLF +;
				"	WHERE RCH_FILIAL=' '" + CRLF +;
				"	  AND RCH_PER='"+ StrZero(Year(dDataRef), 4) + StrZero(Month(dDataRef), 2) + "'" + CRLF +; // " AND RCH_PER='"+MV_PAR23+ "'" + CRLF +;
				"	  AND RCH_ROTEIR='FOL'" + CRLF +;
				"	  -- AND RCH_STATUS='5'" ;
				), "TMPRCH", .T., .F.)
			If !TMPRCH->(Eof())

				If TMPRCH->RCH_STATUS == '5'

					//SRD->(dbSelectArea("SRD"))
					If SRD->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT))
						Do While !SRD->(Eof()) .And. SRD->RD_FILIAL+SRD->RD_MAT == SRA->RA_FILIAL+SRA->RA_MAT

							// Pular Verbas que nao sao sobre a folha:
							If  (SRD->RD_PD $ GetMV('MB_JUMPVRB',,'143,154,300,301,302,306,384,385,386,390,391,424')) ;
									.OR. AT("13", Posicione('SRV', 1, xFilial('SRV')+SRD->RD_PD,'RV_DESC') ) > 0

								// .OR. (SRD->RD_PD $ GetMV('MB_JUMPVR2',,'144,200,203,267,268,413'))

								/* 384,385,390,391 :
									incluido essa verba no dia 03.12.2020
									segundo a vanda corresponde ao 13º;
								*/

								If !(SRD->RD_PD $ ("145,412,415")) // MB : 05.01.2022
									SRD->(dbSkip())
									Loop
								EndIf
							EndIf

							If SRD->RD_PERIODO # StrZero(Year(dDataRef), 4) + StrZero(Month(dDataRef), 2) // MV_PAR23
								SRD->(dbSkip())
								Loop
							Endif
							/*
							If SRD->RD_SEMANA # Semana
							dbSkip()
							Loop
							Endif
							*/
							If !Eval(cAcessaSRD)
								SRD->(dbSkip())
								Loop
							EndIf
							If (nEsc == 1) .And. (SRD->RD_PD == aCodFol[7, 1])      // Desconto de Adto
								fSomaPd("P", aCodFol[6, 1], SRD->RD_HORAS, SRD->RD_VALOR)
								TOTVENC += SRD->RD_Valor
							Elseif (nEsc == 1) .And. (SRD->RD_PD == aCodFol[12, 1])
								fSomaPd("D", aCodFol[9, 1], SRD->RD_HORAS, SRD->RD_VALOR)
								TOTDESC += SRD->RD_VALOR
							Elseif (nEsc == 1) .And. (SRD->RD_PD == aCodFol[8, 1])
								fSomaPd("P", aCodFol[8, 1], SRD->RD_HORAS, SRD->RD_VALOR)
								TOTVENC += SRD->RD_VALOR
							Else
								If PosSrv( SRD->RD_PD ,  SRA->RA_FILIAL ,  "RV_TIPOCOD" ) == "1"
									If (nEsc #1) .Or. (nEsc == 1 .And. PosSrv(SRD->RD_PD, SRA->RA_FILIAL, "RV_ADIANTA") == "S")
										fSomaPd("P", SRD->RD_PD, SRD->RD_HORAS, SRD->RD_VALOR)
										TOTVENC += SRD->RD_Valor
									Endif
								Elseif PosSrv( SRD->RD_PD ,  SRA->RA_FILIAL ,  "RV_TIPOCOD" ) == "2"
									If (nEsc #1) .Or. (nEsc == 1 .And. PosSrv(SRD->RD_PD, SRA->RA_FILIAL, "RV_ADIANTA") == "S")
										fSomaPd("D", SRD->RD_PD, SRD->RD_HORAS, SRD->RD_VALOR)
										TOTDESC += SRD->RD_Valor
									Endif
								Elseif PosSrv( SRD->RD_PD ,  SRA->RA_FILIAL ,  "RV_TIPOCOD" ) == "3"
									If (nEsc #1) .Or. (nEsc == 1 .And. PosSrv(SRD->RD_PD, SRA->RA_FILIAL, "RV_ADIANTA") == "S")
										fSomaPd("B", SRD->RD_PD, SRD->RD_HORAS, SRD->RD_VALOR)
									Endif
								Endif
							Endif
							If nESC = 1
								If SRD->RD_PD == aCodFol[10, 1]
									nBaseIr := SRD->RD_VALOR
								Endif
							ElseIf SRD->RD_PD == aCodFol[13, 1]
								nAteLim += SRD->RD_VALOR
							Elseif SRD->RD_PD$ aCodFol[108, 1]+'*'+aCodFol[17, 1]
								nBaseFgts += SRD->RD_VALOR
							Elseif SRD->RD_PD$ aCodFol[109, 1]+'*'+aCodFol[18, 1]
								nFgts += SRD->RD_VALOR
							Elseif SRD->RD_PD == aCodFol[15, 1]
								nBaseIr += SRD->RD_VALOR
							Elseif SRD->RD_PD == aCodFol[16, 1]
								nBaseIrFe += SRD->RD_VALOR
							Elseif SRD->RD_PD == aCodFol[47, 1]
								nLiquido := SRD->RD_VALOR
							Endif
							//dbSelectArea("SRD")
							SRD->(dbSkip())
						Enddo
						nLiquido := TOTVENC - TOTDESC // essa linha eu nao sei se vai ser necessaria aqui, add no dia 16.12.19
					Endif

				Else

					// dbSelectArea("SRC")
					If SRC->( dbSeek(SRA->RA_FILIAL + SRA->RA_MAT) )

						While !SRC->(Eof()) .And. SRC->RC_FILIAL+SRC->RC_MAT == SRA->RA_FILIAL+SRA->RA_MAT

							If AllTrim(MV_PAR02) $ ("34")
								// If !SRC->RC_PD $ ("145,412,415") // MB : 05.01.2022
								// Pular Verbas que nao sao sobre a folha:
								If (SRC->RC_PD $ GetMV('MB_JUMPVRB',,'143,154,300,301,302,306,384,385,386,390,391,424'))
									// 13 o. .OR. AT("13", Posicione('SRV', 1, xFilial('SRV')+SRC->RC_PD,'RV_DESC') ) > 0 )

									/* 384,385,390,391 :
											incluido essa verba no dia 03.12.2020
											segundo a vanda corresponde ao 13º;
									*/
									SRC->(dbSkip())
									Loop
								EndIf
								// EndIf
							EndIf

							If SRC->RC_PERIODO # StrZero(Year(dDataRef), 4) + StrZero(Month(dDataRef), 2) // MV_PAR23
								SRC->(dbSkip())
								Loop
							Endif
							/*
							If SRC->RC_SEMANA # Semana
							dbSkip()
							Loop
							Endif
							*/
							If !Eval(cAcessaSRC)
								SRC->(dbSkip())
								Loop
							EndIf
							If (nEsc == 1) .And. (Src->Rc_Pd == aCodFol[7, 1])      // Desconto de Adto
								fSomaPd("P", aCodFol[6, 1], SRC->RC_HORAS, SRC->RC_VALOR)
								TOTVENC += Src->Rc_Valor
							Elseif (nEsc == 1) .And. (Src->Rc_Pd == aCodFol[12, 1])
								fSomaPd("D", aCodFol[9, 1], SRC->RC_HORAS, SRC->RC_VALOR)
								TOTDESC += SRC->RC_VALOR
							Elseif (nEsc == 1) .And. (Src->Rc_Pd == aCodFol[8, 1])
								fSomaPd("P", aCodFol[8, 1], SRC->RC_HORAS, SRC->RC_VALOR)
								TOTVENC += SRC->RC_VALOR
							Else
								If PosSrv( Src->Rc_Pd ,  SRA->RA_FILIAL ,  "RV_TIPOCOD" ) == "1"
									If (nEsc #1) .Or. (nEsc == 1 .And. PosSrv(Src->Rc_Pd, SRA->RA_FILIAL, "RV_ADIANTA") == "S")
										fSomaPd("P", SRC->RC_PD, SRC->RC_HORAS, SRC->RC_VALOR)
										TOTVENC += Src->Rc_Valor
									Endif
								Elseif PosSrv( Src->Rc_Pd ,  SRA->RA_FILIAL ,  "RV_TIPOCOD" ) == "2"
									If (nEsc #1) .Or. (nEsc == 1 .And. PosSrv(Src->Rc_Pd, SRA->RA_FILIAL, "RV_ADIANTA") == "S")
										fSomaPd("D", SRC->RC_PD, SRC->RC_HORAS, SRC->RC_VALOR)
										TOTDESC += Src->Rc_Valor
									Endif
								Elseif PosSrv( Src->Rc_Pd ,  SRA->RA_FILIAL ,  "RV_TIPOCOD" ) == "3"
									If (nEsc #1) .Or. (nEsc == 1 .And. PosSrv(Src->Rc_Pd, SRA->RA_FILIAL, "RV_ADIANTA") == "S")
										fSomaPd("B", SRC->RC_PD, SRC->RC_HORAS, SRC->RC_VALOR)
									Endif
								Endif
							Endif
							If nESC = 1
								If SRC->RC_PD == aCodFol[10, 1]
									nBaseIr := SRC->RC_VALOR
								Endif
							ElseIf SRC->RC_PD == aCodFol[13, 1]
								nAteLim += SRC->RC_VALOR
							Elseif SRC->RC_PD$ aCodFol[108, 1]+'*'+aCodFol[17, 1]
								nBaseFgts += SRC->RC_VALOR
							Elseif SRC->RC_PD$ aCodFol[109, 1]+'*'+aCodFol[18, 1]
								nFgts += SRC->RC_VALOR
							Elseif SRC->RC_PD == aCodFol[15, 1]
								nBaseIr += SRC->RC_VALOR
							Elseif SRC->RC_PD == aCodFol[16, 1]
								nBaseIrFe += SRC->RC_VALOR
							Elseif SRC->RC_PD == aCodFol[47, 1]
								nLiquido := SRC->RC_VALOR
							Endif
							// dbSelectArea("SRC")
							SRC->( dbSkip() )
						Enddo
						nLiquido := TOTVENC - TOTDESC
					Endif
				EndIf
			EndIf
			TMPRCH->(DbCloseArea())

		Elseif nEsc == 3	// 1a Parcela

			// dbSelectArea("SRC")
			If SRC->( dbSeek(SRA->RA_FILIAL + SRA->RA_MAT) )
				Do While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRC->RC_FILIAL + SRC->RC_MAT
					If !Eval(cAcessaSRC)
						SRC->(dbSkip())
						Loop
					EndIf
					If SRC->RC_PD == "795" // aCodFol[678, 1] //795=LIQUIDO 1ª PARC. 13º      aCodFol[22, 1] // aCodFol[aScan(aCodFol,{|x|x[1]=="795"}), 1]
						fSomaPd("P", SRC->RC_PD, SRC->RC_HORAS, SRC->RC_VALOR)
						TOTVENC += SRC->RC_VALOR
					Elseif SRC->RC_PD == aCodFol[172, 1]
						fSomaPd("D", SRC->RC_PD, SRC->RC_HORAS, SRC->RC_VALOR)
						TOTDESC += SRC->RC_VALOR
					Elseif SRC->RC_PD == aCodFol[108, 1] .Or. SRC->RC_PD == aCodFol[109, 1] .Or. SRC->RC_PD == aCodFol[173, 1]
						fSomaPd("B", SRC->RC_PD, SRC->RC_HORAS, SRC->RC_VALOR)
					Endif

					If SRC->RC_PD == aCodFol[108, 1]
						nBaseFgts := SRC->RC_VALOR
					Elseif SRC->RC_PD == aCodFol[109, 1]
						nFgts     := SRC->RC_VALOR
					Endif
					// dbSelectArea("SRC")
					SRC->(dbSkip())
				Enddo
				nLiquido := TOTVENC - TOTDESC
			Endif

		Elseif nEsc == 4	// 2a parcela 13


			// SRD é a tabela, quando a folha ja esta fechada
			// Trocar SRD para SRC, eu troquei para tirar a 2a. parcela do 13.or.
			// no dia 20.12.2022

			// dbSelectArea("SRD")
			SRD->(DbSetOrder(1))
			If SRD->( dbSeek(SRA->RA_FILIAL + SRA->RA_MAT) )

				Do While !SRD->(Eof()) .And.;
					SRA->RA_FILIAL + SRA->RA_MAT == SRD->RD_FILIAL + SRD->RD_MAT

					If SRD->RD_ROTEIR <> '132'
						SRD->(dbSkip())
						Loop
					EndIf
					If SRD->RD_DATPGT <> MV_PAR16
						SRD->(dbSkip())
						Loop
					EndIf

					If !Eval(cAcessaSRD)
						SRD->(dbSkip())
						Loop
					EndIf

					// If SRD->RD_PD $ ('144,200,203,267,268,271,274,330') //"788"
					If PosSrv(SRD->RD_PD, SRA->RA_FILIAL, "RV_TIPOCOD") == "1" .AND.;
							SRD->RD_PD $ ("144,200,203,267,268,330") // 418=pensao alimenticia
							// At("13", Posicione("SRV", 1, xFilial("SRV")+SRD->RD_PD, 'RV_DESC')) > 0 .OR.;

						fSomaPd("P", SRD->RD_PD, SRD->RD_HORAS, SRD->RD_VALOR)
						TOTVENC += SRD->RD_VALOR

						// Elseif SRD->RD_PD $ ('412,415,469')
					ElseIf PosSrv(SRD->RD_PD, SRA->RA_FILIAL, "RV_TIPOCOD") == "2" .AND.;
							SRD->RD_PD $ ("412,415,418,469") // 418=pensao alimenticia
							// At("13", Posicione("SRV", 1, xFilial("SRV")+SRD->RD_PD, 'RV_DESC')) > 0) .OR.;

						fSomaPd("D", SRD->RD_PD, SRD->RD_HORAS, SRD->RD_VALOR)
						TOTDESC += SRD->RD_VALOR

					Elseif SRD->RD_PD $ ("704,707,711,714,719,720,721,750,751,752,767") // ,788 nao pode entrar
						// SRD->RD_PD == aCodFol[108, 1] .Or.;
						// SRD->RD_PD == aCodFol[109, 1] .Or. SRD->RD_PD == aCodFol[173, 1]
						fSomaPd("B", SRD->RD_PD, SRD->RD_HORAS, SRD->RD_VALOR)

					Endif

					If SRD->RD_PD == aCodFol[108, 1]
						nBaseFgts := SRD->RD_VALOR
					Elseif SRD->RD_PD == aCodFol[109, 1]
						nFgts     := SRD->RD_VALOR
					Endif
					//dbSelectArea("SRD")
					SRD->(dbSkip())
				Enddo
				nLiquido := TOTVENC - TOTDESC
			Endif

		Elseif nEsc == 5

			// dbSelectArea("SR1")
			// SR1->(dbSetOrder(1))
			If SR1->(dbSeek( SRA->RA_FILIAL + SRA->RA_MAT ))

				Do While !SR1->(Eof()) .And. SRA->RA_FILIAL + SRA->RA_MAT ==	SR1->R1_FILIAL + SR1->R1_MAT
					// If Semana #"99"
					// 	If SR1->R1_SEMANA #Semana
					// 		SR1->(dbSkip())
					// 		Loop
					// 	Endif
					// Endif
					If !Eval(cAcessaSR1)
						SR1->(dbSkip())
						Loop
					EndIf
					If PosSrv( SR1->R1_PD ,  SRA->RA_FILIAL ,  "RV_TIPOCOD" ) == "1"
						fSomaPd("P", SR1->R1_PD, SR1->R1_HORAS, SR1->R1_VALOR)
						TOTVENC = TOTVENC + SR1->R1_VALOR
					Elseif PosSrv( SR1->R1_PD ,  SRA->RA_FILIAL ,  "RV_TIPOCOD" ) == "2"
						fSomaPd("D", SR1->R1_PD, SR1->R1_HORAS, SR1->R1_VALOR)
						TOTDESC = TOTDESC + SR1->R1_VALOR
					Elseif PosSrv( SR1->R1_PD ,  SRA->RA_FILIAL ,  "RV_TIPOCOD" ) == "3"
						fSomaPd("B", SR1->R1_PD, SR1->R1_HORAS, SR1->R1_VALOR)
					Endif

					SR1->(dbSkip())
				Enddo
				nLiquido := TOTVENC - TOTDESC
			Endif

		Elseif nEsc == 6

			dDtFerIni := cTod("  /  /  ")
			dDtBusFer := cTod("  /  /  ")
			//Busca Data Inicial e Data de Pagamento de F?ias
			fCheckFer('INI') // Busca RH_DATAINI

			If (dDtFerIni >= dDataDe .And. dDtFerIni <= dDataAte)

				// DbSelectArea('SRR')
				// If SRR->(dbSeek( xFilial("SRR", SRA->RA_FILIAL) + SRA->RA_MAT + "F" + dTos(dDtBusFer), .T.))
				If SRR->(dbSeek( xFilial("SRR", SRA->RA_FILIAL) + SRA->RA_MAT + "F" + dTos(dDtFerIni), .T.))

					// 				Do While SRR->(!Eof()) .And. (SRA->RA_FILIAL + SRA->RA_MAT + "F" + dTos(dDtBusFer) ==;
					Do While SRR->(!Eof()) .And. (SRA->RA_FILIAL + SRA->RA_MAT + "F" + dTos(dDtFerIni) ==;
							SRR->RR_FILIAL + SRR->RR_MAT + SRR->RR_TIPO3 + dTos(SRR->RR_DATA))

						If !Eval(cAcessaSRR)
							SRR->(dbSkip())
							Loop
						EndIf

						If SRR->RR_PD # aCodFol[102, 1]

							If PosSrv( SRR->RR_PD ,  SRA->RA_FILIAL ,  "RV_TIPOCOD" ) == "1"
								fSomaPd("P", SRR->RR_PD, SRR->RR_HORAS, SRR->RR_VALOR)
								TOTVENC := TOTVENC + SRR->RR_VALOR
							ElseIf PosSrv( SRR->RR_PD ,  SRA->RA_FILIAL ,  "RV_TIPOCOD" ) == "2"
								fSomaPd("D", SRR->RR_PD, SRR->RR_HORAS, SRR->RR_VALOR)
								TOTDESC := TOTDESC + SRR->RR_VALOR
							Endif

						Endif

						If SRR->RR_PD == aCodFol[013, 1]
							nAteLim += SRR->RR_VALOR
						Elseif SRR->RR_PD == aCodFol[016, 1]
							nBaseIr += SRR->RR_VALOR
						Elseif SRR->RR_PD == aCodFol[102, 1]
							nLiquido := SRR->RR_VALOR
						Endif

						SRR->(dbSkip())

					Enddo
				EndIf
			Endif
		Endif

		// dbSelectArea("SRA")

		If TOTVENC == 0 .And. TOTDESC == 0
			SRA->(dbSkip())
			Loop
		Endif
		/*
		If Vez == 0  .And.  nEsc == 2 //--> Verifica se for FOLHA.
		PerSemana() // Carrega Datas referentes a Semana.
		EndIf
		*/
		nSequenc++

		cDataBas	:= DtoC(SRH->RH_DATABAS)
		cDBaseAt	:= DtoC(SRH->RH_DBASEAT)
		cDFerias	:= Str(SRH->RH_DFERIAS)
		cDAbonPe	:= Str(SRH->RH_DABONPE)

		//H?dados a ser informado
		If lData

			//Verifica Header
			If !lHeader
				// Monta Header de Arquivo - Registro Tipo "0"
				fMonta0()
				// Monta Header de Lote - Registro Tipo "1"
				fMonta1()

				lHeader := .T.
			Endif

			// Monta Header de Lote - Registro Tipo "3" Segmento "A"
			fMonta3A()
			// Monta Header de Lote - Registro Tipo "3" Segmento "D"
			fMonta3D()
			// Monta Header de Lote - Registro Tipo "3" Segmento "E" --> Proventos
			fMonta3E( aProve,  "1" )
			// Monta Header de Lote - Registro Tipo "3" Segmento "E" --> Descontos
			fMonta3E( aDesco,  "2" )
			// Monta Header de Lote - Registro Tipo "3" Segmento "F"
			// fMonta3F(cDataBas, cDBaseAt, cDFerias, cDAbonPe)

			//Verifica Liquidos
			If nLiquido == 0
				nLiquido := TOTVENC-TOTDESC
			EndIf

			If nEsc <> 6
				// Verifica Iconsistencias de Liquidos
				If nLiquido != (TotVenc - TotDesc)
					lLiq := .F.
				EndIf
			EndIf

		Endif

		// dbSelectArea("SRA")

		SRA->(dbSkip())
		TOTDESC := TOTVENC := 0
	EndDo

	//Ha Dados a Serem Gerados
	If lData
		// Monta Trailler de Lote - Registro Tipo "5"
		fMonta5()
		// Monta Trailler de Arquivo - Registro Tipo "9"
		fMonta9()
	Endif


	/* Seleciona arq. defaut do Siga caso Imp. Mov. Anteriores */
	/* If nEsc <> 6
	If !lAtual
		fFimArqMov( cAliasMov ,  aOrdBag ,  cArqMov )
	EndIf
EndIf
	*/
	/* Termino do relatorio */
	// dbSelectArea("SRC")
	// dbSetOrder(1)          // Retorno a ordem 1
	// dbSelectArea("SRI")
	// dbSetOrder(1)          // Retorno a ordem 1
	// dbSelectArea("SRA")
	// SET FILTER TO

	fClose( nHdl )
	If !(Type("cNomeArq") == "U")
		fErase(cNomeArq + OrdBagExt())
	Endif

	MS_FLUSH()

	//If !lAtual
	//	nValSal := 0
	//	fBuscaSlr(@nValSal, MesAno(dDataRef))
	//	If nValSal ==0
	//		nValSal := SRA->RA_SALARIO
	//	EndIf
	//Else
	//	nValSal := SRA->RA_SALARIO
	//EndIf

	// Chamar Relatório
	/* MJ: 16.01.20 - tirei o relatorio neste dia, pois pela 2a. vez constatei que o mesmo esta vindo com informacoes divergencias
nao esta batendo com a rotina de holerite e nem com o CNAB;
	sugeri para o R.H. usar o outro relatorio patrao, Liquido Itau; */
	// GPER150()

Return  // U_MBHoleri()


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                               	   |
 |                                                                       		   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
/*
Static Function PerSemana() // Pesquisa datas referentes a semana.()

	If !Empty(Semana)
	cChaveSem := StrZero(Year(dDataRef), 4)+StrZero(Month(dDataRef), 2)+SRA->RA_TNOTRAB
		If !Srx->(dbSeek(If(cFilial=="  ", "  ", SRA->RA_FILIAL) + "01" + cChaveSem + Semana ,  .T. )) .And. ;
		!Srx->(dbSeek(If(cFilial=="  ", "  ", SRA->RA_FILIAL) + "01" + Subs(cChaveSem, 3, 9) + Semana ,  .T. )) .And. ;
		!Srx->(dbSeek(If(cFilial=="  ", "  ", SRA->RA_FILIAL) + "01" + Left(cChaveSem, 6)+"999"+ Semana ,  .T. )) .And. ;
		!Srx->(dbSeek(If(cFilial=="  ", "  ", SRA->RA_FILIAL) + "01" + Subs(cChaveSem, 3, 4)+"999"+ Semana ,  .T. )) .And. ;
		HELP( " ", 1, "SEMNAOCAD" )
		Return Nil
			Endif

		If Len(AllTrim(SRX->RX_COD)) == 9
		cSem_De  := Transforma(CtoD(Left(SRX->RX_TXT, 8)), "DDMMYY")
		cSem_Ate := Transforma(CtoD(Subs(SRX->RX_TXT, 10, 8)), "DDMMYY")
		Else
		cSem_De  := Transforma(If("/" $ SRX->RX_TXT ,  CtoD(SubStr( SRX->RX_TXT,  1, 10)) ,  StoD(SubStr( SRX->RX_TXT,  1, 8 ))), "DDMMYY")
		cSem_Ate := Transforma(If("/" $ SRX->RX_TXT ,  CtoD(SubStr( SRX->RX_TXT,  12, 10)),  StoD(SubStr( SRX->RX_TXT, 12, 8 ))), "DDMMYY")
		EndIf
	EndIf

Return Nil
*/

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Somar as Verbas no Array                                             |
 |                                                                       		   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function fSomaPd(cTipo, cPd, nHoras, nValor)

	Local Desc_paga

	lData	:= .T.  //H?Dados a serem informados

	Desc_paga := DescPd(cPd, SRA->RA_FILIAL)  // mostra como pagto

	If cTipo #'B'
		//--Array para Recibo Pre-Impresso
		nPos := Ascan(aLanca, { |X| X[2] = cPd })
		If nPos == 0
			Aadd(aLanca, {cTipo, cPd, Desc_Paga, nHoras, nValor})
		Else
			aLanca[nPos, 4] += nHoras
			aLanca[nPos, 5] += nValor
		Endif
	Endif

	//--Array para o Recibo Pre-Impresso
	If cTipo = 'P'
		cArray := "aProve"
	Elseif cTipo = 'D'
		cArray := "aDesco"
	Elseif cTipo = 'B'
		cArray := "aBases"
	Endif

	nPos := Ascan(&cArray, { |X| X[1] = cPd })
	If nPos == 0
		Aadd(&cArray, {cPd+" "+left(Desc_Paga, 19), nHoras, nValor })
	Else
		&cArray[nPos, 2] += nHoras
		&cArray[nPos, 3] += nValor
	Endif

Return


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                               	   |
 |                                                                       		   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function Transforma(dData) //Transforma as datas no formato DD/MM/AAAA()
Return(StrZero(Day(dData), 2) +"/"+ StrZero(Month(dData), 2) +"/"+ Right(Str(Year(dData)), 4))


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                               	   |
 |                                                                       		   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function fConvData( dData,  xTipo )

	Local cRet := Space(08)

	If xTipo == "DDMMAAAA"
		cRet := StrZero(Day(dData), 2) + StrZero(Month(dData), 2) + StrZero(Year(dData), 4)
	ElseIf xTipo == "MMAAAA"
		cRet := StrZero(Month(dData), 2) + StrZero(Year(dData), 4)
	EndIf

Return( cRet )


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                               	   |
 |                                                                       		   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function fCheckFer( xTipo)

	Local aOld := GETAREA()
	Local cRet := Replicate("0", 08)

	/*
	If SRA->RA_SITFOLH == "F"
		If SRF->(dbSeek( SRA->(RA_FILIAL+RA_MAT) ))
			If SRH->(dbSeek( SRA->(RA_FILIAL+RA_MAT)+Dtos(SRF->RF_DATABAS) ))
				If xTipo == "INI"
cRet := fConvData( SRH->RH_DATAINI,  "DDMMAAAA" )
dDtBusFer	:= SRH->RH_DTRECIB
dDtFerIni   := SRH->RH_DATAINI
				ElseIf xTipo == "FIM"
cRet := fConvData( SRH->RH_DATAFIM,  "DDMMAAAA" )
				EndIf
			EndIf
		EndIf
	EndIf
	*/

	//Alterado em 15/10/2007 - Marcos Pereira - Posiciona no SRH utilizando a dDataDe como pesquisa
	//If SRA->RA_SITFOLH $ "F*A"

	If SRA->RA_SITFOLH $ " *F*A" // SRP - 30/04/2008 - Incluido a situação "branco" normal.
		SRH->(dbsetorder(2))
		SRH->(dbSeek( SRA->(RA_FILIAL+RA_MAT)+dtos(dDataDe), .t. ))
		If SRH->(RH_FILIAL+RH_MAT) == SRA->(RA_FILIAL+RA_MAT) .and. SRH->RH_DATAINI <= dDataAte
			If xTipo == "INI"
				cRet := fConvData( SRH->RH_DATAINI,  "DDMMAAAA" )
				dDtBusFer	:= SRH->RH_DTRECIB
				dDtFerIni   := SRH->RH_DATAINI
			ElseIf xTipo == "FIM"
				cRet := fConvData( SRH->RH_DATAFIM,  "DDMMAAAA" )
			EndIf
		EndIf
		SRH->(dbsetorder(1))
	EndIf

	RestArea( aOld )

Return( cRet )


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                               	   |
 |                                                                       		   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function fConvHora( cHora )
	Local cRet := SubStr(cHora, 1, 2)+SubStr(cHora, 4, 2)+SubStr(cHora, 7, 2)
Return( cRet )


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: INICIO DO LAY-OUT DO BANCO ITAU                            		   |
 |            Monta Header de Arquivo - Registro Tipo "0"						   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_MBHoleri()                                                         |
'---------------------------------------------------------------------------------*/
Static Function fMonta0()

	cLin := "341"                  	                        	// 001 a 003 Codigo do Banco
	cLin += "0000"             	                            	// 004 a 007 Codigo do Lote
	cLin += "0"            	                                	// 008 a 008 Tipo do Registro
	cLin += Space(06)   	            	                    // 009 a 014 Brancos
	cLin += "081"                          	                	// 015 a 017 Lay-Out do Arquivo
	cLin += "2"                                	            	// 018 a 018 Tipo Inscricao Empresa
	cLin += STRZERO(VAL(SM0->M0_CGC), 14)                        // 019 a 032 Cnpj Empresa
	cLin += Space(20)                                  	    	// 033 a 052 Brancos
	cLin += StrZero(Val( cCodAgenc ), 5)                   		// 053 a 057 Agencia Debitada
	cLin += Space( 01 )                               			// 058 a 058 Brancos
	cLin += StrZero(Val( cCodConta ), 12)						// 059 a 070 Conta Corrente Debitada
	cLin += Space( 01 )                               			// 071 a 071 Brancos
	cLin += StrZero(Val( cDigConta ), 01)						// 072 a 072 Digito Conta Corrente
	cLin += SUBSTR(SM0->M0_NOMECOM, 1, 30)       					// 073 a 102 Nome da Empresa
	cLin += PadR("BANCO ITAU S/A", 30)                  			// 103 a 132 Nome do Banco
	cLin += Space( 10 )                           	    		// 133 a 142 Brancos
	cLin += "1"                                            		// 143 a 143 Codigo Remessa
	cLin += fConvData( dDataBase,  "DDMMAAAA" )                	// 144 a 151 Data Geracao Arquivo
	cLin += fConvHora( Time() )                             	// 152 a 157 Hora Geracao Arquivo
	cLin += "000000000"                                    		// 158 a 166 Zeros
	cLin += "00000"                                        		// 167 a 171 Densidade de Gravacao
	cLin += Space(69)                                  	    	// 172 a 240 Brancos
	cLin += cEol

	fGravaTxt()

Return

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Monta Header de Lote - Registro Tipo "1"                             |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_MBHoleri()                                                                     |
'---------------------------------------------------------------------------------*/
Static Function fMonta1()

	cLin := "341"                  	                        	// 001 a 003 Codigo do Banco
	cLin += "0001"      	                            		// 004 a 007 Codigo do Lote
	cLin += "1"            	                                	// 008 a 008 Tipo do Registro
	cLin += "C"                        	                    	// 009 a 009 Tipo Operacao "C=Credito"
	cLin += "30"        	            	                    // 010 a 011 Tipo Pagamento "30=Salarios"
	cLin += "01"												// 012 a 013 Forma Pagamento "01=Credito CC"
	cLin += "040"       	            	                    // 014 a 016 Lay-Out do Lote
	cLin += Space(01)                      	                	// 017 a 017 Brancos
	cLin += "2"                                	            	// 018 a 018 Tipo Inscricao Empresa
	cLin += SUBST(SM0->M0_CGC, 1, 14)            	        		// 019 a 032 Cnpj Empresa
	cLin += Space(20)                                  	    	// 033 a 052 Brancos
	cLin += StrZero(Val( cCodAgenc ), 5)                   		// 053 a 057 Agencia Debitada
	cLin += Space( 01 )                               			// 058 a 058 Brancos
	cLin += StrZero(Val( cCodConta ), 12)						// 059 a 070 Conta Corrente Debitada
	cLin += Space( 01 )                               			// 071 a 071 Brancos
	cLin += StrZero(Val( cDigConta ), 01)             			// 072 a 072 Digito Conta Corrente
	cLin += SUBSTR(SM0->M0_NOME, 1, 30)               			// 073 a 102 Nome da Empresa
	cLin += cFinPgt + "PAGAMENTO DE SALARIOS       "        	// 103 a 132 Finalidades do Lote
	cLin += Space(10)                                  	    	// 133 a 142 Historico da CC Debitada
	cLin += SUBSTR(SM0->M0_ENDCOB, 1, 30)               			// 143 a 172 Endereco da Empresa			- 30
	cLin += Space(5)                                       		// 173 a 177 Numero do Endereco				- 05
	cLin += SUBSTR(SM0->M0_BAIRCOB, 1, 15)                   		// 178 a 192 Compl do Endereco				- 15
	cLin += SUBS(SM0->M0_CIDCOB, 1, 20)                      		// 193 a 212 Cidade do Endereco				- 20
	cLin += SUBS(SM0->M0_CEPCOB, 1, 8 )                      		// 213 a 220 Cep do Endereco
	cLin += SUBS(SM0->M0_ESTCOB, 1, 2)                           	// 221 a 222 Estado do Endereco
	cLin += Space(08)                                  	    	// 223 a 230 Brancos
	cLin += Space(10)                                  	    	// 231 a 240 Ocorrencias de Retorno
	cLin += cEol

	fGravaTxt()

Return

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Monta Header de Lote - Registro Tipo "3" Segmento "A"				   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_MBHoleri()                                                         |
'---------------------------------------------------------------------------------*/
Static Function fMonta3A()

	cLin := "341"                  	                        		// 001 a 003 Codigo do Banco
	cLin += "0001"             	                            		// 004 a 007 Codigo do Lote
	cLin += "3"            	                                		// 008 a 008 Tipo do Registro
	cLin += StrZero(nSequenc, 5)           	                    	// 009 a 013 Sequencial de Registros
	cLin += "A"        	            	                    		// 014 a 014 Segmento "A"
	cLin += "000"       	            	                    	// 015 a 017 Tipo Movimento
	cLin += "000"       	            	                    	// 018 a 020 Zeros
	cLin += Left(SRA->RA_BCDEPSA, 3)                         		// 021 a 023 Banco Favorecido
	cLin += "0"						                         		// 024 a 024 Zero						*
	cLin += Subs(SRA->RA_BCDEPSA, 4, 4)	                        	// 025 a 028 Agencia                     *
	cLin += Space(1)		                        				// 029 a 029 Branco                       *
	// cLin += Space(6)                                 				// 030 a 035 Zeros                         *---------->		(Nota 11 - Pag. 47)
	cLin += StrZero(Val(SubS(SRA->RA_CTDEPSA, 1, TamSX3('RA_CTDEPSA')[1]-1)), 12) // StrZero(Val(SRA->RA_CTDEPSA), 6) // 036 a 041 Conta Creditada              *
	cLin += Space(1)                       							// 042 a 042 Branco                      *
	cLin += SubS(SRA->RA_CTDEPSA, -1) // Right(StrZero(Val(SRA->RA_CTDEPSA), 6), 1) // 043 a 043 Digito da Conta Creditada	*
	cLin += Left(SRA->RA_NOME, 30)                      				// 044 a 073 Nome do Favorecido
	cLin += Space(20)					                         	// 074 a 093 Numero do Documento atribuido pela Empresa
	cLin += fConvData( dDataPagto,  "DDMMAAAA" )               		// 094 a 101 Data do Pagamento
	cLin += "REA"                                	            	// 102 a 104 Tipo Moeda
	cLin += Space(8)        	                        			// 105 a 112 Zeros
	cLin += StrZero(0, 7)        	                        		// 113 a 119 Zeros
	cLin += StrZero((nLiquido*100), 15)                        		// 120 a 134 Valor do Pagamento
	// cLin += StrZero((TOTVENC-TOTDESC)*100, 15)                       // 120 a 134 Valor do Pagamento
	cLin += Space(15)                       						// 135 a 149 Nosso Numero
	cLin += Space(05)                      	                		// 150 a 154 Brancos
	cLin += "00000000"                     	                		// 155 a 162 Data Efetivacao Pagto
	cLin += Replicate("0", 15)        	                        	// 163 a 177 Valor Efetivo Pagamento
	cLin += Space(18)                      	                		// 178 a 195 Finalidade Detalhe
	cLin += Space(02)                      	                		// 196 a 197 Brancos
	cLin += Replicate("0", 06)        	                        	// 198 a 203 Numero Documento
	cLin += StrZero(Val(SRA->RA_CIC), 14)                        	// 204 a 217 Numero Inscricao Favorecido
	cLin += Space(02)                      	                		// 218 a 219 Brancos
	cLin += "00010"		                             				// 220 a 224 Finalidade da TED
	cLin += Space(05)                      	                		// 225 a 229 Brancos
	cLin += "0"                                        				// 230 a 230 Aviso ao Favorecido
	cLin += Space(10)                                  	    		// 231 a 240 Ocorrencias de Retorno
	cLin += cEol

	aTotLote[1] ++
	aTotLote[2] += nLiquido // TOTVENC-TOTDESC

	fGravaTxt()

Return

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Monta Header de Lote - Registro Tipo "3" Segmento "D"				   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function fMonta3D()

	Local aArea	:= GetArea()

	cLin := "341"                  	                        	// 001 a 003 Codigo do Banco
	cLin += "0001"             	                            	// 004 a 007 Codigo do Lote
	cLin += "3"            	                                	// 008 a 008 Tipo do Registro
	cLin += StrZero(nSequenc, 5)           	                    // 009 a 013 Sequencial de Registros
	cLin += "D"        	            	                    	// 014 a 014 Segmento "D"
	cLin += Space(03)   	            	                    // 015 a 017 Brancos
	cLin += fConvData( dDataRef,  "MMAAAA" )                		// 018 a 023 Mes/Ano Referencia
	cLin += Left(CTT->CTT_DESC01+Space(15), 15)                    	// 024 a 038 Centro de Custo
	cLin += Left(SRA->RA_MAT+Space(15), 15)                    	// 039 a 053 Matricula
	cLin += Left(SRJ->RJ_DESC+Space(30), 30)                    	// 054 a 083 Funcao
	cLin += fCheckFer( "INI" )                               	// 084 a 091 Periodo Ferias De
	cLin += fCheckFer( "FIM" )                               	// 092 a 099 Periodo Ferias Ate
	cLin += StrZero(Val(SRA->RA_DEPIR), 2)                     	// 100 a 101 Dependentes p/ IR
	cLin += StrZero(Val(SRA->RA_DEPSF), 2)                     	// 102 a 103 Dependentes p/ SF
	cLin += StrZero(Int(SRA->RA_HRSEMAN), 2)                     // 104 a 105 Horas Semanais
	cLin += StrZero((nAteLim*100), 15, 0)                       	// 106 a 120 Salario de Contribuicao
	cLin += StrZero((nFgts*100), 15, 0)                         	// 121 a 135 FGTS
	cLin += StrZero((TOTVENC*100), 15, 0)                       	// 136 a 150 Total dos Proventos
	cLin += StrZero((TOTDESC*100), 15, 0)                       	// 151 a 165 Total dos Descontos
	cLin += StrZero(((TOTVENC-TOTDESC)*100), 15, 0)             	// 166 a 180 Liquido a Pagar
	cLin += StrZero((SRA->RA_SALARIO*100), 15, 0)               	// 181 a 195 Salario Base
	cLin += StrZero((nBaseIr*100), 15, 0)                       	// 196 a 210 Base do IRRF
	cLin += StrZero((nBaseFgts*100), 15, 0)                     	// 211 a 225 Base do IRRF
	cLin += "00"						                        // 226 a 227 Prazo p/ Disponibilizar Holerite
	cLin += Space(03)		                        			// 228 a 230 Brancos
	cLin += Space(10)                                  	    	// 231 a 240 Ocorrencias de Retorno
	cLin += cEol

	aTotLote[1]++

	fGravaTxt()

	RestArea( aArea )

Return


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Monta Header de Lote - Registro Tipo "3" Segmento "E" --> Proventos  |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   : 1-Proventos                                                          |
 |            2-Descontos                                                          |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function fMonta3E( aTemp,  xTipo )

	Local i,  nLen

	// Calcula Quantidade de Proventos
	nLen := Len(aTemp)
	If nLen == 0
		Return
	EndIf
	// Incrementa Contador com Multiplos de 4
	Do While .T.
		If nLen % 4 == 0
			Exit
		EndIf

		nLen++
	EndDo

	// Processa Array
	For i := 1 To nLen
		If i % 4 == 1
			cLin := "341"                  	                    // 001 a 003 Codigo do Banco
			cLin += "0001"             	        				// 004 a 007 Codigo do Lote
			cLin += "3"            	                            // 008 a 008 Tipo do Registro
			cLin += StrZero(nSequenc, 5)        	                // 009 a 013 Sequencial de Registros
			cLin += "E"        	            	                // 014 a 014 Segmento "E"
			cLin += Space(03)   	           	                // 015 a 017 Brancos
			cLin += xTipo                                       // 018 a 018 Tipo do Movimento
		EndIf
		If i <= Len(aTemp)
			//      cLin += Left(aTemp[i, 1]+Space(30), 30)       // 019 a 048 Salario de Contribuicao
			cLin += Left(aTemp[i, 1]+" " + if(aTemp[i, 2]>0, Transform(aTemp[i, 2], "@E 999.99"), space(6))+Space(30), 30) // 019 a 048 Salario de Contribuicao
			cLin += Space(05)                                 	// 049 a 053 Brancos
			cLin += StrZero((aTemp[i, 3]*100), 15, 0)              // 054 a 068 Salario de Contribuicao
		Else
			cLin += Space(30)					                // 019 a 048 Salario de Contribuicao
			cLin += Space(05)                          	       	// 049 a 053 Brancos
			cLin += StrZero(0, 15)					            // 054 a 068 Salario de Contribuicao
		EndIf
		If i % 4 == 0
			cLin += Space(12)                                  	// 219 a 230 Brancos
			cLin += Space(10)                                  	// 231 a 240 Ocorrencias de Retorno
			cLin += cEol

			aTotLote[1]++

			fGravaTxt()
		EndIf
	Next

Return

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function fMonta3F(cDataBas, cDBaseAt, cDFerias, cDAbonPe)

	cLin := "341"                  	                        	// 001 a 003 Codigo do Banco
	cLin += "0001"             	                            	// 004 a 007 Codigo do Lote
	cLin += "3"            	                                	// 008 a 008 Tipo do Registro
	cLin += StrZero(nSequenc, 5)           	                    // 009 a 013 Sequencial de Registros
	cLin += "F"        	            	                    	// 014 a 014 Segmento "F"
	cLin += Space(03)   	            	                    // 015 a 017 Brancos

	If nEsc == 6 //Ferias

		DESC_MSG1 := "Periodo Aquisitivo: "+ cDataBas +" a "+ cDBaseAt

		//Quantidade de dias
		DESC_MSG2 := "Dias de Ferias: "+cDFerias

		//Abono Pecuniario
		DESC_MSG3 := "Dias de Abono Pecuniario: "+cDAbonPe

	EndIf

	cLin += Left(DESC_MSG1+Space(48), 48) 	                    	// 018 a 065 Mensagem 1
	cLin += Left(DESC_MSG2+Space(48), 48) 	                    	// 066 a 113 Mensagem 2
	cLin += Left(DESC_MSG3+Space(48), 48) 	                    	// 114 a 161 Mensagem 3

	cLin += Space(69)                                  	    	// 162 a 230 Brancos
	cLin += Space(10)                                  	    	// 231 a 240 Ocorrencias de Retorno
	cLin += cEol

	aTotLote[1]++

	fGravaTxt()

Return

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Monta Trailler de Lote - Registro Tipo "5"						   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function fMonta5()

	cLin := "341"                  	                        	// 001 a 003 Codigo do Banco
	cLin += "0001"             	                            	// 004 a 007 Codigo do Lote
	cLin += "5"            	                                	// 008 a 008 Tipo do Registro "5"
	cLin += Space(09)                                  	    	// 009 a 017 Brancos
	cLin += StrZero(aTotLote[1]+2, 6)        	                // 018 a 023 Total de Registros do Lote
	cLin += StrZero((aTotLote[2]*100), 18, 0)                   	// 024 a 041 Valor Total do Lote
	cLin += StrZero(0, 18)               	                    // 042 a 059 Zeros
	cLin += Space(171)   	            	                    // 060 a 230 Brancos
	cLin += Space(10)                                  	    	// 231 a 240 Ocorrencias de Retorno
	cLin += cEol

	fGravaTxt()

Return


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Monta Trailler de Arquivo - Registro Tipo "9"                        |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function fMonta9()

	cLin := "341"                  	                        	// 001 a 003 Codigo do Banco
	cLin += "9999"             	                            	// 004 a 007 Codigo do Lote
	cLin += "9"            	                                	// 008 a 008 Tipo do Registro "9"
	cLin += Space(09)                                  	    	// 009 a 017 Brancos
	cLin += "000001"                      	                    	// 018 a 023 Total de Registros do Lote
	cLin += StrZero(aTotLote[1]+4, 6)        	                   	// 024 a 029 Total de Registros do Lote
	cLin += Space(211)   	            	                    	// 030 a 240 Brancos
	cLin += cEol

	fGravaTxt()

Return


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function fGravaTxt()

	If fWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
		MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?", "Atenção!")
	Endif

Return


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Cria fOpcoes para tipos de recibos.                                  |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
User Function fRecibos()

	Local cTitulo	:=	""
	Local MvParDef	:=	""
	Local l1Elem 	:= .T.
	Local MvPar		:= ""
	Local oWnd
	Local cTipoAu

	Private aResul	:={}

	oWnd 	:= GetWndDefault()
	MvPar	:=	&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet	:=	Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

	cTitulo := "Tipos de Recibos"
	aResul  := {"Adiantamento", "Folha", "1a Parcela", "2a Parcela", "Extra", "Ferias"}

	MvParDef:=	"123456"

	f_Opcoes(@MvPar, cTitulo, aResul, MvParDef, 12, 49, l1Elem, , 1)		// Chama funcao f_Opcoes
	&MvRet := mvpar 					   	// Devolve Resultado

Return



/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 29.10.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Verifica a existencia das perguntas criando-as caso seja			   |
 |            necessario (caso nao existam).                             		   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
Static Function fAsrPerg()

	Local _aArea	:= GetArea()
	Local nPergs	:= 0
	Local nX		:= 0
	Local aRegs		:= {}
	Local aHelp		:= {}
	Local aHelpE	:= {}
	Local aHelpI	:= {}
	Local cHelp		:= ""
	Local i			:= 0, j := 0

	//Conta quantas perguntas existem ualmente.
	DbSelectArea('SX1')
	DbSetOrder(1)
	SX1->(DbGoTop())
	If SX1->(DbSeek(cPerg))
		While !SX1->(Eof()) .And. X1_GRUPO = cPerg
			nPergs++
			SX1->(DbSkip())
		EndDo
	EndIf

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs, { cPerg, '01', 'Data de Referencia           ?', 'Data de Referencia           ?', 'Data de Referencia           ?', 'mv_ch1', 'D', 08, 0, 0, 'G', 'NaoVazio'   , 'mv_par01', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })

	aHelp := {	"Informe o tipo de recibo que deseja ", ;
		"emitir. Apenas um tipo de recibo ", ;
		"podera ser selecionado." }
	aHelpE:= {	"Informe o tipo de recibo que deseja ", ;
		"emitir. Apenas um tipo de recibo ", ;
		"podera ser selecionado." }
	aHelpI:= {	"Informe o tipo de recibo que deseja ", ;
		"emitir. Apenas um tipo de recibo ", ;
		"podera ser selecionado." }
	cHelp := ".HOLQIT02."

	aAdd(aRegs, { cPerg, '02', 'Emitir Recibos          ?', 'Emitir Recibos       ?', 'Emitir Recibos        ?', 'MV_CH2', 'C', 06, 0, 0, 'G', 'U_fRecibos()', 'MV_PAR02', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' }) // , '', aHelp  , aHelpI   , aHelpE  , cHelp})
	aAdd(aRegs, { cPerg, '03', 'Numero da Semana        ?', 'Numero da Semana     ?', 'Numero da Semana      ?', 'MV_CH3', 'C', 02, 0, 0, 'G', ''            , 'mv_par03', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })
	aAdd(aRegs, { cPerg, '04', 'Filial De               ?', 'Filial De            ?', 'Filial De             ?', 'MV_CH4', 'C', 02, 0, 0, 'G', ''            , 'mv_par04', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , 'SM0', '' })
	aAdd(aRegs, { cPerg, '05', 'Filial Ate              ?', 'Filial Ate           ?', 'Filial Ate            ?', 'MV_CH5', 'C', 02, 0, 0, 'G', 'NaoVazio'    , 'mv_par05', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , 'SM0', '' })
	aAdd(aRegs, { cPerg, '06', 'Centro Custo De         ?', 'Centro Custo De      ?', 'Centro Custo De       ?', 'MV_CH6', 'C', 09, 0, 0, 'G', ''            , 'mv_par06', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , 'CTT', '' })
	aAdd(aRegs, { cPerg, '07', 'Centro Custo Ate        ?', 'Centro Custo Ate     ?', 'Centro Custo Ate      ?', 'MV_CH7', 'C', 09, 0, 0, 'G', 'NaoVazio'    , 'mv_par07', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , 'CTT', '' })
	aAdd(aRegs, { cPerg, '08', 'Matricula De            ?', 'Matricula De         ?', 'Matricula De          ?', 'MV_CH8', 'C', 06, 0, 0, 'G', ''            , 'mv_par08', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , 'SRA', '' })
	aAdd(aRegs, { cPerg, '09', 'Matricula Ate           ?', 'Matricula Ate        ?', 'Matricula Ate         ?', 'MV_CH9', 'C', 06, 0, 0, 'G', 'NaoVazio'    , 'mv_par09', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , 'SRA', '' })
	aAdd(aRegs, { cPerg, '10', 'Mensagem 1              ?', 'Mensagem 1           ?', 'Mensagem 1            ?', 'MV_CHA', 'C', 01, 0, 0, 'G', ''            , 'mv_par10', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })
	aAdd(aRegs, { cPerg, '11', 'Mensagem 2              ?', 'Mensagem 2           ?', 'Mensagem 2            ?', 'MV_CHB', 'C', 01, 0, 0, 'G', ''            , 'mv_par11', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })
	aAdd(aRegs, { cPerg, '12', 'Mensagem 3              ?', 'Mensagem 3           ?', 'Mensagem 3            ?', 'MV_CHC', 'C', 01, 0, 0, 'G', ''            , 'mv_par12', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })
	aAdd(aRegs, { cPerg, '13', 'Situacoes               ?', 'Situacoes            ?', 'Situacoes             ?', 'MV_CHD', 'C', 05, 0, 0, 'G', 'fSituacao'   , 'mv_par13', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })
	aAdd(aRegs, { cPerg, '14', 'Categorias              ?', 'Categorias           ?', 'Categorias            ?', 'MV_CHE', 'C', 12, 0, 0, 'G', 'fCategoria'  , 'mv_par14', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })
	aAdd(aRegs, { cPerg, '15', 'Arquivo de Saida        ?', 'Arquivo de Saida     ?', 'Arquivo de Saida      ?', 'MV_CHF', 'C',100, 0, 0, 'G', 'NaoVazio'    , 'mv_par15', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })
	aAdd(aRegs, { cPerg, '16', 'Data Para Pagamento     ?', 'Data Para Pagamento  ?', 'Data Para Pagamento   ?', 'MV_CHG', 'D', 08, 0, 0, 'G', 'NaoVazio'    , 'mv_par16', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })
	aAdd(aRegs, { cPerg, '17', 'Banco/Agencia De        ?', 'Banco/Agencia De     ?', 'Banco/Agencia De      ?', 'MV_CHH', 'C', 08, 0, 0, 'G', ''            , 'mv_par17', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , 'SA6', '' })
	aAdd(aRegs, { cPerg, '18', 'Banco/Agencia Ate       ?', 'Banco/Agencia Ate    ?', 'Banco/Agencia Ate     ?', 'MV_CHI', 'C', 08, 0, 0, 'G', 'NaoVazio'    , 'mv_par18', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , 'SA6', '' })
	aAdd(aRegs, { cPerg, '19', 'Conta Corrente De       ?', 'Conta Corrente De    ?', 'Conta Corrente De     ?', 'MV_CHJ', 'C', 12, 0, 0, 'G', ''            , 'mv_par19', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })
	aAdd(aRegs, { cPerg, '20', 'Conta Corrente Ate      ?', 'Conta Corrente Ate   ?', 'Conta Corrente Ate    ?', 'MV_CHK', 'C', 12, 0, 0, 'G', 'NaoVazio'    , 'mv_par20', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })
	aAdd(aRegs, { cPerg, '21', 'Data de Ferias De       ?', 'Data de Ferias De    ?', 'Data de Ferias De     ?', 'MV_CHL', 'D', 08, 0, 0, 'G', ''            , 'mv_par21', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })
	aAdd(aRegs, { cPerg, '22', 'Data de Ferias Ate      ?', 'Data de Ferias Ate   ?', 'Data de Ferias Ate    ?', 'MV_CHM', 'D', 08, 0, 0, 'G', 'NaoVazio'    , 'mv_par22', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })
	// aAdd(aRegs, { cPerg, '23', 'Periodo		?'			  , ''                      , ''                       , 'MV_CHN', 'C', 06, 0, 0, 'G', 'NaoVazio'    , 'mv_par23', ''                 , '', '', '', '', ''                 , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '' })

	// aHelp := {	"Informe o Banco a Ser Gerado do CNAB" }
	// aHelpE:= {  "Informe o Banco a Ser Gerado do CNAB" }
	// aHelpI:= {	"Informe o Banco a Ser Gerado do CNAB" }
	// cHelp := ".HOLCNAB."
	// Aadd(aRegs, {cPerg, '23' , 'CNAB do Banco             ?', 'CNAB do Banco                ?', 'CNAB do Banco                ?', 'mv_chn', 'N', 01, 0, 1, 'C', '            ','mv_par23', ''				 , '', '', '', '', ''				  , '', '', '', '', ''                    , '', '', '', '', ''                 , '', '', '', '', ''        , '', '', '' , '   ', '', '', aHelp  , aHelpI   , aHelpE  , cHelp})

	// ValidPerg(aRegs, cPerg)

	//Se quantidade de perguntas for diferente,  apago todas
	SX1->(DbGoTop())			// U_MBHoleri()
	If nPergs <> Len(aRegs)
		For nX:=1 To nPergs
			If SX1->(DbSeek(cPerg))
				If RecLock('SX1', .F.)
					SX1->(DbDelete())
					SX1->(MsUnlock())
				EndIf
			EndIf
		Next nX
		// EndIf

		// gravação das perguntas na tabela SX1
		// If nPergs <> Len(aRegs)
		dbSelectArea("SX1")
		dbSetOrder(1)
		nTot := Len(aRegs)
		For i := 1 to Len(aRegs)
			If !dbSeek(cPerg+aRegs[i, 2])
				RecLock("SX1", .T.)
				For j := 1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j, aRegs[i, j])
					Endif
				Next j
				MsUnlock()
			EndIf
		Next i
	EndIf

	RestArea(_aArea)

Return nil
//Fim do Programa
/*
U_MBHoleri()
*/

/*
 As funcoes a seguir estao sendo desenvolvidas para o CNAB de pgamento
 pois as variaves privadas nValor e nTotal,  nao estao apresentando os valores liquidos

User Function MBLiqFol(nTam)
Local aArea		:= GetArea()
Local cRet 		:= ""
Default nTam	:= 15

	If At( "FOL",  MV_PAR01)==0
	cRet := nValor
	Else
	// 4 = RC_FILIAL+RC_MAT+RC_PERIODO+RC_ROTEIR+RC_SEMANA+RC_PD
	cRet := Posicione( "SRC",  4,  SRA->RA_FILIAL + SRA->RA_MAT + "201910" + "FOL" + "01" + "799",  "RC_VALOR" )
	cRet := StrZero( cRet*100,  nTam)
	EndIf

RestArea(aArea)
Return cRet


User Function MBTotFol(nTam)
Local aArea		:= GetArea()
Local cRet 		:= ""
Default nTam	:= 18

	If At( "FOL",  MV_PAR01)==0
	// cRet := StrZero( SOMAVALOR(),  nTam)
	cRet := StrZero( nTotal,  nTam)
	Else
	cRet := 1000
	EndIf

RestArea(aArea)
Return cRet
*/


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 05.11.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: P.E. para atualizar as variaveis nValor e nTotal;	                   |
 |            Utilizado no CNAB FOLHA.PAG;                                         |
 |            Pagamento folha de pagamentos.  		                               |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
User Function GP450VAL()
	Local aArea	  := GetArea()
	Local _cVerba := GetMV('MB_VRBAFOL', , "799") // verba folha de pagamento liquido
	Local nAux	  := 0
	If (nAux  := Posicione( "SRC",  4,  SRA->RA_FILIAL +;
			SRA->RA_MAT +;
			SubS(dToS(MV_PAR22), 1, 6) +;
			"FOL" +;
			"01" +;
			_cVerba,  "RC_VALOR" ) * 100) > 0
		nValor := nAux
	EndIf
	RestArea(aArea)
Return .T.



/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 25.11.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Imprimir Relatório;                                                  |
 |                                                                       		   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
User Function GPER150()

	Local oReport
	Local aPosSX1 	    := {}

	Private cDescImpr	:= ""
	Private cAgencia	:= ""
	Private cContacc	:= ""
	Private cDac		:= ""
	Private cAliasSRA	:= "SRA"
	Private dDtPgto		:= CtoD("//")
	Private aInfo		:= Array( 26 )

	Private cProcesso
	Private cRot
	Private aRoteiros	:= {}
	Private lValidFil		:= .T.
	//-- Inicializacao do conteudo de aInfo para a impressao do cabecalho sem informacoes
	//-- quando o filtro realizado nos parametros nao retornar nenhum funcionario.
	Afill(aInfo,"")
	aInfo[15] := 0

	//-- Interface de impressao
	Pergunte("GP0150R",.F.)


	aAdd(aPosSX1, { "GP0150R", "01", "00001" } )					// Processo ? 					// 00001
	If MV_PAR02 == "3"
		aAdd(aPosSX1, { "GP0150R", "02", "131" } )					// Roteiro ?    				// 131
	Else
		aAdd(aPosSX1, { "GP0150R", "02", "FOL" } )					// Roteiro ?    				// 131
	EndIf
	aAdd(aPosSX1, { "GP0150R", "03", SubS(dToS(dDataBase),1,6) } )	// Período De ?                 // 201911
	aAdd(aPosSX1, { "GP0150R", "04", "01" } )						// Nro. Pagamento De ?          // 01
	aAdd(aPosSX1, { "GP0150R", "05", SubS(dToS(dDataBase),1,6) } )	// Período Até ?                // 201911
	aAdd(aPosSX1, { "GP0150R", "06", "01" } )						// Nro. Pagamento Até ?         // 01
	aAdd(aPosSX1, { "GP0150R", "07", MV_PAR04 } )					// Filial De ?                  //
	aAdd(aPosSX1, { "GP0150R", "08", MV_PAR05 } )					// Filial Até ?                 // ZZZZZZ
	aAdd(aPosSX1, { "GP0150R", "09", "                      " } )	// Finalidade Pgto. ?           //
	aAdd(aPosSX1, { "GP0150R", "10", "						" } )   // Centro de Custo De ?         //
	aAdd(aPosSX1, { "GP0150R", "11", "ZZZZZZZZZ             " } )   // Centro de Custo Até ?        // ZZZZZZZZZ
	aAdd(aPosSX1, { "GP0150R", "12", "0203" } )   					// Agência Empresa ?            // 0203
	aAdd(aPosSX1, { "GP0150R", "13", "70650" } )   					// C/C da Empresa ?             // 70650
	aAdd(aPosSX1, { "GP0150R", "14", MV_PAR17 } )   				// Banco/Agência De ?           // 34100000
	aAdd(aPosSX1, { "GP0150R", "15", MV_PAR18 } )   				// Banco/Agência Até ?          // 34199999
	aAdd(aPosSX1, { "GP0150R", "16", MV_PAR08 } )   				// Matricula De ?               //
	aAdd(aPosSX1, { "GP0150R", "17", MV_PAR09 } )   				// Matricula Até ?              // ZZZZZZ
	aAdd(aPosSX1, { "GP0150R", "18", "						" } )   // Nome De ?                    //
	aAdd(aPosSX1, { "GP0150R", "19", "ZZZZZZZZZZZZZZZZZZZZZZ" } )   // Nome Até ?                   // ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
	aAdd(aPosSX1, { "GP0150R", "20", "2" } )   						// D.A.C. da Empresa ?          // 2
	aAdd(aPosSX1, { "GP0150R", "21", "                      " } )   // Conta Corrente De ?          //
	aAdd(aPosSX1, { "GP0150R", "22", "ZZZZZZZZZZZZZZZZZZZZZZ" } )   // Conta Corrente Até ?         // ZZZZZZZZZZZZ
	aAdd(aPosSX1, { "GP0150R", "23", MV_PAR13 				  } )   // Situações ?                  //  A*FT
	aAdd(aPosSX1, { "GP0150R", "24", MV_PAR14 				  } )   // Categorias ?                 // ACDEGHIJMPST***
	aAdd(aPosSX1, { "GP0150R", "25", "                      " } )   // Imprimir ?                   //
	aAdd(aPosSX1, { "GP0150R", "26", "                      " } )   // Finalidade de Pagto ?        //
	aAdd(aPosSX1, { "GP0150R", "27", FirstDate(dDataBase) 	  } )   // Data de Pagamento De ?       // 20191101
	aAdd(aPosSX1, { "GP0150R", "28", LastDate(dDataBase) 	  } )   // Data de Pagamento Até ?      // 20191130
	aAdd(aPosSX1, { "GP0150R", "29", MV_PAR16 				  } )   // Data de Pagamento ?          // 20191129

	U_PosSX1(aPosSX1)

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun?.o    ³ ReportDef³ Autor ³ R.H. - Tatiane Matias ³ Data ³ 30.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ?±±
±±³Descri?.o ³ Definicao do relatorio                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3
	Local oBreak

	Local cDesc	:=	STR0001 + oemtoAnsi(STR0053)  //"Rela?"o Liquidos ITAU    " # Esta rotina efetua a impressao dos valores liquidos que serao pagos atraves do Banco Itau"
	Local aOrd	:= {STR0004,;	//"Filial+Bco+Mat"
		STR0005,;	//"Filial+Bco+Cc+Mat"
		STR0006,;	//"Filial+Bco+Nome"
		STR0007,;	//"Filial+Bco+Cta"
		STR0008,;	//"Filial+Bco+Cc+Nome"
		STR0009,;	//"Bco+Mat"
		STR0010,;	//"Bco+Cc+Mat"
		STR0011,;	//"Bco+Nome"
		STR0012,;	//"Bco+Cta"
		STR0013 }   //"Bco+Cc+Nome"

	//-- Relatorio
	oReport:= TReport():New("GPER150",OemToAnsi(STR0016),"GP0150R",{|oReport| GR150Imp(oReport)}, cDesc)

	oReport:SetTotalInLine(.F.)
	oReport:PageTotalInLine(.F.)
	oReport:PageTotalText(STR0021)
	oReport:PageTotalBefore(.T.)

	//-- Section 1
	//-- Forma Pagto Empresa                        Ag/Conta/Dac   CNPJ           Folha
	//-- ------------------------------------------------------------------------------
	//--   01        											1024/42229 /5                 001
	oSection1:= TRSection():New(oReport,STR0041,{},aOrd)

	//-- Celulas
	TRCell():New(oSection1,"FORMAPAG","   ", oemToAnsi(STR0048),,12,, {|| "01" })									//-- "Forma Pagto"
	TRCell():New(oSection1,"EMPRESA" ,"   ", oemToAnsi(STR0049),,32,, {|| Subs(aInfo[3]+Space(40),1,30) }) 		//-- "Empresa"
	TRCell():New(oSection1,"AGCCDAC" ,"   ", oemToAnsi(STR0050),,15,, {|| cAgencia +"/"+ cContacc +"/"+ cDac })	//-- "Ag/Conta/Dac"
	TRCell():New(oSection1,"CGC"     ,"   ", oemToAnsi(STR0051),,16,, {|| aInfo[8] })								//-- "CNPJ"
	TRCell():New(oSection1,"FOLHA"   ,"   ", oemToAnsi(STR0034),,,, {|| Strzero(oReport:Page(),4) })				//-- "Folha"

	//-- Section 2
	//-- No de Ordem  Data Pgto   Tipo Pgto  Finalidade do Pagamento
	//-- ------------------------------------------------------------
	//--    01        31/12/04     03        PAGAMENTO DE SALARIOS
	oSection2:= TRSection():New(oReport,STR0042,{},aOrd)

	//-- Celulas
	TRCell():New(oSection2,"NORDEM","   ", oemToAnsi(STR0044),,13,, {|| "01" })						//--"No de Ordem"
	TRCell():New(oSection2,"DTPGTO","   ", oemToAnsi(STR0045),,12,, {|| PADR(DtoC(dDtPgto),10) })	//--"Data Pgto"
	TRCell():New(oSection2,"TPPGTO","   ", oemToAnsi(STR0046),,12,, {|| "03" })						//--"Tipo Pgto"
	TRCell():New(oSection2,"FINALID","   ",oemToAnsi(STR0047) ,,,, {|| cDescImpr })					//--"Finalidade do Pagamento"

	//-- Section 3
	oSection3:= TRSection():New(oReport,STR0043,{"SRA"},aOrd)
	oSection3:SetTotalInLine(.F.)

	//-- Celulas
	TRCell():New(oSection3,"RA_NOME","SRA")
	TRCell():New(oSection3,"BANCO"	,"   ", oemToAnsi(STR0050),                        , 20,, {|| Substr( SRA->RA_BCDEPSA,4,5) + "/" + SRA->RA_CTDEPSA})		//--"Agencia/Conta/Dac"
	TRCell():New(oSection3,"VALOR"	,"   ", oemToAnsi(STR0052), "@e 999,999,999,999.99", 17)																		//--"Valor"

	//-- Totalizador
	TRFunction():New(oSection3:Cell("VALOR"),,"SUM",,,,,.F.,.T.,.T.)

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun?.o    ³ GPER150  ³ Autor ³ R.H. - Tatiane Matias ³ Data ³ 30.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ?±±
±±³Descri?.o ³ Relacao Liquidos ITAU - relatorio personalizavel           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GR150Imp(oReport)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis Locais (Programa)                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//-- Objeto
	Local oSection1		:= oReport:Section(1)
	Local oSection2 	:= oReport:Section(2)
	Local oSection3 	:= oReport:Section(3)

	//-- String
	Local cMesArqRef 	:= StrZero(Month(dDataBase),2) + StrZero(Year(dDataBase),4)
	Local cArqMov    	:= ""
	Local cAliasMov 	:= ""
	Local cIndCond		:= ""
	Local cFiltro		:= ""
	Local cParBanco		:= ""
	Local cParConta		:= ""
	Local cCabec1		:= ""
	Local cCabec2		:= ""
	Local cCabec3		:= ""
	Local cSitQuery		:= ""
	Local cCatQuery		:= ""
	Local cOrdem		:= ""
	Local cRCName

	//-- Array
	Local aOrdBag		:= {}
	Local aValBenef  	:= {}
	Local aCodFol    	:= {}

	//-- Numerico
	Local nOrdem		:= oReport:Section(1):GetOrder()
	Local nPos			:= 0
	Local nValor		:= 0
	Local nCntP			:= 0
	Local nReg			:= 0

	Local cTipoCalc		:= ""
	Local cAddVerba		:= ""

	Local nFunBenAmb


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis de Acesso do Usuario                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cAcessaSRA	:= &( " { || " + ChkRH( "GPER150" , "SRA" , "2" ) + " } " )
	Private cAcessaSRC	:= &( " { || " + ChkRH( "GPER150" , "SRC" , "2" ) + " } " )
	Private cAcessaSRD	:= &( " { || " + ChkRH( "GPER150" , "SRD" , "2" ) + " } " )
	Private cAcessaSRG	:= &( " { || " + ChkRH( "GPER150" , "SRG" , "2" ) + " } " )
	Private cAcessaSRH	:= &( " { || " + ChkRH( "GPER150" , "SRH" , "2" ) + " } " )
	Private cAcessaSRR	:= &( " { || " + ChkRH( "GPER150" , "SRR" , "2" ) + " } " )
	//
	Private dDataDe := cToD("//")
	Private dDataAte := cToD("//")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Carrega parametros da pergunte                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cProcesso	:= MV_PAR01
	cRot		:= MV_PAR02
	dPerDe		:= MV_PAR03
	cPagDe		:= MV_PAR04
	dPerAte		:= MV_PAR05
	cPagAte		:= MV_PAR06
	cFilDe		:= MV_PAR07
	cFilAte		:= MV_PAR08
	nFinalPgto	:= MV_PAR09
	cCCDe		:= MV_PAR10
	cCCAte		:= MV_PAR11
	cAgencia	:= MV_PAR12
	cContaCC	:= MV_PAR13
	cBancAgDe	:= MV_PAR14
	cBancAgAte	:= MV_PAR15
	cMatDe		:= MV_PAR16
	cMatAte		:= MV_PAR17
	cNomeDe		:= MV_PAR18
	cNomeAte	:= MV_PAR19
	cDac		:= MV_PAR20
	cCntCorDe	:= MV_PAR21
	cCntCorAte	:= MV_PAR22
	cSituacao	:= MV_PAR23
	cCategoria	:= MV_PAR24
	nFunBenAmb	:= MV_PAR25
	cFinalPgto	:= MV_PAR26
	dDataDe		:= MV_PAR27
	dDataAte	:= MV_PAR28
	dDtPgto		:= MV_PAR29

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Define as celulas da section 4                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nFinalPgto == 1
		oSection3:Cell("BANCO"):Disable()
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Monta os cabecalhos                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCabec1 := STR0024 + "          " + IIf(nFinalPgto == 1, STR0025, STR0026 + "   ") + " " + STR0027

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define se devera ser impresso Funcionarios ou Beneficiarios  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRQ" )
	lImprFunci  := ( nFunBenAmb # 2 )
	lImprBenef  := ( nFunBenAmb # 1 )

	dbSelectArea("SRY")
	If( dbSeek(xFilial("SRY")+cRot) )
		cTipoCalc := SRY->RY_TIPO

		Do Case
			Case cTipoCalc $ "1/9/7" 	// Folha de Pagto
				cAddVerba 	:= fGetCodFol("0047")
				cDescImpr	:= STR0034  //"Folha"
			Case cTipoCalc == "2"  //Adiantamento
				cAddVerba 	:= fGetCodFol("0546")
				cDescImpr	:= STR0033  //"Adiantamento"
			Case cTipoCalc == "3"  // Ferias
				cAddVerba 	:= fGetCodFol("0102")
				cDescImpr	:= STR0037  //"Ferias"
			Case cTipoCalc == "4"  // Rescisao
				cAddVerba	:= fGetCodFol("0126")
				cDescImpr	:= cDescImpr + STR0039  //"Rescisao"
			Case cTipoCalc == "5" .And. cPaisLoc == "BRA"  // 1a parcela 13o Salario
				cAddVerba 	:= fGetCodFol("0678")
				cDescImpr	:= STR0035  //"1a.parc 13º"
			Case cTipoCalc == "6" .Or. cTipoCalc == "5" // 2a parcela 13o Salario
				cAddVerba	:= fGetCodFol("0021")
				cDescImpr	:= STR0036  //"2a.parc 13º"
				If cTipoCalc == "6" .And. cPaisLoc $ "VEN"
					cAddVerba	:= fGetCodFol("1021")
				ElseIf cTipoCalc == "5" .And. cPaisLoc $ "VEN"
					cAddVerba	:= fGetCodFol("1022")
				EndIf
			Case cTipoCalc == "A"  //Aplicacao de Rescisao - Mex
				cAddVerba	:= fGetCodFol("0126")
			Case cTipoCalc == "F"  // PLR
				cAddVerba	:= fGetCodFol("0836")
			Case cTipoCalc == "K"  // Valores Extras
				cAddVerba	:= fGetCodFol("1411")
		EndCase
	EndIf

	If !Empty( cFinalPgto )
		cDescImpr := cFinalPgto
	EndIf

	Aadd(aRoteiros, {cRot, cTipoCalc, cAddVerba} )

	cAliasSRA := GetNextAlias()

	//--Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr("GP0150R")

	//-- Modifica variaveis para a Query
	For nReg:=1 to Len(cSituacao)
		cSitQuery += "'"+Subs(cSituacao,nReg,1)+ "'"
		If ( nReg+1 ) <= Len(cSituacao)
			cSitQuery += ","
		EndIf
	Next nReg
	cSitQuery := "%" + cSitQuery + "%"

	cCatQuery := ""
	For nReg:=1 to Len(cCategoria)
		cCatQuery += "'"+Subs(cCategoria,nReg,1)+ "'"
		If ( nReg+1 ) <= Len(cCategoria)
			cCatQuery += ","
		EndIf
	Next nReg
	cCatQuery := "%" + cCatQuery + "%"

	If !Empty(cFiltro:=oSection3:GetSQLExp())
		cFiltro := "% AND " + cFiltro + "%"
	Else
		cFiltro := "%%"
	EndIf

	If nOrdem == 1
		cOrdem += "%SRA.RA_FILIAL, SRA.RA_BCDEPSA,SRA.RA_MAT%"
	ElseIf nOrdem == 2
		cOrdem += "%SRA.RA_FILIAL, SRA.RA_BCDEPSA, SRA.RA_CC, SRA.RA_MAT%"
	ElseIf nOrdem == 3
		cOrdem += "%SRA.RA_FILIAL, SRA.RA_BCDEPSA, SRA.RA_NOME%"
	Elseif nOrdem == 4
		cOrdem += "%SRA.RA_FILIAl, SRA.RA_BCDEPSA, SRA.RA_CTDEPSA%"
	ElseIf nOrdem == 5
		cOrdem += "%SRA.RA_FILIAL, SRA.RA_BCDEPSA, SRA.RA_CC, SRA.RA_NOME%"
	ElseIf nOrdem == 6
		cOrdem += "%SRA.RA_BCDEPSA, SRA.RA_MAT%"
	ElseIf nOrdem == 7
		cOrdem += "%SRA.RA_BCDEPSA, SRA.RA_CC, SRA.RA_Mat%"
	Elseif nOrdem == 8
		cOrdem += "%SRA.RA_BCDEPSA, SRA.RA_NOME%"
	ElseIf nOrdem == 9
		cOrdem += "%SRA.RA_BCDEPSA, SRA.RA_CTDEPSA%"
	ElseIf nOrdem == 10
		cOrdem += "%SRA.RA_BCDEPSA, SRA.RA_CC, SRA.RA_NOME%"
	EndIf

	dbSelectArea( "SRA" )

	oSection1:BeginQuery()

	BeginSql alias cAliasSRA
		SELECT
			SRA.*
		FROM
			%table:SRA% SRA
		WHERE
			SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%)
			AND SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%)
			AND SRA.RA_PROCES = %exp:cProcesso%
			AND SRA.RA_FILIAL >= %exp:cFilDe%
			AND SRA.RA_FILIAL <= %exp:cFilAte%
			AND SRA.RA_CC >= %exp:cCCDe%
			AND SRA.RA_CC <= %exp:cCCAte%
			AND SRA.RA_NOME >= %exp:cNomeDe%
			AND SRA.RA_NOME <= %exp:cNomeAte%
			AND SRA.RA_MAT >= %exp:cMatDe%
			AND SRA.RA_MAT <= %exp:cMatAte%
			AND SRA.RA_BCDEPSA >= %exp:cBancAgDe%
			AND SRA.RA_BCDEPSA <= %exp:cBancAgAte%
			AND SRA.RA_CTDEPSA >= %exp:cCntCorDe%
			AND SRA.RA_CTDEPSA <= %exp:cCntCorAte%
			AND SRA.%notDel% %exp:cFiltro%
		ORDER BY
			%exp:cOrdem%
	EndSql

	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
	oSection1:EndQuery()
	//->Verificar-> oSection1:EndQuery({mv_par13,mv_par14,mv_par15,mv_par16,mv_par17,mv_par18})

	oSection2:SetParentQuery()
	oSection3:SetParentQuery()

	FilAnt   := Space(FWGETTAMFILIAL)

	//-- Define o total da regua da tela de processamento do relatorio
	oReport:SetMeter((cAliasSRA)->( RecCount() ))

	oReport:OnPageBreak({|| fCabec(oReport,cCabec1)})

	//-- Rodape
	oReport:SetPageFooter(3,{|| oReport:PrintText(STR0040), oReport:PrintText(STR0019), oReport:PrintText(STR0020) }, .F.)

	//-- Incializa impressão
	oSection3:Init()

	//Impressao de cada funcionario e seus beneficiarios
	While (cAliasSRA)->( !EOF() )

		//-- Incrementa a régua da tela de processamento do relatório
		oReport:IncMeter()

		//-- Verifica se o usuário cancelou a impressão do relatorio
		If oReport:Cancel()
			Exit
		EndIf

		nValor    := 0
		aValBenef := {}

		If	(cAliasSRA)->RA_FILIAL # FilAnt
			If	!FP_CODFOL(@aCodFol,(cAliasSRA)->RA_FILIAL) .Or. !fInfo(@aInfo,(cAliasSRA)->RA_FILIAL)
				Exit
			EndIf

			lValidFil := .T.

			FilAnt := (cAliasSRA)->RA_FILIAL

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste controle de acessos e filiais validas               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !((cAliasSRA)->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
				(cAliasSRA)->( dbSkip() )
				lValidFil := .F.
				Loop
			EndIf
		EndIf

		If !lValidFil
			(cAliasSRA)->( dbSkip() )
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciono a matric.no SRA quando estiver usando Top Connect  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRA->(RA_FILIAL+RA_MAT) != (cAliasSRA)->(RA_FILIAL+RA_MAT)
			SRA->(DbSetOrder(1))
			SRA->(DbSeek((cAliasSRA)->(RA_FILIAL+RA_MAT)))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca os valores de Liquido e Beneficios                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cRCName := If( Empty(cAliasMov)	, NIL, cArqMov	)

		Gp020BuscaLiq(@nValor, @aValBenef, cAddVerba)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste parametros de banco e conta do beneficiario 		 ³
		//³ aValBenef: 1-Nome  2-Banco  3-Conta  4-Verba  5-Valor  6-CPF ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//-- Para fazer o aEval no array aBenefCop, foi preciso criar os campos com
		//-- X[2] ou X[3] ou .T., caso esteja vazio.
		//-- Ex: (X[3] >= "000000000001" .AND. X[3] <= "999999999999")
		//-- ou
		//-- (.T. .AND. X[3] <= "999999999999")

		If Len(aValBenef) > 0
			aBenefCop  := aClone(aValBenef)
			aValBenef  := {}

			If !Empty(cBancAgDe)
				cBAD := 'X[2] >= "' + cBancAgDe + '"'
			Else
				cBAD := '.T.'
			EndIf

			If !Empty(cBancAgAte)
				cBAA := 'X[2] <= "' + cBancAgAte + '"'
			Else
				cBAA := '.T.'
			EndIf

			If !Empty(cCntCorDe)
				cCCD := 'X[3] >= "' + cCntCorDe + '"'
			Else
				cCCD := '.T.'
			EndIf

			If !Empty(cCntCorAte)
				cCCA := 'X[3] <= "' + cCntCorAte + '"'
			Else
				cCCA := '.T.'
			EndIf

			&('Aeval(aBenefCop, { |X| If( ('+cBAD+' .AND. '+cBAA+') .And. ( '+cCCD+' .AND. '+cCCA+'), AADD(aValBenef, X), "" ) })')

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 1- Testa Situacao do Funcionario na Folha                    ³
		//³ 2- Testa Categoria do Funcionario na Folha                   ³
		//³ 3- Testa  se Valor == 0                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( nValor == 0 .And. Len(aValBenef) == 0 )
			(cAliasSRA)->( dbSkip() )
			Loop
		Endif

		//-- Atualiza campo valor
		oSection3:Cell("VALOR"):SetValue(nValor)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime a linha                                        		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection3:PrintLine()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao dos Beneficiarios                          		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntP := 1 To Len(aValBenef)
			If !Empty(aValBenef[nCntP,1]) .And. aValBenef[nCntP,5] > 0

				//-- Atualiza campo valor
				oSection3:Cell("RA_NOME"):SetValue("- " + aValBenef[nCntP,1])
				oSection3:Cell("VALOR"):SetValue(aValBenef[nCntP,5])
				If nFinalPgto <> 1
					oSection3:Cell("BANCO"):SetValue(Substr(aValBenef[nCntP,2],4,5) + "/" + aValBenef[nCntP,3])
				EndIf

				oSection3:PrintLine()

				oSection3:Cell("RA_NOME"):SetValue()
				oSection3:Cell("BANCO"):SetValue()
				oSection3:Cell("BANCO"):SetBlock({|| Substr( (cAliasSRA)->RA_BCDEPSA,4,5) + "/" +(cAliasSRA)->RA_CTDEPSA})
				oSection3:Cell("VALOR"):SetValue()

			EndIf
		Next nCntP

		(cAliasSRA)->( dbSkip() )
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza impressao inicializada pelo metodo Init             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection3:Finish()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Termino do relatorio                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRA" )

	Set Filter To
	RetIndex( "SRA" )
	dbSetOrder(1)

Return NIL

Static Function fCabec(oReport, cCabec1)

	Local oSection1 	:= oReport:Section(1)
	Local oSection2 	:= oReport:Section(2)

	If lValidFil
		oReport:PrintText(cCabec1)
		oReport:ThinLine()
		oSection1:Init()
		oSection1:PrintLine()
		oSection1:Finish()
		oSection2:Init()
		oSection2:PrintLine()
		oSection2:Finish()
		oReport:SkipLine()
	Endif

Return NIL
