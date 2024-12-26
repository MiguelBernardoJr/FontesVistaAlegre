#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch"
#include "protheus.ch"
#include "TbiConn.ch"
/*---------------------------------------------------------------------------------,
 | Analista : Igor Gomes OLiveira                                                  |
 | Data		: 20.09.2022                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Grava nota dos operadores no trato                                   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/

User Function PerJob13() //U_PerJob13()
    Local aArea := FwGetArea()
    Local cPerg := "PerJob13"
    Local lRet  := .T. 
    Local cUpd  := ""
    Local dInicial, dFinal 
    Local cCrPaz
    Local cCrMot
    Local cCodCr


    If MsgYesNo("Esta Rotina refaz o processamento de todas notas calculadas e atribuidas de acordo com os parâmetros, onde é realizada a exclusão das notas geradas no dia, e recria as notas novamente, deseja Continuar??", "Reprocessamento")
        GeraX1(cPerg)

        if  Pergunte(cPerg, .T.)

            if Empty(mv_par03) .or. Empty(mv_par04)
                MsgStop("Informe as datas corretamente!")
                lRet := .F.
            endif

            if lRet .and. mv_par03 > mv_par04
                MsgStop("Data Inicial não pode ser maior que a data Final")
                lRet := .f.
            endif

            if lRet 
                if mv_par05 == 1 // VAJOB13
                    dInicial    := mv_par03
                    dFinal      := mv_par04
                    BeginTransaction()
                        cUpd := "Update "+RetSqlName("ZAV")+" SET D_E_L_E_T_ = '*' WHERE R_E_C_N_O_ IN ( " + CRLF
                        cUpd += "  SELECT ZAV.R_E_C_N_O_ " + CRLF
                        cUpd += "  FROM "+RetSqlName("ZAV")+" ZAV " + CRLF
                        cUpd += "  JOIN "+RetSqlName("ZCP")+" ZCP ON  " + CRLF
                        cUpd += "       ZAV_FILIAL = ZCP_FILIAL AND ZCP_CODIGO = ZAV_CCOD AND ZAV.D_E_L_E_T_ = ' '  " + CRLF
                        cUpd += "WHERE ZCP.D_E_L_E_T_ ='  ' AND ZCP_LANAUT = 'T' AND ZAV_DATA BETWEEN '"+dToS(dInicial)+"'AND'"+dToS(dFinal)+"' " + CRLF
                        cUpd += ") " + CRLF
                        
                        if (TCSqlExec(cUpd) < 0)
                            conout("TCSQLError() " + TCSQLError())
                        else
                            while dInicial <= dFinal
                                    Processa( { || U_JOB13VA(dInicial) }, 'JOB13: Gravando notas do dia '+dToC(dInicial)+'', 'Aguarde ...', .F. )
                                dInicial += 1
                            enddo
                        EndIf
                    endTransaction()
                endif

                if mv_par06 == 1 // VAJOB14

                    dInicial    := mv_par03
                    dFinal      := mv_par04

                    cCrPaz      := GetMV("VA_CRIPAZ",,"20") //Codigo de Critério para processamento - Carrgamento
                    cCrMot      := GetMV("VA_CRIMOT",,"09") //Codigo de Critério para processamento - Carrgamento

                    BeginTransaction()
                        cUpd := "Update "+RetSqlName("ZAV")+" SET D_E_L_E_T_ = '*' WHERE ZAV_DATA BETWEEN '"+dToS(dInicial)+"' AND '"+dToS(dFinal)+"' AND ZAV_CCOD IN ('"+cCrPaz+"','"+cCrMot+"')"
                        
                        if (TCSqlExec(cUpd) < 0)
                            conout("TCSQLError() " + TCSQLError())
                        else
                            while dInicial <= dFinal
                                    Processa( { || U_JOB14VA(dInicial) }, 'JOB14: Gravando notas do dia '+dToC(dInicial)+'', 'Aguarde ...', .F. )
                                dInicial += 1
                            enddo
                        EndIf
                    endTransaction()
                endif
                
                if mv_par07 == 1 // VAJOB15
                    dInicial    := mv_par03
                    dFinal      := mv_par04

                    cCodCr        := GetMV("VA_CRIFP",,"16") //Codigo de Critério para processamento - Fornecimento Parcial

                    BeginTransaction()
                        cUpd := "Update "+RetSqlName("ZAV")+" SET D_E_L_E_T_ = '*' WHERE ZAV_DATA BETWEEN '"+dToS(dInicial)+"' AND '"+dToS(dFinal)+"' AND ZAV_CCOD = '"+cCodCr+"'"
                        if (TCSqlExec(cUpd) < 0)
                            conout("TCSQLError() " + TCSQLError())
                        else
                            while dInicial <= dFinal
                                    Processa( { || U_JOB15VA(dInicial) }, 'JOB15: Gravando notas do dia '+dToC(dInicial)+'', 'Aguarde ...', .F. )
                                dInicial += 1
                            enddo
                        EndIf
                    endTransaction()
                endif 
                
                if mv_par08 == 1 // VAJOB16
                    dInicial    := mv_par03
                    dFinal      := mv_par04

                    cCodCr      := GetMV("VA_CRIFP",,"17") //Codigo de Critério para processamento - Fornecimento TOtal

                    BeginTransaction()
                        cUpd := "Update "+RetSqlName("ZAV")+" SET D_E_L_E_T_ = '*' WHERE ZAV_DATA BETWEEN '"+dToS(dInicial)+"' AND '"+dToS(dFinal)+"' AND ZAV_CCOD = '"+cCodCr+"'"
                        
                        if (TCSqlExec(cUpd) < 0)
                            conout("TCSQLError() " + TCSQLError())
                        else
                            while dInicial <= dFinal
                                    Processa( { || U_JOB16VA(dInicial) }, 'JOB16: Gravando notas do dia '+dToC(dInicial)+'', 'Aguarde ...', .F. )
                                dInicial += 1
                            enddo
                        EndIf
                    endTransaction()
                endif 
            endif 
        End
    EndIf
    FwRestArea(aArea)
Return 
Static Function GeraX1(cPerg)
Local _aArea	:= GetArea()
Local nX		:= 0
Local nPergs	:= 0
Local aRegs		:= {}
Local i         := 0
Local j         := 0
//Conta quantas perguntas existem ualmente.
DbSelectArea('SX1')
DbSetOrder(1)
SX1->(DbGoTop())
If SX1->(DbSeek(cPerg))
	While !SX1->(Eof()) .And. X1_GRUPO = cPerg
		nPergs++
		SX1->(DbSkip())
	EndDo
EndIf

AADD( aRegs, { cPerg, "01", "Filial de:                    ", "", "", "mv_ch1", TamSX3("Z0Y_FILIAL")[3], TamSX3("Z0Y_FILIAL")[1], TamSX3("Z0Y_FILIAL")[2], 0, "G", "", "mv_par01", ""   , "", "", "", "", ""   , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0", "S", "" ,"" ,"", "", {"Informe o código da filial desejada ou deixe em branco."  , "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "02", "Filial Ate:                   ", "", "", "mv_ch2", TamSX3("Z0Y_FILIAL")[3], TamSX3("Z0Y_FILIAL")[1], TamSX3("Z0Y_FILIAL")[2], 0, "G", "", "mv_par02", ""   , "", "", "", "", ""   , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0", "S", "" ,"" ,"", "", {"Informe o código da filial desejada ou deixe em branco."  , "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "03", "Dt. Inicial:                  ", "", "", "mv_ch3", TamSX3("Z0Y_DATA")[3]  , TamSX3("Z0Y_DATA")[1]  , TamSX3("Z0Y_DATA")[2]  , 0, "G", "", "mv_par03", ""   , "", "", "", "", ""   , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", "S", "" ,"" ,"", "", {"Informe a Dt. de Emissao Inicial                       "  , "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "04", "Dt. Final:                    ", "", "", "mv_ch4", TamSX3("Z0Y_DATA")[3]  , TamSX3("Z0Y_DATA")[1]  , TamSX3("Z0Y_DATA")[2]  , 0, "G", "", "mv_par04", ""   , "", "", "", "", ""   , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", "S", "" ,"" ,"", "", {"Informe a Dt. de Emissao Final                         "  , "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "05", "Proc. Notas Automaticas?      ", "", "", "mv_ch5", 1                      , 0                      , 0                      , 0, "C", "", "mv_par05", "Sim", "", "", "", "", "Não", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "S", "" ,"" ,"", "", {"Informe se irá processar essa rotina ou não."             , ""               }, {""}, {""} } )
AADD( aRegs, { cPerg, "06", "Proc. Assert. Carreg?         ", "", "", "mv_ch6", 1                      , 0                      , 0                      , 0, "C", "", "mv_par06", "Sim", "", "", "", "", "Não", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "S", "" ,"" ,"", "", {"Informe se irá processar essa rotina ou não."             , ""               }, {""}, {""} } )
AADD( aRegs, { cPerg, "07", "Proc. Forn. Parcial?          ", "", "", "mv_ch7", 1                      , 0                      , 0                      , 0, "C", "", "mv_par07", "Sim", "", "", "", "", "Não", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "S", "" ,"" ,"", "", {"Informe se irá processar essa rotina ou não."             , ""               }, {""}, {""} } )
AADD( aRegs, { cPerg, "08", "Proc. Forn. Total ?           ", "", "", "mv_ch8", 1                      , 0                      , 0                      , 0, "C", "", "mv_par08", "Sim", "", "", "", "", "Não", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "S", "" ,"" ,"", "", {"Informe se irá processar essa rotina ou não."             , ""               }, {""}, {""} } )

//Se quantidade de perguntas for diferente, apago todas
SX1->(DbGoTop())  
If nPergs <> Len(aRegs)
	For nX:=1 To nPergs
		If SX1->(DbSeek(cPerg))		
			If RecLock('SX1',.F.)
				SX1->(DbDelete())
				SX1->(MsUnlock())
			EndIf
		EndIf
	Next nX
EndIf

// gravação das perguntas na tabela SX1
If nPergs <> Len(aRegs)
	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
				For j := 1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next j
			SX1->(MsUnlock())
		EndIf
	Next i
EndIf

RestArea(_aArea)

Return nil
User Function VAJOB13()

	ConOut('VAJOB13(): ' + Time())
	
	If Type("oMainWnd") == "U"
		ConOut('oMainWnd: ' + Time())
		U_RunFunc("U_JOB13VA()",'01','01',3) 
	Else
		ConOut('Else oMainWnd: ' + Time())
		U_JOB13VA()
	EndIf
	
return nil

User Function JOB13VA(dDate) //U_JOB13VA()
    Local aArea         := GetArea()
    Local cAliasZ0X     := GetNextAlias()
    Local cAliasZCP     := GetNextAlias()
    Local cAliasTemNF   := GetNextAlias()
    Local cCod  
    Local _cQry            
    Local nItem         := 0
//    Local dDt

    Default dDate := dDataBase

/*
    13/10/2022
    Arthur Toshio
    Selectionar apenas Operadores que trabalharam no dia para cirar o registro na ZAV
*/
    _cQry := " WITH TRATO AS (" +CRLF 
    _cQry += " 		SELECT DISTINCT Z0W_OPERAD, Z0U_NOME, 'T' TIPO	" +CRLF 
    _cQry += " 		  FROM "+RetSqlName("Z0W")+" Z0W" +CRLF 
    _cQry += " 		  JOIN "+RetSqlName("Z0U")+" Z0U ON" +CRLF 
    _cQry += " 		       Z0U_FILIAL = Z0W_FILIAL " +CRLF 
    _cQry += " 		   AND Z0U_CODIGO = Z0W_OPERAD" +CRLF 
    _cQry += " 		   AND Z0U_LANAUT = 'T'" +CRLF 
    _cQry += " 		   AND Z0U.D_E_L_E_T_ = ' ' " +CRLF 
    _cQry += " 		 WHERE Z0W_FILIAL = '"+FWxFilial("Z0W")+"'  " +CRLF 
    _cQry += " 		   AND Z0W_OPERAD <> ' ' " +CRLF 
    _cQry += " 		   AND Z0W_DATA = '"+dToS(dDate)+"' " + CRLF
    _cQry += " 		   AND Z0W.D_E_L_E_T_ = ' '" +CRLF 
    _cQry += " )" +CRLF 
    _cQry += " , PAZEIRO AS (" +CRLF 
    _cQry += " 	SELECT DISTINCT Z0Y_OPER1, Z0U_NOME, 'P' TIPO	" +CRLF 
    _cQry += " 	  FROM "+RetSqlName("Z0Y")+" Z0Y  " +CRLF 
    _cQry += " 	  JOIN "+RetSqlName("Z0U")+" Z0U ON" +CRLF 
    _cQry += " 		       Z0U_FILIAL = Z0Y_FILIAL " +CRLF 
    _cQry += " 		   AND Z0U_CODIGO = Z0Y_OPER1" +CRLF 
    _cQry += " 		   AND Z0U_LANAUT = 'T'" +CRLF 
    _cQry += " 		   AND Z0U.D_E_L_E_T_ = ' ' " +CRLF 
    _cQry += " 	 WHERE Z0Y_FILIAL = '"+FWxFilial("Z0Y")+"'  " +CRLF 
    _cQry += " 	   AND Z0Y_OPER1 NOT IN (SELECT Z0W_OPERAD FROM TRATO WHERE TIPO = 'T' )" +CRLF 
    _cQry += " 	   AND Z0Y_DATA = '"+dToS(dDate)+"' " + CRLF
    _cQry += " 	   AND Z0Y_ORIGEM = 'B' " +CRLF 
    _cQry += " 	   AND Z0Y.D_E_L_E_T_ = ' ' " +CRLF 
    _cQry += " 	UNION " +CRLF 
    _cQry += " 	SELECT DISTINCT Z0Y_OPER2, Z0U_NOME, 'P' TIPO	" +CRLF 
    _cQry += " 	  FROM "+RetSqlName("Z0Y")+" Z0Y  " +CRLF 
    _cQry += " 	  JOIN "+RetSqlName("Z0U")+" Z0U ON" +CRLF 
    _cQry += " 		       Z0U_FILIAL = Z0Y_FILIAL " +CRLF 
    _cQry += " 		   AND Z0U_CODIGO = Z0Y_OPER2" +CRLF 
    _cQry += " 		   AND Z0U_LANAUT = 'T'" +CRLF 
    _cQry += " 		   AND Z0U.D_E_L_E_T_ = ' ' " +CRLF 
    _cQry += " 	 WHERE Z0Y_FILIAL = '"+FWxFilial("Z0Y")+"' " +CRLF 
    _cQry += " 	   AND Z0Y_OPER2 NOT IN (SELECT Z0W_OPERAD FROM TRATO WHERE TIPO = 'T' )" +CRLF 
    _cQry += " 	   AND Z0Y_DATA = '"+dToS(dDate)+"' " + CRLF
    _cQry += " 	   AND Z0Y_ORIGEM = 'B' " +CRLF 
    _cQry += " 	   AND Z0Y.D_E_L_E_T_ = ' ' " +CRLF 
    _cQry += " 	 )" +CRLF 
    _cQry += " 	 SELECT * FROM TRATO " +CRLF 
    _cQry += " 	 UNION " +CRLF
    _cQry += " 	 SELECT * FROM PAZEIRO " 

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliasZ0X),.F.,.F.)
    
    MemoWrite("C:\totvs_relatorios\SQL_VAJOB13.sql" , _cQry)

    _cQry := "SELECT * FROM "+RetSqlName("ZCP")+" ZCP WHERE D_E_L_E_T_ = '' "

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliasZCP),.F.,.F.)

    DbSelectArea("ZAV")
    ZAV->(DbSetOrder(3))

        While !(cAliasZ0X)->(Eof())
    //dDt := (cAliasZ0X)->Z0X_DATA
        nItem := 0
        //if ZAV->(!DbSeek(FWxFilial("ZAV") + (cAliasZ0X)->Z0W_OPERAD + dToS(dDate)))
        cQryNota := " SELECT * FROM "+RetSqlName("ZAV")+" ZAV " + CRLF 
        cQryNota += "   JOIN "+RetSqlName("ZCP")+" ZCP  ON ZCP_FILIAL = '"+FWxFilial("ZCP")+"' " + CRLF
        cQryNota += "   AND ZCP_CODIGO = ZAV_CCOD AND ZCP_LANAUT = 'T' AND ZCP.D_E_L_E_T_ = ' ' AND ZCP_CODIGO = '"+(cAliasZCP)->ZCP_CODIGO+"' " +CRLF 
        cQryNota += " WHERE ZAV_FILIAL = '"+FWxFilial("ZAV")+"' "  + CRLF 
        cQryNota += "   AND ZAV_DATA = '"+DTOS( dDate )+"' " + CRLF 
        cQryNota += "   AND ZAV_MAT = '"+(cAliasZ0X)->Z0W_OPERAD+"' " + CRLF 
        cQryNota += "   AND ZAV.D_E_L_E_T_ = ''  " 

        dbUseArea(.T.,'TOPCONN',TCGENQRY(,, cQryNota ),(cAliasTemNF),.F.,.F.)
        If (cAliasTemNF)->(EoF())
            cCod := GetSx8Num("ZAV","ZAV_COD",,1)

            While !(cAliasZCP)->(Eof())     
                iF (cAliasZCP)->ZCP_LANAUT == "T" .AND. (((cAliasZ0X)->TIPO =='P' .AND. (cAliasZCP)->ZCP_TIPOCR $  "A,C") .OR. ((cAliasZ0X)->TIPO =='T' .AND. (cAliasZCP)->ZCP_TIPOCR $  "A,T") )
                    RecLock("ZAV", .T.)
                        ZAV->ZAV_FILIAL := FWxFilial("ZAV")
                        ZAV->ZAV_COD    := cCod
                        ZAV->ZAV_MAT    := (cAliasZ0X)->Z0W_OPERAD              
                        ZAV->ZAV_DATA   := dDate //ZAV->ZAV_DATA   := sToD(dDt)
                        ZAV->ZAV_ITEM   := StrZero(++nItem,2)
                        ZAV->ZAV_CCOD   := (cAliasZCP)->ZCP_CODIGO
                        ZAV->ZAV_NOTA   := (cAliasZCP)->ZCP_NOTMAX
                        ZAV->ZAV_ORIGEM := "A"
                    ZAV->(MsUnlock())
                    
                    (cAliasZCP)->(dbSkip())
                Else 
                    (cAliasZCP)->(dbSkip())
                EndIf
            EndDo
            (cAliasZCP)->(DbGoTop())
        endif
        (cAliasZ0X)->(dbSkip())
        (cAliasTemNF)->(DBCloseArea())
        //(cAliasTemNF)->(dbSkip())
    EndDo
    //(cAliasTemNF)->(DBCloseArea())
    (cAliasZCP)->(DBCloseArea())
    (cAliasZ0X)->(DBCloseArea())

    RestArea(aArea)

