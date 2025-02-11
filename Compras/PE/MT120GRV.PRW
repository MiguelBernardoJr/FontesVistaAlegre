#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "TOPCONN.CH"

User Function MT120GRV()
	
	Local lRet      := .T.
	Local cNum      := PARAMIXB[1]
    Local lInclui   := PARAMIXB[2]
    Local lAltera   := PARAMIXB[3]
    Local lExclui   := PARAMIXB[4]
    

    //IF PROCNAME( 1 ) != 'VACOMM12' .and. 
Return lRet

/* User Function MT120LOK()
    Local nPosPrd    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'})
    Local nPosItem   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEM'})
    Local lValido := .T.

    dbSelectArea('SC7')
    dbSetOrder(4)
    If MsSeek(xFilial('SC7')+aCols[n][nPosPrd]+cA120Num+aCols[n][nPosItem])     
        If (C7_QUJE > 0) .Or. (C7_RESIDUO == 'S') .Or. (C7_QTDACLA > 0)  
            lValido := .F.     
        EndIf
    EndIf 

Return(lValido)  */
