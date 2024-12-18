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
 | Func:      fAPIBradesco()	            	          	            	      |
 | Cliente:   V@                                                                  |
 | Autor:     Miguel Martins Bernardo Junior	            	          	  	  |
 | Data:      29.01.2023	            	          	            	          |
 | Desc:      Rotina API de comunicacao com o Bradesco.                           |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
'--------------------------------------------------------------------------------*/
User Function fAPIBradesco( nOper )

    Local nI       := 0
    Local aAreas   :={GetArea(), SE2->(GetArea()), ZE2->(GetArea())}
    Local cTit     := "Erro Localizado"
    Local cMsg     := ""
    Local lRetorno := .T.

    dbSelectArea( "ZE2" )
    ZE2->(DbSetOrder(1))
    if ZE2->(ZE2_FILIAL+ZE2_PREFIX+ZE2_NUM+ZE2_FORNEC+ZE2_LOJA+ZE2_PARCEL+ZE2_TIPO) <> SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_FORNECE+E2_LOJA+E2_PARCELA+E2_TIPO) .AND.;
            !ZE2->(DbSeek( SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_FORNECE+E2_LOJA+E2_PARCELA+E2_TIPO) ))
        FWAlertError( "O Titulo: " + SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_FORNECE+E2_LOJA+E2_PARCELA+E2_TIPO) +;
            "não foi encontrado na tabela de integração.", "Aviso")
        lRetorno := .F.
    EndIf

    if lRetorno .AND. nOper == 'E' // E=Enviar API Bradesco

        If Empty(ZE2->ZE2_XDTLIB) //  .AND. Empty(ZE2->ZE2_XDTAPI)
            cMsg := "<html><div>" +;
                '<font face=verdana color=#00FF00 size=5>' +;
                'Titulo aguardando Aprovacao.' +;
                '</font></div></html>'
            FWAlertError( cMsg, "Aviso")

            RecLock("ZE2",.F.)
            ZE2->ZE2_XSTAPI := "99" // jessica passou por aqui e pediu para aprovar/liberar API com o banco
            ZE2->(MsUnlock())

            lRetorno := .F. // Return .T.
        Else

            // If ZE2->ZE2_XSTAPI == "03" .Or. ZE2->ZE2_XSTAPI == "05" .Or. !Empty(SE2->E2_XDTLIB)
            // Título já foi liberado.
            If !(ZE2->ZE2_XSTAPI == "03" .Or. ZE2->ZE2_XSTAPI == "05" .OR. ;
                    ZE2->ZE2_XSTAPI == "ER" .Or. Empty(ZE2->ZE2_XDTAPI))
                // ZE2->ZE2_XSTAPI == "ER" .Or. !Empty(SE2->E2_XDTLIB)) // NAO ENTROU NA VALIDACAO QDO OK, TITULO JA FOI PAGO. FIZ A ALTERACAO ACIMA, VALIDAR

                /// If !Empty(ZE2->ZE2_XDTAPI) ; // FOI SOLICITADO INTEGRACAO PARA PAGAMENTO
                If ZE2->ZE2_XSTAPI == '99' .OR. ZE2->ZE2_XSTAPI == 'BX' // TITULO AGUARDANDO LIBERACAO
                    cMsg := "<html><div>Solcitação de liberacao para pagamento em : <b>" +;
                        DtoC(ZE2->ZE2_XDTAPI) + '-' + ZE2->ZE2_XHRAPI +;
                        '</b>.<br><br><font face=verdana color=#FF0000 size=5>' +;
                        'Favor aguardar liberação da direção para integracao de API com o banco.' +;
                        '</font></div></html>'
                ElseIf ZE2->ZE2_XSTAPI == "02" .Or. ZE2->ZE2_XSTAPI == "04"
                    cMsg := "<html><div><font face=verdana color=#FF0000 size=5>" +;
                        "Título encontra-se com bloqueio pelo aprovador." +;
                        '</font></div></html>'
                ElseIf ZE2->ZE2_XSTAPI == "OK"
                    cMsg := "<html><div><font face=verdana color=#00ff00 size=5>" +;
                        "O Titulo ja foi transmitido ao Banco e esta com status OK para a integracao de pagamento." +;
                        '</font></div></html>'
                    cTit := "Atenção"
                Else
                    cMsg := "Status: " + ZE2->ZE2_XSTAPI + " não permite a integração com o banco."
                EndIf

                FWAlertError( cMsg, cTit)
                lRetorno := .F. // Return .F.
            EndIf
        EndIf
    EndIf

    If lRetorno
        Processa( { || lRetorno := U_fxAPIBradesco( nOper ) }, "Aguarde...")
    EndIf

    //-- Reposiciona Arquivos
    // For nI := 1 To Len(aAreas)
    //     RestArea(aAreas[nI])
    // Next nI
    AEval(aAreas, {|x| RestArea(x) })

Return lRetorno