return nil



/*/{Protheus.doc} VAJOB14
Rotina que Analisa registros da Z0Y e faz processamento com a ZCP para atribuir nota aos critérios
@type  function
@version  1
@author Arthur Toshio
@since 17/10/2022
@return variant, return_description
/*/
User Function VAJOB14() 
    ConOut('VAJOB14(): ' + Time())
        
        If Type("oMainWnd") == "U"
            ConOut('oMainWnd: ' + Time())
            U_RunFunc("U_JOB14VA()",'01','01',3) // Gravar pedido de venda customizado.
        Else
            ConOut('Else oMainWnd: ' + Time())
            U_JOB14VA()
        EndIf        
return nil

User Function JOB14VA(dDate) // U_JOB14VA()
    Local aArea         := GetArea()
    Local cAliasX       := GetNextAlias()
    Local cAliasC       := GetNextAlias()
    Local cCrPaz        := GetMV("VA_CRIPAZ",,"20") //Codigo de Critério para processamento - Carrgamento
    Local cCrMot        := GetMV("VA_CRIMOT",,"09") //Codigo de Critério para processamento - Carrgamento
    Local _cQry         := ""
    Local cCod          := 0
    Local nItem         := 0
    Local nNota1        := 0
    Local nNota2        := 0

    Default dDate := dDataBase

    _cQry += "WITH DADOS AS ( " +CRLF
    _cQry += "     SELECT Z0Y_FILIAL FILIAL " +CRLF
    _cQry += "	      , Z0Y_DATA " +CRLF
    _cQry += "		  --, CONVERT(DATE,Z0Y_DATA,103) DATA " +CRLF
    _cQry += "		  , Z0Y_ORDEM ORDEM , Z0Y_TRATO TRATO " +CRLF
    _cQry += "		  , Z0Y_RECEIT RECEITA , Z0Y_COMP COMPONENTE, B1_DESC DESCRICAO  " +CRLF
    _cQry += "		  , CASE WHEN Z0Y_ORIGEM = 'B' THEN 'BALANÇA' WHEN Z0Y_ORIGEM = 'V' THEN 'MOTORISTA' END ORIGEMPESO " +CRLF
    _cQry += "		  , Z0Y_QTDPRE PREVISTO, Z0Y_KGRECA [P. RECALCULADO], Z0Y_QTDREA REAL, Z0Y_PESDIG PESODIGITADO " +CRLF
    _cQry += "		  , Z0Y_DOPER1 [% DIFERENCA1] " +CRLF
    _cQry += "		  , Z0Y_DOPER2 [% DIFERENCA2] " +CRLF
    _cQry += "		  , ZRF_TOLPER [% TOLERANCIA] " +CRLF
    _cQry += "		  , CASE WHEN ABS(Z0Y_DOPER1) > ZRF_TOLPER THEN ABS(Z0Y_DOPER1) - ZRF_TOLPER   ELSE 0 END [% EXCEDENTE A TOLER.] " +CRLF
    _cQry += "		  , CASE WHEN ABS(Z0Y_DOPER1) > ZRF_TOLPER THEN 'FORA' ELSE 'OK' END SITUACAO " +CRLF
    _cQry += "		  --, CASE WHEN ABS(Z0Y_DOPER1) > ZRF_TOLPER THEN /*ISNULL((1-(ZDP_PERDES/100)/1), 1)*/(ZDP_PERDES/100) ELSE 1 END PONTO " +CRLF
    _cQry += "		  --, CASE WHEN ABS(Z0Y_DOPER1) > ZRF_TOLPER THEN ISNULL((1-(ZDP_PERDES/100)/1), 1) ELSE 1 END PONTO " +CRLF
    _cQry += "		  , Z0Y_OPER1 " +CRLF
    _cQry += "		  , CASE WHEN Z0Y_DOPER1 <> 0 THEN ISNULL((1-(ZDP_PERDES/100)/1), 1) ELSE 1 END PONTOOP1 " +CRLF
    _cQry += "		  , Z0Y_OPER2 " +CRLF
    _cQry += "		  , CASE WHEN Z0Y_DOPER2 <> 0 THEN ISNULL((1-(ZDP_PERDES/100)/1), 1) ELSE 1 END PONTOOP2 " +CRLF
    _cQry += "                  , 1 AS [PTOPOSIVEL] " +CRLF
    _cQry += "		  , Z0Y_FILIAL + Z0Y_ORDEM + Z0Y_ORIGEM [FILIALORDEMORIGEM] " +CRLF
    _cQry += "	   FROM "+RetSqlName("Z0Y")+" Z0Y  " +CRLF
    _cQry += "	   JOIN "+RetSqlName("SB1")+" SB1 " +CRLF
    _cQry += "	     ON SB1.B1_COD = Z0Y.Z0Y_COMP " +CRLF
    _cQry += "		AND SB1.D_E_L_E_T_ = ' '  " +CRLF
    _cQry += "	   JOIN "+RetSqlName("ZRF")+" ZRF " +CRLF
    _cQry += "	     ON ZRF_FILIAL = Z0Y_FILIAL " +CRLF
    _cQry += "		AND ZRF_PRODUT = Z0Y_COMP  " +CRLF
    _cQry += "		AND Z0Y_DATA BETWEEN ZRF_DTINI AND ZRF_DTFIM " +CRLF
    _cQry += "  LEFT JOIN "+RetSqlName("ZDP")+" ZDP ON  " +CRLF
    _cQry += "            ZDP_FILIAL = Z0Y_FILIAL " +CRLF
    _cQry += "		AND Z0Y_DATA >= ZDP_DATA --- REVER " +CRLF
    _cQry += "		AND ZDP_OPERAC = 'P' " +CRLF
    _cQry += "		AND ABS(Z0Y_DOPER1)-ZRF_TOLPER BETWEEN ZDP_PERDE AND ZDP_PERATE " +CRLF
    _cQry += "		AND ZDP.D_E_L_E_T_ = ' ' " +CRLF
    _cQry += "	  WHERE Z0Y_FILIAL = '"+FWxFilial("Z0Y")+"' " +CRLF 
    _cQry += "	    AND Z0Y_ORIGEM in ('B','V') " +CRLF
    _cQry += "	    AND Z0Y_DATA = '"+dToS(dDate)+"' " + CRLF
    _cQry += "		AND Z0Y.D_E_L_E_T_ = ' '  " +CRLF
    _cQry += "		) " +CRLF
    _cQry += "		SELECT Z0Y_DATA, ORIGEMPESO, SUM(PTOPOSIVEL) PONTOPOS " +CRLF
    _cQry += "		     , Z0Y_OPER1 , SUM(PONTOOP1) PONTOOP1 " +CRLF
    _cQry += "			 , Z0Y_OPER2 , SUM(PONTOOP2) PONTOOP2 " +CRLF
    _cQry += "		  FROM DADOS " +CRLF
    _cQry += "		  group by Z0Y_DATA, ORIGEMPESO, Z0Y_OPER1, Z0Y_OPER2 " +CRLF

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliasX),.F.,.F.)

    MemoWrite("C:\totvs_relatorios\SQL_VAJOB14.sql" , _cQry)


    While !(cAliasX)->(Eof())
        //If !(cAliasC)->(Eof())
            // De acordo com a origem seleciona o código do critério correto.
            If (cAliasX)->ORIGEMPESO == "MOTORISTA"
                cCodCr := cCrMot
                _cQry1 := "SELECT * FROM "+RetSqlName("ZCP")+" ZCP WHERE ZCP_FILIAL = '"+FWxFilial("ZCP")+"' AND ZCP_TIPOCR = 'T' AND ZCP_LANAUT = 'F' AND ZCP_CODIGO = '"+cCodCr+"'AND D_E_L_E_T_ = '' "
                dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry1 ),(cAliasC),.F.,.F.)
            Else 
                cCodCr := cCrPaz
                _cQry1 := "SELECT * FROM "+RetSqlName("ZCP")+" ZCP WHERE ZCP_FILIAL = '"+FWxFilial("ZCP")+"' AND ZCP_TIPOCR = 'C' AND ZCP_LANAUT = 'F' AND ZCP_CODIGO = '"+cCodCr+"'AND D_E_L_E_T_ = '' "
                dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry1 ),(cAliasC),.F.,.F.)
            EndIf 
            If !(cAliasC)->(Eof())
                nNota1 := Round(( (cAliasC)->ZCP_NOTMAX / (cAliasX)->PONTOPOS ) * (cAliasX)->PONTOOP1,2)
                cCod := GetSx8Num("ZAV","ZAV_COD",,1) 
                If nNota1 > 0 
                    RecLock("ZAV", .T.)
                        ZAV->ZAV_FILIAL := FWxFilial("ZAV")
                        ZAV->ZAV_COD    := cCod
                        ZAV->ZAV_MAT    := (cAliasX)->Z0Y_OPER1                        
                        ZAV->ZAV_DATA   := dDate //ZAV->ZAV_DATA   := sToD(dDt)
                        ZAV->ZAV_ITEM   := StrZero(++nItem,2)
                        ZAV->ZAV_CCOD   := cCodCr
                        ZAV->ZAV_NOTA   := nNota1
                        ZAV->ZAV_ORIGEM := "A"
                    ZAV->(MsUnlock())
                EndIf
                If !(cAliasX)->ORIGEMPESO == "MOTORISTA"
                    
                    nNota2 := Round( ( (cAliasC)->ZCP_NOTMAX / (cAliasX)->PONTOPOS ) * (cAliasX)->PONTOOP2 ,2)
                    cCod := GetSx8Num("ZAV","ZAV_COD",,1) 
                    If nNota2 > 0 
                        RecLock("ZAV", .T.)
                            ZAV->ZAV_FILIAL := FWxFilial("ZAV")
                            ZAV->ZAV_COD    := cCod
                            ZAV->ZAV_MAT    := (cAliasX)->Z0Y_OPER2
                            ZAV->ZAV_DATA   := dDate //ZAV->ZAV_DATA   := sToD(dDt)
                            ZAV->ZAV_ITEM   := StrZero(++nItem,2)
                            ZAV->ZAV_CCOD   := cCodCr
                            ZAV->ZAV_NOTA   := nNota2
                            ZAV->ZAV_ORIGEM := "A"
                        ZAV->(MsUnlock())
                    EndIf
                EndIf
            
            (cAliasX)->(dbSkip())
            
            EndIf
            (cAliasC)->(DBCloseArea())

    EndDo
    (cAliasX)->(DBCloseArea())
    

