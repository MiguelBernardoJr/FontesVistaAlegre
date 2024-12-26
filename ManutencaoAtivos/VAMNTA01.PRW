#Include "Protheus.ch"
#include "Tbiconn.ch"
#include "TopConn.ch"
#include "Totvs.ch"

// ###############################################################################################
// Projeto: 
// Fonte  : VAMNTA01.prw
// ---------+------------------------------------+------------------------------------------------
// Data     | Autor                              | Descricao
// ---------+------------------------------------+------------------------------------------------
//  16/02/22|  Manoel Filho                      | Cadastro de Preços de Combustivel (tabela ZAT) 
// ---------+------------------------------------+------------------------------------------------
user function VAMNTA01()
/*
Tabela ZAT (compartilhada - chave única por ZAT_FILIAL+ZAT_CODCOM+dTos(ZAT_DATCAD))

criar log de Inclusão, alteração e exclusão no SIGACFG

ZAT_FILIAL
ZAT_CODCOM (Obrigatório, Vínculo com tabela TQM)
ZAT_DESCOM (Virtual)
ZAT_DATCAD (Obrigatório) 
ZAT_VALCOM (Obrigatório)
ZAT_CODUSR (Visualizar - inicializador padrão)
ZAT_NOMUSR (Visualizar - inicializador padrão)
ZAT_LOGREG - Log registro (Campo Memo com as inclusão e alterações do registro)
             I(ncluir) ou A(lterar) + Data + Valor + Usuário

Novos campos na Tabela TQN
TQN_NRABAS - Número do abastecimento
TQN_VUNABA - Valor Unitário Abastecimento
TQN_VTTABA - Valor Total Abastecimento
TQN_TITABA - Título (Nro do Titulo na SA2 - Filial+Pref+Número+Parcela+Tipo)


*/
Private cCadastro  := "Cadastro de Preços de Combustível"
Private aCpoAlt    := {}
// Campos a terem historico de Alteracoes //
aAdd(aCpoAlt,{"ZAT_CODCOM",})
aAdd(aCpoAlt,{"ZAT_VALORC",})
//
DbSelectArea("ZAT")
axCadastro("ZAT",cCadastro,"U_EXCVAM01()","U_TOKVAM01()")

Return .T.

/*/{Protheus.doc} 
    tratativas quando da exclusão
@type function
@param 
@author 
@since 16/02/2022
@return logical
/*/

User Function EXCVAM01()
local lRet := .t.

RegToMemory("ZAT")
If !FS_VALID(.t.)
	lRet := .f.
Endif

return lRet

/*/{Protheus.doc} 
    tratativas quando da confirmação do cadastro
@type function
@param 
@author 
@since 16/02/2022
@return logical
/*/

User Function TOKVAM01()
local lRet := .t.

If INCLUI .Or. ALTERA
	If !FS_VALID(.f.)
		lRet := .f.
	Endif
Endif

If lRet
	If INCLUI
		M->ZAT_LOGREG := "Inclusão    "+Dtoc(dDataBase)+" as "+time()+" - Usuário "+__cUserId+" - Valor " + Transform(M->ZAT_VALCOM,"@E 9999.999")+CRLF 
	Else
		M->ZAT_LOGREG := "Alteração  "+Dtoc(dDataBase)+" as "+time()+" - Usuário "+__cUserId+" - Valor " + Transform(M->ZAT_VALCOM,"@E 9999.999")+CRLF +ZAT->ZAT_LOGREG
	Endif
Endif

return lRet

/*/{Protheus.doc} 
    Função de Validação para Alteração ou Exclusão
@type function
@param lEXCLUI
@author 
@since 17/02/2022
@return logical
/*/

Static Function FS_VALID(lEXCLUI)
local lRet := .t.
local cQuery := ""
local cDatPos := "" // Data de Cadastro de Preço Posterior 
local cDatAnt := "" // Data de Cadastro de Preço Anterior
local cDatVer := ""

If INCLUI

	If Select("TMPZAT") > 0
		TMPZAT->(dbCloseArea())
	EndIf

	// Verificar se existe M->ZAT_CODCOM anterior
	cQuery := "SELECT ZAT_DATCAD "
	cQuery += " FROM "+RetSqlName("ZAT")+" ZAT "
	cQuery += " WHERE ZAT.ZAT_FILIAL='"+xFilial("ZAT")+"' AND ZAT.ZAT_CODCOM = '"+M->ZAT_CODCOM+"'"
	cQuery += " AND ZAT.ZAT_DATCAD = '"+Dtos(M->ZAT_DATCAD)+"' AND ZAT.D_E_L_E_T_ = ' '"
	DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPZAT", .f., .f.)

	If  !TMPZAT->(EOF())
		MsgInfo("Já existe registro nessa data! Impossivel continuar!","Atenção")
		lRet := .f.
	Endif
	TMPZAT->(dbCloseArea())

Endif