User Function fxAPIBradesco( nOper )

    Local oObjBradesco  := nil
    Local cMsg          := ""
    Local lRet          := .T.

    Private cPathLog   := "\API\" + StrTran(dToS(dDataBase), '/','')+'_'+StrTran(Time(), ':','') + "_"
    Private cPathFile   := ""
    Private cE2CODBAR   := AllTrim(SE2->E2_CODBAR) // "83670000001122000481006807187391100091545290"

    // ENDEREÇOS DA HOMOLOGACAO
    Private cURLToken   := "https://proxy.api.prebanco.com.br/auth/server/v1.1/"
    Private cURLBrad    := "https://proxy.api.prebanco.com.br/oapi/v1/"
    Private cURLTED     := "https://proxy.api.prebanco.com.br/v1/"
    Private CLIENT_KEY  := "49eeb64f-ef34-496b-93dc-3ac9aa5d1aeb"

    Private nAgBrad     := 3995
    Private nAgBradDig  := 0
    Private nCtaDeb     := 75557
    Private nCtaDebDig  := 0
    Private _cEndPoint := "", _aAnexos    := {}

    Default nOper       := "E"

    If !(lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador,jsilva')
    MsgAlert("Usuario: " + AllTrim(cUserName) + " sem permissao para acessar a API do Bradesco.")
    lRet := .F.
    EndIf

    If lRet
        DbSelectArea( 'SA2' )
        SA2->(DbSetOrder(1))
        If !SA2->(DbSeek( FwxFilial('SA2') + SE2->E2_FORNECE + SE2->E2_LOJA )) // SE2->E2_FORNECE + SE2->E2_LOJA
            FWAlertError( "Fornecedor: " + SE2->E2_FORNECE + SE2->E2_LOJA +;
                " não encontrado na tabela de fornecedores.", "Aviso")
            lRet := .F.
        EndIf
    EndIf

    If lRet
        if nOper == 'E' .AND. ZE2->ZE2_XSTAPI == 'OK'
            cMsg := "<html><div>Titulo ja enviado para pagamento em: <b>" +;
                DtoC(ZE2->ZE2_XDTAPI) + '-' + ZE2->ZE2_XHRAPI +;
                '</b>.<br><br>Código Banco Bradesco: <font face=verdana color=#FF0000 size=5>' + AllTrim(ZE2->ZE2_XCHVRE) + '</font></div></html>'
            FWAlertError( cMsg, "Processo cancelado")
            lRet := .F.
        EndIf
    EndIf
    If !lRet
        Return .F.
    EndIf

    If SE2->E2_XTPAPI == "P"

        lRet := U_fAPIPIXBrad() // API.PIX.Bradesco

    Else
        If GetServerIP() == GetMV("MB_IP_PROD",,"192.168.0.242") // configuracao para P R O D U Ç Ã O
            // Alert("Producao: " + cValToChar( GetServerIP()))
            nAgBrad    := 3386
            nAgBradDig := 3
            nCtaDeb    := 521900

            CLIENT_KEY := "75a6035c-a888-4f24-9028-896f1e7533fc"

            cURLToken  := "https://openapi.bradesco.com.br/auth/server/v1.1/"
            cURLBrad   := "https://openapi.bradesco.com.br/oapi/v1/"
            cURLTED    := "https://openapi.bradesco.com.br/v1/"

            // Else
            //     // API PIX
            //     If SE2->E2_XTPAPI == "P"
            //         CLIENT_KEY  := "cbb23aa6-4236-4f76-9951-e746d88b0e6c"
            //     EndIf
        EndIf

        oObjBradesco       := APIBradesco():New()

        If  ___Token[ 01 ] == "HORA" .OR.;
                Empty( ___Token[ 02 ] ) .OR.;
                IncTime( ___Token[ 01 ], 0, 40 ) < Time()

            ___Token[ 01 ] := Time()
            ___Token[ 02 ] := oObjBradesco:cAccessToken := p( oObjBradesco:__cClientKey, oObjBradesco:__cIat, oObjBradesco:__cExp, oObjBradesco:cXBradNonce )
        Else
            If Empty( oObjBradesco:cAccessToken ) .AND. !Empty( ___Token[ 02 ] )
                oObjBradesco:cAccessToken := ___Token[ 02 ]
            EndIf
        EndIf

        If Empty( oObjBradesco:cAccessToken )
            MSGSTOP( "Token nao gerado. Aguardar 5 minutos e tentar novamente.", "Erro no banco." )
            // Return .F.
            lRet := .F.
        EndIf

        If lRet
            if nOper == 'E'
                lRet := oObjBradesco:efetivaPagamento()
            Else
                lRet := oObjBradesco:consultaPagamento()
            EndIf
        EndIf
    EndIf

    cMsg := "<div>EndPoint: <font size=6>" + _cEndPoint + "</font> - Metodo: <b>" + AllTrim( ZE2->ZE2_METODO ) + "</b></div><br/>"+;
        "<h1><font color=" + iIf(lRet,"#00FF00>Sucesso", "#FF0000>Erro") + "</font></h1><br/>"+;
        "na integração para o pagamento do título: <font size=5>" + ZE2->ZE2_FILIAL + ZE2->ZE2_PREFIX + ZE2->ZE2_NUM + ZE2->ZE2_FORNEC + ZE2->ZE2_LOJA + ZE2->ZE2_PARCEL + ZE2->ZE2_TIPO + "</font>"+;
        " - Valor: <font size=6> " + AllTrim( Transform( ZE2->ZE2_VLRPAG, "999999999999.99") ) + "</font><br/><br/>" +;
        "Filial: <font size=4>"     + Alltrim(ZE2->ZE2_FILIAL) + "</font><br/>"+;
        "Prefixo: <font size=4>"    + Alltrim(ZE2->ZE2_PREFIX) + "</font><br/>"+;
        "Documento: <font size=4>"  + Alltrim(ZE2->ZE2_NUM)    + "</font><br/>"+;
        "Fornecedor: <font size=4>" + Alltrim(ZE2->ZE2_FORNEC) + "</font><br/>"+;
        "Loja: <font size=4>"       + Alltrim(ZE2->ZE2_LOJA)   + "</font><br/>"+;
        "Parcela: <font size=4>"    + Alltrim(ZE2->ZE2_PARCEL) + "</font><br/>"+;
        "Tipo: <font size=4>"       + Alltrim(ZE2->ZE2_TIPO)   + "</font><br/><br/><br/>"+;
        "Envio automático com anexo dos logs de integração Protheus V@ x API Banco Bradesco.<br/><br/><br/>"+;
        iIf(!Empty(ZE2->ZE2_XLOGIN), "<b>Retorno do Banco:</b><br/><br/>" + ZE2->ZE2_XLOGIN /* oObjBradesco:cRetJson */, "") +;
        "<br/><br/><br/>" +;
        "Data: <b>" + DtoC( MsDate() ) + "</b> - Hora: <b>" + Time() + "</b><br/><br/><br/>"

    // Alert("Programar aqui o envio de email.")
    // Processa({ || u_EnvMail("miguel.bernardo@vistaalegre.agr.br",;	    // _cPara
    Processa({ || u_EnvMail("api.bradesco@vistaalegre.agr.br",;	    // _cPara
        "",;	                                                    // _cCc
        "",;					        // _cBCC
        "Log de Integração API Bradesco" + iIf(lRet,"", " - Erro"),;	                                // _cTitulo
        _aAnexos ,;						                            // _aAnexo
        cMsg,;	                                                    //_cMsg
        /* _lAudit */ )},"Enviando e-mail...")	//_lAudit

Return lRet

Class APIBradesco FROM LongClassName

    DATA __mbDATA     as String // := MsDate()
    DATA __mbHORA     as String // := Time()
    DATA __cClientKey as String // := "49eeb64f-ef34-496b-93dc-3ac9aa5d1aeb"
    DATA cTimestamp   as String // := FWTimeStamp( 3, ::__mbDATA, ::__mbHORA ) + "-00:00"
    DATA __cIat       as Integer // := Val( FWTimeStamp( 4, ::__mbDATA, ::__mbHORA ) )
    DATA __cExp       as Integer // := Val( FWTimeStamp( 4, ::__mbDATA, IncTime( ::__mbHORA , 0 , 40 , 0 ) ) )
    DATA cXBradNonce  as String // := cValToChar( Val(FWTimeStamp( 4, ::__mbDATA, ::__mbHORA )) * 1000 )
    DATA cAccessToken as String // := ""
    DATA numeroControleParticipante as String

    DATA cRetJson     as String

    method New() Constructor
    method efetivaPagamento()
    method consultaPagamento()

EndClass

Method New() class APIBradesco

    ::__cClientKey := CLIENT_KEY
    ::__mbDATA     := MsDate()
    ::__mbHORA     := Time()
    ::cTimestamp   := FWTimeStamp( 3, ::__mbDATA, ::__mbHORA ) + "-00:00"
    // ::__cIat       := Val( FWTimeStamp( 4, ::__mbDATA, ::__mbHORA ) )
    // ::__cExp       := Val( FWTimeStamp( 4, ::__mbDATA, IncTime( ::__mbHORA , 0 , 40 , 0 ) ) )
    // ::cXBradNonce  := cValToChar( Val(FWTimeStamp( 4, ::__mbDATA, ::__mbHORA )) * 1000 )

    ::__cIat       := FWTimeStamp( 4, ::__mbDATA, ::__mbHORA )
    ::__cExp       := FWTimeStamp( 4, ::__mbDATA, IncTime( ::__mbHORA , 0 , 40 , 0 ) )
    ::cXBradNonce  := cValToChar( Val(FWTimeStamp( 4, ::__mbDATA, ::__mbHORA )) * 1000 )

    ::numeroControleParticipante  := "0"
Return nil

Method efetivaPagamento() class APIBradesco

    Local lRet         := .T.
    Local cHeaderJson  := ""

    // DbSelectArea("SA6")
    // If ConPad1(, , , "SA6")

    // if AllTrim(aCpoRet[1]) == '237' // BRADESCO
    // Processa({|| U_fAPIBradesco() }, "Aguarde...")

    If SE2->E2_XTPAPI == 'A' // SubStr(cE2CODBAR,1,1) == '8'

        _cEndPoint := "Tributos"
        lRet := u_fArrecad( ::cAccessToken, ::cXBradNonce, ::cTimestamp, ::__cClientKey, @::cRetJson )

    ElseIf SE2->E2_XTPAPI == 'B' // Len(AllTrim(cE2CODBAR)) == 44 // BOLETO

        _cEndPoint := "Boletos"
        // 1o. GET /pagamentos/boleto/limites - Consulta Limites e HorÃ¡rios DisponÃ?veis para Pagamento
        // mtdLimites( cAccessToken )

        // 2o. POST /pagamentos/fboleto/validarDadosTitulo - Validar Dados do Titulo  - Bradesco  e/ou Outros Bancos
        lRet := mtdVldDados( ::cAccessToken, ::cXBradNonce, ::cTimestamp, @::cRetJson, @::numeroControleParticipante ) // cRetJson => PRECISO POIS É RETORNO DA CHAVE DO BANCO
        If lRet
            // 3o. POST /pagamentos/boleto/validarPagamento - Validar Dados para o Pagmento
            lRet := mtdVldPagamento( ::cAccessToken, ::cXBradNonce, ::cTimestamp, ::__cClientKey, @cHeaderJson, @::cRetJson, ::numeroControleParticipante )
            If lRet
                // 4o. POST /pagamentos/boleto/efetivarPagamento
                lRet := mtdEfetPagto( ::cAccessToken, ::cXBradNonce, ::cTimestamp, ::__cClientKey, cHeaderJson, @::cRetJson, ::numeroControleParticipante )
            EndIf
        EndIf

    ElseIf SE2->E2_XTPAPI == 'T' // TED - TRANSFERENCIA BANCARIA

        _cEndPoint := "TED"
        lRet := u_fTed( ::cAccessToken, ::cXBradNonce, ::cTimestamp, ::__cClientKey, @::cRetJson )

        // ElseIf SE2->E2_XTPAPI == 'P' // PIX

        //     _cEndPoint := "PIX"
        //     lRet := u_fPIX( ::cAccessToken, ::cXBradNonce, ::cTimestamp, ::__cClientKey, @::cRetJson )

    EndIf


    // elseif AllTrim(aCpoRet[1]) == '341' //ITAU
    //     MsgAlert("Itau")
    //
    // else // OUTRO
    //     MsgAlert("API nao implementada!")
    // endif

    // EndIF
    // SA6->(DBCLOSEAREA(  ))

    RecLock( "ZE2", .F.)
    ZE2->ZE2_XDTLIB := dDataBase
    ZE2->ZE2_XHRLIB := TIME()
    ZE2->ZE2_XUSULI := cUsername
    If lRet
        ZE2->ZE2_XSTAPI := "OK"
    Else
        ZE2->ZE2_XSTAPI := "ER"
    EndIf
    ZE2->(MsUnlock())

Return lRet

Static Function mtdToken( __cClientKey, __cIat, __cExp, cXBradNonce )
    Local cMetodo  := "token"
    Local oObj     := nil
    Local cToken   := geraTokenJsonBrad( __cClientKey, __cIat, __cExp, cXBradNonce )
    Local aHeadStr := {}, cPostRet := "", cPostParms := "", cHttpStat := "", nHttpCode := 0, cRet := ""
    // Local cHeadRet := "",

    AAdd(aHeadStr, "Content-Type: application/x-www-form-urlencoded")
    // If GetServerIP() == GetMV("MB_IP_DESV",,"192.168.0.170") .AND. SE2->E2_XTPAPI == "P"
    //     AAdd(aHeadStr, 'Authorization: cbb23aa6-4236-4f76-9951-e746d88b0e6c:f49703bb-1ad2-4faa-b09d-3d53cca2b826' )
    // EndIf

    cPostParms := "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer"
    cPostParms += "&assertion=" + Escape( cToken )
    MemoWrite( cPathLog + ( cPathFile := "01-mtdToken-01-Request.txt" ), cPostParms )
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    oRestClien := FwRest():New( cURLToken )
    oRestClien:SetPath( cMetodo )
    oRestClien:SetPostParams( EncodeUTF8(cPostParms, "cp1252") )
    Sleep( nSLEEP )

    lRet      := oRestClien:Post(aHeadStr)
    cPostRet  := oRestClien:GetResult()
    nHttpCode := HTTPGetStatus(@cHttpStat)

    If !FWJsonDeserialize( cPostRet, @oObj)
        Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else

        MemoWrite( cPathLog + ( cPathFile := "01-mtdToken-05-Resultado_Json.json" ),;
            ToJson( FromJson(cPostRet) ) )
        aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

        If  lRet := (lTrim(Str(nHttpCode)) $ cHttpVld) // Erro 500 se refere a ambiente instÃ¡vel //If  lRet := (nHttpCode == 200 .or. nHttpCode == 201 .or. nHttpCode == 500) // Erro 500 se refere a ambiente instÃ¡vel

            // oJSonRet:GetJsonValue("access_token", @cRet, @ckeyType)
            cRet := oObj:access_token // Alert( "Token Gerado com Sucesso" )
            MemoWrite( cPathLog + ( cPathFile := "01-mtdToken-06-ok-access_token.txt" ), cRet )
            aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

        Else
            if Empty( cPostRet )
                conout( "Fail HTTPSPost" )   // Alert( cHeadRet, "Header" )
            else
                Alert( cPostRet, "WebPage" ) // conout( "OK HTTPSPost" )
            endif
        endif
    EndIf
    Sleep( nSLEEP )

return cRet

/* MB : 28.09.2023
-> Gerar Token Criptografado, conforme manual do Bradesco. */
Static Function geraTokenJsonBrad( __cClientKey, __cIat, __cExp, cXBradNonce )
    Local HeaderJson      := JsonObject():New(), PayLoadJson := JsonObject():New()
    Local cod64HeaderJson := "", cod64PayLoadJson := "", cJWTToSign := "", cErrStr := ""
    Local sHashHex        := ""
    Local __cCertificado  := { "\certs\certPrivate.pem", "V@2025" }
    /*
        > openssl pkcs12 -clcerts -nodes -in privada.p12 -password pass:123456 -out privada.pem

        Convert DER to PEM ?? https://www.sslshopper.com/ssl-converter.html
        > openssl x509 -inform der -in certificate.cer -out certificate.pem
    */

    HeaderJson[ 'alg' ]   := "RS256"
    HeaderJson[ 'typ' ]   := "JWT"
    cod64HeaderJson       := HeaderJson:toJson()
    cod64HeaderJson       := fTratStr( cod64HeaderJson )

    // PayLoadJson[ 'typ' ] := "JWT"
    // PayLoadJson[ 'iss' ] := "Banco Bradesco"
    PayLoadJson[ 'aud' ]  := cURLToken + "token"
    PayLoadJson[ 'sub' ]  := __cClientKey
    PayLoadJson[ 'iat' ]  := __cIat
    PayLoadJson[ 'exp' ]  := __cExp
    PayLoadJson[ 'jti' ]  := cXBradNonce
    PayLoadJson[ 'ver' ]  := "1.1"
    cod64PayLoadJson      := PayLoadJson:toJson()

    MemoWrite( cPathLog + ( cPathFile := "00-geraTokenJsonBrad-01-PayLoadJson.json" ),;
        ToJson( FromJson( cod64PayLoadJson ) ) )
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    cod64PayLoadJson     := fTratStr( cod64PayLoadJson )
    MemoWrite( cPathLog + ( cPathFile := "00-geraTokenJsonBrad-02-PayLoadJson.txt" ), cod64PayLoadJson )
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    cJWTToSign := cod64HeaderJson + '.' + cod64PayLoadJson
    MemoWrite( cPathLog + ( cPathFile := "00-geraTokenJsonBrad-03-cJWTToSign.txt" ), cJWTToSign )
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    // If GetServerIP() == GetMV("MB_IP_DESV",,"192.168.0.170") .AND. SE2->E2_XTPAPI == "P"
    //     __cCertificado  := { "\certs\privada.pem", "123456" }
    // EndIf

    // Criptografia
    // sHashHex := SHA256( cJWTToSign )
    sHashHex := Encode64( EVPPrivSign( __cCertificado[1],; // < cPathKey  >
        cJWTToSign       ,; // < cContent  >
        5                ,; // < nTipo     >
        __cCertificado[2]         ,; // < cPassword >
        @cErrStr        ) )
    // sHashHex := Encode64( EVPPrivSign( __cCertificado[1], cJWTToSign, 5, __cCertificado[2], @cErrStr ) )
    sHashHex := Replace( sHashHex, "=", "" )
    sHashHex := Replace( sHashHex, "+", "-")
    sHashHex := Replace( sHashHex, "/", "_")
    cJWTToSign += '.' + sHashHex

    MemoWrite( cPathLog + ( cPathFile := "00-geraTokenJsonBrad-04-token-PayLoadJson-Cript.txt" ), cJWTToSign)
    // aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

Return cJWTToSign

/* MB : 02.10.2023 */
Static Function mtdVldDados( cAccessToken, cXBradNonce, cTimestamp, cRetJson, numeroControleParticipante )
    Local aArea         := GetArea()
    Local lRet          := .F.
    Local cMetodo       := "pagamentos/boleto/validarDadosTitulo"
    Local HeaderJson    := JsonObject():New(), oObj := JsonObject():new()
    Local aHeadStr      := {}, cPostRet := "", cPostParms := "", cHttpStat := "", nHttpCode := 0, cErrStr := "", cSignature := ''

    HeaderJson[ 'agencia' ]      := nAgBrad
    HeaderJson[ 'tipoEntrada' ]  := 1
    HeaderJson[ 'dadosEntrada' ] := cE2CODBAR // AllTrim(SE2->E2_CODBAR)
    cPostParms := HeaderJson:toJson()    // cPostParms := cValToChar( HeaderJson )
    MemoWrite( cPathLog + ( cPathFile := "02-validarDadosTitulo-01-HeaderJson.txt" ), cPostParms)
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    cSignature := 'POST' + _ENTER_ +;
        '/oapi/v1/'+ cMetodo + _ENTER_ +; // '/oapi/v1/pagamentos/boleto/validarDadosTitulo' + _ENTER_ +;
        _ENTER_ +;
        cPostParms   + _ENTER_ +;
        cAccessToken + _ENTER_ +;
        cXBradNonce  + _ENTER_ +;
        cTimestamp   + _ENTER_ +;
        'SHA256'
    MemoWrite( cPathLog + ( cPathFile := "02-validarDadosTitulo-02-cSignature.txt" ), cSignature)
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    cSignature := EncodeUTF8( cSignature )
    cSignature := Encode64( EVPPrivSign( "\certs\certPrivate.pem", cSignature, 5, "V@2025", @cErrStr ) )
    cSignature := Replace( cSignature, "/", "_")
    cSignature := Replace( cSignature, "+", "-")
    cSignature := Replace( cSignature, "=", "")
    MemoWrite( cPathLog + ( cPathFile := "02-validarDadosTitulo-03-cSignature-Cript.txt" ), cSignature)
    // aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    AAdd(aHeadStr, "Authorization: Bearer " + cAccessToken        )
    AAdd(aHeadStr, "X-Brad-Signature: "     + cSignature          )
    AAdd(aHeadStr, "X-Brad-Nonce: "         + cXBradNonce         )
    AAdd(aHeadStr, "X-Brad-Timestamp: "     + cTimestamp          )
    AAdd(aHeadStr, "X-Brad-Algorithm: "     + "SHA256"            )
    AAdd(aHeadStr, "Content-Type: application/json; charset=utf-8")
    AAdd(aHeadStr, "Accept: application/json, text/plain"         )
    MemoWrite( cPathLog + ( cPathFile := "02-validarDadosTitulo-04-aHeadStr.txt" ), StrTran( U_aToS(aHeadStr), '", "', _ENTER_ ))
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    oRestClien := FwRest():New( cURLBrad )
    oRestClien:SetPath( cMetodo )
    oRestClien:SetPostParams( cPostParms ) // oRestClien:SetPostParams( EncodeUTF8(cPostParms, "cp1252") )
    Sleep( nSLEEP )

    lRet      := oRestClien:Post(aHeadStr)
    cPostRet  := DecodeUTF8( oRestClien:GetResult() ) // oRestClien:GetResult()
    nHttpCode := HTTPGetStatus(@cHttpStat)

    If !FWJsonDeserialize( cPostRet, @oObj)
        Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else

        MemoWrite( cPathLog + ( cPathFile := "02-validarDadosTitulo-05-Resultado_Json.json" ),;
            ToJson( FromJson(cPostRet) ) )
        aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

        If  lRet := (lTrim(Str(nHttpCode)) $ cHttpVld) // Erro 500 se refere a ambiente instÃ¡vel
            cRetJson := Escape( cAccessToken /* oObj:access_token */ )

            If At( "NUMEROCONTROLEPARTICIPANTE", Upper(cPostRet) ) > 0 .AND. oObj:consultaFatorDataVencimentoResponse:consultaCIP=="S"
                numeroControleParticipante := oObj:consultaFatorDataVencimentoResponse:numeroControleParticipante
                // Alert ("numeroControleParticipante: " + numeroControleParticipante)
            EndIf

        Else
            MemoWrite( cPathLog + ( cPathFile := cPathFile := "02-validarDadosTitulo-05-Erro_nos_dados.json" ),;
                cPostRet )
        EndIf
    EndIf

    RestArea(aArea)
return lRet


/* MB : 22.11.2023 - 3o. POST /pagamentos/boleto/validarPagamento - Validar Dados para o Pagmento */
Static Function mtdVldPagamento( cAccessToken, cXBradNonce, cTimestamp, __cClientKey, cPostParms, cRetJson, numeroControleParticipante )

    Local cMetodo    := "pagamentos/boleto/validarPagamento"
    Local HeaderJson := JsonObject():New()
    Local oObj       := nil, nI := 0 //, oJson := JsonObject():New(), xRet := nil,
    Local aHeadStr   := {}, cPostRet := "", cHttpStat := "", nHttpCode := 0, cErrStr := "", cSignature := ''
    // Local cHeadRet := "", cPostParms := ""
    Local _XDTBXA    := MsDate()
    Local _XHRBXA    := Time()

    HeaderJson[ 'agencia' ]                                                               := nAgBrad
    HeaderJson[ 'pagamentoComumRequest' ]                                                 := JsonObject():New()
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ]                            := JsonObject():New()
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ][ 'agenciaContaDebitada' ]  := nAgBrad
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ][ 'bancoContaDebitada' ]    := 237 // cE2CODBAR
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ][ 'contaDebitada' ]         := nCtaDeb
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ][ 'digitoAgenciaDebitada' ] := nAgBradDig
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ][ 'digitoContaDebitada' ]   := nCtaDebDig

    HeaderJson[ 'pagamentoComumRequest' ][ 'dadosSegundaLinhaExtrato' ]                   := Val( DtoS( MsDate() ) )
    HeaderJson[ 'pagamentoComumRequest' ][ 'dataMovimento' ]                              := Val( DtoS( MsDate() ) )
    HeaderJson[ 'pagamentoComumRequest' ][ 'dataPagamento' ]                              := Val( DtoS( MsDate() ) )
    HeaderJson[ 'pagamentoComumRequest' ][ 'dataVencimento' ]                             := Val( DtoS( SE2->E2_VENCTO ) )
    HeaderJson[ 'pagamentoComumRequest' ][ 'horaTransacao' ]                              := StrTran( Time(), ":", "" )
    HeaderJson[ 'pagamentoComumRequest' ][ 'identificacaoTituloCobranca' ]                := cE2CODBAR // AllTrim(SE2->E2_CODBAR)
    HeaderJson[ 'pagamentoComumRequest' ][ 'indicadorFormaCaptura' ]                      := 1
    HeaderJson[ 'pagamentoComumRequest' ][ 'valorTitulo' ]                                := SE2->E2_VALLIQ // SE2->E2_VALOR // AllTrim( Transform( SE2->E2_VALOR, "999999999999.99") )

    HeaderJson[ 'destinatarioDadosComum' ]                                                := JsonObject():New()
    HeaderJson[ 'destinatarioDadosComum' ][ 'cpfCnpjDestinatario' ]                       := SA2->A2_CGC // ""

    HeaderJson[ 'identificacaoChequeCartao' ]                                             := 0
    HeaderJson[ 'indicadorValidacaoGravacao' ]                                            := 1 // "N"
    HeaderJson[ 'indicadorFuncao' ]                                                       := 1
    HeaderJson[ 'nomeCliente' ]                                                           := AllTrim(SE2->E2_NOMFOR)
    HeaderJson[ 'numeroControleParticipante' ]                                            := numeroControleParticipante

    HeaderJson[ 'portadorDadosComum' ]                                                    := JsonObject():New()
    HeaderJson[ 'portadorDadosComum' ][ 'cpfCnpjPortador' ]                               := "09358882000136" // definido email Eder 23.08.2024 // Val( SA2->A2_CGC ) // ""

    HeaderJson[ 'remetenteDadosComum' ]                                                   := JsonObject():New()
    HeaderJson[ 'remetenteDadosComum' ][ 'cpfCnpjRemetente' ]                             := ""

    HeaderJson[ 'valorMinimoIdentificacao' ]                                              := 0
    cPostParms := HeaderJson:toJson()

    MemoWrite( cPathLog + ( cPathFile := "03-validarPagamento-01-HeaderJson.json" ),;
        ToJson( FromJson(cPostParms) ) )
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    cSignature := 'POST' + _ENTER_ +;
        '/oapi/v1/'+ cMetodo + _ENTER_ +;
        _ENTER_ +;
        cPostParms   + _ENTER_ +;
        cAccessToken + _ENTER_ +;
        cXBradNonce  + _ENTER_ +;
        cTimestamp   + _ENTER_ +;
        'SHA256'
    MemoWrite( cPathLog + ( cPathFile := "03-validarPagamento-02-cSignature.txt" ), cSignature)
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    cSignature := EncodeUTF8( cSignature )
    cSignature := Encode64( EVPPrivSign( "\certs\certPrivate.pem", cSignature, 5, "V@2025", @cErrStr ) )
    cSignature := Replace( cSignature, "/", "_")
    cSignature := Replace( cSignature, "+", "-")
    cSignature := Replace( cSignature, "=", "")
    MemoWrite( cPathLog + ( cPathFile := "03-validarPagamento-03-cSignature-Cript.txt" ), cSignature)
    // aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    AAdd(aHeadStr, "Authorization: Bearer " + cAccessToken         )
    AAdd(aHeadStr, "X-Brad-Signature: "     + cSignature           )
    AAdd(aHeadStr, "X-Brad-Nonce: "         + cXBradNonce          )
    AAdd(aHeadStr, "X-Brad-Timestamp: "     + cTimestamp           )
    AAdd(aHeadStr, "X-Brad-Algorithm: "     + "SHA256"             )
    AAdd(aHeadStr, "Access-token: "         + __cClientKey         )
    AAdd(aHeadStr, "Content-Type: application/json; charset=utf-8" )
    AAdd(aHeadStr, "Accept: application/json, text/plain"          )
    MemoWrite( cPathLog + ( cPathFile := "03-validarPagamento-04-aHeadStr.txt" ),;
        StrTran( U_aToS(aHeadStr), '", "', _ENTER_ ))
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    oRestClien := FwRest():New( cURLBrad )
    oRestClien:SetPath( cMetodo )
    // oRestClien:SetPostParams( EncodeUTF8(cPostParms, "cp1252") )
    oRestClien:SetPostParams( cPostParms )
    Sleep( nSLEEP )

    lRet      := oRestClien:Post(aHeadStr)
    cPostRet  := DecodeUTF8( oRestClien:GetResult() ) // oRestClien:GetResult()
    nHttpCode := HTTPGetStatus(@cHttpStat)

    If !FWJsonDeserialize( cPostRet, @oObj)
        // xRet := oJson:FromJson( cPostRet ) //
        // If ValType(xRet) <> "U" // !Empty( xRet ) igual a cError
        Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else

        If At( "PAGAMENTOCOMUMRESPONSE", Upper(cPostRet) ) > 0 // ValType( oObj:PAGAMENTOCOMUMRESPONSE ) == "O" // oJson:HasProperty("pagamentoComumResponse")

            MemoWrite( cPathLog + ( cPathFile := "03-validarPagamento-05-Resultado_Json.json" ),;
                ToJson( FromJson(cPostRet) ) )
            aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

            If  lRet := (lTrim(Str(nHttpCode)) $ cHttpVld) // Erro 500 se refere a ambiente instÃ¡vel //If  lRet := (nHttpCode == 200 .or. nHttpCode == 201 .or. nHttpCode == 500) // Erro 500 se refere a ambiente instÃ¡vel
                cRetJson := cPostRet // DEU BOM
            Else

                MsgAlert( OemToAnsi(cPostRet), "Funcao: " + ProcName() + "retorno do Json: " + cPostRet )

            EndIf

        Else

            cMsg := ""
            If At( "ERROSVALIDACAO", Upper(cPostRet) ) > 0
                For nI := 1 to Len(oObj:ERROSVALIDACAO)
                    cMsg += "Campo: " + oObj:ERROSVALIDACAO[nI]:Campo + " - " + oObj:ERROSVALIDACAO[nI]:Mensagem + _ENTER_
                Next nI

            ElseIf At( "CODIGO", Upper(cPostRet) ) > 0 .and. At( "MENSAGEM", Upper(cPostRet) ) > 0
                cMsg += "Campo: " + oObj:Codigo + " - " + oObj:Mensagem + _ENTER_
            EndIf

            // Alert( "Metodo: validarPagamento, API: Boleto, TAG [pagamentoComumResponse] nao localizada no retorno do Json: " + cPostRet )
            Alert( "ERRO RETORNADO no Metodo: validarPagamento: " + _ENTER_ + _ENTER_ + cMsg)
            lRet := .F.

            // --------------------------------------------------------------------------------------------------------------------
            // atualizar ZE2 antes de criar a proxima
            RecLock("ZE2", .F. )
            ZE2->ZE2_XSTAPI := "ER"
            ZE2->ZE2_XDTAPI := dDataBase
            ZE2->ZE2_XHRAPI := TIME()
            ZE2->ZE2_JSNENV := ToJson( FromJson(cPostParms) )
            ZE2->ZE2_XLOGIN := iIf(Empty(ZE2->ZE2_XLOGIN),"", AllTrim(ZE2->ZE2_XLOGIN) + (Chr(13)+Chr(10)) + (Chr(13)+Chr(10)) ) +;
                cPostRet
            ZE2->ZE2_METODO := "[BOLETO]/" + cMetodo
            ZE2->(MsUnlock())

            _XDTBXA := ZE2->ZE2_XDTBXA
            _XHRBXA := ZE2->ZE2_XHRBXA

            // --------------------------------------------------------------------------------------------------------------------
            // Criar ZE2 para registro do erro
            RecLock("ZE2", .T. )
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

            ZE2->ZE2_VLRPAG := SE2->E2_VALLIQ // SE2->E2_VALOR // SE2->E2_VALOR
            ZE2->ZE2_XDTAPI := dDataBase
            ZE2->ZE2_XHRAPI := TIME()
            ZE2->ZE2_JSNENV := ToJson( FromJson(cPostParms) )
            ZE2->ZE2_XLOGIN := iIf(Empty(ZE2->ZE2_XLOGIN),"", AllTrim(ZE2->ZE2_XLOGIN) + (Chr(13)+Chr(10)) + (Chr(13)+Chr(10)) ) +;
                cPostRet
            ZE2->ZE2_METODO := "[BOLETO]/" + cMetodo
            // If  lRet
            //     __cChvRet := cValToChar( oObj:numeroProtocoloCBCA )
            //     ZE2->ZE2_XCHVRE := __cChvRet // chave retornada pela API BRADESCO - RETORNO API
            // EndIf
            ZE2->(MsUnlock())

            MemoWrite( cPathLog + ( cPathFile := cPathFile := "03-validarPagamento-05-Erro.json" ),;
                cPostRet ) // formatar Json, formater json
            aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

        EndIf
    EndIf
