#INCLUDE "MNTA985.ch"
#INCLUDE "DBINFO.CH"
#include "Protheus.ch"
#include "hbutton.ch"
#INCLUDE "FOLDER.CH"

#DEFINE ANTERIOR 1
#DEFINE PROXIMO  2

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA985
Controle de Portaria
@author Felipe N. Welter
@since 18/02/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTA985()

	// Guarda conteudo e declara variaveis padroes
	Local aNGBEGINPRM 	:= NGBEGINPRM()
	Local nX 			:= 0
	Local lMNTA9851		:= ExistBlock("MNTA9851")
	Local lMNTA9854		:= ExistBlock("MNTA9854")
	Local lMNTA985J		:= ExistBlock("MNTA985J")
	Local lMNTA985C		:= ExistBlock("MNTA985C")
	Local lMNTA9859		:= ExistBlock("MNTA9859")
	Local lMNTA985A		:= ExistBlock("MNTA985A")
	Local lMNTA985B		:= ExistBlock("MNTA985B")
	Local lBut1 		:= .T.
	Local lBut2 		:= .T.
	Local lBut3 		:= .T.
	Local lBut4 		:= .T.
	Local cType		    := ''
	Local nSize	        := 0
	Local nDeci	        := 0
	Local nMax          := TTK->( FCount() )
	Local aHead         := {}
	Local aSizes        := {}
	Local aDetails      := {}
	Local cAtuLine      := Nil

	//Tabelas Temporarias
	Local oTmpTblVei
	Local oTmpTblOS
	Local oTmpTblEs
	Local oTmpTblVis

	//Indices das Tabelas
	Local aIdxVei := {{"FILIAL","CODBEM"},{"CODBEM"},{"EMPRESA","FILIAL","CODBEM"},{"PLACA"}}    // Veiculos
	Local aIdxOS  := {{"EMPRESA","FILIAL","ORDEM"},{"BLOQPT"}} 		  						 	 // O.S.
	Local aIdxEs  := {{"FILTTI","CODVEI","DTMOV","HRMOV"},{"ORD"}}    						     // Entradas e Saidas do Veiculo
	Local aIdxVis := {{"FILIAL","PLACA","DTENT"},{"FILIAL","DOCMOT"}} 							 // Visitantes

	// [LGPD] Se as funcionalidades, referentes à LGPD, podem ser utilizadas
	Local lLgpd    := FindFunction( 'FWPDCanUse' ) .And. FwPdCanUse( .T. )
	// [LGPD] Caso o usuário não possua acesso ao(s) campo(s), deve-se ofuscá-lo(s)
	Local lOfuscar := lLgpd .And. Len( FwProtectedDataUtil():UsrAccessPDField( __CUSERID, { 'DA4_NOME' } ) ) == 0
	Local lDoctMot := .F.
	Local lNomMot  := .F.
	Local aOfusc   := {}

	//Alias das Tabelas
	Private cTRBVei   // Veiculos
	Private cTRBOS    // Ordem De Serviço
	Private cTRBES    // Entrada e Saida de Veiculos
	Private cTRBVis   // Visitantes
	Private asMenu
	Private asMenuVis
	Private bKeyF5
	Private cNextPrev  := ""
	Private nPagAtu    := 1
	Private nTotalPag  := 0
	Private cVeiculo   := ""
	Private cFilialV   := ""
	Private cEmpVeic   := ""
	Private nRegPerPag := 50
	Private aPgsIniFim := {}
	Private cRecTTIIni := ""
	Private cRecTTIFim := ""

	// Bloco de código para atualizar a variável cNextPrev
	Private bAtuNextPrev := { || ;
	If ( !oPanel1:lVisible,cNextPrev := STR0201 + cValToChar( nPagAtu ) + STR0202 + cValToChar( nTotalPag ),; // " Página " ## " de "
	cNextPrev := "" ) }

	// Bloco de código para esconder/exibir botões de next/prev
	Private bAtuBtnNxPr  := { || If( !oPanel1:lVisible,Eval( { || oBtnNext:Show(),oBtnPrev:Show() } ),;
													   Eval( { || oBtnNext:Hide(),oBtnPrev:Hide() } ) )  }

	// Tabelas |  DA4 - Motoristas           | TPA - Etapas Genericas
	//         |  SB1 - Des.Gen. do Produto  | TPE - Segundo Contador do Bem
	//         |  SC2 - Ordens de Producao   | TPQ - Opcoes Etapas da O.S.
	//         |  SH4 - Ferramentas          | TQY - Status do Bem
	//         |  ST0 - Especialidades       | TS0 - Taxas do Gestao de Doc.
	//         |  ST4 - Serv. de Manutencao  | TS2 - Documentos a pagar
	//         |  ST9 - Bem                  | TTB - Sintomas
	//         |  STD - Area de Manutencao   | TTC - Sintomas da O.S.
	//         |  STE - Tipo de Manutencao   | TTI - Entrada/Saida de Veic.
	//         |  STF - Manutencao           | TTK - Entrada/Saida de Visit.
	//         |  STI - Plano de Manutencao  | TTM - Veiculos do Grupo
	//         |  STJ - O.S. de Manutencao   | TTS - Percursos da Rota do MNT
	//         |  STL - Detalhes da O.S.     | TTT - Rotas do MNT
	//         |  STQ - Etapas Executadas    |

	// PE para alteracoes no dicionario e validacoes para incializacao
	If lMNTA9851
		If !ExecBlock("MNTA9851",.F.,.F.)
			NGRETURNPRM(aNGBEGINPRM)
			Return .F.
		EndIf
	EndIf

	// DEFINICOES DE VARIAVEIS DE PARAMETROS (GLOBAIS)
	Private lMVROTAS   := If(GetNewPar("MV_NGROTAS","1")=="1",.T.,.F.)  //Trabalha com utilizacao de Rotas
	Private cMVEntIn   := GetNewPar("MV_NGENTIN","")
	Private nMVATUPORT := GetNewPar("MV_NGATUPT",5)*60
	Private nMVVARSHES := GetNewPar("MV_NGVDMES",7)
	Private INCLUI     := .F.
	Private ALTERA     := .F.
	Private lVIRADA    := .F.

	// Validacoes basicas para iniciar a rotina
	If !M985VLDIN()
		NGRETURNPRM(aNGBEGINPRM)
		Return .F.
	EndIf

	//Valida se possui acesso ao módulo de frotas.
	If FindFunction( 'MNTAmIIn' ) .And. !MNTAmIIn( 95 )
		Return .F.
	EndIf

	bKeyF5 := {|| Processa({|lEnd|MNT985VEI(cDeEF,cAteEF,cTipList)},STR0001),; //"Aguarde... Atualizando Veículos"
	MNT985SEL((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA),;
	Processa({|lEnd|MNT985VIS()},STR0002)} //"Aguarde... Atualizando Visitantes"
	SETKEY(VK_F5,bKeyF5)

	asMenuVis := {{STR0003,"VldVisSai((cTRBVis)->PLACA,'')"},; //"Saída do Visitante"
				  {STR0004,"MNT985LUPA('TTK',(cTRBVis)->FILIAL+(cTRBVis)->PLACA+DTOS((cTRBVis)->DTENT)+(cTRBVis)->HRENT)"}} //"Visualizar Visitante"

	// Definicao de Variaveis
	//Variaveis genericas (Globais)
	Private cPrograma := "MNTA985"

	//--Variaveis para Filtro
	Private cDeEF    := M985LoadEF(1)
	Private cAteEF   := M985LoadEF(2)
	Private cTipList := "1"
	Private aGlbSave := {cDeEF,cAteEF,cTipList}

	//--Variaveis para Pesquisa
	Private cPesqEF := xFilial("ST9")
	Private cBoxEF  := ""

	//Variaveis para montagem de tela
	Private oDlg
	Private oPanelF
	Private oPanel1
	Private oSplitter
	Private oPanel11
	Private oPnl11
	Private oPnl12
	Private oPnlBtn
	Private oBtnEnt
	Private oBtnSai
	Private oBtnCns
	Private oBtnLoc
	Private oBtnHOS
	Private oBtnFtr
	Private oPanel2
	Private oSplitter2
	Private oPanel21
	Private oPnlLgnd21
	Private oPnlBtn21
	Private oBtnOS
	Private oBtnIOS
	Private oBtnSin
	Private oBtnLgOs
	Private oPanel22
	Private oPnlLgnd22
	Private oPnlBtn22
	Private oPnlBtnES
	Private oBntESVis
	Private oBntESInc
	Private oBntESAlt
	Private oBntESExc
	Private oBntESOk
	Private oBntESHis
	Private oPanel3
	Private oPnlBtn3
	Private oBtnVisV
	private oBtnEntV
	Private oBtnSaiV
	Private aTITLES 	:= {OemToAnsi(STR0005),OemToAnsi(STR0006)}  // "Frota"###"Visitantes"
	Private aPAGES  	:= {"HEADER 1","HEADER 2"}
	Private oFont12 	:= TFont():New("Arial",,-12,,.F.,,,,.T.,.F.)
	Private oFont12B 	:= TFont():New("Arial",,-12,,.T.,,,,.T.,.F.)
	Private oFont09  	:= TFont():New("Arial",,-09,,.F.,,,,.T.,.F.)
	Private oFont10  	:= TFont():New("Arial",,-10,,.F.,,,,.T.,.F.)
	Private oFont10B 	:= TFont():New("Arial",,-10,,.T.,,,,.T.,.F.)
	Private oFont14  	:= TFont():New("Arial",, 14,,.T.,,,,.F.,.F.)
	Private oFont16  	:= TFont():New("Arial",, 16,,.T.,,,,.F.,.F.)
	Private aSize 		:= MsAdvSize()
	Private nLeft 		:= 0
	Private cCADASTRO 	:= Oemtoansi(STR0007) //"Controle de Portaria"
	Private aUserBtn
	Private aNgButton 	:= {{"TK_REFRESH" ,{||M985RFRSH()},STR0008,STR0008}} //"Atualizar"###"Atualizar"
	Private oMenu
	Private oMenuVis
	Private oTimer

	//Variaveis de Controle
	Private lENTRADA := .F.  //Indica estado de Entrada de Veiculo (menos Visitantes)
	Private lSAIDA   := .F.  //Indica estado de Saida de Veiculo (menos Visitantes)
	Private lROTA    := .T.  //Indica possibilidade de informar ROTA na Entrada/Saida
	Private lESCALA  := .T.  //Indica possibilidade de informar ESCALA na Entrada/Saida
	Private lBTN     := .T.  //Habilita botoes da tela

	//Variaveis para Arquivo Temporario
	Private aDBFVei := {}
	Private aDBFOS  := {}
	Private aDBFES  := {}
	Private aDBFVIS := {}
	Private oListVei
	Private oGridOS
	Private oListES
	Private oGrid
	Private oFolder
	Private nCntVei := 0
	Private nCntOS  := 0
	Private nCntES  := 0

	// PE destinado a inclusao de botoes extras no controle de portaria
	If lMNTA9854
		aUserBtn := aClone(ExecBlock("MNTA9854", .F., .F., aTITLES))
	EndIf

	//Adiciona botoes de usuario na EnchoiceBar Frota e Visitantes
	If Type("aUserBtn[1]") == "A" .And. Len(aUserBtn[1]) > 0
		For nX := 1 To Len(aUserBtn[1])
			aUserBtn[1,nX,1] := If(aSCan(GetResArray(''),{|x| aUserBtn[1,nX,1]+'.' $ x})==0,"RPMFUNC",aUserBtn[1,nX,1])
			aAdd(aNgButton,{aUserBtn[1,nX,1],aUserBtn[1,nX,2],aUserBtn[1,nX,3],aUserBtn[1,nX,3]})
		Next nX
	EndIf

	//Lista de Frota
	aButton01 := {;
				{"ng_ico_entrada"		, "ng_ico_entrada"			, {||lENTRADA:=.T.,M985Pesq(0)}							,;
				 STR0010, "oBtnEnt"},;//Entrada
				{"ng_ico_saida"	 		, "ng_ico_saida"			, {||lSAIDA:=.T.,M985Pesq(0)}							,;
				 STR0011, "oBtnSai"},;//Saida
				{"ng_os_troca"			, "ng_os_troca"				, {||lENTRADA:=.T.,lSAIDA:=.T., ,M985Pesq(0)}			,;
				 "Movimentações E/S", "oBtnCns"},;
				{"ng_ico_localizar"		, "ng_ico_localizar"		, {|| M985Pesq(0)}										,;
				 STR0012, "oBtnLoc"},;//Localizar veiculo
				{"ng_ico_historico"		, "ng_ico_historico"		, {|| MNT985HOS((cTRBVei)->FILIAL,(cTRBVei)->CODBEM)}	,;
				 STR0013, "oBtnHOS"},;//Histórico de O.S.
				{"ng_ico_filtro1"		, "ng_ico_filtro1"			, {|| M985Filtro(0)}									,;
				 STR0014, "oBtnFtr"},;//Filtrar Veículos
				{"ng_ico_ferramentas_01", "ng_ico_ferramentas_01"	, {||MNTA985CFG()}										,;
				 STR0163, "oBtnOpt"};//Configurações
			}

	If Type("aUserBtn[2]") == "A" .And. Len(aUserBtn[2]) > 0
		For nX := 1 To Len(aUserBtn[2])
			cVar := "oUsrBtn2" + StrZero(nX,2)
			aUserBtn[2,nX,1] := If(aSCan(GetResArray(''),{|x| aUserBtn[2,nX,1]+'.' $ x})==0,"RPMFUNC",aUserBtn[2,nX,1])
			aAdd(aButton01, {aUserBtn[2,nX,1],aUserBtn[2,nX,1],aUserBtn[2,nX,2],aUserBtn[2,nX,3], &(cVar)})
		Next nX
	EndIf

	//Lista de Ordem de Serviços
	aButton02 := {;
				{"ng_ico_iosco"	, "ng_ico_iosco" , {||NGPrepTBL({{"ST9"},{"TPE"}},(cTRBVei)->EMPRESA), MNT985IOS(), NGPrepTBL({{"ST9"},{"TPE"}},cEmpAnt)}	,;
				 STR0015, "oBtnOS"},;//"Abrir O.S. Corretiva"
				{"ng_ico_imp"	, "ng_ico_imp"	 , {||MNT985IMP((cTRBOS)->ORDEM,(cTRBOS)->EMPRESA,(cTRBOS)->FILIAL)}										,;
				 STR0016, "oBtnIOS"},;//"Imprimir O.S."
				{"ng_ico_lgndos", "ng_ico_lgndos", {|| M985LEG()}																							,;
				 STR0017, "oBtnLgOs"};//"Legenda"
			}
	//Adiciona botoes de usuario no painel de lista de OS //MNTA9854
	If Type("aUserBtn[3]") == "A" .And. Len(aUserBtn[3]) > 0
		For nX := 1 To Len(aUserBtn[3])
			cVar := "oUsrBtn3" + StrZero(nX,2)
			aUserBtn[3,nX,1] := If(aSCan(GetResArray(''),{|x| aUserBtn[3,nX,1]+'.' $ x})==0,"RPMFUNC",aUserBtn[3,nX,1])
			aAdd(aButton02, {aUserBtn[3,nX,1],aUserBtn[3,nX,1],aUserBtn[3,nX,2],aUserBtn[3,nX,3], &(cVar)})
		Next nX
	EndIf

	//Movimentação E/S
	aButton03 := {;
				{"ng_ico_visual"	, "ng_ico_visual"	, {|| MNTA985MOV(2)}																				,;
				 "Visualizar"					, "oBntESVis"},;
				{"ng_ico_incluir"	, "ng_ico_incluir"	, {|| MNTA985MOV( 3 ),fCountTTI( ( cTRBVei )->CODBEM,nPagAtu ),fAtuTRBVeic( ( cTRBVei )->CODBEM )}	,;
				 "Incluir"						, "oBntESInc"},;
				{"bpm_ico_editar"	, "bpm_ico_editar"	, {|| MNTA985MOV( 4 ),fCountTTI( ( cTRBVei )->CODBEM,nPagAtu ),fAtuTRBVeic( ( cTRBVei )->CODBEM )}	,;
				 "Alterar"						, "oBntESAlt"},;
				{"ng_ico_excluir"	, "ng_ico_excluir"	, {|| MNTA985MOV( 5 ),fCountTTI( ( cTRBVei )->CODBEM,nPagAtu ),fAtuTRBVeic( ( cTRBVei )->CODBEM )}	,;
				 "Excluir"						, "oBntESExc"},;
				{"ng_ico_histes"	, "ng_ico_histes"	, {|| MNTA985MOV( 6 ),fCountTTI( ( cTRBVei )->CODBEM,nPagAtu ),fAtuTRBVeic( ( cTRBVei )->CODBEM )}	,;
				 "Inclusão Histórico Retroativo", "oBntESHis"},;
				{"ng_ico_final"		, "ng_ico_final"	, {|| MNTA985CNS(2),MNT985SEL((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA)}				,;
				 "Portaria"					 	, "oBntESOk" };
				}

	// Visitantes
	aButton04 := {;
					{"ng_ico_visualizar", "ng_ico_visualizar"	, {||MNT985LUPA("TTK",(cTRBVis)->FILIAL+(cTRBVis)->PLACA+DTOS((cTRBVis)->DTENT)+(cTRBVis)->HRENT)}	,;
				 	STR0004, "oBtnVisV"},;//"Visualizar Visitante"
					{"ng_ico_entrada"	, "ng_ico_entrada"		, {|| lENTRADA:=.T., lSAIDA:=.F., M985VISENT()}														,;
				 	STR0010, "oBtnEntV"},;//"Entrada"
					{"ng_ico_saida"		, "ng_ico_saida"		, {|| lENTRADA:=.F., lSAIDA:=.T., M985VISSAI()}														,;
				 	STR0054, "oBtnSaiV"},;//"Saida"
					{ 'bpm_ico_editar'	, 'bpm_ico_editar', { || lEntrada := .T., lSaida := .F., M985VISENT( 4 ) },; // Editar
					  STR0214, 'oBtnEdtV' };
				}

	aButtons := { aButton01, aButton02, aButton03, aButton04 }

	If lMNTA985J
		aButtons := aClone( ExecBlock("MNTA985J",.F.,.F., aButtons) )
		//Verifica se todos os botões foram passados pelo ponto de entrada.
		lBut1 := Type("aButtons[1]") == "A"
		lBut2 := Type("aButtons[2]") == "A"
		lBut3 := Type("aButtons[3]") == "A"
		lBut4 := Type("aButtons[4]") == "A"
	EndIf
	// Criacao das Tabelas Temporarias
	//Alias: cTRBVei (Veiculos)
	Aadd(aDBFVei,{"EMPRESA" ,"C", 02,0})											 //02,0 //Empresa do veiculo
	Aadd(aDBFVei,{"FILIAL"  ,"C", TAMSX3("T9_FILIAL")[1],TAMSX3("T9_FILIAL")[2]})    //02,0 //Filial do veiculo
	Aadd(aDBFVei,{"CODBEM"  ,"C", TAMSX3("T9_CODBEM")[1],TAMSX3("T9_CODBEM")[2]})    //16,0 //Codigo do Veiculo
	Aadd(aDBFVei,{"PLACA"   ,"C", TAMSX3("T9_PLACA") [1],TAMSX3("T9_PLACA" )[2]})    //08,0 //Placa
	Aadd(aDBFVei,{"LOCAL"   ,"C", MAX(TAMSX3("TTT_NMROTA")[1],15),0})				 //40,0 //Local - Rota ou Filial
	Aadd(aDBFVei,{"TIPMOV"  ,"C", TAMSX3("TTI_TIPMOV")[1],0})						 //40,0 //Local - Rota ou Filial
	Aadd(aDBFVei,{"EMPTTI"  ,"C", 02,0})										     //02,0 //Empresa do veiculo
	Aadd(aDBFVei,{"FILTTI"  ,"C", TAMSX3("TTI_FILIAL")[1],TAMSX3("TTI_FILIAL")[2]})  //02,0 //Filial do veiculo
	Aadd(aDBFVei,{"STATUS"  ,"C", TAMSX3("T9_STATUS" )[1],TAMSX3("T9_STATUS" )[2]})  //02,0 //Status
	Aadd(aDBFVei,{"DESTAT"  ,"C", TAMSX3("TQY_DESTAT")[1],TAMSX3("TQY_DESTAT")[2]})  //30,0 //Desc. Status
	Aadd(aDBFVei,{"BLOQPT"  ,"C", TAMSX3("T4_BLOQPT" )[1],TAMSX3("T4_BLOQPT" )[2]})  //02,0 //Filial do veiculo

	//Usado na criação dos campos MNT985VEI()
	nCntVei := Len(aDBFVei)

	//Alias: cTRBOS (Ordens de Servico do Veiculo)
	Aadd(aDBFOS,{"EMPRESA" ,"C", 02,0})												 //02,0 //Empresa
	Aadd(aDBFOS,{"FILIAL"  ,"C", TAMSX3("TJ_FILIAL" )[1],TAMSX3("TJ_FILIAL" )[2]}) 	 //02,0 //Filial
	Aadd(aDBFOS,{"CODBEM"  ,"C", TAMSX3("T9_CODBEM" )[1],TAMSX3("T9_CODBEM" )[2]}) 	 //16,0 //Codigo do Veiculo
	Aadd(aDBFOS,{"ORDEM"   ,"C", TAMSX3("TJ_ORDEM"  )[1],TAMSX3("TJ_ORDEM"  )[2]})   //06,0 //OS
	Aadd(aDBFOS,{"CODAREA" ,"C", TAMSX3("TJ_CODAREA")[1],TAMSX3("TJ_CODAREA")[1]})   //06,0 //Codigo da Area de Manutencao
	Aadd(aDBFOS,{"NOMAREA" ,"C", TAMSX3("TJ_NOMAREA")[1],TAMSX3("TJ_NOMAREA")[1]})   //20,0 //Codigo da Area de Manutencao
	Aadd(aDBFOS,{"TIPO"    ,"C", 01,0}) 											 //01,0 //Tipo do Servico da OS (P/C/O)
	Aadd(aDBFOS,{"DESTIPO" ,"C", 10,0}) 											 //10,0 //Descricao do Tipo do Servico da OS (Prev./Corr./Outros)
	Aadd(aDBFOS,{"DTMPINI" ,"D", TAMSX3("TJ_DTORIGI")[1],TAMSX3("TJ_DTORIGI")[2]})   //08,0 //Data de Abertura da OS
	Aadd(aDBFOS,{"HOMPINI" ,"C", TAMSX3("TJ_HORACO1")[1],TAMSX3("TJ_HORACO1")[2]})   //05,0 //Hora de Abertura da OS
	Aadd(aDBFOS,{"DTPREV"  ,"D", TAMSX3("TJ_DTMPINI")[1],TAMSX3("TJ_DTMPINI")[2]})   //08,0 //Data Prevista para Fim
	Aadd(aDBFOS,{"HRPREV"  ,"C", TAMSX3("TJ_DTMPINI")[1],TAMSX3("TJ_DTMPINI")[2]})   //05,0 //Hora Prevista para Fim
	Aadd(aDBFOS,{"SERVIC"  ,"C", TAMSX3("TJ_SERVICO")[1],TAMSX3("TJ_SERVICO")[1]})   //06,0 //Servico
	Aadd(aDBFOS,{"OBSERV"  ,"C", 99,0}) 											 //99,0 //Observacao
	Aadd(aDBFOS,{"BLOQPT"  ,"C", 01,0}) 											 //01,0 //Bloqueia Portaria?

	//Usado na criação dos campos MNT985OS()
	nCntOS := Len(aDBFOS)

	//Alias: cTRBES (Entradas e Saidas do Veiculo)
	Aadd(aDBFES,{"EMPTTI"  ,"C", 02,0}) 										  	 //02,0 //Empresa da Entrada/Saida
	Aadd(aDBFES,{"FILTTI"  ,"C", TAMSX3("TTI_FILVEI")[1],TAMSX3("TTI_FILVEI")[2]})   //Filial da Entrada da Entrada/Saida
	Aadd(aDBFES,{"EMPST9"  ,"C", 02,0})												 //02,0 //Empresa do Veiculo
	Aadd(aDBFES,{"FILST9"  ,"C", TAMSX3("TTI_FILVEI")[1],TAMSX3("TTI_FILVEI")[2] })  //02,0 //Filial do Veiculo
	Aadd(aDBFES,{"CODVEI"  ,"C", TAMSX3("TTI_CODVEI")[1],TAMSX3("TTI_CODVEI")[2] })  //16,0 //Codigo do Veiculo
	Aadd(aDBFES,{"DTMOV"   ,"D", TAMSX3("TTI_DTENT" )[1],TAMSX3("TTI_DTENT" )[2] })  //08,0 //Data
	Aadd(aDBFES,{"HRMOV"   ,"C", TAMSX3("TTI_HRENT" )[1],TAMSX3("TTI_HRENT" )[2] })	 //05,0 //Hora
	Aadd(aDBFES,{"TIPO"    ,"C", TAMSX3("TTI_TIPMOV")[1],TAMSX3("TTI_TIPMOV")[2] })  //01,0 //Tipo de Movimento (Entrada/Saida)
	Aadd(aDBFES,{"MOTORI"  ,"C", TAMSX3("TTI_MOTENT")[1],TAMSX3("TTI_MOTENT")[2] })  //06,0 //Motorista
	Aadd(aDBFES,{"NOME"    ,"C", TAMSX3("TTI_NOMMOT")[1],TAMSX3("TTI_NOMMOT")[2] })  //40,0 //Nome do Motorista
	Aadd(aDBFES,{"POS1"    ,"N", TAMSX3("TTI_POS1EN")[1],TAMSX3("TTI_POS1EN")[2] })  //09,0 //Posicao do Contador 1
	Aadd(aDBFES,{"POS2"    ,"N", TAMSX3("TTI_POS2EN")[1],TAMSX3("TTI_POS2EN")[2] })  //09,0 //Posicao do Contador 2
	Aadd(aDBFES,{"OBS"     ,"C", TAMSX3("TTI_OBSENT")[1],TAMSX3("TTI_OBSENT")[2],})  //80,0 //Observacoes
	Aadd(aDBFES,{"DESTINO" ,"C", 46,0}) 											 //Rota/Filial
	Aadd(aDBFES,{"ORD"     ,"N", 05,0}) 											 //Ordem (Tela)
	Aadd(aDBFES,{"RECNUM"  ,"N", 09,0}) 										  	 //R_E_C_N_O_

	//Usado na criação dos campos MNT985ES()
	nCntES    := Len(aDBFES)

	If lMNTA985C //Executa ponto de entrada para criar campos na (cTRB) da rotina de portaria.
		ExecBlock("MNTA985C",.F.,.F.,{@aDBFVei,@aDBFOS,@aDBFES})
	EndIf

	//Alias: cTRBVei (Veiculos)
	cTRBVei := GetNextAlias()
	oTmpTblVei := fTempTable(cTRBVei, aDBFVei, aIdxVei)

	//Alias: cTRBES (Entradas e Saidas do Veiculo)
	cTRBES := GetNextAlias()
	oTmpTblEs := fTempTable(cTRBES, aDBFES, aIdxEs)

	//Criacao de Array (como se fosse TRB) para armaz. ultima/corrente viagem
	aTRAVEL := {}

	// Montagem visual do Folder 01 - oFolder:aDIALOGS[1]
	/*
	oSplitter oPnlBtn21
	ÚÄÄÄÄÄÄÄÄÄÄÄÄ³Ä³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³±           ³±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±³Ä> oPnlLgnd21
	³±           ³±                                                    ³
	³±    o      ³±                                              o     ³
	³±    P      ³±                                              P     ³
	³±    a      :±     oPanel21                                 a     ³
	³±    n      ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ..Ä..ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄnÄÄÄÄÄ³Ä oSplitter2
	³±    e      :±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±e±±±±±³Ä> oPnlLgnd22
	³±    l      ³±                                              l     ³
	³±    1      ³±                                              2     ³
	³±           ³±                                                    ³
	³±           ³±     oPanel22                                       ³
	À³ÄÄÄÄÄÄÄÄÄÄÄÁ³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	³oPnlBtn     ³oPnlBtn22
	*/

	If !(Alltrim(GetTheme()) == "FLAT") .And. !SetMdiChild() .And. "10" $ cVersao
		aSize[7] -= 50
		aSize[6] -= 30
	ElseIf SetMdiChild()
		aSize[5] -= 03
	EndIf

	Define MsDialog oDlg From aSize[7],nLeft to aSize[6],aSize[5] Title cCADASTRO Pixel

	oDlg:lEscClose := .F.

	oFOLDER := TFOLDER():New(11,0,aTITLES,aPAGES,oDlg,,,,.T.,,(aSize[3]),(aSize[4]),)
	oFOLDER:aDIALOGS[1]:oFONT := oDLG:oFONT
	oFOLDER:aDIALOGS[2]:oFONT := oDLG:oFONT
	oFOLDER:Align := CONTROL_ALIGN_ALLCLIENT

	oSplitter := tSplitter():New( 0,0,oFOLDER:aDIALOGS[1],100,100,0 )
	oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel1 := TPanel():New(01,01,,oSplitter,,,,,,2,2,.F.,.T.)
	oPanel1:Align := CONTROL_ALIGN_LEFT

	oPanel11 := TPanel():New(01,01,,oPanel1,,,,,,2,2,.F.,.T.)
	oPanel11:Align := CONTROL_ALIGN_ALLCLIENT

	//Painel de Filtro
	oPnl11:=TPanel():New(00,00,,oPanel11,,,,,RGB(67,70,87),16,46,.F.,.F.)
	oPnl11:Align := CONTROL_ALIGN_TOP
	oPnl11:Hide()

	oPnl111:=TPanel():New(00,00,,oPnl11,,,,,RGB(67,70,87),2,2,.F.,.F.)
	oPnl111:Align := CONTROL_ALIGN_ALLCLIENT

	oPnl112:=TPanel():New(00,00,,oPnl11,,,,,RGB(67,70,87),34,16,.F.,.F.)
	oPnl112:Align := CONTROL_ALIGN_RIGHT

	//Painel de Pesquisa
	oPnl12:=TPanel():New(00,00,,oPanel11,,,,,RGB(67,70,87),16,46,.F.,.F.)
	oPnl12:Align := CONTROL_ALIGN_TOP
	oPnl12:Hide()

	oPnl121:=TPanel():New(00,00,,oPnl12,,,,,RGB(67,70,87),2,2,.F.,.F.)
	oPnl121:Align := CONTROL_ALIGN_ALLCLIENT

	oPnl122:=TPanel():New(00,00,,oPnl12,,,,,RGB(67,70,87),34,16,.F.,.F.)
	oPnl122:Align := CONTROL_ALIGN_RIGHT

	oPnlBtn:=TPanel():New(00,00,,oPanel1,,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPnlBtn:Align := CONTROL_ALIGN_LEFT

	//Lista de Frotas
	If lBut1 .And. Len(aButtons[1]) > 0
		For nX:= 1 to Len(aButtons[1])
			&(aButtons[1,nX,5]) := TBtnBmp():NewBar(aButtons[1,nX,1], aButtons[1,nX,2],,,,aButtons[1,nX,3],,oPnlBtn,, {||lBTN}, "",,,,, "")
			&(aButtons[1,nX,5]):cToolTip := aButtons[1,nX,4]
			&(aButtons[1,nX,5]):Align  := CONTROL_ALIGN_TOP
		Next nX
	EndIf


	oPanel2 := TPanel():New(01,01,,oSplitter,,,,,,5,5,.F.,.T.)
	oPanel2:Align := CONTROL_ALIGN_RIGHT

	oSplitter2 := tSplitter():New( 0,0,oPanel2,100,100,1 )
	oSplitter2:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel21 := TPanel():New(01,01,,oSplitter2,,,,,,10,10,.F.,.T.)
	oPanel21:Align := CONTROL_ALIGN_TOP

	oPnlLgnd21:=TPanel():New(00,00,,oPanel21,,,,,RGB(67,70,87),16,16,.F.,.F.)
	oPnlLgnd21:Align := CONTROL_ALIGN_TOP

	oPnlBtn21:=TPanel():New(00,00,,oPanel21,,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPnlBtn21:Align := CONTROL_ALIGN_LEFT

	//Lista de Ordem de Serviços
	If lBut2 .And. Len(aButtons[2]) > 0
		For nX:= 1 to Len(aButtons[2])
			&(aButtons[2,nX,5]) := TBtnBmp():NewBar(aButtons[2,nX,1], aButtons[2,nX,2] ,,,,aButtons[2,nX,3] ,,oPnlBtn21,, {||lBTN}, "",,,,, "")
			&(aButtons[2,nX,5]) :cToolTip := aButtons[2,nX,4]
			&(aButtons[2,nX,5]) :Align	   := CONTROL_ALIGN_TOP

		Next nX
	EndIf

	oPanel22 := TPanel():New(01,01,,oSplitter2,,,,,,10,10,.F.,.T.)
	oPanel22:Align := CONTROL_ALIGN_TOP

	oPnlLgnd22:=TPanel():New(00,00,,oPanel22,,,,,RGB(67,70,87),16,16,.F.,.F.)
	oPnlLgnd22:Align := CONTROL_ALIGN_TOP

	oPnlBtn22:=TPanel():New(00,00,,oPanel22,,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPnlBtn22:Align := CONTROL_ALIGN_LEFT

	oPnlBtnES:=TPanel():New(00,00,,oPanel22,,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPnlBtnES:Align := CONTROL_ALIGN_LEFT
	oPnlBtnES:Hide()

	//Movimentação de E/S
	If lBut3 .And. Len(aButtons[3]) > 0
		For nX:= 1 to Len(aButtons[3])
			&(aButtons[3,nX,5]) := TBtnBmp():NewBar(aButtons[3,nX,1], aButtons[3,nX,2],,,,aButtons[3,nX,3],,oPnlBtnES,, {||lBTN}, "",,,,, "")
			&(aButtons[3,nX,5]):cToolTip := aButtons[3,nX,4]
			&(aButtons[3,nX,5]):Align	 := CONTROL_ALIGN_TOP
		Next nX
	EndIf
	nLenPict := If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(xFilial("ST9")))
	@ 03,05 SAY STR0020 Pixel Of oPnl111 FONT oFont10B Color CLR_WHITE //"De Empresa/Filial"###"De Filial"
	@ 10,05 MsGet oDeEF Var cDeEF Picture "@S"+cValToChar(nLenPict)+"!" Size 30,08 Pixel Of oPnl111 F3 "EMPMUL" HASBUTTON Valid M985VldEF(cDeEF,cAteEF)
	@ 23,05 SAY STR0022 Pixel Of oPnl111 FONT oFont10B Color CLR_WHITE //"Até Empresa/Filial"###"Até Filial"
	@ 30,05 MsGet oAteEF Var cAteEF Picture "@S"+cValToChar(+nLenPict)+"!" Size 30,08 Pixel Of oPnl111 F3 "EMPMUL" HASBUTTON Valid M985VldEF(cDeEF,cAteEF)

	aTipList := {STR0063,STR0064,STR0065} //'1=Todos'##'2=Em Viagem'##'3=Em Filial'
	@ 13,60 Say STR0023 Pixel Of oPnl111 FONT oFont10B Color CLR_WHITE //"Listar"
	oComboTip:= tComboBox():New(20,60,{|u|If(PCount()>0,cTipList:=u,cTipList)},aTipList,50,20,oPnl111,,{||.T.},,,,.T.,,,,{||(.T.)},,,,,'cTipList')

	oButtonF1 := tButton():New(10,03,STR0024,oPnl112,{||M985Filtro(1)},26,11,,,,.T.)  //"OK"
	oButtonF2 := tButton():New(26,03,STR0025,oPnl112,{||M985Filtro(2)},26,11,,,,.T.)  //"Cancelar"

	// Painel Para Pesquisa
	nODlgWid := 0

	aCombo := {STR0026,STR0027} //"Codigo"###"Placa"
	cCombo := aCombo[1]
	@ 01,05  SAY STR0028 Of oPnl121 Pixel Font oFont10B Color CLR_WHITE //"Localizar por:"
	oCombo:= tComboBox():New(08,05,{|u|If(PCount()>0,cCombo:=u,cCombo)},aCombo,55,20,oPnl121,,{||.T.},,,,.T.,,,,{||.T.},,,,,'cCombo')
	oCombo:bLostFocus := { ||cBoxEF :=  If(cCombo == aCombo[1],(cTRBVei)->CODBEM,(cTRBVei)->PLACA)}

	If NGSX2MODO("ST9") == "E"
		@ 22,05 SAY STR0029 Of oPnl121 Pixel Font oFont10 Color CLR_WHITE //"Filial:"
		@ 29,05 MsGet oPesqEF Var cPesqEF Picture "@!" Size 33,08 Pixel Of oPnl121 F3 "EMPMUL" HASBUTTON WHEN (cCombo == aCombo[1])
		nODlgWid := 30
	EndIf

	cBoxEF := Replicate(" ",TAMSX3("T9_CODBEM")[1])
	@ 22,09+nODlgWid SAY cCombo+":" Of oPnl121 Pixel Font oFont10 Color CLR_WHITE
	@ 29,09+nODlgWid MsGet oBoxEF Var cBoxEF Picture "@!" Size 55,08 Pixel Of oPnl121

	oButtonL1 := tButton():New(10,03,STR0024,oPnl122,{||M985Pesq(1)},26,11,,,,.T.)  //"OK"
	oButtonL2 := tButton():New(26,03,STR0025,oPnl122,{||M985Pesq(2)},26,11,,,,.T.)  //"Cancelar"

	// LISTBOX - VEICULOS
	dbSelectArea(cTRBVei)
	dbGoTop()
	If lMNTA9859 // Executa o ponto de entrada, que é utilizado para adicionar novos campos na tela de Veículos.
		ExecBlock("MNTA9859",.F.,.F.,{@aDBFVei,@oPanel11,@oFolder})
	Else
		@ 0,0 Listbox oListVei Fields (cTRBVei)->CODBEM ,;
		(cTRBVei)->LOCAL               ,;
		((cTRBVei)->STATUS+If(Empty((cTRBVei)->DESTAT)," "," - "+(cTRBVei)->DESTAT));
		FieldSizes 56,65,102            ;
		Size 140,290 Pixel Of oPanel11  ;
		HEADERS STR0032                ,; //"Veículos"
		STR0033                		   ,; //"Local"
		STR0034                 		  //"Status"
	EndIf

	oListVei:Align := CONTROL_ALIGN_ALLCLIENT
	oListVei:bChange := { || MNT985SEL((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA,;
	                         cPesqEF := (cTRBVei)->FILIAL,cBoxEF := If(cCombo==aCombo[1],(cTRBVei)->CODBEM,(cTRBVei)->PLACA)), oGridOS:Refresh()}

	/*----------------------------------------INICIO MONTAGEM FOLDER O.S.----------------------------------------------*/
	oOS1 := LoadBitmap(GetResources(),'br_verde'   )
	oOS2 := LoadBitmap(GetResources(),'br_amarelo' )
	oOS3 := LoadBitmap(GetResources(),'br_vermelho')

	cTRBOS    := GetNextAlias()
	oTmpTblOS := fTempTable( cTRBOS, aDBFOS, aIdxOS )

	dbSelectArea( cTRBOS )
	dbGoTop()

	If lMNTA985A // Executa o ponto de entrada, que é utilizado para adicionar novos campos na tela de Ordens de Serviço.
		ExecBlock("MNTA985A",.F.,.F.,{@aDBFOS,@oPanel21,@oFolder})
	Else

		cAtuLine := '{ ||{ IIf( DtoS( dDataBase ) + Time() < DtoS( (cTRBOS)->DTMPINI ) + (cTRBOS)->HOMPINI, oOS1, '
		cAtuLine += 'IIf( DtoS( dDataBase ) + Time() < DtoS( (cTRBOS)->DTPREV ) + (cTRBOS)->HRPREV, oOS2, oOS3 ) ), '
		cAtuLine += '(cTRBOS)->ORDEM, (cTRBOS)->NOMAREA, (cTRBOS)->DESTIPO, (cTRBOS)->DTMPINI, (cTRBOS)->HOMPINI, (cTRBOS)->DTPREV, '
		cAtuLine += '(cTRBOS)->HRPREV, (cTRBOS)->SERVIC, (cTRBOS)->OBSERV } }'

		aHead  := { '', STR0037, STR0038, STR0039, STR0040, STR0041, STR0046, STR0043, STR0044, STR0045 }
		aSizes := { 05, 25, 75, 45, 40, 40, 40, 40, 30, 110 }

		@ 004,010 Say STR0035 Pixel Of oPnlLgnd21 FONT oFont12B Color CLR_WHITE //Ordens de Serviço
		oGridOS := TWBrowse():New( 0, 0, 387, 125,, aHead, aSizes, oPanel21,,,,,,,,,,,, .F., cTRBOS, .T.,, .F.,, .T., .F. )
			oGridOS:bLine := &( cAtuLine )
			oGridOS:Align := CONTROL_ALIGN_ALLCLIENT

	EndIf

	/*----------------------------------------FIM MONTAGEM FOLDER O.S.---------------------------------------------------*/

	// Botão 'Próxima Página'
	oBtnNext := TBtnBmp():NewBar( "next","next",,,,;
	{ || fNextPrev( 2 ) },,oPnlLgnd22,,{ || lBTN },"",,,,,"" )
	oBtnNext:cToolTip := "Próxima Página"
	oBtnNext:Align := CONTROL_ALIGN_RIGHT

	// Botão 'Página Anterior'
	oBtnPrev := TBtnBmp():NewBar( "prev","prev",,,,;
	{ || fNextPrev( 1 ) },,oPnlLgnd22,,{ || lBTN },"",,,,,"" )
	oBtnPrev:cToolTip := "Página Anterior"
	oBtnPrev:Align := CONTROL_ALIGN_RIGHT

	Eval( bAtuBtnNxPr ) // Esconde botões de Prev/Next

	// ListBox - Entrada e Saida de Veiculos (E/S)
	If lMNTA985B // Executa o ponto de entrada, que é utilizado para adicionar novos campos na tela de Entrada e Saída de Veículos.
		ExecBlock("MNTA985B",.F.,.F.,{@aDBFES,@oPanel22})
	Else

		@ 004,010 Say STR0047 + cNextPrev Pixel Of oPnlLgnd22 FONT oFont12B Color CLR_WHITE //"Entradas e Saídas"

		dbSelectArea(cTRBES)
		dbSetOrder(02)
		dbGoTop()
		@ 0,0 Listbox oListES Fields If((cTRBES)->TIPO == "1",STR0010,STR0011),; //"Entrada"###"Saída"
		Transform((cTRBES)->POS1,"@E 999,999,999"),;
		(cTRBES)->DTMOV             ,;
		(cTRBES)->HRMOV             ,;
		(cTRBES)->DESTINO           ,;
		(cTRBES)->OBS               ,;
		(cTRBES)->MOTORI            ,;
		(cTRBES)->NOME;
		FieldSizes 35,40,40,30,55,110,55,110 ;
		Size 387,130 Pixel Of oPanel22    ;
		HEADERS STR0039      ,; //"Tipo"
		STR0048              ,; //"Contador"
		STR0049              ,; //"Data"
		STR0050              ,; //"Hora"
		STR0051              ,; //"Destino"
		STR0045              ,; //"Observação"
		STR0052              ,; //"Motorista"
		STR0053                 //"Nome"
	EndIf

	oListES:Align := CONTROL_ALIGN_ALLCLIENT
	If lOfuscar
		oListES:aObfuscatedCols := {.F., .F., .F., .F., .F., .F., .F., .T.}
	EndIf

	// Montagem visual do Folder 02 - oFolder:aDIALOGS[2]
	/*           oSplitter3
	ÚÄÄÄÄÄÄÄÄÄÄÄÄ³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³±oPnlBtn3±±±³±±±±±±±±±±±±±±±±±oPnlBtn4±±±±±±±±±±±±±o±±±±±±±±±±±±±±³
	³±±±±±±±±±±±±³                                      P              ³
	³±±±±o±±±±±±±³                                      a              ³
	³ÄÄÄÄPÄÄÄÄÄÄÄÄoSpliiter4                            n              ³
	³    a       ³                                      e              ³
	³    n       ³                 oPanel41             l              ³
	³    e       ³                                      4              ³
	³    l       ³                                                     ³
	³    3       ³                                                     ³
	³            ³                                                     ³
	³ oPnlBmp    ³                                                     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/

	oPanel3:=TPanel():New(00,00,,oFOLDER:aDIALOGS[2],,,,,RGB(67,70,87),160,160,.F.,.F.)
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlBtn3:=TPanel():New(00,00,,oFOLDER:aDIALOGS[2],,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPnlBtn3:Align := CONTROL_ALIGN_LEFT

	//Botões para lista de visitantes
	If lBut4 .And. Len(aButtons[4]) > 0
		For nX:= 1 to Len(aButtons[4])
			&(aButtons[4,nX,5]) := TBtnBmp():NewBar(aButtons[4,nX,1], aButtons[4,nX,1],,,,aButtons[4,nX,3],,oPnlBtn3,, {||lBTN}, "",,,,, "")
			&(aButtons[4,nX,5]):cToolTip := aButtons[4,nX,4]
			&(aButtons[4,nX,5]):Align	 := CONTROL_ALIGN_TOP
		Next nX
	EndIf

	/*----------------------------------------INICIO MONTAGEM FOLDER VISITANTES----------------------------------------------*/
	aSizes := {}
	aHead  := {}
	cAtuLine := '{||{'
	For nX := 1 To nMax
		If Posicione( 'SX3', 2, TTK->( FieldName( nX ) ), 'X3_BROWSE') == 'S' .Or. TTK->( FieldName( nX ) ) == 'TTK_FILIAL'

			cAtuLine  += IIf( nx == 1, '', ',' )
			cField 	  := TTK->( FieldName( nX ) )
			aDetails  := IIf( cField == 'TTK_CORVEI', TamSX3( 'TTK_DESCOR'), TamSX3( cField ) )

			cType     := aDetails[3]
			nSize     := aDetails[1]
			nDeci     := aDetails[2]

			Aadd(aDBFVis,{SubStr(cField,At('_',cField)+1 ), cType, nSize, nDeci})

			aAdd( aSizes, nSize ) //Tamanho das colunas apresentadas no Browse
			aAdd( aHead , Posicione( 'SX3', 2, cField, 'X3Titulo()' ) ) //Nome das colunas apresentadas.
			cAtuLine += '(cTRBVis)->' + SubStr( cField, At( '_', cField) + 1 )

		EndIf

	Next nX
	cAtuLine += '}}'

	cTRBVis    := GetNextAlias()
	oTmpTblVis := fTempTable( cTRBVis, aDBFVis, aIdxVis )

	Processa( { |lEnd| MNT985VIS()}, STR0002 ) //Aguarde... Atualizando Visitantes

	oGrid := TWBrowse():New( 0, 0, 300, 100,, aHead, aSizes, oPanel3,,,,,,,,,,,, .F., cTRBVis, .T.,, .F.,, .T., .F. )
		oGrid:bLine := &( cAtuLine )
		oGrid:Align := CONTROL_ALIGN_ALLCLIENT
		If lLgpd
			aOfusc := FwProtectedDataUtil():UsrAccessPDField( __CUSERID, { 'TTK_NOMMOT', 'TTK_DOCMOT' } )
			lDoctMot := Ascan( aOfusc, { |x|  AllTrim(x) == 'TTK_DOCMOT' } ) == 0
			lNomMot := Ascan( aOfusc, { |x|  AllTrim(x) == 'TTK_NOMMOT' } ) == 0
			oGrid:aObfuscatedCols := {.F., .F., .F., .F., .F., .F., lDoctMot, lNomMot, .F., .F., .F.}
		EndIf

	/*----------------------------------------FIM MONTAGEM FOLDER VISITANTES---------------------------------------------------*/

	// Configuracoes da oDLG
	NGPOPUP(asMenu,@oMenu)
	oDlg:brClicked := { |o,x,y| oMenu:Activate(x,y,oDlg)}

	// Atualizacao Automatica de Tela
	//Tempo, em minutos, que a rotina irá auto-atualizar os registros na tela
	oTimer := TTimer():New( nMVATUPORT * 1000, {|| Processa({|lEnd|MNT985VEI(cDeEF,cAteEF,cTipList)},STR0001),; //"Aguarde... Atualizando Veículos"
	MNT985SEL((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA),;
	Processa({|lEnd|MNT985VIS()},STR0002)}, oDlg) //"Aguarde... Atualizando Visitantes"

	If nMVATUPORT > 0
		oTimer:Activate()
	EndIf

	// Carregamento Inicial
	Processa({ |lEnd| MNT985VEI(cDeEF,cAteEF,cTipList)},STR0001) //"Aguarde... Atualizando Veículos"

	Activate Dialog oDlg On Init (ENCHOICEBAR(oDlg,{||If(APMSGYESNO(STR0058),oDlg:End(),)},; //"Deseja realmente finalizar o Controle de Portaria?"
	{||If(APMSGYESNO(STR0058),oDlg:End(),)},,aNgButton)) 	 	 	 	 	 	 	 	 	 //"Deseja realmente finalizar o Controle de Portaria?"

	//Deleta Tabelas Temporarias
	oTmpTblOS:Delete()
	oTmpTblEs:Delete()
	oTmpTblVei:Delete()
	oTmpTblVis:Delete()

	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} M985VLDIN
Validacoes basicas para iniciar a rotina
@author Felipe N. Welter
@since 04/06/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function M985VLDIN()

	Local nX, nY
	Local lRet     := .T.
	Local lMVROTAS := If(GetNewPar("MV_NGROTAS",1)=="1",.T.,.F.)  //Trabalha com utilizacao de Rotas

	aTBLS := If(lMVROTAS,{"TTI","TTT","TTS"},{"TTI"})
	For nY := 1 To Len(aTBLS)
		If !(FWModeAccess(aTBLS[nY],3) == "C" .And. FWModeAccess(aTBLS[nY],2) == "C")
			lRet := .F.
			Exit
		EndIf
	Next nY

	If !lRet
		MsgAlert(STR0171+CHR(13)+;  					   //"Para utilizar a rotina de controle de portaria é necessário que a(s) tabela(s)"
		         If(lMVROTAS,"TTI/TTT/TTS","TTI")+STR0172,STR0062)  //" esteja(m) compartilhada(s) por filial e unidade de negocio."###"Atenção"
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985VEI
Processa/grava veículos para montar o browse inicial
@param String cEF1: De Empresa/Filial
@param String cEF2: Até Empresa/Filial
@param String cTPL: Tipo/Situação dos veículos para listar
@param String cCodBem: Indica código do bem que deseja filtrar na query
@author Felipe N. Welter
@since 19/02/2009
@return Nil
/*/
//---------------------------------------------------------------------
Function MNT985VEI( cEF1,cEF2,cTPL,cCodBR )

	Local _cGetDB     := TcGetDb()
	Local nX 		  := 0
	Local nK          := 0
	Local nC          := 0
	Local lEptcCodBR  := Empty( cCodBR )
	Local lMNTA9859   := ExistBlock( 'MNTA9859' )

	Private cAliasVei := GetNextAlias()

	cEF1 := NGTROCAFILI("ST9",cEF1)
	cEF2 := NGTROCAFILI("ST9",cEF2)

	dbSelectArea( cTRBVei )
	cSeek := (cTRBVei)->FILIAL + (cTRBVei)->CODBEM

	If lEptcCodBR
		ZAP
	EndIf

	If _cGetDB $ 'POSTGRES/MYSQL'
	
		/*-------------------------------------------------------+
		| Cria CTE com informações da ST9 e última TTI reportada |
		+-------------------------------------------------------*/
		cQuery := "WITH VIEW_BENS AS ( "
		cQuery += 	"SELECT "
		cQuery +=		"ST9.T9_FILIAL, "
		cQuery += 		"ST9.T9_CODBEM, "
		cQuery += 		"ST9.T9_PLACA , "
		cQuery += 		"ST9.T9_STATUS, "
		cQuery += 		"(	 SELECT "
		cQuery +=				"TQY.TQY_DESTAT "
		cQuery +=			"FROM "
		cQuery +=				RetSQLName( 'TQY' ) + " TQY "
		cQuery +=			"WHERE "
		cQuery +=				"TQY.TQY_STATUS = ST9.T9_STATUS AND "
		cQuery +=				"TQY.D_E_L_E_T_ = ' ' AND " 
		cQuery +=				NGMODCOMP( 'TQY', 'ST9' )
		cQuery +=		" ) AS TQY_DESTAT, "
		cQuery +=		"(	 SELECT "
		cQuery +=				"TTI2.R_E_C_N_O_ "
		cQuery +=			"FROM "
		cQuery +=				RetSQLName( 'TTI' ) + " TTI2 "
		cQuery +=			"WHERE "
		cQuery +=				"TTI2.TTI_FILVEI = ST9.T9_FILIAL AND "
		cQuery +=				"TTI2.TTI_CODVEI = ST9.T9_CODBEM AND "
		cQuery +=				"TTI2.TTI_EMPVEI = " + ValToSQL( SM0->M0_CODIGO ) + " AND "
		cQuery +=				"TTI2.D_E_L_E_T_ = ' ' "
	
		If cTPL == '2'

			// Em Viagem 
			cQuery += 			" AND TTI2.TTI_TIPMOV = '2' "

		ElseIf cTPL == '3' 
			
			// Na Garagem
			cQuery += 			" AND TTI2.TTI_TIPMOV = '1' "

		EndIf

		cQuery +=			"ORDER BY "
		cQuery +=				"TTI2.TTI_DTENT DESC, "
		cQuery +=				"TTI2.TTI_HRENT DESC  "
		cQuery +=			"LIMIT 1 "
		cQuery +=		") AS TTI_RECNO "
		cQuery +=	"FROM "
		cQuery +=		RetSQLName( 'ST9' ) + " ST9 "
		cQuery +=	"WHERE "
		cQuery +=		"ST9.T9_CATBEM IN ( '2', '4' ) AND "
		cQuery +=		"( ST9.T9_FILIAL BETWEEN " 
		cQuery +=							ValToSQL( cEF1 ) + " AND "
		cQuery +=							ValToSQL( cEF2 ) + " ) AND "
		cQuery +=		"ST9.T9_SITBEM  = 'A' AND " 
		cQuery +=		"ST9.T9_ESTRUTU = 'N' AND "
		cQuery +=		"ST9.D_E_L_E_T_ = ' ' 
		
		If !lEptcCodBR

			/*------------------------------------------------------------+
			| Filtra pelo código do bem caso o mesmo tenha sido informado |
			+------------------------------------------------------------*/
			cQuery += " AND ST9.T9_CODBEM = " + ValToSQL( PadR( cCodBR, TAMSX3( 'T9_CODBEM' )[1] ) )

		EndIf
	
		cQuery += " ) "

		/*------------------------------------------------------------+
		| Query que consulta CTE unindo informações de outras tabelas |
		+------------------------------------------------------------*/
		cQuery += "SELECT "
		cQuery +=	ValToSQL( SM0->M0_CODIGO ) + " AS EMPST9, "
		cQuery +=	"VW1.T9_FILIAL  AS FILST9, "
		cQuery +=	"TTI.TTI_EMPMOV AS EMPTTI, "
		cQuery +=	"TTI.TTI_FILMOV AS FILTTI, "
		cQuery += 	"VW1.T9_FILIAL , "
		cQuery +=	"VW1.T9_CODBEM , "
		cQuery +=	"VW1.T9_PLACA  , "
		cQuery +=	"VW1.T9_STATUS , "
		cQuery +=	"VW1.TQY_DESTAT, "
		cQuery +=	"TTI.TTI_TIPMOV  "

		If lMVROTAS
			cQuery += ", TTT.TTT_CODROT "
			cQuery += ", TTT.TTT_NMROTA "
		EndIf

		//Verifica se existe o ponto de entrada e se foi adicionado novos campos
		If ExistBlock("MNTA9859") .And. Len(aDBFVei) > nCntVei
			//Adiciona Campos criados pelo Usuário.
			For nK := nCntVei+1 To Len(aDBFVei)
				cQuery += ", TTT."+aDBFVei[nK][1]
			Next nK
		EndIf

		cQuery += " FROM "
		cQuery +=	"VIEW_BENS VW1 "
		cQuery += "INNER JOIN "
		cQuery +=	RetSQLName( 'TTI' ) + " TTI ON "
		cQuery +=		"VW1.TTI_RECNO = TTI.R_E_C_N_O_ "

		If lMVROTAS

			cQuery += "LEFT JOIN "
			cQuery +=	RetSQLName( 'TTT' ) + " TTT ON "
			cQuery +=		"TTT.TTT_CODROT = TTI.TTI_ROTASA AND "
			cQuery +=		"TTT.TTT_EMPROP = " + ValToSQL( SM0->M0_CODIGO )   + " AND "
			cQuery +=		"TTT.TTT_FILPRO = " + ValToSQL( xFilial( 'TTT' ) ) + " AND "
			cQuery += 		"TTI.TTI_TIPMOV = '2' AND "
			cQuery +=		"TTT.D_E_L_E_T_ = ' ' "
			
		EndIf

		cQuery += "ORDER BY "
		cQuery +=	"EMPST9   ," 
		cQuery +=	"FILST9   ,"
		cQuery +=   "T9_CODBEM"

	Else

		cQuery := "SELECT '"+SM0->M0_CODIGO+"' AS EMPST9, ST9.T9_FILIAL AS FILST9, TTI.TTI_EMPMOV AS EMPTTI,TTI.TTI_FILMOV AS FILTTI,"
		cQuery += " ST9.T9_FILIAL,ST9.T9_CODBEM,ST9.T9_PLACA,ST9.T9_STATUS,TQY.TQY_DESTAT,TQY.TQY_FILIAL,TTI.TTI_TIPMOV"
		If lMVROTAS
			cQuery += ", TTT.TTT_CODROT, TTT.TTT_NMROTA"
		EndIf

		//Verifica se existe o ponto de entrada e se foi adicionado novos campos
		If ExistBlock("MNTA9859") .And. Len(aDBFVei) > nCntVei
			//Adiciona Campos criados pelo Usuário.
			For nK := nCntVei+1 To Len(aDBFVei)
				cQuery += ", TTT."+aDBFVei[nK][1]
			Next nK
		EndIf

		cQuery += " FROM "+RetSQLName("ST9")+" ST9"
		cQuery += " LEFT JOIN "+RetSQLName("TQY")+" TQY ON ST9.T9_STATUS = TQY.TQY_STATUS"

		If FWModeAccess("ST9",3, SM0->M0_CODIGO) == FWModeAccess("TQY",3, SM0->M0_CODIGO)
			cQuery += " AND (TQY.TQY_FILIAL IS NULL OR TQY.TQY_FILIAL = ST9.T9_FILIAL)"
		EndIf

		cQuery += " LEFT JOIN "+RetSQLName("TTI")+" TTI ON ST9.T9_FILIAL = TTI.TTI_FILVEI AND ST9.T9_CODBEM = TTI.TTI_CODVEI"
		If lMVROTAS
			cQuery += " LEFT JOIN "+RetSQLName("TTT")+" TTT ON TTI.TTI_TIPMOV='2' AND TTI.TTI_ROTASA = TTT.TTT_CODROT "
			cQuery += " AND TTT.TTT_EMPROP = '"+SM0->M0_CODIGO+"' AND TTT.TTT_FILPRO = '"+xFilial("TTT")+"'"
		EndIf

		cQuery += " WHERE (T9_CATBEM = '2' OR T9_CATBEM = '4') AND T9_SITBEM = 'A' AND T9_ESTRUTU = 'N'"
		If (cTPL == '2') //Em Viagem
			cQuery += " AND TTI.TTI_TIPMOV = '2' "
		ElseIf (cTPL == '3') //Na Garagem
			cQuery += " AND TTI.TTI_TIPMOV = '1' "
		EndIf

		cQuery += " AND (ST9.T9_FILIAL >= '"+cEF1+"') AND (ST9.T9_FILIAL <= '"+cEF2+"')"
		cQuery += " AND ( (TTI.TTI_DTENT||TTI.TTI_HRENT) = "
		cQuery += " (SELECT MAX(A.TTI_DTENT||A.TTI_HRENT) FROM "+RetSQLName("TTI")+" A"
		cQuery += " WHERE A.TTI_FILVEI = TTI.TTI_FILVEI"
		cQuery += " AND TTI.TTI_EMPVEI IS NULL OR TTI.TTI_EMPVEI = '"+SM0->M0_CODIGO+"'"
		cQuery += " AND A.TTI_CODVEI = TTI.TTI_CODVEI AND A.D_E_L_E_T_ <> '*' ))"

		cQuery += " AND (TQY.D_E_L_E_T_ IS NULL OR TQY.D_E_L_E_T_ <> '*')  AND ST9.D_E_L_E_T_ <> '*'"
		cQuery += " AND (TTI.D_E_L_E_T_ IS NULL OR TTI.D_E_L_E_T_ <> '*')"
		If lMVROTAS
			cQuery += " AND (TTT.D_E_L_E_T_ IS NULL OR TTT.D_E_L_E_T_ <> '*')"
		EndIf

		// Filtra pelo código do bem caso o mesmo tenha sido informado
		If !lEptcCodBR
			cQuery += " AND T9_CODBEM = '" + PadR( cCodBR,TAMSX3( "T9_CODBEM" )[1] ) + "'"
		EndIf

		cQuery += " ORDER BY EMPST9, FILST9, T9_CODBEM"

		cQuery := ChangeQuery(cQuery)

	EndIf

	//+------------------------------------------------------------+
	//| PE para alterar o filtro do carregamento do browse inicial |
	//+------------------------------------------------------------+
	If ExistBlock("MNTA9856")
		cQuery := ExecBlock("MNTA9856",.F.,.F.,{cQuery,SM0->M0_CODIGO})
	EndIf

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasVei, .F., .T.)

	dbSelectArea(cAliasVei)
	ProcRegua(M985RecCnt(cAliasVei))

	dbSelectArea( cAliasVei )
	dbGoTop()

	While !EoF()

		IncProc()

		If !lEptcCodBR
			NGDBAREAORDE(cTRBVei,01)
			dbSeek( (cAliasVei)->FILST9 + (cAliasVei)->T9_CODBEM )
		EndIf

		RecLock( cTRBVei,lEptcCodBR )
		(cTRBVei)->EMPRESA := (cAliasVei)->EMPST9
		(cTRBVei)->FILIAL  := (cAliasVei)->FILST9
		(cTRBVei)->CODBEM  := (cAliasVei)->T9_CODBEM
		(cTRBVei)->PLACA   := (cAliasVei)->T9_PLACA

		(cTRBVei)->TIPMOV	 := (cAliasVei)->TTI_TIPMOV
		If (cAliasVei)->TTI_TIPMOV = '1' //Filial
			(cTRBVei)->LOCAL  := NGSEEKSM0((cAliasVei)->EMPTTI+(cAliasVei)->FILTTI,{"M0_NOME"})[1]
		ElseIf (cAliasVei)->TTI_TIPMOV = '2' //Rota
			(cTRBVei)->LOCAL  := If(lMVROTAS,(cAliasVei)->TTT_NMROTA,STR0165)  //"Em Viagem"
		EndIf
		(cTRBVei)->EMPTTI  := (cAliasVei)->EMPTTI
		(cTRBVei)->FILTTI  := (cAliasVei)->FILTTI

		(cTRBVei)->STATUS  := (cAliasVei)->T9_STATUS
		(cTRBVei)->DESTAT  := (cAliasVei)->TQY_DESTAT
		(cTRBVei)->BLOQPT  := "F" // False

		//Verifica se foi adicionado campos no PE-MNTA985C
		If  lMNTA9859 .And. Len(aDBFVei) > nCntVei
			//Adiciona campos criados pelo Usuário
			For nC := nCntVei+1 To Len(aDBFVei)
				nx := "(cTRBVEI)->"+aDBFVei[nC][1]
				ny := "(cAliasVei)->"+aDBFVei[nC][1]
				If !aDBFVei[nC][2] == "D"
					&nx. := &ny.
				Else
					&ny. := STOD(&nx.)
				EndIf
			Next nC
		EndIf

		(cTRBVei)->(MsUnLock())

		NGDBSELSKIP( cAliasVei )

	End While

	(cAliasVei)->(dbCloseArea())

	//Busca os veiculos que não tiveram entrada na portaria
	fBusVeic(cEF1,cEF2,cTPL,cCodBR)

	NGDBAREAORDE((cTRBVei),01)
	If !dbSeek(cSeek)
		dbGoTop()
	EndIf

	oListVei:Refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985SEL
Ao selecionar um veiculo, atualiza OS, e E/S
@author Felipe N. Welter
@since  19/02/09
@version undefined
@param cCODVei, characters, Codigo do Bem (Veiculo) selecionado
@param cFILVei, characters, Filial do Bem (Veiculo) selecionado
@param cEMPVei, characters, Empresa do Bem (Veiculo) selecionado
@type function
/*/
//---------------------------------------------------------------------
Function MNT985SEL(cCODVei,cFILVei,cEMPVei)

	Processa({ |lEnd| MNT985OS(cCODVei,cFILVei,cEMPVei)},STR0066) //"Aguarde... Atualizando O.S."
	Processa({ |lEnd| MNT985ES(cCODVei,cFILVei,cEMPVei)},STR0067) //"Aguarde... Atualizando E/S"

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985OS
Atualiza O.S. mostradas no browse
@author Felipe N. Welter
@since 19/02/09
@version undefined
@param cCODVei, characters, Codigo do Veiculo selecionado
@param cFILVei, characters, Filial do Veiculo selecionado
@param cEMPVei, characters, Empresa do Veiculo selecionado
@type function
/*/
//---------------------------------------------------------------------
Function MNT985OS(cCODVei,cFILVei,cEMPVei)

	Local cTempo 	:= '0:00'
	Local nDias  	:= 0
	Local nHoras 	:= 0
	Local lBloq  	:= .F.
	Local nX     	:= 0
	Local lMNTA985A := ExistBlock("MNTA985A")

	//Variaveis usadas na criação dos campos do Usuario.
	Local nK     := 0
	Local nC     := 0

	//Alias utilizado na Query
	Private cAliasOS := GetNextAlias()

	//Limpa OS's da tabela
	dbSelectArea(cTRBOS)
	ZAP

	cQuery := "SELECT "
	cQuery += " STJ.TJ_FILIAL, STJ.TJ_CODBEM, STJ.TJ_ORDEM, STJ.TJ_CODAREA, STJ.TJ_DTORIGI, STJ.TJ_HORACO1, STJ.TJ_HOMPINI,"
	cQuery += " STJ.TJ_SERVICO, STJ.TJ_DTMPINI, STJ.TJ_DTMPFIM, STJ.TJ_HOMPFIM, STD.TD_NOME, STE.TE_CARACTE, ST4.T4_BLOQPT,"
	cQuery += " '"+SM0->M0_CODIGO+"' AS EMPRESA, STJ.TJ_FILIAL AS FILIAL"

	//Verifica se foi adicionado campos no PE-MNTA985C
	If ExistBlock("MNTA985A") .And. Len(aDBFOS) > nCntOS
		//Adiciona Campos criados pelo Usuário.
		For nK :=  nCntOS+1 To Len(aDBFOS)
			cQuery += ", STJ."+aDBFOS[nK][1]
		Next nK
	EndIf
	//JOINS
	cQuery += " FROM "+RetSQLName("STJ")+" STJ"
	cQuery += " LEFT JOIN "+RetSQLName("STD")+" STD"
	cQuery += " ON STJ.TJ_CODAREA = STD.TD_CODAREA"
	cQuery += " LEFT JOIN "+RetSQLName("STE")+" STE"
	cQuery += " ON STJ.TJ_TIPO = STE.TE_TIPOMAN"
	cQuery += " LEFT JOIN "+RetSQLName("ST4")+" ST4"
	cQuery += " ON STJ.TJ_SERVICO = ST4.T4_SERVICO"
	//WHERE
	cQuery += " WHERE"
	cQuery += " STJ.TJ_TIPOOS = 'B' AND STJ.TJ_CODBEM = '"+cCODVei+"' AND STJ.TJ_SITUACA = 'L' AND STJ.TJ_TERMINO = 'N'"
	cQuery += " AND " + NGMODCOMP("STD","STJ","=")
	cQuery += " AND " + NGMODCOMP("STE","STJ","=")
	cQuery += " AND " + NGMODCOMP("ST4","STJ","=")

	//VERIFICA DELETE
	cQuery += " AND STJ.D_E_L_E_T_ <> '*'"
	cQuery += " AND (STD.D_E_L_E_T_ IS NULL OR STD.D_E_L_E_T_ <> '*')"
	cQuery += " AND (STE.D_E_L_E_T_ IS NULL OR STE.D_E_L_E_T_ <> '*')"
	cQuery += " AND (ST4.D_E_L_E_T_ IS NULL OR ST4.D_E_L_E_T_ <> '*')"
	//ORDER BY
	cQuery += " ORDER BY TJ_FILIAL, TJ_ORDEM"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasOS, .F., .T.)

	//Recria tabela de OS para bem selecionado
	dbSelectArea(cAliasOS)
	ProcRegua(M985RecCnt(cAliasOS))

	While !EoF()
		IncProc()

		dbSelectArea(cTRBOS)
		(cTRBOS)->(dbAppend())
		(cTRBOS)->EMPRESA := (cAliasOS)->EMPRESA
		(cTRBOS)->FILIAL  := (cAliasOS)->FILIAL
		(cTRBOS)->CODBEM  := (cAliasOS)->TJ_CODBEM
		(cTRBOS)->ORDEM   := (cAliasOS)->TJ_ORDEM
		(cTRBOS)->CODAREA := (cAliasOS)->TJ_CODAREA
		(cTRBOS)->NOMAREA := (cAliasOS)->TD_NOME
		(cTRBOS)->TIPO    := (cAliasOS)->TE_CARACTE

		If (cAliasOS)->TE_CARACTE == "P"
			(cTRBOS)->DESTIPO := STR0068  //"PREVENTIVA"
		ElseIf (cAliasOS)->TE_CARACTE == "C"
			(cTRBOS)->DESTIPO := STR0069  //"CORRETIVA"
		ElseIf (cAliasOS)->TE_CARACTE == "O"
			(cTRBOS)->DESTIPO := STR0070  //"OUTROS"
		EndIf

		(cTRBOS)->DTMPINI := STOD((cAliasOS)->TJ_DTMPINI)
		(cTRBOS)->HOMPINI := (cAliasOS)->TJ_HOMPINI
		(cTRBOS)->SERVIC  := (cAliasOS)->TJ_SERVICO
		If (STJ->(FieldPos('TJ_MMSYP')) > 0)
			cObserva := AllTrim(NGSEEK("STJ",(cAliasOS)->TJ_ORDEM,1,"NGMEMOSYP(STJ->TJ_MMSYP)",(cAliasOS)->TJ_FILIAL,(cAliasOS)->EMPRESA))
		Else
			cObserva := AllTrim(NGSEEK("STJ",(cAliasOS)->TJ_ORDEM,1,"TJ_OBSERVA",(cAliasOS)->TJ_FILIAL,(cAliasOS)->EMPRESA))
		EndIf
		(cTRBOS)->OBSERV  := SubStr(cObserva,1,99)

		//Verifica se foi adicionado campos no PE-MNTA985C
		If lMNTA985A .And. Len(aDBFOS) > nCntOS
			//Adiciona campos criados pelo Usuário
			For nC := nCntOS+1 To Len(aDBFOS)
				nx := "(cTRBOS)->"+aDBFOS[nC][1]
				ny := "(cAliasOS)->"+aDBFOS[nC][1]
				If !aDBFOS[nC][2] == "D"
					&nx. := &ny.
				Else
					&ny. := STOD(&nx.)
				EndIf
			Next nC
		EndIf


		//Bloqueia saida (S/N) - Servico
		If (cAliasOS)->T4_BLOQPT == "1"
			lBloq := .T.
		Else
			//Bloqueia saida (S/N) - Etapa
			NGPrepTBL({{"STQ",01},{"TPA",01}},(cAliasOS)->EMPRESA)
			dbSeek((cAliasOS)->FILIAL+(cAliasOS)->TJ_ORDEM,.T.)
			While !EoF() .And. STQ->TQ_FILIAL == (cAliasOS)->FILIAL .And. STQ->TQ_ORDEM == (cAliasOS)->TJ_ORDEM
				If NGSEEK("TPA",STQ->TQ_ETAPA,1,"TPA_BLOQPT",(cAliasOS)->FILIAL,(cAliasOS)->EMPRESA,(cAliasOS)->EMPRESA) == "1"
					lBloq := .T.
					Exit
				EndIf
				dbSelectArea("STQ")
				dbSkip()
			EndDo
			NGPrepTBL({{"STQ",01},{"TPA",01}},SM0->M0_CODIGO)
			//Bloqueia saida (S/N) - Sintoma
			If !lBloq
				NGPrepTBL({{"TTC",01},{"TTB",01}},(cAliasOS)->EMPRESA)
				dbSeek((cAliasOS)->FILIAL+(cAliasOS)->TJ_ORDEM,.T.)
				While !EoF() .And. TTC->TTC_FILIAL == (cAliasOS)->FILIAL .And. TTC->TTC_ORDEM == (cAliasOS)->TJ_ORDEM
					If NGSEEK("TTB",TTC->TTC_CDSINT,1,'TTB_BLOQPT',(cAliasOS)->FILIAL,(cAliasOS)->EMPRESA,(cAliasOS)->EMPRESA) == "1"
						lBloq := .T.
						Exit
					EndIf
					dbSelectArea("TTC")
					dbSkip()
				EndDo
				NGPrepTBL({{"TTC",01},{"TTB",01}},SM0->M0_CODIGO)
			EndIf
		EndIf
		(cTRBOS)->BLOQPT := If(lBloq,"T","F")

		//Acumula tempo medio para O.S. - Etapa
		NGPrepTBL({{"STQ",01},{"TPA",01}},(cAliasOS)->EMPRESA)
		dbSeek((cAliasOS)->FILIAL+(cAliasOS)->TJ_ORDEM,.T.)
		While !EoF() .And. STQ->TQ_FILIAL == (cAliasOS)->FILIAL .And. STQ->TQ_ORDEM == (cAliasOS)->TJ_ORDEM
			cTempo := NGSOMAHCAR(NGSEEK("TPA",STQ->TQ_ETAPA,1,'TPA_TEMPOM',(cAliasOS)->FILIAL,(cAliasOS)->EMPRESA,(cAliasOS)->EMPRESA),cTempo)
			dbSkip()
		EndDo
		NGPrepTBL({{"STQ",01},{"TPA",01}},SM0->M0_CODIGO)

		//Acumula tempo medio para O.S. - Sintoma
		NGPrepTBL({{"TTB",01},{"TTC",01}},(cAliasOS)->EMPRESA)
		dbSeek((cAliasOS)->FILIAL+(cAliasOS)->TJ_ORDEM,.T.)
		While !EoF() .And. TTC->TTC_FILIAL == (cAliasOS)->FILIAL .And. TTC->TTC_ORDEM == (cAliasOS)->TJ_ORDEM
			cTempo := NGSOMAHCAR(NGSEEK("TTB",TTC->TTC_CDSINT,1,'TTB_TEMPOM',(cAliasOS)->FILIAL,(cAliasOS)->EMPRESA,(cAliasOS)->EMPRESA),cTempo)
			dbSkip()
		EndDo
		NGPrepTBL({{"TTB",01},{"TTC",01}},SM0->M0_CODIGO)

		//Calcula previsao de termino com base em tempo medio
		If !Empty((cAliasOS)->TJ_HOMPINI) .And. !Empty((cAliasOS)->TJ_DTMPINI)
			nHoras := NGSOMAHCAR((cAliasOS)->TJ_HOMPINI,If(Empty(cTempo),'00:00',cTempo))
			nHoras := HTOM(nHoras)
			While nHoras >= 1440 //Equivalente a 24h
				nHoras -= 1440
				nDias++
			EndDo

			//Verifica qual maior previsao saida entre calculado por insumos (STJ) e calculo por etapa/sintoma
			cDtPrSai := STOD(((cAliasOS)->TJ_DTMPINI))+nDias
			cHrPrSai := MTOH(nHoras)
			If ((cAliasOS)->TJ_DTMPFIM+(cAliasOS)->TJ_HOMPFIM  > DTOS(cDtPrSai)+cHrPrSai)
				cDtPrSai := STOD((cAliasOS)->TJ_DTMPFIM)
				cHrPrSai := (cAliasOS)->TJ_HOMPFIM
			EndIf

			(cTRBOS)->DTPREV  := cDtPrSai
			(cTRBOS)->HRPREV  := cHrPrSai
		EndIf

		cTempo := '00:00'
		nDias := nHoras := 0
		dbSelectArea(cAliasOS)
		dbSkip()
	EndDo
	(cAliasOS)->(dbCloseArea())

	NGDBAREAORDE((cTRBOS),02)
	If dbSeek("T")
		RecLock((cTRBVei),.F.)
		(cTRBVei)->BLOQPT := "T"
		(cTRBVei)->(MsUnLock())
	EndIf

	dbSelectArea( cTRBOS )
	dbSetOrder( 1 )
	dbGoTop()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985ES
Atualiza Entradas e Saidas mostradas no browse
@author Felipe N. Welter
@since 19/02/09
@version undefined
@param cCODVei, characters, Codigo do Veiculo selecionado
@param cFILVei, characters, Filial do Veiculo selecionado
@param cEMPVei, characters, Empresa do Veiculo selecionado
@type function
/*/
//---------------------------------------------------------------------
Function MNT985ES( cCODVei,cFILVei,cEMPVei )

	Local _cGetDB   := TCGetDb()
	Local nX, nReg  := 1
	Local lMNTA985A	:= ExistBlock("MNTA985A")

	//Variaveis usadas na criação dos campos do Usuario.
	Local nK        := 0
	Local nC        := 0

	//Alias Utilizado na Query
	Private cAliasES := GetNextAlias()

	// Carrega ultima/corrente viagem em aTRAVEL
	aTRAVEL := If(lMVROTAS,M985Viagem(cCODVei,cFILVei,cEMPVei),{})

	//Limpa E/S da tabela
	dbSelectArea(cTRBES)
	cSeek := (cTRBES)->FILTTI+(cTRBES)->CODVEI+DTOS((cTRBES)->DTMOV)+(cTRBES)->HRMOV
	ZAP

	cQuery := " SELECT TTI.* "
	//Verifica se existe o ponto de entrada e se foi adicionado novos campos
	If ExistBlock("MNTA985B") .And. Len(aDBFES) > nCntES
		//Adiciona Campos criados pelo Usuário.
		For nK := nCntES+1 To Len(aDBFES)
			cQuery += ", TTI."+aDBFES[nK][1]
		Next nK
	EndIf
	cQuery += "FROM "
	cQuery += RetSQLName("TTI")+" TTI "
	//WHERE
	cQuery += " WHERE TTI.TTI_CODVEI = '" + cCODVei + "'"

	cQuery += " AND TTI.TTI_EMPMOV = TTI.TTI_EMPVEI AND TTI.TTI_EMPMOV = '"+SM0->M0_CODIGO+"' "
	If oPanel1:lVisible //na consulta de E/S nao filtra por data
		cQuery += " AND (TTI.TTI_DTENT >= '"+DTOS(dDataBase - nMVVARSHES)+"' OR TTI.TTI_DTSAI >= '"+DTOS(dDataBase - nMVVARSHES)+"') "
	EndIf

	If !oPanel1:lVisible
		cQuery += " AND TTI.TTI_DTENT||TTI.TTI_HRENT >= '" + cRecTTIIni + "' AND TTI.TTI_DTENT||TTI.TTI_HRENT <= '" + cRecTTIFim +"'"
	EndIf

	//VERIFICA DELETE
	cQuery += " AND TTI.D_E_L_E_T_ <> '*' "
	//ORDER BY
	cQuery += " ORDER BY TTI.TTI_DTENT||TTI.TTI_HRENT DESC"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasES, .F., .T.)

	dbSelectArea( cAliasES )
	ProcRegua( M985RecCnt( cAliasES ) )

	While !EoF()
		IncProc()

		If ((cAliasES)->TTI_TIPMOV) == "1"
			//Na consulta de E/S nao filtra por data
			If (STOD((cAliasES)->TTI_DTENT) >= (dDataBase - nMVVARSHES)) .Or. !oPanel1:lVisible
				(cTRBES)->(dbAppend())
				(cTRBES)->EMPTTI := (cAliasES)->TTI_EMPMOV
				(cTRBES)->FILTTI := (cAliasES)->TTI_FILMOV
				(cTRBES)->EMPST9 := (cAliasES)->TTI_EMPVEI
				(cTRBES)->FILST9 := (cAliasES)->TTI_FILVEI
				(cTRBES)->CODVEI := (cAliasES)->TTI_CODVEI
				(cTRBES)->DTMOV  := STOD((cAliasES)->TTI_DTENT)
				(cTRBES)->HRMOV  := (cAliasES)->TTI_HRENT
				(cTRBES)->TIPO   := "1"
				(cTRBES)->MOTORI := (cAliasES)->TTI_MOTENT
				(cTRBES)->NOME   := NGSEEK("DA4",(cAliasES)->TTI_MOTENT,1,"DA4->DA4_NOME")
				(cTRBES)->POS1   := (cAliasES)->TTI_POS1EN
				(cTRBES)->POS2   := (cAliasES)->TTI_POS2EN
				(cTRBES)->OBS    := (cAliasES)->TTI_OBSENT
				(cTRBES)->DESTINO:= NGSEEKSM0((cAliasES)->TTI_EMPMOV+(cAliasES)->TTI_FILMOV,{"M0_NOME"})[1]
				(cTRBES)->ORD    := nReg++
				(cTRBES)->RECNUM := (cAliasES)->R_E_C_N_O_

				//Verifica se foi adicionado campos no PE-MNTA985C
				If lMNTA985A .And. Len(aDBFES) > nCntES
					//Adiciona campos criados pelo Usuário
					For nC := nCntES+1 To Len(aDBFES)
						nx := "(cTRBES)->"+aDBFES[nC][1]
						ny := "(cAliasES)->"+aDBFES[nC][1]
						If !aDBFES[nC][2] == "D"
							&nx. := &ny.
		                Else
							&ny. := STOD(&nx.)
						EndIf
					Next nC
				EndIf
			EndIf

		Else
			//Na consulta de E/S nao filtra por data
			If (STOD((cAliasES)->TTI_DTSAI) >= (dDataBase - nMVVARSHES)) .Or. !oPanel1:lVisible
				(cTRBES)->(dbAppend())
				(cTRBES)->EMPTTI := (cAliasES)->TTI_EMPMOV
				(cTRBES)->FILTTI := (cAliasES)->TTI_FILMOV
				(cTRBES)->EMPST9 := (cAliasES)->TTI_EMPVEI
				(cTRBES)->FILST9 := (cAliasES)->TTI_FILVEI
				(cTRBES)->CODVEI := (cAliasES)->TTI_CODVEI
				(cTRBES)->DTMOV  := STOD((cAliasES)->TTI_DTSAI)
				(cTRBES)->HRMOV  := (cAliasES)->TTI_HRSAI
				(cTRBES)->TIPO   := "2"
				(cTRBES)->MOTORI := (cAliasES)->TTI_MOTSAI
				(cTRBES)->NOME   := NGSEEK("DA4",(cAliasES)->TTI_MOTSAI,1,"DA4->DA4_NOME")
				(cTRBES)->POS1   := (cAliasES)->TTI_POS1SA
				(cTRBES)->POS2   := (cAliasES)->TTI_POS2SA
				(cTRBES)->OBS    := (cAliasES)->TTI_OBSSAI
				If lMVROTAS
					nIndic := 01
					cChave := SM0->M0_CODIGO + xFilial("TTI") + (cAliasES)->TTI_ROTASA
					(cTRBES)->DESTINO:= NGSEEK('TTT',cChave,nIndic,'TTT_NMROTA')
				EndIf
				(cTRBES)->ORD    := nReg++
				(cTRBES)->RECNUM := (cAliasES)->R_E_C_N_O_

				//Verifica se foi adicionado campos no PE-MNTA985C
				If lMNTA985A .And. Len(aDBFES) > nCntES
					//Adiciona campos criados pelo Usuário
					For nC := nCntES+1 To Len(aDBFES)
						nx := "(cTRBES)->"+aDBFES[nC][1]
						ny := "(cAliasES)->"+aDBFES[nC][1]
						If !aDBFES[nC][2] == "D"
							&nx. := &ny.
						Else
							&ny. := STOD(&nx.)
						EndIf
					Next nC
				EndIf
			EndIf
			//na consulta nao filtra por data
			If (STOD((cAliasES)->TTI_DTENT) >= (dDataBase - nMVVARSHES)) .Or. !oPanel1:lVisible
				(cTRBES)->(dbAppend())
				(cTRBES)->EMPTTI := (cAliasES)->TTI_EMPMOV
				(cTRBES)->FILTTI := (cAliasES)->TTI_FILMOV
				(cTRBES)->EMPST9 := (cAliasES)->TTI_EMPVEI
				(cTRBES)->FILST9 := (cAliasES)->TTI_FILVEI
				(cTRBES)->CODVEI := (cAliasES)->TTI_CODVEI
				(cTRBES)->DTMOV  := STOD((cAliasES)->TTI_DTENT)
				(cTRBES)->HRMOV  := (cAliasES)->TTI_HRENT
				(cTRBES)->TIPO   := "1"
				(cTRBES)->MOTORI := (cAliasES)->TTI_MOTENT
				(cTRBES)->NOME   := NGSEEK("DA4",(cAliasES)->TTI_MOTENT,1,"DA4->DA4_NOME")
				(cTRBES)->POS1   := (cAliasES)->TTI_POS1EN
				(cTRBES)->POS2   := (cAliasES)->TTI_POS2EN
				(cTRBES)->OBS    := (cAliasES)->TTI_OBSENT
				(cTRBES)->DESTINO:= NGSEEKSM0((cAliasES)->TTI_EMPMOV+(cAliasES)->TTI_FILMOV,{"M0_NOME"})[1]
				(cTRBES)->ORD    := nReg++
				(cTRBES)->RECNUM := (cAliasES)->R_E_C_N_O_

				//Verifica se foi adicionado campos no PE-MNTA985C
				If lMNTA985A .And. Len(aDBFES) > nCntES
					//Adiciona campos criados pelo Usuário
					For nC := nCntES+1 To Len(aDBFES)
						nx := "(cTRBES)->"+aDBFES[nC][1]
						ny := "(cAliasES)->"+aDBFES[nC][1]
						If !aDBFES[nC][2] == "D"
							&nx. := &ny.
						Else
							&ny. := STOD(&nx.)
						EndIf
					Next nC
				EndIf
			EndIf

		EndIf

		dbSelectArea(cAliasES)
		dbSkip()

	EndDo
	(cAliasES)->(dbCloseArea())

	dbSelectArea(cTRBES)
	dbGoTop()

	//Atualiza no browse a localizacao atual
	If (cTRBVei)->(!EoF())
		If (cTRBES)->(!EoF())
			dbSelectArea(cTRBVei)
			Reclock((cTRBVei),.F.)
			(cTRBVei)->LOCAL := If((cTRBES)->TIPO == "2" .And. !lMVROTAS,STR0165,(cTRBES)->DESTINO)  //"Em Viagem"
			(cTRBVei)->TIPMOV := (cTRBES)->TIPO
			(cTRBVei)->EMPTTI := (cTRBES)->EMPTTI
			(cTRBVei)->FILTTI := (cTRBES)->FILTTI
			(cTRBVei)->(MsUnLock())
			oListVei:Refresh()
		Else
			aUltTTI := M985UltTTI(cCODVei,cFILVei,cEMPVei,1,{"TTI_DTSAI","TTI_ROTASA"})
			If !Empty(aUltTTI)
				nIndic := 01
				cChave := SM0->M0_CODIGO + xFilial("TTI") + aULTTTI[6]
				dbSelectArea(cTRBVei)
				Reclock((cTRBVei),.F.)
				(cTRBVei)->LOCAL := If(Empty(aULTTTI[5]),;
				NGSEEKSM0(aUltTTI[1]+aUltTTI[2],{"M0_NOME"})[1],;
				If(lMVROTAS,NGSEEK('TTT',cChave,nIndic,'TTT_NMROTA'),STR0165))  //"Em Viagem"
				(cTRBVei)->TIPMOV := If(Empty(aUltTTI[5]),"1","2")
				(cTRBVei)->EMPTTI := aUltTTI[1]
				(cTRBVei)->FILTTI := aUltTTI[2]
				(cTRBVei)->(MsUnLock())
				oListVei:Refresh()
			Else
				Reclock((cTRBVei),.F.)
				(cTRBVei)->LOCAL  := ""
				(cTRBVei)->TIPMOV := ""
				(cTRBVei)->EMPTTI := ""
				(cTRBVei)->FILTTI := ""
				(cTRBVei)->(MsUnLock())
				oListVei:Refresh()
			EndIf
		EndIf
	EndIf

	NGDBAREAORDE((cTRBES),01)
	If !dbSeek(cSeek)
		dbGoTop()
	EndIf

	//Ordena para apresentacao na tela
	dbSelectArea(cTRBES)
	dbSetOrder(2)
	dbGoTop()

	oListES:Refresh()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985LUPA
Rotina para Visualizacao
@author Felipe N. Welter
@since 20/02/09
@version undefined
@param cTABELA, characters, Tabela que se deseja visualizar
@param cCHAVE , characters, Chave de busca
@param nORD   , numeric   , Ordem de busca
@type function
@obs A rotina trata especificamente cada uma das tabelas aceitas,
sendo que para algumas alguns parametros tornam-se obrigat.
/*/
//---------------------------------------------------------------------
Function MNT985LUPA(cTABELA,cCHAVE,nORD)

	Local cArea     := GetArea()
	Local aOldMenu  := ACLONE(asMenu)
	Local cOldCad   := If(Type("cCADASTRO") <> "U",cCADASTRO,"")
	Local aOldNgBtn := ACLONE(aNgButton)
	Local lVIS      := .T.

	Default nORD := 01

	Private aNgButton := {}

	If cTABELA == "TTK"
		cCADASTRO := Oemtoansi(STR0071) //"[Controle de Portaria] - Visualizar Visitante"
	ElseIf cTABELA == "TTI" .And. lENTRADA
		cCADASTRO := Oemtoansi(STR0072) //"[Controle de Portaria] - Visualizar Entrada"
	ElseIf cTABELA == "TTI" .And. lSAIDA
		cCADASTRO := Oemtoansi(STR0073) //"[Controle de Portaria] - Visualizar Saida"
	EndIf

	If cCHAVE != Nil
		dbSelectArea(cTABELA)
		dbSetOrder(nORD)
		If !dbSeek(cCHAVE)
			lVIS := .F.
		EndIf
	EndIf

	If lVIS
		INCLUI := .F.
		NGCAD01(cTABELA,Recno(),2)
	EndIf

	RestArea(cArea)
	asMenu := ACLONE(aOldMenu)
	cCADASTRO := cOldCad
	aNgButton := ACLONE(aOldNgBtn)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} M985RFRSH
Atualizacao (reprocessamento) dos registros
@author Felipe N. Welter
@since 24/02/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function M985RFRSH()

	If(oFolder:aDIALOGS[1]:lVisibleControl) 						//FOLDER FROTA esta ativo
		Processa({|lEnd| MNT985VEI(cDeEF,cAteEF,cTipList)},STR0001) //"Aguarde... Atualizando Veículos"
		MNT985SEL((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA)
	ElseIf(oFolder:aDIALOGS[2]:lVisibleControl) 				    //FOLDER VISITANTES esta ativo
		Processa({ |lEnd| MNT985VIS()},STR0002)  					//"Aguarde... Atualizando Visitantes"
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985HOS
Historico de ordem de servico do Bem
@author Felipe N. Welter
@since 18/02/09
@version undefined
@param cCODFil, characters, Filial do Veiculo
@param cCODVei, characters, Codigo do Veiculo
@type function
/*/
//---------------------------------------------------------------------
Function MNT985HOS(cCODFil,cCODVei)

	Private aRotina := {}

	dbSelectArea("ST9")
	dbSetOrder(01)
	If dbSeek(cCODFIL+cCODVei)
		MNA080CON(cCODVei)
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985IMP
Impressao da ordem de servico
@author Felipe N. Welter
@since 19/02/09
@version undefined
@param cOrdSer, characters, Ordem de Servico
@param cEmpOS, characters, Codigo da Empresa da O.S.
@param cFilOS, characters, Codigo da Filial da O.S.
@type function
/*/
//---------------------------------------------------------------------
Function MNT985IMP(cOrdSer,cEmpOS,cFilOS)

	Local OldProg := cPrograma
	Local cDefEmp := If(FindFunction("FWGrpCompany"),FWGrpCompany(),SM0->M0_CODIGO)
	Local cDefFil := If(FindFunction("FWCodFil"),FWCodFil(),SM0->M0_CODFIL)

	Default cEmpOS := cDefEmp
	Default cFilOS := cDefFil

	If !Empty(cEmpOS) .And. !Empty(cFilOS)
		NgPrepTbl({{"AC9"},{"ACB"},{"SA2"},{"SB1"},{"SH4"},{"SH7"},{"SHB"},{"SI3"},{"ST0"},{"ST1"},{"ST4"},{"STC"}, {"STD"},;
				   {"STE"},{"STF"},{"STI"},{"STJ"},{"STL"},{"STQ"},{"SYP"},{"TAF"},{"TPR"},{"TPA"},{"TPL"},{"TQB"}},cEmpOS,cFilOS)
		NGPrepTBL({{"ST9"},{"STB"},{"ST5"}},(cTRBVei)->EMPRESA)
		dbSelectArea("STJ")
		If dbSeek(cFilOS+cOrdSer,.F.)
			U_IMP675(STJ->TJ_ORDEM,STJ->TJ_PLANO,.F.,STJ->TJ_FILIAL,STJ->(RECNO()))
		Else
			ShowHelpDlg("OSNAOEXISTE",{STR0160,""},2,;  //"A O.S. que se deseja imprimir não existe."
							          {STR0060,""},2)  //"Selecione uma Ordem de Serviço válida."
		EndIf
		NgPrepTbl({{"AC9"},{"ACB"},{"SA2"},{"SB1"},{"SH4"},{"SH7"},{"SHB"},{"SI3"},{"ST0"},{"ST1"},{"ST4"},{"STC"},{"STD"},;
				   {"STE"},{"STF"},{"STI"},{"STJ"},{"STL"},{"STQ"},{"SYP"},{"TAF"},{"TPR"},{"TPA"},{"TPL"},{"TQB"}},cDefEmp,cDefFil)
		NGPrepTBL({{"ST9"},{"STB"},{"ST5"}},cEmpAnt)
	EndIf
	cPrograma := OldProg
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985VIS
Processa/Grava Visitantes para montar o browse inicial
@author Felipe N. Welter
@since 23/02/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNT985VIS()

	Local i := 0
	Local x := 0
	Local y := 0

	Private cAliasQry := GetNextAlias()

	dbSelectArea((cTRBVis))
	dbGoTop()
	ZAP

	//SELECT
	cQuery := " SELECT TTK.* "
	//JOINS
	cQuery += " FROM "+RetSQLName("TTK")+" TTK "
	//WHERE
	cQuery += " WHERE "
	cQuery += " TTK_DTSAI = '' "
	//VERIFICA FILIAIS
	cQuery += " AND TTK.TTK_FILIAL = '"+xFilial("TTK")+"' "
	//VERIFICA DELETE
	cQuery += " AND TTK.D_E_L_E_T_ <> '*' "
	//ORDER BY
	cQuery += " ORDER BY TTK.TTK_FILIAL, TTK.TTK_PLACA "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	ProcRegua(RecCount())
	dbGoTop()

	While !EoF()
		/*monta o TRB dinâmico da aba de visitantes*/
		IncProc()
		dbSelectArea(cTRBVis)
		(cTRBVis)->(dbAppend())
		For i := 1 To (cTRBVis)->(FCount())

			If Field(i) != "BITMAP"
				x := "(cAliasQry)->TTK_" + Field(i)
				y := "(cTRBVis)->" + SubStr(Field(i),At('_',Field(i))+1)

				If ValType(&y) == "D"
					Replace &y With SToD(&x.)
				Else
				Replace &y With IIF(Field(i) == "CORVEI", Tabela("M7",(cAliasQry)->TTK_CORVEI,.F.), &x)
				EndIf

			EndIf

		Next i

		dbSelectArea(cAliasQry)
		dbSkip()

	EndDo
	(cAliasQry)->(dbCloseArea())

	dbSelectArea(cTRBVis)
	dbGoTop()

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} M985VISENT
Entrada de Visitantes
@type function

@author Felipe N. Welter
@since 23/02/09

@sample M985VISENT()

@param	[nOption], Númerico, Indica a operção que esta sendo executada.
@return .T.
/*/
//---------------------------------------------------------------------------
Function M985VISENT( nOption )

	Local aOldNgBtn  := aClone( aNgButton )
	Local cOldCad    := IIf( Type( 'cCADASTRO' ) <> 'U', cCADASTRO, '' )
	Local nX         := 0
	Local lRet       := .T.

	Private aCOLS    := {}
	Private aRELAC   := {}
	Private aVARNAO  := {}
	Private aCHOICE  := {}
	Private bNGGRAVA := {}
	Private aCHKDEL  := {}
	Private lRefresh := .T.

	Default nOption  := 3

	aNgButton := {}
	cCADASTRO := OemtoAnsi( STR0074 )  //"[Controle de Portaria] - Entrada de Visitantes"
	INCLUI    := nOption == 3
	ALTERA    := nOption == 4

	If (cTRBVis)->( RecCount() ) == 0 .And. nOption != 3

		Help( '', 1, 'ARQVAZIO' )
		lRet := .F.

	Else

		//PE destinado a inclusao de botoes extras no controle de portaria
		If ExistBlock("MNTA9854")
			aUserBtn := aClone(ExecBlock("MNTA9854",.F.,.F., aTITLES))
		EndIf

		//Adiciona botoes de usuario na EnchoiceBar Entrada de visitantes
		If Type("aUserBtn[5]") == "A" .And. Len(aUserBtn[5]) > 0
			For nX := 1 To Len(aUserBtn[1])
				aUserBtn[5,nX,1] := If(aSCan(GetResArray(''),{|x| aUserBtn[5,nX,1]+'.' $ x})==0,"RPMFUNC",aUserBtn[5,nX,1])
				aAdd(aNgButton,{aUserBtn[5,nX,1],aUserBtn[5,nX,2],aUserBtn[5,nX,3],aUserBtn[5,nX,3]})
			Next nX
		EndIf

		//Executa o ponto de entrada, que é utilizado para adicionar novos campos e validações na tela de Entrada de Visitantes.
		If ExistBlock("MNTA985E")
			bNGGRAVA := {|| ExecBlock("MNTA985E", .F., .F., {lEntrada, lSaida, {(cTRBVis)->FILIAL, (cTRBVis)->PLACA, (cTRBVis)->DOCMOT}}), VldVisEnt()}
		Else
			bNGGRAVA := {|| VldVisEnt() }
		EndIf

		If nOption == 3
			aAdd( aRelac, { 'TTK_DTENT', 'dDataBase' } )
			aAdd( aRelac, { 'TTK_HRENT', 'Time()'    } )
		EndIf

		aAdd(aVARNAO,'TTK_DTSAI')
		aAdd(aVARNAO,'TTK_HRSAI')

		// Ponto de Entrada que ao ser executado vai apresentar em tela o campo criado de Entrada.
		If ExistBlock("MNTA985I")
			ExecBlock("MNTA985I",.F.,.F.,{lENTRADA,lSAIDA,{(cTRBVis)->FILIAL, (cTRBVis)->PLACA, (cTRBVis)->DOCMOT}})
		EndIf

		aCHOICE := NGCAMPNSX3("TTK",aVARNAO)
		aAdd(aCHOICE,'NOUSER')  //mantem apenas campos de usuario de aCHOICE

		dbSelectArea("TTK")
		dbSetOrder(01)

		If ALTERA
			dbSeek( xFilial( 'TTK' ) + (cTRBVis)->PLACA + DtoS( (cTRBVis)->DTENT ) + (cTRBVis)->HRENT )
		EndIf

		nRet := NGCAD01( 'TTK', Recno(), nOption )

		If nRet > 0
			Processa({ |lEnd| MNT985VIS()},STR0002)  //"Aguarde... Atualizando Visitantes"
		EndIf

	EndIf

	aNgButton := ACLONE(aOldNgBtn)
	cCADASTRO := cOldCad

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} VldVisEnt
Faz a consistencia antes de gravar a entrada do Visitante
@author Felipe N. Welter
@since 23/02/09
@version undefined
@type function
@obs uso M985VISENT
/*/
//---------------------------------------------------------------------
Static Function VldVisEnt()

	Local lRet := .T.

	// Validações exclusivas para inclusão.
	If INCLUI

		If (M->TTK_DTENT > dDataBase)
			lRet := .F.
			Help(" ",1,"NGATENCAO",,STR0075,3,1)  //"Data de Entrada não pode ser maior do que a data atual"
		EndIf

		If (M->TTK_DTENT == dDataBase) .And. (M->TTK_HRENT >= Time())
			lRet := .F.
			Help(" ",1,"NGATENCAO",,STR0076,3,1)  //"Hora de Entrada não pode ser maior do que a hora atual"
		EndIf

		If lRet

			dbSelectArea("TTK")
			dbSetOrder(01)
			If dbSeek(xFilial("TTK")+M->TTK_PLACA)

				If Empty(TTK->TTK_HRSAI)
					MsgInfo(STR0077+CHR(13)+STR0078,STR0062)  //"Não é possível incluir uma entrada para este veículo pois já existe"##"uma entrada em aberto cadastrada no sistema!"##"Atenção"
					lRet := .F.
				EndIf

				If lRet

					If dbSeek(xFilial("TTK")+M->TTK_PLACA+DTOS(M->TTK_DTENT))

						While !EoF() .And. TTK->TTK_FILIAL == xFilial("TTK") .And. TTK->TTK_PLACA == M->TTK_PLACA .And. DTOS(TTK->TTK_DTENT) == DTOS(M->TTK_DTENT)

							If (TTK->TTK_HRENT == SubStr(M->TTK_HRENT,0,5))
								MsgInfo(STR0079,STR0062)  //"Não é permitido duplicar a entrada para um veículo!"##"Atenção"
								lRet := .F.
								Exit
							EndIf
							dbSkip()

						EndDo

					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} M985VISSAI
Saida de Visitantes
@author Felipe N. Welter
@since 24/02/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function M985VISSAI()

	Local aOldNgBtn := ACLONE(aNgButton)
	Local cOldCad   := If(Type("cCADASTRO") <> "U",cCADASTRO,"")
	Local nX := 0
	Local oDlgSai
	Local cPlaca := Replicate(" ",TAMSX3("TTK_PLACA")[1])
	Local cDoc   := Replicate(" ",TAMSX3("TTK_DOCMOT")[1])

	aNgButton := {}
	cCADASTRO := OemtoAnsi(STR0080)  //"Saída de Visitantes"

	INCLUI := .F.
	//PE destinado a inclusao de botoes extras no controle de portaria
	If ExistBlock("MNTA9854")
		aUserBtn := aClone(ExecBlock("MNTA9854",.F.,.F., aTITLES))
	EndIf
	//Adiciona botoes de usuario na EnchoiceBar Saida de visitantes
	If Type("aUserBtn[6]") == "A" .And. Len(aUserBtn[6]) > 0
		For nX := 1 To Len(aUserBtn[1])
			aUserBtn[6,nX,1] := If(aSCan(GetResArray(''),{|x| aUserBtn[6,nX,1]+'.' $ x})==0,"RPMFUNC",aUserBtn[6,nX,1])
			aAdd(aNgButton,{aUserBtn[6,nX,1],aUserBtn[6,nX,2],aUserBtn[6,nX,3],aUserBtn[6,nX,3]})
		Next nX
	EndIf

	DEFINE MSDIALOG oDlgSai TITLE cCADASTRO From 6.5,0 To 20,58 OF oDlg

	oPnlScr := TPanel():New(00,00,,oDlgSai,,,,,,230,230,.F.,.F.)
	oPnlScr:Align := CONTROL_ALIGN_ALLCLIENT

	@ 00,00 SCROLLBOX oScr VERTICAL SIZE 51,230 OF oPnlScr BORDER

	@ 10.0,5.0  SAY STR0027 Of oScr Pixel //"Placa"
	@ 00.8,04 MSGET cPlaca Picture '@!' Size 50,10 Of oScr
	@ 10.0,103 Say STR0081 Of oScr Pixel  //"Documento"
	@ 00.8,18 MSGET cDoc Picture '@!' Size 70,10 Of oScr

	ACTIVATE MSDIALOG oDlgSai ON INIT EnchoiceBar(oDlgSai,{||If(VldVisSai(cPlaca,cDoc),oDlgSai:End(),.T.)},{||oDlgSai:End()},,@aNgButton) CENTERED

	aNgButton := ACLONE(aOldNgBtn)
	cCADASTRO := cOldCad

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} VldVisSai
Grava a saída de Visitantes
@author Felipe N. Welter
@since 24/02/09
@version undefined
@param cPlaca, characters, Placa do Veiculo
@param cDoc  , characters, Documento apresentado
@type function
@obs uso M985VISSAI
/*/
//---------------------------------------------------------------------
Static Function VldVisSai(cPlaca,cDoc)

	Local aOldNgBtn := ACLONE(aNgButton)
	Local cOldCad   := If(Type("cCADASTRO") <> "U",cCADASTRO,"")

	Local lAchou := .F.

    Private aCHOICE := {}
    Private aVARNAO := {}

	//Executa o ponto de entrada, que é utilizado para adicionar novos campos e validações na tela de Saída de Visitantes.
	If ExistBlock("MNTA985E")
		bNGGRAVA := {|| ExecBlock("MNTA985E", .F., .F., {lEntrada, lSaida, {(cTRBVis)->FILIAL, (cTRBVis)->PLACA, (cTRBVis)->DOCMOT}})}
	EndIf

	aBkpVar := {ALTERA , INCLUI} //Backup das variáveis ALTERA e INCLUI

	SetAltera()

	aNgButton := {}
	cCADASTRO := OemtoAnsi(STR0082)  //"[Controle de Portaria] - Saída de Visitantes"

	dbSelectArea("TTK")
	Set Filter To Empty(TTK->TTK_DTSAI)

	If !Empty(cPlaca)
		dbSelectArea("TTK")
		dbSetOrder(01)
		If dbSeek(xFilial("TTK")+cPlaca,.F.)
			If AllTrim(cPlaca) == AllTrim(TTK->TTK_PLACA)
				lAchou := .T.
			EndIf
		EndIf
	EndIf

	If !Empty(cDoc) .And. !lAchou
		dbSelectArea("TTK")
		dbSetOrder(02)
		If dbSeek(xFilial("TTK")+cDoc,.F.)
			If AllTrim(cDoc) == AllTrim(TTK->TTK_DOCMOT)
				lAchou := .T.
			EndIf
		EndIf
	EndIf

	If Empty(cPlaca) .And. Empty(cDoc)
		MsgInfo(STR0083,STR0080)  //"Preencha pelo menos um dos campos Placa/Documento."##"Saída de Visitantes"
	Else
		If lAchou

		// Ponto de Entrada que ao ser executado vai apresentar em tela o campo criado de Entrada.
		If ExistBlock("MNTA985I")
			ExecBlock("MNTA985I",.F.,.F.,{lENTRADA,lSAIDA,{(cTRBVis)->FILIAL, (cTRBVis)->PLACA, (cTRBVis)->DOCMOT}})
		EndIf

		aCHOICE := NGCAMPNSX3("TTK",aVARNAO)
		aAdd(aCHOICE,'NOUSER')  //mantem apenas campos de usuario de aCHOICE

			RecLock("TTK",.F.)
			TTK->TTK_DTSAI := dDataBase
			TTK->TTK_HRSAI := Time()
			MsUnLock("TTK")

			nRet := NGCAD01("TTK",Recno(),4)

			ALTERA := aBkpVar [1]
			INCLUI := aBkpVar [2]

			If (nRet == 0)
				RecLock("TTK",.F.)
				TTK->TTK_DTSAI := STOD('  /  /  ')
				TTK->TTK_HRSAI := '     '
				MsUnLock("TTK")
			Else
				Processa({ |lEnd| MNT985VIS()},STR0002)  //"Aguarde... Atualizando Visitantes"
			EndIf
		Else
			MsgInfo(STR0084+CHR(13)+STR0085,STR0080)  //"Não existe registro para essa pessoa/placa."##"Favor registrar sua entrada."##"Saída de Visitantes"
		EndIf
	EndIf

	dbSelectArea("TTK")
	Set Filter To

	aNgButton := ACLONE(aOldNgBtn)
	cCADASTRO := cOldCad

Return lAchou

//---------------------------------------------------------------------
/*/{Protheus.doc} M985LEG
Cria uma janela contendo a legenda da mBrowse
@author Felipe N. Welter
@since 04/06/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function M985LEG()

	Local aLegenda := {{"br_verde"   ,STR0086},;  //"Normal"
					   {"br_amarelo" ,STR0087},;  //"Em Execucao Prevista"
					   {"br_vermelho",STR0088}}   //"Atrasada"

	Local cCADASTRO := Oemtoansi(STR0089)  //"[Controle de Portaria] - Ordens de Serviço"

	BrwLegenda(cCADASTRO,STR0017,aLegenda) //"Legenda"

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985STL
Grava a array com os insumos da Ordem de Servico
@author Felipe N. Welter
@since 07/07/09
@version undefined
@param cORDEMSTL, characters, Numero da O.S. Original
@param cPLANOSTL, characters, Numero do Plano da O.S.
@param cFIL     , characters, Filial da O.S. Original
@param cEMP     , characters, Empresa da O.S. Original
@type function
@obs  Retorna - aINSUMSTL - Array com os insumos previstos da O.S.
/*/
//---------------------------------------------------------------------
Static Function MNT985STL(cORDEMSTL,cPLANOSTL,cFIL,cEMP)

	Local aINSUMSTL := {}

	dbSelectArea("STL")
	dbSetOrder(01)
	If dbSeek(NGTROCAFILI("STL",cFIL,cEMP)+cORDEMSTL+cPLANOSTL)
		While !EoF() .And. STL->TL_ORDEM = cORDEMSTL .And. STL->TL_PLANO = cPLANOSTL
			If STL->TL_TIPOREG $ "EFP" .And. AllTrim(STL->TL_SEQRELA) == '0'
				aAdd(aINSUMSTL,{STL->TL_TAREFA   ,; //01
								STL->TL_TIPOREG  ,; //02
								STL->TL_CODIGO   ,; //03
								STL->TL_QUANREC  ,; //04
								STL->TL_QUANTID  ,; //05
								STL->TL_UNIDADE  ,; //06
								STL->TL_DESTINO  ,; //07
								STL->TL_DTINICI  ,; //08
								STL->TL_HOINICI  ,; //09
								STL->TL_DTFIM    ,; //10
								STL->TL_HOFIM    ,; //11
								STL->TL_LOCAL    ,; //12
								STL->TL_TIPOHOR  ,; //13
								STL->TL_USACALE  ,; //14
								STL->TL_CUSTO })    //15
			EndIf
			dbSelectArea("STL")
			dbSkip()
		End
	EndIf

Return aINSUMSTL

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985STQ
Grava a array com as etapas da Ordem de Servico
@author Felipe N. Welter
@since  07/07/09
@version undefined
@param cORDEMSTQ, characters, Numero da O.S. Original
@param cPLANOSTQ, characters, Numero do Plano da O.S.
@param cFIL     , characters, Filial da O.S. Original
@param cEMP     , characters, Empresa da O.S. Original
@type function
@obs Retorna -  aINSUMSTQ - Array com os etapas
/*/
//---------------------------------------------------------------------
Static Function MNT985STQ(cORDEMSTQ,cPLANOSTQ,cFIL,cEMP)

	Local aINSUMSTQ := {}

	dbSelectArea("STQ")
	dbSetOrder(01)
	If dbSeek(NGTROCAFILI("STQ",cFIL,cEMP)+cORDEMSTQ+cPLANOSTQ)
		While !EoF() .And. STQ->TQ_ORDEM = cORDEMSTQ .And. STQ->TQ_PLANO = cPLANOSTQ
			If Empty(STQ->TQ_OK)
				aAdd(aINSUMSTQ,{STQ->TQ_TAREFA,STQ->TQ_ETAPA,STQ->TQ_SEQETA})
			EndIf
			dbSelectArea("STQ")
			dbSkip()
		EndDo
	EndIf

Return aINSUMSTQ

//---------------------------------------------------------------------
/*/{Protheus.doc} M985STLSTQ
Grava as etapas e insumos previstos
@author Felipe N. Welter
@since 07/07/09
@version undefined
@param cORDEM   , characters, Numero da Ordem de Servico Origem
@param cPLANOOS , characters, Numero do plano da Ordem de Servico Origem
@param aTAREFA  , array     , Array contendo os insumos para gravar
@param aETAPAS  , array     , Array contendo as etapas para gravar
@param cCENTCUS , characters, Codigo do centro de custo
@param cNewOS   , characters, Numero da Ordem de Servico Destino
@param cNewPlano, characters, Numero do plano da Ordem de Servico Destino
@param cFilOri  , characters, Filial da Ordem de Servico Origem
@param cEmpOri  , characters, Empresa da Ordem de Servico Origem
@param cFilDes  , characters, Filial da Ordem de Servico Destino
@param cEmpDes  , characters, Empresa de Ordem de Servico Destino
@type function
@obs Retorna -  aBLO - Array com os insumos para fazer bloqueio
/*/
//---------------------------------------------------------------------
Static Function M985STLSTQ(cORDEM,cPLANOOS,aTAREFA,aETAPAS,cCENTCUS,cNewOS,cNewPlano,cFilOri,cEmpOri,cFilDes,cEmpDes)

	Local aBLO    := { {},{},{},{},{}}
	Local i
	Local n

	// Tabelas Temporarias
	Local oTmpTblSTL // Detalhes da Ordem de Serviço
	Local oTmpTblSTQ // Etapas Executadas
	Local oTmpTblTPQ // Opções das Etapas da O.S.

	// Indices
	Local aIdxSTL := {"TL_ORDEM","TL_CODIGO"}
	Local aIdxSTQ := {"TQ_ORDEM","TQ_PLANO","TQ_TAREFA","TQ_ETAPA"}
	Local aIdxTPQ := {"TPQ_ORDEM","TPQ_PLANO","TPQ_TAREFA","TPQ_ETAPA","TPQ_OPCAO"}

	// Alias das Tabelas
	Local cAliSTL
	Local cAliSTQ
	Local cAliTPQ

	dbSelectArea("STL")
	Private cEmpInfo := SM0->M0_CODIGO//Substr(DBINFO(DBI_FULLPATH),4,2)

	NgPrepTbl({{"STL"},{"STI"},{"STQ"},{"TPQ"}},cEmpOri)

	//+-----------------------------------------------------------------------+
	//| Copia insumos Especialidade/Ferramenta/Produto em Tabela Temporaria   |
	//+-----------------------------------------------------------------------+
	NGDBAREAORDE("STL",01)
	cFilSTL := NGTROCAFILI("STL",cFilOri,cEmpOri)
	aCampos := dbStruct()

	//Alias: cAliSTL (Detalhes da Ordem de Serviço)
	cAliSTL := GetNextAlias()
	oTmpTblSTL := fTempTable(cAliSTL, aCampos, aIdxSTL)

	For i := 1 to Len(aTAREFA)
		dbSelectArea("STL")
		If dbSeek(cFilSTL+cORDEM+cPLANOOS+aTAREFA[i,1]+aTAREFA[i,2]+aTAREFA[i,3])
			If STL->TL_TIPOREG == "E"
				cAliMd := "ST0"
			ElseIf STL->TL_TIPOREG == "P"
				cAliMd := "SB1"
			ElseIf STL->TL_TIPOREG == "F"
				cAliMd := "SH4"
			EndIf

			(cAliSTL)->(dbAppend())
			For n := 1 to Fcount()
				ny := "(cAliSTL)->"+FieldName(n)
				nx := "STL->"+FieldName(n)
				&ny. := &nx.
			Next n
			(cAliSTL)->(MsUnlock())

			// Verifica Bloqueio
			dbSelectArea("STI")
			If dbSeek(NGTROCAFILI("STI",cFilOri,cEmpOri)+cPLANOOS)
				nTIP := 0
				If aTAREFA[i][2] == "E"
					nTIP := If(STI->TI_BLOQFUN == "S",3,0)
				ElseIf aTAREFA[i][2] == "F"
					nTIP := If(STI->TI_BLOQFER == "S",1,0)
				ElseIf aTAREFA[i][2] == "P"
					nTIP := If(STI->TI_BLOQITE == "S",4,0)
				EndIf
				If nTIP > 0
					lGrvBLO := .T.
					If nTIP == 4
						//Aglutina produto igual
						nPosBlo := aScan(aBLO[nTIP],{|x| x[2]+x[11] = aTAREFA[i][3]+aTAREFA[i][12]})
						If nPosBlo > 0
							aBLO[nTIP][nPosBlo][3] += If(aTAREFA[i][2]$"E/F",aTAREFA[i][4],aTAREFA[i][5])
							lGrvBLO := .F.
						Else
							lGrvBLO := .T.
						EndIf
					EndIf
					If lGrvBLO
						aAdd(aBLO[nTIP], {aTAREFA[i][1]   ,;
						aTAREFA[i][3]   ,;
						If(aTAREFA[i][2]$"E/F",aTAREFA[i][4],aTAREFA[i][5]),;
						aTAREFA[i][8]   ,;
						aTAREFA[i][9]   ,;
						aTAREFA[i][10]  ,;
						aTAREFA[i][11]  ,;
						cNewOS          ,;
						cNewPlano       ,;
						cCENTCUS        ,;
						aTAREFA[i][12]  ,;
						aTAREFA[i][6]  })
					EndIf
				EndIf
			EndIf
		EndIf
	Next i

	// Copia Etapas Executadas e Opcoes das Etapas
	NGDBAREAORDE("STQ",01)
	cFilSTQ := NGTROCAFILI("STQ",cFilOri,cEmpOri)
	aCampos := dbStruct()

	//Alias: cAliSTQ (Etapas Executadas)
	cAliSTQ := GetNextAlias()
	oTmpTblSTQ := fTempTable(cAliSTQ, aCampos, aIdxSTQ)

	NGDBAREAORDE("TPQ",01)
	cFilTPQ := NGTROCAFILI("STQ",cFilOri,cEmpOri)
	aCampos := dbStruct()

	//Alias: cAliTPQ (Opçoes Etapas da O.S.)
	cAliTPQ := GetNextAlias()
	oTmpTblTPQ := fTempTable(cAliTPQ, aCampos, aIdxTPQ)

	For i := 1 to Len(aETAPAS)
		dbSelectArea("STQ")
		If dbSeek(cFilSTQ+cORDEM+cPLANOOS+aETAPAS[i,1]+aETAPAS[i,2])
			(cAliSTQ)->(dbAppend())
			For n := 1 to Fcount()
				ny := "(cAliSTQ)->"+FieldName(n)
				nx := "STQ->"+FieldName(n)
				&ny. := &nx.
			Next n
			(cAliSTQ)->(MsUnlock())

			dbSelectArea("TPQ")
			If dbSeek(cFilTPQ+cORDEM+cPLANOOS+aETAPAS[i,1]+aETAPAS[i,2])
				While !EoF() .And. TPQ->TPQ_FILIAL == cFilTPQ .And. TPQ->TPQ_ORDEM == cORDEM .And. TPQ->TPQ_PLANO == cPLANOOS .And. ;
				TPQ->TPQ_TAREFA == STQ->TQ_TAREFA .And. TPQ->TPQ_ETAPA == STQ->TQ_ETAPA

					(cAliTPQ)->(dbAppend())
					For n := 1 to Fcount()
						ny := "(cAliTPQ)->"+FieldName(n)
						nx := "TPQ->"+FieldName(n)
						&ny. := &nx.
					Next n
					(cAliTPQ)->(MsUnlock())
					dbSelectArea("TPQ")
					dbSkip()
				End
			EndIf
		EndIf
	Next i

	NgPrepTbl({{"STL"},{"STI"},{"STQ"},{"TPQ"}},cEmpDes)

	// Grava STL
	dbSelectArea(cAliSTL)
	dbGoTop()
	While !EoF()
		dbSelectArea("STL")
		RecLock("STL",.T.)
		dbSelectArea("STL")
		For i := 1 To Fcount()
			ny := "STL->" + FieldName(i)
			nx := "(cAliSTL)->" + FieldName(i)
			If "TL_FILIAL" $ ny
				STL->TL_FILIAL := NGTROCAFILI("STL",cFilDes,cEmpDes)
			ElseIf "TL_ORDEM" $ ny
				STL->TL_ORDEM := cNewOS
			ElseIf "TL_PLANO" $ ny
				STL->TL_PLANO := cNewPlano
			Else
				&ny. := &nx.
			EndIf
		Next i
		STL->(MsUnlock())
		dbSelectArea(cAliSTL)
		dbSkip()
	EndDo

	// Grava STQ
	dbSelectArea(cAliSTQ)
	dbGoTop()
	While !EoF()
		dbSelectArea("STQ")
		RecLock("STQ",.T.)
		dbSelectArea("STQ")
		For i := 1 To Fcount()
			ny := "STQ->" + FieldName(i)
			nx := "(cAliSTQ)->" + FieldName(i)
			If "TQ_FILIAL" $ ny
				STQ->TQ_FILIAL := NGTROCAFILI("STQ",cFilDes,cEmpDes)
			ElseIf "TQ_ORDEM" $ ny
				STQ->TQ_ORDEM := cNewOS
			ElseIf "TQ_PLANO" $ ny
				STQ->TQ_PLANO := cNewPlano
			Else
				&ny. := &nx.
			EndIf
		Next i
		STQ->(MsUnlock())
		dbSelectArea(cAliSTQ)
		dbSkip()
	EndDo

	// Grava TPQ
	dbSelectArea(cAliTPQ)
	dbGoTop()
	While !EoF()
		dbSelectArea("TPQ")
		RecLock("TPQ",.T.)
		dbSelectArea("TPQ")
		For i := 1 To Fcount()
			ny := "TPQ->" + FieldName(i)
			nx := "(cAliTPQ)->" + FieldName(i)
			If "TPQ_FILIAL" $ ny
				TPQ->TPQ_FILIAL := NGTROCAFILI("TPQ",cFilDes,cEmpDes)
			ElseIf "TPQ_ORDEM" $ ny
				TPQ->TPQ_ORDEM := cNewOS
			ElseIf "TPQ_PLANO" $ ny
				TPQ->TPQ_PLANO := cNewPlano
			Else
				&ny. := &nx.
			EndIf
		Next i
		TPQ->(MsUnlock())
		dbSelectArea(cAliTPQ)
		dbSkip()
	EndDo

	NgPrepTbl({{"STL"},{"STI"},{"STQ"},{"TPQ"}},cEmpInfo)

	oTmpTblSTL:Delete()
	oTmpTblSTQ:Delete()
	oTmpTblTPQ:Delete()

Return aBLO

//---------------------------------------------------------------------
/*/{Protheus.doc} M985Filtro
Realiza todos os processos relacionados a filtro de veiculos
@author Felipe N. Welter
@since 02/03/09
@version undefined
@param nOpcao, numeric, Numero do processo a ser executado
@type function
@obs uso M985VISSAI
/*/
//---------------------------------------------------------------------
Static Function M985Filtro(nOpcao)

	Do Case
		Case nOpcao == 0 	//0 - Na abertura do Panel de Filtro
			lBTN := .F.
			oPnl11:Show()
			oDeEF:SetFocus()
		Case nOpcao == 1 	//1 - Botao OK
			Processa({|lEnd|MNT985VEI(cDeEF,cAteEF,cTipList)},STR0001)  //"Aguarde... Atualizando Veículos"
			MNT985SEL((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA)
			lBTN := .T.
			aGlbSave := {cDeEF,cAteEF,cTipList}
			oPnl11:Hide()
		Case nOpcao == 2 //2 - Botao Cancela
			lBTN  := .T.
			cDeEF := aGlbSave[1]
			cAteEF := aGlbSave[2]
			cTipList := aGlbSave[3]
			oPnl11:Hide()
			oListVei:Refresh()
			oPanel1:Refresh()
			oSplitter:Refresh()
			oDlg:Refresh()
	Endcase
	//Forca a atualizacao do ListVei para correcao de um 'bug'
	//que ocorre ao fazer o Hide()
	cursorwait();cursorarrow()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} M985Pesq
Monta a tela para Localizar Veiculo pelo Codigo ou Placa
@author Felipe N. Welter
@since 03/03/09
@version undefined
@param nOpcao, numeric, Numero do processo a ser executado
@type function
/*/
//---------------------------------------------------------------------
Function M985Pesq(nOpcao)

	Do Case
		Case nOpcao == 0 	//0 - Na abertura do Panel de Pesquisa
			lBTN    := .F.
			cPesqEF := (cTRBVei)->FILIAL
			cBoxEF  := If(cCombo==aCombo[1],(cTRBVei)->CODBEM,(cTRBVei)->PLACA)
			oPnl12:Show()
			oBoxEF:SetFocus()
			dbSelectArea("SM0")
		Case nOpcao == 1 //1 - Botao OK
			aVei := MNT985PESQ(cCombo,cPesqEF,cBoxEF)
			If aVei != Nil 	//Carrega ultima/corrente viagem em aTRAVEL
				aTRAVEL := If(lMVROTAS,M985Viagem(aVei[3],aVei[2],aVei[1]),{})
				If lENTRADA .And. lSAIDA
					lENTRADA := .F.
					lSAIDA := .F.
					MNTA985CNS(1)
				ElseIf lENTRADA
					If MNT985ENT(3)
						MNT985SEL((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA)
					EndIf
					lENTRADA := .F.
				ElseIf lSAIDA
					If MNT985SAI(3)
						MNT985SEL((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA)
					EndIf
					lSAIDA := .F.
				Else
					MNT985SEL(aVei[3],aVei[2],aVei[1])
				EndIf
			Else
				MsgInfo(STR0117,STR0062)  //"Veículo não localizado!"##"Atenção"
			EndIf
			lBTN := .T.
			oPnl12:Hide()
			dbSelectArea("SM0")
			Set Filter To
		Case nOpcao == 2 	//2 - Botao Cancela
			lENTRADA := .F.
			lSAIDA := .F.
			lBTN := .T.
			oPnl12:Hide()
	EndCase
	//Forca a atualizacao do ListVei para correcao de um 'bug' que ocorre ao fazer o Hide()
	cursorwait();cursorarrow()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985PESQ
Pesquisa e posiciona um veiculo no listbox de veiculos
@author Felipe N. Welter
@since 05/05/09
@version undefined
@param cCrit, characters, Criterio para pesquisa (um dos contidos em aCombo)
@param cEmpFil, characters, Empresa
@param cCont  , characters, Conteudo
@type function
/*/
//---------------------------------------------------------------------
Function MNT985PESQ(cCrit,cEmpFil,cCont)

	//Se for MultiEmpresa pesquisa direto pelo codigo do bem
	//Se nao for, pesquisa por filial+codbem [(xFilial("ST9").Or.cPesqEF)]

	Local lAchou := .F.
	Local aRet := Nil

	dbSelectArea(cTRBVei)
	nRec := RecNo()

	If cCrit == aCombo[1] //CODIGO
		nIND := 01
		cCON := cEmpFil+cCont
		dbSelectArea(cTRBVei)
		dbSetOrder(nIND)
		If dbSeek(cCON)
			lAchou := .T.
		EndIf
	ElseIf cCrit == aCombo[2] //PLACA
		dbSelectArea(cTRBVei)
		dbSetOrder(04)
		If dbSeek(cCont)
			lAchou := .T.
		EndIf
	EndIf

	If lAchou
		aRet := {(cTRBVei)->EMPRESA,(cTRBVei)->FILIAL,(cTRBVei)->CODBEM}
	Else
		dbGoTo(nRec)
	EndIf

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985ENT
Entrada de Veiculos
@author Felipe N. Welter
@since 05/05/09
@version undefined
@param nOpcX, numeric, descricao
@type function
/*/
//---------------------------------------------------------------------
Function MNT985ENT(nOpcX)

	Local lRet      := .T.
	Local lAbriuOS  := .F.
	Local aOldNgBtn := aClone(aNgButton)
	Local cOldEmp   := cEmpAnt
	Local cDataEnt  := ""
	Local cAlsQry   := GetNextAlias()
	Local nX        := 0

	//Variaveis para NGCAD01 (TTI)
	Private cCADASTRO := Oemtoansi(STR0118)  //"[Controle de Portaria] - Entrada de Veículo"
	Private aRELAC    := {}
	Private aVARNAO   := {}
	Private aCHOICE   := {}
	Private bNGGRAVA  := {|| GravEnt985()}
	Private aNgButton := {{"PARAMETROS" ,{||lAbriuOS := MNT985IOS()},STR0119,STR0120}} //"Abrir O.S. Corretiva"##"Abrir O.S."
	Private cROTA     := ""
	Private nOpc      := nOpcX  //variavel acessivel pelos PE's
	Private vDadoAtu  := {}

	//Variaveis para contadores
	Private cHORCON1 := cHORCON2  := '  :  '
	Private TIPOACOM := TIPOACOM2 := .F.
	Private lCHKCON1 := lCHKCON2  := .F.
	//PE destinado a inclusao de botoes extras no controle de portaria
	If ExistBlock("MNTA9854")
		aUserBtn := aClone(ExecBlock("MNTA9854",.F.,.F., aTITLES))
	EndIf
	//Adiciona botoes de usuario na EnchoiceBar Entrada de Frota
	If Type("aUserBtn[7]") == "A" .And. Len(aUserBtn[7]) > 0
		For nX := 1 To Len(aUserBtn[1])
			aUserBtn[7,nX,1] := If(aSCan(GetResArray(''),{|x| aUserBtn[7,nX,1]+'.' $ x})==0,"RPMFUNC",aUserBtn[7,nX,1])
			aAdd(aNgButton,{aUserBtn[7,nX,1],aUserBtn[7,nX,2],aUserBtn[7,nX,3],aUserBtn[7,nX,3]})
		Next nX
	EndIf

	//Prepara ALIAS's
	NGPrepTBL({{"ST9"},{"STP"},{"TPE"},{"TPP"},{"TQS"},{"TT8"},{"STZ"}},(cTRBVei)->EMPRESA)

	//WHEN dos campos de Contador
	dbSelectArea("ST9")
	dbSetOrder(01)
	dbSeek((cTRBVei)->FILIAL+(cTRBVei)->CODBEM)
	TIPOACOM := If(ST9->T9_TEMCONT = "S",.T.,.F.)
	//FindFunction remover na release GetRPORelease() >= '12.1.027'
	If FindFunction("MNTCont2")
		TIPOACOM2 := MNTCont2(NGTROCAFILI("TPE",(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA), (cTRBVei)->CODBEM )
	Else
		dbSelectArea("TPE")
		dbSetOrder(01)
		TIPOACOM2 := If(dbSeek(NGTROCAFILI("TPE",(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA)+(cTRBVei)->CODBEM),.T.,.F.)
	EndIf

	If nOpcX != 3
		dbSelectArea("TTI")
		dbGoTo((cTRBES)->RECNUM)
		If !TIPOACOM2
			vDadoAtu := {If(NGSX2MODO("STP")=="E",TTI->TTI_FILVEI,xFilial("STP")),TTI->TTI_EMPVEI,TTI->TTI_FILVEI,TTI->TTI_CODVEI,DTOS(TTI->TTI_DTENT),TTI->TTI_HRENT,TTI->TTI_POS1EN}
		Else
			vDadoAtu := {If(NGSX2MODO("STP")=="E",TTI->TTI_FILVEI,xFilial("STP")),TTI->TTI_EMPVEI,TTI->TTI_FILVEI,TTI->TTI_CODVEI,DTOS(TTI->TTI_DTENT),TTI->TTI_HRENT,TTI->TTI_POS1EN,TTI->TTI_POS2EN}
		EndIf
	EndIf

	//WHEN dos campos de Rota/Escala
	If lMVROTAS
		lROTA := .F.
		lESCALA := If(Empty(aTRAVEL) .Or. (nOpcX != 3), .F. , .T. ) //primeira Entrada
	EndIf

	If nOpcX == 3
		aAdd(aRELAC,{"TTI_EMPMOV","SM0->M0_CODIGO"})
		aAdd(aRELAC,{"TTI_FILMOV","FWCodFil()"})
		aAdd(aRELAC,{"TTI_EMPVEI","(cTRBVei)->EMPRESA"})
		aAdd(aRELAC,{"TTI_FILVEI","(cTRBVei)->FILIAL"})
		aAdd(aRELAC,{"TTI_CODVEI","(cTRBVei)->CODBEM"})
		aAdd(aRELAC,{"TTI_DTENT" ,"Date()"})
		aAdd(aRELAC,{"TTI_HRENT" ,"Time()"})
		aAdd(aRELAC,{"TTI_TIPMOV","'1'"   })
		aAdd(aRELAC,{"TTI_POS1EN","ST9->T9_POSCONT"})
		aAdd(aRELAC,{"TTI_POS2EN","TPE->TPE_POSCON"})
	EndIf

	aAdd(aRELAC,{"TTI_USUENT","SubStr(cUserName,1,25)"})

	//seleciona dados referente a movimentacao anterior
	If nOpcX == 3
		dData := dDataBase
		cHora := Substr(Time(),1,5)
		aUltTTI := M985UltTTI((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA,1,{"TTI_ROTAEN","TTI_ESCENT"},dData,cHora,1)
		aNxtTTI := M985UltTTI((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA,1,{"TTI_ROTAEN","TTI_ESCENT"},dData,cHora,2)
		If Empty(aUltTTI) .And. !Empty(aNxtTTI)
			ShowHelpDlg("INVALIDO",{"Data/hora é anterior ao intervalo de movimentações.",""},2,{"Altere data/hora maiores que a entrada inicial.",""},2)
			lRet := .F.
		EndIf
	EndIf

	//If !NGIFDBSEEK("TTI",(cTRBVei)->EMPRESA+(cTRBVei)->FILIAL+(cTRBVei)->CODBEM,3)
	If lMVROTAS
		If nOpcX == 3 .And. Empty(aTRAVEL)
			aAdd(aRELAC,{"TTI_ROTAEN","cMVEntIn"})
			aAdd(aRELAC,{"TTI_DESROT","'ENTRADA INICIAL NO SISTEMA'"})
			aAdd(aRELAC,{'TTI_OBSENT',"'ENTRADA INICIAL NO SISTEMA'+Space(TAMSX3('TTI_OBSENT')[1]-25)"})
			aAdd(aRELAC,{'TTI_ESCENT',"'000'"})
			aAdd(aRELAC,{'TTI_DESESC',"NGRETSX3BOX('TTS_TIPESC','4')"})
		Else

			If nOpcX == 3 .Or. nOpcX == 4

				If Len( aTRAVEL ) > 0
					cROTA := aTRAVEL[1,4]
				Else
					cROTA := TTI->TTI_ROTAEN
				EndIf

			EndIf

			aAdd(aRELAC,{"TTI_ROTAEN","cROTA"})
			aAdd(aRELAC,{"TTI_DESROT","NGSEEK('TTT',cROTA,2,'TTT_NMROTA')"})

			nIndic := 05
			cChave := SM0->M0_CODIGO+xFilial("TTI") + cROTA+;
			          If(FindFunction("FWGrpCompany"),FWGrpCompany(),SM0->M0_CODIGO)+;
			          If(FindFunction("FWCodFil"),FWCodFil(),SM0->M0_CODFIL)
			cChave1 := If(!Empty(NGSEEK('TTS',cChave,nIndic,'TTS_DESCRI')) .And. NGSEEK('TTS',cChave,nIndic,'TTS_TIPESC') != "1",;
			cChave,SubStr(cChave,1,Len(cChave)-2-Len(TTS->TTS_FILESC))+Replicate('0',Len(TTS->TTS_FILESC)))
			aAdd(aRELAC,{'TTI_ESCENT',"If(cROTA==cMVEntIn,'000',NGSEEK('TTS',cChave1,nIndic,'TTS_CODIGO'))"})
			aAdd(aRELAC,{'TTI_DESESC',"If(cROTA==cMVEntIn,NGRETSX3BOX('TTS_TIPESC','4'),NGSEEK('TTS',cChave1,nIndic,'TTS_DESCRI'))"})
		EndIf
	EndIf

	aAdd(aVARNAO,'TTI_ROTASA')
	aAdd(aVARNAO,'TTI_ESCSAI')
	aAdd(aVARNAO,'TTI_MOTSAI')
	aAdd(aVARNAO,'TTI_DTSAI' )
	aAdd(aVARNAO,'TTI_HRSAI' )
	aAdd(aVARNAO,'TTI_POS1SA')
	aAdd(aVARNAO,'TTI_POS2SA')
	aAdd(aVARNAO,'TTI_OBSSAI')
	aAdd(aVARNAO,'TTI_USUENT')
	aAdd(aVARNAO,'TTI_USUSAI')
	If !lMVROTAS
		aAdd(aVARNAO,'TTI_ROTAEN')
		aAdd(aVARNAO,'TTI_DESROT')
		aAdd(aVARNAO,'TTI_ESCENT')
		aAdd(aVARNAO,'TTI_DESESC')
	EndIf

	// Ponto de Entrada que ao ser executado vai apresentar em tela o campo criado de Entrada.
	If ExistBlock("MNTA9858")
		ExecBlock("MNTA9858",.F.,.F.,{lENTRADA,lSAIDA,{(cTRBVei)->EMPRESA,(cTRBVei)->FILIAL,(cTRBVei)->CODBEM}})
	EndIf

	//Valida se pode realizar a ENTRADA
	If nOpcX == 3
		If (cTRBVei)->TIPMOV == "1"
			NGDBAREAORDE("TTI",01)
			dbSeek(xFilial("TTI")+(cTRBVei)->EMPTTI+(cTRBVei)->FILTTI+(cTRBVei)->EMPRESA+(cTRBVei)->FILIAL+(cTRBVei)->CODBEM+"1")
			cMsg := STR0121+AllTrim(TTI->TTI_CODVEI)+", "+CHR(13)  //"Não é possível cadastrar uma entrada para o veículo "
			cMsg += STR0122+CHR(13)+CHR(13)  					   //"pois já existe uma entrada informada no sistema."
			cMsg += STR0123+CHR(13)  		 					   //"Entrada realizada em: "
			cMsg += STR0049+": "+DTOC(TTI->TTI_DTENT)+CHR(13)      //"Data"
			cMsg += STR0050+": "+TTI->TTI_HRENT+CHR(13)+CHR(13)    //"Hora"
			cMsg += STR0124  									   //"Deseja visualizar esse registro?"
			If MsgNoYes(cMsg,STR0062)  							   //"Atenção"
				aCHOICE := NGCAMPNSX3("TTI",aVARNAO)
				aAdd(aCHOICE,'NOUSER')  						   //Mantem apenas campos de usuario de aCHOICE
				MNT985LUPA("TTI")
			EndIf
			lRet := .F.
		EndIf
	ElseIf nOpcX == 5
		//nao pode haver saida associada
		If TTI->TTI_TIPMOV == '2'
			ShowHelpDlg("INVALIDO",{STR0177,""},2,{STR0178,""},2)  //"Não é possível excluir entrada com saída associada."##"Realize a exclusão da saída anteriormente."
			lRet := .F.
		EndIf
	EndIf

	If lRet
		//+-------------------------------------------------------------------+
		//| PE para tratamento de variaveis antes da montagem da tela         |
		//+-------------------------------------------------------------------+
		If ExistBlock("MNTA9852")
			// Foi alterado a chamada direta da User Function pelo ExecBlock pelo motivo de pendência Débito Técnico
			ExecBlock("MNTA9852",.F.,.F.,{lENTRADA,lSAIDA,{(cTRBVei)->EMPRESA,(cTRBVei)->FILIAL,(cTRBVei)->CODBEM}})
		EndIf
		aCHOICE := NGCAMPNSX3("TTI",aVARNAO)
		aAdd(aCHOICE,'NOUSER')  //Mantem apenas campos de usuario de aCHOICE
		//Realiza a ENTRADA
		If nOpcX == 3
			SetInclui()
		ElseIf nOpcX == 4
			SetAltera()
		EndIf
		If nOpcX <> 3
			cDataEnt := DTOS((cTRBES)->DTMOV)

			BeginSql Alias cAlsQry
			SELECT TTI.R_E_C_N_O_ FROM %Table:TTI% TTI
				WHERE TTI.%NotDel% AND
					TTI.TTI_EMPMOV = %exp:(cTRBVei)->EMPTTI%  AND
					TTI.TTI_FILMOV = %exp:(cTRBVei)->FILTTI%  AND
					TTI.TTI_EMPVEI = %exp:(cTRBVei)->EMPRESA% AND
					TTI.TTI_FILVEI = %exp:(cTRBVei)->FILIAL%  AND
					TTI.TTI_CODVEI = %exp:(cTRBVei)->CODBEM%  AND
					TTI.TTI_DTENT  = %exp:cDataEnt% AND
					TTI.TTI_HRENT  = %exp:(cTRBES)->HRMOV%
			EndSql
		EndIf
		If Select(cAlsQry) > 0
			lRet := (NGCAD01("TTI", (cAlsQry)->R_E_C_N_O_,nOpcX) > 0)
			(cAlsQry)->(dbCloseArea())
		Else
			lRet := ( NGCAD01("TTI",Recno(),nOpcX) > 0)
		EndIf

		//P.E para customizações após entrada na portaria
		If lRet .And. nOpcX == 3
			If ExistBlock("MNTA985F")
				ExecBlock("MNTA985F",.F.,.F.,{(cTRBVei)->CODBEM})
			EndIf
		EndIf

		INCLUI := .F.
		ALTERA := .F.

	EndIf

	//Retorna ALIAS's original
	NGPrepTBL({{"ST9"},{"STP"},{"TPE"},{"TPP"},{"TQS"},{"TT8"},{"STZ"}},cOldEmp)
	aNgButton := ACLONE(aOldNgBtn)

Return (lRet .Or. lAbriuOS) //Retorno indica se deve atualizar browse


//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985SAI
Saida de Veiculos
@author Felipe N. Welter
@since 11/05/09
@version undefined
@param nOpcX, numeric, descricao
@type function
/*/
//---------------------------------------------------------------------
Function MNT985SAI(nOpcX)

	Local lRet      := .T.
	Local aOldNgBtn := ACLONE(aNgButton)
	Local cOldEmp   := cEmpAnt
	Local dData
	Local cHora
	Local nX := 0

	//Variaveis para NGCAD01 (TTI)
	Private cCADASTRO := Oemtoansi(STR0125)  //"[Controle de Portaria] - Saída de Veículo"
	Private aRELAC    := {}
	Private aVARNAO   := {}
	Private aCHOICE   := {}
	Private bNGGRAVA  := {|| GravSai985()}
	Private INCLUI    := .F.
	Private aNgButton := {}
	Private nOpc      := nOpcX  //Variavel acessivel pelos PE's

	//Variaveis para contadores
	Private cHORCON1 := cHORCON2 := '  :  '
	Private TIPOACOM := TIPOACOM2 := .F.
	Private lCHKCON1 := lCHKCON2 := .F.
	//PE destinado a inclusao de botoes extras no controle de portaria
	If ExistBlock("MNTA9854")
		aUserBtn := aClone(ExecBlock("MNTA9854",.F.,.F., aTITLES))
	EndIf
	//Adiciona botoes de usuario na EnchoiceBar Saida de Frota
	If Type("aUserBtn[8]") == "A" .And. Len(aUserBtn[8]) > 0
		For nX := 1 To Len(aUserBtn[1])
			aUserBtn[8,nX,1] := If(aSCan(GetResArray(''),{|x| aUserBtn[8,nX,1]+'.' $ x})==0,"RPMFUNC",aUserBtn[8,nX,1])
			aAdd(aNgButton,{aUserBtn[8,nX,1],aUserBtn[8,nX,2],aUserBtn[8,nX,3],aUserBtn[8,nX,3]})
		Next nX
	EndIf

	//Prepara ALIAS's
	NGPrepTBL({{"ST9"},{"STP"},{"TPE"},{"TPP"},{"TQS"},{"TT8"},{"STZ"}},(cTRBVei)->EMPRESA)

	//WHEN dos campos de Contador
	dbSelectArea("ST9")
	dbSetOrder(01)
	dbSeek((cTRBVei)->FILIAL+(cTRBVei)->CODBEM)
	TIPOACOM := If(ST9->T9_TEMCONT = "S",.T.,.F.)
	//FindFunction remover na release GetRPORelease() >= '12.1.027'
	If FindFunction("MNTCont2")
		TIPOACOM2 := MNTCont2( NGTROCAFILI("TPE",(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA), (cTRBVei)->CODBEM )
	Else
		dbselectarea("TPE")
		dbsetorder(01)
		TIPOACOM2 := If(dbSeek(NGTROCAFILI("TPE",(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA)+(cTRBVei)->CODBEM),.T.,.F.)
	EndIf

	If nOpcX != 3
		dbSelectArea("TTI")
		dbGoTo((cTRBES)->RECNUM)
		If !TIPOACOM2
			vDadoAtu := {If(NGSX2MODO("STP")=="E",TTI->TTI_FILVEI,xFilial("STP")),TTI->TTI_EMPVEI,TTI->TTI_FILVEI,TTI->TTI_CODVEI,DTOS(TTI->TTI_DTSAI),TTI->TTI_HRSAI,TTI->TTI_POS1SA}
		Else
			vDadoAtu := {If(NGSX2MODO("STP")=="E",TTI->TTI_FILVEI,xFilial("STP")),TTI->TTI_EMPVEI,TTI->TTI_FILVEI,TTI->TTI_CODVEI,DTOS(TTI->TTI_DTSAI),TTI->TTI_HRSAI,TTI->TTI_POS1SA,TTI->TTI_POS2SA}
		EndIf
	EndIf

	//seleciona dados referente a movimentacao anterior
	dData := If(nOpcX==3,dDataBase,TTI->TTI_DTSAI)
	cHora := If(nOpcX==3,Substr(Time(),1,5),TTI->TTI_HRSAI)
	aUltTTI := M985UltTTI((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA,1,{"TTI_ROTAEN","TTI_ESCENT"},dData,cHora,1)
	aNxtTTI := M985UltTTI((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA,1,{"TTI_ROTAEN","TTI_ESCENT"},dData,cHora,2)
	If Empty(aUltTTI) .And. !Empty(aNxtTTI) .And. nOpcX <> 2
		ShowHelpDlg("INVALIDO",{STR0183,""},2,{STR0184,""},2) //"Data/hora é anterior ao intervalo de movimentações."##"Altere data/hora maiores que a entrada inicial."
		lRet := .F.
	EndIf

	//WHEN dos campos de Rota/Escala
	If lRet .And. !Empty(aTRAVEL) //em decorrencia de lMVROTAS

		If !Empty(aUltTTI)
			nIndic := 01
			cChave := SM0->M0_CODIGO + xFilial("TTI") + aUltTTI[5] + aUltTTI[6]
			aAdd(aUltTTI,NGSEEK("TTS",cChave,nIndic,"TTS_TIPESC"))
			lROTA := If(aUltTTI[5] == cMVEntIn .Or. aUltTTI[7] == "3", .T. , .F. ) //Entrada Inicial .Or. Fim de Viagem
			lESCALA := .F.
		Else
			lROTA := .T.
			lESCALA := .F.
		EndIF

		//Se a rota ja estiver sendo usada em outra movimentacao da mesma viagem, nao permite alterar
		If lRet .And. nOpcX != 3
			aNxtTTI := M985UltTTI((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA,1,{"TTI_ROTAEN","TTI_ESCENT"},dData,cHora,2)
			lROTA := !Empty(aNxtTTI) .And. TTI->TTI_ROTASA != aNxtTTI[5]
		EndIf

		If lRet .And. !lROTA
			If nOpcX != 3
				nIndiS := 01
				cChavS := SM0->M0_CODIGO+xFilial("TTI") + TTI->TTI_ROTASA + TTI->TTI_ESCSAI
				aAdd(aRELAC,{"TTI_DESESC","NGSEEK('TTS',cChavS,nIndiS,'TTS_DESCRI')"})
			Else
				aAdd(aRELAC,{"TTI_ROTASA","aUltTTI[5]"})
				aAdd(aRELAC,{"TTI_ESCSAI","TTI->TTI_ESCENT"})
				nIndiS := 01
				cChavS := SM0->M0_CODIGO+xFilial("TTI") + aUltTTI[5] + aUltTTI[6]
				aAdd(aRELAC,{"TTI_DESESC","NGSEEK('TTS',cChavS,nIndiS,'TTS_DESCRI')"})
			EndIf
		EndIf
	EndIf

	If lRet .And. nOpcX == 3
		aAdd(aRELAC,{"TTI_DTSAI","dDataBase"})
		aAdd(aRELAC,{"TTI_HRSAI","Time()"})
		aAdd(aRELAC,{"TTI_TIPMOV","'2'"})
		aAdd(aRELAC,{"TTI_POS1SA","ST9->T9_POSCONT"})
		aAdd(aRELAC,{"TTI_POS2SA","TPE->TPE_POSCON"})
	EndIf

	aAdd(aRELAC,{"TTI_USUSAI","SubStr(cUserName,1,25)"})

	aAdd(aVARNAO,'TTI_ROTAEN')
	aAdd(aVARNAO,'TTI_ESCENT')
	aAdd(aVARNAO,'TTI_MOTENT')
	aAdd(aVARNAO,'TTI_DTENT' )
	aAdd(aVARNAO,'TTI_HRENT' )
	aAdd(aVARNAO,'TTI_POS1EN')
	aAdd(aVARNAO,'TTI_POS2EN')
	aAdd(aVARNAO,'TTI_OBSENT')
	aAdd(aVARNAO,'TTI_USUENT')
	aAdd(aVARNAO,'TTI_USUSAI')
	If !lMVROTAS
		aAdd(aVARNAO,'TTI_ROTASA')
		aAdd(aVARNAO,'TTI_DESROT')
		aAdd(aVARNAO,'TTI_ESCSAI')
		aAdd(aVARNAO,'TTI_DESESC')
	EndIf

	// Ponto de Entrada que ao ser executado vai apresentar em tela o campo criado de saída.
	If ExistBlock("MNTA9858")
		ExecBlock("MNTA9858",.F.,.F.,{lENTRADA,lSAIDA,{(cTRBVei)->EMPRESA,(cTRBVei)->FILIAL,(cTRBVei)->CODBEM}})
	EndIf

	If lRet
		If nOpcX == 3
			dbSelectArea((cTRBOS))
			If (EoF() .And. Empty(cTRBOS)) .Or. (!EoF() .And. (cTRBOS)->CODBEM != (cTRBVei)->CODBEM)
				MNT985SEL((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA)
			EndIf

			If (cTRBVei)->BLOQPT == "T"
				MsgAlert(STR0126+CHR(13)+;  //"Existe pelo menos um Servico / Sintoma / Etapa nas Ordens de Servico"
						 STR0127,STR0128)   //"que bloqueia a saida deste veículo!"##"Bloqueio de Saída"
				lRet := .F.
			EndIf

			//Ponto de entrada para disconciderar a validação de documentos vencidos
			If ExistBlock("MNTA985D")
				lRet := ExecBlock("MNTA985D",.F.,.F.,{lENTRADA,lSAIDA,{(cTRBVei)->EMPRESA,(cTRBVei)->FILIAL,(cTRBVei)->CODBEM}})
			ElseIf lRet //Valida documentos vencidos
				lRet := M985TS2VEN((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA)
			EndIf

		ElseIf nOpcX == 5
			//Não pode haver entrada pendente no sistema
			cAliasQry := GetNextAlias()
			cQuery := "SELECT * FROM "+RetSQLName("TTI")
			cQuery += " WHERE TTI_CODVEI = '"+(cTRBVei)->CODBEM+"' AND TTI_FILVEI = '"+(cTRBVei)->FILIAL+"' AND TTI_EMPVEI = '"+(cTRBVei)->EMPRESA+"'"
			cQuery += " AND TTI_TIPMOV = '1' AND D_E_L_E_T_ <> '*'"
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			If (cAliasQry)->(!EoF())
				ShowHelpDlg("INVALIDO",{STR0179,""},2,{STR0180,""},2)  //"Não é possível excluir saída se houver entrada pendente para o bem."##"Conclua as operações de entrada/saída pendentes."
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())

			//Quando usa rotas, so pode excluir se for a saida mais recente
			If lRet .And. lMVROTAS
				aNxtTTI := M985UltTTI((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA,1,{"TTI_ROTAEN","TTI_ESCENT"},TTI->TTI_DTSAI,TTI->TTI_HRSAI,2)
				If !Empty(aNxtTTI)
					ShowHelpDlg("INVALIDO",{STR0181,""},2,{STR0182,""},2)  //"Não é possível excluir saída em viagem já iniciada."##"Necessário excluir movimentações posteriores a essa saída."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	//Valida se pode realizar a SAIDA
	If nOpcX == 3
		If lRet
			If (cTRBVei)->TIPMOV == "1"
				NGDBAREAORDE("TTI",01)
				If dbSeek(xFilial("TTI")+(cTRBVei)->EMPTTI+(cTRBVei)->FILTTI+(cTRBVei)->EMPRESA+(cTRBVei)->FILIAL+(cTRBVei)->CODBEM+"1")
					If (TTI->TTI_EMPMOV != cEmpAnt .Or. TTI->TTI_FILMOV != cFilAnt)
						ShowHelpDlg("INVALIDO",{STR0129,""},2,;  //"Empresa/Filial correntes não correspondem à última entrada do veículo."
						{STR0130,"("+TTI->TTI_EMPMOV+" - "+AllTrim(NGSEEKSM0(TTI->TTI_EMPMOV+TTI->TTI_FILMOV,{"M0_NOMECOM"})[1])+" / "+;  //"O reporte deve ser feito em: "
						TTI->TTI_FILMOV+" - "+AllTrim(NGSEEKSM0(TTI->TTI_EMPMOV+TTI->TTI_FILMOV,{"M0_NOME"})[1])+")"},2)
						lRet := .F.
					Else
						//+-----------------------------------------------------------------------+
						//| PE para tratamento de variaveis antes da montagem da tela             |
						//+-----------------------------------------------------------------------+
						If ExistBlock("MNTA9852")
							// Foi alterado a chamada direta da User Function pelo ExecBlock pelo motivo de pendência Débito Técnico
							ExecBlock("MNTA9852",.F.,.F.,{lENTRADA,lSAIDA,{(cTRBVei)->EMPRESA,(cTRBVei)->FILIAL,(cTRBVei)->CODBEM}})
						EndIf
						aCHOICE := NGCAMPNSX3("TTI",aVARNAO)
						aAdd(aCHOICE,'NOUSER')  //mantem apenas campos de usuario de aCHOICE
						//Realiza a SAIDA
						SetAltera()
						nRet := NGCAD01("TTI",Recno(),4)
						lRet := (nRet > 0)
						INCLUI := .F.
						ALTERA := .F.
					EndIf
				EndIf
			Else
				lRet := .F.
				cMsg := STR0131+AllTrim((cTRBVei)->CODBEM)+", "+CHR(13)  //"Não é possível informar uma saida para o veículo "
				cMsg += STR0132  //"Pois não existe uma entrada pendente no sistema. "
				If (cTRBVei)->TIPMOV == "2"
					NGDBAREAORDE("TTI",01)
					dbSeek(xFilial("TTI")+(cTRBVei)->EMPTTI+(cTRBVei)->FILTTI+(cTRBVei)->EMPRESA+(cTRBVei)->FILIAL+(cTRBVei)->CODBEM+"2")
					cMsg += STR0133+CHR(13)  							 //"Última saída realizada em: "
					cMsg += STR0049+": "+DTOC(TTI->TTI_DTSAI)+CHR(13)  	 //"Data"
					cMsg += STR0050+": "+TTI->TTI_HRSAI+CHR(13)+CHR(13)  //"Hora"
					cMsg += STR0124 									 //"Deseja visualizar esse registro?"
					If MsgNoYes(cMsg,STR0062)   //"Atenção"
						aCHOICE := NGCAMPNSX3("TTI",aVARNAO)
						aAdd(aCHOICE,'NOUSER')  //mantem apenas campos de usuario de aCHOICE
						MNT985LUPA("TTI")
					EndIf
				Else
					MsgAlert(cMsg,STR0062)  //"Atenção"
				EndIf
			EndIf
		EndIf
	ElseIf lRet
		//+-----------------------------------------------------------------------+
		//| PE para tratamento de variaveis antes da montagem da tela             |
		//+-----------------------------------------------------------------------+
		If ExistBlock("MNTA9852")
			// Foi alterado a chamada direta da User Function pelo ExecBlock pelo motivo de pendência Débito Técnico
			ExecBlock("MNTA9852",.F.,.F.,{lENTRADA,lSAIDA,{(cTRBVei)->EMPRESA,(cTRBVei)->FILIAL,(cTRBVei)->CODBEM}})
		EndIf
		aCHOICE := NGCAMPNSX3("TTI",aVARNAO)
		aAdd(aCHOICE,'NOUSER')  //mantem apenas campos de usuario de aCHOICE
		//Realiza a SAIDA
		If nOpcX != 2 .And. nOpcX != 5
			SetAltera()
			nRet := NGCAD01("TTI",Recno(),4)
		Else
			dbSelectArea( "TTI" )
			dbSetOrder( 2 )
			dbSeek( (cTRBES)->EMPST9 + (cTRBES)->FILST9 + (cTRBES)->EMPTTI + (cTRBES)->FILTTI + DTOS((cTRBES)->DTMOV) + (cTRBES)->HRMOV )
			nRet := NGCAD01("TTI",Recno(),2)
		EndIf
		lRet := (nRet > 0)
		INCLUI := .F.
		ALTERA := .F.
	EndIf

	If nOpcX == 5 .And. lRet

		//Atualiza a posição do contador na ST9 e STP
		If lRet
			If TTI->TTI_POS1SA > 0
				MNT470EXCO(TTI->TTI_CODVEI, TTI->TTI_DTSAI, TTI->TTI_HRSAI,1)
				If TTI->TTI_POS2SA > 0
					MNT470EXCO(TTI->TTI_CODVEI, TTI->TTI_DTSAI, TTI->TTI_HRSAI,2)
				EndIf
			EndIf
		EndIf

		RecLock("TTI",.F.)
		TTI->TTI_TIPMOV := '1'
		TTI->TTI_DTSAI  := CTOD("")
		TTI->TTI_HRSAI  := ''
		TTI->TTI_MOTSAI := ''
		TTI->TTI_ROTASA := ''
		TTI->TTI_ESCSAI := ''
		TTI->TTI_POS1SA := 0
		TTI->TTI_POS2SA := 0
		TTI->TTI_OBSSAI := ''
		TTI->TTI_USUSAI := ''
		MsUnLock("TTI")

	EndIf

	//Retorna ALIAS's original
	NGPrepTBL({{"ST9"},{"STP"},{"TPE"},{"TPP"},{"TQS"},{"TT8"},{"STZ"}},cOldEmp)
	aNgButton := ACLONE(aOldNgBtn)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GravEnt985
Faz a consistencia antes de gravar a entrada do Veículo
@author Felipe N. Welter
@since 11/05/08
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function GravEnt985()

	Local lRet      := .T.
	Local cAliasQry := GetNextAlias()

	If nOpc == 3 .Or.;
	(nOpc == 4 .And. (M->TTI_DTENT != TTI->TTI_DTENT .Or.;
	M->TTI_HRENT != TTI->TTI_HRENT))

		If nOpc == 3
			lRet := M985DtHr("TTI_DTENT")
		EndIf

		If lRet
			cQuery := "SELECT TTI.TTI_EMPVEI, TTI.TTI_CODVEI, TTI.TTI_FILIAL, TTI.TTI_HRENT, TTI.TTI_DTENT, TTI.TTI_HRSAI, TTI.TTI_DTSAI "
			cQuery += " FROM "+RetSQLName("TTI")+" TTI"
			cQuery += " WHERE"
			cQuery += " '"+DTOS(M->TTI_DTENT)+If(Len(M->TTI_HRENT)>5,SubStr(M->TTI_HRENT,1,5),M->TTI_HRENT)+"' >= (TTI.TTI_DTENT||TTI.TTI_HRENT)"
			cQuery += " AND '"+DTOS(M->TTI_DTENT)+If(Len(M->TTI_HRENT)>5,SubStr(M->TTI_HRENT,1,5),M->TTI_HRENT)+"' <= (TTI.TTI_DTSAI||TTI.TTI_HRSAI)"
			cQuery += " AND TTI.TTI_CODVEI = '"+(cTRBVei)->CODBEM+"' AND TTI.TTI_EMPVEI = '"+(cTRBVei)->EMPRESA+"' AND TTI.TTI_FILVEI = '"+(cTRBVei)->FILIAL+"'"
			If nOpc != 3
				cQuery += " AND R_E_C_N_O_ <> '"+cValToChar(TTI->(RecNo()))+"'"
			EndIf
			cQuery += " AND TTI.D_E_L_E_T_ <> '*'"

			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

			//Verifica se o veiculo esta disponivel
			dbSelectArea(cAliasQry)
			dbGoTop()
			If !EoF()
				cMsg := STR0134+CHR(13)  //"O veículo já possui uma entrada para o intervalo de tempo:"
				cMsg += STR0010+": "+DTOC(STOD((cAliasQry)->TTI_DTENT))+STR0135+(cAliasQry)->TTI_HRENT+CHR(13)  //"Entrada"##" às "
				cMsg += STR0011+": "+DTOC(STOD((cAliasQry)->TTI_DTSAI))+STR0135+(cAliasQry)->TTI_HRSAI          //"Saida"##" às "
				MsgInfo(cMsg,STR0062)   //"Atenção"
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet .And. nOpc == 3
		//CONSISTENCIA DOS CONTADORES
		dbSelectArea("TTI")
		If lRet
			If TIPOACOM .And. !lCHKCON1
				If M->TTI_POS1EN > 0
					lRet := M985CCO(M->TTI_CODVEI,M->TTI_POS1EN,M->TTI_DTENT,M->TTI_HRENT,M->TTI_FILVEI,1,.T.)
				Else
					MsgInfo(STR0136,STR0062)  //"Contador 1 é obrigatório!"##"Atenção"
					lRet := .F.
				EndIf
			EndIf

			If lRet .And. TIPOACOM2 .And. !lCHKCON2
				If M->TTI_POS2EN > 0
					lRet := M985CCO(M->TTI_CODVEI,M->TTI_POS2EN,M->TTI_DTENT,M->TTI_HRENT,M->TTI_FILVEI,2,.T.)
				Else
					MsgInfo(STR0137,STR0062)  //"Contador 2 é obrigatório!"##"Atenção"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	// PE para validacoes de cliente na entrada/saida de veiculos
	If lRet
		BEGIN TRANSACTION

			If lRet
				If ExistBlock("MNTA9855")
					lRet := ExecBlock("MNTA9855",.F.,.F.,{lENTRADA,lSAIDA,{(cTRBVei)->EMPRESA,(cTRBVei)->FILIAL,(cTRBVei)->CODBEM}})
				EndIf
			EndIf

			// PE para gravar reporte de contador especifico
			If lRet
				If ExistBlock("MNTA9857")
					lRet := ExecBlock("MNTA9857",.F.,.F.,{lENTRADA,lSAIDA,{(cTRBVei)->EMPRESA,(cTRBVei)->FILIAL,(cTRBVei)->CODBEM}})
				Else
					lRet := M985RetCN(1)
				EndIf
			EndIf

			If !lRet
				//END TRANSACTION
				//Else
				DisarmTransaction()
			EndIf
		END TRANSACTION
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GravSai985
Faz a consistencia antes de gravar a saida do Veiculo
@author Felipe N. Welter
@since 11/05/08
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function GravSai985()

	Local lRet := .T.

	//CONSISTENCIA DOS CONTADORES
	dbSelectArea("TTI")
	If nOpc == 3

		lRet := M985DtHr("TTI_DTSAI", .T.)

		//Se chamado pelo botão de Inclusão Histórico Retroativo
		//Efetua cosistências necessarias.
		If IsInCallStack("MNT985HRET")
			lRet := fVldIncHis()
		EndIf

		If lRet
			If TIPOACOM .And. !lCHKCON1
				If M->TTI_POS1SA > 0
					lRet := M985CCO(M->TTI_CODVEI,M->TTI_POS1SA,M->TTI_DTSAI,M->TTI_HRSAI,M->TTI_FILVEI,1,.T.)
				Else
					MsgInfo(STR0136,STR0062) //"Contador 1 é obrigatório!"##"Atenção"
					lRet := .F.
				EndIf
			EndIf

			If lRet .And. TIPOACOM2 .And. !lCHKCON2
				If M->TTI_POS2SA > 0
					lRet := M985CCO(M->TTI_CODVEI,M->TTI_POS2SA,M->TTI_DTSAI,M->TTI_HRSAI,M->TTI_FILVEI,2,.T.)
				Else
					MsgInfo(STR0137,STR0062)  //"Contador 2 é obrigatório!"##"Atenção"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	// PE para validacoes de cliente na entrada/saida de veiculos
	If lRet
		BEGIN TRANSACTION

			If lRet
				If ExistBlock("MNTA9855")
					lRet := ExecBlock("MNTA9855",.F.,.F.,{lENTRADA,lSAIDA,{(cTRBVei)->EMPRESA,(cTRBVei)->FILIAL,(cTRBVei)->CODBEM}})
				EndIf
			EndIf

			// PE para gravar reporte de contador especifico
			If lRet
				If ExistBlock("MNTA9857")
					lRet := ExecBlock("MNTA9857",.F.,.F.,{lENTRADA,lSAIDA,{(cTRBVei)->EMPRESA,(cTRBVei)->FILIAL,(cTRBVei)->CODBEM}})
				Else
					lRet := M985RetCN(2)
				EndIf
			EndIf

			If !lRet
				//END TRANSACTION
				//Else
				DisarmTransaction()
			EndIf
		END TRANSACTION
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} M985RetCN
Realiza gravacao/alteracao/exclusao de contador pelo CDP
@author Felipe Nathan Welter
@since 15/12/10
@version undefined
@param nTipMov, numeric, Tipo de Movimentacao (1=Entrada;2=Saida)
@type function
/*/
//---------------------------------------------------------------------
Function M985RetCN(nTipMov)

	Local lRet1Cont := .F.
	Local lRet2Cont := .F.
	Local vTTIArr   := {}
	Local lRetGrav	:= .T. //Retorno da função

	If nTipMov == 1  //entrada
		vTTIArr := {M->TTI_DTENT,M->TTI_HRENT,M->TTI_POS1EN,M->TTI_POS2EN}
	ElseIf nTipMov == 2 // saida
		vTTIArr := {M->TTI_DTSAI,M->TTI_HRSAI,M->TTI_POS1SA,M->TTI_POS2SA}
	EndIf

	//Retorna a filial do Bem no periodo
	cFilBem := M->TTI_FILVEI
	cFROTA985 := M->TTI_CODVEI
	aRetTPN := NgFilTPN(M->TTI_CODVEI,vTTIArr[1]/*dt*/,vTTIArr[2]/*hr*/)
	If !Empty(aRetTPN[1]) .And. !Empty(aRetTPN[2])
		cFilBem  := aRetTPN[1]
	EndIf

	If nOpc == 3
		//GRAVA HISTORICO DE CONTADOR
		If TIPOACOM .And. vTTIArr[3] > 0  //pos1
			NGTRETCON(M->TTI_CODVEI,vTTIArr[1]/*dt*/,vTTIArr[3]/*pos1*/,vTTIArr[2]/*hr*/,1,,.F.,,M->TTI_FILVEI)
		EndIf
		If TIPOACOM2 .And. vTTIArr[4] > 0  //pos2
			NGTRETCON(M->TTI_CODVEI,vTTIArr[1]/*dt*/,vTTIArr[4]/*pos2*/,vTTIArr[2]/*hr*/,2,,.F.,,M->TTI_FILVEI)
		EndIf
	ElseIf nOpc == 4
		Begin Transaction
			If TIPOACOM .And. (vTTIArr[3] <> vDadoAtu[7] .Or.;  //contador 1
			DTOS(vTTIArr[1])  <> vDadoAtu[5] .Or.;  //data
			vTTIArr[2]  <> vDadoAtu[6])  //hora
				aARALTC := {'STP','STP->TP_FILIAL','STP->TP_CODBEM',;
							'STP->TP_DTLEITU','STP->TP_HORA','STP->TP_POSCONT',;
							'STP->TP_ACUMCON','STP->TP_VARDIA','STP->TP_VIRACON'}
				aARABEM := {'ST9','ST9->T9_POSCONT','ST9->T9_CONTACU',;
						    'ST9->T9_DTULTAC','ST9->T9_VARDIA'}

				dbSelectArea("STP")
				dbSetOrder(5)
				If dbSeek(xFilial("STP",vDadoAtu[1])+vDadoAtu[4]+vDadoAtu[5]+vDadoAtu[6])
					nDifCont := vTTIArr[3] - STP->TP_POSCONT
					nAcum655 := (STP->TP_ACUMCON - STP->TP_POSCONT) + vTTIArr[3]
					nRECNSTP := Recno()
					lULTIMOP := .T.
					nACUMFIP := 0
					nCONTAFP := 0
					nVARDIFP := 0
					dDTACUFP := CTOD('  /  /  ')
					dbSkip(-1)
					If !EoF() .And. !BoF() .And. &(aARALTC[2]) = xFilial(aARALTC[1],vDadoAtu[1]) .And.;
					&(aARALTC[3]) == vDadoAtu[4]
						nACUMFIP := &(aARALTC[7])
						dDTACUFP := &(aARALTC[4])
						nCONTAFP := IIF(!FindFunction("NGBlCont") .Or. NGBlCont( STP->TP_CODBEM ), &(aARALTC[6]), NGTpCont(&(aARALTC[3]), &(aARALTC[4]), &(aARALTC[5]), &(aARALTC[6])))
						nVARDIFP := &(aARALTC[8])
					EndIf
					dbGoTo(nRECNSTP)
					nACUMDEL := STP->TP_ACUMCON
					RecLock("STP",.F.)
					dbDelete()
					MsUnLock("STP")
					MNTA875ADEL(vDadoAtu[4],StoD(vDadoAtu[5]),vDadoAtu[6],1,cFilBem,cFilBem)
				EndIf
				If !MNT985HOD(1,nTipMov)
					DisarmTransaction()
					lRetGrav := .F.
				EndIf
				If lRetGrav .And. !lVIRADA
					If !NGCHKHISTO(cFROTA985,vTTIArr[1]/*dt*/,vTTIArr[3]/*pos1*/,vTTIArr[2]/*hr*/,1,,.T.,cFilBem)
						DisarmTransaction()
						lRetGrav := .F.
					EndIf
					If lRetGrav .And. !NGVALIVARD(cFROTA985,vTTIArr[3]/*pos1*/,vTTIArr[1]/*dt*/,vTTIArr[2]/*hr*/,1,.T.,,cFilBem)
						DisarmTransaction()
						lRetGrav := .F.
					EndIf
					If lRetGrav
						lRet1Cont := .T.
					EndIf
				EndIf
			EndIf

            If lRetGrav
                If TIPOACOM2 .And. (vTTIArr[4] <> vDadoAtu[8] .Or.; //contador 2
                DTOS(vTTIArr[1])  <> vDadoAtu[5] .Or.;  //data
                vTTIArr[2]  <> vDadoAtu[6])  //hora
                    aARALTC := {'TPP','TPP->TPP_FILIAL','TPP->TPP_CODBEM',;
                                'TPP->TPP_DTLEIT','TPP->TPP_HORA','TPP->TPP_POSCON',;
                                'TPP->TPP_ACUMCO','TPP->TPP_VARDIA','TPP->TPP_VIRACO'}
                    aARABEM := {'TPE','TPE->TPE_POSCON','TPE->TPE_CONTAC',;
                                'TPE->TPE_DTULTA','TPE->TPE_VARDIA'}

                    dbSelectArea("TPP")
                    dbsetorder(5)
                    If dbSeek(xFilial("TPP",vDadoAtu[1])+vDadoAtu[4]+vDadoAtu[5]+vDadoAtu[6])
                        nAcu6552 := (TPP->TPP_ACUMCO - TPP->TPP_POSCON) + vTTIArr[4]
                        nRECNTPP := Recno()
                        lULTIMOP := .T.
                        nACUMFIP := 0
                        nCONTAFP := 0
                        nVARDIFP := 0
                        dDTACUFP := CTOD('  /  /  ')
                        dbSkip(-1)
                        If !Eof() .And. !Bof() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilBem) .And.;
                        &(aARALTC[3]) == vDadoAtu[4]
                            nACUMFIP := &(aARALTC[7])
                            dDTACUFP := &(aARALTC[4])
                            nCONTAFP := &(aARALTC[6])
                            nVARDIFP := &(aARALTC[8])
                        EndIf
                        dbGoTo(nRECNTPP)
                        nACUMDEL := TPP->TPP_ACUMCO
                        RecLock("TPP",.F.)
                        dbDelete()
                        MsUnLock("TPP")
                        MNTA875ADEL(vDadoAtu[4],StoD(vDadoAtu[5]),vDadoAtu[6],2,cFilBem,cFilBem)
                    EndIf
                    If !MNT985HOD(2,nTipMov)
                        DisarmTransaction()
                        lRetGrav := .F.
                    EndIf
                    If lRetGrav .And. !lVIRADA
                        If !NGCHKHISTO(cFROTA985,vTTIArr[1]/*dt*/,vTTIArr[4]/*pos2*/,vTTIArr[2]/*hr*/,2,,.T.,cFilBem)
                            lRetGrav := .F.
                        EndIf
                        If lRetGrav .And. !NGVALIVARD(cFROTA985,vTTIArr[4]/*pos2*/,vTTIArr[1]/*dt*/,vTTIArr[2]/*hr*/,2,.T.,,cFilBem)
                            DisarmTransaction()
                            lRetGrav := .F.
                        EndIf
                        If lRetGrav
                            lRet2Cont := .T.
                        EndIf
                    EndIf
                EndIf
            EndIf
		End Transaction

		If lRetGrav .And. lRet1Cont
			NGTRETCON(cFROTA985,vTTIArr[1]/*dt*/,vTTIArr[3]/*pos1*/,vTTIArr[2]/*hr*/,1,,.F.,,cFilBem)
		EndIf
		If lRetGrav .And. lRet2Cont
			NGTRETCON(cFROTA985,vTTIArr[1]/*dt*/,vTTIArr[4]/*pos2*/,vTTIArr[2]/*hr*/,2,,.F.,,cFilBem)
		EndIf

	ElseIf nOpc == 5

		//Referentes ao primeiro contador
		aARALTC :=  {'STP','STP->TP_FILIAL','STP->TP_CODBEM',;
					 'STP->TP_DTLEITU','STP->TP_HORA','STP->TP_POSCONT',;
					 'STP->TP_ACUMCON','STP->TP_VARDIA','STP->TP_VIRACON'}
		aARABEM := {'ST9','ST9->T9_POSCONT','ST9->T9_CONTACU',;
				    'ST9->T9_DTULTAC','ST9->T9_VARDIA'}
		dbSelectArea(aARALTC[1])
		dbSetOrder(5)
		If dbSeek(xFilial(aARALTC[1],vDadoAtu[1])+vDadoAtu[4]+vDadoAtu[5]+vDadoAtu[6])  //filial+frota+data+hora
			nRECNSTP := RecNo()
			lULTIMOP := .T.
			nACUMFIP := 0
			nCONTAFP := 0
			nVARDIFP := 0
			dDTACUFP := Ctod('  /  /  ')
			cHRACU   := "  :  "
			dbSkip(-1)
			If !EoF() .And. !BoF() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilBem) .And.;
			&(aARALTC[3]) = vDadoAtu[4]
				nACUMFIP := &(aARALTC[7])
				dDTACUFP := &(aARALTC[4])
				nCONTAFP := IIF(!FindFunction("NGBlCont") .Or. NGBlCont( STP->TP_CODBEM ), &(aARALTC[6]), NGTpCont(&(aARALTC[3]), &(aARALTC[4]), &(aARALTC[5]), &(aARALTC[6])))
				nVARDIFP := &(aARALTC[8])
				cHRACU   := &(aARALTC[5])
			EndIf
			dbGoTo(nRECNSTP)

			nACUMDEL := STP->TP_ACUMCON

			dbSelectArea(aARALTC[1])
			RecLock(aARALTC[1],.F.)
			dbDelete()
			MsUnlock(aARALTC[1])

			MNTA875ADEL(vDadoAtu[4],StoD(vDadoAtu[5]),vDadoAtu[6],1,cFilBem,cFilBem)
			If ExistBlock("NGUTIL4C")
				ExecBlock("NGUTIL4C",.F.,.F.,{vDadoAtu[4],dDTACUFP,cHRACU,nCONTAFP,nACUMFIP})
			EndIf
		EndIf

		//Referentes ao segundo contador
		dbSelectArea("TPE")
		dbSetOrder(1)
		If dbSeek(If(NGSX2MODO("TPE")="E",cFilBem,xFilial("TPE"))+vDadoAtu[4])

			aARALTC := {'TPP','TPP->TPP_FILIAL','TPP->TPP_CODBEM',;
						'TPP->TPP_DTLEIT','TPP->TPP_HORA','TPP->TPP_POSCON',;
						'TPP->TPP_ACUMCO','TPP->TPP_VARDIA','TPP->TPP_VIRACO'}
			aARABEM := {'TPE','TPE->TPE_POSCON','TPE->TPE_CONTAC',;
						'TPE->TPE_DTULTA','TPE->TPE_VARDIA'}
			dbSelectArea(aARALTC[1])
			dbSetOrder(5)
			If dbSeek(xFilial(aARALTC[1],vDadoAtu[1])+vDadoAtu[4]+vDadoAtu[5]+vDadoAtu[6])
				nRECNSTP := RecNo()
				lULTIMOP := .T.
				nACUMFIP := 0
				nCONTAFP := 0
				nVARDIFP := 0
				dDTACUFP := Ctod('  /  /  ')
				cHRACU   := "  :  "
				dbSkip(-1)
				If !EoF() .And. !BoF() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilBem) .And.;
				&(aARALTC[3]) = vDadoAtu[4]
					nACUMFIP := &(aARALTC[7])
					dDTACUFP := &(aARALTC[4])
					nCONTAFP := &(aARALTC[6])
					nVARDIFP := &(aARALTC[8])
					cHRACU   := &(aARALTC[5])
				EndIf
				dbGoTo(nRECNSTP)

				nACUMDEL := TPP->TPP_ACUMCO

				dbSelectArea(aARALTC[1])
				RecLock(aARALTC[1],.F.)
				dbDelete()
				MsUnlock(aARALTC[1])

				MNTA875ADEL(vDadoAtu[4],StoD(vDadoAtu[5]),vDadoAtu[6],2,cFilBem,cFilBem)
				If ExistBlock("NGUTIL4C")
					ExecBlock("NGUTIL4C",.F.,.F.,{vVDadoE[1],dDTACUFP,cHRACU,nCONTAFP,nACUMFIP})
				EndIf
			EndIf
		EndIf
	EndIf

Return lRetGrav


//---------------------------------------------------------------------
/*/{Protheus.doc} M985TS2VEN
Verifica se o veiculo possui documentos vencidos (TS2)
@author Felipe N. Welter
@since 09/07/09
@version undefined
@param cCODVei, characters, Codigo do Veiculo
@param cFILVei, characters, Filial do Veiculo
@param cEMPVei, characters, Empresa do Veiculo
@type function
/*/
//---------------------------------------------------------------------
Static Function M985TS2VEN(cCODVei,cFILVei,cEMPVei)

	Local cAliasTS2 := GetNextAlias()
	Local lRet      := .T.

	If M985ChkTbl({"TS2","TS0"},cEMPVei)

		cQuery := " SELECT TS2.TS2_FILIAL, TS2.TS2_PLACA, TS2.TS2_CODBEM, TS2.TS2_DOCTO, TS0.TS0_NOMDOC,"
		cQuery += " TS2.TS2_DTPGTO, TS2.TS2_DTVENC, TS2.TS2_PARCEL, TS2.TS2_VALOR, TS2.TS2_NOTFIS"
		cQuery += " FROM " + RetFullName("TS2",cEMPVei) + " TS2"
		cQuery += " JOIN " + RetFullName("TS0",cEMPVei) + " TS0 ON TS0.TS0_FILIAL = '" + NGTROCAFILI("TS0",cFILVei,cEMPVei)+"'"
		cQuery += " AND TS0.TS0_DOCTO = TS2.TS2_DOCTO "
		cQuery += " AND TS0.D_E_L_E_T_ <> '*' "
		cQuery += " WHERE TS2.TS2_FILIAL = '"+NGTROCAFILI("TS2",cFILVei,cEMPVei)+"'"
		cQuery += " AND TS2.TS2_CODBEM = '"+cCODVei+"'"
		cQuery += " AND TS2.TS2_DTVENC <= '"+DTOS(dDataBase)+"'"
		cQuery += " AND TS2.TS2_DTPGTO = ' '"
		cQuery += " AND TS2.D_E_L_E_T_ <> '*'"
		cQuery += " ORDER BY TS2.TS2_FILIAL, TS2.TS2_DTVENC, TS2.TS2_DOCTO, TS2.TS2_PARCEL"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTS2, .F., .T.)

		If (cAliasTS2)->(!EoF())
			(cAliasTS2)->(dbGoTop())
			cMsg := STR0138+AllTrim(cCodVei)+", "+CHR(13)  //"Não é possível realizar a saída do veículo "
			cMsg += STR0139+CHR(13)+CHR(13)  			   //"pois existe um documento vencido."
			cMsg += STR0081+": "+AllTrim((cAliasTS2)->TS2_DOCTO)+" - "+(cAliasTS2)->TS0_NOMDOC+CHR(13)  //"Documento"
			cMsg += STR0140+": ("+AllTrim(If(Valtype(TS2->TS2_PARCEL)=='C',(cAliasTS2)->TS2_PARCEL,Str((cAliasTS2)->TS2_PARCEL)))+") - "+MV_SIMB1+" "+AllTrim(STR(Round((cAliasTS2)->TS2_VALOR,2)))+CHR(13) //"Parcela"
			cMsg += STR0141+": "+DTOC(STOD((cAliasTS2)->TS2_DTVENC))  //"Vencimento"
			MsgAlert(cMsg,STR0062)  								  //"Atenção"
			lRet := .F.
		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} M985CCO
Consiste os contadores (final)
@author Felipe N. Welter
@since 12/05/09
@version undefined
@param cCODBEM , characters, Codigo do Veiculo
@param nCONTAD , numeric   , Posicao do Contador
@param dDATACON, date      , Data do Reporte
@param cHORCON , characters, Hora do Reporte
@param cFIL    , characters, Filial do Veiculo
@param nTIP    , numeric   , Tipo de Contador (1/2)
@param lCHKTIP , logical   , descricao
@type function
/*/
//---------------------------------------------------------------------
Function M985CCO(cCODBEM,nCONTAD,dDATACON,cHORCON,cFIL,nTIP,lCHKTIP)

	//VALIDACOES COM CONTADOR 1
	If TIPOACOM .And. !lCHKCON1 .And. nTIP == 1
		If nCONTAD > 0
			If !NGCHKHISTO(cCODBEM,dDATACON,nCONTAD,cHORCON,1,,.T.,cFIL)
				Return .F.
			EndIf
			If !NGVALIVARD(cCODBEM,nCONTAD,dDATACON,cHORCON,1,.T.,,cFIL)
				Return .F.
			EndIf
			If !NGCHKTMS(cCODBEM,dDATACON,cHORCON)
				Return .F.
			EndIf
		EndIf
	EndIf
	//VALIDACOES COM CONTADOR 2
	If TIPOACOM2 .And. nCONTAD > 0 .And. nTIP == 2
		If !NGCHKHISTO(cCODBEM,dDATACON,nCONTAD,cHORCON,2,,.T.,cFIL)
			Return .F.
		EndIf
		If !NGVALIVARD(cCODBEM,nCONTAD,dDATACON,cHORCON,2,.T.,,cFIL)
			Return .F.
		EndIf
	EndIf

	If lCHKTIP
		If nTIP = 1
			lCHKCON1 := .T.
		ElseIf nTIP = 2
			lCHKCON2 := .T.
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985VCO
Valida o contador na digitacao (Get)
@author Felipe N. Welter
@since 12/05/09
@version undefined
@param nCONTADOR, numeric, Posicao do Contador
@param nTIPO    , numeric, Tipo de Contador
@type function
/*/
//---------------------------------------------------------------------
Function MNT985VCO(nCONTADOR,nTIPO)

	lCHKCON1 := If(nTIPO = 1,.F.,lCHKCON1)
	lCHKCON2 := If(nTIPO = 2,.F.,lCHKCON2)
	dbSelectArea("TTI")
	If !Positivo(nCONTADOR) .Or. !Naovazio(nCONTADOR) .Or. !CHKPOSLIM(M->TTI_CODVEI,nCONTADOR,nTIPO,M->TTI_FILVEI)
		Return .F.
	End

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985IOS
Inclusao de ordem de servico Corretiva
@author Felipe N. Welter
@since 11/05/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNT985IOS()

	Local lRet := .F.

	If (Type("bNGGRAVA") == "B")
		bNGGRAVAOld := bNGGRAVA
	EndIf

	Private cCADASTRO := Oemtoansi(STR0142)  //"[Controle de Portaria] - O.S. Corretiva"

	//Variaveis para NG420INC
	Private lCORRET := .T.
	Private aTrocaF3  := {} //F3 - Tipo de Insumo


	//Private asMenu := {}
	Private aRotina := {{ " ", " "     , 0 , 1}   ,;
						{ " " , " "    , 0 , 2}   ,;
						{ " " , " "    , 0 , 3}   ,;
						{ " " , " "    , 0 , 4, 0},;
						{ " " , " "    , 0 , 5, 3}}

	If (cTRBVei)->EMPRESA != If(FindFunction("FWGrpCompany"),FWGrpCompany(),SM0->M0_CODIGO) .Or.;
	    (NGSX2MODO("ST9") <> "C" .And. (cTRBVei)->FILIAL != If(FindFunction("FWCodFil"),FWCodFil(),SM0->M0_CODFIL))
		ShowHelpDlg("INVALIDO",{STR0143,""},2,{STR0144,""},2)  //"O veículo selecionado não pertence à empresa/filial corrente."##"Altere para a empresa/filial do veículo."
		lRet := .F.
	Else
		dbSelectArea("ST9")
		cEmpInfo := SM0->M0_CODIGO//Substr(DBINFO(DBI_FULLPATH),4,2)
		lRet := NG420INC('STJ',1,3,(cTRBVei)->CODBEM,(cTRBVei)->FILIAL)
		nOpca := 0 //NG420INC X NGUTIL
		NGPrepTBL({{"ST9"},{"TPE"}},cEmpInfo)
	EndIf

	If (Type("bNGGRAVAOld") == "B")
		bNGGRAVA := bNGGRAVAOld
	EndIf

	If lRet .And. oPanel1:lVisible
		MNT985SEL((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA)
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA985CNS
Monta/desmonta tela de consulta de E/S para manipulacao
@author Felipe Nathan Welter
@since 03/12/10
@version undefined
@param nOpCNS, numeric,  1=monta/2=desmonta tela de consulta
@type function
/*/
//---------------------------------------------------------------------
Function MNTA985CNS(nOpCNS)

	If nOpCNS == 1 //monta tela para consulta

		//desabilita atualizacoes
		bKeyF5 := SetKey(VK_F5)
		If oTimer:lActive
			oTimer:DeActivate()
		EndIf

		//maximiza e ajusta painel de entradas/saidas
		oPanel1:Hide()
		oPanel21:Hide()
		oPnlBtn22:Hide()
		oPnlBtnES:Show()

		fCountTTI( ( cTRBVei )->CODBEM ) // Carrega variáveis de paginação
		Eval( bAtuBtnNxPr )				 // Exibe botões de Next/Prev
		Eval( bAtuNextPrev ) 			 // Exibe string de contador de página

		cVeiculo := ( cTRBVei )->CODBEM
		cFilialV := ( cTRBVei )->FILIAL
		cEmpVeic := ( cTRBVei )->EMPRESA

		MNT985ES( ( cTRBVei )->CODBEM,( cTRBVei )->FILIAL,( cTRBVei )->EMPRESA )

	ElseIf nOpCNS == 2 //Desmonta tela de consulta

		//ajusta tela com todos os paineis
		oPanel1:Show()
		oPanel21:Show()
		oPnlBtn22:Show()
		oPnlBtnES:Hide()

		Eval( bAtuBtnNxPr )  // Esconde botões de Next/Prev
		Eval( bAtuNextPrev ) // Esconde string de contador de página

		//habilita atualizacoes
		SetKey(VK_F5,bKeyF5)
		If nMVATUPORT > 0
			oTimer:Activate()
		EndIf

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA985MOV
Monta/desmonta tela de consulta de E/S para manipulacao
@author Felipe Nathan Welter
@since 03/12/10
@version undefined
@param nOpcX, numeric, 1=monta/2=desmonta tela de consulta
@type function
/*/
//---------------------------------------------------------------------
Function MNTA985MOV(nOpcX)

	Local lRet := .F.

	//verifica registro selecionado
	lENTRADA := ((cTRBES)->TIPO == '1')
	lSAIDA   := ((cTRBES)->TIPO == '2')

	//verifica arquivo vazio
	If (cTRBES)->(RecCount()) == 0 .And. nOpcX != 3
		Help(" ",1,"ARQVAZIO")
	EndIf

	//realiza operacao solicitada
	If nOpcX == 2  //visualizar
		If lENTRADA
			MNT985ENT(2)
		ElseIf lSAIDA
			MNT985SAI(2)
		EndIf
	ElseIf nOpcX == 3  //inclusao
		If Empty((cTRBVei)->TIPMOV) .Or. (cTRBVei)->TIPMOV == "2"
			lENTRADA := .T.
			lSAIDA   := .F.
			lRet := MNT985ENT(3)
		ElseIf (cTRBVei)->TIPMOV == "1"
			lENTRADA := .F.
			lSAIDA   := .T.
			lRet := MNT985SAI(3)
		EndIf
	ElseIf nOpcX == 4  //alteracao
		If lENTRADA
			lRet := MNT985ENT(4)
		ElseIf lSAIDA
			lRet := MNT985SAI(4)
		EndIf
	ElseIf nOpcX == 5  //exclusao
		If lENTRADA
			lRet := MNT985ENT(5)
		ElseIf lSAIDA
			lRet := MNT985SAI(5)
		EndIf
	ElseIf nOpcX == 6  //Inclusão Histórico
		lRet := MNT985HRET( 3 )
	EndIf

	lENTRADA := .F.
	lSAIDA   := .F.

	If lRet
		MNT985SEL((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA)
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} M985VldEF
Valida parametros de/ate Empresa/Filial
@author Felipe N. Welter
@since 04/05/09
@version undefined
@param cEF1, characters, Empresa/Filial 01
@param cEF2, characters, Empresa/Filial 02
@type function
/*/
//---------------------------------------------------------------------
Function M985VldEF(cEF1,cEF2)

	Local lRet     := .F.

	If Empty(cEF1) .Or. Empty(cEF2)
		If !Empty(cEF1) .And. ExistCpo("SM0",SM0->M0_CODIGO + cEF1)
			lRet := .T.
		EndIf
		If !Empty(cEF2) .And. ExistCpo("SM0",SM0->M0_CODIGO + cEF2)
			lRet := .T.
		EndIf
	Else
		If ExistCpo("SM0",SM0->M0_CODIGO + cEF1) .And. ExistCpo("SM0",SM0->M0_CODIGO + cEF2)
			If cEF2 >= cEF1
				lRet := .T.
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} M985RELAC
Executa o X3_RELAC para alguns campos utilizados.
@author Felipe N. Welter
@since 14/05/09
@version undefined
@param cCampo, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function M985RELAC(cCampo)

	Local xRet    := ""
	Local cTipMov := ""

	If ValType( (cTRBES)->TIPO ) == "C"
		cTipMov := (cTRBES)->TIPO
	Else
		cTipMov := M->TTI_TIPMOV
	EndIf

	Do Case
		Case cCampo == "TTI_NOMMOT"
		If cTipMov == '1'
			xRet := If(!Empty(M->TTI_MOTSAI),NGSEEK("DA4",M->TTI_MOTENT,01,"DA4_NOME",(cTRBVei)->FILTTI,(cTRBVei)->EMPTTI),"")
		Else
			xRet := If(!Empty(M->TTI_MOTENT),NGSEEK("DA4",M->TTI_MOTSAI,01,"DA4_NOME",(cTRBVei)->FILTTI,(cTRBVei)->EMPTTI),"")
		EndIf
	Endcase

	// PE para carregar campos (X3_RELAC) em tela atraves da funcao M985RELAC
	If ExistBlock("MNTA9853")
		xRetPE := ExecBlock("MNTA9853",.F.,.F.,{cCampo,(cTRBVei)->FILTTI,(cTRBVei)->EMPTTI})
		xRet := If(xRetPE == Nil,xRet,xRetPE)
	EndIf

Return xRet

//---------------------------------------------------------------------
/*/{Protheus.doc} M985Viagem
Monta array com as escalas da ultima/corrente viagem realiza da por um
veiculo (quando sistema utiliza rotas: MV_NGROTAS)
@author Felipe N. Welter
@since 13/05/09
@version undefined
@param cCODV, characters, Codigo do Veiculo
@param cFILV, characters, Filial proprietaria do Veiculo (cadastro)
@param cEMPV, characters, Empresa proprietaria do Veiculo (cadastro)
@type function
/*/
//---------------------------------------------------------------------
Function M985Viagem(cCODV,cFILV,cEMPV)

	Local cAliasQry := GetNextAlias()
	Local aArray    := {}

	Default cFILV := If(FindFunction("FWCodFil"),FWCodFil(),SM0->M0_CODFIL)
	Default cEMPV := If(FindFunction("FWGrpCompany"),FWGrpCompany(),SM0->M0_CODIGO)

	Private cMVEntIn := GetNewPar("MV_NGENTIN","")

	//+-----------------------------------------------------------------------+
	//| Retorno  O retorno e' um array contendo os seguintes campos:          |
	//|          [1]- Data de Movimentacao (entrada/saida) [TTI]              |
	//|          [2]- Hora de Movimentacao (entrada/saida) [TTI]              |
	//|          [3]- Tipo de Movimentacao (1=Entrada/2=Saida) [TTI]          |
	//|          [4]- Rota Utilizada na Movimentacao [TTI]                    |
	//|          [5]- Escala Utilizada na Movimentacao [TTI]                  |
	//|          [6]- Tipo Escala (1=Saida/2=Interm./3=Entr./4=Nao-Prog)[TTS] |
	//|          [7]- Empresa/Filial da Escala [TTS]                          |
	//|          [8]- Horario programado para Escala [TTS]                    |
	//+-----------------------------------------------------------------------+

	// As variáveis nomeadas como EMPFIL1 e EMPFIL2 foram desmembradas para EMP1 e EMP2
	// devido à inconsistência em ambiente com banco de dados POSTGRES
	cQuery := "SELECT "
	cQuery += " TTS1.TTS_TIPESC AS TIPO1, TTS1.TTS_EMPESC AS EMP1 ,TTS1.TTS_FILESC AS FIL1,TTS1.TTS_HORARI AS HORARI1,"
	cQuery += " TTS2.TTS_TIPESC AS TIPO2, TTS2.TTS_EMPESC AS EMP2 ,TTS2.TTS_FILESC AS FIL2,TTS2.TTS_HORARI AS HORARI2,"
	cQuery += " TTI.*,TTT1.*,TTS1.*,TTT2.*,TTS2.*"
	cQuery += " FROM "+RetSQLName("TTI")+" TTI"
	cQuery += " LEFT JOIN "+RetSQLName("TTT")+" TTT1 ON (TTI.TTI_TIPMOV = '2' OR TTI.TTI_TIPMOV = '1') AND TTI.TTI_ROTAEN = TTT1.TTT_CODROT"
	cQuery += " LEFT JOIN "+RetSQLName("TTS")+" TTS1 ON (TTI.TTI_TIPMOV = '2' OR TTI.TTI_TIPMOV = '1') AND TTI.TTI_ESCENT = TTS1.TTS_CODIGO AND TTI.TTI_ROTAEN = TTS1.TTS_CODROT"
	cQuery += " LEFT JOIN "+RetSQLName("TTT")+" TTT2 ON (TTI.TTI_TIPMOV = '2') AND TTI.TTI_ROTASA = TTT2.TTT_CODROT"
	cQuery += " LEFT JOIN "+RetSQLName("TTS")+" TTS2 ON (TTI.TTI_TIPMOV = '2') AND TTI.TTI_ESCSAI = TTS2.TTS_CODIGO AND TTI.TTI_ROTASA = TTS2.TTS_CODROT"
	cQuery += " WHERE"

	cQuery += "  ((TTI.TTI_DTSAI||TTI.TTI_HRSAI) = '' OR (TTI.TTI_DTSAI||TTI.TTI_HRSAI) >= "
	cQuery += "  (SELECT MAX(TTI.TTI_DTSAI||TTI.TTI_HRSAI) FROM "+RetSQLName("TTI")+" TTI"

	cQuery += " LEFT JOIN "+RetSQLName("TTT")+" TTT3 ON (TTI.TTI_TIPMOV = '2') AND TTI.TTI_ROTASA = TTT3.TTT_CODROT"
	cQuery += " LEFT JOIN "+RetSQLName("TTS")+" TTS3 ON (TTI.TTI_TIPMOV = '2') AND TTI.TTI_ESCSAI = TTS3.TTS_CODIGO AND TTI.TTI_ROTASA = TTS3.TTS_CODROT"
	cQuery += " WHERE"
	cQuery += " TTI.TTI_CODVEI = '"+cCODV+"'"
	cQuery += " AND TTI.TTI_EMPVEI = '"+cEMPV+"' AND TTI.TTI_FILVEI = '"+cFILV+"'"
	cQuery += " AND TTS3.TTS_TIPESC = '1'"
	cQuery += " AND TTI.D_E_L_E_T_ <> '*' AND TTS3.D_E_L_E_T_ <> '*' ))"

	cQuery += " AND TTI.TTI_CODVEI = '"+cCODV+"' AND TTI.TTI_FILVEI = '"+cFILV+"' AND TTI.TTI_EMPVEI = '"+cEMPV+"'"
	cQuery += " AND TTI.D_E_L_E_T_ <> '*' AND (TTT1.D_E_L_E_T_ IS NULL OR TTT1.D_E_L_E_T_ <> '*') AND (TTS1.D_E_L_E_T_ IS NULL OR TTS1.D_E_L_E_T_ <> '*')"
	cQuery += " AND (TTT2.D_E_L_E_T_ IS NULL OR TTT2.D_E_L_E_T_ <> '*')  AND (TTS2.D_E_L_E_T_ IS NULL OR TTS2.D_E_L_E_T_ <> '*')"

	cQuery += " ORDER BY TTI.TTI_DTENT||TTI.TTI_HRENT DESC"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While !EoF()
		If (cAliasQry)->TTI_TIPMOV == "1"
			If !Empty((cAliasQry)->EMP1 + (cAliasQry)->FIL1) .Or. ((cAliasQry)->TTI_ROTAEN == cMVEntIn) //validacoes em EMPFIL<n> considera apenas registros com controle de rota
				aAdd(aArray,{(cAliasQry)->TTI_DTENT,(cAliasQry)->TTI_HRENT,"1",(cAliasQry)->TTI_ROTAEN,(cAliasQry)->TTI_ESCENT,;
				If((cAliasQry)->TTI_ROTAEN == cMVEntIn,"4",(cAliasQry)->TIPO1),(cAliasQry)->EMP1 + (cAliasQry)->FIL1,(cAliasQry)->HORARI1})
			EndIf
		Else
			If (cAliasQry)->TIPO2 != "1"
				If !Empty((cAliasQry)->EMP2 + (cAliasQry)->FIL2)
					aAdd(aArray,{(cAliasQry)->TTI_DTSAI,(cAliasQry)->TTI_HRSAI,"2",(cAliasQry)->TTI_ROTASA,(cAliasQry)->TTI_ESCSAI,;
					(cAliasQry)->TIPO2,(cAliasQry)->EMP2 + (cAliasQry)->FIL2,(cAliasQry)->HORARI2})
				EndIf
				If !Empty((cAliasQry)->EMP1 + (cAliasQry)->FIL1)
					aAdd(aArray,{(cAliasQry)->TTI_DTENT,(cAliasQry)->TTI_HRENT,"1",(cAliasQry)->TTI_ROTAEN,(cAliasQry)->TTI_ESCENT,;
					(cAliasQry)->TIPO1,(cAliasQry)->EMP1 + (cAliasQry)->FIL1,(cAliasQry)->HORARI1})
				EndIf
			Else
				If !Empty((cAliasQry)->EMP2 + (cAliasQry)->FIL2)
					aAdd(aArray,{(cAliasQry)->TTI_DTSAI,(cAliasQry)->TTI_HRSAI,"2",(cAliasQry)->TTI_ROTASA,(cAliasQry)->TTI_ESCSAI,;
					(cAliasQry)->TIPO2,(cAliasQry)->EMP2 + (cAliasQry)->FIL2,(cAliasQry)->HORARI2})
				EndIf
			EndIf
		EndIf
		dbSkip()
	EndDo

	(cAliasQry)->(dbCloseArea())

Return aArray

//---------------------------------------------------------------------
/*/{Protheus.doc} M985UltTTI
Retorna uma movimentacao especifica de veiculo na portaria
@author Felipe N. Welter
@since 13/05/09
@version undefined
@param cCODV , characters, Codigo do Bem (Veiculo - ST9)
@param cFILV , characters, Filial  Bem
@param cEMPV , characters, Empresa do Bem
@param nTP   , numeric   , (1-Entrada/2-Saida) Tipo de Movimentacao
@param aCPOS , array     , Campos para adicionar ao retorno (tabela TTI)
@param dDtLim, date      , Data limite para selecao
@param cHrLim, characters, Hora limite para selecao
@param nTmp  , numeric   , (1-anterior/2-posterior) em relacao a data passada
@type function
@return Array + aCPOS [1]-TTI_EMPMOV [2]-TTI_FILMOV [3]-TTI_EMPVEI [4]-TTI_FILVEI
/*/
//---------------------------------------------------------------------
Function M985UltTTI(cCODV,cFILV,cEMPV,nTP,aCPOS,dDtLim,cHrLim,nTmp)

	Local aArea     := GetArea()
	Local nX, nY
	Local aCPRet    := {}
	Local _cGetDB   := TcGetDb()
	Local cAliasQry := GetNextAlias()

	Default nTP    := 1
	Default aCPOS  := {}
	Default dDtLim := dDataBase
	Default cHrLim := SubStr(Time(),1,5)
	Default nTmp   := 1

	cQuery := "SELECT "+If(nTmp==1,"MAX","MIN")
	cQuery += If(nTP==1,"(TTI_DTENT||TTI_HRENT) AS DTHR,","(TTI_DTSAI||TTI_HRSAI) AS DTHR,")
	cQuery += "'"+SM0->M0_CODIGO+"' AS EMPTTI, TTI_FILMOV AS FILTTI,"
	cQuery += "'"+SM0->M0_CODIGO+"' AS EMPST9, TTI_FILVEI AS FILST9 "

	For nX := 1 To Len(aCPOS)
		cQuery += ", "+aCPOS[nX]
	Next nX

	cQuery += " FROM "+RetSQLName("TTI")+" TTI "
	cQuery += " WHERE TTI_CODVEI = '"+cCODV+"' AND TTI_FILVEI = '"+cFILV+"' AND TTI_EMPVEI = '"+cEMPV+"' AND TTI_EMPMOV = '"+SM0->M0_CODIGO+"'"
	If nTP == 1
		cQuery += " AND TTI_DTENT||TTI_HRENT "+If(nTmp==1,"<",">")+" '"+DTOS(dDtLim)+cHrLim+"'"
	ElseIf nTP == 2
		cQuery += " AND TTI_DTSAI||TTI_HRSAI "+If(nTmp==1,"<",">")+" '"+DTOS(dDtLim)+cHrLim+"'"
		cQuery += " AND TTI_DTSAI||TTI_HRSAI <> ''"
	EndIf

	cQuery += " AND TTI.D_E_L_E_T_ <> '*'
	cQuery += " GROUP BY TTI_FILMOV, TTI_EMPVEI, TTI_FILVEI"
	For nX := 1 To Len(aCPOS)
		cQuery += ", "+aCPOS[nX]
	Next nX
	cQuery += " ORDER BY DTHR DESC"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!EoF())
		aCPRet := {(cAliasQry)->EMPTTI,(cAliasQry)->FILTTI,(cAliasQry)->EMPST9,(cAliasQry)->FILST9}
		For nX := 1 To Len(aCPOS)
			aAdd(aCPRet,(cAliasQry)->&(aCPOS[nX]))
		Next nX
	EndIf
	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return aCPRet

//---------------------------------------------------------------------
/*/{Protheus.doc} M985LoadEF
Carrega Variaveis de/ate Empresa/Filial, utilizadas para o filtro de veiculos.
@author Felipe N. Welter
@since 04/05/09
@version undefined
@param nPAR, numeric, 1=De (Primeira), 2=Ate (Ultima)
@type function
@return cRet - EMPRESA+FILIAL (se multiempresa) ou FILIAL
/*/
//---------------------------------------------------------------------
Static Function M985LoadEF(nPAR)

	Local cEmp1 := If(FindFunction("FWGrpCompany"),FWGrpCompany(),SM0->M0_CODIGO)
	Local cFil1 := If(FindFunction("FWCodFil"),FWCodFil(),SM0->M0_CODFIL)
	Local cRet  := Space(Len(cEmp1)+Len(cFil1))

	dbSelectArea("SM0")
	nRecSM0  := SM0->(RecNo())
	cEmpresa := SM0->M0_CODIGO
	dbSeek(cEmpresa)
	If (nPAR == 1)
		cRet := FWCodFil()
	ElseIf (nPAR == 2)
		While !EoF() .And. SM0->M0_CODIGO == cEmpresa
			cRet := FWCodFil()
			dbSkip()
		EndDo
	EndIf

	dbGoTo(nRecSM0)

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} M985DtHr
Validacoes para os campos Data e Hora da tabela TTI

@author  Felipe N. Welter
@since	 05/06/09
@version P11/P12
@param	 cCampo,  Caractér, Descrição do Campo a ser validado
@param	 lVldFim, Lógico,   Verifica se é validação final
@return	 lRet,    Lógico,   .F. = Encontrou Inconsistencia
/*/
//---------------------------------------------------------------------
Function M985DtHr(cCampo, lVldFim)

	Local lRet := .T.
	Local dData
	Local cHora
	Local lStackHret := IsInCallStack("MNT985HRET")

	Default lVldFim := .F.

	If "_HR" $ cCampo
		lRet := VALHORA(M->&(cCampo))
	EndIf

	If lRet
		If "ENT" $ cCampo
			If !Empty(M->TTI_DTENT) .And. !Empty(M->TTI_HRENT)
				If DTOS(M->TTI_DTENT)+M->TTI_HRENT > DTOS(dDatabase)+Time()
					ShowHelpDlg("INVALIDO",{STR0145,""},2,{STR0146,""},2)  //"Data/hora de entrada maior que data/hora base."##"Informe uma data/hora menor ou igual base."
					lRet := .F.
				Else
					If Inclui .And. lMVROTAS
						If !Empty(aTRAVEL) .And. DTOS(M->TTI_DTENT)+M->TTI_HRENT <= aTRAVEL[1,1]+aTRAVEL[1,2] .And. !lStackHret
							ShowHelpDlg("INVALIDO",{STR0147,""},2,{STR0148,""},2)  //"Data/hora de entrada menor/igual que data/hora da última saída."##"Informe uma data/hora maior que a da última saída."
							lRet := .F.
						EndIf
					Else

						dData := If(Inclui,M->TTI_DTENT,TTI->TTI_DTENT)
						cHora := If(Inclui,M->TTI_HRENT,TTI->TTI_HRENT)

						//valida data+hora da movimentacao anterior
						aUltTTI := M985UltTTI(M->TTI_CODVEI,M->TTI_FILVEI,M->TTI_EMPVEI,2,{"TTI_DTSAI","TTI_HRSAI"},dData,cHora,1)
						If !Empty(aUltTTI) .And. DTOS(M->TTI_DTENT)+M->TTI_HRENT <= aUltTTI[5]+aUltTTI[6]
							ShowHelpDlg("INVALIDO",{STR0147,""},2,{STR0148,""},2)  //"Data/hora de entrada menor/igual que data/hora da última saída."##"Informe uma data/hora maior que a da última saída."
							lRet := .F.
						EndIf
						//valida data+hora da movimentacao posterior
						aNxtTTI := M985UltTTI(M->TTI_CODVEI,M->TTI_FILVEI,M->TTI_EMPVEI,2,{"TTI_DTSAI","TTI_HRSAI"},dData,cHora,2)
						If lRet .And. !Empty(aNxtTTI) .And. DTOS(M->TTI_DTENT)+M->TTI_HRENT >= aNxtTTI[5]+aNxtTTI[6]
							ShowHelpDlg("INVALIDO",{STR0173,""},2,{STR0174,""},2)  //"Data/hora de entrada maior/igual que data/hora da próxima saída."##"Informe uma data/hora menor que a da próxima saída."
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf "SAI" $ cCampo

			// Ao informar campo data limpa o campo de hora.
			If "DTSAI" $ cCampo .And. !Empty( M->TTI_HRSAI ) .And. !lVldFim
				M->TTI_HRSAI := Space( Len( M->TTI_HRSAI ) )
			EndIf

			If !Empty(M->TTI_DTSAI) .And. !Empty(M->TTI_HRSAI)
				If DTOS(M->TTI_DTSAI)+M->TTI_HRSAI > DTOS(dDataBase)+Time()
					ShowHelpDlg("INVALIDO",{STR0149,""},2,{STR0150,""},2)  //"Data/hora de saida maior que data/hora base."##"Informe uma data/hora menor ou igual a base."
					lRet := .F.
				ElseIf DTOS(M->TTI_DTSAI)+M->TTI_HRSAI <= DTOS(TTI->TTI_DTENT)+TTI->TTI_HRENT .And. !lStackHret
					ShowHelpDlg("INVALIDO",{STR0151,""},2,{STR0152,""},2)  //"Data/hora de saída menor/igual que data/hora da última entrada."##"Informe uma data/hora maior que a da última entrada."
					lRet := .F.
				Else
					If nOpc == 3 .And. lMVROTAS
						If !Empty(aTRAVEL) .And. DTOS(M->TTI_DTSAI)+M->TTI_HRSAI <= aTRAVEL[1,1]+aTRAVEL[1,2] .And. !lStackHret
							ShowHelpDlg("INVALIDO",{STR0151,""},2,{STR0152,""},2)  //"Data/hora de saída menor/igual que data/hora da última entrada."##"Informe uma data/hora maior que a da última entrada."
							lRet := .F.
						EndIf
					Else

						dData := If(nOpc==3,M->TTI_DTSAI,TTI->TTI_DTSAI)
						cHora := If(nOpc==3,M->TTI_HRSAI,TTI->TTI_HRSAI)

						//valida data+hora da movimentacao anterior
						aUltTTI := M985UltTTI(M->TTI_CODVEI,M->TTI_FILVEI,M->TTI_EMPVEI,1,{"TTI_DTENT","TTI_HRENT"},dData,cHora,1)
						If !Empty(aUltTTI) .And. DTOS(M->TTI_DTSAI)+M->TTI_HRSAI <= aUltTTI[5]+aUltTTI[6]
							ShowHelpDlg("INVALIDO",{STR0151,""},2,{STR0152,""},2)  //"Data/hora de saída menor/igual que data/hora da última entrada."##"Informe uma data/hora maior que a da última entrada."
							lRet := .F.
						EndIf
						//valida data+hora da movimentacao posterior
						aNxtTTI := M985UltTTI(M->TTI_CODVEI,M->TTI_FILVEI,M->TTI_EMPVEI,1,{"TTI_DTENT","TTI_HRENT"},dData,cHora,2)
						If lRet .And. !Empty(aNxtTTI) .And. DTOS(M->TTI_DTSAI)+M->TTI_HRSAI >= aNxtTTI[5]+aNxtTTI[6]
							ShowHelpDlg("INVALIDO",{STR0175,""},2,{STR0176,""},2)  //"Data/hora de saída maior/igual que data/hora da próxima entrada."##"Informe uma data/hora maior que a da próxima entrada."
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} M985RtEsc
Preenche os campos de escala e rota na viagem (dicionario)
@author Felipe N. Welter
@since 04/05/09
@version undefined
@param cCampo, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function M985RtEsc(cCampo)

	Local cEmp1		 := If(FindFunction("FWGrpCompany"),FWGrpCompany(),SM0->M0_CODIGO)
	Local cFil1		 := If(FindFunction("FWCodFil"),FWCodFil(),SM0->M0_CODFIL)
	Local lRet		 := .T.
	Local lStackHret := IsInCallStack("MNT985HRET")

	If "ROTA" $ cCampo

		lRet := EXISTCPO("TTT",SM0->M0_CODIGO+xFilial("TTT")+M->&(cCampo))

		//Preenche automaticamente a escala, ao informar a rota para a saida inicial
		nIndic := 03
		cChave := SM0->M0_CODIGO + xFilial("TTI") + If(lENTRADA, M->TTI_ROTAEN, M->TTI_ROTASA)
		If lSAIDA .And. !Empty(aTRAVEL)
			If aTRAVEL[1,4] == cMVEntIn .Or. aTRAVEL[1,6] == "3" //Entrada Inicial .Or. Fim de Viagem
				If NGSEEK("TTS",cChave+"1",nIndic,"TTS_EMPESC")+NGSEEK("TTS",cChave+"1",nIndic,"TTS_FILESC") != cEmp1+cFil1
					lRet := .F.
					ShowHelpDlg("INVALIDO",{STR0153,+""},2,;  //"Empresa e Filial corrente são inválidas para a Escala de saída da rota."
					{STR0154+" : ","("+SM0->M0_CODIGO+" - "+AllTrim(NGSEEKSM0(SM0->M0_CODIGO+SM0->M0_CODFIL,{"M0_NOMECOM"})[1])+" / "+;  //"Selecione uma rota com saída de"
					SM0->M0_CODIGO+SM0->M0_CODFIL+" - "+AllTrim(NGSEEKSM0(SM0->M0_CODIGO+SM0->M0_CODFIL,{"M0_NOME"})[1])+")"},2)
				EndIf
			EndIf
			M->TTI_ESCSAI := NGSEEK("TTS",cChave+"1",nIndic,"TTS_CODIGO")
			M->TTI_DESESC := NGSEEK("TTS",cChave+"1",nIndic,"TTS_DESCRI")
			nIndic2       := 01
			cChave2       := SM0->M0_CODIGO + xFilial("TTI") + M->TTI_ROTASA
			M->TTI_DESROT := NGSEEK("TTT",cChave2,nIndic2,"TTT_NMROTA")
		ElseIf lSAIDA
			M->TTI_ESCSAI := NGSEEK("TTS",cChave+"1",nIndic,"TTS_CODIGO")
			M->TTI_DESESC := NGSEEK("TTS",cChave+"1",nIndic,"TTS_DESCRI")
			nIndic2 := 01
			cChave2 := SM0->M0_CODIGO + xFilial("TTI") + M->TTI_ROTASA
			M->TTI_DESROT := NGSEEK("TTT",cChave2,nIndic2,"TTT_NMROTA")
		EndIf

		If lStackHret //Caso seja inclusão de Histórico retroativo.
			nIndic := 03
			If "ROTAEN" $ cCampo
				cChave := SM0->M0_CODIGO + xFilial("TTI") + M->TTI_ROTAEN
				M->TTI_ESCENT := NGSEEK( "TTS", cChave + "3", nIndic, "TTS_CODIGO" )
			ElseIf "ROTASA" $ cCampo
				cChave := SM0->M0_CODIGO + xFilial("TTI") + M->TTI_ROTASA
				M->TTI_ESCSAI := NGSEEK( "TTS", cChave + "1", nIndic, "TTS_CODIGO" )
				M->TTI_DESESC := NGSEEK( "TTS", cChave + "1", nIndic, "TTS_DESCRI" )
			EndIf
		EndIf

	ElseIf "ESC" $ cCampo

		If !Empty(M->&(cCampo))
			nIndic := 01
			cChave := SM0->M0_CODIGO + xFilial("TTI") + If(lENTRADA, M->TTI_ROTAEN+M->TTI_ESCENT, M->TTI_ROTASA+M->TTI_ESCSAI)

			If !NGIFDBSEEK('TTS',cChave,nIndic)
				ShowHelpDlg("INVALIDO",{STR0155,""},2,{STR0156,""},2)  //"A escala informada não existe."##"Informe uma escala válida."
				lRet := .F.

			ElseIf lENTRADA
				If NGSEEK("TTS",cChave,nIndic,"TTS_TIPESC") == "1"
					ShowHelpDlg("INVALIDO",{STR0157+NGRETSX3BOX('TTS_TIPESC','1')+".",""},2,{STR0156,""},2)  //"A escala informada é do tipo "##"Informe uma escala válida."
					lRet := .F.
				EndIf
			EndIf

			If NGIFDBSEEK('TTS',cChave,nIndic)
				M->TTI_DESESC := NGSEEK("TTS",cChave+"1",nIndic,"TTS_DESCRI")
			EndIf

			If lRet .And. NGSEEK("TTS",cChave,nIndic,"TTS_TIPESC") != "4" .And.;
			NGSEEK("TTS",cChave+"1",nIndic,"TTS_EMPESC")+NGSEEK("TTS",cChave+"1",nIndic,"TTS_FILESC") != cEmp1+cFil1
				cEmpFil := NGSEEK("TTS",cChave+"1",nIndic,"TTS_EMPESC")+NGSEEK("TTS",cChave+"1",nIndic,"TTS_FILESC")
				ShowHelpDlg("INVALIDO",{STR0158,+""},2,;  //"Empresa e Filial corrente são inválidas para a Escala informada."
				{STR0159+": ","("+SubStr(cEmpFil,1,2)+" - "+AllTrim(NGSEEKSM0(cEmpFil,{"M0_NOMECOM"})[1])+" / "+;  //"O reporte deve ser feito em"
				SubStr(cEmpFil,3,Len(cEmpFil))+" - "+AllTrim(NGSEEKSM0(cEmpFil,{"M0_NOME"})[1])+")"},2)
				lRet := .F.
			EndIf
		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA985TTS
Filtro da consulta SXB -  TTS
@author Felipe N. Welter
@since 26/05/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTA985TTS()

	If lENTRADA
		Return TTS->TTS_CODROT == M->TTI_ROTAEN
	ElseIf lSAIDA
		Return TTS->TTS_CODROT == M->TTI_ROTASA
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985HOD
Programa para calcular a autonomia do veiculo.
@author  Felipe Nathan Welter
@since 13/12/10
@version undefined
@param nTpContador, numeric, descricao
@param nTipMov, numeric, descricao
@type function
@obs Baseado na rotina MNTA655HOD
/*/
//---------------------------------------------------------------------
Function MNT985HOD(nTpContador,nTipMov)

	Local nKmAnt  := 0
	Local nKmPos  := 0
	Local lKmAnt  := .T.
	Local lKmPos  := .F.
	Local aKmsR   := {}
	Local aChkLan := {}
	Local nHodom  := 0
	Local vArqDia := {}
	Local vArqCon := {}
	Local lVAuton := .F.

	If nTpContador = Nil
		nTpContador := 1
		lVAuton     := .T.
	EndIf

	vArqCon := If(nTipMov == 1, If(nTpContador = 1,{'M->TTI_POS1EN'},{'M->TTI_POS2EN'}),;
	If(nTpContador = 1,{'M->TTI_POS1SA'},{'M->TTI_POS2SA'}))

	vArqDia := If(nTpContador = 1,{'STP','STP->TP_FILIAL','STP->TP_CODBEM',;
								   'STP->TP_DTLEITU','STP->TP_HORA','STP->TP_TIPOLAN','STP->TP_POSCONT','STP->TP_VIRACON'},;
								  {'TPP','TPP->TPP_FILIAL','TPP->TPP_CODBEM',;
								   'TPP->TPP_DTLEIT','TPP->TPP_HORA','TPP->TPP_TIPOLA','TPP->TPP_POSCON','TPP->TPP_VIRACO'})
	cFrota985 := M->TTI_CODVEI
	dData985 := If(nTipMov == 1,M->TTI_DTENT,M->TTI_DTSAI)
	cHora985 := If(nTipMov == 1,M->TTI_HRENT,M->TTI_HRSAI)
	If nTpContador == 1
		cHodom985 := IIF(!FindFunction("NGBlCont") .Or. NGBlCont( STP->TP_CODBEM ), &(vArqCon[1]), NGTpCont(&(vArqDia[3]), &(vArqDia[4]), &(vArqDia[5]), &(vArqCon[1])))
	Else
		cHodom985 := &(vArqCon[1])
	EndIf

	dbSelectArea("TQN")
	cFrota985 := cFrota985 + Space(Len(ST9->T9_CODBEM)-Len(cFrota985))

	aChkLan := NGCHKCINC(cFrota985,dData985,cHodom985,cHora985,nTpContador,.T.,cFilBem)
	If !aChkLan[1]
		MsgInfo(aChkLan[2],"NÃO CONFORMIDADE")
		Return .F.
	EndIf

	lVIRADA := .F.
	aKmsR := NGCONTAP(cFrota985,DTOS(dData985),cHora985,nTpContador)
	nHodom := cHodom985
	nKmAnt := aKmsR[1]
	nKmPos := aKmsR[2]

	//KM atual menor ou igual ao anterior
	If nHODOM <= aKmsR[1]
		dbselectArea(vArqDia[1])
		dbSetOrder(5)
		dbSeek(xFilial(vArqDia[1],cFilBem)+cFrota985+DTOS(dData985))
		While !EoF() .And. &(vARQDIA[2]) == xFilial(vArqDia[1],cFilBem) .AND. &(vARQDIA[3]) == cFrota985 .And. &(vARQDIA[4]) == dData985
			If &(vARQDIA[7]) == cHodom985
				lKmAnt := .F.
				If &(vARQDIA[5]) == cHora985
					If &(vARQDIA[6]) $ "IQV"	  //I=Implantacao;Q=Quebra;V=Virada diminui 1 minuto
						nRecno := Recno()
						If !NGSTPALT(&(vARQDIA[2]),&(vARQDIA[3]),&(vARQDIA[4]),&(vARQDIA[5]))
							dbGoTo(nRecno)
							MsgInfo(STR0185+NGRETSX3BOX('TP_TIPOLAN',&(vARQDIA[6]))+STR0186,STR0187) //"Registro com mesma data, hora e contador de um lançamento de "##" do Histórico de contador."
							Return .F.
						EndIf
						dbGoTo(nRecno)
					Else
						lVIRADA := .T.
					EndIf
				EndIf
			EndIf
			If &(vARQDIA[7]) > cHodom985
				lKmAnt := .T.
			EndIf
			dbselectArea(vArqDia[1])
			dbSkip()
		End

		If nHODOM = aKmsR[1] .And. aKmsR[4] == "A"
			lKmAnt := .F.
		EndIf
		If nHODOM = aKmsR[1] .And. aKmsR[4] == 'V' .And. ((aKmsR[10] < dData985) .Or. (aKmsR[10] == dData985 .And. aKmsR[11] < cHora985))
			lKmAnt := .F.
		EndIf
		If Altera
			nKmAnt := aKmsR[5]
			If nHODOM > aKmsR[5] .And. aKmsR[6] == 'A'
				lKmAnt := .F.
			EndIf
		EndIf
		If lKmAnt
			MsgInfo(STR0188+Chr(10)+Chr(10)+; 								 //"O valor do contador não pode ser menor ou igual ao valor do contador anterior."
					STR0189+": "+AllTrim(Str(nKmAnt))+Chr(13)+Chr(10)+; 	 //"Contador Anterior"
					STR0049+": "+AllTrim(DTOC(aKmsR[10]))+Chr(13)+Chr(10)+;  //"Data"
					STR0050+": "+AllTrim(aKmsR[11])+Chr(13)+Chr(10)+; 		 //"Hora"
					STR0190+": "+AllTrim(Str(cHodom985))+Chr(13)+Chr(10)+;   //"Contador Atual
					STR0049+": "+AllTrim(DTOC(dData985))+Chr(13)+Chr(10)+;   //"Data"
					STR0050+": "+AllTrim(cHora985)+Chr(10)+Chr(13)+Chr(10)+; //"Hora"
					STR0191+":"+Chr(13)+Chr(10)+; 							 //"Soluções Possíveis"
					STR0192+Chr(13)+Chr(10)+;					 			 //"1 - Alterar o campo Contador."
					STR0193,STR0187)  										 //"2 - Cancelar a Operação."##"NÃO CONFORMIDADE"
			Return .F.
		EndIf
	EndIf

	//Ha proximo lancamento na STP
	If aKmsR[2] <> 0
		If nHODOM > aKmsR[2] //KM atual maior que o posterior
			If aKmsR[8] != dData985 .Or. aKmsR[9] != cHora985
				lKmPos := .T.   // se data ou hora e' diferente, nao permite
			EndIf
		EndIf
		If nHODOM = aKmsR[2] .And. aKmsR[3] == 'C'
			lKmPos := .F.
			dbselectArea(vArqDia[1])
			dbSetOrder(5)
			dbSeek(xFilial(vArqDia[1],cFilBem)+cFrota985+DTOS(dData985))
			While !EoF() .And. &(vARQDIA[2]) == xFilial(vArqDia[1],cFilBem) .AND. &(vARQDIA[3]) == cFrota985 .And. &(vARQDIA[4]) == dData985
				If &(vARQDIA[7]) == cHodom985 .AND. &(vARQDIA[6]) == 'C'
					If &(vARQDIA[5]) == cHora985
						lVIRADA := .T.
					EndIf
				EndIf
				dbselectArea(vArqDia[1])
				dbSkip()
			End
		EndIf
		If nHODOM > aKmsR[2] .And. aKmsR[3] $ 'QV' .And. ((aKmsR[8] > dData985) .Or. (aKmsR[8] == dData985 .And. aKmsR[9] > cHora985))
			lKmPos := .F.
		EndIf
		If nHODOM <= aKmsR[2] .And. aKmsR[3] == 'Q' .And. ((aKmsR[8] > dData985) .Or. (aKmsR[8] == dData985 .And. aKmsR[9] > cHora985))
			MsgInfo(STR0194,STR0187)  //"Data, hora e contador menor ou igual ao informado na quebra de contador."##"NÃO CONFORMIDADE"
			Return .F.
		EndIf
		If lKmPos
			MsgInfo(STR0195+Chr(10)+Chr(10)+; 							     //"O valor do contador não pode ser maior ou igual ao valor do contador posterior."
					STR0196+": "+AllTrim(Str(nKmPos))+Chr(13)+Chr(10)+;      //"Contador Posterior"
					STR0049+": "+AllTrim(DTOC(aKmsR[8]))+Chr(13)+Chr(10)+;   //"Data"
					STR0050+": "+AllTrim(aKmsR[9])+Chr(13)+Chr(10)+; 	     //"Hora"
					STR0190+": "+AllTrim(Str(cHodom985))+Chr(13)+Chr(10)+;   //"Contador Atual"
					STR0049+": "+AllTrim(DTOC(dData985))+Chr(13)+Chr(10)+;   //"Data"
					STR0050+": "+AllTrim(cHora985)+Chr(10)+Chr(13)+Chr(10)+; //"Hora"
					STR0191+":"+Chr(13)+Chr(10)+;						     //"Soluções Possíveis"
					STR0192+Chr(13)+Chr(10)+; 								 //"1 - Alterar o campo Contador."
					STR0193,STR0187) 										 //"2 - Cancelar a Operação."##"NÃO CONFORMIDADE"
			Return .F.
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA985CFG
Configuracoes da sessao
@author Felipe N. Welter
@since 14/09/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTA985CFG()

	Local oDlg
	Local nOp  := 0
	Local nNewATUPORT := nMVATUPORT
	Local nNewVARSHES := nMVVARSHES
	Local cCadastro   := STR0166  //"[Controle de Portaria] - Configurações"

	Define MsDialog oDlg From 0,0 to 140,290 Title cCadastro Pixel

	@ 07,05 SAY Upper(STR0163) Of oDlg Pixel Font oFont12B  //"Configurações"

	@ 20,08	 To 53,130 Of oDlg Pixel

	@ 25,12 SAY STR0167 Of oDlg Pixel Font oFont10  //"Atualização Automática (minutos): "
	oSpnBxT1 := TSpinBox():New( 24,105,oDlg,{|x|nNewATUPORT := x*60},20,12,STR0168)  //"Tempo para atualização automática (em minutos)"
	oSpnBxT1:SetRange(0,99)
	oSpnBxT1:SetValue(nMVATUPORT/60)

	@ 40,12 SAY STR0169 Of oDlg Pixel Font oFont10  //"Apresentação de E/S (dias): "
	oSpnBxT2 := TSpinBox():New( 39,105,oDlg,{|x|nNewVARSHES := x},20,12,STR0170)  //"Variação dia para apresentação das E/S (últimos dias)"
	oSpnBxT2:SetRange(1,99)
	oSpnBxT2:SetValue(nMVVARSHES)

	oButtonT1 := tButton():New(57,048,STR0024,oDlg,{||nOp := 1,oDlg:End()},26,11,,,,.T.)  //"OK"
	oButtonT2 := tButton():New(57,078,STR0025,oDlg,{||nOp := 0,oDlg:End()},26,11,,,,.T.)  //"Cancelar"

	Activate Dialog oDlg Centered

	If nOp == 1
		//Atualizacao automatica
		If nMVATUPORT != nNewATUPORT
			nMVATUPORT := nNewATUPORT
			oTimer:DeActivate()
			oTimer:nInterval := (nMVATUPORT * 1000)
			If nMVATUPORT > 0
				oTimer:Activate()
			EndIf
		EndIf
		If nMVVARSHES != nNewVARSHES
			nMVVARSHES := nNewVARSHES
			//Apresentacao de E/S
			Processa({ |lEnd| MNT985ES((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA)},STR0067) //"Aguarde... Atualizando E/S"
		EndIf
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} M985ChkTbl
Verifica/Cria tabelas no banco antes de montar Querys
@author Felipe N. Welter
@since 04/05/09
@version undefined
@param aTBL   ,array     , Array de tabelas a verificar
@param cCodEmp,characters, Codigo da Empresa proprietaria das tabelas
@type function
@obs Uso Genérico
/*/
//---------------------------------------------------------------------
Function M985ChkTbl(aTBL,cCodEmp)

	Local nI    := 0
	Local lRet  := .T.
	Local aArea := GetArea()
	Local cMD   := ""

	For nI := 1 To Len(aTBL)
		If !EmpOpenFile(aTBL[nI],aTBL[nI],1,.T.,cCodEmp,@cMd) // Verifica se é possível abrir a tabela da outra empresa.
			lRet := .F.
			Exit
		Else
			EmpOpenFile(aTBL[nI],aTBL[nI],1,.F.,cCodEmp,@cMd) // Se conseguiu, fecha as tabelas pois a abertura e utilização será em outro ponto
		EndIf
	Next nI

	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} M985RecCnt
