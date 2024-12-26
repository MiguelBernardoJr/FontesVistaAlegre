#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
// INCLUDE "TBICONN.CH"
// #INCLUDE "TBICODE.CH"
// #INCLUDE "TOPCONN.CH"

/********************

Necessá²©o criar tabelas Z0C, Z0D e Z0E
Necessá²©o criar consulta padrã¯ especï¿½ca para produtos bovinos e consulta padrã¯ de pedidos de compras

********************/

//-------------------------------------------------------------------
User Function VAMVCA01()
	Private oBrowse
	Private	lInterProd := .F.
	Private _cProdMB   := ""
	Private cSeqEfe    := Space(4)

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('Z0C')

	oBrowse:SetDescription( 'Movimentações de Bovinos' )

	oBrowse:AddLegend( "Z0C_STATUS == '1'", "GREEN"  , "Aberto"                )
	oBrowse:AddLegend( "Z0C_STATUS == '2'", "BLACK"  , "Cancelado"             )
	oBrowse:AddLegend( "Z0C_STATUS == '3'", "RED"    , "Efetivado"             )
	oBrowse:AddLegend( "Z0C_STATUS == '4'", "YELLOW" , "Parcialmente Efetivado")

	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
User Function Z0CLEG()
	Local aLegenda    := {}
	Private cCadastro := "Movimentações de Bovinos"

	aAdd( aLegenda, { "BR_VERDE"	, "Aberto"    })
	aAdd( aLegenda, { "BR_PRETO"	, "Cancelado" })
	aAdd( aLegenda, { "BR_VERMELHO"	, "Efetivado" })

	BrwLegenda( cCadastro, "Legenda", aLegenda )

Return Nil

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar'        ACTION 'VIEWDEF.VAMVCA01' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'           ACTION 'u_AddZ0C()' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'           ACTION 'VIEWDEF.VAMVCA01' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'           ACTION 'VIEWDEF.VAMVCA01' OPERATION 5 ACCESS 0
	// ADD OPTION aRotina TITLE 'Efetivar Movimentação'    ACTION 'u_CancMvBv()' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Estorna Movtos'    ACTION 'u_CancMvBv()' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Legenda'           ACTION 'U_Z0CLEG()' OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE 'Rel. Comp. Lotes'  ACTION 'u_VABOVR01()' OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE 'Eliminar Residuos' ACTION 'U_LimpaZ0D()' OPERATION 9 ACCESS 0
Return aRotina

//-------------------------------------------------------------------
User Function LimpaZ0D()

	If Z0C->Z0C_STATUS <> '4' .or. Z0C->Z0C_TPMOV <> '2'
		msgAlert("Esta operação só é permitida para Movimentações efetivadas parcialmente do tipo Apartação.")
		Return
	EndIf

	begin transaction

		cUpd := "delete from " + retSQLName("Z0D") + CRLF
		cUpd += " where Z0D_FILIAL='" + xFilial("Z0D")+ "'" + CRLF
		cUpd += "   and Z0D_CODIGO='" + Z0C->Z0C_CODIGO+ "'" + CRLF
		cUpd += "   and D_E_L_E_T_='*'" + CRLF

		If (TCSqlExec(cUpd) < 0)
			conout("TCSQLError() " + TCSQLError())
			msgAlert("Erro ao eliminar residuos:" + CRLF+TCSQLError())
			DisarmTransaction()
			Return
		else
			ConOut("Z0D: Removidos lotes de origem não pesados com sucesso! ")
		EndIf

		//Ajusta as quantidades contadas
		cUpd := "update " + retSQLName("Z0D") + CRLF
		cUpd += "   set Z0D_QUANT = ( " + CRLF
		cUpd += "		select count(Z0F.R_E_C_N_O_) " + CRLF
		cUpd += "	      from " + retSQLName("Z0F") + "  Z0F " + CRLF
		cUpd += "		 where Z0F_FILIAL=Z0D_FILIAL and Z0F_MOVTO=Z0D_CODIGO and Z0F_PROD=Z0D_PROD and Z0F_LOTORI=Z0D_LOTE and Z0F.D_E_L_E_T_=' '" + CRLF
		cUpd += "	   ) " + CRLF
		cUpd += " where Z0D_FILIAL='" + xFilial("Z0D")+ "'" + CRLF
		cUpd += "   and Z0D_CODIGO='" + Z0C->Z0C_CODIGO+ "'" + CRLF
		cUpd += "   and exists ( " + CRLF
		cUpd += "		select 1 from Z0F010 Z0F " + CRLF
		cUpd += "		 where Z0F_FILIAL=Z0D_FILIAL  " + CRLF
		cUpd += "		   and Z0F_MOVTO=Z0D_CODIGO  " + CRLF
		cUpd += "		   and Z0F_PROD=Z0D_PROD  " + CRLF
		cUpd += "		   and Z0F_LOTORI=Z0D_LOTE  " + CRLF
		cUpd += "		   and Z0F.D_E_L_E_T_=' ' " + CRLF
		cUpd += "   ) " + CRLF
		cUpd += "   and D_E_L_E_T_=' '" + CRLF

		If (TCSqlExec(cUpd) < 0)
			conout("TCSQLError() " + TCSQLError())
			msgAlert("Erro ao eliminar residuos:" + CRLF+TCSQLError())
			DisarmTransaction()
			Return
		else
			ConOut("Z0D: Ajustadas quantidades de origem pesadas com sucesso! ")
		EndIf

		cUpd := "update " + retSQLName("Z0D") + CRLF
		cUpd += "   set D_E_L_E_T_ = '*', R_E_C_D_E_L_=R_E_C_N_O_ " + CRLF
		cUpd += " where Z0D_FILIAL='" + xFilial("Z0D")+ "'" + CRLF
		cUpd += "   and Z0D_CODIGO='" + Z0C->Z0C_CODIGO+ "'" + CRLF
		cUpd += "   and not exists ( " + CRLF
		cUpd += "		select 1 from Z0F010 Z0F " + CRLF
		cUpd += "		 where Z0F_FILIAL=Z0D_FILIAL and Z0F_MOVTO=Z0D_CODIGO and Z0F_PROD=Z0D_PROD and Z0F_LOTORI=Z0D_LOTE and Z0F.D_E_L_E_T_=' ' " + CRLF
		cUpd += "   ) " + CRLF
		cUpd += "   and D_E_L_E_T_=' ' " + CRLF

		If (TCSqlExec(cUpd) < 0)
			conout("TCSQLError() " + TCSQLError())
			msgAlert("Erro ao eliminar residuos:" + CRLF+TCSQLError())
			DisarmTransaction()
			Return
		else
			ConOut("Z0D: Removidos lotes de origem não pesados com sucesso! ")
		EndIf

		RecLock("Z0C")
		Z0C->Z0C_STATUS='3'
		msUnlock()

	end transaction

	msgInfo("Resï¿½os da Movimentação eliminados com sucesso.")

Return

//-------------------------------------------------------------------
Static Function GeraSX1()
	Local aArea    := GetArea()
	Local i        := 0
	Local j        := 0
	Local lInclui  := .F.
	Local aHelpPor := {}
	Local aHelpSpa := {}
	Local aHelpEng := {}
	Local cTexto   := ''

	aRegs          := {}

	AADD(aRegs,{cPerg,"01","Pedido de Compra","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SC7BOV","N","","",""})
	AADD(aRegs,{cPerg,"02","Produto","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1BOV","N","","",""})

	/*Melhoria - Projeto Manejo Analï¿½co*/
	//AADD(aRegs,{cPerg,"03","Tipo de movto","","","mv_ch3","N",01,0,0,"C","","mv_par03","S=Sintetico","","","","","A=Analitico","","","","","","","","","","","","","","","","","","","      ","N","","",""})
	AADD(aRegs,{cPerg,"04","Balanca"      ,"","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","ZV0BOV","N","","",""})

	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 To Len(aRegs)
		If lInclui := !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1", lInclui)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j, aRegs[i,j])
				EndIf
			Next
			MsUnlock()
		EndIf

		aHelpPor := {}; aHelpSpa := {}; aHelpEng := {}
		PutSX1Help("P." + AllTrim(cPerg)+strzero(i,2) + " .", aHelpPor, aHelpEng, aHelpSpa)

	Next

	RestArea(aArea)
Return('SX1: ' + cTexto  + CHR(13) + CHR(10))

//-------------------------------------------------------------------
User Function AddZ0C()
	local aArea        := GetArea()
	// local cAliasQry := GetNextAlias()
	// local cRecnoPed := 0
	Private cPerg      := "VAZ0C"

	If msgYesNo("Deseja inserir uma nova Movimentação?")
		/***********************************************
		 Define os parametros para a execucao da rotina
		***********************************************/
		//cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))
		//GeraSX1()

		MrkLotes()

/*
		If !Pergunte(cPerg,.T.)
			msgAlert("Inclusã¯ cancelada pelo usuá²©o.")
			RestArea(aArea)
			Return
		else
			cPedido := AllTrim(MV_PAR01)
			cProd 	:= AllTrim(MV_PAR02)
			//cAnaSin := AllTrim(MV_PAR03)
			cEquip 	:= AllTrim(MV_PAR04)

			/*If cAnaSin == "A" .and. empty(cEquip)
				msgAlert("Balanç¡ não informada para Movimentação analï¿½ca, informe uma balanç¡ para prosseguir.")
				RestArea(aArea)
				Return
		EndIf*/

		/*If !empty(cPedido)
		BeginSQL alias cAliasQry
					%noParser%
					select SC7.R_E_C_N_O_, C7_NUM, C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_LOCAL, B1_XCONTRA C7_XCONTRA
					  from %table:SC7% SC7
					  join %table:SB1% SB1 on (B1_FILIAL=%xFilial:SB1% and SB1.%notDel% and B1_COD=C7_PRODUTO)
					 where C7_FILIAL=%xFilial:SC7% and SC7.%notDel%
					   and C7_NUM=%exp:cPedido% and C7_PRODUTO like 'BOV%'
		EndSQL
	else
		BeginSQL alias cAliasQry
					%noParser%
					select SC7.R_E_C_N_O_, C7_NUM, C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_LOCAL, B1_XCONTRA C7_XCONTRA
					  from %table:SC7% SC7
					  join %table:SB1% SB1 on (B1_FILIAL=%xFilial:SB1% and SB1.%notDel% and B1_COD=C7_PRODUTO)
					 where C7_FILIAL=%xFilial:SC7% and SC7.%notDel%
					   and C7_PRODUTO=%exp:cProd% and C7_PRODUTO like 'BOV%'
		EndSQL
	EndIf

	If !(cAliasQry)->(Eof())
		If !u_vldPrdBv((cAliasQry)->C7_PRODUTO)
			(cAliasQry)->(dbCloseArea())
			RestArea(aArea)
			Return
		EndIf

		cPedido := (cAliasQry)->C7_NUM
		cItem := (cAliasQry)->C7_ITEM

		cRecnoPed := (cAliasQry)->R_E_C_N_O_
		cCodMovto := GETSXENUM("Z0C","Z0C_CODIGO"); ConfirmSX8()
		dbSelectArea("Z0C")
		RecLock("Z0C", .T.)
		Z0C_FILIAL := xFilial("Z0C")
		Z0C->Z0C_CODIGO := cCodMovto
		Z0C->Z0C_CONTRA := (cAliasQry)->C7_XCONTRA
		Z0C->Z0C_PEDIDO := cPedido
		Z0C->Z0C_ITEMPV := cItem
		Z0C->Z0C_DATA := DDATABASE
		Z0C->Z0C_DTCRIA := DATE()
		Z0C->Z0C_HRCRIA := TIME()
		Z0C->Z0C_TPMOV := "1"
		Z0C->Z0C_RFID := "N"
		Z0C->Z0C_STATUS := "1"
		Z0C->Z0C_PROD := (cAliasQry)->C7_PRODUTO
		Z0C->Z0C_DESC := posicione("SB1",1,xFilial("SB1")+(cAliasQry)->C7_PRODUTO,"B1_DESC")
		Z0C->Z0C_LOCAL := (cAliasQry)->C7_LOCAL
		//Z0C->Z0C_ANASIN := cAnaSin
		Z0C->Z0C_EQUIP := cEquip
		Z0C->Z0C_DTINI := Date()
		Z0C->Z0C_HRINI := Time()
		msUnlock()

				/*dbSelectArea("SB1")
				dbSetOrder(1)
		If dbSeek(xFilial("SB1")+(cAliasQry)->C7_PRODUTO)
					RecLock("SB1", .F.)
					SB1->B1_MSBLQL='1'
					msUnlock()
		EndIf*/
		/*msgAlert("Movimento N.[" + cCodMovto + " ] incluído com sucesso! Para editar seus dados, clique em alterar.")
	else
				msgAlert("N?mero do Pedido e Item não encontrados.")
				RestArea(aArea)
				Return
	EndIf
			(cAliasQry)->(dbCloseArea())
EndIf
*/
EndIf
RestArea(aArea)
Return


Static function MrkLotes(lAdd)
	local nOpc         := GD_UPDATE
	local cLinOk       := "AllwaysTrue"
	local cTudoOk      := "AllwaysTrue"
	local cIniCpos     := "B8_LOTECTL"
	local nFreeze      := 000
	local nMax         := 999
	local cFieldOk     := "AllwaysTrue"
	local cSuperDel    := ""
	local cDelOk       := "AllwaysFalse"
	local nTamLin      := 16
	local nLinIni      := 03
	local nLinAtu      := nLinIni

	Default lAdd       := .F.

	Private oDlg
	Private aHeadMrk   := {}
	Private aColsMrk   := {}
	Private nUsadMrk   := 0

	Private cLoteDe    := Space(TamSX3("B8_LOTECTL")[1])
	Private cLoteAte   := PadR('',TamSX3("B8_LOTECTL")[1],'Z')

	Private cCurralDe  := Space(TamSX3("B8_X_CURRA")[1])
	Private cCurralAte := PadR('',TamSX3("B8_X_CURRA")[1],'Z')

	Private cProdDe    := Space(TamSX3("B1_COD")[1])
	Private cProdAte   := PadR('',TamSX3("B1_COD")[1],'Z')

	Private cEquip     := GetMV("JR_BALPADM",,"000001") //Space(TamSX3("ZV0_CODIGO")[1])
	Private cArm       := GetMV("JR_ARMPADM",,"01")
	Private cTpMov     := ""
	Private cTpAgr     := ""

	If IsInCallStack( 'MATA103' )
		Alert("Esta operação não pode ser realizada neste modo de edição.")
		Return .F.
	EndIf

	If lAdd
		oModel := FWModelActive()
		If oModel:nOperation <> 4
			Alert("Esta operação não pode ser realizada neste modo de edição.")
			Return .F.
		EndIf
	EndIf

	aSize := MsAdvSize(.F.)

	/*
	 MsAdvSize (http://tdn.totvs.com/display/public/mp/MsAdvSize+-+Dimensionamento+de+Janelas)
	 aSize[1] = 1 -> Linha inicial á²¥a trabalho.
	 aSize[2] = 2 -> Coluna inicial á²¥a trabalho.
	 aSize[3] = 3 -> Linha final á²¥a trabalho.
	 aSize[4] = 4 -> Coluna final á²¥a trabalho.
	 aSize[5] = 5 -> Coluna final dialog (janela).
	 aSize[6] = 6 -> Linha final dialog (janela).
	 aSize[7] = 7 -> Linha inicial dialog (janela).
	*/
	aAdd(aHeadMrk,{ " "			, "cStat"      	, "@BMP"         			, 1,0,"","","C","","V","","","","V","","",""})
	aAdd(aHeadMrk,{ "Lote"		, "B8_LOTECTL"	, X3Picture("B8_LOTECTL")	, TamSX3("B8_LOTECTL")[1]	, 0, "AllwaysTrue()", X3Uso("B8_LOTECTL")	, "C", "", "V" } )
	aAdd(aHeadMrk,{ "Curral"	, "B8_X_CURRA"	, X3Picture("B8_X_CURRA")	, TamSX3("B8_X_CURRA")[1]	, 0, "AllwaysTrue()", X3Uso("B8_X_CURRA")	, "C", "", "V" } )
	aAdd(aHeadMrk,{ "BOV"		, "B1_COD"		, X3Picture("B1_COD")	    , TamSX3("B1_COD")[1]		, 0, "AllwaysTrue()", X3Uso("B1_COD")		, "C", "", "V" } )
	aAdd(aHeadMrk,{ "Descricao"	, "B1_DESC"		, X3Picture("B1_DESC")		, 20							, 0, "AllwaysTrue()", X3Uso("B1_DESC")		, "C", "", "V" } )
	aAdd(aHeadMrk,{ "Raca"	    , "B1_XRACA"  	, X3Picture("B1_XRACA"  )   , TamSX3("B1_XRACA")[1]      , 0, "AllwaysTrue()", X3Uso("B1_XRACA")	    , "C", "", "V" } ) // ,"","","","V","","","" } )
	aAdd(aHeadMrk,{ "Sexo"	    , "B1_X_SEXO"  	, X3Picture("B1_X_SEXO"  )  , TamSX3("B1_X_SEXO")[1]	    , 0, "AllwaysTrue()", X3Uso("B1_X_SEXO")	, "C", "", "V" } ) // ,"","","","V","","","" } )
	aAdd(aHeadMrk,{ "Dentiç£¯"  , "B1_XDENTIC"	, X3Picture("B1_XDENTIC")   , TamSX3("B1_XDENTIC")[1]	, 0, "AllwaysTrue()", X3Uso("B1_XDENTIC")	, "C", "", "V" } ) // ,"","","","V","","","" } )
	aAdd(aHeadMrk,{ "Saldo"		, "B8_SALDO"	, X3Picture("B8_SALDO")		, TamSX3("B8_SALDO")[1]		, 0, "AllwaysTrue()", X3Uso("B8_SALDO")		, "C", "", "V" } )
	aAdd(aHeadMrk,{ "Contrato"	, "ZBC_CODIGO"	, X3Picture("ZBC_CODIGO")	, TamSX3("ZBC_CODIGO")[1]	, 0, "AllwaysTrue()", X3Uso("ZBC_CODIGO")	, "C", "", "V" } )
	aAdd(aHeadMrk,{ "Pedido"	, "ZBC_PEDIDO"	, X3Picture("ZBC_PEDIDO")	, TamSX3("ZBC_PEDIDO")[1]	, 0, "AllwaysTrue()", X3Uso("ZBC_PEDIDO")	, "C", "", "V" } )
	aAdd(aHeadMrk,{ "Fornecedor", "A2_NOME"		, X3Picture("A2_NOME")		, TamSX3("A2_NOME")[1]		, 0, "AllwaysTrue()", X3Uso("A2_NOME")		, "C", "", "V" } )
	nUsadMrk := len(aHeadMrk)

	aColsMrk	:= {}
	aAdd(aColsMrk, array(nUsadMrk+1))
	aColsMrk[len(aColsMrk),nUsadMrk+1] := .F.

	define msDialog oDlgMrk title "seleção de Lotes Animais" /*STYLE DS_MODALFRAME*/ From aSize[1], aSize[2] To aSize[3], aSize[5] OF oMainWnd PIXEL
	oDlgMrk:lMaximized := .T. //Maximiza a janela

	oSayFil := TSay():New(nLinAtu, 02 ,{||'Filtros de lotes'},oDlg,,,,,,.T.,,,100,30)
	oSayFil:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 13pt; text-decoration: underline}")

	nLinAtu += nTamLin

	//****************************************************************************
	// Filtro de Lote
	//****************************************************************************
	TSay():New(nLinAtu,02,{||'Lote de: '},oDlgMrk,,,,,,.T.,,,100,10)
	@ nLinAtu-1,030 MSGET oLoteDe VAR cLoteDe PICTURE "@!" /*VALID vldProduto() .or. vazio()*/ F3 "SB8MFJ" SIZE 050, nTamLin/2 OF oDlgMrk PIXEL

	TSay():New(nLinAtu,82,{||'Lote ate: '},oDlgMrk,,,,,,.T.,,,100,10)
	@ nLinAtu-1,110 MSGET oLoteAte VAR cLoteAte PICTURE "@!" /*VALID vldProduto() .or. vazio()*/ F3 "SB8MFJ" SIZE 050, nTamLin/2 OF oDlgMrk PIXEL

	//****************************************************************************
	//Filtro de Curral
	//****************************************************************************
	TSay():New(nLinAtu,162,{||'Curral de: '},oDlgMrk,,,,,,.T.,,,100,10)
	@ nLinAtu-1,190 MSGET oCurralDe VAR cCurralDe PICTURE "@!" /*VALID vldProduto() .or. vazio()*/ F3 "Z08" SIZE 050, nTamLin/2 OF oDlgMrk PIXEL

	TSay():New(nLinAtu,242,{||'Curral ate: '},oDlgMrk,,,,,,.T.,,,100,10)
	@ nLinAtu-1,270 MSGET oCurralAte VAR cCurralAte PICTURE "@!" /*VALID vldProduto() .or. vazio()*/ F3 "Z08" SIZE 050, nTamLin/2 OF oDlgMrk PIXEL

	//****************************************************************************
	//Filtro de Produto
	//****************************************************************************
	TSay():New(nLinAtu,322,{||'Produto de: '},oDlgMrk,,,,,,.T.,,,100,10)
	@ nLinAtu-1,350 MSGET oProdDe VAR cProdDe PICTURE "@!" /*VALID vldProduto() .or. vazio()*/ F3 "SB1" SIZE 050, nTamLin/2 OF oDlgMrk PIXEL

	TSay():New(nLinAtu,402,{||'Produto ate: '},oDlgMrk,,,,,,.T.,,,100,10)
	@ nLinAtu-1,430 MSGET oProdAte VAR cProdAte PICTURE "@!" /*VALID vldProduto() .or. vazio()*/ F3 "SB1" SIZE 050, nTamLin/2 OF oDlgMrk PIXEL

	oSeek	:= TButton():New( nLinAtu-2, 485, "Pesquisar" ,oDlgMrk, {|| SeekAll(lAdd) },55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)
	oSeek:SetCss("QPushButton{ color: #000; }")

	oSeek	:= TButton():New( nLinAtu-2, aSize[5]/2 - 55, "Confirmar" ,oDlgMrk, {|| ConfirmAdd(lAdd) },55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)
	oSeek:SetCss("QPushButton{ color: #FFF; background: #2C2; font-weight: bold}")

	nLinAtu += nTamLin + 5
	If !lAdd
		oSayFil := TSay():New(nLinAtu, 02+162 ,{||'Dados da Movimentação'},oDlg,,,,,,.T.,,,100,30)
		oSayFil:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 13pt; text-decoration: underline}")

		nLinAtu += nTamLin

		nPad := 35
		nA   := 80
		TSay():New(nLinAtu, nA/* 02+162 */,{||'Balanç¡º '},oDlgMrk,,,,,,.T.,,,100,10)
		@ nLinAtu-1, nA+nPad-5/* 030+162 */ MSGET oEquip VAR cEquip PICTURE "@!" VALID !vazio() .and. ExistCPO("ZV0") F3 "ZV0BOV" SIZE 050, nTamLin/2 OF oDlgMrk PIXEL

		nB := (nA+nPad) + nPad + 30
		aTpMov := {"1=Recebimento","2-Apartacao","3-Manejo","4-Enfermaria","5-Reclassificação"}
		cTpMov := aTpMov[2]
		TSay():New(nLinAtu, nB/* 82+162 */,{||'Tipo Movto: '},oDlgMrk,,,,,,.T.,,,60,10)
		aTpMov := TComboBox():New(nLinAtu-1, nB+nPad/* 110+162 */,{|u|If(PCount()>0,cTpMov:=u,cTpMov)}, aTpMov,;
			65,10,oDlgMrk,,{|| SeekAll(lAdd) },,,,.T.,,,,,,,,,'cTpMov')

		nC := (nB+nPad) + nPad + 50
		aTpAgr := {"A=Agrupamento","S=Separado"}
		cTpAgr := aTpAgr[2]
		TSay():New(nLinAtu, nC/* 82+(162*2) */,{||'Tipo Agrupamento: '},oDlgMrk,,,,,,.T.,,,60,10)
		aTpAgr := TComboBox():New(nLinAtu-1, nC+nPad+15/* 110+(162*2) */,{|u|If(PCount()>0,cTpAgr:=u,cTpAgr)}, aTpAgr,;
			65,10,oDlgMrk,,/*{||Alert('Mudou item da combo')}*/,,,,.T.,,,,,,,,,'cTpAgr')

		nD := (nC+nPad) + nPad + 70
		TSay():New(nLinAtu, nD/* 242+162 */,{||'Armazem: '},oDlgMrk,,,,,,.T.,,,190,10)
		@ nLinAtu-1, nD+nPad/* 270+162 */ MSGET oArm VAR cArm PICTURE "@!" VALID !vazio() .and. ExistCPO("NNR") F3 "NNR" ;
			SIZE 030, nTamLin/2 OF oDlgMrk PIXEL
	else
		nLinAtu += nTamLin
	EndIf
	//nLinAtu += nTamLin + 10

	oBtMrk	:= TButton():New( nLinAtu-5, 02, "Inverter seleção" ,oDlgMrk, {|| MarcaDes(oGetDadMrk,"T") },60, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)
	oBtMrk:SetCss("QPushButton{ color: #000; }")

	nLinAtu += nTamLin+4

	oGetDadMrk:= MsNewGetDados():New(nLinAtu, 02, aSize[3]/2, aSize[5]/2, nOpc, cLinOk, cTudoOk, cIniCpos, {}, nFreeze, nMax, cFieldOk, cSuperDel, cDelOk, oDlgMrk, aHeadMrk, aColsMrk)
	oGetDadMrk:oBrowse:blDblClick := {|| MarcaDes(oGetDadMrk,"L")}

	Activate dialog oDlgMrk centered
Return

static Function comboRaca()
	Local cCombo := ''

	BeginSQL alias "QCMB"
	%noParser%
	select distinct Z09_RACA
	  from %table:Z09% Z09
	 where Z09_FILIAL=%xFilial:Z09%
	   and Z09_RACA <> ' '
	   and Z09.%notDel%
	 order by 1 desc
	EndSQL
	while !QCMB->(Eof())
		If !empty(QCMB->Z09_RACA)
			cCombo += If(empty(cCombo),"",";") + AllTrim(QCMB->Z09_RACA) + "=" + AllTrim(QCMB->Z09_RACA)
		EndIf
		QCMB->(dbSkip())
	EndDo
	QCMB->(dbCloseArea())

Return cCombo

Static Function comboSexo()
	Local cCombo := ''

	BeginSQL alias "QCMB"
	%noParser%
	select distinct Z09_SEXO
	  from %table:Z09% Z09
	 where Z09_FILIAL=%xFilial:Z09%
	   and Z09_SEXO <> ' '
	   and Z09.%notDel%
	 order by 1 DESC
	EndSQL
	while !QCMB->(Eof())
		If !empty(QCMB->Z09_SEXO)
			cCombo += If(empty(cCombo),"",";") + AllTrim(QCMB->Z09_SEXO) + "=" + AllTrim(QCMB->Z09_SEXO)
		EndIf
		QCMB->(dbSkip())
	EndDo
	QCMB->(dbCloseArea())

Return cCombo

Static Function ConfirmAdd(lAdd)
	local aArea        := GetArea()
	// local cAliasQry := GetNextAlias()
	// local cRecnoPed := 0
	local nPosLote     := aScan( aHeadMrk, { |x| AllTrim(x[2]) == "B8_LOTECTL"})
	local nPosCurral   := aScan( aHeadMrk, { |x| AllTrim(x[2]) == "B8_X_CURRA"})
	local nPosProd     := aScan( aHeadMrk, { |x| AllTrim(x[2]) == "B1_COD"})
	local nPosDesc     := aScan( aHeadMrk, { |x| AllTrim(x[2]) == "B1_DESC"})
	local nPosSaldo    := aScan( aHeadMrk, { |x| AllTrim(x[2]) == "B8_SALDO"})
	Local nI           := 0

	nQt := 0
	for nI := 1 to len(oGetDadMrk:aCols)
		If oGetDadMrk:aCols[ nI,1]=="LBTIK"
			nQt++
			If !u_vldPrdBv(oGetDadMrk:aCols[ nI,nPosProd],oGetDadMrk:aCols[ nI,nPosLote])
				msgAlert("Lote n.[" + oGetDadMrk:aCols[ nI,nPosLote] + " ] já está sendo utilizado em outra Movimentação")
				RestArea(aArea)
				Return
			EndIf
		EndIf
	Next

	If nQt = 0
		msgAlert("Nenhum lote selecionado, escolha pelo menos 1 lote para continuar.")
		Return .F.
	EndIf

	If !lAdd

		cCodMovto := GETSXENUM("Z0C","Z0C_CODIGO"); ConfirmSX8()
		dbSelectArea("Z0C")
		RecLock("Z0C", .T.)
		Z0C_FILIAL := xFilial("Z0C")
		Z0C->Z0C_CODIGO	:= cCodMovto
		Z0C->Z0C_DATA	:= dDataBase
		Z0C->Z0C_DTCRIA := DATE()
		Z0C->Z0C_HRCRIA := TIME()
		Z0C->Z0C_TPMOV	:= "1"
		Z0C->Z0C_RFID	:= "N"
		Z0C->Z0C_STATUS := "1"
		Z0C->Z0C_EQUIP	:= cEquip
		Z0C->Z0C_TPMOV	:= cTpMov
		Z0C->Z0C_TPAGRP	:= cTpAgr
		Z0C->Z0C_LOCAL	:= cArm
		Z0C->Z0C_DTINI	:= Date()
		Z0C->Z0C_HRINI	:= Time()
		msUnlock()

	else
		cCodMovto := Z0C->Z0C_CODIGO
	EndIf

	lShowMsg := .F.
	dbSelectArea("Z0D")
	cSeq := ""
	for nI := 1 to len(oGetDadMrk:aCols)
		If oGetDadMrk:aCols[ nI,1]=="LBTIK"
			If !lAdd
				If empty(cSeq)
					cSeq := "0001"
				else
					cSeq := soma1(cSeq)
				EndIf

				RecLock("Z0D", .T.)
				Z0D_FILIAL 		:= xFilial("Z0D")
				Z0D->Z0D_CODIGO	:= cCodMovto
				Z0D->Z0D_SEQ	:= cSeq
				Z0D->Z0D_PROD	:= oGetDadMrk:aCols[ nI, nPosProd]
				Z0D->Z0D_DESC 	:= AllTrim(oGetDadMrk:aCols[ nI, nPosDesc])
				Z0D->Z0D_LOCAL 	:= Posicione("SB1",1,xFilial("SB1")+oGetDadMrk:aCols[ nI, nPosProd],"B1_LOCPAD")
				Z0D->Z0D_LOTE	:= oGetDadMrk:aCols[ nI, nPosLote]
				Z0D->Z0D_CURRAL	:= oGetDadMrk:aCols[ nI, nPosCurral]
				Z0D->Z0D_QTDORI	:= oGetDadMrk:aCols[ nI, nPosSaldo]
				Z0D->Z0D_QUANT	:= oGetDadMrk:aCols[ nI, nPosSaldo]

				Z0D->Z0D_RACA   := SB1->B1_XRACA
				Z0D->Z0D_SEXO   := SB1->B1_X_SEXO
				Z0D->Z0D_DENTIC := SB1->B1_XDENTIC
				msUnlock()
				lShowMsg := .T.
			else
				oModel   := FWModelActive()
				oView    := FWViewActive()
				oGridZ0D := oModel:GetModel( 'Z0DDETAIL' )
				cSeq     := oGridZ0D:GetValue( 'Z0D_SEQ' , oGridZ0D:Length())
				cSeq     := soma1(cSeq)

				oModel:GetModel( 'Z0DDETAIL' ):SetNoInsertLine( .F. )

				oGridZ0D:AddLine()
				oGridZ0D:LoadValue("Z0D_CODIGO", cCodMovto)
				oGridZ0D:LoadValue("Z0D_SEQ", cSeq)
				oGridZ0D:LoadValue("Z0D_PROD", left(oGetDadMrk:aCols[ nI, nPosProd],TamSX3("Z0D_PROD")[1]))
				oGridZ0D:LoadValue("Z0D_DESC", left(AllTrim(oGetDadMrk:aCols[ nI, nPosDesc]),TamSX3("Z0D_PROD")[1]))
				oGridZ0D:LoadValue("Z0D_LOCAL", Posicione("SB1",1,xFilial("SB1")+oGetDadMrk:aCols[ nI, nPosProd],"B1_LOCPAD"))
				oGridZ0D:LoadValue("Z0D_LOTE", oGetDadMrk:aCols[ nI, nPosLote])
				oGridZ0D:LoadValue("Z0D_CURRAL", oGetDadMrk:aCols[ nI, nPosCurral])
				oGridZ0D:LoadValue("Z0D_QTDORI", oGetDadMrk:aCols[ nI, nPosSaldo])
				oGridZ0D:LoadValue("Z0D_QUANT", oGetDadMrk:aCols[ nI, nPosSaldo])

				oGridZ0D:LoadValue("Z0D_RACA"  , SubS( SB1->B1_XRACA  , 1, TamSX3('Z0D_RACA')[1]) )
				oGridZ0D:LoadValue("Z0D_SEXO"  , SubS( SB1->B1_X_SEXO , 1, TamSX3('Z0D_SEXO')[1]) )
				oGridZ0D:LoadValue("Z0D_DENTIC", SubS( SB1->B1_XDENTIC, 1, TamSX3('Z0D_DENTIC')[1]) )

				oModel:LoadValue("CALC_TOT", "Z0D__TOT01", oModel:GetValue("CALC_TOT","Z0D__TOT01")+;
														   oGetDadMrk:aCols[ nI, nPosSaldo])
				oView:Refresh()

				oModel:GetModel( 'Z0DDETAIL' ):SetNoInsertLine( .T. )
			EndIf
		EndIf
	Next

	If lShowMsg
		msgInfo("Movimento N.[" + cCodMovto + " ] incluído com sucesso! Para editar seus dados, clique em alterar.")
	EndIf

	oDlgMrk:End()
	RestArea(aArea)
Return


/*/{Protheus.doc} MarcaDes
Funç£¯ para inverter a seleção dos produtos selecionados pelo usuá²©o.
@author Renato de Bianchi
@since 13/07/2018
@version 1.0
@Return ${nenhum}, ${nenhum retorno}
@param oObj, object, Objeto de tela que terá sua seleção invertida
@param cTipo, characters, Indica se inverte todos os itens do markbrowse ou apenas a linha selecionada T - Todos | L - Linha
@type function
/*/
Static Function MarcaDes(oObj,cTipo)
	Local k := 0
	If cTipo <> "T"
		If oObj:aCols[oObj:oBrowse:nAt,1] == "LBNO"
			oObj:aCols[oObj:oBrowse:nAt,1] := "LBTIK"
		Else
			oObj:aCols[oObj:oBrowse:nAt,1] := "LBNO"
		EndIf
	Else
		FOR k:= 1 TO len(oObj:aCols)
			If oObj:aCols[k,1] == "LBNO"
				oObj:aCols[k,1] := "LBTIK"
			Else
				oObj:aCols[k,1] := "LBNO"
			EndIf
		Next

	EndIf
Return(NIL)


