#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Arthru Toshio Oda VAnzella	                                          |
 | Data:  11.11.2017                                                              |
 | Desc:  Relatório de Movimentação de animais.	                                  |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/

user function VAEST022()

Private cPerg := nil

	//nOrdem   :=0
	//tamanho  :="P"
	//limite   :=80
	//titulo   :=PADC("VAEST022",74)
	//cDesc1   :=PADC("Relatório - Movimentação de Animais por período",74)
	//cDesc2   :=""
	//cDesc3   :=""
	//aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
	//nomeprog :="VAEST022"
	cPerg      :="VAEST022"
	//nLastKey := 0
	//wnrel    := "VAEST022"
	_cQry	 :=""

	ValidPerg(cPerg)
	
	While Pergunte(cPerg, .T.)
		MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
	Enddo

//	If Pergunte(cPerg, .T.)
		//MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
	//Endif
	
Return  

///**************************************************************************
///PERGUNTAS DO RELATÓ’IO
///**************************************************************************
Static Function ValidPerg(cPerg)
Local _sAlias,i,j

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}                                                  

	//AADD(aRegs,{cPerg,"01","Filial De             ?",Space(20),Space(20),"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AADD(aRegs,{cPerg,"02","Filial Ate            ?",Space(20),Space(20),"mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"01","Data de         	   ?",Space(20),Space(20),"mv_ch3","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Data até        	   ?",Space(20),Space(20),"mv_ch4","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","TM Nascimento          ?",Space(20),Space(20),"mv_ch5","C",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","TM Morte	           ?",Space(20),Space(20),"mv_ch6","C",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AADD(aRegs,{cPerg,"07","Fornecedor De         ?",Space(20),Space(20),"mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	//AADD(aRegs,{cPerg,"08","Fornecedor Ate        ?",Space(20),Space(20),"mv_ch8","C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	//AADD(aRegs,{cPerg,"09","Loja De               ?",Space(20),Space(20),"mv_ch9","C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AADD(aRegs,{cPerg,"10","Loja Ate              ?",Space(20),Space(20),"mv_cha","C",02,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})		
	//AADD(aRegs,{cPerg,"11","Grupo (sep.p/ ';')    ?",Space(20),Space(20),"mv_chb","C",99,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AADD(aRegs,{cPerg,"12","Produto De            ?",Space(20),Space(20),"mv_chc","C",15,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","SB1_X","","","","",""})
	//AADD(aRegs,{cPerg,"13","Produto Até           ?",Space(20),Space(20),"mv_chd","C",15,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","SB1_X","","","","",""})

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


Static Function ImprRel(cPerg)  
 
// Tratamento para Excel
Private oExcel := nil
Private oExcelApp
oExcel := FWMSExcel():New()
Private cArquivo  := GetTempPath()+'VAEST022_'+StrTran(dToC(dDataBase), '/', '-')+'_'+StrTran(Time(), ':', '-')+'.xml'
oExcel:SetFont('Arial Narrow')
oExcel:SetBgColorHeader("#37752F") // cor de fundo linha cabeç¡¬ho
oExcel:SetLineBgColor("#FFFFFF")   // cor da linha 1
oExcel:Set2LineBgColor("#FFFFFF")  // cor da linha 2

fQuadro1(cPerg)
fQuadro2(cPerg)
fQuadro3(cPerg)
fQuadro4(cPerg)
fQuadro5(cPerg)
fQuadro6(cPerg)
fQuadro7(cPerg)
fQuadro8(cPerg)
fQuadro9(cPerg)
fQuadro10(cPerg)
fQUadro11(cPerg) // RESUMO POR TIPO
fQuadro12(cPerg)
fQuadro13(cPerg)
fQuadro14(cPerg)
//fQuadro15(cPerg)

	oExcel:Activate()
	oExcel:GetXMLFile(cArquivo)
			
	//Abrindo o excel e abrindo o arquivo xml
	oExcelApp := MsExcel():New() 			//Abre uma nova conexã¯ com Excel
	oExcelApp:WorkBooks:Open(cArquivo) 		//Abre uma planilha
	oExcelApp:SetVisible(.T.) 				//Visualiza a planilha
	oExcelApp:Destroy()						//Encerra o processo do gerenciador de tarefas
	
Return 

Static Function fQuadro1(cPerg)

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "NF Transf Filiais"
Local cTitulo	 := "Relação das NFs"
cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)
oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry := "  		SELECT 'ENTRADA'					TIPO,  " + CRLF
	_cQry += "  			   D1.D1_GRUPO					GRUPO,   " + CRLF
	_cQry += "  			   BM.BM_DESC					DESCRICAO,   " + CRLF
	_cQry += "  			   D1.D1_FILIAL					FILIAL,  " + CRLF
	_cQry += "  			   D1.D1_FORNECE				CODIGO,  " + CRLF
	_cQry += "  			   D1.D1_LOJA					LOJA,  " + CRLF
	_cQry += "  			   A2.A2_NOME					RAZAO,  " + CRLF
	_cQry += "  			   D1.D1_DOC					NUMERO_NF,  " + CRLF
	_cQry += "  			   D1.D1_SERIE					SERIE,  " + CRLF
	_cQry += "  			   D1.D1_EMISSAO				DT_EMISSAO,  " + CRLF
	_cQry += "  			   D1.D1_DTDIGIT				DT_DIGITACAO,  " + CRLF
	_cQry += "  			   D1.D1_COD					PROD_CODI,  " + CRLF
	_cQry += "  			   B1.B1_DESC					PROD_DESCR,  " + CRLF
	_cQry += "				   D1.D1_LOTECTL				LOTE,  " + CRLF
	_cQry += "  			   B1.B1_UM						UM,  " + CRLF
	_cQry += "  			   D1.D1_QUANT					QUANT,  " + CRLF
	_cQry += "  			   D1.D1_LOCAL					ARMAZ,  " + CRLF
	_cQry += "  			   D1.D1_TOTAL/D1.D1_QUANT		VL_UNIT,  " + CRLF
	_cQry += "  			   D1.D1_TOTAL					TOTAL,  " + CRLF
	_cQry += "  			   D1.D1_CUSTO/D1.D1_QUANT		CUST_UNI,  " + CRLF
	_cQry += "  			   D1.D1_CUSTO					CUSTO
	_cQry += "     		  FROM "+RetSqlName("SD1")+"				D1   " + CRLF
	_cQry += "  	INNER JOIN "+RetSqlName("SF4")+"				F4  " + CRLF
	_cQry += "  			ON D1.D1_TES						=			F4.F4_CODIGO  " + CRLF
	_cQry += "  		   AND F4.D_E_L_E_T_					=			' '   " + CRLF
	_cQry += "  		   AND F4_TRANFIL						=			'1'  " + CRLF
	_cQry += "  	INNER JOIN "+RetSqlName("SBM")+"				BM  " + CRLF
	_cQry += "  			ON BM.BM_GRUPO						=			D1.D1_GRUPO  " + CRLF
	_cQry += "  		   AND BM.D_E_L_E_T_					=			' '	    " + CRLF
	_cQry += "  	INNER JOIN "+RetSqlName("SA2")+"				A2  " + CRLF
	_cQry += "  			ON A2.A2_COD						=			D1.D1_FORNECE  " + CRLF
	_cQry += "  		   AND A2.A2_LOJA						=			D1.D1_LOJA  " + CRLF
	_cQry += "  		   AND A2.D_E_L_E_T_					=			' '   " + CRLF
	_cQry += "  	INNER JOIN "+RetSqlName("SB1")+"				B1  " + CRLF
	_cQry += "  			ON B1.B1_COD						=			D1.D1_COD  " + CRLF
	_cQry += "  		   AND B1.D_E_L_E_T_					=			' '   " + CRLF
	_cQry += "  		 WHERE D1_DTDIGIT						BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'  " + CRLF
	//_cQry += "				 --D1_EMISSAO						BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'  " + CRLF
	_cQry += "  		   AND D1.D_E_L_E_T_					=			' '   " + CRLF
	_cQry += "  		   AND D1.D1_GRUPO						IN			('01','05','BOV')  " + CRLF
	_cQry += "  		   AND D1.D1_QUANT						>			0  " + CRLF	
	_cQry += "    " + CRLF
	_cQry += "  		UNION ALL  " + CRLF
	_cQry += "    " + CRLF
	_cQry += "  		SELECT 'SAÍ„A'						SAIDA,  " + CRLF
	_cQry += "  			   D2.D2_GRUPO					GRUPO,   " + CRLF
	_cQry += "  			   BM.BM_DESC					DESCRICAO,   " + CRLF
	_cQry += "  			   D2.D2_FILIAL					FILIAL,  " + CRLF
	_cQry += "  			   D2.D2_CLIENTE				CODIGO,  " + CRLF
	_cQry += "  			   D2.D2_LOJA					LOJA,  " + CRLF
	_cQry += "  			   A1.A1_NOME					RAZAO,  " + CRLF
	_cQry += "  			   D2.D2_DOC					NUMERO_NF,  " + CRLF
	_cQry += "  			   D2.D2_SERIE					SERIE,  " + CRLF
	_cQry += "  			   D2.D2_EMISSAO				DT_EMISSAO,  " + CRLF
	_cQry += "  			   ''							DT_DIGITACAO,  " + CRLF
	_cQry += "  			   D2.D2_COD					PROD_CODI,  " + CRLF
	_cQry += "  			   B1.B1_DESC					PROD_DESCR,  " + CRLF
	_cQry += "				   D2.D2_LOTECTL				LOTE,  " + CRLF
	_cQry += "  			   B1.B1_UM						UM,  " + CRLF
	_cQry += "  			   D2.D2_QUANT					QUANT,  " + CRLF
	_cQry += "  			   D2.D2_LOCAL					ARMAZ,  " + CRLF
	_cQry += "  			   D2.D2_TOTAL/D2.D2_QUANT		VL_UNIT,  " + CRLF
	_cQry += "  			   D2.D2_TOTAL					TOTAL,  " + CRLF
	_cQry += "  			   D2.D2_CUSTO1/D2.D2_QUANT		CUST_UNI,  " + CRLF
	_cQry += "  			   D2.D2_CUSTO1					CUSTO
	_cQry += "     		  FROM "+RetSqlName("SD2")+"		D2  " + CRLF
	_cQry += "  	INNER JOIN "+RetSqlName("SF4")+"		F4  " + CRLF
	_cQry += "  			ON D2.D2_TES						=			F4.F4_CODIGO  " + CRLF
	_cQry += "  		   AND F4.D_E_L_E_T_					=			' '   " + CRLF
	_cQry += "  		   AND F4_TRANFIL						=			'1'  " + CRLF
	_cQry += "  	INNER JOIN "+RetSqlName("SBM")+"		BM  " + CRLF
	_cQry += "  			ON BM.BM_GRUPO						=			D2.D2_GRUPO  " + CRLF
	_cQry += "  		   AND BM.D_E_L_E_T_					=			' '	    " + CRLF
	_cQry += "  	INNER JOIN "+RetSqlName("SA1")+"		A1  " + CRLF
	_cQry += "  			ON A1.A1_COD						=			D2.D2_CLIENTE  " + CRLF
	_cQry += "  		   AND A1.A1_LOJA						=			D2.D2_LOJA  " + CRLF
	_cQry += "  		   AND A1.D_E_L_E_T_					=			' '   " + CRLF
	_cQry += "  	INNER JOIN "+RetSqlName("SB1")+"		B1  " + CRLF
	_cQry += "  			ON B1.B1_COD						=			D2.D2_COD  " + CRLF
	_cQry += "  		   AND B1.D_E_L_E_T_					=			' '   " + CRLF
	_cQry += "  		 WHERE D2_EMISSAO						BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'  " + CRLF
	_cQry += "  		   AND D2.D_E_L_E_T_					=			' '   " + CRLF
	_cQry += "  		   AND D2.D2_GRUPO						IN			('01','05','BOV')  " + CRLF
	_cQry += "  		   AND D2.D2_QUANT						>			0	  " + CRLF
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro_Transferencia_Filiais.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "DT_EMISSAO", "D")
	TcSetField(cAlias, "DT_DIGITACAO", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Tipo"		      		 , 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Grupo"		     		 , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		     	 , 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"		     	 , 2, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cod Forn"		     	 , 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Loja"		     		 , 1, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Razao Social"		     , 1, 1 )
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Numero NF"		     	 , 1, 1 )
	/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Serie"		     		 , 2, 1 )
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dt Emissao"		     , 1, 1 )
	/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dt Digitacao"		     , 1, 1 )
	/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cod Produto"		     , 2, 1 )
	/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		     	 , 1, 1 )
	/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "N Lote"		     	 , 1, 1 )
	/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "UM"		     		 , 2, 1 )
	/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quantidade"		     , 1, 2,.T.)
	/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Armazem"	     		 , 2, 1 )
	/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valr Unit."		     , 1, 3,)
	/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Total"		     		 , 1, 3,.T.)
	/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo Unit."		     , 1, 3,)
	/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo Total"		     , 1, 3,.T.)
	
	dbGotop()
	
	While !(cAlias)->(Eof())
	                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->TIPO, ;
							  (cAlias)->GRUPO, ;
							  (cAlias)->DESCRICAO, ;
							  (cAlias)->FILIAL, ;
							  (cAlias)->CODIGO, ;
							  (cAlias)->LOJA, ;
							  (cAlias)->RAZAO, ;
							  (cAlias)->NUMERO_NF, ;
							  (cAlias)->SERIE, ;
							  (cAlias)->DT_EMISSAO, ;
							  (cAlias)->DT_DIGITACAO, ;
							  (cAlias)->PROD_CODI	, ;
							  (cAlias)->PROD_DESCR, ;
							  (cAlias)->LOTE,;
							  (cAlias)->UM, ;
							  (cAlias)->QUANT,;
							  (cAlias)->ARMAZ, ;
							  (cAlias)->VL_UNIT, ;
							  (cAlias)->TOTAL, ;
							  (cAlias)->CUST_UNI, ;
							  (cAlias)->CUSTO })
							  
		
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
	
Return

// Transferencias	
Static Function fQuadro2(cPerg)

Local aArea 	 := getArea()
Local _cQry1		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Transf. Interna"
Local cTitulo	 := "Transferencia de Animais no estoque"
cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry1 := " 		SELECT D3.D3_FILIAL, " + CRLF
	_cQry1 += " 		 	   D3.D3_TM, " + CRLF
	_cQry1 += " 			   CASE WHEN D3.D3_TM = '499' THEN 'DESTINO' " + CRLF
	_cQry1 += " 					WHEN D3.D3_TM = '999' THEN 'ORIGEM' " + CRLF
	_cQry1 += " 					END AS TIPO, " + CRLF
	_cQry1 += " 			   D3.D3_EMISSAO, " + CRLF
	_cQry1 += " 			   D3.D3_COD, " + CRLF
	_cQry1 += " 			   B1.B1_DESC, " + CRLF
	_cQry1 += " 			   D3.D3_LOTECTL, " + CRLF
	//_cQry1 += " 			   B1.B1_X_CURRA, " + CRLF
	_cQry1 += " 			   D3.D3_QUANT, " + CRLF
	_cQry1 += " 			   D3.D3_LOCAL, " + CRLF
	_cQry1 += " 			   D3.D3_USUARIO, " + CRLF
	_cQry1 += " 			   D3.D3_OBS, " + CRLF
	_cQry1 += " 			   D3.D3_OBSERVA, " + CRLF
	_cQry1 += " 			   D3.D3_NUMSEQ, " + CRLF
	_cQry1 += "			       D3.R_E_C_N_O_ CLASSIF " + CRLF
	_cQry1 += " 		  FROM "+RetSqlName("SD3")+"		D3 " + CRLF
	_cQry1 += " 	INNER JOIN "+RetSqlName("SB1")+"		B1 " + CRLF
	_cQry1 += " 			ON B1.B1_COD						=			D3.D3_COD " + CRLF
	_cQry1 += " 		   AND B1.D_E_L_E_T_					=			' ' " + CRLF
	_cQry1 += " 		 WHERE D3.D3_EMISSAO						BETWEEN		'"+dToS(MV_PAR01)+"'		AND		'"+dToS(MV_PAR02)+"' " + CRLF
	_cQry1 += " 		   AND D3.D3_TM							IN			('499','999') " + CRLF
	_cQry1 += " 		   AND D3.D3_CF							IN			('DE4','RE4') " + CRLF
	_cQry1 += " 		   AND D3.D3_GRUPO						IN			('01','05','BOV') " + CRLF
	_cQry1 += " 		   AND D3.D_E_L_E_T_					=			' ' " + CRLF
	_cQry1 += " 		   AND D3.D3_ESTORNO						<>			'S' " + CRLF
	_cQry1 += " 	  ORDER BY D3.D3_EMISSAO, D3.D3_FILIAL, D3.D3_NUMSEQ, D3.D3_CHAVE   " + CRLF
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"QuadroTransferenciaEstoque.sql" , _cQry1)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry1 ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "D3_EMISSAO", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"		     , 2, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Tipo Mov."		     , 2, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Tipo"		     	 , 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dt Movimento"		 , 1, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Codigo"		     , 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		     , 1, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"		     	 , 2, 1 )
	///* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Curral"		     , 2, 1 )
	/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quantidade"		 , 1, 2 )
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Armazem"		     , 2, 1 )
	/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Usuario"		     , 1, 1 )

	
	dbGotop()
	
	While !(cAlias)->(Eof())
	                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->D3_FILIAL, ;
							  (cAlias)->D3_TM, ;
							  (cAlias)->TIPO, ;
							  (cAlias)->D3_EMISSAO, ;
							  (cAlias)->D3_COD, ;
							  (cAlias)->B1_DESC, ;
							  (cAlias)->D3_LOTECTL, ;
							  (cAlias)->D3_QUANT, ;
							  (cAlias)->D3_LOCAL, ;
							  (cAlias)->D3_USUARIO })
		
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)

Return

// Nascimentos e Mortes
Static Function fQuadro3(cPerg)

