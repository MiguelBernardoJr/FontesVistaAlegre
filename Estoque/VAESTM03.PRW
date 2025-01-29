#Include "Protheus.ch"
#include "Totvs.ch"

// ###############################################################################################
// Projeto: 
// Fonte  : VAESTM03.prw
// ---------+------------------------------------+------------------------------------------------
// Data     | Autor                              | Descricao
// ---------+------------------------------------+------------------------------------------------
//  23/05/22|  Manoel Filho                      | Cadastro de Produtos x Centro de Custo
// ---------+------------------------------------+------------------------------------------------
User Function VAESTM03()
Private cCadastro  := "Cadastro de Produtos x Centro de Custo"
//
DbSelectArea("Z0L")
axCadastro("Z0L",cCadastro)

Return

