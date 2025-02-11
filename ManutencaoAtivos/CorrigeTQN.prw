#include "TOTVS.CH"

User Function MNTIGTQN()
    Local aArea  := FWGetArea()
    Local nAbast01 := 1
    Local cAbast01 := StrZero(nAbast01,TamSX3("TQN_NABAST")[1])
    Local nAbast02 := 1
    Local cAbast02 := StrZero(nAbast02,TamSX3("TQN_NABAST")[1])
    Local nAbast03 := 1
    Local cAbast03 := StrZero(nAbast03,TamSX3("TQN_NABAST")[1])
    Local nAbast05 := 1
    Local cAbast05 := StrZero(nAbast05,TamSX3("TQN_NABAST")[1])
    Local nAbast12 := 1
    Local cAbast12 := StrZero(nAbast12,TamSX3("TQN_NABAST")[1])
    Local nAbast13 := 1
    Local cAbast13 := StrZero(nAbast13,TamSX3("TQN_NABAST")[1])
    Local nAbast15 := 1
    Local cAbast15 := StrZero(nAbast15,TamSX3("TQN_NABAST")[1])
    Local nAbast17 := 1
    Local cAbast17 := StrZero(nAbast17,TamSX3("TQN_NABAST")[1])
    Local nAbast20 := 1
    Local cAbast20 := StrZero(nAbast20,TamSX3("TQN_NABAST")[1])
    Local nAbast21 := 1
    Local cAbast21 := StrZero(nAbast21,TamSX3("TQN_NABAST")[1])
    Local nAbast23 := 1
    Local cAbast23 := StrZero(nAbast23,TamSX3("TQN_NABAST")[1])
    Local nAbast28 := 1
    Local cAbast28 := StrZero(nAbast28,TamSX3("TQN_NABAST")[1])
    Local nAbast33 := 1
    Local cAbast33 := StrZero(nAbast33,TamSX3("TQN_NABAST")[1])
    Local nRecno := 1
    Local cQry :=  "select R_E_C_N_O_ AS RECNO from TQN010 ORDER BY R_E_C_N_O_"
    Local cAlias := GetNextAlias()

    
    MpSysOpenQry(cQry,cAlias)
    
    
    DBSelectArea("TQN")
    
    Set DELETE off

    (CALIAS)->(DBGOTOP())
    while !(cAlias)->(EOF())
        nRecno := (CALIAS)->RECNO
        TQN->(DBGoTo(nRecno))

        ConOut("Processando Recno TQN: " + Str((CALIAS)->RECNO) + " de 54766" )
        if TQN->TQN_FILIAL == '0101001'
            RecLock("TQN",.F.)
                TQN->TQN_NABAST := cAbast01
            TQN->(MSUNLOCK())
            nAbast01 += 1
            cAbast01 := StrZero(nAbast01,TamSX3("TQN_NABAST")[1])
        elseif TQN->TQN_FILIAL == '0101002'
            RecLock("TQN",.F.)
                TQN->TQN_NABAST := cAbast02
            TQN->(MSUNLOCK())
            nAbast02 += 1
            cAbast02 := StrZero(nAbast02,TamSX3("TQN_NABAST")[1])
        elseif TQN->TQN_FILIAL == '0101003'
            RecLock("TQN",.F.)
                TQN->TQN_NABAST := cAbast03
            TQN->(MSUNLOCK())
            nAbast03 += 1
            cAbast03 := StrZero(nAbast03,TamSX3("TQN_NABAST")[1])
        elseif TQN->TQN_FILIAL == '0101005'
            RecLock("TQN",.F.)
                TQN->TQN_NABAST := cAbast05
            TQN->(MSUNLOCK())
            nAbast05 += 1
            cAbast05 := StrZero(nAbast05,TamSX3("TQN_NABAST")[1])
        elseif TQN->TQN_FILIAL == '0101012'
            RecLock("TQN",.F.)
                TQN->TQN_NABAST := cAbast12
            TQN->(MSUNLOCK())
            nAbast12 += 1
            cAbast12 := StrZero(nAbast12,TamSX3("TQN_NABAST")[1])
        elseif TQN->TQN_FILIAL == '0101013'
            RecLock("TQN",.F.)
                TQN->TQN_NABAST := cAbast13
            TQN->(MSUNLOCK())
            nAbast13 += 1
            cAbast13 := StrZero(nAbast13,TamSX3("TQN_NABAST")[1])
        elseif TQN->TQN_FILIAL == '0101015'
            RecLock("TQN",.F.)
                TQN->TQN_NABAST := cAbast15
            TQN->(MSUNLOCK())
            nAbast15 += 1
            cAbast15 := StrZero(nAbast15,TamSX3("TQN_NABAST")[1])
        elseif TQN->TQN_FILIAL == '0101017'
            RecLock("TQN",.F.)
                TQN->TQN_NABAST := cAbast17
            TQN->(MSUNLOCK())
            nAbast17 += 1
            cAbast17 := StrZero(nAbast17,TamSX3("TQN_NABAST")[1])
        elseif TQN->TQN_FILIAL == '0101020'
            RecLock("TQN",.F.)
                TQN->TQN_NABAST := cAbast20
            TQN->(MSUNLOCK())
            nAbast20 += 1
            cAbast20 := StrZero(nAbast20,TamSX3("TQN_NABAST")[1])
        elseif TQN->TQN_FILIAL == '0101021'
            RecLock("TQN",.F.)
                TQN->TQN_NABAST := cAbast21
            TQN->(MSUNLOCK())
            nAbast21 += 1
            cAbast21 := StrZero(nAbast21,TamSX3("TQN_NABAST")[1])
        elseif TQN->TQN_FILIAL == '0101023'
            RecLock("TQN",.F.)
                TQN->TQN_NABAST := cAbast23
            TQN->(MSUNLOCK())
            nAbast23 += 1
            cAbast23 := StrZero(nAbast23,TamSX3("TQN_NABAST")[1])
        elseif TQN->TQN_FILIAL == '0101028'
            RecLock("TQN",.F.)
                TQN->TQN_NABAST := cAbast28
            TQN->(MSUNLOCK())
            nAbast28 += 1
            cAbast28 := StrZero(nAbast28,TamSX3("TQN_NABAST")[1])
        elseif TQN->TQN_FILIAL == '0101033'
            RecLock("TQN",.F.)
                TQN->TQN_NABAST := cAbast33
            TQN->(MSUNLOCK())
            nAbast33 += 1
            cAbast33 := StrZero(nAbast33,TamSX3("TQN_NABAST")[1])
        endif
        
        (CALIAS)->(DBSKIP())
    enddo