RestArea(aArea)

Return Nil 

/*/{Protheus.doc} VAJOB15
Rotina que faz o processamento da Tabela Z0W e faz o cadastro da ZAV levando em conta a ZCP
@type function
@version  1
@author Arthur Toshio
@since 17/10/2022
@return nil, return_description
/*/
User Function VAJOB15() 
    ConOut('VAJOB15(): ' + Time())
        
        If Type("oMainWnd") == "U"
            ConOut('oMainWnd: ' + Time())
            U_RunFunc("U_JOB15VA()",'01','01',3) // Gravar pedido de venda customizado.
        Else
            ConOut('Else oMainWnd: ' + Time())
            U_JOB15VA()
        EndIf        
return nil


User Function JOB15VA(dDate)  // U_JOB15VA()
    Local aArea         := GetArea()
    Local cAliasX       := GetNextAlias()
    Local cAliasC       := GetNextAlias()
    Local cCodCr        := GetMV("VA_CRIFP",,"16") //Codigo de Critério para processamento - Fornecimento Parcial
    Local _cQry         := ""
    Local cCod          := 0
    Local nItem         := 0

    Default dDate := dDataBase

    _cQry += " WITH DADOS AS ( " +CRLF
    _cQry += " 	 SELECT Z0W_FILIAL FILIAL " +CRLF
    _cQry += " 	      , Z0W_DATA " +CRLF
    _cQry += " 		  --, CONVERT(DATE,Z0W_DATA,103) DATA " +CRLF
    _cQry += " 		  , Z0W_CURRAL, Z0W_LOTE " +CRLF
    _cQry += " 		  , Z0W_ORDEM ORDEM , Z0W_TRATO TRATO " +CRLF
    _cQry += " 		  , Z0W_RECEIT RECEITA, B1_DESC DESCRICAO  " +CRLF
    _cQry += " 		  , Z0W_QTDPRE PREVISTO, Z0W_KGRECA [P. RECALCULADO], Z0W_QTDREA REAL, Z0W_PESDIG PESODIGITADO " +CRLF
    _cQry += " 		  , Z0W_DIFOPE [% DIFERENCA1] " +CRLF
    _cQry += " 		  , ZRF_TOLPER [% TOLERANCIA] " +CRLF
    _cQry += " 		  , CASE WHEN ABS(Z0W_DIFOPE) > ZRF_TOLPER THEN ABS(Z0W_DIFOPE) - ZRF_TOLPER   ELSE 0 END [% EXCEDENTE A TOLER.] " +CRLF
    _cQry += " 		  , CASE WHEN ABS(Z0W_DIFOPE) > ZRF_TOLPER THEN 'FORA' ELSE 'OK' END SITUACAO " +CRLF
    _cQry += " 		  --, CASE WHEN ABS(Z0W_DOPER1) > ZRF_TOLPER THEN /*ISNULL((1-(ZDP_PERDES/100)/1), 1)*/(ZDP_PERDES/100) ELSE 1 END PONTO " +CRLF
    _cQry += " 		  --, CASE WHEN ABS(Z0W_DOPER1) > ZRF_TOLPER THEN ISNULL((1-(ZDP_PERDES/100)/1), 1) ELSE 1 END PONTO " +CRLF
    _cQry += " 		  , ISNULL((1-(ZDP_PERDES/100)/1), 1) PONTO " +CRLF
    _cQry += "                   , 1 AS [PTOPOSIVEL] " +CRLF
    _cQry += " 		  , Z0W_FILIAL + Z0W_ORDEM[FILIALORDEM] " +CRLF
    _cQry += " 		  , Z0W_FILIAL + Z0W_ORDEM+Z0U_TIPO[FILIALORDEMTIPO] " +CRLF
    _cQry += " 		  , Z0X_OPERAD " +CRLF
    _cQry += " 		  , Z0U_NOME " +CRLF
    _cQry += " 	   FROM Z0W010 Z0W  " +CRLF
    _cQry += " 	   JOIN SB1010 SB1 " +CRLF
    _cQry += " 	     ON SB1.B1_COD = Z0W.Z0W_RECEIT " +CRLF
    _cQry += " 		AND SB1.D_E_L_E_T_ = ' '  " +CRLF
    _cQry += " 	   JOIN ZRF010 ZRF " +CRLF
    _cQry += " 	     ON ZRF_FILIAL = Z0W_FILIAL " +CRLF
    _cQry += " 		AND ZRF_OPERAC = '3' " +CRLF
    _cQry += " 		AND Z0W_DATA BETWEEN ZRF_DTINI AND ZRF_DTFIM " +CRLF
    _cQry += " 		AND ZRF.D_E_L_E_T_ = ' ' " +CRLF
    _cQry += " 	   JOIN Z0X010 Z0X ON  " +CRLF
    _cQry += " 	        Z0X_FILIAL = Z0W_FILIAL " +CRLF
    _cQry += " 		AND Z0X_CODIGO = Z0W_CODEI " +CRLF
    _cQry += " 		AND Z0X_DATA = Z0W_DATA " +CRLF
    _cQry += " 		AND Z0X.D_E_L_E_T_ = ' ' " +CRLF
    _cQry += " 	   JOIN Z0U010 Z0U ON " +CRLF
    _cQry += " 	        Z0U_FILIAL = Z0X_FILIAL " +CRLF
    _cQry += " 		AND Z0U_CODIGO = Z0X_OPERAD " +CRLF
    _cQry += " 		AND Z0U.D_E_L_E_T_ = ' '  " +CRLF
    _cQry += "   LEFT JOIN ZDP010 ZDP ON  " +CRLF
    _cQry += "             ZDP_FILIAL = Z0W_FILIAL " +CRLF
    _cQry += " 		AND Z0W_DATA >= ZDP_DATA --- REVER " +CRLF
    _cQry += " 		AND ZDP_OPERAC = 'P' " +CRLF
    _cQry += " 		AND ABS(Z0W_DIFOPE)-ZRF_TOLPER BETWEEN ZDP_PERDE AND ZDP_PERATE " +CRLF
    _cQry += " 		AND ZDP.D_E_L_E_T_ = ' ' " +CRLF
    _cQry += " 	  WHERE Z0W_FILIAL = '"+FWxFilial("Z0W")+"' " +CRLF 
    _cQry += " 	    AND Z0W_DATA = '"+dToS(dDate)+"' " + CRLF
    _cQry += " 		AND Z0W_QTDPRE > 0 " +CRLF
    _cQry += " 		AND Z0W.D_E_L_E_T_ = ' ' " +CRLF
    _cQry += " ) " +CRLF
    _cQry += "    SELECT Z0X_OPERAD, Z0W_DATA, SUM(PTOPOSIVEL) PTOPOS, SUM(PONTO) PONTOS " +CRLF
    _cQry += "      FROM DADOS " +CRLF
    _cQry += " 	 GROUP BY Z0X_OPERAD, Z0W_DATA " +CRLF

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliasX),.F.,.F.)

    MemoWrite("C:\totvs_relatorios\SQL_VAJOB15.sql" , _cQry)

    _cQry1 := "SELECT * FROM "+RetSqlName("ZCP")+" ZCP WHERE ZCP_FILIAL = '"+FWxFilial("ZCP")+"' AND ZCP_TIPOCR = 'T' AND ZCP_LANAUT = 'F' AND ZCP_CODIGO = '"+cCodCr+"'AND D_E_L_E_T_ = '' "
    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry1 ),(cAliasC),.F.,.F.)

    While !(cAliasX)->(Eof())
        If !(cAliasC)->(Eof())
            
            nNota := Round( ( (cAliasC)->ZCP_NOTMAX / (cAliasX)->PTOPOS ) * (cAliasX)->PONTOS,2)
            cCod := GetSx8Num("ZAV","ZAV_COD",,1) 
        If nNota > 0
                RecLock("ZAV", .T.)
                    ZAV->ZAV_FILIAL := FWxFilial("ZAV")
                    ZAV->ZAV_COD    := cCod
                    ZAV->ZAV_MAT    := (cAliasX)->Z0X_OPERAD                        
                    ZAV->ZAV_DATA   := dDate //ZAV->ZAV_DATA   := sToD(dDt)
                    ZAV->ZAV_ITEM   := StrZero(++nItem,2)
                    ZAV->ZAV_CCOD   := cCodCr
                    ZAV->ZAV_NOTA   := nNota
                    ZAV->ZAV_ORIGEM := "A"
                ZAV->(MsUnlock())
            EndIf
        (cAliasX)->(dbSkip())
        EndIf
    EndDo
    (cAliasX)->(DBCloseArea())
    (cAliasC)->(DBCloseArea())

