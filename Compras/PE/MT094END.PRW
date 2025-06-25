#Include "TOTVS.ch"

User Function MT094END()
    Local aArea     := FwGetArea()
    Local cMessage  := " "
    Local cEmail    := ""
    Local cPass     := ""
    Local cForMail  := ""
    Local cServPath := "\PEDIDOS\"
    Local cLocalPath:= "C:\TOTVS_RELATORIOS\PEDIDOS\"
    
    If !(SCR->CR_STATUS $ "03|05")
        return
    EndIf
    
    DbSelectArea("SY1")
    DbSetOrder(3) //Y1_FILIAL+Y1_COD
    
    IF !(SY1->(DbSeek(FWxFilial("SY1")+SC7->C7_USER)))
        RETURN
    ENDIF

    cEmail := ALLTRIM(SY1->Y1_EMAIL)
    cPass  := ALLTRIM(SY1->Y1_SENHA)

    DbSelectArea("SA2")
    DbSetOrder(1)
    SA2->(DbSeek(FWxFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))

    cForMail := AllTrim(SA2->A2_EMAIL)

    IF Empty(cForMail)
        return
    Endif
    
    cMessage := iif(Val(SubStr(Time(),1,2))<12,"Bom dia!! <br>",iif(Val(SubStr(Time(),1,2))>18,"Boa Noite!! <br>","Boa Tarde!! <br>")) + CRLF 
    cMessage += "<br>" + CRLF
    cMessage += "Pedido de compras aprovado. <br>" + CRLF
    cMessage += "Número: "+SC7->C7_NUM+"<br>" + CRLF
    cMessage += "Data de aprovação: "+dToc(Date())+"<br>" + CRLF
    cMessage += "<br>" + CRLF
    cMessage += "Atenciosamente," + CRLF
    cMessage += "<br>" + CRLF
    cMessage += "<br>" + CRLF
    cMessage += ALLTRIM(SY1->Y1_NOME) + "<br>" + CRLF
    cMessage += ALLTRIM(SY1->Y1_TEL) + "<br>" + CRLF
    cMessage += ALLTRIM(SY1->Y1_EMAIL) + "<br>" + CRLF
    cMessage += "<br>" + CRLF
    cMessage += "www.vistaalegre.agr.br" + CRLF

    if !Empty(cChave := U_VACOMR11())
        //cTexto := ""PEDIDO APROVADO: " + SubStr(cChave, 1, TamSX3("C8_NUM")[1]) + ".""
        cTexto      := "EMAIL DE TESTE, EM DESENVOLVIMENTO"
        cForMail    := "teste@vistaalegre.agr.br"
        U_zEnvMail(cForMail, cTexto,;
                   cMessage, {cServPath+cChave}, .T. , ,cEmail,cPass)

        FErase(cLocalPath+cChave)
    endif 

    FwRestArea(aArea)
Return
User Function zEnvMail(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS,cFrom,cPass)
    Local aArea        := GetArea()
    Local nAtual       := 0
    Local lRet         := .T.
    Local oMsg         := Nil
    Local oSrv         := Nil
    Local nRet         := 0
    Local cUser        := SubStr(cFrom, 1, At('@', cFrom)-1)
    Local cSrvFull     := Alltrim(GetMV("MV_RELSERV"))
    Local cServer      := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
    Local nPort        := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)
    Local nTimeOut     := GetMV("MV_RELTIME")
    Local cLog         := ""
    Default cPara      := ""
    Default cAssunto   := ""
    Default cCorpo     := ""
    Default aAnexos    := {}
    Default lMostraLog := .F.
    Default lUsaTLS    := .F.
  
    //Se tiver em branco o destinatário, o assunto ou o corpo do email
    If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
        cLog += "001 - Destinatario, Assunto ou Corpo do e-Mail vazio(s)!" + CRLF
        lRet := .F.
    EndIf
  
    If lRet
        //Cria a nova mensagem
        oMsg := TMailMessage():New()
        oMsg:Clear()
  
        //Define os atributos da mensagem
        oMsg:cFrom    := cFrom
        oMsg:cTo      := cPara
        oMsg:cSubject := cAssunto
        oMsg:cBody    := cCorpo
  
        //Percorre os anexos
        For nAtual := 1 To Len(aAnexos)
            //Se o arquivo existir
            If File(aAnexos[nAtual])
  
                //Anexa o arquivo na mensagem de e-Mail
                nRet := oMsg:AttachFile(aAnexos[nAtual])
                If nRet < 0
                    cLog += "002 - Nao foi possivel anexar o arquivo '"+aAnexos[nAtual]+"'!" + CRLF
                EndIf
  
            //Senao, acrescenta no log
            Else
                cLog += "003 - Arquivo '"+aAnexos[nAtual]+"' nao encontrado!" + CRLF
            EndIf
        Next
  
        //Cria servidor para disparo do e-Mail
        oSrv := tMailManager():New()
  
        //Define se irá utilizar o TLS
        If lUsaTLS
            oSrv:SetUseTLS(.T.)
        EndIf
  
        //Inicializa conexão
        nRet := oSrv:Init("", cServer, cUser, cPass, 0, nPort)
        If nRet != 0
            cLog += "004 - Nao foi possivel inicializar o servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
            lRet := .F.
        EndIf
  
        If lRet
            //Define o time out
            nRet := oSrv:SetSMTPTimeout(nTimeOut)
            If nRet != 0
                cLog += "005 - Nao foi possivel definir o TimeOut '"+cValToChar(nTimeOut)+"'" + CRLF
            EndIf
  
            //Conecta no servidor
            nRet := oSrv:SMTPConnect()
            If nRet <> 0
                cLog += "006 - Nao foi possivel conectar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                lRet := .F.
            EndIf
  
            If lRet
                //Realiza a autenticação do usuário e senha
                nRet := oSrv:SmtpAuth(cFrom, cPass)
                If nRet <> 0
                    cLog += "007 - Nao foi possivel autenticar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                    lRet := .F.
                EndIf
  
                If lRet
                    //Envia a mensagem
                    nRet := oMsg:Send(oSrv)
                    If nRet <> 0
                        cLog += "008 - Nao foi possivel enviar a mensagem: " + oSrv:GetErrorString(nRet) + CRLF
                        lRet := .F.
                    EndIf
                EndIf
  
                //Disconecta do servidor
                nRet := oSrv:SMTPDisconnect()
                If nRet <> 0
                    cLog += "009 - Nao foi possivel disconectar do servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                EndIf
            EndIf
        EndIf
    EndIf
  
    //Se tiver log de avisos/erros
    If !Empty(cLog)
        cLog := "zEnvMail - "+dToC(Date())+ " " + Time() + CRLF + ;
            "Funcao - " + FunName() + CRLF + CRLF +;
            "Existem mensagens de aviso: "+ CRLF +;
            cLog
        ConOut(cLog)
  
        //Se for para mostrar o log visualmente e for processo com interface com o usuário, mostra uma mensagem na tela
        If lMostraLog .And. ! IsBlind()
            Aviso("Log", cLog, {"Ok"}, 2)
        EndIf
    EndIf
  
    RestArea(aArea)
Return lRet
