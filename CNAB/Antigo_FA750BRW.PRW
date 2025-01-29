#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
// #INCLUDE "JSON.PRG"

/*--------------------------------------------------------------------------------,
 | Principal: 			            U_FA750BRW()            		              |
 | Func:      FA750BRW()	            	          	            	          |
 | Cliente:   V@                                                                  |
 | Autor:     Miguel Martins Bernardo Junior	            	          	  	  |
 | Data:      29.08.2023	            	          	            	          |
 | Desc:      PE Add Botao Rotina Contas a Pagar                                  |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
'--------------------------------------------------------------------------------*/
User Function FA750BRW()
    Local aRotina := {}
    aAdd( aRotina,	{ "API Bradesco", "U_fCallAPi", 0 , 6})
    SetKey( VK_F10 , { || U_fCallAPi() } )
    //SetKey( VK_F10 , { || U_fAPIBradesco() } )
    SetKey( VK_F11 , { || U_statusfAPIBradesco() } )
Return aRotina

Static _ENTER_  := Chr(10) // + Chr(13) // SALTO DE LINHA (CARRIAGE RETURN + LINE FEED)
Static cURL1    := "https://proxy.api.prebanco.com.br/auth/server/v1.1/"
Static cURL2    := "https://proxy.api.prebanco.com.br/oapi/v1"
Static cURL3    := "https://proxy.api.prebanco.com.br/oapi/v1/pagamentos/pagamentoContaConsumo"
Static nTimeOut := 120
Static cHttpVld := "200|201|500|415"

User Function fCallAPi()
    
    DbSelectArea("SA6")
        If ConPad1(, , , "SA6")
            if aCpoRet[1] == '237' // BRADESCO
                Processa({|| U_fAPIBradesco() }, "Aguarde...") 
            elseif aCpoRet[1] == '341' //ITAU
                MsgALert("Itau")
            else // OUTRO
                MsgALert("API não implementada!")
            endif 

        EndIF 
    SA6->(DBCLOSEAREA(  ))
Return

User Function fArrecad(cAccessToken,cRetJson)
    Local HeaderJson    := JsonObject():New(), oObj := nil
    Local cMetodo       := "/pagamentos/pagamentoContaConsumo"
    Local aHeadStr      := {}, cHeadRet := "", cPostRet := "", cPostParms := "", cHttpStat := "", nHttpCode := 0, cErrStr := "", cSignature := ''

    HeaderJson[ 'agencia' ]         := rTrim(aCpoRet[2])
    HeaderJson[ 'codigoBarras']     := cE2CODBAR
    HeaderJson[ 'conta' ]           := rTrim(aCpoRet[3])
    HeaderJson[ 'dataDebito' ]      := Transform(dToS(Date()),"@R 9999-99-99")
    HeaderJson[ 'digitoAgencia' ]   := AllTrim(Posicione("SA6",1,FWxFilial("SA6")+aCpoRet[1]+rTrim(aCpoRet[2])+rTrim(aCpoRet[3]),"A6_DVAGE"))
    HeaderJson[ 'digitoConta' ]     := AllTrim(Posicione("SA6",1,FWxFilial("SA6")+aCpoRet[1]+rTrim(aCpoRet[2])+rTrim(aCpoRet[3]),"A6_DVCTA"))
    HeaderJson[ 'idTransacao' ]     := "" // DEFINIR FORMATO DE ID E QUAL CAMPO IRÁ GRAVAR
    HeaderJson[ 'tipoConta' ]       := "" 
    HeaderJson[ 'tipoRegistro' ]    := "1"
    HeaderJson[ 'valorPrincipal' ]  := SE2->E2_VALOR

    
   //if lRet := bolVldDados()
   //    cRet := bolVldPagamento( cRet, cAccessToken,@cRetJson)
   //
   //    If !Empty( cRet )
   //        // 4º POST /pagamentos/boleto/efetivarPagamento
   //        cRet := mtdEfetPagto( cRet, cAccessToken,@cRetJson )
   //    EndIf
   //endif 

    cPostParms := HeaderJson:toJson()
    /*
    cSignature := 'POST' + _ENTER_ +; // _ENTER_ = (Chr(13)+Chr(10))
        '/oapi/v1'+ cMetodo + _ENTER_ +;
        _ENTER_ +;
        cPostParms   + _ENTER_ +;
        cAccessToken + _ENTER_ +;
        cXBradNonce  + _ENTER_ +;
        cTimestamp   + _ENTER_ +;
        'SHA256'     // + _ENTER_

    cSignature := EncodeUTF8( cSignature )
    cSignature := Encode64( EVPPrivSign( "\certs\cert.pem", cSignature, 5, "V@2023", @cErrStr ) )
    cSignature := Replace( cSignature, "/", "_")
    cSignature := Replace( cSignature, "+", "-")
    cSignature := Replace( cSignature, "=", "")
    AAdd(aHeadStr, "Authorization: Bearer " + cAccessToken       )
    AAdd(aHeadStr, "X-Brad-Signature: "     + cSignature         )
    AAdd(aHeadStr, "X-Brad-Nonce: "         + cXBradNonce        )
    AAdd(aHeadStr, "X-Brad-Timestamp: "     + cTimestamp         )
    AAdd(aHeadStr, "X-Brad-Algorithm: "     + "SHA256"           )
   */

    AAdd(aHeadStr, "cpfCnpj: "      + SM0->M0_CGC           )
    AAdd(aHeadStr, "access-token: " + cAccessToken          )
    AAdd(aHeadStr, "Content-Type: application/json"              )
    AAdd(aHeadStr, "Accept: application/json, text/plain"        )
    MemoWrite("\DATA\CNAB\02-validarDadosTitulo-03-RequestHeader.txt", StrTran( U_aToS(aHeadStr), '", "', _ENTER_ ))

    oRestClien := FwRest():New( cURL2 + "/" )
    oRestClien:SetPath( SubS(cMetodo, 2) )
    oRestClien:SetPostParams( EncodeUTF8(cPostParms, "cp1252") )
    
    lRet      := oRestClien:Post(aHeadStr)
    cPostRet  := oRestClien:GetResult()
    nHttpCode := HTTPGetStatus(@cHttpStat)

    If !FWJsonDeserialize( cPostRet, @oObj)
        Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else
        If  lRet := (lTrim(Str(nHttpCode)) $ cHttpVld) // Erro 500 se refere a ambiente instável
            cRetJson := Escape( cAccessToken /* oObj:access_token */ )
        Else
            DBSELECTAREA( "ZCB" )
                RECLOCK( "ZCB", .T. )
                    ZCB->ZCB_FILIAL := FWxFilial("ZCB")
                    ZCB->ZCB_COD    := GETSXENUM("ZCB","ZCB_COD")
                    ZCB->ZCB_CODRET := oObj:CODIGO
                    ZCB->ZCB_DATA   := dDataBase
                    ZCB->ZCB_HORA   := TIME()
                    ZCB->ZCB_OBS    := oObj:MENSAGEM
                    ZCB->ZCB_TABELA := "SE2"
                    ZCB->ZCB_FIL    := SE2->E2_FILIAL
                    ZCB->ZCB_NUM    := SE2->E2_NUM
                    ZCB->ZCB_SERIE  := SE2->E2_TIPO
                    ZCB->ZCB_PARCEL := SE2->E2_PARCELA
                    ZCB->ZCB_FORN   := SE2->E2_FORNECE
                    ZCB->ZCB_LOJA   := SE2->E2_LOJA
                    ZCB->ZCB_ETAPA  := cMetodo
                ZCB->(MSUNLOCK())
            ZCB->(DBCLOSEAREA(  ))

            reclock("SE2",.F.)
                SE2->E2_XSTATUS := '1'
            SE2->(MSUNLOCK())
        EndIf
    EndIf
    
