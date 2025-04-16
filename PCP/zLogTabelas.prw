//Bibliotecas
#Include "TOTVS.ch"
    
/*/{Protheus.doc} User Function zLogAlias
Função que percorre todos os alias em memória para gravar em log
@type  Function
@author Atilio
@since 02/06/2022
@param nTipo, Numérico, Se for 1 irá retornar um texto de log e se não for irá retornar um array
@obs Posições do array:
 [1] = Tabela (ex.: SB1)
 [2] = RecNo (ex.: 1342)
 [3] = Índice usado (ex.: 1)
 [4] = Campos que compõem o índice (ex.: B1_FILIAL + B1_COD)
 [5] = Chave do registro posicionado (ex.: '  000001')
/*/
    
User Function zLogAlias(nTipo)
    Local aArea      := FWGetArea()
    Local cAbertos   := cFOpened
    Local nAtual     := 0
    Local xLog       := Nil
    Local cAliasAtu  := ""
    Local nAliasRec  := 0
    Local nIndUsado  := 0
    Local cIndCampos := ""
    Local cIndChave  := ""
    Local nMaximo    := 511
    Default nTipo    := 1
    
    If nTipo == 1
        xLog := "Alias abertos (cFOpened): " + cAbertos + CRLF + CRLF
        xLog += "Alias encontrados na WorkArea: " + CRLF
    Else
        xLog := {}
    EndIf
    
    //Percorre 511 alias (conforme documentação em https://tdn.totvs.com/display/tec/Alias)
    For nAtual := 0 To nMaximo
        //Pega o alias da area atual
        cAliasAtu := Upper(Alias(nAtual))
    
        //Somente se houver alias e Garantia para prevenir se realmente ta aberto, para não confiar apenas na variável pública
        If ! Empty(cAliasAtu) .And. Select(cAliasAtu) > 0
            nIndUsado  := (cAliasAtu)->(IndexOrd())
            cIndCampos := StrTran((cAliasAtu)->(IndexKey(nIndUsado)), "+", " + ")
            cIndChave  := (cAliasAtu)->( &(cIndCampos) )
            nAliasRec  := (cAliasAtu)->(RecNo())
    
            //Pula o registro caso seja tabelas internas
            If Left(cAliasAtu, 3) == "MP_" .Or. ;
               Left(cAliasAtu, 6) == "MPUSR_" .Or. ;
               Left(cAliasAtu, 7) == "MPMENU_" .Or. ;
               Left(cAliasAtu, 6) == "MPGRP_" .Or. ;
               Left(cAliasAtu, 1) == "X" .Or. ;
               Left(cAliasAtu, 4) == "TPH_" .Or. ;
               Left(cAliasAtu, 9) == "PROFALIAS"
                Loop
            EndIf
    
            If nTipo == 1
                xLog += "Tabela: " + cAliasAtu + ;
                "; Recno: " + cValToChar(nAliasRec) + ;
                "; Ordem: " + cValToChar(nIndUsado) +;
                "; Índice: " + cIndCampos +;
                "; Chave: '" + cIndChave + "'" +;
                CRLF
            Else
                aAdd(xLog, {;
                    cAliasAtu,;
                    nAliasRec,;
                    nIndUsado,;
                    cIndCampos,;
                    cIndChave;
                })
            EndIf
        EndIf
    Next
    
    FWRestArea(aArea)
Return xLog
