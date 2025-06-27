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

Static dLastClickTime := JurTime(.f., .T.) 

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
	ADD OPTION aRotina TITLE 'Visualizar'        ACTION 'VIEWDEF.VAMVCA01' 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'           ACTION 'u_AddZ0C()' 		OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'           ACTION 'VIEWDEF.VAMVCA01' 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'           ACTION 'VIEWDEF.VAMVCA01' 	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Estorna Movtos'    ACTION 'u_CancMvBv()' 		OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Legenda'           ACTION 'U_Z0CLEG()' 		OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE 'Rel. Comp. Lotes'  ACTION 'u_VABOVR01()' 		OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE 'Eliminar Residuos' ACTION 'U_LimpaZ0D()' 		OPERATION 9 ACCESS 0
Return aRotina

//----------------------------------------	---------------------------
User Function LimpaZ0D()

	If Z0C->Z0C_STATUS <> '4' .or. Z0C->Z0C_TPMOV <> '2'
		msgAlert("Esta operação só é permitida para Movimentações efetivadas parcialmente do tipo Apartação.")
		Return
	EndIf

	begin transaction

		cUpd := "delete from " + retSQLName("Z0D") + CRLF
		cUpd += " where Z0D_FILIAL='" + FWxFilial("Z0D")+ "'" + CRLF
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
		cUpd += " where Z0D_FILIAL='" + FWxFilial("Z0D")+ "'" + CRLF
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
		cUpd += " where Z0D_FILIAL='" + FWxFilial("Z0D")+ "'" + CRLF
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

	msgInfo("Residuos da Movimentação eliminados com sucesso.")

Return
User Function AddZ0C()
	local aArea        := GetArea()
	Private cPerg      := "VAZ0C"

	If msgYesNo("Deseja inserir uma nova Movimentação?")

		MrkLotes()

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
	aAdd(aHeadMrk,{ "Dentição¯"  , "B1_XDENTIC"	, X3Picture("B1_XDENTIC")   , TamSX3("B1_XDENTIC")[1]	, 0, "AllwaysTrue()", X3Uso("B1_XDENTIC")	, "C", "", "V" } ) // ,"","","","V","","","" } )
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
	//oSeek:SetCss("QPushButton{ color: #000; }")

	oSeek	:= TButton():New( nLinAtu-2, aSize[5]/2 - 55, "Confirmar" ,oDlgMrk, {|| ConfirmAdd(lAdd) },55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)
	//oSeek:SetCss("QPushButton{ color: #000; background: #2C2; font-weight: bold}")

	nLinAtu += nTamLin + 5
	If !lAdd
		oSayFil := TSay():New(nLinAtu, 02+162 ,{||'Dados da Movimentação'},oDlg,,,,,,.T.,,,100,30)
		//oSayFil:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 13pt; text-decoration: underline}")

		nLinAtu += nTamLin

		nPad := 35
		nA   := 80
		TSay():New(nLinAtu, nA/* 02+162 */,{||'Balança '},oDlgMrk,,,,,,.T.,,,100,10)
		@ nLinAtu-1, nA+nPad-5/* 030+162 */ MSGET oEquip VAR cEquip PICTURE "@!" VALID !vazio() .and. ExistCPO("ZV0") F3 "ZV0BOV" SIZE 050, nTamLin/2 OF oDlgMrk PIXEL

		nB := (nA+nPad) + nPad + 30
		aTpMov := {"1=Recebimento","2-Apartacao","3-Manejo","4-Enfermaria","5-Reclassificação","6-Transferência de Lote"}
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
	//oBtMrk:SetCss("QPushButton{ color: #000; }")

	nLinAtu += nTamLin+4

	oGetDadMrk:= MsNewGetDados():New(nLinAtu, 02, aSize[3]/2, aSize[5]/2, nOpc, cLinOk, cTudoOk, cIniCpos, {}, nFreeze, nMax, cFieldOk, cSuperDel, cDelOk, oDlgMrk, aHeadMrk, aColsMrk)
	oGetDadMrk:oBrowse:blDblClick := {|| MarcaDes(oGetDadMrk,"L")}

	Activate dialog oDlgMrk centered
Return

static Function comboRaca()
	Local cCombo := ''
	Local cAlias := GetNextAlias()
	Local cQry   := ""

	cQry := " select distinct Z09_RACA " + CRLF 
	cQry += "   from "+RetSQLName("Z09")+" Z09 " + CRLF 
	cQry += "  where Z09_FILIAL='"+FwxFilial("Z09")+"' " + CRLF 
	cQry += "    and Z09_RACA <> ' ' " + CRLF 
	cQry += "    and Z09.D_E_L_E_T_ = '' " + CRLF 
	cQry += "  order by 1 desc " + CRLF

	MpSysOpenQuery(cQry, cAlias)

	while !(cAlias)->(Eof())
		If !empty((cAlias)->Z09_RACA)
			cCombo += If(empty(cCombo),"",";") + AllTrim((cAlias)->Z09_RACA) + "=" + AllTrim((cAlias)->Z09_RACA)
		EndIf
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

Return cCombo

Static Function comboSexo()
	Local cCombo := ''
	Local cAlias := GetNextAlias()
	Local cQry   := ""

	cQry := " select distinct Z09_SEXO " + CRLF 
	cQry += "   from "+RetSQLName("Z09")+" Z09 " + CRLF 
	cQry += "  where Z09_FILIAL='"+FwxFilial("Z09")+"' " + CRLF 
	cQry += "    and Z09_SEXO <> ' ' " + CRLF 
	cQry += "    and Z09.D_E_L_E_T_ = '' " + CRLF
	cQry += "  order by 1 desc " + CRLF

	MpSysOpenQuery(cQry, cAlias)'

	while !(cAlias)->(Eof())
		If !empty((cAlias)->Z09_SEXO)
			cCombo += If(empty(cCombo),"",";") + AllTrim((cAlias)->Z09_SEXO) + "=" + AllTrim((cAlias)->Z09_SEXO)
		EndIf
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

Return cCombo

Static Function ConfirmAdd(lAdd)
	local aArea        := GetArea()
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
		Z0C_FILIAL := FWxFilial("Z0C")
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
	dbSelectArea("Z0E")
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
					Z0D_FILIAL 		:= FWxFilial("Z0D")
					Z0D->Z0D_CODIGO	:= cCodMovto
					Z0D->Z0D_SEQ	:= cSeq
					Z0D->Z0D_PROD	:= oGetDadMrk:aCols[ nI, nPosProd]
					Z0D->Z0D_DESC 	:= AllTrim(oGetDadMrk:aCols[ nI, nPosDesc])
					Z0D->Z0D_LOCAL 	:= Posicione("SB1",1,FWxFilial("SB1")+oGetDadMrk:aCols[ nI, nPosProd],"B1_LOCPAD")
					Z0D->Z0D_DESC 	:= ALLTRIM(Posicione("SB1",1,FWxFilial("SB1")+oGetDadMrk:aCols[ nI, nPosProd],"B1_DESC"))
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
				oGridZ0D:LoadValue("Z0D_CODIGO"	, cCodMovto)
				oGridZ0D:LoadValue("Z0D_SEQ"	, cSeq)
				oGridZ0D:LoadValue("Z0D_PROD"	, left(oGetDadMrk:aCols[ nI, nPosProd],TamSX3("Z0D_PROD")[1]))
				oGridZ0D:LoadValue("Z0D_DESC"	, left(AllTrim(oGetDadMrk:aCols[ nI, nPosDesc]),TamSX3("Z0D_PROD")[1]))
				oGridZ0D:LoadValue("Z0D_LOCAL"	, Posicione("SB1",1,FWxFilial("SB1")+oGetDadMrk:aCols[ nI, nPosProd],"B1_LOCPAD"))
				oGridZ0D:LoadValue("Z0D_DESC"	, ALLTRIM(Posicione("SB1",1,FWxFilial("SB1")+oGetDadMrk:aCols[ nI, nPosProd],"B1_DESC")))
				oGridZ0D:LoadValue("Z0D_LOTE"	, oGetDadMrk:aCols[ nI, nPosLote])
				oGridZ0D:LoadValue("Z0D_CURRAL"	, oGetDadMrk:aCols[ nI, nPosCurral])
				oGridZ0D:LoadValue("Z0D_QTDORI"	, oGetDadMrk:aCols[ nI, nPosSaldo])
				oGridZ0D:LoadValue("Z0D_QUANT"	, oGetDadMrk:aCols[ nI, nPosSaldo])

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
função para inverter a seleção dos produtos selecionados pelo usuá²©o.
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
função responsá¶¥l por pesquisar os produtos a partir dos filtros informados em tela.
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
	Local cAlias  := GetNextAlias()
	If lAdd
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

	_cQry := " select DISTINCT 'LBTIK' CSTAT, " + CRLF
	If (Left(cTpMov,1)) == "5"
		_cQry += " 				 Z08_TIPO, " + CRLF
	EndIf
	_cQry += " 				 B1_COD, B8_LOTECTL, B8_X_CURRA, B1_DESC, A2_NOME, ZBC_CODIGO, ZBC_PEDIDO, " + CRLF
	_cQry += " 				 B8_SALDO, B1_XRACA, B1_X_SEXO, B1_XDENTIC " + CRLF
	_cQry += " from  SB8010 SB8 " + CRLF
	_cQry += " join  SB1010 SB1 on (B1_FILIAL= '"+FWxFilial('SB1')+"' and SB1.B1_COD=SB8.B8_PRODUTO AND SB1.D_E_L_E_T_= ' ') " + CRLF
	_cQry += " left join ZBC010 ZBC on (ZBC.ZBC_FILIAL+ZBC.ZBC_PEDIDO = B1_XLOTCOM " + CRLF
	_cQry += " 					  and ZBC_VERSAO=(select max(ZBC_VERSAO) " + CRLF
	_cQry += " 									  from  ZBC010 Z2 " + CRLF
	_cQry += " 									  where Z2.ZBC_FILIAL=ZBC.ZBC_FILIAL and Z2.ZBC_CODIGO=ZBC.ZBC_CODIGO " + CRLF
	_cQry += " 										and Z2.D_E_L_E_T_= ' ') " + CRLF
	_cQry += " 					  and ZBC.D_E_L_E_T_= ' ') " + CRLF
	_cQry += " left join SA2010 SA2 on (SA2.A2_FILIAL= '"+FWxFilial('SA2')+"'  and A2_COD=ZBC_CODFOR and A2_LOJA=ZBC_LOJFOR and SA2.D_E_L_E_T_= ' ') " + CRLF
	If (Left(cTpMov,1)) == "5"
		_cQry += " 	    JOIN Z08010 Z08 ON Z08_FILIAL=B8_FILIAL AND Z08_CODIGO=B8_X_CURRA AND Z08_TIPO='4'" + CRLF
	EndIf
	_cQry += " where B8_FILIAL= '"+FWxFilial('SB8')+"'  " + CRLF
	_cQry += "   and B8_PRODUTO <> '" + Space(TamSX3("B1_COD")[1]) + " ' and B8_PRODUTO <> '0' " + CRLF
	_cQry += "   and B8_PRODUTO between '" + cProdDe + " ' and '" + cProdAte+ "'" + CRLF
	_cQry += "   and B8_LOTECTL between '" + cLoteDe + " ' and '" + cLoteAte+ "'" + CRLF
	_cQry += "   and B8_X_CURRA between '" + cCurralDe + " ' and '" + cCurralAte+ "'" + CRLF
	_cQry += cFiltro
	_cQry += "   and SB8.B8_SALDO > 0 " + CRLF
	_cQry += "   and SB8.D_E_L_E_T_= ' ' " + CRLF
	_cQry += " order by B8_LOTECTL, B1_COD" + CRLF
	MemoWrite("C:\totvs_relatorios\SQL_VAMVCA01_seekAll.sql" , _cQry)

	mpSysOpenQuery(_cQry,cAlias)

	aColsMrk	:= {}
	If !(cAlias)->(Eof())
		While !(cAlias)->(eof())
			aAdd(aColsMrk, array(nUsadMrk+1))

			For nX:=1 to nUsadMrk
				aColsMrk[Len(aColsMrk),nX]:=(cAlias)->( FieldGet(FieldPos(aHeadMrk[nX,2])) )
			Next
			aColsMrk[Len(aColsMrk),nUsadMrk+1]:=.F.
			(cAlias)->(dbSkip())
		End
	else
		aAdd(aColsMrk, array(nUsadMrk+1))
		aColsMrk[len(aColsMrk),nUsadMrk+1] := .F.
	EndIf
	(cAlias)->(dbCloseArea())

	oGetDadMrk:setArray(aColsMrk)
	oGetDadMrk:oBrowse:Refresh()
	oDlgMrk:CtrlRefresh()
	ObjectMethod(oDlgMrk,"Refresh()")
Return

//-------------------------------------------------------------------
User Function ProxProd()
	Local oModel     := FWModelActive()
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

	//só permite a efetivação se a quantidade de origem e destino estiverem iguais
	nQtdOri          := oModel:GetValue("CALC_TOT","Z0D__TOT01")
	nQtdDes          := oModel:GetValue("CALC_TOT","Z0E__TOT02")
	If nQtdOri<=0
		alert('não hárigens informadas, por favor, informe uma origem para continuar.')
		Return .F.
	EndIf

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
	Local cQry 	  := ""
	Local cAlias  := GetNextAlias()

	cQry := "select B8_X_CURRA " + CRLF 
	cQry += "  from "+RetSQLName("SB8")+" SB8 " + CRLF 
	cQry += " where B8_FILIAL = '"+FWxFilial("SB8")+"' " + CRLF 
	cQry += "   and B8_LOTECTL= '"+cLote+"' " + CRLF 
	cQry += "   and B8_SALDO > 0 " + CRLF 
	cQry += "   and SB8.D_E_L_E_T_=' ' " + CRLF 
	
	MpSysOpenQuery(cQry, cAlias)

	If !(cAlias)->(Eof())
		cCurral := (cAlias)->B8_X_CURRA
	EndIf
	(cAlias)->(dbCloseArea())

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
	Local cRetorno := POSICIONE("SB1",1,FWxFilial("SB1")+FwFldGet('Z0D_PROD'), "B1_DESC")
	Local nAux     := u_getSldBv( FwFldGet('Z0D_PROD'), FwFldGet('Z0D_LOTE') )

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
	Local nAux     := u_getSldBv( FwFldGet('Z0D_PROD'), FwFldGet('Z0D_LOTE') )

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
	local oModel     	:= FWModelActive()
	Local oGridZ0E   	:= oModel:GetModel( 'Z0EDETAIL' )
	Local cLote      	:= AllTrim(FwFldGet( 'Z0E_LOTE' ))
	Local nRegistros 	:= 0
	Local cAux       	:= ""
	Local cAlias		:= GetNextAlias()
	Local cAlias1		:= ""
	Local cQry 			:= ""

	oGridZ0E:LoadValue('Z0E_PROD'  , U_ProxProd() )
	cAux := Left(POSICIONE('SB1', 1, FWxFilial('SB1')+FwFldGet('Z0E_PROD'), 'B1_DESC'), TamSX3('Z0E_DESC')[1])
	oGridZ0E:LoadValue('Z0E_DESC'  , cAux )

	cQry := " SELECT B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO, B8_GMD, B8_DIASCO, B8_XRENESP " + CRLF
	cQry += "		 , AVG(B8_XPESTOT) B8_XPESTOT " + CRLF
    cQry += "         , COUNT(*) QTD " + CRLF
	cQry += "         , SUM(B8_SALDO) SALDO " + CRLF
	cQry += "	FROM   "+RetSQLName("SB8")+" SB8 " + CRLF
	cQry += "	WHERE B8_FILIAL = '"+FwxFilial("SB8")+"' " + CRLF
	cQry += "	  AND B8_LOTECTL  = '"+cLote+"' " + CRLF
	cQry += "	  AND B8_SALDO > 0 " + CRLF
	cQry += "	  AND B8_XDATACO<>' ' " + CRLF
	cQry += "	  AND SB8.D_E_L_E_T_= ' ' " + CRLF
	cQry += "	GROUP BY B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO, B8_GMD, B8_DIASCO, B8_XRENESP " + CRLF
	
	MpSysOpenQuery(cQry, cAlias)

	(cAlias)->(DbEval({|| nRegistros++ }))
	(cAlias)->(DbGoTop())

	If !(cAlias)->(Eof())
		oGridZ0E:LoadValue('Z0E_CURRAL', (cAlias)->B8_X_CURRA )
	EndIf

	If nRegistros == 1
		oGridZ0E:LoadValue('Z0E_PESTOT', (cAlias)->B8_XPESTOT       )
		oGridZ0E:LoadValue('Z0E_DATACO', sToD((cAlias)->B8_XDATACO) )
		oGridZ0E:LoadValue('Z0E_GMD'   , (cAlias)->B8_GMD           )
		oGridZ0E:LoadValue('Z0E_DIASCO', (cAlias)->B8_DIASCO 	   )
		oGridZ0E:LoadValue('Z0E_RENESP', (cAlias)->B8_XRENESP 	   )
		oGridZ0E:LoadValue('Z0E_PESO'  , (cAlias)->B8_XPESOCO       )
		
		// MB : 30.03.2021 => pega lote de origem para gatilhar os campos no destino
		If Z0C->Z0C_TPMOV == '4' // Apartação
			cLote        := FwFldGet('Z0D_LOTE')
			
			cQry := " SELECT B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO, B8_GMD, B8_DIASCO, B8_XRENESP " + CRLF 
			cQry += "		, AVG(B8_XPESTOT) B8_XPESTOT " + CRLF 
			cQry += "		, COUNT(*) QTD " + CRLF 
			cQry += "		, SUM(B8_SALDO) SALDO " + CRLF 
			cQry += "	FROM   "+RetSQLName("SB8")+" SB8 " + CRLF
			cQry += "	WHERE B8_FILIAL = '"+FwxFilial("SB8")+"' " + CRLF
			cQry += "	AND B8_LOTECTL  = '"+cLote+"' " + CRLF
			cQry += "	AND B8_SALDO > 0  " + CRLF 
			cQry += "	AND B8_XDATACO<>' ' " + CRLF 
			cQry += "	AND SB8.D_E_L_E_T_= ' ' " + CRLF 
			cQry += "	GROUP BY B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO, B8_GMD, B8_DIASCO, B8_XRENESP " + CRLF 
			
			cAlias1 := GetNextAlias()

			MpSysOpenQuery(cQry, cAlias1)

			(cAlias1)->(DbGoTop())
			If !(cAlias1)->(Eof())
				oGridZ0E:LoadValue('Z0E_PESO', (cAlias1)->B8_XPESOCO )
			EndIf
			(cAlias1)->(dbCloseArea())
		EndIf
		
	ElseIf nRegistros>1
		msgAlert('O lote: '+AllTrim(clote)+' possui animais com data de entrada diferentes, informe os campos manualmente: PESO APARTAÇÃO, DATA DE INICIO.')
	EndIf
	(cAlias)->(dbCloseArea())

	// POSIONAR NA Z0D de acordo com o produto
	oGridZ0E:LoadValue('Z0E_RACA'  , FwFldGet('Z0D_RACA') )
	oGridZ0E:LoadValue('Z0E_SEXO'  , FwFldGet('Z0D_SEXO') )

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
	Local cAlias   := ""
	Local cAlias1  := ""
	Local cQry 	   := ""
	
	_cProdMB := U_ProxProd() // StaticCall(VAMVCA01, ProxProd)
	If Empty(_cProdMB)
		oGridZ0D:GoLine( nBkpZ0D )
		Return cRaca
	EndIf
	If SubS(ReadVar(),4) == "Z0E_RACA"
		cRaca := &(ReadVar())
	Else
		cRaca := FwFldGet('Z0D_RACA')
	EndIf

	oGridZ0E:LoadValue('Z0E_PROD'  , _cProdMB ) // StaticCall(VAMVCA01, ProxProd) ) // FwFldGet('Z0D_PROD') ) // _cProdMB

	cAux := Left(POSICIONE('SB1', 1, FWxFilial('SB1')+FwFldGet('Z0D_PROD'), 'B1_DESC'), TamSX3('Z0E_DESC')[1])
	oGridZ0E:LoadValue('Z0E_DESC'  , cAux )

	oGridZ0E:LoadValue('Z0E_LOTE'  , FwFldGet('Z0D_LOTE') )
	
	cQry := "SELECT B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO, B8_GMD, B8_DIASCO, B8_XRENESP " + CRLF 
	cQry += "		 , AVG(B8_XPESTOT) B8_XPESTOT " + CRLF 
    cQry += "         , COUNT(*) QTD " + CRLF 
	cQry += "         , SUM(B8_SALDO) SALDO " + CRLF 
	cQry += "	FROM   "+RetSQLName("SB8")+" SB8  " + CRLF 
	cQry += "	WHERE B8_FILIAL   = '"+FwxFilial("SB8")+"' " + CRLF 
	cQry += "	  AND B8_PRODUTO  = '"+_cProdMB+"'" + CRLF 
	cQry += "	  AND B8_LOTECTL  = '"+FwFldGet('Z0D_LOTE')+"'" + CRLF 
	cQry += "	  AND B8_SALDO > 0  " + CRLF 
	cQry += "	  AND B8_XDATACO<>' ' " + CRLF 
	cQry += "	  AND SB8.D_E_L_E_T_= ' ' " + CRLF 
	cQry += "	GROUP BY B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO, B8_GMD, B8_DIASCO, B8_XRENESP " + CRLF 
	
	cAlias		:= GetNextAlias()
	MpSysOpenQuery(cQry, cAlias)

	If !(cAlias)->(Eof())
		If Z0C->Z0C_TPMOV <> "2" // Apartação
			oGridZ0E:LoadValue('Z0E_PESTOT', (cAlias)->B8_XPESTOT   )
			oGridZ0E:LoadValue('Z0E_PESO'  , (cAlias)->B8_XPESOCO   )
		EndIf
		oGridZ0E:LoadValue('Z0E_DATACO', sToD((cAlias)->B8_XDATACO) )
		oGridZ0E:LoadValue('Z0E_GMD'   , (cAlias)->B8_GMD           )
		oGridZ0E:LoadValue('Z0E_DIASCO', (cAlias)->B8_DIASCO 	   )
		oGridZ0E:LoadValue('Z0E_RENESP', (cAlias)->B8_XRENESP 	   )
		oGridZ0E:LoadValue('Z0E_CURRAL', (cAlias)->B8_X_CURRA )
	Else
		oGridZ0E:LoadValue('Z0E_CURRAL', u_SB8Curral( FwFldGet('Z0E_PROD'), FwFldGet('Z0E_LOTE')) ) // FwFldGet('Z0D_CURRAL') )
	EndIf
	(cAlias)->(dbCloseArea())

	oGridZ0E:LoadValue('Z0E_SEXO'  , FwFldGet('Z0D_SEXO') )
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
	Local cRetorno := POSICIONE("SB1",1,FWxFilial("SB1")+FwFldGet('Z0E_PROD'), "B1_DESC")

	oGridZ0E:LoadValue('Z0E_CORRET', U_LoadCpoVirtual( FWxFilial('Z0E'), _cProdMB, 'C' ) )
	oGridZ0E:LoadValue('Z0E_FORNEC', U_LoadCpoVirtual( FWxFilial('Z0E'), _cProdMB, 'F' ) )
	oGridZ0E:LoadValue('Z0E_RACA'  , SB1->B1_XRACA )
	oGridZ0E:LoadValue('Z0E_SEXO'  , SB1->B1_X_SEXO )