If lRet .and. !INCLUI

	If Select("TMPZAT") > 0
		TMPZAT->(dbCloseArea())
	EndIf

	// Verificar se existe M->ZAT_CODCOM anterior
	cQuery := "SELECT ZAT_DATCAD "
	cQuery += " FROM "+RetSqlName("ZAT")+" ZAT "
	cQuery += " WHERE ZAT.ZAT_FILIAL='"+xFilial("ZAT")+"' AND ZAT.ZAT_CODCOM = '"+M->ZAT_CODCOM+"'"
	cQuery += " AND ZAT.ZAT_DATCAD < '"+Dtos(M->ZAT_DATCAD)+"' AND ZAT.D_E_L_E_T_ = ' '"
	DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPZAT", .f., .f.)

	If  !TMPZAT->(EOF())
		cDatAnt := TMPZAT->ZAT_DATCAD
	Endif
	TMPZAT->(dbCloseArea())

	// Verificar se existe M->ZAT_CODCOM posterior
	cQuery := "SELECT ZAT_DATCAD "
	cQuery += " FROM "+RetSqlName("ZAT")+" ZAT "
	cQuery += " WHERE ZAT.ZAT_FILIAL='"+xFilial("ZAT")+"' AND ZAT.ZAT_CODCOM = '"+M->ZAT_CODCOM+"'"
	cQuery += " AND ZAT.ZAT_DATCAD > '"+Dtos(M->ZAT_DATCAD)+"' AND ZAT.D_E_L_E_T_ = ' '"
	DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPZAT", .f., .f.)

	If  !TMPZAT->(EOF())
		cDatPos := TMPZAT->ZAT_DATCAD
	Endif
	TMPZAT->(dbCloseArea())

	If Select("TMPTQN") > 0
		TMPTQN->(dbCloseArea())
	EndIf

	cDatVer := If(!Empty(cDatPos),cDatPos,Dtos(dDataBase))

	cQuery := "SELECT TQN.TQN_TITABA, TQN.R_E_C_N_O_ AS RECTQN "
	cQuery += "  FROM "+RetSqlName("TQN")+" TQN "
	cQuery += "  JOIN "+RetSqlName('ST9')+" ST9 ON ( ST9.T9_FILIAL = '"+xFilial("ST9")+ "' "
	cQuery += " AND ST9.T9_CODBEM = TQN.TQN_FROTA AND ST9.T9_PROPRIE = '2' AND ST9.D_E_L_E_T_ = ' ' )"
	cQuery += " WHERE TQN.TQN_FILIAL='"+xFilial("TQN")+"' AND TQN.TQN_CODCOM = '"+M->ZAT_CODCOM+"'"
	cQuery += " AND TQN.TQN_DTABAS BETWEEN '"+Dtos(M->ZAT_DATCAD)+"' AND '"+cDatVer +"' AND TQN.D_E_L_E_T_ = ' '"
	DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPTQN", .f., .f.)

	If  !TMPTQN->(EOF())

		If Empty(TMPTQN->TQN_TITABA)

			cMsg := "Já existe cobrança no Financeiro com este preço de Combustvel! É necessário estornar o título para então "+iIf(ALTERA,"alterar o preço","excluir o registro")+"!"
			MsgInfo(cMsg,"Atenção")
			lRet := .f.

		Else

			If !MsgYesNo("Já existe registro na tabela de Abastecimento (TQN) utilizando este valor de referência!  Deseja Continuar!","Atenção")
				lRet := .f.
			Else
				cMsg := "Será necessário reprocessar o seguinte período dos Abastecimentos: "+Dtoc(M->AT_DATCAD)+" até "+Dtoc(sTod(cDatVer))+", pois foi alterado o Valor do Litro do Código "+M->ZAT_CODCOM
				MsgInfo(cMsg,"Atenção")
				// TODO
				// Gerar email para informar da necessidade de reprocessamento
				// U_EnvMail(cMsg)
			Endif

		Endif

	Endif

/*
	If lEXCLUI 

		If !TMPTQN->(EOF()) //.and. Empty(cDatAnt) ´
	
			If !Empty(TMPTQN->TQN_TITABA)
				MsgInfo("Registro não pode ser excluído, pois os abastecimentos do periodo entre "+Dtoc(M->ZAT_DATCAD)+" e "+Dtoc(sTod(cDatVer))+" ficarão sem valor de referência!","Atenção")
			Else

			If !MsgYesNo("Já existe registro na tabela de Abastecimento (TQN) utilizando este valor de referência!  Deseja Continuar!","Atenção")
				lRet := .f.
			Else
				cMsg := "Será necessário reprocessar o seguinte período dos Abastecimentos: "+Dtoc(M->AT_DATCAD)+" até "+Dtoc(sTod(cDatVer))+", pois foi alterado o Valor do Litro do Código "+M->ZAT_CODCOM
			Endif

			Endif
	
			lRet := .f.
	
		Endif

	Else

		If ALTERA		

			If  !TMPTQN->(EOF())

				If Empty(TMPTQN->TQN_TITABA)

					If !MsgYesNo("Já existe registro na tabela de Abastecimento (TQN) utilizando este valor de referência!  Deseja Continuar!","Atenção")
						lRet := .f.
					Else
						cMsg := "Será necessário reprocessar o seguinte período dos Abastecimentos: "+Dtoc(M->AT_DATCAD)+" até "+Dtoc(sTod(cDatVer))+", pois foi alterado o Valor do Litro do Código "+M->ZAT_CODCOM
						MsgInfo(cMsg,"Atenção")
						// TODO
						// Gerar email para informar da necessidade de reprocessamento
						// U_EnvMail(cMsg)
					Endif
				Else

					cMsg := "Já existe cobrança no Financeiro com este preço de Combustvel! Estornar o título para então alterar o preço!","Atenção")
					MsgInfo(cMsg,"Atenção")
					lRet := .f.
	
				Endif
			Endif

		Endif
	Endif
*/

	TMPTQN->(dbCloseArea())

Endif

return lRet


//M->TQN_NRABAS-> (M->TQN_NRABAS := StrZero(Val(M->TQN_NRABAS),8)) .and U_VerAbast()                                                              
//M->QTC_QUANT ->  U_VlrAbast()           
