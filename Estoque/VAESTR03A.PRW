#INCLUDE "TOPCONN.CH"
#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"


#DEFINE CRLF Chr(13) + Chr(10)


User Function VAESTR05()

	local aArea	:= getArea()
	local cPerg := "VAESTR05"
	
	Private cPath 	 	:= "C:\totvs_relatorios\"
	Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"		
	Private nHandle    	:= 0

	GeraX1(cPerg)

	//apresentando o grupo de perguntas.
	If Pergunte(cPerg, .T.)
		U_PrintSX1(cPerg)

		//lContinua := perg(cPerg)

		If Len( Directory(cPath + "*.*","D") ) == 0
			If Makedir(cPath) == 0
				ConOut('Diretorio Criado com Sucesso.')
				MsgAlert('Diretorio Criado com Sucesso: ' + cPath, 'Aviso')
			Else	
				ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
				MsgAlert( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ), 'Aviso' )
			EndIf
		EndIf

		nHandle := FCreate(cArquivo)

		if nHandle = -1
			conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
		else 
			Processa({|| executar()},"Imprimindo..." )
		endif 
	else
		//se clicou no botÃ£o sair na tela de perguntas
		alert("Operação cancelada pelo usuário.")	
		return 
	endIf
	
		
	restArea(aArea)
	
Return

Static Function executar()
	Local aCabec		:= {}
	Local aDados		:= {}
	Local cTitulo		:= "Resumo de E/S por Produtos"
	Private nExibeC	:= 0

	nExibeC		:= MV_PAR13
	If nExibeC = 2	// exibe sem custo
		aCabec 	:= {"Filial",;					//01
			        "Produto",;					//01
					"Descrição",;				//02	//"Lote"  "Curral"	"Cod Insumo"
					"Qtd Atual",;
					"Valor Atual",;
					"Armazém",;						//03
					"UM",;						//03
					"Tipo",;					//04
					"Saldo Inicial",;			//05
					"E - Compras",;			//07
					"E - NF Transf.",;			//09				
					"E - Dev. Vendas",;		//11
					"E - Qtd Produção",;			//13
					"E - Movimen. Interno",;		//15
					"E - Transf. Interna",;
					"E - Nascimento",;		//
					"E - Inventário",;		//17
					"S - Vendas",;			//19
					"S - NF Transf.",;			//21				
					"S - Dev.Compras",;		//23
					"S - Req. Produção",;		//25
					"S - Mov.Int.Saida",;	//27
					"S - Transf. Interna",;
					"S - Morte",;			
					"S - Inventário",;		//29
					"Saldo Final",;				//31
					"Situação",;				//31
					}

	Else // Exibe com Custo
		aCabec 	:= {"Filial",;					//01
			        "Produto",;					//01
					"Descrição",;				//02	//"Lote"  "Curral" "Cod Insumo"
					"Qtd Atual",;
					"Valor Atual",;
					"Armazém",;						//03
					"UM",;						//03
					"Tipo",;					//04
					"Saldo Inicial",;			//05
					"Custo Inicial",;			//06
					"E - Compras",;			//07
					"C - Compras",;			//08
					"E - NF Transf.",;			//09				
					"C - NF Transf.",;			//10
					"E - Dev. Vendas",;		//11
					"C - Dev. Vendas",;		//12				
					"E - Qtd Produção",;			//13
					"C - Produção",;			//14
					"E - Movimen. Interno",;		//15
					"C - Mov.Int.Ent.",;	//16
					"E - Transf. Interna",;
					"C - Ent. Transf. Interna",;
					"E - Nascimento",;
					"E - Cust. Nascimento", ;
					"E - Inventário",;		//17
					"C - Invent.Ent.",;		//18
					"S - Vendas",;			//19
					"C - Vendas",;			//20
					"S - NF Transf.",;			//21				
					"C - Transf. Saida",;			//22
					"S - Dev.Compras",;		//23
					"C - Dev.Compras",;		//24				
					"S - Req. Produção",;		//25
					"C - Req. Produção",;	//26
					"S - Mov.Int.Saida",;	//27
					"C - Mov.Int.Saida",;	//28
					"S - Transf. Interna",;
					"C - Saida Transf. Inter",;
					"S - Morte",;
					"C - Morte",;
					"S - Inventário",;		//29
					"S - Invent.Saida",;	//30
					"Saldo Final",;				//31
					"Valor Final",;             //32
					"Situação",;             //32
					}
	
	Endif
			
	aDados 			:= getSQL()
	
	DlgToExcel({{"ARRAY",cTitulo,aCabec,aDados}})
Return