Local aArea 	 := getArea()
Local _cQry1		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Mortes"
Local cTitulo	 := "Relação das Mortes"

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry1 := " 		SELECT D3.D3_FILIAL, " + CRLF
	_cQry1 += " 			   D3.D3_EMISSAO, " + CRLF
	_cQry1 += " 		 	   D3.D3_TM, " + CRLF
	_cQry1 += " 		 	   F5.F5_TEXTO, " + CRLF
	_cQry1 += " 		 	   D3.D3_X_OBS, " + CRLF
	_cQry1 += " 			   D3.D3_COD, " + CRLF
	_cQry1 += " 			   B1.B1_DESC, " + CRLF
	_cQry1 += " 			   D3.D3_LOTECTL, " + CRLF
	//_cQry1 += " 			   B1.B1_X_CURRA, " + CRLF
	_cQry1 += " 			   D3.D3_QUANT, " + CRLF
	_cQry1 += " 			   D3.D3_LOCAL, " + CRLF
	_cQry1 += " 			   D3.D3_USUARIO, " + CRLF
	_cQry1 += " 			   D3.D3_OBS, " + CRLF
	_cQry1 += " 			   D3.D3_OBSERVA, " + CRLF
	_cQry1 += " 			   D3.D3_NUMSEQ, " + CRLF
	_cQry1 += " 			   D3.D3_CUSTO1, " + CRLF
	_cQry1 += "			       D3.R_E_C_N_O_ CLASSIF " + CRLF
	_cQry1 += " 		  FROM "+RetSqlName("SD3")+"	D3 " + CRLF
	_cQry1 += "		INNER JOIN "+RetSqlName("SF5")+"	F5
	_cQry1 += "     	 	ON F5.F5_CODIGO						=			D3.D3_TM
	_cQry1 += "     	   AND F5.D_E_L_E_T_					=			' '
	_cQry1 += " 	INNER JOIN "+RetSqlName("SB1")+"	B1 " + CRLF
	_cQry1 += " 			ON B1.B1_COD						=			D3.D3_COD " + CRLF
	_cQry1 += " 		   AND B1.D_E_L_E_T_					=			' ' " + CRLF
	_cQry1 += " 		 WHERE D3.D3_EMISSAO					BETWEEN		'"+dToS(MV_PAR01)+"'		AND		'"+dToS(MV_PAR02)+"' " + CRLF
	_cQry1 += " 		   AND D3.D3_TM							IN			('"+MV_PAR04+"') " + CRLF
	_cQry1 += " 		   AND D3.D3_GRUPO						IN			('01','05','BOV') " + CRLF
	_cQry1 += " 		   AND D3.D_E_L_E_T_					=			' ' " + CRLF
	_cQry1 += " 		   AND D3.D3_ESTORNO						<>			'S' " + CRLF
	_cQry1 += " 	  ORDER BY D3.D3_EMISSAO, D3.D3_FILIAL, D3.D3_NUMSEQ, D3.D3_CHAVE   " + CRLF
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"QuadroMortes.sql" , _cQry1)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry1 ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "D3_EMISSAO", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"		      		 , 2, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data"		     	         , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Tipo Mov."		      		 , 2, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Motivo"		      		 , 1, 1 )
	///* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Tipo"		     		     , 1, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observacao"		     	 , 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Codigo"		     	     , 1, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		     	     , 1, 1 )
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"		     		     , 2, 1 )
	///* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Curral"		    		 , 2, 1 )
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quantidade"		     	 , 2, 2 )
	/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo"				     	 , 2, 2 )
	/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Armazem"		     		 , 2, 1 )
	/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Usuario"		     		 , 1, 1 )

	
	dbGotop()
	
	While !(cAlias)->(Eof())
	                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->D3_FILIAL, ;
							  (cAlias)->D3_EMISSAO, ;
							  (cAlias)->D3_TM, ;
							  (cAlias)->F5_TEXTO, ;
							  (cAlias)->D3_X_OBS, ;
							  (cAlias)->D3_COD, ;
							  (cAlias)->B1_DESC, ;
							  (cAlias)->D3_LOTECTL, ;
							  (cAlias)->D3_QUANT, ;
							  (cAlias)->D3_CUSTO1, ;
							  (cAlias)->D3_LOCAL, ;
							  (cAlias)->D3_USUARIO })
		
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)

Return

Static Function fQuadro4(cPerg)

Local aArea 	 := getArea()
Local _cQry1		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Nascimentos"
Local cTitulo	 := "Relação dos Nascimentos"

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry1 := " 		SELECT D3.D3_FILIAL, " + CRLF
	_cQry1 += " 			   D3.D3_EMISSAO, " + CRLF
	_cQry1 += " 		 	   D3.D3_TM, " + CRLF
	_cQry1 += " 		 	   F5.F5_TEXTO, " + CRLF
	_cQry1 += " 		 	   D3.D3_X_OBS, " + CRLF
	_cQry1 += " 			   D3.D3_COD, " + CRLF
	_cQry1 += " 			   B1.B1_DESC, " + CRLF
	_cQry1 += " 			   D3.D3_LOTECTL, " + CRLF
	//_cQry1 += " 			   B1.B1_X_CURRA, " + CRLF
	_cQry1 += " 			   D3.D3_QUANT, " + CRLF
	_cQry1 += " 			   D3.D3_LOCAL, " + CRLF
	_cQry1 += " 			   D3.D3_USUARIO, " + CRLF
	_cQry1 += " 			   D3.D3_OBS, " + CRLF
	_cQry1 += " 			   D3.D3_OBSERVA, " + CRLF
	_cQry1 += " 			   D3.D3_NUMSEQ, " + CRLF
	_cQry1 += " 			   D3.D3_CUSTO1, " + CRLF
	_cQry1 += "			       D3.R_E_C_N_O_ CLASSIF " + CRLF
	_cQry1 += " 		  FROM "+RetSqlName("SD3")+"	D3 " + CRLF
	_cQry1 += "		INNER JOIN "+RetSqlName("SF5")+"	F5
	_cQry1 += "     	 	ON F5.F5_CODIGO						=			D3.D3_TM
	_cQry1 += "     	   AND F5.D_E_L_E_T_					=			' '
	_cQry1 += " 	INNER JOIN "+RetSqlName("SB1")+"	B1 " + CRLF
	_cQry1 += " 			ON B1.B1_COD						=			D3.D3_COD " + CRLF
	_cQry1 += " 		   AND B1.D_E_L_E_T_					=			' ' " + CRLF
	_cQry1 += " 		 WHERE D3.D3_EMISSAO					BETWEEN		'"+dToS(MV_PAR01)+"'		AND		'"+dToS(MV_PAR02)+"' " + CRLF
	_cQry1 += " 		   AND D3.D3_TM							IN			('"+MV_PAR03+"') " + CRLF
	_cQry1 += " 		   AND D3.D3_GRUPO						IN			('01','05','BOV') " + CRLF
	_cQry1 += " 		   AND D3.D_E_L_E_T_					=			' ' " + CRLF
	_cQry1 += " 		   AND D3.D3_ESTORNO						<>			'S' " + CRLF
	_cQry1 += " 	  ORDER BY D3.D3_EMISSAO, D3.D3_FILIAL, D3.D3_NUMSEQ, D3.D3_CHAVE   " + CRLF
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"QuadroNascimentos.sql" , _cQry1)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry1 ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "D3_EMISSAO", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"		      		 , 2, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data"		     	         , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Tipo Mov."		      		 , 2, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Motivo"		      		 , 1, 1 )
	///* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Tipo"		     		     , 1, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observacao"		     	 , 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Codigo"		     	     , 1, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		     	     , 1, 1 )
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"		     		     , 2, 1 )
	///* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Curral"		    		 , 2, 1 )
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quantidade"		     	 , 2, 2 )
	/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo"				     	 , 2, 2 )
	/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Armazem"		     		 , 2, 1 )
	/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Usuario"		     		 , 1, 1 )

	
	dbGotop()
	
	While !(cAlias)->(Eof())
	                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->D3_FILIAL, ;
							  (cAlias)->D3_EMISSAO, ;
							  (cAlias)->D3_TM, ;
							  (cAlias)->F5_TEXTO, ;
							  (cAlias)->D3_X_OBS, ;
							  (cAlias)->D3_COD, ;
							  (cAlias)->B1_DESC, ;
							  (cAlias)->D3_LOTECTL, ;
							  (cAlias)->D3_QUANT, ;
							  (cAlias)->D3_CUSTO1, ;
							  (cAlias)->D3_LOCAL, ;
							  (cAlias)->D3_USUARIO })
		
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)

Return


// Faturamento que movimenta estoque
Static Function fQuadro5(cPerg)

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Compras - Relação NFs"
Local cTitulo	 := "Relação das Compras - NFs"

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry := "     SELECT DISTINCT D1.D1_FILIAL					FILIAL, " +CRLF
	_cQry += "  				   D1.D1_DOC					NOTA_FIS, " +CRLF
	_cQry += "  				   D1.D1_SERIE					SERIE, " +CRLF
	_cQry += "  				   D1.D1_EMISSAO				EMISSAO, " +CRLF
	_cQry += "  				   D1.D1_DTDIGIT				DTDIGIT, " +CRLF
	_cQry += "  				   D1.D1_TIPO					TIPO, " +CRLF
	_cQry += "  				   D1.D1_FORNECE				COD_FORNECEDOR, " +CRLF
	_cQry += "  				   A2.A2_NOME					FORNECEDOR, " +CRLF
	_cQry += "  				   A2.A2_MUN					MUNICIPIO, " +CRLF
	_cQry += "  				   A2.A2_EST					ESTADO, " +CRLF
	_cQry += "  				   D1.D1_ITEM					ITEM, " +CRLF
	_cQry += "  				   D1.D1_COD					CODIGO,  " +CRLF
	_cQry += "  				   B1.B1_DESC					DESCRICAO, " +CRLF
	_cQry += "  				   B1.B1_UM						UM, " +CRLF
	_cQry += "  				   D1.D1_QUANT					QUANTIDADE, " +CRLF
	_cQry += "  				   D1.D1_TOTAL/D1.D1_QUANT		VL_UNIT, " +CRLF
	_cQry += "  				   D1.D1_TOTAL					VALOR_TOTAL, " +CRLF
	_cQry += "  				   D1.D1_BASEICM				BASE_ICMS, " +CRLF
	_cQry += "  				   D1.D1_PICM					PERC_ICMS, " +CRLF
	_cQry += "  				   D1.D1_VALICM					VALOR_ICMS, " +CRLF
	_cQry += "					   ZBC.ZBC_ICFRVL				ICMS_FRETE, " +CRLF
	_cQry += "					   ZCC.ZCC_NOMCOR				CORRETOR, " +CRLF
	_cQry += "					   ZBC.ZBC_VLRCOM				VALOR_COMI, " +CRLF
	_cQry += "  				   D1.D1_CUSTO					CUSTO, " +CRLF
	_cQry += "  				   D1.D1_BASEFUN				BASE_FUNRURAL, " +CRLF 
	_cQry += "  				   D1.D1_ALIQFUN				ALIQ_FUNRURAL, " +CRLF
	_cQry += "  				   D1.D1_VALFUN					VAL_FUNRURAL, " +CRLF
	_cQry += "  				   D1.D1_TES					TES, " +CRLF
	_cQry += "  				   F4.F4_TEXTO					DESCRI_TES, " +CRLF
	_cQry += "  				   D1.D1_X_EMBDT				DATA_EMBAR, " +CRLF
	_cQry += "  				   D1.D1_X_EMBHR				HR_EMBAR, " +CRLF
	_cQry += "  				   D1.D1_X_CHEDT				DATA_CHEGA, " +CRLF
	_cQry += "  				   D1.D1_X_CHEHR				HR_CHEGA, " +CRLF
	_cQry += "  				   D1.D1_X_PESCH				PESO_CHEGADA, " +CRLF
	_cQry += "  				   D1.D1_X_QUEKG				QUEBRA, " +CRLF
	_cQry += "  				   D1.D1_X_QUECA				QUEBRA_ANIMAL, " +CRLF
	_cQry += "  				   D1.D1_X_KM					DISTANCIA, " +CRLF
	_cQry += "                     sum(D1F.D1_TOTAL)     			FR_TOTAL, " +CRLF
	_cQry += "                     sum(D1F.D1_VALICM)   	    		FR_ICMS " +CRLF
	_cQry += "    		      FROM "+RetSqlName("SD1")+"						D1 " +CRLF
	_cQry += "  		INNER JOIN "+RetSqlName("SA2")+"		A2 " +CRLF
	_cQry += "  				ON A2.A2_COD					=			D1.D1_FORNECE " +CRLF
	_cQry += "  			   AND A2.A2_LOJA					=			D1.D1_LOJA " +CRLF
	_cQry += "  			   AND A2.D_E_L_E_T_				=			' '  " +CRLF
	_cQry += "  		INNER JOIN "+RetSqlName("SB1")+"		B1 " +CRLF
	_cQry += "  				ON B1.B1_COD					=			D1.D1_COD " +CRLF 
	_cQry += "  			   AND B1.D_E_L_E_T_				=			' '  " +CRLF
	_cQry += "  		INNER JOIN "+RetSqlName("SF4")+"		F4 " +CRLF 
	_cQry += "  				ON F4.F4_CODIGO					=			D1.D1_TES " +CRLF
	_cQry += "  			   AND F4.F4_TRANFIL				<>			'1' " +CRLF
	_cQry += "  			   AND F4.D_E_L_E_T_				=			' ' " +CRLF
	_cQry += "		    LEFT JOIN "+RetSqlName("ZBC")+" ZBC ON
	_cQry += "					   ZBC.ZBC_PRODUT				=			D1.D1_COD " +CRLF
	_cQry += "				   AND ZBC_FILIAL					=			D1.D1_FILIAL " +CRLF
	_cQry += "				   AND ZBC_PEDIDO					=			D1.D1_PEDIDO " +CRLF
	_cQry += "				   AND ZBC.D_E_L_E_T_				=			' ' " +CRLF
	_cQry += "			LEFT JOIN "+RetSqlName("ZCC")+" ZCC ON				" +CRLF
	_cQry += "					   ZCC.ZCC_FILIAL				=			ZBC_FILIAL " +CRLF
	_cQry += "				   AND ZCC_CODIGO					=			ZBC_CODIGO " +CRLF
	_cQry += "				   AND ZCC_VERSAO					=			ZBC_VERSAO " +CRLF
	_cQry += "				   AND ZCC_CODFOR					=			ZBC_CODFOR " +CRLF
	_cQry += "				   AND ZCC_LOJFOR					=			ZBC_LOJFOR " +CRLF
	_cQry += "				   AND ZCC.D_E_L_E_T_				=			' '  " +CRLF
	_cQry += "      LEFT JOIN "+RetSqlName("SF8")+" F8	 " +CRLF
	_cQry += "           	    ON F8_FILIAL					=			D1_FILIAL " +CRLF
	_cQry += "           	   AND F8_FORNECE					=			D1_FORNECE " +CRLF
	_cQry += "           	   AND F8_LOJA						=			D1_LOJA " +CRLF
	_cQry += "           	   AND F8_NFORIG					=			D1_DOC " +CRLF
	_cQry += "           	   AND F8_SERORIG					=			D1_SERIE " +CRLF
	_cQry += "           	   AND F8.D_E_L_E_T_				=			' ' " +CRLF 
	_cQry += "      LEFT JOIN "+RetSqlName("SD1")+" D1F " +CRLF
	_cQry += "                  ON D1F.D1_FORNECE				=			F8_TRANSP " +CRLF
	_cQry += "     	           AND D1F.D1_LOJA					=			F8_LOJTRAN " +CRLF
	_cQry += "     	           AND D1F.D1_DOC					=			F8_NFDIFRE " +CRLF
	_cQry += "     	           AND D1F.D1_SERIE					=			F8.F8_SEDIFRE " +CRLF
	_cQry += "     	           AND D1F.D1_COD					=			D1.D1_COD " +CRLF
	_cQry += "  			 WHERE D1.D1_GRUPO					IN			('01','05','BOV') " +CRLF
	_cQry += "  			   AND D1.D1_DTDIGIT				BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "  			   AND D1.D_E_L_E_T_				=			' ' " +CRLF
	_cQry += "  			   AND D1.D1_TIPO					=			'N' " +CRLF
    _cQry += "        group by D1.D1_FILIAL, D1.D1_DOC, D1.D1_SERIE, D1.D1_EMISSAO, D1.D1_DTDIGIT, D1.D1_TIPO, D1.D1_FORNECE, A2.A2_NOME, A2.A2_MUN, A2.A2_EST, D1.D1_ITEM	" +CRLF
    _cQry += "				   , D1.D1_COD, B1.B1_DESC, B1.B1_UM, D1.D1_QUANT, D1.D1_TOTAL, D1.D1_QUANT, D1.D1_TOTAL, D1.D1_BASEICM, D1.D1_PICM, D1.D1_VALICM, ZBC.ZBC_ICFRVL" +CRLF
    _cQry += "				   , ZCC.ZCC_NOMCOR, ZBC.ZBC_VLRCOM, D1.D1_CUSTO, D1.D1_BASEFUN, D1.D1_ALIQFUN, D1.D1_VALFUN, D1.D1_TES, F4.F4_TEXTO, D1.D1_X_EMBDT, D1.D1_X_EMBHR" +CRLF
    _cQry += "				   , D1.D1_X_CHEDT, D1.D1_X_CHEHR, D1.D1_X_PESCH, D1.D1_X_QUEKG, D1.D1_X_QUECA, D1.D1_X_KM				
	_cQry += "  		  ORDER BY D1.D1_EMISSAO, D1.D1_FILIAL, D1.D1_DOC, D1.D1_ITEM " +CRLF	
	
	/*
	_cQry += "            GROUP BY D1.D1_FILIAL, D1.D1_DOC, D1.D1_SERIE, D1.D1_EMISSAO, D1.D1_TIPO, D1.D1_FORNECE, A2.A2_NOME, A2.A2_MUN, A2.A2_EST, D1.D1_ITEM, D1.D1_COD, B1.B1_DESC, B1.B1_UM, D1.D1_QUANT " +CRLF
	_cQry += "           	  , D1.D1_TOTAL/D1.D1_QUANT, D1.D1_TOTAL, D1.D1_BASEICM, D1.D1_PICM, D1.D1_VALICM, ZBC.ZBC_ICFRVL, ZCC.ZCC_NOMCOR, ZBC.ZBC_VLRCOM, D1.D1_CUSTO, D1.D1_BASEFUN, D1.D1_ALIQFUN, D1.D1_VALFUN " +CRLF
	_cQry += "           	  , D1.D1_TES, F4.F4_TEXTO, D1.D1_X_EMBDT, D1.D1_X_EMBHR,D1.D1_X_CHEDT, D1.D1_X_CHEHR, D1.D1_X_PESCH, D1.D1_X_QUEKG, D1.D1_X_QUECA, D1.D1_X_KM, D1_DTDIGIT " +CRLF
	
	*/
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"QuadroCompras.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "EMISSAO", "D")
	TcSetField(cAlias, "DTDIGIT", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"  		 	    , 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "NF"		      	    , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Serie"	    	 	    , 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Emissao"   	 	    , 1, 4 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Digitaç£¯"   	 	    , 1, 4 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Tipo"	    	        , 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cod. Forn."   		    , 1, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Razao"    	   		    , 1, 1 )
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Municipio"		        , 1, 1 )
	/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Est." 		            , 1, 1 )
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Item"	    		    , 1, 1 )
	/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cod."		     	    , 1, 1 )
	/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		        , 1, 1 )
	/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "UM"	     		    , 1, 1 )
	/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "QTD"	   		        , 1, 2, .T. )
	/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Unit."	        , 1, 3, .T. )
	/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Total"	    	        , 1, 3, .T. )
	/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Base ICMS"		        , 1, 1, .T. )
	/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "% ICMS"		        , 1, 2 )
	/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor ICMS"	        , 1, 3, .T.)
	/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "ICMS Frete (Contrato)"	, 1, 3, .T.)
	/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Corretor"	        	, 1, 1 )
	/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Comissao"	    , 1, 3, .T.)
	/* 20 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo"	    	        , 1, 3, .T. )
	/* 21 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Base Funrural"	        , 1, 3 )
	/* 22 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Aliq Funrural"	        , 1, 2 )
	/* 23 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Funrural"	    , 1, 3, .T. )
	/* 24 */ oExcel:AddColumn( cWorkSheet, cTitulo, "TES"	  		        , 1, 1 )
	/* 25 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Desc. TES"	 	        , 1, 1 )
	/* 26 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dt Embar."		        , 1, 1 )
	/* 27 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Hr Embar."	            , 1, 1 )
	/* 28 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dt Chega."	            , 1, 1 )
	/* 29 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Hr Chega"	            , 1, 1 )
	/* 30 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Chega"	        , 1, 2, .T. )
	/* 31 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quebra"	            , 1, 2 )
	/* 32 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quebra Animal"         , 1, 2 )
	/* 33 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Distancia"		        , 1, 2 )
	/* 33 */ oExcel:AddColumn( cWorkSheet, cTitulo, "R$ Frete"		        , 1, 3 )
	/* 33 */ oExcel:AddColumn( cWorkSheet, cTitulo, "R$ ICMS Frete"	        , 1, 3 )
	
	
	///* 34 */ oExcel:AddColumn( cWorkSheet, cTitulo, ""	    		     , 1, 1 )
	
	dbGotop()
	
	While !(cAlias)->(Eof())                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->FILIAL, ;
							  (cAlias)->NOTA_FIS, ;
							  (cAlias)->SERIE, ;
							  (cAlias)->EMISSAO, ;
							  (cAlias)->DTDIGIT, ;
							  (cAlias)->TIPO, ;
							  (cAlias)->COD_FORNECEDOR, ;
							  (cAlias)->FORNECEDOR, ;
							  (cAlias)->MUNICIPIO, ;
							  (cAlias)->ESTADO, ;
							  (cAlias)->ITEM, ;
							  (cAlias)->CODIGO, ; 
							  (cAlias)->DESCRICAO, ;
							  (cAlias)->UM, ;
							  (cAlias)->QUANTIDADE, ;
							  (cAlias)->VL_UNIT, ;
							  (cAlias)->VALOR_TOTAL, ;
							  (cAlias)->BASE_ICMS, ;
							  (cAlias)->PERC_ICMS, ;
							  (cAlias)->VALOR_ICMS, ;
							  (cAlias)->ICMS_FRETE, ;
							  (cAlias)->CORRETOR, ;
							  (cAlias)->VALOR_COMI, ;
							  (cAlias)->CUSTO, ;
							  (cAlias)->BASE_FUNRURAL, ;
							  (cAlias)->ALIQ_FUNRURAL, ;
							  (cAlias)->VAL_FUNRURAL, ;
							  (cAlias)->TES, ;
							  (cAlias)->DESCRI_TES, ;
							  (cAlias)->DATA_EMBAR, ;
							  (cAlias)->HR_EMBAR, ;
							  (cAlias)->DATA_CHEGA, ;
							  (cAlias)->HR_CHEGA, ;
							  (cAlias)->PESO_CHEGADA, ;
							  (cAlias)->QUEBRA, ;
							  (cAlias)->QUEBRA_ANIMAL, ;
							  (cAlias)->DISTANCIA, ;
							  (cAlias)->FR_TOTAL, ;
							  (cAlias)->FR_ICMS  })							  
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)