return lRet


/* MB : 23.11.2023 */
Static Function mtdEfetPagto( cAccessToken, cXBradNonce, cTimestamp, __cClientKey, cPostParms, cRetJson, numeroControleParticipante )
    Local aArea      := GetArea()
    Local cMetodo    := "pagamentos/boleto/efetivarPagamento"
    Local HeaderJson := JsonObject():New()
    Local oObj       := nil // oJson      := JsonObject():New(), xRet := nil
    Local aHeadStr   := {}, cPostRet := "", cHttpStat := "", nHttpCode := 0, cErrStr := "", cSignature := ''
    // Local cHeadRet := "", cPostParms := "",
    // Local lInclui    := !ZE2->ZE2_XSTAPI $ ("BX,ER")
    Local lInclui    := !ZE2->ZE2_XSTAPI $ ("BX")
    Local _XDTBXA    := MsDate()
    Local _XHRBXA    := Time()

    HeaderJson[ 'agencia' ]                                                               := nAgBrad
    HeaderJson[ 'pagamentoComumRequest' ]                                                 := JsonObject():New()
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ]                            := JsonObject():New()
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ][ 'agenciaContaDebitada' ]  := nAgBrad
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ][ 'bancoContaDebitada' ]    := 237 // cE2CODBAR
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ][ 'contaDebitada' ]         := nCtaDeb
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ][ 'digitoAgenciaDebitada' ] := nAgBradDig
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ][ 'digitoContaDebitada' ]   := nCtaDebDig

    HeaderJson[ 'pagamentoComumRequest' ][ 'dadosSegundaLinhaExtrato' ]                   := Val( DtoS( MsDate() ) )
    HeaderJson[ 'pagamentoComumRequest' ][ 'dataMovimento' ]                              := Val( DtoS( MsDate() ) )
    HeaderJson[ 'pagamentoComumRequest' ][ 'dataPagamento' ]                              := Val( DtoS( MsDate() ) )
    HeaderJson[ 'pagamentoComumRequest' ][ 'dataVencimento' ]                             := Val( DtoS( SE2->E2_VENCTO ) )
    HeaderJson[ 'pagamentoComumRequest' ][ 'horaTransacao' ]                              := StrTran( Time(), ":", "" )
    HeaderJson[ 'pagamentoComumRequest' ][ 'identificacaoTituloCobranca' ]                := cE2CODBAR // AllTrim(SE2->E2_CODBAR)
    HeaderJson[ 'pagamentoComumRequest' ][ 'indicadorFormaCaptura' ]                      := 1
    HeaderJson[ 'pagamentoComumRequest' ][ 'valorTitulo' ]                                := SE2->E2_VALLIQ // SE2->E2_VALOR // AllTrim( Transform( SE2->E2_VALOR, "999999999999.99") )

    HeaderJson[ 'destinatarioDadosComum' ]                                                := JsonObject():New()
    HeaderJson[ 'destinatarioDadosComum' ][ 'cpfCnpjDestinatario' ]                       := SA2->A2_CGC // ""

    // HeaderJson[ 'identificacaoChequeCartao' ]                                             := 0
    // HeaderJson[ 'indicadorValidacaoGravacao' ]                                            := 1 // "N"
    HeaderJson[ 'indicadorFuncao' ]                                                       := 1
    HeaderJson[ 'nomeCliente' ]                                                           := AllTrim(SE2->E2_NOMFOR)
    HeaderJson[ 'numeroControleParticipante' ]                                            := numeroControleParticipante

    HeaderJson[ 'portadorDadosComum' ]                                                    := JsonObject():New()
    HeaderJson[ 'portadorDadosComum' ][ 'cpfCnpjPortador' ]                               := "09358882000136" // definido email Eder 23.08.2024 // Val( SA2->A2_CGC ) // ""

    HeaderJson[ 'remetenteDadosComum' ]                                                   := JsonObject():New()
    HeaderJson[ 'remetenteDadosComum' ][ 'cpfCnpjRemetente' ]                             := ""

    HeaderJson[ 'valorMinimoIdentificacao' ]                                              := 0
    HeaderJson[ 'transactionId' ]                                                         := SE2->(Recno())
    cPostParms := HeaderJson:toJson()

    MemoWrite( cPathLog + ( cPathFile := "04-efetivarPagamento-01-HeaderJson.json" ),;
        ToJson( FromJson(cPostParms) ) )
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    cSignature := 'POST' + _ENTER_ +;
        '/oapi/v1/'+ cMetodo + _ENTER_ +;
        _ENTER_ +;
        cPostParms   + _ENTER_ +;
        cAccessToken + _ENTER_ +;
        cXBradNonce  + _ENTER_ +;
        cTimestamp   + _ENTER_ +;
        'SHA256'
    MemoWrite( cPathLog + ( cPathFile := "04-efetivarPagamento-02-cSignature.txt" ), cSignature)
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    cSignature := EncodeUTF8( cSignature )
    cSignature := Encode64( EVPPrivSign( "\certs\certPrivate.pem", cSignature, 5, "V@2025", @cErrStr ) )
    cSignature := Replace( cSignature, "/", "_")
    cSignature := Replace( cSignature, "+", "-")
    cSignature := Replace( cSignature, "=", "")
    MemoWrite( cPathLog + ( cPathFile := "04-efetivarPagamento-03-cSignature-Cript.txt" ), cSignature)
    // aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    AAdd(aHeadStr, "Authorization: Bearer " + cAccessToken         )
    AAdd(aHeadStr, "X-Brad-Signature: "     + cSignature           )
    AAdd(aHeadStr, "X-Brad-Nonce: "         + cXBradNonce          )
    AAdd(aHeadStr, "X-Brad-Timestamp: "     + cTimestamp           )
    AAdd(aHeadStr, "X-Brad-Algorithm: "     + "SHA256"             )
    AAdd(aHeadStr, "Access-token: "         + __cClientKey         )
    AAdd(aHeadStr, "Content-Type: application/json; charset=utf-8" )
    AAdd(aHeadStr, "Accept: application/json, text/plain"          )
    MemoWrite( cPathLog + ( cPathFile := "04-efetivarPagamento-04-aHeadStr.txt" ), StrTran( U_aToS(aHeadStr), '", "', _ENTER_ ))
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    oRestClien := FwRest():New( cURLBrad )
    oRestClien:SetPath( cMetodo )
    oRestClien:SetPostParams( cPostParms ) // oRestClien:SetPostParams( EncodeUTF8(cPostParms, "cp1252") )
    Sleep( nSLEEP )

    lRet      := oRestClien:Post(aHeadStr)
    cPostRet  := DecodeUTF8( oRestClien:GetResult() ) // oRestClien:GetResult()
    nHttpCode := HTTPGetStatus(@cHttpStat)

    If !FWJsonDeserialize( cPostRet, @oObj) // xRet := oJson:FromJson( cPostRet )
        // If ValType(xRet) <> "U" // !Empty( xRet ) igual a cError
        Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else

        cRetJson := cPostRet := ToJson( FromJson(cPostRet) ) // ToJson( FromJson(cPostRet) ) // formatar Json, formater json

        If At( "CODIGO", Upper(cPostRet) ) > 0 .and. At( "MENSAGEM", Upper(cPostRet) ) > 0  // At( "-99", Upper(cPostRet) ) > 0
            // MsgAlert( OemToAnsi(cPostRet), "Funcao: " + ProcName() + "retorno do Json: " + cPostRet )
            lInclui := .T.
        EndIf

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
            ZE2->ZE2_METODO := "[BOLETO]/" + cMetodo
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
        ZE2->ZE2_METODO := "[BOLETO]/" + cMetodo
        If  lRet
            __cChvRet := cValToChar( oObj:numeroProtocoloCBCA )
            ZE2->ZE2_XCHVRE := __cChvRet // chave retornada pela API BRADESCO - RETORNO API
        EndIf
        ZE2->(MsUnlock())
    EndIf

    MemoWrite( cPathLog + ( cPathFile := cPathFile := "04-efetivarPagamento-05-Resultado_Json.json" ),;
        cPostRet ) // formatar Json, formater json
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    RestArea( aArea )
return lRet
// FIM: mtdEfetPagto

