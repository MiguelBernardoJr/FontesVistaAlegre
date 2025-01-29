#INCLUDE 'Protheus.ch'
#INCLUDE 'TopConn.ch'
#INCLUDE "TRYEXCEPTION.CH"

User Function ProcNFMS()

	Local oDlg     := Nil
	Local oPanel1  := Nil
	Local oPathArq := Nil
	Local oNumNF   := Nil
	Local oBtn1    := Nil
	Local oCli     := Nil
	Local aArea    := GetArea()
	Local nOpcDlg  := 0
	Local nLin     := 6
	Local cPathArq := ""
	Local cNumNF   := CriaVar("F2_DOC", .F.)
	Local cCliente := ""
	Local cSerieNF := ""
	Local cChaveNF := ""

	If !Empty(SC5->C5_NOTA)
		Aviso("Nota Fiscal SEFAZ MS", "Pedido já faturado.", {"Ok"})
		Return()
	EndIf

	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Nota Fiscal SEFAZ MS") From 0,0 TO 600,1200 Of oMainWnd PIXEL
                                    
		@ 000, 000 MSPANEL oPanel1 SIZE 100, 60 OF oDlg 
    	oPanel1:Align := CONTROL_ALIGN_TOP

		@ 100, 000 MSPANEL oPanel2 SIZE 250, 250 OF oDlg 
		oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

		@ nLin + 2, 005 SAY OemtoAnsi("Arquivo") OF oPanel1 PIXEL COLOR CLR_BLUE
		@ nLin    , 040 MSGET oPathArq VAR cPathArq PICTURE "@!" WHEN .F. SIZE 300,04  OF oPanel1 PIXEL COLOR CLR_BLUE
		@ nLin    , 330 BUTTON oBtn1 PROMPT "..." SIZE 10,10 ACTION { || Iif(RetPath(@cPathArq), ProcXML(cPathArq, @cCliente, @cNumNF, @cSerieNF, @cChaveNF, @oGD), .T.) } OF oPanel1 PIXEL

		nLin += 20

		oSayNFE := tSay():New(nLin + 2, 005, {||"Número NF-E"}, oPanel1,,,,,, .T.,   CLR_BLUE,, 130, 100)
		@ nLin    , 040 MSGET oNumNF VAR cNumNF PICTURE "@!"  WHEN .F.  OF oPanel1 PIXEL COLOR CLR_BLUE

		nLin += 20

		oSayCli := tSay():New(nLin + 2, 005, {||"Cliente"}, oPanel1,,,,,, .T.,   CLR_BLUE,, 130, 100)
		@ nLin    , 040 MSGET oCli VAR cCliente PICTURE "@!"  WHEN .F.  SIZE 300,04 OF oPanel1 PIXEL COLOR CLR_BLUE

		nLin += 20

		oGd := MyGrid():New(nLin, 000, 1100, 1100, 0/*GD_UPDATE*/,,,,,, 99999,,,, oPanel2)
		//    AddColSX3(cFieldSX3  , cTitulo         , cCampo    , cPicture, nTamanho         , nDecimal, cValid   , cF3     , cCBox, cRelacao, cWhen, cVisual, cVldUser)//Adiciona Coluna no aHeader conforme dicionario
		oGd:AddColSX3("C6_ITEM"   , "Item Pedido"   , "ITEM"     ,         , Len(SC6->C6_ITEM),         , ""       , "JR_SC6",      ,         ,      , "A"    , "u_JRVldCpos(@oGd)")
		oGd:AddColSX3("C6_PRODUTO", "Produto Pedido", "PRODPED"  ,         ,                  ,         , ""       ,         ,      ,         ,      , "V"    ,                    ) 
		oGd:AddColSX3("B1_DESC"   , "Descrição"     , "DESCPROD1",         ,                  ,         , ""       ,         ,      ,         ,      , "V"    ,                    ) 
		oGd:AddColSX3("C6_QTDVEN" , "Qtde Pedido"   , "QTDVEN"   ,         ,                  ,         , ""       ,         ,      ,         ,      , "V"    ,                    )
		oGd:AddColSX3("C6_LOTECTL", "Lote Pedido"   , "LOTECTL"  ,         ,                  ,         , ""       ,         ,      ,         ,      , "V"    ,                    )
		oGd:AddColSX3("C6_PRODBMS", "Produto NF"    , "PRODNF"   ,         ,                  ,         , ""       ,         ,      ,         ,      , "V"    ,                    ) 
		oGd:AddColSX3("C6_TES"    , "TES Saida"     , "TES"      ,         ,                  ,         , ""       ,         ,      ,         ,      , "V"    ,                    ) 
		oGd:AddColSX3("B1_DESC"   , "Descrição"     , "DESCPROD2",         ,                  ,         , ""       ,         ,      ,         ,      , "V"    ,                    )
		oGd:Load()
		oGd:SetAlignAllClient()
	
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar (oDlg, {|| nOpcDlg := 1, IIF(VldOk(@oGd, cPathArq, cNumNF, cSerieNF, cChaveNF), oDlg:End(), nOpcDlg := 0)}, ;
	                                                         {|| nOpcDlg := 0, oDlg:End()})


	RestArea(aArea)

Return()

/******************************************/
/* Busca dados no XML da Nota Fiscal      */
/******************************************/

