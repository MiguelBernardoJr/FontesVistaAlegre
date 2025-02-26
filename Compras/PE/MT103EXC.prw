#INCLUDE 'PROTHEUS.CH'

User Function MT103EXC()
    lRet := .T.

    If !EMPTY(SF1->F1_DTLANC)
        
        msgAlert("Antes de Excluir, procurar a Contabilidade para que fac?a a exclusa?o do lanc?amento conta?bil da nota fiscal","MT103EXC")
        
        lRet := .F.
    EndIf

Return lRet
