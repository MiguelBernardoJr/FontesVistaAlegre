#Include "Protheus.ch"

User Function TR900CC()
//TQN_FILIAL+TQN_FROTA+DTOS(TQN_DTABAS)+TQN_HRABAS        
//NOMFL + VEIC + DATABA + HRAABA    
    Local cRet := ''
    Local _cQry := ''
    Local cAlias := ''                 

    if Type("VEIC") <> "U"
        cAlias := GetNextAlias()
        
        _cQry := "SELECT TQN_CCUSTO  " + CRLF
        _cQry += " FROM "+RetSqlName("TQN")+" " + CRLF
        _cQry += " WHERE TQN_FILIAL = '"+FILIAL+"'  " + CRLF
        _cQry += " AND TQN_FROTA = '"+VEIC+"'  " + CRLF
        _cQry += " AND TQN_DTABAS = '"+dToS(DATABA)+"'  " + CRLF
        _cQry += " AND TQN_HRABAS = '"+HRAABA+"' "  + CRLF

        MpSysOpenQuery(_cQry,cAlias)
        
        if !(cAlias)->(EOF())
            cRet := (cAlias)->TQN_CCUSTO 
        EndIF

        (cAlias)->(DbCloseArea())
    endif 
Return cRet