Static Function ProcXML(cPath, cCliente, cNumNFE, cSerieNF, cChaveNF, oGD)
	
	Local cAviso     := ""
	Local cErro      := ""
	Local oNfe       := Nil
	Local aDet       := {}
	Local nItem      := aScan(oGD:aHeader, {|aVet| AllTrim(aVet[2]) == "ITEM"})
	Local nProdPed   := aScan(oGD:aHeader, {|aVet| AllTrim(aVet[2]) == "PRODPED"})
	Local nDescProd1 := aScan(oGD:aHeader, {|aVet| AllTrim(aVet[2]) == "DESCPROD1"})
	Local nProdNF    := aScan(oGD:aHeader, {|aVet| AllTrim(aVet[2]) == "PRODNF"})
	Local nDescProd2 := aScan(oGD:aHeader, {|aVet| AllTrim(aVet[2]) == "DESCPROD2"})
	Local nQtdVen    := aScan(oGD:aHeader, {|aVet| AllTrim(aVet[2]) == "QTDVEN"})
	Local nQtdNF     := aScan(oGD:aHeader, {|aVet| AllTrim(aVet[2]) == "QTDNF"})
	Local nTES       := aScan(oGD:aHeader, {|aVet| AllTrim(aVet[2]) == "TES"})
	Local nLoteCtl   := aScan(oGD:aHeader, {|aVet| AllTrim(aVet[2]) == "LOTECTL"})
	Local aCItens    := {}
	Local aArea      := GetArea()
	Local aAreaSB1   := SB1->(GetArea())
	Local aAreaSA1   := SA1->(GetArea())
	Local cSql       := ""
	Local cCGC       := ""
	Local oNfe       := Nil

	oNfe := ImpArq(cPath, cAviso, cErro)

	If XmlChildEx(oNfe:_NFEPROC:_NFE:_INFNFE:_DEST, "_CNPJ") <> nil
		cCGC := AllTrim(GetXmlVal(oNfe, "oNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))
	Else 
		cCGC := AllTrim(GetXmlVal(oNfe, "oNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT"))
 	EndIf
	DbSelectArea("SA1")
	DbSetOrder(3)//A1_FILIAL + A1_CGC
	If !DbSeek(xFilial("SA1") + cCGC)
		Aviso("Validação XML", "O cliente do XML não foi encontrado no cadastro.", {"Ok"})
		Return()
	ElseIf SC5->C5_CLIENTE + SC5->C5_LOJACLI <> SA1->A1_COD + SA1->A1_LOJA
		Aviso("Validação XML", "O cliente do pedido difere do cliente do XML [CNPJ].", {"Ok"})
		Return()
	EndIf

	cNumNFE  := GetXmlVal(oNfe, "oNfe:_NFEPROC:_NFE:_INFNFE:_IDE:_nNF")
	cSerieNF := GetXmlVal(oNfe, "oNfe:_NFEPROC:_NFE:_INFNFE:_IDE:_serie")
	cChaveNF := GetXmlVal(oNfe, "oNfe:_NFEPROC:_PROTNFE:_INFPROT:_chNFe")
	cCliente := "CNPJ: " + cCGC + " - " + SA1->A1_NOME

	If ValType(aDet := GetXmlVal(oNfe, "oNfe:_NFEPROC:_NFE:_INFNFE:_DET", .T.)) <> "A"
		aDet := {aDet}
	EndIf

	//aCItens := aClone(oGd:ACOLS)
	aCItens := {}

	SB1->(DbSetorder(1))//B1_FILIAL+B1_COD

	cSql := "SELECT SC6.*, SB1A.B1_DESC B1_DESCPED, SB1B.B1_DESC B1_DESCNF "
	cSql += "FROM " + RetSqlName("SC6") + " SC6 "
	cSql += "JOIN " + RetSqlName("SB1") + " SB1A ON SB1A.D_E_L_E_T_ <> '*' AND SB1A.B1_FILIAL = '" + xFilial("SB1") + "' AND "
	cSql += "     SB1A.B1_COD = SC6.C6_PRODUTO "
	cSql += "JOIN " + RetSqlName("SB1") + " SB1B ON SB1B.D_E_L_E_T_ <> '*' AND SB1B.B1_FILIAL = '" + xFilial("SB1") + "' AND "
	cSql += "     SB1B.B1_COD = SC6.C6_PRODUTO "
	cSql += "WHERE SC6.D_E_L_E_T_ <> '*' AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' AND "
	cSql += "      SC6.C6_NUM = '" + SC5->C5_NUM + "'"
	cSql += "ORDER BY SC6.C6_FILIAL, SC6.C6_NUM, SC6.C6_ITEM, SC6.C6_PRODUTO "

	TcQuery cSql New Alias "TMPPED"

	While !(TMPPED->(Eof()))

		aAdd(aCItens, Array(Len(oGD:aHeader) + 1))

		aCItens[Len(aCItens), nItem]      := TMPPED->C6_ITEM
		aCItens[Len(aCItens), nProdPed]   := TMPPED->C6_PRODUTO
		aCItens[Len(aCItens), nDescProd1] := TMPPED->B1_DESCPED
		aCItens[Len(aCItens), nQtdVen]    := TMPPED->C6_QTDVEN
		aCItens[Len(aCItens), nLoteCtl]   := TMPPED->C6_LOTECTL
		aCItens[Len(aCItens), nProdNF]    := TMPPED->C6_PRODBMS
		aCItens[Len(aCItens), nTES]       := TMPPED->C6_TES
		aCItens[Len(aCItens), nDescProd2] := TMPPED->B1_DESCNF

		aCItens[Len(aCItens), Len(oGD:aHeader) + 1] := .F. //Coluna DELET do aCols

		TMPPED->(DbSkip())
	End

	TMPPED->(DbCloseArea())

	oGd:SetArray(aCItens)
	oGd:Refresh()

	RestArea(aAreaSA1)
	RestArea(aAreaSB1)
	RestArea(aArea)
Return()

/******************************************/
/* Busca Tag no XML                       */
/******************************************/

Static Function GetXmlVal(oObj, cTag, lRetObj)
	Local cRet := ""
	Private oNfe := oObj
	Default lRetObj := .F.

	_SetOwnerPrvt("oXml",oObj)

	cTag := "oXml:"+SubStr(cTag, aT(":",cTag) + 1)

	If ValType(&(cTag)) == "O" .And. !lRetObj
		cRet := AllTrim(&(cTag+":TEXT"))
	Else
		cRet := &(cTag)
	EndIf

Return(cRet)


/*********************************************************/
/* Le o XML e faz o Parse do arquivo. Retorna objeto XML */
/*********************************************************/
Static Function ImpArq(cPath, cAviso, cErro)

	Local oNfe  := Nil
	Local cXml  := "", cLinha := ""
	Local nCont := 0

	FT_FUse( cPath ) //Abre Arquivo

	FT_FGoTop()

	While !FT_FEof()
		nCont++
		cLinha := FT_FReadLn()
		cXml += StrTran(cLinha, CRLF, "")
		FT_FSkip()
	End

	oNfe := XmlParser(cXml,"_",@cAviso,@cErro)
	/*
	If Empty(cAviso) .And. Empty(cErro)
		VldXml(oNfe)
	EndIF
	*/

Return(oNfe)


/******************************************/
/* Busca pelo arquivo XML, retorna o path */
/******************************************/
Static Function RetPath(cPath)

	Local lRet := .T.
	Local cMascara := "xml | *.xml "

	cPath := AllTrim(cGetFile(cMascara,OemToAnsi("Selecione o Arquivo"), , "", .T. , GETF_LOCALHARD+GETF_NETWORKDRIVE))

	If !Empty(cPath) .And. !File(cPath)
		Aviso("Nota Fiscal SEFAZ", "Arquivo informado não exite",{"Ok"})
		lRet := .F.
	ElseIf Empty(cPath)
		lRet := .F.
	EndIf

Return(lRet)


/******************************************/
/* Função para validação dos campos       */
/******************************************/
User Function JRVldCpos(oGD)

	Local lRet       := .T.
	Local aArea      := GetArea()
	Local aAreaSC6   := SC6->(GetArea())
	Local aAreaSB1   := SB1->(GetArea())
	Local cCampo     := ReadVar()
	Local nPos       := 0
	Local lRepete    := .F.

	If "ITEM" $ cCampo .And. !Empty(M->ITEM)
		
		For nPos := 1 To Len(oGD:oGrid:aCols)
			If nPos <> oGD:GetAt()
				If oGD:GetField("ITEM", nPos) == M->ITEM
					lRepete := .T.
				EndIf
			EndIf
		Next

		If lRepete
			Aviso("Item de Pedido", "Item já utilizado para outro produto da NF.", {"Ok"})
			Return(.F.)
		EndIf
		
		SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		If SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM + M->ITEM))
			oGD:SetField("PRODPED"  , SC6->C6_PRODUTO)
			oGD:SetField("DESCPROD1", Posicione("SB1", 1, xFilial("SB1") + SC6->C6_PRODUTO, "B1_DESC"))
			oGD:SetField("QTDVEN"   , SC6->C6_QTDVEN)
			//If !EMPTY( SC6->C6_LOTECTL )
			oGD:SetField("LOTECTL"  , SC6->C6_LOTECTL) 
			//EndIf
		Else
        	Aviso("Item de Pedido", "Item não encontrado neste pedido de venda.", {"Ok"})
        	Return(.F.)
		EndIf
	EndIf

	oGD:Refresh()

	RestArea(aAreaSB1)
	RestArea(aAreaSC6)
	RestArea(aArea)

