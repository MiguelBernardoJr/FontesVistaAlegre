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

User Function JOB13VA() //U_JOB13VA()
    Local aArea         := GetArea()
    Local cAliasZ0X     := GetNextAlias()
    Local cAliasZCP     := GetNextAlias()
    Local cAliasTemNF   := GetNextAlias()
    Local _cQry         := ""
    Local cCod              
    Local nItem         := 0
//    Local dDt

/*
    13/10/2022
    Arthur Toshio
    Selectionar apenas Operadores que trabalharam no dia para cirar o registro na ZAV
*/
    _cQry += " WITH TRATO AS (" +CRLF 
    _cQry += " 		SELECT DISTINCT Z0W_OPERAD, Z0U_NOME, 'T' TIPO	" +CRLF 
    _cQry += " 		  FROM "+RetSqlName("Z0W")+" Z0W" +CRLF 
    _cQry += " 		  JOIN "+RetSqlName("Z0U")+" Z0U ON" +CRLF 
    _cQry += " 		       Z0U_FILIAL = Z0W_FILIAL " +CRLF 
    _cQry += " 		   AND Z0U_CODIGO = Z0W_OPERAD" +CRLF 
    _cQry += " 		   AND Z0U_LANAUT = 'T'" +CRLF 
    _cQry += " 		   AND Z0U.D_E_L_E_T_ = ' ' " +CRLF 
    _cQry += " 		 WHERE Z0W_FILIAL = '"+FWxFilial("Z0W")+"'  " +CRLF 
    _cQry += " 		   AND Z0W_OPERAD <> ' ' " +CRLF 
    _cQry += " 		   AND Z0W_DATA = '"+dToS(dDataBase)+"' " + CRLF
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
    _cQry += " 	   AND Z0Y_DATA = '"+dToS(dDataBase)+"' " + CRLF
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
    _cQry += " 	   AND Z0Y_DATA = '"+dToS(dDataBase)+"' " + CRLF
    _cQry += " 	   AND Z0Y_ORIGEM = 'B' " +CRLF 
    _cQry += " 	   AND Z0Y.D_E_L_E_T_ = ' ' " +CRLF 
    _cQry += " 	 )" +CRLF 
    _cQry += " 	 SELECT * FROM TRATO " +CRLF 
    _cQry += " 	 UNION " +CRLF 
    _cQry += " 	 SELECT * FROM PAZEIRO " 

/*
    _cQry := " SELECT Z0X_CODIGO " + CRLF 
    _cQry += " , Z0X_OPERAD " + CRLF 
    _cQry += " , Z0X_EQUIP " + CRLF 
    _cQry += " , Z0X_DATA " + CRLF 
    _cQry += " FROM "+RetSqlName("Z0X")+" Z0X " + CRLF 
    _cQry += " JOIN "+RetSqlName("Z0U")+" Z0U ON Z0X.Z0X_FILIAL = Z0U.Z0U_FILIAL" + CRLF 
    _cQry += " AND Z0X.Z0X_OPERAD = Z0U.Z0U_CODIGO " + CRLF 
    _cQry += " AND Z0U.Z0U_LANAUT = 'T' " + CRLF 
    _cQry += " AND Z0U.D_E_L_E_T_ = '' " + CRLF 
    _cQry += " WHERE Z0X.Z0X_FILIAL = '"+FWxFilial("Z0X")+"' " + CRLF 
    //_cQry += " AND Z0X.Z0X_DATA = (SELECT MAX(ZAV_DATA)+1 FROM ZAV010) " + CRLF
    _cQry += " AND Z0X.Z0X_DATA = '"+dToS(dDataBase)+"' " + CRLF
    _cQry += " AND Z0X.Z0X_OPERAD != '' " + CRLF 
    _cQry += " AND Z0X.D_E_L_E_T_ = '' " + CRLF 
    */
    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliasZ0X),.F.,.F.)
    
    MemoWrite("C:\totvs_relatorios\SQL_VAJOB13.sql" , _cQry)

    _cQry := "SELECT * FROM "+RetSqlName("ZCP")+" ZCP WHERE D_E_L_E_T_ = '' "

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliasZCP),.F.,.F.)

    DbSelectArea("ZAV")
    ZAV->(DbSetOrder(3))

        While !(cAliasZ0X)->(Eof())
    //dDt := (cAliasZ0X)->Z0X_DATA
        nItem := 0
        //if ZAV->(!DbSeek(FWxFilial("ZAV") + (cAliasZ0X)->Z0W_OPERAD + dToS(dDataBase)))
        cQryNota := " SELECT * FROM "+RetSqlName("ZAV")+" ZAV " + CRLF 
        cQryNota += "   JOIN "+RetSqlName("ZCP")+" ZCP  ON ZCP_FILIAL = '"+FWxFilial("ZCP")+"' " + CRLF
        cQryNota += "   AND ZCP_CODIGO = ZAV_CCOD AND ZCP_LANAUT = 'T' AND ZCP.D_E_L_E_T_ = ' ' AND ZCP_CODIGO = '"+(cAliasZCP)->ZCP_CODIGO+"' " +CRLF 
        cQryNota += " WHERE ZAV_FILIAL = '"+FWxFilial("ZAV")+"' "  + CRLF 
        cQryNota += "   AND ZAV_DATA = '"+DTOS( dDataBase )+"' " + CRLF 
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
                        ZAV->ZAV_DATA   := dDataBase //ZAV->ZAV_DATA   := sToD(dDt)
                        ZAV->ZAV_ITEM   := StrZero(++nItem,2)
                        ZAV->ZAV_CCOD   := (cAliasZCP)->ZCP_CODIGO
                        ZAV->ZAV_NOTA   := (cAliasZCP)->ZCP_NOTMAX
                        ZAV->ZAV_ORIGEM := "A"
                    MsUnlock()
                    
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

