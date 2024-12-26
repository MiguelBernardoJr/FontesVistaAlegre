#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Arthru Toshio Oda VAnzella	                                          |
 | Data:  19-11-2018                                                              |
 | Desc:  Relatório de relação de marcações para vale combustível.	                                  |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/

user function VAGPER02()

	Private cPerg := nil
	
	//nomeprog :="VAEST022"
	cPerg      :="VAGPER02"
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

Static Function ValidPerg(cPerg)
Local _sAlias,i,j

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}                                                  

	AADD(aRegs,{cPerg,"01","Filial de:	    ?",Space(20),Space(20),"mv_ch1","C",02,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","",""})
	AADD(aRegs,{cPerg,"02","Filial Ate:	    ?",Space(20),Space(20),"mv_ch2","C",02,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","",""})
	AADD(aRegs,{cPerg,"03","Data de         ?",Space(20),Space(20),"mv_ch3","D",08,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Data até        ?",Space(20),Space(20),"mv_ch4","D",08,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Valor p/ dia    ?",Space(20),Space(20),"mv_ch5","N",08,2,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"06","Depart. De:	    ?",Space(20),Space(20),"mv_ch6","C",08,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","SQB","","","",""})
	AADD(aRegs,{cPerg,"07","Depart. Ate:    ?",Space(20),Space(20),"mv_ch7","C",08,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","SQB","","","",""})
	AADD(aRegs,{cPerg,"08","C. Custo de:	?",Space(20),Space(20),"mv_ch8","C",08,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","CTT","","","",""})
	AADD(aRegs,{cPerg,"09","C. Custo Ate:   ?",Space(20),Space(20),"mv_ch9","C",08,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","","CTT","","","",""})
	
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
Private cArquivo  := GetTempPath()+'VAGPER02_'+StrTran(dToC(dDataBase), '/', '-')+'_'+StrTran(Time(), ':', '-')+'.xml'
	
	oExcel := FWMSExcel():New()
	oExcel:SetFont('Arial Narrow')
	oExcel:SetBgColorHeader("#37752F") // cor de fundo linha cabeçalho
	oExcel:SetLineBgColor("#FFFFFF")   // cor da linha 1
	oExcel:Set2LineBgColor("#FFFFFF")  // cor da linha 2

	fQuadro1(cPerg)
	fQuadro2(cPerg)

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
Local cWorkSheet := "Sintético"
Local cTitulo	 := "Relação das marcações de pontos para vale combustível"

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)
oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)


_cQry := "  WITH PONTO AS (  " +CRLF
_cQry += CRLF
_cQry += "  		SELECT  SP8.P8_FILIAL, QB_DESCRIC, RA1.RA_NOME NOME, SRA.RA_CC, CTT_DESC01, SRA.RA_MAT, SRA.RA_NOME, RJ_DESC,  P8_DATA, COUNT(P8_DATA) REGISTROS    " +CRLF
_cQry += "  		FROM " + RetSqlName("SP8") + " SP8  " +CRLF
_cQry += "  		JOIN " + RetSqlName("SRA") + " SRA ON   " +CRLF
_cQry += "  				    RA_FILIAL = P8_FILIAL " +CRLF
_cQry += "  				AND RA_MAT = P8_MAT " +CRLF
_cQry += "  				AND SRA.RA_DEMISSA=' ' " +CRLF
_cQry += "  				AND SRA.D_E_L_E_T_ = ' ' " +CRLF
_cQry += "  		JOIN " + RetSqlName("SRJ") + " SRJ ON " +CRLF
_cQry += "  					SRJ.RJ_FILIAL = ' ' " +CRLF
_cQry += "  				AND SRJ.RJ_FUNCAO = RA_CODFUNC " +CRLF
_cQry += "  				AND SRJ.D_E_L_E_T_ = ' '   " +CRLF
_cQry += "          LEFT JOIN " + RetSqlName("CTT") + " CTT ON CTT_FILIAL=' ' AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ' ' " + CRLF
_cQry += "          LEFT JOIN " + RetSqlName("SQB") + " SQB ON QB_FILIAL=' ' AND QB_DEPTO = RA_DEPTO AND SQB.D_E_L_E_T_ = ' ' " + CRLF
_cQry += "          LEFT JOIN " + RetSqlName("SRA") + " RA1 ON RA1.RA_FILIAL = P8_FILIAL AND RA1.RA_MAT = SQB.QB_MATRESP AND RA1.RA_DEMISSA=' ' AND RA1.D_E_L_E_T_ = ' ' " + CRLF
_cQry += "  		WHERE   P8_FILIAL BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' " + CRLF
_cQry += "  			AND P8_DATA BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"' " + CRLF
_cQry += "          	AND SRA.RA_CC BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"' " + CRLF
_cQry += "				AND QB_DEPTO BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"' " + CRLF
_cQry += "  			AND P8_TPMCREP <> 'D' --AND P8_FLAG <> 'I'  " +CRLF
_cQry += "  			AND SP8.D_E_L_E_T_ = ' ' " +CRLF
_cQry += "  		GROUP BY SP8.P8_FILIAL, QB_DESCRIC, RA1.RA_NOME, SRA.RA_CC, CTT_DESC01, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CARGO, RJ_DESC, P8_DATA   " +CRLF
_cQry += CRLF
_cQry += "  )  " +CRLF
_cQry += CRLF
_cQry += "  SELECT DISTINCT QB_DESCRIC, NOME, RA_CC, CTT_DESC01, P8_FILIAL, RA_MAT, RA_NOME, RJ_DESC,  COUNT(P8_DATA) QT_DIAS, COUNT(P8_DATA)*"+cValtoChar(MV_PAR05)+" AS VALOR  " +CRLF
_cQry += "  FROM  PONTO  " +CRLF
_cQry += "  GROUP BY P8_FILIAL, QB_DESCRIC, NOME, RA_CC, CTT_DESC01, RA_MAT, RA_NOME, RJ_DESC    " +CRLF
_cQry += "  ORDER BY  RA_NOME  " +CRLF
_cQry += CRLF 

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
	
MemoWrite(StrTran(cArquivo,".xml","")+"Conferencia_ponto_vale_combu1.sql" , _cQry)

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"		         , 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Departamento"		     , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Encarregado"		     , 1, 1 )
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cod. Centr. Custos"	 , 1, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Centro de Custos"		 , 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Matricula"		     	 , 1, 1 )
 	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Nome"		     	     , 1, 1 )
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cargo"		     	     , 2, 1 )
	/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde dias"		     	 , 1, 1 )
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor"		     		 , 1, 3 )
	/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Total"		     , 1, 3, .T. )
	
	dbGotop()
	
	While !(cAlias)->(Eof())
	                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->P8_FILIAL, ;
							  (cAlias)->QB_DESCRIC, ;
							  (cAlias)->NOME, ;
							  (cAlias)->RA_CC, ;
							  (cAlias)->CTT_DESC01, ;							  
							  (cAlias)->RA_MAT, ;
							  (cAlias)->RA_NOME, ;
							  (cAlias)->RJ_DESC, ;
							  (cAlias)->QT_DIAS, ;
							  		   MV_PAR05, ;
							  (cAlias)->VALOR })
		
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
	
Return

Static Function fQuadro2(cPerg)

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Analítico"
Local cTitulo	 := "Relação das marcações de pontos para vale combustível"

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

_cQry := "  WITH PONTO AS (  " +CRLF
_cQry += CRLF
_cQry += "  		SELECT  SP8.P8_FILIAL, QB_DESCRIC, RA1.RA_NOME NOME, SRA.RA_CC, CTT_DESC01, SRA.RA_MAT, SRA.RA_NOME, RJ_DESC,  P8_DATA, COUNT(P8_DATA) REGISTROS    " +CRLF
_cQry += "  		FROM " + RetSqlName("SP8") + " SP8  " +CRLF
_cQry += "  		JOIN " + RetSqlName("SRA") + " SRA ON   " +CRLF
_cQry += "  				    RA_FILIAL = P8_FILIAL " +CRLF
_cQry += "  				AND RA_MAT = P8_MAT " +CRLF
_cQry += "  				AND SRA.RA_DEMISSA=' '  " +CRLF
_cQry += "  				AND SRA.D_E_L_E_T_ = ' '   " +CRLF
_cQry += "  		JOIN " + RetSqlName("SRJ") + " SRJ ON " +CRLF
_cQry += "  					SRJ.RJ_FILIAL = ' ' " +CRLF
_cQry += "  				AND SRJ.RJ_FUNCAO = RA_CODFUNC " +CRLF
_cQry += "  				AND SRJ.D_E_L_E_T_ = ' '   " +CRLF
_cQry += "          LEFT JOIN " + RetSqlName("CTT") + " CTT ON CTT_FILIAL=' ' AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ' ' " + CRLF
_cQry += "          LEFT JOIN " + RetSqlName("SQB") + " SQB ON QB_FILIAL=' ' AND QB_DEPTO = RA_DEPTO AND SQB.D_E_L_E_T_ = ' ' " + CRLF
_cQry += "          LEFT JOIN " + RetSqlName("SRA") + " RA1 ON RA1.RA_FILIAL = P8_FILIAL AND RA1.RA_MAT = SQB.QB_MATRESP AND RA1.RA_DEMISSA=' ' AND RA1.D_E_L_E_T_ = ' ' " + CRLF
_cQry += "  		WHERE P8_FILIAL BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' " + CRLF
_cQry += "  		  AND P8_DATA BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"' " + CRLF
_cQry += "            AND SRA.RA_CC BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"' " + CRLF
_cQry += "			  AND QB_DEPTO BETWEEN'"+MV_PAR06+"' AND '"+MV_PAR07+"' "
_cQry += "  		  AND P8_TPMCREP <> 'D' --AND P8_FLAG <> 'I'  " +CRLF
_cQry += "  		  AND SP8.D_E_L_E_T_ = ' '   " +CRLF
_cQry += "  		GROUP BY SP8.P8_FILIAL, QB_DESCRIC, RA1.RA_NOME, SRA.RA_CC, CTT_DESC01, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CARGO, RJ_DESC, P8_DATA   " +CRLF
_cQry += CRLF
_cQry += "  		)  " +CRLF
_cQry += CRLF
_cQry += "    SELECT * FROM PONTO" +CRLF

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

MemoWrite(StrTran(cArquivo,".xml","")+"Conferencia_ponto_vale_combu2.sql" , _cQry)

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
TcSetField(cAlias, "P8_DATA", "D")

/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"		         , 1, 1 )
/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Departamento"		     , 1, 1 )
/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Encarregado"		     , 1, 1 )
/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cod. Centr. Custos"	 , 1, 1 )
/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Centro de Custos"		 , 1, 1 )
/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Matricula"		     	 , 1, 1 )
/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Nome"		     	     , 1, 1 )
/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cargo"		     	     , 2, 1 )
/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data"		     	 	 , 1, 4 )
	
dbGotop()

While !(cAlias)->(Eof())
												
	oExcel:AddRow( cWorkSheet, cTitulo, ;
					{ (cAlias)->P8_FILIAL, ;
						(cAlias)->QB_DESCRIC, ;
						(cAlias)->NOME, ;
						(cAlias)->RA_CC, ;
						(cAlias)->CTT_DESC01, ; 
						(cAlias)->RA_MAT, ;
						(cAlias)->RA_NOME, ;
						(cAlias)->RJ_DESC, ;
						(cAlias)->P8_DATA })

	(cAlias)->(DbSkip())
EndDo
RestArea(aArea)

Return