static function getSQL()
	local cAlias	:= getNextAlias()
	local cQuery 	:= ""
	Local cQrySB2	:= ""
	local cLocalDe	:= ""
	local cLocalAte	:= ""
	local cTipo		:= ""
	local cProdDe	:= ""
	local cProdAte	:= ""
	local dDataDigDe:= CToD("") 
	local dDataDigAt:= CToD("")
	local nMoeda	:= 0
	local aTipo		:= {}
	local nB		:= 0
	local nSaldoFin	:= 0
	local nCustoFin	:= 0
	local aRet		:= {}
	local nQtdTransf:= 0
	local nCustTrans:= 0
	local nQtdMovInt:= 0	
	local nCustMovIn:= 0
	Local cSitua    := ''
	local cGrupoDe	:= ""
	local cGrupoAte	:= ""
	local aProp     := {0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	Local cFiliDe	:= ''
	Local cFiliAte	:= ''
	Local nSaldoIni := 0 
	Local nCustoIni := 0
	Local cfilBkp		:= cFilAnt
	
	cTipo:= MV_PAR03
	
	if At(cTipo,';') > 0
		cTipo := strTran(cTipo,";",",")
	endIf
	
	aTipo	:= StrTokArr(cTipo,',')
	
	cTipo 	:= ""
	
	for nB:=1 to len(aTipo)
		if !empty(allTrim(aTipo[nB]))
			cTipo += "'"+allTrim(aTipo[nB])+"',"
		endIf
	next nB
	
	cTipo := subStr(cTipo,1,len(cTipo)-1)
	
	cLocalDe	:= MV_PAR01
	cLocalAte	:= MV_PAR02
	cProdDe		:= MV_PAR04
	cProdAte	:= MV_PAR05
	dDataDigDe	:= MV_PAR06 
	dDataDigAt	:= MV_PAR07
	nMoeda		:= MV_PAR08
	cGrupoDe	:= MV_PAR09
	cGrupoAte	:= MV_PAR10
	cFiliDe		:= MV_PAR11
	cFiliAte	:= MV_PAR12
	nExibeC		:= MV_PAR03
	dDataAnt 	:= dDataDigDe //MonthSub(dDataDigDe, 1)
	dDataAnt 	:= dDataDigDe //LastDay(dDataAnt)

	cQuery	+= " SELECT B2_FILIAL, B2_COD,B1_DESC,B1_XLOTE, B1_X_CURRA, INSUMO, B2_QATU, B2_VATU1, B1_UM,B1_TIPO, B2_LOCAL,  " + CRLF
	cQuery	+= " 	SUM(SALDO_INI)			AS SALDO_INI, " + CRLF 
	cQuery	+= " 	SUM(CUSTO_INI)			AS CUSTO_INI, " + CRLF
	cQuery	+= " 	SUM(QTD_COMPRAS)		AS QTD_COMPRAS, " + CRLF
	cQuery	+= " 	SUM(CUST_COMPRAS)		AS CUSTO_COMPRAS, " + CRLF
	cQuery	+= " 	SUM(QTD_TRF_ENTRAD)		AS QTD_TRF_ENTRAD ," + CRLF
	cQuery	+= " 	SUM(CUST_TRF_ENTRAD)	AS CUST_TRF_ENTRAD ,	 " + CRLF
	cQuery	+= " 	SUM(QTD_DEV_VENDAS)		AS QTD_DEV_VENDAS, " + CRLF
	cQuery	+= " 	SUM(CUST_VEND_DEV)		AS CUST_VEND_DEV, " + CRLF
	cQuery	+= " 	SUM(QTD_PRODUCAO)		AS QTD_PRODUCAO, " + CRLF
	cQuery	+= " 	SUM(CUSTO_PRODUCAO)		AS CUSTO_PRODUCAO, " + CRLF
	cQuery	+= " 	SUM(QTD_INV_ENTRADA)	AS QTD_INV_ENTRADA, " + CRLF
	cQuery	+= " 	SUM(CUST_INV_ENTRA)		AS CUST_INV_ENTRA, " + CRLF
	cQuery	+= " 	SUM(QTD_MOVI_ENTRADA)	AS QTD_MOVI_ENTRADA, " + CRLF
	cQuery	+= " 	SUM(CUST_MV_ENTRADA)	AS CUST_MV_ENTRADA, " + CRLF
	cQuery	+= " 	SUM(QTD_MV_E_T)			AS QTD_MV_E_T, " + CRLF
	cQuery	+= " 	SUM(CST_MV_E_T)			AS CST_MV_E_T, " + CRLF
	cQuery	+= "	SUM(QTD_NASCIMENTO)		AS QTD_NASCIMENTO, " + CRLF
	cQuery	+= "	SUM(CUST_MV_NASCIMENTO)	AS CUST_MV_NASCIMENTO, " + CRLF
	cQuery	+= " 	SUM(QTD_VENDAS)			AS QTD_VENDAS, " + CRLF
	cQuery	+= " 	SUM(CUST_VENDAS)		AS CUSTO_VENDAS, " + CRLF
	cQuery	+= " 	SUM(QTD_TRF_SAIDA)		AS QTD_TRF_SAIDA ," + CRLF
	cQuery	+= " 	SUM(CUST_TRF_SAIDA)		AS CUST_TRF_SAIDA ,	 	" + CRLF
	cQuery	+= " 	SUM(QTD_DEV_COMPRAS)	AS QTD_DEV_COMPRAS, " + CRLF
	cQuery	+= " 	SUM(CUST_COMP_DEV)		AS CUST_COMP_DEV, " + CRLF
	cQuery	+= " 	SUM(QTD_REQ_PROD)		AS QTD_REQ_PROD, " + CRLF
	cQuery	+= " 	SUM(CUST_REQ_PROD)		AS CUST_REQ_PROD, " + CRLF
	cQuery	+= " 	SUM(QTD_INV_SAIDA)		AS QTD_INV_SAIDA, " + CRLF
	cQuery	+= " 	SUM(CUST_INV_SAIDA)		AS CUST_INV_SAIDA, " + CRLF
	cQuery	+= " 	SUM(QTD_MOVI_SAIDA)		AS QTD_MOVI_SAIDA, " + CRLF
	cQuery	+= " 	SUM(CUST_MV_SAIDA)		AS CUST_MV_SAIDA, " + CRLF
	
	cQuery	+= " 	SUM(QTD_MV_S_TR)		AS QTD_MV_S_TR, " + CRLF
	cQuery	+= " 	SUM(CST_MV_S_TR)		AS CST_MV_S_TR, " + CRLF
	
	
	cQuery	+= " 	SUM(QTD_MORTE)			AS QTD_MORTE, " + CRLF
	cQuery	+= " 	SUM(CUST_MV_MORTE)		AS CUST_MV_MORTE " + CRLF
	
	cQuery	+= " FROM " + CRLF	
	cQuery	+= " 	(" + CRLF	
	cQuery	+= " 	SELECT SB2.B2_FILIAL, SB2.B2_COD,B1_DESC,B1_XLOTE, B1_X_CURRA, B21.B2_COD AS INSUMO, SB2.B2_QATU, SB2.B2_VATU1, B1_UM,B1_TIPO, SB2.B2_LOCAL     "+ CRLF	
	cQuery	+= "		,ISNULL((SELECT B9_QINI        FROM "+retSQLTab("SB9")+" WHERE B9_FILIAL = SB2.B2_FILIAL AND B9_COD = SB2.B2_COD AND B9_LOCAL = SB2.B2_LOCAL AND B9_DATA = '" + DTOS(dDataAnt) + "' AND SB9.D_E_L_E_T_ = ' '),0) AS SALDO_INI" + CRLF
	cQuery	+= "		,ISNULL((SELECT B9_VINI"+cValToChar(nMoeda)+"        FROM "+retSQLTab("SB9")+" WHERE B9_FILIAL = SB2.B2_FILIAL AND B9_COD = SB2.B2_COD AND B9_LOCAL = SB2.B2_LOCAL AND B9_DATA = '" + DTOS(dDataAnt) + "' AND SB9.D_E_L_E_T_ = ' '),0) AS CUSTO_INI" + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D1_QUANT)  FROM "+retSQLTab("SD1")+" INNER JOIN "+retSQLTab("SF4")+" ON F4_FILIAL = ' "+FWxFilial("SF4")+"' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D1_FILIAL = SB2.B2_FILIAL AND D1_COD = SB2.B2_COD AND D1_LOCAL = SB2.B2_LOCAL AND D1_DTDIGIT >= '"+dToS(dDataDigDe)+"' AND D1_DTDIGIT <= '"+dToS(dDataDigAt)+"' AND D1_TIPO <> 'D' AND F4_TRANFIL <> '1' AND SD1.D_E_L_E_T_ = ' '),0) AS QTD_COMPRAS" + CRLF	
	cQuery	+= "   		,ISNULL((SELECT SUM(D1_CUSTO"+iif(nMoeda>1,cValToChar(nMoeda),"")+")  FROM "+retSQLTab("SD1")+" INNER JOIN "+retSQLTab("SF4")+" ON F4_FILIAL = ' "+FWxFilial("SF4")+"' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D1_FILIAL = SB2.B2_FILIAL AND D1_COD = SB2.B2_COD AND D1_LOCAL = SB2.B2_LOCAL AND D1_DTDIGIT >= '"+dToS(dDataDigDe)+"' AND D1_DTDIGIT <= '"+dToS(dDataDigAt)+"' AND D1_TIPO <> 'D' AND F4_TRANFIL <> '1' AND SD1.D_E_L_E_T_ = ' '),0) AS CUST_COMPRAS" + CRLF	
	cQuery	+= "		,ISNULL((SELECT SUM(D2_QUANT)  FROM "+retSQLTab("SD2")+" INNER JOIN "+retSQLTab("SF4")+" ON F4_FILIAL = ' "+FWxFilial("SF4")+"' AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D2_FILIAL = SB2.B2_FILIAL AND D2_COD = SB2.B2_COD AND D2_LOCAL = SB2.B2_LOCAL AND D2_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D2_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D2_TIPO <> 'D' AND F4_TRANFIL <> '1' AND SD2.D_E_L_E_T_ = ' '),0) AS QTD_VENDAS" + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D2_CUSTO"+cValToChar(nMoeda)+") FROM "+retSQLTab("SD2")+" INNER JOIN "+retSQLTab("SF4")+" ON F4_FILIAL = ' "+FWxFilial("SF4")+"' AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D2_FILIAL = SB2.B2_FILIAL AND D2_COD = SB2.B2_COD AND D2_LOCAL = SB2.B2_LOCAL AND D2_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D2_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D2_TIPO <> 'D' AND F4_TRANFIL <> '1' AND SD2.D_E_L_E_T_ = ' '),0) AS CUST_VENDAS" + CRLF	
	cQuery	+= "		,ISNULL((SELECT SUM(D1_QUANT)  FROM "+retSQLTab("SD1")+" INNER JOIN "+retSQLTab("SF4")+" ON F4_FILIAL = ' "+FWxFilial("SF4")+"' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D1_FILIAL = SB2.B2_FILIAL AND D1_COD = SB2.B2_COD AND D1_LOCAL = SB2.B2_LOCAL AND D1_DTDIGIT >= '"+dToS(dDataDigDe)+"' AND D1_DTDIGIT <= '"+dToS(dDataDigAt)+"' AND D1_TIPO = 'D' AND SD1.D_E_L_E_T_ = ' '),0) AS QTD_DEV_VENDAS"  + CRLF	
	cQuery	+= "		,ISNULL((SELECT SUM(D1_CUSTO"+iif(nMoeda>1,cValToChar(nMoeda),"")+")  FROM "+retSQLTab("SD1")+" INNER JOIN "+retSQLTab("SF4")+" ON F4_FILIAL = ' "+FWxFilial("SF4")+"' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D1_FILIAL = SB2.B2_FILIAL AND D1_COD = SB2.B2_COD AND D1_LOCAL = SB2.B2_LOCAL AND D1_DTDIGIT >= '"+dToS(dDataDigDe)+"' AND D1_DTDIGIT <= '"+dToS(dDataDigAt)+"' AND D1_TIPO = 'D' AND SD1.D_E_L_E_T_ = ' '),0) AS CUST_VEND_DEV"  + CRLF	
	cQuery	+= "		,ISNULL((SELECT SUM(D2_QUANT)  FROM "+retSQLTab("SD2")+" INNER JOIN "+retSQLTab("SF4")+" ON F4_FILIAL = ' "+FWxFilial("SF4")+"' AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D2_FILIAL = SB2.B2_FILIAL AND D2_COD = SB2.B2_COD AND D2_LOCAL = SB2.B2_LOCAL AND D2_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D2_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D2_TIPO = 'D' AND SD2.D_E_L_E_T_ = ' '),0) AS QTD_DEV_COMPRAS"  + CRLF	
	cQuery	+= "		,ISNULL((SELECT SUM(D2_CUSTO"+cValToChar(nMoeda)+") FROM "+retSQLTab("SD2")+" INNER JOIN "+retSQLTab("SF4")+" ON F4_FILIAL = ' "+FWxFilial("SF4")+"' AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D2_FILIAL = SB2.B2_FILIAL AND D2_COD = SB2.B2_COD AND D2_LOCAL = SB2.B2_LOCAL AND D2_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D2_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D2_TIPO = 'D' AND SD2.D_E_L_E_T_ = ' '),0) AS CUST_COMP_DEV"  + CRLF	
	cQuery	+= "		,ISNULL((SELECT SUM(D1_QUANT)  FROM "+retSQLTab("SD1")+" INNER JOIN "+retSQLTab("SF4")+" ON F4_FILIAL = ' "+FWxFilial("SF4")+"' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D1_FILIAL = SB2.B2_FILIAL AND D1_COD = SB2.B2_COD AND D1_LOCAL = SB2.B2_LOCAL AND D1_DTDIGIT >= '"+dToS(dDataDigDe)+"' AND D1_DTDIGIT <= '"+dToS(dDataDigAt)+"' AND F4_TRANFIL = '1' AND SD1.D_E_L_E_T_ = ' '),0) AS QTD_TRF_ENTRAD"  + CRLF	
	cQuery	+= "		,ISNULL((SELECT SUM(D1_CUSTO"+iif(nMoeda>1,cValToChar(nMoeda),"")+")  FROM "+retSQLTab("SD1")+" INNER JOIN "+retSQLTab("SF4")+" ON F4_FILIAL = ' "+FWxFilial("SF4")+"' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D1_FILIAL = SB2.B2_FILIAL AND D1_COD = SB2.B2_COD AND D1_LOCAL = SB2.B2_LOCAL AND D1_DTDIGIT >= '"+dToS(dDataDigDe)+"' AND D1_DTDIGIT <= '"+dToS(dDataDigAt)+"' AND F4_TRANFIL = '1' AND SD1.D_E_L_E_T_ = ' '),0) AS CUST_TRF_ENTRAD"  + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D2_QUANT)  FROM "+retSQLTab("SD2")+" INNER JOIN "+retSQLTab("SF4")+" ON F4_FILIAL = ' "+FWxFilial("SF4")+"' AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D2_FILIAL = SB2.B2_FILIAL AND D2_COD = SB2.B2_COD AND D2_LOCAL = SB2.B2_LOCAL AND D2_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D2_EMISSAO <= '"+dToS(dDataDigAt)+"' AND F4_TRANFIL = '1' AND SD2.D_E_L_E_T_ = ' '),0) AS QTD_TRF_SAIDA"  + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D2_CUSTO"+cValToChar(nMoeda)+") FROM "+retSQLTab("SD2")+" INNER JOIN "+retSQLTab("SF4")+" ON F4_FILIAL = ' "+FWxFilial("SF4")+"' AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D2_FILIAL = SB2.B2_FILIAL AND D2_COD = SB2.B2_COD AND D2_LOCAL = SB2.B2_LOCAL AND D2_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D2_EMISSAO <= '"+dToS(dDataDigAt)+"' AND F4_TRANFIL = '1' AND SD2.D_E_L_E_T_ = ' '),0) AS CUST_TRF_SAIDA"  + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D3_QUANT)  FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM <= '499' AND D3_CF =  'PR0' AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS QTD_PRODUCAO"   + CRLF	
	cQuery	+= "		,ISNULL((SELECT SUM(D3_CUSTO"+cValToChar(nMoeda)+") FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM <= '499' AND D3_CF =  'PR0' AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS CUSTO_PRODUCAO"   + CRLF	
	cQuery	+= "		,ISNULL((SELECT SUM(D3_QUANT)  FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM >= '500' AND D3_CF <> 'PR0' AND D3_OP <> ' ' AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS QTD_REQ_PROD"   + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D3_CUSTO"+cValToChar(nMoeda)+") FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM >= '500' AND D3_CF <> 'PR0' AND D3_OP <> ' ' AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS CUST_REQ_PROD"   + CRLF			
	cQuery	+= "		,ISNULL((SELECT SUM(D3_QUANT)  FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM = '499' AND D3_CF = 'DE0' AND D3_DOC = 'INVENT' AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS QTD_INV_ENTRADA" + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D3_CUSTO"+cValToChar(nMoeda)+") FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM = '499' AND D3_CF = 'DE0' AND D3_DOC = 'INVENT' AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS CUST_INV_ENTRA" + CRLF			
	cQuery	+= "		,ISNULL((SELECT SUM(D3_QUANT)  FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM = '999' AND D3_CF = 'RE0' AND D3_DOC = 'INVENT' AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS QTD_INV_SAIDA" + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D3_CUSTO"+cValToChar(nMoeda)+") FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM = '999' AND D3_CF = 'RE0' AND D3_DOC = 'INVENT' AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS CUST_INV_SAIDA" + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D3_QUANT)  FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM < '499' AND D3_TM <> '011' AND ((D3_CF <> 'PR0') AND (D3_CF <> 'DE4') AND (D3_CF <> 'DE0' AND D3_TM <> '499' AND D3_DOC <> 'INVENT'))  AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS QTD_MOVI_ENTRADA" + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D3_CUSTO"+cValToChar(nMoeda)+") FROM "+retSQLTab("SD3")+" INNER JOIN "+retSQLTab("SF5")+ " ON D3_TM = F5_CODIGO WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND F5_TIPO = 'D' AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM < '499' AND D3_TM <> '011' AND ((D3_CF <> 'PR0') OR (D3_CF <> 'DE4') AND (D3_CF <> 'DE0' AND D3_TM <> '499' AND D3_DOC <> 'INVENT'))  AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS CUST_MV_ENTRADA" + CRLF
	
	cQuery	+= "		,ISNULL((SELECT SUM(D3_QUANT)  FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM = '499'  AND (D3_CF = 'DE4' AND D3_DOC <> 'INVENT') AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS  QTD_MV_E_T " + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D3_CUSTO"+cValToChar(nMoeda)+") FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM = '499'  AND (D3_CF = 'DE4' AND D3_DOC <> 'INVENT') AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS CST_MV_E_T " + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D3_QUANT)  FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM = '011'  AND ((D3_CF <> 'PR0') OR (D3_CF <> 'DE0' AND D3_TM <> '499' AND D3_DOC <> 'INVENT'))  AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS QTD_NASCIMENTO " + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D3_CUSTO"+cValToChar(nMoeda)+") FROM "+retSQLTab("SD3")+" INNER JOIN "+retSQLTab("SF5")+ " ON D3_TM = F5_CODIGO WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND F5_TIPO = 'D' AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM = '011'  AND ((D3_CF <> 'PR0') OR (D3_CF <> 'DE0' AND D3_TM <> '499' AND D3_DOC <> 'INVENT'))  AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS CUST_MV_NASCIMENTO " + CRLF			
	cQuery	+= "		,ISNULL((SELECT SUM(D3_QUANT)  FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND (D3_TM >= '500' AND D3_TM <> '511' AND D3_TM <> '999') AND ((D3_OP= '') OR D3_CF <> 'RE4' AND D3_DOC <> 'INVENT') AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS QTD_MOVI_SAIDA " + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D3_CUSTO"+cValToChar(nMoeda)+") FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND (D3_TM >= '500' AND D3_TM <> '511' AND D3_TM <> '999') AND (D3_CF <> 'RE4' AND D3_DOC <> 'INVENT')  AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS CUST_MV_SAIDA " + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D3_QUANT)  FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND (D3_TM = '999') AND ((D3_OP= '') AND (D3_CF = 'RE4' AND D3_DOC <> 'INVENT'))  AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS QTD_MV_S_TR " + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D3_CUSTO"+cValToChar(nMoeda)+") FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND (D3_TM = '999') AND ((D3_OP= '') AND (D3_CF = 'RE4' AND D3_DOC <> 'INVENT'))  AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS CST_MV_S_TR " + CRLF			
	cQuery	+= "		,ISNULL((SELECT SUM(D3_QUANT)  FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM = '511' AND D3_CF = 'RE0' AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS QTD_MORTE" + CRLF
	cQuery	+= "		,ISNULL((SELECT SUM(D3_CUSTO"+cValToChar(nMoeda)+") FROM "+retSQLTab("SD3")+" WHERE D3_FILIAL = SB2.B2_FILIAL AND D3_COD = SB2.B2_COD AND D3_LOCAL = SB2.B2_LOCAL AND D3_EMISSAO >= '"+dToS(dDataDigDe)+"' AND D3_EMISSAO <= '"+dToS(dDataDigAt)+"' AND D3_TM = '511' AND D3_CF = 'RE0'  AND D3_ESTORNO <> 'S' AND SD3.D_E_L_E_T_ = ' '),0) AS CUST_MV_MORTE " + CRLF			
	cQuery	+= " 	FROM "+retSQLTab("SB2") +  CRLF 
	cQuery	+= " 	INNER JOIN "+retSQLTab("SB1") +  CRLF
	cQuery	+= " 	ON B1_COD = B2_COD " +  CRLF
	cQuery	+= " 		AND SB1.D_E_L_E_T_ = ' '" +  CRLF
	cQuery	+= " 		AND B1_FILIAL = '"+FWxFilial("SB1")+"'" +  CRLF
	if !empty(allTrim(cTipo))
		cQuery += "    	AND SB1.B1_TIPO IN ("+cTipo+") " +  CRLF
	endIf
			
	cQuery	+= " 	INNER JOIN "+retSQLTab("SBM") +  CRLF
	cQuery	+= " 	ON BM_FILIAL = '" + FWxFilial("SBM") + "'" +  CRLF
	cQuery	+= " 	    AND BM_GRUPO = B1_GRUPO " +  CRLF
   	cQuery  += "    	AND BM_GRUPO >= '"+cGrupoDe+"' " +  CRLF
	cQuery  += "    	AND BM_GRUPO <= '"+cGrupoAte+"'" +  CRLF
	cQuery	+= " 		AND SBM.D_E_L_E_T_ = ' '" +  CRLF
