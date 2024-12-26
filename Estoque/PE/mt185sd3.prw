#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} mt185sd3
//TODO Descrição auto-gerada.
@author Renato de Bianchi
@since 25/10/2017
@type function
@return Logico, Sempre retorna .t.
/*/
user function mt185sd3()
	//u_VaEstR07(.F.)
	if Type("M->D3_FORNECE") != "U"
		M->D3_FORNECE	:= SCP->CP_FORNECE
		M->D3_LOJA		:= SCP->CP_LOJA
		M->D3_NOMEFOR	:= SCP->CP_NOMEFOR
	else
		M->D3_CODFOR	:= SCP->CP_FORNECE
		M->D3_LOJAFOR	:= SCP->CP_LOJA
	endIf
	M->D3_CODCA	:= SCP->CP_CODCA
	M->D3_MATRI	:= SCP->CP_MATRI
	M->D3_NOME	:= SCP->CP_NOME	
return .t.