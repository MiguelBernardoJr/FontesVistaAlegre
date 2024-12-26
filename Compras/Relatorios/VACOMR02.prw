//**********************************************
//RELATORIO DE DIARIAS- Versao Nova
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


User Function VACOMR02()
	local oReport
	local cPerg := PadR('VACOMR02',10)
 
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
	Local cTitulo := '[VAFINR02] - Diárias '

	oReport := TReport():New('VACOMR02', cTitulo, , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de diárias lancadas no sistema")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
 
	oSection1 := TRSection():New(oReport,"Diárias -  ( atualizado até  "+'Periodo de digitacao: ' + SubStr(DtoS(MV_PAR05),7,2)+'/'+SubStr(DtoS(MV_PAR05),5,2) +'/'+ SubStr(DtoS(MV_PAR05),1,4) + " a: " + SubStr(DtoS(MV_PAR06),7,2)+'/'+SubStr(DtoS(MV_PAR06),5,2) +'/'+ SubStr(DtoS(MV_PAR06),1,4)+")" ,{"SZ7DIA"})
	oSection1:SetTotalInLine(.F.)          

	TRCell():New(oSection1, "Z7PEDIDO" 		, "SZ7DIA", 'Ped.Compra'	,PesqPict('SZ7',"Z7_PEDIDO")	,TamSX3("Z7_PEDIDO")[1]+4	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():new(oSection1, "Z7DATA"		, "SZ7DIA", 'Data'			,PesqPict('SZ7',"Z7_DATA")		,TamSX3("Z7_DATA")[1]+2		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7FORNECE"		, "SZ7DIA", 'Fornecedor'	,PesqPict('SZ7',"Z7_FORNECE")	,TamSX3("Z7_FORNECE")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
//	TRCell():New(oSection1, "Z7LOJA"		, "SZ7DIA", 'Loja'			,PesqPict('SZ7',"Z7_LOJA")		,TamSX3("Z7_LOJA")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7NOME"		, "SZ7DIA", 'R.Social'		,PesqPict('SA2',"A2_NOME")		,TamSX3("A2_NOME")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7PRODUTO"		, "SZ7DIA", 'Servico'		,PesqPict('SZ7',"Z7_SERVICO")	,TamSX3("Z7_SERVICO")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7DESCP"		, "SZ7DIA", 'Desc.Produto'	,PesqPict('SZ7',"B1_DESC")		,TamSX3("B1_DESC")[1]-30	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7DESCRIC"		, "SZ7DIA", 'Desc.Serviço'	,PesqPict('SZ7',"Z7_DESCRIC")	,TamSX3("Z7_DESCRIC")[1]-80	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7REQUISI"		, "SZ7DIA", 'Requi.'	    ,PesqPict('SZ7',"Z7_REQUI")	    ,TamSX3("Z7_REQUI")[1]-80	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z7QUANT"		, "SZ7DIA", "Qtde"			,PesqPict('SZ7',"Z7_QUANT")		,TamSX3("Z7_QUANT")[1]+7 	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z7VUNIT"		, "SZ7DIA", "Vl.Unit."		,PesqPict('SZ7',"Z7_VUNIT")		,TamSX3("Z7_VUNIT")[1]+7 	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z7TOTAL"		, "SZ7DIA", "Total"			,PesqPict('SZ7',"Z7_TOTAL")		,TamSX3("Z7_TOTAL")[1]+3 	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7MOTOR"		, "SZ7DIA", 'Motorista'		,PesqPict('DA4',"DA4_NOME")		,TamSX3("DA4_NOME")[1]-15	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7VEICULO"		, "SZ7DIA", 'Veiculo'		,PesqPict('SZ7',"Z7_VEICULO")	,TamSX3("Z7_VEICULO")[1]+3	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "Z7STATUS"		, "SZ7DIA", 'Status'		,PesqPict('SZ7',"Z7_STATUS")	,TamSX3("Z7_STATUS")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)

	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("Z7FORNECE"),,.F.)
//	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("Z7PRODUTO"),,.F.)
 
//	TRFunction():New(oSection1:Cell("C7_FILIAL"),"TOTAL FILIAL","COUNT",oBreak,,"@E 999999",,.F.,.F.)

// oBreak := TRBreak():New(oSection2,oSection2:Cell("quebra"),"Total") 
//             TRFunction():New(oSection2:Cell("COD2"),"Total Grupos","COUNT",oBreak,,,,.F.,.F.) 
 
	TRFunction():New(oSection1:Cell("Z7QUANT")	,"Qtde "			,"SUM",oBreak1,,PesqPict('SZ7',"Z7_QUANT"),,.F.,.T.)	
	TRFunction():New(oSection1:Cell("Z7TOTAL") 	," Valor Total" 	,"SUM",oBreak1,,PesqPict('SZ7',"Z7_TOTAL"),,.F.,.T.)	

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
	
	If Select("SZ7DIA") > 0
		SZ7DIA->(DbCloseArea())
	EndIf


/*
SELECT Z7_FILIAL, Z7_PEDIDO, Z7_FORNECE, Z7_LOJA, A2_NOME, A2_MUN, A2_EST, Z7_SERVICO, B1_DESC, Z7_DESCRIC, Z7_QUANT, Z7_VUNIT, Z7_TOTAL, 
Z7_VEICULO, Z7_MOTOR, DA4_NOME, Z7_CCUSTO, Z7_DATA, Z7_FILDOC, Z7_DOC, Z7_SERIE , Z7_ITEMNF, Z7_STATUS
FROM SZ7010 SZ7
LEFT JOIN SB1010 SB1 ON (B1_FILIAL=''  AND Z7_SERVICO=B1_COD AND SB1.D_E_L_E_T_='')
LEFT JOIN SA2010 SA2 ON (A2_FILIAL=''  AND Z7_FORNECE=A2_COD AND Z7_LOJA=A2_LOJA AND SB1.D_E_L_E_T_='')
LEFT JOIN DA4010 DA4 ON (DA4_FILIAL='' AND Z7_MOTOR=DA4_COD AND DA4.D_E_L_E_T_='')
LEFT JOIN DA3010 DA3 ON (DA3_FILIAL='' AND Z7_VEICULO=DA3_COD AND DA3.D_E_L_E_T_='')
WHERE SZ7.D_E_L_E_T_ = ''
AND Z7_STATUS <> ''
AND Z7_FORNECE BETWEEN '' AND 'ZZ'
AND Z7_LOJA BETWEEN '' AND 'ZZ'
AND Z7_DATA BETWEEN '' AND 'ZZ'
AND Z7_SERVICO BETWEEN '' AND 'ZZ'
*/

	strSQL := " SELECT Z7_FILIAL, Z7_PEDIDO, Z7_FORNECE, Z7_LOJA, A2_NOME, A2_MUN, A2_EST, "
	strSQL += " Z7_SERVICO, B1_DESC, Z7_DESCRIC, Z7_REQUI, "
	strSQL += " Z7_QUANT, Z7_VUNIT, Z7_TOTAL, "
	strSQL += " Z7_VEICULO, Z7_MOTOR, DA4_NOME, Z7_CCUSTO, Z7_DATA, Z7_FILDOC, Z7_DOC, Z7_SERIE , Z7_ITEMNF, Z7_STATUS "
	strSQL += " FROM " + RetSqlName("SZ7") + " AS SZ7 WITH (NOLOCK) "
	strSQL += " LEFT JOIN SB1010 SB1 WITH (NOLOCK) ON (B1_FILIAL ='" +xFILIAL("SB1")+ "'  AND Z7_SERVICO=B1_COD  AND SB1.D_E_L_E_T_='') "
	strSQL += " LEFT JOIN SA2010 SA2 WITH (NOLOCK) ON (A2_FILIAL ='" +xFILIAL("SA2")+ "'  AND Z7_FORNECE=A2_COD  AND Z7_LOJA=A2_LOJA AND SA2.D_E_L_E_T_='') "
	strSQL += " LEFT JOIN DA4010 DA4 WITH (NOLOCK) ON (DA4_FILIAL='" +xFILIAL("DA4")+ "'  AND Z7_MOTOR=DA4_COD   AND DA4.D_E_L_E_T_='') "
	strSQL += " LEFT JOIN DA3010 DA3 WITH (NOLOCK) ON (DA3_FILIAL='" +xFILIAL("DA3")+ "'  AND Z7_VEICULO=DA3_COD AND DA3.D_E_L_E_T_='') "
	strSQL += " WHERE SZ7.D_E_L_E_T_ = '' "
	strSQL += " AND Z7_FORNECE BETWEEN	'" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	strSQL += " AND Z7_LOJA BETWEEN 	'" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	strSQL += " AND Z7_DATA BETWEEN 	'" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "
	strSQL += " AND Z7_SERVICO BETWEEN 	'" + MV_PAR08 + "' AND '" + MV_PAR09 + "' "
	If mv_par07 == 1 // PENDENTES
		strSQL += " AND Z7_STATUS = 'P' "	
	Else
		If mv_par07 == 2 // ATENDIDOS
			strSQL += " AND Z7_STATUS = 'A' "	
		Endif	
	Endif
	strSQL += " ORDER BY Z7_FILIAL, Z7_FORNECE, Z7_DATA, Z7_PEDIDO, Z7_SERVICO "	
	
	Memowrite("D:\TOTVS\VACOMR02.txt",strSQL)	
	
	If Select("SZ7DIA") > 0
		SZ7DIA->(DbCloseArea())
	EndIf
	TcQuery strSQL New Alias "SZ7DIA"

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
 
	DbSelectArea('SZ7DIA')
	SZ7DIA->(dbGoTop())
	oReport:SetMeter(SZ7DIA->(RecCount()))
	
	
	While SZ7DIA->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf
				
		oReport:IncMeter()
  
		oSection1:Cell("Z7PEDIDO"):SetValue(SZ7DIA->Z7_PEDIDO)
		oSection1:Cell("Z7PEDIDO"):SetAlign("LEFT")
 
		oSection1:Cell("Z7DATA"):SetValue(STOD(SZ7DIA->Z7_DATA))
		oSection1:Cell("Z7DATA"):SetAlign("LEFT")

		oSection1:Cell("Z7FORNECE"):SetValue(SZ7DIA->Z7_FORNECE)
		oSection1:Cell("Z7FORNECE"):SetAlign("LEFT")

	//	oSection1:Cell("Z7LOJA"):SetValue(SZ7DIA->Z7_LOJA)
	//	oSection1:Cell("Z7LOJA"):SetAlign("LEFT")

		oSection1:Cell("Z7NOME"):SetValue(SZ7DIA->A2_NOME)
		oSection1:Cell("Z7NOME"):SetAlign("LEFT")

		oSection1:Cell("Z7PRODUTO"):SetValue(SZ7DIA->Z7_SERVICO)
		oSection1:Cell("Z7PRODUTO"):SetAlign("LEFT")

		oSection1:Cell("Z7DESCP"):SetValue(Alltrim(SZ7DIA->B1_DESC))
		oSection1:Cell("Z7DESCP"):SetAlign("LEFT")

		oSection1:Cell("Z7DESCRIC"):SetValue(SZ7DIA->Z7_DESCRIC)
		oSection1:Cell("Z7DESCRIC"):SetAlign("LEFT")
		
		oSection1:Cell("Z7REQUISI"):SetValue(SZ7DIA->Z7_REQUI)
		oSection1:Cell("Z7REQUISI"):SetAlign("CENTER")
		

		oSection1:Cell("Z7QUANT"):SetValue(SZ7DIA->Z7_QUANT)
		oSection1:Cell("Z7QUANT"):SetAlign("CENTER")

		oSection1:Cell("Z7VUNIT"):SetValue(SZ7DIA->Z7_VUNIT)
		oSection1:Cell("Z7VUNIT"):SetAlign("CENTER")

		oSection1:Cell("Z7TOTAL"):SetValue(SZ7DIA->Z7_TOTAL)
		oSection1:Cell("Z7TOTAL"):SetAlign("RIGTH")

		oSection1:Cell("Z7MOTOR"):SetValue(SZ7DIA->DA4_NOME)
		oSection1:Cell("Z7MOTOR"):SetAlign("LEFT")

		oSection1:Cell("Z7VEICULO"):SetValue(SZ7DIA->Z7_VEICULO)
		oSection1:Cell("Z7VEICULO"):SetAlign("LEFT")

		oSection1:Cell("Z7STATUS"):SetValue(SZ7DIA->Z7_STATUS)
		oSection1:Cell("Z7STATUS"):SetAlign("CENTER")


		oSection1:PrintLine()
 
		dbSelectArea("SZ7DIA")
		SZ7DIA->(dbSkip())
				

	EndDo
	oSection1:Finish()
	SZ7DIA->(DbCloseArea())
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
	AADD(aRegs,{cPerg,"07","Status		  		  ?",Space(20),Space(20),"mv_ch7","N",01,0,2,"C","","mv_par07","1-Pendentes","","","","","2-Atendidos","","","","","3-Todos","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"08","Servico De            ?",Space(20),Space(20),"mv_ch8","C",15,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
	AADD(aRegs,{cPerg,"09","Servico Ate           ?",Space(20),Space(20),"mv_ch9","C",15,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
	AADD(aRegs,{cPerg,"10","Imprime Excel         ?",Space(20),Space(20),"mv_cha","N",01,0,2,"C","","mv_par10","1-Sim","","","","","2-Nao","","","","","","","","","","","","","","","","","","","","","","","",""})

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

	
			

                                                                                 