Return
/*--------------------------------------------------------------------------------,
 | Principal:   		            fAPIBradesco()            		              |
 | Func:      fAPIBradesco()	            	          	            	      |
 | Cliente:   V@                                                                  |
 | Autor:     Miguel Martins Bernardo Junior	            	          	  	  |
 | Data:      29.08.2023	            	          	            	          |
 | Desc:      Rotina API de comunicação com o Bradesco.                           |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
'--------------------------------------------------------------------------------*/
User Function fAPIBradesco()
    Local lRet := .T., cRetJson := ""
    Local cAccessToken   := ""

    Private cE2CODBAR := AllTrim(SE2->E2_CODBAR)
    //Private cE2CODBAR    := "74891955300000000001160000271207000100275005"
    
    Private __mbDATA     := MsDate()
    Private __mbHORA     := Time()
    Private __cClientKey := "49eeb64f-ef34-496b-93dc-3ac9aa5d1aeb"

    Private cTimestamp   := FWTimeStamp( 3, __mbDATA, __mbHORA ) + "-00:00"

    Private __cIat       := Val( FWTimeStamp( 4, __mbDATA, __mbHORA ) )
    Private __cExp       := Val( FWTimeStamp( 4, __mbDATA, IncTime( __mbHORA , 0 , 40 , 0 ) ) )

    Private cXBradNonce  := cValToChar( Val(FWTimeStamp( 4, __mbDATA, __mbHORA )) * 1000 )

    cAccessToken         := mtdToken( )

    if SubStr(cE2CODBAR,1,1) == '8'
        //IF SE2->E2_NATUREZA $ '2129' // 
        cJson := u_fArrecad(cAccessToken,@cRetJson)
        //ENDIF
    else 

    endif
    
    // 1º GET /pagamentos/boleto/limites - Consulta Limites e Horários Disponíveis para Pagamento
    // mtdLimites( cAccessToken )

    // 2º POST /pagamentos/boleto/validarDadosTitulo – Validar Dados do Título  - Bradesco  e/ou Outros Bancos
    lRet := mtdVldDados( cAccessToken, @cRetJson )
    If lRet
    
        // 3º POST /pagamentos/boleto/validarPagamento – Validar Dados para o Pagmento
        cRet := mtdVldPagamento( cRet, cAccessToken,@cRetJson)
    
        If !Empty( cRet )
            // 4º POST /pagamentos/boleto/efetivarPagamento
            cRet := mtdEfetPagto( cRet, cAccessToken,@cRetJson )
        EndIf
    EndIf

Return nil


