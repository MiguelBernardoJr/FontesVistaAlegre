
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} MT170QRY
Ponto de Entrada para  manipular a Query que filtra os produtos que serão utilizados para a geração de Solicitações de compras por ponto de Pedido.
@type function
@version  1
@author Arthur Toshio
@since 6/26/2024
@return CNewQuery, CNewQuery
/*/
User Function MT170QRY()
cNewQry := ParamIXB[1]

    cNewQry += " AND B1_GRUPO NOT IN ('01','02','03','BOV','05','LOTE','99','BMS',' ','APR') "
    cNewQry += " and B1_GRUPO NOT IN (SELECT BM_GRUPO FROM SBM010 WHERE BM_GRUPO = B1_GRUPO AND BM_DESC LIKE '%IMOBILI%' AND SBM010.D_E_L_E_T_ =' ' ) "
    cNewQry += " AND B1_EMIN <> 0  AND B1_LE <> 0 AND B1_COD NOT IN ('TERCEIROS','MANUTENCAO') "

Return  (cNewQry)

User Function MT170FIM()

Local aSolic := PARAMIXB[1]


Return 
