//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "MsGraphi.ch"

//Constantes
#Define STR_PULA    Chr(13)+Chr(10)
#Define CLR_P_A1   RGB(084,120,164) //Cor Ano 1    - Protheus 
#Define CLR_P_A2   RGB(171,225,108) //Cor Ano 2    - Protheus
#Define CLR_P_A3   RGB(207,136,077) //Cor Ano 3    - Protheus
#Define CLR_P_A4   RGB(166,085,082) //Cor Ano 4    - Protheus
#Define CLR_P_A5   RGB(130,130,130) //Cor Ano 5    - Protheus
#Define CLR_H_A1   "5478a4"         //Cor Ano 1    - HTML
#Define CLR_H_A2   "abe16c"         //Cor Ano 2    - HTML
#Define CLR_H_A3   "cf884d"         //Cor Ano 3    - HTML
#Define CLR_H_A4   "a65552"         //Cor Ano 4    - HTML
#Define CLR_H_A5   "828282"         //Cor Ano 5    - HTML

//Cores usadas nos gráficos
Static aRandAno1 := {"084,120,164", "007,013,017"}
Static aRandAno2 := {"171,225,108", "017,019,010"}
Static aRandAno3 := {"207,136,077", "020,020,006"}
Static aRandAno4 := {"166,085,082", "017,007,007"}
Static aRandAno5 := {"130,130,130", "008,008,008"}

/*/{Protheus.doc} VAFATC01
Função que demonstra o faturamento da empresa, por anos
@type function
@author Atilio
@since 17/11/2015
@version 1.0
	@example
	u_VAFATC01()
	@obs A rotina foi montada para consultar até 5 anos
	Estrutura do aDadosAnos:
	  Ano     == aDadosAnos[nVar][1]
	  Valores == aDadosAnos[nVar][2][nMes]
	Onde: nVar é a linha que pode variar (1 a 5 anos), e nMes é o mês que vai de 1 a 12
	
	As grids foram feitas para ficarem vísiveis em telas no mínimo de 14 polegadas...
	  foi feito tratativa para ficar na tela inteira, porém cliente solicitou essa alteração 
/*/

User Function VAFATC01()
	Local aArea := GetArea()
	Local cPerg := PadR("X_VAFATC01", 2)
	Private dDataDe := sToD("")
	Private dDataAt := sToD("")
	Private nTipo   := 0
	
	
	//Cria o grupo de perguntas
	fValidPerg(cPerg)
	
	//Se a pergunta for confirmada
	If Pergunte(cPerg, .T.)
		dDataDe := MV_PAR01
		dDataAt := MV_PAR02
		nTipo := MV_PAR03
	
		Processa({|| fMontaTela()}, "Carregando...")
	EndIf
	
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fValidPerg                                                   |
 | Autor: Daniel Atilio                                                |
 | Data:  17/11/2015                                                   |
 | Desc:  Função para criação do grupo de perguntas                    |
 *---------------------------------------------------------------------*/

Static Function fValidPerg(cPerg)
	//(		cGrupo,	cOrdem,	cPergunt,				cPergSpa,		cPergEng,	cVar,		cTipo,	nTamanho,					nDecimal,	nPreSel,	cGSC,	cValid,	cF3,	cGrpSXG,	cPyme,	cVar01,		cDef01,	cDefSpa1,	cDefEng1,	cCnt01,	cDef02,		cDefSpa2,	cDefEng2,	cDef03,			cDefSpa3,		cDefEng3,	cDef04,	cDefSpa4,	cDefEng4,	cDef05,	cDefSpa5,	cDefEng5,	aHelpPor,	aHelpEng,	aHelpSpa,	cHelp)
	PutSx1(cPerg,		"01",		"Ano Inicial?",		"",				"",			"mv_ch0",	"D",	08,							0,			0,			"G",	"", 		"",		"",			"",		"mv_par01",	"",			"",			"",			"",			"",				"",			"",			"",					"",				"",			"",			"",			"",			"",			"",			"",			{},			{},			{},			"")
	PutSx1(cPerg,		"02",		"Ano Final?",			"",				"",			"mv_ch1",	"D",	08,							0,			0,			"G",	"", 		"",		"",			"",		"mv_par02",	"",			"",			"",			"",			"",				"",			"",			"",					"",				"",			"",			"",			"",			"",			"",			"",			{},			{},			{},			"")
	PutSx1(cPerg,		"03",		"Tipo?",				"",				"",			"mv_ch2",	"N",	1,							0,			1,			"C",	"", 		"",		"",			"",		"mv_par03",	"NF",		"",			"",			"",			"Pedido",		"",			"",			"",					"",				"",			"",			"",			"",			"",			"",			"",			{},			{},			{},			"")
Return

/*---------------------------------------------------------------------*
 | Func:  fMontaTela                                                   |
 | Autor: Daniel Atilio                                                |
 | Data:  17/11/2015                                                   |
 | Desc:  Função que monta a tela                                      |
 *---------------------------------------------------------------------*/