Return(lRet)

/******************************************/
/* Função para validação dos campos       */
/******************************************/
Static Function VldOk(oGd, cPathArq, cNumNF, cSerieNF, cChaveNF)

	Local lRet     := .T.
	Local nFor     := 0
	Local aArea    := GetArea()
	Local aAreaSC6 := SC6->(GetArea())
	Local aAreaSB1 := SB1->(GetArea())
	Local aAreaSF4 := SF4->(GetArea())
	Local aAreaSF2 := SF2->(GetArea())
	Local cMsg     := ""
	Local cPed     := ""
	Local __lAtuEst := .T.

	SB1->(DbSetorder(1))//B1_FILIAL+B1_COD

	If NFRepetida(cNumNF, cSerieNF, @cPed)
		cMsg += "Nota Fiscal já utilizada anteriormente no pedido: " + cPed + "." + Chr(13) + Chr(10)
		lRet := .F.
	EndIf

	For nFor := 1 To Len(oGD:oGrid:aCols)
		If Empty(oGD:GetField("ITEM", nFor))
			cMsg += "Linha: " + cValToChar(nFor) + " - Escolha o item do pedido." + Chr(13) + Chr(10)
			lRet := .F.
		EndIf

		If !SB1->(DbSeek(xFilial("SB1") + oGD:GetField("PRODNF", nFor)))
			cMsg += "Linha: " + cValToChar(nFor) + " - Produto da Nota não encontrado no cadastro de produtos." + Chr(13) + Chr(10)
			lRet := .F.
		EndIf
		
		/*
		Arthur Toshio --22/02/2022
		Verificar se a TES utilizada movimenta estoque 
		*/
		//If SF4->F4_ESTOQUE == 'S'
		If !Posicione("SF4", 1, xFilial("SF4") + oGD:GetField("TES", nFor), "F4_ESTOQUE")  == "N"

			If SB1->B1_RASTRO == "L"
				IF Empty(oGD:GetField("LOTECTL", nFor)) 
					cMsg += "Linha: " + cValToChar(nFor) + " - Lote não informado no pedido de venda." + Chr(13) + Chr(10)
					lRet := .F.
				EndIf
			EndIf
		Else
			__lAtuEst := .F.
		EndIf
	Next

	If !lRet
		Aviso("Validações", cMsg, {"Ok"})
	EndIf

	If lRet

		Processa({ || ProcNF(@oGD, cNumNF, cSerieNF, cChaveNF, cPathArq, __lAtuEst) } , "Processando...") 
		
	EndIf

	RestArea(aAreaSF2)
	RestArea(aAreaSF4)
	RestArea(aAreaSB1)
	RestArea(aAreaSC6)
	RestArea(aArea)