Return cRetorno

// ======================================================================================= //
Static Function ModelDef()
	Local oModel // Modelo de dados construï¿½
	Local oStruZ0C   := FWFormStruct( 1, 'Z0C' )
	Local oStruZ0D   := FWFormStruct( 1, 'Z0D' )
	Local oStruZ0E   := FWFormStruct( 1, 'Z0E' )
	Local oGridZ0D   := nil
	local bZ0DLinePr := {||}
	Local aTrigger   := {}
	Local nI 

	aAdd(aTrigger, FwStruTrigger("Z0D_PROD" ,"Z0D_DESC"   ,"U_TgPrdZ0D()",.F.,"" ,0 ,"" ,NIL,"01" )) 
	aAdd(aTrigger, FwStruTrigger("Z0D_LOTE" ,"Z0D_CURRAL" ,"U_TgLotZ0D()",.F.,"" ,0 ,"" ,NIL,"02" ))

	For nI := 1 To Len(aTrigger)
		oStruZ0D:AddTrigger(aTrigger[nI,1], aTrigger[nI,2], aTrigger[nI,3], aTrigger[nI,4])
	Next nI 

	aTrigger := {}
	aAdd(aTrigger, FwStruTrigger("Z0E_LOTE" ,"Z0E_LOTE" ,"U_TgLotZ0E()",.F.,"" ,0 ,"" ,NIL,"04" )) 
	aAdd(aTrigger, FwStruTrigger("Z0E_RACA" ,"Z0E_RACA" ,"U_TgRacZ0E()",.F.,"" ,0 ,"" ,NIL,"03" )) 
	aAdd(aTrigger, FwStruTrigger("Z0E_PROD" ,"Z0E_DESC" ,"U_TgPrdZ0E()",.F.,"" ,0 ,"" ,NIL,"05" ))
	
	For nI := 1 To Len(aTrigger)
		oStruZ0E:AddTrigger(aTrigger[nI,1], aTrigger[nI,2], aTrigger[nI,3], aTrigger[nI,4])
	Next nI

//Adiciona validação da quantidade do produto de origem
	cVld0 := "u_vldLotBv(&(ReadVar()), .T.) .and. FwFldGet('Z0C_STATUS')$'14'"
	bVld0 := FWBuildFeature( STRUCT_FEATURE_VALID, cVld0 )
	oStruZ0D:SetProperty('Z0D_LOTE', MODEL_FIELD_VALID,bVld0)

//Adiciona validação da quantidade do produto de origem
	cVld1 := "Positivo() .and. u_vlSdOri() .and. FwFldGet('Z0C_STATUS')$'14'"
	bVld1 := FWBuildFeature( STRUCT_FEATURE_VALID, cVld1 )
	oStruZ0D:SetProperty('Z0D_QUANT', MODEL_FIELD_VALID,bVld1)

//Adiciona validação da quantidade do produto de destino
	cVld2 := "Positivo() .and. u_vlSdDest() .and. FwFldGet('Z0C_STATUS')$'14' .and. empty(FwFldGet('Z0E_SEQEFE')) "
	bVld2 := FWBuildFeature( STRUCT_FEATURE_VALID, cVld2 )
	oStruZ0E:SetProperty('Z0E_QUANT', MODEL_FIELD_VALID,bVld2)
	
