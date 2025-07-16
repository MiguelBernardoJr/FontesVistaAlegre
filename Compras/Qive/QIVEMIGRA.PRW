User Function QiveMigra()
Local dDtCorte := Date()
Local aPergs := {}
Local cTab3 := ""
Local cCmp3 := ""
Private nCount := 0

aAdd(aPergs, {1, "Data",  dDtCorte,  "", ".T.", "", ".T.", 80,  .F.})

    If ParamBox(aPergs, "Informe a data dos registros")
        U_CXTabNom("MV_XGTTAB3",@cTab3,@cCmp3)
        MsAguarde({|| FixFlags(cTab3,cCmp3) }, "Ajuste Flags", "Ajustando registros de flag")
    EndIf

    If nCount > 0
        FwAlertInfo("Foram alterados "+ nCount + " registros", "Correção de registros")
    ENDIF
Return

Static Function FixFlags(cTab3,cCmp3)
Local cQuery := ""
Local cAliasQry := ""
Local nAtual := 0
Local nTotal := 0
    
    cQuery := "SELECT R_E_C_N_O_ RECNO"
	cQuery +=  " FROM " + RetSqlName(cTab3) + " TAB3"
	cQuery += " WHERE TAB3." + cCmp3 + "_TIPO IN ('6','7')" // Lançado ERP e Manifesto de Confirmação
	cQuery += " AND TAB3."+ cCmp3 + "_SITINT IN ('1','2')" // Pendente ou com erro
	cQuery += " AND TAB3." + cCmp3 + "_DTCRIA <='"+DtoS(MV_PAR01)+"'
	cQuery += " AND TAB3.D_E_L_E_T_ = ' '"
	cAliasQry := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasQry, .F., .T.)
    
    Count to nTotal
	(cAliasQry)->(dbGoTop())
	
    Do While (cAliasQry)->(!Eof())
        nAtual++
        MsProcTxt("Verificados "+cValtoChar(nAtual)+ " registros de "+ cValtoChar(nTotal))
		(cTab3)->(dbGoTo( (cAliasQry)->RECNO ))
        RecLock(cTab3,.F.)
        (cTab3)->&(cCmp3 + "_SITINT") := "3"
        (cTab3)->(MsUnlock())
        nCount++
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
Return