/* MB : 02.10.2023 */
Static Function mtdVldDados( cAccessToken, cRetJson )
    Local aArea         := GetArea()
    Local lRet          := .F.
    Local cMetodo       := "/pagamentos/boleto/validarDadosTitulo"
    Local HeaderJson    := JsonObject():New(), oObj := nil
    Local aHeadStr      := {}, cHeadRet := "", cPostRet := "", cPostParms := "", cHttpStat := "", nHttpCode := 0, cErrStr := "", cSignature := ''
    // cRet := ""

    HeaderJson[ 'agencia' ]      := 3995
    HeaderJson[ 'tipoEntrada' ]  := 1
    HeaderJson[ 'dadosEntrada' ] := cE2CODBAR // AllTrim(SE2->E2_CODBAR)
    cPostParms := HeaderJson:toJson()    // cPostParms := cValToChar( HeaderJson )

    cSignature := 'POST' + _ENTER_ +; // _ENTER_ = (Chr(13)+Chr(10))
                  '/oapi/v1'+ cMetodo + _ENTER_ +; // '/oapi/v1/pagamentos/boleto/validarDadosTitulo' + _ENTER_ +;
                  _ENTER_ +;
                  cPostParms   + _ENTER_ +;
                  cAccessToken + _ENTER_ +;
                  cXBradNonce  + _ENTER_ +;
                  cTimestamp   + _ENTER_ +;
                  'SHA256'     // + _ENTER_
    MemoWrite("\DATA\CNAB\02-validarDadosTitulo-01-RequestSignature.txt", cSignature)

    cSignature := EncodeUTF8( cSignature )
    cSignature := Encode64( EVPPrivSign( "\certs\cert.pem", cSignature, 5, "V@2023", @cErrStr ) )
    cSignature := Replace( cSignature, "/", "_")
    cSignature := Replace( cSignature, "+", "-")
    cSignature := Replace( cSignature, "=", "")
    MemoWrite("\DATA\CNAB\02-validarDadosTitulo-02-RequestSignatureSHA256.txt", cSignature)

    AAdd(aHeadStr, "Authorization: Bearer " + cAccessToken       )
    AAdd(aHeadStr, "X-Brad-Signature: "     + cSignature         )
    AAdd(aHeadStr, "X-Brad-Nonce: "         + cXBradNonce        )
    AAdd(aHeadStr, "X-Brad-Timestamp: "     + cTimestamp         )
    AAdd(aHeadStr, "X-Brad-Algorithm: "     + "SHA256"           )
    AAdd(aHeadStr, "Content-Type: application/json"              )
    AAdd(aHeadStr, "Accept: application/json, text/plain"        )
    MemoWrite("\DATA\CNAB\02-validarDadosTitulo-03-RequestHeader.txt", StrTran( U_aToS(aHeadStr), '", "', _ENTER_ ))

    oRestClien := FwRest():New( cURL2 + "/" )
    oRestClien:SetPath( SubS(cMetodo, 2) )
    oRestClien:SetPostParams( EncodeUTF8(cPostParms, "cp1252") )
    
    lRet      := oRestClien:Post(aHeadStr)
    cPostRet  := oRestClien:GetResult()
    nHttpCode := HTTPGetStatus(@cHttpStat)

    If !FWJsonDeserialize( cPostRet, @oObj)
        Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else
        If  lRet := (lTrim(Str(nHttpCode)) $ cHttpVld) // Erro 500 se refere a ambiente instável
            cRetJson := Escape( cAccessToken /* oObj:access_token */ )
        Else
            DBSELECTAREA( "ZCB" )
                RECLOCK( "ZCB", .T. )
                    ZCB->ZCB_FILIAL := FWxFilial("ZCB")
                    ZCB->ZCB_COD    := GETSXENUM("ZCB","ZCB_COD")
                    ZCB->ZCB_CODRET := oObj:CODIGO
                    ZCB->ZCB_DATA   := dDataBase
                    ZCB->ZCB_HORA   := TIME()
                    ZCB->ZCB_OBS    := oObj:MENSAGEM
                    ZCB->ZCB_TABELA := "SE2"
                    ZCB->ZCB_FIL    := SE2->E2_FILIAL
                    ZCB->ZCB_NUM    := SE2->E2_NUM
                    ZCB->ZCB_SERIE  := SE2->E2_TIPO
                    ZCB->ZCB_PARCEL := SE2->E2_PARCELA
                    ZCB->ZCB_FORN   := SE2->E2_FORNECE
                    ZCB->ZCB_LOJA   := SE2->E2_LOJA
                    ZCB->ZCB_ETAPA  := cMetodo
                ZCB->(MSUNLOCK())
            ZCB->(DBCLOSEAREA(  ))

            reclock("SE2",.F.)
                SE2->E2_XSTATUS := '1'
            SE2->(MSUNLOCK())
        EndIf
    EndIf
    
    // If oRestClien:Post(aHeadStr)
    //     cPostRet := oRestClien:GetResult()
    //     // Alert("DEU BOM")
    // Else
    //     ConOut("Ainda não")
    //     Alert(oRestClien:GetLastError() )
    // EndIf

    // If Empty( cPostRet )
    //     /* HTTPs */
    //     cPostRet := HTTPSPost( cURL2+cMetodo,; // 01 // < cURL1 >
    //         "\certs\000001_all.pem",; // 02 // < cCertificate > // OU 000001_all
    //         "\certs\000001_key.pem",; // 03 // < cPrivKey >     // 000001_key chave privada
    //         "V@2023"               ,; // 04 // < cPassword >
    //         ""                     ,; // 05 // [ cGETParms ]
    //         cPostParms/* EncodeUTF8(cPostParms ) */,; // 06 // [ cPOSTParms ]
    //         nTimeOut               ,; // 07 // [ nTimeOut ]
    //         aHeadStr               ,; // 08 // [ aHeadStr ]
    //         @cHeadRet               ) // 09 // [ @cHeaderRet ]
    // EndIf

    // If Empty( cPostRet )
    //     cPostRet := HTTPPost( cURL2+cMetodo, "", cPostParms, nTimeOut, aHeadStr, @cHeadRet)
    // EndIf

    // If !FWJsonDeserialize( cPostRet, @oObj)
    //     Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    // Else
    //     nHttpCode := HTTPGetStatus(@cHttpStat)
    //     If  nHttpCode == 200 .or. nHttpCode == 201 .or. nHttpCode == 500 // Erro 500 se refere a ambiente instável
    //         // cPostRet := Escape( oObj:access_token )
    //         //  Alert("Deu Certo: " + cPostRet)
    // 
    //         MemoWrite("\DATA\CNAB\02-validarDadosTitulo-04-OK.txt", cPostRet)
    //     // Else
    //     //     if Empty( cPostRet )
    //     //         conout( "Fail HTTPSPost" )
    //     //         // Alert( cHeadRet, "Header" )
    //     //     else
    //     //         // conout( "OK HTTPSPost" )
    //     //         Alert( cPostRet, "WebPage" )
    //     //     endif
    //     endif
    // EndIf
    RestArea(aArea)
return lRet