// INCLUSÃO DE INFORMAÇÕES REFERENTE AO PRODUTO DO GRUPO LOTE (INSUMO) SALDO ATUAL (SB2)	
	cQuery	+= " 	LEFT JOIN SB2010 B21 " +  CRLF
	cQuery	+= "    	 ON B21.B2_COD = B1_XLOTE" +  CRLF
	cQuery	+= " 		AND B21.D_E_L_E_T_ = ' ' " +  CRLF
	cQuery	+= " 	WHERE SB2.D_E_L_E_T_ = ' '" +  CRLF
   	cQuery	+= " 		AND SB2.B2_COD >= '"+cProdDe+"'"  +  CRLF
   	cQuery	+= " 		AND SB2.B2_COD <= '"+cProdAte+"'" +  CRLF
//   	cQuery	+= " 		AND SB2.B2_FILIAL = '"+FWxFilial("SB2")+"' " +  CRLF
   	cQuery	+= " 		AND SB2.B2_FILIAL >= '"+cFiliDe+"' " +  CRLF
   	cQuery	+= " 		AND SB2.B2_FILIAL <= '"+cFiliAte+"' " +  CRLF
   	cQuery  += "    	AND SB2.B2_LOCAL  >= '"+cLocalDe+"' " +  CRLF
	cQuery  += "    	AND SB2.B2_LOCAL  <= '"+cLocalAte+"'" +  CRLF
	
	cQuery  += " 	) AS TABELA " +  CRLF
	cQuery  += " GROUP BY B2_FILIAL, B2_COD,B1_DESC,B1_XLOTE, B1_X_CURRA, INSUMO, B2_QATU, B2_VATU1, B1_UM, B1_TIPO, B2_LOCAL " +  CRLF
	cQuery  += " ORDER BY B2_COD, B2_LOCAL" +  CRLF
	
	MEMOWRITE("C:\TOTVS\VAESTR05.TXT", cQuery)

	cQuery:=ChangeQuery(cQuery)
	