/*/{Protheus.doc} seekAll
Funç£¯ responsá¶¥l por pesquisar os produtos a partir dos filtros informados em tela.
@author Renato de Bianchi
@since 15/01/2019
@version 1.0
@Return ${nenhum}, ${não há ²etorno}
@type function
/*/
static function seekAll(lAdd)
	Local nAux    := 0
	Local nX      := 0
	Local _cQry   := ""
	Local cFiltro := ""
	//cFiltro := "% B1_MSBLQL='2' "
	// cFiltro := "% B8_PRODUTO <> '" + Space(TamSX3("B1_COD")[1]) + " ' and B8_PRODUTO <> '0' "

	If lAdd
		//cFiltro += " and not exists (select 1 from " + retSQLName("Z0D") + "  Z0D where Z0D.D_E_L_E_T_=' ' and Z0D_FILIAL='" + xFilial("Z0D") + " ' and Z0D_CODIGO='" + Z0C->Z0C_CODIGO + " ' and Z0D_PROD=B8_PRODUTO and Z0D_LOTE=B8_LOTECTL) "
		oModel := FWModelActive()
		oView := FWViewActive()
		oGridZ0D := oModel:GetModel( 'Z0DDETAIL' )
		If oGridZ0D:Length() > 0
			cFiltro += " and B8_PRODUTO+B8_LOTECTL not in ("
			for nAux := 1 to oGridZ0D:Length()
				cFiltro += iIf(nAux > 1, ",", "") + "'" +  PadR(AllTrim(oGridZ0D:GetValue('Z0D_PROD', nAux)),TamSx3("B8_PRODUTO")[1])+PadR(AllTrim(oGridZ0D:GetValue('Z0D_LOTE', nAux)),TamSx3("B8_LOTECTL")[1]) + "'"
			Next
			cFiltro += " ) " + CRLF
		EndIf
	EndIf
	// cFiltro += " %"

	_cQry := " select DISTINCT 'LBTIK' CSTAT, " + CRLF
	If (Left(cTpMov,1)) == "5"
		_cQry += " 				 Z08_TIPO, " + CRLF
	EndIf
	_cQry += " 				 B1_COD, B8_LOTECTL, B8_X_CURRA, B1_DESC, A2_NOME, ZBC_CODIGO, ZBC_PEDIDO, " + CRLF
	_cQry += " 				 B8_SALDO, B1_XRACA, B1_X_SEXO, B1_XDENTIC " + CRLF
	_cQry += " from  SB8010 SB8 " + CRLF
	_cQry += " join  SB1010 SB1 on (B1_FILIAL= '"+xFilial('SB1')+"' and SB1.B1_COD=SB8.B8_PRODUTO AND SB1.D_E_L_E_T_= ' ') " + CRLF
	_cQry += " left join ZBC010 ZBC on (ZBC.ZBC_FILIAL+ZBC.ZBC_PEDIDO = B1_XLOTCOM " + CRLF
	_cQry += " 					  and ZBC_VERSAO=(select max(ZBC_VERSAO) " + CRLF
	_cQry += " 									  from  ZBC010 Z2 " + CRLF
	_cQry += " 									  where Z2.ZBC_FILIAL=ZBC.ZBC_FILIAL and Z2.ZBC_CODIGO=ZBC.ZBC_CODIGO " + CRLF
	_cQry += " 										and Z2.D_E_L_E_T_= ' ') " + CRLF
	_cQry += " 					  and ZBC.D_E_L_E_T_= ' ') " + CRLF
	_cQry += " left join SA2010 SA2 on (SA2.A2_FILIAL= '"+xFilial('SA2')+"'  and A2_COD=ZBC_CODFOR and A2_LOJA=ZBC_LOJFOR and SA2.D_E_L_E_T_= ' ') " + CRLF
	If (Left(cTpMov,1)) == "5"
		_cQry += " 	    JOIN Z08010 Z08 ON Z08_FILIAL=B8_FILIAL AND Z08_CODIGO=B8_X_CURRA AND Z08_TIPO='4'" + CRLF
	EndIf
	_cQry += " where B8_FILIAL= '"+xFilial('SB8')+"'  " + CRLF
	_cQry += "   and B8_PRODUTO <> '" + Space(TamSX3("B1_COD")[1]) + " ' and B8_PRODUTO <> '0' " + CRLF
	_cQry += "   and B8_PRODUTO between '" + cProdDe + " ' and '" + cProdAte+ "'" + CRLF
	_cQry += "   and B8_LOTECTL between '" + cLoteDe + " ' and '" + cLoteAte+ "'" + CRLF
	_cQry += "   and B8_X_CURRA between '" + cCurralDe + " ' and '" + cCurralAte+ "'" + CRLF
	_cQry += cFiltro
	_cQry += "   and SB8.B8_SALDO > 0 " + CRLF
	_cQry += "   and SB8.D_E_L_E_T_= ' ' " + CRLF
	_cQry += " order by B8_LOTECTL, B1_COD" + CRLF
	MemoWrite("C:\totvs_relatorios\SQL_VAMVCA01_seekAll.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"PRD",.F.,.F.)

// 	BeginSQL alias "PRD"
// 		%noParser%
// 		select DISTINCT 'LBTIK' CSTAT, B1_COD, B8_LOTECTL, B8_X_CURRA, B1_DESC, A2_NOME, ZBC_CODIGO, ZBC_PEDIDO, B8_SALDO, B1_XRACA, B1_X_SEXO, B1_XDENTIC
// 		  from %table:SB8% SB8
// 		  join %table:SB1% SB1 on (B1_FILIAL=%xFilial:SB1% AND SB1.%notDel% and SB1.B1_COD=SB8.B8_PRODUTO)
// 		  left join %table:ZBC% ZBC on (ZBC.ZBC_FILIAL+ZBC.ZBC_PEDIDO = B1_XLOTCOM
// 		  					/*ZBC.ZBC_FILIAL=%xFilial:ZBC% and ZBC_PRODUT=B1_COD*/
// 							and ZBC_VERSAO=(select max(ZBC_VERSAO) from %table:ZBC% Z2 where Z2.ZBC_FILIAL=ZBC.ZBC_FILIAL and Z2.ZBC_CODIGO=ZBC.ZBC_CODIGO and Z2.%notDel%) and ZBC.%notDel%)
// 		  left join %table:SA2% SA2 on (SA2.A2_FILIAL=%xFilial:SA2% and A2_COD=ZBC_CODFOR and A2_LOJA=ZBC_LOJFOR and SA2.%notDel%)
// 		 where B8_FILIAL=%xFilial:SB8%
// 		   and %exp:cFiltro%
// 		   and SB8.B8_SALDO > 0
// 		   and SB8.%notDel%
// 		 order by B8_LOTECTL, B1_COD
// 	EndSQL
//	MemoWrite("C:\totvs_relatorios\SQL_VAMVCA01_seekAll.sql" , GetLastQuery()[2])

	aColsMrk	:= {}
	If !PRD->(Eof())
		While !PRD->(eof())
			aAdd(aColsMrk, array(nUsadMrk+1))

			For nX:=1 to nUsadMrk
				aColsMrk[Len(aColsMrk),nX]:=PRD->( FieldGet(FieldPos(aHeadMrk[nX,2])) )
			Next
			aColsMrk[Len(aColsMrk),nUsadMrk+1]:=.F.
			PRD->(dbSkip())
		End
	else
		aAdd(aColsMrk, array(nUsadMrk+1))
		aColsMrk[len(aColsMrk),nUsadMrk+1] := .F.
	EndIf
	PRD->(dbCloseArea())

	oGetDadMrk:setArray(aColsMrk)
	oGetDadMrk:oBrowse:Refresh()
	oDlgMrk:CtrlRefresh()
	ObjectMethod(oDlgMrk,"Refresh()")
Return

//-------------------------------------------------------------------
User Function ProxProd()
	Local oModel     := FWModelActive()
	// Local nI         := 0
	Local cProxProd  := ""

	// MB : 09.06.2020
	// 	# analise para definiç£¯ do BOV utilizar
	// Local nBkpZ0D  := 0
	Local nBkpZ0E  := 0
	Local nD       := 0, nE := 0
	Local nQuant   := 0
	// MB : 09.06.2020

	Private oGridZ0D := oModel:GetModel( 'Z0DDETAIL' )
	Private oGridZ0E := oModel:GetModel( 'Z0EDETAIL' )

	// nBkpZ0D  := oGridZ0D:nLine
	nBkpZ0E  := oGridZ0E:nLine
	// zerando variavel privada
	_cProdMB         := ""

	//só °¥rmite a efetivaç£¯ se a quantidade de origem e destino estiverem iguais
	nQtdOri          := oModel:GetValue("CALC_TOT","Z0D__TOT01")
	nQtdDes          := oModel:GetValue("CALC_TOT","Z0E__TOT02")
	If nQtdOri<=0
		alert('não hárigens informadas, por favor, informe uma origem para continuar.')
		Return .F.
	EndIf
/* 
	//IdentIfica os produtos de destino e salva a quantidade necessá²©a
	oGridZ0D := oModel:GetModel( 'Z0DDETAIL' )
	oGridZ0E := oModel:GetModel( 'Z0EDETAIL' )
	For nI := 1 To oGridZ0D:Length()
		oGridZ0D:GoLine( nI )

		If !oGridZ0D:IsDeleted()
			If nQtdDes < oGridZ0D:GetValue('Z0D_QUANT', nI)
				cProxProd  := oGridZ0D:GetValue('Z0D_PROD', nI)
				_cProdMB := cProxProd
				nI := oGridZ0D:Length()
			else
				nQtdDes -= oGridZ0D:GetValue('Z0D_QUANT', nI)
			EndIf
		EndIf
	Next
*/
	// MB : 09.06.2020
	// 	# analise para definiç£¯ do BOV utilizar
	If _cProdMB <> FwFldGet('Z0D_PROD')

		_cProdMB := ""
		For nD := 1 To oGridZ0D:Length()
			oGridZ0D:GoLine( nD )

			If !oGridZ0D:IsDeleted()

				nQuant := 0

				For nE := 1 To oGridZ0E:Length()
					oGridZ0E:GoLine( nE )
					If !oGridZ0E:IsDeleted()
						If !Empty(FwFldGet('Z0D_PROD')) .and. !Empty(FwFldGet('Z0E_PROD')) .and.;
								FwFldGet('Z0D_PROD') == FwFldGet('Z0E_PROD') ;
								.AND. FwFldGet('Z0D_LOTE') == FwFldGet('Z0E_LOTORI')

							nQuant += FwFldGet('Z0E_QUANT')
						EndIf
					EndIf
				Next nE
				If nQuant < FwFldGet('Z0D_QUANT')
					cProxProd := _cProdMB := FwFldGet('Z0D_PROD')

					oGridZ0E:LoadValue('Z0E_LOTORI', FwFldGet('Z0D_LOTE') )
					exit
				EndIf
			EndIf
		Next nD
	EndIf

	oGridZ0E:GoLine( nBkpZ0E ) // voltar sempre na posicao ... Z0E
Return cProxProd

// ======================================================================================= //
User Function SB8Curral(cProd, cLote)
	local cCurral := "     "

	BeginSQL alias "CUR"
	%noParser%
	select B8_X_CURRA
	  from %table:SB8% SB8
	 where B8_FILIAL =%xFilial:SB8%
	   and B8_LOTECTL=%exp:cLote%
	   and B8_SALDO > 0
	   and SB8.%notDel%
	EndSQL
	//    and B8_PRODUTO=%exp:cProd%

	If !CUR->(Eof())
		cCurral := CUR->B8_X_CURRA
	EndIf
	CUR->(dbCloseArea())

Return cCurral

 /*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 28.05.2020                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '--------------------------------------------------------------------------------*/
User Function TgPrdZ0D()
	local oModel   := FWModelActive()
	Local oGridZ0D := oModel:GetModel( 'Z0DDETAIL' )
	Local cRetorno := POSICIONE("SB1",1,xFilial("SB1")+FwFldGet('Z0D_PROD'), "B1_DESC")
	Local nAux     := u_getSldBv( FwFldGet('Z0D_PROD'), FwFldGet('Z0D_LOTE') )
	// oGridZ0D:LoadValue('Z0D_DESC'  , POSICIONE("SB1",1,xFilial("SB1")+FwFldGet('Z0D_PROD'), "B1_DESC") )

	oGridZ0D:LoadValue('Z0D_QUANT' , nAux )
	oGridZ0D:LoadValue('Z0D_QTDORI', nAux )
Return cRetorno

 /*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 28.05.2020                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '--------------------------------------------------------------------------------*/
User Function TgLotZ0D() // trigger
	local oModel   := FWModelActive()
	Local oGridZ0D := oModel:GetModel( 'Z0DDETAIL' )
	Local cLote    := AllTrim(FwFldGet('Z0D_LOTE'))
	Local nAux     := u_getSldBv( FwFldGet('Z0D_PROD'), FwFldGet('Z0D_LOTE') )
	// Local cCurral  := u_SB8Curral( FwFldGet('Z0D_PROD'), FwFldGet('Z0D_LOTE') )

	oGridZ0D:LoadValue('Z0D_QUANT' , nAux )
	oGridZ0D:LoadValue('Z0D_QTDORI', nAux )

Return u_SB8Curral( FwFldGet('Z0D_PROD'), FwFldGet('Z0D_LOTE') ) // cCurral


 /*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 28.05.2020                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '--------------------------------------------------------------------------------*/
User Function TgLotZ0E() // trigger
	local oModel     := FWModelActive()
	Local oGridZ0D   := oModel:GetModel( 'Z0DDETAIL' )
	Local oGridZ0E   := oModel:GetModel( 'Z0EDETAIL' )
	Local cLote      := AllTrim(FwFldGet( 'Z0E_LOTE' ))
	Local nRegistros := 0
	Local cAux       := ""

	oGridZ0E:LoadValue('Z0E_PROD'  , U_ProxProd() )
	cAux := Left(POSICIONE('SB1', 1, xFilial('SB1')+FwFldGet('Z0E_PROD'), 'B1_DESC'), TamSX3('Z0E_DESC')[1])
	oGridZ0E:LoadValue('Z0E_DESC'  , cAux )

	BeginSQL alias "TMP"
		SELECT B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO, B8_GMD, B8_DIASCO, B8_XRENESP
			 , AVG(B8_XPESTOT) B8_XPESTOT
             , COUNT(*) QTD
	         , SUM(B8_SALDO) SALDO
		FROM   SB8010 SB8 
		WHERE B8_FILIAL = %xFilial:SB8%
		  AND B8_LOTECTL  = %exp:cLote%
		  AND B8_SALDO > 0 
		  AND B8_XDATACO<>' '
		  AND SB8.D_E_L_E_T_= ' '
		GROUP BY B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO, B8_GMD, B8_DIASCO, B8_XRENESP
	EndSQL
	TMP->(DbEval({|| nRegistros++ }))
	TMP->(DbGoTop())

	If !TMP->(Eof())
		oGridZ0E:LoadValue('Z0E_CURRAL', TMP->B8_X_CURRA )
	EndIf

	If nRegistros == 1
		oGridZ0E:LoadValue('Z0E_PESTOT', TMP->B8_XPESTOT       )
		oGridZ0E:LoadValue('Z0E_DATACO', sToD(TMP->B8_XDATACO) )
		oGridZ0E:LoadValue('Z0E_GMD'   , TMP->B8_GMD           )
		oGridZ0E:LoadValue('Z0E_DIASCO', TMP->B8_DIASCO 	   )
		oGridZ0E:LoadValue('Z0E_RENESP', TMP->B8_XRENESP 	   )
		oGridZ0E:LoadValue('Z0E_PESO'  , TMP->B8_XPESOCO       )
		
		// MB : 30.03.2021 => pega lote de origem para gatilhar os campos no destino
		If Z0C->Z0C_TPMOV == '4' // Apartação
			cLote        := FwFldGet('Z0D_LOTE')

			BeginSQL alias "TMP_O"
				SELECT B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO, B8_GMD, B8_DIASCO, B8_XRENESP
					, AVG(B8_XPESTOT) B8_XPESTOT
					, COUNT(*) QTD
					, SUM(B8_SALDO) SALDO
				FROM   SB8010 SB8 
				WHERE B8_FILIAL = %xFilial:SB8%
				AND B8_LOTECTL  = %exp:cLote%
				AND B8_SALDO > 0 
				AND B8_XDATACO<>' '
				AND SB8.D_E_L_E_T_= ' '
				GROUP BY B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO, B8_GMD, B8_DIASCO, B8_XRENESP
			EndSQL
			TMP_O->(DbGoTop())
			If !TMP_O->(Eof())
				oGridZ0E:LoadValue('Z0E_PESO', TMP_O->B8_XPESOCO )
			EndIf
			TMP_O->(dbCloseArea())
		EndIf
		
	ElseIf nRegistros>1
		// msgAlert('Foram encontradas ' + cValToChar(nRegistros) + ' registros diferentes na tabela de lotes (SB8).')
		msgAlert('O lote: '+AllTrim(clote)+' possui animais com data de entrada diferentes, informe os campos manualmente: PESO APARTAÇÃO, DATA DE INICIO.')
	EndIf
	TMP->(dbCloseArea())

	// POSIONAR NA Z0D de acordo com o produto
	oGridZ0E:LoadValue('Z0E_RACA'  , FwFldGet('Z0D_RACA') )
	oGridZ0E:LoadValue('Z0E_SEXO'  , FwFldGet('Z0D_SEXO') )
	oGridZ0E:LoadValue('Z0E_DENTIC', FwFldGet('Z0D_DENTIC') )

Return cLote


 /*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 28.05.2020                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '--------------------------------------------------------------------------------*/
User Function TgRacZ0E()
	local oModel   := FWModelActive()
	Local oGridZ0D := oModel:GetModel( 'Z0DDETAIL' )
	Local nBkpZ0D  := oGridZ0D:nLine
	Local oGridZ0E := oModel:GetModel( 'Z0EDETAIL' )
	Local cRaca    := ""
	Local cAux     := ""
/* 
	// MB : 09.06.2020
	// 	# analise para definiç£¯ do BOV utilizar
	Local nBkpZ0D  := oGridZ0D:nLine
	Local nBkpZ0E  := oGridZ0E:nLine
	Local nD       := 0, nE := 0
	Local nQuant   := 0
	If _cProdMB <> FwFldGet('Z0D_PROD')

		_cProdMB := ""
		For nD := 1 To oGridZ0D:Length()
			oGridZ0D:GoLine( nD )
			If !oGridZ0D:IsDeleted()
				nQuant := 0
				For nE := 1 To oGridZ0E:Length()
					oGridZ0E:GoLine( nE )
					If !oGridZ0E:IsDeleted()
						If !Empty(FwFldGet('Z0D_PROD')) .and. !Empty(FwFldGet('Z0E_PROD')) .and.;
							 FwFldGet('Z0D_PROD') == FwFldGet('Z0E_PROD')
							nQuant += FwFldGet('Z0E_QUANT')
							EndIf
					EndIf
				Next nE
				If nQuant < FwFldGet('Z0D_QUANT')
					_cProdMB := FwFldGet('Z0D_PROD')
					exit
				EndIf
			EndIf
		Next nD
	EndIf
	oGridZ0E:GoLine( nBkpZ0E ) // voltar sempre na posicao ... Z0E 
*/
	_cProdMB := U_ProxProd() // StaticCall(VAMVCA01, ProxProd)
	If Empty(_cProdMB)
		oGridZ0D:GoLine( nBkpZ0D )
		Return cRaca
	EndIf
	If SubS(ReadVar(),4) == "Z0E_RACA"
		cRaca := &(ReadVar())
	Else
		// oGridZ0E:LoadValue('Z0E_RACA'  , FwFldGet('Z0D_RACA') )
		cRaca := FwFldGet('Z0D_RACA')
	EndIf

	oGridZ0E:LoadValue('Z0E_PROD'  , _cProdMB ) // StaticCall(VAMVCA01, ProxProd) ) // FwFldGet('Z0D_PROD') ) // _cProdMB

	cAux := Left(POSICIONE('SB1', 1, xFilial('SB1')+FwFldGet('Z0D_PROD'), 'B1_DESC'), TamSX3('Z0E_DESC')[1])
	oGridZ0E:LoadValue('Z0E_DESC'  , cAux )

	oGridZ0E:LoadValue('Z0E_LOTE'  , FwFldGet('Z0D_LOTE') )
	BeginSQL alias "TMP"
		SELECT B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO, B8_GMD, B8_DIASCO, B8_XRENESP
			 , AVG(B8_XPESTOT) B8_XPESTOT
             , COUNT(*) QTD
	         , SUM(B8_SALDO) SALDO
		FROM   SB8010 SB8 
		WHERE B8_FILIAL   = %xFilial:SB8%
		  AND B8_PRODUTO  = %exp:_cProdMB%
		  AND B8_LOTECTL  = %exp:FwFldGet('Z0D_LOTE')%
		  AND B8_SALDO > 0 
		  AND B8_XDATACO<>' '
		  AND SB8.D_E_L_E_T_= ' '
		GROUP BY B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO, B8_GMD, B8_DIASCO, B8_XRENESP
	EndSQL

	If !TMP->(Eof())
		// If Z0C->Z0C_TPMOV == "5" // Re-Classificaç£¯
		If Z0C->Z0C_TPMOV <> "2" // Apartação
			oGridZ0E:LoadValue('Z0E_PESTOT', TMP->B8_XPESTOT   )
			oGridZ0E:LoadValue('Z0E_PESO'  , TMP->B8_XPESOCO   )
		EndIf
		oGridZ0E:LoadValue('Z0E_DATACO', sToD(TMP->B8_XDATACO) )
		oGridZ0E:LoadValue('Z0E_GMD'   , TMP->B8_GMD           )
		oGridZ0E:LoadValue('Z0E_DIASCO', TMP->B8_DIASCO 	   )
		oGridZ0E:LoadValue('Z0E_RENESP', TMP->B8_XRENESP 	   )
		oGridZ0E:LoadValue('Z0E_CURRAL', TMP->B8_X_CURRA )
	Else
		oGridZ0E:LoadValue('Z0E_CURRAL', u_SB8Curral( FwFldGet('Z0E_PROD'), FwFldGet('Z0E_LOTE')) ) // FwFldGet('Z0D_CURRAL') )
	EndIf
	TMP->(dbCloseArea())

	// oGridZ0E:LoadValue('Z0E_RACA'  , FwFldGet('Z0D_RACA') )
	oGridZ0E:LoadValue('Z0E_SEXO'  , FwFldGet('Z0D_SEXO') )
	oGridZ0E:LoadValue('Z0E_DENTIC', FwFldGet('Z0D_DENTIC') )
	// oModel:CommitData()
Return cRaca


 /*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 28.05.2020                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '--------------------------------------------------------------------------------*/
User Function TgPrdZ0E()
	local oModel   := FWModelActive()
	Local oGridZ0E := oModel:GetModel( 'Z0EDETAIL' )

	// oGridZ0E:LoadValue('Z0E_DESC'  , POSICIONE("SB1",1,xFilial("SB1")+FwFldGet('Z0E_PROD'), "B1_DESC") )
	Local cRetorno := POSICIONE("SB1",1,xFilial("SB1")+FwFldGet('Z0E_PROD'), "B1_DESC")

	oGridZ0E:LoadValue('Z0E_CORRET', U_LoadCpoVirtual( xFilial('Z0E'), _cProdMB, 'C' ) )
	oGridZ0E:LoadValue('Z0E_FORNEC', U_LoadCpoVirtual( xFilial('Z0E'), _cProdMB, 'F' ) )
	oGridZ0E:LoadValue('Z0E_RACA'  , SB1->B1_XRACA )
	oGridZ0E:LoadValue('Z0E_SEXO'  , SB1->B1_X_SEXO )
	oGridZ0E:LoadValue('Z0E_DENTIC', SB1->B1_XDENTIC )
Return cRetorno

// ======================================================================================= //
Static Function ModelDef()

	// Cria as estruturas a serem usadas no Modelo de Dados
	Local oModel // Modelo de dados construï¿½
	Local oStruZ0C   := FWFormStruct( 1, 'Z0C' )
	Local oStruZ0D   := FWFormStruct( 1, 'Z0D' )
	Local oStruZ0E   := FWFormStruct( 1, 'Z0E' )
	Local oGridZ0D   := nil
	local bZ0DLinePr := {||}

	/*oStruZ0D:AddTrigger( ;
      aAuxZ0D[1] , ;       // [01] Id do campo de origem
      aAuxZ0D[2] , ;       // [02] Id do campo de destino
      aAuxZ0D[3] , ;       // [03] Bloco de codigo de validaç£¯ da execuç£¯ do gatilho
	  aAuxZ0D[4] )         // [4] Bloco de codigo de execuç£¯ do gatilho*/
// aAuxZ0D := TrgSB1('Z0D')  	// Z0D_PROD -> Z0D_DESC
Local aTrigger := aClone(FwStruTrigger(;		// Z0D_PROD -> Z0D_DESC
			"Z0D_PROD" ,; // Campo Dominio
			"Z0D_DESC" ,; // Campo de Contradominio
			"U_TgPrdZ0D()",; // Regra de Preenchimento
			.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
			"" ,; // Alias da tabela a ser posicionada
			0,; // Ordem da tabela a ser posicionada
			"",; //'xFilial("SB8")+FWFldGet("'+pAlias+'_PROD")+'+pAlias+'_LOTE' ,; // Chave de busca da tabela a ser posicionada
			NIL,; // Condicao para execucao do gatilho
			"01" )) // Sequencia do gatilho (usado para identIficacao no caso de erro)
oStruZ0D:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])
/* 
	aAuxZ0D2 := TrgSB2('Z0D')	// Z0D_PROD -> Z0D_QTDORI
	oStruZ0D:AddTrigger(aAuxZ0D2[1], aAuxZ0D2[2], aAuxZ0D2[3], aAuxZ0D2[4])
	aAuxZ0D3 := TrgSB3('Z0D')	// _PROD -> _QUANT
	oStruZ0D:AddTrigger(aAuxZ0D3[1], aAuxZ0D3[2], aAuxZ0D3[3], aAuxZ0D3[4])
*/

// aAuxZ0D4 := TrgSB4('Z0D')	// _LOTE -> _CURRAL
	aTrigger := aClone(FwStruTrigger(;     // _LOTE -> _CURRAL
	"Z0D_LOTE" ,; // Campo Dominio
	"Z0D_CURRAL" ,; // Campo de Contradominio
	"U_TgLotZ0D()",; //'SB8->B8_X_CURRA',; // Regra de Preenchimento
	.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
	"   " ,; // Alias da tabela a ser posicionada
	0 ,; // Ordem da tabela a ser posicionada
	" " ,; //'xFilial("SB8")+FWFldGet("'+pAlias+'_PROD")+'+pAlias+'_LOTE' ,; // Chave de busca da tabela a ser posicionada
	NIL ,; // Condicao para execucao do gatilho
	"02" )) // Sequencia do gatilho (usado para identIficacao no caso de erro)
	oStruZ0D:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])
/* 
aAuxZ0D6 := TrgSB6('Z0D')	// LOTE -> _QTDORI
oStruZ0D:AddTrigger(aAuxZ0D6[1], aAuxZ0D6[2], aAuxZ0D6[3], aAuxZ0D6[4])
aAuxZ0D7 := TrgSB7('Z0D') 	// _LOTE -> _QUANT
oStruZ0D:AddTrigger(aAuxZ0D7[1], aAuxZ0D7[2], aAuxZ0D7[3], aAuxZ0D7[4])
*/
	aTrigger := aClone(FwStruTrigger(;	// _LOTE -> _LOTE
	"Z0E_LOTE" ,; // Campo Dominio
	"Z0E_LOTE" ,; // Campo de Contradominio
	"U_TgLotZ0E()",; // Regra de Preenchimento
	.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
	"   " ,; // Alias da tabela a ser posicionada
	0 ,; // Ordem da tabela a ser posicionada
	" " ,; //'xFilial("SB8")+FWFldGet("'+pAlias+'_PROD")+'+pAlias+'_LOTE' ,; // Chave de busca da tabela a ser posicionada
	NIL ,; // Condicao para execucao do gatilho
	"04" )) // Sequencia do gatilho (usado para identIficacao no caso de erro)
	oStruZ0E:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])

	aTrigger := aClone(FwStruTrigger(;	// _RACA -> _RACA
	"Z0E_RACA" ,; // Campo Dominio
	"Z0E_RACA" ,; // Campo de Contradominio
	"U_TgRacZ0E()",;// Regra de Preenchimento
	.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
	"   " ,; // Alias da tabela a ser posicionada
	0 ,; // Ordem da tabela a ser posicionada
	" " ,; //'xFilial("SB8")+FWFldGet("'+pAlias+'_PROD")+'+pAlias+'_LOTE' ,; // Chave de busca da tabela a ser posicionada
	NIL ,; // Condicao para execucao do gatilho
	"03" )) // Sequencia do gatilho (usado para identIficacao no caso de erro)
	oStruZ0E:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])
/* 
	aAuxZ0E4 := TrgSB4('Z0E')	// _LOTE -> _CURRAL
	oStruZ0E:AddTrigger(aAuxZ0E4[1], aAuxZ0E4[2], aAuxZ0E4[3], aAuxZ0E4[4])
	aAuxZ0E5 := TrgSB5('Z0E') 	// _LOTE -> _PROD
	oStruZ0E:AddTrigger(aAuxZ0E5[1], aAuxZ0E5[2], aAuxZ0E5[3], aAuxZ0E5[4])*/
// aAuxZ0E := TrgSB1('Z0E') 	// Z0E_PROD -> Z0E_DESC
	aTrigger := aClone(FwStruTrigger(;		// Z0E_PROD -> Z0E_DESC
		"Z0E_PROD" ,; // Campo Dominio
		"Z0E_DESC" ,; // Campo de Contradominio
		"U_TgPrdZ0E()",; // Regra de Preenchimento
		.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
		"   " ,; // Alias da tabela a ser posicionada
		0 ,; // Ordem da tabela a ser posicionada
		" " ,; //'xFilial("SB8")+FWFldGet("'+pAlias+'_PROD")+'+pAlias+'_LOTE' ,; // Chave de busca da tabela a ser posicionada
		NIL ,; // Condicao para execucao do gatilho
		"05" )) // Sequencia do gatilho (usado para identIficacao no caso de erro)
	oStruZ0E:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])
/* 
	aAuxZ0Ec := TrgSB1c('Z0E')	// _PROD -> _CORRET
	oStruZ0E:AddTrigger(aAuxZ0Ec[1], aAuxZ0Ec[2], aAuxZ0Ec[3], aAuxZ0Ec[4])
	aAuxZ0Ef := TrgSB1f('Z0E')	// _PROD -> _FORNEC
	oStruZ0E:AddTrigger(aAuxZ0Ef[1], aAuxZ0Ef[2], aAuxZ0Ef[3], aAuxZ0Ef[4])
	aAuxZ0Ex := TrgSB1r('Z0E')	 // _PROD -> _RACA
	oStruZ0E:AddTrigger(aAuxZ0Ex[1], aAuxZ0Ex[2], aAuxZ0Ex[3], aAuxZ0Ex[4])
	aAuxZ0Ex := TrgSB1s('Z0E')	// _PROD -> _SEXO
	oStruZ0E:AddTrigger(aAuxZ0Ex[1], aAuxZ0Ex[2], aAuxZ0Ex[3], aAuxZ0Ex[4])
	aAuxZ0Ex := TrgSB1d('Z0E') 	// PROD -> _DENTIC
	oStruZ0E:AddTrigger(aAuxZ0Ex[1], aAuxZ0Ex[2], aAuxZ0Ex[3], aAuxZ0Ex[4])*/

//Adiciona validaç£¯ da quantidade do produto de origem
	cVld0 := "u_vldLotBv(&(ReadVar()), .T.) .and. FwFldGet('Z0C_STATUS')$'14'"
	bVld0 := FWBuildFeature( STRUCT_FEATURE_VALID, cVld0 )
	oStruZ0D:SetProperty('Z0D_LOTE', MODEL_FIELD_VALID,bVld0)

//Adiciona validaç£¯ da quantidade do produto de origem
	cVld1 := "Positivo() .and. u_vlSdOri() .and. FwFldGet('Z0C_STATUS')$'14'"
	bVld1 := FWBuildFeature( STRUCT_FEATURE_VALID, cVld1 )
	oStruZ0D:SetProperty('Z0D_QUANT', MODEL_FIELD_VALID,bVld1)

// MB : 08.08.2019
// cVldMB := "U_LoadCpoVirtual('C')" // C=Corretor; F=Fornecedor
// bVldMB := FWBuildFeature( STRUCT_FEATURE_INIPAD , cVldMB )
// oStruZ0E:SetProperty('Z0D_CORRET', MODEL_FIELD_INIT,bVldMB)
//
// cVldMB := "U_LoadCpoVirtual('F')" // C=Corretor; F=Fornecedor
// bVldMB := FWBuildFeature( STRUCT_FEATURE_INIPAD , cVldMB )
// oStruZ0E:SetProperty('Z0D_FORNEC', MODEL_FIELD_INIT,bVldMB)

//Adiciona validaç£¯ da quantidade do produto de destino
	cVld2 := "Positivo() .and. u_vlSdDest() .and. FwFldGet('Z0C_STATUS')$'14' .and. empty(FwFldGet('Z0E_SEQEFE')) "
	bVld2 := FWBuildFeature( STRUCT_FEATURE_VALID, cVld2 )
	oStruZ0E:SetProperty('Z0E_QUANT', MODEL_FIELD_VALID,bVld2)

