#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User Function MA200CAB()

Local cProduto   := PARAMIXB[1]
Local nOpc       := PARAMIXB[2]
Local oObj       := PARAMIXB[3]
Local nLin1      := PARAMIXB[4]
Local nLin2      := PARAMIXB[5]
Local nColIni    := PARAMIXB[6]
Local nEnerg     := 0
Local lHasButton := .T.

If (nOpc != 1)
	nEnerg := SG1->G1_ENERG
EndIf

TSay():New(nLin1, nColIni + 050     , {|| "Energia:"}, oObj,,,,,,.T., CLR_BLACK, CLR_WHITE, 060, 20)
TGet():New(nLin1, nColIni + 110, { | u | If( PCount() == 0, nEnerg, nEnerg := u ), M->G1_ENERG := nEnerg },oObj, 060, 010, "@E 999,999.9999",, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nEnerg",,,,lHasButton  )

Return