//	TCQUERY cQuery NEW ALIAS &cAlias
	TCQUERY cQuery NEW ALIAS &cAlias
	
	COUNT to nCount
	 
	ProcRegua(nCount)
	
	nSeq1 := 0
	nSeq2 := 0	
	
	(cAlias)->(dbGoTop())
	
	while !(cAlias)->(eof())
		
		IncProc()

		cQrySB2 := ""
		cQrySB2	+= " 	SELECT B2_FILIAL, B2_COD, B2_LOCAL, R_E_C_N_O_ " +  CRLF
		cQrySB2	+= " 	FROM "+ retSqlName("SB2") + " SB2 " +  CRLF
		cQrySB2	+= " 	WHERE SB2.D_E_L_E_T_ = ' '" +  CRLF
	   	cQrySB2	+= " 		AND B2_FILIAL = '"+(cAlias)->B2_FILIAL+"'"  +  CRLF
	   	cQrySB2	+= " 		AND B2_COD = '"+(cAlias)->B2_COD+"'"  +  CRLF
	   	cQrySB2 += "    	AND B2_LOCAL  = '"+(cAlias)->B2_LOCAL+"' " +  CRLF
	
		If select("QRYSB2") > 0
			QRYSB2->(DbCloseArea())
		EndIf
		TCQUERY cQrySB2 NEW ALIAS QRYSB2
	
		nSaldoIni := 0 
		nCustoIni := 0
		cfilBkp		:= cFilAnt
		While !QRYSB2->(EOF())
		// SETAR FILIAL ****
			cFilAnt := QRYSB2->B2_FILIAL
			aSaldos:=CalcEst(QRYSB2->B2_COD,QRYSB2->B2_LOCAL, dDataDigDe)		
			nSaldoIni += aSaldos[1]  // QUANTIDADE	
			nCustoIni += aSaldos[2]  // CUSTO NA MOEDA 1	 	
			QRYSB2->(dbSkip())
		EndDo
		cFilAnt	:= cfilBkp 
		
