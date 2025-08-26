#include "protheus.ch"
#include "apvt100.ch"

/*/{Protheus.doc} vaacdv03
    Transferencia de Localização
    @type Function
    @author anre.cruz@jrscatolon.com.br
    @since 13/10/2020
    @version 1.0.1
/*/

user function vaacdv03()
private cProduto := ""
private cLocaliz := ""

DbSelectArea("SB1")
DbSetOrder(5) // B1_FILIAL+B1_CODBAR

DbSelectArea("SBE")
DbSetOrder(9) // BE_FILIAL+BE_LOCALIZ

    while .t.
        cProduto := CriaVar("B1_CODBAR", .f.)
        cLocaliz := CriaVar("B1_LOCALI", .f.)
        VTClear()
        @ 0,0 VTSAY "Transferencia de Localizacao" 
        @ 2,00 VTSAY "Cod. barras produto: " 
        @ 3,00 VTGet cProduto pict PesqPict("SB1", "B1_CODBAR") Valid VldACDV03(1) // F3 'SB1CBA'
        @ 4,00 VTSAY "Localizacao: " 
        @ 5,00 VTGet cLocaliz pict PesqPict("SB1", "B1_LOCALI") Valid VldACDV03(2) // F3 'SBEACD'
        VTRead()
        if VTLASTKEY()==27
            exit
        endIf
    end

return nil

static function VldACDV03(nValid)
local lRet := .t.

if nValid == 2 .and. Empty(cProduto)
    VTBeep(2)
    VTAlert("Selecione um produto primeiro.","Aviso",.t.,3000)
    VTKeyBoard(chr(20))
    lRet := .f.
else
    if VtLastkey() != 05
        if nValid == 1 .and. !SB1->(DbSeek(FWxFilial("SB1")+cProduto))
            VTBeep(2)
            VTAlert("Codigo do produto nao encontrado.","Aviso",.t.,3000)
            VTKeyBoard(chr(20))
            lRet := .f.
        elseif nValid == 2 .and. !SBE->(DbSeek(FWxFilial("SBE")+cLocaliz))
            VTBeep(2)
            VTAlert("Codigo da localizacao nao encontrada.","Aviso",.t.,3000)
            VTKeyBoard(chr(20))
            lRet := .f.
        endif
        if lRet .and. !Empty(cProduto) .and. !Empty(cLocaliz)
            RecLock("SB1", .f.)
                SB1->B1_LOCALI := cLocaliz
            MsUnlock()
            VTBeep(2)
            VTAlert("Localizacao Atualizada.","Sucesso",.t.,3000)
            VTKeyBoard(chr(20))
        endif
    endif
endif
return lRet