Static Function mtdToken( )
    Local cMetodo    := "token"
    Local oObj       := nil
    Local cToken        := geraTokenJsonBrad( )
    Local aHeadStr   := {}, cHeadRet   := "", cPostRet   := "", cPostParms := "", cHttpStat  := "", nHttpCode  := 0, cRet       := ""

    // Acrescenta o UserAgent na requisição ...
    // http://tools.ietf.org/html/rfc3261#page-179

    AAdd(aHeadStr, "Content-Type: application/x-www-form-urlencoded")

    cPostParms := "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer"
    cPostParms += "&assertion="     + Escape( cToken )
    // cPostParms += "&assertion="        + cToken

    oRestClien := FwRest():New( cURL1 )
    oRestClien:SetPath( cMetodo ) // METODO = token
    oRestClien:SetPostParams( EncodeUTF8(cPostParms, "cp1252") )
    If oRestClien:Post(aHeadStr)
        cPostRet := oRestClien:GetResult()
        // Alert("DEU BOM")
    Else
        ConOut("Ainda não")
        Alert(oRestClien:GetLastError() )
    EndIf
    // Alert( oRestClien:GetResult() )

    If Empty( cPostRet )
        cPostRet := HTTPSPost( cURL1+cMetodo,; // 01 // < cURL1 >
            "\certs\000001_all.pem"         ,; // 02 // < cCertificate > // OU 000001_all
            "\certs\000001_key.pem"         ,; // 03 // < cPrivKey >     // chave privada em RSA - peguei certificado gerado no TSS;
            "V@2023"                        ,; // 04 // < cPassword >
            ""                              ,; // 05 // [ cGETParms ]
            cPostParms /* EncodeUTF8(cPostParms ) */         ,; // 06 // [ cPOSTParms ]
            nTimeOut                        ,; // 07 // [ nTimeOut ]
            aHeadStr                        ,; // 08 // [ aHeadStr ]
            @cHeadRet                        ) // 09 // [ @cHeaderRet ]
        // cPostRet := HTTPSPost( cURL1+cMetodo, "\certs\000001_all.pem", "\certs\000001_key.pem", "V@2023", "", EncodeUTF8(cPostParms ), nTimeOut, aHeadStr, @cHeadRet )
    EndIf
    //
    //    If Empty( cPostRet )
    //        cPostRet := HTTPPost( cURL1+cMetodo, "", cPostParms, nTimeOut, aHeadStr, @cHeadRet)
    //    EndIf

    If !FWJsonDeserialize( cPostRet, @oObj)
        Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else
        nHttpCode := HTTPGetStatus(@cHttpStat)
        If  nHttpCode == 200 .or. nHttpCode == 201 .or. nHttpCode == 500 // Erro 500 se refere a ambiente instável
            cRet := oObj:access_token // Alert( "Token Gerado com Sucesso" )
            MemoWrite("\DATA\CNAB\2-token-access_token.txt", cRet )
        Else
            if Empty( cPostRet )
                conout( "Fail HTTPSPost" )   // Alert( cHeadRet, "Header" )
            else
                Alert( cPostRet, "WebPage" ) // conout( "OK HTTPSPost" )
            endif
        endif
    EndIf

return cRet

/* MB : 28.09.2023
-> Gerar Token Criptografado, conforme manual do Bradesco. */
Static Function geraTokenJsonBrad( )
    Local HeaderJson      := JsonObject():New(), PayLoadJson := JsonObject():New()
    Local cod64HeaderJson := "", cod64PayLoadJson := "", cJWTToSign := "", cErrStr := ""
    Local sHashHex        := ""

    HeaderJson[ 'alg' ]  := "RS256"
    HeaderJson[ 'typ' ]  := "JWT"
    cod64HeaderJson      := HeaderJson:toJson()
    cod64HeaderJson      := fTratStr( cod64HeaderJson )

    PayLoadJson[ 'typ' ] := "JWT"
    PayLoadJson[ 'iss' ] := "Banco Bradesco"
    PayLoadJson[ 'aud' ] := "https://proxy.api.prebanco.com.br/auth/server/v1.1/token"
    PayLoadJson[ 'sub' ] := __cClientKey // Client Key
    PayLoadJson[ 'iat' ] := __cIat
    PayLoadJson[ 'exp' ] := __cExp
    PayLoadJson[ 'jti' ] := Val( cXBradNonce )
    PayLoadJson[ 'ver' ] := "1.1"
    cod64PayLoadJson     := PayLoadJson:toJson()
    MemoWrite("\DATA\CNAB\geraTokenJsonBrad-01-PayLoadJson.txt", cod64PayLoadJson )

    cod64PayLoadJson     := fTratStr( cod64PayLoadJson )
    MemoWrite("\DATA\CNAB\geraTokenJsonBrad-02-PayLoadJson.txt", cod64PayLoadJson )

    cJWTToSign := cod64HeaderJson + '.' + cod64PayLoadJson
    MemoWrite("\DATA\CNAB\geraTokenJsonBrad-03-cJWTToSign.txt", cJWTToSign )

    // Criptografia
    // sHashHex := SHA256( cJWTToSign )
    sHashHex := Encode64( EVPPrivSign( "\certs\cert.pem",; // < cPathKey  >
        cJWTToSign       ,; // < cContent  >
        5                ,; // < nTipo     >
        "V@2023"         ,; // < cPassword >
        @cErrStr        ) )
    sHashHex := Replace( sHashHex, "=", "")
    sHashHex := Replace( sHashHex, "+", "-")
    sHashHex := Replace( sHashHex, "/", "_")
    cJWTToSign += '.' + sHashHex

    MemoWrite("\DATA\CNAB\geraTokenJsonBrad-04-token-PayLoadJson-Cript.txt", cJWTToSign)

Return cJWTToSign