//		nSaldoFin := (cAlias)->SALDO_INI + (cAlias)->QTD_COMPRAS + (cAlias)->QTD_TRF_ENTRAD + (cAlias)->QTD_DEV_VENDAS;
		nSaldoFin := nSaldoIni + (cAlias)->QTD_COMPRAS + (cAlias)->QTD_TRF_ENTRAD + (cAlias)->QTD_DEV_VENDAS;
		 								 + (cAlias)->QTD_PRODUCAO + (cAlias)->QTD_INV_ENTRADA + (cAlias)->QTD_MOVI_ENTRADA;
		 								 + (cAlias)->QTD_NASCIMENTO + (cAlias)->QTD_MV_E_T;
		 								 - (cAlias)->QTD_VENDAS - (cAlias)->QTD_TRF_SAIDA - (cAlias)->QTD_DEV_COMPRAS;
		 								 - (cAlias)->QTD_REQ_PROD - (cAlias)->QTD_INV_SAIDA - (cAlias)->QTD_MOVI_SAIDA;
		 								 - (cAlias)->QTD_MORTE - (cAlias)->QTD_MV_S_TR;
		 								 
//		nCustoFin := (cAlias)->CUSTO_INI + (cAlias)->CUSTO_COMPRAS + (cAlias)->CUST_TRF_ENTRAD + (cAlias)->CUST_VEND_DEV;
		nCustoFin := nCustoIni + (cAlias)->CUSTO_COMPRAS + (cAlias)->CUST_TRF_ENTRAD + (cAlias)->CUST_VEND_DEV;
		 								 + (cAlias)->CUSTO_PRODUCAO + (cAlias)->CUST_INV_ENTRA + (cAlias)->CUST_MV_ENTRADA;
		 								 + (cAlias)->CUST_MV_NASCIMENTO + (cAlias)->CST_MV_E_T;
		 								 - (cAlias)->CUSTO_VENDAS - (cAlias)->CUST_TRF_SAIDA - (cAlias)->CUST_COMP_DEV;
		 								 - (cAlias)->CUST_REQ_PROD - (cAlias)->CUST_INV_SAIDA - (cAlias)->CUST_MV_SAIDA;
		 								 - (cAlias)->CUST_MV_MORTE - (cAlias)->CST_MV_S_TR;
		 
		If (nSaldoIni == 0 .and. (cAlias)->QTD_COMPRAS == 0 .and. (cAlias)->QTD_TRF_ENTRAD == 0 .and.  (cAlias)->QTD_DEV_VENDAS == 0 .and.;
		 								  (cAlias)->QTD_PRODUCAO == 0 .and.  (cAlias)->QTD_INV_ENTRADA == 0 .and.  (cAlias)->QTD_MOVI_ENTRADA == 0 .and.;
		 								  (cAlias)->QTD_NASCIMENTO == 0 .and.  (cAlias)->QTD_MV_E_T == 0 .and.;
		 								  (cAlias)->QTD_VENDAS == 0 .and. (cAlias)->QTD_TRF_SAIDA == 0 .and. (cAlias)->QTD_DEV_COMPRAS == 0 .and.;
		 								  (cAlias)->QTD_REQ_PROD == 0 .and.  (cAlias)->QTD_INV_SAIDA == 0 .and.  (cAlias)->QTD_MOVI_SAIDA == 0 .and.;
		 								  (cAlias)->QTD_MORTE == 0 .and. (cAlias)->QTD_MV_S_TR == 0)
			cSitua := "SEM MOV"
		Else
			cSitua := "NORMAL"
		EndIf