Conta registros em uma alias (query)
@author Felipe N. Welter
@since 06/05/09
@version undefined
@param cAlias, characters, cAlias - Alias para contar regisros
@type function
/*/
//---------------------------------------------------------------------
Static Function M985RecCnt(cAlias)

	Local nCntRec := 0

	dbSelectArea(cAlias)
	dbGoTop()
	While !EoF()
		nCntRec++
		dbSkip()
	EndDo
	dbGoTop()

Return nCntRec

//---------------------------------------------------------------------
/*/{Protheus.doc} M985VDTHRS
Função para validação da data e hora da saida dos visitantes
Parâmetro OPC indica se valida data(1) ou hora(2)
@author Felipe Helio dos Santos
@since 01/02/2013
@return lRet
/*/
//---------------------------------------------------------------------
Function M985VDTHRS(nOpc)

	Local lRet :=.T.
	Local lDtVazio := !Empty(M->TTK_DTSAI) .And. !Empty(M->TTK_DTENT)
	Local lHrVazio := !Empty(M->TTK_HRENT) .And. !Empty(M->TTK_HRSAI)
	If nOpc == 1
		If lDtVazio .And. M->TTK_DTSAI > dDatabase .Or.;
		lDtVazio .And. M->TTK_DTSAI < M->TTK_DTENT
			ShowHelpDlg( STR0062 , ; 		 //"Atenção"
						{ STR0197 } , 2 , ;	 //"Data de saída não pode ser menor que a data de entrada ou maior que a data do sistema."
						{ STR0198 } , 2 )	 //"Favor informar uma data de saída válida."
			M->TTK_DTSAI := CTOD("")
			lRet := .F.
		EndIf
	EndIf
	If nOpc == 2 //Valida hora se as datas forem iguais e forem igual a database
		If (lDtVazio) .And. (M->TTK_DTENT == M->TTK_DTSAI) .And. (M->TTK_DTSAI == dDataBase .Or. M->TTK_DTENT == dDataBase)
			If (lHrVazio) .And. (M->TTK_HRSAI < M->TTK_HRENT .Or. M->TTK_HRSAI > Time())
				ShowHelpDlg( STR0062 , ;
				{ STR0199 } , 2 , ; 		//"Hora de saída não pode ser menor que a hora de entrada ou maior que a hora atual."
				{ STR0200 } , 2 ) 		//"Favor informar hora de saída válida."
				M->TTK_HRSAI := Space(Len(M->TTK_HRSAI))
				lRet := .F.
			EndIf
		EndIf
		//Valida hora se as datas forem iguais porem menor que a data base
		If (lDtVazio) .And. (M->TTK_DTENT == M->TTK_DTSAI) .And. (M->TTK_DTSAI < dDataBase .And. M->TTK_DTENT < dDataBase)
			If (lHrVazio) .And. (M->TTK_HRSAI < M->TTK_HRENT)
				ShowHelpDlg( STR0062 , ;
				{ STR0199 } , 2 , ; 		//"Hora de saída não pode ser menor que a hora de entrada ou maior que a hora atual."
				{ STR0200 } , 2 ) 		//"Favor informar hora de saída válida."
				M->TTK_HRSAI := Space(Len(M->TTK_HRSAI))
				lRet := .F.
			EndIf
		EndIf
		//Valida hora se as datas forem diferentes
		If (lDtVazio) .And. (M->TTK_DTENT <> M->TTK_DTSAI) .And. (M->TTK_DTSAI == dDataBase .And. M->TTK_DTENT < dDataBase)
			If (lHrVazio) .And. (M->TTK_HRSAI > Time())
				ShowHelpDlg( STR0062 , ;
				{ STR0199 } , 2 , ; 		//"Hora de saída não pode ser menor que a hora de entrada ou maior que a hora atual."
				{ STR0200 } , 2 ) 		//"Favor informar hora de saída válida."
				M->TTK_HRSAI := Space(Len(M->TTK_HRSAI))
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} fNextPrev
Controle de paginação das entradas/saídas dos veículos
@param Integer nNextPrev: indica se deve ir para próxima ou página anterior
1 - Página Anterior, 2 - Próxima Página
@author André Felipe Joriatti
@since 07/09/2013
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fNextPrev( nNextPrev )

	If nNextPrev == PROXIMO
		If ( ++nPagAtu ) > nTotalPag
			nPagAtu := nTotalPag
		EndIf
	ElseIf nNextPrev == ANTERIOR
		If ( --nPagAtu ) < 1
			nPagAtu := 1
		EndIf
	EndIf

	cRecTTIIni := aPgsIniFim[nPagAtu][1]
	cRecTTIFim := aPgsIniFim[nPagAtu][2]

	// Carrega (cTRB) de Entradas/Saídas
	Eval( bAtuNextPrev )
	MNT985ES( cVeiculo,cFilialV,cEmpVeic )

Return Nil



//---------------------------------------------------------------------
/*/{Protheus.doc} fCountTTI
Carrega variáveis usadas no controle de paginação
@author André Felipe Joriatti
@since 07/09/2013
@param 	String cCODVei: indica código do veículo que deseja recuperar
as entradas e saídas;
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fCountTTI( cCODVei,nPagina )

	Local cQuery     := ""
	Local cAliasQry  := GetNextAlias()
	Local nRegLastPg := 0
	Local nQtReg
	Local nQtPerPg

	Default nPagina  := 1

	aPgsIniFim := {}

	cQuery := " SELECT TTI.TTI_DTENT, TTI.TTI_HRENT FROM "
	cQuery += RetSQLName("TTI") + " TTI "
	cQuery += " WHERE TTI.TTI_CODVEI = '" + cCODVei + "' "
	cQuery += " AND TTI.TTI_EMPMOV = TTI.TTI_EMPVEI AND TTI.TTI_EMPMOV = '" + SM0->M0_CODIGO + "' "
	cQuery += " AND TTI.D_E_L_E_T_ != '*' "
	cQuery += " ORDER BY TTI.TTI_DTENT||TTI.TTI_HRENT DESC"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TCGenQry( ,,cQuery ),cAliasQry,.F.,.T. )

	nQtReg := M985RecCnt( cAliasQry )

	( cAliasQry )->( dbGoTop() )

	While !( cAliasQry )->( EoF() )

		aAdd( aPgsIniFim,{ "",( cAliasQry )->( TTI_DTENT+TTI_HRENT ) } )

		nQtPerPg	:= Min( nRegPerPag, nQtReg-nRegLastPg ) //Quantidade de registros da pagina atual
		nRegLastPg	+= nQtPerPg //Quantidade de processados até o momento

		If nQtPerPg > 1
			( cAliasQry )->( dbSkip( nQtPerPg-1 ) )
		EndIf

		aPgsIniFim[Len( aPgsIniFim )][1] := ( cAliasQry )->( TTI_DTENT+TTI_HRENT )

		( cAliasQry )->( dbSkip() )

	End While

	If Len( aPgsIniFim ) == 0
		aAdd( aPgsIniFim,{ "", "" } )
	EndIf

	nTotalPag  := Len( aPgsIniFim )
	nPagAtu    := nPagina
	cRecTTIIni := aPgsIniFim[nPagAtu][1]
	cRecTTIFim := aPgsIniFim[nPagAtu][2]

	Eval( bAtuNextPrev )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuTRBVeic
