#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Monitoramento de alterações de campos de bovinos padrão"

User Function VAFATI09() // U_VAFATI09()
    Local lRet      := .T.
    Local cBov      := GETMV("MV_BOVPADR")
    Local cCampo    := ""
    Local cTitulo   := ""
    Local cMsg      := ""

    IF ALLTRIM(SB1->B1_GRUPO) == "BOV" .and. !IsInCallStack("U_VAMVCA01") .and. AllTrim(SB1->B1_COD) $ cBov
        
        cBov      := GETMV("MV_BOVPADR")
        cCampo    := SubStr(ReadVar(),at('>',ReadVar())+1,Len(ReadVar()))
        cTitulo   := FWX3Titulo( cCampo )

        if GetEnvServ() == "IGOR"
            cMsg := "*****AMBIENTE TESTE*****" + CRLF + "<br>"
        else
            cMsg := "*****AMBIENTE PRODUÇÃO*****" + CRLF + "<br>"
        endif
        cMsg += "Produto: " + AllTrim(SB1->B1_COD) + CRLF + "<br>"
        cMsg += "Campo: " + cCampo + " - " + AllTrim(cTitulo) + CRLF + "<br>"
        cMsg += "Valor antigo: " + SB1->&(cCampo) + CRLF + "<br>"
        cMsg += "Valor novo: " + AllTrim(&(ReadVar())) + CRLF + "<br>"
        cMsg += "Usuário: " + cUserName + CRLF + "<br>"
        cMsg += "Data: " + DTOC(DATE()) + " " + TIME() + CRLF + "<br><br>"
        cMsg += "Pilha de chamada:" + CRLF + "<br><br>"

        n := 1
        While !Empty( ProcName( n ) )
            cMsg += ProcName( n++ ) + CRLF + "<br>" //Conout( AllTrim( ProcName( n++ ) ) )
        EndDo

        u_EnvMail( "igor.oliveira@vistaalegre.agr.br"	   	,;
            "carlos.silva@vistaalegre.agr.br"	           	,;
            ""			           	,;
            "BOV PADRÃO ALTERADO"	,;
            "" 		           		,;
            cMsg			        ,;
            .T.)

    endif
Return lRet