Return


Static Function fQuadro6(cPerg)

Local aArea 	 := getArea()
Local _cQry1		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Abate Animal "
Local cTitulo	 := "Animais abatidos no período"
Local dDataAbate := ""
Local nQtdTot    := 0
Local nVlrTot    := 0
cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	
_cQry1 += " 	SELECT ZAB_FILIAL, ZAB_BAIA, ZAB_DTABAT, ZAB_PESOLQ, ZAB_QTABAT, ZAB_QTGRAX, ZAB_VLRARR, ZAB_VLRTOT, ZAB_DESCON, ZAB_VLRECE, ZAB_OBS,  " +CRLF
_cQry1 += "            CASE WHEN ZAB_EMERGE = 1 THEN 'SIM' ELSE 'NÃ' END AS EMERGENCIA,  " +CRLF
_cQry1 += " 	  CASE WHEN ZAB_OUTMOV = 1 THEN 'SIM' ELSE 'NÃ' END AS BOI_GORDO " +CRLF
_cQry1 += "   FROM "+RetSqlName("ZAB")+" ZAB " +CRLF
_cQry1 += "  WHERE ZAB_DTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
_cQry1 += "    AND ZAB.D_E_L_E_T_= ' '  " +CRLF
_cQry1 += "    ORDER BY ZAB_DTABAT, ZAB_BAIA " +CRLF

	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
	MemoWrite(StrTran(cArquivo,".xml","")+"Quadro_Abate_Animal.sql" , _cQry1)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry1 ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "ZAB_DTABAT", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"		      		 	 , 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Baia"		     	             , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Abate"		     	     , 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Liquido"		     	     , 1, 2 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde Abatida"		      		 , 1, 2,)
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Graxaria"		      		 	 , 1, 2,)
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor @"		     		     , 1, 3,)
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Total"		     	     , 1, 3,)
	/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Desconto"		     	         , 1, 3,)
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Receber"		     	 	 , 1, 3,)
	///* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observacao"		     	     , 1, 1 )
	/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Emergencia"		     		 , 1, 1 )
	/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Boi Gordo"		     		     , 1, 1 ) 
	
	
	dbGotop()
	nQtdTot := 0
	nVlrTot := 0
	dDataAbate := (cAlias)->ZAB_DTABAT
	While !(cAlias)->(Eof())
	
		If dDataAbate == (cAlias)->ZAB_DTABAT

				oExcel:AddRow( cWorkSheet, cTitulo, ;
								{ (cAlias)->ZAB_FILIAL, ;
								(cAlias)->ZAB_BAIA, ;
								(cAlias)->ZAB_DTABAT, ;
								(cAlias)->ZAB_PESOLQ, ;
								(cAlias)->ZAB_QTABAT, ;
								(cAlias)->ZAB_QTGRAX, ;
								(cAlias)->ZAB_VLRARR, ;
								(cAlias)->ZAB_VLRTOT, ;
								(cAlias)->ZAB_DESCON, ;
								(cAlias)->ZAB_VLRECE, ; //(cAlias)->ZAB_OBS, ;
								(cAlias)->EMERGENCIA, ;
								(cAlias)->BOI_GORDO })
			nQtdTot += (cAlias)->ZAB_QTABAT
    	    nVlrTot += (cAlias)->ZAB_VLRECE
			(cAlias)->(DbSkip())
		else
			
			oExcel:AddRow( cWorkSheet, cTitulo, ;
									{ "Total", ;
									"", ;
									dDataAbate, ;
									"", ;
									nQtdTot, ;
									"", ;
									"", ;
									, ;
									"", ;
									nVlrTot, ;//"", ;
									"", ;
									"" })
			dDataAbate := (cAlias)->ZAB_DTABAT			
			nQtdTot := 0
			nVlrTot := 0						
		EndIf			
	EndDo
		oExcel:AddRow( cWorkSheet, cTitulo, ;
								{ "Total", ;
								"", ;
								dDataAbate, ;
								"", ;
								nQtdTot, ;
								"", ;
								"", ;
								, ;
								"", ;
								nVlrTot, ;//"", ;
								"", ;
								"" })
			dDataAbate := (cAlias)->ZAB_DTABAT		
	RestArea(aArea)

Return

Static Function fQuadro7(cPerg)

Local aArea 	 := getArea()
Local _cQry1		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "TMs Saida"
Local cTitulo	 := "Outras Movimentações de estoque"

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry1 := "  		SELECT   " + CRLF
	_cQry1 += "  			   D3.D3_FILIAL,  " + CRLF
	_cQry1 += "  			   D3.D3_TM,  " + CRLF
	_cQry1 += "  			   F5.F5_TEXTO,  " + CRLF
	_cQry1 += "  			   D3.D3_GRUPO,  " + CRLF
	_cQry1 += "  			   D3.D3_EMISSAO,  " + CRLF
	_cQry1 += "  			   D3.D3_COD,  " + CRLF
	_cQry1 += "  			   B1.B1_DESC,  " + CRLF
	_cQry1 += "  			   D3.D3_UM,  " + CRLF
	_cQry1 += "  			   D3.D3_LOCAL,  " + CRLF
	_cQry1 += "  			   D3.D3_LOTECTL,  " + CRLF
	_cQry1 += "  			   D3.D3_QUANT,  " + CRLF
	_cQry1 += "  			   D3.D3_CUSTO1/D3.D3_QUANT CUS_UNIT,  " + CRLF
	_cQry1 += "  			   D3.D3_CUSTO1,     " + CRLF
    _cQry1 += "  			   D3.D3_NOMEFOR, " + CRLF
	_cQry1 += "  			   D3.D3_OBSERVA D3_X_OBS" + CRLF
	_cQry1 += "    		  FROM "+RetSqlName("SD3")+"	D3   " + CRLF
	_cQry1 += "  	INNER JOIN "+RetSqlName("SB1")+"	B1  " + CRLF
	_cQry1 += "  			ON B1.B1_COD					=				D3.D3_COD  " + CRLF
	_cQry1 += "  		   AND B1.D_E_L_E_T_				=				' '  " + CRLF
	_cQry1 += "  	INNER JOIN "+RetSqlName("SF5")+"	F5  " + CRLF
	_cQry1 += "  			ON F5.F5_CODIGO					=				D3.D3_TM  " + CRLF
	_cQry1 += "  		   AND F5.D_E_L_E_T_				=				' '   " + CRLF
	_cQry1 += "  		 WHERE D3_EMISSAO					BETWEEN			'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry1 += "  		   AND D3_TM						NOT IN			('001','002','011','511','499','999')  " + CRLF
	_cQry1 += "  		   AND D3_CF 						LIKE 			'RE%'
	_cQry1 += "  		   AND D3_GRUPO						IN				('01',',05','BOV')  " + CRLF
	_cQry1 += "  		   AND D3_QUANT						<>				0  " + CRLF
	_cQry1 += "  		   AND D3.D_E_L_E_T_				=				' '   " + CRLF
	_cQry1 += " 		   AND D3.D3_ESTORNO				<>				'S' " + CRLF
	
	
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro_TM_Movimentacao.sql" , _cQry1)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry1 ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "EMISSAO", "D")
	TcSetField(cAlias, "D3_EMISSAO", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"		      		 	 , 2, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "TM"		     	         	 , 2, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		      		 	 , 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Grupo"		      		 	 	 , 2, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Codigo"		     		     , 2, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		     	 		 , 1, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "UM"		     	     		 , 2, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data"		     	     		 , 2, 4 )
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Armazem"		     		     , 2, 1 )
	/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"		     		         , 1, 1 )
	/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quantidade"		     	     , 1, 2, .T. )
	/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo Unit."		     		 , 1, 3 )
	/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo Total"		     		 , 1, 3, .T. )
	/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Fornecedor"	     	 		 , 1, 1 )
	/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observação"	     	 		 , 1, 1 )
	
	dbGotop()
	
	While !(cAlias)->(Eof())                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->D3_FILIAL, ;
							  (cAlias)->D3_TM, ;
							  (cAlias)->F5_TEXTO, ;
							  (cAlias)->D3_GRUPO, ;
							  (cAlias)->D3_COD, ;
							  (cAlias)->B1_DESC, ;
							  (cAlias)->D3_UM, ;
							  (cAlias)->D3_EMISSAO, ;
							  (cAlias)->D3_LOCAL, ;
							  (cAlias)->D3_LOTECTL, ;
							  (cAlias)->D3_QUANT, ;
							  (cAlias)->CUS_UNIT, ;
							  (cAlias)->D3_CUSTO1, ;
							  (cAlias)->D3_NOMEFOR, ;
							  (cAlias)->D3_X_OBS })
							  
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)

Return
// Faturamento que movimenta estoque


// Faturamento que movimenta estoque
Static Function fQuadro8(cPerg)

Local aArea 	 := getArea()
Local _cQry1		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Venda "
Local cTitulo	 := "Saï¿½ do estoque por faturamento"

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry1 := "  			SELECT D2.D2_FILIAL							FILIAL,	  " + CRLF
	_cQry1 += "  				   D2.D2_DOC							NUMERO,  " + CRLF
	_cQry1 += "  				   D2.D2_EMISSAO						EMISSAO,  " + CRLF
	_cQry1 += "  				   D2.D2_XDTABAT						DATA_ABATE,  " + CRLF
	_cQry1 += "  				   D2.D2_TES							TES,  " + CRLF
	_cQry1 += "  				   F4.F4_TEXTO							DESCRICAO,  " + CRLF
	_cQry1 += "  				   D2.D2_CLIENTE						CLIENTE,  " + CRLF
	_cQry1 += "  				   D2.D2_LOJA							LOJA,  " + CRLF
    _cQry1 += "          CASE WHEN D2.D2_TIPO = 'N' THEN	A1.A1_NOME " + CRLF					   
    _cQry1 += "    	          WHEN D2.D2_TIPO = 'D' THEN	A2.A2_NOME" + CRLF
    _cQry1 += "            									     END AS NOME," + CRLF
	_cQry1 += "  				   A1.A1_NOME							NOME,  " + CRLF
	_cQry1 += "  				   D2.D2_COD							CODIGO,  " + CRLF
	_cQry1 += "  				   B1.B1_DESC							DESCR,  " + CRLF
	_cQry1 += "  				   B1.B1_UM								UM,  " + CRLF
	_cQry1 += "  				   D2.D2_LOTECTL						LOTE,  " + CRLF
	//_cQry1 += "  				   B1.B1_X_CURRA						CURRAL,  " + CRLF
	_cQry1 += "  				   D2.D2_QUANT							QTDE,  " + CRLF
	_cQry1 += "  				   D2.D2_XPESLIQ						PESO_SAIDA,  " + CRLF
	_cQry1 += "  				   D2.D2_XNRPSAG						NUM_PESAGEM,  " + CRLF
	_cQry1 += "  				   D2.D2_LOCAL							ARMAZ,  " + CRLF
	_cQry1 += "  				   D2.D2_TOTAL/D2.D2_QUANT				VL_UNIT,  " + CRLF
	_cQry1 += "  				   D2.D2_TOTAL							TOTAL,  " + CRLF
	_cQry1 += "  				   D2.D2_CUSTO1/D2.D2_QUANT				CUS_UNIT,  " + CRLF
	_cQry1 += "  				   D2.D2_CUSTO1							CUSTO  " + CRLF
	_cQry1 += "     		  FROM "+RetSqlName("SD2")+" 	 D2  " + CRLF
	_cQry1 += "  	          JOIN "+RetSqlName("SF2")+"	 F2   " + CRLF
	_cQry1 += "  			    ON D2.D2_DOC				=					F2.F2_DOC  " + CRLF
	_cQry1 += "  			   AND D2.D2_FILIAL				=					F2.F2_FILIAL  " + CRLF
	_cQry1 += "  			   AND D2.D2_CLIENTE			=					F2.F2_CLIENTE  " + CRLF
	_cQry1 += "  			   AND D2.D2_LOJA				=					F2.F2_LOJA  " + CRLF
	_cQry1 += "   			   AND F2.D_E_L_E_T_ 			=					' ' " + CRLF
	_cQry1 += "  		INNER JOIN "+RetSqlName("SF4")+"	 F4  " + CRLF
	_cQry1 += "  				ON D2.D2_TES				=					F4.F4_CODIGO  " + CRLF
	_cQry1 += "  			   AND F4.D_E_L_E_T_			=					' '  " + CRLF
	_cQry1 += "  			   AND D2_ESTOQUE				=					'S'  " + CRLF
	_cQry1 += "  			   AND F4_TIPO					=					'S'  " + CRLF
	_cQry1 += "  			   AND F4_TRANFIL				=					'2'  " + CRLF
	_cQry1 += "  		 LEFT JOIN "+RetSqlName("SA1")+"	 A1  " + CRLF
	_cQry1 += "  				ON A1.A1_COD				=					D2_CLIENTE  " + CRLF
	_cQry1 += "  			   AND A1.A1_LOJA				=					D2_LOJA  " + CRLF
	_cQry1 += "  			   AND A1.D_E_L_E_T_			=					' '  " + CRLF
	_cQry1 += "    		 LEFT JOIN SA2010 A2  " + CRLF
	_cQry1 += "  				ON A2_COD					=					D2_CLIENTE  " + CRLF
	_cQry1 += "  			   AND A2_LOJA					=					D2_LOJA  " + CRLF
	_cQry1 += "  			   AND A2.D_E_L_E_T_			=					' '   " + CRLF
	_cQry1 += "  		INNER JOIN "+RetSqlName("SB1")+" 	 B1  " + CRLF
	_cQry1 += "  				ON B1.B1_COD				=					D2.D2_COD  " + CRLF
	_cQry1 += "  			   AND B1.D_E_L_E_T_			=					' '  " + CRLF
	_cQry1 += "  			 WHERE D2.D2_EMISSAO			BETWEEN		'"+dToS(MV_PAR01)+"'	AND	  '"+dToS(MV_PAR02)+"'  " + CRLF
	_cQry1 += "  			   AND D2.D_E_L_E_T_			=					' '  " + CRLF
	_cQry1 += "  			   AND D2.D2_QUANT				>					0  " + CRLF
	_cQry1 += "  			   AND D2.D2_GRUPO IN ('BOV','01','05') " + CRLF
	_cQry1 += "  		  ORDER BY D2.D2_EMISSAO  " + CRLF
	
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro_Vendas.sql" , _cQry1)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry1 ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "EMISSAO", "D")
	TcSetField(cAlias, "DATA_ABATE", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"		      		 	 , 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Numero"		     	         , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Emissao"		     	         , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Abate"	     	         , 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "TES"		      		 		 , 1, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		      		 	 , 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cliente"		     		     , 1, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Loja"		     	 			 , 1, 1 )
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Razao Social"		     	     , 1, 1 )
	/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Codigo "		     	         , 1, 1 )
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		     	         , 1, 1 )
	/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "UM"		     		         , 1, 1 )
	/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"		     		         , 1, 1 )
	///* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Curral"		    		     , 1, 1 )
	/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quantidade"		     	     , 1, 2, .T. )
	/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Saï¿½"		     	     , 1, 2, .T. )
	/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "N. Pesagem"		     		 , 1, 1 )
	/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Armazem"		    		     , 1, 1 )
	/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Unit."		     		 , 1, 3 )
	/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Total"		     		 , 1, 3, .T. )
	/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo Unit."		     		 , 1, 3 )
	/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo Total"		     		 , 1, 3, .T. )
	
	dbGotop()
	
	While !(cAlias)->(Eof())                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->FILIAL, ;
							  (cAlias)->NUMERO, ;
							  (cAlias)->EMISSAO, ;
							  (cAlias)->DATA_ABATE, ;
							  (cAlias)->TES, ;
							  (cAlias)->DESCRICAO, ;
							  (cAlias)->CLIENTE, ;
							  (cAlias)->LOJA, ;
							  (cAlias)->NOME, ;
							  (cAlias)->CODIGO, ;
							  (cAlias)->DESCR, ;
							  (cAlias)->UM, ;
							  (cAlias)->LOTE, ;
							  (cAlias)->QTDE, ;
							  (cAlias)->PESO_SAIDA, ;
							  (cAlias)->NUM_PESAGEM, ;
							  (cAlias)->ARMAZ, ;
							  (cAlias)->VL_UNIT, ;
							  (cAlias)->TOTAL, ;
							  (cAlias)->CUS_UNIT, ;
							  (cAlias)->CUSTO })
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)

