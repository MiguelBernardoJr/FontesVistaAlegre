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
	cQryChv += " WHERE F1_CHVNFE = '"+cf1Chvnfe+"' AND D_E_L_E_T_<>'*' AND F1_FILIAL <> '"+cFilant+"' "  // executar apenas para produtos com o campo preenchido e que nao estejam bloqueados  

	If Select("QRYCHV") <> 0
		QRYCHV->(dbCloseArea())
	Endif
	TCQUERY cQryChv NEW ALIAS "QRYCHV"
	dbSelectArea("QRYCHV")
	QRYCHV->(DbGoTop())
	
	If  !EMPTY(QRYCHV->F1_CHVNFE) .and. !Empty(cf1Chvnfe)
		Alert('Chave da NF-e ja foi utilizada em outra filial! verifique!!!  ( Filial: '+QRYCHV->F1_FILIAL+' | Documento: '+QRYCHV->F1_DOC+'\'+QRYCHV->F1_SERIE+' ) ')
        	aNfeDanfe[13] := space(tamsx3("F1_CHVNFE")[1])
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
	
RestArea(aArea)
Return l103Ret                            

