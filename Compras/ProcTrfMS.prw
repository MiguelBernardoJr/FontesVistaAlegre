#INCLUDE 'Protheus.ch'
#INCLUDE 'TopConn.ch'

/**********************************************************/
/* Processa entrada de nota fiscal de transferência entre */
/* filiais.                                               */
/**********************************************************/

User Function ProcTrfMS(nOpcao, cDoc, cSerie, cFornece, cLoja)

    Local cSql     := ""
    Local cSqlCli  := ""
    Local aArea    := GetArea()
    Local aAreaSM0 := SM0->(GetArea())
    Local aAreaSA2 := SA2->(GetArea())
    Local aAreaSD1 := SD1->(GetArea())
    Local cFilNF   := ""
	Local cAlias   := ""
	Local cAlias1  := ""

    If cValToChar(nOpcao) $ "3/4"

        DbSelectArea("SD1")
        DbSetOrder(1)//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
        DbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)

        DbSelectArea("SA2")
        DbSetOrder(1)
        DbSeek(xFilial("SA2") + cFornece + cLoja)

        DbSelectArea("SM0")
        DbSetOrder(1)
        DbGoTop()

        cCGCCli := AllTrim(SM0->M0_CGC)

        While !SM0->(Eof())

            If SM0->M0_CGC == SA2->A2_CGC
                cFilNF := SM0->M0_CODFIL
                Exit
            EndIf

            SM0->(DbSkip())
        End

        RestArea(aAreaSM0)

        DbSelectArea("SB1")
        DbSetOrder(1)

        cSqlCli := "SELECT * "
        cSqlCli += "FROM " + RetSqlName("SA1") + " SA1 "
        cSqlCli += "WHERE SA1.D_E_L_E_T_ <> '*' AND SA1.A1_FILIAL = '" + cFilNF + "' AND SA1.A1_CGC = '" + cCGCCli + "' "

		cAlias := MpSysOpenQuery(cSqlCli)

        cSql := "SELECT * "
        cSql += "FROM " + RetSqlName("SD2") + " SD2 "
        cSql += "JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ <> '*' AND SC6.C6_FILIAL = '" + cFilNF + "' AND "
        cSql += "      SC6.C6_NOTA = SD2.D2_DOC AND SC6.C6_SERIE = SD2.D2_SERIE "
        cSql += "JOIN " + RetSqlName("SF4") + " SF4 ON SF4.D_E_L_E_T_ <> '*' AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND "
        csql += "      SF4.F4_CODIGO = SC6.C6_TES AND SF4.F4_TRANFIL = '1'  AND F4_ESTOQUE = 'S' "
        cSql += "WHERE SD2.D_E_L_E_T_ <> '*' AND SD2.D2_FILIAL = '" + cFilNF + "' AND "
        cSql += "      SD2.D2_DOC = '" + cDoc + "' AND SD2.D2_SERIE = '" + cSerie + "' AND "
        cSql += "      SD2.D2_CLIENTE = '" + (cAlias)->A1_COD + "' AND SD2.D2_LOJA = '" + (cAlias)->A1_LOJA + "' "

		cAlias1 := MpSysOpenQuery(cSql)

        While (cAlias1)->(Eof())

            If (cAlias1)->F4_ESTOQUE == "S"

                SB1->(DbSeek(xFilial(1) + (cAlias1)->D2_COD))

			    TransfSaldo((cAlias1)->D2_COD, SD1->D1_LOCAL, SB1->B1_DESC, SB1->B1_UM, (cAlias1)->D2_LOTECTL, STOD((cAlias1)->C6_DTVALID), (cAlias1)->C6_PRODANT, (cAlias1)->D2_QUANT)
                
		    EndIf

            (cAlias1)->(DbSkip())
        End

        (cAlias1)->(DbCloseArea())
        (cAlias)->(DbCloseArea())

    EndIf 

    RestArea(aAreaSD1)
    RestArea(aAreaSA2)
    RestArea(aArea)
Return()