Return(lRet)

/******************************************************************************/
/* Para uso da função Processa()                                              */
/******************************************************************************/

Static Function ProcNF(oGD, cNumNF, cSerieNF, cChaveNF, cPathArq, __lAtuEst)

	Local nFor := 0
	Private _cProcNF := cNumNF

	Default __lAtuEst := .T.

	ProcRegua(0)

	
	IncProc("Liberando saldos dos produtos do pedido...")
	
	If __lAtuEst
		AlteraPed(oGD)//Faz alteração apenas para liberar os saldos de produtos
	EndIf

	SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	SF4->(DbSetorder(1)) //F4_FILIAL+F4_CODIGO

	IncProc("Transferindo saldos...")

	For nFor := 1 To Len(oGD:oGrid:aCols)
		
		SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM + oGD:GetField("ITEM", nFor)))
		SB1->(DbSeek(xFilial("SB1") + oGD:GetField("PRODPED", nFor)))
		SF4->(DbSeek(xFilial("SF4") + SC6->C6_TES))

		If SF4->F4_ESTOQUE == "S"
			RecLock("SC6", .F.)
				SC6->C6_PRODANT := SC6->C6_PRODUTO
		    SC6->(MsUnLock())		
			TransfSaldo(cNumNF, oGD, nFor, SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, SC6->C6_LOCAL, SC6->C6_DTVALID)
		EndIf
	Next

	IncProc("Alterando produtos no pedido...")
	if __lAtuEst
		AlteraPed(oGD, .T.)
	EndIf
	IncProc("Emitindo Nota Fiscal...")
	u_VAFATA02(SC5->C5_NUM)//Fatura Pedido

	DbSelectArea("SF2")
    DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA
    DbSeek(xFilial("SF2") + SC5->C5_NOTA + SC5->C5_SERIE + SC5->C5_CLIENTE + SC5->C5_LOJACLI)
    
	RecLock("SF2", .F.)
		SF2->F2_CHVNFE  := cChaveNF
		SF2->F2_ESPECIE := "SPED"
	SF2->(MsUnLock())


	IncProc("Anexando XML ao pedido...")
	AnexaXML(cPathArq, SC5->C5_NUM)

	RecLock("SC5", .F.)
		SC5->C5_NFMS    := cNumNF
		SC5->C5_SERIEMS := cSerieNF
	SC5->(MsUnlock())

Return()


/******************************************************************************/
/* Transfere saldo do produto do pedido para produto da NF.                   */
/******************************************************************************/

Static Function TransfSaldo(cNumNF, oGD, nPos, cProduto, cDescricao, cUM, cArmazem, dVldLote)

	Local aProd   := {}
	Local cNumDoc := "AV" + SC5->C5_NUM

	aProd := {{	cNumDoc,;    // 01.Numero do Documento
	            dDataBase }} // 02.Data da Transferencia
	

	DbSelectArea("SB2")
	DbSetOrder(1)
	If !DBSeek(xFilial("SB2") + oGD:GetField("PRODNF", nPos) + cArmazem)
		CriaSB2(oGD:GetField("PRODNF", nPos), cArmazem)
	endif		
	
	//
	//If oGD:GetField("LOTECTL", nPos) <> nil
		aAdd(aProd,{	;
			cProduto  ,;                 // 01.Produto Origem
			cDescricao,;                 // 02.Descricao
			cUM       ,;                 // 03.Unidade de Medida
			cArmazem,;                   // 04.Local Origem
			CriaVar("D3_LOCALIZ"),;	   	 // 05.Endereco Origem
			oGD:GetField("PRODNF", nPos),;     // 06.Produto Destino
			Posicione("SB1", 1, xFilial("SB1") + oGD:GetField("PRODNF", nPos), "B1_DESC"),; // 07.Descricao
			Posicione("SB1", 1, xFilial("SB1") + oGD:GetField("PRODNF", nPos), "B1_UM")  ,; // 08.Unidade de Medida
			cArmazem,;			         // 09.Armazem Destino
			CriaVar("D3_LOCALIZ",.F.),;	 // 10.Endereco Destino
			CriaVar("D3_NUMSERI",.F.),;	 // 11.Numero de Serie
			oGD:GetField("LOTECTL", nPos),;	 // 12.Lote Origem
			CriaVar("D3_NUMLOTE",.F.),;	 // 13.Sublote
			dVldLote,;                   // 14.Data de Validade
			CriaVar("D3_POTENCI",.F.),;	 // 15.Potencia do Lote
			oGD:GetField("QTDVEN", nPos),;    // 16.Quantidade
			CriaVar("D3_QTSEGUM",.F.),;	 // 17.Quantidade na 2 UM
			CriaVar("D3_ESTORNO",.F.),;	 // 18.Estorno
			"",;                         // 19.NumSeq
			oGD:GetField("LOTECTL", nPos),; // 20.Lote Destino
			dVldLote,; // 21.Lote Destino
			CriaVar("D3_ITEMGRD",.F.),; // 22.Item grade
			"Referente ao pedido: " + SC5->C5_NUM + " - Nota Fiscal: " + cNumNF }) // 23.Observação       28/08/20 - grava itens na observacao
	/*Else 
				aAdd(aProd,{	;
			cProduto  ,;                 // 01.Produto Origem
			cDescricao,;                 // 02.Descricao
			cUM       ,;                 // 03.Unidade de Medida
			cArmazem,;                   // 04.Local Origem
			CriaVar("D3_LOCALIZ"),;	   	 // 05.Endereco Origem
			oGD:GetField("PRODNF", nPos),;     // 06.Produto Destino
			Posicione("SB1", 1, xFilial("SB1") + oGD:GetField("PRODNF", nPos), "B1_DESC"),; // 07.Descricao
			Posicione("SB1", 1, xFilial("SB1") + oGD:GetField("PRODNF", nPos), "B1_UM")  ,; // 08.Unidade de Medida
			cArmazem,;			         // 09.Armazem Destino
			CriaVar("D3_LOCALIZ",.F.),;	 // 10.Endereco Destino
			CriaVar("D3_NUMSERI",.F.),;	 // 11.Numero de Serie
			CriaVar("D3_NUMLOTE",.F.),;	 // 13.Sublote
			CriaVar("D3_POTENCI",.F.),;	 // 15.Potencia do Lote
			oGD:GetField("QTDVEN", nPos),;    // 16.Quantidade
			CriaVar("D3_QTSEGUM",.F.),;	 // 17.Quantidade na 2 UM
			CriaVar("D3_ESTORNO",.F.),;	 // 18.Estorno
			"",;                         // 19.NumSeq oGD:GetField("LOTECTL", nPos),; // 20.Lote Destino
			dVldLote,; // 21.Lote Destino
			CriaVar("D3_ITEMGRD",.F.),; // 22.Item grade
			"Referente ao pedido: " + SC5->C5_NUM + " - Nota Fiscal: " + cNumNF }) // 23.Observação       28/08/20 - grava itens na observacao
	EndIf
	*/
	lMsErroAuto := .F.
	MSExecAuto({|x,y| MATA261(x,y)},aProd,3)
			
	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
	EndIf