// MB : 04.01.2017
	bVldAUX := FWBuildFeature( STRUCT_FEATURE_WHEN,;
		"iif(FwFldGet('Z0C_TPMOV') $'12346',.T.,.f.)" ) // "FwFldGet('Z0C_TPMOV')$'123'" )
	oStruZ0E:SetProperty('Z0E_PESTOT', MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0E:SetProperty('Z0E_PESO'  , MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0E:SetProperty('Z0E_GMD'   , MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0E:SetProperty('Z0E_DIASCO', MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0E:SetProperty('Z0E_RENESP', MODEL_FIELD_WHEN, bVldAUX)
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

//IG : 23.11.2023
	cVldMB3 := "U_A01PESODATA( SubStr(ReadVar(),4,Len(ReadVar())) ,&(ReadVar()) )" // 1=Baia;4=Pasto;
	bVldMB3 := FWBuildFeature( STRUCT_FEATURE_VALID, cVldMB3 )
	oStruZ0E:SetProperty( 'Z0E_PESO' , MODEL_FIELD_VALID, bVldMB3)

	oStruZ0E:SetProperty( 'Z0E_DATACO' , MODEL_FIELD_VALID, bVldMB3)

// MB : 02.06.2020
	oStruZ0E:SetProperty('Z0E_SEXO', MODEL_FIELD_VALID,;
		FWBuildFeature( STRUCT_FEATURE_VALID, "fVldSexo()" ) )

	//Adiciona validação da quantidade do produto de destino
	cVld3 := "FwFldGet('Z0C_DATA') <= DDATABASE"
	bVld3 := FWBuildFeature( STRUCT_FEATURE_VALID, cVld3 )
	oStruZ0C:SetProperty('Z0C_DATA', MODEL_FIELD_VALID, bVld3)

	cVldEfet := "FwFldGet('Z0C_STATUS')!='3'"
	bVldEfet := FWBuildFeature( STRUCT_FEATURE_WHEN, cVldEfet )
	oStruZ0D:SetProperty('Z0D_LOTE'  , MODEL_FIELD_WHEN, bVldEfet)
	oStruZ0D:SetProperty('Z0D_QUANT' , MODEL_FIELD_WHEN, bVldEfet)
	oStruZ0E:SetProperty('Z0E_QUANT' , MODEL_FIELD_WHEN, bVldEfet)

	cVldEfet := "iif(FwFldGet('Z0C_TPMOV') == '2',.F.,.T.)"
	bVldEfet := FWBuildFeature( STRUCT_FEATURE_WHEN, cVldEfet )
	oStruZ0D:SetProperty('Z0D_LOTE'		, MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0D:SetProperty('Z0D_CURRAL'	, MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0D:SetProperty('Z0D_PROD'		, MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0D:SetProperty('Z0D_DESC'		, MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0D:SetProperty('Z0D_LOCAL'	, MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0D:SetProperty('Z0D_QTDORI'	, MODEL_FIELD_WHEN, bVldAUX)
	//oStruZ0D:SetProperty('Z0D_RACA'		, MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0D:SetProperty('Z0D_SEXO'		, MODEL_FIELD_WHEN, bVldAUX)
	oStruZ0D:SetProperty('Z0D_DENTIC'	, MODEL_FIELD_WHEN, bVldAUX)

	oModel     := MPFormModel():New("VAMDLA01",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oGridZ0D   := oModel:GetModel("Z0DDETAIL")
	oGridZ0E   := oModel:GetModel("Z0EDETAIL")
	bZ0DLinePr := {|oGridZ0D, nLin, cOperacao, cCampo, xValAtr, xValAnt| Z0DLinPreG(oGridZ0D, nLin, cOperacao, cCampo, xValAtr, xValAnt)}

	//oModel:AddFields('Z0CMASTER',/*cOwner*/,oStruZ0C)
	oModel:AddFields('Z0CMASTER', /*cOwner*/, oStruZ0C, /*bPre*/, { |x| FVldTok(oModel, .F.)}/*bPost*/, /*bLoad*/)
	oModel:AddGrid('Z0DDETAIL', 'Z0CMASTER', oStruZ0D, bZ0DLinePr/*bLinePre*/, { |oModel| FZ0DLok(oModel)}/*bLinePost*/,/*bPre - Grid Inteiro*/,{ || FZ0DTok()}/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é °ara quem pertence
	oModel:AddGrid('Z0EDETAIL', 'Z0CMASTER', oStruZ0E, /*bLinePre*/,{ |oModel| FZ0ELok(oModel)}/*bLinePost*/,/*bPre - Grid Inteiro*/,{ || FZ0ETok()}/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é °ara quem pertence

	oModel:SetPrimaryKey( { "Z0C_FILIAL", "Z0C_CODIGO" } )

	oModel:GetModel('Z0EDETAIL'):SetOptional(.T.)

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'Z0DDETAIL', { { 'Z0D_FILIAL', 'FWxFilial( "Z0D" )' }, { 'Z0D_CODIGO', 'Z0C_CODIGO' } }, Z0D->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'Z0EDETAIL', { { 'Z0E_FILIAL', 'FWxFilial( "Z0E" )' }, { 'Z0E_CODIGO', 'Z0C_CODIGO' } }, Z0E->( IndexKey( 1 ) ) )

	oModel:AddCalc( 'CALC_TOT', 'Z0CMASTER', 'Z0DDETAIL', "Z0D_QUANT", "Z0D__TOT01", "SUM",,, "Total a Transferir")
	oModel:AddCalc( 'CALC_TOT', 'Z0CMASTER', 'Z0EDETAIL', "Z0E_QUANT", "Z0E__TOT02", "SUM",,, "Total Transferido")

	// Adiciona a descriç£¯ do Modelo de Dados
	oModel:SetDescription( 'MOVIMENTACAO DE BOVINOS' )
	
	oModel:GetModel("Z0DDETAIL"):SetMaxLine(10000)
	oModel:GetModel("Z0EDETAIL"):SetMaxLine(10000)
	
	// Adiciona a descriç£¯ dos Componentes do Modelo de Dados
	oModel:GetModel( 'Z0CMASTER' ):SetDescription( 'Dados da Movimentacao' )
	oModel:GetModel( 'Z0DDETAIL' ):SetDescription( 'Dados dos Produtos de Origem' )
	oModel:GetModel( 'Z0EDETAIL' ):SetDescription( 'Dados dos Produtos de Destino' )

	oModel:GetModel( 'Z0DDETAIL' ):SetUniqueLine( { 'Z0D_PROD', 'Z0D_LOTE' } )

	oModel:GetModel( 'Z0EDETAIL' ):SetUniqueLine( { 'Z0E_SEQ','Z0E_PROD', 'Z0E_LOTE', 'Z0E_CURRAL', 'Z0E_RACA', 'Z0E_SEXO'/* , 'Z0E_DENTIC' */, 'Z0E_PRDORI', 'Z0E_LOTORI', 'Z0E_SEQEFE' } )
	oModel:GetModel( 'Z0DDETAIL' ):SetNoInsertLine( .T. )
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

	// Altera o Modelo de dados quer será utilizado
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

User Function LoadCpoVirtual(_cFilial, cProduto, cOrigem)
	Local cRet	   := "" // "MIGUEL " + Time()
	Local _cQry    := ""
	Local cAlias   := GetNextAlias()

	Default cOrigem := ""

	_cQry := " SELECT ZCC_NOMFOR FORNECEDOR, ZCC_NOMCOR CORRETOR " + CRLF
	_cQry += " FROM	  ZCC010 ZCC " + CRLF
	_cQry += "   JOIN ZBC010 ZBC " + CRLF
	_cQry += "    	ON ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO AND ZCC.D_E_L_E_T_=' ' AND ZBC.D_E_L_E_T_=' '" + CRLF
	_cQry += " WHERE  ZBC_FILIAL='" + _cFilial+ "'" + CRLF
	_cQry += "    AND ZBC_PRODUT='" + cProduto+ "'" + CRLF

	MpSysOpenQuery(_cQry,cAlias)

	If !(cAlias)->(Eof())
		If ReadVar() == "M->Z0D_CORRET" .OR. ReadVar() == "M->Z0E_CORRET" .OR. ( ReadVar() == "M->Z0E_PROD" .AND. cOrigem=="C" )
			cRet := SubS( (cAlias)->CORRETOR, 1, TamSx3(StrTran(ReadVar(),"M->",""))[1])
		ElseIf ReadVar() == "M->Z0D_FORNEC" .OR. ReadVar() == "M->Z0E_FORNEC" .OR. ( ReadVar() == "M->Z0E_PROD" .AND. cOrigem=="F" )
			cRet := SubS( (cAlias)->FORNECEDOR, 1, TamSx3(StrTran(ReadVar(),"M->",""))[1])
		EndIf
	EndIf
	(cAlias)->(DbCloseArea())

Return cRet

User Function A01PESODATA( cCampo,cVar )
	Local lRet	:= .T.
	Local nI,nLine
	Local oModel:= nil
	Local cLote := ''
	
	if FWFldGet("Z0C_TPMOV") == "6"
		oModel    := FWModelActive()
		cLote 	:= ALLTRIM(oModel:GetModel('Z0EDETAIL'):GetValue("Z0E_LOTE"))
	 	cCurral := ALLTRIM(oModel:GetModel('Z0EDETAIL'):GetValue("Z0E_CURRAL"))
		nLine 	:= oModel:GetModel('Z0EDETAIL'):GetLine()
		For nI := 1 to oModel:GetModel('Z0EDETAIL'):GetQtdLine()
			oModel:GetModel('Z0EDETAIL'):GoLine(nI)
			IF !(oModel:GetModel('Z0EDETAIL'):IsDeleted())
				if nI != nLine
					if cLote == ALLTRIM(oModel:GetModel('Z0EDETAIL'):GetValue("Z0E_LOTE")) .AND. cCurral == ALLTRIM(oModel:GetModel('Z0EDETAIL'):GetValue("Z0E_CURRAL"))
						if cCampo == 'Z0E_PESO'
							if cVar != oModel:GetModel('Z0EDETAIL'):GetValue("Z0E_PESO")
								oModel:SetErrorMessage("","","","","Peso Inválido", 'Peso não pode ser diferente para Lotes e Currais iguais!', "") 
								lRet := .F.
								exit
							endif
						else 
							if cVar != oModel:GetModel('Z0EDETAIL'):GetValue("Z0E_DATACO")
								oModel:SetErrorMessage("","","","","Data Inválido", 'Data não pode ser diferente para Lotes e Currais iguais!', "") 
								lRet := .F.
								exit
							endif
						endif
					endif 
				endif 
			endif 
		Next nI 
	endif 
Return lRet 
 /*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 08.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: função para verficar o tipo de curral: a SB8; 1=Baia;4=Pasto;		   |
 |             Tipo Recebimento só °¯de ser Curral;                                |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '--------------------------------------------------------------------------------*/
User Function CurPastoOuBaia( cCurral )
	Local cRet 	:= ""
	Local lRet	:= .T.
	Local nI,nLine 
	Local oModel:= nil
	Local cLote := ''

	If (lRet := Existcpo("Z08", cCurral))  
		If 	FWFldGet("Z0C_TPMOV") == "2" .AND. ;
				( cRet:=Posicione('Z08', 1, FWxFilial('Z08')+cCurral, 'Z08_TIPO') ) == "4" // 1=BAIA | 4=PASTO

			lRet:=MsgYesNo( 'Um tipo de Movimentação do tipo APARTAÇÃO não deveria ser transferido para um CURRAL do tipo PASTO.' + CRLF + 'Deseja continuar ?' )

		//Igor Oliveira - 23/11/2023
		ELSEIF FWFldGet("Z0C_TPMOV") == "6"
			oModel    := FWModelActive()
			nLine := oModel:GetModel('Z0EDETAIL'):GetLine()
			cLote := ALLTRIM(oModel:GetModel('Z0EDETAIL'):GetValue("Z0E_LOTE"))

			For nI := 1 to oModel:GetModel('Z0EDETAIL'):GetQtdLine()
				oModel:GetModel('Z0EDETAIL'):GoLine(nI)
				if nI != nLine
					if cLote == ALLTRIM(oModel:GetModel('Z0EDETAIL'):GetValue("Z0E_LOTE")) .AND. cCurral != ALLTRIM(oModel:GetModel('Z0EDETAIL'):GetValue("Z0E_CURRAL"))
						oModel:SetErrorMessage("","","","","Curral Inválido", 'Permitido apenas 1 curral por lote!', "") 
						lRet := .F. 
						exit 
					endif 
				endif 
			Next 
		//
		EndIf
	Else
		MsgInfo("O Curral: " + AllTrim(cCurral) + " não se encontra cadastrado.")
	EndIf
Return lRet

 /*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 02.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: função para buscar um lote disponivel na SB8; 					   |
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
	Local cCurrentTime := JurTime(.f., .T.)

	// Se o tempo entre o último clique e o atual for muito pequeno, ignora`
	if Val(SubStr(ltrim(dLastClickTime),1,2)) == Val(SubStr(ltrim(cCurrentTime),1,2))
		if Val(SubStr(ltrim(dLastClickTime),4,2)) == Val(SubStr(ltrim(cCurrentTime),4,2))
			If Abs(Val(SubStr(ltrim(dLastClickTime),7,2)) - Val(SubStr(ltrim(cCurrentTime),7,2))) < 1
				if abs(Val(SubStr(ltrim(dLastClickTime),10,3)) - Val(SubStr(ltrim(cCurrentTime),10,3))) < 500
					Return Nil // Ignora a segunda chamada muito rápida
				EndIf
			EndIf
		EndIf
	EndIf
	dLastClickTime := cCurrentTime // Atualiza o tempo do último clique

	If oModel:nOperation == 4 .and. FWFldGet("Z0C_TPMOV") <> '4'
		
		if Type("oGetDadRan") != "U"
			IF oGetDadRan:aCols[ oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] == 0 .or.;
			oGetDadRan:aCols[ oGetDadRan:oBrowse:nAt, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})] == 0
				MsgInfo("Informe o Peso Inicial e o Peso Final antes de informar o Lote")
				Return nil
			ENDIF
		endif

		If IsInCallStack( "Selecao" )
			cAux := &(ReadVar())
		Else
			cAux     := AllTrim(oGridModel:GetValue('Z0E_LOTE') )
			If !Empty(cAux)
				lContinua := Empty( POSICIONE('SX5', 1, FWxFilial('SX5')+'Z8'+SubS(cAux, 1, At("-",cAux)-1), 'X5_DESCRI') )
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
								' já se encontra reservado.' +;
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

Static Function FZ0DLok(oModel)
	local nQuant 	:= FWFldGet('Z0D_QUANT')
	local nQtdOri 	:= FWFldGet('Z0D_QTDORI')

	If nQtdOri < nQuant
		Alert("Quantidade de origem não pode ser maior que o saldo atual dos produtos.")
		Return .F.
	EndIf

	//FWFormCommit( oModel )
Return(.T.)

Static Function FVldTok(oModel, lHard)
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
Local lRet   := .T.

	If Z0C->Z0C_TPMOV == '4' .AND.; // Apartação
		Empty( FwFldGet( 'Z0E_OBS' ) )

		MsgAlert("Campo observação não preenchido na linha: " + cValToChar(oModel:GetModel( 'Z0EDETAIL' ):nLine ))
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
	EndIf

	if !Empty(aArea)
    	RestArea(aArea)
	EndIf
Return lRet

// -------------------------------------------------------------------------------------------------------------
Static Function FZ0ELPre()
	//só permite a efetivação se a quantidade de origem e destino estiverem iguais
	If FWFldGet('Z0E__TOT02')>=FWFldGet('Z0D__TOT01')
		alert('já foram informadas destinos suficientes para atender as origens especIficadas, verIfique as quantidades informadas.')
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
	Local cTimeIni    := Time()
	Local nI          := 0
	Local nJ          := 0
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
	Local cALias 	  := ""
	Local cQry 		  := ""
	Local cQryM1	  := ""
	Local cQryM2	  := ""
	Local oQryCache   := nil
	Local oQryMP   	  := nil	
	Local cBovCom	  := ""
	Local cCntScalar  := 0
	Local nIdade  	  := 0
	
	Private oGridZ0D  := nil
	Private oGridZ0E  := nil
	Private aOrigens  := {}
	Private aTransf   := {}

	Private aMedPond  := {}

	Private nLinProc   := 0

	ConOut('Inicio: ProcGrid ' + Time() )

	If oModel:nOperation <> 4
		msgAlert("Esta operação não pode ser realizada neste modo de edição.")
		Return .F.
	EndIf

	If !Z0C->Z0C_STATUS /*FWFldGet\("Z0C_STATUS"\)*/ $ '14'
		msgAlert('só é possível efetivar Movimentações em aberto.')
		Return .F.
	EndIf

	//só permite a efetivação se a quantidade de origem e destino estiverem iguais
	nQtdOri := oModel:GetValue("CALC_TOT","Z0D__TOT01")
	nQtdDes := oModel:GetValue("CALC_TOT","Z0E__TOT02")
	If nQtdOri<=0
		alert('não há origens informadas favor, informe uma origem para continuar.')
		Return .F.
	EndIf

	lHard := .T.
	If FwFldGet('Z0C_TPMOV') != "2" //se nao for apartacao
		If nQtdOri<>nQtdDes
			alert('As quantidades de origem e destino estão diferentes, não é possível efetivar a Movimentação.')
			Return .F.
		EndIf
	else
		If nQtdOri<nQtdDes
			alert('A quantidade de origem não pode ser menor que a quantidade de destino, não é possível efetivar a Movimentação.')
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

	//IdentIfica os produtos de destino e salva a quantidade necessária
	oGridZ0D   	:= oModel:GetModel( 'Z0DDETAIL' )
	aSvLn2   	:= FWSaveRows()
	oGridZ0E   	:= oModel:GetModel( 'Z0EDETAIL' )
	aSvLn1   	:= FWSaveRows()

	For nI := 1 To oGridZ0E:Length()
		oGridZ0E:GoLine( nI )
		If oGridZ0E:IsDeleted()
			alert('Há linhas deletadas na grid Lotes de Destino. Feche a tela pelo botão CONFIRMAR e reabra a movimentação para efetivar.')
			Return .F.
		endif
	Next nI

	nPHZ0EPROD := aScan(oGridZ0E:aHeader,{|x|AllTrim(x[2])=="Z0E_PROD"})
	nPHZ0EORIG := aScan(oGridZ0E:aHeader,{|x|AllTrim(x[2])=="Z0E_PRDORI"}) // PRODUTO ORIGEM: Z0D
	nPHZ0ERACA := aScan(oGridZ0E:aHeader,{|x|AllTrim(x[2])=="Z0E_RACA"})
	nPHZ0ESEXO := aScan(oGridZ0E:aHeader,{|x|AllTrim(x[2])=="Z0E_SEXO"})

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

	cQry := "SELECT  B8_LOTECTL, COUNT(B8_LOTECTL) QTDREG " + CRLF 
	cQry += " FROM	"+RetSqlName("SB8")+" SB8 " + CRLF 
	cQry += " WHERE	B8_FILIAL  =  '"+FwxFilial("SB8")+"' " + CRLF
	cQry += " 	AND B8_LOTECTL <> ? " + CRLF
	cQry += " 	AND B8_X_CURRA =  ? " + CRLF
	cQry += " 	AND B8_SALDO   >  0 " + CRLF
	cQry += " 	AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " GROUP BY B8_LOTECTL " + CRLF
	cQry += " ORDER BY B8_LOTECTL " + CRLF

	oQryCache := FwExecStatement():New(cQry)

	for nI := 1 To oGridZ0E:Length()
		oGridZ0E:GoLine( nI )

		If !oGridZ0E:IsDeleted() .and. ALLTRIM(oGridZ0E:GetValue('Z0E_SEQEFE', nI)) == ""

			oQryCache:SetString(1,oGridZ0E:GetValue('Z0E_LOTE', nI))
			oQryCache:SetString(2,oGridZ0E:GetValue('Z0E_CURRAL', nI))

			cAlias := oQryCache:OpenAlias()

			If !(cAlias)->(Eof())
				cMsg  += CRLF + "Curral: " + AllTrim(oGridZ0E:GetValue('Z0E_CURRAL', nI)) + ", lotes: "
				cMsg2 := ""
				While !(cAlias)->(Eof())
					cMsg2 += iIf(Empty(cMsg2),"",", ") + IIf( AT(AllTrim((cAlias)->B8_LOTECTL), cMsg2)==0, AllTrim((cAlias)->B8_LOTECTL), "")
					(cAlias)->(DbSkip())
				EndDo
				cMsg  += cMsg2
			EndIf
			(cAlias)->(dbCloseArea())
		EndIf
	Next nI
	
	cQry 	  := ""
	cAlias 	  := ""
	oQryCache:Destroy()
	oQryCache := Nil
	
	If !Empty(cMsg2)

		msgAlert("Lotes já cupados: " + cMsg + CRLF +;
			'Esta operação será cancelada.')
		Return .F.
	EndIf
	
	// FVldTok
	// MB: 22.05.2019 - validacao para nao permitir DIfERENTES lotes para IGUAIS currais;
	cMsg := ""
	cMsg3 := ""

	cQry := "SELECT  B8_LOTECTL, B8_X_CURRA, COUNT(B8_LOTECTL) QTDREG" + CRLF 
	cQry += "		FROM	"+RetSqlName("SB8")+" SB8" + CRLF 
	cQry += "		WHERE	B8_FILIAL  =  "+FwxFilial("SB8")+" " + CRLF 
	cQry += "			AND B8_LOTECTL = ? " + CRLF 
	cQry += "			AND B8_X_CURRA <> ? " + CRLF 
	cQry += "			AND B8_SALDO   >  0" + CRLF 
	cQry += "			AND SB8.D_E_L_E_T_ = ' ' " + CRLF 
	cQry += "			AND B8_LOTECTL NOT IN ( SELECT DISTINCT Z0D_LOTE" + CRLF 
	cQry += "									  FROM "+RetSqlName("Z0D")+" Z0D" + CRLF 
	cQry += "									 WHERE Z0D_FILIAL =  "+FwxFilial("Z0D")+" " + CRLF 
	cQry += "									   AND Z0D_CODIGO = ? " + CRLF 
	cQry += "									   AND Z0D.D_E_L_E_T_ = ' ' " + CRLF 
	cQry += "								  ) " + CRLF
	cQry += "		GROUP BY B8_LOTECTL, B8_X_CURRA" + CRLF 
	cQry += "		ORDER BY B8_LOTECTL" + CRLF

	oQryCache := FwExecStatement():New(cQry)

	for nI := 1 To oGridZ0E:Length()
		oGridZ0E:GoLine( nI )

		If !oGridZ0E:IsDeleted()

			oQryCache:SetString(1,oGridZ0E:GetValue('Z0E_LOTE', nI))
			oQryCache:SetString(2,oGridZ0E:GetValue('Z0E_CURRAL', nI))
			oQryCache:SetString(3,oGridZ0E:GetValue('Z0E_CODIGO', nI))

			cAlias := oQryCache:OpenAlias()

			If !(cAlias)->(Eof())
				cMsg  += CRLF + "Lote: " + AllTrim(oGridZ0E:GetValue('Z0E_LOTE', nI)) + ",  "
				cMsg3 := ""
				While !(cAlias)->(Eof())
					cMsg3 += iIf(Empty(cMsg3),"",", ") + IIf( AT(AllTrim((cAlias)->B8_LOTECTL), cMsg3)==0, AllTrim((cAlias)->B8_LOTECTL), "")
					(cAlias)->(DbSkip())
				EndDo
				cMsg  += cMsg3
			EndIf
			(cAlias)->(dbCloseArea())

		EndIf
	Next nI

	cQry 	:= ""
	cAlias 	:= ""
	oQryCache:Destroy()
	oQryCache := Nil

	If !Empty(cMsg3)
		msgAlert("Lote alocado em outro curral, corrija a Movimentação: " + cMsg + CRLF +;
			'Esta operação será cancelada.')
		Return .F.
	EndIf

	// MB : 12.05.2020
	// na apartacao tbm tera de criar NOVOS bovs
	If (FWFldGet("Z0C_TPMOV")=='2' .OR. FWFldGet("Z0C_TPMOV")=='5')
		If (GetMV("VA_EFETZ0F",,.T.) .and. Z0C->Z0C_TPMOV/*FWFldGet\("Z0C_TPMOV"\)*/=='2') // Apartação

			fReLoadZ0E(oModel, oView)

		EndIf
	EndIf
	
	cQry := " select isnull(max(Z0E_SEQEFE),'    ') Z0E_SEQEFE " + CRLF 
	cQry += "	from "+RetSQLName("Z0E")+" z " + CRLF 
	cQry += "	where Z0E_FILIAL='"+xFilial("Z0E")+"'" + CRLF 
	cQry += "	and Z0E_CODIGO='"+Z0C->Z0C_CODIGO+"' " + CRLF 
	cQry += "	and z.D_E_L_E_T_ = '' " + CRLF 

	cCntScalar := MPSysExecScalar(cQry,"Z0E_SEQEFE")

	If ALLTRIM(cCntScalar) == ""
		cSeqEfe := '0001'
	else
		cSeqEfe := Soma1(cCntScalar)
	EndIf


if Z0C->Z0C_TPMOV != '6'
	Begin Transaction

		If nLinProc == 0
			nLinProc := 1
		endif

		For nJ := 1 To oGridZ0D:Length()
			oGridZ0D:GoLine( nJ )
			If !oGridZ0D:IsDeleted()
				aAdd(aOrigens, { FWFldGet('Z0D_PROD'  , nJ),; // 01
				FWFldGet('Z0D_LOTE'  , nJ),; // 02
				FWFldGet('Z0D_QUANT' , nJ),; // 03
				FWFldGet('Z0D_CURRAL', nJ),; // 04
				FWFldGet('Z0D_RACA'  , nJ),; // 05
				FWFldGet('Z0D_SEXO'  , nJ)}) // 06
			EndIf
		Next

		DbSelectArea('Z0F')
		Z0F->(DbSetOrder(1))

		//Percorre cada produto de destino
		__cAntProd  := ""
		_cAntChvZ0E := ""

		cQry := " SELECT  R_E_C_N_O_  " + CRLF 
		cQry += " FROM	"+RetSqlName("Z0F")+" " + CRLF 
		cQry += " WHERE	Z0F_FILIAL = "+FwxFilial("Z0F")+" " + CRLF 
		cQry += " AND Z0F_MOVTO  = ?  " + CRLF 
		cQry += " AND Z0F_PROD   = ?  " + CRLF 
		cQry += " AND Z0F_LOTE   = ?  " + CRLF 
		cQry += " AND Z0F_RACA   = ?  " + CRLF
		cQry += " AND Z0F_SEXO   = ?  " + CRLF

		oQryCache := FwExecStatement():New(cQry)

		For nI := nLinProc To oGridZ0E:Length()	// Z0E <-> Destino
			oGridZ0E:GoLine( nI )

			ConOut("ProcGrid: " + PadL( nI, 3, '0') + "/" + PadL( oGridZ0E:Length(), 3, '0') +' '+;
				oGridZ0E:GetValue('Z0E_SEQ'   , nI) + ' ' +;
				oGridZ0E:GetValue('Z0E_PROD'  , nI) + ' ' +;
				oGridZ0E:GetValue('Z0E_RACA'  , nI) + ' ' +;
				oGridZ0E:GetValue('Z0E_SEXO'  , nI) + ' ' +;
				'Deletado: ' + CVALTOCHAR( oGridZ0E:IsDeleted() ) )
			lTransf := .T.
			If !oGridZ0E:IsDeleted()
				nQtdTr := 0
				for nJ := 1 to len(aOrigens)//Z0D

					// a linha de comparacao dos BOVs, na Z0D e Z0E nao pode ser retirada;
					__cProd := Iif(Empty(oGridZ0E:GetValue('Z0E_PRDORI' , nI)), oGridZ0E:GetValue('Z0E_PROD' , nI), oGridZ0E:GetValue('Z0E_PRDORI' , nI))
					__cLote := Iif(Empty(oGridZ0E:GetValue('Z0E_LOTORI' , nI)), oGridZ0E:GetValue('Z0E_LOTE' , nI), oGridZ0E:GetValue('Z0E_LOTORI' , nI)) // oGridZ0E:GetValue('Z0E_LOTORI' , nI)
					If aOrigens[nJ,1] == __cProd .and. iIf(Z0C->Z0C_TPMOV$('2'), aOrigens[nJ, 2] == __cLote, .T.)

						//tirei no dia 01.09, erro na mov 6994 .or. Z0C->Z0C_TPMOV $ ("13")
						If Empty(oGridZ0E:GetValue('Z0E_SEQEFE' , nI))

							lCriaBov := .F.
							cBovCom  := ""
							cChvZ0D  := aOrigens[nJ, 5] + aOrigens[nJ, 6] //+ cValToChar(aOrigens[nJ, 7]) // cChvZ0D := oGridZ0D:GetValue('Z0D_RACA',nIZ0D) + oGridZ0D:GetValue('Z0D_SEXO',nIZ0D) + cValToChar(oGridZ0D:GetValue('Z0D_DENTIC',nIZ0D))
							cChvZ0E  := oGridZ0E:GetValue('Z0E_RACA', nI) + oGridZ0E:GetValue('Z0E_SEXO', nI) /* + cValToChar(oGridZ0E:GetValue('Z0E_DENTIC', nI)) */
							If Z0C->Z0C_TPMOV == "2" // Apartação
								lCriaBov := .T.
							ElseIf Z0C->Z0C_TPMOV $ "5" // Re-Classificaç£¯
								If cChvZ0D == cChvZ0E
									aOrigens[nJ,3] -= oGridZ0E:GetValue('Z0E_QUANT' , nI)
									lTransf := .F. //nao precisa - apagar depois
									lCriaBov := .F.
								Else
									lCriaBov := .T.
								EndIf
							EndIf

							If aOrigens[nJ,3] > 0
								
								If Empty(oGridZ0E:GetValue('Z0E_PRDORI', nI))
									oGridZ0E:LoadValue('Z0E_PRDORI', oGridZ0E:GetValue('Z0E_PROD', nI) )
									oGridZ0E:LoadValue('Z0E_LOTORI', aOrigens[nJ, 2] ) // lote
								Else
									SB1->(DbSetOrder(1))
									SB1->(DbSeek( FWxFilial('SB1') + oGridZ0E:GetValue('Z0E_PROD', nI) ))
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
									SB1->(DbSeek( FWxFilial('SB1') + __cProd ))
								EndIf
								If lCriaBov
									if !(lTransf := !U_SB1Create( { FWxFilial("SB1"),;			// [01] Filial
										AllTrim(SB1->B1_GRUPO)/*"BOV"*/,;			// [02] Grupo
										nil/*oGridZ0E:GetValue('Z0E_PROD',nI)*/,;   // [03] Produto Base/Copia
										nil/*oGridZ0E:GetValue('Z0E_DESC',nI)*/,;   // [04] Produto Base/Copia Descriç£¯
										oGridZ0E:GetValue('Z0E_RACA'  , nI),;   	// [05] Raç¡
										oGridZ0E:GetValue('Z0E_SEXO'  , nI)},;	    // [06] Sexo
										.T. ))
										// Retorno = lErro
										nQtdTr += oGridZ0E:GetValue('Z0E_QUANT' , nI) 			// aOrigens[nJ,3]
									Else
										__cAntProd := __cProd
										_cAntChvZ0E := cChvZ0E
									EndIf
								EndIf

								oQryCache:SetString(1,oGridZ0E:GetValue('Z0E_CODIGO', nI))
								oQryCache:SetString(2,oGridZ0E:GetValue('Z0E_PROD'  , nI))
								oQryCache:SetString(3,oGridZ0E:GetValue('Z0E_LOTE'  , nI))
								oQryCache:SetString(4,oGridZ0E:GetValue('Z0E_RACA'  , nI))
								oQryCache:SetString(5,oGridZ0E:GetValue('Z0E_SEXO'  , nI))

								cAlias := oQryCache:OpenAlias()
								
								while !(cAlias)->(Eof())
									Z0F->(DbGoTo((cAlias)->R_E_C_N_O_))
									RecLock('Z0F', .F.)
									Z0F->Z0F_PRDORI := Iif(Empty(oGridZ0E:GetValue('Z0E_PRDORI' , nI)), oGridZ0E:GetValue('Z0E_PROD' , nI), oGridZ0E:GetValue('Z0E_PRDORI' , nI)) // oGridZ0E:GetValue('Z0E_PROD', nI)
									Z0F->Z0F_PROD   := SB1->B1_COD // oGridZ0E:GetValue('Z0E_PROD', nI)
									Z0F->Z0F_SEQEFE := cSeqEfe
									Z0F->(MsUnLock())

									(cAlias)->(dbSkip())
								EndDo
								(cAlias)->(dbCloseArea())

								oGridZ0E:LoadValue('Z0E_PROD', Left(SB1->B1_COD, TamSX3('Z0E_PROD')[1]) )

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
									exit
								EndIf
							EndIf
						Else
							aOrigens[nJ,3] -= oGridZ0E:GetValue('Z0E_QUANT' , nI)
							exit
						EndIf
					EndIf
				Next nJ
				// EndDo
			EndIf
		Next nI

		cQry 	:= ""
		cAlias 	:= ""
		oQryCache:Destroy()
		oQryCache := Nil

		oView:Refresh()
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
				else
					Z0C->Z0C_STATUS := '3'
				EndIf
				Z0C->Z0C_DTFIM  := Date()
				Z0C->Z0C_HRFIM  := Time()
				Z0C->Z0C_USUARI := cUserName
				Z0C->Z0C_DTHREF := Time()
			Z0C->(MsUnLock())

			aStruZ0E    := Z0E->(dbStruct())
			DbSelectArea("Z0E")
			Z0E->(DbSetOrder(1))
			// Gravar Z0E
			For nI := nLinProc To oGridZ0E:Length()
				oGridZ0E:GoLine( nI )
				If !oGridZ0E:IsDeleted()
					lControl := !Z0E->(DbSeek( FWxFilial("Z0E") + Z0C->Z0C_CODIGO + oGridZ0E:GetValue('Z0E_SEQ', nI) ))
					RecLock("Z0E", lControl)
					for nJ := 1 to len(aStruZ0E)
						Z0E->&(aStruZ0E[nJ, 1]) := oGridZ0E:GetValue(aStruZ0E[nJ, 1], nI)
					Next nJ
					Z0E->Z0E_FILIAL := FWxFilial('Z0E')
					Z0E->Z0E_SEQEFE := cSeqEfe
					Z0E->(MsUnLock())
				EndIf
			Next nI

			/* MB : 31.03.2021
				NÃ realizar MEDIA PONDERADA para TPMOV $ ('25') */
			if !(Z0C->Z0C_TPMOV $ ('25'))
				
				cQry := "SELECT DISTINCT Z0E_LOTE,Z0E_CURRAL, Z0E_DATACO, Z0E_PESO" + CRLF 
				cQry += " FROM   "+RetSqlName("Z0E")+"  " + CRLF 
				cQry += " WHERE  Z0E_FILIAL = '" + FWxFilial("Z0E") + "'" + CRLF 
				cQry += "    AND Z0E_CODIGO = '" + Z0C->Z0C_CODIGO + "'" + CRLF
				cQry += "    AND Z0E_SEQEFE = '" + cSeqEfe + "'" + CRLF 
				cQry += "    AND D_E_L_E_T_ = ' '" + CRLF 

				cAlias := GetNextAlias()

				MpSysOpenQuery(cQry, cAlias)
				
				//aMedPond[01, 02 ]
				cQryM1 := " SELECT SUM(PESOTOT)/SUM(SALDO) MEDIA_PONDERADA " + CRLF 
				cQryM1 += " FROM ( " + CRLF 
				cQryM1 += " 			SELECT SUM(Z0E_PESO*Z0E_QUANT) PESOTOT" + CRLF 
				cQryM1 += " 				 , SUM(Z0E_QUANT) SALDO" + CRLF 
				cQryM1 += " 			FROM "+RetSqlName("Z0E")+" WITH (NOLOCK) " + CRLF 
				cQryM1 += " 			WHERE Z0E_FILIAL = '" + FWxFilial("Z0E")+ "' " + CRLF 
				cQryM1 += " 				AND Z0E_LOTE   = ? " + CRLF 
				cQryM1 += " 				AND D_E_L_E_T_ = ' ' " + CRLF 
				cQryM1 += " ) DADOS " + CRLF 

				oQryCache := FwExecStatement():New(cQryM1)

				cQryM2 := " SELECT " + CRLF 
				cQryM2 += " 		CASE " + CRLF 
				cQryM2 += " 			WHEN SUM(PESOTOT) = 0 OR SUM(B8_SALDO) = 0 " + CRLF 
				cQryM2 += " 			THEN -1 " + CRLF 
				cQryM2 += " 			ELSE SUM(PESOTOT)/SUM(B8_SALDO) " + CRLF 
				cQryM2 += " 		END MEDIA_PONDERADA " + CRLF 
				cQryM2 += " FROM ( " + CRLF 
				cQryM2 += " 		SELECT	SUM(B8_XPESOCO*B8_SALDO) PESOTOT " + CRLF 
				cQryM2 += " 			  , SUM(B8_SALDO) B8_SALDO" + CRLF 
				cQryM2 += " 		FROM " + RetSqlName("SB8") + CRLF 
				cQryM2 += " 		where B8_FILIAL  = '" + FWxFilial("SB8") + "'" + CRLF 
				cQryM2 += "         and B8_LOTECTL = ? " + CRLF 
				cQryM2 += " 		  and B8_SALDO   >  0 " + CRLF 
				cQryM2 += " 		  and D_E_L_E_T_=' ' " + CRLF 
				cQryM2 += " ) DADOS " + CRLF
				
				oQryMP := FwExecStatement():New(cQryM2)

				While !(cAlias)->(Eof())
					If aMedPond[01, 02 ]
						oQryCache:SetString(1,(cAlias)->Z0E_LOTE)
						__nPeso := oQryCache:ExecScalar("MEDIA_PONDERADA")
						MemoWrite("C:\totvs_relatorios\SQL_VAMVCA01_MediaPonderada.sql" , cQryM1)
					Else
						oQryMP:SetString(1,(cAlias)->Z0E_LOTE)
						__nPeso := oQryMP:ExecScalar("MEDIA_PONDERADA")
						MemoWrite("C:\totvs_relatorios\SQL_VAMVCA01_MediaPonderada.sql" , cQryM2)
					EndIf


					If !Empty(__nPeso) .AND. (__nPeso > 0)
						cUpd := "update " + retSQLName("SB8") + CRLF
						cUpd += "   set B8_XPESOCO = " + cValToChar( ROUND(__nPeso, 3) )  + CRLF
						cUpd += " where B8_FILIAL  = '" + FWxFilial("SB8")+ "'" + CRLF
						cUpd += "   and B8_LOTECTL = '" + (cAlias)->Z0E_LOTE + "'" + CRLF
						cUpd += "   and B8_SALDO   > 0" + CRLF
						cUpd += "   and D_E_L_E_T_=' '"
						If (TCSqlExec(cUpd) < 0)
							conout("TCSQLError() " + TCSQLError())
						else
							ConOut("Peso medio do lote atualizado com sucesso! " + Z0C->Z0C_CODIGO)
						EndIf
					EndIf
					(cAlias)->(DbSkip())
				EndDo

				oQryMP:Destroy()
				oQryMP := Nil

				oQryCache:Destroy()
				oQryCache := Nil

				(cAlias)->(DbCloseArea())
			EndIf
		EndIf
	End Transaction // esta transanção deve acontecer antes do cursor abaixo.
else
//Igor Oliveira 23/11/2023
	Begin Transaction
	
	If nLinProc == 0
		nLinProc := 1
	endif
	
	For nJ := 1 To oGridZ0D:Length()
		oGridZ0D:GoLine( nJ )
		If !oGridZ0D:IsDeleted()
			aAdd(aOrigens, { FWFldGet('Z0D_PROD'  , nJ),; // 01
			FWFldGet('Z0D_LOTE'  , nJ),; // 02
			FWFldGet('Z0D_QUANT' , nJ),; // 03
			FWFldGet('Z0D_CURRAL', nJ),; // 04
			FWFldGet('Z0D_RACA'  , nJ),; // 05
			FWFldGet('Z0D_SEXO'  , nJ)}) // 06
			//FWFldGet('Z0D_DENTIC', nJ)}) // 07
		EndIf
	Next

	//Percorre cada produto de destino
	__cAntProd  := ""
	_cAntChvZ0E := ""
	For nI := nLinProc To oGridZ0E:Length()//Z0E <-> Destino
		oGridZ0E:GoLine( nI )

		If !oGridZ0E:IsDeleted()
			nQtdTr := 0
			ConOut("ProcGrid: " + PadL( nI, 3, '0') + "/" + PadL( oGridZ0E:Length(), 3, '0') +' '+;
			oGridZ0E:GetValue('Z0E_SEQ'   , nI) + ' ' +;
			oGridZ0E:GetValue('Z0E_PROD'  , nI) + ' ' +;
			oGridZ0E:GetValue('Z0E_RACA'  , nI) + ' ' +;
			oGridZ0E:GetValue('Z0E_SEXO'  , nI) + ' ' +;
			'Deletado: ' + CVALTOCHAR( oGridZ0E:IsDeleted() ) )
			
			If !oGridZ0E:IsDeleted()
				for nJ := 1 to len(aOrigens) // Z0D
					__cProd := Iif(Empty(oGridZ0E:GetValue('Z0E_PRDORI' , nI)), oGridZ0E:GetValue('Z0E_PROD' , nI), oGridZ0E:GetValue('Z0E_PRDORI' , nI))
					__cLote := Iif(Empty(oGridZ0E:GetValue('Z0E_LOTORI' , nI)), oGridZ0E:GetValue('Z0E_LOTE' , nI), oGridZ0E:GetValue('Z0E_LOTORI' , nI)) // oGridZ0E:GetValue('Z0E_LOTORI' , nI)
					If aOrigens[nJ,1] == __cProd .and. iIf(Z0C->Z0C_TPMOV$('2'), aOrigens[nJ, 2] == __cLote, .T.)
						If Empty(oGridZ0E:GetValue('Z0E_SEQEFE' , nI))
							cChvZ0D := aOrigens[nJ, 5] + aOrigens[nJ, 6] //+ cValToChar(aOrigens[nJ, 7]) // cChvZ0D := oGridZ0D:GetValue('Z0D_RACA',nIZ0D) + oGridZ0D:GetValue('Z0D_SEXO',nIZ0D) + cValToChar(oGridZ0D:GetValue('Z0D_DENTIC',nIZ0D))
							cChvZ0E := oGridZ0E:GetValue('Z0E_RACA', nI) + oGridZ0E:GetValue('Z0E_SEXO', nI) /* + cValToChar(oGridZ0E:GetValue('Z0E_DENTIC', nI)) */
						
							If aOrigens[nJ,3] > 0
								If Empty(oGridZ0E:GetValue('Z0E_PRDORI', nI))
									// Guardando SB1 Original
									oGridZ0E:LoadValue('Z0E_PRDORI', oGridZ0E:GetValue('Z0E_PROD', nI) )
									oGridZ0E:LoadValue('Z0E_LOTORI', aOrigens[nJ, 2] ) // lote
								Else
									SB1->(DbSetOrder(1))
									SB1->(DbSeek( FWxFilial('SB1') + oGridZ0E:GetValue('Z0E_PROD', nI) ))
									lCriaBov := .F.
									lTransf  := .T.
								EndIf
								
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
										oGridZ0E:GetValue('Z0E_OBS'    , nI),;
										oGridZ0E:GetValue('Z0E_PESO'   , nI),;
										oGridZ0E:GetValue('Z0E_DATACO' , nI)})
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
										oGridZ0E:GetValue('Z0E_OBS'    , nI),;
										oGridZ0E:GetValue('Z0E_PESO'   , nI),;
										oGridZ0E:GetValue('Z0E_DATACO' , nI)})
									aOrigens[nJ,3] -= nDIf
								EndIf
							EndIf 
						EndIf 
					endif 
				next nJ
			EndIf 
		endif 
	Next nI
	
	lTransf := .t. 
	for nI := 1 to len(aTransf)
		ConOut("ProcGrid: [doTransf]: " + PadL( nI, 3, '0') + "/" + PadL( len(aTransf), 3, '0') )
		
		If empty(aTransf[nI, 10])
			lTransf := .f. 
			exit 
		endif
	Next

	aTranBak := aClone(aTransf)
	aSort(aTranBak, , , {|x, y| x[6] > y[6]})
	_cAntLote := ''
	_cAntCurr := ''
	for nI := 1 to Len(aTranBak)
		if _cAntLote == aTranBak[nI][6] .and. _cAntCurr != aTranBak[nI][10]
			alert("Não é permitido currais diferentes para o mesmo lote!")
			lTransf := .F. 
			exit 
		endif
		_cAntLote := aTranBak[nI][6]
		_cAntCurr := aTranBak[nI][10]
	next nI 

	If !lTransf
		Alert("Movimentação não realizada devido a erros nos dados.")
		DisarmTransaction()
	Else
		RecLock('Z0C', .F.)
			If nQtdOri<>nQtdDes
				Z0C->Z0C_STATUS := '4'
			else
				Z0C->Z0C_STATUS := '3'
			EndIf
			Z0C->Z0C_DTFIM  := Date()
			Z0C->Z0C_HRFIM  := Time()
			Z0C->Z0C_USUARI := cUserName
			Z0C->Z0C_DTHREF := Time()
		Z0C->(MsUnLock())

		aStruZ0E    := Z0E->(dbStruct())
		DbSelectArea("Z0E")
		Z0E->(DbSetOrder(1))
		// Gravar Z0E
		For nI := nLinProc To oGridZ0E:Length()
			oGridZ0E:GoLine( nI )
			If !oGridZ0E:IsDeleted()
				lControl := !Z0E->(DbSeek( FWxFilial("Z0E") + Z0C->Z0C_CODIGO + oGridZ0E:GetValue('Z0E_SEQ', nI) ))
				RecLock("Z0E", lControl)
					for nJ := 1 to len(aStruZ0E)
						Z0E->&(aStruZ0E[nJ, 1]) := oGridZ0E:GetValue(aStruZ0E[nJ, 1], nI)
					Next nJ
					Z0E->Z0E_FILIAL := FWxFilial('Z0E')
					Z0E->Z0E_SEQEFE := cSeqEfe
				Z0E->(MsUnLock())
			EndIf
		Next nI

 		for nI := 1 to len(aTransf)
			cUpd := "update " + retSQLName("SB8") + CRLF
			cUpd += "   set   B8_X_CURRA = '" + ALlTrim(aTransf[nI][10]) + "'"  + CRLF
			cUpd += "   	, B8_XPESOCO = '" + ALLTRIM(Str(aTransf[nI][12])) + "'"  + CRLF
			cUpd += "   	, B8_XDATACO = '" + dToS(aTransf[nI][13]) + "'"  + CRLF
			cUpd += " where B8_FILIAL  = '" + FWxFilial("SB8")+ "'" + CRLF
			cUpd += "   and B8_LOTECTL = '" + ALLTRIM( aTransf[nI][6] ) + "'" + CRLF
			cUpd += "   and B8_PRODUTO = '" + ALLTRIM( aTransf[nI][2] ) + "'" + CRLF
			cUpd += "   and B8_SALDO   > 0 " + CRLF
			cUpd += "   and D_E_L_E_T_=' '"
			If (TCSqlExec(cUpd) < 0)
				alert("TCSQLError() " + TCSQLError())
				lTransf := .F.
				DisarmTransaction()
			EndIf
		next nI 
	endif
	End Transaction
Endif
	If lTransf .and. Len(aTransf) > 0
		
		oGridZ0E:SetNoUpdateLine(.T.)
		oGridZ0E:SetNoDeleteLine(.T.)

		oGridZ0D:SetNoUpdateLine(.T.)
		oGridZ0D:SetNoDeleteLine(.T.)
		
		oView:Refresh()

		ConOut(Repl("-",80))
		__cMsg := "Movimentações realizadas com sucesso."+CRLF+CRLF+;
				  "Tempo de processamento: " + ElapTime( cTimeINI, Time() )
		ConOut(__cMsg)
		ConOut(Repl("-",80))
		msgInfo(__cMsg, "Operação Concluída")
	EndIf
	ConOut('Fim: ProcGrid ' + Time() )
	
	RestArea(aAreaSB1)
	RestArea(aArea)
Return .T.

Static Function doTransf(oModel, aTransf)
	Local aArea			:= GetArea()
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

	PRIVATE lMsHelpAuto := .T.
	PRIVATE lMsErroAuto := .F.

	Private oGridAux    := oModel:GetModel( 'Z0EDETAIL' )
	Private aSvLnAux    := FWSaveRows()

	ConOut('Inicio: doTransf ' + Time() )

	DbSelectArea("SB1")
	DbSetOrder(1)

	If !SB1->(MsSeek(FWxFilial("SB1")+cProd))
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
	If !SB8->(MsSeek(FWxFilial("SB8")+ cProd + cLocal + aTransf[3] ))
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
	// If SB8->(MsSeek(FWxFilial("SB8")+ cProd + cLocal + aTransf[6] ))
	If SB8->(MsSeek(FWxFilial("SB8")+ aTransf[5] + cLocal + aTransf[6] ))
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
		SB1->(MsSeek(FWxFilial("SB1")+aTransf[2]))
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
		SB1->(MsSeek(FWxFilial("SB1")+aTransf[5]))
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
			aadd(aItem,"MOV." + cDoc + "." + cSeqEfe)		//24 = observação D3_OBSERVA  C        30       0
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

		aadd(aItem, {"D3_OBSERVA", "MOV." + cDoc + "." + cSeqEfe, Nil}) //observação

		aadd(aItem, {"D3_X_CURRA", aTransf[9]                   , Nil}) //24 = observação D3_OBSERVA  C        30       0
		aadd(aItem, {"D3_X_CURRA", aTransf[10]                  , Nil}) //24 = observação D3_OBSERVA  C        30       0

		If !Empty(aTransf[11])
			aadd(aItem,{"D3_X_OBS", aTransf[11], Nil}) //observação
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
			If dbSeek(FWxFilial() + " 09EST")
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
						" where B8_FILIAL  ='" + FWxFilial("SB8") + "'" + CRLF +;
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
							" where B8_FILIAL  = '" + FWxFilial("SB8")+ "'" + CRLF +;
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

	if !EMPTY( aCols[1, nPosLote] )
		dDataVl  := aCols[1, nPosVldD] // posicao 21 // cToD("  /  /  ")
		If !IsInCallStack( 'U_CANCMVBV' )
			DbSelectArea("SB8")
			DbSetOrder(3)
			If SB8->(MsSeek(FWxFilial("SB8")+ aCols[1, nPosProd] + aCols[1, nPosArma] + aCols[1, nPosLote] ))
				If SB8->B8_DTVALID <> dDataVl
					ConOut('MA261IN. Produto: '+AllTrim(aCols[1, nPosProd])+' Atual: ' + CVALTOCHAR( SB8->B8_DTVALID ) + ' new: ' + CVALTOCHAR( dDataVl ))
					RecLock("SB8")
					SB8->B8_DTVALID := dDataVl
					msUnlock()
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSB8)
Return .T.
User Function CancMvBv()
	Local aArea   	:= GetArea()
	Local lRet    	:= .T.
	Local nL      	:= 0
	Local cQry    	:= ""
	Local cAlias  	:= ""
	Local cAlias3  	:= ""
	Local cAlias4  	:= ""
	Local __nPeso 	:= 0

	Private oQryC1 	:= nil
	Private oQryC2 	:= nil
	Private oQryC3 	:= nil
	Private oQryC4 	:= nil

	Begin Transaction
		If Z0C->Z0C_STATUS = '3' .or. Z0C->Z0C_STATUS = '4'
			aSequen := mrkSeqs()

			If len(aSequen) = 0
				msgInfo("Nenhuma sequencia selecionada.")
				Return
			EndIf

			If msgYesNo("Confirma o estorno?")
				LObjQry() // Carregar Querys 
				for nL := 1 to len(aSequen)

					if !(Z0C->Z0C_TPMOV $ ('25'))
						__nPeso := 0

						oQryC1:SetString(1,aSequen[nL])
						cAlias := oQryC1:OpenAlias()

						While !(cAlias)->(Eof())
							
							oQryC2:SetString(1,(cAlias)->Z0E_LOTE)
							oQryC2:SetString(2,(cAlias)->Z0E_LOTE)
							oQryC2:SetString(3,aSequen[nL])

							__nPeso := oQryC2:ExecScalar("MED_ANT")

							If !Empty(__nPeso) .AND. (__nPeso > 0)
								cUpd := "update " + RetSQLName("SB8") + CRLF +;
										"   set B8_XPESOCO = " + cValToChar( ROUND(__nPeso, 3) ) + CRLF +;
										" where B8_FILIAL  = '" + FWxFilial("SB8")+ "'" + CRLF +;
										"   and B8_LOTECTL = '" + AllTrim((cAlias)->Z0E_LOTE)+ "'" + CRLF +;
										"   and B8_SALDO   > 0" + CRLF +;
										"   and D_E_L_E_T_=' '"
								If (TCSqlExec(cUpd) < 0)
									conout("TCSQLError() " + TCSQLError())
								else
									ConOut("Peso medio do lote atualizado com sucesso! " + Z0E->Z0E_CODIGO)
								EndIf
							EndIf
							(cAlias)->(DbSkip())
						EndDo
						(cAlias)->(DbCloseArea())
					EndIf	

					// If undoTransf(aSequen[nL])
					Processa({|| lRet := undoTransf(aSequen[nL]) }, "Por favor aguarde ...")

					If lRet
						
						oQryC3:SetString(1,aSequen[nL])
						cAlias3 := oQryC3:OpenAlias()

						while !(cAlias3)->(Eof())
							Z0E->(DbGoTo((cAlias3)->R_E_C_N_O_))

							RecLock('Z0E', .F.)
								Z0E->Z0E_SEQEFE := Space(4)
								Z0E->Z0E_ESTUSR := __cUserId
								Z0E->Z0E_ESTDAT := Date() // dToS(Date())
								Z0E->Z0E_ESTHOR := Time()
							Z0E->(MsUnLock())

							(cAlias3)->(dbSkip())
						EndDo
						(cAlias3)->(dbCloseArea())

						oQryC4:SetString(1,aSequen[nL])
						cAlias4 := oQryC4:OpenAlias()

						while !(cAlias4)->(Eof())
							Z0F->(DbGoTo((cAlias4)->R_E_C_N_O_))

							RecLock('Z0F', .F.)
								Z0F->Z0F_SEQEFE := Space(4)
								Z0F->Z0F_ESTUSR := __cUserId
								Z0F->Z0F_ESTDAT := Date() // dToS(Date())
								Z0F->Z0F_ESTHOR := Time()
							Z0F->(MsUnLock())

							(cAlias4)->(dbSkip())
						EndDo
						(cAlias4)->(dbCloseArea())

						MsgInfo("Movimentos excluído com sucesso!", "OPERAÇÃO CONCLUIDA")
					EndIf
				Next

				IF oQryC1 <> NIL
					oQryC1:Destroy()
					oQryC1 := Nil
				ENDIF 
				IF oQryC2 <> NIL
					oQryC2:Destroy()
					oQryC2 := Nil
				ENDIF 
				IF oQryC3 <> NIL
					oQryC3:Destroy()
					oQryC3 := Nil
				ENDIF 
				IF oQryC4 <> NIL
					oQryC4:Destroy()
					oQryC4 := Nil
				ENDIF 

				cAlias := GetNextAlias()

				cQry := " select sum(case when Z0E_SEQEFE = '    ' then 1 else 0 end) QTD_EFE, count(R_E_C_N_O_) QTD_REG " + CRLF
				cQry += " from "+RetSqlName("Z0E")+" z " + CRLF
				cQry += " where Z0E_FILIAL="+FWxFilial("Z0E")+" " + CRLF
				cQry += " and Z0E_CODIGO="+Z0C->Z0C_CODIGO+" " + CRLF
				cQry += " and z.D_E_L_E_T_ = ' ' " + CRLF

				MpSysOpenQuery(cQry,cAlias)

				If !(cAlias)->(Eof())
					RecLock("Z0C", .F.)
					If (cAlias)->QTD_EFE = (cAlias)->QTD_REG
						Z0C->Z0C_STATUS='1'
					else
						Z0C->Z0C_STATUS='4'
					EndIf
					msUnlock()
				EndIf
				(cAlias)->(dbCloseArea())
			EndIf
		Else
			Alert("não há movimentos efetivados para estornar.")
		EndIf
	End Transaction
	RestArea(aArea)
Return

Static Function LObjQry()
	Local cQry    	:= ""
	
	cQry := " SELECT DISTINCT Z0E_LOTE " + CRLF 
	cQry += " FROM   "+RetSqlName("Z0E")+"  " + CRLF 
	cQry += " WHERE  Z0E_FILIAL =  '" + FWxFilial("Z0E") + "'" + CRLF 
	cQry += "    AND Z0E_CODIGO =  '" + Z0C->Z0C_CODIGO + "'" + CRLF 
	cQry += "    AND Z0E_SEQEFE =  ?  " + CRLF 
	cQry += "    AND D_E_L_E_T_= ' ' "+ CRLF 

	oQryC1 := FwExecStatement():New(cQry)
	
	cQry := " SELECT " + CRLF 
	cQry += " 		CASE " + CRLF 
	cQry += " 			WHEN SUM(PESOTOT) = 0 OR SUM(B8_SALDO) = 0 " + CRLF 
	cQry += " 			THEN -1 " + CRLF 
	cQry += " 			ELSE SUM(PESOTOT)/SUM(B8_SALDO) " + CRLF 
	cQry += " 		END MED_ANT " + CRLF 
	cQry += " FROM ( " + CRLF 
	cQry += " 		SELECT	SUM(B8_XPESOCO*B8_SALDO) PESOTOT " + CRLF 
	cQry += " 			  , SUM(B8_SALDO) B8_SALDO" + CRLF 
	cQry += " 		FROM "+RetSqlName("SB8")+" " + CRLF 
	cQry += " 		WHERE B8_FILIAL  = '" + FWxFilial("SB8") + "'" + CRLF 
	cQry += " 		  AND B8_LOTECTL = ? " + CRLF 
	cQry += " 		  AND B8_SALDO   >  0 " + CRLF 
	cQry += " 		  AND D_E_L_E_T_=' ' " + CRLF 
	cQry += " " + CRLF 
	cQry += " 		UNION " + CRLF 
	cQry += " " + CRLF 
	cQry += " 		SELECT SUM(Z0E_PESO*Z0E_QUANT*-1)" + CRLF 
	cQry += " 			 , SUM(Z0E_QUANT*-1)" + CRLF 
	cQry += " 		FROM "+RetSqlName("Z0E")+" " + CRLF 
	cQry += " 		where Z0E_FILIAL = '" + FWxFilial("Z0E") + "' " + CRLF 
	cQry += " 		  and Z0E_CODIGO = '" + Z0C->Z0C_CODIGO + "' " + CRLF 
	cQry += " 		  AND Z0E_LOTE   = ? " + CRLF 
	cQry += " 		  and Z0E_SEQEFE = ? " + CRLF 
	cQry += " 		  and D_E_L_E_T_ = ' ' " + CRLF 
	cQry += " ) DADOS " + CRLF 

	oQryC2 := FwExecStatement():New(cQry)

	cQry := "SELECT  R_E_C_N_O_ " + CRLF 
	cQry += " FROM	"+RetSqlName("Z0E")+" " + CRLF 
	cQry += " where   Z0E_FILIAL = "+FWxFilial("Z0E")+"" + CRLF 
	cQry += " and Z0E_CODIGO = "+Z0C->Z0C_CODIGO+" " + CRLF 
	cQry += " and Z0E_SEQEFE = ? " + CRLF 
	cQry += " and D_E_L_E_T_ = ' ' " + CRLF 

	oQryC3 := FwExecStatement():New(cQry)

	cQry := "SELECT  R_E_C_N_O_ " + CRLF 
	cQry += "FROM	"+RetSqlName("Z0F")+" " + CRLF 
	cQry += "where Z0F_FILIAL = "+FWxFilial("Z0F")+" " + CRLF 
	cQry += "and   Z0F_MOVTO  = "+Z0C->Z0C_CODIGO+" " + CRLF 
	cQry += "and   Z0F_SEQEFE = ? " + CRLF 
	cQry += "and   D_E_L_E_T_ = ' ' " + CRLF 

	oQryC4 := FwExecStatement():New(cQry)
Return 

//Estorna Transferencia 
Static Function undoTransf(cSequen)
	Local nItem			:= 0
	Local aAUTO         := {}
	Local cDoc          := Z0C->Z0C_CODIGO
	Local cAlias 		:= GetNextAlias()
	Local cQry			:= ""

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
		If dbSeek(FWxFilial() + " 09EST")
			cLoteEst:=IIf(Found(),Trim(X5Descri()),"EST ")
		EndIf
		PRIVATE nTotal := 0      // Total dos lancamentos contabeis
		PRIVATE cArquivo     // Nome do arquivo contra prova
	EndIf

	cQry := " select SD3.R_E_C_N_O_ REC" + CRLF 
	cQry += "	from "+retSQLName("SD3")+" SD3" + CRLF 
	cQry += "	where D3_FILIAL= '"+FWxFilial("SD3")+"'" + CRLF 
	cQry += "	and D3_OBSERVA= '"+("MOV." + cDoc + "." + cSequen)+"'" + CRLF 
	cQry += "	and D3_TM= '499' " + CRLF
	cQry += "	and D3_ESTORNO<>'S' " + CRLF
	cQry += "	and SD3.D_E_L_E_T_=' '" + CRLF 
	
	mpSysOpenQuery(cQry,cAlias)

	If !(cAlias)->(Eof())

		while !(cAlias)->(Eof()) .and. !lMsErroAuto
			DbSelectArea("SD3")
			DbGoTo((cAlias)->REC)

			aAuto := {}

			ConOut(StrZero(++nItem, 5) + ': ' + AllTrim(SD3->D3_OBSERVA) + ' ' + AllTrim(SD3->D3_COD) + ' ' + StrZero(SD3->D3_QUANT, 3) + ' ' + SD3->D3_USUARIO )
			MSExecAuto({|x,y| mata261(x,y)}, aAuto,6)

			(cAlias)->(dbSkip())
		EndDo

		If lMsErroAuto
			msgInfo("Erro ao excluir Movimentações exclusão", "ATENÇÃO")
			MostraErro()
			DisarmTransaction()
		EndIf

	else
		lMsErroAuto := .T.
		msgInfo("Registros não encontrados nas Movimentações de estoque (Tabela SD3).", "ATENÇÃO")
	EndIf
	(cAlias)->(dbCloseArea())
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
	Local cAlias 	:= GetNextAlias()
	Local cQry 		:= ""

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
	aAdd(aHeadMrk,{ "Documento"		, "D3_OBSERVA"		, X3Picture("D3_OBSERVA")   ,TamSX3("D3_OBSERVA")[1]	, 0,"AllwaysTrue()", X3Uso("D3_OBSERVA")	, "C", "", "V" } )
	nUsadMrk := len(aHeadMrk)

	aColsMrk	:= {}

	cQry := " select distinct Z0E_SEQEFE " + CRLF 
	cQry += "  from "+RetSQLName("Z0E")+" z " + CRLF 
	cQry += " where Z0E_FILIAL= '"+FwxFilial("Z0E")+"' " + CRLF 
	cQry += "   and Z0E_CODIGO= '"+Z0C->Z0C_CODIGO+"' " + CRLF 
	cQry += "   and Z0E_SEQEFE <> '    ' " + CRLF 
	cQry += "   and z.D_E_L_E_T_=' ' " + CRLF 

	MpSysOpenQuery(cQry, cAlias)

	If !(cAlias)->(Eof())
		while !(cAlias)->(Eof())
			aAdd(aColsMrk, array(nUsadMrk+1))
			aColsMrk[len(aColsMrk), 1] := "LBNO"
			aColsMrk[len(aColsMrk), 2] := (cAlias)->Z0E_SEQEFE
			aColsMrk[len(aColsMrk), 3] := "MOV." + Z0C->Z0C_CODIGO + "." + (cAlias)->Z0E_SEQEFE
			aColsMrk[len(aColsMrk),nUsadMrk+1] := .F.

			(cAlias)->(dbSkip())
		EndDo
	else
		aAdd(aColsMrk, array(nUsadMrk+1))
		aColsMrk[len(aColsMrk),nUsadMrk+1] := .F.
	EndIf
	(cAlias)->(dbCloseArea())

	lOk := .F.
	define msDialog oDlgMrk title "seleção de Sequenciais a serem estornados" /*STYLE DS_MODALFRAME*/ From aSize[1], aSize[2] To aSize[3]/2, aSize[5]/2 OF oMainWnd PIXEL

	nLinAtu += nTamLin
	oSeek	:= TButton():New( nLinAtu-2, aSize[5]/4 - 55, "Confirmar" ,oDlgMrk, {|| lOk := .T., oDlgMrk:End() },55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)

	nLinAtu += nTamLin + 5

	oBtMrk	:= TButton():New( nLinAtu-5, 02, "Inverter seleção" ,oDlgMrk, {|| MarcaDes(oGetDadMrk,"T") },60, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F.)

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
	local nSaldo 	:= 0
	//local cAliasQry := GetNextAlias()
	Local cQry 		:= ""

	default cLote := ""

	If empty(cLote)
		cQry := "select sum(B2_QATU) B2_QATU " + CRLF
		cQry += "  from "+RetSQLName("SB2")+" SB2 " + CRLF
		cQry += " where B2_FILIAL= '" + FWxFilial("SB8")+ "' " + CRLF
		cQry += "   and B2_COD= '"+cProd+"' " + CRLF
		cQry += "   and SB2.D_E_L_E_T_=' ' " + CRLF

		nSaldo := MPSysExecScalar(cQry,"B2_QATU")
	else
		cQry := " select sum(B8_SALDO) B2_QATU " + CRLF
		cQry += "  from "+RetSQLName("SB8")+" SB8 " + CRLF
		cQry += " where B8_FILIAL= '" + FWxFilial("SB8")+ "' " + CRLF
		cQry += "   and B8_PRODUTO='"+cProd+"' " + CRLF
		cQry += "   and B8_LOTECTL='"+cLote+"' " + CRLF
		cQry += "   and SB8.D_E_L_E_T_=' ' " + CRLF

		nSaldo := MPSysExecScalar(cQry,"B2_QATU")
	EndIf

	/* If !(cAliasQry)->(Eof())
		nSaldo := (cAliasQry)->B2_QATU
	EndIf
	(cAliasQry)->(dbCloseArea()) */

Return nSaldo

// -----------------------------------
User Function vlSdOri()
	Local nTotOri := 0
	Local nTotQOri := 0
	Local lRet := .T.

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
	Local lRet 		:= .T.
	//local cAliasQry := ""//GetNextAlias()
	Local cQry 		:= ""
	Local cExiste	:= ""
	Local cFiltro 	:= ""
	
	Default cLote 	:= ""
	Default lSelf 	:= .F.

	cQry := " select 1 EXISTE " + CRLF
	cQry += "	from "+RetSQLName("SB1")+" SB1 " + CRLF
	cQry += "	where B1_FILIAL='"+xFilial("SB1")+"' " + CRLF
	cQry += "	and B1_COD='"+cProduto+"' " + CRLF
	cQry += "	and SB1.D_E_L_E_T_ = '' " + CRLF
	
	cExiste := MPSysExecScalar(cQry,"EXISTE")

	If cExiste != 1
		alert("O produto informado não existe.")
		lRet := .F.
	EndIf
	//(cAliasQry)->(dbCloseArea())

	//If (cAliasQry)->(Eof())
	//	alert("O produto informado não existe.")
	//	lRet := .F.
	//EndIf
	//(cAliasQry)->(dbCloseArea())


	If lSelf
		cFiltro := " and Z0C_CODIGO<>'" + FWFldGet('Z0C_CODIGO')+ "'"
	EndIf
	
	cExiste := ''
	
	If lRet
		If !empty(cLote)
			cQry := "select Z0C_CODIGO" + CRLF 
			cQry += " from "+RetSQLName("Z0D")+" Z0D " + CRLF 
			cQry += " join "+RetSQLName("Z0C")+" Z0C on (Z0C_FILIAL='"+xFilial("Z0C")+"' and Z0C.D_E_L_E_T_ = '' and Z0C_CODIGO=Z0D_CODIGO) " + CRLF 
			cQry += " where Z0D_FILIAL='"+xFilial("Z0D")+"' " + CRLF 
			cQry += " and Z0D_PROD='"+cProduto+"' " + CRLF 
			cQry += " and Z0D_LOTE='"+cLote+"'" + CRLF 
			cQry += " and Z0C_STATUS in ('1', '4') " + CRLF 
			if cFiltro != ''
				cQry += cFiltro + CRLF 
			endif 
			cQry += " and Z0D.D_E_L_E_T_ = '' " + CRLF 

			cExiste := MPSysExecScalar(cQry,"Z0C_CODIGO")

		else
			cQry := " select Z0C_CODIGO " + CRLF 
			cQry += "	from "+RetSQLName("Z0C")+" Z0C" + CRLF 
			cQry += "	where Z0C_FILIAL = '"+xFilial("Z0C")+"' " + CRLF 
			cQry += "	and Z0C_PROD = '"+cProduto+"' " + CRLF 
			cQry += "	and Z0C_STATUS in ('1', '4')" + CRLF 
			cQry += "	and Z0C.D_E_L_E_T_ = ''" + CRLF

			cExiste := MPSysExecScalar(cQry,"Z0C_CODIGO")

		EndIf
		If AllTrim(cExiste) != ''
			alert("Este produto" + iIf(!empty(cLote),"/lote "," ") + " já está endo transferido pela Movimentação [" + cExiste + " ] que está em aberto.")
			lRet := .F.
		EndIf
		//If !(cAliasQry)->(Eof())
		//	alert("Este produto" + iIf(!empty(cLote),"/lote "," ") + " já está endo transferido pela Movimentação [" + (cAliasQry)->CODIGO + " ] que está em aberto.")
		//	lRet := .F.
		//EndIf
		//(cAliasQry)->(dbCloseArea())
	EndIf

	If lRet
		nSaldoDisp := u_getSldBv(cProduto, cLote)
		If nSaldoDisp <= 0
			alert("O saldo do produto informado está Zerado no estoque.")
			lRet := .F.
		EndIf
	EndIf

Return lRet

User Function vldLotZE(cLote)
	Local lRet 			:= .F.
	//local cAlias 		:= "" //GetNextAlias()
	Local cQry 			:= ""
	Local cExiste		:= ""
	local oModel    	:= FWModelActive()
	local oGridModel	:= oModel:GetModel('Z0DDETAIL')
	local nI 

	if Z0C->Z0C_TPMOV == '6'
		if !Empty(cLote)
			for nI := 1 to len(oGridModel:GetQtdLine())
				oGridModel:GoLine(nI)
				if cLote == oGridModel:GetValue("ZOD_LOTE")
					lRet := .t.
					exit
				endif 
			next nI 
		endif 
	else 
		cQry := " select 1 EXISTE " + CRLF 
		cQry += " from "+RetSQLName("SB8")+" SB8 " + CRLF 
		cQry += " where B8_FILIAL='"+FwxFilial("SB8")+"' " + CRLF 
		cQry += " and B8_LOTECTL='"+cLote+"' " + CRLF 
		cQry += " and SB8.D_E_L_E_T_ = '' " + CRLF 
		
		cExiste := MPSysExecScalar(cQry,"EXISTE")

		If AllTrim(cExiste) != ''
			alert("O lote informado não existe.")
			lRet := .F.
		else 
			lRet := .t. 
		EndIf
		//(cAliasQry)->(dbCloseArea())
		//If (cAliasQry)->(Eof())
		//	alert("O lote informado não existe.")
		//	lRet := .F.
		//else 
		//	lRet := .t. 
		//EndIf
		//(cAliasQry)->(dbCloseArea())
	endif 

Return lRet

User Function vldLotBv(cLote, lSelf)
	Local lRet 		:= .T.
	//local cAliasQry := GetNextAlias()
	Local cQry 		:= ""
	Local cExiste	:= ""
	Local cFiltro   := ""
	
	Default lSelf 	:= .F.

	cQry := "select 1 EXISTE" + CRLF 
	cQry += "  from "+RetSQLName("SB8")+" SB8" + CRLF 
	cQry += " where B8_FILIAL='"+FwxFilial("SB8")+"'" + CRLF 
	cQry += "   and B8_LOTECTL='"+cLote+"'" + CRLF 
	cQry += "   and SB8.D_E_L_E_T_ = ''" + CRLF 
	
	cExiste := MPSysExecScalar(cQry,"EXISTE")

	If AllTrim(cExiste) != ''
		alert("O lote informado não existe.")
		lRet := .F.
	EndIf
//	If (cAliasQry)->(Eof())
//		alert("O lote informado não existe.")
//		lRet := .F.
//	EndIf
//	(cAliasQry)->(dbCloseArea())

	If lSelf
		cFiltro += " and Z0C_CODIGO<>'" + FWFldGet('Z0C_CODIGO')+ "'"
	EndIf

	If lRet
		cExiste := ""

		cQry := "select Z0C_CODIGO " + CRLF 
		cQry += "  from "+RetSQLName("Z0D")+" Z0D " + CRLF 
		cQry += "  join "+RetSQLName("Z0C")+" Z0C on (Z0C_FILIAL='"+FwxFilial("Z0C")+"' and Z0C.D_E_L_E_T_ = '' and Z0C_CODIGO=Z0D_CODIGO) " + CRLF 
		cQry += " where Z0D_FILIAL='"+FwxFilial("Z0D")+"' " + CRLF 
		cQry += "   and Z0D_LOTE='"+cLote+"' " + CRLF 
		cQry += "   and Z0C_STATUS in ('1', '4') " + CRLF 
		If cFiltro != ''
		cQry += cFiltro + CRLF 
		endif 
		cQry += "   and Z0D.D_E_L_E_T_ = '' " + CRLF 

		cExiste := MPSysExecScalar(cQry,"Z0C_CODIGO")

		If AllTrim(cExiste) != ""
			alert("Este lote [" + AllTrim(cLote) + " ] já está endo transferido pela Movimentação [" + (cAliasQry)->CODIGO + " ] que está em aberto.")
			lRet := .F.
		EndIf

		//If !(cAliasQry)->(Eof())
		//	alert("Este lote [" + AllTrim(cLote) + " ] já está endo transferido pela Movimentação [" + (cAliasQry)->CODIGO + " ] que está em aberto.")
		//	lRet := .F.
		//EndIf
		//(cAliasQry)->(dbCloseArea())
	EndIf

Return lRet

User Function VAMDLA01()
	Local aParam    := PARAMIXB
	Local xRet      := .T.
	Local oObj      := ''
	Local cIdPonto  := ''
	Local cIdModel  := ''
	local cAlias 	:= ""//GetNextAlias()
	local cQry  	:= ""//GetNextAlias()
	Local oGrid		 := nil

	If aParam <> NIL

		oObj      := aParam[1]
		cIdPonto  := aParam[2]
		cIdModel  := aParam[3]

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
				
				oGridZ0E := oObj:GetModel( 'Z0EDETAIL' )
				oGridZ0D := oObj:GetModel( 'Z0DDETAIL' )
				
				oGridZ0E:SetNoUpdateLine(.F.)
				oGridZ0E:SetNoDeleteLine(.F.) 

				oGridZ0D:SetNoUpdateLine(.F.)
				oGridZ0D:SetNoDeleteLine(.F.)

		EndIf

		// ElseIf cIdPonto == 'MODELPOS'
		// ElseIf cIdPonto == 'FORMPOS'
		// ElseIf cIdPonto == 'FORMLINEPRE'
		// ElseIf cIdPonto == 'FORMLINEPOS'
	ElseIf cIdPonto == 'MODELCOMMITTTS'

		If oObj:nOperation == 5

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

		//Corrige inconsistencia da função FWFormCommit
		cAlias := GetNextAlias()
		cQry := "select Z0D_PROD, Z0D_SEQ, Z0D_LOTE, count(R_E_C_N_O_) QTD, max(R_E_C_N_O_) ULT " + CRLF
		cQry += "	  from "+RetSQLName("Z0D")+" Z0D " + CRLF
		cQry += "	 where Z0D_FILIAL='"+FwxFilial("Z0D")+"'  " + CRLF
		cQry += "	   and Z0D_CODIGO='"+Z0C->Z0C_CODIGO+"'" + CRLF
		cQry += "	   and Z0D.D_E_L_E_T_= '' " + CRLF
		cQry += "	 group by Z0D_PROD, Z0D_SEQ, Z0D_LOTE " + CRLF
		cQry += "	having count(R_E_C_N_O_) > 1 " + CRLF

		MpSysOpenQuery(cQry, cALias)
		
		if !(cAlias)->(Eof())
			dbSelectArea("Z0D")
			while !(cAlias)->(Eof())
				dbGoTo((cAlias)->ULT)
				RecLock("Z0D", .F.)
					Z0D->(dbDelete())
				msUnlock()
				(cAlias)->(dbSkip())
			EndDo
		endIf
		(cAlias)->(DbCloseArea())

		//Corrige inconsistencia da função FWFormCommit
		cAlias := GetNextAlias()

		cQry := "select Z0E_PROD, Z0E_SEQ, Z0E_LOTE, count(R_E_C_N_O_) QTD, max(R_E_C_N_O_) ULT "+ CRLF
		cQry += "	  from "+RetSQLName("Z0E")+" Z0E "+ CRLF
		cQry += "	 where Z0E_FILIAL='"+FwxFilial("SB8")+"'  "+ CRLF
		cQry += "	   and Z0E_CODIGO='"+Z0C->Z0C_CODIGO+"'"+ CRLF
		cQry += "	   and Z0E.D_E_L_E_T_= ''  "+ CRLF
		cQry += "	 group by Z0E_PROD, Z0E_SEQ, Z0E_LOTE "+ CRLF
		cQry += "	having count(R_E_C_N_O_) > 1 "+ CRLF

		mpSysOpenQuery(cQry, cALias)

		if !(cAlias)->(Eof())
			dbSelectArea("Z0E")
			while !(cAlias)->(Eof())
				dbGoTo((cAlias)->ULT)
				RecLock("Z0E", .F.)
					Z0E->(dbDelete())
				msUnlock()
				(cAlias)->(dbSkip())
			EndDo
		endIf
		(cAlias)->(DbCloseArea())

		oGrid := oObj:GetModel( 'Z0EDETAIL' )
		U_DelLoteSB8( oGrid:GetValue('Z0E_CODIGO') )

	ElseIf cIdPonto == 'MODELCANCEL'
		// Disponibilizar o Lote reservado
		oGrid := oObj:GetModel( 'Z0EDETAIL' )
		
		U_DelLoteSB8( oGrid:GetValue('Z0E_CODIGO') )
	EndIf

EndIf

Return xRet
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
	local nTamLin      := 16
	local nLinIni      := 03
	local nLinAtu      := nLinIni
	Local nI           := 0, nJ := 0
	Local aItems       := {}
	Local cALias 		:= ""
	Local cALias1 		:= ""
	Local cQry 			:= ""

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

	Private aHeadVL	:= {}
	Private nPosVW_LOTE   := 0
	Private nPosVW_CURRAL := 0
	Private nPosVW_RACA   := 0
	Private nPosVW_SEXO   := 0
	Private nPosVW_QUANT  := 0
	Private nPosVW_QTDPES := 0

	If Z0C->Z0C_TPMOV/* FwFldGet('Z0C_TPMOV') */ != "2"
		msgInfo('A Pesagem é permitida apenas quando o tipo de Movimentação é Apartação"')
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

				If AllTrim(aHeadOri[nJ,2]) == "Z0D_QUANT"
					nQtdOri += oGridOri:GetValue(aHeadOri[nJ, 2], nI)
				EndIf
			endFor
		EndIf
	Next

	aHeadVL := {}
	/*01*/aAdd(aHeadVL, { "Lote"	   , "VW_LOTE"	, X3Picture("Z0D_LOTE")	  , TamSX3("Z0D_LOTE")[1]		 , 0 ,"AllwaysTrue()", X3Uso("Z0D_LOTE")	, "C", "   ", "V","","","","V","","","" } )
	/*02*/aAdd(aHeadVL, { "Curral"	   , "VW_CURRAL", X3Picture("Z0D_CURRAL") , 10/*TamSX3("Z0D_CURRAL")[1]*/, 0 ,"AllwaysTrue()", X3Uso("Z0D_CURRAL")	, "C", "   ", "V","","","","V","","","" } )
	///*03*/aAdd(aHeadVL, { "Raca"	   , "VW_RACA"	, X3Picture("Z0D_RACA")   , TamSX3("Z0D_RACA")[1]        , 0 ,"AllwaysTrue()", X3Uso("Z0D_RACA")	, "C", "   ", "V","","","","V","","","" } )
	///*04*/aAdd(aHeadVL, { "Sexo"	   , "VW_SEXO"	, X3Picture("Z0D_SEXO")   , TamSX3("Z0D_SEXO")[1]+5 	 , 0 ,"AllwaysTrue()", X3Uso("Z0D_SEXO")	, "C", "   ", "V","","","","V","","","" } )
	/*05*/aAdd(aHeadVL, { "Qtd Animais", "VW_QUANT"	, X3Picture("Z0D_QUANT")  , TamSX3("Z0D_QUANT")[1]	     , 0 ,"AllwaysTrue()", X3Uso("Z0D_QUANT")	, "N", "   ", "V","","","","V","","","" } )
	/*06*/aAdd(aHeadVL, { "Qtd Pesada" , "VW_QTDPES", X3Picture("Z0D_QUANT")  , TamSX3("Z0D_QUANT")[1]	     , 0 ,"AllwaysTrue()", X3Uso("Z0D_QUANT")	, "N", "   ", "V","","","","V","","","" } )
	nUsadVL := len(aHeadVL)

	nPosVW_LOTE   := aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_LOTE"})
	nPosVW_CURRAL := aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_CURRAL"})
	//nPosVW_RACA   := aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_RACA"})
	//nPosVW_SEXO   := aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_SEXO"})
	nPosVW_QUANT  := aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_QUANT"})
	nPosVW_QTDPES := aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_QTDPES"})

	aColsVL := {}
	for nI := 1 to len(aColsOri)
		nPos := aScan(aColsVL, { |x| x[1]==aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_LOTE"})] ;
			                   /* .AND. x[5]==aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_DENTIC"})] */ })
			//.AND. x[4]==aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_SEXO"})]   ;
			//.AND. x[3]==aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_RACA"})]   ;
		If nPos == 0
			aAdd(aColsVL, Array(nUsadVL+1))
			aColsVL[len(aColsVL),1] := aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_LOTE"})]
			aColsVL[len(aColsVL),2] := aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_CURRAL"})]
			//aColsVL[len(aColsVL),3] := aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_RACA"})]
			//aColsVL[len(aColsVL),4] := aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_SEXO"})]
			//aColsVL[len(aColsVL),5] := aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_DENTIC"})]
			aColsVL[len(aColsVL),3] := aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_QUANT"})]
			aColsVL[len(aColsVL),4] := 0
			aColsVL[len(aColsVL), nUsadVL+1] := .F.
		else
			aColsVL[nPos,3] += aColsOri[nI, aScan( aHeadOri,{ |x| AllTrim(x[2]) == "Z0D_QUANT"})]
		EndIf
	Next

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
	nUsadDet := len(aHeadDet)
	aColsDet := {}
	aColsDet := U_AtualizaZ0F(.F.)

	aHeadRan := GeraHeader("ZV2", .F.)
	aHeadRan[aScan( aHeadRan,{ |x| AllTrim(x[2]) == "ZV2_PESINI"}), 6] := "Positivo() .and. U_VLDRANGES(.T.)"
	aHeadRan[aScan( aHeadRan,{ |x| AllTrim(x[2]) == "ZV2_PESFIM"}), 6] := "Positivo() .and. U_VLDRANGES(.T.)"
	nUsadRan := len(aHeadRan)
	aColsRan := {}

	cQry := "		select * from "+RetSQLName("ZV2")+" ZV2 " + CRLF
	cQry += "	 where ZV2_FILIAL='"+FwxFilial("SB8")+"' " + CRLF
	cQry += "	   and ZV2_MOVTO='"+Z0C->Z0C_CODIGO+"'"+ CRLF
	cQry += "	   and ZV2.D_E_L_E_T_ = '' " + CRLF
	cQry += "	 order by ZV2_PESINI " + CRLF
	
	cAlias := GetNextAlias()
	
	MpSysOpenQuery(cQry, cAlias)

	If !(cAlias)->(Eof())
		while !(cAlias)->(Eof())
			aAdd(aColsRan, Array(nUsadRan+1))
			aColsRan[len(aColsRan), nUsadRan+1] := .F.
			for nJ := 1 to len(aHeadRan)
				aColsRan[len(aColsRan), nJ] := &("(cAlias)->" + aHeadRan[nJ, 2])
			Next
			(cAlias)->(dbSkip())
		EndDo
	else
		cQry := " select * from "+RetSQLName("ZV1")+" ZV1 " + CRLF
		cQry += " where ZV1_FILIAL='"+FwxFilial("ZV1")+"' " + CRLF
		cQry += "   and ZV1.D_E_L_E_T_ = '' " + CRLF
		cQry += " order by ZV1_PESINI " + CRLF

		cALias1 := GetNextAlias()
	
		MpSysOpenQuery(cQry, cALias1)

		while !(cALias1)->(Eof())
			RecLock("ZV2", .T.)
				ZV2->ZV2_FILIAL := FWxFilial("ZV2")
				ZV2->ZV2_MOVTO  := Z0C->Z0C_CODIGO // FWFldGet('Z0C_CODIGO')
				ZV2->ZV2_PESINI := (cALias1)->ZV1_PESINI
				ZV2->ZV2_PESFIM := (cALias1)->ZV1_PESFIM
				ZV2->ZV2_LOTE   := (cALias1)->ZV1_LOTE
				ZV2->ZV2_CURRAL := (cALias1)->ZV1_CURRAL
			MsUnlock()

			aAdd(aColsRan, Array(nUsadRan+1))
			aColsRan[len(aColsRan), nUsadRan+1] := .F.
			aColsRan[len(aColsRan), 1] := Z0C->Z0C_CODIGO // FWFldGet('Z0C_CODIGO')
			aColsRan[len(aColsRan), 2] := (cALias1)->ZV1_PESINI
			aColsRan[len(aColsRan), 3] := (cALias1)->ZV1_PESFIM
			aColsRan[len(aColsRan), 4] := (cALias1)->ZV1_LOTE
			aColsRan[len(aColsRan), 5] := (cALias1)->ZV1_CURRAL

			(cALias1)->(DbSkip())
		EndDo
		(cALias1)->(DbCloseArea())
	EndIf
	(cAlias)->(DbCloseArea())

	nTop    := aSize[1]
	nLeft   := aSize[2]-10
	nBottom := aSize[3]*(14/15)
	nRight  := aSize[5]*(14/15)

	define msDialog oDlgPsg title "Pesagem de Animais: " + Z0C->Z0C_CODIGO /*STYLE DS_MODALFRAME*/ From nTop,nLeft To nBottom,nRight OF oMainWnd PIXEL
	oDlgPsg:lMaximized := .T. //Maximiza a janela

	oSayTempo := TSay():New(nLinAtu, 10,{|| 'Processamento de Animais: (Apartação)  Tempo: '+cTempo+'  Média p/ animal: '+cMedia},oDlgPsg,,,,,,.T.,,,500,10)
	oSayTempo:SetCss("QLabel{ color: #222; font-weight: bold; font-size: 12pt}")

	oTButton1 := TButton():New( nLinAtu-1, (nRight)/2 - 60 , "Confirmar" ,oDlgPsg,;
		{|| FWMsgRun(, {|| U_SalvarGeral( oModel, oView ) },;
		"Processando", "Gravando pesagens no movimento...") }, 55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F. )
	//oTButton1:SetCss("QPushButton{ background: #000; margin: 2px; font-weight: bold; }")

	nLinAtu += nTamLin
	nLinAtu += nTamLin+4

	oSayOri := TSay():New(nLinAtu - nTamLin, 10 ,{||'Lotes de Origem'},oDlgPsg,,,,,,.T.,,,100,30)
	oSayOri:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 16pt; text-decoration: underline}")
	oGetDadOri:= MsNewGetDados():New(nLinAtu, 10, (nBottom)/4 - 30, (nRight)/6 + 6, nOpc , cLinOk, cTudoOk,,,,999999,,,,oDlgPsg, aHeadOri, aColsOri)
	oGetDadVL:= MsNewGetDados():New( nLinAtu, 10, (nBottom)/4 - 30, (nRight)/6 + 6, nOpc , cLinOk, cTudoOk,,,,999999,,,,oDlgPsg, aHeadVL, aColsVL)
	oSayFOri := TSay():New(nLinAtu - nTamLin + 2, 100 ,{||''},oDlgPsg,,,,,,.T.,,,200,30)
	oGetDadVL:oBrowse:blDblClick :=  {|| U_ForceOri()}

	oSayQO := TSay():New((nBottom)/4 - 20, 10,{|| 'QTDE ORIGEM: '+cValToChar(nQtdOri) },oDlgPsg,,,,,,.T.,,,200,20)
	oSayQO:SetCss("QLabel   { color: #000; font-weight: bold; font-size: 12pt}")

	oSayRan := TSay():New(nLinAtu - nTamLin, (nRight)/2 - (nRight)/6 ,{||'Parametros'},oDlgPsg,,,,,,.T.,,,100,30)
	oSayRan:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 16pt; text-decoration: underline}")
	oGetDadRan:= MsNewGetDados():New(nLinAtu, (nRight)/2 - (nRight)/6, (nBottom)/4 - 60, (nRight)/2 -3 , GD_INSERT+GD_UPDATE+GD_DELETE , "U_aVldLin()"/* cLinOk */, cTudoOk,,,,999999,;
		"U_SalvarRange()","U_aVldLin()","U_aVldLot()",oDlgPsg, aHeadRan, aColsRan)
	oGetDadRan:oBrowse:blDblClick :=  {|| U_ForceLote()}
	oGetDadRan:oBrowse:SetCSS(;
            "QHeaderView::Section {font-weight: bold;}} " +; //Cabeçallho
            "QTableView { font-size: 14px; } "; //Grid
        )
	oSayForce := TSay():New(nLinAtu - nTamLin, (nRight)/2 - (nRight)/6 + 70 ,{||''},oDlgPsg,,,,,,.T.,,,200,30)

	oSayQD := TSay():New((nBottom)/4 - 20, (nRight)/2 - (nRight)/6,{|| 'QTDE DESTINO: '+cValToChar(nQtdDes) },oDlgPsg,,,,,,.T.,,,200,20)
	oSayQD:SetCss("QLabel   { color: #000; font-weight: bold; font-size: 12pt}")

	nPeso := 0
	oSayPeso := TSay():New(nLinAtu - nTamLin-5, (nRight)/4 - 20 ,{||'Peso'},oDlgPsg,,,,,,.T.,,,100,30)
	oSayPeso:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 24pt}")
	oGet1 := TGet():New( nLinAtu, (nRight)/4 - 80, { | u | If( PCount() == 0, nPeso, nPeso := u ) },oDlgPsg, 160, 030, "@E 9,999.999",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nPeso")
	oGet1:SetCss("QLineEdit{ color: #000; font-weight: bold; font-size: 24pt}")

	oTButton2 := TButton():New( nLinAtu + nTamLin*2+5, (nRight)/4 - 80, "Pesar" ,oDlgPsg,{|| FWMsgRun(, {|| nPeso := U_MA01BAL() }, "Processando", "Obtendo peso da balanca...") }, 55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F. )
	//oTButton2:SetCss("QPushButton{ background: #000; margin: 2px; font-weight: bold; }")

	oTButton3 := TButton():New( nLinAtu + nTamLin*2+5, (nRight)/4 - 25, "Registrar", oDlgPsg,;
		{|| FWMsgRun(, {|| U_Registrar( oModel /* oGetDadDet:aCols */) },;
		"Processando", "Gravando peso no movimento...") }, 55, nTamLin+4,,,.F.,.T.,.F.,,.F.,,,.F. )

	aItems := {'nenhum'}
	// comboRaca 

	cQry := "SELECT distinct Z09_RACA " + CRLF
	cQry += "  FROM "+RetSQLName("Z09")+" Z09 " + CRLF
	cQry += " WHERE Z09_FILIAL='"+FwxFilial("Z09")+"' " + CRLF
	cQry += "   AND Z09_RACA <> ' ' " + CRLF
	cQry += "   AND Z09_RACA NOT LIKE 'BUFAL%' " + CRLF
	cQry += "   AND Z09.D_E_L_E_T_ = '' " + CRLF
	cQry += " ORDER by 1 desc " + CRLF
	
	cALias := GetNextAlias()
	MpSysOpenQuery(cQry, cALias)

	while !(cALias)->(Eof())
		If !empty((cALias)->Z09_RACA)

			aAdd(aItems, AllTrim((cALias)->Z09_RACA))
		EndIf
		(cALias)->(dbSkip())
	EndDo
	(cALias)->(dbCloseArea())

	nRadRaca := 1
	oRadRaca := TRadMenu():New ( nLinAtu + nTamLin*5, (nRight)/4 - 80, aItems,, oDlgPsg,,,,,,,,80, 00,,,,.T.)
	oRadRaca:bSetGet := {|u|Iif (PCount()==0,nRadRaca,nRadRaca:=u)}
	oSayRaca := TSay():New(nLinAtu + nTamLin*4,(nRight)/4 -80,{||'Raça'},oDlgPsg,,,,,,.T.,,,80,00)
	oRadRaca:SetCss("QRadioButton{ font-weight: bold; font-size: 14pt}")
	oSayRaca:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 14pt}")

	nRadDent := 1
	aItems := {'nenhum','0=Zero','2=Dois','4=Quatro','6=Seis','8=Oito'}
	oRadDent := TRadMenu():New (nLinAtu + nTamLin*5, (nRight)/4 + 30, aItems,, oDlgPsg,,,,,,,,80, 10,,,,.T.)
	oRadDent:bSetGet := {|u|Iif (PCount()==0,nRadDent,nRadDent:=u)}
	oSayDent := TSay():New(nLinAtu + nTamLin*4,(nRight)/4 + 30,{||'Dentes'},oDlgPsg,,,,,,.T.,,,80,00)
	oRadDent:SetCss("QRadioButton{ font-weight: bold; font-size: 14pt}")
	oSayDent:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 14pt}")

	nLinAtu := nTamLin*8 + 4

	nLinAtu := (nBottom)/4 + 10
	oSayDet := TSay():New(nLinAtu - nTamLin, 10 ,{||'Pesagens realizadas'},oDlgPsg,,,,,,.T.,,,200,30)
	oSayDet:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 16pt; text-decoration: underline}")
	oGetDadDet:= MsNewGetDados():New(nLinAtu, 10      , (nBottom)/2 -10, (nRight)/2 - (nRight)/6 - 10, nOpc+GD_DELETE , cLinOk     , cTudoOk   ,            ,          ,           ,999999  ,;
		"U_ChangeZ0F()",,;
		"U_DeleteZ0F()" ,oDlgPsg, aHeadDet, aColsDet)
	//			 MsNewGetDados():New([ nTop], [ nLeft], [ nBottom]     , [ nRight ]                  , [ nStyle]      , [ cLinhaOk], [ cTudoOk], [ cIniCpos], [ aAlter], [ nFreeze], [ nMax], [ cFieldOk]                      , [ cSuperDel], [ cDelOk]                         , [ oWnd], [ aPartHeader], [ aParCols], [ uChange], [ cTela] )
	oGetDadDet:bChange := { || U_calcular_destino() }
	
	oSayDes := TSay():New(nLinAtu - nTamLin, (nRight)/2 - (nRight)/6 ,{||'Lotes de Destino'},oDlgPsg,,,,,,.T.,,,200,30)
	oSayDes:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 16pt; text-decoration: underline}")
	oGetDadDes:= MsNewGetDados():New(nLinAtu, (nRight)/2 - (nRight)/6	, (nBottom)/2 - 60, (nRight)/2 -3, nOpc , cLinOk, cTudoOk,,,,999999,,,,oDlgPsg, aHeadDes, aColsDes)
	oGetDadVw:= MsNewGetDados():New(nLinAtu, (nRight)/2 - (nRight)/6	, (nBottom)/2 - 60, (nRight)/2 -3, nOpc , cLinOk, cTudoOk,,,,999999,,,,oDlgPsg, aHeadVw, aColsVw)
	
	oGetDadVw:oBrowse:SetCSS(;
            "QHeaderView::Section {font-weight: bold;font-size: 14px;} " +; //Cabeçallho
            "QTableView { font-size: 14px; } "; //Grid
        )
	oGetDadDes:oBrowse:SetCSS(;
            "QHeaderView::Section {font-weight: bold;font-size: 14px;} " +; //Cabeçallho
            "QTableView { font-size: 14px; } "; //Grid
        )

	oSayFt := TSay():New(nLinAtu -20, (nRight)/4 - 80,{|| 'FALTAM [ '+cValToChar(nQtdOri-nQtdDes)+' ] ANIMAIS PARA PESAR' },oDlgPsg,,,,,,.T.,,,200,20)
	oSayFt:SetCss("QLabel{ color: #000; font-weight: bold; font-size: 14pt}")

	If oModel:nOperation <> 4
		SetKey(VK_F5, {|| FWMsgRun(, {|| U_AtualizaZ0F(.T.) }, "Atualizando", "Buscando pesagens...") })
	EndIf
	SetKey(VK_F10, {|| FWMsgRun(, {|| nPeso := U_MA01BAL() }) })
	SetKey(VK_F11, {|| FWMsgRun(, {|| U_Registrar( oModel /* oGetDadDet:aCols */) }, "Processando", "Gravando peso no movimento...") })

	Activate dialog oDlgPsg centered

	SetKey(VK_F5, {||  })
	SetKey(VK_F10, {||  })
	SetKey(VK_F11, {||  })
