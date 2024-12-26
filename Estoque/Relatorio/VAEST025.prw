#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} VAEST025
//TODO Este relatório é para demonstrar.
@author Arthur Toshio
@since 08/03/2018
@version undefined

@type function
/*/
user function VAEST025()

Private cPerg := nil

	nOrdem   := 0
	tamanho  := "P"
	limite   := 80
	titulo   := PADC("VAEST025",74)
	cDesc1   := PADC("Relatório - Produção de Ração - Insumos",74)
	cDesc2   := ""
	cDesc3   := ""
	aReturn  :=  { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
	nomeprog := "VAEST025"
	cPerg    := "VAEST025"
	nLastKey := 0
	wnrel    := "VAEST025"
	_cQry	 := ""

	ValidPerg(cPerg)
	
	/* 
	While Pergunte(cPerg, .T.)
		MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
	Enddo
	*/
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
	aRegs :={}                                                  

	aAdd(aRegs,{cPerg, "01", "Filial De   ?", "", "", "MV_CH01", "C", TamSX3("D3_FILIAL") [1], TamSX3("D3_FILIAL") [2], 0, "G", "", "MV_PAR01" , "", "","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "02", "Filial Ate  ?", "", "", "MV_CH02", "C", TamSX3("D3_FILIAL") [1], TamSX3("D3_FILIAL") [2], 0, "G", "", "MV_PAR02" , "", "","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "03", "Data De     ?", "", "", "MV_CH03", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "", "MV_PAR03" , "", "","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "04", "Data Até    ?", "", "", "MV_CH04", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "", "MV_PAR04" , "", "","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
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

/* ##################################################################################################################### */
Static Function ImprRel(cPerg)  
 
// Tratamento para Excel
Private oExcel := FWMSExcel():New()
Private oExcelApp
Private cArquivo  := GetTempPath()+'VAEST025_'+StrTran(dToC(dDataBase), '/', '-')+'_'+StrTran(Time(), ':', '-')+'.xml'

oExcel:SetFont('Arial Narrow')
oExcel:SetBgColorHeader("#37752F") // cor de fundo linha cabeçalho
oExcel:SetLineBgColor("#FFFFFF")   // cor da linha 1
oExcel:Set2LineBgColor("#FFFFFF")  // cor da linha 2

fQuadro1(cPerg)
fQuadro2(cPerg)
fQuadro3(cPerg)
fQuadro4(cPerg)

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
Local cWorkSheet := "Produção"
Local cTitulo	 := "Ordem Producao"
cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)
oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

//	_cQry := "  		SELECT DISTINCT(D3.D3_FILIAL)			FILIAL,   " + CRLF
//	_cQry += "  			   D3.D3_TM							TIPO_MOV,   " + CRLF
//	_cQry += "  			   D3.D3_COD						CODIGO,  " + CRLF
//	_cQry += "  			   B1.B1_DESC						DESCRICAO,  " + CRLF
//	_cQry += "  			   D3.D3_UM							UM,  " + CRLF
//	_cQry += "  			   SUM(D3.D3_QUANT)					QUANTIDADE,  " + CRLF
//	//_cQry += "  			   D3.D3_EMISSAO					EMISSAO,  " + CRLF
//	_cQry += "  			   SUM(D3.D3_CUSTO1)/SUM(D3.D3_QUANT) CUSTO,  " + CRLF
//	_cQry += "  			   SUM(D3.D3_CUSTO1)				CUSTO_TOTAL,  " + CRLF
//	_cQry += "  			   D31.D3_COD						COD_INSUM,  " + CRLF
//	_cQry += "  			   B11.B1_DESC						DESC_INSUMO,  " + CRLF
//	_cQry += "  			   SUM(D31.D3_QUANT)				QUANT_INS,  " + CRLF
//	_cQry += "  			   SUM(D31.D3_CUSTO1)				CUSTO_INSU  " + CRLF
//	_cQry += "  		  FROM SD3010 D3   " + CRLF
//	_cQry += "  		  JOIN SB1010 B1  " + CRLF
//	_cQry += "  		    ON B1.B1_COD						=					D3.D3_COD   " + CRLF
//	_cQry += "  		   AND B1.D_E_L_E_T_					=					' '   " + CRLF
//	_cQry += "  		  JOIN SD3010 D31   " + CRLF
//	_cQry += "  		    ON D31.D3_OP						=					D3.D3_OP  " + CRLF
//	_cQry += "  		   AND D31.D3_CF							LIKE				'RE%'  " + CRLF
//	_cQry += "  		   AND D31.D_E_L_E_T_					=					' '   " + CRLF
//	_cQry += "  		  JOIN SB1010 B11  " + CRLF
//	_cQry += "  		    ON B11.B1_COD						=					D31.D3_COD  " + CRLF
//	_cQry += "  		   AND B11.D_E_L_E_T_					=					' '   " + CRLF
//	_cQry += "    " + CRLF
//	_cQry += "  		 WHERE D3.D3_EMISSAO 	BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"'  " + CRLF
//	_cQry += "  		   AND D3.D3_TM							=					'001'  " + CRLF
//	_cQry += "  		   AND D3.D_E_L_E_T_					=					' '   " + CRLF
//	_cQry += "  	  GROUP BY D3.D3_FILIAL,  " + CRLF
//	_cQry += "  			   D3.D3_TM,   " + CRLF
//	_cQry += "  			   D3.D3_COD,  " + CRLF
//	_cQry += "  			   B1.B1_DESC,   " + CRLF
//	_cQry += "  			   D3.D3_UM,   " + CRLF
//	//_cQry += "  			   D3.D3_EMISSAO,  " + CRLF
//	_cQry += "  			   D31.D3_COD,  " + CRLF
//	_cQry += "  			   B11.B1_DESC  " + CRLF
//	_cQry += "  	  ORDER BY D3.D3_COD  " + CRLF
	
	_cQry += "    WITH PROD_RACAO		  " +CRLF  
	_cQry += "    AS (		  " +CRLF  
	_cQry += "        SELECT D3.D3_FILIAL					FILIAL,		  " +CRLF  
	_cQry += "        	   D3.D3_COD					    CODIGO,		  " +CRLF  
	_cQry += "        	   B1.B1_DESC					    DESCRICAO, 		  " +CRLF  
	_cQry += "        	   D3.D3_UM						    UM,    					  " +CRLF  
	_cQry += "           	   D3.D3_OP							OP,		  " +CRLF  
	_cQry += "    		   D3.D3_EMISSAO					EMISSAO,     		  " +CRLF  
	_cQry += "        	   SUM(D3.D3_QUANT)					QTD,		  " +CRLF  
	_cQry += "        	   SUM(D3.D3_CUSTO1) - ISNULL((SELECT SUM(D3_CUSTO1) " +CRLF
	_cQry += "        	  							     FROM SD3010 " +CRLF
	_cQry += "        	   								WHERE D3_EMISSAO BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"' " +CRLF 
	_cQry += "        	   								      AND D3_COD = '020156' AND D_E_L_E_T_ = ' ' AND D3_OP = D3.D3_OP ),0) CUSTO  " +CRLF
	_cQry += "        FROM SD3010 D3		  " +CRLF  
	_cQry += "        JOIN SB1010 B1 ON 		  " +CRLF  
	_cQry += "        D3_COD = B1_COD 		  " +CRLF  
	_cQry += "        WHERE D3.D3_TM = '001'		  " +CRLF  
	_cQry += "        AND D3.D3_EMISSAO BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"'  " + CRLF  
	_cQry += "        AND D3.D_E_L_E_T_ = ' '  		  " +CRLF  
	_cQry += "        AND D3.D3_ESTORNO  = ' '  		  " +CRLF  
	_cQry += "        AND B1.D_E_L_E_T_ = ' ' 		  " +CRLF  
	_cQry += "        AND B1_X_TRATO <> ' ' 		  " +CRLF  
	_cQry += "        GROUP BY D3.D3_FILIAL, D3.D3_COD, B1_DESC, D3.D3_UM, D3.D3_EMISSAO, D3.D3_OP		  " +CRLF
	_cQry += "    	),		  " +CRLF
	_cQry += "    INS_CARR		  " +CRLF
	_cQry += "    AS (		  " +CRLF
	_cQry += "    	SELECT P.FILIAL, P.CODIGO, D3.D3_FILIAL, D3_COD, D3.D3_EMISSAO, D3.D3_OP, SUM(D3_QUANT) QTD, SUM(D3_CUSTO1) CUSTO FROM SD3010 D3		  " +CRLF
	_cQry += "    	  JOIN PROD_RACAO P ON		  " +CRLF
	_cQry += "    	       D3.D3_FILIAL				=			P.FILIAL		  " +CRLF
	_cQry += "    	   AND D3.D3_OP					=			P.OP		  " +CRLF
	_cQry += "    	   AND D3.D3_EMISSAO			=			P.EMISSAO		  " +CRLF
	_cQry += "    	   AND D3.D3_COD				<>			P.CODIGO		  " +CRLF
	_cQry += "    	   AND D3_CF					LIKE		'RE%'		  " +CRLF
	_cQry += "    	 WHERE D3.D_E_L_E_T_			=			' ' 		  " +CRLF  
	_cQry += "    	 GROUP BY P.FILIAL, P.CODIGO, D3.D3_FILIAL, D3.D3_COD, D3_EMISSAO, D3.D3_OP		  " +CRLF  
	_cQry += "    	)		  " +CRLF  
	_cQry += "              SELECT P.FILIAL			FILIAL,   	" + CRLF
	_cQry += "        			   P.CODIGO			CODIGO, 	  " + CRLF
	_cQry += "        			   P.DESCRICAO		DESCRICAO,	" + CRLF
	_cQry += "        			   P.UM 			UM,   " + CRLF
	_cQry += "        			   P.EMISSAO		EMISSAO,    " + CRLF
	_cQry += "        			   SUM(P.QTD) 		QUANTIDADE, " + CRLF
	_cQry += "        			   SUM(P.CUSTO) 	CUSTO_TOTAL,  " + CRLF
	_cQry += "        			   C.D3_COD			COD_INSUM,   " + CRLF 
	_cQry += "        			   B1.B1_DESC		DESC_INSUMO, " + CRLF
	_cQry += "         			   SUM(C.QTD) 		QUANT_INS,  " + CRLF
	_cQry += "        			   SUM(C.CUSTO) 	CUSTO_INSU " + CRLF  
	_cQry += "        		  FROM PROD_RACAO P " + CRLF
	_cQry += "        		  JOIN INS_CARR C  	" + CRLF
	_cQry += "        			ON P.FILIAL 		=       C.FILIAL	" + CRLF
	_cQry += "        		   AND P.CODIGO 		=       C.CODIGO " + CRLF
	_cQry += "        		   AND P.EMISSAO 		=       C.D3_EMISSAO " + CRLF
	_cQry += "        		   AND P.OP 			=       C.D3_OP " + CRLF
	_cQry += "        		  JOIN SB1010 B1 ON   	" + CRLF
	_cQry += "        	  	   	   B1.B1_COD 		= 		C.D3_COD   " + CRLF
	_cQry += "        			   WHERE P.FILIAL BETWEEN '"+MV_PAR01+"' AND  '"+MV_PAR02+"'" + CRLF
	_cQry += "         	  GROUP BY P.FILIAL, 		    " + CRLF
	_cQry += "        			   P.CODIGO, 		    " + CRLF
	_cQry += "           		   P.DESCRICAO, 	  " + CRLF
	_cQry += "             		   P.UM,		  " + CRLF
	_cQry += "             		   P.EMISSAO," + CRLF
	_cQry += "        			   C.D3_COD,  	" + CRLF
	_cQry += "        			   B1.B1_DESC  " + CRLF
  
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro1.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "EMISSAO", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "FILIAL"		     , 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "EMISSÃO"	      	 , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "COD PRODUTO"		 , 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "DESCRICAO"		     , 1, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "UDM"		      	 , 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "QTDE PRODUZIDA"	 , 1, 2 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CUSTO UNITARIO"	 , 1, 2 )
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CUSTO TOTAL"		 , 1, 2 )	
	/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "COD INSUMO"		 , 1, 1 )
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "INSUMO"		     , 1, 1 )
	/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "QTDE INSUMO"		 , 1, 2, .T. )
	/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CUSTO UNITARIO"	 , 1, 2 )
	/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CUSTO INSUMO"		 , 1, 3, .T. )
	
	dbGotop()
	
	While !(cAlias)->(Eof())
	                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->FILIAL,;
							  (cAlias)->EMISSAO,;
							  (cAlias)->CODIGO,;
							  (cAlias)->DESCRICAO,;
							  (cAlias)->UM,;
							  (cAlias)->QUANTIDADE,;
							  (cAlias)->CUSTO_TOTAL/(cAlias)->QUANTIDADE,;
							  (cAlias)->CUSTO_TOTAL,;
							  (cAlias)->COD_INSUM,;
							  (cAlias)->DESC_INSUMO,;
							  (cAlias)->QUANT_INS,; 
							  (cAlias)->CUSTO_INSU/(cAlias)->QUANT_INS,;
							  (cAlias)->CUSTO_INSU } )
							  
		
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
	
