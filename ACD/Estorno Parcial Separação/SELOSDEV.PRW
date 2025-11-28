#include "totvs.ch"

/*/{Protheus.doc} SelOSDev
Rotina que usuário infoma a Ordem de Separação e preenche aCols
@type function
@version 1.0
@author nathan.quirino
@since 10/8/2025
@return variant, Retorna NIL caso o usuário cancele ou uma lista de colunas preenchidas.
/*/
User Function SelOSDev()
Local aArea     := GetArea()
Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local aParamBox := {}
local aRetParam := {}
Local cNumSep   := space(6)

    aAdd( aParamBox , { 1 , "Ordem de Separação:", cNumSep, "", 'ExistCpo("CB7",MV_PAR01)', "CB7", "", 50, .T.} )
	if paramBox( aParamBox, "Selecione Ordem de Separação", aRetParam)
		cNumSep := aRetParam[1]
    else
        Return nil
    endif

    oGet:oBrowse:nAt := 1
    N := 1
    aSize( aCols, 1 )
    aTail( aCols[1] ) := .F.

    CB7->(DbSetOrder(1))
    CB7->(DbSeek(xFilial("CB7")+cNumSep))

    SCP->(DbSetOrder(1))
    If SCP->(DbSeek(xFilial("SCP")+CB7->CB7_NUMSA)) .and. ! empty( SCP->CP_CC )
        cCC := SCP->CP_CC
        M->D3_CC := cCC
    EndIf

    cQuery := "SELECT R_E_C_N_O_ as RECCB8"
    cQuery += " FROM " + RetSqlName("CB8") + " CB8 "
    cQuery += " WHERE CB8_FILIAL = '" + xFilial("CB8") +"' "
    cQuery += "   AND CB8_ORDSEP = '"+ cNumSep +"' " 
    cQuery += "   AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY R_E_C_N_O_ "
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

    While !(cAlias)->(Eof())
        CB8->(DbGoTo((cAlias)->RECCB8))
        If N > Len(aCols)
            aADD(aCols, aClone(aCols[N - 1]))
        Endif
        aCols[ N, GDFieldPos("D3_COD") ]   := CB8->CB8_PROD
        M->D3_COD := CB8->CB8_PROD
        __readvar := "M->D3_COD"
        A240IniCpo()
		If ExistTrigger("D3_COD")
			RunTrigger(2,N,,"D3_COD")
		EndIf

        aCols[ N, GDFieldPos("D3_QUANT") ] := CB8->CB8_QTDORI
        M->D3_QUANT := CB8->CB8_QTDORI
        __readvar := "M->D3_QUANT"
        A240Quant()
		If ExistTrigger("D3_QUANT")
			RunTrigger(2,N,,"D3_QUANT")
		EndIf

        aCols[ N, GDFieldPos("D3_LOCAL") ] := CB8->CB8_LOCAL
        M->D3_LOCAL := CB8->CB8_LOCAL
        __readvar := "M->D3_LOCAL"
		If ExistTrigger("D3_LOCAL")
			RunTrigger(2,N,,"D3_LOCAL")
		EndIf

        N++
        (cAlias)->(DbSkip())
    EndDo
    N := 1
    oGet:oBrowse:nAt := N
    (cAlias)->(DbCloseArea())
    RestArea(aArea)

    oGet:oBrowse:Refresh()
    sysRefresh()
    processMessages()
Return NIL 
