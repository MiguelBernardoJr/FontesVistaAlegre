#include "totvs.ch"
#include "FWMVCDEF.CH" 

user function CUSTOMERVENDOR()

    local lRet          := .T. 
    Local aParam        := PARAMIXB
    Local lIsGrid       := .F.
    Local cIDPonto      := ''
    Local cIDModel      := ''
    Local oObj          := NIL
 
If aParam <> NIL
 
    oObj        := aParam[1]
    cIDPonto    := aParam[2]
    cIDModel    := aParam[3]
    lIsGrid     := (Len(aParam) > 3)
 
    If cIDPonto == 'MODELCOMMITNTTS'
        if oObj:getoperation() == 3 .and. SA2->A2_MSBLQL == "1"  
            ApMsgInfo("Cadastro bloqueado, entre em contato com o setor fiscal para fazer a liberação","Atenção")
        EndIf
    EndIf
    
EndIf

return lRet