Return

Static Function fQuadro9(cPerg)

Local aArea 	 := getArea()
Local _cQry1		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "TMs Entrada"
Local cTitulo	 := "Outras Movimentações de estoque"

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry1 := "  		SELECT   " + CRLF
	_cQry1 += "  			   D3.D3_FILIAL,  " + CRLF
	_cQry1 += "  			   D3.D3_TM,  " + CRLF
	_cQry1 += "  			   F5.F5_TEXTO,  " + CRLF
	_cQry1 += "  			   D3.D3_GRUPO,  " + CRLF
	_cQry1 += "  			   D3.D3_EMISSAO,  " + CRLF
	_cQry1 += "  			   D3.D3_COD,  " + CRLF
	_cQry1 += "  			   B1.B1_DESC,  " + CRLF
	_cQry1 += "  			   D3.D3_UM,  " + CRLF
	_cQry1 += "  			   D3.D3_LOCAL,  " + CRLF
	_cQry1 += "  			   D3.D3_LOTECTL,  " + CRLF
	_cQry1 += "  			   D3.D3_QUANT,  " + CRLF
	_cQry1 += "  			   D3.D3_CUSTO1/D3.D3_QUANT CUS_UNIT,  " + CRLF
	_cQry1 += "  			   D3.D3_CUSTO1,     " + CRLF
    _cQry1 += "  			   D3.D3_NOMEFOR, " + CRLF
	_cQry1 += "  			   D3.D3_OBSERVA D3_X_OBS" + CRLF
	_cQry1 += "    		  FROM "+RetSqlName("SD3")+"	D3   " + CRLF
	_cQry1 += "  	INNER JOIN "+RetSqlName("SB1")+"	B1  " + CRLF
	_cQry1 += "  			ON B1.B1_COD					=				D3.D3_COD  " + CRLF
	_cQry1 += "  		   AND B1.D_E_L_E_T_				=				' '  " + CRLF
	_cQry1 += "  	INNER JOIN "+RetSqlName("SF5")+"	F5  " + CRLF
	_cQry1 += "  			ON F5.F5_CODIGO					=				D3.D3_TM  " + CRLF
	_cQry1 += "  		   AND F5.D_E_L_E_T_				=				' '   " + CRLF
	_cQry1 += "  		 WHERE D3_EMISSAO					BETWEEN			'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry1 += "  		   AND D3_TM						NOT IN			('001','002','011','511','499','999')  " + CRLF
	_cQry1 += "  		   AND D3_CF 						LIKE 			'DE%'
	_cQry1 += "  		   AND D3_GRUPO						IN				('01',',05','BOV')  " + CRLF
	_cQry1 += "  		   AND D3_QUANT						<>				0  " + CRLF
	_cQry1 += "  		   AND D3.D_E_L_E_T_				=				' '   " + CRLF
	_cQry1 += " 		   AND D3.D3_ESTORNO				<>				'S' " + CRLF
	
	
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro_TM_Movimentacao.sql" , _cQry1)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry1 ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "EMISSAO", "D")
	TcSetField(cAlias, "D3_EMISSAO", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"		      		 	 , 2, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "TM"		     	         	 , 2, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		      		 	 , 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Grupo"		      		 	 	 , 2, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Codigo"		     		     , 2, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		     	 		 , 1, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "UM"		     	     		 , 2, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data"		     	     		 , 2, 4 )
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Armazem"		     		     , 2, 1 )
	/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"		     		         , 1, 1 )
	/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quantidade"		     	     , 1, 2, .T. )
	/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo Unit."		     		 , 1, 3 )
	/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo Total"		     		 , 1, 3, .T. )
	/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Fornecedor"	     	 		 , 1, 1 )
	/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Observação"	     	 		 , 1, 1 )
	
	dbGotop()
	
	While !(cAlias)->(Eof())                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->D3_FILIAL, ;
							  (cAlias)->D3_TM, ;
							  (cAlias)->F5_TEXTO, ;
							  (cAlias)->D3_GRUPO, ;
							  (cAlias)->D3_COD, ;
							  (cAlias)->B1_DESC, ;
							  (cAlias)->D3_UM, ;
							  (cAlias)->D3_EMISSAO, ;
							  (cAlias)->D3_LOCAL, ;
							  (cAlias)->D3_LOTECTL, ;
							  (cAlias)->D3_QUANT, ;
							  (cAlias)->CUS_UNIT, ;
							  (cAlias)->D3_CUSTO1, ;
							  (cAlias)->D3_NOMEFOR, ;
							  (cAlias)->D3_X_OBS })
							  
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)

Return

Static Function fQuadro10(cPerg)

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Devoluç£¯ de Vendas"
Local cTitulo	 := "Relação das NFs devolvidas"

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry := "  			SELECT D1.D1_FILIAL					FILIAL, " +CRLF
	_cQry += "  				   D1.D1_DOC					NOTA_FIS, " +CRLF
	_cQry += "  				   D1.D1_SERIE					SERIE, " +CRLF
	_cQry += "  				   D1.D1_EMISSAO				EMISSAO, " +CRLF
	_cQry += "  				   D1.D1_TIPO					TIPO, " +CRLF
	_cQry += "  				   D1.D1_FORNECE				COD_FORNECEDOR, " +CRLF
	_cQry += "  				   A1.A1_NOME					FORNECEDOR, " +CRLF
	_cQry += "  				   A1.A1_MUN					MUNICIPIO, " +CRLF
	_cQry += "  				   A1.A1_EST					ESTADO, " +CRLF
	_cQry += "  				   D1.D1_ITEM					ITEM, " +CRLF
	_cQry += "  				   D1.D1_COD					CODIGO,  " +CRLF
	_cQry += "  				   B1.B1_DESC					DESCRICAO, " +CRLF
	_cQry += "  				   B1.B1_UM						UM, " +CRLF
	_cQry += "  				   D1.D1_QUANT					QUANTIDADE, " +CRLF
	_cQry += "  				   D1.D1_TOTAL/D1.D1_QUANT		VL_UNIT, " +CRLF
	_cQry += "  				   D1.D1_TOTAL					VALOR_TOTAL, " +CRLF
	_cQry += "  				   D1.D1_BASEICM				BASE_ICMS, " +CRLF
	_cQry += "  				   D1.D1_PICM					PERC_ICMS, " +CRLF
	_cQry += "  				   D1.D1_VALICM					VALOR_ICMS, " +CRLF
	_cQry += "  				   D1.D1_CUSTO					CUSTO, " +CRLF
	_cQry += "  				   D1.D1_BASEFUN				BASE_FUNRURAL, " +CRLF 
	_cQry += "  				   D1.D1_ALIQFUN				ALIQ_FUNRURAL, " +CRLF
	_cQry += "  				   D1.D1_VALFUN					VAL_FUNRURAL, " +CRLF
	_cQry += "  				   D1.D1_TES					TES, " +CRLF
	_cQry += "  				   F4.F4_TEXTO					DESCRI_TES, " +CRLF
	_cQry += "  				   D1.D1_X_EMBDT				DATA_EMBAR, " +CRLF
	_cQry += "  				   D1.D1_X_EMBHR				HR_EMBAR, " +CRLF
	_cQry += "  				   D1.D1_X_CHEDT				DATA_CHEGA, " +CRLF
	_cQry += "  				   D1.D1_X_CHEHR				HR_CHEGA, " +CRLF
	_cQry += "  				   D1.D1_X_PESCH				PESO_CHEGADA, " +CRLF
	_cQry += "  				   D1.D1_X_QUEKG				QUEBRA, " +CRLF
	_cQry += "  				   D1.D1_X_QUECA				QUEBRA_ANIMAL, " +CRLF
	_cQry += "  				   D1.D1_X_KM					DISTANCIA " +CRLF
	_cQry += "    		      FROM "+RetSqlName("SD1")+"						D1 " +CRLF
	_cQry += "  		INNER JOIN "+RetSqlName("SA1")+"		A1 " +CRLF
	_cQry += "  				ON A1.A1_COD					=			D1.D1_FORNECE " +CRLF
	_cQry += "  			   AND A1.A1_LOJA					=			D1.D1_LOJA " +CRLF
	_cQry += "  			   AND A1.D_E_L_E_T_				=			' '  " +CRLF
	_cQry += "  		INNER JOIN "+RetSqlName("SB1")+"		B1 " +CRLF
	_cQry += "  				ON B1.B1_COD					=			D1.D1_COD " +CRLF 
	_cQry += "  			   AND B1.D_E_L_E_T_				=			' '  " +CRLF
	_cQry += "  		INNER JOIN "+RetSqlName("SF4")+"		F4 " +CRLF 
	_cQry += "  				ON F4.F4_CODIGO					=			D1.D1_TES " +CRLF
	_cQry += "  			   AND F4.F4_TRANFIL				<>			'1' " +CRLF
	_cQry += "  			   AND F4.D_E_L_E_T_				=			' ' " +CRLF
	_cQry += "  			 WHERE D1.D1_GRUPO					IN			('01','05','BOV') " +CRLF
	_cQry += "  			   AND D1.D1_EMISSAO				BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "  			   AND D1.D_E_L_E_T_				=			' ' " +CRLF
	_cQry += "  			   AND D1.D1_TIPO					=			'D' " +CRLF
	_cQry += "  		  ORDER BY D1_EMISSAO, D1_FILIAL, D1_DOC, D1_ITEM " +CRLF	
	
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro_Devolucao_Vendas.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "EMISSAO", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"  		 	 , 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "NF"		      	 , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Serie"	    	 	 , 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Emissao"   	 	 , 1, 4 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Tipo"	    	     , 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cod. Forn."   		 , 1, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Razao"    	   		 , 1, 1 )
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Municipio"		     , 1, 1 )
	/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Est." 		         , 1, 1 )
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Item"	    		 , 1, 1 )
	/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cod."		     	 , 1, 1 )
	/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		     , 1, 1 )
	/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "UM"	     		 , 1, 1 )
	/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "QTD"	   		     , 1, 2 )
	/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Unit."	     , 1, 3, .T. )
	/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Total"	    	     , 1, 3, .T. )
	/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Base ICMS"		     , 1, 1, .T. )
	/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "% ICMS"		     , 1, 2 )
	/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor ICMS"	     , 1, 3, .T.)
	/* 20 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo"	    	     , 1, 3, .T. )
	/* 21 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Base Funrural"	     , 1, 3 )
	/* 22 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Aliq Funrural"	     , 1, 2 )
	/* 23 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Funrural"	 , 1, 3, .T. )
	/* 24 */ oExcel:AddColumn( cWorkSheet, cTitulo, "TES"	  		     , 1, 1 )
	/* 25 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Desc. TES"	 	     , 1, 1 )
	/* 26 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dt Embar."		     , 1, 1 )
	/* 27 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Hr Embar."	         , 1, 1 )
	/* 28 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dt Chega."	         , 1, 1 )
	/* 29 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Hr Chega"	         , 1, 1 )
	/* 30 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Chega"	     , 1, 2, .T. )
	/* 31 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quebra"	         , 1, 2 )
	/* 32 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quebra Animal"      , 1, 2 )
	/* 33 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Distancia"		     , 1, 2 )
	///* 34 */ oExcel:AddColumn( cWorkSheet, cTitulo, ""	    		     , 1, 1 )
	
	dbGotop()
	
	While !(cAlias)->(Eof())                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->FILIAL, ;
							  (cAlias)->NOTA_FIS, ;
							  (cAlias)->SERIE, ;
							  (cAlias)->EMISSAO, ;
							  (cAlias)->TIPO, ;
							  (cAlias)->COD_FORNECEDOR, ;
							  (cAlias)->FORNECEDOR, ;
							  (cAlias)->MUNICIPIO, ;
							  (cAlias)->ESTADO, ;
							  (cAlias)->ITEM, ;
							  (cAlias)->CODIGO, ; 
							  (cAlias)->DESCRICAO, ;
							  (cAlias)->UM, ;
							  (cAlias)->QUANTIDADE, ;
							  (cAlias)->VL_UNIT, ;
							  (cAlias)->VALOR_TOTAL, ;
							  (cAlias)->BASE_ICMS, ;
							  (cAlias)->PERC_ICMS, ;
							  (cAlias)->VALOR_ICMS, ;
							  (cAlias)->CUSTO, ;
							  (cAlias)->BASE_FUNRURAL, ;
							  (cAlias)->ALIQ_FUNRURAL, ;
							  (cAlias)->VAL_FUNRURAL, ;
							  (cAlias)->TES, ;
							  (cAlias)->DESCRI_TES, ;
							  (cAlias)->DATA_EMBAR, ;
							  (cAlias)->HR_EMBAR, ;
							  (cAlias)->DATA_CHEGA, ;
							  (cAlias)->HR_CHEGA, ;
							  (cAlias)->PESO_CHEGADA, ;
							  (cAlias)->QUEBRA, ;
							  (cAlias)->QUEBRA_ANIMAL, ;
							  (cAlias)->DISTANCIA  })							  
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)

Return


