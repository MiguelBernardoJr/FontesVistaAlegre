#INCLUDE "MNTA120.CH"
#INCLUDE "FOLDER.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PROTHEUS.CH"

Static lRel12133 := GetRPORelease() >= '12.1.033'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA120
Cadastro de Manutenção.
@type User Function

@author	Paulo Pego
@since 01/01/2000

@param  cManut , string, Código da manutenção.
@return
/*/
//---------------------------------------------------------------------
User Function xMNTA120( cManut )
	Local aNGBEGINPRM  := {}
	Local aCores       := {}

	Private lSH1
	Private aTROCAF3   := {}
	Private aNGFIELD   := {}
	Private aRotina    := {}
	Private aAddTT9    := {}
	Private aCopyST5   := {}
	Private cParFr     := 'N'
	Private cRetPar    := ' '
	Private cPrograma  := 'MNTA120'
	Private cCADASTRO  := ''
	Private cManute    := ''
	Private TG_TIPOREG := 'M'
	Private lTipMod    := .F.
	Private lOK        := .F.
	Private lCORRET    := .F.
	Private lTLTTIPINS := .F.
	Private lChkPR     := .T.
	Private nOPCAO     := 0
	Private nPCONTFIXO := 0
	Private nPERFIXO   := 0
	Private nCONTROGD  := 1
	Private dProxManu

	Private cSEQTRB,cSER120,cSEQ120,cBEM120,cALIAS,nOPCX,nOPCOES,nNOMETA,nETAPA,nNOMECO,nQTDGAR
	Private nTAREFA,nTARG,nTARH,nTIPORE,nCODIGO,nQUANRE,nQUANTI,nUNIDAD,nDESTIN,nRESERV,nDESCRI
	Private nDOCTOSTH,nDOCFILSTH,nTARM,nDEPEND,nNOMDEP,nDOCTO,nDOCFIL,nUNIGAR,nSOBREP,nALMOX, nFornec, nLoja

	// Variaveis utilizadas na copia da manutencao
	Private lCopia     := .F.
	Private aTFArea	   := {}

	// Variaveis utilizadas na legenda das manutencoes (NG120CHK())
	Private nDiasTol   := 0
	Private lContManu  := .F.
	Private lOpEtapa   := .T.
	Private lTolera    := .T. // Verificar a necessidade de remover
	Private lTolConE   := .T.

	aPOS1   := {15,1,78,315}
	aCHOICE := {}
	aVARNAO := {}

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 88, 35, 95 )

		aNGBeginPrm := NGBeginPrm()

		aTFArea     := STF->( GetArea() )
		cParFr      := SuperGetMv( 'MV_NGMNTFR', .F., ' ' )
		lTipMod     := lRel12133 .Or. ( IIf( cParFr == Nil .Or. Empty( cParFr ) .Or. cParFr == 'N', .F., .T. ) )
		aRotina     := MenuDef()
		cCADASTRO   := IIf( cMANUT == 'L', OemToANSI( STR0031 ), OemToANSI( STR0009 ) )
		cManute     := cManut
		nPCONTFIXO  := SuperGetMv( 'MV_NGCOFIX', .F., 0 )          // Percentual para calcular o contador fixo da manutencao
		nPERFIXO    := nPCONTFIXO / 100
		lChkPR      := SuperGetMv( 'MV_NGCOQPR', .F., 'N' ) == 'S' // Checa qtd. de peças de reposição
		lTolConE    := NGCADICBASE( 'TF_MARGEM', 'A', 'STF', .F. ) // Quando este campo existe, realiza uma regra específica do cliente.

		If Type( "aNgButton" ) <> "A"
			aNgButton := {}
		EndIf

		//--------------------------------------------------
		// Carrega array de botões para Ações relacionadas
		// baseados nas tabelas de clique da direita
		//--------------------------------------------------
		If Len( aNgButton ) == 0
			NGClickBar( @aNgButton, NGRIGHTCLICK("MNTA120") )
		EndIf

		aAdd(aNgButton,{"PARAMETROS" ,{||MNT120QDO()},STR0047,STR0112})//"Relacionar documento(Manutencao/Tarefa)" ## "Rel.Doc."

		lMan := If(cManute = Nil,.T.,.F.)

		NGSETIFARQUI("STF","I")

		aCores := {{'STF->TF_ATIVO = "N"','BR_PRETO'},;
				{"NG120CHK('V')"      ,'BR_AMARELO'},;
				{"NG120CHK('A')"      ,'BR_VERMELHO'},;
				{".T."                ,'BR_VERDE'   }}

		MBROWSE(6,1,22,75,"STF",,,,,,aCores,,,,,,,, fFilterBrw("MNTA120") )

		NGIFFILSEEK("STF",xFilial("STF"),1,.F.)

		NgReturnPrm( aNgBeginPrm )

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} NG120FOLD

Funcao para montagem de folder

@author Deivys Joenck
@since 21/07/2001
@version 1.0
@sample MNTA120
@return Nill
/*/
//---------------------------------------------------------------------
User Function NG120FOLD(cALIAS1,nREG,nOPCX)

	//Guarda conteudo e declara variaveis padroes
	Local oFONT			:= Nil
	Local oGET			:= Nil
	Local oPanelTot		:= Nil
	Local cGET			:= ""
	Local cKey			:= ""
	Local cWhile		:= ""
	Local nI			:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local nOK			:= 0
	Local aNGBEGINPRM	:= IIf(!IsInCallStack("MNTA120"),NGBEGINPRM(,"MNTA120",,.F.),{})
	Local lGETD			:= .F.
	Local aPAGES		:= {}, aTITLES := {}, aVAR := {}, bCAMPO := {|nCPO| Field(nCPO)}
	Local aNoFields		:= {}
	Local aOldTP1		:= {}
	Local oSize			:= FwDefSize():New(.T.)
	Local nLinIniTl		:= oSize:aWindSize[1] // Linha  inicial da tela
	Local nColIniTl		:= oSize:aWindSize[2] // Coluna inicial da tela
	Local nLinFimTl		:= oSize:aWindSize[3] // Linha  final   da tela
	Local nColFimTl		:= oSize:aWindSize[4] // Coluna final   da tela
	Local aWhen			:= {}
	Local aInfo	  		:= {}
	Local aPosObj   	:= {}
	Local aPOS1     	:= {}

	Private oGET01    := Nil
	Private oGET02    := Nil
	Private oGET03    := Nil
	Private oGET04    := Nil
	Private oENC01    := Nil
	Private oFOLDER   := Nil
	Private oDLG      := Nil
	Private oMenu     := Nil
	Private n         := 1
	Private x         := 0
	Private lOK       := .F.
	Private INCLUI    := If(nOPCX = 3,.T.,.F.)
	Private aSVHEADER := {{},{},{},{}}
	Private aSVCOLS   := {{},{},{},{}}
	Private aSVATELA  := {}
	Private aSVAGETS  := {}
	Private aTELA     := {}
	Private aSt5Tar   := {}
	Private aGETS     := {}
	Private nINDSTH	  := 1
	Private nINDTPH   := 1
	Private cDesTar	  := Space(Len(st5->t5_descric))
	Private nCONTROL  := 0
	Private aAddTT9   := {}
	Private aCopyST5  := {}
	Private lChkPR    := SuperGetMv("MV_NGCOQPR",.F.,"N") == "S" //checa qtd pecas de reposicao
	Private lIntRM    := AllTrim(GetNewPar("MV_NGINTER","N")) == "M" //Variável utilizada no fonte MNTA410
	Private nCONTROGD := 1
	Private lOpEtapa  := .T.

	//Variavel que indicara se sera copia da manutencao
	Private lCopia    := If(Type("lCopia") = "L",lCopia,.F.)
	Private aTFAreaf  := STF->(GetArea())
	Private aCopyTP1  := {}
	Private aSize     := MsAdvSize(, .F., 430)
	Private aObjects  := {}

	//Dados temporarios da Substituicao de OS (tecla F11)
	Private aVetorF11 := {}
	Private nOPCAO    := nOPCX
	Private lWhenOs   := .T.
	Private lTolConE  := If(NGCADICBASE("TF_MARGEM","A","STF",.F.),.T.,.F.)

	lSeqEta := .F.

	If FindFunction("NGSEQETA")
		lSeqEta := .T.
		nINDSTH := NGSEQETA("STH",nINDSTH)
		nINDTPH := NGSEQETA("TPH",nINDTPH)
	EndIf

	SetKey(VK_F12,{||NGINSUF12("M->TG_CODIGO",M->TF_CODBEM,aCOLS[n,nTIPORE],.T.,3,"TG_NOMECOD",,"TG_QUANTID","TG_UNIDADE")})

	If Type("STF->TF_SUBSTIT") == "C"
		SetKey(VK_F11,{|| NG120F11( M->TF_CODBEM , M->TF_SERVICO , nOPCAO , .F. ) })
	EndIf

	aAdd(aTITLES,OEMTOANSI(STR0009))
	aAdd(aPAGES,"HEADER 1")
	nCONTROL++
	aAdd(aTITLES,OEMTOANSI(STR0026))
	aAdd(aPAGES,"HEADER 2")
	nCONTROL++
	aAdd(aTITLES,OEMTOANSI(STR0027))
	aAdd(aPAGES,"HEADER 3")
	nCONTROL++
	aAdd(aTITLES,OEMTOANSI(STR0030))
	aAdd(aPAGES,"HEADER 4")
	nCONTROL++
	aAdd(aTITLES,OEMTOANSI(STR0028))
	aAdd(aPAGES,"HEADER 5")
	nCONTROL++

	lGETD := If((nOPCAO # 2 .OR. nOPCAO # 5),.T.,.F.) // Visual

	//Nao remover, função chamada por outras rotinas
	If Type( "aNgButton" ) <> "A"
		aNgButton := {}
	EndIf

	//Se for alteracao faz copia inicial do TP1
	If nOPCAO == 4 .And. !lCopia
		dbSelectArea("TP1")
		dbSeek(xFilial("TP1")+STF->TF_CODBEM+STF->TF_SERVICO+STF->TF_SEQRELA)
		While !EoF() .And. xFilial("TP1")  == TP1->TP1_FILIAL .And. STF->TF_CODBEM  == TP1->TP1_CODBEM;
					 .And. STF->TF_SERVICO == TP1->TP1_SERVIC .And. STF->TF_SEQRELA == TP1->TP1_SEQREL

			aAdd(aOldTP1,{})
			For nI := 1 to FCOUNT()
				aAdd(aOldTP1[Len(aOldTP1)],&("TP1->"+FieldName(nI)))
			Next nI
			dbSkip()

		EndDo
	EndIf


	aAdd(aObjects,{015,020,.T.,.T.})
	aAdd(aObjects,{100,100,.T.,.T.})

	aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.T.)
	aPOS1 	:= {15,1,140,aPosObj[2,4]}

	DEFINE MSDIALOG oDLG TITLE cCADASTRO From nLinIniTl,nColIniTl To nLinFimTl,nColFimTl Of oMAINWND Pixel STYLE nOR(WS_VISIBLE,WS_POPUP)

		oPanelTot            := TPanel():Create(oDLG,0,0,,,.F.,,,CLR_WHITE,0,0)
		oPanelTot:Align      := CONTROL_ALIGN_ALLCLIENT
		oDLG:lMaximized      := .T.

		oFOLDER            := TFOLDER():New(1,0,aTITLES,aPAGES,oPanelTot,,,,.F.,.F.,320,200,)
		oFolder:bChange    := {|| ChangeGet()}
		oFolder:bSetOption := {|| CheckCols() }
		oFOLDER:aDIALOGS[1]:oFONT := oDLG:oFONT
		oFOLDER:aDIALOGS[2]:oFONT := oDLG:oFONT
		oFOLDER:aDIALOGS[3]:oFONT := oDLG:oFONT
		oFOLDER:aDIALOGS[4]:oFONT := oDLG:oFONT
		oFOLDER:aDIALOGS[5]:oFONT := oDLG:oFONT

		//GetDados 01
		NGDBAREAORDE("ST5",1)
		aHeader := {}
		aCols   := {}

		aAdd(aNoFields, 'T5_CODBEM')
		aAdd(aNoFields, 'T5_SERVICO')
		aAdd(aNoFields, 'T5_SEQRELA')

		cQuery := " SELECT * "
		cQuery += "   FROM " + RetSqlName("ST5") + " ST5 "
		cQuery += "  WHERE ST5.T5_FILIAL  = '" + xFilial("ST5")  + "'"
		cQuery += "    AND ST5.T5_CODBEM  = '" + STF->TF_CODBEM  + "'"
		cQuery += "    AND ST5.T5_SERVICO = '" + STF->TF_SERVICO + "'"
		cQuery += "    AND ST5.T5_SEQRELA = '" + STF->TF_SEQRELA + "'"
		cQuery += "    AND ST5.D_E_L_E_T_ = ' '"

		If nOpcx == 3
			FillGetDados( nOpcx,"ST5",1,,,,aNoFields,,,cQuery,,,aHeader,aCols)
		Else
			cSeekKey   := xFilial("ST5")+STF->TF_CODBEM+STF->TF_SERVICO+STF->TF_SEQRELA
			bSeekWhile := {|| ST5->T5_FILIAL + ST5->T5_CODBEM + ST5->T5_SERVICO + ST5->T5_SEQRELA}
			FillGetDados( nOpcx,"ST5",1 ,cSeekKey,bSeekWhile,Nil,aNoFields,Nil  ,Nil,Nil,Nil,Nil,aHeader,aCols)
		EndIf

		NGSETIFARQUI("ST5","F",1)

		If Empty(aCOLS) .OR. nOPCAO == 3
			aCOLS := BLANKGETD(aHEADER)
		Else
			aSt5Tar := aClone(aCols)
		EndIf

		//For para adição dos campos editaveis na GETDADOS
		If nOPCX <> 2
			For nX:= 1 to Len(aHEADER)
				AAdd(aWhen,aHEADER[nX][2])
			Next
		EndIf

		nTAREFA      := GDFIELDPOS("T5_TAREFA")
		nDESCRI      := GDFIELDPOS("T5_DESCRIC")
		nDOCTO       := GDFIELDPOS("T5_DOCTO")
		nDOCFIL      := GDFIELDPOS("T5_DOCFIL")
		aSVHEADER[1] := aCLONE(aHEADER)
		aSVCOLS[1]   := aCLONE(aCOLS)
		aCopyST5     := aCLONE(aCOLS)
		n            := Len(aCOLS)

		oGET01 := MsNewGetDados():New( 0, 0, 125, 315, GD_INSERT + GD_UPDATE + GD_DELETE, 'NG120LINOK()', 'AllwaysTrue',;
		                               '', aWhen, ,9999, , , "NGFOLDTAR( 'E', 'N' ) .And. MNT120AET5()", oFolder:aDialogs[2],;
									   aHeader,aCols )

		oGET01:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGET01:oBROWSE:DEFAULT()
		oGET01:oBROWSE:REFRESH()

		//GetDados 02
		aHeader		:= {}
		aCols		:= {}
		aNoFields	:= {}
		aWhen		:= {}

		NGSETIFARQUI("STM","F",1)
		aAdd(aNoFields, 'TM_CODBEM')
		aAdd(aNoFields, 'TM_SERVICO')
		aAdd(aNoFields, 'TM_SEQRELA')
		aAdd(aNoFields, 'TM_NOMETAR')

		cQuery := "SELECT * FROM "+RetSqlName("STM")+" STM WHERE STM.TM_FILIAL = '"+xFilial("STM")+"' AND STM.TM_CODBEM = '"+STF->TF_CODBEM+"'"+;
			" AND STM.TM_SERVICO = '"+STF->TF_SERVICO+"' AND STM.TM_SEQRELA = '"+STF->TF_SEQRELA+"' AND STM.D_E_L_E_T_ = ' '"
		FillGetDados( nOpcx, "STM", 1, xFilial("STM")+STF->TF_CODBEM+STF->TF_SERVICO+STF->TF_SEQRELA, {|| "STM->TM_FILIAL + STM->TM_CODBEM + STM->TM_SERVICO + STM->TM_SEQRELA"}, {|| .T.},aNoFields,,,cQuery)

		NGSETIFARQUI("STM","F",1)
		If Empty(aCOLS) .OR. nOPCAO == 3
			aCOLS := BLANKGETD(aHEADER)
		EndIf

		//For para adição dos campos editaveis na GETDADOS
		If nOPCX <> 2
			For nX:= 1 to Len(aHEADER)
				AAdd(aWhen,aHEADER[nX][2])
			Next
		EndIf

		nTARM        := GDFIELDPOS("TM_TAREFA")
		nDEPEND      := GDFIELDPOS("TM_DEPENDE")
		nNOMDEP      := GDFIELDPOS("TM_NOMEDEP")
		nSOBREP      := GDFIELDPOS("TM_SOBREPO")
		aSVHEADER[2] := aCLONE(aHEADER)
		aSVHEADER[2][nTARM][6] += " .And. NG130CHECK(M->TM_TAREFA,.T.)" //Verifica se a tarefa dependende e dela mesma
		aSVCOLS[2]   := aCLONE(aCOLS)
		n            := Len(aCOLS)

		oGET02 := MsNewGetDados():New(0,0,125,315,GD_INSERT+GD_UPDATE+GD_DELETE,"NG120LINO2()","AllwaysTrue","",aWhen,,9999,,,"NGFOLDESM(nTAREFA,aCols[n,nTARM],aCols[n,nDEPEND])",oFolder:aDialogs[3],aHeader,aCols)
		oGET02:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGET02:oBROWSE:DEFAULT()
		oGET02:oBROWSE:REFRESH()

		//GetDados 03
		aHeader		:= {}
		aCols		:= {}
		aNoFields	:= {}
		aWhen		:= {}

		NGDBAREAORDE("STG",1)
		aAdd(aNoFields, 'TG_CODBEM')
		aAdd(aNoFields, 'TG_SERVICO')
		aAdd(aNoFields, 'TG_SEQRELA')
		aAdd(aNoFields, 'TG_NOMETAR')

		//GetDados não montado com uma query, pois esta não da suporte a campos do tipo memo.
		cKey 	:= "STF->TF_CODBEM+STF->TF_SERVICO+STF->TF_SEQRELA"
		cWhile 	:= "STG->TG_FILIAL == '"+xFilial('STG')+"' .And. STG->TG_CODBEM == '"+STF->TF_CODBEM+"' .And. STG->TG_SERVICO == '"+STF->TF_SERVICO+"'"+;
					".And. STG->TG_SEQRELA == '"+STF->TF_SEQRELA+"'"

		FillGetDados( nOpcx, "STG",,,,,aNoFields,,,,{||NGMontaAcols("STG", &cKey, cWhile)})

		NGSETIFARQUI("STG","F",1)
		If Empty(aCOLS) .OR. nOPCAO == 3
			aCOLS := BLANKGETD(aHEADER)
		EndIf

		//For para adição dos campos editaveis na GETDADOS
		If nOPCX <> 2
			For nX:= 1 to Len(aHEADER)
				AAdd(aWhen,aHEADER[nX][2])
			Next
		EndIf

		nTARG        := GDFIELDPOS("TG_TAREFA")
		nTIPORE      := GDFIELDPOS("TG_TIPOREG")
		nCODIGO      := GDFIELDPOS("TG_CODIGO")
		nNOMECO      := GDFIELDPOS("TG_NOMECOD")
		nQUANRE      := GDFIELDPOS("TG_QUANREC")
		nQUANTI      := GDFIELDPOS("TG_QUANTID")
		nUNIDAD      := GDFIELDPOS("TG_UNIDADE")
		nRESERV      := GDFIELDPOS("TG_RESERVA")
		nDESTIN      := GDFIELDPOS("TG_DESTINO")
		nQTDGAR      := GDFIELDPOS("TG_QTDGARA")
		nUNIGAR      := GDFIELDPOS("TG_UNIGARA")
		nALMOX       := GDFIELDPOS("TG_LOCAL")
		nFornec      := GDFIELDPOS("TG_FORNEC")
		nLoja        := GDFIELDPOS("TG_LOJA")
		aSVHEADER[3] := aCLONE(aHEADER)
		aSVCOLS[3]   := aCLONE(aCOLS)
		n            := Len(aCOLS)

		oGET03 := MsNewGetDados():New(0,0,125,315,GD_INSERT+GD_UPDATE+GD_DELETE,"NG120LINO3(3)","AllwaysTrue","",aWhen,,9999,,,"NGFOLDESM(nTAREFA,aCols[n,nTARG])",oFolder:aDialogs[4],aHeader,aCols)
		oGET03:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGET03:oBROWSE:DEFAULT()
		oGET03:oBROWSE:REFRESH()

		//GetDados 04
		aHeader		:= {}
		aCols		:= {}
		aNoFields	:= {}
		aWhen		:= {}

		NGDBAREAORDE("STH",nINDSTH)
		aAdd(aNoFields, 'TH_CODBEM')
		aAdd(aNoFields, 'TH_SERVICO')
		aAdd(aNoFields, 'TH_SEQRELA')

		cQuery := "SELECT * FROM "+RetSqlName("STH")+" STH WHERE STH.TH_FILIAL = '"+xFilial("STH")+"' AND STH.TH_CODBEM = '"+STF->TF_CODBEM+"'"+;
			      " AND STH.TH_SERVICO = '"+STF->TF_SERVICO+"' AND STH.TH_SEQRELA = '"+STF->TF_SEQRELA+"' AND STH.D_E_L_E_T_ = ' '"

		If lSeqEta
			cQuery += " ORDER BY TH_FILIAL,TH_CODBEM,TH_SERVICO,TH_SEQRELA,TH_TAREFA,TH_SEQETA,TH_ETAPA"
		EndIf

		FillGetDados( nOpcx, "STH", 1, xFilial("STH")+STF->TF_CODBEM+STF->TF_SERVICO+STF->TF_SEQRELA, {|| "STH->TH_FILIAL + STH->TH_CODBEM + STH->TH_SERVICO + STH->TH_SEQRELA"}, {|| .T.},aNoFields,,,cQuery)

		NGSETIFARQUI("STH","F",1)
		If Empty(aCOLS) .OR. nOPCAO == 3
			aCOLS := BLANKGETD(aHEADER)
		EndIf

		//For para adição dos campos editaveis na GETDADOS
		If nOPCX <> 2
			For nX:= 1 to Len(aHEADER)
				AAdd(aWhen,aHEADER[nX][2])
			Next
		EndIf

		nTARH        := GDFIELDPOS("TH_TAREFA")
		nETAPA       := GDFIELDPOS("TH_ETAPA")
		nNOMETA      := GDFIELDPOS("TH_NOMETAP")
		nOPCOES      := GDFIELDPOS("TH_OPCOES")
		nDOCTOSTH    := GDFIELDPOS("TH_DOCTO")
		nDOCFILSTH   := GDFIELDPOS("TH_DOCFIL")
		aSVHEADER[4] := aCLONE(aHEADER)
		aSVCOLS[4]   := aCLONE(aCOLS)
		n            := Len(aCOLS)

		oGET04 := MsNewGetDados():New(0,0,125,315,GD_INSERT+GD_UPDATE+GD_DELETE,"NG120LINO4(4)","AllwaysTrue","",aWhen,,9999,,,"NGFOLDESM(nTAREFA,aCols[n,nTARH])",oFolder:aDialogs[5],aHeader,aCols)
		oGET04:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGET04:oBROWSE:DEFAULT()
		oGET04:oBROWSE:REFRESH()

		//Enchoice 01
		aTELA := {}
		aGETS := {}

		NGDBAREAORDE("STF",1)
		nORDSTF1 := IndexOrd()

		//Faz copia da manutencao selecionada
		If lCopia

			RegToMemory("STF",.F.,.T.)
			aCopyTP1 := {}
			nOPCAO   := 3

			//Seta a inclusao
			SetInclui()

			//Limpa campos relacionados a antiga manutencao
			M->TF_DTULTMA := CTOD("  /  /  ")
			M->TF_CODBEM  := Space(Len(M->TF_CODBEM))
			M->TF_NOMBEM  := Space(Len(M->TF_NOMBEM))
			M->TF_SERVICO := Space(Len(M->TF_SERVICO))
			M->TF_NOMSERV := Space(Len(M->TF_NOMSERV))
			M->TF_SEQRELA := Space(Len(M->TF_SEQRELA))
			M->TF_NOMEMAN := Space(Len(M->TF_NOMEMAN))
			M->TF_CODAREA := Space(Len(M->TF_CODAREA))
			M->TF_NOMAREA := Space(Len(M->TF_NOMAREA))
			M->TF_TIPO    := Space(Len(M->TF_TIPO))
			M->TF_NOMTIPO := Space(Len(M->TF_NOMTIPO))
			M->TF_SEQREPA := Space(Len(M->TF_SEQREPA))
			M->TF_SUBSTIT := Space(Len(M->TF_SUBSTIT))
			M->TF_PLANEJA := If(Empty(M->TF_PLANEJA),"S",M->TF_PLANEJA)
			M->TF_ATIVO   := "S"
			M->TF_CONMANU := 0
			M->TF_PADRAO  := 'N'
			M->TF_QUANTOS := 0
		Else
			RegToMemory("STF",(nOPCAO == 3))
		EndIf

		oENC01            := MsMGet():New("STF",nREG,nOPCAO,,,,,aPOS1,,,,,,oFOLDER:aDIALOGS[1],,,.F.,"aSVATELA")
		oENC01:oBOX:Align := CONTROL_ALIGN_ALLCLIENT
		oENC01:oBOX:bGOTFOCUS := {|| NGENTRAENC("STF")}

		aSVATELA := aCLONE(aTELA)
		aSVAGETS := aCLONE(aGETS)

		@ 1000,1000 MSGET oGET VAR cGET PICTURE "@!" SIZE 1,01 //OF oFOLDER:aDIALOGS[5]

		// Determina se o campo TF_DTULTMA ficará aberto para edição
		lWhenOs := fValMnt( M->TF_CODBEM, M->TF_SERVICO, M->TF_SEQRELA )

		dbSelectArea("STF")
		dbSetOrder(01)

	ACTIVATE DIALOG oDLG ON INIT (ENCHOICEBAR(oDLG,{|| lOK:=.T.,If(NG120OBRIG(nOpcao),oDLG:END(),lOK := .F.)},;
		{|| lOK:= .F.,oDLG:END()},,aNgButton),,AlignObject(oDlg,{oFolder},1))

	If lOK .And. STR(nOPCAO ,1) $ "345"
		NG120GRAVA(nOPCAO)
	ElseIf !lOK
		lAltST5 := .F.
		If nOPCAO == 4 .Or. nOPCAO == 5
			If Len(oGET01:aCols) != Len(aCopyST5)
				lAltST5 := .T.
			Else
				For nI := 1 to Len(aCopyST5)
					If aTail(oGET01:aCols[nI])
						lAltST5 := .T.
						Exit
					ElseIf aCopyST5[nI][1] != (oGET01:aCols)[nI][1]
						lAltST5 := .T.
						Exit
					EndIf
				Next nI
			EndIf
		EndIf

		If nOPCAO == 3 .Or. lAltST5
			NGIFDBSEEK("ST5",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA,1)
			While !EoF() .And. ST5->T5_FILIAL  == xFilial("ST5") .And. ST5->T5_CODBEM  == M->TF_CODBEM ;
					     .And. ST5->T5_SERVICO == M->TF_SERVICO  .And. ST5->T5_SEQRELA == M->TF_SEQRELA
				NGDELETAREG("ST5")
				dbSkip()
			End

			If lAltST5
				For nI := 1 To Len(aCopyST5)
					RecLock("ST5",.T.)
					For nY := 1 To Len(aCopyST5[nI])-1
						nFieldPos := ST5->(FieldPos(oGET01:aHeader[nY][2]))
						If nFieldPos > 0
							FieldPut(nFieldPos,aCopyST5[nI][nY])
						EndIf
					Next nY
					ST5->T5_FILIAL  := xFilial("ST5")
					ST5->T5_CODBEM  := M->TF_CODBEM
					ST5->T5_SERVICO := M->TF_SERVICO
					ST5->T5_SEQRELA := M->TF_SEQRELA
					MsUnLock()
				Next nI
			EndIf
		EndIf

		//Se for inclusao e cancelar, deleta TP1 cadastrados
		If Len(aCopyTP1) > 0 .Or. Len(aOldTP1) > 0

			NGDBAREAORDE("TP1",1)
			nP1BEM  := FieldPos('TP1_CODBEM')
			nP1SER  := FieldPos('TP1_SERVIC')
			nP1SEQ  := FieldPos('TP1_SEQREL')
			nP1TAR  := FieldPos('TP1_TAREFA')
			nP1ETA  := FieldPos('TP1_ETAPA')
			nP1OPC  := FieldPos('TP1_OPCAO')
			lDelTP1 := .T.

			If nOPCAO == 4
				If Len(aCopyTP1) == Len(aOldTP1)
					lDelTP1 := .F.
					For nI := 1 to Len(aOldTP1)
						For nY := 1 to Len(aOldTP1[nI])
							If aOldTP1[nI][nY] != aCopyTP1[nI][nY]
								lDelTP1 := .T.
								Exit
							EndIf
						Next nY
						If lDelTP1
							Exit
						EndIf
					Next nI
				EndIf
			EndIf

			If lDelTP1
				For nI := 1 to Len(aCopyTP1)
					If dbSeek(xFilial("TP1")+aCopyTP1[nI][nP1BEM]+aCopyTP1[nI][nP1SER]+aCopyTP1[nI][nP1SEQ]+;
							aCopyTP1[nI][nP1TAR]+aCopyTP1[nI][nP1ETA]+aCopyTP1[nI][nP1OPC])
						NGDELETAREG("TP1")
					EndIf
				Next nI

				If nOPCAO == 4
					For nI := 1 to Len(aOldTP1)
						If dbSeek(xFilial("TP1")+aOldTP1[nI][nP1BEM]+aOldTP1[nI][nP1SER]+aOldTP1[nI][nP1SEQ]+;
								aOldTP1[nI][nP1TAR]+aOldTP1[nI][nP1ETA]+aOldTP1[nI][nP1OPC])
							RecLock("TP1",.F.)
						Else
							RecLock("TP1",.T.)
						EndIf

						For nY := 1 to Len(aOldTP1[nI])
							FieldPut(nY,aOldTP1[nI][nY])
						Next nY
						MsUnLock("TP1")
					Next nI
				EndIf
			EndIf
			aCopyTP1 := {}
		EndIf
	EndIf


	//Retorna lCopia falso
	lCopia := .F.

	//Ponto de entrada executado ao fechar Folder da manutencao
	dbSelectArea("STF")
	If ExistBlock("MNTA1201")
		ExecBlock("MNTA1201",.F.,.F.)
	EndIf

	STF->(dbGoTo(Recno()))
	//Retorna conteudo de variaveis padroes
	SetKey(VK_F11,nil)
	SetKey(VK_F12,nil)
	NGRETURNPRM(aNGBEGINPRM)

	RestArea(aTFAreaf)

Return//fim da funcao NG120FOLD

//---------------------------------------------------------------------
/*/{Protheus.doc} ENTRAGET

Retorna aCols e aHeader quando se foca a GETDADOS

@author Deivys Joenck
@since 14/08/2001
@version 1.0
@sample MNTA120
@return Nill
/*/
//---------------------------------------------------------------------
Static Function ENTRAGET(nG)

	Local cVAR     := "oGET"+STRZERO(nG,2)
	Local cHeadClo := cVar + ":aHeader"
	Local cAcolClo := cVar + ":aCols"

	cBEM120 := M->TF_CODBEM
	cSER120 := M->TF_SERVICO
	cSEQ120 := M->TF_SEQRELA

	aHeader := aClone(&cHeadClo)
	aCols   := aClone(&cAcolClo)
	n       := Len(aCols)

	oFOLDER:Refresh()
	&cVar:Refresh()
	&cVar:Refresh()

	If cVar = "oGET03"
		SetKey(VK_F4,{|| MntViewSB2(oGet03:aCols[oGet03:nAt,nTIPORE],oGet03:aCols[oGet03:nAt,nCODIGO]) })
	EndIf

	nCONTROGD := nG

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} NG120GRAVA

