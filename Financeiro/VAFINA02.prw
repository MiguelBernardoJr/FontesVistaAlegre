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
	/*/{Protheus.doc} VAFINA02
	Função para cadastro de antecipação (pagamento antecipado, recebimento antecipado)
	@author Daniel Atilio // Ajustado por Henrique
	@since  30/07/2014 // Alterado em 28/03/2016
	@version 1.0 
	@example
	u_VAFINA02()
	/*/
//-----------------------------------------------------------------//
User Function VAFINA02(xTpTit, cRAFilial, cContrat, cRACli, cRALOja)
	Local aArea 		:= GetArea()
	Local nEsp  		:= 15
	Local oFontNeg 		:= TFont():New("Tahoma")
	Local nPosIni 		:= 1
	Local cTextLbl 		:= "Cliente:"
	Private cTpTitulo	:= Iif(Empty(xTpTit),"P",xTpTit) // identifica as carteiras "P"agar ou "R"eceber
	Private oDlgAnt
	
	Private oRAPrefix,	cRAPrefix	:= ''
	Private oContrat
	Private oRANum,		cRANum		:= '' 
	Private oRAEmiss,	dRAEmiss	:= dDatabase
	Private oRAParcel,	cRAParcel	:= StrZero(0,TamSX3('E1_PARCELA')[01])
	Private aItensTipo				:= {"Cliente", "Fornecedor"}
	Private oCmbTipo,	cCmbTipo	:= aItensTipo[1]
	Private oRACli		
	Private oRALoja
	Private aItensGera 				:= {"Recebimento", "Pagamento"}
	Private oCmbGerar,	cCmbGerar	:= aItensGera[1]
	Private oRAVencto,	dRAVencto	:= dDatabase
	Private oRANatur,	cRANatur	:= SPACE(10) // Qual sera a origem da natureza?
	Private oRAValor,	nRAValor 	:= 0
	Private oRAHist,	cRAHist		:= Space(TamSX3("E2_HIST")[01])
	Private oRABanco,	cRABanco	:= Space(TamSX3("A6_COD")[01])
	Private oRAAgencia,	cRAAgencia	:= Space(TamSX3("A6_AGENCIA")[01])
	Private oRAConta,	cRAConta	:= Space(TamSX3("A6_NUMCON")[01])
	Private oRACheque,	cRACheque	:= Space(TamSX3("E5_NUMCHEQ")[01])
	Private oRAFilial
	Private cRADBanca				:= ''	
	Private oFBanco,	cFBanco		:= Space(TamSX3("A6_COD")[01])
	Private oFAgencia,	cFAgencia	:= Space(TamSX3("A6_AGENCIA")[01])
	Private oFConta,	cFConta		:= Space(TamSX3("A6_NUMCON")[01])
	
	// MJ : 02.02.2018
	Default cRAFilial	:= SC7->C7_FILIAL 
	Default cContrat	:= SC7->C7_NUM
	Default cRACli		:= SC7->C7_FORNECE
	Default cRALOja		:= SC7->C7_LOJA
	
	cRANum		:= SubStr(cContrat,nPosIni,TamSX3('C7_NUM')[01])
	
	COL_T1 	:= 001				//Primeira Coluna da tela
	COL_T2 	:= 123				//Segunda Coluna da tela
	COL_T3 	:= 245				//Terceira Coluna da tela
	COL_T4 	:= 367				//Quarta Coluna da tela

	//deixando sempre como 1
	cRAParcel := Soma1(cRAParcel)
	
	cFBanco		:= Posicione("SA2",1,xFilial("SA2")+cRACli+cRALoja,"A2_BANCO") 
	cFAgencia 	:= Posicione("SA2",1,xFilial("SA2")+cRACli+cRALoja,"A2_AGENCIA")  
	cFConta		:= Posicione("SA2",1,xFilial("SA2")+cRACli+cRALoja,"A2_NUMCON")
	If Empty(cFBanco)	
		cFBanco		:= Space(TamSX3("A6_COD")[01])
		cFAgencia	:= Space(TamSX3("A6_AGENCIA")[01])
		cFConta		:= Space(TamSX3("A6_NUMCON")[01])
	Endif


	//se for fornecedor *** Sera usado a principio apenas para gerar Adiantamentos a Pagar ***
	If cTpTitulo = "P"
		cCmbTipo 	:= aItensTipo[2]
		cTextLbl 	:= "Fornecedor:"
		cCmbGerar 	:= aItensGera[2]            
  	Endif
	//deixando a fonte em negrito
	oFontNeg:Bold 	:= .T.

	//se for fornecedor, pega do contas a pagar
	If cTpTitulo = "P"
		cRAPrefix := 'ADT'
		//Pegando a última parcela,conforme o contrato e o prefixo
		cQuery := " SELECT MAX(E2_PARCELA) AS PARCELA "
		cQuery += " FROM " + RetSqlName("SE2") + " "
		cQuery += " WHERE E2_NUM     = '" + cRANum    + "' "