Função que invoca a atualização da (cTRB) de veículos filtrando por um único bem
@param String cCodBem: Indica código do bem que deseja filtrar na query
de carregamento da (cTRB) de veículos
@author André Felipe Joriatti
@since 25/10/2013
@return Nil: ever Nil
/*/
//---------------------------------------------------------------------
Static Function fAtuTRBVeic( cCodBem )

	Processa( { |lEnd| MNT985VEI( cDeEF,cAteEF,cTipList,cCodBem ) },STR0001 ) // "Aguarde... Atualizando Veículos"

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} fBusVeic
Função que invoca a atualização da (cTRB) de veículos filtrando por um único bem
@param String cEF1: De Empresa/Filial
@param String cEF2: Até Empresa/Filial
@param String cTPL: Tipo/Situação dos veículos para listar
@param String cCodBem: Indica código do bem que deseja filtrar na query
@author Tainã Alberto Cardoso
@since 10/12/2015
@return Nil: ever Nil
/*/
//---------------------------------------------------------------------
Static Function fBusVeic(cEF1,cEF2,cTPL,cCodBR)

	Local _cGetDB   	:= TcGetDb()
	Local cAliasQry 	:= GetNextAlias()
	Local nX			:= 0
	Local lEptcCodBR 	:= Empty( cCodBR )
	Local lMNTA9856		:= ExistBlock("MNTA9856")
	Local nTamEmp		:= Len(IIf(FindFunction("FWGrpCompany"),FWGrpCompany(),SM0->M0_CODIGO))//TAMSX3( "M0_CODIGO" )[1] //Busca tamanho da Empresa.
	Local nTamFil		:= Len(IIf(FindFunction("FWCodFil"),FWCodFil(),SM0->M0_CODFIL))//TAMSX3( "M0_CODFIL" )[1] //Busca tamanho da Filia.

	cEF1 := NGTROCAFILI("ST9",cEF1)
	cEF2 := NGTROCAFILI("ST9",cEF2)

	dbSelectArea(cTRBVei)

	cQuery := "SELECT '"+SM0->M0_CODIGO+"' AS EMPST9, ST9.T9_FILIAL AS FILST9, TTI.TTI_EMPMOV AS EMPTTI,TTI.TTI_FILMOV AS FILTTI,"
	cQuery += " ST9.T9_FILIAL,ST9.T9_CODBEM,ST9.T9_PLACA,ST9.T9_STATUS,TQY.TQY_DESTAT,TQY.TQY_FILIAL,TTI.TTI_TIPMOV"
	If lMVROTAS
		cQuery += ", TTT.TTT_CODROT, TTT.TTT_NMROTA"
	EndIf
	cQuery += " FROM "+RetSQLName("ST9")+" ST9"
	cQuery += " LEFT JOIN "+RetSQLName("TQY")+" TQY ON ST9.T9_STATUS = TQY.TQY_STATUS"
	If FWModeAccess("ST9",3, SM0->M0_CODIGO) == FWModeAccess("TQY",3, SM0->M0_CODIGO)
		cQuery += " AND (TQY.TQY_FILIAL IS NULL OR TQY.TQY_FILIAL = ST9.T9_FILIAL)"
	EndIf
	cQuery += " LEFT JOIN "+RetSQLName("TTI")+" TTI ON ST9.T9_FILIAL = TTI.TTI_FILVEI AND ST9.T9_CODBEM = TTI.TTI_CODVEI"

	If lMVROTAS
		cQuery += " LEFT JOIN "+RetSQLName("TTT")+" TTT ON TTI.TTI_TIPMOV='2' AND TTI.TTI_ROTASA = TTT.TTT_CODROT "
		cQuery += " AND TTT.TTT_EMPROP = '"+SM0->M0_CODIGO+"' AND TTT.TTT_FILPRO = '"+xFilial("TTT")+"'"
	EndIf
	cQuery += " WHERE (T9_CATBEM = '2' OR T9_CATBEM = '4') AND T9_SITBEM = 'A' AND T9_ESTRUTU = 'N'"
	If (cTPL == '2') //Em Viagem
		cQuery += " AND TTI.TTI_TIPMOV = '2' "
	ElseIf (cTPL == '3') //Na Garagem
		cQuery += " AND TTI.TTI_TIPMOV = '1' "
	EndIf
	cQuery += " AND (ST9.T9_FILIAL >= '"+cEF1+"') AND (ST9.T9_FILIAL <= '"+cEF2+"')"

	cQuery += " AND (TTI.TTI_DTENT IS NULL AND TTI.TTI_HRENT IS NULL )"

	cQuery += " AND (TQY.D_E_L_E_T_ IS NULL OR TQY.D_E_L_E_T_ <> '*')  AND ST9.D_E_L_E_T_ <> '*'"
	cQuery += " AND (TTI.D_E_L_E_T_ IS NULL OR TTI.D_E_L_E_T_ <> '*')"
	If lMVROTAS
		cQuery += " AND (TTT.D_E_L_E_T_ IS NULL OR TTT.D_E_L_E_T_ <> '*')"
	EndIf

	// Filtra pelo código do bem caso o mesmo tenha sido informado
	If !lEptcCodBR
		cQuery += " AND T9_CODBEM = '" + PadR( cCodBR,TAMSX3( "T9_CODBEM" )[1] ) + "'"
	EndIf

	// PE para alterar o filtro do carregamento do browse inicial
	If ExistBlock("MNTA9856")
		cQuery := ExecBlock("MNTA9856",.F.,.F.,{cQuery,SM0->M0_CODIGO})
	EndIf

	cQuery += " ORDER BY EMPST9, FILST9, T9_CODBEM"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	ProcRegua(M985RecCnt(cAliasQry))

	dbSelectArea( cAliasQry )
	dbGoTop()

	While !EoF()

		IncProc()

		If !lEptcCodBR
			NGDBAREAORDE(cTRBVei,01)
			dbSeek( (cAliasQry)->FILST9 + (cAliasQry)->T9_CODBEM)
		EndIf

		RecLock( cTRBVei,lEptcCodBR )
		(cTRBVei)->EMPRESA := (cAliasQry)->EMPST9
		(cTRBVei)->FILIAL  := (cAliasQry)->FILST9
		(cTRBVei)->CODBEM  := (cAliasQry)->T9_CODBEM
		(cTRBVei)->PLACA   := (cAliasQry)->T9_PLACA

		(cTRBVei)->TIPMOV	 := (cAliasQry)->TTI_TIPMOV
		If (cAliasQry)->TTI_TIPMOV = '1' //Filial
			(cTRBVei)->LOCAL  := NGSEEKSM0((cAliasQry)->EMPTTI+(cAliasQry)->FILTTI,{"M0_NOME"})[1]
		ElseIf (cAliasQry)->TTI_TIPMOV = '2' //Rota
			(cTRBVei)->LOCAL  := If(lMVROTAS,(cAliasQry)->TTT_NMROTA,STR0165)  //"Em Viagem"
		EndIf
		(cTRBVei)->EMPTTI  := (cAliasQry)->EMPTTI
		(cTRBVei)->FILTTI  := (cAliasQry)->FILTTI

		(cTRBVei)->STATUS  := (cAliasQry)->T9_STATUS
		(cTRBVei)->DESTAT  := (cAliasQry)->TQY_DESTAT
		(cTRBVei)->BLOQPT  := "F" // False

		MsUnLock( cTRBVei )

		NGDBSELSKIP( cAliasQry )

	End While

	(cAliasQry)->(dbCloseArea())

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985HRET
Inclusão de Histórico Retroativo
@author Bruno Lobo de Souza
@since 15/12/2015
@return Nil: ever Nil
/*/
//---------------------------------------------------------------------
Function MNT985HRET( nOpcX )

	Local lRet      := .T.
	Local aOldNgBtn := ACLONE(aNgButton)
	Local cOldEmp   := cEmpAnt
	Local dData, cHora
	Local cRotaEnt, cRotaSai

	//Variaveis para NGCAD01 (TTI)
	Private cCADASTRO	:= Oemtoansi(STR0211)  //"[Controle de Portaria] - Inclusão Histórico Retroativo"
	Private aRELAC		:= {}
	Private aVARNAO		:= {}
	Private aCHOICE		:= {}
	Private bNGGRAVA	:= {|| GravSai985()}
	Private INCLUI		:= .F.
	Private aNgButton	:= {}
	Private cROTA		:= ""
	Private nOpc 		:= nOpcX  //variavel acessivel pelos PE's

	//Variaveis para contadores
	Private cHORCON1 := cHORCON2  := '  :  '
	Private TIPOACOM := TIPOACOM2 := .F.
	Private lCHKCON1 := lCHKCON2  := .F.

	//Prepara ALIAS's
	NGPrepTBL( { {"ST9"}, {"STP"}, {"TPE"}, {"TPP"}, {"TQS"}, {"TT8"}, {"STZ"} }, (cTRBVei)->EMPRESA )

	//WHEN dos campos de Contador
	dbSelectArea( "ST9" )
	dbSetOrder( 01 )
	dbSeek( (cTRBVei)->FILIAL + (cTRBVei)->CODBEM )
	TIPOACOM := ST9->T9_TEMCONT == "S"
	//FindFunction remover na release GetRPORelease() >= '12.1.027'
	If FindFunction("MNTCont2")
		TIPOACOM2 := MNTCont2(NGTROCAFILI( "TPE", (cTRBVei)->FILIAL, (cTRBVei)->EMPRESA ), (cTRBVei)->CODBEM )
	Else
		dbSelectarea( "TPE" )
		dbSetorder( 01 )
		TIPOACOM2 := If( dbSeek( NGTROCAFILI( "TPE", (cTRBVei)->FILIAL, (cTRBVei)->EMPRESA ) + (cTRBVei)->CODBEM ), .T., .F. )
	EndIf

	//Seleciona dados referente a movimentacao anterior
	dData	:= If( nOpcX==3, dDataBase, TTI->TTI_DTSAI )
	cHora	:= If( nOpcX==3, Substr( Time(), 1, 5 ), TTI->TTI_HRSAI )
	aUltTTI := M985UltTTI( (cTRBVei)->CODBEM,(cTRBVei)->FILIAL, (cTRBVei)->EMPRESA, 1, { "TTI_ROTAEN", "TTI_ESCENT" }, dData, cHora, 1 )
	aNxtTTI := M985UltTTI( (cTRBVei)->CODBEM,(cTRBVei)->FILIAL, (cTRBVei)->EMPRESA, 1, { "TTI_ROTAEN", "TTI_ESCENT" }, dData, cHora, 2 )

	//WHEN dos campos de Rota/Escala
	If lRet .And. !Empty(aTRAVEL) //em decorrencia de lMVROTAS

		lROTA	:= .T.
		lESCALA	:= .F.

		//Se a rota ja estiver sendo usada em outra movimentacao da mesma viagem, nao permite alterar
		If lRet .And. nOpcX != 3
			aNxtTTI := M985UltTTI((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA,1,{"TTI_ROTAEN","TTI_ESCENT"},dData,cHora,2)
			lROTA := !Empty(aNxtTTI) .And. TTI->TTI_ROTASA != aNxtTTI[5]
		EndIf

		If lRet .And. !lROTA
			aAdd(aRELAC,{"TTI_ROTASA","aUltTTI[5]"})
			aAdd(aRELAC,{"TTI_ESCSAI","TTI->TTI_ESCENT"})
		EndIf
	EndIf

	//Inicializador padrão dos campos
	aAdd(aRELAC,{"TTI_EMPMOV","SM0->M0_CODIGO"})
	aAdd(aRELAC,{"TTI_FILMOV","FWCodFil()"})
	aAdd(aRELAC,{"TTI_EMPVEI","(cTRBVei)->EMPRESA"})
	aAdd(aRELAC,{"TTI_FILVEI","(cTRBVei)->FILIAL"})
	aAdd(aRELAC,{"TTI_CODVEI","(cTRBVei)->CODBEM"})
	aAdd(aRELAC,{"TTI_DTENT","CTOD('')"})
	aAdd(aRELAC,{"TTI_HRENT","'  :  '"})
	aAdd(aRELAC,{"TTI_DTSAI","CTOD('')"})
	aAdd(aRELAC,{"TTI_HRSAI","'  :  '"})
	aAdd(aRELAC,{"TTI_TIPMOV","'2'"})
	aAdd(aRELAC,{"TTI_USUENT","SubStr(cUserName,1,25)"})
	aAdd(aRELAC,{"TTI_USUSAI","SubStr(cUserName,1,25)"})

	//Campos retirados de tela
	aAdd(aVARNAO,'TTI_DESROT')
	aAdd(aVARNAO,'TTI_DESESC')
	aAdd(aVARNAO,'TTI_TIPMOV')
	aAdd(aVARNAO,'TTI_USUENT')
	aAdd(aVARNAO,'TTI_USUSAI')
	If !lMVROTAS
		aAdd(aVARNAO,'TTI_ROTAEN')
		aAdd(aVARNAO,'TTI_ESCENT')
		aAdd(aVARNAO,'TTI_DESESC')
		aAdd(aVARNAO,'TTI_ROTASA')
		aAdd(aVARNAO,'TTI_DESROT')
		aAdd(aVARNAO,'TTI_ESCSAI')
	EndIf

	If lRet
		If nOpcX == 3
			dbSelectArea((cTRBOS))
			If EoF() .Or. (!EoF() .And. (cTRBOS)->CODBEM != (cTRBVei)->CODBEM)
				MNT985SEL((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA)
			EndIf

			If (cTRBVei)->BLOQPT == "T"
				MsgAlert(STR0126+CHR(13)+;  //"Existe pelo menos um Servico / Sintoma / Etapa nas Ordens de Servico"
				STR0127,STR0128)  //"que bloqueia a saida deste veículo!"##"Bloqueio de Saída"
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//Monta a tela para realizar a inclusão do histórico retroativo ENTRADA+SAIDA
	If nOpcX == 3
		If lRet
			aCHOICE := NGCAMPNSX3( "TTI", aVARNAO )
			aAdd( aCHOICE, 'NOUSER' )  //mantem apenas campos de usuario de aCHOICE

			//Realiza Inclusão do Histórico retroativo
			SetInclui()
			NGCAD01("TTI",Recno(),3)
			fCountTTI( ( cTRBVei )->CODBEM )
			INCLUI := .F.
			ALTERA := .F.
		EndIf
	EndIf

	//Retorna ALIAS's original
	NGPrepTBL( { {"ST9"}, {"STP"}, {"TPE"}, {"TPP"}, {"TQS"}, {"TT8"}, {"STZ"} }, cOldEmp )
	aNgButton := ACLONE(aOldNgBtn)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldIncHis
Valida Inclusão de Histórico Retroativo
@author Bruno Lobo de Souza
@since 15/12/2015
@return Boolean
/*/
//---------------------------------------------------------------------
Static Function fVldIncHis()

	Local lRet		:= .T.
	Local aFirsTTI	:= {}
	Local aLastTTI	:= {}
	Local aOutTTI	:= {}
	Local aInTTI	:= {}

	If ( dDataBase - M->TTI_DTENT ) > nMVVARSHES
		ShowHelpDlg("INVALIDO",{STR0208,""},2,{STR0209+ cValToChar(nMVVARSHES) +STR0210,""},2) //"Data/hora é anterior a variação de dias permitida."##"Altere o conteudo do parâmetro MV_NGVDMES ou informe uma movimentação de no maximo "##" dias atras."
		lRet := .F.
	EndIf

	//seleciona dados referente a movimentacao anterior
	aFirsTTI	:= M985UltTTI((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA,1,{"TTI_ROTASA","TTI_ESCSAI"},M->TTI_DTENT,M->TTI_HRENT,1)
	aLastTTI	:= M985UltTTI((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA,1,{"TTI_ROTAEN","TTI_ESCENT"},M->TTI_DTENT,M->TTI_HRENT,2)

	aOutTTI		:= M985UltTTI((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA,2,{"TTI_ROTASA","TTI_ESCSAI"},M->TTI_DTENT,M->TTI_HRENT,1)
	aInTTI		:= M985UltTTI((cTRBVei)->CODBEM,(cTRBVei)->FILIAL,(cTRBVei)->EMPRESA,1,{"TTI_ROTAEN","TTI_ESCENT"},M->TTI_DTSAI,M->TTI_HRSAI,2)

	If Empty(aFirsTTI) .And. lRet
		ShowHelpDlg("INVALIDO",{STR0203,""},2,{STR0184,""},2) //"Data/hora é anterior a primeira movimentação."##"Altere data/hora maiores que a entrada inicial."
		lRet := .F.
	ElseIf Empty(aLastTTI) .And. lRet
		ShowHelpDlg("INVALIDO",{STR0204,""},2,{STR0205,""},2) //"Data/hora é posterior a ultima movimentação."##""Para essa movimentação utilize o botão de inclusão.""
		lRet := .F.
	ElseIf ( Empty(aOutTTI) .Or. Empty(aInTTI) ) .And. lRet
		ShowHelpDlg("INVALIDO",{STR0206,""},2,{STR0207,""},2) //"Data/hora é anterior a primeira movimentação."##"Altere data/hora maiores que a entrada inicial."
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985INIP
Valida Inclusão de Histórico Retroativo

@author Bruno Lobo de Souza
@since 15/12/2015
@return Boolean
/*/
//---------------------------------------------------------------------
Function MNT985INIP(cType)

	Local cDesc := ""
	Local cRota := If( M->TTI_TIPMOV == "2", M->TTI_ROTASA, M->TTI_ROTAEN )
	Local cEsc  := If( M->TTI_TIPMOV == "2", M->TTI_ESCSAI, M->TTI_ESCENT )

	If cType == "1" //Descrição da rota
		If cRota == "ENTRAD"
			cDesc := "ENTRADA INICIAL NO SISTEMA"
		Else
			cDesc := Posicione("TTT", 2, xFilial("TTT")+cRota, "TTT_NMROTA")
		EndIf
	ElseIf cType == "2" //Descrição da escala
		If cEsc == '000'
			cDesc := NGRETSX3BOX("TTS_TIPESC","4")
		Else
			cDesc := Posicione("TTS", 2, xFilial("TTS")+cESC, "TTS_DESCRI")
		EndIf
	EndIf

Return cDesc
//---------------------------------------------------------------------
/*/{Protheus.doc} fTempTable
Criação das Tabelas Temporarias
@author douglas.constancio
@since 13/02/2017
@version undefined
@param cAliasTmp, characters, Alias Das Tabelas
@param aField, array, Campos da Tabela
@param aIndex, array, Indice das Tabelas
@type function
/*/
//---------------------------------------------------------------------
Static Function fTempTable(cAliasTmp, aField, aIndex)

	Local nIdx
	Local oTempTbl

	//Intancia classe FWTemporaryTable
	oTempTbl  := FWTemporaryTable():New( cAliasTmp, aField )
	//Cria Indices para tabela temporaria
	For nIdx := 1 To Len(aIndex)
		oTempTbl:AddIndex( "Ind"+cValToChar(nIdx) , aIndex[nIdx] )
	Next
	//Cria objeto
	oTempTbl:Create()

Return oTempTbl
