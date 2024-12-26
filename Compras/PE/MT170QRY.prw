
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COMXFUN.CH" 

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

//User Function MT170FIM()
//   
//   aSolic    := PARAMIXB[1]
//   
//   Local aArea         := FWGetArea()
//   Local aDados        := {}
//   Local aRet          := {}
//   Local nI, nX    
//   Local lAdd          := .T.
//   Local cSolic        := aSolic[1,2]
//   Local aResultado    := {}
//
//   For nI := 1 to Len(aSolic)
//       
//       if SB1->(DBSeek(FWxFilial("SB1")+aSolic[nI,1]))
//           cGrupo  := SB1->B1_GRUPO
//           cProd   := SB1->B1_COD
//           
//           if Len(aDados) == 0
//               aAdd(aDados,{cGrupo,cSolic,{cProd}})
//
//               cSolic := StrZero((Val(cSolic)+1),TamSx3("C1_NUM")[1])
//
//           else
//               lAdd := .T. 
//
//               For nX := 1 to Len(aDados)
//                   if aDados[nX,1] == cGrupo
//                       aAdd(aDados[nX,3],cProd)
//                       lAdd := .F.
//                       exit
//                   endif
//               next nX
//
//               if lAdd
//                   aAdd(aDados,{cGrupo,cSolic,{cProd}})
//
//                   cSolic := StrZero((Val(cSolic)+1),TamSx3("C1_NUM")[1])
//               endif
//               
//           endif
//
//       else
//           MsgStop("Produto "+AllTrim(aSolic[nI,1])+" não encontrado!")
//       endif 
//   Next nI
//
//   For nI := 1 to Len(aDados)
//       cSolic := aDados[nI,2]
//
//      // aResultado := ComGeraDoc(aDados[nI,3],.T.,.F.,.F.,.F.,SomaPrazo(dDataBase, 30),"MATA170",/*08*/,1)
//       For nX := 1 to Len(aDados[nI,3])
//           cProd := aDados[nI,3,nX]
//           aAdd(aRet,{cProd,cSolic,StrZero(nX,TamSx3("C1_ITEM")[1])})
//       next nX
//   Next nI
//   
//  // aSolic := {}
//  // aSolic := aClone(aRet)
//
//   FwRestArea(aArea)
//Return aRet 