RestArea(aArea)

Return Nil


User Function VAJOB16() // U_VAJOB16()
    ConOut('VAJOB16(): ' + Time())
        
        If Type("oMainWnd") == "U"
            ConOut('oMainWnd: ' + Time())
            U_RunFunc("U_JOB16VA()",'01','01',3) // Gravar pedido de venda customizado.
        Else
            ConOut('Else oMainWnd: ' + Time())
            U_JOB16VA()
        EndIf        
return nil


User Function JOB16VA(dDate)
    Local aArea         := GetArea()
    Local cAliasX       := GetNextAlias()
    Local cAliasC       := GetNextAlias()
    Local cCodCr        := GetMV("VA_CRIFP",,"17") //Codigo de Critério para processamento - Fornecimento TOtal
    Local _cQry         := ""
    Local cCod          := 0
    Local nItem         := 0

    Default dDate := dDataBase

    _cQry += " WITH BASE AS ( " +CRLF
    _cQry += " 	 SELECT Z0W_FILIAL, Z0W_DATA, Z0W_CURRAL, Z0W_LOTE, Z0W_RECEIT, B1_DESC, ZRF_TOLPER  " +CRLF
    _cQry += " 		  , SUM(Z0W_QTDPRE) PREV, SUM(CASE WHEN Z0W_PESDIG > 0 THEN Z0W_PESDIG ELSE Z0W_QTDREA END ) QTDREAL " +CRLF
    _cQry += " 		  , ((SUM(CASE WHEN Z0W_PESDIG > 0 THEN Z0W_PESDIG ELSE Z0W_QTDREA END ) / SUM(Z0W_QTDPRE)-1)*100) DIFE		   " +CRLF
    _cQry += "           , 1 AS [PTOPOSIVEL] " +CRLF
    _cQry += " 		  , Z0X_OPERAD, Z0U_NOME " +CRLF
    _cQry += " 	   FROM Z0W010 Z0W  " +CRLF
    _cQry += " 	   JOIN SB1010 SB1 " +CRLF
    _cQry += " 	     ON SB1.B1_COD = Z0W.Z0W_RECEIT " +CRLF
    _cQry += " 		AND SB1.D_E_L_E_T_ = ' '  " +CRLF
    _cQry += " 	   JOIN ZRF010 ZRF " +CRLF
    _cQry += " 	     ON ZRF_FILIAL = Z0W_FILIAL " +CRLF
    _cQry += " 		AND ZRF_OPERAC = '2' " +CRLF
    _cQry += " 		AND Z0W_DATA BETWEEN ZRF_DTINI AND ZRF_DTFIM " +CRLF
    _cQry += " 		AND ZRF.D_E_L_E_T_ = ' ' " +CRLF
    _cQry += " 	   JOIN Z0X010 Z0X ON  " +CRLF
    _cQry += " 	        Z0X_FILIAL = Z0W_FILIAL " +CRLF
    _cQry += " 		AND Z0X_CODIGO = Z0W_CODEI " +CRLF
    _cQry += " 		AND Z0X_DATA = Z0W_DATA " +CRLF
    _cQry += " 		AND Z0X.D_E_L_E_T_ = ' ' " +CRLF
    _cQry += " 	   JOIN Z0U010 Z0U ON " +CRLF
    _cQry += " 	        Z0U_FILIAL = Z0X_FILIAL " +CRLF
    _cQry += " 		AND Z0U_CODIGO = Z0X_OPERAD " +CRLF
    _cQry += " 		AND Z0U.D_E_L_E_T_ = ' '  " +CRLF
    _cQry += " 	  WHERE Z0W_FILIAL = '"+FWxFilial("Z0W")+"' " +CRLF 
    _cQry += " 	    AND Z0W_DATA = '"+dToS(dDate)+"' " + CRLF
    _cQry += " 		AND Z0W.Z0W_QTDPRE > 0 " +CRLF
    _cQry += " 		AND Z0W.D_E_L_E_T_ = ' ' " +CRLF
    _cQry += "    GROUP BY Z0W_FILIAL, Z0W_DATA, Z0W_CURRAL, Z0W_LOTE, Z0X_OPERAD, ZRF_TOLPER, Z0W_RECEIT, B1_DESC, Z0X_OPERAD, Z0U_NOME  " +CRLF
    _cQry += " ) " +CRLF
    _cQry += " , DADOS AS ( " +CRLF
    _cQry += "      SELECT Z0W_FILIAL, Z0X_OPERAD, Z0W_DATA, Z0W_CURRAL, Z0W_LOTE " +CRLF
    _cQry += " 	      , B.PREV, QTDREAL, DIFE, ZRF_TOLPER  " +CRLF
    _cQry += " 		  , CASE WHEN ABS(DIFE) > ZRF_TOLPER THEN ABS(ZRF_TOLPER -DIFE ) ELSE 0 END EXCEDTOL " +CRLF
    _cQry += " 		  , (CASE WHEN ABS(DIFE) > ZRF_TOLPER THEN ISNULL((1-(ZDP_PERDES/100)/1), 1) ELSE 1 END) PONTO " +CRLF
    _cQry += " 		  , 1 AS PTOPOS " +CRLF
    _cQry += " 	   FROM BASE B " +CRLF
    _cQry += "   LEFT JOIN ZDP010 ZDP ON  " +CRLF
    _cQry += "             ZDP_FILIAL = Z0W_FILIAL " +CRLF
    _cQry += " 		AND Z0W_DATA >= ZDP_DATA --- REVER " +CRLF
    _cQry += " 		AND ZDP_OPERAC = 'P' " +CRLF
    _cQry += " 		AND ABS(ZRF_TOLPER-DIFE) BETWEEN ZDP_PERDE AND ZDP_PERATE " +CRLF
    _cQry += " 		AND ZDP.D_E_L_E_T_ = ' ' " +CRLF
    _cQry += " 	GROUP BY Z0W_FILIAL, Z0W_DATA, Z0W_CURRAL, Z0W_LOTE, Z0X_OPERAD, ZRF_TOLPER, B.PREV, B.QTDREAL, B.DIFE, ZDP_PERDES " +CRLF
    _cQry += " )  " +CRLF
    _cQry += "    SELECT Z0X_OPERAD, Z0W_DATA, SUM(PTOPOS) PTOPOS, SUM(PONTO) PONTOS " +CRLF
    _cQry += "      FROM DADOS " +CRLF
    _cQry += " 	 GROUP BY Z0X_OPERAD, Z0W_DATA " +CRLF

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliasX),.F.,.F.)

    MemoWrite("C:\totvs_relatorios\SQL_VAJOB16.sql" , _cQry)

    _cQry1 := "SELECT * FROM "+RetSqlName("ZCP")+" ZCP WHERE ZCP_FILIAL = '"+FWxFilial("ZCP")+"' AND ZCP_TIPOCR = 'T' AND ZCP_LANAUT = 'F' AND ZCP_CODIGO = '"+cCodCr+"'AND D_E_L_E_T_ = '' "
    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry1 ),(cAliasC),.F.,.F.)

    While !(cAliasX)->(Eof())
        If !(cAliasC)->(Eof())
            
            nNota := ROUND(( (cAliasC)->ZCP_NOTMAX / (cAliasX)->PTOPOS ) * (cAliasX)->PONTOS, 2)
            cCod := GetSx8Num("ZAV","ZAV_COD",,1) 
            If nNota > 0 
                RecLock("ZAV", .T.)
                    ZAV->ZAV_FILIAL := FWxFilial("ZAV")
                    ZAV->ZAV_COD    := cCod
                    ZAV->ZAV_MAT    := (cAliasX)->Z0X_OPERAD                        
                    ZAV->ZAV_DATA   := dDate //ZAV->ZAV_DATA   := sToD(dDt)
                    ZAV->ZAV_ITEM   := StrZero(++nItem,2)
                    ZAV->ZAV_CCOD   := cCodCr
                    ZAV->ZAV_NOTA   := nNota
                    ZAV->ZAV_ORIGEM := "A"
                ZAV->(MsUnlock())
            EndIf
        (cAliasX)->(dbSkip())
        EndIf
    EndDo
    (cAliasX)->(DBCloseArea())
    (cAliasC)->(DBCloseArea())

RestArea(aArea)

Return Nil
