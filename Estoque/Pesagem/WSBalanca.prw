#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "JSON.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "TOPCONN.CH"
// #INCLUDE "APWEBSRV.CH"

// User Function MBREST01(); return '20201015'

WSRESTFUL WSPesagem DESCRIPTION "Metodo para receber placa da portaria e fazer reserva na rotina de Pesagens." FORMAT APPLICATION_JSON
   
    WSDATA placa as STRING
    WSDATA cAgendamentoId as STRING

    WSMETHOD GET GetPodeManipular DESCRIPTION "Recebe a placa e o WS retorna os dados do ultimo registro existente na rotina de pesagem." ;
                WSSYNTAX "/WSPesagem/GetPodeManipular/";
                PATH     "/WSPesagem/GetPodeManipular/"
    
    WSMETHOD GET GetStatusProcesso DESCRIPTION "Recebe a placa e o WS retorna os dados do ultimo registro existente na rotina de pesagem." ;
                WSSYNTAX "/WSPesagem/GetStatusProcesso/";
                PATH     "/WSPesagem/GetStatusProcesso/"

    WSMETHOD GET RESERVAPLACA DESCRIPTION "Recebe a placa e o WS retorna os dados do ultimo registro existente na rotina de pesagem." ;
                WSSYNTAX "/WSPesagem/" //PATH "/WSPesagem/{placa}"
    
    WSMETHOD POST RESERVAPLACA DESCRIPTION "Inclusão de reserva de placa para futura pesagem." ;
                WSSYNTAX "/WSPesagem/" //PATH "/WSPesagem/{placa}"
    // WSMETHOD GET DESCRIPTION "Exemplo de retorno de entidade(s)" WSSYNTAX "/WSPesagem || /WSPesagem/{placa}"
    WSMETHOD PUT RESERVAPLACA DESCRIPTION "Inclusão de reserva de placa para futura pesagem." ;
                WSSYNTAX "/WSPesagem/{cAgendamentoId}"/* ;
                PATH "/WSPesagem/{cAgendamentoId}" */
    WSMETHOD DELETE RESERVAPLACA DESCRIPTION "Inclusão de reserva de placa para futura pesagem.";
                WSSYNTAX "/WSPesagem/{cAgendamentoId}"/* ;
                PATH "/{cAgendamentoId}" */
    
END WSRESTFUL

/*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 07.12.2021                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Envia a placa e o WS retorna os dados do ultimo registro existente na|
 |           rotina de pesagem.                                                    |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '--------------------------------------------------------------------------------*/
Class PlacaVeiculo
    Data empresa_id            as String    // 01
    Data agendamento_id        as String    // 02
    Data agendamento_data      as String    // 03
    Data placa                 as String    // 04
    Data fornecedor_id         as String    // 05
    Data fornecedor_nome       as String    // 06
    Data fornecedor_cnpj_cpf   as String    // 07
    Data motorista_id          as String    // 08
    Data motorista_cpf         as String    // 09
    Data motorista_nome        as String    // 10
    Data motorista_phone       as String    // 11
    Data produto_id            as String    // 12
    Data produto_descricao     as String    // 13
    Data departamento_id       as String    // 14
    Data departamento_destino  as String    // 15
    Data porteiro_id           as String    // 16
    Data porteiro_nome         as String    // 17
    Data operacao_tipo         as String    // 18
    Data status                as String    // 19

    Method New( ;
                empresa_id          ,;
                agendamento_id      ,;
                agendamento_data    ,;
                placa               ,;
                fornecedor_id       ,;
                fornecedor_nome     ,;
                fornecedor_cnpj_cpf ,;
                motorista_id        ,;
                motorista_cpf       ,;
                motorista_nome      ,;
                motorista_phone     ,;
                produto_id          ,;
                produto_descricao   ,;
                departamento_id     ,;
                departamento_destino,;
                porteiro_id         ,;
                porteiro_nome       ,;
                operacao_tipo       ,;
                status               ;
                ) Constructor

