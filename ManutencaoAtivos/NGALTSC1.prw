#include 'totvs.ch'
  
User Function NGALTSC1()
    Local aItens    := aClone( ParamIXB[1] )
    Local aCabec    := aClone( ParamIXB[2] )
    
    aAdd(  aItens, { 'C1_XAPLICA'   , 'D'    , Nil } )
  
Return { aItens, aCabec }
