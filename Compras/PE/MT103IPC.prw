#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"


/* 	MJ : 08.01.2019
		-> Preencher campo customizado da descricao do produto, apos importacao do produto
		
		PE encontrado no fonte padrao: LOCXNF2
*/
User Function MT103IPC()
	
	aCols[ len(aCols), 3 ] := Posicione('SB1', 1, xFilial('SB1')+aCols[ len(aCols), 2 ], 'B1_DESC')

return nil
