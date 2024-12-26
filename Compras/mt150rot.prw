#include 'protheus.ch'
#include 'parmtype.ch'

user function mt150rot()
local aRotina := ParamIXB	

AAdd(aRotina, { "Reenvia Workflow", "u_SendWF", 0 , 4, 0, .f.})
AAdd(aRotina, { "Exporta Excel", "u_vacomr05", 0 , 4, 0, .f.})
AAdd(aRotina, { "Exporta Excel", "u_vacomr05", 0 , 4, 0, .f.})

return aRotina

user function SendWF(cAlias, nReg, nOpc)
local lEnvia := .t.

    if !Empty(SC8->C8_WFDT)
        lEnvia := (Aviso("Workflow de cotação", "Já foi enviado o workflow de solicitação de cotação para o fornecedor. Deseja reenviar?", {"Sim", "Não"}) == 1)
    endif

    if lEnvia
        U_MT130WF({{SC8->C8_NUM, SC8->C8_FORNECE+SC8->C8_LOJA, SC8->C8_NUMPRO}})
    endif

return nil
