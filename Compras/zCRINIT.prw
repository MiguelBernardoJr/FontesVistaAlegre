//Lucas de Araujo
//04/11/2025
//Inicializador do campo CR_XAPLICA na rotina "Liberar de Documentos"

#include 'Totvs.ch'

user function zCRINIT()
    Local aArea := FwGetArea()
    Local cRet  := ""
    Local cAlias := ""
    Local cQry   := "" 

    cQry :="   SELECT "+CRLF
    cQry +="   C1_FILIAL,"+CRLF
    cQry +="   C1_NUM,"+CRLF
    cQry +="   STRING_AGG(C1_XAPLICA, ', ') AS C1_XAPLICA"+CRLF
    cQry +="   FROM ("+CRLF
    cQry +="   -- Esta subquery seleciona apenas as combinações distintas"+CRLF
    cQry +="   SELECT DISTINCT"+CRLF
    cQry +="       C1_FILIAL,"+CRLF
    cQry +="       C1_NUM,"+CRLF
    cQry +="       C1_XAPLICA"+CRLF
    cQry +="   FROM "+RETSQLNAME("SC1")+""+CRLF
    cQry +="   WHERE "+CRLF
    cQry +="       C1_FILIAL = '"+SCR->CR_FILIAL+"'"+CRLF
    cQry +="       AND C1_PEDIDO = '"+rtrim(SCR->CR_NUM)+"'"+CRLF
    cQry +="       AND D_E_L_E_T_ = ''"+CRLF
    cQry +="   ) AS ValoresUnicos"+CRLF
    cQry +="   GROUP BY "+CRLF
    cQry +="   C1_FILIAL,"+CRLF
    cQry +="   C1_NUM"+CRLF

    cAlias := MpSysOpenQuery(cQry)
    
    if !(cAlias)->(eof())
        cRet := (cAlias)->C1_XAPLICA
    endif

    (cAlias)->(DbCloseArea())

    FwRestArea(aArea)
return cRet 
