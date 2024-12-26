#INCLUDE "TOPCONN.CH"
#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"


#DEFINE CRLF Chr(13) + Chr(10)


User Function VAESTR03()

	local aArea	:= getArea()
	local cPerg := "VAESTR03"
			
	//apresentando o grupo de perguntas.
	lContinua := perg(cPerg)
	
	//se clicou no botão sair na tela de perguntas.
	if !lContinua
		alert("Operação cancelada pelo usuário.")	
		return 
	endIf
	
	Processa({|| executar()},"Imprimindo..." )
		
	restArea(aArea)
	
Return

Static Function executar()
	Local aCabec		:= {}
	Local aDados		:= {}
	Local cTitulo		:= "Resumo de E/S por Produtos"
	Private nExibeC	:= 0

	nExibeC		:= val(MV_PAR13)
	If nExibeC = 2	// exibe sem custo
		aCabec 	:= {"Filial",;
					"Produto",;					//01
					"Descrição",;				//02	
					"Lote",;
					"Curral",;
					"Armazém",;
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
					}

	Else // Exibe com Custo
		aCabec 	:= {"Filial",;
					"Produto",;					//01
					"Descrição",;				//02	
					"Lote",;
					"Curral",;
					"Armazém",;
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
					"C - Req.Produção",;	//26
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
	nMoeda		:= val(MV_PAR08)
	cGrupoDe	:= MV_PAR09
	cGrupoAte	:= MV_PAR10
	cFiliDe		:= MV_PAR11
	cFiliAte	:= MV_PAR12
	nExibeC		:= val(MV_PAR03)
	dDataAnt 	:= dDataDigDe //MonthSub(dDataDigDe, 1)
	dDataAnt 	:= dDataDigDe //LastDay(dDataAnt)
	
cQuery := "with parametros as (" +  CRLF
cQuery += "	select  " +  CRLF
cQuery += "	  '"+alltrim(GetMv("MV_RASTRO"))+"' mv_rastro " +  CRLF
cQuery += ") " +  CRLF
	
cQuery += ", produtos as (" +  CRLF
cQuery += "	select ISNULL(SB8.R_E_C_N_O_,SB1.R_E_C_N_O_) ID, ISNULL(B8_FILIAL,B1_FILIAL) B8_FILIAL, B1_COD, B1_DESC, ISNULL(B8_LOTECTL,'          ') B8_LOTECTL, ISNULL(B8_X_CURRA,'          ') B8_X_CURRA, ISNULL(B8_LOCAL,B1_LOCPAD) B8_LOCAL, B1_UM, B1_TIPO, B1_RASTRO, B1_XLOTE" +  CRLF
cQuery += "	  from "+retSQLName("SB1")+" SB1" +  CRLF
cQuery += "	  left join "+retSQLName("SB8")+" SB8 on (SB8.D_E_L_E_T_=' ' and B8_FILIAL='"+xFilial("SB8")+"' and B8_PRODUTO=B1_COD)" +  CRLF
cQuery += "	 cross join parametros " +  CRLF
cQuery += "	 where SB1.D_E_L_E_T_ = ' ' and SB1.B1_FILIAL = '"+xFilial("SB1")+"'" +  CRLF
cQuery += "	   and B1_GRUPO		between '"+cGrupoDe+"' and '"+cGrupoAte+"'" +  CRLF
cQuery += "	   and B1_COD		between '"+cProdDe+"' and '"+cProdAte+"'" +  CRLF
cQuery += "	   and B8_FILIAL	between '"+cFiliDe+"' and '"+cFiliAte+"' " +  CRLF
cQuery += "	   and B8_LOCAL		between '"+cLocalDe+"' and '"+cLocalAte+"'" +  CRLF
cQuery += "    and B1_RASTRO in ('L','S') and mv_rastro='S' " +  CRLF
if !empty(allTrim(cTipo))
	cQuery += "    	and B1_TIPO IN ("+cTipo+") " +  CRLF
endIf
cQuery += "	 union  " +  CRLF
cQuery += "	select ISNULL(SB2.R_E_C_N_O_,SB1.R_E_C_N_O_) ID, ISNULL(B2_FILIAL,B1_FILIAL) B8_FILIAL, B1_COD, B1_DESC, '          ' B8_LOTECTL, B1_X_CURRA B8_X_CURRA, ISNULL(B2_LOCAL,B1_LOCPAD) B8_LOCAL, B1_UM, B1_TIPO, B1_RASTRO, B1_XLOTE " +  CRLF
cQuery += "	  from SB1010 SB1 " +  CRLF
cQuery += "	  left join SB2010 SB2 on (SB2.D_E_L_E_T_=' ' and B2_FILIAL='01' and B2_COD=B1_COD) " +  CRLF
cQuery += "	 cross join parametros " +  CRLF
cQuery += "	 where SB1.D_E_L_E_T_ = ' ' and SB1.B1_FILIAL = '  ' " +  CRLF
cQuery += "	   and B1_GRUPO		between '"+cGrupoDe+"' and '"+cGrupoAte+"'" +  CRLF
cQuery += "	   and B1_COD		between '"+cProdDe+"' and '"+cProdAte+"'" +  CRLF
cQuery += "	   and B2_FILIAL	between '"+cFiliDe+"' and '"+cFiliAte+"' " +  CRLF
cQuery += "	   and B2_LOCAL		between '"+cLocalDe+"' and '"+cLocalAte+"'" +  CRLF
cQuery += "	   and (B1_RASTRO not in ('L','S') or mv_rastro<>'S') " +  CRLF
if !empty(allTrim(cTipo))
	cQuery += "    	and B1_TIPO IN ("+cTipo+") " +  CRLF
endIf
cQuery += ") " +  CRLF

cQuery += ", saldos_iniciais as (" +  CRLF
cQuery += "	select SB9.*, prd.ID" +  CRLF
cQuery += "		 , B9_QINI AS SALDO_INI" +  CRLF
cQuery += "		 , B9_VINI1 AS CUSTO_INI " +  CRLF
cQuery += "	  from "+retSQLName("SB9")+" SB9" +  CRLF
cQuery += "	  join produtos prd on (B9_FILIAL = prd.B8_FILIAL and B9_COD = B1_COD and B9_LOCAL = B8_LOCAL)" +  CRLF
cQuery += "	 where SB9.D_E_L_E_T_ = ' ' and B9_DATA = '" + DTOS(dDataAnt) + "'" +  CRLF
cQuery += ") " +  CRLF

cQuery += ", entradas as (" +  CRLF
cQuery += "	select SD1.*, prd.ID, SF4.F4_TRANFIL" +  CRLF
cQuery += "	     , CASE WHEN D1_TIPO <> 'D' AND F4_TRANFIL <> '1' THEN D1_QUANT ELSE 0 END AS QTD_COMPRAS" +  CRLF
cQuery += "   		 , CASE WHEN D1_TIPO <> 'D' AND F4_TRANFIL <> '1' THEN D1_CUSTO"+iif(nMoeda>1,cValToChar(nMoeda),"")+" ELSE 0 END AS CUST_COMPRAS" +  CRLF
cQuery += "		 , CASE WHEN D1_TIPO = 'D' THEN D1_QUANT ELSE 0 END AS QTD_DEV_VENDAS" +  CRLF
cQuery += "		 , CASE WHEN D1_TIPO = 'D' THEN D1_CUSTO"+iif(nMoeda>1,cValToChar(nMoeda),"")+" ELSE 0 END AS CUST_VEND_DEV" +  CRLF
cQuery += "		 , CASE WHEN F4_TRANFIL = '1' THEN D1_QUANT ELSE 0 END AS QTD_TRF_ENTRAD" +  CRLF
cQuery += "		 , CASE WHEN F4_TRANFIL = '1' THEN D1_CUSTO"+iif(nMoeda>1,cValToChar(nMoeda),"")+" ELSE 0 END AS CUST_TRF_ENTRAD" +  CRLF
cQuery += "	  from "+retSQLName("SD1")+" SD1" +  CRLF
cQuery += "	  join produtos prd on (D1_FILIAL = prd.B8_FILIAL and D1_COD = B1_COD and D1_LOCAL = B8_LOCAL and D1_LOTECTL = B8_LOTECTL)" +  CRLF
cQuery += "	  join "+retSQLName("SF4")+" SF4 on (SF4.D_E_L_E_T_ = ' ' and F4_FILIAL = '"+xFilial("SF4")+"' and F4_CODIGO = D1_TES and F4_ESTOQUE = 'S') " +  CRLF
cQuery += "	 where SD1.D_E_L_E_T_ = ' '" +  CRLF
cQuery += "	   and D1_DTDIGIT between '"+dToS(dDataDigDe)+"' and '"+dToS(dDataDigAt)+"'" +  CRLF
cQuery += ")" +  CRLF

cQuery += ", saidas as (" +  CRLF
cQuery += "	select SD2.*, prd.ID, SF4.F4_TRANFIL" +  CRLF
cQuery += "	     , CASE WHEN D2_TIPO <> 'D' AND F4_TRANFIL <> '1' THEN D2_QUANT ELSE 0 END AS QTD_VENDAS" +  CRLF
cQuery += "		 , CASE WHEN D2_TIPO <> 'D' AND F4_TRANFIL <> '1' THEN D2_CUSTO"+cValToChar(nMoeda)+" ELSE 0 END AS CUST_VENDAS" +  CRLF
cQuery += "		 , CASE WHEN D2_TIPO = 'D' THEN D2_QUANT ELSE 0 END AS QTD_DEV_COMPRAS" +  CRLF
cQuery += "		 , CASE WHEN D2_TIPO = 'D' THEN D2_CUSTO"+cValToChar(nMoeda)+" ELSE 0 END AS CUST_COMP_DEV" +  CRLF
cQuery += "		 , CASE WHEN F4_TRANFIL = '1' THEN D2_QUANT ELSE 0 END AS QTD_TRF_SAIDA" +  CRLF
cQuery += "		 , CASE WHEN F4_TRANFIL = '1' THEN D2_CUSTO"+cValToChar(nMoeda)+" ELSE 0 END AS CUST_TRF_SAIDA" +  CRLF
cQuery += "	  from "+retSQLName("SD2")+" SD2" +  CRLF
cQuery += "	  join produtos prd on (D2_FILIAL = prd.B8_FILIAL and D2_COD = B1_COD and D2_LOCAL = B8_LOCAL and D2_LOTECTL = B8_LOTECTL)" +  CRLF
cQuery += "	  join "+retSQLName("SF4")+" SF4 on (SF4.D_E_L_E_T_ = ' ' and F4_FILIAL = '"+xFilial("SF4")+"' and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S') " +  CRLF
cQuery += "	 where SD2.D_E_L_E_T_ = ' '" +  CRLF
cQuery += "	   and D2_EMISSAO between '"+dToS(dDataDigDe)+"' and '"+dToS(dDataDigAt)+"'" +  CRLF
cQuery += ")" +  CRLF

cQuery += ", movimentos as (" +  CRLF
cQuery += "	select SD3.*, prd.ID, SF5.F5_CUSTATF" +  CRLF
cQuery += "	     , CASE WHEN D3_TM <= '499' AND D3_CF = 'PR0' THEN D3_QUANT ELSE 0 END AS QTD_PRODUCAO" +  CRLF
cQuery += "		 , CASE WHEN D3_TM <= '499' AND D3_CF = 'PR0' THEN D3_CUSTO"+cValToChar(nMoeda)+" ELSE 0 END AS CUSTO_PRODUCAO" +  CRLF
cQuery += "		 , CASE WHEN D3_TM >= '500' AND D3_CF <> 'PR0' AND D3_OP <> ' ' THEN D3_QUANT ELSE 0 END  AS QTD_REQ_PROD" +  CRLF
cQuery += "		 , CASE WHEN D3_TM >= '500' AND D3_CF <> 'PR0' AND D3_OP <> ' ' THEN D3_CUSTO"+cValToChar(nMoeda)+" ELSE 0 END  AS CUST_REQ_PROD" +  CRLF
cQuery += "		 , CASE WHEN D3_TM = '499'  AND D3_CF = 'DE0' AND D3_DOC = 'INVENT' THEN D3_QUANT ELSE 0 END  AS QTD_INV_ENTRADA" +  CRLF
cQuery += "		 , CASE WHEN D3_TM = '499'  AND D3_CF = 'DE0' AND D3_DOC = 'INVENT' THEN D3_CUSTO"+cValToChar(nMoeda)+" ELSE 0 END  AS CUST_INV_ENTRA" +  CRLF
cQuery += "		 , CASE WHEN D3_TM = '999'  AND D3_CF = 'RE0' AND D3_DOC = 'INVENT' THEN D3_QUANT ELSE 0 END  AS QTD_INV_SAIDA" +  CRLF
cQuery += "		 , CASE WHEN D3_TM = '999'  AND D3_CF = 'RE0' AND D3_DOC = 'INVENT' THEN D3_CUSTO"+cValToChar(nMoeda)+" ELSE 0 END  AS CUST_INV_SAIDA" +  CRLF
cQuery += "		 , CASE WHEN D3_TM < '499'  AND D3_TM <> '011' AND ((D3_CF <> 'PR0') AND (D3_CF <> 'DE4') AND (D3_CF <> 'DE0' AND D3_TM <> '499' AND D3_DOC <> 'INVENT')) THEN D3_QUANT ELSE 0 END  AS QTD_MOVI_ENTRADA" +  CRLF
cQuery += "		 , CASE WHEN D3_TM < '499'  AND D3_TM <> '011' AND ((D3_CF <> 'PR0') OR (D3_CF <> 'DE4') AND (D3_CF <> 'DE0' AND D3_TM <> '499' AND D3_DOC <> 'INVENT')) AND F5_TIPO = 'D' THEN D3_CUSTO"+cValToChar(nMoeda)+" ELSE 0 END AS CUST_MV_ENTRADA" +  CRLF
cQuery += "		 , CASE WHEN D3_TM = '499'  AND D3_CF = 'DE4' AND D3_DOC <> 'INVENT' THEN D3_QUANT ELSE 0 END  AS  QTD_MV_E_T " +  CRLF
cQuery += "		 , CASE WHEN D3_TM = '499'  AND D3_CF = 'DE4' AND D3_DOC <> 'INVENT' THEN D3_CUSTO"+cValToChar(nMoeda)+" ELSE 0 END  AS CST_MV_E_T " +  CRLF
cQuery += "		 , CASE WHEN D3_TM = '011'  AND ((D3_CF <> 'PR0') OR (D3_CF <> 'DE0' AND D3_TM <> '499' AND D3_DOC <> 'INVENT')) THEN D3_QUANT ELSE 0 END AS QTD_NASCIMENTO " +  CRLF
cQuery += "		 , CASE WHEN D3_TM = '011'  AND ((D3_CF <> 'PR0') OR (D3_CF <> 'DE0' AND D3_TM <> '499' AND D3_DOC <> 'INVENT')) AND F5_TIPO = 'D' THEN D3_CUSTO"+cValToChar(nMoeda)+" ELSE 0 END AS CUST_MV_NASCIMENTO " +  CRLF
cQuery += "		 , CASE WHEN D3_TM >= '500' AND D3_TM <> '511' AND D3_TM <> '999' AND ((D3_OP= '') OR D3_CF <> 'RE4' AND D3_DOC <> 'INVENT') THEN D3_QUANT ELSE 0 END AS QTD_MOVI_SAIDA " +  CRLF
cQuery += "		 , CASE WHEN D3_TM >= '500' AND D3_TM <> '511' AND D3_TM <> '999' AND D3_CF <> 'RE4' AND D3_DOC <> 'INVENT' THEN D3_CUSTO"+cValToChar(nMoeda)+" ELSE 0 END  AS CUST_MV_SAIDA " +  CRLF
cQuery += "		 , CASE WHEN D3_TM = '999'  AND D3_OP= '' AND D3_CF = 'RE4' AND D3_DOC <> 'INVENT' THEN D3_QUANT ELSE 0 END  AS QTD_MV_S_TR " +  CRLF
cQuery += "		 , CASE WHEN D3_TM = '999'  AND D3_OP= '' AND D3_CF = 'RE4' AND D3_DOC <> 'INVENT' THEN D3_CUSTO"+cValToChar(nMoeda)+" ELSE 0 END  AS CST_MV_S_TR " +  CRLF
cQuery += "		 , CASE WHEN D3_TM = '511'  AND D3_CF IN ('RE0','RE6') THEN D3_QUANT ELSE 0 END AS QTD_MORTE" +  CRLF
cQuery += "		 , CASE WHEN D3_TM = '511'  AND D3_CF IN ('RE0','RE6') THEN D3_CUSTO"+cValToChar(nMoeda)+" ELSE 0 END AS CUST_MV_MORTE  " +  CRLF
cQuery += "	  from "+retSQLName("SD3")+" SD3" +  CRLF
cQuery += "	  join produtos prd on (D3_FILIAL = prd.B8_FILIAL and D3_COD = B1_COD and D3_LOCAL = B8_LOCAL and D3_LOTECTL = B8_LOTECTL)" +  CRLF
cQuery += "	  left join "+retSQLName("SF5")+" SF5 on (SF5.D_E_L_E_T_ = ' ' and F5_FILIAL = '"+xFilial("SF5")+"' and F5_CODIGO = D3_TM) " +  CRLF
cQuery += "	 where SD3.D_E_L_E_T_ = ' ' and D3_ESTORNO <> 'S'" +  CRLF
cQuery += "	   and D3_EMISSAO between '"+dToS(dDataDigDe)+"' and '"+dToS(dDataDigAt)+"'" +  CRLF
cQuery += ")" +  CRLF

cQuery += "select B8_FILIAL, B1_COD, B1_DESC, B8_LOTECTL, B8_X_CURRA, B8_LOCAL, B1_UM, B1_TIPO, B1_RASTRO, B1_XLOTE" +  CRLF
cQuery += "		,(select ISNULL(SUM(SALDO_INI),0)			from saldos_iniciais si	where (prd.ID = si.ID))  AS SALDO_INI " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUSTO_INI),0)			from saldos_iniciais si	where (prd.ID = si.ID))  AS CUSTO_INI " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_COMPRAS),0)			from entradas ent		where (prd.ID = ent.ID)) AS QTD_COMPRAS " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUST_COMPRAS),0)		from entradas ent		where (prd.ID = ent.ID)) AS CUSTO_COMPRAS " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_TRF_ENTRAD),0)		from entradas ent		where (prd.ID = ent.ID)) AS QTD_TRF_ENTRAD  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUST_TRF_ENTRAD),0)		from entradas ent		where (prd.ID = ent.ID)) AS CUST_TRF_ENTRAD	  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_DEV_VENDAS),0)		from entradas ent		where (prd.ID = ent.ID)) AS QTD_DEV_VENDAS  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUST_VEND_DEV),0)		from entradas ent		where (prd.ID = ent.ID)) AS CUST_VEND_DEV " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_PRODUCAO),0)		from movimentos mov		where (prd.ID = mov.ID)) AS QTD_PRODUCAO  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUSTO_PRODUCAO),0)		from movimentos mov		where (prd.ID = mov.ID)) AS CUSTO_PRODUCAO  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_INV_ENTRADA),0)		from movimentos mov		where (prd.ID = mov.ID)) AS QTD_INV_ENTRADA  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUST_INV_ENTRA),0)		from movimentos mov		where (prd.ID = mov.ID)) AS CUST_INV_ENTRA " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_MOVI_ENTRADA),0)	from movimentos mov		where (prd.ID = mov.ID)) AS QTD_MOVI_ENTRADA " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUST_MV_ENTRADA),0)		from movimentos mov		where (prd.ID = mov.ID)) AS CUST_MV_ENTRADA  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_MV_E_T),0)			from movimentos mov		where (prd.ID = mov.ID)) AS QTD_MV_E_T  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CST_MV_E_T),0)			from movimentos mov		where (prd.ID = mov.ID)) AS CST_MV_E_T " +  CRLF
cQuery += "		,(select ISNULL(SUM(QTD_NASCIMENTO),0)		from movimentos mov		where (prd.ID = mov.ID)) AS QTD_NASCIMENTO " +  CRLF
cQuery += "		,(select ISNULL(SUM(CUST_MV_NASCIMENTO),0)	from movimentos mov		where (prd.ID = mov.ID)) AS CUST_MV_NASCIMENTO " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_VENDAS),0)			from saidas sai			where (prd.ID = sai.ID)) AS QTD_VENDAS " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUST_VENDAS),0)			from saidas sai			where (prd.ID = sai.ID)) AS CUSTO_VENDAS " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_TRF_SAIDA),0)		from saidas sai			where (prd.ID = sai.ID)) AS QTD_TRF_SAIDA " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUST_TRF_SAIDA),0)		from saidas sai			where (prd.ID = sai.ID)) AS CUST_TRF_SAIDA " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_DEV_COMPRAS),0)		from saidas sai			where (prd.ID = sai.ID)) AS QTD_DEV_COMPRAS  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUST_COMP_DEV),0)		from saidas sai			where (prd.ID = sai.ID)) AS CUST_COMP_DEV " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_REQ_PROD),0)		from movimentos mov		where (prd.ID = mov.ID)) AS QTD_REQ_PROD  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUST_REQ_PROD),0)		from movimentos mov		where (prd.ID = mov.ID)) AS CUST_REQ_PROD  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_INV_SAIDA),0)		from movimentos mov		where (prd.ID = mov.ID)) AS QTD_INV_SAIDA  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUST_INV_SAIDA),0)		from movimentos mov		where (prd.ID = mov.ID)) AS CUST_INV_SAIDA  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_MOVI_SAIDA),0)		from movimentos mov		where (prd.ID = mov.ID)) AS QTD_MOVI_SAIDA  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUST_MV_SAIDA),0)		from movimentos mov		where (prd.ID = mov.ID)) AS CUST_MV_SAIDA  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_MV_S_TR),0)			from movimentos mov		where (prd.ID = mov.ID)) AS QTD_MV_S_TR  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CST_MV_S_TR),0)			from movimentos mov		where (prd.ID = mov.ID)) AS CST_MV_S_TR  " +  CRLF
cQuery += " 	,(select ISNULL(SUM(QTD_MORTE),0)			from movimentos mov		where (prd.ID = mov.ID)) AS QTD_MORTE " +  CRLF
cQuery += " 	,(select ISNULL(SUM(CUST_MV_MORTE),0)		from movimentos mov		where (prd.ID = mov.ID)) AS CUST_MV_MORTE " +  CRLF
cQuery += "  from produtos prd" +  CRLF
//cQuery += "  left join saldos_iniciais si on (prd.ID = si.ID)" +  CRLF
//cQuery += "  left join entradas ent on (prd.ID = ent.ID)" +  CRLF
//cQuery += "  left join saidas sai on (prd.ID = sai.ID)" +  CRLF
//cQuery += "  left join movimentos mov on (prd.ID = mov.ID)" +  CRLF
//cQuery += " group by B8_FILIAL, B1_COD, B1_DESC, B8_LOTECTL, B8_X_CURRA, B8_LOCAL, B1_UM, B1_TIPO, B1_RASTRO, B1_XLOTE" +  CRLF
cQuery += " order by B1_COD" +  CRLF	
	
	
	MEMOWRITE("C:\TOTVS\VAESTR03.TXT", cQuery)

	TCQUERY cQuery NEW ALIAS &cAlias
	
	COUNT to nCount
	 
	ProcRegua(nCount)
	
	nSeq1 := 0
	nSeq2 := 0	
	
	(cAlias)->(dbGoTop())
	
	while !(cAlias)->(eof())
		
		IncProc()
        
		nSaldoIni := 0 
		nCustoIni := 0
		aSaldos:=CalcEstL((cAlias)->B1_COD/*cProduto*/, (cAlias)->B8_LOCAL/*cAlmox*/, dDataDigDe/*dData*/, (cAlias)->B8_LOTECTL/*cLote*/, /*cSubLote*/, /*cEnder*/, /*cSerie*/, (cAlias)->B1_RASTRO$"LS"/*lRastro*/) 
		nSaldoIni += aSaldos[1]  // QUANTIDADE	
		nCustoIni += aSaldos[2]  // CUSTO NA MOEDA 1	 	

		
		nSaldoFin := nSaldoIni + (cAlias)->QTD_COMPRAS + (cAlias)->QTD_TRF_ENTRAD + (cAlias)->QTD_DEV_VENDAS;
		 								 + (cAlias)->QTD_PRODUCAO + (cAlias)->QTD_INV_ENTRADA + (cAlias)->QTD_MOVI_ENTRADA;
		 								 + (cAlias)->QTD_NASCIMENTO + (cAlias)->QTD_MV_E_T;
		 								 - (cAlias)->QTD_VENDAS - (cAlias)->QTD_TRF_SAIDA - (cAlias)->QTD_DEV_COMPRAS;
		 								 - (cAlias)->QTD_REQ_PROD - (cAlias)->QTD_INV_SAIDA - (cAlias)->QTD_MOVI_SAIDA;
		 								 - (cAlias)->QTD_MORTE - (cAlias)->QTD_MV_S_TR;
		 								 
		nCustoFin := nCustoIni + (cAlias)->CUSTO_COMPRAS + (cAlias)->CUST_TRF_ENTRAD + (cAlias)->CUST_VEND_DEV;
		 								 + (cAlias)->CUSTO_PRODUCAO + (cAlias)->CUST_INV_ENTRA + (cAlias)->CUST_MV_ENTRADA;
		 								 + (cAlias)->CUST_MV_NASCIMENTO + (cAlias)->CST_MV_E_T;
		 								 - (cAlias)->CUSTO_VENDAS - (cAlias)->CUST_TRF_SAIDA - (cAlias)->CUST_COMP_DEV;
		 								 - (cAlias)->CUST_REQ_PROD - (cAlias)->CUST_INV_SAIDA - (cAlias)->CUST_MV_SAIDA;
		 								 - (cAlias)->CUST_MV_MORTE - (cAlias)->CST_MV_S_TR;
		 		
		nExibeC		:= val(MV_PAR13)
		If nExibeC = 2	// exibe sem custo
			aadd(aRet,{(cAlias)->B8_FILIAL, (cAlias)->B1_COD,(cAlias)->B1_DESC,"'"+iif(empty((cAlias)->B8_LOTECTL),(cAlias)->B1_XLOTE,(cAlias)->B8_LOTECTL),(cAlias)->B8_X_CURRA,(cAlias)->B8_LOCAL,(cAlias)->B1_UM,(cAlias)->B1_TIPO,;
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
						nSaldoFin})
	
		Else // Exibe com Custo
			aadd(aRet,{(cAlias)->B8_FILIAL,(cAlias)->B1_COD,(cAlias)->B1_DESC,"'"+iif(empty((cAlias)->B8_LOTECTL),(cAlias)->B1_XLOTE,(cAlias)->B8_LOTECTL),(cAlias)->B8_X_CURRA,(cAlias)->B8_LOCAL,(cAlias)->B1_UM,(cAlias)->B1_TIPO,;
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
						nSaldoFin,nCustoFin})
	
		Endif
		
		(cAlias)->(dbSkip())
	end
	
	(cAlias)->(dbCloseArea())
			
