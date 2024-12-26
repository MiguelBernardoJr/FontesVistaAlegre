#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"


user function VACTBA01()
	
	
Private cPerg := nil

	
	cPerg      :="VACTBA01""
	//nLastKey := 0
	//wnrel    := "VAEST022"
	_cQry	 :=""

	ValidPerg(cPerg)
	
	While Pergunte(cPerg, .T.)
		MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
	Enddo

	
return

Static Function ValidPerg(cPerg)
Local _sAlias,i,j

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}                                                  

	AADD(aRegs,{cPerg,"01","Filial de            ?",Space(20),Space(20),"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})
	AADD(aRegs,{cPerg,"02","Filial Ate            ?",Space(20),Space(20),"mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})
	AADD(aRegs,{cPerg,"03","Data de         	   ?",Space(20),Space(20),"mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Data até          	   ?",Space(20),Space(20),"mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	

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
Private cArquivo  := GetTempPath()+'VACTBA01_'+StrTran(dToC(dDataBase), '/', '-')+'.xml'
oExcel:SetFont('Arial Narrow')
oExcel:SetBgColorHeader("#37752F") // cor de fundo linha cabeçalho
oExcel:SetLineBgColor("#FFFFFF")   // cor da linha 1
oExcel:Set2LineBgColor("#FFFFFF")  // cor da linha 2

fQuadro1(cPerg)


	oExcel:Activate()
	oExcel:GetXMLFile(cArquivo)
			
	//Abrindo o excel e abrindo o arquivo xml
	oExcelApp := MsExcel():New() 			//Abre uma nova conexão com Excel
	oExcelApp:WorkBooks:Open(cArquivo) 		//Abre uma planilha
	oExcelApp:SetVisible(.T.) 				//Visualiza a planilha
	oExcelApp:Destroy()						//Encerra o processo do gerenciador de tarefas
	
Return 



Static Function fQuadro1(cPerg)

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Detalhes do Produto - Livro"
Local cTitulo	 := "Detalhamento do Registro C170 "
cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)
oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry := "  		SELECT DISTINCT(FT_NFISCAL)								AS NUM_NF,  " + CRLF
	_cQry += "  			   FT_SERIE											AS SERIE_NF,  " + CRLF
	_cQry += "  			   CASE WHEN FT_TIPOMOV = 'E' THEN 'SA201'+FT_CLIEFOR+FT_LOJA  " + CRLF
	_cQry += "  				    WHEN FT_TIPOMOV = 'S' THEN 'SA101'+FT_CLIEFOR+FT_LOJA  " + CRLF
	_cQry += "  					ELSE 'VERIFICAR'						END AS COD_PART,  " + CRLF
	_cQry += "  			   FT_CHVNFE										AS CHV_NFE,  " + CRLF
	_cQry += "			       FT_OBSERV										AS OBSERVACAO,  " + CRLF
	_cQry += "			       SUBSTRING(B1_POSIPI,1,2) 						AS COD_GEN,  " + CRLF 									
	_cQry += "				   CASE WHEN B1_TIPO = 'ME ' THEN '00'  " + CRLF
	_cQry += "                 		WHEN B1_TIPO = 'MP ' THEN '01'  " + CRLF
	_cQry += "                 		WHEN B1_TIPO = 'EM ' THEN '02'  " + CRLF
	_cQry += "                 		WHEN B1_TIPO = 'PP ' THEN '03'  " + CRLF
	_cQry += "                 		WHEN B1_TIPO = 'PA ' THEN '04'  " + CRLF
	_cQry += "                 		WHEN B1_TIPO = 'SP ' THEN '05'  " + CRLF
	_cQry += "                 		WHEN B1_TIPO = 'PI ' THEN '06'  " + CRLF
	_cQry += "                 		WHEN B1_TIPO = 'OI ' THEN '10'  " + CRLF
	_cQry += "                 		WHEN B1_TIPO = 'MC ' THEN '07'  " + CRLF
	_cQry += "                 		WHEN B1_TIPO = 'AI ' THEN '08'  " + CRLF
	_cQry += "                 		WHEN B1_TIPO = 'MO ' THEN '09'  " + CRLF
	_cQry += "                  ELSE '99'   " + CRLF
	_cQry += "                   					  				        END AS TIPO_ITEM,  " + CRLF
	_cQry += "  			   FT_ENTRADA										AS DATA_ENTRADA,  " + CRLF
	_cQry += "  			   FT_ITEM											AS ITEM,  " + CRLF
	_cQry += "  			   FT_FRETE											AS FRETE,  " + CRLF
	
	_cQry += "  			   /*01*/ 'C170'									AS REG,  " + CRLF
	_cQry += "  			   /*02*/ CASE WHEN FT_TIPOMOV = 'E' THEN '0'  " + CRLF
	_cQry += "  			               WHEN FT_TIPOMOV = 'S' THEN '1'  " + CRLF
	_cQry += "  						ELSE 'VERIFICAR'					END AS IND_OPER,  " + CRLF
	_cQry += "  			   /*03*/ FT_PRODUTO								AS COD_ITEM,  " + CRLF
	_cQry += "  			   /*04*/ B1_DESC									AS DESC_COMPL,  " + CRLF
	_cQry += "  			   /*05*/ FT_QUANT									AS QTD,  " + CRLF
	_cQry += "  			   /*06*/ CASE WHEN FT_TIPOMOV = 'E' THEN D1_UM  " + CRLF
	_cQry += "  					       WHEN FT_TIPOMOV = 'S' THEN D2_UM  " + CRLF
	_cQry += "  					  ELSE 'VERIFICAR'					END AS UNID,  " + CRLF
	_cQry += "    " + CRLF
	_cQry += "  			   /*07*/ FT_TOTAL								AS VL_ITEM,  " + CRLF
	_cQry += "  			   /*08*/ FT_DESCONT							AS VL_DESC,  " + CRLF
	_cQry += "  			   /*09*/ CASE WHEN FT_ESTOQUE = 'S' THEN '0'  " + CRLF
	_cQry += "  						   WHEN FT_ESTOQUE = 'N' THEN '1'  " + CRLF
	_cQry += "  					ELSE 'VERIFICAR'				    END	AS IND_MOV,  " + CRLF
	_cQry += "  			   /*10*/ FT_CLASFIS							AS CST_ICMS,  " + CRLF
	_cQry += "  			   /*11*/ FT_CFOP								AS CFOP,  " + CRLF
	_cQry += "  			   /*12*/ FT_NATOPER							AS COD_NAT,  " + CRLF
	_cQry += "  			   /*13*/ FT_BASEICM							AS VL_BC_ICMS,  " + CRLF
	_cQry += "  			   /*14*/ FT_ALIQICM							AS ALIQ_ICMS,  " + CRLF
	_cQry += "  			   /*15*/ FT_VALICM								AS VL_ICMS,  " + CRLF
	_cQry += "  			   /*25*/ FT_CSTPIS								AS CST_PIS,  " + CRLF
	_cQry += "  			   /*26*/ FT_BASEPIS							AS VL_BC_PIS,  " + CRLF
	_cQry += "  			   /*27*/ FT_ALIQPIS							AS ALIQ_PIS,  " + CRLF
	_cQry += "  			   /*28*/ FT_QUANT								AS QUANT_BC_PIS,  " + CRLF
	_cQry += "  			   /*29*/ FT_PAUTPIS							AS ALIQ_PIS,  " + CRLF
	_cQry += "  			   /*30*/ FT_VALPIS								AS VL_PIS,  " + CRLF
	_cQry += "  			   /*31*/ FT_CSTCOF								AS CST_COFINS,  " + CRLF
	_cQry += "  			   /*32*/ FT_BASECOF							AS VL_BC_COFINS,  " + CRLF
	_cQry += "  			   /*33*/ FT_ALIQCOF							AS ALIQ_COFINS,  " + CRLF
    _cQry += "  			   /*34*/ FT_QUANT								AS QUANT_BC_COFINS,  " + CRLF
    _cQry += "  			   /*35*/ FT_PAUTCOF							AS ALIQ_COFINS,  " + CRLF
    _cQry += "  			   /*36*/ FT_VALCOF								AS VL_COFINS,  " + CRLF
    _cQry += "  			   /*37*/ FT_CONTA								AS COD_CTA  " + CRLF
    _cQry += "     " + CRLF
    _cQry += "  		  FROM SFT010 FT  " + CRLF
    _cQry += "      INNER JOIN SB1010 B1  " + CRLF
    _cQry += "  			ON B1_COD					=					FT_PRODUTO  " + CRLF
    _cQry += "  		   AND B1.D_E_L_E_T_			=					' '   " + CRLF
    _cQry += "  	 LEFT JOIN SD1010 D1  " + CRLF
    _cQry += "  			ON D1_FORNECE				=					FT_CLIEFOR  " + CRLF
    _cQry += "  		   AND D1_LOJA					=					FT_LOJA  " + CRLF
    _cQry += "  		   AND D1_COD					=					FT_PRODUTO  " + CRLF
    _cQry += "  		   AND D1_FILIAL				=					FT_FILIAL  " + CRLF
    _cQry += "  		   AND D1_EMISSAO				=					FT_EMISSAO  " + CRLF
    _cQry += "  		   AND D1.D_E_L_E_T_			=					' '   " + CRLF
    _cQry += "  	 LEFT JOIN SD2010 D2  " + CRLF
    _cQry += "  			ON D2_CLIENTE				=					FT_CLIEFOR  " + CRLF
    _cQry += "  		   AND D2_LOJA					=					FT_LOJA  " + CRLF
    _cQry += "  		   AND D2_COD					=					FT_PRODUTO  " + CRLF
    _cQry += "  		   AND D2_FILIAL				=					FT_FILIAL  " + CRLF
    _cQry += "  		   AND D2_EMISSAO				=					FT_EMISSAO  " + CRLF
    _cQry += "  		   AND D2.D_E_L_E_T_			=					' '  " + CRLF
    _cQry += "  		 WHERE FT_FILIAL BETWEEN  '" +MV_PAR01+ "' AND   '" +MV_PAR02+ "' " + CRLF
    _cQry += "  		   AND FT_ENTRADA BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"'   " + CRLF
    _cQry += "  		   AND FT.D_E_L_E_T_ = ' '   " + CRLF
    _cQry += "  		   AND FT_ESPECIE IN ('NF','NFE','NFA','NFP','SPED', 'CTE')  " + CRLF
    _cQry += "		       AND FT_DTCANC = ' '   " + CRLF
    _cQry += "		       AND FT_OBSERV NOT IN ('%NF CANCELADA%')  " + CRLF
    
    
    
    If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro1.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "DATA_ENTRADA", "D")
    
//WorkSheet, cTitulo, "COD_CTA"		     , 1, 1 )to
		/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "NUM_NF"		     , 1, 1 )
		/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "SERIE_NF"		     , 1, 1 )
		/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "COD_PART"		     , 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CHV_NFE"		     , 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "OBSERVACAO"		 , 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "COD_GEN"		     , 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "TIPO_ITEM"		     , 1, 1 )
		///* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CHV_NFE"		     , 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "DATA_ENTRADA"		 , 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "ITEM"		     	 , 1, 1 )
		/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "FRETE"		      	 , 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "REG"		         , 1, 1 )
		/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "IND_OPER"		     , 1, 1 )
		/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "COD_ITEM"		     , 1, 1 )
		/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "DESC_COMPL"		 , 1, 1 )
		/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "QTD"		      	 , 1, 1 )
		/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "UNID"		      	 , 1, 1 )
		/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "VL_ITEM"		     , 1, 1 )
		/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "VL_DESC"		     , 1, 1 )
		/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "IND_MOV"		     , 1, 1 )
		/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CST_ICMS"		     , 1, 1 )
		/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CFOP"		      	 , 1, 1 )
		/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "COD_NAT"		     , 1, 1 )
		/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "VL_BC_ICMS"		 , 1, 1 )
		/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "ALIQ_ICMS"		     , 1, 1 )
		/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "VL_ICMS"		     , 1, 1 )
		/* 20 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CST_PIS"		     , 1, 1 )
		/* 21 */ oExcel:AddColumn( cWorkSheet, cTitulo, "VL_BC_PIS"		     , 1, 1 )
		/* 22 */ oExcel:AddColumn( cWorkSheet, cTitulo, "ALIQ_PIS"		     , 1, 1 )
		/* 23 */ oExcel:AddColumn( cWorkSheet, cTitulo, "QUANT_BC_PIS"		 , 1, 1 )
		/* 24 */ oExcel:AddColumn( cWorkSheet, cTitulo, "ALIQ_PIS"		     , 1, 1 )
		/* 25 */ oExcel:AddColumn( cWorkSheet, cTitulo, "VL_PIS"		     , 1, 1 )
		/* 26 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CST_COFINS"		 , 1, 1 )
		/* 27 */ oExcel:AddColumn( cWorkSheet, cTitulo, "VL_BC_COFINS"		 , 1, 1 )
		/* 28 */ oExcel:AddColumn( cWorkSheet, cTitulo, "ALIQ_COFINS"		 , 1, 1 )
		/* 29 */ oExcel:AddColumn( cWorkSheet, cTitulo, "QUANT_BC_COFINS"	 , 1, 1 )
		/* 30 */ oExcel:AddColumn( cWorkSheet, cTitulo, "ALIQ_COFINS"		 , 1, 1 )
		/* 31 */ oExcel:AddColumn( cWorkSheet, cTitulo, "VL_COFINS"		     , 1, 1 )		                                               
	    /* 32 */ oExcel:AddColumn( cWorkSheet, cTitulo, "COD_CTA"		     , 1, 1 )
	    
		                                             
    dbGotop()
	
	While !(cAlias)->(Eof())
	                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->NUM_NF, ;
							  (cAlias)->SERIE_NF, ;
							  (cAlias)->COD_PART, ;
							  (cAlias)->CHV_NFE, ;
							  (cAlias)->OBSERVACAO, ;	
							  (cAlias)->COD_GEN, ;
							  (cAlias)->TIPO_ITEM, ;		
							  (cAlias)->DATA_ENTRADA, ;
							  (cAlias)->ITEM, ;
							  (cAlias)->FRETE, ;
							  (cAlias)->REG, ;
							  (cAlias)->IND_OPER, ;
							  (cAlias)->COD_ITEM, ;
							  (cAlias)->DESC_COMPL, ;
							  (cAlias)->QTD, ;
							  (cAlias)->UNID, ;
							  (cAlias)->VL_ITEM, ;
							  (cAlias)->VL_DESC, ;
							  (cAlias)->IND_MOV, ;
							  (cAlias)->CST_ICMS, ;
							  (cAlias)->CFOP, ;
							  (cAlias)->COD_NAT, ;
							  (cAlias)->VL_BC_ICMS, ;
							  (cAlias)->ALIQ_ICMS, ;
							  (cAlias)->VL_ICMS, ;
							  (cAlias)->CST_PIS, ;
							  (cAlias)->VL_BC_PIS, ;
							  (cAlias)->ALIQ_PIS, ;
							  (cAlias)->QUANT_BC_PIS, ;
							  (cAlias)->ALIQ_PIS, ;
							  (cAlias)->VL_PIS, ;
							  (cAlias)->CST_COFINS, ;
							  (cAlias)->VL_BC_COFINS, ;
							  (cAlias)->ALIQ_COFINS, ;
							  (cAlias)->QUANT_BC_COFINS, ;
							  (cAlias)->ALIQ_COFINS, ;
							  (cAlias)->VL_COFINS, ;
							  (cAlias)->COD_CTA} )
							  
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
	
Return
							  