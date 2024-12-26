#Include "Rwmake.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Totvs.ch"
#Include "TryException.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Arthur Toshio Oda Vanzella	                                          |
 | Data:  21.05.2017                                                              |
 | Desc:  Este relatório lista os documentos e títulos com retenção de Funrural;  |
 |		  Utilizado objeto: TReport                         					  |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
user function VACOMR06()  // U_VACOMR06

Local   aArea		:= GetArea()
Local 	oReport                 

Private nRegistros	:= 0
Private cPerg		:= "VACOMR06"
//Private _Alias		:= CriaTrab(,.F.)   

Private cTitulo 	:= "Relatório de Tìtulos com Retenção de Funrural"

GeraX1(cPerg)

While Pergunte(cPerg, .T.)
	oReport := ReportDef()
	oReport:PrintDialog()

EndDo




RestArea(aArea)
Return nil
	
/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Arthur Toshio Oda Vanzella	                                          |
 | Data:  21.05.2017                                                              |
 | Desc:                                                  						  |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/

Static Function ReportDef()

	Local oSectIte   := Nil
	Local oSectCab   := Nil
	Local oReport	:= nil
	Local oSection1	:= nil
	Local oBreak1 	:= nil
	Local cPictBaseFun := PesqPict('SD1', 'D1_TOTAL')
	Local cPictBaseIc  := PesqPict('SD1', 'D1_TOTAL')
	Local cPictFunCor  := PesqPict('SD1', 'D1_TOTAL')
	Local cPictFun     := PesqPict('SD1', 'D1_TOTAL')
	Local cPictValFun  := PesqPict('SD1', 'D1_TOTAL')
    Local oFunBaseFu := Nil
    Local oFunBaseIc := Nil
    Local oFunrCorr  := Nil
    Local oFunrRedu  := Nil
    Local oFunValFun := Nil
	//CriaoFunBaseIcção do componente de impressão
	oReport := TReport():New(	"VACOMR06",;							//Nome do Relatório
								"Docs. Com Funrural",;				//Título
								,;									//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;	//Bloco de código que será executado na confirmação da impressão
							)									//Descrição
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
	TRCell():New(		oSectPar,"PARAM"		,"   ","Parâmetro",	"@!"       ,         30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(		oSectPar,"CONTEUDO"		,"   ","Conteúdo",	"@!"       ,         30,/*lPixel*/,/*{|| code-block de impressao }*/)
	
	//*******************
	// CABEÇALHO
	//*******************
	
	//Criando a seção de dados e as células
	oSectCab := TRSection():New(	oReport,;				//Objeto TReport que a seção pertence
									"Cabeçalho",;			//Descrição da seção
									{"QRY_AUX1"})			//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectCab:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(	oSectCab,"DESC_GRUPO","QRY_AUX1"	,"Grupo Produto"			,X3Picture("BM_DESC")			,TamSX3('BM_DESC')[01] 		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/"LEFT",/*lLineBreak*/,/*cHeaderAlign */"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.T./*lBold*/)
	TRCell():New(	oSectCab,"E22VENCT"	,"QRY_AUX1"		,"Venc. Funrural"     		,X3Picture("D1_EMISSAO")		,TamSX3('E2_VENCREA')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/"LEFT",/*lLineBreak*/,/*cHeaderAlign*/"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.T./*lBold*/)
	//TRCell():New(	oSectCab, oFunBaseFu,"QRY_AUX1" 	,"Base Funrural"			,X3Picture("D1_BASEFUN")		,TamSX3('D1_BASEFUN')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/"LEFT",/*lLineBreak*/,/*cHeaderAlign*/"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.T./*lBold*/)
	
	
	
	//*******************
	// ITENS
	//*******************

	//Criando a seção de dados e as células
	oSectIte := TRSection():New(	oSectCab,;					//Objeto TReport que a seção pertence
									"Itens",;					//Descrição da seção
									{"QRY_AUX1"})				//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectIte:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatórioa
	/*01*/TRCell():New(	oSectIte,"E2FILIAL"		,"QRY_AUX1","Filial"  	          	,X3Picture("E2_FILIAL")   ,	TamSX3('E2_FILIAL')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*02*/TRCell():New(	oSectIte,"E2NOMEFOR"	,"QRY_AUX1","Fornecedor"  	      	,X3Picture("A2_NOME")     ,	TamSX3('A2_NOME')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/, .T.		   ,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*03*/TRCell():New(	oSectIte,"TIPO_PESSOA"	,"QRY_AUX1","Pessoa" 	  	    	,X3Picture("A2_NOME")     ,	10							,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*04*/TRCell():New(	oSectIte,"MUNICIPIO"	,"QRY_AUX1","Municipio"  	      	,X3Picture("A2_MUN")      ,	14							,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T.		   ,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*05*/TRCell():New(	oSectIte,"ESTADO"		,"QRY_AUX1","Est."  	     	  	,X3Picture("A2_EST")      ,	4							,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*06*/TRCell():New(	oSectIte,"CODMUN"		,"QRY_AUX1","Cod Mun."  		  	,X3Picture("A2_CODMUN")   ,	6							,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*07*/TRCell():New(	oSectIte,"D1DOC"		,"QRY_AUX1","Nota Fiscal"        	,X3Picture("D1_DOC")	  ,	TamSX3('D1_DOC')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*08*/TRCell():New(	oSectIte,"D1EMISSAO"	,"QRY_AUX1","Dt Emissao"         	,X3Picture("D1_EMISSAO")  ,	TamSX3('D1_EMISSAO')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*09*/TRCell():New(	oSectIte,"D1DESC"		,"QRY_AUX1","Produto"            	,X3Picture("B1_DESC")     ,	15							,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*10*/TRCell():New(	oSectIte,"D1QUANT"		,"QRY_AUX1","Qtde"	              	,X3Picture("D1_QUANT")    ,	TamSX3('D1_QUANT')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*11*/TRCell():New(	oSectIte,"D1TOTAL"		,"QRY_AUX1","Total"	          		,X3Picture("D1_TOTAL")    ,	TamSX3('D1_TOTAL')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*12*/TRCell():New(	oSectIte,"D1BASEFUN"	,"QRY_AUX1","Base Funrural"      	,X3Picture("D1_BASEFUN")  ,	TamSX3('D1_BASEFUN')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*13*/TRCell():New(	oSectIte,"D1ALIQFUN"	,"QRY_AUX1","Aliq."	          		,X3Picture("D1_ALIQFUN")  ,	TamSX3('D1_ALIQFUN')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*14*/TRCell():New(	oSectIte,"D1VALFUN"		,"QRY_AUX1","Valor Funrural"     	,X3Picture("D1_VALFUN")   ,	TamSX3('D1_VALFUN')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*15*/TRCell():New(	oSectIte,"VALOR_ICM"	,"QRY_AUX1","Valor ICMS."	      	,X3Picture("D1_VALICM")   ,	TamSX3('D1_VALICM')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*16*/TRCell():New(	oSectIte,"BS_FUN_S_ICM"	,"QRY_AUX1","Base Funf. S ICMS"  	,X3Picture("D1_BASEFUN")  ,	TamSX3('D1_BASEFUN')[01]	,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*17*/TRCell():New(	oSectIte,"FUN_CORR"		,"QRY_AUX1","Funrural a Recolher"	,X3Picture("D1_VALFUN")   ,	TamSX3('D1_VALFUN')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	/*18*/TRCell():New(	oSectIte,"FUN_REDUZ"	,"QRY_AUX1","Funrural Reduzido"  	,X3Picture("D1_VALFUN")   ,	TamSX3('D1_VALFUN')[01]		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/, .F.		    ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	                                                                                                                                                             
	// COLOCAR TOTALIZADORES
	oFunBaseFu := TRFunction():New(OSectIte:Cell("D1BASEFUN"),,"SUM",/*oBreak*/,/*cTitle*/,cPictBaseFun,/*uFormula*/,/*lEndSection*/.T.,/*lEndReport*/.T.)
	//oFunBaseFu:SetEndSection(.T.)
	//oFunBaseFu:SetEndReport(.T.)	//Define se será impresso o total também ao finalizar o relatório (Total Geral)
	oFunValFun := TRFunction():New(OSectIte:Cell("D1VALFUN"),,"SUM",/*oBreak*/,/*cTitle*/,cPictValFun,/*uFormula*/,/*lEndSection*/.T.,/*lEndReport*/.T.)
	//oFunValFun:SetEndSection(.T.)
	//oFunValFun:SetEndReport(.T.)
	oFunBaseIc:= TRFunction():New(oSectIte:Cell("BS_FUN_S_ICM"),,"SUM",/*oBreak*/,/*cTitle*/,cPictBaseIc,/*uFormula*/,/*lEndSection*/.T.,/*lEndReport*/.T.)
	//oFunBaseIc:SetEndSection(.T.)
	//oFunBaseIc:SetEndReport(.T.)	//Define se será impresso o total também ao finalizar o relatório (Total Geral)
	oFunrCorr := TRFunction():New(oSectIte:Cell("FUN_CORR"),,"SUM",/*oBreak*/,/*cTitle*/,cPictFunCor,/*uFormula*/,/*lEndSection*/.T.,/*lEndReport*/.T.)
	//oFunrCorr:SetEndSection(.T.)
	//oFunrCorr:SetEndReport(.T.)	//Define se será impresso o total também ao finalizar o relatório (Total Geral)
	oFunrRedu := TRFunction():New(oSectIte:Cell("FUN_REDUZ"),,"SUM",/*oBreak*/,/*cTitle*/,cPictFun,/*uFormula*/,/*lEndSection*/.T.,/*lEndReport*/.T.)
	oFunrRedu:SetEndSection(.T.)
	//oFunrRedu:SetEndReport(.T.)	//Define se será impresso o total também ao finalizar o relatório (Total Geral)
	
Return oReport // U_VACOMR06


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Arthur Toshio Oda Vanzella	                                          |
 | Data:  21.05.2017                                                              |
 | Desc:                                                  						  |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fRepPrint(oReport)
	Local aArea   := GetArea()
	Local cQuery := ""
	Local  := Nil
	Local oSectCab := Nil
	Local oSectIte := Nil
	
	//Pegando as seções do relatório
	//oSectPar := oReport:Section(1)
	oSectCab := oReport:Section(2)
	oSectIte := oReport:Section(2):Section(1)
	
	cQuery := ""
	cQuery := "	SELECT E2.E2_FILIAL					AS		E2FILIAL,	 " + CRLF
	cQuery += "		   E2.E2_FORNECE				AS		E2FORNECE,   " +CRLF
	cQuery += "		   A2.A2_NOME					AS		E2NOMEFOR,   " +CRLF
	cQuery += "		   A2.A2_MUN					AS		MUNICIPIO,	 " +CRLF
	cQuery += "        A2.A2_EST					AS		ESTADO,		" +CRLF
	cQuery += "        A2.A2_CODMUN					AS		CODMUN,   	" +CRLF
	cQuery += "   CASE WHEN A2_TIPO 	= 'J' 	THEN 'JUR.'  " +CRLF
	cQuery += "        WHEN A2_TIPO 	= 'F' 	THEN 'FIS' " +CRLF
	cQuery += "   ELSE 'OUTROS'					END AS		TIPO_PESSOA," +CRLF
	cQuery += "		   E2.E2_EMISSAO				AS		E2EMISSAO,   " +CRLF
	cQuery += "		   SUM(E2.E2_VALOR)				AS		E2VALOR,  " +CRLF
	cQuery += "	  CASE WHEN D1_TIPO = 'N' THEN 'NF'  " +CRLF
	cQuery += "		   WHEN D1_TIPO = 'C' THEN 'NF COMPLEMENTO' END AS D1_TIPO,  " +CRLF
	cQuery += "		   --D1.D1_TIPO					AS		D1TIPO,  " +CRLF
	cQuery += "		   D1.D1_DOC					AS		D1DOC,  " +CRLF
	cQuery += "		   D1.D1_SERIE					AS		D1SERIE,  " +CRLF
	cQuery += "		   D1.D1_EMISSAO				AS		D1EMISSAO,  " +CRLF
	cQuery += "	       D1.D1_GRUPO					AS		GRUPO,  " +CRLF
	cQuery += "        BM.BM_DESC					AS		DESC_GRUPO, " +CRLF
	cQuery += "		   D1_COD						AS		D1COD,  " +CRLF
	cQuery += "		   B1_DESC						AS		D1DESC,  " +CRLF
	cQuery += "		   D1_UM						AS		D1UM,  " +CRLF
	cQuery += "		   D1_QUANT						AS		D1QUANT,  " +CRLF
	cQuery += "		   D1_VUNIT						AS		D1VUNIT,  " +CRLF
	cQuery += "		   D1_TOTAL						AS		D1TOTAL,  " +CRLF
	cQuery += "		   D1_BASEFUN					AS		D1BASEFUN,  " +CRLF
	cQuery += "		   D1_ALIQFUN					AS		D1ALIQFUN,  " +CRLF
	cQuery += "		   D1_VALFUN					AS		D1VALFUN,  " +CRLF
	cQuery += "  	   (D1_BASEFUN-D1_VALICM)		AS		BS_FUN_S_ICM,  " +CRLF
	cQuery += "  	   ((D1_BASEFUN-D1_VALICM)*D1_ALIQFUN)/100 AS FUN_CORR,  " +CRLF
	cQuery += "  	   D1_VALICM					AS		VALOR_ICM,  " +CRLF
	cQuery += "  	   ((D1_VALICM)*D1_ALIQFUN/100)		    FUN_REDUZ,  " +CRLF	
	cQuery += "		   D1_BASEICM					AS		D1BASEIC,  " +CRLF
	cQuery += "		   D1_VALICM					AS		D1VALICM,  " +CRLF
	cQuery += "		   E22.E2_VALOR					AS		E22VALOR,  " +CRLF
	cQuery += "		   E22.E2_VENCREA				AS		E22VENCT  " +CRLF
	cQuery += "	  FROM " + RetSqlName('SE2') + " E2  " +CRLF
	cQuery += " INNER JOIN " + RetSqlName('SE2') + " E22 ON " +CRLF
	cQuery += " 	       E2.E2_FILIAL				=			E22.E2_FILIAL " + CRLF
	cQuery += " 	   AND E2.E2_NUM				=			E22.E2_NUM " + CRLF
	cQuery += " 	   AND E2.E2_EMISSAO			=			E22.E2_EMISSAO " + CRLF
	cQuery += " 	   AND E22.E2_TIPO				=			'TX '  " + CRLF
	cQuery += " 	   AND E22.E2_NATUREZ			IN 			('CSS       ', 'CSS', '257') " + CRLF
	cQuery += " 	   AND E22.D_E_L_E_T_			=			' '  " + CRLF
	cQuery += " INNER JOIN " + RetSqlName('SA2') + " A2 ON " + CRLF
	cQuery += " 	       E2.E2_FORNECE				=			A2_COD " + CRLF
	cQuery += " 	   AND E2.E2_LOJA					=			A2_LOJA	 " + CRLF
	cQuery += " 	   --AND A2_TIPORUR				=			'F' " + CRLF
	cQuery += " 	   AND A2.D_E_L_E_T_			=			' ' " + CRLF
	cQuery += " INNER JOIN " + RetSqlName('SD1') + " D1 ON " + CRLF
	cQuery += " 	       D1.D1_DOC				=			E2.E2_NUM " + CRLF
	cQuery += " 	   AND D1.D1_FORNECE			=			E2.E2_FORNECE " + CRLF
	cQuery += " 	   AND D1.D1_LOJA				=			E2.E2_LOJA " + CRLF
	cQuery += " 	   AND D1.D_E_L_E_T_			=			' ' " + CRLF
	cQuery += " INNER JOIN " + RetSqlName('SB1') + " B1 ON " + CRLF
	cQuery += " 	       B1.B1_COD				=			D1.D1_COD " + CRLF
	cQuery += " 	   AND B1.D_E_L_E_T_			=			' ' " + CRLF
	cQuery += " 	   AND B1.B1_CONTSOC			=			'S'		-- PRODUTO TEM FUNRURAL ? " + CRLF
	cQuery += " INNER JOIN " + RetSqlName('SF4') + " F4 ON " + CRLF
	cQuery += " 		   F4.F4_CODIGO				=			 D1.D1_TES " + CRLF
	cQuery += " 	   AND F4.D_E_L_E_T_			=			' ' " + CRLF
	cQuery += " INNER JOIN " + RetSqlName('SBM') + " BM ON " + CRLF
	cQuery += " 		   BM.BM_GRUPO				=			D1.D1_GRUPO " + CRLF
	cQuery += " 	   AND BM.D_E_L_E_T_			=			' ' "	+ CRLF
	cQuery += "    WHERE D1.D1_FILIAL				BETWEEN		'"+MV_PAR01+"'	AND			'"+MV_PAR02+"'  " + CRLF
	cQuery += " 	 AND D1.D1_EMISSAO				BETWEEN		'"+DTOS(MV_PAR03)+"'	AND			'"+DTOS(MV_PAR04)+"'  " + CRLF
	cQuery += " 	 AND D1.D1_FORNECE				BETWEEN		'"+MV_PAR05+"'  AND 		'"+MV_PAR06+"'  " + CRLF
	cQuery += " 	 AND B1.B1_GRUPO				BETWEEN		'"+MV_PAR07+"'	AND			'"+MV_PAR08+"'  " + CRLF
	cQuery += " 	   --AND E2.E2_NATUREZ			=			'CSS'   " + CRLF
	cQuery += " 	 AND E2.E2_TIPO					=			'NF'   " + CRLF
	cQuery += " GROUP BY E2.E2_FILIAL, E2.E2_FORNECE, A2.A2_NOME, A2.A2_TIPO, E2.E2_EMISSAO, E2.E2_TIPO, A2.A2_EST, A2.A2_MUN, A2.A2_EST, A2.A2_CODMUN,  " + CRLF
	cQuery += " D1_TIPO, D1_GRUPO, BM_DESC, D1_DOC, D1_SERIE,D1_EMISSAO, D1_COD,B1_DESC, D1_UM, D1_QUANT, D1_VUNIT, D1_TOTAL,D1_BASEICM,D1_VALICM, " + CRLF 
	cQuery += " D1_BASEFUN, D1_ALIQFUN, D1_VALFUN, E22.E2_VALOR, E22.E2_VENCREA  " + CRLF
	cQuery += " ORDER BY BM.BM_DESC, E2.E2_FILIAL, D1.D1_EMISSAO, D1.D1_DOC,  D1.D1_COD, A2.A2_NOME  " + CRLF
	
	TCQuery cQuery New Alias "QRY_AUX1"
	memowrite("C:\TOTVS\VACOMR06.txt", cQuery)
	
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	TcSetField("QRY_AUX1", "D1EMISSAO", "D")
	TcSetField("QRY_AUX1", "E22VENCT", "D")
	
	//Enquanto houver dados
	QRY_AUX1->(DbGoTop())
	While ! QRY_AUX1->(Eof())
		//Imprimindo o Cabeçalho
		oSectCab:Init()
		oSectCab:PrintLine()
		
		//Setando variaveis do Cabeçalho para quebra
		cGrupo 		 := QRY_AUX1->DESC_GRUPO
		dVencimento  := QRY_AUX1->E22VENCT
		oReport:SkipLine(1)
		oSectIte:Init()
		While !QRY_AUX1->(EoF()) .And. cGrupo ==  QRY_AUX1->DESC_GRUPO .And. dVencimento == QRY_AUX1->E22VENCT
			oSectIte:PrintLine()
			oReport:IncMeter()
			
			QRY_AUX1->(DbSkip())			
		EndDo
		oSectIte:Finish()
		oSectCab:Finish()
		oReport:SkipLine(2)
	EndDo
	
	QRY_AUX1->(DbCloseArea())

Return nil   // U_VACOMR06()


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Arthur Toshio Oda Vanzella                                              |
 | Data:  21.05.2017                                                              |
 | Desc:                                                  						  |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)
Local _aArea	:= GetArea()
Local nX		:= 0
Local nPergs	:= 0
Local aRegs		:= {}

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

AADD( aRegs, { cPerg, "01", "Filial de:          "        , "", "", "mv_ch1", TamSX3("D1_FILIAL")[3] , TamSX3("D1_FILIAL")[1] , TamSX3("D1_FILIAL")[2] , 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0", "S", "" ,"" ,"", "", {"Informe o código da filial desejada ou deixe em branco."  , "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "02", "Filial Ate:         "        , "", "", "mv_ch2", TamSX3("D1_FILIAL")[3] , TamSX3("D1_FILIAL")[1] , TamSX3("D1_FILIAL")[2] , 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0", "S", "" ,"" ,"", "", {"Informe o código da filial desejada ou deixe em branco."  , "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "03", "Dt. Emissao De:     "        , "", "", "mv_ch3", TamSX3("D1_EMISSAO")[3], TamSX3("D1_EMISSAO")[1], TamSX3("D1_EMISSAO")[2], 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", "S", "" ,"" ,"", "", {"Informe a Dt. de Emissao Inicial                       "  , "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "04", "Dt. Emissao Ate:    "        , "", "", "mv_ch4", TamSX3("D1_EMISSAO")[3], TamSX3("D1_EMISSAO")[1], TamSX3("D1_EMISSAO")[2], 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", "S", "" ,"" ,"", "", {"Informe a Dt. de Emissao Final                         "  , "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "05", "Fornecedor De:      "        , "", "", "mv_ch5", TamSX3("D1_FORNECE")[3], TamSX3("D1_FORNECE")[1], TamSX3("D1_FORNECE")[2], 0, "G", "", "mv_par05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA2", "S", "" ,"" ,"", "", {"Informe o código do Vendedor desejada ou deixe em branco.", "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "06", "Fornecedor Ate:     "        , "", "", "mv_ch6", TamSX3("D1_FORNECE")[3], TamSX3("D1_FORNECE")[1], TamSX3("D1_FORNECE")[2], 0, "G", "", "mv_par06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA2", "S", "" ,"" ,"", "", {"Informe o código do Vendedor desejada ou deixe em branco.", "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "07", "Grupo de Prod De:   "        , "", "", "mv_ch7", TamSX3("D1_GRUPO")[3]  , TamSX3("D1_GRUPO")[1]  , TamSX3("D1_GRUPO")[2]  , 0, "G", "", "mv_par07", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SBM", "S", "" ,"" ,"", "", {"Informe o código do Grupo de Produtos ou deixee m branco.", "<F3 Disponivel>"}, {""}, {""} } )
AADD( aRegs, { cPerg, "08", "Grupo de Prod Ate:  "        , "", "", "mv_ch8", TamSX3("D1_GRUPO")[3]  , TamSX3("D1_GRUPO")[1]  , TamSX3("D1_GRUPO")[2]  , 0, "G", "", "mv_par08", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SBM", "S", "" ,"" ,"", "", {"Informe o código do Grupo de Produtos ou deixee m branco.", "<F3 Disponivel>"}, {""}, {""} } )

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

Return nil	// U_VACOMM04()