// MB : 04.01.2017
	bVldAUX := FWBuildFeature( STRUCT_FEATURE_WHEN,;
		"FwFldGet('Z0C_TPMOV')$'1234'" ) // "FwFldGet('Z0C_TPMOV')$'123'" )
	oStruZ0E:SetProperty('Z0E_PESTOT', MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0E:SetProperty('Z0E_PESO'  , MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0E:SetProperty('Z0E_GMD'   , MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0E:SetProperty('Z0E_DIASCO', MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0E:SetProperty('Z0E_RENESP', MODEL_FIELD_WHEN, bVldAUX)
// MB : 04.01.2017

// MB : 12.05.2020
	oStruZ0E:SetProperty('Z0E_LOTE'  , MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0E:SetProperty('Z0E_CURRAL', MODEL_FIELD_WHEN, bVldAUX)

	bVldAUX := FWBuildFeature( STRUCT_FEATURE_WHEN,;
		"FwFldGet('Z0C_TPMOV')$'5'" )
	oStruZ0E:SetProperty('Z0E_RACA'  , MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0E:SetProperty('Z0E_SEXO'  , MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0E:SetProperty('Z0E_DENTIC', MODEL_FIELD_WHEN, bVldAUX)
// MB : 12.05.2020

// MB : 05.08.2019
	oStruZ0E:SetProperty('Z0E_LOTE', MODEL_FIELD_VALID,;
							FWBuildFeature( STRUCT_FEATURE_VALID,;
									"U_libVldLote( AllTrim(&(ReadVar())), .T., 'M->Z0E_LOTE-VALID' )" ))

// MB : 08.08.2019
	cVldMB3 := "U_CurPastoOuBaia( AllTrim(&(ReadVar())) )" // 1=Baia;4=Pasto;
	bVldMB3 := FWBuildFeature( STRUCT_FEATURE_VALID, cVldMB3 )
	oStruZ0E:SetProperty( 'Z0E_CURRAL' , MODEL_FIELD_VALID, bVldMB3)

// MB : 02.06.2020
	oStruZ0E:SetProperty('Z0E_SEXO', MODEL_FIELD_VALID,;
		FWBuildFeature( STRUCT_FEATURE_VALID, "fVldSexo()" ) )

// MB : 11.05.2020
/*
	cancelado momentaneamente, parece que nao nao ta funcionando
	*/
	// oStruZ0C:SetProperty('Z0C_TPMOV', MODEL_FIELD_VALID,;
		// 			FWBuildFeature( STRUCT_FEATURE_VALID, "StaticCall(VAMVCA01,fVldTPMOV)" ) )
	// MB : 11.05.2020

	// cVldMB := "U_LoadCpoVirtual('C')" // C=Corretor; F=Fornecedor
	// bVldMB := FWBuildFeature( STRUCT_FEATURE_INIPAD , cVldMB )
	// oStruZ0E:SetProperty('Z0E_CORRET', MODEL_FIELD_INIT,bVldMB)
	//
	// cVldMB := "U_LoadCpoVirtual('F')" // C=Corretor; F=Fornecedor
	// bVldMB := FWBuildFeature( STRUCT_FEATURE_INIPAD , cVldMB )
	// oStruZ0E:SetProperty('Z0E_FORNEC', MODEL_FIELD_INIT,bVldMB)

	//Adiciona validaç£¯ da quantidade do produto de destino
	cVld3 := "FwFldGet('Z0C_DATA') <= DDATABASE"
	bVld3 := FWBuildFeature( STRUCT_FEATURE_VALID, cVld3 )
	oStruZ0C:SetProperty('Z0C_DATA', MODEL_FIELD_VALID, bVld3)

	cVldEfet := "FwFldGet('Z0C_STATUS')!='3'"
	bVldEfet := FWBuildFeature( STRUCT_FEATURE_WHEN, cVldEfet )
	oStruZ0D:SetProperty('Z0D_LOTE'  , MODEL_FIELD_WHEN, bVldEfet)
	oStruZ0D:SetProperty('Z0D_QUANT' , MODEL_FIELD_WHEN, bVldEfet)
	oStruZ0E:SetProperty('Z0E_QUANT' , MODEL_FIELD_WHEN, bVldEfet)
	// oStruZ0E:SetProperty('Z0E_LOTE'  , MODEL_FIELD_WHEN, bVldEfet)

	oModel     := MPFormModel():New("VAMDLA01",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oGridZ0D   := oModel:GetModel("Z0DDETAIL")
	oGridZ0E   := oModel:GetModel("Z0EDETAIL")
	bZ0DLinePr := {|oGridZ0D, nLin, cOperacao, cCampo, xValAtr, xValAnt| Z0DLinPreG(oGridZ0D, nLin, cOperacao, cCampo, xValAtr, xValAnt)}

	//oModel:AddFields('Z0CMASTER',/*cOwner*/,oStruZ0C)
	oModel:AddFields('Z0CMASTER', /*cOwner*/, oStruZ0C, /*bPre*/, { |x| FVldTok(oModel, .F.)}/*bPost*/, /*bLoad*/)
	oModel:AddGrid('Z0DDETAIL', 'Z0CMASTER', oStruZ0D, bZ0DLinePr/*bLinePre*/, { |oModel| FZ0DLok(oModel)}/*bLinePost*/,/*bPre - Grid Inteiro*/,{ |x| FZ0DTok(x)}/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é °ara quem pertence
	oModel:AddGrid('Z0EDETAIL', 'Z0CMASTER', oStruZ0E, /*bLinePre*/,{ |oModel| FZ0ELok(oModel)}/*bLinePost*/,/*bPre - Grid Inteiro*/,{ |x| FZ0ETok(x)}/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é °ara quem pertence

	//oModel:AddGrid( 'Z0DDETAIL', 'Z0CMASTER', oStruZ0D )
	//oModel:AddGrid( 'Z0EDETAIL', 'Z0CMASTER', oStruZ0E )

	oModel:SetPrimaryKey( { "Z0C_FILIAL", "Z0C_CODIGO" } )

	oModel:GetModel('Z0EDETAIL'):SetOptional(.T.)

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'Z0DDETAIL', { { 'Z0D_FILIAL', 'xFilial( "Z0D" )' }, { 'Z0D_CODIGO', 'Z0C_CODIGO' } }, Z0D->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'Z0EDETAIL', { { 'Z0E_FILIAL', 'xFilial( "Z0E" )' }, { 'Z0E_CODIGO', 'Z0C_CODIGO' } }, Z0E->( IndexKey( 1 ) ) )

	//oModel:AddCalc( 'CALC_TOT', 'Z0CMASTER', 'Z0DDETAIL', 'Z0D_QUANT', 'Z0D__TOT01', 'FORMULA', /*{ | oFW | COMP022CAL( oFW, .T. ) }*/,,'Total a Transferir', {|oModel,nTotalAtual,xValor,lSomando| CalcOrigem(oModel,nTotalAtual,xValor,lSomando)} )
	oModel:AddCalc( 'CALC_TOT', 'Z0CMASTER', 'Z0DDETAIL', "Z0D_QUANT", "Z0D__TOT01", "SUM",,, "Total a Transferir")
	// oModel:AddCalc( 'CALC_TOT', 'Z0CMASTER', 'Z0EDETAIL', 'Z0E_QUANT', 'Z0E__TOT02', 'FORMULA', /*{ | oFW | calcTotZ0E( oFW, .T. ) }*/,,'Total Transferido', {|oModel,nTotalAtual,xValor,lSomando| CalcDestino(oModel,nTotalAtual,xValor,lSomando)} )
	oModel:AddCalc( 'CALC_TOT', 'Z0CMASTER', 'Z0EDETAIL', "Z0E_QUANT", "Z0E__TOT02", "SUM",,, "Total Transferido")

	// Adiciona a descriç£¯ do Modelo de Dados
	oModel:SetDescription( 'MOVIMENTACAO DE BOVINOS' )

	// Adiciona a descriç£¯ dos Componentes do Modelo de Dados
	oModel:GetModel( 'Z0CMASTER' ):SetDescription( 'Dados da Movimentacao' )
	oModel:GetModel( 'Z0DDETAIL' ):SetDescription( 'Dados dos Produtos de Origem' )
	oModel:GetModel( 'Z0EDETAIL' ):SetDescription( 'Dados dos Produtos de Destino' )

	//oModel:GetModel( 'Z0CMASTER' ):SetOnlyView( .T. )

	oModel:GetModel( 'Z0DDETAIL' ):SetUniqueLine( { 'Z0D_PROD', 'Z0D_LOTE' } )
	// oModel:GetModel( 'Z0EDETAIL' ):SetUniqueLine( { 'Z0E_PROD', 'Z0E_LOTE', 'Z0E_SEQEFE' } )

	//If Z0C->Z0C_TPMOV == '5'
	// oModel:GetModel( 'Z0EDETAIL' ):SetUniqueLine( { 'Z0E_PROD', 'Z0E_LOTE', 'Z0E_SEQEFE', 'Z0E_RACA', 'Z0E_SEXO', 'Z0E_DENTIC' } )
	oModel:GetModel( 'Z0EDETAIL' ):SetUniqueLine( { 'Z0E_PROD', 'Z0E_LOTE', 'Z0E_CURRAL', 'Z0E_RACA', 'Z0E_SEXO', 'Z0E_DENTIC', 'Z0E_PRDORI', 'Z0E_LOTORI', 'Z0E_SEQEFE' } )
	// Else
	// 	oModel:GetModel( 'Z0EDETAIL' ):SetUniqueLine( { 'Z0E_PROD', 'Z0E_LOTE', 'Z0E_CURRAL', 'Z0E_SEQEFE' } )
	// EndIf
	oModel:GetModel( 'Z0DDETAIL' ):SetNoInsertLine( .T. )
/*
	oModel:GetModel( 'Z0DDETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'Z0DDETAIL' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'Z0DDETAIL' ):SetNoDeleteLine( .T. )

	oModel:GetModel( 'Z0EDETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'Z0EDETAIL' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'Z0EDETAIL' ):SetNoDeleteLine( .T. )
*/
/*
	Atribui o conte?do a um campo do modelo.
	FWFldPut(<cCampo >, <xConteudo >, [ nLinha ], [ oModel ], [ lShowMsg ], [ lLoad ])-> lRet
	oModel:GetModel( 'Z0EDETAIL' ):FWFldPut(<cCampo >, <xConteudo >)

	Obtem o conte?do de um campo do modelo
	FWFldGet(<cCampo >, [ nLinha ], [ oModel ], [ lShowMsg ])-> xRet
*/
	// Retorna o Modelo de dados
Return oModel


Static Function CalcOrigem(oModel,nTotalAtual,xValor,lSomando)
	local nRet := 0
	Local nI		:= 0

	Private oGridZ0D := nil
	oGridZ0D := oModel:GetModel( 'Z0DDETAIL' )

	For nI := 1 To oGridZ0D:Length()
		If !oGridZ0D:IsDeleted()
			nRet += oGridZ0D:GetValue('Z0D_QUANT', nI)
		EndIf
	Next
	Alert('Apagar Alerta 02')

Return nRet

Static Function CalcDestino(oModel,nTotalAtual,xValor,lSomando)
	local nRet 		:= 0
	Local nI		:= 0
	Private oGridZ0D 	:= nil

	oGridZ0D := oModel:GetModel( 'Z0EDETAIL' )
	For nI := 1 To oGridZ0D:Length()
		If !oGridZ0D:IsDeleted()
			nRet += oGridZ0D:GetValue('Z0E_QUANT', nI)
		EndIf
	Next
	Alert('Apagar Alerta 01')

Return nRet

// ======================================================================================= //
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel  := FWLoadModel( 'VAMVCA01' )
	// Cria a estrutura a ser acrescentada na View
	Local oStruZ0C := FWFormStruct( 2, 'Z0C' )
	Local oStruZ0D := FWFormStruct( 2, 'Z0D' )
	Local oStruZ0E := FWFormStruct( 2, 'Z0E' )
	// Inicia a View com uma View ja existente
	Local oView   := FWFormView():New()

	// Altera o Modelo de dados quer será µtilizado
	oView:SetModel( oModel )

	oView:AddField( 'VIEW_Z0C', oStruZ0C, 'Z0CMASTER' )
	oView:AddGrid(  'VIEW_Z0D', oStruZ0D, 'Z0DDETAIL' )
	oView:AddGrid(  'VIEW_Z0E', oStruZ0E, 'Z0EDETAIL' )

	// Cria o objeto de Estrutura
	oCalc1 := FWCalcStruct( oModel:GetModel( 'CALC_TOT') )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddField( 'VIEW_CALC', oCalc1, 'CALC_TOT' )

	oView:AddIncrementField("VIEW_Z0D", "Z0D_SEQ")
	oView:AddIncrementField("VIEW_Z0E", "Z0E_SEQ")

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'EMCIMA'  , 28 )
	oView:CreateHorizontalBox( 'MEIO'    , 31 )
	oView:CreateHorizontalBox( 'EMBAIXO' , 31 )
	oView:CreateHorizontalBox( 'TOTALIZA', 10 )

	// Quebra em 2 "box" vertical para receber algum elemento da view
	oView:CreateVerticalBox( 'MEIOESQ', 90, 'MEIO' )
	oView:CreateVerticalBox( 'MEIODIR', 10, 'MEIO' )

	// Quebra em 2 "box" vertical para receber algum elemento da view
	oView:CreateVerticalBox( 'EMBAIXOESQ', 90, 'EMBAIXO' )
	oView:CreateVerticalBox( 'EMBAIXODIR', 10, 'EMBAIXO' )

	// Relaciona o identIficador (ID) da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_Z0C' , 'EMCIMA'    )
	oView:SetOwnerView( 'VIEW_Z0D' , 'MEIOESQ'      )
	oView:SetOwnerView( 'VIEW_Z0E' , 'EMBAIXOESQ')
	oView:SetOwnerView( 'VIEW_CALC', 'TOTALIZA')

	// Liga a identIficacao do componente
	oView:EnableTitleView( 'VIEW_Z0C' , "DADOS DA MOVIMENTAÇƒO" )
	oView:EnableTitleView( 'VIEW_Z0D' , "PRODUTOS DE ORIGEM"  )
	oView:EnableTitleView( 'VIEW_Z0E' , "PRODUTOS DE DESTINO" )
	oView:EnableTitleView( 'VIEW_CALC', "TOTAIS" )

	// Acrescenta um objeto externo ao View do MVC
	// AddOtherObject(cFormModelID,bBloco)
	// cIDObject - Id
	// bBloco    - Bloco chamado devera ser usado para se criar os objetos de tela externos ao MVC.

	oView:AddOtherObject("OTHER_PANEL_O", {|oPanel| MVCA01BUT(oPanel)})
	oView:AddOtherObject("OTHER_PANEL_D", {|oPanel| })

	// Associa ao box que ira exibir os outros objetos
	oView:SetOwnerView("OTHER_PANEL_O",'MEIODIR')
	oView:SetOwnerView("OTHER_PANEL_D",'EMBAIXODIR')

	//Adiciona botã¯ de efetivar ao Enchoice
	oView:AddUserButton( 'Efetivar Movimentação', 'WEB', {|oView| FWMsgRun(, {|| FZ0ELok(oModel) .AND. ProcGrid( oModel, oView ) }, "Processando", "Efetivando Movimentação ...") } )
	oView:AddUserButton( 'Adicionar lotes origem', 'WEB', {|oView| MrkLotes(.T.)} )

	// MB : 02.08.2019
	oView:AddUserButton( 'Definir Novo Lote'     , 'WEB', {|oView| U_NewLotes( "M->Z0E_LOTE" ) } )
	oView:SetCloseOnOk( { |oView| .T. } )

	SetKey(VK_F6, {|| FWMsgRun(, {|| U_NewLotes( "M->Z0E_LOTE" ) }, "Processando", "Pequisando Lote Disponivel ...") })
	// SetKey(VK_F7, {|| FWMsgRun(, {|| StaticCall(VAMVCA01, CopyLine ) }, "Processando", "Copiando Linha ...") })

Return oView


 /*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 07.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Copiar linha acima; Se for a 1? chamar nova linha;	   			   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   : funcao nao da certo, por definicao da rotina. só ¤¡ria certo se o BOV for dIferente. |
 |            -> Processo (ideia) cancelado por enquanto.                          |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '--------------------------------------------------------------------------------*/
/*
Static Function CopyLine()
	Local oView  	 := FWViewActive()
	Local oModel    := FWModelActive()
	Local oGridModel := oModel:GetModel('Z0EDETAIL')
	Local nLen		 := 0
	Local cLote := "", cCurral := ""

	If (nLen:=oGridModel:Length()) == 1
			NewLotes()
	Else
			oGridModel:GoLine( nLen-1 )
			cLote  := oGridModel:GetValue('Z0E_LOTE')
			cCurral := oGridModel:GetValue('Z0E_CURRAL')

			oGridModel:GoLine( nLen )
			oGridModel:SetValue('Z0E_LOTE', cLote   )
			oGridModel:SetValue('Z0E_CURRAL', cCurral )
	EndIf

		oView:Refresh()
	Return nil*/

User Function LoadCpoVirtual(_cFilial, cProduto, cOrigem)
	Local cRet	   := "" // "MIGUEL " + Time()
	Local _cQry    := ""
	Default cOrigem := ""

	_cQry := " SELECT ZCC_NOMFOR FORNECEDOR, ZCC_NOMCOR CORRETOR " + CRLF
	_cQry += " FROM	  ZCC010 ZCC " + CRLF
	_cQry += "   JOIN ZBC010 ZBC " + CRLF
	_cQry += "    	ON ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO AND ZCC.D_E_L_E_T_=' ' AND ZBC.D_E_L_E_T_=' '" + CRLF
	_cQry += " WHERE  ZBC_FILIAL='" + _cFilial+ "'" + CRLF
	_cQry += "    AND ZBC_PRODUT='" + cProduto+ "'" + CRLF

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)

	If !TEMPSQL->(Eof())
		If ReadVar() == "M->Z0D_CORRET" .OR. ReadVar() == "M->Z0E_CORRET" .OR. ( ReadVar() == "M->Z0E_PROD" .AND. cOrigem=="C" )
			cRet := SubS( TEMPSQL->CORRETOR, 1, TamSx3(StrTran(ReadVar(),"M->",""))[1])
		ElseIf ReadVar() == "M->Z0D_FORNEC" .OR. ReadVar() == "M->Z0E_FORNEC" .OR. ( ReadVar() == "M->Z0E_PROD" .AND. cOrigem=="F" )
			cRet := SubS( TEMPSQL->FORNECEDOR, 1, TamSx3(StrTran(ReadVar(),"M->",""))[1])
		EndIf
	EndIf
	TEMPSQL->(DbCloseArea())

Return cRet

 /*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 08.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Funç£¯ para verficar o tipo de curral: a SB8; 1=Baia;4=Pasto;		   |
 |             Tipo Recebimento só °¯de ser Curral;                                |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '--------------------------------------------------------------------------------*/
User Function CurPastoOuBaia( cCurral )
	Local cRet := ""
	Local lRet	:= .T.

	If (lRet := Existcpo("Z08", cCurral))    // Existcpo("Z08",FwFldGet('Z0E_CURRAL'))
		If 	FWFldGet("Z0C_TPMOV") == "2" .AND. ;
				( cRet:=Posicione('Z08', 1, xFilial('Z08')+cCurral, 'Z08_TIPO') ) == "4" // 1=BAIA | 4=PASTO

			// Aviso("Aviso", ;
			// 	  'A Tipo de Movimentação selecionada: APARTAÇÃO deve ser transferido para um CURRAL do tipo PASTO.', ;
			// 	  {"Sair"} )

			lRet:=MsgYesNo( 'Um tipo de Movimentação do tipo APARTAÇÃO não deveria ser transferido para um CURRAL do tipo PASTO.' + CRLF + 'Deseja continuar ?' )
			EndIf
	Else
		MsgInfo("O Curral: " + AllTrim(cCurral) + " não se encontra cadastrado.")
	EndIf
Return lRet

 /*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 02.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Funç£¯ para buscar um lote disponivel na SB8; 					   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '--------------------------------------------------------------------------------*/
User Function NewLotes( __cCampo )
	Local cLote     := "" // AllTrim( U_DispLoteSB8() )
	Local lOk		 := .T.
	Local oView  	 := FWViewActive()
	local oModel    := FWModelActive()
	local oGridModel := oModel:GetModel('Z0EDETAIL')
	Local lContinua	 := .T.
	Local lRet		 := .T.
	Local cAux		 := ""

	If oModel:nOperation == 4 .and. FWFldGet("Z0C_TPMOV") <> '4'

		If IsInCallStack( "Selecao" )
			cAux := &(ReadVar())
		Else
			cAux     := AllTrim(oGridModel:GetValue('Z0E_LOTE') )
			If !Empty(cAux)
				lContinua := Empty( POSICIONE('SX5', 1, xFilial('SX5')+'Z8'+SubS(cAux, 1, At("-",cAux)-1), 'X5_DESCRI') )
			EndIf
		EndIf
		cLote := AllTrim( U_DispLoteSB8( "TABELA",;
								         oGridModel:GetValue('Z0E_CODIGO'),;
								         FWFldGet("Z0C_TPMOV") ) )

		If lContinua .and. ( Empty(cAux) .or. cAux<>cLote )

			If U_libVldLote( cLote, .T. /* , Z0C->Z0C_TPMOV */, __cCampo )
				If IsInCallStack( "Selecao" )
					lRet := .T.
					If !Empty(cLote) .and.;
							!Empty(oGetDadRan:aCols[ oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_LOTE"})]) .and.;
							oGetDadRan:aCols[ oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_LOTE"})] <> cLote

							If lRet := MsgYesNo( 'O lote: ' +;
								AllTrim(oGetDadRan:aCols[ oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_LOTE"})]) +;
								' jáe encontra reservado.' +;
								CRLF +;
								'Deseja liberar esse lote e substituir pelo lote:? ' + cLote)

								If (TCSqlExec("DELETE FROM SX5010 WHERE X5_TABELA='Z8' AND RTRIM(X5_DESCRI) = '" +;
									AllTrim(oGetDadRan:aCols[ oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_LOTE"})]) + "'" ) < 0)

								ConOut("Erro ao liberar lote: " + AllTrim(oGetDadRan:aCols[ oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_LOTE"})]) + CRLF + TCSQLError())
								EndIf

						Else
							If (TCSqlExec("DELETE FROM SX5010 WHERE X5_TABELA='Z8' AND RTRIM(X5_DESCRI) = '" +;
									AllTrim(cLote) + "'" ) < 0)

								ConOut("Erro ao liberar lote: " + cLote + CRLF + TCSQLError())
							EndIf
						EndIf
					EndIf
					If lRet
						oGetDadRan:aCols[ oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_LOTE"})] := cLote
						U_SalvarRange()
					EndIf
				Else
					lOk  := oGridModel:SetValue('Z0E_LOTE', cLote )
				EndIf
				oView:Refresh()
			EndIf
			// Alert('New Lote: ' + cLote + '.' )
		Else
			MsgInfo("O lote: " + cAux + " jáe encontra selecionado.")
		EndIf
	EndIf

Return nil


//-------------------------------------------------------------------
Static Function MVCA01BUT( oPanel )
Local oModel := FWModelActive()
Local oView  := FWViewActive()

	// Local lOk := .F.
	// Ancoramos os objetos no oPanel passado
	@ 10, 10 Button 'Pesar'   			Size 56, 13 Message 'Pesar' 	       Pixel Action Selecao(oModel, oView) of oPanel
	@ 30, 10 Button 'Adicionar Origem'  Size 56, 13 Message 'Adicionar Origem' Pixel Action MrkLotes(.T.) of oPanel

Return NIL

/*Static Function Teste()
Local oModel := FWModelActive()
Local oView := FWViewActive()
Local nI := 0
Local nJ := 0
Local lRet := .T.

oGridZ0E := oModel:GetModel( 'Z0EDETAIL' )
n1 := oGridZ0E:AddLine()
oView:Refresh()

Return*/

Static Function FZ0DLok(oModel)
	// Local oModel := FWModelActive()
	local nQuant := FWFldGet('Z0D_QUANT')
	local nQtdOri := FWFldGet('Z0D_QTDORI')

	If nQtdOri < nQuant
		Alert("Quantidade de origem não pode ser maior que o saldo atual dos produtos.")
		Return .F.
	EndIf

	//FWFormCommit( oModel )
Return(.T.)

Static Function FVldTok(oModel, lHard)
	// Local oModel      := FWModelActive()
	// Local oView       := FWViewActive()
	Local nI          := 0
	Local nJ          := 0
	Local  oGridZ0D  := oModel:GetModel( 'Z0DDETAIL' )
	Local  oGridZ0E  := oModel:GetModel( 'Z0EDETAIL' )

	Private aOrigens  := {}
	Private aDestinos := {}

	Default lHard     := .F.

	for nI := 1 To oGridZ0E:Length()
		oGridZ0E:GoLine( nI )

		If !oGridZ0E:IsDeleted()

			// If Empty( oGridZ0E:GetValue('Z0E_SEQEFE', nI) )
			// 	loop
			// EndIf

			nP := aScan(aDestinos, { |x| x[1]=oGridZ0E:GetValue('Z0E_PROD', nI)})
			If nP = 0
				aAdd(aDestinos, {oGridZ0E:GetValue('Z0E_PROD', nI), oGridZ0E:GetValue('Z0E_QUANT', nI)})
			else
				aDestinos[nP, 2] += oGridZ0E:GetValue('Z0E_QUANT', nI)
			EndIf

		EndIf
	Next

	for nI := 1 to oGridZ0D:Length()
		If !oGridZ0D:IsDeleted()

			nP := aScan(aOrigens, { |x| x[1]=oGridZ0D:GetValue('Z0D_PROD', nI)})
			If nP = 0
				aAdd(aOrigens, {oGridZ0D:GetValue('Z0D_PROD', nI), oGridZ0D:GetValue('Z0D_QUANT', nI)})
			else
				aOrigens[nP, 2] += oGridZ0D:GetValue('Z0D_QUANT', nI)
			EndIf

		EndIf
	Next

	for nI := 1 to len(aDestinos)
		nOco := 0
		for nJ := 1 to len(aOrigens)
			If aDestinos[nI, 1] = aOrigens[nJ, 1]
				nOco++
				If lHard
					If aDestinos[nI, 2] != aOrigens[nJ, 2]
						msgAlert("A quantidade do produto [" + AllTrim(aDestinos[nI, 1]) + " ] no destino é ¤iferente da quantidade na origem.")
						Return .F.
					EndIf
				else
					If aDestinos[nI, 2] > aOrigens[nJ, 2]
						msgAlert("A quantidade do produto [" + AllTrim(aDestinos[nI, 1]) + " ] no destino é superior à ±uantidade na origem.")
						Return .F.
					EndIf
				EndIf
			EndIf
		Next

		If nOco = 0 .AND. !(/* FwFldGet('Z0C_TPMOV') */Z0C->Z0C_TPMOV $ "25") .and. !Empty(aDestinos[nI, 1])
			msgAlert("O produto [" + AllTrim(aDestinos[nI, 1]) + " ] no destino não foi encontrado na origem.")
			Return .F.
		EndIf
	Next

Return (.T.)

// -------------------------------------------------------------------------------------------------------------
Static Function FZ0DLPre()
Return(.T.)

// -------------------------------------------------------------------------------------------------------------
Static Function FZ0DTok()
Return(.T.)

// -------------------------------------------------------------------------------------------------------------
Static Function FZ0ELok(oModel)
Local oModel := FWModelActive()
Local lRet   := .T.

	If Z0C->Z0C_TPMOV == '4' .AND.; // Apartação
		Empty( FwFldGet( 'Z0E_OBS' ) )

		MsgAlert("Campo observaç£¯ não preenchido na linha: " + cValToChar(oModel:GetModel( 'Z0EDETAIL' ):nLine ))
		lRet := .F.
	EndIf

Return lRet

// -------------------------------------------------------------------------------------------------------------
static function Z0DLinPreG( oGridZ0D, nLin, cOperacao, cCampo, xValAtr, xValAnt)
local aArea    := GetArea()
Local oModel   := FWModelActive()
Local oGridZ0E := oModel:GetModel( 'Z0EDETAIL' )
local lRet     := .T.
Local nI       := 0

	if cOperacao == "DELETE"

		nI := 1 
		While lRet .AND. nI <= oGridZ0E:Length()
			oGridZ0E:GoLine( nI )
			If !oGridZ0E:IsDeleted()
				If (FwFldGet('Z0D_PROD') == oGridZ0E:GetValue('Z0E_PROD', nI))
					Alert('O produto: '+FwFldGet('Z0D_PROD')+' esta sendo utilizado no destino (na linha ' + cValToChar(nI) + ') e por isso não pode ser excluï¿½ na tabela de origem.')
					lRet := .F.
				EndIf
			EndIf
			nI += 1
		EndDo

	// ElseIf cOperacao == "UNDELETE"
	// 	Alert("UNDELETE")
	// elseif cOperacao == "SETVALUE"
	// 	Alert("SETVALUE")
	EndIf

	if !Empty(aArea)
    	RestArea(aArea)
	EndIf
Return lRet

// -------------------------------------------------------------------------------------------------------------
Static Function FZ0ELPre()
	Local oModel := FWModelActive()
	//só °¥rmite a efetivaç£¯ se a quantidade de origem e destino estiverem iguais
	If FWFldGet('Z0E__TOT02')>=FWFldGet('Z0D__TOT01')
		alert('Já foram informadas destinos suficientes para atender as origens especIficadas, verIfique as quantidades informadas.')
		Return .F.
	EndIf
Return(.T.)

// -------------------------------------------------------------------------------------------------------------
Static Function FZ0ETok()
Return(.T.)


//Rotina que processa a movimentacao
Static Function ProcGrid( oModel, oView)
	Local aArea       := GetArea()
	Local aAreaSB1    := SB1->(GetArea())
	// Local aSaveLines  := FWSaveRows()
	Local cTimeIni    := Time()
	// Local oModel   := FWModelActive()
	// Local oView    := FWViewActive()
	Local nI          := 0
	Local nJ          := 0
	// Local nDes     := 0
	// Local lErro    := .F.
	Local lTransf     := .F.
	Local lCriaBov    := .F.
	
	Local lControl	  := .T.
	Local aStruZ0E	  := {}

	Local __nPPrd     := 0
	Local __cProd     := ""
	Local __cLote     := ""

	Local nPHZ0EPROD  := 0
	Local nPHZ0EORIG  := 0
	Local nPHZ0ERACA  := 0
	Local nPHZ0ESEXO  := 0
	Local nPHZ0EDENT  := 0

	// Local lRet     := .T.
	// Local oGridZ0D := nil, nIZ0D := 0
	// Local oGridZ0E := nil, nIZ0E := 0

	Private oGridZ0D  := nil
	Private oGridZ0E  := nil
	Private aSvLn1  := nil
	Private aSvLn2  := nil
	Private aOrigens  := {}
	Private aTransf   := {}

	Private aMedPond  := {}

	ConOut('Inicio: ProcGrid ' + Time() )

	If oModel:nOperation <> 4
		msgAlert("Esta operação não pode ser realizada neste modo de edição.")
		Return .F.
	EndIf

	If !Z0C->Z0C_STATUS /*FWFldGet\("Z0C_STATUS"\)*/ $ '14'
		msgAlert('só é possï¿½l efetivar Movimentações em aberto.')
		Return .F.
	EndIf

	//só °¥rmite a efetivaç£¯ se a quantidade de origem e destino estiverem iguais
	nQtdOri := oModel:GetValue("CALC_TOT","Z0D__TOT01")
	nQtdDes := oModel:GetValue("CALC_TOT","Z0E__TOT02")
	If nQtdOri<=0
		alert('não hárigens informadas favor, informe uma origem para continuar.')
		Return .F.
	EndIf

	lHard := .T.
	If FwFldGet('Z0C_TPMOV') != "2" //se nao for apartacao
		If nQtdOri<>nQtdDes
			alert('As quantidades de origem e destino estã¯ diferentes, não é °ossï¿½l efetivar a Movimentação.')
			Return .F.
		EndIf
	else
		If nQtdOri<nQtdDes
			alert('A quantidade de origem não pode ser menor que a quantidade de destino, não é °ossï¿½l efetivar a Movimentação.')
			Return .F.
		EndIf
		lHard := .F.
	EndIf

	If empty(FWFldGet("Z0C_DATA"))
		alert('Informe uma data para a Movimentação.')
		Return .F.
	EndIf

	If (FWFldGet("Z0C_DATA") > DATE())
		alert('Data para a Movimentação não pode ser maior que a data atual.')
		Return .F.
	EndIf

	If !FVldTok(oModel, lHard)
		Return .F.
	EndIf

	//IdentIfica os produtos de destino e salva a quantidade necessá²©a
	oGridZ0D   := oModel:GetModel( 'Z0DDETAIL' )
	//aSvLn2   := FWSaveRows()
	oGridZ0E   := oModel:GetModel( 'Z0EDETAIL' )
	//aSvLn1   := FWSaveRows()

	nPHZ0EPROD := aScan(oGridZ0E:aHeader,{|x|AllTrim(x[2])=="Z0E_PROD"})
	nPHZ0EORIG := aScan(oGridZ0E:aHeader,{|x|AllTrim(x[2])=="Z0E_PRDORI"}) // PRODUTO ORIGEM: Z0D
	nPHZ0ERACA := aScan(oGridZ0E:aHeader,{|x|AllTrim(x[2])=="Z0E_RACA"})
	nPHZ0ESEXO := aScan(oGridZ0E:aHeader,{|x|AllTrim(x[2])=="Z0E_SEXO"})
	nPHZ0EDENT := aScan(oGridZ0E:aHeader,{|x|AllTrim(x[2])=="Z0E_DENTIC"})

	For nI := 1 To oGridZ0E:Length()
		oGridZ0E:GoLine( nI )

		If !oGridZ0E:IsDeleted()
			If empty(FwFldGet('Z0E_CURRAL', nI))
				Alert("O campo curral deve estar preenchido na linha [" + cValToChar(nI) + " ]")
				FWRestRows( aSvLn1 )
				FWRestRows( aSvLn2 )
				Return .F.
			EndIf
		EndIf
	Next

For nI := 1 To oGridZ0E:Length()
		oGridZ0E:GoLine( nI )

		If !oGridZ0E:IsDeleted()
			If empty(FwFldGet('Z0E_DATACO', nI))
				Alert("O campo DATA DE INICIO deve ser preenchido na linha [" + cValToChar(nI) + " ]")
				FWRestRows( aSvLn1 )
				FWRestRows( aSvLn2 )
				Return .F.
			EndIf
		EndIf
	Next

	// FVldTok
	// MB: 22.05.2019 - validacao para nao permitir DIfERENTES lotes para IGUAIS currais;
	cMsg := ""
	cMsg2 := ""
	for nI := 1 To oGridZ0E:Length()
		oGridZ0E:GoLine( nI )

		If !oGridZ0E:IsDeleted() .and. Empty(oGridZ0E:GetValue('Z0E_SEQEFE', nI))

			BeginSQL alias "cAliasVld"
			%noParser%
			SELECT  B8_LOTECTL, COUNT(B8_LOTECTL) QTDREG
			FROM	%table:SB8% SB8
			WHERE	B8_FILIAL  =  %xFilial:SB8%
				AND B8_LOTECTL <> %exp:oGridZ0E:GetValue('Z0E_LOTE', nI)%
				AND B8_X_CURRA =  %exp:oGridZ0E:GetValue('Z0E_CURRAL', nI)%
				AND B8_SALDO   >  0
				AND SB8.%notDel%
			GROUP BY B8_LOTECTL
			ORDER BY B8_LOTECTL
			EndSQL
			If !cAliasVld->(Eof())
				cMsg  += CRLF + "Curral: " + AllTrim(oGridZ0E:GetValue('Z0E_CURRAL', nI)) + ", lotes: "
				cMsg2 := ""
				While !cAliasVld->(Eof())
					cMsg2 += iIf(Empty(cMsg2),"",", ") + IIf( AT(AllTrim(cAliasVld->B8_LOTECTL), cMsg2)==0, AllTrim(cAliasVld->B8_LOTECTL), "")
					cAliasVld->(DbSkip())
				EndDo
				cMsg  += cMsg2
			EndIf
			cAliasVld->(dbCloseArea())

		EndIf
	Next nI
	If !Empty(cMsg2)
		msgAlert("Curral já cupados: " + cMsg + CRLF +;
			'Esta operação será cancelada.')
		Return .F.
	EndIf

	
		// FVldTok
	// MB: 22.05.2019 - validacao para nao permitir DIfERENTES lotes para IGUAIS currais;
	cMsg := ""
	cMsg3 := ""
	for nI := 1 To oGridZ0E:Length()
		oGridZ0E:GoLine( nI )
//TODO TOSHIO - VALIDAR CURRAL SE ESTA CORRETO

		If !oGridZ0E:IsDeleted()

			BeginSQL alias "cAliasVld"
			%noParser%
			SELECT  B8_LOTECTL, B8_X_CURRA, COUNT(B8_LOTECTL) QTDREG
			FROM	%table:SB8% SB8
			WHERE	B8_FILIAL  =  %xFilial:SB8%
				AND B8_LOTECTL = %exp:oGridZ0E:GetValue('Z0E_LOTE', nI)%
				AND B8_X_CURRA <>  %exp:oGridZ0E:GetValue('Z0E_CURRAL', nI)%
				AND B8_SALDO   >  0
				AND SB8.%notDel%
				AND B8_LOTECTL NOT IN ( SELECT DISTINCT Z0D_LOTE
										  FROM %table:Z0D% Z0D
										 WHERE Z0D_FILIAL =  %xFilial:Z0D%
										   AND Z0D_CODIGO = %exp:oGridZ0E:GetValue('Z0E_CODIGO', nI)%
										   AND Z0D.%notDel%
									  ) 
			GROUP BY B8_LOTECTL, B8_X_CURRA
			ORDER BY B8_LOTECTL
			EndSQL
			If !cAliasVld->(Eof())
				cMsg  += CRLF + "Lote: " + AllTrim(oGridZ0E:GetValue('Z0E_LOTE', nI)) + ",  "
				cMsg3 := ""
				While !cAliasVld->(Eof())
					cMsg3 += iIf(Empty(cMsg3),"",", ") + IIf( AT(AllTrim(cAliasVld->B8_LOTECTL), cMsg3)==0, AllTrim(cAliasVld->B8_LOTECTL), "")
					cAliasVld->(DbSkip())
				EndDo
				cMsg  += cMsg3
			EndIf
			cAliasVld->(dbCloseArea())

		EndIf
	Next nI
	If !Empty(cMsg3)
		msgAlert("Lote alocado em outro curral, corrija a Movimentação: " + cMsg + CRLF +;
			'Esta operação será cancelada.')
		Return .F.
	EndIf
	
	/*
	TODO - 


		cMsgC := ""
	cMsgC1 := ""
	for nI := 1 To oGridZ0E:Length()
		oGridZ0E:GoLine( nI )
//TODO TOSHIO - VALIDAR CURRAL SE ESTA CORRETO
Lotel cSql := ""
		If !oGridZ0E:IsDeleted()

			cAlias := CriaTrab(,.t.)

			cSql := " WITH ORIGEM AS ( " + CRLF +;
                         "   SELECT Z0D_LOTE, SUM(Z0D_QTDORI) QTDORI " + CRLF +;
                         "     FROM " + retSQLName("Z0D") + " Z0D " + CRLF +;
                         "    WHERE Z0D_FILIAL = '" + xFilial("Z0D")+ "' " + CRLF +;
                         "      AND Z0D_CODIGO = '"+oGridZ0E:GetValue('Z0E_CODIGO', nI)+"' " + CRLF +;
                         " 	 AND Z0D.D_E_L_E_T_ = ' '  " + CRLF +;
                         " 	 GROUP BY Z0D_LOTE  " + CRLF +;
                         " ) " + CRLF +;
                         " , DESTINO AS ( " + CRLF +;
                         "   SELECT Z0E_LOTORI, Z0E_CURRAL, SUM(Z0E_QUANT) QTDDES " + CRLF +;
                         "     FROM " + retSQLName("Z0E") + " Z0E " + CRLF +;
                         "    WHERE Z0E_FILIAL = '" + xFilial("SB8")+ "' " + CRLF +;
                         "      AND Z0E_CODIGO = '"+oGridZ0E:GetValue('Z0E_CODIGO', nI)+"' " + CRLF +;
                         " 	 AND Z0E.D_E_L_E_T_ = ' '  " + CRLF +;
                         " GROUP BY Z0E_LOTORI, Z0E_CURRAL " + CRLF +;
                         " ) " + CRLF +;
                         "   SELECT DISTINCT B8_LOTECTL, B8_X_CURRA " + CRLF +;
                         "     FROM " + retSQLName("SB8") + " SB8 " + CRLF +;
                         " 	JOIN DESTINO Z0E ON " + CRLF +;
                         " 	     Z0E_LOTORI = B8_LOTECTL " + CRLF +;
                         "    WHERE B8_FILIAL = '" + xFilial("SB8")+ "' " + CRLF +;
                         "      AND B8_SALDO > 0 " + CRLF +;
                         " 	 AND D_E_L_E_T_ = ' '  " + CRLF +;
                         " 	 AND B8_X_CURRA = Z0E_CURRAL " + CRLF +;
                         " 	 GROUP BY B8_LOTECTL, B8_X_CURRA, Z0E.QTDDES, Z0E_CURRAL " + CRLF +;
                         " 	 HAVING SUM(B8_SALDO) > Z0E.QTDDES " + CRLF

			dbUseArea(.T.,'TOPCONN',TCGENQRY(,, cSql ),(cAlias),.F.,.F.)

			While !Eof() .And. 


			
			SELECT  B8_LOTECTL, B8_X_CURRA, COUNT(B8_LOTECTL) QTDREG
			FROM	%table:SB8% SB8
			WHERE	B8_FILIAL  =  %xFilial:SB8%
				AND B8_LOTECTL = %exp:oGridZ0E:GetValue('Z0E_LOTE', nI)%
				AND B8_X_CURRA <>  %exp:oGridZ0E:GetValue('Z0E_CURRAL', nI)%
				AND B8_SALDO   >  0
				AND SB8.%notDel%
				AND B8_LOTECTL NOT IN ( SELECT Z0D_LOTE
										  FROM %table:Z0D% Z0D
										 WHERE Z0D_FILIAL =  %xFilial:Z0D%
										   AND Z0D_CODIGO = %exp:oGridZ0E:GetValue('Z0E_CODIGO', nI)%
										   AND Z0D.%notDel%
									  ) 
			GROUP BY B8_LOTECTL, B8_X_CURRA
			ORDER BY B8_LOTECTL
			EndSQL
			If !cAliasVld->(Eof())
				cMsg  += CRLF + "Lote: " + AllTrim(oGridZ0E:GetValue('Z0E_LOTE', nI)) + ",  "
				cMsg3 := ""
				While !cAliasVld->(Eof())
					cMsg3 += iIf(Empty(cMsg3),"",", ") + IIf( AT(AllTrim(cAliasVld->B8_LOTECTL), cMsg3)==0, AllTrim(cAliasVld->B8_LOTECTL), "")
					cAliasVld->(DbSkip())
				EndDo
				cMsg  += cMsg3
			EndIf
			cAliasVld->(dbCloseArea())

		EndIf
	Next nI
	If !Empty(cMsg4)
		msgAlert("Lote alocado em outro curral, corrija a Movimentação: " + cMsg + CRLF +;
			'Esta operação será cancelada.')
		Return .F.
	EndIf
		
	*/


	// MB : 12.05.2020
	// na apartacao tbm tera de criar NOVOS bovs
	If (FWFldGet("Z0C_TPMOV")=='2' .OR. FWFldGet("Z0C_TPMOV")=='5')
		If (GetMV("VA_EFETZ0F",,.T.) .and. Z0C->Z0C_TPMOV/*FWFldGet\("Z0C_TPMOV"\)*/=='2') // Apartação
			// Forç¡² recarregar a Z0E - Atualiza Z0E a partir da Z0F
			// modelo : calcular_destino()

			fReLoadZ0E(oModel, oView)
			//Return .T.
		EndIf

		/* 
			MB : 10.06.2020

			estou levando a criacao dos BOVS para a hora da montagem da matriz de transferencia;
		If Processa({|| lErro := vldMB001(oView, oModel, @oGridZ0D, @oGridZ0E) },;
				 "Processamento para criaç£¯ de BOVS...")
			Return .F.
			EndIf */
	EndIf

	BeginSQL alias "QSEQ"
		%noParser%
		select isnull(max(Z0E_SEQEFE),'    ') Z0E_SEQEFE
		from %table:Z0E% z
		where Z0E_FILIAL=%xFilial:Z0E%
		and Z0E_CODIGO=%exp:Z0C->Z0C_CODIGO%
		and z.%notDel%
	EndSQL
	If !QSEQ->(Eof())
		If QSEQ->Z0E_SEQEFE == '    '
			cSeqEfe := '0001'
		else
			cSeqEfe := Soma1(QSEQ->Z0E_SEQEFE)
		EndIf
	EndIf
	QSEQ->(DbCloseArea())

	Begin Transaction
		For nJ := 1 To oGridZ0D:Length()
			oGridZ0D:GoLine( nJ )
			If !oGridZ0D:IsDeleted()
				aAdd(aOrigens, { FWFldGet('Z0D_PROD'  , nJ),; // 01
				FWFldGet('Z0D_LOTE'  , nJ),; // 02
				FWFldGet('Z0D_QUANT' , nJ),; // 03
				FWFldGet('Z0D_CURRAL', nJ),; // 04
				FWFldGet('Z0D_RACA'  , nJ),; // 05
				FWFldGet('Z0D_SEXO'  , nJ),; // 06
				FWFldGet('Z0D_DENTIC', nJ)}) // 07
			EndIf
		Next

		DbSelectArea('Z0F')
		Z0F->(DbSetOrder(1))

		//Percorre cada produto de destino
		__cAntProd  := ""
		_cAntChvZ0E := ""
		For nI := 1 To oGridZ0E:Length()	// Z0E <-> Destino
			oGridZ0E:GoLine( nI )

			ConOut("ProcGrid: " + PadL( nI, 3, '0') + "/" + PadL( oGridZ0E:Length(), 3, '0') +' '+;
				oGridZ0E:GetValue('Z0E_SEQ'   , nI) + ' ' +;
				oGridZ0E:GetValue('Z0E_PROD'  , nI) + ' ' +;
				oGridZ0E:GetValue('Z0E_RACA'  , nI) + ' ' +;
				oGridZ0E:GetValue('Z0E_SEXO'  , nI) + ' ' +;
				oGridZ0E:GetValue('Z0E_DENTIC'  , nI) + ' ' +;
				'Deletado: ' + CVALTOCHAR( oGridZ0E:IsDeleted() ) )
			lTransf := .T.
			If !oGridZ0E:IsDeleted()
				nQtdTr := 0
				// while nQtdTr < oGridZ0E:GetValue('Z0E_QUANT', nI) //FWFldGet('Z0E_QUANT', nI)
				for nJ := 1 to len(aOrigens) // Z0D

					// a linha de comparacao dos BOVs, na Z0D e Z0E nao pode ser retirada;
					__cProd := Iif(Empty(oGridZ0E:GetValue('Z0E_PRDORI' , nI)), oGridZ0E:GetValue('Z0E_PROD' , nI), oGridZ0E:GetValue('Z0E_PRDORI' , nI))
					__cLote := Iif(Empty(oGridZ0E:GetValue('Z0E_LOTORI' , nI)), oGridZ0E:GetValue('Z0E_LOTE' , nI), oGridZ0E:GetValue('Z0E_LOTORI' , nI)) // oGridZ0E:GetValue('Z0E_LOTORI' , nI)
					If aOrigens[nJ,1] == __cProd .and. iIf(Z0C->Z0C_TPMOV$('2'), aOrigens[nJ, 2] == __cLote, .T.)

						//tirei no dia 01.09, erro na mov 6994 .or. Z0C->Z0C_TPMOV $ ("13")vou 
						If Empty(oGridZ0E:GetValue('Z0E_SEQEFE' , nI))

							lCriaBov := .F.
							cChvZ0D := aOrigens[nJ, 5] + aOrigens[nJ, 6] + cValToChar(aOrigens[nJ, 7]) // cChvZ0D := oGridZ0D:GetValue('Z0D_RACA',nIZ0D) + oGridZ0D:GetValue('Z0D_SEXO',nIZ0D) + cValToChar(oGridZ0D:GetValue('Z0D_DENTIC',nIZ0D))
							cChvZ0E := oGridZ0E:GetValue('Z0E_RACA', nI) + oGridZ0E:GetValue('Z0E_SEXO', nI) // + cValToChar(oGridZ0E:GetValue('Z0E_DENTIC', nI))
							If Z0C->Z0C_TPMOV == "2" // Apartação
								// If cChvZ0D <> cChvZ0E // retirada esse if, o controle estara novamente sendo validado logo abaixo pela SKYNET. definindo se cria novo bov ou usa existente
								lCriaBov := .T.
								//Else
								//	Alert('Chaves iguais')
								//	ConOut('Chaves iguais')
								// EndIf
							ElseIf Z0C->Z0C_TPMOV == "5" // Re-Classificaç£¯
								If cChvZ0D == cChvZ0E
									// nQtdTr += oGridZ0E:GetValue('Z0E_QUANT' , nI)
									aOrigens[nJ,3] -= oGridZ0E:GetValue('Z0E_QUANT' , nI)
									lTransf := .F. // nao precisa - apagar depois
									lCriaBov := .F.
								Else
									lCriaBov := .T.
								EndIf
							EndIf

							If aOrigens[nJ,3] > 0

								If Empty(oGridZ0E:GetValue('Z0E_PRDORI', nI))
									// Guardando SB1 Original
									oGridZ0E:LoadValue('Z0E_PRDORI', oGridZ0E:GetValue('Z0E_PROD', nI) )
									oGridZ0E:LoadValue('Z0E_LOTORI', aOrigens[nJ, 2] ) // lote
								Else
									SB1->(DbSetOrder(1))
									SB1->(DbSeek( xFilial('SB1') + oGridZ0E:GetValue('Z0E_PROD', nI) ))
									lCriaBov := .F.
									lTransf  := .T.
								EndIf

								// If lCriaBov
								__nPPrd := 0
								__cProd := oGridZ0E:GetValue('Z0E_PROD', nI) // __cProd := Iif(Empty(oGridZ0E:GetValue('Z0E_PRDORI' , nI)), oGridZ0E:GetValue('Z0E_PROD' , nI), oGridZ0E:GetValue('Z0E_PRDORI' , nI))
								If __cAntProd == __cProd .and. _cAntChvZ0E == cChvZ0E
									lCriaBov := .F.
									__cProd  := AllTrim( SB1->B1_COD )
								ElseIf (lCriaBov .or. Z0C->Z0C_TPMOV $ ("134")) .and. AllTrim(__cProd)<>AllTrim(SB1->B1_COD)
									SB1->(DbSetOrder(1))
									SB1->(DbSeek( xFilial('SB1') + __cProd ))
								EndIf
								If lCriaBov
									if !(lTransf := !U_SB1Create( { xFilial("SB1"),;			// [01] Filial
										AllTrim(SB1->B1_GRUPO)/*"BOV"*/,;			// [02] Grupo
										nil/*oGridZ0E:GetValue('Z0E_PROD',nI)*/,;   // [03] Produto Base/Copia
										nil/*oGridZ0E:GetValue('Z0E_DESC',nI)*/,;   // [04] Produto Base/Copia Descriç£¯
										oGridZ0E:GetValue('Z0E_RACA'  , nI),;   	// [05] Raç¡
										oGridZ0E:GetValue('Z0E_SEXO'  , nI),;	    // [06] Sexo
										oGridZ0E:GetValue('Z0E_DENTIC', nI)},;		// [07] Denticao
										.T. ))
										// Retorno = lErro
										nQtdTr += oGridZ0E:GetValue('Z0E_QUANT' , nI) 			// aOrigens[nJ,3]
									Else
										__cAntProd := __cProd
										_cAntChvZ0E := cChvZ0E
									EndIf
								EndIf

								// atualizando Z0F
								BeginSQL alias "TEMP"
									%noParser%
									SELECT  R_E_C_N_O_ // Z0F_RACA RACA, Z0F_SEXO SEXO, Z0F_DENTIC DENTIC, *
									FROM	Z0F010
									WHERE	Z0F_FILIAL = %xFilial:Z0F%
										AND Z0F_MOVTO  = %exp:oGridZ0E:GetValue('Z0E_CODIGO', nI)%
										AND Z0F_PROD   = %exp:oGridZ0E:GetValue('Z0E_PROD'  , nI)%
										AND Z0F_LOTE   = %exp:oGridZ0E:GetValue('Z0E_LOTE'  , nI)%
										AND Z0F_RACA   = %exp:oGridZ0E:GetValue('Z0E_RACA'  , nI)%
										AND Z0F_SEXO   = %exp:oGridZ0E:GetValue('Z0E_SEXO'  , nI)%
										//AND Z0F_DENTIC = %exp:oGridZ0E:GetValue('Z0E_DENTIC', nI)%
								EndSQL
								while !TEMP->(Eof())
									Z0F->(DbGoTo(TEMP->R_E_C_N_O_))
									RecLock('Z0F', .F.)
									Z0F->Z0F_PRDORI := Iif(Empty(oGridZ0E:GetValue('Z0E_PRDORI' , nI)), oGridZ0E:GetValue('Z0E_PROD' , nI), oGridZ0E:GetValue('Z0E_PRDORI' , nI)) // oGridZ0E:GetValue('Z0E_PROD', nI)
									Z0F->Z0F_PROD   := SB1->B1_COD // oGridZ0E:GetValue('Z0E_PROD', nI)
									Z0F->Z0F_SEQEFE := cSeqEfe
									Z0F->(MsUnLock())

									TEMP->(dbSkip())
								EndDo
								TEMP->(dbCloseArea())

								// atualizando Z0E
								oGridZ0E:LoadValue('Z0E_PROD', Left(SB1->B1_COD, TamSX3('Z0E_PROD')[1]) )
								// EndIf
								// oModel:CommitData()

								If lTransf
									If aOrigens[nJ,3]+nQtdTr <= oGridZ0E:GetValue('Z0E_QUANT' , nI)
										nQtdTr += aOrigens[nJ,3]
										aAdd(aTransf, {nI,;
											aOrigens[nJ,1],;
											aOrigens[nJ,2],;
											aOrigens[nJ,3],;
											oGridZ0E:GetValue('Z0E_PROD' , nI),;
											oGridZ0E:GetValue('Z0E_LOTE' , nI),;
											aOrigens[nJ,3],;
											oGridZ0E:GetValue('Z0E_SEQEFE' , nI),;
											aOrigens[nJ,4],;
											oGridZ0E:GetValue('Z0E_CURRAL'	, nI),;
											oGridZ0E:GetValue('Z0E_OBS'    , nI)})
										aOrigens[nJ,3] := 0
										// exit
									else
										nDIf := oGridZ0E:GetValue('Z0E_QUANT', nI) - nQtdTr
										nQtdTr += nDIf
										aAdd(aTransf, {nI,;
											aOrigens[nJ,1],;
											aOrigens[nJ,2],;
											nDIf          ,;
											oGridZ0E:GetValue('Z0E_PROD' , nI),;
											oGridZ0E:GetValue('Z0E_LOTE' , nI),;
											nDIf          ,;
											oGridZ0E:GetValue('Z0E_SEQEFE' , nI),;
											aOrigens[nJ,4],;
											oGridZ0E:GetValue('Z0E_CURRAL' , nI),;
											oGridZ0E:GetValue('Z0E_OBS'    , nI)})
										aOrigens[nJ,3] -= nDIf
									EndIf
									// If oGridZ0E:GetValue('Z0E_QUANT' , nI) <= nQtdTr
									// 	nJ := len(aOrigens)
									// EndIf
									exit
								EndIf
							EndIf
							// If oGridZ0E:GetValue('Z0E_QUANT' , nI) <= nQtdTr
							// 	nJ := len(aOrigens)
							// EndIf
						Else
							// nQtdTr += oGridZ0E:GetValue('Z0E_QUANT' , nI)
							aOrigens[nJ,3] -= oGridZ0E:GetValue('Z0E_QUANT' , nI)
							exit
						EndIf
					EndIf
				Next nJ
				// EndDo
			EndIf
		Next nI
		oView:Refresh()

/* MB : 04.06.2020
	Em levantamento com toshio, essa parte esta refazendo o array aTranf que ja foi montado anteriormente, 
  é °ara garantir que mesmo em caso de queda do sistema, onde a Z0E poderia esta DESATUALIZADA, ele pega 
  para os casos de apartacao = 2, os dados atualizados na Z0F;

  vou mudar a logica, vou forç¡² a atualizacao da Z0E antes de EFETIVAR a MOVIMENTAÇƒO;

	//Renato - 25/07/2019
	//Adicionada funcionalidade de efetivaç£¯ com base na Z0F
		If GetMV("VA_EFETZ0F",,.T.) .and. FWFldGet('Z0C_TPMOV')=='2'
			BeginSQL alias "QEFE"
			%noParser%
			select *
			from %table:Z0F% z
			where Z0F_FILIAL=%xFilial:Z0F%
			and Z0F_MOVTO=%exp:FWFldGet('Z0C_CODIGO')%
			and Z0F_SEQEFE='    '
			and z.%notDel%
			EndSQL
			If !QEFE->(Eof())
				aTransf := {}
				while !QEFE->(Eof())
					nPosOri := aScan(aOrigens, { |x| AllTrim(x[1])==AllTrim(QEFE->Z0F_PROD) .and.;
						AllTrim(x[2])==AllTrim(QEFE->Z0F_LOTORI)})
					nPosDes := 0

					for nDes := 1 to oGridZ0E:Length()
						oGridZ0E:GoLine( nDes )

						If !oGridZ0E:IsDeleted()
							If oGridZ0E:GetValue('Z0E_LOTE', nDes) = QEFE->Z0F_LOTE .and. oGridZ0E:GetValue('Z0E_PROD', nDes) = QEFE->Z0F_PROD
								nPosDes := nDes
								exit
							EndIf
						EndIf
					Next

					If nPosOri = 0
						msgAlert("Nao foi possivel encontrar uma origem associada ao lanç¡­ento de pesagem" + ;
							" do produto [" + QEFE->Z0F_PROD + " ] lote [" + AllTrim(QEFE->Z0F_LOTORI)+;
							"] RecnoZ0F [" + cValToChar(QEFE->R_E_C_N_O_)+;
							"]. A efetivaç£¯ não poderá ser concluï¿½.")
						QEFE->(dbCloseArea())
						Return .F.
					EndIf


					If nPosDes = 0
						msgAlert("Nao foi possivel encontrar um registro de destino associado ao lanç¡­ento" + ;
							" de pesagem do produto [" + QEFE->Z0F_PROD + " ] lote [" + AllTrim(QEFE->Z0F_LOTE)+;
							"] RecnoZ0F [" + cValToChar(QEFE->R_E_C_N_O_)+;
							"]. A efetivaç£¯ não poderá ser concluï¿½.")
						QEFE->(dbCloseArea())
						Return .F.
					EndIf

					cCurOri := aOrigens[nPosOri ,4]

					nPosTransf := aScan(aTransf, { |x| AllTrim(x[2])==QEFE->Z0F_PROD .and.;
						AllTrim(x[3])==QEFE->Z0F_LOTORI .and.;
						AllTrim(x[6])==QEFE->Z0F_LOTE})
					If nPosTransf = 0
						aAdd(aTransf, {nPosDes,;
							QEFE->Z0F_PROD,;
							QEFE->Z0F_LOTORI,;
							1,;
							QEFE->Z0F_PROD,;
							QEFE->Z0F_LOTE,;
							1,;
							'    ',;
							cCurOri,;
							QEFE->Z0F_CURRAL,;
							oGridZ0E:GetValue('Z0E_OBS', nPosDes)})
					else
						aTransf[nPosTransf,4]++
						aTransf[nPosTransf,7]++
					EndIf
					QEFE->(dbSkip())
				EndDo
			EndIf
			QEFE->(dbCloseArea())
		EndIf
*/
	/*
		aTransf[][1] = indice da linha de destino
		aTransf[][2] = produto de origem
		aTransf[][3] = lote de origem
		aTransf[][4] = quantidade de origem
		aTransf[][5] = produto de destino
		aTransf[][6] = lote de destino
		aTransf[][7] = quantidade de destino
		aTransf[][8] = sequencia efetivacao
		aTransf[][9] = curral de origem
		aTransf[][10] = curral de destino
	*/
		// Return .T.
		lTransf := .T.
		for nI := 1 to len(aTransf)
			ConOut("ProcGrid: [doTransf]: " + PadL( nI, 3, '0') + "/" + PadL( len(aTransf), 3, '0') )
			//Aqui vem o có¤©§o da transferê®£ia
			/*alert('Transferindo ['+cValToChar(aTransf[nI][4])+'] unidades do produto ['+;
				aTransf[nI][2]+'] lote ['+aTransf[nI][3]+'] para o produto ['+;
					aTransf[nI][5]+'] lote ['+aTransf[nI][6]+'] curral ['+oGridZ0E:GetValue('Z0E_CURRAL', aTransf[nI][1])+']')*/

			If lTransf .and. empty(aTransf[nI, 8])
				If!(lTransf := doTransf( oModel, aTransf[nI]))
					Exit
				EndIf
			EndIf
		Next
		If !lTransf .or. len(aTransf)==0
			Alert("Movimentação não realizada devido a erros nos dados.")
			DisarmTransaction()
		Else

			RecLock('Z0C', .F.)
				If nQtdOri<>nQtdDes
					Z0C->Z0C_STATUS := '4'
					// FWFldPut("Z0C_STATUS", '4')
				else
					Z0C->Z0C_STATUS := '3'
					// FWFldPut("Z0C_STATUS", '3')
				EndIf
				Z0C->Z0C_DTFIM := Date()
				// FWFldPut("Z0C_DTFIM", Date())
				Z0C->Z0C_HRFIM := Time()
				// FWFldPut("Z0C_HRFIM", Time())
			Z0C->(MsUnLock())
/*
			//Retorna o Status do Produto para liberado
			dbSelectArea("SB1")
			dbSetOrder(1)
			If dbSeek(xFilial("SB1")+Z0C->Z0C_PROD)
			RecLock("SB1", .F.)
			SB1->B1_MSBLQL='2'
			msUnlock()
			EndIf
*/
			aStruZ0E    := Z0E->(dbStruct())
			DbSelectArea("Z0E")
			Z0E->(DbSetOrder(1))
			// Gravar Z0E
			For nI := 1 To oGridZ0E:Length()
				oGridZ0E:GoLine( nI )
				If !oGridZ0E:IsDeleted()
					lControl := !Z0E->(DbSeek( xFilial("Z0E") + Z0C->Z0C_CODIGO + oGridZ0E:GetValue('Z0E_SEQ', nI) ))
					RecLock("Z0E", lControl)
					for nJ := 1 to len(aStruZ0E)
						Z0E->&(aStruZ0E[nJ, 1]) := oGridZ0E:GetValue(aStruZ0E[nJ, 1], nI)
					Next nJ
					Z0E->Z0E_FILIAL := xFilial('Z0E')
					Z0E->Z0E_SEQEFE := cSeqEfe
					Z0E->(MsUnLock())
				EndIf
			Next nI

			/* MB : 31.03.2021
				NÃ realizar MEDIA PONDERADA para TPMOV $ ('25') */
			if !(Z0C->Z0C_TPMOV $ ('25'))
				DbUseArea(.t., "TOPCONN", TCGenQry(,,;
							_cSql := " SELECT DISTINCT Z0E_LOTE " + CRLF +;
									 " FROM   Z0E010  " + CRLF +;
									 " WHERE  Z0E_FILIAL = '" + xFilial("Z0E") + "'" + CRLF +;
									 "    AND Z0E_CODIGO = '" + Z0C->Z0C_CODIGO + "'" + CRLF +;
									 "    AND Z0E_SEQEFE = '" + cSeqEfe + "'" + CRLF +;
									 "    AND D_E_L_E_T_ = ' '";
								), "TMPLOTE", .F., .F.)
				While !TMPLOTE->(Eof())
					If aMedPond[01, 02 ]
						/* MB : 26.05.2021
							novo SQL
							Fazer exclusao do saldo da Z0E na SB8, para depois fazer a media ponderada
							*/
						DbUseArea(.t., "TOPCONN", TCGenQry(,,;
									_cSql := " SELECT SUM(PESOTOT)/SUM(SALDO) MEDIA_PONDERADA " + CRLF +;
											 " FROM ( " + CRLF +;
											 " --  			SELECT AVG(B8_XPESOCO) * (AVG(B8_SALDO) - SUM(Z0E_QUANT)) PESOTOT" + CRLF +;
											 " --  			, AVG(B8_SALDO) - SUM(Z0E_QUANT) SALDO" + CRLF +;
											 " --  			-- , AVG(B8_XPESOCO) B8_XPESOCO" + CRLF +;
											 " --  			FROM Z0E010 Z0E WITH (NOLOCK) " + CRLF +;
											 " --  			JOIN SB8010 SB8 WITH (NOLOCK) ON B8_FILIAL+RTRIM(B8_PRODUTO)+RTRIM(B8_LOTECTL) = Z0E_FILIAL+RTRIM(Z0E_PROD)+RTRIM(Z0E_LOTE)" + CRLF +;
											 " --  			                             AND Z0E.D_E_L_E_T_ = ' ' " + CRLF +;
											 " --  			                             AND SB8.D_E_L_E_T_ = ' ' " + CRLF +;
											 " --  			WHERE Z0E_FILIAL = '" + xFilial("Z0E")+ "' " + CRLF +;
											 " --  			-- AND Z0E_CODIGO = '" + Z0C->Z0C_CODIGO + "' " + CRLF +;
											 " --  			AND Z0E_LOTE   = '" + TMPLOTE->Z0E_LOTE + "'" + CRLF +;
											 " --  UNION" + CRLF +;
											 " 			SELECT SUM(Z0E_PESO*Z0E_QUANT) PESOTOT" + CRLF +;
											 " 					, SUM(Z0E_QUANT) SALDO" + CRLF +;
											 " 			FROM Z0E010 WITH (NOLOCK) " + CRLF +;
											 " 			WHERE Z0E_FILIAL = '" + xFilial("Z0E")+ "' " + CRLF +;
											 " 				-- AND Z0E_CODIGO = '" + Z0C->Z0C_CODIGO + "'" + CRLF +;
											 " 				AND Z0E_LOTE   = '" + TMPLOTE->Z0E_LOTE + "'" + CRLF +;
											 " 				AND D_E_L_E_T_ = ' ' " + CRLF +;
											 " ) DADOS";
											), "TMPMEDIA", .f., .f.) 
					Else
						DbUseArea(.t., "TOPCONN", TCGenQry(,,;
									_cSql := " SELECT " + CRLF +;
											 " 		CASE " + CRLF +;
											 " 			WHEN SUM(PESOTOT) = 0 OR SUM(B8_SALDO) = 0 " + CRLF +;
											 " 			THEN -1 " + CRLF +;
											 " 			ELSE SUM(PESOTOT)/SUM(B8_SALDO) " + CRLF +;
											 " 		END MEDIA_PONDERADA " + CRLF +;
											 " FROM ( " + CRLF +;
											 " 		SELECT	SUM(B8_XPESOCO*B8_SALDO) PESOTOT " + CRLF +;
											 " 			  , SUM(B8_SALDO) B8_SALDO" + CRLF +;
											 " 		FROM " + RetSqlName("SB8") + CRLF +;
											 " 		where B8_FILIAL  = '" + xFilial("SB8") + "'" + CRLF +;
											 "         and B8_LOTECTL = '" + TMPLOTE->Z0E_LOTE + "'" + CRLF +;
											 " 		  and B8_SALDO   >  0 " + CRLF +;
											 " 		  and D_E_L_E_T_=' ' " + CRLF +;
											 " ) DADOS";
											 ), "TMPMEDIA", .f., .f.) 
					EndIf
					MemoWrite("C:\totvs_relatorios\SQL_VAMVCA01_MediaPonderada.sql" , _cSql)
					__nPeso := 0
					if TMPMEDIA->(!Eof())
						__nPeso := TMPMEDIA->MEDIA_PONDERADA
					EndIf
					TMPMEDIA->(DbCloseArea())

					If !Empty(__nPeso) .AND. (__nPeso > 0)
						cUpd := "update " + retSQLName("SB8") + CRLF +;
							"   set B8_XPESOCO = " + cValToChar( ROUND(__nPeso, 3) ) + CRLF +;
							" where B8_FILIAL  = '" + xFilial("SB8")+ "'" + CRLF +;
							"   and B8_LOTECTL = '" + TMPLOTE->Z0E_LOTE + "'" + CRLF +;
							"   and B8_SALDO   > 0" + CRLF +;
							"   and D_E_L_E_T_=' '"
						If (TCSqlExec(cUpd) < 0)
							conout("TCSQLError() " + TCSQLError())
						else
							ConOut("Peso medio do lote atualizado com sucesso! " + Z0C->Z0C_CODIGO)
						EndIf
					EndIf
					TMPLOTE->(DbSkip())
				EndDo
				TMPLOTE->(DbCloseArea())
			EndIf

		EndIf
	End Transaction // esta transanç£¯ deve acontecer antes do cursor abaixo.

	If lTransf // .and. Z0C->Z0C_TPMOV $ ("23")
		//FWRestRows( aSvLn1 )
		//FWRestRows( aSvLn2 )

		// FWFormCommit( oModel ) // nao precisa dessa funcao, pq na sequencia
		// sera clicado o botao CONFIRMAR de modo a passar novamente pela validacao do FORMCOMMIT
		ConOut(Repl("-",80))
		__cMsg := "Movimentações realizadas com sucesso."+CRLF+CRLF+;
				  "Tempo de processamento: " + ElapTime( cTimeINI, Time() )
		ConOut(__cMsg)
		ConOut(Repl("-",80))
		msgInfo(__cMsg, "Operação Concluída")
	EndIf
	ConOut('Fim: ProcGrid ' + Time() )

	// FWRestRows( aSaveLines )

	RestArea(aAreaSB1)
	RestArea(aArea)
Return .T.

Static Function doTransf(oModel, aTransf)
	// Local oModel        := FWModelActive()
	Local aArea		:= GetArea()
	Local aAreaSB8		:= SB8->(GetArea())
	Local aAreaSB1		:= SB1->(GetArea())
	Local cUM           := ""
	Local cLocal        := Z0C->Z0C_LOCAL
	Local cDoc          := Z0C->Z0C_CODIGO
	Local cLote         := " "
	Local nQuant        := 0
	Local lOk           := .T.
	Local aItem         := {}
	Local nOpcAuto      := 3 // Indica qual tipo de aç£¯ será ´omada (Inclusã¯¯Exclusã¯©
	Local cProd         := aTransf[2]
	Local dDataVl     	:= cToD("  /  /  ")
	Local __nPeso		:= 0
	// Local __nQuant		:= 0

	PRIVATE lMsHelpAuto := .T.
	PRIVATE lMsErroAuto := .F.

	Private oGridAux    := oModel:GetModel( 'Z0EDETAIL' )
	Private aSvLnAux    := FWSaveRows()

	ConOut('Inicio: doTransf ' + Time() )

	DbSelectArea("SB1")
	DbSetOrder(1)

	If !SB1->(MsSeek(xFilial("SB1")+cProd))
		lOk := .F.
		Alert("Produto não encontrado, feche a Movimentação e verIfique se o produto foi excluï¿½.")
	Else
		cProd 	:= SB1->B1_COD
		cDescri	:= SB1->B1_DESC
		cUM 	:= SB1->B1_UM
		cSEGUM 	:= SB1->B1_SEGUM
	EndIf

	/*
		aTransf[][1] = indice da linha na grid destino
		aTransf[][2] = produto de origem
		aTransf[][3] = lote de origem
		aTransf[][4] = quantidade de origem
		aTransf[][5] = produto de destino
		aTransf[][6] = lote de destino
		aTransf[][7] = quantidade de destino
	*/

	DbSelectArea("SB8")
	DbSetOrder(3)
	If !SB8->(MsSeek(xFilial("SB8")+ cProd + cLocal + aTransf[3] ))
		cLote 	:= aTransf[3]
		dDataVl	:= dDatabase+GetMV("JR_VLDPADR",,110)
		nQuant	:= aTransf[4]
	Else
		cLote 	:= SB8->B8_LOTECTL
		dDataVl	:= SB8->B8_DTVALID
		nQuant	:= aTransf[4]
	EndIf

	DbSelectArea("SB8")
	DbSetOrder(3)
	// If SB8->(MsSeek(xFilial("SB8")+ cProd + cLocal + aTransf[6] ))
	If SB8->(MsSeek(xFilial("SB8")+ aTransf[5] + cLocal + aTransf[6] ))
		If SB8->B8_DTVALID <> dDataVl
			RecLock("SB8")
				SB8->B8_DTVALID := dDataVl
			msUnlock()
		EndIf
	EndIf

	If lOk
		//GetSxENum("SD3","D3_DOC",1)
		dDtTran := Z0C->Z0C_DATA
		ConOut(Repl("-",80))
		ConOut(PadC("Realiza as transferencias de estoque",80))
		ConOut("Inicio: " + Time())
		//Ú„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä¿
		//| Teste de Inclusao                                            |
		//ÄÄ„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä™

		//Cabecalho a Incluir
		aAuto := {}
		aadd(aAuto,{cDoc,dDtTran})	//Cabecalho		      2
		//Itens a Incluir

		DbSelectArea("SB1")
		DbSetOrder(1)
		SB1->(MsSeek(xFilial("SB1")+aTransf[2]))
		cProd 	:= SB1->B1_COD
		cDescri	:= SB1->B1_DESC
		cUM 	:= SB1->B1_UM
		cSEGUM 	:= SB1->B1_SEGUM
		/*
			aadd(aItem,cProd)	  		//01 = Prod.Orig. D3_COD      C        15       0
			aadd(aItem,cDescri)	  		//02 = Desc.Orig. D3_DESCRI   C        30       0
			aadd(aItem,cUM)		   		//03 = UM Orig.   D3_UM       C         2       0
			aadd(aItem,cLocal)	   		//04 = Armazem Or D3_LOCAL    C         2       0
			aadd(aItem,"")		   		//05 = Endereco O D3_LOCALIZ  C        15       0
		*/
		//Origem
		aadd(aItem,{"D3_COD", cProd, Nil}) //Cod Produto origem
		aadd(aItem,{"D3_DESCRI", cDescri, Nil}) //descr produto origem
		aadd(aItem,{"D3_UM", cUM, Nil}) //unidade medida origem
		aadd(aItem,{"D3_LOCAL", cLocal, Nil}) //armazem origem
		aadd(aItem,{"D3_LOCALIZ", PadR(" ", tamsx3('D3_LOCALIZ') [1]),Nil}) //Informar endereÃ§o origem

		DbSelectArea("SB1")
		DbSetOrder(1)
		SB1->(MsSeek(xFilial("SB1")+aTransf[5]))
		cProd 	:= SB1->B1_COD
		cDescri	:= SB1->B1_DESC
		cUM 	:= SB1->B1_UM
		cSEGUM 	:= SB1->B1_SEGUM
		/*
			aadd(aItem,cProd)	   		//06 = Prod.Desti D3_COD      C        15       0
			aadd(aItem,cDescri)	  		//07 = Desc.Desti D3_DESCRI   C        30       0
			aadd(aItem,cUM)		  		//08 = UM Destino D3_UM       C         2       0
			aadd(aItem,cLocal)	   		//09 = Armazem De D3_LOCAL    C         2       0
			aadd(aItem,"")		  		//10 = Endereco D D3_LOCALIZ  C        15       0
		*/
		//Destino
		aadd(aItem, {"D3_COD"    , cProd                                , Nil}) //Cod Produto origem
		aadd(aItem, {"D3_DESCRI" , cDescri                              , Nil}) //descr produto origem
		aadd(aItem, {"D3_UM"     , cUM                                  , Nil}) //unidade medida origem
		aadd(aItem, {"D3_LOCAL"  , cLocal                               , Nil}) //armazem origem
		aadd(aItem, {"D3_LOCALIZ", PadR(" ", tamsx3( 'D3_LOCALIZ' ) [1]), Nil}) //Informar endereÃ§o origem
		/*
			aadd(aItem,"")		  		//11 = Numero Ser D3_NUMSERI  C        20       0
			aadd(aItem,cLote)	  		//12 = Lote       D3_LOTECTL  C        10       0
			aadd(aItem,"")				//13 = Sub-Lote   D3_NUMLOTE  C         6       0
			aadd(aItem,dDataVl)	   		//14 = Validade   D3_DTVALID  D         8       0
			aadd(aItem,0)		  		//15 = Potencia   D3_POTENCI  N         6       2
			aadd(aItem,nQuant)	  		//16 = Quantidade D3_QUANT    N        12       2
			aadd(aItem,0)		   		//17 = Qt 2aUM    D3_QTSEGUM  N        12       2
			aadd(aItem,"")		   		//18 = Estornado  D3_ESTORNO  C         1       0
			aadd(aItem,"")		  		//19 = Sequencia  D3_NUMSEQ   C         6       0
			aadd(aItem, aTransf[6])		//20 = Lote Desti D3_LOTECTL  C        10       0
			aadd(aItem,dDataVl)	   		//21 = Validade D D3_DTVALID  D         8       0
			aadd(aItem,"")		   		//22 = Item Grade D3_ITEMGRD  C         3       0
			//aadd(aItem,"")		   	//23 = Id DCF     D3_IDDCF    C         6       0
			aadd(aItem,"MOV." + cDoc + "." + cSeqEfe)		//24 = Observaç£¯ D3_OBSERVA  C        30       0
		*/
		aadd(aItem, {"D3_NUMSERI", ""                           , Nil}) //Numero serie
		aadd(aItem, {"D3_LOTECTL", cLote                        , Nil}) //Lote Origem
		aadd(aItem, {"D3_NUMLOTE", ""                           , Nil}) //sublote origem
		aadd(aItem, {"D3_DTVALID", dDataVl                      , Nil}) //data validade
		aadd(aItem, {"D3_POTENCI", 0                            , Nil}) // Potencia
		aadd(aItem, {"D3_QUANT"  , nQuant                       , Nil}) //Quantidade
		aadd(aItem, {"D3_QTSEGUM", 0                            , Nil}) //Seg unidade medida
		aadd(aItem, {"D3_ESTORNO", ""                           , Nil}) //Estorno
		aadd(aItem, {"D3_NUMSEQ" , ""                           , Nil}) // Numero sequencia D3_NUMSEQ

		aadd(aItem, {"D3_LOTECTL", aTransf[6]                   , Nil}) //Lote destino
		aadd(aItem, {"D3_NUMLOTE", ""                           , Nil}) //sublote destino
		aadd(aItem, {"D3_DTVALID", dDataVl                      , Nil}) //validade lote destino
		aadd(aItem, {"D3_ITEMGRD", ""                           , Nil}) //Item Grade

		aadd(aItem, {"D3_CODLAN" , ""                           , Nil}) //cat83 prod origem
		aadd(aItem, {"D3_CODLAN" , ""                           , Nil}) //cat83 prod destino

		aadd(aItem, {"D3_OBSERVA", "MOV." + cDoc + "." + cSeqEfe, Nil}) //Observaç£¯

		aadd(aItem, {"D3_X_CURRA", aTransf[9]                   , Nil}) //24 = Observaç£¯ D3_OBSERVA  C        30       0
		aadd(aItem, {"D3_X_CURRA", aTransf[10]                  , Nil}) //24 = Observaç£¯ D3_OBSERVA  C        30       0

		If !Empty(aTransf[11])
			aadd(aItem,{"D3_X_OBS", aTransf[11], Nil}) //Observaç£¯
		EndIf

		aadd(aAuto, aItem)

		PRIVATE cCusMed   := GetMv("MV_CUSMED")
		PRIVATE cCadastro := "MOVIMENTACAO DE BOVINOS"
		PRIVATE aRegSD3   := {}
		//Ú„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä¿
		//? VerIfica se o custo medio e' calculado On-Line               ?
		//ÄÄ„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä™
		If cCusMed == "O"
			PRIVATE nHdlPrv // Endereco do arquivo de contra prova dos lanctos cont.
			PRIVATE lCriaHeader := .T. // Para criar o header do arquivo Contra Prova
			PRIVATE cLoteEst      // Numero do lote para lancamentos do estoque
			//Ú„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä¿
			//? Posiciona numero do Lote para Lancamentos do Faturamento     ?
			//ÄÄ„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä™
			dbSelectArea("SX5")
			If dbSeek(xFilial() + " 09EST")
				cLoteEst:=IIf(Found(),Trim(X5Descri()),"EST ")
			EndIf
			PRIVATE nTotal := 0      // Total dos lancamentos contabeis
			PRIVATE cArquivo     // Nome do arquivo contra prova
		EndIf

		//lMsErroAuto := !a260Processa(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,cNumLote,cLoteDigi,dDtValid ,cNumSerie,cLoclzOrig,cCodDest,cLocDest,cLocLzDest,lEstorno,nRecOrig,nRecDest,cPrograma ,cEstFis,cServico,cTarefa,cAtividade,cAnomalia,cEstDest,cEndDest,cHrInicio,cAtuEst,cCarga,cUnitiza,cOrdTar,cOrdAti,cRHumano,cRFisico,nPotencia,cLoteDest,dDtVldDest,cCAT83O,cCAT83D,lAtuSB2)
		//lMsErroAuto := !a260Processa(aItem[1], aItem[4], aItem[16],cDoc  ,dDtTran , aItem[16] ,Nil     , aItem[12], aItem[14], aItem[11],Nil       ,Nil     , aItem[9], aItem[10] ,.F.     ,Nil     ,Nil     ,"VAMVCA01",Nil    ,""      ,Nil    ,Nil       ,Nil      ,Nil     ,Nil     ,Nil      ,Nil    ,Nil   ,Nil     ,Nil    ,Nil    ,Nil     ,Nil     ,Nil      , aItem[20], aItem[14] ,Nil    ,Nil)
		MSExecAuto({|x,y| mata261(x,y)}, aAuto,nOpcAuto)
		If !lMsErroAuto

			// If (aTransf[2] <> aTransf[5])
			If (aTransf[2] == aTransf[5])
				aAdd( aMedPond, { aTransf[5], .T. /* igual */ })
			Else
				aAdd( aMedPond, { aTransf[5], .F. })
			EndIf
			
				cUpd := "update " + retSQLName("SB8") + CRLF +;
					"   set B8_X_CURRA ='" + oGridAux:GetValue('Z0E_CURRAL', aTransf[1])+ "'" + CRLF +;
					"	  , B8_XRFID   ='" + SB1->B1_XRFID+ "'" + CRLF +;
					"	  , B8_X_COMIS = " + cValToChar(SB1->B1_X_COMIS) + CRLF +;
					"	  , B8_XDATACO ='" + DTOS(oGridAux:GetValue('Z0E_DATACO', aTransf[1]))+ "'" + CRLF +;
					"	  , B8_XPVISTA = " + cValToChar(SB1->B1_XPVISTA) + CRLF +;
					"	  , B8_XPFRIGO = " + cValToChar(SB1->B1_XPFRIGO) + CRLF
				// Alt. MB : 03.01.2018
				If !Empty(oGridAux:GetValue('Z0E_QUANT', aTransf[1]))
					cUpd += "	  , B8_XQTDORI = " + cValToChar(oGridAux:GetValue('Z0E_QUANT', aTransf[1])) + CRLF
				EndIf
				If (aTransf[2] <> aTransf[5])
					If !Empty(oGridAux:GetValue('Z0E_PESO'   , aTransf[1]))
						cUpd += "	  , B8_XPESOCO = " + cValToChar(round(oGridAux:GetValue('Z0E_PESO'   , aTransf[1]),2)) + CRLF
					EndIf
					If !Empty(oGridAux:GetValue('Z0E_PESTOT' , aTransf[1]))
						cUpd += "	  , B8_XPESTOT = " + cValToChar(round(oGridAux:GetValue('Z0E_PESTOT' , aTransf[1]),2)) + CRLF
					EndIf
				EndIf
				cUpd += "	  , B8_GMD     = " + cValToChar(oGridAux:GetValue('Z0E_GMD'    , aTransf[1])) + CRLF +;
						"	  , B8_DIASCO  = " + cValToChar(oGridAux:GetValue('Z0E_DIASCO' , aTransf[1])) + CRLF +;
						"	  , B8_XRENESP = " + cValToChar(oGridAux:GetValue('Z0E_RENESP' , aTransf[1])) + CRLF +;
						" where B8_FILIAL  ='" + xFilial("SB8") + "'" + CRLF +;
						"   and B8_PRODUTO ='" + AllTrim(cProd)+ "'" + CRLF +;
						"   and B8_LOCAL   ='" + cLocal+ "'" + CRLF +;
						"   and B8_LOTECTL ='" + AllTrim(aTransf[6])+ "'" + CRLF +;
						"   and B8_SALDO   > 0 " + CRLF +;
						"   and D_E_L_E_T_=' '"
				If (TCSqlExec(cUpd) < 0)
					conout("TCSQLError() " + TCSQLError())
				else
					ConOut("Dados do lote atualizados com sucesso! " + cDoc)
				EndIf

				__nPeso  := oGridAux:GetValue('Z0E_PESO' , aTransf[1])
				// if (Z0C->Z0C_TPMOV $ ('25'))
					If !Empty(__nPeso)
						cUpd := "update " + retSQLName("SB8") + CRLF +;
							"   set B8_XPESOCO = " + cValToChar( ROUND(__nPeso, 3) ) + CRLF +;
							" where B8_FILIAL  = '" + xFilial("SB8")+ "'" + CRLF +;
							"   and B8_LOTECTL = '" + AllTrim(aTransf[6])+ "'" + CRLF +;
							"   and B8_SALDO   > 0" + CRLF +;
							"   and D_E_L_E_T_=' '"
						If (TCSqlExec(cUpd) < 0)
							conout("TCSQLError() " + TCSQLError())
						else
							ConOut("Peso medio do lote atualizado com sucesso! " + cDoc)
						EndIf
					EndIf
				//EndIf
			// EndIf

			// MB: 30.06.2020 - LEVEI PARA O PROCESSAMENTO DO VETOR NA EFETIVAÇƒO
			// NAO PODE TIRAR ESSA PARTE DAQUI ...
			oGridAux:GoLine( aTransf[1] )
			oGridAux:SetValue('Z0E_SEQEFE', cSeqEfe)

		Else
			MostraErro()
			ConOut("Erro na inclusao!")
			MsgAlert(U_AtoS(aTransf))
			lOk := .F.
			// aLog 	:= GetAutoGRLog()
		EndIf
		ConOut("Fim: " + Time())

	EndIf

	FWRestRows( aSvLnAux )

	ConOut('Fim: doTransf ' + Time() )
	ConOut(Repl(" ",80))
	RestArea(aAreaSB1)
	RestArea(aAreaSB8)
	RestArea(aArea)
Return lOk

//-- ExecBlock para atribuir valores nos campos de usuario
User Function MA261IN()
	Local aAreaSB8 := SB8->(GetArea())
	Local nPosProd := aScan( aHeader, {|x| x[1] == "Prod.Destino"}) 	// 06
	Local nPosArma := aScan( aHeader, {|x| x[1] == "Armazem Destino"}) 	// 09
	Local nPosLote := aScan( aHeader, {|x| x[1] == "Lote Destino"}) 	// 20
	Local nPosVldD := aScan( aHeader, {|x| x[1] == "Validade Destino"})
	Local dDataVl  := aCols[1, nPosVldD] // posicao 21 // cToD("  /  /  ")

	If !IsInCallStack( 'U_CANCMVBV' )
		DbSelectArea("SB8")
		DbSetOrder(3)
		If SB8->(MsSeek(xFilial("SB8")+ aCols[1, nPosProd] + aCols[1, nPosArma] + aCols[1, nPosLote] ))
			If SB8->B8_DTVALID <> dDataVl
				ConOut('MA261IN. Produto: '+AllTrim(aCols[1, nPosProd])+' Atual: ' + CVALTOCHAR( SB8->B8_DTVALID ) + ' new: ' + CVALTOCHAR( dDataVl ))
				RecLock("SB8")
				SB8->B8_DTVALID := dDataVl
				msUnlock()
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSB8)
Return .T.

// Verifica se existe ponto de entrada para validacao
// User Function A261TOK()
// ConOut('A261TOK')
// Return .T.

//ExecBlock apos gravacao do SD3           
// User Function MA261D3()
// ConOut('MA261D3')
// Return .T.

// User Function MI261RCV()
// ConOut('MI261RCV')
// Return .T.

// User Function MA261TRD3()
// ConOut('MA261TRD3')
// Return .T.

// User Function MTA261DOC()
// ConOut('MTA261DOC')
// Return .T.

User Function CancMvBv()
	Local aArea   := GetArea()
	Local lRet    := .T.
	Local nL      := 0
	Local __nPeso := 0

	Begin Transaction
		If Z0C->Z0C_STATUS = '3' .or. Z0C->Z0C_STATUS = '4'
			aSequen := mrkSeqs()

			If len(aSequen) = 0
				msgInfo("Nenhuma sequencia selecionada.")
				Return
			EndIf

			If msgYesNo("Confirma o estorno?")
				for nL := 1 to len(aSequen)

					if !(Z0C->Z0C_TPMOV $ ('25'))
						__nPeso := 0
						DbUseArea(.t., "TOPCONN", TCGenQry(,,;
									_cSql := " SELECT DISTINCT Z0E_LOTE " + CRLF +;
												" FROM   Z0E010  " + CRLF +;
												" WHERE  Z0E_FILIAL =  '" + xFilial("Z0E") + "'" + CRLF +;
												"    AND Z0E_CODIGO =  '" + Z0C->Z0C_CODIGO + "'" + CRLF +;
												"    AND Z0E_SEQEFE =  '" + aSequen[nL] + "'  " + CRLF +;
												"    AND D_E_L_E_T_= ' '";
										), "TMPLOTE", .f., .f.) 
						While !TMPLOTE->(Eof())
							//_cSql := " SELECT SUM(PESOTOT)/SUM(B8_SALDO) MED_ANT " + CRLF +;
							_cSql := " SELECT " + CRLF +;
									 " 		CASE " + CRLF +;
									 " 			WHEN SUM(PESOTOT) = 0 OR SUM(B8_SALDO) = 0 " + CRLF +;
									 " 			THEN -1 " + CRLF +;
									 " 			ELSE SUM(PESOTOT)/SUM(B8_SALDO) " + CRLF +;
									 " 		END MED_ANT " + CRLF +;
									 " FROM ( " + CRLF +;
									 " 		SELECT	SUM(B8_XPESOCO*B8_SALDO) PESOTOT " + CRLF +;
									 " 			  , SUM(B8_SALDO) B8_SALDO" + CRLF +;
									 " 		FROM SB8010 " + CRLF +;
									 " 		WHERE B8_FILIAL  = '" + xFilial("SB8") + "'" + CRLF +;
									 " 		  AND B8_LOTECTL = '" + TMPLOTE->Z0E_LOTE + "'" + CRLF +;
									 " 		  AND B8_SALDO   >  0 " + CRLF +;
									 " 		  AND D_E_L_E_T_=' ' " + CRLF +;
									 " " + CRLF +;
									 " 		UNION " + CRLF +;
									 " " + CRLF +;
									 " 		SELECT SUM(Z0E_PESO*Z0E_QUANT*-1)" + CRLF +;
									 " 			 , SUM(Z0E_QUANT*-1)" + CRLF +;
									 " 		FROM Z0E010 " + CRLF +;
									 " 		where Z0E_FILIAL = '" + xFilial("Z0E") + "' " + CRLF +;
									 " 		  and Z0E_CODIGO = '" + Z0C->Z0C_CODIGO + "' " + CRLF +;
									 " 		  AND Z0E_LOTE   = '" + TMPLOTE->Z0E_LOTE + "'" + CRLF +;
									 " 		  and Z0E_SEQEFE = '" + aSequen[nL] + "' " + CRLF +;
									 " 		  and D_E_L_E_T_ = ' ' " + CRLF +;
									 " ) DADOS"
							DbUseArea(.t., "TOPCONN", TCGenQry(,, _cSql ), "TMPMEDIA", .f., .f.) 
							if TMPMEDIA->(!Eof())
								__nPeso := TMPMEDIA->MED_ANT
							EndIf
							TMPMEDIA->(DbCloseArea())

							If !Empty(__nPeso) .AND. (__nPeso > 0)
								cUpd := "update " + retSQLName("SB8") + CRLF +;
										"   set B8_XPESOCO = " + cValToChar( ROUND(__nPeso, 3) ) + CRLF +;
										" where B8_FILIAL  = '" + xFilial("SB8")+ "'" + CRLF +;
										"   and B8_LOTECTL = '" + AllTrim(TMPLOTE->Z0E_LOTE)+ "'" + CRLF +;
										"   and B8_SALDO   > 0" + CRLF +;
										"   and D_E_L_E_T_=' '"
								If (TCSqlExec(cUpd) < 0)
									conout("TCSQLError() " + TCSQLError())
								else
									ConOut("Peso medio do lote atualizado com sucesso! " + Z0E->Z0E_CODIGO)
								EndIf
							EndIf
							TMPLOTE->(DbSkip())
						EndDo
						TMPLOTE->(DbCloseArea())
					EndIf	

					// If undoTransf(aSequen[nL])
					Processa({|| lRet := undoTransf(aSequen[nL]) }, "Por favor aguarde ...")
					If lRet
						BeginSQL alias "TEMP"
							%noParser%
							SELECT  R_E_C_N_O_
							FROM	Z0E010
							where   Z0E_FILIAL = %exp:xFilial("Z0E")%
							    and Z0E_CODIGO = %exp:Z0C->Z0C_CODIGO%
							    and Z0E_SEQEFE = %exp:aSequen[nL]%
							    and %notDel%
						EndSQL
						while !TEMP->(Eof())
							Z0E->(DbGoTo(TEMP->R_E_C_N_O_))

							RecLock('Z0E', .F.)
								Z0E->Z0E_SEQEFE := Space(4)
								Z0E->Z0E_ESTUSR := __cUserId
								Z0E->Z0E_ESTDAT := Date() // dToS(Date())
								Z0E->Z0E_ESTHOR := Time()
							Z0E->(MsUnLock())

							TEMP->(dbSkip())
						EndDo
						TEMP->(dbCloseArea())

						BeginSQL alias "TEMP"
							%noParser%
							SELECT  R_E_C_N_O_
							FROM	Z0F010
							where   Z0F_FILIAL = %exp:xFilial("Z0F")%
							and   Z0F_MOVTO  = %exp:Z0C->Z0C_CODIGO%
							and   Z0F_SEQEFE = %exp:aSequen[nL]%
							and   %notDel%
						EndSQL
						while !TEMP->(Eof())
							Z0F->(DbGoTo(TEMP->R_E_C_N_O_))

							RecLock('Z0F', .F.)
								Z0F->Z0F_SEQEFE := Space(4)
								Z0F->Z0F_ESTUSR := __cUserId
								Z0F->Z0F_ESTDAT := Date() // dToS(Date())
								Z0F->Z0F_ESTHOR := Time()
							Z0F->(MsUnLock())

							TEMP->(dbSkip())
						EndDo
						TEMP->(dbCloseArea())

						MsgInfo("Movimentos excluído com sucesso!", "OPERAÇƒO CONCLUÍ„A")
					EndIf
				Next

				BeginSQL alias "Q1"
					%noParser%
					select sum(case when Z0E_SEQEFE = '    ' then 1 else 0 end) QTD_EFE, count(R_E_C_N_O_) QTD_REG
					from %table:Z0E% z
					where Z0E_FILIAL=%xFilial:Z0E%
					and Z0E_CODIGO=%exp:Z0C->Z0C_CODIGO%
					and z.%notDel%
				EndSQL
				If !Q1->(Eof())
					RecLock("Z0C", .F.)
					If Q1->QTD_EFE = Q1->QTD_REG
						Z0C->Z0C_STATUS='1'
					else
						Z0C->Z0C_STATUS='4'
					EndIf
					msUnlock()
				EndIf
				Q1->(dbCloseArea())
			EndIf
		Else
			Alert("não há m­ovimentos efetivados para estornar.")
		EndIf
	End Transaction
	RestArea(aArea)
Return

//Estorna Transferencia 
Static Function undoTransf(cSequen)
	Local nItem			:= 0
	Local aAUTO         := {}
	Local cDoc          := Z0C->Z0C_CODIGO
	// Local cProd      := Z0C->Z0C_PROD
	// Local nOpcAuto      := 6 // Indica qual tipo de aç£¯ será ´omada (Inclusã¯¯Exclusã¯©

	default cSequen     := ""

	PRIVATE lMsHelpAuto := .T.
	PRIVATE lMsErroAuto := .F.

	PRIVATE cCusMed     := GetMv("MV_CUSMED")
	PRIVATE cCadastro   := "MOVIMENTACAO DE BOVINOS"
	PRIVATE aRegSD3     := {}
	//Ú„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä¿
	//? VerIfica se o custo medio e' calculado On-Line               ?
	//ÄÄ„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä™
	If cCusMed == "O"
		PRIVATE nHdlPrv // Endereco do arquivo de contra prova dos lanctos cont.
		PRIVATE lCriaHeader := .T. // Para criar o header do arquivo Contra Prova
		PRIVATE cLoteEst      // Numero do lote para lancamentos do estoque
		//Ú„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä¿
		//? Posiciona numero do Lote para Lancamentos do Faturamento     ?
		//ÄÄ„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä„Ä™
		dbSelectArea("SX5")
		If dbSeek(xFilial() + " 09EST")
			cLoteEst:=IIf(Found(),Trim(X5Descri()),"EST ")
		EndIf
		PRIVATE nTotal := 0      // Total dos lancamentos contabeis
		PRIVATE cArquivo     // Nome do arquivo contra prova
	EndIf

	BeginSQL alias "MYD3"
		%noParser%
		select SD3.R_E_C_N_O_ REC
		from %table:SD3% SD3
		where D3_FILIAL=%xFilial:SD3%
		and D3_OBSERVA=%exp:("MOV." + cDoc + "." + cSequen)%
		and D3_TM=%exp:'499'%
		and D3_ESTORNO<>'S'
		and SD3.%notDel%
	EndSQL

	If !MYD3->(Eof())

		while !MYD3->(Eof()) .and. !lMsErroAuto
			DbSelectArea("SD3")
			DbGoTo(MYD3->REC)
			//DbSetOrder(2)
			//DbSeek(xFilial("SD3")+cDoc+cProd)
			aAuto := {}

			ConOut(StrZero(++nItem, 5) + ': ' + AllTrim(SD3->D3_OBSERVA) + ' ' + AllTrim(SD3->D3_COD) + ' ' + StrZero(SD3->D3_QUANT, 3) + ' ' + SD3->D3_USUARIO )
			MSExecAuto({|x,y| mata261(x,y)}, aAuto,6)

			MYD3->(dbSkip())
		EndDo

		//If !lMsErroAuto
		// msgInfo("Movimentos excluído com sucesso!", "OPERAÇƒO CONCLUÍ„A")
		//ALERT(CVALTOCHAR(LMSERROAUTO))
		//Else
		If lMsErroAuto
			msgInfo("Erro ao excluir Movimentações exclusã¯¡", "ATENÇƒO")
			MostraErro()
			DisarmTransaction()
		EndIf

	else
		lMsErroAuto := .T.
		msgInfo("Registros não encontrados nas Movimentações de estoque (Tabela SD3).", "ATENÇƒO")
	EndIf
	MYD3->(dbCloseArea())
Return !lMsErroAuto



Static function MrkSeqs()
	local nOpc		:= GD_UPDATE
	local cLinOk	:= "AllwaysTrue"
	local cTudoOk	:= "AllwaysTrue"
	local cIniCpos	:= "B8_LOTECTL"
	local nFreeze	:= 000
	local nMax		:= 999
	local cFieldOk	:= "AllwaysTrue"
	local cSuperDel	:= ""
	local cDelOk	:= "AllwaysFalse"
	local nTamLin  := 16
	local nLinIni  := 03
	local nLinAtu  := nLinIni
	Local nL		:= 0

	Private oDlg
	Private aHeadMrk := {}
	Private aColsMrk := {}
	Private nUsadMrk := 0

	aSize := MsAdvSize(.F.)

	/*
	 MsAdvSize (http://tdn.totvs.com/display/public/mp/MsAdvSize+-+Dimensionamento+de+Janelas)
	 aSize[1] = 1 -> Linha inicial á²¥a trabalho.
	 aSize[2] = 2 -> Coluna inicial á²¥a trabalho.
	 aSize[3] = 3 -> Linha final á²¥a trabalho.
	 aSize[4] = 4 -> Coluna final á²¥a trabalho.
	 aSize[5] = 5 -> Coluna final dialog (janela).
	 aSize[6] = 6 -> Linha final dialog (janela).
	 aSize[7] = 7 -> Linha inicial dialog (janela).
	*/

	aAdd(aHeadMrk,{ " "				, "cStat"      		,"@BMP"         			, 1,0,"","","C","","V","","","","V","","",""})
	aAdd(aHeadMrk,{ "Sequencial"	, "Z0E_SEQEFE"		, X3Picture("Z0E_SEQEFE")	,TamSX3("Z0E_SEQEFE")[1]	, 0,"AllwaysTrue()", X3Uso("Z0E_SEQEFE")	, "C", "", "V" } )
	//aAdd(aHeadMrk,{ "Data"			, "D3_EMISSAO"		, X3Picture("D3_EMISSAO")	,TamSX3("D3_EMISSAO")[1]	, 0,"AllwaysTrue()", X3Uso("D3_EMISSAO")	, "D", "", "V" } )
	aAdd(aHeadMrk,{ "Documento"		, "D3_OBSERVA"		, X3Picture("D3_OBSERVA")   ,TamSX3("D3_OBSERVA")[1]	, 0,"AllwaysTrue()", X3Uso("D3_OBSERVA")	, "C", "", "V" } )
	nUsadMrk := len(aHeadMrk)

	aColsMrk	:= {}

	BeginSQL alias "QSEQ"
		%noParser%
		select distinct Z0E_SEQEFE
		  from %table:Z0E% z
		 where Z0E_FILIAL=%xFilial:Z0E%
		   and Z0E_CODIGO=%exp:Z0C->Z0C_CODIGO%
		   and Z0E_SEQEFE <> '    '
		   and z.%notDel%
	EndSQL
	If !QSEQ->(Eof())
		while !QSEQ->(Eof())
			aAdd(aColsMrk, array(nUsadMrk+1))
			aColsMrk[len(aColsMrk), 1] := "LBNO"
			aColsMrk[len(aColsMrk), 2] := QSEQ->Z0E_SEQEFE
			aColsMrk[len(aColsMrk), 3] := "MOV." + Z0C->Z0C_CODIGO + "." + QSEQ->Z0E_SEQEFE
			aColsMrk[len(aColsMrk),nUsadMrk+1] := .F.

			QSEQ->(dbSkip())
		EndDo
	else
		aAdd(aColsMrk, array(nUsadMrk+1))
		aColsMrk[len(aColsMrk),nUsadMrk+1] := .F.
	EndIf
	QSEQ->(dbCloseArea())

	lOk := .F.
	define msDialog oDlgMrk title "seleção de Sequenciais a serem estornados" /*STYLE DS_MODALFRAME*/ From aSize[1], aSize[2] To aSize[3]/2, aSize[5]/2 OF oMainWnd PIXEL
	//oDlgMrk:lMaximized := .T. //Maximiza a janela

	nLinAtu += nTamLin
	oSeek	:= TButton():New( nLinAtu-2, aSize[5]/4 - 55, "Confirmar" ,oDlgMrk, {|| lOk := .T., oDlgMrk:End() },55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)
	oSeek:SetCss("QPushButton{ color: #FFF; background: #2C2; font-weight: bold}")

	nLinAtu += nTamLin + 5

	oBtMrk	:= TButton():New( nLinAtu-5, 02, "Inverter seleção" ,oDlgMrk, {|| MarcaDes(oGetDadMrk,"T") },60, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)
	oBtMrk:SetCss("QPushButton{ color: #000; }")

	nLinAtu += nTamLin+4

	oGetDadMrk:= MsNewGetDados():New(nLinAtu+5, 05, aSize[3]/4 - 5, aSize[5]/4 -5, nOpc, cLinOk, cTudoOk, cIniCpos, {}, nFreeze, nMax, cFieldOk, cSuperDel, cDelOk, oDlgMrk, aHeadMrk, aColsMrk)
	oGetDadMrk:oBrowse:blDblClick := {|| MarcaDes(oGetDadMrk,"L")}

	Activate dialog oDlgMrk centered

	aRet := {}
	for nL := 1 to len(oGetDadMrk:aCols)
		If oGetDadMrk:aCols[nL,1]=="LBTIK"
			aAdd(aRet, oGetDadMrk:aCols[nL,2])
		EndIf
	Next
Return aRet


//---------------------------------------------
user function getSldBv(cProd, cLote)
	local nSaldo := 0
	local cAliasQry := GetNextAlias()

	default cLote := ""

	If empty(cLote)
		BeginSQL alias cAliasQry
		%noParser%
		select sum(B2_QATU) B2_QATU
		  from %table:SB2% SB2
		 where B2_FILIAL=%xFilial:SB2%
		   and B2_COD=%exp:cProd%
		   and SB2.%notDel%
		EndSQL
	else
		BeginSQL alias cAliasQry
		%noParser%
		select sum(B8_SALDO) B2_QATU
		  from %table:SB8% SB8
		 where B8_FILIAL=%xFilial:SB8%
		   and B8_PRODUTO=%exp:cProd%
		   and B8_LOTECTL=%exp:cLote%
		   and SB8.%notDel%
		EndSQL
	EndIf

	If !(cAliasQry)->(Eof())
		nSaldo := (cAliasQry)->B2_QATU
	EndIf
	(cAliasQry)->(dbCloseArea())

Return nSaldo

// -----------------------------------
User Function vlSdOri()
	// Local oModel := FWModelActive()
	// Local nI := 0
	Local nTotOri := 0
	Local nTotQOri := 0
	// Local nTotDest := 0
	Local lRet := .T.

	// Local cProduto := FWFldGet('Z0D_PROD')

	nTotOri := &(ReadVar())
	nTotQOri := FWFldGet('Z0D_QTDORI')

	//VerIfica se a quantidade de origem está ºerada
	If nTotOri <= 0
		Alert("Quantidade de origem não pode ser 0 (Zero).")
		lRet := .F.
		Return lRet
	EndIf

	//Verifica se a quantidade de origem é ­enor ou igual ao saldo atual do produto
	If nTotOri > nTotQOri
		Alert("Quantidade de origem não pode ser maior que o saldo atual dos produtos.")
		lRet := .F.
		Return lRet
	EndIf

Return lRet


User Function vlSdDest()
	Local oModel   := FWModelActive()
	Local nI       := 0
	Local nTotOri  := 0
	Local nTotQOri := 0
	Local nTotDest := 0
	Local lRet     := .T.

	Local cProduto := FWFldGet('Z0E_PROD') + FWFldGet('Z0E_LOTORI')

	If Z0C->Z0C_TPMOV/*FWFldGet\("Z0C_TPMOV"\)*/=="5" .AND. Empty(cProduto)
		Alert('Campo Raça/ Sexo não foram preenchido.')
		Return .F.
	EndIf

	//Verifica se a quantidade de origem está ºerada
	If oModel:GetValue("CALC_TOT","Z0D__TOT01") <= 0
		Alert("Quantidade de origem está errada, informe as origens antes dos destinos.")
		Return .F.
	EndIf

	oGridZ0D := oModel:GetModel( 'Z0DDETAIL' )
	oGridZ0E := oModel:GetModel( 'Z0EDETAIL' )

	nTotDest := oModel:GetValue("CALC_TOT","Z0E__TOT02") //FWFldGet('Z0E__TOT02')
	nTotDest -= oGridZ0E:GetValue( 'Z0E_QUANT' , oGridZ0E:nLine)
	nTotDest += M->Z0E_QUANT

	//VerIfica se a quantidade de destino está ºerada
	If nTotDest < 0
		Alert("Quantidade de destino não pode ser negativa.")
		lRet := .F.
		Return lRet
	EndIf

	//VerIfica se a quantidade de destino é ­aior que a quantidade de origem
	If nTotDest > oModel:GetValue("CALC_TOT","Z0D__TOT01")
		Alert("Quantidade de destino não pode ser maior que quantidade de origem.")
		lRet := .F.
		Return lRet
	EndIf

	nLinAtu  := oGridZ0E:nLine
	cPrdAtu  := oGridZ0E:GetValue( 'Z0E_PROD'  , nLinAtu)
	cLoteAtu := oGridZ0E:GetValue( 'Z0E_LOTORI', nLinAtu)
	nQDest   := 0
	For nI := 1 To oGridZ0E:Length()
		oGridZ0E:GoLine( nI )
		If !oGridZ0E:IsDeleted()
			If oGridZ0E:GetValue("Z0E_PROD", nI) == cPrdAtu ;
					.AND. oGridZ0E:GetValue("Z0E_LOTORI", nI) == cLoteAtu // MB : 29.12.2020

				nQDest += oGridZ0E:GetValue("Z0E_QUANT", nI)
			EndIf
		EndIf
	Next

	oGridZ0E:GoLine( nLinAtu )

	nQtdAux := 0
	For nI := 1 To oGridZ0D:Length()
		oGridZ0D:GoLine( nI )
		If !oGridZ0D:IsDeleted()
			If oGridZ0D:GetValue("Z0D_PROD", nI) == FwFldGet("Z0E_PROD") ;
					.AND. oGridZ0D:GetValue("Z0D_LOTE", nI) == FwFldGet("Z0E_LOTORI") // MB : 29.12.2020

				nQtdAux += oGridZ0D:GetValue("Z0D_QUANT", nI)
			EndIf
		EndIf
	Next

	If nQtdAux < nQDest
		Alert("Quantidade de destino do produto [" + FwFldGet("Z0E_PROD") +;
			" ] lote [" + AllTrim(FwFldGet("Z0E_LOTORI")) + "]" +;
			" não pode ser maior que quantidade de origem [ " +;
			AllTrim(Transform(nQtdAux,"@E 999,999,999")) + " ].")
		lRet := .F.
		Return lRet
	ElseIf nQDest < nQtdAux
		// Reposicionar no produto Origem caso nao tenha sido completamente movimentado
		// oGridZ0D:GoLine( aScan(oGridZ0D:aDataModel,{ |x| x[1][1][6] == cProduto}) )
		// produto e lote // MB : 29.12.2020
		oGridZ0D:GoLine( aScan(oGridZ0D:aDataModel,{ |x| x[1][1][6]+x[1][1][4] == cProduto}) ) // MB : 29.12.2020
	EndIf

Return lRet

// ------------------------------------------------
User Function vldPrdBv(cProduto, cLote, lSelf)
	Local lRet := .T.
	local cAliasQry := GetNextAlias()

	Default cLote := ""
	Default lSelf := .F.

	/*If empty(cProduto)
	FWFldPut("Z0D_PROD", M->Z0C_PROD)
	FWFldPut("Z0E_PROD", M->Z0C_PROD)
	cProduto := M->Z0C_PROD
EndIf*/

BeginSQL alias cAliasQry
	%noParser%
	select 1 EXISTE
	  from %table:SB1% SB1
	 where B1_FILIAL=%xFilial:SB1%
	   and B1_COD=%exp:cProduto%
	   and SB1.%notDel%
EndSQL
If (cAliasQry)->(Eof())
	alert("O produto informado não existe.")
	lRet := .F.
EndIf
(cAliasQry)->(dbCloseArea())

cFiltro := "% "

If lSelf
	cFiltro := " and Z0C_CODIGO<>'" + FWFldGet('Z0C_CODIGO')+ "'"
EndIf

cFiltro += " %"

If lRet
	If !empty(cLote)
		BeginSQL alias cAliasQry
			%noParser%
			select Z0C_CODIGO CODIGO
			  from %table:Z0D% Z0D
			  join %table:Z0C% Z0C on (Z0C_FILIAL=%xFilial:Z0C% and Z0C.%notDel% and Z0C_CODIGO=Z0D_CODIGO)
			 where Z0D_FILIAL=%xFilial:Z0D%
			   and Z0D_PROD=%exp:cProduto%
			   and Z0D_LOTE=%exp:cLote%
			   and Z0C_STATUS in ('1', '4')
			   %exp:cFiltro%
			   and Z0D.%notDel%
			   //and Z0C_CODIGO<>%exp:FWFldGet('Z0C_CODIGO')%
		EndSQL
	else
		BeginSQL alias cAliasQry
			%noParser%
			select Z0C_CODIGO CODIGO
			  from %table:Z0C% Z0C
			 where Z0C_FILIAL=%xFilial:Z0C%
			   and Z0C_PROD=%exp:cProduto%
			   and Z0C_STATUS in ('1', '4')
			   and Z0C.%notDel%
			   //and Z0C_CODIGO<>%exp:FWFldGet('Z0C_CODIGO')%
		EndSQL
	EndIf
	If !(cAliasQry)->(Eof())
		alert("Este produto" + iIf(!empty(cLote),"/lote "," ") + " já está endo transferido pela Movimentação [" + (cAliasQry)->CODIGO + " ] que está ¥m aberto.")
		lRet := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())
EndIf

If lRet
	nSaldoDisp := u_getSldBv(cProduto, cLote)
	If nSaldoDisp <= 0
		alert("O saldo do produto informado está ºerado no estoque.")
		lRet := .F.
	EndIf
EndIf

Return lRet


User Function vldLotBv(cLote, lSelf)
	Local lRet := .T.
	local cAliasQry := GetNextAlias()

	Default lSelf := .F.

	BeginSQL alias cAliasQry
	%noParser%
	select 1 EXISTE
	  from %table:SB8% SB8
	 where B8_FILIAL=%xFilial:SB8%
	   and B8_LOTECTL=%exp:cLote%
	   and SB8.%notDel%
	EndSQL
	If (cAliasQry)->(Eof())
		alert("O lote informado não existe.")
		lRet := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())

	cFiltro := "% "

	If lSelf
		cFiltro += " and Z0C_CODIGO<>'" + FWFldGet('Z0C_CODIGO')+ "'"
	EndIf

	cFiltro += " %"

	If lRet
		BeginSQL alias cAliasQry
		%noParser%
		select Z0C_CODIGO CODIGO
		  from %table:Z0D% Z0D
		  join %table:Z0C% Z0C on (Z0C_FILIAL=%xFilial:Z0C% and Z0C.%notDel% and Z0C_CODIGO=Z0D_CODIGO)
		 where Z0D_FILIAL=%xFilial:Z0D%
		   and Z0D_LOTE=%exp:cLote%
		   and Z0C_STATUS in ('1', '4')
		   %exp:cFiltro%
		   and Z0D.%notDel%
		EndSQL
		If !(cAliasQry)->(Eof())
			alert("Este lote [" + AllTrim(cLote) + " ] já está endo transferido pela Movimentação [" + (cAliasQry)->CODIGO + " ] que está ¥m aberto.")
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

Return lRet


User Function VAMDLA01()
	Local aParam    := PARAMIXB
	Local xRet      := .T.
	Local oObj      := ''
	Local cIdPonto  := ''
	Local cIdModel  := ''
	Local lIsGrid   := .F.
	local cAliasQry := GetNextAlias()
	Local nLinha    := 0
	Local nQtdLinhas := 0
	Local cMsg      := ""
	Local cMsg2 	 := ""

	Local oGrid		 := nil

	If aParam <> NIL

		oObj      := aParam[1]
		cIdPonto  := aParam[2]
		cIdModel  := aParam[3]

		// If cIdPonto == 'FORMPRE' .AND. cIdModel == 'Z0DDETAIL'
		// 	cMiguel	:= "ANALISANDO ... "
		// Else
		If cIdPonto == 'MODELVLDACTIVE'

			If oObj:nOperation = 4 .or. oObj:nOperation = 5
				If Z0C->Z0C_STATUS=="3"
					ApMsgInfo('não é possível realizar operações com Movimentações já efetivadas.')
					Return .F.
				EndIf

				If Z0C->Z0C_STATUS=="4" .and. oObj:nOperation = 5
					ApMsgInfo('não é possível realizar operações com Movimentações já efetivadas.')
					Return .F.
				EndIf

				/*If Z0C->Z0C_ATIVO
				If msgYesNo("Este registro encontra-se ativo, deseja continuar?")
					Help(NIL, NIL, "BLOQ. DE ACAO", NIL, "Esta Movimentação foi marcada como não ativa", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Acesse a Movimentação novamente para continuar."})
					RecLock("Z0C")
						Z0C->Z0C_ATIVO := .F.
					msUnlock()
				EndIf
				Return .F.
			EndIf

			If Z0C->Z0C_TPMOV='2' //Se Apartacao
				BeginSQL alias "QRYATV"
					%noParser%
					select Z0C_CODIGO
					  from %table:Z0C% Z0C
					 where Z0C_FILIAL=%xFilial:Z0C% and Z0C.%notDel%
					   and Z0C_CODIGO<>%exp:Z0C->Z0C_CODIGO%
					   and Z0C_ATIVO='T'
					   and Z0C_EQUIP=%exp:Z0C->Z0C_EQUIP%
					   and Z0C_TPMOV='2'
				EndSQL
				If !QRYATV->(Eof())
					Help(NIL, NIL, "BLOQ. DE ACAO", NIL, "A balanç¡ desta Movimentação já está ¥m uso pela Movimentação [" + QRYATV->Z0C_CODIGO + " ]", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Aguarde a finalizaç£¯ da pesagem em andamento."})
					QRYATV->(dbCloseArea())
					Return .F.
				EndIf
				QRYATV->(dbCloseArea())
			EndIf

			RecLock("Z0C")
			Z0C->Z0C_ATIVO := .T.
			msUnlock()*/
		EndIf

		// ElseIf cIdPonto == 'MODELPOS'
		// ElseIf cIdPonto == 'FORMPOS'
		// ElseIf cIdPonto == 'FORMLINEPRE'
		// ElseIf cIdPonto == 'FORMLINEPOS'
	ElseIf cIdPonto == 'MODELCOMMITTTS'

		/*RecLock("Z0C")
			Z0C->Z0C_ATIVO := .F.
		msUnlock()*/

		If oObj:nOperation == 5
			//Retorna o Status do Produto para liberado
			/*dbSelectArea("SB1")
			dbSetOrder(1)
			If dbSeek(xFilial("SB1")+Z0C->Z0C_PROD)
				RecLock("SB1", .F.)
				SB1->B1_MSBLQL='2'
				msUnlock()
			EndIf*/

			//Atualiza o status para efetivado
			RecLock("Z0C", .F.)
				Z0C->Z0C_STATUS='2'
			msUnLock()

				// Apagar ZV2
			If (TCSqlExec("UPDATE ZV2010 SET D_E_L_E_T_='*' WHERE ZV2_FILIAL='" + FWFldGet('Z0C_FILIAL') + " ' AND ZV2_MOVTO='" + FWFldGet('Z0C_CODIGO') + " ' AND D_E_L_E_T_=' '") < 0)
					Alert("Erro ao excluir movimentacao ZV2: " + FWFldGet('Z0C_CODIGO') + CRLF + TCSQLError())
			EndIf

				// Apagar Z0F
			If (TCSqlExec("UPDATE Z0F010 SET D_E_L_E_T_='*' WHERE Z0F_FILIAL='" + FWFldGet('Z0C_FILIAL') + " ' AND Z0F_MOVTO='" + FWFldGet('Z0C_CODIGO') + " ' AND D_E_L_E_T_=' '") < 0)
					Alert("Erro ao excluir movimentacao Z0F: " + FWFldGet('Z0C_CODIGO') + CRLF + TCSQLError())
			EndIf
		EndIf

		//Corrige inconsistê®£ia da funç£¯ FWFormCommit
		BeginSQL alias cAliasQry
			%noParser%
			select Z0D_PROD, Z0D_SEQ, Z0D_LOTE, count(R_E_C_N_O_) QTD, max(R_E_C_N_O_) ULT
			  from %table:Z0D% Z0D
			 where Z0D_FILIAL=%xFilial:Z0D% 
			   and Z0D_CODIGO=%exp:Z0C->Z0C_CODIGO%
			   and Z0D.%notDel%
			 group by Z0D_PROD, Z0D_SEQ, Z0D_LOTE
			having count(R_E_C_N_O_) > 1
		EndSQL
		if !(cAliasQry)->(Eof())
			dbSelectArea("Z0D")
			while !(cAliasQry)->(Eof())
				dbGoTo((cAliasQry)->ULT)
				RecLock("Z0D", .F.)
				Z0D->(dbDelete())
				msUnlock()
				(cAliasQry)->(dbSkip())
			EndDo
		endIf
		(cAliasQry)->(DbCloseArea())

		cAliasQry := GetNextAlias()

		//Corrige inconsistê®£ia da funç£¯ FWFormCommit
		BeginSQL alias cAliasQry
			%noParser%
			select Z0E_PROD, Z0E_SEQ, Z0E_LOTE, count(R_E_C_N_O_) QTD, max(R_E_C_N_O_) ULT
			  from %table:Z0E% Z0E
			 where Z0E_FILIAL=%xFilial:Z0E% 
			   and Z0E_CODIGO=%exp:Z0C->Z0C_CODIGO%
			   and Z0E.%notDel%
			 group by Z0E_PROD, Z0E_SEQ, Z0E_LOTE
			having count(R_E_C_N_O_) > 1
		EndSQL
		if !(cAliasQry)->(Eof())
			dbSelectArea("Z0E")
			while !(cAliasQry)->(Eof())
				dbGoTo((cAliasQry)->ULT)
				RecLock("Z0E", .F.)
				Z0E->(dbDelete())
				msUnlock()
				(cAliasQry)->(dbSkip())
			EndDo
		endIf
		(cAliasQry)->(DbCloseArea())

		oGrid := oObj:GetModel( 'Z0EDETAIL' )
		U_DelLoteSB8( oGrid:GetValue('Z0E_CODIGO') )

		//ApMsgInfo('Chamada apos a gravaç£¯ total do modelo e dentro da transaç£¯ (MODELCOMMITTTS).' + CRLF + 'ID ' + cIdModel )
		// ElseIf cIdPonto == 'MODELCOMMITNTTS'

		// Alert('MODELCOMMITNTTS')

	ElseIf cIdPonto == 'MODELCANCEL'

			/*RecLock("Z0C")
			Z0C->Z0C_ATIVO := .F.
			msUnlock()*/
			// ApMsgInfo('Cancelado')

			// Disponibilizar o Lote reservado
			oGrid := oObj:GetModel( 'Z0EDETAIL' )
			// for nI := 1 To oGrid:Length()
			// 	oGrid:GoLine( nI )
			// 	// If !oGrid:IsDeleted()
			// 		U_DelLoteSB8( oGrid:GetValue('Z0E_LOTE', nI) )
			//
			// 		// Alert( oGrid:GetValue('Z0E_LOTE', nI) )
			// 	// EndIf
			// Next nI
			U_DelLoteSB8( oGrid:GetValue('Z0E_CODIGO') )

		// ElseIf cIdPonto == 'BUTTONBAR'
	EndIf

EndIf

Return xRet



/*User function JRVWTELA()
PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" TABLES "SB1,SBZ,SB2"

lConfirm	:= .F.
__cInterNet		:= NIL
InitPublic()
SetsDefault()
SetModulo( "SIGAEST" , "EST" )
//__cInterNet	:= NIL
lMsHelpAuto		:= .T.
lMsFinalAuto	:= .T.


Private oMainWnd

DEFINE FONT oFont NAME "Courier New" SIZE 0,-11 BOLD

bWindowInit	:= { || Selecao(oModel), "Tela" }

	define window oMainWnd title "Impressã¯ de Etiquetas de Localizaç£¯ de Produtos" from 100, 000 To 200, 470 pixel

	Activate window oMainWnd MAXIMIZED ON INIT ( Eval( bWindowInit ) , oMainWnd:End() )

RESET ENVIRONMENT
Return*/



/*/{Protheus.doc} Selecao
Rotina que exibe uma tela para o preenchimento dos dados dos cheques
@author Renato de Bianchi
@since 29/10/2018
@version 1.0
@Return ${Return}, ${Return_description}
@param cNumOrc, characters, descricao
@type function
/*/
static function Selecao(oModel, oView)
	local nOpc         := GD_UPDATE
	local cLinOk       := "AllwaysTrue" //"StaticCall(JRFIN001, CopiaLin)"
	local cTudoOk      := "AllwaysTrue"
	// local cIniCpos  := "E1_NUM"
	// local nFreeze   := 000
	// local nMax      := 999
	// local cFieldOk  := "AllwaysTrue"
	// local cSuperDel := ""
	// local cDelOk    := "AllwaysFalse"
	local nTamLin      := 16
	local nLinIni      := 03
	local nLinAtu      := nLinIni
	// Local oModel       := FWModelActive() //FWLoadModel( 'VAMVCA01' )
	Local nI           := 0, nJ := 0
	Local aItems       := {}

	Private oDlg

	Private nRadRaca   := 0, nRadDent  := 0
	Private aHeadOri   := {}
	Private aColsOri   := {}
	Private nUsadOri   := 0

	Private aHeadDes   := {}
	Private aColsDes   := {}
	Private nUsadDes   := 0

	Private aHeadDet   := {}
	Private aColsDet   := {}
	Private nUsadDet   := 0

	Private aHeadRan   := {}
	Private aColsRan   := {}
	Private nUsadRan   := 0

	Private aHeadVw    := {}
	Private aColsVw    := {}
	Private nUsadVw    := 0

	Private oGetDados

	Private cBov       := Z0C->Z0C_PROD //"BOV000000012345"
	Private nQtdOri    := 0
	Private nQtdDes    := 0

	Private nPeso      := 0
	Private nPesBal    := 0

	Private oGridOri   := oModel:GetModel( 'Z0DDETAIL' )
	Private oGridDes   := oModel:GetModel( 'Z0EDETAIL' )

	Private cTempo     := cMedia := "00:00:00"
	Private cLoteForce := ""
	Private cCurrForce := ""
	Private cLoteOri   := ""
	Private cCurrOri   := ""
	Private cRacaOri   := ""
	Private cSexoOri   := ""
	// Private cDentOri   := ""

	Private aHeadVL	:= {}
	Private nPosVW_LOTE   := 0
	Private nPosVW_CURRAL := 0
	Private nPosVW_RACA   := 0
	Private nPosVW_SEXO   := 0
	Private nPosVW_QUANT  := 0
	Private nPosVW_QTDPES := 0

	If Z0C->Z0C_TPMOV/* FwFldGet('Z0C_TPMOV') */ != "2"
		msgInfo('A Pesagem é °ermitida apenas quando o tipo de Movimentação é ¢Apartação"')
		Return
	EndIf

	aSize := MsAdvSize(.F.)

	/*
	 MsAdvSize (http://tdn.totvs.com/display/public/mp/MsAdvSize+-+Dimensionamento+de+Janelas)
	 aSize[1] = 1 -> Linha inicial á²¥a trabalho.
	 aSize[2] = 2 -> Coluna inicial á²¥a trabalho.
	 aSize[3] = 3 -> Linha final á²¥a trabalho.
	 aSize[4] = 4 -> Coluna final á²¥a trabalho.
	 aSize[5] = 5 -> Coluna final dialog (janela).
	 aSize[6] = 6 -> Linha final dialog (janela).
	 aSize[7] = 7 -> Linha inicial dialog (janela).
	*/
	nQtdOri := 0
	aHeadOri := GeraHeader("Z0D", .T.)
	nUsadOri := len(aHeadOri)
	For nI := 1 To oGridOri:Length()
		oGridOri:GoLine( nI )

		If !oGridOri:IsDeleted()
			aAdd(aColsOri, Array(nUsadOri+1))
			aColsOri[len(aColsOri), nUsadOri+1] := .F.
			for nJ := 1 to len(aHeadOri)
				aColsOri[len(aColsOri), nJ] := oGridOri:GetValue(aHeadOri[nJ, 2], nI)

				If aHeadOri[nJ,2] = "Z0D_QUANT"
					nQtdOri += oGridOri:GetValue(aHeadOri[nJ, 2], nI)
				EndIf
			endFor
		EndIf
	Next

	aHeadVL := {}
	/*01*/aAdd(aHeadVL, { "Lote"	   , "VW_LOTE"	, X3Picture("Z0D_LOTE")	  , TamSX3("Z0D_LOTE")[1]		 , 0 ,"AllwaysTrue()", X3Uso("Z0D_LOTE")	, "C", "   ", "V","","","","V","","","" } )
	/*02*/aAdd(aHeadVL, { "Curral"	   , "VW_CURRAL", X3Picture("Z0D_CURRAL") , 10/*TamSX3("Z0D_CURRAL")[1]*/, 0 ,"AllwaysTrue()", X3Uso("Z0D_CURRAL")	, "C", "   ", "V","","","","V","","","" } )
	/*03*/aAdd(aHeadVL, { "Raca"	   , "VW_RACA"	, X3Picture("Z0D_RACA")   , TamSX3("Z0D_RACA")[1]        , 0 ,"AllwaysTrue()", X3Uso("Z0D_RACA")	, "C", "   ", "V","","","","V","","","" } )
	/*04*/aAdd(aHeadVL, { "Sexo"	   , "VW_SEXO"	, X3Picture("Z0D_SEXO")   , TamSX3("Z0D_SEXO")[1]+5 	 , 0 ,"AllwaysTrue()", X3Uso("Z0D_SEXO")	, "C", "   ", "V","","","","V","","","" } )
	// /*05*/aAdd(aHeadVL, { "Dentiç£¯"   , "VW_DENTIC", X3Picture("Z0D_DENTIC") , TamSX3("Z0D_DENTIC")[1]	 , 0 ,"AllwaysTrue()", X3Uso("Z0D_DENTIC")	, "C", "   ", "V","","","","V","","","" } )
	/*05*/aAdd(aHeadVL, { "Qtd Animais", "VW_QUANT"	, X3Picture("Z0D_QUANT")  , TamSX3("Z0D_QUANT")[1]	     , 0 ,"AllwaysTrue()", X3Uso("Z0D_QUANT")	, "N", "   ", "V","","","","V","","","" } )
	/*06*/aAdd(aHeadVL, { "Qtd Pesada" , "VW_QTDPES", X3Picture("Z0D_QUANT")  , TamSX3("Z0D_QUANT")[1]	     , 0 ,"AllwaysTrue()", X3Uso("Z0D_QUANT")	, "N", "   ", "V","","","","V","","","" } )
	nUsadVL := len(aHeadVL)

	nPosVW_LOTE   := aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_LOTE"})
	nPosVW_CURRAL := aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_CURRAL"})
	nPosVW_RACA   := aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_RACA"})
	nPosVW_SEXO   := aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_SEXO"})
	nPosVW_QUANT  := aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_QUANT"})
	nPosVW_QTDPES := aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_QTDPES"})

	aColsVL := {}
	for nI := 1 to len(aColsOri)
		nPos := aScan(aColsVL, { |x| x[1]==aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_LOTE"})] ;
			.AND. x[3]==aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_RACA"})]   ;
			.AND. x[4]==aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_SEXO"})]   ;
			                   /* .AND. x[5]==aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_DENTIC"})] */ })
		If nPos == 0
			aAdd(aColsVL, Array(nUsadVL+1))
			aColsVL[len(aColsVL),1] := aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_LOTE"})]
			aColsVL[len(aColsVL),2] := aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_CURRAL"})]
			aColsVL[len(aColsVL),3] := aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_RACA"})]
			aColsVL[len(aColsVL),4] := aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_SEXO"})]
			// aColsVL[len(aColsVL),5] := aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_DENTIC"})]
			aColsVL[len(aColsVL),5] := aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_QUANT"})]
			aColsVL[len(aColsVL),6] := 0
			aColsVL[len(aColsVL), nUsadVL+1] := .F.
		else
			aColsVL[nPos,5] += aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_QUANT"})]
		EndIf
	Next

	//aColsOri :=  oGridOri:aCols //{}

	aHeadDes := GeraHeader("Z0E", .T.)
	nUsadDes := len(aHeadDes)
	aColsDes := {}

	aHeadVw := {}
	aAdd(aHeadVw,{ "Lote"			 , "VW_LOTE"		, X3Picture("Z0E_LOTE")		,TamSX3("Z0E_LOTE")[1]		, 0		,"AllwaysTrue()"		, X3Uso("Z0E_LOTE")		, "C", "   ", "V","","","","V","","","" } )
	aAdd(aHeadVw,{ "Curral"			 , "VW_CURRAL"		, X3Picture("Z0E_CURRAL")	,12							, 0		,"AllwaysTrue()"		, X3Uso("Z0E_CURRAL")	, "C", "   ", "V","","","","V","","","" } )
	aAdd(aHeadVw,{ "Peso Medio"		 , "VW_PESO"		, X3Picture("B1_PESO")		,TamSX3("B1_PESO")[1]		, 3		,"AllwaysTrue()"		, X3Uso("B1_PESO")		, "N", "   ", "V","","","","V","","","" } )
	aAdd(aHeadVw,{ "UA"				 , "VW_UA"			, X3Picture("B1_PESO")		,TamSX3("B1_PESO")[1]		, 2		,"AllwaysTrue()"		, X3Uso("B1_PESO")		, "N", "   ", "V","","","","V","","","" } )
	aAdd(aHeadVw,{ "Qtde Apartacao"  , "VW_QUANT"		, X3Picture("Z0E_QUANT")	,TamSX3("Z0E_QUANT")[1]		, 0		,"AllwaysTrue()"		, X3Uso("B1_PESO")		, "N", "   ", "V","","","","V","","","" } )
	aAdd(aHeadVw,{ "Saldo Lote Atu"	 , "VW_QTLOTE"		, X3Picture("Z0E_QUANT")	,TamSX3("Z0E_QUANT")[1]		, 0		,"AllwaysTrue()"		, X3Uso("B1_PESO")		, "N", "   ", "V","","","","V","","","" } )
	nUsadVw := len(aHeadVw)
	aColsVw := {}

	aHeadDet := GeraHeader("Z0F", .F.)
	aAdd(aHeadDet,{ "Contrato"			, "Z0F_CONTR"		, X3Picture("ZBC_CODIGO")	,TamSX3("ZBC_CODIGO")[1]	, 0	,"AllwaysTrue()"		, X3Uso("ZBC_CODIGO")	, "C", "   ", "V","","","","V","","","" } )
	aAdd(aHeadDet,{ "Pedido"			, "Z0F_PEDID"		, X3Picture("ZBC_PEDIDO")	,TamSX3("ZBC_PEDIDO")[1]	, 0	,"AllwaysTrue()"		, X3Uso("ZBC_PEDIDO")	, "C", "   ", "V","","","","V","","","" } )
	aAdd(aHeadDet,{ "Fornecedor"		, "Z0F_FORNE"		, X3Picture("A2_NOME")		,TamSX3("A2_NOME")[1]		, 0	,"AllwaysTrue()"		, X3Uso("A2_NOME")		, "C", "   ", "V","","","","V","","","" } )
	aAdd(aHeadDet,{ "Reg.","NRECNO","",10,0,"","","N","","V","","","","V","","","" } )
	/*
	aAdd(aHeadDet,{ "Peso"			, "JR_PAR10"		, X3Picture("B1_PESO")		,TamSX3("B1_PESO")[1]		, 0		,"StaticCall(JRFIN001, ValNum)"		, X3Uso("B1_PESO")		, "N", "   ", "V","","","","A","","","" } )
	*/
	nUsadDet := len(aHeadDet)
	aColsDet := {}
	aColsDet := U_AtualizaZ0F(.F.)

	// nPRecno := aScan( aHeadDet, {|a1| a1[2]="NRECNO"})
	// aSort(aColsDet,,,{ |x, y| x[nPRecno] > y[nPRecno] })

	aHeadRan := GeraHeader("ZV2", .F.)
	aHeadRan[aScan( aHeadRan,{ |x| AllTrim(x[2]) == "ZV2_PESINI"}), 6] := "Positivo() .and. U_VLDRANGES(.T.)"
	aHeadRan[aScan( aHeadRan,{ |x| AllTrim(x[2]) == "ZV2_PESFIM"}), 6] := "Positivo() .and. U_VLDRANGES(.T.)"
	nUsadRan := len(aHeadRan)
	aColsRan := {}
	BeginSQL alias "QRYR"
		%noParser%
		select * from %table:ZV2% ZV2
		 where ZV2_FILIAL=%xFilial:ZV2%
		   and ZV2_MOVTO=%exp:Z0C->Z0C_CODIGO% // and ZV2_MOVTO=%exp:FWFldGet('Z0C_CODIGO')%
		   and ZV2.%notDel%
		 order by ZV2_PESINI
	EndSQL
	If !QRYR->(Eof())
		while !QRYR->(Eof())
			aAdd(aColsRan, Array(nUsadRan+1))
			aColsRan[len(aColsRan), nUsadRan+1] := .F.
			for nJ := 1 to len(aHeadRan)
				aColsRan[len(aColsRan), nJ] := &("QRYR->" + aHeadRan[nJ, 2])
			Next
			QRYR->(dbSkip())
		EndDo
	else
		BeginSQL alias "QRYP"
			%noParser%
			select * from %table:ZV1% ZV1
			 where ZV1_FILIAL=%xFilial:ZV1%
			   and ZV1.%notDel%
			 order by ZV1_PESINI
		EndSQL
		while !QRYP->(Eof())
			RecLock("ZV2", .T.)
				ZV2->ZV2_FILIAL := xFilial("ZV2")
				ZV2->ZV2_MOVTO  := Z0C->Z0C_CODIGO // FWFldGet('Z0C_CODIGO')
				ZV2->ZV2_PESINI := QRYP->ZV1_PESINI
				ZV2->ZV2_PESFIM := QRYP->ZV1_PESFIM
				ZV2->ZV2_LOTE   := QRYP->ZV1_LOTE
				ZV2->ZV2_CURRAL := QRYP->ZV1_CURRAL
			MsUnlock()

			aAdd(aColsRan, Array(nUsadRan+1))
			aColsRan[len(aColsRan), nUsadRan+1] := .F.
			aColsRan[len(aColsRan), 1] := Z0C->Z0C_CODIGO // FWFldGet('Z0C_CODIGO')
			aColsRan[len(aColsRan), 2] := QRYP->ZV1_PESINI
			aColsRan[len(aColsRan), 3] := QRYP->ZV1_PESFIM
			aColsRan[len(aColsRan), 4] := QRYP->ZV1_LOTE
			aColsRan[len(aColsRan), 5] := QRYP->ZV1_CURRAL

			QRYP->(DbSkip())
		EndDo
		QRYP->(DbCloseArea())
	EndIf
	QRYR->(DbCloseArea())

	nTop    := aSize[1]
	nLeft   := aSize[2]-10
	nBottom := aSize[3]*(14/15)
	nRight  := aSize[5]*(14/15)

	define msDialog oDlg title "Pesagem de Animais: " + Z0C->Z0C_CODIGO /*STYLE DS_MODALFRAME*/ From nTop,nLeft To nBottom,nRight OF oMainWnd PIXEL
	//oDlg:lMaximized := .T. //Maximiza a janela

	oSayTempo := TSay():New(nLinAtu, 10,{|| 'Processamento de Animais: (Apartação)  Tempo: '+cTempo+'  Mé¤©a p/ animal: '+cMedia},oDlg,,,,,,.T.,,,500,10)
	oSayTempo:SetCss("QLabel{ color: #222; font-weight: bold; font-size: 12pt}")

	oTButton1 := TButton():New( nLinAtu-1, (nRight)/2 - 60 , "Confirmar" ,oDlg,;
		{|| FWMsgRun(, {|| U_SalvarGeral( oModel, oView ) },;
		"Processando", "Gravando pesagens no movimento...") }, 55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton1:SetCss("QPushButton{ background: #2C2; color: #FFF; margin: 2px; font-weight: bold; }")

	nLinAtu += nTamLin
	nLinAtu += nTamLin+4

	oSayOri := TSay():New(nLinAtu - nTamLin, 10 ,{||'Lotes de Origem'},oDlg,,,,,,.T.,,,100,30)
	oSayOri:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 16pt; text-decoration: underline}")
	oGetDadOri:= MsNewGetDados():New(nLinAtu, 10, (nBottom)/4 - 30, (nRight)/6 + 6, nOpc , cLinOk, cTudoOk,,,,999999,,,,oDlg, aHeadOri, aColsOri)
	oGetDadVL:= MsNewGetDados():New( nLinAtu, 10, (nBottom)/4 - 30, (nRight)/6 + 6, nOpc , cLinOk, cTudoOk,,,,999999,,,,oDlg, aHeadVL, aColsVL)
	oSayFOri := TSay():New(nLinAtu - nTamLin + 2, 100 ,{||''},oDlg,,,,,,.T.,,,200,30)
	oGetDadVL:oBrowse:blDblClick :=  {|| U_ForceOri()}

	oSayQO := TSay():New((nBottom)/4 - 20, 10,{|| 'QTDE ORIGEM: '+cValToChar(nQtdOri) },oDlg,,,,,,.T.,,,200,20)
	oSayQO:SetCss("QLabel   { color: #000; font-weight: bold; font-size: 12pt}")

	oSayDes := TSay():New(nLinAtu - nTamLin, (nRight)/2 - (nRight)/6 ,{||'Lotes de Destino'},oDlg,,,,,,.T.,,,100,30)
	oSayDes:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 16pt; text-decoration: underline}")
	oGetDadDes:= MsNewGetDados():New(nLinAtu, (nRight)/2 - (nRight)/6	, (nBottom)/4 -30, (nRight)/2 -3, nOpc , cLinOk, cTudoOk,,,,999999,,,,oDlg, aHeadDes, aColsDes)
	oGetDadVw:= MsNewGetDados():New(nLinAtu, (nRight)/2 - (nRight)/6	, (nBottom)/4 -30, (nRight)/2 -3, nOpc , cLinOk, cTudoOk,,,,999999,,,,oDlg, aHeadVw, aColsVw)

	oSayQD := TSay():New((nBottom)/4 - 20, (nRight)/2 - (nRight)/6,{|| 'QTDE DESTINO: '+cValToChar(nQtdDes) },oDlg,,,,,,.T.,,,200,20)
	oSayQD:SetCss("QLabel   { color: #000; font-weight: bold; font-size: 12pt}")

	nPeso := 0
	oSayPeso := TSay():New(nLinAtu - nTamLin-5, (nRight)/4 - 20 ,{||'Peso'},oDlg,,,,,,.T.,,,100,30)
	oSayPeso:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 24pt}")
	oGet1 := TGet():New( nLinAtu, (nRight)/4 - 80, { | u | If( PCount() == 0, nPeso, nPeso := u ) },oDlg, 160, 030, "@E 9,999.999",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nPeso")
	oGet1:SetCss("QLineEdit{ color: #000; font-weight: bold; font-size: 24pt}")

	oTButton2 := TButton():New( nLinAtu + nTamLin*2+5, (nRight)/4 - 80, "Pesar" ,oDlg,{|| FWMsgRun(, {|| wsBalanca := TWsBalanca():New(), nPeso := wsBalanca:CallPesar(), nPesBal := nPeso }, "Processando", "Obtendo peso da balanca...") }, 55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2:SetCss("QPushButton{ background: #22C; color: #FFF; margin: 2px; font-weight: bold; }")

	oTButton3 := TButton():New( nLinAtu + nTamLin*2+5, (nRight)/4 - 25, "Registrar", oDlg,;
		{|| FWMsgRun(, {|| U_Registrar( oModel /* oGetDadDet:aCols */) },;
		"Processando", "Gravando peso no movimento...") }, 55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton3:SetCss("QPushButton{ background: #2C2; color: #FFF; margin: 2px; font-weight: bold; }")

	aItems := {'nenhum'}
	// comboRaca 
	BeginSQL alias "QCMB"
	%noParser%
	SELECT distinct Z09_RACA
	  FROM %table:Z09% Z09
	 WHERE Z09_FILIAL=%xFilial:Z09%
	   AND Z09_RACA <> ' '
	   AND Z09_RACA NOT LIKE 'BUFAL%'
	   AND Z09.%notDel%
	 ORDER by 1 desc
	EndSQL
	while !QCMB->(Eof())
		If !empty(QCMB->Z09_RACA)
			// cCombo += If(empty(cCombo),"",",") + AllTrim(QCMB->Z09_RACA)// + " =" + AllTrim(QCMB->Z09_RACA)

			aAdd(aItems, AllTrim(QCMB->Z09_RACA))
		EndIf
		QCMB->(dbSkip())
	EndDo
	QCMB->(dbCloseArea())

	nRadRaca := 1
	oRadRaca := TRadMenu():New ( nLinAtu + nTamLin*4, (nRight)/4 -80, aItems,, oDlg,,,,,,,,50, 00,,,,.T.)
	oRadRaca:bSetGet := {|u|Iif (PCount()==0,nRadRaca,nRadRaca:=u)}
	oRadRaca:SetCss("QRadioButton{ font-weight: bold; font-size: 12pt}")

	nRadDent := 1
	aItems := {'nenhum','0=Zero','2=Dois','4=Quatro','6=Seis','8=Oito'}
	oRadDent := TRadMenu():New (nLinAtu + nTamLin*4, (nRight)/4 + 20, aItems,, oDlg,,,,,,,,50, 00,,,,.T.)
	oRadDent:bSetGet := {|u|Iif (PCount()==0,nRadDent,nRadDent:=u)}
	oRadDent:SetCss("QRadioButton{ font-weight: bold; font-size: 12pt}")

	nLinAtu := nTamLin*8 + 4

	nLinAtu := (nBottom)/4 + 10
	oSayDet := TSay():New(nLinAtu - nTamLin, 10 ,{||'Pesagens realizadas'},oDlg,,,,,,.T.,,,200,30)
	oSayDet:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 16pt; text-decoration: underline}")
	oGetDadDet:= MsNewGetDados():New(nLinAtu, 10      , (nBottom)/2 -10, (nRight)/2 - (nRight)/6 - 10, nOpc+GD_DELETE , cLinOk     , cTudoOk   ,            ,          ,           ,999999  ,;
		"U_ChangeZ0F()",,;
		"U_DeleteZ0F()" ,oDlg, aHeadDet, aColsDet)
				 MsNewGetDados():New([ nTop], [ nLeft], [ nBottom]     , [ nRight ]                  , [ nStyle]      , [ cLinhaOk], [ cTudoOk], [ cIniCpos], [ aAlter], [ nFreeze], [ nMax], [ cFieldOk]                      , [ cSuperDel], [ cDelOk]                         , [ oWnd], [ aPartHeader], [ aParCols], [ uChange], [ cTela] )
	oGetDadDet:bChange := { || U_calcular_destino() }

	oSayRan := TSay():New(nLinAtu - nTamLin, (nRight)/2 - (nRight)/6 ,{||'Parametros'},oDlg,,,,,,.T.,,,200,30)
	oSayRan:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 16pt; text-decoration: underline}")
	oGetDadRan:= MsNewGetDados():New(nLinAtu, (nRight)/2 - (nRight)/6, (nBottom)/2 - 10, (nRight)/2 -3 , GD_INSERT+GD_UPDATE+GD_DELETE , cLinOk, cTudoOk,,,,999999,;
		"U_SalvarRange()",,,oDlg, aHeadRan, aColsRan)
	oGetDadRan:oBrowse:blDblClick :=  {|| U_ForceLote()}
	oSayForce := TSay():New(nLinAtu - nTamLin + 5, (nRight)/2 - (nRight)/6 + 70 ,{||''},oDlg,,,,,,.T.,,,200,30)

	oSayFt := TSay():New(nLinAtu -20, (nRight)/4 - 80,{|| 'FALTAM [ '+cValToChar(nQtdOri-nQtdDes)+' ] ANIMAIS PARA PESAR' },oDlg,,,,,,.T.,,,200,20)
	oSayFt:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 14pt}")

	If oModel:nOperation <> 4
		SetKey(VK_F5, {|| FWMsgRun(, {|| U_AtualizaZ0F(.T.) }, "Atualizando", "Buscando pesagens...") })
	EndIf
	SetKey(VK_F10, {|| FWMsgRun(, {|| wsBalanca := TWsBalanca():New(), nPeso := wsBalanca:CallPesar(), nPesBal := nPeso }) })
	SetKey(VK_F11, {|| FWMsgRun(, {|| U_Registrar( oModel /* oGetDadDet:aCols */) }, "Processando", "Gravando peso no movimento...") })

	//nMilissegundos := 3000 // Disparo será ¤e 2 em 2 segundos
	//oTimer := TTimer():New(nMilissegundos, {|| wsBalanca := TWsBalanca():New(), nPeso := wsBalanca:CallPesar(), oGet1:CtrlRefresh(), oDlg:CtrlRefresh(), ObjectMethod(oDlg,"Refresh()") }, oDlg )
	//oTimer:Activate()
	//calcular_destino()
	Activate dialog oDlg centered

	SetKey(VK_F5, {||  })
	SetKey(VK_F10, {||  })
	SetKey(VK_F11, {||  })
Return

Return !lErro

User Function AtualizaZ0F(lGrid)
	local aColsDet := {}
	Local nJ := 0

	default lGrid := .T.

	BeginSQL alias "QRYP"
	%noParser%
	select Z0F.*, Z0F.R_E_C_N_O_ NRECNO, ZBC_CODIGO Z0F_CONTR, ZBC_PEDIDO Z0F_PEDID, A2_NOME Z0F_FORNE
	  from %table:Z0F% Z0F
	  left join %table:ZBC% ZBC on (ZBC.ZBC_FILIAL=%xFilial:ZBC% and ZBC.%notDel% and ZBC_PRODUT=Z0F_PROD and ZBC_VERSAO=(select max(ZBC_VERSAO) from %table:ZBC% Z2 where Z2.ZBC_FILIAL=ZBC.ZBC_FILIAL and Z2.ZBC_CODIGO=ZBC.ZBC_CODIGO and Z2.%notDel%))
	  left join %table:SA2% SA2 on (SA2.A2_FILIAL=%xFilial:SA2% and SA2.%notDel% and A2_COD=ZBC_CODFOR and A2_LOJA=ZBC_LOJFOR)
	 where Z0F_FILIAL=%xFilial:Z0F%
	   and Z0F_MOVTO=%exp:Z0C->Z0C_CODIGO%
	   and Z0F.%notDel%
	 order by Z0F_MOVTO, Z0F_SEQ
	EndSQL
	// order by Z0F_MOVTO, Z0F_LOTE, Z0F_RACA, Z0F_SEXO, Z0F_DENTIC, Z0F_SEQ
	while !QRYP->(Eof())
		aAdd(aColsDet, Array(nUsadDet+1))
		aColsDet[len(aColsDet), nUsadDet+1] := .F.
		for nJ := 1 to len(aHeadDet)
			If aHeadDet[nJ, 8] = 'D'
				aColsDet[len(aColsDet), nJ] := STOD( &("QRYP->" + aHeadDet[nJ, 2]) )
			elseIf !empty(aHeadDet[nJ, 11]) .and. aHeadDet[nJ, 8] = 'C'
				aColsDet[len(aColsDet), nJ] := AllTrim( &("QRYP->" + aHeadDet[nJ, 2]) )
			else
				aColsDet[len(aColsDet), nJ] := &("QRYP->" + aHeadDet[nJ, 2])
			EndIf
		endFor

		QRYP->(DbSkip())
	EndDo
	QRYP->(DbCloseArea())

	If lGrid
		nPRecno := aScan( aHeadDet, {|a1| a1[2]="NRECNO"})
		aSort(aColsDet,,,{ |x, y| x[nPRecno] > y[nPRecno] })

		oGetDadDet:setArray(aColsDet)
		oGetDadDet:oBrowse:Refresh()

		U_calcular_destino()
	EndIf

Return aColsDet


Static Function GetQtdPesadosLote(cLote, cRaca, cSexo, cDent)
	local nRet := 0
	local aSaldos := GetSldOrigem()
	Local nI		:= 0

	for nI := 1 to len(aSaldos)
		If AllTrim(aSaldos[nI, 1]) == AllTrim(cLote) /*.AND.;
				AllTrim(aSaldos[nI, 5]) == AllTrim(cRaca) .AND.;
				AllTrim(aSaldos[nI, 6]) == AllTrim(cSexo) .AND.;
				AllTrim(aSaldos[nI, 7]) == AllTrim(cDent) */

			nRet += aSaldos[nI, 4]
		EndIf
	Next

Return nRet


User Function ForceOri()
	// local aSaldos := GetSldOrigem()

	/*nPosS := aScan(aSaldos, { |x| x[1]=oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_LOTE] })
	If nPosS > 0 .and. aSaldos[nPosS, 4] = aSaldos[nPosS, 3]
		msgInfo("O lote selecionado já¦oi atendido totalmente nas pesagens anteriores, verIfique se foi selecionado o lote correto.")
		Return nil
	EndIf*/
	//If oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, 7] == oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, 6]
	If oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_QTDPES] == oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_QUANT]
		msgInfo("O lote selecionado já¦oi atendido totalmente nas pesagens anteriores, verIfique se foi selecionado o lote correto.")
		Return nil
	EndIf

	If empty(cLoteOri)  .and.;
			Empty(cCurrOri) .and.;
			Empty(cRacaOri) .and.;
			Empty(cSexoOri) /* .and.;
			Empty(cDentOri) */

		cLoteOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_LOTE]
		cCurrOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_CURRAL]
		cRacaOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_RACA]
		cSexoOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_SEXO]
		// cDentOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_DENTIC"})]

		else

		If cLoteOri == oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_LOTE]    .AND.;
				cCurrOri == oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_CURRAL] .AND.;
				cRacaOri == oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_RACA]   .AND.;
				cSexoOri == oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_SEXO]   /* .AND.;
				cDentOri == oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_DENTIC"})]*/

				cLoteOri := ""
				cCurrOri := ""
				cRacaOri := ""
				cSexoOri := ""
				// cDentOri := ""
			else
				cLoteOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_LOTE]
				cCurrOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_CURRAL]
				cRacaOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_RACA]
				cSexoOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_SEXO]
				/* cDentOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_DENTIC"})]*/
		EndIf
	EndIf

	If !empty(cLoteOri)
		oSayFOri:SetText("Lote: " + AllTrim(cLoteOri) + "  - Curral: " + AllTrim(cCurrOri)+;
			' - ' +AllTrim(cRacaOri)+;
			' - ' +AllTrim(cSexoOri) )
			/* + ' - ' +AllTrim(cDentOri) */
	else
		oSayFOri:SetText("")
	EndIf
Return


User Function ForceLote()
	If empty(cLoteForce)
		cLoteForce := oGetDadRan:aCols[oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_LOTE"})]
		cCurrForce := oGetDadRan:aCols[oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_CURRAL"})]
	else
		If cLoteForce = oGetDadRan:aCols[oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_LOTE"})]
			cLoteForce := ""
			cCurrForce := ""
		else
			cLoteForce := oGetDadRan:aCols[oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_LOTE"})]
			cCurrForce := oGetDadRan:aCols[oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_CURRAL"})]
		EndIf
	EndIf

	If !empty(cLoteForce)
		oSayForce:SetText("Selecionado Lote: " + AllTrim(cLoteForce) + "  - Curral: " + AllTrim(cCurrForce))
	else
		oSayForce:SetText("")
	EndIf
Return


User Function vldRanges(lLinha)
	// Local oModel := FWModelActive()
	Local nI		:= 0
	Local nL		:= 0

	default lLinha := .F.

	// If oModel:nOperation <> 4
	// 	Return .F.
	// EndIf

	//Valida a propria linha
	If lLinha
		nPesIni := 0
		nPesFim := 0
		If "ZV2_PESINI" $ ReadVar()
			nPesIni := &(ReadVar())
		else
			nPesIni := oGetDadRan:aCols[oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})]
		EndIf

		If "ZV2_PESFIM" $ ReadVar()
			nPesFim := &(ReadVar())
		else
			nPesFim := oGetDadRan:aCols[oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})]
		EndIf

		If !oGetDadRan:aCols[oGetDadRan:oBrowse:nAt, nUsadRan+1]
			If nPesIni > 0 .and. nPesFim > 0
				If nPesIni >= nPesFim
					msgAlert("O Peso inicial deve ser menor que o peso final.")
					Return .F.
				EndIf
			EndIf
		EndIf

		for nI := 1 to len(oGetDadRan:aCols)
			If !oGetDadRan:aCols[ nI, nUsadRan+1]
				If oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] > 0 .and. oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})] > 0

					If oGetDadRan:oBrowse:nAt != nI
						If nPesIni >= oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] .and. nPesIni <= oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})]
							msgAlert("O Peso Inicial informado na linha [" + cValToChar(oGetDadRan:oBrowse:nAt) + " ] já¥ncontra-se informado na linha: " + cValToChar(nI))
							Return .F.
						EndIf

						If nPesFim >= oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] .and. nPesFim <= oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})]
							msgAlert("O Peso Final informado na linha [" + cValToChar(oGetDadRan:oBrowse:nAt) + " ] já¥ncontra-se informado na linha: " + cValToChar(nI))
							Return .F.
						EndIf

						If oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] >= nPesIni  .and. oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] <= nPesFim
							msgAlert("O Peso Inicial informado na linha [" + cValToChar(nI) + " ] já¥ncontra-se informado na linha: " + cValToChar(oGetDadRan:oBrowse:nAt))
							Return .F.
						EndIf

						If oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})] >= nPesIni .and. oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})] <= nPesFim
							msgAlert("O Peso Final informado na linha [" + cValToChar(nI) + " ] já¥ncontra-se informado na linha: " + cValToChar(oGetDadRan:oBrowse:nAt))
							Return .F.
						EndIf
					EndIf

				EndIf
			EndIf
		endFor
	else
		//valida todas as linhas
		for nI := 1 to len(oGetDadRan:aCols)
			If !oGetDadRan:aCols[ nI, nUsadRan+1]
				If oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] > 0 .and. oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})] > 0
					If oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] >= oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})]
						msgAlert("O Peso final deve ser maior que o peso inicial na linha [" + cValToCHar(nI) + " ].")
						Return .F.
					EndIf

					for nL := 1 to len(oGetDadRan:aCols)
						If nL != nI
							If oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] >= oGetDadRan:aCols[nL, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] .and. oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] <= oGetDadRan:aCols[nL, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})]
								msgAlert("O Peso Inicial informado na linha [" + cValToChar(nI) + " ] já¥ncontra-se informado na linha: " + cValToChar(nL))
								Return .F.
							EndIf

							If oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})] >= oGetDadRan:aCols[nL, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] .and. oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})] <= oGetDadRan:aCols[nL, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})]
								msgAlert("O Peso Final informado na linha [" + cValToChar(nI) + " ] já¥ncontra-se informado na linha: " + cValToChar(nL))
								Return .F.
							EndIf
						EndIf
					Next
				EndIf
			EndIf
		endFor
	EndIf
