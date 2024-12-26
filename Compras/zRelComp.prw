//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} zRelComp
Listagem de Compras
@author Atilio
@since 21/09/2016
@version 1.0
	@example
	u_zRelComp()
/*/

User Function zRelComp()
	Local aArea		:= GetArea()
	Local oReport
	Private cPerg	:= "X_zRelComp"
	Private cPedDe	:= ""
	Private cPedAt	:= ""
	Private cForDe	:= ""
	Private cForAt	:= ""
	Private dEmiDe	:= sToD("")
	Private dEmiAt	:= sToD("")

	//Enquanto a pergunta for confirmada, define as propriedades do Report e imprime
	fVldPerg(cPerg)
	While Pergunte(cPerg,.T.)
		cPedDe := MV_PAR01
		cPedAt := MV_PAR02
		cForDe := MV_PAR03
		cForAt := MV_PAR04
		dEmiDe := MV_PAR05
		dEmiAt := MV_PAR06
		
		//Definindo atributos e propriedades e gerando relatório TReport
		oReport := fReportDef()
		oReport:PrintDialog()
	EndDo
	
	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Autor: Daniel Atilio                                                          |
 | Data:  21/09/2016                                                             |
 | Desc:  Função que monta a definição do relatório                              |
 *-------------------------------------------------------------------------------*/