Return


Static Function fQuadro2(cPerg)

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Ordens de Producao"
Local cTitulo	 := "Ordem Producao"

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)
oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry := "  		SELECT DISTINCT(D3.D3_FILIAL)			FILIAL,   " +CRLF 
	_cQry += "  			   D3.D3_TM							TIPO_MOV,   " +CRLF 
	_cQry += "  			   D3.D3_COD						CODIGO,  " +CRLF 
	_cQry += "  			   B1.B1_DESC						DESCRICAO,  " +CRLF 
	_cQry += "  			   D3.D3_UM							UM,  " +CRLF 
	_cQry += "  			   D3.D3_QUANT						QUANTIDADE,  " +CRLF 
	_cQry += "  			   D3.D3_EMISSAO					EMISSAO,  " +CRLF 
	_cQry += "  			   D3.D3_CUSTO1						CUSTO_TOTAL,  " +CRLF 
	_cQry += "  			   D3.D3_OP							ORDEM_PRODUC,  " +CRLF 
	_cQry += "  			   D31.D3_COD						COD_INSUM,  " +CRLF 
	_cQry += "  			   B11.B1_DESC						DESC_INSUMO,  " +CRLF 
	_cQry += "  			   D31.D3_QUANT						QUANT_INS,  " +CRLF 
	_cQry += "  			   D31.D3_CUSTO1					CUSTO_INSU  " +CRLF 
	_cQry += "    " +CRLF 
	_cQry += "  		  FROM SD3010 D3   " +CRLF 
	_cQry += "  		  JOIN SB1010 B1  " +CRLF 
	_cQry += "  		    ON B1.B1_COD						=					D3.D3_COD   " +CRLF 
	_cQry += "  		   AND B1.D_E_L_E_T_					=					' '   " +CRLF 
	_cQry += "  		  JOIN SD3010 D31   " +CRLF 
	_cQry += "  		    ON D31.D3_OP						=					D3.D3_OP  " +CRLF 
	_cQry += "  		   AND D31.D3_CF							LIKE				'RE%'  " +CRLF 
	_cQry += "  		   AND D31.D_E_L_E_T_					=					' '   " +CRLF 
	_cQry += "  		   AND D31.D3_ESTORNO					=					' '   " +CRLF 
	_cQry += "  		  JOIN SB1010 B11  " +CRLF 
	_cQry += "  		    ON B11.B1_COD						=					D31.D3_COD  " +CRLF 
	_cQry += "  		   AND B11.D_E_L_E_T_					=					' '   " +CRLF 
	_cQry += "  		 WHERE D3.D3_EMISSAO BETWEEN			'"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"'" +CRLF 
	_cQry += "  		   AND D3.D3_FILIAL BETWEEN  '"+MV_PAR01+"' AND  '"+MV_PAR02+"'" + CRLF
	_cQry += "  		   AND D3.D3_TM							=					'001'  " +CRLF 
	_cQry += "  		   AND D3.D_E_L_E_T_					=					' '   " +CRLF 
	_cQry += "  		   AND D3.D3_ESTORNO					=					' '   " +CRLF 
	_cQry += "			   AND D3.D3_COD						<>					D31.D3_COD
	_cQry += "  	  ORDER BY D3.D3_EMISSAO," +CRLF 
	_cQry += "  		 	   D3.D3_COD," +CRLF
	_cQry += "  		       D3.D3_OP" +CRLF
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
	MemoWrite(StrTran(cArquivo,".xml","")+"Quadro2.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "EMISSAO", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "FILIAL"		     , 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "DATA"		      	 , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "ORDEM PRODUCAO"   	 , 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "TM"		      	 , 1, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "COD PRODUTO"		 , 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "DESCRICAO"		     , 1, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "UDM"		      	 , 1, 1 )
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "QTDE PRODUZIDA"	 , 1, 2 )
	/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "UNITARIO RACAO"	 , 1, 2 )
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CUSTO TOTAL"		 , 1, 3 )
	/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "COD INSUMO"		 , 1, 1 )
	/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "INSUMO"		     , 1, 1 )
	/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "QTDE INSUMO"		 , 1, 2, .T. )
	/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "UNITARIO INSUMO"	 , 1, 2 )
	/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CUSTO INSUMO"		 , 1, 3, .T. )
	
	dbGotop()
	
	While !(cAlias)->(Eof())

		oExcel:AddRow( cWorkSheet, cTitulo, ;
						{ (cAlias)->FILIAL,;
						  (cAlias)->EMISSAO,;
						  (calias)->ORDEM_PRODUC,;
						  (cAlias)->TIPO_MOV,;
						  (cAlias)->CODIGO,;
						  (cAlias)->DESCRICAO,;
						  (cAlias)->UM,;
						  (cAlias)->QUANTIDADE,;
						  (cAlias)->CUSTO_TOTAL/(cAlias)->QUANTIDADE,;
						  (cAlias)->CUSTO_TOTAL,; 
						  (cAlias)->COD_INSUM,;
						  (cAlias)->DESC_INSUMO,;
						  (cAlias)->QUANT_INS,; 
						  (cAlias)->CUSTO_INSU/(cAlias)->QUANT_INS,;
						  (cAlias)->CUSTO_INSU } )		  
	
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
	
