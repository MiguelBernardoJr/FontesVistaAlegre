#Include "TOTVS.ch"

User Function z094INI(cCampo)
    Local aArea     := FwGetArea()
    Local cRet      := ''
    //Local cCampo    := SubStr(ReadVar(),at('>',ReadVar())+1,Len(ReadVar()))
    
    DbSelectArea("SC7")
    DbSetOrder(1)

    if SC7->(DbSeek(FWxFilial("SC7")+ALLTRIM(SCR->CR_NUM)+'0001'+Space(TamSx3("C7_SEQUEN")[1])))
        if cCampo == "CR_FORNECE"
            DbSelectArea("SA2")
            DbSetOrder(1)
        
            if SA2->(DbSeek(FWxFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))
                cRet := AllTrim(SA2->A2_NOME)    
            endif

            SA2->(DBCloseArea())
        else // CR_COMPRAD

            cRet := UsrFullName(SC7->C7_USER)

        endif

    endif

    SC7->(DBCloseArea())

    FwRestArea(aArea)
Return cRet