Funcao de gravacao dos dados.

@author Deivys Joenck
@since 24/07/2001
@version 1.0
@sample MNTA120
@return Booleano
/*/
//---------------------------------------------------------------------
User Function NG120GRAVA(nOPCS)

	Local ah,ny1,nX
	Local lRet
	Local lDEL     := .T.
	Local nCNT     := 0
	Local nRecno   := Recno()
	Local cHelpINT := Space(10)
	Local xConteudo := ""

	cBEM120 := M->TF_CODBEM
	cSER120 := M->TF_SERVICO
	cSEQ120 := M->TF_SEQRELA

	If nCONTROGD # 0
		NGSAIENC(nCONTROGD)
	EndIf

	dbSelectArea("STF")
	nORDSTF := IndexOrd()
	If nOPCS == 3 .Or. nOPCS == 4
		//Atualiza o arquivo principal (cALIAS)
		For ah := 1 To Len(aVARNAO)
			xx := aVARNAO[ah][1]
			yy := aVARNAO[ah][2]
			xConteudo := &(yy)
			If ValType(xConteudo) != 'U' .And. !Empty(yy)
				&xx. := &yy.
			EndIf
		Next

		If NGIFDBSEEK("STF",cBEM120+cSER120+cSEQ120,1)
			RecLock("STF",.F.)
		Else
			RecLock("STF",.T.)
		EndIf

		For ny1 := 1 To FCOUNT()
			nx1 := "M->" + FIELDNAME(ny1)
			xConteudo := &(nx1)

			If ValType(xConteudo) <> "U"
				If "_FILIAL"$UPPER(nx1)
					FieldPut(ny1, xFilial("STF"))
				Else
					If ValType(xConteudo) != "M"
						FieldPut(ny1, &nx1.)
					EndIf
				EndIf
			EndIf
		Next ny1

		dbSelectArea("STF")
		STF->TF_TIPLUB := NGSEEK("ST4",STF->TF_SERVICO,1,"T4_LUBRIFI")
		MsUnLock("STF")
		nREGSTF := Recno()

		For nX := 1 To Len(aVetorF11)
			If cSEQ120 <> aVetorF11[nX,1]
				If NGIFDBSEEK("STF",cBEM120+cSER120+aVetorF11[nX,1],1)
					RecLock("STF",.F.)
					STF->TF_SUBSTIT := aVetorF11[nX,3]
					STF->(MsUnLock())
				EndIf
			EndIf
		Next nX
		dbSelectArea("STF")
		dbGoTo(nREGSTF)

		GRAVASTM()
		GRAVASTG()
		GRAVASTH()
		GRAVATAF()
		GRAVTARPAD()
		GRATARGEN()

		EvalTrigger()  // Processa Gatilhos
		If nOPCS == 3
			ConfirmSX8()
		EndIf
	EndIf

	If nOPCS == 3
		RollBackSX8()
	EndIf

	If nOPCS == 5
		If NGIFDBSEEK("STJ","B"+M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA,2)
			cHelpINT := "OSMANUTENC"
		Else
			If NGIFDBSEEK("STS","B"+M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA,2)
				cHelpINT := "OSMANUTENC"
			EndIf
		EndIf

		If !Empty(cHelpINT)
			Help("",1,cHelpINT)
			Return .F.
		EndIf

		If lDEL
			NGIFDBSEEK("STG",cBEM120+cSER120+cSEQ120,1)
			While !EoF() .And. STG->TG_FILIAL  == xFilial("STG") .And. STG->TG_CODBEM == cBEM120 .And. STG->TG_SERVICO == cSER120 .And.;
					           STG->TG_SEQRELA == cSEQ120
				NGDELETAREG("STG")
				dbSkip()
			End

			NGIFDBSEEK("ST5",cBEM120+cSER120+cSEQ120,1)
			While !EoF() .And. ST5->T5_FILIAL  == xFilial("ST5") .And. ST5->T5_CODBEM  == cBEM120 .And. ST5->T5_SERVICO == cSER120 .And.;
					           ST5->T5_SEQRELA == cSEQ120
				NGDELETAREG("ST5")
				dbSkip()
			End

			NGIFDBSEEK("STH",cBEM120+cSER120+cSEQ120,1)
			While !EoF() .And. STH->TH_FILIAL  == xFilial("STH") .And. STH->TH_CODBEM  == cBEM120 .And. STH->TH_SERVICO == cSER120 .And.;
					           STH->TH_SEQRELA == cSEQ120
				NGIFDBSEEK("TP1",cBEM120+cSER120+cSEQ120+STH->TH_TAREFA+STH->TH_ETAPA,1)
				While !EoF() .And. TP1->TP1_FILIAL == xFilial("TP1") .And. TP1->TP1_CODBEM == cBEM120 .And. TP1->TP1_SERVIC == cSER120 .And.;
						           TP1->TP1_SEQREL == cSEQ120 .And. TP1->TP1_TAREFA == STH->TH_TAREFA .And. TP1->TP1_ETAPA  == STH->TH_ETAPA
					NGDELETAREG("TP1")
					dbSkip()
				End
				dbSelectArea("STH")
				NGDELETAREG("STH")
				dbSkip()
			End

			NGIFDBSEEK("STM",cBEM120+cSER120+cSEQ120,1)
			While !EoF() .And. STM->TM_FILIAL  == xFilial("STM") .And. STM->TM_CODBEM  == cBEM120 .And. STM->TM_SERVICO == cSER120 .And.;
					           STM->TM_SEQRELA == cSEQ120
				NGDELETAREG("STM")
				dbSkip()
			End
			dbSelectArea("STF")
			NGDELETAREG("STF")
			EvalTrigger()  // Processa Gatilhos

		EndIf
	EndIf
	NGDBAREAORDE("STF",nORDSTF)

Return .T.

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GRAVATAR  ³Autor ³ Deivys Joenck         ³ Data ³ 06/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para gravacao dos dados no aCols.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GRAVATAR()

	Local nx
	Local nMaxArray
	Local cTAR
	Local cTIP
	Local lRET := .T.
	Local i

	Private nlin

	NGDBAREAORDE("ST5",1)
	If aHeader[1][2] != "T5_TAREFA"
		aCols   := aClone(oGET01:aCols)
		aHeader := aClone(oGET01:aHeader)
	EndIf
	nMaxArray := Len(aCols)

	//Verifica se nao foi excluido nenhum registro e grava as novas inclusoes e alteracoes efetuadas
	For nx := 1 To nMaxArray
		If !Empty(aCols[nx][1])
			If aCols[nx][Len(aCols[nx])]
				If NGIFDBSEEK("ST5",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+aCols[nx][nTAREFA],1)
					cTAR := aCols[nx][nTAREFA]
					If nDESCRI > 0
						cTIP := aCols[nx][nDESCRI]
					EndIf
					nQTD := 0

					If nDESCRI > 0
						aEVAL(aCols,{|x| If(x[nTAREFA]+x[nDESCRI] == cTAR+cTIP,nQTD++,Nil)})
					EndIf

					If nQTD <= 1
						nLin := nx
						lRET := NG120CHKTAR()
						If !lRET
							lOK := .F.
							Return .F.
						EndIf
					EndIf
				EndIf
				dbSelectArea("ST5")
				If !EoF()
					NGDELETAREG("ST5")
				EndIf
				Loop
			EndIf

			If NGIFDBSEEK("ST5",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+aCols[nx][nTAREFA],1)
				RecLock("ST5",.F.)
			Else
				RecLock("ST5",.T.)
				ST5->T5_FILIAL  := xFilial("ST5")
				ST5->T5_CODBEM  := M->TF_CODBEM
				ST5->T5_SERVICO := M->TF_SERVICO
				ST5->T5_SEQRELA := M->TF_SEQRELA
			EndIf

			For i := 1 To FCOUNT()
				xx := GDFIELDPOS(AllTrim(FIELDNAME(i)))
				If xx > 0
					vv   := "ST5->"+FIELDNAME(i)
					&vv. := aCols[nx][xx]
				EndIf
			Next i

			MsUnLock("ST5")
		EndIf
	Next nx

	If !lOK
		aSVCOLS[1]   := aClone(oGET01:aCols)   //Não remover, utilizado no NGSAIGET
		aSVHEADER[1] := aClone(oGET01:aHeader) //Não remover, utilizado no NGSAIGET
		oGET01:oBROWSE:REFRESH()
		NGSAIGET(1)
	EndIf

	dbSelectArea("STF")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GRAVASTM  ³Autor ³ Deivys Joenck         ³ Data ³ 20/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para gravacao dos dados no aCols para o STM         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GRAVASTM()
Local nx,nMaxArray,cTAR,cDEP,i

nMaxArray := Len(oGET02:aCols)
aCols     := aClone(oGET02:aCols)
aHeader   := aClone(oGET02:aHeader)

If Empty(aCols[1][1])
   nMaxArray := 0
EndIf

NGIFDBSEEK("STM",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA,1)
While !EoF() .And. TM_FILIAL == xFilial("STM") .And.;
   TM_CODBEM  == M->TF_CODBEM .And. TM_SERVICO == M->TF_SERVICO .And.;
   TM_SEQRELA == M->TF_SEQRELA

   If aSCAN(aCOLS,{|x| x[nTARM]+x[nDEPEND] == TM_TAREFA+TM_DEPENDE}) == 0
      NGDELETAREG("STM")
   EndIf
   dbSkip(1)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se nao foi excluido nenhum registro e grava ³
//³ as novas inclusoes e alteracoes efetuadas            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx = 1 To nMaxArray
   If aCOLS[nx][Len(aCOLS[nx])]
      If NGIFDBSEEK("STM",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+aCOLS[nx][nTARM]+aCOLS[nx][nDEPEND],1)
         cTAR := aCOLS[nx][nTAREFA]
         cDEP := aCOLS[nx][nDEPEND]
         nQTD := 0

         aEVAL(aCOLS,{|x| If(x[nTARM]+x[nDEPEND] == cTAR+cDEP,nQTD++,Nil)})
         If nQTD <= 1
            NGDELETAREG("STM")
         EndIf
      EndIf
      Loop
   EndIf

   If !Empty(aCols[nx][nDepend])
      If NGIFDBSEEK("STM",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+aCOLS[nx][nTARM]+aCOLS[nx][nDEPEND],1)
         RecLock("STM",.F.)
      Else
         RecLock("STM",.T.)
         STM->TM_FILIAL  := xFilial("STM")
         STM->TM_CODBEM  := M->TF_CODBEM
         STM->TM_SERVICO := M->TF_SERVICO
         STM->TM_SEQRELA := M->TF_SEQRELA
      EndIf

      For i := 1 To FCOUNT()
         xx := GDFIELDPOS(AllTrim(FIELDNAME(i)))
         If xx > 0
            vv   := "STM->"+FIELDNAME(i)
            &vv. := aCOLS[nx][xx]
         EndIf
      Next i
   EndIf
   MsUnLock("STM")
Next nx
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GRAVASTG  ³Autor ³ Deivys Joenck         ³ Data ³ 17/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para gravacao dos dados no aCols para o STG         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GRAVASTG()
Local nx,nMaxArray,cTIPOREG,cTAR,cTIP,cCOD,i

nMaxArray := Len(oGET03:aCols)
aCols     := aClone(oGET03:aCols)
aHeader   := aClone(oGET03:aHeader)
If Empty(aCols[1][1])
   nMaxArray := 0
EndIf
NGIFDBSEEK("STG",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA,1)
While !EoF() .And. TG_FILIAL == xFilial("STG") .And.;
   TG_CODBEM  == M->TF_CODBEM .And. TG_SERVICO == M->TF_SERVICO .And.;
   TG_SEQRELA == M->TF_SEQRELA
   NGDELETAREG("STG")
   dbSkip(1)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se nao foi excluido nenhum registro e grava ³
//³ as novas inclusoes e alteracoes efetuadas            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx := 1 To nMaxArray
   If aCOLS[nx][Len(aCOLS[nx])]
      If NGIFDBSEEK("STG",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+aCOLS[nx][nTARG]+aCOLS[nx][nTIPORE]+aCOLS[nx][nCODIGO],1)
         cTAR := aCOLS[nx][nTARG]
         cTIP := aCOLS[nx][nTIPORE]
         cCOD := aCOLS[nx][nCODIGO]
         nQTD := 0

         aEVAL(aCOLS, {|x| If(x[nTARG]+x[nTIPORE]+x[nCODIGO] == cTAR+cTIP+cCOD,nQTD++,Nil)})
         If nQTD <= 1
            NGDELETAREG("STG")
         EndIf
      EndIf
      Loop
   EndIf

   If NGIFDBSEEK("STG",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+aCOLS[nx][nTARG]+aCOLS[nx][nTIPORE]+aCOLS[nx][nCODIGO],1)
      RecLock("STG",.F.)
   Else
      RecLock("STG",.T.)
      STG->TG_FILIAL  := xFilial("STG")
      STG->TG_CODBEM  := M->TF_CODBEM
      STG->TG_SERVICO := M->TF_SERVICO
      STG->TG_SEQRELA := M->TF_SEQRELA
   EndIf
   For i := 1 To FCOUNT()
      xx := GDFIELDPOS(AllTrim(FIELDNAME(i)))
      If xx > 0
         vv   := "STG->"+FIELDNAME(i)
         &vv. := aCOLS[nx][xx]
      EndIf
   Next i
   MsUnLock("STG")
Next nx
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GRAVASTH  ³Autor ³ Deivys Joenck         ³ Data ³ 21/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para gravacao dos dados no aCols para o STH         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GRAVASTH()
Local nx 	:= 0
Local nMaxArray := 0
Local nI 	:= 0
Local nY 	:= 0
Local cETA 	:= ""
Local cTAR 	:= ""

nMaxArray := Len(oGET04:aCols)
aCols     := aClone(oGET04:aCols)
aHeader   := aClone(oGET04:aHeader)

If Empty(aCols[1][1])
   nMaxArray := 0
EndIf
NGIFDBSEEK("STH",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA,1)
While !EoF() .And. STH->TH_FILIAL == xFilial("STH") .And.;
   STH->TH_CODBEM  == M->TF_CODBEM .And. STH->TH_SERVICO == M->TF_SERVICO .And.;
   STH->TH_SEQRELA == M->TF_SEQRELA
   If aSCAN(aCOLS,{|x| x[nTARH]+x[nETAPA] == STH->TH_TAREFA+STH->TH_ETAPA}) == 0
      NGDELETAREG("STH")
   EndIf
   dbSkip(1)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se nao foi excluido nenhum registro e grava ³
//³ as novas inclusoes e alteracoes efetuadas            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx = 1 To nMaxArray
	If aCOLS[nx][Len(aCOLS[nx])]
		If NGIFDBSEEK("STH",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+aCOLS[nx][nTARH]+aCOLS[nx][nETAPA],1)
			cTAR := aCOLS[nx][nTARH]
			cETA := aCOLS[nx][nETAPA]
			nQTD := 0

			aEVAL(aCOLS,{|x| If(x[nTARH]+x[nETAPA] == cTAR+cETA,nQTD++,Nil)})
			If nQTD <= 1
				dbSelectArea("STH")
				NGDELETAREG("STH")
			EndIf
		EndIf
		//Deleta TP1 relacionados ao STH
		DELTP1OP(aCOLS[nx][nTARH],aCOLS[nx][nETAPA])
		Loop
	EndIf

	//Se for Sem Opcoes verifica TP1 e deleta registros
	If nOPCOES > 0
		If aCOLS[nX][nOPCOES] = '0'
			DELTP1OP(aCOLS[nx][nTARH],aCOLS[nx][nETAPA])
		EndIf
	EndIf

	If NGIFDBSEEK("STH",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+aCOLS[nx][nTARH]+aCOLS[nx][nETAPA],1)
		RecLock("STH",.F.)
	Else
		RecLock("STH",.T.)
		STH->TH_FILIAL  := xFilial("STH")
		STH->TH_CODBEM  := M->TF_CODBEM
		STH->TH_SERVICO := M->TF_SERVICO
		STH->TH_SEQRELA := M->TF_SEQRELA
	EndIf

	For nI := 1 To FCOUNT()
		xx := GDFIELDPOS(AllTrim(FIELDNAME(nI)))
		If xx > 0
			vv   := "STH->"+FIELDNAME(nI)
			&vv. := aCOLS[nx][xx]
		EndIf
	Next nI
	MsUnLock("STH")

	If NGIFDBSEEK("TPC",aCOLS[nx][nETAPA],1)
		While !EoF() .And. TPC->TPC_FILIAL == xFilial("TPC") .And. TPC->TPC_ETAPA  == aCOLS[nx][nETAPA]
			If !NGIFDBSEEK("TP1",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+aCOLS[nX][nTARH]+aCOLS[nx][nETAPA]+TPC->TPC_OPCAO,1)
				RecLock("TP1",.T.)
				TP1->TP1_FILIAL := xFilial("TP1")
				TP1->TP1_CODBEM := M->TF_CODBEM
				TP1->TP1_SERVIC := M->TF_SERVICO
				TP1->TP1_SEQREL := M->TF_SEQRELA
				TP1->TP1_TAREFA := aCOLS[nX][nTARH]
				TP1->TP1_ETAPA  := TPC->TPC_ETAPA
				TP1->TP1_OPCAO  := TPC->TPC_OPCAO
				TP1->TP1_TIPRES := TPC->TPC_TIPRES
				TP1->TP1_CONDOP := TPC->TPC_CONDOP
				TP1->TP1_CONDIN := TPC->TPC_CONDIN
				TP1->TP1_TPMANU := TPC->TPC_TPMANU
				TP1->TP1_TIPCAM := TPC->TPC_TIPCAM
				TP1->TP1_FORMUL  := TPC->TPC_FORMUL
				TP1->TP1_DESOPC  := TPC->TPC_DESOPC
				TP1->TP1_BEMIMN := If(TPC->TPC_PORBEM = 'P',M->TF_CODBEM,SubStr(TPC->TPC_DESCRI,1,16))
				TP1->TP1_SERVMN := TPC->TPC_SERVIC
				TP1->TP1_BLOQMA := "S"
				TP1->TP1_BLOQFU := "S"
				TP1->TP1_BLOQFE := "S"
				MsUnLock("TP1")
			EndIf
			aAdd(aCopyTP1,{})
			For nY := 1 to FCOUNT()
				aAdd(aCopyTP1[Len(aCopyTP1)],&("TP1->"+FieldName(nY)))
			Next nY
			NGDBSELSKIP("TPC")
		End
	EndIf

Next nx

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG120LINOK³ Autor ³ Deivys Joenck         ³ Data ³ 03/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120LINOK()

	Local nx
	Local lRET     := .T.
	Local lREFRE   := .F.
    Local cVar     := "oGET" + Strzero(nCONTROGD,2)
	Local cHeadClo := cVar + ":aHeader"
	Local cAcolClo := cVar + ":aCols"

    aHeader := aClone(&cHeadClo)
    aCols   := aClone(&cAcolClo)

	If lOK .And. aHeader[1][2] != "T5_TAREFA"
		aSVCOLS[nCONTROGD]   := aClone(&cAcolClo) //Não remover, utilizado no NGSAIGET
		aSVHEADER[nCONTROGD] := aClone(&cHeadClo) //Não remover, utilizado no NGSAIGET
		oGET01:oBROWSE:REFRESH()
		NGSAIGET(nCONTROGD)
		lREFRE  := .T.
	EndIf

	If Len(aCols) == 1 .And. !aTail(aCols[1])
		If nDESCRI > 0
			If Empty(aCols[1][nTAREFA]) .And. Empty(aCols[1][nDESCRI])
				Return .T.
			EndIf
		EndIf
	EndIf

	For nx:=1 To Len(aCols)
		If !aTail(aCols[nx])
			If !aCols[nx][Len(aCols[nx])]
				If nDESCRI > 0
					If Empty(aCols[nx][nTAREFA]) .Or. Empty(aCols[nx][nDESCRI])
						Help(" ",1,"OBRIGAT")
						lRET := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	Next

	If !lOK
		oGET01:oBROWSE:REFRESH()
	EndIf

	If lREFRE
    	aHeader := aClone(&cHeadClo)
    	aCols   := aClone(&cAcolClo)
		oFOLDER:REFRESH()
	EndIf

	NGSETIFARQUI("ST5","F")

Return lRET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG120LINO2³ Autor ³ Deivys Joenck         ³ Data ³ 06/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120LINO2()

	Local nx
	Local lRET := .T.

	aCols   := aClone(oGET02:aCols)
	aHeader := aClone(oGET02:aHeader)

	If Len(aCols) == 1 .And. !aTail(aCols[1])
		If Empty(aCols[1][nTARM]) .And. Empty(aCols[1][nDEPEND])
			Return .T.
		EndIf
	EndIf

	For nx := 1 To Len(aCols)
		If !aTail(aCols[nx])
			If !aCols[nx][Len(aCols[nx])]
				If Empty(aCols[nx][nTARM]) .Or. Empty(aCols[nx][nDEPEND])
					Help(" ",1,"OBRIGAT")
					lRET := .F.
				EndIf
			EndIf
		EndIf
	Next

	If !lOK
		oGET02:oBROWSE:REFRESH()
	EndIf

Return lRET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG120LINO3³ Autor ³ Deivys Joenck         ³ Data ³ 06/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120LINO3(_ng)

	Local lRET		:= .T.
	Local cHelpOK	:= Space( 10 )
	Local cIntComps	:= SuperGetMv( "MV_NGMNTCM",.F.,"N" ) //Integração entre MNT e Compras
	Local cIntEstoq	:= SuperGetMv( "MV_NGMNTES",.F.,"N" ) //Integração entre MNT e Estoque

	aCols := aClone(oGET03:aCols)

	If Len(aCols) == 1 .And. !aTail(aCols[1])
		If nQUANTI > 0
			If Empty(aCols[1][nTARG]) .And. Empty(aCols[1][nTIPORE]) .And.;
					Empty(aCols[1][nCODIGO]) .And. Empty(aCols[1][nQUANTI])
				Return .T.
			EndIf
		EndIf
	EndIf

	If !aCols[n][Len(aCols[n])] .And. !aTail(aCols[n])
		If nQUANTI > 0
			If Empty(aCols[n][nTARG])   .Or. Empty(aCols[n][nTIPORE]) .Or.;
					Empty(aCols[n][nCODIGO]) .Or. Empty(aCols[n][nQUANTI])

				cHelpOK := "OBRIGAT"
			EndIf
		EndIf
		If Empty(cHelpOK)
			If nQUANRE > 0
				If aCols[n][nTIPORE] $ "F/E" .And. Empty(aCols[n][nQUANRE])
					cHelpOK := "QUANTRECUR"
				EndIf
			EndIf
		EndIf
		If Empty(cHelpOK)
			If nDESTIN > 0
				If aCols[n][nTIPORE] == "P" .And. Empty(aCols[n][nDESTIN])
					cHelpOK := "DESTINO"
				EndIf
			EndIf
		EndIf
		If Empty(cHelpOK)
			If nDESTIN > 0
				If aCols[n][nTIPORE] != "P" .And. !Empty(aCols[n][nDESTIN])
					cHelpOK := "NAODESTINO"
				EndIf
			EndIf
		EndIf
		If Empty(cHelpOK)
			If aCols[n][nTIPORE] == "P" .And. lChkPR
				If nQUANTI > 0
					lRet := NGCHKLIMP(M->TF_CODBEM,aCols[n][nCODIGO],aCols[n][nQUANTI])
				EndIf
			EndIf
		EndIf
	EndIf

	If _ng == Nil
		lRet := VldALLGet3(.F.)
	EndIf

	If !lOK
		oGET03:oBROWSE:REFRESH()
	EndIf

	If !Empty(cHelpOK)
		Help(" ",1,cHelpOK)
		Store .F. To lOK,lRet
	EndIf

	If _ng == Nil
		aSVCOLS[3]   := aClone(oGET03:aCols)   //Não remover, utilizado no NGSAIGET
		aSVHEADER[3] := aClone(oGET03:aHeader) //Não remover, utilizado no NGSAIGET
		NGSAIGET(3)
	EndIf

	If lRet .And. ( cIntComps == "S" .Or. cIntEstoq == "S" ) //Se houver integração entre os módulos (MNT e Compras) OU (MNT e Estoque).
		If aCols[n][nTIPORE] == "T" .And. Empty( aCols[n][nALMOX] ) //Se o insumo for do tipo 'Terceiro' e o campo 'Almoxarifado' estiver vazio.
			//"O insumo " # " não tem conteúdo para o campo de almoxarifado. Quando insumo do tipo terceiro, o mesmo deve ser preenchido." # "Preencha o campo Almoxarifado."
			ShowHelpDlg( STR0100,{ STR0128+AllTrim( aCols[n][nCODIGO] )+STR0129 },2,{ STR0130 },2 )
			lRet := .F.
		EndIf
	EndIf

	NGSETIFARQUI("STG","F")

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG120LINO4³ Autor ³ Deivys Joenck         ³ Data ³ 07/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120LINO4(_ng)

	Local lRET := .T.

	aCols := aClone(oGET04:aCols)

	If Len(aCols) == 1 .And. !aTail(aCols[1])
		If Empty(aCols[1][nTARH]) .And. Empty(aCols[1][nETAPA])
			Return .T.
		EndIf
	EndIf

	If !aCols[N][Len(aCols[N])] .And. !aTail(aCols[N])
		If Empty(aCols[N][nTARH]) .Or. Empty(aCols[N][nETAPA])
			Help(" ",1,"OBRIGAT")
			lRET := .F.
		EndIf
	EndIf

	If !lOK
		oGET04:oBROWSE:REFRESH()
	EndIf

	If !lRet
		Store .F. To lOK,lRet
	EndIf

	If _ng == Nil
		aSVCOLS[4]   := aClone(oGET04:aCols)   //Não remover, utilizado no NGSAIGET
		aSVHEADER[4] := aClone(oGET04:aHeader) //Não remover, utilizado no NGSAIGET
		NGSAIGET(4)
	EndIf

	If ExistBlock("MNTA1202")
		lRet := ExecBlock("MNTA1202",.F.,.F.)
	EndIf

	NGSETIFARQUI("STH","F")

Return lRET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG120EXIST³ Autor ³ Deivys Joenck         ³ Data ³ 06/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a nota toda esta' Ok                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120EXIST(cALIAS)
Local lRET := .T.
Local nPosicao, n5 := 0

If cALIAS == "ST5"
	cTAREFA := M->T5_TAREFA

   //Valida alteracao da tarefa, verificando se ela ja eh utilizada
	If !Empty(aCOLS[n][nTAREFA])
		If !MNT120AET5()
			Return .F.
		EndIf
	EndIf
	For n5 := 1 To Len(aCOLS)
		If n5 != n .And. !aCOLS[n5][Len(aCOLS[n5])] .And. aCOLS[n5][nTAREFA] = cTAREFA
			lREFRESH := .T.
			Help(" ",1,"JAGRAVADO")
			lRET := .F.
			Exit
		EndIf
	Next n5

	If lRET .And. NGUSATARPAD() .And. !NGIFDBSEEK("TT9",cTAREFA,1) .And. !Empty(cTAREFA)
		If MsgYesNo(STR0109+AllTrim(cTAREFA) + STR0110,STR0100) //"Desejas utilizar a tarefa "###" como Tarefa Genérica?"###"Atenção"
			bCondic := {|| If(Alias() == "ST5",ST5->T5_FILIAL+ST5->T5_CODBEM+ST5->T5_SERVICO+ST5->T5_SEQRELA != STF->TF_FILIAL+STF->TF_CODBEM+STF->TF_SERVICO+STF->TF_SEQRELA,.T.)}
			If !NGVTART5(cTAREFA,.T.,bCondic)
				aAdd(aAddTT9,cTAREFA)
			Else
				lRET := .F.
			EndIf
		Else
			nPosicao := aScan(aAddTT9,{|x| x == cTAREFA})
			If nPosicao > 0
				aDel( aAddTT9, nPosicao )
				aSize( aAddTT9, Len( aAddTT9 ) - 1 )
			EndIf
		EndIf
	EndIf
	 If NGCADICBASE('T5_ATIVA','A','ST5')[1]
		nAti := aSCAN(aHEADER,{|x| AllTrim(Upper(X[2])) == "T5_ATIVA" })
		If nAti > 0 .And. Empty(aCols[n][nAti])
			aCols[n][nAti]	:= "1"
		EndIf
	 EndIf
EndIf

Return lRET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG120TIPO ³ Autor ³ Paulo Pego            ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consiste o campo TG_TIPOREG                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120 - CADASTRO DE MANUTENCAO                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120TIPO(cTIPO)
Local cReserv
If cTIPO != aCOLS[n][nTIPORE]
	aCOLS[n][nCODIGO] := SPACE(Len(aCOLS[n][nCODIGO]))
	If nNOMECO > 0
		aCOLS[n][nNOMECO] := SPACE(Len(aCOLS[n][nNOMECO]))
	EndIf
	If nQUANRE > 0
		aCOLS[n][nQUANRE] := 0
	EndIf
	If nQUANTI > 0
		aCOLS[n][nQUANTI] := 0.00
	EndIf
	If nUNIDAD > 0
		aCOLS[n][nUNIDAD] := SPACE(Len(aCOLS[n][nUNIDAD]) )
	EndIf
	cReserv := &(GetSX3Cache("TG_RESERVA", "X3_RELACAO"))
	If nRESERV > 0
		aCOLS[n][nRESERV] := If(cReserv $ "SN",cReserv,"S")
	EndIf
	If nDESTIN > 0
		aCOLS[n][nDESTIN] := SPACE(Len(aCOLS[n][nDESTIN]))
	EndIf
EndIf

If M->TG_TIPOREG <> "P"
	If nUNIDAD > 0
		aCOLS[n][nUNIDAD] := "H"
	EndIf
EndIf

If cTIPO == "T"
	If nRESERV > 0
		aCOLS[n][nRESERV] := "N"
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} NG120SERV
Retorna a ultima sequencia digitada

@type   User Function

@author Paulo Pego
@since  01/08/1997

@return Lógico, verdadeiro se não encontrou nenhum problema
/*/
//-------------------------------------------------------------------
User Function NG120SERV()

	Local cSEQ := Space(3), OLDALI := ALIAS(),cMENSA := Space(1)
	Local nP1BEM, nP1SER, nP1SEQ, nP1TAR, nP1ETA, nP1OPC, nX, nY
	Local lPrimRe := .T., nIdTPF  := 1
	Local lManutPad := .F.

	//----------------------------------------
	// Consiste o Serviço da Manutenção
	//----------------------------------------
	If NGIFDBSEEK("ST4",M->TF_SERVICO,1)

		If NGFUNCRPO("NGSERVBLOQ",.F.) .And. !NGSERVBLOQ(M->TF_SERVICO)
			Return .F.
		EndIf
		If lMan
			If ST4->T4_LUBRIFI = 'S'
				cMENSA := STR0034+Chr(13)+Chr(13);
						+STR0035+STR0009+STR0036+Chr(13);
						+STR0037+STR0038+Chr(13)+Chr(13)+Chr(13);
						+STR0039+STR0038+STR0040+Chr(13);
						+STR0041
			EndIf
		Else
			If ST4->T4_LUBRIFI = 'N'
				cMENSA := STR0034+Chr(13)+Chr(13);
						+STR0035+STR0031+STR0036+Chr(13);
						+STR0037+STR0042+Chr(13)+Chr(13)+Chr(13);
						+STR0039+STR0042+STR0040+Chr(13);
						+STR0041
			EndIf
		EndIf

		If !Empty(cMENSA)
			MsgInfo(cMENSA,STR0043)
			Return .F.
		EndIf

		//----------------------------------------
		// Busca e posiciona na respectiva manutenção padrão (TPF)
		//----------------------------------------
		If M->TF_PADRAO == 'S'

			NGIFDBSEEK("ST9",M->TF_CODBEM,1)

			// A partir do release 12.1.33, o tipo modelo será utilizado
			// na busca de manutenção padrão, mesmo em ambientes sem Gestão de Frotas
			If lRel12133

				// Busca e posiciona na manutenção padrão padrão (TPF)
				lManutPad := MNTSeekPad( 'TPF', ;
										4, ; // TPF_FILIAL+TPF_CODFAM+TPF_TIPMOD+TPF_SERVIC+TPF_SEQREL
										ST9->T9_CODFAMI, ;
										ST9->T9_TIPMOD, ;
										M->TF_SERVICO + M->TF_SEQREPA )

			Else

				// Para releases anteriores, o tipo modelo somente é utilizado,
				// na busca de manutenção padrão, para ambientes com Gestão de Frotas
				cTipMod := ''
				If lTipMod
					nIdTPF  := 4 // TPF_FILIAL+TPF_CODFAM+TPF_TIPMOD+TPF_SERVIC+TPF_SEQREL
					cTipMod := ST9->T9_TIPMOD
				EndIf
				lManutPad := NGIFDBSEEK("TPF",ST9->T9_CODFAMI+cTipMod+M->TF_SERVICO+M->TF_SEQREPA,nIdTPF)

			EndIf

			// Caso não seja encontrado uma manutenção padrão
			If !lManutPad
				Help(" ",1,"NREGFASERV")
				Return .F.
			EndIf

		EndIf

		//----------------------------------------
		// Consiste o Tipo de Manutenção
		//----------------------------------------
		NGIFDBSEEK("STE",ST4->T4_TIPOMAN,1)
		If STE->TE_CARACTE != "P" .Or. !FOUND()
			Help(" ",1,"TIPSERVINV")
			dbSelectArea(OLDALI)
			Return .F.
		EndIf
		M->TF_TIPO    := STE->TE_TIPOMAN
		M->TF_NOMTIPO := STE->TE_NOME

		//----------------------------------------
		// Consiste o Área de Manutenção
		//----------------------------------------
		NGIFDBSEEK("STD",ST4->T4_CODAREA,1)
		M->TF_CODAREA := STD->TD_CODAREA
		M->TF_NOMAREA := STD->TD_NOME
		lREFRESH := .T.

		//----------------------------------------
		// Busca a proxima sequencia da Manutencao
		//----------------------------------------
		OLDKEY := IndexKey()
		dbSelectArea('STF')
		nINDSTF := IndexOrd()
		NGIFDBSEEK("STF",M->TF_CODBEM+M->TF_SERVICO,1)
		cSEQ := TF_SEQRELA

		While !EoF() .And. STF->TF_FILIAL == xFilial("STF") .And.;
			STF->TF_CODBEM == M->TF_CODBEM .And. STF->TF_SERVICO == M->TF_SERVICO

			If Val(STF->TF_SEQRELA) > 0
				If Val(STF->TF_SEQRELA) > Val(cSEQ)
					cSEQ := STF->TF_SEQRELA
				EndIf
			Else
				If isDigit(Substr(STF->TF_SEQRELA,1,1))
				Else
					cSEQ := If(lPrimRe,STF->TF_SEQRELA,If(STF->TF_SEQRELA > cSEQ,STF->TF_SEQRELA,cSEQ))
					lPrimRe := .F.
				EndIf
			EndIf
			dbSkip()
		End

		dbSetOrder(nINDSTF)
		If FindFunction("Soma1Old")
			M->TF_SEQRELA := If(Empty(cSEQ),"1  ",PADL(Soma1Old(cSEQ),3))
		Else
			M->TF_SEQRELA := If(Empty(cSEQ),"1  ",PADL(Soma1(cSEQ),3))
		EndIf

		//----------------------------------------
		// Verifica se ja havia sido gravado TP1
		//----------------------------------------
		If Len(aCopyTP1) > 0
			NGDBAREAORDE("TP1",1)
			nP1BEM := FieldPos('TP1_CODBEM')
			nP1SER := FieldPos('TP1_SERVIC')
			nP1SEQ := FieldPos('TP1_SEQREL')
			nP1TAR := FieldPos('TP1_TAREFA')
			nP1ETA := FieldPos('TP1_ETAPA')
			nP1OPC := FieldPos('TP1_OPCAO')

			For nX := 1 to Len(aCopyTP1)
				//Verifica se opcao ja existe e deleta
				If dbSeek(xFilial("TP1")+M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+aCopyTP1[nX][nP1TAR]+aCopyTP1[nX][nP1ETA]+aCopyTP1[nX][nP1OPC])
					NGDELETAREG("TP1")
				EndIf

				//Alteara TP1 para o Bem, Servico e SeqRela digitado
				If dbSeek(xFilial("TP1")+aCopyTP1[nX][nP1BEM]+aCopyTP1[nX][nP1SER]+aCopyTP1[nX][nP1SEQ]+aCopyTP1[nX][nP1TAR]+aCopyTP1[nX][nP1ETA]+aCopyTP1[nX][nP1OPC])
					RecLock("TP1",.F.)
					For nY := 1 to Len(aCopyTP1[nX])
					FieldPut(nY,aCopyTP1[nX][nY])
					Next nY
					TP1->TP1_CODBEM := M->TF_CODBEM
					TP1->TP1_SERVIC := M->TF_SERVICO
					MsUnLock("TP1")
				EndIf
			Next nX
			aCopyTP1 := {}
		EndIf

		//----------------------------------------
		// Faz copia da tabela TP1 na copia da manutencao
		//----------------------------------------
		COPY120TP1()

	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³COPY120TP1³ Autor ³Vitor Emanuel Batista  ³ Data ³29/06/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz copia da tabela TP1 na copia da manutencao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function COPY120TP1()
