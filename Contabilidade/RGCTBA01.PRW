#INCLUDE 'PROTHEUS.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ RGCTBA01  ³ Autor(a) ³ Ednilson Ap. Amarante - TOTVS   ³ Data ³ 05/09/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Programa utilizado para realizar a contabilizacao de forma off-line da     ³±±
±±³           ³ compensacao do cheque e/ou do pagamento antecipado.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³                                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ U_RGCTBA01()                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador            ³ Data       ³ Chamado ³ Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                        ³            ³         ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


// criar indice com nickname "RGCTBA01"
// E5_FILIAL+E5_RECPAG+DTOS(E5_DTDISPO)+E5_NUMCHEQ+E5_DOCUMEN+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ

User Function RGCTBA01()

Local lPadChq
Local lPadPA
Local aSays			:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local lContab		:= .T.
Private cPerg		:= Padr("RGCTBA01",Len(SX1->X1_GRUPO))
Private cPadChq		:= "Z02"
Private cPadPA		:= "Z03"

lPadChq		:= VerPadrao(cPadChq)
lPadPA		:= VerPadrao(cPadPA)

AjustaSX1()

If !Pergunte(cPerg,.T.)
	Return()
EndIf

ProcLogIni(aButtons)

AADD(aSays,OemToAnsi("  Este programa tem como objetivo efetuar a contabilização das      "))
AADD(aSays,OemToAnsi("compensações de cheques e/ou dos pagamentos antecipados             "))
AADD(aSays,OemToAnsi("de forma Off-Line.                                                  "))

AADD(aButtons,{1,.T.,{|o| nOpca:= 1,o:oWnd:End()}})
AADD(aButtons,{2,.T.,{|o| o:oWnd:End() }})
AADD(aButtons,{5,.T.,{|| Pergunte(cPerg,.T. ) } })

FormBatch("Contabilização Off-Line Compensação de Cheque / Pagamento Antecipado",aSays,aButtons ,,,420)

If mv_par05 == 1 .And. !lPadChq
	Alert("Para executar a rotina para cheque é necessário ter pelo menos uma sequência ativa do lançamento padrão Z02.")
	lContab := .F.
ElseIf mv_par05 == 2 .And. !lPadPA
	Alert("Para executar a rotina para pagamento antecipado é necessário ter pelo menos uma sequência ativa do lançamento padrão Z03.")
	lContab := .F.
ElseIf !lPadChq .And. !lPadPA
	Alert("Para executar a rotina para ambos é necessário ter pelo menos uma sequência ativa do lançamento padrão Z02 ou Z03.")
	lContab := .F.
EndIf

If mv_par06 == 2 .And. !MsgNoYes("ATENÇÃO: o parâmetro Recontabiliza está definido como SIM. " +;
									"Se continuar o processamento as movimentações já contabilizadas " +;
									"anteriormente serão recontabilizadas podendo gerar lançamentos em duplicidade." +;
									Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
									"TEM CERTEZA QUE DESEJA CONTINUAR?","CONFIGURADO PARA RECONTABILIZAR")
	Return()
EndIf

If nOpcA == 1 .And. lContab
	Processa( {|| RGCTBA01PR() }, "Aguarde...", "Obtendo dados...",.F.)
EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ RGCTBA01PR³ Autor(a) ³ Ednilson Ap. Amarante - TOTVS   ³ Data ³ 05/09/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Programa utilizado para executar a contabilizacao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ RGCTBA01()                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador            ³ Data       ³ Chamado ³ Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                        ³            ³         ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RGCTBA01PR()
Local aAreaSE5 := SE5->(GetArea())
Local lMostraLct
Local lAglutLct
Local dDataAnt
Local cArquivo
Local dDTBaseAnt
Local cCondic
Local lRecont
Local nRecnoSE5
Local nTipoCTB
//Local cChave
Local cArqInd
Local nIndex
Local nReg			:= 0
Local lHead			:= .F.
Local nHdlPrv		:= 0
Local cLote			:= GetNewPar("MV_X_LTCPA","008856")
Local aFlagCTB 		:= {}
Local nTotal		:= 0
Private dDataIni
Private dDataFin

