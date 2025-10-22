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

/*
	To Do - Atualmente o valor diário de combustivel é preenchido no parametro MV_PAR05.
	
	Com o campo novo criado RA_VLRDIA - substituir o parametro por esse campo:

	Adicionar o campo ao SQL da funções fQuadro1 e fQuadro2

	Com o resultado do SQL, adicionar o retorno ao objeto: oExcel:AddRow

*/
	
user function VAGPER02()

	Private cPerg := "VAGPER02"
	
	ValidPerg(cPerg)
	
	While Pergunte(cPerg, .T.)
		MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
	Enddo

Return

Static Function ValidPerg(cPerg)
	Local _aArea	:= GetArea()
	Local aRegs     := {}
	Local nX		:= 0
	Local j         := 0
	Local i         := 0
	Local nPergs	:= 0

	//Conta quantas perguntas existem ualmente.
	DbSelectArea('SX1')
	DbSetOrder(1)
	SX1->(DbGoTop())
	If SX1->(DbSeek(cPerg))
		While !SX1->(Eof()) .And. X1_GRUPO = cPerg
			nPergs++
			SX1->(DbSkip())
		EndDo
	EndIf
	cPerg := PADR(cPerg,10)
	aRegs:={}                                              

	AADD(aRegs,{cPerg,"01","Filial de:	    ?",Space(20),Space(20),"mv_ch1","C",02,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","",""})
	AADD(aRegs,{cPerg,"02","Filial Ate:	    ?",Space(20),Space(20),"mv_ch2","C",02,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","",""})
	AADD(aRegs,{cPerg,"03","Data de         ?",Space(20),Space(20),"mv_ch3","D",08,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Data até        ?",Space(20),Space(20),"mv_ch4","D",08,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AADD(aRegs,{cPerg,"05","Valor p/ dia  ?",Space(20),Space(20),"mv_ch5","N",08,2,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Depart. De:	    ?",Space(20),Space(20),"mv_ch5","C",08,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","SQB","","","",""})
	AADD(aRegs,{cPerg,"06","Depart. Ate:    ?",Space(20),Space(20),"mv_ch6","C",08,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","SQB","","","",""})
	AADD(aRegs,{cPerg,"07","C. Custo de:	?",Space(20),Space(20),"mv_ch7","C",08,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","CTT","","","",""})
	AADD(aRegs,{cPerg,"08","C. Custo Ate:   ?",Space(20),Space(20),"mv_ch8","C",08,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","CTT","","","",""})
	
	SX1->(DbGoTop())  
	If nPergs <> Len(aRegs)
		For nX:=1 To nPergs
			If SX1->(DbSeek(cPerg))		
				If RecLock('SX1',.F.)
					SX1->(DbDelete())
					SX1->(MsUnlock())
				EndIf
			EndIf
		Next nX
	EndIf

	// gravação das perguntas na tabela SX1
	If nPergs <> Len(aRegs)
		dbSelectArea("SX1")
		dbSetOrder(1)
		For i := 1 to Len(aRegs)
			If !dbSeek(cPerg+aRegs[i,2])
				RecLock("SX1",.T.)
					For j := 1 to FCount()
						If j <= Len(aRegs[i])
							FieldPut(j,aRegs[i,j])
						Endif
					Next j
				MsUnlock()
			EndIf
		Next i
	EndIf
	RestArea(_aArea)
Return

Static Function ImprRel(cPerg)  

	// Tratamento para Excel
	Private oExcel := nil
	Private oExcelApp
	Private cArquivo  := "C:\totvs_relatorios\" +'VAGPER02_'+StrTran(dToC(dDataBase), '/', '-')+'_'+StrTran(Time(), ':', '-')+'.xml' //GetTempPath()+'VAGPER02_'+StrTran(dToC(dDataBase), '/', '-')+'_'+StrTran(Time(), ':', '-')+'.xml'
		
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
	Local cAlias     := ""
	Local cWorkSheet := "Sintético"
	Local cTitulo	 := "Relação das marcações de pontos para vale combustível"

	cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)
	oExcel:AddworkSheet(cWorkSheet)
	oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry := "  WITH PONTO AS (  " + CRLF
	_cQry += "		SELECT SP8.P8_FILIAL,SRA.RA_NASC, QB_DESCRIC, RA1.RA_NOME NOME_GESTOR, SRA.RA_CC, CTT_DESC01, SRA.RA_MAT,SRA.RA_CIC ,SRA.RA_NOME, RJ_DESC,  P8_DATA,SRA.RA_VALORDI, COUNT(P8_DATA) REGISTROS      " + CRLF 
	_cQry += "		FROM " + RetSqlName("SP8") + " SP8   " + CRLF
	_cQry += "		JOIN " + RetSqlName("SRA") + " SRA ON    " + CRLF
	_cQry += "					RA_FILIAL = P8_FILIAL  " + CRLF
	_cQry += "				AND RA_MAT = P8_MAT  " + CRLF
	_cQry += "				AND SRA.D_E_L_E_T_ = ' '  " + CRLF
	_cQry += "		JOIN " + RetSqlName("SRJ") + " SRJ ON  " + CRLF
	_cQry += "					SRJ.RJ_FILIAL = ' '  " + CRLF
	_cQry += "				AND SRJ.RJ_FUNCAO = RA_CODFUNC  " + CRLF
	_cQry += "				AND SRJ.D_E_L_E_T_ = ' '  " + CRLF
	_cQry += "		LEFT JOIN " + RetSqlName("CTT") + " CTT ON CTT_FILIAL=RA_FILIAL AND CTT_CUSTO = SRA.RA_CC AND CTT.D_E_L_E_T_ = ' '  " + CRLF
	_cQry += "		LEFT JOIN " + RetSqlName("SQB") + " SQB ON QB_FILIAL=' ' AND QB_DEPTO = RA_DEPTO AND SQB.D_E_L_E_T_ = ' '  " + CRLF
	_cQry += "		LEFT JOIN " + RetSqlName("SRA") + " RA1 ON RA1.RA_FILIAL = P8_FILIAL AND RA1.RA_MAT = SQB.QB_MATRESP AND RA1.D_E_L_E_T_ = ' '  " + CRLF
	_cQry += "		WHERE   P8_FILIAL BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' " + CRLF
	_cQry += "			AND P8_DATA BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"' " + CRLF
	_cQry += "			AND SRA.RA_CC BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + CRLF
	_cQry += "				AND QB_DEPTO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + CRLF
	_cQry += "			AND P8_TPMCREP <> 'D' --AND P8_FLAG <> 'I'   " + CRLF
	_cQry += "			AND SP8.D_E_L_E_T_ = ' '  " + CRLF
	_cQry += " 		GROUP BY SP8.P8_FILIAL,SRA.RA_NASC, QB_DESCRIC, RA1.RA_NOME, SRA.RA_CC, CTT_DESC01, SRA.RA_MAT,SRA.RA_CIC, SRA.RA_NOME, SRA.RA_CARGO, RJ_DESC, SRA.RA_VALORDI,P8_DATA " + CRLF
	_cQry += " )   " + CRLF
	_cQry += " SELECT DISTINCT QB_DESCRIC,RA_NASC, NOME_GESTOR, RA_CC, CTT_DESC01, P8_FILIAL, RA_MAT,RA_CIC, RA_NOME, RJ_DESC, RA_VALORDI,  COUNT(P8_DATA) QT_DIAS, COUNT(P8_DATA)*RA_VALORDI AS VALOR   " + CRLF
	_cQry += " FROM  PONTO   " + CRLF
	_cQry += " GROUP BY P8_FILIAL, QB_DESCRIC, RA_NASC,NOME_GESTOR, RA_CC, CTT_DESC01, RA_MAT,RA_CIC, RA_NOME, RJ_DESC,RA_VALORDI     " + CRLF
	_cQry += " ORDER BY  RA_NOME " + CRLF
	
	if cUsername $ "Administrador,admin,wmiccoli"
		MemoWrite(StrTran(cArquivo,".xml","")+"Conferencia_ponto_vale_combu1.sql" , _cQry)
	endif

	cAlias := MpSysOpenQuery(_cQry)

	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"		         , 1, 1 	 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Centro de Custos"		 , 1, 1 	 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Matricula"		     	 , 1, 1 	 )
 	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Nome"		     	     , 1, 1 	 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Departamento"		     , 1, 1 	 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CPF"		     	     , 2, 1 	 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data de Nascimento"	 , 2, 1 	 )
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cargo"		     	     , 2, 1 	 )
	/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde dias"		     	 , 1, 1 	 )
	/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor"		     		 , 1, 3 	 )
	/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Total"		     , 1, 3, .T. )
	
	(cAlias)->(dbGotop())
	
	While !(cAlias)->(Eof())
	                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->P8_FILIAL, ;
							  (cAlias)->RA_CC, ;
							  (cAlias)->RA_MAT, ;
							  (cAlias)->RA_NOME, ;
							  (cAlias)->QB_DESCRIC, ;
							  (cAlias)->RA_CIC, ;
							  dToC(sToD((cAlias)->RA_NASC)), ;
							  (cAlias)->RJ_DESC, ;
							  (cAlias)->QT_DIAS, ;
							  (cAlias)->RA_VALORDI,; // cValToChar((cAlias)->RA_VALORDI),;
							  (cAlias)->VALOR })
		
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
	
Return

Static Function fQuadro2(cPerg)

	Local aArea 	 := getArea()
	Local _cQry		 := ''
	Local cAlias     := ""
	Local cWorkSheet := "Analítico"
	Local cTitulo	 := "Relação das marcações de pontos para vale combustível"

	cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)

	oExcel:AddworkSheet(cWorkSheet)
	oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry := "  WITH PONTO AS (  " +CRLF
	_cQry += CRLF
	_cQry += "  		SELECT DISTINCT SP8.P8_FILIAL, QB_DESCRIC,SRA.RA_NASC,SRA.RA_CIC, SRA.RA_NOME NOME, SRA.RA_CC, CTT_DESC01, SRA.RA_MAT, SRA.RA_NOME, RJ_DESC,  P8_DATA, COUNT(P8_DATA) REGISTROS    " +CRLF
	_cQry += "  		FROM " + RetSqlName("SP8") + " SP8  " +CRLF
	_cQry += "  		JOIN " + RetSqlName("SRA") + " SRA ON   " +CRLF
	_cQry += "  				    RA_FILIAL = P8_FILIAL " +CRLF
	_cQry += "  				AND RA_MAT = P8_MAT " +CRLF
	_cQry += "  				AND SRA.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "  		JOIN " + RetSqlName("SRJ") + " SRJ ON " +CRLF
	_cQry += "  					SRJ.RJ_FILIAL = ' ' " +CRLF
	_cQry += "  				AND SRJ.RJ_FUNCAO = RA_CODFUNC " +CRLF
	_cQry += "  				AND SRJ.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "          LEFT JOIN " + RetSqlName("CTT") + " CTT ON CTT_FILIAL=' ' AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "          LEFT JOIN " + RetSqlName("SQB") + " SQB ON QB_FILIAL=' ' AND QB_DEPTO = RA_DEPTO AND SQB.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "          LEFT JOIN " + RetSqlName("SRA") + " RA1 ON RA1.RA_FILIAL = P8_FILIAL AND RA1.RA_MAT = SQB.QB_MATRESP AND RA1.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "  		WHERE P8_FILIAL BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' " + CRLF
	_cQry += "  		  AND P8_DATA BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"' " + CRLF
	_cQry += "            AND SRA.RA_CC BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + CRLF
	_cQry += "			  AND QB_DEPTO BETWEEN'"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	_cQry += "  		  AND P8_TPMCREP <> 'D' --AND P8_FLAG <> 'I'  " +CRLF
	_cQry += "  		  AND SP8.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "  		GROUP BY SP8.P8_FILIAL, QB_DESCRIC,SRA.RA_NASC,SRA.RA_CIC, RA1.RA_NOME, SRA.RA_CC, CTT_DESC01, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CARGO, RJ_DESC, P8_DATA   " +CRLF
	_cQry += CRLF
	_cQry += "  		)  " +CRLF
	_cQry += CRLF
	_cQry += "    SELECT * FROM PONTO" +CRLF

	if cUsername $ "Administrador,admin,wmiccoli"
		MemoWrite(StrTran(cArquivo,".xml","")+"Conferencia_ponto_vale_combu2.sql" , _cQry)
	endif

	cAlias := MpSysOpenQuery(_cQry)

	TcSetField(cAlias, "P8_DATA", "D")

	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"		         , 1, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Centro de Custos"		 , 1, 1 )
	/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Matricula"		     	 , 1, 1 )
	/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Nome"		     	     , 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Departamento"		     , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CPF"				     , 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Dt Nascimento"		     , 1, 1 )
	/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cargo"		     	     , 2, 1 )
	/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data"		     	 	 , 1, 4 )
		
	(cAlias)->(dbGotop())

	While !(cAlias)->(Eof())
													
		oExcel:AddRow( cWorkSheet, cTitulo, ;
						{ (cAlias)->P8_FILIAL, ;
							(cAlias)->RA_CC, ;
							(cAlias)->RA_MAT, ;
							(cAlias)->NOME, ;
							(cAlias)->QB_DESCRIC, ;
							(cAlias)->RA_CIC, ; 
							dToC(sToD((cAlias)->RA_NASC)), ;
							(cAlias)->RJ_DESC, ;
							(cAlias)->P8_DATA })

		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)

Return