Return .T.

/* 
	MB : 03.07.2020
		Atualiza Curral;
*/
Static Function AtualCurral(cLote, cCurral)
	Local nI         := 0
	Local nPosLote   := aScan( aHeadDet, {|x| x[2] == "Z0F_LOTE  "})
	Local nPosCurral := aScan( aHeadDet, {|x| x[2] == "Z0F_CURRAL"})
	//Local nPosSeqE   := aScan( aHeadDet, {|x| x[2] == "Z0F_SEQEFE"})

	For nI := 1 to len(oGetDadDet:aCols)
		If oGetDadDet:aCols[nI, nPosLote] == cLote //.and. Empty(oGetDadDet:aCols[nI, nPosSeqE])
			oGetDadDet:aCols[nI, nPosCurral] := cCurral
		EndIf
	Next nI
	oGetDadDet:oBrowse:Refresh()

	// atualizando Z0F
	BeginSQL alias "TEMP" 
		%noParser%
		SELECT  R_E_C_N_O_ // Z0F_RACA RACA, Z0F_SEXO SEXO, Z0F_DENTIC DENTIC, *
		FROM	Z0F010
		WHERE	Z0F_FILIAL = %xFilial:Z0F%
			AND Z0F_MOVTO  = %exp:Z0C->Z0C_CODIGO%
			AND Z0F_LOTE   = %exp:cLote%
			//AND Z0F_SEQEFE = %exp:Space(TamSX3('Z0F_SEQEFE')[1])%
			// a atualizacao dos currais ser feitos por LOTE independente da classificacao de RACA, SEXO E DENTI
			// AND Z0F_PROD   = %exp:oGridZ0E:GetValue('Z0E_PROD'  , nI)%
			// AND Z0F_RACA   = %exp:oGridZ0E:GetValue('Z0E_RACA'  , nI)%
			// AND Z0F_SEXO   = %exp:oGridZ0E:GetValue('Z0E_SEXO'  , nI)%
			// AND Z0F_DENTIC = %exp:oGridZ0E:GetValue('Z0E_DENTIC', nI)%
	EndSQL
	while !TEMP->(Eof())
		Z0F->(DbGoTo(TEMP->R_E_C_N_O_))

		RecLock('Z0F', .F.)
			Z0F->Z0F_CURRAL := cCurral
		Z0F->(MsUnLock())

		TEMP->(dbSkip())
	EndDo
	TEMP->(dbCloseArea())

	U_calcular_destino()