// Resumo da Movimentação
Static Function fQuadro11(cPerg)

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Resumo por Tipo"
Local cTitulo	 := "Resumo por Tipo de Movimentação"

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)

	oExcel:AddworkSheet(cWorkSheet)
	oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry := " WITH NAS_MOR  " + CRLF
	_cQry += " 	AS ( " + CRLF
	_cQry += " 		SELECT D3.D3_FILIAL					FILIAL, " + CRLF
	_cQry += " 		  CASE WHEN D3_TM = '011'			THEN 'NASCIMENTO' " + CRLF
	_cQry += " 			   WHEN D3_TM = '511'			THEN 'MORTE' " + CRLF
	_cQry += " 											END AS TIPO, " + CRLF
	_cQry += " 			   B1.B1_DESC					ANIMAL, " + CRLF
	_cQry += " 			   SUM(D3.D3_QUANT)				QUANTIDADE " + CRLF
	_cQry += " 		 FROM "+RetSqlName("SD3")+"						D3 " + CRLF
	_cQry += "    INNER JOIN "+RetSqlName("SB1")+"						B1 " + CRLF
	_cQry += " 		   ON B1.B1_COD							=					D3.D3_COD " + CRLF
	_cQry += " 		  AND B1.D_E_L_E_T_						=					' '  " + CRLF
	_cQry += " 		 WHERE D3_TM							IN					('011','511') " + CRLF
	_cQry += " 		   AND D3.D3_EMISSAO				BETWEEN					'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += " 		   AND D3.D_E_L_E_T_					=					' '  " + CRLF
	_cQry += " 		   AND D3.D3_ESTORNO						<>					'S' " + CRLF
	_cQry += " 	  GROUP BY D3.D3_FILIAL, D3.D3_TM, B1.B1_DESC " + CRLF
	_cQry += " 		), " + CRLF
	_cQry += " COMPRA  " + CRLF
	_cQry += " 		AS ( " + CRLF
	_cQry += " 			SELECT D1.D1_FILIAL					FILIAL,  " + CRLF
	_cQry += "				CASE WHEN D1_TIPO = 'N' THEN		'COMPRAS'  " + CRLF
	_cQry += "                  WHEN D1_TIPO = 'D' THEN		'DEV. COMPRAS'  " + CRLF
	_cQry += "              	END AS TIPO,  " + CRLF
	_cQry += " 				   B1.B1_DESC					ANIMAL, " + CRLF
	_cQry += "   				   SUM(D1.D1_QUANT)				QUANTIDADE " + CRLF
	_cQry += "     		      FROM "+RetSqlName("SD1")+"						D1  " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SA2")+"						A2  " + CRLF
	_cQry += "   				ON A2.A2_COD					=			D1.D1_FORNECE  " + CRLF
	_cQry += "   			   AND A2.A2_LOJA					=			D1.D1_LOJA  " + CRLF
	_cQry += "   			   AND A2.D_E_L_E_T_				=			' '   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SB1")+"						B1  " + CRLF
	_cQry += "   				ON B1.B1_COD					=			D1.D1_COD  " + CRLF
	_cQry += "   			   AND B1.D_E_L_E_T_				=			' '   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SF4")+"						F4  " + CRLF
	_cQry += "   				ON F4.F4_CODIGO					=			D1.D1_TES  " + CRLF
	_cQry += "   			   AND F4.F4_TRANFIL				<>			'1'  " + CRLF
	_cQry += "   			   AND F4.D_E_L_E_T_				=			' '  " + CRLF
	_cQry += "   			 WHERE D1.D1_GRUPO					IN			('01','05','BOV')  " + CRLF
	_cQry += "   			   AND D1.D1_EMISSAO				BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   			   AND D1.D_E_L_E_T_				=			' '  " + CRLF
	_cQry += "   			   AND D1.D1_TIPO					=			'N'  " + CRLF
	_cQry += "   		  GROUP BY D1.D1_FILIAL, D1.D1_TIPO, B1.B1_DESC " + CRLF
	_cQry += " 			), " + CRLF
	_cQry += " FATURAMENTO " + CRLF
	_cQry += " 		AS( " + CRLF
	_cQry += " 		    SELECT D2.D2_FILIAL							FILIAL, " + CRLF
	_cQry += " 				   'VENDA'								TIPO,	   " + CRLF
	_cQry += "   				   B1.B1_DESC							ANIMAL,   " + CRLF
	_cQry += "   				   SUM(D2.D2_QUANT)							QUANTIDADE   " + CRLF
	_cQry += "      		  FROM "+RetSqlName("SD2")+"	 D2   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SF4")+"	 F4   " + CRLF
	_cQry += "   				ON D2.D2_TES				=					F4.F4_CODIGO   " + CRLF
	_cQry += "   			   AND F4.D_E_L_E_T_			=					' '   " + CRLF
	_cQry += "   			   AND D2_ESTOQUE				=					'S'   " + CRLF
	_cQry += "   			   AND F4_TIPO					=					'S'   " + CRLF
	_cQry += "   			   AND F4_TRANFIL				=					'2'   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SA1")+"	 A1   " + CRLF
	_cQry += "   				ON A1.A1_COD				=					D2_CLIENTE   " + CRLF
	_cQry += "   			   AND A1.D_E_L_E_T_			=					' '   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SB1")+" 	 B1   " + CRLF
	_cQry += "   				ON B1.B1_COD				=					D2.D2_COD   " + CRLF
	_cQry += "   			   AND B1.D_E_L_E_T_			=					' '   " + CRLF
	_cQry += "   			 WHERE D2.D2_EMISSAO			BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   			   AND D2.D_E_L_E_T_			=					' '   " + CRLF
	_cQry += "   			   AND D2.D2_GRUPO				IN					('01','05','BOV')  " + CRLF
	_cQry += "   			   AND D2.D2_QUANT				>					0   " + CRLF
	_cQry += " 		  GROUP BY D2.D2_FILIAL, B1.B1_DESC " + CRLF
	_cQry += "   		  --ORDER BY D2.D2_EMISSAO   " + CRLF
	_cQry += " 		   ), " + CRLF
	_cQry += " TRANSF_FILIAIS AS" + CRLF
	_cQry += " 		( " + CRLF
	_cQry += " 			SELECT D1.D1_FILIAL					FILIAL, " + CRLF
	_cQry += " 			   'TRANSF. ENTRADA'			TIPO,   " + CRLF
	_cQry += "   			   B1.B1_DESC					ANIMAL, " + CRLF
	_cQry += " 			   SUM(D1.D1_QUANT)				QUANTIDADE " + CRLF
	_cQry += " 		  FROM "+RetSqlName("SD1")+"				D1 " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SF4")+"				F4   " + CRLF
	_cQry += "   			ON D1.D1_TES						=			F4.F4_CODIGO   " + CRLF
	_cQry += "   		   AND F4.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		   AND F4_TRANFIL						=			'1'   " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SBM")+"				BM   " + CRLF
	_cQry += "   			ON BM.BM_GRUPO						=			D1.D1_GRUPO   " + CRLF
	_cQry += "   		   AND BM.D_E_L_E_T_					=			' '	     " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SA2")+"				A2   " + CRLF
	_cQry += "   			ON A2.A2_COD						=			D1.D1_FORNECE   " + CRLF
	_cQry += "   		   AND A2.A2_LOJA						=			D1.D1_LOJA   " + CRLF
	_cQry += "   		   AND A2.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SB1")+"				B1   " + CRLF
	_cQry += "   			ON B1.B1_COD						=			D1.D1_COD   " + CRLF
	_cQry += "   		   AND B1.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		 WHERE D1_DTDIGIT						BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   		   AND D1.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		   AND D1.D1_GRUPO						IN			('01','05','BOV')   " + CRLF
	_cQry += "   		   AND D1.D1_QUANT						>			0   " + CRLF
	_cQry += "     GROUP BY D1.D1_FILIAL, B1.B1_DESC " + CRLF
	_cQry += "   		UNION ALL   " + CRLF
	_cQry += "   		SELECT D2.D2_FILIAL					FILIAL,   " + CRLF
	_cQry += " 			   'TRANSF. SAÍ„A'				TIPO,   " + CRLF
	_cQry += "   			   B1.B1_DESC					ANIMAL,   " + CRLF
	_cQry += "   			   SUM(D2.D2_QUANT)				QUANTIDADE  			    " + CRLF
	_cQry += "   		  FROM "+RetSqlName("SD2")+"		D2   " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SF4")+"		F4   " + CRLF
	_cQry += "   			ON D2.D2_TES						=			F4.F4_CODIGO   " + CRLF
	_cQry += "   		   AND F4.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		   AND F4_TRANFIL						=			'1'   " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SBM")+"		BM   " + CRLF
	_cQry += "   			ON BM.BM_GRUPO						=			D2.D2_GRUPO   " + CRLF
	_cQry += "   		   AND BM.D_E_L_E_T_					=			' '	     " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SA1")+"		A1   " + CRLF
	_cQry += "   			ON A1.A1_COD						=			D2.D2_CLIENTE   " + CRLF
	_cQry += "   		   AND A1.A1_LOJA						=			D2.D2_LOJA   " + CRLF
	_cQry += "   		   AND A1.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SB1")+"		B1   " + CRLF
	_cQry += "   			ON B1.B1_COD						=			D2.D2_COD   " + CRLF
	_cQry += "   		   AND B1.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		 WHERE D2_EMISSAO						BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   		   AND D2.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		   AND D2.D2_GRUPO						IN			('01','05','BOV')   " + CRLF
	_cQry += "   		   AND D2.D2_QUANT						>			0	   " + CRLF
	_cQry += " 		   GROUP BY D2.D2_FILIAL, B1.B1_DESC " + CRLF
	_cQry += " 		), " + CRLF
	_cQry += " MOVIMENTACAO_ESTOQUE " + CRLF
	_cQry += " 		AS ( " + CRLF
	_cQry += " 			SELECT D3.D3_FILIAL				FILIAL,   " + CRLF
	_cQry += "   	  CASE WHEN D3_TM < '499' THEN 'TM ENTRADA' " + CRLF
	_cQry += " 		   WHEN D3_TM >= '500' THEN 'TM SAIDA' " + CRLF
	_cQry += " 							END AS			TIPO, " + CRLF
	_cQry += "   			   B1.B1_DESC					ANIMAL,     " + CRLF
	_cQry += "   			   SUM(D3.D3_QUANT)				QUANTIDADE " + CRLF
	_cQry += "     		  FROM "+RetSqlName("SD3")+"	D3    " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SB1")+"	B1   " + CRLF
	_cQry += "   			ON B1.B1_COD					=				D3.D3_COD   " + CRLF
	_cQry += "   		   AND B1.D_E_L_E_T_				=				' '   " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SF5")+"	F5   " + CRLF
	_cQry += "   			ON F5.F5_CODIGO					=				D3.D3_TM   " + CRLF
	_cQry += "   		   AND F5.D_E_L_E_T_				=				' '    " + CRLF
	_cQry += "   		 WHERE D3_EMISSAO					BETWEEN			'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   		   AND D3_TM						NOT IN			('001','002','011','511','499','999')   " + CRLF
	_cQry += "   		   AND D3_GRUPO						IN				('01',',05','BOV')   " + CRLF
	_cQry += "   		   AND D3_QUANT						<>				0   " + CRLF
	_cQry += "   		   AND D3.D_E_L_E_T_				=				' '    " + CRLF
	_cQry += " 		       AND D3.D3_ESTORNO					<>				'S' " + CRLF
	_cQry += " 	  GROUP BY D3.D3_FILIAL, D3.D3_TM, B1.B1_DESC )," + CRLF
	_cQry += " 	 	  FAT  AS (     	 " + CRLF
	_cQry += " 	     	SELECT DISTINCT D2_FILIAL FILIAL, 	 " + CRLF
	_cQry += " 				'ABATE' AS TIPO,    	 " + CRLF
	_cQry += " 	    	    --D2_XCODABT CODIGO_ABATE,     	 " + CRLF
	_cQry += " 	    		D2_LOTECTL LOTE,     	 " + CRLF
	_cQry += " 	    		D2_EMISSAO EMISSAO_NF,    	 " + CRLF
	_cQry += " 	    		B8_XDATACO DAT_INICIO,     	 " + CRLF
	_cQry += " 	    		B8_XPESOCO PESO_INICIO,      	 " + CRLF
	_cQry += " 	     		--ZBC_PESO,     	 " + CRLF
	_cQry += " 	     		D2_XDTABAT DATA_ABATE,      	 " + CRLF
	_cQry += " 	     		CASE WHEN B8_XDATACO = ' ' THEN 0 ELSE datediff(DAY, B8_XDATACO,D2_EMISSAO) END DIAS_CONF,	 " + CRLF
	_cQry += " 	     		CASE WHEN B8_XDATACO = ' ' THEN ' ' ELSE (ROUND((SUM(D2_XPESLIQ)/SUM(D2_QUANT)-B8_XPESOCO),3)  / CASE WHEN datediff(DAY, B8_XDATACO,D2_EMISSAO) = 0 THEN 1 ELSE datediff(DAY, B8_XDATACO,D2_EMISSAO) END) END GMD,  	 " + CRLF
	_cQry += " 	     		SUM(D2_XPESLIQ) PESO , SUM(D2_QUANT) QTD,      	 " + CRLF
	_cQry += " 	     		ROUND(SUM(D2_XPESLIQ)/SUM(D2_QUANT),2) PESO_MEDIO     	 " + CRLF
	_cQry += " 	     	FROM "+RetSqlName("SD2")+" D2     	 " + CRLF
	_cQry += " 	     	JOIN "+RetSqlName("SB8")+" B8 ON B8_PRODUTO = D2_COD      	 " + CRLF
	_cQry += " 	     	AND B8_LOTECTL = D2_LOTECTL     	 " + CRLF
	_cQry += " 	     	WHERE D2_XPESLIQ > 0       	 " + CRLF
	_cQry += " 	     	AND D2_XDTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' 	 " + CRLF
	_cQry += " 	     	AND D2.D_E_L_E_T_ = ' '  and B8.D_E_L_E_T_ = ' '      	 " + CRLF
	_cQry += " 	     	GROUP BY D2_FILIAL, D2_LOTECTL, D2_EMISSAO, D2_XDTABAT, B8_XDATACO, B8_XPESOCO     	 " + CRLF
	_cQry += " 	    ),    	 " + CRLF
	_cQry += " 	    ABATE AS (    	 " + CRLF
	_cQry += " 	     SELECT ZAB_FILIAL FILIAL,    	 " + CRLF
	_cQry += " 			    'ABATE' AS TIPO, 	 " + CRLF
	_cQry += " 	    	    ZAB_BAIA LOTE,        	 " + CRLF
	_cQry += " 	     		ZAB_DTABAT DATA_ABATE,     	 " + CRLF
	_cQry += " 	     		SUM(ZAB_PESOLQ) PESO_ABATE,     	 " + CRLF
	_cQry += " 	    		SUM(ZAB_QTABAT) QTD,    	 " + CRLF
	_cQry += " 	     		SUM(ZAB_VLRTOT) VALOR_TOTAL    	 " + CRLF
	_cQry += " 	    		FROM "+RetSqlName("ZAB")+"    	 " + CRLF
	_cQry += " 	    		WHERE ZAB_DTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' 	 " + CRLF
	_cQry += " 	    		AND ZAB010.D_E_L_E_T_ = ' '     	 " + CRLF
	_cQry += " 	    		GROUP BY ZAB_FILIAL, ZAB_BAIA, ZAB_DTABAT    	 " + CRLF
	_cQry += " 	    ),  	 " + CRLF
	_cQry += " 			 " + CRLF
	_cQry += " 	    FILIAISA AS (  	 " + CRLF
	_cQry += " 	    SELECT ZAB_FILIAL,'ABATE' AS TIPO, ZAB_CODIGO, ZAB_DTABAT, ZAB_PESOLQ, ZAB_VLRTOT   	 " + CRLF
	_cQry += " 	    FROM "+RetSqlName("ZAB")+"   	 " + CRLF
	_cQry += " 	    WHERE ZAB_FILIAL <> '01' AND ZAB_DTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' AND D_E_L_E_T_ = ' '   	 " + CRLF
	_cQry += " 	    ),  	 " + CRLF
	/*_cQry += " 	    FILIAISD2 AS (  	 " + CRLF
	_cQry += " 	    SELECT D2_FILIAL FILIAL, 'ABATE' AS TIPO,  D2_XCODABT, '' AS LOTE, '' AS EMISSAO_NF, '' DAT_INICIO, '' PESO_INICIO, '' DIAS_CONF, '' GMD,       	 " + CRLF
	_cQry += " 	          SUM(D2_XPESLIQ) PESO, SUM(D2_QUANT) QTD, ROUND(SUM(D2_XPESLIQ)/SUM(D2_QUANT),2) PESO_MEDIO   	 " + CRLF
	_cQry += " 	    FROM "+RetSqlName("SD2")+"   	 " + CRLF
	_cQry += " 	    WHERE D2_FILIAL <> '01' AND D2_XDTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'	 " + CRLF
	_cQry += " 	    GROUP BY D2_FILIAL, D2_XCODABT  	 " + CRLF
	_cQry += " 	    ),	 " + CRLF*/
	_cQry += " 		ABATEE AS (	 " + CRLF
	_cQry += " 	    SELECT F.FILIAL, 'ABATE' AS TIPO,F.LOTE, F.EMISSAO_NF, F.DAT_INICIO, F.PESO_INICIO, F.DATA_ABATE, F.DIAS_CONF, F.GMD, F.PESO, A.QTD, F.PESO_MEDIO, A.PESO_ABATE, A.VALOR_TOTAL    	 " + CRLF
	_cQry += " 	    FROM FAT F    	 " + CRLF
	_cQry += " 	    JOIN ABATE A ON    	 " + CRLF
	_cQry += " 	    F.FILIAL = A.FILIAL    	 " + CRLF
	_cQry += " 	    AND F.LOTE = A.LOTE    	 " + CRLF
	_cQry += " 	    AND F.DATA_ABATE = A.DATA_ABATE    	 " + CRLF
	_cQry += " 	   UNION   	 " + CRLF
	/*_cQry += " 	    SELECT FILIAL, 'ABATE' AS TIPO,'' AS LOTE, EMISSAO_NF, '' DAT_INICIO, '' PESO_INICIO, ZAB_DTABAT, '' DIAS_CONF, '' GMD, PESO, QTD, PESO_MEDIO,  ZAB_PESOLQ, ZAB_VLRTOT  	 " + CRLF
	_cQry += " 	   FROM FILIAISD2 SD2  	 " + CRLF
	_cQry += " 	   JOIN FILIAISA A  	 " + CRLF
	_cQry += " 	   ON SD2.FILIAL = A.ZAB_FILIAL  	 " + CRLF
	_cQry += " 	   AND SD2.D2_XCODABT = ZAB_CODIGO  	 " + CRLF
	_cQry += " 	   UNION ALL 	 " + CRLF*/
	_cQry += " 	    SELECT D2_FILIAL FILIAL, 'ABATE' AS TIPO, D2_LOTECTL LOTE, D2_EMISSAO, B8_XDATACO DATA_INICIO, B8_XPESOCO PESO_INICIO, D2_XDTABAT DATA_ABATE,     	 " + CRLF
	_cQry += " 	    CASE WHEN B8_XDATACO = ' ' THEN 0 ELSE datediff(DAY, B8_XDATACO,D2_EMISSAO) END DIAS_CONF, " + CRLF
	_cQry += " 	    CASE WHEN B8_XDATACO = ' ' THEN ' ' ELSE (ROUND((SUM(D2_XPESLIQ)/SUM(D2_QUANT)-B8_XPESOCO),3)  / CASE WHEN datediff(DAY, B8_XDATACO,D2_EMISSAO) = 0 THEN 1 ELSE datediff(DAY, B8_XDATACO,D2_EMISSAO) END) END GMD, " + CRLF
	_cQry += " 	    SUM(D2_XPESLIQ) PESO, SUM(D2_QUANT) QTD, SUM(D2_XPESLIQ)/SUM(D2_QUANT) PESO_MEDIO,    	 " + CRLF
	_cQry += " 	    ROUND(SUM(ZAB_PESOLQ)/SUM(ZAB_QTABAT),2)*SUM(D2_QUANT) PESO_ABATE,     	 " + CRLF
	_cQry += " 	    ROUND(SUM(ZAB_VLRTOT)/SUM(ZAB_QTABAT)*SUM(D2_QUANT),2) VALOR_TOTAL    	 " + CRLF
	_cQry += " 	    FROM ZAB010 AB    	 " + CRLF
	_cQry += " 	    JOIN SD2010 D2 ON    	 " + CRLF
	_cQry += " 	    D2.D2_XCODABT = ZAB_CODIGO     	 " + CRLF
	_cQry += " 	    AND D2.D2_XDTABAT = ZAB_DTABAT    	 " + CRLF
	_cQry += " 	    JOIN SB8010 ON     	 " + CRLF
	_cQry += " 	    B8_FILIAL = D2_FILIAL     	 " + CRLF
	_cQry += " 	    AND B8_PRODUTO = D2_COD     	 " + CRLF
	_cQry += " 	    AND B8_LOTECTL = D2_LOTECTL    	 " + CRLF
	_cQry += " 	    WHERE ZAB_DTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' 	 " + CRLF
	_cQry += " 	    AND ZAB_BAIA = ' '     	 " + CRLF
	_cQry += " 	    GROUP BY D2_FILIAL, D2_LOTECTL, D2_EMISSAO, B8_XDATACO, B8_XPESOCO, D2_XDTABAT, ZAB_CODIGO, ZAB_DTABAT    	 " + CRLF
	_cQry += " 		)	 " + CRLF
	_cQry += " 			 " + CRLF
	_cQry += " 			 " + CRLF
	_cQry += " 			 " + CRLF
	_cQry += " 	SELECT TIPO, SUM(QUANTIDADE) QUANTIDADE  " + CRLF
	_cQry += " 		  FROM COMPRA 	 " + CRLF
	_cQry += " 	  GROUP BY TIPO		 " + CRLF
	_cQry += " 		UNION ALL 	 " + CRLF
	_cQry += " 		SELECT TIPO, SUM(QUANTIDADE) QUANTIDADE	 " + CRLF
	_cQry += " 	      FROM NAS_MOR	 " + CRLF
	_cQry += " 		 GROUP BY TIPO	 " + CRLF
	_cQry += " 		UNION ALL	 " + CRLF
	_cQry += " 		SELECT TIPO, SUM(QUANTIDADE) QUANTIDADE	 " + CRLF
	_cQry += " 	      FROM FATURAMENTO 	 " + CRLF
	_cQry += " 	  GROUP BY TIPO	 " + CRLF
	_cQry += " 	    UNION ALL	 " + CRLF
	_cQry += "      SELECT TIPO, SUM(QTD) QUANTIDADE" + CRLF	 
 	_cQry += "            FROM ABATEE 	 " + CRLF
 	_cQry += "        GROUP BY TIPO	 " + CRLF
 	_cQry += "          UNION ALL 	" + CRLF
	_cQry += " 	    SELECT TIPO, SUM(QUANTIDADE) QUANTIDADE	 " + CRLF
	_cQry += " 		  FROM TRANSF_FILIAIS	 " + CRLF
	_cQry += " 		  GROUP BY TIPO	 " + CRLF
	_cQry += " 		UNION ALL	 " + CRLF
	_cQry += " 		SELECT  TIPO, SUM(QUANTIDADE) QUANTIDADE	 " + CRLF
	_cQry += " 		  FROM MOVIMENTACAO_ESTOQUE	 " + CRLF
	_cQry += " 		  GROUP BY TIPO	 " + CRLF
	_cQry += " 	  ORDER BY TIPO	 " + CRLF
	
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro_Resumo_Tipo.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
		

	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Tipo"		      	 , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quantidade"   	 	 , 1, 1 )
	///* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Serie"	    	 	 , 1, 1 )
	dbGotop()
	
	While !(cAlias)->(Eof())                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->TIPO, ;
							  (cAlias)->QUANTIDADE  })							  
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
Return