return aRet

Static Function perg(cPerg)

	Local aParBox 	:= {}
	Local cPerg		:= PadR(cPerg,Len(SX1->X1_GRUPO))
	Local aMoeda	:= {"1=1a Moeda","2=2a Moeda","3=3a Moeda","4=4a Moeda","5=5a Moeda"}
	Local aExibCus	:= {"1=Exibe","2=Oculta"}
		
	AADD(aParBox,{1,"Do Armazém"					,SPACE(04)						,"@!"				,""					,""		,""											,050,.F.})	// MV_PAR01
	AADD(aParBox,{1,"Ate o Armazém"					,SPACE(04)						,"@!"				,""					,""		,""											,050,.T.})	// MV_PAR02
	AADD(aParBox,{1,"Tipo"							,SPACE(30)						,"@!"				,""					,""		,""											,050,.F.})	// MV_PAR03
	AADD(aParBox,{1,"Do Produto"					,SPACE(tamSX3("B1_COD")[1])		,"@!"				,""					,"SB1"	,""											,050,.F.})	// MV_PAR04
	AADD(aParBox,{1,"Ate o Produto"					,SPACE(tamSX3("B1_COD")[1])		,"@!"				,""					,"SB1"	,""											,050,.T.})	// MV_PAR05
	AADD(aParBox,{1,"Da Data de Emissão"			,dDataBase						,""					,""					,""		,""											,050,.T.})	// MV_PAR06
	AADD(aParBox,{1,"Ate a Data de Emissão"			,dDataBase						,""					,""					,""		,""											,050,.T.})	// MV_PAR07
	AADD(aParBox,{2,"Moeda"							,"1a Moeda",aMoeda,50,"",.F.})																											// MV_PAR08
	AADD(aParBox,{1,"Do Grupo" 					    ,SPACE(04)						,"@!"				,""					,"SBM"		,""											,050,.F.})	// MV_PAR09
	AADD(aParBox,{1,"Ate o Grupo"					,SPACE(04)						,"@!"				,""					,"SBM"		,""											,050,.T.})	// MV_PAR10
	AADD(aParBox,{1,"Da Filial" 					,SPACE(02)						,"@!"				,""					,"SM0"		,""											,050,.F.})	// MV_PAR11
	AADD(aParBox,{1,"Ate a Filial"					,SPACE(02)						,"@!"				,""					,"SM0"		,""											,050,.T.})	// MV_PAR12
	AADD(aParBox,{2,"Exibe Custo"					,"Exibe",aExibCus,50,"",.F.})																											// MV_PAR13
				
Return ParamBox(aParBox,cPerg,,,,,,,,cPerg,.T.,.T.)

//

Static Function fProporcaoM ( cCodigo, nCustoProd, nQuantidade )

Local aArea := getArea()
Local nI    := 0

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

//cCod := fEstrutura(cCod)

dbSelectArea( "SB1" )
dbseek(xfilial('SB1') + cCod, .T.)

cRev := SB1->B1_REVATU
	
dbSelectArea("SG1")
dbSetOrder(1)
dbseek(xfilial("SG1") + cCod, .T.)

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
			dbSeek(xFilial('SB1') + padr(cCom,tamsx3('B1_COD')[1]))
						
			dbSelectArea('SB2')
			dbSetOrder(1)
			dbSeek(xFilial('SB2') + padr(cCom,tamsx3('B2_COD')[1]) + SB1->B1_LOCPAD)

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


