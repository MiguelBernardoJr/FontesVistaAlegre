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
//  16/02/22|  Manoel Filho                      | Cadastro de Pre�os de Combustivel (tabela ZAT) 
// ---------+------------------------------------+------------------------------------------------
user function VAMNTA01()
/*
Tabela ZAT (compartilhada - chave �nica por ZAT_FILIAL+ZAT_CODCOM+dTos(ZAT_DATCAD))

criar log de Inclus�o, altera��o e exclus�o no SIGACFG

ZAT_FILIAL
ZAT_CODCOM (Obrigat�rio, V�nculo com tabela TQM) ou Conte�do fixo 007 (ARLA)
ZAT_DESCOM (Virtual) - recebe o conteudo ARLA quando o ZAT_CODCOM for 007
ZAT_DATCAD (Obrigat�rio) 
ZAT_VALCOM (Obrigat�rio)
ZAT_CODUSR (Visualizar - inicializador padr�o)
ZAT_NOMUSR (Visualizar - inicializador padr�o)
ZAT_LOGREG - Log registro (Campo Memo com as inclus�o e altera��es do registro)
             I(ncluir) ou A(lterar) + Data + Valor + Usu�rio

Novos campos na Tabela TQN
TQN_NRABAS - N�mero do abastecimento
TQN_VUNABA - Valor Unit�rio Abastecimento
TQN_VTTABA - Valor Total Abastecimento
TQN_TITABA - T�tulo (Nro do Titulo na SA2 - Filial+Pref+N�mero+Parcela+Tipo)

Novos campos na Tabela STL
TL_NRABAS - N�mero do abastecimento
TL_VUNABA - Valor Unit�rio Abastecimento
TL_VTTABA - Valor Total Abastecimento
TL_TITABA - T�tulo (Nro do Titulo na SA2 - Filial+Pref+N�mero+Parcela+Tipo)

*/
Private cCadastro  := "Cadastro de Pre�os de Combust�vel"
Private aCpoAlt    := {}
// Campos a terem historico de Alteracoes //
aAdd(aCpoAlt,{"ZAT_CODCOM",})
aAdd(aCpoAlt,{"ZAT_VALORC",})
//
DbSelectArea("ZAT")
axCadastro("ZAT",cCadastro,"U_EXCVAM01()","U_TOKVAM01()")

Return .T.

/*/{Protheus.doc} 
    tratativas quando da exclus�o
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
    tratativas quando da confirma��o do cadastro
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
		M->ZAT_LOGREG := "Inclus�o    "+Dtoc(dDataBase)+" as "+time()+" - Usu�rio "+__cUserId+" - Valor " + Transform(M->ZAT_VALCOM,"@E 9999.999")+CRLF 
	Else
		M->ZAT_LOGREG := "Altera��o  "+Dtoc(dDataBase)+" as "+time()+" - Usu�rio "+__cUserId+" - Valor " + Transform(M->ZAT_VALCOM,"@E 9999.999")+CRLF +ZAT->ZAT_LOGREG
	Endif
Endif

return lRet

/*/{Protheus.doc} 
    Fun��o de Valida��o para Altera��o ou Exclus�o
