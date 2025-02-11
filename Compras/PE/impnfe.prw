#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"

User Function A103CND2()
Local aDuplic := PARAMIXB


    // Ponto de chamada ConexãoNF-e sempre como última instrução.
    aDuplic := U_GTPE001()

Return aDuplic


User Function A140EXC()
Local lRet := .T.

    // Ponto de chamada ConexãoNF-e sempre como primeira instrução.
    lRet := U_GTPE003()


Return lRet

User Function MT103CWH()
Local lRet := .T.

  

    If lRet
        // Ponto de chamada ConexãoNF-e sempre como última instrução.
        lRet := U_GTPE006()
    EndIf

Return lRet

User Function MT103IP2()

    // Ponto de chamada ConexãoNF-e sempre como primeira instrução.
    U_GTPE007() 

 
Return Nil

User Function MT116GRV()
    Local nI := 0
    Local nPosProd
    Local nPosDesc

    // Ponto de chamada ConexãoNF-e sempre como última instrução.
    U_GTPE008()

    IF IsInCallStack("MATA116")
        For nI := 1 to Len(aCols)
            nPosProd := AScan(aHeader, {|x| AllTrim(x[2]) == "D1_COD"})
             nPosDesc := AScan(aHeader, {|x| AllTrim(x[2]) == "D1_X_DESC"})
            aCols[nI][nPosDesc] := Alltrim(Posicione("SB1",1,FWXFILIAL("SB1")+aCols[nI][nPosProd],"B1_DESC"))
        Next nI 
    ENDIF
Return Nil

User Function MT140CAB()
Local lRet := .T.

  
    // Ponto de chamada ConexãoNF-e sempre como última instrução.
    If lRet
        lRet := U_GTPE009()
    EndIf

Return lRet

User Function MT140TOK()
Local lRet := .T.

    // Ponto de chamada ConexãoNF-e sempre como primeira instrução.
    lRet := U_GTPE011()

    // Restrição para validações não serem chamadas duas vezes ao utilizar o importador da ConexãoNF-e,
    // mantendo a chamada apenas no final do processo, quando a variavel l103Auto estiver .F.
    If lRet .And. !FwIsInCallStack('U_GATI001') .Or. !l103Auto
    
    EndIf

Return lRet

User Function MT140LOK()
Local lRet := .T.

    // Ponto de chamada ConexãoNF-e sempre como primeira instrução.
    lRet := U_GTPE012()

    // Restrição para validações não serem chamadas duas vezes ao utilizar o importador da ConexãoNF-e,
    // mantendo a chamada apenas no final do processo, quando a variavel l103Auto estiver .F.
    If lRet .And. !FwIsInCallStack('U_GATI001') .Or. !l103Auto
    EndIf

Return lRet

User Function MTCOLSE2()
    Local aColsE2   := aClone(PARAMIXB[1]) //aCols de duplicatas
    Local cAlias    := GetNextAlias() //aCols de duplicatas
    Local cAliasT    := GetNextAlias() //aCols de duplicatas
    Local nOpc      := PARAMIXB[2] //0-Tela de visualiza��o / 1-Inclus�o ou Classifica��o
    Local _cQry     := ''
    Local nAt       := Len(aCols)
    Local nI,nX,nJ
    Local aDados    := {}
    Local aSE2      := {}
    Local cPed      := ''
    Local nSomaPar  := 0
    Local nVlrParc  := 0

    Local lPula     := .F.
    Local nTamSE2

   // Local cChave        := cA100For + cLoja + cNFiscal + RTrim(cSerie) + dToS(ddEmissao)
   // Local cArquivo      := "\mata103-boletos\" + cChave + ".txt"
   // Local oFileWriter   := nil
   // Local oFileReader   := nil
   // Local aFileLines
   // Local cFullRead

    if nOpc == 1 .and. cEmpAnt == '01'

        _cQry := " SELECT ZBC_CODIGO,ZBC_VERSAO,ZBC_PEDIDO FROM "+RetSqlName("ZBC")+" " + CRLF
        _cQry += " WHERE ZBC_PEDIDO = '"+iif(ValType(aCols[nAt][16])=='N',cValToChar(aCols[nAt][16]),aCols[nAt][16])+"' " + CRLF
        _cQry += " AND ZBC_FILIAL = '"+fwxFilial("ZBC")+"'  " + CRLF
        _cQry += " AND D_E_L_E_T_ = ''  " + CRLF

        MpSysOpenQry(_cQry,cAlias)
        
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

            MpSysOpenQry(_cQry,cAliasT)

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
                            MSGALERT( "Validar vencimentos do contrato antes de finalizar a nota. Validar com o comprador respons�vel!", "Aten��o!" )
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
        else
            //Ponto de chamada ConexãoNF-e sempre como primeira instrução.
            aColsE2 := U_GTPE013()
        endif  
        (cAlias)->(DbCloseArea())

        aCBrMT103 := {}
        For nI := 1 To Len(aColsE2)
            aAdd(aCBrMT103,{AllTrim(aColsE2[nI,17]),AllTrim(aColsE2[nI,18]) })
        Next nI

    endif

Return aColsE2

User Function MT140SAI()

    // Ponto de chamada ConexãoNF-e sempre como primeira instrução.
    U_GTPE016()


Return Nil
