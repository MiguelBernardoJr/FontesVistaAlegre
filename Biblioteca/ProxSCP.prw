#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} ProxSCP
    (long_description)
    @type  Function
    @author Igor Oliveira
    @since 22/04/2024
    @version 1.0
    @param param_name, param_type, param_descr
    @return cRet, string, retorna o ultimo código + 1 da tabela SCP
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function ProxSCP() //U_PROXSCP()
    Local aArea := GetArea()
    Local cRet := ""
    LOcal cQry := ""
    Local cAlias := GetNextAlias()
    
    cQry := "SELECT MAX(CP_NUM) as MAXIMO " + CRLF 
    cQry += "        FROM "+RetSqlName("SCP")+" " + CRLF 
    cQry += "        WHERE SUBSTRING(CP_NUM, 1, 3) != 'INT' " + CRLF 
    cQry += "            AND CP_FILIAL = '"+FWxFilial("SCP")+"'" + CRLF 
    //cQry += "            AND CP_NUM != '195593'" + CRLF 
    //cQry += "            AND D_E_L_E_T_ = ''" + CRLF 

    MpSysOpenQuery(cQry,cAlias)

    if !(cAlias)->(EOF())
       // if (cAlias)->MAXIMO == '195592'
       //     cRet := ALLTRIM(Str((Val((cAlias)->MAXIMO)+2)))
       // else
            cRet := ALLTRIM(Strzero((Val((cAlias)->MAXIMO)+1),6))
       //endif
    endif

    (cAlias)->(DBCloseArea())

    RestArea(aArea)
Return cRet