Static Function fTratStr( cTexto )
    cTexto := EncodeUTF8( cTexto )
    cTexto := Encode64( cTexto )
    cTexto := Replace( cTexto, " ", "" )
    cTexto := Replace( cTexto, "\", "-" )
    cTexto := Replace( cTexto, "/", "-" )
    cTexto := Replace( cTexto, "=", "" )
Return cTexto

User Function RemoveAcento(cString)
    cRetorno := StrTran( cString, "Ã", "A")
    cRetorno := StrTran( cString, "Ã¡", "a")
    cRetorno := StrTran( cString, "Ã?", "A")
    cRetorno := StrTran( cString, "Ã ", "a")
    cRetorno := StrTran( cString, "Ã£", "a")
    cRetorno := StrTran( cString, "Ã¢", "a")
    cRetorno := StrTran( cString, "Ã‰", "E")
    cRetorno := StrTran( cString, "Ã©", "e")
    cRetorno := StrTran( cString, "Ãˆ", "E")
    cRetorno := StrTran( cString, "Ã¨", "e")
    cRetorno := StrTran( cString, "ÃŒ", "I")
    cRetorno := StrTran( cString, "Ã¬", "i")
    cRetorno := StrTran( cString, "Ã", "I")
    cRetorno := StrTran( cString, "Ã?", "i")
    cRetorno := StrTran( cString, "Ã•", "O")
    cRetorno := StrTran( cString, "Ãµ", "o")
    cRetorno := StrTran( cString, "Ãœ", "U")
    cRetorno := StrTran( cString, "Ã?", "u")
Return cRetorno


// User Function statusfAPIBradesco()
Method consultaPagamento() class APIBradesco

    // Local HeaderJson := JsonObject():New()
    Local oRestClien := nil
    Local cSignature := "", aHeadStr := {}, cPostRet := ""
    Local cMetodo    := "", cGetParams := "", cErrStr := "", cHttpStat := "", nHttpCode := 0
    // cPostRet := "",
    Local cAux       := ""
    Local lRet, cRet
    Local oObj       := nil

    If SubStr(cE2CODBAR,1,1) == '8'
    ElseIf Len(AllTrim(cE2CODBAR)) == 44 // BOLETO
    Else // TED - TRANSFERENCIA BANCARIA

        cMetodo    := "transferencia/consulta"
        // cGetParams := "numeroDocumento=" + cValToChar( SE2->(Recno()) ) +;
        cGetParams := "numeroDocumento=" + SubS(cAux:=ZE2->ZE2_XCHVRE, 1, 7) +;
            "&dataOperacao="   + Transform(DToC( ZE2->ZE2_XDTAPI ),"@R 99.99.9999")

        cSignature := 'GET' + _ENTER_ +;
            '/v1/'+ cMetodo + _ENTER_ +;
            cGetParams + _ENTER_ +;
            _ENTER_ +;
            ::cAccessToken + _ENTER_ +;
            ::cXBradNonce  + _ENTER_ +;
            ::cTimestamp   + _ENTER_ +;
            'SHA256'
        MemoWrite( cPathLog + ( cPathFile := cPathFile := "get_consulta-01-RequestSignature.txt" ), cSignature)
        aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

        cSignature := EncodeUTF8( cSignature )
        cSignature := EVPPrivSign( "\certs\certPrivate.pem", cSignature, 5, "V@2025", @cErrStr )
        cSignature := Encode64( cSignature )
        cSignature := Replace( cSignature, " ", "" )
        cSignature := Replace( cSignature, "=", "" )
        cSignature := Replace( cSignature, "+", "-")
        cSignature := Replace( cSignature, "/", "_")
        MemoWrite( cPathLog + ( cPathFile := "get_consulta-02-RequestSignatureSHA256.txt" ), cSignature)
        // aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

        AAdd(aHeadStr, "Authorization: "    + "Bearer " + ::cAccessToken )
        AAdd(aHeadStr, "X-Brad-Nonce: "     + ::cXBradNonce              )
        AAdd(aHeadStr, "X-Brad-Signature: " + cSignature                 )
        AAdd(aHeadStr, "X-Brad-Timestamp: " + ::cTimestamp               )
        AAdd(aHeadStr, "X-Brad-Algorithm: " + "SHA256"                   )
        AAdd(aHeadStr, "access-token: "     + CLIENT_KEY                 )
        AAdd(aHeadStr, "idUsuario: "        + "I922061"                  )
        AAdd(aHeadStr, "senha: "            + "trba2010"                 )
        AAdd(aHeadStr, "Content-Type: application/json; charset=utf-8"   )
        AAdd(aHeadStr, "Accept: application/json, text/plain"            )

        MemoWrite( cPathLog + ( cPathFile := "get_consulta-03-RequestHeader.txt" ),;
            StrTran( StrTran( StrTran( StrTran( U_aToS(aHeadStr), '", "', _ENTER_ ),'{ "', ""), '" }', ""),': ', ":") )
        aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

        oRestClien := FwRest():New( cURLTED )
        oRestClien:SetPath( cMetodo ) // consulta Pagamento
        oRestClien:SetGetParams( cGetParams )
        Sleep( nSLEEP )

    EndIf

    lRet      := oRestClien:Get(aHeadStr)
    cPostRet  := oRestClien:GetResult()
    nHttpCode := HTTPGetStatus(@cHttpStat)

    // CONSULTA
    If !FWJsonDeserialize( cPostRet, @oObj)
        // xRet := oJson:FromJson( cPostRet ) //
        // If ValType(xRet) <> "U" // !Empty( xRet ) igual a cError
        Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else

        RecLock( 'ZE2', .T. )
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
        // ZE2->ZE2_XDTBXA := dDataBase
        // ZE2->ZE2_XHRBXA := TIME()
        ZE2->ZE2_VLRPAG := SE2->E2_VALOR // SE2->E2_VALOR

        ZE2->ZE2_XDTAPI := dDataBase
        ZE2->ZE2_XHRAPI := TIME()
        ZE2->ZE2_JSNENV := ToJson( FromJson(cPostRet) )
        ZE2->ZE2_XCHVRE := cAux // chave retornada pela API BRADESCO - RETORNO API

        If  lRet := (lTrim(Str(nHttpCode)) $ cHttpVld) // Erro 500 se refere a ambiente instÃ¡vel
            cRet := "Sucesso: " + _ENTER_
            ZE2->ZE2_XSTAPI := "CO" // CO=Retorno Consulta OK;
        Else
            cRet := "Erro: " + _ENTER_
            ZE2->ZE2_XSTAPI := "CE" // CE=Retorno Consulta Erro;
        EndIf

        ZE2->ZE2_XLOGIN := iIf(Empty(ZE2->ZE2_XLOGIN),"", AllTrim(ZE2->ZE2_XLOGIN) + (Chr(13)+Chr(10)) + (Chr(13)+Chr(10)) ) +;
            cRet + (cPostRet := ToJson( FromJson(cPostRet) ) )
        ZE2->ZE2_METODO := "[CONSULTA]/" + cMetodo

        ZE2->(MsUnLock())

    EndIf

    MemoWrite( cPathLog + ( cPathFile := "TED-consultaFinal.txt" ),  ZE2->ZE2_XLOGIN /* cPostRet */ )
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    Alert( ZE2->ZE2_XLOGIN /* cRet + cPostRet */ )
    FreeObj(oRestClien)

Return


/* MB : 28.09.2023 */
/*
Static Function mtdLimites( cAccessToken )
    Local cMetodo       := "/pagamentos/boleto/limites"
    Local aHeadStr      := {}, cHeadRet := "", cPostRet := "", cPostParms := "", cHttpStat := "", nHttpCode := 0, cErrStr := "", cSignature := ''

    AAdd(aHeadStr, "Accept: application/json; charset=utf-8")
    AAdd(aHeadStr, "grant_type: urn:ietf:params:oauth:grant-type:jwt-bearer")
    AAdd(aHeadStr, "assertion: " + cAccessToken)

    cGETParms := "agencia="               + 'nAgBrad'
    cGETParms += "&bancoCliente="         + '237'
    cGETParms += "&agenciaCliente="       + 'nAgBrad'
    cGETParms += "&digitoAgenciaCliente=" + "'0'"
    cGETParms += "&contaCliente="         + 'nCtaDeb'
    cGETParms += "&digitoContaCliente="   + "'5'"
    cGETParms := Escape(cGETParms)

    cPostRet := HTTPSGet( cURLToken+cMetodo ,; // 01 // < cURL >
        "\certs\000001_all.pem",; // 02 // < cCertificate > // OU 000001_all
        "\certs\000001_key.pem",; // 03 // < cPrivKey >     // 000001_key chave privada
        "V@2025"               ,; // 04 // < cPassword >
        EncodeUTF8(cGETParms ) ,; // 05 // [ cGETParms ]
        nTimeOut               ,; // 06 // [ nTimeOut ]
        aHeadStr               ,; // 07 // [ aHeadStr ]
        @cHeadRet               ) // 08 // [ @cHeaderRet ]
    // HTTPSGet( < cURL >, < cCertificate >, < cPrivKey >, < cPassword >, [ cGETParms ], [ nTimeOut ], [ aHeadStr ], [ @cHeaderRet ], [ lClient ] )

    If !FWJsonDeserialize( cPostRet, @oObj)
        Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else
        nHttpCode := HTTPGetStatus(@cHttpStat)
        If  nHttpCode == 200 .or. nHttpCode == 201 .or. nHttpCode == 500 // Erro 500 se refere a ambiente instÃ¡vel
            Alert( "Token Gerado com Sucesso" )
            cRet := oObj:access_token
        Else
            if Empty( cPostRet )
                conout( "Fail HTTPSPost" )
                // Alert( cHeadRet, "Header" )
            else
                // conout( "OK HTTPSPost" )
                Alert( cPostRet, "WebPage" )
            endif
        endif
    EndIf
Return
*/

/*
BIBLIOTECA

Sites enviados pela viviane, executar processo fora do protheus:
1.
https://www.timestamp-converter.com
2.
https://jwt.io
3.
3.1 - https://jsonformatter.org
3.2 - https://jsonformatter.curiousconcept.com/#


-> Converter certificado pfx para PEM
        https://www.sslshopper.com/ssl-converter.html


## Soma Hora
    - IncTime( cTime , 10 , 10 , 10 )
    - SomaHoras( <nHr1> , <nHr2> )
        * https://www.helpfacil.com.br/FORUM/display_topic_threads.asp?ForumID=1&TopicID=629

## FWTimeStamp
    * https://tdn.totvs.com/display/public/framework/FWTimeStamp
    * https://terminaldeinformacao.com/knowledgebase/fwtimestamp/

## HttpsPost
    * https://tdn.totvs.com/display/tec/HTTPSPost


## FUNCOES JSON
    -> https://tdn.totvs.com/display/tec/JsonObject%3AGetJsonObject
    -> https://tdn.totvs.com/pages/viewpage.action?pageId=553334696

// Acrescenta o UserAgent na requisicao ...
// http://tools.ietf.org/html/rfc3261#page-179

    https://jwt.io/
    https://www.timestamp-converter.com/

*/

User Function fArrecad( cAccessToken, cXBradNonce, cTimestamp, __cClientKey, cRetJson )
    Local aArea      := GetArea()
    Local HeaderJson := JsonObject():New()
    Local cMetodo    := "pagamentos/pagamentoContaConsumo"
    Local aHeadStr   := {}, cPostRet := "", cPostParms := "", cHttpStat := "", nHttpCode := 0, cErrStr := "", cSignature := ''
    Local oObj       := nil // oJson      := JsonObject():New(), xRet := nil
    Local lRet       := .T. // cRet       := ""
    // Local lInclui    := !ZE2->ZE2_XSTAPI $ ("BX,ER")
    Local lInclui    := !ZE2->ZE2_XSTAPI $ ("BX")
    Local _XDTBXA    := MsDate()
    Local _XHRBXA    := Time()

    HeaderJson[ 'codigoBarras']     := cE2CODBAR
    HeaderJson[ 'agencia' ]         := nAgBrad // rTrim(aCpoRet[2])
    HeaderJson[ 'digitoAgencia' ]   := nAgBradDig // 0 // AllTrim(Posicione("SA6",1,FWxFilial("SA6")+aCpoRet[1]+rTrim(aCpoRet[2])+rTrim(aCpoRet[3]),"A6_DVAGE"))
    HeaderJson[ 'conta' ]           := nCtaDeb // rTrim(aCpoRet[3])
    HeaderJson[ 'digitoConta' ]     := nCtaDebDig // 5 // AllTrim(SA6->A6_DVCTA) // Posicione("SA6",1,FWxFilial("SA6")+aCpoRet[1]+rTrim(aCpoRet[2])+rTrim(aCpoRet[3]),"A6_DVCTA"))
    HeaderJson[ 'dataDebito' ]      := Transform(DToS( MsDate() ),"@R 9999-99-99") // Transform(DtoS( SE2->E2_EMISSAO ),"@R 9999-99-99") // Transform(DtoS(Date()),"@R 9999-99-99")
    HeaderJson[ 'idTransacao' ]     := SE2->(Recno()) // DEFINIR FORMATO DE ID E QUAL CAMPO IRÃ GRAVAR
    HeaderJson[ 'tipoConta' ]       := "1" // "CC"
    HeaderJson[ 'tipoRegistro' ]    := "1"
    HeaderJson[ 'valorPrincipal' ]  := SE2->E2_VALOR
    cPostParms := HeaderJson:toJson()

    MemoWrite( cPathLog + ( cPathFile := "02-pagamentoContaConsumo-01-HeaderJson.json" ),;
        ToJson( FromJson(cPostParms) ) )
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    cSignature := 'POST' + _ENTER_ +;
        '/oapi/v1/'+ cMetodo + _ENTER_ +; // '/oapi/v1/pagamentos/boleto/validarDadosTitulo' + _ENTER_ +;
        _ENTER_ +;
        cPostParms   + _ENTER_ +;
        cAccessToken + _ENTER_ +;
        cXBradNonce  + _ENTER_ +;
        cTimestamp   + _ENTER_ +;
        'SHA256'
    MemoWrite( cPathLog + ( cPathFile := "02-pagamentoContaConsumo-02-cSignature.txt" ), cSignature)
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    cSignature := EncodeUTF8( cSignature )
    cSignature := Encode64( EVPPrivSign( "\certs\certPrivate.pem", cSignature, 5, "V@2025", @cErrStr ) )
    cSignature := Replace( cSignature, "/", "_")
    cSignature := Replace( cSignature, "+", "-")
    cSignature := Replace( cSignature, "=", "")
    MemoWrite( cPathLog + ( cPathFile := "02-pagamentoContaConsumo-03-cSignature-Cript.txt" ), cSignature)
    // aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    AAdd(aHeadStr, "Authorization: Bearer " + cAccessToken        )
    AAdd(aHeadStr, "X-Brad-Signature: "     + cSignature          )
    AAdd(aHeadStr, "X-Brad-Nonce: "         + cXBradNonce         )
    AAdd(aHeadStr, "X-Brad-Timestamp: "     + cTimestamp          )
    AAdd(aHeadStr, "X-Brad-Algorithm: "     + "SHA256"            )
    AAdd(aHeadStr, "Access-token: "         + __cClientKey         )
    AAdd(aHeadStr, "Content-Type: application/json; charset=utf-8" )
    AAdd(aHeadStr, "Accept: application/json, text/plain"          )

    MemoWrite( cPathLog + ( cPathFile := "02-pagamentoContaConsumo-04-aHeadStr.txt" ), StrTran( U_aToS(aHeadStr), '", "', _ENTER_ ))
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    oRestClien := FwRest():New( cURLBrad )
    oRestClien:SetPath( cMetodo )
    oRestClien:SetPostParams( EncodeUTF8(cPostParms, "cp1252") )
    Sleep( nSLEEP )

    lRet      := oRestClien:Post(aHeadStr)
    cPostRet  := DecodeUTF8( oRestClien:GetResult() ) // oRestClien:GetResult()
    nHttpCode := HTTPGetStatus(@cHttpStat)

    If !FWJsonDeserialize( cPostRet, @oObj) // xRet := oJson:FromJson( cPostRet )
        // If ValType(xRet) <> "U" // !Empty( xRet ) igual a cError
        Alert( "Falha na estrutura do JSON de Retorno. Json: " + cPostRet) //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else

        cRetJson := cPostRet := ToJson( FromJson(cPostRet) ) // ToJson( FromJson(cPostRet) ) // formatar Json, formater json

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
            ZE2->ZE2_METODO := "[IMPOSTOS]/" + cMetodo
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
        ZE2->ZE2_METODO := "[IMPOSTOS]/" + cMetodo
        If lRet
            __cChvRet := cValToChar( oObj:autenticacaoBancaria )
            ZE2->ZE2_XCHVRE := __cChvRet // oObj:chaveUnicaParaApi // oJson["chaveUnicaParaApi"] // chave retornada pela API BRADESCO - RETORNO API
        EndIf
        ZE2->(MsUnlock())

        // Alert(iIf(lRet, "Sucesso: ", "Erro: ") + _ENTER_ + cPostRet )
    EndIf

    MemoWrite( cPathLog + ( cPathFile := cPathFile := "02-pagamentoContaConsumo-05-Resultado_Json.json" ),;
        cPostRet ) // formatar Json, formater json
    aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

    RestArea( aArea )
Return lRet

//Layout de Comunicacao de Consulta - Entrada
// User Function fConsTed(cAccessToken, cXBradNonce, cTimestamp, cRetJson)
//     Local HeaderJson    := JsonObject():New(), oObj := nil
//     Local cMetodo       := "transferencia/efetiva"
//     Local aHeadStr      := {}, cPostRet := "", cPostParms := "", cHttpStat := "", nHttpCode := 0, cErrStr := "", cSignature := ''
//
//     HeaderJson[ 'numeroDocumento' ] := SE2->(Recno())
//     HeaderJson[ 'dataOperacao' ]    := Transform(DToC( MsDate() ),"@R 99-99-9999")
//
//     cSignature := 'POST' + _ENTER_ +;
//         '/oapi/v1/'+ cMetodo + _ENTER_ +; // '/oapi/v1/pagamentos/boleto/validarDadosTitulo' + _ENTER_ +;
//         _ENTER_ +;
//         cPostParms   + _ENTER_ +;
//         cAccessToken + _ENTER_ +;
//         cXBradNonce  + _ENTER_ +;
//         cTimestamp   + _ENTER_ +;
//         'SHA256'
//     MemoWrite( cPathLog + ( cPathFile := "02-validarDadosTitulo-01-RequestSignature.txt", cSignature)
//
//     cSignature := EncodeUTF8( cSignature )
//     cSignature := Encode64( EVPPrivSign( "\certs\certPrivate.pem", cSignature, 5, "V@2025", @cErrStr ) )
//     cSignature := Replace( cSignature, "/", "_")
//     cSignature := Replace( cSignature, "+", "-")
//     cSignature := Replace( cSignature, "=", "")
//     MemoWrite( cPathLog + ( cPathFile := "02-validarDadosTitulo-02-RequestSignatureSHA256.txt", cSignature)
//
//     AAdd(aHeadStr, "Authorization: Bearer " + cAccessToken       )
//     AAdd(aHeadStr, "X-Brad-Signature: "     + cSignature         )
//     AAdd(aHeadStr, "X-Brad-Nonce: "         + cXBradNonce        )
//     AAdd(aHeadStr, "X-Brad-Timestamp: "     + cTimestamp         )
//     AAdd(aHeadStr, "X-Brad-Algorithm: "     + "SHA256"           )
//
//     AAdd(aHeadStr, "cpfCnpj: "              + '038052160005701'  ) /* SM0->M0_CGC */
//     AAdd(aHeadStr, "access-token: "         + cAccessToken       )
//     AAdd(aHeadStr, "Content-Type: application/json; charset=utf-8"              )
//     AAdd(aHeadStr, "Accept: application/json, text/plain"        )
//     MemoWrite( cPathLog + ( cPathFile := "02-validarDadosTitulo-03-RequestHeader.txt", StrTran( U_aToS(aHeadStr), '", "', _ENTER_ ))
//
//     oRestClien := FwRest():New( cURLBrad )
//     oRestClien:SetPath( cMetodo )
//     oRestClien:SetPostParams( EncodeUTF8(cPostParms, "cp1252") )
//
//     lRet      := oRestClien:Post(aHeadStr)
//     cPostRet  := oRestClien:GetResult()
//     nHttpCode := HTTPGetStatus(@cHttpStat)
//
//     If !FWJsonDeserialize( cPostRet, @oObj)
//         Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
//     Else
//         If  lRet := (lTrim(Str(nHttpCode)) $ cHttpVld) // Erro 500 se refere a ambiente instÃ¡vel
//             cRetJson := cPostRet
//         Else
//
//             reclock("SE2",.F.)
//             SE2->E2_XSTATUS := '1'
//             SE2->(MSUNLOCK())
//         EndIf
//     EndIf
//
// Return
//Layout de Comunicacao Efetiva - Entrada


User Function fTed( cAccessToken, cXBradNonce, cTimestamp, __cClientKey, cRetJson )

    Local aArea      := GetArea()
    Local HeaderJson := JsonObject():New()
    Local cMetodo    := "transferencia/efetiva"
    Local aHeadStr   := {}, cPostParms := "", cErrStr := "", cSignature := '' , cHttpStat := "", cPostRet := "", nHttpCode := 0
    Local oObj       := nil // oJson      := JsonObject():New(), xRet := nil
    Local lRet       := .F. // cRet       := ""
    // Local lInclui    := !ZE2->ZE2_XSTAPI $ ("BX,ER")
    Local lInclui    := !ZE2->ZE2_XSTAPI $ ("BX")
    Local _XDTBXA    := MsDate()
    Local _XHRBXA    := Time()

    // If Empty(SA2->A2_BANCO) .OR. Empty(SA2->A2_AGENCIA) .OR. Empty(SA2->A2_NUMCON)
    If Empty(SE2->E2_FORBCO) .OR. Empty(SE2->E2_FORAGE) .OR. Empty(SE2->E2_FORCTA)
        Alert("Nao existem dados de Conta, Agencia ou Banco cadastrados para esse fornecedor. Verifique o cadastro de Fornecedores!")
    Else

        HeaderJson[ "identificadorDoTipoDeTransferencia" ] := 1
        HeaderJson[ "agenciaRemetente" ]                   := nAgBrad // 2856
        HeaderJson[ "contaRemetenteComDigito" ]            := Val( cValToChar(nCtaDeb) + cValToChar(nCtaDebDig) ) // 500356
        HeaderJson[ "tipoContaRemetente" ]                 := "CC"
        HeaderJson[ "tipoDePessoaRemetente" ]              := "J"

        HeaderJson[ "bancoDestinatario" ]                  := Val( SE2->E2_FORBCO ) // Val( SA2->A2_BANCO ) // 341
        HeaderJson[ "agenciaDestinatario" ]                := Val( SE2->E2_FORAGE ) // Val( SA2->A2_AGENCIA ) // 6234
        HeaderJson[ "contaDestinatario" ]                  := Val( AllTrim(SE2->E2_FORCTA)/* AllTrim(SA2->A2_NUMCON) */ + AllTrim(SE2->E2_FCTADV)/* AllTrim(SA2->A2_DVCTA) */ ) // 54754
        HeaderJson[ "tipoDeContaDestinatario" ]            := "CC"
        HeaderJson[ "tipodePessoaDestinatario" ]           := SA2->A2_TIPO // "J"
        HeaderJson[ "numeroInscricao" ]                    := SubStr( SA2->A2_CGC, 01, 8 ) // "005171355" // 29920796000182
        HeaderJson[ "numeroFilial" ]                       := SubStr( SA2->A2_CGC, 09, 4 ) // "0002"
        HeaderJson[ "numeroControle" ]                     := SubStr( SA2->A2_CGC, 13, 2 ) // "48"
        HeaderJson[ "nomeClienteDestinatario" ]            := AllTrim(SA2->A2_NOME) // "MARIA DE SOUZA MATOS"
        HeaderJson[ "valorDaTransferencia" ]               := SE2->E2_VALOR // 1000.8
        HeaderJson[ "finalidadeDaTransferencia" ]          := 10
        HeaderJson[ "codigoIdentificadorDaTransferencia" ] := cValToChar( SE2->(Recno()) ) // "04062024"
        HeaderJson[ "dataMovimento" ]                      := Transform(DToC( MsDate() ),"@R 99.99.9999") // "31.07.2024"
        HeaderJson[ "tipoDeDoc" ]                          := "E"
        HeaderJson[ "tipoDeDocumentoDeBarras" ]            := ""
        HeaderJson[ "numeroCodigoDeBarras" ]               := ""
        HeaderJson[ "canalPagamento" ]                     := 0
        HeaderJson[ "valorMulta" ]                         := SE2->E2_MULTA     // 0
        HeaderJson[ "valorJuro" ]                          := SE2->E2_JUROS     // 0
        HeaderJson[ "valorDescontoOuAbatimento" ]          := SE2->E2_DESCONT   // 0
        HeaderJson[ "valorOutrosAcrescimos" ]              := SE2->E2_ACRESC    // 0
        HeaderJson[ "indicadorDda" ]                       := "N"
        cPostParms                                         := HeaderJson:toJson()

        MemoWrite( cPathLog + ( cPathFile := "05-transferencia-01-HeaderJson.json" ),;
            ToJson( FromJson(cPostParms) ) )
        aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

        cSignature := 'POST' + _ENTER_ +;
            '/v1/'+ cMetodo + _ENTER_ +; // '/oapi/v1/pagamentos/boleto/validarDadosTitulo' + _ENTER_ +;
            _ENTER_ +;
            cPostParms   + _ENTER_ +;
            cAccessToken + _ENTER_ +;
            cXBradNonce  + _ENTER_ +;
            cTimestamp   + _ENTER_ +;
            'SHA256'
        MemoWrite( cPathLog + ( cPathFile := "05-transferencia-02-RequestSignature.txt" ), cSignature)
        aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

        cSignature := EncodeUTF8( cSignature )
        cSignature := EVPPrivSign( "\certs\certPrivate.pem", cSignature, 5, "V@2025", @cErrStr )
        cSignature := Encode64( cSignature )
        cSignature := Replace( cSignature, " ", "" )
        cSignature := Replace( cSignature, "=", "" )
        cSignature := Replace( cSignature, "+", "-")
        cSignature := Replace( cSignature, "/", "_")

        MemoWrite( cPathLog + ( cPathFile := "05-transferencia-03-RequestSignatureSHA256.txt" ), cSignature)
        // aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

        AAdd(aHeadStr, "Authorization: "    + "Bearer " + cAccessToken )
        AAdd(aHeadStr, "X-Brad-Signature: " + cSignature               )
        AAdd(aHeadStr, "X-Brad-Nonce: "     + cXBradNonce              )
        AAdd(aHeadStr, "X-Brad-Timestamp: " + cTimestamp               )
        AAdd(aHeadStr, "X-Brad-Algorithm: " + "SHA256"                 )
        AAdd(aHeadStr, "access-token: "     + __cClientKey             )
        AAdd(aHeadStr, "Content-Type: application/json; charset=utf-8" )
        AAdd(aHeadStr, "Accept: application/json, text/plain"          )

        MemoWrite( cPathLog + ( cPathFile := "05-transferencia-04-RequestHeader.txt" ),;
            StrTran( StrTran( StrTran( StrTran( U_aToS(aHeadStr), '", "', _ENTER_ ),'{ "', ""), '" }', ""),': ', ":") )
        aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )

        oRestClien := FwRest():New( cURLTED )
        oRestClien:SetPath( cMetodo ) // TED = "/transferencia/efetiva"
        oRestClien:SetPostParams( EncodeUTF8(cPostParms, "cp1252") )
        Sleep( nSLEEP )

        lRet      := oRestClien:Post(aHeadStr)
        // cPostRet  := DecodeUTF8( oRestClien:GetResult() ) // deu um erro aqui
        cPostRet  := oRestClien:GetResult()
        nHttpCode := HTTPGetStatus(@cHttpStat)

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
                ZE2->ZE2_METODO := "[TED]/" + cMetodo
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
            ZE2->ZE2_METODO := "[TED]/" + cMetodo
            If lRet
                __cChvRet := cValToChar( oObj:chaveUnicaParaApi )
                ZE2->ZE2_XCHVRE := __cChvRet// chave retornada pela API BRADESCO - RETORNO API
            EndIf
            ZE2->(MsUnlock())

            // Alert(iIf(lRet, "Sucesso: ", "Erro: ") + _ENTER_ + cPostRet )
        EndIf

        MemoWrite( cPathLog + ( cPathFile := "05-transferencia-05-Resultado_Json.json" ),;
            cPostRet ) // formatar Json, formater json
        aAdd( _aAnexos, { cPathFile, cPathLog+cPathFile } )
    EndIf

    // FreeObj(oJson)
    RestArea( aArea )