EndClass
Method New( ;
                empresa_id          ,;
                agendamento_id      ,;
                agendamento_data    ,;
                placa               ,;
                fornecedor_id       ,;
                fornecedor_nome     ,;
                fornecedor_cnpj_cpf ,;
                motorista_id        ,;
                motorista_cpf       ,;
                motorista_nome      ,;
                motorista_phone     ,;
                produto_id          ,;
                produto_descricao   ,;
                departamento_id     ,;
                departamento_destino,;
                porteiro_id         ,;
                porteiro_nome       ,;
                operacao_tipo       ,;
                status               ;
                ) Class PlacaVeiculo
        
    ::empresa_id           := empresa_id          
    ::agendamento_id       := agendamento_id      
    ::agendamento_data     := agendamento_data    
    ::placa                := placa               
    ::fornecedor_id        := fornecedor_id       
    ::fornecedor_nome      := fornecedor_nome     
    ::fornecedor_cnpj_cpf  := fornecedor_cnpj_cpf 
    ::motorista_id         := motorista_id        
    ::motorista_cpf        := motorista_cpf       
    ::motorista_nome       := motorista_nome      
    ::motorista_phone      := motorista_phone     
    ::produto_id           := produto_id          
    ::produto_descricao    := produto_descricao   
    ::departamento_id      := departamento_id     
    ::departamento_destino := departamento_destino
    ::porteiro_id          := porteiro_id         
    ::porteiro_nome        := porteiro_nome       
    ::operacao_tipo        := operacao_tipo       
    ::status               := status              
Return(Self)

/* MB : 09.03.2022
    -> Retorna o status do agendamento para atualizaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o da integr*/
WSMETHOD GET GetStatusProcesso WSRECEIVE WSSERVICE WSPesagem
    Local aArea         := {}
    Local aAreaZPB      := {}
    Local aAreaZFL      := {}
    Local __cMsg:= ""

    If !U_SetEnvironment()
        SetRestFault(404, "Problema ao abrir o dicionario de dados. Por favor, verifique a pastas system, os dicionarios de dados e os índices." )
        ConOut( "Problema ao abrir o dicionario de dados. Por favor, verifique a pastas system, os dicionarios de dados e os índices." )
    Else
        ConOut("")
        ConOut("")
        ConOut("")
        ConOut("")
        ConOut("")
        ConOut("Inicio metodo GET - GetStatusProcesso " + Time())
        aArea        := GetArea()
        aAreaZPB     := ZPB->(GetArea())
        aAreaZFL     := ZFL->(GetArea())

        ::SetContentType("application/json")

        IF Empty(::cAgendamentoId)
            ConOut("Codigo do agendamento nao informado")
            SetRestFault(400, "Codigo do agendamento nao informado")
        Else
            DbSelectArea("ZFL")
            ZFL->(DbSetOrder(1))
            If ZFL->(DbSeek( xFilial('ZFL')+::cAgendamentoId ))
                __cMsg := "Agendamento n: " + cValToChar(ZFL->ZFL_AGENID) + " se encontra com o status: " + ZFL->ZFL_STATUS
                ConOut( __cMsg )
                ::SetResponse('{"STATUS": "' + ZFL->ZFL_STATUS + '",'+;
                              '"descricao" : "' + __cMsg + '" }')
            Else
                __cMsg := "Agendamento nao localizado"
                ConOut( __cMsg )
                ::SetResponse('{"erro": "#",'+;
                              '"descricao" : "' + __cMsg + '" }')
            EndIf
            ZFL->(dbCloseArea())
        EndIf
    EndIf   
    RestArea(aAreaZFL)
    RestArea(aAreaZPB)
    RestArea(aArea)

Return .T.

/* MB : 09.03.2022
    -> Retorna se pode Alterar ou Deletar o registro de pesagem; */