Local nX, nY
Local nP1BEM, nP1SER, nP1SEQ, nP1TAR, nP1ETA, nP1OPC
Local aOldTP1 := aCLONE(aCopyTP1)

lCopia := If(Type("lCopia") = "L",lCopia,.F.)

If lCopia
   dbSelectArea("TP1")
   nP1BEM := FieldPos('TP1_CODBEM')
   nP1SER := FieldPos('TP1_SERVIC')
   nP1SEQ := FieldPos('TP1_SEQREL')
   nP1TAR := FieldPos('TP1_TAREFA')
   nP1ETA := FieldPos('TP1_ETAPA')
   nP1OPC := FieldPos('TP1_OPCAO')

   aCopyTP1 := {}
   If !Empty(M->TF_CODBEM) .And. !Empty(M->TF_SERVICO)
      RestArea(aTFArea)
      NGIFDBSEEK("TP1",STF->TF_CODBEM+STF->TF_SERVICO+STF->TF_SEQRELA,1)
      While !EoF() .And. xFilial("TP1") == TP1->TP1_FILIAL .And. STF->TF_CODBEM == TP1->TP1_CODBEM .And. ;
         STF->TF_SERVICO == TP1->TP1_SERVIC .And. STF->TF_SEQRELA == TP1->TP1_SEQREL
         aAdd(aCopyTP1,{})
         For nX := 1 to FCOUNT()
            aAdd(aCopyTP1[Len(aCopyTP1)],&("TP1->"+FieldName(nX)))
         Next nX
         dbSkip()
      EndDo

      //Se ja havia sido gravado TP1
      If Len(aOldTP1) > 0
         For nX := 1 to Len(aOldTP1)
            dbSeek(xFilial("TP1")+aOldTP1[nX][nP1BEM]+aOldTP1[nX][nP1SER]+aOldTP1[nX][nP1SEQ])
            While !EoF() .And. xFilial("TP1") == TP1->TP1_FILIAL .And. aOldTP1[nX][nP1BEM] == TP1->TP1_CODBEM .And. ;
               aOldTP1[nX][nP1SER] == TP1->TP1_SERVIC .And. aOldTP1[nX][nP1SEQ] == TP1->TP1_SEQREL
               NGDELETAREG("TP1")
               dbSkip()
            EndDo
         Next nX
      EndIf

      dbSeek(xFilial("TP1")+M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA)
      While !EoF() .And. xFilial("TP1") == TP1->TP1_FILIAL .And. M->TF_CODBEM == TP1->TP1_CODBEM .And. ;
          M->TF_SERVICO == TP1->TP1_SERVIC .And. M->TF_SEQRELA == TP1->TP1_SEQREL
          NGDELETAREG("TP1")
          dbSkip()
      EndDo

      For nX := 1 to Len(aCopyTP1)
         If !dbSeek(xFilial("TP1")+M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+aCopyTP1[nX][nP1TAR]+aCopyTP1[nX][nP1ETA]+aCopyTP1[nX][nP1OPC])
            RecLock("TP1",.T.)
            For nY := 1 to Len(aCopyTP1[nX])
               FieldPut(nY,aCopyTP1[nX][nY])
            Next nY
            TP1->TP1_CODBEM := M->TF_CODBEM
            TP1->TP1_SERVIC := M->TF_SERVICO
            TP1->TP1_SEQREL:= M->TF_SEQRELA
            MsUnLock("TP1")

            aCopyTP1[nX][nP1BEM] := M->TF_CODBEM
            aCopyTP1[nX][nP1SER] := M->TF_SERVICO
            aCopyTP1[nX][nP1SEQ] := M->TF_SEQRELA
         EndIf
      Next nX
   EndIf
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} NG120CHECK
Valida o campo TG_Codigo(Codigo Insumo)
@author  Paulo Pego
@since   XX/XX/XXXX
@version P11/P12
@use     Cadastro de Manutenções
@return  _Ret, .T. = Validação OK
               .F. = Encotrou problema.
/*/
//-------------------------------------------------------------------
User Function NG120CHECK()

Local nPosicao := GDFIELDPOS("TG_NOMECOD")
Local _RET		 := .T.
Local cCOD		 := M->TG_CODIGO
Local QTD		 := 0
Local aCAMPOS	 := {}
Local cTAR,cTIP,cParTer
Local cLoja := ''

M->TG_TIPOREG := aCOLS[n][nTIPORE]
cTAR := If(nTARG == 0, "0     ",aCOLS[n][nTARG])
cTIP := aCOLS[n][nTIPORE]
ST1->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SA2->(dbSetOrder(1))
SH4->(dbSetOrder(1))
ST0->(dbSetOrder(1))

If Empty(aCOLS[n][nTARG]) .And. !Empty(M->TG_CODIGO)
   aCOLS[n][nTARG] := "0"+REPLICATE(" ",Len(ST5->T5_TAREFA)-1)
   If cPrograma == "MNTA120"
      oGET03:oBROWSE:REFRESH()
   EndIf
   cTAR := aCOLS[n][nTARG]
   If !NGIFDBSEEK("ST5",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+cTAR,1)
      RecLock("ST5",.T.)
      ST5->T5_FILIAL  := xFilial("ST5")
      ST5->T5_CODBEM  := M->TF_CODBEM
      ST5->T5_SERVICO := M->TF_SERVICO
      ST5->T5_SEQRELA := M->TF_SEQRELA
      ST5->T5_TAREFA  := "0"
      ST5->T5_DESCRIC := STR0013 //"SEM ESPECIFICA€ŽO DE TAREFA"
      MsUnLock("ST5")
      aAdd(aCAMPOS,{"0",STR0013})
      If cPrograma = "MNTA120"
        If Len(oGET01:aCols) == 1 .And. Empty(oGET01:aCols[1][nTARG])
				aDel(oGET01:aCols,1)
				Asize(oGET01:aCols,Len(oGET01:aCols)-1)
		EndIf
			oGet01:AddLine()
			oGet01:aCols[1][nTarg] := "0"
			Iif(nDescri > 0, oGet01:aCols[1][nDescri] := STR0013, )
      EndIf
   EndIf
EndIf

If IsInCallStack("MNTA410") .And. M->TG_TIPOREG == "P"
	If !NGPROBLQ(cCOD) // Função que verifica se o produto está bloqueado (NGUTIL03.PRX).
		Return .F.
	EndIf
EndIf

aEVAL( aCOLS, { | x | If( ( !x[ Len( aCols[ n ] ) ] .And. x[nTARG] == cTAR .And. x[nTIPORE] == cTIP .And. cCOD == x[nCODIGO]),QTD++,Nil)})
If ( QTD > 0 )
	Help( " ",1,"TARJAEXIST" )
	Return .F.
EndIf

If cTIP == "M"
	//Testa o tamanho do campo para nao permitir informar codigo invalido
	If Len(Alltrim(cCOD)) > Len(ST1->T1_CODFUNC)
		_RET := .F.
	EndIf

	If _RET
		cCOD := Left(cCOD, Len(ST1->T1_CODFUNC))
		_RET := ST1->(dbSeek(xFilial("ST1")+cCOD))
	EndIf

	If !_RET
		Help(" ",1,"FUNCNEXIST")
		Return .F.
	EndIf
	If  nPosicao > 0
		aCOLS[n][nPosicao] := Left(ST1->T1_NOME+SPACE(40),40)
	EndIf
ElseIf cTIP == "P"

	//Não permite selecionar um produto 'bloqueado'
	If !Empty(M->TG_CODIGO)
		If !EXISTCPO("SB1",M->TG_CODIGO)
	    	Return .F.
		EndIf
	EndIf

	//Testa o tamanho do campo para nao permitir informar codigo invalido
	If Len(Alltrim(cCOD)) > Len(SB1->B1_COD)
		_RET := .F.
	EndIf

	cCODSTL := Substr(M->TG_CODIGO,1,Len(SB1->B1_COD))
	If !NGPRODESP(cCODSTL)
		Return .F.
	EndIf

	If _RET
		cCOD := Left(cCOD, Len(SB1->B1_COD))
		_RET := SB1->(dbSeek(xFilial("SB1")+cCOD))
	EndIf

	If !_RET
		Help(" ",1,"PRODNEXIST")
		Return .F.
	EndIf
	If nPosicao > 0
		aCOLS[n][nPosicao]    := Left(SB1->B1_DESC+SPACE(40),40)
	EndIf
	If nUNIDAD > 0
		aCOLS[n][nUNIDAD] := SB1->B1_UM
	EndIf
	If nALMOX > 0
		aCOLS[n][nALMOX]  := SB1->B1_LOCPAD
	EndIf

ElseIf cTIP == "T"
	If nFornec > 0

		If cCOD != SA2->A2_COD
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+Alltrim(cCOD)))
		EndIf

		cLoja := SA2->A2_LOJA

		If !ExistCpo("SA2",SubStr(cCOD,1,Len(SA2->A2_COD))+cLoja)
			Return .F.
		EndIf

		//Verica se existe o campo Fornecedor
		If nFornec > 0
			aCols[n][nFornec]	:= SA2->A2_COD
			aCols[n][nLoja] 	:= SA2->A2_LOJA
			aCols[n][nNOMECO]	:= SA2->A2_NOME
		EndIf

	Else
		aEVAL(aCOLS,{|x| If((x[nTARG] == cTAR .And. x[nTIPORE] == cTIP .And. cCOD == x[nCODIGO]),QTD++,Nil)})
		If QTD > 0
			Help(" ",1,"TARJAEXIST")
	   		Return .F.
	   	EndIf
		If Len(Alltrim(cCOD)) > Len(SA2->A2_COD)
			_RET := .F.
		EndIf

		If _RET
			cCOD := Left(cCOD, Len(SA2->A2_COD))
			_RET := SA2->(dbSeek(xFilial("SA2")+cCOD))
		EndIf

		If _RET
			cParTer := If(FindFunction("NGProdMNT"), NGProdMNT("T")[1], PADR(GETMV("MV_PRODTER"),Len(STL->TL_CODIGO)))
			_RET := SB1->(dbSeek(xFilial("SB1")+cParTer))
		EndIf

		If !_RET
			Help(" ",1,"TERCNEXIST")
			Return .F.
		EndIf
		If nPosicao > 0
			aCOLS[n][nPosicao] := Left(SA2->A2_NOME+SPACE(40),40)
		EndIf
	EndIf

ElseIf cTIP == "F"

	If Len(Alltrim(cCOD)) > Len(SH4->H4_CODIGO)
		_RET := .F.
	EndIf

	If _RET
		cCOD := Left(cCOD, Len(SH4->H4_CODIGO))
		_RET := SH4->(dbSeek(xFilial("SH4")+cCOD))
	EndIf

	If !_RET
		Help(" ",1,"FERRNEXIS")
		Return .F.
	EndIf

	If nPosicao > 0
		aCOLS[n][nPosicao] := Left(SH4->H4_DESCRI+SPACE(40),40)
	EndIf
Else
	//Testa o tamanho do campo para nao permitir informar codigo invalido
	If Len(Alltrim(cCOD)) > Len(ST0->T0_ESPECIA)
		_RET := .F.
	EndIf

	If _RET
		cCOD := Left(cCOD,Len(ST0->T0_ESPECIA) )
		_RET := ST0->(dbSeek(xFilial("ST0")+cCOD))
	EndIf

	If !_RET
		Help(" ",1,"ESPENEXIST")
		Return .F.
	EndIf

	If _RET
		If !NGIFDBSEEK("ST2",cCOD,2)
			Help("",1,"NAOHAESP")
			Return .F.
		EndIf
		dbSetOrder(1)
	EndIf
	If nPosicao > 0
		aCOLS[n][nPosicao] := Left(ST0->T0_NOME+SPACE(40),40)
	EndIf
EndIf

If cTIP == "M"
   If !NGFUNCRH(cCOD,.T.)
      Return .F.
   EndIf
EndIf

If cTIP <> "T" .And. nFornec > 0
	If !Empty(aCols[n][nFornec])
		aCols[n][nFornec]  := Space(Len(SA2->A2_COD))
		aCols[n][nLoja] := Space(Len(SA2->A2_LOJA))
	EndIf
EndIf

Return _RET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a120CHKCTD³ Autor ³ Paulo Pego            ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida os Campos correspondes a informacoes o tipo contador³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120CHKCTD()

	// VERIFICA SE HÁ O.S. DE ACOMPANHAMENTO
	If nOPCAO = 4
		If M->TF_TIPACOM $ "C/A/F/T"
			If NGIFDBSEEK("TQA",M->TF_CODBEM,2)
				While !EoF() .And. tqa->tqa_filial = xFilial("TQA") .And. tqa->tqa_codbem = M->TF_CODBEM
					If tqa->tqa_situac = 'P'
						Help(" ",1,"EXISTOSTEM")   // EXISTE O.S.
						Return .F.
					EndIf
					dbSkip()
				End
			EndIf
		EndIf
	EndIf

	If M->TF_TIPACOM != "T"
		If ST9->(dbSeek(xFilial("ST9")+M->TF_CODBEM))
			cCODBEM := M->TF_CODBEM
			cBEMAUX := SPACE(Len(STF->TF_CODBEM))
			lPROBL  := .F.
			If ST9->T9_TEMCONT <> 'N' .And. (ST9->T9_TEMCONT == 'I' .Or. ST9->T9_TEMCONT == 'P')

				If ST9->T9_TEMCONT == 'I'
					cBEMAUX := NGBEMIME(STF->TF_CODBEM)
				ElseIf ST9->T9_TEMCONT == 'P'
					cBEMAUX := NGBEMPAI(STF->TF_CODBEM)
				Else
					cBEMAUX := cCODBEM
				EndIf

				If !Empty(cBEMAUX)
					If NGIFDBSEEK("ST9",cBEMAUX,1)
						If ST9->T9_LIMICON == 0 .Or. ST9->T9_VARDIA == 0
							lPROBL := .T.
						EndIf
					EndIf
				Else
					If ST9->T9_LIMICON == 0 .Or. ST9->T9_VARDIA == 0
						lPROBL := .T.
					EndIf
				EndIf

				If lPROBL
					Help(" ",1,"A120CHKCTD")
					Return .F.
				EndIf

			ElseIf ST9->T9_TEMCONT == "N" .And. M->TF_TIPACOM $ "CSFA"
				MsgStop("Não é possível inserir uma manutenção com acompanhamento de contador para bens que não possuem contador.","")
				Return .F.
			EndIf
		EndIf
	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Proteus.doc} NG120MOSTRA
Consiste o campo TG_TAREFA
@type User Function

@author Paulo Pego

@sample NG120MOSTRA( 'TAR01' )

@param  cCOD   , Caracter, Código da tarefa.
@return Lógico , Define se o processo foi realizado com êxito.

@obs Esta validação encontra-se obsoleta e a partir da versão 12.1.25 é realizada pela função MNTA120Tar()
/*/
//------------------------------------------------------------------------------------------------
User Function NG120MOSTRA(cCOD)

	Local nPosicao := GDFIELDPOS("T5_DESCRIC")
	Local nPOSTARE := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "T5_TAREFA"})
	Local cOldTar

	cBEM120 := M->TF_CODBEM
	cSER120 := M->TF_SERVICO
	cSEQ120 := M->TF_SEQRELA
	cOldTar := aCols[n][nPOSTARE]

	If AllTrim(cCOD) == "0"

		If nPosicao > 0
			_TAM := Len(aCOLS[n][nPosicao])
			aCOLS[n][nPosicao] := Left(STR0013+SPACE(_TAM),_TAM) //"SEM ESPECIFICA€ŽO DE TAREFA"
		EndIf

		Return .T.

	EndIf

	If nDESCRI > 0
		cDesTar := aCOLS[n][nDESCRI]
	EndIf

	If NGIFDBSEEK("ST5",cBEM120+cSER120+cSEQ120+cCOD,1)
		If nPosicao > 0
			aCOLS[n][nPosicao] := ST5->T5_DESCRIC
		EndIf
	Else
		If FindFunction("NGNTARPADRA")
			If nPosicao > 0
				aCOLS[n][nPosicao] := NGNTARPADRA(cCOD)
			EndIf
		EndIf
	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Proteus.doc} NG120TAREFA

