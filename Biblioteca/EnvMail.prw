#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  U_EnvMail ³ Autor ³ MARCIO R. LAPIDUSAS ³ Data ³ 15/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³  GENERICO  ³Contato³ MLAPIDUSAS@GMAIL.COM                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ ROTINA PADRAO PARA ENVIO DE E-MAIL CONFORME PARAMETROS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Parametro Tipo Descricao                                   ³±± 
±±³          ³ _cPara    C                                                ³±±
±±³          ³ _cCc      C                                                ³±±
±±³          ³ _cBCC     C                                                ³±±
±±³          ³ _cTitulo  C                                                ³±±
±±³          ³ _aAnexo   A                                                ³±±
±±³          ³ _cMsg     C                                                ³±±
±±³          ³ _lAudit   L                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ LOGICO -> (.T.) ENVIO OK / (.F.) FALHA NO ENVIO            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ADICIONAR A TAG ABAIXO NO APPSERVER CASO HAJA PROBLEMAS:   ³±±
±±³          ³    [MAIL]                                                  ³±±
±±³          ³    AUTHLOGIN=1                                             ³±±
±±³          ³    AUTHNTLM=0                                              ³±±
±±³          ³    ExtendSMTP=1                                            ³±±
±±³          ³    Protocol=POP3                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.    ³  Data  ³ Manutencao Efetuada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ MARCIO LAPIDUSAS ³15/05/13³ -Desenvolvimento da rotina U_EnvMail();   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function EnvMail(_cPara, _cCc, _cBCC, _cTitulo, _aAnexo, _cMsg, _lAudit)
Local oMail
Local oMessage
Local nRet
Local nTimeout := GetMV("MV_RELTIME")	//Timeout no Envio de E-Mail;
Local cServer  := GetMV("MV_RELSERV")	//Nome do Servidor de Envio de E-Mail utilizado nos relatorios;
Local cEmail   := ""					//Conta a ser utilizada no envio de E-Mail para os relatorios;
Local cEmailA  := ""					//Usuario para Autenticacao no Servidor de E-Mail;
Local cEmailFr := ""					//E-Mail utilizado no campo FROM no envio de relatorios por E-Mail;
Local cPass    := ""					//Senha da Conta de E-Mail para envio de relatorios;
Local lAuth    := GetMv("MV_RELAUTH")	//Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor necessita de Autenticacao;
Local cMailAud := GetMv("MV_MAILADT")	//Conta oculta de auditoria utilizada no envio de E-Mail para os relatorios;
Local lUseSSL  := GetMv("MV_RELSSL")	//Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao segura (SSL);
Local lUseTLS  := GetMv("MV_RELTLS")	//Informe se o servidor de SMTP possui conexao do tipo segura (SSL/TLS);
Local _nPorta  := 25					//Porta Default;
Local _nX 	   := 0
DEFAULT _cPara := ""
DEFAULT _cCc   := ""
DEFAULT _cBCC  := ""
DEFAULT _cMsg  := ""
DEFAULT _aAnexo  := {}
DEFAULT _cTitulo := ""
DEFAULT _lAudit  := .f.

	/*----------+-----------------------------------------------------------------------------+----------------------+----------------------+
	| PARAMETRO | DESCRICAO                                                                   | EXEMPLO E-MAIL TOTVS | EXEMPLO E-MAIL GMAIL |
	+-----------+-----------------------------------------------------------------------------+----------------------+----------------------+
	|MV_RELTIME |Timeout no Envio de E-Mail; .................................................|120                   |120                   |
	|MV_RELSERV |Nome do Servidor de Envio de E-Mail utilizado nos relatorios; ...............|mail.totvs.com.br:587 |smtp.gmail.com:465    |
	|MV_RELACNT |Conta a ser utilizada no envio de E-Mail para os relatorios; ................|usuario               |usuario@gmail.com     |
	|MV_RELAUSR |Usuario para Autenticacao no Servidor de E-Mail; ............................|usuario               |usuario@gmail.com     |
	|MV_RELFROM |E-Mail utilizado no campo FROM no envio de relatorios por E-Mail; ...........|usuario@totvs.com.br  |usuario@gmail.com     |
	|MV_RELPSW  |Senha da Conta de E-Mail para envio de relatorios; ..........................|*** senha ***         |*** senha ***         |
	|MV_RELAUTH |Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor........|.T.                   |.T.                   |
	|           |necessita de Autenticacao; ..................................................|                      |                      |
	|MV_MAILADT |Conta oculta de auditoria utilizada no envio de E-Mail para os relatorios; ..|email@dominio.com.br  |email@dominio.com.br  |
	|MV_RELSSL  |Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao...|.F.                   |.T.                   |
	|           |segura (SSL); ...............................................................|                      |                      |
	|MV_RELTLS  |Informe se o servidor de SMTP possui conexao do tipo segura (SSL/TLS); ......|.T.                   |.F.                   |
	+-----------+-----------------------------------------------------------------------------+----------------------+---------------------*/

	IF PROCNAME(2) $ 'U_VACOMR10|U_MT131WF'
		cEmailFr := cEmailA  := cEmail := AllTrim(Posicione("SY1", 3, xFilial("SY1")+__cUserID,"Y1_EMAIL"))
		cPass 	 := AllTrim(Posicione("SY1", 3, xFilial("SY1")+__cUserID,"Y1_SENHA") )  // 
	ELSE
		cEmail   := GetMV("MV_RELACNT")
		cEmailA  := GetMV("MV_RELAUSR")
		cEmailFr := GetMV("MV_RELFROM")
		cPass    := GetMV("MV_RELPSW")
	ENDIF 

	ProcRegua(15)

	//---------------------------------------------------------------------------------------------------------------------
	//VALIDANDO OS PARAMETROS INFORMADOS
	If Empty(cServer) .OR. Empty(cEmail) .OR. Empty(cEmailA) .OR. Empty(cPass)
		if PROCNAME(2) $ 'U_VACOMR10|U_MT131WF'
			MsgBox("Verifique o parametro: MV_RELSERV. E o cadastro de comprador os Campos: Y1_EMAIL, Y1_SENHA!!!","Funcao EnvMail","STOP") 
		else
			MsgBox("Verifique os parametros: MV_RELSERV, MV_RELACNT, MV_RELAUSR ou MV_RELPSW!!!","Funcao EnvMail","STOP") 
		endif 
		Return(.F.)
	EndIf

	If Empty(_cPara)
		MsgBox("Parametro 'Para' tem preenchimento obrigatorio!!!","Funcao EnvMail","STOP") 
		Return(.F.)
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CASO O ENDERECO DO SERVER TENHA A PORTA INFORMADA, SEPARA OS CAMPOS
	If(At(":",cServer) > 0)
		_nPorta := Val(Substr(cServer,At(":",cServer)+1,Len(cServer)))
		cServer := Substr(cServer,0,At(":",cServer)-1)
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CRIA UMA INSTANCIA DA CLASSE TMAILMANAGER
	oMail := TMailManager():New()
	If(lUseSSL)
		oMail:SetUseSSL(lUseSSL)
	EndIf
	If(lUseTLS)
		oMail:SetUseTLS(lUseTLS)
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//DEFINE AS CONFIGURACOES, DA CLASSE TMAILMANAGER, PARA REALIZAR UMA CONEXAO COM O SERVIDOR DE E-MAIL
	oMail:Init("",cServer,cEmail,cPass,0,_nPorta)

	//---------------------------------------------------------------------------------------------------------------------
	//DEFINE O TEMPO DE ESPERA PARA UMA CONEXAO ESTABELECIDA COM O SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL)
	If (nTimeout <= 0)
		ConOut("[TIMEOUT] DISABLE")
	Else
		IncProc("[TIMEOUT] ENABLE()")
		ConOut("[TIMEOUT] ENABLE()")
		nRet := oMail:SetSmtpTimeOut(nTimeout)

		If nRet != 0
			ConOut("[TIMEOUT] Fail to set")
			ConOut("[TIMEOUT][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
			MsgBox("[TIMEOUT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
			oMail:SMTPDisconnect()
			Return(.F.)
		EndIf
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CONECTA COM O SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL)
	IncProc("[SMTPCONNECT] connecting ...")
	ConOut("[SMTPCONNECT] connecting ...")
	nRet := oMail:SmtpConnect()
	If nRet <> 0
		ConOut("[SMTPCONNECT] Falha ao conectar")
		ConOut("[SMTPCONNECT][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
		MsgBox("[SMTPCONNECT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
		oMail:SMTPDisconnect()
		Return(.F.)
	Else
		ConOut("[SMTPCONNECT] Sucesso ao conectar")
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//REALIZA A AUTENTICACAO NO SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL) PARA ENVIO DE MENSAGENS
	If lAuth
		IncProc("[AUTH] ENABLE")
		ConOut("[AUTH] ENABLE")
		ConOut("[AUTH] TRY with ACCOUNT() and PASS()")

		nRet := oMail:SMTPAuth(cEmailA,cPass)
		If nRet != 0
			IncProc("[AUTH] FAIL TRY with ACCOUNT() and PASS()")
			ConOut("[AUTH] FAIL TRY with ACCOUNT() and PASS()")
			ConOut("[AUTH][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
			ConOut("[AUTH] TRY with USER() and PASS()")
			MsgBox("[AUTH][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
			nRet := oMail:SMTPAuth(cEmailA,cPass)

			If nRet != 0
				ConOut("[AUTH] FAIL TRY with USER() and PASS()")
				ConOut("[AUTH][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
				MsgBox("[AUTH][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
				oMail:SMTPDisconnect()
				Return(.F.)
			Else
				IncProc("[AUTH] SUCEEDED TRY with USER() and PASS()")
				ConOut("[AUTH] SUCEEDED TRY with USER() and PASS()")
			EndIf
		Else
			IncProc("[AUTH] SUCEEDED TRY with ACCOUNT and PASS")
			ConOut("[AUTH] SUCEEDED TRY with ACCOUNT and PASS")
		EndIf
	Else
		IncProc("[AUTH] DISABLE")
		ConOut("[AUTH] DISABLE")
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CRIA UMA INSTANCIA DA CLASSE TMAILMANAGER
	IncProc("[MESSAGE] Criando mail message")
	ConOut("[MESSAGE] Criando mail message")
	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom    := if(!Empty(cEmailFr),cEmailFr,cEmail)
	oMessage:cTo      := _cPara
	oMessage:cCc      := _cCc
	oMessage:cBCC     := IIF(_lAudit, cMailAud, "") + IIF(!Empty(_cBCC), (";" + _cBCC),"")
	oMessage:cSubject := _cTitulo
	oMessage:cBody    := _cMsg

	For _nX := 1 to Len(_aAnexo)
	    if Len(_aAnexo[_nX]) == 2
            oMessage:AddAttHTag("Content-ID: <" + _aAnexo[_nX][01] + ">")	//Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
            oMessage:AttachFile(_aAnexo[_nX][02])							//Adiciona um anexo, nesse caso a imagem esta no root
        else
            oMessage:AttachFile(_aAnexo[_nX])							//Adiciona um anexo, nesse caso a imagem esta no root
        endif
	Next _nX
	oMessage:MsgBodyType("text/html")

	//---------------------------------------------------------------------------------------------------------------------
	//ENVIA E-MAIL ATRAVÉS DO PROTOCOLO SMTP
	IncProc("[SEND] Sending ...")
	ConOut("[SEND] Sending ...")
	nRet := oMessage:Send(oMail)
	If nRet <> 0
		ConOut("[SEND] Fail to send message")
		ConOut("[SEND][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
		MsgBox("[SEND][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
		oMail:SMTPDisconnect()
		Return(.F.)
	Else
		IncProc("[SEND] Success to send message")
		ConOut("[SEND] Success to send message")
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//FINALIZA A CONEXAO ENTRE A APLICACAO E O SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL)
	IncProc("[DISCONNECT] smtp disconnecting ... ")
	ConOut("[DISCONNECT] smtp disconnecting ... ")
	oMail:SMTPDisconnect()
	If nRet != 0
		IncProc("[DISCONNECT] Fail smtp disconnecting ... ")
		ConOut("[DISCONNECT] Fail smtp disconnecting ... ")
		ConOut("[DISCONNECT][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
		MsgBox("[DISCONNECT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
	Else
		IncProc("[DISCONNECT] Success smtp disconnecting ... ")
		ConOut("[DISCONNECT] Success smtp disconnecting ... ")
	EndIf

Return(.T.)


//---------------------------------------------------------------------------------------------------------------------
//FUNCAO PARA TESTES DE ENVIO
//---------------------------------------------------------------------------------------------------------------------
User Function TstEnvMail()
Local aDados := {}

	aAdd(aDados, {"ID_conf_cfop.rpm", "\conf_cfop.rpm"})
	aAdd(aDados, {"ID_conf_cxa.rpm", "\conf_cxa.rpm"})

	Processa({|| u_EnvMail("henriquemds@hotmail.com",;			//_cPara
							"henriquemds@totvs.com.br",;		//_cCc
							"",;							//_cBCC
							"teste",;						//_cTitulo
							aDados,;						//_aAnexo
							"TESTE DE ENVIO DE EMAIL",;		//_cMsg
							.T.)},"Enviando e-mail...")		//_lAudit

Return(Nil)
