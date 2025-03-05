#Include "Rwmake.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Totvs.ch"
#Include "TryException.ch"

 
/* 
	MJ : 24.08.2017
	1- Este PE estava implementado no arquivo VACOMLIB; 
		1.1 - Trouxe ele para um FONTE exclusivo (MT100TOK), para melhor entendimento
			do processo, apos inclusao de encerrametno de transacao;
	2- Foi incluido neste PE bloco para encerrar transacao. Sug. do Andre, a fim de
			conseguir finalizar um documento de entrada, que estava impedindo continuidade
			da operacao;
*/
// Ponto de Entrada para validar confirmacao do Documento de Entrada
User Function MT100TOK()
Local aArea		:= GetArea()
Local l103Ret 	:= .T.
Local nLimDias	:= GetMV("MV_X_DTLIM",) // se nao existir parametro, cria o mesmo com 7 dias
Local cLimUser	:= GetMV("MV_X_USLIM") // se nao existir parametro, cria o mesmo coma senha tst0987
Local cDataLim	:= DTOS(date() - nLimDias) // data atual
Local cDataDoc	:= DTOS(if(Type("dDEmissao")=="U",DDatabase,dDEmissao)) // variavel de data no documento de entrada
Local cUsSenha	:= space(10)	
Local cf1Chvnfe	:= iif (Type("aNfeDanfe")<>"U",aNfeDanfe[13],'') 
Local cQryChv 	:= ''
//Local nI		:= 0                             
//Local nPosProd	:= aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_COD'} )
//Local nPosCC 	:= aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_CC'} )
//Local nPosTES 	:= aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_TES'} )
//Local nPosItem	:= aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_ITEM'} )
//Local nPosOS  	:= aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_ORDEM'} )
//Local nPosOP  	:= aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_OP'} )
//Local cMsg 		:= ""

// Alert('MT100TOK')

/* 
	Esta Solucao nao precisou ser COMPILADA, pois em producao, ambiente VA2, o problema nao estava acontecendo;
	// >> 24.08.2017
	TryException
		MsUnLockAll()
		EndTran()
		Alert('WorkArroud Sugest By Mr. André')
	CatchException Using oException
		Alert("Erro ao processar WorkArroud: " + CRLF + oException:Description)
		l103Ret := .F.
		DisarmTransaction() 
	EndException
// >> 24.08.2017
*/
	cQryChv := " SELECT  F1_FILIAL, F1_CHVNFE, F1_DOC, F1_SERIE "
	cQryChv += " FROM  "+RetSqlNAme('SF1')+"  "
	cQryChv += " WHERE F1_CHVNFE = '" + cf1Chvnfe + "' AND D_E_L_E_T_<>'*' AND F1_FILIAL <> '"+cFilant+"' "  // executar apenas para produtos com o campo preenchido e que nao estejam bloqueados  

	If Select("QRYCHV") <> 0
		QRYCHV->(dbCloseArea())
	Endif
	TCQUERY cQryChv NEW ALIAS "QRYCHV"
	dbSelectArea("QRYCHV")
	QRYCHV->(DbGoTop())
	
	If  !EMPTY(QRYCHV->F1_CHVNFE) .and. !Empty(cf1Chvnfe)
		Alert('Chave da NF-e ja foi utilizada em outra filial! verifique!!!  ( Filial: '+QRYCHV->F1_FILIAL+' | Documento: '+QRYCHV->F1_DOC+'\'+QRYCHV->F1_SERIE+' ) ')
        	// aNfeDanfe[13] := space(tamsx3("F1_CHVNFE")[1])
        Return .F. 
    Endif
	
	If cDataDoc < cDataLim
		MsgAlert("Data do documento menor que o limite definido em parametro MV_X_DTLIM!","Data do Documento")

		@ 0,1 TO 88,265 DIALOG oM103DtLib TITLE OemToAnsi("Liberacao do Documento")
		@ 2,2 TO 44,132	              
		@ 10,010 Say "Senha: " Size 50,8
		@ 10,045 GET cUsSenha 	SIZE 50,10 	PASSWORD
		@ 27,085 Button OemToAnsi("OK") Size 40,12 Action Close(oM103DtLib)
		Activate Dialog oM103DtLib Centered
		If Alltrim(cUsSenha) == Alltrim(cLimUser)
			l103Ret := .T.
		Else
			MsgAlert("Senha Incorreta! Verifique definicao do parametro MV_X_USLIM!","Senha Invalida - MV_X_USLIM")   
			l103Ret := .F.
		Endif
	Endif
	
	//l103Ret  := .F.

	//MsgAlert("l103Ret")

	//dbSelectArea("SF4")
	//SF4->(DbSetOrder(1))
	//
	//dbSelectArea("CT1")
	//CT1->(DbSetOrder(1))
	//
	//For nI := 1 to Len(aCols)
	//
	//	SB1->(DBSeek(FwxFilial("SB1")+aCols[nI][nPosProd]))
	//
	//	IF SF4->(DBSeek(FWxFilial("SF4")+aCols[nI][nPosTES]))
	//		if SF4->F4_TRANFIL == '2' .and.;
	//			SF4->F4_ESTOQUE == 'N' .and.;
	//			SF4->F4_TIPO == 'E' .and.;
	//			SF4->F4_DUPLIC == 'S'
	//
	//			If SB1->B1_X_PRDES == 'D' .and. Empty(aCols[nI][nPosCC])
	//				MsgAlert("A(s) linha(s) abaixo precisa(m) de identificar o centro de custo para quem a solicitação foi feita." + CRLF + aCols[nI][nPosItem] + " - " + aCols[nI][nPosProd])
	//		        cMsg += Iif(Empty(cMsg), "A(s) linha(s) abaixo precisa(m) de identificar o centro de custo para quem a solicitação foi feita." + CRLF, "") + aCols[nI][nPosItem] + " - " + aCols[nI][nPosProd] + CRLF
	//				exit
	//			ElseIf SB1->B1_X_PRDES == 'D'
	//
	//				If CT1->(DBSeek(FWxFilial("CT1")+SB1->B1_X_DEBIT)) .and. CT1->CT1_ITOBRG == '1'
	//					If Empty(aCols[nI][nPosOP]) //D1_OP
	//		                cMsg += Iif(Empty(cMsg), "A(s) linha(s) abaixo precisa(m) de identificar a Ordem de Producao." + CRLF, "") + aCols[nI][nPosItem] + " - " + aCols[nI][nPosProd] + CRLF
	//						exit
	//					ElseIf Empty(aCols[nI][nPosOS]) //D1_ORDEM
	//		                cMsg += Iif(Empty(cMsg), "A(s) linha(s) abaixo precisa(m) de identificar o Número da Ordem de serviço." + CRLF, "") + aCols[nI][nPosItem] + " - " + aCols[nI][nPosProd] + CRLF
	//						exit
	//					Endif
	//				Endif
	//			Endif
	//		Endif
	//	ENDIF
	//Next nI
	//
	//if !Empty(cMsg)
	//	ShowHelpDlg("MT100TOK", {cMsg}, 1, {"Por favor, preencha o centro de custo ou item contábil a que se destinam os itens solicitados."}, 1)
	//	l103Ret := .f.
	//endif

RestArea(aArea)
Return l103Ret
