#INCLUDE 'PROTHEUS.CH'

User Function MT103EXC()
    local lRet := .T.
    Local cChave 	:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
	Local lContinua := .T. // Valor padrão: permite exclusão

    If !EMPTY(SF1->F1_DTLANC)
        
        msgAlert("Antes de Excluir, procurar a Contabilidade para que faça a exclusão do lançamento contábil da nota fiscal","MT103EXC")
        
        lRet := .F.
    EndIf

    if lRet
        DbSelectArea("SD1")
        SD1->(DbSetOrder(1))

        If SD1->(Dbseek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

            While !SD1->(EoF()) .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cChave
                cProdBol	:= Alltrim(SD1->D1_COD)
                nQuantBo	:= SD1->D1_QUANT/2
                dEmissBo	:= SD1->D1_EMISSAO
                nSemana		:= RetSem(dEmissBo)
                nMes		:= Month(dEmissBo)
                cAno		:= Year(dEmissBo)

                IF cProdBol == "020194" .OR. cProdBol == "020138"
                    DBSelectArea("ZH6")
                    DBSetOrder(1)
                    If DBSeek(xFilial("ZH6")+cValToChar(cAno)+"PESO DO LEVEDO (BALANCA)                                    ")
                        nZH6QTD :=  ZH6->ZH6_QUANT
                        RecLock("ZH6",.F.)
                        ZH6->ZH6_QUANT	:= nZH6QTD - nQuantBo
                        MsUnlock()
                    Else
                        RecLock("ZH6",.T.)
                        ZH6->ZH6_FILIAL	:= xFilial("ZH6")
                        ZH6->ZH6_ANO	:= cValToChar(cAno)
                        ZH6->ZH6_PROCES	:= "PESO DO LEVEDO (BALANCA)                                    "
                        ZH6->ZH6_QUANT	:= nQuantBo
                    EndIF
                    nZH6QTD :=  ZH6->ZH6_QUANT
                    DBSelectArea("ZH5")
                    DBSetOrder(1)
                    If DBSeek(xFilial("ZH5")+STR(nMes,2,0)+"PESO DO LEVEDO (BALANCA)                                    ")
                        nZH5QTD :=  ZH5->ZH5_QUANT
                        RecLock("ZH5",.F.)
                        ZH5->ZH5_QUANT	:= nZH5QTD - nQuantBo
                        MsUnlock()
                    Else
                        RecLock("ZH5",.T.)
                        ZH5->ZH5_FILIAL	:= xFilial("ZH5")
                        ZH5->ZH5_MES	:= nMes
                        ZH5->ZH5_PROCES	:= "PESO DO LEVEDO (BALANCA)                                    "
                        ZH5->ZH5_QUANT	:= nQuantBo
                    EndIF
                    nZH5QTD :=  ZH5->ZH5_QUANT
                    nSeman1 := Val(nSemana)
                    DBSelectArea("ZH4")
                    DBSetOrder(1)
                    If DBSeek(xFilial("ZH4")+nSemana+"PESO DO LEVEDO (BALANCA)                                    ")
                        nZH4QTD :=  ZH4->ZH4_QUANT
                        RecLock("ZH4",.F.)
                        ZH4->ZH4_QUANT	:= nZH4QTD - nQuantBo
                        MsUnlock()
                    Else
                        RecLock("ZH4",.T.)
                        ZH4->ZH4_FILIAL	:= xFilial("ZH4")
                        ZH4->ZH4_SEMANA	:= nSeman1
                        ZH4->ZH4_PROCES	:= "PESO DO LEVEDO (BALANCA)                                    "
                        ZH4->ZH4_QUANT	:= nQuantBo
                    EndIF
                    nZH4QTD :=  ZH4->ZH4_QUANT
                    DBSelectArea("ZH1")
                    DBSetOrder(1)
                    If DBSeek(xFilial("ZH1")+DToS(dEmissBo)+"PESO DO LEVEDO (BALANCA)                                    ")
                        nDia	:= ZH1->ZH1_DIA
                        RecLock("ZH1",.F.)
                        ZH1->ZH1_DIA	:= nDia - nQuantBo
                        ZH1->ZH1_SEMANA	:= nZH4QTD
                        ZH1->ZH1_MES	:= nZH5QTD
                        ZH1->ZH1_ACUMUL	:= nZH6QTD
                        MsUnlock()
                    Else
                        DBSelectArea("ZH2")
                        DBSetOrder(1)
                        If DBSeek(xFilial("ZH2")+"PESO DO LEVEDO (BALANCA)                                    ")
                            cProdBol := ZH2->ZH2_PROCES
                            cUnid := ZH2->ZH2_UNIDAD
                            cOrde := ZH2->ZH2_ORDEM
                            RecLock("ZH1",.T.)
                            ZH1->ZH1_FILIAL	:= xFilial("ZH1")
                            ZH1->ZH1_DATA	:= dEmissBo
                            ZH1->ZH1_PROCES	:= cProdBol
                            ZH1->ZH1_UNIDAD	:= cUnid
                            ZH1->ZH1_DIA	:= nQuantBo
                            ZH1->ZH1_SEMANA	:= nZH4QTD
                            ZH1->ZH1_MES	:= nZH5QTD
                            ZH1->ZH1_ACUMUL	:= nZH6QTD
                            ZH1->ZH1_ORDEM	:= cOrde
                            ZH1->ZH1_NUMSEM	:= nSeman1
                            ZH1->ZH1_NUMMES	:= nMes
                            MsUnlock()
                        Else
                            MsgInfo("Processo nao emcontrado - PESO DO LEVEDO (BALANCA)                                    ","Nao encotrado")
                        EndIF
                    EndIF
                EndIF
                SD1->(DbSkip())
            EndDo
	    EndIF
    endif 

Return lRet