@author Paulo Pego

@return .T.

@obs Esta validação encontra-se obsoleta e a partir da versão 12.1.25 é realizada pela função MNTA120Tar()
/*/
//------------------------------------------------------------------------------------------------
User Function NG120TAREFA()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a120CHKPAR³ Autor ³ Paulo Pego            ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida os Campos correspondes a PARADA DO BEM              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120CHKPAR()
Local cOLDALI := ALIAS()

If M->TF_PARADA == "T"
   If NGIFDBSEEK("STC",M->TF_CODBEM,1)
      Return .T.
   Else
      If NGIFDBSEEK("STC",M->TF_CODBEM,3)
         Return .T.
      EndIf
   EndIf
   Help(" ",1,"NEXITESTRU")
   dbSelectArea(cOLDALI)
   Return .F.
EndIf

If M->TF_PARADA == "N"
   M->TF_TEPAANT := 0
   M->TF_UNPAANT := " "
   M->TF_TEPADEP := 0
   M->TF_UNPADEP := " "
EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a120CHKTAR³ Autor ³ Deivys Joenck         ³ Data ³ 18/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a integridade referencial entre os folders.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120CHKTAR()
Local lCHKTAR := .T.
If aCOLS[n][Len(aCOLS[n])]
	cTARPRIN := aCOLS[n][nTAREFA]
	// DEPENDENCIAS
	If Len(oGET02:aCols) > 0
		lCHKTAR := NG120TARFOL(oGET02:aCols,STR0027,1,2,1)
	EndIf

	// INSUMOS
	If lCHKTAR
		If Len(oGET03:aCols) > 0
			lCHKTAR := NG120TARFOL(oGET03:aCols,STR0030,1,,1)
		EndIf
	EndIf

	// ETAPAS
	If lCHKTAR
		If Len(oGET04:aCols) > 0
			lCHKTAR := NG120TARFOL(oGET04:aCols,STR0028,1,,1)
		EndIf
	EndIf
EndIf

Return lCHKTAR

//-------------------------------------------------------------------
/*/{Protheus.doc} CARREG180
Alimenta os campos do STF com os campos padrao TPF

@param  cCampo, Caractere, Campo ao qual será realizado a validação
@return Lógico, Retorno define se a validação obteve sucesso ou não
/*/
//-------------------------------------------------------------------
User Function CARREG180(cCampo)

	Local nNUM
	Local i
	Local cSTF      := ""
	Local cTPF      := ""
	Local cSeq      := ""
	Local lRet      := .T.
	Local lManutPad := .F.
	Local nIdTPF    := 1
	Local aSTF      := {}
	Local aNAO      := {"TF_FILIAL","TF_CODBEM","TF_SERVICO","TF_SEQRELA","TF_PADRAO"}
	Local aHeadSTF  := {}
	Local cModelo   := ''

	If Type("cTipMod") <> "C"
		Private cTipMod := ""
		Private nIdTP5  := 1
		Private nIdTPM  := 1
		Private nIdTPG  := 1
		Private nIdTPH  := 1
	EndIf

	Default cCampo := ReadVar()

	cSeq := If(cCampo == "M->TF_SEQREPA", M->TF_SEQREPA, Str(M->TF_SEQUEPA,3))

	If Naovazio() .And. ExistCpo('TPF', ST9->T9_CODFAMI + M->TF_SERVICO + cSeq, 1)
		cSEQ120 := M->TF_SEQRELA

		//Cria Array de controle do STF
		aHeadSTF := NGHeader("STF", aNAO)

		For i := 1 To Len(aHeadSTF)

			cSTF   := "M->" + aHeadSTF[i,2]
			If SUBSTR(aHeadSTF[i,2],10,01) $ "0123456789"
				cTPF := "TPF_"+SUBSTR(aHeadSTF[i,2],4,5)+SUBSTR(aHeadSTF[i,2],10,01)
			Else
				cTPF := "TPF_"+SUBSTR(aHeadSTF[i,2],4,6)
			EndIf

			If aHeadSTF[i,2] == "TF_SUBSTIT"
				If NGCADICBASE("TPF_SUBSTI","D","TPF",.F.)
					cTPF := "TPF_SUBSTI"
				EndIf
			EndIf

			aAdd(aSTF,{cSTF, cTPF})

		Next i

		//--------------------------------------------------------
		// Busca e posiciona na respectiva manutenção padrão (TPF)
		//--------------------------------------------------------
		NGIFDBSEEK("ST9",M->TF_CODBEM,1)
		If lTipMod
			nIdTPF  := 4
			nIdTP5  := 3
			nIdTPM  := 2
			nIdTPG  := 3
			nIdTPH  := 6
			cTipMod := ST9->T9_TIPMOD
		EndIf

		// A partir do release 12.1.33, o tipo modelo será utilizado
		// na busca de manutenção padrão, mesmo em ambientes sem Gestão de Frotas
		If lRel12133

			// Busca e posiciona na manutenção padrão padrão (TPF)
			lManutPad := MNTSeekPad( 'TPF', ;
									4, ; // TPF_FILIAL+TPF_CODFAM+TPF_TIPMOD+TPF_SERVIC+TPF_SEQREL
									ST9->T9_CODFAMI, ;
									ST9->T9_TIPMOD, ;
									M->TF_SERVICO + M->TF_SEQREPA )

			cModelo := TPF->TPF_TIPMOD

		Else
			// Para releases anteriores, o tipo modelo somente é utilizado,
			// na busca de manutenção padrão, para ambientes com Gestão de Frotas
			lManutPad := NGIFDBSEEK( "TPF",ST9->T9_CODFAMI + cTipMod + M->TF_SERVICO + M->TF_SEQREPA, nIdTPF )

			cModelo := cTipMod

		EndIf

		// Caso não seja encontrado uma manutenção padrão
		If !lManutPad
			Help(" ",1,"NREGFASERV")
			Return .F.
		EndIf

		//----------------------------------------
		// Carrega o TPF nas variaveis do STF
		//----------------------------------------
		For i := 1 To Len(aSTF)

			cTPF := aSTF[i][2]
			cSTF := aSTF[i][1]

			If FIELDPOS(cTPF) > 0
				&cSTF. := FIELDGET(FIELDPOS(cTPF))
			EndIf

			If TRIM(UPPER(cSTF)) == "M->TF_CALENDA"
				SH7->(dbSeek(xFilial("SH7")+M->TF_CALENDA))
				M->TF_NOMCALE := Left(SH7->H7_DESCRI, Len(M->TF_NOMCALE))
			EndIf

		Next

		//-----------------------------------------
		// Utiliza a Manutenção Padrão posicionada
		// (TPF) para carregar seus relacionamentos
		//-----------------------------------------
		NG120ATUT5( TPF->TPF_CODFAM, cModelo, TPF->TPF_SERVIC, TPF->TPF_SEQREL )
		NG120ATUTM( TPF->TPF_CODFAM, cModelo, TPF->TPF_SERVIC, TPF->TPF_SEQREL )
		NG120ATUTG( TPF->TPF_CODFAM, cModelo, TPF->TPF_SERVIC, TPF->TPF_SEQREL )
		NG120ATUTH( TPF->TPF_CODFAM, cModelo, TPF->TPF_SERVIC, TPF->TPF_SEQREL )

		dbSelectArea("STF")
		lREFRESH := .T.
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NG120ATUT5
Atualiza o acols do ST5 conforme o padrão.

@author Deivys Joenck
@since  07/08/01
@Param  cFamilia  , Caracter, Código da Familia
@Param  cModelo   , Caracter, Código do Modelo
@Param  cServico  , Caracter, Serviço utilizado na MNT
@Param  cSequencia, Caracter, Sequência

/*/
//-------------------------------------------------------------------
Static Function NG120ATUT5( cFamilia, cModelo, cServico, cSequencia )

	Local aST5 := {},cST5,cTP5,i

	aCols   := aClone(oGET01:aCols)
	aHeader := aClone(oGET01:aHeader)
	n       := Len(aCols)

	//--------------------------------------------------------------------------
	// Relaciona campos entre TP5 (Tarefas da Manutenção Padrão) e ST5 (Tarefas da Manutenção)
	//--------------------------------------------------------------------------
	For i := 1 To Len(aHeader)
		cST5 := "M->"+aHeader[i][2]
		If SUBSTR(cST5,10,01) $ "0123456789"
			cTP5 := "TP5_"+SUBSTR(cST5,7,5)+SUBSTR(cST5,13,01)
		Else
			cTP5 := "TP5_"+SUBSTR(cST5,7,6)
		EndIf
		aAdd(aST5,{cST5,cTP5})
	Next

	nCOLS := 1
	aTP5  := aClone(aCols[1])

	//--------------------------------------------------------------------------
	// Carrega Tarefas da Manutenção Padrão (TP5)
	// Indice 1: TP5_FILIAL+TP5_CODFAM+TP5_SERVIC+TP5_SEQREL+TP5_TAREFA
	// Indice 3: TP5_FILIAL+TP5_CODFAM+TP5_TIPMOD+TP5_SERVIC+TP5_SEQREL+TP5_TAREFA
	//--------------------------------------------------------------------------
	If NGIFDBSEEK( "TP5", cFamilia + cModelo + cServico + cSequencia, nIdTP5)

		aCols := {}
		While !EoF()                          .And. ;
			   TP5->TP5_FILIAL == xFilial("TP5") .And. ;
			   TP5->TP5_CODFAM == cFamilia       .And. ;
			   (!lTipMod .Or. TP5->TP5_TIPMOD == cModelo) .And. ;
			   TP5->TP5_SERVIC == cServico       .And. ;
			   TP5->TP5_SEQREL == cSequencia

			aAdd(aCols,aClone(aTP5))
			For i := 1 To Len(aST5)
				cTP5 := aST5[i][2]
				cST5 := aST5[i][1]
				If FIELDPOS(cTP5) > 0
					cTP5            := FIELDGET(FIELDPOS(cTP5))
					aCols[nCOLS][i] := cTP5
					&cST5.          := cTP5
				EndIf
			Next
			dbSelectArea("TP5")
			nCOLS := nCOLS + 1
			dbSkip()
		End
	Else
		aCols := BLANKGETD(aHeader)
	EndIf

	oGET01:aHeader := aClone(aHeader)
	oGET01:aCols   := aClone(aCols)
	n              := Len(aCols)
	dbSelectArea("STF")
	lREFRESH := .T.
	oGET01:oBROWSE:REFRESH()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} NG120ATUTM
Atualiza o acols do STM conforme o padrão.

@author Deivys Joenck
@since  07/08/01
@Param  cFamilia  , Caracter, Código da Familia
@Param  cModelo   , Caracter, Código do Modelo
@Param  cServico  , Caracter, Serviço utilizado na MNT
@Param  cSequencia, Caracter, Sequência

/*/
//-------------------------------------------------------------------
Static Function NG120ATUTM( cFamilia, cModelo, cServico, cSequencia )

	Local aSTM	:= {}
	Local cSTM,cTPM,i

	aCols   := aClone(oGET02:aCols)
	aHeader := aClone(oGET02:aHeader)
	n       := Len(aCols)

	//--------------------------------------------------------------------------
	// Relaciona campos entre TPM (Dependências da Manutenção Padrão)
	// e STM (Dependências da Manutenção)
	//--------------------------------------------------------------------------
	For i := 1 To Len(aHeader)

		cSTM := "M->"+aHeader[i][2]
		If SUBSTR(cSTM,10,01) $ "0123456789"
			cTPM := "TPM_"+SUBSTR(cSTM,7,5)+SUBSTR(cSTM,13,01)
		Else
			cTPM := "TPM_"+SUBSTR(cSTM,7,6)
		EndIf
		aAdd(aSTM,{cSTM,cTPM})

	Next

	nCOLS := 1
	aTPM  := aClone(aCols[1])

	//--------------------------------------------------------------------------
	// Carrega Dependências da Manutenção Padrão (TPM)
	// Indice 2: TPM_FILIAL+TPM_CODFAM+TPM_TIPMOD+TPM_SERVIC+TPM_SEQREL+TPM_TAREFA+TPM_DEPEND
	//--------------------------------------------------------------------------
	If NGIFDBSEEK( "TPM", cFamilia + cModelo + cServico + cSequencia, nIdTPM )

		aCols := {}
		While !EoF()                             .And. ;
			   TPM->TPM_FILIAL == xFilial("TPM") .And. ;
			   TPM->TPM_CODFAM == cFamilia       .And. ;
			   (!lTipMod .Or. TPM->TPM_TIPMOD == cModelo) .And. ;
			   TPM->TPM_SERVIC == cServico       .And. ;
			   TPM->TPM_SEQREL == cSequencia

			aAdd(aCols,aClone(aTPM))
			For i := 1 To Len(aSTM)
				cTPM := aSTM[i][2]
				cSTM := aSTM[i][1]
				If FIELDPOS(cTPM) > 0
					cTPM            := FIELDGET(FIELDPOS(cTPM))
					aCols[nCOLS][i] := cTPM
					&cSTM.          := cTPM
				EndIf
			Next

			nPosicao := GDFIELDPOS("TM_NOMEDEP")
			If nPosicao > 0
				// Carrega Nome da Tarefa (TP5_DESCRI)
				// Indice 1: TP5_FILIAL+TP5_CODFAM+TP5_SERVIC+TP5_SEQREL+TP5_TAREFA
				// Indice 3: TP5_FILIAL+TP5_CODFAM+TP5_TIPMOD+TP5_SERVIC+TP5_SEQREL+TP5_TAREFA
				aCols[nCOLS][nPosicao] := IIf(lTipMod, NGSEEK( "TP5", cFamilia + cModelo + cServico + cSequencia + aCols[nCOLS][nDEPEND], IIf(lTipMod, 3, 1), "TP5_DESCRI" ),;
										  NGSEEK( "TP5", cFamilia + cServico + cSequencia + aCols[nCOLS][nDEPEND], 1, "TP5_DESCRI" ))
			EndIf
			dbSelectArea("TPM")
			nCOLS := nCOLS + 1
			dbSkip()
		End
	Else
		aCols := BLANKGETD(aHeader)
	EndIf

	oGET02:aHeader := aClone(aHeader)
	oGET02:aCols   := aClone(aCols)
	n              := Len(aCols)

	dbSelectArea("STF")
	lREFRESH := .T.
	oGET02:oBROWSE:REFRESH()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} NG120ATUTG
Atualiza o acols do STG conforme o padrão.

@author Deivys Joenck
@since  07/08/01
@Param  cFamilia  , Caracter, Código da Familia
@Param  cModelo   , Caracter, Código do Modelo
@Param  cServico  , Caracter, Serviço utilizado na MNT
@Param  cSequencia, Caracter, Sequência

/*/
//-------------------------------------------------------------------
Static Function NG120ATUTG( cFamilia, cModelo, cServico, cSequencia )

	Local i
	Local aSTG := {}
	Local cSTG := ""
	Local cTPG := ""

	aCols   := aClone(oGET03:aCols)
	aHeader := aClone(oGET03:aHeader)
	n       := Len(aCols)

	//--------------------------------------------------------------------------
	// Relaciona campos entre TPG (Insumos da Manutenção Padrão) e STG (Insumos da Manutenção)
	//--------------------------------------------------------------------------
	For i := 1 To Len(aHeader)

		cSTG := "M->" + aHeader[i][2]
		If SUBSTR(cSTG,10,01) $ "0123456789"
			cTPG := "TPG_"+SUBSTR(cSTG,7,5)+SUBSTR(cSTG,13,01)
		Else
			cTPG := "TPG_"+SUBSTR(cSTG,7,6)
		EndIf
		aAdd(aSTG,{cSTG,cTPG})

	Next

	nCOLS := 1
	aTPG  := aClone(aCols[1])

	//--------------------------------------------------------------------------
	// Carrega Insumos da Manutenção Padrão (TPG)
	// Indice 3: TPG_FILIAL+TPG_CODFAM+TPG_TIPMOD+TPG_SERVIC+TPG_SEQREL+TPG_TAREFA+TPG_TIPORE+TPG_CODIGO
	//--------------------------------------------------------------------------
	If NGIFDBSEEK( "TPG", cFamilia + cModelo + cServico + cSequencia, nIdTPG)

		aCols := {}
		While !EoF()                             .And. ;
			   TPG->TPG_FILIAL == xFilial("TPG") .And. ;
			   TPG->TPG_CODFAM == cFamilia       .And. ;
			   (!lTipMod .Or. TPG->TPG_TIPMOD == cModelo) .And. ;
			   TPG->TPG_SERVIC == cServico       .And. ;
			   TPG->TPG_SEQREL == cSequencia

			aAdd(aCols,aClone(aTPG))
			For i := 1 To Len(aSTG)
				cTPG := aSTG[i][2]
				cSTG := aSTG[i][1]
				If FIELDPOS(cTPG) > 0
					cTPG            := FIELDGET(FIELDPOS(cTPG))
					aCols[nCOLS][i] := cTPG
					&cSTG.          := cTPG
				EndIf
			Next
			dbSelectArea("TPG")

			//Adiciona valor ao campo TG_NOMECOD
			nPosicao := GDFIELDPOS("TG_NOMECOD")
			If nPosicao > 0
				If M->TG_TIPOREG == "M"
					M->TG_CODIGO := Left(M->TG_CODIGO,06)
					ST1->(dbSeek(xFilial("ST1")+M->TG_CODIGO))
					aCols[nCOLS][nPosicao] := Left(ST1->T1_NOME+SPACE(40),40)
				ElseIf M->TG_TIPOREG == "P"
					M->TG_CODIGO := Left(M->TG_CODIGO,15)
					SB1->(dbSeek(xFilial("SB1")+M->TG_CODIGO))
					aCols[nCOLS][nPosicao] := Left(SB1->B1_DESC+SPACE(40),40)
				ElseIf M->TG_TIPOREG == "T"
					M->TG_CODIGO := Left(M->TG_CODIGO,06)
					SA2->(dbSeek(xFilial("SA2")+M->TG_CODIGO))
					aCols[nCOLS][nPosicao] := Left(SA2->A2_NOME+SPACE(40),40)
				ElseIf M->TG_TIPOREG == "F"
					M->TG_CODIGO := Left(M->TG_CODIGO,06)
					SH4->(dbSeek(xFilial("SH4")+M->TG_CODIGO))
					aCols[nCOLS][nPosicao] := Left(SH4->H4_DESCRI+SPACE(40),40)
				Else
					M->TG_CODIGO := Left(M->TG_CODIGO,03)
					ST0->(dbSeek(xFilial("ST0")+M->TG_CODIGO))
					aCols[nCOLS][nPosicao] := Left(ST0->T0_NOME+SPACE(40),40)
				EndIf
			EndIf
			dbSelectArea("TPG")
			nCOLS := nCOLS + 1
			dbSkip()
		End
	Else
		aCols := BLANKGETD(aHeader)
	EndIf

	oGET03:aHeader := aClone(aHeader)
	oGET03:aCols   := aClone(aCols)
	n              := Len(aCols)

	dbSelectArea("STF")
	lREFRESH := .T.
	oGET03:oBROWSE:REFRESH()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} NG120ATUTH
Atualiza o acols do STH conforme o padrão.

@author Deivys Joenck
@since  07/08/01
@Param  cFamilia  , Caracter, Código da Familia
@Param  cModelo   , Caracter, Código do Modelo
@Param  cServico  , Caracter, Serviço utilizado na MNT
@Param  cSequencia, Caracter, Sequência

