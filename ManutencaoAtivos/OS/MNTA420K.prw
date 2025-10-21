#include "totvs.ch"

/* 
    Igor Oliveira - 20/10/2025
    Validação da quantidade / produto 

*/
User Function MNTA420K()
 
    Local aCols    := aClone(ParamIXB[1])
    Local nPos     := ParamIXB[2]
    Local aHeader  := aClone(ParamIXB[3])
    Local lRet     := .T.
    Local nPosAlmx := aScan( aHeader, { |x| Trim( Upper( x[2] ) ) == 'TL_LOCAL'   } )
    Local nPosProd := aScan( aHeader, { |x| Trim( Upper( x[2] ) ) == 'TL_CODIGO'  } )
    Local nPosTpRg := aScan( aHeader, { |x| Trim( Upper( x[2] ) ) == 'TL_TIPOREG' } )
    Local nPosQtd  := aScan( aHeader, { |x| Trim( Upper( x[2] ) ) == 'TL_QUANTID' } )
    Local nPosNSa  := aScan( aHeader, { |x| Trim( Upper( x[2] ) ) == 'TL_NUMSA' } )
    Local nPosISa  := aScan( aHeader, { |x| Trim( Upper( x[2] ) ) == 'TL_ITEMSA' } )

    If nPosAlmx > 0 .And. nPosProd > 0 .And. nPosTpRg > 0 .And. nPos > 0 .AND. nPosNSa > 0
 
        If aCols[nPos,nPosTpRg] == 'P' .and. !Empty(aCols[nPos,nPosNSa])

            cQry := "SELECT * FROM "+RetSqlName("CB8")+" WHERE CB8_NUMSA = '"+aCols[nPos,nPosNSa]+"' AND CB8_ITEM = '"+aCols[nPos,nPosISa]+"' AND D_E_L_E_T_ = '' "

            cAlias := MpSysOpenQuery(cQry)

            If !(cAlias)->(EOF()) ;
                .and. (Rtrim((cAlias)->CB8_PROD) != Rtrim(aCols[nPos,nPosProd]) ;
                .or. (cAlias)->CB8_QTDORI != aCols[nPos,nPosQtd])
 
                lRet := .F.
                FwAlertInfo( 'O Produto e Quantidade da linha ['+StrZero(nPos,2)+'] não pode ser alterada pois já possui Ordem de Separação vinculada a Solicitação ao armazém. ' + CRLF + ;
                             'Para prossguir, estorne a ordem de separação ['+(cAlias)->CB8_ORDSEP+'] e tente novamente.',;
                             'Atenção!' )
 
            EndIf

            (cALias)->(DbCloseArea( ))
 
        EndIf
 
    EndIf
 
Return lRet