//		cQuery += "   AND E2_X_CONTR = '" + cContrat  + "' "
		cQuery += "   AND E2_TIPO    = 'PA' "
		cQuery += "   AND E2_FORNECE = '" + cRACli + "' "
		cQuery += "   AND E2_LOJA    = '" + cRALoja + "' "
		cQuery += "   AND D_E_L_E_T_ = '' "
		// Heitor (19/03/2015) - Retirado filtro por filial e prefixo, adicionado por tipo
		TcQuery cQuery New Alias "PAPARC"
		//se tiver registro  
		If PAPARC->PARCELA >= cRAParcel
			cRAParcel := soma1(PAPARC->PARCELA)
		Endif
		PAPARC->(dbCloseArea())
		
	//Senão, se for cliente, pega do contas a receber
	Else
		cRAPrefix := 'RA'
		//Pegando a última parcela,conforme o contrato e o prefixo
		cQuery := " SELECT MAX(E1_PARCELA) AS PARCELA "
		cQuery += " FROM " + RetSqlName("SE1") + " "
		cQuery += " WHERE E1_NUM     = '" + cRANum    + "' "
//		cQuery += "   AND E1_X_CONTR = '" + cContrat  + "' "
		cQuery += "   AND E1_TIPO = 'RA' "
		cQuery += "   AND E1_FORNECE = '" + cRACli + "' "
		cQuery += "   AND E1_LOJA    = '" + cRALoja + "' "
		cQuery += "   AND D_E_L_E_T_ = '' "
		// Heitor (19/03/2015) - Retirado filtro por filial e prefixo, adicionado por tipo
		TcQuery cQuery New Alias "RAPARC"
		//se tiver registro  
		If RAPARC->PARCELA >= cRAParcel
			cRAParcel := soma1(RAPARC->PARCELA)
		Endif
		RAPARC->(dbCloseArea())
	EndIf

	//Criando a janela
	DEFINE MSDIALOG oDlgAnt TITLE "Antecipações" FROM 000, 000  TO 200, 1000 COLORS 0, 16777215 PIXEL
		//Monta a pasta 1 - Contrato
		nLinAux := 6
    		//Prefixo
    		@ nLinAux    , COL_T1            +5        SAY   oSayRAPref PROMPT "Prefixo:"        SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                       	PIXEL
    		@ nLinAux-003, COL_T1+ESP_CAMPO  +5        MSGET oRAPrefix  VAR    cRAPrefix         SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215   										PIXEL
			//Contrato
			@ nLinAux    , COL_T2            +5        SAY   oSayRANum  PROMPT "Núm.Título:"       SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                       	PIXEL
    		@ nLinAux-003, COL_T2+ESP_CAMPO  +5        MSGET oRANum     VAR    cRANum              SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215  									PIXEL
    		//Data de Emissão
			@ nLinAux    , COL_T3            +5        SAY   oSayRAEmis PROMPT "Dt.Emissão:"     SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg             				PIXEL
    		@ nLinAux-003, COL_T3+ESP_CAMPO  +5        MSGET oRAEmiss   VAR    dRAEmiss          SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                       					PIXEL
    		//Parcela
			@ nLinAux    , COL_T4            +5        SAY   oSRAParcel PROMPT "Parcela:"        SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg               			PIXEL
    		@ nLinAux-003, COL_T4+ESP_CAMPO  +5        MSGET oRAParcel  VAR    cRAParcel         SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                             			PIXEL
    	nLinAux += nEsp
    		//Tipo Cliente
    		@ nLinAux    , COL_T1            +5        SAY   oSayTipo PROMPT "Tp.Comprador:"   SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL FONT oFontNeg                            	PIXEL
    		@ nLinAux-003, COL_T1+ESP_CAMPO  +5        MSCOMBOBOX oCmbTipo VAR cCmbTipo ITEMS aItensTipo SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                   				PIXEL
    		//Cliente
    		@ nLinAux    , COL_T2            +5        SAY   oSayRACli  PROMPT cTextLbl          SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                  		PIXEL
    		@ nLinAux-003, COL_T2+ESP_CAMPO  +5        MSGET oRACli     VAR    cRACli            SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215   										PIXEL
			//Loja
			@ nLinAux    , COL_T3            +5        SAY   oSayRALoja PROMPT "Filial:"         SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg            				PIXEL
    		@ nLinAux-003, COL_T3+ESP_CAMPO  +5        MSGET oRALoja    VAR    cRALoja           SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                           				PIXEL
    		//Gerar
    		@ nLinAux    , COL_T4            +5        SAY   oSayGerar PROMPT "Gerar:"   SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL FONT oFontNeg                    					PIXEL
    		@ nLinAux-003, COL_T4+ESP_CAMPO  +5        MSCOMBOBOX oCmbGerar VAR cCmbGerar ITEMS aItensGera SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215              				PIXEL
    	nLinAux += nEsp
    		//Data de Vencimento
    		@ nLinAux    , COL_T1            +5        SAY   oSayRAVenc PROMPT "Vencimento:"     SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T1+ESP_CAMPO  +5        MSGET oRAVencto  VAR    dRAVencto         SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215   										PIXEL
			//Natureza
			@ nLinAux    , COL_T2            +5        SAY   oSayRANatu PROMPT "Natureza:"       SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                         PIXEL
    		@ nLinAux-003, COL_T2+ESP_CAMPO  +5        MSGET oRANatur   VAR    cRANatur          SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215 F3 'SED_X'                             PIXEL
    		//Valor
			@ nLinAux    , COL_T3            +5        SAY   oSayRAValo PROMPT "Valor:"          SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T3+ESP_CAMPO  +5        MSGET oRAValor   VAR    nRAValor          SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215 PICTURE '@E 9,999,999,999,999.99'      PIXEL
    		//Observação
			@ nLinAux    , COL_T4            +5        SAY   oSayRAHist PROMPT "Observação:"     SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T4+ESP_CAMPO  +5        MSGET oRAHist    VAR    cRAHist           SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                                        PIXEL
    	nLinAux += nEsp
    		//Banco
			@ nLinAux    , COL_T1            +5        SAY   oSayRABanc PROMPT "Banco:"          SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T1+ESP_CAMPO  +5        MSGET oRABanco   VAR    cRABanco          SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215 F3 'SA6'                               PIXEL
    		//Agencia
			@ nLinAux    , COL_T2            +5        SAY   oSayRAAgen PROMPT "Agencia:"        SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T2+ESP_CAMPO  +5        MSGET oRAAgencia VAR    cRAAgencia        SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                                        PIXEL
    		//Conta
			@ nLinAux    , COL_T3            +5        SAY   oSayRaCont PROMPT "Conta:"          SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T3+ESP_CAMPO  +5        MSGET oRAConta   VAR    cRAConta          SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                                        PIXEL
    		//Filial
			@ nLinAux    , COL_T4            +5        SAY   oSayRACheque PROMPT "Num.Cheque:"         SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T4+ESP_CAMPO  +5        MSGET oRACheque   VAR    cRACheque          		SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                               			PIXEL
