#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOTVS.CH"   
#INCLUDE "PROTHEUS.CH"

/*--------------------------------------------------------------------------------,
 | Autor:  Miguel Martins Bernardo Junior                                         |
 | Data:   21.07.2017                                                             |
 | Client: V@                                                                     |
 | Desc:   Esta rotina é responsavel por realizar o CADASTRO na tabela ZCI,       |
 |         cadastro de indices;                                                   |
 |         Desenvolvido com funcao AXCADASTRO: Modelo1                            |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VACOMM05()

// Local aRotAdic := {} 
// Local bPre     := {||MsgAlert('Chamada antes da função')     }
// Local bOK      := {||MsgAlert('Chamada ao clicar em OK'), .T.}
// Local bTTS     := {||MsgAlert('Chamada durante transacao')   }
// Local bNoTTS   := {||MsgAlert('Chamada após transacao')      }    
// Local aButtons := {}     // Adiciona botões na tela de inclusão, alteração, visualização e exclusao

// aadd(aButtons,{ "NoRegistro", {|| MsgAlert("NoRegistro")}, "NoRegistro", "Botão noRegistro" }  )    // Adiciona chamada no aRotina
// aadd(aRotAdic,{ "Tela Principal","U_Adic", 0 , 6 })

dbSelectArea("ZCI")
dbSetOrder(1)

AxCadastro("ZCI","Cadastro de Indices", ;
				 "U_ValM5Del()", ;
				 "U_ValM5OK()", ;
				 /* aRotAdic */, ;
				 /* bPre */, /* bOK */, /* bTTS */, /* bNoTTS */, , , ;
				 /* aButtons */, , )

Return(.T.)                        

User Function ValM5Del() 	
// MsgAlert("Chamada antes do delete") 
Return .T.

User Function ValM5OK() 	
// MsgAlert("Clicou botao OK") 
Return .T.

// User Function Adic() 	
// MsgAlert("Botao na tela principal") 
// Return nil


/* DOCUMENTACAO

Tabela:			ZCI
Descricao:		Cadastro de indices
Ac. Filial:		Compartilhado
Ac. Unidade:	Compartilhado
Ac. Empresa:	Compartilhado
X2_UNICO:		ZCI_FILIAL+ZCI_INDICE
------------------------------------------------

Campo: 			ZCI_CODIGO
Tipo:			Caracter
Tamanho:		6
Decimal:		0	
Contexto:		Real
Propriedade:	Visualizar
Titulo:			Codigo
Descricao:		Codigo do Indice     
Inic. Padrao:	GETSX8NUM('ZCI','ZCI_CODIGO')  
Uso:			Usado, Browse  
------------------------------------------------

Campo: 			ZCI_INDICE
Tipo:			Caracter
Tamanho:		30
Decimal:		0	
Contexto:		Real
Propriedade:	Alterar
Titulo:			Indice
Descricao:		Nome do Indice
Uso:			Usado, Browse  
Help:			Informa o índice; Ex: ESALQ, Balcão, 
				Marquinhos, Soja, Milho.
------------------------------------------------

Campo: 			ZCI_COTGAD
Tipo:			Caracter
Tamanho:		1
Decimal:		0	
Contexto:		Real
Propriedade:	Alterar
Titulo:			Cot. Gado   
Descricao:		Eh Cot. Gado   
Lista Opcoes:	S=Sim;N=Nao
Uso:			Usado, Browse  
Help:			Define Sim ou Não, se o índice tem 
				referência à cotação de gado;
------------------------------------------------

===================> Indice <===================
1)
Chave:			ZCI_FILIAL+ZCI_CODIGO
Descricao:		Codigo
Mostra Pesq.	Sim

------------------------------------------------

2)
Chave:			ZCI_FILIAL+ZCI_INDICE
Descricao:		Indice
Mostra Pesq.	Sim
------------------------------------------------

==============> Consulta Padrao <==============
Consulta:		ZCI
Descricao:		Cadastro de Indices
Procurar por:	ZCI
Habilitar Incl:	Sim
Indice:			1
Colunas:		ZCI_CODIGO+ZCI_INDICE+ZCI_COTGAD
Indice:			2
Colunas:		ZCI_INDICE+ZCI_CODIGO+ZCI_COTGAD
Retorno:		ZCI->ZCI_CODIGO
------------------------------------------------

/*