#include "Protheus.ch"
#include "TopConn.ch"

/*/{Protheus.doc} VAESTT03
Cadastro Básico para definir as regras referente a quebra de estoque.
@type function
@version 1  
@author Arthur Toshio
@since 20/09/2022
@return variant, return_description
/*/
User Function VAESTT03()

Local cAlias  := "ZCQ"
Local cTitulo := "Configuração - Quebra de Estoque"
Local cVldDel := ".F."
Local cVldAlt := ".T." 

	AxCadastro(cAlias,cTitulo,cVldDel,cVldAlt)
Return nil

