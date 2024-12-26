#include "rwmake.ch"
#include "protheus.ch"     
#include "topconn.ch"    

//Constantes
#Define STR_PULA		Chr(13) + Chr(10)
#Define DMPAPER_A4 9

User Function VAESTR01()
	local oReport
	local cPerg := PadR('VAESTR01',10)
 
	ValidPerg(cPerg)

	If !Pergunte(cPerg,.T.)
		Return
	endif
	
	oReport := reportDef()
	oReport:printDialog()
Return
 
static function reportDef()
	Local oReport
	Local oSection1
	Local oSection2
	Local cTitulo := '[VAESTR01] - Movimentos de Documentos (NF Entrada + Mov. Internos + Titulos Pagar)'

	oReport := TReport():New('VAESTR01', cTitulo, , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de registros relacionados a composicao de custos, sendo itens de notas fiscais de custo direto, movimento internos de requisicao e titulos a pagar incluidos manualmente no modulo financeiro")
	oReport:SetLandscape()    // paisagem
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
 
	oSection1 := TRSection():New(oReport,"Movimentos de Documentos (NF Entrada + Mov. Internos + Titulos Pagar)",{"QRYCHQ"})
	oSection1:SetTotalInLine(.F.)          
	
	TRCell():New(oSection1, "TIPREG"		, "QRYCUS", 'Tipo Reg.'		,PesqPict('SE2',"E2_NUM")		,TamSX3("E2_NUM")[1]			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "XDIGITACAO"	, "QRYCUS", 'Dt Digitacao'	,PesqPict('SE2',"E2_EMISSAO")	,TamSX3("E2_EMISSAO")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "XXFILIAL" 		, "QRYCUS", 'Filial'		,PesqPict('SE2',"E2_FILIAL")	,TamSX3("E2_FILIAL")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XTES" 			, "QRYCUS", 'TES'			,PesqPict('SF4',"F4_CODIGO")	,TamSX3("F4_CODIGO")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XTESDESC" 		, "QRYCUS", 'Finalidade TES',PesqPict('SF4',"F4_FINALID")	,TamSX3("F4_FINALID")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XGRUPO" 		, "QRYCUS", 'Grupo'			,PesqPict('SBM',"BM_GRUPO")		,TamSX3("BM_GRUPO")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XGRUPODESC" 	, "QRYCUS", 'Desc.Grupo'	,PesqPict('SBM',"BM_DESC")		,TamSX3("BM_DESC")[1]+1	   		,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XPROD" 		, "QRYCUS", 'Produto'		,PesqPict('SB1',"B1_COD")		,TamSX3("B1_COD")[1]+1			,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XPRODDESC" 	, "QRYCUS", 'Desc.Produto'	,PesqPict('SB1',"B1_DESC")		,TamSX3("B1_DESC")[1]+1	   		,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XUM" 			, "QRYCUS", 'UM'			,PesqPict('SB1',"B1_UM")		,TamSX3("B1_UM")[1]+1			,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():new(oSection1, "XQUANT"		, "QRYCUS", "Quantidade"	,PesqPict('SD1',"D1_QUANT")		,TamSX3("D1_QUANT")[1]+1 		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "XVUNIT"		, "QRYCUS", "Vlr. Unit.e"	,PesqPict('SD1',"D1_VUNIT")		,TamSX3("D1_VUNIT")[1]+1 		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "XCUSTO"		, "QRYCUS", "Vlr Custo"		,PesqPict('SD1',"D1_CUSTO")		,TamSX3("D1_CUSTO")[1]+1 		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "XCLVL" 		, "QRYCUS", 'Local'			,PesqPict('SD1',"D1_CLVL")		,TamSX3("D1_CLVL")[1]+1			,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XCLVLDESC" 	, "QRYCUS", 'Desc. Local'	,PesqPict('CTH',"CTH_DESC01")	,TamSX3("CTH_DESC01")[1]+1	   	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XITEMC" 		, "QRYCUS", 'Processo'		,PesqPict('SD1',"D1_ITEMCTA")	,TamSX3("D1_ITEMCTA")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XITEMCDESC" 	, "QRYCUS", 'Desc. Processo',PesqPict('CTH',"CTD_DESC01")	,TamSX3("CTD_DESC01")[1]+1	   	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XCC" 			, "QRYCUS", 'C. Custo'		,PesqPict('SD1',"D1_CC")		,TamSX3("D1_CC")[1]+1			,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XCCDESC" 		, "QRYCUS", 'Desc. C.Custo' ,PesqPict('CTH',"CTT_DESC01")	,TamSX3("CTT_DESC01")[1]+1	   	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XOBSERV" 		, "QRYCUS", 'Observacao' 	,PesqPict('SE2',"E2_HIST")		,TamSX3("E2_HIST")[1]+1	   		,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "XDOCUMENTO"	, "QRYCUS", 'Documento'		,PesqPict('SF1',"F1_DOC")		,TamSX3("F1_DOC")[1]+1			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "XCLIFOR"		, "QRYCUS", 'Cli/For'		,PesqPict('SF1',"F1_FORNECE")	,TamSX3("F1_DOC")[1]+1			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "XRSOCIAL"		, "QRYCUS", 'R.Social'		,PesqPict('SA2',"A2_NOME")		,TamSX3("A2_NOME")[1]+1			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "XEMISSAO"		, "QRYCUS", 'Dt Emissao'	,PesqPict('SE2',"E2_EMISSAO")	,TamSX3("E2_EMISSAO")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "XUSUARIO"		, "QRYCUS", 'Usuario'		,PesqPict('SA2',"A2_NREDUZ")	,TamSX3("A2_NREDUZ")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "XCHVNFE"		, "QRYCUS", 'Chave Nf-e'	,PesqPict('SF1',"F1_CHVNFE")	,TamSX3("F1_CHVNFE")[1]+1			,/*lPixel*/,/*{|| code-block de impressao }*/)

//	oBreak := TRBreak():New(oSection1,oSection1:Cell("E5_FILIAL"),,.F.)
//	TRFunction():New(oSection1:Cell("C7_FILIAL"),"TOTAL FILIAL","COUNT",oBreak,,"@E 999999",,.F.,.F.)
// 	oImpress := mv_par16
// 	If oImpress == 1 .And. oSelection1:Cell()"TIPREG") == "MOV_INT"
 	
//	TRFunction():New(oSection1:Cell("TIPREG")   ,"Qtde de Registros"	,"COUNT",,,"@E 999999",,.F.,.T.)	
//	TRFunction():New(oSection1:Cell("XCUSTO") 	,"Valor Custo Total" 	,"SUM",,,PesqPict('SD1',"D1_CUSTO"),,.F.,.T.)	
//	TRFunction():New(oSection1:Cell("XQUANT") 	,"Quantidade Total" 	,"SUM",,,PesqPict('SD1',"D1_QUANT"),,.F.,.T.)	
	
return (oReport)
 
Static Function PrintReport(oReport)
 	Local cQRYCUS 	:= ''
	Local oSection1 := oReport:Section(1)
	Local nTotCusto := 0
	Local nTotQuant := 0
	
	If Select("QRYCUS") > 0
		QRYCUS->(DbCloseArea())
	EndIf

/*
 
SELECT * FROM SBM990

-- REGISTRO DE MOVIMENTO INTERNOS
SELECT 
'MOV_INT' AS TIPREG, 
D3_EMISSAO AS XDIGITACAO, 
D3_FILIAL AS XXFILIAL, 
'' AS XTES, 
'' AS XTESDESC,
B1_GRUPO AS XGRUPO, 
BM_DESC AS XGRUPODESC, 
D3_COD AS XPROD, 
B1_DESC AS XPRODDESC, 
D3_UM AS XUM, 
D3_QUANT AS XQUANT, 
0 AS XVUNIT, 
D3_CUSTO1 AS XCUSTO, 
D3_CLVL AS XCLVL,  
CTH_DESC01 AS XCLVLDESC, 
D3_ITEMCTA AS XITEMC, 
CTD_DESC01 AS XITEMCDESC,  
D3_CC AS XCC, 
CTT_DESC01 AS XCCDESC,
'D3_X_OBS' AS XOBSERV, 
D3_DOC AS XDOCUMENTO, 
'' AS XCLIFOR, 
''  AS XRSOCIAL, 
D3_EMISSAO AS XEMISSAO
FROM SD3010 SD3
LEFT JOIN SB1010 SB1 ON (B1_FILIAL  = '' AND B1_COD = D3_COD AND SB1.D_E_L_E_T_ = '')
LEFT JOIN CTT010 CTT ON (CTT_FILIAL = '' AND CTT_CUSTO = D3_CC AND CTT.D_E_L_E_T_='')
LEFT JOIN CTD010 CTD ON (CTD_FILIAL = '' AND CTD_ITEM = D3_ITEMCTA AND CTD.D_E_L_E_T_='')
LEFT JOIN CTH010 CTH ON (CTH_FILIAL = '' AND CTH_CLASSE = D3_CLVL AND CTH.D_E_L_E_T_='')
LEFT JOIN SBM010 SBM ON (BM_FILIAL  = '' AND BM_GRUPO = B1_GRUPO AND SBM.D_E_L_E_T_='')
WHERE SD3.D_E_L_E_T_ = ''
AND D3_EMISSAO	BETWEEN '' AND 'ZZ'
AND D3_CC		BETWEEN '' AND 'ZZ'
AND D3_ITEM		BETWEEN '' AND 'ZZ'
AND D3_CLVL		BETWEEN '' AND 'ZZ'
AND D3_ESTORNO = ''  AND D3_CF NOT IN ('RE4','DE4') AND D3_TM>= '500'

UNION 

-- REGISTRO DE ITENS DE ENTRADA
SELECT 'DOC_ENT' AS TIPREG, 
D1_DTDIGIT AS XDIGITACAO, 
D1_FILIAL AS XXFILIAL, 
D1_TES AS XTES, 
F4_TEXTO AS XTESDESC,
B1_GRUPO AS XGRUPO, 
BM_DESC AS XGRUPODESC, 
D1_COD AS XPROD, 
B1_DESC AS XX_PRODDESC, 
D1_UM AS XUM, 
D1_QUANT AS XQUANT, 
D1_VUNIT AS XVUNIT, 
D1_CUSTO AS XCUSTO, 
D1_CLVL AS XCLVL,  
CTH_DESC01 AS XCLVLDESC, 
D1_ITEMCTA AS XITEMC, 
CTD_DESC01 AS XITEMCDESC,  
D1_CC AS XCC, 
CTT_DESC01 AS XCCDESC,  
F1_MENNOTA AS XOBSERV, 
D1_DOC AS XDOCUMENTO, 
F1_FORNECE+F1_LOJA AS XCLIFOR,
CASE WHEN D1_TIPO IN ('B','D')  THEN A1_NOME ELSE A2_NOME END AS XRSOCIAL, 
D1_EMISSAO AS XEMISSAO
FROM SD1010 SD1
LEFT JOIN SF1010 SF1 ON (D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND SF1.D_E_L_E_T_ = '')
LEFT JOIN SA1010 SA1 ON (A1_FILIAL='' AND A1_COD=D1_FORNECE AND A1_LOJA=D1_LOJA AND SA1.D_E_L_E_T_='')
LEFT JOIN SA2010 SA2 ON (A2_FILIAL='' AND A2_COD=D1_FORNECE AND A2_LOJA=D1_LOJA AND SA2.D_E_L_E_T_='')
LEFT JOIN SB1010 SB1 ON (B1_FILIAL = '' AND B1_COD = D1_COD AND SB1.D_E_L_E_T_ = '')
LEFT JOIN CTT010 CTT ON (CTT_FILIAL = '' AND CTT_CUSTO = D1_CC AND CTT.D_E_L_E_T_='')
LEFT JOIN CTD010 CTD ON (CTD_FILIAL = '' AND CTD_ITEM = D1_ITEMCTA AND CTD.D_E_L_E_T_='')
LEFT JOIN CTH010 CTH ON (CTH_FILIAL = '' AND CTH_CLASSE = D1_CLVL AND CTH.D_E_L_E_T_='')
LEFT JOIN SF4010 SF4 ON (F4_FILIAL = '' AND F4_CODIGO=D1_TES AND SF4.D_E_L_E_T_='')
LEFT JOIN SBM010 SBM ON (BM_FILIAL  = '' AND BM_GRUPO = B1_GRUPO AND SBM.D_E_L_E_T_='')
WHERE SD1.D_E_L_E_T_ = ''
AND D1_DTDIGIT	BETWEEN '' AND 'ZZ'
AND D1_CC		BETWEEN '' AND ''
AND D1_ITEMCTA	BETWEEN '' AND 'ZZ'
AND D1_CLVL		BETWEEN '' AND 'ZZ'
AND F4_ESTOQUE = 'N' AND F4_DUPLIC = 'S'

UNION

-- REGISTRO DE TITULOS A PAGAR
SELECT 'TIT_PAG' AS TIPREG, 
E2_EMIS1   AS XDIGITACAO, 
E2_FILIAL AS XXFILIAL, 
'' AS XTES, 
'' AS XTESDESC,
'' AS XGRUPO, 
'' AS XGRUPODESC,  
E2_NATUREZ      AS XPROD, 
ED_DESCRIC      AS XPRODDESC, 
'' AS XUM,
 0 AS XQUANT,
 0 AS XVUNIT, 
 E2_VALOR AS XCUSTO, 
 E2_CLVLDB AS XCLVL,  
 CTH_DESC01 AS XCLVLDESC, 
 E2_ITEMD AS XITEMC, 
 CTD_DESC01 AS XITEMCDESC,  
 E2_CCD AS XCC, 
 CTT_DESC01 AS XCCDESC ,
 E2_HIST AS XOBSERV, 
 E2_NUM AS XDOCUMENTO, 
 E2_FORNECE+E2_LOJA AS XCLIFOR,
 A2_NOME AS XRSOCIAL, 
 E2_EMISSAO AS XEMISSAO
FROM SE2010 SE2
LEFT JOIN SED010 SED ON (ED_FILIAL  = '' AND ED_CODIGO=E2_NATUREZ AND SED.D_E_L_E_T_='')
LEFT JOIN SA2010 SA2 ON (A2_FILIAL  = '' AND A2_COD=E2_FORNECE AND A2_LOJA=E2_LOJA AND SA2.D_E_L_E_T_='')
LEFT JOIN CTT010 CTT ON (CTT_FILIAL = '' AND CTT_CUSTO = E2_CCD AND CTT.D_E_L_E_T_='')
LEFT JOIN CTD010 CTD ON (CTD_FILIAL = '' AND CTD_ITEM = E2_ITEMD AND CTD.D_E_L_E_T_='')
LEFT JOIN CTH010 CTH ON (CTH_FILIAL = '' AND CTH_CLASSE = E2_CLVLDB AND CTH.D_E_L_E_T_='')
WHERE SE2.D_E_L_E_T_ = ''
AND E2_EMIS1	BETWEEN '' AND 'ZZ'
AND E2_CCD		BETWEEN '' AND ''
AND E2_ITEMD	BETWEEN '' AND 'ZZ'
AND E2_CLVLDB	BETWEEN '' AND 'ZZ'
AND E2_ORIGEM LIKE '%FINA%'

ORDER BY XEMISSAO, TIPREG, XXFILIAL, XCC, XITEMC, XCLVL

*/ 
	oImpress := mv_par16

	//-- REGISTRO DE MOVIMENTO INTERNOS
	cQRYCUS += 	" SELECT "								+ STR_PULA
	cQRYCUS += 	" 'MOV_INT' AS TIPREG, "				+ STR_PULA   
	cQRYCUS += 	" D3_EMISSAO AS XDIGITACAO, "			+ STR_PULA 
	cQRYCUS += 	" D3_FILIAL AS XXFILIAL, "				+ STR_PULA
	cQRYCUS += 	" '' AS XTES, "							+ STR_PULA
	cQRYCUS += 	" '' AS XTESDESC, "						+ STR_PULA
	cQRYCUS += 	" B1_GRUPO AS XGRUPO, "					+ STR_PULA 
	cQRYCUS += 	" BM_DESC AS XGRUPODESC, "				+ STR_PULA 
	cQRYCUS += 	" D3_COD AS XPROD, "					+ STR_PULA 
	cQRYCUS += 	" B1_DESC AS XPRODDESC, "				+ STR_PULA 
	cQRYCUS += 	" D3_UM AS XUM, "						+ STR_PULA
	cQRYCUS += 	" D3_QUANT AS XQUANT, "					+ STR_PULA 
	cQRYCUS += 	" 0 AS XVUNIT, "						+ STR_PULA
	cQRYCUS += 	" D3_CUSTO1 AS XCUSTO, "				+ STR_PULA
	cQRYCUS += 	" D3_CLVL AS XCLVL,  "					+ STR_PULA
	cQRYCUS += 	" CTH_DESC01 AS XCLVLDESC, "			+ STR_PULA
	cQRYCUS += 	" D3_ITEMCTA AS XITEMC, "				+ STR_PULA
	cQRYCUS += 	" CTD_DESC01 AS XITEMCDESC, "			+ STR_PULA 
	cQRYCUS += 	" D3_CC AS XCC, "						+ STR_PULA 
	cQRYCUS += 	" CTT_DESC01 AS XCCDESC, "				+ STR_PULA
	cQRYCUS += 	" D3_X_OBS AS XOBSERV,  "				+ STR_PULA
	cQRYCUS += 	" D3_DOC AS XDOCUMENTO,   "				+ STR_PULA
	cQRYCUS += 	" '' AS XCLIFOR, "						+ STR_PULA
	cQRYCUS += 	" ''  AS XRSOCIAL, "					+ STR_PULA
	cQRYCUS += 	" D3_EMISSAO AS XEMISSAO, "				+ STR_PULA
	cQRYCUS += 	" D3_USUARIO AS XUSUARIO, "				+ STR_PULA
	cQRYCUS += 	" '' AS XCHVNFE, "						+ STR_PULA
	cQRYCUS += 	" SD3.R_E_C_N_O_ AS TABRECNO "			+ STR_PULA
	cQRYCUS += 	" FROM " + RetSqlName("SD3") + " SD3 "	+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("SB1") + " SB1 ON (B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_COD = D3_COD AND SB1.D_E_L_E_T_ = '') "				+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("CTT") + " CTT ON (CTT_FILIAL = '"+xFilial('CTT')+"' AND CTT_CUSTO = D3_CC AND CTT.D_E_L_E_T_='') "				+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("CTD") + " CTD ON (CTD_FILIAL = '"+xFilial('CTD')+"' AND CTD_ITEM = D3_ITEMCTA AND CTD.D_E_L_E_T_='') "			+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("CTH") + " CTH ON (CTH_FILIAL = '"+xFilial('CTH')+"' AND CTH_CLVL = D3_CLVL AND CTH.D_E_L_E_T_='') "			+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("SBM") + " SBM ON (BM_FILIAL  = '"+xFilial('SBM')+"' AND BM_GRUPO = B1_GRUPO AND SBM.D_E_L_E_T_='') "			+ STR_PULA
	cQRYCUS += 	" WHERE SD3.D_E_L_E_T_ = '' "					+ STR_PULA
	cQRYCUS += 	" AND D3_FILIAL		BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "'  "		+ STR_PULA
	cQRYCUS += 	" AND D3_EMISSAO	BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'  "		+ STR_PULA
	cQRYCUS += 	" AND D3_EMISSAO	BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "'  "		+ STR_PULA
	cQRYCUS += 	" AND D3_CC			BETWEEN '" + mv_par08 + "' AND '" + mv_par09 + "'  "		+ STR_PULA
	cQRYCUS += 	" AND D3_ITEMCTA	BETWEEN '" + mv_par10 + "' AND '" + mv_par11 + "'  "		+ STR_PULA
	cQRYCUS += 	" AND D3_CLVL		BETWEEN '" + mv_par12 + "' AND '" + mv_par13 + "'  "		+ STR_PULA
	cQRYCUS += 	" AND D3_ESTORNO = ''  AND D3_CF NOT IN ('RE4','DE4') AND D3_TM>= '500' "		+ STR_PULA
	cQRYCUS += 	" AND D3_GRUPO		BETWEEN '" + mv_par14 + "' AND '" + mv_par15 + "'  "		+ STR_PULA
	
	cQRYCUS += 	" UNION "							+ STR_PULA
	
	//-- REGISTRO DE ITENS DE ENTRADA
	cQRYCUS += 	" SELECT 'DOC_ENT' AS TIPREG, "		+ STR_PULA 
	cQRYCUS += 	" D1_DTDIGIT AS XDIGITACAO,  "		+ STR_PULA
	cQRYCUS += 	" D1_FILIAL AS XXFILIAL,  "			+ STR_PULA
	cQRYCUS += 	" D1_TES AS XTES, "					+ STR_PULA
	cQRYCUS += 	" F4_FINALID AS XTESDESC, "			+ STR_PULA
	cQRYCUS += 	" B1_GRUPO AS XGRUPO, "				+ STR_PULA
	cQRYCUS += 	" BM_DESC AS XGRUPODESC, "			+ STR_PULA
	cQRYCUS += 	" D1_COD AS XPROD,  "				+ STR_PULA
	cQRYCUS += 	" B1_DESC AS XX_PRODDESC, "			+ STR_PULA
	cQRYCUS += 	" D1_UM AS XUM, "					+ STR_PULA
	cQRYCUS += 	" D1_QUANT AS XQUANT, "				+ STR_PULA
	cQRYCUS += 	" D1_VUNIT AS XVUNIT, "				+ STR_PULA
	cQRYCUS += 	" D1_CUSTO AS XCUSTO, "				+ STR_PULA
	cQRYCUS += 	" D1_CLVL AS XCLVL,  "				+ STR_PULA
	cQRYCUS += 	" CTH_DESC01 AS XCLVLDESC, "		+ STR_PULA
	cQRYCUS += 	" D1_ITEMCTA AS XITEMC, "			+ STR_PULA
	cQRYCUS += 	" CTD_DESC01 AS XITEMCDESC,  "		+ STR_PULA
	cQRYCUS += 	" D1_CC AS XCC, "					+ STR_PULA
	cQRYCUS += 	" CTT_DESC01 AS XCCDESC,  "			+ STR_PULA
	cQRYCUS += 	" F1_MENNOTA AS XOBSERV, "			+ STR_PULA
	cQRYCUS += 	" D1_DOC AS XDOCUMENTO, "			+ STR_PULA
	cQRYCUS += 	" F1_FORNECE+F1_LOJA AS XCLIFOR, "	+ STR_PULA
	cQRYCUS += 	" CASE WHEN D1_TIPO IN ('B','D')  THEN A1_NOME ELSE A2_NOME END AS XRSOCIAL, "			+ STR_PULA
	cQRYCUS += 	" D1_EMISSAO AS XEMISSAO, "			+ STR_PULA
	cQRYCUS += 	" F1_USERLGI AS XUSUARIO, "			+ STR_PULA
	cQRYCUS += 	" F1_CHVNFE  AS XCHVNFE, "			+ STR_PULA
	cQRYCUS += 	" SF1.R_E_C_N_O_ AS TABRECNO "		+ STR_PULA
	cQRYCUS += 	" FROM SD1010 SD1 "					+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("SF1") + " SF1 ON (D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND SF1.D_E_L_E_T_ = '') "			+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("SA1") + " SA1 ON (A1_FILIAL='"+xFilial('SA1')+"' AND A1_COD=D1_FORNECE AND A1_LOJA=D1_LOJA AND SA1.D_E_L_E_T_='') "			+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("SA2") + " SA2 ON (A2_FILIAL='"+xFilial('SA2')+"' AND A2_COD=D1_FORNECE AND A2_LOJA=D1_LOJA AND SA2.D_E_L_E_T_='') "			+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("SB1") + " SB1 ON (B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = D1_COD AND SB1.D_E_L_E_T_ = '') "			+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("CTT") + " CTT ON (CTT_FILIAL = '"+xFilial('CTT')+"' AND CTT_CUSTO = D1_CC AND CTT.D_E_L_E_T_='') "			+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("CTD") + " CTD ON (CTD_FILIAL = '"+xFilial('CTD')+"' AND CTD_ITEM = D1_ITEMCTA AND CTD.D_E_L_E_T_='') "		+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("CTH") + " CTH ON (CTH_FILIAL = '"+xFilial('CTH')+"' AND CTH_CLVL = D1_CLVL AND CTH.D_E_L_E_T_='') "		+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("SF4") + " SF4 ON (F4_FILIAL = '"+xFilial('SF4')+"' AND F4_CODIGO=D1_TES AND SF4.D_E_L_E_T_='') "				+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("SBM") + " SBM ON (BM_FILIAL  = '"+xFilial('SBM')+"' AND BM_GRUPO = B1_GRUPO AND SBM.D_E_L_E_T_='') "			+ STR_PULA
	cQRYCUS += 	" WHERE SD1.D_E_L_E_T_ = '' "						+ STR_PULA
	cQRYCUS += 	" AND D1_FILIAL		BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "'  "		+ STR_PULA
	cQRYCUS += 	" AND D1_DTDIGIT	BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "			+ STR_PULA
	cQRYCUS += 	" AND D1_EMISSAO	BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "' "			+ STR_PULA
	cQRYCUS += 	" AND D1_CC			BETWEEN '" + mv_par08 + "' AND '" + mv_par09 + "' "			+ STR_PULA
	cQRYCUS += 	" AND D1_ITEMCTA	BETWEEN '" + mv_par10 + "' AND '" + mv_par11 + "' "			+ STR_PULA
	cQRYCUS += 	" AND D1_CLVL		BETWEEN '" + mv_par12 + "' AND '" + mv_par13 + "' "			+ STR_PULA
	cQRYCUS += 	" AND F4_ESTOQUE = 'N' AND F4_DUPLIC = 'S' "		+ STR_PULA
	cQRYCUS += 	" AND D1_GRUPO		BETWEEN '" + mv_par14 + "' AND '" + mv_par15 + "' "			+ STR_PULA
	
	cQRYCUS += 	" UNION "			+ STR_PULA
	
	//-- REGISTRO DE TITULOS A PAGAR
	cQRYCUS += 	" SELECT 'TIT_PAG' AS TIPREG, "			+ STR_PULA 
	cQRYCUS += 	" E2_EMIS1   AS XDIGITACAO,  "			+ STR_PULA
	cQRYCUS += 	" E2_FILIAL AS XXFILIAL,  "				+ STR_PULA
	cQRYCUS += 	" '' AS XTES, "							+ STR_PULA
	cQRYCUS += 	" '' AS XTESDESC, "						+ STR_PULA
	cQRYCUS += 	" '' AS XGRUPO, "						+ STR_PULA 
	cQRYCUS += 	" '' AS XGRUPODESC,   "					+ STR_PULA
	cQRYCUS += 	" E2_NATUREZ      AS XPROD,  "			+ STR_PULA
	cQRYCUS += 	" ED_DESCRIC      AS XPRODDESC,  "		+ STR_PULA
	cQRYCUS += 	" '' AS XUM, "							+ STR_PULA
	cQRYCUS += 	"  0 AS XQUANT, "						+ STR_PULA
	cQRYCUS += 	"  0 AS XVUNIT,  "						+ STR_PULA
	cQRYCUS += 	"  E2_VALOR AS XCUSTO,  "				+ STR_PULA
	cQRYCUS += 	"  E2_CLVLDB AS XCLVL,   "				+ STR_PULA
	cQRYCUS += 	"  CTH_DESC01 AS XCLVLDESC,  "			+ STR_PULA
	cQRYCUS += 	"  E2_ITEMD AS XITEMC,  "				+ STR_PULA
	cQRYCUS += 	"  CTD_DESC01 AS XITEMCDESC,   "		+ STR_PULA
	cQRYCUS += 	"  E2_CCD AS XCC,  "					+ STR_PULA
	cQRYCUS += 	"  CTT_DESC01 AS XCCDESC , "			+ STR_PULA
	cQRYCUS += 	"  E2_HIST AS XOBSERV,  "				+ STR_PULA
	cQRYCUS += 	"  E2_NUM AS XDOCUMENTO,  "				+ STR_PULA
	cQRYCUS += 	"  E2_FORNECE+E2_LOJA AS XCLIFOR, "		+ STR_PULA
	cQRYCUS += 	"  A2_NOME AS XRSOCIAL,  "				+ STR_PULA
	cQRYCUS += 	"  E2_EMISSAO AS XEMISSAO, "			+ STR_PULA
	cQRYCUS += 	"  E2_USERLGI AS XUSUARIO, "			+ STR_PULA
	cQRYCUS += 	" '' AS XCHVNFE, "						+ STR_PULA
	cQRYCUS += 	" SE2.R_E_C_N_O_ AS TABRECNO "			+ STR_PULA
	cQRYCUS += 	" FROM SE2010 SE2 "						+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("SED") + " SED ON (ED_FILIAL  = '"+xFilial('SED')+"' AND ED_CODIGO=E2_NATUREZ AND SED.D_E_L_E_T_='') "							+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("SA2") + " SA2 ON (A2_FILIAL  = '"+xFilial('SA2')+"' AND A2_COD=E2_FORNECE AND A2_LOJA=E2_LOJA AND SA2.D_E_L_E_T_='') "			+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("CTT") + " CTT ON (CTT_FILIAL = '"+xFilial('CTT')+"' AND CTT_CUSTO = E2_CCD AND CTT.D_E_L_E_T_='') "								+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("CTD") + " CTD ON (CTD_FILIAL = '"+xFilial('CTD')+"' AND CTD_ITEM = E2_ITEMD AND CTD.D_E_L_E_T_='') "							+ STR_PULA
	cQRYCUS += 	" LEFT JOIN " + RetSqlName("CTH") + " CTH ON (CTH_FILIAL = '"+xFilial('CTH')+"' AND CTH_CLVL = E2_CLVLDB AND CTH.D_E_L_E_T_='') "							+ STR_PULA
	cQRYCUS += 	" WHERE SE2.D_E_L_E_T_ = '' "					+ STR_PULA
	cQRYCUS += 	" AND E2_FILIAL		BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "'  "		+ STR_PULA
	cQRYCUS += 	" AND E2_EMIS1		BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "			+ STR_PULA
	cQRYCUS += 	" AND E2_EMISSAO	BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "' "			+ STR_PULA
	cQRYCUS += 	" AND E2_CCD		BETWEEN '" + mv_par08 + "' AND '" + mv_par09 + "'  "		+ STR_PULA
	cQRYCUS += 	" AND E2_ITEMD		BETWEEN '" + mv_par10 + "' AND '" + mv_par11 + "' "			+ STR_PULA
	cQRYCUS += 	" AND E2_CLVLDB		BETWEEN '" + mv_par12 + "' AND '" + mv_par13 + "' "			+ STR_PULA
	cQRYCUS += 	" AND E2_ORIGEM LIKE '%FINA%' "					+ STR_PULA
	
	If mv_par05 == 1 // Dt Digitacao
		cQRYCUS += 	" ORDER BY XDIGITACAO, TIPREG, XXFILIAL, XCC, XITEMC, XCLVL, XDOCUMENTO "		+ STR_PULA
	endif
	If mv_par05 == 2 // Dt Emissao
		cQRYCUS += 	" ORDER BY XEMISSAO, TIPREG, XXFILIAL, XCC, XITEMC, XCLVL, XDOCUMENTO "			+ STR_PULA
	endif
	
	If select('QRYCUS') > 0
		QRYCUS->(dbCloseArea())
	Endif
	TCQUERY cQRYCUS NEW ALIAS "QRYCUS"    
	MemoWrite("c:\TOTVS\vaestr01_qry.txt",cQRYCUS)
	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
 
	DbSelectArea('QRYCUS')
	QRYCUS->(dbGoTop())
	oReport:SetMeter(QRYCUS->(RecCount()))
	While QRYCUS->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf
 
		oReport:IncMeter()

		oSection1:Cell("TIPREG"):SetValue(QRYCUS->TIPREG)
		oSection1:Cell("TIPREG"):SetAlign("LEFT")
 
		oSection1:Cell("XDIGITACAO"):SetValue(STOD(QRYCUS->XDIGITACAO))
		oSection1:Cell("XDIGITACAO"):SetAlign("CENTER")

		oSection1:Cell("XXFILIAL"):SetValue(QRYCUS->XXFILIAL)
		oSection1:Cell("XXFILIAL"):SetAlign("LEFT")
 
		oSection1:Cell("XTES"):SetValue(QRYCUS->XTES)
		oSection1:Cell("XTES"):SetAlign("LEFT")
 
		oSection1:Cell("XTESDESC"):SetValue(QRYCUS->XTESDESC)
		oSection1:Cell("XTESDESC"):SetAlign("LEFT")

		oSection1:Cell("XGRUPO"):SetValue(QRYCUS->XGRUPO)
		oSection1:Cell("XGRUPO"):SetAlign("LEFT")

		oSection1:Cell("XGRUPODESC"):SetValue(UPPER(QRYCUS->XGRUPODESC))
		oSection1:Cell("XGRUPODESC"):SetAlign("LEFT")

		oSection1:Cell("XPROD"):SetValue(QRYCUS->XPROD)
		oSection1:Cell("XPROD"):SetAlign("LEFT")

		oSection1:Cell("XPRODDESC"):SetValue(QRYCUS->XPRODDESC)
		oSection1:Cell("XPRODDESC"):SetAlign("LEFT")
		
		oSection1:Cell("XUM"):SetValue(QRYCUS->XUM)
		oSection1:Cell("XUM"):SetAlign("LEFT")

		oSection1:Cell("XQUANT"):SetValue(QRYCUS->XQUANT)
		oSection1:Cell("XQUANT"):SetAlign("RIGTH")

		oSection1:Cell("XVUNIT"):SetValue(QRYCUS->XVUNIT)
		oSection1:Cell("XVUNIT"):SetAlign("RIGTH")

		oSection1:Cell("XCUSTO"):SetValue(QRYCUS->XCUSTO)
		oSection1:Cell("XCUSTO"):SetAlign("RIGTH")

		oSection1:Cell("XCLVL"):SetValue(QRYCUS->XCLVL)
		oSection1:Cell("XCLVL"):SetAlign("LEFT")

		oSection1:Cell("XCLVLDESC"):SetValue(QRYCUS->XCLVLDESC)
		oSection1:Cell("XCLVLDESC"):SetAlign("LEFT")

		oSection1:Cell("XITEMC"):SetValue(QRYCUS->XITEMC)
		oSection1:Cell("XITEMC"):SetAlign("LEFT")

		oSection1:Cell("XITEMCDESC"):SetValue(QRYCUS->XITEMCDESC)
		oSection1:Cell("XITEMCDESC"):SetAlign("LEFT")

		oSection1:Cell("XCC"):SetValue(QRYCUS->XCC)
		oSection1:Cell("XCC"):SetAlign("LEFT")

		oSection1:Cell("XCCDESC"):SetValue(QRYCUS->XCCDESC)
		oSection1:Cell("XCCDESC"):SetAlign("LEFT")

		oSection1:Cell("XOBSERV"):SetValue(QRYCUS->XOBSERV)
		oSection1:Cell("XOBSERV"):SetAlign("LEFT")

		oSection1:Cell("XDOCUMENTO"):SetValue(QRYCUS->XDOCUMENTO)
		oSection1:Cell("XDOCUMENTO"):SetAlign("LEFT")

		oSection1:Cell("XCLIFOR"):SetValue(QRYCUS->XCLIFOR)
		oSection1:Cell("XCLIFOR"):SetAlign("LEFT")

		oSection1:Cell("XRSOCIAL"):SetValue(QRYCUS->XRSOCIAL)
		oSection1:Cell("XRSOCIAL"):SetAlign("LEFT")

		oSection1:Cell("XEMISSAO"):SetValue(STOD(QRYCUS->XEMISSAO))
		oSection1:Cell("XEMISSAO"):SetAlign("CENTER")
		
		If ALLTRIM(QRYCUS->TIPREG)$'DOC_ENT'
			SF1->(DbGoTo(QRYCUS->TABRECNO))
			cUsrInc := FWLeUserlg("F1_USERLGI", 1)
		ElseIf ALLTRIM(QRYCUS->TIPREG)$'TIT_PAG'
			SE2->(DbGoTo(QRYCUS->TABRECNO))
			cUsrInc := FWLeUserlg("E2_USERLGI", 1)
        Else
			cUsrInc := QRYCUS->XUSUARIO
		Endif	
		
		oSection1:Cell("XUSUARIO"):SetValue( cUsrInc )       
		oSection1:Cell("XUSUARIO"):SetAlign("LEFT")

		oSection1:Cell("XCHVNFE"):SetValue(QRYCUS->XCHVNFE)
		oSection1:Cell("XCHVNFE"):SetAlign("LEFT")
		
		
		If oImpress == 1 .And. QRYCUS->TIPREG == "MOV_INT"
			oSection1:PrintLine()
		ElseIf oImpress == 2 .And. QRYCUS->TIPREG == "DOC_ENT"
			oSection1:PrintLine()
		Elseif oImpress == 3 .And. QRYCUS->TIPREG == "TIT_PAG"
			oSection1:PrintLine()
		Elseif oImpress == 4
			oSection1:PrintLine()
		EndIf
		nTotCusto += QRYCUS->XCUSTO
		nTotQuant += QRYCUS->XQUANT
 
		dbSelectArea("QRYCUS")
		QRYCUS->(dbSkip())
				
	EndDo

		oReport:IncMeter()
		oSection1:Cell("TIPREG"):SetValue('TOTAL GERAL')
		oSection1:Cell("TIPREG"):SetAlign("LEFT")
		oSection1:Cell("XQUANT"):SetValue(nTotQuant)
		oSection1:Cell("XQUANT"):SetAlign("RIGTH")
		oSection1:Cell("XCUSTO"):SetValue(nTotCusto)
		oSection1:Cell("XCUSTO"):SetAlign("RIGTH")

		oSection1:Cell("XDIGITACAO"):SetValue("")
		oSection1:Cell("XXFILIAL"):SetValue("")
		oSection1:Cell("XTES"):SetValue("") 
		oSection1:Cell("XTESDESC"):SetValue("")
		oSection1:Cell("XGRUPO"):SetValue("")
		oSection1:Cell("XGRUPODESC"):SetValue("")
		oSection1:Cell("XPROD"):SetValue("")
		oSection1:Cell("XPRODDESC"):SetValue("")
		oSection1:Cell("XUM"):SetValue("")
		oSection1:Cell("XVUNIT"):SetValue()
		oSection1:Cell("XCLVL"):SetValue("")
		oSection1:Cell("XCLVLDESC"):SetValue("")
		oSection1:Cell("XITEMC"):SetValue("")
		oSection1:Cell("XITEMCDESC"):SetValue("")
		oSection1:Cell("XCC"):SetValue("")
		oSection1:Cell("XCCDESC"):SetValue("")
		oSection1:Cell("XOBSERV"):SetValue("")
		oSection1:Cell("XDOCUMENTO"):SetValue("")
		oSection1:Cell("XCLIFOR"):SetValue("")
		oSection1:Cell("XRSOCIAL"):SetValue("")
		oSection1:Cell("XEMISSAO"):SetValue("")
		oSection1:Cell("XUSUARIO"):SetValue("")       
		oSection1:Cell("XCHVNFE"):SetValue("")
		
	
		oSection1:PrintLine()

	oSection1:Finish()
	QRYCUS->(DbCloseArea())
Return
        


Static Function ValidPerg(cPerg)        
Local _sAlias, i, j

	_sAlias	:=	Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg 	:=	PADR(cPerg,10)
	aRegs	:=	{}
	//                                                                                                      -- 02 03 04 05 -- 07 08 09 10 -- 12 13 14 15 -- 17 18 19 20 -- 22 23 24 F3
	AADD(aRegs,{cPerg,"01","Dt Digitacao De  ?",Space(20),Space(20),"mv_ch1","D",08						,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Dt Digitacao Até ?",Space(20),Space(20),"mv_ch2","D",08						,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Dt Emissao De    ?",Space(20),Space(20),"mv_ch3","D",08						,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Dt Emissao Ate   ?",Space(20),Space(20),"mv_ch4","D",08						,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Ordem Impressao  ?",Space(20),Space(20),"mv_ch5","N",01						,0,0,"C","","mv_par05","Dt Digitacao","","","","","Dt Emissao","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"06","Filial De        ?",Space(20),Space(20),"mv_ch6","C",02						,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SM0"  ,"","","","","",""})
	AADD(aRegs,{cPerg,"07","Filial Até       ?",Space(20),Space(20),"mv_ch7","C",02						,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SM0"  ,"","","","","",""})
	AADD(aRegs,{cPerg,"08","C.Custo De       ?",Space(20),Space(20),"mv_ch8","C",TamSX3("D1_CC")[1]		,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","CTT_X","","","","","",""})
	AADD(aRegs,{cPerg,"09","C.Custo Até      ?",Space(20),Space(20),"mv_ch9","C",TamSX3("D1_CC")[1]		,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","CTT_X","","","","","",""})
	AADD(aRegs,{cPerg,"10","Processo De      ?",Space(20),Space(20),"mv_cha","C",TamSX3("D1_ITEMCTA")[1],0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","CTDX1","","","","","",""})
	AADD(aRegs,{cPerg,"11","Processo Até     ?",Space(20),Space(20),"mv_chb","C",TamSX3("D1_ITEMCTA")[1],0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","CTDX1","","","","","",""})
	AADD(aRegs,{cPerg,"12","Local De         ?",Space(20),Space(20),"mv_chc","C",TamSX3("D1_CLVL")[1]	,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","CTH","","","","","",""})
	AADD(aRegs,{cPerg,"13","Local Até        ?",Space(20),Space(20),"mv_chd","C",TamSX3("D1_CLVL")[1]	,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","CTH","","","","","",""})
	AADD(aRegs,{cPerg,"14","Grupo de         ?",Space(20),Space(20),"mv_che","C",TamSX3("D1_GRUPO")[1]	,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","","",""})	
	AADD(aRegs,{cPerg,"15","Grupo Até        ?",Space(20),Space(20),"mv_chf","C",TamSX3("D1_GRUPO")[1]	,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","","",""})
	AADD(aRegs,{cPerg,"16","Imprimir		 ?",Space(20),Space(20),"mv_chg","N",01						,0,0,"C","","mv_par16","M. Estoque","","","","","NF Entrada","","","","","Fnanceiro","","","","","Todos","","","","","","","","","","","","","","",""})
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				FieldPut(j,aRegs[i,j])
			Next
			MsUnlock()
			dbCommit()
		Endif
	Next
	
	dbSelectArea(_sAlias)
	
Return