ProcLogAtu(".","Inicio do processamento","Data de " + DTOC(mv_par03) + " ate " + DTOC(mv_par04) + " na Filial " + cFilAnt + ".")

lMostraLct	:= IIf(mv_par01==1,.T.,.F.)
lAglutLct	:= IIf(mv_par02==1,.T.,.F.)
dDataIni	:= IIf(Empty(mv_par03),CTOD("01/01/1900"),mv_par03)
dDataFin	:= mv_par04
nTipoCTB	:= mv_par05
dDTBaseAnt	:= dDataBase
lRecont		:= IIf(mv_par06==2,.T.,.F.)

// cChave := "E5_FILIAL+E5_RECPAG+DTOS(E5_DTDISPO)+E5_NUMCHEQ+E5_DOCUMEN+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ"

cCondic := "E5_FILIAL == FWXFILIAL('SE5') .AND. E5_DTDISPO >= dDataIni .AND. E5_DTDISPO <= dDataFin "
cCondic += " .AND. EMPTY(ALLTRIM(E5_KEY)) .AND. E5_RECPAG == 'P' "

If nTipoCTB == 1
	cCondic += ".AND. E5_TIPODOC == 'CH'"
ElseIf nTipoCTB == 2
	cCondic += ".AND. E5_TIPODOC == 'PA'"
Else
	cCondic += ".AND. E5_TIPODOC $ 'CH#PA'"
EndIf

If !lRecont 
	cCondic += " .AND. E5_LA <> 'S'"
EndIf

DbSelectArea("SE5")
SE5->(DbOrderNickname("RGCTBA01"))
SE5->(DbSetFilter({|| &(cCondic) }, cCondic))

//cArqInd := CriaTrab(,.F.)
//IndRegua("SE5",cArqInd,cChave,,cCondic,,.F.)
//DbSelectArea("SE5")
//nIndex := RetIndex("SE5")

SE5->(DbGoTop())
Count to nReg
SE5->(DbGoTop())

DbSelectArea("SA2")
SA2->(DbSetOrder(1))

DbSelectArea("SA6")
SA6->(DbSetOrder(1))

DbSelectArea("SE2")
SE2->(DbSetOrder(1))

DbSelectArea("SED")
SED->(DbSetOrder(1))	

ProcRegua(nReg)