Static Function fReportDef()
	Local oReport
	Local oSctnPar   := Nil
	Local oSectCab   := Nil
	Local oSectIte   := Nil
	Local cPictTot   := PesqPict('SD1', 'D1_TOTAL')
	Local cPictQtd   := PesqPict('SD1', 'D1_QUANT')
	Local oFuncTotal := Nil
	Local oFuncQuant := Nil

	//Criação do componente de impressão
	oReport := TReport():New(	"zRelComp",;														//Nome do Relatório
									"Recebimento. Gado",;										//Título
									,;																	//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
									{|oReport| fRepPrint(oReport)},;								//Bloco de código que será executado na confirmação da impressão
									)																	//Descrição
	oReport:SetLandscape(.T.)   //Define a orientação de página do relatório como paisagem  ou retrato. .F.=Retrato; .T.=Paisagem
	oReport:SetTotalInLine(.F.) //Define se os totalizadores serão impressos em linha ou coluna
	oReport:ShowHeader()
	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf
	
	//*******************
	// PARÂMETROS
	//*******************
	
	//Criando a seção de parâmetros e as células
	oSectPar := TRSection():New(	oReport,;				//Objeto TReport que a seção pertence
										"Parâmetros",;		//Descrição da seção
										{""})					//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectPar:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Células da seção parâmetros
	TRCell():New(		oSectPar,"PARAM"			,"   ","Parâmetro",	"@!"       ,         30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(		oSectPar,"CONTEUDO"		,"   ","Conteúdo",	"@!"       ,         30,/*lPixel*/,/*{|| code-block de impressao }*/)
	
	//*******************
	// CABEÇALHO
	//*******************
	
	//Criando a seção de dados e as células
	oSectCab := TRSection():New(	oReport,;				//Objeto TReport que a seção pertence
									"Cabeçalho",;			//Descrição da seção
									{"QRY_AUX"})			//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectCab:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(	oSectCab,"FILIAL"		,"QRY_AUX","Filial"			,/*Picture*/,					TamSX3('D1_FILIAL')[01] 	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"PEDIDO"		,"QRY_AUX","Pedido"			,/*Picture*/,					TamSX3('D1_PEDIDO')[01]	    ,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"COD_FORNE"	,"QRY_AUX","Cod.Forn."		,/*Picture*/,					TamSX3('D1_FORNECE')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"FORNECEDOR"	,"QRY_AUX","Fornecedor"		,/*Picture*/,					TamSX3('A2_NOME')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"CORRETOR"		,"QRY_AUX","Cod.Corr."		,/*Picture*/,					TamSX3('C7_X_CORRE')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"NOME_CORRE"	,"QRY_AUX","Corretor"		,/*Picture*/,					TamSX3('A3_NOME')[01]-25		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"VALOR_COMI"	,"QRY_AUX","Vlr. Comiss."	,PesqPict('SC7', 'C7_X_COMIS'),	TamSX3('C7_X_COMIS')[01]+2	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"PERCE_COMI"	,"QRY_AUX","% Comiss"		,PesqPict('SC7', 'C7_X_COMIP'),	TamSX3('C7_X_COMIP')[01]+2	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"VAL_ADT"		,"QRY_AUX","Vlr. Adiant."	,PesqPict('SE2', 'E2_VALOR'),	TamSX3('E2_VALOR')[01]+2	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"TIT_ICM_FR"	,"QRY_AUX","ICMS Frete"		,PesqPict('SE2', 'E2_VALOR'),	TamSX3('E2_VALOR')[01]+2	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	//TRCell():New(	oSectCab,"TIT_ICM_GD"	,"QRY_AUX","ICMS Gado"		,PesqPict('SE2', 'E2_VALOR'),	TamSX3('E2_VALOR')[01]+2	,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	//*******************
	// ITENS
	//*******************

	//Criando a seção de dados e as células
	oSectIte := TRSection():New(	oSectCab,;					//Objeto TReport que a seção pertence
									"Itens",;					//Descrição da seção
									{"QRY_AUX"})				//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectIte:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(	oSectIte,"COD_PROD"		,"QRY_AUX","Cod.Pro."		,/*Picture*/,					TamSX3('D1_COD')[01]-5		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"DESCRICAO"	,"QRY_AUX","Descricao"		,/*Picture*/,					TamSX3('B1_DESC')[01]-60	,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"QTD"			,"QRY_AUX","Quant."			,PesqPict('SD1', 'D1_QUANT'),	TamSX3('D1_QUANT')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"VAL_UNIT"		,"QRY_AUX","Vlr.Un."		,PesqPict('SD1', 'D1_VUNIT'),	TamSX3('D1_VUNIT')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"TOTAL"		,"QRY_AUX","Total"			,PesqPict('SD1', 'D1_TOTAL'),	TamSX3('D1_TOTAL')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"NUM_NF"		,"QRY_AUX","Num.NF"			,/*Picture*/,					TamSX3('D1_DOC')[01]+3		,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"EMISSAO"		,"QRY_AUX","Emissão"		,/*Picture*/,					TamSX3('D1_EMISSAO')[01]+3	,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"PESO_CHEGA"	,"QRY_AUX","Pes.Cheg."		,PesqPict('SD1', 'D1_X_PESO'),	TamSX3('D1_X_PESO')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"DT_EMBARQ"	,"QRY_AUX","Dt.Emba."		,/*Picture*/,					TamSX3('D1_X_EMBDT')[01]+2	,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"HR_EMBARQU"	,"QRY_AUX","Hr.Emba."		,/*Picture*/,					TamSX3('D1_X_EMBHR')[01]+2	,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"DT_CHEGADA"	,"QRY_AUX","Dt.Cheg."		,/*Picture*/,					TamSX3('D1_X_CHEDT')[01]+2	,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"PESO_NEGOC"	,"QRY_AUX","Pes.Negoc"		,PesqPict('SC7', 'C7_X_PESO'),	TamSX3('C7_X_PESO')[01]+2	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"RENDIMENTO"	,"QRY_AUX","Rend."			,PesqPict('SC7', 'C7_X_REND'),	TamSX3('C7_X_REND')[01]+2	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"RENDIM_KG"	,"QRY_AUX","Rend.KG"		,PesqPict('SC7', 'C7_X_RENDP'),	TamSX3('C7_X_RENDP')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"ARROBA"		,"QRY_AUX","Arroba"			,PesqPict('SC7', 'C7_X_ARROV'),	TamSX3('C7_X_ARROV')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"QTD_ARROBA"	,"QRY_AUX","Qtd.Arroba"		,PesqPict('SC7', 'C7_X_ARROQ'),	TamSX3('C7_X_ARROQ')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"TOTAL_GADO"	,"QRY_AUX","Tot.Gado"		,PesqPict('SC7', 'C7_X_TOTAL'),	TamSX3('C7_X_TOTAL')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"VAL_UNIT_C"	,"QRY_AUX","Vlr.Uni.Cab"	,PesqPict('SC7', 'C7_X_VLUNI'),	TamSX3('C7_X_VLUNI')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"VAL_TOT_IC"	,"QRY_AUX","Total ICMS"		,PesqPict('SC7', 'C7_X_TOICM'),	TamSX3('C7_X_TOICM')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"ICMS_CABEC"	,"QRY_AUX","ICMS Cabeça"	,PesqPict('SC7', 'C7_X_VLICM'),	TamSX3('C7_X_VLICM')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	//Acrescentando totalizador nos dados
	oFuncTotal := TRFunction():New(oSectIte:Cell("TOTAL"),,"SUM",,,cPictTot)
	oFuncTotal:SetEndReport(.F.)	//Define se será impresso o total também ao finalizar o relatório (Total Geral)
	oFuncQuant := TRFunction():New(oSectIte:Cell("QTD"),,"SUM",,,cPictTot)
	oFuncQuant:SetEndReport(.F.)	//Define se será impresso o total também ao finalizar o relatório (Total Geral)
Return oReport

/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Autor: Daniel Atilio                                                          |
 | Data:  21/09/2016                                                             |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/

Static Function fRepPrint(oReport)
	Local cQryAux := ""
	Local oSectPar := Nil
	Local oSectCab := Nil
	Local oSectIte := Nil

	//Pegando as seções do relatório
	oSectPar := oReport:Section(1)
	oSectCab := oReport:Section(2)
	oSectIte := oReport:Section(2):Section(1)

	//Setando os conteúdos da seção de parâmetros
	oSectPar:Init()
	oSectPar:Cell("PARAM"):SetValue("Pedido De?")
	oSectPar:Cell("CONTEUDO"):SetValue(cPedDe)
	oSectPar:PrintLine()
	oSectPar:Cell("PARAM"):SetValue("Pedido Até?")
	oSectPar:Cell("CONTEUDO"):SetValue(cPedAt)
	oSectPar:PrintLine()
	oSectPar:Cell("PARAM"):SetValue("Fornecedor De?")
	oSectPar:Cell("CONTEUDO"):SetValue(cForDe)
	oSectPar:PrintLine()
	oSectPar:Cell("PARAM"):SetValue("Fornecedor Até?")
	oSectPar:Cell("CONTEUDO"):SetValue(cForAt)
	oSectPar:PrintLine()
	oSectPar:Cell("PARAM"):SetValue("Emissão De?")
	oSectPar:Cell("CONTEUDO"):SetValue(dToC(dEmiDe))
	oSectPar:PrintLine()
	oSectPar:Cell("PARAM"):SetValue("Emissão Até?")
	oSectPar:Cell("CONTEUDO"):SetValue(dToC(dEmiAt))
	oSectPar:PrintLine()
	oSectPar:Finish()

	//Montando a consulta
	cQryAux := ""
	cQryAux += " SELECT " + STR_PULA
	cQryAux += " " + STR_PULA
	//Cabeçalho 
	cQryAux += "        D1.D1_FILIAL           AS FILIAL, " + STR_PULA
	cQryAux += "        D1.D1_PEDIDO           AS PEDIDO, " + STR_PULA
	cQryAux += "        D1.D1_FORNECE          AS COD_FORNE, " + STR_PULA
	cQryAux += "        A2.A2_NOME             AS FORNECEDOR, " + STR_PULA
	cQryAux += "        C7.C7_X_CORRE          AS CORRETOR, " + STR_PULA
	cQryAux += "        A3.A3_NOME             AS NOME_CORRE, " + STR_PULA
	cQryAux += "        C7.C7_X_COMIS          AS VALOR_COMI, " + STR_PULA
	cQryAux += "        C7_X_COMIP             AS PERCE_COMI, " + STR_PULA
	cQryAux += "        SUM(E2.E2_VALOR)       AS VAL_ADT, " + STR_PULA
	cQryAux += "        SUM(E2X.E2_VALOR)      AS TIT_ICM_FR, " + STR_PULA
	//cQryAux += "        SUM(E2Y.E2_VALOR)      AS TIT_ICM_GD, " + STR_PULA
	//Itens
	cQryAux += " " + STR_PULA
	cQryAux += "        D1.D1_COD              AS COD_PROD, " + STR_PULA
	cQryAux += "        B1.B1_DESC             AS DESCRICAO, " + STR_PULA
	cQryAux += "        D1.D1_QUANT            AS QTD, " + STR_PULA
	cQryAux += "        D1.D1_VUNIT            AS VAL_UNIT, " + STR_PULA
	cQryAux += "        D1_TOTAL               AS TOTAL, " + STR_PULA
	cQryAux += "        D1.D1_DOC              AS NUM_NF, " + STR_PULA
	cQryAux += "        D1.D1_EMISSAO          AS EMISSAO, " + STR_PULA
	cQryAux += "        D1_X_PESO              AS PESO_CHEGA, " + STR_PULA
	cQryAux += "        D1.D1_X_EMBDT          AS DT_EMBARQ, " + STR_PULA
	cQryAux += "        D1.D1_X_EMBHR          AS HR_EMBARQU, " + STR_PULA
	cQryAux += "        D1.D1_X_CHEDT          AS DT_CHEGADA, " + STR_PULA
	cQryAux += "        D1.D1_X_PESCH          AS PESO_CHEGA, " + STR_PULA
	cQryAux += "        C7.C7_X_PESO           AS PESO_NEGOC, " + STR_PULA
	cQryAux += "        C7.C7_X_REND           AS RENDIMENTO, " + STR_PULA
	cQryAux += "        C7.C7_X_RENDP          AS RENDIM_KG, " + STR_PULA
	cQryAux += "        C7.C7_X_ARROV          AS ARROBA, " + STR_PULA
	cQryAux += "        C7.C7_X_ARROQ          AS QTD_ARROBA, " + STR_PULA
	cQryAux += "        C7.C7_X_TOTAL          AS TOTAL_GADO, " + STR_PULA
	cQryAux += "        C7_X_VLUNI             AS VAL_UNIT_C, " + STR_PULA
	cQryAux += "        C7.C7_X_TOICM          AS VAL_TOT_IC, " + STR_PULA
	cQryAux += "        C7.C7_X_VLICM          AS ICMS_CABEC " + STR_PULA
	cQryAux += "  " + STR_PULA
	cQryAux += "  FROM "+RetSQLName('SD1')+" D1, "+RetSQLName('SA2')+" A2, "+RetSQLName('SB1')+" B1, "+RetSQLName('SC7')+" C7, "+RetSQLName('SA3')+" A3, "+RetSQLName('SE2')+" E2, "+RetSQLName('SE2')+" E2X "+STR_PULA
			//	RetSQLName('SE2')+" E2Y " + STR_PULA
	cQryAux += "  " + STR_PULA
	cQryAux += "  WHERE  " + STR_PULA
	cQryAux += "    (A2.D_E_L_E_T_ = '' AND B1.D_E_L_E_T_ = '' AND D1.D_E_L_E_T_ = '' AND C7.D_E_L_E_T_ = '') " + STR_PULA
	cQryAux += "    AND (D1.D1_FORNECE = C7.C7_FORNECE AND D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM) " + STR_PULA
	cQryAux += "    AND (D1.D1_FORNECE = A2.A2_COD) " + STR_PULA
	cQryAux += "    AND (D1.D1_COD = B1.B1_COD ) " + STR_PULA
	cQryAux += "    AND (A3.A3_COD = C7.C7_X_CORRE) " + STR_PULA    
	cQryAux += "    AND (D1.D1_PEDIDO = C7.C7_NUM) " + STR_PULA
	cQryAux += "    AND (D1.D1_EMISSAO BETWEEN '"+dToS(dEmiDe)+"' AND '"+dToS(dEmiAt)+"') " + STR_PULA
	//cQryAux += "    AND (D1.D1_COD = '010001') " + STR_PULA
	cQryAux += "    AND (D1.D1_PEDIDO >= '"+cPedDe+"' AND D1.D1_PEDIDO <= '"+cPedAt+"')  " + STR_PULA
	cQryAux += "    AND (A2.A2_COD >= '"+cForDe+"' AND A2.A2_COD <= '"+cForAt+"')  " + STR_PULA
	cQryAux += "    AND (E2.E2_FILIAL = C7.C7_FILIAL AND E2.E2_NUM = C7.C7_NUM AND E2.E2_PREFIXO = 'ADT' AND E2.D_E_L_E_T_ = '') " + STR_PULA
	cQryAux += "    AND (E2X.E2_FILIAL = C7.C7_FILIAL AND E2X.E2_NUM = C7.C7_NUM AND E2X.E2_PREFIXO = 'ICF' AND E2X.D_E_L_E_T_ = '') " + STR_PULA
	//cQryAux += "    AND (E2Y.E2_NUM = C7.C7_NUM AND E2Y.E2_PREFIXO = 'ICM' AND E2Y.D_E_L_E_T_ = '') " + STR_PULA
	cQryAux += " " + STR_PULA
	cQryAux += "  GROUP BY D1_FILIAL, D1_PEDIDO, D1_FORNECE, A2_NOME, D1_COD, B1_DESC, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_DOC, D1_EMISSAO, D1_X_PESO, D1_X_EMBDT, D1_X_EMBHR, D1_X_CHEDT, D1_X_PESCH, " + STR_PULA
	cQryAux += "    C7_X_PESO, C7_X_REND, C7_X_RENDP, C7_X_ARROV, C7_X_ARROQ, C7_X_TOTAL, C7_X_VLUNI, C7_X_TOICM, C7_X_CORRE, A3_NOME, C7_X_COMIS, C7_X_COMIP, C7_X_VLICM " + STR_PULA
	cQryAux += "  ORDER BY PEDIDO, COD_FORNE, COD_PROD, NUM_NF "
	TCQuery cQryAux New Alias "QRY_AUX"
	Memowrite("D:\TOTVS\zRelComp.txt",cQryAux)
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Setando os campos Data
	TCSetField("QRY_AUX", "EMISSAO",    "D")
	TCSetField("QRY_AUX", "DT_CHEGADA", "D")
	TCSetField("QRY_AUX", "DT_EMBARQ",  "D")
	
	//Enquanto houver dados
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Imprimindo o Cabeçalho
		oSectCab:Init()
		oSectCab:PrintLine()
		
		//Setando as variáveis de Quebra
		cFilAux := QRY_AUX->FILIAL
		cPedAux := QRY_AUX->PEDIDO
		cForAux := QRY_AUX->COD_FORNE
		//cAdtAux := QRY_AUX->VAL_ADT
		//cIcmAux := QRY_AUX->TIT_ICM_FR
		
		
		//Enquanto for o mesmo Filial e Pedido e Fornecedor, imprime os itens
		oSectIte:Init()
		While !QRY_AUX->(EoF()) .And. cFilAux == QRY_AUX->FILIAL .And. cPedAux == QRY_AUX->PEDIDO .And. cForAux == QRY_AUX->COD_FORNE
			//Imprime os dados
			oSectIte:PrintLine()
			oReport:IncMeter()
			
			QRY_AUX->(DbSkip())
		EndDo
		oSectIte:Finish()
		
		//Finalizando o Cabeçalho
		oSectCab:Finish()
		oReport:SkipLine(2)
	EndDo
	
	QRY_AUX->(DbCloseArea())
Return

/*---------------------------------------------------------------------*
 | Func:  fVldPerg                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  21/09/2016                                                   |
 | Desc:  Função para criar o grupo de perguntas                       |
 *---------------------------------------------------------------------*/

Static Function fVldPerg(cPerg)
	//(		cGrupo,	cOrdem,	cPergunt,			cPergSpa,		cPergEng,	cVar,		cTipo,	nTamanho,					nDecimal,	nPreSel,	cGSC,	cValid,	cF3,	cGrpSXG,	cPyme,	cVar01,		cDef01,	cDefSpa1,	cDefEng1,	cCnt01,	cDef02,		cDefSpa2,	cDefEng2,	cDef03,			cDefSpa3,		cDefEng3,	cDef04,	cDefSpa4,	cDefEng4,	cDef05,	cDefSpa5,	cDefEng5,	aHelpPor,	aHelpEng,	aHelpSpa,	cHelp)
	PutSx1(	cPerg,	"01",	"Pedido De?",		"",				"",			"mv_ch0",	"C",	TamSX3('C7_NUM')[01],		0,			0,			"G",	"", 	"SC7",	"",			"",		"mv_par01",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"02",	"Pedido Até?",		"",				"",			"mv_ch1",	"C",	TamSX3('C7_NUM')[01],		0,			0,			"G",	"", 	"SC7",	"",			"",		"mv_par02",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"03",	"Fornecedor De?",	"",				"",			"mv_ch2",	"C",	TamSX3('A2_COD')[01],		0,			0,			"G",	"", 	"SA2",	"",			"",		"mv_par03",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"04",	"Fornecedor Até?",	"",				"",			"mv_ch3",	"C",	TamSX3('A2_COD')[01],		0,			0,			"G",	"", 	"SA2",	"",			"",		"mv_par04",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"05",	"Emissão De?",		"",				"",			"mv_ch4",	"D",	TamSX3('C7_EMISSAO')[01],	0,			0,			"G",	"", 	"",		"",			"",		"mv_par05",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"06",	"Emissão Até?",		"",				"",			"mv_ch5",	"D",	TamSX3('C7_EMISSAO')[01],	0,			0,			"G",	"", 	"",		"",			"",		"mv_par06",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
Return