@type function
@param lEXCLUI
@author 
@since 17/02/2022
@return logical
/*/

Static Function FS_VALID(lEXCLUI)
local lRet := .t.
local cQuery := ""
local cDatPos := "" // Data de Cadastro de Pre�o Posterior 
local cDatAnt := "" // Data de Cadastro de Pre�o Anterior
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
		MsgInfo("J� existe registro nessa data! Impossivel continuar!","Aten��o")
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

	// Verifica��o Abastecimentos
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

				cMsg := "J� existe cobran�a no Financeiro com este pre�o de Combustvel! � necess�rio estornar o t�tulo para ent�o "+iIf(ALTERA,"alterar o pre�o","excluir o registro")+"!"
				MsgInfo(cMsg,"Aten��o")
				lRet := .f.

			Else

				If !MsgYesNo("J� existe registro na tabela de Abastecimento (TQN) utilizando este valor de refer�ncia!  Deseja Continuar!","Aten��o")
					lRet := .f.
				Else
					cMsg := "Ser� necess�rio reprocessar o seguinte per�odo dos Abastecimentos: "+Dtoc(M->ZAT_DATCAD)+" at� "+Dtoc(sTod(cDatVer))+", pois foi alterado o Valor do Litro do C�digo "+M->ZAT_CODCOM
					MsgInfo(cMsg,"Aten��o")
					// TODO
					// Gerar email para informar da necessidade de reprocessamento
					// U_EnvMail(cMsg)
				Endif

			Endif

		Endif

	Endif

	// Verifica��o ARLA
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

				cMsg := "J� existe cobran�a no Financeiro com este pre�o do ARLA! � necess�rio estornar o t�tulo para ent�o "+iIf(ALTERA,"alterar o pre�o","excluir o registro")+"!"
				MsgInfo(cMsg,"Aten��o")
				lRet := .f.

			Else

				If !MsgYesNo("J� existe registro na tabela de Abastecimento (STL) utilizando este valor de refer�ncia!  Deseja Continuar!","Aten��o")
					lRet := .f.
				Else
					cMsg := "Ser� necess�rio reprocessar o seguinte per�odo de Lan�amento do ARLA: "+Dtoc(M->ZAT_DATCAD)+" at� "+Dtoc(sTod(cDatVer))+", pois foi alterado o Valor do Litro do C�digo "+M->ZAT_CODCOM
					MsgInfo(cMsg,"Aten��o")
					// TODO
					// Gerar email para informar da necessidade de reprocessamento
					// U_EnvMail(cMsg)
				Endif

			Endif

		Endif
	
	Endif

/*
	If lEXCLUI 

		If !TMPTQN->(EOF()) //.and. Empty(cDatAnt) �
	
			If !Empty(TMPTQN->TQN_TITABA)
				MsgInfo("Registro n�o pode ser exclu�do, pois os abastecimentos do periodo entre "+Dtoc(M->ZAT_DATCAD)+" e "+Dtoc(sTod(cDatVer))+" ficar�o sem valor de refer�ncia!","Aten��o")
			Else

			If !MsgYesNo("J� existe registro na tabela de Abastecimento (TQN) utilizando este valor de refer�ncia!  Deseja Continuar!","Aten��o")
				lRet := .f.
			Else
				cMsg := "Ser� necess�rio reprocessar o seguinte per�odo dos Abastecimentos: "+Dtoc(M->AT_DATCAD)+" at� "+Dtoc(sTod(cDatVer))+", pois foi alterado o Valor do Litro do C�digo "+M->ZAT_CODCOM
			Endif

			Endif
	
			lRet := .f.
	
		Endif

	Else

		If ALTERA		

			If  !TMPTQN->(EOF())

				If Empty(TMPTQN->TQN_TITABA)

					If !MsgYesNo("J� existe registro na tabela de Abastecimento (TQN) utilizando este valor de refer�ncia!  Deseja Continuar!","Aten��o")
						lRet := .f.
					Else
						cMsg := "Ser� necess�rio reprocessar o seguinte per�odo dos Abastecimentos: "+Dtoc(M->AT_DATCAD)+" at� "+Dtoc(sTod(cDatVer))+", pois foi alterado o Valor do Litro do C�digo "+M->ZAT_CODCOM
						MsgInfo(cMsg,"Aten��o")
						// TODO
						// Gerar email para informar da necessidade de reprocessamento
						// U_EnvMail(cMsg)
					Endif
				Else

					cMsg := "J� existe cobran�a no Financeiro com este pre�o de Combustvel! Estornar o t�tulo para ent�o alterar o pre�o!","Aten��o")
					MsgInfo(cMsg,"Aten��o")
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




