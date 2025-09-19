#Include 'Protheus.ch'
User Function MNTA8053()
      
    Local aRot := aClone( ParamIXB[1] )
  
    aAdd( aRot, { 'Alterar Centro de Custos', "VAMNTI01.U_FwExecVamnti01()", 0, 4, , .F. } )
  
Return aRot