Return nil

/* ==================================================================================== */
User Function SalvarRange()
	local aArea := GetArea()
	local cSql	:= ""
	Local nI	:= 0, nJ := 0

	If !U_vldRanges(.F.)
	    RestArea(aArea)
		Return .F.
	EndIf

		// MB : 05.08.2019
	If ReadVar() == "M->ZV2_LOTE" // .and. ;
		If !U_libVldLote( AllTrim(&(ReadVar())), .T., "M->ZV2_LOTE"/* , @__xRetorno */ )
			RestArea(aArea)
			Return .F.
		EndIf
	EndIf

	If ReadVar() == "M->ZV2_CURRAL" // .and. ;

		If Empty( oGetDadRan:aCols[ oGetDadRan:nAt, 4/*Lote*/] )
			MsgInfo("O campo Lote não foi localizado. O mesmo é necessário para validação do CURRAL.",;
					"Operação Cancelada")
			RestArea(aArea)
			Return .F.
		EndIf
		If !Empty(oGetDadRan:aCols[ oGetDadRan:nAt, 5/*Curral*/]) .and.;
			&(ReadVar()) <> oGetDadRan:aCols[ oGetDadRan:nAt, 5/*Curral*/]

			// verificar se o novo CURRAL informado pertence ao Lote informado;
			BeginSQL alias "qTMP"
				%noParser%
				SELECT DISTINCT B8_LOTECTL, B8_X_CURRA, SUM(B8_SALDO) SALDO
				FROM  %table:SB8%
				WHERE B8_LOTECTL=%exp:oGetDadRan:aCols[ oGetDadRan:nAt, 4/*Lote*/]%
				  AND %notDel%
				GROUP BY B8_LOTECTL, B8_X_CURRA
			EndSQL
			//While !qTMP->(Eof()) 
			
			If !qTMP->(Eof())  .and. &(ReadVar()) <> qTMP->B8_X_CURRA
				Alert("O curral informado: [" + &(ReadVar()) + "] nao pode ser utilizado. Ja existe saldo para o mesmo no curral: " + qTMP->B8_X_CURRA +".")
				RestArea(aArea)
			EndIf
			qTMP->(dbCloseArea())
			//EndDo
			//qTMP->(dbCloseArea())
			If MsgYesNo("O Curral ["+AllTrim(oGetDadRan:aCols[ oGetDadRan:nAt, 5/*Curral*/])+"] foi alterado para ["+;
					AllTrim(&(ReadVar()))+"]. Confirma a alteração do curral ?")
				AtualCurral(oGetDadRan:aCols[ oGetDadRan:nAt, 4/*Lote*/], AllTrim(&(ReadVar())))
			EndIf
		EndIf
	EndIf

	cSql := "update " + retSqlName("ZV2") + " set D_E_L_E_T_='*', R_E_C_D_E_L_=R_E_C_N_O_ where ZV2_FILIAL='" + xFilial("ZV2") + " ' and ZV2_MOVTO = '" +  Z0C->Z0C_CODIGO + "'"
	nStatus := TCSqlExec(cSql)
	If (nStatus < 0)
		conout("TCSQLError() " + TCSQLError())
	EndIf
	
	//// MB : 05.08.2019
	//If ReadVar() == "M->ZV2_LOTE" // .and. ;
	//	If !U_libVldLote( AllTrim(&(ReadVar())), .T., "M->ZV2_LOTE" )
	//		Return .F.
	//	EndIf
	//EndIf
    //
	//If ReadVar() == "M->ZV2_CURRAL" // .and. ;
	//		If !Empty(oGetDadRan:aCols[ oGetDadRan:nAt, 5/*Curral*/]) .and.;
	//			&(ReadVar()) <> oGetDadRan:aCols[ oGetDadRan:nAt, 5/*Curral*/]
	//		If MsgYesNo("O Curral ["+AllTrim(oGetDadRan:aCols[ oGetDadRan:nAt, 5/*Curral*/])+"] foi alterado para ["+;
	//				AllTrim(&(ReadVar()))+"]. Deseja atualizar os lotes que nao foram efetivados?")
	//			AtualCurral(oGetDadRan:aCols[ oGetDadRan:nAt, 4/*LOTE*/], AllTrim(&(ReadVar())))
	//		EndIf
	//	EndIf
	//EndIf
    //
	//cSql := "update " + retSqlName("ZV2") + " set D_E_L_E_T_='*', R_E_C_D_E_L_=R_E_C_N_O_ where ZV2_FILIAL='" + xFilial("ZV2") + " ' and ZV2_MOVTO = '" +  Z0C->Z0C_CODIGO + "'"
	//nStatus := TCSqlExec(cSql)
	//If (nStatus < 0)
	//	conout("TCSQLError() " + TCSQLError())
	//EndIf
	

	for nI := 1 to len(oGetDadRan:aCols)
		If !oGetDadRan:aCols[ nI, nUsadRan+1]
			RecLock("ZV2", .T.)
			ZV2->ZV2_FILIAL := xFilial("ZV2")
			for nJ := 1 to len(aHeadRan)
				If aHeadRan[nJ, 2] = substr(ReadVar(),4) .and. nI = oGetDadRan:oBrowse:nAt
					&("ZV2->" + aHeadRan[nJ, 2] + "  := " + ReadVar())
				else
					&("ZV2->" + aHeadRan[nJ, 2] + "  := oGetDadRan:aCols[ nI, nJ]")
				EndIf
			endFor
			MsUnlock()
		EndIf
	endFor

	restArea(aArea)
