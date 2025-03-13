#include 'protheus.ch'
#include 'parmtype.ch'

user function ValEstTes()
	local lret:=	.T.
	
	IF SB1->B1_X_PRDES=='E'
		IF SF4->F4_ESTOQUE=='N'
			//lret:= .F.
			Alert('Verificar divergencia entre a TES e Cadastro de Produto. Este Produto está definido como ESTOCAVEL e a TES está definida para DESPESA.')
		EndIf
    EndIf
return lret
