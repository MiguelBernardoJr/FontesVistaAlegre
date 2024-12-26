#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} u_ma150but
Ponto de entrada que adiciona botões à interface da rotina mata150, permitindo 

/*/

user function ma150but()
local aButtons := {} 
	aadd(aButtons,{"AVGARMAZEM" ,{|| u_ShowForn() }, "Dados Fornecedor", "Fornecedor"})
return aButtons

User Function ShowForn()

DbSelectArea("SA2")
DbSetOrder(1)

AxVisual("SA2", SA2->(RecNo()), 2)

return nil