WSMETHOD GET GetPodeManipular WSRECEIVE WSSERVICE WSPesagem
    Local aArea         := {}
    Local aAreaZPB      := {}
    Local aAreaZFL      := {}

    If !U_SetEnvironment()
        SetRestFault(404, "Problema ao abrir o dicionario de dados. Por favor, verifique a pastas system, os dicionarios de dados e os índices." )
        ConOut( "Problema ao abrir o dicionario de dados. Por favor, verifique a pastas system, os dicionarios de dados e os índices." )
    Else
        ConOut("")
        ConOut("")
        ConOut("")
        ConOut("")
        ConOut("")
        ConOut("Inicio metodo GET - GetPodeManipular " + Time())
        aArea        := GetArea()
        aAreaZPB     := ZPB->(GetArea())
        aAreaZFL     := ZFL->(GetArea())

        ::SetContentType("application/json")

        IF Empty(::cAgendamentoId)
            ConOut("Codigo do agendamento nao informado")
            SetRestFault(400, "Codigo do agendamento nao informado")
        else

            DbSelectArea("ZFL")
            ZFL->(DbSetOrder(1))
            If ZFL->(DbSeek( xFilial('ZFL')+::cAgendamentoId ))

                DbSelectArea("ZPB")
                ZPB->(DbSetOrder(1))
                ZPB->(DbGoTo( ZFL->(Recno() ) ))
                if (( ZPB -> ZPB_STATUS ) <> 'F')
                    ConOut("01-Registro pode ser manipulado.")
                    ::SetResponse('{"retorno": true,'+;
                                  '"descricao" : "Registro podera ser manipulado" }')
                Else
                    ConOut("02-Registro nao pode ser manipulado.")
                    ::SetResponse('{"retorno": false,'+;
                                  '"descricao" : "Registro NAO podera ser manipulado" }')
                EndIf
                ZPB->(dbCloseArea())
            Else
                ConOut("Agendamento nao localizado em nossos registros")
                SetRestFault(404, "Agendamento nao localizado em nossos registros")
            EndIf
            ZFL->(dbCloseArea())

        EndIf
    EndIf   
    RestArea(aAreaZFL)
    RestArea(aAreaZPB)
    RestArea(aArea)

Return .T.

WSMETHOD GET RESERVAPLACA WSRECEIVE placa WSSERVICE WSPesagem

Local aArea        := {}
Local aAreaZPB     := {}
Local aAreaZFL     := {}
Local lRet         := .T.
// Local _aMotorista  := {}
Local _nRecnoZPB  := {}
Local oObjeto      := nil
Local cJson        := ""

Local _ZFLAGENID := ""
Local _ZFLCELMOT := ""
Local _ZFLDPTOID := ""
Local _ZFLDPDEST := ""
Local _ZFLPORCOD := ""
Local _ZFLPORNOM := ""
Local _ZFLOPERAC := ""
Local _ZFLSTATUS := ""

Private placaTGet := Self:placa

If !U_SetEnvironment()
    SetRestFault(404, "Problema ao abrir o dicionario de dados. Por favor, verifique a pastas system, os dicionarios de dados e os índices." )
    ConOut( "Problema ao abrir o dicionario de dados. Por favor, verifique a pastas system, os dicionarios de dados e os índices." )
    lRet := .F.
