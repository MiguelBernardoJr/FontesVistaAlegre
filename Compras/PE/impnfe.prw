#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"

User Function A103CND2()
    Local aDuplic := PARAMIXB
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)

    // Ponto de chamada Conex√£oNF-e sempre como √∫ltima instru√ß√£o.
    if lAtivo
        aDuplic := U_GTPE001()
    endif 
Return aDuplic

User Function A140EXC()
    Local lRet := .T.
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)
    
    // Ponto de chamada Conex√£oNF-e sempre como primeira instru√ß√£o.
    if lAtivo
        lRet := U_GTPE003()
    ENDIF

Return lRet

User Function MT103CWH()
    Local lRet := .T.
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)

    If lAtivo .and. lRet
        // Ponto de chamada Conex√£oNF-e sempre como √∫ltima instru√ß√£o.
        lRet := U_GTPE006()
    EndIf

Return lRet

User Function M145ARDEL()
    Local lRet := .T.
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)

    // Ponto de chamada Conex„oNF-e sempre como primeira instruÁ„o 
    If lAtivo
        lRet := U_GTPE018()
    endif
    //If
    //    Regra existente
    //    [...]
    //EndIf

Return lRet

User Function MA103ATF()
    Local aRet := {}
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)
    
    // Ponto de chamada Conex„oNF-e sempre como primeira instruÁ„o.
    If lAtivo
        aRet := U_GTPE015()
    endif 
    // If
    //     Regra existente
    //     [...]
    // EndIf

Return aRet

User Function MT103IP2()
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)

    if lAtivo
        // Ponto de chamada Conex√£oNF-e sempre como primeira instru√ß√£o.
        U_GTPE007() 
    endif 
 
Return Nil

User Function MT103TPC()        
    Local cTesPermit := PARAMIXB[1]
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)
    //If
	//	Regra existente
	//	[...]
	//EndIf
 
    if lAtivo
        // Ponto de chamada Conex„oNF-e sempre como ˙ltima instruÁ„o
        U_GTPE019()
    endif
Return cTesPermit

User Function MT103BDP()
    Local lRet := .F.
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)
    
    if lAtivo     
        // Ponto de chamada Conex„oNF-e sempre como primeira instruÁ„o.
        lRet := U_GTPE020()
    endif 
    // If
    //     Regra existente
    //     [...]
    // EndIf

Return lRet

User Function MT116GRV()
    Local nI := 0
    Local nPosProd
    Local nPosDesc
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)

    IF IsInCallStack("MATA116")
        For nI := 1 to Len(aCols)
            nPosProd := AScan(aHeader, {|x| AllTrim(x[2]) == "D1_COD"})
             nPosDesc := AScan(aHeader, {|x| AllTrim(x[2]) == "D1_X_DESC"})
            aCols[nI][nPosDesc] := Alltrim(Posicione("SB1",1,FWXFILIAL("SB1")+aCols[nI][nPosProd],"B1_DESC"))
        Next nI 
    ENDIF
    // Ponto de chamada Conex√£oNF-e sempre como √∫ltima instru√ß√£o.
    if lAtivo
        U_GTPE008()
    endif 
Return Nil

User Function MT140CAB()
    Local lRet := .T.
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)  
  
    // Ponto de chamada Conex√£oNF-e sempre como √∫ltima instru√ß√£o.
    If lAtivo .and. lRet
        lRet := U_GTPE009()
    EndIf

Return lRet

User Function MT140TOK()
    Local lRet := .T.
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)  
    
    if lAtivo 
        // Ponto de chamada Conex√£oNF-e sempre como primeira instru√ß√£o.
        lRet := U_GTPE011()
    endif 
    // Restri√ß√£o para valida√ß√µes n√£o serem chamadas duas vezes ao utilizar o importador da Conex√£oNF-e,
    // mantendo a chamada apenas no final do processo, quando a variavel l103Auto estiver .F.
    If lRet .And. !FwIsInCallStack('U_GATI001') .Or. !l103Auto
    
    EndIf

Return lRet

User Function MT140LOK()
    Local lRet := .T.
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)  
    
    if lAtivo 
        // Ponto de chamada Conex√£oNF-e sempre como primeira instru√ß√£o.
        lRet := U_GTPE012()
    endif 
    // Restri√ß√£o para valida√ß√µes n√£o serem chamadas duas vezes ao utilizar o importador da Conex√£oNF-e,
    // mantendo a chamada apenas no final do processo, quando a variavel l103Auto estiver .F.
    If lRet .And. !FwIsInCallStack('U_GATI001') .Or. !l103Auto
    EndIf

Return lRet

User Function MT140PC()
    Local lRet := .F.
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)  
    
    //If
	//	Regra existente
	//	[...]
	//EndIf
    
    if lAtivo
        // Ponto de chamada Conex„oNF-e sempre como ˙ltima instruÁ„o
        U_GTPE019()
    endif 
Return lRet

