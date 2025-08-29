#include 'protheus.ch'
#include 'parmtype.ch'

user function mt110tok()
local aArea     := GetArea()
local lRet      := .t.
local nLen      := 0
local cMsg      := ""
local i         := 0
//Apenas o grupo Almoxarifado e Fabrica tem permissão para incluir produtos com B1_X_PRDES = 'E'
Local aGrpPer   := "000002|000032"
Local aGrupos   := {}
Local nI        := 0
local cTipoMsg  := "D"
local nPosItem  := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'C1_ITEM'} )
local nPosProd  := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'C1_PRODUTO'} )
local nPosCC    := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'C1_CC'} )
local nPosIC    := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'C1_ITEMCTA'} )
local nPosOP    := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'C1_OP'} )
local nPosOS    := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'C1_OS'} )
local nPosAP    := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'C1_XAPLICA'} )

SB1->(DbSetOrder(1))

DBSelectArea("CT1")
DbSetOrder(1)

nLen := Len(aCols)
for i := 1 to nLen
    if aCols[i][nPosAP] == 'D' .and. Empty(aCols[i][nPosCC])
        cMsg += Iif(Empty(cMsg), "A(s) linha(s) abaixo precisa(m) de identificar o centro de custo para quem a solicitação foi feita." + CRLF, "") + aCols[i][nPosItem] + " - " + aCols[i][nPosProd] + CRLF
    elseif aCols[i][nPosAP] == 'D'
        SB1->(DBSeek(FwxFilial("SB1")+aCols[i][nPosProd]))

        IF CT1->(DBSeek(FWxFilial("CT1")+SB1->B1_X_DEBIT)) .and. CT1->CT1_ITOBRG == '1'
            IF Empty(aCols[i][nPosIC])
                cMsg += Iif(Empty(cMsg), "A(s) linha(s) abaixo precisa(m) de identificar o item contabil para quem a solicitação foi feita." + CRLF, "") + aCols[i][nPosItem] + " - " + aCols[i][nPosProd] + CRLF
            elseif Empty(aCols[i][nPosOP])
                cMsg += Iif(Empty(cMsg), "A(s) linha(s) abaixo precisa(m) de identificar a Ordem de Producao." + CRLF, "") + aCols[i][nPosItem] + " - " + aCols[i][nPosProd] + CRLF
            elseif Empty(aCols[i][nPosOS])
                cMsg += Iif(Empty(cMsg), "A(s) linha(s) abaixo precisa(m) de identificar o Número da Ordem de serviço." + CRLF, "") + aCols[i][nPosItem] + " - " + aCols[i][nPosProd] + CRLF
            endif
        endif
    elseif aCols[i][nPosAP] == 'E'
        aGrupos := FWSFUsrGrps(__cUserID)

        lRet := .F.
        For nI := 1 to Len(aGrupos)
            if aGrupos[nI] $ aGrpPer
                lRet := .T.
                exit
            endif
        Next nI

        if !lRet
            cTipoMsg := "E"
            cMsg += Iif(Empty(cMsg), "A(s) linha(s) não podem ser destinadas a estoque." + CRLF, "") + aCols[i][nPosItem] + " - " + aCols[i][nPosProd] + CRLF
        endif

        aCols[i][nPosCC] := CriaVar("C1_CC", .f.)
        aCols[i][nPosIC] := CriaVar("C1_ITEMCTA", .f.)
    endif
next

if !Empty(cMsg)
    if cTipoMsg == "D"
        ShowHelpDlg("MT110TOK", {cMsg}, 1, {"Por favor, preencha o centro de custo ou item contábil a que se destinam os itens solicitados."}, 1)
    else
        ShowHelpDlg("MT110TOK", {cMsg}, 1, {"Por favor, altere o campo Tp. Aplicação para D-Direto. Produtos destinados a ESTOQUE podem ser solicitados apenas por usuários do Almoxarifado e Fábrica."}, 1)
    endif
    lRet := .f.
endif

RestArea(aArea)
return lRet