Static Function TransfSaldo(cProdOrigem, cArmazem, cDescOrigem, cUMOrigem, cLote, dValidade, cProdDest, nQuant)


	Local aProd   := {}
	Local cNumDoc := "DE" + SC5->C5_NUM

	aProd := {{	cNumDoc,;    // 01.Numero do Documento
	            dDataBase }} // 02.Data da Transferencia
    
	DbSelectArea("SB2")
	DbSetOrder(1)
	If !DBSeek(xFilial("SB2") + cProdDest + cArmazem)
        CriaSB2(cProdDest, cArmazem)
	endif		
	
	//
    If !EMPTY( cLote )
	aAdd(aProd,{	;
		cProdOrigem  ,;                 // 01.Produto Origem
		cDescOrigem  ,;                 // 02.Descricao
		cUMOrigem    ,;                 // 03.Unidade de Medida
		cArmazem     ,;                   // 04.Local Origem
		CriaVar("D3_LOCALIZ"),;	   	 // 05.Endereco Origem
		cProdDest    ,;     // 06.Produto Destino
		Posicione("SB1", 1, xFilial("SB1") + cProdDest, "B1_DESC"),; // 07.Descricao
		Posicione("SB1", 1, xFilial("SB1") + cProdDest, "B1_UM")  ,; // 08.Unidade de Medida
		cArmazem     ,;			         // 09.Armazem Destino
		CriaVar("D3_LOCALIZ",.F.),;	 // 10.Endereco Destino
		CriaVar("D3_NUMSERI",.F.),;	 // 11.Numero de Serie
		cLote        ,;	 // 12.Lote Origem
		CriaVar("D3_NUMLOTE",.F.),;	 // 13.Sublote
		dValidade    ,;                   // 14.Data de Validade
		CriaVar("D3_POTENCI",.F.),;	 // 15.Potencia do Lote
		nQuant       ,;    // 16.Quantidade
		CriaVar("D3_QTSEGUM",.F.),;	 // 17.Quantidade na 2 UM
		CriaVar("D3_ESTORNO",.F.),;	 // 18.Estorno
		""           ,; // 19.NumSeq
		cLote        ,; // 20.Lote Destino
		dValidade,; // 21.Lote Destino
		CriaVar("D3_ITEMGRD",.F.),; // 22.Item grade
		"Referente Nota Fiscal : " + SF1->F1_DOC + "/" + SF1->F1_SERIE }) // 23.Observação       28/08/20 - grava itens na observacao
    else
        aAdd(aProd,{	;
		cProdOrigem  ,;                 // 01.Produto Origem
		cDescOrigem  ,;                 // 02.Descricao
		cUMOrigem    ,;                 // 03.Unidade de Medida
		cArmazem     ,;                   // 04.Local Origem
		CriaVar("D3_LOCALIZ"),;	   	 // 05.Endereco Origem
		cProdDest    ,;     // 06.Produto Destino
		Posicione("SB1", 1, xFilial("SB1") + cProdDest, "B1_DESC"),; // 07.Descricao
		Posicione("SB1", 1, xFilial("SB1") + cProdDest, "B1_UM")  ,; // 08.Unidade de Medida
		cArmazem     ,;			         // 09.Armazem Destino
		CriaVar("D3_LOCALIZ",.F.),;	 // 10.Endereco Destino
		CriaVar("D3_NUMSERI",.F.),;	 // 11.Numero de Serie
		CriaVar("D3_NUMLOTE",.F.),;	 // 13.Sublote
		CriaVar("D3_POTENCI",.F.),;	 // 15.Potencia do Lote
		nQuant       ,;    // 16.Quantidade
		CriaVar("D3_QTSEGUM",.F.),;	 // 17.Quantidade na 2 UM
		CriaVar("D3_ESTORNO",.F.),;	 // 18.Estorno
		""           ,; // 19.NumSeq
		cLote        ,; // 20.Lote Destino
		dValidade,; // 21.Lote Destino
		CriaVar("D3_ITEMGRD",.F.),; // 22.Item grade
		"Referente Nota Fiscal : " + SF1->F1_DOC + "/" + SF1->F1_SERIE }) // 23.Observação       28/08/20 - grava itens na observacao
	EndIf
	lMsErroAuto := .F.
	MSExecAuto({|x,y| MATA261(x,y)},aProd,3)
			
	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
	EndIf

Return()