Else

    ConOut("")
    ConOut("")
    ConOut("")
    ConOut("")
    ConOut("")
    ConOut("Inicio metodo GET: " + Time())
    aArea        := GetArea()
    aAreaZPB     := ZPB->(GetArea())
    aAreaZFL     := ZFL->(GetArea())

    // define o tipo de retorno do método
    ::SetContentType("application/json")

    If Empty(placaTGet)
        
        ConOut("Sem Parametros")
        // ::SetResponse('{"retorno": 9, "descricao": "Codigo da placa nao informado"}')
        SetRestFault(400, "Codigo da placa nao informado")
        lRet := .F.
    Else

        ConOut( "Placa: " + placaTGet )

        // _aMotorista := {"", "31039574831", "", "001", "Animal"}
        // _aMotorista := U_UltPesagemXPlaca(placaTGet)
        If ( (_nRecnoZPB := U_UltPesagemXPlaca(placaTGet)) > 0 )
            ConOut( "Recno ZPB: " + cValToChar(_nRecnoZPB) )
        EndIf

        // If Empty(_aMotorista) // preenchimento de campos automaticamente de acordo com a ultima pesagem do caminhao
        If Empty( _nRecnoZPB ) // preenchimento de campos automaticamente de acordo com a ultima pesagem do caminhao
            
            //::SetResponse('{"retorno": 1, "descricao": "Esta placa nao foi encontrada em nossos registros."}')
            SetRestFault(404, "Esta placa nao foi encontrada em nossos registros.")
            lRet := .F.

        Else

            // ConOut( U_AtoS(_aMotorista) )
            If _nRecnoZPB > 0
                ZPB->(DbGoTo( _nRecnoZPB )) 
                If !Empty(ZPB->ZPB_RCOZFL) .and. ZPB->ZPB_RCOZFL > 0
                    ZFL->(DbGoTo( ZPB->ZPB_RCOZFL )) 
                    _ZFLAGENID := cValToChar(ZFL->ZFL_AGENID)
                    _ZFLCELMOT := ZFL->ZFL_CELMOT
                    _ZFLDPTOID := ZFL->ZFL_DPTOID
                    _ZFLDPDEST := ZFL->ZFL_DPDEST
                    _ZFLPORCOD := ZFL->ZFL_PORCOD
                    _ZFLPORNOM := ZFL->ZFL_PORNOM
                    _ZFLOPERAC := ZFL->ZFL_OPERAC
                    _ZFLSTATUS := ZFL->ZFL_STATUS
                EndIf
            EndIf

            _cCPF_CNPJ := ""
            If ZPB->ZPB_CLIFOR == "F" // Fornecedor
                _cCPF_CNPJ := Posicione("SA2", 1, xFilial("SA2") + AllTrim(ZPB->ZPB_CODFOR) + AllTrim(ZPB->ZPB_LOJFOR), "A2_CGC" )
            Else // If ZPB->ZPB_CLIFOR == "C" // Cliente
                _cCPF_CNPJ := Posicione("SA1", 1, xFilial("SA1") + AllTrim(ZPB->ZPB_CODFOR) + AllTrim(ZPB->ZPB_LOJFOR), "A1_CGC" )
            EndIf
            oObjeto := PlacaVeiculo():New( ;
                                        AllTrim(ZPB->ZPB_FILIAL) ,;                     // 01
                                        AllTrim(_ZFLAGENID) ,;                          // 02
                                        DtoC(ZPB->ZPB_DATA) + " "  + ZPB->ZPB_HORA ,;   // 03
                                        AllTrim(ZPB->ZPB_PLACA) ,;                      // 04
                                        AllTrim(ZPB->ZPB_CODFOR+ZPB->ZPB_LOJFOR) ,;     // 05
                                        AllTrim(ZPB->ZPB_NOMFOR) ,;                     // 06
                                        AllTrim(_cCPF_CNPJ) ,;                          // 07
                                        AllTrim(ZPB->ZPB_CODMOT) ,;                     // 08
                                        AllTrim(ZPB->ZPB_CPFMOT) ,;                     // 09
                                        AllTrim(ZPB->ZPB_NOMMOT) ,;                     // 10
                                        AllTrim(_ZFLCELMOT) ,;                          // 11
                                        AllTrim(ZPB->ZPB_PRODUT) ,;                     // 12
                                        AllTrim(ZPB->ZPB_DESC) ,;                       // 13
                                        AllTrim(_ZFLDPTOID) ,;                          // 14
                                        AllTrim(_ZFLDPDEST) ,;                          // 15
                                        AllTrim(_ZFLPORCOD) ,;                          // 16
                                        AllTrim(_ZFLPORNOM) ,;                          // 17
                                        AllTrim(_ZFLOPERAC) ,;                          // 18
                                        AllTrim(_ZFLSTATUS) ;                           // 19
                                        )

            // --> Transforma o objeto de produtos em uma string json
            // cJson := '{"retorno": "0", "descricao": "Processo finalizado com sucesso."}'
            cJson := FwNoAccent( FWJsonSerialize(oObjeto, .F.) )
            ConOut( cJson )

            U_LogWs( cJson, "S") // SAIDA, ENVIANDO MSG PARA O APP

            // --> Envia o JSON Gerado para a aplicação Client
            ::SetResponse(cJson)

            ZPB->(dbCloseArea())
            ZFL->(dbCloseArea())
        EndIf
    EndIf
    RestArea(aAreaZPB)
    RestArea(aAreaZFL)
    RestArea(aArea)
EndIf
// u_ClearEnvironment()
ConOut("Fim: WSMETHOD " + Time())

Return lRet

// User Function onAuthorization( cUser, cPass )
// Local lRet as Logical
// return lRet := (cUser == 'admin' .and. cPass == 'V@2020')

WSMETHOD POST RESERVAPLACA WSRECEIVE WSSERVICE WSPesagem

Local nI            := 0 // as Integer
Local oParseJson
// Local cTextJson     := FwNoAccent( DecodeUtf8( ::GetContent() ) )
Local cTextJson     := ::GetContent()
// Local cTextJson     := ::GetContent()

ConOut(Replicate("-", 90))
ConOut("inicio Metodo POST: " + Time())

If !U_SetEnvironment()
    ConOut( "Problema ao abrir o dicionario de dados. Por favor, verifique a pastas system, os dicionarios de dados e os índices." )
