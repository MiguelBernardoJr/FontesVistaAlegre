#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} VAESTR04
//TODO Descrição auto-gerada.
@author Arthur Toshio
@since 28/11/2016
@version 1.0
@example 
U_VAESTR004()
@type function
/*/
User Function VAESTR04()
	Local aArea		:= GetArea()
	Private oSection1
	Private oReport
	Private cPerg := PadR('VAESTR04',10)
	//Private cPerg	:= "X_VAESTR04"
	Private dEmiDe	:= sToD("") // Emissão De 
	Private dEmiAt	:= sToD("") // Emissão Até
	Private cFilde	:= ""
	Private cFilAt	:= ""
	Private	cTesDe	:= ""
	Private cTesAt	:= ""
	
	fVldPerg(cPerg)
	/*If !Pergunte(cPerg,.T.)
		Return
	EndIf*/
	While Pergunte(cPerg,.T.)
		dEmiDe := MV_PAR01
		dEmiAt := MV_PAR02
		cFilde := MV_PAR03
		cFilAt := MV_PAR04
		cTesDe := MV_PAR05
		cTesAt := MV_PAR06
		
		oReport := reportDef()
		oReport:printDialog()
	EndDo
	
	RestArea(aArea)
Return

static function reportDef()
	
	Local oSctnPar   := Nil
	Local oSectCab   := Nil

	Local cTitulo := '[VAESTR04] - Situação NFs de Transferencias'
	
	oReport := TReport():New('VAESTR04', cTitulo, , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de notas fiscais de gado, seus complementos e contra-notas")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
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
	
	
	//oSection1 := TRSection():New(oReport,"Relação de Faturamento de Gado",{"QRYEST"})
		
	//Criando a seção de dados e as células
	oSection1 := TRSection():New(oReport,;				//Objeto TReport que a seção pertence
									"Itens",;			//Descrição da seção
									{"QRYEST"})			//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSection1:SetTotalInLine(.F.)   

	TRCell():New(oSection1, "FIL_ORIGEM"	,"QRYEST", "Fil. Orig."		,PesqPict('SD2', 'D2_FILIAL'),		TamSX3('D2_FILIAL')[01]+4	,/*lPixel*/,/*{|| code-block de impressao }*/)//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "NOTA_FISCA"	,"QRYEST", "NF"				,PesqPict('SD2', 'D2_DOC'),			TamSX3('D2_DOC')[01]+3		,/*lPixel*/,/*{|| code-block de impressao }*/)//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "ITEM_NF"		,"QRYEST", "Item NF"		,PesqPict('SD2', 'D2_ITEM'),		TamSX3('D2_ITEM')[01]+4		,/*lPixel*/,/*{|| code-block de impressao }*/)//,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "CODIGO"		,"QRYEST", "Cod. Prod."		,PesqPict('SD2', 'D2_COD'),			TamSX3('D2_COD')[01]+4		,/*lPixel*/,/*{|| code-block de impressao }*/)//,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "DESCRICAO"		,"QRYEST", "Descricao"		,PesqPict('SB1', 'B1_DESC'),		TamSX3('B1_DESC')[01]+10	,/*lPixel*/,/*{|| code-block de impressao }*/)//,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "QUANTIDADE"	,"QRYEST", "Qtde"			,PesqPict('SD2', 'D2_QUANT'),		TamSX3('D2_QUANT')[01]+3	,/*lPixel*/,/*{|| code-block de impressao }*/)//,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "VALOR"			,"QRYEST", "Valor"			,PesqPict('SD2', 'D2_VALBRUT'),		TamSX3('D2_VALBRUT')[01]+4	,/*lPixel*/,/*{|| code-block de impressao }*/)//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "SITUACAO"		,"QRYEST", "Situacao"		,/*Picture*/,						TamSX3('B1_DESC')[01]-40	,/*lPixel*/,/*{|| code-block de impressao }*/)//,"CENTER",/*lLineBreak*/,"CENTER",/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "TIPO_ENTRA"	,"QRYEST", "TES"			,PesqPict('SD2', 'D2_TES'),			TamSX3('D2_TES')[01]+4		,/*lPixel*/,/*{|| code-block de impressao }*/)//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "TEXTO"			,"QRYEST", "Desc. TES"		,PesqPict('SF4', 'F4_TEXTO'),		TamSX3('F4_TEXTO')[01]+15	,/*lPixel*/,/*{|| code-block de impressao }*/)//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "CFOP"			,"QRYEST", "CFOP"			,PesqPict('SF4', 'F4_CF'),			TamSX3('F4_CF')[01]+2		,/*lPixel*/,/*{|| code-block de impressao }*/)//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "FILIAL"		,"QRYEST", "Fil. Dest."		,PesqPict('SD1', 'D1_FILIAL'),		TamSX3('D1_FILIAL')[01]+4	,/*lPixel*/,/*{|| code-block de impressao }*/)//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "NF_DESTINO"	,"QRYEST", "N. NF"			,PesqPict('SD1', 'D1_DOC'),			TamSX3('D1_DOC')[01]+15		,/*lPixel*/,/*{|| code-block de impressao }*/)//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	
	TRCell():New(oSection1, "DATA_LANCT"	,"QRYEST", "Data Lancto"	,PesqPict('SD1', 'D1_DTDIGIT'),		TamSX3('D1_DTDIGIT')[01]+15	,/*lPixel*/,/*{|| code-block de impressao }*/)//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "SITU_DEST"		,"QRYEST", "Situacao"		,/*Picture*/,						TamSX3('B1_DESC')[01]-10	,/*lPixel*/,/*{|| code-block de impressao }*/)//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	//TRFunction():New(oSection1:Cell("FATQUANT") ," Qtde Total" 			,"SUM",,,PesqPict('SD2',"D2_QUANT"),,.F.,.T.)	
Return (oReport)
	
Static Function PrintReport(oReport)
	Local cQryAux := ''
	Local oSection1 := oReport:Section(2)
	
	If Select("QRYEST") > 0
		QRYEST->(DbCloseArea())
	EndIf
	
	
	cQryAux := "" + STR_PULA
	
	cQryAux += "SELECT D2.D2_FILIAL			AS	FIL_ORIGEM,                       	 " + STR_PULA
	cQryAux += "	   D2.D2_DOC			AS	NOTA_FISCA,                          " + STR_PULA
	cQryAux += "	   D2.D2_ITEM			AS	ITEM_NF,                             " + STR_PULA
	cQryAux += "	   D2.D2_COD			AS	CODIGO,                              " + STR_PULA
	cQryAux += "	   B1.B1_DESC			AS	DESCRICAO,                           " + STR_PULA
	cQryAux += "	   D2.D2_QUANT			AS	QUANTIDADE,                          " + STR_PULA
	cQryAux += "	   D2.D2_VALBRUT		AS	VALOR,                               " + STR_PULA
	cQryAux += "	   CASE WHEN D2.D_E_L_E_T_ =  '' THEN 'EMISSÃO AUTORIZADA'       " + STR_PULA
	cQryAux += "	        WHEN D2.D_E_L_E_T_ <> '' THEN 'NF CANCELADA'             " + STR_PULA
	cQryAux += "	   			END 		AS SITUACAO,                                              " + STR_PULA
	cQryAux += "	   D2.D2_TES			AS	TIPO_ENTRA,                        	 " + STR_PULA
	cQryAux += "	   F4.F4_TEXTO			AS	TEXTO,                               " + STR_PULA
	cQryAux += "	   F4.F4_CF				AS	CFOP,                                " + STR_PULA
	cQryAux += "	   D1.D1_FILIAL			AS	FILIAL,                              " + STR_PULA
	cQryAux += "	   D1.D1_DOC			AS	NF_DESTINO,                          " + STR_PULA
	cQryAux += "	   D1.D1_DTDIGIT		AS	DATA_LANCT,                          " + STR_PULA
	cQryAux += "	   CASE WHEN D1.D_E_L_E_T_ =  '' THEN 'NF ESCRITURADA'           " + STR_PULA
	cQryAux += "	        WHEN D1.D_E_L_E_T_ <> '' THEN 'LANCTO EXCLUIDO'          " + STR_PULA
	cQryAux += "	   END AS SITU_DEST                                          	 " + STR_PULA
	cQryAux += "  FROM "+RetSQLName('SD2')+" D2, "+RetSQLName('SF4')+" F4, "+RetSQLName('SB1')+" B1, "+RetSQLName('SD1')+" D1  " + STR_PULA
	cQryAux += " WHERE D2.D_E_L_E_T_ <> '' AND F4.D_E_L_E_T_ = '' --AND B1.D_E_L_E_T_ = '' AND D1.D_E_L_E_T_ = ''" + STR_PULA
	cQryAux += "   AND D2.D2_EMISSAO BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'            " + STR_PULA
	cQryAux += "   AND D2.D2_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                         " + STR_PULA
	cQryAux += "   AND D2.D2_DOC = D1.D1_DOC AND D2.D2_EMISSAO = D1.D1_EMISSAO AND D2.D2_COD = D1.D1_COD   " + STR_PULA
	cQryAux += "   AND D2.D2_TES BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'								 " + STR_PULA
	cQryAux += "   --AND D2_DOC = '000000069'                                     " + STR_PULA
	cQryAux += "   AND F4.F4_CODIGO = D2.D2_TES                                   " + STR_PULA
	cQryAux += "   AND D2.D2_COD = B1.B1_COD                                      " + STR_PULA
	cQryAux += "   AND F4_TRANFIL = '1'											" + STR_PULA
	cQryAux += "	 ORDER BY D2.D2_FILIAL, D2.D2_DOC	                            " + STR_PULA 

	memowrite("C:\TOTVS\VAESTR04.txt", cQryAux)
	TCQUERY cQryAux NEW ALIAS "QRYEST"    
	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
	
	DbSelectArea('QRYEST')
	QRYEST->(dbGoTop())
	oReport:SetMeter(QRYEST->(RecCount()))
	While QRYEST->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf
		
		oReport:IncMeter()
		
		oSection1:Cell("FIL_ORIGEM"):SetValue(QRYEST->FIL_ORIGEM)
		oSection1:Cell("FIL_ORIGEM"):SetAlign("LEFT")
		
		oSection1:Cell("NOTA_FISCA"):SetValue(QRYEST->NOTA_FISCA)
		oSection1:Cell("NOTA_FISCA"):SetAlign("CENTER")
		
		oSection1:Cell("ITEM_NF"):SetValue(QRYEST->ITEM_NF)
		oSection1:Cell("ITEM_NF"):SetAlign("CENTER")
		
		oSection1:Cell("CODIGO"):SetValue(QRYEST->CODIGO)
		oSection1:Cell("CODIGO"):SetAlign("CENTER")	
		
		oSection1:Cell("DESCRICAO"):SetValue(QRYEST->DESCRICAO)
		oSection1:Cell("DESCRICAO"):SetAlign("LEFT")	
		
		oSection1:Cell("QUANTIDADE"):SetValue(QRYEST->QUANTIDADE)
		oSection1:Cell("QUANTIDADE"):SetAlign("CENTER")
		
		oSection1:Cell("VALOR"):SetValue(QRYEST->VALOR)
		oSection1:Cell("VALOR"):SetAlign("RIGHT")
		
		oSection1:Cell("SITUACAO"):SetValue(QRYEST->SITUACAO)
		oSection1:Cell("SITUACAO"):SetAlign("LEFT")
		
		oSection1:Cell("TIPO_ENTRA"):SetValue(QRYEST->TIPO_ENTRA)
		oSection1:Cell("TIPO_ENTRA"):SetAlign("CENTER")
		
		oSection1:Cell("TEXTO"):SetValue(QRYEST->TEXTO)
		oSection1:Cell("TEXTO"):SetAlign("LEFT")
		
		oSection1:Cell("CFOP"):SetValue(QRYEST->CFOP)
		oSection1:Cell("CFOP"):SetAlign("CENTER")
		
		oSection1:Cell("FILIAL"):SetValue(QRYEST->FILIAL)
		oSection1:Cell("FILIAL"):SetAlign("CENTER")
		
		oSection1:Cell("NF_DESTINO"):SetValue(QRYEST->NF_DESTINO)
		oSection1:Cell("NF_DESTINO"):SetAlign("CENTER")
		
		oSection1:Cell("DATA_LANCT"):SetValue(STOD(QRYEST->DATA_LANCT))
		oSection1:Cell("DATA_LANCT"):SetAlign("CENTER")	
		
		oSection1:Cell("SITU_DEST"):SetValue(QRYEST->SITU_DEST)
		oSection1:Cell("SITU_DEST"):SetAlign("LEFT")
		
		oSection1:PrintLine()
		
		dbSelectArea("QRYEST")
		QRYEST->(dbSkip())
		
	EndDo
	oSection1:Finish()
	QRYEST->(DbCloseArea())

Return

/*---------------------------------------------------------------------*
| Func:  fVldPerg                                                     |
| Autor: Daniel Atilio                                                |
| Data:  21/09/2016                                                   |
| Desc:  Função para criar o grupo de perguntas                       |
*---------------------------------------------------------------------*/

Static Function fVldPerg(cPerg)
	//(		cGrupo,	cOrdem,	cPergunt,			cPergSpa,		cPergEng,	cVar,		cTipo,	nTamanho,					nDecimal,	nPreSel,	cGSC,	cValid,			cF3,	cGrpSXG,	cPyme,	cVar01,		cDef01,	cDefSpa1,	cDefEng1,	cCnt01,	cDef02,		cDefSpa2,	cDefEng2,	cDef03,			cDefSpa3,		cDefEng3,	cDef04,	cDefSpa4,	cDefEng4,	cDef05,	cDefSpa5,	cDefEng5,	aHelpPor,	aHelpEng,	aHelpSpa,	cHelp)
	PutSx1(	cPerg,	"01",	"Emissão De?",		"",				"",			"mv_ch0",	"D",	TamSX3('D2_EMISSAO')[01],	0,			0,			"G",	"", 	"",		"",			"",		"MV_PAR01",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"02",	"Emissão Até?",		"",				"",			"mv_ch1",	"D",	TamSX3('D2_EMISSAO')[01],	0,			0,			"G",	"", 	"",		"",			"",		"MV_PAR02",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"03",	"Filial  De?",		"",				"",			"mv_ch2",	"C",	TamSX3('D2_FILIAL')[01],	0,			0,			"G",	"", 	"SM0",	"",			"",		"MV_PAR03",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"04",	"Filial  Até?",		"",				"",			"mv_ch3",	"C",	TamSX3('D2_FILIAL')[01],	0,			0,			"G",	"", 	"SM0",	"",			"",		"MV_PAR04",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"05",	"TES De?",			"",				"",			"mv_ch4",	"C",	TamSX3('D2_TES')[01],		0,			0,			"G",	"", 	"SF4",	"",			"",		"MV_PAR05",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
	PutSx1(	cPerg,	"06",	"TES Até?",			"",				"",			"mv_ch5",	"C",	TamSX3('D2_TES')[01],		0,			0,			"G",	"", 	"SF4",	"",			"",		"MV_PAR06",	"",		"",			"",			"",		"",			"",			"",			"",				"",				"",			"",		"",			"",			"",		"",			"",			{},			{},			{},			"")
Return

/*
Static Function fVldPerg(cPerg)
Local _sAlias,i,j

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}                                                  

	AADD(aRegs,{cPerg,"01","Emissao de        ?",Space(20),Space(20),"mv_ch1","D",06,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Emissao Ate	      ?",Space(20),Space(20),"mv_ch2","D",06,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Filial De         ?",Space(20),Space(20),"mv_ch3","C",02,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SMO","","","","",""})
	AADD(aRegs,{cPerg,"04","Filial Ate        ?",Space(20),Space(20),"mv_ch4","C",02,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SMO","","","","",""})		
	AADD(aRegs,{cPerg,"05","Tes De         	  ?",Space(20),Space(20),"mv_ch5","C",08,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SF4","","","","",""})
	AADD(aRegs,{cPerg,"06","Tes Ate        	  ?",Space(20),Space(20),"mv_ch6","C",08,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","SF4","","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				FieldPut(j,aRegs[i,j])
			Next
			MsUnlock()
			dbCommit()
		EndIf
	Next
	dbSelectArea(_sAlias)
	
Return*/