Return

User Function AtualizaZ0F(lGrid)
	local aColsDet 	:= {}
	Local nJ 		:= 0
	Local cAlias 	:= GetNextAlias()
	Local cQry 		:= ""

	default lGrid := .T.

	cQry := "select Z0F.*, Z0F.R_E_C_N_O_ NRECNO, ZBC_CODIGO Z0F_CONTR, ZBC_PEDIDO Z0F_PEDID, A2_NOME Z0F_FORNE " + CRLF
	cQry += "  from "+RetSQLName("Z0F")+" Z0F " + CRLF
	cQry += "  left join "+RetSQLName("ZBC")+" ZBC on (ZBC.ZBC_FILIAL='"+FwxFilial("ZBC")+"' and ZBC.D_E_L_E_T_ = '' and ZBC_PRODUT=Z0F_PROD and ZBC_VERSAO=(select max(ZBC_VERSAO) from "+RetSQLName("ZBC")+" Z2 where Z2.ZBC_FILIAL=ZBC.ZBC_FILIAL and Z2.ZBC_CODIGO=ZBC.ZBC_CODIGO and Z2.D_E_L_E_T_ = '' )) " + CRLF
	cQry += "  left join "+RetSQLName("SA2")+" SA2 on (SA2.A2_FILIAL ='"+FwxFilial("SA2")+"' and SA2.D_E_L_E_T_ = '' and A2_COD=ZBC_CODFOR and A2_LOJA=ZBC_LOJFOR) " + CRLF
	cQry += " where Z0F_FILIAL='"+FwxFilial("Z0F")+"' " + CRLF
	cQry += "   and Z0F_MOVTO='"+Z0C->Z0C_CODIGO+"'" + CRLF
	cQry += "   and Z0F.D_E_L_E_T_ = '' " + CRLF
	cQry += " order by Z0F_MOVTO, Z0F_SEQ " + CRLF
	//cQry += " order by Z0F_MOVTO, Z0F_LOTORI,Z0F_HRPES" + CRLF

	MpSysOpenQuery(cQry, cALias)

	while !(cALias)->(Eof())
		aAdd(aColsDet, Array(nUsadDet+1))
		aColsDet[len(aColsDet), nUsadDet+1] := .F.
		for nJ := 1 to len(aHeadDet)
			If aHeadDet[nJ, 8] = 'D'
				aColsDet[len(aColsDet), nJ] := STOD( &("(cALias)->" + aHeadDet[nJ, 2]) )
			elseIf !empty(aHeadDet[nJ, 11]) .and. aHeadDet[nJ, 8] = 'C'
				aColsDet[len(aColsDet), nJ] := AllTrim( &("(cALias)->" + aHeadDet[nJ, 2]) )
			else
				aColsDet[len(aColsDet), nJ] := &("(cALias)->" + aHeadDet[nJ, 2])
			EndIf
		endFor

		(cALias)->(DbSkip())
	EndDo
	(cALias)->(DbCloseArea())

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
		If AllTrim(aSaldos[nI, 1]) == AllTrim(cLote)

			nRet += aSaldos[nI, 4]
		EndIf
	Next