//		If alltrim( (cAlias)->B1_TIPO ) $ 'PP/PI/PA'
//			aProp := fProporcaoM ( (cAlias)->B2_COD, (cAlias)->CUSTO_PRODUCAO, (cAlias)->QTD_PRODUCAO )		
//		Endif  
		
	nExibeC		:= MV_PAR13
	If nExibeC = 2	// exibe sem custo
		aadd(aRet,{(cAlias)->B2_FILIAL,(cAlias)->B2_COD,(cAlias)->B1_DESC,;//(cAlias)->B1_XLOTE,(cAlias)->B1_X_CURRA, (cAlias)->INSUMO,
		(cAlias)->B2_QATU,(cAlias)->B2_VATU1,(cAlias)->B2_LOCAL,(cAlias)->B1_UM,(cAlias)->B1_TIPO,;
					nSaldoIni,;
					(cAlias)->QTD_COMPRAS,;
					(cAlias)->QTD_TRF_ENTRAD,;
					(cAlias)->QTD_DEV_VENDAS,;
					(cAlias)->QTD_PRODUCAO,;
					(cAlias)->QTD_MOVI_ENTRADA,;
					(cAlias)->QTD_MV_E_T,;
					(cAlias)->QTD_NASCIMENTO,;
					(cAlias)->QTD_INV_ENTRADA,;
					(cAlias)->QTD_VENDAS,;
					(cAlias)->QTD_TRF_SAIDA,;
					(cAlias)->QTD_DEV_COMPRAS,;
					(cAlias)->QTD_REQ_PROD,;
					(cAlias)->QTD_MOVI_SAIDA,;
					(cAlias)->QTD_MV_S_TR,;
					(cAlias)->QTD_MORTE,;
					(cAlias)->QTD_INV_SAIDA,;
					nSaldoFin,;
					cSitua})

	Else // Exibe com Custo
		aadd(aRet,{(cAlias)->B2_FILIAL,(cAlias)->B2_COD,(cAlias)->B1_DESC,;//(cAlias)->B1_XLOTE, (cAlias)->B1_X_CURRA,(cAlias)->INSUMO,
		(cAlias)->B2_QATU,(cAlias)->B2_VATU1,(cAlias)->B2_LOCAL,(cAlias)->B1_UM,(cAlias)->B1_TIPO,;
					nSaldoIni,nCustoIni,;
					(cAlias)->QTD_COMPRAS,(cAlias)->CUSTO_COMPRAS,;
					(cAlias)->QTD_TRF_ENTRAD,(cAlias)->CUST_TRF_ENTRAD,;
					(cAlias)->QTD_DEV_VENDAS,(cAlias)->CUST_VEND_DEV,;
					(cAlias)->QTD_PRODUCAO,(cAlias)->CUSTO_PRODUCAO,;
					(cAlias)->QTD_MOVI_ENTRADA,(cAlias)->CUST_MV_ENTRADA,;
					(cAlias)->QTD_MV_E_T,(cAlias)->CST_MV_E_T,;
					(cAlias)->QTD_NASCIMENTO,(cAlias)->QTD_MORTE,;
					(cAlias)->QTD_INV_ENTRADA,(cAlias)->CUST_INV_ENTRA,;
					(cAlias)->QTD_VENDAS,(cAlias)->CUSTO_VENDAS,;
					(cAlias)->QTD_TRF_SAIDA,(cAlias)->CUST_TRF_SAIDA,;
					(cAlias)->QTD_DEV_COMPRAS,(cAlias)->CUST_COMP_DEV,;
					(cAlias)->QTD_REQ_PROD,(cAlias)->CUST_REQ_PROD,;
					(cAlias)->QTD_MOVI_SAIDA,(cAlias)->CUST_MV_SAIDA,;
					(cAlias)->QTD_MV_S_TR,(cAlias)->CST_MV_S_TR,;
					(cAlias)->QTD_MORTE,(cAlias)->CUST_MV_MORTE,;
					(cAlias)->QTD_INV_SAIDA,(cAlias)->CUST_INV_SAIDA,;
					nSaldoFin,nCustoFin,;
					cSitua})

	Endif
		
		(cAlias)->(dbSkip())
	end
	
	(cAlias)->(dbCloseArea())
			
