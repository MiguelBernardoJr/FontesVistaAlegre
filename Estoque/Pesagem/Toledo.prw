#INCLUDE 'PROTHEUS.CH'
/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  ToledoSocket 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  22.10.2020                   	          	            	              |
 | Desc:  Conecta na balanca e pega o resultado;                                  |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
            '--------------------------------------------------------------------------------*/
            User Function ToledoSocket( lConverte )
                Local oObj        := tSocketClient():New()
                Local nX          := 0
                Local nIp         := GetMV("MB_BalTolI",, '192.168.0.168' )
                Local nPort       := GetMV("MB_BAlTolP",, 9000)
                Local cBuffer     := ""
                Local xRetorno

                Default lConverte := .T.

                xRetorno          := iIf(lConverte, 0, "0")

                // -------------------------------
                // Tenta conectar 3 vezes
                // -------------------------------
                For nX := 1 to GetMV("MB_BAlTolT",, 3)
                    nResp := oObj:Connect( nPort,nIp,10 )
                    if(nResp == 0 )
                        exit
                    else
                        conout("--> Tentativa de Conexão: " + StrZero(nX,3))
                        Sleep(2000)
                        // continue
                        Alert("Sem conectividade com a balança para a coleta do peso, tentativa nº " +cValtoChar(nX)+ ". Esta mensagem aparece quando o sistema solicita o peso para a balança e não ocore a resposta. Verificar se a balança está ligada e se o cabo de comunicação está ok.")
                    endif
                Next

                // --------------------------------------
                // Verifica se a conexão foi bem sucedida
                // --------------------------------------
                if( !oObj:IsConnected() )
                    conout("--> Falha na conexão")
                    return xRetorno
                else
                    conout("--> Conexão OK")
                endif

                // -------------------------------
                // Teste de envio para o socket
                // -------------------------------
                cSend := OemToAnsi("Nao precisa ser enviado nada.") // Dados enviados pelo AdvPL..."
                nResp := oObj:Send( cSend )
                if( nResp != len( cSend ) )
                    conout( "--> Erro! Dado nao transmitido" )
                else
                    conout( "-- > Dado Enviado - Retorno: " +StrZero(nResp,5) )
                endif

                // -------------------------------
                // Teste de recebimento do socket
                // -------------------------------
                nResp = oObj:Receive( @cBuffer, 10000 )
                if( nResp >= 0 )
                    conout( "--> Dados Recebidos " + StrZero(nResp,5) )
                    conout( "--> ["+cBuffer+"]" )

                    If lConverte
                        if !Empty(cBuffer)
                            cBuffer := SubS(cBuffer, 5, Len(SubS(cBuffer, 5))-1)
                            xRetorno    := Val( SubS( cBuffer, 1, 6)+'.'+SubS( cBuffer, 7) )

                            If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
                                MemoWrite( "C:\totvs_relatorios\Pesagem_" + AllTrim(cPlacaTGet) + "_" + DtoS(MsDate()) + "_" + StrTran(Time(),":","") + ".txt",;
                                    cBuffer+/* CRLF+ */cValToChar(xRetorno) )
                            EndIf
                        EndIf
                    EndIf
                else
                    conout( "--> Nao recebi dados" )
                endif

                // -------------------------------
                // Fecha conexão
                // -------------------------------
                oObj:CloseConnection()
                conout( "--> Conexão fechada" )

            Return xRetorno// Return cBuffer