While SE5->(!EOF())
	dDataAnt	:= SE5->E5_DTDISPO
	dDataBase	:= SE5->E5_DTDISPO
	
	IncProc("Processando... Data: " + DTOC(SE5->E5_DTDISPO))
	
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA))
	
	SA6->(DbSetOrder(1))
	SA6->(DbSeek(xFilial("SA6")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
	
	SE2->(DbSetOrder(1))
	SE2->(DbSeek(SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))

	SED->(DbSetOrder(1))
	SED->(dbSeek(xFilial("SED")+SE5->E5_NATUREZ))
	
	If !lHead
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa Lancamento Contabil                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nHdlPrv := HeadProva(cLote,;
		                     "RGCTBA01" /*cPrograma*/,;
		                     Alltrim(cUserName),;
		                     @cArquivo)
		lHead := .T.
	EndIf
	
	//Contabiliza a compensacao de cheque
	If nTipoCTB != 2 .And. SE5->E5_TIPODOC == "CH"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Prepara Lancamento Contabil                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aFlagCTB,{"E5_LA","S","SE5",SE5->(Recno()),0,0,0})
		
		nTotal += DetProva(nHdlPrv,;
						   cPadChq,;
						   "RGCTBA01" /*cPrograma*/,;
						   cLote,;
						   /*nLinha*/,;
						   /*lExecuta*/,;
						   /*cCriterio*/,;
						   /*lRateio*/,;
						   /*cChaveBusca*/,;
						   /*aCT5*/,;
						   /*lPosiciona*/,;
						   @aFlagCTB,;
						   /*aTabRecOri*/,;
						   /*aDadosProva*/ )
	EndIf
	
	//Contabiliza o pagamento antecipado
	If nTipoCTB != 1 .And. SE5->E5_TIPODOC == "PA"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Prepara Lancamento Contabil                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aFlagCTB,{"E5_LA","S","SE5",SE5->(Recno()),0,0,0})
		
		nTotal += DetProva(nHdlPrv,;
						   cPadPA,;
						   "RGCTBA01" /*cPrograma*/,;
						   cLote,;
						   /*nLinha*/,;
						   /*lExecuta*/,;
						   /*cCriterio*/,;
						   /*lRateio*/,;
						   /*cChaveBusca*/,;
						   /*aCT5*/,;
						   /*lPosiciona*/,;
						   @aFlagCTB,;
						   /*aTabRecOri*/,;
						   /*aDadosProva*/ )
	EndIf
						   
	SE5->(DbSkip())
	
	If dDataAnt != SE5->E5_DTDISPO .Or. SE5->(EOF())
		
		nRecnoSE5 := SE5->(Recno())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetiva Lan‡amento Contabil                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RodaProva(nHdlPrv,;
			      nTotal)

		cA100Incl(cArquivo,;
			      nHdlPrv,;
			      /*nOpcx*/,;
			      cLote,;
			      lMostraLct,;
			      lAglutLct,;
			      /*cOnLine*/,;
			      /*dData*/,;
			      /*dReproc*/,;
			      @aFlagCTB,;
			      /*aDadosProva*/,;
			      /*aDiario*/)
					   
		aFlagCTB	:= {}  // Limpa o coteudo apos a efetivacao do lancamento
		lHead 		:= .F.
		nTotal		:= 0 
		
		// Forca o reposicionamento na tabela SE5 para corrigir falha da cA100Incl que deposiciona o arquivo ao setar as Flags
		DbSetOrder(nIndex)
		SE5->(DbGoTo(nRecnoSE5))
	EndIf	
End

ProcLogAtu(".","Termino do processamento","Data de " + DTOC(mv_par03) + " ate " + DTOC(mv_par04) + " na Filial " + cFilAnt + ".")

dDataBase := dDTBaseAnt

DbSelectArea("SE5")
SE5->(DbClearFilter())

MsgInfo("Contabilização concluída.")	
if !Empty(aAreaSE5)
    SE5->(RestArea(aAreaSE5))
endif
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ AjustaSX1 ³ Autor(a) ³ Ednilson Ap. Amarante - TOTVS   ³ Data ³ 05/09/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Programa utilizado para criar ou ajustar o grupo de perguntas.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ RGCTBA01()                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador            ³ Data       ³ Chamado ³ Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Ednilson Ap. Amarante  ³ 23/08/2013 ³         ³ Inclusao de parametro para permitir    ³±±
±±³ #EAA-20130823          ³            ³         ³ a recontabilizacao de movimento ja     ³±±
±±³                        ³            ³         ³ contabilizado anteriormente.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()

Local aArea := GetArea()
Local aRegs	:= {}  