Return nRet


User Function ForceOri()

	If oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_QTDPES] == oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_QUANT]
		msgInfo("O lote selecionado já foi atendido totalmente nas pesagens anteriores, verIfique se foi selecionado o lote correto.")
		Return nil
	EndIf

	If empty(cLoteOri)  .and.;
			Empty(cCurrOri) .and.;
			Empty(cRacaOri) .and.;
			Empty(cSexoOri) 

		cLoteOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_LOTE]
		cCurrOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_CURRAL]
		//cRacaOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_RACA]
		//cSexoOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_SEXO]

		else

		If cLoteOri == oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_LOTE]    .AND.;
				cCurrOri == oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_CURRAL] //.AND.;
				//cRacaOri == oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_RACA]   .AND.;
				//cSexoOri == oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_SEXO]  

				cLoteOri := ""
				cCurrOri := ""
				cRacaOri := ""
				cSexoOri := ""
			else
				cLoteOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_LOTE]
				cCurrOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_CURRAL]
				//cRacaOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_RACA]
				//cSexoOri := oGetDadVL:aCols[oGetDadVL:oBrowse:nAt, nPosVW_SEXO]
		EndIf
	EndIf

	If !empty(cLoteOri)
		oSayFOri:SetText("Lote: " + AllTrim(cLoteOri) + "  - Curral: " + AllTrim(cCurrOri)+;
			' - ' +AllTrim(cRacaOri)+;
			' - ' +AllTrim(cSexoOri) )
	else
		oSayFOri:SetText("")
	EndIf