/* MB : 22.11.2023 - 3º POST /pagamentos/boleto/validarPagamento – Validar Dados para o Pagmento */
Static Function mtdVldPagamento( __cmtdVldDados, cAccessToken, cRetJson)

    Local cMetodo    := "/pagamentos/boleto/validarPagamento"
    Local HeaderJson := JsonObject():New(), oObj := nil
    Local aHeadStr   := {}, cHeadRet := "", cPostRet := "", cPostParms := "", cHttpStat  := "", nHttpCode  := 0, cErrStr  := "", cSignature := ''

    HeaderJson[ 'agencia' ]                                                                := 3995
    HeaderJson[ 'pagamentoComumRequest' ]                                                  := JsonObject():New()
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ]                             := JsonObject():New()
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ] [ 'agenciaContaDebitada' ]  := 3995
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ] [ 'bancoContaDebitada' ]    := 237
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ] [ 'contaDebitada' ]         := 75557
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ] [ 'digitoAgenciaDebitada' ] := 0
    HeaderJson[ 'pagamentoComumRequest' ][ 'contaDadosComum' ] [ 'digitoContaDebitada' ]   := 0

    HeaderJson[ 'pagamentoComumRequest' ][ 'dadosSegundaLinhaExtrato' ]                    := "TESTE"
    HeaderJson[ 'pagamentoComumRequest' ][ 'dataMovimento' ]                               := dToS( MsDate() )
    HeaderJson[ 'pagamentoComumRequest' ][ 'dataPagamento' ]                               := dToS( MsDate() )
    HeaderJson[ 'pagamentoComumRequest' ][ 'dataVencimento' ]                              := SE2->E2_VENCTO
    HeaderJson[ 'pagamentoComumRequest' ][ 'horaTransacao' ]                               := StrTran( Time(), ":", "" )
    HeaderJson[ 'pagamentoComumRequest' ][ 'identificacaoTituloCobranca' ]                 := cE2CODBAR // AllTrim(SE2->E2_CODBAR)
    HeaderJson[ 'pagamentoComumRequest' ][ 'indicadorFormaCaptura' ]                       := 1
    HeaderJson[ 'pagamentoComumRequest' ][ 'valorTitulo' ]                                 := SE2->E2_VALOR

    HeaderJson[ 'destinatarioDadosComum' ]                                                 := JsonObject():New()
    HeaderJson[ 'destinatarioDadosComum' ][ 'cpfCnpjDestinatario' ]                        := SA2->A2_CGC // ""

    HeaderJson[ 'identificacaoChequeCartao' ]                                              := 0
    HeaderJson[ 'indicadorValidacaoGravacao' ]                                             := "N"
    HeaderJson[ 'nomeCliente' ]                                                            := AllTrim(SE2->E2_NOMFOR)
    HeaderJson[ 'numeroControleParticipante' ]                                             := ""

    HeaderJson[ 'portadorDadosComum' ]                                                     := JsonObject():New()
    HeaderJson[ 'portadorDadosComum' ][ 'cpfCnpjPortador' ]                                := ""

    HeaderJson[ 'remetenteDadosComum' ]                                                    := JsonObject():New()
    HeaderJson[ 'remetenteDadosComum' ][ 'cpfCnpjRemetente' ]                              := ""

    HeaderJson[ 'valorMinimoIdentificacao' ]                                               := 0
    cPostParms := HeaderJson:toJson()
    MemoWrite("\DATA\CNAB\03-validarPagamento-01-HeaderJson.txt", cPostParms)

    cSignature := 'POST' + _ENTER_ +; // _ENTER_ = (Chr(13)+Chr(10))
        '/oapi/v1'+ cMetodo + _ENTER_ +;
        _ENTER_ +;
        cPostParms   + _ENTER_ +;
        cAccessToken + _ENTER_ +;
        cXBradNonce  + _ENTER_ +;
        cTimestamp   + _ENTER_ +;
        'SHA256'     // + _ENTER_
    MemoWrite("\DATA\CNAB\03-validarPagamento-02-cSignature.txt", cSignature)

    cSignature := EncodeUTF8( cSignature )
    cSignature := Encode64( EVPPrivSign( "\certs\cert.pem", cSignature, 5, "V@2023", @cErrStr ) )
    cSignature := Replace( cSignature, "/", "_")
    cSignature := Replace( cSignature, "+", "-")
    cSignature := Replace( cSignature, "=", "")
    MemoWrite("\DATA\CNAB\03-validarPagamento-03-cSignature-Cript.txt", cSignature)

    AAdd(aHeadStr, "Authorization: Bearer " + cAccessToken       )
    AAdd(aHeadStr, "X-Brad-Signature: "     + cSignature         )
    AAdd(aHeadStr, "X-Brad-Nonce: "         + cXBradNonce        )
    AAdd(aHeadStr, "X-Brad-Timestamp: "     + cTimestamp         )
    AAdd(aHeadStr, "X-Brad-Algorithm: "     + "SHA256"           )
    AAdd(aHeadStr, "Access-token: "         + __cClientKey       )
    MemoWrite("\DATA\CNAB\03-validarPagamento-04-aHeadStr.txt", StrTran( U_aToS(aHeadStr), '", "', _ENTER_ ))

    oRestClien := FwRest():New( cURL2 + "/" )
    oRestClien:SetPath( SubS(cMetodo, 2) )
    oRestClien:SetPostParams( EncodeUTF8(cPostParms, "cp1252") )
    
    //If oRestClien:Post(aHeadStr)
    //    cPostRet := oRestClien:GetResult()
    //    // Alert("DEU BOM")
    //Else
    //    ConOut("Ainda não")
    //    Alert(oRestClien:GetLastError() )
    //EndIf

    //If Empty( cPostRet )
    //    cPostRet := HTTPSPost( cURL2+cMetodo,; // 01 // < cURL1 >
    //        "\certs\000001_all.pem"         ,; // 02 // < cCertificate > // OU 000001_all
    //        "\certs\000001_key.pem"         ,; // 03 // < cPrivKey >     // chave privada em RSA - peguei certificado gerado no TSS;
    //        "V@2023"                        ,; // 04 // < cPassword >
    //        ""                              ,; // 05 // [ cGETParms ]
    //        cPostParms /* EncodeUTF8(cPostParms ) */         ,; // 06 // [ cPOSTParms ]
    //        nTimeOut                        ,; // 07 // [ nTimeOut ]
    //        aHeadStr                        ,; // 08 // [ aHeadStr ]
    //        @cHeadRet                        ) // 09 // [ @cHeaderRet ]
    //    // cPostRet := HTTPSPost( cURL1+cMetodo, "\certs\000001_all.pem", "\certs\000001_key.pem", "V@2023", "", EncodeUTF8(cPostParms ), nTimeOut, aHeadStr, @cHeadRet )
    //EndIf

    lRet      := oRestClien:Post(aHeadStr)
    cPostRet  := oRestClien:GetResult()
    nHttpCode := HTTPGetStatus(@cHttpStat)

    If !FWJsonDeserialize( cPostRet, @oObj)
        Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else
        If  lRet := (lTrim(Str(nHttpCode)) $ cHttpVld) // Erro 500 se refere a ambiente instável
        //If  lRet := (nHttpCode == 200 .or. nHttpCode == 201 .or. nHttpCode == 500) // Erro 500 se refere a ambiente instável
            cRetJson := Escape( cAccessToken /* oObj:access_token */ )
        Else
            MsgAlert( OemToAnsi(cPostRet), "Funcao: " + ProcName() )

            DBSELECTAREA( "ZCB" )
                RECLOCK( "ZCB", .T. )
                    ZCB->ZCB_FILIAL := FWxFilial("ZCB")
                    ZCB->ZCB_COD    := GETSXENUM("ZCB","ZCB_COD")
                    ZCB->ZCB_CODRET := oObj:CODIGO
                    ZCB->ZCB_DATA   := dDataBase
                    ZCB->ZCB_HORA   := TIME()
                    ZCB->ZCB_OBS    := oObj:MENSAGEM
                    ZCB->ZCB_TABELA := "SE2"
                    ZCB->ZCB_FIL    := SE2->E2_FILIAL
                    ZCB->ZCB_NUM    := SE2->E2_NUM
                    ZCB->ZCB_SERIE  := SE2->E2_TIPO
                    ZCB->ZCB_PARCEL := SE2->E2_PARCELA
                    ZCB->ZCB_FORN   := SE2->E2_FORNECE
                    ZCB->ZCB_LOJA   := SE2->E2_LOJA
                    ZCB->ZCB_ETAPA  := cMetodo
                ZCB->(MSUNLOCK())
            ZCB->(DBCLOSEAREA(  ))

            reclock("SE2",.F.)
                SE2->E2_XSTATUS := '2'
            SE2->(MSUNLOCK())
        EndIf
    EndIf

   //If !FWJsonDeserialize( cPostRet, @oObj)
   //    Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
   //Else
   //    nHttpCode := HTTPGetStatus(@cHttpStat)
   //    If  nHttpCode == 200 .or. nHttpCode == 201 .or. nHttpCode == 500 // Erro 500 se refere a ambiente instável
   //        // cRet := oObj:access_token
   //        Alert("Deu Certo: " + cPostRet)

   //        MemoWrite("\DATA\CNAB\03-validarPagamento-OK.txt", cPostRet)
   //    Else
   //        if Empty( cPostRet )
   //            conout( "Fail HTTPSPost" )
   //            Alert( cHeadRet, "Header" )
   //        else
   //            conout( "OK HTTPSPost" )
   //            Alert( cPostRet, "WebPage" )
   //        endif
   //    endif
   //EndIf

