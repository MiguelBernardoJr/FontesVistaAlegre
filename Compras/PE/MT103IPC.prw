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

/*
User Function MT140LOK()  
Local lRet         := .T.
// Local nOpcao    := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina  // 3- incluir  2-visualizar 5-excluir
// Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO.....
// Local aArea     := GetArea()
// Local aAreaD1   := SD1->(GetArea())

Alert('MT140LOK')

// RestArea(aAreaD1)
// RestArea(aArea)
Return lRet


User Function SF1140I()

	Alert('SF1140I')

return nil


User Function A140IPRD()

	Alert('A140IPRD')

return nil


User Function A140ALT()

	Alert('A140ALT')

return nil


User Function MT103CPC()

	Alert('MT103CPC')

return nil


User Function MT103INF()

	Alert('MT103INF')

return nil
*/