Static Function fMontaTela()
	Local		aAreaCon	:= GetArea()
	Local		cLogoDom	:= "\system\LGMID.png"
	Local		oGrpCab
	Local		oGrpLeg
	Local		oScroll
	Local		nFimAno	:= 0         
	Local		nAux		:= 0
	Local		dDatAux	:= dDataDe
	Private	aAnos		:= Array(5)
	Private	aDadosAnos	:= {}
	//Gets de Legendas
	Private	oGetAno1, cGetAno1 := ""
	Private	oGetAno2, cGetAno2 := ""
	Private	oGetAno3, cGetAno3 := ""
	Private	oGetAno4, cGetAno4 := ""
	Private	oGetAno5, cGetAno5 := ""
	//Objetos da tela
	Private	oBmpLogo
	Private	oDlgPvt
	Private	oFolderPvt
	Private	oScroMes
	Private	oScroBim
	Private	oScroTri
	Private	oScroSem
	Private	oScroNon
	Private	oScroAno
	//Tamanho da janela
	Private	aTamanho	:= MsAdvSize()
	Private	nJanLarg	:= aTamanho[5]
	Private	nJanAltu	:= aTamanho[6]
	Private	nColMeio	:= (nJanLarg)/4
	//Grid Meses
	Private	oGetMes
	Private	aHeadMes	:= {}
	Private	aColsMes	:= {}
	//Grid Bimestres
	Private	oGetBim
	Private	aHeadBim	:= {}
	Private	aColsBim	:= {}
	//Grid Trimestres
	Private	oGetTri
	Private	aHeadTri	:= {}
	Private	aColsTri	:= {}
	//Grid Semestres
	Private	oGetSem
	Private	aHeadSem	:= {}
	Private	aColsSem	:= {}
	//Grid Nonamestres
	Private	oGetNon
	Private	aHeadNon	:= {}
	Private	aColsNon	:= {}
	//Grid Anual
	Private	oGetAno
	Private	aHeadAno	:= {}
	Private	aColsAno	:= {}
	//Gráficos
	Private oChartJan, 	oChartFev, 	oChartMar, 	oChartAbr, 	oChartMai, 	oChartJun, 	oChartJul, 	oChartAgo, 	oChartSet, 	oChartOut, 	oChartNov, 	oChartDez
	Private oChartJan2, 	oChartFev2, 	oChartMar2, 	oChartAbr2, 	oChartMai2, 	oChartJun2, 	oChartJul2, 	oChartAgo2, 	oChartSet2, 	oChartOut2, 	oChartNov2, 	oChartDez2
	Private oChart1Bi, 	oChart2Bi, 	oChart3Bi, 	oChart4Bi, 	oChart5Bi, 	oChart6Bi
	Private oChart1Bi2, 	oChart2Bi2, 	oChart3Bi2, 	oChart4Bi2, 	oChart5Bi2, 	oChart6Bi2
	Private oChart1Tr, 	oChart2Tr, 	oChart3Tr, 	oChart4Tr
	Private oChart1Tr2, 	oChart2Tr2, 	oChart3Tr2, 	oChart4Tr2
	Private oChart1Se, 	oChart2Se
	Private oChart1Se2, 	oChart2Se2
	Private oChart1No
	Private oChart1No2
	Private oChartAno
	Private oChartAno2
	
	//Pega a diferença de anos
	nFimAno := DateDiffYear(dDataAt, dDataDe)+1
	
	//Se tiver mais que 6 anos, encerra a rotina
	If nFimAno >= 6
		MsgStop("Só pode ter um período de diferença de até <b>5 anos</b>!", "Atenção")
		Return
	EndIf
	
	//Percorrendo os anos
	For nAux := 1 To nFimAno
		aAnos[nAux] := Year(dDatAux)
		dDatAux := YearSum(dDatAux, 1)
	Next
	
	//Função que carrega as grids
	fCarGrids()
	
	//Criando a janela
	DEFINE MSDIALOG oDlgPvt TITLE "Consulta de Faturamento" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
		//Cabeçalho
		@ 001, 060 GROUP oGrpCab TO 021, (nJanLarg/2) PROMPT "Faturamento Anual - FAT v1.000: " OF oDlgPvt COLOR 0, 16777215 PIXEL
	
			//Se não estiver em branco a imagem e ela existir, mostra o logo
			If !Empty(cLogoDom) .And. File(cLogoDom)
				@ 003, 003 BITMAP oBmpLogo SIZE 48, 20 OF oDlgPvt FILENAME cLogoDom NOBORDER PIXEL
				oBmpLogo:lStretch := .T.
			EndIf
	
			//Botões
			@007, (nJanLarg/2-003)-(0042*01) BUTTON "&Sair"				SIZE 40, 12 FONT  Action ( oDlgPvt:End() )													PIXEL of oDlgPvt
			@007, (nJanLarg/2-003)-(0042*02) BUTTON "&Imprimir"			SIZE 40, 12 FONT  Action ( fImprimir() )														PIXEL of oDlgPvt
		
		//Abas
		@ 027, 003 FOLDER oFolderPvt SIZE (nJanLarg/2)-03, (nJanAltu/2)-055 OF oDlgPvt ITEMS ;
			"Meses",;
			"Bimestres",;
			"Trimestres",;
			"Semestres",;
			"Nonamestres",;
			"Anual" COLORS 0, 14215660 PIXEL
		
			//Barra de rolagem Aba Meses
			@ 003, 002 SCROLLBOX oScroMes VERTICAL SIZE (nJanAltu/2)-075, (nJanLarg/2)-09 OF oFolderPvt:aDialogs[1] NO BORDER
				//Aba meses
				oGetMes := MsNewGetDados():New(	003,;												//nTop
	    											003,;												//nLeft
	    											070,;												//nBottom
	    											Iif(nJanLarg <= 1400, (nJanLarg/2)-18, 664),;	//nRight 
	    											0,;													//nStyle
	    											"",;												//cLinhaOk
	    											,;													//cTudoOk
	    											"",;												//cIniCpos
	    											{},;												//aAlter
	    											,;													//nFreeze
	    											999,;												//nMax
	    											,;													//cFieldOK
	    											,;													//cSuperDel
	    											,;													//cDelOk
	    											oScroMes,;											//oWnd
	    											aHeadMes,;											//aHeader
	    											aColsMes)											//aCols
				oGetMes:lActive := .F.
				
				//Aba dos meses
				@ 073, 003 FOLDER oFolderMes SIZE (nJanLarg/2)-03, (nJanAltu/2)-150 OF oScroMes ITEMS ;
					"Janeiro",;
					"Fevereiro",;
					"Março",;
					"Abril",;
					"Maio",;
					"Junho",;
					"Julho",;
					"Agosto",;
					"Setembro",;
					"Outubro",;
					"Novembro",;
					"Dezembro" COLORS 0, 14215660 PIXEL
				
				//Criando os paineis que conterão os gráficos
				oPanJan	:= tPanel():New(001, 001, 							"", oFolderMes:aDialogs[01], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPanJan2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderMes:aDialogs[01], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPanFev	:= tPanel():New(001, 001, 							"", oFolderMes:aDialogs[02], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPanFev2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderMes:aDialogs[02], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPanMar	:= tPanel():New(001, 001, 							"", oFolderMes:aDialogs[03], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPanMar2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderMes:aDialogs[03], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPanAbr	:= tPanel():New(001, 001, 							"", oFolderMes:aDialogs[04], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPanAbr2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderMes:aDialogs[04], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPanMai	:= tPanel():New(001, 001, 							"", oFolderMes:aDialogs[05], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPanMai2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderMes:aDialogs[05], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPanJun	:= tPanel():New(001, 001, 							"", oFolderMes:aDialogs[06], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPanJun2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderMes:aDialogs[06], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPanJul	:= tPanel():New(001, 001, 							"", oFolderMes:aDialogs[07], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPanJul2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderMes:aDialogs[07], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPanAgo	:= tPanel():New(001, 001, 							"", oFolderMes:aDialogs[08], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPanAgo2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderMes:aDialogs[08], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPanSet	:= tPanel():New(001, 001, 							"", oFolderMes:aDialogs[09], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPanSet2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderMes:aDialogs[09], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPanOut	:= tPanel():New(001, 001, 							"", oFolderMes:aDialogs[10], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPanOut2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderMes:aDialogs[10], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPanNov	:= tPanel():New(001, 001, 							"", oFolderMes:aDialogs[11], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPanNov2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderMes:aDialogs[11], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPanDez	:= tPanel():New(001, 001, 							"", oFolderMes:aDialogs[12], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPanDez2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderMes:aDialogs[12], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				
			//Barra de rolagem Aba Bimestres
			@ 003, 002 SCROLLBOX oScroBim VERTICAL SIZE (nJanAltu/2)-075, (nJanLarg/2)-09 OF oFolderPvt:aDialogs[2] NO BORDER
				//Aba meses
				oGetBim := MsNewGetDados():New(	003,;													//nTop
	    											003,;													//nLeft
	    											070,;													//nBottom
	    											Iif(nJanLarg <= 1400, (nJanLarg/2)-128, 524),;	//nRight
	    											0,;														//nStyle
	    											"",;													//cLinhaOk
	    											,;														//cTudoOk
	    											"",;													//cIniCpos
	    											{},;													//aAlter
	    											,;														//nFreeze
	    											999,;													//nMax
	    											,;														//cFieldOK
	    											,;														//cSuperDel
	    											,;														//cDelOk
	    											oScroBim,;												//oWnd
	    											aHeadBim,;												//aHeader
	    											aColsBim)												//aCols
				oGetBim:lActive := .F.
				
				//Aba dos bimestres
				@ 073, 003 FOLDER oFolderBim SIZE (nJanLarg/2)-03, (nJanAltu/2)-150 OF oScroBim ITEMS ;
					"1º Bimestre",;
					"2º Bimestre",;
					"3º Bimestre",;
					"4º Bimestre",;
					"5º Bimestre",;
					"6º Bimestre" COLORS 0, 14215660 PIXEL
					
				//Criando os paineis que conterão os gráficos
				oPan1Bi	:= tPanel():New(001, 001, 							"", oFolderBim:aDialogs[01], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPan1Bi2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderBim:aDialogs[01], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPan2Bi	:= tPanel():New(001, 001, 							"", oFolderBim:aDialogs[02], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPan2Bi2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderBim:aDialogs[02], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPan3Bi	:= tPanel():New(001, 001, 							"", oFolderBim:aDialogs[03], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPan3Bi2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderBim:aDialogs[03], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPan4Bi	:= tPanel():New(001, 001, 							"", oFolderBim:aDialogs[04], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPan4Bi2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderBim:aDialogs[04], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPan5Bi	:= tPanel():New(001, 001, 							"", oFolderBim:aDialogs[05], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPan5Bi2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderBim:aDialogs[05], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPan6Bi	:= tPanel():New(001, 001, 							"", oFolderBim:aDialogs[06], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPan6Bi2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderBim:aDialogs[06], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				
			//Barra de rolagem Aba Trimestres
			@ 003, 002 SCROLLBOX oScroTri VERTICAL SIZE (nJanAltu/2)-075, (nJanLarg/2)-09 OF oFolderPvt:aDialogs[3] NO BORDER
				//Aba meses
				oGetTri := MsNewGetDados():New(	003,;													//nTop
	    											003,;													//nLeft
	    											070,;													//nBottom
	    											Iif(nJanLarg <= 1400, (nJanLarg/2)-288, 364),;	//nRight
	    											0,;														//nStyle
	    											"",;													//cLinhaOk
	    											,;														//cTudoOk
	    											"",;													//cIniCpos
	    											{},;													//aAlter
	    											,;														//nFreeze
	    											999,;													//nMax
	    											,;														//cFieldOK
	    											,;														//cSuperDel
	    											,;														//cDelOk
	    											oScroTri,;												//oWnd
	    											aHeadTri,;												//aHeader
	    											aColsTri)												//aCols
				oGetTri:lActive := .F.
				
				//Aba dos trimestres
				@ 073, 003 FOLDER oFolderTri SIZE (nJanLarg/2)-03, (nJanAltu/2)-150 OF oScroTri ITEMS ;
					"1º Trimestre",;
					"2º Trimestre",;
					"3º Trimestre",;
					"4º Trimestre" COLORS 0, 14215660 PIXEL
					
				//Criando os paineis que conterão os gráficos
				oPan1Tr	:= tPanel():New(001, 001, 							"", oFolderTri:aDialogs[01], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPan1Tr2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderTri:aDialogs[01], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPan2Tr	:= tPanel():New(001, 001, 							"", oFolderTri:aDialogs[02], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPan2Tr2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderTri:aDialogs[02], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPan3Tr	:= tPanel():New(001, 001, 							"", oFolderTri:aDialogs[03], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPan3Tr2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderTri:aDialogs[03], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPan4Tr	:= tPanel():New(001, 001, 							"", oFolderTri:aDialogs[04], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPan4Tr2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderTri:aDialogs[04], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				
			//Barra de rolagem Aba Semestres
			@ 003, 002 SCROLLBOX oScroSem VERTICAL SIZE (nJanAltu/2)-075, (nJanLarg/2)-09 OF oFolderPvt:aDialogs[4] NO BORDER
				//Aba meses
				oGetSem := MsNewGetDados():New(	003,;													//nTop
	    											003,;													//nLeft
	    											070,;													//nBottom
	    											Iif(nJanLarg <= 1400, (nJanLarg/2)-448, 204),;	//nRight
	    											0,;														//nStyle
	    											"",;													//cLinhaOk
	    											,;														//cTudoOk
	    											"",;													//cIniCpos
	    											{},;													//aAlter
	    											,;														//nFreeze
	    											999,;													//nMax
	    											,;														//cFieldOK
	    											,;														//cSuperDel
	    											,;														//cDelOk
	    											oScroSem,;												//oWnd
	    											aHeadSem,;												//aHeader
	    											aColsSem)												//aCols
				oGetSem:lActive := .F.
				
				//Aba dos semestres
				@ 073, 003 FOLDER oFolderSem SIZE (nJanLarg/2)-03, (nJanAltu/2)-150 OF oScroSem ITEMS ;
					"1º Semestre",;
					"2º Semestre" COLORS 0, 14215660 PIXEL
				
				//Criando os paineis que conterão os gráficos
				oPan1Se	:= tPanel():New(001, 001, 							"", oFolderSem:aDialogs[01], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPan1Se2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderSem:aDialogs[01], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				oPan2Se	:= tPanel():New(001, 001, 							"", oFolderSem:aDialogs[02], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPan2Se2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderSem:aDialogs[02], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				
			//Barra de rolagem Aba Nonamestre
			@ 003, 002 SCROLLBOX oScroNon VERTICAL SIZE (nJanAltu/2)-075, (nJanLarg/2)-09 OF oFolderPvt:aDialogs[5] NO BORDER
				//Aba nonamestre
				oGetNon := MsNewGetDados():New(	003,;													//nTop
	    											003,;													//nLeft
	    											070,;													//nBottom
	    											Iif(nJanLarg <= 1400, (nJanLarg/2)-528, 124),;	//nRight
	    											0,;														//nStyle
	    											"",;													//cLinhaOk
	    											,;														//cTudoOk
	    											"",;													//cIniCpos
	    											{},;													//aAlter
	    											,;														//nFreeze
	    											999,;													//nMax
	    											,;														//cFieldOK
	    											,;														//cSuperDel
	    											,;														//cDelOk
	    											oScroNon,;												//oWnd
	    											aHeadNon,;												//aHeader
	    											aColsNon)												//aCols
				oGetNon:lActive := .F.
				
				//Aba dos nonamestres
				@ 073, 003 FOLDER oFolderNon SIZE (nJanLarg/2)-03, (nJanAltu/2)-150 OF oScroNon ITEMS ;
					"1º Nonamestre" COLORS 0, 14215660 PIXEL
					
				//Criando os paineis que conterão os gráficos
				oPan1No	:= tPanel():New(001, 001, 							"", oFolderNon:aDialogs[01], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPan1No2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderNon:aDialogs[01], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
				
			//Barra de rolagem Aba Anual
			@ 003, 002 SCROLLBOX oScroAno VERTICAL SIZE (nJanAltu/2)-075, (nJanLarg/2)-09 OF oFolderPvt:aDialogs[6] NO BORDER
				//Aba meses
				oGetAno := MsNewGetDados():New(	003,;													//nTop
	    											003,;													//nLeft
	    											070,;													//nBottom
	    											Iif(nJanLarg <= 1400, (nJanLarg/2)-528, 124),;	//nRight
	    											0,;														//nStyle
	    											"",;													//cLinhaOk
	    											,;														//cTudoOk
	    											"",;													//cIniCpos
	    											{},;													//aAlter
	    											,;														//nFreeze
	    											999,;													//nMax
	    											,;														//cFieldOK
	    											,;														//cSuperDel
	    											,;														//cDelOk
	    											oScroAno,;												//oWnd
	    											aHeadAno,;												//aHeader
	    											aColsAno)												//aCols
				oGetAno:lActive := .F.
				
				//Aba anual
				@ 073, 003 FOLDER oFolderAno SIZE (nJanLarg/2)-03, (nJanAltu/2)-150 OF oScroAno ITEMS ;
					"Valor Anual" COLORS 0, 14215660 PIXEL
					
				//Criando os paineis que conterão os gráficos
				oPanAno	:= tPanel():New(001, 001, 							"", oFolderAno:aDialogs[01], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-3, 	(nJanAltu/2)-165)
				oPanAno2	:= tPanel():New(001, ((nJanLarg/2)-20)/2-3+12, 	"", oFolderAno:aDialogs[01], , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-20)/2-6, 	(nJanAltu/2)-165)
		
		//Legenda
		@ (nJanAltu/2)-21, 001 GROUP oGrpLeg TO (nJanAltu/2)-1, (nJanLarg/2) PROMPT "Legenda: " OF oDlgPvt COLOR 0, 16777215 PIXEL
			//Ano 1
			If !Empty(aAnos[1])
				cGetAno1 := "Ano 1: "+cValToChar(aAnos[1])
				@ (nJanAltu/2)-13, 003+(43*0)   MSGET oGetAno1 VAR    cGetAno1        SIZE 040, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL
				oGetAno1:lActive := .F.
				oGetAno1:setCSS("QLineEdit{background-color:#"+CLR_H_A1+"; color:#ffffff}")
			EndIf
			
			//Ano 2
			If !Empty(aAnos[2])
				cGetAno2 := "Ano 2: "+cValToChar(aAnos[2])
				@ (nJanAltu/2)-13, 003+(43*1)   MSGET oGetAno2 VAR    cGetAno2        SIZE 040, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL
				oGetAno2:lActive := .F.
				oGetAno2:setCSS("QLineEdit{background-color:#"+CLR_H_A2+";}")
			EndIf
			
			//Ano 3
			If !Empty(aAnos[3])
				cGetAno3 := "Ano 3: "+cValToChar(aAnos[3])
				@ (nJanAltu/2)-13, 003+(43*2)   MSGET oGetAno3 VAR    cGetAno3        SIZE 040, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL
				oGetAno3:lActive := .F.
				oGetAno3:setCSS("QLineEdit{background-color:#"+CLR_H_A3+"; color:#ffffff}")
			EndIf
			
			//Ano 4
			If !Empty(aAnos[4])
				cGetAno4 := "Ano 4: "+cValToChar(aAnos[4])
				@ (nJanAltu/2)-13, 003+(43*3)   MSGET oGetAno4 VAR    cGetAno4        SIZE 040, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL
				oGetAno4:lActive := .F.
				oGetAno4:setCSS("QLineEdit{background-color:#"+CLR_H_A4+"; color:#ffffff}")
			EndIf
			
			//Ano 5
			If !Empty(aAnos[5])
				cGetAno5 := "Ano 5: "+cValToChar(aAnos[5])
				@ (nJanAltu/2)-13, 003+(43*4)   MSGET oGetAno5 VAR    cGetAno5        SIZE 040, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL
				oGetAno5:lActive := .F.
				oGetAno5:setCSS("QLineEdit{background-color:#"+CLR_H_A5+"; color:#ffffff}")
			EndIf
			
			cGetTipo := "Tipo: "+Iif(nTipo==1, "NF", "Pedido")
			@ (nJanAltu/2)-13, (nJanLarg/2)-(43*1)   MSGET oGetTipo VAR    cGetTipo        SIZE 040, 007 OF oDlgPvt COLORS 0, 16777215 NOBORDER PIXEL
			oGetTipo:lActive := .F.
			oGetTipo:setCSS("QLineEdit{background-color:#fefefe; color:#ff0000}")
			
			//Função para criar os gráficos
			fCriaGraf()
			
	//Mostrando a janela
	ACTIVATE MSDIALOG oDlgPvt CENTERED

	RestArea(aAreaCon)
Return

/*---------------------------------------------------------------------*
 | Func:  fCarGrids                                                    |
 | Autor: Daniel Atilio                                                |
 | Data:  17/11/2015                                                   |
 | Desc:  Função que monta a grid                                      |
 *---------------------------------------------------------------------*/

Static Function fCarGrids()
	Local nAux := 0
	Local aAux := {}
	Local nMes := 0
	Local cQuery := ""
	Local dDiaIni := sToD("")
	Local dDiaFin := sToD("")
	
	aDadosAnos := {}
	ProcRegua(Len(aAnos)*12)
	
	//Percorre os anos
	For nAux := 1 To Len(aAnos)
		aAux := {}
		
		//Se tiver ano
		If !Empty(aAnos[nAux])
			aAux := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
			
			//Faz consultas SQL para popular os dados
			For nMes := 1 To 12
				IncProc("Analisando mês "+StrZero(nMes, 2)+", ano "+cValToChar(aAnos[nAux])+"...")
				
				//Pegando os dias
				dDiaIni := sToD(cValToChar(aAnos[nAux])+StrZero(nMes, 2)+"01")
				dDiaFin := LastDate(dDiaIni)
				
				//Montando a consulta
				cQuery := " SELECT "																					+ STR_PULA
				cQuery += " 	SUM( "																					+ STR_PULA
				cQuery += " 		CASE "																				+ STR_PULA
				cQuery += " 			WHEN SUBSTRING(D2_CF,2,3) NOT IN ( "										+ STR_PULA
				cQuery += " 					'912','949','914', "													+ STR_PULA
				cQuery += " 					'901','903','910', "													+ STR_PULA
				cQuery += " 					'202','201','411', "													+ STR_PULA
				cQuery += " 					'915','556','413','206') "											+ STR_PULA
				cQuery += " 				AND (D2_TIPO NOT IN ('I')) "											+ STR_PULA
				cQuery += " 			THEN D2_TOTAL "																+ STR_PULA
				cQuery += " 			ELSE 0 END "																	+ STR_PULA
				cQuery += " 	) AS TOTAL " 																			+ STR_PULA
				cQuery += " FROM "																					+ STR_PULA
				cQuery += " 	"+RetSQLName('SD2')+" SD2 "															+ STR_PULA
				cQuery += " 	LEFT JOIN "+RetSQLName('SF2')+" SF2 ON ( "										+ STR_PULA
				cQuery += " 		F2_FILIAL = D2_FILIAL "															+ STR_PULA
				cQuery += " 		AND F2_DOC = D2_DOC "															+ STR_PULA
				cQuery += " 		AND F2_SERIE = D2_SERIE "														+ STR_PULA
				cQuery += " 		AND SF2.D_E_L_E_T_ = '' "														+ STR_PULA
				cQuery += " 	) "																						+ STR_PULA
				cQuery += " WHERE "																					+ STR_PULA
				cQuery += " 	D2_FILIAL = '"+FWxFilial('SD2')+"' "												+ STR_PULA
				cQuery += " 	AND D2_EMISSAO >= '"+dToS(dDiaIni)+"' "											+ STR_PULA
				cQuery += " 	AND D2_EMISSAO <= '"+dToS(dDiaFin)+"' "											+ STR_PULA
				cQuery += " 	AND SUBSTRING(D2_CF, 2, 3) NOT IN ('901','903','910','915','556','206') "		+ STR_PULA
				cQuery += " 	AND D2_CF NOT IN ('5411','5413') "													+ STR_PULA
				cQuery += " 	AND SD2.D_E_L_E_T_ = '' "															+ STR_PULA
				cQuery := ChangeQuery(cQuery)
				TCQuery cQuery New Alias "QRY_DAD"
				
				//Atualiza valor do mês
				aAux[nMes] := QRY_DAD->TOTAL
				
				QRY_DAD->(DbCloseArea())
			Next
				
			//Adiciona nos dados dos anos
			aAdd(aDadosAnos, {aAnos[nAux], aAux})
		EndIf
	Next

	ProcRegua(7)
	IncProc("Carregando dados...")

	IncProc("Carregando dados dos Meses...")	
	//Monta o aHeader
	//					Titulo					Campo			Picture						Tamanho					Dec		Valid	Usado	Tipo
	aAdd(aHeadMes,{	"Ano",					"XX_ANO",		"",								04,							0,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadMes,{	"Janeiro",				"XX_JAN",		"@E 99,999,999.99",			11,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadMes,{	"Fevereiro",			"XX_FEV",		"@E 99,999,999.99",			11,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadMes,{	"Março",				"XX_MAR",		"@E 99,999,999.99",			11,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadMes,{	"Abril",				"XX_ABR",		"@E 99,999,999.99",			11,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadMes,{	"Maio",				"XX_MAI",		"@E 99,999,999.99",			11,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadMes,{	"Junho",				"XX_JUN",		"@E 99,999,999.99",			11,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadMes,{	"Julho",				"XX_JUL",		"@E 99,999,999.99",			11,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadMes,{	"Agosto",				"XX_AGO",		"@E 99,999,999.99",			11,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadMes,{	"Setembro",			"XX_SET",		"@E 99,999,999.99",			11,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadMes,{	"Outubro",				"XX_OUT",		"@E 99,999,999.99",			11,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadMes,{	"Novembro",			"XX_NOV",		"@E 99,999,999.99",			11,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadMes,{	"Dezembro",			"XX_DEZ",		"@E 99,999,999.99",			11,							2,		".F.",	".F.",	"N",	"", ""} )
	
	//Preenche o aCols
	For nAux := 1 To Len(aDadosAnos)
		aAdd(aColsMes,{	aDadosAnos[nAux][1],;		//Ano
							aDadosAnos[nAux][2][01],;	//Janeiro
							aDadosAnos[nAux][2][02],;	//Fevereiro
							aDadosAnos[nAux][2][03],;	//Março
							aDadosAnos[nAux][2][04],;	//Abril
							aDadosAnos[nAux][2][05],;	//Maio
							aDadosAnos[nAux][2][06],;	//Junho
							aDadosAnos[nAux][2][07],;	//Julho
							aDadosAnos[nAux][2][08],;	//Agosto
							aDadosAnos[nAux][2][09],;	//Setembro
							aDadosAnos[nAux][2][10],;	//Outubro
							aDadosAnos[nAux][2][11],;	//Novembro
							aDadosAnos[nAux][2][12],;	//Dezembro
							.F.})							//Excluído?
	Next
	
	IncProc("Carregando dados dos Bimestres...")
	//Monta o aHeader
	//					Titulo					Campo			Picture								Tamanho					Dec		Valid	Usado	Tipo
	aAdd(aHeadBim,{	"Ano",					"XX_ANO",		"",										04,							0,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadBim,{	"1º Bimestre",		"XX_PRI",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadBim,{	"2º Bimestre",		"XX_SEG",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadBim,{	"3º Bimestre",		"XX_TER",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadBim,{	"4º Bimestre",		"XX_QUA",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadBim,{	"5º Bimestre",		"XX_QUI",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadBim,{	"6º Bimestre",		"XX_SEX",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	
	//Preenche o aCols
	For nAux := 1 To Len(aDadosAnos)
		aAdd(aColsBim,{	aDadosAnos[nAux][1],;									//Ano
							aDadosAnos[nAux][2][01]+aDadosAnos[nAux][2][02],;	//1º Bimestre
							aDadosAnos[nAux][2][03]+aDadosAnos[nAux][2][04],;	//2º Bimestre
							aDadosAnos[nAux][2][05]+aDadosAnos[nAux][2][06],;	//3º Bimestre
							aDadosAnos[nAux][2][07]+aDadosAnos[nAux][2][08],;	//4º Bimestre
							aDadosAnos[nAux][2][09]+aDadosAnos[nAux][2][10],;	//5º Bimestre
							aDadosAnos[nAux][2][11]+aDadosAnos[nAux][2][12],;	//6º Bimestre
							.F.})														//Excluído?
	Next
	
	IncProc("Carregando dados dos Trimestres...")
	//Monta o aHeader
	//					Titulo					Campo			Picture								Tamanho					Dec		Valid	Usado	Tipo
	aAdd(aHeadTri,{	"Ano",					"XX_ANO",		"",										04,							0,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadTri,{	"1º Trimestre",		"XX_PRI",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadTri,{	"2º Trimestre",		"XX_SEG",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadTri,{	"3º Trimestre",		"XX_TER",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadTri,{	"4º Trimestre",		"XX_QUA",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	
	//Preenche o aCols
	For nAux := 1 To Len(aDadosAnos)
		aAdd(aColsTri,{	aDadosAnos[nAux][1],;															//Ano
							aDadosAnos[nAux][2][01]+aDadosAnos[nAux][2][02]+aDadosAnos[nAux][2][03],;	//1º Trimestre
							aDadosAnos[nAux][2][04]+aDadosAnos[nAux][2][05]+aDadosAnos[nAux][2][06],;	//2º Trimestre
							aDadosAnos[nAux][2][07]+aDadosAnos[nAux][2][08]+aDadosAnos[nAux][2][09],;	//3º Trimestre
							aDadosAnos[nAux][2][10]+aDadosAnos[nAux][2][11]+aDadosAnos[nAux][2][12],;	//4º Trimestre
							.F.})																				//Excluído?
	Next
	
	IncProc("Carregando dados dos Semestres...")
	//Monta o aHeader
	//					Titulo					Campo			Picture								Tamanho					Dec		Valid	Usado	Tipo
	aAdd(aHeadSem,{	"Ano",					"XX_ANO",		"",										04,							0,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadSem,{	"1º Semestre",		"XX_PRI",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadSem,{	"2º Semestre",		"XX_SEG",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	
	//Preenche o aCols
	For nAux := 1 To Len(aDadosAnos)
		aAdd(aColsSem,{	aDadosAnos[nAux][1],;																																				//Ano
							aDadosAnos[nAux][2][01]+aDadosAnos[nAux][2][02]+aDadosAnos[nAux][2][03]+aDadosAnos[nAux][2][04]+aDadosAnos[nAux][2][05]+aDadosAnos[nAux][2][06],;	//1º Semestre
							aDadosAnos[nAux][2][07]+aDadosAnos[nAux][2][08]+aDadosAnos[nAux][2][09]+aDadosAnos[nAux][2][10]+aDadosAnos[nAux][2][11]+aDadosAnos[nAux][2][12],;	//2º Semestre
							.F.})																																									//Excluído?
	Next
	
	IncProc("Carregando dados dos Nonamestres...")
	//Monta o aHeader
	//					Titulo					Campo			Picture								Tamanho					Dec		Valid	Usado	Tipo
	aAdd(aHeadNon,{	"Ano",					"XX_ANO",		"",										04,							0,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadNon,{	"Nonamestre",			"XX_PRI",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	
	//Preenche o aCols
	For nAux := 1 To Len(aDadosAnos)
		aAdd(aColsNon,{	aDadosAnos[nAux][1],;																																																									//Ano
							aDadosAnos[nAux][2][01]+aDadosAnos[nAux][2][02]+aDadosAnos[nAux][2][03]+aDadosAnos[nAux][2][04]+aDadosAnos[nAux][2][05]+aDadosAnos[nAux][2][06]+aDadosAnos[nAux][2][07]+aDadosAnos[nAux][2][08]+aDadosAnos[nAux][2][09],;	//Nonamestre
							.F.})																																																														//Excluído?
	Next
	
	IncProc("Carregando dados dos Anos...")
	//Monta o aHeader
	//					Titulo					Campo			Picture								Tamanho					Dec		Valid	Usado	Tipo
	aAdd(aHeadAno,{	"Ano",					"XX_ANO",		"",										04,							0,		".F.",	".F.",	"N",	"", ""} )
	aAdd(aHeadAno,{	"Valor",				"XX_PRI",		"@E 99,999,999,999,999.99",			18,							2,		".F.",	".F.",	"N",	"", ""} )
	
	//Preenche o aCols
	For nAux := 1 To Len(aDadosAnos)
		aAdd(aColsAno,{	aDadosAnos[nAux][1],;																																																																													//Ano
							aDadosAnos[nAux][2][01]+aDadosAnos[nAux][2][02]+aDadosAnos[nAux][2][03]+aDadosAnos[nAux][2][04]+aDadosAnos[nAux][2][05]+aDadosAnos[nAux][2][06]+aDadosAnos[nAux][2][07]+aDadosAnos[nAux][2][08]+aDadosAnos[nAux][2][09]+aDadosAnos[nAux][2][10]+aDadosAnos[nAux][2][11]+aDadosAnos[nAux][2][12],;	//Valor
							.F.})																																																																																		//Excluído?
	Next
Return

/*---------------------------------------------------------------------*
 | Func:  fCriaGraf                                                    |
 | Autor: Daniel Atilio                                                |
 | Data:  25/11/2015                                                   |
 | Desc:  Função que cria os gráficos                                  |
 *---------------------------------------------------------------------*/

Static Function fCriaGraf()
	//************************************
	// MESES
	//************************************
	//Gráfico na aba Janeiro
	aRand := {}
	oChartJan := FWChartBar():New()
	
	//Inicializa pertencendo a janela
	oChartJan:Init(oPanJan, .T., .T.)
	
	//Seta o título do gráfico
	oChartJan:SetTitle("Mês de Janeiro", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartJan:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChartJan:cPicture := "@E 999,999,999,999,999.99"
	oChartJan:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChartJan:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsMes[1][2], "@E 999,999,999,999,999.99")), aColsMes[1][2])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChartJan:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsMes[2][2], "@E 999,999,999,999,999.99")), aColsMes[2][2])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChartJan:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsMes[3][2], "@E 999,999,999,999,999.99")), aColsMes[3][2])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChartJan:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsMes[4][2], "@E 999,999,999,999,999.99")), aColsMes[4][2])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChartJan:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsMes[5][2], "@E 999,999,999,999,999.99")), aColsMes[5][2])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChartJan:oFWChartColor:aRandom := aRand
	oChartJan:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChartJan:Build()

	//Gráfico na aba Fevereiro
	aRand := {}
	oChartFev := FWChartBar():New()
	
	//Inicializa pertencendo a Fevela
	oChartFev:Init(oPanFev, .T., .T.)
	
	//Seta o título do gráfico
	oChartFev:SetTitle("Mês de Fevereiro", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartFev:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChartFev:cPicture := "@E 999,999,999,999,999.99"
	oChartFev:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChartFev:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsMes[1][3], "@E 999,999,999,999,999.99")), aColsMes[1][3])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChartFev:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsMes[2][3], "@E 999,999,999,999,999.99")), aColsMes[2][3])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChartFev:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsMes[3][3], "@E 999,999,999,999,999.99")), aColsMes[3][3])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChartFev:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsMes[4][3], "@E 999,999,999,999,999.99")), aColsMes[4][3])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChartFev:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsMes[5][3], "@E 999,999,999,999,999.99")), aColsMes[5][3])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChartFev:oFWChartColor:aRandom := aRand
	oChartFev:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChartFev:Build()

	//Gráfico na aba Março
	aRand := {}
	oChartMar := FWChartBar():New()
	
	//Inicializa pertencendo a Marela
	oChartMar:Init(oPanMar, .T., .T.)
	
	//Seta o título do gráfico
	oChartMar:SetTitle("Mês de Março", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartMar:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChartMar:cPicture := "@E 999,999,999,999,999.99"
	oChartMar:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChartMar:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsMes[1][4], "@E 999,999,999,999,999.99")), aColsMes[1][4])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChartMar:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsMes[2][4], "@E 999,999,999,999,999.99")), aColsMes[2][4])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChartMar:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsMes[3][4], "@E 999,999,999,999,999.99")), aColsMes[3][4])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChartMar:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsMes[4][4], "@E 999,999,999,999,999.99")), aColsMes[4][4])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChartMar:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsMes[5][4], "@E 999,999,999,999,999.99")), aColsMes[5][4])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChartMar:oFWChartColor:aRandom := aRand
	oChartMar:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChartMar:Build()
	
		//Gráfico na aba Abril
	aRand := {}
	oChartAbr := FWChartBar():New()
	
	//Inicializa pertencendo a Abrela
	oChartAbr:Init(oPanAbr, .T., .T.)
	
	//Seta o título do gráfico
	oChartAbr:SetTitle("Mês de Abril", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartAbr:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChartAbr:cPicture := "@E 999,999,999,999,999.99"
	oChartAbr:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChartAbr:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsMes[1][5], "@E 999,999,999,999,999.99")), aColsMes[1][5])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChartAbr:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsMes[2][5], "@E 999,999,999,999,999.99")), aColsMes[2][5])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChartAbr:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsMes[3][5], "@E 999,999,999,999,999.99")), aColsMes[3][5])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChartAbr:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsMes[4][5], "@E 999,999,999,999,999.99")), aColsMes[4][5])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChartAbr:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsMes[5][5], "@E 999,999,999,999,999.99")), aColsMes[5][5])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChartAbr:oFWChartColor:aRandom := aRand
	oChartAbr:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChartAbr:Build()

	//Gráfico na aba Maio
	aRand := {}
	oChartMai := FWChartBar():New()
	
	//Inicializa pertencendo a Maiela
	oChartMai:Init(oPanMai, .T., .T.)
	
	//Seta o título do gráfico
	oChartMai:SetTitle("Mês de Maio", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartMai:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChartMai:cPicture := "@E 999,999,999,999,999.99"
	oChartMai:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChartMai:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsMes[1][6], "@E 999,999,999,999,999.99")), aColsMes[1][6])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChartMai:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsMes[2][6], "@E 999,999,999,999,999.99")), aColsMes[2][6])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChartMai:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsMes[3][6], "@E 999,999,999,999,999.99")), aColsMes[3][6])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChartMai:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsMes[4][6], "@E 999,999,999,999,999.99")), aColsMes[4][6])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChartMai:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsMes[5][6], "@E 999,999,999,999,999.99")), aColsMes[5][6])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChartMai:oFWChartColor:aRandom := aRand
	oChartMai:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChartMai:Build()
	
	//Gráfico na aba Junho
	aRand := {}
	oChartJun := FWChartBar():New()
	
	//Inicializa pertencendo a Junela
	oChartJun:Init(oPanJun, .T., .T.)
	
	//Seta o título do gráfico
	oChartJun:SetTitle("Mês de Junho", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartJun:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChartJun:cPicture := "@E 999,999,999,999,999.99"
	oChartJun:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChartJun:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsMes[1][7], "@E 999,999,999,999,999.99")), aColsMes[1][7])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChartJun:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsMes[2][7], "@E 999,999,999,999,999.99")), aColsMes[2][7])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChartJun:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsMes[3][7], "@E 999,999,999,999,999.99")), aColsMes[3][7])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChartJun:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsMes[4][7], "@E 999,999,999,999,999.99")), aColsMes[4][7])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChartJun:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsMes[5][7], "@E 999,999,999,999,999.99")), aColsMes[5][7])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChartJun:oFWChartColor:aRandom := aRand
	oChartJun:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChartJun:Build()
	
	//Gráfico na aba Julho
	aRand := {}
	oChartJul := FWChartBar():New()
	
	//Inicializa pertencendo a Julela
	oChartJul:Init(oPanJul, .T., .T.)
	
	//Seta o título do gráfico
	oChartJul:SetTitle("Mês de Julho", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartJul:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChartJul:cPicture := "@E 999,999,999,999,999.99"
	oChartJul:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChartJul:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsMes[1][8], "@E 999,999,999,999,999.99")), aColsMes[1][8])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChartJul:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsMes[2][8], "@E 999,999,999,999,999.99")), aColsMes[2][8])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChartJul:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsMes[3][8], "@E 999,999,999,999,999.99")), aColsMes[3][8])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChartJul:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsMes[4][8], "@E 999,999,999,999,999.99")), aColsMes[4][8])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChartJul:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsMes[5][8], "@E 999,999,999,999,999.99")), aColsMes[5][8])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChartJul:oFWChartColor:aRandom := aRand
	oChartJul:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChartJul:Build()
	
	//Gráfico na aba Agosto
	aRand := {}
	oChartAgo := FWChartBar():New()
	
	//Inicializa pertencendo a Agoela
	oChartAgo:Init(oPanAgo, .T., .T.)
	
	//Seta o título do gráfico
	oChartAgo:SetTitle("Mês de Agosto", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartAgo:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChartAgo:cPicture := "@E 999,999,999,999,999.99"
	oChartAgo:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChartAgo:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsMes[1][9], "@E 999,999,999,999,999.99")), aColsMes[1][9])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChartAgo:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsMes[2][9], "@E 999,999,999,999,999.99")), aColsMes[2][9])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChartAgo:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsMes[3][9], "@E 999,999,999,999,999.99")), aColsMes[3][9])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChartAgo:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsMes[4][9], "@E 999,999,999,999,999.99")), aColsMes[4][9])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChartAgo:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsMes[5][9], "@E 999,999,999,999,999.99")), aColsMes[5][9])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChartAgo:oFWChartColor:aRandom := aRand
	oChartAgo:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChartAgo:Build()
	
	//Gráfico na aba Setembro
	aRand := {}
	oChartSet := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChartSet:Init(oPanSet, .T., .T.)
	
	//Seta o título do gráfico
	oChartSet:SetTitle("Mês de Setembro", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartSet:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChartSet:cPicture := "@E 999,999,999,999,999.99"
	oChartSet:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChartSet:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsMes[1][10], "@E 999,999,999,999,999.99")), aColsMes[1][10])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChartSet:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsMes[2][10], "@E 999,999,999,999,999.99")), aColsMes[2][10])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChartSet:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsMes[3][10], "@E 999,999,999,999,999.99")), aColsMes[3][10])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChartSet:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsMes[4][10], "@E 999,999,999,999,999.99")), aColsMes[4][10])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChartSet:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsMes[5][10], "@E 999,999,999,999,999.99")), aColsMes[5][10])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChartSet:oFWChartColor:aRandom := aRand
	oChartSet:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChartSet:Build()
	
	//Gráfico na aba Outubro
	aRand := {}
	oChartOut := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChartOut:Init(oPanOut, .T., .T.)
	
	//Seta o título do gráfico
	oChartOut:SetTitle("Mês de Outubro", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartOut:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChartOut:cPicture := "@E 999,999,999,999,999.99"
	oChartOut:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChartOut:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsMes[1][11], "@E 999,999,999,999,999.99")), aColsMes[1][11])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChartOut:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsMes[2][11], "@E 999,999,999,999,999.99")), aColsMes[2][11])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChartOut:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsMes[3][11], "@E 999,999,999,999,999.99")), aColsMes[3][11])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChartOut:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsMes[4][11], "@E 999,999,999,999,999.99")), aColsMes[4][11])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChartOut:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsMes[5][11], "@E 999,999,999,999,999.99")), aColsMes[5][11])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChartOut:oFWChartColor:aRandom := aRand
	oChartOut:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChartOut:Build()
	
	//Gráfico na aba Novembro
	aRand := {}
	oChartNov := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChartNov:Init(oPanNov, .T., .T.)
	
	//Seta o título do gráfico
	oChartNov:SetTitle("Mês de Novembro", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartNov:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChartNov:cPicture := "@E 999,999,999,999,999.99"
	oChartNov:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChartNov:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsMes[1][12], "@E 999,999,999,999,999.99")), aColsMes[1][12])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChartNov:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsMes[2][12], "@E 999,999,999,999,999.99")), aColsMes[2][12])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChartNov:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsMes[3][12], "@E 999,999,999,999,999.99")), aColsMes[3][12])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChartNov:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsMes[4][12], "@E 999,999,999,999,999.99")), aColsMes[4][12])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChartNov:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsMes[5][12], "@E 999,999,999,999,999.99")), aColsMes[5][12])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChartNov:oFWChartColor:aRandom := aRand
	oChartNov:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChartNov:Build()
	
	//Gráfico na aba Dezembro
	aRand := {}
	oChartDez := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChartDez:Init(oPanDez, .T., .T.)
	
	//Seta o título do gráfico
	oChartDez:SetTitle("Mês de Dezembro", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartDez:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChartDez:cPicture := "@E 999,999,999,999,999.99"
	oChartDez:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChartDez:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsMes[1][13], "@E 999,999,999,999,999.99")), aColsMes[1][13])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChartDez:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsMes[2][13], "@E 999,999,999,999,999.99")), aColsMes[2][13])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChartDez:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsMes[3][13], "@E 999,999,999,999,999.99")), aColsMes[3][13])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChartDez:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsMes[4][13], "@E 999,999,999,999,999.99")), aColsMes[4][13])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChartDez:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsMes[5][13], "@E 999,999,999,999,999.99")), aColsMes[5][13])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChartDez:oFWChartColor:aRandom := aRand
	oChartDez:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChartDez:Build()

	//************************************
	// BIMESTRES
	//************************************
	//Gráfico na aba 1º Bimestre
	aRand := {}
	oChart1Bi := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChart1Bi:Init(oPan1Bi, .T., .T.)
	
	//Seta o título do gráfico
	oChart1Bi:SetTitle("1º Bimestre", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart1Bi:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChart1Bi:cPicture := "@E 999,999,999,999,999.99"
	oChart1Bi:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChart1Bi:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsBim[1][2], "@E 999,999,999,999,999.99")), aColsBim[1][2])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChart1Bi:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsBim[2][2], "@E 999,999,999,999,999.99")), aColsBim[2][2])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChart1Bi:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsBim[3][2], "@E 999,999,999,999,999.99")), aColsBim[3][2])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChart1Bi:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsBim[4][2], "@E 999,999,999,999,999.99")), aColsBim[4][2])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChart1Bi:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsBim[5][2], "@E 999,999,999,999,999.99")), aColsBim[5][2])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChart1Bi:oFWChartColor:aRandom := aRand
	oChart1Bi:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChart1Bi:Build()

	//Gráfico na aba 2º Bimestre
	aRand := {}
	oChart2Bi := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChart2Bi:Init(oPan2Bi, .T., .T.)
	
	//Seta o título do gráfico
	oChart2Bi:SetTitle("2º Bimestre", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart2Bi:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChart2Bi:cPicture := "@E 999,999,999,999,999.99"
	oChart2Bi:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChart2Bi:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsBim[1][3], "@E 999,999,999,999,999.99")), aColsBim[1][3])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChart2Bi:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsBim[2][3], "@E 999,999,999,999,999.99")), aColsBim[2][3])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChart2Bi:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsBim[3][3], "@E 999,999,999,999,999.99")), aColsBim[3][3])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChart2Bi:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsBim[4][3], "@E 999,999,999,999,999.99")), aColsBim[4][3])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChart2Bi:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsBim[5][3], "@E 999,999,999,999,999.99")), aColsBim[5][3])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChart2Bi:oFWChartColor:aRandom := aRand
	oChart2Bi:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChart2Bi:Build()
	
	//Gráfico na aba 3º Bimestre
	aRand := {}
	oChart3Bi := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChart3Bi:Init(oPan3Bi, .T., .T.)
	
	//Seta o título do gráfico
	oChart3Bi:SetTitle("3º Bimestre", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart3Bi:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChart3Bi:cPicture := "@E 999,999,999,999,999.99"
	oChart3Bi:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChart3Bi:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsBim[1][4], "@E 999,999,999,999,999.99")), aColsBim[1][4])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChart3Bi:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsBim[2][4], "@E 999,999,999,999,999.99")), aColsBim[2][4])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChart3Bi:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsBim[3][4], "@E 999,999,999,999,999.99")), aColsBim[3][4])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChart3Bi:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsBim[4][4], "@E 999,999,999,999,999.99")), aColsBim[4][4])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChart3Bi:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsBim[5][4], "@E 999,999,999,999,999.99")), aColsBim[5][4])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChart3Bi:oFWChartColor:aRandom := aRand
	oChart3Bi:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChart3Bi:Build()
	
	//Gráfico na aba 4º Bimestre
	aRand := {}
	oChart4Bi := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChart4Bi:Init(oPan4Bi, .T., .T.)
	
	//Seta o título do gráfico
	oChart4Bi:SetTitle("4º Bimestre", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart4Bi:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChart4Bi:cPicture := "@E 999,999,999,999,999.99"
	oChart4Bi:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChart4Bi:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsBim[1][5], "@E 999,999,999,999,999.99")), aColsBim[1][5])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChart4Bi:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsBim[2][5], "@E 999,999,999,999,999.99")), aColsBim[2][5])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChart4Bi:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsBim[3][5], "@E 999,999,999,999,999.99")), aColsBim[3][5])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChart4Bi:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsBim[4][5], "@E 999,999,999,999,999.99")), aColsBim[4][5])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChart4Bi:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsBim[5][5], "@E 999,999,999,999,999.99")), aColsBim[5][5])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChart4Bi:oFWChartColor:aRandom := aRand
	oChart4Bi:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChart4Bi:Build()
	
	//Gráfico na aba 5º Bimestre
	aRand := {}
	oChart5Bi := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChart5Bi:Init(oPan5Bi, .T., .T.)
	
	//Seta o título do gráfico
	oChart5Bi:SetTitle("5º Bimestre", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart5Bi:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChart5Bi:cPicture := "@E 999,999,999,999,999.99"
	oChart5Bi:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChart5Bi:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsBim[1][6], "@E 999,999,999,999,999.99")), aColsBim[1][6])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChart5Bi:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsBim[2][6], "@E 999,999,999,999,999.99")), aColsBim[2][6])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChart5Bi:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsBim[3][6], "@E 999,999,999,999,999.99")), aColsBim[3][6])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChart5Bi:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsBim[4][6], "@E 999,999,999,999,999.99")), aColsBim[4][6])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChart5Bi:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsBim[5][6], "@E 999,999,999,999,999.99")), aColsBim[5][6])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChart5Bi:oFWChartColor:aRandom := aRand
	oChart5Bi:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChart5Bi:Build()
	
	//Gráfico na aba 6º Bimestre
	aRand := {}
	oChart6Bi := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChart6Bi:Init(oPan6Bi, .T., .T.)
	
	//Seta o título do gráfico
	oChart6Bi:SetTitle("6º Bimestre", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart6Bi:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChart6Bi:cPicture := "@E 999,999,999,999,999.99"
	oChart6Bi:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChart6Bi:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsBim[1][7], "@E 999,999,999,999,999.99")), aColsBim[1][7])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChart6Bi:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsBim[2][7], "@E 999,999,999,999,999.99")), aColsBim[2][7])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChart6Bi:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsBim[3][7], "@E 999,999,999,999,999.99")), aColsBim[3][7])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChart6Bi:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsBim[4][7], "@E 999,999,999,999,999.99")), aColsBim[4][7])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChart6Bi:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsBim[5][7], "@E 999,999,999,999,999.99")), aColsBim[5][7])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChart6Bi:oFWChartColor:aRandom := aRand
	oChart6Bi:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChart6Bi:Build()

	//************************************
	// TRIMESTRES
	//************************************
	//Gráfico na aba 1º Trimestre
	aRand := {}
	oChart1Tr := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChart1Tr:Init(oPan1Tr, .T., .T.)
	
	//Seta o título do gráfico
	oChart1Tr:SetTitle("1º Trimestre", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart1Tr:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChart1Tr:cPicture := "@E 999,999,999,999,999.99"
	oChart1Tr:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChart1Tr:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsTri[1][2], "@E 999,999,999,999,999.99")), aColsTri[1][2])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChart1Tr:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsTri[2][2], "@E 999,999,999,999,999.99")), aColsTri[2][2])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChart1Tr:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsTri[3][2], "@E 999,999,999,999,999.99")), aColsTri[3][2])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChart1Tr:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsTri[4][2], "@E 999,999,999,999,999.99")), aColsTri[4][2])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChart1Tr:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsTri[5][2], "@E 999,999,999,999,999.99")), aColsTri[5][2])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChart1Tr:oFWChartColor:aRandom := aRand
	oChart1Tr:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChart1Tr:Build()

	//Gráfico na aba 2º Trimestre
	aRand := {}
	oChart2Tr := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChart2Tr:Init(oPan2Tr, .T., .T.)
	
	//Seta o título do gráfico
	oChart2Tr:SetTitle("2º Trimestre", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart2Tr:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChart2Tr:cPicture := "@E 999,999,999,999,999.99"
	oChart2Tr:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChart2Tr:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsTri[1][3], "@E 999,999,999,999,999.99")), aColsTri[1][3])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChart2Tr:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsTri[2][3], "@E 999,999,999,999,999.99")), aColsTri[2][3])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChart2Tr:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsTri[3][3], "@E 999,999,999,999,999.99")), aColsTri[3][3])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChart2Tr:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsTri[4][3], "@E 999,999,999,999,999.99")), aColsTri[4][3])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChart2Tr:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsTri[5][3], "@E 999,999,999,999,999.99")), aColsTri[5][3])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChart2Tr:oFWChartColor:aRandom := aRand
	oChart2Tr:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChart2Tr:Build()
	
	//Gráfico na aba 3º Trimestre
	aRand := {}
	oChart3Tr := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChart3Tr:Init(oPan3Tr, .T., .T.)
	
	//Seta o título do gráfico
	oChart3Tr:SetTitle("3º Trimestre", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart3Tr:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChart3Tr:cPicture := "@E 999,999,999,999,999.99"
	oChart3Tr:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChart3Tr:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsTri[1][4], "@E 999,999,999,999,999.99")), aColsTri[1][4])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChart3Tr:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsTri[2][4], "@E 999,999,999,999,999.99")), aColsTri[2][4])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChart3Tr:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsTri[3][4], "@E 999,999,999,999,999.99")), aColsTri[3][4])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChart3Tr:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsTri[4][4], "@E 999,999,999,999,999.99")), aColsTri[4][4])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChart3Tr:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsTri[5][4], "@E 999,999,999,999,999.99")), aColsTri[5][4])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChart3Tr:oFWChartColor:aRandom := aRand
	oChart3Tr:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChart3Tr:Build()
	
	//Gráfico na aba 4º Trimestre
	aRand := {}
	oChart4Tr := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChart4Tr:Init(oPan4Tr, .T., .T.)
	
	//Seta o título do gráfico
	oChart4Tr:SetTitle("4º Trimestre", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart4Tr:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChart4Tr:cPicture := "@E 999,999,999,999,999.99"
	oChart4Tr:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChart4Tr:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsTri[1][5], "@E 999,999,999,999,999.99")), aColsTri[1][5])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChart4Tr:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsTri[2][5], "@E 999,999,999,999,999.99")), aColsTri[2][5])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChart4Tr:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsTri[3][5], "@E 999,999,999,999,999.99")), aColsTri[3][5])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChart4Tr:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsTri[4][5], "@E 999,999,999,999,999.99")), aColsTri[4][5])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChart4Tr:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsTri[5][5], "@E 999,999,999,999,999.99")), aColsTri[5][5])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChart4Tr:oFWChartColor:aRandom := aRand
	oChart4Tr:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChart4Tr:Build()

	//************************************
	// SEMESTRES
	//************************************
	//Gráfico na aba 1º Semestre
	aRand := {}
	oChart1Se := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChart1Se:Init(oPan1Se, .T., .T.)
	
	//Seta o título do gráfico
	oChart1Se:SetTitle("1º Semestre", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart1Se:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChart1Se:cPicture := "@E 999,999,999,999,999.99"
	oChart1Se:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChart1Se:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsSem[1][2], "@E 999,999,999,999,999.99")), aColsSem[1][2])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChart1Se:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsSem[2][2], "@E 999,999,999,999,999.99")), aColsSem[2][2])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChart1Se:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsSem[3][2], "@E 999,999,999,999,999.99")), aColsSem[3][2])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChart1Se:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsSem[4][2], "@E 999,999,999,999,999.99")), aColsSem[4][2])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChart1Se:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsSem[5][2], "@E 999,999,999,999,999.99")), aColsSem[5][2])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChart1Se:oFWChartColor:aRandom := aRand
	oChart1Se:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChart1Se:Build()

	//Gráfico na aba 2º Semestre
	aRand := {}
	oChart2Se := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChart2Se:Init(oPan2Se, .T., .T.)
	
	//Seta o título do gráfico
	oChart2Se:SetTitle("2º Semestre", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart2Se:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChart2Se:cPicture := "@E 999,999,999,999,999.99"
	oChart2Se:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChart2Se:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsSem[1][3], "@E 999,999,999,999,999.99")), aColsSem[1][3])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChart2Se:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsSem[2][3], "@E 999,999,999,999,999.99")), aColsSem[2][3])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChart2Se:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsSem[3][3], "@E 999,999,999,999,999.99")), aColsSem[3][3])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChart2Se:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsSem[4][3], "@E 999,999,999,999,999.99")), aColsSem[4][3])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChart2Se:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsSem[5][3], "@E 999,999,999,999,999.99")), aColsSem[5][3])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChart2Se:oFWChartColor:aRandom := aRand
	oChart2Se:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChart2Se:Build()

	//************************************
	// NONAMESTRES
	//************************************
	//Gráfico na aba 1º Nonamestre
	aRand := {}
	oChart1No := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChart1No:Init(oPan1No, .T., .T.)
	
	//Seta o título do gráfico
	oChart1No:SetTitle("1º Nonamestre", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart1No:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChart1No:cPicture := "@E 999,999,999,999,999.99"
	oChart1No:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChart1No:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsNon[1][2], "@E 999,999,999,999,999.99")), aColsNon[1][2])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChart1No:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsNon[2][2], "@E 999,999,999,999,999.99")), aColsNon[2][2])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChart1No:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsNon[3][2], "@E 999,999,999,999,999.99")), aColsNon[3][2])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChart1No:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsNon[4][2], "@E 999,999,999,999,999.99")), aColsNon[4][2])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChart1No:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsNon[5][2], "@E 999,999,999,999,999.99")), aColsNon[5][2])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChart1No:oFWChartColor:aRandom := aRand
	oChart1No:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChart1No:Build()

	//************************************
	// ANUAL
	//************************************
	//Gráfico na aba Anual
	aRand := {}
	oChartAno := FWChartBar():New()
	
	//Inicializa pertencendo a Setela
	oChartAno:Init(oPanAno, .T., .T.)
	
	//Seta o título do gráfico
	oChartAno:SetTitle("Anual", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartAno:setLegend(CONTROL_ALIGN_RIGHT)
	
	//Seta a máscara mostrada na régua e a forma de mostrar o tooltype
	oChartAno:cPicture := "@E 999,999,999,999,999.99"
	oChartAno:cMask := "R$ *@*"
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		oChartAno:addSerie(cValToChar(aAnos[1]) +" - "+ Alltrim(Transform(aColsAno[1][2], "@E 999,999,999,999,999.99")), aColsAno[1][2])
		aAdd(aRand, aRandAno1)
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		oChartAno:addSerie(cValToChar(aAnos[2]) +" - "+ Alltrim(Transform(aColsAno[2][2], "@E 999,999,999,999,999.99")), aColsAno[2][2])
		aAdd(aRand, aRandAno2)
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		oChartAno:addSerie(cValToChar(aAnos[3]) +" - "+ Alltrim(Transform(aColsAno[3][2], "@E 999,999,999,999,999.99")), aColsAno[3][2])
		aAdd(aRand, aRandAno3)
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		oChartAno:addSerie(cValToChar(aAnos[4]) +" - "+ Alltrim(Transform(aColsAno[4][2], "@E 999,999,999,999,999.99")), aColsAno[4][2])
		aAdd(aRand, aRandAno4)
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		oChartAno:addSerie(cValToChar(aAnos[5]) +" - "+ Alltrim(Transform(aColsAno[5][2], "@E 999,999,999,999,999.99")), aColsAno[5][2])
		aAdd(aRand, aRandAno5)
	EndIf
	
	//Seta as cores utilizadas
	oChartAno:oFWChartColor:aRandom := aRand
	oChartAno:oFWChartColor:SetColor("Random")
	
	//Constrói o gráfico
	oChartAno:Build()
	
//****************************************************************
//****************************************************************
//Gráficos de linha
//****************************************************************
//****************************************************************
	
	//************************************
	// MESES
	//************************************
	//Gráfico na aba Janeiro
	aRand := {}
	oChartJan2 := FWChartLine():New()
	
	//Inicializa pertencendo a janela
	oChartJan2:Init(oPanJan2, .T., .T.)
	
	//Seta o título do gráfico
	oChartJan2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartJan2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := (aColsMes[2][2]*100)/(aColsMes[1][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[1][2] > aColsMes[2][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := (aColsMes[3][2]*100)/(aColsMes[2][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[2][2] > aColsMes[3][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := (aColsMes[4][2]*100)/(aColsMes[3][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[3][2] > aColsMes[4][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := (aColsMes[5][2]*100)/(aColsMes[4][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[4][2] > aColsMes[5][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChartJan2:addSerie( "%", aAnosAux)

	//Constrói o gráfico
	oChartJan2:Build()

	//Gráfico na aba Fevereiro
	aRand := {}
	oChartFev2 := FWChartLine():New()
	
	//Inicializa pertencendo a Fevela
	oChartFev2:Init(oPanFev2, .T., .T.)
	
	//Seta o título do gráfico
	oChartFev2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartFev2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsMes[2][3]*100)/(aColsMes[1][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[1][3] > aColsMes[2][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsMes[3][3]*100)/(aColsMes[2][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[2][3] > aColsMes[3][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsMes[4][3]*100)/(aColsMes[3][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[3][3] > aColsMes[4][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsMes[5][3]*100)/(aColsMes[4][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[4][3] > aColsMes[5][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChartFev2:addSerie( "%", aAnosAux)

	//Constrói o gráfico
	oChartFev2:Build()

	//Gráfico na aba Março
	aRand := {}
	oChartMar2 := FWChartLine():New()
	
	//Inicializa pertencendo a Marela
	oChartMar2:Init(oPanMar2, .T., .T.)
	
	//Seta o título do gráfico
	oChartMar2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartMar2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsMes[2][4]*100)/(aColsMes[1][4])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[1][4] > aColsMes[2][4]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsMes[3][4]*100)/(aColsMes[2][4])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[2][4] > aColsMes[3][4]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsMes[4][4]*100)/(aColsMes[3][4])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[3][4] > aColsMes[4][4]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsMes[5][4]*100)/(aColsMes[4][4])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[4][4] > aColsMes[5][4]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChartMar2:addSerie( "%", aAnosAux)

	//Constrói o gráfico
	oChartMar2:Build()
	
	//Gráfico na aba Abril
	aRand := {}
	oChartAbr2 := FWChartLine():New()
	
	//Inicializa pertencendo a Abrela
	oChartAbr2:Init(oPanAbr2, .T., .T.)
	
	//Seta o título do gráfico
	oChartAbr2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartAbr2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsMes[2][5]*100)/(aColsMes[1][5])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[1][5] > aColsMes[2][5]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsMes[3][5]*100)/(aColsMes[2][5])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[2][5] > aColsMes[3][5]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsMes[4][5]*100)/(aColsMes[3][5])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[3][5] > aColsMes[4][5]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsMes[5][5]*100)/(aColsMes[4][5])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[4][5] > aColsMes[5][5]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChartAbr2:addSerie( "%", aAnosAux)

	//Constrói o gráfico
	oChartAbr2:Build()

	//Gráfico na aba Maio
	aRand := {}
	oChartMai2 := FWChartLine():New()
	
	//Inicializa pertencendo a Maiela
	oChartMai2:Init(oPanMai2, .T., .T.)
	
	//Seta o título do gráfico
	oChartMai2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartMai2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsMes[2][6]*100)/(aColsMes[1][6])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[1][6] > aColsMes[2][6]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsMes[3][6]*100)/(aColsMes[2][6])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[2][6] > aColsMes[3][6]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsMes[4][6]*100)/(aColsMes[3][6])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[3][6] > aColsMes[4][6]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsMes[5][6]*100)/(aColsMes[4][6])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[4][6] > aColsMes[5][6]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChartMai2:addSerie( "%", aAnosAux)

	//Constrói o gráfico
	oChartMai2:Build()
	
	//Gráfico na aba Junho
	aRand := {}
	oChartJun2 := FWChartLine():New()
	
	//Inicializa pertencendo a Junela
	oChartJun2:Init(oPanJun2, .T., .T.)
	
	//Seta o título do gráfico
	oChartJun2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartJun2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsMes[2][7]*100)/(aColsMes[1][7])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[1][7] > aColsMes[2][7]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsMes[3][7]*100)/(aColsMes[2][7])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[2][7] > aColsMes[3][7]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsMes[4][7]*100)/(aColsMes[3][7])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[3][7] > aColsMes[4][7]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsMes[5][7]*100)/(aColsMes[4][7])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[4][7] > aColsMes[5][7]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChartJun2:addSerie( "%", aAnosAux)

	//Constrói o gráfico
	oChartJun2:Build()
	
	//Gráfico na aba Julho
	aRand := {}
	oChartJul2 := FWChartLine():New()
	
	//Inicializa pertencendo a Julela
	oChartJul2:Init(oPanJul2, .T., .T.)
	
	//Seta o título do gráfico
	oChartJul2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartJul2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsMes[2][8]*100)/(aColsMes[1][8])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[1][8] > aColsMes[2][8]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsMes[3][8]*100)/(aColsMes[2][8])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[2][8] > aColsMes[3][8]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsMes[4][8]*100)/(aColsMes[3][8])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[3][8] > aColsMes[4][8]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsMes[5][8]*100)/(aColsMes[4][8])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[4][8] > aColsMes[5][8]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChartJul2:addSerie( "%", aAnosAux)

	//Constrói o gráfico
	oChartJul2:Build()
	
	//Gráfico na aba Agosto
	aRand := {}
	oChartAgo2 := FWChartLine():New()
	
	//Inicializa pertencendo a Agoela
	oChartAgo2:Init(oPanAgo2, .T., .T.)
	
	//Seta o título do gráfico
	oChartAgo2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartAgo2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsMes[2][9]*100)/(aColsMes[1][9])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[1][9] > aColsMes[2][9]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsMes[3][9]*100)/(aColsMes[2][9])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[2][9] > aColsMes[3][9]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsMes[4][9]*100)/(aColsMes[3][9])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[3][9] > aColsMes[4][9]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsMes[5][9]*100)/(aColsMes[4][9])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[4][9] > aColsMes[5][9]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChartAgo2:addSerie( "%", aAnosAux)

	//Constrói o gráfico
	oChartAgo2:Build()
	
	//Gráfico na aba Setembro
	aRand := {}
	oChartSet2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChartSet2:Init(oPanSet2, .T., .T.)
	
	//Seta o título do gráfico
	oChartSet2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartSet2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsMes[2][10]*100)/(aColsMes[1][10])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[1][10] > aColsMes[2][10]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsMes[3][10]*100)/(aColsMes[2][10])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[2][10] > aColsMes[3][10]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsMes[4][10]*100)/(aColsMes[3][10])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[3][10] > aColsMes[4][10]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsMes[5][10]*100)/(aColsMes[4][10])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[4][10] > aColsMes[5][10]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChartSet2:addSerie( "%", aAnosAux)

	//Constrói o gráfico
	oChartSet2:Build()
	
	//Gráfico na aba Outubro
	aRand := {}
	oChartOut2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChartOut2:Init(oPanOut2, .T., .T.)
	
	//Seta o título do gráfico
	oChartOut2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartOut2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsMes[2][11]*100)/(aColsMes[1][11])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[1][11] > aColsMes[2][11]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsMes[3][11]*100)/(aColsMes[2][11])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[2][11] > aColsMes[3][11]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsMes[4][11]*100)/(aColsMes[3][11])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[3][11] > aColsMes[4][11]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsMes[5][11]*100)/(aColsMes[4][11])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[4][11] > aColsMes[5][11]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChartOut2:addSerie( "%", aAnosAux)

	//Constrói o gráfico
	oChartOut2:Build()
	
	//Gráfico na aba Novembro
	aRand := {}
	oChartNov2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChartNov2:Init(oPanNov2, .T., .T.)
	
	//Seta o título do gráfico
	oChartNov2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartNov2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsMes[2][12]*100)/(aColsMes[1][12])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[1][12] > aColsMes[2][12]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsMes[3][12]*100)/(aColsMes[2][12])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[2][12] > aColsMes[3][12]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsMes[4][12]*100)/(aColsMes[3][12])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[3][12] > aColsMes[4][12]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsMes[5][12]*100)/(aColsMes[4][12])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[4][12] > aColsMes[5][12]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChartNov2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChartNov2:Build()
	
	//Gráfico na aba Dezembro
	aRand := {}
	oChartDez2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChartDez2:Init(oPanDez2, .T., .T.)
	
	//Seta o título do gráfico
	oChartDez2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartDez2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsMes[2][13]*100)/(aColsMes[1][13])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[1][13] > aColsMes[2][13]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsMes[4][13]*100)/(aColsMes[3][13])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[3][13] > aColsMes[4][13]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsMes[4][13]*100)/(aColsMes[3][13])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[3][13] > aColsMes[4][13]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsMes[5][13]*100)/(aColsMes[4][13])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsMes[4][13] > aColsMes[5][13]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChartDez2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChartDez2:Build()

	//************************************
	// BIMESTRES
	//************************************
	//Gráfico na aba 1º Bimestre
	aRand := {}
	oChart1Bi2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChart1Bi2:Init(oPan1Bi2, .T., .T.)
	
	//Seta o título do gráfico
	oChart1Bi2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart1Bi2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsBim[2][2]*100)/(aColsBim[1][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[1][2] > aColsBim[2][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsBim[3][2]*100)/(aColsBim[2][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[2][2] > aColsBim[3][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsBim[4][2]*100)/(aColsBim[3][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[3][2] > aColsBim[4][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsBim[5][2]*100)/(aColsBim[4][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[4][2] > aColsBim[5][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChart1Bi2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChart1Bi2:Build()

	//Gráfico na aba 2º Bimestre
	aRand := {}
	oChart2Bi2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChart2Bi2:Init(oPan2Bi2, .T., .T.)
	
	//Seta o título do gráfico
	oChart2Bi2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart2Bi2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsBim[2][3]*100)/(aColsBim[1][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[1][3] > aColsBim[2][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsBim[3][3]*100)/(aColsBim[2][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[2][3] > aColsBim[3][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsBim[4][3]*100)/(aColsBim[3][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[3][3] > aColsBim[4][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsBim[5][3]*100)/(aColsBim[4][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[4][3] > aColsBim[5][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChart2Bi2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChart2Bi2:Build()
	
	//Gráfico na aba 3º Bimestre
	aRand := {}
	oChart3Bi2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChart3Bi2:Init(oPan3Bi2, .T., .T.)
	
	//Seta o título do gráfico
	oChart3Bi2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart3Bi2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsBim[2][4]*100)/(aColsBim[1][4])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[1][4] > aColsBim[2][4]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsBim[3][4]*100)/(aColsBim[2][4])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[2][4] > aColsBim[3][4]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsBim[4][4]*100)/(aColsBim[3][4])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[3][4] > aColsBim[4][4]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsBim[5][4]*100)/(aColsBim[4][4])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[4][4] > aColsBim[5][4]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChart3Bi2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChart3Bi2:Build()
	
	//Gráfico na aba 4º Bimestre
	aRand := {}
	oChart4Bi2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChart4Bi2:Init(oPan4Bi2, .T., .T.)
	
	//Seta o título do gráfico
	oChart4Bi2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart4Bi2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsBim[2][5]*100)/(aColsBim[1][5])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[1][5] > aColsBim[2][5]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsBim[3][5]*100)/(aColsBim[2][5])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[2][5] > aColsBim[3][5]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsBim[4][5]*100)/(aColsBim[3][5])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[3][5] > aColsBim[4][5]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsBim[5][5]*100)/(aColsBim[4][5])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[4][5] > aColsBim[5][5]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChart4Bi2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChart4Bi2:Build()
	
	//Gráfico na aba 5º Bimestre
	aRand := {}
	oChart5Bi2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChart5Bi2:Init(oPan5Bi2, .T., .T.)
	
	//Seta o título do gráfico
	oChart5Bi2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart5Bi2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsBim[2][6]*100)/(aColsBim[1][6])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[1][6] > aColsBim[2][6]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsBim[3][6]*100)/(aColsBim[2][6])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[2][6] > aColsBim[3][6]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsBim[4][6]*100)/(aColsBim[3][6])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[3][6] > aColsBim[4][6]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsBim[5][6]*100)/(aColsBim[4][6])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[4][6] > aColsBim[5][6]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChart5Bi2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChart5Bi2:Build()
	
	//Gráfico na aba 6º Bimestre
	aRand := {}
	oChart6Bi2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChart6Bi2:Init(oPan6Bi2, .T., .T.)
	
	//Seta o título do gráfico
	oChart6Bi2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart6Bi2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsBim[2][7]*100)/(aColsBim[1][7])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[1][7] > aColsBim[2][7]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsBim[3][7]*100)/(aColsBim[2][7])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[2][7] > aColsBim[3][7]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsBim[4][7]*100)/(aColsBim[3][7])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[3][7] > aColsBim[4][7]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsBim[5][7]*100)/(aColsBim[4][7])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsBim[4][7] > aColsBim[5][7]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChart6Bi2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChart6Bi2:Build()

	//************************************
	// TRIMESTRES
	//************************************
	//Gráfico na aba 1º Trimestre
	aRand := {}
	oChart1Tr2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChart1Tr2:Init(oPan1Tr2, .T., .T.)
	
	//Seta o título do gráfico
	oChart1Tr2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart1Tr2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsTri[2][2]*100)/(aColsTri[1][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[1][2] > aColsTri[2][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsTri[3][2]*100)/(aColsTri[2][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[2][2] > aColsTri[3][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsTri[4][2]*100)/(aColsTri[3][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[3][2] > aColsTri[4][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsTri[5][2]*100)/(aColsTri[4][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[4][2] > aColsTri[5][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChart1Tr2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChart1Tr2:Build()

	//Gráfico na aba 2º Trimestre
	aRand := {}
	oChart2Tr2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChart2Tr2:Init(oPan2Tr2, .T., .T.)
	
	//Seta o título do gráfico
	oChart2Tr2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart2Tr2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsTri[2][3]*100)/(aColsTri[1][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[1][3] > aColsTri[2][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsTri[3][3]*100)/(aColsTri[2][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[2][3] > aColsTri[3][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsTri[4][3]*100)/(aColsTri[3][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[3][3] > aColsTri[4][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsTri[5][3]*100)/(aColsTri[4][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[4][3] > aColsTri[5][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChart2Tr2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChart2Tr2:Build()
	
	//Gráfico na aba 3º Trimestre
	aRand := {}
	oChart3Tr2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChart3Tr2:Init(oPan3Tr2, .T., .T.)
	
	//Seta o título do gráfico
	oChart3Tr2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart3Tr2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsTri[2][4]*100)/(aColsTri[1][4])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[1][4] > aColsTri[2][4]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsTri[3][4]*100)/(aColsTri[2][4])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[2][4] > aColsTri[3][4]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsTri[4][4]*100)/(aColsTri[3][4])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[3][4] > aColsTri[4][4]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsTri[5][4]*100)/(aColsTri[4][4])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[4][4] > aColsTri[5][4]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChart3Tr2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChart3Tr2:Build()
	
	//Gráfico na aba 4º Trimestre
	aRand := {}
	oChart4Tr2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChart4Tr2:Init(oPan4Tr2, .T., .T.)
	
	//Seta o título do gráfico
	oChart4Tr2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart4Tr2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsTri[2][5]*100)/(aColsTri[1][5])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[1][5] > aColsTri[2][5]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsTri[3][5]*100)/(aColsTri[2][5])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[2][5] > aColsTri[3][5]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsTri[4][5]*100)/(aColsTri[3][5])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[3][5] > aColsTri[4][5]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsTri[5][5]*100)/(aColsTri[4][5])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsTri[4][5] > aColsTri[5][5]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChart4Tr2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChart4Tr2:Build()

	//************************************
	// SEMESTRES
	//************************************
	//Gráfico na aba 1º Semestre
	aRand := {}
	oChart1Se2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChart1Se2:Init(oPan1Se2, .T., .T.)
	
	//Seta o título do gráfico
	oChart1Se2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart1Se2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsSem[2][2]*100)/(aColsSem[1][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsSem[1][2] > aColsSem[2][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsSem[3][2]*100)/(aColsSem[2][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsSem[2][2] > aColsSem[3][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsSem[4][2]*100)/(aColsSem[3][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsSem[3][2] > aColsSem[4][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsSem[5][2]*100)/(aColsSem[4][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsSem[4][2] > aColsSem[5][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChart1Se2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChart1Se2:Build()

	//Gráfico na aba 2º Semestre
	aRand := {}
	oChart2Se2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChart2Se2:Init(oPan2Se2, .T., .T.)
	
	//Seta o título do gráfico
	oChart2Se2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart2Se2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsSem[2][3]*100)/(aColsSem[1][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsSem[1][3] > aColsSem[2][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsSem[3][3]*100)/(aColsSem[2][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsSem[2][3] > aColsSem[3][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsSem[4][3]*100)/(aColsSem[3][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsSem[3][3] > aColsSem[4][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsSem[5][3]*100)/(aColsSem[4][3])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsSem[4][3] > aColsSem[5][3]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChart2Se2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChart2Se2:Build()

	//************************************
	// NONAMESTRES
	//************************************
	//Gráfico na aba 1º Nonamestre
	aRand := {}
	oChart1No2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChart1No2:Init(oPan1No2, .T., .T.)
	
	//Seta o título do gráfico
	oChart1No2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChart1No2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsNon[2][2]*100)/(aColsNon[1][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsNon[1][2] > aColsNon[2][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsNon[3][2]*100)/(aColsNon[2][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsNon[2][2] > aColsNon[3][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsNon[4][2]*100)/(aColsNon[3][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsNon[3][2] > aColsNon[4][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsNon[5][2]*100)/(aColsNon[4][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsNon[4][2] > aColsNon[5][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChart1No2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChart1No2:Build()

	//************************************
	// ANUAL
	//************************************
	//Gráfico na aba Anual
	aRand := {}
	oChartAno2 := FWChartLine():New()
	
	//Inicializa pertencendo a Setela
	oChartAno2:Init(oPanAno2, .T., .T.)
	
	//Seta o título do gráfico
	oChartAno2:SetTitle("% Crescimento em relação ao ano anterior", CONTROL_ALIGN_CENTER)
	
	//Define que a legenda será mostrada na esquerda
	oChartAno2:setLegend(CONTROL_ALIGN_RIGHT)
	
	aAnosAux := {}
	
	//Ano 1, adiciona a série e as cores
	If !Empty(aAnos[1])
		nPercAux := 0
		aAdd(aAnosAux, {cValToChar(aAnos[1]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 2, adiciona a série e as cores
	If !Empty(aAnos[2])
		nPercAux := 0
		nPercAux := (aColsAno[2][2]*100)/(aColsAno[1][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsAno[1][2] > aColsAno[2][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[2]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 3, adiciona a série e as cores
	If !Empty(aAnos[3])
		nPercAux := 0
		nPercAux := (aColsAno[3][2]*100)/(aColsAno[2][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsAno[2][2] > aColsAno[3][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[3]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 4, adiciona a série e as cores
	If !Empty(aAnos[4])
		nPercAux := 0
		nPercAux := (aColsAno[4][2]*100)/(aColsAno[3][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsAno[3][2] > aColsAno[4][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[4]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Ano 5, adiciona a série e as cores
	If !Empty(aAnos[5])
		nPercAux := 0
		nPercAux := (aColsAno[5][2]*100)/(aColsAno[4][2])
		//Tratamento, caso o ano anterior seja maior que o ano atual
		If aColsAno[4][2] > aColsAno[5][2]
			nPercAux := (100 - nPercAux) * -1
		Else
			nPercAux := (nPercAux - 100)
		EndIf
		aAdd(aAnosAux, {cValToChar(aAnos[5]) +" . "+ Alltrim(Transform(nPercAux, "@E 9,999.99%")), nPercAux})
	EndIf
	
	//Seta as cores utilizadas
	oChartAno2:addSerie( "%", aAnosAux)
	
	//Constrói o gráfico
	oChartAno2:Build()
Return

/*---------------------------------------------------------------------*
 | Func:  fImprimir                                                    |
 | Autor: Daniel Atilio                                                |
 | Data:  05/01/2016                                                   |
 | Desc:  Função que mostra a tela para parametrizar a impressão       |
 *---------------------------------------------------------------------*/

Static Function fImprimir()
	Local aArea := GetArea()
	Local oDlgImp
	Local nImpAltu := 300
	Local nImpLarg := 650
	//Variáveis privadas
	Private oCmbTipo, cCmbTipo := "1", aTipos := {"1=Meses", "2=Bimestres", "3=Trimestres", "4=Semestres", "5=Nonamestres", "6=Anual"}
	Private oChkAno1, lChkAno1 := .T.
	Private oChkAno2, lChkAno2 := .T.
	Private oChkAno3, lChkAno3 := .T.
	Private oChkAno4, lChkAno4 := .T.
	Private oChkAno5, lChkAno5 := .T.
	Private oChkOpc01, lChkOpc01 := .T.
	Private oChkOpc02, lChkOpc02 := .T.
	Private oChkOpc03, lChkOpc03 := .T.
	Private oChkOpc04, lChkOpc04 := .T.
	Private oChkOpc05, lChkOpc05 := .T.
	Private oChkOpc06, lChkOpc06 := .T.
	Private oChkOpc07, lChkOpc07 := .T.
	Private oChkOpc08, lChkOpc08 := .T.
	Private oChkOpc09, lChkOpc09 := .T.
	Private oChkOpc10, lChkOpc10 := .T.
	Private oChkOpc11, lChkOpc11 := .T.
	Private oChkOpc12, lChkOpc12 := .T.
	
	//Criando a janela
	DEFINE MSDIALOG oDlgImp TITLE "Imprimir Gráficos" FROM 000, 000  TO nImpAltu, nImpLarg COLORS 0, 16777215 PIXEL
		//Grupo de Tipo
		@ 001, 001 GROUP oGrpTip TO 021, (nImpLarg/2) PROMPT "Tipo: " OF oDlgImp COLOR 0, 16777215 PIXEL
			@ 008, 010 MSCOMBOBOX oCmbTipo VAR cCmbTipo ITEMS aTipos SIZE 095, 013 OF oDlgImp PIXEL
			oCmbTipo:bChange := {|| fAltTipo()}
			
		//Grupo de Dados
		@ 024, 001 GROUP oGrpDad TO (nImpAltu/2)-24, (nImpLarg/2) PROMPT "Dados: " OF oDlgImp COLOR 0, 16777215 PIXEL
			@ 035, 010              CHECKBOX 	oChkOpc01 VAR lChkOpc01 	PROMPT "..."	SIZE (nImpLarg/4)-10, 010 OF oDlgImp COLORS 0, 16777215  	PIXEL
			@ 050, 010              CHECKBOX 	oChkOpc03 VAR lChkOpc03 	PROMPT "..."	SIZE (nImpLarg/4)-10, 010 OF oDlgImp COLORS 0, 16777215  	PIXEL
			@ 065, 010              CHECKBOX 	oChkOpc05 VAR lChkOpc05 	PROMPT "..."	SIZE (nImpLarg/4)-10, 010 OF oDlgImp COLORS 0, 16777215  	PIXEL
			@ 080, 010              CHECKBOX 	oChkOpc07 VAR lChkOpc07 	PROMPT "..."	SIZE (nImpLarg/4)-10, 010 OF oDlgImp COLORS 0, 16777215  	PIXEL
			@ 095, 010              CHECKBOX 	oChkOpc09 VAR lChkOpc09 	PROMPT "..."	SIZE (nImpLarg/4)-10, 010 OF oDlgImp COLORS 0, 16777215  	PIXEL
			@ 110, 010              CHECKBOX 	oChkOpc11 VAR lChkOpc11 	PROMPT "..."	SIZE (nImpLarg/4)-10, 010 OF oDlgImp COLORS 0, 16777215  	PIXEL
			@ 035, (nImpLarg/4)+010 CHECKBOX 	oChkOpc02 VAR lChkOpc02 	PROMPT "..."	SIZE (nImpLarg/4)-10, 010 OF oDlgImp COLORS 0, 16777215  	PIXEL
			@ 050, (nImpLarg/4)+010 CHECKBOX 	oChkOpc04 VAR lChkOpc04 	PROMPT "..."	SIZE (nImpLarg/4)-10, 010 OF oDlgImp COLORS 0, 16777215  	PIXEL
			@ 065, (nImpLarg/4)+010 CHECKBOX 	oChkOpc06 VAR lChkOpc06 	PROMPT "..."	SIZE (nImpLarg/4)-10, 010 OF oDlgImp COLORS 0, 16777215  	PIXEL
			@ 080, (nImpLarg/4)+010 CHECKBOX 	oChkOpc08 VAR lChkOpc08 	PROMPT "..."	SIZE (nImpLarg/4)-10, 010 OF oDlgImp COLORS 0, 16777215  	PIXEL
			@ 095, (nImpLarg/4)+010 CHECKBOX 	oChkOpc10 VAR lChkOpc10 	PROMPT "..."	SIZE (nImpLarg/4)-10, 010 OF oDlgImp COLORS 0, 16777215  	PIXEL
			@ 110, (nImpLarg/4)+010 CHECKBOX 	oChkOpc12 VAR lChkOpc12 	PROMPT "..."	SIZE (nImpLarg/4)-10, 010 OF oDlgImp COLORS 0, 16777215  	PIXEL
		
		//Grupo de Ações
		@ (nImpAltu/2)-21, 001 GROUP oGrpAco TO (nImpAltu/2)-1, (nImpLarg/2) PROMPT "Ações: " OF oDlgImp COLOR 0, 16777215 PIXEL
			@ (nImpAltu/2)-15, (nImpLarg/2-003)-(0042*01) BUTTON "&Confirmar"		SIZE 40, 12 FONT  Action (fConfImp())		PIXEL Of oDlgImp
			@ (nImpAltu/2)-15, (nImpLarg/2-003)-(0042*02) BUTTON "&Cancelar"		SIZE 40, 12 FONT  Action (oDlgImp:End())		PIXEL Of oDlgImp
		
		//Atualiza os check de dados
		fAltTipo()
	//Mostrando a janela
	ACTIVATE MSDIALOG oDlgImp CENTERED
	
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fAltTipo                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  05/01/2016                                                   |
 | Desc:  Função executada ao alterar o tipo de impressão              |
 *---------------------------------------------------------------------*/

Static Function fAltTipo()
	//Se for mensal
	If cCmbTipo == '1'
		//Deixando os checks visíveis
		oChkOpc01:lVisible := .T.
		oChkOpc02:lVisible := .T.
		oChkOpc03:lVisible := .T.
		oChkOpc04:lVisible := .T.
		oChkOpc05:lVisible := .T.
		oChkOpc06:lVisible := .T.
		oChkOpc07:lVisible := .T.
		oChkOpc08:lVisible := .T.
		oChkOpc09:lVisible := .T.
		oChkOpc10:lVisible := .T.
		oChkOpc11:lVisible := .T.
		oChkOpc12:lVisible := .T.
		
		//Deixando tudo checado
		lChkOpc01 := .T.
		lChkOpc02 := .T.
		lChkOpc03 := .T.
		lChkOpc04 := .T.
		lChkOpc05 := .T.
		lChkOpc06 := .T.
		lChkOpc07 := .T.
		lChkOpc08 := .T.
		lChkOpc09 := .T.
		lChkOpc10 := .T.
		lChkOpc11 := .T.
		lChkOpc12 := .T.
		
		//Alterando textos
		oChkOpc01:cCaption := "Janeiro"
		oChkOpc02:cCaption := "Fevereiro"
		oChkOpc03:cCaption := "Março"
		oChkOpc04:cCaption := "Abril"
		oChkOpc05:cCaption := "Maio"
		oChkOpc06:cCaption := "Junho"
		oChkOpc07:cCaption := "Julho"
		oChkOpc08:cCaption := "Agosto"
		oChkOpc09:cCaption := "Setembro"
		oChkOpc10:cCaption := "Outubro"
		oChkOpc11:cCaption := "Novembro"
		oChkOpc12:cCaption := "Dezembro"
		
	//Se for bimestral
	ElseIf cCmbTipo == '2'
		//Deixando os checks visíveis
		oChkOpc01:lVisible := .T.
		oChkOpc02:lVisible := .T.
		oChkOpc03:lVisible := .T.
		oChkOpc04:lVisible := .T.
		oChkOpc05:lVisible := .T.
		oChkOpc06:lVisible := .T.
		oChkOpc07:lVisible := .F.
		oChkOpc08:lVisible := .F.
		oChkOpc09:lVisible := .F.
		oChkOpc10:lVisible := .F.
		oChkOpc11:lVisible := .F.
		oChkOpc12:lVisible := .F.
		
		//Deixando tudo checado
		lChkOpc01 := .T.
		lChkOpc02 := .T.
		lChkOpc03 := .T.
		lChkOpc04 := .T.
		lChkOpc05 := .T.
		lChkOpc06 := .T.
		lChkOpc07 := .F.
		lChkOpc08 := .F.
		lChkOpc09 := .F.
		lChkOpc10 := .F.
		lChkOpc11 := .F.
		lChkOpc12 := .F.
		
		//Alterando textos
		oChkOpc01:cCaption := "1º Bimestre"
		oChkOpc02:cCaption := "2º Bimestre"
		oChkOpc03:cCaption := "3º Bimestre"
		oChkOpc04:cCaption := "4º Bimestre"
		oChkOpc05:cCaption := "5º Bimestre"
		oChkOpc06:cCaption := "6º Bimestre"
		oChkOpc07:cCaption := ""
		oChkOpc08:cCaption := ""
		oChkOpc09:cCaption := ""
		oChkOpc10:cCaption := ""
		oChkOpc11:cCaption := ""
		oChkOpc12:cCaption := ""
		
	//Se for trimestral
	ElseIf cCmbTipo == '3'
		//Deixando os checks visíveis
		oChkOpc01:lVisible := .T.
		oChkOpc02:lVisible := .T.
		oChkOpc03:lVisible := .T.
		oChkOpc04:lVisible := .T.
		oChkOpc05:lVisible := .F.
		oChkOpc06:lVisible := .F.
		oChkOpc07:lVisible := .F.
		oChkOpc08:lVisible := .F.
		oChkOpc09:lVisible := .F.
		oChkOpc10:lVisible := .F.
		oChkOpc11:lVisible := .F.
		oChkOpc12:lVisible := .F.
		
		//Deixando tudo checado
		lChkOpc01 := .T.
		lChkOpc02 := .T.
		lChkOpc03 := .T.
		lChkOpc04 := .T.
		lChkOpc05 := .F.
		lChkOpc06 := .F.
		lChkOpc07 := .F.
		lChkOpc08 := .F.
		lChkOpc09 := .F.
		lChkOpc10 := .F.
		lChkOpc11 := .F.
		lChkOpc12 := .F.
		
		//Alterando textos
		oChkOpc01:cCaption := "1º Trimestre"
		oChkOpc02:cCaption := "2º Trimestre"
		oChkOpc03:cCaption := "3º Trimestre"
		oChkOpc04:cCaption := "4º Trimestre"
		oChkOpc05:cCaption := ""
		oChkOpc06:cCaption := ""
		oChkOpc07:cCaption := ""
		oChkOpc08:cCaption := ""
		oChkOpc09:cCaption := ""
		oChkOpc10:cCaption := ""
		oChkOpc11:cCaption := ""
		oChkOpc12:cCaption := ""
		
	//Se for semestral
	ElseIf cCmbTipo == '4'
		//Deixando os checks visíveis
		oChkOpc01:lVisible := .T.
		oChkOpc02:lVisible := .T.
		oChkOpc03:lVisible := .F.
		oChkOpc04:lVisible := .F.
		oChkOpc05:lVisible := .F.
		oChkOpc06:lVisible := .F.
		oChkOpc07:lVisible := .F.
		oChkOpc08:lVisible := .F.
		oChkOpc09:lVisible := .F.
		oChkOpc10:lVisible := .F.
		oChkOpc11:lVisible := .F.
		oChkOpc12:lVisible := .F.
		
		//Deixando tudo checado
		lChkOpc01 := .T.
		lChkOpc02 := .T.
		lChkOpc03 := .F.
		lChkOpc04 := .F.
		lChkOpc05 := .F.
		lChkOpc06 := .F.
		lChkOpc07 := .F.
		lChkOpc08 := .F.
		lChkOpc09 := .F.
		lChkOpc10 := .F.
		lChkOpc11 := .F.
		lChkOpc12 := .F.
		
		//Alterando textos
		oChkOpc01:cCaption := "1º Semestre"
		oChkOpc02:cCaption := "2º Semestre"
		oChkOpc03:cCaption := ""
		oChkOpc04:cCaption := ""
		oChkOpc05:cCaption := ""
		oChkOpc06:cCaption := ""
		oChkOpc07:cCaption := ""
		oChkOpc08:cCaption := ""
		oChkOpc09:cCaption := ""
		oChkOpc10:cCaption := ""
		oChkOpc11:cCaption := ""
		oChkOpc12:cCaption := ""
		
	//Se for nonamestral
	ElseIf cCmbTipo == '5'
		//Deixando os checks visíveis
		oChkOpc01:lVisible := .T.
		oChkOpc02:lVisible := .F.
		oChkOpc03:lVisible := .F.
		oChkOpc04:lVisible := .F.
		oChkOpc05:lVisible := .F.
		oChkOpc06:lVisible := .F.
		oChkOpc07:lVisible := .F.
		oChkOpc08:lVisible := .F.
		oChkOpc09:lVisible := .F.
		oChkOpc10:lVisible := .F.
		oChkOpc11:lVisible := .F.
		oChkOpc12:lVisible := .F.
		
		//Deixando tudo checado
		lChkOpc01 := .T.
		lChkOpc02 := .F.
		lChkOpc03 := .F.
		lChkOpc04 := .F.
		lChkOpc05 := .F.
		lChkOpc06 := .F.
		lChkOpc07 := .F.
		lChkOpc08 := .F.
		lChkOpc09 := .F.
		lChkOpc10 := .F.
		lChkOpc11 := .F.
		lChkOpc12 := .F.
		
		//Alterando textos
		oChkOpc01:cCaption := "1º Nonamestre"
		oChkOpc02:cCaption := ""
		oChkOpc03:cCaption := ""
		oChkOpc04:cCaption := ""
		oChkOpc05:cCaption := ""
		oChkOpc06:cCaption := ""
		oChkOpc07:cCaption := ""
		oChkOpc08:cCaption := ""
		oChkOpc09:cCaption := ""
		oChkOpc10:cCaption := ""
		oChkOpc11:cCaption := ""
		oChkOpc12:cCaption := ""
		
	//Senão, será anual
	Else
		//Deixando os checks visíveis
		oChkOpc01:lVisible := .T.
		oChkOpc02:lVisible := .F.
		oChkOpc03:lVisible := .F.
		oChkOpc04:lVisible := .F.
		oChkOpc05:lVisible := .F.
		oChkOpc06:lVisible := .F.
		oChkOpc07:lVisible := .F.
		oChkOpc08:lVisible := .F.
		oChkOpc09:lVisible := .F.
		oChkOpc10:lVisible := .F.
		oChkOpc11:lVisible := .F.
		oChkOpc12:lVisible := .F.
		
		//Deixando tudo checado
		lChkOpc01 := .T.
		lChkOpc02 := .F.
		lChkOpc03 := .F.
		lChkOpc04 := .F.
		lChkOpc05 := .F.
		lChkOpc06 := .F.
		lChkOpc07 := .F.
		lChkOpc08 := .F.
		lChkOpc09 := .F.
		lChkOpc10 := .F.
		lChkOpc11 := .F.
		lChkOpc12 := .F.
		
		//Alterando textos
		oChkOpc01:cCaption := "Anual"
		oChkOpc02:cCaption := ""
		oChkOpc03:cCaption := ""
		oChkOpc04:cCaption := ""
		oChkOpc05:cCaption := ""
		oChkOpc06:cCaption := ""
		oChkOpc07:cCaption := ""
		oChkOpc08:cCaption := ""
		oChkOpc09:cCaption := ""
		oChkOpc10:cCaption := ""
		oChkOpc11:cCaption := ""
		oChkOpc12:cCaption := ""
		
		//Caso escolha em branco, força a ser o anual
		cCmbTipo := "6"
		oCmbTipo:Refresh()
	EndIf
Return

/*---------------------------------------------------------------------*
 | Func:  fConfImp                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  26/01/2016                                                   |
 | Desc:  Função que gera a impressão dos dados                        |
 *---------------------------------------------------------------------*/

Static Function fConfImp()
	Local aArea := GetArea()
	Local lAnos := .T.
	Local lOpc  := .T.
	Local aImpr := {}
	Local oPrint
	
	//Pegando se todos os anos não estão checados
	lAnos := lChkAno1
	If !Empty(aAnos[2])
		lAnos := lChkAno1 .Or. lChkAno2
	EndIf
	If !Empty(aAnos[3])
		lAnos := lChkAno1 .Or. lChkAno2 .Or. lChkAno3
	EndIf
	If !Empty(aAnos[4])
		lAnos := lChkAno1 .Or. lChkAno2 .Or. lChkAno3 .Or. lChkAno4
	EndIf
	If !Empty(aAnos[5])
		lAnos := lChkAno1 .Or. lChkAno2 .Or. lChkAno3 .Or. lChkAno4 .Or. lChkAno5
	EndIf
	
	//Se não tiver nenhum ano checado, mostra mensagem
	If !lAnos
		MsgAlert("Nenhum <b>ano</b> está checado para impressão!", "Atenção")
		Return
	EndIf
	
	//Se for mensal
	If cCmbTipo == '1'
		lOpc :=	lChkOpc01 .Or.;
					lChkOpc02 .Or.;
					lChkOpc03 .Or.;
					lChkOpc04 .Or.;
					lChkOpc05 .Or.;
					lChkOpc06 .Or.;
					lChkOpc07 .Or.;
					lChkOpc08 .Or.;
					lChkOpc09 .Or.;
					lChkOpc10 .Or.;
					lChkOpc11 .Or.;
					lChkOpc12
		
	//Se for bimestral
	ElseIf cCmbTipo == '2'
		lOpc :=	lChkOpc01 .Or.;
					lChkOpc02 .Or.;
					lChkOpc03 .Or.;
					lChkOpc04 .Or.;
					lChkOpc05 .Or.;
					lChkOpc06
		
	//Se for trimestral
	ElseIf cCmbTipo == '3'
		lOpc :=	lChkOpc01 .Or.;
					lChkOpc02 .Or.;
					lChkOpc03 .Or.;
					lChkOpc04
		
	//Se for semestral
	ElseIf cCmbTipo == '4'
		lOpc :=	lChkOpc01 .Or.;
					lChkOpc02
		
	//Se for nonamestral
	ElseIf cCmbTipo == '5'
		lOpc :=	lChkOpc01
		
	//Senão, será anual
	Else
		lOpc :=	lChkOpc01
	EndIf
	
	//Se não tiver nenhuma opção checada
	If !lOpc
		MsgAlert("Nenhuma <b>opção</b> está checada para impressão!", "Atenção")
		Return
	EndIf
	
	//Agora guarda em um array os objetos que serão impressos
	aImpr := {}
	
	//Se for mensal
	If cCmbTipo == '1'
		//Janeiro
		If lChkOpc01
			aAdd(aImpr, {"oChartJan", "Arquivo_oChartJan"})
		EndIf
		
		//Fevereiro
		If lChkOpc02
			aAdd(aImpr, {"oChartFev", "Arquivo_oChartFev"})
		EndIf
		
		//Março
		If lChkOpc03
			aAdd(aImpr, {"oChartMar", "Arquivo_oChartMar"})
		EndIf
		
		//Abril
		If lChkOpc04
			aAdd(aImpr, {"oChartAbr", "Arquivo_oChartAbr"})
		EndIf
		
		//Maio
		If lChkOpc05
			aAdd(aImpr, {"oChartMai", "Arquivo_oChartMai"})
		EndIf
		
		//Junho
		If lChkOpc06
			aAdd(aImpr, {"oChartJun", "Arquivo_oChartJun"})
		EndIf
		
		//Julho
		If lChkOpc07
			aAdd(aImpr, {"oChartJul", "Arquivo_oChartJul"})
		EndIf
		
		//Agosto
		If lChkOpc08
			aAdd(aImpr, {"oChartAgo", "Arquivo_oChartAgo"})
		EndIf
		
		//Setembro
		If lChkOpc09
			aAdd(aImpr, {"oChartSet", "Arquivo_oChartSet"})
		EndIf
		
		//Outubro
		If lChkOpc10
			aAdd(aImpr, {"oChartOut", "Arquivo_oChartOut"})
		EndIf
		
		//Novembro
		If lChkOpc11
			aAdd(aImpr, {"oChartNov", "Arquivo_oChartNov"})
		EndIf
		
		//Dezembro
		If lChkOpc12
			aAdd(aImpr, {"oChartDez", "Arquivo_oChartDez"})
		EndIf
		
	//Se for bimestral
	ElseIf cCmbTipo == '2'
		//Se tiver checado o 1º Bimestre
		If lChkOpc01
			aAdd(aImpr, {"oChart1Bi", "Arquivo_oChart1Bi"})
		EndIf
		
		//Se tiver checado o 2º Bimestre
		If lChkOpc02
			aAdd(aImpr, {"oChart2Bi", "Arquivo_oChart2Bi"})
		EndIf
		
		//Se tiver checado o 3º Bimestre
		If lChkOpc03
			aAdd(aImpr, {"oChart3Bi", "Arquivo_oChart3Bi"})
		EndIf
		
		//Se tiver checado o 4º Bimestre
		If lChkOpc04
			aAdd(aImpr, {"oChart4Bi", "Arquivo_oChart4Bi"})
		EndIf
		
		//Se tiver checado o 5º Bimestre
		If lChkOpc05
			aAdd(aImpr, {"oChart5Bi", "Arquivo_oChart5Bi"})
		EndIf
		
		//Se tiver checado o 6º Bimestre
		If lChkOpc06
			aAdd(aImpr, {"oChart6Bi", "Arquivo_oChart6Bi"})
		EndIf
		
	//Se for trimestral
	ElseIf cCmbTipo == '3'
		//Se o primeiro trimestre estiver checado
		If lChkOpc01
			aAdd(aImpr, {"oChart1Tr", "Arquivo_oChart1Tr"})
		EndIf
		
		//Se o segundo trimestre estiver checado
		If lChkOpc02
			aAdd(aImpr, {"oChart2Tr", "Arquivo_oChart2Tr"})
		EndIf
		
		//Se o terceiro trimestre estiver checado
		If lChkOpc03
			aAdd(aImpr, {"oChart3Tr", "Arquivo_oChart3Tr"})
		EndIf
		
		//Se o quarto trimestre estiver checado
		If lChkOpc04
			aAdd(aImpr, {"oChart4Tr", "Arquivo_oChart4Tr"})
		EndIf
		
	//Se for semestral
	ElseIf cCmbTipo == '4'
		//Se o primeiro semestre tiver checado
		If lChkOpc01
			aAdd(aImpr, {"oChart1Se", "Arquivo_oChart1Se"})
		EndIf
		
		//Se o segundo semestre tiver checado
		If lChkOpc02
			aAdd(aImpr, {"oChart2Se", "Arquivo_oChart2Se"})
		EndIf
		
	//Se for nonamestral
	ElseIf cCmbTipo == '5'
		aAdd(aImpr, {"oChart1No", "Arquivo_oChart1No"})
		
	//Senão, será anual
	Else
		aAdd(aImpr, {"oChartAno","Arquivo_oChartAno"})
	EndIf
	
	//Gerando as imagens
	For nAuxImg := 1 To Len(aImpr)
		cObjeto := aImpr[nAuxImg][1]
		cExpressao := ":SaveToPng(001, "
		cExpressao += "001, "
		cExpressao += "oPan"+SubStr(aImpr[nAuxImg][1], Len(aImpr[nAuxImg][1])-2, 3)+":nWidth, "
		cExpressao += "oPan"+SubStr(aImpr[nAuxImg][1], Len(aImpr[nAuxImg][1])-2, 3)+":nHeight, "
		cImagem := "GetTempPath()+'"+aImpr[nAuxImg][2]
		
		&(cObjeto+		cExpressao+cImagem+".png')")
		&(cObjeto+"2"+cExpressao+cImagem+"2.png')")
	Next
	
	//Cria o relatório em modo paisagem
	oPrint	:= TMSPrinter():New("VAFATC01")
	oPrint:Setup()
	oPrint:SetPaperSize(9)
	oPrint:SetLandscape()
	
	nColIniRel	:= 0080
	nColFinRel	:= 3250
	nColMeiRel	:= nColIniRel+((nColFinRel-nColIniRel)/2)
	
	//Imprimindo as imagens
	For nAuxImg := 1 To Len(aImpr)
		oPrint:StartPage()
		
		//Imprimindo gráfico
		nEscala := 2
		nLargura := &("oPan"+SubStr(aImpr[nAuxImg][1], Len(aImpr[nAuxImg][1])-2, 3)+":nWidth")
		nAltura := &("oPan"+SubStr(aImpr[nAuxImg][1], Len(aImpr[nAuxImg][1])-2, 3)+":nHeight")
		oPrint:SayBitmap(300, nColIniRel, GetTempPath()+aImpr[nAuxImg][2]+".png", nLargura*nEscala, nAltura*nEscala)
		
		//Imprimindo crescimento
		nEscala := 2
		nLargura := &("oPan"+SubStr(aImpr[nAuxImg][1], Len(aImpr[nAuxImg][1])-2, 3)+"2:nWidth")
		nAltura := &("oPan"+SubStr(aImpr[nAuxImg][1], Len(aImpr[nAuxImg][1])-2, 3)+"2:nHeight")
		oPrint:SayBitmap(300, nColMeiRel, GetTempPath()+aImpr[nAuxImg][2]+"2.png", nLargura*nEscala, nAltura*nEscala)
		
		oPrint:EndPage()
	Next
	
	oPrint:Preview()
	
	//Excluindo as imagens
	For nAuxImg := 1 To Len(aImpr)
		FErase(GetTempPath()+aImpr[nAuxImg][2])
	Next
	
	RestArea(aArea)
Return