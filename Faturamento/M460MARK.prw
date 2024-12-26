#INCLUDE 'Protheus.ch'
#INCLUDE 'TopConn.ch'

User Function M460MARK()

    Local aParam   := PARAMIXB
	Local cMarca   := aParam[1]   //indica se o item esta selecionado para NF de saida
    Local lRet     := .T.
    Local cSql     := ""
    Local cMsg     := ""
    Local aPedidos := {}


    //Filtrar Grupo de Produto BOV

    //Executa apenas para filiais do MS
    
    If SM0->M0_ESTENT <> 'MS'
        Return(.T.)
    EndIf
    

    cSql := "SELECT * "
    cSql += "FROM " + RetSqlName("SC9") + " SC9 "
    cSql += "JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL = '"+ xFilial("SC5") + "' AND "
	cSql +=  " SC5.C5_NUM = SC9.C9_PEDIDO AND "
	cSql +=  " SC5.C5_TIPO = 'N' AND "
	cSql +=  " SC5.D_E_L_E_T_ = ' '  "
    //cSql +=  " SC5.C5_LIBVAMS <> 'S' "
    cSql += "JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
    cSql += " SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = SC9.C9_PRODUTO AND "
    cSql += " SB1.B1_GRUPO = '" + PadR('BOV', Len(SB1->B1_GRUPO)) + "' "// Transformar em parametro
    cSql += "WHERE SC9.D_E_L_E_T_ <> '*' AND SC9.C9_FILIAL = '" + xFilial("SC9") + "' AND "
    cSql += "      SC9.C9_OK = '"+ cMarca +"' "
    cSql += "ORDER BY SC9.C9_FILIAL, SC9.C9_PEDIDO, SC9.C9_ITEM 

    cSql := ChangeQuery(cSql)
    TcQuery cSql New Alias "TMPSC9"

    While !TMPSC9->(Eof())
		
        If aScan(aPedidos, {|x| x == TMPSC9->C9_PEDIDO }) == 0
            aAdd(aPedidos, TMPSC9->C9_PEDIDO)
		    cMsg += TMPSC9->C9_PEDIDO + Chr(13) + Chr(10)
        EndIf
		
		TMPSC9->(DbSkip())
	EndDo

    TMPSC9->(DbCloseArea())

    If !Empty(cMsg)
        cMsg := "Os pedidos abaixo não poderão ser faturados. Providencie o faturamento SEFAZ-MS e processamento do XML." + Chr(13) + Chr(10) + cMsg
        Aviso("Faturamento Bloqueado", OemToAnsi(cMsg), {"Ok"})

        //MsgAlert( cMsg, "Faturamento Bloqueado")
		
        lRet := .F.
    EndIf
	
Return(lRet)
