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
ZAT_CODCOM (Obrigatório, Vínculo com tabela TQM) ou Conteúdo fixo 007 (ARLA)
ZAT_DESCOM (Virtual) - recebe o conteudo ARLA quando o ZAT_CODCOM for 007
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

Novos campos na Tabela STL
TL_NRABAS - Número do abastecimento
TL_VUNABA - Valor Unitário Abastecimento
TL_VTTABA - Valor Total Abastecimento
TL_TITABA - Título (Nro do Titulo na SA2 - Filial+Pref+Número+Parcela+Tipo)

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

	// Verificação Abastecimentos
	If M->ZAT_CODCOM <> "007"

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
					cMsg := "Será necessário reprocessar o seguinte período dos Abastecimentos: "+Dtoc(M->ZAT_DATCAD)+" até "+Dtoc(sTod(cDatVer))+", pois foi alterado o Valor do Litro do Código "+M->ZAT_CODCOM
					MsgInfo(cMsg,"Atenção")
					// TODO
					// Gerar email para informar da necessidade de reprocessamento
					// U_EnvMail(cMsg)
				Endif

			Endif

		Endif

	Endif

	// Verificação ARLA
	If M->ZAT_CODCOM == "007"

		If Select("TMPSTL") > 0
			TMPSTL->(dbCloseArea())
		EndIf

		cDatVer := If(!Empty(cDatPos),cDatPos,Dtos(dDataBase))

		cQuery := "SELECT STL.TL_TITABA, STL.R_E_C_N_O_ AS RECSTL "
		cQuery += "  FROM "+RetSqlName("STL")+" STL "
		cQuery += "	JOIN "+RetSqlName("STJ")+" STJ ON "
		cQuery += "	     TJ_FILIAL = '"+xFilial("STJ")+ "' "
		cQuery += "	 AND TJ_ORDEM= TL_ORDEM "
		cQuery += "	 AND TJ_PLANO = TL_PLANO "
		cQuery += "  JOIN "+RetSqlName('ST9')+" ST9 ON ( ST9.T9_FILIAL = '"+xFilial("ST9")+ "' "
		cQuery += " AND ST9.T9_CODBEM = TQN.TQN_FROTA AND ST9.T9_PROPRIE = '2' AND ST9.D_E_L_E_T_ = ' ' )"
		cQuery += " WHERE STL.TL_FILIAL='"+xFilial("STL")+"' "
		cQuery += " AND STJ.TJ_DTORIGI BETWEEN '"+Dtos(M->ZAT_DATCAD)+"' AND '"+cDatVer +"' AND STL.D_E_L_E_T_ = ' '"
		cQuery += " AND TL_CODIGO = '130011' "
		cQuery += " AND STJ.D_E_L_E_T_ = ' ' "
		cQuery += " AND STJ.TJ_SERVICO = 'C00014' "
		DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPSTL", .f., .f.)

		If  !TMPSTL->(EOF())

			If Empty(TMPSTL->TL_TITABA)

				cMsg := "Já existe cobrança no Financeiro com este preço do ARLA! É necessário estornar o título para então "+iIf(ALTERA,"alterar o preço","excluir o registro")+"!"
				MsgInfo(cMsg,"Atenção")
				lRet := .f.

			Else

				If !MsgYesNo("Já existe registro na tabela de Abastecimento (STL) utilizando este valor de referência!  Deseja Continuar!","Atenção")
					lRet := .f.
				Else
					cMsg := "Será necessário reprocessar o seguinte período de Lançamento do ARLA: "+Dtoc(M->ZAT_DATCAD)+" até "+Dtoc(sTod(cDatVer))+", pois foi alterado o Valor do Litro do Código "+M->ZAT_CODCOM
					MsgInfo(cMsg,"Atenção")
					// TODO
					// Gerar email para informar da necessidade de reprocessamento
					// U_EnvMail(cMsg)
				Endif

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


/*
SELECT TJ_CODBEM, TJ_DTORIGI,  TJ_TIPOOS, TL_FILIAL, TL_CODIGO, TL_QUANTID, TJ_CODBEM
    FROM STL010 STL
	JOIN STJ010 STJ ON
	     TJ_FILIAL = '01'
	 AND TJ_ORDEM= TL_ORDEM
	 AND TJ_PLANO = TL_PLANO
	-- AND TJ_CODBEM = TL_CODBEM
	 AND STL.D_E_L_E_T_ = ' ' 
	JOIN TZZ010 TZZ ON
	     TZZ_FILIAL = '01' 
	 AND TZZ_PRODUT = TL_CODIGO
	 JOIN ST9010 ST9 ON ( ST9.T9_FILIAL = '01' 
	 AND ST9.T9_CODBEM = STJ.TJ_CODBEM AND ST9.T9_PROPRIE = '2' AND ST9.D_E_L_E_T_ = ' ' )
   WHERE TL_FILIAL = '01'
     AND TL_CODIGO = '130011' -- PRODUTO
	 AND STJ.D_E_L_E_T_ = ' '
	 AND TJ_SERVICO = 'C00014' -- MESMO PREENCHIDO NA TELA DE ABASTECIMENTO EM PRODUTOS
     AND STJ.TJ_DTORIGI BETWEEN '20220101' AND '20220210' AND STL.D_E_L_E_T_ = ' '
	 ORDER BY STJ.R_E_C_N_O_ DESC
*/