Return

Static _nPFilial := 1
Static _nPCODIGO := 2
Static _nPDescri := 3
Static _nPUm     := 4
Static _dUCP     := 5
Static _nUCP     := 6



/* ##################################################################################################################### */
Static Function fQuadro3(cPerg)

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Resumo Producao"
Local cTitulo	 := "Quantidade Produzidas"
Local nQtDias    := DateDiffDay(MV_PAR03, MV_PAR04)+1
Local dDia 		 := MV_PAR03
Local aDados	 := {} // Array(4+(3*nQtdias))

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)
oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

//_cQry := "	SELECT  D3.D3_FILIAL					FILIAL,       	" + CRLF
//_cQry += "		   	D3.D3_COD						CODIGO,       	" + CRLF
//_cQry += "		   	B1.B1_DESC						DESCRICAO,    	" + CRLF
//_cQry += "		   	D3.D3_UM						UM,    			" + CRLF
//_cQry += "   		D3.D3_EMISSAO					EMISSAO,      	" + CRLF				
//_cQry += "		   	SUM(D3.D3_QUANT)				QUANTIDADE,    	" + CRLF
//_cQry += "		    SUM(D3.D3_CUSTO1)/SUM(D3.D3_QUANT)	CUSTO_MEDIO," + CRLF
//_cQry += "		   	SUM(D3.D3_CUSTO1)				CUSTO_TOTAL   	" + CRLF
//_cQry += "	  FROM SD3010 D3     									" + CRLF
//_cQry += "	  JOIN SB1010 B1     									" + CRLF
//_cQry += "	    ON B1.B1_COD						= D3.D3_COD     " + CRLF
//_cQry += "	   AND B1.D_E_L_E_T_					= ' '     		" + CRLF
//_cQry += "     JOIN SD3010 D31   									" + CRLF
//_cQry += "	    ON D31.D3_OP						= D3.D3_OP 		" + CRLF  
//_cQry += "        AND D31.D3_CF						LIKE 'RE%'  	" + CRLF
//_cQry += "        AND D31.D_E_L_E_T_				= ' '   		" + CRLF
//_cQry += "	 WHERE D3.D3_EMISSAO BETWEEN			'" +dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"'" +CRLF
//_cQry += "	   AND D3.D3_TM							= '001'    		" + CRLF
//_cQry += "	   AND D3.D_E_L_E_T_					= ' '      		" + CRLF
//_cQry += "  AND D3.D3_COD <> D31.D3_COD   							" +	CRLF
//_cQry += "  GROUP BY D3.D3_FILIAL,	  								" +	CRLF
//_cQry += "     D3.D3_COD,  											" +	CRLF
//_cQry += "     B1.B1_DESC,  										" +	CRLF
//_cQry += "     D3.D3_UM,  											" +	CRLF
//_cQry += "     D3.D3_EMISSAO  										" +	CRLF
//_cQry += "  ORDER BY D3.D3_COD,  									" +	CRLF
//_cQry += "	   D3.D3_EMISSAO										" +	CRLF

