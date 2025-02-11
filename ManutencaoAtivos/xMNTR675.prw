#include "MNTR675.ch"
#INCLUDE "PROTHEUS.CH"

Static cBchST4 := ' '
Static cBchST5 := ' '
Static cBchSTB := ' '
Static cBchSTF := ' '
Static cBchSTI := ' '
Static cBchSTJ := ' '
Static cBchSTL := ' '
Static cBchSTQ := ' '
Static cBchTPA := ' '
Static cBchTPC := ' '
Static cBchTPL := ' '
Static cBchTTB := ' '
Static cBchTTC := ' '

//----------------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR675
Impressão da ordem de serviço.
@type function

@author Inácio Luiz Kolling
@since 07/08/2002

@param lVPERG    , boolean, Define se será apresentado o pergunte ao usuário.
@param cDEPLANO  , string , Indica código inicio do filtro de plano de manutenção.
@param cATEPLANO , string , Indica código final do filtro de plano de manutenção.
@param aMATOS    , array  , Matriz de O.S.
@param nTipo     , numeric, Define qual dos relatórios será impresso.
@param [avMatSX1], array  , Não utilizado, mantido por compatibilidade.
@param [nRecOs]  , numeric, RECNO para posicionamento na ordem de serviço.
@param [cAls990] , string , Alias temporário para insumos da rotina MNTA990.

@return
/*/
//----------------------------------------------------------------------------------------
User Function MNTR675(lVPERG, cDEPLANO, cATEPLANO, aMATOS, nTipo, avMatSX1, nRecOs, cAls990 )

	//+-----------------------------------------------+
	//| Armazena variaveis p/ devolucao (NGRIGHTCLICK)|
	//+-----------------------------------------------+
	Local aNGBEGINPRM := NGBEGINPRM()

	Local cString		:= "STJ"
	Local lPERGUN       := IIf(ValType(lVPERG) != "L",.T.,lVPERG)
	Local cdesc1		:= STR0001 //"Emissao de Ordem de Servico de Manutencao. O Usuario pode selecionar"
	Local cdesc2		:= STR0002 //"quais os campos que deverao ser mostrados na O.S., bem como informar"
	Local cdesc3		:= STR0003 //"parametros de selecao para a impressao."
	Local wnrel			:= "MNTR675"
	Local aArea

	cBchST4 := xFilial( 'ST4' )
	cBchST5 := xFilial( 'ST5' )
	cBchSTB := xFilial( 'STB' )
	cBchSTF := xFilial( 'STF' )
	cBchSTI := xFilial( 'STI' )
	cBchSTJ := xFilial( 'STJ' )
	cBchSTL := xFilial( 'STL' )
	cBchSTQ := xFilial( 'STQ' )
	cBchTPA := xFilial( 'TPA' )
	cBchTPC := xFilial( 'TPC' )
	cBchTPL := xFilial( 'TPL' )
	cBchTTB := xFilial( 'TTB' )
	cBchTTC := xFilial( 'TTC' )

	Private aReturn	:= {STR0004, 1,STR0005, 2, 2, 1, "",1} //"Zebrado"###"Administracao"
	Private nLastKey	:= 0
	Private Tamanho	:= "P"
	Private cPerg	:= "MNT675"
	Private Titulo	:= STR0006 //"Ordem De Servico De Manutencao"
	Private lSEQSTF	:= If(NGVerify("STF"),.T.,.F.)
	Private lSEQSTJ	:= If(NGVerify("STJ"),.T.,.F.)
	Private lSEQSTL	:= If(NGVerify("STL"),.T.,.F.)
	Private oPrint
	Private oDlgC,nTImpr,nOpca := 0
	Private lUSATAR := If(FindFunction("NGUSATARPAD"),NGUSATARPAD(),.f.)
	Private nB1		:= TAMSX3("B1_COD")[1]-15
	Private aMatSX1 := {}
	Private lQuebra := .F.
	Private nHorz	:= 100
	Private cTRB675	:= GetNextAlias()

	Default nRecOs   := 0
	Default avMatSX1 := {}
	Default cAls990  := ''

	aMatSX1 := aClone(avMatSX1)

	oFontPN := TFont():New("Courier New",13,13,,.T.,,,,.F.,.F.)
	oFontMN := TFont():New("Courier New",18,18,,.T.,,,,.F.,.F.)
	oFontGN := TFont():New("Courier New",20,20,,.T.,,,,.F.,.F.)

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis utilizadas para parametros                         ³
	³ mv_par01     // De  Plano de Manutencao                      ³
	³ mv_par02     // Ate Plano de manutencao                      ³
	³ mv_par03     // Lista Descricao do Bem   S/N                 ³
	³ mv_par04     // Lista Detalhes do Bem    S/N                 ³
	³ mv_par05     // Lista Descricao Manut.   S/N                 ³
	³ mv_par06     // Lista Descricao Etapas   S/N                 ³
	³ mv_par07     // De  Centro de Custo                          ³
	³ mv_par08     // Ate Centro de Custo                          ³
	³ mv_par09     // De  Centro de Trabalho                       ³
	³ mv_par10     // Ate Centro de Trabalho                       ³
	³ mv_par11     // De  Area de Manutencao                       ³
	³ mv_par12     // Ate Area de Manutencao                       ³
	³ mv_par13     // De  Ordem de Servico                         ³
	³ mv_par14     // Ate Ordem de Servico                         ³
	³ mv_par15     // De  Data de Manutencao                       ³
	³ mv_par16     // Ate Data de manutencao                       ³
	³ mv_par17     // Classificacao (Ordem,Servico/Bem,            ³
	³                 Centro Custos,Data da O.S,Servico/Bem Pai)   ³
	³ mv_par18     // Lista descr. da O.S  (Nao, Sim)              ³
	³ mv_par19     // Lista pecas de reposicao(Nao,Sim)            ³
	³ mv_par20     // Lista Banco do Conhecimento(Nao, Sim)        ³
	³ mv_par21     // Banco do Conhecimento(Da OS, Da Manutencao,  ³
	³              // Ambos)                                       ³
	³ mv_par22     // Tipo de Impressao (Em Disco, Via Spool)      ³
	³ mv_par23     // Lista Opcoes da Etapa ? (Sim, Nao)           ³
	³ mv_par24     // Imprimir Localizacao : (Sim, Nao)			   ³
	³ mv_par25     // Imprimir O.S. ? : (Liberada, Pendente, Todas)³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/

	cLogo := NGLOCLOGO()

	vVetMvP := NGSALVAMVPA()

	If nTipo = Nil

		Define MsDialog oDlgC From 00,00 To 200,350 Title STR0088 Pixel

		oPnlPai := TPanel():New(00,00,,oDlgC,,,,,,310,300,.F.,.F.)
		oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		@ 005,007 To 60,170 Label STR0091 Of oPnlPai Pixel

		@ 045,012 Radio oRad Var nTImpr Items STR0092 + " " + STR0089, STR0092 + " " + STR0090,; //"Padrao"+"Normal"###"Padrao"+"Grafico"
		STR0093 + " " + STR0089, STR0093 + " " + STR0090 Of Size 60,10 Of oPnlPai Pixel //"Completa"+"Normal"###"Completa"+"Grafico"

		Activate MsDialog oDlgC On Init EnchoiceBar(oDlgC,{|| nOPCA := 1,oDlgC:End()},{||oDlgC:End()}) Centered

		If nOpca == 0
			Return
		EndIf
	Else
		nTImpr := nTipo
	EndIf

	lPerg := Pergunte(cPerg, IIf((nTImpr == 2 .Or. nTImpr == 4) .And. lPERGUN,.T.,.F.))

	If !IsInCallStack("MNTA265")
		If ValType(nRecOs) == "N" .And. nRecOs > 0
			aArea := STJ->(GetArea())

			dbSelectArea("STJ")
			dbGoTo(nRecOs)

			aMATSX1 := 	{{'01',stj->tj_plano},{'02',stj->tj_plano},;
						 {'07',stj->tj_ccusto},{'08',stj->tj_ccusto},;
						 {'09',stj->tj_centrab},{'10',stj->tj_centrab},;
						 {'11',stj->tj_codarea},{'12',stj->tj_codarea},;
						 {'13',STJ->TJ_ORDEM},{'14',STJ->TJ_ORDEM},;
						 {'15',STJ->TJ_DTMPINI},{'16',STJ->TJ_DTMPINI},;
						 {'18',2}, {'24',1},{'25',3}} //Adicionada MV_PAR18 que é listar Descrição da OS.

			RestArea(aArea)
		EndIf
	EndIf

	If nTImpr = 2 .Or. nTImpr = 4

		If !lperg .And. lPERGUN
			Return
		EndIf

		oPrint  := TMSPrinter():New(OemToAnsi(STR0006))
		limpbol := oPrint:Setup()
		oPrint:SetPortrait() // Normal

		If !limpbol
			Return
		EndIf

		If ExistBlock( 'MNTR6752' )
			ExecBlock( 'MNTR6752', .F., .F., { oPrint, cDEPLANO, cATEPLANO, aMATOS, nRecOs, cAls990 } )
		Else
 			Processa( { |lEnd| RW675IMP( oPrint, cDEPLANO, cATEPLANO, aMATOS, nRecOs, cAls990 ) }, STR0067 ) // "Aguarde... verificando alteracoes.."
		EndIf

	Else
		If lPERGUN
			wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
		Else
			wnrel:=SetPrint(cString,wnrel,,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
		EndIf

		If nLastKey = 27
			Set Filter To
			DbSelectArea("STI")
			Return
		EndIf

		SetDefault(aReturn,cString)
		
		RptStatus( { |lEnd| R675Imp( @lEnd, wnRel, titulo, tamanho, cDEPLANO, cATEPLANO, aMATOS, nRecOS, cAls990 ) }, titulo )

	EndIf

	NGRETAUMVPA(vVetMvP)

	DbSelectArea("STI")

	//+-----------------------------------------------+
	//| Devolve variaveis armazenadas (NGRIGHTCLICK)  |
	//+-----------------------------------------------+
	NGRETURNPRM(aNGBEGINPRM)

Return

//----------------------------------------------------------------------------------------
/*/{Protheus.doc} RW675Imp
Chamada para impressão da ordem de serviço.
@type function

@author Inácio Luiz Kolling
@since 13/11/1995

@param oPrint    , object , Objeto de impressão.
@param cDEPLANO  , string , Indica código inicio do filtro de plano de manutenção.
@param cATEPLANO , string , Indica código final do filtro de plano de manutenção.
@param aMATOS    , array  , Matriz de O.S.
@param [nRecOs]  , numeric, RECNO para posicionamento na ordem de serviço.
@param [cAls990] , string , Alias temporário para insumos da rotina MNTA990.

