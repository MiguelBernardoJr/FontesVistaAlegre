#include "rwmake.ch"
#include "protheus.ch"     
#include "topconn.ch"    

#define DMPAPER_A4 9


User Function VAFINR03()
	local oReport
	local cPerg := PadR('VAFINR03',10)
 
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
	Local cTitulo := '[VAFINR03] - Titulo a Pagar por Periodo'

	oReport := TReport():New('VAFINR03', cTitulo, , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de titulos a pagar com data de digitacao ")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
 
	oSection1 := TRSection():New(oReport,"Titulo a Pagar por Periodo",{"QRYPAG"})
	oSection1:SetTotalInLine(.F.)          
	
	TRCell():New(oSection1, "TITFILIAL" 	, "QRYPAG", 'Filial'		,PesqPict('SE2',"E2_FILIAL")	,TamSX3("E2_FILIAL")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "TITPREFIXO"	, "QRYPAG", 'Pref.'			,PesqPict('SE2',"E2_PREFIXO")	,TamSX3("E2_PREFIXO")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITNUM"		, "QRYPAG", 'Numero'		,PesqPict('SE2',"E2_NUM")		,TamSX3("E2_NUM")[1]+3		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITTIPO"		, "QRYPAG", 'Tipo'			,PesqPict('SE2',"E2_TIPO")		,TamSX3("E2_TIPO")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITFORNECE"	, "QRYPAG", 'Forn.'			,PesqPict('SE2',"E2_FORNECE")	,TamSX3("E2_FORNECE")[1]+3+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITNOMFOR"		, "QRYPAG", 'Fornecedor'	,PesqPict('SE2',"E2_NOMFOR")	,TamSX3("E2_NOMFOR")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITNAT"		, "QRYPAG", 'Natureza'		,PesqPict('SE2',"E2_NATUREZ")	,TamSX3("E2_NATUREZ")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "NATDESCRIC"	, "QRYPAG", 'Desc. Naturez.',PesqPict('SED',"ED_DESCRIC")	,TamSX3("ED_DESCRIC")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITEMISSAO"	, "QRYPAG", 'Dt.Emissao'	,PesqPict('SE2',"E2_EMISSAO")	,TamSX3("E2_EMISSAO")[1]+2	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITVENCTO"		, "QRYPAG", 'Dt.Vencto'		,PesqPict('SE2',"E2_VENCTO")	,TamSX3("E2_VENCTO")[1]+2	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITVENCREA"	, "QRYPAG", 'Dt.Venc.Real'	,PesqPict('SE2',"E2_VENCREA")	,TamSX3("E2_VENCREA")[1]+2	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITBAIXA"		, "QRYPAG", 'Dt.Baixa'		,PesqPict('SE2',"E2_BAIXA")		,TamSX3("E2_BAIXA")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITVALOR"		, "QRYPAG", "Valor Orig."	,PesqPict('SE2',"E2_VALOR")		,TamSX3("E2_VALOR")[1]+5 	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITSALDO"		, "QRYPAG", "Valor Saldo."	,PesqPict('SE2',"E2_SALDO")		,TamSX3("E2_SALDO")[1]+5 	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITVALLIQ"		, "QRYPAG", "Valor Liquid."	,PesqPict('SE2',"E2_VALLIQ")	,TamSX3("E2_VALLIQ")[1]+5 	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITACRESC"		, "QRYPAG", "Acrescimo"		,PesqPict('SE2',"E2_ACRESC")	,TamSX3("E2_ACRESC")[1]+2 	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITHIST"		, "QRYPAG", 'Historico'		,PesqPict('SE2',"E2_HIST")		,TamSX3("E2_HIST")[1]-30	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITXXDTDIG"	, "QRYPAG", 'Dt.Digitacao'	,PesqPict('SE2',"E2_XXDTDIG")	,TamSX3("E2_XXDTDIG")[1]+2	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITEMIS1"		, "QRYPAG", 'Dt.Base'		,PesqPict('SE2',"E2_EMIS1")		,TamSX3("E2_EMIS1")[1]+2	,/*lPixel*/,/*{|| code-block de impressao }*/)

 

//	oBreak := TRBreak():New(oSection1,oSection1:Cell("E5_FILIAL"),,.F.)
 
//	TRFunction():New(oSection1:Cell("C7_FILIAL"),"TOTAL FILIAL","COUNT",oBreak,,"@E 999999",,.F.,.F.)
 
	TRFunction():New(oSection1:Cell("TITFILIAL"),"Qtde de Titulos"	,"COUNT",,,"@E 999999",,.F.,.T.)	
	TRFunction():New(oSection1:Cell("TITVALOR") ," Valor Total" 	,"SUM",,,PesqPict('SE2',"E2_VALOR"),,.F.,.T.)	
	TRFunction():New(oSection1:Cell("TITSALDO") ," Valor Saldo" 	,"SUM",,,PesqPict('SE2',"E2_SALDO"),,.F.,.T.)	
	TRFunction():New(oSection1:Cell("TITVALLIQ")," Liquid. Total" 	,"SUM",,,PesqPict('SE2',"E2_VALLIQ"),,.F.,.T.)	
	TRFunction():New(oSection1:Cell("TITACRESC")," Acresc. Total" 	,"SUM",,,PesqPict('SE2',"E2_ACRESC"),,.F.,.T.)	
 
return (oReport)
 
Static Function PrintReport(oReport)
 	Local cQRYPAG := ''
	Local oSection1 := oReport:Section(1)
	//Local cCHTipo	
	//Local dDtDispo	 
	//Local aCheques := {}
	
	Local nCont
	If Select("QRYPAG") > 0
		QRYPAG->(DbCloseArea())
	EndIf


/*
 
SELECT 
SE2.E2_PREFIXO	AS TITFILIAL,
SE2.E2_PREFIXO	AS TITPREFIXO,
SE2.E2_TIPO		AS TITTIPO, 
SE2.E2_NUM		AS TITNUM, 
SE2.E2_FORNECE +'-'+SE2.E2_LOJA AS TITFORNECE, 
SE2.E2_NOMFOR	AS TITNOMFOR, 
SE2.E2_NATUREZ	AS TITNAT,
SED.ED_DESCRIC	AS NATDESCRI,
SE2.E2_EMISSAO	AS TITEMISSAO, 
SE2.E2_VENCTO	AS TITVENCTO,
SE2.E2_VENCREA	AS TITVENCREA,
SE2.E2_BAIXA	AS TITBAIXA,
SE2.E2_VALOR	AS VL_ORIGINAL, 
SE2.E2_VALLIQ	AS VL_LIQUIDACAO, 
SE2.E2_ACRESC	AS VL_ACRESCIMO, 
SE2.E2_HIST,
SE2.E2_XXDTDIG	AS TITXXDTDIG,
SE2.E2_EMIS1	AS TITEMIS1
FROM SE2010 as SE2
LEFT JOIN SED010 SED ON (ED_FILIAL = '' AND ED_CODIGO = E2_NATUREZ AND SED.D_E_L_E_T_ = '')
WHERE SE2.D_E_L_E_T_ <> '*'
--AND SE2.E2_EMISSAO BETWEEN '20150717' AND '20150723'
AND SE2.E2_XXDTDIG	BETWEEN '20150717' AND '20150723'
AND SE2.E2_FILIAL	BETWEEN '' AND 'ZZ'
AND SE2.E2_FORNECE	BETWEEN '' AND 'ZZ'
AND SE2.E2_LOJA	BETWEEN '' AND 'ZZ'
AND SE2.E2_FILIAL	NOT IN ('70') 
AND SE2.E2_TIPO		NOT IN('PA','PR','PRE')
AND SE2.E2_NATUREZ	NOT IN ('')

 
*/ 


	cQRYPAG += 	" SELECT "
	cQRYPAG += 	" SE2.E2_FILIAL	    AS TITFILIAL, "
	cQRYPAG += 	" SE2.E2_PREFIXO	AS TITPREFIXO, "
	cQRYPAG += 	" SE2.E2_TIPO		AS TITTIPO, "
	cQRYPAG += 	" SE2.E2_NUM		AS TITNUM, "
	cQRYPAG += 	" SE2.E2_FORNECE +'-'+SE2.E2_LOJA AS TITFORNECE, "
	cQRYPAG += 	" SE2.E2_NOMFOR		AS TITNOMFOR, "
	cQRYPAG += 	" SE2.E2_NATUREZ	AS TITNAT, "
	cQRYPAG += 	" SED.ED_DESCRIC	AS NATDESCRIC, "
	cQRYPAG += 	" SE2.E2_EMISSAO	AS TITEMISSAO, "
	cQRYPAG += 	" SE2.E2_VENCTO		AS TITVENCTO, "
	cQRYPAG += 	" SE2.E2_VENCREA	AS TITVENCREA, "
	cQRYPAG += 	" SE2.E2_BAIXA		AS TITBAIXA, "
	cQRYPAG += 	" SE2.E2_VALOR		AS TITVALOR, " 
	cQRYPAG += 	" SE2.E2_SALDO		AS TITSALDO, " 
	cQRYPAG += 	" SE2.E2_VALLIQ		AS TITVALLIQ, "
	cQRYPAG += 	" SE2.E2_ACRESC		AS TITACRESC, "
	cQRYPAG += 	" SE2.E2_HIST		AS TITHIST, "
	cQRYPAG += 	" SE2.E2_XXDTDIG	AS TITXXDTDIG, "
	cQRYPAG += 	" SE2.E2_EMIS1		AS TITEMIS1 "
	cQRYPAG += 	" FROM " + RetSqlName("SE2") + " AS SE2 "
	cQRYPAG += 	" LEFT JOIN " + RetSqlName("SED") + " SED ON (ED_FILIAL = '' AND ED_CODIGO = E2_NATUREZ AND SED.D_E_L_E_T_ = '') "   
	cQRYPAG += 	" WHERE SE2.D_E_L_E_T_ <> '*' "

	If mv_par07 == 1 		// digitacao E2_XXDTDIG
		cQRYPAG += 	" AND SE2.E2_XXDTDIG	BETWEEN '"+dtos(MV_PAR08)+"' AND '"+dtos(MV_PAR09)+"' "
	Elseif mv_par07 == 2 	// emissao E2_EMISSAO
		cQRYPAG += 	" AND SE2.E2_EMISSAO 	BETWEEN '"+dtos(MV_PAR08)+"' AND '"+dtos(MV_PAR09)+"' "    
    Else 					// data base sistema  E2_EMIS1
		cQRYPAG += 	" AND SE2.E2_EMIS1 		BETWEEN '"+dtos(MV_PAR08)+"' AND '"+dtos(MV_PAR09)+"' "    
    Endif

	If mv_par12 == 1 		// filtra data da baixa
		cQRYPAG += 	" AND SE2.E2_BAIXA	BETWEEN '"+dtos(MV_PAR13)+"' AND '"+dtos(MV_PAR14)+"' "
    Endif

	cQRYPAG += 	" AND SE2.E2_VENCREA	BETWEEN '"+dtos(MV_PAR15)+"' AND '"+dtos(MV_PAR16)+"' "
	cQRYPAG += 	" AND SE2.E2_FILIAL		BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQRYPAG += 	" AND SE2.E2_FORNECE	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' "
	cQRYPAG += 	" AND SE2.E2_LOJA		BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' "
	cQRYPAG += 	" AND SE2.E2_FILIAL	NOT IN ('70') " 

	cNatOut := ""
	If !Empty(MV_PAR10)
		aNatOut := StrTokArr(AllTrim(MV_PAR10),";")	
		For nCont := 1 To Len(aNatOut)
			cNatOut += If(Empty(cNatOut),"'",",'") + aNatOut[nCont] + "'"
		Next		
		cQRYPAG += 	" AND SE2.E2_NATUREZ NOT IN ("+cNatOut+") "
	EndIf

	cTipoOut := ""
	If !Empty(MV_PAR11)
		aTipoOut := StrTokArr(AllTrim(MV_PAR11),";")	
		For nCont := 1 To Len(aTipoOut)
			cTipoOut += If(Empty(cTipoOut),"'",",'") + aTipoOut[nCont] + "'"
		Next		
		cQRYPAG += 	" AND SE2.E2_TIPO NOT IN ("+cTipoOut+") "
	EndIf

	cPrefOut := ""
	If !Empty(MV_PAR17)
		aPrefOut := StrTokArr(AllTrim(MV_PAR17),";")	
		For nCont := 1 To Len(aPrefOut)
			cPrefOut += If(Empty(cPrefOut),"'",",'") + aPrefOut[nCont] + "'"
		Next		
		cQRYPAG += 	" AND SE2.E2_PREFIXO NOT IN ("+cPrefOut+") "
	EndIf

	If mv_par07 == 1 		// digitacao E2_XXDTDIG
		cQRYPAG += 	" ORDER BY SE2.E2_XXDTDIG, SE2.E2_EMIS1, SE2.E2_EMISSAO, SE2.E2_FILIAL, SE2.E2_NOMFOR, SE2.E2_TIPO, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA "
	Elseif mv_par07 == 2 	// emissao E2_EMISSAO
		cQRYPAG += 	" ORDER BY SE2.E2_EMISSAO, 	SE2.E2_FILIAL, SE2.E2_NOMFOR, SE2.E2_TIPO, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA "
    Else 					// data base sistema  E2_EMIS1
		cQRYPAG += 	" ORDER BY SE2.E2_EMIS1, 	SE2.E2_FILIAL, SE2.E2_NOMFOR, SE2.E2_TIPO, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA "
    Endif
 

  	memowrite("D:\TOTVS\vafinr03.txt", cQRYPAG)
	TCQUERY cQRYPAG NEW ALIAS "QRYPAG"    
	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
 
	DbSelectArea('QRYPAG')
	QRYPAG->(dbGoTop())
	oReport:SetMeter(QRYPAG->(RecCount()))
	
	
	While QRYPAG->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf
 
//		aAdd(aCheques,{ EF_FILIAL + EF_NUM + EF_BANCO + EF_AGENCIA + EF_CONTA + EF_TIPO + EF_BENEF , EF_VALOR})

		oReport:IncMeter()
 
		oSection1:Cell("TITFILIAL"):SetValue(QRYPAG->TITFILIAL)
		oSection1:Cell("TITFILIAL"):SetAlign("LEFT")
 
		oSection1:Cell("TITPREFIXO"):SetValue(QRYPAG->TITPREFIXO)
		oSection1:Cell("TITPREFIXO"):SetAlign("LEFT")

		oSection1:Cell("TITTIPO"):SetValue(QRYPAG->TITTIPO)
		oSection1:Cell("TITTIPO"):SetAlign("LEFT")

		oSection1:Cell("TITNUM"):SetValue(QRYPAG->TITNUM)
		oSection1:Cell("TITNUM"):SetAlign("LEFT")
 
		oSection1:Cell("TITFORNECE"):SetValue(QRYPAG->TITFORNECE)
		oSection1:Cell("TITFORNECE"):SetAlign("LEFT")
 
		oSection1:Cell("TITNOMFOR"):SetValue(QRYPAG->TITNOMFOR)
		oSection1:Cell("TITNOMFOR"):SetAlign("LEFT")

		oSection1:Cell("TITNAT"):SetValue(QRYPAG->TITNAT)
		oSection1:Cell("TITNAT"):SetAlign("LEFT")

		oSection1:Cell("NATDESCRIC"):SetValue(QRYPAG->NATDESCRIC)
		oSection1:Cell("NATDESCRIC"):SetAlign("LEFT")

		oSection1:Cell("TITEMISSAO"):SetValue(STOD(QRYPAG->TITEMISSAO))
		oSection1:Cell("TITEMISSAO"):SetAlign("CENTER")

		oSection1:Cell("TITVENCTO"):SetValue(STOD(QRYPAG->TITVENCTO))
		oSection1:Cell("TITVENCTO"):SetAlign("CENTER")

		oSection1:Cell("TITVENCREA"):SetValue(STOD(QRYPAG->TITVENCREA))
		oSection1:Cell("TITVENCREA"):SetAlign("CENTER")
		
		oSection1:Cell("TITBAIXA"):SetValue(STOD(QRYPAG->TITBAIXA))
		oSection1:Cell("TITBAIXA"):SetAlign("CENTER")

		oSection1:Cell("TITVALOR"):SetValue(QRYPAG->TITVALOR)
		oSection1:Cell("TITVALOR"):SetAlign("RIGTH")

		oSection1:Cell("TITVALLIQ"):SetValue(QRYPAG->TITVALLIQ)
		oSection1:Cell("TITVALLIQ"):SetAlign("RIGTH")

		oSection1:Cell("TITACRESC"):SetValue(QRYPAG->TITACRESC)
		oSection1:Cell("TITACRESC"):SetAlign("RIGTH")

		oSection1:Cell("TITHIST"):SetValue(QRYPAG->TITHIST)
		oSection1:Cell("TITHIST"):SetAlign("LEFT")

		oSection1:Cell("TITXXDTDIG"):SetValue(STOD(QRYPAG->TITXXDTDIG))
		oSection1:Cell("TITXXDTDIG"):SetAlign("CENTER")

		oSection1:Cell("TITEMIS1"):SetValue(STOD(QRYPAG->TITEMIS1))
		oSection1:Cell("TITEMIS1"):SetAlign("CENTER")

		oSection1:PrintLine()
 
		dbSelectArea("QRYPAG")
		QRYPAG->(dbSkip())
				

	EndDo
	oSection1:Finish()
	QRYPAG->(DbCloseArea())
Return
        


Static Function ValidPerg(cPerg)        
Local _sAlias, i, j

	_sAlias	:=	Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg 	:=	PADR(cPerg,10)
	aRegs	:=	{}
	//                                                                                                      -- 02 03 04 05 -- 07 08 09 10 -- 12 13 14 15 -- 17 18 19 20 -- 22 23 24 F3
	AADD(aRegs,{cPerg,"01","Filial De        ?",Space(20),Space(20),"mv_ch1","C",02							,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","","",""})
	AADD(aRegs,{cPerg,"02","Filial Até       ?",Space(20),Space(20),"mv_ch2","C",02							,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","","",""})
	AADD(aRegs,{cPerg,"03","Fornecedor De    ?",Space(20),Space(20),"mv_ch3","C",TamSX3("E2_FORNECE")[1]	,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","","","","",""})
	AADD(aRegs,{cPerg,"04","Loja De          ?",Space(20),Space(20),"mv_ch4","C",TamSX3("E2_LOJA")[1]		,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Fornecedor Até   ?",Space(20),Space(20),"mv_ch5","C",TamSX3("E2_FORNECE")[1]	,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","","","","",""})
	AADD(aRegs,{cPerg,"06","Loja Até         ?",Space(20),Space(20),"mv_ch6","C",TamSX3("E2_LOJA")[1]		,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"07","Qual Data        ?",Space(20),Space(20),"mv_ch7","N",01							,0,0,"C","","mv_par07","Digitacao NF","","","","","Dt Emissao","","","","","Dt Base Sistema","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"08","Emissao De       ?",Space(20),Space(20),"mv_ch8","D",08							,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"09","Emissao Até      ?",Space(20),Space(20),"mv_ch9","D",08							,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"10","Desconsid. Natur.?",Space(20),Space(20),"mv_cha","C",99							,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SEDMKB","","","","","",""})
	AADD(aRegs,{cPerg,"11","Desconsid. Tipo  ?",Space(20),Space(20),"mv_chb","C",99							,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","TIPOMB","","","","","",""})
	AADD(aRegs,{cPerg,"12","Filtra Dt Baixa  ?",Space(20),Space(20),"mv_chc","N",01							,0,0,"C","","mv_par12","Filtra Dt Baixa","","","","","Nao Filtrar Baixa","","","","","Dt Base Sistema","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"13","Dt Baixa De      ?",Space(20),Space(20),"mv_chd","D",08							,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"14","Dt Baixa Até     ?",Space(20),Space(20),"mv_che","D",08							,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"15","Dt Vencto De     ?",Space(20),Space(20),"mv_chf","D",08							,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"16","Dt Vencto Até    ?",Space(20),Space(20),"mv_chg","D",08							,0,0,"G","","mv_par16","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"17","Desconsid.Prefixo?",Space(20),Space(20),"mv_chh","C",99							,0,0,"G","","mv_par17","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

