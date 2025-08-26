#INCLUDE "Protheus.ch"
#Include "TOTVS.ch"

/*/
    Programa: MT103EXC.PRW
    Autor: Rodrigo Franco
    Data: 07/07/2025
    Descrição: Implementação do ponto de entrada MT103EXC para impedir
               a exclusão de NF com campo XEXCLUIR igual a 'N'
*/

User Function MT103EXC()
	Local cChave 	:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
	Local lContinua := .T. // Valor padrão: permite exclusão

	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))
	
	

Return lContinua