@return
/*/
//----------------------------------------------------------------------------------------
User Function RW675Imp( oPrint, cDEPLANO, cATEPLANO, aMATOS, nRecOS, cAls990 )

	Local cCONDICAO := IIf(cDEPLANO = Nil,'stj->tj_situaca == "L" .And. stj->tj_termino == "N"',;
					   IIf(MV_PAR25==1,'stj->tj_situaca == "L".And. stj->tj_termino == "N"',;
					   IIf(MV_PAR25==2,'stj->tj_situaca == "P".And. stj->tj_termino == "N"',;
									   'stj->tj_situaca <> "C".And. stj->tj_termino == "N"')))
	Local xk			:= 0
	Local xz			:= 0
	Local nContador 	:= 0
	Local cLoc
	Local lIdent		:= .F.
	Local nContLinha	:= 1
	Local nLinha		:= 0
	Local lCabStl1		:= .T.
	Local cT5Sequen		:= Space(TAMSX3("T5_SEQUENC")[1])
	Local cDescSint 	:= Space(TAMSX3("TTB_DESSIN")[1])
	Local cBloqPort 	:= Space(TAMSX3("TTB_BLOQPT")[1])
	Local nIncrLin 		:= 0
	Local lMNTR675G		:= ExistBlock("MNTR675G")
	Local cTitCodMod	:= FWX3Titulo( 'TPL_CODMOT' )
	Local cTitDesMot	:= FWX3Titulo( 'TPL_DESMOT' )
	Local cTitDtInic	:= SubStr( FWX3Titulo( 'TPL_DTINIC' ), 1, 8 )
	Local cTitDtFim		:= FWX3Titulo( 'TPL_DTFIM' )

	//Variaveis utilizada p/ criação da tabela temporária.
	Local aIND675 := {}
	Local oARQTR675

	Local cAlsSTL    := 'STL'
	Local nOrdSTL    := 3
	Local cSeekTL    := ''
	Local cWhileTL   := ''
	Local cLoopSTL   := '.F.'

	Private aBenseP	 := {}
	Private li		 := 4000 ,m_pag := 1
	Private nINDSTQ	 := 1
	Private cSEQSTL	 := If(lSEQSTL,"0  ",Str(0,2))

	Default nRecOs   := 0
	Default cAls990  := ''

	If Len(aMatSX1) > 0
		fModParSX1(cPerg,aMatSX1)
	EndIf

	If !IsInCallStack("MNTA990")
		If MV_PAR25==2
			cCONDICAO := 'stj->tj_situaca == "P" .And. stj->tj_termino == "N"'
		EndIf
		cCONDICAO += ' .And. stj->tj_ccusto >= MV_PAR07 .And. stj->tj_ccusto <= MV_PAR08 .And. ';
		+'stj->tj_centrab >= MV_PAR09 .And. stj->tj_centrab <= MV_PAR10 .And. ';
		+'stj->tj_codarea >= MV_PAR11 .And. stj->tj_codarea <= MV_PAR12 .And.';
		+'stj->tj_ordem >= MV_PAR13 .And. stj->tj_ordem <= MV_PAR14 .And. ';
		+'stj->tj_dtmpini >= MV_PAR15 .And. stj->tj_dtmpini <= MV_PAR16'
	Else

		cCONDICAO := 'stj->tj_situaca <> "C".And. stj->tj_termino == "N" .And. stj->tj_ccusto >= MV_PAR07 .And. stj->tj_ccusto <= MV_PAR08 .And. ';
		+'stj->tj_centrab >= MV_PAR09 .And. stj->tj_centrab <= MV_PAR10 .And. ';
		+'stj->tj_codarea >= MV_PAR11 .And. stj->tj_codarea <= MV_PAR12 .And.';
		+'stj->tj_ordem >= MV_PAR13 .And. stj->tj_ordem <= MV_PAR14'

		If !Empty( cAls990 )

			cAlsSTL := cAls990
			nOrdSTL := 7

		EndIf

	EndIf

	aDBFR675 := {{"ORDEM"   ,"C", 06,0},;
				 {"PLANO"   ,"C", 06,0},;
				 {"SERVICO" ,"C", 06,0},;
				 {"CODBEM"  ,"C", 16,0},;
				 {"CCUSTO"  ,"C", Len(STJ->TJ_CCUSTO),0},;
				 {"DATAOS"  ,"D", 08,0},;
				 {"DIFFDT"  ,"N", 08,0},;
				 {"BEMPAI"  ,"C", 16,0}}

	Do Case
		Case MV_PAR17 = 1  //Ordem
			aIND675 := {{"ORDEM"}}
		Case MV_PAR17 = 2  //Servico/Bem
			aIND675 := {{"SERVICO","CODBEM"}}
		Case MV_PAR17 = 3  //Centro Custo
			aIND675 := {{"CCUSTO"}}
		Case MV_PAR17 = 4  //Data da O.S.
			aIND675 := {{"DATAOS"}}
		OtherWise  		   // Servico/Bem Pai
			aIND675 := {{"SERVICO","BEMPAI"}}
	End Do

	//Criação Tabela Temporária
	oARQTR675 := NGFwTmpTbl(cTRB675, aDBFR675, aIND675)

	If FindFunction("NGSEQETA")
		nINDSTQ := NGSEQETA("STQ",nINDSTQ)
	EndIf

	lSEQETA := .F.
	DbSelectArea("STQ")
	If FieldPos("TQ_SEQETA") > 0
		lSEQETA := .T.
	EndIf

	If cDEPLANO == Nil .and. nRecOS == 0
		DbSelectArea("STI")
		DbSetOrder(01)
		dbSeek( cBchSTI + MV_PAR01 )
		DbSelectArea("STJ")
		DbSetOrder(03)
		dbSeek( cBchSTJ + MV_PAR01, .T. )
		ProcRegua(LastRec())
		While !EoF() .And. STJ->TJ_FILIAL == cBchSTJ .And.;
		STJ->TJ_PLANO >= MV_PAR01 .And. STJ->TJ_PLANO <= MV_PAR02
			IncProc()
			If &(cCONDICAO)
				MNTRW675GTRB()
			EndIf
			DbSelectArea("STJ")
			DbSkip()
		End
	Elseif cDEPLANO == Nil .and. nRecOS <> 0
		dbSelectArea("STJ")
		dbGoTo(nRecOS)
		MNTRW675GTRB()
	Else
		DbSelectArea("STJ")
		DbSetOrder(03)
		dbSeek( cBchSTJ + cDEPLANO, .T. )
		ProcRegua(LastRec())
		While !EoF() .And. STJ->TJ_FILIAL == cBchSTJ .And.;
		STJ->TJ_PLANO <= cATEPLANO

			IncProc()
			If &(cCONDICAO)

				nPosOs := aSCAN(aMATOS, {|x| x[1]+x[2] == STJ->TJ_PLANO+STJ->TJ_ORDEM})
				If nPosOs > 0
					nDiff := Nil
					If Len(aMATOS[nPosOs]) >= 3
						nDiff := aMATOS[nPosOs,3] //Indica a quantidade de dias que as datas da OS serão deslocadas
					EndIf
					MNTRW675GTRB( nDiff )
				EndIf

			EndIf
			DbSelectArea("STJ")
			DbSkip()
		EndDo
	EndIf

	DbSelectArea(cTRB675)
	DbGotop()
	ProcRegua(LastRec())
	While !EoF()
		IncProc()

		nPaG := 0
		DbSelectArea("STJ")
		DbSetOrder(01)
		If DbSeek( cBchSTJ + (cTRB675)->ORDEM + (cTRB675)->PLANO )

			If !Empty( cAls990 )

				cSeekTL  := STJ->TJ_ORDEM + STJ->TJ_PLANO + cSEQSTL
				cWhileTL := '(cAlsSTL)->( !EoF() ) .And. (cAlsSTL)->TL_ORDEM == STJ->TJ_ORDEM .And. (cAlsSTL)->TL_PLANO == STJ->TJ_PLANO ' +;
					' .And. (cAlsSTL)->TL_SEQRELA == ' + ValToSQL( cSEQSTL )
				cLoopSTL := '(cAlsSTL)->STATUS == 3'

			Else

				cSeekTL  := cBchSTL + STJ->TJ_ORDEM + STJ->TJ_PLANO + cSEQSTL
				cWhileTL := "STL->( !EoF() ) .And. cBchSTL == STL->TL_FILIAL .And. STJ->TJ_ORDEM == STL->TL_ORDEM .And. STJ->TJ_PLANO == STL->TL_PLANO .And." +;
					" IIf( lSEQSTL, STL->TL_SEQRELA == '0  ', STL->TL_SEQUENC == 0 )"

			EndIf

			DbSelectArea("STF")
			DbSetOrder(01)
			cSEQSTF := If(lSEQSTF,STJ->TJ_SEQRELA,STR(STJ->TJ_SEQUENC,3))
			dbSeek( cBchSTF + STJ->TJ_CODBEM + STJ->TJ_SERVICO + cSEQSTF )

			MNTW675Somal(oPrint)

			MNTW675Somal(oPrint)
			oPrint:Say(li,nHorz+900,STR0068,oFonTMN)

			MNTW675Somal(oPrint)
			MNTW675Somal(oPrint)
			oPrint:Line(li,nHorz+15,li,nHorz+2280)

			If STJ->TJ_TIPOOS == "B"
				cLoc := NGLocComp(STJ->TJ_CODBEM,'1') //Bem
			Else
				cLoc := NGLocComp(STJ->TJ_CODBEM,'2') //Localização
			EndIf

			If cLoc <> AllTrim(STJ->TJ_CODBEM)
				lIdent := .T.
			Else
				lIdent := .F.
			EndIf
			If lIdent .And. MV_PAR24 == 1
				cLoc := STR0104+": "+cLoc //"Localização"
				While Len(cLoc) > 0
					oPrint:Say(li,nHorz+15,SubStr(cLoc,1,077),oFontPN)
					cLoc := SubStr(cLoc,078)
					cLoc := If(!Empty(cLoc),Space(Len(STR0104+": ")),"")+cLoc //"Localização"
					MNTW675Somal(oPrint)
				EndDo
			EndIf
			If STJ->TJ_TIPOOS == "B"
				oPrint:Say(li,nHorz+015,STR0184+Space(1)+STJ->TJ_CODBEM; //"Bem......:"
				+Space(21-len(STJ->TJ_CODBEM))+NGSEEK('ST9',STJ->TJ_CODBEM,1,'ST9->T9_NOME'),oFonTPN)


				cPlaca := NGSEEK('ST9',STJ->TJ_CODBEM,1,'ST9->T9_PLACA')
				If !Empty(cPlaca)
					MNTW675Somal(oPrint)
					oPrint:Say(li,nHorz+15,STR0185+Space(1)+cPlaca,oFonTPN) //"Placa....:"
				EndIf

				MNTW675Somal(oPrint)
				oPrint:Say(li,nHorz+15,STR0205+" "+NGSEEK('ST9',STJ->TJ_CODBEM,1,'ST9->T9_PRIORID'),oFonTPN)
				nAtual := ST9->(Recno())
				If !Empty((cTRB675)->BEMPAI)
					MNTW675Somal(oPrint)

					oPrint:Say(li,nHorz+15,SubStr(STR0010,2,Len(STR0010))+" "+(cTRB675)->BEMPAI;
					+Space(21-len((cTRB675)->BEMPAI))+NGSEEK('ST9',(cTRB675)->BEMPAI,1,'ST9->T9_NOME'),oFonTPN)
					DbSelectArea("ST9")
					dbGoTo(nAtual)
				EndIf
			Else
				oPrint:Say(li,nHorz+015,STR0186+Space(1)+STJ->TJ_CODBEM; //"Código...:"
				+Space(21-len(STJ->TJ_CODBEM));
				+NGSEEK('TAF',"X2"+SubStr(STJ->TJ_CODBEM,1,3),7,"SubStr(TAF_NOMNIV,1,40)"),oFonTPN)
				MNTW675Somal(oPrint)
				oPrint:Say(li,nHorz+15,STR0205+" "+NGSEEK('TQB',STJ->TJ_CODBEM,1,'TQB->TQB_PRIORI'),oFonTPN)
			EndIf
			If !Empty(ST9->T9_LOCAL)
				MNTW675Somal(oPrint)
				oPrint:Say(li,nHorz+015,STR0105,oFonTPN) //"Local....:"
				oPrint:Say(li,nHorz+315,ST9->T9_LOCAL,oFonTPN)
			EndIf
			MNTW675Somal(oPrint)
			oPrint:Say(li,nHorz+15,SubStr(STR0011,2,Len(STR0011))+Space(1)+STJ->TJ_CCUSTO;
			+Space(21-len(STJ->TJ_CCUSTO))+NGSEEK('CTT',STJ->TJ_CCUSTO,1,'CTT->CTT_DESC01'),oFonTPN)

			MNTW675Somal(oPrint)
			If !Empty(STJ->TJ_CENTRAB)
				oPrint:Say(li,nHorz+15,SubStr(STR0012,2,Len(STR0012))+Space(1)+STJ->TJ_CENTRAB;
				+Space(21-len(STJ->TJ_CENTRAB))+NGSEEK('SHB',STJ->TJ_CENTRAB,1,'SHB->HB_NOME'),oFonTPN)
			EndIf

			// Impressao da Linha de Descrição (observação) do bem/veículo
			If mv_par03 == 1
				NGMEMORW675(STR0014,ST9->T9_DESCRIC,300,70,.F.) //"Descrição:"
				MNTW675Somal(oPrint)
			EndIf

			If STJ->TJ_TIPOOS == "B"
				If mv_par04 = 1
					lPrimeiro := .F.
					dbSelectArea("STB")
					dbSetOrder(01)
					dbSeek( cBchSTB + ST9->T9_CODBEM )
					nIncrLin := 0
					While !EoF() .And. STB->TB_CODBEM = ST9->T9_CODBEM .And.;
					STB->TB_FILIAL == cBchSTB
						MNTW675Somal(oPrint)
						If !lPrimeiro
							lPrimeiro = .T.
							oPrint:Say(li,nHorz+15,STR0013,oFonTPN) //"Detalhes.:"
						EndIf

						oPrint:Say(li+40+nIncrLin,nHorz+15,;
						SubStr(NGSEEK('TPR',STB->TB_CARACTE,1,'TPR->TPR_NOME'),1,40) + Space(1),oFonTPN)

						oPrint:Say(li+40+nIncrLin,nHorz+15,;
						If(STB->TB_CONDOP == "2", Space(42) + STR0190 + Space(2),""+Space(42))+;
						SubStr(STB->TB_DETALHE,1,15)+" "+;
						If(STB->TB_CONDOP == "2",Space(1) + STR0191 + Space(1) +;
						SubStr(STB->TB_INFO02,1,15),Space(1)) + Space(1) + SubStr(STB->TB_UNIDADE,1,2),oFonTPN)

						nIncrLin := nIncrLin+40

						dbSelectArea("STB")
						dbSkip()
					End
					MNTW675Somal(oPrint)
				EndIf
			EndIf

			nLinha := li+nIncrLin
			lQuebra := .F.
			For nContLinha := 1 to 5
				MNTW675Somal(oPrint)
			Next
			If lQuebra
				oPrint:Say(li,nHorz+900,STR0070,oFonTMN)
			Else
				li := nLinha
				MNTW675Somal(oPrint)
				MNTW675Somal(oPrint)
				oPrint:Say(li,nHorz+900,STR0070,oFonTMN)
			EndIf
			MNTW675Somal(oPrint)
			MNTW675Somal(oPrint)

			oPrint:Line( li, nHorz + 15, li, nHorz + 2280 )

			oPrint:Say(li,nHorz+15,SubStr(STR0016,2,Len(STR0016))+" "+STJ->TJ_SERVICO;
			+"  "+NGSEEK('ST4',STJ->TJ_SERVICO,1,'SubStr(ST4->T4_NOME,1,25)'),oFonTPN)

			If STJ->TJ_TIPOOS == "B"
				oPrint:Say(li,nHorz+1550,STR0017+"  "+Dtoc(STJ->TJ_DTULTMA),oFonTPN)//
			EndIf

			MNTW675Somal(oPrint)

			oPrint:Say(li,nHorz+15,SubStr(STR0018,2,Len(STR0018))+" ";
			+If(lSEQSTJ,STJ->TJ_SEQRELA,Str(STJ->TJ_SEQUENC,3)),oFonTPN)

			If STJ->TJ_TIPOOS == "B"
				oPrint:Say(li,nHorz+550,STR0019,oFonTPN)
			EndIf

			lPrinNom := .F.

			If NGCADICBASE('T4_TERCEIR','A','ST4',.F.)
				DbselectArea("ST4")
				DbSetOrder(01)
				If dbSeek( cBchST4 + STJ->TJ_SERVICO )
					If ST4->T4_TERCEIR = "S"
						lPOSR1 := NGCADICBASE('TJ_POSCPR1','A','STJ',.F.)
						lPOSR2 := NGCADICBASE('TJ_POSCPR2','A','STJ',.F.)

						If lPOSR1 .Or. lPOSR2
							If !Empty(STJ->TJ_POSCPR1)
								oPrint:Say(li,nHorz+850,STR0057+" "+STR0058+" 1 "+STR0059;
								+"  "+Str(STJ->TJ_POSCPR1,12),oFonTPN)
								lPrinNom := .T.

							ElseIf !Empty(STJ->TJ_POSCPR2)
								oPrint:Say(li,nHorz+850,STR0057+" "+STR0058+" 1 "+STR0059;
								+"  "+Str(STJ->TJ_POSCPR2,12),oFonTPN)
								lPrinNom := .T.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			DbSelectArea("STF")
			DbSetOrder(01)
			dbSeek( cBchSTF + STJ->TJ_CODBEM + STJ->TJ_SERVICO + cSEQSTF )
			If !lPrinNom .And. STJ->TJ_TIPOOS == "B"
				oPrint:Say(li,nHorz+950,STF->TF_NOMEMAN,oFonTPN)
			EndIf
			If STJ->TJ_PLANO == "000000"
				oPrint:Say(li,nHorz+950," "+STR0115,oFonTPN)
			EndIf

			MNTW675Somal(oPrint)

			oPrint:Say(li,nHorz+15,SubStr(STR0020,2,Len(STR0020))+" "+STJ->TJ_CODAREA;
			+Space(2)+NGSEEK('STD',STJ->TJ_CODAREA,1,'STD->TD_NOME'),oFonTPN)

			If STJ->TJ_TIPOOS == "B"
				If STF->TF_TIPACOM $ "CAF"
					oPrint:Say(li,nHorz+1550,STR0021+" "+Str(STF->TF_CONMANU,6),oFonTPN)
				EndIf
			EndIf

			MNTW675Somal(oPrint)

			oPrint:Say(li,nHorz+15,SubStr(STR0022,2,Len(STR0022))+" "+STJ->TJ_TIPO;
			+Space(5)+NGSEEK('STE',STJ->TJ_TIPO,1,'STE->TE_NOME'),oFonTPN)

			MNTW675Somal(oPrint)

			oPrint:Say(li,nHorz+15,SubStr(STR0065,1,Len(STR0065))+" "+STF->TF_DOCTO,oFonTPN)

			If STJ->TJ_TIPOOS == "B"
				MNTW675Somal(oPrint)
				oPrint:Say(li,nHorz+15  ,SubStr(STR0023,2,Len(STR0023))+" "+Str(STF->TF_TEPAANT,3),oFonTPN)
				oPrint:Say(li,nHorz+700 ,STF->TF_UNPAANT,oFonTPN)
				oPrint:Say(li,nHorz+800 ,Dtoc(STJ->TJ_DTPPINI),oFonTPN)
				oPrint:Say(li,nHorz+1000 ,STJ->TJ_HOPPINI,oFonTPN)

				oPrint:Say(li,nHorz+1400,STR0024+"  "+Str(STF->TF_TEPADEP,3),oFonTPN)
				oPrint:Say(li,nHorz+1750,STF->TF_UNPADEP,oFonTPN)
				oPrint:Say(li,nHorz+1950,Dtoc(STJ->TJ_DTPPFIM),oFonTPN)
				oPrint:Say(li,nHorz+2150,STJ->TJ_HOPPFIM,oFonTPN)

				// Linha da descricao da manutencao
				If mv_par05 == 1
					NGMEMORW675(STR0014,STF->TF_DESCRIC,300,70,.T.)
				EndIf

			EndIf

			aARTAREFAS := {}

			dbSelectArea( cAlsSTL )
			dbSetOrder( nOrdSTL )
			dbSeek( cSeekTL )

			While &( cWhileTL )

				If &( cLoopSTL )
					(cAlsSTL)->( dbSkip() )
					Loop
				EndIf

				DbSelectArea("ST5")
				DbSetOrder(1)
				If dbSeek( cBchST5 + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA + (cAlsSTL)->TL_TAREFA )
					cT5Sequen := cValToChar(STRZERO(T5_SEQUENC,TAMSX3("T5_SEQUENC")[1]))
				EndIf

				nPOS := aScan( aARTAREFAS,{ |x| x[1] == (cAlsSTL)->TL_TAREFA } )
				If nPOS = 0
					
					aAdd( aARTAREFAS, { (cAlsSTL)->TL_TAREFA, (cAlsSTL)->TL_DTINICI, (cAlsSTL)->TL_HOINICI,;
						(cAlsSTL)->TL_DTFIM, (cAlsSTL)->TL_HOFIM, cT5Sequen } )

				Else

					If (cAlsSTL)->TL_DTINICI < aARTAREFAS[nPOS][2]
						aARTAREFAS[nPOS][2] := (cAlsSTL)->TL_DTINICI
						aARTAREFAS[nPOS][3] := (cAlsSTL)->TL_HOINICI
					ElseIf (cAlsSTL)->TL_DTINICI == aARTAREFAS[nPOS][2] .And. (cAlsSTL)->TL_HOINICI < aARTAREFAS[nPOS][3]
						aARTAREFAS[nPOS][3] := (cAlsSTL)->TL_HOINICI
					EndIf

					If (cAlsSTL)->TL_DTFIM > aARTAREFAS[nPOS][4]
						aARTAREFAS[nPOS][4] := (cAlsSTL)->TL_DTFIM
						aARTAREFAS[nPOS][5] := (cAlsSTL)->TL_HOFIM
					ElseIf (cAlsSTL)->TL_DTFIM == aARTAREFAS[nPOS][4] .And. (cAlsSTL)->TL_HOFIM > aARTAREFAS[nPOS][5]
						aARTAREFAS[nPOS][5] := (cAlsSTL)->TL_HOFIM
					EndIf
					
					aARTAREFAS[nPOS][6] := cT5Sequen

				EndIf

				(cAlsSTL)->( dbskip() )
				
			End

			aARETAPAS := {}
			DbSelectArea("STQ")
			DbSetOrder(01)
			dbSeek( cBchSTQ + STJ->TJ_ORDEM + STJ->TJ_PLANO )
			While !EoF() .And. cBchSTQ == STQ->TQ_FILIAL .And.;
			STQ->TQ_ORDEM == STJ->TJ_ORDEM .And. STQ->TQ_PLANO == STJ->TJ_PLANO

				DbSelectArea("ST5")
				DbSetOrder(1)
				If dbSeek( cBchST5 + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA + STQ->TQ_TAREFA )
					cT5Sequen := cValToChar(STRZERO(T5_SEQUENC,TAMSX3("T5_SEQUENC")[1]))
				EndIf

				Aadd(aARETAPAS,{stq->tq_tarefa,stq->tq_etapa,stq->tq_seqeta,cT5Sequen})

				If Empty(aARTAREFAS)
					Aadd(aARTAREFAS,{STQ->TQ_TAREFA,STJ->TJ_DTMPINI,STJ->TJ_HOMPINI,;
					STJ->TJ_DTMPFIM,STJ->TJ_HOMPFIM,cT5Sequen})
				EndIf

				DbSelectArea("STQ")
				DbSkip()
			End While

			//If MV_PAR26 == 1
			// Adiciona no Array aARSINTOMA os
			// sintomas da O.S corrente...
			aARSINTOMA := {}
			NGdbAreaOrde("TTC", 1)
			dbSeek( cBchTTC + STJ->TJ_ORDEM + STJ->TJ_PLANO )
			While !Eof() .And.;
			cBchTTC == TTC->TTC_FILIAL .And.;
			TTC->TTC_ORDEM == STJ->TJ_ORDEM .And.;
			TTC->TTC_PLANO  == STJ->TJ_PLANO
				// Busca na TTB a descrição do Sintoma.
				If NGIFdbSeek('TTB', TTC->TTC_CDSINT, 1 )
					cDescSint := TTB->TTB_DESSIN
					If TTB->TTB_BLOQPT == 'S'
						cBloqPort := STR0063
					Else
						cBloqPort := STR0062
					EndIf
					aAdd(aARSINTOMA, { TTC->TTC_CDSINT,;
					cDescSint, cBloqPort  } )
				EndIf
				NGDBSELSKIP("TTC")
			EndDo
			If !Empty(aARSINTOMA)
				aSort( aARSINTOMA )
			EndIf

			If !Empty(aARETAPAS)
				If Len(aARETAPAS[1]) >= 4
					aSort(aARETAPAS ,,, {|x,y| x[4]+x[1]+x[2] < y[4]+y[1]+Y[2] })
				Else
					aSort(aARETAPAS ,,, {|x,y| x[1]+x[2] < y[1]+y[2] })
				EndIf
			EndIf

			If !Empty(aARTAREFAS)
				If Len(aARTAREFAS[1]) >= 6
					aSort(aARTAREFAS ,,, {|x,y| x[6]+x[1] < y[6]+y[1] })
				EndIf
			EndIf

			MNTW675Somal(oPrint)

			For xk := 1 To Len(aARTAREFAS)

				nLinha := li
				lQuebra := .F.
				For nContLinha := 1 to 5
					MNTW675Somal(oPrint)
				Next
				If lQuebra
					oPrint:Say(li,nHorz+900,STR0051,oFonTMN)
				Else
					li := nLinha
					MNTW675Somal(oPrint)
					MNTW675Somal(oPrint)
					oPrint:Say(li,nHorz+900,STR0051,oFonTMN)
				EndIf
				MNTW675Somal(oPrint)
				MNTW675Somal(oPrint)

				oPrint:Line( li, nHorz + 15, li, nHorz + 2280 )

				MNTW675Somal(oPrint)

				oPrint:Say(li,nHorz+15 ,SubStr(STR0026,2,Len(STR0026))+" "+aARTAREFAS[xk,1],oFonTPN)
				oPrint:Say( li, nHorz + 550 , STR0027 + ' ' + DToC( aARTAREFAS[xk,2] ) + ' ' + aARTAREFAS[xk,3], oFonTPN )

				oPrint:Say( li, nHorz + 1600, STR0028 + ' ' + DToC( aARTAREFAS[xk,4] ) + ' ' + aARTAREFAS[xk,5], oFonTPN )

				MNTW675Somal(oPrint)

				oPrint:Say(li,nHorz+550 ,STR0029,oFonTPN)
				oPrint:Say(li,nHorz+1600,STR0028,oFonTPN)

				MNTW675Somal(oPrint)

				If AllTrim(aARTAREFAS[xk][1]) == "0"
					oPrint:Say(li,nHorz+20,STR0030,oFonTPN)
				Else
					If !lUSATAR
						oPrint:Say(li,nHorz+20,NGSEEK('ST5',STJ->TJ_CODBEM+STJ->TJ_SERVICO+;
						If (lSEQSTJ,STJ->TJ_SEQRELA,Str(STJ->TJ_SEQUENC,3))+;
						aARTAREFAS[xk][1],1,'T5_DESCRIC'),oFonTPN)
					Else
						lCORRET := If(Val(stj->tj_plano) = 0,.T.,.F.)
						oPrint:Say(li,nHorz+20,NGNOMETAR(STJ->TJ_CODBEM+STJ->TJ_SERVICO+STJ->TJ_SEQRELA,;
						aARTAREFAS[xk][1]),oFonTPN)
					EndIf
				EndIf

				If MV_PAR06 == 1      // mostra etapas da tarefa
					DbSelectArea("STQ")
					DbSetOrder(nINDSTQ)
					If DbSeek( cBchSTQ + STJ->TJ_ORDEM + STJ->TJ_PLANO + aARTAREFAS[xk][1] )

						MNTW675Somal(oPrint)
						MNTW675Somal(oPrint)
						oPrint:Say(li,nHorz+900,STR0071,oFonTMN)
						MNTW675Somal(oPrint)
						MNTW675Somal(oPrint)

						oPrint:Line( li, nHorz + 20, li, nHorz + 2280 )

						While !EoF() .And. cBchSTQ == STQ->TQ_FILIAL .And.;
						STQ->TQ_ORDEM == STJ->TJ_ORDEM .And.;
						STQ->TQ_PLANO == STJ->TJ_PLANO .And.;
						STQ->TQ_TAREFA == aARTAREFAS[xk][1]

							NGWIMPETAPA(stq->tq_ok,stq->tq_etapa)

							// Deletar as etapas da array aARETAPAS
							nPOS2 := Ascan(aARETAPAS,{|x| x[1] == stq->tq_tarefa .And. x[2] == stq->tq_etapa})
							If nPOS2 > 0
								Adel(aARETAPAS,nPOS2)
								Asize(aARETAPAS,Len(aARETAPAS)-1)
							EndIf
							DbSelectArea("STQ")
							DbSkip()
						End While
					EndIf
				EndIf

				nLinha := li
				lQuebra := .F.
				For nContLinha := 1 to 3
					MNTW675Somal(oPrint)
				Next

				dbSelectArea( cAlsSTL )
				dbSetOrder( nOrdSTL )
				dbSeek( cSeekTL + aARTAREFAS[xk,1] )
				
				While &( cWhileTL ) .And. (cAlsSTL)->TL_TAREFA == aARTAREFAS[xk,1]

					If &( cLoopSTL )
						(cAlsSTL)->( dbSkip() )
						Loop
					EndIf

					If lCabStl1
						If lQuebra
							oPrint:Say(li,nHorz+900,STR0072,oFonTMN)
						Else
							li := nLinha
							MNTW675Somal(oPrint)
							MNTW675Somal(oPrint)
							oPrint:Say(li,nHorz+900,STR0072,oFonTMN)
						EndIf

						MNTW675Somal(oPrint)
						MNTW675Somal(oPrint)

						oPrint:Line( li, nHorz + 20, li, nHorz + 2280 )

						MNTW675Somal(oPrint)

						oPrint:Say(li,nHorz+30,STR0033,oFonTPN)	//Nome
						oPrint:Say(li,nHorz+168,STR0120,oFonTPN) 	//Codigo
						oPrint:Say(li,nHorz+1240,STR0094,oFonTPN)//Descricao

						MNTW675Somal(oPrint)

						oPrint:Say(li,nHorz+100,STR0107,oFonTPN)	//Data Prev.
						oPrint:Say(li,nHorz+470,STR0087,oFonTPN)	//Hora
						oPrint:Say(li,nHorz+720,STR0108,oFonTPN)	//Quant.
						oPrint:Say(li,nHorz+960,STR0109,oFonTPN)	//Consumo
						oPrint:Say(li,nHorz+1320,STR0110,oFonTPN)	//Unid.
						oPrint:Say(li,nHorz+1720,"Status",oFonTPN)	//Unid.

						MNTW675Somal(oPrint)
						MNTW675Somal(oPrint)
						lCabStl1 := .F.
					EndIf

					oPrint:Say( li, nHorz+30, SubStr( TIPREGBRW((cAlsSTL)->TL_TIPOREG), 1, 4 ), oFonTPN ) //Nome

					oPrint:Say( li, nHorz+168, SubStr( (cAlsSTL)->TL_CODIGO, 1, 30 ), oFonTPN ) //Codigo
					oPrint:Say(li,nHorz+1240,SubStr( NOMINSBRW((cAlsSTL)->TL_TIPOREG, (cAlsSTL)->TL_CODIGO, (cAlsSTL)->TL_LOJA ),1,30),oFonTPN) //Descricao

					MNTW675Somal(oPrint)

					oPrint:Say( li, nHorz + 100, DToC( (cAlsSTL)->TL_DTINICI ), oFonTPN ) //Data Prev
					oPrint:Say( li, nHorz + 470, (cAlsSTL)->TL_HOINICI, oFonTPN ) //Hora
					oPrint:Say( li, nHorz + 780, Str( (cAlsSTL)->TL_QUANREC, 3 ), oFonTPN ) //Quant.

					If (cAlsSTL)->TL_TIPOREG != 'P'
						oPrint:Say( li, nHorz + 905, Str( MNT675CONV( (cAlsSTL)->TL_QUANTID, IIf( Empty( (cAlsSTL)->TL_TIPOHOR ), Nil, (cAlsSTL)->TL_TIPOHOR ) ), 9, 2 ), oFonTPN ) //Consumo
					Else
						oPrint:Say( li, nHorz + 905, Str( (cAlsSTL)->TL_QUANTID, 9, 2 ), oFonTPN ) //Consumo
					EndIf

					oPrint:Say( li, nHorz + 1320, (cAlsSTL)->TL_UNIDADE, oFonTPN ) // Unid.
					oPrint:Say( li, nHorz + 1720, "Aplicado", oFonTPN ) // Unid.

					MNTW675Somal(oPrint)

					If !Empty( (cAlsSTL)->TL_OBSERVA )

						NGMEMORW675( Space( 1 ) + STR0066, (cAlsSTL)->TL_OBSERVA, 470, 60, .T. )
						MNTW675Somal( oPrint )

					EndIf

					MNTW675Somal(oPrint)

					(cAlsSTL)->( dbSkip() )

				End

				lCabStl1 := .T.

			Next xk

			// Imprime as etapas nao relacionadas com insumos
			If MV_PAR06 == 1      // mostra etapas da tarefa
				If Len(aARETAPAS) > 0
					nLinha := li
					lQuebra := .F.
					For nContLinha := 1 to 5
						MNTW675Somal(oPrint)
					Next
					If lQuebra
						oPrint:Say(li,nHorz+700,STR0071+" "+STR0073+" "+STR0072,oFonTMN)
					Else
						li := nLinha
						MNTW675Somal(oPrint)
						MNTW675Somal(oPrint)
						oPrint:Say(li,nHorz+700,STR0071+" "+STR0073+" "+STR0072,oFonTMN)
					EndIf
					MNTW675Somal(oPrint)
					MNTW675Somal(oPrint)

					oPrint:Line( li, nHorz + 10, li, nHorz + 2280 )

					If !Empty(aARETAPAS)
						If lSEQETA
							If Len(aARETAPAS[1]) >= 4
								aARCLASS := Asort(aARETAPAS,,,{|x,y| x[4]+x[1]+x[3]+x[2] < y[4]+y[1]+y[3]+y[2]})
							Else
								aARCLASS := Asort(aARETAPAS,,,{|x,y| x[1]+x[3]+x[2] < y[1]+y[3]+y[2]})
							EndIf
						Else
							If Len(aARETAPAS[1]) >= 4
								aARCLASS := Asort(aARETAPAS,,,{|x,y| x[4]+x[1]+x[2] < y[4]+y[1]+y[2]})
							Else
								aARCLASS := Asort(aARETAPAS,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
							EndIf
						EndIf
					EndIf

					cAUXTAR := 'XXXXXX'
					For xz := 1 To Len(aARCLASS)
						If cAUXTAR <> aARCLASS[xz][1]
							MNTW675Somal(oPrint)
							oPrint:Say(li,nHorz+15 ,STR0051,oFonTPN)
							oPrint:Say(li,nHorz+200,aARCLASS[xz,1],oFonTPN)

							If !lUSATAR
								oPrint:Say(li,nHorz+380,If(AllTrim(aARCLASS[xz,1]) == "0",STR0030,;
								NGSEEK('ST5',STJ->TJ_CODBEM+STJ->TJ_SERVICO;
								+If(lSEQSTJ,STJ->TJ_SEQRELA,Str(STJ->TJ_SEQUENC,3))+;
								aARCLASS[xz,1],1,'ST5->T5_DESCRIC')),oFonTPN)
							Else
								lCORRET := If(Val(stj->tj_plano) = 0,.T.,.F.)
								oPrint:Say(li,nHorz+380,NGNOMETAR(STJ->TJ_CODBEM+STJ->TJ_SERVICO+STJ->TJ_SEQRELA,;
								aARCLASS[xz][1]),oFonTPN)
							EndIf
						EndIf
						cAUXTAR := aARCLASS[xz][1]
						NGWIMPETAPA("  ",aARCLASS[xz][2])
					Next xz
				EndIf
			EndIf

			//If MV_PAR26 == 1
			If Len( aARSINTOMA ) > 0
				oPrint:Say( li, nHorz+900, STR0187, oFonTMN ) //"Sintomas"

				MNTW675Somal(oPrint)
				MNTW675Somal(oPrint)
				oPrint:Line( li, nHorz + 15, li, nHorz + 2280 )
				MNTW675Somal(oPrint)
				oPrint:Say(li,nHorz+030 ,STR0153, oFonTPN)
				oPrint:Say(li,nHorz+900 ,STR0154, oFonTPN)
				oPrint:Say(li,nHorz+1900, STR0155, oFonTPN)
				For xz := 1 To Len( aARSINTOMA )
					MNTW675Somal(oPrint)
					oPrint:Say(li,nHorz+030 ,aARSINTOMA[xz][1],oFonTPN)
					oPrint:Say(li,nHorz+900 ,aARSINTOMA[xz][2],oFonTPN)
					oPrint:Say(li,nHorz+01900 ,aARSINTOMA[xz][1],oFonTPN)
				Next xz
			EndIf
			//EndIf
			If MV_PAR18 = 2 .And. !Empty(STJ->TJ_OBSERVA)
				nLinha := li
				lQuebra := .F.
				If lQuebra
					oPrint:Say(li,nHorz+900,STR0119,oFonTMN)
				Else
					li := nLinha
					MNTW675Somal(oPrint)
					MNTW675Somal(oPrint)
					oPrint:Say(li,nHorz+900,STR0119,oFonTMN)
				EndIf

				// Impressao da Linha de Descricao da O.S.

				MNTW675Somal(oPrint)
				MNTW675Somal(oPrint)
				oPrint:Line( li, nHorz + 10, li, nHorz + 2280 )

				cOBSERVA := If(NGCADICBASE('TJ_MMSYP','A','STJ',.F.),;
				NGMEMOSYP(STJ->TJ_MMSYP),STJ->TJ_OBSERVA)
				nCol := 500
				nTOs := 65

				NGMEMORW675(STR0052,cOBSERVA,nCol,nTOs,.T.)  //"Descricao da O.S:"
			EndIf

			If mv_par19 = 2 .And. STJ->TJ_TIPOOS == "B"
				dbselectarea("STJ")
				nINDESTJ := IndexOrd()
				nRECNSTJ := Recno()
				aAPESCAR := NGPEUTIL(stj->tj_codbem)
				DbselectArea("STJ")
				DbsetOrder(nINDESTJ)
				DbGoto(nRECNSTJ)
				If Len(aAPESCAR) > 0
					MNTW675Somal(oPrint)
					MNTW675Somal(oPrint)
					oPrint:Say(li,nHorz+900,STR0074,oFonTMN)// "Peças de Reposição"
					MNTW675Somal(oPrint) // inc linha
					MNTW675Somal(oPrint)
					oPrint:Line( li, nHorz + 10, li, nHorz + 2280 )
					MNTW675Somal(oPrint)

					oPrint:Say(li,nHorz+15,STR0085,oFonTPN) //"Codigo"
					oPrint:Say(li,nHorz+880,STR0094,oFonTPN) //"Descricao"
					MNTW675Somal(oPrint)
					oPrint:Say(li,nHorz+1030,STR0098,oFonTPN) //"Dt.U.Uso"
					oPrint:Say(li,nHorz+1260,STR0099,oFonTPN) //"Contador"
					oPrint:Say(li,nHorz+1540,STR0100,oFonTPN) //"Proxima"
					oPrint:Say(li,nHorz+1780,STR0101,oFonTPN) //"Dt.Prox."

					For xk := 1 To Len(aAPESCAR)
						MNTW675Somal(oPrint)
						oPrint:Say(li,nHorz+15 ,aAPESCAR[xk,1],oFonTPN)
						oPrint:Say(li,nHorz+880,Substr(NGSEEK("SB1",aAPESCAR[xk,1],1,"B1_DESC"),1,24),oFonTPN)
						MNTW675Somal(oPrint)
						If !Empty(aAPESCAR[xk,2])
							oPrint:Say(li,nHorz+1030,Dtoc(aAPESCAR[xk,2]),oFonTPN)
						EndIf

						If !Empty(aAPESCAR[xk,4])
							oPrint:Say(li,nHorz+1240,Str(aAPESCAR[xk,4],9),oFonTPN)
						EndIf

						If !Empty(aAPESCAR[xk,6])
							oPrint:Say(li,nHorz+1500,Str(aAPESCAR[xk,6],9),oFonTPN)
						EndIf

						If !Empty(aAPESCAR[xk,8])
							oPrint:Say(li,nHorz+1780,Dtoc(aAPESCAR[xk,8]),oFonTPN)
						EndIf

						If !Empty(aAPESCAR[xk,5]) .Or. !Empty(aAPESCAR[xk,7]) .Or.;
						!Empty(aAPESCAR[xk,9])
							MNTW675Somal(oPrint)
							oPrint:Say(li,nHorz+500,STR0055,oFonTPN)

							If !Empty(aAPESCAR[xk,5])
								oPrint:Say(li,nHorz+1250,Str(aAPESCAR[xk,5],9),oFonTPN)
							EndIf
							If !Empty(aAPESCAR[xk,7])
								oPrint:Say(li,nHorz+1500,Str(aAPESCAR[xk,7],9),oFonTPN)
							EndIf
							If !Empty(aAPESCAR[xk,9])
								oPrint:Say(li,nHorz+1780,Dtoc(aAPESCAR[xk,9]),oFonTPN)
							EndIf
						EndIf
					Next xk
				EndIf

				Dbselectarea("STJ")
				DbSetOrder(nINDESTJ)
				Dbgoto(nRECNSTJ)

			EndIf


			nLinha := li
			lQuebra := .F.
			For nContLinha := 1 to 5
				MNTW675Somal(oPrint)
			Next
			If lQuebra
				oPrint:Say(li,nHorz+900,STR0075,oFonTMN)
			Else
				li := nLinha
				MNTW675Somal(oPrint)
				MNTW675Somal(oPrint)
				oPrint:Say(li,nHorz+900,STR0075,oFonTMN)
			EndIf
			MNTW675Somal(oPrint)
			MNTW675Somal(oPrint)

			oPrint:Line( li, nHorz + 10, li, nHorz + 2280 )
			MNTW675Somal(oPrint)
			oPrint:Say(li,nHorz+17 ,SubStr(STR0041,2,Len(STR0041)-2),oFonTPN)

			For nContador := 1 to 5
				MNTW675Somal(oPrint)
				oPrint:Say(li,nHorz+15,"  ____________  ____________________  _____________________  __________________ ",oFonTPN)
			Next

			// Motivos de Atraso
			If nTImpr = 4
				DbSelectArea("TPL")
				DbSetOrder(01)
				If DbSeek( cBchTPL + STJ->TJ_ORDEM )

					MNTW675Somal(oPrint)
					MNTW675Somal(oPrint)
					oPrint:Say(li,nHorz+800,NGSX2NOME("TPL"),oFonTMN)

					MNTW675Somal(oPrint)
					MNTW675Somal(oPrint)
					oPrint:Line( li, nHorz + 10, li, nHorz + 2280 )

					oPrint:Say(li,nHorz+15,cTitCodMod,oFonTPN)
					oPrint:Say(li,nHorz+250,cTitDesMot,oFonTPN)
					oPrint:Say(li,nHorz+1340,cTitDtInic,oFonTPN)
					oPrint:Say(li,nHorz+1645,STR0087,oFonTPN)
					oPrint:Say(li,nHorz+1805,cTitDtFim,oFonTPN)
					oPrint:Say(li,nHorz+2100,STR0087,oFonTPN)

					DbSelectArea("TPL")
					While !EoF() .And. cBchTPL == TPL->TPL_FILIAL .And.;
					TPL->TPL_ORDEM == STJ->TJ_ORDEM
						MNTW675Somal(oPrint)
						oPrint:Say(li,nHorz+15,TPL->TPL_CODMOT,oFonTPN)
						oPrint:Say(li,nHorz+250,SubStr(NGSEEK("TPJ",TPL->TPL_CODMOT,1,'TPJ_DESMOT'),1,35),oFonTPN)
						oPrint:Say(li,nHorz+1340,Dtoc(TPL->TPL_DTINIC),oFonTPN)
						oPrint:Say(li,nHorz+1645,TPL->TPL_HOINIC,oFonTPN)
						oPrint:Say(li,nHorz+1805,Dtoc(TPL->TPL_DTFIM) ,oFonTPN)
						oPrint:Say(li,nHorz+2100,TPL->TPL_HOFIM ,oFonTPN)
						DbSelectArea("TPL")
						DbSkip()
					End
				EndIf
			EndIf


			MNTW675Somal(oPrint)
			MNTW675Somal(oPrint)
			oPrint:Line( li, nHorz + 10, li, nHorz + 2280 )
			MNTW675Somal(oPrint)
			MNTW675Somal(oPrint)

			oPrint:Say(li,nHorz+15 ,SubStr(STR0042,2,Len(STR0042)-2),oFonTPN)

			MNTW675Somal(oPrint)

			oPrint:Say(li,nHorz+15 ,SubStr(STR0043,2,Len(STR0043)-2),oFonTPN)

			If lMNTR675G //Parâmetro {1} indica que o relatório é do MNTR675
				ExecBlock("MNTR675G",.F.,.F.,{1})
			EndIf

			//Lista banco do conhecimento
			If MV_PAR20 == 2
				fPrintBco( MV_PAR22 )
			EndIf

		EndIf

		DbSelectArea(cTRB675)

		dbSkip()
		li := 4000

	End While

	If GetNewPar("MV_NGMNTCC","N") == "S" //Ve se utiliza template Construção Civil para impressão de detalhes material rodante
		MNTR688MR(oPrint,STJ->TJ_CODBEM)
	EndIf

	//Deleta o arquivo temporario fisicamente
	oARQTR675:Delete()

	oPrint:EndPage()
	RetIndex('STJ')
	Set Filter To
	DbSetOrder(01)

	If MV_PAR22 = 1 //Em Disco
		oPrint:Preview()
	Else // Via Spool
		oPrint:Print()
	EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³MNTW675SomaL³ Autor ³ In cio Luiz Kolling   ³ Data ³28/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Incrementa Linha,Cabecalho e Salto de Pagina                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR675                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function MNTRW675GTRB( nDiffDias )
	DbSelectArea(cTRB675)
	(cTRB675)->(DbAppend())
	(cTRB675)->ORDEM   := STJ->TJ_ORDEM
	(cTRB675)->PLANO   := STJ->TJ_PLANO
	(cTRB675)->SERVICO := STJ->TJ_SERVICO
	(cTRB675)->CODBEM  := STJ->TJ_CODBEM
	(cTRB675)->CCUSTO  := STJ->TJ_CCUSTO
	(cTRB675)->DATAOS  := STJ->TJ_DTMPINI
	If ValType(nDiffDias) == "N"
		(cTRB675)->DIFFDT := nDiffDias
	EndIf
	nPosBP := aSCAN(aBenseP,{|x| x[1] == (cTRB675)->CODBEM})
	If nPosBP = 0
		(cTRB675)->BEMPAI := NGBEMPAI((cTRB675)->CODBEM)
		Aadd(aBenseP,{(cTRB675)->CODBEM,(cTRB675)->BEMPAI})
	Else
		(cTRB675)->BEMPAI := aBenseP[nPosBP,2]
	EndIf
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NGWIMPETAPA³ Autor ³ NG Informatica Ltda   ³ Data ³   /06/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Imprime a etapas                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR675                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function NGWIMPETAPA(cVOK,cVETAPA)
	If Empty(cVOK)
		//Realizar a quebra de página para exibir corretamente Etapas Genéricas
		If li > 3010
			li := 3201
		EndIf
		MNTW675Somal(oPrint)
		oPrint:Say(li,nHorz+20,cVETAPA,oFonTPN)
		dbSelectArea("TPA")
		dbSetOrder(01)
		If dbSeek( cBchTPA + cVETAPA )
			NGMEMOEW675(TPA->TPA_DESCRI,150,70)
			If MV_PAR23 == 1
				MNT675OPE(oPrint,cVETAPA)
			EndIf
		EndIf
	EndIf
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NGMEMOEW675³ Autor ³In cio Luiz Kolling    ³ Data ³29/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Imprime campo memo etapa                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR675                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function NGMEMOEW675(cDESCRI,nCOLU,nTAM)
	Local lLin
	nLinhasMemo := MLCOUNT(AllTrim(cDESCRI),nTAM)
	For lLin := 1 To nLinhasMemo
		If !Empty((MemoLine(cDESCRI,nTAM,lLin)))
			If lLin > 1
				MNTW675Somal(oPrint)
			EndIf
			oPrint:Say(li,nHorz+nCOLU+60,(MemoLine(cDESCRI,nTAM,lLin)),oFonTPN)
		EndIf
	Next LinhaCorrente
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMEMORW675
Imprime campo memo ( especifica p/ mntr675 )

@type function

@source MNTR675.prx

@author Inácio Luiz Kolling
@since 13/08/2002

@param cTITULO	, Caracter	, Titulo do relátorio.
@param cDESCRI	, Caracter	, Descrição do relatório.
@param nCOLU	, Numérico	, Numero de colunas.
@param nTAM		, Numérico	, Tamanho do relatório.
@param lSOMLI	, Lógico	, Determina se pula linha.

@sample NGMEMORW675("Retorno","Descrição",1,2,.T.)

@return Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
User Function NGMEMORW675(cTITULO,cDESCRI,nCOLU,nTAM,lSOMLI)
	Local lPrimeiro := .T.
	Local lSOMEILI  := lSOMLI,linhacorrente
	nLinhasMemo := MLCOUNT(cDESCRI,nTAM)
	For LinhaCorrente := 1 To nLinhasMemo
		If lSOMEILI
			MNTW675Somal(oPrint)
			lSOMEILI := .T.
		Else
			If Len(AllTrim(MemoLine(cDESCRI,nTAM,LinhaCorrente))) > 0
				MNTW675Somal(oPrint)
			EndIf
		EndIf
		If lPrimeiro
			If !Empty(cTITULO)
				oPrint:Say(li+nTAM,nHorz+15 ,cTITULO,oFonTPN)
			EndIf
			lPrimeiro := .F.
		EndIf
		oPrint:Say(li+nTAM,nHorz+nCOLU,(MemoLine(cDESCRI,nTAM,LinhaCorrente)),oFonTPN)
		//Caso seja a ultima linha que será impressa.
		If  LinhaCorrente == nLinhasMemo
			MNTW675Somal(oPrint)
			Exit
		EndIf
	Next
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³MNTW675SomaL³ Autor ³ In cio Luiz Kolling   ³ Data ³28/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Incrementa Linha,Cabecalho e Salto de Pagina                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR675                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function MNTW675Somal(oPrint)
	Private cNomFil  := Trim( SM0->M0_FILIAL )

	li += 50
	If li > 3100
		lQuebra := .T.
		li := 100
		nPaG ++
		oPrint:EndPage()
		oPrint:StartPage()
		oPrint:Box(li,nHorz+10,3200,nHorz+2280)
		li += 20
		//
		If File(cLogo)
			oPrint:SayBitMap(li,nHorz+40,cLogo,250,73)
		EndIf

		oPrint:Say(li,nHorz+380,STR0006+"  "+STJ->TJ_ORDEM,oFonTMN)
		oPrint:Say( Li-10, nHorz+2040, STR0076 + ' ' + Str( nPag, 2 ), oFonTPN )

		If !Empty(stj->tj_solici)
			Li += 90
			oPrint:Say(li,nHorz+15,STR0056+"  "+STJ->TJ_SOLICI+Space(5)+STR0095+; //"Solicitante: "
			SubStr(UsrRetName(NGSEEK('TQB',STJ->TJ_SOLICI,1,'TQB->TQB_CDSOLI')),1,15))
			Li += 60
			oPrint:Say(li,nHorz+15,STR0096+; //"Dt.Solic.: "
			DtoC(NGSEEK('TQB',STJ->TJ_SOLICI,1,'TQB->TQB_DTABER'))+;
			Space(4)+STR0097+; //"Hr.Solic.: "
			NGSEEK('TQB',STJ->TJ_SOLICI,1,'TQB->TQB_HOABER'),oFonTPN)
		EndIf

		Li += 100

		oPrint:Say( Li, nHorz+15, STR0204 + cNomFil, oFonTPN ) // Filial:

		Li += 60

		oPrint:Say(li,nHorz+15 ,STR0044+" "+Dtoc(STJ->TJ_DTMPINI+(cTRB675)->DIFFDT)+" "+STJ->TJ_HOMPINI,oFonTPN)
		oPrint:Say(li,nHorz+750,STR0045+" "+Dtoc(STJ->TJ_DTMPFIM+(cTRB675)->DIFFDT)+" "+STJ->TJ_HOMPFIM,oFonTPN)
		oPrint:Say(li,nHorz+1400,STR0046+" "+Dtoc(Date())+" "+SubStr(Time(),1,5),oFonTPN)

		Li += 60
		oPrint:Say(li,nHorz+15,SubStr(STR0047,2,Len(STR0047))+" "+STJ->TJ_PLANO,oFonTPN)

		If STJ->TJ_TIPOOS == "B"
			oPrint:Say(li,nHorz+1650,STR0048+" "+STJ->TJ_PRIORID,oFonTPN)
		EndIf

		Li += 50
		oPrint:Say(li,nHorz+15,SubStr(STR0049,2,Len(STR0049))+" "+;
		NGSEEK('STI',STJ->TJ_PLANO,1,'SubStr(STI->TI_DESCRIC,1,39)'),oFonTPN)

		If NGSEEK('ST9',STJ->TJ_CODBEM,1,'ST9->T9_TEMCONT') <> "N"
			Li += 50
			oPrint:Say(li,nHorz+15,"1º "+STR0021+AllTrim(Str(STJ->TJ_POSCONT)),oFonTPN)  //"Contador:"
			If NGIFDBSEEK("TPE",STJ->TJ_CODBEM,1)
				Li += 50
				oPrint:Say(li,nHorz+15,"2º "+STR0021+AllTrim(Str(STJ->TJ_POSCON2)),oFonTPN) //"Contador:"
			EndIf
		EndIf

		Li += 100
	EndIf
Return

//----------------------------------------------------------------------------------------
/*/{Protheus.doc} R675Imp
Chamada para impressão da ordem de serviço.
@type function

