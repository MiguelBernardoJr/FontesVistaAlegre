#Include 'Protheus.ch'

User Function ATF060END()
    Local aArea := GetArea()

    IF AllTrim(FN9->FN9_MENNOT) <> ""
        RecLock("SF2",.F.)
            SF2->F2_MENNOTA := AllTrim(FN9->FN9_MENNOT)        
        SF2->(MsUnLock())
    ENDIF 

    RestArea(aArea)
Return