return cPostRet


/* MB : 23.11.2023 */
Static Function mtdEfetPagto( _cmtdEfetPagto, cAccessToken, cRetJson)

    Local cMetodo    := "/pagamentos/boleto/efetivarPagamento"
    Local HeaderJson := JsonObject():New(), oObj := nil
    Local aHeadStr   := {}, cHeadRet := "", cPostRet := "", cPostParms := "", cHttpStat  := "", nHttpCode  := 0, cErrStr  := "", cSignature := ''

    HeaderJson[ 'agencia' ]                                         := 3995
    HeaderJson[ 'contaDadosComum' ]                                 := JsonObject():New()
    HeaderJson[ 'contaDadosComum' ] [ 'agenciaContaDebitada' ]      := 3995
    HeaderJson[ 'contaDadosComum' ] [ 'bancoContaDebitada' ]        := 237
    HeaderJson[ 'contaDadosComum' ] [ 'contaDebitada' ]             := 75557
    HeaderJson[ 'contaDadosComum' ] [ 'digitoAgenciaDebitada' ]     := 0
    HeaderJson[ 'contaDadosComum' ] [ 'digitoContaDebitada' ]       := 0

    HeaderJson[ 'dadosSegundaLinhaExtrato' ]                        := "TESTE"
    HeaderJson[ 'dataMovimento' ]                                   := dToS( MsDate() )
    HeaderJson[ 'dataPagamento' ]                                   := dToS( MsDate() )
    HeaderJson[ 'dataVencimento' ]                                  := SE2->E2_VENCTO
    HeaderJson[ 'identificacaoTituloCobranca' ]                     := cE2CODBAR // AllTrim(SE2->E2_CODBAR)
    HeaderJson[ 'indicadorFormaCaptura' ]                           := 1
    HeaderJson[ 'valorTitulo' ]                                     := SE2->E2_VALOR
    HeaderJson[ 'horaTransacao' ]                                   := StrTran( Time(), ":", "" )

    HeaderJson[ 'destinatarioDadosComum' ]                          := JsonObject():New()
    HeaderJson[ 'destinatarioDadosComum' ][ 'cpfCnpjDestinatario' ] := ""

    HeaderJson[ 'indicadorFuncao' ]                                 := 1
    HeaderJson[ 'nomeCliente' ]                                     := SE2->E2_NOMFOR
    HeaderJson[ 'numeroControleParticipante' ]                      := ""

    HeaderJson[ 'portadorDadosComum' ]                              := JsonObject():New()
    HeaderJson[ 'portadorDadosComum' ][ 'cpfCnpjPortador' ]         := ""

    HeaderJson[ 'remetenteDadosComum' ]                             := JsonObject():New()
    HeaderJson[ 'remetenteDadosComum' ][ 'cpfCnpjRemetente' ]       := ""

    HeaderJson[ 'transactionId' ]                                   := SE2->(Recno())
    cPostParms := HeaderJson:toJson()

    cSignature := 'POST' + _ENTER_ +; // _ENTER_ = (Chr(13)+Chr(10))
        '/oapi/v1'+ cMetodo + _ENTER_ +;
        _ENTER_ +;
        cPostParms   + _ENTER_ +;
        cAccessToken + _ENTER_ +;
        cXBradNonce  + _ENTER_ +;
        cTimestamp   + _ENTER_ +;
        'SHA256'     // + _ENTER_
    cSignature := EncodeUTF8( cSignature )
    cSignature := Encode64( EVPPrivSign( "\certs\cert.pem", cSignature, 5, "V@2023", @cErrStr ) )
    cSignature := Replace( cSignature, "/", "_")
    cSignature := Replace( cSignature, "+", "-")
    cSignature := Replace( cSignature, "=", "")

    AAdd(aHeadStr, "Authorization: Bearer " + cAccessToken       )
    AAdd(aHeadStr, "X-Brad-Signature: "     + cSignature         )
    AAdd(aHeadStr, "X-Brad-Nonce: "         + cXBradNonce        )
    AAdd(aHeadStr, "X-Brad-Timestamp: "     + cTimestamp         )
    AAdd(aHeadStr, "X-Brad-Algorithm: "     + "SHA256"           )
    AAdd(aHeadStr, "Access-token: "         + __cClientKey       )

    oRestClien := FwRest():New( cURL2 + "/" )
    oRestClien:SetPath( SubS(cMetodo, 2) )
    oRestClien:SetPostParams( EncodeUTF8(cPostParms, "cp1252") )
    
    lRet      := oRestClien:Post(aHeadStr)
    cPostRet  := oRestClien:GetResult()
    nHttpCode := HTTPGetStatus(@cHttpStat)

    If !FWJsonDeserialize( cPostRet, @oObj)
        Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else
        If  lRet := (lTrim(Str(nHttpCode)) $ cHttpVld) // Erro 500 se refere a ambiente instável
            cRetJson := Escape( cAccessToken /* oObj:access_token */ )
            
           //reclock("SE2",.F.)
           //    SE2->E2_XSTATUS := '4'
           //SE2->(MSUNLOCK())
        Else
            DBSELECTAREA( "ZCB" )
                RECLOCK( "ZCB", .T. )
                    ZCB->ZCB_FILIAL := FWxFilial("ZCB")
                    ZCB->ZCB_COD    := GETSXENUM("ZCB","ZCB_COD")
                    ZCB->ZCB_CODRET := oObj:CODIGO
                    ZCB->ZCB_DATA   := dDataBase
                    ZCB->ZCB_HORA   := TIME()
                    ZCB->ZCB_OBS    := oObj:MENSAGEM
                    ZCB->ZCB_TABELA := "SE2"
                    ZCB->ZCB_FIL    := SE2->E2_FILIAL
                    ZCB->ZCB_NUM    := SE2->E2_NUM
                    ZCB->ZCB_SERIE  := SE2->E2_TIPO
                    ZCB->ZCB_PARCEL := SE2->E2_PARCELA
                    ZCB->ZCB_FORN   := SE2->E2_FORNECE
                    ZCB->ZCB_LOJA   := SE2->E2_LOJA
                    ZCB->ZCB_ETAPA  := cMetodo
                ZCB->(MSUNLOCK())
            ZCB->(DBCLOSEAREA(  ))

            reclock("SE2",.F.)
                SE2->E2_XSTATUS := '3'
            SE2->(MSUNLOCK())
        EndIf
    EndIf
    //If !FWJsonDeserialize( cPostRet, @oObj)
    //    Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    //Else
    //    nHttpCode := HTTPGetStatus(@cHttpStat)
    //    If  nHttpCode == 200 .or. nHttpCode == 201 .or. nHttpCode == 500 // Erro 500 se refere a ambiente instável
    //        // cRet := oObj:access_token
    //        Alert("Deu Certo: " + cPostRet)
    //        MemoWrite("\DATA\CNAB\04-mtdEfetPagto-OK.txt", cPostRet)
    //    Else
    //        if Empty( cPostRet )
    //            conout( "Fail HTTPSPost" )
    //            Alert( cHeadRet, "Header" )
    //        else
    //            conout( "OK HTTPSPost" )
    //            Alert( cPostRet, "WebPage" )
    //        endif
    //    endif
    //EndIf