@author Inácio Luiz Kolling
@since 13/11/1995

@param lEnd     , boolean, Indica se o processo  foi finalizado.
@param wnRel    , boolean, Nome do relatório.
@param titulo   , string , Titulo do relatório. 
@param tamanho  , string , Tamanho do relatório.
@param cDEPLANO , string , Indica código inicio do filtro de plano de manutenção.
@param cATEPLANO, string , Indica código final do filtro de plano de manutenção.
@param aMATOS   , array  , Matriz de O.S.
@param [nRecOs] , numeric, RECNO para posicionamento na ordem de serviço.
@param [cAls990], string , Alias temporário para insumos da rotina MNTA990.

@return
/*/
//----------------------------------------------------------------------------------------
Static Function R675Imp( lEnd, wnRel, titulo, tamanho, cDEPLANO, cATEPLANO,;
	aMATOS, nRecOS, cAls990 )

	Local xk            := 0
	Local xz            := 0
	Local ncontador     := 0
	Local nPosOs        := 0
	Local nExists       := 0
	Local cWhere        := "%%"
	Local aBenseP		:= {}
	Local lIdent		:= .F.
	Local lCabStl1		:= .T.
	Local lMNTR6751		:= ExistBlock("MNTR6751")
	Local lCall990      := FwIsInCallStack( 'MNTA990' )
	Local nColNomMan	:= 79 //Usado para definir a coluna de impressão do nome da Manutenção, na seção de Manutenção
	Local cT5Sequen		:= Space(TAMSX3("T5_SEQUENC")[1])
	Local cTitCodMod	:= FWX3Titulo( 'TPL_CODMOT' )
	Local cTitDesMot	:= FWX3Titulo( 'TPL_DESMOT' )
	Local cTitDtInic	:= SubStr( FWX3Titulo( 'TPL_DTINIC' ), 1, 8 )
	Local cTitDtFim		:= SubStr( FWX3Titulo( 'TPL_DTFIM' ), 1, 8 )
	Local cAlsSTL       := 'STL'
	Local cAlsSTJ       := ''
	Local nOrdSTL       := 3
	Local cSeekTL       := ''
	Local cWhileTL      := ''
	Local cLoopSTL      := '.F.'

	//Variaveis utilizada p/ criação da tabela temporária.
	Local aIND675       := {}
	Local oARQTR675     := Nil

	Private li		    := 80
	Private m_pag	    := 1
	Private nomeprog    := "MNTR675"
	Private ntipo	    := IIF(aReturn[4]==1,15,18)
	Private nINDSTQ	    := 1
	Private cNomFil	    := SM0->M0_FILIAL

	Default nRecOs      := 0
	Default cAls990     := ''

	If Len(aMatSX1) > 0
		fModParSX1(cPerg,aMatSX1)
	EndIf

	

	aDBFR675 := {{"ORDEM"  , "C", 06, 0},;
				 {"PLANO"  , "C", 06, 0},;
				 {"SERVICO", "C", 06, 0},;
				 {"CODBEM" , "C", 16, 0},;
				 {"CCUSTO" , "C", Len(STJ->TJ_CCUSTO), 0},;
				 {"DATAOS" , "D", 08, 0},;
				 {"DIFFDT" , "N", 08, 0},;
				 {"BEMPAI" , "C", 16, 0}}

	Do Case
		Case MV_PAR17 == 1  //Ordem
			aIND675 := {{"ORDEM"}}
		Case MV_PAR17 == 2  //Servico/Bem
			aIND675 := {{"SERVICO","CODBEM"}}
		Case MV_PAR17 == 3  //Centro Custo
			aIND675 := {{"CCUSTO"}}
		Case MV_PAR17 == 4  //Data da O.S.
			aIND675 := {{"DATAOS"}}
		OtherWise  		   // Servico/Bem Pai
			aIND675 := {{"SERVICO","BEMPAI"}}
	End Do

	//Criação Tabela Temporária
	oARQTR675 := NGFwTmpTbl(cTRB675, aDBFR675, aIND675)

	If FindFunction("NGSEQETA")
		nINDSTQ := NGSEQETA("STQ",nINDSTQ)
	EndIf

	Store " " To Cabec1,Cabec2

	If cDEPLANO == Nil
	
		If nRecOS == 0
		
			cAlsSTJ := GetNextAlias()

			If lCall990
				cWhere := "%AND STJ.TJ_SITUACA <> 'C'%"
			Else
				cWhere := "%AND ( STJ.TJ_DTMPINI BETWEEN " + ValToSQL( MV_PAR15 ) + " AND " + ValToSQL( MV_PAR16 ) + " ) AND "
				cWhere += IIf( MV_PAR25 == 1,"STJ.TJ_SITUACA = 'L'", IIf( MV_PAR25 == 2, "STJ.TJ_SITUACA = 'P'", "STJ.TJ_SITUACA <> 'C'" ) ) + "%"
			EndIf

			BeginSQL Alias cAlsSTJ

				SELECT
					STJ.TJ_ORDEM  ,
					STJ.TJ_PLANO  ,
					STJ.TJ_SERVICO,
					STJ.TJ_CODBEM ,
					STJ.TJ_CCUSTO ,
					STJ.TJ_DTMPINI
				FROM
					%table:STJ% STJ
				WHERE
					STJ.TJ_FILIAL = %exp:cBchSTJ% AND
					STJ.TJ_TERMINO = 'N'          AND
					( STJ.TJ_PLANO   BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% ) AND
					( STJ.TJ_CCUSTO  BETWEEN %exp:MV_PAR07% AND %exp:MV_PAR08% ) AND
					( STJ.TJ_CENTRAB BETWEEN %exp:MV_PAR09% AND %exp:MV_PAR10% ) AND
					( STJ.TJ_CODAREA BETWEEN %exp:MV_PAR11% AND %exp:MV_PAR12% ) AND
					( STJ.TJ_ORDEM   BETWEEN %exp:MV_PAR13% AND %exp:MV_PAR14% ) AND
					STJ.%NotDel%
					%exp:cWhere%

			EndSQL

			While (cAlsSTJ)->( !EoF() )
				
				RecLock( cTRB675, .T. )
					
				(cTRB675)->ORDEM   := (cAlsSTJ)->TJ_ORDEM
				(cTRB675)->PLANO   := (cAlsSTJ)->TJ_PLANO
				(cTRB675)->SERVICO := (cAlsSTJ)->TJ_SERVICO
				(cTRB675)->CODBEM  := (cAlsSTJ)->TJ_CODBEM
				(cTRB675)->CCUSTO  := (cAlsSTJ)->TJ_CCUSTO
				(cTRB675)->DATAOS  := SToD( (cAlsSTJ)->TJ_DTMPINI )
				
				If ( nPosBP := aScan( aBenseP, { |x| x[1] == (cTRB675)->CODBEM } ) ) == 0
					(cTRB675)->BEMPAI := NGBEMPAI((cTRB675)->CODBEM)
					Aadd(aBenseP,{(cTRB675)->CODBEM,(cTRB675)->BEMPAI})
				Else
					(cTRB675)->BEMPAI := aBenseP[nPosBP,2]
				EndIf

				(cAlsSTJ)->( MsUnLock() )
				
				(cAlsSTJ)->( dbSkip() )

			End

			(cAlsSTJ)->( dbCloseArea() )

		Else
			
			dbSelectArea("STJ")
			dbGoTo(nRecOS)
			DbSelectArea(cTRB675)
			(cTRB675)->(DbAppend())
			(cTRB675)->ORDEM   := STJ->TJ_ORDEM
			(cTRB675)->PLANO   := STJ->TJ_PLANO
			(cTRB675)->SERVICO := STJ->TJ_SERVICO
			(cTRB675)->CODBEM  := STJ->TJ_CODBEM
			(cTRB675)->CCUSTO  := STJ->TJ_CCUSTO
			(cTRB675)->DATAOS  := STJ->TJ_DTMPINI

			nPosBP := aSCAN(aBenseP,{|x| x[1] == (cTRB675)->CODBEM})
			If nPosBP = 0
				(cTRB675)->BEMPAI := NGBEMPAI((cTRB675)->CODBEM)
				Aadd(aBenseP,{(cTRB675)->CODBEM,(cTRB675)->BEMPAI})
			Else
				(cTRB675)->BEMPAI := aBenseP[nPosBP,2]
			EndIf

		EndIf
		
	Else

		cAlsSTJ := GetNextAlias()

		If lCall990
			cWhere := "%AND STJ.TJ_SITUACA <> 'C'%"
		Else
			cWhere := "%AND ( STJ.TJ_DTMPINI BETWEEN " + ValToSQL( MV_PAR15 ) + " AND " + ValToSQL( MV_PAR16 ) + " ) AND "
			cWhere += IIf( MV_PAR25 == 1,"STJ.TJ_SITUACA = 'L'", IIf( MV_PAR25 == 2, "STJ.TJ_SITUACA = 'P'", "STJ.TJ_SITUACA <> 'C'" ) ) + "%"
		EndIf

		BeginSQL Alias cAlsSTJ

			SELECT
				STJ.TJ_ORDEM  ,
				STJ.TJ_PLANO  ,
				STJ.TJ_SERVICO,
				STJ.TJ_CODBEM ,
				STJ.TJ_CCUSTO ,
				STJ.TJ_DTMPINI
			FROM
				%table:STJ% STJ
			WHERE
				STJ.TJ_FILIAL  = %exp:cBchSTJ% AND
				STJ.TJ_TERMINO = 'N'           AND
				( STJ.TJ_PLANO   BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% ) AND
				( STJ.TJ_CCUSTO  BETWEEN %exp:MV_PAR07% AND %exp:MV_PAR08% ) AND
				( STJ.TJ_CENTRAB BETWEEN %exp:MV_PAR09% AND %exp:MV_PAR10% ) AND
				( STJ.TJ_CODAREA BETWEEN %exp:MV_PAR11% AND %exp:MV_PAR12% ) AND
				( STJ.TJ_ORDEM   BETWEEN %exp:MV_PAR13% AND %exp:MV_PAR14% ) AND
				STJ.%NotDel%
				%exp:cWhere%

		EndSQL
		
		While (cAlsSTJ)->( !EoF() )

			If ( nPosOs := aScan( aMATOS, { |x| x[1] + x[2] == (cAlsSTJ)->TJ_PLANO + (cAlsSTJ)->TJ_ORDEM } ) ) > 0
				
				RecLock( cTRB675, .T. )
				
				(cTRB675)->ORDEM   := (cAlsSTJ)->TJ_ORDEM
				(cTRB675)->PLANO   := (cAlsSTJ)->TJ_PLANO
				(cTRB675)->SERVICO := (cAlsSTJ)->TJ_SERVICO
				(cTRB675)->CODBEM  := (cAlsSTJ)->TJ_CODBEM
				(cTRB675)->CCUSTO  := (cAlsSTJ)->TJ_CCUSTO
				(cTRB675)->DATAOS  := SToD( (cAlsSTJ)->TJ_DTMPINI )
				
				If Len( aMATOS[nPosOs] ) >= 3 .And. ValType( aMATOS[nPosOs,3] ) == 'N' 
					(cTRB675)->DIFFDT := aMATOS[nPosOs,3]
				EndIf

				If ( nPosBP := aScan( aBenseP, { |x| x[1] == (cTRB675)->CODBEM } ) ) == 0
					(cTRB675)->BEMPAI := NGBEMPAI( (cTRB675)->CODBEM )
					aAdd( aBenseP, { (cTRB675)->CODBEM, (cTRB675)->BEMPAI } )
				Else
					(cTRB675)->BEMPAI := aBenseP[nPosBP,2]
				EndIf

				(cAlsSTJ)->( MsUnLock() )

			EndIf

			(cAlsSTJ)->( dbSkip() )

		End

		(cAlsSTJ)->( dbCloseArea() )

	EndIf
	
	dbSelectArea( cTRB675 )
	dbGoTop()
	
	SetRegua( (cTRB675)->( LastRec() ) )
	
	While ( cTRB675 )->( !EoF() )

		IncRegua()

		DbSelectArea("STJ")
		DbSetOrder(01)
		If dbSeek( cBchSTJ + (cTRB675)->ORDEM + (cTRB675)->PLANO )
			DbSelectArea("STF")
			DbSetOrder(01)
			dbSeek( cBchSTF + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA )

			SomaR765()
			@ Li,000 Psay STR0008 //"|------------------------------Bem/Localização---------------------------------|"
			SomaR765()

			If STJ->TJ_TIPOOS == "B"
				cLoc := NGLocComp(STJ->TJ_CODBEM,'1') //Bem
			Else
				cLoc := NGLocComp(STJ->TJ_CODBEM,'2') //Localização
			EndIf

			If cLoc <> AllTrim(STJ->TJ_CODBEM)
				lIdent := .T.
			Else
				lIdent := .F.
			EndIf
			If lIdent .And. MV_PAR24 == 1
				cLoc := STR0104+": "+cLoc //"Localização"
				While Len(cLoc) > 0
					@ LI,000 PSAY "|"+SubStr(cLoc,1,077)
					@ Li,079 Psay "|"
					cLoc := SubStr(cLoc,078)
					cLoc := If(!Empty(cLoc),Space(Len(STR0104+": ")),"")+cLoc //"Localização"
					SomaR765()
				EndDo
			EndIf
			@ Li,000 Psay STR0188 //"|Código...:"
			@ Li,012 Psay SubStr(STJ->TJ_CODBEM,1,20) Picture "@!S(39)"
			If STJ->TJ_TIPOOS == "B"
				@ Li,032 Psay SubStr( NGSEEK('ST9',STJ->TJ_CODBEM,1,'ST9->T9_NOME'),1,40 ) Picture "@!S(39)"
				@ Li,079 Psay "|"

				cPlaca := NGSEEK('ST9',STJ->TJ_CODBEM,1,'ST9->T9_PLACA')
				If !Empty(cPlaca)
					// Linha da Placa
					SomaR765()
					@ Li,000 Psay STR0189 //"|Placa....:"
					@ Li,012 Psay cPlaca
					If Empty(ST9->T9_LOCAL) .And. STJ->TJ_TIPOOS == "B"
						@ Li,065 Psay STR0009 //"Prioridade:"
						@ Li,073 Psay NGSEEK('ST9',STJ->TJ_CODBEM,1,'ST9->T9_PRIORID')
					EndIf
					@ Li,079 Psay "|"
				EndIf

				nAtual := ST9->(Recno())
				If !Empty((cTRB675)->BEMPAI)
					SomaR765()
					@ Li,000 Psay STR0010 //"|Pai......:"
					@ Li,012 Psay (cTRB675)->BEMPAI
					@ Li,029 Psay NGSEEK('ST9',(cTRB675)->BEMPAI,1,'ST9->T9_NOME') Picture "@!S(39)"
					@ Li,079 Psay "|"
				EndIf
				DbSelectArea("ST9")
				dbGoTo(nAtual)
			Else
				@ Li,029 Psay NGSEEK("TAF","X2"+Substr(STJ->TJ_CODBEM,1,3),7,"SUBSTR(TAF_NOMNIV,1,40)") Picture "@!S(39)"
				@ Li,065 Psay STR0009 //"Prioridade:"
				@ Li,076 Psay NGSEEK('TQB',STJ->TJ_CODBEM,1,'TQB->TQB_PRIORI')
				@ Li,079 Psay "|"
			EndIf
			If !Empty(ST9->T9_LOCAL)
				SomaR765()
				@ Li,000 Psay STR0106 //"|Local....:"
				@ Li,012 Psay ST9->T9_LOCAL
				If STJ->TJ_TIPOOS == "B"
					@ Li,065 Psay STR0009 //"Prioridade:"
					@ Li,073 Psay NGSEEK('ST9',STJ->TJ_CODBEM,1,'ST9->T9_PRIORID')
				EndIf
				@ Li,079 Psay "|"
			EndIf
			dbSeek( cBchSTF + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA )

			// Linha do Centro de Custo
			SomaR765()
			@ Li,000 Psay STR0011 //"|C.Custo..:"
			@ Li,012 Psay SubStr(STJ->TJ_CCUSTO,1,20)
			@ Li,032 Psay SubStr( NGSEEK('CTT',STJ->TJ_CCUSTO,1,'CTT->CTT_DESC01'),1,30)
			@ Li,079 Psay "|"

			// Linha do Centro de Trabalho
			SomaR765()
			@ Li,000 Psay STR0012 //"|C.Trab...:"
			@ Li,012 Psay SubStr( STJ->TJ_CENTRAB,1,20 )
			@ Li,032 Psay SubStr( NGSEEK('SHB',STJ->TJ_CENTRAB,1,'SHB->HB_NOME'),1,30)
			@ Li,079 Psay "|"

			If STJ->TJ_TIPOOS == "B"
				// Impressao da Linha de Detalhes
				If mv_par04 = 1
					lPrimeiro := .F.
					SomaR765()
					dbSelectArea("STB")
					dbSetOrder(01)
					dbSeek( cBchSTB + ST9->T9_CODBEM )
					While !EoF() .And. STB->TB_CODBEM = ST9->T9_CODBEM  .And.;
					STB->TB_FILIAL == cBchSTB

						@ Li,000 Psay "|"
						If !lPrimeiro
							@ Li,001 Psay STR0013 //"Detalhes.:"
						EndIf

						@ Li,079 Psay "|"
						lPrimeiro = .T.
						SomaR765()
						If Empty(STB->TB_INFO02)

							lPrimeiro = .T.
							@ Li,012 Psay NGSEEK('TPR',STB->TB_CARACTE,1,'TPR->TPR_NOME')//Substr(NGSEEK('TPR',STB->TB_CARACTE,1,'TPR->TPR_NOME'),1,25)
							@ Li,060 Psay STB->TB_DETALHE //043
							@ Li,076 Psay STB->TB_UNIDADE //061
							@ Li,079 Psay "|"

						Else

						@ Li,000 Psay "|"
							@ Li,012 Psay SubStr(NGSEEK('TPR',STB->TB_CARACTE,1,'TPR->TPR_NOME'),1,40) + Space(1)
						@ Li,079 Psay "|"

						SomaR765()
						@ Li,000 Psay "|"
							@ Li,012 Psay If(STB->TB_CONDOP == "2", STR0190,"")+;
						Space(1) + SubStr(STB->TB_DETALHE,1,15) + Space(1) +;
								          If(STB->TB_CONDOP == "2",STR0191 + Space(1) +;
								          SubStr(STB->TB_INFO02,1,15),"") + SubStr(STB->TB_UNIDADE,1,2)
						@ Li,079 Psay "|"

						EndIf

						dbSelectArea("STB")
						dbSkip()
					End Do

				EndIf

				// Impressao da Linha de Descricao
				If mv_par03 = 1
					NGMEMOR675(STR0014,ST9->T9_DESCRIC,12,56,.T.)
				EndIf
			EndIf
			@ Li,000 Psay "|"
			@ Li,079 Psay "|"

			SomaR765()
			@ Li,000 Psay STR0015 //"|---------------------------------Manutencao-----------------------------------|"

			// Linha do Servico
			SomaR765()
			@ Li,000 Psay STR0016 //"|Servico..:"
			@ Li,012 Psay STJ->TJ_SERVICO
			@ Li,020 Psay NGSEEK('ST4',STJ->TJ_SERVICO,1,'Substr(ST4->T4_NOME,1,24)')
			If STJ->TJ_TIPOOS == "B"
				@ Li,047 Psay STR0017 //"Manutenção Anterior:"
				@ Li,069 Psay STJ->TJ_DTULTMA Picture '99/99/9999'
			EndIf
			@ Li,079 Psay "|"

			SomaR765()
			@ Li,000 Psay STR0018 //"|Sequencia:"

			@ Li,012 Psay STJ->TJ_SEQRELA  Picture "@!"
			If STJ->TJ_TIPOOS == "B"
				@ Li,20 Psay STR0019 //"Nome Manut..:"
			EndIf

			lPrinNom := .F.

			DbselectArea("ST4")
			If FieldPos("T4_TERCEIR") > 0
				DbSetOrder(01)
				If dbSeek( cBchST4 + STF->TF_SERVICO )
					If ST4->T4_TERCEIR = "S"
						DbselectArea("STJ")
						If FieldPos("TJ_POSCPR1") > 0 .Or. FieldPos("TJ_POSCPR2") > 0
							If !Empty(STJ->TJ_POSCPR1)
								@ Li,032 Psay STR0057+" "+STR0058+" 1 "+STR0059
								@ Li,067 Psay STJ->TJ_POSCPR1 Picture "999999999999"
								lPrinNom := .T.
							ElseIf !Empty(STJ->TJ_POSCPR2)
								@ Li,032 Psay STR0057+" "+STR0058+" 2 "+STR0059
								@ Li,067 Psay STJ->TJ_POSCPR2 Picture "999999999999"
								lPrinNom := .T.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			If !lPrinNom .And. STJ->TJ_TIPOOS == "B"
				@ Li,034 Psay STF->TF_NOMEMAN
				nColNomMan := 79
			EndIf
			If STJ->TJ_PLANO == "000000"
				@ Li,034 Psay " " + STR0115
				nColNomMan := 80
			EndIf
			@ Li,nColNomMan Psay "|"
			nColNomMan := 79 //Por padrão fica como 79 (caso não haja nome da manutenção)

			// Linha da Area de Manutencao
			SomaR765()
			@ Li,000 Psay STR0020 //"|Area.....:"
			@ Li,012 Psay STJ->TJ_CODAREA
			@ Li,020 Psay NGSEEK('STD',STJ->TJ_CODAREA,1,'STD->TD_NOME')

			If STJ->TJ_TIPOOS == "B"
				If STF->TF_TIPACOM = "C" .OR. STF->TF_TIPACOM = "A" .OR. STF->TF_TIPACOM = "F"
					@ Li,061 Psay STR0021 //"Contador:"
					@ Li,071 Psay STF->TF_CONMANU Picture "@E 999999"
				EndIf
			EndIf
			@ Li,079 Psay "|"

			// Linha de Tipo de Manutencao
			SomaR765()
			@ Li,000 Psay STR0022 //"|Tipo.....:"
			@ Li,012 Psay STJ->TJ_TIPO
			@ Li,020 Psay NGSEEK('STE',STJ->TJ_TIPO,1,'STE->TE_NOME')
			@ Li,079 Psay "|"

			If !Empty(STF->TF_DOCTO)
				SomaR765()
				@ Li,000 Psay STR0065 //"|NºProced.:"
				@ Li,012 Psay STF->TF_DOCTO
				@ Li,079 Psay "|"
			EndIf

			If STJ->TJ_TIPOOS == "B"
				// linha de informacao das paradas necessarias
				SomaR765()
				@ Li,000 Psay STR0023 //"|Parada...: Antes:"
				@ Li,019 Psay STF->TF_TEPAANT Picture "@E 999"
				@ Li,023 Psay STF->TF_UNPAANT
				@ Li,025 Psay STJ->TJ_DTPPINI
				@ Li,036 Psay STJ->TJ_HOPPINI
				@ Li,046 Psay STR0024 //"Depois:"
				@ Li,054 Psay STF->TF_TEPADEP Picture "@E 999"
				@ Li,058 Psay STF->TF_UNPADEP
				@ Li,060 Psay STJ->TJ_DTPPFIM
				@ Li,071 Psay STJ->TJ_HOPPFIM
				@ Li,079 Psay "|"

				// Linha da descricao da manutencao
				If mv_par05 == 1
					NGMEMOR675(STR0014,STF->TF_DESCRIC,12,56,.T.)
				EndIf

			EndIf

			If !Empty( cAls990 )

				cAlsSTL := cAls990
				nOrdSTL := 7
				cSeekTL  := STJ->TJ_ORDEM + STJ->TJ_PLANO + PadR( '0', TamSX3( 'TL_SEQRELA' )[1] )
				cWhileTL := '(cAlsSTL)->( !EoF() ) .And. (cAlsSTL)->TL_ORDEM == STJ->TJ_ORDEM .And. (cAlsSTL)->TL_PLANO == STJ->TJ_PLANO ' +;
					' .And. (cAlsSTL)->TL_SEQRELA == ' + ValToSQL( PadR( '0', TamSX3( 'TL_SEQRELA' )[1] ) )
				cLoopSTL := '(cAlsSTL)->STATUS == 3'

			Else

				cSeekTL  := cBchSTL + STJ->TJ_ORDEM + STJ->TJ_PLANO + PadR( '0', TamSX3( 'TL_SEQRELA' )[1] )
				cWhileTL := "STL->( !EoF() ) .And. cBchSTL == STL->TL_FILIAL .And. STJ->TJ_ORDEM == STL->TL_ORDEM .And. STJ->TJ_PLANO == STL->TL_PLANO " +;
					" .And. STL->TL_SEQRELA == " + ValToSQL( PadR( '0', TamSX3( 'TL_SEQRELA' )[1] ) )

			EndIf

			aARTAREFAS := {}

			dbSelectArea( cAlsSTL )
			dbSetOrder( nOrdSTL )
			dbSeek( cSeekTL )

			While &( cWhileTL )

				If &( cLoopSTL )
					(cAlsSTL)->( dbSkip() )
					Loop
				EndIf

				DbSelectArea("ST5")
				DbSetOrder(1)
				If dbSeek( cBchST5 + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA + (cAlsSTL)->TL_TAREFA )
					cT5Sequen := cValToChar(STRZERO(T5_SEQUENC,TAMSX3("T5_SEQUENC")[1]))
				EndIf

				nPOS := aScan( aARTAREFAS, { |x| x[1] == (cAlsSTL)->TL_TAREFA } )
				If nPOS = 0
					
					aAdd( aARTAREFAS, { (cAlsSTL)->TL_TAREFA, (cAlsSTL)->TL_DTINICI, (cAlsSTL)->TL_HOINICI,;
						(cAlsSTL)->TL_DTFIM, (cAlsSTL)->TL_HOFIM, cT5Sequen } )

				Else

					If (cAlsSTL)->TL_DTINICI < aARTAREFAS[nPOS][2]
						aARTAREFAS[nPOS][2] := (cAlsSTL)->TL_DTINICI
						aARTAREFAS[nPOS][3] := (cAlsSTL)->TL_HOINICI
					ElseIf (cAlsSTL)->TL_DTINICI == aARTAREFAS[nPOS][2] .And. (cAlsSTL)->TL_HOINICI < aARTAREFAS[nPOS][3]
						aARTAREFAS[nPOS][3] := (cAlsSTL)->TL_HOINICI
					EndIf

					If (cAlsSTL)->TL_DTFIM > aARTAREFAS[nPOS][4]
						aARTAREFAS[nPOS][4] := (cAlsSTL)->TL_DTFIM
						aARTAREFAS[nPOS][5] := (cAlsSTL)->TL_HOFIM
					ElseIf (cAlsSTL)->TL_DTFIM == aARTAREFAS[nPOS][4] .And. (cAlsSTL)->TL_HOFIM > aARTAREFAS[nPOS][5]
						aARTAREFAS[nPOS][5] := (cAlsSTL)->TL_HOFIM
					EndIf

					aARTAREFAS[nPOS][6] := cT5Sequen

				EndIf

				(cAlsSTL)->( dbSkip() )
				
			End

			aARETAPAS := {}
			dbSelectArea("STQ")
			dbSetOrder(01)
			dbSeek( cBchSTQ + STJ->TJ_ORDEM + STJ->TJ_PLANO )
			Do While !EoF() .And. cBchSTQ == STQ->TQ_FILIAL .And.;
			STQ->TQ_ORDEM == STJ->TJ_ORDEM .And. STQ->TQ_PLANO == STJ->TJ_PLANO

				dbSelectArea("ST5")
				dbSetOrder(1)
				If dbSeek( cBchST5 + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA + STQ->TQ_TAREFA )
					cT5Sequen := cValToChar(STRZERO(T5_SEQUENC,TAMSX3("T5_SEQUENC")[1]))
				EndIf

				aAdd(aARETAPAS,{STQ->TQ_TAREFA, STQ->TQ_ETAPA, STQ->TQ_SEQETA, cT5Sequen})
				nExists := aScan(aARTarefas, {|x| x[1] == STQ->TQ_TAREFA})

				If Empty(aARTAREFAS) .Or. nExists == 0
					Aadd(aARTAREFAS,{STQ->TQ_TAREFA,STJ->TJ_DTMPINI,STJ->TJ_HOMPINI,;
					STJ->TJ_DTMPFIM,STJ->TJ_HOMPFIM,cT5Sequen })
				EndIf

				dbSelectArea("STQ")
				dbSkip()
			EndDo

			//If MV_PAR26 == 1
			// Adiciona no Array aARSINTOMA os
			// sintomas da O.S corrente...
			aARSINTOMA := {}
			NGdbAreaOrde("TTC", 1)
			dbSeek( cBchTTC + STJ->TJ_ORDEM + STJ->TJ_PLANO )
			While !Eof() .And.;
			cBchTTC == TTC->TTC_FILIAL .And.;
			TTC->TTC_ORDEM == STJ->TJ_ORDEM .And.;
			TTC->TTC_PLANO  == STJ->TJ_PLANO
				// Busca na TTB a descrição do Sintoma.
				If NGIFdbSeek('TTB', TTC->TTC_CDSINT, 1 )
					cDescSint := TTB->TTB_DESSIN
					If TTB->TTB_BLOQPT == 'S'
						cBloqPort := STR0063
					Else
						cBloqPort := STR0062
					EndIf
					aAdd(aARSINTOMA, { TTC->TTC_CDSINT,;
					cDescSint, cBloqPort  } )
				EndIf
				NGDBSELSKIP("TTC")
			EndDo
			If !Empty(aARSINTOMA)
				aSort( aARSINTOMA )
			EndIf
			//EndIf
			If !Empty(aARETAPAS)
				If Len(aARETAPAS[1]) >= 4
					aSort(aARETAPAS ,,, {|x,y| x[4]+x[1]+x[2] < y[4]+y[1]+Y[2] })
				Else
					aSort(aARETAPAS ,,, {|x,y| x[1]+x[2] < y[1]+y[2] })
				EndIf
			EndIf

			If !Empty(aARTAREFAS)
				If Len(aARTAREFAS[1]) >= 6
					aSort(aARTAREFAS ,,, {|x,y| x[6]+x[1] < y[6]+y[1] })
				EndIf
			EndIf

			For xk := 1 To Len(aARTAREFAS)
				SomaR765()
				@ Li,000 Psay STR0025 //"|----------------------------------Tarefa--------------------------------------|"
				SomaR765()
				@ Li,000 Psay STR0026 //"|Codigo:"
				@ Li,009 Psay aARTAREFAS[xk][1]    Picture "@!"
				@ Li,017 Psay STR0027 //"Previsao Inicio..:"
				@ Li,035 Psay aARTAREFAS[xk,2]     Picture '99/99/9999'
				@ Li,047 Psay aARTAREFAS[xk][3]    Picture '99:99'
				@ Li,055 Psay STR0028  //"Fim..:"
				@ Li,061 Psay aARTAREFAS[xk,4]     Picture '99/99/9999'
				@ Li,073 Psay aARTAREFAS[xk][5]    Picture '99:99'
				@ Li,079 Psay "|"
				SomaR765()
				@ Li,000 Psay "|"
				@ Li,017 Psay STR0029 //"Real     Inicio..:"
				@ Li,055 Psay STR0028 //"Fim..:"
				@ Li,079 Psay "|"

				If AllTrim(aARTAREFAS[xk][1]) == "0"
					SomaR765()
					@ Li,000 Psay "|"
					@ Li,002 Psay STR0030 //"Sem Especificacao De Tarefa"
					@ Li,079 Psay "|"
				Else
					SomaR765()
					@ Li,000 Psay "|"
					If !lUSATAR
						@ Li,002 Psay NGSEEK('ST5',STJ->TJ_CODBEM+STJ->TJ_SERVICO+;
						STJ->TJ_SEQRELA+aARTAREFAS[xk][1],1,'T5_DESCRIC') Picture "!@"
					Else
						lCORRET := If(Val(stj->tj_plano) = 0,.T.,.F.)
						@ Li,002 Psay NGNOMETAR(STJ->TJ_CODBEM+STJ->TJ_SERVICO+STJ->TJ_SEQRELA,;
						aARTAREFAS[xk][1]) Picture "!@"
					EndIf
					@ Li,079 Psay "|"
				EndIf

				If MV_PAR06 == 1      // mostra etapas da tarefa
					DbSelectArea("STQ")
					DbSetOrder(nINDSTQ)
					dbSeek( cBchSTQ + STJ->TJ_ORDEM + STJ->TJ_PLANO + aARTAREFAS[xk][1] )
					If Found()
						SomaR765()
						@ Li,000 Psay STR0031 //"|   -------------------------------Etapas-----------------------------------   |"
					EndIf

					While !EoF() .And. cBchSTQ == STQ->TQ_FILIAL .And.;
					STQ->TQ_ORDEM == STJ->TJ_ORDEM .And.;
					STQ->TQ_PLANO == STJ->TJ_PLANO .And.;
					STQ->TQ_TAREFA == aARTAREFAS[xk][1]

						NGIMPETAPA(stq->tq_ok,stq->tq_etapa)

						// Deletar as etapas da array aARETAPAS
						nPOS2 := Ascan(aARETAPAS,{|x| x[1] == stq->tq_tarefa .And. x[2] == stq->tq_etapa})
						If nPOS2 > 0
							Adel(aARETAPAS,nPOS2)
							Asize(aARETAPAS,Len(aARETAPAS)-1)
						EndIf
						DbSelectArea("STQ")
						DbSkip()
					End
				EndIf

				dbSelectArea( cAlsSTL )
				dbSetOrder( nOrdSTL )
				dbSeek( cSeekTL + aARTAREFAS[xk,1] )

				While &( cWhileTL ) .And. (cAlsSTL)->TL_TAREFA == aARTAREFAS[xk,1]

					If &( cLoopSTL )
						(cAlsSTL)->( dbSkip() )
						Loop
					EndIf

					If lCabStl1
						SomaR765()
						@ Li,000 Psay "|"
						@ Li,079 Psay "|"
						SomaR765()
						@ Li,000 Psay STR0032 //"|   -------------------------------Insumos----------------------------------   |"
						SomaR765()
						@ Li,000 Psay STR0082+Space(10+nB1)+STR0094+Space(48-nB1)+"|" //"|Nome     Codigo"###"Descricao"
						SomaR765()
						@ Li,000 Psay STR0083 //"|   Data Prev.   Hora   Quant.   Consumo   Unid.  Quant.   Consumo   Unid.     |"
						lCabStl1 := .F.
					EndIf

					SomaR765()
					@ Li,000 Psay "|"

					@ Li,001 Psay Substr(TIPREGBRW((cAlsSTL)->TL_TIPOREG),1,4)
					
					@ Li,006 Psay (cAlsSTL)->TL_CODIGO Picture '@!'
					@ Li,022+(nB1) Psay NOMINSBRW((cAlsSTL)->TL_TIPOREG, (cAlsSTL)->TL_CODIGO, (cAlsSTL)->TL_LOJA )
					@ Li,079 Psay "|"
					SomaR765()
					@ Li,000 Psay "|"
					@ Li,004 Psay (cAlsSTL)->TL_DTINICI Picture '99/99/9999' //Data Prev.
					@ Li,017 Psay (cAlsSTL)->TL_HOINICI Picture '99:99' //Hora
					@ Li,027 Psay (cAlsSTL)->TL_QUANREC Picture '999' //Quant

					If (cAlsSTL)->TL_TIPOREG != 'P'
						@ Li,031 Psay MNT675CONV( (cAlsSTL)->TL_QUANTID, IIf( Empty( (cAlsSTL)->TL_TIPOHOR ), Nil, (cAlsSTL)->TL_TIPOHOR ) ) Picture '@E 999999.99' //Consumo
					Else
						@ Li,031 Psay (cAlsSTL)->TL_QUANTID Picture '@E 999999.99' //Consumo
					EndIf
					@ Li,043 Psay (cAlsSTL)->TL_UNIDADE //Unid.
					@ Li,079 Psay "|"

					If !Empty( (cAlsSTL)->TL_OBSERVA )
						SomaR765()
						@ Li,000 Psay "|"
						@ Li,079 Psay "|"
						NGMEMOR675( Space(5) + STR0066, (cAlsSTL)->TL_OBSERVA, 21, 55, .T. )
						SomaR765()
						@ Li,000 Psay "|"
						@ Li,079 Psay "|"
					EndIf
					
					(cAlsSTL)->( dbSkip() )

				End

				lCabStl1 := .T.

			Next xk

			// Imprime as etapas nao relacionadas com insumos
			If MV_PAR06 == 1      // mostra etapas da tarefa
				If Len(aARETAPAS) > 0
					SomaR765()
					@ Li,000 Psay "|"
					@ Li,079 Psay "|"
					SomaR765()
					@ Li,000 Psay STR0050

					aARCLASS := aClone(aARETAPAS)

					cAUXTAR  := 'XXXXXX'
					For xz := 1 To Len(aARCLASS)
						If cAUXTAR <> aARCLASS[xz][1]
							SomaR765()
							@ Li,000 Psay "|"
							@ Li,001 Psay STR0051
							@ Li,008 Psay aARCLASS[xz][1]

							If !lUSATAR
								@ Li,015 Psay If(AllTrim(aARCLASS[xz][1]) == "0",STR0030,;
								NGSEEK('ST5',STJ->TJ_CODBEM+STJ->TJ_SERVICO+;
								STJ->TJ_SEQRELA+aARCLASS[xz][1],1,'ST5->T5_DESCRIC'))
							Else
								lCORRET := If(Val(stj->tj_plano) = 0,.T.,.F.)
								@ Li,015 Psay NGNOMETAR(STJ->TJ_CODBEM+STJ->TJ_SERVICO+STJ->TJ_SEQRELA,;
								aARCLASS[xz][1]) Picture "!@"
							EndIf

							@ Li,079 Psay "|"
						EndIf
						cAUXTAR := aARCLASS[xz][1]
						NGIMPETAPA("  ",aARCLASS[xz][2])
					Next xz
				EndIf
			EndIf
			//If MV_PAR26 == 1
			If Len( aARSINTOMA ) > 0
				SomaR765()
				@ Li,000 Psay STR0152 // "|----------------------------------Sintomas------------------------------------|"
				SomaR765()
				@ Li,000 Psay "| "
				@ Li,001 Psay STR0153 // "Cód. Sintoma: "
				@ Li,017 Psay STR0154 // "Desc. Sintoma: "
				@ Li,060 Psay STR0155 // "Bloqueia Portaria:"
				@ Li,078 Psay "|"
				For xz := 1 To Len( aARSINTOMA )
					SomaR765()
					@ Li,000 Psay "| "
					@ Li,001 Psay aARSINTOMA[xz][1]
					@ Li,017 Psay aARSINTOMA[xz][2]
					@ Li,060 Psay aARSINTOMA[xz][3]
					@ Li,078 Psay "|"
				Next xz
			EndIf
			//EndIf

			// Impressao da Linha de Descricao da O.S
			If !Empty(STJ->TJ_OBSERVA)
				If mv_par18 == 2
					SomaR765()
					@ Li,000 Psay "|"
					@ Li,079 Psay "|"
					SomaR765()
					@ Li,000 Psay STR0118 //"|----------------------------------Observação----------------------------------|"
					dbSelectArea("STJ")
					dbSetOrder(STJ->(INDEXORD()))
					cOBSERVA := If(FieldPos('TJ_MMSYP') > 0,AllTrim(NGMEMOSYP(STJ->TJ_MMSYP)),If(FieldPos('TJ_OBSERVA')>0,AllTrim(STJ->TJ_OBSERVA)," "))
					NGMEMOR675(STR0052,cOBSERVA,19,58,.T.,"TJ_OBSERVA")  //"Descrição da O.S:"
				EndIf
			EndIf

			If mv_par19 == 2 .And. STJ->TJ_TIPOOS == "B"
				dbselectarea("STJ")
				nINDESTJ := IndexOrd()
				nRECNSTJ := Recno()
				aAPESCAR := NGPEUTIL(stj->tj_codbem)
				DbselectArea("STJ")
				DbsetOrder(nINDESTJ)
				DbGoto(nRECNSTJ)
				If Len(aAPESCAR) > 0
					SomaR765()
					@ Li,000 Psay "|"
					@ Li,079 Psay "|"

					SomaR765()
					@ Li,000 Psay STR0053 //"|-----------------------------Pecas de Reposicao-------------------------------|"
					SomaR765()
					@ Li,000 Psay "|"
					@ Li,001 Psay STR0085+Space(10+nB1)+STR0094  //"Codigo"###"Descricao"
					@ Li,079 Psay "|"
					SomaR765()
					@ Li,000 Psay "|"
					@ Li,034 Psay STR0098+Space(4)+STR0099+Space(4)+STR0100+Space(4)+STR0101  //"Dt.U.Uso"###"Contador"###"Proxima"###"Dt.Prox."
					@ Li,079 Psay "|"
					For xk := 1 To Len(aAPESCAR)
						SomaR765()
						@ Li,000 Psay "|"
						@ Li,001 Psay aAPESCAR[xk,1] Picture "@!"
						//@ Li,017 Psay Substr(NGSEEK("SB1",aAPESCAR[xk,1],1,"B1_DESC"),1,24)
						@ Li,017+(nB1) Psay Substr(NGSEEK("SB1",aAPESCAR[xk,1],1,"B1_DESC"),1,24)
						@ Li,079 Psay "|"
						SomaR765()
						@ Li,000 Psay "|"
						If !Empty(aAPESCAR[xk,2])
							@ Li,034 Psay aAPESCAR[xk,2] Picture "99/99/9999"
						EndIf

						If !Empty(aAPESCAR[xk,4])
							@ Li,045 Psay aAPESCAR[xk,4] Picture "999999999"
						EndIf

						If !Empty(aAPESCAR[xk,6])
							@ Li,056 Psay aAPESCAR[xk,6] Picture "999999999"
						EndIf

						If !Empty(aAPESCAR[xk,8])
							@ Li,069 Psay aAPESCAR[xk,8] Picture "99/99/9999"
						EndIf
						@ Li,079 Psay "|"

						If !Empty(aAPESCAR[xk,5]) .Or. !Empty(aAPESCAR[xk,7]) .Or.;
						!Empty(aAPESCAR[xk,9])
							SomaR765()
							@ Li,000 Psay "|"
							@ Li,025 Psay STR0055 //"Segundo Contador"
							If !Empty(aAPESCAR[xk,5])
								@ Li,045 Psay aAPESCAR[xk,5] Picture "999999999"
							EndIf
							If !Empty(aAPESCAR[xk,7])
								@ Li,056 Psay aAPESCAR[xk,7] Picture "999999999"
							EndIf
							If !Empty(aAPESCAR[xk,9])
								@ Li,069 Psay aAPESCAR[xk,9] Picture "99/99/99"
							EndIf
							@ Li,079 Psay "|"
						EndIf
					Next xk
				EndIf

				Dbselectarea("STJ")
				DbSetOrder(nINDESTJ)
				Dbgoto(nRECNSTJ)

			EndIf

			SomaR765()
			@ Li,000 Psay "|"
			@ Li,079 Psay "|"
			SomaR765()
			@ Li,000 Psay STR0040 //"|--------------------------------Ocorrencias-----------------------------------|"
			SomaR765()
			@ Li,000 Psay STR0084 //"| Tarefa   Ocorrencia            Causa                  Solucao                |"

			For nContador := 1 to 5
				SomaR765()
				@ Li,000 Psay "| ______   ___________________   ____________________   ___________________    |"
			Next

			If nTImpr = 3
				DbSelectArea("TPL")
				DbSetOrder(01)
				If dbSeek( cBchTPL + STJ->TJ_ORDEM )

					@ Li,000 Psay "|"
					@ Li,079 Psay "|"
					SomaR765()
					@ Li,000 Psay "|"
					@ Li,079 Psay "|"
					SomaR765()
					SomaR765()
					@ Li,000 Psay STR0086 //"|------------------------------Motivo de atraso-------------------------------|"
					SomaR765()
					@ Li,000 Psay "|"
					@ Li,002 Psay cTitCodMod
					@ Li,010 Psay cTitDesMot
					@ Li,048 Psay cTitDtInic
					@ Li,058 Psay STR0087
					@ Li,065 Psay cTitDtFim
					@ Li,075 Psay STR0087//+"|"
					@ Li,080 Psay "|"

					DbSelectArea("TPL")
					While !EoF() .And. cBchTPL == TPL->TPL_FILIAL .And.;
					TPL->TPL_ORDEM == STJ->TJ_ORDEM
						SomaR765()
						@ Li,000 Psay "|"
						@ Li,002 Psay TPL->TPL_CODMOT Picture "!@"
						@ Li,009 Psay SubStr(NGSEEK("TPJ",TPL->TPL_CODMOT,1,'TPJ_DESMOT'),1,35)
						@ Li,046 Psay TPL->TPL_DTINIC Picture "99/99/99"
						@ Li,057 Psay TPL->TPL_HOINIC Picture "99:99"
						@ Li,063 Psay TPL->TPL_DTFIM  Picture "99/99/99"
						@ Li,074 Psay TPL->TPL_HOFIM  Picture "99:99"
						@ Li,078 Psay "|"
						DbSelectArea("TPL")
						DbSkip()
					End
					SomaR765()
					@ Li,000 Psay "|"
					@ Li,079 Psay "|"
				EndIf
			EndIf
			SomaR765()
			@ Li,000 Psay "|------------------------------------------------------------------------------|"
			SomaR765()
			@ Li,000 Psay "|"
			@ Li,079 Psay "|"
			SomaR765()
			@ Li,000 Psay STR0042 //"|  Manutencao.: ____/____/____               Contador..: _____________ Fim.:   |"
			SomaR765()
			@ Li,000 Psay "|"
			@ Li,079 Psay "|"
			SomaR765()
			@ Li,000 Psay STR0043 //"|  Data.......: ____/____/____               Assinatura: ______________________|"
			SomaR765()
			@ Li,000 Psay Replicate("-",80)

			If lMNTR6751
				ExecBlock("MNTR6751",.F.,.F.)
			EndIf

			SomaR765()

			li := 80
		EndIf

		If MV_PAR20 == 2
			fPrintBco( aReturn[5] )
		EndIf
		dbSelectArea(cTRB675)
		dbSkip()
	
	End

	//Deleta o arquivo temporario fisicamente
	oARQTR675:Delete()

	RetIndex("STJ")
	Set Filter To
	Set device to Screen

	DbSelectArea("STJ")
	DbSetOrder(01)

	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NGIMPETAPA³ Autor ³ NG Informatica Ltda   ³ Data ³   /06/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Imprime a etapas                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR675                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function NGIMPETAPA(cVOK,cVETAPA)
	If Empty(cVOK)
		SomaR765()
		@ Li,000 Psay "|"
		@ Li,002 Psay cVETAPA
		DbSelectArea("TPA")
		DbSetOrder(01)
		dbSeek( cBchTPA + cVETAPA )
		NGMEMOR675(' ',TPA->TPA_DESCRI,9,65,.F.)
		If MV_PAR23 == 1
			MNT675NOP(cVETAPA)
		EndIf
	EndIf
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NGMEMOR675³ Autor ³In cio Luiz Kolling    ³ Data ³13/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Imprime campo memo ( especifica p/ mntr675 )                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR675                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function NGMEMOR675(cTITULO,cDESCRI,nCOLU,nTAM,lSOMLI,cCAMPO)
	Local lPrimeiro := .T.
	Local lSOMEILI  := lSOMLI,linhacorrente
	Default cCAMPO := ""//Varáivel para saber qual campo está sendo impresso, utilizado para tratamento especial do TJ_OBSERVA
	//Verifica se TJ_OBSERVA para tratamento especial em detrimento das O.S. MultiEmpresa
	If Trim(Upper(cCAMPO)) == "TJ_OBSERVA" .AND. (nAt:= AT(CHR(13),cDESCRI)) > 0
		//Verifica se deve pular linha antes de imprimir
		If lSOMEILI
			SomaR765()
			@ Li,000 Psay "|"
		EndIf
		If !Empty(cTITULO)
			@ Li,001 Psay cTITULO
		EndIf
		lSOMEILI := .F.
		nIni:= 1
		//Verifica se ainda existem quebras
		While AT(CHR(13),SubStr(cDESCRI,nIni)) > 0
			While nIni < nAT
				//Verifica se existem 2 quebras seguidas
				If(AT(CHR(10),Substr(cDESCRI,nIni,1)) > 0,nIni += 1,)
				//Verifica o pedaco a ser impresso
				If (nAT-nIni) < nTAM
					cLine := Substr(cDESCRI,nIni,nAT-nIni)
				Else
					cLine := Substr(cDESCRI,nIni,nTAM)
				EndIf
				//Pula Linha
				If lSOMEILI .And. !Empty(cLine)
					SomaR765()
					@ Li,000 Psay "|"
				EndIf
				//Imprime da ultima quebra até a próxima e pula de linha
				If nAT > 0 .And. Substr(cDESCRI,nIni,(nAT-1)-nIni) <> CHR(10)
					@ li,nCOLU Psay cLine
				EndIf
				nIni += nTAM
				If !Empty(cLine)
					@ Li,079 Psay "|"
				EndIf
				lSOMEILI := .T.
			End
			nIni:= nAt+1
			nAt:= nAt + AT(CHR(13),SubStr(cDESCRI,nIni))
		End
		If(AT(CHR(10),Substr(cDESCRI,nIni,1)) > 0,nIni += 1,)
		While nIni <= Len(cDESCRI)

			If lSOMEILI
				SomaR765()
				@ Li,000 Psay "|"
			EndIf
			If Substr(cDESCRI,nIni) <> CHR(10)
				@ li,nCOLU Psay Substr(cDESCRI,nIni,nTAM)
			EndIf
			@ Li,079 Psay "|"

			lSOMEILI := .T.
			nIni += nTAM
		End
	Else
		nLinhasMemo := MLCOUNT(AllTrim(cDESCRI),nTAM)
		For LinhaCorrente := 1 To nLinhasMemo

			If lSOMEILI
				SomaR765()
				@ Li,000 Psay "|"
			EndIf
			If lPrimeiro
				If !Empty(cTITULO)
					@ Li,001 Psay cTITULO
				EndIf
				lPrimeiro := .F.
			EndIf
			@ Li,nCOLU Psay (MemoLine(cDESCRI,nTAM,LinhaCorrente))
			@ Li,079 Psay "|"
			lSOMEILI := .T.
		Next
	EndIf
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ SomaR765 ³ Autor ³ NG Informatica Ltda   ³ Data ³   /06/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Incrementa Linha e Controla Salto de Pagina                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR675                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function SomaR765()
	Li++
	If Li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,,.F.,cLogo)

		@ Li  ,000 Psay "--------------------------------------------------------------------------------"
		Li += 1
		@ Li,000 Psay "|"
		@ Li,001 Psay cNomFil
		@ Li,038 Psay STR0006+":" //"Ordem De Servico De Manutencao"
		@ Li,074 Psay STJ->TJ_ORDEM
		@ Li,080 Psay "|"

		If !Empty(stj->tj_solici)
			Li += 1
			@ Li,000 Psay "|"
			@ Li,042 Psay STR0056 // "Solicitacao de Servico"
			@ Li,073 Psay STJ->TJ_SOLICI
			@ Li,079 Psay "|"
			Li += 1
			@ Li,000 Psay "|"
			@ Li,001 Psay STR0095 //"Solicitante: "
			@ Li,015 Psay SubStr(UsrRetName(NGSEEK('TQB',STJ->TJ_SOLICI,1,'TQB->TQB_CDSOLI')),1,15)
			@ Li,033 Psay STR0096 //"Dt.Solic.: "
			@ Li,045 Psay DtoC(NGSEEK('TQB',STJ->TJ_SOLICI,1,'TQB->TQB_DTABER'))
			@ Li,057 Psay STR0097 //"Hr.Solic.: "
			@ Li,068 Psay NGSEEK('TQB',STJ->TJ_SOLICI,1,'TQB->TQB_HOABER')
			@ Li,079 Psay "|"
		EndIf

		Li += 1
		@ Li,000 Psay "|SIGA/MNTR675"
		@ Li,014 Psay STR0044 //"Inicio:"
		@ Li,022 Psay STJ->TJ_DTMPINI+(cTRB675)->DIFFDT Picture '99/99/9999'
		@ Li,034 Psay STJ->TJ_HOMPINI Picture '99:99'
		@ Li,040 Psay STR0045 //"Fim:"
		@ Li,045 Psay STJ->TJ_DTMPFIM+(cTRB675)->DIFFDT Picture '99/99/9999'
		@ Li,056 Psay STJ->TJ_HOMPFIM Picture '99:99'
		@ Li,063 Psay STR0117 //"Emis.:"
		@ Li,069 Psay dDataBase
		@ Li,079 Psay "|"
		Li += 1
		@ Li,000 Psay STR0047 //"|Execucao: Inicio: ____/____/____ __:__ Plano:"
		@ Li,047 Psay STJ->TJ_PLANO
		If STJ->TJ_TIPOOS == "B"
			@ Li,055 Psay STR0048 //"Prioridade Manut.:"
			@ Li,074 Psay STJ->TJ_PRIORID
		EndIf
		@ Li,079 Psay "|"
		Li += 1
		@ Li,000 Psay STR0049 //"|          Fim...: ____/____/____ __:__"
		@ Li,040 Psay  NGSEEK('STI',STJ->TJ_PLANO,1,'SubStr(STI->TI_DESCRIC,1,39)')
		@ Li,079 Psay "|"
		Li += 1
		@ Li,000 Psay "|"
		If NGSEEK('ST9',STJ->TJ_CODBEM,1,'ST9->T9_TEMCONT') <> "N"
			@ Li,001 Psay "1º "+STR0021 //"Contador:"
			@ Li,013 Psay STJ->TJ_POSCONT
			If NGIFDBSEEK("TPE",STJ->TJ_CODBEM,1)
				@ Li,079 Psay "|"
				Li += 1
				@ Li,000 Psay "|"
				@ Li,001 Psay "2º "+STR0021 //"Contador:"
				@ Li,013 Psay STJ->TJ_POSCON2
			EndIf
		EndIf
		@ Li,079 Psay "|"
		Li := Prow()+1
	EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³MNT675OPE   ³ Autor ³ In cio Luiz Kolling   ³ Data ³02/12/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Impressao das opcoes da etapa grafica                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR675                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function MNT675OPE( oPrint, cVETAP )

	If NGIFDBSEEK( "TPC", cVETAP, 1 )
		MNTW675Somal(oPrint)
		oPrint:Line(li, nHorz+150 , li , nHorz+2000)
		MNTW675Somal(oPrint)
		MNTW675Somal(oPrint)
		oPrint:Say( li - 55 , nHorz+750, NGSX2NOME("TPC"), oFonTMN )
		MNTW675Somal(oPrint)
		oPrint:Line(li, nHorz+150 , li , nHorz+2000)
		oPrint:Say( li, nHorz+150 , NGRETTITULO("TPC_OPCAO") , oFonTMN)
		oPrint:Say( li, nHorz+700 , NGRETTITULO("TPC_TIPRES"), oFonTMN)

		oPrint:Say( li, nHorz+1100, NGRETTITULO("TPC_FORMUL"), oFonTMN)

		NGIFDBSEEK( "TPC", cVETAP, 1 )
		While !EoF() .And. TPC->TPC_FILIAL == cBchTPC .And. TPC->TPC_ETAPA == cVETAP
			MNTW675Somal(oPrint)
			MNTW675Somal(oPrint)
			oPrint:Say( li, nHorz+150 , TPC->TPC_OPCAO, oFonTPN)
			oPrint:Say( li, nHorz+700 , NGRETSX3BOX("TPC_TIPRES",TPC->TPC_TIPRES), oFonTPN )
			oPrint:Say( li, nHorz+1100, SubStr( TPC->TPC_FORMUL, 1, 80 ), oFonTPN)

			dbSelectArea( "TPC" )
			dbSkip()
		EndDo

		MNTW675Somal(oPrint)
	EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³MNT675NOP   ³ Autor ³ In cio Luiz Kolling   ³ Data ³02/12/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Impressao das opcoes da etapa normal                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR675                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function MNT675NOP(cVETAP)

	Local cAuxTIPRES := ""
	Local cAuxFORMUL := ""

	If NGIFDBSEEK("TPC",cVETAP,1)
		SomaR765()
		@ Li,000 Psay "|"
		@ Li,005 Psay "---------------------"+NGSX2NOME("TPC")+"--------------------"
		@ Li,079 Psay "|"
		SomaR765()
		@ Li,000 Psay "|"
		@ Li,005 Psay NGRETTITULO("TPC_OPCAO")
		@ Li,022 Psay NGRETTITULO("TPC_TIPRES")

		@ Li,040 Psay NGRETTITULO("TPC_FORMUL")

		@ Li,079 Psay "|"

		While !EoF() .And. TPC->TPC_FILIAL == cBchTPC .And. TPC->TPC_ETAPA = cVETAP
			SomaR765()

			cAuxTIPRES := AllTrim(NGRETSX3BOX("TPC_TIPRES",TPC->TPC_TIPRES))
			If Empty(cAuxTIPRES)
				cAuxTIPRES := " "
			EndIf

			cAuxFORMUL := SubStr( AllTrim( TPC->TPC_FORMUL ), 1, 60 )
			If Empty(cAuxTIPRES)
				cAuxFORMUL := " "
			EndIf

			@ Li,000 Psay "|"
			@ Li,005 Psay TPC->TPC_OPCAO Picture "@!"
			@ Li,022 Psay cAuxTIPRES     Picture "@!"

			If !Empty(TPC->TPC_FORMUL)
				@ Li,040 Psay cAuxFORMUL  Picture "@!"
			EndIf

			@ Li,079 Psay "|"

			dbSelectArea( "TPC" )
			dbSkip()
		EndDo

		SomaR765()

		@ Li,000 Psay "|"
		@ Li,079 Psay "|"
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fModParSX1
Carrega as variaveis das perguntas a partir do SX1 e Altera os conteúdos

@author  Maicon André Pinheiro
@since   27/02/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function fModParSX1(cPerg,aMNT675)

	Local aArea     := GetArea()
	Local cPergC    := PadR( Alltrim(cPerg), Len(Posicione("SX1", 1, Alltrim(cPerg), "X1_GRUPO")) )
	Local nTotSX1   := Len(aMNT675)
	Local nInd      := 0
	Local nTamanho  := 0
	Local cTipo     := ""
	Local xConteudo := ""

	For nInd := 1 To nTotSX1

		cTipo    := Posicione("SX1",1,cPergC + aMNT675[nInd][1],"X1_TIPO")
		nTamanho := Posicione("SX1",1,cPergC + aMNT675[nInd][1],"X1_TAMANHO")
		If nTamanho > 0 //Caso encontrou a pergunta.

			Do Case
				Case cTipo == "N"
					xConteudo := aMNT675[nInd,2]
				Case cTipo == "C"
					xConteudo := SubStr(aMNT675[nInd,2],1,nTamanho)
				Case cTipo == "D"
					If ValType(aMNT675[nInd,2]) == "C"
						xConteudo := CtoD(aMNT675[nInd,2])
					Else
						xConteudo := aMNT675[nInd,2]
					EndIf
			End Case

			&("MV_PAR"+aMNT675[nInd][1]) := xConteudo

		EndIf

	Next nInd

	RestArea(aArea)

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} MNT675CONV
Converte as horas conforme parâmetro verificando o estado atual do registro.
@type function

@author  Alexandre Santos
@since   20/07/2018

@sample MNT675CONV(nQtde, cTipoHr)

@param  nQtde    , numeric, Quantidade que será convertida.
@param  [cTipoHr], string , Tipo de hora utilizada pelo registro em base.
@return numeric  , Valor já convertido.
/*/
//---------------------------------------------------------------------------
User Function MNT675CONV( nQtde, cTipoHr )

	Local cNgUnidt  := SuperGetMV( 'MV_NGUNIDT', .F., 'D' )
	Local nRetHr    := 0.0

	Default cTipoHr := SuperGetMV( 'MV_NGUNIDT', .F., 'D' )

	If cTipoHr != cNgUnidt
		nRetHr := NGCONVERHORA(nQtde, cTipoHr, cNgUnidt)
	Else
		nRetHr := nQtde
	EndIf

