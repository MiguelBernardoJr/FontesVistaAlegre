//Bibliotecas
#Include 'Protheus.ch'
#Include 'TopConn.ch'

//Constantes
#Define STR_PULA		Chr(13) + Chr(10)

/*/{Protheus.doc} VAFISR01
Relatório de Conferência de Notas Fiscais de Saida
@author Atilio
@since 21/01/2015
@version 1.0
	@example
	u_VAFISR01()
	@obs Semelhante ao AFESPR13
/*/

User Function VAFISR01()
	Local aArea := GetArea()
	Local cFilBkp := cFilAnt
	Local oReport
	Private cPerg := "VAFISR01"

	//Enquanto a pergunta for confirmada, imprime o relatório
	fVldPerg()
	While Pergunte(cPerg,.T.)
		oReport := fReportDef()
		oReport:PrintDialog()
		cFilAnt := cFilBkp
	EndDo
	
	cFilAnt := cFilBkp
	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Autor: Daniel Atilio                                                          |
 | Data:  25/01/2015                                                             |
 | Desc:  Função que monta a definição do relatório                              |
 *-------------------------------------------------------------------------------*/

Static Function fReportDef()
	Local oReport
	Local oSctnPar := nil
	Local oSectDad := nil
	Local oSectIte := nil

	//Criação do componente de impressão
	oReport := TReport():New(	"VAFISR01",;														//Nome do Relatório
									"Relatório de Conferência de Notas Fiscais de Saida",;	//Título
									,;																	//Pergunte
									{|oReport| fRepPrint(oReport)},;								//Bloco de código que será executado na confirmação da impressão
									)																	//Descrição
	oReport:SetLandscape(.T.)   //Define a orientação de página do relatório como paisagem  ou retrato. .F.=Retrato; .T.=Paisagem
	oReport:SetTotalInLine(.F.) //Define se os totalizadores serão impressos em linha ou coluna
	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf
	
	//Criando a seção de dados e as células
	oSectPar := TRSection():New(	oReport,;					//Objeto TReport que a seção pertence
										"Parâmetros",;					//Descrição da seção
										{""})					//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectPar:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Células da seção parâmetros
	TRCell():New(		oSectPar,"PARAM"			,"   ","Parâmetro","@!"       ,         30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(		oSectPar,"CONTEUDO"			,"   ","Conteúdo","@!"       ,         30,/*lPixel*/,/*{|| code-block de impressao }*/)
	
	//Criando a seção de dados e as células
	oSectDad := TRSection():New(	oReport,;					//Objeto TReport que a seção pertence
										"Dados",;					//Descrição da seção
										{"SF4"})					//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Se agrupar por TES, o campo mostrado será o F4_CODIGO 
	If MV_PAR03 == 1
		TRCell():New(	oSectDad,"F4_CODIGO"		,"SF4","TES"     ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	ElseIf MV_PAR03 == 2
		TRCell():New(	oSectDad,"F4_CF"			,"SF4","CFOP"    ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	EndIf
	TRCell():New(		oSectDad,"DESCRI"			,"   ","        ","@!"       ,         30,/*lPixel*/,/*{|| code-block de impressao }*/)

	//Criando a seção de itens e células
	oSectIte := TRSection():New(	oSectDad,;					//Objeto TReport que a seção pertence
										"Itens",;					//Descrição da seção
										{"SF2","SD2"})			//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectIte:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Somente se for impressão normal será impresso a linha de itens
	If MV_PAR06 == 1
		//Células dos itens
		TRCell():New(oSectIte,"F2_EMISSAO"	,"SF2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"F2_FILIAL"	,"SF2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"F2_DOC"		,"SF2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"F2_SERIE"	,"SF2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"F2_EST"		,"SF2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"A1_NOME"		,"SA1",/*Titulo*/,/*Picture*/,         20,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"A1_CGC"		,"SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"A1_INSCR"	,"SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//		TRCell():New(oSectIte,"D2_QUANT"	,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	EndIf
	
	TRCell():New(oSectIte,"D2_TOTAL"	,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectIte,"D2_QUANT"	,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	
	//Somente se for impressão normal será impresso a linha de itens
	If MV_PAR06 == 1
		TRCell():New(oSectIte,"CD2_PAUTA"	,"CD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"CD2_BC"		,"CD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"CD2_ALIQ"	,"CD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"ICMS"		,"CD2","ICMS"    ,"@E 999,999,999.99", 12,/*lPixel*/,/*{|| code-block de impressao }*/)
	EndIf
	
	//Somente se for impressão normal será impresso a linha de itens
	If MV_PAR06 == 1
		TRFunction():New(oSectIte:Cell("D2_TOTAL"),,"SUM",,,PesqPict("SD2","D2_TOTAL"))
		TRFunction():New(oSectIte:Cell("D2_QUANT"),,"SUM",,,PesqPict("SD2","D2_QUANT"))
	EndIf

Return oReport

/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Autor: Daniel Atilio                                                          |
 | Data:  25/01/2015                                                             |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/

Static Function fRepPrint(oReport)
	Local cQuery := ""
	Local oParam := Nil
	Local oDados := Nil
	Local oItens := Nil
	Local cQuebr := ""
	Local lQuebr := .F.
	Local nTotal := 0
	Local nTotQT := 0

	DbSelectArea("SF4")
	DbSelectArea("SF2")
	DbSelectArea("SD2")
	DbSelectArea("CD2")

	//Pegando as seções do relatório
	oParam := oReport:Section(1)
	oDados := oReport:Section(2)
	oItens := oReport:Section(2):Section(1)

	//Montando consulta de dados
	cQuery := " SELECT "											+ STR_PULA
	cQuery += "    F4_CODIGO, "										+ STR_PULA
	cQuery += "    F4_CF, "											+ STR_PULA
	cQuery += "    F4_TEXTO, "										+ STR_PULA
	cQuery += "    ISNULL(CD2_PAUTA, 0) AS CD2_PAUTA, "				+ STR_PULA
	cQuery += "    ISNULL(CD2_BC, 0) AS CD2_BC, "					+ STR_PULA
	cQuery += "    ISNULL(CD2_ALIQ, 0) AS CD2_ALIQ, "				+ STR_PULA
	cQuery += "    ISNULL(CD2_QTRIB, 0) AS CD2_QTRIB, "				+ STR_PULA
	cQuery += "    F2_EMISSAO, "									+ STR_PULA
	cQuery += "    F2_FILIAL, "										+ STR_PULA
	cQuery += "    F2_DOC, "										+ STR_PULA
	cQuery += "    F2_SERIE, "										+ STR_PULA
	cQuery += "    F2_EST, "										+ STR_PULA
	cQuery += "    F2_TIPO, "										+ STR_PULA
	cQuery += "    CASE WHEN F2_TIPO IN ('B','D') THEN A2_NOME 		ELSE A1_NOME 	END AS A1_NOME,    " + STR_PULA
	cQuery += "    CASE WHEN F2_TIPO IN ('B','D') THEN A2_CGC 		ELSE A1_CGC 	END AS A1_CGC,     " + STR_PULA
	cQuery += "    CASE WHEN F2_TIPO IN ('B','D') THEN A2_INSCR 	ELSE A1_INSCR 	END AS A1_INSCR,   " + STR_PULA
	cQuery += "    CASE WHEN F2_TIPO IN ('B','D') THEN A1_TIPO 		ELSE A1_PESSOA 	END AS A1_PESSOA,  " + STR_PULA
	cQuery += "    D2_QUANT, "										+ STR_PULA
	cQuery += "    D2_TOTAL, "										+ STR_PULA
	cQuery += "    D2_CF, "											+ STR_PULA
	cQuery += "    D2_TES, "										+ STR_PULA
	cQuery += "    SF4.R_E_C_N_O_ AS SF4REC, "						+ STR_PULA
	cQuery += "    SF2.R_E_C_N_O_ AS SF2REC, "						+ STR_PULA
	cQuery += "    SD2.R_E_C_N_O_ AS SD2REC, "						+ STR_PULA
	cQuery += "    SA1.R_E_C_N_O_ AS SA1REC, "						+ STR_PULA
	cQuery += "    ISNULL(CD2.R_E_C_N_O_, -1) AS CD2REC  "			+ STR_PULA
	cQuery += " FROM "												+ STR_PULA
	cQuery += "    "+RetSQLName("SF2")+" SF2 "					+ STR_PULA
	cQuery += "    INNER JOIN "+RetSQLName("SD2")+" SD2 ON ( "	+ STR_PULA
	cQuery += "     SD2.D_E_L_E_T_ = '' "							+ STR_PULA
	cQuery += "     AND D2_FILIAL = F2_FILIAL "					+ STR_PULA
	cQuery += "     AND D2_DOC    = F2_DOC "						+ STR_PULA
	cQuery += "     AND D2_SERIE  = F2_SERIE "					+ STR_PULA
	cQuery += "     AND D2_CLIENTE  = F2_CLIENTE "					+ STR_PULA
	cQuery += "     AND D2_LOJA  = F2_LOJA "					+ STR_PULA
	cQuery += "    ) "												+ STR_PULA
	cQuery += "    LEFT JOIN "+RetSQLName("CD2")+" CD2 ON ( "	+ STR_PULA
	cQuery += "     CD2.D_E_L_E_T_ = '' "							+ STR_PULA
	cQuery += "     AND CD2_TPMOV = 'S' "							+ STR_PULA
	cQuery += "     AND CD2.CD2_DOC    = SD2.D2_DOC "			+ STR_PULA
	cQuery += "     AND CD2.CD2_FILIAL = SD2.D2_FILIAL "			+ STR_PULA
	cQuery += "     AND CD2.CD2_SERIE  = SD2.D2_SERIE "			+ STR_PULA
	cQuery += "     AND CD2.CD2_CODCLI = SD2.D2_CLIENTE "		+ STR_PULA
	cQuery += "     AND CD2.CD2_LOJCLI = SD2.D2_LOJA "			+ STR_PULA
	cQuery += "     AND CD2.CD2_IMP    = 'ICM' "					+ STR_PULA
	cQuery += "    ) "												+ STR_PULA
	cQuery += "    LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( "	+ STR_PULA
	cQuery += "     SA1.D_E_L_E_T_ = '' "							+ STR_PULA
	cQuery += "     AND A1_COD  = SD2.D2_CLIENTE "				+ STR_PULA
	cQuery += "     AND A1_LOJA = SD2.D2_LOJA "					+ STR_PULA
	cQuery += "    ) "												+ STR_PULA
	cQuery += "    LEFT JOIN "+RetSQLName("SA2")+" SA2 ON ( "	+ STR_PULA
	cQuery += "     SA2.D_E_L_E_T_ = '' "							+ STR_PULA
	cQuery += "     AND A2_COD  = SD2.D2_CLIENTE "				+ STR_PULA
	cQuery += "     AND A2_LOJA = SD2.D2_LOJA "					+ STR_PULA
	cQuery += "    ) "												+ STR_PULA
	cQuery += "    INNER JOIN "+RetSQLName("SF4")+" SF4 ON ( "	+ STR_PULA
	cQuery += "     SF4.D_E_L_E_T_ = '' "							+ STR_PULA
	cQuery += "     AND F4_CODIGO = D2_TES "						+ STR_PULA
	If !Empty(MV_PAR04)
		cQuery += "     AND F4_CODIGO LIKE '%"+Alltrim(MV_PAR04)+"%' "		+ STR_PULA
	EndIf
	If !Empty(MV_PAR05)
		cQuery += "     AND F4_CF LIKE '%"+Alltrim(MV_PAR05)+"%' "	+ STR_PULA
	EndIf
	//cQuery += "     AND F4_FILIAL = D2_FILIAL "					+ STR_PULA   //TES Compartilhada, não precisa fazer join com os itens
	cQuery += "    ) "												+ STR_PULA
	cQuery += " WHERE "												+ STR_PULA
	cQuery += "    SF2.D_E_L_E_T_  = '' "							+ STR_PULA
	cQuery += "    AND F2_EMISSAO >= '"+dToS(MV_PAR01)+"' "		+ STR_PULA
	cQuery += "    AND F2_EMISSAO <= '"+dToS(MV_PAR02)+"' "		+ STR_PULA
	If !Empty(MV_PAR06)
		cQuery += "    AND F2_FILIAL LIKE '%"+Alltrim(MV_PAR07)+"%' "		+ STR_PULA
	EndIf

	cESTIn := ""
	If !Empty(MV_PAR10)
		aESTIn := StrTokArr(AllTrim(MV_PAR10),";")	
		For nCont := 1 To Len(aESTIn)
			cESTIn += If(Empty(cESTIn),"'",",'") + aESTIn[nCont] + "'"
		Next		
		cQuery += " AND SF2.F2_EST IN ("+cESTIn+") "
	EndIf

	cPRODIn := ""
	If !Empty(MV_PAR12)
		aPRODIn := StrTokArr(AllTrim(MV_PAR12),";")	
		For nCont := 1 To Len(aPRODIn)
			cPRODIn += If(Empty(cPRODIn),"'",",'") + aPRODIn[nCont] + "'"
		Next		
		cQuery += " AND SD2.D2_COD IN ("+cPRODIn+") "
	EndIf

	
	//Armazem
	cQuery += "    AND D2_LOCAL >= '"+Alltrim(MV_PAR08)+"' AND  D2_LOCAL <= '"+Alltrim(MV_PAR09)+"'"		+ STR_PULA	
	
	//Se agrupa por TES
	If MV_PAR03 == 1
		cQuery += "ORDER BY F4_CODIGO "
		
	//Senão se agrupa por CFOP
	ElseIf MV_PAR03 == 2
		cQuery += "ORDER BY F4_CF "
	Endif

	//Executando consulta e setando o total da régua
	TCQuery cQuery New Alias "QRY_NOT"
	Count to nTotal
	oReport:SetMeter(nTotal)
	lQuebr := .F.
	lFirst := .T.

	//Setando os parâmetros
	oParam:Init()
	oParam:Cell("PARAM"):SetValue("Data NF De?")
	oParam:Cell("CONTEUDO"):SetValue(dToC(MV_PAR01))
	oParam:PrintLine()
	oParam:Cell("PARAM"):SetValue("Data NF Até?")
	oParam:Cell("CONTEUDO"):SetValue(dToC(MV_PAR02))
	oParam:PrintLine()
	oParam:Cell("PARAM"):SetValue("Agrupar por?")
	oParam:Cell("CONTEUDO"):SetValue(Iif(MV_PAR03 == 1, "TES", "CFOP"))
	oParam:PrintLine()
	oParam:Cell("PARAM"):SetValue("TES?")
	oParam:Cell("CONTEUDO"):SetValue(MV_PAR04)
	oParam:PrintLine()
	oParam:Cell("PARAM"):SetValue("CFOP?")
	oParam:Cell("CONTEUDO"):SetValue(MV_PAR05)
	oParam:PrintLine()
	oParam:Cell("PARAM"):SetValue("Tipo?")
	oParam:Cell("CONTEUDO"):SetValue(Iif(MV_PAR06 == 1, "Normal", "Sintético"))
	oParam:PrintLine()
	oParam:Cell("PARAM"):SetValue("Filial?")
	oParam:Cell("CONTEUDO"):SetValue(MV_PAR07)
	oParam:PrintLine()
	oParam:Finish()

	//Enquanto houver dados
	QRY_NOT->(DbGoTop())
	While ! QRY_NOT->(Eof())
	//	SF4->(DbGoTo(QRY_NOT->SF4REC))
	//	SF2->(DbGoTo(QRY_NOT->SF2REC))
	//	SD2->(DbGoTo(QRY_NOT->SD2REC))
	//	SA1->(DbGoTo(QRY_NOT->SA1REC))

		// TRATAR SE É PESSOA FISICA OU JURIDICA
		If (Alltrim(QRY_NOT->A1_PESSOA)$'J' .and. MV_PAR11==2) .or. (Alltrim(QRY_NOT->A1_PESSOA)$'F' .and. MV_PAR11==3) // 1-ambos  	2-Fisica	3-Juridica
			QRY_NOT->(DbSkip())
			loop
		Endif

		If QRY_NOT->CD2REC != -1
			CD2->(DbGoTo(QRY_NOT->CD2REC))
		EndIf
	
		cDescr := ""
		//Se agrupa por TES
		If MV_PAR03 == 1
			If cQuebr != QRY_NOT->F4_CODIGO
				lQuebr := .T.
				cDescr := QRY_NOT->F4_TEXTO
				cQuebr := QRY_NOT->F4_CODIGO
			EndIf
		
		//Se agrupa por CFOP
		ElseIf MV_PAR03 == 2
			If cQuebr != QRY_NOT->F4_CF
				lQuebr := .T.
				cDescr := Posicione("SX5", 1, xFilial("SX5")+"13"+QRY_NOT->F4_CF, "X5_DESCRI")
				cQuebr := QRY_NOT->F4_CF
			EndIf
		EndIf
		
		//Se houver a quebra
		If lQuebr
			//Se não for a primeira vez, finaliza a seção
			If !lFirst
				//Se for sintético, atualiza e imprime
				If MV_PAR06 == 2
					oItens:Cell("D2_QUANT"):SetValue(nTotQt)
					oItens:Cell("D2_TOTAL"):SetValue(nTotal)
					oItens:PrintLine()
				EndIf
				oItens:Finish()
				oDados:Finish()
				nTotal := 0
				nTotQT := 0
			EndIf
			
			//Iniciando a seção de dados e imprimindo
			oDados:Init()
			//Se agrupar por TES, o campo mostrado será o F4_CODIGO 
			If MV_PAR03 == 1
				oDados:Cell("F4_CODIGO"):SetValue(QRY_NOT->F4_CODIGO)
			ElseIf MV_PAR03 == 2
				oDados:Cell("F4_CF"):SetValue(QRY_NOT->F4_CF)
			EndIf
			oDados:Cell("DESCRI"):SetValue(cDescr)
			oDados:PrintLine()
			
			//Iniciando a linha de itens
			oItens:Init()
			
			lQuebr := .F.
			lFirst := .F.
		EndIf
		
		//Somente se for impressão normal será impresso a linha de itens
		If MV_PAR06 == 1
			//Se tiver recno
			If QRY_NOT->CD2REC != -1
				//Setando os valores
				oItens:Cell("CD2_PAUTA"):SetValue(QRY_NOT->CD2_PAUTA)
				oItens:Cell("CD2_BC"):SetValue(QRY_NOT->CD2_BC)
				oItens:Cell("CD2_ALIQ"):SetValue(QRY_NOT->CD2_ALIQ)
				oItens:Cell("ICMS"):SetValue(QRY_NOT->CD2_PAUTA * (QRY_NOT->CD2_ALIQ /100) * QRY_NOT->CD2_QTRIB )
			Else
				//Setando os valores
				oItens:Cell("CD2_PAUTA"):SetValue(0)
				oItens:Cell("CD2_BC"):SetValue(0)
				oItens:Cell("CD2_ALIQ"):SetValue(0)
				oItens:Cell("ICMS"):SetValue(0)
			EndIf

			oItens:Cell("F2_FILIAL"):SetValue(QRY_NOT->F2_FILIAL)
			oItens:Cell("F2_EMISSAO"):SetValue(DTOC(STOD(QRY_NOT->F2_EMISSAO)))
			oItens:Cell("F2_DOC"):SetValue(QRY_NOT->F2_DOC)
			oItens:Cell("F2_SERIE"):SetValue(QRY_NOT->F2_SERIE)
			oItens:Cell("F2_EST"):SetValue(QRY_NOT->F2_EST)			
			oItens:Cell("A1_NOME"):SetValue(QRY_NOT->A1_NOME)
			oItens:Cell("A1_CGC"):SetValue(QRY_NOT->A1_CGC)
			oItens:Cell("A1_INSCR"):SetValue(QRY_NOT->A1_INSCR)	
			oItens:Cell("D2_QUANT"):SetValue(QRY_NOT->D2_QUANT)	
			oItens:Cell("D2_TOTAL"):SetValue(QRY_NOT->D2_TOTAL)	

			oItens:PrintLine()
		EndIf

		nTotQT += QRY_NOT->D2_QUANT
		nTotal += QRY_NOT->D2_TOTAL
		
		oReport:IncMeter()
		QRY_NOT->(DbSkip())
	EndDo
	
	//Se for sintético, atualiza e imprime
	If MV_PAR06 == 2
		oItens:Cell("D2_QUANT"):SetValue(nTotQt)
		oItens:Cell("D2_TOTAL"):SetValue(nTotal)
		oItens:PrintLine()
	EndIf
	
	oItens:Finish()
	oDados:Finish()
	
	QRY_NOT->(DbCloseArea())
Return

/*---------------------------------------------------------------------*
 | Func:  fVldPerg                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  21/01/2015                                                   |
 | Desc:  Função para criar o grupo de perguntas                       |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

Static Function fVldPerg()
	Local aRegs
	Local i, j
	Local aAreaPerg := GetArea()
	
	//Selecionando a tabela de perguntas
	dbSelectArea("SX1")
	dbSetOrder(1)
	
	aRegs:={}
	
	cPerg := PADR(cPerg,10)
	
	//Adicionando perguntas
	aAdd(aRegs,{cPerg,"01","Data NF De?"			,"" ,"" ,"mv_ch1","D",	TamSX3('F2_EMISSAO')[01],	0,0,"G","","mv_par01","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","",		"","",""})
	aAdd(aRegs,{cPerg,"02","Data NF Até?"			,"" ,"" ,"mv_ch2","D",	TamSX3('F2_EMISSAO')[01],	0,0,"G","","mv_par02","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","",		"","",""})
	aAdd(aRegs,{cPerg,"03","Agrupar por?"			,"" ,"" ,"mv_ch3","N",	01,							0,0,"C","","mv_par03","TES",		"","","","","CFOP",			"","","","","",				"","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"04","TES?"					,"" ,"" ,"mv_ch4","C",  TamSX3('F4_CODIGO')[01],	0,0,"G","","mv_par04","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","SF4_X",	"","",""})
	aAdd(aRegs,{cPerg,"05","CFOP?"					,"" ,"" ,"mv_ch5","C",  TamSX3('F4_CF')[01],		0,0,"G","","mv_par05","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","13",	"","",""})
	aAdd(aRegs,{cPerg,"06","Tipo?"					,"" ,"" ,"mv_ch6","N",	01,							0,0,"C","","mv_par06","Normal",		"","","","","Sintético",	"","","","","",				"","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"07","Filial?"				,"" ,"" ,"mv_ch7","C",  TamSX3('F2_FILIAL')[01],	0,0,"G","","mv_par07","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","SM0",	"","",""})
	aAdd(aRegs,{cPerg,"08","Armazem de?"			,"" ,"" ,"mv_ch8","C",  TamSX3('D3_LOCAL')[01],		0,0,"G","","mv_par08","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","",		"","",""})
	aAdd(aRegs,{cPerg,"09","Armazem até?"			,"" ,"" ,"mv_ch9","C",  TamSX3('D3_LOCAL')[01],		0,0,"G","","mv_par09","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","",		"","",""})
	aAdd(aRegs,{cPerg,"10","Filtrar UF?"			,"" ,"" ,"mv_cha","C",  99,							0,0,"G","","mv_par10","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","12_MA",	"","",""})
	aAdd(aRegs,{cPerg,"11","Tipo Pessoa?"			,"" ,"" ,"mv_chb","N",	01,							0,0,"C","","mv_par11","Ambos",		"","","","","P. Fisica",	"","","","","P. Juridica",	"","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"12","Filtrar Produtos?"		,"" ,"" ,"mv_chc","C",  99,							0,0,"G","","mv_par12","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","SB1_MA",	"","",""})

	//Inserindo os dados
	For i := 1 to Len(aRegs)
		//Se não conseguir posicionar na pergunta + o numero da pergunta		
		If !dbSeek(cPerg+aRegs[i,2])
			//Travalando a tabela
			RecLock("SX1",.T.)
			//Percorrendo o array e gravando os dados
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next j
			MsUnlock()
			dbCommit()
		EndIf
	Next i
	
	RestArea(aAreaPerg)
Return