return aRet
/* Igor Oliveira 01/02/2023
	PARAMBOX descontinuado pela TOTVS.
*/
/* Static Function perg(cPerg)
	Local aParBox 	:= {}
	Local cPerg		:= PadR(cPerg,Len(SX1->X1_GRUPO))
	Local aMoeda	:= {"1=1a Moeda","2=2a Moeda","S","4=4a Moeda","5=5a Moeda"}
	Local aExibCus	:= {"1=Exibe","2=Oculta"}
		
	AADD(aParBox,{1,"Do Armazém"					,SPACE(04)						,"@!"				,""					,""		,""											,050,.F.})	// MV_PAR01
	AADD(aParBox,{1,"Ate o Armazém"					,SPACE(04)						,"@!"				,""					,""		,""											,050,.T.})	// MV_PAR02
	AADD(aParBox,{1,"Tipo"							,SPACE(30)						,"@!"				,""					,""		,""											,050,.F.})	// MV_PAR03
	AADD(aParBox,{1,"Do Produto"					,SPACE(tamSX3("B1_COD")[1])		,"@!"				,""					,"SB1"	,""											,050,.F.})	// MV_PAR04
	AADD(aParBox,{1,"Ate o Produto"					,SPACE(tamSX3("B1_COD")[1])		,"@!"				,""					,"SB1"	,""											,050,.T.})	// MV_PAR05
	AADD(aParBox,{1,"Da Data de Emissão"			,dDataBase						,""					,""					,""		,""											,050,.T.})	// MV_PAR06
	AADD(aParBox,{1,"Ate a Data de Emissão"			,dDataBase						,""					,""					,""		,""											,050,.T.})	// MV_PAR07
	AADD(aParBox,{2,"Moeda"							,"1a Moeda"						,aMoeda,50,"",.F.})	// MV_PAR08
	AADD(aParBox,{1,"Do Grupo" 					    ,SPACE(04)						,"@!"				,""					,"SBM"		,""											,050,.F.})	// MV_PAR09
	AADD(aParBox,{1,"Ate o Grupo"					,SPACE(04)						,"@!"				,""					,"SBM"		,""											,050,.T.})	// MV_PAR10
	AADD(aParBox,{1,"Da Filial" 					,SPACE(TamSX3("D3_FILIAL")[1])	,"@!"				,""					,"SM0"		,""											,050,.F.})	// MV_PAR11
	AADD(aParBox,{1,"Ate a Filial"					,SPACE(TamSX3("D3_FILIAL")[1])	,"@!"				,""					,"SM0"		,""											,050,.T.})	// MV_PAR12
	AADD(aParBox,{2,"Exibe Custo"					,"Exibe",aExibCus,50,"",.F.})	// MV_PAR13
Return ParamBox(aParBox,cPerg,,,,,,,,cPerg,.T.,.T.) */

Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local i := 0, j := 0

//Conta quantas perguntas existem ualmente.
DbSelectArea('SX1')
DbSetOrder(1)
SX1->(DbGoTop())
If SX1->(DbSeek(cPerg))
	While !SX1->(Eof()) .And. X1_GRUPO = cPerg
		nPergs++
		SX1->(DbSkip())
	EndDo
EndIf

