//Bibliotecas 
#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "TbiConn.ch"
#Include "ApWizard.ch"

//Constantes
#Define CLR_VERMELHO  RGB(255,048,048)									//Cor Vermelha
#Define CLR_VERDE     RGB(119,255,083)									//Cor Verde
#Define CLR_BRANCO    RGB(254,254,254)									//Cor Branca
#Define CLR_CINZA     RGB(180,180,180)									//Cor Cinza
#Define CLR_AZUL      RGB(058,074,119)									//Cor Azul
#Define CLR_PRETO     RGB(000,000,000)									//Cor Preto
#Define CLR_HTM_VRM   'ff3030'											//Cor HTML Vermelha
#Define CLR_HTM_VDE   '77ff53'											//Cor HTML Verde
#Define CLR_HTM_BRA   'fefefe'											//Cor HTML Branca
#Define CLR_HTM_CIN   'b4b4b4'											//Cor HTML Cinza
#Define CLR_HTM_AZU   '3a4a77'											//Cor HTML Azul
#Define CLR_HTM_PRE   '000000'											//Cor HTML Preto
#Define STR_PULA      Chr(13)+Chr(10)									//String que identifica a quebra de linha

//Variaveis
Static COL_T1 		:= 001				//Primeira Coluna da tela
Static COL_T2 		:= 123				//Segunda Coluna da tela
Static COL_T3 		:= 245				//Terceira Coluna da tela
Static COL_T4 		:= 367				//Quarta Coluna da tela
Static ESP_CAMPO	:= 038				//Espaçamento do campo para coluna
Static ESP_DESC		:= 062				//Espaçamento de campos descritivos para o campo



//-----------------------------------------------------------------//
	/*/{Protheus.doc} VAFINA03
	Função para geracao de titulos no financeiro
	@author Daniel Atilio // Ajustado por Henrique
	@since  30/07/2014 // Alterado em 28/03/2016
	@version 1.0 
	@example
	u_VAFINA03()
	/*/
//-----------------------------------------------------------------//
User Function VAFINA03(xTpTit, cTTFilial, cContrat, cTTCli, cTTLOja)
	Local aArea 		:= GetArea()
	Local nEsp  		:= 15
	Local oFontNeg 		:= TFont():New("Tahoma")
	Local nPosIni 		:= 1
	Local cTextLbl 		:= "Cliente:"
	Private cTpTitulo	:= Iif(Empty(xTpTit),"P",xTpTit) // identifica as carteiras "P"agar ou "R"eceber
	Private oDlgAnt
	
	Private oTTPrefix,	cTTPrefix	:= ''
	Private oContrat
	Private oTTNum,		cTTNum		:= ''
	Private oTTEmiss,	dTTEmiss	:= dDatabase
	Private oTTParcel,	cTTParcel	:= StrZero(0,TamSX3('E1_PARCELA')[01])
	Private aItensTipo				:= {"Cliente", "Fornecedor"}
	Private oCmbTipo,	cCmbTipo	:= aItensTipo[1]
	Private oTTCli
	Private oTTLoja
	Private aItensGera 				:= {"Recebimento", "Pagamento"}
	Private oCmbGerar,	cCmbGerar	:= aItensGera[1]
	Private oTTVencto,	dTTVencto	:= dDatabase
	Private oTTNatur,	cTTNatur	:= SPACE(10) // Qual sera a origem da natureza?
	Private oTTValor,	nTTValor 	:= 0
	Private oTTHist,	cTTHist		:= Space(TamSX3("E2_HIST")[01])
	Private oTTFilial
	Private oTTCCD,		cTTCCD		:= Space(TamSX3("E2_CCD")[01]) 
	Private oTTItemD,	cTTItemD	:= Space(TamSX3("E2_ITEMD")[01]) 
	Private oTTCLVLD,	cTTCLVLD	:= Space(TamSX3("E2_CLVLDB")[01]) 

	Private aItensPref 				:= {"ICF-Guia ICMS Frete", "ICM-Guia ICMS", "MIN-Minuta", "PRO-Provisorio", "OUT-Outros"}
	Private oCmbPref,	cCmbPref	:= aItensPref[1]
	Private cTpTit					:= Iif(cTTPrefix$"MIN;PRO;","PR","DP")
	
	// MJ : 02.02.2018
	Default cTTFilial	:= SC7->C7_FILIAL 
	Default cContrat	:= SC7->C7_NUM
	Default cTTCli		:= SC7->C7_FORNECE
	Default cTTLOja		:= SC7->C7_LOJA
	
	cTTNum		:= SubStr(cContrat,nPosIni,TamSX3('C7_NUM')[01])
	
	COL_T1 	:= 001				//Primeira Coluna da tela
	COL_T2 	:= 123				//Segunda Coluna da tela
	COL_T3 	:= 245				//Terceira Coluna da tela
	COL_T4 	:= 367				//Quarta Coluna da tela

                                                                 
	//se for fornecedor *** Sera usado a principio apenas para gerar Adiantamentos a Pagar ***
	If cTpTitulo = "P"
		cCmbTipo 	:= aItensTipo[2]
		cTextLbl 	:= "Fornecedor:"
		cCmbGerar 	:= aItensGera[2]
  	Endif
	//deixando a fonte em negrito
	oFontNeg:Bold 	:= .T.

	//se for fornecedor, pega do contas a pagar
	NParcel(cTTFilial, cContrat, cTTCli, cTTLOja ) // atualizar campo Parcela a ser gerada
