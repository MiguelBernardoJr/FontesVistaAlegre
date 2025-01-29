#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function MT103PN()
    Local aParam := ParamIxb
Return .T.

USER FUNCTION MAT103OK() 
    Local lRet := ParamIxb[1]     //Customizações do usuário.
Return lRet

User Function ADOCVTOK()
    Local lRet:= .T.// Customização desejada para a validação conforme a regra de negócio praticada 
Return lRet