Else
    // If Len(::aURLParms) > 0
    //     ::SetResponse('{"id":' + ::aURLParms[1] /* + ', "name":"sample"}' */)
    // EndIf

    For nI:=1 to Len(::aURLParms)
        ConOut("aURLParms " + cValToChar(nI) + ": " + ::aURLParms[nI] )
    Next nI

    ConOut( cTextJson )
    If FWJsonDeserialize(cTextJson, @oParseJson)
            
        Begin Transaction

            RecLock( "ZWS", .T. )
                ZWS->ZWS_FILIAL := xFilial("ZWS")
                ZWS->ZWS_CODIGO := GetSX8Num('ZWS','ZWS_CODIGO')
                ZWS->ZWS_TABELA := "ZFL"
                ZWS->ZWS_TIPO   := "J"
                ZWS->ZWS_JSON   := cTextJson
                ZWS->ZWS_WSDATA := MsDate()
                ZWS->ZWS_WSHORA := Time()
                ZWS->ZWS_STATUS := "0"
                ZWS->ZWS_METODO := "POST" + "-" + "RESERVAPLACA" // ::aURLParms[1]
                ZWS->ZWS_RECEIV := oParseJson:AGENDAMENTO_ID
            ZWS->(MsUnlock())
            ConfirmSX8()

		End Transaction
        U_LogWs( cTextJson, "E")

        //  names := oParseJson:GetNames()
        // ConOut("Integrado: " +CRLF+;
        //     "   Placa......: " + oParseJson:placa + Chr(13) + Chr(10) +;
        //     "   Produto....: " + oParseJson:produto + Chr(13) + Chr(10) +;
        //     "   Motorista..: " + oParseJson:motorista )
        ::SetResponse('{"retorno": "001-Reserva realizada com Sucesso."}')
        ConOut( "001-Reserva realizada com Sucesso." )

    Else
        ConOut( 'Erro ao converter JSON' )
        SetRestFault(500, 'Erro ao converter JSON' )
        ::SetResponse('{"retorno": "0-Erro ao converter JSON"}')        
    EndIf
EndIf
// U_ClearEnvironment()
ConOut("Fim: WSMETHOD " + Time())

Return .T. // lRet
// POST

/* MB : 06.01.2022 
    Postman: http://192.168.0.250:8099/WSVistaAlegre/WSPesagem\RESERVAPLACA?cAgendamentoId=100
*/
WSMETHOD PUT RESERVAPLACA WSRECEIVE WSSERVICE WSPesagem
Local _cMsg := ""
Local nI    := 0
// Local cTextJson     := FwNoAccent( DecodeUtf8( ::GetContent() ) )
Local cTextJson     := ::GetContent()

ConOut("")
ConOut("")
ConOut("")
ConOut("")
ConOut("")
ConOut( "[Metodo PUT]" )
// VarInfo( "Metodo PUT: ", ::cAgendamentoId )

If !U_SetEnvironment()
    ConOut( "Problema ao abrir o dicionario de dados. Por favor, verifique a pastas system, os dicionarios de dados e os índices." )
Else
    For nI:=1 to Len(::aURLParms)
        ConOut("aURLParms " + cValToChar(nI) + ": " + ::aURLParms[nI] )
    Next nI

    ConOut( cTextJson )
    Begin Transaction
        RecLock( "ZWS", .T. )
            ZWS->ZWS_FILIAL := xFilial("ZWS")
            ZWS->ZWS_CODIGO := GetSX8Num('ZWS','ZWS_CODIGO')
            ZWS->ZWS_TABELA := "ZFL"
            ZWS->ZWS_TIPO   := "J"
            ZWS->ZWS_JSON   := cTextJson
            ZWS->ZWS_WSDATA := MsDate()
            ZWS->ZWS_WSHORA := Time()
            ZWS->ZWS_METODO := "PUT" + "-" + "RESERVAPLACA" // ::aURLParms[1]
            ZWS->ZWS_RECEIV := ::cAgendamentoId
            ZWS->ZWS_STATUS := "0"
        ZWS->(MsUnlock())
        ConfirmSX8()
    End Transaction
    U_LogWs( cTextJson, "E")

    _cMsg := "001-Integração realizada com Sucesso. ID: " + ::cAgendamentoId
    _cMsg := FwNoAccent( _cMsg )
    ConOut( "Retorno: " + _cMsg )

    ::SetResponse('{"retorno": "' + _cMsg + '"}')