/*	If cTpTitulo = "P"
		cTTPrefix := "ICM'
		//Pegando a última parcela,conforme o contrato e o prefixo
		cQuery := " SELECT MAX(E2_PARCELA) AS PARCELA "
		cQuery += " FROM " + RetSqlName("SE2") + " "
		cQuery += " WHERE E2_NUM     = '" + cTTNum    + "' "
		cQuery += "   AND E2_TIPO    = 'DP' "
		cQuery += "   AND E2_FORNECE = '" + cTTCli + "' "
		cQuery += "   AND E2_LOJA    = '" + cTTLoja + "' "
		cQuery += "   AND D_E_L_E_T_ = '' "
		// Heitor (19/03/2015) - Retirado filtro por filial e prefixo, adicionado por tipo
		TcQuery cQuery New Alias "PAPARC"
		//se tiver registro  
		If PAPARC->PARCELA >= cTTParcel
			cTTParcel := soma1(PAPARC->PARCELA)
		Endif
		PAPARC->(dbCloseArea())
		
	//Senão, se for cliente, pega do contas a receber
	Else
		cTTPrefix := 'ICM'
		//Pegando a última parcela,conforme o contrato e o prefixo
		cQuery := " SELECT MAX(E1_PARCELA) AS PARCELA "
		cQuery += " FROM " + RetSqlName("SE1") + " "
		cQuery += " WHERE E1_NUM     = '" + cTTNum    + "' "
//		cQuery += "   AND E1_X_CONTR = '" + cContrat  + "' "
		cQuery += "   AND E1_TIPO = 'DP' "
		cQuery += "   AND E1_FORNECE = '" + cTTCli + "' "
		cQuery += "   AND E1_LOJA    = '" + cTTLoja + "' "
		cQuery += "   AND D_E_L_E_T_ = '' "
		// Heitor (19/03/2015) - Retirado filtro por filial e prefixo, adicionado por tipo
		TcQuery cQuery New Alias "RAPARC"
		//se tiver registro  
		If RAPARC->PARCELA >= cTTParcel
			cTTParcel := soma1(RAPARC->PARCELA)
		Endif
		RAPARC->(dbCloseArea())
	EndIf
*/

	//Criando a janela
	DEFINE MSDIALOG oDlgAnt TITLE "Titulos Financeiros" FROM 000, 000  TO 200, 1000 COLORS 0, 16777215 PIXEL
		//Monta a pasta 1 - Contrato
		nLinAux := 6
    		//Prefixo
    		@ nLinAux    , COL_T1            +5        SAY   oSayRAPref PROMPT "Prefixo:"        SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                       	PIXEL
    		@ nLinAux-003, COL_T1+ESP_CAMPO  +5        MSGET oTTPrefix  VAR    cTTPrefix         SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215   										PIXEL
			//Contrato
			@ nLinAux    , COL_T2            +5        SAY   oSayRANum  PROMPT "Núm.Título:"       SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                       	PIXEL
    		@ nLinAux-003, COL_T2+ESP_CAMPO  +5        MSGET oTTNum     VAR    cTTNum              SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215  									PIXEL
    		//Data de Emissão
			@ nLinAux    , COL_T3            +5        SAY   oSayRAEmis PROMPT "Dt.Emissão:"     SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg             				PIXEL
    		@ nLinAux-003, COL_T3+ESP_CAMPO  +5        MSGET oTTEmiss   VAR    dTTEmiss          SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                       					PIXEL
    		//Parcela
			@ nLinAux    , COL_T4            +5        SAY   oSRAParcel PROMPT "Parcela:"        SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg               			PIXEL
    		@ nLinAux-003, COL_T4+ESP_CAMPO  +5        MSGET oTTParcel  VAR    cTTParcel         SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                             			PIXEL
    	nLinAux += nEsp
    		//Tipo Cliente
    		@ nLinAux    , COL_T1            +5        SAY   oSayTipo PROMPT "Tp.Comprador:"   SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL FONT oFontNeg                            	PIXEL
    		@ nLinAux-003, COL_T1+ESP_CAMPO  +5        MSCOMBOBOX oCmbTipo VAR cCmbTipo ITEMS aItensTipo SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                   				PIXEL
    		//Cliente
    		@ nLinAux    , COL_T2            +5        SAY   oSayRACli  PROMPT cTextLbl          SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                  		PIXEL
    		@ nLinAux-003, COL_T2+ESP_CAMPO  +5        MSGET oTTCli     VAR    cTTCli            SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215 F3 'SA2_X'	Valid(NParcel(cTTFilial, cContrat, cTTCli, cTTLOja ))			PIXEL
			//Loja
			@ nLinAux    , COL_T3            +5        SAY   oSayRALoja PROMPT "Loja:"         SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg            				PIXEL
    		@ nLinAux-003, COL_T3+ESP_CAMPO  +5        MSGET oTTLoja    VAR    cTTLoja           SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                           				PIXEL
    		//Gerar
    		@ nLinAux    , COL_T4            +5        SAY   oSayGerar PROMPT "Gerar:"   SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL FONT oFontNeg                    					PIXEL
    		@ nLinAux-003, COL_T4+ESP_CAMPO  +5        MSCOMBOBOX oCmbGerar VAR cCmbGerar ITEMS aItensGera SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215              				PIXEL
    	nLinAux += nEsp
    		//Data de Vencimento
    		@ nLinAux    , COL_T1            +5        SAY   oSayRAVenc PROMPT "Vencimento:"     SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T1+ESP_CAMPO  +5        MSGET oTTVencto  VAR    dTTVencto         SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215   										PIXEL
			//Natureza
			@ nLinAux    , COL_T2            +5        SAY   oSayRANatu PROMPT "Natureza:"       SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                         PIXEL
    		@ nLinAux-003, COL_T2+ESP_CAMPO  +5        MSGET oTTNatur   VAR    cTTNatur          SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215 F3 'SED_X'                             PIXEL
    		//Valor
			@ nLinAux    , COL_T3            +5        SAY   oSayRAValo PROMPT "Valor:"          SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T3+ESP_CAMPO  +5        MSGET oTTValor   VAR    nTTValor          SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215 PICTURE '@E 9,999,999,999,999.99'      PIXEL
    		//Observação
			@ nLinAux    , COL_T4            +5        SAY   oSayRAHist PROMPT "Observação:"     SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T4+ESP_CAMPO  +5        MSGET oTTHist    VAR    cTTHist           SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                                        PIXEL
    	nLinAux += nEsp
    		//Tipo
    		@ nLinAux    , COL_T1            +5        SAY   oSayGerar PROMPT "Tipo:"   		SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL FONT oFontNeg                    			PIXEL
    		@ nLinAux-003, COL_T1+ESP_CAMPO  +5        MSCOMBOBOX oCmbPref VAR cCmbPref  ITEMS aItensPref SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215  Valid(NParcel(cTTFilial, cContrat, cTTCli, cTTLOja ))             PIXEL
    		//Classe valor
			@ nLinAux    , COL_T2            +5        SAY   oSayRAAgen PROMPT "Local:"        	SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T2+ESP_CAMPO  +5        MSGET oTTCLVLD 		VAR    cTTCLVLD     SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215     F3 'CTH'   							PIXEL
    		//Item Contabil
			@ nLinAux    , COL_T3            +5        SAY   oSayRaCont PROMPT "Processo:"     	SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T3+ESP_CAMPO  +5        MSGET oTTItemD   	VAR    cTTItemD     SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215    F3 'CTDX1'	      					PIXEL
    		//C.Custo
			@ nLinAux    , COL_T4            +5        SAY   oSayRaCont PROMPT "C.Custo:"     	SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T4+ESP_CAMPO  +5        MSGET oTTCCD  		VAR    cTTCCD      	SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215    F3 'CTT_X'	       					PIXEL
    		//C.Filial
