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

	IF ALLTRIM(SB1->B1_GRUPO) $ "01|BOV"
		Envmail()
	ENDIF
	
	RestArea(aArea)
Return l103Ret

Static Function Envmail()
	Local nI 		:= 0
	Local cMsgAux 	:= ""
	Local cMsg 		:= ""
	Local cQry 		:= ""
	Local nPosDoc   := 0
	Local nPosFor   := 0
	Local nPosPS    := 0
	Local nPosPC    := 0
	Local nPosQue   := 0
	Local nPosKm    := 0
	Local nPosProd  := 0
	Local nPosPed   := 0
	Local oExecZCC  := nil 
	Local cPara 	:= GETMV("MV_EVM103L",,"luana.santana@vistaalegre.agr.br,carlos.silva@vistaalegre.agr.br")

	cMsg := '<table style="width: 100%; border-collapse: collapse; border: 1px solid #000;"> ' + CRLF 
	cMsg +=	'	<thead> ' + CRLF
	cMsg +=	'		<tr style="background-color: #92D050; color: #000; font-family: Arial, sans-serif; font-size: 14px; text-align: left;"> ' + CRLF
	cMsg +=	'		<th style="padding: 8px; border: 1px solid #000;">Contrato</th> ' + CRLF
	cMsg +=	'		<th style="padding: 8px; border: 1px solid #000;">Corretor</th> ' + CRLF
	cMsg +=	'		<th style="padding: 8px; border: 1px solid #000;">NF</th> ' + CRLF
	cMsg +=	'		<th style="padding: 8px; border: 1px solid #000;">Fornecedor</th> ' + CRLF
	cMsg +=	'		<th style="padding: 8px; border: 1px solid #000;">Peso Gado (Saída)</th> ' + CRLF
	cMsg +=	'		<th style="padding: 8px; border: 1px solid #000;">Peso Gado (Chegada)</th> ' + CRLF
	cMsg +=	'		<th style="padding: 8px; border: 1px solid #000;">Quebra</th> ' + CRLF
	cMsg +=	'		<th style="padding: 8px; border: 1px solid #000;">Km</th> ' + CRLF
	cMsg +=	'		</tr> ' + CRLF
	cMsg +=	'	</thead> ' + CRLF
	cMsg +=	'<tbody> ' + CRLF
	
	nPosDoc  := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_DOC'})
	nPosFor  := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_FORNECE'})
	nPosPS   := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_X_PESO'})
	nPosPC   := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_X_PESCH'})
	nPosQue  := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_X_QUEKG'})
	nPosKm   := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_X_KM'})
	nPosProd := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_COD'})
	nPosPed  := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'D1_PEDIDO'})

	cQry := "SELECT ZCC_CODIGO, ZCC_CODCOR,A3_NOME ,A2_NOME" + CRLF
	cQry += " FROM "+RetSqlNAme("ZBC")+" ZBC " + CRLF
	cQry += " JOIN "+RetSqlNAme("ZCC")+" ZCC ON " + CRLF
	cQry += " ZCC_FILIAL = ZBC_FILIAL " + CRLF
	cQry += " AND ZBC_CODIGO = ZCC_CODIGO " + CRLF
	cQry += " AND ZCC.D_E_L_E_T_ = '' " + CRLF
	cQry += " LEFT  JOIN "+RetSqlNAme("SA3")+" SA3 ON ZCC_CODCOR = A3_COD " + CRLF
	cQry += " AND SA3.D_E_L_E_T_ = '' " + CRLF
	cQry += " LEFT JOIN "+RetSqlNAme("SA2")+" SA2 ON A2_COD = ZCC_CODFOR " + CRLF
	cQry += " AND A2_LOJA = ZCC_LOJFOR " + CRLF
	cQry += " AND SA2.D_E_L_E_T_ = '' " + CRLF
	cQry += " WHERE ZBC.D_E_L_E_T_ = '' " + CRLF
	cQry += " AND ZBC_PEDIDO = ? " + CRLF

	oExecZCC := FWExecStatement():New(cQry)
	
	cMsgAux := ""
	For nI := 1 to Len(aCols)
		if !aCols[nI][Len(aCols[nI])]
		
		oExecZCC:SetString(1,aCols[nI][nPosPed])
		cAlias := oExecZCC:OpenAlias()

		cMsgAux += '<tr style="font-family: Arial, sans-serif; font-size: 14px; text-align: left;"> ' + CRLF
		cMsgAux += '<td style="padding: 8px; border: 1px solid #000;">'+(cAlias)->ZCC_CODIGO+'</td> ' + CRLF
		cMsgAux += '<td style="padding: 8px; border: 1px solid #000;">'+ALLTRIM((cAlias)->A3_NOME)+'</td> ' + CRLF
		cMsgAux += '<td style="padding: 8px; border: 1px solid #000;">'+cNFiscal + "-" +cSerie+'</td> ' + CRLF
		cMsgAux += '<td style="padding: 8px; border: 1px solid #000;">'+ALLTRIM((cAlias)->A2_NOME)+'</td> ' + CRLF
		cMsgAux += '<td style="padding: 8px; border: 1px solid #000;">'+cValToChar(aCols[nI][nPosPS] )+'</td> ' + CRLF
		cMsgAux += '<td style="padding: 8px; border: 1px solid #000;">'+cValToChar(aCols[nI][nPosPC] )+'</td> ' + CRLF
		cMsgAux += '<td style="padding: 8px; border: 1px solid #000;">'+cValToChar(aCols[nI][nPosQue])+'</td> ' + CRLF
		cMsgAux += '<td style="padding: 8px; border: 1px solid #000;">'+cValToChar(aCols[nI][nPosKm] )+'</td> ' + CRLF
		cMsgAux += '</tr> ' + CRLF
		
		(cAlias)->(DbCloseArea())
		
		endif
	Next nI
	
	if !Empty(cMsgAux)
		cMsg += cMsgAux
		cMsg += ' </tbody> ' + CRLF
		cMsg += ' </table> ' + CRLF

		Processa({ || u_EnvMail(/* cPara */"igor.oliveira@vistaalegre.agr.br"	,;			//_cPara
			"" 					,;	//_cCc
			""					,;	//_cBCC
			"Entrada de Gado - "+ Alltrim(Posicione("SA2",1,FWxFilial("SA2")+ca100For+cLoja,"A2_NOME"))+" - "+dToC(dDEmissao)+"",;		//_cTitulo
			nil					,;	//_aAnexo
			cMsg				,;	//_cMsg
			.T.)},"Enviando e-mail...")	//_lAudit
	endif

	oExecZCC:Destroy()
	oExecZCC := nil
Return 
