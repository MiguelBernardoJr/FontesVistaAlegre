#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/* MJ : 12/07/2018
	- Ponto de Entrada para valida��es ap�s a confirma��o, antes da grava��o do fornecedor.
		- Esta funcao estava no arquivo VALIB2, na pasta BIBLIOTECA;
*/


/*---------------------------------------------------------------------------------,
 | Func:  			                                                               |
 | Autor: Miguel Martins Bernardo Junior                                           |
 | Data:  12/07/2018                                                               |
 | Desc:  - Ponto de Entrada para valida��es ap�s a confirma��o, antes da grava��o |
 |		 do fornecedor.                                                            |
 |		  - Esta funcao estava no arquivo VALIB2, na pasta BIBLIOTECA;             |
 | Alt.:  02.02.2021                                                               |
 |        - Atendendo solicita��o do Rodrigo-Fiscal; Valida��o cadastro Funrural;  |
 | Obs.:  -                                                                        |
'---------------------------------------------------------------------------------*/

User Function MA020TDOK()

	Local lRet := .T.

	Local cAlias := GetNextAlias()
	Local cQry   := ""

	If INCLUI
		cQry   := ""+;
			" SELECT      " + CRLF +;
			"             *  " + CRLF +;
			" FROM        " + RetSQLName('SA2') + CRLF +;
			" WHERE        " + CRLF +;
			"             A2_CGC = '" + M->A2_CGC + "' AND " + CRLF +;
			"             D_E_L_E_T_ = ' ' "
		MpSysOpenQry(cQry, cAlias)

		//If !(cAlias)->(EOF())
		//	MsgInfo("Fornecedor localizado com o codigo: " + AllTrim((cAlias)->A2_COD) + " - " + AllTrim((cAlias)->A2_NOME) + ". Cadastro repetido n�o � permitido. Esta opera��o ser� cancelada.")
		//	lRet   := .F.
		//EndIf
		(cAlias)->(DbCloseArea())
	EndIf

	If lRet
		If FWSM0Util():GetSM0Data(, cFIlAnt, {'M0_CODIGO'})[1][2] == "01"
			If M->A2_EST == 'SP' .OR. M->A2_EST == 'MG' // relatorio DIPAN
				If Empty( M->A2_X_PRUR )
					Alert('O Campo que define o tipo de produtor rural � obrigat�rio e n�o foi informado.')
					Return .F.
				EndIf
				If Empty( M->A2_CODMUN )
					Alert('O campo "Cod. Mun. ZF" � obrigat�rio e n�o foi informado.')
					Return .F.
				EndIf

				// MB : 02.02.2021 - Compra produtor rural SP - sol. Rodrigo fiscal
				if M->A2_X_PRUR  == "S"  .AND. ;
						M->A2_TIPORUR == "F"  .AND. ;
						M->A2_TPESSOA == "PF" .AND. ;
						M->A2_CONTRIB == "1"  .AND. ;
						M->A2_INDRUR  == "1"

					If Empty( M->A2_CPFRUR )
						Alert('O campo "CPF Rural" � obrigat�rio e n�o foi informado.')
						Return .F.
					EndIf
				EndIf

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