_cQry += "  WITH PROD_RACAO		" +CRLF																								
_cQry += "  AS (		" +CRLF
_cQry += "      SELECT D3.D3_FILIAL					    FILIAL,		" +CRLF       	
_cQry += "      	   D3.D3_COD					    CODIGO,		" +CRLF
_cQry += "      	   B1.B1_DESC					    DESCRICAO, 		" +CRLF
_cQry += "      	   D3.D3_UM						    UM,    					" +CRLF
_cQry += "         	   D3.D3_OP							OP,		" +CRLF
_cQry += "  		   D3.D3_EMISSAO					EMISSAO,     		" +CRLF
_cQry += "      	   SUM(D3.D3_QUANT)					QTD,		" +CRLF
_cQry += "      	   SUM(D3.D3_CUSTO1)				CUSTO		" +CRLF
_cQry += "      FROM SD3010 D3		" +CRLF		
_cQry += "      JOIN SB1010 B1 ON 		" +CRLF
_cQry += "      D3_COD = B1_COD 		" +CRLF
_cQry += "      WHERE D3.D3_TM = '001'		" +CRLF
_cQry += "      AND D3.D3_FILIAL BETWEEN '"+MV_PAR01+"' AND  '"+MV_PAR02+"'" + CRLF
_cQry += "      AND D3.D3_EMISSAO between '" +dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"'		" +CRLF
_cQry += "      AND D3.D_E_L_E_T_ = ' '  		" +CRLF
_cQry += "      AND D3.D3_ESTORNO = ' '  		" +CRLF
_cQry += "      AND B1.D_E_L_E_T_ = ' ' 		" +CRLF
_cQry += "      AND B1_X_TRATO <> ' ' 		" +CRLF
_cQry += "      --AND D3.D3_COD = '030013'		" +CRLF
_cQry += "      GROUP BY D3.D3_FILIAL, D3.D3_COD, B1_DESC, D3.D3_UM, D3.D3_EMISSAO, D3.D3_OP		" +CRLF
_cQry += "      --ORDER BY D3.D3_COD,  			" +CRLF
_cQry += "      	   --D3.D3_EMISSAO					" +CRLF
_cQry += "  	),		" +CRLF
_cQry += "  INS_CARR		" +CRLF
_cQry += "  AS (		" +CRLF
_cQry += "  	SELECT P.FILIAL, P.CODIGO, D3.D3_FILIAL, D3_COD, D3.D3_EMISSAO, SUM(D3_QUANT) QTD, SUM(D3_CUSTO1) CUSTO FROM SD3010 D3		" +CRLF
_cQry += "  	  JOIN PROD_RACAO P ON		" +CRLF
_cQry += "  	       D3.D3_FILIAL				=			P.FILIAL		" +CRLF
_cQry += "  	   AND D3.D3_OP					=			P.OP		" +CRLF
_cQry += "  	   AND D3.D3_EMISSAO			=			P.EMISSAO		" +CRLF
_cQry += "  	   AND D3.D3_COD				<>			P.CODIGO		" +CRLF
_cQry += "  	   AND D3_CF					LIKE		'RE%'		" +CRLF
_cQry += "  	 WHERE D3.D_E_L_E_T_			=			' ' 		" +CRLF
_cQry += "         AND D3.D3_FILIAL BETWEEN '"+MV_PAR01+"' AND  '"+MV_PAR02+"'" + CRLF
_cQry += "  	 GROUP BY P.FILIAL, P.CODIGO, D3.D3_FILIAL, D3.D3_COD, D3_EMISSAO		" +CRLF
_cQry += "  	)		" +CRLF
_cQry += "  	SELECT P.FILIAL,		" +CRLF 
_cQry += "  		   P.CODIGO, 		" +CRLF
_cQry += "			   P.DESCRICAO,		" +CRLF
_cQry += "  		   P.UM,		" +CRLF
_cQry += "  		   P.EMISSAO, 		" +CRLF
_cQry += "  		   SUM(P.QTD) QTD, 		" +CRLF
_cQry += "  		   SUM(P.CUSTO) CUSTO 		" +CRLF
_cQry += "  	FROM PROD_RACAO P		" +CRLF
_cQry += "  	GROUP BY P.FILIAL, 		" +CRLF
_cQry += "  		     P.CODIGO, 		" +CRLF
_cQry += "			     P.DESCRICAO,	" +CRLF
_cQry += "  			 P.UM,		    " +CRLF
_cQry += "  			 P.EMISSAO		" +CRLF
_cQry += "  	ORDER BY P.FILIAL,		" +CRLF
_cQry += "  			 P.CODIGO, 		" +CRLF
_cQry += "  			 P.EMISSAO		" +CRLF



	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
	MemoWrite(StrTran(cArquivo,".xml","")+"Quadro3.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "EMISSAO", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "FILIAL"		      		, 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "COD PRODUTO"		  		, 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "DESCRICAO"		  			, 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "UDM"		      	  		, 1, 1 )
	
	
	
	For dDia := MV_PAR03 to MV_PAR04
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtd "+DTOC(dDia) 			, 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CUSTO MEDIO"		  		, 1, 3 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CUSTO TOTAL"		  		, 1, 3 )
	Next dDia
	
	// dbGotop()
	
	aDados 	:= Array(4+(3*nQtdias))
	While !(cAlias)->(Eof())

		If Empty ( aDados[ _nPCODIGO ] )
			aDados[ _nPFilial ] := (cAlias)->FILIAL
			aDados[ _nPCODIGO ] := (cAlias)->CODIGO
			aDados[ _nPDescri ] := (cAlias)->DESCRICAO
			aDados[ _nPUm     ] := (cAlias)->UM
		EndIf

		nPos := (cAlias)->EMISSAO-MV_PAR03
		nPosCol := Iif(nPos==0, nPos, nPos*3 )
		aDados[5+nPosCol ] := (cAlias)->QTD
		aDados[6+nPosCol ] := (cAlias)->CUSTO/(cAlias)->QTD
		aDados[7+nPosCol ] := (cAlias)->CUSTO

		(cAlias)->(DbSkip())
	
		If (cAlias)->(Eof()) .or.  aDados[ _nPCODIGO ] <> (cAlias)->CODIGO
			// imprimir
			oExcel:AddRow( cWorkSheet, cTitulo, aDados )	
			
			aDados	:= Array(4+(3*nQtdias))
		EndIf
	EndDo
	RestArea(aArea)
	
Return

Static Function fQuadro4(cPerg) 

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Insumos"
Local cTitulo	 := "Quantidade Produzidas"
Local nQtDias    := DateDiffDay(MV_PAR03, MV_PAR04)+1
Local dDia 		 := MV_PAR03
Local aDados	 := {} // Array(4+(3*nQtdias))

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)
oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