Return nRetHr

//--------------------------------------------------------------------------
/*/{Protheus.doc} fPrintBco
Realiza chamada da impressão para banco de conhecimento conforme parametro
@type static

@author Alexandre Santos
@since 01/10/18

@sample fPrintBco(2)

@param  nTypePrint, Numérico, Define o tipo de impressão (Via Spool, Em Disco)
@return
/*/
//-------------------------------------------------------------------------
Static Function fPrintBco( nTypePrint )

	Local aArea     := GetArea()
	Local cSequence := IIf( NgVerify("STJ"), STJ->TJ_SEQRELA, Str(STJ->TJ_SEQUENC,3) )

	If !(nTypePrint == 3 .Or. nTypePrint == 4)
		If MV_PAR21 == 1 .Or. STJ->TJ_PLANO == '000000' //Da Os
			NgDocPrint( "STJ", cBchSTJ, STJ->TJ_ORDEM, nTypePrint )
		ElseIf MV_PAR21 == 2 //Da Manutencao
			NgDocPrint( "STF", cBchSTF, STJ->TJ_CODBEM + STJ->TJ_SERVICO + cSequence, nTypePrint )
		Else  //Ambos
			NgDocPrint( "STF", cBchSTF, STJ->TJ_CODBEM + STJ->TJ_SERVICO + cSequence, nTypePrint )
			NgDocPrint( "STJ", cBchSTJ, STJ->TJ_ORDEM, nTypePrint )
		EndIf
	EndIf

	RestArea(aArea)

Return
