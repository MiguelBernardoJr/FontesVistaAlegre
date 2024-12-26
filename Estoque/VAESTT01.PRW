#include "Protheus.ch"
#include "TopConn.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Arthur Toshio Oda Vanzella
 | Data:  07.10.2021                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/


User Function VAESTT01() // u_VAESTT01()

Local    cAlias  := "ZSR"
Local    cTitulo := "Sobras de Ração por Dia"
Local    cVldDel := ".T."
Local    cVldAlt := ".T." 

	AxCadastro(cAlias,cTitulo,cVldDel,cVldAlt)
Return nil


/*--------------------------------------------------------------------------------,
 | Principal: 					     U_TotalTrato()        		                  |
 | Func:  TotalizaTrato	            	          	            	              |
 | Autor: Arthur Toshio Oda Vanzella                     	          	          |
 | Data:  15-10-2021                                                              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
// ALERT(U_TotalTrato(DtoS(dDatabase)))                                                                                                                                                                                                                      
User Function TotalTrato(dData)
Local aArea   := GetArea()
Local nQtde := CriaVar( 'ZSR_KGFORN', .F.)
Local _cQry   := ""
//Local dData := DtoS(M->ZSR_DATA)

    
   _cQry := "	WITH TRATO AS (	" + CRLF
  _cQry +=	"    SELECT Z0W_FILIAL 	" + CRLF
  _cQry +=	"	     , Z0W_DATA " + CRLF
  _cQry +=	"        , CASE WHEN Z0W_PESDIG > 0 THEN Z0W_PESDIG " + CRLF
  _cQry +=	"               ELSE Z0W_QTDREA  " + CRLF
  _cQry +=	"          END AS Z0W_QTDREA  " + CRLF
  _cQry +=	"      FROM " + RetSqlName("Z0W") + " Z0W	" + CRLF
  _cQry +=	"     WHERE Z0W_FILIAL = '" + xFilial('Z0W') + "'	" + CRLF
  _cQry +=	"	   AND Z0W_DATA = '" +dData+ "' " + CRLF
  _cQry +=	"	   AND Z0W.D_E_L_E_T_ = ' ' " +CRLF 
  _cQry +=	"     )" +CRLF
  _cQry +=	"   SELECT SUM(Z0W_QTDREA) Z0W_QTDREA FROM TRATO	" +CRLF


    If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
        MemoWrite("C:\totvs_relatorios\TotalTrato.sql" , _cQry)
    EndIf
    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)
    if !TEMPSQL->(Eof())
        nQtde := TEMPSQL->Z0W_QTDREA
    EndIf
    TEMPSQL->(DbCloseArea())
	RestArea(aArea)
Return nQtde
//PadR(nQtde, TamSX3('ZSR_KGFORN')[1])