/*/
//-------------------------------------------------------------------
Static Function NG120ATUTH( cFamilia, cModelo, cServico, cSequencia )

	Local i
	Local nX     := 0
	Local nP1BEM := 0
	Local nP1SER := 0
	Local nP1SEQ := 0
	Local nP1TAR := 0
	Local nP1ETA := 0
	Local nP1OPC := 0
	Local aSTH   := {}
	Local cSTH   := ""
	Local cTPH   := ""

	aCols   := aClone(oGET04:aCols)
	aHeader := aClone(oGET04:aHeader)
	n       := Len(aCols)

	//--------------------------------------------------------------------------
	// Relaciona campos entre TPH (Etapas da Manutenção Padrão) e STH (Etapas da Manutenção)
	//--------------------------------------------------------------------------
	For i := 1 To Len(aHeader)

		cSTH := "M->" + aHeader[i][2]
		If SUBSTR(cSTH,10,01) $ "0123456789"
			cTPH := "TPH_"+SUBSTR(cSTH,7,5)+SUBSTR(cSTH,13,01)
		Else
			cTPH := "TPH_"+SUBSTR(cSTH,7,6)
		EndIf
		aAdd(aSTH,{cSTH,cTPH})

	Next

	nCOLS := 1
	aTPH  := aClone(aCols[1])

	//--------------------------------------------------------------------------
	// Valida se ja existia TP1
	//--------------------------------------------------------------------------
	If Len(aCopyTP1) > 0

		NGDBAREAORDE("TP1",1)
		nP1BEM := FieldPos('TP1_CODBEM')
		nP1SER := FieldPos('TP1_SERVIC')
		nP1SEQ := FieldPos('TP1_SEQREL')
		nP1TAR := FieldPos('TP1_TAREFA')
		nP1ETA := FieldPos('TP1_ETAPA')
		nP1OPC := FieldPos('TP1_OPCAO')

		For nX := 1 to Len(aCopyTP1)
			If dbSeek(xFilial("TP1")+aCopyTP1[nX][nP1BEM]+aCopyTP1[nX][nP1SER]+aCopyTP1[nX][nP1SEQ]+;
					  aCopyTP1[nX][nP1TAR]+aCopyTP1[nX][nP1ETA]+aCopyTP1[nX][nP1OPC])
				NGDELETAREG("TP1")
			EndIf
		Next nX
		aCopyTP1 := {}

	EndIf

	//--------------------------------------------------------------------------
	// Carrega Etapas da Manutenção Padrão (TPH)
	// Indice 6: TPH_FILIAL+TPH_CODFAM+TPH_TIPMOD+TPH_SERVIC+TPH_SEQREL+TPH_TAREFA+TPH_ETAPA
	//--------------------------------------------------------------------------
	If NGIFDBSEEK( "TPH", cFamilia + cModelo + cServico + cSequencia, nIdTPH )

		aCols := {}
		While !EoF()                            .And. ;
			   TPH->TPH_FILIAL == xFilial("TPH") .And. ;
			   TPH->TPH_CODFAM == cFamilia       .And. ;
			   (!lTipMod .Or. TPH->TPH_TIPMOD == cModelo) .And. ;
			   TPH->TPH_SERVIC == cServico       .And. ;
			   TPH->TPH_SEQREL == cSequencia

			aAdd(aCols,aClone(aTPH))
			For i := 1 To Len(aSTH)

				cTPH := aSTH[i][2]
				cSTH := aSTH[i][1]
				If FIELDPOS(cTPH) > 0
					cTPH            := FIELDGET(FIELDPOS(cTPH))
					aCols[nCOLS][i] := cTPH
					&cSTH.          := cTPH
				EndIf

			Next
			dbSelectArea("TPH")

			nPosicao := GDFIELDPOS("TH_NOMETAP")
			If nPosicao > 0
				TPA->(dbSeek(xFilial("TPA")+M->TH_ETAPA))
				aCols[nCOLS][nPosicao] := SUBSTR(TPA->TPA_DESCRI, 1, TamSX3('TH_NOMETAP')[1])
			EndIf

			//--------------------------------------------------------------------------
			// Manutenção Padrão
			//--------------------------------------------------------------------------
			If M->TF_PADRAO == "S"

				//--------------------------------------------------------------------------
				// Verifica as Opções das Etapas da Manutenção Padrão (TP2)
				// Indice 1: TP2_FILIAL+TP2_CODFAM+TP2_SERVIC+TP2_SEQREL+TP2_TAREFA+TP2_ETAPA+TP2_OPCAO
				// Indice 3: TP2_FILIAL+TP2_CODFAM+TP2_TIPMOD+TP2_SERVIC+TP2_SEQREL+TP2_TAREFA+TP2_ETAPA+TP2_OPCAO
				//--------------------------------------------------------------------------
				NGIFDBSEEK( "TP2", TPH->TPH_CODFAM + IIf(lTipMod, TPH->TPH_TIPMOD, '') + TPH->TPH_SERVIC + TPH->TPH_SEQREL + TPH->TPH_TAREFA + TPH->TPH_ETAPA, IIf(lTipMod, 3, 1) )
				While !EoF()                             .And. ;
					  TP2->TP2_FILIAL == xFilial('TP2')  .And. ;
					  TP2->TP2_CODFAM == TPH->TPH_CODFAM .And. ;
					  (!lTipMod .Or. TP2->TP2_TIPMOD == TPH->TPH_TIPMOD) .And. ;
					  TP2->TP2_SERVIC == TPH->TPH_SERVIC .And. ;
					  TP2->TP2_SEQREL == TPH->TPH_SEQREL .And. ;
					  TP2->TP2_TAREFA == TPH->TPH_TAREFA .And. ;
					  TP2->TP2_ETAPA  == TPH->TPH_ETAPA

					//--------------------------------------------------------------------------
					// Carrega Opções das Etapas da Manutenção (TP1)
					// Indice 1: TP1_FILIAL+TP1_CODBEM+TP1_SERVIC+TP1_SEQREL+TP1_TAREFA+TP1_ETAPA+TP1_OPCAO
					//--------------------------------------------------------------------------
					If !NGIFDBSEEK( "TP1", M->TF_CODBEM + M->TF_SERVICO + M->TF_SEQRELA + TP2->TP2_TAREFA + TP2->TP2_ETAPA + TP2->TP2_OPCAO, 1 )

						RecLock("TP1",.T.)
						TP1->TP1_FILIAL := xFilial("TP1")
						TP1->TP1_CODBEM := M->TF_CODBEM
						TP1->TP1_SERVIC := M->TF_SERVICO
						TP1->TP1_SEQREL := M->TF_SEQRELA
						TP1->TP1_TAREFA := TP2->TP2_TAREFA
						TP1->TP1_ETAPA  := TP2->TP2_ETAPA
						TP1->TP1_OPCAO  := TP2->TP2_OPCAO
						TP1->TP1_TIPRES := TP2->TP2_TIPRES
						TP1->TP1_CONDOP := TP2->TP2_CONDOP
						TP1->TP1_CONDIN := TP2->TP2_CONDIN
						TP1->TP1_TPMANU := TP2->TP2_TPMANU
						TP1->TP1_TIPCAM := TP2->TP2_TIPCAM
						TP1->TP1_FORMUL := TP2->TP2_FORMUL
						TP1->TP1_DESOPC := TP2->TP2_DESOPC
						TP1->TP1_BLOQMA := "S"
						TP1->TP1_BLOQFU := "S"
						TP1->TP1_BLOQFE := "S"
						MsUnLock()

						aAdd(aCopyTP1,{})
						For nX := 1 to FCOUNT()
							aAdd(aCopyTP1[Len(aCopyTP1)],&("TP1->"+FieldName(nX)))
						Next nX

					EndIf
					NGDBSELSKIP("TP2")

				End
			EndIf

			nCOLS := nCOLS + 1
			NGDBSELSKIP("TPH")

		End
	Else
		aCols := BLANKGETD(aHeader)
	EndIf

	oGET04:aHeader := aClone(aHeader)
	oGET04:aCols   := aClone(aCols)
	n              := Len(aCols)

	dbSelectArea("STF")
	lREFRESH := .T.
	oGET04:oBROWSE:REFRESH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG120OBRIG³ Autor ³ Paulo Pego            ³ Data ³ 02/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consiste a atualizacao dos campos do cadastro de Manutencao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120OBRIG(nOpcao)

	Local lRET     := .T.
	Local cOLDALI  := ""
    Local cVar     := ""
	Local cHeadClo := ""
	Local cAcolClo := ""
	Local nTanINEN := TamSX3("TF_INENMAN")[1]
	Local nTanTEEN := TamSX3("TF_TEENMAN")[1]

	If nOpcao == 2
		Return .T.
	EndIf

	cOLDALI := Alias()
	If !OBRIGATORIO(aGETS,aTELA)
		Return .F.
	Else
		If !NGSUBSTIT(M->TF_CODBEM+M->TF_SERVICO,M->TF_SEQRELA,M->TF_SUBSTIT)
			Return .F.
		EndIf
	EndIf

	NGENTRAENC("STF")
	If !MNTA120MTI()
		Return .F.
	EndIf
	If M->TF_PADRAO == 'S' .And. Empty(M->TF_SEQREPA)
		Help(" ",1,"OBRIGAT",,CHR(13)+RetTitSX3("TF_SEQREPA")+Space(35),3)
		Return .F.
	EndIf

	If M->TF_TIPACOM == "A"
		If !MNTA120Cr(M->TF_CODBEM+M->TF_SERVICO+M->TF_UNENMAN+Str(M->TF_TEENMAN,nTanTEEN),;
				"9","T",nOpcao,.F.)
			If !MNTA120Cr(M->TF_CODBEM+M->TF_SERVICO+Str(M->TF_INENMAN,nTanINEN),;
					"8","C",nOpcao)
				Return .F.
			EndIf
		EndIf
	ElseIf M->TF_TIPACOM == "T"
		If !MNTA120Cr(M->TF_CODBEM+M->TF_SERVICO+M->TF_UNENMAN+Str(M->TF_TEENMAN,nTanTEEN),;
				"9","T",nOpcao)
			Return .F.
		EndIf
	Else
		If !MNTA120Cr(M->TF_CODBEM+M->TF_SERVICO+Str(M->TF_INENMAN,nTanINEN),;
				"8","C",nOpcao)
			Return .F.
		EndIf
	EndIf

	If M->TF_PADRAO = "S"
		If Empty(M->TF_SEQRELA)
			lRET := .F.
		EndIf

		If !lRET
			MsgInfo(STR0063+Chr(13)+STR0064,STR0043)
			Return .F.
		EndIf
	EndIf

	NGSAIENC("STF")
	nControl := ((oFolder:nOption) - 1)
	If nControl > 0

    	cVar     := "oGET" + Strzero(nControl,2)
		cHeadClo := cVar + ":aHeader"
		cAcolClo := cVar + ":aCols"

		aSVCOLS[nControl]   := aClone(&cAcolClo) //Não remover, utilizado no NGSAIGET
		aSVHEADER[nControl] := aClone(&cHeadClo) //Não remover, utilizado no NGSAIGET
		NGSAIGET(nControl)

	EndIf

	lRet1 := lRet
	lRet  := NG_120TUDOOK()

	dbSelectArea(cOLDALI)
	If !lRet1
		lRet := lRet1
	EndIf

	If !lRET
		NGENTRAENC("STF")
	EndIf

	//Validade o campo data do ultimo acompanhamento.
	If lRET
		lRet := VLDDTUTLM()
	EndIf

	If ExistBlock("MNTA1203")
		lRet := ExecBlock("MNTA1203",.F.,.F.)
	EndIf

	If lRET
		//Limpa os campos de acordo com o tipo da manutenção
		If (M->TF_TIPACOM <> "T" .And. M->TF_TIPACOM <> "A")
			M->TF_TEENMAN := 0
			M->TF_UNENMAN := " "
		ElseIf M->TF_TIPACOM == "T"
			M->TF_CONMANU := 0
			M->TF_INENMAN := 0
		EndIf
	EndIf

Return lRET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BSEEK()   ³ Autor ³ Paulo Pego            ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche o Browse conforme o Parametro 6 da mBrowse        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERVACAO³   Tipo 1 -> Retorna CODIGO E NOME DO BEM                   ³±±
±±³          ³        2 -> Retorna CODIGO E NOME DO SERVICO               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BSEEK(cBUSCA,cRET)
dbSeek(xFilial()+cBUSCA)
Return &cRET.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG120_F3  ³ Autor ³ Paulo Pego            ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Altera a Consulta conforme o tipo de insumo                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120_F3()
nTIP  := GDFIELDPOS("TG_TIPOREG")
M->TG_TIPOREG := aCOLS[n][nTIP]
aTROCAF3 := {}

If M->TG_TIPOREG == "M"
   aAdd(aTROCAF3,{"TG_CODIGO","ST1"})
ElseIf M->TG_TIPOREG == "E"
   aAdd(aTROCAF3,{"TG_CODIGO","ST0"})
ElseIf M->TG_TIPOREG == "P"
   aAdd(aTROCAF3,{"TG_CODIGO","SB1"})
ElseIf M->TG_TIPOREG == "T"
   aAdd(aTROCAF3,{"TG_CODIGO","SA2"})
ElseIf M->TG_TIPOREG == "F"
   aAdd(aTROCAF3,{"TG_CODIGO","SH4"})
EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG130CHECK³ Autor ³ Paulo Pego            ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se o detalhe digitado esta OK                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTN120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Param    ³ cCod    - Indica o código da tarefa.                       ³±±
±±³          ³ lVerTar - Verifica se está validando o campo de tarefa.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG130CHECK(cCOD,lVerTar)

Local RET	:= .T.
Local QTD	:= 0
Local QTD2	:= 0
Local nTARM := GDFIELDPOS("TM_TAREFA")
Local nDEPE := GDFIELDPOS("TM_DEPENDE")
Local nNODE := GDFIELDPOS("TM_NOMEDEP")

Local cTAR  := aCOLS[n][nTARM], cSEQX := M->TF_SEQRELA

Default lVerTar	:= .F.

If !ST5->(dbSeek(xFilial("ST5")+cBEM120+cSER120+cSEQX+cCOD))
	Help(" ",1,"NG130NAOREG")
	RET := .F.
EndIf


If Empty(cTAR) .And. lVerTar //Verificar apenas ao validar a Tarefa
	If cCOD == aCols[n][nDEPE]
		MsgInfo(STR0079+" "+Alltrim(cTAR)+" "+STR0080 + ", " +STR0078+".",STR0043) //"A tarefa"#informe outra dependência"#"NÃO CONFORMIDADE"
		RET := .F.
	EndIf
EndIf


If RET
	aEVAL(aCOLS,{|x| If((x[nTARM] == cTAR .And. cCOD == x[nDEPE] .And. !aTail(x)),QTD++,Nil)})
	aEVAL(aCOLS,{|x| If((x[nTARM] == cCOD .And. cTAR == x[nDEPE] .And. !aTail(x)),QTD2++,Nil)})
	If QTD > 0
		Help(" ",1,"JAEXISTE")
		RET := .F.
	EndIf
EndIf


If RET .And. QTD2 > 0
	MsgInfo(STR0076+" "+Alltrim(cCOD)+" "+ STR0077+" "+ Alltrim(cTAR)+","+Chr(13); //"A dependência informada" #"já possui dependência com a tarefa"
				+STR0078+".",STR0043) //"informe outra dependência." # "NÃO CONFORMIDADE"
	RET := .F.
EndIf


If RET .And. cTar == cCOD
	MsgInfo(STR0079+" "+Alltrim(cTAR)+" "+STR0080 + ", " +STR0078+".",STR0043) //"A tarefa"#informe outra dependência"#"NÃO CONFORMIDADE"
	RET := .F.
EndIf


If RET
	If nNODE > 0
		If !lVerTar
			aCOLS[n][nNODE] := SubStr(ST5->T5_DESCRIC,1,20)
		EndIf
	EndIf
EndIf

Return RET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DELTP1OP  ³ Autor ³ Deivys Joenck         ³ Data ³ 10/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Deleta as opcoes da etapa                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DELTP1OP(vTAREF,vETAPA)
	If NGIFDBSEEK("TP1",  M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+vTAREF+vETAPA,1)
		While !EoF() .And. xFilial("TP1") == TP1->TP1_FILIAL .And.;
				TP1->TP1_CODBEM == M->TF_CODBEM  .And. TP1->TP1_SERVIC == M->TF_SERVICO .And.;
				TP1->TP1_SEQREL == M->TF_SEQRELA .And. TP1->TP1_TAREFA == vTAREF .And.;
				TP1->TP1_ETAPA  == vETAPA
			NGDELETAREG("TP1")
			dbSkip()
		EndDo
	EndIf
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG140CHECK³ Autor ³ Deivys Joenck         ³ Data ³ 07/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se o detalhe digitado esta OK                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTN120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG140CHECK(cCOD)

	Local cTarefa, cEtapa
	Local nX, nQtd := 0
	Local lRet     := .T.
	Local lVA120   := .F.
	Local aCampos  := {}
	nOPCOES := GDFIELDPOS("TH_OPCOES")
	cBEM120 := M->TF_CODBEM
	cSER120 := M->TF_SERVICO
	cSEQ120 := M->TF_SEQRELA
	cTAREFA := aCOLS[n][nTARH]
	cETAPA  := M->TH_ETAPA

	If TYPE("oGET04") <> 'U' .And. cPrograma != 'MNTA410'
		If Empty(aCOLS[n][nTARH]) .And. !Empty(M->TH_ETAPA) .And. AllTrim(M->TH_TAREFA) == "0"
			aCOLS[n][nTARH] := "0"+REPLICATE(" ",Len(ST5->T5_TAREFA)-1)
			oGET04:oBROWSE:REFRESH()
			cTAREFA := aCOLS[n][nTARH]
			If !NGIFDBSEEK("ST5",cBEM120+cSER120+cSEQ120+cTAREFA,1)
				RecLock("ST5",.T.)
				ST5->T5_FILIAL  := xFilial("ST5")
				ST5->T5_CODBEM  := cBEM120
				ST5->T5_SERVICO := cSER120
				ST5->T5_SEQRELA := cSEQ120
				ST5->T5_TAREFA  := "0"
				ST5->T5_DESCRIC := STR0013 //"SEM ESPECIFICA€ŽO DE TAREFA"
				MsUnLock("ST5")

				aAdd(oGET01:aCols,{"0",STR0013," "," ","ST5",Recno(),.F.})
			EndIf
		ElseIf Empty(aCOLS[n][nTARH])
			Help(" ",1,"OBRIGAT")
			lRet := .F.
		EndIf
	EndIf

	If !EXISTCPO("TPA",cCOD) .And. lRet
		lRet := .F.
	EndIf

	aEval(aCOLS,{|x| If(x[nTARH] == cTAREFA .And. x[nETAPA] == cETAPA, nQtd++,Nil)})

	If nQtd > 0 .And. lRet
		Help(" ",1,"JAEXISTE")
		lRet := .F.
	ElseIf lRet
		If Type("cPrograma") = 'C' .And. cPrograma = 'MNTA120'
			If NGIFDBSEEK("TPA",cCOD,1)

				If nNOMETA > 0
					aCOLS[n][nNOMETA] := TPA->TPA_DESCRI
				EndIf
				If nOPCOES > 0
					aCOLS[n][nOPCOES] := TPA->TPA_OPCOES
				EndIf
				lREFRESH := .T.
			EndIf
		Else
			If nNOMETA > 0
				aCOLS[n][nNOMETA] := NGSEEK("TPA",cCOD,1,"TPA_DESCRI")
			EndIf
		EndIf
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTSEGU1  ³ Autor ³ Thiago Machado        ³ Data ³ 22/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro do Segundo Contador                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNTSEGU1(cCODBEM)
cOLDALIAS := ALIAS()
lACHOU := .F.

If NGIFDBSEEK("TPE",cCODBEM,1)
   If NGIFDBSEEK("TPI",cCODBEM+M->TF_SERVICO+M->TF_SEQRELA,1)
      lACHOU := .T.
   Else
      APPEND BLANK
   EndIf
   aRELAC := {{"TPI_CODBEM","M->TF_CODBEM"} ,;
              {"TPI_SERVIC","M->TF_SERVICO"},;
              {"TPI_SEQREL","M->TF_SEQRELA"}}

   M->TPI_CODBEM := STF->TF_CODBEM
   M->TPI_SERVIC := STF->TF_SERVICO
   M->TPI_SEQREL := STF->TF_SEQRELA

   nRET :=NGCAD01("TPI",RECNO(),4)
   If nRET <> 1
      If !lACHOU
         dbDelete()
      EndIf
   EndIf

   dbSelectArea(cOLDALIAS)
   Return .T.
Else
   dbSelectArea(cOLDALIAS)
   Help(" ",1,"NGMBNSECON")//"Este bem nao possui segundo contador"
   Return
EndIf

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ NG120CHK ³ Autor ³ Thiago Olis Machado   ³ Data ³ 27.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120CHK(cTipo)
Local lRet := .F.
Local nCont := 0
Local nCntPrxMnt := 0 //Variável utilizada para soma do contador acumulado da manutenção e incremento da manutenção.

//Ponto de entrada para alterar logica dos semaforos
If ExistBlock("MNTA120L")
	Return ExecBlock("MNTA120L",.F.,.F.,{cTipo})
EndIf

If STF->TF_ATIVO <> "N" .And. STF->TF_PERIODO <> "E"
   If cTipo = "A" //Atrasar
   	  If STF->TF_TIPACOM $ "T/A"
         If !Empty(dProxManu) .And. dProxManu < dDATABASE
            lRet := .T.
         EndIf
      EndIf

      If STF->TF_TIPACOM != "T" .Or. STF->TF_TIPACOM == "A"
         If STF->TF_TIPACOM = 'S' //Segundo Contador
            NGIFDICIONA("TPE",xFilial("TPE")+STF->TF_CODBEM,1)
            nCont := TPE->TPE_CONTAC
         Else
            NGIFDICIONA("ST9",xFilial("ST9")+STF->TF_CODBEM,1)
            nCont := ST9->T9_CONTACU
         EndIf
         If lTolera
            If !lTolConE
               //Retirado o campo STF->TF_TOLERA pois manutenção vencia nao utiliza tolerancia
               If (STF->TF_CONMANU + STF->TF_INENMAN ) < nCont
                  lRet := .T.
               EndIf
            Else
               If (STF->TF_CONMANU + STF->TF_INENMAN + ST9->T9_VARDIA ) < nCont
                  lRet := .T.
               EndIf
            EndIf
         Else
            If (STF->TF_CONMANU + STF->TF_INENMAN) < nCont
               lRet := .T.
            EndIf
         EndIf
      EndIf

   ElseIf cTipo = "V" //A Vencer
      dProxManu := PROXMANU(STF->TF_CODBEM,STF->TF_SERVICO,STF->TF_SEQRELA,nPERFIXO, .T.)
      nDiasTol	:= If(lContManu, fVarTolCon(), STF->TF_TOLERA)
      lContManu	:= .F.
      If lTolera
         If STF->TF_TIPACOM $ "T/A"
            If !Empty(dProxManu)
            	//Se a data atual estiver no intervalo de tolerancia
            	//   Normal            			A Vencer           	  Atrasado
            	//<------------|      dDataBase(com Tolerancia)    |------------->
            	If (dProxManu >= dDATABASE)  .And.  ((dProxManu - nDiasTol) <= dDATABASE)
            		dbSelectArea("STF")
                  	Return .T.
               EndIf
            EndIf
         EndIf

         If STF->TF_TIPACOM != "T"
            If STF->TF_TIPACOM = 'S' //Segundo Contador
               NGIFDICIONA("TPE",xFilial("TPE")+STF->TF_CODBEM,1)
               nCont := TPE->TPE_CONTAC
            Else
               NGIFDICIONA("ST9",xFilial("ST9")+STF->TF_CODBEM,1)
               nCont := ST9->T9_CONTACU
            EndIf
            //Verifica se o contador nao passou a margem na manutencao
            //e se for verificado do tipo "Tempo/Contador" verifica se nao esta atrasado
            If !lTolConE
            	//Retirada verificação "contador da manutenção + incremento da manutenção + tolerância",
            	//pois não se aplica tolerância em manutenção vencida.
            	nCntPrxMnt := STF->TF_CONMANU + STF->TF_INENMAN
				If nCont <= nCntPrxMnt .And. nCont >= ( nCntPrxMnt - STF->TF_TOLECON ) .And.;
					If(STF->TF_TIPACOM == "A",(dProxManu + nDiasTol) >= dDATABASE, .T.)

                  lRet := .T.
               EndIf
            Else
               nTolEsp := ST9->T9_VARDIA * STF->TF_TOLERA
               If STF->TF_CONMANU + STF->TF_INENMAN+nTolEsp >= nCont .And.;
                 (STF->TF_CONMANU + STF->TF_INENMAN) - nTolEsp <= nCont .And.;
               		If(STF->TF_TIPACOM == "A",(dProxManu + nDiasTol) >= dDATABASE, .T.)

                  lRet := .T.
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf
EndIf

dbSelectArea("STF")
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ NG120LEG ³ Autor ³ Thiago Olis Machado   ³ Data ³ 27.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120LEG()
Local aLegenda := {}

aAdd(aLegenda,{"ENABLE",OEMTOANSI(STR0024)}) //"Em dia"
If lTolera
   aAdd(aLegenda,{"BR_AMARELO","A Vencer"})    //"A Vencer"
EndIf
aAdd(aLegenda,{"BR_VERMELHO",STR0025})      //"Atrasada"
aAdd(aLegenda,{"BR_PRETO",STR0046})         //"Inativa

BrwLegenda(cCADASTRO,STR0023,aLegenda) //"Legenda"

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NG_120TUDOOK
Consistência final.

@author	Thiago Olis Machado
@since		27.06.01
@version	MP11 e MP12
/*/
//---------------------------------------------------------------------
User Function NG_120TUDOOK()

	Local _lEmpty,nx,nf

	If M->TF_TIPACOM == "T" .And. M->TF_UNENMAN == "H" //Se o tipo de acompanhamento for igual à 'Tempo' e Unidade for controlada por 'Hora'.
		If M->TF_TEENMAN > 23 //Se o tempo da manutenção for maior que 23 horas.
			ShowHelpDlg( STR0100,{ STR0133 },1,{ STR0134 },1 )
			Return .F.
		EndIf
	EndIf

	If !VldALLGet1(.T.)
		Return .F.
	EndIf

	If !VldALLGet2(.T.)
		Return .F.
	EndIf

	If !VldALLGet3(.T.)
		Return .F.
	EndIf

	If !VldALLGet4( oGet04:aCols, oGet04:aHeader, oGet01:aCols, oGet01:aHeader, 'MNTA120' )
		Return .F.
	EndIf

	ENTRAGET(4)
	_lEmpty := .F.
	If Empty(aCols[1][1])
		_lEmpty := .T.
	EndIf

	If !_lEmpty
		For nx:=1 To Len(aCols)
			If !aTail(aCols[1])
				If !aCols[NX][Len(aCols[NX])]
					If Empty(aCols[NX][nTARH]) .Or. Empty(aCols[NX][nETAPA])
						Help(" ",1,"OBRIGAT")
						Return .F.
					EndIf
				EndIf
			EndIf
		Next
	EndIf

	If !_lEmpty
		aCOLSC1 := Aclone(oGET01:aCols)
		lRETTAR := .T.
		If Len(aCOLSC1) > 0
			For nf := 1 To Len(aCOLSC1)
				cTARPRIN := aCOLSC1[nf,1]
				If aCOLSC1[nf][Len(aCOLSC1[nf])]
					// DEPENDENCIAS
					If Len(oGET02:aCols) > 0
						lRETTAR := NG120TARFOL(oGET02:aCols,STR0027,1,2)
					EndIf

					// INSUMOS
					If lRETTAR
						If Len(oGET03:aCols) > 0
							lRETTAR := NG120TARFOL(oGET03:aCols,STR0030,1)
						EndIf
					EndIf

					// ETAPAS
					If lRETTAR
						If Len(oGET04:aCols) > 0
							lRETTAR := NG120TARFOL(oGET04:aCols,STR0028,1)
						EndIf
					EndIf
				EndIf
			Next nf
		EndIf

		If !lRETTAR
			aSVCOLS[4]   := aClone(oGET04:aCols)   //Não remover, utilizado no NGSAIGET
			aSVHEADER[4] := aClone(oGET04:aHeader) //Não remover, utilizado no NGSAIGET
			NGSAIGET(4)
			ENTRAGET(1)
			Return .F.
		EndIf

	EndIf

	aSVCOLS[4]   := aClone(oGET04:aCols)   //Não remover, utilizado no NGSAIGET
	aSVHEADER[4] := aClone(oGET04:aHeader) //Não remover, utilizado no NGSAIGET
	NGSAIGET(4)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³MNT120PROX³ Autor ³ Thiago Olis Machado   ³ Data ³ 27.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Data da proxima manutencao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNT120PROX(cBem)