//			@ nLinAux    , COL_T4            +5        SAY   oSayRaCont PROMPT "Emp/Filial:"     SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg        					PIXEL
//    		@ nLinAux-003, COL_T4+ESP_CAMPO  +5        MSGET oTTFilial   VAR    cTTFilial        SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215  F3 'SM0'  							PIXEL
    	nLinAux += (nEsp*2)
    		@ nLinAux, 430 BUTTON oBtnConf   PROMPT "Confirmar" SIZE 058, 010 OF oDlgAnt ACTION(fGeraTit(cTTFilial, cContrat, cTTCli, cTTLOja ))     PIXEL
    		
    	//desabilitando campos
    	oTTPrefix:lActive	:=.F.
    	oTTNum:lActive		:=.F.
    	oTTEmiss:lActive	:=.F.
    	oTTParcel:lActive	:=.F.
    	oCmbTipo:lActive	:=.F.
//    	oTTCli:lActive		:=.F.
//    	oTTLoja:lActive		:=.F.
    	oCmbGerar:lActive	:=.F.
	ACTIVATE MSDIALOG oDlgAnt CENTERED
	
	RestArea(aArea)
Return


/*---------------------------------------------------------------------*
 | Func:  fGeraTit                                                   |
 |	@author Daniel Atilio // Ajustado por Henrique
 |	@since  30/07/2014 // Alterado em 28/03/2016
 | Desc:  Função que gera a antecipação (pagamento SE2/recebimento SE1)|
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

Static Function fGeraTit(cTTFilial, cContrat, cTTCli, cTTLOja )
	Local cTipo 	:= ""
//	Local cTpTit	:= Iif(cTTPrefix$"MIN;PRO;","PR","DP")
	Local lErro 	:= .F.
	Local aVetor 	:= {}
	Local cMens 	:= ""
	Local nModAnt 	:= nModulo
	Private lMsErroAuto := .F.
	
	cTpTit	:= Iif(cTTPrefix$"MIN;PRO;","PR","DP")

	If !(VALIDCC())
		Return
	Endif	
	
	//se a data de vencimento for menor que a data atual
	If dTTVencto < dDatabase
		lErro := .T.
		cMens += "- Data de vencimento menor que a data atual;<br>"
	EndIf
	
	//se a natureza estiver em branco
	If Empty(cTTNatur)
		lErro := .T.
		cMens += "- Tipo de Negociação em branco;<br>"
	Else
		DbSelectArea('SED')
		SED->(DbSetOrder(1)) //ED_FILIAL+ED_CODIGO
		SED->(DbGoTop())
		//Se não conseguir posicionar
		If !SED->(DbSeek(xFilial('SED')+cTTNatur))
			lErro := .T.
			cMens += "- Natureza Finaceira não encontrada;<br>"
		EndIf
	EndIf
	
	//Se o valor for menor ou igual a zero
	If nTTValor <= 0
		lErro := .T.
		cMens += "- Valor menor ou igual a zero;<br>"
	EndIf
	
	
	//Se houver erros
	If lErro
		MsgStop("Existem algumas divergências:<br>"+cMens,"Atenção")
		Return
	EndIf
	
	//se for fornecedor, o tipo será p de pagamento
	If cTpTitulo == "P"
		cTipo := "P"
		
	//senão, o tipo será R de recebimento
	Else
		cTipo := "R"
	EndIf

	//Se não for confirmada a pergunta
	If !(MsgYesNo("Deseja gerar <b>"+Iif(cTipo=="R","Titulo a Receber","Titulo a Pagar")+"</b> ?","Atenção"))
		Return
	EndIf
	
	//Se for pagamento antecipado
	If cTipo == "P"
		aVetor:= 	{;
			{"E2_FILIAL"		, cTTFilial					,Nil},;
			{"E2_PREFIXO"		, cTTPrefix					,Nil},;
			{"E2_NUM"			, cTTNum					,Nil},;
			{"E2_PARCELA"		, cTTParcel					,Nil},;
			{"E2_TIPO"	 		, cTpTit		      		,Nil},;
			{"E2_NATUREZ"		, cTTNatur		  			,Nil},;
			{"E2_FORNECEDOR"	, cTTCli					,Nil},;
			{"E2_LOJA"	 		, cTTLoja      				,Nil},;
			{"E2_NOMFOR"		, Posicione("SA2",1,xFilial("SA2")+cTTCli+cTTLoja,"A2_NREDUZ")			,Nil},;
			{"E2_EMISSAO"		, dTTEmiss   				,Nil},;
			{"E2_VENCTO"		, dTTVencto 				,Nil},;
			{"E2_VENCREA"  		, DataValida(dTTVencto)		,Nil},;
			{"E2_VALOR"			, nTTValor		        	,Nil},;
			{"E2_ORIGEM"		, "FINA050"		       		,Nil},;
			{"E2_FLUXO"			, "S"                		,Nil},;
			{"E2_LA"			, " "                		,Nil},;
			{"E2_CCD"			, cTTCCD                	,Nil},;
			{"E2_ITEMD"			, cTTItemD                	,Nil},;
			{"E2_CLVLDB"		, cTTCLVLD                	,Nil},;
			{"E2_X_PC"			, cTTNum                	,Nil},;
			{"E2_HIST"			, cTTHist               	,Nil}}

//			{"AUTBANCO"			, cTTBanco              	,Nil},;
//			{"AUTAGENCIA" 		, cTTAgencia            	,Nil},;
//			{"AUTCONTA"			, cTTConta	            	,Nil}}
		
	//Se for recebimento antecipado
	ElseIf cTipo == "R"
		aVetor:= 	{;
			{"E1_FILIAL"		, cTTFilial					,Nil},;
			{"E1_PREFIXO"		, cTTPrefix					,Nil},;
			{"E1_NUM"			, cTTNum					,Nil},;
			{"E1_PARCELA"		, cTTParcel			   		,Nil},;
			{"E1_TIPO"	 		, cTpTit		      		,Nil},;
			{"E1_NATUREZ"		, cTTNatur		  			,Nil},;
			{"E1_CLIENTE"		, cTTCli					,Nil},;
			{"E1_LOJA"	 		, cTTLoja     				,Nil},;
			{"E1_NOMCLI"		, Posicione("SA1",1,xFilial("SA1")+cTTCli+cTTLoja,"A1_NREDUZ")			,Nil},;
			{"E1_EMISSAO"		, dTTEmiss   				,Nil},;
			{"E1_EMIS1"			, dTTEmiss   				,Nil},;
			{"E1_VENCTO"		, dTTVencto 				,Nil},;
			{"E1_VENCREA"  		, DataValida(dTTVencto)		,Nil},;
			{"E1_VLCRUZ"		, nTTValor		        	,Nil},;
			{"E1_VEND1"			, ""     					,Nil},;
			{"E1_VEND2"			, ""                 		,Nil},;
			{"E1_VEND3"			, ""                 		,Nil},;
			{"E1_VEND4"			, ""                 		,Nil},;
			{"E1_VEND5"			, ""                 		,Nil},;
			{"E1_VALOR"			, nTTValor		        	,Nil},;
			{"E1_SALDO"			, nTTValor		        	,Nil},;
			{"E1_COMIS1"		, 0                  		,Nil},;
			{"E1_COMIS2"		, 0                  		,Nil},;
			{"E1_COMIS3"		, 0                  		,Nil},;
			{"E1_COMIS4"		, 0                  		,Nil},;
			{"E1_COMIS5"		, 0                  		,Nil},;
			{"E1_ORIGEM"		, "FINA040"		      		,Nil},;
			{"E1_SERIE"			, ""         				,Nil},;
			{"E1_SITUACA"		, "0"               		,Nil},;
			{"E1_STATUS"		, "A"           	    	,Nil},;
			{"E1_PEDIDO"		, ""                 		,Nil},;
			{"E1_MOEDA"			, 1				     		,Nil},;
			{"E1_FLUXO"			, "S"                		,Nil},;
			{"E1_MULTNAT"		, "2"                		,Nil},;
			{"E1_PROJPMS"		, ""                  		,Nil},;
			{"E1_HIST"			, cTTHist               	,Nil},;
			{"E1_LA"			, " " 	            		,Nil}}
//			{"CBCOAUTO"			, cTTBanco              	,Nil},;
//			{"CAGEAUTO"			, cTTAgencia				,Nil},;
//			{"CCTAAUTO"			, cTTConta              	,Nil},;
	EndIf
	
	//Começando o controle de transação
	nModulo	:= 6 // financeiro   //Henrique Magalhaes - incluido pois, se usando rotina pelo menu SIGAOMS ou SIGACOM, o sigaauto nao era executado
	Begin Transaction
		//Contas a Pagar
		If cTipo == "P"
			MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aVetor, , 3)
		//Contas a Receber                     /
		Else
			MSExecAuto({|x,y| Fina040(x,y)}, aVetor, 3)
		EndIf
		
		//Se houver erros
		If lMsErroAuto
			MostraErro()
			DisarmTransaction()
			
		//Se der tudo certo
		Else
			
			MsgInfo("<b>"+Iif(cTipo=="R","Titulo","Titulo")+"</b> gerado.","Atenção")
			oDlgAnt:End()
			If cTTPrefix = "ICF" // Rotina envio de Email
		      ADTEmail(cTTFilial, cContrat, cTTCli, cTTLOja )
		    Endif
		Endif
		
	End Transaction
	nModulo	:= nModAnt
	
Return


Static Function NParcel(cTTFilial, cContrat, cTTCli, cTTLOja )

	cTTParcel	:= StrZero(0,TamSX3('E1_PARCELA')[01])
	//deixando sempre como 1
	cTTParcel := Soma1(cTTParcel)
	cTTPrefix := Substr(cCmbPref,1,3)
	cTpTit	:= Iif(cTTPrefix$"MIN;PRO;","PR","DP")
	
	//se for fornecedor, pega do contas a pagar
	If cTpTitulo = "P"
	//	cTTPrefix := Substr(cCmbPref,1,3)
		//Pegando a última parcela,conforme o contrato e o prefixo
		cQuery := " SELECT MAX(E2_PARCELA) AS PARCELA "
		cQuery += " FROM " + RetSqlName("SE2") + " "
		cQuery += " WHERE E2_NUM     = '" + cTTNum    + "' "
//		cQuery += "   AND E2_X_CONTR = '" + cContrat  + "' "
		cQuery += "   AND E2_TIPO    = '" + cTpTit    + "' "
		cQuery += "   AND E2_PREFIXO = '" + cTTPrefix + "' "
		cQuery += "   AND E2_FORNECE = '" + cTTCli + "' "
		cQuery += "   AND E2_LOJA    = '" + cTTLoja + "' "
		cQuery += "   AND D_E_L_E_T_ = '' "
		// Heitor (19/03/2015) - Retirado filtro por filial e prefixo, adicionado por tipo
		TcQuery cQuery New Alias "PAPARC"
		//se tiver registro  
		If PAPARC->PARCELA >= cTTParcel
			cTTParcel := soma1(PAPARC->PARCELA)
		Endif
		PAPARC->(dbCloseArea())
		
	//Senão, se for cliente, pega do contas a receber
	Else
	 //	cTTPrefix := Substr(cCmbPref,1,3)
		//Pegando a última parcela,conforme o contrato e o prefixo
		cQuery := " SELECT MAX(E1_PARCELA) AS PARCELA "
		cQuery += " FROM " + RetSqlName("SE1") + " "
		cQuery += " WHERE E1_NUM     = '" + cTTNum    + "' "
//		cQuery += "   AND E1_X_CONTR = '" + cContrat  + "' "
		cQuery += "   AND E1_TIPO    = '" + cTpTit    + "' "
		cQuery += "   AND E1_PREFIXO = '" + cTTPrefix + "' "
		cQuery += "   AND E1_FORNECE = '" + cTTCli    + "' "
		cQuery += "   AND E1_LOJA    = '" + cTTLoja   + "' "
		cQuery += "   AND D_E_L_E_T_ = '' "
		// Heitor (19/03/2015) - Retirado filtro por filial e prefixo, adicionado por tipo
		TcQuery cQuery New Alias "RAPARC"
		//se tiver registro  
		If RAPARC->PARCELA >= cTTParcel
			cTTParcel := soma1(RAPARC->PARCELA)
		Endif
		RAPARC->(dbCloseArea())
	EndIf

Return                              




//---------------------------------------------------------------------------------------------
// Validar CC/Item/Classe na inclusão do Titulo a pagar
//---------------------------------------------------------------------------------------------
Static Function VALIDCC()

Local aArea		:= GetArea()
Local lRet		:= .T.
Local cVldCC	:= ''
Local cNaturCod := SuperGetMv("MV_X_NATCC" ,.T.,"20606") // naturezas que obrigam o uso de CC Debito nos titulos incluidos manualmente no contas a pagar (FINA050)
Local cE2CC		:= cTTCCD 
Local cE2Item	:= cTTItemD
Local cE2CLVL	:= cTTCLVLD 


If Alltrim(cEmpAnt)<>'01' // Efetua Validacao apenas para empresa 01 - fazendas
	RestArea(aArea)
	Return lRet 
Endif



cVldCC	:= Posicione("SED",1,xFilial('SED')+cTTNatur,"ED_X_OCC")
// Verificar como vai ficar a regra de validacao para inclusao (tipo de titulo etc etc)
If  cVldCC=="S" .and. ( Empty(cE2CC) .or. Empty(cE2Item) .or. Empty(cE2CLVL) )
	Aviso('AVISO', 'Itens que nao controlam Estoque, devem ter os campos Centro de Custo / Item Contabil / Classe Valor preenchidos!!! Verifique!!!', {'Ok'})	
	lRet := .F.
Elseif cVldCC<>"S"
	cE2CC 	 := Space(TamSX3('E2_CCD')[1])
	cE2Item  := Space(TamSX3('E2_ITEMD')[1])
	cE2CLVL  := Space(TamSX3('E2_CLVLDB')[1])  
	lRet := .T.
Elseif cVldCC=="S" .and. ( !Empty(cE2CC) .and. !Empty(cE2Item) .and. !Empty(cE2CLVL) )
	lRet := CTBAMARRA(,cE2CC,cE2Item,cE2CLVL,,,)
Endif	

RestArea(aArea)
Return(lRet)                                                                                    


Static Function ADTEmail(cTTFilial, cContrat, cTTCli, cTTLOja )


	//cRADBanca := 'Banco: ' + cFBanco + ' | Agencia: ' + cFAgencia  + ' | Conta: ' + cFConta + ' | ' + cRACheque

	xAssunto:= "Protheus - Geracao de Titulos de Guia de ICMS - Frete (GADO) para Pedido de Compra " + cContrat  + " "
	xAnexo  := ""                                           
	xDe     := "protheus@vistalegre.agr.br"              
	xCopia  := "financeiro@vistaalegre.agr.br"
	xEmail  := ""  // comentar depois
	xaDados := {}


	xHTM := '<HTML><BODY>'
	xHTM += '<hr>'
	xHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
	xHTM += '<b><font face="Verdana" SIZE=3>' + SM0->M0_NOMECOM + '</b></p>'
	xHTM += '<br>'                                                                                            
	xHTM += '<font face="Verdana" SIZE=3>'+Alltrim( SM0->M0_ENDENT )+" - "+Alltrim(SM0->M0_BAIRENT)+" - CEP: "+alltrim(SM0->M0_CEPENT)+" - Fone/Fax ("+Substr(SM0->M0_TEL,4,2)+") "+Substr(SM0->M0_TEL,7,4)+"-"+Substr(SM0->M0_TEL,11,4) + '</p>'
	xHTM += '<hr>'
	xHTM += '<br>'
	xHTM += '<b><font face="Verdana" SIZE=3>Inclusao de titulo de ICMS de Frete - Pedido de Compra:'  + cContrat + ' </b></p>'
	xHTM += '<font face="Verdana" SIZE=3>Data: ' + dtoc(date()) + ' Hora: ' + time() + '</p>'
	xHTM += '<br>'	
	xHTM += '<br>'      
	
	xHTM += '<b><font face="Verdana" SIZE=1>
	xHTM += '<table BORDER=1>'
	xHTM += '<tr BGCOLOR=#191970 >'
	xHTM += '<td Width= 4%><b><font color=#F5F5F5>Filial</b></font></td>'
	xHTM += '<td Width=15%><b><font color=#F5F5F5>Prx\Titulo\Tipo\Parcela</b></font></td>'
	xHTM += '<td Width=08%><b><font color=#F5F5F5>Emissao</b></font></td>'
	xHTM += '<td Width=08%><b><font color=#F5F5F5>Vencimento</b></font></td>'
	xHTM += '<td Width=12%><b><font color=#F5F5F5>Valor Titulo</b></font></td>'
	xHTM += '<td Width=20%><b><font color=#F5F5F5>Fornecedor</b></font></td>'
	//xHTM += '<td Width=11%><b><font color=#F5F5F5>Dados Bancarios Fornecedor</b></font></td>'
	//xHTM += '<td Width=11%><b><font color=#F5F5F5>Dados Banco V@</b></font></td>'
	xHTM += '<td Width=30%><b><font color=#F5F5F5>Observacao</b></font></td>
	xHTM += '</tr>'	
	
	xHTM += '<tr>'
	xHTM += '<td Width=4%>'+cTTFilial+'</td>'
	xHTM += '<td Width=15%>'+cTTPrefix+'\'+cContrat+'\'+'PA'+IIF(!EMPTY(cTTParcel),'\'+cTTParcel,"")+'</td>'
	xHTM += '<td Width=08%>'+SUBSTR(DTOS(dTTEmiss),7,2)+'/'+SUBSTR(DTOS(dTTEmiss),5,2)+'/'+SUBSTR(DTOS(dTTEmiss),1,4)+'</td>'
	xHTM += '<td Width=08%>'+SUBSTR(DTOS(DataValida(dTTVencto)),7,2)+'/'+SUBSTR(DTOS(DataValida(dTTVencto)),5,2)+'/'+SUBSTR(DTOS(DataValida(dTTVencto)),1,4)+'</td>'
	xHTM += '<td Width=12% align=right>'+Transform(nTTValor,"@E 999,999,999.99")+'</td>'
	xHTM += '<td Width=20% align=left>'+cTTCli + "-" + cTTLOja + "  " + ALLTRIM(Posicione("SA2",1,xFilial("SA2")+cTTCli+cTTLOja,"A2_NREDUZ")) + '</td>
	//xHTM += '<td Width=11% align=left>'+cRADBanca+'</td>' 
	//xHTM += '<td Width=11% align=left>Banco: ' + cRABanco + ' | Agencia: ' + cRAAgencia  + ' | Conta: ' + cRAConta + IIF(!EMPTY(cRACheque), '  | Cheque: ' + cRACheque, '')+'</td> 
	xHTM += '<td Width=30% align=left>' + Alltrim(cTTHist) + '</td>' 
	xHTM += '</tr>'	
	xHTM += '</table>'
	xHTM += '<br>
	xHTM += '<br>'
	xHTM += '</BODY></HTML>'



	Processa({|| 	u_EnvMail(xEmail	,;			//_cPara
					xCopia 				,;			//_cCc
					""					,;			//_cBCC
					xAssunto			,;			//_cTitulo
					xaDados				,;			//_aAnexo
					xHTM				,;			//_cMsg
					.T.)},"Enviando e-mail...")		//_lAudit
	
Return

