#INCLUDE "Protheus.ch"
#INCLUDE "FwMBrowse.CH"
#INCLUDE "MNTA291.ch"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE __OPC_TQB__ 1
#DEFINE __OPC_ST1__ 2
#DEFINE __OPC_TQB2__ 3

#DEFINE __POS_OBJ__ 1
#DEFINE __POS_FIELDS__ 2
#DEFINE __POS_DBF__ 3
#DEFINE __POS_IND__ 4
#DEFINE __POS_VIR__ 5
#DEFINE __POS_ARQ__ 6
#DEFINE __POS_ALIAS__ 7
#DEFINE __POS_LEG__ 8
#DEFINE __POS_ALIDIC__ 9
#DEFINE __POS_FILTER__ 10
#DEFINE __POS_DESIND__ 11
#DEFINE __POS_LEG2__ 12
#DEFINE __POS_LEG3__ 13

#DEFINE __LEN_MARK__ 3
#DEFINE __LEN_PROP__ 13

#DEFINE __POS_FILSS__ 1
#DEFINE __POS_CODSS__ 2

#DEFINE __LEN_LISTA__ 2

//Variaveis referentes ao funcionario logado
Static __cCodFun := Space(6)
Static __aEqpRes := {}

Static __cOldFil := cFilAnt
Static __cFilPos := cFilAnt

// Variáveis de Chamada de Função
Static __cCallAtend := "ATENDIMENTO" // Chamada pela rotina de Atendimento de S.S.
Static __cCallDistr := "DISTRIBUICAO" // Chamada pela rotina de Distribuição de S.S.

// Variáveis de Totalizadores
Static __aTotal     := Array(3)
Static __nTotSS     := 1
Static __nTotEquipe := 2
Static __nTotCarga  := 3

// Variáveis de Botões manipuláveis
Static __aBtns291 := {}

// Variáveis de componentes para quando o atendente é responsável por uma equipe
Static __aResp291 := Array(3)
Static __nRespAte := 1
Static __nRespEqu := 2
Static __nRespMsg := 3

// Variáveis de Filtro
Static __cFilt291 := ""
Static __nAtEq291 := 1

// Variável do Índice principal das Solicitações de Serviço
Static __nIndTQB := 0

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA291
Tela de Atendimento de Solicitacoes de Servico

