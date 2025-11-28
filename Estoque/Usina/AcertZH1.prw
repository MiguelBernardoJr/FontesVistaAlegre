//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TOTVS.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} AcertZH1
Função Gerar o ZH1 diario
@author Rodrigo Franco
@since 02/06/2025
@version 1.0
    @return Nil, Função não tem retorno
    @example
    u_GeraZH1()
    @obs Os campos chave usado entre cabeçalho e grid são:
/*/

User Function AcertZH1()

    Local aArea   := GetArea()
    Private dGetPerc1 := dDataBase

    AcerZH1(dGetPerc1)

    RestArea(aArea)

Return Nil


// Função para gravar na tabela ZH1
Static Function AcerZH1(dGetPerc1)

    dRef	:= dGetPerc1
    nSemana := RetSem(dRef)
    nMes	:= Month(dRef)
    cAno	:= Year(dRef)
    cOrd1   := ""
    cOrd2   := ""
    DBSelectArea("ZH2")
    DBGoTop()
    DBSetOrder(2)
    While !Eof()
        cOrd1 := ZH2->ZH2_ORDEM
        IF cOrd1 == cOrd2
            While !Eof()
                cOrd1 := ZH2->ZH2_ORDEM
                nNewOrd := VAL(cOrd1)+1
                cNewOrd := StrZero(nNewOrd,3)
                RecLock("ZH2",.F.)
                ZH2->ZH2_ORDEM := cNewOrd
                MsUnlock()
                DBSelectArea("ZH2")
                DBSkip()
            End
        ENDIF
        cOrd2 := ZH2->ZH2_ORDEM
        DBSelectArea("ZH2")
        DBSkip()
    End

    DBSelectArea("ZH2")
    DBGoTop()
    While !Eof()
        cProd := ZH2->ZH2_PROCES
        cUnid := ZH2->ZH2_UNIDAD
        cOrde := ZH2->ZH2_ORDEM
        cCalc := ZH2->ZH2_CALCUL

        DBSelectArea("ZH6")
        DBSetOrder(1)
        If DBSeek(xFilial("ZH6")+cValToChar(cAno)+cProd)
            // nZH6QTD :=  ZH6->ZH6_QUANT
        Else
            RecLock("ZH6",.T.)
            ZH6->ZH6_FILIAL	:= xFilial("ZH6")
            ZH6->ZH6_ANO	:= cValToChar(cAno)
            ZH6->ZH6_PROCES	:= cProd
            ZH6->ZH6_QUANT	:= 0
        EndIF
        nZH6QTD :=  ZH6->ZH6_QUANT

        DBSelectArea("ZH5")
        DBSetOrder(1)
        If DBSeek(xFilial("ZH5")+STR(nMes,2,0)+cProd)
            // nZH5QTD :=  ZH5->ZH5_QUANT
        Else
            RecLock("ZH5",.T.)
            ZH5->ZH5_FILIAL	:= xFilial("ZH5")
            ZH5->ZH5_MES	:= nMes
            ZH5->ZH5_PROCES	:= cProd
            ZH5->ZH5_QUANT	:= 0
        EndIF
        nZH5QTD :=  ZH5->ZH5_QUANT
        nSeman1 := Val(nSemana)

        DBSelectArea("ZH4")
        DBSetOrder(1)
        If DBSeek(xFilial("ZH4")+nSemana+cProd)
            //nZH4QTD :=  ZH4->ZH4_QUANT
        Else
            RecLock("ZH4",.T.)
            ZH4->ZH4_FILIAL	:= xFilial("ZH4")
            ZH4->ZH4_SEMANA	:= nSeman1
            ZH4->ZH4_PROCES	:= cProd
            ZH4->ZH4_QUANT	:= 0
        EndIF
        nZH4QTD :=  ZH4->ZH4_QUANT

        DBSelectArea("ZH1")
        DBSetOrder(1)
        If DBSeek(xFilial("ZH1")+DToS(dGetPerc1)+cOrde)
            IF SubStr(cCalc,1,4) == "SOMA"
                _cOrd1 := ""
                _cOrd2 := ""
                _cOrd3 := ""
                _cOrd4 := ""
                _cOrd5 := ""
                _cOrd6 := ""
                _cOrd7 := ""
                _cOrd8 := ""
                _cOrd1 := SubStr(cCalc,6,3)
                IF SubStr(cCalc,9,1) == ";"
                    _cOrd2 := SubStr(cCalc,10,3)
                    IF SubStr(cCalc,13,1) == ";"
                        _cOrd3 := SubStr(cCalc,14,3)
                        IF SubStr(cCalc,17,1) == ";"
                            _cOrd4 := SubStr(cCalc,18,3)
                            IF SubStr(cCalc,21,1) == ";"
                                _cOrd5 := SubStr(cCalc,22,3)
                                IF SubStr(cCalc,25,1) == ";"
                                    _cOrd6 := SubStr(cCalc,26,3)
                                    IF SubStr(cCalc,29,1) == ";"
                                        _cOrd7 := SubStr(cCalc,30,3)
                                        IF SubStr(cCalc,33,1) == ";"
                                            _cOrd8 := SubStr(cCalc,34,3)
                                        Endif
                                    Endif
                                Endif
                            Endif
                        Endif
                    Endif
                Endif
                nValOrdx := 0
                nValSoma := 0
                IF  _cOrd1 <> ""
                    DBSelectArea("ZH1")
                    DBSetOrder(1)
                    If DBSeek(xFilial("ZH1")+DToS(dGetPerc1)+_cOrd1)
                        nValOrdx := ZH1->ZH1_DIA
                        nValSoma := nValSoma + nValOrdx
                    Endif
                Endif
                IF  _cOrd2 <> ""
                    DBSelectArea("ZH1")
                    DBSetOrder(1)
                    If DBSeek(xFilial("ZH1")+DToS(dGetPerc1)+_cOrd2)
                        nValOrdx := ZH1->ZH1_DIA
                        nValSoma := nValSoma + nValOrdx
                    Endif
                Endif
                IF  _cOrd3 <> ""
                    DBSelectArea("ZH1")
                    DBSetOrder(1)
                    If DBSeek(xFilial("ZH1")+DToS(dGetPerc1)+_cOrd3)
                        nValOrdx := ZH1->ZH1_DIA
                        nValSoma := nValSoma + nValOrdx
                    Endif
                Endif
                IF  _cOrd4 <> ""
                    DBSelectArea("ZH1")
                    DBSetOrder(1)
                    If DBSeek(xFilial("ZH1")+DToS(dGetPerc1)+_cOrd4)
                        nValOrdx := ZH1->ZH1_DIA
                        nValSoma := nValSoma + nValOrdx
                    Endif
                Endif
                IF  _cOrd5 <> ""
                    DBSelectArea("ZH1")
                    DBSetOrder(1)
                    If DBSeek(xFilial("ZH1")+DToS(dGetPerc1)+_cOrd5)
                        nValOrdx := ZH1->ZH1_DIA
                        nValSoma := nValSoma + nValOrdx
                    Endif
                Endif
                IF  _cOrd6 <> ""
                    DBSelectArea("ZH1")
                    DBSetOrder(1)
                    If DBSeek(xFilial("ZH1")+DToS(dGetPerc1)+_cOrd6)
                        nValOrdx := ZH1->ZH1_DIA
                        nValSoma := nValSoma + nValOrdx
                    Endif
                Endif
                IF  _cOrd7 <> ""
                    DBSelectArea("ZH1")
                    DBSetOrder(1)
                    If DBSeek(xFilial("ZH1")+DToS(dGetPerc1)+_cOrd7)
                        nValOrdx := ZH1->ZH1_DIA
                        nValSoma := nValSoma + nValOrdx
                    Endif
                Endif
                IF  _cOrd8 <> ""
                    DBSelectArea("ZH1")
                    DBSetOrder(1)
                    If DBSeek(xFilial("ZH1")+DToS(dGetPerc1)+_cOrd8)
                        nValOrdx := ZH1->ZH1_DIA
                        nValSoma := nValSoma + nValOrdx
                    Endif
                Endif
                DBSelectArea("ZH1")
                DBSetOrder(1)
                If DBSeek(xFilial("ZH1")+DToS(dGetPerc1)+cOrde)
                    RecLock("ZH1", .F.)
                    ZH1->ZH1_DIA    := nValSoma
                    MsUnlock()
                Endif
            Endif
        Else
            RecLock("ZH1", .T.)
            ZH1->ZH1_FILIAL := xFilial("ZH2")
            ZH1->ZH1_DATA   := dGetPerc1
            ZH1->ZH1_PROCES := cProd
            ZH1->ZH1_UNIDAD := cUnid
            ZH1->ZH1_DIA    := 0
            ZH1->ZH1_SEMANA := nZH4QTD
            ZH1->ZH1_MES    := nZH5QTD
            ZH1->ZH1_ACUMUL := nZH6QTD
            ZH1->ZH1_ORDEM  := cOrde
            MsUnlock()
        EndIF
        DBSelectArea("ZH2")
        DBSkip()
    End

Return