Return .T.


Static Function GeraHeader(cAliasHead, lOnlyView)
	local aHead := {}
	default lOnlyView := .F.

	DbSelectArea("SX3")
	DbSetOrder(1)
	dbSeek(cAliasHead)

	while !SX3->(Eof()) .and. SX3->X3_ARQUIVO == cAliasHead

		If X3Uso(SX3->X3_USADO); 				// O Campo é µsado.
			.and. cNivel >= SX3->X3_NIVEL      // Nivel do Usuario >= Nivel do Campo.

			AAdd(aHead, {Trim(SX3->X3_Titulo),;
				SX3->X3_Campo       ,;
				SX3->X3_Picture     ,;
				SX3->X3_Tamanho     ,;
				SX3->X3_Decimal     ,;
				SX3->X3_Valid       ,;
				SX3->X3_Usado       ,;
				SX3->X3_Tipo        ,;
				SX3->X3_F3     		,;
				iIf( lOnlyView, "V", SX3->X3_Visual) ,;
				iIf( "staticcall"$lower(SX3->X3_CBOX), &(StrTran(SX3->X3_CBOX,'#','')), SX3->X3_CBOX )		 })

		EndIf

		SX3->(DbSkip())
	EndDo

Return aHead


Static Function GetSldOrigem()
	Local aSaldos 	:= {}
	Local nI		:= 0, nJ := 0

	for nI := 1 to len(oGetDadOri:aCols)
		If !oGetDadOri:aCols[ nI, nUsadOri+1]
			nQtdPrd := 0
			cVarPrd := oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_PROD"})]
			cVarLot := oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_LOTE"})]

			cVarRaca := oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_RACA"})]
			cVarSexo := oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_SEXO"})]
			// cVarDent := oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_DENTIC"})]
			BeginSQL alias "QTD1"
				%noParser%
				select count(Z0F_PROD) Z0F_QUANT
				  from %table:Z0F% Z0F
				 where Z0F_FILIAL = %xFilial:Z0F%
				   and Z0F_MOVTO  = %exp:Z0C->Z0C_CODIGO%
				   and (Z0F_PROD   =  %exp:cVarPrd%
					or Z0F_PRDORI =  %exp:cVarPrd%)
				   and Z0F_LOTORI = %exp:cVarLot%
				   and Z0F.%notDel%
			EndSQL
			// and Z0F_PROD   = %exp:cVarPrd%
			/* 
				NESTA PARTE QUE CALCULA O SALDO DISPONIVEL, DEVE SER FEITA APENAS POR PRODUTO E LOTE
			and Z0F_RACA   = %exp:cVarRaca%
			and Z0F_SEXO   = %exp:cVarSexo%
			and Z0F_DENTIC = %exp:cVarDent% */
			If !QTD1->(Eof())
				nQtdPrd := QTD1->Z0F_QUANT
			EndIf
			QTD1->(dbCloseArea())
			aAdd(aSaldos, {oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_LOTE"})],;
				oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_PROD"})],;
				oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_QUANT"})],;
				nQtdPrd,;
				oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_RACA"})],;
				oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_SEXO"})],;
				oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_DENTIC"})] })
		EndIf
	Next

	nAjuste := 0
	for nI := 1 to len(aSaldos)
		If aSaldos[nI, 4] > aSaldos[nI, 3]
			nAjuste := aSaldos[nI, 4] - aSaldos[nI, 3]
			aSaldos[nI, 4] := aSaldos[nI, 3]
		EndIf
		while nAjuste > 0 .and. nI < len(aSaldos)
			for nJ := nI+1 to len(aSaldos)
				If aSaldos[nI, 2] = aSaldos[nJ, 2]
					aSaldos[nJ, 4] := nAjuste
					If aSaldos[nJ, 4] > aSaldos[nJ, 3]
						nAjuste := aSaldos[nJ, 4] - aSaldos[nJ, 3]
					else
						nAjuste := 0
					EndIf
				EndIf
			Next
		EndDo
	Next

Return aSaldos


Static Function DefOrigem()
	local aOrigem := {}
	//local nQtdPesados := 0
	local aSaldos := GetSldOrigem()
	Local nI		:= 0

	If !empty(cLoteOri)
		nPosS := aScan(aSaldos, { |x| x[1]==cLoteOri .and. x[5]==cRacaOri .and. x[6]==cSexoOri /* .and. x[7]==cDentOri */ .and. x[3]>x[4]})
		If nPosS == 0
			msgAlert("não existe saldo disponï¿½l para o lote de origem selecionado. será µtilizado o pró¸©­o lote disponï¿½l.")
		else
			aOrigem := oGetDadOri:aCols[ aScan(oGetDadOri:aCols, { |x| x[aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_LOTE"})]==aSaldos[nPosS, 1] .and. x[aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_PROD"})]==aSaldos[nPosS, 2]}) ]
			If aSaldos[nPosS, 4]+1 == aSaldos[nPosS, 3]

				If !empty(cLoteOri)
					lCtlLote := .T.
					If lCtlLote

						nPosLoteVL := aScan(oGetDadVL:aCols, { |x| x[ nPosVW_LOTE ]=cLoteOri})
						If oGetDadVL:aCols[nPosLoteVL, nPosVW_QTDPES]+1 == oGetDadVL:aCols[nPosLoteVL, nPosVW_QUANT]

							msgInfo("O Lote de Origem [" + aSaldos[nPosS, 1] + " ] foi totalmente contado. Selecione um novo lote de origem.")

							cLoteOri := ""
							cCurrOri := ""
							cRacaOri := ""
							cSexoOri := ""
							// cDentOri := ""

							oSayFOri:SetText("")

						EndIf

					else

						msgInfo("O BOV [" + aSaldos[nPosS, 2] + " ] do Lote de Origem [" + aSaldos[nPosS, 1] + " ] foi totalmente contado. Selecione um novo lote de origem.")

						cLoteOri := ""
						cCurrOri := ""
						cRacaOri := ""
						cSexoOri := ""
						// cDentOri := ""
						oSayFOri:SetText("")

					EndIf
				EndIf

			EndIf
		EndIf
	EndIf

	If empty(aOrigem)
		for nI := 1 to len(aSaldos)
			If aSaldos[nI,3] > aSaldos[nI,4]
				aOrigem := oGetDadOri:aCols[aScan(oGetDadOri:aCols, { |x| x[aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_LOTE"})]=aSaldos[nI, 1] .and. x[aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_PROD"})]=aSaldos[nI, 2]})]
				nI := len(aSaldos)
			EndIf
		Next
	EndIf