return cPostRet

Static Function fTratStr( cTexto )
    cTexto := EncodeUTF8( cTexto )
    cTexto := Encode64( cTexto )
    cTexto := Replace( cTexto, " ", "" )
    cTexto := Replace( cTexto, "\", "-" )
    cTexto := Replace( cTexto, "/", "-" )
    cTexto := Replace( cTexto, "=", "" )
Return cTexto

User Function RemoveAcento(cString)
    /*     Local nX        := 0
    Local nY        := 0
    Local cSubStr   := ""
    Local cRetorno  := ""
    Local cStrEsp   := "ÁÃÂÀáàâãÓÕÔóôõÇçÉÊéêºÜü"
    Local cStrEqu   := "AAAAaaaaOOOoooCcEEeerUu" //char equivalente ao char especial

    For nX:= 1 To Len(cString)
        cSubStr := SubStr(cString,nX,1)
        nY := At(cSubStr,cStrEsp)
        If nY > 0
            cSubStr := SubStr(cStrEqu,nY,1)
        EndIf
        cRetorno += cSubStr
    Next nX
    */
    cRetorno := StrTran( cString, "Á", "A")
    cRetorno := StrTran( cString, "á", "a")
    cRetorno := StrTran( cString, "À", "A")
    cRetorno := StrTran( cString, "à", "a")
    cRetorno := StrTran( cString, "ã", "a")
    cRetorno := StrTran( cString, "â", "a")
    cRetorno := StrTran( cString, "É", "E")
    cRetorno := StrTran( cString, "é", "e")
    cRetorno := StrTran( cString, "È", "E")
    cRetorno := StrTran( cString, "è", "e")
    cRetorno := StrTran( cString, "Ì", "I")
    cRetorno := StrTran( cString, "ì", "i")
    cRetorno := StrTran( cString, "Í", "I")
    cRetorno := StrTran( cString, "í", "i")
    cRetorno := StrTran( cString, "Õ", "O")
    cRetorno := StrTran( cString, "õ", "o")
    cRetorno := StrTran( cString, "Ü", "U")
    cRetorno := StrTran( cString, "ü", "u")

Return cRetorno


User Function statusfAPIBradesco()

    Local cMetodo    := "/pagamentos/boleto/consulta"
    // Local HeaderJson := JsonObject():New()
    // Local oObj := nil
    Local aHeadStr   := {}, cPostRet := ""
    // Local cErrStr  := "", cHeadRet := "", cHttpStat  := "", cPostParms := "", cSignature := '', nHttpCode  := 0

    AAdd(aHeadStr, "Content-Type: application/json"              )

    oRestClien := FwRest():New( cURL2 + "/" )
    oRestClien:SetPath( SubS(cMetodo, 2) )
    oRestClien:SetPostParams( cValToChar( SE2->(Recno()) ) )
    If oRestClien:Get(aHeadStr)
        cPostRet := oRestClien:GetResult()
        Alert("Deu Certo: " + cPostRet)
    Else
        ConOut("Ainda não")
        Alert(oRestClien:GetLastError() )
    EndIf

Return


/* MB : 28.09.2023 */
/*
Static Function mtdLimites( cAccessToken )
    Local cMetodo       := "/pagamentos/boleto/limites"
    Local nTimeOut   := 120
    Local aHeadStr   := {}
    Local cHeadRet   := ""
    Local cPostRet   := ""
    Local cGETParms := ""
    Local oObj       := nil// , oRestClien := nil
    Local cHttpStat  := ""
    Local nHttpCode  := 0

    AAdd(aHeadStr, "Accept: application/json")
    AAdd(aHeadStr, "grant_type: urn:ietf:params:oauth:grant-type:jwt-bearer")
    AAdd(aHeadStr, "assertion: " + cAccessToken)

    cGETParms := "agencia="               + '3995'
    cGETParms += "&bancoCliente="         + '237'
    cGETParms += "&agenciaCliente="       + '3995'
    cGETParms += "&digitoAgenciaCliente=" + "'0'"
    cGETParms += "&contaCliente="         + '75557'
    cGETParms += "&digitoContaCliente="   + "'5'"
    cGETParms := Escape(cGETParms)

    cPostRet := HTTPSGet( cURL1+cMetodo ,; // 01 // < cURL1 >
        "\certs\000001_all.pem",; // 02 // < cCertificate > // OU 000001_all
        "\certs\000001_key.pem",; // 03 // < cPrivKey >     // 000001_key chave privada
        "V@2023"               ,; // 04 // < cPassword >
        EncodeUTF8(cGETParms ) ,; // 05 // [ cGETParms ]
        nTimeOut               ,; // 06 // [ nTimeOut ]
        aHeadStr               ,; // 07 // [ aHeadStr ]
        @cHeadRet               ) // 08 // [ @cHeaderRet ]
    // HTTPSGet( < cURL1 >, < cCertificate >, < cPrivKey >, < cPassword >, [ cGETParms ], [ nTimeOut ], [ aHeadStr ], [ @cHeaderRet ], [ lClient ] )

    If !FWJsonDeserialize( cPostRet, @oObj)
        Alert( "Falha na estrutura do JSON de Retorno. Json: ") //"Falha na estrutura do JSON de Retorno .Pedido "##" Json"
    Else
        nHttpCode := HTTPGetStatus(@cHttpStat)
        If  nHttpCode == 200 .or. nHttpCode == 201 .or. nHttpCode == 500 // Erro 500 se refere a ambiente instável
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
static function BearerBatch( sHashHex, cPostRet )
    local cFileBatch := "bearer_" + AllTrim(__cUserID) + ".bat"
    local cLogFile   := "bearer_" + AllTrim(__cUserID) + ".log"
    local cStartPath := GetSrvProfString ("STARTPATH", "") // + "API_Bradesco\"
    local cSrvPath   := GetSrvProfString ("ROOTPATH", "") + cStartPath
    Local cAux       := ""
    // Local cHttpStat  := ""

    cAux := 'cURL1 --location "https://proxy.api.prebanco.com.br/auth/server/v1.2/token" ' +;
    ' --header "Content-Type: application/x-www-form-urlencoded" ' +;
        ' --data-urlencode  "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer" ' +;
        ' --data-urlencode  "assertion=' + sHashHex + '" '
    cAux += ' > ' + cLogFile
    // if !File(cStartPath + cFileBatch)
    MemoWrite(cStartPath + cFileBatch, cAux )
    // endif

    WaitRunSrv( cSrvPath+cFileBatch , .t. , cSrvPath )
    if File(cStartPath+cLogFile)
        cPostRet := MemoRead(cStartPath+cLogFile)
        // fErase(cStartPath+cFileBatch)
        fErase(cStartPath+cLogFile)
    endif

    // nHttpCode := HTTPGetStatus(@cHttpStat)
return // nHttpCode
*/
/*

# Ler o conteúdo dos arquivos JSON
$header = Get-Content -Raw header.json
$payload = Get-Content -Raw payload.json

# Remover espaços em branco e codificar em base64
$headerBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($header))
$payloadBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($payload))

# Remover caracteres especiais
$headerBase64 = $headerBase64 -replace ' ', ''
$payloadBase64 = $payloadBase64 -replace ' ', ''

# Substituir '+' e '/' por '-'
$headerBase64 = $headerBase64 -replace '\+', '-'
$headerBase64 = $headerBase64 -replace '/', '_'
$payloadBase64 = $payloadBase64 -replace '\+', '-'
$payloadBase64 = $payloadBase64 -replace '/', '_'

# Concatenar as partes
$stringToSign = $headerBase64 + "." + $payloadBase64

# Exibir o resultado
Write-Host $stringToSign



BIBLIOTECA
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


    https://jwt.io/
    https://www.timestamp-converter.com/

*/