Return()


/******************************************************************************/
/* Faz alteração do pedido, somente para liberar os saldos dos produtos.      */
/******************************************************************************/

Static Function AlteraPed(oGD, lTrocaPrd)

	Local aArea    := GetArea()
	Local aAreaSC6 := SC6->(GetArea())
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSB1 := SB1->(GetArea())
	Local aCab     := {}
	Local aItem    := {}
	Local nPos     := 0
	Local nItem    := oGD:GetColHeader("ITEM")

	Default lTrocaPrd := .F.

	Private lMsErroAuto := .F.

	SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM
	SC5->(DbSeek(xFilial("SC5") + SC5->C5_NUM))

	// Monta vetor com cabecalho do pedido                             
	aadd(aCab,{"C5_NUM    ", SC5->C5_NUM    , Nil}) // Tipo de pedido	
	aadd(aCab,{"C5_TIPO   ", SC5->C5_TIPO   , Nil}) // Tipo de pedido
	aadd(aCab,{"C5_CLIENTE", SC5->C5_CLIENTE, Nil}) // Cliente
	aadd(aCab,{"C5_LOJACLI", SC5->C5_LOJACLI, Nil}) // Loja
	aadd(aCab,{"C5_CLIENT ", SC5->C5_CLIENT , Nil}) // Cliente de entrega
	aadd(aCab,{"C5_LOJAENT", SC5->C5_LOJAENT, Nil}) // Loja de entrega

	SB1->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))

	While !SC6->(Eof()) .And. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC5") + SC5->C5_NUM

		If lTrocaPrd
			SB1->(DbSeek(xFilial("SB1") + SC6->C6_PRODBMS))
		Else 
			SB1->(DbSeek(xFilial("SB1") + SC6->C6_PRODUTO))
		EndIf

		aAdd(aItem, {	{"C6_ITEM   ", SC6->C6_ITEM        , Nil},; // Item
						{"C6_PRODUTO", SB1->B1_COD         , Nil},; // Codigo do produto
						{"C6_UM     ", SB1->B1_UM          , Nil},; // Unidade de medida
						{"C6_QTDVEN ", SC6->C6_QTDVEN      , Nil},; // quantidade
						{"C6_PRUNIT ", SC6->C6_PRUNIT      , Nil},; // valor unitario do preco de lista
						{"C6_PRCVEN ", SC6->C6_PRCVEN      , Nil},; // Valor unitario liquido B2_CM1
						{"C6_VALOR  ", A410Arred(SC6->C6_PRCVEN * SC6->C6_QTDVEN, "C6_VALOR"), Nil},; // Valor total
						{"C6_TES    ", SC6->C6_TES         , Nil},; // TES do Item
						{"C6_LOCAL  ", SC6->C6_LOCAL       , Nil},; // De onde sai o produto -- Almoxarifado (SB1)
						{"C6_QTDLIB ", IIf(lTrocaPrd, SC6->C6_QTDVEN, 0), Nil},; // De onde sai o produto -- Almoxarifado (SB1)
						{"C6_LOTECTL", SC6->C6_LOTECTL     , Nil},;
						{"C6_PRODBMS", SC6->C6_PRODBMS     , Nil},;
						{"C6_PRODANT", SC6->C6_PRODANT     , Nil},;
						{"C6_NUM    ", SC6->C6_NUM         , Nil}}) // Numero do Pedido
		
		SC6->(DbSkip())
	End

	Begin Transaction
	
	lMsErroAuto := .F.
	MSExecAuto({|x,y,z|Mata410(x,y,z)}, aCab, aItem, 4 )

	If lMsErroAuto
		cErro := "1"
		MostraErro()
		DisarmTransaction()
	EndIf

	End Transaction
	
	RestArea(aAreaSB1)
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aArea)
Return()


/******************************************************/
/*Fatura o pedido de venda*/
/******************************************************/
User Function VAFATA02(cPed)
Local lRet 		:= .F.
Private cSemaforo	:= ""
                                      		
