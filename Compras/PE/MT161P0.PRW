#INCLUDE "PROTHEUS.CH"

User Function MT161CPO()
    Local aPropostas := PARAMIXB[1] // Array com os dados das propostas dos Fornecedores
    Local aItens     := PARAMIXB[2] // Array com os dados da grid "Produtos"
    Local aCampos    := {} // Array com os campos adicionados na grid "Item da Proposta"
    Local aCposProd  := {"C8_VAUNIT"} // Array com os campos adicionados na grid "Produtos"
    Local aRetorno   := {}
    Local nX         := 0
    Local nY         := 0
    Local nZ         := 0
    Local nI         := 0
    Local aPreco     := {}
    
    For nX := 1 To Len(aItens)
        aAdd(aPreco,{aItens[nX][1],999999999})
        //AADD(aItens[nX], "TESTE "+Str(nCount,2))
    Next nX
    
    For nX := 1 To Len(aPropostas)
        For nY := 1 To Len(aPropostas[nX])
            For nZ := 1 To Len(aPropostas[nX][nY][2])
                //AADD(aPropostas[nX][nY][2][nZ], "TESTE "+Str(nCount,2))
                for nI := 1 to len(aPreco)
                    if aPropostas[nX][nY][2][nI][3] == aPreco[nI][1]
                        if aPropostas[nX][nY][2][nI][13] < aPreco[nI][2] .and. aPropostas[nX][nY][2][nI][13] != 0
                            aPreco[nI][2] := aPropostas[nX][nY][2][nI][13]
                        endif
                    endif
                next nI
            Next nZ
        Next nY
    Next nX

    For nX := 1 To Len(aItens)
        AADD(aItens[nX], aPreco[nX][2])
    Next nX

    AADD(aRetorno, aPropostas )
    AADD(aRetorno, aCampos    )
    AADD(aRetorno, aItens     )
    AADD(aRetorno, aCposProd  )
    
Return aRetorno
