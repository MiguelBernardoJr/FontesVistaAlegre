#INCLUDE "PROTHEUS.CH"

User Function MT161CPO()
    Local aPropostas := PARAMIXB[1] // Array com os dados das propostas dos Fornecedores
    Local aItens     := PARAMIXB[2] // Array com os dados da grid "Produtos"
    Local aCampos    := {"C8_XMARCA"} // Array com os campos adicionados na grid "Item da Proposta"
    Local aCposProd  := {"B1_UPRC","C8_VAUNIT"} // Array com os campos adicionados na grid "Produtos"
    Local aRetorno   := {}
    Local nX         := 0
    Local nY         := 0
    Local nZ         := 0
    Local nI         := 0
    Local aPreco     := {}
    Local aMarca     := aClone(aPropostas)
    Local cNumCot    := SC8->C8_NUM
    Local cNumPro    := SC8->C8_NUMPRO
    Local cNUmGrid   := SC8->C8_ITEMGRD

    For nX := 1 To Len(aItens)
        aAdd(aPreco,{aItens[nX][1],999999999,999999999})
    Next nX

    SC8->(DbSetOrder(10)) //C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_PRODUTO+C8_ITEM+C8_NUMPRO+C8_ITEMGRD

    For nX := 1 To Len(aPropostas)
        For nY := 1 To Len(aPropostas[nX])
            For nZ := 1 To Len(aPropostas[nX][nY][2])
                //AADD(aPropostas[nX][nY][2][nZ], "TESTE "+Str(nCount,2))
                for nI := 1 to len(aPreco)
                    if aPropostas[nX][nY][2][nI][3] == aPreco[nI][1]
                        if aPropostas[nX][nY][2][nI][13] < aPreco[nI][3] .and. aPropostas[nX][nY][2][nI][13] != 0
                            aPreco[nI][3] := aPropostas[nX][nY][2][nI][13]
                        endif
                        
                        IF SB1->(DbSeek(FwXFilial("SB1")+aPropostas[nX][nY][2][nI][3]))
                            aPreco[nI][2] := SB1->B1_UPRC
                        ELSE
                            aPreco[nI][2] := 0
                        ENDIF

                    endif
                next nI
                //C8_FILIAL+C8_PRODUTO+C8_FORNECE+C8_LOJA
                IF Len(aPropostas[nX][nY][1]) > 0 .and. Len(aPropostas[nX][nY][2]) > 0
                    if SC8->(DbSeek(fWxFilial("SC8")+;
                                    cNumCot+;
                                    aPropostas[nX][nY][1][1]+;
                                    aPropostas[nX][nY][1][2]+;
                                    aPropostas[nX][nY][2][nZ][3]+;
                                    aPropostas[nX][nY][2][nZ][2]+;
                                    cNumPro+;
                                    cNUmGrid))

                        aAdd(aMarca[nX][nY][2][nZ],SC8->C8_XMARCA)
                    else
                        aAdd(aMarca[nX][nY][2][nZ],"")
                    endif
                else
                    aAdd(aMarca[nX][nY][2][nZ],"")
                endif
            Next nZ
        Next nY
    Next nX

    For nX := 1 To Len(aItens)
        AADD(aItens[nX], aPreco[nX][2])
        AADD(aItens[nX], aPreco[nX][3])
    Next nX

    aPropostas := {}
    aPropostas := aClone(aMarca)

    AADD(aRetorno, aPropostas )
    AADD(aRetorno, aCampos    )
    AADD(aRetorno, aItens     )
    AADD(aRetorno, aCposProd  )
    
Return aRetorno