Return lRet
// FIM : fTed


/*
aNames := oJson:GetNames()

cRet := oJson:fromJson(FwNoAccent(cJson))

TRATAR CARACTERES ESPECIAIS
https://programandosemcafeina.blogspot.com/2007/04/caracteres-especiais-representados-em.html?m=1
*/


// Static Function zLogin
//     Local aArea              := GetArea()
//     Local oGrpLog
//     Local oBtnConf
//     Private lRetorno         := .F.
//     Private oDlgPvt
//     //Says e Gets
//     Private oSayUsr
//     Private oGetUsr, cGetUsr := Space(25)
//     Private oSayPsw
//     Private oGetPsw, cGetPsw := Space(20)
//     Private oGetErr, cGetErr := ""
//     //Dimensões da janela
//     Private nJanLarg         := 200
//     Private nJanAltu         := 200

//     //Criando a janela
//     DEFINE MSDIALOG oDlgPvt TITLE "Login" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
//         @ 003, 001   GROUP oGrpLog TO (nJanAltu/2)-1, (nJanLarg/2)-3 PROMPT "Login: " OF oDlgPvt COLOR 0, 16777215 PIXEL
//         //Label e Get de Usuário
//         @ 013, 006   SAY   oSayUsr PROMPT "Usuário:" SIZE 030, 007 OF oDlgPvt PIXEL
//         @ 020, 006   MSGET oGetUsr VAR    cGetUsr    SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL
//         //Label e Get da Senha
//         @ 033, 006   SAY   oSayPsw PROMPT "Senha:"   SIZE 030, 007 OF oDlgPvt PIXEL
//         @ 040, 006   MSGET oGetPsw VAR    cGetPsw    SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL PASSWORD
//         //Get de Log, pois se for Say, não da para definir a cor
//         @ 060, 006   MSGET oGetErr VAR    cGetErr    SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 NO BORDER PIXEL
//         oGetErr:lActive := .F.
//         oGetErr:setCSS("QLineEdit{color:#FF0000; background-color:#FEFEFE;}")
//         //Botões
//         @ (nJanAltu/2)-18, 006 BUTTON oBtnConf PROMPT "Confirmar" SIZE (nJanLarg/2)-12, 015 OF oDlgPvt ACTION (fVldUsr()) PIXEL
//         oBtnConf:SetCss("QPushButton:pressed { background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #dadbde, stop: 1 #f6f7fa); }")
//     ACTIVATE MSDIALOG oDlgPvt CENTERED

