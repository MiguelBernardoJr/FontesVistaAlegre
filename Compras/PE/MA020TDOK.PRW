#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"

/* MJ : 12/07/2018
	- Ponto de Entrada para validações após a confirmação, antes da gravação do fornecedor.
		- Esta funcao estava no arquivo VALIB2, na pasta BIBLIOTECA;
 */


/*---------------------------------------------------------------------------------,
 | Func:  			                                                               |
 | Autor: Miguel Martins Bernardo Junior                                           |
 | Data:  12/07/2018                                                               |
 | Desc:  - Ponto de Entrada para validações após a confirmação, antes da gravação |
 |		 do fornecedor.                                                            |
 |		  - Esta funcao estava no arquivo VALIB2, na pasta BIBLIOTECA;             |
 | Alt.:  02.02.2021                                                               |
 |        - Atendendo solicitação do Rodrigo-Fiscal; Validação cadastro Funrural;  |
 | Obs.:  -                                                                        |
 '---------------------------------------------------------------------------------*/

User Function MA020TDOK()

Local lRet := .T.

	If M->A2_EST == 'SP' .OR. M->A2_EST == 'MG' // relatorio DIPAN
		If Empty( M->A2_X_PRUR )
			Alert('O Campo que define o tipo de produtor rural é obrigatório e não foi informado.')
			Return .F.
		EndIf
		If Empty( M->A2_CODMUN )
			Alert('O campo "Cod. Mun. ZF" é obrigatório e não foi informado.')
			Return .F.
		EndIf
	
		// MB : 02.02.2021 - Compra produtor rural SP - sol. Rodrigo fiscal
		if M->A2_X_PRUR  == "S"  .AND. ;
		   M->A2_TIPORUR == "F"  .AND. ;
		   M->A2_TPESSOA == "PF" .AND. ;
		   M->A2_CONTRIB == "1"  .AND. ;
		   M->A2_INDRUR  == "1"

		   If Empty( M->A2_CPFRUR )
				Alert('O campo "CPF Rural" é obrigatório e não foi informado.')
				Return .F.
		   EndIf
		EndIf

	EndIf
Return lRet

/*
	MB : 02.02.2021
	CAMPO: A2_CPFRUR 
		X3_WHEN
			Iif(FindFunction( "VldRur"), VldRur(), .F.)
		X3_VALID
			Iif(FindFunction( "VldRur"), VldRur(), .F.)                                                                                     
*/
User Function CPFRural()
Return (M->A2_TIPO $ "F") .AND. (M->A2_INDRUR $ "1,2,3") .AND. (M->A2_EST $ GetMV("MV_TAFESLB",,"SP|MG"))
