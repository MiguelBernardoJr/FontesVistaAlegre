//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)


/*/{Protheus.doc} VAFINR08
//Relat�rio para listagem dos adiantamentos (RA) e dos t�tulos compensados.
@author Arthur Toshio
@since 11/10/2016
@version undefined
 	@example 
 		u_VAFINR08()
@type function
/*/
User Function VAFINR08()

Local aArea		:= GetArea()
Local oReport
Private cPerg	:= "X_VAFINR08"
Private cFilDe	:= ""
Private cFilAt  := ""
Private dEmiDe	:= StoD("")
Private dEmiAt	:= StoD("")
Private cCliDe	:= ""
Private cCliAt	:= ""

	fVldPerg(cPerg)
	While Pergunte(cPerg,.T.)
		cFilDe	:= MV_PAR01
		cFilAt  := MV_PAR02
		dEmiDe	:= MV_PAR03
		dEmiAt	:= MV_PAR04
		cCliDe	:= MV_PAR05
		cCliAt	:= MV_PAR06
		
		oReport := fReportDef()
		oReport:PrintDialog()
	EndDo
	
	RestArea(aArea)
		
Return

/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Autor: Arthur Toshio                                                          |
 | Data:  13/10/2016                                                             |
 | Desc:  Fun��o que monta a defini��o do relat�rio                              |
 *-------------------------------------------------------------------------------*/