_DtProx := NGXPROXMAN(cBem)

If INCLUI
   ShowHelpDlg(OemToAnsi(STR0050),{OemToAnsi(STR0115)},3,; //"Não é possivel verificar a data da próxima manutenção na opção de inclusão."
              {OemToAnsi(STR0091)},2) //"Escolha outra opção no menu que não seja Incluir ou Copia."
   Return .F.
Else
	If STF->TF_PERIODO != "E"
		MsgInfo(STR0048+DtoC(_DtProx)) //"Data da Proxima Manutencao :"
	Else
		MsgInfo(STR0111)  //"Em manutenções eventuais não é possível calcular data da próxima manutenção."
	EndIf
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NG120ENCOK³ Autor ³ Thiago Olis Machado   ³ Data ³ 27.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Consistencia da enchoice                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120ENCOK()
	Local lRet := .T.

	NGENTRAENC("STF")
	If !MNTA120MTI()
		lRet := .F.
	EndIf

	aSvaTela := aClone(aTela)
	aSvaGets := aClone(aGets)

	dbSelectArea("STF")
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³MNTA120MTI³ Autor ³ In cio Luiz Kolling   ³ Data ³18/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Consistencia do tipo de companhamento e campos obrigat¢rios ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNTA120MTI()
Local cRETMTI := Space(10)
Local lRet := .T.

If M->TF_PERIODO == "E"
	lRet := .T.
Else
	If M->TF_TIPACOM == "T"
	   If Empty(M->TF_TEENMAN)
	      cRETMTI := "TEENMAN"
	   EndIf
	   If Empty(cRETMTI) .And. Empty(M->TF_UNENMAN)
	      cRETMTI := "UNENMAN"
	   EndIf
	ElseIf M->TF_TIPACOM == "C"
	   If Empty(M->TF_INENMAN)
	      cRETMTI := "INENMAN"
	   EndIf
	   If Empty(cRETMTI) .And. Empty(M->TF_CONMANU)
	      cRETMTI := "CONMANU"
	   EndIf
	ElseIf M->TF_TIPACOM == "P"
	   If Empty(M->TF_INENMAN)
	      cRETMTI := "INENMAN"
	   EndIf
	   If Empty(cRETMTI) .And. Empty(M->TF_CONMANU)
	      cRETMTI := "CONMANU"
	   EndIf
	ElseIf M->TF_TIPACOM == "A"
	   If Empty(M->TF_TEENMAN)
	      cRETMTI := "TEENMAN"
	   EndIf
	   If Empty(cRETMTI) .And. Empty(M->TF_UNENMAN)
	      cRETMTI := "UNENMAN"
	   EndIf
	   If Empty(cRETMTI) .And. Empty(M->TF_INENMAN)
	      cRETMTI := "INENMAN"
	   EndIf
	   If Empty(cRETMTI) .And. Empty(M->TF_CONMANU)
	      cRETMTI := "CONMANU"
	   EndIf
	ElseIf M->TF_TIPACOM == "F"
	   If Empty(M->TF_INENMAN)
	      cRETMTI := "INENMAN"
	   EndIf
	   If Empty(cRETMTI) .And. Empty(M->TF_CONMANU)
	      cRETMTI := "CONMANU"
	   EndIf
	EndIf
EndIf

If !Empty(cRETMTI)
   Help(" ",1,cRETMTI)
   lRet := .F.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NG120CON2 ³ Autor ³ Thiago Olis Machado   ³ Data ³ 27.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Consistencia do segundo contador                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120CON2()
lFind := .F.
If (TPE->(dbSeek(xFilial("TPE")+M->TF_CODBEM)),lFind:=.T.,lFind:=.F.)
   If !lFind
      Help(" ",1,"NGSEMSEG")
      Return .F.
   EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NG120PESQ ³ Autor ³ Thiago Olis Machado   ³ Data ³ 27.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³pesquisa da manutencao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120PESQ()
Local nINDOLD := 0
dbSelectArea('STF')
nINDOLD := Indexord()
AxPESQUI('STF',Recno(),1)
dbSelectArea('STF')
dbSetOrder(nINDOLD)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NG120TARFOL³ Autor ³ In cio Luiz Kolling   ³ Data ³07/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Validacao da exclusao da tarefa                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NG120TARFOL(aVCOLS,cDESI,nCOL1,nCOL2,nFOLDT)
Local cMENDET := Space(10),nLPTAR := 0, aCOLITE := Aclone(aVCOLS)
Local nFOLDEA := If(nFOLDT = Nil,((oFolder:nOption) - 1),1)
If nFOLDEA = 1
   For nLPTAR := 1 To Len(aCOLITE)
      If !aCOLITE[nLPTAR][Len(aCOLITE[nLPTAR])]
         If aCOLITE[nLPTAR][nCOL1] = cTARPRIN
            cMENDET := cDESI
            Exit
         EndIf
         If nCOL2 <> Nil
            If aCOLITE[nLPTAR][nCOL2] = cTARPRIN
               cMENDET := cDESI
               Exit
            EndIf
         EndIf
      EndIf
   Next nLPTAR

   If !Empty(cMENDET)
      MsgInfo(STR0032+chr(13)+chr(10)+"( "+cMENDET+" )",STR0043)
      Return .F.
   EndIf
EndIf
Return .T.

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GRAVATAF  ³Autor ³Inacio Luiz kolling    ³ Data ³11/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Deleta as tarefas marcadas para exclusÆo                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GRAVATAF()
Local aCOLS1F := Aclone(oGET01:aCols),nDF := 0
Local cCHAVEF := M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA
For nDF := 1 To Len(aCOLS1F)
   If aCOLS1F[nDF][Len(aCOLS1F[nDF])]
      cCHAVEAF := cCHAVEF+aCOLS1F[nDF][nTAREFA]
      If NGIFDBSEEK("ST5",cCHAVEAF,1)
         lDELST5 := If(NGIFDBSEEK("STG",cCHAVEAF,1),.F.,.T.)
         If lDELST5
            lDELST5 := If(NGIFDBSEEK("STM",cCHAVEAF,1),.F.,.T.)
         EndIf
         If lDELST5
            lDELST5 := If(NGIFDBSEEK("STH",cCHAVEAF,1),.F.,.T.)
         EndIf
         If lDELST5
            dbSelectArea('ST5')
            If !EoF()
               NGDELETAREG("ST5")
            EndIf
         EndIf
      EndIf
   EndIf
Next nDF
Return .T.

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GRAVTARPAD ³Autor ³Elisangela Costa       ³ Data ³14/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava as tarefas  vindas da manutencao padrao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GRAVTARPAD()
Local nx,nMaxArray,i

If nOPCAO == 3 .Or. nOPCAO == 4
   If aHEADER[1][2] != "T5_TAREFA"
	  aHeader := aClone(oGET01:aHeader)
	  aCols   := aClone(oGET01:aCols)
   EndIf
   nMaxArray := Len(aCOLS)
   NGIFDBSEEK("ST5",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA,1)
   If Found()
      While !EoF() .And. ST5->T5_FILIAL = xFilial("ST5") .And.;
         ST5->T5_CODBEM = M->TF_CODBEM .And. ST5->T5_SERVICO = M->TF_SERVICO;
         .And. ST5->T5_SEQRELA = M->TF_SEQRELA
         NGDELETAREG("ST5")
         dbSkip()
      End
   EndIf

   For nx := 1 To nMaxArray
      If !Empty(aCOLS[nx][1])
         If !aCOLS[nx][Len(aCOLS[nx])]
            If !NGIFDBSEEK("ST5",M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+aCOLS[nx][nTAREFA],1)
               RecLock("ST5",.T.)
               ST5->T5_FILIAL  := xFilial("ST5")
               ST5->T5_CODBEM  := M->TF_CODBEM
               ST5->T5_SERVICO := M->TF_SERVICO
               ST5->T5_SEQRELA := M->TF_SEQRELA

               For i := 1 To Fcount()
                  xx := GDFIELDPOS(AllTrim(Fieldname(i)))
                  If xx > 0
                     vv   := "ST5->"+Fieldname(i)
                     &vv. := aCOLS[nx][xx]
                     If Fieldname(i) == "T5_ATIVA" .And. Empty(aCOLS[nx][xx])
                     	&vv. := "1"
                     EndIf
                  EndIf
               Next i
               MsUnLock("ST5")
            EndIf

            If aScan(aAddTT9,{|x| x == ST5->T5_TAREFA}) > 0
               NGGTARPADRA(ST5->T5_TAREFA,ST5->T5_DESCRIC)
            EndIf
         EndIf
      EndIf
   Next nx
EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT120QDO ³ Autor ³ Elisangela Costa      ³ Data ³ 11/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a tela de visualizacao ou relacionamento do documento |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNT120QDO()
Local oDlgQdo,oRadio
Local nRadio := 1,nOpc := 1
Local lRet := .T.,lGrava
Private lDOCSTH := .F.

dbSelectArea("STH")
   lDOCSTH := .T.
   If oFolder:nOption <> 1 .And. oFolder:nOption <> 2 .And. oFolder:nOption <> 5
      MsgInfo(STR0082,STR0043) //"Relaciona apenas documentos da manutencao, tarefa ou etapa."#"NAO CONFORMIDADE"
      Return .T.
   EndIf


Define MsDialog oDlgQdo From 03.5,6 To 150,320 Title STR0050 Pixel //"Atencao"
Define FONT oBold NAME "Courier New" SIZE 0, -13 BOLD
@ 0, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgQdo SIZE 35,250 NOBORDER WHEN .F. PIXEL

@ 05,040 Say OemToAnsi(STR0051) Size 117,7 Of oDlgQdo Pixel Font oBold  //"O que deseja fazer ?"

@ 20,048 Radio oRadio Var nRadio Items STR0052,STR0053,STR0054 3d Size 105,10 Of oDlgQdo Pixel //"Relacionar um documento"#"Visualizar documento relacionado"#"Apagar documento relacionado"

Define sButton From 055,090 Type 1 Enable Of oDlgQdo Action (lGrava := .T.,oDlgQdo:End())
Define sButton From 055,120 Type 2 Enable Of oDlgQdo Action (lGrava := .F.,oDlgQdo:End())

Activate MsDialog oDlgQdo Centered

If !lGrava
	lRet := .F.
Else
	If nRadio == 1
		If !MNT120RQDO()
			lRet := .F.
		EndIf
	ElseIf nRadio == 2
		If !MNT120VQDO()
			lRet := .F.
		EndIf
	Else
		If oFolder:nOption = 1
			M->TF_DOCTO  := "  "
			M->TF_DOCFIL := "  "
		ElseIf oFolder:nOption = 2
			If nDOCTO > 0
				aCOLS[n][nDOCTO]  := "  "
			EndIf
			If nDOCFIL > 0
				aCOLS[n][nDOCFIL] := "  "
			EndIf
			If NGIFDBSEEK("ST5",cBEM120+cSER120+cSEQ120+aCOLS[n][1],1)
				RecLock("ST5",.F.)
				ST5->T5_DOCTO  := "  "
				ST5->T5_DOCFIL := "  "
				MsUnLock("ST5")
			EndIf
		ElseIf oFolder:nOption = 5
			If lDOCSTH
				If nDOCTOSTH > 0
					aCOLS[n][nDOCTOSTH]  := "  "
				EndIf
				If nDOCFILSTH > 0
					aCOLS[n][nDOCFILSTH] := "  "
				EndIf
			EndIf
		EndIf
	EndIf
EndIf


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT120RQDO³Autor  ³ Elisangela Costa      ³ Data ³ 11/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relaciona um procedimento a um documento QDO                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNT120RQDO()
Local lRet := .F.
lRet := ConPad1( , , , "QDH",,,.F.)
If lRet
	If oFolder:nOption = 1
		M->TF_DOCTO  := QDH->QDH_DOCTO
		M->TF_DOCFIL := QDH->QDH_FILIAL
	ElseIf oFolder:nOption = 2
		If nDOCTO > 0
			aCOLS[n][nDOCTO]  := QDH->QDH_DOCTO
		EndIf
		If nDOCFIL > 0
			aCOLS[n][nDOCFIL] := QDH->QDH_FILIAL
		EndIf
		If NGIFDBSEEK("ST5",cBEM120+cSER120+cSEQ120+aCOLS[n][1],1)
			RecLock("ST5",.F.)
			If nDOCTO > 0
				ST5->T5_DOCTO  := aCOLS[n][nDOCTO]
			EndIf
			If nDOCFIL > 0
				ST5->T5_DOCFIL := aCOLS[n][nDOCFIL]
			EndIf
			MsUnLock("ST5")
		EndIf
	ElseIf oFolder:nOption = 5
		If lDOCSTH
			If nDOCTOSTH > 0
				aCOLS[n][nDOCTOSTH]  := QDH->QDH_DOCTO
			EndIf
		EndIf
		If nDOCFILSTH > 0
			aCOLS[n][nDOCFILSTH] := QDH->QDH_FILIAL
		EndIf
	EndIf

EndIf

Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT120VQDO³Autor  ³ Elisangela Costa      ³ Data ³ 11/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Visualiza um documento QDO                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNT120VQDO()
Local _lRet := .F.

If oFolder:nOption = 1
	If !Empty(M->TF_DOCTO)
		If QDOVIEW( , M->TF_DOCTO) //Visualiza documento Word...
			_lRet := .T.
		EndIf
	Else
		MsgInfo(STR0055,STR0043)//"Nao existe documento associado a esta manutencao."#"NAO CONFORMIDADE"
	EndIf
ElseIf  oFolder:nOption = 2
	If nDOCTO > 0
		If !Empty(aCOLS[n][nDOCTO])
			If QDOVIEW( , aCOLS[n][nDOCTO]) //Visualiza documento Word...
				_lRet := .T.
			EndIf
		Else
			MsgInfo(STR0083,STR0043) //"Nao existe documento associado a esta tarefa."#"NAO CONFORMIDADE"
		EndIf
	EndIf
ElseIf  oFolder:nOption = 5
	If lDOCSTH
		If nDOCTOSTH > 0
			If !Empty(aCOLS[n][nDOCTOSTH])
				If QDOVIEW( , aCOLS[n][nDOCTOSTH]) //Visualiza documento Word...
					_lRet := .T.
				EndIf
			Else
				MsgInfo(STR0084,STR0043) //"Nao existe documento associado a esta etapa."#"NAO CONFORMIDADE"
			EndIf
		EndIf
	EndIf
EndIf


Return _lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA120IMA
Valida se a manutencao tem ordem de servico liberadas e nao terminadas.

