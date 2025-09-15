#include "totvs.ch"
#include 'fwmvcdef.ch'

User Function MTA103MNU()
	Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)

	//.Customizações do cliente
	aAdd(aRotina,{ "Movto Recebimento", "U_CRIAZ0C()", 0 , 2, 0, .F.})

	// MB: 17.01.2025
	aAdd(aRotina,{OemToAnsi("Liberar Devolução da NF"), "U_fLibCancNF()", 0 , 20, 0, nil})
	SetKey( VK_F10, { || U_fLibCancNF() } )
	
	if lAtivo
		// Ponto de chamada ConexãoNF-e sempre como última instrução.
		U_GTPE010()
	endif
Return

/* MB: 17.01.2025
	-> Funcao para liberacao de devolucao de NF;
Processo solicitado pela Camila. */
User Function fLibCancNF()

	Local aArea := GetArea()

	If !(lower(cUserName) $ GetMV("MB_USRLBBQ",, 'camila,bernardo,ioliveira,atoshio,admin,administrador') ) // MB_USRLBBQ: Usuarios que podem liberar a devolucao da NF
		MsgStop("Usuário não tem autorização para liberar a Devolução da NF de entrada.", "Acesso Negado")
	Else
		RecLock("SF1", .F.)
			SF1->F1_XCANCEL := cUserName + "," + DtoC(MsDate()) + "," + Time()
		SF1->(MsUnlock())

		MsgInfo( "Autorizado Devolução da NF " + AllTrim(SF1->F1_DOC) +;
			" por " + AllTrim(cUserName) + " em " + DtoC(MsDate()) + " às " + Time() + ".",;
			"NF de Entrada")
	EndIf

	RestArea(aArea)
Return nil