// Tratamento para Conta a Depositar o PA

    	nLinAux += nEsp
    		//Banco
			@ nLinAux    , COL_T1            +5        SAY   oSayFBanc PROMPT "For.Banco:"         	SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T1+ESP_CAMPO  +5        MSGET oFBanco   VAR    cFBanco          		SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                               			PIXEL
    		//Agencia
			@ nLinAux    , COL_T2            +5        SAY   oSayFAgen PROMPT "For.Agencia:"        	SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T2+ESP_CAMPO  +5        MSGET oFAgencia VAR    cFAgencia        		SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                                        PIXEL
    		//Conta
			@ nLinAux    , COL_T3            +5        SAY   oSayFCont PROMPT "For.Conta:"          	SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg                          PIXEL
    		@ nLinAux-003, COL_T3+ESP_CAMPO  +5        MSGET oFConta   VAR    cFConta          		SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215                                        PIXEL

    	nLinAux += nEsp
//    	nLinAux += (nEsp*2)
			@ nLinAux    , COL_T1            +5        SAY   oSayRaCont PROMPT "Emp/Filial:"          SIZE 040, 007 OF oDlgAnt COLORS CLR_AZUL    FONT oFontNeg        				PIXEL
    		@ nLinAux-003, COL_T1+ESP_CAMPO  +5        MSGET oRAFilial   VAR    cRAFilial          SIZE 060, 010 OF oDlgAnt COLORS 0, 16777215  F3 'SM0'  							PIXEL

    		@ nLinAux, 430 BUTTON oBtnConf   PROMPT "Confirmar" SIZE 058, 010 OF oDlgAnt ACTION(fGeraAntec(cRAFilial, cRACli, cRALOja ))     PIXEL

    		
    	//desabilitando campos
    	oRAPrefix:lActive	:=.F.
    	oRANum:lActive		:=.F.
    	oRAEmiss:lActive	:=.F.
    	oRAParcel:lActive	:=.F.
    	oCmbTipo:lActive	:=.F.
    	oRACli:lActive		:=.F.
    	oRALoja:lActive		:=.F.
    	oCmbGerar:lActive	:=.F.
	ACTIVATE MSDIALOG oDlgAnt CENTERED
	
	RestArea(aArea)