@author		Inacio Luiz Kolling
@since		22/02/2006
@version	MP11 e MP12
/*/
//---------------------------------------------------------------------
User Function MNTA120IMA()

	Local aAreaco := GetArea(), cMENSAN := Space(1)
	Local cCHAVEA := "B"+M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA
	Local cLOPSTJ := "stj->tj_codbem+stj->tj_servico+stj->tj_seqrela"
	Local aAreaTF := STF->(GetArea()),lTemOS := .F.

	aArea := GetArea()

	dbSelectArea( "ST9" )
	dbSetOrder( 01 )
	If dbSeek( xFilial( "ST9" ) + M->TF_CODBEM ) //Se encontrar o Bem.
		If M->TF_ATIVO == "S" .And. ST9->T9_SITBEM == "I" //Se a manutenção estiver ativa e o bem estiver com a situação atual igual à 'Inativo'.
			//"Não é possível tornar a manutenção ativa quando o Bem estiver com a situação atual igual à 'Inativo'."
			ShowHelpDlg( STR0050,{ STR0131 },1,{ STR0132+AllTrim( M->TF_CODBEM )},2 ) //"Acessar o Cadastro de Bens e alterar a situação atual do Bem: "
			Return .F.
		EndIf
	EndIf

	RestArea( aArea )

	If M->TF_ATIVO = "N"
		If NGIFDBSEEK("STJ",cCHAVEA,6)
			While !EoF() .And. Xfilial("STJ") = stj->tj_filial .And. cCHAVEA = "B"+&(cLOPSTJ)
				If stj->tj_situaca <> "C" .And. stj->tj_termino = "N"
					cMENSAN := STR0056 //"Existe ordem de servico aberta para a manutencao"
					Exit
				EndIf
				dbSkip()
			End While
		EndIf

		If !Empty( cMENSAN )
			lTemOS := .T.
			MsgInfo( cMENSAN,STR0043 )
		EndIf
	EndIf

	If Empty(cMENSAN)

		//Verifica se a Manutenção do Bem+Servico tem aglutinação
		lTemAglut := .F.
		vVetSeqS  := MNTSepSeq(M->TF_SUBSTIT)
		If Empty(vVetSeqS)
			NGIFDBSEEK("STF",M->TF_CODBEM+M->TF_SERVICO,1)
			While !EoF() .And. xFilial("STF")+M->TF_CODBEM+M->TF_SERVICO == STF->(TF_FILIAL+TF_CODBEM+TF_SERVICO)

				If M->TF_SEQRELA <> STF->TF_SEQRELA .And. !Empty(MNTSepSeq(STF->TF_SUBSTIT))
					lTemAglut := .T.
					Exit
				EndIf
				dbSkip()

			End While
		Else
			lTemAglut := .T.
		EndIf

		If lTemAglut
			If !NG120F11( M->TF_CODBEM , M->TF_SERVICO , nOPCAO , .T. )
				cMENSAN := "Error"
			EndIf
		EndIf

	EndIf

	RestArea(aAreaTF)
	RestArea(aAreaco)

Return If( Empty(cMENSAN),.T.,.F. )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTA120OP ³ Autor ³Inacio Luiz Kolling    ³ Data ³22/02/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ordem de servico pendentes da manutencao (Liberadas e nao   ³±±
±±³          ³terminadas)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNTA120OP()

	Local aNgBeginPrm := NgBeginPrm()
	Local aArea := GetArea()
	aNGButton := {}

	cCadastro := OemtoAnsi(STR0012+" "+STR0058) //"Ordem Servico Manutencao (Pendentes)"

	lCORRET   := .F.

	aRotina   := {{STR0004,"AxPesqui"  , 0, 1},;    //"Pesquisar"
				  {STR0005,"NGCAD01"   , 0, 2},;    //"Visual."
				  {STR0059,"OsDetalhe" , 0, 4},;    //"Detalhes"
				  {STR0060,"OsOcorre"  , 0, 4},;    //"Ocorren."
				  {STR0061,"OsProblema", 0, 4},;    //"proBlemas"
				  {STR0062,"NGATRASOS" , 0, 4,0},;  //"Motivo Atraso"
				  {STR0028,"OsEtapas"  , 0, 4},;    //"Etapas   "
				  {STR0088,"MNT120IMP" , 0, 4}}     //"Imprimir"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'STJ' ) // Alias da tabela utilizada
	oBrowse:SetFilterDefault( fFilterBrw("MNTA120OP") ) //Filtro do Alias
	oBrowse:SetDescription( cCadastro ) // Descrição do browse
	oBrowse:Activate()

	RestArea( aArea )
	NgReturnPrm( aNgBeginPrm )

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTA120PAD³ Autor ³Inacio Luiz Kolling    ³ Data ³21/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Desmar a sequencia da padrao                                ³±±
±±³          ³terminadas)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNTA120PAD()

	Local nVp := 0
	Local aAreaTPF

	Private cTipMod := ""
	Private nIdTPF  := 1
	Private nIdTP5  := 1
	Private nIdTPM  := 1
	Private nIdTPG  := 1
	Private nIdTPH  := 1

	NGIFDBSEEK("ST9",M->TF_CODBEM,1)
	If lTipMod
		cTipMod := ST9->T9_TIPMOD
		nIdTPF  := 4
		nIdTP5  := 3
		nIdTPM  := 2
		nIdTPG  := 3
		nIdTPH  := 6
	EndIf

	If M->TF_PADRAO = "N"

		aAreaTPF := TPF->( GetArea() )

		//--------------------------------------------------------------------------
		// Posiciona na Manutenção Padrão (TPF)
		//--------------------------------------------------------------------------
		If fManutPad( cTipMod, M->TF_SERVICO + M->TF_SEQREPA, nIdTPF )

			// Deleta as tarefas
			For nVp := Len(oGET01:aCols) To 1 step - 1
				If NGIFDBSEEK( "TP5", TPF->TPF_CODFAM + IIf(lTipMod, TPF->TPF_TIPMOD, cTipMod) + TPF->TPF_SERVIC + TPF->TPF_SEQREL + oGET01:aCols[nVp,nTAREFA], nIdTP5 )
					Adel(oGET01:aCols,nVp)
					Asize(oGET01:aCols,Len(oGET01:aCols)-1)
				EndIf
			Next nVp

			If Len(oGET01:aCols) = 0
				NGSETIFARQUI("ST5","F",1)
				oGET01:aCols := BLANKGETD(oGET01:aHeader)
			EndIf

			// Deleta as dependencias
			For nVp := Len(oGET02:aCols) To 1 step - 1
				If NGIFDBSEEK( "TPM", TPF->TPF_CODFAM + IIf(lTipMod, TPF->TPF_TIPMOD, cTipMod) + TPF->TPF_SERVIC + TPF->TPF_SEQREL + oGET02:aCols[nVp,nTARM] + oGET02:aCols[nVp,nDEPEND], nIdTPM )
					Adel(oGET02:aCols,nVp)
					Asize(oGET02:aCols,Len(oGET02:aCols)-1)
				EndIf
			Next nVp

			If Len(oGET02:aCols) = 0
				NGSETIFARQUI("STM","F",1)
				oGET02:aCols := BLANKGETD(oGET02:aHeader)
			EndIf

			// Deleta os insumos
			For nVp := Len(oGET03:aCols) To 1 step - 1
				If NGIFDBSEEK( "TPG", TPF->TPF_CODFAM + IIf(lTipMod, TPF->TPF_TIPMOD, cTipMod) + TPF->TPF_SERVIC + TPF->TPF_SEQREL + ;
								oGET03:aCols[nVp,nTARG] + oGET03:aCols[nVp,nTIPORE] + oGET03:aCols[nVp,nCODIGO], nIdTPG )
					Adel(oGET03:aCols,nVp)
					Asize(oGET03:aCols,Len(oGET03:aCols)-1)
				EndIf
			Next nVp

			If Len(oGET03:aCols) = 0
				NGSETIFARQUI("STG","F",1)
				oGET03:aCols := BLANKGETD(oGET03:aHeader)
			EndIf

			// Deleta as etapas
			For nVp := Len(oGET04:aCols) To 1 step - 1
				If NGIFDBSEEK( "TPH", TPF->TPF_CODFAM + IIf(lTipMod, TPF->TPF_TIPMOD, cTipMod) + TPF->TPF_SERVIC + TPF->TPF_SEQREL + oGET04:aCols[nVp,nTARH] + oGET04:aCols[nVp,nETAPA], nIdTPH )
					Adel(oGET04:aCols,nVp)
					Asize(oGET04:aCols,Len(oGET04:aCols)-1)
				EndIf
			Next nVp

			If Len(oGET04:aCols) = 0
				NGSETIFARQUI("STH","F",1)
				oGET04:aCols := BLANKGETD(oGET04:aHeader)
			EndIf

		EndIf

		RestArea( aAreaTPF )

		M->TF_SEQUEPA := 0
		M->TF_SEQREPA := Space(Len(M->TF_SEQREPA))
		lREFRESH := .T.

	Else

		If Inclui

			// Verifica se encontra manutenção padrão para os dados informados
			// Inicialmente utiliza a sequencia na pesquisa
			If fManutPad( cTipMod, M->TF_SERVICO + M->TF_SEQRELA, nIdTPF )
				M->TF_SEQUEPA := 0
				M->TF_SEQREPA := M->TF_SEQRELA
				CARREG180("M->TF_SEQREPA")

			// Caso não tenha encontrado com a chave completa,
			// realiza uma nova busca desconsiderando a sequencia
 			ElseIf !fManutPad( cTipMod, M->TF_SERVICO, nIdTPF ) .And. Empty(M->TF_SEQREPA)
				Help(" ",1,"NREGFASERV")
				Return .F.
			EndIf
			lREFRESH := .T.
		EndIf

	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³29/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local lPyme := Iif(Type("__lPyme") <> "U",__lPyme,.F.)
Local aRotNew := {}
Local aImpMnt := {{STR0094,"MNTA120IMP()",0,6,0},;  //"Manutenções do Bem"
                  {STR0095,"MNTA120IMP({STF->TF_FILIAL,STF->TF_CODBEM,STF->TF_SERVICO,STF->TF_SEQRELA})",0,6,0}}  //"Manutenção Selecionada"

Local aROTINA := {{STR0004,"AxPesqui"  , 0, 1},;      //"Pesquisar"
                  {STR0005,"NG120FOLD" , 0, 2},;      //"Visualizar"
                  {STR0006,"NG120FOLD" , 0, 3},;      //"Incluir"
                  {STR0007,"NG120FOLD" , 0, 4,0},;    //"Alterar"
                  {STR0008,"NG120FOLD" , 0, 5,3},;    //"Excluir"
                  {STR0089,"NG120COPY" , 0, 5},;      //"Copia"
                  {STR0023,"NG120LEG"  , 0, 7,,.F.},; //"Legenda"
                  {STR0088,aImpMnt     , 0, 6,0}}     // "Imprimir"

If ExistBlock("MNTA1204")
	aRotNew := ExecBlock("MNTA1204",.F.,.F.,{aRotina})
	If ValType(aRotNew) == "A"
		aRotina := aClone(aRotNew)
	EndIf
EndIf

If !lPyme
   AAdd(aRotina,{STR0045,"MsDocument", 0, 4})  //"Conhecimento"
EndIf

Return(aRotina)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTA120Cr ³ Autor ³Inacio Luiz Kolling    ³ Data ³22/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia do incremento da manutencao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNTA120Cr(cVChav,cInd,cTip,nOpcao,lShowMsg)
Local cTipIn := If(cTip = "T",STR0065,STR0066)
Local cChav8 := NGSEEKDIC('SIX','STF8',1,'CHAVE')
Local cChav9 := NGSEEKDIC('SIX','STF9',1,'CHAVE')
Local lSeekF := .F.
Local cSeqST := If (NGVERIFY("STF"),'STF->TF_SEQRELA == M->TF_SEQRELA',;
                                    'STF->TF_SEQUENC == M->TF_SEQUENC')
Local cUniMa := STR0073 //"Dia"
Local aArea  := GetArea(),lRet := .T.
Local nTanINEN := TamSX3("TF_INENMAN")[1]
Local nTanTEEN := TamSX3("TF_TEENMAN")[1]

// Define de deve mostrar a mensagem de incosistencia, usada para manutençao controlada por "tempo / contador"
Default lShowMsg := .T.


If cInd = "8"
	If !Empty(cChav8)
		If NGIFDBSEEK("STF",M->TF_CODBEM+M->TF_SERVICO+Str(M->TF_INENMAN,nTanINEN),8)
			lSeekF := If(&cSeqST,.F.,.T.)
		EndIf
	EndIf
Else
	If !Empty(cChav9)
		If NGIFDBSEEK("STF",M->TF_CODBEM+M->TF_SERVICO+M->TF_UNENMAN+Str(M->TF_TEENMAN,nTanTEEN),9)
			lSeekF := If(&cSeqST,.F.,.T.)
			If STF->TF_UNENMAN = "D" // Unidade da manuntenção ( DIA ).
				If STF->TF_TEENMAN > 1
					cUniMa := STR0073+"s" //"Dia"
				EndIf
			ElseIf STF->TF_UNENMAN = "S" // Unidade da manuntenção ( SEMANA ).
				If STF->TF_TEENMAN > 1
					cUniMa := STR0074+"s" //"Semana"
				Else
					cUniMa := STR0074 //"Semana"
				EndIf
			ElseIf STF->TF_UNENMAN = "M" // Unidade da manuntenção ( MÊS ).
				If STF->TF_TEENMAN > 1
					cUniMa := STR0075+"es" //"Mês"
				Else
					cUniMa := STR0117 //"Mês"
				EndIf
			ElseIf STF->TF_UNENMAN = "H" // Unidade da manuntenção ( HORA ).
				If STF->TF_TEENMAN > 1
					cUniMa := STR0116+"s" //"Hora"
				Else
					cUniMa := STR0116 //"Hora"
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If AllTrim( Str( nOpcao ) ) $ "3/4"
	If GetNewPar("MV_NGCHKIN","S") = "S"
		If lSeekF
			If lShowMsg
				MsgStop(STR0067+" "+cTipIn+Chr(13)+Chr(10);
					+STR0068+Chr(13)+Chr(10)+Chr(13)+Chr(10);
					+STR0069+" "+STF->TF_CODBEM+Chr(13)+Chr(10);
					+STR0070+" "+STF->TF_SERVICO+Chr(13)+Chr(10);
					+STR0071+" "+If(NGVERIFY('STF'),STF->TF_SEQRELA,STR(STF->TF_SEQUENC,2))+Chr(13)+Chr(10);
					+STR0072+" "+If(cInd = "8",STR(STF->TF_INENMAN,nTanINEN),STR(STF->TF_TEENMAN,nTanTEEN));
					+If(cInd = "9"," "+cUniMa,+" "))
			EndIf
			lRet := .F.
		EndIf
	EndIf
EndIf

dbSetOrder(1)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG120TIR  ³ Autor ³ Inacio Luiz Kolling   ³ Data ³14/01/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra a unidade                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120TIR()

If M->TG_TIPOREG != aCOLS[n][nTIPORE]
	If M->TG_TIPOREG <> "P"
		If nUNIDAD > 0
			aCOLS[n][nUNIDAD] := "H"
		EndIf
	EndIf
EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGSUBSTIT  ³ Autor ³In cio Luiz Kolling   ³ Data ³16/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia substituicao das ordens de servico (SEQUENCIA) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NGSUBSTIT(vCodBServ,vSeq,cVSubst,cIncManut,cTmpManut)
Local cMensa := Space(1),cCoDSub := cVSubst
Local aAreaAntS := GetArea(), vVetSeq := {}
Local cDesSub := AllTrim( FWX3Titulo( 'TF_SUBSTIT' ) )
Local cDesSeq := AllTrim( FWX3Titulo( 'TF_SEQRELA' ) )

Default cIncManut := ""
Default cTmpManut := ""

cSeqRL  := If(Empty(cIncManut) .And. Empty(cTmpManut),M->TF_SEQRELA,vSeq)
cTipoAL := If(Empty(cIncManut) .And. Empty(cTmpManut),M->TF_TIPACOM,NGSEEK('STF',vCodBServ+cSeqRL,1,'TF_TIPACOM'))

If Empty(StrTran(cCoDSub,",","")) .Or. Empty(cCoDSub) //Se for vazio
	Return .T.
EndIf

While !Empty(cCodSub)
	nPosS := At(',',cCodSub)
   // Início.. Acerto de base.. Antes de retirar avaliar...
	cSubAux := Alltrim(cCodSub)
	If nPosS = 0 .And. Len(cSubAux) > 0
		cCodSub := If(Len(cSubAux) = 1,cSubAux+Space(2),cCodSub)
	EndIf
   // Fim.. Acerto

	If nPosS > 0 .Or. Len(cCodSub) = 3
		cSubCod := If(nPosS > 0,Substr(cCodSub,1,nPosS-1),cCodSub)
		If !Empty(cSubCod)
			If cSubCod = vSeq
				cMensa := cDesSub+"  "+cSubCod +" "+STR0085+" "+cDesSeq+" "+vSeq
				Exit
			EndIf
			If ( !Empty(cIncManut) .And. cIncManut == cSubCod ) .Or. ;
					!Empty(cTmpManut) .And. cTmpManut == cSubCod //Se esta sequencia está sendo incluida ou alterada, verifica apenas se esta inativa

				If M->TF_ATIVO == "N"
					cMensa := cDesSeq+" "+cSubCod+" - "+STR0098 //"Manutenção Inativa."
					Exit
				EndIf
			ElseIf !NGIFDBSEEK("STF",vCodBSerV+cSubCod,1)
				cMensa := cDesSub+" "+cSubCod+" "+STR0086
				Exit
			ElseIf STF->TF_ATIVO == "N"
				cMensa := cDesSeq+" "+cSubCod+" - "+STR0098 //"Manutenção Inativa."
				Exit
			Else
				If cTipoAl <> STF->TF_TIPACOM
					cMensa := STR0106+Chr(13)+Chr(13)+;
						NGRETTITULO( "TF_SEQRELA")+" "+cSeqRL+"  "+STR0107+" "+NGRETSX3BOX("TF_TIPACOM",cTipoAL)+Chr(13)+;
						NGRETTITULO( "TF_SUBSTIT")+"  "+cSubCod+"  "+STR0107+" "+NGRETSX3BOX("TF_TIPACOM",STF->TF_TIPACOM)
					Exit
				EndIf
			EndIf
		EndIf

		If Ascan(vVetSeq,{|x| x == cSubCod}) > 0
			cMensa := cDesSub+" "+cSubCod+" "+STR0087
			Exit
		Else
			aAdd(vVetSeq,cSubCod)
		EndIf

		If nPosS > 0
			cCodSub := Substr(cCodSub,nPosS+1,Len(cCodSub))
		Else
			Exit
		EndIf
	EndIf
End


If !Empty(cMensa)
   MsgInfo(cMensa,STR0043)
EndIf

RestArea(aAreaAntS)
Return If(Empty(cMensa),.T.,.F.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTA120DIC ³ Autor ³Marcos Wagner Junior  ³ Data ³30/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Altera X3_VALID e consulta SXB NGTPFC, para quem usa Frotas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNTA120DIC()

NGALTCONTEU("SX3","TF_SEQREPA",2,"X3_VALID",'NaoVazio() .And. NGSEEKCPO("TPF",ST9->T9_CODFAMI+ST9->T9_TIPMOD+M->TF_SERVICO+M->TF_SEQREPA,4) .And. CARREG180("M->TF_SEQREPA")')
NGALTCONTEU("SXB","NGTPFC601  ",1,"XB_CONTEM",'TPF->TPF_CODFAM = ST9->T9_CODFAMI .And. TPF->TPF_TIPMOD = ST9->T9_TIPMOD .And. TPF->TPF_SERVIC = M->TF_SERVICO')

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NG120QUANT ³ Autor ³In cio Luiz Kolling   ³ Data ³31/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia da quantidade / unidade                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Dicionario  TG_QUANTID / TG_UNIDADE                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120QUANT()
Local lRet := .T.
If ReadVar() = "M->TG_QUANTID"
	If !NaoVazio(M->TG_QUANTID) .Or. !Positivo(M->TG_QUANTID)
		lRet := .F.
	EndIf
	M->TG_TIPOREG := aCols[n,nTIPORE]
EndIf
If lRet
	If M->TG_TIPOREG <> "P"
		If ReadVar() = "M->TG_UNIDADE"
			If nQUANTI > 0
				M->TG_QUANTID := aCols[n,nQUANTI]
			EndIf
		Else
			If nUNIDAD > 0
				M->TG_UNIDADE := aCols[n,nUNIDAD]
			EndIf
		EndIf
		lRet := NGVALQUANT(M->TG_TIPOREG,M->TG_UNIDADE,M->TG_QUANTID)
	Else
		If lChkPR
			lRet := NGCHKLIMP(M->TF_CODBEM,aCols[n,nCODIGO],M->TG_QUANTID)
		EndIf
	EndIf
EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTA120WUNID³ Autor ³In cio Luiz Kolling   ³ Data ³03/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia do When do campo TG_UNIDADE                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Dicionario                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNTA120WUNID()
	//Segundo SS 014160, o campo unidade nao deve ser aberto
	Local lRet

	lRet := .F.

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTA120DPA ³ Autor ³Marcos Wagner Junior  ³ Data ³30/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Altera X3_VALID e consulta SXB NGTPFC, para quem usa Padrao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNTA120DPA()

	NGALTCONTEU("SX3","TF_SEQREPA",2,"X3_VALID",'Naovazio() .And. ExistCpo("TPF",ST9->T9_CODFAMI+M->TF_SERVICO+M->TF_SEQREPA) .And. CARREG180("M->TF_SEQREPA")')
	NGALTCONTEU("SXB","NGTPFC601  ",1,"XB_CONTEM",'TPF->TPF_CODFAM = ST9->T9_CODFAMI .And. TPF->TPF_SERVIC = M->TF_SERVICO')

Return .T.

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTA120IMP³ Autor ³Vitor Emanuel Batista  ³ Data ³31/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao das manutencoes do Bem                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1.aSTFImp - Imprime somente manutencao passada por parametro³±±
±±³          ³            {FILIAL,CODBEM,SERVICO,SEQRELA}        -Nao.Obrg³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNTA120IMP(aSTFImp)
	Local nRecSTF := STF->(RecNo())
	Local cFiltroOld
	dbSelectArea("STF")
	If aSTFImp != Nil
		Set Filter To STF->TF_FILIAL == aSTFImp[1] .And. STF->TF_CODBEM == aSTFImp[2] .And.;
			STF->TF_SERVICO == aSTFImp[3] .And. STF->TF_SEQRELA == aSTFImp[4]
	Else
		Set Filter To
	EndIf
	dbSetOrder(1)

	NGIFDBSEEK("ST9",STF->TF_CODBEM,1)
	MNTR605(STF->TF_CODBEM,ST9->T9_CCUSTO,ST9->T9_CENTRAB,ST9->T9_CODFAMI)

	dbSelectArea("STF")
	Set Filter To
	STF->(dbGoTo(nRecSTF))
Return .T.

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT120TOLE³ Autor ³Vitor Emanuel Batista  ³ Data ³14/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao When do campo TF_TOLERA                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNT120TOLE()
	Local lRet := .T.

	If !(M->TF_TIPACOM $ 'T/A') .Or. (M->TF_PERIODO $ "E")
		M->TF_TOLERA := 0
		lRet := .F.
	EndIf
Return lRet


/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT120TOCO³ Autor ³Vitor Emanuel Batista  ³ Data ³14/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao When do campo TF_TOLECON                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNT120TOCO()
	Local lRet := .T.

	If !(M->TF_TIPACOM $ 'C/A/P/F/S') .Or. (M->TF_PERIODO $ "E")
		M->TF_TOLECON := 0
		lRet := .F.
	EndIf
Return lRet

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT120WHEN³ Autor ³Felipe Nathan Welter   ³ Data ³ 18/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Habilita campos conforme periodo da manutencao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNT120WHEN(cVar)
	Local lRet := .T.

	If "TF_SUBSTIT" $ cVar
		lRet := !(M->TF_PERIODO $ "E")
		M->TF_SUBSTIT := If(!lRet,Space(Len(M->TF_SUBSTIT)),M->TF_SUBSTIT)
	ElseIf "TF_PLANEJA" $ cVar
		lRet := !(M->TF_PERIODO $ "E")
		M->TF_PLANEJA := If(!lRet,'N',M->TF_PLANEJA)
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG120COPY ³ Autor ³Vitor Emanuel Batista  ³ Data ³23/06/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Copia Manutencao que esta setado                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120COPY()
	Local nRecno := STF->(Recno())
	Local lOk    := .T.

	Private lCopia := .F.

	If xFilial("STF") != STF->TF_FILIAL .Or. (STF->(EoF()) .And. STF->(BoF()))
		Help(" ",1,"ARQVAZIO")
		lOk := .F.
	EndIf

	If lOk
		lCopia := .T.
		NG120FOLD("STF",nRecno,4)
		lCopia := .F.
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT120GEOS³ Autor ³Vitor Emanuel Batista  ³ Data ³30/06/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera O.S manual de acordo com a manutencao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Clique da Direita - MNTA120                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNT120GEOS()

	If INCLUI
		ShowHelpDlg(OemToAnsi(STR0050),{OemToAnsi(STR0090)},3,; //"Não é possivel incluir uma O.S Manual na inclusão de uma Manutenção."
		{OemToAnsi(STR0091)},2) //"Escolha outra opção no menu que não seja Incluir ou Copia."
		Return .F.
	Else
		If ALTERA
			If !MsgYesNo(OemToAnsi(STR0092)+CHR(13)+; //"Não foram gravadas as alterações feitas na Manutenção."
				OemToAnsi(STR0093),STR0050) //"Deseja gerar O.S Manual mesmo assim?"
				Return .F.
			EndIf
		EndIf
		NG410INC('STF',STF->(RECNO()),3)
	EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MNT120IMP ³ Autor ³ Marcos Wagner Junior ³ Data ³28/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao de Ordem de Servico                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNT120IMP()

	dbSelectArea("STF")
	Set Filter To

	U_IMP675(STJ->TJ_ORDEM,STJ->TJ_PLANO,.F.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT120ST5W
Validacao do When do campo T5_DESCRIC

@author Vitor Emanuel Batista
@since 19/10/2009

@sample MNT120ST5W()

@param
@return lRet, Lógico, Verifica se o campo será ou não fechado
/*/
//---------------------------------------------------------------------
User Function MNT120ST5W()

	Local lRet := .T.

	If NGUSATARPAD()

		If NGIFDBSEEK("TT9", GdFieldGet("T5_TAREFA", n), 1)
			lRet := .F.
		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT120T5F3
Altera a consulta generica do campo T5_TAREFA pelo WHEN
@type User Function

@author Vitor Emanuel Batista
@since 19/10/2009

@param
@return .T.
@todo Remover na versão 12.1.29
/*/
//---------------------------------------------------------------------
User Function MNT120T5F3()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT120DET5³ Autor ³Vitor Emanuel Batista  ³ Data ³19/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida alteracao ou exclusao da Tarefa da Manutencao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNT120AET5(nX)
Default nX := n
If ALTERA .And. !aTail(aCols[nx])
	Return NGINTEGST5(M->TF_CODBEM,M->TF_SERVICO,M->TF_SEQRELA,aCols[nX][nTAREFA])
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NG120F11 ³ Autor ³Denis Hyroshi de Souza ³ Data ³16/02/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra tela de gerenciamento das aglutinacoes              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NG120F11( cTF_CODBEM , cTF_SERVICO , nOPCAO , lChamCpo )
Local nOpc    := If(ValType(nOPCAO)=="N",nOPCAO,2)
Local lVisual := .T.
Local aArea   := GetArea()
Local aAreaTF := STF->(GetArea())
Local lRet    := .F.
Local nX, nY
Local bKeyF11 := SetKey(VK_F11)
Local cUso := ""
Local cValid := ""
Local cF3 := ""
Local cContext := ""

dbSelectArea("STF")
nRecLSTF := Recno()
Default lChamCpo := .F. //Indica se foi chamado pela validacao do campo TF_ATIVO

SetKey(VK_F11,Nil)

Private cIncMan12 := "" //Indica a sequencia que está sendo incluida
Private cTmpMan12 := "" //Indica a sequencia que está sendo alterada
Private aCoBrw5 := {}
Private aHoBrw5 := {}
Private oBrw5

If (nOpc == 3 .Or. nOpc == 4)
	lVisual := .F.
	If nOpc == 3
		cIncMan12 := M->TF_SEQRELA
	Else
		cTmpMan12 := M->TF_SEQRELA
	EndIf
EndIf

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("TF_SEQRELA")
cUso := Posicione("SX3",2,"TF_SEQRELA","X3_USADO")
cValid := Posicione("SX3",2,"TF_SEQRELA","X3_VALID")
cF3 := Posicione("SX3",2,"TF_SEQRELA","X3_F3")
cContext := Posicione("SX3",2,"TF_SEQRELA","X3_CONTEXT")
aAdd(aHoBrw5,{Trim(X3TITULO()),"TF_SEQRELA", X3Picture("TF_SEQRELA"), TamSX3("TF_SEQRELA")[1], TamSX3("TF_SEQRELA")[2], cValid, X3Uso(cUso), TamSX3("TF_SEQRELA")[3], cF3, cContext})
DbSeek("TF_NOMEMAN")
cUso := Posicione("SX3",2,"TF_NOMEMAN","X3_USADO")
cValid := Posicione("SX3",2,"TF_NOMEMAN","X3_VALID")
cF3 := Posicione("SX3",2,"TF_NOMEMAN","X3_F3")
cContext := Posicione("SX3",2,"TF_NOMEMAN","X3_CONTEXT")
aAdd(aHoBrw5,{Trim(X3TITULO()),"TF_NOMEMAN", X3Picture("TF_NOMEMAN"), TamSX3("TF_NOMEMAN")[1], TamSX3("TF_NOMEMAN")[2], cValid, X3Uso(cUso), TamSX3("TF_NOMEMAN")[3], cF3, cContext})
DbSeek("TF_SUBSTIT")
cUso := Posicione("SX3",2,"TF_SUBSTIT","X3_USADO")
cValid := Posicione("SX3",2,"TF_SUBSTIT","X3_VALID")
cF3 := Posicione("SX3",2,"TF_SUBSTIT","X3_F3")
cContext := Posicione("SX3",2,"TF_SUBSTIT","X3_CONTEXT")
aAdd(aHoBrw5,{Trim(X3TITULO()),"TF_SUBSTIT", X3Picture("TF_SUBSTIT"), TamSX3("TF_SUBSTIT")[1], TamSX3("TF_SUBSTIT")[2], cValid, X3Uso(cUso), TamSX3("TF_SUBSTIT")[3], cF3, cContext})

If Type("aVetorF11") == "A" .And. Len(aVetorF11) > 0
	aCoBrw5 := aClone(aVetorF11)
Else
	NGIFDBSEEK("STF",cTF_CODBEM+cTF_SERVICO,1)
	While !EoF() .And. xFilial("STF")+cTF_CODBEM+cTF_SERVICO == STF->(TF_FILIAL+TF_CODBEM+TF_SERVICO)
		aAdd( aCoBrw5 , { STF->TF_SEQRELA , Substr(STF->TF_NOMEMAN,1,40) , STF->TF_SUBSTIT , If(STF->TF_ATIVO=="N",.T.,.F.) } )
		dbSkip()
	End While
EndIf
If !Empty(M->TF_SEQRELA)
	nPosicao := aScan(aCoBrw5,{|x| x[1] == M->TF_SEQRELA })
	If nPosicao == 0
		aAdd( aCoBrw5 , { M->TF_SEQRELA , Substr(M->TF_NOMEMAN,1,40) , M->TF_SUBSTIT , If(M->TF_ATIVO=="N",.T.,.F.) } )
	Else
		aCoBrw5[nPosicao,2] := Substr(M->TF_NOMEMAN,1,40)
		aCoBrw5[nPosicao,3] := M->TF_SUBSTIT
		aCoBrw5[nPosicao,4] := If(M->TF_ATIVO=="N",.T.,.F.)
	EndIf
EndIf

aSort(aCoBrw5,,,{|x,y| x[1] < y[1] })

If lChamCpo .And. M->TF_ATIVO == "N"
	//Carrega as Sequencias que a MNT Inativa substitui, para repassar para as que substituem a Inativa
	aKill    := MNTSepSeq(M->TF_SUBSTIT)
	aKillIna := {}
	For nX := 1 To Len(aKill)
		If nX <= 3
			aAdd(aKillIna , PadR(Alltrim(aKill[nX]),3) )
		EndIf
	Next nX

	//Verifica quem substitui a MNT Inativa e retira do campo TF_SUBSTIT
	For nX := 1 To Len(aCoBrw5)
		If M->TF_SEQRELA <> aCoBrw5[nX,1]
			aKill := MNTSepSeq(aCoBrw5[nX,3])
			lInat := .F.
			For nY := 1 To Len(aKill)
				If PadR(Alltrim(aKill[nY]),3) == M->TF_SEQRELA
					aKill[nY] := Space(3)
					lInat := .T.
				EndIf
			Next nY
			If lInat
				nContA := 0
				cKill  := "   ,   ,   "
				For nY := 1 To Len(aKill)
					If !Empty(aKill[nY])
						nContA++
						aKill[nY] := PadR(Alltrim(aKill[nY]),3)
						If nContA == 1
							cKill := PadR(Alltrim(aKill[nY]),3) + Substr(cKill,4,8)
						ElseIf nContA == 2
							cKill := Substr(cKill,1,4) + PadR(Alltrim(aKill[nY]),3) + Substr(cKill,8,4)
						ElseIf nContA == 3
							cKill := Substr(cKill,1,8) + PadR(Alltrim(aKill[nY]),3)
						EndIf
					EndIf
				Next nY
				If nContA < 3
					For nY := 1 To Len(aKillIna)
						If !Empty(aKillIna[nY]) .And. aScan(aKill,{|x| x == aKillIna[nY] }) == 0
							nContA++
							If nContA == 1
								cKill := PadR(Alltrim(aKillIna[nY]),3) + Substr(cKill,4,8)
							ElseIf nContA == 2
								cKill := Substr(cKill,1,4) + PadR(Alltrim(aKillIna[nY]),3) + Substr(cKill,8,4)
							ElseIf nContA == 3
								cKill := Substr(cKill,1,8) + PadR(Alltrim(aKillIna[nY]),3)
							EndIf
						EndIf
					Next nY
				EndIf

				// aCoBrw5[nX,3] := cKill
				nPosS := At(aCoBrw5[nX,1],cKill)
				If nPosS > 0
					If nPosS = 1
						cSubS := SubS(cKill,nPosS+4,Len(cKill))
					Else
						cSubS := SubS(cKill,1,nPosS-1)+SubS(cKill,nPosS+4,Len(cKill))
					EndIf
					aCoBrw5[nX,3]  := cSubS
				Else
					aCoBrw5[nX,3] := cKill
				EndIf

			EndIf
		EndIf
	Next nX
EndIf

If Len(aCoBrw5) == 0
	MsgInfo(STR0099,STR0100) //"Não existe nenhuma Manutenção para este Bem + Serviço."#"Atenção"
	SetKey(VK_F11,bKeyF11)
	RestArea(aAreaTF)
	RestArea(aArea)
Return .F.
EndIf

dbSelectArea("STF")
dbGoTo(nRecLSTF)
cCodiBem := STF->TF_CODBEM
cCodiSer := STF->TF_SERVICO
cNomeBem := NGSEEK("ST9",STF->TF_CODBEM,1,"ST9->T9_NOME")
cNomeSer := NGSEEK("ST4",STF->TF_SERVICO,1,"ST4->T4_NOME")
opcaoZZ  := 0

DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0101) from 0,0 To 34,75 ; //"Manutenções do Bem e Serviço - Tabela de Substituição de O.S."
	of oMainwnd COLOR CLR_BLACK,CLR_WHITE

	oDlg1:lEscClose := .T.

    @ 16,008 Say OemToAnsi(STR0102) Of oDlg1 Pixel //"Bem"
    @ 16,040 MsGet cCodiBem Size 060,5 Of oDlg1 When .F. Pixel
    @ 16,100 MsGet cNomeBem Size 190,5 Of oDlg1 When .F. Pixel

    @ 27,008 Say OemToAnsi(STR0103) Of oDlg1 Pixel //"Serviço"
    @ 27,040 MsGet cCodiSer Size 060,5 Of oDlg1 When .F. Pixel
    @ 27,100 MsGet cNomeSer Size 190,5 Of oDlg1 When .F. Pixel

	If lVisual
       @ 040,08 SAY STR0104 OF oDlg1 Pixel //"Visualize a tabela de substituição de O.S."
	Else
       @ 040,08 SAY STR0105 OF oDlg1 Pixel //"Configure a tabela de substituição de O.S."
	EndIf
    oBrw5 := MsNewGetDados():New(050,08,233,290,IIF(lVisual,0,GD_UPDATE),;
								{|| .T. },{|| .T. },,,,9999,,,,oDlg1,aHoBrw5,aCoBrw5)
	oBrw5:aInfo[1][5] := "V" //Desativando edição do campo Seqrela
	oBrw5:aInfo[2][5] := "V" //Desativando edição do campo Nome
	oBrw5:aInfo[3][5] := "A" //Ativando edição do campo Substituicao
Activate MsDialog oDLG1 On Init EnchoiceBar(oDLG1,{|| opcaoZZ := 1,If(!MNT120ACOBR(),opcaoZZ  := 0,oDLG1:End())},{||oDLG1:End()}) CENTERED

M->TF_SEQRELA := If(nOpc == 3,cIncMan12,cTmpMan12)
If opcaoZZ == 1 .And. !lVisual
	aVetorF11 := aClone(aCoBrw5)
	nPosicao := aScan(aCoBrw5,{|x| x[1] == M->TF_SEQRELA })
	If nPosicao > 0
		M->TF_SUBSTIT := aCoBrw5[nPosicao,3]
	EndIf
EndIf

SetKey(VK_F11,bKeyF11)
RestArea(aAreaTF)
RestArea(aArea)
Return If( opcaoZZ == 1, .T. , .F. )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT120SUBF ³ Autor ³In cio Luiz Kolling   ³ Data ³14/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia substituicao das ordens de servico (SEQUENCIA) ³±±
±±³          ³por tipo de acompanhamento                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNT120SUBF()
Local lRetL := .T.,nFl := 0, cMensa := Space(1),aAreaTF := STF->(GetArea())
Local cChav := STF->TF_CODBEM+STF->TF_SERVICO

For nFl := 1 To Len(aCoBrw5)
	cCoDSub := aCoBrw5[nFl,3]
	If !Empty(StrTran(cCoDSub,",",""))
		cSeqBrw := aCoBrw5[nFl,1]
		NGIFDBSEEK("STF",cChav+cSeqBrw,1)
		cTipAcom := STF->TF_TIPACOM
		While !Empty(cCodSub) .And. lRetL
			cMensa := Space(1)
			nPosS := At(',',cCodSub)
			If nPosS > 0 .Or. Len(cCodSub) = 3
				cSubCod := If(nPosS > 0,Substr(cCodSub,1,nPosS-1),cCodSub)
				If !Empty(cSubCod)
					If !NGIFDBSEEK("STF",cChav+cSubCod,1)
						cMensa := NGRETTITULO("TF_SUBSTIT")+" "+cSubCod+" "+STR0086
					Else
						If cTipAcom <> STF->TF_TIPACOM
							cMensa := STR0106+Chr(13)+Chr(13)+;
								NGRETTITULO( "TF_SEQRELA")+" "+cSeqBrw+"  "+STR0107+" "+NGRETSX3BOX("TF_TIPACOM",cTipAcom)+Chr(13)+;
								NGRETTITULO( "TF_SUBSTIT")+"  "+cSubCod+"  "+STR0107+" "+NGRETSX3BOX("TF_TIPACOM",STF->TF_TIPACOM)
						EndIf
					EndIf
				EndIf
			EndIf

			If !Empty(cMensa)
				lRetL := .F.
			Else
				If nPosS > 0
					cCodSub := Substr(cCodSub,nPosS+1,Len(cCodSub))
				Else
					Exit
				EndIf
			EndIf
		End
	EndIf
Next nFl

If !Empty(cMensa)
   MsgInfo(cMensa,STR0043)
EndIf
RestArea(aAreaTF)
Return lRetL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT120ACOBR³ Autor ³In cio Luiz Kolling   ³ Data ³23/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atribuicao e Consistencia substituicao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MNT120ACOBR()
aCoBrw5 := Aclone(oBrw5:aCols)
Return MNT120SUBF()

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldALLGet1 ³ Autor ³Marcos Wagner Junior  ³ Data ³11/02/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao da GetDados01                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function VldALLGet1(_lEntraSai)
	Local _lEmpty,nx

	If _lEntraSai
		ENTRAGET(1)
	EndIf

	_lEmpty := .F.
	If Len(aCols) == 1 .And. !aTail(aCols[1])
		If nDESCRI > 0
			If Empty(aCols[1][nTAREFA]) .And. Empty(aCols[1][nDESCRI])
				_lEmpty := .T.
			EndIf
		EndIf
	EndIf

	If !_lEmpty
		For nx:=1 To Len(aCols)
			If !aTail(aCols[nx])
				If !aCols[nx][Len(aCols[nx])]
					If nDESCRI > 0
						If Empty(aCols[nx][nTAREFA]) .Or. Empty(aCols[nx][nDESCRI])
							Help(" ",1,"OBRIGAT")
							aSVCOLS[1]   := aClone(oGET01:aCols)   //Não remover, utilizado no NGSAIGET
							aSVHEADER[1] := aClone(oGET01:aHeader) //Não remover, utilizado no NGSAIGET
							NGSAIGET(1)
							If nControl > 0
								ENTRAGET(nControl)
							EndIf
							Return .F.
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	EndIf

	If _lEntraSai
		aSVCOLS[1]   := aClone(oGET01:aCols)   //Não remover, utilizado no NGSAIGET
		aSVHEADER[1] := aClone(oGET01:aHeader) //Não remover, utilizado no NGSAIGET
		NGSAIGET(1)
	EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldALLGet2 ³ Autor ³Marcos Wagner Junior  ³ Data ³11/02/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao da GetDados02                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function VldALLGet2(_lEntraSai)
	Local _lEmpty,nx

	If _lEntraSai
		ENTRAGET(2)
	EndIf

	_lEmpty := .F.
	If Len(aCols) == 1 .And. !aTail(aCols[1])
		If Empty(aCols[1][nTARM]) .And. Empty(aCols[1][nDEPEND])
			_lEmpty := .T.
		EndIf
	EndIf

	If !_lEmpty
		For nx:=1 To Len(aCols)
			If !aTail(aCols[nx])
				If !aCols[nx][Len(aCols[nx])]
					If Empty(aCols[nx][nTARM]) .Or. Empty(aCols[nx][nDEPEND])
						Help(" ",1,"OBRIGAT")
						aSVCOLS[2]   := aClone(oGET02:aCols)   //Não remover, utilizado no NGSAIGET
						aSVHEADER[2] := aClone(oGET02:aHeader) //Não remover, utilizado no NGSAIGET
						NGSAIGET(2)
						If nControl > 0
							ENTRAGET(nControl)
						EndIf
						Return .F.
					EndIf
				EndIf
			EndIf
		Next
	EndIf



	If _lEntraSai
		aSVCOLS[2]   := aClone(oGET02:aCols)   //Não remover, utilizado no NGSAIGET
		aSVHEADER[2] := aClone(oGET02:aHeader) //Não remover, utilizado no NGSAIGET
		NGSAIGET(2)
	EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldALLGet3 ³ Autor ³Marcos Wagner Junior  ³ Data ³11/02/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao da GetDados03                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function VldALLGet3(_lEntraSai)

	Local _lEmpty,nx
	Local lRet    := .T.
	Local nPosTar := aScan( oGet01:aHeader, { |x| Trim( Upper( x[2] ) ) == 'T5_TAREFA' } )
	Local nPsTrIn := aScan( oGet03:aHeader, { |x| Trim( Upper( x[2] ) ) == 'TG_TAREFA' } )

	If _lEntraSai
		ENTRAGET(3)
	EndIf

	_lEmpty := .F.
	If Len(aCols) == 1  .And. !aTail(aCols[1])
		If nQUANTI > 0
			If Empty(aCols[1][nTARG]) .And. Empty(aCols[1][nTIPORE]) .And.;
					Empty(aCols[1][nCODIGO]) .And. Empty(aCols[1][nQUANTI]) .And. lOK

				_lEmpty := .T.
			EndIf
		EndIf
	EndIf

	If !_lEmpty

		For nx:=1 To Len(aCols)

			If !aTail(aCols[nx])

				If !aCols[nx][Len(aCols[nx])]

					// Valida se a tarefa relacionada ao insumo existe no folder de tarefas (oGet01)
					If aScan( oGet01:aCols, { |x| x[nPosTar] == aCols[nx,nPosTar] } ) == 0 .And.;
					          Trim( aCols[nx,nPosTar] ) != '0'

						// Atenção ## Existem tarefas relacionadas a insumos que não constam no folder destinado as tarefas da manutenção!
						Help( Nil, Nil, STR0050, Nil, STR0136, 1, 0 )
						lRet := .F.

					Else

						If nQUANTI > 0

							If Empty(aCols[nx][nTARG])  .Or. Empty(aCols[nx][nTIPORE]) .Or.;
									Empty(aCols[nx][nCODIGO]) .Or. Empty(aCols[nx][nQUANTI])

								Help(" ",1,"OBRIGAT")
								lRet := .F.

							Else

								If nQUANRE > 0

									If aCols[nx][nTIPORE] $ "F/E" .And. Empty(aCols[nx][nQUANRE])

										Help(" ",1,"QUANTRECUR")
										lRet := .F.

									EndIf

								Else

									If nDESTIN > 0

										If aCols[nx][nTIPORE] == "P" .And. Empty(aCols[nx][nDESTIN])

											Help(" ",1,"DESTINO")
											lRet := .F.

										EndIf

									Else

										If nDESTIN > 0

											If aCols[nx][nTIPORE] != "P" .And. !Empty(aCols[nx][nDESTIN])

												Help(" ",1,"NAODESTINO")
												lRet := .F.

											EndIf

										Else

											If aCols[nx][nTIPORE] == "P" .And. lChkPR

												If nQUANTI > 0

													If !NGCHKLIMP(M->TF_CODBEM,aCols[nx][nCODIGO],aCols[nx][nQUANTI])
														lRet := .F.
													EndIf

												EndIf

											EndIf

										EndIf

									EndIf

								EndIf

							EndIf

						EndIf

					EndIf

				EndIf

			EndIf

			If !lRet
				Exit
			EndIf

		Next nX

	EndIf

	If _lEntraSai
		aSVCOLS[3]   := aClone(oGET03:aCols)   //Não remover, utilizado no NGSAIGET
		aSVHEADER[3] := aClone(oGET03:aHeader) //Não remover, utilizado no NGSAIGET
		NGSAIGET(3)
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Proteus.doc} VldALLGet4
Validacao da GetDados04.
@type User Function

@author Alexandre Santos
@since  18/06/2019

@sample VldALLGet4( oGet:aCols, oGet:aHeader )

@param  aColEta  , Array   , Registros relacionados a etapas da manutenção
@param  aHeaEta  , Array   , Cabeçalho do getdados referente a etapas.
@param  [aColTar], Array   , Registros relacionados a Tarefas da manutenção
@param  [aHeaTar], Array   , Cabeçalho do getdados referente a Tarefas.
@param  cOrigin  , Caracter, Origem da chamada de validação.
@return Lógico   , Define se o processo foi executado com êxito.
/*/
//------------------------------------------------------------------------------------------------
User Function VldALLGet4( aColEta, aHeaEta, aColTar, aHeaTar, cOrigin )

	Local nIndex  := 0
	Local nPosTar := 0
	Local nPsTrEt := 0
	Local lRet    := .T.

	Default aColTar := oGet01:aCols
	Default aHeaTar := oGet01:aHeader

	If cOrigin == 'MNTA180'
		nPosTar := aScan( aHeaTar, { |x| Trim( Upper( x[2] ) ) == 'TP5_TAREFA' } )
		nPsTrEt := aScan( aHeaEta, { |x| Trim( Upper( x[2] ) ) == 'TPH_TAREFA' } )
	Else
		nPosTar := aScan( aHeaTar, { |x| Trim( Upper( x[2] ) ) == 'T5_TAREFA' } )
		nPsTrEt := aScan( aHeaEta, { |x| Trim( Upper( x[2] ) ) == 'TH_TAREFA' } )
	EndIf

	For nIndex := 1 to Len( aColEta )

		If !aColEta[nIndex, Len( aColEta[nIndex] )]

			// Valida se a tarefa relacionada ao insumo existe no folder de tarefas (oGet01)
			If aScan( aColTar, { |x| x[nPosTar] == aColEta[nIndex,nPsTrEt] } ) == 0 .And.;
			          !( Trim( aColEta[nIndex,nPsTrEt] ) == '0' .Or. Empty( aColEta[nIndex,nPsTrEt] ) )

				// Atenção ## Existem tarefas relacionadas a etapas que não constam no folder destinado as tarefas da manutenção!
				Help( Nil, Nil, STR0050, Nil, STR0137, 1, 0 )
				lRet := .F.

			EndIf

		EndIf

	Next nIndex

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NGDTULT   ºAutor  ³Taina A. Cardoso    º Data ³  03/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a data da ultima manutencao                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MNTA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VLDDTUTLM()

