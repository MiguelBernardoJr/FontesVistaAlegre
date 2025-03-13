WITH Historico AS ( 
     SELECT 'HISTÓRICO' ORIGEM, CY_FILIAL, CY_NUM, CY_ITEM,  
            CY_FORNECE, CY_LOJA, CY_PRODUTO, CY_UM,  
            CY_QUANT, CY_TOTAL, CY_PRECO, CY_VERSAO, D_E_L_E_T_ 
     FROM SCY010 
     WHERE CY_NUM = '077397                                            ' AND D_E_L_E_T_ = '' 
     AND CY_FILIAL = '0101001' 
     AND CY_VERSAO = (SELECT MAX(CY_VERSAO) FROM SCY010 WHERE CY_NUM = '077397' AND D_E_L_E_T_ = '') 
 ), 
 Atual AS ( 
     SELECT 'ATUAL' ORIGEM, C7_FILIAL, C7_NUM, C7_ITEM,  
            C7_FORNECE, C7_LOJA, C7_PRODUTO, C7_UM,  
            C7_QUANT, C7_TOTAL, C7_PRECO, D_E_L_E_T_ 
     FROM SC7010  
     WHERE C7_NUM = '077397                                            ' AND D_E_L_E_T_ = '' 
     AND C7_FILIAL = '0101001' 
 ) 
 , FINAL AS ( 
 SELECT  
     COALESCE(A.ORIGEM, H.ORIGEM, '') AS ORIGEM, 
     COALESCE(A.C7_FILIAL, H.CY_FILIAL, '') AS FILIAL, 
     COALESCE(A.C7_NUM, H.CY_NUM, '') AS NUMERO, 
     COALESCE(A.C7_ITEM, H.CY_ITEM, '') AS ITEM, 
      
     -- Produto 
     COALESCE(H.CY_PRODUTO, '') AS PRODUTO_HISTORICO, 
     COALESCE(A.C7_PRODUTO, '') AS PRODUTO_ATUAL, 
      
     -- Unidade de Medida 
     COALESCE(H.CY_UM, '') AS UNIDADE_HISTORICO, 
     COALESCE(A.C7_UM, '') AS UNIDADE_ATUAL, 
      
     -- Quantidade (substitui NULL por 0) 
     COALESCE(H.CY_QUANT, 0) AS QUANTIDADE_HISTORICO, 
     COALESCE(A.C7_QUANT, 0) AS QUANTIDADE_ATUAL, 
      
     -- Unitario (substitui NULL por 0) 
     COALESCE(H.CY_PRECO, 0) AS UNIT_HISTORICO, 
     COALESCE(A.C7_PRECO, 0) AS UNIT_ATUAL, 
  
     -- Total (substitui NULL por 0) 
     COALESCE(H.CY_TOTAL, 0) AS TOTAL_HISTORICO, 
     COALESCE(A.C7_TOTAL, 0) AS TOTAL_ATUAL, 
      
     -- Versão do Histórico 
     COALESCE(H.CY_VERSAO, '') AS VERSAO_HISTORICO, 
      
     -- Se o item for novo, exibe 'SIM' 
     CASE  
         WHEN H.CY_ITEM IS NULL AND A.C7_ITEM IS NOT NULL THEN 'SIM'  
         ELSE 'NAO' 
     END AS NOVO_ITEM, 
  
     -- Flag para indicar alteração 
     CASE  
         WHEN (H.CY_PRODUTO <> A.C7_PRODUTO OR H.CY_UM <> A.C7_UM OR H.CY_QUANT <> A.C7_QUANT  
             OR H.CY_TOTAL <> A.C7_TOTAL OR H.CY_PRECO <> A.C7_PRECO  
             OR H.CY_FORNECE <> A.C7_FORNECE OR H.CY_LOJA <> A.C7_LOJA)  
         THEN 'SIM' 
         ELSE 'NAO' 
     END AS ALTERADO, 
  
     -- Lista os campos alterados separados por '|'' 
     isnull(STUFF( 
         (CASE WHEN H.CY_PRODUTO <> A.C7_PRODUTO THEN '|C7_PRODUTO' ELSE '' END) + 
         (CASE WHEN H.CY_UM <> A.C7_UM THEN '|C7_UM' ELSE '' END) + 
         (CASE WHEN H.CY_QUANT <> A.C7_QUANT THEN '|C7_QUANT' ELSE '' END) + 
         (CASE WHEN H.CY_TOTAL <> A.C7_TOTAL THEN '|C7_TOTAL' ELSE '' END) + 
         (CASE WHEN H.CY_PRECO <> A.C7_PRECO THEN '|C7_PRECO' ELSE '' END) + 
         (CASE WHEN H.CY_FORNECE <> A.C7_FORNECE THEN '|C7_FORNECE' ELSE '' END) + 
         (CASE WHEN H.CY_LOJA <> A.C7_LOJA THEN '|C7_LOJA' ELSE '' END), 
     1, 1, ''),'') AS CAMPOS_ALTERADOS 
  
 FROM Atual A 
 FULL OUTER JOIN Historico H 
 ON A.C7_NUM = H.CY_NUM AND A.C7_ITEM = H.CY_ITEM 
 ) 
 SELECT * FROM FINAL WHERE ALTERADO = 'SIM' OR NOVO_ITEM = 'SIM' 
