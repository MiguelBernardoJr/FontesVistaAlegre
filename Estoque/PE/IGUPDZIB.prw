#Include 'Protheus.ch'
#Include "TbiConn.ch"

User Function IGUPDZIB()
    Local aArea := GetArea()
	Local cAlias 	:= GetNextAlias()
    Local cQry      := ''
    Local cDtAnt    := ''
    Local nI        := 0

    
    //ZIB_FILIAL+ZIB_CONFNA+ZIB_CURRAL+ZIB_DATA
    
    cQry := "select * from  "+ RetSqlName("ZIB") +" where D_E_L_E_T_ = '' order by ZIB_DATA"

    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry), cAlias, .F., .T. )
    
    dbSelectArea("ZIB")
    dbSetOrder(1)
    ZIB->(DbGoTop())

    while !(cAlias)->(EOF())
        if DbSeek(xFilial('ZIB')+(cAlias)->ZIB_CONFNA+(cAlias)->ZIB_CURRAL+(cAlias)->ZIB_DATA)
            
            if cDtAnt != (cAlias)->ZIB_DATA
                cDtAnt := (cAlias)->ZIB_DATA
                nI++
            endif

            RecLock("ZIB", .F.)
                ZIB->ZIB_COD := STRZERO(NI,6)
            MsUnlock()
        endif 
        (cAlias)->(DbSkip())
    end 

    (cAlias)->(DbCloseArea())

    RestArea(aArea)
Return 
