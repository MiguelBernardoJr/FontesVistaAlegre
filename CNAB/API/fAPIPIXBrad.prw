#INCLUDE "TOTVS.CH"
#INCLUDE "JSON.CH"
#INCLUDE "SHASH.CH"

STATIC _ENTER_    := Chr(10) // + Chr(13) // SALTO DE LINHA (CARRIAGE RETURN + LINE FEED)
STATIC _TAB_      := Chr(9)  // TABULACAO
STATIC nTimeOut   := 120
STATIC cHttpVld   := GetMV( "MB_RETAPI",, "200|201") // |415|500") // Codigo de Retorno na API
STATIC nSLEEP     := 1000

/*--------------------------------------------------------------------------------,
 | Principal:   		            fAPIBradesco()            		              |
 | Func:      fAPIPIXBrad() // API.PIX.Bradesco            	          	          |
 | Cliente:   V@                                                                  |
 | Autor:     Miguel Martins Bernardo Junior	            	          	  	  |
 | Data:      29.01.2023	            	          	            	          |
 | Desc:      Rotina API de comunicacao com o Bradesco.                           |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
'--------------------------------------------------------------------------------*/
User Function fAPIPIXBrad() // API.PIX.Bradesco


    Local genToken  := "", oTokenJWT := Nil, claims    := Nil
    Local lRet := .T.
    Local aHeadStr       := {}, cPostRet := "", cPostParms := "", cHttpStat := "", nHttpCode := 0
    Local cAuthorization := "", oObj := nil
    //, cRet := ""
    Local aResEnc        := {;
        MemoRead("/API/APIConfigCode2.ini"),;
        MemoRead("/API/APIConfigCode3.ini"),;
        MemoRead("/API/APIConfigCode4.ini") ;
        }

    Private oJson           := JsonObject():New()
    Private cURLToken       := ""
    Private cEndPointToken  := ""
    Private cClient_Key     := ""
    Private cClient_Secret  := ""
    Private cURLTransf      := ""
    Private cEndPointTransf := ""

    If SE2->E2_XTPCHPX == "04" // CHAVE ALEATORIA
        Alert( "Chave Aleatoria nao permitida para o PIX." )
        Return .F.
    EndIf

    aResDec              := AESDecrypt( 2, aResEnc[1], aResEnc[2], aResEnc[3] )

    // cFileCfg := aResDec[2] // Dados do arquivo de configuracao
    If !FWJsonDeserialize( aResDec[2], @oJson)
        Alert( "Erro ao converter Json: " + aResDec[2] )
        lRet := .F.

    ElseIf cToD(oJson:DATA) < MsDate()
        Alert( "Data de Validade do Token Expirada: " + oJson:DATA + "." + _ENTER_ + "Esta operação sera cancelada." )
        lRet := .F.
    Else

        cURLToken       := oJson:PIX:HOMOLOGACAO:URLToken
        cEndPointToken  := oJson:PIX:EndPointToken
        cClient_Key     := oJson:PIX:HOMOLOGACAO:Client_Key
        cClient_Secret  := oJson:PIX:HOMOLOGACAO:Client_Secret
        cURLTransf      := oJson:PIX:HOMOLOGACAO:URLTransf
        cEndPointTransf := oJson:PIX:EndPointTransf

        If GetServerIP() == GetMV("MB_IP_PROD",,"192.168.0.242") // configuracao para P R O D U Ç Ã O
            cURLToken      := oJson:PIX:PRODUCAO:URLToken
            cClient_Key    := oJson:PIX:PRODUCAO:Client_Key
            cClient_Secret := oJson:PIX:PRODUCAO:Client_Secret
            cURLTransf     := oJson:PIX:PRODUCAO:URLTransf
        EndIf

        CLIENT_KEY := cClient_Key // oJson:Client_Key
        _cEndPoint := "PIX"

        cAuthorization := Encode64( cClient_Key + ':' + cClient_Secret )

        // Token
        // If GetServerIP() == GetMV("MB_IP_DESV",,"192.168.0.170")// .AND. SE2->E2_XTPAPI=="P"
        AAdd(aHeadStr, "Content-Type: application/x-www-form-urlencoded")
        AAdd(aHeadStr, 'Authorization: ' + 'Basic ' + cAuthorization )
        // AAdd(aHeadStr, 'Cookie: ak_bmsc=6EA0D569C3852076D96D7275A035652D~000000000000000000000000000000~YAAQySoRAvFdlx+TAQAAPClOQBlu/oWHnWu7tqTjtabyGcYuJm1wRPYwiuY0w/I9qlq7dt7f79m+Ci8zb6tdMnk4ymjz2/6llaJvjHgl1JHJNpBQBrv/pAt5LnZGJQwceBWFf0010AbnxpivbRXRdkC484c/Z9SZw2tY1ytlPUCH2iKe/zk3tAYoWslRFmumrgzrOORb1tE5lolBU2NL9ZQQ1mRYir8dcbLs3OIvSQYyXiOjPtj4or899ubWcS+w7/QegqcxzkFe5SQ95LWK2w30n4yAegLJ8fgmFKjHqc8A5uP+eLA6dCb2qj4QsV1ViSuon3lv+BdUBAW2Mjevkh0joyqqM0zlMITeXnBfM5lxFvHm6EJpBqDHWqA64Mnr3cNl54Gim5pvQ/kO6ciDQewwef4/6PNoCnzNw08E1RSuSw==; f90e2b980fa727fe2ec7319a84a64293=267f77ee83bf53ae184220b81910d64b' )
        // EndIf

        cPostParms := "grant_type=client_credentials"

        oRestClien := FwRest():New( cURLToken )
        oRestClien:SetPath( cEndPointToken )
        oRestClien:SetPostParams( cPostParms )
        Sleep( nSLEEP )

        // https://devforum.totvs.com.br/2386-httpsslclient--com-fwrest
        HTTPSSLClient( 0, 0, 3, "", oJson:PIX:Cert_Publico,;
            oJson:PIX:Cert_Privado, 0, .F. , 1, 1, 1)

        lRet      := oRestClien:Post(aHeadStr)
        cPostRet  := oRestClien:GetResult()
        nHttpCode := HTTPGetStatus(@cHttpStat)

        If !FWJsonDeserialize( cPostRet, @oObj)
            Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
        Else

            If  lRet := (lTrim(Str(nHttpCode)) $ cHttpVld) // Erro 500 se refere a ambiente instÃ¡vel //If  lRet := (nHttpCode == 200 .or. nHttpCode == 201 .or. nHttpCode == 500) // Erro 500 se refere a ambiente instÃ¡vel

                cRet := oObj:access_token // Alert( "Token Gerado com Sucesso" )
                MemoWrite( cPathLog + ( cPathFile := "01-mtdToken-06-ok-access_token.txt" ), cRet )
                aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

                lRet := U_fPIX( cRet )

            Else
                if Empty( cPostRet )
                    FwLogMsg( "Fail HTTPSPost" )   // Alert( cHeadRet, "Header" )
                else
                    Alert( cPostRet, "WebPage" ) // conout( "OK HTTPSPost" )
                endif
            endif

        EndIf
    EndIf