Return aOrigem

/* ============================================================================================ */
Static Function GetQtdLote(cLote)
	local nQtdLote := 0
	Local nI		:= 0

	for nI := 1 to len(oGetDadDet:aCols)
		If !oGetDadDet:aCols[ nI, nUsadDet+1] .and. oGetDadDet:aCols[ nI, aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_LOTE"})] = cLote
			nQtdLote++
		EndIf
	Next

Return nQtdLote

/* ============================================================================================ */
User Function Registrar( oModel )
	// Local oModel   := FWModelActive()
	Local nPMovto  := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_MOVTO"})
	Local nPSeq    := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_SEQ"  })
	Local nPProd   := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_PROD" })
	Local nPLote   := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_LOTE" })
	Local nPCurral := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_CURRAL"})
	Local nPPeso   := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_PESO" })
	Local nPPeBal  := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_PESBAL"})
	Local nPData   := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_DTPES"})
	Local nPHora   := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_HRPES"})

	Local nPContr  := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_CONTR"})
	Local nPPedid  := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_PEDID"})
	Local nPForne  := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_FORNE"})

	Local nPRaca   := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_RACA"})
	Local nPSexo   := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_SEXO"})
	Local nPDent   := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_DENTIC"})
	Local nPTag    := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_TAG"})

	Local nPLOri   := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_LOTORI"})

	Local nI       := 0, nJ := 0

	If oModel:nOperation <> 4
		Alert("Esta operação não pode ser realizada neste modo de edição.")
		Return .F.
	EndIf

	If nPeso == 0
		Return nil
	EndIf

	If nPeso < 0
		msgAlert("O peso informado não pode ser negativo, realize a pesagem novamente.")
		Return nil
	EndIf

	If nQtdDes >= nQtdOri
		msgInfo("A quantidade informada nos lotes origem já¦oi registrada. VerIfique se a quantidade de origem está £orreta.")
		Return nil
	EndIf

	If empty(cLoteForce)

		If !GetMV("VA_USARANG",,.F.)

			msgAlert("Nenhum lote de destino selecionado. Utilize a grade de parâ­¥tros para definir o lote de destino.")
			Return

		else

			nQtd := 0
			for nI := 1 to len(oGetDadRan:aCols)
				for nJ := 1 to nUsadRan
					If !oGetDadRan:aCols[ nI, nUsadRan+1]
						If empty(oGetDadRan:aCols[ nI, nJ])
							msgAlert("O item [" + aHeadRan[nJ,1] + " ] na linha " + cValToChar(nI) + "  nos parametros está ¶azio. Preencha todos os campos dos parâ­¥tros para continuar")
							Return nil
						EndIf
						If nPeso >= oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) = "ZV2_PESINI"})] .and. nPeso <= oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) = "ZV2_PESFIM"})]
							nQtd++
						EndIf
					EndIf
				Next
			Next
			If nQtd = 0
				msgAlert("Nao foi encontrado nenhum parâ­¥tro para o peso informado. Preencha os parâ­¥tros antes de continuar.")
				Return nil
			EndIf

		EndIf
	EndIf

	aColsDet := oGetDadDet:aCols

	If len(aColsDet) == 1
		If empty(aColsDet) .or. aColsDet[len(aColsDet), nPPeso] = 0
			aColsDet := {}
		EndIf
	EndIf

	If len(aColsDet) = 0 .or. !empty(aColsDet[len(aColsDet), nPLote])
		aAdd(aColsDet, Array(nUsadDet+1))
	EndIf

	cSeq := ""

	If len(aColsDet) == 1
		cSeq := "0001"
	else
		//cSeq := soma1(aColsDet[len(aColsDet)-1, nPSeq])
		cSeq := soma1(aColsDet[1, nPSeq])
	EndIf

	aLOrigem := DefOrigem()

	aColsDet[len(aColsDet), nPMovto] := Z0C->Z0C_CODIGO
	aColsDet[len(aColsDet), nPSeq]   := cSeq
	aColsDet[len(aColsDet), nPProd]  := aLOrigem[aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_PROD"})]

	BeginSQL alias "QRYZ"
		%noParser%
		select ZBC_CODIGO, ZBC_PEDIDO, A2_NOME
		  from %table:ZBC% ZBC
		  left join %table:SA2% SA2 on (SA2.A2_FILIAL=%xFilial:SA2% and A2_COD=ZBC_CODFOR and A2_LOJA=ZBC_LOJFOR and SA2.%notDel%)
		 where ZBC.ZBC_FILIAL=%xFilial:ZBC%
		   and ZBC_PRODUT=%exp:aColsDet[len(aColsDet), nPProd]%
		   and ZBC_VERSAO=(
		   		select max(ZBC_VERSAO)
		   		  from %table:ZBC% Z2
		   		 where Z2.ZBC_FILIAL=ZBC.ZBC_FILIAL
		   		   and Z2.ZBC_CODIGO=ZBC.ZBC_CODIGO
				   and Z2.%notDel%
		   )
		   and ZBC.%notDel%
	EndSQL
	If !QRYZ->(Eof())
		aColsDet[len(aColsDet), nPContr] := QRYZ->ZBC_CODIGO
		aColsDet[len(aColsDet), nPPedid] := QRYZ->ZBC_PEDIDO
		aColsDet[len(aColsDet), nPForne] := QRYZ->A2_NOME
	EndIf
	QRYZ->(dbCloseArea())

	aColsDet[len(aColsDet), nPData] := Date()
	aColsDet[len(aColsDet), nPHora] := Time()

	aColsDet[len(aColsDet), nPLOri] := aLOrigem[aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_LOTE"})]
	aColsDet[len(aColsDet), nPSexo] := aLOrigem[aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_SEXO"})]   // AllTrim(posicione("SB1", 1, xFilial("SB1")+aColsDet[len(aColsDet), nPProd], "B1_X_SEXO"))
	aColsDet[len(aColsDet), nPTag]  := space(tamsx3("Z0F_TAG")[1])

	If nRadRaca >= 2
		aColsDet[len(aColsDet), nPRaca] := oRadRaca:aItems[nRadRaca]
	Else
		aColsDet[len(aColsDet), nPRaca] := AllTrim(aLOrigem[aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_RACA"})])   // AllTrim(posicione("SB1", 1, xFilial("SB1")+aColsDet[len(aColsDet), nPProd], "B1_XRACA"))
	EndIf

	If nRadDent >= 2
		aColsDet[len(aColsDet), nPDent] := Left(oRadDent:aItems[nRadDent],1)
	Else
		aColsDet[len(aColsDet), nPDent] := aLOrigem[aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_DENTIC"})] // "0"
	EndIf

	cLote := ""
	cCurral := ""

	nPosIni := 2
	nPosFim := 3
	nPosLote := 4
	nPosCurral := 5

	If empty(cLoteForce)

		for nI := 1 to len(oGetDadRan:aCols)
			If !oGetDadRan:aCols[ nI, nUsadRan+1]
				If nPeso >= oGetDadRan:aCols[ nI, nPosIni] .and. nPeso <= oGetDadRan:aCols[ nI, nPosFim]
					cLote := oGetDadRan:aCols[ nI, nPosLote]
					cCurral := oGetDadRan:aCols[ nI, nPosCurral]

					nI := len(oGetDadRan:aCols)
				EndIf
			EndIf
		endFor

	else
		cLote 	   := cLoteForce
		cCurral    := cCurrForce

		cLoteForce := ""
		cCurrForce := ""
		oSayForce:SetText("")
	EndIf

	If empty(cLote)
		msgAlert("Peso não se encaixa nos parä­¥tros especIficados. Informe uma parametrizaç£¯ de pesos vá¬©da que permita a escolha do lote e curral adequado.")
		Return nil
	EndIf

	aColsDet[len(aColsDet), nPLote] 	:= cLote
	aColsDet[len(aColsDet), nPCurral] 	:= cCurral
	aColsDet[len(aColsDet), nPPeso] 	:= nPeso
	aColsDet[len(aColsDet), nPPeBal] 	:= nPesBal
	aColsDet[len(aColsDet), nUsadDet+1] := .F.

	RecLock("Z0F", .T.)
	Z0F->Z0F_FILIAL := xFilial("Z0F")
	Z0F->Z0F_MOVTO 	:= Z0C->Z0C_CODIGO
	Z0F->Z0F_SEQ 	:= cSeq
	Z0F->Z0F_PROD 	:= aColsDet[len(aColsDet), nPProd]
	Z0F->Z0F_LOTE 	:= aColsDet[len(aColsDet), nPLote]
	Z0F->Z0F_CURRAL := aColsDet[len(aColsDet), nPCurral]
	Z0F->Z0F_PESO 	:= aColsDet[len(aColsDet), nPPeso]
	Z0F->Z0F_PESBAL := aColsDet[len(aColsDet), nPPeBal]
	If valtype(aColsDet[len(aColsDet), nPData]) == "D"
		Z0F->Z0F_DTPES := aColsDet[len(aColsDet), nPData]
	else
		Z0F->Z0F_DTPES := STOD(aColsDet[len(aColsDet), nPData])
	EndIf
	Z0F->Z0F_HRPES := aColsDet[len(aColsDet), nPHora]
	Z0F->Z0F_RACA  := AllTrim(aColsDet[len(aColsDet), nPRaca])
	Z0F->Z0F_SEXO  := AllTrim(aColsDet[len(aColsDet), nPSexo])
	Z0F->Z0F_DENTIC := AllTrim(aColsDet[len(aColsDet), nPDent])
	Z0F->Z0F_TAG   := AllTrim(aColsDet[len(aColsDet), nPTag])
	Z0F->Z0F_LOTORI := aColsDet[len(aColsDet), nPLOri]
	MsUnlock()

	aColsDet[len(aColsDet), aScan( aHeadDet, { |x| AllTrim(x[2]) == "NRECNO"})] := Z0F->(RECNO())

	nPRecno := aScan( aHeadDet, {|a1| a1[2]=="NRECNO"})
	aSort(aColsDet,,,{ |x, y| x[nPRecno] > y[nPRecno] })

	oGetDadDet:setArray(aColsDet)
	oGetDadDet:oBrowse:Refresh()
	oDlg:CtrlRefresh()
	ObjectMethod(oDlg,"Refresh()")

	U_calcular_destino()

	nPeso := 0
Return


User Function ChangeZ0F()
	local nRec := oGetDadDet:aCols[oGetDadDet:oBrowse:nAt, aScan( aHeadDet, { |x| AllTrim(x[2]) == "NRECNO"})]
	Local oModel := FWModelActive()

	If oModel:nOperation <> 4 .or. !empty( oGetDadDet:aCols[oGetDadDet:oBrowse:nAt, aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_SEQEFE"})] )
		msgAlert("Esta operação não pode ser realizada neste modo de edição.")
		Return .F.
	EndIf

	If nRec > 0

		If !empty(ReadVar())

			dbSelectArea("Z0F")
			dbGoTo(nRec)

			RecLock("Z0F", .F.)

			// If SX3->X3_TIPO == "C"
			&("Z0F->" + SubStr(ReadVar(),4) + "  := " + ReadVar() + " ")
			&("oGetDadDet:aCols[oGetDadDet:oBrowse:nAt, aScan( aHeadDet, { |x| AllTrim(x[2])=='" + SubStr(ReadVar(),4) + "'})] := " + ReadVar() + " ")

			// ElseIf SX3->X3_TIPO == "N"
			// 	&("Z0F->" + SubStr(ReadVar(),4)) := &(ReadVar())
			// 	&("oGetDadDet:aCols[oGetDadDet:oBrowse:nAt, aScan( aHeadDet, { |x| AllTrim(x[2])='" + SubStr(ReadVar(),4) + " '})]") := &(ReadVar())
			// EndIf

			MsUnlock()

		EndIf

		U_calcular_destino()

	else

		Return .F.

	EndIf

Return .T.

/*
mudei o campo de numerico para caractaer

Static Function fValDent()
Local lRet := &(ReadVar())<=8 .and. &(ReadVar())%2==0
Return lRet
*/
User Function DeleteZ0F()
	local nRec := oGetDadDet:aCols[oGetDadDet:oBrowse:nAt, aScan( aHeadDet, { |x| AllTrim(x[2]) == "NRECNO"})]
	Local oModel := FWModelActive()

	If oModel:nOperation <> 4 .or. !empty( oGetDadDet:aCols[oGetDadDet:oBrowse:nAt, aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_SEQEFE"})] )
		msgAlert("Esta operação não pode ser realizada neste modo de edição.")
		Return .F.
	EndIf

	If nRec > 0

		dbSelectArea("Z0F")
		dbGoTo(nRec)

		RecLock("Z0F", .F.)
		If !oGetDadDet:aCols[oGetDadDet:oBrowse:nAt, nUsadDet+1]
			If !Z0F->(Deleted())
				Z0F->(DBDelete())
			EndIf
		else
			If Z0F->(Deleted())
				Z0F->(DBRecall())
			EndIf
		EndIf
		MsUnlock()

		//oGetDadDet:aCols[oGetDadDet:oBrowse:nAt, nUsadDet+1] := !oGetDadDet:aCols[oGetDadDet:oBrowse:nAt, nUsadDet+1]
		U_calcular_destino()
	else
		Return .F.
	EndIf
Return .T.


/*
	em caso de alteracao, verificar a funcao fReLoadZ0E
	que tem processamento parecido;
*/
User Function calcular_destino()

	Local nJ          := 0
	Local nPProd      := aScan( aHeadDet, { |x| AllTrim(x[2]) == "Z0F_PROD"  })

	nPosSeq           := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_SEQ"   })
	nPosProd          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_PROD"  })
	nPosDesc          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_DESC"  })
	nPosLote          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_LOTE"  })
	nPosCurral        := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_CURRAL"})
	nPosQuant         := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_QUANT" })
	nPosPesA          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_PESO"  })
	nPosPeso          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_PESTOT"})
	nPosDtCo          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_DATACO"})
	nPosSeqE          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_SEQEFE"})
	nPosRaca          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_RACA"  })
	nPosSexo          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_SEXO"  })
	//nPosDent          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_DENTIC"})
	nPPrdOri          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_PRDORI"})
	nPLotOri          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_LOTORI"})

	If len(oGetDadDet:aCols) = 1
		If empty(oGetDadDet:aCols[1, nPProd])
			Return
		EndIf
	EndIf

	BeginSQL alias "QRYDET"
		%noParser%
		select *
		  from %table:Z0F% Z0F
		 where Z0F_FILIAL=%xFilial:Z0F%
		   and Z0F_MOVTO=%exp:Z0C->Z0C_CODIGO%
		   and Z0F.%notDel%
		order by Z0F_MOVTO, Z0F_PROD, Z0F_RACA, Z0F_SEXO, Z0F_DENTIC, Z0F_LOTE, Z0F_LOTORI, Z0F_CURRAL, Z0F_SEQEFE DESC, Z0F_SEQ
	EndSQL

	nQtdDes := 0
	lCria := .T.
	nPosLinha := 1
	cSeq := "0001"
	aColsDes := {}
	aColsVw := {}
	cHrAtu := ""
	// calcular_destino()
	If !QRYDET->(Eof())
		while !QRYDET->(Eof())

			nQtdDes++
			// calcular_destino
			If nQtdDes > 1
				nPosLinha := aScan(aColsDes, { |x| AllTrim(x[nPosLote])   == AllTrim(QRYDET->Z0F_LOTE  );
					.and. AllTrim(x[nPosRaca])   == AllTrim(QRYDET->Z0F_RACA  );
					.and. AllTrim(x[nPosSexo])   == AllTrim(QRYDET->Z0F_SEXO  ); // .and. AllTrim(x[nPosDent])   == AllTrim(QRYDET->Z0F_DENTIC);
					.and. AllTrim(x[nPosCurral]) == AllTrim(QRYDET->Z0F_CURRAL);
					.and. AllTrim(x[nPosProd])   == AllTrim(QRYDET->Z0F_PROD  );
					.and. AllTrim(x[nPLotOri])   == AllTrim(QRYDET->Z0F_LOTORI);
					.and. AllTrim(x[nPosSeqE])   == AllTrim(QRYDET->Z0F_SEQEFE) })
				If nPosLinha > 0
					lCria := .F.
				else
					lCria := .T.
				EndIf
			EndIf

			If lCria
				aAdd(aColsDes, Array(nUsadDes+1))
				aColsDes[len(aColsDes), nUsadDes+1] := .F.

				for nJ := 1 to len(aHeadDes)
					aColsDes[len(aColsDes), nJ] := CriaVar(aHeadDes[nJ, 2])
				endFor

				cSeqDes := ""
				If len(aColsDes) == 1
					cSeqDes := "0001"
				else
					cSeqDes := Soma1(aColsDes[len(aColsDes)-1, nPosSeq])
				EndIf

				aColsDes[len(aColsDes), nPosSeq] := cSeqDes
				aColsDes[len(aColsDes), nPosProd] := QRYDET->Z0F_PROD

				dbSelectArea("SB1")
				dbSetOrder(1)
				SB1->( dbSeek(xFilial("SB1")+QRYDET->Z0F_PROD) )

				aColsDes[len(aColsDes), nPosDesc]   := SB1->B1_DESC
				aColsDes[len(aColsDes), nPosLote]   := QRYDET->Z0F_LOTE
				aColsDes[len(aColsDes), nPosCurral] := QRYDET->Z0F_CURRAL
				aColsDes[len(aColsDes), nPosQuant]  := 1
				// aColsDes[len(aColsDes), nPosPeso]   := QRYDET->Z0F_PESO
				// aColsDes[len(aColsDes), nPosPesA]   := QRYDET->Z0F_PESO
				aColsDes[len(aColsDes), nPosDtCo]   := SToD(QRYDET->Z0F_DTPES)+1
				aColsDes[len(aColsDes), nPosSeqE]   := QRYDET->Z0F_SEQEFE
				aColsDes[len(aColsDes), nPosRaca]   := QRYDET->Z0F_RACA
				aColsDes[len(aColsDes), nPosSexo]   := QRYDET->Z0F_SEXO
				//aColsDes[len(aColsDes), nPosDent]   := QRYDET->Z0F_DENTIC
				aColsDes[len(aColsDes), nPPrdOri]   := QRYDET->Z0F_PRDORI
				aColsDes[len(aColsDes), nPLotOri]   := QRYDET->Z0F_LOTORI
			else
				aColsDes[nPosLinha, nPosQuant]      += 1
				// aColsDes[nPosLinha, nPosPesA]       += QRYDET->Z0F_PESO
				// aColsDes[nPosLinha, nPosPeso]       := aColsDes[nPosLinha, nPosPesA] / aColsDes[nPosLinha, nPosQuant]
			EndIf

			cHrIni   := Z0C->Z0C_HRINI // FwFldGet("Z0C_HRINI")
			cHrAtu   := iIf(empty(QRYDET->Z0F_HRPES), Time(), QRYDET->Z0F_HRPES)
			cTempo   := ElapTime ( cHrIni, cHrAtu )
			nMinutos := val(substr(cTempo,1,2))*60 + val(substr(cTempo,4,2)) + val(substr(cTempo,7,2))/60

			nMedia   := nMinutos/nQtdDes
			nHora    := int(nMedia/60)
			nMinuto  := int(nMedia - (nHora*60))
			nSegundo := int((nMedia - (nHora*60) - nMinuto)*60)
			cMedia   := StrZero(nHora, 2) + ":" + StrZero( nMinuto, 2) + ":" + StrZero(nSegundo, 2)

			QRYDET->(dbSkip())
		EndDo
	EndIf
	QRYDET->(dbCloseArea())

	If cHrAtu = time()
		cTempo := cMedia := "00:00:00"
	EndIf

	aColsVw := {}
	for nJ := 1 to len(aColsDes)

		nPesPrd1 := getPesoZ0F(aColsDes[nJ, nPosLote], aColsDes[nJ, nPosProd])
		nQtdPrd  := getSaldoZ0F(aColsDes[nJ, nPosLote], aColsDes[nJ, nPosProd]) //getSaldoLote(aColsDes[nJ, nPosLote], aColsDes[nJ, nPosProd])
		aColsDes[nJ, nPosPeso] := nPesPrd1/nQtdPrd

		If Z0C->Z0C_TPAGRP/* FwFldGet('Z0C_TPAGRP') */=="S" // A=Agrupado; S=Separado
			nPesLot1 := getPesoZ0F(aColsDes[nJ, nPosLote],, aColsDes[nJ, nPosProd+1])
			nQtdLot  := getSaldoZ0F(aColsDes[nJ, nPosLote],/* cProduto */,/* lAtu */, aColsDes[nJ, nPosProd+1]) //getSaldoLote(aColsDes[nJ, nPosLote])
			aColsDes[nJ, nPosPesA] := nPesLot1/nQtdLot

		Else // If FwFldGet('Z0C_TPAGRP')=="A" // A=Agrupado; S=Separado
			nPesLot1 := getPesoZ0F(aColsDes[nJ, nPosLote])
			nQtdLot  := getSaldoZ0F(aColsDes[nJ, nPosLote]) //getSaldoLote(aColsDes[nJ, nPosLote])
			aColsDes[nJ, nPosPesA] := nPesLot1/nQtdLot
		EndIf

		nPLinha := aScan(aColsVw, { |x| AllTrim(x[1])=AllTrim(aColsDes[nJ, nPosLote]);
			.and. AllTrim(x[2])=AllTrim(aColsDes[nJ, nPosCurral]) })
		If nPLinha = 0
			aAdd(aColsVw, Array(nUsadVw+1))
			aColsVw[len(aColsVw), nUsadVw+1] := .F.
			aColsVw[len(aColsVw), 1] := aColsDes[nJ, nPosLote]
			aColsVw[len(aColsVw), 2] := aColsDes[nJ, nPosCurral]
			aColsVw[len(aColsVw), 3] := aColsDes[nJ, nPosPesA]
			aColsVw[len(aColsVw), 5] := aColsDes[nJ, nPosQuant]
			aColsVw[len(aColsVw), 6] := (/* nQtdLot2:= */getSaldoLote(aColsDes[nJ, nPosLote])) //nQtdLot+nQtdLot2 // + aColsVw[len(aColsVw), 5]
		else
			aColsVw[nPLinha, 5] += aColsDes[nJ, nPosQuant]
		EndIf
	Next

	for nJ := 1 to len(oGetDadVL:aCols)
		oGetDadVL:aCols[nJ, nPosVW_QTDPES] := GetQtdPesadosLote(oGetDadVL:aCols[nJ, nPosVW_LOTE],;
			oGetDadVL:aCols[nJ, nPosVW_RACA],;
			oGetDadVL:aCols[nJ, nPosVW_SEXO],;
			/* oGetDadVL:aCols[nJ, aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_DENTIC"})] */ )
		Next

	for nJ := 1 to len(aColsVw)
		aColsVw[nJ, 4] := aColsVw[nJ, 3] / U_getUA(aColsVw[nJ, 2]) * aColsVw[nJ, 5]
	Next

	aSort(aColsVw ,,,{|x,y| AllTrim(x[2]) < y[2]})
	oSayFt:SetText('FALTAM [ '+cValToChar(nQtdOri-nQtdDes)+' ] ANIMAIS PARA PESAR')
	oSayQD:SetText('QTDE DESTINO: '+cValToChar(nQtdDes))

	oSayTempo:SetText('Processamento de Animais: (Apartação)  Tempo: '+cTempo+'  Mé¤©a p/ animal: '+cMedia)

	oGetDadDes:setArray(aColsDes)
	oGetDadDes:oBrowse:Refresh()
	oGetDadVw:setArray(aColsVw)
	oGetDadVw:oBrowse:Refresh()
	oGetDadVL:oBrowse:Refresh()
	oDlg:CtrlRefresh()
	ObjectMethod(oDlg,"Refresh()")
Return .T.


// ----------------------------------------------------------------------------------------------------
User Function getUA(cCurral)
	dbSelectArea("Z08")
	dbSetOrder(1)
	dbSeek(xFilial("Z08")+cCurral)
Return iIf(!empty(Z08->Z08_UAREF),Z08->Z08_UAREF, 1)


// ----------------------------------------------------------------------------------------------------
Static Function getSaldoLote(cLote, cProduto)
	local nRet    := 0
	Local cFiltro := ""
	default cProduto := ""

	cFiltro := "% "
	If !empty(cProduto)
		cFiltro += " and B8_PRODUTO='" + AllTrim(cProduto)+ "'"
	EndIf
	cFiltro += " %"

	BeginSQL alias "QPES"
	%noParser%
	select sum(B8_SALDO) SALDO
	  from %table:SB8% B8
	 where B8_FILIAL=%xFilial:SB8%
	   and B8_LOTECTL = %exp:cLote%
	   and B8.%notDel%
	   %exp:cFiltro%
	   and B8_SALDO > 0
	EndSQL
	If !QPES->(Eof())
		nRet := QPES->SALDO
	EndIf
	QPES->(dbCloseArea())

Return nRet

/* MB : 09.07.2020
	# Processamento do Peso no vetor passado no primeiro parametro; */
Static Function gPesoSaldoZ0E(_aCols, cLote, cProduto, cDesc, nPeso, nSaldo)
Local nI       := 0
Local cControl := ""

	If !Empty(cLote)
		cControl := "AllTrim(_aCols[nI, nPosLote ]) == AllTrim(cLote)"
	EndIf
	If !Empty(cProduto)
		cControl += Iif(Empty(cControl), "", " .and. ") +;
						"AllTrim(_aCols[nI, nPosProd ]) == AllTrim(cProduto)"
	EndIf
	If !Empty(cDesc)
		cControl += Iif(Empty(cControl), "", " .and. ") +;
						"AllTrim(_aCols[nI, nPosDesc ]) == AllTrim(cDesc)"
	EndIf
	nPeso  := 0
	nSaldo := 0
	For nI := 1 to len(_aCols)
		If !Empty(cControl) .and. &(cControl)
			nPeso  += _aCols[nI, nPosPeso ]
			nSaldo += 1
			// nSaldo	+= _aCols[nI, nPosQuant ]
		EndIf
	Next nI
Return nil

/* ================================================================================= */
Static Function getPesoZ0F(cLote, cProduto, cDesc)
	local nRet       := 0
	Local _cQry      := ""
	default cProduto := ""
	default cDesc	 := ""

	_cQry += " SELECT SUM(Z0F_PESO) MEDIA" + CRLF
	_cQry += " FROM  Z0F010 Z0F " + CRLF
	If !empty(cDesc)
		_cQry += "  JOIN SB1010 SB1 ON B1_FILIAL='"+xFilial('SB1')+"' AND B1_COD=Z0F_PROD " + CRLF
		_cQry += "			       AND SB1.D_E_L_E_T_=' '" + CRLF
	EndIf
	_cQry += " WHERE Z0F_FILIAL= '"+xFilial('Z0F')+"'  " + CRLF
	If !empty(cProduto)
		_cQry += "   AND Z0F_PROD='"+AllTrim(cProduto)+"'   " + CRLF
	EndIf
	If !empty(cDesc)
		_cQry += "   AND RTRIM(B1_DESC)='"+AllTrim(cDesc)+"'" + CRLF
	EndIf
	_cQry += "   AND Z0F_LOTE =  '"+cLote+"'" + CRLF
	_cQry += "   AND Z0F.D_E_L_E_T_=' '" + CRLF

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"QPES",.F.,.F.)
/* 
	cFiltro := "% "
	If !empty(cProduto)
		cFiltro += " and Z0F_PROD='" + AllTrim(cProduto)+ "'"
	EndIf
	cFiltro += " %"

	BeginSQL alias "QPES"
	%noParser%
	select sum(Z0F_PESO) MEDIA
	  from %table:Z0F% Z0F
	 where Z0F_FILIAL=%xFilial:Z0F% and Z0F.%notDel%
	   %exp:cFiltro%
	   and Z0F_LOTE = %exp:cLote%
	EndSQL
	//and Z0F_MOVTO = %exp:Z0C->Z0C_CODIGO%
*/
	If !QPES->(Eof())
		nRet := QPES->MEDIA
	EndIf
	QPES->(dbCloseArea())

Return nRet



// ==================================================================================================== \\
Static Function getSaldoZ0F(cLote, cProduto, lAtu, cDesc)
	local nRet       := 0
	Local _cQry      := ""
	default cProduto := ""
	default lAtu     := .F.
	default cDesc	 := ""

	_cQry += " SELECT COUNT(Z0F.R_E_C_N_O_) SALDO " + CRLF
	_cQry += " FROM  Z0F010 Z0F " + CRLF
	If !empty(cDesc)
		_cQry += "  JOIN SB1010 SB1 ON B1_FILIAL='"+xFilial('SB1')+"' AND B1_COD=Z0F_PROD " + CRLF
		_cQry += "			       AND SB1.D_E_L_E_T_=' '" + CRLF
	EndIf
	_cQry += " WHERE Z0F_FILIAL= '"+xFilial('Z0F')+"'  " + CRLF
	If lAtu
		_cQry += " and Z0F_MOVTO='" + Z0C->Z0C_CODIGO+ "'" + CRLF
	EndIf
	If !empty(cProduto)
		_cQry += "   AND Z0F_PROD='"+AllTrim(cProduto)+"'   " + CRLF
	EndIf
	If !empty(cDesc)
		_cQry += "   AND RTRIM(B1_DESC)='"+AllTrim(cDesc)+"'" + CRLF
	EndIf
	_cQry += "   AND Z0F_LOTE =  '"+cLote+"'" + CRLF
	_cQry += "   AND Z0F.D_E_L_E_T_=' '" + CRLF

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"QPES",.F.,.F.)
/* 
	cFiltro := "% "
	If !empty(cProduto)
		cFiltro += " and Z0F_PROD='" + AllTrim(cProduto)+ "'"
	EndIf

	If lAtu
		cFiltro += " and Z0F_MOVTO='" + Z0C->Z0C_CODIGO+ "'"
	EndIf

	cFiltro += " %"

	BeginSQL alias "QPES"
	%noParser%
	select count(R_E_C_N_O_) SALDO
	  from %table:Z0F% Z0F
	 where Z0F_FILIAL=%xFilial:Z0F%
	   %exp:cFiltro%
	   and Z0F_LOTE = %exp:cLote%
	   and Z0F.%notDel%
	EndSQL
*/	
	If !QPES->(Eof())
		nRet := QPES->SALDO
	EndIf
	QPES->(dbCloseArea())

Return nRet

/*
Static Function getPesoLote(cLote, cProduto)
	local nRet := 0
	default cProduto := ""

	cFiltro := "% "
	If !empty(cProduto)
		cFiltro += " and B8_PRODUTO='" + AllTrim(cProduto)+ "'"
	EndIf
	cFiltro += " %"

	BeginSQL alias "QPES"
		%noParser%
		select sum(B8_XPESTOT*B8_SALDO)/sum(B8_SALDO) MEDIA
		from %table:SB8% B8
		where B8_FILIAL=%xFilial:SB8%
		and B8_SALDO > 0
		%exp:cFiltro%
		and B8_LOTECTL = %exp:cLote%
		and B8.%notDel%
	EndSQL
	If !QPES->(Eof())
		nRet := QPES->MEDIA
	EndIf
	QPES->(dbCloseArea())

Return nRet
*/

 /*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 06.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Funç£¯ para buscar um lote disponivel na SB8; 					   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   : 1- Liberar lote da SX5 = tabela Z8; Quando o processo nao chega ao   |
 |                final.                                                           |
 |            2- Se o processo for completo, ou seja for criado SB8, nao se faz    |
 |                obrigatorio deletar na SX5.                                      |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '--------------------------------------------------------------------------------*/
/*
Static Function LiberarLotes()
	Local oModel := FWModelActive()
	Local oGrid := oModel:GetModel( 'Z0EDETAIL' )
	Local cLote	 := ""
	for nI := 1 To oGrid:Length()
		oGrid:GoLine( nI )
		// If !oGrid:IsDeleted()
		If ReadVar() == "M->ZV2_LOTE"
				cLote := Posicione('ZV2', 2, xFilial('ZV2')+oGrid:GetValue('ZV2_MOVTO', nI)+oGrid:GetValue('ZV2_LOTE', nI),'ZV2_MOVTO')
				U_DelLoteSB8( cLote )
		Else
				cLote := oGrid:GetValue('Z0E_LOTE', nI)
				U_DelLoteSB8( cLote )
		EndIf
			// Alert( oGrid:GetValue('Z0E_LOTE', nI) )
		// EndIf
	Next nI
Return nil
*/

User Function SalvarGeral( oModel, oView )
	// Local lRet  := .T.
	Local nI       := 0
	Local nJ       := 0
	// Local oModel   := FWModelActive()
	// Local oView    := FWViewActive()
	Private oGridZ0E := nil

	If oModel:nOperation <> 4
		Alert("Esta operação não pode ser realizada neste modo de edição.")
		Return .F.
	EndIf

	If Z0C->Z0C_STATUS /*FWFldGet\("Z0C_STATUS"\)*/ <> '1' .and. Z0C->Z0C_STATUS /*FWFldGet\("Z0C_STATUS"\)*/ <> '4'
		alert('Só é Possível alterar Movimentações em aberto.')
		Return .F.
	EndIf

	//IdentIfica os produtos de destino e salva a quantidade necessá²©a
	oGridZ0E := oModel:GetModel( 'Z0EDETAIL' )
	//oModel:CommitData()

	for nI := 1 to oGridZ0E:Length()
		oGridZ0E:GoLine(nI)
		oGridZ0E:DeleteLine()
	endFor
	oGridZ0E:DelAllLine()

	// oModel:SetValue("CALC_TOT", "Z0E__TOT02", 0)
	oModel:LoadValue("CALC_TOT", "Z0E__TOT02", 0)

	for nI := 1 to len(oGetDadDes:aCols)
		// RENATO
		// nLinAdd := oGridZ0E:AddLine()
		// oGridZ0E:GoLine(nLinAdd)
		oGridZ0E:AddLine()

		for nJ := 1 to len(aHeadDes)
			If ValType(oGetDadDes:aCols[ nI, nJ]) == "C"
				oGridZ0E:LoadValue(aHeadDes[nJ,2], left(oGetDadDes:aCols[ nI, nJ], TamSX3(aHeadDes[nJ,2])[1]))
			else
				oGridZ0E:LoadValue(aHeadDes[nJ,2], oGetDadDes:aCols[ nI, nJ])
			EndIf
		Next

	endFor

	// oModel:SetValue("CALC_TOT", "Z0E__TOT02", nQtdDes)
	oModel:LoadValue("CALC_TOT", "Z0E__TOT02", nQtdDes)

	oModel:CommitData()
	oView:Refresh()
	oDlg:End()
	ConOut('Fim: SalvarGeral')

Return .T.


class TWsBalanca from TObject
	data oRestClient
	data cUrl
	data aHeader

	method New() constructor
	method CallPesar()
	//method CallUltima()
endClass


method New(cUrl) class TWsBalanca
	Default cUrl := SuperGetMV("MV_XWSBAL",,"http://192.168.0.230:8080")

	::aHeader := {}
	::cUrl := cUrl
	::oRestClient := FWRest():New(::cUrl)

Return

method CallPesar() class TWsBalanca
	local aHeader := {"Content-Type: application/json"}
	local nPesoWs := 0

	conOut("REALIZANDO INTEGRACAO COM WEBSERVICE DA BALANCA")
	cPath := "/pesar"

	conOut("Requisicao: " + cPath)

	::oRestClient:setPath(cPath)
	If ::oRestClient:Get(::aHeader)
		cJson :=  ::oRestClient:GetResult()

		Private aObj := {}
		If FWJsonDeserialize(cJson,@aObj)

			If valtype(aObj) == "O"
				nPesoWs := val(aObj:peso) / 1000
			EndIf

		EndIf
	Else
		ConOut("GET", ::oRestClient:GetLastError())
	EndIf

Return nPesoWs

/*
	funcao inutilizada. a validacao acontecera manualmente na EFETIVAÇƒO DA MOVIMENTACAO.
Static Function fVldTPMOV()
	// Local oView  	 := FWViewActive()
	local oModel    := FWModelActive()
	// local oGridModel := oModel:GetModel('Z0EDETAIL')

	If FWFldGet("Z0C_TPMOV") == '5'
		// oGridModel:SetUniqueLine( { 'Z0E_PROD', 'Z0E_LOTE', 'Z0E_SEQEFE', 'Z0E_RACA', 'Z0E_SEXO', 'Z0E_DENTIC' } )
		oModel:GetModel( 'Z0EDETAIL' ):AUNIQUE := { 6, 4, 17, 24, 25, 26 }
	Else
		// oGridModel:SetUniqueLine( { 'Z0E_PROD', 'Z0E_LOTE', 'Z0E_SEQEFE' } )
		oModel:GetModel( 'Z0EDETAIL' ):AUNIQUE := { 6, 4, 17 }
	EndIf
	oModel:CommitData()
	//oView:Refresh()
	// Alert('Alterou o campo TIPO MOVIMENTO')
Return .T.
*/


/*	MB : 12.05.2020
	# Funcç£¯ para validar a repetiç£¯ dos dados, definindo a permisã¯ da continuidade da funç£¯;
	# Valida campos Raç¡¬ Sexo e Dentiç£¯:
		- Se campos iguais entao lotes deve ser dIferente
		- Se campos dIferentes, lotes podem ser iguais, Mov Tipo : Re-ClassIficaç£¯;
*/
Static Function vldMB001(oView, oModel, oGridZ0D, oGridZ0E)
	Local aArea  	:= GetArea()
	Local aAreaSB1	:= SB1->(GetArea())
	Local lErro 	:= .F.
	Local nIZ0D		:= 0
	Local cChvZ0D	:= ""
	Local nIZ0E		:= 0
	Local cChvZ0E	:= ""

	Begin Transaction
		For nIZ0D := 1 To oGridZ0D:Length()
			oGridZ0D:GoLine( nIZ0D )
			If !oGridZ0D:IsDeleted()
				For nIZ0E := 1 To oGridZ0E:Length()
					oGridZ0E:GoLine( nIZ0E )
					If !oGridZ0E:IsDeleted()

						If oGridZ0D:GetValue('Z0D_PROD',nIZ0D) == oGridZ0E:GetValue('Z0E_PROD',nIZ0E)

							cChvZ0D := oGridZ0D:GetValue('Z0D_RACA',nIZ0D) + oGridZ0D:GetValue('Z0D_SEXO',nIZ0D) ///+ cValToChar(oGridZ0D:GetValue('Z0D_DENTIC',nIZ0D))
							cChvZ0E := oGridZ0E:GetValue('Z0E_RACA',nIZ0E) + oGridZ0E:GetValue('Z0E_SEXO',nIZ0E) //+ cValToChar(oGridZ0E:GetValue('Z0E_DENTIC',nIZ0E))
							If cChvZ0D <> cChvZ0E

								SB1->(DbSetOrder(1))
								SB1->(DbSeek( xFilial('SB1') + oGridZ0E:GetValue('Z0E_PROD', nIZ0E) ))

								If !(lErro := U_SB1Create( { xFilial("SB1"),;										// [01] Filial
									AllTrim(SB1->B1_GRUPO)/*"BOV"*/,;			    // [02] Grupo
									nil/*oGridZ0E:GetValue('Z0E_PROD',nIZ0E)*/,;    // [03] Produto Base/Copia
									nil/*oGridZ0E:GetValue('Z0E_DESC',nIZ0E)*/,;    // [04] Produto Base/Copia Descriç£¯
									oGridZ0E:GetValue('Z0E_RACA'  , nIZ0E),;   		// [05] Raç¡
									oGridZ0E:GetValue('Z0E_SEXO'  , nIZ0E)},;	    // [06] Sexo        //oGridZ0E:GetValue('Z0E_DENTIC', nIZ0E),;		// [07] Denticao
									.T. )) 		// lCriaSaldoSB9 - Saldo Inicial
									// Alert("Produto Incluido com sucesso!!!!")
									// oGridZ0E:SetValue('Z0E_PROD', SB1->B1_COD )
									oGridZ0E:SetValue('Z0E_PROD', SubS(SB1->B1_COD, 1, TamSX3('Z0E_PROD')[1]) )
									// oModel:CommitData()
									// oView:Refresh()
								EndIf
							EndIf
						EndIf
					EndIf
				Next nIZ0E
			EndIf
		Next nIZ0D
		// oModel:CommitData()
	End Transaction
	RestArea(aAreaSB1)
	RestArea(aArea)
Return lErro


/*
	MB : 14.05.2020
		# MsExecAuto para Criaç£¯ de produto;
*/
User Function SB1Create( __aProd, lCriaSaldoSB9 )
	Local _cCodPrd        := ""
	Local aProd           := {}
	Local lErro           := .F.

	Private lMsHelpAuto   := .F.
	Private lMsErroAuto   := .F.

	Default __aProd       := {}
	Default	lCriaSaldoSB9 := .F.

	ConOut('Inicio: SB1Create ' + Time())

	aAdd( aProd, {"B1_FILIAL"	, __aProd[1]		, nil })
	aAdd( aProd, {"B1_GRUPO"	, __aProd[2]		, nil })

	If Empty(__aProd[3])
		_cCodPrd	:= U_PROXSB1( __aProd[2] )
	Else
		_cCodPrd	:=__aProd[3]
	EndIf
	aAdd( aProd, {"B1_COD"		, _cCodPrd			, nil })

	aAdd( aProd, {"B1_DESC"		, Iif(Empty(__aProd[4]),SB1->B1_DESC,__aProd[4]), nil })
	aAdd( aProd, {"B1_TIPO"		, "PA"				, nil })
	aAdd( aProd, {"B1_UM"		, "UN"				, nil })
	aAdd( aProd, {"B1_LOCPAD"	, "01"				, nil })
	aAdd( aProd, {"B1_CONTA"	, "1140200001"      , nil })
	aAdd( aProd, {"B1_ORIGEM"	, "0"				, nil })
	aAdd( aProd, {"B1_X_TRATO"	, "2"				, nil })
	aAdd( aProd, {"B1_X_PRDES"	, "1"				, nil })
	aAdd( aProd, {"B1_PICM"		, 0					, nil })
	aAdd( aProd, {"B1_IPI"		, 0					, nil })
	aAdd( aProd, {"B1_CONTRAT"	, "N"				, nil })
	aAdd( aProd, {"B1_LOCALIZ"	, "N"				, nil })
	aAdd( aProd, {"B1_GRTRIB"	, "001"				, nil })
	aAdd( aProd, {"B1_CODBAR"	, "SEM GTIN"        , nil }) // SEM GTIN => layout 4.0
	aAdd( aProd, {"B1_TIPCAR"	, "005"				, nil })
	aAdd( aProd, {"B1_TPREG"	, "2"				, nil })
	aAdd( aProd, {"B1_CONTSOC"	, 'N'				, nil })
	aAdd( aProd, {"B1_MSBLQL"	, "2"				, nil })
	aAdd( aProd, {"B1_X_TRATO"	, "2"				, nil })
	aAdd( aProd, {"B1_MCUSTD"	, "1"				, nil })
	aAdd( aProd, {"B1_TE"		, GetMV("JR_M11TESC",,"005"), nil })
	aAdd( aProd, {"B1_POSIPI"	, GetMV("JR_POSIPI",,"01022919"), nil })
	// aAdd( aProd, {"B1_APROPRI"	, "D"			, nil })

	// -------------------------------------------------------------------------------------
	//Encontra o B1_XANIMAL
	xAnimal := SB1->B1_XANIMAL
	//A=Angus;C=Cruzamento;M=Mestico;N=Nelore
	BeginSQL alias "QRYA"
		%noParser%
		select Z09_CODIGO
		  from %table:Z09% Z09
		 where Z09_FILIAL=%xFilial:Z09%
		   and Z09_RACA=%exp:__aProd[5]%
		   and Z09_SEXO=%exp:__aProd[6]%
		   and %exp:SB1->B1_XIDADE% between Z09_IDAINI and Z09_IDAFIM
		   and Z09.%notDel%
	EndSQL
	if !QRYA->(Eof())
		xAnimal := QRYA->Z09_CODIGO
	EndIf
	QRYA->(dbCloseArea())

	aAdd( aProd, {"B1_XANIMAL", xAnimal		   , nil })
	// -------------------------------------------------------------------------------------
	aAdd( aProd, {"B1_X_PESOC", SB1->B1_X_PESOC, nil })
	aAdd( aProd, {"B1_XLOTCOM", SB1->B1_XLOTCOM, nil })
	aAdd( aProd, {"B1_X_ARRON", SB1->B1_X_ARRON, nil })
	aAdd( aProd, {"B1_X_TOICM", SB1->B1_X_TOICM, nil })
	aAdd( aProd, {"B1_X_VLICM", SB1->B1_X_VLICM, nil })
	aAdd( aProd, {"B1_XIDADE" , SB1->B1_XIDADE , nil })
	aAdd( aProd, {"B1_CUSTD"  , SB1->B1_CUSTD  , nil })
	aAdd( aProd, {"B1_X_CRED" , SB1->B1_X_CRED , nil })
	aAdd( aProd, {"B1_X_CUSTO", SB1->B1_X_CUSTO, nil })
	aAdd( aProd, {"B1_X_DEBIT", SB1->B1_X_DEBIT, nil })
	aAdd( aProd, {"B1_X_COMIS", SB1->B1_X_COMIS, nil })
	aAdd( aProd, {"B1_XVLRPTA", SB1->B1_XVLRPTA, nil })
	aAdd( aProd, {"B1_XALIICM", SB1->B1_XALIICM, nil })
	aAdd( aProd, {"B1_XVICMPA", SB1->B1_XVICMPA, nil })
	aAdd( aProd, {"B1_XCONTRA", SB1->B1_XCONTRA, nil })
	// -------------------------------------------------------------------------------------
	aAdd( aProd, {"B1_XRACA"  , __aProd[5]     , nil })
	aAdd( aProd, {"B1_X_SEXO" , __aProd[6]     , nil })
	aAdd( aProd, {"B1_XDENTIC", __aProd[7]     , nil })
	// -------------------------------------------------------------------------------------

	If GetMV('MV_RASTRO') == 'S'
		aAdd( aProd, {"B1_RASTRO", 'L'		   , nil })
	EndIf

	FG_X3ORD("C", , aProd )

	lMsErroAuto := .F.
	MSExecAuto({|x, y| MATA010(x, y)}, aProd, 3)

	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
		lErro := .T.
	Else
		If lCriaSaldoSB9

			aProd :={;
				{"B9_FILIAL", FWxFilial('SB9'), Nil},;
				{"B9_COD",    SB1->B1_COD,      Nil},;
				{"B9_LOCAL",  "01",             Nil},;
				{"B9_DATA",   sToD("")/* dDataBase */, Nil},;
				{"B9_QINI",   0,                Nil};
				}

			FG_X3ORD("C", , aProd )

			lErro := U_SB9Create(aProd) // Saldo Inicial
		EndIf
	EndIf

	ConOut('Fim: SB1Create: ' + AllTrim(SB1->B1_COD) + ' - ' + Time())

Return lErro

/*
	MB : 20.05.2020
		# Execauto para criaç£¯ de Saldo inicial
*/
User Function SB9Create( aMatriz )
	//Setando valores da rotina automá´©ca
	Local lMsErroAuto := .F.
	Local lErro       := .F.

	ConOut('Inicio: SB9Create ' + Time())

	//Iniciando transaç£¯ e executando saldos iniciais
	Begin Transaction
		MSExecAuto({|x, y| Mata220(x, y)}, aMatriz, 3)

		//Se houve erro, mostra mensagem
		If lMsErroAuto
			MostraErro()
			DisarmTransaction()
			lErro := .T.
		EndIf
	End Transaction

	ConOut('Fim: SB9Create ' + Time())

Return lErro

/* MB : 02.06.2020
	# Validar ao Trocar o Sexo */
Static Function fVldSexo(nOpc)
Local lRet          := .T.
local oModel        := FWModelActive()
local oGridZ0D      := oModel:GetModel('Z0DDETAIL')
// local oGridZ0E   := oModel:GetModel('Z0EDETAIL')

Local nPosZ0D       := 0
// Local nPHeadSexo := aScan( oGridZ0D:aHeader,{ |x| AllTrim(x[2]) == "Z0D_SEXO"})

Default nOpc        := 1

	If nOpc == 1
	
	nPosZ0D       := aScan( oGridZ0D:aDataModel, { |x| x[1,1,6] == FwFldGet('Z0E_PROD') } )
		If nPosZ0D <= 0
		Alert("ERRO" + CRLF + "O Produto: "+FwFldGet('Z0E_PROD')+" não foi localizado na Origem" )
		Return .F.
		EndIf

	oGridZ0D:GoLine(nPosZ0D)
		If ((LEFT(FwFldGet('Z0D_SEXO'), 1) $ "CM" ) .AND. LEFT(FwFldGet('Z0E_SEXO'), 1) == "F") .OR.;
	   ((LEFT(FwFldGet('Z0D_SEXO'), 1) == "F")  .AND. LEFT(FwFldGet('Z0E_SEXO'), 1) $ "CM")

		Alert("ATENÇƒO" + CRLF + "Sexos invertidos não sao permitidos" )
		lRet := .F.
			EndIf
	Else

	nPosZ0D       := aScan( oGridZ0D:aDataModel, { |x| x[1,1,6] == GdFieldGet('Z0F_PROD') } )
		If nPosZ0D <= 0
		Alert("ERRO" + CRLF + "O Produto: "+GdFieldGet('Z0F_PROD')+" não foi localizado na Origem" )
		Return .F.
		EndIf

	oGridZ0D:GoLine(nPosZ0D)
		If GdFieldGet('Z0F_SEXO') != &(ReadVar()) .and.;
	   ((Left(FwFldGet('Z0D_SEXO'), 1) $ "CM" ) .AND. Left(&(ReadVar()), 1) == "F") .OR.;
	   ((Left(FwFldGet('Z0D_SEXO'), 1) == "F")  .AND. Left(&(ReadVar()), 1) $ "CM")
		
		Alert("ATENÇƒO" + CRLF + "Sexos invertidos não sao permitidos" )
		lRet := .F.
			EndIf

	EndIf

Return lRet


 /*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 04.06.2020                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : em caso de alteracao, verificar a funcao calcular_destino            |
 |	          que tem processamento parecido;                                      |
 '--------------------------------------------------------------------------------*/
Static Function fReLoadZ0E( oModel, oView )

	Local aArea       := GetArea()
	// Local oModel   := FWModelActive()
	// Local oView    := FWViewActive()
	Local oGridZ0E    := oModel:GetModel( 'Z0EDETAIL' )
	Local nQtdDes     := 0
	Local nPosLinha   := 0
	Local lCria       := .T.
	// Local aColsZ0E := {}
	Local aStruZ0F    := {}
	Local aStruZ0E    := Z0E->(dbStruct())	// aHeadDes := GeraHeader("Z0E", .T.)
	Local nUsadZ0E    := len(aStruZ0E)
	Local aColsZ0E    := {}
	Local cSeqDes     := "0000"
	Local nI          := 0, nJ := 0
	Local nPesPrd1    := 0, nQtdPrd := 0, nPesLot1 := 0, nQtdLot := 0

	nPosSeq           := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_SEQ"   })
	nPosProd          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_PROD"  })
	nPosDesc          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_DESC"  })
	nPosLote          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_LOTE"  })
	nPosCurral        := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_CURRAL"})
	nPosQuant         := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_QUANT" })
	nPosPesA          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_PESO"  })
	nPosPeso          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_PESTOT"})
	nPosDtCo          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_DATACO"})
	nPosSeqE          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_SEQEFE"})
	nPosRaca          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_RACA"  })
	nPosSexo          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_SEXO"  })
	//nPosDent          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_DENTIC"})
	nPPrdOri          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_PRDORI"})
	nPLotOri          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_LOTORI"})

	BeginSQL alias "TMPZ0F"
		%noParser%
		select *
		  from %table:Z0F% Z0F
		 where Z0F_FILIAL=%xFilial:Z0F%
		   and Z0F_MOVTO=%exp:Z0C->Z0C_CODIGO%
		   and Z0F.%notDel%
		order by Z0F_MOVTO, Z0F_PROD, Z0F_RACA, Z0F_SEXO, Z0F_DENTIC, Z0F_LOTE, Z0F_LOTORI, Z0F_CURRAL, Z0F_SEQEFE DESC, Z0F_SEQ
	EndSQL
	// fReLoadZ0E
	If !TMPZ0F->(Eof())
		aStruZ0F  := TMPZ0F->(dbStruct())
		TMPZ0F->(DbGoTop())
		while !TMPZ0F->(Eof())
			dbSelectArea("SB1")
			dbSetOrder(1)
			If SB1->( dbSeek(xFilial("SB1")+TMPZ0F->Z0F_PROD) )
				nQtdDes++
				ConOut(StrZero(nQtdDes, 4) + ': fReLoadZ0E: ' + TMPZ0F->Z0F_PROD)
				// fReLoadZ0E
				If nQtdDes > 1
					nPosLinha := aScan(aColsZ0E, { |x| AllTrim(x[nPosLote])   == AllTrim(TMPZ0F->Z0F_LOTE  );
						.and. AllTrim(x[nPosRaca])   == AllTrim(TMPZ0F->Z0F_RACA  );
						.and. AllTrim(x[nPosSexo])   == AllTrim(TMPZ0F->Z0F_SEXO  ); //.and. AllTrim(x[nPosDent])   == AllTrim(TMPZ0F->Z0F_DENTIC)					
						.and. AllTrim(x[nPosCurral]) == AllTrim(TMPZ0F->Z0F_CURRAL);
						.and. AllTrim(x[nPosProd])   == AllTrim(TMPZ0F->Z0F_PROD  );
						.and. AllTrim(x[nPLotOri])   == AllTrim(TMPZ0F->Z0F_LOTORI);
						.and. AllTrim(x[nPosSeqE])   == AllTrim(TMPZ0F->Z0F_SEQEFE) })
					If nPosLinha > 0
						lCria := .F.
					else
						lCria := .T.
					EndIf
				EndIf

				If lCria

					aAdd(aColsZ0E, Array(nUsadZ0E+1))
					aColsZ0E[len(aColsZ0E), nUsadZ0E+1] := .F.

					for nI := 1 to len(aStruZ0E)
						aColsZ0E[len(aColsZ0E), nI] := CriaVar(aStruZ0E[nI, 1])
					Next nI

					cSeqDes := ""
					If len(aColsZ0E) == 1
						cSeqDes := "0001"
					else
						cSeqDes := Soma1(aColsZ0E[len(aColsZ0E)-1, nPosSeq])
					EndIf

					For nI := 1 to Len( aStruZ0F )
						If (nPosZ0E:=aScan( aStruZ0E,{ |x| AllTrim(x[1]) == StrTran( aStruZ0F[ nI, 1], "Z0F_", "Z0E_" ) } )) > 0
							/* 
							oGridZ0E:LoadValue( StrTran( aStruZ0F[ nI, 1], "Z0F_", "Z0E_" ),;
													TMPZ0F->&(aStruZ0F[ nI, 1]) )
							 */
							aColsZ0E[len(aColsZ0E), nPosZ0E]    := TMPZ0F->&(aStruZ0F[ nI, 1])
						EndIf
					Next nI

					aColsZ0E[len(aColsZ0E), nPosSeq]    := cSeqDes
					aColsZ0E[len(aColsZ0E), nPosDesc]   := SB1->B1_DESC
					aColsZ0E[len(aColsZ0E), nPosQuant]  := 1
					// aColsZ0E[len(aColsZ0E), nPosPeso]   := TMPZ0F->Z0F_PESO
					// aColsZ0E[len(aColsZ0E), nPosPesA]   := TMPZ0F->Z0F_PESO
					aColsZ0E[len(aColsZ0E), nPosDtCo]   := SToD(TMPZ0F->Z0F_DTPES)+1
					aColsZ0E[len(aColsZ0E), nPosSeqE]   := TMPZ0F->Z0F_SEQEFE
					// essa parte abaixo estava comentada,
					// nao lembro porque
					//aColsZ0E[len(aColsZ0E), nPosProd]   := TMPZ0F->Z0F_PROD
					//aColsZ0E[len(aColsZ0E), nPosLote]   := TMPZ0F->Z0F_LOTE
					//aColsZ0E[len(aColsZ0E), nPosCurral] := TMPZ0F->Z0F_CURRAL
					// aColsZ0E[len(aColsZ0E), nPosRaca]   := TMPZ0F->Z0F_RACA
					// aColsZ0E[len(aColsZ0E), nPosSexo]   := TMPZ0F->Z0F_SEXO
					// aColsZ0E[len(aColsZ0E), nPosDent]   := TMPZ0F->Z0F_DENTIC

				else
					aColsZ0E[nPosLinha, nPosQuant]      += 1
					// aColsZ0E[nPosLinha, nPosPesA] 		+= TMPZ0F->Z0F_PESO
					// aColsZ0E[nPosLinha, nPosPeso]       := aColsZ0E[nPosLinha, nPosPesA] / aColsZ0E[nPosLinha, nPosQuant]
				EndIf
			EndIf
			TMPZ0F->(dbSkip())
		EndDo

		for nI := 1 to oGridZ0E:Length()
			oGridZ0E:GoLine(nI)
			oGridZ0E:DeleteLine()
		endFor
		oGridZ0E:DelAllLine()

		oModel:LoadValue("CALC_TOT", "Z0E__TOT02", 0)

		// fReLoadZ0E( oModel, oView )
		// for nI := 1 to len(aColsZ0E)
		// 	// nPesPrd1 := getPesoZ0F(aColsDes[nJ, nPosLote], aColsDes[nJ, nPosProd])
		// 	// nQtdPrd  := getSaldoZ0F(aColsDes[nJ, nPosLote], aColsDes[nJ, nPosProd]) //getSaldoLote(aColsDes[nJ, nPosLote], aColsDes[nJ, nPosProd])
		// 	gPesoSaldoZ0E( aColsZ0E, aColsZ0E[nI, nPosLote], aColsZ0E[nI, nPosProd], /* DESCRIÇƒO */,;
			// 					@nPesPrd1, @nQtdPrd )
		// 	aColsZ0E[nI, nPosPeso] := nPesPrd1/nQtdPrd
// 
		// 	If Z0C->Z0C_TPAGRP/* FwFldGet('Z0C_TPAGRP') */=="S" // A=Agrupado; S=Separado
		// 		// nPesLot1 := getPesoZ0F(aColsDes[nJ, nPosLote],, aColsDes[nJ, nPosProd+1])
		// 		// nQtdLot  := getSaldoZ0F(aColsDes[nJ, nPosLote],/* cProduto */,/* lAtu */, aColsDes[nJ, nPosProd+1]) //getSaldoLote(aColsDes[nJ, nPosLote])
		// 		gPesoSaldoZ0E( aColsZ0E, aColsZ0E[nI, nPosLote], aColsZ0E[nI, nPosProd], aColsZ0E[nI, nPosDesc],;
			// 					@nPesLot1, @nQtdLot )
		// 		aColsZ0E[nI, nPosPesA] := nPesLot1/nQtdLot
// 
		// 	Else // If FwFldGet('Z0C_TPAGRP')=="A" // A=Agrupado; S=Separado
		// 		// nPesLot1 := getPesoZ0F(aColsDes[nJ, nPosLote])
		// 		// nQtdLot  := getSaldoZ0F(aColsDes[nJ, nPosLote]) //getSaldoLote(aColsDes[nJ, nPosLote])
		// 		gPesoSaldoZ0E( aColsZ0E, aColsZ0E[nI, nPosLote], /* PRODUTO */, /* DESCRIÇƒO */,;
			// 					@nPesLot1, @nQtdLot )
		// 		aColsZ0E[nI, nPosPesA] := nPesLot1/nQtdLot
		// 	EndIf
		// Next nI
		for nJ := 1 to len(aColsZ0E)

			nPesPrd1 := getPesoZ0F(aColsZ0E[nJ, nPosLote], aColsZ0E[nJ, nPosProd])
			nQtdPrd  := getSaldoZ0F(aColsZ0E[nJ, nPosLote], aColsZ0E[nJ, nPosProd]) //getSaldoLote(aColsZ0E[nJ, nPosLote], aColsZ0E[nJ, nPosProd])
			aColsZ0E[nJ, nPosPeso] := nPesPrd1/nQtdPrd

			If Z0C->Z0C_TPAGRP/* FwFldGet('Z0C_TPAGRP') */=="S" // A=Agrupado; S=Separado
				nPesLot1 := getPesoZ0F(aColsZ0E[nJ, nPosLote],, aColsZ0E[nJ, nPosProd+1])
				nQtdLot  := getSaldoZ0F(aColsZ0E[nJ, nPosLote],/* cProduto */,/* lAtu */, aColsZ0E[nJ, nPosProd+1]) //getSaldoLote(aColsZ0E[nJ, nPosLote])
				aColsZ0E[nJ, nPosPesA] := nPesLot1/nQtdLot

			Else // If FwFldGet('Z0C_TPAGRP')=="A" // A=Agrupado; S=Separado
				nPesLot1 := getPesoZ0F(aColsZ0E[nJ, nPosLote])
				nQtdLot  := getSaldoZ0F(aColsZ0E[nJ, nPosLote]) //getSaldoLote(aColsZ0E[nJ, nPosLote])
				aColsZ0E[nJ, nPosPesA] := nPesLot1/nQtdLot
			EndIf
		Next nJ

		for nI := 1 to len(aColsZ0E)

			nLinAdd := oGridZ0E:AddLine()

			for nJ := 1 to len(aStruZ0E)
				// If ValType(aColsZ0E[ nI, nJ]) == "C"
				If aStruZ0E[nJ,2] == "C"
					oGridZ0E:LoadValue(aStruZ0E[nJ,1], left(aColsZ0E[ nI, nJ], aStruZ0E[nJ,3]))
				elseIf aStruZ0E[nJ,2] == "N"
					oGridZ0E:LoadValue(aStruZ0E[nJ,1], aColsZ0E[ nI, nJ] )
				ElseIf aStruZ0E[nJ,2] == "D"
					If ValType( aColsZ0E[ nI, nJ] ) == "C"
						oGridZ0E:LoadValue(aStruZ0E[nJ,1], sToD(aColsZ0E[ nI, nJ]) )
					Else
						oGridZ0E:LoadValue(aStruZ0E[nJ,1], aColsZ0E[ nI, nJ] )
					EndIf
				EndIf
			Next nJ

		Next nI

		oModel:LoadValue("CALC_TOT", "Z0E__TOT02", nQtdDes)
		// comentei de volta a linha acima
		// ver se vai travar no confirmar para encerrar a movimentacao
		// oModel:CommitData()
		oView:Refresh()
	EndIf
	TMPZ0F->(DbCloseArea())

	RestArea(aArea)
Return nil // oGridZ0E
// Fim fReLoadZ0E

// IIF(EMPTY(M->B1_XLOTCOM),.T.,EXISTCPO('SC7', SUBS(M->B1_XLOTCOM,3) ))
User Function mbEXISTCPO( __Alias, __cChave )
	Local aArea    := GetArea()
// Local aAreaM0  := SM0->(GetArea())

	Local lRet     := .T.

// Local cCurFil  := SM0->M0_CODFIL
// Local nRecSM0  := SM0->(RecNo())

	Local __Filial := SubS(__cChave, 1, 2 )

	// If xFilial('SC7') <> __Filial
	// 	DbSelectArea("SM0")
	// 	SM0->(DbSetOrder(1))
	// 	SM0->(DbSeek(SM0->M0_CODIGO + __Filial ))
	// EndIf

	// lRet := EXISTCPO('SC7', SUBS(__cChave,3) )
	// lRet := Existchav("SC7", SUBS(__cChave,3), ,"EXISTCLI")

	// SM0->(DbGoTo(nRecSM0))
	// cFilAnt := cCurFil

	BeginSQL alias "qTMP"
		%noParser%
		
		SELECT  R_E_C_N_O_
		FROM    %table:SC7%
		WHERE	C7_FILIAL+C7_NUM=%exp:__cChave%
			AND %notDel%
	EndSQL
	// If !qTMP->(Eof())
	// EndIf
	lRet := !qTMP->(Eof())
	qTMP->(dbCloseArea())

	//RestArea(aAreaM0)
	RestArea(aArea)
Return lRet



/*	------------------- ATUALIZAÇ•ES DE DICIONARIOS -------------------

	MB : 07.05.2020
		# Atualizaçµ¥s para aplicar no ambiente de PRODUCAO;

	- Z0C_STATUS
		x3_cbox: 1=Aberto;2=Cancelado;3=Efetivado;4=Parcialmente Efetivado

	- Z0C_USUARI
		Caracter 15

	- Z0C_DTHREF
		Caracter 19

	- Z0C_TPAGRP
		Caracter 1
		x3_cbox: A=Agupado;S=Separado 
		X3_RELACAO: "A"

	- B1_XDENTIC
		Criar campo (copiado a partir da Z0D)

	* Criaç£¯ de campos Raç¡¬ Sexo e Dentiç£¯ nas tabelas (Z0D, Z0E e Z0F)

	* Criaç£¯ de Campos:
		- Z0D
			- Z0D_PRDORI
		- Z0E
			- Z0E_PRDORI
			- Z0E_LOTORI

	- Criaç£¯ de indices SXI : Z0E

	# filtro SX3:
		X3_ARQUIVO $ ('Z0C,Z0D,Z0E,Z0F,SB1,   ')

*/
