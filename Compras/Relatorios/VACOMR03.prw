//**********************************************
//RELATORIO DE DIARIAS- Versao Nova Baseado na SC7 E CONTRATO DE PARCERIA
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
#DEFINE EXTENSAO 	3200
#DEFINE CENTRO  	1500
#DEFINE CDIREITO 	2900


User Function VACOMR03()
	local oReport
	local cPerg := PadR('VACOMR03',10)
 
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
	Local cTitulo := '[VAFINR03] - Diárias '

	oReport := TReport():New('VACOMR03', cTitulo, , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de diárias lancadas no sistema")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
 
	oSection1 := TRSection():New(oReport,"Diárias -  ( atualizado até  "+'Periodo de digitacao: ' + SubStr(DtoS(MV_PAR05),7,2)+'/'+SubStr(DtoS(MV_PAR05),5,2) +'/'+ SubStr(DtoS(MV_PAR05),1,4) + " a: " + SubStr(DtoS(MV_PAR06),7,2)+'/'+SubStr(DtoS(MV_PAR06),5,2) +'/'+ SubStr(DtoS(MV_PAR06),1,4)+")" ,{"SC7DIA"})
	oSection1:SetTotalInLine(.F.)          

	TRCell():New(oSection1, "Z7PEDIDO" 		, "SC7DIA", 'Ped.Compra'	,PesqPict('SC7',"C7_NUM")		,TamSX3("C7_PEDIDO")[1]+4	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():new(oSection1, "Z7DATA"		, "SC7DIA", 'Data'			,PesqPict('SC7',"C7_EMISSAO")	,TamSX3("C7_EMISSAO")[1]+2		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7FORNECE"		, "SC7DIA", 'Fornecedor'	,PesqPict('SC7',"C7_FORNECE")	,TamSX3("C7_FORNECE")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
//	TRCell():New(oSection1, "Z7LOJA"		, "SC7DIA", 'Loja'			,PesqPict('SZ7',"Z7_LOJA")		,TamSX3("Z7_LOJA")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7NOME"		, "SC7DIA", 'R.Social'		,PesqPict('SA2',"A2_NOME")		,TamSX3("A2_NOME")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7PRODUTO"		, "SC7DIA", 'Servico'		,PesqPict('SC7',"C7_PRODUTO")	,TamSX3("C7_PRODUTO")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7DESCP"		, "SC7DIA", 'Desc.Produto'	,PesqPict('SB1',"B1_DESC")		,TamSX3("B1_DESC")[1]-30	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7DESCRIC"		, "SC7DIA", 'Desc.Serviço'	,PesqPict('SC7',"C7_DESCRI")	,TamSX3("C7_DESCRI")[1]-80	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7REQUISI"		, "SC7DIA", 'Requisicao'	,PesqPict('SC7',"C7_X_REQUI")	,TamSX3("C7_X_REQUI")[1]-80	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z7QUANT"		, "SC7DIA", "Quantidade"	,PesqPict('SC7',"C7_QUANT")		,TamSX3("C7_QUANT")[1]+7 		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z7VUNIT"		, "SC7DIA", "Vl.Unit."		,PesqPict('SC7',"C7_VALOR")		,TamSX3("C7_VUNIT")[1]+7 		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z7TOTAL"		, "SC7DIA", "Quantidade"	,PesqPict('SC7',"C7_TOTAL")		,TamSX3("C7_TOTAL")[1]+3 		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7MOTOR"		, "SC7DIA", 'Motorista'		,PesqPict('DA4',"DA4_NOME")		,TamSX3("DA4_NOME")[1]-15	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7VEICULO"		, "SC7DIA", 'Veiculo'		,PesqPict('SC7',"C7_X_VEICU")	,TamSX3("C7_X_VEICU")[1]+3	,/*lPixel*/,/*{|| code-block de impressao }*/)

	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("Z7FORNECE"),,.F.)
//	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("Z7PRODUTO"),,.F.)
 
//	TRFunction():New(oSection1:Cell("C7_FILIAL"),"TOTAL FILIAL","COUNT",oBreak,,"@E 999999",,.F.,.F.)

// oBreak := TRBreak():New(oSection2,oSection2:Cell("quebra"),"Total") 
//             TRFunction():New(oSection2:Cell("COD2"),"Total Grupos","COUNT",oBreak,,,,.F.,.F.) 
 
	TRFunction():New(oSection1:Cell("Z7QUANT")	,"Qtde "			,"SUM",oBreak1,,PesqPict('SC7',"C7_QUANT"),,.F.,.T.)	
	TRFunction():New(oSection1:Cell("Z7TOTAL") 	," Valor Total" 	,"SUM",oBreak1,,PesqPict('SC7',"C7_TOTAL"),,.F.,.T.)	

//	TRFunction():New(oSection1:Cell("Z7QUANT")	,"Qtde "			,"SUM",oBreak2,,PesqPict('SZ7',"Z7_QUANT"),,.F.,.T.)	
//	TRFunction():New(oSection1:Cell("Z7TOTAL") ," Valor Total" 	,"SUM",oBreak2,,PesqPict('SZ7',"Z7_TOTAL"),,.F.,.T.)	

	//TRFunction():New(oSection1:Cell("Z7QUANT")	,"Qtde "			,"SUM",,,PesqPict('SZ7',"Z7_QUANT"),,.F.,.T.)	
	//TRFunction():New(oSection1:Cell("Z7TOTAL") ," Valor Total" 	,"SUM",,,PesqPict('SZ7',"Z7_TOTAL"),,.F.,.T.)	
 
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
	
	If Select("SC7DIA") > 0
		SC7DIA->(DbCloseArea())
	EndIf



	strSQL := " SELECT C7_FILIAL AS Z7_FILIAL, C7_NUM AS Z7_PEDIDO, C7_FORNECE AS Z7_FORNECE, C7_LOJA AS Z7_LOJA, A2_NOME, A2_MUN, A2_EST, "
	strSQL += " C7_PRODUTO AS Z7_SERVICO, B1_DESC, C7_DESCRI AS Z7_DESCRIC, C7_X_REQUI AS Z7_REQUI, "
	strSQL += " C7_QUANT AS Z7_QUANT, C7_PRECO AS  Z7_VUNIT, C7_TOTAL AS Z7_TOTAL, "
	strSQL += " C7_X_VEICU AS Z7_VEICULO, C7_X_MOTOR AS Z7_MOTOR, DA4_NOME, C7_CCUSTO AS Z7_CCUSTO, C7_EMISSAO AS Z7_DATA, '' as Z7_FILDOC, '' as Z7_DOC, '' as Z7_SERIE , '' as Z7_ITEMNF, '' as Z7_STATUS "
	strSQL += " FROM " + RetSqlName("SC7") + " AS SZ7 WITH (NOLOCK) "
	strSQL += " LEFT JOIN SB1010 SB1 WITH (NOLOCK) ON (B1_FILIAL ='" +xFILIAL("SB1")+ "'  AND Z7_SERVICO=B1_COD  AND SB1.D_E_L_E_T_='') "
	strSQL += " LEFT JOIN SA2010 SA2 WITH (NOLOCK) ON (A2_FILIAL ='" +xFILIAL("SA2")+ "'  AND Z7_FORNECE=A2_COD  AND Z7_LOJA=A2_LOJA AND SB1.D_E_L_E_T_='') "
	strSQL += " LEFT JOIN DA4010 DA4 WITH (NOLOCK) ON (DA4_FILIAL='" +xFILIAL("DA4")+ "'  AND Z7_MOTOR=DA4_COD   AND DA4.D_E_L_E_T_='') "
	strSQL += " LEFT JOIN DA3010 DA3 WITH (NOLOCK) ON (DA3_FILIAL='" +xFILIAL("DA3")+ "'  AND Z7_VEICULO=DA3_COD AND DA3.D_E_L_E_T_='') "
	strSQL += " WHERE SZ7.D_E_L_E_T_ = '' "
	strSQL += " AND C7_FORNECE BETWEEN	'" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	strSQL += " AND C7_LOJA BETWEEN 	'" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	strSQL += " AND C7_EMISSAO BETWEEN 	'" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "
	strSQL += " AND C7_PRODUTO BETWEEN 	'" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
	strSQL += " ORDER BY C7_FILIAL, C7_FORNECE, C7_EMISSAO, C7_NUM, C7_PRODUTO "	
	
	Memowrite("D:\TOTVS\VACOMR03.txt",strSQL)	
	
	If Select("SC7DIA") > 0
		SC7DIA->(DbCloseArea())
	EndIf
	TcQuery strSQL New Alias "SC7DIA"

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
 
	DbSelectArea('SC7DIA')
	SC7DIA->(dbGoTop())
	oReport:SetMeter(SC7DIA->(RecCount()))
	
	
	While SC7DIA->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf
				
		oReport:IncMeter()
  
		oSection1:Cell("Z7PEDIDO"):SetValue(SC7DIA->Z7_PEDIDO)
		oSection1:Cell("Z7PEDIDO"):SetAlign("LEFT")
 
		oSection1:Cell("Z7DATA"):SetValue(STOD(SC7DIA->Z7_DATA))
		oSection1:Cell("Z7DATA"):SetAlign("LEFT")

		oSection1:Cell("Z7FORNECE"):SetValue(SC7DIA->Z7_FORNECE)
		oSection1:Cell("Z7FORNECE"):SetAlign("LEFT")

	//	oSection1:Cell("Z7LOJA"):SetValue(SC7DIA->Z7_LOJA)
	//	oSection1:Cell("Z7LOJA"):SetAlign("LEFT")

		oSection1:Cell("Z7NOME"):SetValue(SC7DIA->A2_NOME)
		oSection1:Cell("Z7NOME"):SetAlign("LEFT")

		oSection1:Cell("Z7PRODUTO"):SetValue(SC7DIA->Z7_SERVICO)
		oSection1:Cell("Z7PRODUTO"):SetAlign("LEFT")

		oSection1:Cell("Z7DESCP"):SetValue(Alltrim(SC7DIA->B1_DESC))
		oSection1:Cell("Z7DESCP"):SetAlign("LEFT")

		oSection1:Cell("Z7DESCRIC"):SetValue(SC7DIA->Z7_DESCRIC)
		oSection1:Cell("Z7DESCRIC"):SetAlign("LEFT")
		
		oSection1:Cell("Z7REQUISI"):SetValue(SC7DIA->Z7_REQUI)
		oSection1:Cell("Z7REQUISI"):SetAlign("LEFT")
		

		oSection1:Cell("Z7QUANT"):SetValue(SC7DIA->Z7_QUANT)
		oSection1:Cell("Z7QUANT"):SetAlign("RIGTH")

		oSection1:Cell("Z7VUNIT"):SetValue(SC7DIA->Z7_VUNIT)
		oSection1:Cell("Z7VUNIT"):SetAlign("RIGTH")

		oSection1:Cell("Z7TOTAL"):SetValue(SC7DIA->Z7_TOTAL)
		oSection1:Cell("Z7TOTAL"):SetAlign("RIGTH")

		oSection1:Cell("Z7MOTOR"):SetValue(SC7DIA->DA4_NOME)
		oSection1:Cell("Z7MOTOR"):SetAlign("LEFT")

		oSection1:Cell("Z7VEICULO"):SetValue(SC7DIA->Z7_VEICULO)
		oSection1:Cell("Z7VEICULO"):SetAlign("LEFT")

//		oSection1:Cell("Z7STATUS"):SetValue(SC7DIA->Z7_STATUS)
//		oSection1:Cell("Z7STATUS"):SetAlign("LEFT")


		oSection1:PrintLine()
 
		dbSelectArea("SC7DIA")
		SC7DIA->(dbSkip())
				

	EndDo
	oSection1:Finish()
	SC7DIA->(DbCloseArea())
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

	AADD(aRegs,{cPerg,"01","Fornecedor De         ?",Space(20),Space(20),"mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	AADD(aRegs,{cPerg,"02","Fornecedor Ate        ?",Space(20),Space(20),"mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	AADD(aRegs,{cPerg,"03","Loja De               ?",Space(20),Space(20),"mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Loja Ate              ?",Space(20),Space(20),"mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})		
	AADD(aRegs,{cPerg,"05","Emissao de         	  ?",Space(20),Space(20),"mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"06","Emissao até        	  ?",Space(20),Space(20),"mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"07","Servico De            ?",Space(20),Space(20),"mv_ch7","C",15,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
	AADD(aRegs,{cPerg,"08","Servico Ate           ?",Space(20),Space(20),"mv_ch8","C",15,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
	AADD(aRegs,{cPerg,"09","Imprime Excel         ?",Space(20),Space(20),"mv_ch9","N",01,0,2,"C","","mv_par09","1-Sim","","","","","2-Nao","","","","","","","","","","","","","","","","","","","","","","","",""})

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

	
			

                                                                                 
