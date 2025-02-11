#include 'protheus.ch'
#include 'parmtype.ch'

user function mt097end()
local cDocto := ParamIXB[1]
local cTipo := ParamIXB[2]
local nOpc := ParamIXB[3]
local cFilDoc := ParamIXB[4]
local cCodLiber := ParamIXB[5]
local cObs := ParamIXB[6]

if cTipo == 'PC' .and. nOpc == 2
    DbSelectArea("SC7")
    DbSetOrder(1)
    if DbSeek(xFilial("SC7") + cDocto)
        u_envpv("SC7", nReg, 2, .f.)
    endif
endif
	
return