// Resumo da Movimentação
Static Function fQuadro12(cPerg)

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Resumo Filial-Tipo-Animal"
Local cTitulo	 := "Resumo por Filial, Tipo de Movimentação e Tipo de Animal"
cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)

	oExcel:AddworkSheet(cWorkSheet)
	oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry := " WITH NAS_MOR  " + CRLF
	_cQry += " 	AS ( " + CRLF
	_cQry += " 		SELECT D3.D3_FILIAL					FILIAL, " + CRLF
	_cQry += " 		  CASE WHEN D3_TM = '011'			THEN 'NASCIMENTO' " + CRLF
	_cQry += " 			   WHEN D3_TM = '511'			THEN 'MORTE' " + CRLF
	_cQry += " 											END AS TIPO, " + CRLF
	_cQry += " 			   B1.B1_DESC					ANIMAL, " + CRLF
	_cQry += " 			   SUM(D3.D3_QUANT)				QUANTIDADE " + CRLF
	_cQry += " 		 FROM "+RetSqlName("SD3")+"						D3 " + CRLF
	_cQry += "    INNER JOIN "+RetSqlName("SB1")+"						B1 " + CRLF
	_cQry += " 		   ON B1.B1_COD							=					D3.D3_COD " + CRLF
	_cQry += " 		  AND B1.D_E_L_E_T_						=					' '  " + CRLF
	_cQry += " 		 WHERE D3_TM							IN					('011','511') " + CRLF
	_cQry += " 		   AND D3.D3_EMISSAO				BETWEEN					'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += " 		   AND D3.D_E_L_E_T_					=					' '  " + CRLF
	_cQry += " 		   AND D3.D3_ESTORNO					<>					'S'  " + CRLF
	_cQry += " 	  GROUP BY D3.D3_FILIAL, D3.D3_TM, B1.B1_DESC " + CRLF
	_cQry += " 		), " + CRLF
	_cQry += " COMPRA  " + CRLF
	_cQry += " 		AS ( " + CRLF
	_cQry += " 			SELECT D1.D1_FILIAL					FILIAL,  " + CRLF
	_cQry += "				CASE WHEN D1_TIPO = 'N' THEN		'COMPRAS'  " + CRLF
	_cQry += "                  WHEN D1_TIPO = 'D' THEN		'DEV. COMPRAS'  " + CRLF							
	_cQry += "              	END AS TIPO,  " + CRLF
	_cQry += " 				   B1.B1_DESC					ANIMAL, " + CRLF
	_cQry += "   				   SUM(D1.D1_QUANT)				QUANTIDADE " + CRLF
	_cQry += "     		      FROM "+RetSqlName("SD1")+"						D1  " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SA2")+"						A2  " + CRLF
	_cQry += "   				ON A2.A2_COD					=			D1.D1_FORNECE  " + CRLF
	_cQry += "   			   AND A2.A2_LOJA					=			D1.D1_LOJA  " + CRLF
	_cQry += "   			   AND A2.D_E_L_E_T_				=			' '   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SB1")+"						B1  " + CRLF
	_cQry += "   				ON B1.B1_COD					=			D1.D1_COD  " + CRLF
	_cQry += "   			   AND B1.D_E_L_E_T_				=			' '   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SF4")+"						F4  " + CRLF
	_cQry += "   				ON F4.F4_CODIGO					=			D1.D1_TES  " + CRLF
	_cQry += "   			   AND F4.F4_TRANFIL				<>			'1'  " + CRLF
	_cQry += "   			   AND F4.D_E_L_E_T_				=			' '  " + CRLF
	_cQry += "   			 WHERE D1.D1_GRUPO					IN			('01','05','BOV')  " + CRLF
	_cQry += "   			   AND D1.D1_EMISSAO				BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   			   AND D1.D_E_L_E_T_				=			' '  " + CRLF
	_cQry += "   			   AND D1.D1_TIPO					IN			('N','D')  " + CRLF
	_cQry += "   		  GROUP BY D1.D1_FILIAL, D1.D1_TIPO, B1.B1_DESC " + CRLF
	_cQry += " 			), " + CRLF
	_cQry += " FATURAMENTO " + CRLF
	_cQry += " 		AS( " + CRLF
	_cQry += " 		    SELECT D2.D2_FILIAL							FILIAL, " + CRLF
	_cQry += " 				   'VENDA'								TIPO,	   " + CRLF
	_cQry += "   				   B1.B1_DESC							ANIMAL,   " + CRLF
	_cQry += "   				   SUM(D2.D2_QUANT)							QUANTIDADE   " + CRLF
	_cQry += "      		  FROM "+RetSqlName("SD2")+"	 D2   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SF4")+"	 F4   " + CRLF
	_cQry += "   				ON D2.D2_TES				=					F4.F4_CODIGO   " + CRLF
	_cQry += "   			   AND F4.D_E_L_E_T_			=					' '   " + CRLF
	_cQry += "   			   AND D2_ESTOQUE				=					'S'   " + CRLF
	_cQry += "   			   AND F4_TIPO					=					'S'   " + CRLF
	_cQry += "   			   AND F4_TRANFIL				=					'2'   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SA1")+"	 A1   " + CRLF
	_cQry += "   				ON A1.A1_COD				=					D2_CLIENTE   " + CRLF
	_cQry += "   			   AND A1.D_E_L_E_T_			=					' '   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SB1")+" 	 B1   " + CRLF
	_cQry += "   				ON B1.B1_COD				=					D2.D2_COD   " + CRLF
	_cQry += "   			   AND B1.D_E_L_E_T_			=					' '   " + CRLF
	_cQry += "   			 WHERE D2.D2_EMISSAO			BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   			   AND D2.D_E_L_E_T_			=					' '   " + CRLF
	_cQry += "   			   AND D2.D2_QUANT				>					0   " + CRLF
	_cQry += " 		  GROUP BY D2.D2_FILIAL, B1.B1_DESC " + CRLF
	_cQry += "   		  --ORDER BY D2.D2_EMISSAO   " + CRLF
	_cQry += " 		   ), " + CRLF
	_cQry += " TRANSF_FILIAIS AS" + CRLF
	_cQry += " 		( " + CRLF
	_cQry += " 			SELECT D1.D1_FILIAL					FILIAL, " + CRLF
	_cQry += " 			   'TRANSF. ENTRADA'			TIPO,   " + CRLF
	_cQry += "   			   B1.B1_DESC					ANIMAL, " + CRLF
	_cQry += " 			   SUM(D1.D1_QUANT)				QUANTIDADE " + CRLF
	_cQry += " 		  FROM "+RetSqlName("SD1")+"				D1 " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SF4")+"				F4   " + CRLF
	_cQry += "   			ON D1.D1_TES						=			F4.F4_CODIGO   " + CRLF
	_cQry += "   		   AND F4.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		   AND F4_TRANFIL						=			'1'   " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SBM")+"				BM   " + CRLF
	_cQry += "   			ON BM.BM_GRUPO						=			D1.D1_GRUPO   " + CRLF
	_cQry += "   		   AND BM.D_E_L_E_T_					=			' '	     " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SA2")+"				A2   " + CRLF
	_cQry += "   			ON A2.A2_COD						=			D1.D1_FORNECE   " + CRLF
	_cQry += "   		   AND A2.A2_LOJA						=			D1.D1_LOJA   " + CRLF
	_cQry += "   		   AND A2.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SB1")+"				B1   " + CRLF
	_cQry += "   			ON B1.B1_COD						=			D1.D1_COD   " + CRLF
	_cQry += "   		   AND B1.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		 WHERE D1_DTDIGIT						BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   		   AND D1.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		   AND D1.D1_GRUPO						IN			('01','05','BOV')   " + CRLF
	_cQry += "   		   AND D1.D1_QUANT						>			0   " + CRLF
	_cQry += "     GROUP BY D1.D1_FILIAL, B1.B1_DESC " + CRLF
	_cQry += "   		UNION ALL   " + CRLF
	_cQry += "   		SELECT D2.D2_FILIAL					FILIAL,   " + CRLF
	_cQry += " 			   'TRANSF. SAÍ„A'				TIPO,   " + CRLF
	_cQry += "   			   B1.B1_DESC					ANIMAL,   " + CRLF
	_cQry += "   			   SUM(D2.D2_QUANT)				QUANTIDADE  			    " + CRLF
	_cQry += "   		  FROM "+RetSqlName("SD2")+"		D2   " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SF4")+"		F4   " + CRLF
	_cQry += "   			ON D2.D2_TES						=			F4.F4_CODIGO   " + CRLF
	_cQry += "   		   AND F4.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		   AND F4_TRANFIL						=			'1'   " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SBM")+"		BM   " + CRLF
	_cQry += "   			ON BM.BM_GRUPO						=			D2.D2_GRUPO   " + CRLF
	_cQry += "   		   AND BM.D_E_L_E_T_					=			' '	     " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SA1")+"		A1   " + CRLF
	_cQry += "   			ON A1.A1_COD						=			D2.D2_CLIENTE   " + CRLF
	_cQry += "   		   AND A1.A1_LOJA						=			D2.D2_LOJA   " + CRLF
	_cQry += "   		   AND A1.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SB1")+"		B1   " + CRLF
	_cQry += "   			ON B1.B1_COD						=			D2.D2_COD   " + CRLF
	_cQry += "   		   AND B1.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		 WHERE D2_EMISSAO						BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   		   AND D2.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		   AND D2.D2_GRUPO						IN			('01','05','BOV')   " + CRLF
	_cQry += "   		   AND D2.D2_QUANT						>			0	   " + CRLF
	_cQry += " 		   GROUP BY D2.D2_FILIAL, B1.B1_DESC " + CRLF
	_cQry += " 		), " + CRLF
	_cQry += " MOVIMENTACAO_ESTOQUE " + CRLF
	_cQry += " 		AS ( " + CRLF
	_cQry += " 			SELECT D3.D3_FILIAL				FILIAL,   " + CRLF
	_cQry += "   	  CASE WHEN D3_TM < '499' THEN 'TM ENTRADA' " + CRLF
	_cQry += " 		   WHEN D3_TM >= '500' THEN 'TM SAIDA' " + CRLF
	_cQry += " 							END AS			TIPO, " + CRLF
	_cQry += "   			   B1.B1_DESC					ANIMAL,     " + CRLF
	_cQry += "   			   SUM(D3.D3_QUANT)				QUANTIDADE " + CRLF
	_cQry += "     		  FROM "+RetSqlName("SD3")+"	D3    " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SB1")+"	B1   " + CRLF
	_cQry += "   			ON B1.B1_COD					=				D3.D3_COD   " + CRLF
	_cQry += "   		   AND B1.D_E_L_E_T_				=				' '   " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SF5")+"	F5   " + CRLF
	_cQry += "   			ON F5.F5_CODIGO					=				D3.D3_TM   " + CRLF
	_cQry += "   		   AND F5.D_E_L_E_T_				=				' '    " + CRLF
	_cQry += "   		 WHERE D3_EMISSAO					BETWEEN			'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   		   AND D3_TM						NOT IN			('001','002','011','511','499','999')   " + CRLF
	_cQry += "   		   AND D3_GRUPO						IN				('01',',05','BOV')   " + CRLF
	_cQry += "   		   AND D3_QUANT						<>				0   " + CRLF
	_cQry += "   		   AND D3.D_E_L_E_T_				=				' '    " + CRLF
	_cQry += " 		   	   AND D3.D3_ESTORNO					<>				'S'  " + CRLF
	_cQry += " 	  GROUP BY D3.D3_FILIAL, D3.D3_TM, B1.B1_DESC )," + CRLF
	_cQry += " 	 	  FAT  AS (     	 " + CRLF
	_cQry += " 	     	SELECT DISTINCT D2_FILIAL FILIAL, 	 " + CRLF
	_cQry += " 				'ABATE' AS TIPO,    	 " + CRLF
	_cQry += " 	    	    --D2_XCODABT CODIGO_ABATE,     	 " + CRLF
	_cQry += " 	    		D2_LOTECTL LOTE,     	 " + CRLF
	_cQry += " 	    		D2_EMISSAO EMISSAO_NF,    	 " + CRLF
	_cQry += " 	    		B8_XDATACO DAT_INICIO,     	 " + CRLF
	_cQry += " 	    		B8_XPESOCO PESO_INICIO,      	 " + CRLF
	_cQry += " 	     		--ZBC_PESO,     	 " + CRLF
	_cQry += " 	     		D2_XDTABAT DATA_ABATE,      	 " + CRLF
	_cQry += " 	     		CASE WHEN B8_XDATACO = ' ' THEN 0 ELSE datediff(DAY, B8_XDATACO,D2_EMISSAO) END DIAS_CONF, " + CRLF
	_cQry += " 	     		CASE WHEN B8_XDATACO = ' ' THEN ' ' ELSE (ROUND((SUM(D2_XPESLIQ)/SUM(D2_QUANT)-B8_XPESOCO),3)  / CASE WHEN datediff(DAY, B8_XDATACO,D2_EMISSAO) = 0 THEN 1 ELSE datediff(DAY, B8_XDATACO,D2_EMISSAO) END) END GMD,    	 " + CRLF
	_cQry += " 	     		SUM(D2_XPESLIQ) PESO , SUM(D2_QUANT) QTD,      	 " + CRLF
	_cQry += " 	     		ROUND(SUM(D2_XPESLIQ)/SUM(D2_QUANT),2) PESO_MEDIO     	 " + CRLF
	_cQry += " 	     	FROM "+RetSqlName("SD2")+" D2     	 " + CRLF
	_cQry += " 	     	JOIN "+RetSqlName("SB8")+" B8 ON B8_PRODUTO = D2_COD      	 " + CRLF
	_cQry += " 	     	AND B8_LOTECTL = D2_LOTECTL     	 " + CRLF
	_cQry += " 	     	WHERE D2_XPESLIQ > 0       	 " + CRLF
	_cQry += " 	     	AND D2_XDTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' 	 " + CRLF
	_cQry += " 	     	AND D2.D_E_L_E_T_ = ' '  and B8.D_E_L_E_T_ = ' '      	 " + CRLF
	_cQry += " 	     	GROUP BY D2_FILIAL, D2_LOTECTL, D2_EMISSAO, D2_XDTABAT, B8_XDATACO, B8_XPESOCO     	 " + CRLF
	_cQry += " 	    ),    	 " + CRLF
	_cQry += " 	    ABATE AS (    	 " + CRLF
	_cQry += " 	     SELECT ZAB_FILIAL FILIAL,    	 " + CRLF
	_cQry += " 			    'ABATE' AS TIPO, 	 " + CRLF
	_cQry += " 	    	    ZAB_BAIA LOTE,        	 " + CRLF
	_cQry += " 	     		ZAB_DTABAT DATA_ABATE,     	 " + CRLF
	_cQry += " 	     		SUM(ZAB_PESOLQ) PESO_ABATE,     	 " + CRLF
	_cQry += " 	    		SUM(ZAB_QTABAT) QTD,    	 " + CRLF
	_cQry += " 	     		SUM(ZAB_VLRTOT) VALOR_TOTAL    	 " + CRLF
	_cQry += " 	    		FROM "+RetSqlName("ZAB")+"    	 " + CRLF
	_cQry += " 	    		WHERE ZAB_DTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' 	 " + CRLF
	_cQry += " 	    		AND ZAB010.D_E_L_E_T_ = ' '     	 " + CRLF
	_cQry += " 	    		GROUP BY ZAB_FILIAL, ZAB_BAIA, ZAB_DTABAT    	 " + CRLF
	_cQry += " 	    ),  	 " + CRLF
	_cQry += " 			 " + CRLF
	_cQry += " 	    FILIAISA AS (  	 " + CRLF
	_cQry += " 	    SELECT ZAB_FILIAL,'ABATE' AS TIPO, ZAB_CODIGO, ZAB_DTABAT, ZAB_PESOLQ, ZAB_VLRTOT   	 " + CRLF
	_cQry += " 	    FROM "+RetSqlName("ZAB")+"   	 " + CRLF
	_cQry += " 	    WHERE ZAB_FILIAL <> '01' AND ZAB_DTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' AND D_E_L_E_T_ = ' '   	 " + CRLF
	_cQry += " 	    ),  	 " + CRLF
	/*
	_cQry += " 	    FILIAISD2 AS (  	 " + CRLF
	_cQry += " 	    SELECT D2_FILIAL FILIAL, 'ABATE' AS TIPO,  D2_XCODABT, '' AS LOTE, '' AS EMISSAO_NF, '' DAT_INICIO, '' PESO_INICIO, '' DIAS_CONF, '' GMD,       	 " + CRLF
	_cQry += " 	          SUM(D2_XPESLIQ) PESO, SUM(D2_QUANT) QTD, ROUND(SUM(D2_XPESLIQ)/SUM(D2_QUANT),2) PESO_MEDIO   	 " + CRLF
	_cQry += " 	    FROM "+RetSqlName("SD2")+"   	 " + CRLF
	_cQry += " 	    WHERE D2_FILIAL <> '01' AND D2_XDTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'	 " + CRLF
	_cQry += " 	    GROUP BY D2_FILIAL, D2_XCODABT  	 " + CRLF
	_cQry += " 	    ),	 " + CRLF
	*/
	_cQry += " 		ABATEE AS (	 " + CRLF
	_cQry += " 	    SELECT F.FILIAL, 'ABATE' AS TIPO,F.LOTE, F.EMISSAO_NF, F.DAT_INICIO, F.PESO_INICIO, F.DATA_ABATE, F.DIAS_CONF, F.GMD, F.PESO, A.QTD, F.PESO_MEDIO, A.PESO_ABATE, A.VALOR_TOTAL    	 " + CRLF
	_cQry += " 	    FROM FAT F    	 " + CRLF
	_cQry += " 	    JOIN ABATE A ON    	 " + CRLF
	_cQry += " 	    F.FILIAL = A.FILIAL    	 " + CRLF
	_cQry += " 	    AND F.LOTE = A.LOTE    	 " + CRLF
	_cQry += " 	    AND F.DATA_ABATE = A.DATA_ABATE    	 " + CRLF
	_cQry += " 	   UNION   	 " + CRLF
	/*
	_cQry += " 	    SELECT FILIAL, 'ABATE' AS TIPO,'' AS LOTE, EMISSAO_NF, '' DAT_INICIO, '' PESO_INICIO, ZAB_DTABAT, '' DIAS_CONF, '' GMD, PESO, QTD, PESO_MEDIO,  ZAB_PESOLQ, ZAB_VLRTOT  	 " + CRLF
	_cQry += " 	   FROM FILIAISD2 SD2  	 " + CRLF
	_cQry += " 	   JOIN FILIAISA A  	 " + CRLF
	_cQry += " 	   ON SD2.FILIAL = A.ZAB_FILIAL  	 " + CRLF
	_cQry += " 	   AND SD2.D2_XCODABT = ZAB_CODIGO  	 " + CRLF
	_cQry += " 	   UNION ALL 	 " + CRLF
	*/
	_cQry += " 	    SELECT D2_FILIAL FILIAL, 'ABATE' AS TIPO, D2_LOTECTL LOTE, D2_EMISSAO, B8_XDATACO DATA_INICIO, B8_XPESOCO PESO_INICIO, D2_XDTABAT DATA_ABATE,     	 " + CRLF
	_cQry += " 	    CASE WHEN B8_XDATACO = ' ' THEN 0 ELSE datediff(DAY, B8_XDATACO,D2_EMISSAO) END DIAS_CONF, " + CRLF
	_cQry += "      CASE WHEN B8_XDATACO = ' ' THEN ' ' ELSE (ROUND((SUM(D2_XPESLIQ)/SUM(D2_QUANT)-B8_XPESOCO),3)  / CASE WHEN datediff(DAY, B8_XDATACO,D2_EMISSAO) = 0 THEN 1 ELSE datediff(DAY, B8_XDATACO,D2_EMISSAO) END) END GMD, " + CRLF
	_cQry += " 	    SUM(D2_XPESLIQ) PESO, SUM(D2_QUANT) QTD, SUM(D2_XPESLIQ)/SUM(D2_QUANT) PESO_MEDIO,    	 " + CRLF
	_cQry += " 	    ROUND(SUM(ZAB_PESOLQ)/SUM(ZAB_QTABAT),2)*SUM(D2_QUANT) PESO_ABATE,     	 " + CRLF
	_cQry += " 	    ROUND(SUM(ZAB_VLRTOT)/SUM(ZAB_QTABAT)*SUM(D2_QUANT),2) VALOR_TOTAL    	 " + CRLF
	_cQry += " 	    FROM ZAB010 AB    	 " + CRLF
	_cQry += " 	    JOIN SD2010 D2 ON    	 " + CRLF
	_cQry += " 	    D2.D2_XCODABT = ZAB_CODIGO     	 " + CRLF
	_cQry += " 	    AND D2.D2_XDTABAT = ZAB_DTABAT    	 " + CRLF
	_cQry += " 	    JOIN SB8010 ON     	 " + CRLF
	_cQry += " 	    B8_FILIAL = D2_FILIAL     	 " + CRLF
	_cQry += " 	    AND B8_PRODUTO = D2_COD     	 " + CRLF
	_cQry += " 	    AND B8_LOTECTL = D2_LOTECTL    	 " + CRLF
	_cQry += " 	    WHERE ZAB_DTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' 	 " + CRLF
	_cQry += " 	    AND ZAB_BAIA = ' '     	 " + CRLF
	_cQry += " 	    GROUP BY D2_FILIAL, D2_LOTECTL, D2_EMISSAO, B8_XDATACO, B8_XPESOCO, D2_XDTABAT, ZAB_CODIGO, ZAB_DTABAT    	 " + CRLF
	_cQry += " 		)	 " + CRLF
	_cQry += " 			 " + CRLF
	_cQry += " 			 " + CRLF
	_cQry += " SELECT * FROM COMPRA	" + CRLF
	_cQry += " UNION ALL 	" + CRLF
	_cQry += " SELECT * FROM NAS_MOR	" + CRLF
	_cQry += " UNION ALL	" + CRLF
	_cQry += " SELECT * FROM FATURAMENTO	" + CRLF
	_cQry += " UNION ALL 	" + CRLF
	_cQry += " SELECT * FROM TRANSF_FILIAIS	" + CRLF
	_cQry += " UNION ALL 	" + CRLF
	_cQry += " SELECT * FROM MOVIMENTACAO_ESTOQUE	" + CRLF
	_cQry += " ORDER BY FILIAL, TIPO	" + CRLF
	
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro_Filial_Tipo.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
		
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"     	 , 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Tipo"		   	 , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Animal"   	 	 , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quantidade" 	 , 1, 1 )
	///* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Serie"	    	 	 , 1, 1 )
	dbGotop()
	
	While !(cAlias)->(Eof())                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->FILIAL, ;
							  (cAlias)->TIPO, ;
							  (cAlias)->ANIMAL, ;
							  (cAlias)->QUANTIDADE  })							  
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
Return

