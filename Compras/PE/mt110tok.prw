#include 'protheus.ch'
#include 'parmtype.ch'

user function mt110tok()
local aArea := GetArea()
local lRet := .t.
local nLen := 0
local cMsg := ""
local i    := 0
local nPosItem := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'C1_ITEM'} )
local nPosProd := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'C1_PRODUTO'} )
local nPosCC := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'C1_CC'} )
local nPosIC := aScan(aHeader, {|aMat| AllTrim(aMat[2]) == 'C1_ITEMCTA'} )

SB1->(DbSetOrder(1))

nLen := Len(aCols) 
for i := 1 to nLen
    SB1->(DbSeek(xFilial("SB1")+aCols[i][nPosProd]))
    if SB1->B1_X_PRDES != '1' .and. Empty(aCols[i][nPosCC]) .and. Empty(aCols[i][nPosIC])
        cMsg += Iif(Empty(cMsg), "A(s) linha(s) abaixo precisa(m) de identificar o centro de custo ou item contabil para quem a solicitação foi feita." + CRLF, "") + aCols[i][nPosItem] + " - " + aCols[i][nPosProd] + CRLF
    elseif SB1->B1_X_PRDES == '1'
        aCols[i][nPosCC] := CriaVar("C1_CC", .f.)
        aCols[i][nPosIC] := CriaVar("C1_ITEMCTA", .f.)
    endif
next


if !Empty(cMsg)
    ShowHelpDlg("MT110TOK", {cMsg}, 1, {"Por favor, preencha o centro de custo ou item conttábil a que se destinam os itens solicitados."}, 1)
    lRet := .f.
endif

RestArea(aArea)
return lRet
