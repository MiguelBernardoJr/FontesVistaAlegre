#INCLUDE "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "RWMAKE.CH"
#include "Fileio.ch"
#include "tbiconn.ch"
#INCLUDE "DBINFO.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "mntutil_os.CH"

Static lIntegES := SuperGetMV( 'MV_NGMNTES', .F., 'N' ) == 'S'
Static lHistEst := SuperGetMV( 'MV_NGHISES', .F., 'N' ) == 'S'

Static cQrySldSB2 
Static cQrySldSBF

//-----------------------------------------------------------------
// Fonte destinado apenas as funções que tenham relação com O.S
// Ex.: Manutenção, Insumos, Estoque/Compra, verificação de O.S,
// etc. Antes de adicionar uma função aqui, verifique se atende
// a este requisito.
//-----------------------------------------------------------------

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGDATHOSTL³ Autor ³In cio Luiz Kolling    ³ Data ³11/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calula a data e hora real inicio e fim da O.S. ( STL )      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVORDEM   - N£mero da ordem de servico         - Obrigatorio³±±
±±³          ³cVPLANO   - N£mero do plano                    - Obrigatorio³±±
±±³          ³lSAIDA    - Indica se a sa¡da de erro na tela  - Obrigatorio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ SE lSAIDA = .T.                                            ³±±
±±³          ³    .T. /ou .F.                                             ³±±
±±³          ³ SENAO                                                      ³±±
±±³          ³    vDATAHOR   Onde:                                        ³±±
±±³          ³    SE  vDATAHOR[1] = .T.                                   ³±±
±±³          ³        Sem problema                                        ³±±
±±³          ³        vDATAHOR[3] = Data real inicio                      ³±±
±±³          ³        vDATAHOR[4] = Hora real inicio                      ³±±
±±³          ³        vDATAHOR[5] = Data real fim                         ³±±
±±³          ³        vDATAHOR[6] = Hora real fim                         ³±±
±±³          ³    SENAO                                                   ³±±
±±³          ³       Problema                                             ³±±
±±³          ³       vDATAHOR[2] = Mensagem do problema                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGDATHOSTL(cVORDEM,cVPLANO,lSAIDA)
	Local cALIOLD := Alias(), nINDEOL := IndexOrd()
	Local dMINSTL,dMAXSTL,hMINSTL,hMAXSTL
	Local lSEQUEN0 := .T.
	Local vDATAHOR := {}
	Local cMENSAGE := Space(1)

	Store Ctod('  /  /  ') To dMINSTL,dMAXSTL
	Store '  :  '          To hMINSTL,hMAXSTL

	DbselectArea("STJ")
	DbSetOrder(1)
	If !DbSeek(xFilial("STJ")+cVORDEM+cVPLANO)
		cMENSAGE := STR0001+cVORDEM // //"Ordem de servico nao cadastrada "
	Endif
	If Empty(cMENSAGE)
		If stj->tj_situaca == "C"
			cMENSAGE := STR0002+cVORDEM // //"Ordem de servico cancelada "
		Endif
	Endif
	If Empty(cMENSAGE)
		If stj->tj_situaca == "P"
			cMENSAGE := STR0003+cVORDEM // //"Ordem de servico nao foi liberada "
		Endif
	Endif

	If Empty(cMENSAGE)

		DbselectArea("STL")
		dbSetOrder(1)
		If !DbSeek(xFilial("STL")+cVORDEM+cVPLANO)

			/*O P.E. já foi executado no MNTA400, então não há necessidade
			de executar novamente.
			Se não possuir o P.E. NGSEMINS deverá apresentar a mensagem informando
			que não possui item(insumo) na OS.*/
			If !ExistBlock("NGSEMINS")
				cMENSAGE := STR0004+cVORDEM // //"Nao existem itens para a ordem de servico "
			Else
				dMINSTL := CTOD("  /  /  ")
				hMINSTL := "  :  "
				dMAXSTL := CTOD("  /  /  ")
				hMAXSTL := "  :  "
			EndIf
		Else
			While !Eof() .And. STL->TL_FILIAL == xFILIAL("STL") .And. STL->TL_ORDEM == cVORDEM
				If Alltrim(STL->TL_SEQRELA) <> "0" .AND. STL->TL_TIPOREG != "P"
					If lSEQUEN0
						dMINSTL := STL->TL_DTINICI
						hMINSTL := STL->TL_HOINICI
						dMAXSTL := STL->TL_DTFIM
						hMAXSTL := STL->TL_HOFIM

						lSEQUEN0 := .f.
					Endif

					If STL->TL_DTINICI < dMINSTL
						dMINSTL := STL->TL_DTINICI
						hMINSTL := STL->TL_HOINICI
					ElseIf STL->TL_DTINICI = dMINSTL
						hMINSTL := If(STL->TL_HOINICI < hMINSTL,STL->TL_HOINICI,hMINSTL)
					Endif

					If STL->TL_DTFIM > dMAXSTL
						dMAXSTL := STL->TL_DTFIM
						hMAXSTL := STL->TL_HOFIM
					Elseif STL->TL_DTFIM = dMAXSTL
						dMAXSTL := If(STL->TL_DTFIM > dMAXSTL,STL->TL_DTFIM,dMAXSTL)
						hMAXSTL := If(STL->TL_HOFIM > hMAXSTL,STL->TL_HOFIM,hMAXSTL)
					Endif
				Endif
				dbSelectArea("STL")
				dbSkip()
			End
		Endif
	Endif
	vDATAHOR := If(Empty(cMENSAGE),{.t.,' ',dMINSTL,hMINSTL,dMAXSTL,hMAXSTL},;
	{.f.,cMENSAGE})
	If lSAIDA
		If !vDATAHOR[1]
			MsgInfo(cMENSAGE,STR0005) //"NAO CONFORMIDADE"
			DbSelectArea(cALIOLD)
			DbSetOrder(nINDEOL)
			Return vDATAHOR
			// Return .f.
		Endif
	Endif
	DbselectArea(cALIOLD)
	DbSetOrder(nINDEOL)
Return vDATAHOR

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGREFMST9 ³ Autor ³Incaio Luiz Kolling    ³ Data ³14/09/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o ST9                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³NGREFMOVR                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGREFMST9()
	Dbselectarea("ST9")
	Dbsetorder(1)
	If Dbseek(cFilST9+STP->TP_CODBEM)
		RecLock("ST9",.f.)
		ST9->T9_DTULTAC := STP->TP_DTLEITU
		ST9->T9_POSCONT := STP->TP_POSCONT
		ST9->T9_VARDIA  := STP->TP_VARDIA

		If ST9->T9_UNGARAN == 'K'
			nINCREM := ST9->T9_PRGARAN / ST9->T9_VARDIA
			ST9->T9_DTGARAN := NGPROXMDT(ST9->T9_DTCOMPR,'D',nINCREM)
		EndIf

		ST9->T9_VIRADAS := STP->TP_VIRACON
		ST9->T9_CONTACU := STP->TP_ACUMCON
		MsUnLock("ST9")
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGDATHOPR ³ Autor ³Elisangela Costa       ³ Data ³21/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica e retorna a menor data/hora e maior data/hora      ³±±
±±³          ³contida na getdados de inusmos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVORDEM   - N£mero da ordem de servico         - Obrigatorio³±±
±±³          ³cVPLANO   - N£mero do plano                    - Obrigatorio³±±
±±³          ³aVHEADER  - Array com os nome dos campos       - Obrigatorio³±±
±±³          ³aVCOLS    - Array com os valores dos campos    - Obrigatorio³±±
±±³          ³lSAIDA    - Indica se a sa¡da de erro na tela  - Obrigatorio³±±
±±³          ³lPDR      - Indica que tem somente insumo prev.- Obrigatorio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ SE lSAIDA = .T.                                            ³±±
±±³          ³    .T. /ou .F.                                             ³±±
±±³          ³ SENAO                                                      ³±±
±±³          ³    vDATAHOR   Onde:                                        ³±±
±±³          ³    SE  vDATAHOR[1] = .T.                                   ³±±
±±³          ³        Sem problema                                        ³±±
±±³          ³        vDATAHOR[3] = Data real inicio                      ³±±
±±³          ³        vDATAHOR[4] = Hora real inicio                      ³±±
±±³          ³        vDATAHOR[5] = Data real fim                         ³±±
±±³          ³        vDATAHOR[6] = Hora real fim                         ³±±
±±³          ³    SENAO                                                   ³±±
±±³          ³       Problema                                             ³±±
±±³          ³       vDATAHOR[2] = Mensagem do problema                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGDATHOPR(cVORDEM,cVPLANO,aVHEADER,aVCOLS,lSAIDA,lPDR)
	Local cALIOLD  := Alias(),xn
	Local nINDEOL  := IndexOrd()
	Local dMINSTL  := CtoD("31/12/35")
	Local hMINSTL  := "23:59"
	Local dMAXSTL  := CtoD("  /  /  ")
	Local hMAXSTL  := "00:01"
	Local hMINPSTL := "23:59"
	Local vDATAHOR := {}
	Local cMENSAGE := Space(1)
	Local lSEQUEN0 := .T.
	Local nTI      := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_TIPOREG" })
	Local nCO      := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_CODIGO" })
	Local nQU      := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_QUANTID" })
	Local nUN      := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_UNIDADE" })
	Local nDI      := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_DTINICI" })
	Local nHO      := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_HOINICI" })
	Local nDFIM    := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_DTFIM" })
	Local nHOFI    := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_HOFIM" })

	DbselectArea("STJ")
	DbSetOrder(1)
	If !DbSeek(xFilial("STJ")+cVORDEM+cVPLANO)
		cMENSAGE := STR0001+cVORDEM  //"Ordem de servico nao cadastrada "
	Endif
	If Empty(cMENSAGE)
		If stj->tj_situaca == "C"
			cMENSAGE := STR0002+cVORDEM  //"Ordem de servico cancelada "
		Endif
	Endif
	If Empty(cMENSAGE)
		If stj->tj_situaca == "P"
			cMENSAGE := STR0003 //"Ordem de servico nao foi liberada "+cVORDEM
		Endif
	Endif

	If Empty(cMENSAGE)
		If Len(aVCOLS) = 0 .And. lPDR
			cMENSAGE := STR0004+cVORDEM  //"Nao existem itens para a ordem de servico "
		Endif
		If Empty(cMENSAGE)
			If nTI = 0 .Or. nCO = 0 .Or. nQU = 0 .Or. nUN = 0;
			.Or. nDI = 0 .Or. nHO = 0 .And. lPDR
				cMENSAGE := STR0004+cVORDEM  //"Nao existem itens para a ordem de servico "
			Else
				For xn := 1 To Len(aVCOLS)
					If !aVCOLS[xn][Len(aVCOLS[xn])]
						If lSEQUEN0
							dMINSTL := aVCOLS[xn][nDI]
							hMINSTL := aVCOLS[xn][nHO]
							dMAXSTL := If(aVCOLS[xn][nTI] == "P",aVCOLS[xn][nDI],aVCOLS[xn][nDFIM])
							hMAXSTL := If(aVCOLS[xn][nTI] == "P",aVCOLS[xn][nHO],aVCOLS[xn][nHOFI])
							lSEQUEN0 := .f.
						Endif
						If aVCOLS[xn][nDI] < dMINSTL
							dMINSTL := aVCOLS[xn][nDI]
							hMINSTL := aVCOLS[xn][nHO]
						ElseIf aVCOLS[xn][nDI] = dMINSTL
							hMINSTL := If(aVCOLS[xn][nHO] < hMINSTL, aVCOLS[xn][nHO],hMINSTL)
						Endif

						dMAXF := If(aVCOLS[xn][nTI] == "P",aVCOLS[xn][nDI],aVCOLS[xn][nDFIM])
						hMAXF := If(aVCOLS[xn][nTI] == "P",aVCOLS[xn][nHO],aVCOLS[xn][nHOFI])
						If dMAXF > dMAXSTL
							dMAXSTL := dMAXF
							hMAXSTL := hMAXF
						Elseif dMAXF = dMAXSTL
							dMAXSTL := If(dMAXF > dMAXSTL,dMAXF,dMAXSTL)
							hMAXSTL := If(hMAXF > hMAXSTL,hMAXF,hMAXSTL)
						Endif
					Endif
				Next xn
			Endif
		Endif
	Endif
	vDATAHOR := If(Empty(cMENSAGE),{.t.,' ',dMINSTL,hMINSTL,dMAXSTL,hMAXSTL},;
	{.f.,cMENSAGE})
	If lSAIDA
		If !vDATAHOR[1]
			MsgInfo(cMENSAGE,STR0005) //"NAO CONFORMIDADE"
			DbSelectArea(cALIOLD)
			DbSetOrder(nINDEOL)
			Return .f.
		Endif
	Endif
	DbSelectArea(cALIOLD)
	DbSetOrder(nINDEOL)
Return vDATAHOR

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGMNTOSCO ³ Autor ³Marcos Wagner Junior   ³ Data ³05/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se ja existe O.S. aberta para o mesmo dia/servico  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTipoOS    - Tipo da O.S. -> 'B' ou 'L'        - Obrigatorio³±±
±±³          ³cCodBemSTJ - Codigo do Bem                     - Obrigatorio³±±
±±³          ³cServSTJ   - Codigo do Servico                 - Obrigatorio³±±
±±³          ³dDataOrSTJ - Data de Origem                    - Obrigatorio³±±
±±³          ³cPlanoSTJ  - Plano da O.S.                     - Obrigatorio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ _lOK = .f. (a O.S. nao sera aberta                         ³±±
±±³          ³ _lOK = .t. (a O.S. sera aberta                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGMNTOSCO(cTipoOS,cCodBemSTJ,cServSTJ,dDataOrSTJ,cPlanoSTJ,nItemX)

	Local nRecnoSTJ := 0,nDiasD := 0
	Local _lOK := .t.
	Local cMNTOSCO := GETMV("MV_MNTOSCO")
	Local nNGOSPRO := GETMV("MV_NGOSPRO")
	Local lInterdt := If(nNGOSPRO = Nil .Or. nNGOSPRO = 0,.f.,.t.)

	If cMNTOSCO = "B"
		DbSelectArea( "STJ" )
		Set Filter to
		DbSetOrder(12)
		If DbSeek(xFilial("STJ")+cTipoOS+cCodBemSTJ+'N')
			nRecnoSTJ := Recno()
		Endif
		While !Eof() .And. STJ->TJ_FILIAL == xFilial("STJ") .And. STJ->TJ_TIPOOS = cTipoOS;
		.And. STJ->TJ_CODBEM = cCodBemSTJ .AND. STJ->TJ_TERMINO = 'N'
			If STJ->TJ_DTORIGI == dDataOrSTJ .And. STJ->TJ_SITUACA = "L" .And. nRecnoSTJ != Recno()
				_lOK := .F.
				Exit
			EndIf
			If lInterdt
				If STJ->TJ_SITUACA = "L" .And. nRecnoSTJ != Recno()
					nDiasD := STJ->TJ_DTORIGI - dDataOrSTJ
					If nDiasD > 0
						If nDiasD <= nNGOSPRO
							_lOK := .F.
							Exit
						EndIf
					Endif
				Endif
			Endif
			DbSkip()
		End
	ElseIf cMNTOSCO = "N"
		DbSelectArea( "STJ" )
		Set Filter to
		DbSetOrder(2)
		DbSeek(xFilial("STJ")+cTipoOS+cCodBemSTJ+cServSTJ)
		While !Eof() .And. STJ->TJ_FILIAL == xFilial("STJ") .And.;
		STJ->TJ_TIPOOS = cTipoOS .And. STJ->TJ_CODBEM = cCodBemSTJ;
		.And. STJ->TJ_SERVICO = cServSTJ

			If STJ->TJ_TERMINO == "N" .And.  &(cPlanoSTJ) .And.;
			STJ->TJ_DTORIGI == dDataOrSTJ .And. STJ->TJ_SITUACA = "L" .And. nRecnoSTJ != Recno()
				_lOK := .F.
				Exit
			EndIf
			If lInterdt
				If STJ->TJ_TERMINO == "N" .And. STJ->TJ_SITUACA = "L" .And. &(cPlanoSTJ) .And. nRecnoSTJ != Recno()
					nDiasD := STJ->TJ_DTORIGI - dDataOrSTJ
					If nDiasD > 0
						If nDiasD <= nNGOSPRO
							_lOK := .F.
							Exit
						EndIf
					Endif
				Endif
			Endif
			DbSkip()
		End
	Endif

	If !_lOK
		cMMensa := If(nDiasD > 0,If(lInterdt,STR0008+" "+Alltrim(Str(nDiasD,4))+" "+STR0009+If(nDiasD > 1,"s"," ")," ")," ")
		If cMNTOSCO == "N"
			Help(" ",1,"MANJAEXIST",,IIF(!Empty(nItemX),STR0007+' '+STR(nItemX,2),'')+CRLF+cMMensa,3,1) //"Já existe uma Ordem de Serviço para esta data, para o mesmo Bem."
		Else
			Help(" ",1,"NGATENCAO",,STR0006+' '+IIF(!Empty(nItemX),STR0007+' '+STR(nItemX,2),'')+CRLF+cMMensa,3,1) //"Já existe uma Ordem de Serviço para esta data, para o mesmo Bem."
		Endif
	EndIf

Return _lOK

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGPREVBSS ³ Autor ³Evaldo Cevinscki Jr.   ³ Data ³19/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checa se ja existe preventiva para o mesmo bem,servico e seq³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTipoOS    - Tipo da O.S. -> 'B' ou 'L'        - Obrigatorio³±±
±±³          ³cCodBemSTJ - Codigo do Bem                     - Obrigatorio³±±
±±³          ³cServSTJ   - Codigo do Servico                 - Obrigatorio³±±
±±³          ³dDataOrSTJ - Data de Origem                    - Obrigatorio³±±
±±³          ³cPlanoSTJ  - Plano da O.S.                     - Obrigatorio³±±
±±³          ³lMsg       - Mensagem na Tela                  - Obrigatorio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ _lRet = .f. (a O.S. nao sera aberta                        ³±±
±±³          ³ _lRet = .t. (a O.S. sera aberta                            ³±±
±±³          ³ _lRet e !lMsg, retorna string                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPREVBSS(cTipoOS,cCodBemSTJ,cServSTJ,dDataOrSTJ,cSeqRel,lMsg)

	Local nRecnoSTJ := 0
	Local _lRet     :=  .t.
	Local _cRet     := " "
	Local lTemOS    :=  .f.

	// Verifica o parametro se permite abrir uma O.S. para mesmo bem/serviço/sequencia
	If SuperGetMV( 'MV_NGNOVOS', .F., '2' ) == '1'

		DbSelectArea( "STJ" )
		DbSetOrder(2)
		If DbSeek(xFilial("STJ")+cTipoOS+cCodBemSTJ+cServSTJ+cSeqRel)
			nRecnoSTJ := Recno()
		Endif
		cAliasQry := GetNextAlias()

		cQuery := " SELECT TJ_FILIAL,TJ_ORDEM,TJ_PLANO "
		cQuery += " FROM " + RetSqlName("STJ") + ""
		cQuery += " WHERE TJ_FILIAL = '"+xFilial("STJ")+"' AND TJ_TIPOOS = '"+cTipoOS+"' "
		cQuery += " AND TJ_CODBEM = '"+cCodBemSTJ+"' AND TJ_SERVICO = '"+cServSTJ+"' "
		cQuery += " AND TJ_DTORIGI = '"+DtoS(dDataOrSTJ)+"' AND TJ_TERMINO = 'N' AND TJ_SITUACA = 'L' "
		cQuery += " AND TJ_SEQRELA = '"+cSeqRel+"' AND R_E_C_N_O_ <> "+AllTrim(Str(nRecnoSTJ))+" AND D_E_L_E_T_<>'*'"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		While !Eof()
			lTemOS :=  .t.
			DbSelectArea(cAliasQry)
			DbSkip()
		End
		(cALIASQRY)->(dbCloseArea())

		If lTemOS
			If lMsg
				MsgInfo(STR0006,STR0005) //"Já existe uma Ordem de Serviço para esta data, para o mesmo Bem."
				_lRet := .f.
			Else
				_cRet := STR0006
			EndIf
		EndIf

		dbSelectArea("STJ")

	EndIf

Return If(lMsg,_lRet,_cRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} NGPROXMANC
Retorna a Data da proxima Manutencao por contador 

@type Function
@version undefined
@author Paulo Pego
@since 24/05/99
@param dULTACO, data, Data do Ultimo Acomponhamento[DEFAULT=Data Sist.]
@param nCONTAD, numerico, Posicao do contador na Ultima manutencao   
@param nINCREM, numerico, Incremento da Manutencao.  
@param nCONTAC, numerico, Acomulador do Contador.  
@param nVARDIA, numerico, Variacao do contador. 
@param dDtUltMan, data, data da última manutenção.
@param cBem, caractere, codigo do bem.

@return data, Data da proxima manutencao prevista
/*/ 
//------------------------------------------------------------------------------
Function NGPROXMANC(dULTACO,nCONTAD,nINCREM,nCONTAC,nVARDIA,dDtUltMan,cBem)

	Local dRetC   := dDATABASE
	Local nPROX   := nCONTAD+nINCREM
	Local nPOSPO
	Local cVALOR
	Local nINCDAT
	Local nIncLim := cTOD('31/12/1899') - dULTACO
	Local nRetc   := (nPROX - nCONTAC) / nVARDIA,nINTEI := Int(nRetc)
	Local nRESTO  := If(nINTEI < 0,nRetc*-1,nRetc) - If(nINTEI < 0,nINTEI*-1,nINTEI)
	Store 0 To nPOSPO,nINCDAT

	Default dDtUltMan := dDatabase
	Default cBem      := ''

	If Empty(nCONTAD) .or. Empty(nVARDIA) .or. Empty(nINCREM) .or. Empty(nCONTAC)
		Return dRetC
	EndIf

	If nRESTO > 0
		cVALOR := Alltrim(Str(nRESTO))
		nPOSPO := At('.',cVALOR)
	Endif

	nRESTO  := If (nPOSPO > 0,Val(Substr(cVALOR,nPOSPO+1,1)),0)
	nINCDAT := If(nRESTO > 5,If(nINTEI <= 0,nINTEI-1,nINTEI+1),nINTEI)

	If nINCDAT < nIncLim // Verifica se a data vai ser menor que 31/12/1899, caso seja, substitui ela por 31/12/1899

		nINCDAT := nIncLim

	EndIf


Return dULTACO+nINCDAT

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGPROXMANF³ Autor ³ Paulo Pego            ³ Data ³ 24/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Data da proxima Manutencao por contador FIXO     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dULTACO - Data do Ultimo Acomponhamento[DEFT = Data Sist.] ³±±
±±³          ³ nCONTAD - Posicao do contador na Ultima manutencao         ³±±
±±³          ³ nINCREM - Incremento da Manutencao                         ³±±
±±³          ³ nCONTAC - Acomulador do Contador.                          ³±±
±±³          ³ nVARDIA - Variacao do contador.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBS       ³ Retorna a Data da proxima manutencao prevista              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT - Planejamento de Manutencao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DT.ALTERAC³ANLISTA/PROG.³ MOTIVO                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³             ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPROXMANF(dULTACO,nCONTAD,nINCREM,nCONTAC,nVARDIA)
	Local dRetC    := dDATABASE,nPOSPO,cVALOR,nINCDAT
	Local nRetC  := ((nCONTAD+nINCREM)-nCONTAC)/nVARDIA,nINTEI := Int(nRetc)
	Local nRESTO   := If(nINTEI < 0,nRetc*-1,nRetc) - If(nINTEI < 0,nINTEI*-1,nINTEI)
	Store 0 To nPOSPO,nINCDAT

	If Empty(nCONTAD) .Or. Empty(nVARDIA) .Or. Empty(nINCREM) .Or. Empty(nCONTAC)
		Return dRetC
	EndIf

	If nRESTO > 0
		cVALOR := Alltrim(Str(nRESTO))
		nPOSPO := At('.',cVALOR)
	Endif

	nRESTO := If(nPOSPO > 0,Val(Substr(cVALOR,nPOSPO+1,1)),0)
	nINCDAT := If(nRESTO > 5,If(nINTEI <= 0,nINTEI-1,nINTEI+1),nINTEI)
Return dULTACO+nINCDAT

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGPROXMANT³ Autor ³ Paulo Pego            ³ Data ³ 24/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Data da proxima Manutencao por tempo             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dULTMAN - Data da Ultima Manutencao                        ³±±
±±³          ³ nQTD    - Quantidade tempo ou Posicao do contador na Ultima³±±
±±³          ³           manutencao.                                      ³±±
±±³          ³ cUNID   - Unidade de Tempo ( D=Dias, S=Semanas, M=Meses e  ³±±
±±³          ³           F = Dias Fixos)  [DEFAULT = D]                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBS       ³ Retorna a Data da proxima manutencao prevista              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT - Planejamento de Manutencao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DT.ALTERAC³ANLISTA/PROG.³ MOTIVO                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³             ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPROXMANT(dUltMan,nQTD,cUNID)
	Local dRetT := dDATABASE
	Local dDtManRef := If(!Empty(dUltMan),dUltMan,Nil)
	Local nInc

	If Empty(nQTD) .Or. Empty(cUNID)
		Return dRetT
	EndIf

	If nQTD <> Nil .And. cUNID <> Nil
		nInc := NGINCMANUNI(STF->TF_CODBEM,STF->TF_SERVICO,STF->TF_SEQRELA,nQTD,cUNID,dDtManRef)
	Else
		nInc := NGINCMANUNI(STF->TF_CODBEM,STF->TF_SERVICO,STF->TF_SEQRELA,,,dDtManRef)
	EndIf

	dRetT := dUltMan+nInc

Return dRetT

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCHKDTMNT³ Autor ³ Paulo Pego            ³ Data ³ 24/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a data REAL da manutencao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dDATA   - Data da Original Manutencao                      ³±±
±±³          ³ cCALENDA- Codigo do calendario da Manutencao               ³±±
±±³          ³ cPROC   - Procedimento para dia nao util                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBS       ³ Retorna a Data da real manutencao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT - Planejamento de Manutencao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DT.ALTERAC³ANLISTA/PROG.³ MOTIVO                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³             ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCHKDTMNT(dDATA,cCALENDA,cPROC)
	Local dRet := dDATA
	Local aDIAMAN

	If Empty(cPROC)
		cPROC := "U"
	EndIf

	If cPROC ==  "U"
		Return dDATA
	EndIf

	aDIAMAN := NG_H7(cCALENDA)

	If Empty(aDIAMAN)
		Return dDATA
	EndIf

	SH9->(DbSetOrder(2))

	Do While .T.
		If SH9->(DbSeek(xFilial("SH9") + "E" + DtoS(dRET)))
			If SH9->H9_DTINI >= dDATA .and. SH9->H9_DTFIM <= dDATA
				dRet := If(cPROC == "A", dRet-1, dRet+1)
				Loop
			EndIf
		EndIf

		nSem := If(DOW(dRET)==1,7,DOW(dRET)-1)
		nTOT := HtoM( aDIAMAN[nSEM][03] )

		If Empty(nTOT)
			dRet := If(cPROC == "A", dRet-1, dRet+1)
			Loop
		EndIf

		Exit
	EndDo

	SH9->(DbSetOrder(1))
Return dRet

//+-----------------------------------------+
//| Removida função NGFINALPDR, pois deixou |
//| de ser utilizada no MNTA231, a qual era |
//| a unica chamada da função               |
//| Versão 68 P12114                        |
//+-----------------------------------------+

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGESTRUPROD³ Autor ³In cio Luiz Kolling   ³ Data ³05/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca a estrutura do produto                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cCodpro - Codigo do produto                   - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³        - Matriz com os produto onde: [x,2] - pai           ³±±
±±³          ³                                      [x,3] - componente    ³±±
±±³          ³                                      [x,4] - quantidade    ³±±
±±³          ³                                      [x,5] - nivel         ³±±
±±³          ³                                      ..... -               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGESTRUPROD(cCodpro)
	Local cCodSSpa := Alltrim(cCodpro)
	Local cCodCert := cCodSSpa+Space(Len(sb1->b1_cod)-Len(cCodSSpa))
	Private nEstru := 0
Return Estrut(cCodCert)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGFINAL   ³ Autor ³ Paulo Pego            ³ Data ³ 24/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa a Finalizacao da O.S.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOS      - Numero da Ordem de Servico                      ³±±
±±³          ³ cPLANO   - Plano de Manutencao                             ³±±
±±³          ³ dPRINI   - Data Parada Inicio                              ³±±
±±³          ³ hPRINI   - Hora Parada Inicio.                             ³±±
±±³          ³ dPRFIM   - Data Parada Fim                                 ³±±
±±³          ³ hPRFIM   - Hora Parada Fim                                 ³±±
±±³          ³ nPOSCONT - Posicao do Contador 1                           ³±±
±±³          ³ nPOSCON2 - Posicao do Contador 2                           ³±±
±±³          ³ cBEMCO   - C¢digo do bem que receber  o contador (1/2)     ³±±
±±³          ³ cHORCO1  - Hora do 1 contador                              ³±±
±±³          ³ cHORCO2  - Hora do 2 contador                              ³±±
±±³          ³ nDIFC    - Diferenca do contador                           ³±±
±±³          ³ lVGEST   - Gera D3                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBS       ³ Implementa a variavel cNGERRO                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT - Planejamento de Manutencao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DT.ALTERAC³ANLISTA/PROG.³ MOTIVO                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³             ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGFINAL(cOS,cPLANO,dPRINI,hPRINI,dPRFIM,hPRFIM,nPOSCONT,nPoscon2,;
	cBEMCO,cHORCO1,cHORCO2,nDIFC,lVGEST,PFIL,lTQS,cEmp,cFilBem)

	Local aAreaD3   := SD3->( GetArea() )
	Local cGERAPREV := AllTrim(GETMv("MV_NGGERPR")),XX
	Local dMIN,dMAX,dMAXF,hMIN,hMAX,hMAXF, nMDO,nTRO,nSUB,nAPO,nTER,nFER,aSTLARQ := {}
	Local aCposUser := {},nPosCpo := 0,nI := 0,cCposSD3 := "",cCposSTL := ""
	Local cVarSTL   := "",lGERAEST := If(lVGEST = NIL,.T.,lVGEST)
	Local lOSHESTO  := .F., lAtuTQS := If(lTQS = NIL,.t.,lTQS)
	Local cFilSTJ   := NGTROCAFILI("STJ",PFIL)
	Local cFilSTF   := NGTROCAFILI("STF",PFIL)
	Local cFilSTL   := NGTROCAFILI("STL",PFIL)
	Local cFilST9   := NGTROCAFILI("ST9",PFIL)
	Local cFilSH9   := NGTROCAFILI("SH9",PFIL)
	Local cFilSTP   := NGTROCAFILI("STP",PFIL)
	Local cFilSTQ   := NGTROCAFILI("STQ",PFIL)
	Local cFilST4   := NGTROCAFILI("ST4",PFIL)
	Local cFilTPD   := NGTROCAFILI("TPD",PFIL)
	Local cFilTQS   := NGTROCAFILI("TQS",PFIL)
	Local cFilTQE   := NGTROCAFILI("TQE",PFIL)
	Local cFilTT7   := If(AliasInDic("TT7"), NGTROCAFILI("TT7",PFIL), "")
	Local lCustFer  := NGCADICBASE("TJ_CUSTFER","A","STJ",.F.)
	Local lIntSFC   := FindFunction("NGINTSFC") .And. FindFunction("NGINTSFC") .And. NGINTSFC() // Verifica se ha integracao com modulo Chao de Fabrica [SIGASFC]
	Local cDocumSD3
	Local nCustoAtu
	Local lMMoeda  	:= NGCADICBASE("TL_MOEDA","A","STL",.F.) // Multi-Moeda
    Local lShowMens	:= !IsBlind() .And. !IsInCallStack("RESTEXECUTE")  //Variável para não apresentar mensagens quando está sendo executado via WebService Rest
	Local cNGSEREF  := SuperGetMV("MV_NGSEREF", .F., " ")
	Local cPRODTER	:= Trim(GetMv("MV_PRODTER"))
	Local cNGRETOS	:= GetMv("MV_NGRETOS")
	Local cNGUNIDT	:= AllTrim(GetMv("MV_NGUNIDT"))
	Local cPRODMNT	:= Trim(GetMv("MV_PRODMNT"))
	Local lVerSubst := SuperGetMV("MV_NG1SUBS", .F., "1" ) == "2"
	Local lIntRm    := AllTrim(GetNewPar("MV_NGINTER","N")) == "M"
	Local lExecSD4  := NgVldRpo( { { 'MNTUTIL.prx', SToD( '20220825' ), '08:00' } } ) .And. MntUseExec()

	// Variáveis para controlar a Vida do Pneu
	Local aCBoxBanda := {}
	Local cMaxBanda  := ""
	Local nATIgual   := 0
	Local lIntTec 	 := .F.

	Default cEmp := cEmpAnt
	Default cFilBem := ""

	Store Ctod('  /  /  ') To dMIN,dMAX,dMAXF
	Store '  :  '          To hMIN,hMAX,hMAXF
	Store 0.00             To nMDO,nTRO,nSUB,nAPO,nTER,nFER

	DbSelectArea('TEW')
	lIntTEC := FindFunction("At040ImpST9") .And. ( TEW->(FieldPos('TEW_TPOS')) > 0 )

	cUSAINT1 := AllTrim(GETMv("MV_NGMNTPC"))
	cUsaInt2 := AllTrim(GetMv("MV_NGMNTCM"))
	cUsaInt3 := AllTrim(GetMv("MV_NGMNTES"))
	cUIntHis := AllTrim(GetMv("MV_NGHISES"))

	// Incluido para emular chamada via nota fiscal de entrada
	If Type("cPrograma") = "U"
		cPrograma := "XXXXXXXX"
	Endif

	cNGERROR := "  "

	DbSelectArea("STJ")
	DbSetOrder(1)
	If !DbSeek(cFilSTJ + cOS + cPLANO)
		cNGERROR := STR0010 //"ORDEM/PLANO  DE MANUTENCAO NAO EXISTE"
		Return .f.
	EndIf

	//testa integracao via mensagem unica
	If lIntRm //Mensagem Unica
		cTerm := STJ->TJ_TERMINO
		RecLock("STJ",.F.)
		STJ->TJ_TERMINO := "S"
		MsUnLock("STJ")
	EndIf

	If cUsaInt3 == 'S' .And. cUIntHis == "N" .And. STJ->TJ_SERVICO == "HISTOR";
	.And. cPrograma == "MNTA400"
		lOSHESTO := .T.
	EndIf

	cCalend := "   "
	DbSelectArea("STF")
	DbSetOrder(1)

	If DbSeek(cFilSTF + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA)
		cCALEND := STF->TF_CALENDA
		aDIAMAN := NG_H7(cCALEND)
	EndIf

	//Verifica se o existe SD3 para esta OP e incrementa a OS
	DbSelectArea("STL")
	DbSetOrder(7)

	cORDEMOP := cOS+"OS001"
	cORDESD4 := cORDEMOP+Space(Len(SD4->D4_OP)-Len(cORDEMOP))

	If cUsaInt3  = 'S' .And. lGERAEST
		DbSelectArea("SD3")
		DbSetOrder(1)

		DbSeek(xFilial("SD3") + cORDESD4)
		While !Eof() .And. SD3->D3_FILIAL == xFilial("SD3") .And.;
		SD3->D3_OP == cORDESD4

			If MntProdMod( Trim( SD3->D3_COD ) ) .Or. SD3->D3_TM == '499' .Or. SubStr( SD3->D3_CF, 1, 2 ) == 'PR' .Or.;
				SD3->D3_ESTORNO == 'S'

				SD3->( dbSkip() )
				Loop

			EndIf

			cNUMSEQ := SD3->D3_NUMSEQ
			cCODTER := If(FindFunction("NGProdMNT"), NGProdMNT("T")[1], cPRODTER) //Ira verificar apenas o primeiro Produto Terceiro do parametro

			If cNGRETOS == 1           //Retorno Automatico Via SD3
				DbSelectArea("STL")
				DbSetOrder(7)
				If !DbSeek(cFilSTL + cNUMSEQ)
					If Trim(sd3->d3_cod) == cCODTER
						cTipo := "T"
						hFIM  := Space(5)
						dFIM  := CtoD("  /  /  ")
						hINI  := Space(5)

						If !Empty(cCALEND)
							nSem := If(DOW(sd3->d3_emissao)==1,7,DOW(sd3->d3_emissao)-1)
							hINI := aDIAMAN[nSEM][01]
							hFIM := ( HtoM(hINI) + (sd3->d3_quant * 60) )
							dFIM := sd3->d3_emissao

							While hFIM >= 1440
								hFIM := hFIM - 1440
								dFIM++
							End
							hFIM := MtoH(hFIM)
						EndIf

					Else
						cTipo := "P"
						hFIM  := Space(5)
						dFIM  := CtoD("  /  /  ")
						hINI  := Space(5)
						If !Empty(cCALEND)
							nSem := If(DOW(sd3->d3_emissao)==1,7,DOW(sd3->d3_emissao)-1)
							hINI := aDIAMAN[nSEM][01]
						EndIf
					EndIf
					M->TJ_PLANO := cOS
					M->TJ_ORDEM := cplano
					M->TL_PLANO := M->TJ_PLANO
					M->TL_ORDEM := M->TJ_ORDEM
					nSEQSTL := ULTSEQ(Recno())
					If !NGIFDBSEEK("STL",cOS+cPLANO+"0     "+cTipo+sd3->d3_cod+nSEQSTL,1)
						DbSelectArea("STL")
						RecLock("STL",.T.)
						stl->tl_filial   := cFilSTL
						stl->tl_ordem    := cOS
						stl->tl_plano    := cPLANO
						stl->tl_seqrela  := nSEQSTL
						stl->tl_tarefa   := "0"
						stl->tl_tiporeg  := cTIPO
						stl->tl_codigo   := sd3->d3_cod
						stl->tl_quanrec  := 0
						stl->tl_quantid  := sd3->d3_quant
						stl->tl_unidade  := sd3->d3_um
						stl->tl_dtinici  := sd3->d3_emissao
						stl->tl_hoinici  := If(Empty(hINI),Time(),hINI)
						stl->tl_dtfim    := If(Empty(dFIM),SD3->D3_EMISSAO,dtfim)
						stl->tl_hofim    := If(Empty(hFIM),Time(),hFIM)
						stl->tl_custo    := SD3->D3_CUSTO1
						stl->tl_destino  := If(cTipo = "P","A",stl->tl_destino)
						Stl->tl_local    := SD3->D3_LOCAL
						STL->TL_TIPOHOR  := cNGUNIDT
						STL->TL_USACALE  := 'N'
						If lMMoeda
							STL->TL_MOEDA := "1"
						Endif
						STL->(MsUnlock())

						// Preenche os compos complementares
						NGSTLSD3COMP("SD3")

						If Empty(stl->tl_garanti)
							RecLock("STL",.F.)
							STL->TL_GARANTI := 'N'
							STL->(MsUnlock())
						Endif

					EndIf
				EndIf
			EndIf

			If !lExecSD4

				//Atualiza arquivo de empenhos e B2_QEMP
				dbSelectArea('SD4')
				dbSetOrder(2)
				dbSeek( xFilial('SD4') + SD3->D3_OP )
				While !EoF() .And. SD4->D4_FILIAL + SD4->D4_OP == xFilial('SD3') + SD3->D3_OP

					//Nao baixa se quantidade empenhada for negativa
					If SD4->D4_QUANT == 0 .Or. MntProdMod( Trim( SD4->D4_COD ) )
						SD4->( dbSkip() )
						Loop
					EndIf
					nQuantS := SD4->D4_QUANT
					dbSelectArea('SD4')
					RecLock( 'SD4', .F. )
					Replace D4_QUANT   With 0
					Replace D4_QTSEGUM With 0
					SD4->( MsUnlock() )

					NGAtuErp("SD4","UPDATE")

					If !Empty( nQuants )
						
						dbSelectArea( 'SB2' )
						dbSetOrder( 1 ) // B2_FILIAL + B2_COD + B2_LOCAL
						If dbSeek( xFilial( 'SB2' ) + SD4->D4_COD + SD4->D4_LOCAL )
							
							// Retira quantidade empenhada no saldo físico.
							RecLock( 'SB2',.F. )
							SB2->B2_QEMP := IIf( ( SB2->B2_QEMP - nQuants ) < 0, 0, ( SB2->B2_QEMP - nQuants ) )
							SB2->( MsUnLock() )

						EndIf

					EndIf

					dbSelectArea( 'SDC' )
					dbSetOrder( 2 ) // DC_FILIAL + DC_PRODUTO + DC_LOCAL + DC_OP + DC_TRT + DC_LOTECTL + DC_NUMLOTE + DC_LOCALIZ + DC_NUMSERI
					If dbSeek( xFilial( 'SDC' ) + SD4->D4_COD + SD4->D4_LOCAL + SD4->D4_OP )

						While SDC->( !EoF() ) .And. SD4->D4_COD == SDC->DC_PRODUTO .And. SD4->D4_LOCAL == SDC->DC_LOCAL .And.;
							SD4->D4_OP == SDC->DC_OP .And. xFilial( 'SDC' ) == SDC->DC_FILIAL

							// Retira quantidade da composição do empenho.
							RecLock( 'SDC', .F. )
							SDC->DC_QUANT := IIf( ( SDC->DC_QUANT - nQuants ) < 0, 0, ( SDC->DC_QUANT - nQuants ) )
							SDC->( MsUnLock() )

							dbSelectArea( 'SBF' )
							dbSetOrder( 1 ) // BF_FILIAL + BF_LOCAL + BF_LOCALIZ + BF_PRODUTO + BF_NUMSERI + BF_LOTECTL + BF_NUMLOTE
							If dbSeek( xFilial( 'SBF' ) + SDC->DC_LOCAL + SDC->DC_LOCALIZ + SDC->DC_PRODUTO ) 

								While SBF->( !EoF() ) .And. SDC->DC_LOCAL == SBF->BF_LOCAL .And. SDC->DC_LOCALIZ == SBF->BF_LOCALIZ .And.;
									SDC->DC_PRODUTO == SBF->BF_PRODUTO .And. xFilial( 'SBF' ) == SBF->BF_FILIAL
								
									// Retira quantidade empenhada relacionado ao endereço.
									RecLock( 'SBF', .F. )
									SBF->BF_EMPENHO := IIf( ( SBF->BF_EMPENHO - nQuants ) < 0, 0, ( SBF->BF_EMPENHO - nQuants ) )
									SBF->( MsUnLock() )

									SBF->( dbSkip() )
								
								End

							EndIf

							SDC->( dbSkip() )

						End
					
					EndIf
					
					SD4->( dbSkip() )

				End

			EndIf

			//Posiciona no arquivo de OP's
			DbSelectArea("SC2")
			DbSetOrder(1)
			If DbSeek(xFilial("SC2")+SD3->D3_OP)
				RecLock("SC2",.F.)
				Replace C2_DATRF With SD3->D3_EMISSAO
				SC2->(MsUnlock())
				If SG1->(Dbseek(xFILIAL('SG1')+SC2->C2_PRODUTO))
					NGAtuErp("SC2","UPDATE")
				EndIf
			EndIf

			//Atualiza o campo totalizador dos empenhos
			DbSelectArea("SB2")
			DbSeek(xFilial("SB2")+SC2->C2_PRODUTO+SC2->C2_LOCAL)
			If Eof()
				CriaSB2(SC2->C2_PRODUTO,SC2->C2_LOCAL)
				// A FUNCAO ACIMA NAO LIBERA O REGISTRO
				SB2->(MsUnlock())
				NGAtuErp("SB2","INSERT")
			EndIf

			RecLock("SB2",.F.)
			Replace B2_SALPEDI With B2_SALPEDI - (SC2->C2_QUANT - SC2->C2_QUJE - SC2->C2_PERDA)
			SB2->(MsUnlock())
			If NGPRODESP(SB2->B2_COD,.F.,"M")
				NGAtuErp("SB2","UPDATE")
			EndIf

			DbSelectArea("SD3")
			DbSkip()
		End
	EndIf

	DbSelectArea("STL")
	DbSetOrder(1)
	DbSeek(cFilSTL + cOS + cPLANO)
	lTemInR := .F.
	lPRIMD  := .T.
	vVETRE  := {}
	aSGAINS := {}
	DbSelectArea("STL")
	While !EOF() .AND. STL->TL_FILIAL == cFilSTL .and.;
	STL->TL_ORDEM == cOS .and. STL->TL_PLANO == cPLANO

		If Alltrim(stl->tl_seqrela) <> "0"  .And. stl->tl_tiporeg = "P"

			Aadd(aSGAINS,{stl->tl_codigo,stl->tl_dtinici,stl->tl_hoinici,;
			stl->tl_quantid,stl->tl_ordem,stl->tl_plano,;
			stl->tl_seqrela,STL->TL_FILIAL,STL->TL_NUMSEQ})
		Endif

		If Alltrim(stl->tl_seqrela) == "0"
			If STL->TL_TIPOREG == 'P' .Or. STL->TL_TIPOREG == "T"
				nPOSX := aSCAN(aSTLARQ,{|x| (x[1]) == STL->TL_CODIGO .and. (x[2]) == STL->TL_LOCAL})
				If nPOSX == 0
					If STL->TL_TIPOREG == "T"
						aAdd(aSTLARQ,{PadR(cPRODTER,TAMSX3("D4_COD")[1]),STL->TL_LOCAL,STL->TL_QUANTID,0.0})
					Else
						aAdd(aSTLARQ,{STL->TL_CODIGO,STL->TL_LOCAL,STL->TL_QUANTID,0.0})
					EndIf
				Else
					aSTLARQ[nPOSX][3] := aSTLARQ[nPOSX][3] + STL->TL_QUANTID
				EndIf
			EndIf
			DbSkip()
			Loop
		EndIf

		lTemInR := .T.
		If STL->TL_TIPOREG != 'P'
			NGDTHORFINAL(STL->TL_DTINICI,STL->TL_HOINICI,STL->TL_DTFIM,;
			STL->TL_HOFIM,STL->TL_TIPOREG,;
			STL->TL_SEQRELA,"R")
			dMIN := vVETRE[1]
			hMIN := vVETRE[2]
			dMAX := vVETRE[3]
			hMAX := vVETRE[4]
		Endif

		If STL->TL_TIPOREG == "P"
			nPOSX := aSCAN(aSTLARQ,{|x| (x[1]) == STL->TL_CODIGO .and. (x[2]) == STL->TL_LOCAL})
			If nPOSX > 0
				aSTLARQ[nPOSX][4] := aSTLARQ[nPOSX][4] + STL->TL_QUANTID
			EndIf
		EndIf

		nCustoAtu := If(lMMoeda,xMoeda(stl->tl_custo,Val(stl->tl_moeda),1,stl->tl_dtinici,2),stl->tl_custo)

		If STL->TL_TIPOREG == "T"
			nTER := nTER + nCustoAtu
		ElseIf STL->TL_TIPOREG == "P"
			If STL->TL_DESTINO == "T"
				nTRO := nTRO + nCustoAtu
			ElseIf STL->TL_DESTINO == "S"
				nSUB := nSUB + nCustoAtu
			Else
				nAPO := nAPO + nCustoAtu
			EndIf
		ElseIf STL->TL_TIPOREG == "F"
			nFER := nFER + nCustoAtu
		ElseIf STL->TL_TIPOREG == "M"
			nMDO := nMDO + nCustoAtu
		EndIf

		DbSelectArea("STL")
		RecLock("STL",.F.)
		stl->tl_repfim := "S"
		STL->(MsUnlock())
		DbSkip()
	End

	If ( cPrograma == "MNTA401" .OR. FunName() == "MNTA510" .Or. cPrograma == "MNTA330" );
		.AND. Empty(dMIN) .AND. Empty(dMAX)
		dbSelectArea("STL")
		dbSetOrder(1)
		dbSeek(cFilSTL+cOS+cPLANO)
		While !Eof() .AND. STL->TL_FILIAL == cFilSTL .AND.;
		STL->TL_ORDEM == cOS .AND. STL->TL_PLANO == cPLANO
			If Alltrim(STL->TL_SEQRELA) != "0"
				NGDTHORFINAL(STL->TL_DTINICI,STL->TL_HOINICI,STL->TL_DTFIM,;
				STL->TL_HOFIM,STL->TL_TIPOREG,;
				STL->TL_SEQRELA,"R")
				dMIN := vVETRE[1]
				hMIN := vVETRE[2]
				dMAX := vVETRE[3]
				hMAX := vVETRE[4]
			Endif
			dbSkip()
		End
	Endif

	If Empty(dMAX)
		dMIN := STJ->TJ_DTMPINI
		hMIN := STJ->TJ_HOMPINI
		dMAX := STJ->TJ_DTMPINI
		hMAX := STJ->TJ_HOMPINI
	EndIf

	//Pega o proximo numero sequencial de movimento
	If cUsaInt3  = 'S' .And. lGERAEST .And. !lOSHESTO
		cNumSeq := ProxNum()

		//Pega o proximo numero sequencial do documento do SD3
		cDocumSD3 := NextNumero("SD3",2,"D3_DOC",.T.)
		cDocumSD3 := A261RetINV(cDocumSD3)

		nTOTAL  := 0.00

		//Grava no SD3 o encerramento da OP gerada
		nTOTAL  := (nMDO + nTRO + nSUB + nAPO + nTER + nFER)

		cCODPRO := If(FindFunction("NGProdMNT"), NGProdMNT("M")[1], cPRODMNT) //Ira verificar apenas o primeiro Produto Manutencao do parametro
		DbSelectArea("SB1")
		DbSeek(xFilial("SB1") + cCODPRO)

		cB1APROP := SB1->B1_APROPRI
		DbSelectArea("SD3")
		RecLock("SD3",.T.)
		Replace d3_filial   With xFilial("SD3")
		Replace d3_tm       With "499"
		Replace d3_cod      With cCODPRO
		Replace d3_um       With sb1->b1_um
		Replace d3_quant    With 1
		Replace d3_cf       With "PR0"
		Replace d3_conta    With sb1->b1_conta
		Replace d3_op       With stj->tj_ordem+"OS001"
		Replace d3_local    With sb1->b1_locpad
		Replace d3_doc      With cDocumSD3
		Replace d3_emissao  With dMAX
		Replace d3_custo1   With nTOTAL
		Replace d3_segum    With sb1->b1_segum
		Replace d3_qtsegum  With ConvUm(SB1->B1_COD,1,0,2)
		Replace d3_tipo     With sb1->b1_tipo
		Replace d3_usuario  With If(Len(SD3->D3_USUARIO) > 15,cUsername,Substr(cUsuario,7,15))
		Replace d3_numseq   With cNumSeq
		Replace d3_chave    With SubStr(D3_CF,2,1)+If(D3_CF $ 'RE4|DE4','9','0')
		Replace d3_cc       With stj->tj_ccusto
		Replace d3_ordem    With stj->tj_ordem
		If cB1APROP = "I"
			SD3->D3_CHAVE   := Substr(sd3->d3_chave,1,1)+"3"
		Endif

		If NGCADICBASE("T9_ITEMCTA","A","ST9",.F.)
			SD3->D3_ITEMCTA := NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_ITEMCTA")
		EndIf
		SD3->(MsUnlock())

		If NGPRODESP(SD3->D3_COD,.F.,"M")
			NGAtuErp("SD3","INSERT")
		EndIf

		cNumSeq := ProxNum()

		//Pega o proximo numero sequencial do documento do SD3
		cDocumSD3 := NextNumero("SD3",2,"D3_DOC",.T.)
		cDocumSD3 := A261RetINV(cDocumSD3)

		//Grava no SD3 o encerramento da OP gerada
		nTOTAL  := 0.00
		nTOTAL  := (nMDO + nTRO + nSUB + nAPO + nTER + nFER)

		cCODPRO := If(FindFunction("NGProdMNT"), NGProdMNT("M")[1], cPRODMNT) //Ira verificar apenas o primeiro Produto Manutencao do parametro
		DbSelectArea("SB1")
		DbSeek(xFilial("SB1") + cCODPRO)
		cB1APROP := SB1->B1_APROPRI

		DbSelectArea("SD3")
		RecLock("SD3",.T.)
		Replace d3_filial   With xFilial("SD3")
		Replace d3_tm       With "999"
		Replace d3_cod      With cCODPRO
		Replace d3_um       With sb1->b1_um
		Replace d3_quant    With 1
		Replace d3_cf       With "RE0"
		Replace d3_conta    With sb1->b1_conta
		Replace d3_op       With stj->tj_ordem+"OS001"
		Replace d3_local    With sb1->b1_locpad
		Replace d3_doc      With cDocumSD3
		Replace d3_emissao  With dMAX
		Replace d3_custo1   With nTOTAL
		Replace d3_segum    With sb1->b1_segum
		Replace d3_qtsegum  With ConvUm(SB1->B1_COD,1,0,2)
		Replace d3_tipo     With sb1->b1_tipo
		Replace d3_usuario  With If(Len(SD3->D3_USUARIO) > 15,cUsername,Substr(cUsuario,7,15))
		Replace d3_numseq   With cNumSeq
		Replace d3_chave    With SubStr(D3_CF,2,1)+If(D3_CF $ 'RE4|DE4','9','0')
		Replace d3_cc       With stj->tj_ccusto
		Replace d3_ordem    With stj->tj_ordem
		If cB1APROP = "I"
			SD3->D3_CHAVE   := Substr(sd3->d3_chave,1,1)+"3"
		Endif

		If NGCADICBASE("T9_ITEMCTA","A","ST9",.F.)
			SD3->D3_ITEMCTA := NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_ITEMCTA")
		EndIf
		SD3->(MsUnlock())
		If NGPRODESP(SD3->D3_COD,.F.,"M")
			NGAtuErp("SD3","INSERT")
		EndIf

		//Posiciona no arquivo de OP's
		DbSelectArea("SC2")
		DbSetOrder(1)
		If DbSeek(xFilial("SC2")+SD3->D3_OP)
			RecLock("SC2",.F.)
			Replace C2_DATRF With SD3->D3_EMISSAO
			SC2->(MsUnlock())

			If SG1->(DbSeek(xFilial('SG1') + SC2->C2_PRODUTO))
				NGAtuErp("SC2","UPDATE")
			EndIf
		EndIf

		// Inicio da orientacao do Microsiga

		//Pega os 5 custos medios atuais
		aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)

		//³ Grava o custo da movimentacao
		C2AtuComD3(aCM)
		If SG1->(DbSeek(xFilial('SG1') + SC2->C2_PRODUTO))
			NGAtuErp("SC2","UPDATE")
		EndIf

		// fim da orientacao do Microsiga
		// ATUALIZACAO O EMPENHO DO SB2
		If !lIntRm
			For XX := 1 To Len(aSTLARQ)
				DbSelectArea("SB2")
				DbSeek(xFilial("SB2")+aSTLARQ[XX][1]+aSTLARQ[XX][2])

				DbSelectArea("SD4")
				DbSetOrder(02)
				If DbSeek(xFilial('SD4') + cORDESD4 + aSTLARQ[XX][1] + aSTLARQ[XX][2])
					aTravas := {}
					
					If !lExecSD4

						If SD4->D4_QUANT <> 0
							GravaEmp(aSTLARQ[XX][1],aSTLARQ[XX][2],aSTLARQ[XX][3],0,'','','','',cORDEMOP,Str(XX,3),NIL,NIL,'SC2',NIL,SD4->D4_DATA,@aTravas,.T.,.F.,.T.,.T.,NIL,NIL,.F.)
						Endif

						NGAtuErp("SD4","INSERT")

					EndIf

					If aSTLARQ[XX][4] == 0
						
						If !lExecSD4
						
							RecLock('SD4',.F.)
							DbDelete()
							SD4->(MsUnlock())
							
							NGAtuErp("SD4","DELETE")

						EndIf

						DbSelectArea("SC1")
						DbSetOrder(04)
						If DbSeek(xFilial('SC1')+cORDESD4)
							While !Eof() .And. sc1->c1_filial == xfilial("SC1") .And.;
							sc1->c1_op     == cORDESD4

								If sc1->c1_produto == aSTLARQ[XX][1] .And.;
								sc1->c1_local == aSTLARQ[XX][2]   .And.;
								sc1->c1_tpop == 'F'               .And.;
								Empty(sc1->c1_cotacao)            .And.;
								sc1->c1_quje == 0

									//Remove o Numero e Item da SC do Pedido de Compra.
									DbSelectArea("SC7")
									DbSetOrder(2)
									If DbSeek(xFilial('SC7')+SC1->C1_PRODUTO)
										While !Eof() .And. xFilial('SC7')+SC1->C1_PRODUTO==SC7->C7_FILIAL+SC7->C7_PRODUTO

											If SC1->C1_Num+SC1->C1_ITEM == SC7->C7_NUMSC+SC7->C7_ITEMSC
												RecLock("SC7",.F.)
												Replace C7_NUMSC  With "",;
												C7_ITEMSC With ""
												SC7->(MsUnlock())
											EndIf
											DbSelectArea("SC7")
											DbSkip()
										End
									EndIf

									//Subtrai a qtde do Item da SC no arquivo de entrada de estoque
									DbSelectArea("SB2")
									DbSetOrder(1)
									If DbSeek(xFilial('SC1')+SC1->C1_PRODUTO+SC1->C1_LOCAL)
										RecLock("SB2",.F.)
										Replace B2_SALPEDI With B2_SALPEDI-(SC1->C1_QUANT-SC1->C1_QUJE)
										SB2->(MsUnlock())
										If NGPRODESP(SB2->B2_COD,.F.,"M")
											NGAtuErp("SB2","UPDATE")
										EndIf
									EndIf
									NGAtuErp("SC1","DELETE")
									DbSelectArea('SC1')
									RecLock('SC1',.F.,.T.)
									dbDelete()
									SC1->(MsUnlock())
									Exit
								EndIf
								DbSelectArea("SC1")
								DbSkip()
							End
						EndIf

					EndIf

				EndIf

			Next XX

		EndIf

	EndIf
	
	DbSelectArea("ST9")
	DbSeek(cFilST9+STJ->TJ_CODBEM)

	DbSelectArea("STF")
	If DbSeek(cFilSTF + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA)
		RecLock("STF",.F.)
		STF->TF_QUANTOS := STF->TF_QUANTOS + 1
		If STF->( FieldPos("TF_CONPREV") ) > 0
			STF->TF_CONPREV := STF->TF_CONPREV + STF->TF_INENMAN
		EndIf
		If STF->TF_PERIODO == "U"
			STF->TF_ATIVO := "N"
		Endif
		STF->(MsUnlock())
	EndIf

	// 11 - DELETA OS RECURSOS DA MICROSIGA (SH9)  - BEM
	DbSelectArea("SH9")
	DbSetOrder(4)
	DbSeek(cFilSH9 + "B" + DtoS(stj->tj_dtmpini) )
	While !Eof() .And. H9_FILIAL+H9_TIPO+DTOS(H9_DTINI) == cFilSH9+"B"+DtoS(stj->tj_dtmpini)
		cMotivo1 := STR0012 + stj->tj_ordem + STR0013 + stj->tj_plano //"OS.MANUT."###" PLANO "
		cMotivo2 := STR0014 + stj->tj_ordem //"OS "

		If Trim(cMOTIVO1) == Trim(SH9->H9_MOTIVO) .Or.;
		Trim(cMOTIVO2) == Trim(SH9->H9_MOTIVO) .AND. SH9->H9_ORIGEM = '1'
			//desfazer SGT na versao 12 (verificar com a Totvs)
			If AliasInDic("SGT")
				SGT->(dbSetOrder(1))
				If SGT->(dbSeek(xFilial("SGT")+SH9->(H9_TIPO+H9_CCUSTO+H9_RECURSO+DTOS(H9_DTINI)+H9_HRINI)))
					RecLock("SGT",.F.)
					SGT->(dbDelete())
					SGT->(MsUnLock())
				EndIf
			EndIf
			RecLock("SH9",.F.)
			DbDelete()
			SH9->(MsUnlock())
		EndIf
		DbSkip()
	End

	// 12 - DELETA OS RECURSOS DA MICROSIGA (SH9)  - FERRAMENTAS
	DbSelectArea("SH9")
	DbSetOrder(4)
	DbSeek(cFilSH9 + "F" + DtoS(stj->tj_dtmpini) )
	While !Eof() .And. H9_FILIAL+H9_TIPO+DTOS(H9_DTINI) == cFilSH9+"F"+DtoS(stj->tj_dtmpini)
		cMotivo1 := STR0012 + stj->tj_ordem + STR0013 + stj->tj_plano //"OS.MANUT."###" PLANO "
		cMotivo2 := STR0014 + stj->tj_ordem //"OS "

		If Trim(cMOTIVO1) == Trim(SH9->H9_MOTIVO) .Or.;
		Trim(cMOTIVO2) == Trim(SH9->H9_MOTIVO) .and. SH9->H9_ORIGEM = '1'
			//desfazer SGT na versao 12 (verificar com a Totvs)
			If AliasInDic("SGT")
				SGT->(dbSetOrder(1))
				If SGT->(dbSeek(xFilial("SGT")+SH9->(H9_TIPO+H9_CCUSTO+H9_RECURSO+DTOS(H9_DTINI)+H9_HRINI)))
					RecLock("SGT",.F.)
					SGT->(dbDelete())
					SGT->(MsUnLock())
				EndIf
			EndIf
			RecLock("SH9",.F.)
			DbDelete()
			SH9->(MsUnlock())
		EndIf
		DbSkip()
	End

	If cBEMCO <> NIL
		cFilAx := cFilSTP
		dDtRealF := If(Len(vVETRE) > 0,vVETRE[3],STJ->TJ_DTMRFIM)
		If !Empty(nPOSCONT)
			vRetHis := NGCHKHISTO(cBEMCO,dDtRealF,nPOSCONT,cHORCO1,1,,.f.,cFilAx)
			If vRetHis[1]
				NGTRETCON(cBEMCO,dDtRealF,nPOSCONT,cHORCO1,1,,.T.,,cFilAx)
			Endif
		Endif
		If !Empty(nPOSCON2)
			vRetHis := NGCHKHISTO(cBEMCO,dDtRealF,nPOSCON2,cHORCO2,2,,.f.,,cFilAx)
			If vRetHis[1]
				NGTRETCON(cBEMCO,dDtRealF,nPOSCON2,cHORCO2,2,,.F.,,cFilAx)
			Endif
		Endif
	Else

	Endif

	//Atualiza as ETAPAS EXECUTADAS para o BEM (TPD)
	DbSelectArea("ST9")
	DbSetOrder(1)
	DbSeek(cFilST9+STJ->TJ_CODBEM)
	nCTACUM := ST9->T9_CONTACU

	If Select("TPD") > 0
		DbSelectArea("STQ")
		DbSetOrder(1)
		DbSeek(cFilSTQ + STJ->TJ_ORDEM + STJ->TJ_PLANO )
		While !Eof() .And. STQ->TQ_FILIAL == cFilSTQ .And.;
		STQ->TQ_ORDEM == STJ->TJ_ORDEM .And. STQ->TQ_PLANO == STJ->TJ_PLANO

			If Empty(STQ->TQ_OK)
				DbSKip()
				Loop
			EndIf

			DbSelectArea("TPD")
			If !DbSeek(cFilTPD + STJ->TJ_CODBEM + STQ->TQ_ETAPA )
				RecLock("TPD", .t.)
				TPD->TPD_FILIAL := cFilTPD
				TPD->TPD_CODBEM := STJ->TJ_CODBEM
				TPD->TPD_ETAPA  := STQ->TQ_ETAPA
				TPD->TPD_DTULTM := dMAX
				TPD->TPD_POSCON := ST9->T9_POSCONT
				TPD->(MsUnlock())
			Else
				If dMAX > TPD->TPD_DTULTM
					RecLock("TPD", .f.)
					TPD->TPD_DTULTM := dMAX
					TPD->TPD_POSCON := ST9->T9_POSCONT
					TPD->(MsUnlock())
				ElseIf dMAX == TPD->TPD_DTULTM .and. ST9->T9_POSCONT > TPD->TPD_POSCON
					RecLock("TPD", .f.)
					TPD->TPD_POSCON := ST9->T9_POSCONT
					TPD->(MsUnlock())
				EndIf
			EndIf
			DbSelectArea("STQ")
			DbSkip()
		End
	EndIf

	nMAX := 999999

	If Empty(dMAX)                //PELO PADRAO DE UMA CORRETIVA
		dMIN := STJ->TJ_DTMPINI
		hMIN := STJ->TJ_HOMPINI
		dMAX := STJ->TJ_DTMPINI
		hMAX := STJ->TJ_HOMPINI
	EndIf

	DbSelectArea("STJ")
	dbSetOrder(1)
	If dbSeek( xFilial("STJ") + cOS + cPLANO )
		RecLock("STJ",.F.)
		Recstjf := Recno()
		STJ->TJ_CUSTMDO := If(nMDO > nMAX .Or. nMDO < 0.00, 0.00, nMDO)
		STJ->TJ_CUSTMAT := If(nTRO > nMAX .Or. nTRO < 0.00, 0.00, nTRO)
		STJ->TJ_CUSTMAA := If(nAPO > nMAX .Or. nAPO < 0.00, 0.00, nAPO)
		STJ->TJ_CUSTMAS := If(nSUB > nMAX .Or. nSUB < 0.00, 0.00, nSUB)
		STJ->TJ_CUSTTER := If(nTER > nMAX .Or. nTER < 0.00, 0.00, nTER)
		If lCustFer
			STJ->TJ_CUSTFER := If(nFER > nMAX .Or. nFER < 0.00, 0.00, nFER)
		EndIf
		STJ->TJ_DTMRINI := If(Len(vVETRE) > 0, vVETRE[1],STJ->TJ_DTMRINI)
		STJ->TJ_HOMRINI := If(Len(vVETRE) > 0, vVETRE[2],STJ->TJ_HOMRINI)
		STJ->TJ_DTMRFIM := If(Len(vVETRE) > 0, vVETRE[3],STJ->TJ_DTMRFIM)
		STJ->TJ_HOMRFIM := If(Len(vVETRE) > 0, vVETRE[4],STJ->TJ_HOMRFIM)
		STJ->TJ_TERMINO := "S"
		//STJ->TJ_COULTMA := STF->TF_CONMANU Bloqueio feito em virtude de S.S. 015231
		STJ->TJ_DTPRINI := dPRINI
		STJ->TJ_HOPRINI := hPRINI
		STJ->TJ_DTPRFIM := dPRFIM
		STJ->TJ_HOPRFIM := hPRFIM
		If FieldPos('TJ_CONTFIM') > 0 .AND. FieldPos('TJ_USUAFIM') > 0
			STJ->TJ_CONTFIM := STJ->TJ_POSCONT
		STJ->TJ_USUAFIM :=  If(Len(	STJ->TJ_USUAFIM) > 15,cUsername,Substr(cUsuario,7,15)) //cUsername //Padronização da gravação do usuário conforme TJ_USUAINI
		EndIf

		STJ->TJ_TIPORET := If(lTemInR,"S"," ")
		If lMMoeda
			STJ->TJ_MOEDA := "1"
		Endif
		STJ->(MsUnlock())
	EndIf

	// SERVICO DE CONTROLE DE VIDA
	DbSelectArea("ST4")
	DbSetOrder(1)
	If DbSeek(cFilST4+STJ->TJ_SERVICO)
		If Alltrim(cNGSEREF) == AllTrim(ST4->T4_SERVICO)
			If ExistBlock("MNTA4004")
				ExecBlock("MNTA4004",.F.,.F.)
			EndIf
		EndIf
		If ST4->T4_VIDAUTI = "S" .And. lAtuTQS

			//Integracao com TQS
			If AllTrim(GetNewPar('MV_NGPNEUS','N')) == "S"
				dbSelectArea("SX3")
				dbSetOrder(2)
				If dbSeek("TQS_BANDAA")
					aCBoxBanda := StrTokArr(AllTrim(X3CBox()), ";")
					cMaxBanda  := aTail(aCBoxBanda)
					nATIgual   := AT("=", cMaxBanda)
					cMaxBanda  := SubStr(cMaxBanda,1,(nATIgual-1))

					DbSelectArea("TQS")
					DbSetOrder(1)
					If DbSeek(cFilTQS+STJ->TJ_CODBEM)
						// A função NGKMTQS somente deve ser chamada depois de ter sido feito o reporte de contador
						NGKMTQS(STJ->TJ_CODBEM, STJ->TJ_DTMRFIM, STJ->TJ_HOMRFIM)
						If TQS->TQS_BANDAA < cMaxBanda
							RecLock("TQS",.F.)
							TQS->TQS_BANDAA := SubStr(If(FindFunction("Soma1Old"),Soma1Old(TQS->TQS_BANDAA),Soma1(TQS->TQS_BANDAA)),1,1)
							TQS->(MsUnlock())
						Endif


					Endif
				EndIf
			Endif
		Endif

	Endif

	If Select("TQE") > 0
		DbSelectArea("TQE")
		Dbsetorder(1)
		If Dbseek(cFilTQE+stj->tj_ordem+stj->tj_plano)
			RecLock('TQE',.F.)
			TQE->TQE_SITUAC := "T"
			TQE->(MsUnLock())
		Endif
	Endif

	// Atualiza a O.S. relacionada a uma S.S.
	If AliasInDic("TT7")
		dbSelectArea("TT7")
		dbSetOrder(2)
		If dbSeek(cFilTT7 + STJ->TJ_ORDEM)
			RecLock("TT7", .F.)
			TT7->TT7_SITUAC := STJ->TJ_SITUACA
			TT7->TT7_TERMIN := STJ->TJ_TERMINO
			MsUnlock("TT7")
		EndIf
	EndIf


	dbSelectArea( 'STJ' )
	dbGoTo( Recstjf )
	If STJ->TJ_PLANO != '000000'
		
		If nDIFC = NIL
			NGATUMANUT(stj->tj_codbem,stj->tj_servico,;
			stj->tj_seqrela,stj->tj_dtmrfim,stj->tj_homrfim, ,;
			stj->tj_horaco1,stj->tj_horaco2,stj->tj_filial,cEmp)
		Else
			NGATUMANUT(stj->tj_codbem,stj->tj_servico,;
			stj->tj_seqrela,stj->tj_dtmrfim,stj->tj_homrfim,;
			nDIFC,stj->tj_horaco1,stj->tj_horaco2,stj->tj_filial,cEmp)
		EndIf

	EndIf

	// Caso integrado ao modulo de Chao de Fabrica
	// Finaliza Parada Programada
	If FindFunction("NGINTSFC") .And. NGINTSFC() .And. !Empty(NGVRFMAQ(STJ->TJ_CODBEM))
		NGSFCATPRD(STJ->TJ_ORDEM,{{"CZ2_LGMN",.F.}})
	Endif

	If lIntTEC
		At800OsxTec( .F. /*Exclusão?*/ )
	EndIf

	//Executa o Ponto de Entrada MNT4002 - Tratamento finalizacao OS
	If ExistBlock("MNTA4002")
		ExecBlock("MNTA4002",.F.,.F.)
	EndIf

	//atualiza OS com status terminado e com os custos
	//no caso de erro, o maximo que pode acontecer e' nao estar atualizado
	If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"  //Mensagem Unica
		NGMUMntOrd(STJ->(RecNo()),3)
	EndIf

	//Executa o tratamento de atualizacao de data e contador para ao O.S. que foram aglutinadas.
	If TamSX3("TF_SUBSTIT")[1] == 11 .And. ( lVerSubst .Or. !Empty(STJ->TJ_SUBSTIT) )
		NGAgluFim()
	EndIf

	//GERA O.S AUTOMATICA POR CONTADOR
	If cBEMCO <> NIL
		If cGERAPREV $ "SC" .And. (!Empty(nPOSCONT) .Or. !Empty(nPOSCON2))
			If NGCONFOSAUT(cGERAPREV)
				NGGEROSAUT(cBEMCO,If(!Empty(nPOSCONT),nPOSCONT,nPOSCON2),PFIL)
			Endif
		EndIf
	EndIf

	//-------------------------------
	// GERA O.S AUTOMATICA POR TEMPO
	//-------------------------------
	If STJ->TJ_PLANO != '000000'

		NGOSABRVEN(STJ->TJ_CODBEM,STJ->TJ_SERVICO,.F.,.T.,.F.,STJ->TJ_SEQRELA)
		If GETMV("MV_NGOSAUT") == "S"
		NGOSPORTEM(STJ->TJ_CODBEM,STJ->TJ_SERVICO,STJ->TJ_SEQRELA,lShowMens)
		EndIf
		
	EndIf

	// INICIO DO PROCESSO DE INTEGRA€ÇO COM O MàDULO SIGASGA
	If Len(aSGAINS) > 0 .AND. FunName() != "MNTA400" .AND. FunName() != "MNTA415"
		DbSelectArea("SX6")
		DbSetOrder(1)
		If DbSeek(xFILIAL("SX6")+"MV_SGAMNT")
			If GETMV("MV_SGAMNT") = "S"
				If FindFunction("SGINTMNT")
					SGINTMNT(aSGAINS,2)
				Endif
			Endif
		Endif
	Endif
	//Integracao com GEE
	If AllTrim(GetNewPar("MV_SGAMNT","N")) != "N" .and. FindFunction("SGAGEEPCP")
		SGAGEEPCP(cOS,"2")
	Endif
	// FIM DO PROCESSO DE INTEGRA€ÇO COM O MàDULO SIGASGA

	RestArea( aAreaD3 )

	DbSelectArea("STJ")
	Dbgoto(Recstjf)

Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} NGFINALPD2
Processa a Finalização da O.S. Pelo Padrão
@type function

@author  Inacio Luiz Kolling
@since   20/08/2001

@param  cOS    , string, Número da Ordem de Serviço
        cPLANO , string, Plano de Manutenção

@return boolean, Indica se o processo ocorreu corretamente.
/*/
//-------------------------------------------------------------------
Function NGFINALPD2(cOS,cPLANO)

	Local aRetSD3    := {}
	Local nz         := 0
	Local nCustoAtu  := 0.00
	Local lOSHESTO   := .F.
	Local cSEQSTL    := ""
	Local lMMoeda    := NGCADICBASE("TL_MOEDA","A","STL",.F.)
	Local cFieldName := ""
	Local lRet       := .T.
	
	cNGERROR := "  "
	nMDO     := 0.00
	nTRO     := 0.00
	nSUB     := 0.00
	nAPO     := 0.00
	nTER     := 0.00

	DbSelectArea("STJ")
	DbSetOrder(1)
	If !DbSeek(xFilial("STJ") + cOS + cPLANO)
		cNGERROR := STR0010 //"ORDEM/PLANO  DE MANUTENCAO NAO EXISTE"
		Return .F.
	EndIf

	lOSHESTO := ( lIntegES .And. !lHistEst .And.;
		STJ->TJ_SERVICO == 'HISTOR' )
	
	// INICIO NOVA ROTINA DE FINALIZA€ÇO PELO PADRÇO
	M->TJ_ORDEM := cOS
	M->TJ_PLANO := cPLANO
	M->TL_ORDEM := cOS
	M->TL_PLANO := cPLANO

	Begin Transaction

		DbSelectArea(cTRBP400)
		DbGoTop()
		ProcRegua(LastRec())

		While (cTRBP400)->( !EoF() )

			cSEQSTL := ULTSEQ()

			IncProc()
			DbSelectArea("STL")
			RecLock("STL",.T.)
			STL->TL_FILIAL  := xFilial("STL")
			STL->TL_SEQRELA := cSEQSTL
			STL->TL_LOCAL   := (cTRBP400)->TL_LOCAL
			STL->TL_LOTECTL := (cTRBP400)->TL_LOTECTL
			STL->TL_NUMLOTE := (cTRBP400)->TL_NUMLOTE
			STL->TL_DTVALID := (cTRBP400)->TL_DTVALID
			STL->TL_LOCALIZ := (cTRBP400)->TL_LOCALIZ
			STL->TL_NUMSERI := (cTRBP400)->TL_NUMSERI

			For nz := 1 To Fcount()
				cFieldName := FieldName(nz)
				If cFieldName <> "TL_FILIAL"  .And. cFieldName <> "TL_SEQRELA" .And.;
				cFieldName <> "TL_SEQUENC" .And. cFieldName <> "TL_LOCAL"   .And.;
				cFieldName <> "TL_LOTECTL" .And. cFieldName <> "TL_NUMLOTE" .And.;
				cFieldName <> "TL_LOCALIZ" .And. cFieldName <> "TL_DTVALID" .And.;
				cFieldName <> "TL_NUMSERI"

					If STL->(FieldPos(cFieldName)) > 0
						&("STL->"+cFieldName) := &("(cTRBP400)->"+cFieldName)
					EndIf

				EndIf
			Next nz

			STL->(MsUnLock())

			If lIntegES .And. !lOSHESTO

				If STL->TL_TIPOREG $ 'P/M'
					aRetSD3 := MNTGERAD3( 'RE0', , , , .T., .T. )

					If aRetSD3[2]

						cNUMSEQ := aRetSD3[1]

						If NGPRODESP( SD3->D3_COD, .F., 'M' )

							NGAtuErp( 'SD3', 'INSERT' )

						EndIf

						RecLock( 'STL', .F. )
						
							STL->TL_CUSTO  := SD3->D3_CUSTO1
							STL->TL_NUMSEQ := cNUMSEQ

						STL->( MsUnLock() )

					Else

						lRet := .F.
						Exit

					EndIf			

				EndIf

			EndIf

			nCustoAtu := If(lMMoeda,xMoeda(stl->tl_custo,Val(stl->tl_moeda),1,stl->tl_dtinici,2),stl->tl_custo)

			If STL->TL_TIPOREG == "T"
				nTER := nTER + nCustoAtu
			ElseIf STL->TL_TIPOREG == "P"
				If STL->TL_DESTINO == "T"
					nTRO := nTRO + nCustoAtu
				ElseIf STL->TL_DESTINO == "S"
					nSUB := nSUB + nCustoAtu
				Else
					nAPO := nAPO + nCustoAtu
				EndIf
			Else
				nMDO := nMDO + nCustoAtu
			EndIf

			DbSelectArea(cTRBP400)
			DbSkip()

		End

		If !lRet

			DisarmTransaction()

		EndIf

	End Transaction

	// FIM NOVA ROTINA DE FINALIZA€AO PELO PADRAO
	DbSelectArea("STJ")

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGALMOXA  ³ Autor ³ Inacio Luiz Kolling   ³ Data ³25/09/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Traz o codigo do almaxarifado                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGALMOXA(cCODBEM,cCODPRO,cTIPOREG,lCHEKSB2)
	Local aArea		:= GetArea()
	Local cALMOXA 	:= Space(Len(sb1->b1_locpad))
	Local cCODTER 	:= SuperGetMv("MV_PRODTER",.F.,"") //Verifica o codigo do produto Terceiro
	// Verifica local padrao se no produto Terceiro não estiver preenchido
	Local cLocPad 	:= Padr( SuperGetMv("MV_NGLOCPA",.F.,""), TamSx3("NNR_CODIGO")[1] )

	If cTIPOREG == 'P'
		DbSelectArea('ST9')
		DbSetOrder(1)
		DbSeek(xFilial('ST9')+cCODBEM)

		cALMOXA := Posicione( 'CTT', 1, xFilial( 'CTT' ) + ST9->T9_CCUSTO, 'CTT_LOCAL' )

		DbSelectArea('SB1')
		DbSetOrder(1)
		DbSeek(xFilial('SB1')+cCODPRO)

		If lCHEKSB2 .and. !Empty(cALMOXA)
			DbSelectArea('SB2')
			DbSetOrder(1)
			If !DbSeek(xFilial('SB2')+cCODPRO+cALMOXA)
				cALMOXA := SB1->B1_LOCPAD
			EndIf
		EndIf

		cALMOXA := If(Empty(cALMOXA),SB1->B1_LOCPAD,cALMOXA)

		//Verificar o almoxerifado para o produto do tipo TERCEIRO
	ElseIf cTIPOREG = 'T'

		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+cCODTER)
			cALMOXA := SB1->B1_LOCPAD
		Else
			cALMOXA := cLocPad
		EndIf

	EndIf

	RestArea(aArea)

Return cALMOXA

//-------------------------------------------------------------------
/*/{Protheus.doc} NGCALCUSTI
Calcula o custo total do insumo

@author  Inácio Luiz Kolling
@since   27/06/2003
@version P11/P12

@param 	 cCODIN,      Caracter, Código do insumo
@param 	 cTIPR,	      Caracter, Tipo do insumo
@param 	 nQUANT,      Numérico, Quantidade
@param 	 [cLOCAL],    Caracter, Local estoque ( Almoxarifado )Não Obr.(SB1)
@param 	 cTIPOH,      Caracter, Tipo de unidade de hora
@param 	 [cEMP],      Caracter, Codigo da Empresa
@param 	 [cFIL],      Caracter, Codigo da Filial
@param 	 [nRecur],    Numérico, Quantidade de recurso
@param 	 [cSeqRel],   Caracter, Indica o _SEQRELA que sera validado
@param 	 [cMoeda],    Caracter, Moeda utilizada para conversao
@param   [nCustoOld], Numérico, Indica o valor do custo digitado anteriormente

@return nCusto, Numérico, Valor Custo do Insumo.
/*/
//-------------------------------------------------------------------
Function NGCALCUSTI(cCODIN,cTIPR,nQUANT,cLOCAL,cTIPOH,cEMP,cFIL,nRecur,cSeqRel,cMoeda,nCustoOld)

	Local aArea     := GetArea()
	Local cFilST1, cFilST2, lChangeMd
	Local nVALORUNI := 0.00
	Local cCodInsum := IIf( cTIPR == 'P', cCODIN, Substr( cCODIN, 1, 6 ) )
	Local cLOCAXSTL := Space(2)
	Local nQUANTCON := nQUANT
	Local cINTESTOQ
	Local cFilST0, cFilSB2, cFilSB1 ,cFilTPO, cFilSH4
	Local nQTDRec   := IIf(nRecur = Nil .Or. nRecur = 0,1,nRecur)
	Local lMMoeda   := NGCADICBASE("TL_MOEDA","A","STL",.F.) // Verifica implementacao Multi-Moeda
	Local nCusto	:= 0
	Local nCustoAtu := 0

	Default  nCustoOld := 0
	Default cMoeda := ""

	Private cMoedaAtu := "1"

	cEmp := If(Empty(cEMP),FWGrpCompany(),cEMP)
	lChangeMd := lMMoeda .And. !Empty(cMoeda) // Verifica se devera converter o valor

	cINTESTOQ := AllTrim(GetNewPar("MV_NGMNTES"))
	cVTIPOHOR := If(cTIPOH = Nil, AllTrim(GetNewPar("MV_NGUNIDT")) ,cTIPOH)
	cFilST1 := NGTROCAFILI("ST1",cFIL,cEMP)
	cFilST2 := NGTROCAFILI("ST2",cFIL,cEMP)
	cFilST0 := NGTROCAFILI("ST0",cFIL,cEMP)
	cFilSB2 := NGTROCAFILI("SB2",cFIL,cEMP)
	cFilSB1 := NGTROCAFILI("SB1",cFIL,cEMP)
	cFilTPO := NGTROCAFILI("TPO",cFIL,cEMP)
	cFilSH4 := NGTROCAFILI("SH4",cFIL,cEMP)

	If cTIPR <> "P" .And. cVTIPOHOR <> "D"
		nQUANTCON := NGCONVERHORA(nQUANT,cVTIPOHOR,"D",cEMP)
	Endif

	If cTIPR = "M"
		dbSelectArea('ST1')
		dbSetOrder(1)
		dbSeek( cFilST1 + cCodInsum )
		If Empty(ST1->T1_SALARIO)
			DbSelectArea("ST2")
			DbSetOrder(1)
			dbSeek( cFilST2 + cCodInsum )
			DbSelectArea("ST0")
			DbSetOrder(1)
			DbSeek(cFilST0+ST2->T2_ESPECIA)
			nVALORUNI := If(lChangeMd, NGCONVMD(ST0->T0_SALARIO, 1, cMoeda), ST0->T0_SALARIO)
		Else
			nVALORUNI := If(lChangeMd, NGCONVMD(ST1->T1_SALARIO, 1, cMoeda), ST1->T1_SALARIO)
		EndIf

		If cINTESTOQ = 'S'
			cCodInsum := MntGetPrdM()
			dbSelectArea("SB2")
			dbSetOrder(1)
			dbSeek( cFilSB2 + cCodInsum )
			nVALORUNI := SB2->B2_CM1
			cMoedaAtu := "1"
		EndIf

	ElseIf cTIPR == "E"

		DbSelectArea("ST0")
		DbSeek(cFilST0+cCodInsum)

		nVALORUNI := If(lChangeMd, NGCONVMD(ST0->T0_SALARIO, 1, cMoeda), ST0->T0_SALARIO)

	ElseIf cTIPR == "P"

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( cFilSB1 + cCodInsum )
		If Found() //Se registro encontrado
			If cINTESTOQ = 'S' //Custo Medio
				cLOCAXSTL := If(cLOCAL = Nil,sb1->b1_locpad,cLOCAL)
				DbSelectArea("SB2")
				DbSetOrder(1)
				DbSeek(cFilSB2+sb1->b1_cod+cLOCAXSTL)

				nVALORUNI := SB2->B2_CM1
				cMoedaAtu := "1"

			Else //Custo Standard

				nVALORUNI := If(lChangeMd, NGCONVMD(SB1->B1_CUSTD, Val(SB1->B1_MCUSTD), cMoeda), SB1->B1_CUSTD)
				cMoedaAtu := If(!lChangeMd, SB1->B1_MCUSTD, cMoedaAtu)

			EndIf
		EndIf

	ElseIf cTIPR == "T"

		DbSelectArea("TPO")
		dbSeek( cFilTPO + cCodInsum )
		If Found()
			If cINTESTOQ = 'S'
				If ValType( cSeqRel ) <> "C"
					cSeqRel := STL->TL_SEQRELA
				EndIf
				If Alltrim(cSeqRel) == "0"
					nVALORUNI := If(lChangeMd, NGCONVMD(TPO->TPO_CUSTO, Val(TPO->TPO_MOEDA), cMoeda), TPO->TPO_CUSTO)
					cMoedaAtu := If(!lChangeMd, "1", cMoedaAtu)
				EndIf
			Else
				nVALORUNI := If(lChangeMd, NGCONVMD(TPO->TPO_CUSTO, Val(TPO->TPO_MOEDA), cMoeda), TPO->TPO_CUSTO)
				cMoedaAtu := If(!lChangeMd, "1", cMoedaAtu)
			EndIf

		EndIf

	ElseIf cTIPR == "F"

		DbSelectArea("SH4")
		dbSeek( cFilSH4 + cCodInsum )
		If Found()

			If cINTESTOQ = 'S'
				If ValType( cSeqRel ) <> "C"
					cSeqRel := STL->TL_SEQRELA
				EndIf
				If Alltrim(cSeqRel) == "0"
					nVALORUNI := If(lChangeMd, NGCONVMD(SH4->H4_CUSTOH, 1, cMoeda), SH4->H4_CUSTOH)
				Else
					nVALORUNI :=  SH4->H4_CUSTOH
				EndIf
			Else
				nVALORUNI :=  SH4->H4_CUSTOH
			EndIf

		EndIf

	EndIf

	If ExistBlock("NGCALCUSTI")
		nCustoAtu := (nVALORUNI*nQUANTCON*nQTDRec)
		nCusto := ExecBlock("NGCALCUSTI", .F., .F., { nCustoAtu, cTIPR, cCODIN, nQUANT, nRecur, nVALORUNI, cLOCAL, cTIPOH, cSeqRel, cEMP, cFIL, nCustoOld })
	Else
		nCusto := (nVALORUNI*nQUANTCON*nQTDRec)
	EndIf

	// Impl. Multi-Moeda
	If lMMoeda .And. Type("cMdCusto") == "C"
		cMdCusto := cMoedaAtu
	Endif

	RestArea( aArea ) 

Return nCusto

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NGAtuManut
Atualiza a data e o acumulado da manutencao.
@type function

@author Inacio Luiz Kolling
@since 11/03/2003

@sample NGAtuManut()

@param cCodBem , Caracter, Código do Bem.
@param cServico, Caracter, Serviço referente a manutenção.
@param nSequens, Numérico, Numéro da sequencia de manutenção.
@param dDataLei, Date    , Data de atualização.
@param cHoraLei, Caracter, Hora de atualização.
@param [nDif]  , Numérico, Diferença de contador.
@param cHCont1 , Caracter, Hora de Leitura do contador 1.
@param cHCont2 , Caracter, Hora de Leitura do contador 2.
@param pFil    , Caracter, Filial para troca.
@param [cEmp]  , Caracter, Empresa para troca.

@return .T.
/*/
//----------------------------------------------------------------------------------------------------------
Function NGATUMANUT(cCODBEM,cSERVICO,nSEQUENS,dDATALEI,hHORALEI,nDIF,cHCONT1,cHCONT2,PFIL,cEmp)

	Local nTipoC     := 0
	Local cAliasQry  := GetNextAlias()
	Local aAreaL     := GetArea()
	Local nSEQUENC   := If(ValType(nSEQUENS) = "C",nSEQUENS,Str(nSEQUENS,3))
	Local cFilAST9   := NGTROCAFILI("ST9",PFIL)
	Local cFilASTF   := NGTROCAFILI("STF",PFIL)
	Local cFilASTJ   := NGTROCAFILI("STJ",PFIL)
	Local cFilASTP   := NGTROCAFILI("STP",PFIL)

	//Em um levantamento foi verificado que o cEmp não é mais passado no parâmetro. No entanto foi mantido
	//por compatibilidade
	Default cEmp := cEmpAnt

	If NGIFDBSEEK( "ST9", cCODBEM, 1, .F., cFilAST9 )
		If NGIFDBSEEK( "STF", cCODBEM+cSERVICO+nSEQUENC, 1, .F., cFilASTF )

			nTipoC   := IIf(STF->TF_TIPACOM = "S",2,1)
			cFilASTP := IIf(nTipoC = 1,cFilASTP,NGTROCAFILI("TPP",PFIL))

			cQuery := "SELECT STJ.TJ_ORDEM, STJ.TJ_DTMRFIM, STJ.TJ_HORACO1, STJ.TJ_HORACO2, STJ.TJ_HOMRFIM"
			cQuery += " FROM " + RetSQLName("STJ") + " STJ"
			cQuery += " INNER JOIN " + RetSQLName("STF") + " STF "
			cQuery +=     "ON STJ.TJ_CODBEM  = STF.TF_CODBEM  AND "
			cQuery +=        "STJ.TJ_SERVICO = STF.TF_SERVICO AND "
			cQuery +=        "STJ.TJ_SEQRELA = STF.TF_SEQRELA AND "
			cQuery +=        NGModComp("STF", "STJ")
			cQuery += " WHERE  STJ.TJ_CODBEM  = " + ValToSql(cCODBEM)
			cQuery +=    " AND STJ.TJ_SERVICO = " + ValToSql(cSERVICO)
			cQuery +=    " AND STJ.TJ_SEQRELA = " + ValToSql(nSEQUENC)
			cQuery +=    " AND STF.TF_FILIAL  = " + ValToSQL(cFilASTF)
			cQuery +=    " AND STJ.TJ_SITUACA = 'L' "
			cQuery +=    " AND STJ.TJ_TERMINO = 'S' "
			cQuery +=    " AND STJ.TJ_TIPOOS  = 'B' "
			cQuery +=    " AND STF.D_E_L_E_T_ <> '*'"
			cQuery +=    " AND STJ.D_E_L_E_T_ <> '*'"

			If ST9->T9_TEMCONT <> "N" .And. STF->TF_TIPACOM <> "T"
				cQuery += " AND (STJ.TJ_POSCONT > 0 OR STJ.TJ_POSCON2 > 0)"
			EndIf

			If ST9->T9_TEMCONT <> "N" .And. STF->TF_TIPACOM <> "T"
				cQuery += IIf(nTipoC = 1," ORDER BY STJ.TJ_DTMRFIM||STJ.TJ_HORACO1 DESC "," ORDER BY STJ.TJ_DTMRFIM||STJ.TJ_HORACO2 DESC ")
			Else
				cQuery += " ORDER BY STJ.TJ_DTMRFIM||STJ.TJ_HOMRFIM DESC "
			EndIf

			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

			If !Eof() .And. !Empty((cAliasQry)->TJ_DTMRFIM)
				dDataA := Stod((cAliasQry)->TJ_DTMRFIM)
				DbSelectArea("STF")
				RecLock("STF",.F.)
				If ST9->T9_TEMCONT <> "N" .And. STF->TF_TIPACOM <> "T"
					cHoraA   := If(nTipoC = 1,(cAliasQry)->TJ_HORACO1,(cAliasQry)->TJ_HORACO2)
					vRetHist := NGACUMEHIS(cCodbem,dDataA,cHoraA,nTipoC,"E",cFilASTP)
					If !Empty(vRetHist[2])
						dDataA := vRetHist[3]
						STF->TF_CONMANU := vRetHist[2]
					EndIf
				EndIf

				STF->TF_DTULTMA := dDataA
				STF->(MsUnLock())

				//Altera a SH1 para que a data da última manutenção seja preenchida conforme na STF.
				If ST9->T9_FERRAME == "R"
					DbSelectArea("SH1")
					dbSetOrder(1)
					If Dbseek(cFilAST9+ST9->T9_RECFERR)
						RecLock("SH1",.F.)
						SH1->H1_ULTMANU := dDataA
						SH1->(MsUnLock())
					EndIf
				EndIf

			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaL)

Return .T.

//FAZ O MESMO PROCESSO QUE O GERAMANUT.PRX, FOI ADICIONADO E CHAMADO NOS PROGRAMAS
//COM ESSE NOME PARA QUE NA VER811 MATE O MESMO, E O NGUTIL03 COMPORTE A FUNCAO PADRAO PARA
//GERACAO DE O.S AUTOMATICA POR CONTADOR.
//---------------------------------------------------------------------
/*/{Protheus.doc} NGGEROSAUT
Programa Cria o.s. PREVENTIVAS
@type function

@author Thiago Olis Machado
@since 18/04/2001

@param cBEM        , Caracter, Código do bem
@param nContad     , Data    , Contador do bem
@param PFIL        , Caracter, Código da filial de processamento
@param [aTrbEst]   , Array   , Array possuindo as tabelas temporárias responsalve por montar a estrutura do bem.
							[1] tabela temporaria do pai da estrutura - cTRBS
							[2] tabela temporaria do pai da estrutura - cTRBF
							[3] tabela temporaria do eixo suspenso    - CTRBEixo
@param [lCONUS1VEZ], boolean , Indica se a consulta deve ocorrer apenas uma vez.
@param [lGerOsAut] , boolean , Indica se a O.S. automatica está habilitada.
@param aVldMNT     , array   , Array contendo os Recnos da STF que não irão gerar O.S.
								aVldMNT[x,1] - Recno STF
								aVldMNT[x,2] - Define que não irá gerar O.S

@return True
/*/
//---------------------------------------------------------------------
Function NGGEROSAUT( cBem, nContad, PFIL, aTrbEst, lCONUS1VEZ, lGerOsAut, aVldMNT, nTipCont )
	
	Local cALIASOC, nORDIOLC, nRECGARC
	Local aARRCOMP     := {}
	Local cGOSESTRU    := AllTrim(GETMv("MV_NGOSAES"))
	Local cVERGEROS    := AllTrim(GETMv("MV_NGVEROS"))
	Local cFilGSTC     := NGTROCAFILI("STC",PFIL)

	Private aNewSC     := {} // Utilizado na regra de produto alternativo

	Default aTrbEst    := {}
	Default lCONUS1VEZ := .F.
	Default lGerOsAut  := .F.
	Default nTipCont   := 0

	dbSelectArea("STF")
	dbSetOrder(01)
	cALIASOC := Alias()
	nORDIOLC := IndexOrd()
	nRECGARC := Recno()

	If !Empty(nCONTAD)
		If ExistBlock("NGAUTCLI")
			ParamIXB := {cBem,nContad,PFIL}
			ExecBlock("NGAUTCLI",.F.,.F.,{cBem,nContad,PFIL})
		Else
			
			If !FwIsInCallStack( 'MNTA655' )
			
				If cVERGEROS == "V"
					If GetRemoteType() > -1 // -1 = Job, Web ou Working Thread (Sem remote)
						lCONUS1VEZ := MsgYesNo(STR0015+chr(13); //"Deseja gerar OS automática por contador mesmo que já exista OS aberta"
						+STR0016+chr(13)+chr(13); //"para o mesmo Bem+Serviço+Sequência ?"
						+STR0017,STR0018) //"Confirma (Sim/Não)" # "ATENÇÃO"
					Else
						lCONUS1VEZ := .F. //quando executado pelo webservice não irá gerar caso já exista
					EndIf
				EndIf

			EndIf

			Processa({|lEnd| NGGPREVAUT( cBem, nContad, PFIL, .F., , cVERGEROS, lCONUS1VEZ, aVldMNT, nTipCont )})

			dbSelectArea("STC")
			dbSetOrder(01)
			If dbSeek(cFilGSTC+cBem)

				//GERAR O.S AUTOMATICA POR CONTADOR PARA OS COMPONENTES DA ESTRUTURA QUE SAO CONTROLADOS POR CONTADOR
				If (cGOSESTRU = "S" .Or. cGOSESTRU = "C")
					If cGOSESTRU = "C"
						If lGerOsAut .Or. ( ( GetRemoteType() == -1 .Or. MsgYesNo(STR0019 + chr(13)+chr(13); //"Deseja que seja verificado a existência de o.s automática por contador"
							+STR0020 + Chr(13)+Chr(13)+STR0017 ) ) ) //"para os componentes da estrutura de bens ?" # "Confirma (Sim/Nao)"

							aARRCOMP := NGCOMPPCONT(cBem,dDataBase,SubStr(Time(),1,5),PFIL,aTrbEst)

							If Len(aARRCOMP) > 0
								Processa({|lEnd| NGGPREVAUT(cBem,nContad,PFIL,.T.,aARRCOMP,cVERGEROS,lCONUS1VEZ, aVldMNT )})
							EndIf
						EndIf
					Else
						aARRCOMP := NGCOMPPCONT(cBem,dDataBase,SubStr(Time(),1,5),PFIL,aTrbEst)

						If Len(aARRCOMP) > 0
							Processa({|lEnd| NGGPREVAUT(cBem,nContad,PFIL,.T.,aARRCOMP,cVERGEROS,lCONUS1VEZ, aVldMNT )})
						EndIf
					EndIf
				EndIf

			EndIf
		EndIf
	EndIf

	dbSelectArea(cALIASOC)
	dbSetOrder(nORDIOLC)
	dbGoto(nRECGARC)

Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGGPREVAUT
Grava a O.S 
@type function

@author Thiago Olis Machado
@since 18/04/2001

@param [cBEM]    , string  , Código do bem
@param [nContad] , numeric , Contador do bem
@param [PFIL]    , string  , Código da filial de processamento
@param [lSTR]    , boolean , Indica se a verificacao de o.s automatica 
por contador e para os componentes da estrutura.
@param aESTRUOS  , arrau   , Array contendo os componentes da estrutura.
@param cVERGEROS , string  , Parametro de verificacao de os aberta.
@param lCONUS1VEZ, boolean , Indica se a consulta será realizada uma vez.
@param aVldMNT   , array   , Array contendo os Recnos da STF que não irão gerar O.S.
								aVldMNT[x,1] - Recno STF
								aVldMNT[x,2] - Define que não irá gerar O.S

@return 
/*/
//---------------------------------------------------------------------
Function NGGPREVAUT( cBem, nContad, PFIL, lSTR, aESTRUOS, cVERGEROS, lCONUS1VEZ, aVldMNT, nTipCont )

	Local ic        := 0
	Local lSTRUT    := If(lSTR <> nil,lSTR,.F.)
	Local cMensag   := " "
	Local xConteudo := ""
	Local cTipo     := ""
	Local nTamanho  := 0

	Private nNUMOSGE := 0
	Private dMENOR   := Ctod('  /  /  '),dMAIOR := dMENOR
	Private cMEORD   := Space(Len(stj->tj_ordem)), cMAORD := cMEORD
	Private dDPROXM

	Default nTipCont := 0

	If lSTRUT
		For ic := 1 To Len(aESTRUOS)
			NGGOSAUT(aESTRUOS[ic][1],PFIL,cVERGEROS,lCONUS1VEZ, aVldMNT )
		Next ic
	Else

		NGGOSAUT( cBem, PFIL, cVERGEROS, lCONUS1VEZ, aVldMNT, nTipCont )

	EndIf

	If Alltrim(GetMv("MV_NGIOSAU")) = "S"  .And. GetRemoteType() > -1 //-1 = Job, Web ou Working Thread (Sem remote)

		//Alerta que foi gerada O.S automatica por contador
		If nNUMOSGE > 0

			If lSTRUT
				cMensag := STR0021+chr(13)+chr(13)+STR0022+Chr(13)+Chr(13)+STR0023 //"Foi gerada automaticamente O.S preventiva controlada por"# "contador para os componentes da estrutura de bens."
			Else
				cMensag := STR0024+chr(13)+chr(13)+STR0025 + cBem+Chr(13)+Chr(13)+STR0023 //"Foi gerada automaticamente O.S preventiva controlada por"
				//"contador para o bem deseja imprimir
			EndIf

			If MsgYesNo(cMensag)

				aMATSX1 := {{'01',"000001"    },{'02',"000001"},;
				            {'07','S'         },{'08','Z'},;
				            {'09','S'         },{'10','Z'},;
				            {'11','S'         },{'12','Z'},;
				            {'13',cMEORD      },{'14',cMAORD},;
				            {'15',Dtoc(dMENOR)},{'16',Dtoc(dMAIOR)}}

				//Array para o relatorio MNTR676
				aMATSX16 := {{'01',"000001"},{'02',"000001"},;
				             {'03',Replicate(' ',TamSx3("T9_CODBEM")[1])},{'04',Replicate('Z',TamSx3("T9_CODBEM")[1])},;
				             {'05',cMEORD},{'06',cMAORD},;
				             {'07',Dtoc(dMENOR)},{'08',Dtoc(dMAIOR)}}

				If Dtos(Ctod(aMATSX1[11,2])) < Dtos(Ctod(aMATSX1[10,2]))
					dTAUXI        := aMATSX1[10,2]
					aMATSX1[10,2] := aMATSX1[11,2]
					aMATSX1[11,2] := dTAUXI
				Endif

				For ic := 1 To Len(aMATSX1)

                    cTipo     := Posicione("SX1",1,"MNT675"+Space(4)+aMATSX1[ic][1],"X1_TIPO")
                    nTamanho  := Posicione("SX1",1,"MNT675"+Space(4)+aMATSX1[ic][1],"X1_TAMANHO")
					xConteudo := IIf(aMATSX1[ic][2] == 'S',Space(nTamanho),If(aMATSX1[ic][2] == 'Z',Replicate('Z',nTamanho),aMATSX1[ic][2]))

					If cTipo == "C"
						aMATSX1[ic][2] := Left(xConteudo,nTamanho)
					ElseIf cTipo == "D"
						aMATSX1[ic][2] := CTOD(aMATSX1[ic][2])
					EndIf

				Next ic

				If ExistBlock("MNTROSA")
					ExecBlock("MNTROSA",.F.,.F.)
				Else
					MNTR676(.f.,,,,,aMATSX16,aMATSX1)
				Endif
			EndIf
		EndIf
	EndIf

Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} NGCHKMESFE
Consistencia de fechamento do estoque

@author  Inácio Luiz Kolling
@since   15/09/2004
@version P11/P12
@param   dVDATAF  , Data    , Data de movimentacao
@param   cTPINSU  , Caracter, Tipo do insumo
@param   [lMENSAI], Lógico  , Saída do alerta
@return  Lógico, define se pode ser digitada movimentação
/*/
//-------------------------------------------------------------------
Function NGCHKMESFE(dVDATAF,cTPINSU,lMENSAI)
	Local dDTULMES := GetMv("MV_ULMES"),lSAIMEN := If(lMENSAI = Nil,.t.,lMENSAI)
	If AllTrim(GetMv("MV_NGMNTES")) = "S" .And. (cTPINSU = "P" .Or. cTPINSU = "M") .And. !Empty(dDTULMES)
		If dVDATAF <= dDTULMES
			If lSAIMEN
				// "Não pode ser digitado movimento com data anterior a última data de fechamento (virada de saldos)."
				// "Informe uma data posterior a última data de fechamento. Data de Fechamento: "
				HELP( ' ', 1, "FECHTO",, STR0026, 2, 0,,,,,, { STR0027 + DTOC( dDTULMES ) } )
			Endif
			Return .f.
		Endif
	Endif
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSTLSD3COMP³ Autor ³In cio Luiz Kolling  ³ Data ³14/07/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os campos complementares do STL para SD3 e vice versa ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paramentro³vALIAP  - Alias do arquivo com os valores - Obrigatorio     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGSTLSD3COMP(vALIAP)
	Local nVP      := 0
	Local cPRER    := If(vALIAP = "STL","D3","TL")
	Local cALIVAL  := If(vALIAP = "STL","STL","SD3")
	Local cALIREC  := If(vALIAP = "STL","SD3","STL")
	Local vVETCAMN := {"_FILIAL","_LOCAL","_NUMSEQ","_ORDEM"}
	Local aESTRUT  := {}

	DbSelectArea(cALIREC)
	aESTRUT := DbStruct()

	RecLock(cALIREC,.F.)
	DbSelectArea(cALIVAL)
	For nVP := 1 To Fcount()
		ny := Fieldname(nVP)
		nc := cALIREC+"->"+cPRER+Alltrim(Substr(ny,3,Len(ny)))
		cCAMPP := Alltrim(Substr(ny,3,Len(ny)))
		If Ascan(vVETCAMN, {|x| x == Alltrim(Substr(ny,3,Len(ny)))}) = 0
			If Ascan(aESTRUT, {|x| Alltrim(Substr(x[1],3,Len(x[1]))) == cCAMPP}) > 0
				nx   := cALIVAL+"->"+Fieldname(nVP)
				&nc. := &nx.
			Endif
		Endif
	Next
	(cALIREC)->(MsUnLock())
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGDTHORFINAL³ Autor ³In cio Luiz Kolling  ³ Data ³28/07/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula maior e menor data e hora                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametors³vVDTIN  - Data inicio do insuno                             ³±±
±±³          ³vVHORI  - Hora inicio do insuno                             ³±±
±±³          ³vVDTFI  - Data final  do insuno                             ³±±
±±³          ³vVHORF  - Hora final  do insuno                             ³±±
±±³          ³vVTIN   - Tipo do insuno                                    ³±±
±±³          ³vVSEQ   - Sequencia do insuno (nome do campo)               ³±±
±±³          ³vVSEQP  - Tipo do insumo para calculo (Previsto,Real)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observa‡ao³Devera ser declarado as variaveis vVETRE := {},lPRIMD := .T.³±±
±±³          ³antes de chamar a fun‡Æo fora do loop se tiver              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGDTHORFINAL(vVDTIN,vVHORI,vVDTFI,vVHORF,vVTIN,vVSEQ,vVSEQP)
	Local cTIPSEQ := If(ValType(vVSEQ) == "C","C","N")
	Local vTIPSEQ := If(cTIPSEQ == "C", If (vVSEQP == "P",'"'+Alltrim(vVSEQ)+'" == "0"',;
	 '"0" <> "'+Alltrim(vVSEQ)+'"' ), If(vVSEQP == "P",'vVSEQ == 0' ,'vVSEQ <> 0'))
	
	/* Ponto de entrada para uso exclusivo do cliente Expresso Nepomuceso.
	   Não deve ser utilizado ou disponibilizado para outro cliente.
	   Este ponto de entrada será removido futuramente. 
	*/
	If ExistBlock("NG_ESN")
		ExecBlock("NG_ESN",.F.,.F.)		
	ElseIf &vTIPSEQ
		If lPRIMD
			lPRIMD := .F.
			dMAXDT := If(vVTIN == "P",vVDTIN,vVDTFI)
			hMAXDT := If(vVTIN == "P",vVHORI,vVHORF)
			Aadd(vVETRE,vVDTIN)
			Aadd(vVETRE,vVHORI)
			Aadd(vVETRE,vVDTFI)
			Aadd(vVETRE,vVHORF)
		Else
			If vVDTIN < vVETRE[1]
				vVETRE[1] := vVDTIN
				vVETRE[2] := vVHORI
			ElseIf vVDTIN = vVETRE[1]
				vVETRE[2] := If(vVHORI < vVETRE[2],vVHORI,vVETRE[2])
			Endif

			dMAXFT := If(vVTIN == "P",vVDTIN,vVDTFI)
			hMAXFT := If(vVTIN == "P",vVHORI,vVHORF)

			If dMAXFT > vVETRE[3]
				vVETRE[3] := dMAXFT
				vVETRE[4] := hMAXFT
			Elseif dMAXFT = vVETRE[3]
				vVETRE[3] := If(dMAXFT > vVETRE[3],dMAXFT,vVETRE[3])
				vVETRE[4] := If(hMAXFT > vVETRE[4],hMAXFT,vVETRE[4])
			Endif
		Endif
	Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGVALDATIN³ Autor ³ Elisangela Costa      ³ Data ³ 24/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o intervalo de data/hora do insumo tipo mao de obra, ³±±
±±³          ³terceiro e ferramenta                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCODINSU  - Codigo do insumo                                ³±±
±±³          ³cORDEMSTL - Data inicio de aplicacao do insumo              ³±±
±±³          ³cPLANOSTL - Data inicio de aplicacao do insumo              ³±±
±±³          ³dDTINISTL - Data inicio de aplicacao do insumo              ³±±
±±³          ³cHRINISTL - Hora inicio de aplicao do insumo                ³±±
±±³          ³dDTFIMSTL - Data fim de aplicacao do insumo                 ³±±
±±³          ³cHRFIMSTL - Hora fim de aplicao do insumo                   ³±±
±±³          ³cTIPOINS  - Tipo do insumo                                  ³±±
±±³          ³nREGLOG   - Numero do Recno, registro logico quando altera- ³±±
±±³          ³            cao e obrigatorio                               ³±±
±±³          ³cALIASOS  - Alias para verificacao (STL/STT)                ³±±
±±³          ³cORDEMNAO - Codigo da O.S a nao ser verificado              ³±±
±±³          ³cPLANONAO - Codigo do Plano a nao ser verificado            ³±±
±±³          ³nRecnoTTL - Número do Recno da tabela TTL					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT - Retorno de insumo                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGVALDATIN(cCODINSU,cORDEMSTL,cPLANOSTL,dDTINISTL,cHRINISTL,dDTFIMSTL,;
	cHRFIMSTL,cTIPOINS,nREGLOG,cALIASOS,cORDEMNAO,cPLANONAO,nRecnoTTL)
	Local cALIOLD := Alias()
	Local nORDOLD := IndexOrd()
	Local lREGLOG := If(nREGLOG <> Nil,.T.,.F.)
	Local vARQVAR := If(cALIASOS = "STL",{'STL',8,'STL->TL_FILIAL','STL->TL_CODIGO',;
	'STL->TL_SEQRELA','STL->TL_ORDEM',;
	'STL->TL_PLANO','STL->TL_DTINICI',;
	'STL->TL_DTFIM','STL->TL_HOINICI',;
	'STL->TL_HOFIM','STL->TL_TIPOREG'},;
	{'STT',3,'STT->TT_FILIAL','STT->TT_CODIGO',;
	'STT->TT_SEQRELA','STT->TT_ORDEM',;
	'STT->TT_PLANO','STT->TT_DTINICI',;
	'STT->TT_DTFIM','STT->TT_HOINICI',;
	'STT->TT_HOFIM','STT->TT_TIPOREG'})
	Local _cGetDB := TcGetDb()
	Local cHrIniTemp := cHRINISTL
	Local cHrFimTemp := cHRFIMSTL
	Local dDtIniTemp := dDTINISTL
	Local dDtFimTemp := dDTFIMSTL


	Local aArea := GetArea()

	Private dDTINIAPL := Ctod('  /  /  '), cHRINIAPL := "  :  "  //Data e hora inicio de aplicacao do insumo
	Private dDTFIMAPL := Ctod('  /  /  '), cHRFIMAPL := "  :  "  //Data e hora inicio de aplicacao do insumo
	Private cORDEMSER := Space(Len(&(vARQVAR[6]))) //Ordem de servico de aplicacao do insumo
	Private cPLANPSER := Space(Len(&(vARQVAR[7]))) //Plano de aplicacao do insumo
	Private lMENSINS  := .F.                        //Variavel logica do controle do While
	Private nQUATFEU  := 0                          //Guarda a quantidade da mesma ferrameta utilizada no mesmo intervalo de data/hora
	Private nQUATISH4 := 0                          //Guarda a quantidade de ferramenta disponivel no SH4

	If cTIPOINS == "F"
		dbSelectArea("SH4")
		dbSeek(xFilial("SH4")+SubStr(M->TL_CODIGO,1,6))
		nQUATISH4 := SH4->H4_QUANT
	EndIf

	//Validacao para permitir insumos no mesmo intervalo de data/hora inicio/fim
	If cHRINISTL == '23:59'
		dDTINISTL += 1
	EndIf
	If cHRFIMSTL == '00:00'
		dDTFIMSTL -= 1
	EndIf
	cHRINISTL := MTOH(HTOM(cHRINISTL)+1)
	cHRFIMSTL := MTOH(HTOM(cHRFIMSTL)-1)
	If cHRFIMSTL < cHRINISTL .And. dDTINISTL == dDTFIMSTL
		cHRFIMSTL := cHRINISTL
	EndIf
	#IFDEF TOP
	cAliasQry := GetNextAlias()
	If cALIASOS == "STL"
		cQuery := " SELECT STL.TL_FILIAL,STL.TL_ORDEM,STL.TL_PLANO,STL.TL_CODBEM,STL.TL_DTINICI,STL.TL_HOINICI,STL.TL_DTFIM,STL.TL_HOFIM "
		cQuery += " FROM "+RetSQLName("STL")+" STL"
		cQuery += " LEFT JOIN "+RetSQLName("STJ")+" STJ ON STJ.TJ_FILIAL = STL.TL_FILIAL AND STJ.TJ_ORDEM = STL.TL_ORDEM AND"
		cQuery += "                                  STJ.TJ_SITUACA <> 'C' AND STJ.D_E_L_E_T_ != '*'"
		cQuery += " WHERE STL.TL_CODIGO = '"+cCODINSU+"' AND STL.TL_TIPOREG = '"+cTIPOINS+"' AND "
		cQuery += "       STL.TL_SEQRELA <> '0' AND STL.D_E_L_E_T_<>'*' AND STL.TL_FILIAL = '"+xFilial("STL")+"'"
		cQuery += "       AND (('"+DtoS(dDTINISTL)+cHRINISTL+"' BETWEEN STL.TL_DTINICI||STL.TL_HOINICI  AND STL.TL_DTFIM||STL.TL_HOFIM"
		cQuery += "       	OR '"+DtoS(dDTFIMSTL)+cHRFIMSTL+"' BETWEEN STL.TL_DTINICI||STL.TL_HOINICI  AND STL.TL_DTFIM||STL.TL_HOFIM ) "
		cQuery += "       OR (STL.TL_DTINICI||STL.TL_HOINICI BETWEEN '"+DtoS(dDTINISTL)+cHRINISTL+"' AND '"+DtoS(dDTFIMSTL)+cHRFIMSTL+"' "
		cQuery += "       	OR STL.TL_DTFIM||STL.TL_HOFIM   BETWEEN '"+DtoS(dDTINISTL)+cHRINISTL+"' AND '"+DtoS(dDTFIMSTL)+cHRFIMSTL+"')) "
		If lREGLOG
			cQuery += " AND STL.R_E_C_N_O_<> "+AllTrim(Str(nREGLOG))
		EndIf
		If ValType(cORDEMNAO) = "C" .And. ValType(cPLANONAO) = "C"
			cQuery += " AND (STL.TL_ORDEM <> " + ValToSql(cORDEMNAO) + " OR STL.TL_PLANO <> " + ValToSql(cPLANONAO)+")"
		EndIf
		cQuery += " ORDER BY STL.TL_FILIAL,STL.TL_ORDEM"

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		While !Eof()
			NGCARRINSU(StoD((cAliasQry)->TL_DTINICI),(cAliasQry)->TL_HOINICI,StoD((cAliasQry)->TL_DTFIM),(cAliasQry)->TL_HOFIM,(cAliasQry)->TL_ORDEM,;
			(cAliasQry)->TL_PLANO,If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
			dbSelectArea(cAliasQry)
			dbSkip()
		End
		(cAliasQry)->(DbCloseArea())
	Else
		cQuery := " SELECT STT.TT_FILIAL,STT.TT_ORDEM,STT.TT_PLANO,STT.TT_CODBEM,STT.TT_DTINICI,STT.TT_HOINICI,STT.TT_DTFIM,STT.TT_HOFIM "
		cQuery += " FROM "+RetSQLName("STT")+" STT"
		cQuery += " LEFT JOIN "+RetSQLName("STS")+" STS ON STS.TS_FILIAL = STT.TT_FILIAL AND STS.TS_ORDEM = STT.TT_ORDEM AND"
		cQuery += "                                  STS.TS_SITUACA <> 'C' AND STS.D_E_L_E_T_ != '*'"
		cQuery += " WHERE STT.TT_CODIGO = '"+cCODINSU+"' AND STT.TT_TIPOREG = '"+cTIPOINS+"' AND "
		cQuery += "       STT.TT_SEQRELA <> '0' AND STT.D_E_L_E_T_<>'*' AND STT.TT_FILIAL = '"+xFilial("STT")+"'"
		cQuery += "       AND (('"+DtoS(dDTINISTL)+cHRINISTL+"' BETWEEN STT.TT_DTINICI||STT.TT_HOINICI  AND STT.TT_DTFIM||STT.TT_HOFIM"
		cQuery += "       	OR '"+DtoS(dDTFIMSTL)+cHRFIMSTL+"' BETWEEN STT.TT_DTINICI||STT.TT_HOINICI  AND STT.TT_DTFIM||STT.TT_HOFIM ) "
		cQuery += "       OR (STT.TT_DTINICI||STT.TT_HOINICI BETWEEN '"+DtoS(dDTINISTL)+cHRINISTL+"' AND '"+DtoS(dDTFIMSTL)+cHRFIMSTL+"' "
		cQuery += "       	OR STT.TT_DTFIM||STT.TT_HOFIM   BETWEEN '"+DtoS(dDTINISTL)+cHRINISTL+"' AND '"+DtoS(dDTFIMSTL)+cHRFIMSTL+"')) "
		If lREGLOG
			cQuery += " AND STT.R_E_C_N_O_<> "+AllTrim(Str(nREGLOG))
		EndIf
		If ValType(cORDEMNAO) = "C" .And. ValType(cPLANONAO) = "C"
			cQuery += " AND (STT.TT_ORDEM <> " + ValToSql(cORDEMNAO) + " OR STT.TT_PLANO <> " + ValToSql(cPLANONAO)+")"
		EndIf
		cQuery += " ORDER BY STT.TT_FILIAL,STT.TT_ORDEM"

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		While !Eof()
			NGCARRINSU(StoD((cAliasQry)->TT_DTINICI),(cAliasQry)->TT_HOINICI,StoD((cAliasQry)->TT_DTFIM),(cAliasQry)->TT_HOFIM,(cAliasQry)->TT_ORDEM,;
			(cAliasQry)->TT_PLANO,If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
			dbSelectArea(cAliasQry)
			dbSkip()
		End
		(cAliasQry)->(DbCloseArea())
	Endif

	If AliasInDic("TTL")
		cAliasQry := GetNextAlias()
		cQuery := " SELECT TTL.TTL_FILIAL,TTL.TTL_DTINI,TTL.TTL_HRINI,TTL.TTL_DTFIM,TTL.TTL_HRFIM "
		cQuery += " FROM "+RetSQLName("TTL")+" TTL "
		cQuery += " WHERE TTL.TTL_CODFUN = '"+cCODINSU+"' AND "
		cQuery += "       TTL.D_E_L_E_T_<>'*' AND TTL.TTL_FILIAL = '"+xFilial("TTL")+"'"
		cQuery += "       AND (('"+DtoS(dDTINISTL)+cHRINISTL+"' BETWEEN TTL.TTL_DTINI||TTL.TTL_HRINI  AND TTL.TTL_DTFIM||TTL.TTL_HRFIM "
		cQuery += "       	OR '"+DtoS(dDTFIMSTL)+cHRFIMSTL+"' BETWEEN TTL.TTL_DTINI||TTL.TTL_HRINI  AND TTL.TTL_DTFIM||TTL.TTL_HRFIM ) "
		cQuery += "       OR (TTL.TTL_DTINI||TTL.TTL_HRINI BETWEEN '"+DtoS(dDTINISTL)+cHRINISTL+"' AND '"+DtoS(dDTFIMSTL)+cHRFIMSTL+"' "
		cQuery += "       	OR TTL.TTL_DTFIM||TTL.TTL_HRFIM   BETWEEN '"+DtoS(dDTINISTL)+cHRINISTL+"' AND '"+DtoS(dDTFIMSTL)+cHRFIMSTL+"')) "
		If ValType(nRecnoTTL) == "N"
			cQuery += " AND TTL.R_E_C_N_O_<> "+AllTrim(Str(nRecnoTTL))
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		If !Eof()
			MsgInfo(STR0028+ chr(13)+chr(13); //"Ja existe aplicacao de insumo no intervalo de Data/Hora informada."
			+STR0029 + cCODINSU+chr(13); //"Codigo Insumo: "
			+STR0030 + dtoc(dDtIniTemp)+chr(13); //"Data Inicio......: "
			+STR0031 + Substr(cHrIniTemp,1,5)+chr(13); //"Hora Inicio......: "
			+STR0032 + dtoc(dDtFimTemp)+chr(13); //"Data Fim.........: "
			+STR0033 + Substr(cHrFimTemp,1,5)+chr(13)+chr(13); //"Hora Fim.........: "
			+STR0049 + chr(13)+chr(13); //"Aplicacao do insumo ja existente:"
			+STR0030 + dtoc(STOD((cAliasQry)->TTL_DTINI))+chr(13); //"Data Inicio.....: "
			+STR0031 + Substr((cAliasQry)->TTL_HRINI,1,5)+chr(13); //"Hora Inicio.....: "
			+STR0032 + dtoc(STOD((cAliasQry)->TTL_DTFIM))+chr(13); //"Data Fim........: "
			+STR0033 + Substr((cAliasQry)->TTL_HRFIM,1,5),STR0005)//"Hora Fim........: "
			(cAliasQry)->(DbCloseArea())
			Return {.F.,0}
		Endif
		(cAliasQry)->(DbCloseArea())
	Endif

	#ELSE
	DbSelectArea(vARQVAR[1])
	DbSetOrder(vARQVAR[2])
	If DbSeek(xFILIAL(vARQVAR[1])+cTIPOINS+cCODINSU)
		While !Eof() .And. &(vARQVAR[3]) == xFILIAL(vARQVAR[1])        .And.;
		&(vARQVAR[12]) == cTIPOINS .And. &(vARQVAR[4]) == cCODINSU  .And.;
		!lMENSINS

			If lREGLOG
				If nREGLOG = Recno()
					dbSelectArea(vARQVAR[1])
					dbSkip()
					Loop
				EndIf
			EndIf

			If Alltrim(&(vARQVAR[5])) <> "0"

				If vARQVAR[1] == "STL"
					DbSelectArea("STJ")
					DbSetOrder(01)
					If DbSeek(xFILIAL("STJ")+&(vARQVAR[6])+&(vARQVAR[7]))
						If STJ->TJ_SITUACA = "C"
							DbSelectArea("STL")
							DbSkip()
							Loop
						EndIf
					EndIf
				EndIf

				DbSelectArea(vARQVAR[1])
				If dDTFIMSTL < &(vARQVAR[9])
					If dDTFIMSTL = &(vARQVAR[8])
						If cHRFIMSTL >= &(vARQVAR[10])
							//Carrega variaveis
							NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
							&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
							dbSkip()
							Loop
						EndIf
					ElseIf dDTINISTL > &(vARQVAR[8])
						//Carrega variaveis
						NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
						&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
						dbSkip()
						Loop

					ElseIf dDTFIMSTL > &(vARQVAR[8])
						//Carrega variaveis
						NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
						&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
						dbSkip()
						Loop

					EndIf
				Else
					If dDTFIMSTL > &(vARQVAR[9])
						If dDTINISTL = &(vARQVAR[9])
							If cHRINISTL <= &(vARQVAR[11])
								//Carrega variaveis
								NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
								&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
								dbSkip()
								Loop

							EndIf
						Else
							If dDTINISTL < &(vARQVAR[9])
								//Carrega variaveis
								NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
								&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
								dbSkip()
								Loop

							EndIf
						EndIf
					Else
						If dDTINISTL > &(vARQVAR[8])
							If dDTFIMSTL = &(vARQVAR[9])
								If dDTINISTL = &(vARQVAR[9])
									If cHRINISTL <= &(vARQVAR[11])
										//Carrega variaveis
										NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
										&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
										dbSkip()
										Loop

									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

				If dDTINISTL < &(vARQVAR[8])
					If dDTFIMSTL = &(vARQVAR[8])
						If cHRFIMSTL >= &(vARQVAR[10])
							//Carrega variaveis
							NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
							&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
							dbSkip()
							Loop
						EndIf
					Else
						If dDTFIMSTL = &(vARQVAR[9])
							//Carrega variaveis
							NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
							&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
							dbSkip()
							Loop
						EndIf
					EndIf
				Else
					If dDTINISTL > &(vARQVAR[8])
						If dDTINISTL <> &(vARQVAR[9])
							If dDTFIMSTL = &(vARQVAR[9])
								//Carrega variaveis
								NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
								&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
								dbSkip()
								Loop
							EndIf
						EndIf
					Else
						If dDTINISTL = &(vARQVAR[8])
							If dDTFIMSTL = &(vARQVAR[8])
							Else
								If dDTFIMSTL < &(vARQVAR[9])
									//Carrega variaveis
									NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
									&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
									dbSkip()
									Loop

								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

				If dDTINISTL = &(vARQVAR[8]) .And. dDTFIMSTL = &(vARQVAR[9])
					If &(vARQVAR[8]) = &(vARQVAR[9])  //DATAS IGUAIS MESMO DIA
						If cHRFIMSTL >= &(vARQVAR[10]) //INICIO DE ARQUIVO
							If cHRINISTL < &(vARQVAR[10])
								//Carrega variaveis
								NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
								&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
								dbSkip()
								Loop

							EndIf
						EndIf
						If cHRINISTL <= &(vARQVAR[11])   //FINAL DE ARQUIVO
							If cHRFIMSTL > &(vARQVAR[11])
								//Carrega variaveis
								NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
								&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
								dbSkip()
								Loop

							EndIf
						EndIf
						If cHRINISTL >= &(vARQVAR[10])
							If cHRFIMSTL <= &(vARQVAR[11])
								//Carrega variaveis
								NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
								&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
								dbSkip()
								Loop

							EndIf
						EndIf
					Else //DATAS IGUAIS DIAS DIFERENTE
						If cHRINISTL >= &(vARQVAR[10])
							//Carrega variaveis
							NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]),&(vARQVAR[11]),&(vARQVAR[6]),;
							&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
							dbSkip()
							Loop

						Else
							If cHRFIMSTL <= &(vARQVAR[11])
								//Carrega variaveis
								NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
								&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
								dbSkip()
								Loop

							EndIf
						EndIf
						If cHRINISTL <= &(vARQVAR[10]) .And. cHRFIMSTL >= &(vARQVAR[11])
							//Carrega variaveis
							NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
							&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
							dbSkip()
							Loop

						EndIf
					EndIf
				Else
					If dDTINISTL = &(vARQVAR[8]).And. dDTFIMSTL = &(vARQVAR[8])
						If cHRFIMSTL >= &(vARQVAR[10])
							//Carrega variaveis
							NGCARRINSU(&(vARQVAR[8]),&(vARQVAR[10]),&(vARQVAR[9]) ,&(vARQVAR[11]),&(vARQVAR[6]),;
							&(vARQVAR[7]),If(cTIPOINS <> "F",.T.,.F.),cTIPOINS)
							dbSkip()
							Loop

						EndIf
					EndIf
				EndIf
			EndIf
			DbSelectArea(vARQVAR[1])
			DbSkip()
		End
	EndIf
	#ENDIF

	//Retorna valores iniciais das variaveis
	cHRINISTL := cHrIniTemp
	cHRFIMSTL := cHrFimTemp
	dDTINISTL := dDtIniTemp
	dDTFIMSTL := dDtFimTemp

	If lMENSINS  .And. cTIPOINS <> "F"

		//Verifica se o insumo é de terceiro
		If cTIPOINS == "T"

			dbSelectArea("STJ")
			dbSetOrder(1)
			If dbSeek(xFilial("STJ") + cORDEMSER + cPLANPSER )

				If lREGLOG
					dbGoto(nREGLOG)
				EndIf

				RestArea(aArea)
				Return {.T.,0}

			EndIf

		EndIf

		If cORDEMSTL <> Nil .And. cPLANOSTL <> Nil
			MsgInfo(STR0028+ chr(13)+chr(13); //"Ja existe aplicacao de insumo no intervalo de Data/Hora informada."
			+STR0029 + cCODINSU+chr(13); //"Codigo Insumo: "
			+STR0035 + cORDEMSTL+chr(13); //"Ordem Serv....: "
			+STR0036 + cPLANOSTL+chr(13); //"Plano..............: "
			+STR0030 + dtoc(dDTINISTL)+chr(13); //"Data Inicio......: "
			+STR0031 + Substr(cHRINISTL,1,5)+chr(13); //"Hora Inicio......: "
			+STR0032 + dtoc(dDTFIMSTL)+chr(13); //"Data Fim.........: "
			+STR0033 + Substr(cHRFIMSTL,1,5)+chr(13)+chr(13); //"Hora Fim.........: "
			+STR0034 + chr(13)+chr(13); //"Aplicacao do insumo ja existente:"
			+STR0035 + cORDEMSER+chr(13); //"Ordem Serv....: "
			+STR0036 + cPLANPSER+chr(13); //"Plano.............: "
			+STR0030 + dtoc(dDTINIAPL)+chr(13); //"Data Inicio.....: "
			+STR0031 + Substr(cHRINIAPL,1,5)+chr(13); //"Hora Inicio.....: "
			+STR0032 + dtoc(dDTFIMAPL)+chr(13); //"Data Fim........: "
			+STR0033 + Substr(cHRFIMAPL,1,5),STR0005)//"Hora Fim........: "
		Else
			MsgInfo(STR0028+ chr(13)+chr(13); //"Ja existe aplicacao de insumo no intervalo de Data/Hora informada."
			+STR0034 + chr(13)+chr(13); //"Aplicacao do insumo ja existente:"
			+STR0045 + cORDEMSER+chr(13); //"Ordem Serv....: "
			+STR0036 + cPLANPSER+chr(13); //"Plano.............: "
			+STR0030 + dtoc(dDTINIAPL)+chr(13); //"Data Inicio.....: "
			+STR0031 + Substr(cHRINIAPL,1,5)+chr(13); //"Hora Inicio.....: "
			+STR0032 + dtoc(dDTFIMAPL)+chr(13); //"Data Fim........: "
			+STR0033 + Substr(cHRFIMAPL,1,5),STR0005)//"Hora Fim........: "

		EndIf

		Return {.F.,0}

	ElseIf cTIPOINS == "F"

		Return {.F.,nQUATFEU}

	EndIf

	If ValType(cALIOLD) <> Nil .And. ValType(nORDOLD) <> Nil .And. .Not. Empty(cALIOLD) .And. .Not. Empty(nORDOLD)
		DbSelectArea(cALIOLD)
		DbSetOrder(nORDOLD)

		If lREGLOG
			dbGoto(nREGLOG)
		EndIf
	EndIf
Return {.T.,0}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCARRINSU  ³ Autor ³Elisangela Costa     ³ Data ³24/08/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega Variaveis                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametors³vVDTINIAP - Data inicio do insuno                           ³±±
±±³          ³vVHRINIAP - Hora inicio do insuno                           ³±±
±±³          ³vVDTFIMAP - Data final  do insuno                           ³±±
±±³          ³vVHRFIMAP - Hora final  do insuno                           ³±±
±±³          ³vVORDEMS  - Ordem de servico do insumo                      ³±±
±±³          ³vVPLANPS  - Plano do insumo                                 ³±±
±±³          ³vVLMES    - .T. indica que achou insumo no intervalo        ³±±
±±³          ³vQUANTIF  - Quantidade da utilizada                         ³±±
±±³          ³vVTIPINS  - Tipo de insumo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGVALDATIN                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGCARRINSU(vVDTINIAP,vVHRINIAP,vVDTFIMAP,vVHRFIMAP,vVORDEMS,vVPLANPS,vVLMES,vVTIPINS)
	Local nRESTSH4 := 0

	dDTINIAPL := vVDTINIAP
	cHRINIAPL := vVHRINIAP
	dDTFIMAPL := vVDTFIMAP
	cHRFIMAPL := vVHRFIMAP
	cORDEMSER := vVORDEMS
	cPLANPSER := vVPLANPS
	lMENSINS  := vVLMES
	nQUATFEU  += 1

	If vVTIPINS == "F"
		nRESTSH4 := nQUATISH4 - nQUATFEU

		If nRESTSH4 <= 0
			lMENSINS := .T.
		EndIf

	EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGVALDISPM ³ Autor ³Elisangela Costa       ³ Data ³22/12/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se a mao de obra a ser reportada esta disponivel      ³±±
±±³          ³no cadastro do funcionario                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cTIPOINS = Tipo do insumo                                    ³±±
±±³          ³cCODIGO  = Codigo da mao de obra                             ³±±
±±³          ³lMOSTRAM = .T. Indica que mostra a mensagem, .F. nao         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGVALDISPM(cTIPOINS,cCODIGO,lMOSTRAM)
	Local lTIPOINS := .T., aAREAU := GetArea()

	If Vazio(cTIPOINS)
		Return .F.
	Endif

	If Type("cNGINSPREA") <> "U"  //Indica se o insumo e previsto ou realizado
		If cNGINSPREA = "R"
			If cTIPOINS = "M"
				cCODMADO := Substr(cCODIGO,1,Len(ST1->T1_CODFUNC))
				DbSelectArea("ST1")
				DbSetOrder(01)
				If DbSeek(xFilial("ST1")+cCODMADO)
					If ST1->T1_DISPONI = "N"
						lTIPOINS := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If !lTIPOINS
		If lMOSTRAM
			MSGINFO(STR0037,STR0005) //"Mao de obra indisponivel no cadastro de funcionarios" # "NAO CONFORMIDADE"
		EndIf
	EndIf
	RestArea(aAREAU)

Return lTIPOINS

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCUSTSTAN ³ Autor ³Elisangela Costa       ³ Data ³26/12/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o custo standard, retorna o custo, nome do tipo de   ³±±
±±³          ³insumo e nome do insumo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cCODIGO = Codigo do Insumo                                   ³±±
±±³          ³cTIPORE = Tipo do insumo                                     ³±±
±±³          ³nEXTRA  = Valor da hora extra do insumo                      ³±±
±±³          ³nPARMET = Parametro de aglutinacao da mao de obra            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCUSTSTAN(cCodigo, cTipore, nVHExtra, nParmet, cMoeda, cFilStan)
	Local nPAR := If(nPARMET = Nil, 2, nPARMET)
	Local nEXTRA := If(nVHEXTRA = nil, 1,nVHEXTRA)
	Local cTIPOREG := cTIPORE
	Local cCODPROD := cCODIGO
	Local cNOME    := Space(40)
	Local cNOMTIPO := Space(3)
	Local nCUSTO   := 0.00
	Local lMMoeda   := NGCADICBASE("TL_MOEDA","A","STL",.F.)

	Local cFilST1 := xFilial("ST1"), cFilST2 := xFilial("ST2"), cFilST0 := xFilial("ST0"), cFilSB1 := xFilial("SB1")
	Local cFilSA2 := xFilial("SA2"), cFilTPO := xFilial("TPO"), cFilSH4 := xFilial("SH4")

	Default cMoeda := ""
	Default cFilStan	:= xFilial("ST1")

	Private cMoedaAtu := "1"

	lChangeMd := lMMoeda .And. !Empty(cMoeda)

	If cTIPORE <> "P"
		If cTIPORE = "E"
			cCODPROD := SubStr(cCODIGO,1,3)
		ElseIf cTIPORE = "T"
			cCODPROD := SubStr(cCODIGO,1,Len(SA2->A2_COD))
		Else
			cCODPROD := SubStr(cCODIGO,1,6)
		Endif
	Endif

	If cTIPOREG == "M"
		cNOMTIPO := STR0163 //"FUN"
		DbSelectArea("ST1")
		DbSeek(cFilST1 +cCODPROD)
		cNOME := ST1->T1_NOME

		nCUSTO := If(lChangeMd, NGCONVMD(ST1->T1_SALARIO, 1, cMoeda), ST1->T1_SALARIO)
		nCUSTO := nCUSTO * nEXTRA

		If nPAR == 1 // Parametro de aglutinacao da mao de obra
			cNOMTIPO := STR0162 //"ESP"
			DbSelectArea("ST2")
			If DbSeek(cFilST2 + cCODPROD)
				cTIPOREG := "E"
				cCODPROD := ST2->T2_ESPECIA

				DbSelectArea("ST0")
				DbSeek(cFilST0 + cCODPROD)
				cNOME := ST0->T0_NOME

				nCUSTO := If(Empty(nCUSTO), ST0->T0_SALARIO, nCUSTO)
				nCUSTO := If(lChangeMd, NGCONVMD(nCUSTO, 1, cMoeda), nCusto)
				nCUSTO := nCUSTO * nEXTRA
			EndIf
		EndIf

	ElseIf cTIPOREG == "P"
		cNOMTIPO := STR0164 //"PRO"
		DbSelectArea("SB1")
		DbSeek(cFilSB1 + cCODPROD)
		cNOME  := SB1->B1_DESC

		nCUSTO := If(lChangeMd, NGCONVMD(SB1->B1_CUSTD, Val(SB1->B1_MCUSTD), cMoeda), SB1->B1_CUSTD)
		cMoedaAtu := If(!lChangeMd, SB1->B1_MCUSTD, cMoedaAtu)

	ElseIf cTIPOREG == "T"
		cNOMTIPO := STR0166 //"TER"
		DbSelectArea("SA2")
		DbSetOrder(01)
		DbSeek(cFilSA2 + cCODPROD)
		cNOME := SA2->A2_NOME

		DbSelectArea("TPO")
		DbSetOrder(01)
		If DbSeek(cFilTPO + cCODPROD)
			nCUSTO		:= If(lChangeMd, NGCONVMD(TPO->TPO_CUSTO, Val(TPO->TPO_MOEDA), cMoeda), TPO->TPO_CUSTO)
			cMoedaAtu := If(!lChangeMd, "1", cMoedaAtu)
		EndIf

	ElseIf cTIPOREG == "F"
		cNOMTIPO := STR0165 //"FER"
		DbSelectArea("SH4")
		DbSeek(cFilSH4 + cCODPROD)
		cNOME  := SH4->H4_DESCRI

		nCUSTO := If(lChangeMd, NGCONVMD(SH4->H4_CUSTOH, 1, cMoeda), SH4->H4_CUSTOH)
	Else
		cNOMTIPO := STR0162 //"ESP"
		DbSelectArea("ST0")
		DbSeek(cFilST0 + cCODPROD)
		cNOME  := ST0->T0_NOME

		nCUSTO := If(lChangeMd, NGCONVMD(ST0->T0_SALARIO, 1, cMoeda), ST0->T0_SALARIO)
		nCUSTO := nCUSTO * nEXTRA
	EndIf

	// Implementacao necessaria para Multi-Moeda
	If lMMoeda .And. Type("cMdCusto") == "C"
		cMdCusto := cMoedaAtu
	Endif

Return {nCUSTO,cNOMTIPO,cTIPOREG,cNOME,cCODPROD}

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGVRASTSB8 ³ Autor ³Elisangela Costa       ³ Data ³08/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a ratreabilidade do insumo do tipo produto no SB8     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cCODIN   = Codigo do insumo                                  ³±±
±±³          ³cLOCAL   = Local do insumo                                   ³±±
±±³          ³cLOTECTL = Numero do lote                                    ³±±
±±³          ³cNUMLOTE = Numero do sub-lote                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGVRASTSB8(cCODIN,cLOCAL,cLOTECTL,cNUMLOTE)
	Local aAREAU := GetArea()
	Local cVar:=ReadVar()
	Local nCODIGO  := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TL_CODIGO"})
	Local nLOCALTL := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TL_LOCAL"})
	Local nLOTECTL := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TL_LOTECTL"})
	Local nNUMLOTE := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TL_NUMLOTE"})
	Local nDTVALID := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TL_DTVALID"})

	Local cCODIGO  := If(nCODIGO  > 0,aCOLS[n][nCODIGO],cCODIN)
	Local cLOCALT  := If(nLOCALTL > 0,aCOLS[n][nLOCALTL],cLOCAL)
	Local cLOTCTL  := If(nLOTECTL > 0 .And. cVar <> "M->TL_LOTECTL",aCOLS[n][nLOTECTL],cLOTECTL)
	Local cNUMLOT  := If(nNUMLOTE > 0 .And. cVar <> "M->TL_NUMLOTE",aCOLS[n][nNUMLOTE],cNUMLOTE)

	If !Rastro(cCODIGO)
		Help(" ",1,"NAORASTRO")
		Return .F.
	EndIf

	If Empty( SuperGetMV( 'MV_MNTREQ', .F., '' ) )

		If cVar == "M->TL_LOTECTL"   //Campo que esta sendo digitado

			//Valida controle por sub-lote
			If Rastro(cCODIGO,"S")
				If !Empty(cNUMLOT)
					DbSelectArea("SB8")
					DbSetOrder(02)
					If DbSeek(xFilial("SB8")+cNUMLOT) .And. cCODIGO+cLOCALT == SB8->B8_PRODUTO+SB8->B8_LOCAL
						If cLOTCTL != SB8->B8_LOTECTL
							Help(" ",1,"A240LOTCTL")
							Return .F.
						Else
							If NGCONDTSB8(SB8->B8_DTVALID)
								If nDTVALID > 0
									aCOLS[n][nDTVALID] := SB8->B8_DTVALID
								Else
									M->TL_DTVALID := SB8->B8_DTVALID
								EndIf
							Else
								Return .f.
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				//Valida controle por lote
				If !Empty(cLOTCTL)
					DbSelectArea("SB8")
					DbSetOrder(03)
					If !(DbSeek(xFilial()+cCODIGO+cLOCALT+cLOTCTL))
						Help(" ",1,"NGATENCAO",,STR0043+Chr(13)+Chr(10)+; //"Numero do lote não corresponde ao produto que foi "
						STR0044,3,1) //" informado. Digite um lote correspondente."
						Return .F.
					Else
						If NGCONDTSB8(SB8->B8_DTVALID)
							If nDTVALID > 0
								aCOLS[n][nDTVALID] := SB8->B8_DTVALID
							Else
								M->TL_DTVALID := SB8->B8_DTVALID
							EndIf
						Else
							Return .f.
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf cVar == "M->TL_NUMLOTE"
			If Rastro(cCODIGO,"S")
				If !Empty(cNUMLOT)
					DbSelectArea("SB8")
					DbSetOrder(2)
					If DbSeek(xFilial("SB8")+cNUMLOT) .And. cCODIGO+cLOCALT == SB8->B8_PRODUTO+SB8->B8_LOCAL
						If NGCONDTSB8(SB8->B8_DTVALID)
							If nLOTECTL > 0 .And. nDTVALID > 0
								aCOLS[n][nLOTECTL] := SB8->B8_LOTECTL
								aCOLS[n][nDTVALID] := SB8->B8_DTVALID
							Else
								M->TL_LOTECTL := SB8->B8_LOTECTL
								M->TL_DTVALID := SB8->B8_DTVALID
							EndIf
						Else
							Return .f.
						EndIf
					Else
						Help(" ",1,"NGATENCAO",,STR0045+Chr(13)+Chr(10)+; //"Numero do sub-lote não corresponde ao produto que foi "
						STR0046,3,1) //" informado. Digite um sub-lote correspondente."
						Return .F.
					EndIf
				EndIf
			Else
				M->TL_NUMLOTE := CriaVar("TL_NUMLOTE")
			EndIf
		EndIf

	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCONFOSAUT ³ Autor ³ In cio Luiz Kolling   ³ Data ³15/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia da gerao automatica da ordem de servico automati-³±±
±±³          ³ca                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCONFOSAUT(cVPar)
	Local lRetAut := .t.
	If cVPar = "C"
		If ExistBlock("NGUT0301")
			lRetAut := ExecBlock("NGUT0301",.F.,.F.)
			If lRetAut
				lRetAut := MsgYesNo(STR0047+chr(13)+chr(13); //"Deseja que seja verificado a existência de o.s automática por contador?"
				+STR0017,STR0018)        //"Confirma (Sim/Não)" # "ATENÇÃO"
			EndIf
		Else
			lRetAut := MsgYesNo(STR0047+chr(13)+chr(13); //"Deseja que seja verificado a existência de o.s automática por contador?"
			+STR0017,STR0018)        //"Confirma (Sim/Não)" # "ATENÇÃO"
		EndIf
	EndIf
Return lRetAut

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGCOPIAOS ³ Autor ³Inacio Luiz Kolling    ³ Data ³05/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Copias de ordem de servico.                                 ³±±
±±³          ³Esta funcao pode ser chamada passando como parametro o nume-³±±
±±³          ³mero da ordem de servico e plano. Ou ainda, pode chamar sem ³±±
±±³          ³passar estes parametros quando estiver em cima da ordem que ³±±
±±³          ³deseja copiar.                                              ³±±
±±³          ³Se o programa que chamar esta funcao conter filtro no STJ   ³±±
±±³          ³deve ser feito o tratamento para guardar as referencias e   ³±±
±±³          ³no retorno refazer o fittro na tabela STJ.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cORDEM  - Numero da Ordem de Servico                        ³±±
±±³          ³cPLANO  - Numero do Plano da Ordem de Servico               ³±±
±±³          ³lTOSPRCORR - Trata uma O.s preventiva como corretiva        ³±±
±±³          ³             (MNTA430), .T. - Trata como corretiva ou       ³±±
±±³          ³             .F. nao faz tratamento como corretiva          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCOPIAOS(cORDEM,cPLANO,lTOSPRCORR)
	//----------------------------------------------
	// Guarda conteudo e declara variaveis padroes
	//----------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	Local oDlg
	Local oGet
	Local GetList := {},nXF := 0
	Local nRECSTJ := 0
	Local cSTATUSOS := ""
	Local aSitos := {STR0048,STR0049} // "Pendente"/"Liberada"
	Local aSize := MsAdvSize(), aObjects := {}

	Local lIntSFC := Val(cPlano) > 0 .And. FindFunction("NGINTSFC") .And. NGINTSFC() // Verifica se ha integracao com modulo Chao de Fabrica [SIGASFC]

	Private cCadastro := STR0050 //"Copia da ordem de servico"
	Private nCopias   := 1
	Private cSITUC := STR0048 // "Pendente"
	Private cTIPOSITUA := "P"

	// Variaveis de imulacao.. nao alterar os conteudos
	Private M->TF_PARADA := "N"
	Private aRotina := {{STR0051 ,"AxPesqui",0 ,1},; //"Pesquisar"
	{STR0052 ,"NGCAD01" ,0 ,2},; //"Visualizar"
	{STR0053 ,"NGCAD01" ,0 ,3}}  //"Incluir"

	Default lTOSPRCORR := .F.

	// Caso haja integracao com modulo de Chao de Fabrica (SIGASFC)
	// Valida existencia de parametro de motivo de parada (MV_SFCMTSP)
	If lIntSFC .And. ( !NGSFCPARAM() .Or. !NGSFCRESP() )
		Return .F.
	Endif

	Aadd(aObjects,{015,020,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.t.})
	aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	//------------------------------------------
	// Variável utilizada no When do TF_DTULTMA
	//------------------------------------------
	lWhenOs := .T.

	dbSelectArea("TQA")
	dbGobottom()
	dbSkip()

	dbSelectArea("SX3")
	dbSetOrder(2)
	nUsado  := 0
	aHeader := {}

	dbSeek("TF_TEPAANT")
	nUsado := nUsado+1
	Aadd(aHeader,{STR0054,"TF_TEPAANT",Posicione("SX3",2,"TF_TEPAANT","X3_PICTURE"),TamSX3("TF_TEPAANT")[1],;
				  Posicione("SX3",2,"TF_TEPAANT","X3_DECIMAL"),"NaoVazio()",Posicione("SX3",2,"TF_TEPAANT","X3_USADO"),Posicione("SX3",2,"TF_TEPAANT","X3_TIPO"),;
				  Posicione("SX3",2,"TF_TEPAANT","X3_ARQUIVO"),Posicione("SX3",2,"TF_TEPAANT","X3_CONTEXT"),Posicione("SX3",2,"TF_TEPAANT","X3_F3"),.f.}) //"Copia"

	dbSeek("TF_DTULTMA")
	nUsado:=nUsado+1
	Aadd(aHeader,{STR0055,"TF_DTULTMA",Posicione("SX3",2,"TF_DTULTMA","X3_PICTURE"),TamSX3("TF_DTULTMA")[1],;
						  Posicione("SX3",2,"TF_DTULTMA","X3_DECIMAL"),"MNTACOPD()",Posicione("SX3",2,"TF_DTULTMA","X3_USADO"),Posicione("SX3",2,"TF_DTULTMA","X3_TIPO"),;
						  Posicione("SX3",2,"TF_DTULTMA","X3_ARQUIVO"),Posicione("SX3",2,"TF_DTULTMA","X3_CONTEXT"),Posicione("SX3",2,"TF_DTULTMA","X3_F3")}) //"Dt. Prevista"

	aCols := Array(1,nUsado+1)

	nCoHe := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TF_TEPAANT"})
	nDaHe := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TF_DTULTMA"})

	If cORDEM <> Nil .And. cPLANO <> Nil

		dbSelectArea( "STJ" )
		Set Filter to
		dbSetOrder(1)
		If dbSeek(xFilial("STJ")+cORDEM+CPLANO)
			If STJ->TJ_SITUACA = "L" .And. STJ->TJ_TERMINO = "N"
				nRECSTJ := Recno()
				cTipOs  := STJ->TJ_TIPOOS
				cCodBe  := STJ->TJ_CODBEM
				cCodSe  := STJ->TJ_SERVICO
			Else
				MsgInfo(STR0056+Chr(13)+; //"A ordem de servico nao esta com a situacao liberada e nao terminada."
				STR0057,STR0005) //"Informe uma ordem de servico que contenha esta situacao." #"NAO CONFORMIDADE"
				//---------------------------------------
				// Retorna conteudo de variaveis padroes
				//---------------------------------------
				NGRETURNPRM(aNGBEGINPRM)
				Return .F.
			EndIf
		Else
			MsgInfo(STR0058+Chr(13)+; //"Ordem de servico nao encontrada. Informe uma ordem de servico valida"
			STR0059,STR0005) //"e que contenha a situacao de liberada e nao terminhada." # "NAO CONFORMIDADE"
			//---------------------------------------
			// Retorna conteudo de variaveis padroes
			//---------------------------------------
			NGRETURNPRM(aNGBEGINPRM)
			Return .f.
		EndIf
	Else
		If STJ->TJ_SITUACA = "L" .And. STJ->TJ_TERMINO = "N"
			nRECSTJ := Recno()
			cTipOs  := STJ->TJ_TIPOOS
			cCodBe  := STJ->TJ_CODBEM
			cCodSe  := STJ->TJ_SERVICO
		Else
			MsgInfo(STR0056+Chr(13)+; //"A ordem de servico nao esta com a situacao liberada e nao terminada."
			STR0057,STR0005) //"Informe uma ordem de servico que contenha esta situacao." #"NAO CONFORMIDADE"
			//---------------------------------------
			// Retorna conteudo de variaveis padroes
			//---------------------------------------
			NGRETURNPRM(aNGBEGINPRM)
			Return .F.
		EndIf
	EndIf

	aCOLS[1][nCoHe] := 1
	aCOLS[1][nDaHe] := STJ->TJ_DTMPINI
	aCOLS[1][3]     := .F.

	nOpca := 0
	nOpcx := 3

	SetInclui()

	Define Msdialog oDlg Title cCadastro From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd PIXEL

	oPanel := TPanel():New(00,00,,oDlg,,,,,,12,65,.F.,.F.)
	oPanel:Align := CONTROL_ALIGN_TOP

	@ 007,008 Say OemtoAnsi(STR0060) Of oPanel Pixel COLOR CLR_HBLUE //"Bem"
	@ 005,030 Msget STJ->TJ_CODBEM Picture '@!' When .f. Size 75,7 Of oPanel Pixel
	@ 005,110 Msget If(cTipOs = "B",NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_NOME"),;
	NGSEEK("TAF","X2"+Substr(STJ->TJ_CODBEM,1,3),7,"TAF_NOMNIV"))  Picture '@!' When .f. Size 180,7 Of oPanel Pixel

	@ 022,008 Say OemtoAnsi(STR0061) Of oPanel Pixel COLOR CLR_HBLUE //"Servico"
	@ 020,030 Msget STJ->TJ_SERVICO Picture '@!' When .f. Size 40,7 Of oPanel Pixel
	@ 020,075 Msget NGSEEK("ST4",STJ->TJ_SERVICO,1,"T4_NOME") Picture '@!' When .f. Size 150,7 Of oPanel Pixel

	@ 022,240 Say OemtoAnsi(STR0062) Of oPanel Pixel COLOR CLR_HBLUE  //"Seq."
	@ 020,260 Msget STJ->TJ_SEQRELA Picture '@!' When .f. Size 10,7 Of oPanel Pixel

	@ 037,008 Say OemtoAnsi(STR0063) Of oPanel Pixel COLOR CLR_HBLUE //"Ordem"
	@ 035,030 Msget STJ->TJ_ORDEM Picture '@!' When .f. Size 20,7 Of oPanel Pixel

	@ 037,060 Say OemtoAnsi(STR0064) Of oPanel Pixel COLOR CLR_HBLUE //"Plano"
	@ 035,080 Msget STJ->TJ_PLANO Picture '@!' When .f. Size 20,7 Of oPanel Pixel

	@ 037,115 Say OemtoAnsi(STR0065) Of oPanel Pixel COLOR CLR_HBLUE //"Data Prevista"
	@ 035,155 MsGet STJ->TJ_DTMPINI Picture '99/99/99' When .F. Size 45,7 Of oPanel HASBUTTON Pixel

	@ 052,008 Say OemtoAnsi(STR0066) Of oPanel Pixel COLOR CLR_HBLUE //"N. Copias"
	@ 050,040 MsGet nCopias Picture "999" Size 10,7 Of oPanel Pixel Valid MNTANCOP(oGet)
	@ 052,065 Say OemtoAnsi(STR0067) Of oPanel Pixel COLOR CLR_HBLUE //"Situacao"
	@ 050,096 Combobox cSITUC Items aSitos Size 37,7 Of oPanel Pixel

	oGet := MSGetDados():New(065,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],3,{|| .T.},{|| .T.},,.T.,,1,,nCopias)
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,IF(!MNTACOPPF(nRECSTJ),nOpca := 0,oDlg:End())},{||oDlg:End()})

	If nOpca == 1

		cTIPOSITUA := If(cSITUC = STR0048,"P","L") // "Pendente"
		For nXF := 1 To Len(aCOLS)
			If !atail(aCols[nXF])

				dbSelectArea("STJ")
				dbSetOrder(01)
				dbGoto(nRECSTJ)
				cOBSERVA := If(FieldPos('TJ_MMSYP') > 0,NGMEMOSYP(STJ->TJ_MMSYP),If(FieldPos('TJ_OBSERVA')>0,STJ->TJ_OBSERVA," "))

				//Verifica o Status da OS
				If STJ->TJ_SITUACA <> "P"
					dbSelectArea("ST4")
					dbSetOrder(01)
					If dbSeek(xFilial("ST4")+STJ->TJ_SERVICO)
						If FieldPos("T4_FOLLOWU") > 0
							If ST4->T4_FOLLOWU == "S"
								dbSelectArea("TQW")
								dbSetOrder(03)
								If dbSeek(xFILIAL("TQW")+"6 ")
									cSTATUSOS := TQW->TQW_STATUS
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					cSTATUSOS := STJ->TJ_STFOLUP
				EndIf

				dbSelectArea("STJ")
				NGGEROSESP(STJ->TJ_ORDEM,STJ->TJ_PLANO,STJ->TJ_CODBEM,STJ->TJ_SERVICO,STJ->TJ_SEQRELA,;
				aCols[nXF][2],STJ->TJ_DTMPINI,STJ->TJ_HOMPINI,STJ->TJ_DTMPFIM,STJ->TJ_HOMPFIM,STJ->TJ_DTPPINI,STJ->TJ_HOPPINI,;
				STJ->TJ_DTPPFIM,STJ->TJ_HOPPFIM,STJ->TJ_TIPO,STJ->TJ_CODAREA,STJ->TJ_CCUSTO,STJ->TJ_DTULTMA,STJ->TJ_COULTMA,;
				STJ->TJ_DTORIGI,STJ->TJ_USUARIO,STJ->TJ_CENTRAB,STJ->TJ_PRIORID,STJ->TJ_POSCONT,STJ->TJ_HORACO1,STJ->TJ_POSCON2,;
				STJ->TJ_HORACO2,STJ->TJ_ORDEPAI,cOBSERVA,STJ->TJ_SOLICI,STJ->TJ_BEMPAI,lTOSPRCORR,cTIPOSITUA,;
				STJ->TJ_TIPOOS,If(FieldPos("TJ_STFOLUP") > 0,cSTATUSOS,))
			EndIf
		Next nXf
	EndIf

	//---------------------------------------
	// Retorna conteudo de variaveis padroes
	//---------------------------------------
	NGRETURNPRM(aNGBEGINPRM)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNTACOPD  ³ Autor ³Inacio Luiz Kolling    ³ Data ³05/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia da data da ordem de servico                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTACOP                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTACOPD()
	If M->TF_DTULTMA <= STJ->TJ_DTMPINI
		MsgInfo(STR0068,STR0005) //"Data devera ser maior do que a data prevista da ordem" # "NAO CONFORMIDADE"
		Return .F.
	EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNTACOPPF ³ Autor ³Inacio Luiz Kolling    ³ Data ³05/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia na confirmacao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³nNUMREGSTJ - Numero do registro logico da Ordem de Servico  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTACOP                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNTACOPPF(nNUMREGSTJ)
	Local nX1 := 0, nX2 := 0
	Local dDtin  := Ctod('  /  /  ')
	For nX1 := 1 To Len(aCOLS)
		If !atail(aCols[nX1])
			dDtin := aCols[nX1,nDaHe]
			If dDTIN <= STJ->TJ_DTMPINI
				MsgInfo(STR0069+" "+Str(nX1,3)+" "+STR0070,STR0005) //"Data do item" # "e menor ou igual do que a data prevista da ordem" #"NAO CONFORMIDADE"
				Return .f.
			EndIf
			For nX2 := 1 To Len(aCOLS)
				If !atail(aCols[nX2])
					If nX2 = nX1
					Else
						If dDtin = aCols[nX2,nDaHe]
							MsgInfo(STR0071+"  "+Str(nX2,3)+" "+STR0072+" "+Str(nX1,3),STR0005)// "Datas iguais nos itens" # e # "NAO CONFORMIDADE"
							Return .f.
						EndIf
					EndIf
				EndIf
			Next nX2
		EndIf
	Next nX1

	cCodPl := If(Val(stj->tj_plano) = 0,'Val(STJ->TJ_PLANO) = 0',;
	'Val(STJ->TJ_PLANO) > 0')
	For nX1 := 1 To Len(aCOLS)
		If !atail(aCols[nX1])
			If cCodPl == 'Val(STJ->TJ_PLANO) = 0'
				If !NGMNTOSCO(cTipOs,cCodBe,cCodSe,aCols[nX1,nDaHe],cCodPl,nX1)
					Return .f.
				Endif
			Else
				If !NGPREVBSS(cTipOs,cCodBe,cCodSe,aCols[nX1,nDaHe],"0",.t.)
					Return .f.
				Endif
			EndIf
		EndIf
	Next nX1
	dbSelectArea("STJ")
	dbSetOrder(01)
	dbGoto(nNUMREGSTJ)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGGEROSESP³ Autor ³ Elisangela Costa      ³ Data ³ 14/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gerar O.S. baseada em uma ordem de servico que ja exista    ³±±
±±³          ³contendo sitacao de liberada e nao terminada                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cORDEMSER -> Numero da ordem de servico a ser copiada       ³±±
±±³          ³cPLANOOS  -> Numero do plano da ordem de servico            ³±±
±±³          ³cCODBOS   -> Codigo do bem                                  ³±±
±±³          ³cSERVOS   -> Codigo do serviço                              ³±±
±±³          ³cSEQMAN   -> Sequencia da manutencao                        ³±±
±±³          ³dDATAOS   -> Data inicio da ordem de servico                ³±±
±±³          ³dDMPINI   -> Data da manutencao prevista inicio             ³±±
±±³          ³cHMPINI   -> Hora da manutencao prevista inicio             ³±±
±±³          ³dDMPFIM   -> Data da manutencao prevista fim                ³±±
±±³          ³cHMPFIM   -> Hora da manutencao prevista fim                ³±±
±±³          ³dDPPINI   -> Data da parada prevista inicio                 ³±±
±±³          ³cHPPINI   -> Hora da padara prevista inicio                 ³±±
±±³          ³cDPPFIM   -> Data da parada prevista inicio                 ³±±
±±³          ³cHPPFIM   -> Hora da parada prevista fim                    ³±±
±±³          ³cTIPOSER  -> Tipo do servico                                ³±±
±±³          ³cCODAREA  -> Codigo da area de servico                      ³±±
±±³          ³cCENTROC  -> Centro de Custo                                ³±±
±±³          ³cCENTROC  -> Centro de Custo                                ³±±
±±³          ³dDATULTMA -> Data da ultima manutencao                      ³±±
±±³          ³nCONTULTMA-> Contador da ultima manutencao                  ³±±
±±³          ³dDATORIGI -> Data de Origem da manutencao                   ³±±
±±³          ³cUSUARIOOS-> Usuario                                        ³±±
±±³          ³cCENTRAB  -> Centro de trabalho                             ³±±
±±³          ³cPRIORID  -> Prioridade da manutencao                       ³±±
±±³          ³nPOSCONT1 -> Posicao do contador 1 da O.s                   ³±±
±±³          ³cHORCO1   -> Hora do contador 1 da O.s                      ³±±
±±³          ³nPOSCONT2 -> Posicao do contador 2 da O.s                   ³±±
±±³          ³cHORCO12  -> Hora do contador 2 da O.s                      ³±±
±±³          ³cORDPAI   -> Ordem de servico pai                           ³±±
±±³          ³cOBSERV   -> Observacao                                     ³±±
±±³          ³cSOLICI   -> Numero da Solicitacao                          ³±±
±±³          ³cBEMPAI   -> Codigo do bem pai da O.s                       ³±±
±±³          ³lTOSPRC   -> Indica se deve tratar uma O.s preventiva como  ³±±
±±³          ³             corretiva (.T. - Sim, .F. - Nao                ³±±
±±³          ³cSITAC    -> Indica a situacao que a O.s deve ser gravada   ³±±
±±³          ³             P= Pendente e L=Liberada                       ³±±
±±³          ³cTIPOOS   -> Tipo da O.s                                    ³±±
±±³          ³cSTATOS   -> Codigo do status da OS                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT - Planejamento de Manutencao                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGGEROSESP(cORDEMSER,cPLANOOS,cCODBOS,cSERVOS,cSEQMAN,dDATAOS,dDMPINI,;
	cHMPINI,dDMPFIM,cHMPFIM,dDPPINI,cHPPINI,cDPPFIM,cHPPFIM,cTIPOSER,cCODAREA,;
	cCENTROC,dDATULTMA,nCONTULTMA,dDATORIGI,cUSUARIOOS,cCENTRAB,cPRIORID,nPOSCONT1,;
	cHORCO1,nPOSCONT2,cHORCO2,cORDPAI,cOBSERV,cSOLICI,cBEMPAI,lTOSPRC,cSITAC,cTIPOOS,cSTATOS)
	Local i
	Local nDIASOS 	:= dDATAOS - dDMPINI
	Local aTAREFA 	:= {}, aETAPAS := {}
	Local cTRB	  	:= GetNextAlias()
	Local oTmpTbCOP
	Local cPRODMNT	:= GetMV("MV_PRODMNT")

	Private aBLO := { {},{},{},{},{}}
	Private dINI1,dFIM1,HINI1,hFIM1
	Private cUsaIntPc := AllTrim(GetMV("MV_NGMNTPC"))
	Private cUsaBloqC := AllTrim(GETMV("MV_NGCORPR"))
	Private cORDEM
	Private TI_BLOQFER, TI_BLOQFUN, TI_BLOQITE, TI_PLANO
	Private aVETINR := {}

	If cPLANOOS > "000000"
		m->TI_BLOQFUN := "S"
		m->TI_BLOQFER := "S"
		m->TI_BLOQITE := "S"
		m->TI_PLANO   := cPLANOOS
	Else
		m->TI_BLOQFUN := If(cUsaBloqC == "S","S","N")
		m->TI_BLOQFER := If(cUsaBloqC == "S","S","N")
		m->TI_BLOQITE := If(cUsaBloqC == "S","S","N")
		m->TI_PLANO   := cPLANOOS
	EndIf

	dbSelectArea("ST9")
	dbSeek(xFilial("ST9")+cCODBOS)

	If cPLANOOS > "000000" .And. !lTOSPRC

		dbselectarea("STF")
		dbsetorder(1)
		If dbSeek(xFILIAL("STF")+cCODBOS+cSERVOS+cSEQMAN)
			aCampos  := DbStruct()
			AAdd(aCAMPOS,{"DTULTPROC" ,"D",8,0})
			AAdd(aCAMPOS,{"POSCONT"   ,"N",9,0})
			AAdd(aCAMPOS,{"CONPROX"   ,"N",9,0})
			AAdd(aCAMPOS,{"DTPROX"    ,"D",8,0})
			AAdd(aCAMPOS,{"DTULTMA"   ,"D",8,0})
			AAdd(aCAMPOS,{"DTREAL"    ,"D",8,0})
			AAdd(aCAMPOS,{"TEMPO"     ,"N",4,0})
			AAdd(aCAMPOS,{"UNID"      ,"C",1,0})
			AAdd(aCAMPOS,{"PRIOBEM"   ,"C",1,0})
			AAdd(aCAMPOS,{"CALENDA"   ,"C",Len(sh7->h7_codigo) ,0})
			AAdd(aCAMPOS,{"CCUSTO"    ,"C",Len(stj->tj_ccusto) ,0})
			AAdd(aCAMPOS,{"CENTRAB"   ,"C",Len(st9->t9_centrab),0})
			AAdd(aCAMPOS,{"VARDIA"    ,"N",6,0})
			AAdd(aCAMPOS,{"FERRAMENTA","C",1,0})

			oTmpTbCOP := fCriaTRB(cTRB,aCampos,{{"TF_FILIAL","TF_PRIORID","PRIOBEM"}})

			Store dDATAOS To dReal,_DTPROX
			_CONPROX := 0

			(cTRB)->(DbAppend())
			For i := 1 To STF->(FCount())
				x := "STF->" +STF->(FieldName(i))
				y := "(cTRB)->" + STF->(FieldName(i))
				Replace &y. with &x.
			Next i

			(cTRB)->DTULTPROC  := dDATULTMA
			(cTRB)->POSCONT    := nPOSCONT1
			(cTRB)->PRIOBEM    := cPRIORID
			(cTRB)->CALENDA    := ST9->T9_CALENDA
			(cTRB)->DTULTMA    := dDATULTMA
			(cTRB)->DTPROX     := _DTPROX
			(cTRB)->CONPROX    := _CONPROX
			(cTRB)->DTREAL     := dREAL
			(cTRB)->CCUSTO     := cCENTROC
			(cTRB)->CENTRAB    := cCENTRAB
			(cTRB)->VARDIA     := ST9->T9_VARDIA
			(cTRB)->FERRAMENTA := ST9->T9_FERRAME
			(cTRB)->TF_DTULTMA := dREAL

			dbSelectArea(cTRB)
			dbGoTop()
			While !(cTRB)->(Eof())

				dbSelectArea(cTRB)
				aTAREFA := NGARRAYSTL(cORDEMSER,cPLANOOS,nDIASOS)
				aETAPAS := NGARRAYSTQ(cORDEMSER,cPLANOOS)

				dINI1 := dDMPINI + nDIASOS
				HINI1 := cHMPINI
				dFIM1 := dDMPFIM + nDIASOS
				hFIM1 := cHMPFIM
				dPRE1 := dDPPINI + nDIASOS
				hPRE1 := cHPPINI
				dPOS1 := cDPPFIM + nDIASOS
				hPOS1 := cHPPFIM

				dbSelectArea( "STJ" )
				cORDEM    := Space(6)
				cORDEM    := GetSXENum("STJ", "TJ_ORDEM")
				cORDGEROS := cORDEM
				ConfirmSX8()

				NGGERAOSTJ(cORDGEROS,cPLANOOS,(cTRB)->TF_CODBEM,(cTRB)->TF_SERVICO,;
				(cTRB)->TF_SEQRELA,(cTRB)->DTPROX,cTIPOSER,cCODAREA,(cTRB)->CCUSTO,;
				(cTRB)->CENTRAB,cPRIORID,(cTRB)->POSCONT,nPOSCONT2,dINI1,;
				HINI1,dFIM1,hFIM1,dPRE1,hPRE1,dPOS1,hPOS1,dDATULTMA,nCONTULTMA,;
				cUSUARIOOS,cHORCO1,cHORCO2,cORDPAI,cOBSERV,cSOLICI,cBEMPAI,lTOSPRC,;
				cSITAC,cTIPOOS,cSTATOS)

				dINIREAL  := If(Empty(dPRE1),dINI1,dPRE1)
				hINIREAL  := IF(Empty(hPRE1),hINI1,hPRE1)
				dFIMREAL  := If(Empty(dPOS1),dFIM1,dPOS1)
				hFIMREAL  := If(Empty(hPOS1),hFIM1,hPOS1)

				dORIGINAL := (cTRB)->DTPROX
				If (cTRB)->TF_PARADA == "S" .or. (cTRB)->TF_PARADA == "T"
					a330BEM(dINIREAL,hINIREAL,dFIMREAL,hFIMREAL,(cTRB)->TF_CODBEM,(cTRB)->TF_PARADA,(cTRB)->CCUSTO)
				EndIf
				If (cTRB)->FERRAMENTA == "F"
					cCodFer := NGSEEK("ST9",(cTRB)->TF_CODBEM,1,"T9_RECFERR")
					If !Empty(cCodFer)
						aFer := {}
						AAdd(aFER, {"0",cCodFer,1,dINIREAL,hINIREAL,dFIMREAL,hFIMREAL,cORDEM,cPLANOOS,(cTRB)->CCUSTO})
						a330FER(aFER[1],(cTRB)->TF_CODBEM)
					EndIf
				EndIf

				If cUsaIntPc == "S" .And. cSITAC = "L"
					cCODPRO := If(FindFunction("NGProdMNT"), NGProdMNT("M")[1], cPRODMNT) //Ira verificar apenas o primeiro Produto Manutencao do parametro
					cOP     := cORDEM + "OS001"
					GERAOP(cCODPRO,1,cOP,dINI1,dFIM1)
					//-- Grava os Campos Especificos na OP
					dbSelectArea('SC2')
					RecLock('SC2', .F.)
					SC2->C2_CC      := (cTRB)->CCUSTO
					SC2->C2_EMISSAO := MNT420DTOP(dDMPINI)
					SC2->C2_STATUS  := 'U'
					SC2->C2_OBS     := 'PLANO '+ cPLANOOS
					MsUnlock('SC2')
				EndIf

				aBLO := NGGSTLSTQ(cORDEM,cPLANOOS,aTAREFA,aETAPAS,(cTRB)->CCUSTO)

				(cTRB)->(DbSkip(1))
			End

			If cSITAC = "L"
				NGBLOQINS(aBLO,cPLANOOS,cCODBOS)
			EndIf

			//Deleta o arquivo temporario fisicamente
			oTmpTbCOP:Delete()
		EndIf
	Else
		aTAREFA := NGARRAYSTL(cORDEMSER,cPLANOOS,nDIASOS)
		aETAPAS := NGARRAYSTQ(cORDEMSER,cPLANOOS)

		dINI1 := dDMPINI + nDIASOS
		HINI1 := cHMPINI
		dFIM1 := dDMPFIM + nDIASOS
		hFIM1 := cHMPFIM

		dbSelectArea( "STJ" )
		cORDEM    := Space(6)
		cORDEM    := GetSXENum("STJ","TJ_ORDEM")
		cORDGEROS := cORDEM
		ConfirmSX8()

		If cUsaIntPc == "S" .And. cSITAC = "L"
			cCODPRO := If(FindFunction("NGProdMNT"), NGProdMNT("M")[1], GetMV("MV_PRODMNT")) //Ira verificar apenas o primeiro Produto Manutencao do parametro
			cOP     := cORDEM + "OS001"
			cCusto := NgFilTPN(cCODBOS,dINI1,SubStr(Time(),1,5))[2] //Buscar o C.C. do bem na TPN

			If !GERAOPNEW(cCODPRO,1,cORDEM,dINI1,dFIM1,,,cCusto,"PLANO " + cPLANOOS)
				Return .F.
			EndIf

		EndIf

		NGGERAOSTJ(cORDGEROS,cPLANOOS,cCODBOS,cSERVOS,cSEQMAN,dDATAOS,cTIPOSER,cCODAREA,cCENTROC,;
		cCENTRAB,cPRIORID,nPOSCONT1,nPOSCONT2,dINI1,HINI1,dFIM1,hFIM1,,,,,dDATULTMA,;
		nCONTULTMA,cUSUARIOOS,cHORCO1,cHORCO2,cORDPAI,cOBSERV,cSOLICI,cBEMPAI,lTOSPRC,;
		cSITAC,cTIPOOS,cSTATOS)



		aBLO := NGGSTLSTQ(cORDGEROS,cPLANOOS,aTAREFA,aETAPAS,ST9->T9_CCUSTO)

		If cSITAC = "L"
			NGBLOQINS(aBLO,cPLANOOS,cCODBOS)
		EndIf
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGGERAOSTJ³ Autor ³ Elisangela Costa      ³ Data ³18/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera a ordem de servico                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVORDEM -> Ordem de Servico                                 ³±±
±±³          ³cVPLANO -> Plano                                            ³±±
±±³          ³cVBEM   -> Codigo do bem                                    ³±±
±±³          ³cVSER   -> Codigo do Servico                                ³±±
±±³          ³nVSEQ   -> Sequencia da manutencao                          ³±±
±±³          ³dDTORI  -> Data Original da O.s                             ³±±
±±³          ³cVTIPO  -> Tipo do servico                                  ³±±
±±³          ³cVAREA  -> Codigo da area                                   ³±±
±±³          ³cVCCUST -> Codigo do centro de custo                        ³±±
±±³          ³cVCENTR -> Codigo do centro de trabalho                     ³±±
±±³          ³cVPRIOR -> Prioridade da O.s                                ³±±
±±³          ³nVCONT1 -> Posicao do contador 1                            ³±±
±±³          ³nVCONT2 -> Posicao do contador 2                            ³±±
±±³          ³dVDTPI  -> Data da manutencao prevista inicio               ³±±
±±³          ³cVHOPI  -> Hora da manutencao prevista inicio               ³±±
±±³          ³dVDTPF  -> Data da manutencao prevista fim                  ³±±
±±³          ³cVHOPF  -> Hora da manutencao prevista fim                  ³±±
±±³          ³dVDTPPI -> Data da parada prevista inicio                   ³±±
±±³          ³cVHOPPI -> Hora da parda prevista inicio                    ³±±
±±³          ³dVDTPPF -> Data da parada prevista fim                      ³±±
±±³          ³cVHOPPF -> Hora da parada prevista fim                      ³±±
±±³          ³dVDATUL -> Data da Ultima manutencao da O.s                 ³±±
±±³          ³nVCONTU -> Contador da Ultima manutencao da O.s             ³±±
±±³          ³cVUSUAR -> Usuario da O.s                                   ³±±
±±³          ³cVHORC1 -> Hora do contador 1                               ³±±
±±³          ³cVHORC2 -> Hora do contador 2                               ³±±
±±³          ³cVORDPAI-> Ordem de servico pai                             ³±±
±±³          ³cVOBSER -> Observacao da O.s                                ³±±
±±³          ³cVSOLIC -> Solicitacao da O.s                               ³±±
±±³          ³cVBEMP  -> Bem pai da O.s                                   ³±±
±±³          ³lTOSPRC -> Indica se deve tratar uma O.s preventiva como    ³±±
±±³          ³           corretiva (.T. - Sim, .F. - Nao                  ³±±
±±³          ³cSITAC  -> Situacao da O.s que deve ser gravada (P=Penden., ³±±
±±³          ³           L=Liberada                                       ³±±
±±³          ³cTIPOOS -> Tipo da O.s (B= Bem e L = Localizacao)           ³±±
±±³          ³cSTATOS -> Status da OS                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGGERAOSTJ(cVORDEM,cVPLANO,cVBEM,cVSER,nVSEQ,dDTORI,cVTIPO,cVAREA,;
	cVCCUST,cVCENTR,cVPRIOR,nVCONT1,nVCONT2,dVDTPI,cVHOPI,;
	dVDTPF,cVHOPF,dVDTPPI,cVHOPPI,dVDTPPF,cVHOPPF,dVDATUL,;
	nVCONTU,cVUSUAR,cVHORC1,cVHORC2,cVORDPAI,cVOBSER,cVSOLIC,;
	cVBEMP,lTOSPRC,cSITAC,cTIPOOS,cSTATOS)

	Local cIntSFC := IIf( FindFunction("NGINTSFC"), NGINTSFC(.F.), "" ) // Verifica se ha integracao com modulo Chao de Fabrica [SIGASFC]
	Local cRecSFC := ""

	If cVPLANO <> '000000'
		If !NGNOVAOS(cVBEM,cVSER,nVSEQ)
			Return
		Else
			dVDTPI := dDATABASE
			dFIM1  := dDATABASE
		Endif
	Endif

	//Tratamento para evitar duplicação de número de O.S. em base
	DbSelectArea("STJ")
	DbSetOrder(1)

	If DbSeek(xFilial("STJ") + cVORDEM)
		ConfirmSX8()
		cVORDEM := GETSXENUM("STJ","TJ_ORDEM")
	EndIf

	dbSelectArea("STJ")
	STJ->(RecLock("STJ",.T.))
	STJ->TJ_FILIAL  := xFilial('STJ')
	STJ->TJ_ORDEM   := cVORDEM
	STJ->TJ_PLANO   := cVPLANO
	STJ->TJ_TIPOOS  := cTIPOOS
	STJ->TJ_CODBEM  := cVBEM
	STJ->TJ_SERVICO := cVSER
	STJ->TJ_SEQRELA := nVSEQ
	STJ->TJ_DTORIGI := dDTORI
	STJ->TJ_TIPO    := cVTIPO
	STJ->TJ_CODAREA := cVAREA
	STJ->TJ_CCUSTO  := cVCCUST
	STJ->TJ_SITUACA := cSITAC
	STJ->TJ_TERMINO := "N"
	STJ->TJ_USUARIO := cVUSUAR
	STJ->TJ_CENTRAB := cVCENTR
	STJ->TJ_PRIORID := cVPRIOR
	STJ->TJ_POSCONT := nVCONT1
	STJ->TJ_HORACO1 := cVHORC1
	STJ->TJ_POSCON2 := nVCONT2
	STJ->TJ_HORACO2 := cVHORC2
	STJ->TJ_DTMPINI := dVDTPI
	STJ->TJ_HOMPINI := cVHOPI
	STJ->TJ_LUBRIFI := NGSEEK('ST4',cVSER,1,'T4_LUBRIFI')
	STJ->TJ_ORDEPAI := cVORDPAI
	If NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
		MsMM(,80,,cVOBSER,1,,,"STJ","TJ_MMSYP")
	Else
		STJ->TJ_OBSERVA := cVOBSER
	EndIf

	STJ->TJ_SOLICI  := cVSOLIC
	STJ->TJ_BEMPAI  := cVBEMP

	If Val(cVPLANO) > 0 .And. !lTOSPRC
		STJ->TJ_DTULTMA := dVDATUL
		If dFIM1 = cToD("01/01/80")
			dVDTPF := dVDTPI
			cVHOPF := cVHOPI
		EndIf
		STJ->TJ_DTMPFIM := dVDTPF
		STJ->TJ_HOMPFIM := cVHOPF
		STJ->TJ_DTPPINI := dVDTPPI
		STJ->TJ_HOPPINI := cVHOPPI
		STJ->TJ_DTPPFIM := dVDTPPF
		STJ->TJ_HOPPFIM := cVHOPPF
	Else
		STJ->TJ_DTMPFIM := dVDTPF
		STJ->TJ_HOMPFIM := cVHOPF
	Endif
	STJ->TJ_TERCEIR  := '1'
	If cSITAC == "P" .And. cSTATOS <> Nil
		STJ->TJ_STFOLUP := cSTATOS
	EndIf

	MsUnlock("STJ")

	// Se integrado ao modulo de Chao de Fabrica (SIGASFC), e haja necessidade de Parada do Bem/Estrutura
	If Val(cVPLANO) > 0 .And. !Empty(cIntSFC) .And. !Empty(STJ->TJ_DTPPINI) .And. !Empty(cRecSFC := NGVRFMAQ(STJ->TJ_CODBEM))
		NGSFCINCPP(cRecSFC,STJ->TJ_DTPPINI,STJ->TJ_HOPPINI,STJ->TJ_DTPPFIM,STJ->TJ_HOPPFIM,STJ->TJ_ORDEM,cIntSFC,(cTRB)->CALENDA, .F.) // Gera Parada Programada
	EndIf

	//gera nao-conformidade
	If Val(STJ->TJ_PLANO) == 0 .And. FindFunction("NGGERAFNC")
		NGGERAFNC(STJ->TJ_ORDEM,STJ->TJ_CODBEM,STJ->TJ_SERVICO,STJ->TJ_DTORIGI)
	EndIf

	If AllTrim(GetNewPar("MV_NGINTER","N")) == "M" .And. STJ->TJ_SITUACA == "L" //Mensagem Unica
		lOK := NGMUMntOrd(STJ->(RecNo()),3)
		If !lOK
			MsgAlert(STR0073+CRLF+;  //'Inconsistência no backoffice.'
			STR0074+CRLF+STR0075,STR0076)  //'A OS não foi integrada com o backoffice.'##"Para mais detalhes consulte o log do EAI."##"Integração BackOffice"
		EndIf
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGARRAYSTL³ Autor ³ Elisangela Costa      ³ Data ³18/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava a array com os insumos da Ordem de Servico            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cORDEMSTL --> Numero da Ordem de Servico                    ³±±
±±³          |cPLANOSTL --> Numero do plano da Ordem de Servico           ³±±
±±³          |nDIASOS   --> Numero de dias entre a O.s copiada            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   |aINSUMSTL --> Array com os insumos previstos da O.s         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGARRAYSTL(cORDEMSTL,cPLANOSTL,nDIASOS)
	Local aINSUMSTL := {}
	Local lSEQTAR   := NGCADICBASE("TL_SEQTARE","A","STL",.F.)

	dbSelectArea("STL")
	dbSetOrder(01)
	If dbSeek(xFilial("STL")+cORDEMSTL+cPLANOSTL)
		While !Eof() .And. STL->TL_ORDEM = cORDEMSTL .And. STL->TL_PLANO = cPLANOSTL

			If Alltrim(STL->TL_SEQRELA) = "0"
				dINI := STL->TL_DTINICI + nDIASOS
				dFIM := If(Empty(STL->TL_DTFIM),STL->TL_DTFIM,STL->TL_DTFIM + nDIASOS)
				AAdd(aINSUMSTL,{STL->TL_TAREFA   ,; //01
				STL->TL_TIPOREG  ,; //02
				STL->TL_CODIGO   ,; //03
				STL->TL_QUANREC  ,; //04
				STL->TL_QUANTID  ,; //05
				STL->TL_UNIDADE  ,; //06
				STL->TL_DESTINO  ,; //07
				dINI             ,; //08
				STL->TL_HOINICI  ,; //09
				dFIM             ,; //10
				STL->TL_HOFIM    ,; //11
				STL->TL_LOCAL    ,; //12
				STL->TL_TIPOHOR  ,; //13
				STL->TL_USACALE  ,; //14
				STL->TL_CUSTO    ,; //15
				If(lSEQTAR,STL->TL_SEQTARE,Nil) ,}) //16
			EndIf
			dbSelectArea("STL")
			dbSkip()
		End
	EndIf

Return aINSUMSTL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGARRAYSTQ³ Autor ³ Elisangela Costa      ³ Data ³18/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava a array com as etapas da Ordem de Servico             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cORDEMSTQ --> Numero da Ordem de Servico                    ³±±
±±³          |cPLANOSTQ --> Numero do plano da Ordem de Servico           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   |aINSUMSTQ --> Array com os etapas                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGARRAYSTQ(cORDEMSTQ,cPLANOSTQ)
	Local aINSUMSTQ := {}
	dbSelectArea("STQ")
	dbSetOrder(01)
	If dbSeek(xFilial("STQ")+cORDEMSTQ+cPLANOSTQ)
		While !Eof() .And. STQ->TQ_ORDEM = cORDEMSTQ .And. STQ->TQ_PLANO = cPLANOSTQ

			AAdd(aINSUMSTQ,{STQ->TQ_TAREFA ,; //01
			STQ->TQ_ETAPA  ,; //02
			STQ->TQ_SEQETA}) //03
			dbSelectArea("STQ")
			dbSkip()
		End
	EndIf
Return aINSUMSTQ

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGGSTLSTQ ³ Autor ³ Elisangela Costa      ³ Data ³18/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava as etapas e insumos previstos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cORDEM   -> Numero da Ordem de Servico                      ³±±
±±³          |cPLANOOS -> Numero do plano da Ordem de Servico             ³±±
±±³          |aTAREFA  -> Array contendo os insumos para gravar           ³±±
±±³          |aETAPAS  -> Array contendo as etapas para gravar            ³±±
±±³          |cCENTCUS -> Codigo do centro de custo                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   |aBLO     --> Array com os insumos para fazer bloqueio       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGGSTLSTQ(cORDEM,cPLANOOS,aTAREFA,aETAPAS,cCENTCUS)
	Local aBLO := { {},{},{},{},{}}, i
	Local cUsaBloqC := AllTrim(GETMV("MV_NGCORPR"))
	Local lSEQTAR   := NGCADICBASE("TL_SEQTARE","A","STL",.F.)

	If cPLANOOS > "000000"
		m->TI_BLOQFUN := "S"
		m->TI_BLOQFER := "S"
		m->TI_BLOQITE := "S"
		m->TI_PLANO   := cPLANOOS
	Else
		m->TI_BLOQFUN := If(cUsaBloqC == "S","S","N")
		m->TI_BLOQFER := If(cUsaBloqC == "S","S","N")
		m->TI_BLOQITE := If(cUsaBloqC == "S","S","N")
		m->TI_PLANO   := cPLANOOS
	EndIf

	For i := 1 to Len(aTAREFA)
		cReserva := "S"
		dbSelectArea( "STL" )
		STL->(RecLock("STL",.T.))
		STL->TL_FILIAL  := xFilial('STL')
		STL->TL_ORDEM   := cORDEM
		STL->TL_PLANO   := cPLANOOS
		STL->TL_TAREFA  := aTAREFA[i][1]
		STL->TL_DTINICI := aTAREFA[i][8]
		STL->TL_HOINICI := aTAREFA[i][9]
		STL->TL_DTFIM   := aTAREFA[i][10]
		STL->TL_HOFIM   := aTAREFA[i][11]
		STL->TL_TIPOREG := aTAREFA[i][2]
		STL->TL_CODIGO  := aTAREFA[i][3]
		STL->TL_QUANREC := aTAREFA[i][4]
		STL->TL_QUANTID := aTAREFA[i][5]
		STL->TL_UNIDADE := aTAREFA[i][6]
		STL->TL_DESTINO := aTAREFA[i][7]
		STL->TL_LOCAL   := aTAREFA[i][12]
		STL->TL_SEQRELA := "0  "
		STL->TL_TIPOHOR := aTAREFA[i][13]
		STL->TL_USACALE := If(Empty(aTAREFA[i][14]),"N",aTAREFA[i][14])
		STL->TL_CUSTO   := aTAREFA[i][15]
		If lSEQTAR
			STL->TL_SEQTARE := aTAREFA[i][16]
		EndIf
		MsUnlock("STL")

		nTIP := 0
		If aTAREFA[i][2] == "F"
			nTIP := If(m->TI_BLOQFER == "S",1,0)
		ElseIf aTAREFA[i][2] == "M"
			nTIP := If(m->TI_BLOQFUN == "S",2,0)
		ElseIf aTAREFA[i][2] == "E"
			nTIP := If(m->TI_BLOQFUN == "S",3,0)
		ElseIf aTAREFA[i][2] == "P"
			nTIP := If(m->TI_BLOQITE == "S",4,0)
		ElseIf aTAREFA[i][2] == "T"
			nTIP := If(m->TI_BLOQITE == "S",5,0)
		EndIf

		If nTIP > 0
			lGrvBLO := .t.
			If nTIP == 4
				//Aglutina produto igual
				nPosBlo := aScan(aBLO[nTIP],{|x| x[2]+x[11] = aTAREFA[i][3]+aTAREFA[i][12]})
				If nPosBlo > 0
					aBLO[nTIP][nPosBlo][3] += If(aTAREFA[i][2]$"E/F",aTAREFA[i][4],aTAREFA[i][5])
					lGrvBLO := .f.
				Else
					lGrvBLO := .t.
				EndIf
			EndIf
			If lGrvBLO
				AAdd(aBLO[nTIP], {aTAREFA[i][1]  ,;
				aTAREFA[i][3]   ,;
				If(aTAREFA[i][2]$"E/F",aTAREFA[i][4],aTAREFA[i][5]),;
				aTAREFA[i][8]   ,;
				aTAREFA[i][9]   ,;
				aTAREFA[i][10]  ,;
				aTAREFA[i][11]  ,;
				cORDEM           ,;
				cPLANOOS         ,;
				cCENTCUS         ,;
				aTAREFA[i][12]   ,;
				aTAREFA[i][6],;
				cReserva })
			EndIf
		EndIf
	Next

	//Grava as etapas da O.s
	For i := 1 to Len(aETAPAS)
		dbSelectArea("STQ")
		RecLock("STQ", .T.)
		STQ->TQ_FILIAL := xFILIAL("STQ")
		STQ->TQ_ORDEM  := cORDEM
		STQ->TQ_PLANO  := cPLANOOS
		STQ->TQ_TAREFA := aETAPAS[i][1]
		STQ->TQ_ETAPA  := aETAPAS[i][2]
		STQ->TQ_SEQETA := aETAPAS[i][3]
		MsUnlock("STQ")
	Next i

Return aBLO

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGBLOQINS ³ Autor ³ Elisangela Costa      ³ Data ³18/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os bloqueios dos insumos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aBLO     -> Array multidimensional contendo os insumos para ³±±
±±³          |          realizar o bloqueio                               ³±±
±±³          |cPLANOOS -> Numero do plano de ordem de servico             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGBLOQINS(aBLO,cPLANOOS,cCODBOS)
	Local i
	Local aItens   := {}
	Local lContSC2 := .F.

	Private cUsaIntPc := AllTrim(GetMV("MV_NGMNTPC"))
	Private cUsaIntCm := AllTrim(GetMV("MV_NGMNTCM"))
	Private cUsaIntEs := AllTrim(GetMV("MV_NGMNTES"))
	Private cUsaBloqC := AllTrim(GETMV("MV_NGCORPR"))
	//Verifica se Gera Solicit. ao Armazem em vez de Solic. Compras
	Private lGeraSA := .F.
	Private aRetSA :={}
	Private nPRO := 1

	// Usado na funcao NGGERASA.. Nao mexer
	Private cNumSA  := Space(Len(SCP->CP_NUM))

	If NGCADICBASE('TL_NUMSA','A','STL',.F.) .And. FindFunction("NGGERASA")
		If GetNewPar("MV_NGGERSA","N") == "S" .And. cUsaIntEs == "S"
			lGeraSA := .T.
		EndIf
	EndIf

	// INICIO
	// Variaveis usadas na geracao de solicitacao de compras
	// NAO MEXER....
	Private aDataOPC1 := {}, aDataOPC7 := {}, aOPC1 := {}, aOPC7 := {}
	Private vVetP     := {}, aNumSC1 := {},aIAglu := {}
	Private cNumSC1   := Space(Len(SC1->C1_NUM))
	Private cNuISC1   := 0
	// FIM

	If cPLANOOS == "000000" .And. cUsaBloqC = "N"
		Return .T.
	EndIf

	For i := 1 to Len(aBLO[1])
		a330FER(aBLO[1][i])
	Next

	For i := 1 to Len(aBLO[2])
		a330FUN(aBLO[2][i])
	Next

	For i := 1 to Len(aBLO[3])
		a330ESP(aBLO[3][i])
	Next

	nPRO := 1
	While nPRO <= Len(aBLO[4])
		cTAREFA   := aBLO[4][nPRO][1]
		nQTDCOMP  := aBLO[4][nPRO][3]
		cOPrin    := AllTrim(aBLO[4][nPRO][8]) + "OS001"
		cCodPro := Left(aBLO[4][nPRO][2], Len(SB1->B1_COD))
		cOP     := AllTrim(aBLO[4][nPRO][8]) + "OS001"
		cLOCSTL := aBLO[4][nPRO][11]

		// AGLUTINACAO POR PRODUTO E ALMAXARIFADO
		nPosSC := Ascan(aIAglu,{|x| x[1]+x[2] = cCodPro+cLOCSTL})
		If nPosSC > 0
			aIAglu[nPosSC][3] += nQTDCOMP
		Else
			aAdd(aIAglu,{cCodPro,cLOCSTL,nQTDCOMP,cOp,cTAREFA,aBLO[4,nPRO,10],;
			aBLO[4][nPRO][4],aBLO[4][nPRO][12],aBLO[4,nPRO,8],aBLO[4,nPRO,9]})
		EndIf
		nPRO++
	End

	// ESTA FUNCAO ESTA NO FONTE NGUTIL02 UTILIZA A MATRIZ aIAglu
	NGINTCOMPEST(STJ->TJ_DTMPINI,STJ->TJ_DTMPFIM,"NGUTIL03")
	// FIM DO NOVO PROCESSO DE GERACAO COMPRAS E EMPENHO

	For i := 1 to Len(aBLO[5])
		a340TER(aBLO[5][i],aBLO[5][i][11],aBLO[5][i][3],aBLO[5][i][12],.F.,i)
	Next

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NGXPROXMAN³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 19.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Identifica a forma como sera chamada a funcao NGPROXMAN    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGPROXMAN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGXPROXMAN(cBem)
	Local dDPROXM := CTOD("  /  /  ")
	Local nPCONTFIXO := GetMV("MV_NGCOFIX") //Percentual para calcular o contador fixo da manutencao
	Local nPERFIXO   := nPCONTFIXO / 100
	Local nULTCOMAN  := 0

	Default cBem := STF->TF_CODBEM

	dbSelectArea("ST9")
	ST9->(Dbseek(xFilial('ST9')+cBem))

	//----------------------------------------------
	// PE utilizado para retornar data da proxima
	// manutenção de forma específica
	//----------------------------------------------
	If ExistBlock("NGPROXMAN")
		Return ExecBlock("NGPROXMAN",.F.,.F.)
	Endif

	If STF->TF_TIPACOM <> "T" .And. STF->TF_TIPACOM <> "A"
		If STF->TF_TIPACOM = "S"
			DbSelectArea("TPE")
			DbSetOrder(01)
			If DbSeek(xFilial("TPE")+cBEM)
				dDPROXM := NGPROXMAN(TPE->TPE_DTULTA,"C",STF->TF_TEENMAN,;
				STF->TF_UNENMAN,STF->TF_CONMANU,STF->TF_INENMAN,;
				TPE->TPE_CONTAC,TPE->TPE_VARDIA)
			EndIf
		ElseIf STF->TF_TIPACOM = "F"

			If STF->( FieldPos("TF_CONPREV") ) > 0
				nULTCOMAN := STF->TF_CONPREV
			Else
				nULTCOMAN := STF->TF_CONMANU
			EndIf
			
			nINCPERC := STF->TF_INENMAN * nPERFIXO  // Incremento da manutencao com percentual
	
			nVEZMANU := Int(nULTCOMAN / STF->TF_INENMAN) // Numero de vezes que foi feito a manutencao
			nCONTFIX := IF(nVEZMANU==0, STF->TF_INENMAN, nVEZMANU * STF->TF_INENMAN) // Contador fixo exato
			nCONTPAS := nULTCOMAN - nCONTFIX             // Quantidade que passou da manutenção fixa

			If nCONTPAS < nINCPERC .Or. nINCPERC == 0
				nULTCOMAN := nCONTFIX
			Else
				nULTCOMAN := nCONTFIX + STF->TF_INENMAN
			EndIf

			dDPROXM := NGPROXMAN(ST9->T9_DTULTAC,STF->TF_TIPACOM,STF->TF_TEENMAN,;
			STF->TF_UNENMAN,nULTCOMAN,STF->TF_INENMAN,;
			ST9->T9_CONTACU,ST9->T9_VARDIA)
		Else
			dDPROXM := NGPROXMAN(ST9->T9_DTULTAC,STF->TF_TIPACOM,STF->TF_TEENMAN,;
			STF->TF_UNENMAN,STF->TF_CONMANU,STF->TF_INENMAN,;
			ST9->T9_CONTACU,ST9->T9_VARDIA,STF->TF_DTULTMA,cBem)
		EndIf
	Else
		If STF->TF_TIPACOM = "T"
			dDPROXM := NGPROXMANT(STF->TF_DTULTMA,STF->TF_TEENMAN,STF->TF_UNENMAN)
		Else
			dDATATEM := NGPROXMANT(STF->TF_DTULTMA,STF->TF_TEENMAN,STF->TF_UNENMAN,.t.)
			dDATACON := NGPROXMANC(ST9->T9_DTULTAC,STF->TF_CONMANU,STF->TF_INENMAN,;
			ST9->T9_CONTACU,ST9->T9_VARDIA,STF->TF_DTULTMA,cBem)
			If dDATATEM < dDATACON
				dDPROXM := NGPROXMANT(STF->TF_DTULTMA,STF->TF_TEENMAN,STF->TF_UNENMAN)
			Else
				dDPROXM := dDATACON
			EndIf
		EndIf
	EndIf
Return dDPROXM

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NGTRCSTJOS³ Autor ³In cio Luiz Kolling    ³ Data ³12/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Consistencia da ordem de servico com os parametros, conforme³±±
±±³          ³nova especificao do conceito de custo da ordem de servico   ³±±
±±³          ³(Somente STJ)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dParIn - Data inicio                          - Obrigatorio ³±±
±±³          ³dParFi - Data fim                             - Obrigatorio ³±±
±±³          ³nParCo - Condicao da ordem de servico         - Obrigatorio ³±±
±±³          ³nParDt - Condicao da data da ordem de servico - Obrigatorio ³±±
±±³          ³cVSitu - Situacao da ordem de servico         - Obrigatorio ³±±
±±³          ³cVTerm - Situacao do termino da ordem servico - Obrigatorio ³±±
±±³          ³dDtMri - Data real inicio da ordem de servico - Obrigatorio ³±±
±±³          ³dDtMpi - Data prevista inicio ordem servico   - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.t.,.f.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function NGTRCSTJOS(dParIn,dParFi,nParCo,nParDt,cVSitu,cVTerm,dDtMri,dDtMpi)
	Local lRetOk := .t.
	If nParCo = 1  //Finalizadas(L/S) e Liberadas(L/N)
		If cVSitu != "L"
			lRetOk := .f.
		EndIf
	ElseIf nParCo = 2 //Finalizadas(L/S) e Pendentes(P/N)
		If (cVSitu == "L" .And. cVTerm == "N") .Or. cVSitu == "C"
			lRetOk := .f.
		EndIf
	ElseIf nParCo = 3 //Finalizadas(L/S) e Ambas (Pendentes e Liberadas - L/N e P/N))
		If cVSitu == "C"
			lRetOk := .f.
		EndIf
	ElseIf nParCo = 4 //Finalizadas(L/S)
		If cVSitu <> "L" .Or. cVTerm <> "S"
			lRetOk := .f.
		EndIf
	EndIf
	If nParDt == 1
		If cVSitu == "L" .And. cVTerm == "S"
			If dDtMri < dParIn .Or. dDtMri > dParFi
				lRetOk := .f.
			EndIf
		Else
			If dDtMpi < dParIn .Or. dDtMpi > dParFi
				lRetOk := .f.
			EndIf
		EndIf
	EndIf
Return lRetOk

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NGTRCSTSOS³ Autor ³In cio Luiz Kolling    ³ Data ³13/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Consistencia da ordem de servico com os parametros, conforme³±±
±±³          ³nova especificao do conceito de custo da ordem de servico   ³±±
±±³          ³(Somente STS)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dParI  - Data inicio                          - Obrigatorio ³±±
±±³          ³dParF  - Data fim                             - Obrigatorio ³±±
±±³          ³nParC  - Condicao da ordem de servico         - Obrigatorio ³±±
±±³          ³cVSit  - Situacao da ordem de servico         - Obrigatorio ³±±
±±³          ³cVTer  - Situacao do termino da ordem servico - Obrigatorio ³±±
±±³          ³dParR  - Data real inicio da ordem de servico - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.t.,.f.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function NGTRCSTSOS(dParI,dParF,nParC,cVSit,cVTer,dParR)
	Local lRetSTS := .t.
	If cVSit = "L" .And. cVTer = "S"
		If nParC == 1
			lRetSTS := If((dParR >= dParI .And. dParR <= dParF),.t.,.f.)
		EndIf
	Endif
Return lRetSTS

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NGTRDTINSU³ Autor ³In cio Luiz Kolling    ³ Data ³13/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Consistencia da data do insumo com o parametro,conforme nova³±±
±±³          ³especificao do conceito de custo da ordem de servico        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nParCo - Condicao                             - Obrigatorio ³±±
±±³          ³dParDi - Data inicio                          - Obrigatorio ³±±
±±³          ³dParDf - Data fim                             - Obrigatorio ³±±
±±³          ³dDtIns - Data do insumo                       - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.t.,.f.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function NGTRDTINSU(nParCo,dParDi,dParDf,dDtIns)
	Local lRetF := .t.
	If nParCo = 2
		If dDtIns >= dParDi .And. dDtIns <= dParDf
		Else
			lRetF := .f.
		EndIf
	EndIf
Return lRetF

//--------------------------------------------------------------------------
/*/{Protheus.doc} NGPROCOSAB
Procura Os aberta para mesmo bem+servico+sequencia  
@type function

@author Elisagela Costa
@since 31/07/2007

@param 	cFilOS	, string, Código da Filial.
@param 	cTipoOS , string, Tipo de Ordem de Serviço.
@param 	cCodBem , string, Código do Bem.
@param 	cCodServ, string, Código do Serviço.
@param  cSequenc, string, Sequência da manutenção .

@return	array   , Indica se encontrou outra O.S. conforme os parâmetros.
					[1] - Indica se existe outra O.S.
					[2] - Número da O.S. localizada
/*/
//--------------------------------------------------------------------------
Function NGPROCOSAB( cFilOS, cTipoOS, cCodBem, cCodServ, cSequenc )
	
	Local aRet     := { .T., '' }
	Local cFilOSTJ := NGTROCAFILI( 'STJ', cFilOS )
	Local cAlsSTJ  := GetNextAlias()
	Local cLike    := "%'%" + cSequenc + "%'%"

	BeginSQL Alias cAlsSTJ

		SELECT 
			STJ.TJ_ORDEM 
		FROM
			%table:STJ% STJ
		WHERE
			STJ.TJ_FILIAL  = %exp:cFilOSTJ% AND
			STJ.TJ_TIPOOS  = %exp:cTipoOS%  AND
			STJ.TJ_CODBEM  = %exp:cCodBem%  AND 
			STJ.TJ_SERVICO = %exp:cCodServ% AND
			( STJ.TJ_SEQRELA = %exp:cSequenc% OR
			  STJ.TJ_SUBSTIT LIKE %exp:cLike% ) AND
			STJ.TJ_SITUACA = 'L'  AND
			STJ.TJ_TERMINO = 'N'  AND
			STJ.%NotDel%

	EndSQL

	If (cAlsSTJ)->( !EoF() )
		
		aRet := { .F., (cAlsSTJ)->TJ_ORDEM }
			
	EndIf

	(cAlsSTJ)->( dbCloseArea() )
	
Return aRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F4MNTLOCAL³ Autor ³ Elisangela Costa      ³ Data ³ 11/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a consulta de localizacoes por produto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F4MNTLOCAL()
	Local aArrayF4  :={}, aArrayF4NS:={}, nX, cVar
	Local cProduto  :="", nPosProd:=0, cLocal:="", nPosLocal:=0, nPosLocaliz:=0, nPosQuant:=0,nPosNumSer:=0,nPosSerie:=0
	Local nQuant    := 0
	Local nQuantLoc := 0
	Local nEndereco
	Local cChave2
	Local cLocaliza  := ""
	Local lGetDados  := .F.
	Local aUsado     := {}
	Local nPosNumLote
	Local nPosLoteCtl
	Local lLote      := .F.
	Local cQuant, nOAT
	Local lSaida     := .F.
	Local oDlg
	Local nOpcA      := 0
	Local aPosSBF , aArea:=GetArea()
	Local lShowNSeri := .F.
	Local cNumSeri   := CriaVar( "BF_NUMSERI", .F. )
	Local nNumSerie  := 0
	Local lSelLote   := (SuperGetMV("MV_SELLOTE") == "1")
	Local nLoop      := 0
	Local dDtValid   := CTOD('  /  /  ')
	Local aAreaSB8   := SB8->(GetArea())
	Local aDelArrF4  := {}
	Local nPos 		 := 0
	Local lMTF4LOC   := ExistBlock("MTF4LOC")
	Local aArrayAux  := Nil
	Local nLOTECTL, nNUMLOTE, nLOCALPR, nCODIGOP, nQUANTDP, nLOCALIZ, nNUMSERI

	nQtd := 0

	If cPrograma $ "MNTA400#MNTA401#NG400PADRA#MNTA415#MNTA360"

		lSaida   := .T.
		nLOTECTL := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TL_LOTECTL"})
		nNUMLOTE := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TL_NUMLOTE"})
		nLOCALPR := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TL_LOCAL"})
		nCODIGOP := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TL_CODIGO"})
		nQUANTDP := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TL_QUANTID"})
		nLOCALIZ := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TL_LOCALIZ"})
		nNUMSERI := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TL_NUMSERI"})
		nDATVALI := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TL_DTVALID"})

		If cPrograma $ "MNTA400#NG400PADRA#MNTA415#MNTA360"
			If nLOTECTL > 0 .And. nNUMLOTE > 0 .And. nLOCALPR > 0 .And. nCODIGOP > 0 .And. nQUANTDP > 0 .And.;
			nLOCALIZ > 0 .And. nNUMSERI > 0 .And. nDATVALI > 0
				cProduto := aCOLS[n][nCODIGOP]
				cLocal   := aCOLS[n][nLOCALPR]
				nQuant   := aCOLS[n][nQUANTDP]
				cNumLote := aCOLS[n][nNUMLOTE]
				cLoteCtl := aCOLS[n][nLOTECTL]
			Else
				cProduto := M->TL_CODIGO
				cLocal   := M->TL_LOCAL
				nQuant   := M->TL_QUANTID
				cNumLote := M->TL_NUMLOTE
				cLoteCtl := M->TL_LOTECTL
			EndIf
		Else
			If cPrograma == "MNTA401"
				cProduto := M->TL_CODIGO
				cLocal   := aCOLS[n][nLOCALPR]
				nQuant   := aCOLS[n][nQUANTDP]
				cNumLote := aCOLS[n][nNUMLOTE]
				cLoteCtl := aCOLS[n][nLOTECTL]
			Endif
		Endif
	ElseIf cPrograma == "MNTA232"
		cProduto := cProd600
		cLocal   := cLoc600
		nQuant   := 1
		cNumLote := ''
		cLoteCtl := ''
	ElseIf cPrograma == "MNTA600"
		cProduto := cCodProd
		cLocal   := cCodAlmo
		nQuant   := 1
		cNumLote := ''
		cLoteCtl := ''
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o F4 apenas se o produto tiver controle de Localizacao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Localiza( cProduto ) .And. If( cPrograma $ "MNTA400#MNTA401#NG400PADRA#MNTA415#MNTA360", lSaida, .T. )
		If Rastro( cProduto )
			If !Empty( If( Rastro( cProduto, "S" ), cNumLote, cLoteCtl ) )
				lLote := .T.
			EndIf
		EndIf
		aPosSBF := SBF->(GetArea())
		cChave2 := xFilial( "SBF" ) + cProduto + cLocal
		cCompara:= "BF_FILIAL+BF_PRODUTO+BF_LOCAL"
		If lLote
			If Rastro(cProduto,"S")
				cCompara+="+BF_LOTECTL+BF_NUMLOTE"
				cChave2 +=cLoteCtl + cNumLote
			Else
				cCompara+="+BF_LOTECTL"
				cChave2 +=cLoteCtl
			EndIf
		EndIf
		
		dbSelectArea("SBF")
		dbSetOrder(2)
		If dbSeek(cChave2)
			
			While !SBF->( Eof() ) .And. cChave2 == &(cCompara)
				nSaldoLoc  := SBF->BF_QUANT - (SBF->BF_EMPENHO+AvalQtdPre("SBF",1))
				nSaldoLoc2 := SBF->BF_QTSEGUM - (SBF->BF_EMPEN2+AvalQtdPre("SBF",1,.T.))
				nEmpenho   := SBF->BF_EMPENHO
				If QtdComp(nSaldoLoc) > QtdComp(0)
					nScan := AScan( aUsado, { |x| x[1] == SBF->BF_LOCALIZ .And. If(lLote,If(Rastro(cProduto,"S"),x[3]==SBF->BF_LOTECTL.And.x[4]==SBF->BF_NUMLOTE,x[3]==SBF->BF_LOTECTL),.T.) .And. x[5] == If(nPosNumSer>0,SBF->BF_NUMSERI,"")} )
					If nScan <> 0
						nSaldoLoc  -= aUsado[ nScan, 2 ]
						nSaldoLoc2 -= ConvUM(cProduto, aUsado[ nScan, 2 ], 0, 2)
					EndIf
				EndIf
				
				If nSaldoLoc > 0
					
					dDtValid   := CTOD('  /  /  ')
					
					If Rastro(cProduto)
						dbSelectArea("SB8")
						dbSetOrder(3)
						If dbSeek(xFilial("SB8")+cProduto+SBF->BF_LOCAL+SBF->BF_LOTECTL+If(Rastro(cProduto,"S"),SBF->BF_NUMLOTE,""))
							dDtValid:=B8_DTVALID
						EndIf

					EndIf

					dbSelectArea("SBF")
					
					AAdd(aArrayF4NS,{SBF->BF_LOCALIZ,SBF->BF_NUMSERI,TransForm(nSaldoLoc,PesqPict("SBF","BF_QUANT",13)),TransForm(nSaldoLoc2,PesqPict("SBF","BF_QUANT",13)),TransForm(nEmpenho,PesqPict("SBF","BF_EMPENHO",13)),SBF->BF_LOTECTL,SBF->BF_NUMLOTE,dDtValid})
					AAdd(aArrayF4,{SBF->BF_LOCALIZ,TransForm(nSaldoLoc,PesqPict("SBF","BF_QUANT",13)),TransForm(nSaldoLoc2,PesqPict("SBF","BF_QUANT",13)),TransForm(nEmpenho,PesqPict("SBF","BF_EMPENHO",13)),SBF->BF_LOTECTL,SBF->BF_NUMLOTE,dDtValid})
					
					If !Empty(SBF->BF_NUMSERI)
						lShowNSeri := .T.
					EndIf

				EndIf

				SBF->( dbSkip() )

			End

		EndIf

		If lShowNSeri
			aArrayF4:=ACLONE(aArrayF4NS)
		EndIf
		If ExistBlock("MTVLDLOC")
			aDelArrF4 := ExecBlock("MTVLDLOC",.F.,.F.,ACLONE(aArrayF4))
			If ValType(aDelArrF4) == "A" .And. Len(aDelArrF4) > 0
				For nX := 1 To Len(aDelArrF4)
					If lShowNSeri
						nPos := aScan(aArrayF4,{|x| x[1] == aDelArrF4[nX][1] .And. x[2] == aDelArrF4[nX][2] .And. x[5] == aDelArrF4[nX][5] .And. x[6] == aDelArrF4[nX][6] .And. x[7] == aDelArrF4[nX][7]})
					Else
						nPos := aScan(aArrayF4,{|x| x[1] == aDelArrF4[nX][1] .And. x[4] == aDelArrF4[nX][4] .And. x[5] == aDelArrF4[nX][5] .And. x[6] == aDelArrF4[nX][6]})
					Endif
					If nPos > 0
						Adel(aArrayF4,nPos)
						ASize(aArrayF4,Len(aArrayF4)-1)
					Endif
				Next
			Endif
		EndIf
		If Len( aArrayF4 ) > 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada utilizado para manipular a ordem do array aArrayF4 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lMTF4LOC
				aArrayAux := ExecBlock('MTF4LOC', .F., .F., {aArrayF4})
				If ValType(aArrayAux) == 'A'  .And. Len(aArrayF4) == Len(aArrayAux)
					aArrayF4 := aClone(aArrayAux)
				EndIf
			EndIf

			nOpcA := 0
			cCadastro := OemToAnsi(STR0077) //"Saldos por Localizacao"
			DEFINE MSDIALOG oDlg TITLE cCadastro From 09,0 To 33,75 OF oMainWnd
			@ 1.1,  .7  Say OemToAnsi(STR0078) //"Produto :"
			@ 1  , 3.8  MSGet cProduto SIZE 150,10 When .F.
			If lShowNSeri
				@ 2.4,.7 LISTBOX oQual VAR cVar Fields HEADER OemToAnsi(STR0079),OemToAnsi(STR0080),OemToAnsi(STR0081),OemToAnsi(STR0082),OemToAnsi(STR0252), RetTitle("BF_LOTECTL"),RetTitle("BF_NUMLOTE"),RetTitle("B8_DTVALID") SIZE 285,140 ON DBLCLICK (nOpca := 1,oDlg:End())  //"Localizacao"#"Numero de Serie"#"Saldo"#"Saldo 2aUM"#"Empenho"
			Else
				@ 2.4,.7 LISTBOX oQual VAR cVar Fields HEADER OemToAnsi(STR0079),OemToAnsi(STR0081),OemToAnsi(STR0082),OemToAnsi(STR0252),RetTitle("BF_LOTECTL"), RetTitle("BF_NUMLOTE"),RetTitle("B8_DTVALID") SIZE 285,140 ON DBLCLICK (nOpca := 1,oDlg:End())  //"Localizacao"#"Saldo"#"Saldo 2aUM"#"Empenho"
			EndIf
			oQual:SetArray(aArrayF4)
			If lShowNSeri
				oQual:bLine:={ ||{aArrayF4[oQual:nAT,1],aArrayF4[oQual:nAT,2],aArrayF4[oQual:nAT,3],aArrayF4[oQual:nAT,4],aArrayF4[oQual:nAT,5],aArrayF4[oQual:nAT,6],aArrayF4[oQual:nAT,7],aArrayF4[oQual:nAT,8]}}
			Else
				oQual:bLine:={ ||{aArrayF4[oQual:nAT,1],aArrayF4[oQual:nAT,2],aArrayF4[oQual:nAT,3],aArrayF4[oQual:nAT,4],aArrayF4[oQual:nAT,5],aArrayF4[oQual:nAT,6],aArrayF4[oQual:nAT,7]}}
			EndIf
			DEFINE SBUTTON FROM 06  ,264  TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM 18.5,264  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg VALID (nOAT := oQual:nAT,.T.) CENTERED

			If nOpca == 1
				If lShowNSeri
					cLocaliza := aArrayF4[ nOAT, 1 ]
					cNumSeri  := aArrayF4[ nOAT, 2 ]
					cLoteCtl  := aArrayF4[ nOAT, 6 ]
					cNUMLote  := aArrayF4[ nOAT, 7 ]
					dDtValid  := aArrayF4[ nOAT, 8 ]
					cEmp      := aArrayF4[ nOAT, 4 ]
					cEmp      := StrTran( cEmp, ".", ""  )
					cEmp      := StrTran( cEmp, ",", "." )
					cQuant    := aArrayF4[ nOAT, 5 ]
					cQuant    := StrTran( cQuant, ".", ""  )
					cQuant    := StrTran( cQuant, ",", "." )
					nQuantLoc := Val( cQuant )
				Else
					cLocaliza := aArrayF4[ nOAT, 1 ]
					cLoteCtl  := aArrayF4[ nOAT, 5 ]
					cNUMLote  := aArrayF4[ nOAT, 6 ]
					dDtValid  := aArrayF4[ nOAT, 7 ]
					cEmp      := aArrayF4[ nOAT, 4 ]
					cEmp      := StrTran( cEmp, ".", ""  )
					cEmp      := StrTran( cEmp, ",", "." )
					cQuant    := aArrayF4[ nOAT, 3 ]
					cQuant    := StrTran( cQuant, ".", ""  )
					cQuant    := StrTran( cQuant, ",", "." )
					nQuantLoc := Val( cQuant )
				EndIf
			EndIf
		Else
			Help( " ", 1, "F4LOCALIZ" )
		EndIf

		If !Empty(cLOCALIZA) .Or. !Empty(cNumSeri)
			If cPrograma == "MNTA400" .Or. cPrograma == "NG400PADRA" .Or. cPrograma == "MNTA415";
				.Or. cPrograma == "MNTA360"

				If nLOTECTL > 0 .And. nNUMLOTE > 0 .And. nLOCALPR > 0 .And. nCODIGOP > 0 .And. nQUANTDP > 0 .And.;
					nLOCALIZ > 0 .And. nNUMSERI > 0 .And. nDATVALI > 0
					aCOLS[n][nLOCALIZ] := cLocaliza
					aCOLS[n][nNUMSERI] := cNumSeri
					aCOLS[n][nLOTECTL] := cLoteCtl
					aCOLS[n][nNUMLOTE] := cNUMLote
					aCOLS[n][nDATVALI] := dDtValid
				Else
					M->TL_LOCALIZ := cLocaliza
					M->TL_NUMSERI := cNumSeri
					M->TL_LOTECTL := cLoteCtl
					M->TL_NUMLOTE := cNUMLote
					M->TL_DTVALID := dDtValid
				EndIf
			ElseIf cPrograma == "MNTA401"

				aCOLS[n][nLOCALIZ] := cLocaliza
				aCOLS[n][nNUMSERI] := cNumSeri
				aCOLS[n][nLOTECTL] := cLoteCtl
				aCOLS[n][nNUMLOTE] := cNUMLote
				aCOLS[n][nDATVALI] := dDtValid

			ElseIf cPrograma == "MNTA232

				cLocaLi600 := cLocaliza

			ElseIf cPrograma == "MNTA600"

				cLocaLi := cLocaliza

			EndIf
		EndIf
		RestArea(aPosSBF)
		RestArea(aAreaSB8)
	EndIf
	RestArea(aArea)
Return .T.

//---------------------------------------------------------------------------------------
/*/{Proteus.doc} NGAgluFim
Processa e atualiza as Manutencoes que foram aglutinadas.
@type function

@author Thiago Machado
@since 16/09/2008

NGAgluFim()

@param
@return Nil
/*/
//---------------------------------------------------------------------------------------
Function NGAgluFim()

	Local aArea     := GetArea()
	Local aKill     := {}
	Local aMKill    := {}
	Local nIndex    := 0
	Local x         := 0
	Local dUltManut := CtoD('')

	dbSelectArea("STJ")
	If AllTrim(STJ->TJ_SEQRELA) <> '0'
		dbSelectArea("STF")
		dbSetOrder(1)
		dbSeek( xFilial("STF", STJ->TJ_FILIAL) + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA )
		dUltManut := STF->TF_DTULTMA //Reserva data da ultima manuteção gravada na Manut. que irá substituir as demais
		aKill     := MNTSepSeq(STF->TF_SUBSTIT)
		If !Empty(aKill)
			nAcumSTF := STF->TF_CONMANU
			lFirst   := .t.

			x := 1
			While x <= Len(aKill)

				If dbSeek( xFilial("STF", STJ->TJ_FILIAL) + STJ->TJ_CODBEM + STJ->TJ_SERVICO + aKill[x] )
					aMKill := MNTSepSeq(STF->TF_SUBSTIT)
					If !Empty(aMKill)
						For nIndex := 1 to Len(aMKill)
							If aScan(aKill,{|z| z == aMKill[nIndex]}) = 0
								aAdd(aKill,aMKill[nIndex])
							EndIf
						Next
					EndIf
				EndIf
				x++
			End

			//Realiza atualização da ultima manut. e Acumulado para as manutençãoes substituidas.
			For nIndex := 1 To Len(aKill)

				cKill   := aKill[nIndex]

				If dbSeek( xFilial("STF", STJ->TJ_FILIAL) + STJ->TJ_CODBEM + STJ->TJ_SERVICO + cKill )
					If STF->TF_DTULTMA < dUltManut .Or. STF->TF_CONMANU < nAcumSTF
						RecLock("STF",.F.)
						STF->TF_DTULTMA := dUltManut
						STF->TF_CONMANU := nAcumSTF
						STF->TF_QUANTOS := STF->TF_QUANTOS + 1
						STF->(MsUnlock())
					EndIf
				EndIf

			Next nIndex
		EndIf
	EndIf

	RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGGERAFNC³ Autor ³ Evaldo Cevinscki Jr.  ³ Data ³ 03/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gerar registro de nao-conformidade no respectivo modulo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOS     -> Ordem de Servico                                ³±±
±±³          ³ cBEM    -> C¢digo do Bem da O.S.                           ³±±
±±³          ³ cSERV   -> C¢digo do servi‡o da O.S.                       ³±±
±±³          ³ dDTORIGI-> Data Original da O.S.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT -                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGGERAFNC(cOS,cBEM,cSERV,dDTORIG)
	Local aCamposQNC := {}
	Local aRetQNC    := {}
	Local cNaoConf   := NGSEEK('ST4',cSERV,1,'T4_NAOCONF')
	Local cIntQNC    := AllTrim(GetMv("MV_NGMNTQN"))

	If cNaoConf == "S" .And. cIntQNC == "S"
		DbSelectArea("QI2")
		aADD(aCamposQNC,{"QI2_TPFIC","2"})
		aADD(aCamposQNC,{"QI2_PRIORI","1"})
		aADD(aCamposQNC,{"QI2_STATUS","1"})
		aADD(aCamposQNC,{"QI2_DESCR",STR0012+": "+cOS+", "+STR0060+": "+AllTrim(cBEM)}) //OS.MANUT.###Bem
		aADD(aCamposQNC,{"QI2_MEMO1",STR0012+": "+cOS; //OS.MANUT.
		+", "+STR0060+": "+AllTrim(cBEM)+" - "+AllTrim(NGSEEK("ST9",cBEM,1,"T9_NOME")); //Bem
		+", "+STR0061+": "+cSERV+" - "+AllTrim(NGSEEK('ST4',cSERV,1,'T4_NOME'))+"."}) //Serviço
		aADD(aCamposQNC,{"QI2_OCORRE",dDTORIG})
		aADD(aCamposQNC,{"QI2_NUMOS",cOS})
		aRetQNC := QNCGERA(1,aCamposQNC)
		dbSelectArea("STJ")
		RecLock("STJ",.F.)
		STJ->TJ_FILQNC  := aRetQNC[1]
		STJ->TJ_FNC     := aRetQNC[2]
		STJ->TJ_REVQFNC := aRetQNC[3]
		MsUnlock("STJ")
	EndIf

Return .t.

//--------------------------------------------------------------------------
/*/{Protheus.doc} NGVERSUBST
Verifica se existe O.S para cancelamento por Substituição.
@type function

@author Vitor Emanuel Batista
@since 29/04/2009

@param 	cCodBem	  , string, Código do bem.
@param 	cOrdemPai , string, Ordem de Serviço.
@param 	cPlanoPai , string, Plano de Manutenção.
@param  [cSequenc], string, Sequência da Ordem de Serviço.

@return	
/*/
//--------------------------------------------------------------------------
Function NGVERSUBST( cCodBem, cOrdemPai, cPlanoPai, cSequenc )
	
	Local aArea       := GetArea()
	Local aKill       := {}
	Local aSTLFields  := {}
	Local aSTL        := {}
	Local cQuery      := ''
	Local cAlsSTJ     := ''
	Local cAliasQry2  := ''
	Local cNumCP      := ''
	Local cTJOBSERVA  := ''
	Local cNGMNTAS	  := SuperGetMV( 'MV_NGMNTAS', .F., '2' )
	Local cNGINTER	  := SuperGetMV( 'MV_NGINTER', .F., 'N' )
	Local lMataEsp    := NGCADICBASE( 'TF_MARGEM', 'A', 'STF', .F. )
	Local lNGTARGE    := AliasIndic( 'TT9' ) .And. GetNewPar( 'MV_NGTARGE', '2' ) == '1'
	Local i           := 0
	Local nX          := 0
	Local nZZ         := 0

	// Variáveis de gravação do campo TJ_SUBSTIT
	Local aOSKill     := {}
	Local cSeqOSs     := '' //Variavel para guardas as sequencias como exemplo '1,2,3'
	Local lTJ_SUBSTIT := TamSX3("TJ_SUBSTIT")[1] == 100

	Private aBLO      := { {}, {}, {}, {}, {} }
	Private cUsaIntEs := AllTrim(GetMV("MV_NGMNTES"))
	Private cUsaIntCm := AllTrim(GetMV("MV_NGMNTCM"))

	Default cSequenc  := STJ->TJ_SEQRELA

	If FWTamSX3( 'TF_SUBSTIT' )[1] == 11

		cAlsSTJ := GetNextAlias()

		BeginSQL Alias cAlsSTJ

			SELECT 
				STJ.TJ_ORDEM  ,
				STJ.TJ_PLANO  ,
				STJ.TJ_CODBEM , 
				STJ.TJ_SERVICO,
				STJ.TJ_DTMPINI,
				STJ.TJ_SEQRELA,
				STF.TF_SUBSTIT
			FROM 
				%table:STJ% STJ
			INNER JOIN
				%table:STF% STF ON
					STF.TF_CODBEM  = STJ.TJ_CODBEM  AND
					STF.TF_SERVICO = STJ.TJ_SERVICO AND
					STF.TF_SEQRELA = STJ.TJ_SEQRELA AND
					STF.TF_SUBSTIT <> '' AND
					STF.%NotDel%
			WHERE
				STJ.TJ_FILIAL  = %xFilial:STJ%  AND
				STJ.TJ_CODBEM  = %exp:cCodBem%  AND
				STJ.TJ_PLANO   = '000001'       AND
				STJ.TJ_SEQRELA = %exp:cSequenc% AND
				STJ.TJ_SITUACA = 'L'  AND
				STJ.TJ_TERMINO = 'N'  AND
				STJ.TJ_TIPORET <> 'S' AND
				STJ.%NotDel%
			ORDER BY 
				STJ.TJ_ORDEM DESC

		EndSQL

		While (cAlsSTJ)->( !Eof() )

			aKill  := MNTSepSeq( (cAlsSTJ)->TF_SUBSTIT )
			lFirst := .t.

			For i := 1 To Len(aKill)

				cKill   := aKill[i]
				If lFirst
					dDtMata := STOD((cAlsSTJ)->TJ_DTMPINI)
					lFirst := .f.
				EndIf

				cCodBem  := (cAlsSTJ)->TJ_CODBEM
				cPlano   := (cAlsSTJ)->TJ_PLANO
				cOsKill  := (cAlsSTJ)->TJ_ORDEM
				cSqKill  := (cAlsSTJ)->TJ_SEQRELA
				cServico := (cAlsSTJ)->TJ_SERVICO

				cAliasQry2 := GetNextAlias()

				cQuery := " SELECT TJ_ORDEM,TJ_PLANO,TJ_CODBEM,TJ_SERVICO,TJ_DTMPINI,TJ_SEQRELA FROM "+RetSQLName("STJ")
				cQuery += " WHERE TJ_CODBEM = '"+cCodBem+"' AND TJ_PLANO = '"+cPlano+"' AND TJ_SEQRELA = '"+cKill+"' AND TJ_SERVICO = '"+cServico+"'
				cQuery += "   AND TJ_TERMINO = 'N' AND TJ_TIPORET <> 'S' AND TJ_SITUACA = 'L' AND TJ_FILIAL = "+ValToSql(xFilial("STJ"))

				If lMataEsp
					cQuery += " AND TJ_DTMPINI = '"+DtoS(dDtMata)+"'
				Else
					cQuery += " AND TJ_DTMPINI <= '"+DtoS(dDtMata)+"'
				EndIf

				cQuery += " AND D_E_L_E_T_<>'*' "
				cQuery += " ORDER BY TJ_DTMPINI"

				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry2, .F., .T.)

				lDtMorta := .f.

				DbSelectArea(cAliasQry2)
				DbGotop()
				While !Eof()
					cOrdem   := (cAliasQry2)->TJ_ORDEM
					cPlano   := (cAliasQry2)->TJ_PLANO
					cSeqRela := (cAliasQry2)->TJ_SEQRELA
					lDtMorta := .T.
					DbSkip()
				End
				(cAliasQry2)->(dbCloseArea())

				If lDtMorta

					If lNGTARGE
						aSTLFields := STL->(dbStruct())
						aSTL := {}
						NGIFDICIONA("STL",xFilial("STL")+cOrdem+cPlano,1)
						While !Eof() .And. xFilial("STL")+cOrdem+cPlano == STL->TL_FILIAL+STL->TL_ORDEM+STL->TL_PLANO
							If STL->TL_SEQRELA == '0  ' .And. If(STL->TL_TIPOREG='P',NGGERCOTAC(STL->TL_ORDEM,.f.,STL->TL_CODIGO),.t.)
								aAdd(aSTL,Array(Len(aSTLFields)))
								For nX := 1 To Len(aSTLFields)
									aTail(aSTL)[nX] := STL->(&(aSTLFields[nX][1]))
								Next nX
							EndIf
							dbSelectArea("STL")
							dbSkip()
						EndDo

						aSTQFields := STQ->(dbStruct())
						aSTQ := {}
						NGIFDICIONA("STQ",xFilial("STQ")+cOrdem+cPlano,1)
						While !Eof() .And. xFilial("STQ")+cOrdem+cPlano == STQ->TQ_FILIAL+STQ->TQ_ORDEM+STQ->TQ_PLANO
							If Empty(STQ->TQ_CODFUNC)
								aAdd(aSTQ,Array(Len(aSTQFields)))
								For nX := 1 To Len(aSTQFields)
									aTail(aSTQ)[nX] := STQ->(&(aSTQFields[nX][1]))
								Next nX
							EndIf
							dbSelectArea("STQ")
							dbSkip()
						EndDo
					EndIf

					If NGIFDICIONA("STJ",xFilial("STJ")+cOrdem+cPlano+"B"+cCodBem+cServico+cSeqRela,1)
						If NGGERCOTAC(cOrdem,.f.)
							If NGDELETOS(STJ->TJ_ORDEM,STJ->TJ_PLANO)
								nNUMOSGE -= 1
								//Adiciona a sequencia da O.S. que foi deletada
								aOsCancel := MNTSepSeq(STJ->TJ_SUBSTIT)
								If Len(aOsCancel) > 0
									For nX := 1 to len(aOsCancel)
										aAdd(aOSKill,aOsCancel[nX])
									Next
								EndIf
								aAdd(aOSKill,cSeqRela)
								//Exclui o lancamento de contador relacionado ao bem do Contador 1
								If !EMPTY(STJ->TJ_HORACO1) .And. STJ->TJ_POSCONT > 0
									MNT470EXCO(STJ->TJ_CODBEM,STJ->TJ_DTORIGI,STJ->TJ_HORACO1,1)
								EndIf

								//Exclui o lancamento de contador relacionado ao bem do Contador 2
								If !EMPTY(STJ->TJ_HORACO2) .And. STJ->TJ_POSCON2 > 0
									MNT470EXCO(STJ->TJ_CODBEM,STJ->TJ_DTORIGI,STJ->TJ_HORACO2,2)
								EndIf

								RecLock("STJ",.f.)
								cTJOBSERVA := CRLF + STR0083 +DtoC(dDtMata)+ STR0084 +cOsKill+ STR0085 +AllTrim(cSqKill)+"." //"Essa O.S. prevista para a data " ## ", foi substituida pela O.S. " ## " de sequência "
								If NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
									MsMM(,80,,NGMEMOSYP(STJ->TJ_MMSYP) + cTJOBSERVA,1,,,"STJ","TJ_MMSYP")
								Else
									STJ->TJ_OBSERVA += cTJOBSERVA
								EndIf
								MsUnLock("STJ")
								dDtMorta        := STJ->TJ_DTMPINI

								NGIFDICIONA("STJ",xFilial("STJ")+cOsKill+cPlano+"B"+cCodBem+cServico+cSqKill,1)
								RecLock("STJ",.f.)
								STJ->TJ_DTMPINI := dDtMorta
								MsUnLock("STJ")
							EndIf

						Else
							NGIFDICIONA("STL",xFilial("STL")+cOrdem+cPlano,1)
							While !Eof() .And. xFilial("STL")+cOrdem+cPlano == STL->TL_FILIAL+STL->TL_ORDEM+STL->TL_PLANO
								If STL->TL_SEQRELA == '0  ' .And. If(STL->TL_TIPOREG='P',NGGERCOTAC(STL->TL_ORDEM,.f.,STL->TL_CODIGO),.t.)
									//Deleta os relacionamentos do insumo
									NGDELINTEG(STL->TL_ORDEM,STL->TL_PLANO,STL->TL_TAREFA,STL->TL_TIPOREG,STL->TL_CODIGO,STL->TL_SEQRELA)

									NGIFDBSEEK("SCP",STL->TL_CODIGO+STL->TL_NUMSA+STL->TL_ITEMSA,2)
									cNumCP := SCP->CP_NUM
								EndIf
								dbSelectArea("STL")
								dbSkip()
							EndDo

							If cNGMNTAS == "1"
								If !Empty(cNumCP) .And. NGIFDBSEEK( "SCP",cNumCP,01,.F. )
									If SCP->CP_PREREQU <> "S"
										If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"
											NGMUReques( SCP->( RecNo() ),"SCP",.F.,5 )
										EndIf

										While SCP->( DbSeek( xFilial( "SCP" ) + cNumCP ) )

											// Realiza exclusão da S.A. e seus relacionamentos ( SCR ).
											MntDelReq( SCP->CP_NUM, SCP->CP_ITEM, 'SA' )

										End While

									EndIf
								EndIf
							EndIf

							NGIFDICIONA("STJ",xFilial("STJ")+cOsKill+cPlano+"B"+cCodBem+cServico+cSqKill,1)
							RecLock("STJ",.f.)
							cTJOBSERVA := CRLF + STR0086 + cOrdem + STR0087 + AllTrim(cSeqRela)+ STR0088 //"A O.S. " ## " de sequência " ## " que está em execução possui vinculo com a O.S atual, assim não podendo ser cancelada."
							If NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
								MsMM(,80,,NGMEMOSYP(STJ->TJ_MMSYP) + cTJOBSERVA,1,,,"STJ","TJ_MMSYP")
							Else
								STJ->TJ_OBSERVA += cTJOBSERVA
							EndIf
							MsUnLock("STJ")
						EndIf
					EndIf

					If lNGTARGE
						nTAREFA   := aSCAN(aSTLFields,{|x| AllTrim(x[1]) == "TL_TAREFA"})
						nTIPOREG  := aSCAN(aSTLFields,{|x| AllTrim(x[1]) == "TL_TIPOREG"})
						nCODIGO   := aSCAN(aSTLFields,{|x| AllTrim(x[1]) == "TL_CODIGO"})
						nSEQRELA  := aSCAN(aSTLFields,{|x| AllTrim(x[1]) == "TL_SEQRELA"})
						nSEQTARE  := aSCAN(aSTLFields,{|x| AllTrim(x[1]) == "TL_SEQTARE"})

						For nX := 1 To Len( aSTL )

							dbSelectArea( 'STL' )
							dbSetOrder( 1 ) // TL_FILIAL + TL_ORDEM + TL_PLANO + TL_TAREFA + TL_TIPOREG + TL_CODIGO + TL_SEQRELA + TL_SEQTARE
							If !msSeek( FWxFilial( 'STL' ) + cOsKill + cPlano + aSTL[nX,nTAREFA] + aSTL[nX,nTIPOREG] +;
								aSTL[nX,nCODIGO] + aSTL[nX,nSEQRELA] )
								
								RecLock("STL",.T.)
								For nZZ := 1 To Len(aSTLFields)
									STL->(&(aSTLFields[nZZ][1])) := aSTL[nX][nZZ]
								Next nZZ
								STL->TL_ORDEM := cOsKill
								STL->TL_PLANO := cPlano
								STL->TL_NUMSA := ''
								STL->TL_ITEMSA := ''
								MsUnLock()

								nTIP := 0
								If STL->TL_TIPOREG == "F"
									nTIP := 1
								Elseif STL->TL_TIPOREG == "M"
									nTIP := 2
								Elseif STL->TL_TIPOREG == "E"
									nTIP := 3
								Elseif STL->TL_TIPOREG == "P"
									nTIP := 4
								Elseif STL->TL_TIPOREG == "T"
									nTIP := 5
								Endif

								If nTIP > 0
									Aadd(aBLO[nTIP],{	STL->TL_TAREFA ,;
									STL->TL_CODIGO ,;
									If(STL->TL_TIPOREG$"E/F",STL->TL_QUANREC,STL->TL_QUANTID),;
									STL->TL_DTINICI           ,;
									STL->TL_HOINICI           ,;
									STL->TL_DTFIM             ,;
									STL->TL_HOFIM             ,;
									STL->TL_ORDEM             ,;
									STL->TL_PLANO             ,;
									STJ->TJ_CCUSTO            ,;
									Space(Len(SC1->C1_NUM))       ,;   //11 NUMERO DA SOLICITACAO DE COMPRA
									Space(Len(SC1->C1_ITEM))      ,;   //12 NUMERO DO ITEM DA SOLICITACAO DE COMPRA
									0.00                          ,;   //13 QUANTIDADE DO ESTOQUE DA OPERACAO   TL_QTDOPER
									Space(Len(SB2->B2_LOCAL))     ,;   //14 CODIGO DO ALMOXARIFADO OPERACAO     TL_ALMOPERA
									0.00                          ,;   //15 QUANTIDADE DO ESTOQUE DA MATRIZ     TL_QTDOMAT
									Space(Len(SB2->B2_LOCAL))     ,;   //16 CODIGO DO ALMOXARIFADO DA MATRIZ    TL_ALMOMAT
									0.00                          ,;   //17 QUANTIDADE DA SOLICITACAO DE COMPRA TL_QTDSC1
									STL->TL_LOCAL                 ,;   //18 CODIGO DO LOCAL GRAVADO NO STL
									STL->TL_UNIDADE				  ,;   //19 UNIDADE DO INSUMO
									STL->TL_OBSERVA               ,;   //20 OBSERVACAO DO INSUMO
									0.00                          ,;   //21 QUANTIDADE DA SOLICITACAO DE COMPRA TL_QTDSC1
									STL->TL_FORNEC                ,;   //22 Fornecedor TL_FORNEC
									STL->TL_LOJA                  })   //23 Loja do fornecedor TL_LOJA
								EndIf
							EndIf

						Next nX

						//--------------------------------------------------------
						// Se houver mais insumos a serem adicionados, deverá ser
						// reprocessado os insumos da O.S que está matando
						//--------------------------------------------------------
						If Len(aBLO[1]) >0 .Or. Len(aBLO[2]) > 0 .Or. Len(aBLO[3]) > 0 .Or. Len(aBLO[4]) > 0  .Or. Len(aBLO[4]) > 0

							aSTL := {}
							aBLO := {{},{},{},{},{}}
							NGIFDICIONA("STL",xFilial("STL")+cOsKill+cPlano,1)
							While !Eof() .And. xFilial("STL")+cOsKill+cPlano == STL->TL_FILIAL+STL->TL_ORDEM+STL->TL_PLANO
								If STL->TL_SEQRELA == '0  '
									aAdd(aSTL,Array(Len(aSTLFields)))
									For nZZ := 1 To Len(aSTLFields)
										aTail(aSTL)[nZZ] := STL->(&(aSTLFields[nZZ][1]))
									Next nZZ

									//Deleta os relacionamentos do insumo
									NGDELINTEG(STL->TL_ORDEM,STL->TL_PLANO,STL->TL_TAREFA,STL->TL_TIPOREG,STL->TL_CODIGO,STL->TL_SEQRELA)

									NGIFDBSEEK("SCP",STL->TL_CODIGO+STL->TL_NUMSA+STL->TL_ITEMSA,2)
									cNumCP := SCP->CP_NUM
								EndIf
								dbSelectArea("STL")
								dbSkip()
							EndDo

							If cNGMNTAS == "1"
								If !Empty(cNumCP) .And. NGIFDBSEEK( "SCP",cNumCP,01,.F. )
									If SCP->CP_PREREQU <> "S"
										If cNGINTER == "M"
											NGMUReques( SCP->( RecNo() ),"SCP",.F.,5 )
										EndIf

										While SCP->( DbSeek( xFilial( "SCP" ) + cNumCP ) )

											// Realiza exclusão da S.A. e seus relacionamentos ( SCR ).
											MntDelReq( SCP->CP_NUM, SCP->CP_ITEM, 'SA' )

										End While

									EndIf
								EndIf
							EndIf

							For nX := 1 To Len(aSTL)
								cChave := aSTL[nX][nTAREFA]+aSTL[nX][nTIPOREG]+aSTL[nX][nCODIGO]+aSTL[nX][nSEQRELA]+If(nSEQTARE==0,"",aSTL[nX][nSEQTARE])
								If !NGIFDICIONA("STL",xFilial("STL")+cOsKill+cPlano+cChave,1)
									RecLock("STL",.T.)
									For nZZ := 1 To Len(aSTLFields)
										STL->(&(aSTLFields[nZZ][1])) := aSTL[nX][nZZ]
									Next nZZ
									STL->TL_ORDEM := cOsKill
									STL->TL_PLANO := cPlano
									MsUnLock()

									nTIP := 0
									If STL->TL_TIPOREG == "F"
										nTIP := 1
									Elseif STL->TL_TIPOREG == "M"
										nTIP := 2
									Elseif STL->TL_TIPOREG == "E"
										nTIP := 3
									Elseif STL->TL_TIPOREG == "P"
										nTIP := 4
									Elseif STL->TL_TIPOREG == "T"
										nTIP := 5
									Endif

									If nTIP > 0
										Aadd(aBLO[nTIP],{	STL->TL_TAREFA ,;
										STL->TL_CODIGO ,;
										If(STL->TL_TIPOREG$"E/F",STL->TL_QUANREC,STL->TL_QUANTID),;
										STL->TL_DTINICI           ,;
										STL->TL_HOINICI           ,;
										STL->TL_DTFIM             ,;
										STL->TL_HOFIM             ,;
										STL->TL_ORDEM             ,;
										STL->TL_PLANO             ,;
										STJ->TJ_CCUSTO            ,;
										Space(Len(SC1->C1_NUM))       ,;   //11 NUMERO DA SOLICITACAO DE COMPRA
										Space(Len(SC1->C1_ITEM))      ,;   //12 NUMERO DO ITEM DA SOLICITACAO DE COMPRA
										0.00                          ,;   //13 QUANTIDADE DO ESTOQUE DA OPERACAO   TL_QTDOPER
										Space(Len(SB2->B2_LOCAL))     ,;   //14 CODIGO DO ALMOXARIFADO OPERACAO     TL_ALMOPERA
										0.00                          ,;   //15 QUANTIDADE DO ESTOQUE DA MATRIZ     TL_QTDOMAT
										Space(Len(SB2->B2_LOCAL))     ,;   //16 CODIGO DO ALMOXARIFADO DA MATRIZ    TL_ALMOMAT
										0.00                          ,;   //17 QUANTIDADE DA SOLICITACAO DE COMPRA TL_QTDSC1
										STL->TL_LOCAL                 ,;   //18 CODIGO DO LOCAL GRAVADO NO STL
										STL->TL_UNIDADE				  ,;   //19 UNIDADE DO INSUMO
										STL->TL_OBSERVA               ,;   //20 OBSERVACAO DO INSUMO
										0.00                          ,;   //21 QUANTIDADE DA SOLICITACAO DE COMPRA TL_QTDSC1
										STL->TL_FORNEC                ,;   //22 Fornecedor TL_FORNEC
										STL->TL_LOJA                  })   //23 Loja do fornecedor TL_LOJA
									EndIf
								EndIf
							Next nX

						EndIf
						M->TJ_CODBEM := STJ->TJ_CODBEM

						//Faz bloqueio dos insumos
						MNTA410FE() //Ferramenta
						MNTA410FU() //Mao de Obra
						MNTA410ES() //Especialidade
						If !IsIncallStack("MNTA830")
							MNTA410PR() //Produto
						EndIf
						MNTA410TE() //Terceiros

						nTAREFA   := aSCAN(aSTQFields,{|x| AllTrim(x[1]) == "TQ_TAREFA"})
						nETAPA    := aSCAN(aSTQFields,{|x| AllTrim(x[1]) == "TQ_ETAPA"})
						nSEQTARE  := aSCAN(aSTQFields,{|x| AllTrim(x[1]) == "TQ_SEQTARE"})

						For nX := 1 To Len(aSTQ)
							cChave := aSTQ[nX][nTAREFA]+aSTQ[nX][nETAPA]+aSTQ[nX][nSEQTARE]
							If !NGIFDICIONA("STQ",xFilial("STQ")+cOsKill+cPlano+cChave,1)
								RecLock("STQ",.T.)
								For nZZ := 1 To Len(aSTQFields)
									STQ->(&(aSTQFields[nZZ][1])) := aSTQ[nX][nZZ]
								Next nZZ
								STQ->TQ_ORDEM := cOsKill
								STQ->TQ_PLANO := cPlano
								MsUnLock()
							EndIf
						Next nX

					EndIf

				EndIf

			Next i

			(cAlsSTJ)->( dbSkip() )

		End

		(cAlsSTJ)->( dbCloseArea() )

		//-----------------------------------------------
		// Ponto de entrada executado após substituições
		//-----------------------------------------------
		If ExistBlock("NGVERSUB")
			ExecBlock("NGVERSUB",.F.,.F.,cCodBem)
		EndIf

		//Verifica se o campo TJSUBSTIT possui tamanho 100
		If lTJ_SUBSTIT

			//Grava a sequencia das manutenções que fora substituidas
			dbSelectArea("STJ")
			dbSetOrder(1)
			If dbSeek(xFilial("STJ") + cOrdemPai + cPlanoPai )

				If len(aOSKill) > 0

					//Percorre o array para verificar as sequencias substituidas
					For nX := 1 to len(aOSKill)

						cSeqOSs += aOSKill[nX]

						If nX < len(aOSKill)
							cSeqOSs += ', '
						EndIf

					Next nX

					RecLock("STJ",.F.)
					STJ->TJ_SUBSTIT := cSeqOSs
					MsUnlock("STJ")
				EndIf
			EndIf

		EndIf

	EndIf

	RestArea(aArea)

Return

//--------------------------------------------------------------------------
/*/{Protheus.doc} NGPROBLQ
Verifica se o produto nao esta bloqueado (B1_MSBLQL == 1)

@author Marcos Wagner Junior
@since 03/06/2009

@param cVProdNG, string, código do produto
@param [lProduto], boolean, se é insumo tipo produto
@return boolean, validação
/*/
//--------------------------------------------------------------------------

Function NGPROBLQ(cVProdNG,lProduto)

	Local aAreaStl  := STL->( GetArea() )
	Local lRet 		:=	.T.
	Local cProdNGN	:= Alltrim(SubStr(cVProdNG,1,15))
	Local cProdNG 	:= cProdNGN+Space(Len(SB1->B1_COD)-Len(cProdNGN))

	If ValType(lProduto) == 'L'
		If lProduto
			M->TL_TIPOREG := 'P'
		Else
			If IsInCallStack("MNTA401")
				M->TL_TIPOREG := M->TL_TIPOREG//Se for chamado pelo MNTA401 continua com o mesmo valor
			Else
				M->TL_TIPOREG := 'M' //Jogando um valor qualquer
			Endif
		Endif
	ElseIf Type("aCols") == "A" .And. Type("aHeader") == "A"
		//Verifica se existe acols para verificar o tipo de insumo
		nPOSINS := aSCAN(aHeader,{|x| AllTrim(Upper(X[2])) == "TL_TIPOREG" })
		If nPOSINS > 0
			If aCols[n][nPOSINS] <> "P"
				Return .T.
			EndIf
		EndIf
	Endif

	If IsInCallStack("MNTA410") .Or. ( IsInCallStack("NG410ININS") .And. ( ValType('M->TL_TIPOREG') = 'C' .And. M->TL_TIPOREG == 'P' ) );
	.Or. ( ValType( 'M->TG_TIPOREG' ) = 'C' .And. M->TG_TIPOREG == 'P' ) .Or. IsInCallStack("MNTA330") .Or. IsInCallStack("MNTA415")  ;
	.Or. IsInCallStack("MNTA420") .Or. FwIsInCallStack( "MNA655BG" )

		dbSelectArea("SB1")
		dbSetOrder(01)
		If dbSeek( xFilial ( "SB1" ) + cProdNG ) .And. SB1->B1_MSBLQL == '1'
			lRet := .F.
		Endif
	EndIf

	If !lRet .And. !IsInCallStack("MNTA330") .And. !FwIsInCallStack( "MNA655BG" )
		Aviso("REGBLOQ",OemToAnsi(STR0089)+cProdNG,{"Ok"}, 2) //"Itens Bloqueados: "
	EndIf

	RestArea( aAreaStl )

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGSTLPRO ³ Autor ³ Marcos Wagner Junior  ³ Data ³28/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a O.S. possui ou nao insumos realizados cujo   ³±±
±±³          ³ tipo seja diferente de 'Produto'.                          ³±±
±±³          ³ Se possui, o retorno sera .f., senao .t.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cOrdem  - Ordem de Servico                                ³±±
±±³          ³ _cPlano  - Plano                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSTLPRO(_cOrdem,_cPlano)
	Local lRet := .t.
	Local aOldArea := GetArea()

	#IFDEF TOP
	cAliasQry := GetNextAlias()
	cQuery := " SELECT 1 "
	cQuery += " FROM "+RetSqlName("STL")+" STL "
	cQuery += " WHERE STL.TL_FILIAL  = '"+xFilial("STL")+"'"
	cQuery += " AND   STL.TL_ORDEM   = '"+_cOrdem+"'"
	cQuery += " AND   STL.TL_PLANO   = '"+_cPlano+"'"
	cQuery += " AND   STL.TL_SEQRELA <> '0' "
	cQuery += " AND   STL.TL_TIPOREG <> 'P' "
	cQuery += " AND   STL.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbGoTop()
	If !Eof()
		lRet := .f.
		lFimOSWhen := .f.
	End
	(cAliasQry)->(dbCloseArea())
	#ELSE
	If NGIFDBSEEK("STL",_cOrdem+_cPlano,1,.f.)
		While !Eof() .And. STL->TL_FILIAL = Xfilial("STL") .And. STL->TL_ORDEM = _cOrdem;
		.And. STL->TL_PLANO = _cPlano
			If STL->TL_SEQRELA <> "0  " .And. STL->TL_TIPOREG <> "P"
				lRet := .f.
				lFimOSWhen := .f.
				Exit
			EndIf
			DbSkip()
		End
	EndIf
	#ENDIF
	RestArea(aOldArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGSTLWHE ³ Autor ³ Marcos Wagner Junior  ³ Data ³28/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ When dos campos TJ_DTMRINI, TJ_HOMRINI, TJ_DTMRFIM e		  ³±±
±±³          ³ TJ_HOMRFIM                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSTLWHE()
	Local lRetWhe := .f.
	If Type('lFimOSWhen') == 'L'
		If lFimOSWhen
			lRetWhe := .t.
		Endif
	Endif
Return lRetWhe

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGINCMANUNI³ Autor ³ Inacio Luiz Kolling   ³ Data ³05/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Converte o incremento da manutencao por tempo em dias        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodBem  - Codigo do bem                        - Obrigatorio³±±
±±³          ³cServico - Codigo do servico                    - Obrigatorio³±±
±±³          ³cSequenc - Sequencia da manutencao              - Obrigatorio³±±
±±³          ³nQtdincr - Quantidade                           - Nao Obrig. ³±±
±±³          ³cUnidade - Unidade                              - Nao Obrig. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³nIncMan - Incremento da manutencao por tempo                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGINCMANUNI(cCodBem,cServico,cSequenc,nQtdincr,cUnidade,dDtMan)
	Local nIncMan := 0,aAreaAA := GetArea(), dUltima
	If nQtdincr <> Nil .And. cUnidade <> Nil
		nIncMan := nQtdincr
		cUniMan := cUnidade
		dUltima := STF->TF_DTULTMA
	Else
		DbselectArea("STF")
		aAreaLSTF := GetArea()
		If NGIFDBSEEK("STF",cCodBem+cServico+cSequenc,1)
			nIncMan := STF->TF_TEENMAN
			cUniMan := STF->TF_UNENMAN
			dUltima := STF->TF_DTULTMA
		EndIf
		RestArea(aAreaLSTF)
	EndIf

	If dDtMan <> Nil
		dUltima := dDtMan
	EndIf

	If cUniMan == "H"
		nIncMan := nIncMan / 24
	ElseIf cUniMan == "S"
		nIncMan := nIncMan * 7
	ElseIf cUniMan == "M"
		nIncMan := (NGSOMAMES(dUltima,nIncMan)) - dUltima // nIncMan * 30
	EndIf

	RestArea(aAreaAA)
Return nIncMan

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGMANCASCATA³ Autor ³ Inacio Luiz Kolling   ³ Data ³26/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Pesquisa em cascata as manutencoes a serem substituidas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodBem  - Codigo do bem                         - Obrigatorio³±±
±±³          ³cServico - Codigo do servico                     - Obrigatorio³±±
±±³          ³cSequenc - Sequencia da manutencao               - Obrigatorio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³vVetSR   - Vetor com as sequencias a ser substituidas         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGMANCASCATA(cCodBem,cServico,cSequenc)
	Local nFl := 0,nFl2 := 0,aAreaAA := GetArea()
	Local vVetSI := {},vVetSP := {},vVetSR := {}
	DbselectArea("STF")
	aAreaLSTF := GetArea()
	If NGIFDBSEEK("STF",cCodBem+cServico+cSequenc,1)
		vVetSI := MNTSEPSEQ(STF->TF_SUBSTIT)
		vVetSR := vVetSI
		If !Empty(vVetSI)
			For nFl := 1 To Len(vVetSI)
				NGIFDBSEEK("STF",cCodBem+cServico+vVetSI[nFl],1)
				vVetSP := MNTSEPSEQ(STF->TF_SUBSTIT)
				If !Empty(vVetSP)
					For nFl2 := 1 To Len(vVetSP)
						If Ascan(vVetSR,{|x| x == vVetSP[nFl2]}) = 0
							Aadd(vVetSR,vVetSP[nFl2])
						EndIf
					Next nFl2
				EndIf
			Next nFl
		EndIf
	EndIf
	RestArea(aAreaLSTF)
	RestArea(aAreaAA)
Return vVetSR

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGPROXMAN³ Autor ³ Paulo Pego            ³ Data ³ 24/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Data da proxima Manutencao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dULTACO - 1- Data da Ultimo Acompamento se quer projetar   ³±±
±±³          ³           data de proxima manutencao controlada por cont.  ³±±
±±³          ³           2- Data da Ultima Manutencao  se quer projetar   ³±±
±±³          ³           data de proxima manutencao controlada por tempo  ³±±
±±³          ³           [DEFAULT = Data do Sistema]                      ³±±
±±³          ³ cTIPO   - Tipo da Manutencao (T=Tempo, C=contador,         ³±±
±±³          ³           A = Tempo/Contador, P=Producao, F=Fim Producao,  ³±±
±±³          ³           S = Segundo Contador)                            ³±±
±±³          ³           [DEFAULT = T]                                    ³±±
±±³          ³ nQTD    - Quantidade tempo para Manutencao                 ³±±
±±³          ³ cUNID   - Unidade de Tempo ( D=Dias, S=Semanas, M=Meses e  ³±±
±±³          ³           F = Dias Fixos)  [DEFAULT = D]                   ³±±
±±³          ³ nCONTAD -  Posicao do contador na Ultima Manutencao        ³±±
±±³          ³ nINCREM - Incremento da Manutencao                         ³±±
±±³          ³ nCONTAC - Acomulador do Contador                           ³±±
±±³          ³ nVARDIA - Variacao dia do Contador.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBS       ³ Retorna a Data da proxima manutencao prevista              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT - Planejamento de Manutencao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DT.ALTERAC³ANLISTA/PROG.³ MOTIVO                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³             ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPROXMAN(dULTACO,cTIPO,nQTD,cUNID,nCONTAD,nINCREM,nCONTAC,nVARDIA,dDtUltMan,cCodBem)
	Local dRet := dDATABASE

	Default dDtUltMan := dDataBase
	Default cCodBem   := ""

	If Empty(dULTACO)
		dULTACO := dDATABASE
	Endif

	If Empty(cUNID)
		cUNID := "D"
	Endif

	If cTIPO $ "C/P/S"
		dRet  := NGPROXMANC(dULTACO, nCONTAD, nINCREM, nCONTAC,nVARDIA,dDtUltMan,cCodBem)
	ElseIf cTIPO == "A"
		dRet1 := NGPROXMANC(dULTACO, nCONTAD, nINCREM, nCONTAC,nVARDIA,dDtUltMan,cCodBem)
		dRet2 := NGPROXMANT(dULTACO, nQTD, cUNID,.t.)
		dRet  := dRet1
		If dRet2 < dRet1
			dRet2 := NGPROXMANT(dULTACO, nQTD, cUNID)
			dRet  := dRet2
		EndIf
	ElseIf cTIPO == "F"
		dRet := NGPROXMANF(dULTACO, nCONTAD, nINCREM, nCONTAC,nVARDIA)
	Else
		dRet := NGPROXMANT(dULTACO, nQTD, cUNID)
	Endif
Return dRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGPRIMAN ³ Autor ³ Paulo Pego            ³ Data ³ 24/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ??ÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula data da proxima manutencao conforme cadastro       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCODBEM - Codigo do Bem                                    ³±±
±±³          ³ cSERVICO- Codigo do Servico                                ³±±
±±³          ³ nSEQUENC- Sequencia da Manutencao                          ³±±
±±³          ³ dINICIO - Data inicial do plano                            ³±±
±±³          ³ dFIM    - Data fim do plano                                ³±±
±±³          ³ cATRASO - Indice se considera manutencao em atraso         ³±±
±±³          ³           [DEFAULT = "S"]                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBS       ³ Retorna um array com 2 elentros (DATA ORIGINAL e DATA REAL)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT - Planejamento de Manutencao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPRIMAN(cCODBEM,cSERVICO,nSEQU,dINICIO,dFIM,cATRASO)
	Local aRET := { Ctod("  /  /    "), Ctod("  /  /    ") }
	Local dRet, dReal
	nSequenc := If(ValType(nSEQU) = "C",nSEQU,Str(nSEQU,3))

	If !NGIFDBSEEK('ST9',cCODBEM,1)
		Return aRET
	Endif

	If !NGIFDBSEEK("STF",cCODBEM+cServico+nSequenc,1)
		Return aRET
	ElseIf STF->TF_PERIODO == "E"
		Return aRET
	Endif

	M->TF_DTULTMA := STF->TF_DTULTMA
	M->TF_CONMANU := STF->TF_CONMANU
	M->TF_INENMAN := STF->TF_INENMAN
	M->TF_TEENMAN := STF->TF_TEENMAN
	M->TF_UNENMAN := STF->TF_UNENMAN
	M->T9_POSCONT := ST9->T9_POSCONT
	M->T9_CONTACU := ST9->T9_CONTACU
	M->T9_VARDIA  := ST9->T9_VARDIA

	nPROX := 0
	While nPROX < M->T9_CONTACU
		nPROX := M->TF_CONMANU + M->TF_INENMAN
	End

	nQTDIA := ((nPROX - M->T9_CONTACU ) / M->T9_VARDIA  )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa a Manutencao considerando as Manutencoes em atraso        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cATRASO == "S"
		If STF->TF_TIPACOM $ "C/P"
			dRet := NGPROXMANC(M->TF_DTULTMA, M->TF_CONMANU, M->TF_INENMAN, M->T9_CONTACU, M->T9_VARDIA)
		ElseIf STF->TF_TIPACOM == "A"
			dRet1 := NGPROXMANC(M->TF_DTULTMA, M->TF_CONMANU, M->TF_INENMAN, M->T9_CONTACU, M->T9_VARDIA)
			dRet2 := NGPROXMANT(M->TF_DTULTMA, M->TF_TEENMAN, M->TF_UNENMAN,.t.)
			dRet  := dRet1
			If dRet2 < dRet1
				dRet := NGPROXMANT(M->TF_DTULTMA, M->TF_TEENMAN, M->TF_UNENMAN)
			EndIf
		Else
			dRet := NGPROXMANT(M->TF_DTULTMA, M->TF_TEENMAN, M->TF_UNENMAN)
		Endif

		If dRET > dFIM
			Return aRET
		Endif

		If dRET < dINICIO
			dReal := NGCHKDTMNT(dINICIO, STF->TF_CALENDA, STF->TF_NAOUTIL)

			If dReal > dFIM
				Return aRet
			Endif

			aRET := {dRet,dReal}
			Return aRET
		Else
			dReal := NGCHKDTMNT(dRet, STF->TF_CALENDA, STF->TF_NAOUTIL)
			aRET := {dRet,aReal}
			Return aRET
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao Considera OS em atraso                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPROX := 0
	While nPROX < M->T9_CONTACU
		nPROX := M->TF_CONMANU + M->TF_INENMAN
	End

	nQTDIA := ((nPROX - M->T9_CONTACU ) / M->T9_VARDIA  )

	dRet := M->TF_DTULTMA
	While dRET < dINICIO
		If STF->TF_TIPACOM $ "C/P"
			dRet := NGPROXMANT(dRET, nQTDIA, "D")
		ElseIf STF->TF_TIPACOM == "A"
			dRet1 := NGPROXMANT(dRET, nQTDIA,"D")
			dRet2 := NGPROXMANT(dRET, M->TF_TEENMAN, M->TF_UNENMAN,.t.)
			dRet  := dRet1
			If dRet2 < dRet1
				dRet  := NGPROXMANT(dRET, M->TF_TEENMAN, M->TF_UNENMAN)
			EndIf
		Else
			dRet := NGPROXMANT(dRET, M->TF_TEENMAN, M->TF_UNENMAN)
		Endif
	End

	dReal := NGCHKDTMNT(dRet, STF->TF_CALENDA, STF->TF_NAOUTIL)
	aRET  := {dRet, dReal}
Return aRET

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGDELINTEG³ Autor ³Inacio Luiz Kolling    ³ Data ³10/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Deleta o insumo e integra‡Æo com a microsiga                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCORDEM  - N£mero da Ordem de Servico                       ³±±
±±³          ³cCPLANO  - N£mero do Plano                                  ³±±
±±³          ³cCTAREFA - C¢digo da Tarefa                                 ³±±
±±³          ³cCTIPO   - Tipo de Insumo                                   ³±±
±±³          ³cCODIGO  - C¢digo do Insumo                                 ³±±
±±³          ³nSEQ     - N£mero da sequencia do Insumo                    ³±±
±±³          ³                                                            ³±±
±±³          ³OBS:       Todos os parametros sÆo obrigat¢rio              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generica                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGDELINTEG(cCORDEM,cCPLANO,cCTAREFA,cCTIPO,cCODIGO,nSEQINS)
	Local nOLDKEYD := INDEXORD()
	Local cCALIASD := ALIAS()
	If cCORDEM == NIL .or. cCPLANO == NIL .or. cCTAREFA == NIL;
	.or. cCTIPO == NIL .or. cCODIGO == NIL .or. nSEQINS == NIL
		Return .f.
	Endif

	nSEQ := If(ValType(nSEQINS) = "C",nSEQINS,Str(nSEQINS,2))
	If NGIFDBSEEK("STL",cCORDEM+cCPLANO+cCTAREFA+cCTIPO+cCODIGO+nSEQ,1)

		// SOLICITA€ÇO DE COMPRA
		If cCTIPO == 'P' .or. cCTIPO == 'T'
			cCODPROD := cCODIGO
			If cCTIPO == 'T'
				cMVTER := If(FindFunction("NGProdMNT"), NGProdMNT("T")[1], PADR(GETMV('MV_PRODTER'),LEN(SB1->B1_COD))) //Ira verificar apenas o primeiro Produto Terceiro do parametro
				If !Empty(cMVTER)
					cCODPROD := cMVTER
				Endif
			Endif

			If cCTIPO == 'P'
				If NGIFDBSEEK("SG1",cCODPROD,1)
					If NGIFDBSEEK("SC2",cCORDEM,1)
						while !eof() .and. sc2->c2_filial == xfilial("SC2");
						.and. sc2->c2_num == cCORDEM
							lProcessa  := .T.
							GERAOPNEW(cCODPROD,,cCORDEM,,,,,,,5)
							NGDBSELSKIP("SC2")
						End While
					Endif
				Else
					NGDELETSC1(cCORDEM,'OS001',cCODPROD)
				Endif
				//Deleta Solicitacao ao Armazem
				If NGCADICBASE('TL_NUMSA','A','STL',.F.)
					If NGIFDBSEEK("SCP",cCODPROD+STL->TL_NUMSA+STL->TL_ITEMSA,2)

						If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"
							If SuperGetMV( "MV_NGMNTAS",.F.,"2" ) == "2" .And. !IsIncallStack("NGMUStoTuO") .And. !IsIncallStack("NGMUReques")
								NGMUReques(SCP->(RecNo()),"SCP",.F.,5)
							EndIf
						EndIf

						// Realiza exclusão da S.A. e seus relacionamentos ( SCR ).
						MntDelReq( SCP->CP_NUM, SCP->CP_ITEM, 'SA' )

					EndIf
				EndIf
			Else
				NGDELETSC1(cCORDEM,'OS001',cCODPROD)
			Endif
		Endif

		// DELETA AS MOVIMNTACOES INTERNAS
		If NGIFDBSEEK('SD3',STL->TL_NUMSEQ,4)
			//-------------------------------------
			//INTEGRACAO POR MENSAGEM UNICA
			//-------------------------------------
			If !IsIncallStack("NGMUStoTuO")
				If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"  //Mensagem Unica
					NGMUCanReq(SD3->(RecNo()),"SD3")
				EndIf
			EndIf
			//exclui a movimentacao no SD3
			NGDELETAREG("SD3")
		Endif

		// DELETA BLOQUEIO DE FERRAMENTA
		If cCTIPO == "F"
			NGIFDBSEEK("SH9","F"+DtoS(STL->TL_DTINICI),4)
			While !Eof() .And. H9_FILIAL+H9_TIPO+DTOS(H9_DTINI) == xFilial("SH9")+"F"+DtoS(STL->TL_DTINICI)
				cMotivo1 := "OS.MANUT." + cCORDEM + " PLANO " + cCPLANO
				cMotivo2 := "OS " + cCORDEM

				If Trim(cMOTIVO1) == Trim(SH9->H9_MOTIVO) .or.;
				Trim(cMOTIVO2) == Trim(SH9->H9_MOTIVO)
					NGDELETAREG("SH9")
				EndIf
				dbSkip()
			End
		EndIf

		// DELETA O INSUMO STL
		dbSelectArea('STL')
		NGDELETAREG("STL")
	Endif

	// DELETA OS PROBLEMAS DA ORDEM DE SERVICO
	If NGIFDBSEEK('STA',cCORDEM+cCPLANO+cCTAREFA+cCTIPO+cCODIGO,1)
		NGDELETAREG("STA")
	Endif

	// DELETA OS BLOQUEIO DE FUNCIONARIOS
	If cCTIPO == 'M'
		If NGIFDBSEEK('STK',cCORDEM+cCPLANO+cCTAREFA+cCODIGO,1)
			NGDELETAREG("STK")
		Endif
	Endif

	// DELETA AS ORDENS DE PRODUCAO

	If cCTIPO == 'P'
		If NGIFDBSEEK('SC2',cCORDEM+'OS'+'001',1)
			while !eof() .and.sc2->c2_filial == xFilial('SC2') .and.;
			sc2->c2_num == cCORDEM .and. sc2->c2_item == 'OS' .and.;
			sc2->c2_sequen == '001'
				If sc2->c2_produto == cCODIGO
					NGDELETAREG("SC2")
				Endif
				DbSKip()
			End
		Endif
	Endif

	// PARA ANALISE

	// DELETA OS RECURSOS DA MICROSIGA (SH9)  - BEM
	// DELETA AS SOLICITACOES DE COMPRAS

	NGDBAREAORDE(cCALIASD,nOLDKEYD)

Return .t.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGCOTAPEDI³ Autor ³Inacio Luiz Kolling    ³ Data ³10/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica h  solicitacao de compra pedido e/ou h  cotacao    ³±±
±±³          ³para o insumo na alteracao ou excluisao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cORDEM   - Numero da ordem de servico                       ³±±
±±³          ³cPLANO   - Numero do plano                                  ³±±
±±³          ³cTAREFA  - C¢digo da tarefa                                 ³±±
±±³          ³cTIPO    - Tipo do Insumo                                   ³±±
±±³          ³cCODIGO  - C¢digo do Insumo                                 ³±±
±±³          ³nSEQ     - N£mero da sequˆncia do Insumo                    ³±±
±±³          ³nTAMG    - Quantidade de Linhas dos GETDADOS anteriores     ³±±
±±³          ³nPOS     - Posi‡Æo ( linha ) atual do item no getdados      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.t. , .f.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCOTAPEDI(cORDEM,cPLANO,cTAREFA,cTIPO,cCODIGO,nSEQUEN,nTAMG,nPOS,lDELG)
	Local lNDEL := .T.
	Local cMENS := STR0090+chr(13)+chr(13);
	+STR0091+chr(13)+chr(13);
	+STR0091+chr(13)+chr(13);
	+STR0093
	Local lDELI := If(lDELG = Nil,.F.,lDELG)

	If cTIPO $ "PT"  //== 'P'
		If cORDEM == NIL .or. cPLANO == NIL .or. cTAREFA == NIL .or.;
		cTIPO == NIL .or. cCODIGO == NIL .or. nSEQUEN == NIL
			MsgInfo(cMENS,STR0018) //"ATENCAO"
			Return .f.
		Else
			If nTAMG == NIL .and. nPOS == NIL
			Else
				If nTAMG == NIL .or. nPOS == NIL
					MsgInfo(cMENS+chr(13)+chr(13)+STR0094,STR0018)
					Return .f.
				Endif
			Endif
		Endif

		If nPOS <> NIL .and. nPOS > nTAMG
			Return lNDEL
		Endif

		nSEQ    := If(ValType(nSEQUEN) = "C",Alltrim(nSEQUEN)+Space(3-Len(Alltrim(nSEQUEN))),Str(nSEQUEN,2))
		cChaveA := Xfilial("STL")+ cORDEM+cPLANO+cTAREFA+cTIPO+cCODIGO+nSEQ
		nPosSeq := GDFIELDPOS("TL_SEQTARE")
		If nPOS > 0 .And. nPosSeq > 0
			cChaveA += aCols[n,nPosSeq]
		EndIf
		NGDBAREAORDE("STL",1)
		If DBSEEK(cChaveA)
			lNDEL := NGGERCOTAC(cORDEM,.t.,STL->TL_CODIGO,,cTIPO,STL->TL_QUANTID,lDELI,STL->TL_NUMSA,STL->TL_ITEMSA)
		Endif
	Endif
Return lNDEL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGGERCOTAC³ Autor ³Inacio Luiz Kolling    ³ Data ³23/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se foi gerado Cotacao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GEN?RICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGGERCOTAC(cVORDEM,lMENSA,cVCODIGO,cCodBem_,cTipIn,nQtdA,lDELG,cNumSa,cItemSA,lSolicit)
	Local nQUANTPED := 0
	Local fCotacao  := .F.
	Local cCODOP1		:= cVORDEM + 'OS001'
	Local cCODOP    := ""
	Local lRETOR    := .T.
	Local cALIASOLD := Alias()
	Local nINDEOLD  := IndexOrd()
	Local lMsg_OS		:= .F.
	Local cCodPTerc := If(cTipIn <> Nil .And. cTipIn = "T" .And. nQtda <> Nil,If(FindFunction("NGProdMNT"),NGProdMNT("T")[1],PADR(GETMV('MV_PRODTER'),LEN(SB1->B1_COD)))," ") //Ira verificar apenas o primeiro Produto Terceiro do parametro
	Local lDELGL		:= If(lDELG = Nil,.F.,lDELG)
	Local lCheCot		:= .T.

	Default lMENSA   := .T.
	Default cCodBem_ := ""
	Default cNumSa	:= Space(TAMSX3("TL_NUMSA")[1])
	Default cItemSA	:= Space(TAMSX3("TL_ITEMSA")[1])
	Default lSolicit := .F.

	lMsg_OS := If( Valtype(cCodBem_) == "C" .and. !Empty(cCodBem_) , .T. , .F. )
	If lSolicit
		cCODOP1 := cVORDEM + "SS001"
	EndIf
	cCODOP := cCODOP1+Space(Len(sc1->c1_op)-Len(cCODOP1))

	If FunName() $ "MNTA420/MNTA990/MNTA265"
		// NOVO CHECAGEM COTACAO
		If fAltera
			fCotacao := NGALTSTLCOMP(cVORDEM,cVCODIGO,cCODOP,lDELGL,cCodPTerc,cNumSa,cItemSA)
			lCheCot  := .F.
		EndIf
	EndIf

	If lCheCot
		NGIFDBSEEK('SC1',cCODOP,4)
		While !EOF() .And. SC1->C1_FILIAL == xFilial("SC1") .And. SC1->C1_OP == cCODOP
			If cVCODIGO <> NIL
				If If (Empty(cCodPTerc),SC1->C1_PRODUTO == cVCODIGO,SC1->C1_PRODUTO = cCodPTerc .And. SC1->C1_FORNECE = Left(cVCODIGO,6);
				.And. SC1->C1_QTDORIG = nQtdA)
					If !Empty(SC1->C1_COTACAO)
						If SC1->C1_COTACAO != "XXXXXX"
							fCotacao := .T.
							Exit
						Endif
					EndIf
					nQUANTPED := nQUANTPED+SC1->C1_QUJE
				EndIf
			Else
				If !Empty(SC1->C1_COTACAO)
					If SC1->C1_COTACAO != "XXXXXX"
						fCotacao := .T.
						Exit
					Endif
				EndIf

				//Verifica se o pedido foi realizado eliminação de resíduo
				dbSelectArea('SC7')
				dbSetOrder(1) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
				If dbSeek( xFilial('SC7') + SC1->C1_PEDIDO + SC1->C1_ITEMPED ) .And. SC7->C7_RESIDUO <> "S"
					nQUANTPED := nQUANTPED + SC1->C1_QUJE
				EndIf
			Endif
			dbSelectArea('SC1')
			dbSkip()
		EndDo
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite excluir SC com Cotacao em aberto.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If fCotacao
		If lMENSA
			If lMsg_OS
				ShowHelpDlg(STR0018,; //"Atenção"
				{If(!lSolicit,STR0095,"Solicitação de Serviço: ")+cVORDEM+" - "+STR0096+cCodBem_,; //"Ordem Serviço: "###"Bem: "
				If(!lSolicit,STR0097,"Não é permitido excluir a Solicitação de Serviço, pois há solicitações de cotação em aberto.")},5,; //"Não é permitido excluir a Ordem de Serviço, pois há solicitações de cotação em aberto."
				{If(!lSolicit,STR0098,"O usuário deverá verificar se as cotações para esta Solicitação de Serviço foram liberadas, se não, deverá liberá-las.")},5) //"O usuário deverá verificar se as cotações para esta Ordem de Serviço foram liberadas, se não, deverá liberá-las."
			Else
				Help(" ",1,"NGMCOTABER")    //"Nao Permitido Excluir Esta Ordem de Servico,"
				//"Pois Ha Solicitacoes de Cotacao em Aberto"###"ATENCAO"
			Endif
		Endif
		lRETOR := .F.
	Endif
	If lRETOR .and. nQUANTPED > 0
		If lMENSA
			If lMsg_OS
				ShowHelpDlg(STR0130,; //"Atenção"
				{If(!lSolicit,STR0095,"Solicitação de Serviço: ")+cVORDEM+" - "+STR0096+cCodBem_,; //"Ordem Serviço: "###"Bem: "
				If(!lSolicit,STR0099,"Não é permitido excluir a Solicitação de Serviço, pois há itens da solicitação de compra em aberto.")},5,; //"Não é permitido excluir a Ordem de Serviço, pois há itens da solicitação de compra em aberto."
				{If(!lSolicit,STR0100,"O usuário deverá verificar para esta Solicitação de Serviço, os itens da solicitação de compra que estão em aberto, se for o caso, liberá-las.")},5) //"O usuário deverá verificar para esta Ordem de Serviço, os itens da solicitação de compra que estão em aberto, se for o caso, liberá-las."
			Else
				Help(" ",1,"NGMSCOMABE")    //"Nao Permitido Excluir Esta Ordem de Servico"
				//"Pois Ha Itens da Solicitacoes Em Pedido de Compra"###"ATENCAO"
			Endif
		Endif
		lRETOR := .F.
	Endif
	NGDBAREAORDE(cALIASOLD,nINDEOLD)
Return lRETOR

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGOSREPROG³ Autor ³Inacio Luiz Kolling    ³ Data ³14/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra as O.S. com data prevista inicio posterior a data    ³±±
±±³          ³real fim de um determinado bem servico e sequencia          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGOSREPROG(cVBEM,cVSERV,nVSEQUEN,dVRFIM,dVPFIM)
    Local cALIASOL  := Alias()
    Local nORDIOLD  := IndexOrd()
    Local nRECGARQ  := Recno()
	Local aROTIOLD  := If(Type("aRotina") = 'A',Aclone(aROTINA),{})
	Local aHEADERO  := If(Type("aHeader") = 'A',Aclone(aHeader),{})
	Local aCOLSOLD  := If(Type("aCols") = 'A',Aclone(aCols),{})
	Local aAlter    := {}

	Local cTRBAREP	:= GetNextAlias() //Alias Tabela Temporária
	Local cUSADO    := chr(0)+chr(0)+chr(1)
	Local lAtualiza := .F.

	Local oTmpTbREP

	Private aHeader := {}
	Private lSELREP := .F.
	Private cREPRBE := GETMV("MV_NGREPRB")

	cREPRBE := If(Empty(cREPRBE),"N",cREPRBE)
	nVSEQ   := If(ValType(nVSEQUEN) = "C",nVSEQUEN,Str(nVSEQUEN,3))
	If NGIFDBSEEK('STF',cVBEM+cVSERV+nVSEQ,1)
		If stf->tf_tipacom = "C"
			lSELREP := .T.
		Endif
	Endif

	aROTINA := {{STR0051,"AxPesqui", 0, 1},;  //"Pesquisar"
	{STR0052,"AxVisual", 0, 2},;  //"Visualizar"
	{STR0053,"AxInclui", 0, 3}}   //"Incluir"

	aDBFP := {{"ORDEM"  , "C", 06, 0 },;
	{"PLANO"  , "C", 06, 0 },;
	{"DTMPINI", "D", 08, 0 },;
	{"DATANOV", "D", 08, 0 }}

	oTmpTbREP := fCriaTRB(cTRBAREP,aDBFP,{{"ORDEM"}})

	Processa({|lEnd| NGOSREPROS(cVBEM,cVSERV,nVSEQ,dVRFIM,dVPFIM,cTRBAREP)},STR0102,STR0103,.F.)

	AADD(aHeader,{STR0104,"ORDEM","@!",6,0,"Naovazio()",cUSADO,"C","",""})
	AADD(aHeader,{STR0105,"PLANO","@!",6,0,"Naovazio()",cUSADO,"C","",""})
	AADD(aHeader,{STR0106,"DTMPINI","99/99/99",8,0,"Naovazio()",cUSADO,"D","",""})
	AADD(aHeader,{STR0107,"DATANOV","99/99/99",8,0,"Naovazio()",cUSADO,"D","",""})
	AADD(aAlter,"DATANOV")

	NGSETIFARQUI(cTRBAREP)
	If Reccount() > 0
		DEFINE MSDIALOG oDLG TITLE STR0108+Dtoc(dVRFIM) From 12,27 TO 32,76 OF oMAINWND
		@ 1.4,2 BUTTON STR0052 OF oDLG SIZE 40,12 ACTION NGVISUESPE('STJ',(cTRBAREP)->ORDEM)
		oGetDb := MsGetDB():New(31,3,150,190,3,"Allwaystrue","Allwaystrue","",,aAlter,,,,cTRBAREP,,,,,,.T.)
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(oGetDb:TudoOk(),(lAtualiza:=.T.,oDlg:End()),)},{||oDlg:End()})
		If lAtualiza
			Processa({|lEnd| NGOSREPRAT(cTRBAREP)},STR0102,STR0109,.F.)
		Endif
	Endif

	oTmpTbREP:Delete()

	aROTINA := aROTIOLD
	aHeader := aHEADERO
	aCols   := aCOLSOLD
	NGDBAREAORDE(cALIASOL,nORDIOLD)
	Dbgoto(nRECGARQ)
Return .t.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGOSREPROS³ Autor ³In cio Luiz Kolling    ³ Data ³24/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Alimenta o arquivo temporario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NGOSREPROG                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGOSREPROS(cVBEM,cVSERV,nVSEQUEN,dVRFIM,dVPFIM,cAliTRB)
	Local nDIFERDT := dVRFIM - dVPFIM,lPRINTES := .F.,cTIPOREP := 1
	Local lPRVAROS := .F.

	nVSEQ := If(ValType(nVSEQUEN) = "C",nVSEQUEN,Str(nVSEQUEN,3))
	If cREPRBE = "N"
		// reporgramacao por bem/servico/sequencia
		NGIFDBSEEK('STJ',"B"+cVBEM+cVSERV+nVSEQ,2)
		ProcRegua(LastRec())
		While !Eof() .And. stj->tj_filial == xFILIAL('STJ') .And.;
		stj->tj_tipoos == "B" .And. stj->tj_codbem == cVBEM .And.;
		stj->tj_servico == cVSERV .And. stj->tj_seqrela == nVSEQ

			IncProc()
			If stj->tj_situaca = 'L' .And. stj->tj_termino = 'N'.And.;
			stj->tj_dtmpini > dVRFIM .And. stj->tj_tiporet <> 'S' .And.;
			val(stj->tj_plano) > 1

				If NGGERCOTAC(stj->tj_ordem,.f.)
					If lSELREP
						If !lPRINTES
							nOpt1 := 1
							DEFINE MSDIALOG oDLGP TITLE STR0110 From 14,30 TO 24,63 OF oMAINWND
							@ 023,020 TO 54,85 LABEL STR0111 of oDlgp Pixel
							@ 030,025 RADIO oRad VAR cTIPOREP ITEMS STR0005,STR0112 3D SIZE 55,10 of oDlgp Pixel
							Activate MsDialog oDLGP On Init EnchoiceBar(oDLGP,{|| nOpt1 := 1,oDLGP:End()},{|| nOpt1 := 2,NGREPROSIN()})
							lPRINTES := .t.
							If cTIPOREP = 2
								nDIFERDT := 0
								If NGIFDBSEEK('STF',stj->tj_codbem+stj->tj_servico+stj->tj_seqrela,1)
									If NGIFDBSEEK('ST9',stj->tj_codbem,1)
										nDIFERDT := INT(STF->TF_INENMAN/ST9->T9_VARDIA)
									Endif
								Endif
							Endif
						Endif
					Endif
					(cAliTRB)->(DbAppend())
					(cAliTRB)->ORDEM   := STJ->TJ_ORDEM
					(cAliTRB)->PLANO   := STJ->TJ_PLANO
					(cAliTRB)->DTMPINI := STJ->TJ_DTMPINI

					If cTIPOREP = 2
						If !lPRVAROS
							lPRVAROS := .T.
							dULTIMAD := dVRFIM + nDIFERDT
						Else
							dULTIMAD := dULTIMAD + nDIFERDT
						Endif
						(cAliTRB)->DATANOV := dULTIMAD
					Else
						(cAliTRB)->DATANOV := (cAliTRB)->DTMPINI + nDIFERDT
					Endif
				Endif
			Endif
			NGDBSELSKIP("STJ")
		End
	Else
		// reporgramacao por bem
		If NGIFDBSEEK('ST9',cVBEM,1)
			If st9->t9_temcont = "S"
				NGIFDBSEEK('STJ',"B"+cVBEM,2)
				ProcRegua(LastRec())
				While !Eof() .And. stj->tj_filial == xFILIAL('STJ') .And.;
				stj->tj_tipoos == "B" .And. stj->tj_codbem == cVBEM

					IncProc()
					If stj->tj_situaca = 'L' .And. stj->tj_termino = 'N'.And.;
					stj->tj_dtmpini > dVRFIM .And. stj->tj_tiporet <> 'S' .And.;
					val(stj->tj_plano) > 1

						If NGGERCOTAC(stj->tj_ordem,.f.)
							If !lPRINTES
								nOpt1 := 1
								DEFINE MSDIALOG oDLGP TITLE STR0110 From 14,30 TO 24,63 OF oMAINWND
								@ 023,020 TO 54,85 LABEL STR0049 of oDlgp Pixel
								@ 030,025 RADIO oRad VAR cTIPOREP ITEMS STR0111,STR0112 3D SIZE 55,10 of oDlgp Pixel
								Activate MsDialog oDLGP On Init EnchoiceBar(oDLGP,{|| nOpt1 := 1,oDLGP:End()},{|| nOpt1 := 2,NGREPROSIN()})
								lPRINTES := .t.
							Endif
							If NGIFDBSEEK('STF',stj->tj_codbem+stj->tj_servico+stj->tj_seqrela,1)
								If stf->tf_tipacom = "C"

									cHORASTJ := Alltrim(stj->tj_horaco1)
									cHORAORI := If(Empty(cHORASTJ) .or. cHORASTJ = ":","08:00",cHORASTJ)
									vVARDIOS := NGBUSCONTHI(stj->tj_codbem,stj->tj_dtorigi,cHORAORI,1,.F.)
									nVARDIOS := vVARDIOS[3]
									nDIASPOS := INT(STF->TF_INENMAN/nVARDIOS)
									nDIASATU := INT(STF->TF_INENMAN/st9->t9_vardia)
									nDIFDIAS := nDIASPOS - nDIASATU
									nDIASOMA := If(nDIFDIAS < 0,nDIFDIAS * -1,nDIFDIAS * -1)

									(cAliTRB)->(DbAppend())
									(cAliTRB)->ORDEM   := STJ->TJ_ORDEM
									(cAliTRB)->PLANO   := STJ->TJ_PLANO
									(cAliTRB)->DTMPINI := STJ->TJ_DTMPINI
									(cAliTRB)->DATANOV := (cAliTRB)->DTMPINI + nDIASOMA

								Endif
							Endif
						Endif

					Endif
					NGDBSELSKIP("STJ")
				End
			Endif
		Endif
	Endif

Return .t.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGREPROSIN³ Autor ³In cio Luiz Kolling    ³ Data ³24/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mensagem de alerta para selecao da reporgramacao da ordem   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NGOSREPROG                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGREPROSIN()
	MsgInfo(STR0113,STR0005)
Return .f.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGOSREPRAT³ Autor ³In cio Luiz Kolling    ³ Data ³24/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza as O.S. e insumos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NGOSREPROG                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGOSREPRAT(cAliTRB)

	Local cCODIGOPTER, cCODLOCALTER

	Local aVRECNOSH9 := {}
	Local lDTAIGUAIS := .F.
	Local nVx        := 0
	Local nRecSTJ    := 0

	Local dMAX := CtoD("  /  /  ")
	Local hMAX := "  :  "

	Local aValuesCZ2 := {}
	Local cIntSFC    := If( FindFunction("NGINTSFC"), NGINTSFC(.F.), "" ) // Verifica se ha integracao com modulo Chao de Fabrica [SIGASFC]

	//Ira verificar apenas o primeiro Produto Terceiro do parametro
	Local cCODPROTER := If(FindFunction("NGProdMNT"), ;
	NGProdMNT("T")[1], PADR(GetMv("MV_PRODTER"),Len(SB1->B1_COD)))

	Local aOSPRE, aOSPOS
	Local cNumCP := ""
	Local dDATAPINI := cTod("  /  /    ")
	Local dDATAPPIN := cTod("  /  /    ")
	Local cHORMPINI := ""
	Local cHORAPPIN := ""
	Local cNGMNTAS	:= SuperGetMV( "MV_NGMNTAS",.F.,"2" )

	NGSETIFARQUI(cAliTRB)
	ProcRegua(LastRec())
	While !Eof()
		IncProc()

		nRecSTJ := 0

		If NGIFDBSEEK('STJ',(cAliTRB)->ORDEM+(cAliTRB)->PLANO,1)

			nRecSTJ := STJ->(Recno()) // Armazena recno para utilizacao posterior a atualizacao
			nDIFDAT := (cAliTRB)->DATANOV - STJ->TJ_DTMPINI

			If nDIFDAT <> 0
				dDATAPINI := STJ->TJ_DTMPINI
				cHORMPINI := STJ->TJ_HOMPINI
				dDATAPPIN := STJ->TJ_DTPPINI
				cHORAPPIN := STJ->TJ_HOPPINI

				cCODIGOP1 := STJ->TJ_ORDEM+"OS001"
				cCODIGOP2 := cCODIGOP1+Space(Len(sd4->d4_op)-Len(cCODIGOP1))

				RecLock("STJ",.F.)
				nDIFDAT := (cAliTRB)->DATANOV - STJ->TJ_DTMPINI
				STJ->TJ_DTMPINI := (cAliTRB)->DATANOV
				STJ->TJ_DTMPFIM := STJ->TJ_DTMPFIM + nDIFDAT
				STJ->(MsUnlock())
				dMAX := STJ->TJ_DTMPFIM
				hMAX := STJ->TJ_HOMPFIM
				If NGIFDBSEEK('STL',STJ->TJ_ORDEM+STJ->TJ_PLANO,1)
					While !Eof() .And. stl->tl_filial == xFILIAL('STL') .And.;
					stl->tl_ordem == stj->tj_ordem .And. stl->tl_plano == stj->tj_plano

						If Alltrim(stl->tl_seqrela) == "0"
							dDtIniOld := STL->TL_DTINICI
							RecLock("STL",.F.)
							STL->TL_DTINICI := STL->TL_DTINICI + nDIFDAT
							STL->TL_DTFIM   := If(STL->TL_TIPOREG = 'P',STL->TL_DTINICI,;
							STL->TL_DTFIM + nDIFDAT)
							//Checa se nova data inicio existe no calendario, se nao existir busca proxima data no calendario
							If STL->TL_USACALE == "S" .And. STL->TL_TIPOREG == "M"
								cVCALEND := NGSEEK("ST1",Substr(STL->TL_CODIGO,1,6),1,"T1_TURNO")
								aCALEND  := NGCALENDAH(cVCALEND)
								dVDATA   := STL->TL_DTINICI
								lDtVal := .f.
								While !lDtVal
									nDIASEM     := Dow(dVDATA)
									If aCALEND[nDIASEM,1] = "00:00"
										dVDATA := dVDATA + 1
									Else
										lDtVal := .t.
										STL->TL_DTINICI := dVDATA
									Endif
								End
								//calcula nova data fim
								nQUANTINS := STL->TL_QUANTID
								If STL->TL_TIPOHOR = "D" .And. STL->TL_TIPOREG $ "E/F/M/T"
									nVALINHOR := Int(STL->TL_QUANTID)
									nVALINMIM := (STL->TL_QUANTID - Int(STL->TL_QUANTID)) * 0.6
									nQUANTINS := nVALINHOR+nVALINMIM
								EndIf
								vDTAHOR := NGDTHORFCALE(STL->TL_DTINICI,STL->TL_HOINICI,nQUANTINS,cVCALEND)
								STL->TL_DTFIM := vDTAHOR[1]
								STL->TL_HOFIM := vDTAHOR[2]

								If NGIFDBSEEK('STK',STL->TL_ORDEM+STL->TL_PLANO+STL->TL_TAREFA+STL->TL_CODIGO,1)
									If STK->TK_DATAINI == dDtIniOld
										RecLock("STK",.F.)
										STK->TK_DATAINI := STL->TL_DTINICI
										STK->TK_DATAFIM := STL->TL_DTFIM
										STK->(MsUnlock())
									EndIf
								Endif
							EndIf
							STL->(MsUnlock())

							If stl->tl_tiporeg == 'P' .Or. stl->tl_tiporeg == 'T'
								cCODIGOPTER  := If(stl->tl_tiporeg == "P",stl->tl_codigo,cCODPROTER)
								cCODLOCALTER := If(stl->tl_tiporeg == "P",stl->tl_local,NGSEEK("SB1",cCODIGOPTER,1,'B1_LOCPAD'))
								If NGIFDBSEEK('SD4',cCODIGOP2+cCODIGOPTER+cCODLOCALTER,2)
									RecLock("SD4",.F.)
									SD4->D4_DATA := STJ->TJ_DTMPINI
									SD4->(MsUnlock())
								Endif
								If NGIFDBSEEK('SC1',cCODIGOP2,4)
									While !Eof() .And. sc1->c1_filial == xFILIAL('SC1') .And.;
									sc1->c1_op == cCODIGOP2
										If sc1->c1_produto = cCODIGOPTER .And.;
										sc1->c1_datprf = dDATAPINI    .And.;
										sc1->c1_local  = cCODLOCALTER
											RecLock("SC1",.F.)
											SC1->C1_DATPRF := STJ->TJ_DTMPINI
											SC1->(MsUnlock())
											If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"  //Mensagem Unica
												NGMUReques(SC1->(RecNo()),"SC1",.F.,3)
											EndIf
											Exit
										Endif
										Dbskip()
									End
								Endif
							Endif
						Endif
						If STL->TL_DTFIM >= dMAX
							If STL->TL_DTFIM > dMAX
								dMAX := STL->TL_DTFIM
								hMAX := STL->TL_HOFIM
							Else
								If STL->TL_HOFIM > hMAX
									hMAX := STL->TL_HOFIM
								EndIf
							EndIf
						EndIf
						NGDBSELSKIP("STL")
					End
				Endif
				If STJ->TJ_DTMPFIM <> dMAX .And. !Empty(dMAX)
					RecLock("STJ",.F.)
					STJ->TJ_DTMPFIM := dMAX
					STJ->TJ_HOMPFIM := hMAX
					STJ->(MsUnLock())
				EndIf

				//Recalcula data de parada prevista incio da manutencao
				aOSPRE := MNT490PRE(STJ->TJ_CODBEM,STJ->TJ_SERVICO,STJ->TJ_SEQRELA,;
				STJ->TJ_DTMPINI,STJ->TJ_HOMPINI)

				//Recalcula data de parada prevista fim da manutencao
				aOSPOS := MNT490POS(STJ->TJ_CODBEM,STJ->TJ_SERVICO,STJ->TJ_SEQRELA,;
				STJ->TJ_DTMPFIM,STJ->TJ_HOMPFIM)

				If !Empty(aOSPOS) .And. !Empty(aOSPRE)
					dbSelectArea("STJ")
					RecLock("STJ",.F.)
					STJ->TJ_DTPPINI := aOSPRE[1]
					STJ->TJ_HOPPINI := aOSPRE[2]
					STJ->TJ_DTPPFIM := aOSPOS[1]
					STJ->TJ_HOPPFIM := aOSPOS[2]
					STJ->(MsUnLock())
				Endif

				If NGIFDBSEEK('SC2',cCODIGOP1,6)
					While !Eof() .And. sc2->c2_filial == xFILIAL('SC2') .And.;
					sc2->c2_num+sc2->c2_item+sc2->c2_sequen = cCODIGOP1

						RecLock("SC2",.F.)
						SC2->C2_DATPRI := STJ->TJ_DTMPINI
						SC2->C2_DATPRF := STJ->TJ_DTMPINI
						SC2->C2_EMISSAO := STJ->TJ_DTMPINI
						SC2->(MsUnlock())
						Dbskip()
					End
				Endif

				//Altera Data Solicitacao Armazem
				If NGCADICBASE('TT4_FILIAL','A','TT4',.F.)
					NGIFDBSEEK('TT4',STJ->TJ_ORDEM+STJ->TJ_PLANO,2)
					While !Eof() .and. xFilial("TT4")+STJ->TJ_ORDEM+STJ->TJ_PLANO == TT4->TT4_FILIAL+TT4->TT4_ORDEM+TT4->TT4_PLANO
						If !Empty(TT4->TT4_NUMSA) .and. !Empty(TT4->TT4_ITEMSA)
							If NGIFDBSEEK('SCP',TT4->TT4_NUMSA+TT4->TT4_ITEMSA,1)
								RecLock("SCP",.f.)
								SCP->CP_DATPRF  := STJ->TJ_DTMPINI
								SCP->(MsUnLock())


								If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"
									If cNGMNTAS == "1"
										cNumCP := SCP->CP_NUM
									Else
										NGMUReques(SCP->(RecNo()),"SCP",.F.,3)
									EndIf
								EndIf

							Endif
						Endif
						NGDBSELSKIP("TT4")
					End While
				Endif

				If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"
					If cNGMNTAS == "1"
						If !Empty(cNumCP) .And. NGIFDBSEEK( "SCP",cNumCP,01,.F. )
							NGMUReques( SCP->( RecNo()),"SCP",.F.,3 )
						EndIf
					EndIf
				EndIf

				If NGIFDBSEEK('ST3',STJ->TJ_ORDEM+STJ->TJ_PLANO,2)
					While !Eof() .And. ST3->T3_FILIAL == xFILIAL('ST3') .And.;
					ST3->T3_ORDEM = STJ->TJ_ORDEM .And. ST3->T3_PLANO = STJ->TJ_PLANO

						RecLock("ST3",.F.)
						ST3->T3_DTINI := ST3->T3_DTINI + nDIFDAT
						ST3->T3_DTFIM := ST3->T3_DTFIM + nDIFDAT
						ST3->(MsUnlock())
						Dbskip()
					End
				Endif

				If NGCADICBASE("TTY_ORDEM","A","TTY",.F.)
					NGIFDBSEEK('TTY',STJ->TJ_ORDEM+STJ->TJ_PLANO,1)
					While !Eof() .And. TTY->(TTY_FILIAL+TTY_ORDEM+TTY_PLANO) == xFILIAL("TTY")+STJ->TJ_ORDEM+STJ->TJ_PLANO
						RecLock("TTY",.F.)
						TTY->TTY_DTINI := TTY->TTY_DTINI + nDIFDAT
						TTY->TTY_DTFIM := TTY->TTY_DTFIM + nDIFDAT
						TTY->(MsUnlock())
						dbSkip()
					End
				Endif
				cCODFERRB := Space(Len(ST9->T9_RECFERR))
				If NGIFDBSEEK('ST9',STJ->TJ_CODBEM,1)
					If ST9->T9_FERRAME == "F"
						cCODFERRB := ST9->T9_RECFERR
						//Checa bloqueios pela data da manutencao prevista inicio
						If NGIFDBSEEK('SH9',"F"+ST9->T9_RECFERR+DTOS(dDATAPINI)+cHORMPINI,3)
							While !Eof() .And. SH9->H9_FILIAL+SH9->H9_TIPO+SH9->H9_FERRAM+DTOS(SH9->H9_DTINI)+ SH9->H9_HRINI ==;
							xFILIAL("SH9")+"F"+ST9->T9_RECFERR+DTOS(dDATAPINI)+cHORMPINI
								If STJ->TJ_ORDEM $ SH9->H9_MOTIVO
									//desfazer SGT na versao 12 (verificar com a Totvs)
									If AliasInDic("SGT")
										SGT->(dbSetOrder(1))
										If SGT->(dbSeek(xFilial("SGT")+SH9->(H9_TIPO+H9_CCUSTO+H9_RECURSO+DTOS(H9_DTINI)+H9_HRINI)))
											RecLock("SGT",.F.)
											SGT->GT_DTINI += nDIFDAT
											SGT->GT_DTFIM += nDIFDAT
											SGT->(MsUnLock())
										EndIf
									EndIf
									RecLock("SH9",.F.)
									SH9->H9_DTINI := SH9->H9_DTINI + nDIFDAT
									SH9->H9_DTFIM := SH9->H9_DTFIM + nDIFDAT
									SH9->(MsUnlock())
								EndIf
								dbSkip()
							End
						Else
							//Checa bloqueios pela data de parada prevista inicio
							If !Empty(dDATAPPIN)
								NGIFDBSEEK('SH9',"F"+ST9->T9_RECFERR+DTOS(dDATAPPIN)+cHORAPPIN,3)
								While !Eof() .And. SH9->H9_FILIAL+SH9->H9_TIPO+SH9->H9_FERRAM+DTOS(SH9->H9_DTINI)+ SH9->H9_HRINI ==;
								xFILIAL("SH9")+"F"+ST9->T9_RECFERR+DTOS(dDATAPPIN)+cHORAPPIN

									If STJ->TJ_ORDEM $ SH9->H9_MOTIVO
										//desfazer SGT na versao 12 (verificar com a Totvs)
										If AliasInDic("SGT")
											SGT->(dbSetOrder(1))
											If SGT->(dbSeek(xFilial("SGT")+SH9->(H9_TIPO+H9_CCUSTO+H9_RECURSO+DTOS(H9_DTINI)+H9_HRINI)))
												RecLock("SGT",.F.)
												SGT->GT_DTINI += nDIFDAT
												SGT->GT_DTFIM += nDIFDAT
												SGT->(MsUnLock())
											EndIf
										EndIf
										RecLock("SH9",.F.)
										SH9->H9_DTINI := SH9->H9_DTINI + nDIFDAT
										SH9->H9_DTFIM := SH9->H9_DTFIM + nDIFDAT
										SH9->(MsUnlock())
									Endif
									dbSkip()
								End
							EndIf
						EndIf
					EndIf

					//Checa bloqueios pela data da manutencao prevista inicio
					lDTAIGUAIS := If(!Empty(dDATAPPIN) .And. dDATAPINI == dDATAPPIN,.T.,.F.)
					NGIFDBSEEK('SH9',"B"+DTOS(dDATAPINI),2)
					While !Eof() .And. H9_FILIAL+H9_TIPO+DTOS(H9_DTINI) == xFILIAL("SH9")+"B"+DTOS(dDATAPINI)
						If STJ->TJ_ORDEM $ SH9->H9_MOTIVO
							Aadd(aVRECNOSH9,{Recno()})
						EndIf
						NGDBSELSKIP("SH9")
					End

					//Checa bloqueios pela data de parada prevista inicio
					If !Empty(dDATAPPIN) .And. !lDTAIGUAIS
						NGIFDBSEEK('SH9',"B"+DTOS(dDATAPPIN),2)
						While !Eof() .And. H9_FILIAL+H9_TIPO+DTOS(H9_DTINI) == xFILIAL("SH9")+"B"+DTOS(dDATAPPIN)
							If STJ->TJ_ORDEM $ SH9->H9_MOTIVO
								Aadd(aVRECNOSH9,{Recno()})
							EndIf
							NGDBSELSKIP("SH9")
						End
					EndIf
				EndIf
				If NGIFDBSEEK('SH9',"F"+Dtos(dDATAPINI),2)
					While !Eof() .And. SH9->H9_FILIAL == xFILIAL('SH9') .And.;
					SH9->H9_TIPO = "F" .And. SH9->H9_DTINI = dDATAPINI

						If STJ->TJ_ORDEM $ SH9->H9_MOTIVO .And. SH9->H9_FERRAM <> cCODFERRB
							Aadd(aVRECNOSH9,{Recno()})
						EndIf
						dbskip()
					End
				EndIf

				If Len(aVRECNOSH9) > 0
					For nVx := 1 To Len(aVRECNOSH9)
						dbSelectArea("SH9")
						dbGoto(aVRECNOSH9[nVx][1])
						//desfazer SGT na versao 12 (verificar com a Totvs)
						If AliasInDic("SGT")
							SGT->(dbSetOrder(1))
							If SGT->(dbSeek(xFilial("SGT")+SH9->(H9_TIPO+H9_CCUSTO+H9_RECURSO+DTOS(H9_DTINI)+H9_HRINI)))
								RecLock("SGT",.F.)
								SGT->GT_DTINI += nDIFDAT
								SGT->GT_DTFIM += nDIFDAT
								SGT->(MsUnLock())
							EndIf
						EndIf
						RecLock("SH9",.F.)
						SH9->H9_DTINI := SH9->H9_DTINI + nDIFDAT
						SH9->H9_DTFIM := SH9->H9_DTFIM + nDIFDAT
						SH9->(MsUnlock())
					Next nVx
				EndIf
			EndIf

			// Caso integrado ao modulo de Chao de Fabrica (SIGASFC), atualiza parada programada (CZ2)
			If !Empty(dDATAPPIN) .And. !Empty(cIntSFC) .And. !Empty(NGVRFMAQ(STJ->TJ_CODBEM))
				aValuesCZ2 := {}

				aAdd( aValuesCZ2 , { "CZ2_DTBGPL" , STJ->TJ_DTPPINI    } ) // Data de Início da Parada do Bem
				aAdd( aValuesCZ2 , { "CZ2_HRBGPL" , Padr(Trim(Transform(STJ->TJ_HOPPINI,"99:99:99")),8,"0")} ) // Hora Fim da Parada do Bem
				aAdd( aValuesCZ2 , { "CZ2_DTEDPL" , STJ->TJ_DTPPFIM    } ) // Data de Fim da Parada do Bem
				aAdd( aValuesCZ2 , { "CZ2_HREDPL" , Padr(Trim(Transform(STJ->TJ_HOPPFIM,"99:99:99")),8,"0")} ) // Hora Fim da Parada do Bem
				aAdd( aValuesCZ2 , { "CZ2_TPSTSP" , NGSFCSTPP(cIntSFC) } )
				NGSFCATPRD(STJ->TJ_ORDEM,aValuesCZ2) // Atualiza Parada Programada conforme Ordem de Serviço
			Endif

			// [Mensagem Unica] Se a O.S. foi liberada e ha integracao por MU
			If nRecSTJ > 0 .And. AllTrim(GetNewPar("MV_NGINTER","N")) == "M"
				dbSelectArea("STJ")
				dbgoto(nRecSTJ)

				// Verifica se O.S. esta liberada, possibilitando atualizacao da mesma
				If STJ->TJ_SITUACA == "L" .And. AllTrim(GetNewPar("MV_NGINTER","N")) == "M"  //Mensagem Unica
					NGMUMntOrd(nRecSTJ, 3)
				Endif

			EndIf

		Endif

		NGDBSELSKIP(cAliTRB)

	End

Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} NGOSABRVEN
Alerta a existencia de O.S. em abertas e/ou vencidas

@author  Inacio Luiz Kolling
@since   26/07/2002
@version P12

@param cVBem, Caractere, Código do Bem
@param cVSer, Caractere, Código do Serviço
@param lCorr, Lógico, Se é corretivo
@param lPreve, Lógico, Se é preventivo
@param lConf, Lógico,
@param nSeq, Numérico, sequencia da O.S. (Preventiva)
@param cFilTroc, Caractere, Filial para trocar
@param lMostraMsg, Lógico, Se mostra mensagem em tela
@param lClass, Lógico, Se a chamada vem da Class
@param nAlert, numérico, Indica se as mensagens devem ser a respeito
						 de uma S.S. ou O.S. ao usar a rotina de Árvore Lógica
							-	1: Ordem Serviço
							-	2: Solicitação de Serviço

@return lRETORAB, lógico, indica se a validação está correta e se a ação
						  será efetuada
/*/
//-------------------------------------------------------------------
Function NGOSABRVEN(cVBem,cVSer,lCorr,lPreve,lConf,nSeq,cFilTroc,lMostraMsg, lClass, nAlert)

	Local cALIASOL := Alias()
	Local nORDIOLD := IndexOrd()
	Local nRECGARQ := Recno()
	Local aRet     := {.T.,"",.T.}

	Private lRETORAB := .T.

	Default lMostraMsg := !IsBlind()
	Default lClass     := .F.
	Default nAlert	   := 0

	Processa({|lEnd| NGOSABERTP(cVBem,cVSer,lCorr,lPreve,lConf,nSeq,cFilTroc,lMostraMsg,@aRet,lClass,nAlert)},STR0102,STR0114,.F.)

	NGDBAREAORDE(cALIASOL,nORDIOLD)
	Dbgoto(nRECGARQ)

Return Iif(lClass, aRet, lRETORAB)

//-------------------------------------------------------------------
/*/{Protheus.doc} NGOSABERTP
Alimenta o arquivo temporario

@author  Inacio Luiz Kolling
@since   26/07/2002
@version P12

@param cVBem, Caractere, Código do Bem
@param cVSer, Caractere, Código do Serviço
@param lCorr, Lógico, Se é corretivo
@param lPreve, Lógico, Se é preventivo
@param lConf, Lógico,
@param nSequenc, Numérico, sequencia da O.S. (Preventiva)
@param cFilTroc, Caractere, Filial para trocar
@param lMostraMsg, Lógico, Se mostra mensagem em tela
@param aRet, Array, Retorno da função
@param lClass, Lógico, Se a chamada vem da Class
@param nAlert, numérico, 1 quando a chamada é na inclusão de uma O.S.
	2 quando a chamada é na inclusão de uma S.S.
@return lRETORAB, lógico, indica se a validação está correta e se a ação
						  será efetuada
/*/
//-------------------------------------------------------------------
Function NGOSABERTP(cVBEM,cVSER,lCORR,lPREVE,lCONF,nSEQUENC,cFilTroc,lMostraMsg,aRet,lClass,nAlert)

	LOcal cMENSC     := Space(1) // Indica que há uma corretiva com mesmo bem + serviço
	Local cMENSP     := Space(1) // Indica que há uma preventiva atrasada
	Local cMENSS     := Space(1) // Indica que há uma preventiva atrasada com mesmo serviço+sequencia
	Local cMENSF     := Space(1) // Mensagem final que será apresentada
	LOcal nULTCOMAN  := 0
	Local cFilSt9    := NGTROCAFILI("ST9",cFilTroc)
	Local cFilTpe    := NGTROCAFILI("TPE",cFilTroc)
	Local cMNTOSCO   := GetNewPar("MV_MNTOSCO","S") //Permite que mais de uma O.S. Corretiva possa ser aberta sem que a anterior esteja finalizada.
	Local lIncluiOS	 := GETMV( "MV_NGPREVE" ) $ "1/3/S" // Exibir alerta de manutencao preventiva atrasada na inclusão de OS
	Local lIncluiSS	 := GETMV( "MV_NGPREVE" ) $ "2/3/S" // Exibir alerta de manutencao preventiva atrasada na inclusão de SS

	Local nPCONTFIXO := GetMV("MV_NGCOFIX") //Percentual para calcular o contador fixo da manutencao
	Local nPERFIXO   := nPCONTFIXO / 100

	Default lMostraMsg := .T.
	Default aRet       := {}
	Default lClass     := .F.
	Default nAlert	   := 0

	lIncluiOS := lIncluiOS .And. nAlert != 2
	lIncluiSS := lIncluiSS .And. nAlert == 2

	If nSEQUENC <> Nil
		nSEQ := If(ValType(nSEQUENC) = "C",nSEQUENC,Str(nSEQUENC,3))
	Else
		nSEQ := nSEQUENC
	EndIf

	DbselectArea("ST9")
	nREGST9 := Recno()

	//--------------------------------------------------------------------------
	// Trecho abaixo verifica se há uma corretiva para o mesmo bem + serviço
	//---------------------------------------------------------------------------
	If cMNTOSCO == "S"
		If GETMV("MV_NGCORAB") == "S" .And. lCORR
			NGIFDBSEEK('STJ',"B"+cVBEM+cVSER+"0  ",2)
			ProcRegua(LastRec())
			While !Eof() .And. stj->tj_filial == xFILIAL('STJ') .And.;
			stj->tj_tipoos == "B" .And. stj->tj_codbem == cVBEM .And.;
			stj->tj_servico == cVSER .And. Alltrim(stj->tj_seqrela) == "0"

				IncProc()
				If stj->tj_situaca = 'L' .And. stj->tj_termino = 'N'
					cMENSC := STR0115 // "Existe ordem de servico corretiva aberta para o bem,servico"
					Exit
				Endif
				NGDBSELSKIP("STJ")
			End
		Endif
	EndIf

	//--------------------------------------------------------------------
	// Trecho abaixo verifica se há uma preventiva atrasada para o bem
	//--------------------------------------------------------------------
	If lPREVE .And. ( lIncluiOS .Or. lIncluiSS )

		NGDBAREAORDE("STF",1)
		cCHAVESTF := cVBEM
		cWHILESTF := "stf->tf_codbem"
		If cVSER <> NIL .And. nSEQ <> NIL
			cCHAVESTF := cVBEM+cVSER+nSEQ
			cWHILESTF := "stf->tf_codbem+stf->tf_servico+stf->tf_seqrela"
			cMENSS    := STR0116 //" ,servico,sequencia"
		Endif
		Dbseek(xFILIAL("STF")+cCHAVESTF)
		ProcRegua(LastRec())
		While !Eof() .And. stf->tf_filial == xFILIAL('STF') .And.;
		&(cWHILESTF) == cCHAVESTF

			IncProc()
			If STF->TF_TIPACOM <> "A" .And. STF->TF_TIPACOM <> "T" .And. STF->TF_TIPACOM <> "S"  //Contator, Producao e Contador Fixo
				NGDBAREAORDE("ST9",1)
				If Dbseek(cFilSt9+stf->tf_codbem)
					If !Empty(st9->t9_contacu) .And. !Empty(st9->t9_dtultac) .And. !Empty(st9->t9_vardia)

						If STF->TF_TIPACOM = "F"
							nULTCOMAN := If(STF->( FieldPos("TF_CONPREV") ) > 0,STF->TF_CONPREV,STF->TF_CONMANU)
							
							nINCPERC := STF->TF_INENMAN * nPERFIXO     // Incremento da manutencao com percentual

							nVEZMANU := Int(nULTCOMAN / STF->TF_INENMAN) // Numero de vezes que foi feito a manutencao
							nCONTFIX := nVEZMANU * STF->TF_INENMAN       // Contador fixo exato
							nCONTPAS := nULTCOMAN - nCONTFIX             // Quantidade que passou da manutenção fixa

							If nCONTPAS < nINCPERC .Or. nINCPERC == 0
								nULTCOMAN := nCONTFIX
							Else
								nULTCOMAN := nCONTFIX + STF->TF_INENMAN
							EndIf
						Else
							nULTCOMAN := STF->TF_CONMANU
						EndIf

						If NGPROXMAN(st9->t9_dtultac,stf->tf_tipacom,stf->tf_teenman,;
						stf->tf_unenman,nULTCOMAN,STF->TF_INENMAN,;
						st9->t9_contacu,st9->t9_vardia) < dDataBase
							cMENSP := STR0117+cMENSS //"Existe(m) manutenção(ões) preventiva(s) atrasada(s) para o Bem."
							Exit
						EndIf
					EndIf
				EndIf
			Else
				If STF->TF_TIPACOM = "A"  //Tempo/Contador
					NGDBAREAORDE("ST9",1)
					If Dbseek(cFilSt9+stf->tf_codbem)
						If !Empty(st9->t9_contacu) .And. !Empty(st9->t9_dtultac) .And. !Empty(st9->t9_vardia)
							dDATCONTA := NGPROXMANC(st9->t9_dtultac,stf->tf_conmanu,STF->TF_INENMAN,st9->t9_contacu,st9->t9_vardia) //Data da manutencao por contador
							dDATTEMPO := NGPROXMANT(stf->tf_dtultma,stf->tf_teenman,stf->tf_unenman,.t.)
							dDATACMA  := dDATCONTA

							If dDATTEMPO < dDATCONTA
								dDATACMA  := NGPROXMANT(stf->tf_dtultma,stf->tf_teenman,stf->tf_unenman)
							EndIf

							If dDATACMA <= dDataBase
								cMENSP := STR0117+cMENSS //"Existe(m) manutenção(ões) preventiva(s) atrasada(s) para o Bem."
								Exit
							EndIf
						EndIf
					EndIf

				ElseIf STF->TF_TIPACOM = "T" //Tempo
					NGDBAREAORDE("ST9",1)
					If Dbseek(cFilSt9+stf->tf_codbem)
						If NGPROXMAN(stf->tf_dtultma,stf->tf_tipacom,stf->tf_teenman,;
						stf->tf_unenman,stf->tf_conmanu,STF->TF_INENMAN,;
						st9->t9_contacu,st9->t9_vardia) < dDataBase
							cMENSP := STR0117+cMENSS //"Existe(m) manutenção(ões) preventiva(s) atrasada(s) para o Bem."
							Exit
						EndIf
					EndIf
				Else                         //Segundo Contador
					NGDBAREAORDE("TPE",1)
					If Dbseek(cFilTpe+stf->tf_codbem)
						If !Empty(tpe->tpe_contac) .And. !Empty(tpe->tpe_dtulta) .And. !Empty(tpe->tpe_vardia)
							If NGPROXMAN(tpe->tpe_dtulta,stf->tf_tipacom,stf->tf_teenman,;
							stf->tf_unenman,stf->tf_conmanu,STF->TF_INENMAN,;
							tpe->tpe_contac,tpe->tpe_vardia) < dDataBase
								cMENSP := STR0117+cMENSS //"Existe(m) manutenção(ões) preventiva(s) atrasada(s) para o Bem."
								Exit
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			NGDBSELSKIP("STF")
		End
	Endif

	//----------------------------------------------------
	// Trecho abaixo faz o tratamento para as mensagens
	//----------------------------------------------------
	If !Empty(cMENSC) .Or. !Empty(cMENSP)
		If !Empty(cMENSC) .And. !Empty(cMENSP)
			cMENSF := cMENSC+chr(13)+chr(13)+STR0072+cMENSP
		ElseIf !Empty(cMENSC)
			cMENSF := cMENSC
		ElseIf !Empty(cMENSP)
			cMENSF := cMENSP
		Endif

		If IsInCallStack( "MNTA902" ) //Se for chamada através da árvore lógica.

			If nAlert == 2 .And. lIncluiSS .And. lCONF // Se chamada a função para incluir uma Solicitação de Servico na árvore lógica.
				If lMostraMsg
					// "Quanto a inclusão da Solicitação de Serviço ?  Confirma/Cancela"
					lRETORAB := MsgYesNo(cMENSF+chr(13)+chr(13)+chr(13)+STR0118,STR0018)
				Else
					aRet := {.T.,cMENSF+chr(13)+chr(13)+chr(13)+STR0118,.F.}
				EndIf
			ElseIf nAlert == 1 .And. lIncluiOS .And. lCONF //Se chamada a função para incluir uma Ordem de Serviço na árvore lógica.
				If lMostraMsg
					//"Quanto a inclusão da ordem de serviço ?  Confirma/Cancela"
					lRETORAB := MsgYesNo(cMENSF+chr(13)+chr(13)+chr(13)+STR0119,STR0018) // Ordem de Serviço.
				Else
					aRet := {.T.,cMENSF+chr(13)+chr(13)+chr(13)+STR0119,.F.}
				EndIf
			Else
				If lMostraMsg
					MsgInfo(cMENSF+chr(13)+chr(13)+chr(13),STR0018)
				Else
					aRet := {.T.,cMENSF,.T.}
				EndIf
				lRETORAB := .T.
			EndIf

		Else

			If IsInCallStack( "MNTA280" ) .And. lCONF // Se chamado a rotina de Abertura de Solicita?o de Servi?.
				If lMostraMsg
					lRETORAB := MsgYesNo(cMENSF+chr(13)+chr(13)+chr(13)+STR0118,STR0018) // Solicita?o de Servi?.
				Else
					aRet := {.T.,cMENSF+chr(13)+chr(13)+chr(13)+STR0118,.F.}
				EndIf
			ElseIf lCONF
				If lMostraMsg
					lRETORAB := MsgYesNo(cMENSF+chr(13)+chr(13)+chr(13)+STR0119,STR0018) // Ordem de Servi?.
				Else
					aRet := {.T.,cMENSF+chr(13)+chr(13)+chr(13)+STR0119,.F.}
				EndIf
			Else
				If lMostraMsg
					MsgInfo(cMENSF+chr(13)+chr(13)+chr(13),STR0018)
				Else
					aRet := {.T.,cMENSF,.T.}
				EndIf
				lRETORAB := .T.
			EndIf

		EndIf

	Endif
	DbselectArea("ST9")
	Dbgoto(nREGST9)

Return Iif(lClass, aRet, lRETORAB)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGOSPORTEM³ Autor ³In cio Luiz Kolling    ³ Data ³31/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se ha O.S. vencidas por tempo e gera O.S.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGOSPORTEM(cVBEM,cVSER,nVSEQMAN,lALERTA)
	Local cALIASOT := Alias()
	Local nORDIOLT := IndexOrd()
	Local nRECGART := Recno()
	Local cPLANOS  := stj->tj_plano
	Local cCONDSTF := "(stf->tf_tipacom = 'T' .Or. stf->tf_tipacom = 'A') .And. stf->tf_periodo <> 'E'"
	nVSEQ := If(ValType(nVSEQMAN) = "C",nVSEQMAN,Str(nVSEQMAN,3))

	If NGIFDBSEEK("STF",cVBEM+cVSER+nVSEQ,1) .And. &(cCONDSTF)

		dDTPROXM := NGXPROXMAN(cVBEM)

		If dDTPROXM < dDataBase  .Or. dDTPROXM > dDataBase
			aNGGERAOS := NGGERAOS('P',dDTPROXM,cVBEM,cVSER,nVSEQ,'S','S','S')
			If aNGGERAOS[1][1] = 'S'
				If NGIFDBSEEK("STJ",aNGGERAOS[1][3],1)
					RecLock("STJ",.F.)
					STJ->TJ_DTMPFIM := If(dDTPROXM < dDataBase,dDataBase,dDTPROXM)+(STJ->TJ_DTMPFIM-STJ->TJ_DTMPINI)
					STJ->TJ_DTMPINI := If(dDTPROXM < dDataBase,dDataBase,dDTPROXM)
					STJ->(MsUnlock())
				EndIf
				If lALERTA .And. MsgYesNo(STR0120+chr(13)+chr(13)+STR0121)
					NGIMP675(aNGGERAOS[1,3],cPLANOS,.f.)
				Endif
			Endif
		Endif
	Endif

	NGDBAREAORDE(cALIASOT,nORDIOLT)
	Dbgoto(nRECGART)
Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIMP675
Impressao de ordem de servico

@return .T.

@Param cVORDEM
@Param cVPLANO
@Param lPARI
@Param cFilTroc
@Param nRecOs

@sample
NGIMP675()

@author Inacio Luiz Kolling
@since 24/06/04
/*/
//---------------------------------------------------------------------
Function NGIMP675(cVORDEM,cVPLANO,lPARI,cFilTroc,nRecOs)

	Local aItems
	Local lNovo676  := .F.
    Local lRet      := .T.
	Local nTamDial  := 250
    Local nTamGrp   := 82
	Local nOptPE	:= 0

	Private oDlgC
    Private nOpRe   := 1
    Private nOpca   := 0
	Private cNomFil := SM0->M0_FILIAL
	Private nHorz   := 100

	Default nRecOs := 0

	DbSelectArea("STJ")
	cAliasimp := Alias()
	nIndeximp := IndexOrd()
	nIMP675RE := Recno()
	If cVORDEM <> NIL .And. cVPLANO <> NIL
		DbSetOrder(1)
		Dbseek(NGTROCAFILI("STJ",cFilTroc)+cVORDEM+cVPLANO)
	Endif

    If !ExistBlock("MNTIMPOS")

        aItems := { STR0233, STR0234, STR0235+" "+STR0236,;  // "Basica" "Simplificada" "Padrao"##"Normal"
                    STR0235+" "+STR0237,STR0238+" "+STR0236,;// "Padrao"##"Gráfica" "Completa"##"Normal"
                    STR0238+" "+STR0237 , STR0241 }          // "Completa"##"Gráfica"##"OS Interna"

        If ExistBlock("IMP675OS")
            aOptionsPE := {}
            aOptionsPE := ExecBlock("IMP675OS", .F., .F.)
            // Adiciona as opções informadas pelo PE no menu de impressões padrão
            // Ajusta tamanho da Dialog e do Grupo de opções conforme quantidade de opções inseridas
            For nOptPE := 1 To Len(aOptionsPE)
                aAdd(aItems, aOptionsPE[nOptPE, 1])
                nTamDial += 18
                nTamGrp  += 10
            Next nOptPE
        EndIf

		DEFINE MSDIALOG oDlgC FROM 00,00 TO nTamDial,600 TITLE STR0232 PIXEL //"Modelo de Impressao da ordem"

        oPnlPai := TPanel():New(00,00,,oDlgC,,,,,,320,200,.F.,.F.)
		oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		@ 0005,030 To nTamGrp,155 LABEL STR0239 of oPnlPai Pixel  // "Opcoes"

		TRadMenu():New( 015, 035, aItems,{|u|Iif (PCount()==0,nOpRe,nOpRe:=u)},oPnlPai,,,,,,,,60,10,,,,.T.)

		Activate MsDialog oDlgC On Init EnchoiceBar(oDlgC,{|| nOPCA := 1,oDlgC:End()},{||oDlgC:End()}) Centered
		If nOpca != 0
		    If nOpRe == 1 .OR. nOpRe == 2
			    lNovo676 := .T.
		    Endif
        Else
            lRet := .F.
        EndIf
	EndIf

	If lRet
        If STJ->TJ_SITUACA <> 'L'
            MsgInfo(STR0240,STR0005) //"NÃO CONFORMIDADE" ### "Ordem de serviço não foi liberada."
        Else
            If !lNovo676 //Se for alguma opcao do MNTR675
                aMATSX1 := {{'01', Space(Len(stj->tj_plano))},{'02',Replicate('Z',Len(stj->tj_plano))},;
                            {'07', Space(Len(stj->tj_ccusto))},{'08',Replicate('Z',Len(stj->tj_ccusto))},;
                            {'09', Space(Len(stj->tj_centrab))},{'10',Replicate('Z',Len(stj->tj_centrab))},;
                            {'11', Space(Len(stj->tj_codarea))},{'12',Replicate('Z',Len(stj->tj_codarea))},;
                            {'13', STJ->TJ_ORDEM},{'14',STJ->TJ_ORDEM},{'15',STJ->TJ_DTMPINI},;
                            {'16', STJ->TJ_DTMPINI}}

            Else //Se for alguma opcao do MNTR676
                aMATSX1 := {{'01', STJ->TJ_PLANO},;
                            {'02', STJ->TJ_PLANO},;
                            {'03', STJ->TJ_CODBEM},;
                            {'04', STJ->TJ_CODBEM},;
                            {'05', STJ->TJ_ORDEM},;
                            {'06', STJ->TJ_ORDEM},;
                            {'07', STJ->TJ_DTMPINI},;
                            {'08', STJ->TJ_DTMPINI}}

            Endif

            If ExistBlock("MNTIMPOS")
                ExecBlock("MNTIMPOS",.F.,.F.,{stj->tj_plano,stj->tj_ordem,stj->tj_dtmpini})
            Else
                If nOpRe == 1
                    MNTBA676(lPARI,nRecOs,,aMATSX1)
                ElseIf nOpRe == 2
                    MNTSI676(lPARI,nRecOs,,aMATSX1)
                ElseIf nOpRe == 3
                    U_xMNTR675(lPARI,,,,1,aMATSX1,nRecOs)
                ElseIf nOpRe == 4
                    U_xMNTR675(lPARI,,,,2,aMATSX1,nRecOs)
                ElseIf nOpRe == 5
                    U_xMNTR675(lPARI,,,,3,aMATSX1,nRecOs)
                ElseIf nOpRe == 6
                    U_xMNTR675(lPARI,,,,4,aMATSX1,nRecOs)
                ElseIf nOpRe == 7
                    MNTR422(STJ->TJ_ORDEM)
                Else
                    If ExistBlock("IMP675OS")
						//Calculo para validar a opção do cliente ( 7 = Quantidade de opções de impressão padrão do sistema)
                        nPosPe := nOpRe - 7
                        If nPosPe > 0
                            If Len( aOptionsPE[ nPosPe ] ) < 3
                                &( aOptionsPE[nPosPe, 2] + '()' )
                            Else
								aOpcParam := aOptionsPE[nPosPe, 3]
                                &( aOptionsPE[nPosPe, 2] + '( aOpcParam )' )
                            EndIf
                        EndIf
                    EndIf
                Endif
            Endif
        EndIf

        DbSelectArea(cAliasimp)
        DbSetOrder(nIndeximp)
        Dbgoto(nIMP675RE)
    EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGVQLIMITP³ Autor ³Elisangela Costa       ³ Data ³02/12/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida a quantidade limite digitada do no retorno para in-  ³±±
±±³          ³sumo do tipo produto. Validando a quantidade no cadastro de ³±±
±±³          ³pecas de reposicao do bem (TPY).                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGVQLIMITP()

	Local lRet			:= .T.
	Local cBEMREP		:= STJ->TJ_CODBEM
	Local cCODIGOPR	:= M->TL_CODIGO
	Local nQUANTPRO	:= M->TL_QUANTID
	Local cVALPECRE := AllTrim(GETMv("MV_NGCOQPR"))
	Local nTipReg		:= aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
	Local nCodigo		:= aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_CODIGO" })
	Local nQtdade		:= aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_QUANTID"})

	If cVALPECRE == "S"
		If cPROGRAMA = "MNTA420"
			cBEMREP := M->TJ_CODBEM
		Endif

		If IsInCallStack( "NG400FIM" ) //Se executado pela rotina de Retorno.
			If aCols[n][nTipReg] == "P" //Se o Tipo de Registro for igual a 'Produto'.
				If !NGCHKLIMP( cBEMREP,aCols[n][nCodigo],aCols[n][nQtdade] )
					lRet := .F.
				EndIf
			EndIf
		Else
			If M->TL_TIPOREG = "P"
				If !NGCHKLIMP(cBEMREP,cCODIGOPR,nQUANTPRO)
					lRet := .F.
				EndIf
			EndIf
		EndIf

	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGPEUTIL ³ Autor ³ Inacio Luiz Kolling   ³ Data ³05/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pecas de reposicao do bem X Ultima utilizacao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cVCODB   - Codigo do bem                  - Obrigatorio    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ aAPTPY   - Array   [x,1] - Codigo do produto               ³±±
±±³          ³                    [x,2] - Data da ultima utilizacao       ³±±
±±³          ³                    [x,3] - Hora da ultima utilizacao       ³±±
±±³          ³                    [x,4] - Contador 1 na ultima utilizacao ³±±
±±³          ³                    [x,5] - Contador 2 na ultima utilizacao ³±±
±±³          ³                    [x,6] - Contador 1 na proxima manutencao³±±
±±³          ³                    [x,7] - Contador 2 na proxima manutencao³±±
±±³          ³                    [x,8] - Data da proxima manutencao c. 1 ³±±
±±³          ³                    [x,9] - Data da proxima manutencao c. 2 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function NGPEUTIL(cVCODB)

	Local aAPTPY    := {},aAPSTGSTF := {},cCONDSTLP := "",cCONDSTTP := ""
	Local cTRBXX := GetNextAlias()
	Local nICREMA1,nICREMA2,xp,dDTMENO1,dDTMENO2,cALIXX := Alias()
	Local oTmpTRBXX


	cCONDSTLP := 'stl->tl_tiporeg = "P" .And. Val(stl->tl_seqrela) > 0'
	cCONDSTTP := 'stt->tt_tiporeg = "P" .And. Val(stt->tt_seqrela) > 0'

	Store 0                To nICREMA1,nICREMA2,xp
	Store Ctod('  /  /  ') To dDTMENO1,dDTMENO2

	aDBFXX := {}
	AADD(aDBFXX,{"TPRODUTO" ,"C",Len(sb1->b1_cod)    , 0 })
	AADD(aDBFXX,{"TCODBEM"  ,"C",Len(st9->t9_codbem) , 0 })
	AADD(aDBFXX,{"TSERVICO" ,"C",Len(st4->t4_servico), 0 })
	AADD(aDBFXX,{"TSEQUENC" ,"C",03                  , 0 })
	AADD(aDBFXX,{"TINENMAN" ,"N",06                  , 0 })

	oTmpTRBXX := fCriaTRB(cTRBXX,aDBFXX,{{"TPRODUTO","TCODBEM","TSERVICO","TSEQUENC"}})

	If NGIFDBSEEK('TPY',cVCODB,1)
		While !Eof() .And. tpy->tpy_filial = xFILIAL("TPY") .And. ;
		tpy->tpy_codbem = cVCODB
			Aadd(aAPTPY,{tpy->tpy_codpro,Ctod("  /  /  "),'  :  ',0,0,0,0,;
			Ctod("  /  /  "),Ctod("  /  /  ")})
			NGDBSELSKIP("TPY")
		End
	Endif

	If Len(aAPTPY) > 0
		For xp := 1 To Len(aAPTPY)
			If NGIFDBSEEK('STG',"P"+aAPTPY[xp,1]+cVCODB,2)
				While !Eof() .And. stg->tg_filial = xFILIAL("STG") .And.;
				stg->tg_tiporeg = "P" .And. stg->tg_codigo = aAPTPY[xp,1];
				.And. stg->tg_codbem = cVCODB
					If NGIFDBSEEK('STF',stg->tg_codbem+stg->tg_servico+stg->tg_seqrela,1)
						DbSelectArea(cTRBXX)
						If !Dbseek(aAPTPY[xp,1]+stf->tf_codbem+stf->tf_servico+stf->tf_seqrela)
							(cTRBXX)->(DbAppend())
							(cTRBXX)->TPRODUTO  := aAPTPY[xp,1]
							(cTRBXX)->TCODBEM   := stf->tf_codbem
							(cTRBXX)->TSERVICO  := stf->tf_servico
							(cTRBXX)->TSEQUENC  := stf->tf_seqrela
							(cTRBXX)->TINENMAN  := stf->tf_inenman
						Endif
					Endif
					NGDBSELSKIP("STG")
				End
			Endif
		Next xp
		If NGIFDBSEEK('STJ', "B"+cVCODB,2)
			While !Eof() .And. stj->tj_filial = xFILIAL("STJ") .And. ;
			stj->tj_tipoos = "B" .And. stj->tj_codbem = cVCODB

				If stj->tj_situaca = "L"
					If NGIFDBSEEK('STL',stj->tj_ordem+stj->tj_plano,1)
						While !Eof() .And. stl->tl_filial = xFILIAL("STL") .And. ;
						stl->tl_ordem = stj->tj_ordem .And.;
						stl->tl_plano = stj->tj_plano

							If &(cCONDSTLP)

								For xp := 1 To Len(aAPTPY)
									If stl->tl_codigo = aAPTPY[xp,1]
										If stl->tl_dtinici > aAPTPY[xp,2]
											aAPTPY[xp,2] := stl->tl_dtinici
											aAPTPY[xp,3] := stl->tl_hoinici
										ElseIf stl->tl_dtinici = aAPTPY[xp,2] .And.;
										stl->tl_hoinici > aAPTPY[xp,3]
											aAPTPY[xp,3] := stl->tl_hoinici
										Endif
										Exit
									Endif
								Next xp

							Endif
							NGDBSELSKIP("STL")
						End
					Endif
				Endif
				NGDBSELSKIP("STJ")
			End
		Endif
		If NGIFDBSEEK('STS',"B"+cVCODB,2)
			While !Eof() .And. sts->ts_filial = xFILIAL("STS") .And. ;
			sts->ts_tipoos = "B" .And. sts->ts_codbem = cVCODB

				If sts->ts_situaca = "L"
					If NGIFDBSEEK('STT',sts->ts_ordem+sts->ts_plano,1)
						While !Eof() .And. stt->tt_filial = xFILIAL("STT") .And. ;
						stt->tt_ordem = sts->ts_ordem .And.;
						stt->tt_plano = sts->ts_plano

							If &(cCONDSTTP)
								For xp := 1 To Len(aAPTPY)
									If stt->tt_codigo = aAPTPY[xp,1]
										If stt->tt_dtinici > aAPTPY[xp,2]
											aAPTPY[xp,2] := stt->tt_dtinici
											aAPTPY[xp,3] := stt->tt_hoinici
										ElseIf stt->tt_dtinici = aAPTPY[xp,2] .And.;
										stt->tt_hoinici > aAPTPY[xp,3]
											aAPTPY[xp,3] := stt->tt_hoinici
										Endif
										Exit
									Endif
								Next xp

							Endif
							NGDBSELSKIP("STT")
						End
					Endif
				Endif
				NGDBSELSKIP("STS")
			End
		Endif

		xp := 0
		For xp := 1 To Len(aAPTPY)
			If !Empty(aAPTPY[xp,2])
				If NGIFDBSEEK('ST9',cVCODB,1)
					If st9->t9_temcont <> "N"
						// atualizar os contadores
						vCONTX1 := NGACUMEHIS(cVCODB,aAPTPY[xp,2],aAPTPY[xp,3],1,"P")
						vCONTX2 := NGACUMEHIS(cVCODB,aAPTPY[xp,2],aAPTPY[xp,3],2,"P")
						aAPTPY[xp,4] := vCONTX1[1]
						aAPTPY[xp,5] := vCONTX2[1]
					Endif
				Endif
			Endif

			// Calcula contador da proxima manutencao
			Store 0                To nICREMA1,nICREMA2
			Store Ctod('  /  /  ') To dDTMENO1,dDTMENO2

			DbSelectArea(cTRBXX)
			Dbseek(aAPTPY[xp,1])
			While !Eof() .And. (cTRBXX)->tproduto = aAPTPY[xp,1]
				If NGIFDBSEEK('STF',(cTRBXX)->tcodbem+(cTRBXX)->tservico+(cTRBXX)->tsequenc,1)
					If STF->TF_ATIVO <> "N" .And. STF->TF_PERIODO <> "E"
						If stf->tf_tipacom <> "S"

							dDTPROX1 := NGXPROXMAN((cTRBXX)->tcodbem)

							If Empty(dDTMENO1) .Or. dDTPROX1 < dDTMENO1
								dDTMENO1 := dDTPROX1
								nICREMA1 := (cTRBXX)->TINENMAN
							Endif
						Else
							If NGIFDBSEEK('TPE',cVCODB,1)
								dDTPROX2 := NGPROXMAN(tpe->tpe_dtulta,STF->TF_TIPACOM,;
								STF->TF_TEENMAN,STF->TF_UNENMAN,;
								STF->TF_CONMANU,STF->TF_INENMAN,;
								tpe->tpe_contac,tpe->tpe_vardia)

								If Empty(dDTMENO2) .Or. dDTPROX2 < dDTMENO2
									dDTMENO2 := dDTPROX2
									nICREMA2 := (cTRBXX)->TINENMAN
								Endif
							Endif
						Endif
					EndIf
				Endif
				NGDBSELSKIP(cTRBXX)
			End
			aAPTPY[xp,6] := If(aAPTPY[xp,4] > 0 .And. nICREMA1 > 0,;
			aAPTPY[xp,4]+nICREMA1,aAPTPY[xp,6])
			aAPTPY[xp,7] := If(aAPTPY[xp,5] > 0 .And. nICREMA2 > 0,;
			aAPTPY[xp,5]+nICREMA2,aAPTPY[xp,7])
			aAPTPY[xp,8] := dDTMENO1
			aAPTPY[xp,9] := dDTMENO2
		Next xp
	Endif

	oTmpTRBXX:Delete()

	DbSelectArea(cALIXX)
Return aAPTPY

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGINSUF12  ³ Autor ³In cio Luiz Kolling   ³ Data ³10/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³F12 - Reporte de insumo tipo produto (pecas reposicao/bem)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cVVAR   - Variavel de leitura                  - Obrigatorio³±±
±±³          ³cVBEM   - Codigo do bem                        - Obrigatorio³±±
±±³          ³cVTPR   - Tipo de insumo                       - Obrigatorio³±±
±±³          ³lGETDAD - Utilisa o getdados                   - Nao Obrig. ³±±
±±³          ³nFOLDER - Numero do folder                     - Nao Obrig. ³±±
±±³          ³cNOMPRO - Campo virtual da descricao produto   - Nao Obrig. ³±±
±±³          ³oObjTmp - Objeto da classe GetDados            - Nao Obrig. ³±±
±±³          ³          (Utilizar somente se o objeto GetDados em uso for ³±±
±±³          ³          declarado com nome diferente de 'oGet')           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGINSUF12(cVVAR,cVBEM,cVTPR,lGETDAD,nVFDER,cNOMPRO,oObjTmp,cQUANT,cUNIMED)
	Local lINSF12 := .F., cINTTPR := If(cVTPR = NIL,"P",cVTPR)
	Local cALISU12 := Alias(), nREGSU12 := IndexOrd(),lREF12 := .T.
	Local lUTIGDAD := If(lGETDAD = Nil,.f.,.t.),nPOSCENO := 0, nPOSQNT := 0, nPOSUNI := 0

	If lUTIGDAD
		If ValType(oObjTmp) == "O"
			nCOLGE := oObjTmp:obrowse:ncolpos
		ElseIf nVFDER = NIL
			nCOLGE := oget:obrowse:ncolpos
		Else
			If nVFDER = 1
				nCOLGE := oget01:obrowse:ncolpos
			ElseIf nVFDER = 2
				nCOLGE := oget02:obrowse:ncolpos
			ElseIf nVFDER = 3
				nCOLGE := oget03:obrowse:ncolpos
			ElseIf nVFDER = 4
				nCOLGE := oget04:obrowse:ncolpos
			Endif
		Endif
		nTEMMM   := At("->",cVVAR)
		cCAMAH   := If(nTEMMM > 0,Substr(cVVAR,nTEMMM+2,Len(cVVAR)),cVVAR)
		nPOSCEDU := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == cCAMAH})
		nPOSCENO := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == cNOMPRO})
		If cQUANT <> Nil
			nPOSQNT := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == cQUANT})
		Endif
		If	cUNIMED <> Nil
			nPOSUNI := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == cUNIMED})
		Endif

		If nPOSCEDU > 0
			If nPOSCEDU <> nCOLGE
				Return
			Endif
		Else
			Return
		Endif
	Endif

	cBEMSUF12 := cVBEM
	If !NGIFDICIONA("SXB","TPY",1)
		MsgInfo(STR0122+" TPY."+chr(13)+STR0124,STR0123)
		lREF12 := .F.
	Else
		If cINTTPR = "P"
			If !Empty(cVBEM)
				If lUTIGDAD
					If nPOSCEDU > 0
						lINSF12 := .T.
					Endif
				Else
					If Readvar() = cVVAR
						lINSF12 := .T.
					Endif
				Endif
			Endif
		Endif

		If lINSF12
			If Type("aTROCAF3") = 'A'
				If Len(aTROCAF3) > 0
					aTROCAF3[1,2] := "TPY"
				Endif
			Endif
			lCONDP := CONPAD1(NIL,NIL,NIL,"TPY",NIL,NIL,.F.)
			If lCONDP
				&cVVAR. := TPY->TPY_CODPRO
				If lUTIGDAD
					Acols[n,nPOSCEDU] := TPY->TPY_CODPRO
					If nPOSCENO > 0
						Acols[n,nPOSCENO] := NGSEEK("SB1",TPY->TPY_CODPRO,1,"B1_DESC")
					Endif
					If nPOSQNT > 0
						Acols[n,nPOSQNT] := TPY->TPY_QUANTI
					Endif
					If nPOSUNI > 0
						Acols[n,nPOSUNI] := NGSEEK("SB1",TPY->TPY_CODPRO,1,"B1_UM")
					Endif
				Endif
				lREFRESH := .T.
			Endif
		Endif
	Endif
	If !Empty(cALISU12)
		DbSelectArea(cALISU12)
		If nREGSU12 > 0
			DbSetOrder(nREGSU12)
		Endif
	Endif
	If Type("aTROCAF3") = 'A'
		If Len(aTROCAF3) > 0 .And. cVTPR = "P"
			aTROCAF3[1,2] := "SB1"
		Endif
	Endif
Return lREF12

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NGGERASC1
Gera solicitacao de compras pelo modelo de aglutinação
@type function

@author Inacio Luiz Kolling
@since	23/06/2006

@sample NGGERASC1(cCodPr, aQtd, cOp, dData, cLocal, cCcust, nInc)

@param cCodPr    , Caracter, Codigo do produto
@param aQtd      , Array   , Vetor com as quantidade
@param cOp       , Caracter, Numero da solicitacao de producao
@param dData     , Date    , Data da necessidade
@param cLocal    , Caracter, Codigo do almoxarifado
@param cCcust    , Caracter, Codigo do centro de custo
@param nIncMa    , Numérico, Incremento da matriz
@param [vCaBLO]  , Array   , Vetor c.as colunas da aBLO
@param [cForne]  , Caracter, Codigo do fornecedor
@param [cUnida]  , Caracter, Codigo da unidade
@param [lArsc1]  , Lógico  , Controle de acesso a array
@param [nMatBl]  , Numérico, Controle de acesso a matriz
@param [lAlteraS], Lógico  , Indica se TEM ALGUM  ITEM ALTERADO
@param [cFornec] , Caracter, Fornecedor quando o prod é terceiro
@param [cLojaFor], Caracter, Loja quando o produto é terceiro
@param [cTarefa] , Caracter, Tarefa do insumo
@return Array    , [1] - Define se o processo foi realizado com sucesso.
				   [2] - Numero da S.C. gerada.
/*/
//----------------------------------------------------------------------------------------------------------
Function NGGERASC1( cCodPr, aQtd, cOp, dData, cLocal, cCcust, nInc, vCaBLO, cForne, nQtd, cUnida, lArsc1, nMatBl, cObs,;
	lAlteraS, cForneTer, cLojaFor, cTarefa, cNum, cItem )

	Local nx          := 0
	Local nz          := 0
	Local nParCom     := SuperGetMV("MV_NGMNTSC")
	Local lIntegRM    := Trim( SuperGetMV( 'MV_NGINTER', .F., 'N' ) ) == 'M'
	Local lAglutSC    := SuperGetMV( 'MV_NGMNTSC', .F., 1 ) != 1
	Local nIndex      := 1
	Local nQtdCot     := 0
	Local lTemSC      := .F.
	Local lAltInc     := .F.
	Local lRet 	      := .T.
	Local lGeraSC     := .T.	
	Local lTemIAl     := IIf(lAlteraS = Nil,.F.,lAlteraS)
	Local aAreaAnt    := GetArea()
	Local aCampo      := {} //Variável utilizada no Ponto de Entrada "NGSEPARASC".
	Local aSC         := {}
	Local aRetSC      := {.T.,''}
	Local cNumSC      := ''
	Local cItemCta    := ''
	Local cDescSB1    := ''

	Private aDataOPC1 := {}
	Private aDataOPC7 := {}
	Private aOpc1     := {}
	Private aOPC7     := {}
	Private aSav650   := {}
	Private AOPC7LOCAL := {}
	Private nMatac    := IIf(nMatBl = Nil,4,nMatBl)
	Private nQtdO     := IIf(nQtd = Nil,aQtd[1],nQtd)
	Private lProj711  := .F.

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Default cForneTer := ""
	Default cLojaFor  := ""
	Default cTarefa   := ""

	// P.E. que define condição  para inclusão de solicitação de compras.
	lGeraSC := IIf( ExistBlock( 'NGNOGERASC' ), !ExecBlock( 'NGNOGERASC', .F., .F., { cOp, cCodPr, cLocal } ), lGeraSC )

	If lGeraSC

		If FindFunction( 'MntExecSC1' ) .And. ( FwIsInCallStack( 'NG410INC' ) .Or.;
			FwIsInCallStack( 'NG420INC' ) .Or. FwIsInCallStack( 'A340ASIM' ) )
			
			If Empty( cNum )

				nOption := 3

			Else

				nOption := 4

			EndIf

			/*---------------------------------------------+
			| Gera novo número para S.C. conforme sua O.P. |
			+---------------------------------------------*/
			aSC := MNTNumSC( cNum, cItem, cOP, Nil )

			/*----------------------------------------------------------+
			| Manipula variáveis que seram enviadas ao ExecAuto MATA110 |
			+----------------------------------------------------------*/
			cOP      := PadR( cOP, Len( SD4->D4_OP ) )
			cCodBem  := NGSEEK( 'STJ', SubStr( cOP, 1, TAMSX3( 'TJ_ORDEM' )[1] ), 1, 'TJ_CODBEM' )
			cItemCta := NGSEEK( 'ST9', cCodBem, 1, 'T9_ITEMCTA' )
			cCcust   := IIf( Empty( cCcust ), NGSEEK( 'STJ', SubStr( cOP, 1, TAMSX3( 'TJ_ORDEM' )[1] ), 1, 'TJ_CCUSTO' ), cCcust )
			cObs     := IIf( Empty( cObs )  , STR0139 + SubStr( cOP, 1, TAMSX3( 'TJ_ORDEM' )[1] ) + STR0140 + cCodBem, cObs )
			cDescSB1 := Posicione( 'SB1', 1, FWxFilial( 'SB1' ) + cCodPr, 'B1_DESC' )

			/*----------------------------------------------------------------------------------------+
			| Quando integrado ao RM, caso a database seja superior a data da O.S., assume a database |
			+----------------------------------------------------------------------------------------*/
			If lIntegRM .And. dDataBase > dData
				dData := dDataBase
			EndIf

			/*-----------------------------------------------------------------+
			| P.E. que permite alterar Centro de Custo da SC antes da gravação |
			+-----------------------------------------------------------------*/
			If ExistBlock( 'NGGERSC2' )
				cCcust := ExecBlock( 'NGGERSC2', .F., .F., { cCodPr, cLocal, cOP, cForne } )
			EndIf

			/*-------------------------------------------------------------+
			| Realiza a inclusão de uma S.C. por meio do ExecAuto MATA110. |
			+-------------------------------------------------------------*/
			aRetSC := MntExecSC1( aSC[1], aSC[2], { nQtd, cCodPr, cLocal, cOP, dData, cCcust, cItemCta,;
				cForneTer, cLojaFor, cObs, cDescSB1 }, nOption )

			If aRetSC[1]
				
				cNumSC := SC1->C1_NUM

				/*---------------------------------------------------+
				| Integração RM quando a S.C. não estiver aglutinada |
				+---------------------------------------------------*/
				If lIntegRM .And. !NGMUReques( SC1->( RecNo() ), 'SC1', .F., nOption )

					Return { .F., '' }

				EndIf

			Else

				Return { .F., '' }	

			EndIf

			aRetSC := { .T., cNumSC }

		Else

			/*------------------------------------------------------------------------------------------------------+
			| Processo via ExecAuto MATA110, sendo que, até o momento somente é comportado a operação de alteração, |
			| quando acionado pela rotina MNTA420.                                                                  |
			+------------------------------------------------------------------------------------------------------*/
			If FwIsInCallStack( 'MNTA420' ) .And. !Empty( cNum )

				/*--------------------------------------------------------------+
				| Realiza a alteração de uma S.C. por meio do ExecAuto MATA110. |
				+--------------------------------------------------------------*/
				aRetSC := MNTXCOM( cNum, cItem, { nQtd, cLocal, cCodPr } )

				If aRetSC[1]

					dbSelectArea( 'SC1' )
					dbSetOrder( 1 ) // C1_FILIAL + C1_NUM + C1_ITEM + C1_ITEMGRD
					msSeek( xFilial( 'SC1' ) + cNum + cItem )

					If lIntegRM .And. !NGMUReques( SC1->( RecNo() ), 'SC1', .F., 4 )
						Return { .F., '' }
					EndIf

				Else

					Return aRetSC

				EndIf

			Else
				
				/*----------------------------------------------------------+
				| Manipula variáveis que seram enviadas ao ExecAuto MATA110 |
				+----------------------------------------------------------*/
				cOP      := PadR( cOP, Len( SD4->D4_OP ) )
				cCodBem  := NGSEEK( 'STJ', SubStr( cOP, 1, TAMSX3( 'TJ_ORDEM' )[1] ), 1, 'TJ_CODBEM' )
				cItemCta := NGSEEK( 'ST9', cCodBem, 1, 'T9_ITEMCTA' )
				cCcust   := IIf( Empty( cCcust ), NGSEEK( 'STJ', SubStr( cOP, 1, TAMSX3( 'TJ_ORDEM' )[1] ), 1, 'TJ_CCUSTO' ), cCcust )
				cObs     := IIf( Empty( cObs )  , STR0139 + SubStr( cOP, 1, TAMSX3( 'TJ_ORDEM' )[1] ) + STR0140 + cCodBem, cObs )

				/*----------------------------------------------------------------------------------------+
				| Quando integrado ao RM, caso a database seja superior a data da O.S., assume a database |
				+----------------------------------------------------------------------------------------*/
				If lIntegRM .And. dDataBase > dData
					dData := dDataBase
				EndIf

				/*-----------------------------------------------------------------+
				| P.E. que permite alterar Centro de Custo da SC antes da gravação |
				+-----------------------------------------------------------------*/
				If ExistBlock( 'NGGERSC2' )
					cCcust := ExecBlock( 'NGGERSC2', .F., .F., { cCodPr, cLocal, cOP, cForne } )
				EndIf

				/*-------------------------------------------------------------------------
				| Carregado array aSav650 com conteudo do grupo de perguntas MTA650 para  |
				| utilização na rotina A650GeraC1(). Este é feito pelo MNT para o correto |
				| preenchimento do PAR06 com o conteudo do parametro MV_NGMNTSC.          |
				-------------------------------------------------------------------------*/
				Pergunte("MTA650", .F.)
				MV_PAR06 := nParCom
				nIndex   := 1
				Do While !(ValType(&("MV_PAR" + StrZero(nIndex, 2))) == "C" .And. Len(&("MV_PAR" + StrZero(nIndex, 2))) == 0)

					aAdd(aSav650, &("MV_PAR" + StrZero(nIndex, 2)))
					nIndex++

				EndDo

				If lTemIAl   // Itens alterados e/ou + novos

					//checa se SC ja foi gerada para o item,caso positivo não gera novamente
					cAliasQry := GetNextAlias()
					cQuery := " SELECT * "
					cQuery += " FROM "+RetSqlName("SC1")+" SC1"
					cQuery += " WHERE SC1.C1_FILIAL='"+xFilial("SC1")+"' AND SC1.C1_PRODUTO='"+cCodPr+"' "
					cQuery += " AND SC1.C1_LOCAL='"+cLocal+"' "
					cQuery += " AND SC1.C1_OP = '"+cOP+"' AND SC1.D_E_L_E_T_<>'*' "
					cQuery := ChangeQuery(cQuery)
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

					While !Eof()
						If !Empty((cAliasQry)->C1_PEDIDO)
							nQtdCot += (cAliasQry)->C1_QUJE
						ElseIf !Empty((cAliasQry)->C1_COTACAO)
							nQtdCot += (cAliasQry)->C1_QUANT
						EndIf
						NGDBSELSKIP(cAliasQry)
					End While

					(cALIASQRY)->(dbCloseArea())

					If nQtdCot > 0
						lTemSC := .T.
					EndIf

					RestArea( aAreaAnt )

					If nQtd > nQtdCot
						lTemSC := .f.
						nQtd   := nQtdO - nQtdCot
						aQtd   := CalcLote(cCodPr,nQtd,"C")
					Endif
				EndIf

				If lTemSC
					RestArea( aAreaAnt )
					Return
				EndIf

				RestArea( aAreaAnt )

				For nX := 1 To Len(aQtd)

					If AllTrim(GetNewPar("MV_NGINTER","N")) == "M" //Mensagem Unica

						cUnida := If(cUnida<>Nil, cUnida, NGSEEK("SB1",cCodPr,1,"B1_UM"))

						If dDataBase > dData
							dData := dDataBase
						EndIf
						//trecho baseado na rotina A650GeraC1

						If nParCom == 1

							cNumSolic := GetNumSc1(.F.)
							RollBackSX8()
							If Empty(cNumSolic)
								cNumSolic := ProximoNum("SC1")
							EndIf
							//So vai gerar se for igual a 1

							M->C1_FILIAL := xFilial("SC1")
							M->C1_NUM := cNumSolic //NextNumero("SC1",1,"C1_NUM",.T.)
							M->C1_SOLICIT := SubStr(cusuario,7,15)
							M->C1_OP :=  cOp
							M->C1_EMISSAO := dData
							M->C1_OBS := If(cObs<>Nil,cObs,'')
							M->C1_ITEM := '0001'
							M->C1_ITEMGRD := ''
							M->C1_PRODUTO := cCodPr
							M->C1_QUANT := nQtd
							M->C1_UM := cUnida
							M->C1_LOCAL := If(cLocal<>Nil,cLocal,'')
							M->C1_DATPRF := dData
							M->C1_CC := cCcust
							M->C1_PRECO := 0
							M->C1_TOTAL := 0
							M->C1_CONDPAG := ''

						EndIf

					EndIf

					If lRet

						NGIFDBSEEK("SB2",cCodPr+cLocal,1)

						/* Função da rotina MATA650 que realiza a inclusão de um S.C. apenas quando não aglutinado, para os casos
						em que existe algum tipo de aglutinação, será preenchido as informações dos produtos no Array aOpc1 ou aDataOPC1*/
						A650GeraC1(cCodPr,aQtd[nX],cOp,dData,Nil,Nil,aQtd[nX],cLocal)

						If nParCom == 1 //1 - Normal
							If(vCaBLO = Nil,If(cForne = Nil,NGATUSC1(cCcust,nInc,,,,,,,cForneTer,cLojaFor),;
									NGATUSC1(cCcust,nInc,      ,,,,,,cForneTer,)),If(cForne = Nil,NGATUSC1(cCcust,nInc,vCaBLO,,,,,cObs,cForneTer,cLojaFor),;
							NGATUSC1(cCcust,nInc,vCaBLO,cForne,nQtd,cUnida,lArsc1,cObs,cForneTer,cLojaFor)))

							If lIntegRM .And. !lAglutSC
								
								If !NGMUReques( SC1->( RecNo() ), 'SC1', .F., 3 )
									Return { .F., '' }
								EndIf	

							EndIf

							//Adiciona no array os campos, para realizar a separação de compras de acordo com o tipo de produto.
							aAdd( aCampo, { SC1->C1_NUM, SC1->C1_ITEM, SC1->C1_PRODUTO, SC1->C1_QUANT } )

							cNumSC := SC1->C1_NUM

							NGAtuErp("SC1","INSERT")

						EndIf

					EndIf

				Next

				//-------------------------------
				// Gera SC's aglutinadas por OP.
				//-------------------------------

				//altera "Inclui"	para gravacao de nova SC
				If !Inclui
					Inclui := .t.
					lAltInc := .t.
				EndIf

				If lRet

					If nParCom == 2 // 2 - Aglutina por OP

						For nz:=1 to Len(aOPC7)
							A650GravC7(aOPC7[nz,1],aOPC7[nz,2],aOPC7[nz,3],aOPC7[nz,4],aOPC7[nz,5],aOPC7[nz,6],aOPC7[nz,8],aOPC7[nz,9])
						Next nz

						For nz:=1 to Len(aOpc1)

							If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"  //Mensagem Unica

								cUnida := If(cUnida<>Nil, cUnida, NGSEEK("SB1",aOpc1[nz,1],1,"B1_UM"))

								//Ajusta as data quando integrado ao RM
								If dDataBase > dData
									dData := dDataBase
								EndIf

								If dDataBase > aOpc1[nz,4]
									aOpc1[nz,4] := dDataBase
								EndIf

							EndIf

							/* Função da rotina MATA650 que realiza a inclusão de uma S.C. utilizando os registros já aglutinados no
							array aOpc1 que foram gerados na função A650GeraC1. */
							A650GravC1( aOpc1[nz,1], aOpc1[nz,2], cOP, aOpc1[nz,4], aOpc1[nz,5], aOpc1[nz,6], aOpc1[nz,7],;
										aOpc1[nz,8], aOpc1[nz,9], aOpc1[nz,10], aOpc1[nz,11], aOpc1[nz,12] )

							/*	
								Deixa no ultimo registro incluso na SC1, visto que quando habilitado o controle de alçada é desposicionado
								o registro recém incluso na função A650GravC1, deixando o ponteiro no primeiro item da S.C.
							*/
							dbSelectArea( 'SC1' )
							dbGoTo( LastRec() )

							If (vCaBLO = Nil,If(cForne = Nil,NGATUSC1(cCcust,nInc,,,,,,,cForneTer,cLojaFor),;
								NGATUSC1(cCcust,nInc,      ,,,,,,cForneTer,)),;
									If(cForne = Nil,NGATUSC1(cCcust,nInc,vCaBLO,,,,,cObs,cForneTer,cLojaFor),;
								NGATUSC1(cCcust,nInc,vCaBLO,cForne,nQtd,cUnida,lArsc1,cObs,cForneTer,cLojaFor)))
							NGAtuErp("SC1","INSERT")

							If lIntegRM .And. !NGMUReques( SC1->( RecNo() ), 'SC1', .F., 3 )
								Return { .F., '' }
							EndIf				

							//Adiciona no array os campos, para realizar a separação de compras de acordo com o tipo de produto.
							Aadd(aCampo,{SC1->C1_NUM,SC1->C1_ITEM,SC1->C1_PRODUTO,SC1->C1_QUANT})

						Next nz

						cNumSC := SC1->C1_NUM

					ElseIf nParCom == 3 //Aglutina por Data de Necessidade

						For nz:=1 to Len(aDataOPC7)
							A650GravC7(aDataOPC7[nz,1],aDataOPC7[nz,2],aDataOPC7[nz,3],aDataOPC7[nz,4],aDataOPC7[nz,5],aDataOPC7[nz,6],;
							aDataOPC7[nz,8],aDataOPC7[nz,9])
						Next nz

						For nz:=1 to Len(aDataOPC1)

							If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"  //Mensagem Unica

								cUnida := If(cUnida<>Nil, cUnida, NGSEEK("SB1",aDataOPC1[nz,1],1,"B1_UM"))

								//Ajusta as data quando integrado ao RM
								If dDataBase > dData
									dData := dDataBase
								EndIf

								If dDataBase > aDataOPC1[nz,4]
									aDataOPC1[nz,4] := dDataBase
								EndIf

							EndIf

							/* Função da rotina MATA650 que realiza a inclusão de uma S.C. utilizando os registros já aglutinados no
							array aDataOPC1 que foram gerados na função A650GeraC1. */
							A650GravC1( aDataOPC1[nz,1], aDataOPC1[nz,2], cOP, aDataOPC1[nz,4], aDataOPC1[nz,5], aDataOPC1[nz,6],;
										aDataOPC1[nz,7], aDataOPC1[nz,8], aDataOPC1[nz,9], aDataOPC1[nz,10], aDataOPC1[nz,11],;
										aDataOPC1[nz,12] )

							If (vCaBLO = Nil,If(cForne = Nil,NGATUSC1(cCcust,nInc,,,,,,,cForneTer,cLojaFor),;
								NGATUSC1(cCcust,nInc,      ,,,,,,cForneTer,)),;
									If(cForne = Nil,NGATUSC1(cCcust,nInc,vCaBLO,,,,,cObs,cForneTer,cLojaFor),;
								NGATUSC1(cCcust,nInc,vCaBLO,cForne,nQtd,cUnida,lArsc1,cObs,cForneTer,cLojaFor)))
							NGAtuErp("SC1","INSERT")

							If lIntegRM .And. !NGMUReques( SC1->( RecNo() ), 'SC1', .F., 3 )
								Return { .F., '' }
							EndIf

							//Adiciona no array os campos, para realizar a separação de compras de acordo com o tipo de produto.
							Aadd(aCampo,{SC1->C1_NUM,SC1->C1_ITEM,SC1->C1_PRODUTO,SC1->C1_QUANT})

						Next nz

						cNumSC := SC1->C1_NUM

					EndIf

				EndIf

				//--------------------------------------
				// Envia e-mail na inclusao de SC's
				//--------------------------------------
				If Inclui
					MEnviaMail( "035",{ SC1->C1_NUM })
				EndIf

			EndIf

			aRetSC := { .T., cNumSC }

		EndIf

		/*-----------------------------------------+
		| Gravação dos campos TL_NUMSC e TL_ITEMSC |
		+-----------------------------------------*/
		dbSelectArea( 'STL' )
		dbSetOrder( 4 ) // TL_FILIAL + TL_ORDEM + TL_PLANO + TL_TIPOREG + TL_CODIGO

		If msSeek( xFilial( 'STL' ) + SubStr( cOP, 1, 6 ) + STJ->TJ_PLANO + 'P' + cCodPr )
			
			/*-----------------------+
			| Insumo do tipo Produto |
			+-----------------------*/
			While STL->( !EoF() ) .And. STL->TL_ORDEM == SubStr( cOP, 1, 6 ) .And. AllTrim( STL->TL_CODIGO ) == AllTrim( cCodPr )
				
				If Empty( STL->TL_NUMSC ) .And. Empty( STL->TL_ITEMSC ) .And. AllTrim( STL->TL_LOCAL ) == AllTrim( cLocal ) .And.;
					STL->TL_SEQRELA == PadR( '0', TamSX3( 'TL_SEQRELA' )[1] )

					RecLock( 'STL', .F. )
						STL->TL_NUMSC  := SC1->C1_NUM
						STL->TL_ITEMSC := SC1->C1_ITEM
					MsUnlock()

				EndIf

				STL->( dbSkip() )

			End

		Else
			
			dbSelectArea( 'STL' )
			dbSetOrder( 1 ) // TL_FILIAL + TL_ORDEM + TL_PLANO + TL_TAREFA + TL_TIPOREG + TL_CODIGO

			If msSeek( xFilial( 'STL' ) + SubStr( cOP, 1, 6 ) + STJ->TJ_PLANO + PadR( cTarefa, Len( STL->TL_TAREFA ) ) + 'T' ) .And. !Empty( cForneTer )
				
				/*------------------------+
				| Insumo do tipo Terceiro |
				+------------------------*/
				While STL->( !EoF() ) .And. STL->TL_ORDEM == SubStr( cOP, 1, 6 ) .And. AllTrim( STL->TL_TAREFA ) == AllTrim( cTarefa )
					
					//Condição para atuação na alteração de um insumo do tipo terceiro de mesma quantidade/fornecedor/tarefa
					If Empty( STL->TL_NUMSC ) .And. Empty( STL->TL_ITEMSC ) .And. AllTrim( cForne ) == Alltrim( STL->TL_CODIGO ) .And.;
						STL->TL_SEQRELA == PadR( '0', TamSX3( 'TL_SEQRELA' )[1] )

						RecLock( 'STL', .F. )
							STL->TL_NUMSC  := SC1->C1_NUM
							STL->TL_ITEMSC := SC1->C1_ITEM
						MsUnLock()

					EndIf

					STL->( dbSkip() )

				End

			EndIf

		EndIf

		/*PE que possibilita realizar a separação de solicitação de compras de acordo com o tipo
		de produto sem a utilização da solicitação de armazém.*/
		If ExistBlock("NGSEPARASC")
			ExecBlock("NGSEPARASC",.F.,.F.,{aCampo}) //após a gravação
		EndIf

		If ExistBlock("NGGERASC11") //Ponto de entrada que possibilita alterar informações da solicitação de compras
			ExecBlock("NGGERASC11",.F.,.F.,{ STJ->TJ_ORDEM, STJ->TJ_PLANO,If(Empty(cForneTer) ,"P","T" ) , If(Empty(cForneTer) ,cCodPr,cForne ) } ) //após a gravação
		Endif

		If lAltInc      //devolve condicao do Inclui
			Inclui := .F.
		EndIf

	EndIf
	
	RestArea( aAreaAnt )

Return aRetSC

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGGERASC1 ³ Autor ³Inacio Luiz Kolling    ³ Data ³23/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera solicitacao de compras pelo modelo de aglutinacao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCustv    - Codigo do centro de custo          - Obrigatorio³±±
±±³          ³nIncMv    - Numero do incremento da matriz     - Obrigatorio³±±
±±³          ³vCaBLO    - Vetor c.as colunas da aBLO         - Nao Obrigat³±±
±±³          ³cCodf     - Codigo do fornecedor               - Nao Obrigat³±±
±±³          ³nQdt      - Quantidade fornecedor              - Nao Obrigat³±±
±±³          ³cUnd      - Codigo do unidade                  - Nao Obrigat³±±
±±³          ³lAr       - Controle de acesso a array         - Nao Obrigat³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGGERASC1                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGATUSC1(cCustv,nIncMv,vCaBLO,cCodf,nQdt,cUnd,lAr,cObs,cForneTer,cLojaFor)

	Local aAreaA   := GetArea()
	Local lAPROVSC := SuperGetMv( 'MV_APROVSC', .F., .F. )
	Local lAprScEc := SuperGetMV( 'MV_APRSCEC', .F., .F. )
	Local aHeadSC1 := {}
	Local aHeadSCX := {}
	Local aColSC1  := {}
	Local aColsSCX := {}

	Default cForneTer := "" , cLojaFor := ""

	If cCustv <> Nil
		DbSelectArea("SC1")
		cOrdSer := SubStr(SC1->C1_OP,1,TAMSX3("TJ_ORDEM")[1])
		cCodBem := NGSEEK("STJ",cOrdSer,1,"TJ_CODBEM")
		cCodBem := If(Empty(cCodBem),If(Type("M->TJ_CODBEM")=="C",M->TJ_CODBEM,""),cCodBem)
		RecLock("SC1",.F.)
		If NGCADICBASE("T9_ITEMCTA","A","ST9",.F.)
			SC1->C1_ITEMCTA := NGSEEK("ST9",cCodBem,1,"T9_ITEMCTA")
		EndIf
		cMsgObs		:= STR0125+cOrdSer+STR0126+cCodBem  //"MNT OS"##" BEM "
		SC1->C1_OBS := If(cObs = Nil,cMsgObs,If(Empty(cObs),cMsgObs,cObs))
		SC1->C1_CC  := cCustv
		SC1->(MsUnlock())
	Endif

	If cCodf <> Nil
		Dbselectarea("SC1")
		RecLock("SC1",.F.)
		SC1->C1_FORNECE := cForneTer
		SC1->C1_LOJA    := cLojaFor
		SC1->C1_QUANT   := nQdt
		SC1->C1_UM      := cUnd
		cOrdSer         := SubStr(SC1->C1_OP,1,TAMSX3("TJ_ORDEM")[1])
		cCodBem         := NGSEEK("STJ",cOrdSer,1,"TJ_CODBEM")
		cCodBem         := If(Empty(cCodBem),If(Type("M->TJ_CODBEM")=="C",M->TJ_CODBEM,""),cCodBem)
		cMsgObs		  := STR0125+cOrdSer+STR0126+cCodBem  //"MNT OS"##" BEM "
		SC1->C1_OBS     := If(cObs = Nil,cMsgObs,If(Empty(cObs),cMsgObs,cObs))

		//Ponto de entrada que altera o Centro de Custo da SC1
		If Empty(cCustV) .Or. !ExistBlock('NGGERSC2')
			cCustB          := NGSEEK("STJ",cOrdSer,1,"TJ_CCUSTO")
			cCustB          := If(Empty(cCustB),If(Type("M->TJ_CCUSTO")=="C",M->TJ_CCUSTO,""),cCustB)
			SC1->C1_CC      := cCustB
		EndIf

		If NGCADICBASE("T9_ITEMCTA","A","ST9",.F.)
			SC1->C1_ITEMCTA := NGSEEK("ST9",cCodBem,1,"T9_ITEMCTA")
		EndIf

		SC1->(MsUnlock())

	Endif

	//-----------------------------------------------------------------------------------------
	// Bloqueio automático das Solicitações de Compras com regras do Cadastro de Solicitantes
	//-----------------------------------------------------------------------------------------
	If lAPROVSC

		Dbselectarea("SC1")
		RecLock("SC1",.F.)
		SC1->C1_APROV := IIf(MaVldSolic(SC1->C1_PRODUTO,/*aGrupo*/,/*cUser*/,.F.),"L","B")
		SC1->(MsUnlock())

	EndIf


	//-----------------------------------------------------
	// Controle de Alçada
	//-----------------------------------------------------
	If lAprScEc
		
		// Gera aHead e aCols das tabelas SC1 e SCX.
		COMGerC1Cx(SC1->C1_NUM,@aHeadSC1,@aColSC1,@aHeadSCX,@aColsSCX)
		
		//Funcao utilizada para gerar a alcada de aprovacao por itens aglutinados por Entidade Ctb. e valor.
		MaEntCtb("SC1","SCX",SC1->C1_NUM,"SC",aHeadSC1,aColSC1,aHeadSCX,aColsSCX,2,dDataBase)

	EndIf

	If Type("lAblo") <> "U"
		// Nao altera aBLO
	Else
		If Type("aBLO") <> "U"
			If Type("aBLO") = "A"
				If vCaBLO <> Nil
					If Len(vCaBLO) > 0
						If lAr = Nil
							aBLO[nMatac][nIncMv][vCaBLO[1]] := SC1->C1_NUM		//Número da solicitação de compras
							aBLO[nMatac][nIncMv][vCaBLO[2]] := SC1->C1_ITEM		//Número do item da solicitação de compra
							aBLO[nMatac][nIncMv][vCaBLO[3]] := SC1->C1_QUANT		//Quantidade da solicitação de compra TL_QTDSC1
						Else
							If lAr
								aBLO[nMatac][nIncMv][vCaBLO[1]] := SC1->C1_NUM	//Número da solicitação de compra
								aBLO[nMatac][nIncMv][vCaBLO[2]] := SC1->C1_ITEM	//Número do item da solicitação de compra
								aBLO[nMatac][nIncMv][vCaBLO[3]] := SC1->C1_QUANT	//Quantidade da solicitação de compra TL_QTDSC1
							Else
								If Len(aBLO[nMatac][nIncMv]) > 10
									aBLO[nMatac][nIncMv][11] := SC1->C1_NUM		//Número da solicitação de compra
								Endif
								If Len(aBLO[nMatac][nIncMv]) > 11
									aBLO[nMatac][nIncMv][12] := SC1->C1_ITEM		//Número do item da solicitação de compra
								Endif
								If Len(aBLO[nMatac][nIncMv]) > 16
									aBLO[nMatac][nIncMv][17] := SC1->C1_QUANT		//Quantidade da solicitação de compra TL_QTDSC1
								Endif
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif

	RestArea(aAreaA)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGRELOCORRC³ Autor ³Elisangela Costa      ³ Data ³27/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³F11 ou F10 - Relaciona causas e soulucoes possiveis para    ³±±
±±³          ³             cada  problema ou causa                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cVVAR   - Variavel de leitura                   - Obrigat.  ³±±
±±³          ³cVOCOR  - Codigo da ocorrencia                  - Obrigat.  ³±±
±±³          ³cVTIPO  - Tipo da ocorrencia                    - Obrigat.  ³±±
±±³          ³lGETDAD - Utilisa o getdados                    - Nao Obrig.³±±
±±³          ³nVFDER  - Numero do folder                      - Nao Obrig.³±±
±±³          ³cNOMOCO - Campo virtual da descricao ocorrencia - Nao Obrig.³±±
±±³          ³oOBJTMP - Objeto da classe GetDados             - Nao Obrig.³±±
±±³          ³          (Utilizar somente se o objeto GetDados em uso for ³±±
±±³          ³          declarado com nome diferente de 'oGet')           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGRELOCORRC(cVVAR,cVOCOR,cVTIPO,lGETDAD,nVFDER,cNOMOCO,oOBJTMP)
	Local lINSTECLF  := .F., cINTTOCOR := If(cVTIPO = NIL,"P",cVTIPO)
	Local cALISUTECF := Alias(), nREGTECF := IndexOrd(),lRETECF := .T.
	Local lUTIGDAD   := If(lGETDAD = Nil,.f.,.t.),nPOSCENO := 0
	Local cSXBTQ5    := "NGTQ5"+Space(len(sxb->xb_alias)-5)

	If lUTIGDAD
		If ValType(oOBJTMP) == "O"
			nCOLGE := oOBJTMP:obrowse:ncolpos
		ElseIf nVFDER = NIL
			nCOLGE := oget:obrowse:ncolpos
		Else
			If nVFDER = 1
				nCOLGE := oget01:obrowse:ncolpos
			ElseIf nVFDER = 2
				nCOLGE := oget02:obrowse:ncolpos
			ElseIf nVFDER = 3
				nCOLGE := oget03:obrowse:ncolpos
			ElseIf nVFDER = 4
				nCOLGE := oget04:obrowse:ncolpos
			Endif
		Endif
		nTEMMM   := At("->",cVVAR)
		cCAMAH   := If(nTEMMM > 0,Substr(cVVAR,nTEMMM+2,Len(cVVAR)),cVVAR)
		nPOSCEDU := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == cCAMAH})
		nPOSCENO := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == cNOMOCO})
		If nPOSCEDU > 0
			If nPOSCEDU <> nCOLGE
				Return
			EndIf
		Else
			Return
		EndIf
	Endif

	cCODOCOR := cVOCOR
	cTIPOC   := cINTTOCOR

	If !NGIFDICIONA("SXB",cSXBTQ5,1)
		MsgInfo(STR0112+" NGTQ5."+chr(13)+STR0127,STR0005) //"Nao existe pesquisa padrao para"# "Consulte o suporte." # "NAO CONFORMIDADE"
		lRETECF := .F.
	Else
		If cINTTOCOR = "P" .Or. cINTTOCOR = "C"
			If !Empty(cVOCOR)
				If lUTIGDAD
					If nPOSCEDU > 0
						lINSTECLF := .T.
					EndIf
				Else
					If Readvar() = cVVAR
						lINSTECLF := .T.
					EndIf
				EndIf
			Endif
		EndIf

		If lINSTECLF
			lCONDP := CONPAD1(NIL,NIL,NIL,"NGTQ5",NIL,NIL,.F.)
			If lCONDP
				&cVVAR. := TQ5->TQ5_CODOCR
				If lUTIGDAD
					Acols[n,nPOSCEDU] := TQ5->TQ5_CODOCR
					If nPOSCENO > 0
						Acols[n,nPOSCENO] := NGSEEK("ST8",TQ5->TQ5_CODOCR,1,"T8_NOME")
					Endif
				Endif
				lREFRESH := .T.
			Endif
		Endif
	Endif
	If !Empty(cALISUTECF)
		DbSelectArea(cALISUTECF)
		If nREGTECF > 0
			DbSetOrder(nREGTECF)
		Endif
	Endif
Return lRETECF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCANCOSBLO³ Autor ³Inacio Luiz Kolling ³ Data ³26/04/2007³09:53³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava a ordem de servico como cancelada por motivo de bloqueio  ³±±
±±³          ³do bem.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVNOs - Numero da ordem de servico               - Nao Obrigat. ³±±
±±³          ³cPlan - Numero do plano                          - Nao Obrigat. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Chamadas  ³NGCANCOSBLO()   -> Somente quando ja estiver posicionado no STJ ³±±
±±³          ³NGCANCOSBLO(cOrdem,cPlano)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGCANCOSBLO(cVOs,cPlan)
	Local aAreaBlo := GetArea(),lGravSit := .t.
	Local cOldSituac := ""

	If SuperGetMv("MV_NGBLQOS",.F.,"N") == "S"
		If cVOs <> Nil .And. cPlan <> Nil
			If !NGIFDBSEEK('STJ',cVOs+cPlan,1)
				lGravSit := .f.
			Endif

			cOldSituac := STJ->TJ_SITUACA

			If lGravSit
				Reclock("STJ",.F.)
				STJ->TJ_SITUACA := "C"
				If NGCADICBASE('TJ_MMSYP','A','STJ',.F.)
					If (Empty(STJ->TJ_MMSYP),MsMM(,80,,STR0128,1,,,"STJ","TJ_MMSYP"),;
					MsMM(STJ->TJ_MMSYP,80,,STR0128,1,,,"STJ","TJ_MMSYP"))
				Else
					STJ->TJ_OBSERVA := STR0128
         		Endif
				STJ->(MsUnLock())

				//------------------------------------------------------
				// Integração Mensagem Única para cancelamento de O.S.
				//------------------------------------------------------
				If AllTrim(GetNewPar("MV_NGINTER","N")) == "M" .And. cOldSituac <> "P"
					NGMUCanMnO(STJ->(RecNo()))
				EndIf

			Endif
		Endif
	Endif

	RestArea(aAreaBlo)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCHKBLQBEM³ Autor ³Inacio Luiz Kolling ³ Data ³26/04/2007³15:30³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se tem bloqueio do bem no intervalo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVCodB - Codigo do bem                           - Obrigatorio  ³±±
±±³          ³dVIni  - Data inicio da ordem                    - Obrigatorio  ³±±
±±³          ³hVIni  - Hora inicio da ordem                    - Obrigatorio  ³±±
±±³          ³dVFim  - Data fim da ordem                       - Obrigatorio  ³±±
±±³          ³hVFni  - Hora fim da ordem                       - Obrigatorio  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGCHKBLQBEM(cVCodB,dVIni,hVIni,dVFim,hVFim)

	Local lRetBlq   := .F.
	Local aAreaCBlo := GetArea()

	If SuperGetMv("MV_NGBLQOS",.F.,"N") == "S"
		NGDBAREAORDE("ST3",3)
		DbSeek(xFILIAL("ST3")+cVCodB+Dtos(dVIni),.T.)

		If !Eof()
			If ST3->T3_FILIAL <> xFILIAL("ST3") .Or. ST3->T3_CODBEM <> cVCodB
				Dbskip(-1)
			Endif
		ElseIf !Bof()
			If ST3->T3_FILIAL <> xFILIAL("ST3") .Or. ST3->T3_CODBEM <> cVCodB
				Dbskip()
			Endif
		ElseIf Eof()
			Dbskip(-1)
		Endif

		While !Eof() .And. ST3->T3_FILIAL == xFILIAL("ST3") .And. ST3->T3_CODBEM == cVCodB

			If ST3->T3_DTINI > dVFim
				Exit
			Endif

			If dVFim < ST3->T3_DTFIM
				If dVFim = ST3->T3_DTINI
					If hVFim >= ST3->T3_HRINI
						lRetBlq := .t.
					EndIf
				ElseIf dVIni > ST3->T3_DTINI
					lRetBlq := .t.
				ElseIf dVFim > ST3->T3_DTINI
					lRetBlq := .t.
				EndIf
			Else
				If dVFim > ST3->T3_DTFIM
					If dVIni = ST3->T3_DTFIM
						If hVIni <= ST3->T3_HRFIM
							lRetBlq := .t.
						EndIf
					Else
						If dVIni < ST3->T3_DTFIM
							lRetBlq := .t.
						EndIf
					EndIf
				Else
					If dVIni > ST3->T3_DTINI
						If dVFim = ST3->T3_DTFIM
							If dVIni = ST3->T3_DTFIM
								If hVIni <= ST3->T3_HRFIM
									lRetBlq := .t.
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			If !lRetBlq
				If dVIni < ST3->T3_DTINI
					If dVFim = ST3->T3_DTINI
						If hVFim >= ST3->T3_HRINI
							lRetBlq := .t.
						EndIf
					Else
						If dVFim = ST3->T3_DTFIM
							lRetBlq := .t.
						EndIf
					EndIf
				Else
					If dVIni > ST3->T3_DTINI
						If dVIni <> ST3->T3_DTFIM
							If dVFim = ST3->T3_DTFIM
								lRetBlq := .t.
							EndIf
						EndIf
					Else
						If dVIni = ST3->T3_DTINI
							If dVFim = ST3->T3_DTINI
							Else
								If dVFim < ST3->T3_DTFIM
									lRetBlq := .t.
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Endif

			If !lRetBlq
				If dVIni = ST3->T3_DTINI .And. dVFim = ST3->T3_DTFIM
					If ST3->T3_DTINI = ST3->T3_DTFIM  //Datas Iguais
						If hVFim >= ST3->T3_HRINI //Inico de arquivo
							If hVIni < ST3->T3_HRINI
								lRetBlq := .t.
							EndIf
						EndIf
						If hVIni <= ST3->T3_HRFIM   //FinaL da arquivo
							If hVFim > ST3->T3_HRFIM
								lRetBlq := .t.
							EndIf
						EndIf
						If hVIni >= ST3->T3_HRINI
							If hVFim <= ST3->T3_HRFIM
								lRetBlq := .t.
							EndIf
						EndIf
					Else //Datas iguais ..
						If hVIni >= ST3->T3_HRINI
							lRetBlq := .t.
						Else
							If hVFim <= ST3->T3_HRFIM
								lRetBlq := .t.
							EndIf
						EndIf
						If hVIni <= ST3->T3_HRINI.And. hVFim >= ST3->T3_HRFIM
							lRetBlq := .t.
						EndIf
					EndIf
				Else
					If dVIni = ST3->T3_DTINI.And. dVFim = ST3->T3_DTINI
						If hVFim >= ST3->T3_HRINI
							lRetBlq := .t.
						EndIf
					EndIf
				EndIf
			EndIf

			If lRetBlq
				Exit
			EndIf
			NGDBSELSKIP("ST3")
		End
	EndIf

	RestArea(aAreaCBlo)

Return lRetBlq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCONFBLQBE³ Autor ³Inacio Luiz Kolling ³ Data ³27/04/2007³15:57³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se tem bloqueio do bem no intervalo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVCodB - Codigo do bem                           - Obrigatorio  ³±±
±±³          ³cTpOS  - Tipo da ordem ('P/C')                   - Obrigatorio  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGCONFBLQBE(cVCodB,cTpOS)

	Local lRetConBlq := .t., aAreaCBlo := GetArea(),ny := 0
	Local dTini,hHini,dTfim,hHfim

	Store Ctod('  /  /  ') To dTini,dTfim,dMIN,dMAX
	Store '00:00'          To hHini,hHfim,hMIN,hMAX

	If SuperGetMv("MV_NGBLQOS",.F.,"N") == "S"

		NG420CALDF()
		lPRI420 := .T.
		For ny := 1 To Len(aDATINS)
			If lPRI420 .AND. !Empty(aDATINS[ny][2]) .AND. !Empty(aDATINS[ny][4])
				lPRI420 := .F.
				dMIN := aDATINS[ny][2]
				hMIN := aDATINS[ny][3]
				dMAX := aDATINS[ny][4]
				hMAX := aDATINS[ny][5]
			Else
				If !Empty(aDATINS[ny][2])
					If aDATINS[ny][2] < dMIN
						dMIN := aDATINS[ny][2]
						hMIN := aDATINS[ny][3]
					Else
						If aDATINS[ny][3] < hMIN
							hMIN := aDATINS[ny][3]
						EndIf
					EndIf
				EndIf

				If !Empty(aDATINS[ny][4])
					If aDATINS[ny][4] > dMAX
						dMAX := aDATINS[ny][4]
						hMAX := aDATINS[ny][5]
					Else
						If aDATINS[ny][5] > hMAX
							hMAX := aDATINS[ny][5]
						EndIf
					EndIf
				EndIf
			EndIf
		Next

		dTini := If(Empty(dMIN),M->TJ_DTORIGI,dMIN)
		hHini := If(Empty(hMIN),Time(),hMIN)
		dTfim := If(Empty(dMAX),M->TJ_DTORIGI,dMAX)
		hHfim := If(Empty(hMAX),Time(),hMAX)

		If NGCHKBLQBEM(cVCodB,dTIni,hHIni,dTFim,hHFim)
			If !MsgYesNo(STR0129+Chr(13)+Chr(13)+STR0130,STR0018)
				lRetConBlq := .f.
			Endif
		Endif
	Endif

	RestArea(aAreaCBlo)

Return lRetConBlq

//+-------------------------------------------------+
//|Removida função NGCALSTFDHO, visto que não era   |
//|utilizada, sua unica chamada era através da      |
//|função NGCONFBLQBE, a qual somente era chamada   |
//|pelo MNTA420 O.S. corretiva, tornando impossível |
//|de ser executada.                                |
//|Removido Versão 68 P12114                        |
//+-------------------------------------------------+

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGTEMOSPREVE ³ Autor ³Inacio Luiz Kolling ³ Data ³08/11/2007³11:45³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia da esxistencia de ordem de servico preventiva        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodB  - Codigo do bem                              - Obrigatorio ³±±
±±³          ³cServ  - Codigo do servico                          - Obrigatorio ³±±
±±³          ³cSeq   - Codigo da sequencia                        - Obrigatorio ³±±
±±³          ³dDtOri - Data de origem                             - Obrigatorio ³±±
±±³          ³lTela  - Indica se tera saida via tela              - Nao obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³lRetX  - .t. -> tem O.S ,.f. -> Nao tem O.S.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGTEMOSPREVE(cCodB,cServ,cSeq,dDtOri,lTela)
	Local aAreaAx := GetArea(),lRetX := .F.,lTelL := If(lTela = Nil,.f.,lTela)
	Local lSeqA   := NGVERIFY("STJ"), cSeqA := If(lSeqA,'STJ->TJ_SEQRELA','STJ->TJ_SEQUENC')

	NGIFDBSEEK('STJ',"B"+cCodB+cServ+cSeq+Dtos(dDtOri),6)
	While !Eof() .And. STJ->TJ_FILIAL = Xfilial("STJ") .And. STJ->TJ_TIPOOS = "B";
	.And. STJ->TJ_CODBEM = cCodB .And. STJ->TJ_SERVICO = cServ;
	.And. &(cSeqA) = cSeq .And. STJ->TJ_DTORIGI = dDtOri
		If Val(STJ->TJ_PLANO) > 0 .And. STJ->TJ_TERMINO = "N" .And. STJ->TJ_SITUACA = "L"
			lRetX := .T.
			Exit
		Endif
		Dbskip()
	End
	If lRetX
		If lTela
			MsgInfo(STR0131+" "+Alltrim(cCodB)+CRLF;
			+STR0132+" "+cServ+" "+STR0133+"  "+If(lSeqA,cSeq,Str(cSeq,3));
			+STR0134+" "+Dtoc(dDtOri)+CRLF+STR0135,STR0005)
		Endif
	Endif
	RestArea(aAreaAx)
Return lRetX

//----------------------------------------------------------------------------------
/*/{Protheus.doc} NGGERASA
Função que Gera Solicitação ao Armazém.
@type function

@author Evaldo Cevinscki Jr.
@since 12/11/2008

@param [cCodPr]	  , Caracter , Código do produto.
@param [cOS]	  , Caracter , Código da Ordem de Servico.
@param [cPLN]	  , Caracter , Código do Plano.
@param [nQtd]	  , Numérico , Quantidade do Produto.
@param [cAlmox]   , Caracter , Local estoque.
@param [cItemSA]  , Caracter , Item da Solicitação ao almoxarifado.
@param [cObs]  	  , Caracter , Observação para gravar na S.A.
@param [lMsg_Erro], Lógico   , Indica se mostra msg de erro, quando houver.
@param [cCodSS]   , Caracter , Código da Solicitação de Serviço.
@param [lNewRet]  , Lógico   , Define se deve utilizar o novo padrão de retorno ( poderá ser removido na v12.1.32 )
@param [nSTLNUMSA], Caracter , Numero da S.A. (Utilizado para alterar uma S.A. já existente)
@param [nOpc105]  , numeric  , Indica a operação do processo.
@return Array     , [1] - Caracter, Código da SA.
					[2] - Caracter, Item da SA.
					[3] - Lógico  , Gera pré requisição.
					[4] - Caracter, Mensagem de erro, caso tenha.
					[5] - Lógico  , Define se o processo foi realizado com sucesso.
/*/
//----------------------------------------------------------------------------------
Function NGGERASA( cCodPr, cOS, cPLN, nQtd, cAlmox, cItemSA, cObs, lMsg_Erro, cCodSS,;
	lNewRet, cSTLNumSA, nOpc105 )

	Local nTamB1      := Len(SCP->CP_PRODUTO)
	Local aArea       := GetArea()
	Local aRet        := { '', '', .T., '', .T. }
	Local aFields     := {}
	Local dDatGerasa  := " "
	Local cLocAlm     := IIf(cAlmox <> Nil,cAlmox," ")
	Local lRetPE      := .F.
	Local cItemPos	  := cItemSA //Item do array posicionado, utilizado no PE
	Local cAlsSA      := ''
	Local cBemSA      := ''
	Local lPreReq     := .F.
	Local aCab
	Local aItem
	Local lAglutSA    := GetNewPar("MV_NGMNTAS",'2') == '1' .And. !IsInCallStack( "MNTA720" )
	Local cNumSA      := Space(TAMSX3("TL_NUMSA")[1])
	Local lSolicit    := IIf(cCodSS == Nil, .F., !Empty(cCodSS))
	Local nX
	Local lFacilit    := IIf(FindFunction("MNTINTFAC"),MNTINTFAC(),.F.)
	Local nTamItem	  := TamSx3("TL_ITEMSA")[1]
	Local cItemCTABEM := ''
	Local lOkBaixa    := GetMV("MV_ALTSABX",,.T.)
	Local lIntgRm     := SuperGetMV( "MV_NGINTER",.F.,"N" ) == "M"
	Local aAreaSTJ    := STJ->( GetArea() )
	Local nRecSA      := 0

    // Tratamento efetuado para possivel falta da variavel aBlo
    aBlo := If( Type("aBlo") == "A", aBlo, {{},{},{},{},{}} )

    Default lMsg_Erro := .T.
	Default lNewRet   := .F.
    Default cCodSS    := Space(TAMSX3("TQB_SOLICI")[1])
    Default cObs      := ""
	Default cSTLNumSA := ''
	Default nOpc105   := 3

    Private cCodProd
    Private cTipo
	
	If nOpc105 != 5

		cCodProd := PadR(cCodPr,nTamB1)
		cNumOP   := If(!lSolicit, PadR(cOS,6)+"OS", PadR(cCodSS,6)+"SS") + "001"

		If If(!lSolicit, NGIFDBSEEK('STJ',cOS+cPLN,1), NGIFDBSEEK("TQB", cCodSS, 1))
			cBemSA     := IIf( !lSolicit, STJ->TJ_CODBEM , TQB->TQB_CODBEM )
			dDatGerasa := IIf( !lSolicit, STJ->TJ_DTMPINI, TQB->TQB_DTABER )
			cCCGerasa  := IIf( !lSolicit, STJ->TJ_CCUSTO , TQB->TQB_CCUSTO )
		Else
			cBemSA     := IIf( !lSolicit, M->TJ_CODBEM , TQB->TQB_CODBEM )
			dDatGerasa := IIf( !lSolicit, M->TJ_DTMPINI, TQB->TQB_DTABER )
			cCCGerasa  := IIf( !lSolicit, M->TJ_CCUSTO , TQB->TQB_CCUSTO )
		Endif

		cObs := IIf( Empty( cObs ), cBemSA, cObs )

		IF (ExistBlock("NGNOGERASA"))

			If FunName() == "MNTA450"
				lAblo := .F.
			Endif

			lRetPE  := ExecBlock( 'NGNOGERASA', .F., .F., { cCodProd, cNumOP, nQtd, cAlmox, dDatGerasa, cCCGerasa, cObs, cItemSA, aBLO } )

			aRet[5] := !lRetPE

		Endif

	EndIf

    If aRet[5]

		If nOpc105 != 5
			
			NGIFDBSEEK('SB1',cCodProd,1)
			dbSelectArea("STL")

			/*-----------------------------------------------------------------------------------+
			| Validação não aplicadas por requisições geradas por meio de O.S. vinculadas a S.S. |
			+-----------------------------------------------------------------------------------*/
			If !lSolicit

				//-------------------------------------------------------------
				// Só deve ser executada a query quando não houver uma S.A.
				// preenchida, pois caso a query seja executada quando exista uma S.A.,
				// ocasionará em alteração na S.A. de forma errada
				//-------------------------------------------------------------
				If Empty( cSTLNumSA )

					/*--------------------------------------------------------------------+
					| Processo para incremento no item S.A. quando habilitado aglutinação |
					+--------------------------------------------------------------------*/
					If lAglutSA
					
						cAlsSA := GetNextAlias()

						BeginSQL Alias cAlsSA

							SELECT
								STL.TL_NUMSA,
								STL.TL_ITEMSA,
								STL.TL_QUANTID,
								STL.TL_LOCAL
							FROM
								%table:STL% STL
							WHERE
								STL.TL_ORDEM  = %exp:cOS%     AND
								STL.TL_PLANO  = %exp:cPLN%    AND
								STL.TL_FILIAL = %xFilial:STL% AND
								STL.TL_NUMSA <> ''            AND
								STL.%NotDel%
							ORDER BY
								STL.TL_NUMSA  DESC,
								STL.TL_ITEMSA DESC

						EndSQL

						If (cAlsSA)->( !EoF() ) .And. ( ( !lIntgRm .Or. Inclui ) .Or. NGMUTRAREQ( 'SCP', (cAlsSA)->TL_NUMSA,;
							xFilial( 'SCP' ) , .F., (cAlsSA)->TL_ITEMSA, (cAlsSA)->TL_QUANTID, (cAlsSA)->TL_LOCAL ) )

							cNumSA  := (cAlsSA)->TL_NUMSA
							cItemSA := IIf( cItemSA < PadL( Soma1( (cAlsSA)->TL_ITEMSA ), 2 ), PadL( Soma1( (cAlsSA)->TL_ITEMSA ),;
								2 ), cItemSA )

						EndIf

						(cAlsSA)->( dbCloseArea() )

					EndIf

				Else

					// Para integração com RM, verifica se a S.A. pode sofrer alterações
					If !lIntgRm .Or. Inclui .Or. NGMUTRAREQ( 'SCP', cNumSA, xFilial( 'SCP' ) , .F., cItemSA, nQtd, cAlmox )

						// Pega numero da S.A. gravado na STL
						cNumSA  := cSTLNumSA

						/*-------------------------------------------------------------------------------------------------+
						| Para as rotinas MNTA265 e MNTA490 utiliza-se o parâmetro cItemSA, assim dispensando este trecho. |
						+-------------------------------------------------------------------------------------------------*/
						If !FwIsInCallStack( 'MNTA265' ) .And. !FwIsInCallStack( 'MNTA490' )

							If !lIntgRm

								cAlsSA := GetNextAlias()

								BeginSQL Alias cAlsSA

									SELECT
										STL.TL_ITEMSA
									FROM
										%table:STL% STL
									WHERE
										STL.TL_NUMSA  = %exp:cSTLNumSA% AND
										STL.TL_FILIAL = %xFilial:STL%   AND
										STL.%NotDel%
									ORDER BY
										STL.TL_ITEMSA DESC

								EndSQL

								cItemSA := PadL( Soma1( (cAlsSA)->TL_ITEMSA ), 2 )

								(cAlsSA)->( dbCloseArea() )

							EndIf
						
						EndIf

					EndIf

				EndIf

			EndIf

			dbSelectArea("SCP")
			dbSetOrder(1)
			If !Empty(cNumSA) .And. DbSeek( xFilial("SCP") + cNumSA )
				
				nOpc105 := 4

				// Salva numero da S.A. para que antes de enviar mensagem ao RM posicione corretamente na SCP.
				nRecSA := SCP->( RecNo() )
				//Verifica se existe SCP baixada e se o parametro MV_ALTSABX estiver falso gera um novo numero de S.A.
				If !lOkBaixa
					While !Eof() .And. xFilial("SCP") == SCP->CP_FILIAL .And. SCP->CP_NUM == cNumSA

						If !Empty(SCP->CP_STATUS) .And. SCP->CP_PREREQU == "S"
							nOpc105 := 3
							cNumSA := GetSxeNum( "SCP", "CP_NUM" )
							cItemSA := StrZero(1,nTamItem)
							ConfirmSx8()
							Exit
						EndIf

						dbSelectArea("SCP")
						dbSkip()
					End

					SCP->( dbGoTo( nRecSA ) )

				EndIf

			Else

				/* Para a integração deve ser utilizada a função NGNextNuM("SCP","CP_NUM")
				pois no RM não é permitido utilizar o número de uma SA que já foi cancelada. */
				If lIntgRm
					cNumSA := NGNextNuM( "SCP", "CP_NUM" )
				Else
					//Retirado o GetSxeNum pois ja é feito de forma automatica no ExecAuto
					cNumSA := ''//GetSxeNum( "SCP", "CP_NUM" )
					//ConfirmSx8()
				EndIf

				nOpc105 := 3
				cItemSA := "01"

				dbSelectArea("SCP")
				cMay := "SCP"+AllTrim(xFilial("SCP"))
				If !lAglutSA .And. !Empty(cNumSA)
					While MsSeek(xFilial("SCP")+cNumSA) .Or. !MayIUseCode(cMay+cNumSA)
						cNumSA := Soma1(cNumSA,Len(cNumSA))
					End While
				EndIf
			Endif

			cLocSCP := If(Empty(cLocAlm),SB1->B1_LOCPAD,cLocAlm)

			If lIntgRm
				If lAglutSA .And. NGProdMNT("T")[1] == cCodProd
					cNumSA := NGNextNuM( "SCP", "CP_NUM" )
					cItemSA := StrZero(1,nTamItem)
					nOpc105 := 3
				EndIf
			EndIf

			aCab := {	{"CP_NUM"		,cNumSA		,NIL},;
						{"CP_SOLICIT"   ,cUserName  ,NIL},;
						{"CP_EMISSAO"	,dDataBase  ,NIL}}

			//Verificar se é chamado pela rotina de O.S. corretiva
			If FunName() == "MNTA420"

				//Verifica se ja existia uma S.A para o mesmo produto e quantidade e recupera a data de Emissao para historico
				For nX := 1 to Len(aDtSa)

					If Alltrim(aDtSA[nX][1]) == Alltrim(cCodProd) .And. aDtSA[nX][2] == nQtd .And. ;
						AllTrim(aDtSA[nX][4]) == Alltrim(cNumOP) .And. AllTrim(aDtSA[nX][5]) == Alltrim(cItemSA)

						aCab[3][2] := aDtSA[nX][3]

					EndIf
				Next nX
			EndIf

			If dDataBase > dDatGerasa
				dDatGerasa := dDataBase
			EndIf

			//Busca o item contábil do bem.
			dbSelectArea("STJ")
			dbSetOrder(1)
			If dbSeek(xFilial("STJ") + cOS )
				dbSelectArea("ST9")
				dbSetOrder(1)
				If dbSeek(xFilial("ST9") + STJ->TJ_CODBEM )
					cItemCTABEM := ST9->T9_ITEMCTA
				EndIf
			EndIf

			aItem := {}
			aAdd( aItem , { {"CP_NUM"		,cNumSA		        ,NIL},;
							{"CP_ITEM"	    ,cItemSA			,NIL},;
							{"CP_PRODUTO"	,cCodProd			,NIL},;
							{"CP_UM"		,SB1->B1_UM			,NIL},;
							{"CP_QUANT"		,nQtd				,NIL},;
							{"CP_LOCAL"		,cLocSCP			,NIL},;
							{"CP_DATPRF"	,dDatGerasa			,NIL},;
							{"CP_OP"		,cNumOP				,NIL},;
							{"CP_CC"		,cCCGerasa		    ,NIL},;
							{"CP_DESCRI"	,SB1->B1_DESC		,NIL},;
							{"CP_ITEMCTA"	, cItemCTABEM		,Nil},;
							{ 'CP_OBS'		, cObs              , NIL } } )

			//Ponto de entrada para adicionar ou alterar algum valor dos campos da SCP.
			If ExistBlock("NGALTSCP")
				aSCPReturn := ExecBlock("NGALTSCP",.F.,.F.,{cCodProd,cOS,aBLO,cItemPos,cPLN})
				If Len( aSCPReturn[ 1 ] ) > 0 .Or. Len( aSCPReturn[ 2 ] ) > 0
					//Função para atribuir novos valores para os arrays do aCab e aItem.
					MNTOSPESCP( aSCPReturn, @aCab, @aItem )
				EndIf
			Endif

			//Integracao por Mensagem Unica
			If lIntgRm
				M->CP_FILIAL  := xFilial("SCP")
				//Atribuido os valores do aCab, pois o P.E. NGALTSCP pode alterar o conteúdo de alguns campos
				M->CP_NUM 	  := aCab[ 1 , 2 ] //cNumSA
				M->CP_SOLICIT := aCab[ 2 , 2 ] //cUserName
				M->CP_EMISSAO := aCab[ 3 , 2 ] //dDataBase
				//Atribuido os valores do aItem, pois o P.E. NGALTSCP pode alterar o conteúdo de alguns campos
				M->CP_ITEM 	  := aItem[ 1 , 2 , 2 ]  //cItemSA
				M->CP_PRODUTO := aItem[ 1 , 3 , 2 ]  //cCodProd
				M->CP_UM 	  := aItem[ 1 , 4 , 2 ]  //SB1->B1_UM
				M->CP_QUANT   := aItem[ 1 , 5 , 2 ]  //nQtd
				M->CP_LOCAL   := aItem[ 1 , 6 , 2 ]  //cLocSCP
				M->CP_DATPRF  := aItem[ 1 , 7 , 2 ]  //dDatGerasa
				M->CP_OP 	  := aItem[ 1 , 8 , 2 ]  //cNumOP
				M->CP_CC 	  := aItem[ 1 , 9 , 2 ]  //cCCGERASA //ST9->T9_CCUSTO
				M->CP_OBS 	  := aItem[ 1 , 12 ,2 ] // cObs

				If !lAglutSA
					lOk := NGMUReques(0, 'SCP',.T., nOpc105,, { { cNumSA, { { cItemSA, IIf( Altera, 4, Nil ) } } } } )
				Else
					lOk := .T.
				EndIf

				If !lOk

					aRet := { '', '', .F., '', .F. }

				EndIf

			EndIf

		Else

			dbSelectArea( 'SCP' )
			dbSetOrder( 1 ) // CP_FILIAL + CP_NUM + CP_ITEM + CP_EMISSAO
			If msSeek( FWxFilial( 'SCP' ) + cSTLNumSA + cItemSA )
				
				aCab := {}

				aAdd( aCab, { 'CP_NUM'    , SCP->CP_NUM    , Nil } )
				aAdd( aCab, { 'CP_EMISSAO', SCP->CP_EMISSAO, Nil } )

				aItem := {}

				aAdd( aFields, { 'CP_ITEM'   , SCP->CP_ITEM   , Nil } )
				aAdd( aFields, { 'CP_PRODUTO', SCP->CP_PRODUTO, Nil } )
				aAdd( aFields, { 'CP_QUANT'  , SCP->CP_QUANT  , Nil } )

				aAdd( aItem, aFields )

			EndIf

		EndIf

		If aRet[5]

 			If nOpc105 == 4
				//-----------------------------------------------------------------------------------------------
				// o array aItem é alterado no trecho abaixo para contemplar todos os itens já existentes na SA
				//-----------------------------------------------------------------------------------------------
				aItem := fCargaItem( cNumSA, aItem[1] )

				If Len( aItem ) > 1
					
					/*-----------------------------------------------------------------------+
					| A data de emissão sempre deve ser a menor entre todos os itens da S.A. |
					| sendo assim o valor é pego do primeiro.                                |                                                                          |
					+-----------------------------------------------------------------------*/
					aCab[3,2] := NGSeek( 'SCP', cNumSA, 1, 'CP_EMISSAO' )

				EndIf

			EndIf

			dbSelectArea("SC2")
			dbSetOrder(1) //Necessita definir como Ordem 1 para não ocorrer problema na validação 'ExistCPO(SC2)'

			dbSelectArea("SCP")
			lMsErroAuto := .F.
			MSExecAuto({|x,y,z| mata105(x,y,z)},aCab,aItem,nOpc105) //Inclusao

			If nOpc105 != 5

				dbSelectArea("SCP")
				dbSetOrder(1)
				dbGoTo( IIf( nOpc105 == 4 .And. nRecSA > 0, nRecSA, SCP->( LastRec() ) ) )
				cNumSA := SCP->CP_NUM
				nRecSCP := SCP->(Recno())

				//Não é realizado aglutinação do insumo no tipo terceiro
				//quando integrado ao RM, sempre é gerado uma nova S.A.
				If lIntgRm
					If lAglutSA .And. NGProdMNT("T")[1] == cCodProd
						NGMUReques(,"SCP",.T.,3,"T")
					EndIf
				EndIf

				If nOpc105 == 3
					FreeUsedCode(.T.) //Libera codigos de correlativos reservados pela MayIUseCode()
				Endif

				If lSolicit .And. lFacilit
					dbSelectArea("SCP")
					dbSetOrder(1)
					If dbSeek(xFilial("SCP") + cNumSA + cItemSA)
						RecLock("SCP", .F.)
						SCP->CP_MNTSS := cCodSS
						MsUnlock("SCP")
					EndIf
				EndIf

			EndIf

			If lMsErroAuto

				If FunName() != 'MNTA340' .And. !IsBlind()

					MostraErro()

				EndIf

				// Proteção de fonte garantindo que as rotinas que esperam o retorno encontram-se atualizadas.
				aRet := IIf( lNewRet, { '', '', .F., MostraErro( GetSrvProfString( 'Startpath', '' ), CriaTrab( , .F. ) + '.log' ), .F. }, {} )

			Else

				//Passado como parâmetro os códigos do Produto, número da SA e Item
				If ( ExistBlock( 'MNTSCPUSER' ) )

					ExecBlock( 'MNTSCPUSER', .F., .F., { cCodProd, cNumSA, cItemSA } )

				EndIf

				// Proteção de fonte garantindo que as rotinas que esperam o retorno encontram-se atualizadas.
				aRet := IIf( lNewRet, { cNumSA, cItemSA, lPreReq, '', .T. }, { cNumSA, cItemSA, lPreReq } )

			EndIf

		EndIf

	EndIf

	RestArea( aAreaSTJ )
    RestArea( aArea )

Return aRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGCHKSAPR ³ Autor ³Evaldo Cevinscki Jr.   ³ Data ³11/12/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Checa se existe Solicitacao ao Armazem com Pre-Requisicao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cOS       - Ordem de Servico                   - Obrigatorio³±±
±±³          ³cvPLANO   - Plano da Manutencao                - Obrigatorio³±±
±±³          ³cProdSA   - Codigo do Produto                  - Nao Obrigat³±±
±±³          ³laCols    - Para programas com GetDados de Insumos          ³±±
±±³          ³lTela  - Indica se tera saida via tela        - Nao obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCHKSAPR(cOS,cvPLANO,cProdSA,laCols,lTela)

    Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	Local cCondSql  := '%%'
	Local cOPSA     := PadR( cOS, 6 ) + 'OS001'
    Local lSARet    := .T.
	Local nLocP     := 0

    Default cProdSA := ''
    Default lTela   := .F.

	If laCols
        nTar := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_TAREFA"})
        nCodP:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_CODIGO"})
        nSeq := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_SEQTARE"})
        nLocP:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_LOCAL"})
    EndIf

    If !Empty( cProdSA )
        cCondSql := '% AND CP_PRODUTO = ' + ValToSQL( cProdSA ) + '%'
    EndIf

    BeginSQL Alias cAliasQry

        SELECT 
			SCP.CP_NUM
        FROM 
			%table:SCP% SCP
        WHERE 
			SCP.CP_FILIAL  = %xFilial:SCP% AND
        	SCP.CP_OP      = %exp:cOPSA%   AND
        	SCP.CP_PREREQU = 'S'           AND
            ( ( SCP.CP_QUJE > 0 AND
				SCP.CP_STATUS = 'E' ) OR SCP.CP_STATUS = '' ) AND
            SCP.%NotDel%
            %exp:cCondSql%

    EndSQL

    While (cAliasQry)->( !EoF() )

        If NGIFDBSEEK("STL",cOS+cvPLANO+If(laCols,If(nTar>0,aCols[n][nTar],"0"+Space(Len(STL->TL_TAREFA)-1))+"P"+aCols[n][nCodP]+"0  "+aCols[n][nSeq],""),1)
            If laCols
                If STL->TL_NUMSA == (cAliasQry)->CP_NUM
                    lSARet := .f.
                EndIf
            Else
                While !Eof() .And. STL->TL_FILIAL == xFilial("STL") .And. STL->TL_ORDEM == cOS .And. STL->TL_PLANO == cvPLANO
                    If STL->TL_NUMSA == (cAliasQry)->CP_NUM
                        lSARet := .f.
                    EndIf
                    NGDBSELSKIP("STL")
                End
            EndIf
        EndIf
        NGDBSELSKIP(cAliasQry)
    End
    
	(cALIASQRY)->(dbCloseArea())

    If laCols .And. !lSARet
        If aScan(aGETINSAL,{|x| x[nCodP]+x[nSeq]+If(nTar > 0,x[nTar],"")+x[nLocP] = aCols[n][nCodP]+aCols[n][nSeq]+If(nTar>0,aCols[n][nTar],"")+aCols[n][nLocP]}) == 0
            lSARet := .t.
        EndIf
    EndIf

    If !lSARet .And. lTela
        If laCols
            MsgStop(STR0136,STR0018)  //"Alteração/Exclusão não permitida pois existe Solicitação ao Armazém com Pré-Requisição."###"ATENÇÃO"
        Else
            MsgStop(STR0137,STR0018)  //"Cancelamento da O.S. não permitido pois existe Solicitação ao Armazém com Pré-Requisição."###"ATENÇÃO"
        EndIf
    EndIf
    RestArea(aArea)
Return lSARet

//--------------------------------------------------------------------------------------------------
/*/{Proteus.doc} NGNOVAOS
Busca o código do produto referente ao funcionário enviado por parâmetro.
@type function

@author Marcos Wagner Junior
@since  02/07/2010

@sample NGNOVAOS()

@param  _cBem    , string , Código do Bem.
@param  _cServico, string , Código do Serviço.
@param  _cSequenc, string , Sequência da Manutenção.
@param  lRetArr  , boolean, Define se o retorno deve ser boolean ou array.
@return boolean  , Define se o processo de inclusão da O.S. poderá seguir.
@return array    ,  [1] - Define se o processo de inclusão da O.S. poderá seguir.
					[2] - Mensagem de erro.
/*/
//------------------------------------------------------------------------------------------------
Function NGNOVAOS( _cBem, _cServico, _cSequenc, lRetArr )

	Local lRet     := .T.
	Local cNovaOS  := GetNewPar( 'MV_NGNOVOS', '' )
	Local cError   := ''
	Local aOldArea := GetArea()

	Default lRetArr := .F.

	If cNovaOS == '1'
		If NGIFDBSEEK('STJ','B'+_cBem+_cServico+_cSequenc,2)
			While !Eof() .AND. STJ->TJ_FILIAL == xFilial("STJ") .AND. STJ->TJ_CODBEM == _cBem .AND.;
			STJ->TJ_SERVICO == _cServico .AND. STJ->TJ_SEQRELA == _cSequenc .AND. lRet

				If STJ->TJ_PLANO <> '000000' .AND. STJ->TJ_TERMINO == 'N' .AND. STJ->TJ_SITUACA == 'L'
					lRet   := .F.
					cError := STR0286 // Já existe uma ordem de serviço aberta para bem, serviço e sequência.
				Endif

				dbSkip()
			End
		Endif
	Endif
	RestArea(aOldArea)

Return IIf( lRetArr, { lRet, cError }, lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} NGALTSTLCOMP
Verifica quantidade Pedida / Cotada


@author In cio Luiz Kolling
@since 21/08/2012
@return
/*/
//---------------------------------------------------------------------

Static Function NGALTSTLCOMP(cVORDEM,cVCODIGO,cCODOP,lDELG,cCodPTerc,cNumSa,cItemSA)
	Local lRetL  := .F.,cOPL := Alltrim(cCODOP)+Space(Len(SC1->C1_OP)-Len(Alltrim(cCODOP)))
	Local nProdL := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_CODIGO"})
	Local nTiprL := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_TIPOREG"})
	Local nQuanL := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_QUANTID"})
	Local nLocaL := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_LOCAL"})
	Local nNumSA	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_NUMSA"})
	Local nItemSA	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_ITEMSA"})
	Local aISTLC := {}, nFL := 0,nQtdSTL := 0,nQtdCom := 0,nQtdDif := 0
	Local lLGeSA := .F.
	Local lDELGC := If(lDELG = Nil,.f.,lDELG)
	Local aAreaL := GetArea()

	If NGCADICBASE('TL_NUMSA','A','STL',.F.) .And. FindFunction("NGGERASA")
		If GetNewPar("MV_NGGERSA","N") $ "S/P" .And. cUsaIntEs == "S"
			lLGeSA := .T.
		EndIf
	EndIf

	If NGIFDBSEEK("STL",cVORDEM,1)
		While !Eof() .And. STL->TL_FILIAL = Xfilial("STL") .And. STL->TL_ORDEM = cVORDEM
			Aadd(aISTLC,{STL->TL_TIPOREG,STL->TL_CODIGO,STL->TL_QUANTID,STL->TL_LOCAL,STL->TL_NUMSA,STL->TL_ITEMSA})
			DbSkip()
		End
		If len(aISTLC) > 0
			If !lLGeSA //GERA SC
				If !lDELGC // ALTERA QUANTIDADE
					If n <= len(aISTLC)
						cLocX := aISTLC[n,4]
						For nFL := 1 To Len(aCols)
							If !Atail(aCols[nFL]) .And. aCols[nFL,nTiprL] = aISTLC[n,1] .And. aCols[nFL,nProdL] = cVCODIGO .And. aCols[nFL,nLocaL] = cLocX
								nQtdSTL += aCols[nFL,nQuanL]
							EndIf
						Next nFL
						nQtdDif := nQtdSTL-aCols[n,nQuanL]+M->TL_QUANTID
						If nQtdSTL > 0
							nQtdCom := NGBUSC1COM(cOPL,If(Empty(cCodPTerc),cVCODIGO,cCodPTerc),cLocX,If(Empty(cCodPTerc),Nil,cVCODIGO))
						EndIf
					EndIf
				Else // EXCLUSAO DO ITEM

					If nProdL > 0
						cLocX   := aISTLC[n,4]
						nQtdDif := 0
						For nFL := 1 To Len(aCols)
							If !Atail(aCols[nFL]) .And. aCols[nFL,nTiprL] == aISTLC[n,1] .And. aCols[nFL,nProdL] == cVCODIGO .And. aCols[nFL,nLocaL] == cLocX
								If nFl <> n
									nQtdDif += aCols[nFL,nQuanL]
								EndIf
							EndIf
						Next nFL
						nQtdCom := NGBUSC1COM(cOPL,If(Empty(cCodPTerc),cVCODIGO,cCodPTerc),cLocX,If(Empty(cCodPTerc),Nil,cVCODIGO))
					EndIf
				EndIf
				If nQtdCom > 0
					If nQtdCom > nQtdDif
						lRetL := .T.
					EndIf
				EndIf
			Else //GERA SA
				If !lDELGC // ALTERA QUANTIDADE
					If n <= len(aISTLC)

						cLocX := aISTLC[n,4]
						For nFL := 1 To Len(aCols)
							If !Atail(aCols[nFL]) .And. aCols[nFL,nTiprL] == aISTLC[n,1] .And. aCols[nFL,nProdL] == cVCODIGO .And. ;
							aCols[nFL,nLocaL] == cLocX .And. aCols[nFL,nNumSa] == cNumSa .And. aCols[nFL,nItemSa] == cItemSA
								nQtdSTL += aCols[nFL,nQuanL]
							EndIf
						Next nFL
						nQtdDif := nQtdSTL-aCols[n,nQuanL]+M->TL_QUANTID
						If nQtdSTL > 0
							lRetL := NGBUSCPCOM(cOPL,cVCODIGO,cLocX,nQtdSTL,aCols)
						EndIf
					EndIf
				Else //EXCLUSAO DO ITEM

					If nProdL > 0
						cLocX   := aISTLC[n,4]
						nQtdDif := 0
						For nFL := 1 To Len(aCols)
							If !Atail(aCols[nFL]) .And. aCols[nFL,nTiprL] == aISTLC[n,1] .And. aCols[nFL,nProdL] == cVCODIGO .And. ;
							aCols[nFL,nLocaL] == cLocX .And. aCols[nFL,nNumSa] == cNumSa .And. aCols[nFL,nItemSa] == cItemSA
								nQtdDif += aCols[nFL,nQuanL]
							EndIf

						Next nFL
						lRetL := NGBUSCPCOM(cOPL,cVCODIGO,cLocX,nQtdSTL,aCols)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaL)
Return lRetL


//---------------------------------------------------------------------
/*/{Protheus.doc} NGBUSC1COM
Verifica e retorna a quantidade de itens que foram Pedidos e Cotados,
de acordo com a OP, Produto e Almoxarifado passados como parâmetro.

@param cVOP OP para localização da SC1
@param cVCOD Código do produto a ser validado
@param cVLoc Local do Almoxarifado
@author In cio Luiz Kolling
@since 21/08/2012
@return
/*/
//---------------------------------------------------------------------
Function NGBUSC1COM(cVOP,cVCOD,cVLoc,cFornec)
	Local nQtdSC1C := 0.00,aAreaOLD := GetArea(),cOPL := Alltrim(cVOP)+Space(Len(SC1->C1_OP)-Len(Alltrim(cVOP)))
	If NGIFDBSEEK("SC1",cOPL,4)
		While !EOF() .And. SC1->C1_FILIAL == xFilial("SC1") .And. SC1->C1_OP == cOPL
			If SC1->C1_PRODUTO == cVCOD .And. SC1->C1_LOCAL = cVLoc
				If Empty(cFornec) .Or. AllTrim(cFornec) == AllTrim(SC1->C1_FORNECE) //Caso for TERCEIROS, verifica Cotação e Pedido do Fornecedor
					If !Empty(SC1->C1_PEDIDO)
						nQtdSC1C += SC1->C1_QUJE
					ElseIf !Empty(SC1->C1_COTACAO)
						nQtdSC1C += SC1->C1_QUANT
					EndIf
				EndIf
			EndIf
			DbSkip()
		End
	EndIf

	RestArea(aAreaOLD)
Return nQtdSC1C



Function NGBUSCPCOM(cVOP,cVProd,cVLoc,nQtdSTL,aCols)

	Local nQtdSCPC		:= 0.00
	Local aAreaOLD		:= GetArea()
	Local lRet 			:= .F.
	Local nNumSA	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_NUMSA"})
	Local nItemSa	:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_ITEMSA"})
	Local nTipo		:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_TIPOREG"})
	Default nQtdSTL := 0
	If nTipo > 0 .AND. aCols[n][nTipo] == "T"
		cVProd = If(FindFunction("NGProdMNT"), NGProdMNT("T")[1], Alltrim(GetMV("MV_PRODTER")))
	EndIf
	//checa se SA ja foi gerada para o item,caso positivo não gera novamente
	cAliasQry := GetNextAlias()
	cQuery := " SELECT * "
	cQuery += " FROM "+RetSqlName("SCP")+" SCP"
	cQuery += " WHERE SCP.CP_FILIAL='"+xFilial("SCP")+"' AND SCP.CP_PRODUTO = '"+cVProd+"' "
	cQuery += " AND SCP.CP_OP = '" + cVOP + "' AND SCP.CP_LOCAL = '" + cVLoc + "'"
	If (nNumSA + nItemSA) > 0
		cQuery += " AND SCP.CP_NUM = '" + aCols[n][nNumSA] + "'" + " AND SCP.CP_ITEM = '" + aCols[n][nItemSA] + "'"
	EndIf
	cQuery += " AND SCP.D_E_L_E_T_<>'*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	//se ja teve alguma qtd. atendida gera somente para a diferenca
	While !Eof()
		If (cAliasQry)->CP_PREREQU == "S" //.And. (cAliasQry)->CP_QUJE = 0




			nQtdSCPC += (cAliasQry)->CP_QUANT
		EndIf
		NGDBSELSKIP(cAliasQry)
	End While
	(cALIASQRY)->(dbCloseArea())
	RestArea(aAreaOLD)

	If nQtdSCPC > 0
		lRet 	:= .T.
	EndIF
Return lRet

Function NGRETJACOMP(cCODOP)
	Local cUsaIntEs := AllTrim(GetMv("MV_NGMNTES"))
	Local cOPL := Alltrim(cCODOP)+Space(Len(SC1->C1_OP)-Len(Alltrim(cCODOP)))
	Local nFR := 0, nQtdComp

	//------------------------------------------------------------
	// Verificação Geração de Solicitação ao Armazém (S.A.)
	//------------------------------------------------------------
	If NGCADICBASE('TL_NUMSA','A','STL',.F.) .And. FindFunction("NGGERASA")
		// Gera S.A. quando a integração for completa ("S") ou quando for apenas para os Produtos ("P")
		If GetNewPar("MV_NGGERSA","N") $ "S/P" .And. cUsaIntEs == "S"
			lGeraSA := .T.
		EndIf
	EndIf

	// Retira a quantidade já solicitada
	For nFR := 1 To Len(aIAglu)
		nQtdComp := 0
		If !lGeraSA
			nQtdComp := NGBUSC1COM(cOPL,aIAglu[nFR,1],aIAglu[nFR,2])
		EndIf
		If nQtdComp > 0 .And. aIAglu[nFR,3] >= nQtdComp
			aIAglu[nFR,3] := aIAglu[nFR,3] - nQtdComp
		EndIf
	Next nFR
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} NGGRAVSC1CM
Gera solicitacao de compras no modelo normal (Unico C1_NUM)

@author Inácio Luiz Kolling
@param  cVOP       , Caracter, Numero da Ordem de Producao
@param  avItenC    , Array   , Array com os itens a serem comprados
@param  cCHAMADOR  , Caracter, Programa que chamou a função
@param  [lUsePrAlt], Lógico  , Define se utiliza produto alternativo
@param  [cSC1Bkp]  , string  , Número da SC1 relacionada a OS

/*/
//---------------------------------------------------------------------
Function NGGRAVSC1CM( cVOP, avItenC, cCHAMADOR, lUsePrAlt, cSC1Bkp )

	Local nVx 		 := 0
	Local nQTDCOMP	 := 0
	Local lRet 		 := .T.
	Local lSolicit   := .F.
	Local lMNTA4102	 := ExistBlock("MNTA4102")
	Local lMNTA3404	 := ExistBlock("MNTA3404")
	Local lMT650C1	 := ExistBlock("MT650C1")
	Local lNGGERSC2	 := ExistBlock("NGGERSC2")
	Local lNOGERASC  := ExistBlock( 'NGNOGERASC' )	
	Local cCodUsr	 := RetCodUsr()
	Local aAreaAn 	 := GetArea()
	Local aSC        := {}
	Local cUsaIntEs  := AllTrim(GetMv("MV_NGMNTES"))
	Local lAPROVSC	 := SuperGetMv("MV_APROVSC")
	Local cTJ_CCUSTO := IIf(Type("M->TJ_CCUSTO") == "C" , M->TJ_CCUSTO , "")
	Local cTJ_CODBEM := IIf(Type("M->TJ_CODBEM") == "C" , M->TJ_CODBEM , "")
	Local cTpSaldo   := AllTrim(SuperGetMV("MV_TPSALDO"))
	Local lNewSc     := Type('aNewSc') == 'A'
	Local lGeraSC    := .T.	
	Local lIntegRM   := SuperGetMv( 'MV_NGINTER', 'N' ) == 'M'
	Local nQtdSC1    := 0
	Local nQtdSTL    := 0
	Local cSC1Num    := ' '
	Local cSC1Item   := ' '

	// Variáveis utilizadas no ExecAuto MATA110
	Local cObserva   := ''
	Local cItemCta   := ''
	Local cFornec    := ''
	Local cLoja      := ''
	Local cCustB     := ''
	Local cCodBem    := ''
	Local cDescSB1   := ''
	Local aRetSC     := { .F., '' }
	Local nOption    := 3  // Operação de inclusão como default
	Local lExecSC    := FindFunction( 'MntExecSC1' ) .And. ( FwIsInCallStack( 'NG410INC' ) .Or.;
		FwIsInCallStack( 'NG420INC' ) .Or. FwIsInCallStack( 'A340ASIM' ) )

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Default lUsePrAlt := AllTrim( SuperGetMv( 'MV_MNTPRAL', .F., '2' ) ) == '1' .And. AllTrim( SuperGetMv( 'MV_NGGERSA', .F., 'N' ) ) == 'N'
	Default cSC1Bkp   := ' '

	If Type('cNumSC1') == 'U'
		cNumSC1 := Space(Len(SC1->C1_NUM))
		cNuISC1 := 0
	Endif

	For nVx := 1 To Len(avItenC)

		/*----------------------------------------------+
		| Recupero número e item da S.C. para gravação. |
		+----------------------------------------------*/
		aSC := MNTNumSC( avItenC[nVx,9], avItenC[nVx,10], cVOP, cSC1Bkp )
			
		cSC1Num  := aSC[1]
		cSC1Item := aSC[2]	

		nOption  := 3  // Operação de inclusão como default

		cCodPro	 := Left(aVItenC[nVx,1],Len(SB1->B1_COD))
		cLOCSTL	 := avItenc[nVx,4]
		NGIFDBSEEK('SB2',cCodPro+cLOCSTL,1)

		//P.E. que permite alterar Centro de Custo da SC antes da gravação
		If lNGGERSC2
			cCustB := ExecBlock( "NGGERSC2", .F., .F. , { avItenC[nVx,1] , avItenc[nVx,4] } ) //{ Códgo do Produto, Almoxarifado }
		EndIf

		lSaldoSB2 := .T.
		If !Empty(cCHAMADOR)
			If cCHAMADOR = "MNTA410"
				If lMNTA4102
					ExecBlock("MNTA4102",.F.,.F.)
					lSaldoSB2 := .F.
				EndIf
			ElseIf cCHAMADOR = "MNTA340"
				If lMNTA3404
					ExecBlock("MNTA3404",.F.,.F.)
					lSaldoSB2 := .F.
				EndIf
			EndIf
		EndIf

		nQTDCOMP  := avItenC[nVx,2]

		//-------------------------------------------
		// Realiza consistencia para insumo TERCEIRO
		//-------------------------------------------
		If Len(avItenC[nVx]) > 4 .And. !Empty( avItenC[nVx,5] )

			//--------------------------------------------------------
			// Verifica a quantidade já gerada no SC1.
			// Se houver SC, provavelmente será de COTACAO ou PEDIDO
			//--------------------------------------------------------
			If NGIFDBSEEK("SC1",cVOP,4)
				While !EOF() .And. SC1->C1_FILIAL == xFilial("SC1") .And. SC1->C1_OP == cVOP
					If SC1->C1_PRODUTO == avItenC[nVx,1] .And. SC1->C1_LOCAL = avItenC[nVx,4]
						If AllTrim(avItenC[nVx,5]) == AllTrim(SC1->C1_FORNECE) //Caso for TERCEIROS, verifica Cotação e Pedido do Fornecedor
							If !Empty(SC1->C1_PEDIDO)
								nQtdSC1 += SC1->C1_QUJE
							Else //If !Empty(SC1->C1_COTACAO)
								nQtdSC1 += SC1->C1_QUANT
							EndIf
						EndIf
					EndIf
					dbSelectArea("SC1")
					dbSkip()
				EndDo
			EndIf

			//--------------------------------------------------------
			// Garante que registro esteja posicionado no STJ correto
			//--------------------------------------------------------
			NGIFDBSEEK("STJ",SubStr(cVOP,1,6),1)

			//-------------------------------------------------------------------------------------------
			// Verifica a quantidade total requisitada para o Terceiro com o mesmo código de fornecedor
			//-------------------------------------------------------------------------------------------
			dbSelectArea("STL")
			dbSetOrder(4)
			dbSeek(xFilial("STL")+STJ->TJ_ORDEM+STJ->TJ_PLANO+"T"+avItenC[nVx,5])
			While !Eof() .And. STL->TL_FILIAL == Xfilial("STL") .And. STL->TL_ORDEM = STJ->TJ_ORDEM .And. ;
			STL->TL_TIPOREG == "T" .And. Alltrim(STL->TL_CODIGO) == Alltrim(avItenC[nVx,5]) .And. Alltrim(STL->TL_LOCAL) == Alltrim(avItenC[nVx,4])

				nQtdSTL += STL->TL_QUANTID

				dbSelectArea("STL")
				dbSkip()
			EndDo

			If nQtdSC1 > nQtdSTL
				Return .F.
			ElseIf nQtdSC1 == nQtdSTL
				Return .T.
			EndIf
			
		EndIf

		If !lUsePrAlt
			lPROBLEMA := .T.//Não retirar - caso não tiver integração com Estoque não verifica saldo
			If lSaldoSB2 .and. cUsaIntEs == "S"
				//Validação conforme definição da Equipe de Estoque TOTVS de acordo com  o conteúdo do parâmetro MV_TPSALDO
				If GetNewPar("MV_NGINTER","") == "M" 			// Integracao por Mensagem Unica
					nSALDODIS := NGMUStoLvl(cCodPro, cLOCSTL,.T.) // Atualiza tabela
				Else
					If cTpSaldo == "C" //Busca saldo que o estoque tinha na data informada no parâmetro dData
						nSALDODIS := xCalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDataBase+1)[1]
					ElseIf cTpSaldo == "S" //Retorna saldo atual independente da data
						nSALDODIS := SaldoSB2(.F.,.T.,dDataBase+3650,.F.)
					ElseIf cTpSaldo == "Q" //Retorna saldo com desconto de quantidade reservada e quantidade a enderecar
						nSALDODIS := SB2->B2_QATU - SB2->B2_QACLASS - SB2->B2_RESERVA
					EndIf
				EndIf

				lPROBLEMA := .F.
				If nSALDODIS <= 0
					lPROBLEMA := .T.
					nQTDCOMP  := avItenC[nVx,2]
				ElseIf (nSALDODIS - avItenC[nVx,2]) < 0
					lPROBLEMA := .T.
					nQTDCOMP  := (nSALDODIS - avItenC[nVx,2]) * -1
				Endif
			EndIf
		Else
			lPROBLEMA := .F.
			// Caso o produto esteja no array de aNewSC, deverá ser gerado solicitação de compra, pois não há quantidade
			// em estoque e nenhum produto alternativo que atenda a quantidade requisitada
			If lNewSc .And. ( nPosCode := aScan( aNewSc, { |x| x[ 1 ] + x[ 2 ] == aVItenC[ nVx, 1 ] + avItenc[ nVx, 4 ] } ) ) > 0
				nSALDODIS := aNewSc[ nPosCode, 3 ]
				If nSALDODIS <= 0
					lPROBLEMA := .T.
					nQTDCOMP  := avItenC[nVx,2]
				ElseIf (nSALDODIS - avItenC[nVx,2]) < 0
					lPROBLEMA := .T.
					nQTDCOMP  := ( nSALDODIS - avItenC[ nVx, 2 ] ) * - 1
				Endif
			EndIf
		EndIf

		If lPROBLEMA  // Nao Possui quantidade em estoque
			If SG1->(Dbseek(xFILIAL('SG1')+avItenC[nVx,1]))
				lContSC2 := .F.
				If NGIFDBSEEK("SC2",cVOP,1)
					lContSC2 := .T.
				EndIf
				nC2RECNO := SC2->(RecNo())
				cCusto := NgFilTPN(M->TJ_CODBEM,DTPREINI,SubStr(Time(),1,5))[2] //Buscar o C.C. do bem na TPN
				GERAOPNEW(avItenC[nVx,1],avItenC[nVx,2],SubStr(cVOP,1,TAMSX3("TJ_ORDEM")[1]),DTPREINI,DTPREINI,avItenC[nVx,4],,cCusto,"PLANO " + M->TJ_PLANO)
				If !lContSC2 //Se nao encontrou antes, então tem que posicionar na OP que acabou de incluir pela função GERAOP
					nC2RECNO := SC2->(RecNo())
				EndIf
				NGAtuErp("SC2",If(lContSC2,"UPDATE","INSERT"))
				SC2->(DbGoTo(nC2RECNO)) //Posiciona na OP para função NGEMPMATE()
			Else
				aQtdes := {}
				aQtdes := CALCLOTE(cCODPRO,nQTDCOMP,"C")
			Endif

			// P.E. que define condição  para inclusão de solicitação de compras.
			lGeraSC := IIf( lNOGERASC, !ExecBlock( 'NGNOGERASC', .F., .F., { cVOP, avItenC[nVx,1], avItenC[nVx,4] } ), lGeraSC )
			
			If lGeraSC

				If NGIFDBSEEK("SB1",avItenC[nVx,1],1)

					If !lExecSC .And. AllTrim(GetNewPar("MV_NGINTER","N")) == "M"  //Mensagem Unica
						cOrdSer := SubStr(cVOP,1,TAMSX3("TJ_ORDEM")[1])
						cCodBem := NGSEEK("STJ",cOrdSer,1,"TJ_CODBEM")
						If Empty(cCustB) .Or. !lNGGERSC2
							cCustB  := NGSEEK("STJ",cOrdSer,1,"TJ_CCUSTO")
							cCustB  := If(Empty(cCustB),cTJ_CCUSTO,cCustB)
						Endif

						If dDataBase > avItenC[nVx,3]
							avItenC[nVx,3] := dDataBase
						EndIf

						M->C1_FILIAL  := xFilial("SC1")
						M->C1_NUM	  := cSC1Num
						M->C1_SOLICIT := SubStr(cusuario,7,15)
						M->C1_OP 	  := cVOP
						M->C1_EMISSAO := dDataBase
						M->C1_OBS 	  := STR0139+cOrdSer+STR0140+cCodBem
						M->C1_ITEM 	  := cSC1Item
						M->C1_ITEMGRD := ''
						M->C1_PRODUTO := avItenC[nVx,1]
						M->C1_QUANT   := nQTDCOMP
						M->C1_UM 	  := SB1->B1_UM
						M->C1_LOCAL   := avItenC[nVx,4]
						M->C1_DATPRF  := avItenC[nVx,3]
						M->C1_CC      := cCustB

						lRet := NGMUReques(SC1->(Recno()),'SC1',.T.)
					EndIf

					If lRet

						If lExecSC

							If NgIfDbSeek( 'SC1', cSC1Num + cSC1Item, 1 )

								/*----------------------------------------------------------------------------------+
								| Somente altera para o processo de alteração quando Num SC e Item SC já existirem. |
								+----------------------------------------------------------------------------------*/
								nOption := 4

							EndIf

							/*----------------------------------------------------------+
							| Manipula variáveis que seram enviadas ao ExecAuto MATA110 |
							+----------------------------------------------------------*/
							If Empty( cCustB ) .Or. !lNGGERSC2

								cCustB  := NGSEEK( 'STJ', SubStr( cVOP, 1, TAMSX3( 'TJ_ORDEM' )[1] ), 1, 'TJ_CCUSTO' )

							EndIf

							cCodBem  := NGSEEK( 'STJ', SubStr( cVOP, 1, TAMSX3( 'TJ_ORDEM' )[1] ), 1, 'TJ_CODBEM' )
							cObserva := STR0139 + SubStr( cVOP, 1, TAMSX3( 'TJ_ORDEM' )[1] ) + STR0140 + cCodBem
							cItemCta := NGSEEK( 'ST9', cCodBem, 1, 'T9_ITEMCTA' )
							cDescSB1 := Posicione( 'SB1', 1, FWxFilial( 'SB1' ) + avItenC[nVx,1], 'B1_DESC' )
							
							If Len( avItenC[nVx] ) >= 7
								cFornec := avItenC[nVx,6]
								cLoja   := avItenC[nVx,7]
							EndIf

							/*----------------------------------------------------------------------------------------+
							| Quando integrado ao RM, caso a database seja superior a data da O.S., assume a database |
							+----------------------------------------------------------------------------------------*/
							If lIntegRM .And. dDataBase > avItenC[nVx,3]
								avItenC[nVx,3] := dDataBase
							EndIf

							/*-------------------------------------------------------------+
							| Realiza a inclusão de uma S.C. por meio do ExecAuto MATA110. |
							+-------------------------------------------------------------*/
							aRetSC := MntExecSC1( cSC1Num, cSC1Item, { nQTDCOMP, avItenC[nVx,1], avItenC[nVx,4], cVOP, avItenC[nVx,3],;
								cCustB, cItemCta, cFornec, cLoja, cObserva, cDescSB1 }, nOption )

							If aRetSC[1]
									
								lRet := aRetSC[1]

							Else

								lRet := aRetSC[1]
								Exit
							
							EndIf

						Else

							/*------------------------------------------------------------------------------------------------------+
							| Processo via ExecAuto MATA110, sendo que, até o momento somente é comportado a operação de alteração, |
							| quando acionado pela rotina MNTA420.                                                                  |
							+------------------------------------------------------------------------------------------------------*/
							If FwIsInCallStack( 'MNTA420' ) .And. NGIFDBSEEK( 'SC1', cSC1Num + cSC1Item, 1 )
								
								/*--------------------------------------------------------------+
								| Realiza a alteração de uma S.C. por meio do ExecAuto MATA110. |
								+--------------------------------------------------------------*/
								aRetSC := MNTXCOM( cSC1Num, cSC1Item, { nQTDCOMP, avItenC[nVx,4], avItenC[nVx,1] } )

								If !aRetSC[1]
									Return aRetSC[1]
								EndIf

							Else

								lSolicit := 'SS001' $ cVOP

								DbSelectArea("SC1")
								RecLock("SC1",.T.)
								SC1->C1_FILIAL		:= xFilial("SC1")
								SC1->C1_NUM			:= cSC1Num
								SC1->C1_OP			:= cVOP
								SC1->C1_EMISSAO	    := dDataBase
								SC1->C1_SOLICIT	    := SubStr(cusuario,7,15)
								SC1->C1_ITEM		:= cSC1Item
								SC1->C1_PRODUTO	    := avItenC[nVx,1]
								SC1->C1_UM			:= SB1->B1_UM
								SC1->C1_QUANT		:= nQTDCOMP
								SC1->C1_DATPRF		:= avItenC[nVx,3]
								SC1->C1_LOCAL		:= avItenC[nVx,4]
								SC1->C1_CONTA		:= SB1->B1_CONTA
								SC1->C1_DESCRI		:= SB1->B1_DESC
								SC1->C1_FORNECE     := If(Len( avItenC[nVx]) > 5, avItenC[nVx,6], "")
								SC1->C1_SEGUM		:= SB1->B1_SEGUM
								SC1->C1_QTSEGUM	    := ConvUm(SC1->C1_PRODUTO,SC1->C1_QUANT,0,2)
								SC1->C1_IMPORT		:= SB1->B1_IMPORT
								SC1->C1_COTACAO	    := If(SB1->B1_IMPORT = "S","IMPORT","")
								SC1->C1_CLASS		:= "1"
								SC1->C1_GRUPCOM     := MaRetComSC(SB1->B1_COD,UsrRetGrp(),cCodUsr)
								SC1->C1_USER		:= cCodUsr
								SC1->C1_LOJA		:= If(Len(avItenC[nVx]) > 6,avItenC[nVx,7],"")
								SC1->C1_FILENT		:= SC1->C1_FILIAL
								SC1->C1_QTDORIG	    := avItenC[nVx,2]
								SC1->C1_TPOP		:= "F"
								SC1->C1_ORIGEM      := FunName()
								cOrdSer				:= SubStr(cVOP,1,TAMSX3("TJ_ORDEM")[1])
								cCodBem				:= If(!lSolicit, NGSEEK("STJ",cOrdSer,1,"TJ_CODBEM"), NGSEEK("TQB",cOrdSer,1,"TQB_CODBEM"))
								cCodBem				:= If(Empty(cCodBem),cTJ_CODBEM,cCodBem)
								SC1->C1_OBS			:= STR0139+cOrdSer+STR0140+cCodBem  //"MNT OS"##" BEM "  //STR0100
								If Empty(cCustB) .Or. !lNGGERSC2
									cCustB	:= If(!lSolicit, NGSEEK("STJ",cOrdSer,1,"TJ_CCUSTO"), NGSEEK("TQB",cOrdSer,1,"TQB_CCUSTO"))
									cCustB	:= If(Empty(cCustB),cTJ_CCUSTO,cCustB)
								Endif
								SC1->C1_CC := cCustB
								
								If NGCADICBASE("T9_ITEMCTA","A","ST9",.F.)
									SC1->C1_ITEMCTA := NGSEEK("ST9",cCodBem,1,"T9_ITEMCTA")
								EndIf
								
								If lAPROVSC
									SC1->C1_APROV := IIf(MaVldSolic(avItenC[nVx,1],/*aGrupo*/,/*cUser*/,.F.),"L","B")
								EndIf

								SC1->(MsUnlock())

								If NGIFDBSEEK("SB2",SC1->C1_PRODUTO+SC1->C1_LOCAL,1)
									DbSelectArea("SB2")
									RecLock("SB2",.F.)
									SB2->B2_SALPEDI += SC1->C1_QUANT
									SB2->(MsUnlock())
								EndIf

								//--------------------------------------
								// Envia e-mail na inclusao de SC's
								//--------------------------------------
								MEnviaMail( "035",{ SC1->C1_NUM })

							EndIf

						EndIf

						If lRet

							/*-----------------------------------------+
							| Gravação dos campos TL_NUMSC e TL_ITEMSC |
							+-----------------------------------------*/
							dbSelectArea( 'STL' )
							dbSetOrder( 4 ) // TL_FILIAL + TL_ORDEM + TL_PLANO + TL_TIPOREG + TL_CODIGO

							If msSeek( xFilial( 'STL' ) + SubStr( cVOP, 1, 6 ) + STJ->TJ_PLANO + 'P' + avItenC[nVx,1] )
								
								/*-----------------------+
								| Insumo do tipo Produto |
								+-----------------------*/
								While STL->( !EoF() ) .And. STL->TL_ORDEM == SubStr( cVOP, 1, 6 ) .And. AllTrim( STL->TL_CODIGO ) == AllTrim( avItenC[nVx,1] )
									
									If Empty( STL->TL_NUMSC ) .And. Empty( STL->TL_ITEMSC ) .And. AllTrim( STL->TL_LOCAL ) == AllTrim( avItenC[nVx,4] ) .And.;
										STL->TL_SEQRELA == PadR( '0', TamSX3( 'TL_SEQRELA' )[1] )

										RecLock( 'STL', .F. )
											STL->TL_NUMSC  := SC1->C1_NUM
											STL->TL_ITEMSC := SC1->C1_ITEM
										MsUnlock()

									EndIf

									STL->( dbSkip() )

								End

							ElseIf Len( avItenC[nVx] ) > 7
								
								dbSelectArea( 'STL' )
								dbSetOrder( 1 ) // TL_FILIAL + TL_ORDEM + TL_PLANO + TL_TAREFA + TL_TIPOREG + TL_CODIGO

								If msSeek( xFilial( 'STL' ) + SubStr( cVOP, 1, 6 ) + STJ->TJ_PLANO + avItenC[nVx,8] + 'T' + AllTrim( avItenC[nVx,5] ) )
									
									/*------------------------+
									| Insumo do tipo Terceiro |
									+------------------------*/
									While STL->( !EoF() ) .And. STL->TL_ORDEM == SubStr( cVOP, 1, 6 ) .And. AllTrim( STL->TL_CODIGO ) == AllTrim( avItenC[nVx,5] )
										
										//Condição para atuação na alteração de um insumo do tipo terceiro de mesma quantidade/fornecedor/tarefa
										If Empty( STL->TL_NUMSC ) .And. Empty( STL->TL_ITEMSC ) .And. AllTrim( avItenC[nVx,8] ) == Alltrim( STL->TL_TAREFA ) .And.;
											STL->TL_SEQRELA == PadR( '0', TamSX3( 'TL_SEQRELA' )[1] )

											RecLock( 'STL', .F. )
												STL->TL_NUMSC  := SC1->C1_NUM
												STL->TL_ITEMSC := SC1->C1_ITEM
											MsUnLock()

										EndIf

										STL->( dbSkip() )

									End

								EndIf

							EndIf

							// Ponto de entrada para modificações após a inclusão da SC1
							If lMT650C1
								ExecBlock("MT650C1",.F.,.F.)
							EndIf

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	Next nVx

	If lExecSC .And. aRetSC[1] .And. SuperGetMv( 'MV_NGINTER', 'N' ) == 'M'

		lRet := NGMUReques( SC1->( RecNo() ), 'SC1', .F., nOption )

	EndIf

	cNumSC1 := Space(Len(SC1->C1_NUM))
	RestArea(aAreaAn)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGUSATARPAD³ Autor ³In cio Luiz Kolling    ³ Data ³16/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se utiliza tarefa padrao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.f. - Nao usa                                                ³±±
±±³          ³.t. - Usa                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGUSATARPAD()
	Local lRetPad := .f.,aAreaTp := GetArea()
	If NGCADICBASE("TT9_TAREFA","A","TT9",.F.) .And. GetNewPar("MV_NGTARGE","2") = "1"
		lRetPad := .t.
	Endif
	RestArea(aAreaTp)
Return lRetPad

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGNTARPAPRA³ Autor ³In cio Luiz Kolling    ³ Data ³16/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca a descricao da tarefa padrao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cvTAR - Codigo da tarefa padrao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³cDescTar - Descricao da tarefa padrao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGNTARPADRA(cvTAR)
	Local aAreaOld := GetArea(),cDescTar := Space(Len(ST5->T5_DESCRIC))
	lLEDESTAR      := .T. // Nao mexer nesta variavel..
	If NGUSATARPAD()
		cDescTar := NGSEEK("TT9",cvTAR,1,"TT9_DESCRI")
		If !Empty(cDescTar)
			lLEDESTAR := .f. // Nao mexer nesta variavel..
		Endif
	Endif
	RestArea(aAreaOld)
Return If(Empty(cDescTar),Space(Len(ST5->T5_DESCRIC)),cDescTar)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGGTARPAPRA³ Autor ³In cio Luiz Kolling    ³ Data ³16/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava a tarefa padrao vindo da manutencao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cvTAR - Codigo da tarefa padrao                              ³±±
±±³          ³cvDES - Descricao da tarefa padrao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGGTARPADRA(cvTAR,cvDES)
	Local aAreaOld := GetArea()
	If NGUSATARPAD()
		If !NGIFDBSEEK("TT9",cvTAR,1)
			RecLock("TT9",.T.)
			TT9->TT9_FILIAL := Xfilial("TT9")
			TT9->TT9_TAREFA := cvTAR
			TT9->TT9_DESCRI := cvDES
			TT9->(MsUnlock())
		Endif
	Endif
	RestArea(aAreaOld)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGVTART5  ³ Autor ³Vitor Emanuel Batista  ³ Data ³16/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica a existencia do codigo da Tarefa informado nas      ³±±
±±³          ³Manutencoes, retornando .T. caso exista nas tabelas ST5 e TP5³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cTAR - Codigo da tarefa padrao                   -Obrigatorio³±±
±±³          ³lHelp - Mostra help caso haja manutencoes com o codigo infor.³±±
±±³          ³bCondic - Bloco para validar ST5 e TP5                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³.T. - Indica que existe / .F. - Indica que nao existe        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGVTART5(cTAR,lHelp,bCondic)
	Local cAliasQry, cQuery,lRet  := .F.,aArea := GetArea()
	Local cModoTT9 := NGSX2MODO("TT9"),cModoST5 := NGSX2MODO("ST5")
	Local cModoTP5 := NGSX2MODO("TP5")

	Default lHelp   := .t.
	Default bCondic :=  {|| .T.}

	If cModoTT9 = "C" .And. cModoST5 = "E"
		#IFDEF TOP
		cAliasQry := GetNextAlias()
		cQuery := " SELECT R_E_C_N_O_ FROM "+RetSqlName("ST5")
		cQuery += " WHERE T5_TAREFA = " + ValToSql(cTAR) + " AND D_E_L_E_T_ <> '*'"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
		NGSETIFARQUI(cAliasQry)
		While !Eof()
			dbSelectArea("ST5")
			dbGoTo((cAliasQry)->R_E_C_N_O_)
			If Eval(bCondic)
				lRet := .T.
				Exit
			EndIf
			NGDBSELSKIP(cAliasQry)
		EndDo
		(cAliasQry)->(dbCloseArea())
		#ENDIF
	Else
		dbSelectArea("ST5")
		dbSetOrder(5)
		dbSeek(xFilial("ST5")+cTAR)
		While !Eof() .And. xFilial("ST5")+cTAR == ST5->T5_FILIAL+ST5->T5_TAREFA
			If Eval(bCondic)
				lRet := .T.
				Exit
			EndIf
			NGDBSELSKIP("ST5")
		EndDo
	EndIf

	If !lRet
		If cModoTT9 = "C" .And. cModoTP5 = "E"
			#IFDEF TOP
			cAliasQry := GetNextAlias()
			cQuery := " SELECT R_E_C_N_O_ FROM "+RetSqlName("TP5")
			cQuery += " WHERE TP5_TAREFA = " + ValToSql(cTAR) + " AND D_E_L_E_T_ <> '*'"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
			NGSETIFARQUI(cAliasQry)
			While !Eof()
				dbSelectArea("TP5")
				dbGoTo((cAliasQry)->R_E_C_N_O_)
				If Eval(bCondic)
					lRet := .T.
					Exit
				EndIf
				NGDBSELSKIP(cAliasQry)
			EndDo
			(cAliasQry)->(dbCloseArea())
			#ENDIF
		Else
			dbSelectArea("TP5")
			dbSetOrder(4)
			dbSeek(xFilial("TP5")+cTAR)
			While !Eof() .And. xFilial("TP5")+cTAR == TP5->TP5_FILIAL+TP5->TP5_TAREFA
				If Eval(bCondic)
					lRet := .T.
					Exit
				EndIf
				NGDBSELSKIP("TP5")
			EndDo
		EndIf
	EndIf

	If lRet .And. lHelp
		ShowHelpDlg(STR0018,	{STR0141},1,; //"ATENÇÃO"##"Já existem outras manutenções que utilizam o mesmo código da Tarefa informado."
		{STR0142},1) //"Escolha outro código ou exclua a Tarefa informada em todas as manutenções."
	EndIf

	RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGINTEGST5 ³ Autor ³Vitor Emanuel Batista  ³ Data ³26/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica integridade da tabela ST5 com outras tabelas, permi-³±±
±±³          ³tindo a alteracao ou exclusao da Tarefa.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cCodBem  - Codigo do Bem                         -Obrigatorio³±±
±±³          ³cServico - Servico da Manutencao                             ³±±
±±³          ³cSeqRela - Sequencia da Manutencao                           ³±±
±±³          ³cTarefa  - Tarefa da Manutencao                              ³±±
±±³          ³lMsg     - Mostra mensagem se retorno .F.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³.T. - Indica que existe / .F. - Indica que nao existe        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGINTEGST5(cCodBem,cServico,cSeqRela,cTarefa,lMsg)
	Local lRet := .T.
	#IFDEF TOP
	Local nX
	Local cAliasQry, cQuery
	Local aArea := GetArea()
	Local aVerify := {{"STA","TA"},;
	{"STK","TK"},;
	{"STL","TL"},;
	{"STN","TN"},;
	{"STQ","TQ"}}

	Default lMsg := .T.
	If NGIFDBSEEK("ST5",cCodBem+cServico+cSeqRela+cTarefa,1,.f.)
		cAliasQry := GetNextAlias()
		cQuery := " SELECT COUNT(*) AS QUANT FROM " + RetSqlName("STJ") + " STJ "

		For nX := 1 to Len(aVerify)
			cQuery += " LEFT JOIN "+RetSqlName(aVerify[nX][1])+" "+aVerify[nX][1]+" ON "
			cQuery += "   TJ_ORDEM = "+aVerify[nX][2]+"_ORDEM AND TJ_PLANO = "+aVerify[nX][2]+"_PLANO AND "
			cQuery += aVerify[nX][2]+"_TAREFA = "+ValToSql(cTarefa)+" AND "+aVerify[nX][1]+".D_E_L_E_T_ <> '*'
		Next nX

		cQuery += " WHERE TJ_CODBEM = "+ValToSql(cCodBem)+" AND TJ_SERVICO = "+ValToSql(cServico)
		cQuery += "       AND TJ_SEQRELA = "+ValToSql(cSeqRela)+" AND TJ_PLANO >= '000001' AND STJ.D_E_L_E_T_ <> '*' AND ("
		For nX := 1 to Len(aVerify)
			cQuery += aVerify[nX][2]+"_TAREFA IS NOT NULL"
			If nX < Len(aVerify)
				cQuery += " OR "
			EndIf
		Next nX
		cQuery += ")"

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
		NGSETIFARQUI(cAliasQry)
		lRet := !((cAliasQry)->QUANT > 0)
		If !lRet .And. lMsg
			MsgStop(STR0143+AllTrim(cTarefa)+STR0144) //"Não é possível alterar/excluir a Tarefa "##" pois já existe relacionamento desta com outras tabelas."
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aArea)
	#ENDIF
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} NGSTLTAR
Consistência da Tarefa

@param String cPreC: indica Pré chave ( Bem+Serviço+Sequencia ) Obrigatório
para preventiva
@param String cTar - indica Codigo da Tarefa - Obrigatório
@author Inácio Luiz Kolling
@since 21/10/2008
@return Boolean lRet: conforme validação
@version MP11
/*/
//---------------------------------------------------------------------

Function NGSTLTAR( cPreC,cTar )

	Local lRet     := .T.
	Local cNomTarL := Space( Len( ST5->T5_DESCRIC ) )
	Local nSeqTare := 0
	Local nIndex   := 0

	// Executa ponto de entrada para validação da tarefa
	If ExistBlock( "NGUTI01A" )
		lRet := ExecBlock( "NGUTI01A",.F.,.F.,{ cTar } )
	EndIf

	If lRet

		If cTar <> "0" + Replicate( " ",Len( ST5->T5_TAREFA ) - 1 )

			If lCORRET .Or. AllTrim( STJ->TJ_SERVICO ) == "HISTOR"
				If NGUSATARPAD()
					If !ExistCpo( "TT9",cTar )
						lRet := .F.
					EndIf
				Else
					If !ExistCpo( "ST5",cPreC + cTar )
						lRet := .F.
					Else
						nSeqTare := ST5->T5_SEQUENC
					EndIf
				EndIf
			Else
				If !ExistCpo( "ST5",cPreC + cTar )
					lRet := .F.
				Else
					nSeqTare := ST5->T5_SEQUENC
				EndIf
			EndIf
		EndIf

		If lRet
			cNomTarL := NGNOMETAR( cPreC,cTar )

			If NGEXISTVARIA( "M->TQ_NOMTARE" )
				M->TQ_NOMTARE :=  cNomTarL
			EndIf

			If NGEXISTVARIA("M->TL_NOMTAR")
				M->TL_NOMTAR :=  cNomTarL
			EndIf

			If NGEXISTVARIA( "aHeader","A" )

				nColTa := GDFIELDPOS( "TL_NOMTAR",aHeader )
				If nColTa > 0
					aCOLS[n,nColTa] := cNomTarL
				EndIf

				nColTq := GDFIELDPOS("TQ_NOMTARE",aHeader)

				If nColTq > 0
					aCOLS[n,nColTq] := cNomTarL
				EndIf

				nIndex := GDFIELDPOS( 'TQ_SEQTARE', aHeader )
				If nIndex > 0
					If nSeqTare > 0
						aCOLS[n,nIndex] := CValToChar( nSeqTare )
					Else
						aCOLS[n,nIndex] := Space( TamSx3('TQ_SEQTARE')[1] )
					EndIf
				EndIf

				If NGCADICBASE( "TL_PERMDOE","A","STL",.F. ) .And. NGFUNCRPO( "NGMDOEXECU",.F. )

					nColPe := GDFIELDPOS( "TL_PERMDOE" )
					nColTi := GDFIELDPOS( "TL_TIPOREG" )
					nColTc := GDFIELDPOS( "TL_TAREFA" )
					If ( !Empty( aCols ) .And. nColPe > 0  .And. nColTi > 0 .And. nColTc > 0 .And. aCOLS[n,nColTi] <> Nil .And. aCOLS[n,nColTi] <> Nil ) ;
					.And.  ( aCOLS[n,nColTi] <> "M" .Or.  aCOLS[n,nColTc] <> M->TL_TAREFA )

						aCOLS[n,nColPe] := 0.00

					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³NGNOMETAR  ³ Autor ³In cio Luiz Kolling    ³ Data ³22/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Busca a descricao da tarefa                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cPreC - Pre-chave (Bem+servico+sequencia)  Obri p/ preventiva³±±
±±³          ³cTar  - Codico tarefa                             Obrigatorio³±±
±±³          ³nTam  - Tamanho do campo                      Não Obrigatorio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGNOMETAR(cPreC,cTar,nTam)

	Local cDescT

	Default nTam := TAMSX3("TT9_DESCRI")[1]

	If IsInCallStack( 'NG410INC' )

		cPrec := M->TJ_CODBEM + M->TJ_SERVICO + M->TJ_SEQRELA

	EndIf

	If ValType(cPreC) == "N"
		cPrec := cValToChar(cPrec)
	EndIf

	If lCORRET .Or. AllTrim( STJ->TJ_SERVICO ) == "HISTOR"
		If NGUSATARPAD()
			cDescT := NGNTARPADRA(cTar)
		Else
			cDescT := NGSEEK("ST5",cPreC+cTar,1,"T5_DESCRIC")
		Endif
	Else
		cDescT := NGSEEK("ST5",cPreC+cTar,1,"T5_DESCRIC")
	Endif

	If Empty(cDescT) .And. cTar == "0"+Replicate(" ",TAMSX3("T5_TAREFA")[1]-1)
		cDescT := If(Empty(cDescT),STR0145,cDescT)
	EndIf

	cDescT := SUBSTR( cDescT, 1, nTam)

Return cDescT

//--------------------------------------------------------------------------------------------------
/*/{Proteus.doc} NGFOLDTAR
Consistencia na alteracao e/ou exclusao da tarefa.
@type function

@author Inácio Luiz Kolling
@since  13/03/2009

@sample NGFOLDTAR( 'E', 'TP' )

@param  cTipC , Caracter, Indica se o processo é alteração ou exclusão.
@param  cPreA , Caracter, Indica o prefixo do arquivo de consistencia.
@return Lógico, Define se o processo foi executado com êxito.
/*/
//------------------------------------------------------------------------------------------------
Function NGFOLDTAR( cTipC, cPreA )

	Local nFor   := 0
	Local cMensa := Space( 1 )
	Local cSubP  := IIf( cPreA == 'P', 'TP', 'ST' )
	Local lTipC  := IIf( cTipC == 'A', IIf( Readvar() == 'M->T5_TAREFA' .Or. Readvar() == 'M->TP5_TAREFA', .T., .F. ), .T. )

	If !Empty( aCols[n,nTAREFA] ) .And. lTipC

		For nFor := 1 To Len( aSVCOLS[2] )

			If !aTail( aSVCOLS[2,nFor] )

				// Valida se a tarefa depende ou é dependencia de outra tarefa.
				If aCols[n,nTAREFA] == aSVCOLS[2,nFor,nTARM] .Or. ( nDEPEND > 0 .And. aCols[n,nTAREFA] == aSVCOLS[2,nFor,nDEPEND] )
					cMensa := 'M'
					Exit
				EndIf

			EndIf

		Next nFor

		If Empty(cMensa)
			For nFor := 1 To Len(aSVCOLS[3])
				If !Atail(aSVCOLS[3,nFor])
					If aCols[n,nTARG] = aSVCOLS[3,nFor,nTARG]
						cMensa := "G"
						Exit
					Endif
				Endif
			Next nFor
		Endif

		If Empty(cMensa)
			For nFor := 1 To Len(aSVCOLS[4])
				If !Atail(aSVCOLS[4,nFor])
					If aCols[n,nTARG] = aSVCOLS[4,nFor,nTARG]
						cMensa := "H"
						Exit
					Endif
				Endif
			Next nFor
		Endif

		If !Empty(cMensa)
			MsgInfo(STR0146+" "+NGSX2NOME(cSubP+cMensa),STR0005)
			If cTipC = "A"
				aCOLS[n][nDESCRI] := cDesTar
			EndIf
			Return .F.
		EndIf
	EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGFOLDESM   ³ Autor ³In cio Luiz Kolling   ³ Data ³13/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia para desmarcar tarefa na manutencao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nCTar - Indica a coluna do aCols das tarefas         - Obrig.³±±
±±³          ³nTar1 - Codigo da tarefa para desmacra               - Obrig.³±±
±±³          ³nTar2 - Codigo da tarefa para desmacra (Dependecia)  - N.Ori.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120, MNTA180                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGFOLDESM(nCTar,nTar1,nTar2)
	Local cCodT := Space(len(ST5->T5_TAREFA))
	If !Empty(aCols[n,nCTar])
		If Atail(aCols[n])
			nPosT := aSCAN(aSVCOLS[1],{|x| x[nCTar] == nTar1})
			If nPosT > 0
				If Atail(aSVCOLS[1,nPosT])
					cCodT := nTar1
				Endif
			Endif
			If Empty(cCodT) .And. ValType(nTar2) == 'C' //A variável virá preenchida com um caracter quando a função for chamada pelo folder de dependência
				nPosT := aSCAN(aSVCOLS[1],{|x| x[nCTar] == nTar2})
				If nPosT > 0
					If Atail(aSVCOLS[1,nPosT])
						cCodT := nTar2
					Endif
				Endif
			Endif
		Endif
		If !Empty(cCodT)
			MsgInfo(STR0147+" "+cCodT+" "+STR0148,STR0005)
			Return .f.
		Endif
	Endif
Return .t.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGJAMANUNICA³ Autor ³Inacio Luiz Kolling   ³ Data ³17/12/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se ja foi liberada a manutencao unica               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cCodBem  = Codigo do Bem                      - Obrigatorio  ³±±
±±³          ³cCodSer  = Codigo do servico                  - Obrigatorio  ³±±
±±³          ³cSeqRel  = Sequencia da manutencao            - Obrigatorio  ³±±
±±³          ³lSaida   = Indica a saida via tela            - Nao Obrigat. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.t.,.f. ou um vetor [1] = .t.,.f.  [2] = mensagem -> lSaida  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGJAMANUNICA(cCodBem,cCodSer,cSeqRel,lSaida)
	Local lTelaS := If(lSaida = Nil,.f.,lSaida),lJaunica := .f.
	Local cMenJM := Space(1),aAreaJM := GetArea(),cAliasQry,cQuery
	Local cOrdJM,cPlaJM,cArqJM := Space(3)
	Store Space(Len(stj->tj_ordem)) To cOrdJM,cPlaJM

	cAliasQry := GetNextAlias()
	cQuery := " SELECT TJ_ORDEM,TJ_PLANO FROM "+RetSqlName("STJ")
	cQuery += " WHERE TJ_FILIAL = '" + Xfilial("STJ") +"'"
	cQuery += " And TJ_CODBEM = '" + cCodBem + "'"
	cQuery += " And TJ_SERVICO = '" + cCodSer + "'"
	cQuery += " And TJ_SEQRELA = '" + cSeqRel + "'"
	cQuery += " And TJ_SITUACA = 'L' And TJ_TIPOOS = 'B' And D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
	NGSETIFARQUI(cAliasQry)
	While !Eof()
		lJaunica := .t.
		cOrdJM   := (cAliasQry)->TJ_ORDEM
		cPlaJM   := (cAliasQry)->TJ_PLANO
		cArqJM   := "STJ"
		Exit
		dbSkip()
	EndDo
	(cAliasQry)->(dbCloseArea())

	If !lJaunica
		cAliasQry := GetNextAlias()
		cQuery := " SELECT TS_ORDEM,TS_PLANO FROM "+RetSqlName("STS")
		cQuery += " WHERE TS_FILIAL = '" + Xfilial('STS') + "'"
		cQuery += " And TS_CODBEM = '" + cCodBem + "'"
		cQuery += " And TS_SERVICO = '" + cCodSer + "'"
		cQuery += " And TS_SEQRELA = '" + cSeqRel + "'"
		cQuery += " And TS_SITUACA = 'L' And TS_TIPOOS = 'B' And D_E_L_E_T_ <> '*'"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
		NGSETIFARQUI(cAliasQry)
		While !Eof()
			lJaunica := .t.
			cOrdJM   := (cAliasQry)->TS_ORDEM
			cPlaJM   := (cAliasQry)->TS_PLANO
			cArqJM   := "STS"
			Exit
			dbSkip()
		EndDo
		(cAliasQry)->(dbCloseArea())
	Endif

	If lJaunica
		cMenJM := STR0149+" "+Alltrim(NGRETTITULO("TF_PERIODO"))+"  ( "+NGRETSX3BOX("TF_PERIODO","U")+" ),"+CRLF
		cMenJM += STR0150+CRLF+STR0151+"..: "+cOrdJM+"  "+STR0152+"..: "+cPlaJM+CRLF
		cMenJM += STR0153+" "+Alltrim(NGSX2NOME(cArqJM))+" ( "+cArqJM+" )"
		If lTelaS
			MsgInfo(cMenJM,STR0005)
		Endif
	Endif

	RestArea(aAreaJM)
Return If(lTelaS,lJaunica,{lJaunica,cMenJM})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGPERMDOEXE³ Autor ³ Inacio Luiz Kolling   ³ Data ³08/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consiste o percentual de execucao de mao-de-obra             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cOrdem   - Numero de ordem de servico          - Obrigatorio ³±±
±±³          ³nPerc    - Percentual informado                - Obrigatorio ³±±
±±³          ³cTareI   - Tarefa do insumo                    - Obrigatorio ³±±
±±³          ³nRecSTL  - Registro logico                     - Nao Obrigat.³±±
±±³          ³lSaida   - Saida via tela                      - Nao Obrigat.³±±
±±³          ³avGdados - Getdados que nao esta no STL        - Nao Obrigat.³±±
±±³          ³vvPosG   - Vetor onde:                         - Nao Obrigat.³±±
±±³          ³             [1] - Coluna do tipo do insumo                  ³±±
±±³          ³             [2] - Coluna do percentual MDO                  ³±±
±±³          ³             [3] - Coluna do item para na comparar           ³±±
±±³          ³             [4] - Numero da ordem de servico                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.f.,.t.  - lSaida = .t., vRetPe                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NGMDOEXECU e/ou GENERICO                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPERMDOEXE(cOrdem,nPerc,cTareI,nRecSTL,lSaida,avGdados,vvPosG)
	Local vRetPe := {.t.,"  ",0.00},aAreaEs := GetArea(),nPercSTL := 0.00
	Local lTelaS := If(lSaida = Nil,.t.,lSaida),nz := 0

	If avGdados <> Nil
		aGdados := Aclone(avGdados)
	Endif
	If vvPosG <> Nil
		vPosG := Aclone(vvPosg)
	Endif

	lFilSTL := If(Type("ccondSTL") <> 'U',.t.,.f.)
	If lFilSTL
		DbSelectArea("STL")
		Set Filter To
	Endif

	If nPerc < 0 .Or. nPerc > 100
		vRetPe := {.f.,STR0154+" "+STR0156,nPercSTL}
	Else
		If Type("aHoBrw6") = "A" .And. Type("oBrw6") = "O"
			// MNTA435
			aGdados := Aclone(aCOLS)
			vPosG   := {GDFIELDPOS("TL_TIPOREG",aHoBrw6),GDFIELDPOS("TL_PERMDOE",aHoBrw6),GDFIELDPOS("TL_TAREFA",aHoBrw6) ,oBrw6:oBrowse:nAt}

		ElseIf Type("cPROGRAMA") = "C" .And. cPROGRAMA  = "NG400PADRA"
			// FECHAMENTO PELO PADRAO
			aGdados := Aclone(aCOLS)
			vPosG   := {GDFIELDPOS("TL_TIPOREG"),GDFIELDPOS("TL_PERMDOE"),GDFIELDPOS("TL_TAREFA") ,n}

		ElseIf NGIFDBSEEK("STL",cOrdem,1)  .And. nPerc > 0
			While !Eof() .And. stl->tl_filial = Xfilial("STL") .And. ;
			stl->tl_ordem = cOrdem
				If nRecSTL <> Nil .And. Recno() = nRecSTL
					NGDBSELSKIP("STL")
					Loop
				Endif
				If stl->tl_seqrela <> "0  " .And. stl->tl_tiporeg = "M"  .And. stl->tl_tarefa = cTareI
					nPercSTL := Max(nPercSTL,stl->tl_permdoe)
				Endif
				NGDBSELSKIP("STL")
			End
		Endif
	Endif

	If vRetPe[1]
		If Type("aGdados") = "A"  .And. Type("vPosG") = "A"
			For nz := 1 To Len(aGdados)
				If !Atail(aGdados[nz])
					If Len(vPosG) >= 5
						If aGdados[nz,vPosG[5]] <> cOrdem
							Loop
						Endif
					Endif
					If aGdados[nz,vPosG[1]] = "M" .And. nz <> vPosG[4] .And. aGdados[nz,vPosG[3]] = cTareI
						nPercSTL := Max(nPercSTL,aGdados[nz,vPosG[2]])
					Endif
				EndIf
			Next nz
		Endif
		If !Empty(nPercSTL) .And. nPerc < nPercSTL
			vRetPe := {.f.,Upper(STR0156)+" "+STR0157+" "+Alltrim(cTareI)+" "+STR0158+" ";
			+Alltrim(Str(nPercSTL,6,2))+"% "+STR0159+" "+Alltrim(Str(nPerc,6,2))+"% "+Chr(13);
			+STR0160+" "+STR0161+" "+Alltrim(Str(nPercSTL,6,2))+"% ",nPercSTL}
		EndIf
	EndIf

	If !vRetPe[1]
		If lTelaS
			MsgInfo(vRetPe[2],STR0005)
		Endif
	Endif

	If lFilSTL
		bFiltraBrw := {|| FilBrowse("STL",@aIndSTL,@condSTL) }
		Eval(bFiltraBrw)
	Endif

	RestArea(aAreaEs)
Return If(lTelaS,vRetPe[1],vRetPe)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGMDOEXECU ³ Autor ³ Inacio Luiz Kolling   ³ Data ³08/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consiste o percentual de execucao de mao-de-obra             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPerMDO  - Percentual informado                - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERVACAO³Deve estar posicionado corretamente na ordem de servico      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³DICIONARIO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGMDOEXECU(nPerMDO,cTareM,aGdados,vPosG)
	Local nRecuso := 0
	If Type("Altera") <> "U" .And. Altera
		DbSelectArea("STL")
		nRecuso := Recno()
	Endif
Return NGPERMDOEXE(STJ->TJ_ORDEM,nPerMDO,cTareM,If(nRecuso > 0,nRecuso,),,aGdados,vPosG)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGDISP   ³ Autor ³ NG INFORMATICA        ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atribui um valor a uma variavel do achoice                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ARG1 -> nome da variavel                                   ³±±
±±³          ³ ARG2 -> nome da variavel                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGDISP(Arg1,Arg2)
	aTELA[1][4] := Arg2
	&Arg1. := Arg2
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VIRTINSUMO³ Autor ³ Inacio Luiz Kolling   ³ Data ³ 02/08/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ visualiza do insumo                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VIRTINSUMO(cTIPOREG,cCODIGO)
	Local _RETOR  := SPACE(20)

	If Empty(cTIPOREG) .or. Empty(cCODIGO)
		Return Space(20)
	Endif

	If cTIPOREG == 'E'      // especialista
		ST0->(DbSeek( xFilial('ST0') + Left(cCODIGO, LEN(ST0->T0_ESPECIA)) ))
		_RETOR := ST0->T0_NOME
	ElseIf cTIPOREG == 'M'  // funcionario
		ST1->(DbSeek( xFilial('ST1') + Left(cCODIGO, LEN(ST1->T1_CODFUNC)) ))
		_RETOR := ST1->T1_NOME
	ElseIf cTIPOREG == 'P' // produto
		SB1->(DbSeek( xFilial('SB1') + Left(cCODIGO, LEN(SB1->B1_COD)) ))
		_RETOR := SB1->B1_DESC
	ElseIf cTIPOREG == 'F' // ferramenta
		SH4->(DbSeek( xFilial('SH4') + Left(cCODIGO, LEN(SH4->H4_CODIGO)) ))
		_RETOR := SH4->H4_DESCRI
	ElseIf cTIPOREG == 'T' // terceiro
		SA2->(DbSeek( xFilial('SA2') + Left(cCODIGO, LEN(SA2->A2_COD)) ))
		_RETOR := SA2->A2_NOME
	endif
Return _RETOR

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VIRTIPREG ³ Autor ³ Inacio Luiz Kolling   ³ Data ³ 02/08/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ visualiza       tipo do insumo                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VIRTIPREG(VTIPOREG)
	Local _RETOR := SPACE(13)

	If VTIPOREG == 'E'
		_RETOR := STR0162 //"ESPECIALIDADE"
	ElseIf VTIPOREG == 'M'
		_RETOR := STR0163 //"FUNCIONARIO  "
	ElseIf VTIPOREG == 'P'
		_RETOR := STR0164 //"PRODUTO      "
	ElseIf VTIPOREG == 'F'
		_RETOR := STR0165 //"FERRAMENTA   "
	ElseIf VTIPOREG == 'T'
		_RETOR := STR0166 //"TERCEIROS    "
	Endif
return _RETOR

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TIPREGBRW ³ Autor ³ Inacio Luiz Kolling   ³ Data ³ 29/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra o nome do insumo no BROWSE                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TIPREGBRW(cTIPREG)
	Local _RETOR := SPACE(13)

	If cTIPREG == 'E'
		_RETOR := STR0162 //"ESPECIALIDADE"
	ElseIf cTIPREG == 'M'
		_RETOR := STR0163 //"FUNCIONARIO  "
	ElseIf cTIPREG == 'P'
		_RETOR := STR0164 //"PRODUTO      "
	ElseIf cTIPREG == 'F'
		_RETOR := STR0165 //"FERRAMENTA   "
	ElseIf cTIPREG == 'T'
		_RETOR := STR0166 //"TERCEIROS    "
	Endif
Return _RETOR

//---------------------------------------------------------------------
/*/{Protheus.doc} NGQUANTIHOR
Calcula a quantidade baseada nas datas e horas (calendario)

@param cVTIP, string, Tipo do insumo
@param cVUNID, string, Unidade do insumo
@param dDINI, date, Data inicio
@param cHINI, string, Hora inicio
@param dDFIM, date, Data fim
@param cHFIM, string, Hora fim
@param cUCALE, string, Usa calendario
@param cCALEN, string, Codigo do calendario
@author Inácio Luiz Kolling
@since 10/02/2004
/*/
//---------------------------------------------------------------------
Function NGQUANTIHOR(cVTIP,cVUNID,dDINI,cHINI,dDFIM,cHFIM,cUCALE,cCALEN, cPARUIND)

	Default cPARUIND := GETMV("MV_NGUNIDT")

	If cVTIP <> 'P'
		If cVTIP = 'M'
			If cUCALE <> NIL .And. cUCALE = 'S'
				nQTDHORA := NGCALENHORA(dDINI,cHINI,dDFIM,cHFIM,cCALEN)
				nQTDHORA := If(cPARUIND = "D",NGCONVERHORA(nQTDHORA,"S","D"),nQTDHORA)
			Else
				nQTDHORA := If(cPARUIND = "D",NGCALCH100(dDINI,cHINI,dDFIM,cHFIM);
				,NGCALCH060(dDINI,cHINI,dDFIM,cHFIM))
			Endif
		Else
			nQTDHORA := If(cPARUIND = "D",NGCALCH100(dDINI,cHINI,dDFIM,cHFIM);
			,NGCALCH060(dDINI,cHINI,dDFIM,cHFIM))
		Endif
	Endif

Return nQTDHORA


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGVALQUANT ³ Autor ³In cio Luiz Kolling   ³ Data ³10/02/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia da quantidade para tipo hora                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVTIPOR  - Tipo de insumo                       -Obrigatorio³±±
±±³          ³cVUNID   - Unidade                                   II     ³±±
±±³          ³nVQUANT  - Quantidade                                II     ³±±
±±³          ³lSoluca  - Indica de informa a solucao          -Nao Obrig. ³±±
±±³          ³cUsaCal  - Indica se usa calendario             -Nao Obrig. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function NGVALQUANT(cVTIPOR,cVUNID,nVQUANT,lSoluca,cUsaCal)
	Local c1LI    := chr(13)+chr(10)
	Local c2LI    := chr(13)+chr(13)+chr(10)
	Local cMENSAH := Space(10)
	Local lMostSo := If(lSoluca = Nil,.t.,lSoluca)
	Local lUsaClo := If(cUsaCal = Nil,.f.,If(cUsaCal = 'N',.f.,.t.))

	If cVTIPOR <> "P"
		If Alltrim(cVUNID) = "H"
			cPARUIND := AllTrim(GETMV("MV_NGUNIDT"))
			IF cPARUIND <> "D" .Or. lUsaClo
				cQUANT := Str(nVQUANT,9,2)
				nPOSPO := At(".",cQUANT)
				If nPOSPO > 0
					cDECIQUA := Substr(cQUANT,nPOSPO+1,2)
					If cDECIQUA > "59"
						If !lUsaClo
							cMENSAH := STR0167+STR0168+" "+STR0169+" "+STR0170+If(lMostSo,c2LI+STR0173+c1LI+STR0172," ")
						Else
							cMENSAH := STR0167+" "+STR0171+" "+STR0170+If(lMostSo,c2LI+STR0173+c1LI+STR0172," ")
						Endif
						MsgInfo(cMENSAH,STR0005)
					Endif
				Endif
			Endif
		Endif
	Endif
Return If(Empty(cMENSAH),.T.,.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGTQUATINS³ Autor ³ Elisangela Costa      ³ Data ³ 07/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz o tratamento da quantidade de insumo (tipo de unidade,  ³±±
±±³          ³tipo de hora, tratamento do calendario quando mao de obra)  ³±±
±±³          ³para insumos do  tipo M=MAO DE OBRA, E=ESPECIALIDADE,       ³±±
±±³          ³F=FERRAMENTA e T=TERCEIRO                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCODINS  = Codigo do Insumo           -Obrigatorio          ³±±
±±³          ³cTIPOINS = Tipo do Insumo             -Obrigatorio          ³±±
±±³          ³cUSACALE = Indicacao de utilizacao de calendario quando     ³±±
±±³          ³           mao de obra                -obrigatorio          ³±±
±±³          ³nQUANTID = Quantidade aplicada        -obrigatorio          ³±±
±±³          ³cTIPOHOR = Tipo de Hora               -obrigatorio          ³±±
±±³          ³dDATAINI = Data Inicio aplicacao ins  -obrigatorio          ³±±
±±³          ³cHORINIC = Hora Inicio aplicacao ins. -obrigatorio          ³±±
±±³          dDataFim = Data Fim aplicacao ins.    -obrigatorio          ³±±
±±³          ³cHORAFIM = Hora Fim aplicacao ins.    -obrigatorio          ³±±
±±³          ³cUNIDADE = Unidade de medida          -obrigatorio          ³±±
±±³          ³cEMP     = Empresa de Troca           -opcional             ³±±
±±³          ³cFIL     = Filial de Troca            -opcional             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aVETQUANT = [1] Hora decimal(Ex: 01:30 retorna 1,50) numer. ³±±
±±³          ³            [2] Hora em formato decimal mais como hora      ³±±
±±³          ³                (Ex: 1:30 retorna 1,30) em numerico         ³±±
±±³          ³            [3] Hora sexagesimal (Ex: 1,50 retorna 01:30)   ³±±
±±³          ³            em caracter                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGTQUATINS(cCODINS,cTIPOINS,cUSACALE,nQUANTID,cTIPOHOR,dDATAINI,cHORINIC,dDataFim,cHORAFIM,cUNIDADE,cEMP,cFIL)
	Local nHORDEC  := 0.0     //Hora em decimal 1,50  (numerico)
	Local nHORANUM := 0.0     //Hora em numerico 1,30 (numerico)
	Local cHORASE  := "00:00" //Hora em formato sexagesimal 01:30 (Caracter)
	Local vVETHODH := {}, aVETQUANT := {}
	Local cCALENDIN

	cCALENDIN := NGSEEK("ST1",Substr(cCODINS,1,6),1,"T1_TURNO",cFIL,cEMP,cEMP)

	If cTIPOINS <> "P"
		If cUNIDADE = "H"
			If cTIPOHOR = "S"

				vVETHODH := NGRETHORDDH(nQUANTID)
				nHORDEC  := vVETHODH[2]
				nHORANUM := nQUANTID
				cHORASE  := vVETHODH[1]

			Else

				nHORDEC  := nQUANTID
				nHORANUM := NGRHODSEXN(nQUANTID,cTIPOHOR,cEMP)
				cHORASE  := NTOH(nQUANTID)

			EndIf
		Else
			If cUSACALE == "S"  .And. cTIPOINS == "M"

				cCALENDIN := NGSEEK("ST1",Substr(cCODINS,1,6),1,"T1_TURNO",cFIL,cEMP,cEMP)
				nHORA := NGCALENHORA(dDATAINI,cHORINIC,dDataFim,cHORAFIM,cCALENDIN,cFIL)

				vVETHODH := NGRETHORDDH(nHORA)
				nHORDEC  := vVETHODH[2]
				nHORANUM := nHORA
				cHORASE  := vVETHODH[1]

			Else

				nHORA := NGCALCH100(dDATAINI,cHORINIC,dDataFim,cHORAFIM)
				nHORDEC  := nHORA
				nHORANUM := NGRHODSEXN(nHORA,"D")
				cHORASE  := NTOH(nHORA)

			EndIf
		EndIf
		aVETQUANT := {nHORDEC,nHORANUM,cHORASE}
	Else
		aVETQUANT := {nQUANTID,nQUANTID,nQUANTID}
	EndIf
Return aVETQUANT

//---------------------------------------------------------------------
/*/{Protheus.doc} NGRHODSEXN
Converte um valor em decimal para horas numerica

@return nHoras = Hora em numerico

@Param nQUANT = Quantidade aplicada		-obrigatorio
@Param cTIPOH = Tipo de Hora				-obrigatorio
@Param cEMP   = Empresa					-opcional
@sample
NGRHODSEXN()

@author Elisangela Costa
@since 07/12/06
/*/
//---------------------------------------------------------------------
Function NGRHODSEXN(nQUANT,cTIPOH,cEMP)
	Local nHORAS := 0
	Local nTIPOHXY := If(Empty(cTIPOH),AllTrim(GetNewPar("MV_NGUNIDT")),cTIPOH)
	If nTIPOHXY = "D"
		cHoraa := MtoH(nQUANT*60)
		cHORAI := Alltrim (cHoraa)
		nPOSTI := At (':',cHORAI)
		cHORI  := Substr(cHORAI,1,nPOSTI-1)
		cMINI  := Substr(cHORAI,nPOSTI+1,2)
		nHORAS := Val(cHORI+"."+cMINI)
	Else
		nHORAS := nQUANT
	Endif
Return nHoras

//---------------------------------------------------------------------
/*{Protheus.doc} NgHrFunBl()
Função que retorna a quantidade de horas por Bloqueio de Funcionário,
ou seja, a quantidade de horas que o funcionário encontra-se indisponível.

@param cCodFun --> Código do Funcionário.
@param dDataIni -> Data inicial do bloqueio.

@return nHrsFuBlo

@Author: Elynton Fellipe Bazzo
@Since:  21/05/2014
//---------------------------------------------------------------------
*/
Function NgHrFunBl( cCodFun,dDataIni )

	Local aArea := GetArea() //Salva o ambiente ativo.
	Local lDobleHr := .T.

	nHrsFuBlo := 0

	DBSelectArea( "ST1" )
	DBSetOrder( 01 ) //T1_FILIAL+T1_CODFUNC
	DBSeek( xFilial( "ST1" )+ PadR( cCodFun, TAMSX3( "TL_CODIGO" )[1] ), .T. )
	DBSelectArea( "STK" )
	DBSetOrder( 02 )
	DBSeek( xFilial( "STK" )+ cCodFun + DTOS( dDataIni )   )
	While !Eof() .And. STK->TK_CODFUNC == cCodFun .And. STK->TK_DATAINI == dDataIni

		If ST1->T1_DTFIMDI >= dDataIni .Or. Empty( ST1->T1_DTFIMDI )

			//Quantidade de horas que o funcionário encontra-se bloqueado no dia.
			If STK->TK_DATAINI <> STK->TK_DATAFIM //Calcula o tempo entre duas data,hora e calendario.
				If Empty( nHrInicio )
					nHrInicio	+= SubHoras( "24:00",STK->TK_HORAINI )
					nHrsFuBlo	+= nHrInicio
					nHrFinal	:= SubHoras( STK->TK_HORAFIM,"00:00" )
					lDobleHr	:= .F.
				EndIf
			Else
				nHrsFuBlo += SubHoras( STK->TK_HORAFIM,STK->TK_HORAINI ) //Subtrai a hora fim com a inicial.
			EndIf

			nTotHrBlo	:= nHrsFuBlo // Total de horas de bloqueio por funcionário.
			lVerBloq	:= .T. //Variável que verifica se existe bloqueio.

		EndIf

		DBSelectArea( "STK" )
		DBSkip() //Pula registro da STK.

	End While //Fim do While.

	If lDobleHr
		nHrsFuBlo	+= nHrFinal
		nHrFinal	:= 0
		lDobleHr	:= .F.
	EndIf

	RestArea( aArea ) //Restaura o ambiente salvo anteriormente.

Return nHrsFuBlo

//---------------------------------------------------------------------
/*/{Protheus.doc} NGGERASC7()
Função para gerar Pedido de Compra.

@author Thiago Olis Machado
@since 12/01/2007

@param cFornecedor , Caracter , Código do Fornecedor
@param cLoja       , Caracter , Loja
@param cCondicao   , Caracter , Condicao de Pagamento
@param cFilEnt     , Caracter , Filial de recebimento
@param aItens      , Array    , Itens do pedido, no formato:
								[1] Produto
								[2] Unidade de Medida
								[3] Quantidade
								[4] Preco Unitario
@param cOrigem     , Caracter , Nome da rotina de origem (Ex: "MNTA650")
@param nOpcAuto    , Numérico , Operação que será realizada (incluir/excluir)

@return boolean, pedido de compra gerado com sucesso,
/*/
//---------------------------------------------------------------------
Function NgGeraSC7(cFornecedor,cLoja,cCondicao,cFilEnt,aItens,cOrigem,nOpcAuto)

	Local i,aCab := {},aItem := {},nCont := 1, lRet := .T.
	Local cFEntr
	Local cNumero := ""
	Local cItemPC := StrZero(nCont,Len(SC7->C7_ITEM))

	//Conteúdo default para evitar inconsistência
	Default nOpcAuto := 3

	If nOpcAuto == 3
		cNumero := CriaVar("C7_NUM",.T.)
	ElseIf nOpcAuto == 5
		cNumero := SC7->C7_NUM
	EndIf

	dbSelectArea("SA2")
	dbSetOrder(1) //A2_FILIAL+A2_COD+A2_LOJA
	dbSeek(xFilial("SA2")+cFornecedor+cLoja)
	cFEntr := xFilial("SC7")
	M->C7_FILENT := cFEntr
	aCab:={{"C7_NUM"     ,cNumero  	  ,Nil},; // Numero do Pedido
	{"C7_EMISSAO" ,dDataBase    ,Nil},; // Data de Emissao
	{"C7_FORNECE" ,cFornecedor  ,Nil},; // Fornecedor
	{"C7_LOJA"    ,cLoja	    ,Nil},; // Loja do Fornecedor
	{"C7_COND"    ,cCondicao    ,Nil},; // Condicao de pagamento
	{"C7_CONTATO" ,"           ",Nil},; // Contato
	{"C7_ITEM"    ,cItemPC	    ,Nil},; //Numero do Item
	{"C7_FILENT"  ,cFEntr       ,Nil}}  // Filial Entrega

	//No caso de exclusão não precisa buscar todos os itens
	If nOpcAuto <> 5
		For i:= 1 To Len(aItens)
			NGIFDBSEEK("SB1",aItens[i][1],1)
			DbSelectArea("SC7")
			aAdd(aItem,{{"C7_PRODUTO",aItens[i][1]    ,Nil},; //Codigo do Produto
						{"C7_UM"     ,aItens[i][2]    ,Nil},; //Unidade de Medida
						{"C7_QUANT"  ,aItens[i][3]    ,Nil},; //Quantidade
						{"C7_PRECO"  ,aItens[i][4]    ,Nil},; //Preco
						{"C7_DATPRF" ,dDataBase       ,Nil},; //Data De Entrega
						{"C7_FLUXO"  ,"S"             ,Nil},; //Fluxo de Caixa (S/N)
						{"C7_LOCAL"  ,SB1->B1_LOCPAD  ,Nil},; //Localizacao
						{"C7_CODITE" ,SB1->B1_CODITE  ,Nil},;
						{"C7_CODGRP" ,SB1->B1_GRUPO   ,Nil},;
						{"C7_ORIGEM" ,cOrigem         ,Nil}})

			If Len(aItens[i]) > 4 .And. (aItens[i][5] <> Nil)
				aAdd(aItem[i],{"C7_CC"  ,aItens[i][5]    ,Nil}) //Centro de Custo
			EndIf

			If Len(aItens[i]) > 6 .And. !Empty(aItens[i][7])
				aAdd(aItem[i],{"C7_ITEMCTA"  ,aItens[i][7]    ,Nil}) //Item Contabil
			EndIf

			If Len(aItens[i]) > 7 .And. !Empty(aItens[i][8])
				aAdd(aItem[i],{"C7_CLVL"  ,aItens[i][8]    ,Nil}) //Classe de Valor
			EndIf
			nCont++
		Next i
	EndIf

	If ExistBlock("NGUTIL51")
		aAux := aClone( ExecBlock("NGUTIL51",.F.,.F.,{aCab, aItem}) )
		If Len(aAux) >= 1
			aCab := aClone( aAux[1] )
		EndIf
		If Len(aAux) >= 2
			aItem := aClone( aAux[2] )
		EndIf
	EndIf

	lMsErroAuto := .F.
	MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,nOpcAuto)
	If lMsErroAuto
		lRet := .F.
		DisarmTransaction()
		MostraErro()
	Endif

	//-------------------------------------
	//INTEGRACAO POR MENSAGEM UNICA
	//-------------------------------------
	If lRet .And. AllTrim(GetNewPar("MV_NGINTER","N")) == "M"  //Mensagem Unica
		dbSelectArea("SC7")
		dbSetOrder(01)
		dbSeek(xFilial("SC7") + cNumero)
		lRet := NGMUOrder(SC7->(RecNo()),"SC7",Nil,3,aItem)

		If !lRet
			MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,5)
		EndIf
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGALCVIOLGAR³ Autor ³ In cio Luiz Kolling   ³ Data ³15/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia da violacao da garantia do produto               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cCodBemG = Codigo do bem                                      ³±±
±±³          ³cCodProd = Codigo do produto                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGALCVIOLGAR(cCodBemG,cCodProd)
	Local aAreaGar := GetArea(),lRetGar := .F.
	Local nPosTPZ1 := 0, nPosTPZ2 := 0,nQtdG := 0,nSomaG := 0

	cQuery := "SELECT TPZ_ORDEM,TPZ_PLANO,TPZ_CONGAR,TPZ_LOCGAR,TPZ_SEQREL,Max(TPZ_DTGARA)"
	cQuery += " FROM " + RetSQLName("TPZ")
	cQuery += " WHERE TPZ_FILIAL = '" + xFilial("TPZ") + "'"
	cQuery += " AND TPZ_CODBEM = '" + cCodBemG+"'"
	cQuery += " AND TPZ_CODIGO = '" + cCodProd+"'"
	cQuery += " AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'TPZTMP', .F., .T.)

	dbSelectArea("TPZTMP")
	dbgotop()

	While !Eof()
		If !Empty(TPZTMP->TPZ_CONGAR)
			dbSelectArea("STJ")
			dbsetOrder(1)
			If MSseek(xFilial('STJ')+TPZTMP->TPZ_ORDEM+TPZTMP->TPZ_PLANO)
				nPosTPZ1 := IIf(TPZTMP->TPZ_CONGAR = "1",STJ->TJ_POSCONT,STJ->TJ_POSCON2)
				dbSelectArea("TPZ")
				dbsetOrder(1)
				If MSseek(xFilial('TPZ')+cCodBemG+"P"+cCodProd+TPZTMP->TPZ_LOCGAR+;
				TPZTMP->TPZ_ORDEM+TPZTMP->TPZ_PLANO+TPZTMP->TPZ_SEQREL)
					While !Bof() .And. TPZ->TPZ_FILIAL = xFILIAL("TPZ") .And.;
					TPZ->TPZ_CODBEM = cCodBemG .And. TPZ->TPZ_CODIGO = cCodProd
						If !Empty(TPZ->TPZ_CONGAR)
							nQtdG := TPZ->TPZ_QTDGAR
							dbSelectArea("STJ")
							dbsetOrder(1)
							If MSseek(xFilial('STJ')+TPZ->TPZ_ORDEM+TPZ->TPZ_PLANO)
								nPosTPZ2 := IIf(TPZ->TPZ_CONGAR = "1",STJ->TJ_POSCONT,STJ->TJ_POSCON2)
							Endif
							Exit
						Endif
						DbSkip(-1)
					End
				Endif
			Endif
			If nPosTPZ1 > 0 .And. nPosTPZ2 > 0
				nSomaG := nPosTPZ1 + nQtdG
				If nSomaG > nPoscont2
					lRetGar := .T.
				Endif
			Endif
		Else
			dbSelectArea("TPZ")
			dbsetOrder(1)
			If MSseek(xFilial('TPZ')+cCodBemG+"P"+cCodProd+TPZTMP->TPZ_LOCGAR+;
			TPZTMP->TPZ_ORDEM+TPZTMP->TPZ_PLANO+TPZTMP->TPZ_SEQREL)
				dData1   := TPZ->TPZ_DTGARA
				cLocaliz := TPZ->TPZ_LOCGAR

				DbSkip(-1)
				cLocal1 := TPZ->TPZ_LOCGAR
				If TPZ->TPZ_CODBEM == cCodBem .And. TPZ->TPZ_TIPORE == M->TL_TIPOREG .And.;
				TPZ->TPZ_CODIGO == M->TL_CODIGO
					If TPZ->TPZ_ORDEM <> cOrdem
						cOrdem2 := TPZ->TPZ_ORDEM
						cPlano1 := TPZ->TPZ_PLANO
						If NgVerify("TPZ")
							nSequen := TPZ->TPZ_SEQREL
						Else
							nSequen := TPZ->TPZ_SEQUEN
						EndIf

						dData   := TPZ->TPZ_DTGARA
					Else
						While !Bof() .And. TPZ->TPZ_ORDEM == cOrdem
							DbSkip(-1)
						End
						cOrdem2 := TPZ->TPZ_ORDEM
						cPlano1 := TPZ->TPZ_PLANO
						If NgVerify("TPZ")
							nSequen := TPZ->TPZ_SEQREL
						Else
							nSequen := TPZ->TPZ_SEQUEN
						EndIf
						dData   := TPZ->TPZ_DTGARA
					EndIf
					If cLocaliz == cLocal1
						If TPZ->TPZ_ORDEM <> cOrdem
							If TPZ->TPZ_UNIGAR = "D"
								dData2 := TPZ->TPZ_QTDGAR + dData
								If dData2 > dData1
									lRetGar := .T.
								EndIf
							ElseIf TPZ->TPZ_UNIGAR = "S"
								dData2 := (TPZ->TPZ_QTDGAR * 7) + dData
								If dData2 > dData1
									lRetGar := .T.
								EndIf
							ElseIf TPZ->TPZ_UNIGAR = "M"
								dData2 := (TPZ->TPZ_QTDGAR * 30) + dData
								If dData2 > dData1
									lRetGar := .T.
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Endif
		Endif
		Exit
		dbSelectArea("TPZTMP")
		dbskip()
	End

	dbSelectArea("TPZTMP")
	dbCloseArea()

	RestArea(aAreaGar)
Return lRetGar

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGALCGERCOMP³ Autor ³ In cio Luiz Kolling   ³ Data ³16/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera solicitacao de producao/compras/empenho/bloqueios        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³vOrdA = Codigo da Ordem de servico                            ³±±
±±³          ³vPlaA = Codigo do Plano                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGALCGERCOMP(vOrdA,vPlaA)
	Local aAreaAp := GetArea()
	Local cSeqSTL := If(NgVerify("STL"),'STL->TL_SEQRELA = "0  "','STL->TL_SEQUENC = 0')
	M->TI_PLANO   := vPlaA

	cOP      := vOrdA + "OS001"
	aBLO     := {{},{},{},{},{}}
	lGERAEMP := .T.
	INCLUI   := .T.

	If VAL(vPlaA) == 0
		If GETMV("MV_NGCORPR") <> "S"
			lGERAEMP := .F.
		Endif
	Endif

	dbSelectArea("STJ")
	dbSetOrder(1)
	MSseek(xfilial("STJ")+vOrdA+vPlaA)

	dbSelectArea("ST9")
	dbSetOrder(1)
	MSseek(xfilial("ST9")+STJ->TJ_CODBEM)

	//Gera ordem de Producao para a OS

	If cUsaIntPc == "S"
		cCODPRO  := If(FindFunction("NGProdMNT"), NGProdMNT("M")[1], GetMV("MV_PRODMNT"))
		cOP      := vOrdA + "OS001"

		GERAOP(cCODPRO, 1, cOP, STJ->TJ_DTORIGI,STJ->TJ_DTORIGI)
		//-- Grava os Campos Especificos na OP
		DbSelectArea("SC2")
		RecLock("SC2", .F.)
		SC2->C2_CC      := STJ->TJ_CCUSTO
		SC2->C2_EMISSAO := MNT420DTOP(STJ->TJ_DTMPINI)
		SC2->C2_STATUS  := "U"
		SC2->C2_OBS     := "PLANO "+vPlaA
		SC2->(MsUnlock())
	Endif

	// LE O STL COM OS ITEMS COM SEQUENCIA 0 E ARMAZENA NA ARRAY OS CAMPOS:

	aARRAYSTL := {}

	DbSelectArea("STL")
	DbSetOrder(1)
	DbSeek(xfilial("STL")+vOrdA+vPlaA)
	nRegSTL := Recno()
	While !Eof() .And. STL->TL_ORDEM == vOrdA .And. STL->TL_PLANO == vPlaA
		If &cSeqSTL
			Aadd(aARRAYSTL,{STL->TL_TIPOREG,STL->TL_CODIGO,STL->TL_QUANTID,;
			STL->TL_QUANREC,STL->TL_DTINICI,STL->TL_HOINICI,;
			STL->TL_DTFIM,STL->TL_HOFIM,STL->TL_TAREFA,;
			STL->TL_LOCAL,STL->TL_CUSTO})
		Endif
		DbSelectArea("STL")
		DbSkip()
	End


	If Len(aARRAYSTL) > 0
		Processa({ |lEnd| MNTA490PT(vPlaA,vOrdA)}, STR0174) //"Aguarde ..Preparando Para Gerar Insumos..."
	Endif

	If Len(aBLO[1]) > 0
		// Efetua o bloqueio de Ferramentas
		Processa({ |lEnd| MNTA490FE(cBEM490) }, STR0175+" "+STR0176 ) //"Aguarde ..Bloqueando Ferramentas..."
	Endif

	If Len(aBLO[2]) > 0
		// Efetua o bloqueio de Mao de Obras (FUNCIONARIO)
		Processa({ |lEnd| MNTA490FU() }, STR0175+" "+STR0177 ) //"Aguarde ..Bloqueando Mao-de-Obra..."
	Endif

	If Len(aBLO[3]) > 0
		// Efetua o bloqueio de Especialistas (FUNCIONARIO)
		Processa({ |lEnd| MNTA490ES() }, STR0175+" "+STR0178 ) //"Aguarde ..Bloqueando Especialidade.."
	Endif

	dbSelectArea("STL")
	dbgoto(nRegSTL)

	If Len(aBLO[4]) > 0
		//Efetua o bloqueio de Produtos

		// Ponto de entrada
		If ExistBlock("NGPRODAL")
			ExecBlock("NGPRODAL",.F.,.F.,{aBLO[4]})
		Else
			If cUsaIntEs == "S"
				Processa({ |lEnd| MNTA490PR() }, STR0175+" "+STR0179 ) //"Aguarde ..Bloqueando Produto e Integra‡Æo.."
			Endif
		Endif
	Endif

	dbSelectArea("STL")
	dbgoto(nRegSTL)

	If Len(aBLO[5]) > 0
		//Gera Solicitacao de compra para terceiros
		// Ponto de entrada
		If ExistBlock("NGTERCAL")
			ExecBlock("NGTERCAL",.F.,.F.,{aBLO[5]})
		Else
			Processa({ |lEnd| MNTA490TE() }, STR0175+" "+STR0180 ) //"Aguarde ..Bloqueando Terceiros.."
		Endif
	Endif

	RestArea(aAreaAp)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGIMTAETOPIN³ Autor ³ Inacio Luiz Kolling   ³ Data ³23/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressão generica dos detalhes da manutenção                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ vBem   - Código do bem                         - Obrigatorio³±±
±±³          ³ vSER    - Código do serviço                      - Obrigatório³±±
±±³          ³ vSEQ    - Código da sequencia                    - Obrigatório³±±
±±³          ³ nPARE  - Indica se imprime as etapas           - Obrigatório³±±
±±³          ³ nPARI   - Indica se imprime os insumos            - Obrigatório³±±
±±³          ³ cFUNCCAB - Nome da função do cabeçalho      - Obrigatório³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Relatórios                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGIMTAETOPIN(vBEM,vSER,vSEQ,nPARE,nPARI,cFUNCCAB)

	Local cDescDep := Posicione( 'SX3', 2, 'TM_NOMEDEP', 'X3Descric()' )

	If NGIFDBSEEK("ST5",vBEM+vSER+vSEQ,1,.F.)
		While !Eof() .And. ST5->T5_FILIAL = xFILIAL("ST5") .And. ST5->T5_CODBEM = vBEM .And.;
		ST5->T5_SERVICO = vSER .And. ST5->T5_SEQRELA = vSEQ

			nRecST5 := Recno()
			cTarefa := ST5->T5_TAREFA
			&(cFUNCCAB+"(2)")
			@ Li,008 PSay Replicate("-",50)+STR0181+Replicate("-",48) //-.. TAREFA--..
			&(cFUNCCAB+"()")
			@ Li,008 PSay NGRETTITULO("T5_TAREFA")
			@ Li,017 PSay NGRETTITULO("T5_DESCRIC")
			&(cFUNCCAB+"()")
			@ Li,008 PSay cTarefa
			@ Li,016 PSay If(Alltrim(cTarefa) == "0",STR0145,ST5->T5_DESCRIC)
			If NGIFDBSEEK("STM",vBEM+vSER+vSEQ+cTarefa,1,.F.)
				&(cFUNCCAB+"(2)")
				@ Li,040 PSay Replicate("-",20)+STR0182+Replicate("-",20) //"Dependencias"
				&(cFUNCCAB+"()")
				@ Li,040 PSay NGRETTITULO("TM_DEPENDE")
				@ Li,053 PSay cDescDep
				@ Li,080 PSay NGRETTITULO("TM_SOBREPO")

				DbSelectArea("STM")
				While !Eof() .And. STM->TM_FILIAL = xFILIAL("STM") .And. STM->TM_CODBEM = vBEM .And.;
				STM->TM_SERVICO = vSER .And. STM->TM_SEQRELA = vSEQ .AND. STM->TM_TAREFA = cTarefa
					&(cFUNCCAB+"()")
					@ Li,40 PSay STM->TM_DEPENDE Picture "@!"
					@ Li,53 PSay NGSEEK("ST5",STM->TM_CODBEM+STM->TM_SERVICO+STM->TM_SEQRELA+STM->TM_DEPENDE,1,"SubS(T5_DESCRIC,1,25)")
					nSobreP := If(Empty(STM->TM_SOBREPO),100,STM->TM_SOBREPO)
					@ Li,If(nSobreP = 100,88,86) PSay nSobreP Picture If(nSobreP = 100,"@E 999%","99.99%")
					NGDBSELSKIP("STM")
				End
			EndIf

			If nPARE = 1 .And. NGIFDBSEEK("STH",vBEM+vSER+vSEQ+cTarefa,1,.F.)
				&(cFUNCCAB+"(2)")
				@ Li,012 PSay Replicate("-",41)+STR0183+Replicate("-",52) //"-..ETAPAS--..
				While !Eof() .And. STH->TH_FILIAL = xFILIAL("STH") .And. STH->TH_CODBEM = vBEM .And.;
				STH->TH_SERVICO = vSER .And. STH->TH_SEQRELA = vSEQ .AND. STH->TH_TAREFA = cTarefa
					&(cFUNCCAB+"()")
					@ Li,012 PSay STH->TH_ETAPA
					NGIMPMEMO(NGSEEK("TPA",STH->TH_ETAPA,1,"TPA_DESCRI"),92,20,,.F.,.F.,cFUNCCAB+"()",58)
					If sth->th_opcoes <> 'S'
						If NGIFDBSEEK("TP1",STH->TH_CODBEM+STH->TH_SERVICO+STH->TH_SEQRELA+STH->TH_TAREFA+STH->TH_ETAPA,1,.F.)
							&(cFUNCCAB+"()")
							@ Li,019 PSay Replicate("-",41)+STR0184+Replicate("-",45) //"----------------------------OPCOES--------------------------------"
							&(cFUNCCAB+"()")
							@ Li,019 PSAY STR0185 //"Opcao      Tipo Res. Condicao          Informacao Tp. Manut. Bem              Serv.  Seq."
						EndIf
						While !EOF() .And. TP1->TP1_FILIAL = xFILIAL("TP1") .And. STH->TH_CODBEM == TP1->TP1_CODBEM .And.;
						STH->TH_SERVICO == TP1->TP1_SERVIC .And. STH->TH_SEQRELA == TP1->TP1_SEQREL .And.;
						STH->TH_TAREFA  == TP1->TP1_TAREFA .And. STH->TH_ETAPA == TP1->TP1_ETAPA
							&(cFUNCCAB+"()")
							@ Li,019 PSAY TP1->TP1_OPCAO
							@ Li,036 PSAY NGRETSX3BOX("TP1_TIPRES",TP1->TP1_TIPRES)
							If TP1->TP1_TIPRES = "I"
								@ Li,046 PSAY NGRETSX3BOX("TP1_CONDOP",TP1->TP1_CONDOP)
								@ Li,061 PSAY TP1->TP1_CONDIN
							EndIf
							@ Li,072 PSAY NGRETSX3BOX("TP1_TPMANU",TP1->TP1_TPMANU)
							@ Li,083 PSAY If(TP1->TP1_TPMANU <> "N",TP1->TP1_BEMIMN," ")
							@ Li,100 PSAY If(TP1->TP1_TPMANU <> "N",TP1->TP1_SERVMN," ")
							@ Li,107 PSAY If (!Empty(TP1->TP1_SEQUMN),TP1->TP1_SEQUMN," ")
							NGDBSELSKIP("TP1")
						End
						&(cFUNCCAB+"()")
					EndIf
					NGDBSELSKIP("STH")
				End
			EndIf
			If nPARI = 1 .And. NGIFDBSEEK("STG",vBEM+vSER+vSEQ+cTarefa,1,.F.)
				&(cFUNCCAB+"(2)")
				@ Li,012 PSay Replicate("-",52)+STR0186+Replicate("-",55) //"--..INSUMOS--....
				&(cFUNCCAB+"()")
				@ Li,012 PSay STR0187 //"Nome          Codigo"
				@ Li,056 PSay STR0188 // Descricao                               Qtd Consumo   Uni Res Destino"
				While !EOF() .And. STG->TG_FILIAL = xFILIAL("STG") .And. STG->TG_CODBEM = vBEM .And.;
				STG->TG_SERVICO = vSER .And. STG->TG_SEQRELA = vSEQ .And. STG->TG_TAREFA = cTarefa
					&(cFUNCCAB+"()")
					vVetNI := NGNOMINSUM(STG->TG_TIPOREG,STG->TG_CODIGO,40)
					@ Li,012 PSay vVetNI[1,1]
					@ Li,026 PSay STG->TG_CODIGO
					@ Li,057 PSay Substr(vVetNI[1,2],1,38)
					@ Li,097 PSay STG->TG_QUANREC PICTURE "@E 999"
					@ Li,101 PSay STG->TG_QUANTID PICTURE "@E 999999.99"
					@ Li,111 PSay STG->TG_UNIDADE
					@ Li,115 PSay NGRETSX3BOX("TG_RESERVA",STG->TG_RESERVA)
					@ Li,119 PSay If (STG->TG_TIPOREG = "P",NGRETSX3BOX("TG_DESTINO",STG->TG_DESTINO)," ")
					NGDBSELSKIP("STG")
				End
			EndIf
			DbSelectArea("ST5")
			DbGoto(nRecST5)
			DbSkip()
		End
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGACERTOMANU³ Autor ³ Inacio Luiz Kolling   ³ Data ³23/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acerto data e/ou acumulado da manutencao na exclusao da O.S.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodBem   - Código do bem                         - Obrigatorio³±±
±±³          ³ cSer    - Código do serviço                      - Obrigatório³±±
±±³          ³ cSeq    - Código da sequencia                    - Obrigatório³±±
±±³          ³ dDtFim - data da finalização da ordem de servico - Obrigatório³±±
±±³          ³ cHoCo1 - Hora do contador 1                            - Obrigatório³±±
±±³          ³ cHoCo2 - Hora do contador 2                            - Obrigatório³±±
±±³          ³ cFilA  - Código da filial                                     - Não Obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGACERTOMANU(cCodbem,cSer,cSeq,dDtFim,cHoCo1,cHoCo2,cFilAA)
	Local  aAreaL := GetArea()
	cFilA := cFilAA
	If NGIFDBSEEK("STF",cCodbem+cSer+cSeq,1,.f.)
		NGACEPROCMAN(cCodbem,cSer,cSeq)
		NGACERMANS(cCodbem,cSer,cSeq,STF->TF_DTULTMA,STF->TF_CONMANU,cFilAA)
	EndIf
	RestArea(aAreaL)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³NGProdMNT ºAutor  ³Wagner S. de Lacerdaº Data ³  27/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para retornar os codigos dos produtos contidos nos  º±±
±±º          ³ parametros de cotrole de Manutencao e Terceiros do SigaMNT.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ aProdutos -> Array contendo os Codigos dos Produtos.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cParam -> Obrigatorio;                                     º±±
±±º          ³           Indica qual o parametro para buscar os produtos. º±±
±±º          ³            "*" -> Todos                                    º±±
±±º          ³            "M" -> MV_PRODMNT (Manutencao)                  º±±
±±º          ³            "T" -> MV_PRODTER (Terceiro)                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaMNT                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³   Data     ³ Descricao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ³ xx/xx/xxxx ³                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGProdMNT(cParam)

	Local aProdutos := {} //Vetor responsavel por receber os Codigos dos Produtos (separadamente)
	Local aProdsMNT := {} //Vetor dos produtos de Manutencao
	Local aProdsTER := {} //Vetor dos produtos de Terceiro
	Local cConteudo := "" //String responsavel por receber o conteudo do parametro (completo)
	Local cGetMV    := "" //Indica qual o parametro a buscar

	Local nTamCodSB1 := TAMSX3("B1_COD")[1]
	Local nX         := 0

	cParam := If(cParam == Nil, "*", cParam)

	aProdutos := {}

	If cParam == "*" //Produtos de todos os parametros
		aProdsMNT := aClone(NGProdMNT("M"))
		aProdsTER := aClone(NGProdMNT("T"))

		For nX := 1 To Len(aProdsMNT)
			aAdd(aProdutos, aProdsMNT[nX])
		Next nX

		For nX := 1 To Len(aProdsTER)
			aAdd(aProdutos, aProdsTER[nX])
		Next nX
	Else //Produtos do parametro especificado
		cGetMV := If(cParam == "M", "MV_PRODMNT", "MV_PRODTER")

		//Recebe o conteudo do parametro
		cConteudo := AllTrim( SuperGetMV(cGetMV,.F.,"") )

		If !Empty(cConteudo)
			//Verifica se o Conteudo possui o caracter de separacao '/'
			//Se nao possuir, entao esta' definido somente 1 (um) produto no parametro
			If "/" $ cConteudo
				aProdutos := StrTokArr(cConteudo, "/")
			Else
				aAdd(aProdutos, cConteudo)
			EndIf
		Else
			aProdutos := {Space(nTamCodSB1)}
		EndIf
	EndIf

	//Ponto de Entrada que permite que o cliente possa alterar o produto
	If ExistBlock("PRODMNT1")
		aProdutos := ExecBlock("PRODMNT1",.F.,.F.,{aProdutos})
	EndIf

	//Define os tamanho dos Codigos dos Produtos de acordo com o tamanho no dicionario
	For nX := 1 To Len(aProdutos)
		aProdutos[nX] := AllTrim(aProdutos[nX])
		aProdutos[nX] := aProdutos[nX] + Space( nTamCodSB1 - Len(aProdutos[nX]) )
	Next nX

Return aProdutos

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGDATAOS ³ Autor ³ Paulo Pego            ³ Data ³ 24/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Informa a Data da proxima Manutencao para determinado Bem  ³±±
±±³          ³ ou Estrutura                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCODBEM - Codigo do Bem                                    ³±±
±±³          ³ cCalc   - Informa se inclui a estrutura                    ³±±
±±³          ³           E = Calcula a Estrutura, I = Somente o Bem isola-³±±
±±³          ³           do [DEFAULT = I ]                                ³±±
±±³          ³ cSERVICO - Codigo do Servico (Somente para cCALC = I)      ³±±
±±³          ³            Se nao informado refere-se a todas as manuten-  ³±±
±±³          ³            coes do Bem oi Estrutura                        ³±±
±±³          ³ nSequenc - Sequencia da Manutencao (Idem a cSERVICO)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBS       ³ Retorna uma array multidimicional com BEM, SERVICO, SEQUEN-³±±
±±³          ³ CIA, DATA PROXIMA MANUTENCAO, DATA REAL PROXIMA MANUTENCAO ³±±
±±³          ³ e CONTADOR NA PROXIMA MANUTENCAO                           ³±±
±±³          ³ Deve ser definida uma variavel cNGERROR com a mensagem de  ³±±
±±³          ³ error ocorrido.                                            ³±±
±±³          ³ Quando houver error a array retorna vazia.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT - Planejamento de Manutencao                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION NGDATAOS(cCODBEM, cCALC, cSERVICO,nSEQ)
	Local aBEM := {}, aMNT := {}, aRET, i
	nSequenc := If(ValType(nSEQ) = "C",nSEQ,Str(nSEQ,3))

	NGDBAREAORDE("STC",1)
	SET FILTER TO STC->TC_FILIAL = xFilial("STC") .And. STC->TC_TIPOEST == "B"

	If Empty(cCODBEM)
		cNGERROR := STR0189 //"FALTA O CODIGO DO BEM"
		Return {}
	Endif

	If Empty(cCALC)
		cCALC := "I"
	Endif

	AAdd(aBEM,cCODBEM)

	If cCALC == "E"
		If NGIFDBSEEK('STC',cCODBEM,1)
			aRET := NGESTRU(STC->TC_COMPONE)
			For i := 1 to Len(aRET)
				AAdd(aBEM, aRET[i])
			Next
		Endif
	Endif

	For i := 1 to Len(aBEM)
		NGIFDBSEEK('STF',aBEM[i],1)
		WHile !Eof() .and. STF->TF_FILIAL == xFilial('STF') .and. STF->TF_CODBEM == aBEM[i]
			lOK := If(Empty(cSERVICO), .T., STF->TF_SERVICO == cSERVICO)
			If lOK
				lOK := If(Empty(nSEQUENC), .T., STF->TF_SEQRELA == nSEQUENC)
			Endif

			If !lOK
				DbSkip()
				Loop
			Endif

			dRET  := NGXPROXMAN(STF->TF_CODBEM)
			dREAL := NGCHKDTMNT(dRET, STF->TF_CALENDA, STF->TF_NAOUTIL)
			nCONT := (STF->TF_CONMANU + STF->TF_INENMAN)
			AAdd(aMNT, {STF->TF_CODBEM, STF->TF_SERVICO, STF->TF_SEQRELA, dRET, dREAL, nCONT})
			NGDBSELSKIP("STF")
		End
	Next
Return aMNT

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGOSPEND  ³ Autor ³Inacio Luiz Kolling   ³ Data ³19/07/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica as ordem de servico pendentes                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cBEMDE  - De codigo do bem                                  ³±±
±±³          ³cBEMATE - Ate codigo do bem                                 ³±±
±±³          ³cSERDE  - De codigo do servico                              ³±±
±±³          ³cSERATE - Ate codigo do servico                             ³±±
±±³          ³dDTDE   - De data prevista inicio                           ³±±
±±³          ³dDTATE  - Ate data prevista inicio                          ³±±
±±³          ³lTELA   - Indica se sera mostra na tela - Nao obrigatorio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Se nao for informado lTELA retorna a matriz aOSPEND Onde:   ³±±
±±³          ³[n,1] - codigo do bem                                       ³±±
±±³          ³[n,2] - codigo do servico                                   ³±±
±±³          ³[n,3] - numero da sequencia                                 ³±±
±±³          ³[n,4] - numero da ordem de servico                          ³±±
±±³          ³[n,5] - numero do plano                                     ³±±
±±³          ³[n,6] - data de abertura                                    ³±±
±±³          ³[n,7] - data prevista inicio                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGOSPEND(cBEMDE,cBEMATE,cSERDE,cSERATE,dDTDE,dDTATE,lTELA)
	Local aAreasros := GetArea(), aOSPEND := {}
	Local lMOSTRA   := If(lTELA = NiL,.F.,lTELA), aRotOld := {},lRot := .f.
	Local aTMPFIELD ,bTMPFUNC,  cTMPBRW

	If lMOSTRA
		Private aIndSTJ    := {}
		Private bFiltraBrw := {|| Nil}
		Private aVETINR    := {}
		If Type("aROTINA") = "A"
			aRotOld := Aclone(aROTINA)
			lRot    := .t.
		Endif
		aROTINA := {{STR0051,"PesqBrw" , 0, 1},; //"Pesquisar"
		{STR0052,"AxVisual", 0, 2}} //"Visualizar"
		cCADASTRO := Oemtoansi(STR0190)
		aPOS1 := {15,1,95,315}
		DbSelectArea("STJ")

		ccondicao := 'STJ->TJ_FILIAL = "'+ xFilial("STJ")+'"'+'.And. '
		ccondicao += 'STJ->TJ_TIPOOS = "B" .And. STJ->TJ_TERMINO = "N" .And. '
		ccondicao += 'STJ->TJ_SITUACA = "L" .And. (STJ->TJ_CODBEM >= "'+cBEMDE+'"'
		ccondicao += '.And. STJ->TJ_CODBEM <= "'+ cBEMATE+'") .And. '
		ccondicao += '(STJ->TJ_SERVICO >= "'+cSERDE+'" .And. STJ->TJ_SERVICO <= "'+ cSERATE+'")'
		ccondicao += ' .And. (Dtos(STJ->TJ_DTMPINI) >= "'+Dtos(dDTDE)+'" .And. Dtos(STJ->TJ_DTMPINI) <= "'+Dtos(dDTATE)+'")'

		bFiltraBrw := {|| FilBrowse("STJ",@aIndSTJ,@cCondicao) }
		Eval(bFiltraBrw)

		nINDSTJ := INDEXORD()

		mBrowse(6,1,22,75,"STJ")
		aEval(aIndSTJ,{|x| Ferase(x[1]+OrdBagExt())})
		ENDFILBRW("STJ",aIndSTJ)

		DbSelectArea("STJ")
		Set Filter To

		If lRot
			aROTINA := Aclone(aRotOld)
		Endif

		RestArea(aAreasros)
		Return
	Else
		NGDBAREAORDE("STJ",2)
		DbSeek(Xfilial("STJ")+"B"+cBEMDE,.T.)
		ProcRegua(LastRec())
		While !Eof() .And. stj->tj_filial = Xfilial("STJ") .And. stj->tj_tipoos = "B";
		.And. stj->tj_codbem <= cBEMATE
			IncProc("Processando....")
			If stj->tj_situaca = "L" .And. stj->tj_termino = "N" .And.;
			(stj->tj_servico >= cSERDE .And. stj->tj_servico <= cSERATE) .And.;
			(stj->tj_dtmpini >= dDTDE .And. stj->tj_dtmpini <= dDTATE)
				Aadd(aOSPEND,{stj->tj_codbem,stj->tj_servico,stj->tj_seqrela,;
				stj->tj_ordem,stj->tj_plano,stj->tj_dtorigi,stj->tj_dtmpini})
			Endif
			NGDBSELSKIP("STJ")
		End
	Endif
	RestArea(aAreasros)
Return aOSPEND

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGINSUSB2  ³ Autor ³In cio Luiz Kolling   ³ Data ³21/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³F10 - Insumo tipo produto para saldo em estoque ( SB1 + SB2)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cVVAR   - Variavel de leitura                  - Obrigatorio³±±
±±³          ³cVBEM   - Codigo do bem                        - Obrigatorio³±±
±±³          ³cVTPR   - Tipo de insumo                       - Obrigatorio³±±
±±³          ³lGETDAD - Utilisa o getdados                   - Nao Obrig. ³±±
±±³          ³nFOLDER - Numero do folder                     - Nao Obrig. ³±±
±±³          ³cNOMPRO - Campo virtual da descricao produto   - Nao Obrig. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGINSUSB2(cVVAR,cVBEM,cVTPR,lGETDAD,nVFDER,cNOMPRO)
	Local lINSF11  := .F., cINTTPR := If(cVTPR = NIL,"P",cVTPR)
	Local cALISU11 := Alias(), nREGSU11 := IndexOrd(),lREF11 := .T.
	Local lUTIGDAD := If(lGETDAD = Nil,.f.,.t.),nPOSCENO := 0

	If lUTIGDAD
		If nVFDER = NIL
			nCOLGE := oget:obrowse:ncolpos
		Else
			If nVFDER = 1
				nCOLGE := oget01:obrowse:ncolpos
			ElseIf nVFDER = 2
				nCOLGE := oget02:obrowse:ncolpos
			ElseIf nVFDER = 3
				nCOLGE := oget03:obrowse:ncolpos
			ElseIf nVFDER = 4
				nCOLGE := oget04:obrowse:ncolpos
			Endif
		Endif
		nTEMMM   := At("->",cVVAR)
		cCAMAH   := If(nTEMMM > 0,Substr(cVVAR,nTEMMM+2,Len(cVVAR)),cVVAR)
		nPOSCEDU := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == cCAMAH})
		nPOSCENO := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == cNOMPRO})
		If nPOSCEDU > 0
			If nPOSCEDU <> nCOLGE
				Return
			Endif
		Else
			Return
		Endif
	Endif

	cBEMSUF11 := cVBEM
	If !NGIFDICIONA("SXB","SB1",1)
		MsgInfo(STR0191+" SB1"+STR0191,STR0005)
		lREF11 := .F.
	Else
		If cINTTPR = "P"
			If !Empty(cVBEM)
				If lUTIGDAD
					If nPOSCEDU > 0
						lINSF11 := .T.
					Endif
				Else
					If Readvar() = cVVAR
						lINSF11 := .T.
					Endif
				Endif
			Endif
		Endif

		If lINSF11
			If Type("aTROCAF3") = 'A'
				If Len(aTROCAF3) > 0
					aTROCAF3[1,2] := "SB1"
				Endif
			Endif
			lCONDP := NGCONSALSB2()
			If lCONDP
				&cVVAR. := SB1->B1_COD
				If lUTIGDAD
					Acols[n,nPOSCEDU] := SB1->B1_COD
					If nPOSCENO > 0
						Acols[n,nPOSCENO] := NGSEEK("SB1",SB1->B1_COD,1,"B1_DESC")
					Endif
				Endif
				lREFRESH := .T.
			Endif
		Endif
	Endif
	If !Empty(cALISU11)
		DbSelectArea(cALISU11)
		If nREGSU11 > 0
			DbSetOrder(nREGSU11)
		Endif
	Endif

	If Type("aTROCAF3") = 'A'
		If Len(aTROCAF3) > 0 .And. cVTPR = "P"
			aTROCAF3[1,2] := "SB1"
		Endif
	Endif

Return lREF11

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCONSALSB2³ Autor ³Inacio Luiz Kolling   ³ Data ³22/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta Especifica SB1 + SB2 Saldo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCONSALSB2()
	Private aCampos := {},aHeaCam := {},cFiltrar := Space(40),lPesq := .f.
	Private oDlgF,lSAIPESQ := .F.

	NGDBAREAORDE("SB1",1)
	cTitulo := STR0192
	Aadd(aCampos,{STR0193,"B1_COD"})
	Aadd(aCampos,{STR0194,"B1_DESC"})
	Aadd(aCampos,{STR0195,"NSALDOE"})
	lRet := NGCONSB2SAL(cTitulo,"SB1",aCampos,1,"xFILIAL('SB1')", {||B1_FILIAL == xFilial("SB1")})
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCONSB2SAL³ Autor ³Inacio Luiz Kolling   ³ Data ³22/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consulta Especifica                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³NGCONSALSB2                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NGCONSB2SAL(cTitulo,cAlias,aCampos,nOrdem,cSeek,bWhile,bFor)
	Local bConteudo,cBloco,oBtn1,oBtn2,nOpc := 0,nItens := 0,cConteudo := ''
	Local cNaoCon := '',aListAux := {}, nI := 0
	Private aListPad := {},oLBrowse,nReg := 0

	nOrdem := If( nOrdem == NIL, 1, nOrdem )
	bWhile := If( bWhile == NIL, {||.T.}, bWhile )
	bFor   := If( bFor   == NIL, {||.T.}, bFor   )

	NGDBAREAORDE(cAlias,nOrdem)
	CursorWait()

	If cSeek == NIL
		DbGoTop()
	Else
		DbSeek(&(cSeek),.T.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta aHeaCam especifico                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval(aCampos,{|aElem|Aadd(aHeaCam,aElem[1])})

	While !Eof() .And. Eval(bWhile)
		If ! Eval( bFor )
			DbSkip()
			Loop
		Endif
		nRecSB1 := Recno()
		aListAux := {}
		For nI := 1 To Len(aCampos)
			cNaoCon := ''
			If aCampos[nI,2] <> "NSALDOE"
				bConteudo := FieldWBlock(aCampos[nI,2],Select(cAlias))
				cNaoCon   := Eval(bConteudo)
				Aadd(aListAux,cNaoCon)
			Else
				NGIFDBSEEK('SB2',SB1->B1_COD+SB1->B1_LOCPAD,1)
				//         nSALDODIS := SaldoSB2(.F.,.T.,dDataBase+3650,.F.)+SB2->B2_SALPEDI+SB2->B2_QACLASS-SB2->B2_QEMPN+AvalQtdPre("SB2",2)

				nSALDODIS := If(GetNewPar("MV_NGINTER","") == "M",; 			// Integracao por Mensagem Unica
				NGMUStoLvl(SB1->B1_COD, SB1->B1_LOCPAD,.T.),;		  		// Atualiza tabela
				SaldoSB2(.F.,.T.,dDataBase+3650,.F.))		// Atualiza tabela SB2
				nSALDODIS += SB2->B2_SALPEDI+SB2->B2_QACLASS-SB2->B2_QEMPN+AvalQtdPre("SB2",2)

				Aadd(aListAux,nSALDODIS)
			Endif
		Next nI

		Aadd(aListAux,nRecSB1)
		Aadd(aListPad,aListAux)

		If (++nItens) == 4096
			Alert(STR0196)
			Exit
		EndIf
		NGDBSELSKIP("SB1")
	End

	CursorArrow()

	If Len(aListPad) == 0
		Alert(STR0197)
		Return .F.
	EndIf

	DEFINE DIALOG oDlgF TITLE cTitulo From 12,60 To 36,120 OF oMainWnd

	@.1,1 Say OemToAnsi(STR0198)
	@.7,1 MsGet cFiltrar Picture "@!" Size 160,7  Valid NGFILSALSB2() when lPesq
	oLBrowse:= TWBrowse():New( 1.5, 1, 222, 140,,aHeaCam,, oDlgF,,,,,,,,,,,,.T.)
	oLBrowse:SetArray(aListPad)

	cBloco := "{|| { "
	For nI := 1 To Len(aListPad[1]) - 1
		If nI > 1
			cBloco += ","
		EndIf
		cBloco += "aListPad[oLBrowse:nAt,"+StrZero(nI,2)+"]"
	Next

	cBloco += " }}"
	oLBrowse:bLine := &(cBloco)
	oLBrowse:bLDblClick := {||(nOpc := 1,nReg:=aListPad[oLbrowse:nAt,Len(aListPad[1] ) ],oDlgF:End())}

	DEFINE SBUTTON oBtn1 FROM 165,10 TYPE 1 ACTION (nOpc := 1,nReg:=aListPad[oLbrowse:nAt,Len(aListPad[1])],oDlgF:End()) ENABLE OF oDlgF
	DEFINE SBUTTON oBtn2 FROM 165,40 TYPE 2 ACTION (nOpc := 0,oDlgF:End()) ENABLE OF oDlgF
	@.5,47 Button STR0051 Of oDlgF Size 40,12 Action NGLEPESB2()

	ACTIVATE MSDIALOG oDlgF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona registro											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSAIPESQ
		nOpc := 1
	Else
		If nOpc == 1
			DbselectArea("SB1")
			DbGoto(nReg)
		EndIf
	EndIf
Return(nOpc == 1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGLEPESB2  ³ Autor ³Inacio Luiz Kolling   ³ Data ³22/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consulta Especifica                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³NGCONSALSB2                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NGLEPESB2()
	lPesq := .t.
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCONSB2SAL³ Autor ³Inacio Luiz Kolling   ³ Data ³22/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consulta Especifica                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³NGCONSALSB2                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NGFILSALSB2()
	Local nVa := 0,nI := 0,cConteudo := '',cNaoCon := '',aListAux := {}
	Private aListPad2 := {},oLBrowse2,nopc := 0
	lSAIPESQ := .f.

	For nVa := 1 To Len(aListPad)
		aListAux := {}
		If Alltrim(cFiltrar) $ aListPad[nVa,2]
			For nI := 1 To Len(aCampos)
				Aadd(aListAux,aListPad[nVa,nI])
			Next nI
			Aadd(aListAux,aListPad[nVa,4])
			Aadd(aListPad2,aListAux)
		Endif
	Next nVa

	cFiltrar := Space(40)
	lPesq    := .f.
	lREFRESH := .T.

	CursorArrow()

	If Len(aListPad2) == 0
		Alert(STR0197)
		Return .F.
	EndIf

	DEFINE MSDIALOG oDlgS TITLE cTitulo From 12,60 To 36,120 OF oMainWnd
	oLBrowse2:= TWBrowse():New( .5, 1, 222, 150,,aHeaCam,, oDlgS,,,,,,,,,,,,.T.)
	oLBrowse2:SetArray(aListPad2)

	cBloco := "{|| { "
	For nI := 1 To Len(aListPad2[1]) - 1
		If nI > 1
			cBloco += ","
		EndIf
		cBloco += "aListPad2[oLBrowse2:nAt,"+StrZero(nI,2)+"]"
	Next

	cBloco += " }}"
	oLBrowse2:bLine := &(cBloco)
	oLBrowse2:bLDblClick := {||(nOpc := 1,nReg:=aListPad2[oLbrowse2:nAt,Len(aListPad2[1] ) ],oDlgS:End())}
	DEFINE SBUTTON oBtn1 FROM 165,10 TYPE 1 ACTION (nOpc := 1,nReg:=aListPad2[oLbrowse2:nAt,Len(aListPad2[1])],oDlgS:End()) ENABLE OF oDlgS
	DEFINE SBUTTON oBtn2 FROM 165,40 TYPE 2 ACTION (nOpc := 0,oDlgS:End()) ENABLE OF oDlgS

	ACTIVATE MSDIALOG oDlgS

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona registro                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 1
		oDlgF:End()
		DbselectArea("SB1")
		DbGoto(nReg)
		lSAIPESQ := .t.
		Return(nOpc == 1)
	EndIf
Return .T.

//+-----------------------------------------+
//| Removida função NGCUSTOVEI, pois deixou |
//| de ser utilizada,chamada da função      |
//| Versão 68 P12114                        |
//+-----------------------------------------+

//+-----------------------------------------+
//| Removida função NGOSVCUSTO, pois deixou |
//| de ser utilizada,chamada da função      |
//| Versão 68 P12114                        |
//+-----------------------------------------+

//+-----------------------------------------+
//| Removida função NGOSVCUST2, pois deixou |
//| de ser utilizada no NGOSVCUSTO, a qual  |
//| era a unica chamada da função           |
//| Versão 68 P12114                        |
//+-----------------------------------------+

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGTMSCUSTO   ³ Autor ³ Inacio Luiz Kolling   ³ Data ³31/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Custo abastecimento do veiculo (TQN)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cVCODB    - Codigo do veiculo                                   ³±±
±±³          ³dVDEDATA  - De data                                             ³±±
±±³          ³dDATEDATA - Ate data                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGCUSTOVEI E/Ou Generico                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGTMSCUSTO(cVCODB,dVDEDATA,dVATEDATA)
	Local nCUSTQN := 0.00, aAREAUM := GetArea()

	//Integracao com TMS
	If AllTrim(GetNewPar('MV_NGMNTMS',"N")) == "S"
		If NGIFDBSEEK('ST9',cVCODB,15)
			cQuery := "SELECT SUM(TQN_VALTOT) SUM_SALDO"
			cQuery += " FROM " + RetSQLName("TQN")
			cQuery += " WHERE TQN_FILIAL = '" + xFilial("TQN") + "'"
			cQuery += " AND TQN_FROTA = '" + ST9->T9_CODBEM +"'"
			cQuery += " AND TQN_DTABAS >= '" + DToS(dVDEDATA) + "'"
			cQuery += " AND TQN_DTABAS <= '" + DToS(dVATEDATA) + "'"
			cQuery += " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'TQNTMP', .F., .T.)
			dbSelectArea("TQNTMP")
			If !EOF() .And. SUM_SALDO > 0
				nCUSTQN := SUM_SALDO
			EndIf
			dbCloseArea()
		EndIf
	Endif
	RestArea(aAREAUM)
Return nCUSTQN
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGBCONHSTJ  ³Autor  ³In cio Luiz Kolling  ³ Data ³21/07/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna nome do BEM e SERVICO para o banco conhecimento(STJ)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cORDEMB - C¢digo da ordem de servico                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGBCONHSTJ(cORDEMB)
	Local cOLDALIAS := Alias()
	Local nOLDINDIC := IndexOrd()
	Local cDESCRI   := Space(60)

	cDESCRI := Alltrim(NGSEEK('ST9',STJ->TJ_CODBEM,1,'T9_NOME'))
	cDESCRI := cDESCRI+' /  '+ Substr(NGSEEK('ST4',STJ->TJ_SERVICO,1,'T4_NOME'),1,30)

	Dbselectarea(cOLDALIAS)
	Dbsetorder(nOLDINDIC)
Return cDESCRI

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGDELSTPSTL³ Autor ³Inacio Luiz Kolling    ³ Data ³09/09/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica e/ou deleta o lancamento do STP -> STL              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVOSTPSTL  - Numero do ordem de servico        - Obrigatorio ³±±
±±³          ³cVPTPSTL   - Numero do plano                   - Obrigatorio ³±±
±±³          ³cVDINSTL   - Data inicio do insumo             - Obrigatorio ³±±
±±³          ³hVOINSTL   - Hora inicio do insumo             - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGDELSTPSTL(cVOSTPSTL,cVPTPSTL,dVDINSTL,hVOINSTL)
	Local cALOLD  := Alias(),nORDIN,nRECSTL,lQTDREG := .f.
	Store 0 To nORDIN,nRECSTJ,nRECSTL,nOLDATU := IndexOrd()

	DbSelectArea("STL")
	nRECSTL := Recno()
	nORDIN  := IndexOrd()

	DbSelectArea("STJ")
	nRECSTJ := Recno()
	DbSetOrder(1)
	If Dbseek(xFILIAL("STJ")+cVOSTPSTL+cVPTPSTL)
		DbSelectArea("STL")
		DbSetOrder(1)
		If Dbseek(xFILIAL("STL")+cVOSTPSTL+cVPTPSTL)
			While !Eof() .And. stl->tl_filial = Xfilial('STL') .And.;
			stl->tl_ordem = cVOSTPSTL .And. stl->tl_plano = cVPTPSTL

				If Alltrim(stl->tl_seqrela) <> "0" .And. stl->tl_dtinici = dVDINSTL .And.;
				stl->tl_hoinici = hVOINSTL
					lQTDREG := .t.
					Exit
				EndIf
				dbskip()
			End
		Endif
		If !lQTDREG
			DbSelectArea("STP")
			DbSetOrder(5)
			If Dbseek(Xfilial('STP')+stj->tj_codbem+dtos(dVDINSTL)+hVOINSTL)
				RecLock('STP',.F.)
				DbDelete()
				STP->(MsUnLock())
			Endif
			DbSelectArea("TPP")
			DbSetOrder(5)
			If Dbseek(Xfilial('TPP')+stj->tj_codbem+dtos(dVDINSTL)+hVOINSTL)
				RecLock('TPP',.F.)
				DbDelete()
				TPP->(MsUnLock())
			Endif
		Endif
	Endif

	DbSelectArea("STL")
	DbSetOrder(nORDIN)
	Dbgoto(nRECSTL)

	DbSelectArea("STJ")
	Dbgoto(nRECSTJ)

	DbSelectArea(cALOLD)
	DbSetOrder(nOLDATU)
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGQTDISTL   ³ Autor ³ In cio Luiz Kolling ³ Data ³21/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia da quantidade de itens do insumo, so pode ser  ³±±
±±³          ³utilizada quando o STL considerar sequencia numerica        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVORDEM - Numero da ordem de servico      - Obrigatorio     ³±±
±±³          ³lMESAL  - Indica saida da mensagem        - Obrigatorio     ³±±
±±³          ³cTIPO   - Tipo de itens (pelo padrao S/N) - Obrigatorio     ³±±
±±³          ³nVQTD   - Quantidade a ser somada         - Obrigatorio     ³±±
±±³          ³nVTOT   - Quantidade ja calculada         - Nao Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGQTDISTL(cVORDEM,lMESAL,cTIPO,nVQTD,nVTOT)
	Local nQTDEXT := If(nVQTD <> Nil,nVQTD,0),lRETATU := .T.
	Local nQTDMA0 := 0, nQTDME0 := 0, nQTDSTL := 0,nINDSTL := 0,nREGSTL := 0
	Local cALIATU := Alias(),nORDATU := IndexOrd(),nTOTALI := 0

	If nVTOT <> Nil
		If nVTOT > 99
			lRETATU := .F.
			nTOTALI := nVTOT
		EndIf
	Else
		DbselectArea("STL")
		nINDSTL := nINDSTL
		nREGSTL := Recno()
		Dbsetorder(1)
		If Dbseek(xFILIAL("STL")+cVORDEM)
			While !Eof() .And. stl->tl_filial = xFILIAL("STL") .And.;
			stl->tl_ordem = cVORDEM

				If stl->tl_sequenc > 0
					nQTDMA0 := stl->tl_sequenc
				Else
					nQTDME0 += 1
				EndIf
				Dbskip()
			End
		Endif

		DbselectArea("STL")
		Dbsetorder(nINDSTL)
		Dbgoto(nREGSTL)
		nQTDSTL := If(cTIPO = "S",nQTDME0,nQTDMA0)

		nTOTALI := nQTDEXT+nQTDSTL
		If nTOTALI > 99
			lRETATU := .F.
		Endif
	EndIf

	If !lRETATU
		If lMESAL
			Msginfo(STR0206+chr(13)+STR0207+"..: "+cVORDEM+" "+STR0034+chr(13)+chr(13);
			+STR0209+"   99"+chr(13)+STR0210+Space(1)+Alltrim(Str(nTOTALI,3))+chr(13)+chr(13);
			+STR0173+":"+chr(13)+STR0211,STR0005)
		Endif
	Endif

	If !Empty(cALIATU)
		DbselectArea(cALIATU)
		If !Empty(nORDATU)
			Dbsetorder(nORDATU)
		Endif
	Endif

Return lRETATU

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGDTHORFIOS ³ Autor ³In cio Luiz Kolling  ³ Data ³28/07/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula e retorna a maior e menor data e hora de uma ordem  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametors³vVORDE  - Numero da ordem                                   ³±±
±±³          ³vVPLAN  - Numero do plano                                   ³±±
±±³          ³vVSEQ   - Sequencia do insuno (nome do campo)               ³±±
±±³          ³vVSEQP  - Tipo do insumo para calculo (Previsto,Real)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³vVETRE  - Vetor com [1] - Menor data inicio                 ³±±
±±³          ³                    [2] - Menor hora inicio                 ³±±
±±³          ³                    [3] - Menor data final                  ³±±
±±³          ³                    [4] - Menor hora final                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGDTHORFIOS(vVORDE,vVPLAN,vVSEQ,vVSEQP)
	Local aArea   := GetArea()
	Local cTVASEQ := &(vVSEQ), lPRIMD := .T., vVETRE := {}
	Local cTIPSEQ := If(ValType("vTVASEQ") = "C","C","N")
	Local vTIPSEQ := If(cTIPSEQ = "C", If (vVSEQP = "P",'Alltrim('+vVSEQ+') = "0"',;
	'Alltrim('+vVSEQ+') <> "0"'), If(vVSEQP = "P",'vVSEQ = 0' ,'vVSEQ <> 0'))
	Dbselectarea("STL")
	Dbsetorder(1)
	If Dbseek(xFILIAL("STL")+vVORDE+vVPLAN)
		While !Eof() .And. stl->tl_filial = xFILIAL("STL") .And.;
		stl->tl_ordem = vVORDE .And. stl->tl_plano = vVPLAN
			If  &vTIPSEQ
				If lPRIMD
					lPRIMD := .F.
					dMAXDT := If(stl->tl_tiporeg == "P",stl->tl_dtinici,stl->tl_dtfim)
					hMAXDT := If(stl->tl_tiporeg == "P",stl->tl_hoinici,stl->tl_hofim)
					Aadd(vVETRE,stl->tl_dtinici)
					Aadd(vVETRE,stl->tl_hoinici)
					Aadd(vVETRE,dMAXDT)
					Aadd(vVETRE,hMAXDT)
				Else
					If stl->tl_dtinici < vVETRE[1]
						vVETRE[1] := stl->tl_dtinici
						vVETRE[2] := stl->tl_hoinici
					ElseIf stl->tl_dtinici = vVETRE[1]
						vVETRE[2] := If(stl->tl_hoinici < vVETRE[2],stl->tl_hoinici,vVETRE[2])
					Endif

					dMAXFT := If(stl->tl_tiporeg == "P",stl->tl_dtinici,stl->tl_dtfim)
					hMAXFT := If(stl->tl_tiporeg == "P",stl->tl_hoinici,stl->tl_hofim)

					If dMAXFT > vVETRE[3]
						vVETRE[3] := dMAXFT
						vVETRE[4] := hMAXFT
					Elseif dMAXFT = vVETRE[3]
						vVETRE[3] := If(dMAXFT > vVETRE[3],dMAXFT,vVETRE[3])
						vVETRE[4] := If(hMAXFT > vVETRE[4],hMAXFT,vVETRE[4])
					Endif
				Endif
			Endif
			Dbskip()
		End
	Endif
	RestArea(aArea)
Return vVETRE


//---------------------------------------------------------------------
/*/{Protheus.doc} NGGOSAUT
Gera OS automática por contador
@type function

@author	Elisangela Costa
@since 21/05/2007

@param cBEM      , string , Código do bem
@param PFIL      , string , Código da filial
@param cVERGEROS , string , Parametro de verificacao de os aberta
@param lCONUS1VEZ, boolean, Indica se será verificado somente uma vez.
@param aVldMNT   , array  , Array contendo os Recnos da STF que não irão gerar O.S.
								aVldMNT[x,1] - Recno STF
								aVldMNT[x,2] - Define que não irá gerar O.S

@return
/*/
//---------------------------------------------------------------------
Function NGGOSAUT( cBEM, PFIL, cVERGEROS, lCONUS1VEZ, aVldMNT, nTipCont )

	Local cFilOST9   := NGTROCAFILI("ST9",PFIL)
	Local cFilOSTF   := NGTROCAFILI("STF",PFIL)
	Local cFilOTPE   := NGTROCAFILI("TPE",PFIL)
	Local cFilOSTJ   := NGTROCAFILI("STJ",PFIL)
	Local vOSABER    := {}
	Local nULTCOMAN  := 0
	Local nPCONTFIXO := GetMV("MV_NGCOFIX") //Percentual para calcular o contador fixo da manutencao
	Local nPERFIXO   := nPCONTFIXO / 100
	Local lTolera    := NGCADICBASE("TF_TOLECON","D","STF",.F.),nMargem := 0
	Local lTolConE   := If(NGCADICBASE("TF_MARGEM","A","STF",.F.),.t.,.f.)
	Local aNGGERAOS  := {}
	Local aCounter   := {} //Informações de último contador do bem
	Local cTContacu  := ''
	Local dTDtUltac  := Ctod( '  /  /  ' )
	Local nTVardia   := 0
	
	Private lJaApag  := .F.

	Default aVldMNT  := {}
	Default nTipCont := 0

	dbSelectArea("ST9")
	dbSetOrder(01)
	If dbSeek(cFilOST9+cBEM)
		cBemAut := ST9->T9_CODBEM
		If ST9->T9_SITMAN <> "I" .AND. ST9->T9_SITBEM = "A"

			//Dados do primeiro contador
			If ST9->T9_TEMCONT <> "N"
				
				aCounter   := NGACUMEHIS( cBEM, dDatabase, Substr( Time(), 1,5 ), 1, 'E', cFilOST9 )
				cTContacu  := aCounter[2]
				dTDtUltac  := acounter[3]
				nTVardia   := aCounter[6]

			EndIf

			If ExistBlock("SUBOSAUT")
				ExecBlock("SUBOSAUT",.F.,.F.)
			Else
				dbSelectArea("STF")
				dbSetOrder(01)
				If dbSeek(cFilOSTF+cBEM)
					ProcRegua(LastRec())
					While !Eof() .And. STF->TF_FILIAL == cFilOSTF .And. STF->TF_CODBEM == cBEM

						IncProc()
						If STF->TF_ATIVO == "N"
							DbSkip()
							Loop
						EndIf

						If STF->TF_PERIODO == "E"  //manutencoes eventuais nao geram OS automatica
							DbSkip()
							Loop
						EndIf

						dbSelectArea("STF")
						nRegStf  := Recno()
						nTolCont := If(!lTolConE,STF->TF_TOLECON,STF->TF_TOLERA * nTVardia )

						If STF->TF_TIPACOM <> "T"   // .And. STF->TF_TIPACOM <> "A"

							If STF->TF_TIPACOM == "S" .And. ( Empty( nTipCont ) .Or. nTipCont == 2 )

								dbSelectArea("TPE")
								dbSetOrder(01)
								If dbSeek(cFilOTPE+cBEM)

									// Dados do segundo contador
									aCounter   := NGACUMEHIS( cBEM, dDatabase, Substr( Time(), 1, 5 ), 2, 'E', cFilOTPE )
									cTContacu := aCounter[2]
									dTDtUltac := acounter[3]
									nTVardia  := aCounter[6]

									If ((STF->TF_CONMANU + STF->TF_INENMAN) - nMargem <= cTContacu) .Or. ;
										(lTolera .And. ((STF->TF_CONMANU + STF->TF_INENMAN) + nMargem  >= cTContacu) .And. ;
										((STF->TF_CONMANU + STF->TF_INENMAN - nTolCont ) - nMargem  < cTContacu))

										If !FwIsInCallStack( 'MNTA655' )
										
											//Verifica os aberta para mesmo bem+servico+sequencia
											If (cVERGEROS == "V" .And. !lCONUS1VEZ) .Or. (cVERGEROS == "C")
												vOSABER := NGPROCOSAB(PFIL,"B",STF->TF_CODBEM,STF->TF_SERVICO,STF->TF_SEQRELA)
												If !vOSABER[1]
													dbSelectArea("STF")
													dbSkip()
													Loop
												EndIf
											ElseIf cVERGEROS == "S"
												
												vOSABER := NGPROCOSAB(PFIL,"B",STF->TF_CODBEM,STF->TF_SERVICO,STF->TF_SEQRELA)
												
												If !vOSABER[1]
													
													If GetRemoteType() > -1 .And. !MsgYesNo(STR0216+chr(13)+chr(13); //"Já existe OS aberta para o mesmo Bem+Serviço+Sequência:"
														+STR0217+": "+STF->TF_CODBEM+chr(13); //"Bem"
														+STR0218+": "+STF->TF_SERVICO+chr(13); //"Serviço"
														+STR0219+ STF->TF_SEQRELA+chr(13)+chr(13); //"Sequência: "
														+STR0220+chr(13)+chr(13); //"Deseja gerar OS automática por contador mesmo com OS já aberta ?"
														+STR0017,STR0018) //"Confirma (Sim/Não)"# "ATENÇÃO"
														dbSelectArea("STF")
														dbSkip()
														Loop
													EndIf

												EndIf
												
											EndIf

										EndIf

										dDPROXM := NGPROXMAN( dTDtUltac,"C",STF->TF_TEENMAN,;
										STF->TF_UNENMAN,STF->TF_CONMANU,STF->TF_INENMAN,;
										cTContacu, nTVardia )

										aNGGERAOS := NGGERAOS('P',dDPROXM ,cBEM,STF->TF_SERVICO,STF->TF_SEQRELA,'S','S','S',PFIL)

										If aNGGERAOS[1][1] = 'S'
											nNUMOSGE += 1
											dbSelectArea("STJ")
											dbSetOrder(01)
											If dbSeek(cFilOSTJ+aNGGERAOS[1][3]+"000001")
												RecLock("STJ",.f.)
												STJ->TJ_OBSERVA := STR0222
												STJ->(MsUnlock())
												If Empty(dMENOR)
													dMENOR := stj->tj_dtmpini
													dMAIOR := dMENOR
													cMEORD := aNGGERAOS[1,3]
													cMAORD := cMEORD
												Else
													dMENOR := Min(dMENOR,stj->tj_dtmpini)
													dMAIOR := Max(dMAIOR,stj->tj_dtmpini)
													cMAORD := aNGGERAOS[1,3]
												Endif
											Endif
										EndIf
									EndIf
								EndIf

							ElseIf STF->TF_TIPACOM != 'S' .And. ( Empty( nTipCont ) .Or. nTipCont == 1 )

								If STF->TF_TIPACOM = "F"

									If STF->( FieldPos("TF_CONPREV") ) > 0
										nULTCOMAN := STF->TF_CONPREV
									Else
										nULTCOMAN := STF->TF_CONMANU
									EndIf

									nINCPERC := STF->TF_INENMAN * nPERFIXO     // Incremento da manutencao com percentual								

									nVEZMANU := Int(nULTCOMAN / STF->TF_INENMAN) // Numero de vezes que foi feito a manutencao
									nCONTFIX := IF(nVEZMANU==0, STF->TF_INENMAN, nVEZMANU * STF->TF_INENMAN) // Contador fixo exato
									nCONTPAS := nULTCOMAN - nCONTFIX             // Quantidade que passou da manutenção fixa

									If nCONTPAS < nINCPERC .Or. nINCPERC == 0
										If nCONTPAS < 0
											nCONTPAS := nCONTPAS * -1
										EndIf
										If nVEZMANU == 0 .And. nCONTPAS > nINCPERC
											nULTCOMAN := 0
										Else
											nULTCOMAN := nCONTFIX
										EndIf
									Else
										nULTCOMAN := nCONTFIX + STF->TF_INENMAN
									EndIf
								Else
									nULTCOMAN := STF->TF_CONMANU
								EndIf

								If ((nULTCOMAN + STF->TF_INENMAN) - nMargem <= cTContacu ) .Or. ;
								(lTolera .And. ((nULTCOMAN + STF->TF_INENMAN) + nMargem >=  cTContacu) .And.;
								((nULTCOMAN + STF->TF_INENMAN - nTolCont) - nMargem <  cTContacu))

									dDPROXM := NGPROXMAN( STF->TF_DTULTMA, STF->TF_TIPACOM, STF->TF_TEENMAN,;
									STF->TF_UNENMAN, nULTCOMAN, STF->TF_INENMAN, cTContacu, nTVardia, STF->TF_DTULTMA )

									If !FwIsInCallStack( 'MNTA655' )
									
										//Verifica os aberta para mesmo bem+servico+sequencia
										If (cVERGEROS == "V" .And. !lCONUS1VEZ) .Or. (cVERGEROS == "C")
											vOSABER := NGPROCOSAB(PFIL,"B",STF->TF_CODBEM,STF->TF_SERVICO,STF->TF_SEQRELA)
											If !vOSABER[1]
												dbSelectArea("STF")
												dbSkip()
												Loop
											EndIf
										ElseIf cVERGEROS == "S"
											
											vOSABER := NGPROCOSAB(PFIL,"B",STF->TF_CODBEM,STF->TF_SERVICO,STF->TF_SEQRELA)
											
											If GetRemoteType() > -1 .And. !vOSABER[1] //-1 = Job, Web ou Working Thread (Sem remote)
												
												If !MsgYesNo(STR0216+chr(13)+chr(13); //"Já existe OS aberta para o mesmo Bem+Serviço+Sequência:"
												+STR0217+": "+STF->TF_CODBEM+chr(13); //"Bem"
												+STR0218+": "+STF->TF_SERVICO+chr(13); //"Serviço"
												+STR0219+ STF->TF_SEQRELA+chr(13)+chr(13); //"Sequência: "
												+STR0220+chr(13)+chr(13); //"Deseja gerar OS automática por contador mesmo com OS já aberta ?"
												+STR0017,STR0018) //"Confirma (Sim/Não)"# "ATENÇÃO"
													
													dbSelectArea("STF")
													dbSkip()
													Loop

												EndIf
											
											EndIf

										EndIf

									EndIf

									aNGGERAOS := NGGERAOS('P',dDataBase ,cBEM,STF->TF_SERVICO,STF->TF_SEQRELA,'S','S','S',PFIL)

									If aNGGERAOS[1][1] = 'S'
										nNUMOSGE += 1
										dbSelectArea("STJ")
										dbSetOrder(01)
										If dbSeek(cFilOSTJ+aNGGERAOS[1][3]+"000001")
											RecLock("STJ",.f.)
											STJ->TJ_OBSERVA := STR0222
											STJ->TJ_DTORIGI := dDPROXM
											STJ->(MsUnlock())
											If Empty(dMENOR)
												dMENOR := stj->tj_dtmpini
												dMAIOR := dMENOR
												cMEORD := aNGGERAOS[1,3]
												cMAORD := cMEORD
											Else
												dMENOR := Min(dMENOR,stj->tj_dtmpini)
												dMAIOR := Max(dMAIOR,stj->tj_dtmpini)
												cMAORD := aNGGERAOS[1,3]
											Endif
										Endif
									EndIf
								EndIf
							EndIf
						EndIf
						dbSelectArea("STF")
						dbgoto(nRegStf)
						dbSkip()
					End
				EndIf
				//Verifica Substituicao
				If !lJaApag
					If Len(aNGGERAOS) > 0
						If aNGGERAOS[1][1] = 'S'
							// Variável utilizada dentro do NGINTCOMPEST, localizado no NGUTIL02, devido geração de O.S. automática com aglutinação
							// foi chamada a função de verificação da substituição para que ao gerar os insumos, não haja distorção na verificação
							// pelo estoque, portanto se esta função já foi chamada por lá, não deve ser chamada novamente.
							NGVERSUBST(cBEM,STJ->TJ_ORDEM, STJ->TJ_PLANO)
						EndIf
					else
						// Variável utilizada dentro do NGINTCOMPEST, localizado no NGUTIL02, devido geração de O.S. automática com aglutinação
						// foi chamada a função de verificação da substituição para que ao gerar os insumos, não haja distorção na verificação
						// pelo estoque, portanto se esta função já foi chamada por lá, não deve ser chamada novamente.
						NGVERSUBST(cBEM,STJ->TJ_ORDEM, STJ->TJ_PLANO)
					ENdIf
				Endif
			EndIf
		EndIf
	EndIf
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGVALOSLOT
Consiste a integracao do Manutencao da Ativo com Estoque e verifica se
pode ser deletado a nota fiscal

nRecSF1 - Numero do Recno da Tabela SF1 - Cabecalho das NF de Entrada

@author Tainã Alberto Cardoso
@since 03/09/2013
@version MP11
@return
/*/
//---------------------------------------------------------------------
Function NGVALOSLOT(nRecSF1)

	Local cServRef := GETNEWPAR("MV_NGSEREF")
	Local lGFrota  := NGVERUTFR() // Verifica se utiliza o modulo de Frota
	Local aAreaSD1 := SD1->(GetArea())

	if !lGFrota
		return .T.
	endif

	//Acessa a o cabecalho da nota Fiscal para percorrer todos os registros da nota
	dbSelectArea("SF1")
	dbGoTo(nRecSF1)

	If !Eof() //Find() Found()
		//Seleciona os Itens da Nota Fiscal
		dbSelectArea("SD1")
		dbSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		If dbSeek(xFilial("SD1")+SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)
			While !Eof() .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DOC == SF1->F1_DOC .And. SD1->D1_SERIE == SF1->F1_SERIE .And. ;
			SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA

				//Verifica se existe uma O.S. relacionada
				dbSelectArea("STJ")
				dbSetOrder(1)
				If dbSeek(xFilial("STJ")+SD1->D1_ORDEM)
					//Verifica se o servico é de Reforma de Pneu e O.S. Finalizada
					If STJ->TJ_SERVICO == cServRef .And. STJ->TJ_TERMINO == "S" .And. STJ->TJ_SITUACA == "L"
						//Verifica qual lote pertence a O.S.
						dbSelectArea("TR8")
						dbSetOrder(2)//TR8_FILIAL+TR8_ORDEM+TR8_PLANO
						If dbSeek(xFilial("TR8") + STJ->TJ_ORDEM + STJ->TJ_PLANO )
							ShowHelpDlg("",{STR0223},2,{STR0158+TR8->TR8_LOTE},2)//"Esta nota fiscal não pode ser excluída, pois existe relacionamento com a Ordem de Serviço em Lote referente ao serviço de recapeamento de pneus do sistema de manutenção de Ativos. ## Favor solicitar ao setor de manutenção para Reabrir a O.S. em lote de numero: "
							Return .F.
						EndIf
					EndIf
				EndIf

				dbSelectarea("SD1")
				dbSkip()
			End
		EndIf
	EndIf

	RestArea(aAreaSD1)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMNTATFBA
Função Baixa do imobilizado com integracao de ATF x MNT -
Chamado na funcao AFGRBXIntMnt do fonte ATFXATU

cCodBemMNT - Codigo do bem (SN1->N1_CODBEM)
dDataBaixa - Data da baixa (SN1->N1_BAIXA)
cRotina    - Rotina de baixa (ATFA030 / ATFA035)
lEstorno   - Indica se a baixa foi estornada, para limpeza
cNota	   - Nota fiscal

@author ARNALDO R. JUNIOR
@since 14/07/2008
@funcao trazida por Guiherme Benkendorf
@Data 11/02/2013
@version MP11
@return
/*/
//---------------------------------------------------------------------
Function NGMNTATFBA(cCodBemMNT,dDataBaixa,cRotina,lEstorno,cNota)

	Local aArea := GetArea()

	Default dDataBaixa	:= dDataBase
	Default cNota		:= Space(Len(ST9->T9_NFVENDA))

	If !IsInCallStack("ATFA060")

		DbSelectArea("ST9")
		DbSetorder(01)
		If DbSeek(xFilial("ST9") + cCodBemMNT)
			If !lEstorno .AND. Empty(ST9->T9_DTBAIXA)
				Reclock("ST9",.F.)
				ST9->T9_DTBAIXA := dDataBaixa
				ST9->T9_SITBEM  := "I"
				ST9->T9_SITMAN  := "I"
				If SubStr(cMotivo,1,2) == "01"// Motivo - 01 - Venda
					ST9->T9_DTVENDA := dDataBaixa
					ST9->T9_COMPRAD := STR0224 //"Ver detalhes na NF de Venda."
					ST9->T9_NFVENDA	:= cNota
				EndIf
				ST9->(MsUnlock())
			ElseIf lEstorno .AND. !Empty(ST9->T9_DTBAIXA)
				Reclock("ST9",.F.)
				ST9->T9_DTBAIXA := CTOD("")
				ST9->T9_SITBEM  := "A"
				ST9->T9_DTVENDA := CTOD("")
				ST9->T9_COMPRAD := Space(Len(ST9->T9_COMPRAD))
				ST9->T9_NFVENDA	:= Space(Len(ST9->T9_NFVENDA))
				ST9->(MsUnlock())
			EndIf
		EndIf
	EndIf
	RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGGARANSD3³ Autor ³Vitor Emanuel Batista  ³ Data ³10/02/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao de garantia do produto utilizado na manutencao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Integracao de entrada das NF com SIGAMNT                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGGARANSD3()
	Local aGarant := {}
	Local laCols  := .f.
	Local nPosProd, cProduto, nPosOS, cOrdem

	If Type("M->D3_COD") == "U"
		laCols    := .t.
		nPosProd  := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "D3_COD" })
		cProduto  := aCols[n][nPosProd]
		M->D3_COD := cProduto
	Else
		cProduto  := M->D3_COD
	EndIf

	If Type("M->D3_ORDEM") == "U"
		laCols    := .t.
		nPosOS := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "D3_ORDEM" })
		cOrdem := aCols[n][nPosOS]
		M->D3_ORDEM := cOrdem
	Else
		cOrdem := M->D3_ORDEM
	EndIf

	If Type("M->D3_TM") == "U"
		M->D3_TM := cTM
	Else
		cTM := M->D3_TM
	EndIf

	If M->D3_GARANTI == "S"
		dbSelectArea("SF5")
		dbSetOrder(1)
		dbSeek(xFilial("SF5")+cTM)
		If SF5->F5_TIPO <> 'R'
			MsgStop(STR0225,STR0005) //"Somente será controlada a garantia para Requisições de Produtos"
			Return .F.
		ElseIf Empty(cOrdem) .Or. Empty(cProduto)
			MsgInfo(STR0226,STR0005) //"Para informar a garantia é necessário informar a ordem de serviço e código do produto."
			Return .F.
		EndIf
	ElseIf M->D3_GARANTI == "N"
		If laCols
			nLS := Ascan(aMntGarant,{|x| x[11] = n })
			If nLS > 0
				aDel(aMntGarant,nLS)
				aSize(aMntGarant,Len(aMntGarant)-1)
			EndIf
		Else
			aMntGarant := {}
		EndIf
		Return .t.
	EndIf

	aGarant := NGTPZGARAN(cOrdem,cProduto)

	If Len(aGarant) > 0
		If Type("aCols") <> 'A'
			aMntGarant := { aGarant }
		Else
			nPosMnt := Ascan(aMntGarant,{|x| x[11] = n})
			If nPosMnt = 0
				aAdd(aMntGarant,{})
				nPosMnt := Len(aMntGarant)
			EndIf
			aMntGarant[nPosMnt] := aGarant
		EndIf
	Else
		Return .f.
	EndIf

Return .t.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NGULTOSREA³ Autor ³ Elisangela Costa      ³ Data ³15/10/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Retorna um vetor a ultima ordem de servico realizada para   ³±±
±±³          ³o bem ou localizaca                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametro³cCODBEM - Codigo do bem                   - Obrigatorio     ³±±
±±³          ³cTIPOOS - Tipo da OS (Bem ou Localizacao) - Obrigatorio     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³array - [1] - Numero da OS                                  ³±±
±±³          ³        [2] - Codigo do Plano                               ³±±
±±³          ³        [3] - Data de Real fim da OS                        ³±±
±±³          ³        [4] - Codigo do Servico                             ³±±
±±³          ³        [5] - Alias da OS (STJ ou STS)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function NGULTOSREA(cCODBEM,cTIPOOS)
	Local cNUMOS := Space(6), cPLANO := Space(6), dDATARF := CTOD("  /  /  "), cSERVI := Space(6), cALIARQ := " "
	Local cNUMOSSTJ := Space(6), cPLANOSTJ := Space(6), dDATARFSTJ := CTOD("  /  /  "), cSERVISTJ := Space(6), cALIARQSTJ := " "
	Local cNUMOSSTS := Space(6), cPLANOSTS := Space(6), dDATARFSTS := CTOD("  /  /  "), cSERVISTS := Space(6), cALIARQSTS := " "
	Local nRECSTJ , nRECSTS
	Local cALIASREA := Alias()
	Local nINDEXREA := IndexOrd()
	Local nRECREA   := Recno()

	dbSelectArea("STJ")
	dbSetOrder(12)
	dbSeek(xFilial("STJ")+cTIPOOS+cCODBEM+"S"+DTOS(Date()),.T.)
	If Eof() .Or. STJ->TJ_FILIAL <> xFilial("STJ") .Or. STJ->TJ_TIPOOS <> cTIPOOS .Or. STJ->TJ_CODBEM <> cCODBEM
		dbSkip(-1)
		While !Bof() .And. STJ->TJ_FILIAL == xFilial("STJ") .And. STJ->TJ_TIPOOS == cTIPOOS .And.;
		STJ->TJ_CODBEM == cCODBEM

			If STJ->TJ_SITUACA == "L" .And. STJ->TJ_TERMINO == "S"
				cNUMOSSTJ  := STJ->TJ_ORDEM
				cPLANOSTJ  := STJ->TJ_PLANO
				dDATARFSTJ := STJ->TJ_DTMRFIM
				cSERVISTJ  := STJ->TJ_SERVICO
				cALIARQSTJ := "STJ"
				Exit
			EndIf
			dbSelectArea("STJ")
			dbSkip(-1)
		End
	Else
		lACHOU := .F.
		nRECSTJ := Recno()
		While !Eof() .And. STJ->TJ_FILIAL == xFilial("STJ") .And. STJ->TJ_TIPOOS == cTIPOOS .And.;
		STJ->TJ_CODBEM == cCODBEM

			If STJ->TJ_SITUACA == "L" .And. STJ->TJ_TERMINO == "S"
				cNUMOSSTJ  := STJ->TJ_ORDEM
				cPLANOSTJ  := STJ->TJ_PLANO
				dDATARFSTJ := STJ->TJ_DTMRFIM
				cSERVISTJ  := STJ->TJ_SERVICO
				cALIARQSTJ := "STJ"
				lACHOU := .T.
			EndIf
			dbSelectArea("STJ")
			dbSkip()
		End

		If !lACHOU
			dbSelectArea("STJ")
			dbGoto(nRECSTJ)
			While !Bof() .And. STJ->TJ_FILIAL == xFilial("STJ") .And. STJ->TJ_TIPOOS == cTIPOOS .And.;
			STJ->TJ_CODBEM == cCODBEM

				If STJ->TJ_SITUACA == "L" .And. STJ->TJ_TERMINO == "S"
					cNUMOSSTJ  := STJ->TJ_ORDEM
					cPLANOSTJ  := STJ->TJ_PLANO
					dDATARFSTJ := STJ->TJ_DTMRFIM
					cSERVISTJ  := STJ->TJ_SERVICO
					cALIARQSTJ := "STJ"
					Exit
				EndIf
				dbSelectArea("STJ")
				dbSkip(-1)
			End
		EndIf
	EndIf

	dbSelectArea("STS")
	dbSetOrder(08)
	dbSeek(xFilial("STS")+cTIPOOS+cCODBEM+"S"+DTOS(Date()),.T.)
	If Eof() .Or. STS->TS_FILIAL <> xFilial("STS") .Or. STS->TS_TIPOOS <> cTIPOOS .Or. STS->TS_CODBEM <> cCODBEM
		dbSkip(-1)
		While !Bof() .And. STS->TS_FILIAL == xFilial("STS") .And. STS->TS_TIPOOS == cTIPOOS .And.;
		STS->TS_CODBEM == cCODBEM

			If STS->TS_SITUACA == "L" .And. STS->TS_TERMINO == "S"
				cNUMOSSTS  := STS->TS_ORDEM
				cPLANOSTS  := STS->TS_PLANO
				dDATARFSTS := STS->TS_DTMRFIM
				cSERVISTS  := STS->TS_SERVICO
				cALIARQSTS := "STS"
				Exit
			EndIf
			dbSelectArea("STS")
			dbSkip(-1)
		End
	Else
		lACHOU := .F.
		nRECSTS := Recno()
		While !Eof() .And. STS->TS_FILIAL == xFilial("STS") .And. STS->TS_TIPOOS == cTIPOOS .And.;
		STS->TS_CODBEM == cCODBEM

			If STS->TS_SITUACA == "L" .And. STS->TS_TERMINO == "S"
				cNUMOSSTS  := STS->TS_ORDEM
				cPLANOSTS  := STS->TS_PLANO
				dDATARFSTS := STS->TS_DTMRFIM
				cSERVISTS  := STS->TS_SERVICO
				cALIARQSTS := "STS"
				lACHOU := .T.
			EndIf
			dbSelectArea("STS")
			dbSkip()
		End

		If !lACHOU
			dbSelectArea("STS")
			dbGoto(nRECSTS)
			While !Bof() .And. STS->TS_FILIAL == xFilial("STS") .And. STS->TS_TIPOOS == cTIPOOS .And.;
			STS->TS_CODBEM == cCODBEM

				If STS->TS_SITUACA == "L" .And. STS->TS_TERMINO == "S"
					cNUMOSSTS  := STS->TS_ORDEM
					cPLANOSTS  := STS->TS_PLANO
					dDATARFSTS := STS->TS_DTMRFIM
					cSERVISTS  := STS->TS_SERVICO
					cALIARQSTS := "STS"
					Exit
				EndIf
				dbSelectArea("STS")
				dbSkip(-1)
			End
		EndIf
	EndIf

	If !Empty(cNUMOSSTJ) .And. !Empty(cNUMOSSTS)

		If dDATARFSTJ > dDATARFSTS
			cNUMOS  :=  cNUMOSSTJ
			cPLANO  :=  cPLANOSTJ
			dDATARF :=  dDATARFSTJ
			cSERVI  :=  cSERVISTJ
			cALIARQ :=  cALIARQSTJ
		Else
			cNUMOS  := cNUMOSSTS
			cPLANO  := cPLANOSTS
			dDATARF := dDATARFSTS
			cSERVI  := cSERVISTS
			cALIARQ := cALIARQSTS
		EndIf

	ElseIf !Empty(cNUMOSSTJ)
		cNUMOS  :=  cNUMOSSTJ
		cPLANO  :=  cPLANOSTJ
		dDATARF :=  dDATARFSTJ
		cSERVI  :=  cSERVISTJ
		cALIARQ :=  cALIARQSTJ
	ElseIf !Empty(cNUMOSSTS)
		cNUMOS  := cNUMOSSTS
		cPLANO  := cPLANOSTS
		dDATARF := dDATARFSTS
		cSERVI  := cSERVISTS
		cALIARQ := cALIARQSTS
	EndIf

	dbSelectArea(cALIASREA)
	dbSetOrder(nINDEXREA)
	dbGoto(nRECREA)

Return {cNUMOS,cPLANO,dDATARF,cSERVI,cALIARQ}

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NGMPROXDC ³ Autor ³ Elisangela Costa      ³ Data ³15/10/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Retorna um vetor com a manutencao do bem mais proxima da    ³±±
±±³          ³da data corrente                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametro³cCODBEM - Codigo do bem    - obrigatorio                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³array - [1] - Codigo do Servico da manutencao               ³±±
±±³          ³        [2] - Data da proxima manutencao                    ³±±
±±³          ³        [3] - Sequencia da manutencao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function NGMPROXDC(cCODBEM)
	Local cSERVICO   := Space(6), dDATAPREV :=  CTOD("  /  "  ), dDataProx :=  CTOD("  /  "  ), cnSEQMAN
	Local lPRIMAN    := .T.
	Local lSEQMAN    := NGVERIFY("STF")

	dbSelectArea("STF")
	dbSetOrder(01)
	dbSeek(xFILIAL("STF")+cCODBEM,.T.)
	While !Eof() .And. STF->TF_FILIAL == xFILIAL("STF") .And. STF->TF_CODBEM == cCODBEM

		If STF->TF_ATIVO == "N"
			dbSelectArea("STF")
			dbSkip()
			Loop
		EndIf

		If STF->TF_PERIODO == "E"
			dbSelectArea("STF")
			dbSkip()
			Loop
		EndIf

		dDataProx := NGXPROXMAN(STF->TF_CODBEM)

		If dDataProx >= date()
			If lPRIMAN
				lPRIMAN := .F.
				cSERVICO  := STF->TF_SERVICO
				dDATAPREV := dDataProx
				cnSEQMAN  := If(lSEQMAN,STF->TF_SEQRELA,STF->TF_SEQUENC)
			Else
				If dDataProx < dDATAPREV
					cSERVICO  := STF->TF_SERVICO
					dDATAPREV := dDataProx
					cnSEQMAN  := If(lSEQMAN,STF->TF_SEQRELA,STF->TF_SEQUENC)
				EndIf
			EndIf
		EndIf
		dbSelectArea("STF")
		dbSkip()
	End

Return {cSERVICO,dDATAPREV,cnSEQMAN}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGDATHOARR³ Autor ³In cio Luiz Kolling    ³ Data ³11/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calula a data e hora real inicio e fim da O.S. ( aCOLS )    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVORDEM   - N£mero da ordem de servico         - Obrigatorio³±±
±±³          ³cVPLANO   - N£mero do plano                    - Obrigatorio³±±
±±³          ³aVHEADER  - Array com os nome dos campos       - Obrigatorio³±±
±±³          ³aVCOLS    - Array com os valores dos campos    - Obrigatorio³±±
±±³          ³lSAIDA    - Indica se a sa¡da de erro na tela  - Obrigatorio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ SE lSAIDA = .T.                                            ³±±
±±³          ³    .T. /ou .F.                                             ³±±
±±³          ³ SENAO                                                      ³±±
±±³          ³    vDATAHOR   Onde:                                        ³±±
±±³          ³    SE  vDATAHOR[1] = .T.                                   ³±±
±±³          ³        Sem problema                                        ³±±
±±³          ³        vDATAHOR[3] = Data real inicio                      ³±±
±±³          ³        vDATAHOR[4] = Hora real inicio                      ³±±
±±³          ³        vDATAHOR[5] = Data real fim                         ³±±
±±³          ³        vDATAHOR[6] = Hora real fim                         ³±±
±±³          ³    SENAO                                                   ³±±
±±³          ³       Problema                                             ³±±
±±³          ³       vDATAHOR[2] = Mensagem do problema                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGDATHOARR(cVORDEM,cVPLANO,aVHEADER,aVCOLS,lSAIDA)
	Local cALIOLD  := Alias(),xn
	Local nINDEOL  := IndexOrd()
	Local dMINSTL  := CtoD("31/12/35")
	Local hMINSTL  := "23:59"
	Local dMAXSTL  := CtoD("  /  /  ")
	Local hMAXSTL  := "00:01"
	Local hMINPSTL := "23:59"
	Local vDATAHOR := {}
	Local cMENSAGE := Space(1)
	Local nTI      := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_TIPOREG" })
	Local nCO      := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_CODIGO" })
	Local nQU      := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_QUANTID" })
	Local nUN      := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_UNIDADE" })
	Local nDI      := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_DTINICI" })
	Local nHO      := aSCAN( aVHEADER, { |x| Trim( Upper(x[2]) ) == "TL_HOINICI" })

	DbselectArea("STJ")
	DbSetOrder(1)
	If !DbSeek(xFilial("STJ")+cVORDEM+cVPLANO)
		cMENSAGE := STR0001+cVORDEM // //"Ordem de servico nao cadastrada "
	Endif
	If Empty(cMENSAGE)
		If stj->tj_situaca == "C"
			cMENSAGE := STR0002+cVORDEM // //"Ordem de servico cancelada "
		Endif
	Endif
	If Empty(cMENSAGE)
		If stj->tj_situaca == "P"
			cMENSAGE := STR0003+cVORDEM // //"Ordem de servico nao foi liberada "
		Endif
	Endif

	If Empty(cMENSAGE)
		If Len(aVCOLS) = 0
			cMENSAGE := STR0004+cVORDEM // //"Nao existem itens para a ordem de servico "
		Endif
		If Empty(cMENSAGE)
			If nTI = 0 .Or. nCO = 0 .Or. nQU = 0 .Or. nUN = 0;
			.Or. nDI = 0 .Or. nHO = 0
				cMENSAGE := STR0004+cVORDEM // //"Nao existem itens para a ordem de servico "
			Else
				For xn := 1 To Len(aVCOLS)
					If !aVCOLS[xn][Len(aVCOLS[xn])]
						cUNIDAD := ALLTRIM(aVCOLS[xn][nUN])
						dINI    := aVCOLS[xn][nDI]
						hINI    := aVCOLS[xn][nHO]
						dFIM    := aVCOLS[xn][nDI]
						hFIM    := aVCOLS[xn][nHO]
						nTEMPO  := HTOM(aVCOLS[xn][nHO])

						If aVCOLS[xn][nTI] == "P"
							dFIM := dINI
							hFIM := hINI
						ElseIf cUNIDAD == "D"
							dFIM := dINI + aVCOLS[xn][nQU]
						ElseIf cUNIDAD == "S"
							dFIM := dINI + (aVCOLS[xn][nQU] * 7)
						ElseIf cUNIDAD == "M"
							nAno := Year(dINI)
							nMES := Month(dINI)
							nDIA := Day(dINI)

							nMES := nMES + aVCOLS[xn][nQU]

							Do While nMES > 12
								nMES := nMES - 12
								nANO := nANO + 01
							EndDo

							nDIA := STRZERO(nDIA,2)
							nMES := STRZERO(nMES,2)
							nANO := Alltrim( STRZERO(nANO,4) )

							dFIM := CtoD(nDIA + "/" + nMES + "/" + nANO)

							Do While Empty(dFIM)
								nDIA := Val(nDIA)-1
								nDIA := STRZERO(nDIA,2)
								dFIM := CtoD(nDIA + "/" + nMES + "/" + nANO)
							EndDo

						Else
							nTEMPO := nTEMPO + (aVCOLS[xn][nQU] * 60)
							nSOMA  := 0

							Do While nTEMPO > 1440
								nSOMA  := nSOMA + 1
								nTEMPO := nTEMPO - 1440
							Enddo

							dFIM := dINI + nSOMA
							hFIM := MtoH(nTEMPO)
						Endif

						If aVCOLS[xn][nTI] == "P"
							dMINSTL := MIN(dMINSTL, aVCOLS[xn][nDI])
							h1STL   := HtoM(hMINPSTL)
							h2STL   := HtoM(aVCOLS[xn][nHO])

							hMINPSTL := MIN(h1STL,h2STL)
							hMINPSTL := MtoH(hMINPSTL)

							dMAXSTL  := MAX(dMAXSTL,aVCOLS[xn][nDI])
							hMAXSTL  := hMINPSTL
						Else
							dMINSTL := MIN(dMINSTL,aVCOLS[xn][nDI])

							h1STL   := HtoM(hMINSTL)
							h2STL   := HtoM(aVCOLS[xn][nHO])

							hMINSTL := MIN(h1STL,h2STL)
							hMINSTL := MtoH(hMINSTL)

							dMAXSTL := MAX(dMAXSTL,dFIM)

							h1STL   := HtoM(hMAXSTL)
							h2STL   := HtoM(hFIM)

							hMAXSTL := MAX(h1STL,h2STL)
							hMAXSTL := MtoH(hMAXSTL)
						Endif
					Endif
				Next xn
			Endif
		Endif
	Endif
	vDATAHOR := If(Empty(cMENSAGE),{.t.,' ',dMINSTL,hMINSTL,dMAXSTL,hMAXSTL},;
	{.f.,cMENSAGE})
	If lSAIDA
		If !vDATAHOR[1]
			MsgInfo(cMENSAGE,STR0005) //"NAO CONFORMIDADE"
			DbSelectArea(cALIOLD)
			DbSetOrder(nINDEOL)
			Return .f.
		Endif
	Endif
	DbSelectArea(cALIOLD)
	DbSetOrder(nINDEOL)
Return vDATAHOR

//----------------------------------------------------------------------------------
/*/{Protheus.doc} NGDELETOS
Deleta a O.S. e seus relacionamnetos.
@type function

@author Inacio Luiz Kolling
@since 17/12/2001

@param cvORDEM   , Caracter, Código da Ordem de Serviço (TJ_ORDEM).
@param cvPLANO   , Caracter, Código do Plano (TJ_PLANO).
@param cMMemo    , Caracter, Concatena string no Memo da O.S (TJ_OBSERVA ou TJ_MMSYP).
@param lRetArray , Lógico  , Retorno via Array ou Lógico.
@return Lógico ou Array.
		lRet 	   , Lógico , Se o registro foi deletado.
		aTypeRet[1], Array	, Deletado ou não (conteúdo Lógico).
		aTypeRet[2], Array	, Mensagem de erro (conteúdo Caracter).
/*/
//----------------------------------------------------------------------------------
Function NGDELETOS(cvORDEM,cvPLANO,cMMemo,lRetArray)

	Local nOS	   := 0
	Local cSolici  := ''
	Local aDelSTL  := {}
	Local cNGMNTAS := SuperGetMV( "MV_NGMNTAS",.F.,"2" )
	Local lIntSFC  := FindFunction("NGINTSFC") .And. NGINTSFC() //Verifica se há integração com módulo Chão de Fabrica [SIGASFC]
	Local lExecSD4 := FindFunction( 'MntUseExec' ) .And. MntUseExec()
	Local lExecSC1 := FindFunction( 'MntExecSC1' ) .And. FwIsInCallStack( 'NG420INC' )
	Local lIntegRM := Trim( SuperGetMV( 'MV_NGINTER', .F., 'N' ) ) == 'M'
	Local lHasSA   := .F.
	Local lIntTEC  := .F.
	Local nX       := 0
	Local aSCDel   := {}
	Local lIntegra := AllTrim( GetNewPar( 'MV_NGINTER', 'N' ) ) == 'M'
	Local aTypeRet := { .T., '' }  // Array para retornar mensagem para MostraErro via JOB
	Local lRet     := .T. //Variável pra tratar retorno da função
	Local lDelSTL  := .T. // Indica se deve deletar insumos.
	Local cOPSC2   := cvORDEM+"OS"
	Local cOP      := PadR( cvORDEM + 'OS001', Len( SD4->D4_OP ) )
	Local cAliasSTL := ''

	//Variável que define se apresentará mensagem de erro (com interface gráfica).
	Default lRetArray := .F.

	dbSelectArea('SC1')
	dbSetOrder(1)

	DbSelectArea('TEW')
	lIntTEC := FindFunction("At040ImpST9") .And. ( TEW->(FieldPos('TEW_TPOS')) > 0 )

	//------------------------------------------------------------------
	// 1 - Deleta os detalhes da OS
	//------------------------------------------------------------------
	If NGIFDBSEEK('STL',cvORDEM+cvPLANO,3)

		If lIntegra

			Do While STL->( !EoF() ) .And. STL->TL_FILIAL == xFilial( 'STL' ) .And.;
					STL->TL_ORDEM == cvORDEM .And. STL->TL_PLANO == cvPLANO
				If !Empty(STL->TL_NUMSA) .And. aScan( aSCDel, {|x| x[1] == STL->TL_NUMSA} )  == 0
					If !NGMUTRAREQ("SCP",STL->TL_NUMSA,xFilial("SCP"),.T., STL->TL_ITEMSA, STL->TL_QUANTID, STL->TL_LOCAL)
						lRet := .F.
					Else
						aAdd( aSCDel, { STL->TL_NUMSA, STL->TL_ITEMSA } )
					EndIf

				EndIf

				dbSelectArea("STL")
				dbSkip()
			End
		EndIf

		dbSelectArea( 'STL' )
		dbSetOrder( 3 ) // TL_FILIAL + TL_ORDEM + TL_PLANO + TL_SEQRELA + TL_TAREFA + TL_TIPOREG + TL_CODIGO
		dbSeek( xFilial( 'STL' ) + cvORDEM + cvPLANO )
		While lRet .And. STL->( !EoF() ) .And. STL->TL_FILIAL == xFilial('STL') .And.;
				STL->TL_ORDEM == cvORDEM .And. STL->TL_PLANO == cvPLANO

			lDelSTL := .T. // Reset da váriavel para controle da deleção dos insumos.

			//Deleta as movimentações internas
			If !Empty(STL->TL_NUMSEQ)
				MNTGERAD3("DE1")
				If NGPRODESP(SD3->D3_COD,.F.,"M")
					NGAtuErp("SD3","INSERT")
				EndIf
			EndIf

			//Deleta as solicitações de compra, atualiza estoque e empenho
			If STL->TL_TIPOREG == 'P'
				
				/*--------------------------------------------------+
				| Valida se é possivel utilizar o ExecAuto MATA381. |
				+--------------------------------------------------*/
				If lExecSD4

					If NGIFDBSEEK( 'SD4', STL->TL_CODIGO + cOP, 1 )
					
						/*----------------------------------------------------+
						| Aciona o ExecAuto MATA381 para exclusão de espenho. |
						+----------------------------------------------------*/
						lRet := MntExecSD4( cOP, STL->TL_CODIGO, STL->TL_LOCAL )[1]

					EndIf
				
				Else

					/*------------------------------------------+
					| Processo antigo para exclusão de espenho. |
					+------------------------------------------*/
					lRet := NGDELETSC1(stl->tl_ordem,'OS001',stl->tl_codigo)
				
				EndIf

			EndIf

			//Deleta Solicitação de Armazém
			If NGCADICBASE('TL_NUMSA','A','STL',.F.) .And. lRet
				If ( lHasSA := !Empty( STL->TL_NUMSA ) )

					//Verificar se essa função existe
					If NGIFDBSEEK('SCP',STL->TL_NUMSA+STL->TL_ITEMSA,1)

						// caso não realize aglutinação de SA, cada SA está ligada diretamente a um STL
						// por isso deve realizar a exclusão da SA dentro desse while
						If cNGMNTAS == "2" .And. !lIntegra

							// S.A. encerrada sem baixa não deve ter o insumo deletado para fins de histórico
							If SCP->CP_QUJE == 0 .And. SCP->CP_STATUS == 'E'
								lDelSTL := .F.
							Else

								/*---------------------------------------------------------------------+
								| Chamada do ExecAuto MATA105 para exclusão da S.A. e relacionamentos. |
								+---------------------------------------------------------------------*/
								lRet := NGGERASA( , , , , , SCP->CP_ITEM, , , , .T., SCP->CP_NUM, 5 )[5]

							EndIf

						ElseIf aScan( aDelSTL, { |x| x[1] == STL->( RecNo() ) } ) == 0
							aAdd( aDelSTL, { STL->( RecNo() ) } )
						EndIf

					EndIf
				EndIf
			EndIf

			// Deleta insumos fora do processo RM e Aglutinado.
			If lRet .And. lDelSTL .And. ( !lHasSA .Or.;
				( !lIntegra .And. cNGMNTAS != '1' ) )

				RecLock( 'STL', .F. )
					dbDelete()
				MsUnlock()

			EndIf

			STL->(dbSkip())

		EndDo

		// caso realize aglutinação de SA, a SA está agrupando todas as STL's
		// por isso deve realizar a exclusão da SA fora do while
		If lRet .And. cNGMNTAS == "1" .And. !Empty( aDelSTL ) .And. !lIntegra
			
			For nX := 1 To Len( aDelSTL )

				lDelSTL := .T. // Reset da váriavel para controle da deleção dos insumos.
				
				dbSelectArea( 'STL' )
				dbGoTo( aDelSTL[nX,1] )

				dbSelectArea( 'SCP' )
				dbSetOrder( 1 )
				If dbSeek( xFilial( 'SCP' ) + STL->TL_NUMSA + STL->TL_ITEMSA )

					If SCP->CP_QUJE == 0 .And. SCP->CP_STATUS == 'E'
						lDelSTL := .F. // S.A. encerrada sem baixa não deve ter o insumo deletado para fins de histórico.
					
					/*---------------------------------------------------------------------+
					| Chamada do ExecAuto MATA105 para exclusão da S.A. e relacionamentos. |
					+---------------------------------------------------------------------*/
					ElseIf !NGGERASA( , , , , , SCP->CP_ITEM, , , , .T., SCP->CP_NUM, 5 )[5]
						
						lRet := .F.
						Exit

					EndIf
				
				EndIf

				// Deleção do insumo.
				If lRet .And. lDelSTL
					NGDELETAREG( 'STL' )
				EndIf

			Next nX

		Else
			For nX := 1 to Len(aSCDel)
				If lRet .And. lIntegra .And. NGIFDBSEEK('SCP',aSCDel[nX][1]+aSCDel[nX][2],1)
					If NGMUCanReq( SCP->( RecNo() ), "SCP")
						
						/*---------------------------------------------------------------------+
						| Chamada do ExecAuto MATA105 para exclusão da S.A. e relacionamentos. |
						+---------------------------------------------------------------------*/
						If NGGERASA( , , , , , SCP->CP_ITEM, , , , .T., SCP->CP_NUM, 5 )[5]

							//Posiciona no Recno da STL
							cAliasSTL := GetNextAlias()
							BeginSQL Alias cAliasSTL
								SELECT
									R_E_C_N_O_ nRec
									FROM
										%table:STL%
									WHERE
										TL_FILIAL  = %xFilial:STL% AND
										TL_NUMSA = %exp:SCP->CP_NUM% AND
										TL_ITEMSA = %exp:SCP->CP_ITEM% AND
										%NotDel%
							EndSQL

							If !Eof()
								dbSelectArea('STL')
								dbSetOrder(1)
								dbGoTo((cAliasSTL)->nRec)
								NGDELETAREG("STL")
							EndIf

						EndIf

					Else
						lRet := .F.
					EndIf
				EndIf
			Next nX
		EndIf

		dbSelectArea("SC1")
		cORDOP := cvORDEM+"OS001"
		cORDOP := cORDOP+Space(Len(sc1->c1_op)-Len(cORDOP))
		If lRet .And. NGIFDBSEEK('SC1',cORDOP,4)
			While !EoF() .And. SC1->C1_FILIAL == xfilial("SC1") .And. SC1->C1_OP == cORDOP
				
				If SC1->C1_TPOP == 'F'

					dbSelectArea('SC1')
					If lIntegRM
						NGMUReques( SC1->( RecNo() ), "SC1", .F., 5)
					EndIf

					If lRet .And. lExecSC1
	
						/*---------------------------------+
						| Deleta a S.C. e relacionamentos. |
						+---------------------------------*/
						lRet := MntExecSC1( SC1->C1_NUM, SC1->C1_ITEM, , 5 )[1]

						If !lRet
							Exit
						EndIf

					Else

						//------------------------------------------------------------------
						// Remove o Numero e Item da SC do Pedido de Compra.
						//------------------------------------------------------------------
						If NGIFDBSEEK('SC7',SC1->C1_PRODUTO,2)
							While !EoF() .And. xFilial('SC7')+SC1->C1_PRODUTO==SC7->C7_FILIAL+SC7->C7_PRODUTO

								If SC1->C1_Num+SC1->C1_ITEM == SC7->C7_NUMSC+SC7->C7_ITEMSC
									RecLock("SC7",.F.)
									Replace C7_NUMSC  With "",;
										C7_ITEMSC With ""
									SC7->(MsUnlock())
								EndIf

								NGDBSELSKIP("SC7")
							EndDo
						EndIf

						//------------------------------------------------------------------
						// Subtrai a qtde do Item da SC no arquivo de entrada de estoque
						//------------------------------------------------------------------
						If NGIFDBSEEK('SB2',SC1->C1_PRODUTO+SC1->C1_LOCAL,1)
							RecLock("SB2",.F.)
							Replace B2_SALPEDI With B2_SALPEDI-(SC1->C1_QUANT-SC1->C1_QUJE)
							SB2->(MsUnlock())
						EndIf

						// Realiza exclusão da S.C. e seus relacionamentos ( SCR ).
						MntDelReq( SC1->C1_NUM, SC1->C1_ITEM, 'SC' )

					EndIf

				EndIf

				NGDBSELSKIP("SC1")
			End
		EndIf

	EndIf

	//------------------------------------------------------------------
	// 2 - Deleta as OPs
	//  O.P deve ser deletada após as exclusões do insumo pois ele
	//  deleta as S.A. e S.C. relacionadas a O.P.
	//------------------------------------------------------------------
	If lRet .And. NGIFDBSEEK('SC2',cOPSC2,1)
		While lRet .And. !EoF() .And. sc2->c2_filial == xFilial('SC2') .And.;
				SC2->C2_NUM+SC2->C2_ITEM == cOPSC2

			aArea := GetArea()
			//Adicionada variável lógica para evitar prosseguir quando apresentar problema
			aTypeRet := A650RotAut(5)
			lRet     := aTypeRet[1]
			RestArea(aArea)
			NGDBSELSKIP("SC2")
		EndDo
	EndIf

	//------------------------------------------------------------------
	// 3 - Deleta as ocorrências do retorno manutenção
	//------------------------------------------------------------------
	If lRet .And. NGIFDBSEEK('STN',cvORDEM+cvPLANO,1)
		While !EoF() .And. STN->TN_FILIAL == xFilial('STN') .And.;
				STN->TN_ORDEM == cvORDEM .And. STN->TN_PLANO == cvPLANO

			NGDELETAREG("STN")
			NGDBSELSKIP("STN")

		EndDo
	EndIf

	//------------------------------------------------------------------
	// 4 - Deleta os bloqueios do bem manutenção
	//------------------------------------------------------------------
	If lRet .And. NGIFDBSEEK('ST3',cvORDEM+cvPLANO,2)
		While !EoF() .And. ST3->T3_FILIAL == xFilial('ST3') .And.;
				ST3->T3_ORDEM == cvORDEM .And. ST3->T3_PLANO == cvPLANO

			NGDELETAREG("ST3")
			NGDBSELSKIP("ST3")

		EndDo
	EndIf

	//------------------------------------------------------------------
	// 5 - Deleta os problemas da OS
	//------------------------------------------------------------------
	If lRet .And. NGIFDBSEEK('STA',cvORDEM+cvPLANO,1)
		While !EoF() .And. STA->TA_FILIAL == xFilial('STA') .And.;
				STA->TA_ORDEM == cvORDEM .And. STA->TA_PLANO == cvPLANO

			NGDELETAREG("STA")
			NGDBSELSKIP("STA")

		EndDo
	EndIf

	//------------------------------------------------------------------
	// 6 - Deleta as etapas da OS
	//------------------------------------------------------------------
	If lRet .And. NGIFDBSEEK('STQ',cvORDEM+cvPLANO,1)
		While !EoF() .And. stq->tq_filial == xFilial('STQ') .And.;
				STQ->TQ_ORDEM == cvORDEM .And. STQ->TQ_PLANO == cvPLANO

			NGDELETAREG("STQ")
			NGDBSELSKIP("STQ")

		EndDo
	EndIf

	//------------------------------------------------------------------
	// 7 - Deleta os bloqueios de funcionários
	//------------------------------------------------------------------
	If lRet .And. NGIFDBSEEK('STK',cvORDEM+cvPLANO,1)
		While !EoF() .And. STK->TK_FILIAL == xFilial('STK') .And.;
				STK->TK_ORDEM == cvORDEM .And. STK->TK_PLANO == cvPLANO

			NGDELETAREG("STK")
			NGDBSELSKIP("STK")

		EndDo
	EndIf

	//------------------------------------------------------------------
	// 8 - Deleta os recursos da Microsiga (SH9) - Bem
	//------------------------------------------------------------------
	NGIFDBSEEK('SH9', "B" + DToS(STJ->TJ_DTPPINI), 4)
	While lRet .And. !EoF() .And. H9_FILIAL + H9_TIPO + DToS(H9_DTINI) == xFilial('SH9') + "B" + DToS(STJ->TJ_DTPPINI)
		cMotivo1 := STR0018 + cvORDEM + STR0019 + cvPLANO //"OS.MANUT."###" PLANO "
		cMotivo2 := STR0020 + cvORDEM //"OS "

		If Trim(cMOTIVO1) == Trim(SH9->H9_MOTIVO) .Or. Trim(cMOTIVO2) == TRIM(SH9->H9_MOTIVO)
			NGDELETAREG("SH9")
		EndIf

		NGDBSELSKIP("SH9")
	EndDo

	//------------------------------------------------------------------
	// 9 - Deleta os recursos da Microsiga (SH9) - Ferramentas
	//------------------------------------------------------------------
	NGIFDBSEEK('SH9', "F" + DToS(STJ->TJ_DTMPINI), 4)
	While lRet .And. !EoF() .And. H9_FILIAL + H9_TIPO + DTOS(H9_DTINI) == xFilial('SH9') + "F" + DToS(STJ->TJ_DTMPINI)
		cMotivo1 := STR0018 + cvORDEM + STR0019 + cvPLANO //"OS.MANUT."###" PLANO "
		cMotivo2 := STR0020 + cvORDEM //"OS "

		If Trim(cMOTIVO1) == TRIM(SH9->H9_MOTIVO) .or.;
				Trim(cMOTIVO2) == TRIM(SH9->H9_MOTIVO)
			NGDELETAREG("SH9")
		EndIf

		NGDBSELSKIP("SH9")
	EndDo

	//------------------------------------------------------------------
	// 10 - Deleta as opções da etapa relacionada à OS
	//------------------------------------------------------------------
	If lRet .And. NGIFDBSEEK('TPQ',cvORDEM+cvPLANO,1)
		While !EoF() .And. TPQ->TPQ_FILIAL == xFilial("TPQ") .And.;
				TPQ->TPQ_ORDEM == cvORDEM .And. TPQ->TPQ_PLANO == cvPLANO

			NGDELETAREG("TPQ")
			NGDBSELSKIP("TPQ")
		EndDo
	EndIf

	//------------------------------------------------------------------
	// 11 - Deleta os motivos de atraso da OS
	//------------------------------------------------------------------
	If lRet .And. NGIFDBSEEK('TPL',cvORDEM,1)
		While !EoF() .And. TPL->TPL_FILIAL == xFilial("TPL") .And.;
				TPL->TPL_ORDEM == cvORDEM

			NGDELETAREG("TPL")
			NGDBSELSKIP("TPL")

		EndDo
	EndIf

	//------------------------------------------------------------------
	// 12 - Deleta a garantia dos insumos
	//------------------------------------------------------------------
	If lRet .And. NGIFDBSEEK('TPZ',cvORDEM+cvPLANO,2)
		While !EoF() .And. TPZ->TPZ_FILIAL == xFilial("TPZ") .And.;
				TPZ->TPZ_ORDEM == cvORDEM .And. TPZ->TPZ_PLANO == cvPLANO

			NGDELETAREG("TPZ")
			NGDBSELSKIP("TPZ")

		EndDo
	EndIf

	//------------------------------------------------------------------
	// 13 - Cancela a OS de Manutenção
	//------------------------------------------------------------------
	If lRet .And. NGCADICBASE("TTY_ORDEM","A","TTY",.F.)
		NGIFDBSEEK('TTY',cvORDEM+cvPLANO,1)
		While !EoF() .And. TTY->(TTY_FILIAL+TTY_ORDEM+TTY_PLANO) == xFILIAL("TTY")+cvORDEM+cvPLANO

			NGDELETAREG("TTY")
			NGDBSELSKIP("TTY")

		EndDo
	EndIf

	//------------------------------------------------------
	// Integração Mensagem Única para cancelamento de O.S.
	//------------------------------------------------------
	If AllTrim( GetNewPar("MV_NGINTER", "N") ) == "M"
		If lRet .And. NGIFDBSEEK('STJ', cvOrdem + cvPlano, 1) .And. STJ->TJ_SITUACA == 'L'

			If !NGMUCanMnO( STJ->( RecNo() ) )
				lRet := .F.
			EndIf

		EndIf
	EndIf

	//------------------------------------------------------------------
	// 14 - Cancela a OS de Manutenção
	//------------------------------------------------------------------
	dbSelectArea("STJ")
	If STJ->TJ_FILIAL <> xFilial("STJ") .Or. STJ->TJ_ORDEM <> cvORDEM .Or.;
			STJ->TJ_PLANO <> cvPLANO

		NGIFDBSEEK("STJ",cvORDEM+cvPLANO,1)
	EndIf

	If lRet
		If !EoF() .And. !BoF() .And. STJ->TJ_FILIAL = xFilial("STJ") .And. STJ->TJ_ORDEM = cvORDEM .And.;
				STJ->TJ_PLANO = cvPLANO

			RecLock('STJ', .F.)

			STJ->TJ_SITUACA := 'C'
			STJ->TJ_USUARIO := IIf(Len(STJ->TJ_USUARIO) > 15, cUsername, Substr(cUsuario, 7, 15) )

			If cMMemo <> Nil
				If NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
					MsMM(,80,,AllTrim(NGMEMOSYP(STJ->TJ_MMSYP))+CRLF+CRLF+cMMemo,1,,,"STJ","TJ_MMSYP")
				Else
					STJ->TJ_OBSERVA := AllTrim(STJ->TJ_OBSERVA) + CRLF + CRLF + cMMemo
				EndIf
			EndIf

			MsUnlock('STJ')

		EndIf

		cCodBem := STJ->TJ_CODBEM

		If AllTrim( GetNewPar("MV_NGMULOS", "N") ) <> "S"
			If NGIFDBSEEK('TQB',cvORDEM,4)
				RecLock('TQB',.F.)
				TQB->TQB_ORDEM  := Space( TamSX3('TQB_ORDEM')[1] )
				TQB->TQB_SOLUCA := "D"
				MsUnlock('TQB')
			EndIf
		Else
			If NGIFDBSEEK('TT7',cvORDEM,2)
				cSolici := TT7->TT7_SOLICI
				NGDELETAREG("TT7")
			EndIf

			NGIFDBSEEK('TT7',cSolici,1)
			While !EoF() .And. TT7->TT7_FILIAL == xFilial("TT7") .And. TT7->TT7_SOLICI == cSolici
				If TT7->TT7_TERMIN == "N"
					nOS++
				EndIf

				NGDBSELSKIP("TT7")
			EndDo

			If nOs == 0
				If NGIFDBSEEK('TQB', cSolici, 1)
					RecLock('TQB',.F.)
					TQB->TQB_SOLUCA := "D"
					MsUnlock('TQB')
				EndIf
			EndIf
		EndIf

		NGDBAREAORDE("TQB",1)

		//------------------------------------------------------------------
		// Deleta OS da Programação
		//------------------------------------------------------------------
		If NGCADICBASE('TT2_FILIAL','A','TT2',.F.)

			NGIFDBSEEK('TT2',cvORDEM+cvPLANO,2)
			While !EoF() .And. xFilial("TT2")+cvORDEM+cvPLANO == TT2->TT2_FILIAL+TT2->TT2_ORDEM+TT2->TT2_PLANO

				NGDELETAREG("TT2")
				NGDBSELSKIP("TT2")

			EndDo
		EndIf

		//------------------------------------------------------------------
		// Deleta Ferramentas da Programação
		//------------------------------------------------------------------
		If NGCADICBASE('TT3_FILIAL','A','TT3',.F.)

			NGIFDBSEEK('TT3',cvORDEM+cvPLANO,2)
			While !EoF() .And. xFilial("TT3")+cvORDEM+cvPLANO == TT3->TT3_FILIAL+TT3->TT3_ORDEM+TT3->TT3_PLANO

				NGDELETAREG("TT3")
				NGDBSELSKIP("TT3")

			EndDo
		EndIf

		//------------------------------------------------------------------
		// Deleta Produtos da Programação
		//------------------------------------------------------------------
		If NGCADICBASE('TT4_FILIAL','A','TT4',.F.)

			NGIFDBSEEK('TT4',cvORDEM+cvPLANO,2)
			While !EoF() .And. xFilial("TT4")+cvORDEM+cvPLANO == TT4->TT4_FILIAL+TT4->TT4_ORDEM+TT4->TT4_PLANO

				NGDELETAREG("TT4")
				NGDBSELSKIP("TT4")

			EndDo
		EndIf

		//------------------------------------------------------------------
		// Deleta MDO da Programação
		//------------------------------------------------------------------
		If NGCADICBASE('TT5_FILIAL','A','TT5',.F.)

			NGIFDBSEEK('TT5',cvORDEM+cvPLANO,2)
			While !EoF() .And. xFilial("TT5")+cvORDEM+cvPLANO == TT5->TT5_FILIAL+TT5->TT5_ORDEM+TT5->TT5_PLANO

				NGDELETAREG("TT5")
				NGDBSELSKIP("TT5")

			EndDo
		EndIf

		//------------------------------------------------------------------
		// Deleta o historico de alteracao da OS
		//------------------------------------------------------------------
		If NGCADICBASE("TQ9_ORDEM","A","TQ9",.F.)

			NGIFDBSEEK('TQ9',cvORDEM+cvPLANO,1)
			While !EoF() .And. TQ9_FILIAL + TQ9_ORDEM + TQ9_PLANO == xFILIAL("TQ9") + cvORDEM + cvPLANO

				NGDELETAREG("TQ9")
				NGDBSELSKIP("TQ9")

			EndDo
		EndIf

		If lIntSFC .And. !Empty( NGVRFMAQ(cCodBem) )
			NGSFCDELPP(cvORDEM)
		EndIf

		If lIntTEC
			At800OsxTec( IsInCallStack("At800AtuOs"), .T. /*lGravaCusto*/ )
		EndIf

		dbSelectArea("STJ")
		If ExistBlock("NGDELDIN")
			ExecBlock("NGDELDIN",.F.,.F.)
		EndIf
	EndIf

	// Verifica o valor do lRet para alterar o valor do retorno.
	If aTypeRet[1] .And. !lRet
		aTypeRet[1] := lRet
	EndIf

Return IIf( lRetArray, aTypeRet, aTypeRet[1] )

//---------------------------------------------------------------------
/*/{Protheus.doc} NGEMPALM
Verifica se o código do almaxarifado informado é válido

@param cALMOXA

@author Inacio Luiz Kolling
@since 26/09/2001
@version MP12
@return lRETO
/*/
//---------------------------------------------------------------------
Function NGEMPALM(cALMOXA)
	Local lRETO := .T.
	If Empty(cALMOXA)
		Help(" ",1,"NGALMOINVAL")
		lRETO := .F.
	EndIf
Return lRETO

//---------------------------------------------------------------------
/*/{Protheus.doc} NGDELETSC1
Programa de exclusão de ITEM sc1 atu. SB2 e SD4

@param cvORDEM
@param cvITEM
@param cvPROD

@author Inacio Luiz Kolling
@since 17/12/2001
@version MP12
@return lRet, lógico, indica se a validação está correta e se a ação
						  será efetuada
@return .T.
/*/
//---------------------------------------------------------------------
Function NGDELETSC1(cvORDEM,cvITEM,cvPROD)
	Local cCODOP1 := cvORDEM+cvITEM
	Local cCODOP2 := cCODOP1+Space(Len(sc1->c1_op)-Len(cCODOP1))
	Local lPCriaSDC := .F.
	Local lRet := .T.

	If NGIFDBSEEK('SC1',cvORDEM+cvITEM,4)
		While !eof() .and. sc1->c1_filial == xfilial("SC1") .And. sc1->c1_op == cCODOP2

			If sc1->c1_produto == cvPROD .and.;
			sc1->c1_tpop == 'F'

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Remove o Numero e Item da SC do Pedido de Compra.              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If NGIFDBSEEK('SC7',SC1->C1_PRODUTO,2)
					While !Eof() .And. xFilial('SC7')+SC1->C1_PRODUTO==SC7->C7_FILIAL+SC7->C7_PRODUTO
						If SC1->C1_Num+SC1->C1_ITEM == SC7->C7_NUMSC+SC7->C7_ITEMSC
							RecLock("SC7",.F.)
							Replace C7_NUMSC  With "",;
							C7_ITEMSC With ""
							SC7->(MsUnlock())
						EndIf
						NGDBSELSKIP("SC7")
					End
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Subtrai a qtde do Item da SC no arquivo de entrada de estoque  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If NGIFDBSEEK('SB2',cvPROD+SC1->C1_LOCAL,1)
					RecLock("SB2",.F.)
					Replace B2_SALPEDI With B2_SALPEDI-(SC1->C1_QUANT-SC1->C1_QUJE)
					SB2->(MsUnlock())
				EndIf
				dbSelectArea('SC1')
				If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"  //Mensagem Unica
					If !IsIncallStack("NGMUStoTuO") .And. !IsIncallStack("NGMUReques")
						//NGMUCanReq(SC1->(RecNo()),"SC1")
						lRet := NGMUReques(SC1->(RecNo()),"SC1",.F.,5)
					EndIf
				EndIf

				If lRet

					// Realiza exclusão da S.C. e seus relacionamentos ( SCR ).
					MntDelReq( SC1->C1_NUM, SC1->C1_ITEM, 'SC' )

				EndIf

				Exit

			Endif
			NGDBSELSKIP("SC1")
		End
	Endif

	// DELETA OS EMPENHOS DE PRODUTOS
	If lRet .And. NGIFDBSEEK("SD4",cvPROD+cvORDEM+cvITEM,1)

		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1") + SD4->D4_COD )
			If SB1->B1_LOCALIZ == "S"
				lPCriaSDC := .T.
			Else
				lPCriaSDC := .F.
			EndIf
		EndIf

		aTravas := {}
		GravaEmp(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_QUANT,0,'','','','',SD4->D4_OP,Str(1,3),NIL,NIL,'SC2',NIL,SD4->D4_DATA,@aTravas,.T.,.F.,.T.,.T.,NIL,NIL,.F.)

		dbSelectArea( 'SB1' )
		dbSetOrder( 1 ) // B1_FILIAL + B1_COD
		If dbseek( xFilial( 'SB1' ) + SD4->D4_COD ) .And. SB1->B1_LOCALIZ == 'S'

			dbSelectArea( 'SDC' )
			dbSetOrder( 2 ) // DC_FILIAL + DC_PRODUTO + DC_LOCAL + DC_OP + DC_TRT + DC_LOTECTL + DC_NUMLOTE + DC_LOCALIZ + DC_NUMSERI
			If dbSeek( xFilial( 'SDC' ) + SD4->D4_COD + SD4->D4_LOCAL + SD4->D4_OP )
				
				While SDC->( !EoF() ) .And. SD4->D4_COD == SDC->DC_PRODUTO .And. SD4->D4_LOCAL == SDC->DC_LOCAL .And.;
					SD4->D4_OP == SDC->DC_OP .And. xFilial( 'SDC' ) == SDC->DC_FILIAL

					dbSelectArea( 'SBF' )
					dbSetOrder( 1 ) // BF_FILIAL + BF_LOCAL + BF_LOCALIZ + BF_PRODUTO + BF_NUMSERI + BF_LOTECTL + BF_NUMLOTE
					If dbSeek( xFilial( 'SBF' ) + SDC->DC_LOCAL + SDC->DC_LOCALIZ + SDC->DC_PRODUTO )
						
						While SBF->( !EoF() ) .And. SDC->DC_LOCAL == SBF->BF_LOCAL .And. SDC->DC_LOCALIZ == SBF->BF_LOCALIZ .And.;
							SDC->DC_PRODUTO == SBF->BF_PRODUTO .And. xFilial( 'SBF' ) == SBF->BF_FILIAL
							
							// Retira quantidade empenhada relacionado ao endereço.
							RecLock( 'SBF', .F. )
							SBF->BF_EMPENHO := IIf( ( SBF->BF_EMPENHO - SD4->D4_QUANT ) < 0, 0, ( SBF->BF_EMPENHO - SD4->D4_QUANT ) )
							SBF->( MsUnLock() )

							SBF->( dbSkip() )
							
						End

					EndIf

					// Deleta registro quantidade da composição do empenho atrelado a OP.
					RecLock( 'SDC', .F. )
					dbDelete()
					SDC->( MsUnLock() )

					SDC->( dbSkip() )

				End

			EndIf
			
		EndIf

		NGAtuErp("SD4","DELETE")
		NGDELETAREG("SD4")

	EndIf
	
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} NGTPCONTCAR
Consistência do tipo do conteúdo de uma variável.

@author Pedro Henrique Soares de Souza
@since 25/11/11

@param cTipo Tipo da variável
@param xConteudo Conteúdo da variável (sempre em caracter)

@return .T./.F. Indicando se o conteúdo está correspondente com o tipo.
/*/
//---------------------------------------------------------------------
Function NGTPCONTCAR(cTipo, xConteudo, lSaida)

	Local nI, nMenos, nPonto

	Local lNumeric	:= .F.

	Local cTipoMsg	:= Space(1)
	Local cConteudo	:= AllTrim(If(cTipo == "D" .And. ValType(xConteudo) == "D" ,DtoC(xConteudo),xConteudo))

	Default lSaida := .T.

	Store 0  To nI, nMenos, nPonto

	If cTipo == "N"

		//--------------------------------------------------------------
		//Separa os caractere de forma que cada um seja uma posição do
		//array e verifica se tem apenas números, pontos ou sinal
		//--------------------------------------------------------------
		For nI := 1 To Len( cConteudo )
			lNumeric := isDigit( SubStr(cConteudo, nI, 1) ) .Or.;
			SubStr(cConteudo, nI, 1) == "." .Or.;
			SubStr(cConteudo, nI, 1) == "-"

			If !lNumeric
				Exit
			Endif

			IIf( SubStr(cConteudo, nI, 1) == '.', nPonto++, Nil )
			IIf( SubStr(cConteudo, nI, 1) == '-', nMenos++, Nil )
		Next nI

		If lNumeric
			//--------------------------------------------------------------
			//Verifica se contém no máximo 1 ponto (utilizado para decimais)
			//e se o ponto não está no primeiro nem no último caractere.
			//--------------------------------------------------------------
			lNumeric := (nPonto <= 1 .And. nMenos <= 1)

			If lNumeric
				//--------------------------------------------------------------------
				// Lógica da validação de ponto e sinal
				//--------------------------------------------------------------------
				//Se tem ponto e NÃO tem menos: O '.' não pode ser o primeiro e nem o
				//último caractere.
				//-----
				//Se tem ponto e tem menos: O '-' deve ser o primeiro caratere e o '.'
				//não pode ser o segundo e nem o último caractere.
				//-----
				//Se NÃO tem ponto e tem menos: O '-' deve ser o primeiro caractere.
				//-----
				//Se NÃO tem ponto e NÃO tem menos: Está ok.
				//--------------------------------------------------------------------
				lNumeric :=	((nPonto == 0 .And. nMenos == 0) .Or.;
				(nPonto == 0 .And. nMenos == 1 .And. SubStr(cConteudo, 1, 1) == '-' ) .Or.;
				(nPonto == 1 .And. nMenos == 0 .And. SubStr(cConteudo, 1, 1) != '.' .And.;
				SubStr(cConteudo, Len(cConteudo), 1) != '.') .Or.;
				(nPonto == 1 .And. nMenos == 1 .And. SubStr(cConteudo, 1, 1) == '-' .And.;
				SubStr(cConteudo, 2, 1) != '.' .And. SubStr(cConteudo, Len(cConteudo), 1) != '.') )

				If lNumeric
					//Verifica se o conteúdo é numério(apenas confirmação)
					lNumeric := ValType( &(cConteudo) ) == 'N'
				Endif
			Endif
		Endif

		If !lNumeric
			cTipoMsg := STR0227 //"numérico"
		Endif

	ElseIf cTipo == "L"

		If Upper( AllTrim(cConteudo) ) <> ".T." .And. Upper( Alltrim(cConteudo) ) <> ".F."
			cTipoMsg := STR0228 //"lógico"
		EndIf

	ElseIf cTipo == "D"
		If Empty( cConteudo )
			cTipoMsg := STR0229 //"data"
		EndIf
	EndIf

	If !Empty(cTipoMsg)
		If lSaida .And. GetRemoteType() > -1 // -1 = Job, Web ou Working Thread (Sem remote)
			ShowHelpDlg( "CONTEUDO", { STR0230 }, 5,; 		//"O valor digitado não corresponde ao tipo utilizado."
			{ STR0231 + cTipoMsg + "."}, 5)		//"Informe um valor do tipo "
		EndIf
		Return .F.
	Endif
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGDTINIC
Funcao para validacao da data inicio do insumo

@author NG Informática
@since 25/11/11
@version MP12
@return Nil
/*/
//---------------------------------------------------------------------
Function NGDTINIC()

	Local dDATA
	If !NAOVAZIO( M->TL_DTINICI )
		Return .F.
	EndIf
	dDATA := If( !EMPTY( STJ->TJ_DTMPINI ), STJ->TJ_DTMPINI, STJ->TJ_DTORIGI )
	If M->TL_DTINICI < dDATA
		If !MSGYESNO( STR0253+" '"+DTOC(dDATA)+"'."+STR0215, STR0018 ) //Data de inicio informada e menor do que a data prevista para inicio da OS. # Deseja continuar? # Atenção
			Return .F.
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGINSPRODDH
Verifica se tem so insumos do tipo produto e calcula as
datas e horas reais de termino da ordem de servico

@param cOrdem - Numero da ordem de servico
@param cPlano - Numero do plano
@author NG Informática
@since 06/10/2009
@version MP12
@return vRetins  - Vetor com os dados onde: 	[1] .t.,.f. (so produto)
[2] Data real inicio
[3] Hora real inicio
[4] Data real fim
[5] Hora real fim
/*/
//---------------------------------------------------------------------
Function NGINSPRODDH( cOrdem, cPlano )

	Local aAreaAt := GetArea()
	Local vRetins := {.t.,Ctod("  /  /  "),Space(5),Ctod("  /  /  "),Space(5)}
	Local dDtRini,dDtRfim,cHoRini,cHoRfim,cSequen := "stl->tl_seqrela <> '0  '"

	Store Ctod( "  /  /  " ) To dDtRini,dDtRfim
	Store Space( 5 )         To cHoRini,cHoRfim

	If NGIFDBSEEK( "STJ", cOrdem + cPlano, 1 )
		If stj->tj_situaca = "L" .And. stj->tj_termino = "N"
			If NGCHKRET( STJ->TJ_ORDEM, STJ->TJ_PLANO )
				cSequen := "stl->tl_seqrela = '0  '"
			EndIf
			NGIFDBSEEK("STL",cOrdem+cPlano,1)
			While !Eof() .And. stl->tl_filial = Xfilial( "STL" ) .And. stl->tl_ordem = cOrdem;
			.And. stl->tl_plano = cPlano
				If &( cSequen )
					If stl->tl_tiporeg <> "P"
						If vRetins[1]
							vRetins[1] := .f.
						EndIf
						If Empty( dDtRini )
							dDtRini := stl->tl_dtinici
							dDtRfim := stl->tl_dtfim
							cHoRini := stl->tl_hoinici
							cHoRfim := stl->tl_hofim
						Else
							If stl->tl_dtinici < dDtRini
								dDtRini := stl->tl_dtinici
								cHoRini := stl->tl_hoinici
							ElseIf stl->tl_dtinici = dDtRini .And. stl->tl_hoinici < cHoRini
								cHoRini := stl->tl_hoinici
							EndIf
							If stl->tl_dtfim > dDtRfim
								dDtRfim := stl->tl_dtfim
								cHoRfim := stl->tl_hofim
							ElseIf stl->tl_dtfim = dDtRfim .And. stl->tl_hofim > cHoRfim
								cHoRfim := stl->tl_hofim
							EndIf
						EndIf
					EndIf
				EndIf
				DbSkip()
			End
			vRetins := If(vRetins[1],{.t.,stj->tj_dtmpini,stj->tj_hompini,stj->tj_dtmpfim,stj->tj_hompfim},;
			{.f.,dDtRini,cHoRini,dDtRfim,cHoRfim})
		EndIf
	EndIf
	RestArea(aAreaAt)

Return vRetins

//---------------------------------------------------------------------
/*/{Protheus.doc} MntWhenCal
Define se possibilita edição do campo Usa Calendário [ TL_USACALE ].
Situada no X3_WHEN do campo em questão.

@author	 Elynton Fellipe Bazzo
@since	 12/03/2015
@version MP11 e MP12
@return	 lRet - Indica se será possível editar o campo.
/*/
//---------------------------------------------------------------------
Function MntWhenCal()

	Local lRet := .T.
	Local nTipReg := 0

	If FunName() == "MNTA401" //Consistência da tarefa
		If !lCalend //Se não utiliza calendário
			lRet := .F.
		EndIf
	ElseIf FunName() == "MNTA400" .Or. FunName() == "MNTA460" .Or. FunName() == "MNTA360"  //Retorno Tarefas - Retorno Reformas
		If M->TL_TIPOREG <> "M" //Se o tipo de registro for diferente de Mão-de-Obra
			lRet := .F. //Fecha o When
		EndIf
	Else
		If Type( "cPROGRAMA" ) <> "U"
			If Type( "aCols" ) == "A" .And. Type( "aHeader" ) == "A" // Se aCols/aHeader for array.

				// Se existir o campo "TL_TIPOREG" no aHeader, atribui a variável.
				nTipReg := aSCAN( aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_TIPOREG" })

				/*/Se o campo existir no aHeader ( E ) a memória do item for diferente da linha da getdados ( E ) a memória
				do campo for diferente de mão-de-obra ( OU ) a linha da getdados for do tipo diferente de mão-de-obra. /*/
				If nTipReg > 0
					If (M->TL_TIPOREG == aCols[n][nTipReg] .And. M->TL_TIPOREG <> "M") .Or. aCols[n][nTipReg] <> "M"
						lRet := .F. //Fecha o When
					EndIf
				EndIf
			Else
				If M->TL_TIPOREG <> "M" //Se o tipo de registro for diferente de Mão-de-Obra
					lRet := .F. //Fecha o When
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} NGVLDSTL
Validação para não permitir FINALIZAR A O.S. com recursos trabalhando nela.
(Verifica se existe insumo mão de obra com data e hora inicial igual a data e hora final.

@author Maria Elisandra de Paula
@since 23/10/2015
@version P12
@return Nil
/*/
//----------------------------------------------------------------------------------------
Function NGVLDSTL(cOrdem,cPlano,lShowHelp)

	Local cAliasQry	:= GetNextAlias()
	Local cQuery 	:= ""
	Local lRet 		:= .t.
	Local aArea		:= GetArea()
	Default cOrdem 	:= ""
	Default cPlano  := ""
	Default lShowHelp  := .t.

	cQuery := " SELECT TL_ORDEM  FROM " + RetSqlName("STL") + " WHERE TL_TIPOREG = 'M' AND TL_SEQRELA <> '0'"

	If !Empty(cOrdem)
		cQuery += " AND TL_ORDEM = " +  ValtoSql(cOrdem)
	EndIf

	If !Empty(cPlano)
		cQuery += " AND TL_PLANO = " +  ValtoSql(cPlano)
	EndIf

	cQuery += " AND TL_DTFIM = TL_DTINICI AND TL_HOFIM = TL_HOINICI "
	cQuery += " AND TL_FILIAL = " + ValtoSql(xFilial('STL')) + " AND D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)
	If !Eof()
		If lShowHelp
			Help(1,"","MNTHRIGUAL",,(cAliasQry)->TL_ORDEM,3,0)
		EndIf
		lRet := .f.
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
Return lRet
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} NGVLDSTL
Verifica se o apontamento foi realizado atraveS da rotina de apontamento de MDO(MNTA422) e
se houve alterações que podem impactar neste apontamento

@param aVetSTL:	[1]Ordem
[2]Funcionário banco
[3]Tarefa no banco
[4]Etapa no banco
[5]Data Inicial banco
[6]Hora Inicial banco
[7]Data Final banco
[8]Hora Final banco
[9]Código do Funcionário memória
[10]Código da Tarefa na memória
[11]Código da Etapa memória
[12]Data Inicial na memória
[13]Hora Inicial na memória
[14]Data Final na memória
[15]Hora Final na memória

@author Maria Elisandra de Paula
@since 10/12/2015
@version P12
@return Nil
/*/
//----------------------------------------------------------------------------------------
Function NGVLDSTL2(aVetSTL)
	Local aArea	:= GetArea()
	Local cMens	:= ""
	Local lRet := .t.

	If DtoS(aVetSTL[5]) + aVetSTL[6]  ==  DtoS(aVetSTL[7] ) + aVetSTL[8] ;//verifica se DtInicio+Hrinicio e DataFim+HrFim são iguais
	.And. (aVetSTL[2]  <> aVetSTL[9]; //verifica se houve alterações: funcionário
	.or. aVetSTL[3]  <> aVetSTL[10];//tarefa
	.or. aVetSTL[4]  <> aVetSTL[11];//etapa
	.or. aVetSTL[5]  <> aVetSTL[12];//Dt inicio
	.or. aVetSTL[6]  <> aVetSTL[13];//Hr inicio
	.or. aVetSTL[7]  <> aVetSTL[14];//Dt final
	.or. aVetSTL[8]  <> aVetSTL[15])//Hr final

		cMens := STR0250 +  chr(13)  //"As alterações realizadas neste registro impactarão diretamente no apontamento: "
		cMens += STR0242 + Alltrim(aVetSTL[2]) + " - " + Alltrim(NGSEEK("ST1",aVetSTL[2],1,"T1_NOME")) +   chr(13)//"Funcionário.: "
		cMens += STR0243 + Alltrim(aVetSTL[1]) + chr(13)//"Ordem.........: "
		cMens += STR0244 + Alltrim(aVetSTL[3]) + " - " + Alltrim(NGSEEK("TT9",aVetSTL[3],1,"TT9->TT9_DESCRI")) +   chr(13)//"Tarefa..........: "
		cMens += STR0245 + Alltrim(aVetSTL[4]) + " - " + Alltrim(NGSEEK("TPA",aVetSTL[4],1,"TPA->TPA_DESCRI")) +   chr(13)//"Etapa...........: "
		cMens += STR0246 + Dtoc(aVetSTL[5])  + chr(13) // "Data............: "
		cMens += STR0247 + aVetSTL[6]  + chr(13)//"Hora............: "

		If .not. Empty(GetNewPar("MV_NGHROCI",""))
			cMens += STR0248 //"O reporte de horas deste funcionário deverá ser realizado manualmente."
		EndIf

		cMens += STR0249 //"Deseja alterar mesmo assim ? "

		If .not. MsgYesNo(cMens)
			lRet := .f.
		EndIf
	EndIf

	RestArea(aArea)
	Return lRet

	//---------------------------------------------------------------------
	/*/{Protheus.doc} NGVLDSTL3(cColab,cOrdem,cPlano,cTarefa,cEtapa)
	Se todos os parâmetros estiverem preenchidos verifica se colaborador esta em execução em outra Etapa da mesma os
	Senão verifica se colaborador esta em execução em alguma etapa

	@param cCodFunc	- colaborador a ser pesquisado
	cOrdem 	- OS a ser pesquisada
	cPlano - Código do plano
	cTarefa - tarefa
	cEtapa - etapa

	@author Maria Elisandra de Paula
	@since 25/08/2014
	@version P11
	@return 	aRet[1] - Ordem
	aRet[2] - 	Veiculo
	aRet[3] - 	Tarefa
	aRet[4] - Etapa
	aRet[5] - nome do BEM
	aRet[6] - descrição da TAREFA
	aRet[7] - descrição da Etapa
	/*/
//---------------------------------------------------------------------
Function NGVLDSTL3(cCodFunc,cOrdem,cPlano,cTarefa,cEtapa)

	Local aArea     := GetArea()
	Local cQuery    := " "
	Local cAliasQry	:= GetNextAlias()
	Local aRet 	    := {}

	Default cOrdem	:= ""
	Default cPlano	:= ""
	Default cTarefa	:= ""
	Default cEtapa	:= ""

	//query verifica se colaborador esta em execução em outra OS
	cQuery += " SELECT TL_ORDEM,TJ_CODBEM , TL_TAREFA, TL_ETAPA FROM " + RetSqlName("STL") + " STL "
	cQuery += " INNER JOIN "+ RetSqlName("STJ") + " STJ ON TJ_ORDEM = TL_ORDEM AND TJ_PLANO = TL_PLANO"
	cQuery += " WHERE TL_CODIGO = " + ValToSql(cCodFunc) + " AND TL_TIPOREG = 'M' AND TL_SEQRELA <> '0'"
	cQuery += " AND TL_HOFIM = TL_HOINICI AND TL_DTFIM = TL_DTINICI "

	If !Empty(cOrdem)
		cQuery += 	" AND (TL_ORDEM + TL_PLANO <> " + ValToSql(cOrdem + cPlano) + " OR (TL_ORDEM =  " + ValToSql(cOrdem) + " AND TL_PLANO = " + ValToSql(cPlano)
		cQuery += 	"				 AND TL_TAREFA + TL_ETAPA <> " + ValToSql(cTarefa + cEtapa) + ")) "
	EndIf

	cQuery += 	" AND TJ_TERMINO = 'N' "
	cQuery += 	" AND TL_FILIAL = " + ValToSql(xFilial('STL'))
	cQuery += 	" AND TJ_FILIAL = " + ValToSql(xFilial('STJ'))
	cQuery += 	" AND STL.D_E_L_E_T_ <> '*' AND STJ.D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry , .T. , .T.  )

	dbSelectArea((cAliasQry))
	If !Eof()
		aRet := {	(cAliasQry)->TL_ORDEM,;
		(cAliasQry)->TJ_CODBEM,;
		(cAliasQry)->TL_TAREFA,;
		(cAliasQry)->TL_ETAPA ,;
		Substr(NGSEEK("ST9",(cAliasQry)->TJ_CODBEM	,1, "T9_NOME"   ),1,30),;
		Substr(NGSEEK("TT9",(cAliasQry)->TL_TAREFA	,1, "TT9_DESCRI"),1,30),;
		Substr(NGSEEK("TPA",(cAliasQry)->TL_ETAPA	,1, "TPA_DESCRI"),1,30)}
	EndIf

	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
	Return aRet

	//---------------------------------------------------------------------
	/*/{Protheus.doc} MNTValDBl()
	Função que valida a data de baixa de estoque com a ultima data de bloqueio (MV_DBLQMOV);
	@author Rodrigo Luan Backes
	@since 19/04/16
	@version P11 e P12
	@return booleano
	/*/
//---------------------------------------------------------------------
Function MNTValDBl(dDtInic)

	Local lRet := .T.
	Local dDtBlqMov := SuperGetMV("MV_DBLQMOV",.F.,STOD("")) //data de bloqueio de movimentações no estoque.
	Local cUsaInt3  := AllTrim(GetMv("MV_NGMNTES"))

	If !Empty(dToS(dDtInic))
		If cUsaInt3 == "S"
			If  dDtInic <= dDtBlqMov
				MsgInfo( STR0251 + DTOC( dDtBlqMov ) + "." ) //"Não pode haver baixa de estoque se a data da mesma for menor ou igual que a data de bloqueio (MV_DBLQMOV): "
				lRet := .F.
			EndIf
		EndIf
	EndIf

	Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} NGEMPMATE()
Gera OPs para estrutura do produto
@author Inacio Luiz Kolling
@since 17/12/2001
@version P12
@return booleano
/*/
//---------------------------------------------------------------------
Function NGEMPMATE()

	Local aHeadTemp
	Local ccALIAS := Alias()
	// VARIAVEIS USADAS NA GERA€ÇO DE OPs DA ESTRUTURA

	PRIVATE cSeqC2   := "000"
	PRIVATE MV_PAR02 := 1  // Considera saldo apenas Local Padrao ? 1-sim  2-nao
	PRIVATE MV_PAR06 := 1  // Gera SC - Por Empenho / Por OP / Por Data
	PRIVATE MV_PAR08 := 1  // Sugere Lotes a Empenhar Sim / Nao
	PRIVATE lEnd     := .F.
	PRIVATE l650Auto := .t.
	Private lCONSTERC := .T.
	Private lconsNPT  := .t.
	Private aDataOPC1:={},aDataOPC7:={},aOPC1:={},aOPC7:={}
	Private LGERAR 	 := .F.

	If !NGIFDBSEEK('SB2',SC2->C2_PRODUTO+SC2->C2_LOCAL,1)
		CriaSB2(SC2->C2_PRODUTO,SC2->C2_LOCAL)
		SB2->(MsUnlock())
	EndIf

	dbSelectArea("SC2")
	A650PutBatch(C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN,,SC2->C2_DATPRI,SC2->C2_DATPRF)

	nOps := 0

	a650RegOPI(@lGerar, @nOps, Funname())

	If lGerar
		// Controle para não ocorrer conflito com o MATA650
		If Type("aHeader") == "A"
			aHeadTemp := aClone(aHeader)
			aHeader := Nil
		EndIf

		Processa({|lEnd| MA650Process(@lEnd,nOps)},STR0021,OemToAnsi(STR0022),.F.)

		// Controle para não ocorrer conflito com o MATA650
		If ValType(aHeadTemp) == "A"
			aHeader := aClone(aHeadTemp)
		EndIf
	EndIf

	dbSelectArea(ccALIAS)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A650RotAut ³ Autor ³ Sergio S. Fuzinaka   ³ Data ³ 14.04.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Executa exclusao da OP via Rotina Automatica.               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA650                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A650RotAut(nOpcao)

	Local aRotAuto	:= {}
	//Variável para mudança do retorno quando chamado via JOB
	Local aTypeRet := { .T., '' }
	Local cError   := ''

	Private lMsErroAuto := .F.

	dbSelectArea("SC2")
	dbSetOrder(1)

	//-- Monta array para utilizacao da Rotina Automatica
	aRotAuto  := {	{"C2_FILIAL"	,xFilial("SC2")		,NIL},;
	{"C2_NUM"		,SC2->C2_NUM		,NIL},;
	{"C2_ITEM"		,SC2->C2_ITEM		,NIL},;
	{"C2_SEQUEN"	,SC2->C2_SEQUEN		,NIL},;
	{"C2_ITEMGRD"	,SC2->C2_ITEMGRD	,NIL},;
	{'C2_PRODUTO'   ,SC2->C2_PRODUTO    ,NIL}}

	// Definicao de Indice - Exemplo:
	//				{"INDEX"		,1					,NIL} }

	// Chamada da rotina automatica
	MsExecAuto({|x,y| MATA650(x,y)},aRotAuto,nOpcao)

	// Mostra Erro na geração de Rotinas automáticas
	If lMsErroAuto
		If !IsBlind()
			MostraErro()
			aTypeRet[1] := .F.
		Else
			cError := MostraErro( GetSrvProfString("Startpath","") , ) // Armazena mensagem de erro na raíz.
			//Array contendo o resultado do MostraErro
			aTypeRet := { .F. , cError }
		EndIf
	EndIf

Return aTypeRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTGOSAuto()
Função para gerar manutenções automaticas por tempo via JOBs;
@author Hamilton Soldati
@since 09/05/16
@version P11 e P12
@return booleano
/*/
//---------------------------------------------------------------------
Function MNTGOSAuto(aParam)

Private cCodEmp   := ""
Private cCodFil   := ""
Private cIniFile  := GetAdv97()

If !(Type("oMainWnd")=="O")

	cCodEmp := aParam[1]
	cCodFil := aParam[2]

	RPCSetType(3)

	//Abre empresa/filial/modulo/arquivos
	RPCSetEnv(cCodEmp,cCodFil,"","","MNT","",{"STF"})

	Else
		cCodEmp := cEmpAnt
		cCodFil := cFilAnt
	EndIf

	//Faz a chamada da funcao para inciar o processo de exportacao dos dados
	Processa({ || fGeraOS()}) //Processa o Planejamento

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGeraOS()
Função para gerar manutenções automaticas por tempo via JOBs;
@author Hamilton Soldati
@author Felipe Nathan Welter
@since 09/05/16
@version P11 e P12
@return booleano
	/*/
//---------------------------------------------------------------------
Static Function fGeraOS()

	Local aArea := GetArea()
	Local aAreaST9 := ST9->(GetArea())
	Local aAreaSTF := STF->(GetArea())

	dbSelectArea("STF")
	dbsetOrder(01)
	Set Filter To STF->TF_FILIAL == xFilial("STF") .And. STF->TF_ATIVO == "S" .And. STF->TF_TIPACOM $ "T/A" .And. STF->TF_PERIODO == "R"
	STF->(dbGoTop())

	While STF->(!Eof())
		dbSelectArea("ST9")
		dbSetOrder(01)
		dbSeek(xFilial("ST9") + STF->TF_CODBEM)
		If ST9->T9_SITBEM == "A" .Or. ST9->T9_SITMAN <> "I"
			NGOSPORTEM ( STF->TF_CODBEM, STF->TF_SERVICO, STF->TF_SEQRELA, .F.)
		EndIf

		STF->(dbSkip())

	EndDo

	RestArea(aAreaSTF)
	RestArea(aAreaST9)
	RestArea(aArea)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} NGINTCOMPEST()
Função responsável por fazer o controle de semafaro na funcao NGESTCOMP
@type function

@author NG Informatica
@since 04/11/2016

@param  dDTPREINI  , Data    , Data prevista inicio da O.S.
@param  dDTPREFIM  , Data    , Data prevista fim da O.S.
@param  [cPROGCHAM], Caracter, Nome do programa que chamou a funcao.
@param  [cCodSS]   , Caracter, Código da solicitação.
@param  [aArraySD4], Array   , Conteudo da SD4.
@param  [lRecalSb2], Lógico  , Define se realiza o recalculo de empenho.
@param  [lRetArr]  , Lógico  , Define se o retorno deve ser um array ou lógico.
@param  [cSC1Bkp]  , string  , Número da SC1 relacionada a OS
@return Lógico     , Define se o processo foi realizado com êxito.
@return Array      , [1] - Define se o processo foi realizado com êxito.
					 [2] - Mensage mde erro, caso tenha.
/*/
//---------------------------------------------------------------------
Function NGINTCOMPEST( dDTPREINI, dDTPREFIM, cPROGCHAM, cCodSS, aArraySD4, lRecalSb2, lRetArr, cSC1Bkp )

	Local xRet
	Local lTravF := .F.

	Default cPROGCHAM := ''
	Default aArraySD4 := {}
	Default lRecalSb2 := .F.
	Default lRetArr   := .F.
	Default cSC1Bkp   := ' '

	If NGTRAVAROT( 'NGESTCOMP' )

		lTravF := .T.
		xRet   := NGESTCOMP( dDTPREINI, dDTPREFIM, cPROGCHAM, cCodSS, aArraySD4, lRecalSb2, lRetArr, cSC1Bkp )

	Else

		xRet := IIf( lRetArr, { .F., STR0269 + cPROGCHAM + STR0270 }, .F. ) // O acesso a rotina xxx está bloqueado, pois outro usuário está utilizando

	EndIf

	If lTravF
		NGDETRAVAROT("NGESTCOMP")
	EndIf

Return xRet

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NGESTCOMP
Gera o compras, estoque, PCP  Geração SC1,SD4,SB2,SCP....
@type function

@author NG Informatica
@since 04/11/2016

@sample NGESTCOMP(dDTPREINI, dDTPREFIM, cPROGCHAM, cCodSS, aArraySD4)

@param 	dDTPREINI  , Date    , Data prevista inicio da O.S.
@param	dDTPREFIM  , Date    , Data prevista fim da O.S.
@param	[cPROGCHAM], Caracter, Nome do programa que chamou a funcao
@param	[cCodSS]   , Caracter, Código da SS
@param	[aArraySD4], Array   , Conteudo da SD4
@param  [lRecalSb2], Lógico  , Define se realiza o recalculo de empenho.
@param  [lRetArr]  , Lógico  , Define se o retorno deve ser um array ou lógico
@param  [cSC1Bkp]  , string  , Número da SC1 relacionada a OS

@return Lógico     , Define se o processo foi realizado com êxito.
@return Array      , [1] - Define se o processo foi realizado com êxito.
					 [2] - Mensage mde erro, caso tenha.
/*/
//----------------------------------------------------------------------------------------------------------
Function NGESTCOMP( dDTPREINI, dDTPREFIM, cPROGCHAM, cCodSS, aArraySD4, lRecalSb2, lRetArr, cSC1Bkp )

	Local nQTDCOMP		:= 0
	Local ia 			:= 0
	Local iEmp			:= 0
	Local nQtdSD4BX	    := 0   // Acumulador das quantidades baixadas
	Local nQtdInsOS	    := 0   // Acumulador das quantidades do produto na O.S.
	Local nI            := 0
	Local lGeraSA   	:= .F.
	Local lGeraEmp	    := .T.
	Local lPCriaSDC     := .F.
	Local lAglutin 		:= SuperGetMv( "MV_NGMNTAS",.F.,"2" ) == "1"
	Local lSolicit  	:= If(cCodSS == Nil, .F., !Empty(cCodSS))
	Local lMNTA4102		:= ExistBlock("MNTA4102")
	Local lMNTA3404		:= ExistBlock("MNTA3404")
	Local lMNTA4201		:= ExistBlock("MNTA4201")
	Local lMNTA3401		:= ExistBlock("MNTA3401")
	Local lMNTA3402		:= ExistBlock("MNTA3402")
	Local lMNTA420S		:= ExistBlock("MNTA420S")
	Local lNGNOGRSA     := ExistBlock( 'NGNOGERASA' )
	Local cNumSAA  		:= ""
	Local cParCP    	:= If(GetNewPar("MV_NGMNTCP","N") == "S","S","N")
	Local cUsaIntCm 	:= AllTrim(SuperGetMv("MV_NGMNTCM"))
	Local cUsaIntEs 	:= AllTrim(SuperGetMv("MV_NGMNTES"))
	Local cTpSaldo      := AllTrim(SuperGetMV("MV_TPSALDO")) //Variável para correto cálculo na geração de Solicitação de Compras
	Local cOP       	:= If(!lSolicit, STJ->TJ_ORDEM + "OS", cCodSS + "SS" ) + "001"
	Local cCHAMADOR 	:= If(cPROGCHAM = Nil,' ',cPROGCHAM)
	Local cBranchSTL    := xFilial( 'STL' )
	Local vIEmp     	:= {}
	Local aRetSA 		:= {}
	Local aRet          := { .T., '' }
	Local aItens 		:= {}
	Local aArea			:= {}
	Local aAgluBKP		:= {}
	Local aNumSC        := { .F., '' }
	Local aAreaE    	:= GetArea()
	Local aAreaSTL 	    := STL->(GetArea())
	Local aExecDados 	:= IIf(!lSolicit, {"STJ->TJ_CODBEM", "STJ->TJ_CCUSTO", "STJ->TJ_ORDEM", "STJ->TJ_PLANO", 'STJ->TJ_SEQRELA' }, {"TQB->TQB_CODBEM", "TQB->TQB_CCUSTO","","", '' } )
	Local cMVPRODTER    := Trim(GetMv("MV_PRODTER"))
	Local lRet			:= .T.
	Local lIntegRM		:= SuperGetMV( "MV_NGINTER",.F.,"N" ) == "M"
	Local lAglutSC      := SuperGetMV( 'MV_NGMNTSC', .F., 1 ) != 1
	Local lUsePrAlt     := AllTrim( SuperGetMv( 'MV_MNTPRAL', .F., '2' ) ) == '1' .And. AllTrim( SuperGetMv( 'MV_NGGERSA', .F., 'N' ) ) == 'N'
	Local lNewSc        := Type('aNewSc') == 'A'
	Local nTamItem		:= TAMSX3("TL_ITEMSA")[1]
	Local lLogix        := AllTrim( GetNewPar("MV_NGINTER", "N") ) == "L"
	Local nPosSD4       := 0
	Local nSizeWH       := TamSX3( 'TL_LOCAL' )[1]

	Local aAreaSTJ      := STJ->( GetArea() )

	Default cCodSS      := Space(TAMSX3("TQB_SOLICI")[1])
	Default lRecalSb2   := .F.
	Default aArraySD4   := {}
	Default cSC1Bkp     := ' '

	dbSelectArea("SD4")
	cOP += ( Space( Len(SD4->D4_OP) - Len(cOP) ) )

	//------------------------------------------------------------
	// Verificação Geração de Solicitação ao Armazém (S.A.)
	//------------------------------------------------------------
	If NGCADICBASE('TL_NUMSA','A','STL',.F.) .And. FindFunction("NGGERASA")
		// Gera S.A. quando a integração for completa ("S") ou quando for apenas para os Produtos ("P")
		If GetNewPar("MV_NGGERSA","N") $ "S/P" .And. cUsaIntEs == "S"
			lGeraSA := .T.
		EndIf
	EndIf

	If lSolicit
		NGIFDBSEEK("TQB", cCodSS, 1)
	EndIf

	IF cCHAMADOR == "NGGERAOS" .AND. !Empty(MNTSepSeq(STF->TF_SUBSTIT)) .and. cUsaIntEs == "S"
		//Verifica Substituicao
		aAgluBKP := aIAglu
		aArea    := GetArea()
		NGVERSUBST( &( aExecDados[1] ), &( aExecDados[3] ), &( aExecDados[4] ), &( aExecDados[5] ) )
		aIAglu   := aAgluBKP

		//Adiciona os novos insumos que foi substituido por outra O.S.
		dbSelectArea("STL")
		dbSetOrder(1)
		If dbSeek(xFilial("STL") + &(aExecDados[3]) + &(aExecDados[4]))

			While !EoF() .And. STL->TL_FILIAL == xFilial("STL") .And. STL->TL_ORDEM == &(aExecDados[3]) .And. STL->TL_PLANO == &(aExecDados[4])

				If aScan(aIAglu,{|x | Trim(Upper(x[1]+x[2]+cValtoChar(x[3]))) == Alltrim(STL->TL_CODIGO+STL->TL_LOCAL+cValToChar(STL->TL_QUANTID))}) == 0
					If STL->TL_TIPOREG == "P"
						aAdd(aIAglu,{ STL->TL_CODIGO,STL->TL_LOCAL,STL->TL_QUANTID,STL->TL_ORDEM+"OS001",STL->TL_TAREFA,STJ->TJ_CCUSTO,STL->TL_DTINICI,"S",STL->TL_ORDEM,STL->TL_PLANO, STL->TL_NUMSA, STL->TL_ITEMSA})
					ElseIf STL->TL_TIPOREG == "T" .And. GetNewPar("MV_NGGERSA","N") == "S"
						cCODTER := If(FindFunction("NGProdMNT"), NGProdMNT("T")[1], cMVPRODTER) //Ira verificar apenas o primeiro Produto
						aAdd(aIAglu,{ cCODTER,STL->TL_LOCAL,STL->TL_QUANTID,STL->TL_ORDEM+"OS001",STL->TL_TAREFA,STJ->TJ_CCUSTO,STL->TL_DTINICI,"S",STL->TL_ORDEM,STL->TL_PLANO, STL->TL_NUMSA, STL->TL_ITEMSA })
					EndIf
				EndIf

				dbSelectArea("STL")
				dbSkip()
			End

		EndIf

		RestArea(aArea)
		lJaApag  := .T.
	Endif

	If !lGeraSA

		DTPREINI := dDTPREINI
		DTPREFIM := dDTPREFIM
		vIEmp := {}

		If cParCP == 'N' // COMPRA PADRAO SIGA

			For ia := 1 To Len(aIAglu)

				If Len(aIAglu[ia]) > 10

					Aadd(vIEmp,aIAglu[ia,11])

					iEmp++

				EndIf

				cCodPro := aIAglu[ia,1]
				cLOCSTL := aIAglu[ia,2]

				NGIFDBSEEK('SB2',cCodPro+cLOCSTL,1)
				If aIAglu[ia,3] > 0
					If cUsaIntCm == "S"  //INTEGRACAO COM COMPRAS
						lSaldoSB2 := .T.
						If !Empty(cCHAMADOR)
							If cCHAMADOR = "MNTA410"
								If lMNTA4102
									ExecBlock("MNTA4102",.F.,.F.)
									lSaldoSB2 := .F.
								Endif
							ElseIf cCHAMADOR = "MNTA340"
								If lMNTA3404
									ExecBlock("MNTA3404",.F.,.F.)
									lSaldoSB2 := .F.
								EndIf
							ElseIf cCHAMADOR = "MNTA420"
								If lMNTA4201
									ExecBlock("MNTA4201",.F.,.F.)
									lSaldoSB2 := .F.
								EndIf
							EndIf
						EndIf

						nQTDCOMP  := aIAglu[ia,3]
						If !lUsePrAlt
							lPROBLEMA := .T.//Não retirar - caso não tiver integração com Estoque não verifica saldo
							If lSaldoSB2 .And. cUsaIntEs == "S"

								/*----------------------------------------------------------
								| Validação conforme definição da Equipe de Estoque TOTVS  |
								| de acordo com o conteúdo do parâmetro MV_TPSALDO         |
								----------------------------------------------------------*/
								If GetNewPar("MV_NGINTER","") == "M"
									nSALDODIS := NGMUStoLvl(cCodPro, cLOCSTL,.T.)
								Else
									If cTpSaldo == "C" //Busca saldo que o estoque tinha na data informada no parâmetro dData
										nSALDODIS := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDataBase+1)[1]
									ElseIf cTpSaldo == "S" //Retorna saldo atual independente da data
										nSALDODIS := SaldoSB2(.F.,.T.,dDataBase+3650,.F.)
									Else //Retorna saldo com desconto de quantidade reservada e quantidade a enderecar
										nSALDODIS := SB2->B2_QATU - SB2->B2_QACLASS - SB2->B2_RESERVA
									EndIf
								EndIf
								lPROBLEMA := .F.
								If nSALDODIS <= 0
									lPROBLEMA := .T.
									nQTDCOMP  := aIAglu[ia,3]
								ElseIf (nSALDODIS - aIAglu[ia,3]) < 0
									lPROBLEMA := .T.
									nQTDCOMP  := (nSALDODIS - aIAglu[ia,3]) * -1
								Endif
							EndIf
						Else
							lPROBLEMA := .F.
							// Caso o produto esteja no array de aNewSc, deverá ser gerado solicitação de compra, pois não
							// há quantidade em estoque e nenhum produto alternativo que atenda a quantidade requisitada
							If lNewSc .And. ( nPosCode := aScan( aNewSc, { |x| x[ 1 ] + x[ 2 ] == aIAglu[ ia, 1 ] + aIAglu[ ia, 2 ] } ) ) > 0
								nSALDODIS := aNewSc[ nPosCode, 3 ]
								If nSALDODIS <= 0
									lPROBLEMA := .T.
									nQTDCOMP  := aIAglu[ ia, 3 ]
								ElseIf ( nSALDODIS - aIAglu[ ia, 3 ] ) < 0
									lPROBLEMA := .T.
									nQTDCOMP  := ( nSALDODIS - aIAglu[ ia, 3 ] ) * - 1
								Endif
							EndIf
						EndIf
						INCLUI := .T. // Não retirar usado no A650

						If lPROBLEMA  // Nao Possui quantidade em estoque

							If SG1->(Dbseek(xFILIAL('SG1')+aIAglu[ia,1]))

								dDataIni := MNT420DTOP(DTPREINI)
								dDataFim := MNT420DTOP(DTPREFIM)
								cCusto := NgFilTPN(M->TJ_CODBEM,dDataIni,SubStr(Time(),1,5))[2] //Buscar o C.C. do bem na TPN
								If GERAOPNEW(aIAglu[ia,1],aIAglu[ia,3],M->TJ_ORDEM,dDataBase,dDataBase,aIAglu[ia,2],,cCusto,"PLANO " + M->TJ_PLANO)
									lContSC2 := .T.
								EndIf
								nC2RECNO := SC2->(RecNo())
								NGAtuErp("SC2",If(lContSC2,"UPDATE","INSERT"))
								SC2->(DbGoTo(nC2RECNO)) //Posiciona na OP para função NGEMPMATE()
								NGEMPMATE()

							Else

								If !Empty(cCHAMADOR)
									If cCHAMADOR = "MNTA340"
										If lMNTA3401
											ExecBlock("MNTA3401",.F.,.F.)
										Endif
									EndIf
								EndIf

								aQtdes  := {}
								aQtdes  := CalcLote(cCODPRO,nQTDCOMP,"C")
								vColNFI := {}

								aNumSC := NGGERASC1(cCodPro,aQtdes,cOp,DTPREINI,cLOCSTL,&(aExecDados[2]),ia,vColNFI,,nQTDCOMP,,,,,,,,aIAglu[ia,5],;
									IIf( Len( aIAglu[ia] ) > 14, aIAglu[ia,15], '' ), IIf( Len( aIAglu[ia] ) > 15, aIAglu[ia,16], '' ) )

								If !aNumSC[1]
									lRet := .F.
									Exit
								EndIf

								If !Empty(cCHAMADOR)

									If cCHAMADOR == "MNTA340"
										If lMNTA3402
											ExecBlock("MNTA3402",.F.,.F.)
										EndIf
									ElseIf cCHAMADOR == "MNTA490" .And. !aNumSC[1]

										Return aNumSC[1]

									EndIf

								EndIf

							EndIf
						EndIf
					EndIf
				EndIf

				If cUsaIntEs == "S" //INTEGRACAO COM ESTOQUE
					// GERA EMPENHO
					If !SG1->(Dbseek(xFilial('SG1') + cCodPro))
						SB1->(Dbseek(xFilial('SB1')+cCodPro))

						If SB1->B1_LOCALIZ == "S"
							lPCriaSDC := .T.
						Else
							lPCriaSDC := .F.
						EndIf

						aTRAVAS := {}
						nQtdInsOS	:= IIf( !Empty( vIEmp ), IIf( !Empty( vIEmp[iEmp] ), vIEmp[iEmp], aIAglu[ia,3] ), aIAglu[ia,3] )
						nQtdSD4BX	:= 0
						lGeraEmp	:= .T.

						If NGIFDBSEEK("SD4",Padr( cOP, Len(SD4->D4_OP) ) + Padr( cCodPro, Len(SB1->B1_COD) ) + Padr( cLOCSTL, Len(SB1->B1_LOCPAD) ), 2 ) // D4_FILIAL+D4_OP+D4_COD+D4_LOCAL

							If ( IsInCallStack( 'MNTA420' ) .Or. IsInCallStack( 'MNTA990' ) ) .Or. IsInCallStack( 'RESTEXECUTE' ) .Or. lRecalSb2

								lGeraEmp  := .F.
								nQtdSD4BX	 := nQtdInsOS - ( SD4->D4_QTDEORI - SD4->D4_QUANT )

								RecLock("SD4", .F.)
								SD4->D4_QTDEORI	:= nQtdInsOS
								SD4->D4_QUANT		:= nQtdSD4BX
								SD4->(MsUnlock())

								NGAtuErp("SD4","UPDATE")

								If NGIFDBSEEK("SB2",cCodPro+cLOCSTL,1,.F.)
									RecLock("SB2",.F.)
									SB2->B2_QEMP += nQtdSD4BX
									SB2->(MsUnlock())
								EndIf

							Else

								aTravas := {}
								dbSelectArea("STJ") //Retira Alias SD4 pois GRAVAEMP realiza RestArea da Alias corrente
								GravaEmp(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_QUANT,0,'','','','',SD4->D4_OP,Str(1,3),NIL,NIL,'SC2',NIL,SD4->D4_DATA,@aTravas,.T.,.F.,.T.,.T.,NIL,NIL,lPCriaSDC)
								NGAtuErp("SD4","DELETE")
								NGDELETAREG("SD4")

							EndIf

						EndIf

						If lGeraEmp .And. nQtdInsOS > 0

							dbSelectArea("STJ") //Retira Alias SD4 pois GRAVAEMP realiza RestArea da Alias corrente
							GRAVAEMP(cCODPRO,cLOCSTL,nQtdInsOS,0,'','','','',cOP,Str(ia,3),NIL,NIL,'SC2',NIL,dDTPREINI,@aTRAVAS,.F.,.F.,.T.,.T.,NIL,NIL,lPCriaSDC)

							nPosSD4 := aScan(aArraySD4, {|x| x[1]+ PADR(x[2]+"OS001",LEN(SD4->D4_OP)) == cCODPRO + PADR(cOP,LEN(SD4->D4_OP))})

							If nPosSD4 > 0

								aAreaAtual := SD4->(GetArea())

								DbSelectArea("SD4")
								DbSetOrder(1)
								If DbSeek(xFilial("SD4") + cCODPRO + cOP )
									RecLock("SD4", .F.)
									SD4->D4_CODAEN	:= aArraySD4[nPosSD4][4]
									MsUnLock()
								EndIf
								RestArea(aAreaAtual)
							EndIf

							If lLogix .And. !Empty(aArraySD4)

								aAreaAtual := SD4->(GetArea())
								DbSelectArea("SD4")
								DbSetOrder(1)

								For nI := 1 To Len(aArraySD4)

									If DbSeek(xFilial("SD4") + aArraySD4[nI][1] + PADR((aArraySD4[nI][2] + "OS001"),TAMSX3("D4_OP")[1]))

										While xFilial("SD4") == SD4->D4_FILIAL .And. SD4->D4_COD == aArraySD4[nI][1] .And. AllTrim(SD4->D4_OP) == (aArraySD4[nI][2] + "OS001")

											RecLock("SD4", .F.)
											SD4->D4_CODAEN := aArraySD4[nI][4]
											SD4->(MsUnlock())

											DbSelectArea("SD4")
											DbSkip()

										End

									EndIf

								Next nI

								RestArea(aAreaAtual)

							EndIf


							If lMNTA420S
								ExecBlock("MNTA420S", .F., .F., aArraySD4)
							EndIf

							NGAtuErp("SD4","INSERT")
						Endif

					Endif
				Endif

			Next ia

		Else // quando MV_NGMNTCP = S
			
			aITensCP := {}
			
			For ia := 1 To len(aIAglu)

				aAdd( aItens, { aIAglu[ia,1], aIAglu[ia,3], aIAglu[ia,7], aIAglu[ia,2] } )

				If aIAglu[ia,3] > 0
					
					aAdd( aItensCP, { aIAglu[ia,1], aIAglu[ia,3], aIAglu[ia,7], aIAglu[ia,2], , , , ,;
						IIf( Len( aIAglu[ia] ) > 14, aIAglu[ia,15], '' ),  IIf( Len( aIAglu[ia] ) > 14, aIAglu[ia,16], '' ) } )

				EndIf
				
				If Len(aIAglu[ia]) > 10
					Aadd(vIEmp,aIAglu[ia,11])
				EndIf

			Next ia

			// Integração com o módulo Compras - SIGACOM.
			If cUsaIntCm == 'S'  

				lRet := NGGRAVSC1CM( cOP, aItensCP, cCHAMADOR, lUsePrAlt, cSC1Bkp )

			EndIf

			If lRet
			
				If cUsaIntEs == "S" //INTEGRACAO COM ESTOQUE
					For ia := 1 To Len(aItens)
						cCodPro := Left(aItens[ia,1],Len(SB1->B1_COD))
						cLOCSTL := aItens[ia,4]
						// GERA EMPENHO
						If !SG1->(Dbseek(xFilial('SG1') + cCodPro))
							SB1->(Dbseek(xFilial('SB1')+cCodPro))

							lPCriaSDC := SB1->B1_LOCALIZ == "S"
							aTRAVAS   := {}
							If !Empty( vIEmp ) .And. Type( 'vIEmp[' + cValToChar( ia ) + ']' ) != 'U' .And. !Empty( vIEmp[ ia ] )
								nQtdInsOS := vIEmp[ ia ]
							Else
								nQtdInsOS := aItens[ ia, 2 ]
							EndIf
							nQtdSD4BX := 0
							lGeraEmp  := .T.

							If NGIFDBSEEK("SD4",Padr( cOP, Len(SD4->D4_OP) ) + Padr( cCodPro, Len(SB1->B1_COD) ) + Padr( cLOCSTL, Len(SB1->B1_LOCPAD) ), 2 ) // D4_FILIAL+D4_OP+D4_COD+D4_LOCAL

								If ( IsInCallStack( 'MNTA420' ) .Or. IsInCallStack( 'MNTA990' ) ) .Or. IsInCallStack( 'RESTEXECUTE' ) .Or. lRecalSb2

									lGeraEmp  := .F.
									nQtdSD4BX	 := nQtdInsOS - ( SD4->D4_QTDEORI - SD4->D4_QUANT )

									RecLock("SD4", .F.)
									SD4->D4_QTDEORI	:= nQtdInsOS
									SD4->D4_QUANT	:= nQtdSD4BX
									SD4->(MsUnlock())

									NGAtuErp("SD4","UPDATE")

									If NGIFDBSEEK("SB2",cCodPro+cLOCSTL,1,.F.)
										RecLock("SB2",.F.)
										SB2->B2_QEMP += nQtdSD4BX
										SB2->(MsUnlock())
									EndIf

								Else

									aTravas := {}
									dbSelectArea("STJ") //Retira Alias SD4 pois GRAVAEMP realiza RestArea da Alias corrente
									GravaEmp(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_QUANT,0,'','','','',SD4->D4_OP,Str(1,3),NIL,NIL,'SC2',NIL,SD4->D4_DATA,@aTravas,.T.,.F.,.T.,.T.,NIL,NIL,lPCriaSDC)
									NGAtuErp("SD4","DELETE")
									NGDELETAREG("SD4")
								Endif

							EndIf

							If lGeraEmp .And. nQtdInsOS > 0
								GRAVAEMP(cCODPRO,cLOCSTL,nQtdInsOS,0,'','','','',cOP,Str(ia,3),NIL,NIL,'SC2',NIL,SC2->C2_DATPRF,@aTRAVAS,.F.,.F.,.T.,.T.,NIL,NIL,lPCriaSDC)

								If lLogix .And. !Empty(aArraySD4)

									aAreaAtual := SD4->(GetArea())
									DbSelectArea("SD4")
									DbSetOrder(1)

									For nI := 1 To Len(aArraySD4)

										If DbSeek(xFilial("SD4") + aArraySD4[nI][1] + PADR((aArraySD4[nI][2] + "OS001"),TAMSX3("D4_OP")[1]))

											While xFilial("SD4") == SD4->D4_FILIAL .And. SD4->D4_COD == aArraySD4[nI][1] .And. AllTrim(SD4->D4_OP) == (aArraySD4[nI][2] + "OS001")

												RecLock("SD4", .F.)
												SD4->D4_CODAEN := aArraySD4[nI][4]
												SD4->(MsUnlock())

												DbSelectArea("SD4")
												DbSkip()

											End

										EndIf

									Next nI

									RestArea(aAreaAtual)

								EndIf

								NGAtuErp("SD4","INSERT")
							Endif
						Endif
					Next ia
				EndIf

			EndIf

		EndIf

	Else

		If cUsaIntEs == "S" //INTEGRACAO COM ESTOQUE
			For ia:= 1 to Len(aIAglu)
				If aIAglu[ia,3] > 0
					If !lSolicit
						NGIFDBSEEK("STJ",aIAglu[ia,9]+aIAglu[ia,10],1)
					Else
						NGIFDBSEEK("TQB", aIAglu[ia,11], 1)
					EndIf
					cNumSAA := " "

					aRetSA := NGGERASA( aIAglu[ia,1], aIAglu[ia,9], aIAglu[ia,10], aIAglu[ia,3], aIAglu[ia,2], IIf( Len( aIAglu[ia] ) > 12 , aIAglu[ia,13], StrZero( ia, nTamItem ) ),;
						IIf( Len( aIAglu[ia] ) > 13, aIAglu[ia,14], Nil ), .F., IIf( lSolicit, aIAglu[ia,11], Nil ), .T., IIf( Len( aIAglu[ia] ) > 12 , aIAglu[ia,12], '' ) )

					If aRetSA[5]
						cNumSAA := aRetSA[1]
						If !lSolicit

							dbSelectArea( 'STL' )
							dbSetOrder( 2 ) // TL_FILIAL + TL_TIPOREG + TL_SEQRELA + TL_CODIGO + TL_ORDEM + TL_PLANO

							// Atualiza campo TL_NUMSA e TL_ITEMSA para insumos do tipo PRODUTO.
							If msSeek( cBranchSTL + 'P' + '0  ' + aIAglu[ia,1] + aIAglu[ia,9] + aIAglu[ia,10] )

								Do While STL->( !EoF() ) .And. cBranchSTL == STL->TL_FILIAL .And. STL->TL_TIPOREG == 'P' .And.;
									STL->TL_SEQRELA == '0  ' .And. STL->TL_CODIGO == aIAglu[ia,1] .And. STL->TL_ORDEM == aIAglu[ia,9] .And.;
									STL->TL_PLANO == aIAglu[ia,10]

									If STL->TL_LOCAL == PadR( aIAglu[ia,2], nSizeWH ) .And. Empty( STL->TL_NUMSA )

										RecLock( 'STL', .F. )
											STL->TL_NUMSA  := aRetSA[1]
											STL->TL_ITEMSA := aRetSA[2]
										STL->( MsUnlock() )

									EndIf

									STL->( dbSkip() )

								EndDo

							Else

								// Atualiza campo TL_NUMSA e TL_ITEMSA para insumos do tipo TERCEIRO.
								If msSeek( cBranchSTL + 'T' + '0  ' + aIAglu[ia,1] + aIAglu[ia,9] + aIAglu[ia,10] )

									Do While STL->( !EoF() ) .And. cBranchSTL == STL->TL_FILIAL .And. STL->TL_TIPOREG == 'T' .And.;
										STL->TL_SEQRELA == '0  ' .And. STL->TL_CODIGO == aIAglu[ia,1] .And. STL->TL_ORDEM == aIAglu[ia,9] .And.;
										STL->TL_PLANO == aIAglu[ia,10]

										If STL->TL_LOCAL == PadR( aIAglu[ia,2], nSizeWH ) .And. Empty( STL->TL_NUMSA )

											RecLock( 'STL', .F. )
												STL->TL_NUMSA  := aRetSA[1]
												STL->TL_ITEMSA := aRetSA[2]
											STL->( MsUnLock() )

										EndIf

										STL->( dbSkip() )

									EndDo

								EndIf

							EndIf

							aRetSA := {}

						EndIf
					Else

						If !Empty(cCHAMADOR) .And. cCHAMADOR = "MNTA340"
							cTextoSTA := STR0138 //"PROBLEMA AO GERAR SOLICITACAO AO ARMAZEM"
							If !NGIFDBSEEK("STA",aIAglu[ia,9]+aIAglu[ia,10]+aIAglu[ia,5]+"P"+aIAglu[ia,1]+cTextoSTA,1,.F.)
								MNTGRAVSTA(aIAglu[ia,9],aIAglu[ia,10],aIAglu[ia,5],"P",aIAglu[ia,1],cTextoSTA)
							EndIf

						ElseIf !Empty( cCHAMADOR ) .And. cCHAMADOR == 'MNTA490'

							lRet := aRetSA[5]

							Exit

						ElseIf !lIntegRM // Condição para que se mantenha a integridade do registro no RM (sem rollback)
							//Se o P.E. existir deverá retornar verdadeiro para prosseguir com a gravação da O.S.
							//Com o retorno verdadeiro, a função MNTA420PR continuará com o processo de gravação
							//corretamente mesmo não possuindo S.A.
							lRet := IIf( Empty( aRetSA[4] ), lNGNOGRSA, aRetSA[5] )

							aRet := { lRet, aRetSA[4] }

							If !lNGNOGRSA
								Exit
							EndIf

						EndIf

					EndIf

				EndIf

			Next ia

			RestArea(aAreaSTL)

			If lAglutin .And. lIntegRM .And. !Empty( cNumSAA ) .And.;
				NGIFDBSEEK( 'SCP', cNumSAA, 01, .F. )

				 lRet := !( !NGMUReques( SCP->( RecNo() ), 'SCP', .F., 3 ) .And. cCHAMADOR == 'MNTA490' )

			EndIf

		EndIf
	EndIf

	RestArea( aAreaSTJ )
	RestArea(aAreaE)

Return IIf( !lRetArr, lRet, aRet )


//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaTRB
Cria TRB
@author eduardo.izola
@since 16/02/2017
@version undefined
@param cAlias, characters, Alias Tabela
@param aFields, array, Array de campos
@param aIndex, array, Indice TRB
@type function
/*/
//---------------------------------------------------------------------
Static Function fCriaTRB(cAlias,aFields,aIndex)

	Local i

	oTempTable := FWTemporaryTable():New( cAlias , aFields )
	For i := 1 To Len(aIndex)
		oTempTable:AddIndex("ind"+cValToChar(i), aIndex[i] )
	Next i
	oTempTable:Create()

Return oTempTable

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTOSPESCP
Função para adicionar os valores informados no P.E. nos arrays de aCab e aItem.

@type function

@source MNTUTIL_OS.prw

@param aSCPReturn, Array, Retorno do ponto de entrada com os campos e novos valores.
@param aCab , Array, Array do cabeçalho da SCP
@param aItem , Array, Array dos itens da SCP

@author Jean Pytter da Costa
@since 18/07/2018

@obs Essa função será utilizada somente pelo P.E. NGALTSCP

@return Lógico, Sempre verdadeiro
/*/
//---------------------------------------------------------------------
Static Function MNTOSPESCP( aSCPReturn, aCab, aItem )

	Local aSCPFields := {}
	Local nArrSCP 	 := 0
	Local nSCPField	 := 0

 	// Verifica cabeçalho e itens
	For nArrSCP := 1 To 2

		aSCPFields  := aSCPReturn[nArrSCP]
		cNaoRetirar := IIf( nArrSCP == 1, "CP_NUM/CP_EMISSAO", "CP_ITEM/CP_PRODUTO/CP_LOCAL/CP_DATPRF/CP_OP" )
		//Removido uma dimensão do array aItem para realizar as validações corretamente
		aCmpSCP := aClone( IIf( nArrSCP == 1, aCab, aItem[1] ) )

		For nSCPField := 1 To Len(aSCPFields)

			//Se o campo é utilizado em alguma chave(SXI) não será alterado.
			If ( aSCPFields[nSCPField, 1] $ cNaoRetirar )
				Loop
			Endif

			If ( nPosSCP := aScan( aCmpSCP, {|x| x[1] == aSCPFields[nSCPField, 1] } ) ) == 0
				aAdd( aCmpSCP, {} )
				nPosSCP := Len(aCmpSCP)
			Endif
			aCmpSCP[nPosSCP] := aSCPFields[nSCPField]

		Next nSCPField

		//Adicionado uma dimensão no array aItem para realizar a gravação na SCP corretamente.
		IIf( nArrSCP == 1, aCab := aClone( aCmpSCP ), aItem := aClone( { aCmpSCP } ) )

	Next nArrSCP

Return .T.

//------------------------------------------------------------------------
/*/{Proteus.doc} MntGetPrdM
Busca o código do produto referente ao funcionário enviado por parâmetro.
@type function

@author Alexandre Santos
@since  24/09/2018

@sample MntGetPrdM()

@param  [cCode], Caracter, Código do Funcionário.
@param  [cFil] , Caracter, Filial para posicionamento na ST1.
@param  [cEmp] , Caracter, Empresa para posicionamento na ST1.
@return cReturn, Caracter, Código do produto referente ao funcionário.
/*/
//------------------------------------------------------------------------
Function MntGetPrdM( cCode, cFil, cEmp )

	Local aArea   := GetArea()
	Local cReturn := ''
	Local lFound  := .T.
	Local lExist  := ( ST1->( FieldPos( 'T1_PRODMO' ) ) > 0 )

	Default cCode := ''

	If !Empty( cCode )
		dbSelectArea( 'ST1' )
		dbSetOrder( 1 )
		lFound := MsSeek( NgTrocaFili( 'ST1', cFil, cEmp ) + Trim( cCode ) )
	EndIf

	If lExist .And. lFound .And. !Empty( ST1->T1_PRODMO ) .And. MntProdMod( Trim( ST1->T1_PRODMO ) )
		cReturn := ST1->T1_PRODMO
	Else
		cReturn := PadR( 'MOD' + LTrim( ST1->T1_CCUSTO ), TamSX3( 'B1_COD' )[1] ) //LTrim para caso o centro de custo tenha um espaço no começo
	EndIf

	RestArea( aArea )

Return cReturn

//------------------------------------------------------------------------
/*/{Proteus.doc} MntProdMod
Valida se o produto controla mão de obra.
@type function

@author Alexandre Santos
@since  14/12/2021

@sample MntProdMod( '001' )

@param  cCode  , string, Código do produto.
@return boolean, Indica se o produto controla mão de obra.
/*/
//------------------------------------------------------------------------
Function MntProdMod( cCode )

	Local cAlsST1  := ''
	Local lRet     := .F.
	Local lIntegRM := SuperGetMV( 'MV_NGINTER', .F., 'N' ) == 'M'
	
	If !lIntegRM

		// Validação de produto do tipo mão de obra.
		lRet := IsProdMod( cCode )

	Else

		If Substr( cCode, 1, 3 ) == 'MOD'

			lRet := .T.

		Else

			cAlsST1 := GetNextAlias()

			BeginSQL Alias cAlsST1

				SELECT
					COUNT( ST1.T1_CODFUNC ) AS QTDE
				FROM
					%table:ST1% ST1
				WHERE
					ST1.T1_FILIAL  = %xFilial:ST1% AND 
					ST1.T1_PRODMO  = %exp:cCode%   AND
					ST1.T1_DISPONI = 'S'           AND
					ST1.%NotDel%

			EndSQL

			lRet := (cAlsST1)->(QTDE) > 0

			(cAlsST1)->( dbCloseArea() )

		EndIf

	EndIf

Return lRet

//------------------------------------------------------------------------------------
/*/{Protheus.doc} MntVldBlqM
Valida se já existe bloqueio para o funcionário no periodo.
@type function

@author Alexandre Santos
@since 02/08/2019

@sample MntVldBlqM( '000100', '000000', { '0', 'TRUMP', 'S', 15, 28/05/1999, '18:00' }, , .F. )

@param  cOrder    , Caracter, Ordem de Serviço.
@param  cPlan     , Caracter, Plano de Manutenção.
@param  aInfoIns  , Array   , Informações do insumo em validação.
								[1] - Código da tarefa genérica.
								[2] - Código da mão-de-obra.
								[3] - Indica se utiliza calendário.
								[4] - Quantidade da mão-de-obra.
								[5] - Data Inicio de aplicação da mão-de-obra.
								[6] - Hora Inicio de aplicação da mão-de obra.
@param  [nLineItm], Númerico, Número da linha.
@param  [lShowMsg], Lógico  , Indica se deve ou não apresentar a mensagem ao usuário.
@return Array     , [1] - Indica se o processo foi validado com êxito.
				    [2] - Mensgem refernte a inconsistência.

@obs Replica da função NG420VBLOF() com objetivo de torna-la genérica.
/*/
//------------------------------------------------------------------------------------
Function MntVldBlqM( cOrder, cPlan, aInfoIns, nLineItm, lShowMsg )

	Local cCodeMO  := PadR( aInfoIns[2], Len( STK->TK_CODFUNC ) )
	Local cMessage := ''
	Local aRetBlq  := { .T., '' }
	Local aDatIns  := {}
	Local lRet     := .T.
	Local lSeek    := .F.

	Default nLineItm := 0
	Default lShowMsg := .T.

	If SuperGetMv( 'MV_NGCORPR' ) == 'S'

		// Retorna a data/hora início e fim de aplicação do insumo ( Somente para Mão de Obra ).
		aDatIns  := M420RETDAT( cCodeMO, aInfoIns[5], aInfoIns[6], aInfoIns[4], aInfoIns[3] )

		dbSelectArea( 'STK' )
		dbSetOrder( 1 ) // TK_FILIAL + TK_ORDEM + TK_PLANO + TK_TAREFA + TK_CODFUNC + TK_DATAINI + TK_HORAINI
		lSeek := dbSeek( xFilial( 'STK' ) + cOrder + cPlan + aInfoIns[1] + cCodeMO + DToS( aDatIns[1] ) + aDatIns[2] )

		// Verifica a existência de outro bloqueio de funcionário que conflite com o qual está em validação.
		aRetBlq := MNT160CKDA( cCodeMO, aDatIns[1], aDatIns[2], aDatIns[3], aDatIns[4], IIf( lSeek, STK->( RecNo() ),;
			Nil ), .F. )

		// Caso exista algum conflito apresenta mensagem.
		If !aRetBlq[1]

			// Mensagem apresentada em tela, decisão de prosseguir fica a cargo do usuário.
			If lShowMsg

				/*
					Já existe bloqueio do funcionário no periodo apontado: XX/XX/XXXX às XX:XX
					até XX/XX/XXXX às XX:XX. Referente ao item: 1. Deseja prosseguir mesmo assim?
				*/
				lRet := MsgYesNo( STR0261 + dToC( aDatIns[1] ) + STR0262 + aDatIns[2] + STR0263 + dToC( aDatIns[3] ) +;
							STR0262 + aDatIns[4] + '.' + STR0264 + Trim( Str( nLineItm, 3 ) ) + '.' + Chr( 13 ) + STR0265,;
							STR0018 )

			/*
				Mensagem não é apresentado neste momento, mesmo com retorno falso, no momento em que a mensagem for
				apresentada a decisão de prosseguir deve ficar a cargo do usuário.
			*/
			Else

				/*
					Já existe bloqueio do funcionário no periodo apontado: XX/XX/XXXX às XX:XX
					até XX/XX/XXXX às XX:XX.
				*/
				cMessage := STR0261 + dToC( aDatIns[1] ) + STR0262 + aDatIns[2] + STR0263 + dToC( aDatIns[3] ) +;
							STR0262 + aDatIns[4] + '.'
				lRet     := .F.

			EndIf

		EndIf

	EndIf

Return { lRet, cMessage }

//--------------------------------------------------------------------------------------------------
/*/{Proteus.doc} MntVldBlqE
Valida se existe bloqueio para a especialidade no periodo.
@type function

@author Alexandre Santos
@since  05/08/2019

@sample MntVldBlqE( '000010', '000000' { 'Esp', 10, 5, 25/12/2019, '13:00' }, , .F. )

@param  cOrder   , Caracter, Ordem de Serviço.
@param  aInfoIns , Array   , Informações do insumo em validação.
							[1] - Código da especialidade.
							[2] - Quantidade de horas.
							[3] - Quantidade de recursos.
							[4] - Data Inicio de aplicação.
							[5] - Hora Inicio de aplicação.
@param  [nLineItm], Númerico, Número da linha.
@param  [lShowMsg], Lógico  , Indica se deve ou não apresentar a mensagem ao usuário.
@return Array , [1] - Indica se o processo foi validado com êxito.
				[2] - Mensgem refernte a inconsistência.

@obs Replica da função NGTTYBLOQ() com objetivo de torna-la genérica.
/*/
//------------------------------------------------------------------------------------------------
Function MntVldBlqE( cOrder, cPlan, aInfoIns, nLineItm, lShowMsg )

	Local cEspCod    := ''
	Local cAlsST2    := ''
	Local cAlsTTY    := ''
	Local cMsg       := ''
	Local cConcatF   := ''
	Local cConcatI   := ''
	Local aDtHoFim   := {}
	Local lRet       := .T.
	Local nQtdDisp   := 0

	Default nLineItm := 0

	If SuperGetMv( 'MV_NGCORPR' ) == 'S'

		cEspCod := PadR( aInfoIns[1], TamSX3( 'T2_ESPECIA' )[1] )
		cAlsST2 := GetNextAlias()

		BeginSQL Alias cAlsST2

			SELECT
				COUNT( T2_ESPECIA ) AS QTDESP
			FROM
				%table:ST2%
			WHERE
				T2_FILIAL  = %xFilial:ST2% AND
				T2_ESPECIA = %exp:cEspCod% AND
				%NotDel%

		EndSQL

		If (cAlsST2)->QTDESP == 0

			cMsg := STR0268 // Não existe funcionário para esta especialidade.

		ElseIf (cAlsST2)->QTDESP < aInfoIns[3]

			cMsg := STR0267 // Quantidade insuficiente de funcionários para a especialidade definida.

		Else

			// BUSCA QUANTIDADE DE ESPECIALISTAS QUE POSSUEM BLOQUEIO PARA DEDUÇÃO DOS DISPONIVEIS.
			aDtHoFim := NGDTHORFIM( aInfoIns[4], aInfoIns[5], aInfoIns[2] )
			cAlsTTY  := GetNextAlias()
			nQtdDisp := (cAlsST2)->QTDESP
			cConcatF := dToS( aInfoIns[4] ) + aInfoIns[5]
			cConcatI := dToS( aDtHoFim[1] ) + aDtHoFim[2]

			BeginSQL Alias cAlsTTY

				SELECT
					SUM( TTY_QUANTI ) AS nSumQtd
				FROM
					%table:TTY%
				WHERE
					TTY_FILIAL = %xFilial:TTY% AND
					TTY_CODESP = %exp:cEspCod% AND
					TTY_ORDEM || TTY_PLANO <> %exp:cOrder+cPlan% AND
					TTY_DTFIM || TTY_HRFIM >  %exp:cConcatF%              AND
					TTY_DTINI || TTY_HRINI <  %exp:cConcatI%              AND
					TTY_QUANTI > 0 AND %NotDel%

			EndSQL

			If (cAlsTTY)->( !EoF() )

				nQtdDisp -= (cAlsTTY)->nSumQtd

			EndIf

			(cAlsTTY)->( dbCloseArea() )

			If ( nQtdDisp - aInfoIns[3] ) < 0

				/*
				Já existe bloqueio do funcionário no periodo apontado: XX/XX/XXXX às XX:XX
				até XX/XX/XXXX às XX:XX. Referente ao item: 1..
				*/
				cMsg := STR0266 + dToC( aInfoIns[4] ) + STR0262 + aInfoIns[5] + STR0263 + dToC( aDtHoFim[1] ) + STR0262 + aDtHoFim[2] +;
						IIf( lShowMsg, '.' + STR0264 + Trim( Str( nLineItm, 3 ) ) + '.', '.' )

			EndIf

		EndIf


		If !Empty( cMsg )

			If lShowMsg

				lRet := MsgYesNo( cMsg + CHR( 13 ) + STR0265, STR0018 ) // Deseja prosseguir mesmo assim? # ATENÇÃO

			Else

				lRet     := .F.

			EndIf

		EndIf

		(cAlsST2)->( dbCloseArea() )

	EndIf

Return { lRet, cMsg }

//--------------------------------------------------------------------------------------------------
/*/{Proteus.doc} MNTCusPro
Atualiza saldo e custo médio do produto integrado ao RM.
@type function

@author Tainã Alberto Cardoso
@since  31/01/2019

@sample MNTCusPro( 'M', '00001' )

@param  cTipIns, Caracter, Tipo de insumo.
@param  cCodIns, Caracter, Código de insumo.
@param  cLocal , Caracter, Local de insumo.

@return .T., Lógico, Sempre verdadeiro
/*/
//------------------------------------------------------------------------------------------------
Function MNTCusPro( cTipIns, cCodIns, cLocal )

	Default cLocal := ''

	If cTipIns == 'M'

		NGMUStoLvl( MntGetPrdM( cCodIns ), SuperGetMV( 'MV_NGLOCPA', .F., '01'), .F., cTipIns, cCodIns )

	Else

		NGMUStoLvl( NGMURetIns( cTipIns, cCodIns ), cLocal, .F. )

	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} NGSD1STL
Função para gravar o insumo atraves de um registro da SD1

@type function

@source MNTUTIL_OS.prw

@param cAliasTPZ, Caracter, Alias temporário quando insumo possuir garantia.
@param cFilD1   , Caracter, D1_FILIAL  - Filial do cadastro da Nota.
@param cDocD1   , Caracter, D1_DOC     - Numero do Documento/Nota.
@param cSerieD1 , Caracter, D1_SERIE   - Serie da Nota Fiscal.
@param cForneD1 , Caracter, D1_FORNECE - Código do Forn/Cliente.
@param cLojaD1  , Caracter, D1_LOJA    - Loja do Forn/Cliente.
@param cProdD1  , Caracter, D1_COD     - Código do Produto.
@param cItemD1  , Caracter, D1_ITEM    - Item da Nota Fiscal.
@param lInclui  , Lógico  , .T. para inclusão, .F. para exclusão.

@author Tainã Alberto Cardoso
@since 03/12/2018

@return Lógico, Sempre verdadeiro
/*/
//---------------------------------------------------------------------
Function NGSD1STL(cAliasTPZ, cFilD1, cDocD1, cSerieD1, cForneD1, cLojaD1, cProdD1, cItemD1, lInclui)

	Local aAreaSD1  := SD1->(GetArea())
	Local cChaTPZ   := ''
	Local lFound    := .T.
	Local lTermino  := .F.
	Local nRecSTJ   := 0

	DEFAULT cAliasTPZ := "TRBTPZ"

	dbSelectarea("SD1")
	dbSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	If dbSeek( cFilD1 + cDocD1 + cSerieD1 + cForneD1 + cLojaD1 + cProdD1 + cItemD1 )

		If Empty(SD1->D1_NFORI)
			If lInclui
				dbSelectArea("STJ")
				dbSetorder(1)
				If DbSeek(xFilial("STJ") + SD1->D1_ORDEM )
					lFOUND   := .F.

					//Lança insumo para OS ja terminada
					lTermino := STJ->TJ_TERMINO == 'S'

					dbSelectArea("STL")
					dbSetorder(7)  // ORDEM DE NUMSEQ
					dbSeek(xFilial("STL")+SD1->D1_NUMSEQ)
					While !Eof() .And. STL->TL_FILIAL == xFilial("STL") .And. STL->TL_NUMSEQ == SD1->D1_NUMSEQ

						If Trim(STL->TL_CODIGO) == Trim(SD1->D1_COD) .And. STL->TL_ORDEM == SD1->D1_ORDEM

							lFound := .T.
							Exit
						Endif
						DbSkip()
					End

					If !lFOUND
						// Verifica se a OS e uma OS em Lote e se já possui insumo aplicado
						dbSelectArea("TR8")
						dbSetOrder(02)
						If dbSeek(xFilial("TR8")+SD1->D1_ORDEM)
							dbSelectArea("STL")
							dbSetOrder(01)
							dbSeek(xFilial("STL")+SD1->D1_ORDEM)
							While STL->(!Eof()) .And.  STL->TL_ORDEM == SD1->D1_ORDEM
								If cValToChar(STL->TL_SEQRELA) > "0" .And. Empty(STL->TL_NUMSEQ)
									RecLock("STL",.F.)
									dbDelete()
									MsUnLock("STL")
								EndIf
								dbSelectArea("STL")
								STL->(dbSkip())
							End
						EndIf

						NGD1INCTL(SD1->D1_ORDEM,SD1->D1_COD)//Grava Insumo realizado

						dbSelectArea("STJ")
						Reclock("STJ",.F.)
						STJ->TJ_TIPORET := "S"
						MsUnlock("STJ")
						If lTermino
							NGFINAL(STJ->TJ_ORDEM,STJ->TJ_PLANO,STJ->TJ_DTPRINI,STJ->TJ_HOPRINI,STJ->TJ_DTPRFIM,STJ->TJ_HOPRFIM)
						EndIf

						//Grava a garantia do insumo
						If SD1->D1_GARANTI == "S"
							dbSelectArea(cAliasTPZ)
							If dbSeek(SD1->D1_ITEM)
								dbSelectArea("TPZ")
								RecLock("TPZ",.T.)
								TPZ->TPZ_FILIAL := xFilial("TPZ")
								TPZ->TPZ_CODBEM := STJ->TJ_CODBEM
								TPZ->TPZ_TIPORE := STL->TL_TIPOREG
								TPZ->TPZ_CODIGO := (cAliasTPZ)->TPZ_CODIGO
								TPZ->TPZ_LOCGAR := (cAliasTPZ)->TPZ_LOCGAR
								TPZ->TPZ_ORDEM  := (cAliasTPZ)->TPZ_ORDEM
								TPZ->TPZ_PLANO  := STJ->TJ_PLANO
								TPZ->TPZ_SEQREL := STL->TL_SEQRELA
								TPZ->TPZ_SEQUEN := STL->TL_SEQUENC
								If Empty(STL->TL_DTFIM)
									TPZ->TPZ_DTGARA := STL->TL_DTINICI
								Else
									TPZ->TPZ_DTGARA := STL->TL_DTFIM
								EndIf
								TPZ->TPZ_QTDGAR := (cAliasTPZ)->TPZ_QTDGAR
								TPZ->TPZ_UNIGAR := (cAliasTPZ)->TPZ_UNIGAR
								TPZ->TPZ_CONGAR := (cAliasTPZ)->TPZ_CONGAR
								TPZ->TPZ_QTDCON := (cAliasTPZ)->TPZ_QTDCON

								MsUnlock("TPZ")
							EndIf
						EndIf
					Endif
				Endif
			Else //Exclusão da Nota
				DbSelectArea("STJ")
				DbSetorder(1)
				If DbSeek(xFilial("STJ") + SD1->D1_ORDEM) .and. STJ->TJ_SITUACA == 'L' .and. STJ->TJ_TERMINO == 'N'
					nRecSTJ := STJ->( Recno() )
					DbSelectArea("STL")
					DbSetorder(7)
					If DbSeek(xFilial("STL")+SD1->D1_NUMSEQ)
						DbSelectArea("STN")
						DbSetorder(1)
						If DbSeek(xFilial("STN")+STL->TL_ORDEM+STL->TL_PLANO+STL->TL_TAREFA+STL->TL_SEQRELA)
							While !Eof() .And. STN->TN_FILIAL = Xfilial("STN") .And.;
							STN->TN_ORDEM = STL->TL_ORDEM .And. STN->TN_TAREFA = STL->TL_TAREFA;
							.And. STN->TN_SEQRELA = STL->TL_SEQRELA
							RecLock("STN",.F.)
							dbDelete()
							MSUNLOCK("STN")
							DbSkip()
							End
						EndIf
						DbSelectArea("SD1")
						If SD1->D1_GARANTI == "S"
							DbSelectArea("TPZ")
							DbSetOrder(2)
							cChaTPZ := STJ->TJ_ORDEM+STJ->TJ_PLANO+STL->TL_SEQRELA
							If DbSeek(xfilial("TPZ")+cChaTPZ)
								While !Eof() .And. TPZ->TPZ_FILIAL = Xfilial("TPZ") .And.;
									TPZ->TPZ_ORDEM+TPZ->TPZ_PLANO+TPZ->TPZ_SEQREL = cChaTPZ
									RecLock("TPZ",.F.)
									dbDelete()
									MSUNLOCK("TPZ")
									DbSkip()
								End
							EndIf
						EndIf
						DbSelectArea("STL")
						RecLock("STL",.F.)
						dbDelete()
						MSUNLOCK("STL")
					Endif

					dbSelectArea("STL")
					dbSetOrder(4)
					If dbSeek(xFilial("STL")+SD1->D1_ORDEM)
						aOldArea := GetArea()
						While !Eof() .AND. STL->TL_FILIAL == xFilial("STL") .AND. STL->TL_ORDEM == SD1->D1_ORDEM
							If STL->TL_TIPOREG == "P" .AND. STL->TL_ORIGNFE == "SD1" .AND. STL->TL_ORDEM == SD1->D1_ORDEM .AND.;
								STL->TL_NOTFIS == SD1->D1_NFORI .AND. STL->TL_SERIE == SD1->D1_SERIORI
								If SD1->D1_TIPO == 'D'
									nQuant := STL->TL_QUANTID + SD1->D1_QUANT
								Else
									nQuant := STL->TL_QUANTID - SD1->D1_QUANT
								Endif

								RecLock("STL",.f.)
								If nQuant <= 0
									dbDelete()
								Else
									nCustoNovo := (STL->TL_CUSTO/STL->TL_QUANTID)
									STL->TL_QUANTID -= nQtdeDevol
									STL->TL_CUSTO := nCustoNovo * STL->TL_QUANTID
								Endif
								MsUnlock("STL")
							Endif
							dbSelectArea("STL")
							dbSkip()
						End
						RestArea(aOldArea)
					Else
						dbSelectArea("SD1")
						aOldArea := GetArea()
						dbSetOrder(01)
						If	dbSeek(xFilial("SD1")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD)
							NGSD1GESTL(SD1->D1_ORDEM,SD1->D1_COD)
						Endif
						RestArea(aOldArea)
					Endif

					//-----------------------------------------------------------
					// Atualiza campo que indica se ordem possui insumo realizado
					//-----------------------------------------------------------
					AtuTipoRet( SD1->D1_ORDEM )

				Endif
			Endif
		Else //Atualiza o insumos
			NGD1D2STL( SD1->D1_NFORI, SD1->D1_SERIORI, SD1->D1_ITEMORI, SD1->D1_FORNECE, SD1->D1_LOJA ,;
						SD1->D1_COD, SD1->D1_QUANT, SD1->D1_TOTAL, lInclui, SD1->( Recno()) )
		EndIf
	EndIf

	RestArea(aAreaSD1)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGD1INCTL
Função para gravar o insumo o insumo da nota

@type function

@source MNTUTIL_OS.prw

@param cOrdem  , Caracter, Numero da O.S.
@param cCodIns , Caracter, Código do insumo

@author Tainã Alberto Cardoso
@since 03/12/2018

@return Lógico, Sempre verdadeiro
/*/
//---------------------------------------------------------------------
Function NGD1INCTL(cOrdem,cCodIns)

	Local lTermino  := .F.
	Local lTercProd := .F.
	Local cDestino  := ""
	Local cCodigo   := ""
	Local cTipoReg  := ""
	Local cCAMPP    := ""
	Local nVP       := 0
	Local nY        := 0
	Local nX        := 0
	Local nZ        := 0
	Local vVETCAMN  := {"_FILIAL","_NUMSEQ","_ORDEM"}
	Local aESTRUT   := {}
	Local aTercProd := {}
	Local cTarefa   := "0"
	Local cAliasTar := ""
	Local aDatFim   := {}
	Local cHoraAtu  := Substr( Time(), 1, 5 )

	Private dDtMDO    := Ctod("  /  /  "),cHoMDO := Space(5)

	//Recebe os Produtos de Terceiros do parametro
	aTercProd := aClone(NGProdMNT("T"))
	lTercProd := ( aScan(aTercProd, {|x| AllTrim(x) == AllTrim( cCodIns ) }) > 0)
	cTipoReg := If(lTercProd, "T", "P")

	//Valores utilizados para garantir o funcionamento da função ULTSEQ
	M->TJ_ORDEM   := STJ->TJ_ORDEM
	M->TJ_PLANO   := STJ->TJ_PLANO
	M->TL_ORDEM   := STJ->TJ_ORDEM
	M->TL_PLANO   := STJ->TJ_PLANO
	nSEQSTL := ULTSEQ(STJ->(Recno()))

	If cTipoReg == "T"
		cCodigo := SD1->D1_FORNECE
		aDatFim := NGDTHORFIM( SD1->D1_DTDIGIT, cHoraAtu, SD1->D1_QUANT )
	Else
		cCodigo  := SD1->D1_COD
		cDestino := "A"
		aDatFim  := { SD1->D1_DTDIGIT, cHoraAtu }
	EndIf

	dbSelectArea("STJ")
	dbSetorder(1)
	If dbSeek(xFilial("STJ")+cOrdem)
		lTermino := STJ->TJ_TERMINO == 'S'
	Endif

	//----------------------------------------------------------
	//Busca tarefa do insumo previsto pela solicitação de compra
	//-----------------------------------------------------------
	If !Empty( SD1->D1_ORDEM )
		cAliasTar := GetNextAlias()

		BeginSQL Alias cAliasTar

			SELECT STL.TL_TAREFA, STL.TL_DESTINO
				FROM %table:STL% STL
			JOIN %table:SC7% SC7 //pedido de compra
				ON SC7.C7_NUMSC = STL.TL_NUMSC
				AND SC7.C7_ITEMSC = STL.TL_ITEMSC
				AND SC7.C7_FILIAL = %xfilial:SC7%
				AND SC7.C7_NUM = %exp:SD1->D1_PEDIDO%
				AND SC7.C7_ITEM = %exp:SD1->D1_ITEMPC%
				AND SC7.%NotDel%
			WHERE STL.TL_CODIGO = %exp:cCodigo%
				AND STL.TL_ORDEM = %exp:SD1->D1_ORDEM%
				AND STL.TL_FILIAL = %xfilial:STL%
				AND STL.%NotDel%
		EndSQL

		If (cAliasTar)->( !EoF() )
			cTarefa  := (cAliasTar)->TL_TAREFA
			cDestino := (cAliasTar)->TL_DESTINO
		EndIf
		(cAliasTar)->( dbCloseArea() )
	EndIf

	dbSelectArea("STL")
	dbSetorder(1)  // ORDEM DE NUMSEQ
	Reclock("STL",.T.)
	STL->TL_FILIAL  := xfilial('STL')
	STL->TL_ORDEM   := cOrdem
	STL->TL_PLANO   := STJ->TJ_PLANO
	STL->TL_CODIGO  := cCodigo
	STL->TL_TIPOREG := cTipoReg
	STL->TL_TAREFA  := cTarefa
	STL->TL_USACALE := 'N'
	STL->TL_GARANTI := 'N'
	STL->TL_SEQRELA := nSEQSTL
	STL->TL_UNIDADE := If(cTIPOREG = "T","H",SD1->D1_UM)
	STL->TL_QUANTID := SD1->D1_QUANT
	STL->TL_NUMSEQ  := SD1->D1_NUMSEQ

	// Data e hora ver função MNTINTSD3
	STL->TL_DTINICI := SD1->D1_DTDIGIT
	STL->TL_HOINICI := cHoraAtu
	STL->TL_DTFIM   := aDatFim[1]
	STL->TL_HOFIM   := aDatFim[2]

	STL->TL_DESTINO := cDestino
	STL->TL_REPFIM  := 'S'
	STL->TL_CUSTO   := SD1->D1_CUSTO
	STL->TL_NUMOP   := Substr(SD1->D1_OP,1,6)
	STL->TL_ITEMOP  := Substr(SD1->D1_OP,7,2)
	STL->TL_SEQUEOP := Substr(SD1->D1_OP,9,3)
	STL->TL_TIPOHOR := ALLTrim(GETMV("MV_NGUNIDT"))
	STL->TL_ORIGNFE := 'SD1'
	STL->TL_FORNEC  := SD1->D1_FORNECE
	STL->TL_LOJA    := SD1->D1_LOJA
	STL->TL_NOTFIS  := SD1->D1_DOC
	STL->TL_SERIE   := SD1->D1_SERIE

	// Multi-Moeda [ UPDMNT39 ]
	// Define '1' como valor default para moeda, representando a moeda padrao do pais [ TL_CUSTO = SD3->D3_CUSTO1 ]
	If FieldPos("TL_MOEDA") > 0
		STL->TL_MOEDA := "1"
	Endif

	If lTermino
		STL->TL_OBSERVA := STR0259+DtoC(STL->TL_DTFIM)+"."+Chr(13)+; //"Insumo lançado após a finalização da O.S. em: "
								STR0260+DtoC(SD1->D1_DTDIGIT)+"." //"Data de lançamento: "
	EndIf

	DbSelectArea("STL")
	aESTRUT := DbStruct()

	RecLock("STL",.F.)
	DbSelectArea("SD1")
	For nVP := 1 To Fcount()
		nY := Fieldname(nVP)
		nX := "STL->TL"+Alltrim(Substr(nY,3,Len(nY)))
		cCAMPP := Alltrim(Substr(nY,3,Len(nY)))
		If Ascan(vVETCAMN, {|x| x == Alltrim(Substr(nY,3,Len(nY)))}) = 0
			If Ascan(aESTRUT, {|x| Alltrim(Substr(x[1],3,Len(x[1]))) == cCAMPP}) > 0
				nZ   := "SD1->"+Fieldname(nVP)
				&nX. := &nZ.
			Endif
		Endif
	Next

	MsUnlock()

	/*Ponto de entrada que será executado após a aplicação do insumo,
	com o intuito de finalizar a O.S. via Documento de Entrada da Nota Fiscal.*/
	If ExistBlock("NGFIMOS")
		ExecBlock("NGFIMOS",.F.,.F.)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGD1D2STL
Função para atualizar um insumo gerado através de um documento de
entrada, verifica documento de entrada X documento de saida.

@type function

@source MNTUTIL_OS.prw

@param cDocD2   , Caracter , D2_NFORI   - Numero da nota origem.
@param cSerieD2 , Caracter , D2_SERIORI - Serie da nota origem.
@param cItemD2  , Caracter , D2_ITEMORI - Item da nota origem.
@param cForneD2 , Caracter , D2_CLIENTE - Código do fornecedor.
@param cLojaD2  , Caracter , D2_LOJA    - Loja do cliente.
@param cProdD2  , Caracter , D2_COD     - Código do produto.
@param nQuantR  , Numérico , D2_QUANT   - Quantidade a ser deletada
@param nValorR  , Numérico , D2_TOTAL   - Valor a ser deletado
@param lInclui  , Lógico   , indica uma inclusão de nota vinculada a uma NF com origem
							FALSO indica uma devolução (decremento de valores)
@param [nRecSd1], numérico , número do recno da NF de entrada atual

@author Tainã Alberto Cardoso
@since 24/01/2019

@return Lógico, Sempre verdadeiro
/*/
//---------------------------------------------------------------------
Function NGD1D2STL( cDocD2, cSerieD2, cItemD2, cForneD2, cLojaD2 ,cProdD2, nQuantR, nValorR, lInclui, nRecSd1 )

	Local cAliasSD1 := ""
	Local cAliasSD2 := ""
	Local cAliasSTL := ""

	Local nValorSD1 := 0
	Local nQuantSD1 := 0

	Local nValorSD2 := 0
	Local nQuantSD2 := 0

	Local nVAlSTL   := 0
	Local nQuantSTL := 0
	Local lTemOs    := .F.

	Default nRecSd1 := 0   // somente será zero quando a origem é no documento de saída

	//--------------------------------------------------
	// o trecho a seguir tem o objetivo de: 
	// verificar se há uma ordem de serviço vinculada
	// e posicionar na nota fiscal origem
	//--------------------------------------------------

	If nRecSd1 > 0

		//-------------------------------------------------------------
		// chamada foi realizada pelo DOCUMENTO DE ENTRADA: SD1 x SD1
		//-------------------------------------------------------------

		DbSelectArea('SD1')
		DbSetOrder(1)
		DbGoTo(nRecSd1)

		lTemOs := !Empty(SD1->D1_ORDEM)

		If lTemOs

			//------------------------------------------------
			// busca nota origem sem especificar o fornecedor
			//------------------------------------------------
			cAliasSD1 := GetNextAlias()
			BeginSQL Alias cAliasSD1

				SELECT R_E_C_N_O_ AS RECNO
				FROM %table:SD1% SD1
				WHERE SD1.D1_FILIAL = %xfilial:SD1%
					AND SD1.D1_DOC = %exp:SD1->D1_NFORI%
					AND SD1.D1_SERIE  = %exp:SD1->D1_SERIORI%
					AND SD1.D1_ITEM = %exp:SD1->D1_ITEMORI%
				AND %NotDel%

			EndSQL

			//--------------------------
			// Posiciona na nota origem 
			//--------------------------
			DbSelectArea('SD1')
			DbSetOrder(1)
			DbGoTo((cAliasSD1)->RECNO)

			(cAliasSD1)->(dbCloseArea())

		EndIf

	Else

		//------------------------------------------------------------------
		// chamada foi realizada pelo DOCUMENTO DE SAIDA: SD2 x SD1 x SD1
		//------------------------------------------------------------------

		//------------------------------------------------------------------
		// Posiciona na NF de compra e NFOrigem 2 caso exista
		//------------------------------------------------------------------
		If !Empty(SD1->D1_ORDEM)
			lTemOs := .T.
		ElseIf SD1->D1_TIPO == 'C' .And. !Empty(SD1->D1_NFORI) //Verificar a nota original possui O.S.
			dbSelectarea("SD1")
			dbSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			If dbSeek( xFilial("SD1") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + ;
					   SD1->D1_COD + SD1->D1_ITEMORI ) .And. !Empty(SD1->D1_ORDEM)
				lTemOs := .T.
			EndIf
		EndIf

	EndIf

	If lTemOs
		//Soma a quantidade de todas as notas fiscais e dos complementos
		cAliasSD1 := GetNextAlias()
		BeginSQL Alias cAliasSD1

			SELECT SUM(D1_QUANT) QUANTID, SUM(D1_TOTAL) VALOR
				FROM %table:SD1%
					WHERE D1_FILIAL = %xfilial:SD1%
						AND ( ( D1_DOC = %exp:SD1->D1_DOC%
								AND D1_SERIE = %exp:SD1->D1_SERIE%
								AND D1_ITEM = %exp:SD1->D1_ITEM% )
							OR ( D1_NFORI =  %exp:SD1->D1_DOC%
								AND D1_SERIORI = %exp:SD1->D1_SERIE%
								AND D1_ITEMORI = %exp:SD1->D1_ITEM% ) )
						AND %NotDel%
		EndSQL

		If (cAliasSD1)->( !EoF() )
			nValorSD1 := (cAliasSD1)->VALOR
			nQuantSD1 := (cAliasSD1)->QUANTID
		EndIf

		(cAliasSD1)->(dbCloseArea())

		//Soma toda a quantidade devolvida para o fornecedor
		cAliasSD2 := GetNextAlias()
		BeginSQL Alias cAliasSD2

			SELECT SUM(D2_QUANT) QUANTID, SUM(D2_TOTAL) VALOR
				FROM %table:SD2%
					WHERE D2_FILIAL = %xfilial:SD2%
						AND D2_NFORI =  %exp:cDocD2%
						AND D2_SERIORI = %exp:cSerieD2%
						AND D2_ITEMORI = %exp:cItemD2%
						AND %NotDel%
		EndSQL

		If (cAliasSD2)->( !EoF() )
			nValorSD2 := (cAliasSD2)->VALOR
			nQuantSD2 := (cAliasSD2)->QUANTID
		EndIf

		(cAliasSD2)->(dbCloseArea())

		//Pega o saldo de Documento de entrada X Documento de Saida.
		nVAlSTL   := nValorSD1 - nValorSD2
		nQuantSTL := nQuantSD1 - nQuantSD2

		//Busca insumo relacionada a nota de origem
		cAliasSTL := GetNextAlias()
		BeginSQL Alias cAliasSTL

			SELECT R_E_C_N_O_
				FROM %table:STL%
					WHERE TL_FILIAL = %xfilial:STL%
						AND TL_NOTFIS = %exp:SD1->D1_DOC%
						AND TL_SERIE = %exp:SD1->D1_SERIE%
						AND TL_ITEM = %exp:SD1->D1_ITEM%
						AND TL_ORDEM = %exp:SD1->D1_ORDEM%
						AND %NotDel%
		EndSQL

		If (cAliasSTL)->( !EoF() )

			dbSelectarea("STL")
			dbGoTo((cAliasSTL)->R_E_C_N_O_)
			RecLock("STL", .F.)
			If nQuantSTL > 0 .Or. nVAlSTL > 0
				STL->TL_QUANTID := If( lInclui, nQuantSTL, nQuantSTL - nQuantR )
				STL->TL_CUSTO   := IF( lInclui, nVAlSTL, nVAlSTL - nValorR )
			Else
				dbDelete()
			EndIf
			MsUnLock()
		EndIf
		(cAliasSTL)->( dbCloseArea() )

	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} NGALTPROD
Atualiza aCols com produto alternativo para os produtos que não possuirem saldo

@author Eduardo Mussi
@since  09/04/2019

@sample NGALTPROD( aCols, aHeader, ST9->T9_CODBEM, 'TL', 'MNTA420' )

@param  aColsAlt   , Array   , Acols
@param  [aHeadAlt] , Array   , aHeader
@param  cCodeBem   , Caracter, Código do Bem
@param  cRef       , Caracter, Referencia da tabela. Ex.: STL - 'TL'
@param  cCallProg  , Caracter, Indica o programa que está chamando.
@param  [aFieldPos], Array   , Define posições dos campos no array aColsAlt
							  [ 1 ] - Tipo de Insumo
							  [ 2 ] - Código
							  [ 3 ] - Quantidade
							  [ 4 ] - Tarefa
							  [ 5 ] - Local
							  [ 6 ] - Destino
							  [ 7 ] - Custo
@Return Array, Retorna acols alterado com produto alternativo.
/*/
//-------------------------------------------------------------------
Function NGALTPROD( aColsAlt, aHeadAlt, cCodeBem, cRef, cCallProg, aFieldPos )

    Local aProducts  := {}
	Local aArea      := GetArea()
	Local cBranchSGI := xFilial( 'SGI' )
	Local cBranchSB2 := xFilial( 'SB2' )
	Local cTypeCalc  := AllTrim( SuperGetMV( 'MV_TPSALDO' ) )
	Local lNgInter   := AllTrim( SuperGetMV( 'MV_NGINTER', .F., '' ) ) == 'M'
	Local lReprocess := .T.
	Local nSizePro   := 0
	Local nInsumo    := 1
	Local nPosTip    := 0
	Local nPosQnt    := 0
	Local nPosDes    := 0
	Local nPosCod    := 0
	Local nPosTas    := 0
	Local nPosLoc    := 0
	Local nPosCus    := 0
	Local nPos       := 0
	Local lPosCus    := .F.
	Local lPosTas    := .F.
	// Verifica se já foi criada a tabela temporária, tratativa necessária pois algumas rotinas possuem begin transaction
	// então os TRB's devem ser criados antes de iniciar o begin transaction.
	Local lCreateTbl := Type( 'oTempIns' ) == 'U'

	Default aHeadAlt  := {}
	Default aFieldPos := {}

	If Len( aHeadAlt ) > 0
		nPosTip := GDFieldPos( cRef + '_TIPOREG', aHeadAlt )
		nPosQnt := GDFieldPos( cRef + '_QUANTID', aHeadAlt )
		nPosDes := GDFieldPos( cRef + '_DESTINO', aHeadAlt )
		nPosCod := GDFieldPos( cRef + '_CODIGO' , aHeadAlt )
		nPosTas := GDFieldPos( cRef + '_TAREFA' , aHeadAlt )
		nPosLoc := GDFieldPos( cRef + '_LOCAL'  , aHeadAlt )
		nPosCus := GDFieldPos( cRef + '_CUSTO'  , aHeadAlt )
	ElseIf Len( aFieldPos ) > 0
		nPosTip := aFieldPos[ 1 ]
		nPosCod := aFieldPos[ 2 ]
		nPosQnt := aFieldPos[ 3 ]
		nPosTas := aFieldPos[ 4 ]
		nPosLoc := aFieldPos[ 5 ]
		nPosDes := aFieldPos[ 6 ]
		nPosCus := aFieldPos[ 7 ]
	EndIf

	lPosCus := nPosCus > 0
	lPosTas := nPosTas > 0

	// Cria um array somente com produtos
	aProducts := NGJointPro( @aColsAlt, { nPosQnt, nPosTip, nPosCod, nPosLoc }, cRef, Len( aHeadAlt ) > 0 )

	nSizePro := Len( aProducts )

	If nSizePro > 0

		// Verifica se já foi criada a tabela temporária, tratativa necessária pois algumas rotinas possuem begin transaction
		// então os TRB's devem ser criados antes de iniciar o begin transaction.
		If lCreateTbl
			NewTrbAlt()
		EndIf

		// Popula tabela temporaria com os produtos retornados pela função NGJointPro
		dbSelectArea( cAliasIns )
		For nInsumo := 1 To nSizePro

			RecLock( ( cAliasIns ), .T. )
			( cAliasIns )->PRODUTO   := aProducts[ nInsumo, 1 ]
			( cAliasIns )->LOCAL     := aProducts[ nInsumo, 2 ]
			( cAliasIns )->LOCALORIG := aProducts[ nInsumo, 2 ]
			( cAliasIns )->QTDREQ    := aProducts[ nInsumo, 3 ]
			( cAliasIns )->QTDREQORI := aProducts[ nInsumo, 3 ]
			( cAliasIns )->STATUS    := '0'
			( cAliasIns )->PRODORIG  := aProducts[ nInsumo, 1 ]
			( cAliasIns )->PRODLINE  := aProducts[ nInsumo, 4 ]
			( cAliasIns )->( MsUnLock() )

		Next nInsumo

		Do While lReprocess
			// Cria um arquivo temporário de saldo com base nos insumos
			fGetStock( cBranchSB2, cTypeCalc, lNgInter )

			// Atualiza arquivo temporário
			fRefreshPr()

			// Valida quantidade do produto, caso haja necessidade busca por um produto alternativo
			lReprocess := fFindAltPr( cCodeBem, cBranchSGI, cBranchSB2, cTypeCalc, lNgInter )
		EndDo

		dbSelectArea( cAliasIns )
		dbGoTop()
		Do While (cAliasIns)->( !EoF() )

			If lPosTas
				// Verifica se a chave a ser inserida já existe
				nPos := aScan( aColsAlt, { |x| x[ nPosTas ] + x[ nPosCod ] + x[ nPosLoc ] + x[ nPosDes ] == aColsAlt[ (cAliasIns)->PRODLINE, nPosTas ] +;
						(cAliasIns)->PRODUTO + (cAliasIns)->LOCAL + aColsAlt[ (cAliasIns)->PRODLINE, nPosDes ] } )
			Else
				// Verifica se a chave a ser inserida já existe
				nPos := aScan( aColsAlt, { |x| x[ nPosCod ] + x[ nPosLoc ] + x[ nPosDes ] ==(cAliasIns)->PRODUTO +;
							(cAliasIns)->LOCAL + aColsAlt[ (cAliasIns)->PRODLINE, nPosDes ] } )
			EndIf

			// Cria array para os produtos que não possuirem saldo e nem Produto alternativo.
			If (cAliasIns)->STATUS == '2'
				aAdd( aNewSC, { (cAliasIns)->PRODORIG, (cAliasIns)->LOCALORIG,;
						Posicione( cAliasSLP, 1, (cAliasIns)->PRODORIG + (cAliasIns)->LOCALORIG, 'SALDO' ) } )
			EndIf

			If nPos > 0

				// Verifica se a linha está deletada
				If aTail( aColsAlt[ nPos ] )
					// Caso a linha tenha sido deletada pelo usuário não poderá ser utilizada
					If aColsAlt[ nPos, nPosQnt ] != 0
						// Então posiciona na linha salva no TRB incialmente.
						nPos := (cAliasIns)->PRODLINE

						// Atualiza código do produto
						If aColsAlt[ nPos, nPosCod ] != (cAliasIns)->PRODUTO
							aColsAlt[ nPos, nPosCod ] := (cAliasIns)->PRODUTO
						EndIf

					Else
						// Remove a deleção caso a quantidade seja 0.
						aColsAlt[ nPos, Len( aColsAlt[ nPos ] ) ] := .F.
					EndIf
				EndIf

				// Adiciona quantidade do P.A. para o produto já existente no aCols
				aColsAlt[ nPos, nPosQnt ] += (cAliasIns)->QTDREQ

				If lPosCus
					// Ajusta o custo do produto após adição da quantidade
					aColsAlt[ nPos, nPosCus ] := NGCALCUSTI( (cAliasIns)->PRODUTO, 'P', aColsAlt[ nPos, nPosQnt ], (cAliasIns)->LOCAL )
				EndIf

				// Para nao gerar inconsistência a um proximo produto alternativo que for utilizar o produto
				// do aCols e remove a quatantidade solicitada inicialmente
				aColsAlt[ (cAliasIns)->PRODLINE, nPosQnt ] -= (cAliasIns)->QTDREQORI

				// Só será deletada a linha caso a quantidade seja 0
				If aColsAlt[ (cAliasIns)->PRODLINE, nPosQnt ] == 0
					// Caso não seja mais utilizado a linha ficará como deletada.
					aColsAlt[ (cAliasIns)->PRODLINE, Len( aColsAlt[ (cAliasIns)->PRODLINE ] ) ] := .T.
				Else
					If lPosCus
						// Atualiza custo do produto original com base na quantidade atual.
						aColsAlt[ (cAliasIns)->PRODLINE, nPosCus ] := NGCALCUSTI( aColsAlt[ (cAliasIns)->PRODLINE, nPosCod ], 'P', aColsAlt[ (cAliasIns)->PRODLINE, nPosQnt ], aColsAlt[ (cAliasIns)->PRODLINE, nPosLoc ] )
					EndIf
				EndIf
			Else
				// Remove deleção de linha
				If aTail( aColsAlt[ (cAliasIns)->PRODLINE ] )
					aColsAlt[ (cAliasIns)->PRODLINE, Len( aColsAlt[ (cAliasIns)->PRODLINE ] ) ] := .F.
				EndIf

				// Altera a linha do Produto Original
				aColsAlt[ (cAliasIns)->PRODLINE, nPosCod ] := (cAliasIns)->PRODUTO
				aColsAlt[ (cAliasIns)->PRODLINE, nPosLoc ] := (cAliasIns)->LOCAL
				aColsAlt[ (cAliasIns)->PRODLINE, nPosQnt ] := (cAliasIns)->QTDREQ
				If lPosCus
					aColsAlt[ (cAliasIns)->PRODLINE, nPosCus ] := NGCALCUSTI( (cAliasIns)->PRODUTO, 'P', (cAliasIns)->QTDREQ, (cAliasIns)->LOCAL )
				EndIf

			EndIf

			(cAliasIns)->( dbSkip() )
		EndDo

		// Caso as posições sejam fixas, deverá ser verificado se existem posições a serem deletadas
		// e posteriormente realizam a deleção
		If cCallProg $ 'NGGERAOS/MNTNG'
			Do While ( nPos := aScan( aColsAlt, { |x| x[ Len( x ) ] } ) ) > 0
				aDel( aColsAlt, nPos )
				aSize( aColsAlt, Len( aColsAlt ) - 1 )
			EndDo
		EndIf

		// Tratativa para que o app não fique travado.
		// Devido à um Begin Sequence não é possivel deletar as tabelas temporárias aqui.
		If lCreateTbl
			// Fecha tabela temporária
			oTempIns:Delete()
			oTempSLP:Delete()
		EndIf

	EndIf

	RestArea( aArea )

Return aColsAlt

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetStock
Busca saldo dos produtos

@author  Eduardo Mussi
@since   date
@param  cBranchSB2, Caracter, Filial SB2
@param  cTypeCalc , Caracter, Conteúdo do parametro MV_TPSALDO
@param  lNgInter  , Lógico  , Define se está integrado ao RM
/*/
//-------------------------------------------------------------------
Static Function fGetStock( cBranchSB2, cTypeCalc, lNgInter )

    Local nStockLvl  := 0
	Local cSLProduct := GetNextAlias()
	Local cAliasSLP  := oTempSLP:GetAlias()
	Local cTableINS  := '%' + oTempIns:GetRealName() + '%'
	Local cTableSLP  := '%' + oTempSLP:GetRealName() + '%'

    // Stock Level Product
    // Seleciona os produtos que não estão presentes na tabela SLP ( Stock Level Product )
    BeginSQL Alias cSLProduct
        SELECT DISTINCT INS.PRODUTO, INS.LOCAL
        FROM
            %exp:cTableINS% INS
        LEFT JOIN
            %exp:cTableSLP% SLP
                ON ( SLP.PRODUTO || SLP.LOCAL = INS.PRODUTO || INS.LOCAL )
        WHERE
            SLP.PRODUTO IS NULL
	EndSQL

	// Percorre todos os produtos que nao tiveram seu saldo verificado até o momento
    Do While ( cSLProduct )->( !EoF() )

        // Busca saldo disponivel em estoque para o produto
        nStockLvl := NGGetStock( ( cSLProduct )->PRODUTO, ( cSLProduct )->LOCAL, cBranchSB2, cTypeCalc, lNgInter )

        // Armaneza o saldo consultado no TRB de Saldo
        dbSelectArea( cAliasSLP )
        RecLock( cAliasSLP, .T. )
        ( cAliasSLP )->PRODUTO := ( cSLProduct )->PRODUTO
        ( cAliasSLP )->LOCAL   := ( cSLProduct )->LOCAL
        ( cAliasSLP )->SALDO   := nStockLvl
        ( cAliasSLP )->( MsUnlock() )

        ( cSLProduct )->( dbSkip() )

    EndDo

    ( cSLProduct )->( dbCloseArea() )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fRefreshPr
Verifica atráves de uma query na TRB os produtos que serão ou não
atendidos tendo em base o saldo atual em estoque dos produtos
validados.

@author Eduardo Mussi
@since  08/04/2019

/*/
//-------------------------------------------------------------------
Static Function fRefreshPr()

	Local cUpdateQry := ''
	Local cAliQry    := GetNextAlias()	
	Local cAliasQry  := oTempIns:GetRealName()

	// Atualiza o status de todos os insumos que podem ser atendidos pelo saldo atual
	cUpdateQry += "UPDATE " +  cAliasQry + " "
	cUpdateQry += "SET " + cAliasQry + ".STATUS = '1' "
	cUpdateQry += "WHERE "
	cUpdateQry +=       "( "
	cUpdateQry +=           "SELECT "
	cUpdateQry +=               "CASE "
	cUpdateQry +=                   "WHEN SUM( INSAUX.QTDREQ ) <= SLP.SALDO THEN 1 "
	cUpdateQry +=                   "ELSE 0 "
	cUpdateQry +=               "END "
	cUpdateQry +=           "FROM "
	cUpdateQry +=               cAliasQry + " INSAUX "
	cUpdateQry +=           "INNER JOIN "
	cUpdateQry +=               oTempSLP:GetRealName() + " SLP "
	cUpdateQry +=               "ON ( SLP.PRODUTO = INSAUX.PRODUTO AND SLP.LOCAL = INSAUX.LOCAL ) "
	cUpdateQry +=           "WHERE "
	cUpdateQry +=               "INSAUX.PRODUTO = " + cAliasQry + ".PRODUTO AND INSAUX.LOCAL = " + cAliasQry + ".LOCAL "
	cUpdateQry +=           "GROUP BY INSAUX.PRODUTO, INSAUX.LOCAL, SLP.SALDO "
	cUpdateQry +=       ") = 1 "

    TcSqlExec( cUpdateQry )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fFindAltPr
Para os insumos com status "Não tem saldo", procura seu alternativo e
atualiza a TRB de insumos.

@author Eduardo Mussi
@since  08/04/2019
@param  cCodeBem  , Caracter, Código do bem
@param  cBranchSGI, Caracter, Filial SGI
@param  cBranchSB2, Caracter, Filial SB2
@param  cTypeCalc , Caracter, Conteúdo do parametro MV_TPSALDO
@param  lNgInter  , Lódigo  , Conteúdo do parametro MV_NGINTER
@return Lógico, Define se ainda há produtos a serem processados.
/*/
//-------------------------------------------------------------------
Static Function fFindAltPr( cCodeBem, cBranchSGI, cBranchSB2, cTypeCalc, lNgInter )

	Local aAlterProd := {}
	Local lHavePro   := .F.
	Local cAliasIns  := oTempIns:GetAlias()

	// Abre e seta indice para busca do produto alternativo
	dbSelectArea( 'SGI' )
	dbSetOrder( 1 )

    dbSelectArea( cAliasIns )
    dbSetOrder( 2 )

	If dbSeek( '0' )
		Do While ( cAliasIns )->( !EoF() ) .And. ( cAliasIns )->STATUS == '0'

			// Busca o produto alternativo
			aAlterProd := GetAlterPr( cCodeBem, cBranchSGI, cBranchSB2, ( cAliasIns )->PRODORIG, ( cAliasIns )->ORDALTER,;
				( cAliasIns )->QTDREQORI, cTypeCalc, lNgInter )

			dbSelectArea( cAliasIns )
			RecLock( cAliasIns, .F. )
			// Caso não possua mais produtos alternativos e a quantidade não seja atendida é alterado o Status para 2
			// e serão informados os dados iniciais para que continue o processo padrão( geração de SC para o produto )
			If Empty( aAlterProd )
				( cAliasIns )->STATUS  := '2' // Define que devera gerar SC
				( cAliasIns )->PRODUTO := ( cAliasIns )->PRODORIG  // Recebe produto origem
				( cAliasIns )->LOCAL   := ( cAliasIns )->LOCALORIG // Recebe a quantidade original
				( cAliasIns )->QTDREQ  := ( cAliasIns )->QTDREQORI // Recebe a quantidade original
				( cAliasIns )->( MsUnlock() )
				( cAliasIns )->( dbSeek( '0' ) )
			Else
				( cAliasIns )->PRODUTO  := aAlterProd[1] // Produto Alternativo (P.A.)
				( cAliasIns )->LOCAL    := aAlterProd[2] // Local do P.A.
				( cAliasIns )->QTDREQ   := aAlterProd[3] // Quantidade original convertida para o fator do P.A.
				( cAliasIns )->ORDALTER := aAlterProd[4] // Ordem do P.A.
				( cAliasIns )->( MsUnlock() )
			Endif

			( cAliasIns )->( dbSkip() )

		EndDo

		lHavePro := .T.

	EndIf

Return lHavePro

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAlterPr
Busca pelo Produto Alternativo

@author Eduardo Mussi
@since  08/04/2019
@param  cCodeBem  , Caracter, Código do Bem
@param  cBranchSGI, Caracter, Filial SGI
@param  cBranchSB2, Caracter, Filial SB2
@param  cProduct  , Caracter, Código do Produto
@param  cOrder    , Caracter, Ordem do Produto Alternativo( GI_ORDEM )
@param  nQuant    , Numérico, Quantidade solicitada do produto
@param  cTypeCalc , Caracter, Conteúdo do parametro MV_TPSALDO
@param  lNgInter  , Lódigo  , Conteúdo do parametro MV_NGINTER
@return Array, Retorna array do produto alternativo
		Array[ 1 ] - Produto Alternativo
		Array[ 2 ] - Local Produto Alternativo
		Array[ 3 ] - Quantidade convertida para o fator do produto alternativo
		Array[ 4 ] - Ordem do produto alternativo ( GI_ORDEM )
/*/
//-------------------------------------------------------------------
Static Function GetAlterPr( cCodeBem, cBranchSGI, cBranchSB2, cProduct, cOrder, nQuant, cTypeCalc, lNgInter )

	Local aArea     := GetArea()
	Local aFindAlt  := {}
	Local cAltProd  := ''
	Local cProdLoc  := ''
	Local lHaveAlt  := .F.
	Local nSalStock := 0
	Local nQntCalc  := 0

	If !Empty( cOrder )
		// pesquisa pelo próximo produto alternativo conforme informação do cOrder
		SGI->( MsSeek( cBranchSGI + cProduct + cOrder ) )
		SGI->( dbSkip() )
		lHaveAlt := SGI->GI_FILIAL + SGI->GI_PRODORI == cBranchSGI + cProduct
	Else
		// Posiciona no primeiro produto alternativo
		lHaveAlt := SGI->( MsSeek( cBranchSGI + cProduct ) )
	EndIf

	If lHaveAlt
		cAltProd := SGI->GI_PRODALT
		cProdLoc := NGALMOXA( cCodeBem, cAltProd, 'P', .T. )

		// Retorna saldo do produto em estoque.
		nSalStock := NGGetStock( cAltProd, cProdLoc, cBranchSB2, cTypeCalc, lNgInter )
		nQntCalc  := IIf( SGI->GI_TIPOCON == 'M', nQuant * SGI->GI_FATOR, nQuant / SGI->GI_FATOR )

		aFindAlt := { cAltProd, cProdLoc, nQntCalc, SGI->GI_ORDEM }
	EndIf

	RestArea( aArea )

Return aFindAlt

//-------------------------------------------------------------------
/*/{Protheus.doc} NGGetStock
Busca saldo em estoque para um determinado produto.
Ps. ao chamar esta função a tabela SB2 deverá estar aberta e
definida para o indice 1 (um)

@author  Eduardo Henrique Mussi
@since   12/12/2018
@version P12

@param   cProdSal, Caracter, Código do Produto
@param   cLocProd, Caracter, Local do Produto
@param   cFilSB2 , Caracter, Filial de busca do produto
@param   cTpSaldo, Caracter, Conteúdo do parametro MV_TPSALDO
@param   lNgInter, Lógico  , Conteúdo do parametro MV_NGINTER

@return  Numérico, Quantidade de saldo em estoque.
/*/
//-------------------------------------------------------------------
Function NGGetStock( cProdSal, cLocProd, cFilSB2, cTpSaldo, lNgInter )

	Local aArea  := GetArea()
	Local nSaldo := 0

	/*----------------------------------------------------------
	| Validação conforme definição da Equipe de Estoque TOTVS  |
	| de acordo com o conteúdo do parâmetro MV_TPSALDO         |
	----------------------------------------------------------*/

	If SB2->( MsSeek( cFilSB2 + cProdSal + cLocProd ) )
		If lNgInter	// Integracao por Mensagem Unica
			nSaldo := NGMUStoLvl( cProdSal, cLocProd, .T. ) // Atualiza tabela
		Else
			If cTpSaldo == 'C'     // Busca saldo que o estoque tinha na data informada no parâmetro dData
				nSaldo := CalcEst( SB2->B2_COD, SB2->B2_LOCAL, dDataBase + 1 )[ 1 ]
			ElseIf cTpSaldo == 'S' // Retorna saldo atual independente da data
				nSaldo := SaldoSB2( .F., .T., dDataBase + 3650, .F. )
			ElseIf cTpSaldo == 'Q' // Retorna saldo com desconto de quantidade reservada e quantidade a enderecar
				nSaldo := SB2->B2_QATU - SB2->B2_QACLASS - SB2->B2_RESERVA
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return nSaldo


//-------------------------------------------------------------------
/*/{Protheus.doc} NGJointPro
Monta estrutura de produtos com base no aCols para avaliação de saldo.

@author Eduardo Mussi
@since  08/04/2019
@param  aColsVal , Array, aCols
@param  aHead    , Array, Contendo as posições para busca no aColsVal
						[ 1 ] - Posição referente a Quantidade
						[ 2 ] - Posição referente ao Tipo de insumo
						[ 3 ] - Posição referente ao Código do insumo
						[ 4 ] - Posição referente ao Local
@param  cRef     , Caracter, Referente da tabela a ser utilziada para
pesquisada no aHeader. Ex. STL parametro irá receber 'TL'
@param  lHasCabec, Lógico, Define que será utilizado aHeader
@return Array    , Contendo os produtos e suas quantidades
		[ 1 ] - Código do Produto
		[ 2 ] - Local
		[ 3 ] - Quantidade
		[ 4 ] - Linha do aCols onde encontra-se o produto
/*/
//-------------------------------------------------------------------
Static Function NGJointPro( aColsVal, aFieldPos, cRef, lHasCabec )

	Local aProducts := {}
	Local nPosQnt   := aFieldPos[ 1 ]
	Local nPosTip   := aFieldPos[ 2 ]
	Local nPosCod   := aFieldPos[ 3 ]
	Local nPosLoc   := aFieldPos[ 4 ]
	Local nLine

	If lHasCabec
		For nLine := 1 To Len( aColsVal )
			If aColsVal[ nLine, nPosTip ] == 'P' .And. !aTail( aColsVal[ nLine ] )
				aAdd( aProducts, { aColsVal[ nLine, nPosCod ], aColsVal[ nLine, nPosLoc ], aColsVal[ nLine, nPosQnt ], nLine } )
			EndIf
		Next nLine
	Else
		For nLine := 1 To Len( aColsVal )
			If aColsVal[ nLine, nPosTip ] == 'P'
				aAdd( aProducts, { aColsVal[ nLine, nPosCod ], aColsVal[ nLine, nPosLoc ], aColsVal[ nLine, nPosQnt ], nLine } )
			EndIf
			// Adiciona ultima posição para simular linha da GetDados
			aAdd( aColsVal[ nLine ], .F. )
		Next nLine
	EndIf

Return aProducts

//-------------------------------------------------------------------
/*/{Protheus.doc} NewTrbAlt
Monta TRB que será utilizado na função NGALTPROD

@author  Eduardo Mussi
@since   17/04/2019

/*/
//-------------------------------------------------------------------
Function NewTrbAlt()

 	Local aFldIns    := {}
	Local aFldSLP    := {}
    Local aTamQtd    := TAMSX3( 'TL_QUANTID' )
	Local aTamSal    := TAMSX3( 'B2_QATU' )
	Local nSizeLoc   := TamSx3( 'B1_LOCPAD' )[ 1 ]
	Local nSizeCod   := TamSx3( 'B1_COD'    )[ 1 ]
	Local nSizeOrd   := TamSx3( 'GI_ORDEM'  )[ 1 ]

	_SetOwnerPrvt('oTempIns')
	_SetOwnerPrvt('oTempSLP')

	_SetOwnerPrvt('cAliasIns', GetNextAlias())
	_SetOwnerPrvt('cAliasSLP', GetNextAlias())

	// Construção do TRB de insumos para analise
	// Obs: Apenas insumos do tipo Produto ( TL_TIPOREG = P )
	aFldIns := { { 'PRODUTO'  , 'C', nSizeCod    , 0            }, ;
				 { 'LOCAL'    , 'C', nSizeLoc    , 0            }, ;
				 { 'LOCALORIG', 'C', nSizeLoc    , 0            }, ; // Local origem
				 { 'QTDREQ'   , 'N', aTamQtd[ 1 ], aTamQtd[ 2 ] }, ;
				 { 'QTDREQORI', 'N', aTamQtd[ 1 ], aTamQtd[ 2 ] }, ; // Quantidade original
				 { 'STATUS'   , 'C', 1           , 0            }, ; // ( 0=Não tem saldo; 1=Tem saldo; 2=Não tem saldo e não tem mais alternativos )
				 { 'PRODORIG' , 'C', nSizeCod    , 0            }, ;
				 { 'ORDALTER' , 'C', nSizeOrd    , 0            }, ;
				 { 'PRODLINE' , 'N', 3           , 0            } }

	oTempIns := NGFwTmpTbl( cAliasIns, aFldIns, { { 'PRODUTO', 'LOCAL' }, { 'STATUS' } }  )

	// Construção do TRB de saldo de produto
	aFldSLP := { { 'PRODUTO' , 'C', nSizeCod    , 0            }, ;
				 { 'LOCAL'   , 'C', nSizeLoc    , 0            }, ;
				 { 'SALDO'   , 'N', aTamSal[ 1 ], aTamSal[ 2 ] } }

	oTempSLP := NGFwTmpTbl( cAliasSLP, aFldSLP, { { 'PRODUTO', 'LOCAL' } }  )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} NGATUSTL
Atualiza insumos com produto alternativo

@author  Eduardo Mussi
@since   29/04/2019
@version P12
@param   cOrder      , Caracter, Numero da O.S.
@param   cPlan       , Caracter, Código do Plano
@param   cCodeBem    , Caracter, Código do Bem
@param   [aPosFields], Array   , Posições dos campos no aARRAYSTL
								 [1] - TL_QUANTID
								 [2] - TL_CODIGO
								 [3] - TL_LOCAL
								 [4] - TL_CUSTO
/*/
//-------------------------------------------------------------------
Function NGATUSTL( cOrder, cPlan, cCodeBem, aPosFields )

	Local aGetInf   := {}
	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	Local lInsumo   := .F.
	Local nPosQtd   := 0
	Local nPosCod   := 0
	Local nPosLoc   := 0
	Local nPosCus   := 0
	Local nPosPro   := 0
	Local nQtdSD4BX := 0
	Local nSizeLoc  := Len( SB1->B1_LOCPAD )
	Local nSizeCod  := Len( SB1->B1_COD )
	Local nSizeOP   := Len( SD4->D4_OP )
	Local nX

	Default aPosFields := {}

	If Type( 'aARRAYSTL' ) == 'A' .And. ( lInsumo := Len( aARRAYSTL ) > 0 .And. Len( aPosFields ) == 4 )
		nPosQtd  := aPosFields[ 1 ]
		nPosCod  := aPosFields[ 2 ]
		nPosLoc  := aPosFields[ 3 ]
		nPosCus  := aPosFields[ 4 ]
	EndIf

	// Busca os produtos utilizados na O.S.
	BeginSQL Alias cAliasQry
		SELECT	TL_TIPOREG,
				TL_CODIGO,
				TL_QUANTID,
				TL_TAREFA,
				TL_LOCAL,
				TL_DESTINO,
				TL_CUSTO,
				R_E_C_N_O_ AS RECNO
			FROM %table:STL%
			WHERE TL_FILIAL  = %xFilial:STL%
			  AND TL_ORDEM   = %exp:cOrder%
			  AND TL_PLANO   = %exp:cPlan%
			  AND TL_TIPOREG = 'P'
			  AND TL_SEQRELA = '0  '
			  AND %NotDel%
	EndSQL

	// Cria array para verificação de produto alternativos
	Do While (cAliasQry)->( !EoF() )
		aAdd( aGetInf, { (cAliasQry)->TL_TIPOREG, (cAliasQry)->TL_CODIGO, (cAliasQry)->TL_QUANTID,;
						 (cAliasQry)->TL_TAREFA , (cAliasQry)->TL_LOCAL , (cAliasQry)->TL_DESTINO,;
						 (cAliasQry)->TL_CUSTO  , (cAliasQry)->RECNO } )

		(cAliasQry)->( dbSkip() )
	EndDo

	(cAliasQry)->( dbCloseArea() )

	aGetInf := NGALTPROD( aGetInf, NIL, cCodeBem, 'TL', 'MNTUTIL_OS', { 01, 02, 03, 04, 05, 06, 07 } )

	// Atualiza TRB de insumos após realizar alterações de produto alternativo.
	For nX := 1 To Len( aGetInf )

		STL->( dbGoTo( aGetInf[ nX, 08 ] ) )

		// Quando o código do produto for diferente do original ou a linha estiver deletada
		// Busca e deleta STA.
		If STL->TL_CODIGO != aGetInf[ nX, 02 ] .Or. aTail( aGetInf[ nX ] )

			dbselectarea( 'STA' )
			dbsetOrder( 1 )
			If dbSeek( xFilial( 'STA' ) + cOrder + cPlan + STL->TL_TAREFA + STL->TL_TIPOREG + STL->TL_CODIGO )
				RecLock( 'STA', .F. )
				STA->( DbDelete() )
				STA->( MsUnlock() )
			EndIf

		EndIf

		If lInsumo .And. ( nPosPro := aScan( aARRAYSTL, { |x| AllTrim( Upper( x[ 2 ] ) ) == AllTrim( STL->TL_CODIGO ) } ) ) > 0

			// Deleta registro da SD4 do produto principal
			If NGIFDBSEEK( 'SD4', Padr( cOrder + 'OS' + '001', nSizeOP ) + Padr( aARRAYSTL[ nPosPro, nPosCod ], nSizeCod ) +;
			Padr( aARRAYSTL[ nPosPro, nPosLoc ], nSizeLoc ), 2 )
				NGDELSC1PR( cOrder, 'OS001', aARRAYSTL[ nPosPro, nPosCod ], aARRAYSTL[ nPosPro, nPosLoc ], aARRAYSTL[ nPosPro, nPosQtd ], .T. )
			EndIf
			// Verificar se a linha não está deletada
			If !aTail( aGetInf[ nX ] )
				// Atualiza o array de insumo com os novos dados.
				aARRAYSTL[ nPosPro, nPosQtd ] := aGetInf[ nX, 03 ]
				aARRAYSTL[ nPosPro, nPosCod ] := aGetInf[ nX, 02 ]
				aARRAYSTL[ nPosPro, nPosLoc ] := aGetInf[ nX, 05 ]
				aARRAYSTL[ nPosPro, nPosCus ] := aGetInf[ nX, 07 ]
			Else
				// Caso a linha retorne deletada, deleta STL
				aDel( aArraySTL, nPosPro )
				aSize( aArraySTL, Len( aArraySTL ) - 1 )
			EndIf

		EndIf

		// Visto que o insumo já possui na STL e na SD4, busca pelo insumo na SD4 para atualizar a quantidade.
		If NGIFDBSEEK( 'SD4', Padr( cOrder + 'OS' + '001', nSizeOP ) + Padr( aGetInf[ nX, 02 ], nSizeCod ) +;
		Padr( aGetInf[ nX, 05 ], nSizeLoc ), 2 ) .And. !aTail( aGetInf[ nX ] )

			nQtdSD4BX := aGetInf[ nX, 03 ] - ( SD4->D4_QTDEORI - SD4->D4_QUANT )

			RecLock( 'SD4', .F.)
			SD4->D4_QTDEORI	:= aGetInf[ nX, 03 ]
			SD4->D4_QUANT	:= nQtdSD4BX
			SD4->( MsUnlock() )

			NGAtuErp( 'SD4', 'UPDATE' )
		EndIf

		// Altera STL conforme retorno da função de produto alternativo.
		RecLock( 'STL', .F. )
		If !aTail( aGetInf[ nX ] )
			STL->TL_QUANTID := aGetInf[ nX, 03 ]
			STL->TL_CODIGO  := aGetInf[ nX, 02 ]
			STL->TL_LOCAL   := aGetInf[ nX, 05 ]
			STL->TL_CUSTO   := aGetInf[ nX, 07 ]
		Else
			// Caso a linha retorne deletada, deleta STL
			STL->( DbDelete() )
		EndIf

		STL->( MsUnlock() )

	Next nX

	RestArea( aArea )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MntUpdCost
Quando integrado ao RM, realiza a atualização do custo e saldo dos insumos.
@type function

@author Alexandre Santos
@since 27/09/2019

@sample MntUpdCost( aCols, aHeader )

@param aIns , Array, Lista de insumos reportados na O.S.
@param aHead, Array, Campos apresentado no getdados.
@return
/*/
//---------------------------------------------------------------------
Function MntUpdCost( aIns, aHead )

	Local nIndex := 0
	Local nType  := aScan( aHead, { |x| Trim( Upper( x[2] ) ) == 'TL_TIPOREG' } )
	Local nCode  := aScan( aHead, { |x| Trim( Upper( x[2] ) ) == 'TL_CODIGO'  } )
	Local nWare  := aScan( aHead, { |x| Trim( Upper( x[2] ) ) == 'TL_LOCAL'   } )

	For nIndex := 1 to Len( aIns )

		// TRATAMENTO EXCLUSIVO PARA MÃO DE OBRA E PRODUTO.
		If ( nType > 0 .And. nCode > 0 .And. nWare > 0 ) .And. aIns[nIndex,nType] $ 'M/P'

			MNTCusPro( aIns[nIndex,nType], aIns[nIndex,nCode], aIns[nIndex,nWare] )

		EndIf

	Next nIndex

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MntSeqSub
Busca relacionamentos com SEQRELA da OS (STJ) ou Manutenção (STF).
@type function

@author Diego de Oliveira
@since 04/11/2019

@param cCodBem  , Caracter, Código do Bem da Manutenção.
@param cServico , Caracter, Serviço da Manutenção.
@param cSeqRela , Caracter, Código da sequência da manutenção.
@param cPlano   , Caracter, Código do Plano.
@param [lOption], Lógico  , Define se deve verificar STF(T) ou STJ(F),
pois quando é chamado pelo MNTA365 a O.S. ainda está como pendente
e deverá ser verificado pela STF.
@return
/*/
//---------------------------------------------------------------------
Function MntSeqSub( cCodBem, cServico, cSeqRela, cPlano, lOption )

	Local aKill 	:= {}
	Local cSubs 	:= ""
	Local lVerSTJ   := SuperGetMV("MV_NG1SUBS", .F., "1" ) == "2"
	Local cAliasSub	:= GetNextAlias()
	Local cDataBase := AllTrim( TCGetDB() )

	Default lOption := .F.

	If lVerSTJ .Or. lOption
		cQuery	:= " WITH SEQUENCES (TF_FILIAL, TF_CODBEM, TF_SERVICO, TF_SEQRELA, TF_SUBSTIT) AS "
		cQuery	+= " 	( SELECT STF.TF_FILIAL  AS FILIAL, " // QUERY BASE
		cQuery	+= " 	  STF.TF_CODBEM  AS CODBEM, "
		cQuery	+= " 	  STF.TF_SERVICO AS SERVICO, "
		cQuery	+= " 	  STF.TF_SEQRELA AS SEQUENCIA, "
		cQuery	+= " 	  STF.TF_SUBSTIT AS SUBSTIT "
		cQuery	+= "      FROM " + RetSqlName("STF") + " STF "
		cQuery	+= " WHERE STF.TF_FILIAL  = " + ValToSQL(xFilial("STF",STJ->TJ_FILIAL))
		cQuery	+= "   AND STF.TF_CODBEM  = " + ValToSQL(cCodBem)
		cQuery	+= "   AND STF.TF_SERVICO = " + ValToSQL(cServico)
		cQuery	+= "   AND STF.TF_SEQRELA = " + ValToSQL(cSeqRela)
		cQuery  += "   AND STF.D_E_L_E_T_ <> '*'"
		cQuery	+= "  UNION ALL " //RECURSIVIDADE
		cQuery	+= "  SELECT "
		cQuery	+= "  RECUR_STF.TF_FILIAL  AS FILIAL, "
		cQuery	+= "  RECUR_STF.TF_CODBEM  AS CODBEM, "
		cQuery	+= "  RECUR_STF.TF_SERVICO AS SERVICO, "
		cQuery	+= "  RECUR_STF.TF_SEQRELA AS SEQUENCIA, "
		cQuery	+= "  RECUR_STF.TF_SUBSTIT AS SUBSTIT "
		cQuery	+= "  FROM " + RetSqlName("STF") + " RECUR_STF "
		cQuery	+= "  INNER JOIN SEQUENCES SEQ ON ( "
		cQuery	+= "    RECUR_STF.TF_FILIAL  = SEQ.TF_FILIAL "
		cQuery	+= "    AND RECUR_STF.TF_CODBEM  = SEQ.TF_CODBEM "
		cQuery	+= "    AND RECUR_STF.TF_SERVICO = SEQ.TF_SERVICO "
		//Tratamento para funções exclusivas do Oracle e SQL Server.
		If cDataBase == "ORACLE"
			cQuery += " AND instr(SEQ.TF_SUBSTIT,RTRIM(RECUR_STF.TF_SEQRELA)) > 0 ) "
		ElseIf cDataBase == "POSTGRES"
			cQuery += "  AND POSITION(RTRIM(RECUR_STF.TF_SEQRELA) IN SEQ.TF_SUBSTIT) > 0 ) "
		Else
			cQuery += "  AND CHARINDEX(RTRIM(RECUR_STF.TF_SEQRELA), SEQ.TF_SUBSTIT) > 0 ) "
		Endif
		cQuery	+= "  	) "
		cQuery	+= " SELECT DISTINCT TF_FILIAL, TF_CODBEM, TF_SERVICO, TF_SEQRELA "
		cQuery	+= "  FROM SEQUENCES "
		cQuery	+= "  WHERE TF_SEQRELA <> " + ValToSQL(cSeqRela)
		MPSysOpenQuery(cQuery, cAliasSub)//Changequery não suporta expressão WITH
	Else
		cQuery	:= " WITH SEQUENCES (TJ_FILIAL, TJ_CODBEM, TJ_SERVICO, TJ_SEQRELA, TJ_SUBSTIT) AS "
		cQuery	+= " 	( SELECT STJ.TJ_FILIAL AS FILIAL, " // QUERY BASE
		cQuery	+= " 	  STJ.TJ_CODBEM AS CODBEM, "
		cQuery	+= " 	  STJ.TJ_SERVICO AS SERVICO, "
		cQuery	+= " 	  STJ.TJ_SEQRELA AS SEQUENCIA, "
		cQuery	+= " 	  STJ.TJ_SUBSTIT AS SUBSTIT "
		cQuery	+= "      FROM " + RetSqlName("STJ") + "  STJ "
		cQuery	+= " WHERE STJ.TJ_FILIAL  = " + ValToSQL(xFilial("STJ",STJ->TJ_FILIAL))
		cQuery	+= "   AND STJ.TJ_CODBEM  = " + ValToSQL(cCodBem)
		cQuery	+= "   AND STJ.TJ_SERVICO = " + ValToSQL(cServico)
		cQuery	+= "   AND STJ.TJ_SEQRELA = " + ValToSQL(cSeqRela)
		cQuery  += "   AND STJ.D_E_L_E_T_ <> '*'"
		cQuery	+= "  UNION ALL " //RECURSIVIDADE
		cQuery	+= "  SELECT "
		cQuery	+= "  RECUR_STJ.TJ_FILIAL AS FILIAL, "
		cQuery	+= "  RECUR_STJ.TJ_CODBEM AS CODBEM, "
		cQuery	+= "  RECUR_STJ.TJ_SERVICO AS SERVICO, "
		cQuery	+= "  RECUR_STJ.TJ_SEQRELA AS SEQUENCIA, "
		cQuery	+= "  RECUR_STJ.TJ_SUBSTIT AS SUBSTIT "
		cQuery	+= "  FROM " + RetSqlName("STJ") + " RECUR_STJ "
		cQuery	+= "  INNER JOIN SEQUENCES SEQ ON ( "
		cQuery	+= "    RECUR_STJ.TJ_FILIAL = SEQ.TJ_FILIAL "
		cQuery	+= "    AND RECUR_STJ.TJ_CODBEM = SEQ.TJ_CODBEM "
		cQuery	+= "    AND RECUR_STJ.TJ_SERVICO = SEQ.TJ_SERVICO "
		//Tratamento para funções exclusivas do Oracle e SQL Server.
		If cDataBase == "ORACLE"
			cQuery += " AND instr(SEQ.TJ_SUBSTIT,RTRIM(RECUR_STJ.TJ_SEQRELA)) > 0 )"
		ElseIf cDataBase == "POSTGRES"
			cQuery += "  AND POSITION(RTRIM(RECUR_STJ.TJ_SEQRELA) IN SEQ.TJ_SUBSTIT) > 0 ) "
		Else
			cQuery += "  AND CHARINDEX(RTRIM(RECUR_STJ.TJ_SEQRELA), SEQ.TJ_SUBSTIT) > 0 ) "
		Endif
		cQuery	+= "  	) "
		cQuery	+= " SELECT DISTINCT TJ_FILIAL, TJ_CODBEM, TJ_SERVICO, TJ_SEQRELA "
		cQuery	+= "  FROM SEQUENCES "
		cQuery	+= "  WHERE TJ_SEQRELA <> " + ValToSQL(cSeqRela)
		MPSysOpenQuery(cQuery, cAliasSub)//Changequery não suporta expressão WITH
	EndIf

	While (cAliasSub)->(!Eof())
		//Preenche o campo que apresentará o conteúdo substitutivo
		cSubs += IIf(lVerSTJ .Or. lOption,Alltrim((cAliasSub)->TF_SEQRELA),Alltrim((cAliasSub)->TJ_SEQRELA)) + ","
		aKill := StrTokArr( cSubs, "," )
		(cAliasSub)->(Dbskip())
	End

	(cAliasSub)->(dbCloseArea())

Return aKill

//--------------------------------------------------------------------------
/*/{Protheus.doc} MntGatSD3
Gatilho referente a O.S. para os campos de movimentação de estoque ( SD3 ).
@type function

@author Alexandre Santos
@since 16/12/2019

@param cField   , Caracter, Campo ao qual foi acionado o gatilho.
@return Caracter, Conteudo referente ao D4_TRT, caso este exista.
/*/
//--------------------------------------------------------------------------
Function MntGatSD3( cField, cSequence )

	Local aAreaSC2 := {}
	Local cOp      := ''
	Local cTable   := ''
	Local cSD3COD  := ''
	Local cSD3LOC  := ''
	Local cReturn  := Space( TamSX3( 'D3_TRT' )[1] )
	Local nTamOS   := 0
	Local aArea    := GetArea()

	If SuperGetMV( 'MV_NGMNTES', .F., 'N' ) == 'S'
			
		Do Case

			Case cField == 'D3_ORDEM'

				cOp := M->D3_ORDEM + 'OS001'

				If cSequence == '1'

					cReturn := cOp

				ElseIf cSequence == '2'

					cTable  := GetNextAlias()

					// Tratativa realzada para pegar corretamente os valores dos campos D3_COD e D3_LOCAL.
					If IsInCallStack( 'A241INCLUI' )

						// Na rotina MATA241 é utilizado um MsGetDados, portanto o valor em memória não existe.
						cSD3COD := GDFieldGet( 'D3_COD', , .F. )
						cSD3LOC := GDFieldGet( 'D3_LOCAL', , .F. )

					Else

						cSD3COD := M->D3_COD
						cSD3LOC := M->D3_LOCAL

					EndIf

					BeginSQL Alias cTable

						SELECT
							D4_TRT
						FROM
							%table:SD4%
						WHERE
							D4_OP     = %exp:cOp%     AND
							D4_COD    = %exp:cSD3COD% AND
							D4_LOCAL  = %exp:cSD3LOC% AND
							D4_FILIAL = %xFilial:SD4% AND
							%NotDel%

					EndSQL

					cReturn := IIf( (cTable)->( !EoF() ), (cTable)->D4_TRT, cReturn )

					(cTable)->( dbCloseArea() )

				EndIf

			Case cField == 'D3_OP'

				nTamOS   := Len( STJ->TJ_ORDEM )
				aAreaSC2 := SC2->( GetArea() )

				If SuperGetMV( 'MV_NGMNTNO', .F., '2' ) == '1'

					dbSelectArea( 'SC2' )
					dbSetOrder( 1 ) // C2_FILIAL + C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD
					If dbSeek( xFilial( 'SC2' ) + M->D3_OP ) .And. SC2->( C2_ITEM + C2_SEQUEN ) == 'OS001'

						cReturn := SubStr( M->D3_OP, 1, nTamOS )

					EndIf

				EndIf

				RestArea( aAreaSC2 )

		End Case

	EndIf

	RestArea( aArea )

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} fAvancaPC
Verifica se permite alterar/excluir pedido de compras de origem MNT.

@author Diego de Oliveira
@since  06/03/2020
@Param  nOpc, Numérico, Operação.
@Param  cOrigem, Caracter, Origem do Pedido de Compras.

@return lRet, boolean
/*/
//-------------------------------------------------------------------
Function fAvancaPC(nOpc,cOrigem)

	Local lRet := .T.

    If ( nOpc == 5 .And. Alltrim(cOrigem) $ "MNTA645*MNTA650")
    	//"O pedido de compras não pode ser excluído porque possui sua origem no módulo SIGAMNT."
		Aviso( "MNTAINTEG",STR0271, {"OK"},2 )
    	lRet := .F.
    Endif

Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} fCargaItem
Carrega todos os itens da solicitação de armazém

@author Maria Elisandra de Paula
@since 16/06/20
@param cNumSA, string, numero da solic. armazém
@param aLastItem, array, item que será adicionado na solic. armazém
@return array, todos os itens já existentes da solic. armazém mais novo item
/*/
//----------------------------------------------------------------------------
Static Function fCargaItem( cNumSA, aLastItem )

	Local aAuxiliar := {}
	Local cAliasQry := GetNextAlias()

	BeginSQL Alias cAliasQry

		SELECT
			SCP.CP_NUM,
			SCP.CP_ITEM,
			SCP.CP_PRODUTO,
			SCP.CP_UM,
			SCP.CP_QUANT,
			SCP.CP_LOCAL,
			SCP.CP_DATPRF,
			SCP.CP_OP,
			SCP.CP_CC,
			SCP.CP_DESCRI,
			SCP.CP_ITEMCTA,
			SCP.CP_OBS
		FROM %table:SCP% SCP
		WHERE 
			SCP.CP_FILIAL  = %xFilial:SCP% AND
			SCP.CP_NUM     = %exp:cNumSa%  AND
			SCP.CP_PREREQU <> 'S'          AND 
			SCP.%NotDel%
		ORDER BY
			SCP.CP_NUM, SCP.CP_ITEM

	EndSQL

	While !(cAliasQry)->( Eof() )

		aAdd( aAuxiliar,;
			{ {"CP_NUM"   , (cAliasQry)->CP_NUM,     NIL},;
			{"CP_ITEM"    , (cAliasQry)->CP_ITEM,    NIL},;
			{"CP_PRODUTO" , (cAliasQry)->CP_PRODUTO, NIL},;
			{"CP_UM"      , (cAliasQry)->CP_UM,      NIL},;
			{"CP_QUANT"   , (cAliasQry)->CP_QUANT,   NIL},;
			{"CP_LOCAL"   , (cAliasQry)->CP_LOCAL,   NIL},;
			{"CP_DATPRF"  , STOD((cAliasQry)->CP_DATPRF),  NIL},;
			{"CP_OP"      , (cAliasQry)->CP_OP,      NIL},;
			{"CP_CC"      , (cAliasQry)->CP_CC,      NIL},;
			{"CP_DESCRI"  , (cAliasQry)->CP_DESCRI,  NIL},;
			{"CP_ITEMCTA" , (cAliasQry)->CP_ITEMCTA, NIL},;
			{"CP_OBS"     , (cAliasQry)->CP_OBS,     NIL}} )

		(cAliasQry)->( DBSkip() )

	End

	(cAliasQry)->( DBCloseArea() )

	aAdd( aAuxiliar, aLastItem )

Return aAuxiliar

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTALTSC7
Verifica se permite alterar pedido de compras de origem MNT.

@author Tainã Alberto Cardoso
@since  24/06/2020
@Param  aCols, Array, Itens do pedido de compra
@Param  aHeader, Array, Aheader com os campos da SC7

@return lRet, boolean
/*/
//-------------------------------------------------------------------
Function MNTALTSC7(aCols,aHeader)

	Local lRet := .T.
	Local nX := 0
	Local nPosQuant := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "C7_QUANT" })
	Local nPosPrice := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "C7_PRECO" })

	For nX := 1 to Len(aCols)

		dbSelectArea("SC7")
		dbGoto(aCols[nX][Len(aHeader)])

		If Alltrim(SC7->C7_ORIGEM) $ "MNTA645*MNTA650"

			If atail(aCols[nX])

				HELP( ' ', 1, "MNTAINTEG",, STR0271,; //"O pedido de compras não pode ser excluído porque possui sua origem no módulo SIGAMNT."
					2, 0,,,,,, { STR0279 } ) //"Para deletar este pedido acessar a rotina de conciliação manual no módulo de mauntenção de ativos para deletar."
				lRet := .F.

			EndIf

			// Verifica se C7_QUANT/C7_PRECO foram alterados
			If lRet .And. ( nPosQuant > 0 .And. aCols[nX][nPosQuant] <> SC7->C7_QUANT ) .Or.;
				( nPosQuant > 0 .And. aCols[nX][nPosPrice] <> SC7->C7_PRECO )

				HELP( ' ', 1, 'MNTAINTEG', , STR0277 + RetTitle( 'C7_QUANT' ) + ' ' + STR0072 + ' ' + RetTitle( 'C7_PRECO' ) + STR0278,; // Os campos ## e ## não pode ser alterado.
					2, 0, , , , , , { STR0280 } ) //"Para alterar estas informações acessar a rotina de conciliação manual no módulo de mauntenção de ativos."
				lRet := .F.
			EndIf

		EndIf

	Next nX

Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} MNTINTSD3
Gera um insumo realizado vinculado a uma movimentação de estoque
cópia da função NGsd3240i para descontinuá-la

@author Maria Elisandra de Paula
@since 24/08/2020

@param [nLinha]  , numerico, posição no acols
ExecAuto da rotina MATA241.

@return
/*/
//--------------------------------------------------------------------------
Function MNTINTSD3( nLinha )

	Local cOrdem     := SD3->D3_ORDEM
	Local aTercProd  := {}
	Local aDatFim    := {}
	Local cTiporeg   := ''
	Local cAliasTar  := ''
	Local cTarefa    := '0'
	Local cDestino   := ''
	Local cHoraAtu   := Substr( Time(), 1, 5 )
	Local lTercProd  := .F.
	Local lFound     := .F.
	Local nLinSD3    := 0
	Local nLsd3      := 0
	Local nSeqStl    := 0
	
	Default nLinha   := 0

	dbSelectArea( 'STJ' )
	dbSetOrder( 1 )
	If !Empty( cOrdem ) .And. SubStr( SD3->D3_CF, 1, 2 ) == 'RE' .And.; 
		dbSeek( xFilial( 'STJ' ) + cOrdem ) .And. !FwIsInCallStack( 'MNTExecSD3' )
		
		// variáveis utilizadas na função ULTSEQ
		M->TL_ORDEM := STJ->TJ_ORDEM
		M->TL_PLANO := STJ->TJ_PLANO
		M->TJ_ORDEM := STJ->TJ_ORDEM
		M->TJ_PLANO := STJ->TJ_PLANO

		//Recebe os Produtos de Terceiros do parametro
		aTercProd := aClone( NGProdMNT("T") )
		lTercProd := ( aScan(aTercProd, {|x| AllTrim(x) == AllTrim(SD3->D3_COD) }) > 0)

		cTiporeg := If( lTercProd, 'T', 'P' )
		cDestino := If( cTiporeg == 'T','', 'A' )

		DbSelectArea("STL")
		DbSetorder(7)
		DbSeek(xFilial("STL")+SD3->D3_NUMSEQ)
		While !Eof() .and. STL->TL_FILIAL == xFilial("STL") .and. ;
					STL->TL_NUMSEQ == SD3->D3_NUMSEQ

			If Trim(STL->TL_CODIGO) == Trim(SD3->D3_COD) .and. ;
				Trim(STL->TL_ORDEM)  == cOrdem
				lFound := .T.
				Exit
			Endif
			DbSkip()
		End

		If cTiporeg = "T"
			aDatFim := NGDTHORFIM( SD3->D3_EMISSAO, cHoraAtu, SD3->D3_QUANT )
		Else
			aDatFim := { SD3->D3_EMISSAO, cHoraAtu }
		EndIf

		If !Empty( SD3->D3_NUMSA )

			cAliasTar := GetNextAlias()

			BeginSQL Alias cAliasTar

				SELECT TL_TAREFA, TL_DESTINO
				FROM %table:STL%
				WHERE TL_FILIAL = %xFilial:STL%
					AND TL_NUMSA = %exp:SD3->D3_NUMSA%
					AND TL_ITEMSA = %exp:SD3->D3_ITEMSA%
					AND %NotDel%
			EndSQL

			If (cAliasTar)->( !EoF() )
				cTarefa  := (cAliasTar)->TL_TAREFA
				cDestino := (cAliasTar)->TL_DESTINO
			EndIf

			(cAliasTar)->( dbCloseArea() )

		EndIf

		//--------------------------
		// busca sequencia do insumo
		//--------------------------
		nSeqStl := ULTSEQ()

		DbSelectArea("STL")
		Reclock("STL",.T.)
		STL->TL_FILIAL  := xFilial('STL')
		STL->TL_ORDEM   := SD3->D3_ORDEM
		STL->TL_PLANO   := STJ->TJ_PLANO
		STL->TL_CODIGO  := SD3->D3_COD
		STL->TL_TIPOREG := cTiporeg
		STL->TL_TAREFA  := cTarefa
		STL->TL_DESTINO := cDestino
		STL->TL_USACALE := 'N'
		STL->TL_GARANTI := 'N'
		STL->TL_SEQRELA := nSeqStl
		STL->TL_UNIDADE := If( cTiporeg = 'T','H', SD3->D3_UM )
		STL->TL_QUANTID := SD3->D3_QUANT
		STL->TL_NUMSEQ  := SD3->D3_NUMSEQ
		STL->TL_DTINICI := SD3->D3_EMISSAO
		STL->TL_HOINICI := cHoraAtu
		STL->TL_DTFIM   := aDatFim[1]
		STL->TL_HOFIM   := aDatFim[2]
		STL->TL_REPFIM  := 'S'
		STL->TL_CUSTO   := SD3->D3_CUSTO1
		STL->TL_TIPOHOR := SuperGetMV("MV_NGUNIDT",.F., "D")
		STL->TL_ORIGNFE := 'SD3'
		STL->TL_NOTFIS  := SD3->D3_DOC

		STL->( MsUnlock() )

		fCopiaSd3()

		DbSelectArea("STJ")
		Reclock("STJ",.F.)
		STJ->TJ_TIPORET := "S"
		MsUnlock("STJ")

		If STJ->TJ_TERMINO == 'S'

			NGFINAL( STJ->TJ_ORDEM, STJ->TJ_PLANO, STJ->TJ_DTPRINI, STJ->TJ_HOPRINI, STJ->TJ_DTPRFIM,;
				STJ->TJ_HOPRFIM )

		EndIf

		//-------------------------------------------------------
		// Gravação de garantia - tabela TPZ
		//-------------------------------------------------------
		If SD3->D3_GARANTI == "S" .And. Type("aMntGarant") == "A"
			nLinSD3 := If( nLinha == 0, 1, nLinha )
			nLsd3 := Ascan( aMntGarant,{|x| x[11] = nLinSD3 } )
			If nLsd3  > 0
				NGGRVGARAN( aMntGarant, nLsd3, STL->TL_SEQRELA )
			EndIf
		EndIf

	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fCopiaSd3
Grava os campos complementares do SD3 para STL

@author Inácio Luiz Kolling
@since 14/07/2005
@return nulo
/*/
//-------------------------------------------------------------------
Static Function fCopiaSd3()

	Local nVP      := 0
	Local cPRER    := 'TL'
	Local cALIVAL  := 'SD3'
	Local cALIREC  := 'STL'
	Local vVETCAMN := {"_FILIAL","_NUMSEQ","_ORDEM"}
	Local aESTRUT  := {}

	DbSelectArea(cALIREC)
	aESTRUT := DbStruct()

	RecLock(cALIREC,.F.)
	DbSelectArea(cALIVAL)
	For nVP := 1 To Fcount()
		ny := Fieldname(nVP)
		nc := cALIREC+"->"+cPRER+Alltrim(Substr(ny,3,Len(ny)))
		cCAMPP := Alltrim(Substr(ny,3,Len(ny)))
		If Ascan(vVETCAMN, {|x| x == Alltrim(Substr(ny,3,Len(ny)))}) = 0
			If Ascan(aESTRUT, {|x| Alltrim(Substr(x[1],3,Len(x[1]))) == cCAMPP}) > 0
				nx   := cALIVAL+"->"+Fieldname(nVP)
				&nc. := &nx.
			Endif
		Endif
	Next

	MsUnlock(cALIREC)

Return .t.

//--------------------------------------------------------------------------
/*/{Protheus.doc} MNTINTSASC
Validações para não permitir excluir/alterar solicitações armazém/compras
vinculadas a uma ordem de serviço

@author Tainã Alberto Cardoso
@author Maria Elisandra de Paula
@since 04/05/2020

@param cNumGen   , string  , Número da S.C./S.A./O.P.
@param cOrigem   , string  , Função que acionou ( MATA105, MATA110, MATA380 ou MATA381 )
@param nOperation, numerico, operação (4-altera, 5-exclui)
@param [aHeader] , array   , header dos itens
@param [aCols]   , array   , itens da solicitação
@param [nRecNo]  , numeric , RECNO do registro SD4 em validação.

@return boolean, se validação ocorreu com sucesso
/*/
//--------------------------------------------------------------------------
Function MNTINTSASC( cNumGen, cOrigem, nOperation, aHeader, aCols, nRecNo )

	Local aArea     := GetArea()
	Local lRet      := .T.
	
	Default aHeader := {}
	Default aCols   := {}
	Default nRecNo  := 0

	If cOrigem == "MATA105" /*armazém*/ .And. !IsInCallStack("NGGERASA") .And. !IsInCallStack("NGDELETOS")
		//Adicionadas chamadas que fazem a deleção a partir do MNT e não do SIGAEST
		If nOperation == 5 // excluir armazém
			lRet := fValExcScp( cNumGen )
		ElseIf nOperation == 4 // alterar armazém
			lRet := fValAltScp( cNumGen, aHeader, aCols )
		EndIf

	ElseIf cOrigem == 'MATA110' .And. !FwIsInCallStack( 'MntExecSC1' ) // Solicitação de Compras

		If nOperation == 5 // excluir compras
			lRet := fValExcSc1( cNumGen )
		ElseIf nOperation == 4 // alterar compras
			lRet := fValAltSc1( cNumGen, aHeader, aCols )
		EndIf
	
	ElseIf cOrigem == 'MATA380' // Empenho

		// Validação de um único registro de empenho ( MATA380 ).
		lRet := fVldUpdSD4( cNumGen, nOperation, nRecNo )

	ElseIf cOrigem == 'MATA381' // Empenho Mod. 2

		// Validação de múltiplos registros de empenho ( MATA381 ).
		lRet := fVldUpdSD4( cNumGen, nOperation, nRecNo, aCols, aHeader )

	ElseIf cOrigem == 'MATA240' // Mov. de Estoque

		// Validação de Mov. de Estoque ( MATA240 ).
		lRet := fVldSD3( cNumGen )

	EndIf

	RestArea( aArea )

Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} fVldSD3
Válida inclusão/alteração de movimentação de estoque realizadas no SIGAMNT.
@type function

@author Alexandre Santos
@since 27/04/2022

@param cOrdPrd , string , Ordem de Produção.

@return boolean, Indica se validação ocorreu com sucesso.
/*/
//--------------------------------------------------------------------------
Static Function fVldSD3( cOrdPrd )

	Local aAreaSTJ := STJ->( GetArea() )
	Local aAreaSC2 := SC2->( GetArea() )
	Local lRet     := .T.

	If lIntegES

		dbSelectArea( 'SC2' )
		dbSetOrder( 1 ) // C2_FILIAL + C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD
		If dbSeek( FWxFilial( 'SC2' ) + cOrdPrd ) .And.;
			Trim( SC2->C2_ITEM + SC2->C2_SEQUEN ) == 'OS001'

			/*-------------------------------------------------------------------------------+
			| Caso a O.P. esteja relacionado a uma O.S. não seguir com o processo no SIGAEST |
			+-------------------------------------------------------------------------------*/
			dbSelectArea( 'STJ' )
			dbSetOrder( 1 ) // TJ_FILIAL + TJ_ORDEM + TJ_PLANO + TJ_TIPOOS + TJ_CODBEM + TJ_SERVICO + TJ_SEQRELA
			lRet := !dbSeek( FWxFilial( 'STJ' ) + SubStr( cOrdPrd, 1, TamSX3( 'TJ_ORDEM' )[1] ) )

		EndIf

	EndIf

	RestArea( aAreaSC2 )
	RestArea( aAreaSTJ )

Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} fVldUpdSD4
Válida alterações no empenho realizadas foram do SIGAMNT.
@type function

@author Alexandre Santos
@since 05/05/2020

@param cOP     , string , Ordem de Produção.
@param nOpt    , numeric, Operação que acionou a validação.
@param nRecNo  , string , RECNO do registro SD4 em validação.
@param aCols   , array  , aCols com os espenhos para a O.P.
@param aHeader , array  , aHeader do processo de empenho.

@return boolean, Indica se validação ocorreu com sucesso.
/*/
//--------------------------------------------------------------------------
Static Function fVldUpdSD4( cOP, nOpt, nRecNo, aCols, aHeader )

	Local aAreaD4 := SD4->( GetArea() )
	Local cBrchD4 := xFilial( 'SD4' )
	Local lRet    := .T.
	Local nSizeOS := TamSX3( 'TJ_ORDEM' )[1]
	Local nIndex  := 0
	Local nPosWH  := 0
	Local nPosCod := 0
	Local nPosQtd := 0
	Local nPosOri := 0
	
	If !FwIsInCallStack( 'MntExecSD4' ) .And. Trim( SubStr( cOP, nSizeOS + 1, Len( cOP ) ) ) == 'OS001' 
		
		// Validação de um único registro de empenho ( MATA380 ).
		If !Empty( nRecNo )

			dbSelectArea( 'SD4' )
			dbGoTo( nRecNo )

			// Deve possuir o sufixo OS001 e ser acionado pela operação deleção ou alteração modificando determinados campos.
			If nOpt == 5 .Or. ( nOpt == 4 .And.	SD4->D4_QUANT != M->D4_QUANT .Or. SD4->D4_QTDEORI != M->D4_QTDEORI .Or.;
				SD4->D4_LOCAL != M->D4_LOCAL )
				
				Help( '', 1, 'NGATENCAO', , STR0303 + SubStr( SD4->D4_OP, 1, nSizeOS ) + STR0304,; // Este empenho possui vínculo com a ordem de serviço XXXXX, assim não é permitido a alteração ou exclusão de produtos contidos neste empenho.
					2, 0, , , , , , { STR0302 } ) // Acesse a ordem de serviço que originou este empenho e realize o processo desejado.

				lRet := .F.
					
			EndIf

		// Validação de múltiplos registros de empenho ( MATA381 ).
		Else

			nPosWH  := GDFieldPos( 'D4_LOCAL'  , aHeader )
			nPosCod := GDFieldPos( 'D4_COD'    , aHeader )
			nPosQtd := GDFieldPos( 'D4_QUANT'  , aHeader )
			nPosOri := GDFieldPos( 'D4_QTDEORI', aHeader )

			For nIndex := 1 To Len( aCols )

				dbSelectarea( 'SD4' )
				dbSetOrder( 2 ) // D4_FILIAL + D4_OP + D4_COD + D4_LOCAL
				If dbSeek( cBrchD4 + cOP + aCols[nIndex,nPosCod] + aCols[nIndex,nPosWH] )

					If aTail( aCols[nIndex] ) .Or. SD4->D4_QUANT != aCols[nIndex,nPosQtd] .Or.;
						SD4->D4_QTDEORI != aCols[nIndex,nPosOri] .Or. SD4->D4_LOCAL != aCols[nIndex,nPosWH]

						Help( '', 1, 'NGATENCAO', , STR0303 + SubStr( SD4->D4_OP, 1, nSizeOS ) + STR0304,; // Este empenho possui vínculo com a ordem de serviço XXXXX, assim não é permitido a alteração ou exclusão de produtos contidos neste empenho.
							2, 0, , , , , , { STR0302 } ) // Acesse a ordem de serviço que originou este empenho e realize o processo desejado.

						lRet := .F.
						
						Exit

					EndIf

				Else

					Help( '', 1, 'NGATENCAO', , STR0303 + SubStr( cOP, 1, nSizeOS ) + STR0305,; // Este empenho possui vínculo com a ordem de serviço XXXXX, assim não é permitido a inclusão de novos produtos diretamente a este empenho.
						2, 0, , , , , , { STR0302 } ) // Acesse a ordem de serviço que originou este empenho e realize a inclusão dos produtos desejados.	
					
					lRet := .F.
						
					Exit

				EndIf

			Next nIndex

		EndIf

	EndIf

	RestArea( aAreaD4 )

Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} fValExcScp
Valida exclusão de uma solicitação de armazém

@author Maria Elisandra de Paula
@since 18/08/2020
@param cNumScp, string, numero da solicitação
@return boolean, se validação ocorreu com sucesso
/*/
//--------------------------------------------------------------------------
Static Function fValExcScp( cNumScp )

	Local aItensStl := {}
	Local cHelp     := ""

	If !Empty( cNumScp )

		aItensStl := fItensStl( cNumScp, 2 )

		If Len( aItensStl ) > 0
			cHelp := STR0281 + " " + aItensStl[1, 1] + " " + STR0285  + " " + cNumScp + " " + ; // "O item" #"da solicitação de armazém"#
						STR0283 + " " + aItensStl[1, 2] + " " + STR0284 // "possui vínculo com a ordem de serviço" # "e não pode ser alterado/excluído."
		EndIf

	EndIf

	If !Empty( cHelp )
		// 'Acessar a ordem de serviço que gerou essa solicitação de armazém e realizar o processo desejado.'
		HELP( ' ', 1, "NGATENCAO",, cHelp,2, 0,,,,,, { STR0276 } )
	EndIf

Return Empty( cHelp )

//--------------------------------------------------------------------------
/*/{Protheus.doc} fValExcSc1
Valida exclusão de uma solicitação de compras

@author Maria Elisandra de Paula
@since 18/08/2020
@param cNumSc1, string, numero da solicitação
@return boolean, se validação ocorreu com sucesso
/*/
//--------------------------------------------------------------------------
Static Function fValExcSc1( cNumSc1 )

	Local aItensStl := {}
	Local cHelp     := ""

	If !Empty( cNumSc1 )

		aItensStl := fItensStl( cNumSc1, 1 )

		If Len( aItensStl ) > 0
			cHelp := STR0281 + " " + aItensStl[1, 1] + " " + STR0282  + " " + cNumSc1 + " " + ; // "O item" #"da solicitação de compra"#
						STR0283 + " " + aItensStl[1, 2] + " " + STR0284 // "possui vínculo com a ordem de serviço" # "e não pode ser excluído."
		EndIf

	EndIf

	If !Empty( cHelp )
		// 'Acessar a ordem de serviço que gerou essa solicitação de compra e realizar o processo desejado.'
		HELP( ' ', 1, "NGATENCAO",, cHelp,2, 0,,,,,, { STR0274 } )
	EndIf

Return Empty( cHelp )

//-------------------------------------------------------------------
/*/{Protheus.doc} fValAltSc1
Valida alteraçoes nas solicitações de compra vinculadas a um insumo

@author Maria Elisandra de Paula
@since 18/08/20
@param aHeader, array, campos dos itens
@param aCols, array, itens da solicitação
@param cNumSC1, string, numero da solicitação
@return boolean, se validação ocorreu com sucesso
/*/
//-------------------------------------------------------------------
Static Function fValAltSc1( cNumSC1, aHeader, aCols )

	Local lRet      := .T.
	Local lExecAuto := FwIsInCallStack( 'MNTA420' )
	Local cHelp     := ""
	Local nIndex    := 0
	Local nAscan    := 0
	Local nPosItem  := 0
	Local nPosQuant := 0
	Local nPosProd  := 0
	Local nPosLocal := 0
	Local aItensStl := {}

	If !lExecAuto

		nPosItem  := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "C1_ITEM" })
		nPosQuant := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "C1_QUANT" })
		nPosProd  := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "C1_PRODUTO" })
		nPosLocal := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "C1_LOCAL" })
		aItensStl := fItensStl( cNumSC1, 1 )
	
		If Len( aItensStl ) == 0
			Return .T.
		EndIf

		For nIndex := 1 To Len( aCols )

			dbSelectarea( "SC1" )
			dbSetOrder(1)
			If dbSeek( xFilial("SC1") + cNumSC1 + aCols[ nIndex, nPosItem ] )

				// busca vinculo da SC1 com STL
				If ( nAscan := aScan( aItensStl, {|x|  x[1] == SC1->C1_ITEM } ) ) > 0

					If aTail( aCols[ nIndex ] ) .Or. ; // deletado
						SC1->C1_QUANT != aCols[ nIndex, nPosQuant ] .Or. ;// Alterou quantidade
						SC1->C1_PRODUTO != aCols[ nIndex, nPosProd ] .Or. ;// Alterou código do produto
						SC1->C1_LOCAL != aCols[ nIndex, nPosLocal ] // Alterou almoxarifado

						// "O item"# "possui vínculo com a ordem de serviço" #"e não pode ser alterado/excluído."
						cHelp := STR0281 + " " + SC1->C1_ITEM + " " + STR0283  + " " + aItensStl[nAscan, 2] + " " + STR0284
						lRet := .F.
						Exit
					EndIf

				EndIf

			EndIf

		Next

		If !lRet .And. !Empty( cHelp )
			// 'Acessar a ordem de serviço que gerou essa solicitação de compra e realizar o processo desejado.'
			HELP( ' ', 1, "NGATENCAO",, cHelp,2, 0,,,,,, { STR0274 } )
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fValAltScp
Valida alteraçoes nas solicitações de compra vinculadas a um insumo

@author Maria Elisandra de Paula
@since 18/08/20
@param aHeader, array, campos dos itens
@param aCols, array, itens da solicitação
@param cNumSCp, string, numero da solicitação
@return boolean, se validação ocorreu com sucesso
/*/
//-------------------------------------------------------------------
Static Function fValAltScp( cNumSCP, aHeader, aCols )

	Local lRet      := .T.
	Local cHelp     := ""
	Local nIndex    := 0
	Local nAscan    := 0
	Local nPosItem  := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "CP_ITEM" })
	Local nPosQuant := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "CP_QUANT" })
	Local nPosProd  := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "CP_PRODUTO" })
	Local nPosLocal := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "CP_LOCAL" })
	Local aItensStl := fItensStl( cNumScp, 2 )

	If Len( aItensStl ) == 0
		Return .T.
	EndIf

	For nIndex := 1 To Len( aCols )

		dbSelectarea( "SCP" )
		dbSetOrder(1)
		If dbSeek( xFilial("SCP") + cNumScp + aCols[ nIndex, nPosItem ] )

			// busca vinculo da SCP com STL
			If ( nAscan := aScan( aItensStl, {|x|  x[1] == SCP->CP_ITEM } ) ) > 0

				If aTail( aCols[ nIndex ] ) .Or. ; // deletado
					SCP->CP_QUANT != aCols[ nIndex, nPosQuant ] .Or. ;// Alterou quantidade
					SCP->CP_PRODUTO != aCols[ nIndex, nPosProd ] .Or. ;// Alterou código do produto
					SCP->CP_LOCAL != aCols[ nIndex, nPosLocal ] // Alterou almoxarifado

					// "O item"# "possui vínculo com a ordem de serviço" #"e não pode ser alterado/excluído."
					cHelp := STR0281 + " " + SCP->CP_ITEM + " " + STR0283  + " " + aItensStl[nAscan, 2] + " " + STR0284
					lRet := .F.
					Exit
				EndIf

			EndIf

		EndIf

	Next

	If !lRet .And. !Empty( cHelp )
		// 'Acessar a ordem de serviço que gerou essa solicitação de armazém e realizar o processo desejado.'
		HELP( ' ', 1, "NGATENCAO",, cHelp,2, 0,,,,,, { STR0276 } )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fItensStl
Busca insumos stl vinculados a uma solicitação de compras/armazém

@author Maria Elisandra de Paula
@since 18/08/20
@param cNumSCGen, string, numero da solic. de compras/armazém
@param nType, numerico, tipo = 1-compra; 2-armazem
@return array, detalhes dos itens vinculados
/*/
//-------------------------------------------------------------------
Static Function fItensStl( cNumSCGen, nType )

	Local aReturn   := {}
	Local cAliasQry := GetNextAlias()

	If nType == 1 // Compras - SC1

		BeginSQL Alias cAliasQry

			SELECT STL.TL_ORDEM,
				STL.TL_ITEMSC ITEMSOLIC
			FROM %table:STL% STL
			INNER JOIN %table:SC1% SC1
				ON SC1.C1_FILIAL = %xFilial:SC1%
				AND SC1.C1_NUM = STL.TL_NUMSC
				AND SC1.C1_OP = STL.TL_ORDEM || 'OS001'
				AND SC1.%NotDel%
			WHERE STL.TL_FILIAL = %xFilial:STL%
				AND STL.%NotDel%
				AND STL.TL_NUMSC = %Exp:cNumSCGen%
			ORDER BY STL.TL_ITEMSC

		EndSQL

	Else // Armazém - SCP

		BeginSQL Alias cAliasQry

			SELECT STL.TL_ORDEM,
				STL.TL_ITEMSA ITEMSOLIC
			FROM %table:STL% STL
			INNER JOIN %table:SCP% SCP
				ON SCP.CP_FILIAL = %xFilial:SCP%
				AND SCP.CP_NUM = STL.TL_NUMSA
				AND SCP.CP_OP = STL.TL_ORDEM || 'OS001'
				AND SCP.%NotDel%
			WHERE STL.TL_FILIAL = %xFilial:STL%
				AND STL.%NotDel%
				AND STL.TL_NUMSA = %Exp:cNumSCGen%
			ORDER BY STL.TL_ITEMSA

		EndSQL

	EndIf

	While !(cAliasQry)->( Eof() )

		aAdd( aReturn,  { (cAliasQry)->ITEMSOLIC, (cAliasQry)->TL_ORDEM } )

		(cAliasQry)->( dbSkip() )

	EndDo

	(cAliasQry)->( dbCloseArea() )

Return aReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGCONVMD
Converte valor conforme conforme moeda repassada.

@type static function

@author Hugo R. Pereira
@since 28/05/2012

@param nCusto, Numérico, Valor/Custo a ser convertido.
@param nMoedaIni, Numérico, Moeda de origem.
@param cMoedaDst, Caractere, Moeda de destino.

@return numérico, Valor conforme a moeda repassada
/*/
//---------------------------------------------------------------------
Static Function NGCONVMD(nCusto, nMoedaIni, cMoedaDst)

	Local nValor := xMoeda( nCusto, nMoedaIni, Val(cMoedaDst), dDatabase, 2 )

	cMoedaAtu    := cMoedaDst

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} MntDelReq
Realiza exclusão da S.A. ou S.C. e seus relacionamentos ( SCR ).
@type function

@author Alexandre Santos
@since 22/12/2020

@param cNum     , string , Número da S.A. ou S.C.
@param cItem    , string , Item da S.A. ou S.C.
@param cDoc     , string , Indica o tipo de documento SA ou SC
@param [lDelSTL], boolean, Indica se ao excluir a requisição deve limpar
os campos relacionados ao insumo.

@return
/*/
//-------------------------------------------------------------------
Function MntDelReq( cNum, cItem, cDoc, lDelSTL )

	Local dDtDoc    := cToD( '' )
	Local cAlsSCR   := ''
	Local aDoc      := {}
	Local aAreaTL   := STL->( GetArea() )
	Local aInfoDel  := IIf( cDoc == 'SA', { 'SCP', 'SCP->CP_EMISSAO', ( SuperGetMV( 'MV_NGMNTAS', .F., '2' ) != '2' ) },;
		{ 'SC1', 'SC1->C1_EMISSAO', ( SuperGetMV( 'MV_NGMNTSC', .F., 1 ) != 1 ) } )

	Default lDelSTL := .F.

	dbSelectArea( aInfoDel[1] )
	dbSetOrder( 1 )
	If msSeek( xFilial( aInfoDel[1] ) + cNum + cItem )

		dDtDoc := &( aInfoDel[2] )

		// Exclui S.A.
		RecLock( aInfoDel[1], .F. )
			dBDelete()
		MsUnLock()

		If lDelSTL

			/*---------------------------------------------------+
			| Limpa os campos da requisição na tabela de insumos. |
			+---------------------------------------------------*/
			fCleanSTL( cDoc == 'SA', cNum, cItem)

		EndIf

		// Não aglutina requisição ou Aglutina, porém não existe mais itens nesta requisição.
		If !aInfoDel[3] .Or. ( aInfoDel[3] .And. !NGIfDbSeek( aInfoDel[1], cNum, 1 ) )

			// Inicio do processo de exclusão do bloqueio por controle de alçada.
			cAlsSCR := GetNextAlias()

			BeginSQL Alias cAlsSCR

				SELECT
					SCR.CR_NUM  ,
					SCR.CR_TOTAL,
					SCR.CR_GRUPO
				FROM
					%table:SCR% SCR
				WHERE
					SCR.CR_FILIAL = %xFilial:SCR% AND
					SCR.CR_NUM    = %exp:cNum%    AND
					SCR.CR_TIPO   = %exp:cDoc%    AND
					SCR.%NotDel%
				GROUP BY
					SCR.CR_NUM  ,
					SCR.CR_TOTAL,
					SCR.CR_GRUPO

			EndSQL

			Do While (cAlsSCR)->( !EoF() )

				aDoc := 	{ 	cNum	           ,; // Num. Documento
								cDoc               ,; // Tipo Doc.
								(cAlsSCR)->CR_TOTAL,; // Valor aprovac.
												,; // Aprovador
												,; // Cod. Usuario
								(cAlsSCR)->CR_GRUPO,; // Grupo Aprovac.
												,; // Aprov. Superior
												,; // Moeda Docto
												,; // Taxa da moeda
								dDtDoc			    ; // Data Emissao
							}

				// Função de SIGAEST que realiza o processo de estorno de documento do controle de alçada.
				MaAlcDoc( aDoc, , 3 )

				(cAlsSCR)->( dbSkip() )

			EndDo

			(cAlsSCR)->( dbCloseArea() )

		EndIf

	EndIf

	RestArea( aAreaTL )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCleanSTL
Realiza exclusão da S.A. ou S.C. e seus relacionamentos ( SCR ).
@type function

@author Alexandre Santos
@since 27/07/2021

@param lSA , boolean, Indica se o processo é referente s SA ou SC
@param cNum, string , Número da S.A. ou S.C.
@param cItm, string , Item da S.A. ou S.C.

@return
/*/
//-------------------------------------------------------------------
Static Function fCleanSTL( lSA, cNum, cItm )

	Local aArea   := STL->( GetArea() )
	Local aInfDel := {}
	Local cWhere  := '%'
	Local cAlsSTL := GetNextAlias()

	If lSA // Solicitação de Armazém

		cWhere  += 'STL.TL_NUMSA  = ' + ValToSQL( cNum ) + ' AND '
		cWhere  += 'STL.TL_ITEMSA = ' + ValToSQL( cItm ) + '%'

		aInfDel := { 'STL->TL_NUMSA', TAMSX3( 'TL_NUMSA' )[1], 'STL->TL_ITEMSA' , TAMSX3( 'TL_ITEMSA' )[1] }
	
	Else // Solicitação de Compras
		
		cWhere  += 'STL.TL_NUMSC  = ' + ValToSQL( cNum ) + ' AND '
		cWhere  += 'STL.TL_ITEMSC = ' + ValToSQL( cItm ) + '%'

		aInfDel := { 'STL->TL_NUMSC', TAMSX3( 'TL_NUMSC' )[1], 'STL->TL_ITEMSC' , TAMSX3( 'TL_ITEMSC' )[1] }

	EndIf

	BeginSQL Alias cAlsSTL

		SELECT * FROM
			%table:STL% STL
		WHERE
			STL.TL_FILIAL = %xFilial:STL% AND
			STL.%NotDel% AND %exp:cWhere%

	EndSQL

	While (cAlsSTL)->( !EoF() )

		dbSelectArea( 'STL' )
		dbGoTo( (cAlsSTL)->R_E_C_N_O_ )
		
		/*-----------------------------------------------------
		| Limpa os campos da requisição na tabela de insumos. |
		+----------------------------------------------------*/
		RecLock( 'STL', .F. )
			&( aInfDel[1] ) := Space( aInfDel[2] )
			&( aInfDel[3] ) := Space( aInfDel[4] )
		MsUnLock()

		(cAlsSTL)->( dbSkip() )

	End

	(cAlsSTL)->( dbCloseArea() )

	RestArea( aArea )
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTSTLWHEN
Função provisória para os campos When da STL, enviado apenas para 
o cliente adicionar via configurador.
@type function

@author Tainã Alberto Cardoso
@since 25/05/2021

@param cFildSTL, string, Campo a ser validado

@return boolean, se habilita ou desabilita a edição do campo 
/*/
//-------------------------------------------------------------------
Function MNTSTLWHEN( cFildSTL )

	Local lRet := .F.
	Local nTpReg := 0 

	Default cFildSTL := ''
	
	If cFildSTL == 'TL_QUANREC' .And. Type("aHeader") == "A" .And. Type("aCols") == "A"
		
		nTpReg := Ascan(aHEADER,{|x| TRIM(UPPER(x[2])) == "TL_TIPOREG"})
		
		If nTpReg > 0 .And. Len(aCols) > 0

			lRet := aCols[n][nTpReg] $ "E/F"

		Else

			lRet := M->TL_TIPOREG $ "E/F"

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTSD3EST
Exclui o insumo realizado vinculado a uma movimentação de estoque.
@type function

@author Maria Elisandra de Paula
@since 03/06/2021

@return
/*/
//---------------------------------------------------------------------
Function MNTSD3EST()

	Local aArea      := GetArea()
	Local aAreaSd3   := SD3->( GetArea() )
	Local cChaTPZ    := ''
	Local cOrdem     := ''
	Local nOrdId     := 0

	Private lRegVir  := .F.
	Private nDifVir  := 0
	Private nACUMFIF := 0

	// Chamadas pelo ExecAuto não devem realizar este processo.
	If !FwIsInCallStack( 'MNTExecSD3' )
	
		If !Empty( SD3->D3_ORDEM )

			cOrdem := SD3->D3_ORDEM

			DbSelectArea('STJ')
			DbSetorder(1)
			IF DbSeek( xFilial('STJ') + cOrdem ) .And. STJ->TJ_SITUACA == 'L' .And. STJ->TJ_TERMINO == 'N'

				DbSelectArea('SF5')
				DbSetorder(1)
				If DbSeek( xFilial('SF5') + M->D3_TM ) .And. SF5->F5_TIPO == 'R' // Requisição

					DbSelectArea('STL')
					DbSetorder(7)
					If DbSeek( xFilial('STL') + SD3->D3_NUMSEQ )

						DbSelectArea('STN')
						DbSetorder(1)
						If DbSeek( xFilial('STN') + STL->TL_ORDEM + STL->TL_PLANO + STL->TL_TAREFA + STL->TL_SEQRELA )

							While !Eof() .And. STN->TN_FILIAL == xFilial('STN') .And. STN->TN_ORDEM == STL->TL_ORDEM ;
								.And. STN->TN_TAREFA == STL->TL_TAREFA .And. STN->TN_SEQRELA == STL->TL_SEQRELA

								RecLock('STN',.F.)
								dbDelete()
								STN->( MsUnlock('STN') )

								DbSkip()
							End

						EndIf
						
						DbSelectArea('SD3')
						
						If NGCADICBASE( 'D3_GARANTI', 'A', 'SD3', .F. ) .And. SD3->D3_GARANTI == 'S'

							DbSelectArea('TPZ')
							DbSetOrder(2)
							cChaTPZ := STJ->TJ_ORDEM + STJ->TJ_PLANO + STL->TL_SEQRELA
					
							If DbSeek( xFilial( 'TPZ' ) + cChaTPZ )
								While !Eof() .And. TPZ->TPZ_FILIAL == xFilial('TPZ') .And.;
									TPZ->TPZ_ORDEM + TPZ->TPZ_PLANO + TPZ->TPZ_SEQREL == cChaTPZ

									RecLock('TPZ', .F. )
									dbDelete()
									TPZ->( MsUnlock('TPZ') )

									DbSkip()
								End

							EndIf

						EndIf

						DbSelectArea('STL')
						RecLock( 'STL', .F. )
						dbDelete()
						STL->( MsUnlock() )

					EndIf

					//-----------------------------------------------------------
					// Atualiza campo que indica se ordem possui insumo realizado
					//-----------------------------------------------------------
					AtuTipoRet( cOrdem )

				EndIf

			EndIf

		EndIf

		If nModulo != 19 .And. nModulo != 95

			nOrdId := NGRETORDEM( 'TQN', 'TQN_FILIAL+TQN_NUMSEQ' )

			If nOrdId > 0

				DbSelectArea('TQN')
				DbSetorder( nOrdId )
				If DbSeek(xFilial( 'TQN') + SD3->D3_NUMSEQ )

					// PROCESSO COPIADO DO MNTA655
					DbSelectArea("ST9")
					DbSetOrder(16)
					If DbSeek(TQN->TQN_FROTA)
						cFilBem	:= ST9->T9_FILIAL
					EndIf

					aRetTPN := NgFilTPN(TQN->TQN_FROTA,TQN->TQN_DTABAS,TQN->TQN_HRABAS)
					cFilTPN := aRetTPN[1]

					If cFilTPN = " "
						cFilTPN := TQN->TQN_FILIAL
					EndIf

					lSegCont := NGCADICBASE("TQN_POSCO2","A","TQN",.F.)

					//Referentes ao primeiro contador
					aARALTC := {'STP','stp->tp_filial','stp->tp_codbem',;
								'stp->tp_dtleitu','stp->tp_hora','stp->tp_poscont',;
								'stp->tp_acumcon','stp->tp_vardia','stp->tp_viracon'}
					aARABEM := {'ST9','st9->t9_poscont','st9->t9_contacu',;
								'st9->t9_dtultac','st9->t9_vardia'}

					DbSelectArea(aARALTC[1])
					Dbsetorder(5)
					If Dbseek(xFilial(aARALTC[1],cFilTPN)+TQN->TQN_FROTA+Dtos(TQN->TQN_DTABAS)+TQN->TQN_HRABAS)
						nRECNSTP := Recno()
						nRECASTP := 0
						lULTIMOP := .T.
						nACUMFIP := 0
						nCONTAFP := 0
						nVARDIFP := 0
						dDTACUFP := Ctod('  /  /  ')

						DbSkip(-1)

						If !Eof() .And. !Bof() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilTPN) .And.;
							&(aARALTC[3]) = TQN->TQN_FROTA
							nACUMFIP := &(aARALTC[7])
							dDTACUFP := &(aARALTC[4])
							nCONTAFP := &(aARALTC[6])
							nVARDIFP := &(aARALTC[8])
							nRECASTP := Recno()
						EndIf

						Dbgoto(nRECNSTP)

						nACUMDEL := stp->tp_acumcon

						DbSelectArea(aARALTC[1])
						RecLock(aARALTC[1],.F.)
						Dbdelete()
						MsUnlock(aARALTC[1])

						MNTA875ADEL(TQN->TQN_FROTA,TQN->TQN_DTABAS,TQN->TQN_HRABAS,2,cFilTPN,cFilTPN)

						DbSelectArea(aARALTC[1])
						If nRECASTP > 0
							Dbgoto(nRECASTP)
							DbSkip()
							If !Eof() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilTPN) .And.;
								&(aARALTC[3]) = TQN->TQN_FROTA
							Else
								NGATUCONT(STP->TP_CODBEM,STP->TP_DTLEITU,STP->TP_POSCONT,;
											STP->TP_ACUMCON,STP->TP_VARDIA,1,.f.,.f.)
							EndIf
						EndIf
					EndIf

					//Referentes ao segundo contador
					If lSegCont

						dbSelectArea("TPE")
						dbSetOrder(1)
						If DbSeek(If(NGSX2MODO("TPE")="E",cFilBem,xFilial("TPE"))+TQN->TQN_FROTA)
							aARALTC := {'TPP','tpp->tpp_filial','tpp->tpp_codbem',;
										'tpp->tpp_dtleit','tpp->tpp_hora','tpp->tpp_poscon',;
										'tpp->tpp_acumco','tpp->tpp_vardia','tpp->tpp_viraco'}
							aARABEM := {'TPE','tpe->tpe_poscon','tpe->tpe_contac',;
										'tpe->tpe_dtulta','tpe->tpe_vardia'}

							DbSelectArea(aARALTC[1])
							Dbsetorder(5)
							If Dbseek(xFilial(aARALTC[1],cFilTPN)+TQN->TQN_FROTA+Dtos(TQN->TQN_DTABAS)+TQN->TQN_HRABAS)
								nRECNSTP := Recno()
								nRECATPP := 0
								lULTIMOP := .T.
								nACUMFIP := 0
								nCONTAFP := 0
								nVARDIFP := 0
								dDTACUFP := Ctod('  /  /  ')

								DbSkip(-1)

								If !Eof() .And. !Bof() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilTPN) .And.;
									&(aARALTC[3]) = TQN->TQN_FROTA
									nACUMFIP := &(aARALTC[7])
									dDTACUFP := &(aARALTC[4])
									nCONTAFP := &(aARALTC[6])
									nVARDIFP := &(aARALTC[8])
								EndIf

								Dbgoto(nRECNSTP)

								nACUMDEL := TPP->TPP_ACUMCO

								DbSelectArea(aARALTC[1])
								RecLock(aARALTC[1],.F.)
								Dbdelete()
								MsUnlock(aARALTC[1])

								MNTA875ADEL(TQN->TQN_FROTA,TQN->TQN_DTABAS,TQN->TQN_HRABAS,2,cFilTPN,cFilTPN)

								DbSelectArea(aARALTC[1])
								If nRECATPP > 0

									Dbgoto(nRECATPP)
									DbSkip()
									If !Eof() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilTPN) .And.;
										&(aARALTC[3]) = cCodfrot
									Else
										NGATUCONT(TPP->TPP_CODBEM,TPP->TPP_DTLEIT,TPP->TPP_POSCON,;
												TPP->TPP_ACUMCO,TPP->TPP_VARDIA,"2",.f.,.f.)
									EndIf

								EndIf

							EndIf

						EndIf

					EndIf

					NGDelTTVAba(TQN->TQN_NABAST)

					DbSelectArea("TQN")
					RecLock("TQN",.F.)
					Dbdelete()
					MsUnlock("TQN")

				EndIf

			EndIf

		Endif

	EndIf

	RestArea( aArea )
	RestArea( aAreaSd3 )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTipoRet
Atualiza campo da ordem que indica se possui insumo realizado

@param cOrdem, string, número da ordem de serviço
@author Maria Elisandra de Paula
@since 03/06/21
@return nil
/*/
//-------------------------------------------------------------------
Static Function AtuTipoRet( cOrdem )

	Local cTipoRet := ''

	DbSelectArea('STL')
	DbSetorder(1)
	If DbSeek( xFilial('STL') + cOrdem )
		While !( STL->( Eof() ) ) .And. xFilial( 'STL' ) == STL->TL_FILIAL .And. cOrdem == STL->TL_ORDEM

			If Val( STL->TL_SEQRELA ) > 0
				cTipoRet := 'S'
				Exit
			EndIf

			STL->( dbSkip() )
		End

	Else

		cTipoRet := ' '

	EndIf

	DbSelectArea('STJ')
	dbSetOrder(1)
	If dbSeek( xFilial( 'STJ' ) + cOrdem )
		RecLock( 'STJ', .F. )
		STJ->TJ_TIPORET := cTipoRet
		STJ->( MsUnlock('STJ') )
	EndIf

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} MntSC1OfOp
Busca número de solicitação de compras pela OP

@author Maria Elisandra de Paula
@since 02/07/21

@param cOSProd, string, número da ordem de produção.

@return array , Número e Item da S.C.
/*/
//-----------------------------------------------------------------------------
Function MntSC1OfOp( cOSProd )

	Local cSCNum  := ''
	Local cItemSC := ''
	Local nSCItem := 0

	If SuperGetMv( 'MV_NGMNTCP', .F., 'N' ) == 'S' .Or.;
		SuperGetMv( 'MV_NGMNTSC', .F., 'N' ) == 2

		dbSelectArea('SC1')
		dbSetOrder(4)
		If dbSeek( xFilial('SC1') + cOSProd )

			While !Eof() .And. xFilial('SC1') + cOSProd == SC1->C1_FILIAL + SC1->C1_OP

				cSCNum  := SC1->C1_NUM
				nSCItem := Val( SC1->C1_ITEM )

				SC1->( dbSkip() )

			EndDo

		EndIf

		/*------------------------------------------------------+
		| Incrementa o ultimo número utilizado para Item da S.C |                                                  | 
		+------------------------------------------------------*/
		nSCItem++

		/*-----------------------------------------------------+
		| Converte conforme o tipo e tamanho do campo C1_ITEM. |                                                  | 
		+-----------------------------------------------------*/
		cItemSC := StrZero( nSCItem, TamSX3( 'C1_ITEM' )[1] )

	EndIf
	

Return { cSCNum, cItemSC }

//-----------------------------------------------------------------------------
/*/{Protheus.doc} MNTNumSC
Busca o número e item da solicitação de compras para gravação.
@type function

@author Alexandre Santos.
@since 21/10/2021

@param cNumSC , string, Número da S.C. já em uso.
@param cItemSC, string, Item da S.C. já em uso.
@param cOSProd, string, O.P. que será vinculado a S.C.
@param cSC1Bkp, string, Número da S.C. utilizado em outros itens da mesma O.S.

@return array , Número e Item da S.C.
	[1] - Número da S.C.
	[2] - Item da S.C.
/*/
//-----------------------------------------------------------------------------
Function MNTNumSC( cNumSC, cItemSC, cOSProd, cSC1Bkp )

	Local aArSC1 := SC1->( GetArea() )
	Local aRet   := { '', '' }

	If !Empty( cNumSC )

		/*-----------------------------------------------------------------+
		| Processo de alteração de S.C. assim utiliza-se a mesma numeração |
		+-----------------------------------------------------------------*/
		aRet[1] := cNumSC

		If !Empty( cItemSC )

			/*------------------------------------------------------------+
			| Processo de alteração de S.C. assim utiliza-se o mesm0 item |
			+------------------------------------------------------------*/
			aRet[2] := cItemSC

		EndIf

	Else
		
		If !Empty( cSC1Bkp )

			/*-------------------------------------------------------------------------------+
			| Utiliza o Número S.C. já utilizado para está ordem de produção em outros itens |
			+-------------------------------------------------------------------------------*/
			aRet[1] := cSC1Bkp

		Else
			
			/*-------------------------------------------+
			| Busca o Número e Item S.C. conforme a O.P. |
			+-------------------------------------------*/
			aRet := MntSC1OfOp( cOSProd )

		EndIf
		
	EndIf

	If Empty( aRet[1] )
		
		/*--------------------------------------+
		| Gera um uma nova numerção para a S.C. |
		+--------------------------------------*/
		aRet[1] := GETNumSC1( .T. )

		If __lSX8
			ConfirmSX8()
		EndIf

	EndIf

	If Empty( aRet[2] )

		/*-------------------------------------------------+
		| Gera um novo Item de acordo com o número da S.C. |
		+-------------------------------------------------*/
		aRet[2] := fSC1Item( aRet[1] )

	EndIf

	RestArea( aArSC1 )
	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fSC1Item
Busca próximo número do item da solicitação de compras.
@type function

@author Maria Elisandra de Paula
@since 02/07/21
@param cSCNum , string, número da SC1.
@return string, Item da solicitação de compras.
/*/
//-------------------------------------------------------------------
Static Function fSC1Item( cSCNum )

	Local nSCItem := 0
	Local cItemSC := ''

	dbSelectArea('SC1')
	dbSetOrder(1)
	If dbSeek( xFilial('SC1') + cSCNum )

		While !Eof() .And. xFilial('SC1') + cSCNum == SC1->C1_FILIAL + SC1->C1_NUM

			nSCItem := Val( SC1->C1_ITEM )

			SC1->( dbSkip() )

		EndDo

	EndIf

	/*------------------------------------------------------+
	| Incrementa o ultimo número utilizado para Item da S.C |                                                  | 
	+------------------------------------------------------*/
	nSCItem++

	/*-----------------------------------------------------+
	| Converte conforme o tipo e tamanho do campo C1_ITEM. |                                                  | 
	+-----------------------------------------------------*/
	cItemSC := StrZero( nSCItem, TamSX3( 'C1_ITEM' )[1] )

Return cItemSC

//----------------------------------------------------
/*/{Protheus.doc} MNTDESCOS
Retorna descrição para rel. e cons. kardex

@autor Maria Elisandra de Paula
@since 15/07/2021
@param cOp, string, número da ordem de produção
@param lDescOs, booelan, se imprime 'OS-'
@return string
/*/
//----------------------------------------------------
Function MNTDESCOS( cOrdem, cCCusto, lDescOs )

	Local cRet   := ''
	Local cDesCC := IIf( !Empty( cCCusto ), '-' + cCCusto, '' )

	Default lDescOs := .T.

	If lDescOs
		cRet := 'OS-'
	EndIf

	cRet += cOrdem + cDesCC

Return cRet

//----------------------------------------------------------
/*/{Protheus.doc} MNTXCOM
Aciona o ExecAuto MATA110 para alteração de S.C.
@type function

@autor Alexandre Santos
@since 21/10/2021

@param cNumSC  , string, Número da solicitação de compra.
@param cItemSC , string, Item da solicitação de compra.
@param aUpdInfo, array , Campos a serem alterados na S.C.
	[1] C1_QUANT   - Quantidade
	[2] C1_LOCAL   - Local de Estoque
	[3] C1_PRODUTO - Produto

@return array  , Indica se o processo foi realizado.
	[1] - Indica se o processo teve êxito.
	[2] - Mensagem de erro, caso exista.
/*/
//----------------------------------------------------------
Function MNTXCOM( cNumSC, cItemSC, aUpdInfo )

	Local aAreaSC1      := SC1->( GetArea() )
	Local aHeadBkp      := {}
	Local aCabecSC1     := {}
	Local aItensSC1     := {}
	Local aRet          := { .T., '' }

	Private lMsErroAuto := .F.
	
	/*-----------------------------------------------------------------------------------------------+
	| A variavél aHeader é utilizada pelo ExecAuto MATA110, como ela encontra-se com escopo privete, |
	| seu conteúdo deve ser salvo e a variável zerada.                                               |
	+-----------------------------------------------------------------------------------------------*/
	aHeadBkp := aClone( aHeader )
	aHeader  := {}
	
	/*------------------------------------------------+
	| Posiciona no registro da SC1 que será alterado. |
	+------------------------------------------------*/
	dbSelectArea( 'SC1' )
	dbSetOrder( 1 ) // C1_FILIAL + C1_NUM + C1_ITEM + C1_ITEMGRD
	If dbSeek( xFilial( 'SC1' ) + cNumSC + cItemSC )

		aAdd( aCabecSC1, { 'C1_NUM'    , SC1->C1_NUM 	, Nil } )
		aAdd( aCabecSC1, { 'C1_SOLICIT', SC1->C1_SOLICIT, Nil } )
		aAdd( aCabecSC1, { 'C1_EMISSAO', SC1->C1_EMISSAO, Nil } )

		aAdd( aItensSC1, 	{ 	{ 'C1_NUM'    , SC1->C1_NUM	   , Nil },;
								{ 'C1_ITEM'   , SC1->C1_ITEM   , Nil },;
								{ 'C1_PRODUTO', SC1->C1_PRODUTO, Nil },;
								{ 'C1_QUANT'  , aUpdInfo[1]	   , Nil },;
								{ 'C1_EMISSAO', SC1->C1_EMISSAO, Nil },;
								{ 'C1_DATPRF' , SC1->C1_DATPRF , Nil },;
								{ 'C1_OBS'    , SC1->C1_OBS    , Nil },;
								{ 'C1_OP'     , SC1->C1_OP     , Nil },;
								{ 'C1_CC'     , SC1->C1_CC     , Nil },;
								{ 'C1_QTDORIG', SC1->C1_QTDORIG, Nil },;
								{ 'C1_FORNECE', SC1->C1_FORNECE, Nil },;
								{ 'C1_LOJA'   , SC1->C1_LOJA   , Nil },;
								{ 'C1_ORIGEM' , FunName()      , Nil },;
								{ 'C1_LOCAL'  , aUpdInfo[2]    , Nil },;
								{ 'C1_ITEMCTA', SC1->C1_ITEMCTA, Nil },;
								{ 'C1_UM'	  , NGSEEK( 'SB1', aUpdInfo[3], 1, 'B1_UM' )   , Nil },;
								{ 'C1_CONTA'  , NGSEEK( 'SB1', aUpdInfo[3], 1, 'B1_CONTA' ), Nil } } )

		MSExecAuto( { |x,y,z| MATA110( x, y, z ) }, aCabecSC1, aItensSC1, 4 )

		If lMsErroAuto

			If IsBlind()

				aRet := { .F., MostraErro( GetSrvProfString( 'StartPath', '' ) ) }

			Else

				MostraErro()
				aRet := { .F., '' }

			EndIf
			
		EndIf

	EndIf

	/*---------------------------------------+
	| Restaura conteúdo da variavél aHeader. |
	+---------------------------------------*/
	aHeader := aClone( aHeadBkp )

	RestArea( aAreaSC1 )
	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NGVLMNT
Valida se o bem possui alguma manutenção ativa e se existe algum bloqueio
que impeça a O.S. de ser gerada.

@type   Function

@author Eduardo Mussi
@since  14/12/2021

@param  cBemMNT  , Caractere, Código do bem
@param  nContador, Numérico , Contador do bem
@param  cFilMNT  , Caractere, Filial do bem
@param  aTrbEst  , Array    , Estrutura
@param  lCon1Vez , Lógico   , Define se gera O.S por contador quando não executado pelo ws
@param  lGerOsAut, Lógico   , Define se gera O.S automatica
@param  aVldMNT  , Array    , Array contendo os Recnos da STF que não irão gerar O.S.
							   aVldMNT[ x, 1 ] - Recno STF
							   aVldMNT[ x, 2 ] - Define que não irá gerar O.S
@param  lCont2   , boolean  , Indica se a validação é referente a contador 2.

@return Lógico, define se o bem poderá gerar O.S. automática
/*/
//-------------------------------------------------------------------
Function NGVLMNT( cBemMNT, nContador, cFilMNT, aTrbEst, lCon1Vez, lGerOsAut, aVldMNT, lCont2 )

	Local aARRCOMP   :=  {}
	Local cGOSESTRU  := AllTrim(GETMv("MV_NGOSAES"))
	Local cVERGEROS  := AllTrim(GETMv("MV_NGVEROS"))
	Local cFilGSTC   := NGTROCAFILI( 'STC', cFilMNT )
	Local lCONUS1VEZ := .F.
	Local lReturn    := .T.
	
	Default lCont2   := .F.

	If cVERGEROS == 'V' 
	
		If ValType( lCon1Vez ) == 'U'

			If !isBlind()
			
				lCONUS1VEZ := MsgYesNo(STR0015+chr(13); //"Deseja gerar OS automática por contador mesmo que já exista OS aberta"
				+STR0016+chr(13)+chr(13); //"para o mesmo Bem+Serviço+Sequência ?"
				+STR0017,STR0018) //"Confirma (Sim/Não)" # "ATENÇÃO"
				lCon1Vez := lCONUS1VEZ

			Else
				
				// Quando executado pelo webservice não irá gerar caso já exista
				lCon1Vez := lCONUS1VEZ

			EndIf

		Else

			// Quando a pergunta já foir respondida, recupera a resposta.
			lCONUS1VEZ := lCon1Vez

		EndIf

	EndIf

	lReturn := NGMNTCHK( cBemMNT, nContador, cFilMNT, .F.,, cVERGEROS, lCONUS1VEZ, @aVldMNT, lCont2 )

	If lReturn .And. ( cGOSESTRU == 'S' .Or. cGOSESTRU == 'C' )
		
		dbSelectArea( 'STC' )
		dbSetOrder( 1 ) // TC_FILIAL+TC_CODBEM+TC_COMPONE+TC_TIPOEST+TC_LOCALIZ+TC_SEQRELA
		If dbSeek( cFilGSTC + cBemMNT )

			//GERAR O.S AUTOMATICA POR CONTADOR PARA OS COMPONENTES DA ESTRUTURA QUE SAO CONTROLADOS POR CONTADOR
			If cGOSESTRU == 'C'

				If GetRemoteType() == -1 .Or. MsgYesNo(STR0019 + chr(13)+chr(13); //"Deseja que seja verificado a existência de o.s automática por contador"
					+STR0020 + Chr(13)+Chr(13)+STR0017) //"para os componentes da estrutura de bens ?" # "Confirma (Sim/Nao)"

					aARRCOMP  := NGCOMPPCONT(cBemMNT,dDataBase,SubStr(Time(),1,5),cFilMNT,aTrbEst)
					lGerOsAut := .T.
					If Len(aARRCOMP) > 0
						lReturn := NGMNTCHK(cBemMNT,nContador,cFilMNT,.T.,aARRCOMP,cVERGEROS,lCONUS1VEZ, @aVldMNT )
					EndIf
				EndIf

			Else

				aARRCOMP  := NGCOMPPCONT(cBemMNT,dDataBase,SubStr(Time(),1,5),cFilMNT,aTrbEst)
				lGerOsAut := .T.
				
				If Len(aARRCOMP) > 0
					lReturn := NGMNTCHK( cBemMNT,nContador,cFilMNT,.T.,aARRCOMP,cVERGEROS,lCONUS1VEZ, @aVldMNT )
				EndIf
			EndIf
		EndIf

	EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} NGMNTCHK
Valida se a manutenção é valida para geração de O.S.

@type   Function

@author Eduardo Mussi
@since  23/12/2021

@param  cBemMNT   , Caractere, Código do Bem
@param  nContador , Numérico , Posição do contador
@param  cFilMNT   , Caractere, Filial a ser validada
@param  lEstru    , Lógico   , Se verifica estrutura
@param  aEstruBem , Array    , Estrutura
@param  cVERGEROS , Caractere, Conteúdo do parametro MV_NGVEROS
@param  lCONUS1VEZ, Lógico   , Define se gera O.S por contador quando não executado pelo ws
@param  aVldMNT   , Array    , Array contendo os Recnos da STF que não irão gerar O.S.
							   aVldMNT[ x, 1 ] - Recno STF
							   aVldMNT[ x, 2 ] - Define que não irá gerar O.S
@param  [lCont2]  , boolean  , Indica se a validação é referente a contador 2.

@return Lógico, Define se a manutenção é valida para gerar O.S.
/*/
//-------------------------------------------------------------------
Static Function NGMNTCHK( cBemMNT, nContador, cFilMNT, lEstru, aEstruBem, cVERGEROS, lCONUS1VEZ, aVldMNT, lCont2 )
	
	Local nEstru   := 0
	Local lReturn  := .T.

	Default lCont2 := .F.
	
	If lEstru
		For nEstru := 1 To Len( aEstruBem )
			If !NGVLSTF( aEstruBem[ nEstru, 1 ], cFilMNT,cVERGEROS,lCONUS1VEZ, @aVldMNT, nContador )
				lReturn := .F.
				Exit
			EndIf
		Next nEstru
	Else
		lReturn := NGVLSTF( cBemMNT, cFilMNT, cVERGEROS, lCONUS1VEZ, @aVldMNT, nContador, lCont2 )
	EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} NGVLSTF
Procura na manutenção se existe algum impeditivo para geração de O.S.

@type   Function

@author Eduardo Mussi
@since  23/12/2021
@param  cBemMNT   , Caractere, Código do Bem
@param  cFilMNT   , Caractere, Filial do bem
@param  cVERGEROS , Caractere, Conteúdo do parametro MV_NGVEROS
@param  lCONUS1VEZ, Lógico   , Define se gera O.S por contador quando não executado pelo ws
@param  aVldMNT   , array    , Array contendo os Recnos da STF que não irão gerar O.S.
							   aVldMNT[ x, 1 ] - Recno STF
							   aVldMNT[ x, 2 ] - Define que não irá gerar O.S
@param nCounter   , numeric  , Posição de contador reportado.
@param  [lCont2]  , boolean  , Indica se a validação é referente a contador 2.

@return Lógico, Define se existem manutenções que podem gerar O.S.
/*/
//-------------------------------------------------------------------
Function NGVLSTF( cBemMNT, cFilMNT, cVERGEROS, lCONUS1VEZ, aVldMNT, nCounter, lCont2 )	

	Local aCounter  := {}
	Local aOSABER   := {}
	Local cTContacu := ''
	Local cFilOTPE  := NGTROCAFILI( 'TPE', cFilMNT )
	Local cFilOST9  := NGTROCAFILI( 'ST9', cFilMNT )
	Local cFilOSTF  := NGTROCAFILI( 'STF', cFilMNT )
	Local cAliasQry := GetNextAlias()
	Local dTDtUltac := CToD( '' )
	Local lReturn   := .T.
	Local nTVardia  := 0
	Local nTolCont  := 0
	Local nReg      := 0
	Local nPERFIXO  := ( SuperGetMV( 'MV_NGCOFIX', .F., 50 ) / 100 )
	Local lCONPREV  := STF->( FieldPos( 'TF_CONPREV' ) ) > 0

	Default lCont2  := .F.

	// Caso possua campo TF_CONPREV adiciona o campo
	cCamQuery := IIf( lCONPREV, '%, STF.TF_CONPREV%', '%%' )
	cWhereCnt := "%AND " + IIf( lCont2  , "STF.TF_TIPACOM = 'S'", "STF.TF_TIPACOM <> 'S'" ) + "%"

	BeginSQL Alias cAliasQry
	
		SELECT  
			ST9.T9_CCUSTO ,
			ST9.T9_TEMCONT,
			STF.TF_CODBEM ,
			STF.TF_CONMANU,
			STF.TF_INENMAN,
			STF.TF_SERVICO,
			STF.TF_SEQRELA,
			STF.TF_TOLERA ,
			STF.TF_TIPACOM,
			STF.TF_DTULTMA,
			STF.TF_TEENMAN,
			STF.TF_UNENMAN,
			STF.R_E_C_N_O_ AS RECNO
			%exp:cCamQuery%
		FROM 
			%table:ST9% ST9
		INNER JOIN 
			%table:STF% STF ON
				ST9.T9_FILIAL = %exp:cFilOST9% AND
				ST9.T9_CODBEM = STF.TF_CODBEM  AND
				ST9.T9_SITBEM = 'A'            AND
				ST9.T9_SITMAN <> 'I'           AND
				ST9.%NotDel%
		WHERE   
			STF.TF_FILIAL  = %exp:cFilOSTF%               AND
			STF.TF_CODBEM  = %exp:cBemMNT%                AND
			STF.TF_PERIODO <> 'E'                         AND
			STF.TF_ATIVO   <> 'N'                         AND
			STF.TF_CONMANU + TF_INENMAN <= %exp:nCounter% AND
			STF.%NotDel%
			%exp:cWhereCnt%
			
	EndSQL

	Do while (cAliasQry)->( !EoF() )

		// Dados do primeiro contador
		If nReg == 0 .And. (cAliasQry)->T9_TEMCONT != 'N'
			aCounter   := NGACUMEHIS( (cAliasQry)->TF_CODBEM, dDatabase, Substr( Time(), 1, 5 ), 1, 'A', cFilOST9 )
			cTContacu  := aCounter[ 2 ]
			dTDtUltac  := acounter[ 3 ]
			nTVardia   := aCounter[ 6 ]
		EndIf
		
		nTolCont := (cAliasQry)->TF_TOLERA * nTVardia

		If (cAliasQry)->TF_TIPACOM != 'T'

			If (cAliasQry)->TF_TIPACOM == 'S'

				dbSelectArea( 'TPE' )
				dbSetOrder( 1 ) // TPE_FILIAL + TPE_CODBEM
				If dbSeek( cFilOTPE + (cAliasQry)->TF_CODBEM )

					// Dados do segundo contador
					aCounter   := NGACUMEHIS( (cAliasQry)->TF_CODBEM, dDatabase, Substr( Time(), 1, 5 ), 2, 'A', cFilOTPE )
					cTContacu := aCounter[ 2 ]
					dTDtUltac := acounter[ 3 ]
					nTVardia  := aCounter[ 6 ]

					If (((cAliasQry)->TF_CONMANU + (cAliasQry)->TF_INENMAN) <= cTContacu) .Or. ;
						( ( (cAliasQry)->TF_CONMANU + (cAliasQry)->TF_INENMAN ) >= cTContacu .And. ( ( (cAliasQry)->TF_CONMANU + (cAliasQry)->TF_INENMAN - nTolCont ) < cTContacu ) )

						//Verifica os aberta para mesmo bem+servico+sequencia
						If (cVERGEROS == 'V' .And. !lCONUS1VEZ) .Or. (cVERGEROS == 'C')
							aOSABER := NGPROCOSAB( cFilMNT, 'B', (cAliasQry)->TF_CODBEM, (cAliasQry)->TF_SERVICO, (cAliasQry)->TF_SEQRELA )
							If !aOSABER[1]
								lReturn := .F.
							EndIf
						ElseIf cVERGEROS == 'S'
							aOSABER := NGPROCOSAB( cFilMNT, 'B', (cAliasQry)->TF_CODBEM, (cAliasQry)->TF_SERVICO, (cAliasQry)->TF_SEQRELA )
							If !aOSABER[1]
								If  GetRemoteType() > -1 .And. !MsgYesNo(STR0216+chr(13)+chr(13); //"Já existe OS aberta para o mesmo Bem+Serviço+Sequência:"
										+STR0217 + ': ' +(cAliasQry)->TF_CODBEM  + chr(13); // "Bem"
										+STR0218 + ': ' +(cAliasQry)->TF_SERVICO + chr(13); // "Serviço"
										+STR0219 + (cAliasQry)->TF_SEQRELA+chr(13)+chr(13); // "Sequência: "
										+STR0220 + chr(13) + chr(13); //"Deseja gerar OS automática por contador mesmo com OS já aberta ?"
										+STR0017, STR0018 ) //"Confirma (Sim/Não)"# "ATENÇÃO"
									aAdd( aVldMnt, { (cAliasQry)->RECNO, .F. } )
									lReturn    := .F.
									Exit
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

			Else

				If (cAliasQry)->TF_TIPACOM = "F"

					nULTCOMAN := IIf( lCONPREV, (cAliasQry)->TF_CONPREV, (cAliasQry)->TF_CONMANU )
					nINCPERC  := ( (cAliasQry)->TF_INENMAN * nPERFIXO ) // Incremento da manutencao com percentual

					nVEZMANU := Int(nULTCOMAN / (cAliasQry)->TF_INENMAN) // Numero de vezes que foi feito a manutencao
					nCONTFIX := IIf(nVEZMANU == 0, (cAliasQry)->TF_INENMAN, nVEZMANU * (cAliasQry)->TF_INENMAN) // Contador fixo exato
					nCONTPAS := nULTCOMAN - nCONTFIX             // Quantidade que passou da manutenção fixa

					If nCONTPAS < nINCPERC .Or. nINCPERC == 0
						If nCONTPAS < 0
							nCONTPAS := nCONTPAS * - 1
						EndIf
						If nVEZMANU == 0 .And. nCONTPAS > nINCPERC
							nULTCOMAN := 0
						Else
							nULTCOMAN := nCONTFIX
						EndIf
					Else
						nULTCOMAN := nCONTFIX + (cAliasQry)->TF_INENMAN
					EndIf
				Else
					nULTCOMAN := (cAliasQry)->TF_CONMANU
				EndIf

				If ((nULTCOMAN + (cAliasQry)->TF_INENMAN) <= cTContacu ) .Or. ;
					( ( (nULTCOMAN + (cAliasQry)->TF_INENMAN) >= cTContacu) .And.;
					((nULTCOMAN + (cAliasQry)->TF_INENMAN - nTolCont) < cTContacu))

					dDPROXM := NGPROXMAN( SToD( (cAliasQry)->TF_DTULTMA ), (cAliasQry)->TF_TIPACOM, (cAliasQry)->TF_TEENMAN, (cAliasQry)->TF_UNENMAN,;
						nULTCOMAN, (cAliasQry)->TF_INENMAN, cTContacu, nTVardia, SToD( (cAliasQry)->TF_DTULTMA ) )

					//Verifica os aberta para mesmo bem+servico+sequencia
					If ( cVERGEROS == 'V' .And. !lCONUS1VEZ ) .Or. ( cVERGEROS == 'C' )
						aOSABER := NGPROCOSAB( cFilMNT, 'B', (cAliasQry)->TF_CODBEM, (cAliasQry)->TF_SERVICO, (cAliasQry)->TF_SEQRELA )
						If !aOSABER[1]
							aAdd( aVldMnt, { (cAliasQry)->RECNO, .F. } )
							lReturn := .F.
						EndIf
					ElseIf cVERGEROS == 'S'
						aOSABER := NGPROCOSAB( cFilMNT, 'B', (cAliasQry)->TF_CODBEM, (cAliasQry)->TF_SERVICO, (cAliasQry)->TF_SEQRELA )
						If GetRemoteType() > - 1 .And. !aOSABER[1] //-1 = Job, Web ou Working Thread (Sem remote)
							If !MsgYesNo(STR0216+chr(13)+chr(13); //"Já existe OS aberta para o mesmo Bem+Serviço+Sequência:"
									+STR0217 + ': ' + (cAliasQry)->TF_CODBEM  + chr(13);    // "Bem"
									+STR0218 + ': ' + (cAliasQry)->TF_SERVICO + chr(13);    // "Serviço"
									+STR0219 + (cAliasQry)->TF_SEQRELA + chr(13) + chr(13); // "Sequência: "
									+STR0220 + chr(13) + chr(13); //"Deseja gerar OS automática por contador mesmo com OS já aberta ?"
									+STR0017,STR0018) //"Confirma (Sim/Não)"# "ATENÇÃO"
								aAdd( aVldMnt, { (cAliasQry)->RECNO, .F. } )
								lReturn    := .F.
								Exit
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

		EndIf

		(cAliasQry)->( dbSkip() )
		nReg++
	EndDo

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} MntSldSB2
Consulta saldo disponível por local de estoque.
@type function

@author Alexandre Santos
@since  29/09/2022

@param  cCodProd, string, Código do Produto.

@return array   , Lista dos saldos disponiveis local de estoque.
					[1] - Código do Local de Estoque
					[2] - Saldo disponível
/*/
//---------------------------------------------------------------------
Function MntSldSB2( cCodProd )

	Local aBind   := {}
	Local aSldSB2 := {}
	Local aArea   := SB2->( GetArea() )
	Local cAlsSB2 := GetNextAlias()
	Local nSaldo  := 0

	/*----------------------------------------+
	| Verifica a existência da query em cache |
	+----------------------------------------*/
	If Empty( cQrySldSB2 )
		
		cQrySldSB2 :=	'SELECT '
		cQrySldSB2 += 		'SB2.R_E_C_N_O_ '
		cQrySldSB2 +=	'FROM '
		cQrySldSB2 += 		RetSqlName( 'SB2' ) + ' SB2 '
		cQrySldSB2 += 	'WHERE '
		cQrySldSB2 += 		'SB2.B2_FILIAL  = ? AND '
		cQrySldSB2 += 		'SB2.B2_COD     = ? AND '
		cQrySldSB2 += 		'SB2.B2_STATUS <> ? AND '
		cQrySldSB2 += 		'SB2.D_E_L_E_T_ = ? '
		cQrySldSB2 += 	'ORDER BY '
		cQrySldSB2 += 		'SB2.B2_LOCAL'
				
		cQrySldSB2 := ChangeQuery( cQrySldSB2 )
	
	EndIf
	
	aBind := {}
	aAdd( aBind, FWxFilial( 'SB2' ) )
	aAdd( aBind, cCodProd )
	aAdd( aBind, '2' )
	aAdd( aBind, Space( 1 ) )

	dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQrySldSB2, aBind ), cAlsSB2, .T., .T. )

	While (cAlsSB2)->( !EoF() )

		SB2->( msGoTo( (cAlsSB2)->R_E_C_N_O_ ) )

		/*--------------------------------------------------------------------------+
		| Retorna saldo disponível do local de estoque, conforme regras do estoque. |
		+--------------------------------------------------------------------------*/
		If ( nSaldo := QtdComp( SaldoSB2() ) ) > 0

			aAdd( aSldSB2, { SB2->B2_LOCAL, nSaldo } )

		EndIf

		(cAlsSB2)->( dbSkip() )

	End

	(cAlsSB2)->( dbCloseArea() )

	RestArea( aArea )

	/*------------------------------------------------+
	| Libera consumo de memória p/ melhor performance |
	+------------------------------------------------*/
	aSize( aArea, 0 )
	aArea := Nil
	
	aSize( aBind, 0 )
	aBind := Nil
	
Return aSldSB2

//---------------------------------------------------------------------
/*/{Protheus.doc} MntSldSBF
Consulta saldo disponível por endereço.
@type function

@author Alexandre Santos
@since  29/09/2022

@param  cCodProd, string, Código do Produto.
@param  cCodAlmo, string, Código do Local de Estoque.

@return array   , Lista dos saldos disponiveis por endereço.
					[1] - Código do Endereço
					[2] - Saldo disponível
/*/
//---------------------------------------------------------------------
Function MntSldSBF( cCodProd, cCodAlmo )

	Local aBind   := {}
	Local aSldSBF := {}
	Local aArea   := SBF->( GetArea() )
	Local cAlsSBF := GetNextAlias()
	Local nSaldo  := 0

	/*----------------------------------------+
	| Verifica a existência da query em cache |
	+----------------------------------------*/
	If Empty( cQrySldSBF )
		
		cQrySldSBF :=	'SELECT '
		cQrySldSBF += 		'SBF.R_E_C_N_O_ '
		cQrySldSBF +=	'FROM '
		cQrySldSBF += 		RetSqlName( 'SBF' ) + ' SBF '
		cQrySldSBF += 	'WHERE '
		cQrySldSBF += 		'SBF.BF_FILIAL  = ? AND '
		cQrySldSBF += 		'SBF.BF_PRODUTO = ? AND '
		cQrySldSBF += 		'SBF.BF_LOCAL   = ? AND '
		cQrySldSBF += 		'SBF.D_E_L_E_T_ = ? '
		cQrySldSBF += 	'ORDER BY '
		cQrySldSBF += 		'SBF.BF_LOCALIZ'
				
		cQrySldSBF := ChangeQuery( cQrySldSBF )
	
	EndIf
	
	aBind := {}
	aAdd( aBind, FWxFilial( 'SBF' ) )
	aAdd( aBind, cCodProd )
	aAdd( aBind, cCodAlmo )
	aAdd( aBind, Space( 1 ) )

	dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQrySldSBF, aBind ), cAlsSBF, .T., .T. )

	While (cAlsSBF)->( !EoF() )

		SBF->( msGoTo( (cAlsSBF)->R_E_C_N_O_ ) )

		/*------------------------------------------------------------------+
		| Retorna saldo disponível do endereço, conforme regras do estoque. |
		+------------------------------------------------------------------*/
		If ( nSaldo := QtdComp( SaldoSBF( SBF->BF_LOCAL, SBF->BF_LOCALIZ, SBF->BF_PRODUTO, '', '', '', .F. ) ) ) > 0

			aAdd( aSldSBF, { SBF->BF_LOCALIZ, nSaldo } )

		EndIf

		(cAlsSBF)->( dbSkip() )

	End

	(cAlsSBF)->( dbCloseArea() )

	RestArea( aArea )

	/*------------------------------------------------+
	| Libera consumo de memória p/ melhor performance |
	+------------------------------------------------*/
	aSize( aArea, 0 )
	aArea := Nil
	
	aSize( aBind, 0 )
	aBind := Nil
	
Return aSldSBF