_cQry := " SELECT D3.D3_FILIAL					FILIAL,       		" +CRLF 
_cQry += " 	   D3.D3_COD					    CODIGO,       	    " +CRLF
_cQry += " 	   B1.B1_DESC					    DESCRICAO,    	    " +CRLF
_cQry += " 	   D3.D3_UM						    UM,    			    " +CRLF
_cQry += "     D3.D3_EMISSAO					EMISSAO,            " +CRLF
_cQry += "     B1.B1_UCOM			            DATA_COMPRA,	    " +CRLF
_cQry += "     B1.B1_UPRC			            ULTIMO_PRECO,       " +CRLF
_cQry += " 	   SUM(D3_QUANT)					QTD,                " +CRLF
_cQry += " 	   SUM(D3_CUSTO1)					CUSTO               " +CRLF
_cQry += " FROM SD3010 D3                                           " +CRLF
_cQry += " JOIN SB1010 B1 ON D3_COD = B1_COD                        " +CRLF
_cQry += " WHERE D3_OP <> ' '                                       " +CRLF
_cQry += " AND D3.D3_FILIAL BETWEEN '"+MV_PAR01+"' AND  '"+MV_PAR02+"'" + CRLF
_cQry += " AND D3_EMISSAO BETWEEN '" +dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"' " +CRLF 
_cQry += " AND D3.D_E_L_E_T_ = ' '                                  " +CRLF
_cQry += " AND D3.D3_ESTORNO = ' '                                  " +CRLF
_cQry += " AND B1.D_E_L_E_T_ = ' '                                  " +CRLF
_cQry += " AND D3_GRUPO IN ('02','03') 								" +CRLF
_cQry += " AND D3_TM <> '001'                                    	" +CRLF
_cQry += " AND B1_DESC NOT LIKE 'RACAO%'					    	" +CRLF
_cQry += " GROUP BY D3_FILIAL, D3_COD, B1_DESC, D3_UM, D3_EMISSAO, B1_UCOM, B1_UPRC  " +CRLF
_cQry += " ORDER BY D3.D3_COD,  									" +CRLF
_cQry += " 	   D3.D3_EMISSAO										" +CRLF


	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
	MemoWrite(StrTran(cArquivo,".xml","")+"Quadro4.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "EMISSAO", "D")
	TcSetField(cAlias, "DATA_COMPRA", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "FILIAL"		      		, 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "COD PRODUTO"		  		, 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "DESCRICAO"		  			, 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "UDM"		      	  		, 1, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "ULTIMA COMPRA"		      	, 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "ULTIMO PRECO"		      	, 1, 2 )
	
	
	For dDia := MV_PAR03 to MV_PAR04
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtd "+DTOC(dDia) 			, 1, 2 )
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CUSTO MEDIO"		  		, 1, 2 )
	/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CUSTO TOTAL"		  		, 1, 2 )
	Next dDia
	
	// dbGotop()
	
	aDados 	:= Array(6+(3*nQtdias))
	While !(cAlias)->(Eof())

		If Empty ( aDados[ _nPCODIGO ] )
			aDados[ _nPFilial ] := (cAlias)->FILIAL
			aDados[ _nPCODIGO ] := (cAlias)->CODIGO
			aDados[ _nPDescri ] := (cAlias)->DESCRICAO
			aDados[ _nPUm     ] := (cAlias)->UM
			aDados[ _dUCP     ] := (cAlias)->DATA_COMPRA
			aDados[ _nUCP     ] := (cAlias)->ULTIMO_PRECO
			
			
		EndIf

		nPos := (cAlias)->EMISSAO-MV_PAR03
		nPosCol := Iif(nPos==0, nPos, nPos*3 )
		aDados[7+nPosCol ] := (cAlias)->QTD
		aDados[8+nPosCol ] := (cAlias)->CUSTO/(cAlias)->QTD
		aDados[9+nPosCol ] := (cAlias)->CUSTO

		(cAlias)->(DbSkip())
	
		If (cAlias)->(Eof()) .or.  aDados[ _nPCODIGO ] <> (cAlias)->CODIGO
			// imprimir
			oExcel:AddRow( cWorkSheet, cTitulo, aDados )	
			
			aDados	:= Array(6+(3*nQtdias))
		EndIf
	EndDo
	RestArea(aArea)
	
Return