DbSelectArea("SC5")
SC5->( DbSetOrder(1) ) // C5_FILIAL+C5_NUM
If SC5->(DbSeek(xFilial("SC5")+cPed))

	DbSelectArea("SC6")            
	SC6->( DbSetOrder(1) ) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	If SC6->( DbSeek(xFilial("SC6")+cPed ) )
 
 		DbSelectArea("SC9")
		SC9->( DbSetOrder(1) ) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
		If SC9->( DbSeek(xFilial("SC9")+cPed ) )
			cSemaforo := "VAFATA02"+xFilial('SC5')
			While !LockByName(cSemaforo,.F., .F., .T.)
				Sleep(500)
			EndDo
				lRet := SF_CA00A()
			UnLockByName(cSemaforo,.F., .F., .T.)
		EndIf
	EndIf
EndIf

Return lRet

Static Function SF_CA00A()
Local aArea     := GetArea()
Local aLibera   := {}
Local aBloqueio := {{"","","","","","","",""}}
Local aNotas    := {}
Local nItemNf   := 0
Local i         := 0
Local cSerie    := "" 
Local lContinua := .T.
Local lCond9  	:= GetNewPar("MV_DATAINF",.F.)
Local cFunName  := FunName()
Local lTxMoeda  := .F.
Local nReg      := SC5->(Recno())


if !Empty(cSerie := PadR(GetMV("VA_SERNF"), TamSX3("F2_SERIE")[1]))
   
   lCond9   := IIf(ValType(lCond9)<>"L",.F.,lCond9)
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Retorna o SetFunName que iniciou a rotina                               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   
   SetFunName("MATA461")
   
   If ( ExistBlock("M410PVNF") )
   	lContinua := ExecBlock("M410PVNF",.f.,.f.,nReg)
   EndIf
   
   If lContinua
       // aLibera ::={ <C9_PEDIDO>, <C9_ITEM>, <C9_SEQUEN>, <C9_QTDLIB>, <C9_PRCVEN>, <C9_PRODUTO>, <F4_ISS=="S">, <SC9->(RecNo())>,;
   	//              <SC5->(RecNo())>, <SC6->(RecNo())>, <SE4->(RecNo())>, <SB1->(RecNo())>, <SB2->(RecNo())>, <SF4->(RecNo())>,
       //              <C9_LOCAL>, 0, <C9_QTDLIB2> }
       // aBloqueio ::= { <C9_PEDIDO>, <C9_ITEM>, <C9_SEQUEN>, <C9_PRODUTO>, <C9_QTDLIB>, <C9_BLCRED>, <C9_BLEST>, <C9_BLWMS> }
   
   	LoadNFS(@aLibera,@aBloqueio)
   
   	If Empty(aBloqueio) .and.  !Empty(aLibera)
   		nItemNf  := A460NumIt(cSerie)
   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   		//³ Define variaveis de parametrizacao de lancamentos             ³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   		//³ mv_par01 Mostra Lan?.Contab ?  Sim/Nao                        ³
   		//³ mv_par02 Aglut. Lan?amentos ?  Sim/Nao                        ³
   		//³ mv_par03 Lan?.Contab.On-Line?  Sim/Nao                        ³
   		//³ mv_par04 Contb.Custo On-Line?  Sim/Nao                        ³
   		//³ mv_par05 Reaj. na mesma N.F.?  Sim/Nao                        ³
   		//³ mv_par06 Taxa deflacao ICMS ?  Numerico                       ³
   		//³ mv_par07 Metodo calc.acr.fin?  Taxa defl/Dif.lista/% Acrs.ped ³
   		//³ mv_par08 Arred.prc unit vist?  Sempre/Nunca/Consumid.final    ³
   		//³ mv_par09 Agreg. liberac. de ?  Caracter                       ³
   		//³ mv_par10 Agreg. liberac. ate?  Caracter                       ³
   		//³ mv_par11 Aglut.Ped. Iguais  ?  Sim/Nao                        ³
   		//³ mv_par12 Valor Minimo p/fatu?                                 ³
   		//³ mv_par13 Transportadora de  ?                                 ³
   		//³ mv_par14 Transportadora ate ?                                 ³
   		//³ mv_par15 Atualiza Cli.X Prod?                                 ³
   		//³ mv_par16 Emitir             ?  Nota / Cupom Fiscal            ³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
   
//   		If ( Pergunte("MT460A",.F.) ) // tirei, miguel
   			AAdd(aNotas,{})			
   		    For i := 1 To Len(aLibera)
   		    	If Len(aNotas[Len(aNotas)]) >= nItemNf
   		    		AAdd(aNotas,{})
   		    	EndIf
   		    	AAdd(aNotas[Len(aNotas)], aClone(aLibera[i]))
   			Next         
   
   			If ExistBlock("M410ALDT")			
                dDataBase := If(ValType(dDataPE := ExecBlock("M410ALDT", .F., .F.))=='D', dDataPE , dDataBase) 
            Endif
   
   			For i := 1 To Len(aNotas)
   				// Verifica se bloqueia faturamento quando o 1o vencto < emissao da NF na cond.pgto tipo 9 (T = Bloqueia , F = Fatura)
   				// Bloqueia faturamento se a moeda nao estiver cadastrada
   				// Neste momento o SC5 esta posicionado no item que irá gerar a nota fiscal.
   				If !(( lCond9 .And. SC5->C5_DATA1 < dDataBase .And. !Empty(SC5->C5_DATA1) );
   						.Or. ( xMoeda( 1, SC5->C5_MOEDA, 1, dDataBase, TamSX3("M2_MOEDA2")[2] ) = 0 ))
   					//MaPvlNfs(aNotas[i],cSerie,MV_PAR01==1,MV_PAR02==1,MV_PAR03==1,MV_PAR04==1,MV_PAR05==1,MV_PAR07,MV_PAR08,MV_PAR15==1,MV_PAR16==2)