aAdd(aRegs,{cPerg, "01", "Do Armazém"				, "", "", "MV_CH1"	, "C", 04						, 0, 0, "G", "", "MV_PAR01", ""				, "","","",""		,""				,"","","","",""	,"","","","",""				,"","","","",""				,"","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Ate o Armazém"			, "", "", "MV_CH2"	, "C", 04						, 0, 0, "G", "", "MV_PAR02", ""				, "","","",""		,""				,"","","","",""	,"","","","",""				,"","","","",""				,"","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "03", "Tipo"						, "", "", "MV_CH3"	, "C", 30						, 0, 0, "G", "", "MV_PAR03", ""				, "","","",""		,""				,"","","","",""	,"","","","",""				,"","","","",""				,"","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "04", "Do Produto"				, "", "", "MV_CH4"	, "C", tamSX3("B1_COD")[1]		, 0, 0, "G", "", "MV_PAR04", ""				, "","","",""		,""				,"","","","",""	,"","","","",""				,"","","","",""				,"","","","SB1","","","","",""})
aAdd(aRegs,{cPerg, "05", "Ate o Produto"			, "", "", "MV_CH5"	, "C", tamSX3("B1_COD")[1]		, 0, 0, "G", "", "MV_PAR05", ""				, "","","",""		,""				,"","","","",""	,"","","","",""				,"","","","",""				,"","","","SB1","","","","",""})
aAdd(aRegs,{cPerg, "06", "Da Data de Emissão"		, "", "", "MV_CH6"	, "D", 08						, 0, 0, "G", "", "MV_PAR06", ""				, "","","",dDataBase,""				,"","","","",""	,"","","","",""				,"","","","",""				,"","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "07", "Ate a Data de Emissão?"	, "", "", "MV_CH7"	, "D", 08						, 0, 0, "G", "", "MV_PAR07", ""				, "","","",dDataBase,""				,"","","","",""	,"","","","",""				,"","","","",""				,"","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "08", "Moeda"					, "", "", "MV_CH8"	, "C", 01						, 0, 0, "C", "", "MV_PAR08", "1=1a Moeda"	, "","","","1"		,"2=2a Moeda"	,"","","","","S","","","","","4=4a Moeda"	,"","","","","5=5a Moeda"	,"","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "09", "Do Grupo"					, "", "", "MV_CH9"	, "C", 04						, 0, 0, "G", "", "MV_PAR09", ""				, "","","",""		,""				,"","","","",""	,"","","","",""				,"","","","",""				,"","","","SBM","","","","",""})
aAdd(aRegs,{cPerg, "10", "Ate o Grupo"				, "", "", "MV_CH10"	, "C", 04						, 0, 0, "G", "", "MV_PAR10", ""				, "","","",""		,""				,"","","","",""	,"","","","",""				,"","","","",""				,"","","","SBM","","","","",""})
aAdd(aRegs,{cPerg, "11", "Da Filial"				, "", "", "MV_CH11"	, "C", TamSX3("D3_FILIAL")[1]	, 0, 0, "G", "", "MV_PAR11", ""				, "","","",""		,""				,"","","","",""	,"","","","",""				,"","","","",""				,"","","","SM0","","","","",""})
aAdd(aRegs,{cPerg, "12", "Ate a Filial"				, "", "", "MV_CH12"	, "C", TamSX3("D3_FILIAL")[1]	, 0, 0, "G", "", "MV_PAR12", ""				, "","","",""		,""				,"","","","",""	,"","","","",""				,"","","","",""				,"","","","SM0","","","","",""})
aAdd(aRegs,{cPerg, "13", "Exibe Custo"				, "", "", "MV_CH13"	, "C", 01						, 0, 0, "C", "", "MV_PAR13", "1=Exibe"		, "","","","1"		,"2=Oculta"		,"","","","",""	,"","","","",""				,"","","","",""				,"","","","   ","","","","",""})
//aAdd(aRegs,{cPerg, "14", "Close"				, "", "", "MV_CH14"	, "C", 01						, 0, 0, "C", "", "MV_PAR14", "1=Exibe"		, "","","","","2=Oculta"	,"","","","",""	,"","","","",""				,"","","","",""				,"","","","   ","","","","",""})

//Se quantidade de perguntas for diferente, apago todas
SX1->(DbGoTop())
If nPergs <> Len(aRegs)
	For nX:=1 To nPergs
		If SX1->(DbSeek(cPerg))		
			If RecLock('SX1',.F.)
				SX1->(DbDelete())
				SX1->(MsUnlock())
			EndIf
		EndIf
	Next nX
EndIf

// gravação das perguntas na tabela SX1
If nPergs <> Len(aRegs)
	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
				For j := 1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next j
			MsUnlock()
		EndIf
	Next i
EndIf

RestArea(_aArea)
Return nil
//

Static Function fProporcaoM ( cCodigo, nCustoProd, nQuantidade )

	Local aArea := getArea()
	Local nI := 0
	aTotais := {0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	aPTotais:= {0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	nTotal  := 0
	nPTotal := 0

	cCod := ""
	cCom := ""
	aRec := array(200)
	aPos := array(200)
	aQua := array(200)
	aCom := array(200)
	aRev := array(200)
	aSeq1:= array(200)
	aSeq2:= array(200)

	nNiv := 0
	nC   := 0

	dbSelectArea( "SG1" )
	dbsetorder(1)	

	cCod := cCodigo
	nQua := nQuantidade
	nOri := nQuantidade
	nSeq1++
	nSeq2:= 1
					
	fRecEstr( )

	For nI := 1 to len(aTotais)	
		nTotal += aTotais [nI]
	Next					

	For nI := 1 to len(aTotais)
		aPTotais [nI] := round(aTotais [nI] * 100 / nTotal, 2)
	Next	

	For nI := 1 to len(aPTotais)
		nPTotal += aPTotais [nI]
	Next	

	aPTotais [1] += (100 - nPTotal) 

	RestArea ( aArea )

Return aPTotais

Static Function fRecEstr( )

	dbSelectArea( "SB1" )
	dbseek(FWxFilial('SB1') + cCod, .T.)

	cRev := SB1->B1_REVATU
		
	dbSelectArea("SG1")
	dbSetOrder(1)
	dbseek(FWxFilial("SG1") + cCod, .T.)

	nNiv++

	Do while alltrim(cCod) == alltrim(SG1->G1_COD)

		If ( dDatabase >= SG1->G1_INI .and. dDatabase <= SG1->G1_FIM )

		If ( cRev >= SG1->G1_REVINI .and. cRev <= SG1->G1_REVFIM )

			If empty(SG1->G1_GROPC) .or. (!empty(SG1->G1_GROPC).and.val(SG1->G1_OPC) == 1)		
			
				//cCom := '' fEstrut(SG1->G1_COMP)
				cCom := SG1->G1_COMP		
				//Registra os consumos
				dbSelectArea('SB1')
				dbSetOrder(1)
				dbSeek(FWxFilial('SB1') + padr(cCom,tamsx3('B1_COD')[1]))
							
				dbSelectArea('SB2')
				dbSetOrder(1)
				dbSeek(FWxFilial('SB2') + padr(cCom,tamsx3('B2_COD')[1]) + SB1->B1_LOCPAD)

				nValCusto := nQua * SG1->G1_QUANT * SB2->B2_CM1
							
				If     alltrim(SB1->B1_TIPO) == 'MP'
					aTotais[1] += nValCusto 
				ElseIf alltrim(SB1->B1_TIPO) == 'ME'
					aTotais[2] += nValCusto 
				ElseIf alltrim(SB1->B1_TIPO) == 'EM'
					aTotais[3] += nValCusto 
				ElseIf alltrim(SB1->B1_TIPO) == 'MO'
					If     alltrim(cCom) == '027740'
						aTotais[4] += nValCusto
					ElseIf alltrim(cCom) == '027741'
						aTotais[5] += nValCusto
					ElseIf alltrim(cCom) == '027742'
						aTotais[6] += nValCusto
					ElseIf alltrim(cCom) == '027743'
						aTotais[7] += nValCusto
					ElseIf alltrim(cCom) == '028079'
						aTotais[8] += nValCusto				
					ElseIf alltrim(cCom) == '028080'
						aTotais[9] += nValCusto				
					ElseIf alltrim(cCom) == '028081'
						aTotais[10]+= nValCusto				
					ElseIf alltrim(cCom) == '028082'
						aTotais[11]+= nValCusto				
					Else
						aTotais[12]+= nValCusto
					Endif	 	
				ElseIf alltrim(SB1->B1_TIPO) == 'GG'
					aTotais[13] += nValCusto
				ElseIf alltrim(SB1->B1_TIPO) $ 'PI/PP/PA'

					dbSelectArea("SG1")
					dbSetOrder(1)
			
					aRec[nNiv] := recno() 
					aPos[nNiv] := cCod
					aQua[nNiv] := nQua
					aCom[nNiv] := cCom 
					aRev[nNiv] := cRev 
			
					aSeq1[nNiv]:= nSeq1 
					aSeq2[nNiv]:= nSeq2
							
					cCom       := '' 
					cCod       := alltrim(SG1->G1_COMP)
					nOri       := nQua
					nEst       := SG1->G1_QUANT
					nQua       := nQua * SG1->G1_QUANT 
					nSeq2++
					
					fRecEstr() 
					
					dbSelectArea("SG1")
					dbSetOrder(1)
					dbgoto(aRec[nNiv])
					
					cCod := aPos[nNiv]
					nQua := aQua[nNiv]
					cCom := aCom[nNiv]   
					cRev := aRev[nNiv] 
			
					nSeq1:= aSeq1[nNiv]
					nSeq2:= aSeq2[nNiv]
						
				Else
					aTotais[14] += nValCusto 	
				Endif
			
			Endif
			
		Endif
		
		Endif

		dbSelectArea('SG1')
		dbskip()
		
	Enddo

	nNiv--

Return


