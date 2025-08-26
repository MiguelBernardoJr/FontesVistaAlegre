#include "protheus.ch"
#include "rwmake.ch"

User Function SD3250E()

	Local aArea    := Getarea()

	DbSelectarea ('SD3')
	DbSetOrder(1)

	If SD3->D3_FILIAL == "0101001" .AND. SD3->D3_ESTORNO == "S" .AND. SD3->D3_COD = "020138" .AND. SD3->D3_OP <> " " .AND. SD3->D3_TM == "004"
		DBSelectArea("ZH6")
		DBSetOrder(1)
		If DBSeek(xFilial("ZH6")+cValToChar(cAno)+"PRODUCAO DIARIA DE LEVEDURA ESTABILIZADA                    ")
			nZH6QTD :=  ZH6->ZH6_QUANT
			RecLock("ZH6",.F.)
			ZH6->ZH6_QUANT	:= nZH6QTD - nQuant
			MsUnlock()
		Else
			RecLock("ZH6",.T.)
			ZH6->ZH6_FILIAL	:= xFilial("ZH6")
			ZH6->ZH6_ANO	:= cValToChar(cAno)
			ZH6->ZH6_PROCES	:= "PRODUCAO DIARIA DE LEVEDURA ESTABILIZADA                    "
			ZH6->ZH6_QUANT	:= nQuant
		EndIF
		nZH6QTD :=  ZH6->ZH6_QUANT
		DBSelectArea("ZH5")
		DBSetOrder(1)
		If DBSeek(xFilial("ZH5")+STR(nMes,2,0)+"PRODUCAO DIARIA DE LEVEDURA ESTABILIZADA                    ")
			nZH5QTD :=  ZH5->ZH5_QUANT
			RecLock("ZH5",.F.)
			ZH5->ZH5_QUANT	:= nZH5QTD - nQuant
			MsUnlock()
		Else
			RecLock("ZH5",.T.)
			ZH5->ZH5_FILIAL	:= xFilial("ZH5")
			ZH5->ZH5_MES	:= nMes
			ZH5->ZH5_PROCES	:= "PRODUCAO DIARIA DE LEVEDURA ESTABILIZADA                    "
			ZH5->ZH5_QUANT	:= nQuant
		EndIF
		nZH5QTD :=  ZH5->ZH5_QUANT
		nSeman1 := Val(nSemana)
		DBSelectArea("ZH4")
		DBSetOrder(1)
		If DBSeek(xFilial("ZH4")+nSemana+"PRODUCAO DIARIA DE LEVEDURA ESTABILIZADA                    ")
			nZH4QTD :=  ZH4->ZH4_QUANT
			RecLock("ZH4",.F.)
			ZH4->ZH4_QUANT	:= nZH4QTD - nQuant
			MsUnlock()
		Else
			RecLock("ZH4",.T.)
			ZH4->ZH4_FILIAL	:= xFilial("ZH4")
			ZH4->ZH4_SEMANA	:= nSeman1
			ZH4->ZH4_PROCES	:= "PRODUCAO DIARIA DE LEVEDURA ESTABILIZADA                    "
			ZH4->ZH4_QUANT	:= nQuant
		EndIF
		nZH4QTD :=  ZH4->ZH4_QUANT
		DBSelectArea("ZH1")
		DBSetOrder(1)
		If DBSeek(xFilial("ZH1")+DToS(dEmiss)+"PRODUCAO DIARIA DE LEVEDURA ESTABILIZADA                    ")
			nDia	:= ZH1->ZH1_DIA
			RecLock("ZH1",.F.)
			ZH1->ZH1_DIA	:= nDia - nQuant
			ZH1->ZH1_SEMANA	:= nZH4QTD
			ZH1->ZH1_MES	:= nZH5QTD
			ZH1->ZH1_ACUMUL	:= nZH6QTD
			MsUnlock()
		Else
			DBSelectArea("ZH2")
			DBSetOrder(1)
			If DBSeek(xFilial("ZH2")+"PRODUCAO DIARIA DE LEVEDURA ESTABILIZADA                    ")
				cProd := ZH2->ZH2_PROCES
				cUnid := ZH2->ZH2_UNIDAD
				cOrde := ZH2->ZH2_ORDEM
				RecLock("ZH1",.T.)
				ZH1->ZH1_FILIAL	:= xFilial("ZH1")
				ZH1->ZH1_DATA	:= dEmiss
				ZH1->ZH1_PROCES	:= cProd
				ZH1->ZH1_UNIDAD	:= cUnid
				ZH1->ZH1_DIA	:= nQuant
				ZH1->ZH1_SEMANA	:= nZH4QTD
				ZH1->ZH1_MES	:= nZH5QTD
				ZH1->ZH1_ACUMUL	:= nZH6QTD
				ZH1->ZH1_ORDEM	:= cOrde
				ZH1->ZH1_NUMSEM	:= nSeman1
				ZH1->ZH1_NUMMES	:= nMes
				MsUnlock()
			EndIF
		EndIF

	EndIf

	restarea(aArea)
return
