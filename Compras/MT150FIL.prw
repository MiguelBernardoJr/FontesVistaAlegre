#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} MT150FIL
Ponto de Entrada Utilizado 
@type function
@version  
@author Arthur Toshio
@since 3/23/2023
@return cRet, Retorna filtro na execu��o do Mata150 ap�s o pergunte.
*/

User Function MT150FIL
Local cRet := ""
Local cCodComp := ""

    cCodComp := Posicione("SY1",3,FwXFilial("SY1")+__cUserId,"Y1_COD") 

    IF!(MsgYesNo( "Mostra cota��o de outros compradores ??", "Filtro" ))
        cRet := "C8_CODCOMP == '"+cCodComp+"' .OR. EMPTY(C8_CODCOMP)"
    EndIf
 // Customiza��o do clientecRet := " C8_NUM >= '000010'"
 Return cRet