//     //Se a rotina foi confirmada e deu certo, atualiza o usuário e a senha
//     If lRetorno
//         cUsrLog := Alltrim(cGetUsr)
//         cPswLog := Alltrim(cGetPsw)
//     EndIf

//     RestArea(aArea)
// Return lRetorno

// /*---------------------------------------------------------------------
//  | Func:  fVldUsr                                                      |
//  | Autor: Ivan Caproni                                                 |
//  | Data:  23/07/2021                                                   |
//  | Desc:  Função para validar se o usuário existe                      |
//  ---------------------------------------------------------------------*/
// Static Function fVldUsr()
//     Local cUsrAux	:= Alltrim(cGetUsr)
//     Local cPswAux	:= Alltrim(cGetPsw)
// 	//Local _cUsuario	:= "eddavid"
// 	//Local _cSenha	:= "@!Am0r41901"
// 	Local _cUsuario	:= "@#$" // 234
// 	Local _cSenha	:= "@#$" // 234

//     If !Empty(cUsrAux) .And. Upper(cUsrAux)==Upper(_cUsuario)
//          If Trim(cPswAux)!=_cSenha
//             cGetErr := "Senha inválida!"
//             oGetErr:Refresh()
//             Return
//         Else
//             // lRetorno := .T.
//             lRetorno := fLiberaRotina()
//         Endif
//      Else
//         cGetErr := "Usuário não encontrado!"
//         oGetErr:Refresh()
//         Return
//     EndIf
//     If lRetorno
//         oDlgPvt:End()
//     EndIf
// Return


