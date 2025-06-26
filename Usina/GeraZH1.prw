//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TOTVS.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} GeraZH1
Função Gerar o ZH1 diario
@author Rodrigo Franco 
@since 12/05/2025
@version 1.0
    @return Nil, Função não tem retorno
    @example
    u_GeraZH1()
    @obs Os campos chave usado entre cabeçalho e grid são:
/*/

User Function GeraZH1()

    Local aArea   := GetArea()
    Private dGetPerc1 := dDataBase

    GerZH1(dGetPerc1)

    RestArea(aArea)

Return Nil


// Função para gravar na tabela ZH1
Static Function GerZH1(dGetPerc1)

    dEmiss	:= dGetPerc1
    nSemana := RetSem(dEmiss)
    nMes	:= Month(dEmiss)
    cAno	:= Year(dEmiss)

    DBSelectArea("ZH2")
    DBGoTop()
    While !Eof()
        cProd := ZH2->ZH2_PROCES
        cUnid := ZH2->ZH2_UNIDAD
        cOrde := ZH2->ZH2_ORDEM

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
            // nZh1Sem := ZH1->ZH1_SEMANA
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