//			CPERG	CORDEM	CPERGPORT							CPERSPA								CPERENG								CVAR  		CTIPO	NTAM	 NDEC1	NPRESEL COBJ	CVALID	CVARUSO		CDEF01		CDEFSPA1	CDEFENG1	CCONT01					CVAR02	CDEF02			CDEFSPA2		CDEFENG2		CCNT02	CVAR03	CDEF03	CDEFSPA3	CDEFENG3	CCNT03	CVAR04	CDEF04	CDEFSPA4	CDEFENG4	CCNT04	CVAR05	CDEF05	CDEFSPA5	CDEFENG5	CCNT05	CF3		CPYME		CGRPSXG		AHELPPOR																																								AHELPENG	AHELPSPA	CHELP
AAdd(aRegs,{cPerg	,"01"	,"Mostra Lanc Contab. ?         "	,"¿Muestra Asientos ?           "	,"Display Accnt.Entries ?       "	,"mv_ch1"	,"N"	,1		,0		,2		,"C"	,""		,"mv_par01"	,"Sim"		,"Si"		,"Yes"		,""						,""		,"Nao"			,"No"			,"No"			,""		,""		,""		,""			,""			,""		,""		,""		,""			,""			,""		,""		,""		,""			,""			,""		,""		,"S"		,""			,{"Selecione a opção “Sim” para que os   ","lançamentos contábeis sejam exibidos  ","ao final da movimentação, ou “Não”,   ","caso contrário.                       "}	,""			,""			,""})
AAdd(aRegs,{cPerg	,"02"	,"Aglutina Lanc Contab ?        "	,"¿Agrupa Asientos ?            "	,"Group Accnt.Entries ?         "	,"mv_ch2"	,"N"	,1		,0		,2		,"C"	,""		,"mv_par02"	,"Sim"		,"Si"		,"Yes"		,""						,""		,"Nao"			,"No"			,"No"			,""		,""		,""		,""			,""			,""		,""		,""		,""			,""			,""		,""		,""		,""			,""			,""		,""		,"S"		,""			,{"Selecione a opção “Sim” para que os   ","lançamentos referentes a uma mesma    ","conta sejam aglutinados em um único   ","lançamento, ou “Não”, caso contrário. "}	,""			,""			,""})
AAdd(aRegs,{cPerg	,"03"	,"Da Data ?                     "	,"¿A Fecha ?                    "	,"From Date ?                   "	,"mv_ch3"	,"D"	,8		,0		,0		,"G"	,""		,"mv_par03"	,""			,""			,""			,"CTOD('  /  /    ')"	,""		,""				,""				,""				,""		,""		,""		,""			,""			,""		,""		,""		,""			,""			,""		,""		,""		,""			,""			,""		,""		,"S"		,""			,{"Informe a data inicial do intervalo de"," datas a serem consideradas para      ","ageração dos lançamentos contábeis    ","off line.                             "}	,""			,""			,""})
AAdd(aRegs,{cPerg	,"04"	,"Ate a Data ?                  "   ,"¿A Fecha ?                    "	,"To Date ?                     "	,"mv_ch4"	,"D"	,8		,0		,0		,"G"	,""		,"mv_par04"	,""			,""			,""			,"CTOD('31/12/2100')"	,""		,""				,""				,""				,""		,""		,""		,""			,""			,""		,""		,""		,""			,""			,""		,""		,""		,""			,""			,""		,""		,"S"		,""			,{"Informe a data final do intervalo de  ","datas a serem consideradas para       ","ageração dos lançamentos contábeis    ","off line.                             "}	,""			,""			,""})
AAdd(aRegs,{cPerg	,"05"	,"Contabilizar ?                "	,"Contabilizar ?                "	,"Contabilizar ?                "	,"mv_ch5"	,"N"	,1		,0		,1		,"C"	,""		,"mv_par05"	,"Cheque"	,"Cheque"	,"Cheque"	,""						,""		,"Pg.Antecipado","Pg.Antecipado","Pg.Antecipado",""		,""		,"Ambos","Ambos"	,"Ambos"	,""		,""		,""		,""			,""			,""		,""		,""		,""			,""			,""		,""		,"S"		,""			,{"Selecione a opção para que a geração  ","do documento contábil se dê por       ","Período ou Documento.                 ","                                      "}	,""			,""			,""})
AAdd(aRegs,{cPerg	,"06"	,"Recontabiliza ?               "	,"Recontabiliza ?               "	,"Recontabiliza ?               "	,"mv_ch6"	,"N"	,1		,0		,2		,"C"	,""		,"mv_par06"	,"Nao"		,"No"		,"No"		,""						,""		,"Sim"			,"Si"			,"Yes"			,""		,""		,""		,""			,""			,""		,""		,""		,""			,""			,""		,""		,""		,""			,""			,""		,""		,"S"		,""			,{"Selecione a opção “Sim” para que os   ","lançamentos contábeis já              ","contabilizados anteriormente          ","sejam recontabilizados.               "}	,""			,""			,""})

ValidPerg(aRegs,cPerg,.T.)

RestArea(aArea)
 
Return()