#include "totvs.ch"

/*/{Protheus.doc} MT241SD3
	P.E. final da gravação dos movimentos internos - Devolução
	@type function
	@author Cristiam Rossi
	@since 25/09/2025
/*/
user function MT241SD3
local aArea     := getArea()
local cTMdev    := superGetMV("FS_MOTDEV",,"010")
local cMotivo   := ""
local aParamBox := {}
local aRetParam := {}

	if ! isBlind()
		SD3->(DbSetOrder(2))
		SD3->(DbSeek(xFilial("SD3")+cDocumento))
		if SD3->D3_TM $ cTMdev
			aAdd( aParamBox , { 1 , "Motivo:", space(6), "", 'ExistCpo("SX5","E-"+MV_PAR01)', "E-", "", 50, .T.} )
			if paramBox( aParamBox, "Selecione Motivo - Devolução", aRetParam)
				cMotivo := aRetParam[1]

				while ! SD3->( eof() ) .and. SD3->D3_FILIAL == xFilial("SD3") .and. SD3->D3_DOC == cDocumento
					recLock("SD3", .F.)
					SD3->D3_XMOTIV := cMotivo
					msUnlock()
					SD3->( dbSkip() )
				endDo
			endif
		endif
	endif

	restArea( aArea )
return nil