Static Function fReportDef()
	Local oReport
	Local oSctnPar   := Nil
	Local oSectCab   := Nil
	Local oSectIte   := Nil
	Local cPictTot   := PesqPict('SE5', 'E5_VALOR')
	//Local cPictQtd   := PesqPict('SE1', 'E1_SALDO')
	Local oFuncTotal := Nil
	Local oFuncQuant := Nil

	//Cria��o do componente de impress�o
	oReport := TReport():New(	"VAFINR08",;														//Nome do Relat�rio
									"Rel. Compensa��o de ADT (Carteira Receber)",;					//T�tulo
									,;																//Pergunte ... Se eu defino a pergunta aqui, ser� impresso uma p�gina com os par�metros, conforme privil�gio 101
									{|oReport| fRepPrint(oReport)},;								//Bloco de c�digo que ser� executado na confirma��o da impress�o
									)																	//Descri��o
	oReport:SetLandscape(.T.)   //Define a orienta��o de p�gina do relat�rio como paisagem  ou retrato. .F.=Retrato; .T.=Paisagem
	oReport:SetTotalInLine(.F.) //Define se os totalizadores ser�o impressos em linha ou coluna
	oReport:ShowHeader()
	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf

	//*******************
	// PAR�METROS
	//*******************
	
	//Criando a se��o de par�metros e as c�lulas
	oSectPar := TRSection():New(	oReport,;				//Objeto TReport que a se��o pertence
										"Par�metros",;		//Descri��o da se��o
										{""})					//Tabelas utilizadas, a primeira ser� considerada como principal da se��o
	oSectPar:SetTotalInLine(.F.)  //Define se os totalizadores ser�o impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//C�lulas da se��o par�metros
	TRCell():New(		oSectPar,"PARAM"		,"   ","Par�metro",	"@!"       ,         30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(		oSectPar,"CONTEUDO"		,"   ","Conte�do",	"@!"       ,         30,/*lPixel*/,/*{|| code-block de impressao }*/)
	
	//*******************
	// CABE�ALHO
	//*******************
	
	//Criando a se��o de dados e as c�lulas
	oSectCab := TRSection():New(	oReport,;				//Objeto TReport que a se��o pertence
									"Cabe�alho",;			//Descri��o da se��o
									{"QRY_AUX"})			//Tabelas utilizadas, a primeira ser� considerada como principal da se��o
	oSectCab:SetTotalInLine(.F.)  //Define se os totalizadores ser�o impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	// Cabe�alho
	TRCell():New(	oSectCab,"FILIAL"		,"QRY_AUX","Filial"			,/*Picture*/,					TamSX3('E1_FILIAL')[01] 	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"PREFIXO"		,"QRY_AUX","Prefixo"		,/*Picture*/,					TamSX3('E1_PREFIXO')[01] 	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"TIPO"			,"QRY_AUX","Tipo"			,/*Picture*/,					TamSX3('E1_TIPO')[01	] 	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"NUM_TIT"		,"QRY_AUX","Num. Tit"		,/*Picture*/,					TamSX3('E1_NUM')[01] 		,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"COD_CLI"		,"QRY_AUX","Cod. Cliente"	,/*Picture*/,					TamSX3('E1_CLIENTE')[01] 	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"NOME"			,"QRY_AUX","Raz. Social"	,/*Picture*/,					TamSX3('E1_NOMCLI')[01] 	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"EMISSAO"		,"QRY_AUX","Emiss�o"		,/*Picture*/,					TamSX3('E1_EMISSAO')[01]+3	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"VALOR"		,"QRY_AUX","Valor"			,PesqPict('SE1', 'E1_VALOR'),	TamSX3('E1_VALOR')[01] 		,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectCab,"SALDO"		,"QRY_AUX","Saldo"			,PesqPict('SE1', 'E1_SALDO'),	TamSX3('E1_SALDO')[01] 		,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	//*******************
	// ITENS
	//*******************

		//Criando a se��o de dados e as c�lulas
	oSectIte := TRSection():New(	oSectCab,;					//Objeto TReport que a se��o pertence
									"Itens",;					//Descri��o da se��o
									{"QRY_AUX"})				//Tabelas utilizadas, a primeira ser� considerada como principal da se��o
	oSectIte:SetTotalInLine(.F.)  //Define se os totalizadores ser�o impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relat�rio
	TRCell():New(	oSectIte,"TIPOBA"		,"QRY_AUX","Tipo Baixa"		,/*Picture*/,					TamSX3('E5_TIPODOC')[01]-5		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"MOTIVO_BX"	,"QRY_AUX","Motivo Baixa"	,/*Picture*/,					TamSX3('E5_MOTBX')[01]-5		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"HISTORICO"	,"QRY_AUX","Hist�rico"		,/*Picture*/,					TamSX3('E5_HISTOR')[01]-5		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"NF"			,"QRY_AUX","Num NF"			,/*Picture*/,					TamSX3('E5_DOCUMEN')[01]-5		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"DATACMP"		,"QRY_AUX","Data Comp."		,/*Picture*/,					TamSX3('E5_DATA')[01]-5			,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(	oSectIte,"VALORTIT"		,"QRY_AUX","Valor"			,/*Picture*/,					TamSX3('E5_VALOR')[01]-5		,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	
	//Acrescentando totalizador nos dados
	oFuncTotal := TRFunction():New(oSectIte:Cell("VALORTIT"),,"SUM",,,cPictTot)
	oFuncTotal:SetEndReport(.T.)	//Define se ser� impresso o total tamb�m ao finalizar o relat�rio (Total Geral)
	
Return oReport

/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Autor: Arthur Toshio															 |
 | Data:  13/10/2016                                                             |
 | Desc:  Fun��o que imprime o relat�rio                                         |
 *-------------------------------------------------------------------------------*/

Static Function fRepPrint(oReport)
	Local cQryAux := ""
	Local oSectPar := Nil
	Local oSectCab := Nil
	Local oSectIte := Nil

	//Pegando as se��es do relat�rio
	oSectPar := oReport:Section(1)
	oSectCab := oReport:Section(2)
	oSectIte := oReport:Section(2):Section(1)

	//Setando os conte�dos da se��o de par�metros
	oSectPar:Init()
	oSectPar:Cell("PARAM"):SetValue("Filial De?")
	oSectPar:Cell("CONTEUDO"):SetValue(cFilde)
	oSectPar:Cell("PARAM"):SetValue("Filial At�?")
	oSectPar:Cell("CONTEUDO"):SetValue(cFilAt)
	oSectPar:Cell("PARAM"):SetValue("Emiss�o De?")
	oSectPar:Cell("CONTEUDO"):SetValue(dEmiDe)
	oSectPar:Cell("PARAM"):SetValue("Emiss�o At�?")
	oSectPar:Cell("CONTEUDO"):SetValue(dEmiAt)
	oSectPar:Cell("PARAM"):SetValue("Cliente De?")
	oSectPar:Cell("CONTEUDO"):SetValue(cCliDe)
	oSectPar:Cell("PARAM"):SetValue("Cliente At�?")
	oSectPar:Cell("CONTEUDO"):SetValue(cCliAt)


/*	
SELECT
        E1_FILIAL         AS          FILIAL,
        E1_PREFIXO        AS          PREFIXO,
        E1_TIPO           AS          TIPO,
        E1_NUM            AS          NUM_TIT,
        E1_CLIENTE        AS          COD_CLI,
        E1_NOMCLI         AS          NOME,
        E1_EMISSAO        AS          EMISSAO,
        E1_VALOR          AS          VALOR,
        E1_SALDO          AS          SALDO,     
        CASE WHEN E5_TIPODOC IN (SELECT E5_TIPODOC FROM SE5010  WHERE E5_NUMERO = E1_NUM AND E5_CLIENTE = E1_CLIENTE AND E5_MOTBX <> 'NOR' AND D_E_L_E_T_ = '') THEN E5_TIPODOC ELSE '' END AS TIPOBA,
        CASE WHEN E5_MOTBX IN (SELECT E5_MOTBX FROM SE5010  WHERE E5_NUMERO = E1_NUM AND E5_CLIENTE = E1_CLIENTE AND E5_MOTBX <> 'NOR' AND D_E_L_E_T_ = '') THEN E5_MOTBX ELSE '' END AS MOTIVO_BX,
        CASE WHEN E5_HISTOR IN (SELECT E5_HISTOR FROM SE5010  WHERE E5_NUMERO = E1_NUM AND E5_CLIENTE = E1_CLIENTE AND E5_MOTBX <> 'NOR' AND D_E_L_E_T_ = '') THEN E5_HISTOR ELSE '' END AS HISTORICO,
        CASE WHEN E5_DOCUMEN IN (SELECT E5_DOCUMEN FROM SE5010  WHERE E5_NUMERO = E1_NUM AND E5_CLIENTE = E1_CLIENTE AND E5_MOTBX <> 'NOR' AND D_E_L_E_T_ = '') THEN E5_DOCUMEN ELSE '' END AS NF,
        CASE WHEN E5_DATA IN (SELECT E5_DATA FROM SE5010  WHERE E5_NUMERO = E1_NUM AND E5_CLIENTE = E1_CLIENTE AND E5_MOTBX <> 'NOR' AND D_E_L_E_T_ = '') THEN E5_DATA ELSE '' END AS DATACMP,
        CASE WHEN E5_VALOR IN (SELECT E5_VALOR FROM SE5010  WHERE E5_NUMERO = E1_NUM AND E5_CLIENTE = E1_CLIENTE AND E5_MOTBX <> 'NOR' AND D_E_L_E_T_ = '') THEN E5_VALOR ELSE '' END AS VALORTIT
   FROM SE1010 E1, SE5010 E5
  -- LEFT JOIN  SE5010 E5 ON
    --    E1.E1_NUM = E5.E5_NUMERO AND E5.E5_CLIFOR = E1.E1_CLIENTE 
  WHERE E1.D_E_L_E_T_ = '' AND E5.D_E_L_E_T_ = ''
    --FILTRA CLIENTE
	AND E1.E1_NUM = E5.E5_NUMERO AND E5.E5_CLIFOR = E1.E1_CLIENTE AND E1_CLIENTE = E5_CLIENTE
    AND E1_CLIENTE BETWEEN '000001' AND '000001'
    -- FILTRA EMISS�O
    AND E1_EMISSAO BETWEEN '20160101' AND '20161011'
      AND E1_PREFIXO = 'ADT'
    AND E1_TIPO = 'RA'
    --AND E5_TIPODOC NOT INN (SELECT E5_TIPODOC FROM SE5010  WHERE E5_NUMERO = E1_NUM AND E5_CLIENTE = E1_CLIENTE AND E5_MOTBX <> 'NOR' AND D_E_L_E_T_ = '')  
    ORDER BY EMISSAO, NUM_TIT, COD_CLI, DATA
	*/
	
	//Montando a consulta
	cQryAux := "" + STR_PULA
	cQryAux += " SELECT " + STR_PULA
	cQryAux +=" E1_FILIAL         AS          FILIAL, " + STR_PULA
	cQryAux +=" E1_PREFIXO        AS          PREFIXO," + STR_PULA
	cQryAux +=" E1_TIPO           AS          TIPO,   " + STR_PULA
	cQryAux +=" E1_NUM            AS          NUM_TIT," + STR_PULA
	cQryAux +=" E1_CLIENTE        AS          COD_CLI," + STR_PULA
	cQryAux +=" E1_NOMCLI         AS          NOME,   " + STR_PULA
	cQryAux +=" E1_EMISSAO        AS          EMISSAO," + STR_PULA
	cQryAux +=" E1_VALOR          AS          VALOR,  " + STR_PULA
	cQryAux +=" E1_SALDO          AS          SALDO,  " + STR_PULA   
	cQryAux +=" CASE WHEN E5_TIPODOC IN (SELECT E5_TIPODOC FROM SE5010  WHERE E5_NUMERO = E1_NUM AND E5_CLIENTE = E1_CLIENTE AND E5_MOTBX <> 'NOR' AND D_E_L_E_T_ = '') THEN E5_TIPODOC ELSE '' END AS TIPOBA, " + STR_PULA
	cQryAux +=" CASE WHEN E5_MOTBX IN (SELECT E5_MOTBX FROM SE5010  WHERE E5_NUMERO = E1_NUM AND E5_CLIENTE = E1_CLIENTE AND E5_MOTBX <> 'NOR' AND D_E_L_E_T_ = '') THEN E5_MOTBX ELSE '' END AS MOTIVO_BX,    " + STR_PULA
	cQryAux +=" CASE WHEN E5_HISTOR IN (SELECT E5_HISTOR FROM SE5010  WHERE E5_NUMERO = E1_NUM AND E5_CLIENTE = E1_CLIENTE AND E5_MOTBX <> 'NOR' AND D_E_L_E_T_ = '') THEN E5_HISTOR ELSE '' END AS HISTORICO, " + STR_PULA
	cQryAux +=" CASE WHEN E5_DOCUMEN IN (SELECT E5_DOCUMEN FROM SE5010  WHERE E5_NUMERO = E1_NUM AND E5_CLIENTE = E1_CLIENTE AND E5_MOTBX <> 'NOR' AND D_E_L_E_T_ = '') THEN E5_DOCUMEN ELSE '' END AS NF,     " + STR_PULA
	cQryAux +=" CASE WHEN E5_DATA IN (SELECT E5_DATA FROM SE5010  WHERE E5_NUMERO = E1_NUM AND E5_CLIENTE = E1_CLIENTE AND E5_MOTBX <> 'NOR' AND D_E_L_E_T_ = '') THEN E5_DATA ELSE '' END AS DATACMP,         " + STR_PULA
	cQryAux +=" CASE WHEN E5_VALOR IN (SELECT E5_VALOR FROM SE5010  WHERE E5_NUMERO = E1_NUM AND E5_CLIENTE = E1_CLIENTE AND E5_MOTBX <> 'NOR' AND D_E_L_E_T_ = '') THEN E5_VALOR ELSE '' END AS VALORTIT      " + STR_PULA      
	cQryAux +=" FROM SE1010 E1, SE5010 E5 " + STR_PULA
	cQryAux +=" WHERE E1.D_E_L_E_T_ = '' AND E5.D_E_L_E_T_ = '' " + STR_PULA
	cQryAux +=" AND E1.E1_NUM = E5.E5_NUMERO AND E5.E5_CLIFOR = E1.E1_CLIENTE AND E1_CLIENTE = E5_CLIENTE " + STR_PULA
	cQryAux +=" AND E1_FILIAL BETWEEN '"+cFilde+"' AND '"+cFilAt+"' " + STR_PULA
	cQryAux +=" AND E1_CLIENTE BETWEEN '"+cCliDe+"' AND '"+cCliAt+"' " + STR_PULA
	cQryAux +=" AND E1_EMISSAO BETWEEN '"+dToS(dEmiDe)+"' AND '"+dToS(dEmiAt)+"' " + STR_PULA
	cQryAux +=" AND E1_PREFIXO = 'ADT' " + STR_PULA
	cQryAux +=" AND E1_TIPO = 'RA' " + STR_PULA
	cQryAux +=" ORDER BY EMISSAO, NUM_TIT, COD_CLI, DATACMP " + STR_PULA
    
    TCQuery cQryAux New Alias "QRY_AUX"
	Memowrite("C:\TOTVS\VAFINR08.txt",cQryAux)
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Setando os campos Data
	TCSetField("QRY_AUX", "EMISSAO",    "D")
	TCSetField("QRY_AUX", "DATACMP",    "D")

	//Enquanto houver dados
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Imprimindo o Cabe�alho
		oSectCab:Init()
		oSectCab:PrintLine()
		//Setando as vari�veis de Quebra
		cFilAux	 	:= QRY_AUX->FILIAL		// FILIAL
		cPrefAux 	:= QRY_AUX->PREFIXO		// PREFIXO 
		cTipAux 	:= QRY_AUX->TIPO        // TIPO
		cTitAux 	:= QRY_AUX->NUM_TIT     // NUMERO DO T�TULO
		cCClAux 	:= QRY_AUX->COD_CLI     // C�DIGO DO CLIENTE
		cCliAux 	:= QRY_AUX->NOME        // NOME
		cEmisAux 	:= QRY_AUX->EMISSAO     // EMISS�O
		cValAux		:= QRY_AUX->VALOR       // VALOR
		cSalAux		:= QRY_AUX->SALDO       // SALDO
		
		
		
		//Enquanto for o mesmo Filial e Pedido e Fornecedor, imprime os itens
		oSectIte:Init()
		While !QRY_AUX->(EoF()) .And. cFilAux == QRY_AUX->FILIAL .And. cPrefAux == QRY_AUX->PREFIXO .And. cTipAux == QRY_AUX->TIPO .And. cTitAux == QRY_AUX->NUM_TIT .And. cCClAux == QRY_AUX->COD_CLI .And. cCliAux == QRY_AUX->NOME;
		 						.And. cEmisAux == QRY_AUX->EMISSAO .And. cValAux == QRY_AUX->VALOR .And. cSalAux == QRY_AUX->SALDO	 	
			 	//Imprime os dados
				oSectIte:PrintLine()
				oReport:IncMeter()
				
				QRY_AUX->(DbSkip())
		EndDo
		oSectIte:Finish()
		
		//Finalizando o Cabe�alho
		oSectCab:Finish()
		oReport:SkipLine(2)
	EndDo
	
	QRY_AUX->(DbCloseArea())
Return


/*---------------------------------------------------------------------*
 | Func:  fVldPerg                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  21/09/2016                                                   |
 | Desc:  Fun��o para criar o grupo de perguntas                       |
 *---------------------------------------------------------------------*/

Static Function fVldPerg(cPerg)
	//(		cGrupo,	cOrdem,	cPergunt,			cPergSpa,		cPergEng,	cVar,		cTipo,	nTamanho,					nDecimal,	nPreSel,	cGSC,	cValid,	cF3,	cGrpSXG,	cPyme,	cVar01,		cDef01,	cDefSpa1,	cDefEng1,	cCnt01,	cDef02,		cDefSpa2,	cDefEng2,	cDef03,			cDefSpa3,		cDefEng3,	cDef04,	cDefSpa4,	cDefEng4,	cDef05,	cDefSpa5,	cDefEng5,	aHelpPor,	aHelpEng,	aHelpSpa,	cHelp)
	PutSx1(	cPerg,	"01",	"Filial  De?",		"",				"",			"mv_ch0",	"C",	TamSX3('E1_FILIAL')[01],		0,			0,			"G",	"", 	"",		"",			"",		"mv_par01",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"02",	"Filial  At�?",		"",				"",			"mv_ch1",	"C",	TamSX3('E1_FILIAL')[01],		0,			0,			"G",	"", 	"",		"",			"",		"mv_par02",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"03",	"Emiss�o De?",		"",				"",			"mv_ch2",	"D",	TamSX3('E1_EMISSAO')[01],		0,			0,			"G",	"", 	"",		"",			"",		"mv_par03",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"04",	"Emiss�o At�?",		"",				"",			"mv_ch3",	"D",	TamSX3('E1_EMISSAO')[01],		0,			0,			"G",	"", 	"",		"",			"",		"mv_par04",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"05",	"Cliente De?",		"",				"",			"mv_ch4",	"C",	TamSX3('E1_CLIENTE')[01],		0,			0,			"G",	"", 	"SA1C",		"",			"",		"mv_par05",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"06",	"Cliente At�?",		"",				"",			"mv_ch5",	"C",	TamSX3('E1_CLIENTE')[01],		0,			0,			"G",	"", 	"SA1C",		"",			"",		"mv_par06",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	
Return
