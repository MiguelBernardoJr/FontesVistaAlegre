#include "Protheus.ch"
#include "FWMVCDEF.CH" 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980
Ponto de Entrada do Cadastro de Clientes (MVC)
@param      Não há
@return     Vários. Dependerá de qual PE está sendo executado.
@author     Lucas de Araujo Silva
@version    12.1.2410
@since      28/10/2025
/*/
//-------------------------------------------------------------------
User Function CRMA980() ///cXXX1,cXXX2,cXXX3,cXXX4,cXXX5,cXXX6
    Local aParam        := PARAMIXB
    Local xRet          := .T.
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
            if oObj:getoperation() == 3 .and. SA1->A1_MSBLQL == "1"  
                ApMsgInfo("Cadastro bloqueado, entre em contato com o setor fiscal para fazer a liberação","Atenção")

            EndIf
        EndIf
    
    EndIf
 
Return xRet