User Function MTCOLSE2()
    Local aColsE2   := aClone(PARAMIXB[1]) //aCols de duplicatas
    Local cAlias    := "" //aCols de duplicatas
    Local cAliasT   := "" //aCols de duplicatas
    Local nOpc      := PARAMIXB[2] //0-Tela de visualizaÁ„o / 1-Inclus„o ou ClassificaÁ„o
    Local _cQry     := ''
    Local nAt       := Len(aCols)
    Local nI,nX,nJ
    Local aDados    := {}
    Local aSE2      := {}
    Local cPed      := ''
    Local nSomaPar  := 0
    Local nVlrParc  := 0
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)  
    Local lPula     := .F.
    Local nTamSE2
    Local nPosPedido := 0
   // Local cChave        := cA100For + cLoja + cNFiscal + RTrim(cSerie) + dToS(ddEmissao)
   // Local cArquivo      := "\mata103-boletos\" + cChave + ".txt"
   // Local oFileWriter   := nil
   // Local oFileReader   := nil
   // Local aFileLines
   // Local cFullRead

    if nOpc == 1 .and. cEmpAnt == '01'
        nPosPedido := aScan(aHeader,{|x| Alltrim(x[2])=="D1_PEDIDO"})
        If nPosPedido > 0
            _cQry := " SELECT ZBC_CODIGO,ZBC_VERSAO,ZBC_PEDIDO FROM "+RetSqlName("ZBC")+" " + CRLF
            _cQry += " WHERE ZBC_PEDIDO = '"+iif(ValType(aCols[nAt][nPosPedido])=='N',cValToChar(aCols[nAt][nPosPedido]),aCols[nAt][nPosPedido])+"' " + CRLF
            _cQry += " AND ZBC_FILIAL = '"+fwxFilial("ZBC")+"'  " + CRLF
            _cQry += " AND D_E_L_E_T_ = ''  " + CRLF

            cAlias := MpSysOpenQry(_cQry)
            
            MemoWrite( "C:\totvs_relatorios\MTCOLSE2_ZBC.sql",_cQry )

            if !(cAlias)->(EOF())
                _cQry := " select * from "+RetSqlName("ZBD")+"  " + CRLF 
                _cQry += " WHERE ZBD_CODZCC = '"+(cAlias)->ZBC_CODIGO+"'  " + CRLF
                _cQry += " AND ZBD_ZCCVER = '"+(cAlias)->ZBC_VERSAO+"'  " + CRLF
                _cQry += " AND ZBD_CODPED = '"+(cAlias)->ZBC_PEDIDO+"'  " + CRLF
                _cQry += " AND ZBD_FILIAL = '"+fwxFilial("ZBD")+"'  " + CRLF

                _cQry += " AND D_E_L_E_T_ = ''  " + CRLF
                _cQry += " order by ZBD_CODPED,ZBD_ITEM " + CRLF
                
                MemoWrite( "C:\totvs_relatorios\MTCOLSE2_ZBD_.sql",_cQry )

                cAliasT := MpSysOpenQry(_cQry)

                WHILE !(cAliasT)->(Eof())
                    if cPed != (cAliasT)->ZBD_CODPED .and. Len(aSE2) > 0 
                        aAdd(aDados,{cPed,aSE2})
                        aSE2 := {}
                    endif
                    
                    aAdd(aSE2,{(cAliasT)->ZBD_ITEM,sTod((cAliasT)->ZBD_DATA)})

                    cPed := (cAliasT)->ZBD_CODPED
                    (cAliasT)->(DBSkip())
                EndDo

                if Len(aSE2) > 0
                    aAdd(aDados,{cPed,aSE2})
                    aSE2 := {}
                endif
                
                if Len(aDados) > 1
                    For nI := 1 to Len(aDados)
                        For nX := 1 to Len(aDados[nI][2])
                            if aDados[1][2][nX][2] != aDados[nI][2][nX][2]
                                MSGALERT( "Validar vencimentos do contrato antes de finalizar a nota. Validar com o comprador respons·vel!", "AtenÁ„o!" )
                                lPula := .T.
                                exit
                            endif
                        Next nX
                        if lPula
                            EXIT
                        endif
                    Next nI
                endif

                if !lPula
                    nTamSE2 := len(aColsE2)
                    For nI := 1 to Len(aDados)
                        if aDados[nI][1] == (cAlias)->ZBC_PEDIDO

                            if len(aColsE2) != Len(aDados[nI][2])
                                For nJ := 1 to Len(aColsE2)
                                    nSomaPar += aColsE2[nJ][3]
                                next nJ
                                nVlrParc := nSomaPar / Len(aDados[nI][2]) // divide o valor da primeira parcela pelo total de parcelas a pagar
                            else 
                                nVlrParc := aColsE2[1][3] // divide o valor da primeira parcela pelo total de parcelas a pagar
                            endif

                            For nX := 1 to Len(aDados[nI][2])
                                if nX > nTamSE2
                                    aAdd(aColsE2, aClone(aColsE2[nX-1]))
                                    aColsE2[nX][1] := StrZero(nX,2)
                                    aColsE2[nX][2] := aDados[nI][2][nX][2]
                                    aColsE2[nX][3] := Round(nVlrParc,2)
                                else
                                    aColsE2[nX][1] := StrZero(nX,2)
                                    aColsE2[nX][2] := aDados[nI][2][nX][2]
                                    aColsE2[nX][3] := Round(nVlrParc,2)
                                endif
                            Next nX
                        endif
                    Next ni
                endif

                (cAliasT)->(DbCloseArea())
            endif

            (cAlias)->(DbCloseArea())
        else
            if lAtivo 
                //Ponto de chamada Conex√£oNF-e sempre como primeira instru√ß√£o.
                aColsE2 := U_GTPE013()
            endif  
        endif  

        if Type("aColsE2") == "A"
            aCBrMT103 := {}
            For nI := 1 To Len(aColsE2)
                aAdd(aCBrMT103,{AllTrim(aColsE2[nI,17]),AllTrim(aColsE2[nI,18]) })
            Next nI
        endif

    endif

Return aColsE2

User Function MT140SAI()
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)  
    
    if lAtivo
        // Ponto de chamada Conex√£oNF-e sempre como primeira instru√ß√£o.
        U_GTPE016()
    endif 
    
    if Type("oGetDados") == "O".and. oGetDados:nOpc == 3 .or.  oGetDados:nOpc == 4
        U_VAMT140TOK(1)
    elseif Type("oGetDados") == "O".and. oGetDados:nOpc == 5 
        U_VAMT140TOK(99)
    endif

Return Nil