// User Function fLiberaRotina()
// 	Local lContinua     := .F.
// 	Local cQuery        := ""
// 	Local aCNPJClientes := {}

// 	aAdd( aCNPJClientes, {} )
// 	aAdd( aTail(aCNPJClientes), "111111111111111" )
// 	aAdd( aTail(aCNPJClientes), "222222222222222" )
// 	aAdd( aTail(aCNPJClientes), "333333333333333" )

// 	cQuery:= " SELECT M0_CODIGO, M0_CODFIL, M0_FILIAL, M0_NOME, M0_CGC " +;
// 		" FROM   SYS_COMPANY " +;
// 		" WHERE  D_E_L_E_T_ = " "

// 	MPSysOpenQuery( cQuery, "SQL1" )
// 	While SQL1->(!Eof()) .And. !lContinua

// 		If aScan( aCNPJClientes, { |x| x == SQL1->M0_CGC } ) > 0
// 			lContinua := .T.
// 			Exit
// 		EndIf

// 		SQL1->(DbSkip())
// 	EndDo

// 	If !lContinua
// 		If GetMV("ZZ_3SDATA")
// 			lContinua := .T.
// 		EndIf
// 	EndIf
// Return lContinua



/* MB : Botao no fonte VAFINI01
     -> Tela de integracao desenvolvida pelo Igor,
     Eu trouxe essa funcao para k pois ainda esta em desenvolvimento,
e para nao atrapalhar eventuais ajustes da funcao que estamos fazendo. */
User Function FI01CAP()
    Local cChave := SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_FORNECE+E2_LOJA+E2_PARCELA+E2_TIPO)
    Local nQtOK  := 0, nQtEr  := 0

    ZE2->(DbSetOrder(1))
    If ZE2->(DbSeek( cChave ))
        While !ZE2->(Eof()) .AND. cChave == ZE2->(ZE2_FILIAL+ZE2_PREFIX+ZE2_NUM+ZE2_FORNEC+ZE2_LOJA+ZE2_PARCEL+ZE2_TIPO)
            If Empty(ZE2->ZE2_XDTLIB)
                FWAlertError( "Titulo não liberado para ser transmitido para o banco via WS-API, no item : " + ZE2->ZE2_ITEM,;
                    "Problema Localizado")
                exit
            Else
                // Alert("FI01CAP: " + DtoC(dDataBase) + " - " + Time() + " Item: " + ZE2->ZE2_ITEM )
                if ZE2->ZE2_XSTAPI $ ("BX,ER")
                    If U_fxAPIBradesco( "E" )
                        ++nQtOK
                    Else
                        ++nQtEr
                    EndIf
                    sleep( nSLEEP )
                EndIf
            EndIf
            ZE2->(DbSkip())
        EndDo
    EndIf

    If (nQtOK+nQtEr)>0
        MsgInfo( "Foram transmitidos: " + cValToChar( nQtOK+nQtEr) + (Chr(13)+Chr(10)) +;
            cValToChar(nQtOK) + " com sucesso," + (Chr(13)+Chr(10)) +;
            cValToChar(nQtEr) + " com erros.",;
            "Atenção")
    ElseIf (nQtOK+nQtEr)==0
        MsgInfo( "Não houve nenhum titulo enviado para pagamento.",;
            "Atenção")
    EndIf