EndIf
// U_ClearEnvironment()
ConOut( "Time: " + Time() )
Return .T. // lRet



/* MB : 06.01.2022 
    Postman: http://192.168.0.250:8099/WSVistaAlegre/WSPesagem/RESERVAPLACA?cAgendamentoId=5678
*/
WSMETHOD DELETE RESERVAPLACA WSRECEIVE WSSERVICE WSPesagem
Local _cMsg := ""
Local nI    := 0
Local cTextJson     := "" // FwNoAccent( DecodeUtf8( ::GetContent() ) )
// ::SetContentType( 'application/json' )

ConOut( "" )
ConOut( "[Metodo DELETE]" )
// VarInfo( "Metodo DELETE: ", ::cAgendamentoId )

If !U_SetEnvironment()
    ConOut( "Problema ao abrir o dicionario de dados. Por favor, verifique a pastas system, os dicionarios de dados e os índices." )
Else
    For nI:=1 to Len(::aURLParms)
        ConOut("aURLParms " + cValToChar(nI) + ": " + ::aURLParms[nI] )
    Next nI

    ConOut( cTextJson )
    Begin Transaction
        RecLock( "ZWS", .T. )
            ZWS->ZWS_FILIAL := xFilial("ZWS")
            ZWS->ZWS_CODIGO := GetSX8Num('ZWS','ZWS_CODIGO')
            ZWS->ZWS_TABELA := "ZFL"
            ZWS->ZWS_TIPO   := "J"
            ZWS->ZWS_JSON   := cTextJson
            ZWS->ZWS_WSDATA := MsDate()
            ZWS->ZWS_WSHORA := Time()
            ZWS->ZWS_METODO := "DELETE" + "-" + "RESERVAPLACA" // ::aURLParms[1]
            ZWS->ZWS_RECEIV := ::cAgendamentoId
            ZWS->ZWS_STATUS := "0"
        ZWS->(MsUnlock())
        ConfirmSX8()
    End Transaction
    U_LogWs( cTextJson, "E")

    _cMsg := "001-Integracao realizada com Sucesso. ID: " + ::cAgendamentoId
    _cMsg := FwNoAccent( _cMsg )
    ConOut( _cMsg )

    ::SetResponse('{"retorno": "' + _cMsg + '"}')
EndIf
// U_ClearEnvironment()
ConOut( "Time: " + Time() )
Return .T. // lRet

/* MB : 20.01.2022
    -> Teste Metodo Get
     * U_WSTestGet("DVS-8336")
*/
User Function WSTestGet( __cPlaca )
Local aHeader     := {}
Local oRestClient := FWRest():New("http://192.168.0.250:8099" )

aAdd(aHeader, "Content-Type: application/json")

oRestClient:setPath("/WSVistaAlegre/WSPesagem")
oRestClient:setPath("/RESERVAPLACA?placa=" + __cPlaca)

If oRestClient:Get(aHeader)
    cTextJson := oRestClient:GetResult()
    If FWJsonDeserialize(cTextJson, @oParseJson)            
        Alert("Resultado: " + CRLF + oParseJson:retorno)
    EndIf
Else
    ConOut(oRestClient:GetLastError())
    Alert( StrTran( oRestClient:GetLastError(), ',"', Chr(13) + Chr(10)+'"') )
EndIf
FwFreeObj(oRestClient)

Return .T.

