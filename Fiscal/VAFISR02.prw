//Bibliotecas
#Include 'Protheus.ch'
#Include 'TopConn.ch'

//Constantes
#Define STR_PULA		Chr(13) + Chr(10)

/*/{Protheus.doc} VAFISR02
Relatório de Conferência de Notas Fiscais de Entrada
@author Atilio
@since 21/01/2015
@version 1.0
	@example
	u_VAFISR02()
/*/

User Function VAFISR02()
	Local aArea := GetArea()
	Local cFilBkp := cFilAnt
	Local oReport
	Private cPerg := "VAFISR02"

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
	oReport := TReport():New(	"VAFISR02",;														//Nome do Relatório
									"Relatório de Conferência de Notas Fiscais de Entrada",;	//Título
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
										{"SF1","SD1"})			//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectIte:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Somente se for impressão normal será impresso a linha de itens
	If MV_PAR06 == 1
		//Células dos itens
		If MV_PAR08 == 1
			TRCell():New(oSectIte,"F1_EMISSAO"	,"SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		ElseIf MV_PAR08 == 2
			TRCell():New(oSectIte,"F1_DTDIGIT"	,"SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		EndIf
		TRCell():New(oSectIte,"F1_FILIAL"	,"SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"F1_DOC"		,"SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"F1_SERIE"	,"SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"F1_EST"		,"SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"A2_NOME"		,"SA2",/*Titulo*/,/*Picture*/,         20,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"A2_CGC"		,"SA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"A2_INSCR"	,"SA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//		TRCell():New(oSectIte,"D1_QUANT"	,"SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	EndIf
	
	TRCell():New(oSectIte,"D1_QUANT"	,"SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSectIte,"D1_TOTAL"	,"SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	
	//Somente se for impressão normal será impresso a linha de itens
	If MV_PAR06 == 1
		TRCell():New(oSectIte,"CD2_PAUTA"	,"CD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"CD2_BC"		,"CD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"CD2_ALIQ"	,"CD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSectIte,"ICMS"		,"CD2","ICMS"    ,"@E 999,999,999.99", 12,/*lPixel*/,/*{|| code-block de impressao }*/)
	EndIf
	
	//Somente se for impressão normal será impresso a linha de itens
	If MV_PAR06 == 1
		TRFunction():New(oSectIte:Cell("D1_QUANT"),,"SUM",,,PesqPict("SD1","D1_QUANT"))
		TRFunction():New(oSectIte:Cell("D1_TOTAL"),,"SUM",,,PesqPict("SD1","D1_TOTAL"))
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

	//DbSelectArea("SF4")
	//DbSelectArea("SF1")
	//DbSelectArea("SD1")
	//DbSelectArea("CD2")

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
	cQuery += "    D1_TOTAL, "										+ STR_PULA
	cQuery += "    D1_QUANT, "										+ STR_PULA
	cQuery += "    F1_EMISSAO, "									+ STR_PULA
	cQuery += "    F1_DTDIGIT, "									+ STR_PULA
	cQuery += "    F1_FILIAL, "										+ STR_PULA
	cQuery += "    F1_DOC, "										+ STR_PULA
	cQuery += "    F1_SERIE, "										+ STR_PULA
	cQuery += "    F1_EST, "										+ STR_PULA
	cQuery += "    CASE WHEN F1_TIPO IN ('B','D') THEN A1_NOME ELSE A2_NOME END AS A2_NOME,    " + STR_PULA
	cQuery += "    CASE WHEN F1_TIPO IN ('B','D') THEN A1_CGC ELSE A2_CGC END AS A2_CGC,       " + STR_PULA
	cQuery += "    CASE WHEN F1_TIPO IN ('B','D') THEN A1_INSCR ELSE A2_INSCR END AS A2_INSCR, " + STR_PULA
	cQuery += "    CASE WHEN F1_TIPO IN ('B','D') THEN A1_PESSOA ELSE A2_TIPO END AS A2_TIPO,  " + STR_PULA
	cQuery += "    SF4.R_E_C_N_O_ AS SF4REC, "						+ STR_PULA
	cQuery += "    SF1.R_E_C_N_O_ AS SF1REC, "						+ STR_PULA
	cQuery += "    SD1.R_E_C_N_O_ AS SD1REC, "						+ STR_PULA
	cQuery += "    SA2.R_E_C_N_O_ AS SA2REC, "						+ STR_PULA
	cQuery += "    SA1.R_E_C_N_O_ AS SA1REC, "						+ STR_PULA
	cQuery += "    ISNULL(CD2.R_E_C_N_O_, -1) AS CD2REC  "			+ STR_PULA
	cQuery += " FROM "												+ STR_PULA
	cQuery += "    "+RetSQLName("SF1")+" SF1 "						+ STR_PULA
	cQuery += "    INNER JOIN "+RetSQLName("SD1")+" SD1 ON ( "		+ STR_PULA
	cQuery += "     SD1.D_E_L_E_T_ = '' "							+ STR_PULA
	cQuery += "     AND D1_FILIAL = F1_FILIAL "						+ STR_PULA
	cQuery += "     AND D1_DOC    = F1_DOC "						+ STR_PULA
	cQuery += "     AND D1_SERIE  = F1_SERIE "					+ STR_PULA
	cQuery += "     AND D1_FORNECE= F1_FORNECE "					+ STR_PULA
	cQuery += "     AND D1_LOJA   = F1_LOJA "					+ STR_PULA
	cQuery += "    ) "												+ STR_PULA
	cQuery += "    LEFT JOIN "+RetSQLName("CD2")+" CD2 ON ( "	+ STR_PULA
	cQuery += "     CD2.D_E_L_E_T_ = '' "							+ STR_PULA
	cQuery += "     AND CD2_TPMOV = 'E' "							+ STR_PULA
	cQuery += "     AND CD2.CD2_DOC    = SD1.D1_DOC "			+ STR_PULA
	cQuery += "     AND CD2.CD2_FILIAL = SD1.D1_FILIAL "			+ STR_PULA
	cQuery += "     AND CD2.CD2_SERIE  = SD1.D1_SERIE "			+ STR_PULA
	cQuery += "     AND CD2.CD2_CODFOR = SD1.D1_FORNECE "		+ STR_PULA
	cQuery += "     AND CD2.CD2_LOJFOR = SD1.D1_LOJA "			+ STR_PULA
	cQuery += "     AND CD2.CD2_IMP    = 'ICM' "				+ STR_PULA
	cQuery += "    ) "											+ STR_PULA
	cQuery += "    LEFT JOIN "+RetSQLName("SA2")+" SA2 ON ( "	+ STR_PULA
	cQuery += "     SA2.D_E_L_E_T_ = '' "						+ STR_PULA
	cQuery += "     AND A2_FILIAL = '"+xFilial('SA2')+"' "		+ STR_PULA
	cQuery += "     AND A2_COD  = SD1.D1_FORNECE "				+ STR_PULA
	cQuery += "     AND A2_LOJA = SD1.D1_LOJA "					+ STR_PULA
	cQuery += "    ) "											+ STR_PULA
	cQuery += "    LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( "	+ STR_PULA
	cQuery += "     SA1.D_E_L_E_T_ = '' "						+ STR_PULA
	cQuery += "     AND A1_FILIAL = '"+xFilial('SA1')+"' "		+ STR_PULA
	cQuery += "     AND A1_COD  = SD1.D1_FORNECE "				+ STR_PULA
	cQuery += "     AND A1_LOJA = SD1.D1_LOJA "					+ STR_PULA
	cQuery += "    ) "											+ STR_PULA
	cQuery += "    INNER JOIN "+RetSQLName("SF4")+" SF4 ON ( "	+ STR_PULA
	cQuery += "     SF4.D_E_L_E_T_ = '' "							+ STR_PULA
	cQuery += "     AND F4_FILIAL = '"+xFilial('SF4')+"' "		+ STR_PULA
	cQuery += "     AND F4_CODIGO = D1_TES "						+ STR_PULA
	If !Empty(MV_PAR04)
		cQuery += "     AND F4_CODIGO LIKE '%"+Alltrim(MV_PAR04)+"%' "		+ STR_PULA
	EndIf
	If !Empty(MV_PAR05)
		cQuery += "     AND F4_CF LIKE '%"+Alltrim(MV_PAR05)+"%' "	+ STR_PULA
	EndIf
	//cQuery += "     AND F4_FILIAL = D1_FILIAL "					+ STR_PULA   //TES Compartilhada, não precisa fazer join com os itens
	cQuery += "    ) "												+ STR_PULA
	cQuery += " WHERE "												+ STR_PULA
	cQuery += "    SF1.D_E_L_E_T_  = '' "							+ STR_PULA
	If MV_PAR08 == 1
		cQuery += "    AND F1_EMISSAO >= '"+dToS(MV_PAR01)+"' "		+ STR_PULA
		cQuery += "    AND F1_EMISSAO <= '"+dToS(MV_PAR02)+"' "		+ STR_PULA
	ElseIf MV_PAR08 == 2
		cQuery += "    AND F1_DTDIGIT >= '"+dToS(MV_PAR01)+"' "		+ STR_PULA
		cQuery += "    AND F1_DTDIGIT <= '"+dToS(MV_PAR02)+"' "		+ STR_PULA
	EndIf
	
	If !Empty(MV_PAR06)
		cQuery += "    AND F1_FILIAL LIKE '%"+Alltrim(MV_PAR07)+"%' "		+ STR_PULA
	EndIf
	
	//Armazem
	cQuery += "    AND D1_LOCAL >= '"+Alltrim(MV_PAR09)+"' AND  D1_LOCAL <= '"+Alltrim(MV_PAR10)+"'"		+ STR_PULA

	cESTIn := ""
	If !Empty(MV_PAR11)
		aESTIn := StrTokArr(AllTrim(MV_PAR11),";")	
		For nCont := 1 To Len(aESTIn)
			cESTIn += If(Empty(cESTIn),"'",",'") + aESTIn[nCont] + "'"
		Next		
		cQuery += " AND SF1.F1_EST IN ("+cESTIn+") "
	EndIf

	cPRODIn := ""
	If !Empty(MV_PAR13)
		aPRODIn := StrTokArr(AllTrim(MV_PAR13),";")	
		For nCont := 1 To Len(aPRODIn)
			cPRODIn += If(Empty(cPRODIn),"'",",'") + aPRODIn[nCont] + "'"
		Next		
		cQuery += " AND SD1.D1_COD IN ("+cPRODIn+") "
	EndIf

	
	//Se agrupa por TES
	If MV_PAR03 == 1
		If MV_PAR08 == 1
			cQuery += "ORDER BY F4_CODIGO, F1_FILIAL, F1_EMISSAO, F1_SERIE, F1_DOC "
		Else //MV_PAR08 == 2
			cQuery += "ORDER BY F4_CODIGO, F1_FILIAL, F1_DTDIGIT, F1_SERIE, F1_DOC "
		EndIf				
	//Senão se agrupa por CFOP
	ElseIf MV_PAR03 == 2
		If MV_PAR08 == 1
			cQuery += "ORDER BY F4_CF, F1_FILIAL, F1_EMISSAO, F1_SERIE, F1_DOC "
		Else //MV_PAR08 == 2
			cQuery += "ORDER BY F4_CF, F1_FILIAL, F1_DTDIGIT, F1_SERIE, F1_DOC "
		EndIf				
	Endif

	//Executando consulta e setando o total da régua
	TCQuery cQuery New Alias "QRY_NOT"
	MEMOWRITE("C:\TOTVS\VAFISR02.TXT",cQuery)
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
	oParam:Cell("PARAM"):SetValue("Tipo Data?")
	oParam:Cell("CONTEUDO"):SetValue(Iif(MV_PAR08 == 1, "Emissão", "Entrada"))
	oParam:PrintLine()
	oParam:Finish()

	//Enquanto houver dados
	QRY_NOT->(DbGoTop())
	While ! QRY_NOT->(Eof())

		//SF4->(DbGoTo(QRY_NOT->SF4REC))
		//SF1->(DbGoTo(QRY_NOT->SF1REC))
		//SD1->(DbGoTo(QRY_NOT->SD1REC))
//		If QRY_NOT->F1_TIPO $ 'B;D'
//			SA1->(DbGoTo(QRY_NOT->SA1REC))
//			cAxNome		:= SA1->A1_NOME
//			cAxCGC		:= SA1->A1_CGC
//			cAxINSCR	:= SA1->A1_INSCR
//			cAxPessoa	:= SA1->A1_PESSOA 		
//		Else
//			SA2->(DbGoTo(QRY_NOT->SA2REC))					
//			cAxNome		:= SA2->A2_NOME
//			cAxCGC		:= SA2->A2_CGC
//			cAxINSCR	:= SA2->A2_INSCR		
//			cAxPessoa	:= SA2->A2_TIPO 		
//		Endif
		
		// TRATAR SE É PESSOA FISICA OU JURIDICA
		If (Alltrim(QRY_NOT->A2_TIPO)$'J' .and. MV_PAR12==2) .or. (Alltrim(QRY_NOT->A2_TIPO)$'F' .and. MV_PAR12==3) // 1-ambos  	2-Fisica	3-Juridica
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
		
		//Se agrua por CFOP
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
					oItens:Cell("D1_QUANT"):SetValue(nTotQT)
					oItens:Cell("D1_TOTAL"):SetValue(nTotal)
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
				oItens:Cell("ICMS"):SetValue(QRY_NOT->CD2_PAUTA * (QRY_NOT->CD2_ALIQ /100))
			Else
				//Setando os valores
				oItens:Cell("CD2_PAUTA"):SetValue(0)
				oItens:Cell("CD2_BC"):SetValue(0)
				oItens:Cell("CD2_ALIQ"):SetValue(0)
				oItens:Cell("ICMS"):SetValue(0)
			EndIf
			
		If MV_PAR08 == 1
			oItens:Cell("F1_EMISSAO"):SetValue(DTOC(STOD(QRY_NOT->F1_EMISSAO)))
		ElseIf MV_PAR08 == 2
			oItens:Cell("F1_DTDIGIT"):SetValue(DTOC(STOD(QRY_NOT->F1_DTDIGIT)))
		EndIf

			oItens:Cell("F1_FILIAL"):SetValue(QRY_NOT->F1_FILIAL)
			oItens:Cell("F1_DOC"):SetValue(QRY_NOT->F1_DOC)
			oItens:Cell("F1_SERIE"):SetValue(QRY_NOT->F1_SERIE)
			oItens:Cell("F1_EST"):SetValue(QRY_NOT->F1_EST)			
			oItens:Cell("A2_NOME"):SetValue(QRY_NOT->A2_NOME)
			oItens:Cell("A2_CGC"):SetValue(QRY_NOT->A2_CGC)
			oItens:Cell("A2_INSCR"):SetValue(QRY_NOT->A2_INSCR)	
			oItens:Cell("D1_QUANT"):SetValue(QRY_NOT->D1_QUANT)	
			oItens:Cell("D1_TOTAL"):SetValue(QRY_NOT->D1_TOTAL)	
			oItens:PrintLine()
		EndIf

		nTotQT += QRY_NOT->D1_QUANT
		nTotal += QRY_NOT->D1_TOTAL
		oReport:IncMeter()
		QRY_NOT->(DbSkip())
	EndDo
	
	//Se for sintético, atualiza e imprime
	If MV_PAR06 == 2
		oItens:Cell("D1_QUANT"):SetValue(nTotQT)
		oItens:Cell("D1_TOTAL"):SetValue(nTotal)
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
	aAdd(aRegs,{cPerg,"01","Data NF De?"			,"" ,"" ,"mv_ch1","D",	TamSX3('F1_EMISSAO')[01],	0,0,"G","","mv_par01","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","",		"","",""})
	aAdd(aRegs,{cPerg,"02","Data NF Até?"			,"" ,"" ,"mv_ch2","D",	TamSX3('F1_EMISSAO')[01],	0,0,"G","","mv_par02","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","",		"","",""})
	aAdd(aRegs,{cPerg,"03","Agrupar por?"			,"" ,"" ,"mv_ch3","N",	01,							0,0,"C","","mv_par03","TES",		"","","","","CFOP",			"","","","","",				"","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"04","TES?"					,"" ,"" ,"mv_ch4","C",  TamSX3('F4_CODIGO')[01],	0,0,"G","","mv_par04","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","SF4_X",	"","",""})
	aAdd(aRegs,{cPerg,"05","CFOP?"					,"" ,"" ,"mv_ch5","C",  TamSX3('F4_CF')[01],		0,0,"G","","mv_par05","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","13",	"","",""})
	aAdd(aRegs,{cPerg,"06","Tipo?"					,"" ,"" ,"mv_ch6","N",	01,							0,0,"C","","mv_par06","Normal",		"","","","","Sintético",	"","","","","",				"","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"07","Filial?"				,"" ,"" ,"mv_ch7","C",  TamSX3('F1_FILIAL')[01],	0,0,"G","","mv_par07","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","SM0",	"","",""})
	aAdd(aRegs,{cPerg,"08","Tipo Data?"				,"" ,"" ,"mv_ch8","N",	01,							0,0,"C","","mv_par08","Emissão",	"","","","","Entrada",		"","","","","",				"","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"09","Armazem de?"			,"" ,"" ,"mv_ch9","C",  TamSX3('D3_LOCAL')[01],		0,0,"G","","mv_par09","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","",		"","",""})
	aAdd(aRegs,{cPerg,"10","Armazem até?"			,"" ,"" ,"mv_cha","C",  TamSX3('D3_LOCAL')[01],		0,0,"G","","mv_par10","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","",		"","",""})
	aAdd(aRegs,{cPerg,"11","Filtrar UF?"			,"" ,"" ,"mv_chb","C",  99,							0,0,"G","","mv_par11","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","12_MA",	"","",""})
	aAdd(aRegs,{cPerg,"12","Tipo Pessoa?"			,"" ,"" ,"mv_chc","N",	01,							0,0,"C","","mv_par12","Ambos",		"","","","","P. Fisica",	"","","","","P. Juridica",	"","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"13","Filtrar Produtos?"		,"" ,"" ,"mv_chd","C",  99,							0,0,"G","","mv_par13","",			"","","","","",				"","","","","",				"","","","","","","","","","","","","","SB1_MA",	"","",""})
	
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