Return


/* PE : 08.08.2024
-> PE na baixa do titulo. */
User Function FA080PE()
    U_CriarZE2()
Return nil

/* MB : 10.09.2024
    -> Baixa Automatica
*/
User Function F90SE5GRV()
    // Local cChave := SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_FORNECE+E2_LOJA+E2_PARCELA+E2_TIPO)
    // Alert('Baixa Automatica: ' + cChave)
    U_CriarZE2()
Return nil

User Function CriarZE2()
    Local nI      := 0
    Local aAreas  := {}
    Local lInclui := .T.

    If cEmpAnt <> "01" // API Somente habilitadas para a Filial 01
        Return nil
    EndIf

    If !(SE2->E2_BCOPAG $ ('237')) // se diferente de BRADESCO (237) entao SAIR da funcao
        Return nil
    EndIf

    If Empty(SE2->E2_XTPAPI) // B=Boleto;T=TED;A=Arrec. Tributo;P=PIX
        Return nil
    EndIf

    aAreas  :={GetArea(), SE2->(GetArea()), ZE2->(GetArea())}
    // U_fxAPIBradesco( "E" )

    // ZE2->(DbSetOrder(1))
    // lInclui := !ZE2->(DbSeek( SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_FORNECE+E2_LOJA+E2_PARCELA+E2_TIPO) ))
    RecLock( 'ZE2', lInclui )
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
    ZE2->ZE2_XSTAPI := "BX" // BX=Baixado;
    ZE2->ZE2_XDTBXA := dDataBase
    ZE2->ZE2_XHRBXA := TIME()
    ZE2->ZE2_VLRPAG := SE5->E5_VALOR // SE2->E2_VALOR
    ZE2->(MsUnLock())

    If Empty(SE2->E2_XSTAPI)
        RecLock( 'SE2', .F. )
        // SE2->E2_XRCNZE2 := ZE2->(Recno()) // APAGAR ESSE CAMPO, NAO SERA MAIS UTILIZADO
        SE2->E2_XSTAPI  := "BX" // BX=Baixado;
        SE2->(MsUnLock())
    EndIf

    //-- Reposiciona Arquivos
    For nI := 1 To Len(aAreas)
        RestArea(aAreas[nI])
    Next nI
Return nil

/* MB : 23.09.2024
    -> GATILHO para preencher automaticamente as contas do banco.
*/
User Function FGatStatusAPI( cCpo, cValor ) // B=Boleto;T=TED;A=Arrec. Tributo;P=PIX

    If M->(E2_FORNECE+E2_LOJA) <> SA2->(A2_COD+A2_LOJA)
        SA2->(DbSetOrder(1))
        SA2->(DbSeek( FwxFilial('SA2') + SE2->E2_FORNECE + SE2->E2_LOJA ))
    EndIf

    if cCpo == 1
        Do Case
            // Case cValor $ "B" // Boleto
            Case cValor $ "T" // TED
                M->E2_FORBCO := SA2->A2_BANCO
                M->E2_FORAGE := SA2->A2_AGENCIA // SA2->A2_DVAGE
                M->E2_FAGEDV := SA2->A2_DVAGE
                M->E2_FORCTA := SA2->A2_NUMCON
                M->E2_FCTADV := SA2->A2_DVCTA
                // Case cValor $ "A" // Arrec. Tributo

            // Case cValor $ "P" .AND. !Empty( M->E2_XTPCHPX )// PIX
            //     U_FGatStatusAPI( 2, M->E2_XTPCHPX )

        EndCase

    // Else// if cCpo == 2

    //     If SE2->E2_XTPAPI $ "P"// PIX
    //         Do Case

    //             Case cValor $ "01" // TELEFONE
    //                 M->E2_XPIXCHV := '+' +;
    //                             Iif( Empty(SA2->A2_DDI), '55', AllTrim(SA2->A2_DDI) ) +;
    //                             AllTrim(SA2->A2_DDD) +;
    //                             AllTrim(SA2->A2_TEL)
    //             Case cValor $ "02" // EMAIL
    //                 M->E2_XPIXCHV := SA2->A2_EMAIL
    //             Case cValor $ "03" // CPF/CNPJ
    //                 M->E2_XPIXCHV := SA2->A2_CGC
                
    //             Case cValor $ "04" // CHAVE ALEATORIA
    //                 Alert( "Chave Aleatória não implementada" )
                
    //             Case cValor $ "05" // AGENCIACONTA
    //                 M->E2_XPIXCHV := SA2->A2_BANCO + ',' + SA2->A2_AGENCIA + ',' + SA2->A2_DVAGE + ',' + SA2->A2_NUMCON + ',' + SA2->A2_DVCTA
    //         EndCase

    //     EndIf
    EndIf

Return cValor
