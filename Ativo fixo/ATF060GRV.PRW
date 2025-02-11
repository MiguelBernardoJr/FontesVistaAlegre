#include 'totvs.ch'
#include "rwmake.ch"    
 
User Function ATF060GRV()
 
    Local Modelo060  := PARAMIXB[1]
    Local aArea      := GetArea()
    Local cBase      := Modelo060:GetValue("GridFNR",'FNR_CBAORI')
    Local cItem      := Modelo060:GetValue("GridFNR",'FNR_ITEORI')
    Local cFilMovi   := Modelo060:GetValue("FieldFN9",'FN9_FILIAL')
    Local cChave     := cFilMovi + cBase + cItem
 
    MsgAlert("Teste1")
    
    /* dbSelectArea("SN4")
    dbSetOrder(1)
 
    If dbSeek(cChave)
        While SN4->(!EOF()) .And. cChave==SN4->(N4_FILIAL+N4_CBASE+N4_ITEM)
            
            SN4->(dbSkip())
        EndDo
    Endif */
 
    RestArea(aArea)
 
Return  