User Function CriaZ0C()
	//Array dos botoes do FwExecView
	local aEnButt := {{.f., nil},;     // 1 - Copiar
		{.f., nil},;     // 2 - Recortar
		{.f., nil},;     // 3 - Colar
		{.f., nil},;     // 4 - Calculadora
		{.f., nil},;     // 5 - Spool
		{.f., nil},;     // 6 - Imprimir
		{.t., "Salvar"},;// 7 - Confirmar
		{.t., "Sair"},;  // 8 - Cancelar
		{.f., nil},;     // 9 - WalkTrhough
		{.f., nil},;     // 10 - Ambiente
		{.f., nil},;     // 11 - Mashup
		{.t., nil},;     // 12 - Help
		{.f., nil},;     // 13 - Formulário HTML
		{.f., nil},;     // 14 - ECM
		{.f., nil}}      // 15 - Salvar e Criar novo
	local cAliasQry := GetNextAlias()
	local cAliasSD1 := GetNextAlias()
	local cMsg := ""
	local cSeq := ""
	local cCodMovto := ""

	//Verifica se é uma nota do tipo normal
	if SF1->F1_TIPO <> 'N'
		Help(/*Descontinuado*/,/*Descontinuado*/,"OPERAÇÃO INVÁLIDA",/**/,"Esta opção está disponível apenas para notas do tipo normal.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Escolha uma nova nota fiscal para continuar." })
		return
	endIf

	//Verifica se existem itens aptos ao recebimento
	beginSQL alias cAliasSD1
		%noParser%

		select
			SD1.*,
			SB8.B8_SALDO
		from
			%table:SD1% SD1
		join %table:SB8% SB8
		on (
				SB8.%notDel%
				and B8_FILIAL = D1_FILIAL
				and B8_PRODUTO = D1_COD
				and B8_LOTECTL = D1_LOTECTL
				and D1_LOCAL = B8_LOCAL
			)
		where
			SD1.%notDel%
			and D1_FILIAL = %xFilial:SD1%
			and D1_DOC = %exp:SF1->F1_DOC%
			and D1_SERIE = %exp:SF1->F1_SERIE%
			and D1_LOTECTL <> ' '
			and D1_TIPO = 'N'
	endSQL
	if (cAliasSD1)->(Eof())
		Help(/*Descontinuado*/,/*Descontinuado*/,"OPERAÇÃO INVÁLIDA",/**/,"Não foi possível gerar movimentação, pois não foram encontrados lotes de BOVs disponíveis para recebimento.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Escolha uma nova nota fiscal para continuar." })
		(cAliasSD1)->(dbCloseArea())
		return
	else
		while !(cAliasSD1)->(Eof())
			if (cAliasSD1)->B8_SALDO<>(cAliasSD1)->D1_QUANT
				Help(/*Descontinuado*/,/*Descontinuado*/,"OPERAÇÃO INVÁLIDA",/**/,"O saldo do produto ["+allTrim((cAliasSD1)->D1_COD)+"] no lote ["+allTrim((cAliasSD1)->D1_LOTECTL)+"] está diferente entre Saldo em estoque ["+cValToChar((cAliasSD1)->B8_SALDO)+"] (SB8) e quantidade da nota fiscal ["+cValToChar((cAliasSD1)->D1_QUANT)+"] (SD1).", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Escolha uma nova nota fiscal para continuar." })
				(cAliasSD1)->(dbCloseArea())
				return
			endIf
			(cAliasSD1)->(dbSkip())
		endDo
	endIf
	(cAliasSD1)->(dbCloseArea())

	//Verifica se já existe movimentação criada
	beginSQL alias cAliasQry
		%noParser%

		select
			D1_FILIAL,
			D1_DOC,
			D1_SERIE,
			D1_FORNECE,
			D1_LOJA,
			D1_ITEM,
			D1_COD,
			D1_LOTECTL,
			D1_QUANT,
			Z0D_CODIGO,
			sum(Z0D_QUANT) Z0D_QUANT
		from
			%table:SD1% SD1
		join %table:Z0D% Z0D
		on (
				Z0D.%notDel%
				and Z0D_FILIAL = D1_FILIAL
				and Z0D_PROD = D1_COD
				and Z0D_LOTE = D1_LOTECTL
			)
		where
			SD1.%notDel%
			and D1_FILIAL = %xFilial:SD1%
			and D1_DOC = %exp:SF1->F1_DOC%
			and D1_SERIE = %exp:SF1->F1_SERIE%
		group by
			D1_FILIAL,
			D1_DOC,
			D1_SERIE,
			D1_FORNECE,
			D1_LOJA,
			D1_ITEM,
			D1_COD,
			D1_LOTECTL,
			D1_QUANT,
			Z0D_CODIGO
	endSQL

	if !(cAliasQry)->(Eof())
		while !(cAliasQry)->(Eof())

			cMsg += "Item: " + (cAliasQry)->D1_ITEM + ", Produto: " + (cAliasQry)->D1_COD + ", Lote: " + (cAliasQry)->D1_LOTECTL + ", Quantidade da nota: " + allTrim(transform((cAliasQry)->D1_QUANT,"@E 999,999,999")) + ", Movimento: " + (cAliasQry)->Z0D_CODIGO + ", Quantidade do movimento: " + allTrim(transform((cAliasQry)->Z0D_QUANT,"@E 999,999,999")) + CRLF

			(cAliasQry)->(dbSkip())
		endDo

		Help(/*Descontinuado*/,/*Descontinuado*/,"OPERAÇÃO INVÁLIDA",/**/,"Não foi possível gerar movimentação, pois já existem movimentações criadas para os itens da nota:" + CRLF + cMsg, 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Altere as movimentações pela rotina de Movimentação de Bovinos no módulo Estoque/Custos." })
	else

		//Criar movimentação Z0C
		cEquip := GetMV("JR_BALPADM",,"000001")
		cArm   := GetMV("JR_ARMPADM",,"01")
		cTpMov := "1"

		dbSelectArea("Z0C")
		cCodMovto := GETSXENUM("Z0C","Z0C_CODIGO"); ConfirmSX8()

		recLock("Z0C", .T.)
		Z0C_FILIAL := xFilial("Z0C")
		Z0C->Z0C_CODIGO	:= cCodMovto
		Z0C->Z0C_DATA	:= dDataBase
		Z0C->Z0C_DTCRIA := DATE()
		Z0C->Z0C_HRCRIA := TIME()
		Z0C->Z0C_RFID	:= "N"
		Z0C->Z0C_STATUS := "1"
		Z0C->Z0C_TPMOV	:= cTpMov
		Z0C->Z0C_EQUIP	:= cEquip
		Z0C->Z0C_LOCAL	:= cArm
		Z0C->Z0C_DTINI	:= Date()
		Z0C->Z0C_HRINI	:= Time()
		msUnlock()

		beginSQL alias cAliasSD1
			%noParser%

			select
				B8_X_CURRA,
				SD1.*
			from
				%table:SD1% SD1
			join %table:SB8% SB8
			on (
					SB8.%notDel%
					and B8_FILIAL = D1_FILIAL
					and B8_PRODUTO = D1_COD
					and B8_LOTECTL = D1_LOTECTL
					and D1_LOCAL = B8_LOCAL
				)
			where
				SD1.%notDel%
				and D1_FILIAL = %xFilial:SD1%
				and D1_DOC = %exp:SF1->F1_DOC%
				and D1_SERIE = %exp:SF1->F1_SERIE%
				and D1_LOTECTL <> ' '
			order by
				D1_ITEM
		endSQL

		cSeq := ""
		while !(cAliasSD1)->(Eof())

			dbSelectArea("Z0D")
			if empty(cSeq)
				cSeq := "0001"
			else
				cSeq := soma1(cSeq)
			endIf

			recLock("Z0D", .T.)
			Z0D_FILIAL := xFilial("Z0D")
			Z0D->Z0D_CODIGO	:= cCodMovto
			Z0D->Z0D_SEQ	:= cSeq
			Z0D->Z0D_PROD	:= (cAliasSD1)->D1_COD
			Z0D->Z0D_DESC 	:= Posicione("SB1",1,xFilial("SB1")+(cAliasSD1)->D1_COD,"B1_DESC")
			Z0D->Z0D_LOCAL 	:= Posicione("SB1",1,xFilial("SB1")+(cAliasSD1)->D1_COD,"B1_LOCPAD")
			Z0D->Z0D_LOTE	:= (cAliasSD1)->D1_LOTECTL
			Z0D->Z0D_CURRAL	:= (cAliasSD1)->B8_X_CURRA
			Z0D->Z0D_QTDORI	:= (cAliasSD1)->D1_QUANT
			Z0D->Z0D_QUANT	:= (cAliasSD1)->D1_QUANT
			msUnlock()

			(cAliasSD1)->(dbSkip())
		endDo
		(cAliasSD1)->(dbCloseArea())

		//Chama a tela da movimentação
		FWExecView('Recebimento de Animais', 'VAMVCA01', MODEL_OPERATION_UPDATE,, { || .t. },,,aEnButt )
	endIf
	(cAliasQry)->(dbCloseArea())
return
