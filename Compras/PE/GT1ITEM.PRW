#INCLUDE 'PROTHEUS.CH'

User Function GT1ITEM()
    Local aParam    := PARAMIXB
    Local aArea     := GetArea()
    Local aAdItem   := {}
    Local _nPosPed  := aScan(aHeader, {|x| x[2] == PadR("ZA2_PEDIDO", 10)})
    Local cPedido   := ""

    If _nPosPed > 0
        
        cPedido := aParam[_nPosPed]

        IF !Empty(aParam[_nPosPed])
        
            if select("SC7") == 0
                DBSELECTAREA("SC7")
            endif
            
            SC7->(DBSETORDER(1))
            
            IF SC7->(DBSEEK(FWxFilial("SC7")+cPedido))
                aAdd(aAdItem, {"D1_DATPRF", SC7->C7_DATPRF, Nil})
            ENDIF
            
        endif
    EndIf

    RestArea(aArea)
Return(aAdItem)
