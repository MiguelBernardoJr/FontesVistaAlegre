//**********************************************
// Relatório de Entrada de notas de Insumos em Excel
//**********************************************
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*               
___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VACOMR01   ¦ Autor ¦ Henrique Magalhaes  ¦ Data ¦ 06/07/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Relatório de Entrada de notas de Insumos em Excel 		  ¦¦¦
¦¦¦          ¦ (INSUMOS)     									  		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ especifico Vista Alegre                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
       


 
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

//Função Principal do relatório                             
User Function VACOMR01()
Private cPerg

	nOrdem   :=0
	tamanho  :="P"
	limite   :=80
	titulo   :=PADC("VACOMR01",74)
	cDesc1   :=PADC("Relatorio de NF de Insumos - Entrada",74)
	cDesc2   :=""
	cDesc3   :=""
	aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
	nomeprog :="VACOMR01"
	cPerg    :="VACOMR01"
	nLastKey := 0
	wnrel    := "VACOMR01"
	cQuery	 :=""

	ValidPerg(cPerg)
	
//	While Pergunte(cPerg, .T.)
//		MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
//	Enddo

	If Pergunte(cPerg, .T.)
		MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
	Endif

	
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
	AADD(aRegs,{cPerg,"03","Emissao de         	  ?",Space(20),Space(20),"mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Emissao até        	  ?",Space(20),Space(20),"mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Digitacao de          ?",Space(20),Space(20),"mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"06","Digitacao até         ?",Space(20),Space(20),"mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"07","Fornecedor De         ?",Space(20),Space(20),"mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	AADD(aRegs,{cPerg,"08","Fornecedor Ate        ?",Space(20),Space(20),"mv_ch8","C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	AADD(aRegs,{cPerg,"09","Loja De               ?",Space(20),Space(20),"mv_ch9","C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"10","Loja Ate              ?",Space(20),Space(20),"mv_cha","C",02,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})		
	AADD(aRegs,{cPerg,"11","Grupo (sep.p/ ';')    ?",Space(20),Space(20),"mv_chb","C",99,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"12","Produto De            ?",Space(20),Space(20),"mv_chc","C",15,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","SB1_X","","","","",""})
	AADD(aRegs,{cPerg,"13","Produto Até           ?",Space(20),Space(20),"mv_chd","C",15,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","SB1_X","","","","",""})

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


//relatorio de insumos via excel
// 1a. Versao
Static Function ImprRel(cPerg)           
Local aArea 	:= getArea()
Local cQuery	:= ''
Local cAba1 	:= "Notas Fiscais"
Local cTable1	:= "Relatorio de NF de Insumos - Entrada" 
Local nVlFrete	:= 0
// Tratamento para Excel
Private oExcel
Private oExcelApp
Private cArquivo  := GetTempPath()+'vajob05_'+StrTran(dToC(dDataBase), '/', '-')+'_'+StrTran(Time(), ':', '-')+'.xml'


/*
SELECT D1_FILIAL, D1_DTDIGIT, D1_EMISSAO, D1_X_KM, D1_PEDIDO,C7_NUM, D1_ITEMPC, D1_COD, B1_DESC, D1_DOC, D1_SERIE, D1_FORNECE, 
D1_LOJA, A2_NOME, D1_QUANT, D1_PESO, D1_TOTAL, D1_VALFRE, D1_VUNIT, D1_CUSTO, D1_X_PESCH, D1_X_PESO, D1_X_PESOB, 
D1_X_PESOL, D1_X_KGIMP, D1_X_KGUMI, D1_X_IMPUR, D1_X_UMIDA, C7_X_LIMIM, C7_X_LIMUM, C7_X_DESIM, C7_X_DESUM, C7_OBS   
FROM SD1010 SD1
LEFT JOIN SA2010 SA2 ON (A2_FILIAL='' AND A2_COD=D1_FORNECE AND A2_LOJA=D1_LOJA AND SA2.D_E_L_E_T_='')
LEFT JOIN SB1010 SB1 ON (B1_FILIAL='' AND B1_COD=D1_COD AND SB1.D_E_L_E_T_='')
LEFT JOIN SC7010 SC7 ON (C7_NUM=D1_PEDIDO AND C7_ITEM=D1_ITEMPC AND C7_PRODUTO=D1_COD AND C7_FORNECE=D1_FORNECE AND C7_LOJA=D1_LOJA AND SC7.D_E_L_E_T_='')
WHERE D1_GRUPO IN ('02')
AND SD1.D1_X_PESOB > 0
AND D1_EMISSAO BETWEEN '' AND 'ZZ'
AND D1_DTDIGIT BETWEEN '20160101' AND 'ZZ'
AND D1_COD     BETWEEN '' AND 'ZZ'
AND D1_FORNECE BETWEEN '' AND 'ZZ'
AND D1_LOJA	   BETWEEN '' AND 'ZZ'
AND SD1.D_E_L_E_T_ = ''
*/

/*  QUERY REVISADA POR ARTHUR TOSHIO - INCLUSÃO DA COLUNA SALDO_PAGAR VERIFICANDO NO TÍTULO (SE2)
SELECT D1_FILIAL, D1_DTDIGIT, D1_EMISSAO, D1_X_KM, D1_PEDIDO,C7_NUM, D1_ITEMPC, D1_COD, B1_DESC, D1_DOC, D1_SERIE, D1_FORNECE, 
D1_LOJA, A2_NOME, D1_QUANT, D1_PESO, D1_TOTAL, D1_VALFRE, D1_VUNIT, D1_CUSTO, D1_X_PESCH, D1_X_PESO, D1_X_PESOB, 
D1_X_PESOL, D1_X_KGIMP, D1_X_KGUMI, D1_X_IMPUR, D1_X_UMIDA, C7_X_LIMIM, C7_X_LIMUM, C7_X_DESIM, C7_X_DESUM, C7_OBS, F1_MENNOTA,  
CASE WHEN (SELECT E2_SALDO FROM SE2010 WHERE D_E_L_E_T_ = '' AND E2_FILIAL = D1_FILIAL AND E2_FORNECE = D1_FORNECE AND E2_NUM = D1_DOC) = 0 THEN '0' 
	 -- QUANDO SALDO IGUAL AO TITULO = TÍTULO
	 WHEN D1_TOTAL = (SELECT E2_SALDO FROM SE2010 WHERE D_E_L_E_T_ = '' AND E2_FILIAL = D1_FILIAL AND E2_FORNECE = D1_FORNECE AND E2_NUM = D1_DOC) THEN D1_TOTAL
     --CASE QUANDO SALDO MENOR QUE TOTAL = SALDO
     WHEN D1_TOTAL > (SELECT E2_SALDO FROM SE2010 WHERE D_E_L_E_T_ = '' AND E2_FILIAL = D1_FILIAL AND E2_FORNECE = D1_FORNECE AND E2_NUM = D1_DOC) THEN (SELECT E2_SALDO FROM SE2010 WHERE D_E_L_E_T_ = '' AND E2_FILIAL = D1_FILIAL AND E2_FORNECE = D1_FORNECE AND E2_NUM = D1_DOC) END AS SALDO_PAGAR
FROM SD1010 SD1
LEFT JOIN SA2010 SA2 ON (A2_FILIAL='' AND A2_COD=D1_FORNECE AND A2_LOJA=D1_LOJA AND SA2.D_E_L_E_T_='')
LEFT JOIN SB1010 SB1 ON (B1_FILIAL='' AND B1_COD=D1_COD AND SB1.D_E_L_E_T_='')
LEFT JOIN SC7010 SC7 ON (C7_NUM=D1_PEDIDO AND C7_ITEM=D1_ITEMPC AND C7_PRODUTO=D1_COD AND C7_FORNECE=D1_FORNECE AND C7_LOJA=D1_LOJA AND SC7.D_E_L_E_T_='')
LEFT JOIN SF1010 SF1 ON (F1_FILIAL = D1_FILIAL AND D1_DOC = F1_DOC AND F1_FORNECE = D1_FORNECE AND D1_EMISSAO = F1_EMISSAO AND SF1.D_E_L_E_T_='')
WHERE D1_GRUPO IN ('02')
AND SD1.D1_X_PESOB > 0
AND D1_EMISSAO BETWEEN '' AND 'ZZ'
AND D1_DTDIGIT BETWEEN '20160801' AND '20160930'
AND D1_COD     BETWEEN '' AND 'ZZ'
AND D1_FORNECE BETWEEN '' AND 'ZZ'
AND D1_LOJA	   BETWEEN '' AND 'ZZ'
AND SD1.D_E_L_E_T_ = ''

*/


cQuery := " SELECT D1_FILIAL, D1_DTDIGIT, D1_EMISSAO, D1_X_KM, D1_UM, D1_PEDIDO, D1_ITEMPC,C7_NUM,  D1_COD, B1_DESC, D1_DOC, D1_SERIE, D1_FORNECE,  " 
cQuery += " D1_LOJA, A2_NOME, D1_QUANT, D1_PESO, D1_TOTAL, D1_VALFRE, D1_VUNIT, D1_CUSTO, D1_X_PESCH, D1_X_PESO, D1_X_PESOB, "
cQuery += " D1_X_PESOL, D1_X_KGIMP, D1_X_KGUMI, D1_X_IMPUR, D1_X_UMIDA, C7_X_LIMIM, C7_X_LIMUM, C7_X_DESIM, C7_X_DESUM, F1_MENNOTA, "
cQuery += "CASE WHEN (SELECT SUM(E2_SALDO) FROM SE2010 WHERE D_E_L_E_T_ = '' AND E2_FILIAL = D1_FILIAL AND E2_FORNECE = D1_FORNECE AND E2_NUM = D1_DOC GROUP BY E2_FILIAL, E2_FORNECE, E2_NUM ) = 0 THEN '0' "
cQuery += "WHEN D1_TOTAL = (SELECT SUM(E2_SALDO) FROM SE2010 WHERE D_E_L_E_T_ = '' AND E2_FILIAL = D1_FILIAL AND E2_FORNECE = D1_FORNECE AND E2_NUM = D1_DOC GROUP BY E2_FILIAL, E2_FORNECE, E2_NUM ) THEN D1_TOTAL "
cQuery += "WHEN D1_TOTAL > (SELECT SUM(E2_SALDO) FROM SE2010 WHERE D_E_L_E_T_ = '' AND E2_FILIAL = D1_FILIAL AND E2_FORNECE = D1_FORNECE AND E2_NUM = D1_DOC GROUP BY E2_FILIAL, E2_FORNECE, E2_NUM) THEN "
cQuery += "(SELECT SUM(E2_SALDO) FROM SE2010 WHERE D_E_L_E_T_ = '' AND E2_FILIAL = D1_FILIAL AND E2_FORNECE = D1_FORNECE AND E2_NUM = D1_DOC GROUP BY E2_FILIAL, E2_FORNECE, E2_NUM) END AS SALDO_PAG "
cQuery += " FROM "+RetSqlName('SD1')+" SD1 "
cQuery += "  JOIN "+RetSqlName('SF1')+" SF1 ON (F1_FILIAL = D1_FILIAL AND D1_DOC = F1_DOC AND F1_FORNECE = D1_FORNECE AND D1_EMISSAO = F1_EMISSAO AND SF1.D_E_L_E_T_='') "
cQuery += "  JOIN "+RetSqlName('SA2')+" SA2 ON (A2_FILIAL='"+FWxFilial("SA2")+"' AND A2_COD=D1_FORNECE AND A2_LOJA=D1_LOJA AND SA2.D_E_L_E_T_<>'*') "
cQuery += "  JOIN "+RetSqlName('SB1')+" SB1 ON (B1_FILIAL='"+FWxFilial("SB1")+"' AND B1_COD=D1_COD AND SB1.D_E_L_E_T_<>'*') "
cQuery += "  JOIN "+RetSqlName('SF4')+" SF4 ON (F4_FILIAL='"+FWxFilial("SF4")+"' AND F4_CODIGO = D1_TES AND F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_<>'*') "
cQuery += " LEFT JOIN "+RetSqlName('SC7')+" SC7 ON (C7_NUM=D1_PEDIDO AND C7_ITEM=D1_ITEMPC AND C7_PRODUTO=D1_COD AND C7_FORNECE=D1_FORNECE AND C7_LOJA=D1_LOJA AND SC7.D_E_L_E_T_='') "
cQuery += " WHERE SD1.D_E_L_E_T_ <> '*' AND D1_GRUPO IN ('02') "  // grupo de insumos
cQuery += " AND D1_EMISSAO BETWEEN  '"+DtOS(MV_PAR03)+"' 	AND '"+DtOS(MV_PAR04)+"' " 
cQuery += " AND D1_DTDIGIT BETWEEN  '"+DtOS(MV_PAR05)+"' 	AND '"+DtOS(MV_PAR06)+"' " 
//cQuery += " AND D1_COD BETWEEN  '"++"' 	AND '"++"' " 
cQuery += " AND D1_FORNECE BETWEEN  '"+MV_PAR07+"' 	AND '"+MV_PAR08+"' " 
cQuery += " AND D1_LOJA BETWEEN  '"+MV_PAR09+"' 	AND '"+MV_PAR10+"' "
cQuery += " AND D1_COD BETWEEN  '"+MV_PAR12+"' 	AND '"+MV_PAR13+"' " 
cQuery += " AND SC7.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' "

cQuery += " ORDER BY D1_FILIAL, D1_EMISSAO, D1_DOC, D1_SERIE "


If Select("TSC7") <> 0
	TSC7->(dbCloseArea())
Endif

TCQuery cQuery Alias "TSC7" New


memowrite("C:\TOTVS\VAESTR04.txt", cQuery)

oExcel := FWMSExcel():New()
		
//Aba 01 - Relatorio 
oExcel:AddworkSheet(cAba1)
	//Criando a Tabela
	//FWMsExcelEx():AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)-> NIL
	oExcel:AddTable(cAba1,cTable1)
	oExcel:AddColumn(cAba1,cTable1,"Filial",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Data",				1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Motorista",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"KM",				3,2,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Requisicao",		1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"NF",				1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Peso VA",			3,2,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Peso NF",			3,2,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"R$ NF",				3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"R$/Ton",			3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"R$ Frete",			3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"R$ Ton/CIF",		3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"R$ Saco",			3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Produto",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Fornecedor",		1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Umid.%",			3,2,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Impu.%",	  		3,2,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Desc.Umid.",		3,2,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Desc.Impu.",		3,2,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"R$ Desconto",		3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Observacao",		1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Peso Liquido",		3,2,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"R$ Total",			3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"",					1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Lim.Umid.%",		3,2,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Lim.Impu.%",	  	3,2,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Data Emissao",		1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Data Digitacao",	1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Saldo a Pagar",     3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"",					1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	
	
//FWMsExcelEx():AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)-> NIL

	dbSelectArea("TSC7")
	dbGotop()
	cPedido := "ZYX999"
	While !(TSC7->(Eof()))
	   		// alimentar dados na planilha	

	   		nVlFrete := ComplNF(TSC7->D1_FILIAL, TSC7->D1_DOC, TSC7->D1_SERIE, TSC7->D1_FORNECE, TSC7->D1_LOJA, TSC7->D1_COD)	

	 		oExcel:AddRow(cAba1,cTable1,{	U_BuscaSM0(TSC7->D1_FILIAL),;		// Filial
	 										dToC(Stod(TSC7->D1_EMISSAO)),;		// Emissao
	 										"Motorista  " + TSC7->D1_UM,;						// Motorista
	 										TSC7->D1_X_KM,;						// KM
	 										TSC7->C7_NUM,;						// Requisicao/Pedido
	 										TSC7->D1_DOC + IIF(Empty(TSC7->D1_SERIE),'','-'+TSC7->D1_SERIE),;// NF
	 										TSC7->D1_QUANT,;					// Peso VA
	 										TSC7->D1_X_PESOB,;					// Peso NF
	 										TSC7->D1_TOTAL,;					// R$ NF
	 										IIF(TSC7->D1_UM=='KG',TSC7->D1_VUNIT * 1000, TSC7->D1_VUNIT),;				// R$ Ton
	 										nVlFrete,;							// R$ Frete
	 										IIF(TSC7->D1_UM=='KG',(TSC7->D1_TOTAL + nVlFrete)/TSC7->D1_QUANT*1000, (TSC7->D1_TOTAL + nVlFrete)/TSC7->D1_QUANT) ,;	// R$ Ton/CIF
	 										IIF(TSC7->D1_UM=='KG',TSC7->D1_VUNIT * 60, IIF(TSC7->D1_UM=='TL',TSC7->D1_VUNIT * 60/1000,TSC7->D1_VUNIT)) ,;				// R$ Saco
	 										alltrim(TSC7->B1_DESC),;			// Produto
	 										alltrim(TSC7->A2_NOME),;			// fORNECEDOR
	 										TSC7->D1_X_UMIDA,;					// % Umidade
	 										TSC7->D1_X_IMPUR,;					// % Impurezas
	 										TSC7->D1_X_KGUMI,;					// Desconto Umidade
	 										TSC7->D1_X_KGIMP,;					// Desconto Impurezas
	 										(TSC7->D1_X_KGUMI + TSC7->D1_X_KGIMP) * TSC7->D1_VUNIT,;	// Desconto R$
	 										alltrim(TSC7->F1_MENNOTA),;							// Observacoes
	 										TSC7->D1_X_PESOL,;					// Peso Liquido
	 										TSC7->D1_TOTAL,;					// R$ Total
	 										"",;								// coluna em branco
	 										TSC7->C7_X_LIMUM,;									// % Limite de Umidade
	 										TSC7->C7_X_LIMIM,;									// % Limite de Impurezas
	 										dToC(Stod(TSC7->D1_EMISSAO)),;		// Emissao
	 										dToC(Stod(TSC7->D1_DTDIGIT)),;		// Digitacao
	 										TSC7->SALDO_PAG,;					// Saldo a Pagar
											""} )			
	    	TSC7->(dbSkip())
	EndDo           

	oExcel:Activate()
	oExcel:GetXMLFile(cArquivo)
			
	//Abrindo o excel e abrindo o arquivo xml
	oExcelApp := MsExcel():New() 			//Abre uma nova conexão com Excel
	oExcelApp:WorkBooks:Open(cArquivo) 		//Abre uma planilha
	oExcelApp:SetVisible(.T.) 				//Visualiza a planilha
	oExcelApp:Destroy()						//Encerra o processo do gerenciador de tarefas

RestArea(aArea)
return   



Static Function ConvType(xValor,nTam,nDec)

Local cNovo := ""
DEFAULT nDec := 0
Do Case
	Case ValType(xValor)=="N"
		If xValor <> 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))	
		Else
			cNovo := "0"
		EndIf
	Case ValType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
	Case ValType(xValor)=="C"
		If nTam==Nil
			xValor := AllTrim(xValor)
		EndIf
		DEFAULT nTam := 60
		cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
EndCase
Return(cNovo)



Static Function ComplNF(cFilComp, cDocComp, cSerComp, cForCod, cForLoja, cProduto)
	Local cQuery := ""
	Local nRet   := 0
	Local cDocFre, cSerFre, cForFre, cLojFre := ''			
			
	/* Verifica se existe complemento de preço/frete */
	cQuery := " SELECT F8_NFDIFRE, F8_SEDIFRE, F8_TRANSP, F8_LOJTRAN FROM  " + RetSqlName("SF8")
	cQuery += "  WHERE D_E_L_E_T_ <> '*' AND F8_NFORIG = '" + cDocComp + "' AND F8_SERORIG = '" + cSerComp + "' AND F8_FILIAL = '" + cFilComp + "' "  
	cQuery += "  AND F8_FORNECE = '" + cForCod + "' AND F8_LOJA = '" + cForLoja + "'  "  
	
	
	If Select("_QRYSF8") > 0
		_QRYSF8->(DbCloseArea())
	Endif    
	TcQuery ChangeQuery(cQuery) New Alias "_QRYSF8"	
	cDocFre := _QRYSF8->F8_NFDIFRE
	cSerFre := _QRYSF8->F8_SEDIFRE
	cForFre := _QRYSF8->F8_TRANSP
	cLojFre := _QRYSF8->F8_LOJTRAN

	
	/* Se achar relação, buscar título e somar D1_CUSTO adicional */
	if !Empty(cDocFre)
		cQuery := " SELECT D1_CUSTO FROM " + RetSQLName("SD1")
		cQuery += " WHERE D_E_L_E_T_ <> '*' AND D1_TIPO = 'C' AND D1_DOC = '" + cDocFre + "' AND D1_SERIE = '" + cSerFre + "' AND D1_COD = '" + cProduto + "'"
		cQuery += "  AND D1_FORNECE = '" + cForFre + "' AND D1_LOJA = '" + cLojFre + "'  "
			
		If Select("_QRYCUS2") > 0
			_QRYCUS2->(DbCloseArea())
		Endif
		TcQuery ChangeQuery(cQuery) New Alias "_QRYCUS2"
	
		While !_QRYCUS2->(EOF())
			nRet  += _QRYCUS2->D1_CUSTO
			_QRYCUS2->(DbSkip())
		enddo
	endif	
Return nRet
