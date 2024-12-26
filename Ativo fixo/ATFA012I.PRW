#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/* Igor Oliveira 
   P.E da rotina ATFA012 - SIGAATF
*/

User Function ATFA012()
	Local aParam 		:= PARAMIXB
	Local xRet 			:= .T.
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local cIdIXB5		:= ''
	Local cIdIXB4		:= ''
	Local oModel 	 	:= nil
	Local oGrid 		:= nil
    Local nX, nI, nJ, nG
    Local cQry          := ''
    Local aArea 
    
    If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		if len(aParam) >= 4
			cIdIXB4  := aParam[4]
		endif 

		if len(aParam) >= 5
			cIdIXB5  := aParam[5]
		endif 

		If Alltrim(cIdPonto) == "MODELCOMMITNTTS"
			cIdPonto := aParam[2]
		ENDIF
	ENDIF
Return xRet