User Function JOB14VA() // U_JOB14VA()
    Local aArea         := GetArea()
    Local cAliasX       := GetNextAlias()
    Local cAliasC     := GetNextAlias()
    Local cCrPaz        := GetMV("VA_CRIPAZ",,"20") //Codigo de Critério para processamento - Carrgamento
    Local cCrMot        := GetMV("VA_CRIMOT",,"09") //Codigo de Critério para processamento - Carrgamento
    Local _cQry         := ""
    Local cCod          := 0
    Local nItem         := 0
    Local nNota1        := 0
    Local nNota2        := 0


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
    _cQry += "	    AND Z0Y_DATA = '"+dToS(dDataBase)+"' " + CRLF
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
                        ZAV->ZAV_DATA   := dDataBase //ZAV->ZAV_DATA   := sToD(dDt)
                        ZAV->ZAV_ITEM   := StrZero(++nItem,2)
                        ZAV->ZAV_CCOD   := cCodCr
                        ZAV->ZAV_NOTA   := nNota1
                        ZAV->ZAV_ORIGEM := "A"
                    MsUnlock()
                EndIf
                If !(cAliasX)->ORIGEMPESO == "MOTORISTA"
                    
                    nNota2 := Round( ( (cAliasC)->ZCP_NOTMAX / (cAliasX)->PONTOPOS ) * (cAliasX)->PONTOOP2 ,2)
                    cCod := GetSx8Num("ZAV","ZAV_COD",,1) 
                    If nNota2 > 0 
                        RecLock("ZAV", .T.)
                            ZAV->ZAV_FILIAL := FWxFilial("ZAV")
                            ZAV->ZAV_COD    := cCod
                            ZAV->ZAV_MAT    := (cAliasX)->Z0Y_OPER2
                            ZAV->ZAV_DATA   := dDataBase //ZAV->ZAV_DATA   := sToD(dDt)
                            ZAV->ZAV_ITEM   := StrZero(++nItem,2)
                            ZAV->ZAV_CCOD   := cCodCr
                            ZAV->ZAV_NOTA   := nNota2
                            ZAV->ZAV_ORIGEM := "A"
                        MsUnlock()
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


User Function JOB15VA()  // U_JOB15VA()
    Local aArea         := GetArea()
    Local cAliasX       := GetNextAlias()
    Local cAliasC     := GetNextAlias()
    Local cCodCr        := GetMV("VA_CRIFP",,"16") //Codigo de Critério para processamento - Fornecimento Parcial
    Local _cQry         := ""
    Local cCod          := 0
    Local nItem         := 0

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
    _cQry += " 	    AND Z0W_DATA = '"+dToS(dDataBase)+"' " + CRLF
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
                    ZAV->ZAV_DATA   := dDataBase //ZAV->ZAV_DATA   := sToD(dDt)
                    ZAV->ZAV_ITEM   := StrZero(++nItem,2)
                    ZAV->ZAV_CCOD   := cCodCr
                    ZAV->ZAV_NOTA   := nNota
                    ZAV->ZAV_ORIGEM := "A"
                MsUnlock()
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


User Function JOB16VA()
    Local aArea         := GetArea()
    Local cAliasX       := GetNextAlias()
    Local cAliasC     := GetNextAlias()
    Local cCodCr        := GetMV("VA_CRIFP",,"17") //Codigo de Critério para processamento - Fornecimento TOtal
    Local _cQry         := ""
    Local cCod          := 0
    Local nItem         := 0

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
    _cQry += " 	    AND Z0W_DATA = '"+dToS(dDataBase)+"' " + CRLF
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
                    ZAV->ZAV_DATA   := dDataBase //ZAV->ZAV_DATA   := sToD(dDt)
                    ZAV->ZAV_ITEM   := StrZero(++nItem,2)
                    ZAV->ZAV_CCOD   := cCodCr
                    ZAV->ZAV_NOTA   := nNota
                    ZAV->ZAV_ORIGEM := "A"
                MsUnlock()
            EndIf
        (cAliasX)->(dbSkip())
        EndIf
    EndDo
    (cAliasX)->(DBCloseArea())
    (cAliasC)->(DBCloseArea())

RestArea(aArea)

Return Nil
