#INCLUDE "PROTHEUS.CH"
/*
Finalidade: Específico para clientes que utilizam o Ponto de entrada do faturamento SX5NOTA.
Objetivo: Alterar a validação padrão do campo FN6_SERIE na tela de baixa de ativos.
*/
User Function A036VLDSER()
Local oModel := PARAMIXB[1]
Local lRet   := .T.
Local aArea := GetArea()
Local aAreaSX5 := SX5->(GetArea())
 
If FWModeAccess("SX5",3) == 'E'  //exemplo se compartilhamento exclusivo
    lRet := oModel:GetValue("FN6_GERANF") == '1' .And. EXISTCPO('SX5','01'+oModel:GetValue("FN6_SERIE"))
Else 
    //se tabela SX5 compartilhada mas tabela 01 numero de serie for exclusivo tem que fazer com dbSeek()
    SX5->( dbSetOrder(1) )
    lRet := SX5->( dbSeek(cFilAnt+'01'+oModel:GetValue("FN6_SERIE")) ) //Onde cFilAnt é a filial  logada no momento
EndIf
 
RestArea(aAreaSX5)
RestArea(aArea)
 
Return lRet
