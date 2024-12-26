
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COMXFUN.CH" 

User Function MT170SC1()

    If IsBlind()
        cUser := "ricardo.santana"
    else
        cUser := cUserName
    endif

    //SB1->(DbSetOrder(1))
    SB1->(DBSeek(FwXFilial("SB1")+SC1->C1_PRODUTO))

    RecLock("SC1",.f.)
        If !Empty(SB1->B1_C1DESC)
            SC1->C1_OBS := AllTrim(SB1->B1_C1DESC)
        endif

        if Empty(SC1->C1_GRPRD)
            SC1->C1_GRPRD   := SB1->B1_GRUPO
        endif

        SC1->C1_SOLICIT := cUser
    SC1->(MsUnLock())

Return