Return lRet



User Function fPIX( cAccessToken ) // , cXBradNonce, cTimestamp, __cClientKey, cRetJson )

    Local aArea      := GetArea()
    Local HeaderJson := nil // JsonObject():New()
    Local aHeadStr   := {}, cPostParms := "", cHttpStat := "", cPostRet := "", nHttpCode := 0
    // cErrStr := "", cSignature := '' ,
    Local oObj       := nil // oJson      := JsonObject():New(), xRet := nil
    Local lRet       := .F. // cRet       := ""
    // Local lInclui    := !ZE2->ZE2_XSTAPI $ ("BX,ER")
    Local lInclui    := !ZE2->ZE2_XSTAPI $ ("BX")
    Local _XDTBXA    := MsDate()
    Local _XHRBXA    := Time()

    // Json
    HeaderJson                                    := JsonObject():New()
    HeaderJson[ "pagador" ]                       := JsonObject():New()
    HeaderJson[ "pagador" ]["tipoChave"]          := "AGENCIACONTA"
    HeaderJson[ "pagador" ]["agencia" ]           := "3861"
    HeaderJson[ "pagador" ]["conta" ]             := "41000"

    HeaderJson[ "recebedor" ]                     := JsonObject():New()
    HeaderJson[ "recebedor" ][ "cpfCnpj" ]        := "09999902291969" // SA2->A2_CGC

    // 01=Telefone;02=E-mail;03=CPF/CNPJ;04=Chave Aleatória;
    Do Case
        Case SE2->E2_XTPCHPX == "01" // TELEFONE
            HeaderJson[ "recebedor" ][ "tipoChave" ]      := "TELEFONE"
        Case SE2->E2_XTPCHPX == "02" // EMAIL
            HeaderJson[ "recebedor" ][ "tipoChave" ]      := "EMAIL"
        Case SE2->E2_XTPCHPX == "03" // CPF/CNPJ
            HeaderJson[ "recebedor" ][ "tipoChave" ]      := "CPFCNPJ"
            // HeaderJson[ "recebedor" ][ "chavePix" ]       := "09999902291969" // SA2->A2_CGC
            // Case SE2->E2_XTPCHPX == "04" // CHAVE ALEATORIA
        Case SE2->E2_XTPCHPX == "05" // AGENCIACONTA
            HeaderJson[ "recebedor" ][ "tipoChave" ]   := "AGENCIACONTA"
            HeaderJson[ "recebedor" ][ "agencia" ]     := "3987"
            HeaderJson[ "recebedor" ][ "banco" ]       := "237"
            HeaderJson[ "recebedor" ][ "ispb" ]        := "60746948"
            HeaderJson[ "recebedor" ][ "conta" ]       := "200958"
            HeaderJson[ "recebedor" ][ "digitoConta" ] := "7"
            HeaderJson[ "recebedor" ][ "tipoConta" ]   := "CONTA_POUPANCA"
    EndCase

    If SE2->E2_XTPCHPX <> "05"
        HeaderJson[ "recebedor" ][ "chavePix" ]       :=  "09999902291969" // AllTrim(SE2->E2_XPIXCHV) // SA2->A2_CGC
    EndIf
    HeaderJson[ "recebedor" ][ "nomeFavorecido" ] := "FULANO DA SILVA JUNIOR" // AllTrim(SA2->A2_NOME)


    HeaderJson[ "valor" ]                         := AllTrim( Transform( SE2->E2_VALLIQ, "999999999999.99") )
    HeaderJson[ "idtransacao" ]                   := DToS( MsDate() ) + StrTran( Time(), ":", "" ) + cValToChar( SE2->(Recno()) ) // "TransfenciaAPI000000000000000000001"
    HeaderJson[ "descricao" ]                     := "Pagamento teste"
    cPostParms                                    := HeaderJson:toJson()

    MemoWrite( cPathLog + ( cPathFile := "06-PIX-01-HeaderJson.json" ),;
        ToJson( FromJson(cPostParms) ) )
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )


    AAdd(aHeadStr, "Content-Type: application/json; charset=utf-8")
    AAdd(aHeadStr, "Authorization: Bearer " + cAccessToken )

    MemoWrite( cPathLog + ( cPathFile := "06-PIX-04-RequestHeader.txt" ),;
        StrTran( StrTran( StrTran( StrTran( U_aToS(aHeadStr), '", "', _ENTER_ ),'{ "', ""), '" }', ""),': ', ":") )
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    oRestClien := FwRest():New( URLTransf )
    oRestClien:SetPath( cEndPointTransf ) // TED = "/transferencia/efetiva"
    oRestClien:SetPostParams( cPostParms )
    // oRestClien:SetPostParams( EncodeUTF8(cPostParms, "cp1252") )
    Sleep( nSLEEP )

    // // https://devforum.totvs.com.br/2386-httpsslclient--com-fwrest
    HTTPSSLClient( 0, 0, 3, "", oJson:PIX:Cert_Publico,;
        oJson:PIX:Cert_Privado, 0, .F. , 1, 1, 1)

    lRet      := oRestClien:Post(aHeadStr)
    // cPostRet  := DecodeUTF8( oRestClien:GetResult() ) // deu um erro aqui
    cPostRet  := oRestClien:GetResult()
    nHttpCode := HTTPGetStatus(@cHttpStat)

    // If !(lTrim(Str(nHttpCode)) $ cHttpVld)
    //     Alert( "Erro: " + cPostRet )
    //     Return .F.
    // EndIf

    // Metodo: TED
    If !FWJsonDeserialize( cPostRet, @oObj) // xRet := oJson:FromJson( cPostRet )
        // If ValType(xRet) <> "U" // !Empty( xRet ) igual a cError
        Alert( "Falha na estrutura do JSON de Retorno. Json: " + cPostRet) //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else

        cRetJson := cPostRet := ToJson( FromJson(cPostRet) ) // ToJson( FromJson(cPostRet) ) // formatar Json, formater json
        // if At( "CODIGO", Upper(cPostRet) ) > 0 .and. oObj:Codigo == "8" // oObj:Mensagem == CPF/CNPJ do favorecido inválido.
        //     lInclui := .T.
        // EndIf

        lRet := (lTrim(Str(nHttpCode)) $ cHttpVld) // Erro 500 se refere a ambiente instÃ¡vel
        If !lRet .OR. lInclui
            lInclui := .T.
            RecLock("ZE2", .F. )
            ZE2->ZE2_XSTAPI := "ER"
            ZE2->ZE2_XDTAPI := dDataBase
            ZE2->ZE2_XHRAPI := TIME()
            ZE2->ZE2_JSNENV := ToJson( FromJson(cPostParms) )
            ZE2->ZE2_XLOGIN := iIf(Empty(ZE2->ZE2_XLOGIN),"", AllTrim(ZE2->ZE2_XLOGIN) + (Chr(13)+Chr(10)) + (Chr(13)+Chr(10)) ) +;
                cPostRet
            ZE2->ZE2_METODO := "[PIX]/" + cEndPointTransf
            ZE2->(MsUnlock())

            _XDTBXA := ZE2->ZE2_XDTBXA
            _XHRBXA := ZE2->ZE2_XHRBXA
        EndIf

        RecLock("ZE2", lInclui )
        If lInclui
            ZE2->ZE2_FILIAL := SE2->E2_FILIAL
            ZE2->ZE2_PREFIX := SE2->E2_PREFIXO
            ZE2->ZE2_NUM    := SE2->E2_NUM
            ZE2->ZE2_FORNEC := SE2->E2_FORNECE
            ZE2->ZE2_LOJA   := SE2->E2_LOJA
            ZE2->ZE2_PARCEL := SE2->E2_PARCELA
            ZE2->ZE2_TIPO   := SE2->E2_TIPO
            ZE2->ZE2_ITEM   := U_fChvITEM( "ZE2" /* cTab */ ,;
                "ZE2_PREFIX, ZE2_NUM, ZE2_FORNEC, ZE2_LOJA, ZE2_PARCEL, ZE2_TIPO" /* cCpoSlc */ ,;
                "ZE2_ITEM" /* cCpoMAX */ ,;
                "ZE2_FILIAL+ZE2_PREFIX+ZE2_NUM+ZE2_FORNEC+ZE2_LOJA+ZE2_PARCEL+ZE2_TIPO" /* cWhreCpo */ ,;
                SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_FORNECE+E2_LOJA+E2_PARCELA+E2_TIPO) /* cInfo */ ,;
                /* cNotNull */,;
                SE2->E2_FILIAL )
            ZE2->ZE2_RCNSE2 := SE2->(Recno())

            ZE2->ZE2_XDTBXA := _XDTBXA
            ZE2->ZE2_XHRBXA := _XHRBXA
        EndIf
        ZE2->ZE2_VLRPAG := SE2->E2_VALLIQ // SE2->E2_VALOR // SE2->E2_VALOR
        ZE2->ZE2_XDTAPI := dDataBase
        ZE2->ZE2_XHRAPI := TIME()
        ZE2->ZE2_JSNENV := ToJson( FromJson(cPostParms) )
        ZE2->ZE2_XLOGIN := iIf(Empty(ZE2->ZE2_XLOGIN),"", AllTrim(ZE2->ZE2_XLOGIN) + (Chr(13)+Chr(10)) + (Chr(13)+Chr(10)) ) +;
            cPostRet
        ZE2->ZE2_METODO := "[PIX]/" + cEndPointTransf
        If lRet
            __cChvRet := cValToChar( oObj:e2e )
            ZE2->ZE2_XCHVRE := __cChvRet// chave retornada pela API BRADESCO - RETORNO API
        EndIf
        ZE2->(MsUnlock())

        // Alert(iIf(lRet, "Sucesso: ", "Erro: ") + _ENTER_ + cPostRet )
    EndIf

    MemoWrite( cPathLog + ( cPathFile := "06-PIX-05-Resultado_Json.json" ),;
        cPostRet ) // formatar Json, formater json
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    // FreeObj(oJson)
    RestArea( aArea )
Return lRet