Return

User Function ForceLote()
	If !oGetDadRan:aCols[ oGetDadRan:oBrowse:nAt, nUsadRan+1]
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
			oSayForce:SetCss("QLabel{ color: #FF0000; font-weight: bold; font-size: 14pt;text-decoration: underline}")
		else
			oSayForce:SetText("")
		EndIf
	EndIf
Return


User Function vldRanges(lLinha)
	Local nI		:= 0
	Local nL		:= 0

	default lLinha := .F.

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
							msgAlert("O Peso Inicial informado na linha [" + cValToChar(oGetDadRan:oBrowse:nAt) + " ] já encontra-se informado na linha: " + cValToChar(nI))
							Return .F.
						EndIf

						If nPesFim >= oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] .and. nPesFim <= oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})]
							msgAlert("O Peso Final informado na linha [" + cValToChar(oGetDadRan:oBrowse:nAt) + " ] já¥ncontra-se informado na linha: " + cValToChar(nI))
							Return .F.
						EndIf

						If oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] >= nPesIni  .and. oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESINI"})] <= nPesFim
							msgAlert("O Peso Inicial informado na linha [" + cValToChar(nI) + " ] já encontra-se informado na linha: " + cValToChar(oGetDadRan:oBrowse:nAt))
							Return .F.
						EndIf

						If oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})] >= nPesIni .and. oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) == "ZV2_PESFIM"})] <= nPesFim
							msgAlert("O Peso Final informado na linha [" + cValToChar(nI) + " ] já encontra-se informado na linha: " + cValToChar(oGetDadRan:oBrowse:nAt))
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
						If !oGetDadRan:aCols[ nL, nUsadRan+1]
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
	Local cAlias	 := GetNextAlias()
	Local cQry		 := ""

	For nI := 1 to len(oGetDadDet:aCols)
		If oGetDadDet:aCols[nI, nPosLote] == cLote //.and. Empty(oGetDadDet:aCols[nI, nPosSeqE])
			oGetDadDet:aCols[nI, nPosCurral] := cCurral
		EndIf
	Next nI
	oGetDadDet:oBrowse:Refresh()

	cQry := "SELECT  R_E_C_N_O_  " + CRLF
	cQry += "	FROM	"+RetSqlName("Z0F")+" " + CRLF
	cQry += "	WHERE	Z0F_FILIAL = '"+FwxFilial("Z0F")+"' " + CRLF
	cQry += "		AND Z0F_MOVTO  = '"+Z0C->Z0C_CODIGO+"'" + CRLF
	cQry += "		AND Z0F_LOTE   = '"+cLote+"'" + CRLF
	
	MpSysOpenQuery(cQry, cALias)

	while !(cALias)->(Eof())
		Z0F->(DbGoTo((cALias)->R_E_C_N_O_))

		RecLock('Z0F', .F.)
			Z0F->Z0F_CURRAL := cCurral
		Z0F->(MsUnLock())

		(cALias)->(dbSkip())
	EndDo
	(cALias)->(dbCloseArea())

	U_calcular_destino()
