#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc}Mt110Grv
    ponto de entrada executado no laco de grava��o dos itens da SC na
    fun��o A110GRAVA, ap�s gravar o item da SC, a cada item gravado
    da SC.
    Usado para gravar o campo C1_XAPROV, replicado com o conte�do do campo
    C1_APROV.

@since 20170328
@author JRScatolon
@return Nil, Nenhum valor.
/*/
user function Mt110Grv()

    if Inclui .or. lCopia
        RecLock("SC1", .f.)
        SC1->C1_XAPROV  := Replicate(SC1->C1_APROV, TamSX3("C1_XAPROV")[1])
        // SC1->C1_GRUPCOM := ""
        // SC1->C1_CODCOMP := ""
        MsunLock()
    endif

return nil

/* MB : 07.01.2025
comentei a funcao abaixo nesta data pois encontrei o fonte MT131WF criado. */
/* MB : 21.03.2023 */
// User Fuanction MT131WF()
// Local aArea     := GetArea()
// Local _cCODCOMP := Posicione("SY1", 3, xFilial("SY1") + RetCodUsr(), "Y1_COD")
// Local _cGRUPCOM := SY1->Y1_GRUPCOM

//     // C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT
//     // Num. Cotacao + Produto + Identif.
//     SC1->(DbSetOrder(5))
//     If SC1->(DbSeek( xFilial('SC1') + cCotNum ))
//         While SC1->C1_FILIAL + SC1->C1_COTACAO == xFilial('SC1') + cCotNum
//             RecLock("SC1", .f.)
//                 SC1->C1_CODCOMP := _cCODCOMP
//                 SC1->C1_GRUPCOM := _cGRUPCOM
//             SC1->(MsunLock())

//             SC1->(DbSkip())
//         EndDo
//     EndIf

//     SC8->(DbSetOrder(1))
//     If SC8->(DbSeek( xFilial('SC8') + cCotNum ))
//         While SC8->C8_FILIAL + SC8->C8_NUM == xFilial('SC8') + cCotNum

//             RecLock("SC8", .f.)
//                 SC8->C8_GRUPCOM := _cGRUPCOM
//             SC8->(MsunLock())

//             SC8->(DbSkip())
//         EndDo
//     EndIf

// RestArea(aArea)
// Return nil

/* Atualizar Cotacao */
User Function MT150FIL()
    Local cFiltro := ""

    If MV_PAR03 == 1
        cFiltro := U_mbMTFIL()
    EndIf

Return cFiltro


/* Analisar Cotacao */
User Function MT161FIL()
    // Local cFiltro := ""
    // If MV_PAR03 == 1 // os parametros nesta rotina sao diferentes do PE MT150FIL
Return U_mbMTFIL()


User Function mbMTFIL()

    Local cCODCOMP := POSICIONE('SY1', 3, xFilial('SY1')+RetCodUsr(), 'Y1_COD' )

    // Local cFiltro := " C8_CODCOMP=='" + cCODCOMP + "' .AND. C8_VALIDA >= '" + dToS(MsDate()) + "'"
    Local cFiltro := " C8_CODCOMP=='" + cCODCOMP + "'"

Return cFiltro

/* MB : 07.01.2024
    -> funcao comentada pois nao estava trazendo todas as cotacoes */
// User Function mbMTFIL()
//     Local aArea   := GetArea()
//     Local cFiltro := ""
//     Local cQry    := ""
// 
//     Local nQtdCot := 0
// 
//     // cFiltro := " C8_NUM IN (  " + CRLF +;
//     //            " 				SELECT  DISTINCT C1_COTACAO " + CRLF +;
//     //            " 				FROM	" + RetSQLName("SC1") + CRLF +;
//     //            " 				WHERE	C1_CODCOMP IN ( " + CRLF +;
//     //            " 					SELECT  Y1_COD " + CRLF +;
//     //            " 					FROM	" + RetSQLName("SY1") + CRLF +;
//     //            " 					WHERE	Y1_USER = '" + RetCodUsr() + "' AND D_E_L_E_T_=' ' " + CRLF +;
//     //            " 				) OR C1_CODCOMP=' ' AND D_E_L_E_T_ = ' ' " + CRLF +;
//     //            " 		) "
// 
//     mpSysOpenQuery( changeQuery(;
//         cQry := "	SELECT  DISTINCT C1_COTACAO " + CRLF +;
//         "	FROM	" + RetSQLName("SC1") + CRLF +;
//         "	WHERE	C1_CODCOMP IN ( " + CRLF +;
//         "		SELECT  Y1_COD" + CRLF +;
//         "		FROM	" + RetSQLName("SY1") + CRLF +;
//         "		WHERE	Y1_USER = '" + RetCodUsr() + "' AND D_E_L_E_T_=' '" + CRLF +;
//         "	) " + CRLF +;
//         "	AND C1_RESIDUO = ' ' " + CRLF +;
//         "	AND C1_QUJE < C1_QUANT" + CRLF +;
//         "	AND D_E_L_E_T_ = ' ' " + CRLF +;
//         "	ORDER BY 1 DESC ";
//         ), '_TMP' )
// 
//     While !_TMP->(Eof()) // .AND. LEN(cFiltro) < 500
// 
//         ++nQtdCot
//         If At( _TMP->C1_COTACAO, cFiltro) == 0
//             cFiltro += if(Empty(cFiltro),"", ".OR.") + "C8_NUM=='" + _TMP->C1_COTACAO + "'"
//         EndIf
// 
//         _TMP->(DbSkip())
//     EndDo
// 
//     cFiltro := "( " + cFiltro + " ) .AND. C8_VALIDA >= '" + dToS(MsDate()) + "'"
// 
//     RestArea(aArea)
// 
// Return cFiltro