/* 
					cSemaforo := "VAFATA02"+cFilant+cSerie
					While !LockByName(cSemaforo,.F., .F., .T.)
						Sleep(500)
					End
 */
						MaPvlNfs(aNotas[i],cSerie,.F.,.F.,.F.,.F.,.F.,3,3,.F.,.F.)
						SX6->(MsRUnLock()) // destravar X6 para liberar faturamento, alteracao realizada no dia 25/03. ANDREZÃO.
/*                      
					UnLockByName(cSemaforo,.F., .F., .T.)       
 */
   				Else
   					If ( xMoeda( 1, SC5->C5_MOEDA, 1, dDataBase ) = 0 )
   						lTxMoeda := .T.
   					EndIf
   				EndIf
   
   				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   				//³P.E . para exibir mensagem com motivo de não faturar de acordo com parametro MV_DATAINF³
   				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   				If (lCond9 .And. SC5->C5_DATA1 < dDataBase .And. !Empty(SC5->C5_DATA1) ) .And. ExistBlock( "M461DINF" ) 
   					ExecBlock( "M461DINF", .f., .f. ) 
   				EndIf
   			Next
   		//EndIf
   	Else
   		lContinua := .F.
		MSGINFO("Um ou mais itens do pedido de vendas " + SC5->C5_NUM + " não foram liberados. Ref Ped Site: " + SC5->C5_NUMPVIM + ".","Faturamento Automatico." )
	    //U_SendMail( "log.protheus@email.com.br", "" , "", "EI/Faturamento.PV: " + SC5->C5_NUMPVIM + " Fonte: VAFATA02" ,'Um ou mais itens do pedido de vendas ' + SC5->C5_NUM + ' não foram liberados. Ref Ped Site: ' + SC5->C5_NUMPVIM + '.', /*cFrom */ , "" ,  .T. )
   	EndIf
   EndIf                                                                       
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Retorna o SetFunName que iniciou a rotina                               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   SetFunName(cFunName)
   	
   //Mensagem para o usuário em caso de existirem notas com datas onde não foram encontrados valores de moeda cadastrados
   If lTxMoeda
   	  lContinua := .F.
	  Msginfo("O pedido " + SC5->C5_NUM + " não foi gerado pois não existe taxa para a moeda na data! Ref Ped Site: " + SC5->C5_NUMPVIM + ".", "Faturamento Automatico.")
	  //U_SendMail( "log.protheus@email.com.br", "" , "", "EI/Faturamento.PV: " + SC5->C5_NUMPVIM + " Fonte: VAFATA02" , "O pedido " + SC5->C5_NUM + " não foi gerado pois não existe taxa para a moeda na data! Ref Ped Site: " + SC5->C5_NUMPVIM + ".", /*cFrom */ , "" ,  .T. )
   EndIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Carrega perguntas do MATA410                                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Pergunte("MTA410",.F.)
   RestArea(aArea)
Else
	Msginfo('O pedido nao foi faturado pois nao existe parametro VA_SERNF para faturamento automatico. Ref Ped Site: ' + SC5->C5_NUMPVIM + ".", "Faturamento Automatico.")
	//U_SendMail( "log.protheus@email.com.br", "" , "", "EI/Faturamento.PV: " + SC5->C5_NUMPVIM + " Fonte: VAFATA02" , 'O pedido nao foi faturado pois nao existe parametro 'VA_SERNF' para faturamento automatico. Ref Ped Site: ' + SC5->C5_NUMPVIM + ".", /*cFrom */ , "" ,  .T. )
EndIf
   
Return lContinua

Static Function LoadNFS(aLiberada,aBloqueada)
Local aArea      := GetArea()
Local cAliasSC9  := ""
Local nPrcVen    := 0
Local cSql       := ""