Local dDtUltCon

If M->TF_DTULTMA > DDATABASE
	CHKHelp("NG080DTINV")
	Return .F.
EndIf

If !Empty(M->TF_DTULTMA)
	If M->TF_TIPACOM == "S"
		dDtUltCon := TPE->TPE_DTULTA
	ElseIf ST9->T9_TEMCONT == "S" .And. M->TF_TIPACOM <> "T"
		dDtUltCon := ST9->T9_DTULTAC
	EndIf
	If !Empty(dDtUltCon) .And. M->TF_DTULTMA > dDtUltCon
		MsgStop(If(M->TF_TIPACOM == "S",STR0114,STR0113)+DTOC(dDtUltCon)+" .") //"A data da ultima manutenção não pode ser maior que a data do ultimo acompanhamento do contador "
		Return .F.
	EndIf
EndIf

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GRATARGEN ºAutor  ³Jackson Machado	  º Data ³  24/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³Funcao para gravação da tarefa generica                     º±±
±±º          ³Esta funcao sera chamada quando, na gravacao, forem         º±±
±±ºDesc.     ³encontrados insumo, dependencias ou etapas que contenham a  º±±
±±º          ³tarefa generica mas esta na esteja contida no folder de     º±±
±±º          ³tarefas                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MNTA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GRATARGEN()
Local aColsTar := oGET01:aCols
Local aColsDep := oGET02:aCols
Local aColsIns := oGET03:aCols
Local aColsEta := oGET04:aCols
Local lGraTar := .F.
If Empty(aColsTar[1][1])
	If aScan(aColsDep,{|x| AllTrim(x[1]) == "0"}) > 0
		lGraTar := .T.
	ElseIf aScan(aColsIns,{|x| AllTrim(x[1]) == "0"}) > 0
		lGraTar := .T.
	ElseIf aScan(aColsEta,{|x| AllTrim(x[1]) == "0"}) > 0
		lGraTar := .T.
	EndIf
EndIf

If lGraTar
	dbSelectArea("ST5")
	dbSetOrder(1)
	If !dbSeek(xFilial("ST5")+M->TF_CODBEM+M->TF_SERVICO+M->TF_SEQRELA+PadR("0",Len(ST5->T5_TAREFA)))
		RecLock("ST5",.T.)
		ST5->T5_FILIAL  := xFilial("ST5")
	   	ST5->T5_CODBEM  := M->TF_CODBEM
	   	ST5->T5_SERVICO := M->TF_SERVICO
	   	ST5->T5_SEQRELA := M->TF_SEQRELA
	   	ST5->T5_TAREFA  := PadR("0",Len(ST5->T5_TAREFA))
		ST5->T5_DESCRIC := NGSEEK("TT9",PadR("0",Len(ST5->T5_TAREFA)),1,"TT9_DESCRI")
		If NGCADICBASE("T5_ATIVA","A","ST5",.F.)
		   ST5->T5_ATIVA := "1"
		EndIf
		MsUnLock("ST5")
	EndIf
EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} NG120ALMOX
	Funcção que valida se o insumo da linha é do tipo produto e habilita a alteração do campo TG_LOCAL.
@author Cezar Augusto Padilha
@since 21/11/2012
@version P11
@return .T.
/*/
//---------------------------------------------------------------------
User Function NG120ALMOX()
Local nTipo := Ascan(aHEADER,{|x| TRIM(UPPER(x[2])) == "TG_TIPOREG"})
Local lRet := .F.

If nTipo > 0
	If aCols[n][nTipo] == "P"  .Or. aCols[n][nTipo] == "T"
		If(SuperGetMv("MV_NGMNTES",.F.,"N")="S",lRet := .T.,)
	EndIf
EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fVarTolCon
	Funcção que calcula a dias de tolerancia atraves da tolerancia do contador;
@author Guilherme Benkendorf

@since 05/04/13
@version P11
@return nDias
/*/
//---------------------------------------------------------------------
Static Function fVarTolCon()
	Local nDias
	Local nVarDia := If( Empty( NGSEEK("ST9", STF->TF_CODBEM, 1, "T9_VARDIA") ), 0, NGSEEK("ST9", STF->TF_CODBEM, 1, "T9_VARDIA"))
	Local nResto

	nDias	:=  STF->TF_TOLECON / nVarDia
	nIntei	:= NoRound( nDias, 0)
	nResto	:= If(nIntei < 0,nDias*-1,nDias) - If(nIntei < 0,nIntei*-1,nIntei)

	If nResto > 0
		nDias	:= nIntei + 1
	EndIf

Return nDias

//-----------------------------------------------------------
/*/{Protheus.doc} fFilterBrw
Filtra registros do browse

@author Lucas Guszak
@since 02/09/2014
@version MP11
@return cCondicao
/*/
//-----------------------------------------------------------
Static Function fFilterBrw( cFuncaoBrw )

	Local cCondicao := ''
	Local cCondTemp := ''

	If cFuncaoBrw == "MNTA120"
		If lMan
			cCondicao := "TF_FILIAL = '"+xFilial('STF')+"' And TF_TIPLUB <> 'S' "
		Else
			cCondicao := "TF_FILIAL = '"+xFilial('STF')+"' And TF_TIPLUB = 'S' "
		EndIf

		If ExistBlock("MNTA1205")
			cCondTemp	:= ExecBlock("MNTA1205",.F.,.F.)
			If ValType( cCondTemp ) == "C"
				cCondicao += cCondTemp
			EndIF
		EndIf

	ElseIf cFuncaoBrw == "MNTA120OP"

		cCondicao := 'STJ->TJ_TIPOOS == "B" .And. STJ->TJ_CODBEM == M->TF_CODBEM .And. '+;
		'STJ->TJ_SERVICO == M->TF_SERVICO .And. STJ->TJ_SEQRELA == M->TF_SEQRELA .And. '+;
		'STJ->TJ_FILIAL  == xFilial("STJ") .And. STJ->TJ_SITUACA == "L" .And. STJ->TJ_TERMINO == "N"'

	EndIf

Return cCondicao

//----------------------------------------------------------------
/*/{Protheus.doc} ChangeGet()
Realiza backup do aCols modificado e carrega novo aCols de acordo
com mudança de Aba.

@author Tainã Alberto Cardoso
@since	10/02/2015
@return Nil Nulo
/*/
//----------------------------------------------------------------
Static Function ChangeGet()

	Do Case
		Case oFolder:nOption == 2
			EntraGet(1)

		Case oFolder:nOption == 3
			EntraGet(2)

		Case oFolder:nOption == 4
			EntraGet(3)

		Case oFolder:nOption == 5
			EntraGet(4)
	EndCase

Return
//----------------------------------------------------------------
/*/{Protheus.doc} CheckCols()
Verifica se o aCols atual está de acordo com o que será validado
no linOk.

@author Tainã Alberto Cardoso
@since	10/02/2015
@return Nil lRet
/*/
//----------------------------------------------------------------
Static Function CheckCols()

	Local lRet := NG120ENCOK()

	If lRet
		Do Case
			Case oFolder:nOption == 2
				If ( lRet := NG120LINOK() )
					GRAVATAR(2)
					aSVCOLS[1] := aClone( oGet01:aCols )
				EndIf

			Case oFolder:nOption == 3
				If ( lRet := NG120LINO2() )
					aSVCOLS[2] := aClone( oGet02:aCols )
				EndIf

			Case oFolder:nOption == 4
				If !( lRet := NG120LINO3() )
					oGET03:Refresh()
				Else
					aSVCOLS[3] := aClone( oGet03:aCols )
					SetKey( VK_F4, Nil)
				EndIf

			Case oFolder:nOption == 5
				If !( lRet := VldALLGet4( oGet04:aCols, oGet04:aHeader, oGet01:aCols, oGet01:aHeader, 'MNTA120' ) )
					oGet04:Refresh()
				Else
					aSVCOLS[4] := aClone( oGet04:aCols )
				EndIf

		EndCase
	EndIf
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTVALBEM
Função que realiza a validação verificando se o Bem informado junto a
manutenção é 'Ativo' e se a data de inativação (baixa) é menor que a atual.
@type function

@author		Elynton Fellipe Bazzo
@since		12/01/2015

@sample MNTVALBEM( '0000' )

@param  cCode  , string, Código do bem.
@return boolean, Indica se será possível prosseguir, ou não.
/*/
//---------------------------------------------------------------------
User Function MNTVALBEM( cCode )

	Local lRet    := .T.

	Default cCode := M->TF_CODBEM

	dbSelectArea( 'ST9' )
	dbSetOrder( 01 )
	If dbSeek( xFilial( 'ST9' ) + cCode )

		Do Case

			Case ST9->T9_SITBEM == 'I'
				Help( '', 1, 'NGBEMINATI' )
				lRet := .F.

			Case ST9->T9_SITBEM == 'T'
				Help( '', 1, 'NGBEMTRANSF', , STR0127, 3, 1 ) // Este Bem foi transferido.
				lRet := .F.

			Case ST9->T9_SITMAN == 'I'
				Help( '', 1, 'NGMABEMINA' )
				lRet := .F.

		End Case

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Proteus.doc} MNTA120Tar
Realiza validação do campo T5_TAREFA, juntamente com o auto preenchimento do campo descrição.
@type User Function

@author Alexandre Santos
@since  18/06/2019

@sample MNTA120Tar( 'TAR01' )

@param  cCode  , Caracter, Código da tarefa.
@param  cAlias , Caracter, Tabela referente ao registro ( TP5 ou ST5 )
@return Lógico , Define se o processo foi realizado com êxito.
/*/
//------------------------------------------------------------------------------------------------
User Function MNTA120Tar( cCode, cAlias )

	Local nPosDsc := IIf( cAlias == 'ST5', GDFieldPos( 'T5_DESCRIC' ), GDFieldPos( 'TP5_DESCRI' ) )
	Local nPosTar := 0
	Local cOldDsc := Trim( aCols[n,nPosDsc] )
	Local cKey    := ''
	Local lRet    := .T.

	If cAlias == 'ST5'
		nPosTar := aScan( aHeader, {|x| AllTrim( Upper( x[2] ) ) == 'T5_TAREFA' } )
		cKey    := xFilial( 'ST5' ) + M->TF_CODBEM + M->TF_SERVICO + M->TF_SEQRELA + cCode
	Else
		nPosTar := aScan( aHeader, {|x| AllTrim( Upper( x[2] ) ) == 'TP5_TAREFA' } )
		cKey    := xFilial( 'TP5' ) + M->TPF_CODFAM + M->TPF_SERVIC + M->TPF_SEQREL + cCode
	EndIf

	If !NG120EXIST( cAlias ) .Or. !NGFOLDTAR( 'A', 'N' )

		If nPosDsc > 0
			aCols[n,nPosDsc] := cOldDsc
		EndIf
		lRet := .F.

	Else

		If nPosDsc > 0

			dbSelectArea( cAlias )
			dbSetOrder( 1 )
			If dbSeek( cKey )

				aCols[n,nPosDsc] := IIf( cAlias == 'ST5', ST5->T5_DESCRIC, TP5->TP5_DESCRI )

			ElseIf Trim( cCode ) == '0'

				nSize            := Len( aCols[n,nPosDsc] )
				aCols[n,nPosDsc] := Left( STR0013 + Space( nSize ), nSize ) // SEM ESPECIFICAÇÃO DE TAREFA

			Else

				aCols[n,nPosDsc] := NGNTARPADRA( cCode )

			EndIf

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fValMnt
Verifica se há O.S. aberta em alguma manutenção para o bem.

@author  Eduardo Mussi
@since   25/05/2020

@param   cCodeBem , Caracter, Código do bem
@param   cServSTF , Caracter, Código do serviço
@param   cSeqRlSTF, Caracter, Sequencia da manutenção

@return Lógico, define se o campo TF_DTULTIMA ficará aberto a alterações.
/*/
//-------------------------------------------------------------------
Static Function fValMnt( cCodeBem, cServSTF, cSeqRlSTF )

	Local cAliasSTF := GetNextAlias()
	Local lUseField := .T.
	Local cQuery    := '%'
	Local cQuery1   := ''
	Local lUseSTF   := SuperGetMv( 'MV_NG1SUBS', .F., '2' ) == '2'
	Local cFieldSub := IIf( lUseSTF, 'STF.TF_SUBSTIT', 'STJ.TJ_SUBSTIT' )
	Local cDataBase := AllTrim( TCGetDB() )

	If cDataBase == "ORACLE"
		cQuery1 += " instr( " + cFieldSub + ", RTRIM(" + ValToSQL( cSeqRlSTF ) + ") ) > 0 "
	ElseIf cDataBase == "POSTGRES"
		cQuery1 += " POSITION( RTRIM(" + ValToSQL( cSeqRlSTF ) + ") IN " + cFieldSub + " ) > 0 "
	Else
		cQuery1 += " CHARINDEX( RTRIM(" + ValToSQL( cSeqRlSTF ) + "), " + cFieldSub + " ) > 0 "
	Endif

	// Quando parametro MV_NG1SUBS é igual a 1, verifica na STF
	// buscando manutenções que possuem as informações da manutenção posicionada no browse.
	If lUseSTF
		cQuery += "	STJ.TJ_SEQRELA IN (
		cQuery += "	SELECT TF_SEQRELA
		cQuery += "		FROM " + RetSQLName( 'STF' ) + " STF"
		cQuery += "	WHERE STF.TF_FILIAL  = " + ValToSQL( xFilial( 'STF' ) )
		cQuery += "		  AND STF.TF_CODBEM  = STJ.TJ_CODBEM
		cQuery += "		  AND STF.TF_SERVICO = STJ.TJ_SERVICO
		cQuery += "       AND STF.D_E_L_E_T_ <> '*'
		cQuery += "       AND " + cQuery1 + " ) %"
	Else
		// Se for MV_NG1SUBS igual a 1 verifica a sequencia de substuitação na STJ.
		cQuery += cQuery1 + " %"
	EndIf

	BeginSql Alias cAliasSTF
		SELECT COUNT(TJ_ORDEM) AS REGISTROS
		   FROM %table:STJ% STJ
		WHERE   STJ.TJ_FILIAL  = %xFilial:STJ%
		  AND   STJ.TJ_TIPOOS  = 'B'
		  AND   STJ.TJ_CODBEM  = %exp:cCodeBem%
		  AND   STJ.TJ_SERVICO = %exp:cServSTF%
		  AND   STJ.%NotDel%
		  AND ( STJ.TJ_SEQRELA = %exp:cSeqRlSTF% OR %exp:cQuery% )
	EndSQL

	lUseField := (cAliasSTF)->REGISTROS == 0

	(cAliasSTF)->( dbCloseArea( ) )

Return lUseField

//--------------------------------------------------------------------------------------------------
/*/{Proteus.doc} fManutPad
Realiza busca e posicionamento na manutenção padrão (TPF) correspondente.

@type function

@author Wexlei Silveira
@since  11/07/2020

@param  cModelo , Caracter, Código do Tipo Modelo a ser utilizado na pesquisa.
@param  cCompl  , Caracter, Chave de pesquisa complementar, utilizada após o Tipo Modelo.
@param nIdTPF   , Numerico, Índice da TPF a ser utilizado na pesquisa.
                            Utilizado apenas em releases anteriores à 12.1.33.

@return lManutPad, Define se a manutenção padrão foi encontrada.
/*/
//------------------------------------------------------------------------------------------------
Static Function fManutPad( cModelo, cCompl, nIdTPF )

	Local lManutPad := .F.

	// A partir do release 12.1.33, o tipo modelo será utilizado
	// na busca de manutenção padrão, mesmo em ambientes sem Gestão de Frotas
	If lRel12133

		// Busca e posiciona na manutenção padrão padrão (TPF)
		// Índice 4: TPF_FILIAL+TPF_CODFAM+TPF_TIPMOD+TPF_SERVIC+TPF_SEQREL
		lManutPad := MNTSeekPad( 'TPF', 4, ST9->T9_CODFAMI, cModelo, cCompl )

	Else

		// Para releases anteriores, o tipo modelo somente é utilizado,
		// na busca de manutenção padrão, para ambientes com Gestão de Frotas
		lManutPad := NGIFDBSEEK( "TPF", ST9->T9_CODFAMI + cModelo + cCompl, nIdTPF )

	EndIf

Return lManutPad