// /* Consumir / Ler API Rest */
// // U_WSEnviaPlaca( "AAA"+"-"+StrTran(SubS(Time(),1,5),":",""), 'MILHO VERDE', "Miguel " + DtoS(dDataBase) + " " + StrTran(SubS(Time(),1,5),":",""))
// User Function WSEnviaPlaca(cPlaca, cProduto, cMotorista) 
//     Local aArea       := GetArea()
//     Local aHeader     := {}
//     Local oRestClient := FWRest():New("http://192.168.0.250:8099" )
//     Local _aJSon      // := {}
//     local cTextJson
//     Local oParseJson    := NIL
// 
//     aAdd(aHeader, "Content-Type: application/json")
//     // aadd(aHeader,'Authorization: Basic YmVybmFyZG86YQ==') // bernardo/a => meu usuario no protheus    
//     // oRestClient:setPath("/produtos?codproduto=" + cProduto)
//     
//     oRestClient:setPath("/WSVistaAlegre/WSPesagem")
//     // https://jsonformatter.org/json-editor - editor on line
//     _aJSon := '{ "placa" : "'+cPlaca+;
//              '", "produto": "'+cProduto+;
//              '", "motorista": "'+cMotorista+'" }'
//     oRestClient:SetPostParams( _aJSon )
//     If oRestClient:Post(aHeader)
//         
//         cTextJson := oRestClient:GetResult()
//         If FWJsonDeserialize(cTextJson, @oParseJson)            
//             Alert("Resultado: " + CRLF + oParseJson:retorno)
//         EndIf
// 
//     Else
//         ConOut(oRestClient:GetLastError())
//         Alert( StrTran( oRestClient:GetLastError(), ',"', Chr(13) + Chr(10)+'"') )
//     EndIf
// 
//     FwFreeObj(oRestClient)
//     RestArea(aArea)
// Return 
// 
// 
// /* Consumir / Ler API Rest */
// User Function tstWSBalanca( cProduto ) // U_TSTWSBalanca('020015')
// // Local cProduto := '020017'
// Local oRestClient := FWRest():New("http://192.168.0.250:8099" )
// 
// Local aHeader := {}
// // aadd(aHeader,'Authorization: Basic YmVybmFyZG86YQ==') // bernardo/a => meu usuario no protheus
// 
// // oRestClient:setPath("/produtos?codproduto=" + cProduto)
// oRestClient:setPath("/WSVistaAlegre/WSBalanca")
// aadd(aHeader, 'CODPRODUTO: ' + cProduto)
// 
// If oRestClient:Get(aHeader)
//    ConOut(oRestClient:GetResult())
//    Alert(StrTran(oRestClient:GetResult(), ',"', Chr(13) + Chr(10)+'"'))
// Else
//    ConOut(oRestClient:GetLastError())
// 	Alert( StrTran( oRestClient:GetLastError(), ',"', Chr(13) + Chr(10)+'"') )
// EndIf
// 
// Return 

User Function SetEnvironment()
local lRet := .t. 

	if cEmpAnt <> "01" .OR. cFilAnt <> "01" .OR. Select("SM0") == 0 

        ConOut("Entrou na funcao: SetEnvironment: Select('SM0')")

		// dbusearea( .t.,, "sigamat.emp", "sm0", .t., .f. )
		// dbsetindex("sigamat.ind")
        OpenSM0( "01" + "01", .F.)

		dbselectarea("SM0")
		dbsetorder(1)
        // dbgotop()
        SM0->(DbSeek( "01" + "01" ))

	EndIf

	// RpcSetType(3)
	// RpcSetEnv(SM0->M0_CODIGO,SM0->M0_CODFIL)
	
	lRet := (select("SX3") > 0)
return lRet
			
// user function ClearEnvironment()
//     RpcClearEnv()
// return nil


// /* ############################################################################################################################## */
// WSMETHOD POST ID_2 WSSERVICE WSBalanca
// 
//     ::SetResponse('{"id":"' + ::aURLParms[1] + '", "name":"WSBalanca", "method":"post id","version":"2"}')
// 
// Return .T.
// 
// /* ############################################################################################################################## */
// WSMETHOD PUT V2 PATHPARAM path1, path2 WSSERVICE WSBalanca
// 
//     ::SetResponse('{"path1":"' + ::path1 + '","path2":"' + ::path2 + '", "urlparm1":"' + ::aURLParms[1] + '","urlparm2":"' + ::aURLParms[2] + '","name":"WSBalanca", "method":"put twoparms"')
//     ::SetResponse(',"version":"2"}')
// 
// Return .T.
// 
// 
// /* ############################################################################################################################## */
// WSMETHOD PUT reservaPlaca PATHPARAM placa WSSERVICE WSBalanca
// 
//     ::SetResponse('{"placa":"' + ::placa + '", "urlparm1":"' + ::aURLParms[1] + '","urlparm2":"' + ::aURLParms[2] + '","name":"WSBalanca", "method":"put twoparms"')
//     ::SetResponse(',"version":"2"}')
// 
// Return .T.


/*
BIBLIOTECA

    https://devforum.totvs.com.br/1515-metodo-post-api-rest-em-advpl

    https://jsoneditoronline.org/#left=local.tusuju&right=local.zoluja

    -> https://tdn.totvs.com/pages/viewpage.action?pageId=75269436

Retorno json
{
"retorno": "Não foi localizado nenhuma informacao."
}

*/