Return nil

/* ==================================================================================== */
User Function aVldLin()
Return .T.

User Function aVldLot()
	Local nI		:= 0
	Local nJ		:= 0
	Local lRet 		:= .T. 
	Local cLote 	:= oGetDadRan:aCols[ oGetDadRan:nAt, 4/*Lote*/]
	Local lDelete 	:= oGetDadRan:aCols[ oGetDadRan:nAt, 6]

	if AllTrim(cLote) == ""
		Return .t. 
	endif
	
	For nI := 1 To Len(aColsDes)
		if cLote == aColsDes[nI,3]
			MsgInfo("Linha não pode ser deletada, pois esse lote já está cadastrado na grid [Pesagens Realizadas] na Linha: "+AllTrim(Str(nI))+".",;
					"Operação Cancelada")
			Return .F.
		endif
	Next nI

	if oGetDadRan:lDelete
		MsgInfo("Operação não pode ser realizada, insira uma nova linha com as informações do lote!",;
				"Operação Cancelada")
		Return .F.
		//cSql := "update " + retSqlName("ZV2") + " set D_E_L_E_T_='*', R_E_C_D_E_L_=R_E_C_N_O_ " + CRLF 
		//cSql += " where ZV2_FILIAL='"+ FWxFilial("ZV2") +"'"+ CRLF
		//cSql += " and ZV2_MOVTO = '" + Z0C->Z0C_CODIGO + "'" + CRLF
		//cSql += " and ZV2_LOTE = '" + cLote + "'"
		//
		//nStatus := TCSqlExec(cSql)
		//If (nStatus < 0)
		//	conout("TCSQLError() " + TCSQLError())
		//	Return .F.
		//EndIf
		//
		//If (TCSqlExec("DELETE FROM SX5010 WHERE X5_TABELA='Z8' AND RTRIM(X5_DESCRI) = '" +;
		//	AllTrim(cLote) + "'" ) < 0)
		//	ConOut("Erro ao liberar lote: " + AllTrim(cLote) + CRLF + TCSQLError())
		//	Return .F.
		//EndIf
	else 

		RecLock("ZV2", .T.)
			ZV2->ZV2_FILIAL := FWxFilial("ZV2")
			for nJ := 1 to len(aHeadRan)
				&("ZV2->" + aHeadRan[nJ, 2] + "  := oGetDadRan:aCols[ oGetDadRan:nAt, nJ]")
			endFor
		MsUnlock()

		if !Empty( cLote )
			RecLock('SX5', .T.)
				SX5->X5_FILIAL 	:= ' '
				SX5->X5_TABELA 	:= 'Z8'
				SX5->X5_CHAVE  	:= SubS(cLote, 1, At("-", cLote)-1)
				SX5->X5_DESCRI 	:= cLote
				SX5->X5_DESCSPA	:= Z0C->Z0C_CODIGO
				SX5->X5_DESCENG	:= dToS(dDataBase)
			SX5->(MsUnLock())
		EndIf
	endif

	oGetDadRan:Refresh()
Return lRet

User Function SalvarRange()
	local aArea 	:= GetArea()
	local cSql		:= ""
	Local nI		:= 0, nJ := 0
	Local cQry  	:= ""
	Local cAlias 	:= ""
	Local lVldLot 	:= .F.
	//Local cLotAnt 	:= oGetDadRan:aCols[ oGetDadRan:nAt, 4]

	//For nI := 1 To Len(aColsDes)
	//	if oGetDadRan:aCols[ oGetDadRan:nAt, 4] == aColsDes[nI,3]  // /*Lote*/
	//		MsgInfo("lote não pode ser, pois esse lote já está cadastrado na grid [Pesagens Realizadas] na Linha: "+AllTrim(Str(nI))+".",;
	//				"Operação Cancelada")
	//		Return .F.
	//	endif 
	//Next nI 

	If !U_vldRanges(.F.)
	    RestArea(aArea)
		Return .F.
	EndIf

	// MB : 05.08.2019
	If (lVldLot := IsInCallStack("U_aVldLot")) .or. ReadVar() == "M->ZV2_LOTE" // .and. ;
		If !U_libVldLote(iif(lVldLot, oGetDadRan:aCols[ oGetDadRan:nAt, 4/*Lote*/],;
									  AllTrim(&(ReadVar()))), .T., "M->ZV2_LOTE"/* , @__xRetorno */ )
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
			cQry := "SELECT DISTINCT B8_LOTECTL, B8_X_CURRA, SUM(B8_SALDO) SALDO " + CRLF 
			cQry += "	FROM  "+RetSQLName("SB8")+" " + CRLF 
			cQry += "	WHERE B8_LOTECTL='"+oGetDadRan:aCols[ oGetDadRan:nAt, 4/*Lote*/]+"'" + CRLF 
			cQry += "	  AND D_E_L_E_T_ = '' " + CRLF
			cQry += "	GROUP BY B8_LOTECTL, B8_X_CURRA " + CRLF 
			
			cAlias := GetNextAlias()
			MpSysOpenQuery(cQry, cALias)
			
			If !(cALias)->(Eof())  .and. &(ReadVar()) <> (cALias)->B8_X_CURRA
				Alert("O curral informado: [" + &(ReadVar()) + "] nao pode ser utilizado. Ja existe saldo para o mesmo no curral: " + (cALias)->B8_X_CURRA +".")
				RestArea(aArea)
			EndIf
			(cALias)->(dbCloseArea())

			If MsgYesNo("O Curral ["+AllTrim(oGetDadRan:aCols[ oGetDadRan:nAt, 5/*Curral*/])+"] foi alterado para ["+;
					AllTrim(&(ReadVar()))+"]. Confirma a alteração do curral ?")
				AtualCurral(oGetDadRan:aCols[ oGetDadRan:nAt, 4/*Lote*/], AllTrim(&(ReadVar())))
			EndIf
		EndIf
	EndIf
