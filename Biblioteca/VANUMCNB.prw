#include "totvs.ch"

User Function VaNumCnb(lAtu)
Local cRet := ""
Default lAtu := .T.
	
	if empty(SRA->RA_XIDCNAB) .or. lAtu
		cRet := GETSXENUM("SRA","RA_XIDCNAB")
		ConfirmSX8()
		
		RecLock("SRA")
		SRA->RA_XIDCNAB := cRet
		MsUnlock()
	else
		cRet := SRA->RA_XIDCNAB
	endIf
	
return cRet