Default aLiberada    := {}
aBloqueada  := {}


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se há itens liberados                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasSC9 := CriaTrab(,.F.)
	cSql := "  select SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_SEQUEN,SC9.C9_QTDLIB,SC9.C9_QTDLIB2,"
	cSql += "         SC9.C9_PRCVEN,SC9.C9_PRODUTO,SC9.C9_LOCAL,SC9.C9_BLCRED,SC9.C9_BLEST,SC9.C9_BLWMS,"
	cSql += "         SC9.R_E_C_N_O_ C9_RECNO "
	cSql += "    from "+RetSqlName("SC9")+" SC9 "
	cSql += "   where SC9.C9_FILIAL = '" + xFilial("SC9") + "' "
	cSql += "     and SC9.C9_PEDIDO = '" + SC5->C5_NUM + "' "
	cSql += "     and SC9.D_E_L_E_T_=' ' "
		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cSql)),cAliasSC9)
		
	While !Eof() .And. xFilial("SC9") == (cAliasSC9)->C9_FILIAL .And. SC5->C5_NUM == (cAliasSC9)->C9_PEDIDO
		If Empty((cAliasSC9)->C9_BLCRED+(cAliasSC9)->C9_BLEST) ;
		   .And. (Empty((cAliasSC9)->C9_BLWMS) .Or.;
		          (cAliasSC9)->C9_BLWMS == "05" .Or.;
		          (cAliasSC9)->C9_BLWMS == "07" ) 
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona registros                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SC6->(DbSetOrder(1))
			SC6->(DbSeek(xFilial("SC6")+(cAliasSC9)->C9_PEDIDO+(cAliasSC9)->C9_ITEM+(cAliasSC9)->C9_PRODUTO))
			
			SE4->(DbSetOrder(1))
			SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG) )
	
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
	
			SB2->(DbSetOrder(1))
			SB2->(DbSeek(xFilial("SB2")+(cAliasSC9)->C9_PRODUTO+(cAliasSC9)->C9_LOCAL))
	
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o produto est  sendo inventariado  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF4->F4_ESTOQUE == 'S' .And. BlqInvent((cAliasSC9)->C9_PRODUTO,(cAliasSC9)->C9_LOCAL)
				// TODO -- LOG " Produto bloqueado por inventario. Pedido: " + (cAliasSC9)->C9_PEDIDO + ", Item: " + (cAliasSC9)->C9_ITEM + " Produto: " + (cAliasSC9)->C9_PRODUTO + " Local: " + (cAliasSC9)->C9_LOCAL + "."
				Msginfo("Produto bloqueado por inventario. Pedido: " + (cAliasSC9)->C9_PEDIDO + ", Item: " + (cAliasSC9)->C9_ITEM + " Produto: " + (cAliasSC9)->C9_PRODUTO + " Local: " + (cAliasSC9)->C9_LOCAL + ".", "Faturamento Automatico.")
				//U_SendMail( "log.protheus@email.com.br", "" , "", "EI/Faturamento.PV: " + SC5->C5_NUMPVIM + " Fonte: VAFATA02" , " Produto bloqueado por inventario. Pedido: " + (cAliasSC9)->C9_PEDIDO + ", Item: " + (cAliasSC9)->C9_ITEM + " Produto: " + (cAliasSC9)->C9_PRODUTO + " Local: " + (cAliasSC9)->C9_LOCAL + ".", /*cFrom */ , "" ,  .T. )
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calcula o preco de venda                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				nPrcVen := (cAliasSC9)->C9_PRCVEN
				If ( SC5->C5_MOEDA <> 1 )
					nPrcVen := a410Arred(xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase,8),"D2_PRCVEN")
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta array para geracao da NF                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Aadd(aLiberada,{ (cAliasSC9)->C9_PEDIDO,;
				                 (cAliasSC9)->C9_ITEM,;
				                 (cAliasSC9)->C9_SEQUEN,;
				                 (cAliasSC9)->C9_QTDLIB,;
				                 nPrcVen,;
				                 (cAliasSC9)->C9_PRODUTO,;
				                 SF4->F4_ISS=="S",;
				                 (cAliasSC9)->C9_RECNO,;
				                 SC5->(RecNo()),;
				                 SC6->(RecNo()),;
				                 SE4->(RecNo()),;
				                 SB1->(RecNo()),;
				                 SB2->(RecNo()),;
				                 SF4->(RecNo()),;
				                 (cAliasSC9)->C9_LOCAL,;
				                 0,;
				                 (cAliasSC9)->C9_QTDLIB2} )
			EndIf
		ElseIf (cAliasSC9)->C9_BLCRED <> "10" .And. (cAliasSC9)->C9_BLEST <> "10"
			AAdd(aBloqueada,{(cAliasSC9)->C9_PEDIDO, (cAliasSC9)->C9_ITEM, (cAliasSC9)->C9_SEQUEN, (cAliasSC9)->C9_PRODUTO, TransForm((cAliasSC9)->C9_QTDLIB,X3Picture("C9_QTDLIB")), (cAliasSC9)->C9_BLCRED, (cAliasSC9)->C9_BLEST, (cAliasSC9)->C9_BLWMS})
		EndIf
		(cAliasSC9)->(DbSkip())
	EndDo
	(cAliasSC9)->(DbCloseArea())
	
RestArea(aArea)
Return Nil

/******************************************************/
/*Anexa o XML no pedido de venda                      */
/******************************************************/

Static Function AnexaXML(cPathArq, cChave)

	GrvBancoC(cPathArq, cChave)

Return()

Static Function GrvBancoC(cArq, cChave)
	Local lRet := .F.
	Local cFile := ""
	Local cExten := ""
	Local cCodObj := ""

	If Select("ACB") == 0
		DbSelectArea("ACB")
		DbSetOrder(1)
	EndIf

	If Select("AC9") == 0
		DbSelectArea("AC9")
	EndIf

	If lRet := Ft340CpyObj(cArq)
		SplitPath( cArq, , , @cFile, @cExten )
		
		cCodObj := GetSXENum( "ACB", "ACB_CODOBJ" )
		
		While ACB->(DbSeek(xFilial("ACB") + cCodObj))
			ConfirmSx8()
			cCodObj := GetSXENum( "ACB", "ACB_CODOBJ" )
		End
		
		RecLock("ACB", .T.)
			ACB->ACB_FILIAL := xFilial("ACB")
			ACB->ACB_CODOBJ := cCodObj
			ACB->ACB_OBJETO := cFile + cExten
			ACB->ACB_DESCRI := cFile
		MsUnLock()

		ConfirmSx8()

		RecLock("AC9", .T.)
			AC9->AC9_FILIAL := xFilial("AC9")
			AC9->AC9_FILENT := cFilAnt
			AC9->AC9_ENTIDA := "SC5"
			AC9->AC9_CODENT := cChave
			AC9->AC9_CODOBJ := cCodObj
		MsUnLock()
	EndIf
Return(lRet)

/************************************************************************/
/* Verifica se a nota fiscal da sefaz já foi utilizada em outro pedido. */
/************************************************************************/

Static Function NFRepetida(cNumNF, cSerieNF, cPed)
	
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local cSql     := "" 

	cSql := "SELECT * "
	cSql += "FROM " + RetSqlName("SC5") + " SC5 "
	cSql += "WHERE SC5.D_E_L_E_T_ <> '*' AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND "
	cSql += "      SC5.C5_NFMS    = '" + PadR(cNumNF,   Len(SC5->C5_NFMS)) + "' AND "
	cSql += "      SC5.C5_SERIEMS = '" + PadR(cSerieNF, Len(SC5->C5_NFMS)) + "' "

	TCQuery cSql New Alias "TMPC5"

	If !TMPC5->(Eof())
		cPed := TMPC5->C5_NUM
		lRet := .T.
	EndIf

	TMPC5->(DbCloseArea())

	RestArea(aArea)
Return(lRet)
