#include "Protheus.ch"

#include "TopConn.ch"

// FUNCAO PARA TESTAR SE O MOVIMENTO ESTA CONCILIADO, PARA SER CONTABILIZADO

User Function CONC()

Local cRet := .T. // NAO CONCILIADO

Local cSQL





If alltrim(SE5->E5_LOTE) <> ''

 cSql:=" SELECT COUNT(*) AS QTDE FROM "+RetSqlName("SE5")

 cSql+=" WHERE D_E_L_E_T_ <> '*' " 

 cSql+=" AND E5_FILIAL = '"+xFilial('SE5')+"' " 

 cSql+=" AND E5_RECPAG = '"+SE5->E5_RECPAG+"' "

 cSql+=" AND E5_LOTE = '"+SE5->E5_LOTE+"' "

 cSql+=" AND E5_DATA = '"+DtoS(SE5->E5_DATA)+"' "

 cSql+=" AND E5_RECONC = 'x' "

 TCQuery cSql NEW ALIAS "LOTE"

 If LOTE->QTDE > 0

  cRet := .F.

 Endif 

 LOTE->(DbCloseArea())

Elseif alltrim(SE5->E5_NUMCHEQ) <> ''

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



Else 

 If SE5->E5_RECONC == 'x'

  cRet := .F.

 EndIf

Endif



Return cRet