Set DELETE on
    (CALIAS)->(DBCLOSEAREA(  ))
    FWRestArea(aArea)
RETURN

User Function MNTIGTTV()
    Local aArea     := FWGetArea()
    Local aMsg      := {}
    Local cQry :=  "select R_E_C_N_O_ AS RECNO from TQN010 ORDER BY R_E_C_N_O_"
    Local cAlias := GetNextAlias()

    Set DELETE off

    MpSysOpenQry(cQry,cAlias)

    DBSelectArea("TQN")

    DBSelectArea("TTV")
    TTV->(DBSETORDER( 3 ))

    (CALIAS)->(DBGOTOP())
    WHILE !(CALIAS)->(Eof())
        nRecno := (CALIAS)->RECNO
        TQN->(DBGoTo(nRecno))

/*         IF nRecno == 15172 .or. nRecno == 17088
            nRecno := nRecno
        ENDIF */
        ConOut("Processando Recno TQN: " + Str(nRecno) + " de 54766" )
        //WHILE !TQN->(EOF())
        IF TTV->(DBSEEK( TQN->(TQN_FILIAL + TQN_POSTO + TQN_LOJA + TQN_TANQUE + TQN_BOMBA + dTos(TQN_DTABAS) + TQN_HRABAS)))

/*             IF TTV->(RECNO(  )) == 15546 .OR. 17500
                nRecno := nRecno
            endif 
 */
            IF TTV->TTV_TIPOLA != '3' .and. TTV->TTV_TIPOLA != '5' .AND. TQN->TQN_QUANT == TTV->TTV_CONSUM
                RECLOCK( "TTV", .F. )
                    TTV->TTV_NABAST := TQN->TQN_NABAST
                TTV->(MSUNLOCK())
            endif
        ELSE
            aAdd(aMsg,{(CALIAS)->RECNO})
        ENDIF

        (CALIAS)->(DBSKIP())
    enddo
    
    Set DELETE off

    (CALIAS)->(DBCLOSEAREA(  ))
    FwRestArea(aArea)
RETURN