/* 
	if ReadVar() == "M->ZV2_LOTE" .and. cLotAnt != &(ReadVar())
		If (TCSqlExec("DELETE FROM SX5010 WHERE X5_TABELA='Z8' AND RTRIM(X5_DESCRI) = '" +;
			AllTrim(cLotAnt) + "'" ) < 0)
			MsgInfo("Erro ao liberar lote anterior: " + AllTrim(cLotAnt) + CRLF + TCSQLError() )
			ConOut("Erro ao liberar lote: " + AllTrim(cLotAnt) + CRLF + TCSQLError())
		EndIf
	endif  */

	cSql := "update " + retSqlName("ZV2") + " set D_E_L_E_T_='*', R_E_C_D_E_L_=R_E_C_N_O_ where ZV2_FILIAL='" + FWxFilial("ZV2") + " ' and ZV2_MOVTO = '" +  Z0C->Z0C_CODIGO + "'"
	nStatus := TCSqlExec(cSql)
	If (nStatus < 0)
		conout("TCSQLError() " + TCSQLError())
	EndIf
	
	for nI := 1 to len(oGetDadRan:aCols)
		If !oGetDadRan:aCols[ nI, nUsadRan+1]
			RecLock("ZV2", .T.)
			ZV2->ZV2_FILIAL := FWxFilial("ZV2")
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
	Local cQry		:= ""
	Local oQryC5    := ""
	
	cQry := " select count(Z0F_PROD) Z0F_QUANT " + CRLF
	cQry += " from "+RetSQLName("Z0F")+" Z0F " + CRLF
	cQry += " where Z0F_FILIAL = '"+FwxFilial("Z0F")+"' " + CRLF
	cQry += " and Z0F_MOVTO  = '"+Z0C->Z0C_CODIGO+"' " + CRLF
	cQry += " and (Z0F_PROD  =  ? " + CRLF  // %exp:cVarPrd%
	cQry += " or Z0F_PRDORI  =  ? ) " + CRLF//%exp:cVarPrd%)
	cQry += " and Z0F_LOTORI =  ? " + CRLF  //exp:cVarLot%
	cQry += " and Z0F.D_E_L_E_T_ = '' " + CRLF

	oQryC5 := FwExecStatement():New(cQry)

	for nI := 1 to len(oGetDadOri:aCols)
		If !oGetDadOri:aCols[ nI, nUsadOri+1]
			nQtdPrd := 0
			
			oQryC5:SetString(1, oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_PROD"})] )
			oQryC5:SetString(2, oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_PROD"})] )
			oQryC5:SetString(3, oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_LOTE"})])

			nQtdPrd := oQryC5:ExecScalar("Z0F_QUANT")

			aAdd(aSaldos, {oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_LOTE"})],;
				oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_PROD"})],;
				oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_QUANT"})],;
				nQtdPrd,;
				oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_RACA"})],;
				oGetDadOri:aCols[ nI, aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_SEXO"})]})
		EndIf
	Next nI 

	oQryC5:Destroy()
	oQryC5 := Nil

	nAjuste := 0
	for nI := 1 to len(aSaldos)
		If aSaldos[nI, 4] > aSaldos[nI, 3]
			nAjuste := aSaldos[nI, 4] - aSaldos[nI, 3]
			aSaldos[nI, 4] := aSaldos[nI, 3]
		EndIf
		while nAjuste > 0 .and. nI < len(aSaldos)
			for nJ := nI+1 to len(aSaldos)
				If aSaldos[nI, 2] == aSaldos[nJ, 2]
					aSaldos[nJ, 4] := nAjuste
					If aSaldos[nJ, 4] > aSaldos[nJ, 3]
						nAjuste := aSaldos[nJ, 4] - aSaldos[nJ, 3]
					else
						nAjuste := 0
					EndIf
				EndIf
			Next nJ
		EndDo
	Next nI

Return aSaldos


Static Function DefOrigem()
	local aOrigem := {}
	local aSaldos := GetSldOrigem()
	Local nI		:= 0

	if empty(cLoteOri) 
		MsgInfo("Selecione um lote de origem!")
		return {}
	endif

	If !empty(cLoteOri)
		nPosS := aScan(aSaldos, { |x| x[1]==cLoteOri  .and. AllTrim(x[5])==IIF(nRadRaca == 1,"NELORE",oRadRaca:aItems[nRadRaca]) /*.and. x[6]==cSexoOri  *//* .and. x[7]==cDentOri */ .and. x[3]>x[4]})
		If nPosS > 0
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

							oSayFOri:SetText("")

						EndIf

					else

						msgInfo("O BOV [" + aSaldos[nPosS, 2] + " ] do Lote de Origem [" + aSaldos[nPosS, 1] + " ] foi totalmente contado. Selecione um novo lote de origem.")

						cLoteOri := ""
						cCurrOri := ""
						cRacaOri := ""
						cSexoOri := ""
						oSayFOri:SetText("")

					EndIf
				EndIf

			EndIf
		EndIf
	EndIf

	If empty(aOrigem)
		for nI := 1 to len(aSaldos)
			If aSaldos[nI,1] == cLoteOri .and. aSaldos[nI,3] > aSaldos[nI,4]
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
	Local cAlias   := ""
	Local cQry 	   := ""

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
		msgInfo("A quantidade informada nos lotes origem já foi registrada. VerIfique se a quantidade de origem está correta.")
		Return nil
	EndIf

	If empty(cLoteForce)

		If !GetMV("VA_USARANG",,.F.)

			msgAlert("Nenhum lote de destino selecionado. Utilize a grade de parametros para definir o lote de destino.")
			Return

		else

			nQtd := 0
			for nI := 1 to len(oGetDadRan:aCols)
				for nJ := 1 to nUsadRan
					If !oGetDadRan:aCols[ nI, nUsadRan+1]
						If empty(oGetDadRan:aCols[ nI, nJ])
							msgAlert("O item [" + aHeadRan[nJ,1] + " ] na linha " + cValToChar(nI) + "  nos parametros está vazio. Preencha todos os campos dos parametros para continuar")
							Return nil
						EndIf
						If nPeso >= oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) = "ZV2_PESINI"})] .and. nPeso <= oGetDadRan:aCols[ nI, aScan( aHeadRan, { |x| AllTrim(x[2]) = "ZV2_PESFIM"})]
							nQtd++
						EndIf
					EndIf
				Next
			Next
			If nQtd = 0
				msgAlert("Nao foi encontrado nenhum parametro para o peso informado. Preencha os parametros antes de continuar.")
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
		cSeq := soma1(aColsDet[1, nPSeq])
	EndIf

	aLOrigem := DefOrigem()
	if Len(aLOrigem) > 0
		aColsDet[len(aColsDet), nPMovto] := Z0C->Z0C_CODIGO
		aColsDet[len(aColsDet), nPSeq]   := cSeq
		aColsDet[len(aColsDet), nPProd]  := aLOrigem[aScan( aHeadOri, { |x| AllTrim(x[2]) == "Z0D_PROD"})]

		cQry := "select ZBC_CODIGO, ZBC_PEDIDO, A2_NOME " + CRLF 
		cQry += "	  from "+RetSQLName("ZBC")+" ZBC " + CRLF 
		cQry += "	  left join "+RetSQLName("SA2")+" SA2 on (SA2.A2_FILIAL='"+FwxFilial("SA2")+"' and A2_COD=ZBC_CODFOR and A2_LOJA=ZBC_LOJFOR and SA2.D_E_L_E_T_ = '') " + CRLF 
		cQry += "	 where ZBC.ZBC_FILIAL='"+FwxFilial("ZBC")+"' " + CRLF 
		cQry += "	   and ZBC_PRODUT='"+aColsDet[len(aColsDet), nPProd]+"'" + CRLF 
		cQry += "	   and ZBC_VERSAO=( " + CRLF 
		cQry += "	   		select max(ZBC_VERSAO) " + CRLF 
		cQry += "	   		  from "+RetSQLName("ZBC")+" Z2 " + CRLF 
		cQry += "	   		 where Z2.ZBC_FILIAL=ZBC.ZBC_FILIAL " + CRLF 
		cQry += "	   		   and Z2.ZBC_CODIGO=ZBC.ZBC_CODIGO " + CRLF 
		cQry += "			   and Z2.D_E_L_E_T_ = '' " + CRLF 
		cQry += "	   ) " + CRLF 
		cQry += "	   and ZBC.D_E_L_E_T_ = '' " + CRLF 
		
		cAlias := GetNextAlias()
		MpSysOpenQuery(cQry,cAlias)

		If !(cALias)->(Eof())
			aColsDet[len(aColsDet), nPContr] := (cALias)->ZBC_CODIGO
			aColsDet[len(aColsDet), nPPedid] := (cALias)->ZBC_PEDIDO
			aColsDet[len(aColsDet), nPForne] := (cALias)->A2_NOME
		EndIf
		(cALias)->(dbCloseArea())

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
			msgAlert("Peso não se encaixa nos parametros especIficados. Informe uma parametrização de pesos válida que permita a escolha do lote e curral adequado.")
			Return nil
		EndIf

		aColsDet[len(aColsDet), nPLote] 	:= cLote
		aColsDet[len(aColsDet), nPCurral] 	:= cCurral
		aColsDet[len(aColsDet), nPPeso] 	:= nPeso
		aColsDet[len(aColsDet), nPPeBal] 	:= nPesBal
		aColsDet[len(aColsDet), nUsadDet+1] := .F.

		RecLock("Z0F", .T.)
		Z0F->Z0F_FILIAL := FWxFilial("Z0F")
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
		Z0F->Z0F_HRPES  := aColsDet[len(aColsDet), nPHora]
		Z0F->Z0F_RACA   := AllTrim(aColsDet[len(aColsDet), nPRaca])
		Z0F->Z0F_SEXO   := AllTrim(aColsDet[len(aColsDet), nPSexo])
		Z0F->Z0F_DENTIC := AllTrim(aColsDet[len(aColsDet), nPDent])
		Z0F->Z0F_TAG    := AllTrim(aColsDet[len(aColsDet), nPTag])
		Z0F->Z0F_LOTORI := aColsDet[len(aColsDet), nPLOri]
		MsUnlock()

		aColsDet[len(aColsDet), aScan( aHeadDet, { |x| AllTrim(x[2]) == "NRECNO"})] := Z0F->(RECNO())

		nPRecno := aScan( aHeadDet, {|a1| a1[2]=="NRECNO"})
		aSort(aColsDet,,,{ |x, y| x[nPRecno] > y[nPRecno] })

		oGetDadDet:setArray(aColsDet)
		oGetDadDet:oBrowse:Refresh()
		oDlgPsg:CtrlRefresh()
		ObjectMethod(oDlgPsg,"Refresh()")

		U_calcular_destino()

		nPeso := 0
	endif
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

			&("Z0F->" + SubStr(ReadVar(),4) + "  := " + ReadVar() + " ")
			&("oGetDadDet:aCols[oGetDadDet:oBrowse:nAt, aScan( aHeadDet, { |x| AllTrim(x[2])=='" + SubStr(ReadVar(),4) + "'})] := " + ReadVar() + " ")

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
	Local cAlias 	  := ""
	Local cQry 		  := ""
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
	nPPrdOri          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_PRDORI"})
	nPLotOri          := aScan( aHeadDes, { |x| AllTrim(x[2]) == "Z0E_LOTORI"})

	If len(oGetDadDet:aCols) = 1
		If empty(oGetDadDet:aCols[1, nPProd])
			Return
		EndIf
	EndIf

	cQry := "select * " + CRLF 
	cQry += "  from "+RetSQLName("Z0F")+" Z0F " + CRLF 
	cQry += " where Z0F_FILIAL='"+FwxFilial("Z0F")+"' " + CRLF 
	cQry += "   and Z0F_MOVTO='"+Z0C->Z0C_CODIGO+"'" + CRLF 
	cQry += "   and Z0F.D_E_L_E_T_ = '' " + CRLF 
	cQry += "order by Z0F_MOVTO, Z0F_PROD, Z0F_RACA, Z0F_SEXO, Z0F_DENTIC, Z0F_LOTE, Z0F_LOTORI, Z0F_CURRAL, Z0F_SEQEFE DESC, Z0F_SEQ " + CRLF 

	nQtdDes := 0
	lCria := .T.
	nPosLinha := 1
	cSeq := "0001"
	aColsDes := {}
	aColsVw := {}
	cHrAtu := ""

	cAlias 	  := GetNextAlias()
	MpSysOpenQuery(cQry,cAlias)
	// calcular_destino()
	If !(cALias)->(Eof())
		while !(cALias)->(Eof())

			nQtdDes++
			// calcular_destino
			If nQtdDes > 1
				nPosLinha := aScan(aColsDes, { |x| AllTrim(x[nPosLote])   == AllTrim((cALias)->Z0F_LOTE  );
					.and. AllTrim(x[nPosRaca])   == AllTrim((cALias)->Z0F_RACA  );
					.and. AllTrim(x[nPosSexo])   == AllTrim((cALias)->Z0F_SEXO  );
					.and. AllTrim(x[nPosCurral]) == AllTrim((cALias)->Z0F_CURRAL);
					.and. AllTrim(x[nPosProd])   == AllTrim((cALias)->Z0F_PROD  );
					.and. AllTrim(x[nPLotOri])   == AllTrim((cALias)->Z0F_LOTORI);
					.and. AllTrim(x[nPosSeqE])   == AllTrim((cALias)->Z0F_SEQEFE) })
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
				aColsDes[len(aColsDes), nPosProd] := (cALias)->Z0F_PROD

				dbSelectArea("SB1")
				dbSetOrder(1)
				SB1->( dbSeek(FWxFilial("SB1")+(cALias)->Z0F_PROD) )

				aColsDes[len(aColsDes), nPosDesc]   := SB1->B1_DESC
				aColsDes[len(aColsDes), nPosLote]   := (cALias)->Z0F_LOTE
				aColsDes[len(aColsDes), nPosCurral] := (cALias)->Z0F_CURRAL
				aColsDes[len(aColsDes), nPosQuant]  := 1
				aColsDes[len(aColsDes), nPosDtCo]   := SToD((cALias)->Z0F_DTPES)+1
				aColsDes[len(aColsDes), nPosSeqE]   := (cALias)->Z0F_SEQEFE
				aColsDes[len(aColsDes), nPosRaca]   := (cALias)->Z0F_RACA
				aColsDes[len(aColsDes), nPosSexo]   := (cALias)->Z0F_SEXO
				aColsDes[len(aColsDes), nPPrdOri]   := (cALias)->Z0F_PRDORI
				aColsDes[len(aColsDes), nPLotOri]   := (cALias)->Z0F_LOTORI
			else
				aColsDes[nPosLinha, nPosQuant]      += 1
			EndIf

			cHrIni   := Z0C->Z0C_HRINI // FwFldGet("Z0C_HRINI")
			cHrAtu   := iIf(empty((cALias)->Z0F_HRPES), Time(), (cALias)->Z0F_HRPES)
			cTempo   := ElapTime ( cHrIni, cHrAtu )
			nMinutos := val(substr(cTempo,1,2))*60 + val(substr(cTempo,4,2)) + val(substr(cTempo,7,2))/60

			nMedia   := nMinutos/nQtdDes
			nHora    := int(nMedia/60)
			nMinuto  := int(nMedia - (nHora*60))
			nSegundo := int((nMedia - (nHora*60) - nMinuto)*60)
			cMedia   := StrZero(nHora, 2) + ":" + StrZero( nMinuto, 2) + ":" + StrZero(nSegundo, 2)

			(cALias)->(dbSkip())
		EndDo
	EndIf
	(cALias)->(dbCloseArea())

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
		oGetDadVL:aCols[nJ, nPosVW_QTDPES] := GetQtdPesadosLote(oGetDadVL:aCols[nJ, nPosVW_LOTE])//,;
			//oGetDadVL:aCols[nJ, nPosVW_RACA],;
			//oGetDadVL:aCols[nJ, nPosVW_SEXO],;
			///* oGetDadVL:aCols[nJ, aScan( aHeadVL, { |x| AllTrim(x[2]) == "VW_DENTIC"})] */ )
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
	oDlgPsg:CtrlRefresh()
	ObjectMethod(oDlgPsg,"Refresh()")
Return .T.


// ----------------------------------------------------------------------------------------------------
User Function getUA(cCurral)
	dbSelectArea("Z08")
	dbSetOrder(1)
	dbSeek(FWxFilial("Z08")+cCurral)
Return iIf(!empty(Z08->Z08_UAREF),Z08->Z08_UAREF, 1)


// ----------------------------------------------------------------------------------------------------
Static Function getSaldoLote(cLote, cProduto)
	local nRet    := 0
	Local cFiltro := ""
	Local cQry    := ""

	default cProduto := ""

	If !empty(cProduto)
		cFiltro += " and B8_PRODUTO='" + AllTrim(cProduto)+ "'"
	EndIf

	cQry := "select sum(B8_SALDO) SALDO " + CRLF 
	cQry += "  from "+RetSQLName("SB8")+" B8 " + CRLF 
	cQry += " where B8_FILIAL='"+FwxFilial("SB8")+"' " + CRLF 
	cQry += "   and B8_LOTECTL = '"+cLote+"' " + CRLF 
	cQry += "   and B8.D_E_L_E_T_ = '' " + CRLF 
	if cFiltro != ''
		cQry += cFiltro + CRLF 
	endif
	cQry += "   and B8_SALDO > 0 " + CRLF 

	nRet := MPSysExecScalar(cQry,"SALDO")

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
	_cQry += " FROM  "+RetSQLName("Z0F")+" Z0F " + CRLF
	If !empty(cDesc)
		_cQry += "  JOIN "+RetSQLName("SB1")+" SB1 ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B1_COD=Z0F_PROD " + CRLF
		_cQry += "			       AND SB1.D_E_L_E_T_=' '" + CRLF
	EndIf
	_cQry += " WHERE Z0F_FILIAL= '"+FWxFilial('Z0F')+"'  " + CRLF
	If !empty(cProduto)
		_cQry += "   AND Z0F_PROD='"+AllTrim(cProduto)+"'   " + CRLF
	EndIf
	If !empty(cDesc)
		_cQry += "   AND RTRIM(B1_DESC)='"+AllTrim(cDesc)+"'" + CRLF
	EndIf
	_cQry += "   AND Z0F_LOTE =  '"+cLote+"'" + CRLF
	_cQry += "   AND Z0F.D_E_L_E_T_=' '" + CRLF

	nRet := MPSysExecScalar(_cQry,"MEDIA")

Return nRet



// ==================================================================================================== \\
Static Function getSaldoZ0F(cLote, cProduto, lAtu, cDesc)
	local nRet       := 0
	Local _cQry      := ""

	default cProduto := ""
	default lAtu     := .F.
	default cDesc	 := ""

	_cQry += " SELECT COUNT(Z0F.R_E_C_N_O_) SALDO " + CRLF
	_cQry += " FROM  "+RetSQLName("Z0F")+" Z0F " + CRLF
	If !empty(cDesc)
		_cQry += "  JOIN "+RetSQLName("SB1")+" SB1 ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B1_COD=Z0F_PROD " + CRLF
		_cQry += "			       AND SB1.D_E_L_E_T_=' '" + CRLF
	EndIf
	_cQry += " WHERE Z0F_FILIAL= '"+FWxFilial('Z0F')+"'  " + CRLF
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

	nRet := MPSysExecScalar(_cQry,"SALDO")

Return nRet

User Function SalvarGeral( oModel, oView )
	Local nI       := 0
	Local nJ       := 0
	Private oGridZ0E := nil

	If oModel:nOperation <> 4
		Alert("Esta operação não pode ser realizada neste modo de edição.")
		Return .F.
	EndIf

	If Z0C->Z0C_STATUS /*FWFldGet\("Z0C_STATUS"\)*/ <> '1' .and. Z0C->Z0C_STATUS /*FWFldGet\("Z0C_STATUS"\)*/ <> '4'
		alert('Só é Possível alterar Movimentações em aberto.')
		Return .F.
	EndIf

	//IdentIfica os produtos de destino e salva a quantidade necessária
	oGridZ0E := oModel:GetModel( 'Z0EDETAIL' )
	//oModel:CommitData()
	
	for nI := 1 to oGridZ0E:Length()
		oGridZ0E:GoLine(nI)
		oGridZ0E:DeleteLine()
	endFor
	oGridZ0E:DelAllLine()

	oModel:LoadValue("CALC_TOT", "Z0E__TOT02", 0)

	for nI := 1 to len(oGetDadDes:aCols)
		oGridZ0E:AddLine()

		for nJ := 1 to len(aHeadDes)
			If ValType(oGetDadDes:aCols[ nI, nJ]) == "C"
				oGridZ0E:LoadValue(aHeadDes[nJ,2], left(oGetDadDes:aCols[ nI, nJ], TamSX3(aHeadDes[nJ,2])[1]))
			else
				oGridZ0E:LoadValue(aHeadDes[nJ,2], oGetDadDes:aCols[ nI, nJ])
			EndIf
		Next

	endFor

	oModel:LoadValue("CALC_TOT", "Z0E__TOT02", nQtdDes)

	oModel:CommitData()
	oView:Refresh()
	oDlgPsg:End()
	ConOut('Fim: SalvarGeral')

Return .T.
User Function MA01BAL()
 	Local nPesoRet := 0

    Local nH        := 0
    Local nPos      := 0
    Local cBuffer   := ""
    Local nCont  	:= 0

    Local cBPorta  := GetMV("MB_CU_TPOR",, "COM3") //Porta
    Local cBVeloc  := GetMV("MB_CU_TVEL",, "115200") //Velocidade
    Local cBParid  := GetMV("MB_CU_TPAR",, "S") //Paridade
    Local cBBits   := GetMV("MB_CU_TBIT",, "7") //Bits
    Local cBStop   := GetMV("MB_CU_TSTO",, "1") //Stop Bit

    Local cCfg     := cBPorta+":"+cBVeloc+","+cBParid+","+cBBits+","+cBStop

    //Guarda resultado se houve abertura da porta
    Local lRet     := msOpenPort(@nH,cCfg)

    //Se não conseguir abrir a porta, mostra mensagem e finaliza
    If(!lRet)
        //Se for barra, tentar na confiança, depois na jundiai
        MsgStop("<b>Falha</b> ao conectar com a porta serial. Detalhes:"+;
            "<br><b>Porta:</b> "        +cBPorta+;
            "<br><b>Velocidade:</b> "    +cBVeloc+;
            "<br><b>Paridade:</b> "        +cBParid+;
            "<br><b>Bits:</b> "            +cBBits+;
            "<br><b>Stop Bits:</b> "    +cBStop,"Atenção")
        cLido := 0

    Else
        msWrite(nH,Chr(5))
        Sleep(1000)

        //Lendo os dados
        While (Empty(cBuffer) .AND. nCont < 50)
            msRead(nH,@cBuffer)
            nCont++
        EndDo
        msClosePort(nH,cCfg)

        memoWrite( "C:\temp\pesagem_" + StrTran( Time(), ":", "" ) + ".txt", cBuffer )

        if !Empty(cBuffer) .and. (nPos:=At( "kg", cBuffer )) > 0

            // Alert("Peso Lido: "+cValToChar(cBuffer))
            cBuffer := SubStr( cBuffer, 1, nPos-1 )
            // Alert("Peso Lido Cortado: "+cValToChar(cBuffer))
            nPesoRet := Val( cBuffer )
            //Alert("Peso Lido Convertido: "+cValToChar(nPesoRet))
        EndIf

    EndIf
Return nPesoRet

/*	MB : 12.05.2020
	# Funcç£¯ para validar a repetiç£¯ dos dados, definindo a permisã¯ da continuidade da função;
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

							cChvZ0D := oGridZ0D:GetValue('Z0D_RACA',nIZ0D) + oGridZ0D:GetValue('Z0D_SEXO',nIZ0D) /* + cValToChar(oGridZ0D:GetValue('Z0D_DENTIC',nIZ0D)) */
							cChvZ0E := oGridZ0E:GetValue('Z0E_RACA',nIZ0E) + oGridZ0E:GetValue('Z0E_SEXO',nIZ0E) /* + cValToChar(oGridZ0E:GetValue('Z0E_DENTIC',nIZ0E)) */
							If cChvZ0D <> cChvZ0E

								SB1->(DbSetOrder(1))
								SB1->(DbSeek( FWxFilial('SB1') + oGridZ0E:GetValue('Z0E_PROD', nIZ0E) ))

								If !(lErro := U_SB1Create( { FWxFilial("SB1"),;										// [01] Filial
									AllTrim(SB1->B1_GRUPO)/*"BOV"*/,;			    // [02] Grupo
									nil/*oGridZ0E:GetValue('Z0E_PROD',nIZ0E)*/,;    // [03] Produto Base/Copia
									nil/*oGridZ0E:GetValue('Z0E_DESC',nIZ0E)*/,;    // [04] Produto Base/Copia Descriç£¯
									oGridZ0E:GetValue('Z0E_RACA'  , nIZ0E),;   		// [05] Raç¡
									oGridZ0E:GetValue('Z0E_SEXO'  , nIZ0E)},;	    // [06] Sexo
									.T. )) 		// lCriaSaldoSB9 - Saldo Inicial

									oGridZ0E:SetValue('Z0E_PROD', SubS(SB1->B1_COD, 1, TamSX3('Z0E_PROD')[1]) )
								EndIf
							EndIf
						EndIf
					EndIf
				Next nIZ0E
			EndIf
		Next nIZ0D
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
	Local cQry 			  := ""
	Local cRetQry  		  := ""

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

	aAdd( aProd, {"B1_DESC"		, Alltrim(Iif(Empty(__aProd[4]),SB1->B1_DESC,__aProd[4])), nil })
	aAdd( aProd, {"B1_TIPO"		, "PA"						, nil })
	aAdd( aProd, {"B1_UM"		, "UN"						, nil })
	aAdd( aProd, {"B1_LOCPAD"	, "01"						, nil })
	aAdd( aProd, {"B1_CONTA"	, "1140200001"      		, nil })
	aAdd( aProd, {"B1_ORIGEM"	, "0"						, nil })
	aAdd( aProd, {"B1_X_TRATO"	, "2"						, nil })
	aAdd( aProd, {"B1_X_PRDES"	, "E"						, nil })
	aAdd( aProd, {"B1_PICM"		, 0							, nil })
	aAdd( aProd, {"B1_IPI"		, 0							, nil })
	aAdd( aProd, {"B1_CONTRAT"	, "N"						, nil })
	aAdd( aProd, {"B1_LOCALIZ"	, "N"						, nil })
	aAdd( aProd, {"B1_GRTRIB"	, "001"						, nil })
	aAdd( aProd, {"B1_CODBAR"	, "SEM GTIN"        		, nil }) // SEM GTIN => layout 4.0
	aAdd( aProd, {"B1_TIPCAR"	, "005"						, nil })
	aAdd( aProd, {"B1_TPREG"	, "2"						, nil })
	aAdd( aProd, {"B1_CONTSOC"	, 'N'						, nil })
	aAdd( aProd, {"B1_MSBLQL"	, "2"						, nil })
	aAdd( aProd, {"B1_X_TRATO"	, "2"						, nil })
	aAdd( aProd, {"B1_MCUSTD"	, "1"						, nil })
	aAdd( aProd, {"B1_TE"		, GetMV("JR_M11TESC",,"005"), nil })
	aAdd( aProd, {"B1_POSIPI"	, GetMV("JR_POSIPI",,"01022919"), nil })

	// -------------------------------------------------------------------------------------
	//Encontra o B1_XANIMAL
	xAnimal := SB1->B1_XANIMAL
	//A=Angus;C=Cruzamento;M=Mestico;N=Nelore

	cQry := "select Z09_CODIGO " + CRLF 
	cQry += "	  from "+RetSQLName("Z09")+" Z09 " + CRLF 
	cQry += "	 where Z09_FILIAL='"+FwxFilial("Z09")+"' " + CRLF 
	cQry += "	   and Z09_RACA='"+__aProd[5]+"'" + CRLF 
	cQry += "	   and Z09_SEXO='"+__aProd[6]+"'" + CRLF 
	cQry += "	   and '"+SB1->B1_XIDADE+"' between Z09_IDAINI and Z09_IDAFIM " + CRLF 
	cQry += "	   and Z09.D_E_L_E_T_ = '' " + CRLF

	cRetQry := MPSysExecScalar(cQry,"Z09_CODIGO")

	if AllTrim(cRetQry) != ""
		xAnimal := cRetQry
	EndIf

	aAdd( aProd, {"B1_XANIMAL", xAnimal		   , nil })
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
	aAdd( aProd, {"B1_XRACA"  , __aProd[5]     , nil })
	aAdd( aProd, {"B1_X_SEXO" , __aProd[6]     , nil })

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
Local nPosZ0D       := 0

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

		Alert("ATENÇÃO" + CRLF + "Sexos invertidos não sao permitidos" )
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
		
		Alert("ATENÇÃO" + CRLF + "Sexos invertidos não sao permitidos" )
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
	Local oGridZ0E    := oModel:GetModel( 'Z0EDETAIL' )
	Local nQtdDes     := 0
	Local nPosLinha   := 0
	Local lCria       := .T.
	Local aStruZ0F    := {}
	Local aStruZ0E    := Z0E->(dbStruct())	// aHeadDes := GeraHeader("Z0E", .T.)
	Local nUsadZ0E    := len(aStruZ0E)
	Local aColsZ0E    := {}
	Local cSeqDes     := "0000"
	Local nI          := 0, nJ := 0
	Local nPesPrd1    := 0, nQtdPrd := 0, nPesLot1 := 0, nQtdLot := 0
	Local cAlias 	  := GetNextAlias()
	Local cQry		  := ""

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
	nPPrdOri          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_PRDORI"})
	nPLotOri          := aScan( aStruZ0E, { |x| AllTrim(x[1]) == "Z0E_LOTORI"})
	
	cQry := " select * " + CRLF 
	cQry += "  from "+RetSQLName("Z0F")+" Z0F" + CRLF 
	cQry += " where Z0F_FILIAL= "+xFilial('Z0F')+" " + CRLF 
	cQry += "   and Z0F_MOVTO= '"+Z0C->Z0C_CODIGO+"' " + CRLF 
	cQry += "   and Z0F.D_E_L_E_T_='' " + CRLF 
	cQry += "order by Z0F_MOVTO, Z0F_PROD, Z0F_RACA, Z0F_SEXO, Z0F_DENTIC, Z0F_LOTE, Z0F_LOTORI, Z0F_CURRAL, Z0F_SEQEFE DESC, Z0F_SEQ " + CRLF 

	MpSysOpenQuery(cQry,cAlias)
	
	// fReLoadZ0E
	If !(cAlias)->(Eof())
		aStruZ0F  := (cAlias)->(dbStruct())
		(cAlias)->(DbGoTop())
		while !(cAlias)->(Eof())
			dbSelectArea("SB1")
			dbSetOrder(1)
			If SB1->( dbSeek(FWxFilial("SB1")+(cAlias)->Z0F_PROD) )
				nQtdDes++
				ConOut(StrZero(nQtdDes, 4) + ': fReLoadZ0E: ' + (cAlias)->Z0F_PROD)
				// fReLoadZ0E
				If nQtdDes > 1
					nPosLinha := aScan(aColsZ0E, { |x| AllTrim(x[nPosLote])   == AllTrim((cAlias)->Z0F_LOTE  );
						.and. AllTrim(x[nPosRaca])   == AllTrim((cAlias)->Z0F_RACA  );
						.and. AllTrim(x[nPosSexo])   == AllTrim((cAlias)->Z0F_SEXO  );
						.and. AllTrim(x[nPosCurral]) == AllTrim((cAlias)->Z0F_CURRAL);
						.and. AllTrim(x[nPosProd])   == AllTrim((cAlias)->Z0F_PROD  );
						.and. AllTrim(x[nPLotOri])   == AllTrim((cAlias)->Z0F_LOTORI);
						.and. AllTrim(x[nPosSeqE])   == AllTrim((cAlias)->Z0F_SEQEFE) })
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
							aColsZ0E[len(aColsZ0E), nPosZ0E]    := (cAlias)->&(aStruZ0F[ nI, 1])
						EndIf
					Next nI

					aColsZ0E[len(aColsZ0E), nPosSeq]    := cSeqDes
					aColsZ0E[len(aColsZ0E), nPosDesc]   := SB1->B1_DESC
					aColsZ0E[len(aColsZ0E), nPosQuant]  := 1
					aColsZ0E[len(aColsZ0E), nPosDtCo]   := SToD((cAlias)->Z0F_DTPES)+1
					aColsZ0E[len(aColsZ0E), nPosSeqE]   := (cAlias)->Z0F_SEQEFE
				else
					aColsZ0E[nPosLinha, nPosQuant]      += 1
				EndIf
			EndIf
			(cAlias)->(dbSkip())
		EndDo

		for nI := 1 to oGridZ0E:Length()
			oGridZ0E:GoLine(nI)
			oGridZ0E:DeleteLine()
		endFor
		oGridZ0E:DelAllLine()

		oModel:LoadValue("CALC_TOT", "Z0E__TOT02", 0)

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

		nLinProc := oGridZ0E:Length() + 1 // VARIAVEL USADA NA EFETIVAÇÃO DA APARTAÇÃO

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

		oView:Refresh()
	EndIf
	(cAlias)->(DbCloseArea())

	RestArea(aArea)
Return nil // oGridZ0E
// Fim fReLoadZ0E
User Function mbEXISTCPO( __Alias, __cChave )
	Local aArea     := GetArea()
	Local cQry 		:= ""
	Local lRet      := .T.
	
	cQry := " SELECT  R_E_C_N_O_ RECNO " + CRLF 
	cQry += "	FROM     "+RetSQLName("SC7")+" " + CRLF 
	cQry += "	WHERE	C7_FILIAL+C7_NUM='"+__cChave+"'" + CRLF 
	cQry += "		AND D_E_L_E_T_ = '' " + CRLF 

	lRet := MPSysExecScalar(cQry,"RECNO") > 0 

	RestArea(aArea)
Return lRet
