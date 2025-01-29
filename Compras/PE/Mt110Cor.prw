#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc}Mt110Cor
    Manipula o Array com as regras e cores da Mbrowse. Usado para reclassificar a legenda dos 
    registros conforme o campo C1_XAPROV, que identifica a aprovação de acordo com a posição no 
    do caracter no campo.

@since 20170328
@author JRScatolon
@return Array, Aray com as expressões para identificar a legenda do campo  
/*/
user function Mt110Cor()
local aCores := ParamIXB[1]
//local i, nLen
	
    //DbSelectArea("Z0A")
    //DbSetOrder(1) // Z0A_FILIAL + Z0A_USERID 
    //if StrTran(aCores[i][1], "C1_APROV", "SubStr(C1_XAPROV, " + Z0A->Z0A_SEQ + ", 1)") .and. Z0A->Z0A_MSBLQL <> '1'
    //    nLen := Len(aCores)
    //    for i := 1 to nLen
    //        if At("C1_APROV", Upper(aCores[i][1])) > 0
    //            aCores[i][1] := StrTran(aCores[i][1], "C1_APROV", "SubStr(C1_XAPROV, " + Z0A->Z0A_SEQ + ", 1)")
    //        endif
    //    next
    //endif
    aAdd(aCores,{iif(U_MT110CE(),,),"BR_CINZA"})
return aCores

User Function MT110CE()
    Local lRet := .T.
    Local cNum
    
    cNum := SC1->C1_NUM

Return lRet

User Function MT110LEG()
// aCores     = Array contendo as Legendas para a apresentação das
//cores do status da SC na mbrowse.
// lGspInUseM = Indica se há integração com o modulo GSP
Local aNewLegenda  := aClone(PARAMIXB[1])  // aLegenda
    aAdd(aNewLegenda,{'BR_CINZA'    , 'Pedido Entregue'})
Return (aNewLegenda) 
