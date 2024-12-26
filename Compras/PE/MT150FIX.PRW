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


User Function MT150GET()
    
    Local cCpACols := aClone(aCols)
    Local cCampos := "C8_XNOMFOR" // ;C8_DESCRI
    Local aCampos := STRTOKARR( cCampos, ";" )
    Local nPos    := 0, nI := 0, nJ := 0
    
    For nI := 1 to Len(aCampos)
        If !Empty(aCampos[nI])
            If (nPos := aScan( aHeaderPro, {|x| AllTrim(x[1]) == aCampos[nI] })) > 0
                
                For nJ := 1 to Len(cCpACols)
                    aDel( cCpACols[nJ], nPos)
                    aSize( cCpACols[nJ], len(cCpACols[nJ])-1 )
                Next nJ

                aDel( aHeader, nPos)
                aSize( aHeader, len(aHeader)-1 )

                aDel( aHeaderPro, nPos)
                aSize( aHeaderPro, len(aHeaderPro)-1 )
            EndIf
        EndIf
    Next nI

Return cCpACols

