#include 'topconn.ch'
 
// FUNCAO PARA TESTAR SE O MOVIMENTO DO CHEQUE TOTALIZADOR ESTÁ CONCILIADO
User Function CONCCH()
Local cRet := .T. // NAO CONCILIADO
Local cSQL


if alltrim(SE5->E5_NUMCHEQ) <> ''
 cSql:=" SELECT COUNT(*) AS QTDE FROM "+RetSqlName("SE5")
 cSql+=" WHERE D_E_L_E_T_ <> '*' " 
 cSql+=" AND E5_FILIAL = '"+xFilial('SE5')+"' " 
 cSql+=" AND E5_RECPAG = '"+SE5->E5_RECPAG+"' "
 cSql+=" AND E5_NUMCHEQ = '"+SE5->E5_NUMCHEQ+"' "
 cSql+=" AND E5_DATA = '"+DtoS(SE5->E5_DATA)+"' "
 cSql+=" AND E5_RECONC = 'x' "
 TCQuery cSql NEW ALIAS "NUMCHEQ"
 If NUMCHEQ->QTDE > 0
  cRet := .F.
 Endif 
 NUMCHEQ->(DbCloseArea())
ENDIF

Return cRet

