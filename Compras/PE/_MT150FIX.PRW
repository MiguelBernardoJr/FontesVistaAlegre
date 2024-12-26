#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

User Function MT150FIX()
Local aRet   := {} // PARAMIXB
Local cAlias := "SC8"

DbSelectArea("SX3")
SX3->(DBSETORDER( 1 ))
SX3->(DBSEEK( cAlias )) // COTACAO
While !SX3->(Eof()) .and. X3_ARQUIVO == cAlias
    aAdd( aRet, {;
                    SX3->X3_TITULO,;
                    SX3->X3_CAMPO ;
    })
    SX3->(DbSkip())
EndDo

Return aRet

/*
User Function MaFisIni()
local xret := {}
    alert("MaFisIni")
Return xret


User Function MT150LIN()
    Local nPos := aScan( aHeaderPro, {|x| x[1] == "C8_XNOMFOR"})
    aDel( aHeaderPro, 3 )
    aSize( aHeaderPro, len(aHeaderPro)-1 )

    aDel( aHeaderPro, 3 )
    aSize( aHeaderPro, len(aHeaderPro)-1 )


    alert("MT150LIN")

Return 
*/
