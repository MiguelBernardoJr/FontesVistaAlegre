//**********************************************
//RELATORIO DE TITULOS PAGOS - Versao Nova
//**********************************************
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE DMPAPER_A4 9
#DEFINE PAD_RIGHT 	1 

#DEFINE COL_1		0000
#DEFINE COL_2		0300
#DEFINE COL_3		0550
#DEFINE COL_4		0700
#DEFINE COL_5		0900
#DEFINE COL_6		1100
#DEFINE COL_7		1700 
#DEFINE COL_8		3000
#DEFINE EXTESAO 	3200
#DEFINE CENTRO  	1500
#DEFINE CDIREITO 	2900


User Function VAFINR06()
	local oReport
	local cPerg := PadR('VAFINR06',10)
 
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
	Local cTitulo := '[VAFINR06] - Titulos Pagos - ' + iif(MV_PAR09==1,"Analitico ","Sintetico ")'

	oReport := TReport():New('VAFINR06', cTitulo, , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de titulos a pagar com data de digitacao ")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
 
	oSection1 := TRSection():New(oReport,"Titulos Pagos - " + iif(MV_PAR09==1,"Analitico ","Sintetico ") + " ( atualizado até  "+'Periodo de Pagamento: ' + SubStr(DtoS(MV_PAR03),7,2)+'/'+SubStr(DtoS(MV_PAR03),5,2) +'/'+ SubStr(DtoS(MV_PAR03),1,4) + " a: " + SubStr(DtoS(MV_PAR04),7,2)+'/'+SubStr(DtoS(MV_PAR04),5,2) +'/'+ SubStr(DtoS(MV_PAR04),1,4)+")" ,{"ORSSE2"})
	oSection1:SetTotalInLine(.F.)          
	
	TRCell():New(oSection1, "TITFILIAL" 	, "ORSSE2", 'Filial'		,PesqPict('SE2',"E2_FILIAL")	,TamSX3("E2_FILIAL")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "TITNATUREZ" 	, "ORSSE2", 'Natureza'		,PesqPict('SED',"ED_DESCRIC")	,TamSX3("ED_DESCRIC")[1]+10	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():new(oSection1, "TITPAGTO"		, "ORSSE2", 'Dt.Pagto'		,PesqPict('SE2',"E2_VENCTO")	,TamSX3("E2_VENCTO")[1]+2	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "TITPREFIXO"	, "ORSSE2", 'Pref.'			,PesqPict('SE2',"E2_PREFIXO")	,TamSX3("E2_PREFIXO")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITNUM"		, "ORSSE2", 'Numero'		,PesqPict('SE2',"E2_NUM")		,TamSX3("E2_NUM")[1]+3		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITTIPO"		, "ORSSE2", 'Tipo'			,PesqPict('SE2',"E2_TIPO")		,TamSX3("E2_TIPO")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITPARC"		, "ORSSE2", 'Parcela'		,PesqPict('SE2',"E2_PARCELA")	,TamSX3("E2_PARCELA")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITNOMFOR"		, "ORSSE2", 'Fornecedor'	,PesqPict('SE2',"E2_NOMFOR")	,TamSX3("E2_NOMFOR")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITHIST"		, "ORSSE2", 'Historico'		,PesqPict('SE5',"E5_HISTOR")	,TamSX3("E5_HISTOR")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "TITVALOR"		, "ORSSE2", "Valor Pago"	,PesqPict('SE5',"E5_VALOR")		,TamSX3("E5_VALOR")[1] 	,/*lPixel*/,/*{|| code-block de impressao }*/)


	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("TITFILIAL"),,.F.)
	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("TITNATUREZ"),,.F.)
 
//	TRFunction():New(oSection1:Cell("C7_FILIAL"),"TOTAL FILIAL","COUNT",oBreak,,"@E 999999",,.F.,.F.)

// oBreak := TRBreak():New(oSection2,oSection2:Cell("quebra"),"Total") 
//             TRFunction():New(oSection2:Cell("COD2"),"Total Grupos","COUNT",oBreak,,,,.F.,.F.) 
 
//	TRFunction():New(oSection1:Cell("TITFILIAL"),"Qtde de Titulos"	,"COUNT",oBreak1,,"@E 999999",,.F.,.T.)	
	TRFunction():New(oSection1:Cell("TITVALOR") ," Valor Total" 	,"SUM",oBreak1,,PesqPict('SE2',"E2_VALOR"),,.F.,.T.)	

//	TRFunction():New(oSection1:Cell("TITNATUREZ"),"Natureza"		,"COUNT",oBreak2,,"@E 999999",,.F.,.T.)	
	TRFunction():New(oSection1:Cell("TITVALOR") ," Valor Total" 	,"SUM",oBreak2,,PesqPict('SE2',"E2_VALOR"),,.F.,.T.)	

//	TRFunction():New(oSection1:Cell("TITFILIAL"),"Qtde de Titulos"	,"COUNT",,,"@E 999999",,.F.,.T.)	
	TRFunction():New(oSection1:Cell("TITVALOR") ," Valor Total" 	,"SUM",,,PesqPict('SE2',"E2_VALOR"),,.F.,.T.)	
 
return (oReport) 
 
 
 Static Function PrintReport(oReport)
 	Local strSQL := ''
	Local oSection1 := oReport:Section(1)
	Local cCHTipo, cDescNatur	
	Local dDtDispo	 
	Local aCheques := {}

	Local nTot1:=0
	Local strCliente:=""  
	Local xNumCTR:=""   

	Private strDia, strDiaAtu, strNomeImp, strNatur, strNaturA,strForn, strFornA, mTotalN:=0, mTotalP:=0, mTotal:=0, cNaturs := '', mTotalC:= 0, mTotalF:= 0, mTotalD:= 0
	
	If Select("ORSSE2") > 0
		ORSSE2->(DbCloseArea())
	EndIf




	cNaturs := alltrim(MV_PAR10)
	If MV_PAR09==1 ////RELATORIO ANALITICO
		strSQL:="SELECT E5_FILIAL, E2_NOMFOR AS E2_NOMFOR, E5_DATA, E5_PREFIXO, E5_NUMERO, E5_TIPO, E5_PARCELA, E5_CLIFOR, "
	Else
		strSQL:="SELECT E5_FILIAL, E2_NOMFOR AS E2_NOMFOR, E5_DATA, E5_PREFIXO, E5_NUMERO, E5_TIPO, E5_PARCELA, E5_CLIFOR, "
	Endif
	strSQL+="E5_LOJA, E5_BENEF, E2_HIST, E5_VALOR, CASE WHEN E2_NATUREZ = '' THEN '99999' ELSE E2_NATUREZ END AS E2_NATUREZ, E5_TIPODOC, E5_KEY, E5_SEQ, E5_HISTOR AS E5HIST FROM " + RetSqlName("SE5") + " AS SE5 WITH (NOLOCK) "
	strSQL+="INNER JOIN " + RetSqlName("SE2") + " AS SE2 WITH (NOLOCK) ON E2_FILIAL = E5_FILIAL "
	strSQL+="	AND E2_FORNECE = E5_CLIFOR "
	strSQL+="	AND E2_LOJA = E5_LOJA "
	strSQL+="	AND E2_NUM = E5_NUMERO "
	strSQL+="	AND E2_PREFIXO = E5_PREFIXO "
	strSQL+="	AND E2_PARCELA = E5_PARCELA AND SE2.D_E_L_E_T_ <> '*' "
	strSQL+="WHERE SE5.D_E_L_E_T_ <> '*' " 
	
	
	If !Empty(ALLTRIM(MV_PAR11))
		cPfxAux := ALLTRIM(MV_PAR11)
		If ";"$cPfxAux
			cPfx := StrTran(ALLTRIM(MV_PAR11), ';', "','")
		Else	
			cPfx := StrTran(cPfxAux+';', ';', "','")
		Endif	
//		cPfx := StrTran(ALLTRIM(MV_PAR11), ';', "','")
		If SubStr(cPfx, Len(cPfx)-1, 2) == ",'"
			cPfx := "'"+SubStr(cPfx, 1, Len(cPfx)-2)
		EndIf
		strSQL+="	AND E5_PREFIXO IN ("+cPfx+") "
	EndIf
	
	If !Empty(MV_PAR10)
		cNaturs := StrTran(cNaturs, ';', "','")
		If SubStr(cNaturs, Len(cNaturs)-1, 2) == ",'"
			cNaturs := "'"+SubStr(cNaturs, 1, Len(cNaturs)-2)
		EndIf
		strSQL+="	AND SE5.E5_NATUREZ IN ('"+cNaturs+"') "
	EndIf
	
	strSQL+="	AND E5_FILIAL 	BETWEEN '"+MV_PAR01+"' 			AND '"+MV_PAR02+"' "
	strSQL+="	AND E5_DATA 	BETWEEN '"+DtOS(MV_PAR03)+"' 	AND '"+DtOS(MV_PAR04)+"' "
	strSQL+="	AND E5_CLIFOR 	BETWEEN '"+MV_PAR05+"' 			AND '"+MV_PAR06+"' "
	strSQL+="	AND E5_LOJA 	BETWEEN '"+MV_PAR07+"' 			AND '"+MV_PAR08+"' "
	strSQL+="	AND E5_RECPAG = 'P' "
	strSQL+="	AND E5_MOTBX IN ('NOR','DEB') "
	strSQL+="	AND (E5_TIPODOC+E5_MOTBX <> 'BANOR')  " // nao considerar baixas que tenham cheque
	strSQL+="	AND E5_TIPODOC NOT IN ('ES') "	// desconsiderar estornos
	strSQL+="	AND E5_VALOR > 0 " // para evitar impressao de linhas nao consideradas no movimento de descontos, etc
	// foi incluido para tratar cancelamento de compensacoes com cheques cancelados
	strSQL+="	AND E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ NOT IN  "
	strSQL+="	(SELECT EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM FROM " + RetSqlName("SEF") + "  SEF WITH (NOLOCK) WHERE EF_NATUR ='NTCHEST'  AND EF_IMPRESS='C'  AND EF_NUM <> ''  AND SEF.D_E_L_E_T_ = '' ) "

	
	
	strSQL+="UNION ALL "             
	
	If MV_PAR09==1 //RELATORIO ANALITICO
		strSQL+="SELECT E5_FILIAL, E1_NOMCLI AS E2_NOMFOR, E5_DATA, E5_PREFIXO, E5_NUMERO, E5_TIPO, E5_PARCELA,  E5_CLIFOR, "
	Else
		strSQL+="SELECT E5_FILIAL, E1_NOMCLI AS  E2_NOMFOR, E5_DATA, E5_PREFIXO, E5_NUMERO, E5_TIPO, E5_PARCELA, E5_CLIFOR, "
	Endif
	strSQL+="E5_LOJA, E5_BENEF, E1_HIST AS E2_HIST, E5_VALOR, CASE WHEN E1_NATUREZ = '' THEN '99999' ELSE E1_NATUREZ END AS E2_NATUREZ,  E5_TIPODOC, E5_KEY, E5_SEQ, E5_HISTOR AS E5HIST FROM " + RetSqlName("SE5") + " AS SE5 WITH (NOLOCK) "
	strSQL+="INNER JOIN " + RetSqlName("SE1") + " AS SE1 WITH (NOLOCK) ON E1_FILIAL = E5_FILIAL "
	strSQL+="	AND E1_CLIENTE = E5_CLIFOR "
	strSQL+="	AND E1_LOJA = E5_LOJA "
	strSQL+="	AND E1_NUM = E5_NUMERO "
	strSQL+="	AND E1_PREFIXO = E5_PREFIXO "
	strSQL+="	AND E1_PARCELA = E5_PARCELA AND SE1.D_E_L_E_T_ <> '*' "
	strSQL+="WHERE SE5.D_E_L_E_T_ <> '*' "
	
	//Prefixos
	If !Empty(ALLTRIM(MV_PAR11))
		cPfxAux := ALLTRIM(MV_PAR11)
		If ";"$cPfxAux
			cPfx := StrTran(ALLTRIM(MV_PAR11), ';', "','")
		Else	
			cPfx := StrTran(cPfxAux+';', ';', "','")
		Endif	
//		cPfx := StrTran(ALLTRIM(MV_PAR11), ';', "','")
		If SubStr(cPfx, Len(cPfx)-1, 2) == ",'"
			cPfx := "'"+SubStr(cPfx, 1, Len(cPfx)-2)
		EndIf
		strSQL+="	AND E5_PREFIXO IN ("+cPfx+") "
	EndIf

	If !Empty(MV_PAR10)
		cNaturs := StrTran(cNaturs, ';', "','")
		If SubStr(cNaturs, Len(cNaturs)-1, 2) == ",'"
			cNaturs := "'"+SubStr(cNaturs, 1, Len(cNaturs)-2)
		EndIf
		strSQL+="	AND SE5.E5_NATUREZ IN ('"+cNaturs+"') "
	EndIf
	
	strSQL+="	AND E5_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	strSQL+="	AND E5_DATA BETWEEN '"+DtOS(MV_PAR03)+"' AND '"+DtOS(MV_PAR04)+"' "
	strSQL+="	AND E5_CLIFOR 	BETWEEN '"+MV_PAR05+"' 			AND '"+MV_PAR06+"' "
	strSQL+="	AND E5_LOJA 	BETWEEN '"+MV_PAR07+"' 			AND '"+MV_PAR08+"' "
	strSQL+="	AND E5_RECPAG = 'P' "
	strSQL+="	AND E5_MOTBX IN ('NOR','DEB') "
	strSQL+="	AND (E5_TIPODOC+E5_MOTBX <> 'BANOR')  " // nao considerar baixas que tenham cheque
	strSQL+="	AND E5_TIPODOC NOT IN ('ES') "	// desconsiderar estornos
	strSQL+="	AND E5_VALOR > 0 " // para evitar impressao de linhas nao consideradas no movimento de descontos, etc
	// foi incluido para tratar cancelamento de compensacoes com cheques cancelados
	strSQL+="	AND E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ NOT IN  "
	strSQL+="	(SELECT EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM FROM " + RetSqlName("SEF") + "  SEF WITH (NOLOCK) WHERE EF_NATUR ='NTCHEST'  AND EF_IMPRESS='C'  AND EF_NUM <> ''  AND SEF.D_E_L_E_T_ = '' ) "
	

	strSQL+="UNION ALL "             
	
	If MV_PAR09==1 //RELATORIO ANALITICO
		strSQL+="SELECT E5_FILIAL, 'MOV.BANCARIO' AS E2_NOMFOR,  E5_DATA, E5_PREFIXO, E5_NUMERO, E5_TIPO, E5_PARCELA,  E5_CLIFOR, "
	Else
		strSQL+="SELECT E5_FILIAL, 'MOV.BANCARIO' AS  E2_NOMFOR, E5_DATA, E5_PREFIXO, E5_NUMERO, E5_TIPO, E5_PARCELA, E5_CLIFOR, "
	Endif
	strSQL+="E5_LOJA, E5_BENEF, E5_HISTOR AS E2_HIST, E5_VALOR, CASE WHEN E5_NATUREZ = '' THEN '99999' ELSE E5_NATUREZ END AS E2_NATUREZ,  E5_TIPODOC, E5_KEY, E5_SEQ, E5_HISTOR AS E5HIST FROM " + RetSqlName("SE5") + " AS SE5 WITH (NOLOCK) "
	strSQL+="WHERE SE5.D_E_L_E_T_ <> '*' "
	
	//Prefixos
	If !Empty(ALLTRIM(MV_PAR11))
		cPfxAux := ALLTRIM(MV_PAR11)
		If ";"$cPfxAux
			cPfx := StrTran(ALLTRIM(MV_PAR11), ';', "','")
		Else	
			cPfx := StrTran(cPfxAux+';', ';', "','")
		Endif	
//		cPfx := StrTran(ALLTRIM(MV_PAR11), ';', "','")
		If SubStr(cPfx, Len(cPfx)-1, 2) == ",'"
			cPfx := "'"+SubStr(cPfx, 1, Len(cPfx)-2)
		EndIf
		strSQL+="	AND E5_PREFIXO IN ("+cPfx+") "
	EndIf

	If !Empty(MV_PAR10)
		cNaturs := StrTran(cNaturs, ';', "','")
		If SubStr(cNaturs, Len(cNaturs)-1, 2) == ",'"
			cNaturs := "'"+SubStr(cNaturs, 1, Len(cNaturs)-2)
		EndIf
		strSQL+="	AND SE5.E5_NATUREZ IN ('"+cNaturs+"') "
	EndIf
	
	strSQL+="	AND E5_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	strSQL+="	AND E5_DATA BETWEEN '"+DtOS(MV_PAR03)+"' AND '"+DtOS(MV_PAR04)+"' "
	strSQL+="	AND E5_CLIFOR 	BETWEEN '"+MV_PAR05+"' 			AND '"+MV_PAR06+"' "
	strSQL+="	AND E5_LOJA 	BETWEEN '"+MV_PAR07+"' 			AND '"+MV_PAR08+"' "
	strSQL+="	AND E5_CLIFOR = '' " 
	strSQL+="	AND E5_RECPAG = 'P' "
//	strSQL+="	AND E5_MOTBX IN ('NOR','DEB') "
	strSQL+="	AND (E5_TIPODOC+E5_MOTBX <> 'BANOR')  " // nao considerar baixas que tenham cheque
	strSQL+="	AND E5_TIPODOC NOT IN ('ES','TR','TB') "	// desconsiderar estornos
	strSQL+="	AND E5_VALOR > 0 " // para evitar impressao de linhas nao consideradas no movimento de descontos, etc
	// foi incluido para tratar cancelamento de compensacoes com cheques cancelados
	strSQL+="	AND E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ NOT IN  "
	strSQL+="	(SELECT EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM FROM " + RetSqlName("SEF") + "  SEF WITH (NOLOCK) WHERE EF_NATUR ='NTCHEST'  AND EF_IMPRESS='C'  AND EF_NUM <> ''  AND SEF.D_E_L_E_T_ = '' ) "

		
	strSQL+= " ORDER BY E5_FILIAL ASC, E5_DATA ASC, E2_NATUREZ ASC, E5_CLIFOR ASC, E5_LOJA ASC, E5_TIPO ASC, E5_PREFIXO ASC, E5_NUMERO ASC "
	

	Memowrite("D:\TOTVS\VAFINR05.txt",strSQL)	
	
	If Select("ORSSE2") > 0
		ORSSE2->(DbCloseArea())
	EndIf
	TcQuery strSQL New Alias "ORSSE2"


	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
 
	DbSelectArea('ORSSE2')
	ORSSE2->(dbGoTop())
	oReport:SetMeter(ORSSE2->(RecCount()))
	
	
	While ORSSE2->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf

		//DESCONSIDERA TITULOS ESTORNADOS
		If Estornado()
			DbSelectArea("ORSSE2")
			ORSSE2->(DbSkip())
			Loop
		EndIf
		
		//DESCONSIDERA DESCONTO/JUROS/MULTA			
		If AllTrim(ORSSE2->E5_TIPODOC)$ "DC,JR,MT"
			DbSelectArea("ORSSE2")
			ORSSE2->(DbSkip())
			Loop
		EndIf  			
		

		oReport:IncMeter()
 
		oSection1:Cell("TITFILIAL"):SetValue(ORSSE2->E5_FILIAL)
		oSection1:Cell("TITFILIAL"):SetAlign("LEFT")
		cDescNatur := Alltrim(ORSSE2->E2_NATUREZ) + ' - ' + POSICIONE("SED",1,XFILIAL("SED")+ORSSE2->E2_NATUREZ,"ED_DESCRIC")//	
		oSection1:Cell("TITNATUREZ"):SetValue(cDescNatur)
		oSection1:Cell("TITNATUREZ"):SetAlign("LEFT")
 
		oSection1:Cell("TITPAGTO"):SetValue(STOD(ORSSE2->E5_DATA))
		oSection1:Cell("TITPAGTO"):SetAlign("CENTER")

		oSection1:Cell("TITPREFIXO"):SetValue(ORSSE2->E5_PREFIXO)
		oSection1:Cell("TITPREFIXO"):SetAlign("LEFT")

		oSection1:Cell("TITNUM"):SetValue(ORSSE2->E5_NUMERO)
		oSection1:Cell("TITNUM"):SetAlign("LEFT")

		oSection1:Cell("TITTIPO"):SetValue(ORSSE2->E5_TIPO)
		oSection1:Cell("TITTIPO"):SetAlign("LEFT")

		oSection1:Cell("TITPARC"):SetValue(ORSSE2->E5_PARCELA)
		oSection1:Cell("TITPARC"):SetAlign("LEFT")

 
		oSection1:Cell("TITNOMFOR"):SetValue(ORSSE2->E2_NOMFOR)
		oSection1:Cell("TITNOMFOR"):SetAlign("LEFT")


	//	oSection1:Cell("NATDESCRIC"):SetValue(ORSSE2->NATDESCRIC)
	//	oSection1:Cell("NATDESCRIC"):SetAlign("LEFT")

	
		oSection1:Cell("TITHIST"):SetValue( iif(AllTrim(ORSSE2->E5_TIPO)=="RA","DEV.RECEB.ANTECIPADO",Alltrim(ORSSE2->E5HIST)) )
		oSection1:Cell("TITHIST"):SetAlign("LEFT")

		oSection1:Cell("TITVALOR"):SetValue(ORSSE2->E5_VALOR)
		oSection1:Cell("TITVALOR"):SetAlign("RIGTH")


		oSection1:PrintLine()
 
		dbSelectArea("ORSSE2")
		ORSSE2->(dbSkip())
				

	EndDo
	oSection1:Finish()
	ORSSE2->(DbCloseArea())
Return
 
 
 


///**************************************************************************
///PERGUNTAS DO RELATÓRIO
///**************************************************************************
Static Function ValidPerg(cPerg)
Local _sAlias,i,j

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}                                                  

	AADD(aRegs,{cPerg,"01","Filial De             ?",Space(20),Space(20),"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Filial Ate            ?",Space(20),Space(20),"mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Pagos de         	  ?",Space(20),Space(20),"mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Pagos até        	  ?",Space(20),Space(20),"mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Fornecedor De         ?",Space(20),Space(20),"mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	AADD(aRegs,{cPerg,"06","Fornecedor Ate        ?",Space(20),Space(20),"mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	AADD(aRegs,{cPerg,"07","Loja De               ?",Space(20),Space(20),"mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"08","Loja Ate              ?",Space(20),Space(20),"mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})		
	AADD(aRegs,{cPerg,"09","Tipo relatório		  ?",Space(20),Space(20),"mv_ch9","N",01,0,2,"C","","mv_par09","1-Analítico","","","","","2-Sintético","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"10","Natureza (sep. p/ ';')?",Space(20),Space(20),"mv_cha","C",99,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SEDMKB","","","","",""})
	AADD(aRegs,{cPerg,"11","Prefixo  (sep. p/ ';')?",Space(20),Space(20),"mv_chb","C",99,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"12","Imprime Excel         ?",Space(20),Space(20),"mv_chc","N",01,0,2,"C","","mv_par09","1-Sim","","","","","2-Nao","","","","","","","","","","","","","","","","","","","","","","","",""})

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
	
Return

	
			

                                                                                 

//Verifica se movimento foi estornado
Static Function Estornado()
Local lRet := .f.

	cSql := "SELECT E5_NUMERO "
	cSql += "FROM " + RetSqlName("SE5") + " "
	cSql += "WHERE E5_FILIAL = '" + ORSSE2->E5_FILIAL + "' AND E5_PREFIXO = '" + ORSSE2->E5_PREFIXO + "' AND "
	cSql += "E5_NUMERO = '" + ORSSE2->E5_NUMERO + "' AND E5_PARCELA = '" + ORSSE2->E5_PARCELA + "' AND "
	cSql += "E5_TIPO = '" + ORSSE2->E5_TIPO + "' AND E5_CLIFOR = '" + ORSSE2->E5_CLIFOR + "' AND "
	cSql += "E5_LOJA = '" + ORSSE2->E5_LOJA + "' AND E5_SEQ = '" + ORSSE2->E5_SEQ + "' AND "
	If ORSSE2->E5_TIPODOC == "PA"
		cSql += "E5_KEY = '" + ORSSE2->E5_KEY + "' AND "
	EndIf
	cSql += "E5_RECPAG = 'R' AND E5_TIPODOC = 'ES' AND D_E_L_E_T_ <> '*' "
	
	TcQuery cSql NEW ALIAS "QEST"
	If !Eof()
		lRet := .t.
	EndIf          
	
	QEST->(DbCloseArea())

Return lRet