// Resumo da Movimentação
Static Function fQuadro13(cPerg)

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Resumo Filial-Tipo"
Local cTitulo	 := "Resumo Movimentação por Filial e Tipo de Movimentação"

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)

	oExcel:AddworkSheet(cWorkSheet)
	oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry := " WITH NAS_MOR  " + CRLF
	_cQry += " 	AS ( " + CRLF
	_cQry += " 		SELECT D3.D3_FILIAL					FILIAL, " + CRLF
	_cQry += " 		  CASE WHEN D3_TM = '011'			THEN 'NASCIMENTO' " + CRLF
	_cQry += " 			   WHEN D3_TM = '511'			THEN 'MORTE' " + CRLF
	_cQry += " 											END AS TIPO, " + CRLF
	_cQry += " 			   B1.B1_DESC					ANIMAL, " + CRLF
	_cQry += " 			   SUM(D3.D3_QUANT)				QUANTIDADE " + CRLF
	_cQry += " 		 FROM "+RetSqlName("SD3")+"			D3 " + CRLF
	_cQry += "    INNER JOIN "+RetSqlName("SB1")+"		B1 " + CRLF
	_cQry += " 		   ON B1.B1_COD							=					D3.D3_COD " + CRLF
	_cQry += " 		  AND B1.D_E_L_E_T_						=					' '  " + CRLF
	_cQry += " 		 WHERE D3_TM							IN					('011','511') " + CRLF
	_cQry += " 		   AND D3.D3_EMISSAO				BETWEEN					'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += " 		   AND D3.D_E_L_E_T_					=					' '  " + CRLF
	_cQry += " 		   AND D3.D3_ESTORNO						<>					'S' " + CRLF
	_cQry += " 	  GROUP BY D3.D3_FILIAL, D3.D3_TM, B1.B1_DESC " + CRLF
	_cQry += " 		), " + CRLF
	_cQry += " COMPRA  " + CRLF
	_cQry += " 		AS ( " + CRLF
	_cQry += " 			SELECT D1.D1_FILIAL					FILIAL,  " + CRLF
	_cQry += "   			   CASE WHEN D1_TIPO = 'N' THEN		'COMPRAS' " + CRLF
	_cQry += "   			       WHEN D1_TIPO = 'D' THEN		'DEV. COMPRAS' " + CRLF
	_cQry += "   			   	END AS TIPO, " + CRLF
	_cQry += " 				   B1.B1_DESC					ANIMAL, " + CRLF
	_cQry += "   				   SUM(D1.D1_QUANT)				QUANTIDADE " + CRLF
	_cQry += "     		      FROM "+RetSqlName("SD1")+"		D1  " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SA2")+"		A2  " + CRLF
	_cQry += "   				ON A2.A2_COD					=			D1.D1_FORNECE  " + CRLF
	_cQry += "   			   AND A2.A2_LOJA					=			D1.D1_LOJA  " + CRLF
	_cQry += "   			   AND A2.D_E_L_E_T_				=			' '   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SB1")+"		B1  " + CRLF
	_cQry += "   				ON B1.B1_COD					=			D1.D1_COD  " + CRLF
	_cQry += "   			   AND B1.D_E_L_E_T_				=			' '   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SF4")+"		F4  " + CRLF
	_cQry += "   				ON F4.F4_CODIGO					=			D1.D1_TES  " + CRLF
	_cQry += "   			   AND F4.F4_TRANFIL				<>			'1'  " + CRLF
	_cQry += "   			   AND F4.D_E_L_E_T_				=			' '  " + CRLF
	_cQry += "   			 WHERE D1.D1_GRUPO					IN			('01','05','BOV')  " + CRLF
	_cQry += "   			   AND D1.D1_EMISSAO				BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   			   AND D1.D_E_L_E_T_				=			' '  " + CRLF
	_cQry += "   			   AND D1.D1_TIPO					IN			('N','D')  " + CRLF
	_cQry += "   		  GROUP BY D1.D1_FILIAL, D1.D1_TIPO, B1.B1_DESC " + CRLF
	_cQry += " 			), " + CRLF
	_cQry += " FATURAMENTO " + CRLF
	_cQry += " 		AS( " + CRLF
	_cQry += " 		    SELECT D2.D2_FILIAL							FILIAL, " + CRLF
	_cQry += " 				   'VENDA'								TIPO,	   " + CRLF
	_cQry += "   				   B1.B1_DESC							ANIMAL,   " + CRLF
	_cQry += "   				   SUM(D2.D2_QUANT)							QUANTIDADE   " + CRLF
	_cQry += "      		  FROM "+RetSqlName("SD2")+" 	 D2   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SF4")+"	 F4   " + CRLF
	_cQry += "   				ON D2.D2_TES				=					F4.F4_CODIGO   " + CRLF
	_cQry += "   			   AND F4.D_E_L_E_T_			=					' '   " + CRLF
	_cQry += "   			   AND D2_ESTOQUE				=					'S'   " + CRLF
	_cQry += "   			   AND F4_TIPO					=					'S'   " + CRLF
	_cQry += "   			   AND F4_TRANFIL				=					'2'   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SA1")+"	 A1   " + CRLF
	_cQry += "   				ON A1.A1_COD				=					D2_CLIENTE   " + CRLF
	_cQry += "   			   AND A1.D_E_L_E_T_			=					' '   " + CRLF
	_cQry += "   		INNER JOIN "+RetSqlName("SB1")+" 	 B1   " + CRLF
	_cQry += "   				ON B1.B1_COD				=					D2.D2_COD   " + CRLF
	_cQry += "   			   AND B1.D_E_L_E_T_			=					' '   " + CRLF
	_cQry += "   			 WHERE D2.D2_EMISSAO			BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   			   AND D2.D_E_L_E_T_			=					' '   " + CRLF
	_cQry += "   			   AND D2.D_E_L_E_T_			=					' '   " + CRLF
	_cQry += "   			   AND D2.D2_QUANT				>					0   " + CRLF
	_cQry += " 		  GROUP BY D2.D2_FILIAL, B1.B1_DESC " + CRLF
	_cQry += "   		  --ORDER BY D2.D2_EMISSAO   " + CRLF
	_cQry += " 		   ), " + CRLF
	_cQry += " TRANSF_FILIAIS AS" + CRLF
	_cQry += " 		( " + CRLF
	_cQry += " 			SELECT D1.D1_FILIAL					FILIAL, " + CRLF
	_cQry += " 			   'TRANSF. ENTRADA'			TIPO,   " + CRLF
	_cQry += "   			   B1.B1_DESC					ANIMAL, " + CRLF
	_cQry += " 			   SUM(D1.D1_QUANT)				QUANTIDADE " + CRLF
	_cQry += " 		  FROM "+RetSqlName("SD1")+"				D1 " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SF4")+"			F4   " + CRLF
	_cQry += "   			ON D1.D1_TES						=			F4.F4_CODIGO   " + CRLF
	_cQry += "   		   AND F4.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		   AND F4_TRANFIL						=			'1'   " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SBM")+"			BM   " + CRLF
	_cQry += "   			ON BM.BM_GRUPO						=			D1.D1_GRUPO   " + CRLF
	_cQry += "   		   AND BM.D_E_L_E_T_					=			' '	     " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SA2")+"				A2   " + CRLF
	_cQry += "   			ON A2.A2_COD						=			D1.D1_FORNECE   " + CRLF
	_cQry += "   		   AND A2.A2_LOJA						=			D1.D1_LOJA   " + CRLF
	_cQry += "   		   AND A2.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SB1")+"			B1   " + CRLF
	_cQry += "   			ON B1.B1_COD						=			D1.D1_COD   " + CRLF
	_cQry += "   		   AND B1.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		 WHERE D1_DTDIGIT						BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   		   AND D1.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		   AND D1.D1_GRUPO						IN			('01','05','BOV')   " + CRLF
	_cQry += "   		   AND D1.D1_QUANT						>			0   " + CRLF
	_cQry += "     GROUP BY D1.D1_FILIAL, B1.B1_DESC " + CRLF
	_cQry += "   		UNION ALL   " + CRLF
	_cQry += "   		SELECT D2.D2_FILIAL					FILIAL,   " + CRLF
	_cQry += " 			   'TRANSF. SAÍ„A'				TIPO,   " + CRLF
	_cQry += "   			   B1.B1_DESC					ANIMAL,   " + CRLF
	_cQry += "   			   SUM(D2.D2_QUANT)				QUANTIDADE  			    " + CRLF
	_cQry += "   		  FROM "+RetSqlName("SD2")+"		D2   " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SF4")+"		F4   " + CRLF
	_cQry += "   			ON D2.D2_TES						=			F4.F4_CODIGO   " + CRLF
	_cQry += "   		   AND F4.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		   AND F4_TRANFIL						=			'1'   " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SBM")+"		BM   " + CRLF
	_cQry += "   			ON BM.BM_GRUPO						=			D2.D2_GRUPO   " + CRLF
	_cQry += "   		   AND BM.D_E_L_E_T_					=			' '	     " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SA1")+"		A1   " + CRLF
	_cQry += "   			ON A1.A1_COD						=			D2.D2_CLIENTE   " + CRLF
	_cQry += "   		   AND A1.A1_LOJA						=			D2.D2_LOJA   " + CRLF
	_cQry += "   		   AND A1.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SB1")+"		B1   " + CRLF
	_cQry += "   			ON B1.B1_COD						=			D2.D2_COD   " + CRLF
	_cQry += "   		   AND B1.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		 WHERE D2_EMISSAO						BETWEEN		'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   		   AND D2.D_E_L_E_T_					=			' '    " + CRLF
	_cQry += "   		   AND D2.D2_GRUPO						IN			('01','05','BOV')   " + CRLF
	_cQry += "   		   AND D2.D2_QUANT						>			0	   " + CRLF
	_cQry += " 		   GROUP BY D2.D2_FILIAL, B1.B1_DESC " + CRLF
	_cQry += " 		), " + CRLF
	_cQry += " MOVIMENTACAO_ESTOQUE " + CRLF
	_cQry += " 		AS ( " + CRLF
	_cQry += " 			SELECT D3.D3_FILIAL				FILIAL,   " + CRLF
	_cQry += "   	  CASE WHEN D3_TM < '499' THEN 'TM ENTRADA' " + CRLF
	_cQry += " 		   WHEN D3_TM >= '500' THEN 'TM SAIDA' " + CRLF
	_cQry += " 							END AS			TIPO, " + CRLF
	_cQry += "   			   B1.B1_DESC					ANIMAL,     " + CRLF
	_cQry += "   			   SUM(D3.D3_QUANT)				QUANTIDADE " + CRLF
	_cQry += "     		  FROM "+RetSqlName("SD3")+"	D3    " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SB1")+"	B1   " + CRLF
	_cQry += "   			ON B1.B1_COD					=				D3.D3_COD   " + CRLF
	_cQry += "   		   AND B1.D_E_L_E_T_				=				' '   " + CRLF
	_cQry += "   	INNER JOIN "+RetSqlName("SF5")+"	F5   " + CRLF
	_cQry += "   			ON F5.F5_CODIGO					=				D3.D3_TM   " + CRLF
	_cQry += "   		   AND F5.D_E_L_E_T_				=				' '    " + CRLF
	_cQry += "   		 WHERE D3_EMISSAO					BETWEEN			'"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "   		   AND D3_TM						NOT IN			('001','002','011','511','499','999')   " + CRLF
	_cQry += "   		   AND D3_GRUPO						IN				('01',',05','BOV')   " + CRLF
	_cQry += "   		   AND D3_QUANT						<>				0   " + CRLF
	_cQry += "   		   AND D3.D_E_L_E_T_				=				' '    " + CRLF
	_cQry += " 		   	   AND D3.D3_ESTORNO					<>				'S' " + CRLF
	_cQry += " 	  GROUP BY D3.D3_FILIAL, D3.D3_TM, B1.B1_DESC )," + CRLF
	_cQry += " 	 	  FAT  AS (     	 " + CRLF
	_cQry += " 	     	SELECT DISTINCT D2_FILIAL FILIAL, 	 " + CRLF
	_cQry += " 				'ABATE' AS TIPO,    	 " + CRLF
	_cQry += " 	    	    --D2_XCODABT CODIGO_ABATE,     	 " + CRLF
	_cQry += " 	    		D2_LOTECTL LOTE,     	 " + CRLF
	_cQry += " 	    		D2_EMISSAO EMISSAO_NF,    	 " + CRLF
	_cQry += " 	    		B8_XDATACO DAT_INICIO,     	 " + CRLF
	_cQry += " 	    		B8_XPESOCO PESO_INICIO,      	 " + CRLF
	_cQry += " 	     		--ZBC_PESO,     	 " + CRLF
	_cQry += " 	     		D2_XDTABAT DATA_ABATE,      	 " + CRLF
	_cQry += " 	     		CASE WHEN B8_XDATACO = ' ' THEN 0 ELSE datediff(DAY, B8_XDATACO,D2_EMISSAO) END DIAS_CONF, " + CRLF
	_cQry += " 	     		CASE WHEN B8_XDATACO = ' ' THEN ' ' ELSE (ROUND((SUM(D2_XPESLIQ)/SUM(D2_QUANT)-B8_XPESOCO),3)  / CASE WHEN datediff(DAY, B8_XDATACO,D2_EMISSAO) = 0 THEN 1 ELSE datediff(DAY, B8_XDATACO,D2_EMISSAO) END) END GMD, 	 " + CRLF
	_cQry += " 	     		SUM(D2_XPESLIQ) PESO , SUM(D2_QUANT) QTD,      	 " + CRLF
	_cQry += " 	     		ROUND(SUM(D2_XPESLIQ)/SUM(D2_QUANT),2) PESO_MEDIO     	 " + CRLF
	_cQry += " 	     	FROM "+RetSqlName("SD2")+" D2     	 " + CRLF
	_cQry += " 	     	JOIN "+RetSqlName("SB8")+" B8 ON B8_PRODUTO = D2_COD      	 " + CRLF
	_cQry += " 	     	AND B8_LOTECTL = D2_LOTECTL     	 " + CRLF
	_cQry += " 	     	WHERE D2_XPESLIQ > 0       	 " + CRLF
	_cQry += " 	     	AND D2_XDTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' 	 " + CRLF
	_cQry += " 	     	AND D2.D_E_L_E_T_ = ' '  and B8.D_E_L_E_T_ = ' '      	 " + CRLF
	_cQry += " 	     	GROUP BY D2_FILIAL, D2_LOTECTL, D2_EMISSAO, D2_XDTABAT, B8_XDATACO, B8_XPESOCO     	 " + CRLF
	_cQry += " 	    ),    	 " + CRLF
	_cQry += " 	    ABATE AS (    	 " + CRLF
	_cQry += " 	     SELECT ZAB_FILIAL FILIAL,    	 " + CRLF
	_cQry += " 			    'ABATE' AS TIPO, 	 " + CRLF
	_cQry += " 	    	    ZAB_BAIA LOTE,        	 " + CRLF
	_cQry += " 	     		ZAB_DTABAT DATA_ABATE,     	 " + CRLF
	_cQry += " 	     		SUM(ZAB_PESOLQ) PESO_ABATE,     	 " + CRLF
	_cQry += " 	    		SUM(ZAB_QTABAT) QTD,    	 " + CRLF
	_cQry += " 	     		SUM(ZAB_VLRTOT) VALOR_TOTAL    	 " + CRLF
	_cQry += " 	    		FROM "+RetSqlName("ZAB")+"    	 " + CRLF
	_cQry += " 	    		WHERE ZAB_DTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' 	 " + CRLF
	_cQry += " 	    		AND ZAB010.D_E_L_E_T_ = ' '     	 " + CRLF
	_cQry += " 	    		GROUP BY ZAB_FILIAL, ZAB_BAIA, ZAB_DTABAT    	 " + CRLF
	_cQry += " 	    ),  	 " + CRLF
	_cQry += " 			 " + CRLF
	_cQry += " 	    FILIAISA AS (  	 " + CRLF
	_cQry += " 	    SELECT ZAB_FILIAL,'ABATE' AS TIPO, ZAB_CODIGO, ZAB_DTABAT, ZAB_PESOLQ, ZAB_VLRTOT   	 " + CRLF
	_cQry += " 	    FROM "+RetSqlName("ZAB")+"   	 " + CRLF
	_cQry += " 	    WHERE ZAB_FILIAL <> '01' AND ZAB_DTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' AND D_E_L_E_T_ = ' '   	 " + CRLF
	_cQry += " 	    ),  	 " + CRLF
	/*
	_cQry += " 	    FILIAISD2 AS (  	 " + CRLF
	_cQry += " 	    SELECT D2_FILIAL FILIAL, 'ABATE' AS TIPO,  D2_XCODABT, '' AS LOTE, '' AS EMISSAO_NF, '' DAT_INICIO, '' PESO_INICIO, '' DIAS_CONF, '' GMD,       	 " + CRLF
	_cQry += " 	          SUM(D2_XPESLIQ) PESO, SUM(D2_QUANT) QTD, ROUND(SUM(D2_XPESLIQ)/SUM(D2_QUANT),2) PESO_MEDIO   	 " + CRLF
	_cQry += " 	    FROM "+RetSqlName("SD2")+"   	 " + CRLF
	_cQry += " 	    WHERE D2_FILIAL <> '01' AND D2_XDTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'	 " + CRLF
	_cQry += " 	    GROUP BY D2_FILIAL, D2_XCODABT  	 " + CRLF
	_cQry += " 	    ),	 " + CRLF
	*/
	_cQry += " 		ABATEE AS (	 " + CRLF
	_cQry += " 	    SELECT F.FILIAL, 'ABATE' AS TIPO,F.LOTE, F.EMISSAO_NF, F.DAT_INICIO, F.PESO_INICIO, F.DATA_ABATE, F.DIAS_CONF, F.GMD, F.PESO, A.QTD, F.PESO_MEDIO, A.PESO_ABATE, A.VALOR_TOTAL    	 " + CRLF
	_cQry += " 	    FROM FAT F    	 " + CRLF
	_cQry += " 	    JOIN ABATE A ON    	 " + CRLF
	_cQry += " 	    F.FILIAL = A.FILIAL    	 " + CRLF
	_cQry += " 	    AND F.LOTE = A.LOTE    	 " + CRLF
	_cQry += " 	    AND F.DATA_ABATE = A.DATA_ABATE    	 " + CRLF
	_cQry += " 	   UNION   	 " + CRLF
	/*
	_cQry += " 	    SELECT FILIAL, 'ABATE' AS TIPO,'' AS LOTE, EMISSAO_NF, '' DAT_INICIO, '' PESO_INICIO, ZAB_DTABAT, '' DIAS_CONF, '' GMD, PESO, QTD, PESO_MEDIO,  ZAB_PESOLQ, ZAB_VLRTOT  	 " + CRLF
	_cQry += " 	   FROM FILIAISD2 SD2  	 " + CRLF
	_cQry += " 	   JOIN FILIAISA A  	 " + CRLF
	_cQry += " 	   ON SD2.FILIAL = A.ZAB_FILIAL  	 " + CRLF
	_cQry += " 	   AND SD2.D2_XCODABT = ZAB_CODIGO  	 " + CRLF
	_cQry += " 	   UNION ALL 	 " + CRLF
	*/
	_cQry += " 	    SELECT D2_FILIAL FILIAL, 'ABATE' AS TIPO, D2_LOTECTL LOTE, D2_EMISSAO, B8_XDATACO DATA_INICIO, B8_XPESOCO PESO_INICIO, D2_XDTABAT DATA_ABATE,     	 " + CRLF
	_cQry += " 	    CASE WHEN B8_XDATACO = ' ' THEN 0 ELSE datediff(DAY, B8_XDATACO,D2_EMISSAO) END DIAS_CONF, " + CRLF
	_cQry += "      CASE WHEN B8_XDATACO = ' ' THEN ' ' ELSE (ROUND((SUM(D2_XPESLIQ)/SUM(D2_QUANT)-B8_XPESOCO),3)  / CASE WHEN datediff(DAY, B8_XDATACO,D2_EMISSAO) = 0 THEN 1 ELSE datediff(DAY, B8_XDATACO,D2_EMISSAO) END) END GMD,  " + CRLF
	_cQry += " 	    SUM(D2_XPESLIQ) PESO, SUM(D2_QUANT) QTD, SUM(D2_XPESLIQ)/SUM(D2_QUANT) PESO_MEDIO,    	 " + CRLF
	_cQry += " 	    ROUND(SUM(ZAB_PESOLQ)/SUM(ZAB_QTABAT),2)*SUM(D2_QUANT) PESO_ABATE,     	 " + CRLF
	_cQry += " 	    ROUND(SUM(ZAB_VLRTOT)/SUM(ZAB_QTABAT)*SUM(D2_QUANT),2) VALOR_TOTAL    	 " + CRLF
	_cQry += " 	    FROM ZAB010 AB    	 " + CRLF
	_cQry += " 	    JOIN SD2010 D2 ON    	 " + CRLF
	_cQry += " 	    D2.D2_XCODABT = ZAB_CODIGO     	 " + CRLF
	_cQry += " 	    AND D2.D2_XDTABAT = ZAB_DTABAT    	 " + CRLF
	_cQry += " 	    JOIN SB8010 ON     	 " + CRLF
	_cQry += " 	    B8_FILIAL = D2_FILIAL     	 " + CRLF
	_cQry += " 	    AND B8_PRODUTO = D2_COD     	 " + CRLF
	_cQry += " 	    AND B8_LOTECTL = D2_LOTECTL    	 " + CRLF
	_cQry += " 	    WHERE ZAB_DTABAT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' 	 " + CRLF
	_cQry += " 	    AND ZAB_BAIA = ' '     	 " + CRLF
	_cQry += " 	    GROUP BY D2_FILIAL, D2_LOTECTL, D2_EMISSAO, B8_XDATACO, B8_XPESOCO, D2_XDTABAT, ZAB_CODIGO, ZAB_DTABAT    	 " + CRLF
	_cQry += " 		)	 " + CRLF
	_cQry += " 			 " + CRLF
	_cQry += " 			 " + CRLF
	_cQry += "      SELECT FILIAL, TIPO, SUM(QUANTIDADE) QUANTIDADE " + CRLF
	_cQry += " 	      FROM NAS_MOR " + CRLF
	_cQry += " 	  GROUP BY FILIAL, TIPO " + CRLF
	_cQry += " 		 UNION ALL " + CRLF
	_cQry += " 		SELECT FILIAL, TIPO, SUM(QUANTIDADE) QUANTIDADE " + CRLF
	_cQry += " 		  FROM COMPRA " + CRLF
	_cQry += " 	  GROUP BY FILIAL, TIPO " + CRLF
	_cQry += " 		UNION ALL " + CRLF
	_cQry += "      SELECT FILIAL, TIPO, SUM(QTD) QUANTIDADE" + CRLF	 
 	_cQry += "            FROM ABATEE 	 " + CRLF
 	_cQry += "        GROUP BY FILIAL, TIPO	 " + CRLF
 	_cQry += "          UNION ALL 	" + CRLF
	_cQry += " 		SELECT FILIAL, TIPO, SUM(QUANTIDADE) QUANTIDADE " + CRLF
	_cQry += " 	      FROM FATURAMENTO  " + CRLF
	_cQry += " 	  GROUP BY FILIAL, TIPO " + CRLF
	_cQry += " 	    UNION ALL " + CRLF
	_cQry += " 	    SELECT FILIAL, TIPO, SUM(QUANTIDADE) QUANTIDADE " + CRLF
	_cQry += " 		  FROM TRANSF_FILIAIS " + CRLF
	_cQry += " 		  GROUP BY FILIAL, TIPO " + CRLF
	_cQry += " 		UNION ALL " + CRLF
	_cQry += " 		SELECT FILIAL, TIPO, SUM(QUANTIDADE) QUANTIDADE " + CRLF
	_cQry += " 		  FROM MOVIMENTACAO_ESTOQUE " + CRLF
	_cQry += " 	  GROUP BY FILIAL, TIPO " + CRLF
	_cQry += " 	  ORDER BY TIPO " + CRLF
	
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro_Filial_Tipo1.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	//TcSetField(cAlias, "EMISSAO", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"  		 	 , 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Tipo"		      	 , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quantidade"   	 	 , 1, 1 )
	///* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Serie"	    	 	 , 1, 1 )
	dbGotop()
	
	While !(cAlias)->(Eof())                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->FILIAL, ;
							  (cAlias)->TIPO, ;
							  (cAlias)->QUANTIDADE  })							  
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
Return