Return


/*---------------------------------------------------------------------*
 | Func:  fGeraAntec                                                   |
 |	@author Daniel Atilio // Ajustado por Henrique
 |	@since  30/07/2014 // Alterado em 28/03/2016
 | Desc:  Função que gera a antecipação (pagamento SE2/recebimento SE1)|
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

Static Function fGeraAntec(cRAFilial, cRACli, cRALOja)
	Local cTipo := ""
	Local lErro := .F.
	Local aVetor := {}
	Local cMens := ""
	Local nModAnt := nModulo
	Private lMsErroAuto := .F.
	
	//se a data de vencimento for menor que a data atual
	If dRAVencto < dDatabase
		lErro := .T.
		cMens += "- Data de vencimento menor que a data atual;<br>"
	EndIf
	
	//se a natureza estiver em branco
	If Empty(cRANatur)
		lErro := .T.
		cMens += "- Tipo de Negociação em branco;<br>"
	Else
		DbSelectArea('SED')
		SED->(DbSetOrder(1)) //ED_FILIAL+ED_CODIGO
		SED->(DbGoTop())
		//Se não conseguir posicionar
		If !SED->(DbSeek(xFilial('SED')+cRANatur))
			lErro := .T.
			cMens += "- Natureza Finaceira não encontrada;<br>"
		EndIf
	EndIf
	
	//Se o valor for menor ou igual a zero
	If nRAValor <= 0
		lErro := .T.
		cMens += "- Valor menor ou igual a zero;<br>"
	EndIf
	
	//se o banco agência ou conta estiverem em branco
	If Empty(cRABanco) .Or. Empty(cRAAgencia) .Or. Empty(cRAConta)
		lErro := .T.
		cMens += "- Banco, Agência ou Conta estão em branco;<br>"
	Else
		DbSelectArea('SA6')
		SA6->(DbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
		SA6->(DbGoTop())
		//Se não conseguir posicionar
		If !SA6->(DbSeek(xFilial('SA6')+cRABanco+cRAAgencia+cRAConta))
			lErro := .T.
			cMens += "- Banco + Agência + Conta não encontrada;<br>"
		EndIf
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
	If !(MsgYesNo("Deseja gerar <b>"+Iif(cTipo=="R","Recebimento","Pagamento")+"</b> antecipado?","Atenção"))
		Return
	EndIf
	
	//Se for pagamento antecipado
	If cTipo == "P"
	
		Pergunte("FIN050",.T.)

		Posicione("SA2",1,xFilial("SA2")+cRACli+cRALoja,"A2_NREDUZ")
		If	!Empty(cRACheque)
			aVetor:= 	{;
			{"E2_FILIAL"		, cRAFilial					,Nil},;
			{"E2_PREFIXO"		, cRAPrefix					,Nil},;
			{"E2_NUM"			, cRANum					,Nil},;
			{"E2_PARCELA"		, cRAParcel					,Nil},;
			{"E2_TIPO"	 		, "PA"			      		,Nil},;
			{"E2_NATUREZ"		, cRANatur		  			,Nil},;
			{"E2_FORNECEDOR"	, SA2->A2_COD				,Nil},;
			{"E2_LOJA"	 		, SA2->A2_LOJA      		,Nil},;
			{"E2_NOMFOR"		, SubS(SA2->A2_NREDUZ,1,TamSX3('E2_NOMFOR')[1]),Nil},;
			{"E2_EMISSAO"		, dRAEmiss   				,Nil},;
			{"E2_VENCTO"		, dRAVencto 				,Nil},;
			{"E2_VENCREA"  		, DataValida(dRAVencto)		,Nil},;
			{"E2_VALOR"			, nRAValor		        	,Nil},;
			{"E2_ORIGEM"		, "FINA050"		       		,Nil},;
			{"E2_FLUXO"			, "S"                		,Nil},;
			{"E2_LA"			, " "                		,Nil},;
			{"E2_X_PC"			, cRANum                	,Nil},;
			{"E2_HIST"			, cRAHist               	,Nil},;
			{"E2_X_BANCO"		, cFBanco              		,Nil},;
			{"E2_X_AGENC" 		, cFAgencia            		,Nil},;
			{"E2_X_CONTA"		, cFConta	            	,Nil},;
			{"AUTBANCO"			, cRABanco              	,Nil},;
			{"AUTAGENCIA" 		, cRAAgencia            	,Nil},;
			{"AUTCONTA"			, cRAConta	            	,Nil},;
			{"AUTCHEQUE"		, cRACheque              	,Nil}}
			
		Else

			aVetor:= 	{;
			{"E2_FILIAL"		, cRAFilial					,Nil},;
			{"E2_PREFIXO"		, cRAPrefix					,Nil},;
			{"E2_NUM"			, cRANum					,Nil},;
			{"E2_PARCELA"		, cRAParcel					,Nil},;
			{"E2_TIPO"	 		, "PA"			      		,Nil},;
			{"E2_NATUREZ"		, cRANatur		  			,Nil},;
			{"E2_FORNECEDOR"	, SA2->A2_COD			    ,Nil},;
			{"E2_NOMFOR"		, SubS(SA2->A2_NREDUZ,1,TamSX3('E2_NOMFOR')[1]),Nil},;
			{"E2_EMISSAO"		, dRAEmiss   				,Nil},;
			{"E2_VENCTO"		, dRAVencto 				,Nil},;
			{"E2_VENCREA"  		, DataValida(dRAVencto)		,Nil},;
			{"E2_VALOR"			, nRAValor		        	,Nil},;
			{"E2_ORIGEM"		, "FINA050"		       		,Nil},;
			{"E2_FLUXO"			, "S"                		,Nil},;
			{"E2_LA"			, " "                		,Nil},;
			{"E2_X_PC"			, cRANum                	,Nil},;
			{"E2_HIST"			, cRAHist               	,Nil},;
			{"E2_X_BANCO"		, cFBanco              		,Nil},;
			{"E2_X_AGENC" 		, cFAgencia            		,Nil},;
			{"E2_X_CONTA"		, cFConta	            	,Nil},;
			{"AUTBANCO"			, cRABanco              	,Nil},;
			{"AUTAGENCIA" 		, cRAAgencia            	,Nil},;
			{"AUTCONTA"			, cRAConta	            	,Nil}}
		
		Endif

	//Se for recebimento antecipado
	ElseIf cTipo == "R"
		aVetor:= 	{;
			{"E1_FILIAL"		, cRAFilial					,Nil},;
			{"E1_PREFIXO"		, cRAPrefix					,Nil},;
			{"E1_NUM"			, cRANum					,Nil},;
			{"E1_PARCELA"		, cRAParcel			   		,Nil},;
			{"E1_TIPO"	 		, "RA"			      		,Nil},;
			{"E1_NATUREZ"		, cRANatur		  			,Nil},;
			{"E1_CLIENTE"		, cRACli					,Nil},;
			{"E1_LOJA"	 		, cRALoja     				,Nil},;
			{"E1_NOMCLI"		, Posicione("SA1",1,xFilial("SA1")+cRACli+cRALoja,"A1_NREDUZ")			,Nil},;
			{"E1_EMISSAO"		, dRAEmiss   				,Nil},;
			{"E1_EMIS1"			, dRAEmiss   				,Nil},;
			{"E1_VENCTO"		, dRAVencto 				,Nil},;
			{"E1_VENCREA"  		, DataValida(dRAVencto)		,Nil},;
			{"E1_VLCRUZ"		, nRAValor		        	,Nil},;
			{"E1_VEND1"			, ""     					,Nil},;
			{"E1_VEND2"			, ""                 		,Nil},;
			{"E1_VEND3"			, ""                 		,Nil},;
			{"E1_VEND4"			, ""                 		,Nil},;
			{"E1_VEND5"			, ""                 		,Nil},;
			{"E1_VALOR"			, nRAValor		        	,Nil},;
			{"E1_SALDO"			, nRAValor		        	,Nil},;
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
			{"E1_HIST"			, cRAHist               	,Nil},;
			{"CBCOAUTO"			, cRABanco              	,Nil},;
			{"CAGEAUTO"			, cRAAgencia				,Nil},;
			{"CCTAAUTO"			, cRAConta              	,Nil},;
			{"E1_LA"			, " " 	            		,Nil}}
	EndIf
	
	//Começando o controle de transação
	nModulo	:= 6 // financeiro   //Henrique Magalhaes - incluido pois, se usando rotina pelo menu SIGAOMS ou SIGACOM, o sigaauto nao era executado
	Begin Transaction
		
		//Contas a Pagar
		If cTipo == "P"
			MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aVetor, , 3)
		//Contas a Receber
		Else
			MSExecAuto({|x,y| Fina040(x,y)}, aVetor, 3)
		EndIf
		
		//Se houver erros
		If lMsErroAuto
			MostraErro()
			DisarmTransaction()
			
		//Se der tudo certo
		Else
			MsgInfo("<b>"+Iif(cTipo=="R","Recebimento","Pagamento")+"</b> gerado.","Atenção")
			// enviar email
			ADTEmail(cRAFilial, cRACli, cRALOja)
			oDlgAnt:End()

		Endif
	End Transaction
	nModulo	:= nModAnt

	RestArea(aArea)
Return
                                 

Static Function ADTEmail(cRAFilial, cRACli, cRALOja)

	cRADBanca := 'Banco: ' + cFBanco + ' | Agencia: ' + cFAgencia  + ' | Conta: ' + cFConta + ' | ' + cRACheque

	xAssunto:= "Protheus Workflow - Geracao de Adiantamento para Pedido de Compra " + cRANum  + " "
	xAnexo  := ""                                           
	xDe     := "protheus@vistalegre.agr.br"              
	xCopia  := "financeiro@vistaalegre.agr.br"
	xEmail  := "arthur.toshio@vistaalegre.agr.br"  // comentar depois
	xaDados := {}

	xHTM := '<HTML><BODY>'
	xHTM += '<hr>'
	xHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
	xHTM += '<b><font face="Verdana" SIZE=3>' + SM0->M0_NOMECOM + '</b></p>'
	xHTM += '<br>'                                                                                            
	xHTM += '<font face="Verdana" SIZE=3>'+Alltrim( SM0->M0_ENDENT )+" - "+Alltrim(SM0->M0_BAIRENT)+" - CEP: "+alltrim(SM0->M0_CEPENT)+" - Fone/Fax ("+Substr(SM0->M0_TEL,4,2)+") "+Substr(SM0->M0_TEL,7,4)+"-"+Substr(SM0->M0_TEL,11,4) + '</p>'
	xHTM += '<hr>'
	xHTM += '<b><font face="Verdana" SIZE=3>Inclusao de titulo de Adiantamento - Pedido de Compra:'  + cRANum + ' </b></p>'
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
	xHTM += '<td Width=12%><b><font color=#F5F5F5>Valor Adiantamento</b></font></td>'
	xHTM += '<td Width=12%><b><font color=#F5F5F5>Fornecedor</b></font></td>'
	xHTM += '<td Width=11%><b><font color=#F5F5F5>Dados Bancarios Fornecedor</b></font></td>'
	xHTM += '<td Width=11%><b><font color=#F5F5F5>Dados Banco V@</b></font></td>'
	xHTM += '<td Width=30%><b><font color=#F5F5F5>Observacao</b></font></td>
	xHTM += '</tr>'	
	
	xHTM += '<tr>'
	xHTM += '<td Width=4%>'+cRAFilial+'</td>'
	xHTM += '<td Width=15%>'+cRAPrefix+'\'+cRANum+'\'+'PA'+IIF(!EMPTY(cRAParcel),'\'+cRAParcel,"")+'</td>'
	xHTM += '<td Width=08%>'+SUBSTR(DTOS(dRAEmiss),7,2)+'/'+SUBSTR(DTOS(dRAEmiss),5,2)+'/'+SUBSTR(DTOS(dRAEmiss),1,4)+'</td>'
	xHTM += '<td Width=08%>'+SUBSTR(DTOS(DataValida(dRAVencto)),7,2)+'/'+SUBSTR(DTOS(DataValida(dRAVencto)),5,2)+'/'+SUBSTR(DTOS(DataValida(dRAVencto)),1,4)+'</td>'
	xHTM += '<td Width=12% align=right>'+Transform(nRAValor,"@E 999,999,999.99")+'</td>'
	xHTM += '<td Width=12% align=left>'+cRACli + "-" + cRALoja + "  " + ALLTRIM(Posicione("SA2",1,xFilial("SA2")+cRACli+cRALoja,"A2_NREDUZ")) + '</td>
	xHTM += '<td Width=11% align=left>'+cRADBanca+'</td>' 
	xHTM += '<td Width=11% align=left>Banco: ' + cRABanco + ' | Agencia: ' + cRAAgencia  + ' | Conta: ' + cRAConta + IIF(!EMPTY(cRACheque), '  | Cheque: ' + cRACheque, '')+'</td> 
	xHTM += '<td Width=30% align=left>' + Alltrim(cRAHist) + '</td>' 
	xHTM += '</tr>'	
	xHTM += '</table>'
	xHTM += '<br>
	xHTM += '<br>'
	xHTM += '</BODY><//HTML>'

	Processa({|| 	u_EnvMail(xEmail	,;			//_cPara
					xCopia 				,;			//_cCc
					""					,;			//_cBCC
					xAssunto			,;			//_cTitulo
					xaDados				,;			//_aAnexo
					xHTM				,;			//_cMsg
					.T.)},"Enviando e-mail...")		//_lAudit
	
Return
