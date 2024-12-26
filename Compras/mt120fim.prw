#include 'protheus.ch'
#include 'parmtype.ch'

user function mt120fim()
local aArea := GetArea()
local nOpc := ParamIXB[1]
local cPedido := ParamIXB[2]
local nOpcA := ParamIXB[3]

if (nOpc == 4 .or. nOpc == 3) .and. nOpcA == 1
    
    DbSelectArea("SAK")
    DbSetOrder(1) // AK_FILIAL+AK_COD
    
    DbSelectArea("SCR")
    DbSetOrder(1) // CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL

    if SCR->(DbSeek(xFilial("SCR")+"PC"+PadR(SC7->C7_NUM, TamSX3("CR_NUM")[1])))
        while SCR->CR_FILIAL == xFilial("SCR") .and. SCR->CR_TIPO == "PC" .and. SCR->CR_NUM = SC7->C7_NUM
            SAK->(DbSeek(xFilial("SAK")+SCR->CR_APROV))
            u_SndLib(SC7->C7_NUM, SAK->AK_USER)
            SCR->(DbSkip())
        end
    endif
endif

RestArea(aArea)
return nil

