#include "rwmake.ch"
#include "protheus.ch"     
#include "topconn.ch"    

#define DMPAPER_A4 9


User Function VAFATR02()
	local oReport
	local cPerg := PadR('VAFATR02',10)
 
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
	Local cTitulo := '[VAFATR02] - Relação de Faturamento de Gado'

	oReport := TReport():New('VAFATR02', cTitulo, , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de notas fiscais de gado, seus complementos e contra-notas")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
 
	oSection1 := TRSection():New(oReport,"Relação de Faturamento de Gado",{"QRYFAT"})
	oSection1:SetTotalInLine(.F.)          
	
	TRCell():New(oSection1, "FATFILIAL" 	, "QRYFAT", 'Filial'		,PesqPict('SF2',"F2_FILIAL")	,TamSX3("F2_FILIAL")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():new(oSection1, "FATEMISSAO"	, "QRYFAT", 'Dt.Emissao'	,PesqPict('SF2',"F2_EMISSAO")	,TamSX3("F2_EMISSAO")[1]+2	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "FATNUM"		, "QRYFAT", 'Numero'		,PesqPict('SF2',"F2_DOC")		,TamSX3("F2_DOC")[1]+3		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "FATSERIE"		, "QRYFAT", 'Série'			,PesqPict('SF2',"F2_SERIE")		,TamSX3("F2_SERIE")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "FATPROD"		, "QRYFAT", 'Produto'		,PesqPict('SD2',"D2_COD")		,TamSX3("D2_COD")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "FATDESCPRO"	, "QRYFAT", 'Descricao'		,PesqPict('SB1',"B1_DESC")		,TamSX3("B1_DESC")[1]-30	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "FATQUANT"		, "QRYFAT", "Quant."		,PesqPict('SD2',"D2_QUANT")		,TamSX3("E2_VALOR")[1]+3 	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "FATPRUNIT"		, "QRYFAT", "R$ Unit."		,PesqPict('SD2',"D2_PRUNIT")	,TamSX3("D2_PRUNIT")[1]+3 	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "FATTOTAL"		, "QRYFAT", "R$ Total"		,PesqPict('SD2',"D2_TOTAL")		,TamSX3("D2_TOTAL")[1]+3 	,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():new(oSection1, "FATCNUM"		, "QRYFAT", 'Cp.Num.'		,PesqPict('SF2',"F2_DOC")		,TamSX3("F2_DOC")[1]+4		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "FATCEMISSAO"	, "QRYFAT", 'Cp.Emissao'	,PesqPict('SF2',"F2_EMISSAO")	,TamSX3("F2_EMISSAO")[1]+4	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "FATCTOTAL"		, "QRYFAT", "Cp.R$ Total"	,PesqPict('SD2',"D2_TOTAL")		,TamSX3("D2_TOTAL")[1]+3 	,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():new(oSection1, "FATSOMA"		, "QRYFAT", "R$ NF+Compl."	,PesqPict('SD2',"D2_TOTAL")		,TamSX3("D2_TOTAL")[1]+6 	,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():new(oSection1, "FATENUM"		, "QRYFAT", 'Nf.Entrada'	,PesqPict('SF2',"F2_X_NFENT")	,TamSX3("F2_X_NFENT")[1]+4	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "FATEENT"		, "QRYFAT", 'Nf.Ent.Data'	,PesqPict('SF2',"F2_X_DTENT")	,TamSX3("F2_X_DTENT")[1]+2	,/*lPixel*/,/*{|| code-block de impressao }*/)


 

//	oBreak := TRBreak():New(oSection1,oSection1:Cell("E5_FILIAL"),,.F.)
 
//	TRFunction():New(oSection1:Cell("C7_FILIAL"),"TOTAL FILIAL","COUNT",oBreak,,"@E 999999",,.F.,.F.)
 
//	TRFunction():New(oSection1:Cell("TITFILIAL"),"Qtde de Titulos"	,"COUNT",,,"@E 999999",,.F.,.T.)	
	TRFunction():New(oSection1:Cell("FATQUANT") ," Qtde Total" 			,"SUM",,,PesqPict('SD2',"D2_QUANT"),,.F.,.T.)	
	TRFunction():New(oSection1:Cell("FATTOTAL") ," NF Total" 			,"SUM",,,PesqPict('SD2',"D2_TOTAL"),,.F.,.T.)	
	TRFunction():New(oSection1:Cell("FATCTOTAL")," Compl.Total" 		,"SUM",,,PesqPict('SD2',"D2_TOTAL"),,.F.,.T.)	
	TRFunction():New(oSection1:Cell("FATSOMA")  ," Total NF+Compl." 	,"SUM",,,PesqPict('SE2',"E2_VALOR"),,.F.,.T.)	
 
return (oReport)
 
Static Function PrintReport(oReport)
 	Local cQRYFAT := ''
	Local oSection1 := oReport:Section(1)
	//Local nOrder := oSection1.GetOrder()
	//Local cOrder := ""
	If Select("QRYFAT") > 0
		QRYFAT->(DbCloseArea())
	EndIf


/*
 
//-- SELECT PARA BUSCAR NOTAS FISCAIS DO BETTER
//-- VINCULA NOTAS COM SEUS COMPLEMENTOS
//-- VINCULA NOTAS COM NF BETTER
//--SD2C.D2_NFORI, SD2C.D2_SERIORI, SD2C.D2_ITEMORI,

SELECT SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_EMISSAO, 
SD2.D2_CLIENTE, SD2.D2_LOJA, SA1.A1_NOME, SA1.A1_MUN, SA1.A1_EST, 
SD2.D2_COD, B1_DESC, 
SD2.D2_QUANT, SD2.D2_PRUNIT, SD2.D2_TOTAL,
SD2C.D2_DOC, SD2C.D2_SERIE, SD2C.D2_ITEM,
SF2.F2_X_NFENT, SF2.F2_X_DTENT
FROM SD2010 SD2
LEFT JOIN SF2010 SF2  ON (SF2.F2_FILIAL=SD2.D2_FILIAL AND SF2.F2_CLIENTE=SD2.D2_CLIENTE AND SF2.F2_LOJA=SD2.D2_LOJA AND SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.D_E_L_E_T_='')
LEFT JOIN SD2010 SD2C ON (SD2C.D2_FILIAL=SD2.D2_FILIAL AND SD2C.D2_CLIENTE=SD2.D2_CLIENTE AND SD2C.D2_LOJA=SD2.D2_LOJA AND SD2C.D2_NFORI=SD2.D2_DOC AND SD2C.D2_SERIORI=SD2.D2_SERIE AND SD2C.D2_ITEMORI=SD2.D2_ITEM AND SD2C.D_E_L_E_T_='')
LEFT JOIN SB1010 SB1  ON (B1_FILIAL='' AND B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_='')
LEFT JOIN SA1010 SA1  ON (A1_FILIAL='' AND A1_COD=SD2.D2_CLIENTE AND A1_LOJA=SD2.D2_LOJA AND SA1.D_E_L_E_T_='')
WHERE SD2.D2_EMISSAO BETWEEN '' AND 'ZZ'
AND SD2.D2_FILIAL	BETWEEN '' AND 'ZZ'
AND SD2.D2_CLIENTE	BETWEEN '' AND 'ZZ'
AND SD2.D2_COD		BETWEEN '' AND 'ZZ'
AND SD2.D2_GRUPO	BETWEEN '' AND 'ZZ'
AND SD2.D_E_L_E_T_ = ''
AND SD2.D2_NFORI = ''
--AND SF2.F2_X_NFENT <> ''

 
*/ 


	cQRYFAT += 	" SELECT SD2.D2_FILIAL AS FATFILIAL, SD2.D2_DOC AS FATNUM, SD2.D2_SERIE AS FATSERIE, SD2.D2_EMISSAO AS FATEMISSAO, "
	cQRYFAT += 	" SD2.D2_CLIENTE AS FATCLIENTE, SD2.D2_LOJA AS FATLOJA, SA1.A1_NOME AS CLINOME, SA1.A1_MUN AS CLIMUN, SA1.A1_EST AS CLIEST,"
	cQRYFAT += 	" SD2.D2_COD AS FATPROD, B1_DESC AS FATDESCPRO,  "
	cQRYFAT += 	" SD2.D2_QUANT AS FATQUANT, SD2.D2_PRUNIT AS FATPRUNIT, SD2.D2_TOTAL AS FATTOTAL, "
	cQRYFAT += 	" SD2C.D2_DOC AS FATCNUM, SD2C.D2_SERIE AS FATCSERIE, SD2C.D2_ITEM AS FATCITEM, SD2C.D2_EMISSAO AS FATCEMISSAO,  SD2C.D2_TOTAL FATCTOTAL,"
	cQRYFAT += 	" SF2.F2_X_NFENT AS FATENUM, SF2.F2_X_DTENT AS FATEENT "

	cQRYFAT += 	" FROM " + RetSqlName("SD2") + " AS SD2 "
	cQRYFAT += 	" LEFT JOIN " + RetSqlName("SF2") + " SF2  ON (SF2.F2_FILIAL=SD2.D2_FILIAL AND SF2.F2_CLIENTE=SD2.D2_CLIENTE AND SF2.F2_LOJA=SD2.D2_LOJA AND SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.D_E_L_E_T_='') "   
	cQRYFAT += 	" LEFT JOIN " + RetSqlName("SD2") + " SD2C ON (SD2C.D2_FILIAL=SD2.D2_FILIAL AND SD2C.D2_CLIENTE=SD2.D2_CLIENTE AND SD2C.D2_LOJA=SD2.D2_LOJA AND SD2C.D2_NFORI=SD2.D2_DOC AND SD2C.D2_SERIORI=SD2.D2_SERIE  AND SD2C.D_E_L_E_T_='') " 
	// AND SD2C.D2_ITEMORI=SD2.D2_ITEM         //   
	cQRYFAT += 	" LEFT JOIN " + RetSqlName("SB1") + " SB1  ON (B1_FILIAL='"+xFilial("SB1")+"' AND B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_='') "   
	cQRYFAT += 	" LEFT JOIN " + RetSqlName("SA1") + " SA1  ON (A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD=SD2.D2_CLIENTE AND A1_LOJA=SD2.D2_LOJA AND SA1.D_E_L_E_T_='') "   

	cQRYFAT += 	" WHERE SD2.D_E_L_E_T_ <> '*' AND SD2.D2_NFORI = '' "
	cQRYFAT += 	" AND SD2.D2_FILIAL	 BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  "
	cQRYFAT += 	" AND SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"'  "
	cQRYFAT += 	" AND SD2.D2_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"'  "
	cQRYFAT += 	" AND SD2.D2_LOJA    BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"'  "
	cQRYFAT += 	" AND SD2.D2_COD	 BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'  "
	cQRYFAT += 	" AND SD2.D2_GRUPO	 BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"'  "
	//ORDENAÇÃO
if 		mv_par13  == 1  					// EMISSÃO NF	
	cQRYFAT += 	" ORDER BY FATFILIAL, FATEMISSAO, FATNUM "
Elseif 	mv_par13  == 2  					// EMISSÃO NF COMPLEMENTO
	cQRYFAT += 	" ORDER BY FATCEMISSAO, FATCNUM "
ElseIf 	mv_par13  == 3  					// NF ENTRADA
	cQRYFAT += 	" ORDER BY FATENUM	 "
Endif

  	memowrite("D:\TOTVS\vaFATR02.txt", cQRYFAT)
	TCQUERY cQRYFAT NEW ALIAS "QRYFAT"    
	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
 
	DbSelectArea('QRYFAT')
	QRYFAT->(dbGoTop())
	oReport:SetMeter(QRYFAT->(RecCount()))
	While QRYFAT->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf
 

		oReport:IncMeter()
 

		oSection1:Cell("FATFILIAL"):SetValue(QRYFAT->FATFILIAL)
		oSection1:Cell("FATFILIAL"):SetAlign("LEFT")
 
		oSection1:Cell("FATEMISSAO"):SetValue(STOD(QRYFAT->FATEMISSAO))
		oSection1:Cell("FATEMISSAO"):SetAlign("CENTER")

		oSection1:Cell("FATNUM"):SetValue(QRYFAT->FATNUM)
		oSection1:Cell("FATNUM"):SetAlign("LEFT")

		oSection1:Cell("FATSERIE"):SetValue(QRYFAT->FATSERIE)
		oSection1:Cell("FATSERIE"):SetAlign("LEFT")

		oSection1:Cell("FATPROD"):SetValue(QRYFAT->FATPROD)
		oSection1:Cell("FATPROD"):SetAlign("LEFT")

		oSection1:Cell("FATDESCPRO"):SetValue(QRYFAT->FATDESCPRO)
		oSection1:Cell("FATDESCPRO"):SetAlign("LEFT")

		oSection1:Cell("FATQUANT"):SetValue(QRYFAT->FATQUANT)
		oSection1:Cell("FATQUANT"):SetAlign("RIGTH")

		oSection1:Cell("FATPRUNIT"):SetValue(QRYFAT->FATPRUNIT)
		oSection1:Cell("FATPRUNIT"):SetAlign("RIGTH")

		oSection1:Cell("FATTOTAL"):SetValue(QRYFAT->FATTOTAL)
		oSection1:Cell("FATTOTAL"):SetAlign("RIGTH")

		oSection1:Cell("FATCNUM"):SetValue(QRYFAT->FATCNUM)
		oSection1:Cell("FATCNUM"):SetAlign("LEFT")

		oSection1:Cell("FATCEMISSAO"):SetValue(STOD(QRYFAT->FATCEMISSAO))
		oSection1:Cell("FATCEMISSAO"):SetAlign("CENTER")
 
		oSection1:Cell("FATCTOTAL"):SetValue(QRYFAT->FATCTOTAL)
		oSection1:Cell("FATCTOTAL"):SetAlign("RIGTH")

		oSection1:Cell("FATSOMA"):SetValue(QRYFAT->FATTOTAL + QRYFAT->FATCTOTAL)
		oSection1:Cell("FATSOMA"):SetAlign("RIGTH")

		oSection1:Cell("FATENUM"):SetValue(QRYFAT->FATENUM)
		oSection1:Cell("FATENUM"):SetAlign("LEFT")

		oSection1:Cell("FATEENT"):SetValue(STOD(QRYFAT->FATEENT))
		oSection1:Cell("FATEENT"):SetAlign("CENTER")

		oSection1:PrintLine()
 

		dbSelectArea("QRYFAT")
		QRYFAT->(dbSkip())

	EndDo
	oSection1:Finish()
	QRYFAT->(DbCloseArea())
Return
        


Static Function ValidPerg(cPerg)        
Local _sAlias, i, j

	_sAlias	:=	Alias()
	dbSelectArea("SX1")
	//dbSetOrder(1)
	cPerg 	:=	PADR(cPerg,10)
	aRegs	:=	{}
	//                                                                                                      -- 02 03 04 05 -- 07 08 09 10 -- 12 13 14 15 -- 17 18 19 20 -- 22 23 24 F3
	AADD(aRegs,{cPerg,"01","Filial De        ?",Space(20),Space(20),"mv_ch1","C",02							,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Filial Até       ?",Space(20),Space(20),"mv_ch2","C",02							,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Cliente De       ?",Space(20),Space(20),"mv_ch3","C",TamSX3("F2_CLIENTE")[1]	,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","","",""})
	AADD(aRegs,{cPerg,"04","Loja De          ?",Space(20),Space(20),"mv_ch4","C",TamSX3("F2_LOJA")[1]		,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Cliente Até      ?",Space(20),Space(20),"mv_ch5","C",TamSX3("F2_CLIENTE")[1]	,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","","",""})
	AADD(aRegs,{cPerg,"06","Loja Até         ?",Space(20),Space(20),"mv_ch6","C",TamSX3("F2_LOJA")[1]		,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"07","Emissao De       ?",Space(20),Space(20),"mv_ch7","D",08							,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"08","Emissao Até      ?",Space(20),Space(20),"mv_ch8","D",08							,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"09","Produto De       ?",Space(20),Space(20),"mv_ch9","C",TamSX3("D2_COD")[1]		,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","","",""})
	AADD(aRegs,{cPerg,"10","Produto Até      ?",Space(20),Space(20),"mv_cha","C",TamSX3("D2_COD")[1]		,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","","",""})
	AADD(aRegs,{cPerg,"11","Grupo De         ?",Space(20),Space(20),"mv_chb","C",TamSX3("D2_GRUPO")[1]		,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","","",""})
	AADD(aRegs,{cPerg,"12","Grupo Até        ?",Space(20),Space(20),"mv_chc","C",TamSX3("D2_GRUPO")[1]		,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","","",""})
	AADD(aRegs,{cPerg,"13","Ordem por        ?",Space(20),Space(20),"mv_chd","N",09							,0,0,"C","","mv_par13","Emissão NF","","","","","Emissão Compl.","","","","","NF Ref.","","","","","","","","","","","","","","","","","","","",""})

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