/* 
	MJ : 09.04.2019
		Relatorio para o Canela;
			Analisar a chegada dos animais na agropecuaria;
*/
Static Function fQuadro14()

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Recebimento Gados"
Local cTitulo	 := "Recebimento dos animais na agropecuaria"

	cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)

	oExcel:AddworkSheet(cWorkSheet)
	oExcel:AddTable(  cWorkSheet, cTitulo)


_cQry += "WITH" + CRLF
_cQry += "	DADOS AS (" + CRLF
_cQry += "		SELECT  ZCC_CODIGO, ZCC_DTCONT, ZCC_NOMCOR, ZCC_NOMFOR, ZCC_DISTES" + CRLF
_cQry += "				, C7_EMISSAO" + CRLF
_cQry += "				, ZBC_FILIAL, ZBC_PEDIDO, ZBC_ITEMPC, ZBC_PRODUT, ZBC_SEXO, ZBC_QUANT, ZBC_PESO, ZBC_DTENTR, ZBC_DTVCTO" + CRLF
_cQry += "				, D1_FILIAL, D1_COD, D1_QUANT, D1_EMISSAO" + CRLF
_cQry += "		FROM	ZCC010 CC" + CRLF
_cQry += "		   JOIN ZBC010 BC ON ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO " + CRLF
_cQry += "								AND CC.D_E_L_E_T_=' ' AND BC.D_E_L_E_T_=' '" + CRLF
_cQry += "		   JOIN SC7010 C7 ON C7_FILIAL=ZBC_FILIAL AND C7_NUM=ZBC_PEDIDO " + CRLF
_cQry += "								AND C7_PRODUTO=ZBC_PRODUT AND C7_ITEM=ZBC_ITEMPC " + CRLF
_cQry += "								AND C7.D_E_L_E_T_=' '" + CRLF
_cQry += "	  LEFT JOIN SD1010 D1 ON  D1_FILIAL  = ZBC_FILIAL" + CRLF
_cQry += "								AND D1_PEDIDO  = ZBC_PEDIDO" + CRLF
_cQry += "								AND D1_ITEMPC  = ZBC_ITEMPC" + CRLF
_cQry += "								AND D1_COD     = ZBC_PRODUT" + CRLF
_cQry += "								AND D1.D_E_L_E_T_=' '" + CRLF
_cQry += "		WHERE ISNULL(D1_EMISSAO, ZBC_DTENTR) BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' 	 " + CRLF
_cQry += "	)" + CRLF
_cQry += "" + CRLF
_cQry += "	, AGRUPADO AS (" + CRLF
_cQry += "		SELECT " + CRLF
_cQry += "			-- CASE WHEN ZBC_DTENTR<>' '" + CRLF
_cQry += "			-- 		THEN ZBC_DTENTR" + CRLF
_cQry += "			-- 		ELSE D1_EMISSAO" + CRLF
_cQry += "			-- END" + CRLF
_cQry += "			isnull(D1_EMISSAO, ZBC_DTENTR)'Data_Recebimento'" + CRLF
_cQry += "			, ZCC_NOMCOR				'Corretor'" + CRLF
_cQry += "			, ZCC_NOMFOR				'Fornecedor'" + CRLF
_cQry += "			, CASE WHEN ZBC_SEXO='M' " + CRLF
_cQry += "					THEN 'MACHO'" + CRLF
_cQry += "					ELSE 'FEMEA' " + CRLF
_cQry += "			END							'Sexo'" + CRLF
_cQry += "			, SUM(ZBC_QUANT)			'Quant_Contrato'" + CRLF
_cQry += "			, isnull(SUM(D1_QUANT),0)	'Quant_NF_Recebida'" + CRLF
_cQry += "			-- , SUM(D1_QUANT) D1_QUANT" + CRLF
_cQry += "			, SUM(ZBC_QUANT)-isnull(SUM(D1_QUANT),0)  'Falta_Receber'" + CRLF
_cQry += "			, SUM(ZBC_PESO)				'Peso'" + CRLF
_cQry += "			, ZCC_DISTES				'Distancia'" + CRLF
_cQry += "		FROM DADOS" + CRLF
_cQry += "		GROUP BY--   CASE WHEN ZBC_DTENTR<>' '" + CRLF
_cQry += "				-- 		THEN ZBC_DTENTR" + CRLF
_cQry += "				-- 		ELSE D1_EMISSAO" + CRLF
_cQry += "				-- END				" + CRLF
_cQry += "				isnull(D1_EMISSAO, ZBC_DTENTR)" + CRLF
_cQry += "				, ZCC_NOMCOR			" + CRLF
_cQry += "				, ZCC_NOMFOR			" + CRLF
_cQry += "				, ZBC_SEXO" + CRLF
_cQry += "				, ZCC_DISTES" + CRLF
_cQry += "	)" + CRLF
_cQry += "" + CRLF
_cQry += "	SELECT " + CRLF
_cQry += "	  CONVERT(DATE,Data_Recebimento) Data_Recebimento" + CRLF
_cQry += "	, Corretor" + CRLF
_cQry += "	, Fornecedor" + CRLF
_cQry += "	, Sexo" + CRLF
_cQry += "	, Quant_Contrato" + CRLF
_cQry += "	, Quant_NF_Recebida" + CRLF
_cQry += "	, Falta_Receber" + CRLF
_cQry += "	, Peso" + CRLF
_cQry += "	, Distancia" + CRLF
_cQry += "	FROM AGRUPADO" + CRLF

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
	MemoWrite(StrTran(cArquivo,".xml","")+"Quadro_Recebimento.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Recebimento"  , 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Corretor"		    , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Fornecedor"   	 	, 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Sexo"   	 	 	, 1, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quant. Contrato"   , 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quant. NF/Recebida", 1, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Saldo a Receber"   , 1, 1 )
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso"   	 	 	, 1, 1 )
	/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Distancia"   	 	, 1, 1 )
	
	While !(cAlias)->(Eof())                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->Data_Recebimento, ;
							  (cAlias)->Corretor, ;
							  (cAlias)->Fornecedor,;
							  (cAlias)->Sexo,;
							  (cAlias)->Quant_Contrato,;
							  (cAlias)->Quant_NF_Recebida,;
							  (cAlias)->Falta_Receber,;
							  (cAlias)->Peso,;
							  (cAlias)->Distancia })							  
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
	
Return nil