@author Roger Rodrigues
@since 30/04/2011
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA291(cParFilial, cParSolici, cParTipoSS, cParCodBem)
	//Guarda variaveis padrao
	Local aNGBEGINPRM := NGBEGINPRM()
	Local i

	//Variaveis da tela
	Local oDlg291
	Local lOk := .T.
	Local cTitulo := STR0001 //"Atendimento de Solicitações de Serviço"
	Local bGravaEnc := {||}
	Local aButtons  := {}
	Local aArrGet := {}
	Local cTitAtend := ""
	Local aLegBrwSS := {2,3,4} //Mostra legendas de criticidade, prioridade e terceiros

	//Variaveis do combo
	Local oGetSearch, oCBoxSearch, oBtnSearch, cCombo, cGetSearch := Space(100)

	//Variaveis de tamanho de tela e objetos
	Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}

	//Variaveis do MarkBrowse
	Local cMarca   := GetMark()

	//Objetos principais
	Local oPanelTop
	Local oSplitVert, oPanelLeft, oPanelRight
	Local oFont16 := TFont():New("Arial",,-16,,.T.)

	//Botoes para esconder paineis
	Local oHideLeft, oHideRight, oHideTop, oHideBottom

	//Parte Esquerda
	Local oPanelT1, oPanelLBtn, oPanelMark, oPanelPesq

	//Parte Direita
	Local oSplitHor, oPanelRUp, oPanelRDown, oPanelT2, oPanelEnc, oPanelR1Btn

	//Follow-up
	Local oPanelD1, oPanelR2Btn, oPanelFol

	//Botoes da tela
	Local oBtnRepSS, oBtnFecha, oBtnCancel
	Local oBtnFil, oBtnImp, oBtnHis, oBtnLeg, oBtnOS, oBtnCarga
	Local oBtnQuest, oBtnVis, oBtnUser, oBtnTransf, oBtnDet
	Local bWhenBtn := Nil

	// Objetos da Troca de visão entre S.S.'s do Atendente e da Equipe (somente para quando o funcionário é responsável pela equipe)
	Local oPanelAtEq

	// Objetos do Totalizador
	Local oPanelTot

	// Defaults
	Default cParFilial := ""
	Default cParSolici := ""
	Default cParTipoSS := ""
	Default cParCodBem := ""

	//Objetos que serao desabilitados
	Private oPanelLCont, oPanelRDCont
	Private oBtnAltSS, oBtnConf, oBtnCanc

	//Titulo da tela
	Private cCadastro := cTitulo

	//Variaveis da Enchoice
	Private oEncSS
	Private aTela := {}
	Private aGets := {}
	Private aRotina := {{"", "PesqBrw", 0, 1},;
	{"", "NGCAD01", 0, 2},;
	{"", "NGCAD01", 0, 3},;
	{"", "NGCAD01", 0, 4},;
	{"", "NGCAD01", 0, 5,3}}

	//Variaveis da GetDados de Follow-up
	Private oGet291Fol

	Private aObj291 := Array(__LEN_MARK__,__LEN_PROP__)

	// Variável das cores da tela
	Private aNGColor := aClone( NGCOLOR("10") )

	//Variável que troca o F3 se chamado através da rotina MNTA291
	Private aTrocaF3 := {}

	//Verifica se o update de facilities foi aplicado
	If !FindFunction("MNTUPDFAC") .or. !MNTUPDFAC()
		NGRETURNPRM(aNGBEGINPRM)
		Return .F.
	Endif

	If !fRetCodUsu()
		Return .F.
	Endif

	SetVisual(.T.)//Utilizado caso exista algum Ini. Browse

	//Cria estrutura de arquivo temporario e markbrowse
	fCreateTRB(__OPC_TQB__)

	// Define o Filtro pricipal da TQB da rotina MNTA291
	__cFilt291 := ""
	If !Empty(cParFilial)
		cParFilial := PADR(cParFilial, TAMSX3("TQB_FILIAL")[1], " ")
		__cFilt291 += If(!Empty(__cFilt291), " .And. ", "") + "AllTrim(TQB->TQB_FILIAL) == '" + AllTrim(cParFilial) + "' "
	EndIf
	If !Empty(cParSolici)
		cParSolici := PADR(cParSolici, TAMSX3("TQB_SOLICI")[1], " ")
		__cFilt291 += If(!Empty(__cFilt291), " .And. ", "") + "AllTrim(TQB->TQB_SOLICI) == '" + AllTrim(cParSolici) + "' "
	EndIf
	If !Empty(cParTipoSS)
		cParTipoSS := PADR(cParTipoSS, TAMSX3("TQB_TIPOSS")[1], " ")
		__cFilt291 += If(!Empty(__cFilt291), " .And. ", "") + "AllTrim(TQB->TQB_TIPOSS) == '" + AllTrim(cParTipoSS) + "' "
	EndIf
	If !Empty(cParCodBem)
		cParCodBem := PADR(cParCodBem, TAMSX3("TQB_CODBEM")[1], " ")
		__cFilt291 += If(!Empty(__cFilt291), " .And. ", "") + "AllTrim(TQB->TQB_CODBEM) == '" + AllTrim(cParCodBem) + "' "
	EndIf

	//Carrega Arquivo temporario
	Processa({|| fLoadTRB(__OPC_TQB__,,__cCodFun)},STR0002,STR0003) //"Aguarde..." ## "Processando Solicitações..."

	//Definicao de tamanho de tela e objetos
	aSize := MsAdvSize(,.f.,430)
	Aadd(aObjects,{030,030,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.t.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	Define MsDialog oDlg291 Title OemToAnsi(cTitulo) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel
	oDlg291:lMaximized := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo do Atentende                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelTop := TPanel():New(,,,oSplitHor,,,,aNGColor[1],aNGColor[2],,015, .F., .F. )
	oPanelTop:Align := CONTROL_ALIGN_TOP

	cTitAtend := "Atendente: "+Trim(__cCodFun)+" - "+Trim(NGSEEK("ST1",__cCodFun,1,"ST1->T1_NOME"))
	@ 003,013 Say cTitAtend Of oPanelTop Color aNGColor[1] Pixel Font oFont16

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Estrutura da Tela            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSplitVert := TSplitter():New(01,01,oDlg291,10,10)
	oSplitVert:SetOrient(0)
	oSplitVert:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Parte Esquerda - Browse SS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelLeft := TPanel():New(0,0,,oSplitVert,,,,,,10,10,.F.,.F.)
	oPanelLeft:nWidth := (aSize[5]/2)
	oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelLCont := TPanel():New(0,0,,oPanelLeft,,,,,,10,10,.F.,.F.)
	oPanelLCont:nWidth := (aSize[5]/2)
	oPanelLCont:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelLCont:CoorsUpdate()

	oPanelT1:=TPanel():New(00,00,,oPanelLCont,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPanelT1:nHeight := 25
	oPanelT1:Align := CONTROL_ALIGN_TOP

	@ 003,013 Say OemToAnsi(STR0004) Of oPanelT1 Color aNGColor[1] Pixel //"Solicitações"

	oPanelLBtn:=TPanel():New(00,00,,oPanelLCont,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPanelLBtn:Align := CONTROL_ALIGN_LEFT

	__aBtns291 := {} // Array com os botões manipuláveis {Função do botão para identificar qual é o botão, Objeto do botão}

	oBtnFil  := TBtnBmp():NewBar("ng_ico_filtro","ng_ico_filtro",,,,{|| fSetFilter(__OPC_TQB__,__cCodFun,__aEqpRes)},,oPanelLBtn,,,STR0005,,,,,"") //"Filtro"
	oBtnFil:Align  := CONTROL_ALIGN_TOP

	oBtnImp  := TBtnBmp():NewBar("ng_ico_imp","ng_ico_imp",,,,{|| fImpSS()},,oPanelLBtn,,,STR0006,,,,,"") //"Imprimir"
	oBtnImp:Align  := CONTROL_ALIGN_TOP

	oBtnHis  := TBtnBmp():NewBar("ng_ico_hist","ng_ico_hist",,,,;
	{|| MNT296HIST(Substr((aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_TIPOSS,1,1),(aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_CODBEM)};
	,,oPanelLBtn,,,STR0007,,,,,"") //"Histórico"
	oBtnHis:Align  := CONTROL_ALIGN_TOP

	oBtnRepSS  := TBtnBmp():NewBar("ng_ico_ss","ng_ico_ss",,,,{|| A291RepSS((aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_FILIAL,(aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI,__cCodFun,__cOldFil)},,oPanelLBtn,,,STR0088,,,,,"") //"Reporte de Horas"
	oBtnRepSS:Align  := CONTROL_ALIGN_TOP
	aAdd(__aBtns291, {"A291RepSS", oBtnRepSS})

	oBtnFecha  := TBtnBmp():NewBar("ng_ico_finss","ng_ico_finss",,,,{|| A291Fecha((aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_FILIAL,(aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI,__cCallAtend)},,oPanelLBtn,,,STR0009,,,,,"") //"Fechamento da S.S."
	oBtnFecha:Align  := CONTROL_ALIGN_TOP
	If !MNT280REST("TUA_FECHSS")
		oBtnFecha:Disable()
	Else
		aAdd(__aBtns291, {"A291Fecha", oBtnFecha})
	Endif

	oBtnCancel  := TBtnBmp():NewBar("ng_ico_excss","ng_ico_excss",,,,{|| A291Cancel((aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_FILIAL,(aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI,__cCallAtend)},,oPanelLBtn,,,STR0010,,,,,"") //"Cancelamento da S.S."
	oBtnCancel:Align  := CONTROL_ALIGN_TOP
	If !MNT280REST("TUA_CANCSS")
		oBtnCancel:Disable()
	Endif
	aAdd(__aBtns291, {"A291Cancel", oBtnCancel})

	oBtnOS  := TBtnBmp():NewBar("ng_ico_detalhesos","ng_ico_detalhesos",,,,{|| MNT291OS()},,oPanelLBtn,,,STR0011,,,,,"") //"Ordens de Serviço"
	oBtnOS:Align  := CONTROL_ALIGN_TOP
	aAdd(__aBtns291, {"MNT291OS", oBtnOS})

	If Len(__aEqpRes) > 0
		oBtnCarga  := TBtnBmp():NewBar("ng_ico_atendimento","ng_ico_atendimento",,,,{|| A291CARGA(__cOldFil,__aEqpRes),Eval(aObj291[__OPC_TQB__][__POS_OBJ__]:bChange)},,oPanelLBtn,,,STR0012,,,,,"") //"Carga da Equipe"
		oBtnCarga:Align  := CONTROL_ALIGN_TOP
	Endif

	oBtnTransf  := TBtnBmp():NewBar("ng_os_transf","ng_os_transf",,,,{|| fTransfSS((aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_FILIAL,(aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI,,,,,__cCallAtend)},,oPanelLBtn,,,STR0013,,,,,"") //"Transferir Atendimento"
	oBtnTransf:Align  := CONTROL_ALIGN_TOP
	If !MNT280REST("TUA_TRANSS")
		oBtnTransf:Disable()
	Endif

	oBtnLeg  := TBtnBmp():NewBar("ng_ico_lgndos","ng_ico_lgndos",,,,{|| A291LEGEND(1,,,aLegBrwSS)},,oPanelLBtn,,,STR0014,,,,,"") //"Legenda"
	oBtnLeg:Align	:= CONTROL_ALIGN_TOP

	oPanelMark := TPanel():New(0,0,,oPanelLCont,,,,,,10,10,.F.,.F.)
	oPanelMark:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria Panel com opcoes de pesquisa no MsSelect³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelPesq := TPanel():New(0,0,,oPanelMark,,,,,CLR_WHITE,0,15,.f.,.f.)
	oPanelPesq:Align := CONTROL_ALIGN_TOP

	oCBoxSearch := TComboBox():New(02,02,{|u| If(PCount()>0,cCombo:=u,cCombo)},aObj291[__OPC_TQB__][__POS_DESIND__],100,20,oPanelPesq,,;
	{|| fSeekReg(__OPC_TQB__,oCBoxSearch:nAt,@cGetSearch,.F.)},,,,.T.,,,,,,,,,"cCombo")
	oGetSearch  := TGet():New( 02,105,{|u| If(PCount()>0,cGetSearch:=u,cGetSearch)}, oPanelPesq,096,008,,,;
	0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cGetSearch,,,, )
	oBtnSearch  := TButton():New( 002, 202, STR0015,oPanelPesq,{|| fSeekReg(__OPC_TQB__,oCBoxSearch:nAt,Trim(cGetSearch))},; //"Buscar"
	35,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	oCBoxSearch:Select((aObj291[__OPC_TQB__][__POS_ALIAS__])->(IndexOrd()))

	aObj291[__OPC_TQB__][__POS_OBJ__] := TCBrowse():New(0,0,1500,1500,,,,oPanelMark,,,,,,,,,,,,,aObj291[__OPC_TQB__][__POS_ALIAS__],.T.,,,,.T.,.T.)

	aObj291[__OPC_TQB__][__POS_OBJ__]:Align := CONTROL_ALIGN_ALLCLIENT
	aObj291[__OPC_TQB__][__POS_OBJ__]:bChange := {|| fAtuEnc(__OPC_TQB__), fAtuBtns() }
	aObj291[__OPC_TQB__][__POS_OBJ__]:bLDblClick := {|| fMarkBrw(__OPC_TQB__,cMarca) }
	aObj291[__OPC_TQB__][__POS_OBJ__]:bHeaderClick := { |oObj,nPos| fMrkAll(__OPC_TQB__,nPos,cMarca)}

	//Adiciona Colunas
	//Marcacao
	aObj291[__OPC_TQB__][__POS_OBJ__]:AddColumn(TCColumn():New( " " , {|| fImgLeg(0,__OPC_TQB__) } ,,,,,,.T.,.F.,,,,.T.,))
	//Legenda Criticidade
	aObj291[__OPC_TQB__][__POS_OBJ__]:AddColumn(TCColumn():New( STR0016 , {|| fImgLeg(1,__OPC_TQB__) } ,,,,,30,.T.,.F.,,,,.T.,)) //"Criticidade"
	//Legenda Prioridade
	aObj291[__OPC_TQB__][__POS_OBJ__]:AddColumn(TCColumn():New( STR0017 , {|| fImgLeg(2,__OPC_TQB__) } ,,,,,30,.T.,.F.,,,,.T.,)) //"Prioridade"
	//Legenda Terceiros
	aObj291[__OPC_TQB__][__POS_OBJ__]:AddColumn(TCColumn():New( STR0018 , {|| fImgLeg(3,__OPC_TQB__) } ,,,,,20,.T.,.F.,,,,.T.,)) //"Terc."

	//Adiciona Colunas
	For i := 1 to Len(aObj291[__OPC_TQB__][__POS_FIELDS__])
		If aObj291[__OPC_TQB__][__POS_FIELDS__][i][1] != "OK"
			aObj291[__OPC_TQB__][__POS_OBJ__]:AddColumn( TCColumn():New(aObj291[__OPC_TQB__][__POS_FIELDS__][i][3],;
			&("{|| ('"+aObj291[__OPC_TQB__][__POS_ALIAS__]+"')->"+aObj291[__OPC_TQB__][__POS_FIELDS__][i][1]+" }"),;
			aObj291[__OPC_TQB__][__POS_FIELDS__][i][4],,,"LEFT",;
			If(aObj291[__OPC_TQB__][__POS_FIELDS__][i][2] <= 8,35,Nil),.F. ))
		Endif
	Next i

	// Painél de seleção entre S.S.'s do Atendente e da Equipe
	If Len(__aEqpRes) > 0
		oPanelAtEq := TPanel():New(0,0,,oPanelMark,,,,CLR_BLACK,CLR_WHITE,0,018,.f.,.f.)
		oPanelAtEq:Align := CONTROL_ALIGN_BOTTOM

		__aResp291[__nRespAte] := TBtnBmp2():New(02, 02, 030, 030, "ng_funcionario", , , , {|| fBrwAtEq(1) }, oPanelAtEq, OemToAnsi(STR0019), , .T.) //"Solicitações de Serviço do Atendente"
		__aResp291[__nRespEqu] := TBtnBmp2():New(02, 42, 030, 030, "ng_ico_oficina", , , , {|| fBrwAtEq(2) }, oPanelAtEq, OemToAnsi(STR0020), , .T.) //"Solicitações de Serviço da Equipe"
		__aResp291[__nRespMsg] := TSay():New(05, 42, {|| "" }, oPanelAtEq,,TFont():New(,,,,.T.),,,,.T.,CLR_BLACK,,200,20)

		// Inicializa botões
		fBrwAtEq(1, .T.)
	EndIf

	// Totalizador
	oPanelTot := TPanel():New(0,0,,oPanelLCont,,,,aNGColor[1],aNGColor[2],0,012,.f.,.f.)
	oPanelTot:Align := CONTROL_ALIGN_BOTTOM

	__aTotal[__nTotSS] := TSay():New(02, 12, {|| A296TotTRB(aObj291[__OPC_TQB__][__POS_ALIAS__], .T.) },oPanelTot,,TFont():New(,,,,.T.),,,,.T.,aNGColor[1],,200,20)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte dir.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideRight := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_right", , , , {|| fShowHide(1,oPanelRight,oHideRight)}, oPanelLeft, OemToAnsi(STR0021), , .T.) //"Expandir Browse"
	oHideRight:Align := CONTROL_ALIGN_RIGHT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Parte Direita                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelRight := TPanel():New(0,0,,oSplitVert,,,,,,10,10,.F.,.F.)
	oPanelRight:nWidth := (aSize[5]/2)
	oPanelRight:Align  := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte esq.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideLeft := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_left", , , , {|| fShowHide(2,oPanelLeft,oHideLeft)}, oPanelRight, OemToAnsi(STR0022), , .T.) //"Esconder Browse"
	oHideLeft:Align := CONTROL_ALIGN_LEFT

	oSplitHor := TSplitter():New(01,01,oPanelRight,10,10)
	oSplitHor:SetOrient(1)
	oSplitHor:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Direita/Cima - Detalhes SS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelRUp := TPanel():New(0,0,,oSplitHor,,,,,,10,10,.F.,.F.)
	oPanelRUp:nHeight := ((aSize[7]-aSize[6])/2)
	oPanelRUp:Align   := CONTROL_ALIGN_TOP

	oPanelT2:=TPanel():New(00,00,,oPanelRUp,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPanelT2:nHeight := 25
	oPanelT2:Align := CONTROL_ALIGN_TOP

	@ 003,013 Say OemToAnsi(STR0023) Of oPanelT2 Color aNGColor[1] Pixel //"Detalhes da Solicitação"

	oPanelR1Btn:=TPanel():New(00,00,,oPanelRUp,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPanelR1Btn:Align := CONTROL_ALIGN_LEFT

	oBtnAltSS  := TBtnBmp():NewBar("ng_ico_altss","ng_ico_altss",,,,{|| fAtuEnc(__OPC_TQB__,.T.,4)},,oPanelR1Btn,,,STR0024,,,,,"") //"Alterar Solicitação"
	oBtnAltSS:Align  := CONTROL_ALIGN_TOP

	bGravaEnc := {|| fGravaEnc(__OPC_TQB__)}
	oBtnConf  := TBtnBmp():NewBar("ng_ico_confirmar","ng_ico_confirmar",,,,bGravaEnc,,oPanelR1Btn,,,STR0025,,,,,"") //"Confirmar"
	oBtnConf:Align  := CONTROL_ALIGN_TOP
	oBtnConf:lVisible := .F.

	oBtnCanc  := TBtnBmp():NewBar("ng_ico_cancelar","ng_ico_cancelar",,,,{|| fDisable(.F.,,__OPC_TQB__) },,oPanelR1Btn,,,STR0026,,,,,"") //"Cancelar"
	oBtnCanc:Align  := CONTROL_ALIGN_TOP
	oBtnCanc:lVisible := .F.

	oBtnQuest  := TBtnBmp():NewBar("ng_ico_questionario","ng_ico_questionario",,,,{|| fQuestiSS(__OPC_TQB__)},,oPanelR1Btn,,,STR0027,,,,,"") //"Questionário de Sintomas"
	oBtnQuest:Align  := CONTROL_ALIGN_TOP

	oBtnDet := TBtnBmp():NewBar("ng_ico_tarefas","ng_ico_tarefas",,,,{|| fVisualSS(__OPC_TQB__)},,oPanelR1Btn,,,STR0028,,,,,"") //"Detalhamento Solicitação"
	oBtnDet:Align  := CONTROL_ALIGN_TOP

	oBtnUser  := TBtnBmp():NewBar("ng_ico_info","ng_ico_info",,,,{|| fUserSS(__OPC_TQB__)},,oPanelR1Btn,,,STR0029,,,,,"") //"Informações do Solicitante"
	oBtnUser:Align  := CONTROL_ALIGN_TOP

	oBtnVis  := TBtnBmp():NewBar("ng_ico_conhecimento","ng_ico_conhecimento",,,,{|| fMsDocSS(__OPC_TQB__)},,oPanelR1Btn,,,STR0030,,,,,"") //"Conhecimento"
	oBtnVis:Align  := CONTROL_ALIGN_TOP

	oPanelEnc:=TPanel():New(00,00,,oPanelRUp,,,,,,200,200,.F.,.F.)
	oPanelEnc:Align := CONTROL_ALIGN_ALLCLIENT

	//Criacao das Variaveis da Enchoice
	dbSelectArea("TQB")
	dbSetOrder(1)
	dbSeek(xFilial("TQB"))
	MNT280CPO(2,2)
	MNT280REG(0, a280Relac, a280Memos)

	oEncSS := MsMGet():New("TQB",TQB->(Recno()),4,,,,a280Choice,{0,0,500,500},,3,,,,oPanelEnc)
	oEncSS:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte de baixo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideBottom := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_down", , , , {|| fShowHide(3,oPanelRDown,oHideBottom)}, oPanelRUp, OemToAnsi(STR0031), , .T.) //"Expandir Detalhes da S.S."
	oHideBottom:Align := CONTROL_ALIGN_BOTTOM

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Direita/Baixo - Follow-up    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelRDown := TPanel():New(0,0,,oSplitHor,,,,,,10,10,.F.,.F.)
	oPanelRDown:nHeight := ((aSize[7]-aSize[6])/2)
	oPanelRDown:Align   := CONTROL_ALIGN_BOTTOM

	oHideTop := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_top", , , , {|| fShowHide(4,oPanelRUp,oHideTop)}, oPanelRDown, OemToAnsi(STR0032), , .T.) //"Expandir Browse Follow-Up"
	oHideTop:Align := CONTROL_ALIGN_TOP

	oPanelRDCont := TPanel():New(0,0,,oPanelRDown,,,,,,10,10,.F.,.F.)
	oPanelRDCont:nHeight := ((aSize[7]-aSize[6])/2)
	oPanelRDCont:Align   := CONTROL_ALIGN_ALLCLIENT
	oPanelRDCont:CoorsUpdate()

	oPanelD1:=TPanel():New(00,00,,oPanelRDCont,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPanelD1:nHeight := 25
	oPanelD1:Align := CONTROL_ALIGN_TOP

	@ 003,013 Say OemToAnsi(STR0033) Of oPanelD1 Color aNGColor[1] Pixel //"Follow-Up"

	oPanelR2Btn:=TPanel():New(00,00,,oPanelRDCont,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPanelR2Btn:Align := CONTROL_ALIGN_LEFT

	oPanelFol :=TPanel():New(00,00,,oPanelRDCont,,,,,,200,200,.F.,.F.)
	oPanelFol:Align := CONTROL_ALIGN_ALLCLIENT

	aArrGet := MNT280RFU(Space(Len(TQB->TQB_SOLICI)))
	oGet291Fol := MsNewGetDados():New(5,5,500,500,0,"AllWaysTrue()","AllWaysTrue()",,,,9999,,,,oPanelFol,aArrGet[1], aArrGet[2])
	oGet291Fol:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGet291Fol:oBrowse:Refresh()

	// Carrega Teclas de Atalho
	SetKey(VK_F5, {|| A291RfshSS(__cCallAtend) }) // Refresh do Browse de S.S.

	// Colca o Foco no Browse de Atendimento
	aObj291[__OPC_TQB__][__POS_OBJ__]:SetFocus()
	Activate MsDialog oDlg291 On Init (fCreateBar(oDlg291)) Centered

	//Deleta Arquivo temporario
	NGDELETRB(aObj291[__OPC_TQB__][__POS_ALIAS__],aObj291[__OPC_TQB__][__POS_ARQ__])

	// Limpa variáveis estáticas
	__cCodFun := Space(6)
	__aEqpRes := {}
	__aTotal := Array(3)
	__cFilt291 := ""
	__nAtEq291 := 1

	//Retorna variaveis padrao
	cFilAnt := __cOldFil
	NGRETURNPRM(aNGBEGINPRM)

	If !Empty(cParSolici)
		dbSelectArea("TQB")
		dbSetOrder(1)
		dbSeek(xFilial("TQB")+cParSolici)
	Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCreateTRB
Realiza a criacao das estruturas dos arquivos temporarios

@param nOpcao Opcao de alias a ser criado

@author Roger Rodrigues
@since 12/03/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCreateTRB(nOpcao)
	Local i
	Local nIndx
	Local nFld
	Local nPosDel
	Local cArqMark
	Local cAliasDic
	Local cAliasTRB 	:= GetNextAlias()
	Local aCritic 		:= {}
	Local cAliasTmp
	Local aDBF 			:= {}
	Local aVirtual 		:= {}
	Local aFields 		:= {}
	Local aLegenda 		:= {}
	Local aLegPriori 	:= {}
	Local aLegTerc 		:= {}
	Local vInd 			:= {}
	Local vDesInd 		:= {}
	Local aFldIdx 		:= {}
	Local aExpDel 		:= { "DTOS" , "DESCEND" }
	Local oTmpMark
	Local nTamTot		:= 0
	Local nInd			:= 0
	Local cCampo 		:= ""
	Local cContext 		:= ""
	Local nTamanho 		:= 0
	Local cTipo 		:= ""
	Local cCBox 		:= ""
	Local cIniBRW 		:= ""
	Local cRelacao 		:= ""
	Local nDecimal 		:= 0
	Local cBrowse 		:= ""
	Local aHeadTQB		:= {}
	Local aHeadST1		:= {}

	// Montagem do Markbrowse e arquivo temporario
	If nOpcao == __OPC_TQB__ .or. nOpcao == __OPC_TQB2__
		aADD(aDBF,{"OK"			, "C", 2	,0	})
		aADD(aDBF,{"TQB_FILIAL"	, "C", TAMSX3("TQB_FILIAL")[1], TAMSX3("TQB_FILIAL")[2]	})
		aADD(aDBF,{"TQB_SOLICI"	, "C", TAMSX3("TQB_SOLICI")[1], TAMSX3("TQB_SOLICI")[2]	})
		aADD(aDBF,{"CRITICID"	, "C", TAMSX3("TQB_CRITIC")[1], 0	})
		aADD(aDBF,{"TERCEIRO"	, "C", 1, 0	}) //Indica se SS esta com terceiros

		aADD(aFields, {"OK"		  		, 0, "", "" })
		aADD(aFields, {"TQB_FILIAL"	, TAMSX3("TQB_FILIAL")[1], RetTitle("TQB_FILIAL"), PesqPict("TQB", "TQB_FILIAL")	})
		aADD(aFields, {"TQB_SOLICI"	, TAMSX3("TQB_SOLICI")[1], RetTitle("TQB_SOLICI"), PesqPict("TQB", "TQB_SOLICI")	})

		//Carrega os campos do TRB e do Browse
		aHeadTQB := NGHeader("TQB")
		nTamTot := Len(aHeadTQB)

		For nInd := 1 To nTamTot
			cCampo 		:= aHeadTQB[nInd,2]
			cContext 	:= aHeadTQB[nInd,10]
			nTamanho 	:= aHeadTQB[nInd,4]
			cTipo 		:= aHeadTQB[nInd,8]
			cCBox 		:= Posicione("SX3",2,cCampo,"X3CBox()")
			cIniBRW 	:= Posicione("SX3",2,cCampo,"X3_INIBRW")
			cRelacao 	:= Posicione("SX3",2,cCampo,"X3_RELACAO")
			nDecimal 	:= aHeadTQB[nInd,5]
			cBrowse 	:= Posicione("SX3",2,cCampo,"X3_BROWSE")

			If (aScan(aDBF,{|x| Trim(Upper(x[1])) == Trim(Upper(cCampo))}) ) == 0 .and. AllTrim(cTipo) != "M"
				aADD(aDBF, {AllTrim(cCampo), AllTrim(cTipo),If(!Empty(cCBox),20,nTamanho) , nDecimal })//TRB
				//Se for do Browse
				If AllTrim(Upper(cBrowse)) == "S"
					If (aScan(aFields,{|x| Trim(Upper(x[1])) == Trim(Upper(cCampo))}) ) == 0
						aADD(aFields, {AllTrim(cCampo), If(!Empty(cCBox),20,nTamanho), RetTitle(AllTrim(cCampo)),;
						PesqPict("TQB", AllTrim(cCampo))})//Tela
						//Se o campo for virtual guarda o Ini. Browse
						If !Empty(cCBox)
							aADD(aVirtual, {AllTrim(cCampo), "COMBO"})
						ElseIf cContext == "V"
							aADD(aVirtual, {AllTrim(cCampo), AllTrim(cIniBRW)})
						Endif
					Endif
				ElseIf !Empty(cCBox)
					aADD(aVirtual, {AllTrim(cCampo), "COMBO"})
				ElseIf cContext == "V"
					aADD(aVirtual, {AllTrim(cCampo), AllTrim(cRelacao)})
				Endif
			Endif

		Next nInd

		aAdd(vInd, "TQB_FILIAL+TQB_SOLICI")
		aAdd(vDesInd, RetTitle("TQB_SOLICI"))

		aAdd(vInd, "TQB_FILIAL+TQB_TPSERV+TQB_PRIORI+DESCEND(CRITICID)+DTOS(TQB_DTABER)")
		aAdd(vDesInd, Trim(RetTitle("TQB_TPSERV"))+"+"+Trim(RetTitle("TQB_PRIORI"))+"+"+Trim(RetTitle("TQB_CRITIC"))+"+"+Trim(RetTitle("TQB_DTABER")))
		// Recebe o Índice inicial
		If __nIndTQB == 0
			__nIndTQB := Len(vInd)
		EndIf
		//Carrega indices
		dbSelectArea("SIX")
		dbSetOrder(1)
		dbSeek("TQB")
		While !eof() .and. SIX->INDICE == "TQB"
			If !("TQB_CDSERV" $ SIX->CHAVE) .and. !("TQB_CDEXEC" $ SIX->CHAVE) .and. !("TQB_FUNEXE" $ SIX->CHAVE) .and.;
			aScan(vInd, {|x| AllTrim(x) == AllTrim(SIX->CHAVE)}) == 0
				aAdd(vInd, AllTrim(SIX->CHAVE))
				aAdd(vDesInd, AllTrim(SixDescricao()))
			Endif
			dbSelectArea("SIX")
			dbSkip()
		End

		//Definicao da Legenda do MarkBrowse
		aCritic := MNT293CRI()
		cAliasTmp := "aObj291["+cValToChar(nOpcao)+"]["+cValToChar(__POS_ALIAS__)+"]"
		For i:=1 to Len(aCritic)
			If aCritic[i][3] == 0
				aAdd(aLegenda, {"Substr(("+cAliasTmp+")->TQB_TPSERV,1,1) == '1'",aCritic[i][1]})
			ElseIf aCritic[i][3] == 0.5
				aAdd(aLegenda, {"Substr(("+cAliasTmp+")->TQB_TPSERV,1,1) == '2'",aCritic[i][1]})
			Else
				aAdd(aLegenda, {"("+cAliasTmp+")->TQB_CRITIC >= "+cValToChar(aCritic[i][3])+" .and. ("+cAliasTmp+")->TQB_CRITIC <= "+cValToChar(aCritic[i][4]),aCritic[i][1]})
			Endif
		Next i

		aAdd(aLegPriori, {"Empty(("+cAliasTmp+")->TQB_PRIORI)","BR_PRETO"})
		aAdd(aLegPriori, {"Substr(("+cAliasTmp+")->TQB_PRIORI,1,1) == '1'","BR_VERMELHO"})
		aAdd(aLegPriori, {"Substr(("+cAliasTmp+")->TQB_PRIORI,1,1) == '2'","BR_AMARELO"})
		aAdd(aLegPriori, {"Substr(("+cAliasTmp+")->TQB_PRIORI,1,1) == '3'","BR_AZUL"})

		aAdd(aLegTerc, {"Empty(("+cAliasTmp+")->TERCEIRO)","BR_BRANCO"})
		aAdd(aLegTerc, {"!Empty(("+cAliasTmp+")->TERCEIRO)","BR_PRETO"})

		cAliasDic := "TQB"
	ElseIf nOpcao == __OPC_ST1__

		aADD(aDBF,{"T1_FILIAL"	, "C", TAMSX3("T1_FILIAL")[1]	, TAMSX3("T1_FILIAL")[2]	})
		aADD(aDBF,{"T1_CODFUNC"	, "C", TAMSX3("T1_CODFUNC")[1], TAMSX3("T1_CODFUNC")[2]	})
		aADD(aDBF,{"T1_NOME"		, "C", TAMSX3("T1_NOME")[1]	, TAMSX3("T1_NOME")[2]	})
		aADD(aDBF,{"QTDSS"	   , "N", 6 , 0 })

		aADD(aFields, {"T1_CODFUNC", TAMSX3("T1_CODFUNC")[1], RetTitle("T1_CODFUNC"), PesqPict("ST1", "T1_CODFUNC")	})
		aADD(aFields, {"T1_NOME"	, TAMSX3("T1_NOME")[1]	 , RetTitle("T1_NOME"), PesqPict("ST1", "T1_NOME")	})
		aADD(aFields, {"QTDSS" 	   , 6, STR0034 , "@E 999,999"}) //"Quantidade de S.S."

		//Carrega os campos do TRB e do Browse
		aHeadST1 := NGHeader("ST1")
		nTamTot := Len(aHeadST1)

		For nInd := 1 To nTamTot
			cCampo 		:= aHeadST1[nInd,2]
			cContext 	:= aHeadST1[nInd,10]
			nTamanho 	:= aHeadST1[nInd,4]
			cTipo 		:= aHeadST1[nInd,8]
			cCBox 		:= Posicione("SX3",2,cCampo,"X3CBox()")
			cIniBRW 	:= Posicione("SX3",2,cCampo,"X3_INIBRW")
			cRelacao 	:= Posicione("SX3",2,cCampo,"X3_RELACAO")
			nDecimal 	:= aHeadST1[nInd,5]
			cBrowse 	:= Posicione("SX3",2,cCampo,"X3_BROWSE")

			If (aScan(aDBF,{|x| Trim(Upper(x[1])) == Trim(Upper(cCampo))}) ) == 0 .and. AllTrim(cTipo) != "M"
				aADD(aDBF, {AllTrim(cCampo), AllTrim(cTipo),If(!Empty(cCBox),20,nTamanho) , nDecimal })//TRB
				//Se for do Browse
				If AllTrim(Upper(cBrowse)) == "S"
					//Se o campo for virtual guarda o Ini. Browse
					If !Empty(cCBox)
						aADD(aVirtual, {AllTrim(cCampo), "COMBO"})
					ElseIf cContext == "V"
						aADD(aVirtual, {AllTrim(cCampo), AllTrim(cIniBRW)})
					Endif
				ElseIf !Empty(cCBox)
					aADD(aVirtual, {AllTrim(cCampo), "COMBO"})
				ElseIf cContext == "V"
					aADD(aVirtual, {AllTrim(cCampo), AllTrim(cRelacao)})
				Endif
			Endif

		Next nInd

		//Carrega indices
		dbSelectArea("SIX")
		dbSetOrder(1)
		dbSeek("ST1")
		While !eof() .and. SIX->INDICE == "ST1"
			If aScan(vInd, {|x| AllTrim(x) == AllTrim(SIX->CHAVE)}) == 0
				aAdd(vInd, AllTrim(SIX->CHAVE))
				aAdd(vDesInd, AllTrim(SixDescricao()))
			Endif
			dbSelectArea("SIX")
			dbSkip()
		End

		//Definicao da Legenda do TCBrowse
		cAliasTmp := "aObj291["+cValToChar(nOpcao)+"]["+cValToChar(__POS_ALIAS__)+"]"
		aAdd(aLegenda, {"fRespEquipe(("+cAliasTmp+")->T1_FILIAL, ("+cAliasTmp+")->T1_CODFUNC)" ,"BR_VERDE", STR0035}) //"Responsável da Equipe"
		aAdd(aLegenda, {"!fRespEquipe(("+cAliasTmp+")->T1_FILIAL, ("+cAliasTmp+")->T1_CODFUNC)","BR_AZUL" , STR0036}) //"Membro da Equipe"

		cAliasDic := "ST1"
	Endif

	oTmpMark := FWTemporaryTable():New(cAliasTRB, aDBF)
	For nIndx := 1 To Len(vInd)
		aFldIdx := StrTokArr( vInd[nIndx], "+" )

		For nFld := 1 To Len( aFldIdx )
			If ( nPosDel := aScan( aExpDel , { | x | AllTrim( Upper( x ) ) $ Upper( aFldIdx[ nFld ] ) } ) ) > 0
				aFldIdx[ nFld ] := SubStr( aFldIdx[ nFld ] , Len( aExpDel[ nPosDel ] ) + 2 )
				aFldIdx[ nFld ] := SubStr( aFldIdx[ nFld ] , 1 , Len( aFldIdx[ nFld ] ) - 1 )
			EndIf
		Next nFld
		oTmpMark:AddIndex( "Ind" + cValToChar( nIndx ) , aFldIdx )
	Next nIndx
	oTmpMark:Create()

	//Preenche array do markbrowse
	aObj291[nOpcao][__POS_OBJ__]   := Nil
	aObj291[nOpcao][__POS_FIELDS__]:= aFields
	aObj291[nOpcao][__POS_DBF__]   := aDBF
	aObj291[nOpcao][__POS_IND__]   := vInd
	aObj291[nOpcao][__POS_VIR__]   := aVirtual
	aObj291[nOpcao][__POS_ARQ__]   := cArqMark
	aObj291[nOpcao][__POS_ALIAS__] := cAliasTRB
	aObj291[nOpcao][__POS_LEG__]   := aLegenda
	aObj291[nOpcao][__POS_ALIDIC__]:= cAliasDic
	aObj291[nOpcao][__POS_FILTER__]:= ""
	aObj291[nOpcao][__POS_DESIND__]:= vDesInd
	aObj291[nOpcao][__POS_LEG2__]  := aLegPriori
	aObj291[nOpcao][__POS_LEG3__]  := aLegTerc

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadTRB
Carrega arquivo temporario com solicitacoes de servico

@param nOpcao Opcao de alias a ser carregado
@param cFiltro Filtro a ser aplicado no alias a ser carregado

@author Roger Rodrigues
@since 07/06/2011
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fLoadTRB(nOpcao, cFiltro, cCodFun, cEquipe, cFornec)
	Local i, j, nPos
	Local cOldFil := cFilAnt
	Local aListaSS := {}
	Local aEquipeRes := If(nOpcao == __OPC_TQB2__, {}, Nil)
	Local cCampo := ""
	Local cTerceiro := ""
	Local cValor := Nil
	Local cAliasMark := aObj291[nOpcao][__POS_ALIAS__]

	Default cFiltro := ""
	Default cCodFun := ""
	Default cEquipe := ""
	Default cFornec := ""

	//Limpa Arquivo temporario
	dbSelectArea(cAliasMark)
	Zap

	//Carrega solicitacao
	If nOpcao == __OPC_TQB__ .or. nOpcao == __OPC_TQB2__

		If nOpcao == __OPC_TQB2__ .and. !Empty(cCodFun)
			If NGIFDBSEEK("TP4",cEquipe,1) .and. TP4->TP4_CODRES == cCodFun
				aEquipeRes := {{cEquipe,TP4->TP4_DESCRI}}
			Endif
		Endif

		aListaSS := fRetSSAte(cCodFun, aEquipeRes, cFornec)

		ProcRegua(Len(aListaSS))
		For j:=1 to Len(aListaSS)
			IncProc()
			dbSelectArea("TQB")
			dbSetOrder(1)
			If dbSeek(xFilial("TQB",aListaSS[j][__POS_FILSS__])+aListaSS[j][__POS_CODSS__])
				If !Empty(aListaSS[j][__POS_FILSS__])
					cFilAnt := aListaSS[j][__POS_FILSS__]
				Endif
				//Somente distribuidas
				If TQB->TQB_SOLUCA != "D"
					dbSelectArea("TQB")
					dbSkip()
					Loop
				Endif

				// Filtro Padrão da Rotina
				If !Empty(__cFilt291) .and. !Eval( &("{||"+__cFilt291+"}") )
					dbSelectArea("TQB")
					dbSkip()
					Loop
				Endif

				// Filtro personalizado
				If !Empty(cFiltro) .and. !Eval( &("{||"+cFiltro+"}") )
					dbSelectArea("TQB")
					dbSkip()
					Loop
				Endif

				// Adiciona
				cTerceiro := fRetTerc(aListaSS[j][__POS_FILSS__],aListaSS[j][__POS_CODSS__])
				dbSelectArea("TQB")
				dbSelectArea(cAliasMark)
				RecLock(cAliasMark,.T.)
				For i:=1 to FCount()
					cCampo := Upper(Trim(FieldName(i)))
					cValor := Nil
					If cCampo == "OK"
						cValor := Space(2)
					ElseIf cCampo == "CRITICID"
						cValor := StrZero(TQB->TQB_CRITIC, 3)
					ElseIf cCampo == "TERCEIRO"
						cValor := cTerceiro
					ElseIf (nPos := aScan(aObj291[nOpcao][__POS_VIR__],{|x| Trim(Upper(x[1])) == cCampo}) ) > 0//Verifica se o campo tem Inicializador
						//Executa Combo
						If aObj291[nOpcao][__POS_VIR__][nPos][2] == "COMBO"
							If !Empty(&("TQB->"+cCampo))
								cValor := &("TQB->"+cCampo)+"="+NGRETSX3BOX(cCampo,&("TQB->"+cCampo))
							Endif
						ElseIf !Empty(aObj291[nOpcao][__POS_VIR__][nPos][2])//Executa Inicializador
							cValor := &(aObj291[nOpcao][__POS_VIR__][nPos][2])
						Endif
					Else//Grava normalmente
						cValor := &("TQB->"+cCampo)
					Endif
					If ValType(cValor) != "U"
						dbSelectArea(cAliasMark)
						FieldPut(i, cValor)
					Endif
				Next i
				MsUnlock(cAliasMark)

			Endif
		Next j
		dbSelectArea(cAliasMark)
		dbSetOrder(__nIndTQB)
		dbGoTop()

	ElseIf nOpcao == __OPC_ST1__

		dbSelectArea("ST1")
		dbSetOrder(1)
		ProcRegua(ST1->(RecCount()))
		dbSeek(xFilial("ST1"))
		While !Eof() .and. ST1->T1_FILIAL == xFilial("ST1")
			IncProc()

			// Filtro Obrigatório de Funcionários (ST1) que atendem 2=Facilities ou 3=Ambos
			If !(ST1->T1_TIPATE $ "2/3")
				dbSelectArea("ST1")
				dbSkip()
				Loop
			EndIf
			// Filtro personalizado
			If !Empty(cFiltro) .and. !Eval( &("{||"+cFiltro+"}") )
				dbSelectArea("ST1")
				dbSkip()
				Loop
			Endif

			// Adiciona
			dbSelectArea("ST1")
			dbSelectArea(cAliasMark)
			RecLock(cAliasMark,.T.)
			For i:=1 to FCount()
				cCampo := Upper(Trim(FieldName(i)))
				cValor := Nil
				If (nPos := aScan(aObj291[nOpcao][__POS_VIR__],{|x| Trim(Upper(x[1])) == cCampo}) ) > 0//Verifica se o campo tem Inicializador
					//Executa Combo
					If aObj291[nOpcao][__POS_VIR__][nPos][2] == "COMBO"
						If !Empty(&("ST1->"+cCampo))
							cValor := &("ST1->"+cCampo)+"="+NGRETSX3BOX(cCampo,&("ST1->"+cCampo))
						Endif
					ElseIf !Empty(aObj291[nOpcao][__POS_VIR__][nPos][2])//Executa Inicializador
						cValor := Eval({|| &(aObj291[nOpcao][__POS_VIR__][nPos][2])})
					Endif
				ElseIf "QTDSS" $ cCampo
					cValor := A296QtdSS("2", ST1->T1_FILIAL, ST1->T1_CODFUNC, )
				Else//Grava normalmente
					cValor := &("ST1->"+cCampo)
				Endif
				If ValType(cValor) != "U"
					dbSelectArea(cAliasMark)
					FieldPut(i, cValor)
				Endif
			Next i
			MsUnlock(cAliasMark)

			dbSelectArea("ST1")
			dbSkip()
		End
	Endif

	dbSelectArea(cAliasMark)
	dbGoTop()
	cFilAnt := cOldFil
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fShowHide
Mostra/Esconde Painel

@param nPanel Painel a ser escondido/mostrado
@param oPanel Objeto do painel a ser escondido/mostrado
@param oBotao Objeto do botao que deve ter sua label alterada

@author Roger Rodrigues
@since 13/03/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fShowHide(nPanel,oPanel,oBotao)

	If oPanel:lVisible
		oPanel:Hide()
		If nPanel == 1
			oBotao:LoadBitmaps("fw_arrow_left")
			oBotao:cTooltip := OemToAnsi(STR0037) //"Esconder Browse"
		ElseIf nPanel == 2
			oBotao:LoadBitmaps("fw_arrow_right")
			oBotao:cTooltip := OemToAnsi(STR0038) //"Expandir Browse"
		ElseIf nPanel == 3
			oBotao:LoadBitmaps("fw_arrow_top")
			oBotao:cTooltip := OemToAnsi(STR0039) //"Expandir Browse Follow-Up"
		ElseIf nPanel == 4
			oBotao:LoadBitmaps("fw_arrow_down")
			oBotao:cTooltip := OemToAnsi(STR0040) //"Expandir Detalhes da S.S."
		Endif
	Else
		oPanel:Show()
		If nPanel == 1
			oBotao:LoadBitmaps("fw_arrow_right")
			oBotao:cTooltip := OemToAnsi(STR0038) //"Expandir Browse"
		ElseIf nPanel == 2
			oBotao:LoadBitmaps("fw_arrow_left")
			oBotao:cTooltip := OemToAnsi(STR0037) //"Esconder Browse"
		ElseIf nPanel == 3
			oBotao:LoadBitmaps("fw_arrow_down")
			oBotao:cTooltip := OemToAnsi(STR0040) //"Expandir Detalhes da S.S."
		ElseIf nPanel == 4
			oBotao:LoadBitmaps("fw_arrow_top")
			oBotao:cTooltip := OemToAnsi(STR0039) //"Expandir Browse Follow-Up"
		EndIf
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fQuestiSS
Carrega questionario da solicitacao

@author Roger Rodrigues
@since 24/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fQuestiSS(nOpcao)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local cOldFil := cFilAnt
	Local cFilSS := (aObj291[nOpcao][__POS_ALIAS__])->TQB_FILIAL
	Local cCodSS := (aObj291[nOpcao][__POS_ALIAS__])->TQB_SOLICI

	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB",cFilSS)+cCodSS)
		If !Empty(cFilSS)
			cFilAnt := cFilSS
		Endif
		MNT280DIAG(.F., .F., Nil)
	Endif

	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fVisualSS
Carrega visualizacao da solicitacao

@author Roger Rodrigues
@since 18/09/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fVisualSS(nOpcao)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local aMemory  := NGGetMemory("TQB")
	Local cOldFil := cFilAnt
	Local cFilSS := (aObj291[nOpcao][__POS_ALIAS__])->TQB_FILIAL
	Local cCodSS := (aObj291[nOpcao][__POS_ALIAS__])->TQB_SOLICI

	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB",cFilSS)+cCodSS)
		If !Empty(cFilSS)
			cFilAnt := cFilSS
		Endif
		MNTA280IN(2,1)
	Endif

	cFilAnt := cOldFil
	NgRestMemory(aMemory)
	NGRETURNPRM(aNGBEGINPRM)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fUserSS
Mostra informacoes do solicitante da SS

@author Roger Rodrigues
@since 04/03/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fUserSS(nOpcao)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local cOldFil := cFilAnt
	Local cFilSS := (aObj291[nOpcao][__POS_ALIAS__])->TQB_FILIAL
	Local cCodSS := (aObj291[nOpcao][__POS_ALIAS__])->TQB_SOLICI

	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB",cFilSS)+cCodSS)
		If !Empty(cFilSS)
			cFilAnt := cFilSS
		Endif
		dbSelectArea("TUF")
		dbSetOrder(1)
		If dbSeek(xFilial("TUF",cFilSS)+TQB->TQB_CDSOLI)
			FWExecView( STR0029 , 'MNTA909' , MODEL_OPERATION_VIEW , , { || .T. } ) //"Informações do Solicitante"
		Endif
	Endif

	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fMsDocSS
Realiza chamada do conhecimento das solicitacoes

@author Roger Rodrigues
@since 04/03/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMsDocSS(nOpcao)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local cOldFil := cFilAnt
	Local cFilSS := (aObj291[nOpcao][__POS_ALIAS__])->TQB_FILIAL
	Local cCodSS := (aObj291[nOpcao][__POS_ALIAS__])->TQB_SOLICI

	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB",cFilSS)+cCodSS)
		If !Empty(cFilSS)
			cFilAnt := cFilSS
		Endif
		MsDocument("TQB",TQB->(Recno()),4)
	Endif

	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fImpSS
Realiza chamada da impressao das solicitacoes marcadas

@author Roger Rodrigues
@since 03/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fImpSS()
	Local aGetArea := fGetArea(aObj291[__OPC_TQB__][__POS_ALIAS__])
	Local aListaSS := fRetSSMrk()

	If Len(aListaSS) > 0
		MNTR120(aListaSS)
	Else
		ShowHelpDlg(STR0041,{STR0042},1,{STR0043}) //"Atenção" ## "Deve ser selecionada pelo menos uma Solicitação de Serviço para impressão." ## "Marque uma Solicitação de Serviço."
	Endif

	fRestArea(aGetArea)
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetSSMrk
Retorna array com as SS's marcadas

@author Roger Rodrigues
@since 04/04/2012
@version MP10/MP11
@return aSSMark
/*/
//---------------------------------------------------------------------
Static Function fRetSSMrk()
	Local aSSMark := {}
	Local cAliasMrk := aObj291[__OPC_TQB__][__POS_ALIAS__]
	Local aGetArea := fGetArea(cAliasMrk)

	dbSelectArea(cAliasMrk)
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		If !Empty((cAliasMrk)->OK)
			aAdd(aSSMark, {(cAliasMrk)->TQB_FILIAL, (cAliasMrk)->TQB_SOLICI})
		Endif
		dbSelectArea(cAliasMrk)
		dbSkip()
	End

	fRestArea(aGetArea)
Return aSSMark
//---------------------------------------------------------------------
/*/{Protheus.doc} fGetArea
Salva posicao de alias selecionado e filtro

@param cAliasTmp Alias que devera ter salvo sua posicao e filtro

@author Roger Rodrigues
@since 04/04/2012
@version MP10/MP11
@return aGetArea
/*/
//---------------------------------------------------------------------
Static Function fGetArea(cAliasTmp)
	Local aGetArea := {}

	aAdd(aGetArea, cAliasTmp)
	aAdd(aGetArea, (cAliasTmp)->(IndexOrd()))
	aAdd(aGetArea, (cAliasTmp)->(Recno()))
	aAdd(aGetArea, (cAliasTmp)->(dbFilter()))

Return aGetArea
//---------------------------------------------------------------------
/*/{Protheus.doc} fRestArea
Retorna posicao de alias selecionado e filtro

@param aGetArea Array com parametros do alias salvo

@author Roger Rodrigues
@since 04/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fRestArea(aGetArea)

	dbSelectArea(aGetArea[1])
	dbSetOrder(aGetArea[2])
	dbGoTo(aGetArea[3])
	Set Filter To &(aGetArea[4])

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fMrkAll
Marca todos os itens do Markbrowse

@param nOpcao Opcao de markbrowse a ser marcado
@param cMarca Variavel de marcacao do browse

@author Roger Rodrigues
@since 04/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMrkAll(nOpcao,nPosHead,cMarca)
	Local lMarca:= .F.
	Local cAliasMrk := aObj291[nOpcao][__POS_ALIAS__]
	Local aGetArea := fGetArea(cAliasMrk)
	Default nPosHead := 1

	If nPosHead <> 1
		Return .F.
	Endif

	//Verifica se existe item desmarcado
	dbSelectArea(cAliasMrk)
	dbSetOrder(1)
	dbGoTop()
	While !eof()
		If Empty((cAliasMrk)->OK)
			lMarca := .T.
			Exit
		Endif
		dbSelectArea(cAliasMrk)
		dbSkip()
	End
	//Marca ou desmarca todos
	dbSelectArea(cAliasMrk)
	dbSetOrder(1)
	dbGoTop()
	While !eof()
		RecLock(cAliasMrk,.F.)
		(cAliasMrk)->OK := If(lMarca, cMarca, Space(2))
		MsUnlock(cAliasMrk)
		dbSelectArea(cAliasMrk)
		dbSkip()
	End

	//Restaura tabela e atualiza browse
	fRestArea(aGetArea)
	aObj291[nOpcao][__POS_OBJ__]:Refresh(.T.)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fSetFilter
Troca filtro de markbrowse

@param nOpcao Opcao de markbrowse a ser filtrado

@author Roger Rodrigues
@since 10/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSetFilter(nOpcao, cCodFun, aEqpRes)
	Local cOldFilt := aObj291[nOpcao][__POS_FILTER__]
	aObj291[nOpcao][__POS_FILTER__] := BuildExpr(aObj291[nOpcao][__POS_ALIDIC__],,aObj291[nOpcao][__POS_FILTER__])
	// Apenas atualiza se o Filtro for diferente
	If AllTrim(aObj291[nOpcao][__POS_FILTER__]) <> cOldFilt
		Processa({|| fLoadTRB(nOpcao, aObj291[nOpcao][__POS_FILTER__], cCodFun, aEqpRes) },STR0002,STR0044) //"Aguarde..." ## "Recarregando..."
		Eval( aObj291[nOpcao][__POS_OBJ__]:bChange )
	EndIf
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A291LEGEND
Monta tela de Legenda de acordo com os arrays

@param nOpcao Opcao de tela de legenda a ser montada

@author Roger Rodrigues
@since 12/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function A291LEGEND(nOpcao, nOpcTabela, nOpcLegend, aShowLegs)
	Local aLegenda := {}, nLeg := 0
	Local cTitulo  := ""
	Local cOldFil  := cFilAnt
	Local lSituac  := .T., lCritic := .T., lPriori := .T., lTercei := .T.
	Default aShowLegs := {}
	cFilAnt := __cOldFil
	If nOpcao == 1//Legenda da Criticidade
		If Len(aShowLegs) > 0
			lSituac := ( aScan(aShowLegs, {|x| x == 1 }) > 0 )
			lCritic := ( aScan(aShowLegs, {|x| x == 2 }) > 0 )
			lPriori := ( aScan(aShowLegs, {|x| x == 3 }) > 0 )
			lTercei := ( aScan(aShowLegs, {|x| x == 4 }) > 0 )
		EndIf
		MNT293LEG(lSituac, lCritic, lPriori, lTercei)
	ElseIf nOpcao == 2 // Legenda de acordo com os Arrays
		cTitulo := STR0014 //"Legenda"
		For nLeg := 1 To Len(aObj291[nOpcTabela][nOpcLegend])
			If Len(aObj291[nOpcTabela][nOpcLegend][nLeg]) >= 3
				// 1      ; 2
				// Imagem ; Descrição
				aAdd(aLegenda, {aObj291[nOpcTabela][nOpcLegend][nLeg][2], aObj291[nOpcTabela][nOpcLegend][nLeg][3]})
			EndIf
		Next nLeg
	Endif
	If Len(aLegenda) > 0
		BrwLegenda(cCadastro,cTitulo,aLegenda)
	Endif
	cFilAnt := cOldFil
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuEnc
Cria e recria enchoice da solicitacao

@author Roger Rodrigues
@since 08/06/2011
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fAtuEnc(nOpcao,lDisable,nOpcx)
	Local i
	Local aGetArea := fGetArea("TQB")
	Local cFilSS := (aObj291[nOpcao][__POS_ALIAS__])->TQB_FILIAL
	Local cCodSS := (aObj291[nOpcao][__POS_ALIAS__])->TQB_SOLICI
	Default lDisable := .F.
	Default nOpcx := 2

	If nOpcx <> 4 .Or. !Empty(cCodSS)
		If lDisable
			If !fDisable(.T.,.F.,nOpcao)
				Return .F.
			EndIf
		Endif
		If Empty(cCodSS) .And. nOpcx > 0
			nOpcx := 0
		EndIf
		If nOpcx > 0
			dbSelectArea("TQB")
			dbSetOrder(1)
			If dbSeek(xFilial("TQB",cFilSS)+cCodSS)
				If !Empty(cFilSS)
					cFilAnt := cFilSS
				Endif
				MNT280CPO(2,nOpcx)
				MNT280REG(nOpcx, a280Relac, a280Memos)
				If nOpcao == __OPC_TQB__
					//Atualiza GetDados
					oGet291Fol:aCols := MNT280RFU(cCodSS)[2]
				Endif
			Else
				If nOpcao == __OPC_TQB__
					//Atualiza GetDados
					oGet291Fol:aCols := BlankGetD(MNT280RFU(Space(Len(TQB->TQB_SOLICI)))[1])
				Endif
			Endif
		Else
			MNT280CPO(2,2)
			MNT280REG(nOpcx, a280Relac, a280Memos)
			If nOpcao == __OPC_TQB__
				//Atualiza GetDados
				oGet291Fol:aCols := BlankGetD(MNT280RFU(Space(Len(TQB->TQB_SOLICI)))[1])
			Endif
		Endif

		//Coloca campo no modo de visualizacao
		For i:=1 to Len(oEncSS:aGets)
			oEncSS:aEntryCtrls[i]:lReadOnly := (nOpcx == 2 .or. nOpcx == 0)
			oEncSS:aEntryCtrls[i]:lActive := (nOpcx == 2 .or. nOpcx == 0)
		Next i

		oEncSS:EnchRefreshAll()
		If nOpcao == __OPC_TQB__
			oGet291Fol:GoTo(1)
			oGet291Fol:oBrowse:Refresh()
		Endif
	Endif

	fRestArea(aGetArea)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fDisable
Desabilita/Habilita Botões.

@author Wagner Sobral de Lacerda
@since 11/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fAtuBtns()

	// Variáveis auxiliares
	Local lEnable := .T.
	Local nBtn := 0

	// Verifica se pode atender a S.S. posicionada
	lEnable := fPodeAtender((aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_FILIAL, (aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI, .F.)

	// Habilita/Desabilita botões
	aEval(__aBtns291, {|x| If(lEnable, x[2]:Enable(), x[2]:Disable()) })

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fDisable
Desabilita/Habilita objetos da tela

@param lDisable Indica se deve desabilitar campos
@param lAtuEnc Indica se atualiza enchoice

@author Roger Rodrigues
@since 11/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fDisable(lDisable,lAtuEnc,nOpcao)
	Local cCodSS := ""
	Default lDisable := .T.
	Default lAtuEnc  := .T.

	cCodSS := (aObj291[nOpcao][__POS_ALIAS__])->TQB_SOLICI

	If lDisable
		// Semáforo para utilização da Alteração de S.S.
		If !LockByName("MNTALTSS"+cCodSS, .T., .T., .F.)
			MsgInfo(STR0045 + " " + cCodSS + " " + STR0046 + CRLF + CRLF + ; //"A Solicitação de Serviço" ## "já está sendo manipulada por outro processo ou usuário."
			STR0047 , STR0041) //"Por favor, tente novamente mais tarde." ## "Atenção"
			Return .F.
		EndIf

		oPanelLCont:Disable()
		oBtnAltSS:lVisible := .F.
		oBtnConf:lVisible  := .T.
		oBtnCanc:lVisible  := .T.
		If nOpcao == __OPC_TQB__
			oPanelRDCont:Disable()
		Else
			oPnlTop:Disable()
		Endif
	Else
		cFilAnt := __cOldFil
		If lAtuEnc
			fAtuEnc(nOpcao)
		Endif
		oPanelLCont:Enable()
		oBtnAltSS:lVisible := .T.
		oBtnConf:lVisible  := .F.
		oBtnCanc:lVisible  := .F.
		If nOpcao == __OPC_TQB__
			oPanelRDCont:Enable()
		Else
			oPnlTop:Enable()
		Endif

		// Libera Semáforo
		UnLockByName("MNTALTSS"+cCodSS, .T., .T., .F.)
	Endif
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fSeekReg
Procura registro na tabela

@param nOpcao Opcao do markbrowse a ser pesquisado
@param nIndex Indice da tabela a ser utilizado para pesquisa
@param cPesquisa Chave de Pesquisa
@param lSeek Indica se procura registro ou apenas muda indice

@author Roger Rodrigues
@since 12/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSeekReg(nOpcao, nIndex, cPesquisa, lSeek)
	Local nInd := 0
	Local cChave := ""
	Default lSeek := .T.

	nInd := nIndex
	__nIndTQB := nInd

	dbSelectArea(aObj291[nOpcao][__POS_ALIAS__])
	dbSetOrder(nInd)

	If !lSeek
		cPesquisa := Space(100)
	Else
		cChave := cPesquisa
		If "_FILIAL"$Substr(aObj291[nOpcao][__POS_IND__][nIndex],1,10)
			cChave := xFilial(aObj291[nOpcao][__POS_ALIDIC__])+cChave
		Endif
		dbSeek(cChave,.T.)
	Endif

	If !Empty(aObj291[nOpcao][__POS_OBJ__])
		If lSeek
			Eval( aObj291[nOpcao][__POS_OBJ__]:bChange )
		EndIf
		aObj291[nOpcao][__POS_OBJ__]:Refresh(.T.)
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaEnc
Realiza validacao e gravacao da solicitacao

@author Roger Rodrigues
@since 16/04/2012
@version MP10/MP11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fGravaEnc(nOpcao)
	Local i
	Local cAliasMark := aObj291[nOpcao][__POS_ALIAS__]
	Local aGetArea := fGetArea(cAliasMark)
	Local cCodSS, cValor, cCampo
	Local lRet := .T.

	lRet := MNT280TOK( 0, 4 )

	//Atualiza tabela e tela
	If lRet
		cCodSS := MNT280GRV( 0, 4, .T., a280Memos, __cCodFun, __cOldFil )//Grava campos da tela

		dbSelectArea("TQB")
		dbSetOrder(1)
		If dbSeek(xFilial("TQB")+cCodSS)
			If !Empty(aObj291[nOpcao][__POS_FILTER__]) .and. !Eval( &("{||"+aObj291[nOpcao][__POS_FILTER__]+"}") )
				dbSelectArea(cAliasMark)
				dbSetOrder(1)
				If dbSeek(xFilial("TQB")+cCodSS)
					RecLock(cAliasMark, .F.)
					dbDelete()
					MsUnlock(cAliasMark)
				Endif
			Else
				dbSelectArea(cAliasMark)
				dbSetOrder(1)
				If dbSeek(xFilial("TQB")+cCodSS)
					RecLock(cAliasMark,.F.)
					For i:=1 to FCount()
						cCampo := Upper(Trim(FieldName(i)))
						cValor := Nil
						If cCampo == "OK" .or. cCampo == "CRITICID"
							Loop
						ElseIf (nPos := aScan(aObj291[nOpcao][__POS_VIR__],{|x| Trim(Upper(x[1])) == cCampo}) ) > 0//Verifica se o campo tem Inicializador
							//Executa Combo
							If aObj291[nOpcao][__POS_VIR__][nPos][2] == "COMBO"
								If !Empty(&("TQB->"+cCampo))
									cValor := &("TQB->"+cCampo)+"="+NGRETSX3BOX(cCampo,&("TQB->"+cCampo))
								Endif
							ElseIf !Empty(aObj291[nOpcao][__POS_VIR__][nPos][2])//Executa Inicializador
								cValor := &(aObj291[nOpcao][__POS_VIR__][nPos][2])
							Endif
						ElseIf TQB->(FieldPos(cCampo)) > 0//Grava normalmente
							cValor := &("TQB->"+cCampo)
						Endif
						If ValType(cValor) != "U"
							dbSelectArea(cAliasMark)
							FieldPut(i, cValor)
						Endif
					Next i
					MsUnlock(cAliasMark)
				Endif
			Endif
			aObj291[nOpcao][__POS_OBJ__]:Refresh(.T.)
		Endif
		fDisable(.F.,.T.,nOpcao)
	Endif

	fRestArea(aGetArea)
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetCodUsu
Retorna codigo do usuario logado

@author Roger Rodrigues
@since 23/08/2012
@version MP10/MP11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fRetCodUsu()
	Local lRet := .F.
	Local oDlgUsu
	Local oCodUsu, oNomUsu
	Local cCodUsu := Space(TAMSX3("T1_CODFUNC")[1])
	Local cNomUsu := Space(TAMSX3("T1_NOME")[1])

	dbSelectArea("ST1")
	dbSetOrder(6)
	If dbSeek(xFilial("ST1")+RetCodUsr())
		__cCodFun := ST1->T1_CODFUNC
		lRet := .T.
	Endif

	If Empty(__cCodFun)
		Define MsDialog oDlgUsu Title OemToAnsi(STR0048) From 000,000 To 80,357 OF oMainWnd Pixel //"Identifique-se:"

		@ 003,003 TO 025,177 LABEL OemToAnsi(STR0049) Of oDlgUsu Pixel //"Funcionário:"

		@ 010,006 MsGet oCodUsu Var cCodUsu Picture "@!" F3 "ST1FAC" Size 065,008 Of oDlgUsu Pixel ;
		Valid (If(fVldCodUsu(cCodUsu), (cNomUsu := NGSEEK("ST1",cCodUsu,1,"ST1->T1_NOME")),.F.)) HasButton

		@ 010,075 MsGet oNomUsu Var cNomUsu Size 100,008 Of oDlgUsu Pixel ReadOnly

		Define sButton From 026,117 Type 1 Enable Of oDlgUsu Action (lRet := .T., oDlgUsu:End())

		Define sButton From 026,147 Type 2 Enable Of oDlgUsu Action (lRet := .F., oDlgUsu:End())

		Activate MsDialog oDlgUsu Centered

		If lRet
			__cCodFun := cCodUsu
		Endif
	Endif

	//Se for responsavel, carrega codigo equipes as quais ele eh responsavel
	If lRet
		dbSelectArea("TP4")
		dbSetOrder(2)
		dbSeek(xFilial("TP4")+__cCodFun)
		While !Eof() .and. TP4->TP4_FILIAL+TP4->TP4_CODRES == xFilial("TP4")+__cCodFun
			aAdd(__aEqpRes, {TP4->TP4_CODIGO, TP4->TP4_DESCRI})
			dbSelectArea("TP4")
			dbSkip()
		End
	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fVldCodUsu
Valida o codigo do usuario para atendimento.

@author Wagner Sobral de Lacerda
@since 18/10/2012
@version MP10/MP11
@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fVldCodUsu(cVerCodUsu)

	//----------
	// Valida
	//----------
	// Valida existência do Funcionário
	dbSelectArea("ST1")
	dbSetOrder(1)
	If !dbSeek(xFilial("ST1") + cVerCodUsu)
		Help(" ",1,"REGNOIS")
		Return .F.
	EndIf
	// Valida vínculo com Usuário do Sistema
	If !Empty(ST1->T1_CODUSU) .And. ST1->T1_CODUSU <> RetCodUsr()
		Help(Nil, Nil, STR0041, Nil, STR0050 + " " + AllTrim(cVerCodUsu) +  " " + STR0051, 1, 0) //"Atenção" ## "O Funcionário" ## "possui vínculo com um usuário do sistema. Portanto, não pode ser utilizado por outros usuários."
		Return .F.
	EndIf
	// Valida se funcionário atende Facilities (2=Facilities;3=Ambos)
	If !(ST1->T1_TIPATE $ "2/3")
		Help(Nil, Nil, STR0041, Nil, STR0050 + " " + AllTrim(cVerCodUsu) +  " " + STR0052, 1, 0) //"Atenção" ## "O Funcionário" ## "não é um atendente de Facilities, portanto é inválido."
		Return .F.
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetSSAte
Retorna SS sob responsabilidade do atendente

@author Roger Rodrigues
@since 23/08/2012
@version MP10/MP11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fRetSSAte(cCodFun, aEqpRes, cFornec)
	Local i
	Local aListaSS := {}
	Local cCodigo := "", cLoja := ""
	Default cCodFun := __cCodFun
	Default aEqpRes := __aEqpRes
	Default cFornec := ""

	//Le SS do Atendente
	If !Empty(cCodFun)
		If __nAtEq291 == 0 .Or. __nAtEq291 == 1
			dbSelectArea("TUR")
			dbSetOrder(3)
			dbSeek("2"+xFilial("ST1")+Padr(cCodFun,TAMSX3("TUR_CODATE")[1])+Space(TAMSX3("TUR_LOJATE")[1])+DTOS(STOD(""))+Space(TAMSX3("TUR_HRFINA")[1]))
			While !Eof() .and. TUR->TUR_TIPO+TUR->TUR_FILATE+TUR->TUR_CODATE+TUR->TUR_LOJATE+DTOS(TUR->TUR_DTFINA)+TUR->TUR_HRFINA == ;
			"2"+xFilial("ST1")+Padr(cCodFun,TAMSX3("TUR_CODATE")[1])+Space(TAMSX3("TUR_LOJATE")[1])+DTOS(STOD(""))+Space(TAMSX3("TUR_HRFINA")[1])

				aAdd(aListaSS, Array(__LEN_LISTA__))
				aListaSS[Len(aListaSS)][__POS_FILSS__] := TUR->TUR_FILIAL
				aListaSS[Len(aListaSS)][__POS_CODSS__] := TUR->TUR_SOLICI
				dbSelectArea("TUR")
				dbSkip()
			End
		EndIf
		//Le SS da equipe ao qual ele eh responsavel
		If __nAtEq291 == 0 .Or. __nAtEq291 == 2
			If Len(aEqpRes) > 0
				For i:=1 to Len(aEqpRes)
					dbSelectArea("TUR")
					dbSetOrder(3)
					dbSeek("1"+xFilial("TP4")+Padr(aEqpRes[i][1],TAMSX3("TUR_CODATE")[1])+Space(TAMSX3("TUR_LOJATE")[1])+DTOS(STOD(""))+Space(TAMSX3("TUR_HRFINA")[1]))
					While !Eof() .and. TUR->TUR_TIPO+TUR->TUR_FILATE+TUR->TUR_CODATE+TUR->TUR_LOJATE+DTOS(TUR->TUR_DTFINA)+TUR->TUR_HRFINA == ;
					"1"+xFilial("TP4")+Padr(aEqpRes[i][1],TAMSX3("TUR_CODATE")[1])+Space(TAMSX3("TUR_LOJATE")[1])+DTOS(STOD(""))+Space(TAMSX3("TUR_HRFINA")[1])

						aAdd(aListaSS, Array(__LEN_LISTA__))
						aListaSS[Len(aListaSS)][__POS_FILSS__] := TUR->TUR_FILIAL
						aListaSS[Len(aListaSS)][__POS_CODSS__] := TUR->TUR_SOLICI
						dbSelectArea("TUR")
						dbSkip()
					End
				Next i
			EndIf
		EndIf
	Else
		cCodigo := Padr(Substr(cFornec,1,(At("/",cFornec)-1)),TAMSX3("TUR_CODATE")[1])
		cLoja := Padr(Substr(cFornec,(At("/",cFornec)+1)),TAMSX3("TUR_LOJATE")[1])
		//Le SS do Fornecedor
		dbSelectArea("TUR")
		dbSetOrder(3)
		dbSeek("3"+xFilial("SA2")+cCodigo+cLoja+DTOS(STOD(""))+Space(TAMSX3("TUR_HRFINA")[1]))
		While !Eof() .and. TUR->TUR_TIPO+TUR->TUR_FILATE+TUR->TUR_CODATE+TUR->TUR_LOJATE+DTOS(TUR->TUR_DTFINA)+TUR->TUR_HRFINA == ;
		"3"+xFilial("SA2")+cCodigo+cLoja+DTOS(STOD(""))+Space(TAMSX3("TUR_HRFINA")[1])

			aAdd(aListaSS, Array(__LEN_LISTA__))
			aListaSS[Len(aListaSS)][__POS_FILSS__] := TUR->TUR_FILIAL
			aListaSS[Len(aListaSS)][__POS_CODSS__] := TUR->TUR_SOLICI
			dbSelectArea("TUR")
			dbSkip()
		End
	Endif

Return aListaSS
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetTerc
Retorna se SS esta sob responsabilidade de terceiros

@author Roger Rodrigues
@since 23/08/2012
@version MP10/MP11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fRetTerc(cFilSS, cCodSS)
	Local cRet := ""

	dbSelectArea("TUR")
	dbSetOrder(1)
	dbSeek(xFilial("TUR",cFilSS)+cCodSS+"3")
	While !Eof() .and. TUR->TUR_FILIAL+TUR->TUR_SOLICI+TUR->TUR_TIPO == xFilial("TUR",cFilSS)+cCodSS+"3"
		If Empty(TUR->TUR_DTFINA)
			cRet := "X"
			Exit
		Endif
		dbSelectArea("TUR")
		dbSkip()
	End

Return cRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fMarkBrw
Marca o registro no browse

@author Roger Rodrigues
@since 23/08/2012
@version MP10/MP11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fMarkBrw(nOpcao,cMarca)
	Local cAliasMark := aObj291[nOpcao][__POS_ALIAS__]

	dbSelectArea(cAliasMark)
	If !Eof() .And. !Bof()
		RecLock(cAliasMark, .F.)
		(cAliasMark)->OK := If(Empty((cAliasMark)->OK),cMarca,Space(Len((cAliasMark)->OK)))
		MsUnlock(cAliasMark)
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fImgLeg
Retorna qual imagem deve ser mostrada na coluna

@author Roger Rodrigues
@since 23/08/2012
@version MP10/MP11
@return cImagem
/*/
//---------------------------------------------------------------------
Static Function fImgLeg(nLegPos, nOpcao)
	Local i
	Local cImagem := "NG_SEM_INFO"
	Local aArrLeg := {}
	Local cAliasMark := aObj291[nOpcao][__POS_ALIAS__]

	//Marcacao
	If !(cAliasMark)->(Eof())
		If nLegPos == 0
			cImagem := If(Empty((cAliasMark)->OK) , "LBNO" , "LBOK")
		Else
			If nLegPos == 1
				aArrLeg := aObj291[nOpcao][__POS_LEG__]
			ElseIf nLegPos == 2
				aArrLeg := aObj291[nOpcao][__POS_LEG2__]
			ElseIf nLegPos == 3
				aArrLeg := aObj291[nOpcao][__POS_LEG3__]
			Endif
			For i:=1 To Len(aArrLeg)
				If Eval({|| &(aArrLeg[i][1])})
					cImagem := aArrLeg[i][2]
					Exit
				Endif
			Next i
		Endif
	Endif

Return cImagem
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT291OS
Monta browse com OS's relacionadas a SS

@author Roger Rodrigues
@since 06/09/2012
@version MP10/MP11
@return .T./.F.
/*/
//---------------------------------------------------------------------
Function MNT291OS(cFilSS, cCodSS, lVisual)
	Local cOldFil := cFilAnt
	Local aGetArea := fGetArea("TQB")
	Local aAreaSTJ := fGetArea("STJ")
	Local aAreaSTS := fGetArea("STS")
	Local aAreaSX3 := fGetArea("SX3")
	Local aMemory  := NGGetMemory("TQB")
	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA291")
	Local cBemSS

	// Variáveis para a Tabela Temporária
	Local aDBF, aIND, nDBF
	Local cQryAlias, cQryExec
	Local nHist, cHistTbl, cHistCpo
	Local cFldName, nFldCount, nFld
	Local uGet, uSet
	Local aColunas, oColuna

	Local nIndx	  := 0
	Local nFld	  := 0
	Local aFldIdx := {}
	Local aExpDel := { "DTOS" , "DESCEND" }

	Default cFilSS := (aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_FILIAL
	Default cCodSS := (aObj291[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI
	Default lVisual:= .F.

	Private lIncOS := .T.//Variavel para controle da mensagem de inclusao de OS
	Private oBrwOSRelSS
	Private aRotina := {{ STR0053 , "MNTC755((cTRBAlias)->TJ_ORDEM)",0, 2}} //"Visualizar"
	// Variáveis para a Tabela Temporária
	Private cTRBAlias := GetNextAlias()
	Private oTmpTbl

	//-- Valida Atendente
	If !lVisual .And. !fPodeAtender(cFilSS, cCodSS)
		Return .F.
	EndIf

	cBemSS := NGSEEK("TQB",cCodSS,1,"TQB->TQB_CODBEM",cFilSS)

	If Len(Trim(xFilial("TQB"))) >= Len(Trim(xFilial("ST9"))) .and. Len(Trim(cFilSS)) == Len(Trim(cFilAnt))
		cFilAnt := cFilSS
	Endif

	If !lVisual
		aAdd(aRotina, {STR0054 , "MNT291IOS('"+cFilSS+"','"+cCodSS+"',1)", 0, 3}) //"O.S. Corretiva"
		//So habilita botao se encontra manutencao para o bem
		If NGSEEK("TQB",cCodSS,1,"TQB->TQB_TIPOSS",cFilSS) == "B" .and. NGIFDBSEEK("STF",cBemSS,1)
			aAdd(aRotina, {STR0055 , "MNT291IOS('"+cFilSS+"','"+cCodSS+"',2)", 0, 3}) //"O.S. Preventiva"
		Endif
		aAdd(aRotina, {STR0056 , "MNT291ROS('"+cFilSS+"','"+cCodSS+"')", 0, 4}) //"Retorno O.S."
		aAdd(aRotina, {STR0057, "MNT291COS('"+cFilSS+"','"+cCodSS+"')", 0, 4}) //"Cancelar O.S."
	Endif

	aAdd(aRotina, {STR0006 , "U_IMP675(STJ->TJ_ORDEM,STJ->TJ_PLANO,.f.,STJ->TJ_FILIAL,STJ->(RECNO()))"  ,0, 4}) //"Imprimir"
	aAdd(aRotina, {STR0014 , "MNT291LEG", 0, 4}) //"Legenda"

	//Ponto de entrada para adicionar botões no aRotina
	If ExistBlock("MNTA2911")
		aRotina:= ExecBlock("MNTA2911", .F., .F., { aRotina } )
	EndIf

	// Cursor em Espera
	CursorWait()

	// Cria a Tabela Temporária
	dbSelectArea("STJ")
	aDBF := dbStruct()
	aAdd(aDBF, {"TBLORI", "C", 3, 0})
	aIND := {OrdKey(1)}

	oTmpTbl := FWTemporaryTable():New(cTRBAlias, aDBF)
	For nIndx := 1 To Len(aInd)
		aFldIdx := StrTokArr( aInd[nIndx], "+" )

		For nFld := 1 To Len( aFldIdx )
			If ( nPosDel := aScan( aExpDel , { | x | AllTrim( Upper( x ) ) $ Upper( aFldIdx[ nFld ] ) } ) ) > 0
				aFldIdx[ nFld ] := SubStr( aFldIdx[ nFld ] , Len( aExpDel[ nPosDel ] ) + 2 )
				aFldIdx[ nFld ] := SubStr( aFldIdx[ nFld ] , 1 , Len( aFldIdx[ nFld ] ) - 1 )
			EndIf
		Next nFld
		oTmpTbl:AddIndex( "Ind" + cValToChar( nIndx ) , aFldIdx )
	Next nIndx
	oTmpTbl:Create()

	dbSelectArea(cTRBAlias)
	nFldCount := FCount()

	// Alimenta Tabela Temporária
	For nHist := 1 To 2
		cHistTbl := If(nHist == 1, "STJ", "STS")
		cHistCpo := If(nHist == 1, "TJ_", "TS_")

		cQryAlias := GetNextAlias()
		cQryExec  := "SELECT TBL.* FROM " + NGRetX2(cHistTbl,,.F.) + " TBL WHERE TBL." + cHistCpo + "FILIAL = " + ValToSQL(cFilSS) + " AND TBL." + cHistCpo + "SOLICI = " + ValToSQL(cCodSS) + " AND TBL.D_E_L_E_T_ <> '*' "
		cQryExec  := ChangeQuery(cQryExec)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryExec), cQryAlias, .T., .T.)
		dbSelectArea(cQryAlias)
		While !Eof()
			dbSelectArea(cTRBAlias)
			RecLock(cTRBAlias, .T.)
			For nFld := 1 To nFldCount
				dbSelectArea(cTRBAlias)
				cFldName := FieldName(nFld)
				If cFldName != "TBLORI"
					uGet := "('" + cQryAlias + "')->" + If(nHist == 1, cFldName, StrTran(cFldName,"TJ_","TS_"))
					uSet := "('" + cTRBAlias + "')->" + cFldName
					nDBF := aScan(aDBF, {|x| x[1] == cFldName })
					If nDBF > 0 .And. aDBF[nDBF][2] <> "M"
						dbSelectArea(cHistTbl)
						dbSetOrder(1)
						If dbSeek(cFilSS + &("('"+cQryAlias+"')->"+cHistCpo+"ORDEM") + &("('"+cQryAlias+"')->"+cHistCpo+"PLANO"))
							If !Empty(Posicione("SX3",2,aDBF[nDBF][1],"X3_INIBRW"))
								&(uSet) := &(Posicione("SX3",2,aDBF[nDBF][1],"X3_INIBRW"))
							Else
								If aDBF[nDBF][2] == "D"
									&(uSet) := STOD(&(uGet))
								Else
									&(uSet) := &(uGet)
								EndIf
							EndIf
						EndIf
					EndIf
					(cTRBAlias)->TBLORI := cHistTbl
				EndIf
			Next nFld
			MsUnlock(cTRBAlias)
			dbSelectArea(cQryAlias)
			dbSkip()
		End
		(cQryAlias)->( dbCloseArea() )
	Next nHist

	// Cursor Normal
	CursorArrow()

	// Cria o Browse
	oBrwOSRelSS := FwMBrowse():New()
	oBrwOSRelSS:SetAlias(cTRBAlias)
	oBrwOSRelSS:SetFieldFilter( fCreateFil( aDBF ) ) // Permite criação de filtro
	oBrwOSRelSS:SetDescription(STR0011) //"Ordens de Serviço"

	oBrwOSRelSS:lChgAll := .T.//nao apresentar a tela para informar a filial

	// Coluna de Status
	oBrwOSRelSS:AddStatusColumns({|| fOSStatus() }/*bStatus*/, {|| MNT291LEG() }/*bLDblClick*/)
	// Define colunas do Browse
	aColunas := {}
	For nDBF := 1 To Len(aDBF)
		If aDBF[nDBF][1] != "TBLORI"
			// Instancia a Classe
			oColuna := FWBrwColumn():New()

			// Definições Básicas do Objeto
			oColuna:SetAlign(If(Posicione("SX3",2,aDBF[nDBF][1],"X3_TIPO") == "N", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT))
			oColuna:SetEdit(.F.)

			// Definições do Dado apresentado
			oColuna:SetSize(Posicione("SX3",2,aDBF[nDBF][1],"X3_TAMANHO") + Posicione("SX3",2,aDBF[nDBF][1],"X3_DECIMAL"))
			oColuna:SetTitle(X3Titulo())
			oColuna:SetType(Posicione("SX3",2,aDBF[nDBF][1],"X3_TIPO"))
			oColuna:SetPicture(PesqPict(Posicione("SX3",2,aDBF[nDBF][1],"X3_ARQUIVO"), aDBF[nDBF][1] ))

			cSetData := "('" + cTRBAlias + "')->" + AllTrim(aDBF[nDBF][1])
			cSetData := "{|| " + cSetData + " }" // Transforma em Bloco de Código
			oColuna:SetData(&(cSetData))

			aAdd(aColunas, oColuna)
		EndIf
	Next nDBF
	oBrwOSRelSS:SetColumns(aColunas)

	//Aplica Filtro
	oBrwOSRelSS:Activate()
	oBrwOSRelSS:DeActivate()

	// Delete tabela temporária
	oTmpTbl:Delete()//NGDELETRB(cTRBAlias, cTRBArq)

	NGRETURNPRM(aNGBEGINPRM)
	NgRestMemory(aMemory)
	fRestArea(aAreaSX3)
	fRestArea(aAreaSTS)
	fRestArea(aAreaSTJ)
	fRestArea(aGetArea)

	cFilAnt := cOldFil
	If !lVisual .And. IsInCallStack("MNTA291")
		A291RfshSS(__cCallAtend) // Refresh do Browse de S.S.
	EndIf
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fOSStatus
Retorna uma Imagem do RPO para o Status da O.S. no browse.

@author Wagner Sobral de Lacerda
@since 12/11/2012
@version MP10/MP11
@return cImgRPO
/*/
//---------------------------------------------------------------------
Static Function fOSStatus()

	// Variável do Retorno
	Local cImgRPO := ""

	//-- Define Status do registro
	If (cTRBAlias)->TJ_SITUACA == "C"
		cImgRpo := "BR_VERMELHO"
	ElseIf (cTRBAlias)->TJ_SITUACA == "L"
		If (cTRBAlias)->TJ_TERMINO == "S"
			cImgRpo := "BR_VERDE"
		Else
			cImgRpo := "BR_AZUL"
		EndIf
	ElseIf (cTRBAlias)->TJ_SITUACA == "P"
		cImgRpo := "BR_AMARELO"
	EndIf

Return cImgRPO
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT291LEG
Legenda do Status da O.S. no browse.

@author Wagner Sobral de Lacerda
@since 12/11/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT291LEG()

	// Array das Legendas
	Local aLegenda := {	{"BR_AMARELO" , STR0138 }, ; //"Pendente"
	{"BR_AZUL"    , STR0139 }, ; //"Liberada"
	{"BR_VERDE"   , STR0140 }, ; //"Terminada"
	{"BR_VERMELHO", STR0141 } } //"Cancelada"

	//-- Define Status do registro
	NGLegenda(STR0014 , STR0011, aLegenda) //"Legenda" ## "Ordens de Serviço"

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT291OSREL
Retorna string com OS's relacionadas a SS

@author Roger Rodrigues
@since 06/09/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT291OSREL(cFilSS, cCodSS)
	Local aGetArea := STJ->(GetArea())
	Local cOSRelac := "/"

	If AllTrim(GetNewPar("MV_NGMULOS","N")) == "S"
		dbSelectArea("TT7")
		dbSetOrder(1)
		dbSeek(xFilial("TT7",cFilSS)+cCodSS)
		While !Eof() .and. xFilial("TT7",cFilSS)+cCodSS == TT7->TT7_FILIAL+TT7->TT7_SOLICI
			cOsRelac += TT7->TT7_ORDEM+"/"
			dbSelectArea("TT7")
			dbSkip()
		End
	Endif

	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB",cFilSS)+cCodSS)
		cOsRelac += TQB->TQB_ORDEM+"/"
	Endif

	RestArea(aGetArea)
Return cOSRelac
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT291IOS
Chama tela de inclusao de OS

@author Roger Rodrigues
@since 10/09/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT291IOS(cFilSS, cCodSS, nOpcao)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local lCheckList := NGCADICBASE("TTG_CHECK","D","TTG",.F.)
	Local aManOsPr := {}
	Local cCodOS   := ""
	Local cTipoSS  := NGSEEK("TQB",cCodSS,1,"TQB->TQB_TIPOSS",cFilSS)
	Local cBemSS   := NGSEEK("TQB",cCodSS,1,"TQB->TQB_CODBEM",cFilSS)
	Local cObsFlw  := ""
	Local cHorFlw  := ""
	Local aOldRot  := If(Type("aRotina") == "A", aClone(aRotina), Nil)
	Local cFldName, nFldCount, nFld
	Local uGet, uSet
	Default nOpcao := 1//1=Corretiva;2=Preventiva

	//Array de Etapas utilizado no MNTA420 e MNTA410 para etapas do checklist
	Private aArrEtapas := {}

	//Inicialização variáveis AEN
	If ExistBlock("MNTA420T")
		Private aLinhaProd := {}
		ExecBlock("MNTA420T", .F., .F.)
	EndIf

	//-- Define um 'aRotina' para o cadastro
	aRotina := {{"", "PesqBrw",0, 1},;
	{"", "NGCAD01",0, 2},;
	{"", "NGCAD01",0, 3},;
	{"", "NGCAD01",0, 4},;
	{"", "NGCAD01",0, 5,3}}

	//----------
	// Executa
	//----------
	If AllTrim(GetNewPar("MV_NGMULOS","N",cFilSS)) == "N" .and. !Empty(NGSEEK("TQB",cCodSS,1,"TQB->TQB_ORDEM",cFilSS))
		If lIncOS
			ShowHelpDlg(STR0041,; //"Atenção"
			{STR0059},1) //"Não é possível incluir uma Ordem de Serviço para a Solicitação de Serviço, pois a mesma já possui uma Ordem de serviço relacionada."
		Else
			lIncOS := .T.
		Endif
	Else
		lIncOS := .F.
		If lCheckList
			dbSelectArea("TTG")
			dbSetOrder(2)
			If dbSeek(xFilial("TTG")+TQB->TQB_SOLICI)
				While !Eof() .And. xFilial("TTG") == TTG->TTG_FILIAL .And. TTG->TTG_NUMERO == TQB->TQB_SOLICI
					//Tarefa, Etapa e Nome
					aAdd(aArrEtapas, {Padr("0",TAMSX3("T5_TAREFA")[1]), TTG->TTG_ETAPA, NGSEEK("TPA",TTG->TTG_ETAPA,1,"TPA_DESCRI")} )
					dbSelectArea("TTG")
					dbSkip()
				End
			EndIf
		EndIf
		Begin Transaction

			// Cadastro da O.S.
			If nOpcao == 1
				cCadastro := OemtoAnsi(STR0054) //"O.S. Corretiva"
				cCodOS := NG420INC("STJ",1,3,cBemSS,,cTipoSS,.T.)
			Else
				dbSelectArea("ST9")
				dbSetOrder(1)
				dbSeek(xFilial("ST9")+cBemSS)
				aManOsPr := MNT902IOSPR()
				If aManOsPr[1]
					dbSelectArea("STF")
					dbSetOrder(1)
					dbSeek(xFilial("STF")+ST9->T9_CODBEM+aManOsPr[2]+aManOsPr[3])
					cCodOS := NG410INC("STF",1,3,.T.)
				EndIf
			Endif
			// Relaciona a O.S. no TRB
			If !Empty(cCodOS)
				dbSelectArea("STJ")
				dbSetOrder(1)
				If dbSeek(xFilial("STJ")+cCodOS)
					dbSelectArea(cTRBAlias)
					dbSetOrder(1)
					If !dbSeek(xFilial("STJ")+cCodOS)
						RecLock(cTRBAlias, .T.)
					Else
						RecLock(cTRBAlias, .F.)
					EndIf
					nFldCount := FCount()
					For nFld := 1 To nFldCount
						cFldName := FieldName(nFld)
						If cFldName == "TBLORI"
							uGet := "'STJ'"
						Else
							uGet := "STJ->" + cFldName
						EndIf
						uSet := "('" + cTRBAlias + "')->" + cFldName
						&(uSet) := &(uGet)
					Next nFld
					MsUnlock(cTRBAlias)
				EndIf
			EndIf

			//Relaciona a OS na SS
			If !Empty(cCodOS)
				dbSelectArea("STJ")
				dbSetOrder(1)
				If dbSeek(xFilial("STJ")+cCodOS)
					If AllTrim(GetNewPar("MV_NGMULOS","N",cFilSS)) == "S"
						dbSelectArea("TT7")
						dbSetOrder(1)
						If !dbSeek(xFilial("TT7",cFilSS)+cCodSS+STJ->TJ_ORDEM)
							Reclock("TT7",.T.)
							TT7->TT7_FILIAL := xFilial("TT7",cFilSS)
							TT7->TT7_SOLICI := TQB->TQB_SOLICI
							TT7->TT7_ORDEM  := STJ->TJ_ORDEM
							TT7->TT7_PLANO  := STJ->TJ_PLANO
							TT7->TT7_SITUAC := STJ->TJ_SITUACA
							TT7->TT7_TERMIN := STJ->TJ_TERMINO
							MsUnlock("TT7")
						EndIf
					Else
						dbSelectArea("TQB")
						dbSetOrder(1)
						If dbSeek(xFilial("TQB",cFilSS)+cCodSS)
							RecLock("TQB",.F.)
							TQB->TQB_ORDEM := STJ->TJ_ORDEM
							MsUnlock("TQB")
						Endif
					EndIf

					// Atualiza o vínculo da S.S. na O.S.
					RecLock("STJ", .F.)
					STJ->TJ_SOLICI := TQB->TQB_SOLICI
					MsUnlock("STJ")
					//Ponto de entrada que possibilita alterar o conteúdo de qualquer campo da STJ
					If ExistBlock("MNTA291A")
						ExecBlock("MNTA291A", .F., .F., {STJ->TJ_ORDEM,STJ->TJ_PLANO})
					EndIf

					//Verifica se está parametrizado para envio de WF
					If AllTrim(GetNewPar("MV_NGSSWRK","N")) == "S"
						MNW29501(TQB->TQB_CDSOLI)
					EndIf

					// Grava Follow-Up
					cObsFlw := STR0060 + " " + If(nOpcao == 1, STR0061, STR0062) + ": " + cCodOS + "." //"Geração de O.S." ## "Corretiva" ## "Preventiva"
					cHorFlw := Time()
					MNT280GFU(cCodSS/*cCodSS*/, "08"/*cCodFlwUp*/, cObsFlw/*cObservacao*/, STJ->TJ_DTORIGI/*dDtIFlwUp*/, cHorFlw/*cHrIFlwUp*/, ;
					STJ->TJ_DTORIGI/*dDtFFlwUp*/, cHorFlw/*cHrFFlwUp*/, /*cUsuFlwUp*/, __cCodFun/*cCodFun*/, xFilial("ST1")/*cCodFilAte*/)
				Endif
			Endif

		End Transaction
	Endif

	NGRETURNPRM(aNGBEGINPRM)
	If Type("aOldRot") == "A"
		aRotina := aClone(aOldRot)
	EndIf
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT291ROS
Chama tela para Retorno da O.S.

@author Roger Rodrigues
@since 10/09/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT291ROS(cFilSS, cCodSS)
	Local aGetArea := (cTRBAlias)->(GetArea())
	Local aNGBEGINPRM := NGBEGINPRM()
	Local lOk := .F.
	Local nSaveRec := 0

	If (cTRBAlias)->TBLORI == "STS"
		ShowHelpDlg(STR0041,{STR0063},1,{STR0064}) //"Atenção" ## "Esta Ordem de Serviço é pertencente ao histórico (tabela STS) e portanto está bloqueada para qualquer alteração." ## "Selecione uma outra Ordem de Serviço."
	Else
		dbSelectArea("STJ")
		dbSetOrder(1)
		If dbSeek((cTRBAlias)->TJ_FILIAL + (cTRBAlias)->TJ_ORDEM + (cTRBAlias)->TJ_PLANO)
			nSaveRec := RecNo()
			If STJ->TJ_TERMINO == "S"
				ShowHelpDlg(STR0041,{STR0065},1,{STR0064}) //"Atenção" ## "Esta Ordem de Serviço já está terminada." ## "Selecione uma outra Ordem de Serviço."
			ElseIf STJ->TJ_SITUACA == "C"
				ShowHelpDlg(STR0041,{STR0066},1,{STR0064}) //"Atenção" ## "Esta Ordem de Serviço já está cancelada." ## "Selecione uma outra Ordem de Serviço."
			Else
				lOk := .T.
				MsgRun(STR0067, STR0068, {|| MNTA435(STJ->TJ_ORDEM, 1) }) //"Carregando Retorno de O.S., aguarde..." ## "Carregando"
			EndIf
		Else
			ShowHelpDlg(STR0041,{STR0069},1,{STR0064}) //"Atenção" ## "Não foi possível encontrar o cadastro desta Ordem de Serviço." ## "Selecione uma outra Ordem de Serviço."
		EndIf
	EndIf
	// Atualiza TRB
	If lOk
		dbSelectArea("STJ")
		dbGoTo(nSaveRec)
		RestArea(aGetArea)
		RecLock(cTRBAlias, .F.)
		(cTRBAlias)->TJ_SITUACA := STJ->TJ_SITUACA
		(cTRBAlias)->TJ_TERMINO := STJ->TJ_TERMINO
		MsUnlock(cTRBAlias)
	EndIf

	NGRETURNPRM(aNGBEGINPRM)
	RestArea(aGetArea)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT291COS
Chama tela para Cancelar da O.S.

@author Wagner Sobral de Lacerda
@since 12/11/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT291COS(cFilSS, cCodSS)
	Local aGetArea := (cTRBAlias)->(GetArea())
	Local aNGBEGINPRM := NGBEGINPRM()
	Local lOk := .F.
	Local nSaveRec := 0

	If (cTRBAlias)->TBLORI == "STS"
		ShowHelpDlg(STR0041,{STR0070},1,{STR0064}) //"Atenção" ## "Esta Ordem de Serviço é pertencente ao histórico (tabela STS) e portanto está bloqueada para qualquer alteração." ## "Selecione uma outra Ordem de Serviço."
	ElseIf (cTRBAlias)->TBLORI == "STJ"
		dbSelectArea("STJ")
		dbSetOrder(1)
		If dbSeek((cTRBAlias)->TJ_FILIAL + (cTRBAlias)->TJ_ORDEM + (cTRBAlias)->TJ_PLANO)
			nSaveRec := RecNo()
			If STJ->TJ_TERMINO == "S"
				ShowHelpDlg(STR0041,{STR0065},1,{STR0064}) // "Atenção" ## "Esta Ordem de Serviço já está terminada." ##  "Selecione uma outra Ordem de Serviço."
			ElseIf STJ->TJ_SITUACA == "C"
				ShowHelpDlg(STR0041,{STR0066},1,{STR0064}) //"Atenção" ## "Esta Ordem de Serviço já está cancelada." ## "Selecione uma outra Ordem de Serviço."
			Else
				lOk := ( NG400EXC("STJ", nSaveRec, 5) == 2 )
			EndIf
		Else
			ShowHelpDlg(STR0041,{STR0069},1,{STR0064}) // "Atenção" ## "Não foi possível encontrar o cadastro desta Ordem de Serviço." ## "Selecione uma outra Ordem de Serviço."
		EndIf
	Endif
	// Atualiza TRB
	If lOk
		dbSelectArea("STJ")
		dbGoTo(nSaveRec)
		RestArea(aGetArea)
		RecLock(cTRBAlias, .F.)
		(cTRBAlias)->TJ_SITUACA := STJ->TJ_SITUACA
		(cTRBAlias)->TJ_TERMINO := STJ->TJ_TERMINO
		MsUnlock(cTRBAlias)
	EndIf

	NGRETURNPRM(aNGBEGINPRM)
	RestArea(aGetArea)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} A291CARGA
Mostra carga de atendentes da equipe

@author Roger Rodrigues
@since 12/09/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function A291CARGA(cFilPos, aEquipes, cFuncio, cFornec)
	Local aGetArea := STJ->(GetArea())
	Local aMemory  := NGGetMemory("TQB")
	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA291")
	Local cEquipe  := ""
	Local cTitCarga := ""
	Local i, nScan := 0
	Local cOldFil := cFilAnt
	Local cAuxAlign := ""
	Local aLegBrwSSi := {2,3,4} //Mostra legendas de criticidade, prioridade e terceiros

	Local c_Filt291 := If(ValType(__cFilt291) == "C", __cFilt291, Nil)
	Local n_AtEq291 := If(ValType(__nAtEq291) == "N", __nAtEq291, Nil)

	//Variaveis de tamanho de tela e objetos
	Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}
	Local oFont16 := TFont():New("Arial",,-16,,.T.)

	//Variaveis do combo
	Local oGetSearch, oCBoxSearch, oBtnSearch, cCombo, cGetSearch := Space(100)

	//Objetos principais
	Local oDlgCarga, oPanel, oSplitHor, oPnlBot
	Local oSplitVert, oPanelLeft, oPanelRight

	//Objetos do Topo
	Local oPanelT1, oPanelT2, oPanelTBtn, oBtnVisual, oBtnLegend

	//Botoes para esconder paineis
	Local oHideLeft, oHideRight

	//Objetos do Rodape
	//Parte Esquerda
	Local oPanelT3, oPanelLBtn, oBtnTransf, oBtnLeg

	//Parte Direita
	Local oPanelRCont, oPanelT4, oPanelRBtn, oPanelEnc
	Local oBtnQuest, oBtnVis, oBtnUser, oBtnDet

	// Objetos do Totalizador
	Local oPanelTot

	// [LGPD] Caso o usuário não possua acesso ao(s) campo(s), deve-se ofuscá-lo(s)
	Local lOfuscar := FindFunction( 'FWPDCanUse' ) .And. FwPdCanUse( .T. );
					.And. Len( FwProtectedDataUtil():UsrAccessPDField( __CUSERID, { 'T1_NOME' } ) ) == 0	
		
	Default cFilPos  := __cOldFil
	Default aEquipes := {}
	Default cFuncio  := ""
	Default cFornec  := ""

	//Objetos que serao desabilitados
	Private oPanelLCont, oPnlTop
	Private oBtnAltSS, oBtnConf, oBtnCanc

	//Titulo da tela
	Private cCadastro := STR0071 //"Carga de Atendimento"

	//Variaveis da Enchoice
	Private oEncSS
	Private aTela := {}, aGets := {}
	Private aRotina := {{"", "PesqBrw",0, 1},;
	{"", "NGCAD01",0, 2},;
	{"", "NGCAD01",0, 3},;
	{"", "NGCAD01",0, 4},;
	{"", "NGCAD01",0, 5,3}}

	Private aObj291 := Array(__LEN_MARK__,__LEN_PROP__)

	// Definição de variáveis estáticas
	If ValType(__cFilt291) == "C"
		__cFilt291 := "" // Limpa
	EndIf
	If ValType(__nAtEq291) == "N"
		__nAtEq291 := 0 // Limpa
	EndIf

	//Retorna codigo da equipe
	If Len(aEquipes) > 1
		cEquipe := fSelEquipe(aEquipes)
	ElseIf Len(aEquipes) == 1
		cEquipe := aEquipes[1][1]
	Endif

	If Empty(cEquipe) .and. Empty(cFuncio) .and. Empty(cFornec)
		NGRETURNPRM(aNGBEGINPRM)
		NgRestMemory(aMemory)
		RestArea(aGetArea)
		Return .F.
	Endif

	If !Empty(cFilPos)
		cFilAnt := cFilPos
		__cFilPos := cFilPos
	Endif

	//Definicao de tamanho de tela e objetos
	aSize := MsAdvSize(,.f.,430)
	Aadd(aObjects,{030,030,.t.,.t.})
	Aadd(aObjects,{060,060,.t.,.t.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	//Cria estrutura de arquivo temporario e listbox
	fCreateTRB(__OPC_TQB2__)

	If !Empty(cEquipe)
		//Cria estrutura de arquivo temporario e listbox
		fCreateTRB(__OPC_ST1__)

		//Carrega Arquivo temporario
		Processa({|| fLoadTRB(__OPC_ST1__,"ST1->T1_EQUIPE == '"+cEquipe+"'")},STR0002,STR0072) // "Aguarde..." ## "Processando Atendentes..."
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta tela de Carga                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Define MsDialog oDlgCarga Title OemToAnsi(cCadastro) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel
	oDlgCarga:lMaximized := .T.

	//Define painel principal
	oPanel := TPanel():New(0,0,,oDlgCarga,,,,,,aSize[5],aSize[6],.F.,.F.)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	oSplitHor := TSplitter():New(01,01,oPanel,10,10)
	oSplitHor:SetOrient(1)
	oSplitHor:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel dos Atendentes               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPnlTop := TPanel():New(,,,oSplitHor,,,,aNGColor[1],aNGColor[2],, If(!Empty(cEquipe),aPosObj[1,3],32), .F., .F. )
	oPnlTop:Align := CONTROL_ALIGN_TOP

	oPanelT1:=TPanel():New(00,00,,oPnlTop,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPanelT1:nHeight := 30
	oPanelT1:Align := CONTROL_ALIGN_TOP

	If !Empty(cEquipe)
		cTitCarga := STR0073+Trim(cEquipe)+" - "+Trim(NGSEEK("TP4",cEquipe,1,"TP4->TP4_DESCRI")) //"Equipe: "
	ElseIf !Empty(cFuncio)
		cTitCarga := STR0074+Trim(cFuncio)+" - "+Trim(NGSEEK("ST1",cFuncio,1,"ST1->T1_NOME")) //"Atendente: "
	Else
		cTitCarga := STR0075+Trim(cFornec)+" - "+Trim(NGSEEK("SA2",Padr(Substr(cFornec,1,(At("/",cFornec)-1)),TAMSX3("A2_COD")[1])+; //"Terceiro: "
		Padr(Substr(cFornec,(At("/",cFornec)+1)),TAMSX3("A2_LOJA")[1]),1,"SA2->A2_NOME"))
	Endif

	@ 003,013 Say cTitCarga Of oPanelT1 Color aNGColor[1] Pixel Font oFont16

	oPanelT2:=TPanel():New(00,00,,oPnlTop,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	If !Empty(cEquipe)
		oPanelT2:nHeight := 25
	Else
		oPanelT2:nHeight := 30
	Endif
	oPanelT2:Align := CONTROL_ALIGN_TOP

	If !Empty(cEquipe)
		@ 003,013 Say OemToAnsi(STR0076) Of oPanelT2 Color aNGColor[1] Pixel //"Atendentes"

		oPanelTBtn:=TPanel():New(00,00,,oPnlTop,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
		oPanelTBtn:Align := CONTROL_ALIGN_LEFT

		oBtnVisual  := TBtnBmp():NewBar("ng_ico_visualizar","ng_ico_visualizar",,,,{|| fVisualizar((aObj291[__OPC_ST1__][__POS_ALIAS__])->T1_CODFUNC)},,oPanelTBtn,,,STR0077,,,,,"") //"Visualizar Atendente"
		oBtnVisual:Align    := CONTROL_ALIGN_TOP
		oBtnLegend  := TBtnBmp():NewBar("ng_ico_lgndos","ng_ico_lgndos",,,,{|| A291LEGEND(2, __OPC_ST1__, __POS_LEG__) },,oPanelTBtn,,,STR0014,,,,,"") //"Legenda"
		oBtnLegend:Align    := CONTROL_ALIGN_TOP


		aObj291[__OPC_ST1__][__POS_OBJ__] := TCBrowse():New(0,0,500,500,,,,oPnlTop,,,,,,,,,,,,,aObj291[__OPC_ST1__][__POS_ALIAS__],.T.,,,,.T.,.T.)

		aObj291[__OPC_ST1__][__POS_OBJ__]:Align := CONTROL_ALIGN_ALLCLIENT
		aObj291[__OPC_ST1__][__POS_OBJ__]:bChange := {|| fLoadCarga(cFilPos, cEquipe, (aObj291[__OPC_ST1__][__POS_ALIAS__])->T1_CODFUNC) }
		If lOfuscar
			aObj291[__OPC_ST1__][__POS_OBJ__]:aObfuscatedCols := {.F., .F., .T., .F.}
		EndIf
		//Adiciona Colunas
		// Legenda Membro/Responsável
		aObj291[__OPC_ST1__][__POS_OBJ__]:AddColumn(TCColumn():New("", {|| fImgLeg(1,__OPC_ST1__) } ,,,,,30,.T.,.F.,,,,.T.,))
		// Outras Colunas
		For i := 1 to Len(aObj291[__OPC_ST1__][__POS_FIELDS__])
			cAuxAlign := "LEFT"
			If ( nScan := aScan(aObj291[__OPC_ST1__][__POS_DBF__], {|x| AllTrim(x[1]) == aObj291[__OPC_ST1__][__POS_FIELDS__][i][1] }) ) > 0
				cAuxAlign := If(aObj291[__OPC_ST1__][__POS_DBF__][nScan][2] == "N", "RIGHT", cAuxAlign)
			EndIf
			aObj291[__OPC_ST1__][__POS_OBJ__]:AddColumn( TCColumn():New(aObj291[__OPC_ST1__][__POS_FIELDS__][i][3],;
			&("{|| ('"+aObj291[__OPC_ST1__][__POS_ALIAS__]+"')->"+aObj291[__OPC_ST1__][__POS_FIELDS__][i][1]+" }"),;
			aObj291[__OPC_ST1__][__POS_FIELDS__][i][4],,,cAuxAlign,;
			If(aObj291[__OPC_ST1__][__POS_FIELDS__][i][2] <= 8,35,Nil),.F. ))
		Next i

		oPanelTot := TPanel():New(0,0,,oPnlTop,,,,aNGColor[1],aNGColor[2],0,012,.f.,.f.)
		oPanelTot:Align := CONTROL_ALIGN_BOTTOM

		__aTotal[__nTotEquipe] := TSay():New(02, 12, {|| A296TotTRB(aObj291[__OPC_ST1__][__POS_ALIAS__]) },oPanelTot,,TFont():New(,,,,.T.),,,,.T.,aNGColor[1],,200,20)

	Else
		oBtnVisual := TButton():New(01,013,STR0053,oPanelT2,{|| fVisualizar(cFuncio, cFornec) },49,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Visualizar"
		oBtnVisual:SetCss("QPushButton{ border-radius: 3px;border: 1px solid #000000; background-color: #F0F0F0;  }")
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel das inconsistencias          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPnlBot := TPanel():New(,,,oSplitHor,,,,,CLR_WHITE,CLR_WHITE, aPosObj[2,3], .F., .F. )
	oPnlBot:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Estrutura de Baixo           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSplitVert := TSplitter():New(01,01,oPnlBot,10,10)
	oSplitVert:SetOrient(0)
	oSplitVert:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Parte Esquerda - Browse SS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelLeft := TPanel():New(0,0,,oSplitVert,,,,,,10,10,.F.,.F.)
	oPanelLeft:nWidth := (aSize[5]/2)
	oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelLCont := TPanel():New(0,0,,oPanelLeft,,,,,,10,10,.F.,.F.)
	oPanelLCont:nWidth := (aSize[5]/2)
	oPanelLCont:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelLCont:CoorsUpdate()

	oPanelT3:=TPanel():New(00,00,,oPanelLCont,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPanelT3:nHeight := 25
	oPanelT3:Align := CONTROL_ALIGN_TOP

	@ 003,013 Say OemToAnsi(STR0004) Of oPanelT3 Color aNGColor[1] Pixel //"Solicitações"

	oPanelLBtn:=TPanel():New(00,00,,oPanelLCont,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPanelLBtn:Align := CONTROL_ALIGN_LEFT

	oBtnTransf  := TBtnBmp():NewBar("ng_os_transf","ng_os_transf",,,,{|| fTransfSS((aObj291[__OPC_TQB2__][__POS_ALIAS__])->TQB_FILIAL,(aObj291[__OPC_TQB2__][__POS_ALIAS__])->TQB_SOLICI, cFilPos, cEquipe, cFuncio, cFornec,__cCallDistr) },,oPanelLBtn,,,STR0078,,,,,"") //"Transferir Atendimento"
	oBtnTransf:Align  := CONTROL_ALIGN_TOP
	If !MNT280REST("TUA_TRANSS")
		oBtnTransf:Disable()
	Endif
	oBtnLeg  := TBtnBmp():NewBar("ng_ico_lgndos","ng_ico_lgndos",,,,{|| A291LEGEND(1,,,aLegBrwSSi)},,oPanelLBtn,,,STR0014,,,,,"") //"Legenda"
	oBtnLeg:Align	:= CONTROL_ALIGN_TOP

	oPanelList := TPanel():New(0,0,,oPanelLCont,,,,,,10,10,.F.,.F.)
	oPanelList:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria Panel com opcoes de pesquisa no MsSelect³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelPesq := TPanel():New(0,0,,oPanelList,,,,,CLR_WHITE,0,15,.f.,.f.)
	oPanelPesq:Align := CONTROL_ALIGN_TOP

	oCBoxSearch := TComboBox():New(02,02,{|u| If(PCount()>0,cCombo:=u,cCombo)},aObj291[__OPC_TQB2__][__POS_DESIND__],100,20,oPanelPesq,,;
	{|| fSeekReg(__OPC_TQB2__,oCBoxSearch:nAt,@cGetSearch,.F.)},,,,.T.,,,,,,,,,"cCombo")
	oGetSearch  := TGet():New( 02,105,{|u| If(PCount()>0,cGetSearch:=u,cGetSearch)}, oPanelPesq,096,008,,,;
	0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cGetSearch,,,, )
	oBtnSearch  := TButton():New( 002, 202, STR0015,oPanelPesq,{|| fSeekReg(__OPC_TQB2__,oCBoxSearch:nAt,Trim(cGetSearch))},; //"Buscar"
	35,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	oCBoxSearch:Select((aObj291[__OPC_TQB2__][__POS_ALIAS__])->(IndexOrd()))

	aObj291[__OPC_TQB2__][__POS_OBJ__] := TCBrowse():New(0,0,1500,1500,,,,oPanelList,,,,,,,,,,,,,aObj291[__OPC_TQB2__][__POS_ALIAS__],.T.,,,,.T.,.T.)

	aObj291[__OPC_TQB2__][__POS_OBJ__]:Align := CONTROL_ALIGN_ALLCLIENT
	aObj291[__OPC_TQB2__][__POS_OBJ__]:bChange := {|| fAtuEnc(__OPC_TQB2__)}

	//Adiciona Colunas
	//Legenda Criticidade
	aObj291[__OPC_TQB2__][__POS_OBJ__]:AddColumn(TCColumn():New( STR0016 , {|| fImgLeg(1,__OPC_TQB2__) } ,,,,,30,.T.,.F.,,,,.T.,)) //"Criticidade"
	//Legenda Prioridade
	aObj291[__OPC_TQB2__][__POS_OBJ__]:AddColumn(TCColumn():New( STR0017 , {|| fImgLeg(2,__OPC_TQB2__) } ,,,,,30,.T.,.F.,,,,.T.,)) //"Prioridade"
	//Legenda Terceiros
	aObj291[__OPC_TQB2__][__POS_OBJ__]:AddColumn(TCColumn():New( STR0018 , {|| fImgLeg(3,__OPC_TQB2__) } ,,,,,20,.T.,.F.,,,,.T.,)) //"Terc."

	//Adiciona Colunas
	For i := 1 to Len(aObj291[__OPC_TQB2__][__POS_FIELDS__])
		If aObj291[__OPC_TQB2__][__POS_FIELDS__][i][1] != "OK"
			aObj291[__OPC_TQB2__][__POS_OBJ__]:AddColumn( TCColumn():New(aObj291[__OPC_TQB2__][__POS_FIELDS__][i][3],;
			&("{|| ('"+aObj291[__OPC_TQB2__][__POS_ALIAS__]+"')->"+aObj291[__OPC_TQB2__][__POS_FIELDS__][i][1]+" }"),;
			aObj291[__OPC_TQB2__][__POS_FIELDS__][i][4],,,"LEFT",;
			If(aObj291[__OPC_TQB2__][__POS_FIELDS__][i][2] <= 8,35,Nil),.F. ))
		Endif
	Next i

	oPanelTot := TPanel():New(0,0,,oPanelLCont,,,,aNGColor[1],aNGColor[2],0,012,.f.,.f.)
	oPanelTot:Align := CONTROL_ALIGN_BOTTOM

	__aTotal[__nTotCarga] := TSay():New(02, 12, {|| A296TotTRB(aObj291[__OPC_TQB2__][__POS_ALIAS__], .T.) },oPanelTot,,TFont():New(,,,,.T.),,,,.T.,aNGColor[1],,200,20)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte dir.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideRight := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_right", , , , {|| fShowHide(1,oPanelRight,oHideRight)}, oPanelLeft, OemToAnsi(STR0021), , .T.) //"Expandir Browse"
	oHideRight:Align := CONTROL_ALIGN_RIGHT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Parte Direita                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelRight := TPanel():New(0,0,,oSplitVert,,,,,,10,10,.F.,.F.)
	oPanelRight:nHeight := (aSize[5]/2)
	oPanelRight:Align   := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte esq.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideLeft := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_left", , , , {|| fShowHide(2,oPanelLeft,oHideLeft)}, oPanelRight, OemToAnsi(STR0022), , .T.) //"Esconder Browse"
	oHideLeft:Align := CONTROL_ALIGN_LEFT

	oPanelRCont := TPanel():New(0,0,,oPanelRight,,,,,,10,10,.F.,.F.)
	oPanelRCont:nWidth := (aSize[5]/2)
	oPanelRCont:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelRCont:CoorsUpdate()

	oPanelT4:=TPanel():New(00,00,,oPanelRCont,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPanelT4:nHeight := 25
	oPanelT4:Align := CONTROL_ALIGN_TOP

	@ 003,013 Say OemToAnsi(STR0023) Of oPanelT4 Color aNGColor[1] Pixel //"Detalhes da Solicitação"

	oPanelRBtn:=TPanel():New(00,00,,oPanelRCont,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPanelRBtn:Align := CONTROL_ALIGN_LEFT

	oBtnAltSS  := TBtnBmp():NewBar("ng_ico_altss","ng_ico_altss",,,,{|| fAtuEnc(__OPC_TQB2__,.T.,4)},,oPanelRBtn,,,STR0024,,,,,"") //"Alterar Solicitação"
	oBtnAltSS:Align  := CONTROL_ALIGN_TOP

	bGravaEnc := {|| fGravaEnc(__OPC_TQB2__)}
	oBtnConf  := TBtnBmp():NewBar("ng_ico_confirmar","ng_ico_confirmar",,,,bGravaEnc,,oPanelRBtn,,,STR0025,,,,,"") //"Confirmar"
	oBtnConf:Align  := CONTROL_ALIGN_TOP
	oBtnConf:lVisible := .F.

	oBtnCanc  := TBtnBmp():NewBar("ng_ico_cancelar","ng_ico_cancelar",,,,{|| fDisable(.F.,,__OPC_TQB2__) },,oPanelRBtn,,,STR0026,,,,,"") //"Cancelar"
	oBtnCanc:Align  := CONTROL_ALIGN_TOP
	oBtnCanc:lVisible := .F.

	oBtnQuest  := TBtnBmp():NewBar("ng_ico_questionario","ng_ico_questionario",,,,{|| fQuestiSS(__OPC_TQB2__)},,oPanelRBtn,,,STR0027,,,,,"") //"Questionário de Sintomas"
	oBtnQuest:Align  := CONTROL_ALIGN_TOP

	oBtnDet := TBtnBmp():NewBar("ng_ico_tarefas","ng_ico_tarefas",,,,{|| fVisualSS(__OPC_TQB2__)},,oPanelRBtn,,,STR0028,,,,,"") //"Detalhamento Solicitação"
	oBtnDet:Align  := CONTROL_ALIGN_TOP

	oBtnUser  := TBtnBmp():NewBar("ng_ico_info","ng_ico_info",,,,{|| fUserSS(__OPC_TQB2__)},,oPanelRBtn,,,STR0029,,,,,"") //"Informações do Solicitante"
	oBtnUser:Align  := CONTROL_ALIGN_TOP

	oBtnVis  := TBtnBmp():NewBar("ng_ico_conhecimento","ng_ico_conhecimento",,,,{|| fMsDocSS(__OPC_TQB2__)},,oPanelRBtn,,,STR0030,,,,,"") //"Conhecimento"
	oBtnVis:Align  := CONTROL_ALIGN_TOP

	oPanelEnc:=TPanel():New(00,00,,oPanelRCont,,,,,,200,200,.F.,.F.)
	oPanelEnc:Align := CONTROL_ALIGN_ALLCLIENT

	//Criacao das Variaveis da Enchoice
	dbSelectArea("TQB")
	dbSetOrder(1)
	dbSeek(xFilial("TQB"))
	MNT280CPO(2,2)
	MNT280REG(0, a280Relac, a280Memos)

	oEncSS := MsMGet():New("TQB",TQB->(Recno()),4,,,,a280Choice,{0,0,500,500},,3,,,,oPanelEnc)
	oEncSS:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega solicitacoes de servico    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cFuncio) .or. !Empty(cFornec)
		fLoadCarga(cFilPos, cEquipe, cFuncio, cFornec)
	Endif

	Activate MsDialog oDlgCarga On Init (EnchoiceBar(oDlgCarga,{|| oDlgCarga:End()},{|| oDlgCarga:End()})) Centered

	//Deleta Arquivo temporario
	If !Empty(cEquipe)
		NGDELETRB(aObj291[__OPC_ST1__][__POS_ALIAS__],aObj291[__OPC_ST1__][__POS_ARQ__])
	Endif

	//Deleta Arquivo temporario
	NGDELETRB(aObj291[__OPC_TQB2__][__POS_ALIAS__],aObj291[__OPC_TQB2__][__POS_ARQ__])

	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)
	NgRestMemory(aMemory)
	RestArea(aGetArea)
	If ValType(c_Filt291) == "C"
		__cFilt291 := c_Filt291
	EndIf
	If ValType(n_AtEq291) == "N"
		__nAtEq291 := n_AtEq291
	EndIf
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fSelEquipe
Monta tela para selecionar equipe

@author Roger Rodrigues
@since 13/09/2012
@version MP10/MP11
@return cEquipe
/*/
//---------------------------------------------------------------------
Static Function fSelEquipe(aEquipes)
	Local cEquipe  := ""
	Local oDlgEqp, oPnlEqp, oPnlLeg, oListEqp

	Define MsDialog oDlgEqp From 0,0 To 250,540 Title OemToAnsi(STR0079) Pixel //"Equipes"

	oPnlEqp := TPanel():New(0,0,,oDlgEqp,,,,,,200,200,.F.,.F.)
	oPnlEqp:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlLeg := TPanel():New(0,0,,oPnlEqp,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPnlLeg:Align := CONTROL_ALIGN_TOP
	oPnlLeg:nHeight := 25

	@ 002,002 Say OemToAnsi(STR0080) Of oPnlLeg Color aNGColor[1] Pixel //"Selecione a Equipe desejada e confirme a tela:"

	oListEqp := TCBrowse():New(0,0,500,500,,{RetTitle("TP4_CODIGO"),RetTitle("TP4_DESCRI")},,oPnlEqp,,,,,,,,,,,,,,.T.,,,,.T.,.T.)

	oListEqp:SetArray( aEquipes ) // Seta vetor para a browse
	oListEqp:Align := CONTROL_ALIGN_ALLCLIENT
	oListEqp:bLine := {|| { aEquipes[oListEqp:nAt,1],aEquipes[oListEqp:nAt,2]}}
	oListEqp:bLDblClick := {||cEquipe := aEquipes[oListEqp:nAt,1],oDlgEqp:End()}

	Activate MsDialog oDlgEqp ON INIT EnchoiceBar(oDlgEqp,{||cEquipe := aEquipes[oListEqp:nAt,1],oDlgEqp:End()},{||oDlgEqp:End()}) Centered

Return cEquipe
//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadCarga
Carrega a carga de ss do atendente

@author Roger Rodrigues
@since 13/09/2012
@version MP10/MP11
@return cEquipe
/*/
//---------------------------------------------------------------------
Static Function fLoadCarga(cFilPos, cEquipe, cFuncio, cFornec)

	If !Empty(cFilPos)
		cFilAnt := cFilPos
	Endif

	dbSelectArea(aObj291[__OPC_TQB2__][__POS_ALIAS__])
	ZAP

	Processa({|| fLoadTRB(__OPC_TQB2__, , cFuncio, cEquipe, cFornec)},STR0002,STR0003) //"Aguarde..." ## "Processando Solicitações..."

	aObj291[__OPC_TQB2__][__POS_OBJ__]:Refresh(.T.)

	If (aObj291[__OPC_TQB2__][__POS_ALIAS__])->(Eof())
		Eval({|| fAtuEnc(__OPC_TQB2__,.F.,0)})
	Else
		Eval(aObj291[__OPC_TQB2__][__POS_OBJ__]:bChange)
	Endif

	If ValType(__aTotal[__nTotEquipe]) == "O"
		__aTotal[__nTotEquipe]:Refresh()
	EndIf
	If ValType(__aTotal[__nTotCarga]) == "O"
		__aTotal[__nTotCarga]:Refresh()
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fVisualizar
Carrega visualizacao do funcionario

@author Roger Rodrigues
@since 18/09/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fVisualizar(cCodFunc, cFornec)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local cOldFil := cFilAnt
	Local cCodigo, cLoja
	Private cCadastro := ""

	cFilAnt := __cFilPos

	If !Empty(cCodFunc)
		cCadastro := STR0081 //"Cadastro de Funcionários"
		dbSelectArea("ST1")
		dbSetOrder(1)
		If dbSeek(xFilial("ST1")+cCodFunc)
			FWExecView( cCadastro , 'MNTA020' , MODEL_OPERATION_VIEW , , { || .T. } )
		Endif
	Else
		cCadastro := STR0082 //"Cadastro de Fornecedores"
		cCodigo := Padr(Substr(cFornec,1,(At("/",cFornec)-1)),TAMSX3("A2_COD")[1])
		cLoja := Padr(Substr(cFornec,(At("/",cFornec)+1)),TAMSX3("A2_LOJA")[1])
		dbSelectArea("SA2")
		dbSetOrder(1)
		If dbSeek(xFilial("SA2")+cCodigo+cLoja)
			AxInclui("SA2", SA2->(Recno()), 2)
		Endif
	Endif

	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fTransfSS
Função auxiliar para a Chamada da Transferência de S.S.

@author Wagner Sobral de Lacerda
@since 02/10/2012
@version MP10/MP11
@return lTransf
/*/
//---------------------------------------------------------------------
Static Function fTransfSS(cTQBFilial, cTQBCodSS, cCodFilial, cCodEquipe, cCodFunc, cCodFornec, cChamada)

	// Variáveis auxiliares
	Local lTransf  := .F.

	// Defaults
	Default cCodFilial := ""
	Default cCodEquipe := ""
	Default cCodFunc   := ""
	Default cCodFornec := ""
	Default cChamada   := ""

	//------------------------------
	// Executa a Transferência
	//------------------------------
	lTransf := A296TRANSF(cTQBFilial, cTQBCodSS)

	// Se efetuou a Transferência (confirmou o Dialog)
	If lTransf
		// Atualiza o Browse
		A291RfshSS(cChamada, cCodFilial, cCodEquipe, cCodFunc, cCodFornec)
	EndIf

Return lTransf

//---------------------------------------------------------------------
/*/{Protheus.doc} fRespEquipe
Função auxiliar para verificar se o funcionário (ST1) é o responsável
pela Equipe de Manutenção.

@author Wagner Sobral de Lacerda
@since 03/10/2012
@version MP10/MP11
@return lRespon
/*/
//---------------------------------------------------------------------
Static Function fRespEquipe(cCodFilial, cCodFunc)

	// Variável do Retorno
	Local lRespon := .F.

	// Variáveis auxiliares
	Local cCodEquipe := ""

	//------------------------------------------------------------
	// Verifica se o Funcionário é o Responsável pela Equipe
	//------------------------------------------------------------
	dbSelectArea("ST1")
	dbSetOrder(1)
	If dbSeek(xFilial("ST1",cCodFilial) + cCodFunc)
		cCodEquipe := ST1->T1_EQUIPE

		dbSelectArea("TP4")
		dbSetOrder(1)
		If dbSeek(xFilial("TP4",ST1->T1_FILIAL) + cCodEquipe) .And. TP4->TP4_CODRES == ST1->T1_CODFUNC
			lRespon := .T.
		EndIf
	EndIf

Return lRespon

//---------------------------------------------------------------------
/*/{Protheus.doc} A291RfshSS
Atualiza o Browse de S.S. conforme a chamada da função.

@author Wagner Sobral de Lacerda
@since 03/10/2012
@version MP10/MP11
@return lRespon
/*/
//---------------------------------------------------------------------
Function A291RfshSS(cChamada, cCodFilial, cCodEquipe, cCodFunc, cCodFornec)

	// Variáveis auxiliares
	Local aAreaOld := {}, nIndOLD := 1
	Local aRegOld := {}
	Local cAuxTbl := ""
	Local cAuxCol := ""
	Local nX := 0

	// Defaults
	Default cCodFilial := ""
	Default cCodEquipe := ""
	Default cCodFunc   := ""
	Default cCodFornec := ""

	//----------
	// Atualiza
	//----------
	If cChamada == __cCallDistr // Distribuição de S.S.
		// Atualiza a Quantidade de S.S. para cada atendente
		If !Empty(cCodEquipe)
			A296AtuQtd(aObj291[__OPC_ST1__][__POS_ALIAS__], "2", "T1_FILIAL", "T1_CODFUNC", )
		EndIf

		// Recarrega a Carga de S.S.
		If !Empty(cCodEquipe)
			Eval(aObj291[__OPC_ST1__][__POS_OBJ__]:bChange)
		ElseIf !Empty(cCodFunc) .Or. !Empty(cCodFornec)
			fLoadCarga(cCodFilial, cCodEquipe, cCodFunc, cCodFornec)
		EndIf

		If Empty(cCodEquipe) .And. Empty(cCodFunc) .And. Empty(cCodFornec)
			//Carrega Arquivo temporario
			Processa({|| MNT296TRB( __OPC_TQB__, ".T." ) },STR0002,STR0003) //"Aguarde..." ## "Processando Solicitações..."
			Eval( aMark296[__OPC_TQB__][__POS_OBJ__]:oBrowse:bChange )
		EndIf
	ElseIf cChamada == __cCallAtend // Atendimento de S.S.
		// Armazena registro posicionado anteriormente
		cAuxTbl := aObj291[__OPC_TQB__][__POS_ALIAS__]
		dbSelectArea(cAuxTbl)
		aRegOld := {(cAuxTbl)->TQB_FILIAL, (cAuxTbl)->TQB_SOLICI}
		nIndOLD := IndexOrd()

		//Carrega Arquivo temporario
		Processa({|| fLoadTRB(__OPC_TQB__,,__cCodFun,__aEqpRes)},STR0002,STR0003) //"Aguarde..." ## "Processando Solicitações..."
		// Atualiza o browse
		aObj291[__OPC_TQB__][__POS_OBJ__]:GoTop()

		// Devolve o registro posicionado anteriormente
		dbSelectArea(cAuxTbl)
		aAreaOld := GetArea()
		dbSetOrder(1)
		If !dbSeek(aRegOld[1] + aRegOld[2])
			RestArea(aAreaOld)
		Else
			dbSetOrder(nIndOLD)
		EndIf
		aObj291[__OPC_TQB__][__POS_OBJ__]:Refresh()
		Eval( aObj291[__OPC_TQB__][__POS_OBJ__]:bChange )

		// Atualiza o Total de S.S.
		If ValType(__aTotal[__nTotSS]) == "O"
			__aTotal[__nTotSS]:Refresh()
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwAtEq
Executa a troca de visualização entre as S.S.'s do Atendente e da
Equipe.

@author Wagner Sobral de Lacerda
@since 18/10/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fBrwAtEq(nOpcBtn, lOnlyLoad)

	// Variáveis auxiliares
	Local cSay := ""
	Local nClrFore := 0, nClrBack := CLR_WHITE

	// Defaults
	Default lOnlyLoad := .F.

	//----------
	// Executa
	//----------
	If nOpcBtn == 1 // S.S.'s do Atendente
		cSay := STR0083 //"Mostrando solicitações de serviço do Atendente."
		nClrFore := CLR_HBLUE
		__aResp291[__nRespAte]:Disable()
		__aResp291[__nRespEqu]:Enable()
	ElseIf nOpcBtn == 2 // S.S.'s da Equipe
		cSay := STR0084 //"Mostrando solicitações de serviço da Equipe."
		nClrFore := CLR_HRED
		__aResp291[__nRespEqu]:Disable()
		__aResp291[__nRespAte]:Enable()
	EndIf
	__nAtEq291 := nOpcBtn
	__aResp291[__nRespMsg]:SetText(cSay)
	__aResp291[__nRespMsg]:SetColor(nClrFore, nClrBack)
	If !lOnlyLoad
		// Recarrega Browse
		A291RfshSS(__cCallAtend)
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES PARA OS REPORTES POSSÍVEIS DA S.S.                                             ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} A291RepSS
Função centralizadora dos Reportes possíveis para uma S.S.

@author Wagner Sobral de Lacerda
@since 10/10/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function A291RepSS(cTQBFilial, cTQBCodSS, cCodAtend, cCodFilial)

	//------------------------------
	// Armazena as variáveis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA291")

	//-- Valida Atendente
	If !fPodeAtender(cTQBFilial, cTQBCodSS)
		Return .F.
	EndIf

	//Direciona para reporte de horas, devido ao reporte de insumos da SS nao ser homologado
	//Para acesso aos outro reportes, remover essa função e comentarios dessa função e dos botoes utilizados na dialog
	A291RepHrs(cTQBFilial,cTQBCodSS,cCodAtend,cCodFilial)

	//------------------------------
	// Devolve as variáveis armazenadas
	//------------------------------
	NGRETURNPRM(aNGBEGINPRM)

	// Atualiza o Browse
	A291RfshSS(__cCallAtend)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fRepSSBtns
Monta um array com os Botões para selecionar o Reporte.

@author Wagner Sobral de Lacerda
@since 13/04/2012

@return aBotoes
/*/
//---------------------------------------------------------------------
Static Function fRepSSBtns()

	Local aBotoes := {}

	/* Define os Botões:
	[01] - Imagem do RPO
	[02] - Título do Botão
	[03] - Ação no Clique (Bloco de Código)
	*/

	aAdd(aBotoes, {"ng_funcionario"  , STR0088  , {|| A291RepHrs(cRepFilSS,cRepCodSS,cRepCodAte,cRepFilAte) }}) //"Reporte de Horas"

Return aBotoes

//---------------------------------------------------------------------
/*/{Protheus.doc} fPodeAtender
Função para verifica se a S.S. pode ser "atendida".

@author Wagner Sobral de Lacerda
@since 17/10/2012
@version MP10/MP11
@return lRetorno
/*/
//---------------------------------------------------------------------
Static Function fPodeAtender(cTQBFilial, cTQBCodSS, lShowMsg)

	// Salva as áreas atuais
	Local aAreaTQB := TQB->( GetArea() )
	Local aAreaTUR := TUR->( GetArea() )

	// Variável do Retorno
	Local lRetorno := .F.

	// Variáveis para a Validação
	Local aAtendimentos := {}
	Local aHeader := {}
	Local aCols   := {}
	Local nX := 0

	Local nTURTIPO   := 0
	Local nTURFILATE := 0
	Local nTURCODATE := 0
	Local nTURDTFINA := 0

	Local cTipoAtend := "2" // 2=Atendente (Funcionário)

	// Defaults
	Default lShowMsg := .T.

	//----------
	// Valida
	//----------
	If IsInCallStack("MNTA296")
		lRetorno := .T.
	Else
		aAtendimentos := aClone( MNT280RAT(cTQBCodSS, , cTQBFilial) )
		aHeader := aClone( aAtendimentos[1] )
		aCols   := aClone( aAtendimentos[2] )

		nTURTIPO   := aScan(aHeader, {|x| AllTrim(x[2]) == "TUR_TIPO" })
		nTURFILATE := aScan(aHeader, {|x| AllTrim(x[2]) == "TUR_FILATE" })
		nTURCODATE := aScan(aHeader, {|x| AllTrim(x[2]) == "TUR_CODATE" })
		nTURDTFINA := aScan(aHeader, {|x| AllTrim(x[2]) == "TUR_DTFINA" })

		// Verifica Todos os Atendimentos
		For nX := 1 To Len(aCols)
			// Filtra pelo mesmo Atendente
			If aCols[nX][nTURTIPO] == cTipoAtend .And. AllTrim(aCols[nX][nTURFILATE]) == AllTrim(xFilial("ST1")) .And. AllTrim(aCols[nX][nTURCODATE]) == AllTrim(__cCodFun)
				// Se o reporte estiver em aberto, então o atente é válido. Caso contrário, o atendente é inválido
				If Empty(aCols[nX][nTURDTFINA])
					lRetorno := .T.
				EndIf
			EndIf
		Next nX
	EndIf

	// Mostra Mensagem
	If !lRetorno .And. lShowMsg
		Help(Nil, Nil, STR0041, Nil, STR0089, 1, 0) // "Atenção" ##
	EndIf

	// Devolve variáveis
	RestArea(aAreaTQB)
	RestArea(aAreaTUR)

Return lRetorno

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES PARA O REPORTE DE HORAS DA S.S.                                                ##
##                                                                                        ##
############################################################################################
/*/
//---------------------------------------------------------------------
/*/{Protheus.doc} A291RepHrs
Browse de Reporte de Horas de uma S.S.

@author Wagner Sobral de Lacerda
@since 05/10/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function A291RepHrs(cTQBFilial, cTQBCodSS, cCodAtend, cCodFilial)

	// Armazena variáveis padrões
	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA291")

	// Salva as áreas atuais
	Local aAreaTUM := TUM->( GetArea() )
	Local aOldRot  := If(Type("aRotina") == "A", aClone( aRotina ), Nil)

	// Variáveis do Browse
	Local oBrwTUM

	// Variáveis auxiliares
	Local aCampos := {}
	Local aNao := {}

	// Defaults
	Default cTQBFilial := xFilial("TQB")
	Default cTQBCodSS  := ""
	Default cCodAtend  := ""
	Default cCodFilial := xFilial("ST1")

	//-- Define aRotina
	aRotina := {	{STR0090, "PesqBrw",0, 1},; //"Pesquisar"
	{STR0053, "A291CadHrs('" + cTQBFilial + "', '" + cTQBCodSS + "', '" + cCodAtend + "', '" + cCodFilial + "', 2)",0, 2},; //"Visualizar"
	{STR0091, "A291CadHrs('" + cTQBFilial + "', '" + cTQBCodSS + "', '" + cCodAtend + "', '" + cCodFilial + "', 3)",0, 3},; //"Incluir"
	{STR0092, "A291CadHrs('" + cTQBFilial + "', '" + cTQBCodSS + "', '" + cCodAtend + "', '" + cCodFilial + "', 4)",0, 4},; //"Alterar"
	{STR0093, "A291CadHrs('" + cTQBFilial + "', '" + cTQBCodSS + "', '" + cCodAtend + "', '" + cCodFilial + "', 5)",0, 5,3}} //"Excluir"

	//--------------------
	// Monta o Browse
	//--------------------
	dbSelectArea("TUM")
	dbGoTop()
	oBrwTUM := FWMBrowse():New()
	oBrwTUM:SetAlias("TUM")
	oBrwTUM:SetDescription(FWX2Nome("TUM"))

	aNao := {"TUM_USUARI", "TUM_NOMUSU"}
	aCampos := NGCAMPNSX3("TUM", aNao)
	aAdd(aCampos, "TUM_FILIAL")
	oBrwTUM:SetOnlyFields(aCampos)

	oBrwTUM:lChgAll := .F. // Não apresentar a tela para informar a filial

	oBrwTUM:SetUseFilter(.T.)
	oBrwTUM:SetFilterDefault("TUM->TUM_FILIAL == '" + xFilial("TUM",cTQBFilial) + "' .And. TUM->TUM_SOLICI == '" + cTQBCodSS + "' .And. TUM->TUM_FILATE == '" + cCodFilial + "' .And. TUM->TUM_ATENDE == '" + cCodAtend + "'") // Filtro pelo Atendente
	oBrwTUM:Activate()
	oBrwTUM:DeActivate()

	// Devolve variáveis
	If Type("aOldRot") == "A"
		aRotina := aClone( aOldRot )
	EndIf
	RestArea(aAreaTUM)
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A291CadHrs
Cadastro de Reporte de Horas de uma S.S.

@author Wagner Sobral de Lacerda
@since 04/10/2012
@version MP10/MP11
@return lDlgHrs
/*/
//---------------------------------------------------------------------
Function A291CadHrs(cTQBFilial, cTQBCodSS, cCodAtend, cCodFilial, nOpcCad)

	// Salva as áreas atuais
	Local aAreaTUM := TUM->( GetArea() )
	Local aAreaTUR := TUM->( GetArea() )

	// Guarda variáveis padrão
	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA291")
	Local cOldFil := cFilAnt
	Local aOldTela := aClone(aTela), aOldGets := aClone(aGets)

	// Variáveis do Dialog
	Local oDlgHrs
	Local cDlgHrs := OemToAnsi(STR0094) //"Atendimento de S.S. - Reporte de Horas"
	Local lDlgHrs
	Local oPnlHrs

	Local oFont16 := TFont():New("Arial",,-16,,.T.)

	Local aSize    := MsAdvSize(.T.)
	Local aObjects := {}
	Local aInfo    := {}
	Local aPosObj  := {}

	Local oPnlTitulo
	Local oSayTitulo
	Local oBtnDetalh

	Local oPnlGet
	Local oGetTUM

	// Variáveis auxiliares
	Local aCposGet := {}, aCposNao := {}
	Local cHoraNULL := "00:00:00"

	// Defaults
	Default cCodFilial := xFilial("ST1")

	// Variáveis para a Classe MsMGet
	Private aTela := {}, aGets := {}

	//--------------------
	// Inicializa
	//--------------------
	//-- Define o Posicionamento dos objetos
	Aadd(aObjects,{030,030,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.t.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	//-- Define os Campos a serem mostrados
	aCposNao := {"TUM_SOLICI", "TUM_CODFOL", "TUM_NOMFOL", "TUM_USUARI", "TUM_NOMUSU"}
	aCposGet := NGCAMPNSX3("TUM", aCposNao)

	//-- Inicializa a Memória
	dbSelectArea("TUM")
	RegToMemory("TUM", (nOpcCad == 3)) // Memória de Inclusão

	If nOpcCad == 3
		M->TUM_FILATE := cCodFilial // Filial do Atendente (Funcionário)
		M->TUM_ATENDE := cCodAtend // Còdigo do Atendente (Funcionário)
		M->TUM_NOMATE := &( AllTrim( GetSX3Cache("TUM_NOMATE", "X3_RELACAO") ) ) // Nome do Atendente (Funcionário)
	EndIf

	//--------------------
	// Monta Reporte
	//--------------------
	DEFINE MSDIALOG oDlgHrs TITLE cDlgHrs FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
	oDlgHrs:lMaximized := .T.

	// Painél principal do Dialog
	oPnlHrs := TPanel():New(01, 01, , oDlgHrs, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oPnlHrs:Align := CONTROL_ALIGN_ALLCLIENT

	// Painél do Título
	oPnlTitulo := TPanel():New(01, 01, , oPnlHrs, , , , aNGColor[1], aNGColor[2], 100, 035)
	oPnlTitulo:Align := CONTROL_ALIGN_TOP

	// SAY da S.S.
	oSayTitulo := TSay():New(003, 010, {|| STR0095 + cTQBCodSS }, oPnlTitulo, , ; //"Solicitação de Serviço: "
	oFont16, , , , .T., CLR_WHITE, , 200, 015)

	// Botão de Detalhes da S.S.
	oBtnDetalh := TButton():New(020, 010, STR0096 , oPnlTitulo, {|| fVisualSS(__OPC_TQB__) }, 49, 12, , , .F., .T., .F., , .F., , , .F.) //"Detalhes"
	oBtnDetalh:SetCSS("QPushButton{ border-radius: 3px; border: 1px solid #000000; background-color: #F0F0F0; }")

	// Painél do Cadastro
	oPnlGet := TPanel():New(01, 01, , oPnlHrs, , , , CLR_BLACK, CLR_WHITE, 100, 030)
	oPnlGet:Align := CONTROL_ALIGN_ALLCLIENT

	// Get do Cadastro
	oGetTUM := MsMGet():New("TUM",RecNo(),nOpcCad,/*aCRA*/,/*cLetras*/,/*cTexto*/,aCposGet/*aChoice*/,aPosObj[1]/*aPos*/,/*aCpos*/,;
	3/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oPnlGet/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
	/*caTela*/,/*lNoFolder*/,/*lProperty*/, /*aField*/)
	oGetTUM:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgHrs ON INIT EnchoiceBar(oDlgHrs, {|| lDlgHrs := .T., If(fExecRepHrs(cTQBFilial, cTQBCodSS, nOpcCad), oDlgHrs:End(), lDlgHrs := .F.) }, {|| lDlgHrs := .F., oDlgHrs:End() }) CENTERED

	// Retorna variáveis padrão
	aTela   := aClone(aOldTela)
	aGets   := aClone(aOldGets)
	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)

	// Devolve as áreas
	RestArea(aAreaTUM)
	RestArea(aAreaTUR)

Return lDlgHrs

//---------------------------------------------------------------------
/*/{Protheus.doc} fExecRepHrs
Valida e Efetua o Reporte de Horas.

@author Wagner Sobral de Lacerda
@since 04/10/2012
@version MP10/MP11
@return lRetorno
/*/
//---------------------------------------------------------------------
Static Function fExecRepHrs(cTQBFilial, cTQBCodSS, nOpcCad)

	// Salva as áreas atuais
	Local aAreaTQB := TQB->( GetArea() )
	Local aAreaTUM := TUM->( GetArea() )
	Local aAreaTUR := TUR->( GetArea() )
	Local aMemory  := NGGetMemory("TUM")

	Local nRecTUM := TUM->( RecNo() )
	Local cOldTot := If(nOpcCad == 4 .Or. nOpcCad == 5, TUM->TUM_HRTOTA, "00:00:00")

	// Variável do Retorno
	Local lRetorno := .T.

	// Variáveis de Memória facilitadas
	Local dDataIni   := M->TUM_DTINIC, cHoraIni := M->TUM_HRINIC
	Local dDataFim   := M->TUM_DTFIM , cHoraFim := M->TUM_HRFIM
	Local cTipoAtend := "2" // 2=Atendente (Funcionário)
	Local cFlwAtend  := "09" // Follow Up de Atendimento
	Local cFilAtend  := M->TUM_FILATE
	Local cCodAtend  := M->TUM_ATENDE
	Local cObservac  := M->TUM_MEMO1

	// Variáveis para validação do Follow Up
	Local lFollowUp := .F.
	Local aFollowUp := {}
	Local nTUMCODFOL := 0
	Local nTUMDTINIC := 0
	Local nTUMHRINIC := 0
	Local nTUMDTFIM  := 0
	Local nTUMHRFIM  := 0
	Local nTUMFILATE := 0
	Local nTUMATENDE := 0
	Local nTUMTUMREC := 0

	// Variáveis para validação do Atendimento
	Local lAtendimento  := .F.
	Local aAtendimentos := {}
	Local nTURTIPO   := 0
	Local nTURFILATE := 0
	Local nTURCODATE := 0
	Local nTURLOJATE := 0
	Local nTURDTRECE := 0
	Local nTURHRRECE := 0
	Local nTURHRREAL := 0
	Local nTURDTFINA := 0
	Local nTURHRFINA := 0
	Local nTURTURREC := 0

	// Variáveis auxiliares
	Local cTime := Time()

	Local aHeader := {}
	Local aCols   := {}
	Local nX := 0

	Local cHrsTotal := ""
	Local cHrsCalc  := ""

	Local dAuxDtIni, cAuxHrIni
	Local dAuxDtFim, cAuxHrFim
	Local nProc, nGrvPos := 0, nAltPos := 0, nGrvPrx := 0, nAltPrx := 0
	Local nSMM := If(nOpcCad == 3 .Or. nOpcCad == 4, 1, 2)

	//-- Verifica Opção do Cadastro
	If nOpcCad <> 2

		If nOpcCad == 3 .Or. nOpcCad == 4
			//------------------------------
			// Valida campos Obrigatórios
			//------------------------------
			If !OBRIGATORIO(aGets,aTela)
				lRetorno := .F.
			EndIf

			//------------------------------
			// Validações Básicas
			//------------------------------
			If dDataIni > dDataBase
				lRetorno := .F.
				Help(Nil, Nil, STR0041, Nil, STR0097 + " " + AllTrim(RetTitle("TUR_DTRECE")) + " " + STR0098, 1, 0) //"Atenção" ## "O campo" ## "não pode ser superior a data atual."
			ElseIf dDataFim > dDataBase
				lRetorno := .F.
				Help(Nil, Nil, STR0041, Nil, STR0097 + " " + AllTrim(RetTitle("TUR_DTFINA")) + " " + STR0098, 1, 0) //"Atenção" ## "O campo" ## "não pode ser superior a data atual."
			ElseIf Len(AllTrim(cHoraIni)) <> 8
				lRetorno := .F.
				Help(Nil, Nil, STR0041, Nil, STR0097 + " " + AllTrim(RetTitle("TUR_HRRECE")) + " " + STR0099, 1, 0) //"Atenção" ## "O campo" ## "deve ser devidamente preenchido."
			ElseIf Len(AllTrim(cHoraFim)) <> 8
				lRetorno := .F.
				Help(Nil, Nil, STR0041, Nil, STR0097 + " " + AllTrim(RetTitle("TUR_HRFINA")) + " " + STR0099, 1, 0) //"Atenção" ## "O campo" ## "deve ser devidamente preenchido."
			ElseIf dDataIni == dDataBase .And. cHoraIni > cTime
				lRetorno := .F.
				Help(Nil, Nil, STR0041, Nil, STR0097 + " " + AllTrim(RetTitle("TUR_HRRECE")) + " " + STR0100, 1, 0) //"Atenção" ## "O campo" ## "não pode ser superior a hora atual."
			ElseIf dDataFim == dDataBase .And. cHoraFim > cTime
				lRetorno := .F.
				Help(Nil, Nil, STR0041, Nil, STR0097 + " " + AllTrim(RetTitle("TUR_HRFINA")) + " " + STR0100, 1, 0) //"Atenção" ## "O campo" ## "não pode ser superior a hora atual."
			ElseIf dDataFim < dDataIni
				lRetorno := .F.
				Help(Nil, Nil, STR0041, Nil, STR0097 + " " + AllTrim(RetTitle("TUR_DTFINA")) + " " + STR0101 + " " + AllTrim(RetTitle("TUR_DTRECE")) + ".", 1, 0) //"Atenção" ## "O campo" ## "não pode ser inferior ao campo"
			ElseIf dDataFim == dDataIni .And. cHoraFim < cHoraIni
				lRetorno := .F.
				Help(Nil, Nil, STR0041, Nil, STR0097 + " " + AllTrim(RetTitle("TUR_HRFINA")) + " " + STR0101 + " " + AllTrim(RetTitle("TUR_HRRECE")) + ".", 1, 0) //"Atenção" ## "O campo" ## "não pode ser inferior ao campo"
			EndIf

			If lRetorno
				//-- Recebe as Horas Totais Reportadas
				cHrsCalc := A291CalcHr(dDataIni, cHoraIni, dDataFim, cHoraFim)
				If Empty( StrTran(StrTran(cHrsCalc,":",""),"0","") )
					lRetorno := .F.
					Help(Nil, Nil, STR0041, Nil, STR0102, 1, 0) //"Atenção" ## "O Reporte de Horas deve ser efetuado contabilizando uma quantidade de Horas Totais."
				EndIf
			EndIf

			//------------------------------
			// Valida Abertura da S.S.
			//------------------------------
			If lRetorno
				dbSelectArea("TQB")
				dbSetOrder(1)
				If dbSeek(xFilial("TQB",cTQBFilial) + cTQBCodSS)
					If dDataIni < TQB->TQB_DTABER .Or. ( dDataIni == TQB->TQB_DTABER .And. cHoraIni < TQB->TQB_HOABER )
						lRetorno := .F.
						Help(Nil, Nil, STR0041, Nil, STR0103, 1, 0) //"Atenção" ## "O Reporte de Horas não deve ser efetuado para uma data/hora anterior à abertura da Solicitação de Serviço."
					EndIf
				EndIf
			EndIf

			//------------------------------
			// Valida Distribuição da S.S.
			//------------------------------
			If lRetorno
				dbSelectArea("TUM")
				dbSetOrder(2)
				If dbSeek(xFilial("TUM",TQB->TQB_FILIAL) + PADR("04",TAMSX3("TUM_CODFOL")[1]," ") + TQB->TQB_SOLICI)
					If dDataIni < TUM->TUM_DTINIC .Or. ( dDataIni == TUM->TUM_DTINIC .And. cHoraIni < TUM->TUM_HRINIC )
						lRetorno := .F.
						Help(Nil, Nil, STR0041, Nil, STR0104, 1, 0) //"Atenção" ## "Não é possível efetuar um Reporte de Horas anterior a data e hora da distribuição da Solicitação de Serviço."
					EndIf
				Else
					lRetorno := .F.
					Help(Nil, Nil, STR0041, Nil, STR0045 + " " + TQB->TQB_SOLICI + " " + STR0105, 1, 0) //"Atenção" ## "A Solicitação de Serviço" ## "ainda não foi distribuída. Portanto, não é possível efetuar Reporte de Horas."
				EndIf
			EndIf
		EndIf

		//------------------------------
		// Valida Insumos (O.S.) // e S.S.)
		//------------------------------
		If lRetorno .And. ( nOpcCad == 3 .Or. nOpcCad == 4 )
			lRetorno := A291ChkIns("2", cCodAtend, dDataIni, cHoraIni, dDataFim, cHoraFim)
		EndIf

		//------------------------------
		// Valida Follow Up
		//------------------------------
		If lRetorno
			aFollowUp := aClone( MNT280RFU(cTQBCodSS, , cTQBFilial) )
			aHeader := aClone( aFollowUp[1] )
			aCols   := aClone( aFollowUp[2] )

			nTUMCODFOL := aScan(aHeader, {|x| AllTrim(x[2]) == "TUM_CODFOL" })
			nTUMDTINIC := aScan(aHeader, {|x| AllTrim(x[2]) == "TUM_DTINIC" })
			nTUMHRINIC := aScan(aHeader, {|x| AllTrim(x[2]) == "TUM_HRINIC" })
			nTUMDTFIM  := aScan(aHeader, {|x| AllTrim(x[2]) == "TUM_DTFIM"  })
			nTUMHRFIM  := aScan(aHeader, {|x| AllTrim(x[2]) == "TUM_HRFIM"  })
			nTUMFILATE := aScan(aHeader, {|x| AllTrim(x[2]) == "TUM_FILATE" })
			nTUMATENDE := aScan(aHeader, {|x| AllTrim(x[2]) == "TUM_ATENDE" })
			nTUMTUMREC := aScan(aHeader, {|x| "_REC_" $ AllTrim(x[2]) })

			// Verifica Todos os Follow Ups
			lFollowUp := .T.
			For nX := 1 To Len(aCols)
				// Se não for único, sai do laço
				If !lFollowUp
					Exit
				EndIf

				// Filtra pelo mesmo Atendente
				If AllTrim(aCols[nX][nTUMCODFOL]) == AllTrim(cFlwAtend) .And. AllTrim(aCols[nX][nTUMFILATE]) == AllTrim(cFilAtend) .And. AllTrim(aCols[nX][nTUMATENDE]) == AllTrim(cCodAtend)

					// Verifica se o Follow Up é único
					If (( DTOS(dDataIni)+cHoraIni >= DTOS(aCols[nX][nTUMDTINIC])+aCols[nX][nTUMHRINIC] .And. DTOS(dDataIni)+cHoraIni <= DTOS(aCols[nX][nTUMDTFIM])+aCols[nX][nTUMHRFIM] ) .Or. ;
					( DTOS(dDataFim)+cHoraFim >= DTOS(aCols[nX][nTUMDTINIC])+aCols[nX][nTUMHRINIC] .And. DTOS(dDataFim)+cHoraFim <= DTOS(aCols[nX][nTUMDTFIM])+aCols[nX][nTUMHRFIM] ) .Or. ;
					( DTOS(dDataIni)+cHoraIni <= DTOS(aCols[nX][nTUMDTINIC])+aCols[nX][nTUMHRINIC] .And. DTOS(dDataFim)+cHoraFim >= DTOS(aCols[nX][nTUMDTFIM])+aCols[nX][nTUMHRFIM] ))

						// Indica que o Follow Up já existe
						If nOpcCad == 3 .Or. (nOpcCad == 4 .And. aCols[nX][nTUMTUMREC] <> nRecTUM)
							lFollowUp := .F.
						EndIf

					EndIf

				EndIf
			Next nX

			If !lFollowUp
				Help(Nil, Nil, STR0041, Nil, STR0106 + CRLF + STR0107, 1, 0) //"Atenção" ## "Já existe um Atendimento para o período informado." ## "Favor informar outro período ou então cancelar o cadastro."
			Else
				If nOpcCad == 3
					MNT280GFU(cTQBCodSS/*cCodSS*/, cFlwAtend/*cCodFlwUp*/, cObservac/*cObservacao*/, dDataIni/*dDtIFlwUp*/, cHoraIni/*cHrIFlwUp*/, ;
					dDataFim/*dDtFFlwUp*/, cHoraFim/*cHrFFlwUp*/, /*cUsuFlwUp*/, cCodAtend/*cCodFun*/, cFilAtend/*cCodFilAte*/)
				ElseIf nOpcCad == 4 .Or. nOpcCad == 5
					If nOpcCad == 4
						dbSelectArea("TUM")
						dbGoTo(nRecTUM)
						RecLock("TUM", .F.)
						TUM->TUM_DTINIC := dDataIni
						TUM->TUM_HRINIC := cHoraIni
						TUM->TUM_DTFIM  := dDataFim
						TUM->TUM_HRFIM  := cHoraFim
						TUM->TUM_HRTOTA := cHrsCalc
						MsUnlock("TUM")
					ElseIf nOpcCad == 5
						dbSelectArea("TUM")
						dbGoTo(nRecTUM)
						RecLock("TUM", .F.)
						dbDelete()
						MsUnlock("TUM")
					EndIf
					MSMM(M->TUM_OBSERV,,,cObservac,nSMM,,,"TUM","TUM_OBSERV")
				EndIf
			EndIf

			lRetorno := lFollowUp
		EndIf

		//------------------------------
		// Valida Atendimentos
		//------------------------------
		If lRetorno
			aAtendimentos := aClone( MNT280RAT(cTQBCodSS, , cTQBFilial) )
			aHeader := aClone( aAtendimentos[1] )
			aCols   := aClone( aAtendimentos[2] )

			nTURTIPO   := aScan(aHeader, {|x| AllTrim(x[2]) == "TUR_TIPO" })
			nTURFILATE := aScan(aHeader, {|x| AllTrim(x[2]) == "TUR_FILATE" })
			nTURCODATE := aScan(aHeader, {|x| AllTrim(x[2]) == "TUR_CODATE" })
			nTURLOJATE := aScan(aHeader, {|x| AllTrim(x[2]) == "TUR_LOJATE" })
			nTURDTRECE := aScan(aHeader, {|x| AllTrim(x[2]) == "TUR_DTRECE" })
			nTURHRRECE := aScan(aHeader, {|x| AllTrim(x[2]) == "TUR_HRRECE" })
			nTURHRREAL := aScan(aHeader, {|x| AllTrim(x[2]) == "TUR_HRREAL" })
			nTURDTFINA := aScan(aHeader, {|x| AllTrim(x[2]) == "TUR_DTFINA" })
			nTURHRFINA := aScan(aHeader, {|x| AllTrim(x[2]) == "TUR_HRFINA" })
			nTURTURREC := aScan(aHeader, {|x| "_REC_" $ AllTrim(x[2]) })

			// Verifica Todos os Atendimentos
			For nX := 1 To Len(aCols)
				// Se já reportou, sai do laço
				If nAltPos > 0 .And. nGrvPos > 0
					Exit
				EndIf

				// Filtra pelo mesmo Atendente
				If aCols[nX][nTURTIPO] == cTipoAtend .And. AllTrim(aCols[nX][nTURCODATE]) == AllTrim(cCodAtend)

					// Na alteração, decrementa o reporte anterior
					dbSelectArea("TUM")
					dbGoTo(nRecTUM)
					For nProc := 1 To 2 // 1 - Alteração ou Exclusão ; 2 - Inclusão
						If nProc == 1 .And. nOpcCad == 3
							Loop
						ElseIf nProc == 2 .And. nOpcCad == 5
							Loop
						EndIf

						dAuxDtIni := If(nProc == 1, TUM->TUM_DTINIC, dDataIni)
						cAuxHrIni := If(nProc == 1, TUM->TUM_HRINIC, cHoraIni)
						dAuxDtFim := If(nProc == 1, TUM->TUM_DTFIM , dDataFim)
						cAuxHrFim := If(nProc == 1, TUM->TUM_HRFIM , cHoraFim)
						// Verifica se o Reporte está dentro do Período de Atendimento ou se o Atendimento está Em Aberto (sem data/hora fim)
						If ( ( dAuxDtIni > aCols[nX][nTURDTRECE] ) .Or. ( dAuxDtIni == aCols[nX][nTURDTRECE] .And. cAuxHrIni >= aCols[nX][nTURHRRECE] ) ) .And. ;
						( ( dAuxDtFim < aCols[nX][nTURDTFINA] ) .Or. ( dAuxDtFim == aCols[nX][nTURDTFINA] .And. cAuxHrFim <= aCols[nX][nTURHRFINA] ) .Or. ( Empty(aCols[nX][nTURDTFINA]) ) )

							// Recebe a Posição do Registro no aCols para gravar
							If nProc == 1
								nAltPos := nX
							Else
								nGrvPos := nX
							EndIf

						Else
							// Verifica o Mais Próximo
							If nAltPrx == 0 .And. nGrvPrx == 0
								nAltPrx := nX
								nGrvPrx := nX
							ElseIf dAuxDtFim < aCols[nX][nTURDTRECE] .Or. ( dAuxDtFim == aCols[nX][nTURDTRECE] .And. cAuxHrFim < aCols[nX][nTURHRRECE] )
								nAltPrx := nX
								nGrvPrx := nX
							EndIf
						EndIf
					Next nProc

				EndIf
			Next nX

			// Se não encontrou um período ideal, busca o mais próximo
			If nAltPos == 0 .And. nOpcCad <> 3
				nAltPos := nAltPrx
			EndIf
			If nGrvPos == 0 .And. nOpcCad <> 5
				nGrvPos := nGrvPrx
			EndIf

			// Atualiza
			For nProc := 1 To 2 // 1 - Alteração ou Exclusão ; 2 - Inclusão
				If nProc == 1 .And. nAltPos == 0
					Loop
				ElseIf nProc == 2 .And. nGrvPos == 0
					Loop
				EndIf

				nX := If(nProc == 1, nAltPos, nGrvPos)

				// Recebe as Horas Realizadas atuais
				cHrsTotal := aCols[nX][nTURHRREAL]
				If Empty(cHrsTotal) .Or. AllTrim(cHrsTotal) == ":"
					cHrsTotal := "00:00:00"
				EndIf
				If nProc == 1
					// Se for alteração/exclusão, primeiro decrementa as horas cadastradas anteriormente
					cHrsTotal := A291HrsAdd(cHrsTotal, cOldTot, .F.)
				Else
					// Soma as Horas Reportadas com o Total Atual, resultando num Novo Total Realizado
					cHrsTotal := A291HrsAdd(cHrsTotal, cHrsCalc)
				EndIf
				cHrsTotal := PADL(cHrsTotal, TAMSX3("TUR_HRREAL")[1], "0")

				// Efetua o Reporte de Horas, atualizando as Horas Realizadas
				dbSelectArea("TUR")
				dbGoTo(aCols[nX][nTURTURREC])
				RecLock("TUR", .F.)
				TUR->TUR_HRREAL := cHrsTotal
				MsUnlock("TUR")
				aCols[nX][nTURHRREAL] := cHrsTotal

				// Indica que já reportou o Atendimento
				If nProc == 2
					lAtendimento := .T.
				EndIf
			Next nProc
		EndIf
	EndIf

	// Se reportou ou alterou/exclui algum atendimento, atualiza o Tempo da S.S.
	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB",cTQBFilial) + cTQBCodSS)
		cHrsTotal := A291HrsTot(cTQBFilial, cTQBCodSS)

		RecLock("TQB", .F.)
		TQB->TQB_TEMPO := cHrsTotal
		MsUnlock("TQB")
	EndIf

	// Devolve as áreas
	RestArea(aAreaTQB)
	RestArea(aAreaTUM)
	RestArea(aAreaTUR)
	NGRestMemory(aMemory)

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} A291CalcHr
Calcula o Tempo Total Reportado.

@author Wagner Sobral de Lacerda
@since 04/10/2012
@version MP10/MP11
@return cHrCalc
/*/
//---------------------------------------------------------------------
Function A291CalcHr(dDtIni, cHrIni, dDtFim, cHrFim)

	// Variável do Retorno
	Local cHrCalc := "00:00:00"

	// Variáveis para o Cálculo
	Local dAuxData := CTOD("")
	Local cAuxCalc := ""

	Local aCalc := {}
	Local nCalc := 0
	Local nHoras := 0
	Local nMins  := 0
	Local nSegs  := 0

	Local cStrHoras := ""
	Local cStrMins  := ""
	Local cStrSegs  := ""
	Local nAT := 0

	// Variáveis auxiliares
	Local nTamHora := fGetTamHora("TUM_HRTOTA")

	// Defaults
	Default dDtIni := dDataBase
	Default dDtFim := dDataBase

	//----------
	// Calcula
	//----------
	//--- Calcula as Horas de acordo com a Data
	// Armazena as Horas, Minutos e Segundos
	For nCalc := 1 To 2
		// Receba qual é a hora (Inicial ou Final)
		cAuxCalc := If(nCalc == 1, cHrIni, cHrFim)

		// Horas
		nAT := AT(":",cAuxCalc)
		cStrHoras := SubStr(cAuxCalc,1,(nAT-1))
		cAuxCalc  := SubStr(cAuxCalc,(nAT+1))
		// Minutos e Segundos
		nAT := AT(":",cAuxCalc)
		cStrMins := SubStr(cAuxCalc,1,(nAT-1))
		cStrSegs := SubStr(cAuxCalc,(nAT+1))

		// Armazena
		aAdd(aCalc, Array(3))
		aCalc[nCalc][1] := Val(cStrHoras)
		aCalc[nCalc][2] := Val(cStrMins)
		aCalc[nCalc][3] := Val(cStrSegs)
	Next nCalc

	// Se for a mesma data, apenas calcula o tempo, sem considerar as datas
	If dDtIni == dDtFim

		nHoras := ( aCalc[2][1] - aCalc[1][1] )
		nMins  := ( aCalc[2][2] - aCalc[1][2] )
		nSegs  := ( aCalc[2][3] - aCalc[1][3] )
		If nSegs < 0
			nMins := ( nMins - 1 )
			nSegs  := ( 60 + nSegs )
		EndIf
		If nMins < 0
			nHoras := ( nHoras - 1 )
			nMins  := ( 60 + nMins )
		EndIf

	Else // Se forem datas diferentes, calcula de acordo com as datas

		dAuxData := dDtIni
		While dAuxData <= dDtFim
			// Se for o primeiro dia, calcula deste o tempo da variável 'cHrIni' até 00:00:00 (24h)
			If dAuxData == dDtIni
				nHoras := ( 24 - aCalc[1][1] )
				nMins  := ( 0 - aCalc[1][2] )
				nSegs  := ( 0 - aCalc[1][3] )
				If nSegs < 0
					nMins := ( nMins - 1 )
					nSegs  := ( 60 + nSegs )
				EndIf
				If nMins < 0
					nHoras := ( nHoras - 1 )
					nMins  := ( 60 + nMins )
				EndIf
			ElseIf dAuxData == dDtFim // Se for o último dia, então calcula desde o tempo 00:00:00 até o da variável 'cHrFim'
				nHoras := ( aCalc[2][1] )
				nMins  := ( aCalc[2][2] )
				nSegs  := ( aCalc[2][3] )
			Else // Senão, calcula um tempo total de um dia (00:00:00 até 23:59:59)
				nHoras := 24
				nMins  := 0
				nSegs  := 0
			EndIf

			// Armazena
			aAdd(aCalc, Array(3))
			nCalc := Len(aCalc)
			aCalc[nCalc][1] := nHoras
			aCalc[nCalc][2] := nMins
			aCalc[nCalc][3] := nSegs

			// Incrementa a Data
			dAuxData++
		End

		// Recebe agora o Total do 'Tempo'
		Store 0 To nHoras, nMins, nSegs
		For nCalc := 3 To Len(aCalc)
			nHoras := ( nHoras + aCalc[nCalc][1] )
			nMins  := ( nMins + aCalc[nCalc][2] )
			nSegs  := ( nSegs + aCalc[nCalc][3] )
		Next nCalc

	EndIf

	//------------------------------
	// Ajusta o Tempo Calculado
	//------------------------------
	// Segundos para Minutos
	While nSegs >= 60
		nSegs := ( nSegs - 60 )
		nMins := ( nMins + 1 )
	End
	// Minutos para Horas
	While nMins >= 60
		nMins := ( nMins - 60 )
		nHoras := ( nHoras + 1 )
	End

	//-- Define o Retorno
	cHrCalc := PADL(nHoras,nTamHora,"0") + ":" + PADL(nMins,2,"0") + ":" + PADL(nSegs,2,"0")

Return cHrCalc

//---------------------------------------------------------------------
/*/{Protheus.doc} A291HrsAdd
Soma (ou subtrai) duas Horas COM SEGUNDOS.

@author Wagner Sobral de Lacerda
@since 04/10/2012
@version MP10/MP11
@return cSomaHoras
/*/
//---------------------------------------------------------------------
Static Function A291HrsAdd(cHora1, cHora2, lSoma, nTamHora)

	// Variável do Retorno
	Local cSomaHoras := "00:00:00"

	// Variáveis para o Cálculo
	Local cAuxCalc := ""
	Local nAuxSoma := 0

	Local aCalc := {}
	Local nCalc := 0
	Local nHoras := 0
	Local nMins  := 0
	Local nSegs  := 0

	Local cStrHoras := ""
	Local cStrMins  := ""
	Local cStrSegs  := ""
	Local nAT := 0

	// Defaults
	Default lSoma    := .T. // .T. - Adição ; .F. - Subtração
	Default nTamHora := 2 // Tamanho das Horas (por exemplo: 2="01:00:00", 3="001:00:00", 4="0001:00:00"

	// -- Define conteúdo das horas caso estejam em branco
	If Empty(cHora1) .Or. Empty( StrTran(cHora1,":","") )
		cHora1 := cSomaHoras
	EndIf
	If Empty(cHora2) .Or. Empty( StrTran(cHora2,":","") )
		cHora2 := cSomaHoras
	EndIf

	//----------
	// Calcula
	//----------
	//--- Calcula as Horas de acordo com a Data
	// Armazena as Horas, Minutos e Segundos
	For nCalc := 1 To 2
		// Receba qual é a hora (Inicial ou Final)
		cAuxCalc := If(nCalc == 1, cHora1, cHora2)

		// Horas
		nAT := AT(":",cAuxCalc)
		cStrHoras := SubStr(cAuxCalc,1,(nAT-1))
		cAuxCalc  := SubStr(cAuxCalc,(nAT+1))
		// Minutos e Segundos
		nAT := AT(":",cAuxCalc)
		cStrMins := SubStr(cAuxCalc,1,(nAT-1))
		cStrSegs := SubStr(cAuxCalc,(nAT+1))

		// Armazena
		aAdd(aCalc, Array(3))
		aCalc[nCalc][1] := Val(cStrHoras)
		aCalc[nCalc][2] := Val(cStrMins)
		aCalc[nCalc][3] := Val(cStrSegs)
	Next nCalc
	// Adição/Subtração apenas das 2 Horas passadas como parâmetro da função
	For nCalc := 1 To Len(aCalc)
		// Horas
		If lSoma .Or. (!lSoma .And. nCalc == 1 )
			nAuxSoma := aCalc[nCalc][1]
		Else
			nAuxSoma := ( aCalc[nCalc][1] * -1 )
		EndIf
		nHoras   := ( nHoras + nAuxSoma )

		// Minutos
		If lSoma .Or. (!lSoma .And. nCalc == 1 )
			nAuxSoma := aCalc[nCalc][2]
		Else
			nAuxSoma := ( aCalc[nCalc][2] * -1 )
		EndIf
		nMins    := ( nMins + aCalc[nCalc][2] )

		// Segundos
		If lSoma .Or. (!lSoma .And. nCalc == 1 )
			nAuxSoma := aCalc[nCalc][3]
		Else
			nAuxSoma := ( aCalc[nCalc][3] * -1 )
		EndIf
		nSegs    := ( nSegs + aCalc[nCalc][3] )
	Next nCalc

	//------------------------------
	// Ajusta o Tempo Calculado
	//------------------------------
	// Segundos para Minutos
	While nSegs >= 60
		nSegs := ( nSegs - 60 )
		nMins := ( nMins + 1 )
	End
	// Minutos para Horas
	While nMins >= 60
		nMins := ( nMins - 60 )
		nHoras := ( nHoras + 1 )
	End

	//-- Define o Retorno
	cSomaHoras := PADL(nHoras,nTamHora,"0") + ":" + PADL(nMins,2,"0") + ":" + PADL(nSegs,2,"0")

Return cSomaHoras

//---------------------------------------------------------------------
/*/{Protheus.doc} A291VldTUM
Função de Validação de campos do Dicionário SX3 da tabela TUM.

@author Wagner Sobral de Lacerda
@since 05/10/2012
@version MP10/MP11
@return .T./.F.
/*/
//---------------------------------------------------------------------
Function A291VldTUM(cIDCampo)

	// Variáveis Auxiliares
	Local cHrsTotal := ""

	// Defaults
	Default cIDCampo := ""

	//----------
	// Valida
	//----------
	If cIDCampo == "TUM_DTINIC"
		If Empty(M->TUM_DTINIC)
			Help(1," ","OBRIGAT")
			Return .F.
		EndIf
	ElseIf cIDCampo == "TUM_HRINIC"
		If Empty( StrTran(M->TUM_HRINIC,":","") )
			Help(1," ","OBRIGAT")
			Return .F.
		EndIf
	ElseIf cIDCampo == "TUM_DTFIM"
		If Empty(M->TUM_DTFIM)
			Help(1," ","OBRIGAT")
			Return .F.
		EndIf
	ElseIf cIDCampo == "TUM_HRFIM"
		If Empty( StrTran(M->TUM_HRFIM,":","") )
			Help(1," ","OBRIGAT")
			Return .F.
		EndIf
	EndIf

	// Gatilha as Horas Totais
	If !Empty(M->TUM_DTINIC) .And. !Empty(M->TUM_HRINIC) .And. !Empty(M->TUM_DTFIM) .And. !Empty(M->TUM_HRFIM)
		cHrsTotal := A291CalcHr(M->TUM_DTINIC, M->TUM_HRINIC, M->TUM_DTFIM, M->TUM_HRFIM)
		cHrsTotal := PADL(cHrsTotal, TAMSX3("TUM_HRTOTA")[1], "0")
		M->TUM_HRTOTA := cHrsTotal
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A291HrsTot
Retorna a Quantidade Total de Horas Reportadas em uma S.S.

@author Wagner Sobral de Lacerda
@since 08/10/2012
@version MP10/MP11
@return cHrsTotal
/*/
//---------------------------------------------------------------------
Function A291HrsTot(cTQBFilial, cTQBCodSS)

	// Salva as áreas atuais
	Local aAreaTQB := TQB->( GetArea() )
	Local aAreaTUR := TUR->( GetArea() )

	// Variáveis para o Cálculo
	Local cHrsTotal := Transform('', PesqPict('TQB', 'TQB_TEMPO'))

	// Variáveis auxiliares
	Local nTamHora := fGetTamHora("TQB_TEMPO")

	// Defaults
	Default cTQBFilial := xFilial("TQB")

	//----------
	// Executa
	//----------
	dbSelectArea("TUR")
	dbSetOrder(1)
	dbSeek(xFilial("TUR",cTQBFilial) + cTQBCodSS, .T.)
	While !Eof() .And. TUR->TUR_FILIAL == xFilial("TUR",cTQBFilial) .And. TUR->TUR_SOLICI == cTQBCodSS

		cHrsTotal := A291HrsAdd(cHrsTotal, TUR->TUR_HRREAL, , nTamHora)

		dbSelectArea("TUR")
		dbSkip()
	End

	// Devolve as áreas
	RestArea(aAreaTQB)
	RestArea(aAreaTUR)

Return cHrsTotal

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetTamHora
Retorna o tamanho da Hora da Picture de um Campo do SX3.

@author Wagner Sobral de Lacerda
@since 08/10/2012
@version MP10/MP11
@return cHrsTotal
/*/
//---------------------------------------------------------------------
Static Function fGetTamHora(cCampo)

	// Variáveis auxiliares
	Local cPictHora := AllTrim( GetSX3Cache(cCampo, "X3_PICTURE") )
	Local cTamHora := ""
	Local nTamHora := 2
	Local nAT := 0

	//----------
	// Recebe
	//----------
	nAT := AT(":", cPictHora)
	If nAT > 0
		cTamHora := StrTran(cPictHora, "@", "")
		cTamHora := StrTran(cTamHora, "E", "")
		cTamHora := StrTran(cTamHora, "R", "")
		cTamHora := AllTrim(cTamHora)
		nTamHora := Len( SubStr(cTamHora,1,(nAT-1)) )
	EndIf

Return nTamHora

//---------------------------------------------------------------------
/*/{Protheus.doc} A291ChkIns
Calcula o Tempo Total Reportado.

@author Wagner Sobral de Lacerda
@since 04/10/2012
@version MP10/MP11
@return .T./.F.
/*/
//---------------------------------------------------------------------
Function A291ChkIns(cTipoIns, cCodInsumo, dDtIni, cHrIni, dDtFim, cHrFim, cLojaTerc)

	// Variáveis para validação
	Local cTipoReg := ""
	Local cCodInsSTL := ""
	//Local cCodInsTUU := ""

	// Defaults
	Default cLojaTerc := ""

	//-- Define conteúdos
	If cTipoIns == "1" // 1=Ferramenta
		cTipoReg := "F"
	ElseIf cTipoIns == "2" // 2=Mão de Obra
		cTipoReg := "M"
	ElseIf cTipoIns == "3" // 3=Produto
		cTipoReg := "P"
	ElseIf cTipoIns == "4" // 4=Terceiro
		cTipoReg := "T"
	EndIf

	//----------
	// Valida
	//----------
	//-- Insumos Realizados de ORDENS DE SERVIÇO
	cCodInsSTL := PADR(cCodInsumo, TAMSX3("TL_CODIGO")[1], " ")
	dbSelectArea("STL")
	dbSetOrder(8)
	dbSeek(xFilial("STL") + cTipoReg + cCodInsSTL, .T.)
	While !Eof() .And. STL->TL_FILIAL == xFilial("STL") .And. STL->TL_TIPOREG == cTipoReg .And. STL->TL_CODIGO == cCodInsSTL

		// Apenas Insumos Realizados
		If AllTrim(STL->TL_SEQRELA) <> "0"

			If DTOS(dDtIni) + cHrIni < DTOS(STL->TL_DTINICI) + STL->TL_HOINICI .And. ;
			DTOS(dDtFim) + cHrFim > DTOS(STL->TL_DTFIM) + STL->TL_HOFIM

				ShowHelpDlg(STR0041, ; //"Atenção"
				{STR0108 + " " + STL->TL_ORDEM + "."}, 2, ; //"Já existe reporte para o mesmo período no insumo da Ordem de Serviço"
				{STR0109}, 2) //"Favor alterar o período de utilização do insumo ou cancelar o cadastro."
				Return .F.
			EndIf

		EndIf

		dbSelectArea("STL")
		dbSkip()
	End

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES PARA O FECHAMENTO DA S.S.                                                      ##
##                                                                                        ##
############################################################################################
/*/
//---------------------------------------------------------------------
/*/{Protheus.doc} A291Fecha
Fechamento de uma S.S.

@author Wagner Sobral de Lacerda
@since 08/10/2012
@version MP10/MP11
@return lRetorno
/*/
//---------------------------------------------------------------------
Function A291Fecha(cTQBFilial, cTQBCodSS, cChamada)

	// Salva as áreas atuais
	Local aAreaTQB := TQB->( GetArea() )
	Local aAreaOLD := {}

	// Variável do Retorno
	Local lRetorno := .F.

	// Defaults
	Default cChamada := ""

	//-- Valida Atendente
	If !fPodeAtender(cTQBFilial, cTQBCodSS)
		Return .F.
	EndIf

	//----------
	// Executa
	//----------
	// Posiciona no Registro
	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB",cTQBFilial) + cTQBCodSS)
		aAreaOLD := GetArea()
		lRetorno := MNTA290FEC(STR0137) //"Fechamento"
		If lRetorno
			RestArea(aAreaOLD)
			//A291FecIns(TQB->TQB_FILIAL, TQB->TQB_SOLICI, TQB->TQB_DTFECH, TQB->TQB_HOFECH)
		EndIf
	Else
		lRetorno := .F.
		Help(" ",1,"REGNOIS")
	EndIf

	// Devolve as áreas
	RestArea(aAreaTQB)

	// Atualiza o Browse
	If !Empty(cChamada)
		A291RfshSS(cChamada)
	EndIf

Return lRetorno

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES PARA O CANCELAMENTO DA S.S.                                                    ##
##                                                                                        ##
############################################################################################
/*/
//---------------------------------------------------------------------
/*/{Protheus.doc} A291Cancel
Cancelamento de uma S.S.

@author Wagner Sobral de Lacerda
@since 08/10/2012
@version MP10/MP11
@return lRetorno
/*/
//---------------------------------------------------------------------
Function A291Cancel(cTQBFilial, cTQBCodSS, cChamada)

	// Salva as áreas atuais
	Local aAreaTQB := TQB->( GetArea() )
	Local aAreaOLD := {}
	Local cAreaTRB := IIf( IsInCallStack('mnta296'), aMark296[ __OPC_TQB__, __POS_ALIAS__ ], aObj291[ __OPC_TQB__, __POS_ALIAS__ ] )

	//Conta a quantidade de itens marcados
	Local nCont   := 0

	// Variável do Retorno
	Local lRetorno := .T.

	// Defaults
	Default cChamada := ""

	//-- Valida Atendente
	If !fPodeAtender(cTQBFilial, cTQBCodSS)
		Return .F.
	EndIf

	dbSelectArea( cAreaTRB )
	dbGoTop()
	ProcRegua( LastRec() )
	While (cAreaTRB)->( !Eof() )
		IncProc()
		If !Empty( (cAreaTRB)->OK )
			nCont++
			If nCont == 2
				MsgInfo( STR0142, STR0041) //"Existe mais de uma S.S. marcada. Para cancelar, marque apenas uma S.S." , "Atenção"
				lRetorno := .F.
				Exit
			Endif
		Endif
		(cAreaTRB)->( DbSkip() )
	End

	//----------
	// Executa
	//----------
	// Posiciona no Registro
	dbSelectArea("TQB")
	dbSetOrder(1)
	If lRetorno
		If dbSeek(xFilial("TQB",cTQBFilial) + cTQBCodSS)
			aAreaOLD := GetArea()
			lRetorno := MNTA290CAN(STR0127) //"Cancelamento"
			If lRetorno
				RestArea(aAreaOLD)
				//A291FecIns(TQB->TQB_FILIAL, TQB->TQB_SOLICI, TQB->TQB_DTCANC, TQB->TQB_HRCANC)
				nRecno := TQB->(Recno())
				Processa({|| MNTW035(nRecno)},"Enviando Workflow...") //Envia workflow para o solicitante da SS;
			EndIf
		Else
			lRetorno := .F.
			Help(" ",1,"REGNOIS")
		EndIf
	Endif

	// Devolve as áreas
	RestArea(aAreaTQB)

	// Atualiza o Browse
	If !Empty(cChamada)
		A291RfshSS(cChamada)
	EndIf

Return lRetorno

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES PARA O DICIONÁRIO DE DADOS                                                     ##
##                                                                                        ##
############################################################################################
/*/
//---------------------------------------------------------------------
/*/{Protheus.doc} fCreateBar
Cria Enchoice bar de acordo com a versao

@author Roger Rodrigues
@since 09/11/2012
@version MP10/MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fCreateBar(oDialog)
	Local oPanelBar, oPanelBtn
	Local oBtnFechar, cCssFechar
	Local lImg := Len(GetResArray("fwstd_btn_focal.png")) > 0

	If cVersao $ "11"
		cCssFechar := "QPushButton { font: bold }"

		If lImg
			cCssFechar += "QPushButton { border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch }"
			cCssFechar += "QPushButton { color: #024670 } "
		Else
			cCssFechar += "QPushButton { color: #024670 } "
		EndIf
		cCssFechar += "QPushButton { border-top-width: 3px }"
		cCssFechar += "QPushButton { border-left-width: 3px }"
		cCssFechar += "QPushButton { border-right-width: 3px }"
		cCssFechar += "QPushButton { border-bottom-width: 3px }"

		If lImg
			cCssFechar += "QPushButton:pressed { color: #FFFFFF } "
			cCssFechar += "QPushButton:pressed { border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch }"
		EndIf

		cCssFechar += "QPushButton:pressed { border-top-width: 3px }"
		cCssFechar += "QPushButton:pressed { border-left-width: 3px }"
		cCssFechar += "QPushButton:pressed { border-right-width: 3px }"
		cCssFechar += "QPushButton:pressed { border-bottom-width: 3px }"

		oPanelBar := TPanel():New(0,0,,oDialog,,,,NGCOLOR("11")[1],NGCOLOR("11")[2],0,012,.f.,.f.)
		oPanelBar:Align := CONTROL_ALIGN_BOTTOM

		oPanelBtn := TPanel():New(0,0,,oPanelBar,,,,NGCOLOR("11")[1],NGCOLOR("11")[2],100,012,.f.,.f.)
		oPanelBtn:Align := CONTROL_ALIGN_RIGHT

		@ 001,050 Button oBtnFechar Prompt STR0136 Message STR0136 Size 38,10 Action (oDialog:End()) Of oPanelBtn Pixel //"Fechar"
		oBtnFechar:SetCss(cCssFechar)

	Else
		EnchoiceBar(oDialog,{|| oDialog:End()},{|| oDialog:End()})
	Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} fCreateFil
Gera array para poder criar o filtro no browse.

@author Eduardo Mussi
@since  19/03/2020
@param  aFields, Array, contém os campos que poderão ser criados filtros
						[ x, 1 ] - Contém o nome do campo da tabela
						[ x, 2 ] - Contém o tipo do campo da tabela
						[ x, 3 ] - Contém o tamanho do campo
						[ x, 4 ] - Contém a quantidade de casas decimais
@return array, retorna estrutura adequada para utilizar o método SetFieldFilter
						[ x, 1 ] - Contém o nome do campo da tabela
						[ x, 2 ] - Contém o titulo do campo
						[ x, 3 ] - Contém o tipo do campo da tabela
						[ x, 4 ] - Contém o tamanho do campo
						[ x, 5 ] - Contém a quantidade de casas decimais
						[ x, 6 ] - Contém a picture do campo
/*/
//-------------------------------------------------------------------
Static Function fCreateFil( aFields )

	Local aFilter := {}
	Local nFields
	
	For nFields := 1 to Len( aFields )
		If STJ->( FieldPos( aFields[ nFields, 1 ] ) ) > 0 // verifica a existência do campo na STJ
			// Campos utilizados para filtro
			aAdd( aFilter, { aFields[ nFields, 1 ],; // Nome do campo
							 RetTitle( aFields[ nFields, 1 ] ),; // Título
							 aFields[ nFields, 2 ],; // Tipo
							 aFields[ nFields, 3 ],; // Tamanho
							 aFields[ nFields, 4 ],; // Decimais
							 PesqPict( 'STJ', aFields[ nFields, 1 ] ) } ) // Picture
		EndIf
	Next nFields

Return aFilter
