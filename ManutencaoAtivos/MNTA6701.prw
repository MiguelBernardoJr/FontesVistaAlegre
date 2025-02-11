#Include 'Protheus.ch'

User Function MNTA6701()
    Local nQtLitros := PARAMIXB[1] //Quantidade de Litros à Conciliar
    Local aRet656VL := PARAMIXB[2] //Informação de validação de hodômetro e atualização de estoque e quantidade do abastecimento
    Local oDlg1 := PARAMIXB[3] //Objeto onde os campos serão apresentados
    Local oQtdBom, oQtdAfe, oQtdAbast, oQtdTotal
    Local nQtdBom, nQtdAfer, nQtdAbast, nQtdTotal

    nQtdAbast := nQtLitros
    nQtdAfer := If( Empty(aRet656VL), 0, aRet656VL[1] )
    nQtdTotal := nQtdAbast + nQtdAfer
    //nQtdBom := MNTA670TTA()

    // @ 208,010 Say "Contador Bomba" Size 55,10 Of oDlg1 Pixel color CLR_BLUE
    //
    // @ 208,050 Say oQtdBom Var nQtdBom Size 40,10 Of oDlg1 Pixel Picture "@E 999,999,999.999"

    @ 208,100 Say "Qtde Aferição" Size 55,10 Of oDlg1 Pixel color CLR_BLUE

    @ 208,140 Say oQtdAfe Var nQtdAfer Size 40,10 Of oDlg1 Pixel Picture "@E 999,999,999.999"

    @ 208,240 Say "Qtde Abastecida" Size 55,10 Of oDlg1 Pixel color CLR_BLUE

    @ 208,320 Say oQtdAbast Var nQtdAbast Size 40,10 Of oDlg1 Pixel Picture "@E 999,999,999.999"

    @ 208,360 Say "Qtde Total" Size 55,10 Of oDlg1 Pixel color CLR_BLUE

    @ 208,410 Say oQtdTotal Var nQtdTotal Size 40,10 Of oDlg1 Pixel Picture "@E 999,999,999.999"

Return { /* nQtdBom, */ nQtdAfer, nQtdAbast, nQtdTotal }

Static Function MNTA670TTA()
    Local cQuery, cAliasQry
    Local nTotalInfo := 0

    If NGCADICBASE("TTA_TOTCOM","A","TTA",.F.)

        cAliasQry := GetNextAlias()
        cQuery := "SELECT TTA.TTA_TOTCOM, TTA.TTA_FOLHA "
        cQuery += "FROM " + RetSQLName("TTA") + " TTA "
        cQuery += "WHERE TTA.TTA_POSTO = '" + MV_PAR03 + "' "
        cQuery += " AND TTA.TTA_LOJA = '" + MV_PAR04 + "' "
        cQuery += " AND TTA.TTA_DTABAS >= '" + DTOS(MV_PAR01) + "' "
        cQuery += " AND TTA.TTA_DTABAS <= '" + DTOS(MV_PAR02) + "' "
        cQuery += " AND TTA.D_E_L_E_T_ <> '*' "
        cQuery := ChangeQuery(cQuery)

        dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

        If (cAliasQry)->( !EoF() )
            While !Eof()
                nTotalInfo += (cAliasQry)->TTA_TOTCOM
                nTotalInfo -= MNT670CONC((cAliasQry)->TTA_FOLHA)

                dbSelectArea(cAliasQry)
                dbSkip()
            End

        EndIf

        

        (cAliasQry)->(dbCloseArea())

    EndIf


Return nTotalInfo

Static Function MNT670CONC(cNotaFis)

 

Local cQuery

Local cAliasQry2

Local nTotalConc := 0

cAliasQry2 := GetNextAlias()

 

cQuery := "SELECT TQN.TQN_QUANT "

cQuery += "FROM " + RetSQLName("TQN") + " TQN "

cQuery += "WHERE TQN.TQN_POSTO = '" + MV_PAR03 + "' "

cQuery += " AND TQN.TQN_LOJA = '" + MV_PAR04 + "' "

cQuery += " AND TQN.TQN_DTABAS >= '" + DTOS(MV_PAR01) + "' "

cQuery += " AND TQN.TQN_DTABAS <= '" + DTOS(MV_PAR02) + "' "

cQuery += " AND ((TQN.TQN_NOTFIS = '" + AllTrim(cNotaFis)+ "' AND TQN.TQN_DTCON <> ' ' "

cQuery += " AND TQN.TQN_CODCOM ='" + MV_PAR05 + "') "

cQuery += " OR ( TQN.TQN_NOTFIS = '" +AllTrim(cNotaFis)+ "' AND TQN.TQN_CODCOM <> '"+ MV_PAR05+"') )"

cQuery += " AND TQN.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry2, .F., .T.)

 

While (cAliasQry2)->( !Eof() )

nTotalConc += (cAliasQry2)->TQN_QUANT

(cAliasQry2)->( dbSkip() )

End

 

(cAliasQry2)->(dbCloseArea())


Return nTotalConc


