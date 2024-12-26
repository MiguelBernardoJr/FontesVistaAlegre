#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

User Function VAEST024()
	
/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Arthru Toshio Oda VAnzella	                                          |
 | Data:  11.11.2017                                                              |
 | Desc:  Relatório de movimentação de animais.	                                  |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/

Private cPerg := nil
	nOrdem   :=0
	tamanho  :="P"
	limite   :=80
	titulo   :=PADC("VAEST024",74)
	cDesc1   :=PADC("Relatório - Resumo das informações contratuais",74)
	cDesc2   :=""
	cDesc3   :=""
	aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
	nomeprog :="VAEST024"
	cPerg      :="VAEST024"
	nLastKey := 0
	//wnrel    := "VAEST024"
	//_cQry2	 :=""

	ValidPerg(cPerg)
	
	While Pergunte(cPerg, .T.)
		MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
	Enddo

//	If Pergunte(cPerg, .T.)
		//MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
	//Endif
	
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

	AADD(aRegs,{cPerg,"01","Filial De              ?",Space(20),Space(20),"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})
	AADD(aRegs,{cPerg,"02","Filial Ate             ?",Space(20),Space(20),"mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})
	AADD(aRegs,{cPerg,"03","Data de         	   ?",Space(20),Space(20),"mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Data até        	   ?",Space(20),Space(20),"mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Corretor 	           ?",Space(20),Space(20),"mv_ch5","C",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA3","","","","",""})
	AADD(aRegs,{cPerg,"06","Fornecedor	           ?",Space(20),Space(20),"mv_ch6","C",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","","","",""})
	//AADD(aRegs,{cPerg,"07","Fornecedor De         ?",Space(20),Space(20),"mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	//AADD(aRegs,{cPerg,"08","Fornecedor Ate        ?",Space(20),Space(20),"mv_ch8","C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	

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
 
Private oExcel := nil
Private oExcelApp
oExcel := FWMSExcel():New()
Private cArquivo  := GetTempPath()+'VAEST024_'+StrTran(dToC(dDataBase), '/', '-')+'_'+StrTran(Time(), ':', '-')+'.xml'
oExcel:SetFont('Arial Narrow')
oExcel:SetBgColorHeader("#37752F") // cor de fundo linha cabeçalho
oExcel:SetLineBgColor("#FFFFFF")   // cor da linha 1
oExcel:Set2LineBgColor("#FFFFFF")  // cor da linha 2

fQuadro1()
fQuadro2()
fQuadro3()
fQuadro4()

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
Local _cQry      := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Base Contratual"
Local cTitulo	 := "Detalhes - Base Contratual"
cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)
	
	_cQry := "     SELECT CC.ZCC_CODIGO,  " + CRLF
	_cQry += "  		  CC.ZCC_CODFOR,  " + CRLF
	_cQry += "  		  CC.ZCC_NOMFOR,  " + CRLF
	_cQry += "  		  CC.ZCC_DDD,  " + CRLF
	_cQry += "  		  CC.ZCC_FONE,  " + CRLF
	_cQry += "  		  CC.ZCC_NOMCOR,  " + CRLF
	_cQry += "  		  CC.ZCC_QTDRES,  " + CRLF
	_cQry += "  		  CASE   " + CRLF
	_cQry += "  			WHEN ZCC_PAGFUT = 'N' THEN 'NAO'  " + CRLF
	_cQry += "  			ELSE 'SIM'  " + CRLF
	_cQry += "  			 END ZCC_PAGFUT,  " + CRLF
	_cQry += "  		CC.ZCC_DTVCTO,  " + CRLF
	_cQry += "  		CASE WHEN IC.ZIC_SEXO = 'M' THEN 'MACHO' "   + CRLF
	_cQry += "  		  	 WHEN IC.ZIC_SEXO = 'F' THEN 'FEMEA' " + CRLF
	_cQry += "			END AS ZIC_SEXO,"	
	_cQry += "  		CASE WHEN IC.ZIC_RACA = 'M' THEN 'MESTICO' "   + CRLF
	_cQry += "  		  	 WHEN IC.ZIC_RACA = 'N' THEN 'NELORE' " + CRLF
	_cQry += "  		  	 WHEN IC.ZIC_RACA = 'C' THEN 'CRUZAMENTO' " + CRLF
	_cQry += "  		  	 WHEN IC.ZIC_RACA = 'A' THEN 'ANGUS' " + CRLF
	_cQry += "			END AS ZIC_RACA,"	
	_cQry += "  		B1.B1_DESC,  " + CRLF
	_cQry += "  		IC.ZIC_QUANT,  " + CRLF
	_cQry += "  		IC.ZIC_QTDFEC,  " + CRLF
	_cQry += "  		CASE   " + CRLF
	_cQry += "  		  WHEN ZIC_TPNEG = 'P' THEN 'PESO X REND. X @'  " + CRLF
	_cQry += "  		  WHEN ZIC_TPNEG = 'K' THEN 'R$ / KG'  " + CRLF
	_cQry += "  		  ELSE 'R$ POR ANIMAL'   " + CRLF
	_cQry += "  		   END ZIC_TPNEG,  " + CRLF
	_cQry += "  		IC.ZIC_VLAROB,  " + CRLF
	_cQry += "  		IC.ZIC_TOTVLR,   " + CRLF
	_cQry += "  		BC.ZBC_PEDIDO,   " + CRLF
	_cQry += "  		BC.ZBC_ITEMPC,   " + CRLF
	_cQry += "  		BC.ZBC_DTENTR,  " + CRLF
	_cQry += "  		BC.ZBC_PRODUT,  " + CRLF
	_cQry += "  		BC.ZBC_QUANT,  " + CRLF
	_cQry += "  		BC.ZBC_VLRPTA,  " + CRLF
	_cQry += "  		BC.ZBC_ALIICM,  " + CRLF
	_cQry += "  		BC.ZBC_PESO,   " + CRLF
	_cQry += "  		BC.ZBC_PESOAN,   " + CRLF
	_cQry += "  		BC.ZBC_REND,  " + CRLF
	_cQry += "  		BC.ZBC_RENDP,  " + CRLF
	_cQry += "  		BC.ZBC_TTSICM,  " + CRLF
	_cQry += "  		BC.ZBC_VLUSIC,  " + CRLF
	_cQry += "  		BC.ZBC_TOTICM,   " + CRLF
	_cQry += "  		BC.ZBC_VLICM,   " + CRLF
	_cQry += "  		BC.ZBC_ICFRVL  " + CRLF
	_cQry += "       FROM " + RetSqlName('ZCC') + " CC  " + CRLF
	_cQry += " INNER JOIN " + RetSqlName('ZIC') + " IC  " + CRLF
	_cQry += "  	   ON CC.ZCC_FILIAL					=			IC.ZIC_FILIAL  " + CRLF
	_cQry += "  	  AND CC.ZCC_CODIGO					=			IC.ZIC_CODIGO  " + CRLF
	_cQry += "  	  AND CC.ZCC_VERSAO					=			IC.ZIC_VERSAO  " + CRLF
	_cQry += " INNER JOIN " + RetSqlName('ZBC') + " BC  " + CRLF
	_cQry += "  	   ON BC.ZBC_FILIAL					=			CC.ZCC_FILIAL  " + CRLF
	_cQry += "  	  AND BC.ZBC_CODIGO					=			CC.ZCC_CODIGO  " + CRLF
	_cQry += " INNER JOIN " + RetSqlName('SB1') + " B1  " + CRLF
	_cQry += "  	   ON B1.B1_COD						=			IC.ZIC_PRODUT	    " + CRLF
	_cQry += "  	WHERE   " + CRLF
	_cQry += "  		  CC.D_E_L_E_T_					=			' '   " + CRLF
	
	if !Empty(MV_PAR05)
	_cQry += "  	  AND ZCC_CODCOR					=			'"+ MV_PAR05 +"'  "+ CRLF
	EndIf
	if !Empty(MV_PAR06) 
	_cQry += "  	  AND ZCC_CODFOR					=			'"+ MV_PAR06 +"'  "+ CRLF
	EndIf
	
	_cQry += "  	  AND IC.D_E_L_E_T_					=			' '   " + CRLF
	_cQry += "  	  AND BC.D_E_L_E_T_					=			' '   " + CRLF
	_cQry += "  	  AND B1.D_E_L_E_T_					=			' '   " + CRLF
	_cQry += "  	  AND ZIC_ITEM						=			ZBC_ITEZIC  " + CRLF
	_cQry += "   ORDER BY ZCC_CODIGO, ZIC_ITEM  "
	
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro1.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
TcSetField(cAlias, "ZCC_DTVCTO", "D")
	//TcSetField(cAlias, "DT_DIGITACAO", "D")
			/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Código" 		                         , 1, 1 )
			/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cod Forn." 		                     , 1, 1 )
			/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Fornecedor"     	                     , 1, 1 )
			/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "DDD"     	                             , 1, 1 )
			/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Fone"     	                             , 1, 1 )
			/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Corretor" 		                         , 1, 1 )
			/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde Pend"	                             , 1, 1 )
			/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Pagto Fut?"     	                     , 1, 1 )
			/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Venc." 		                     , 1, 1 ) // quebra de seção                                                                                1  1 )
			/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Sexo"	                                 , 1, 1 )
			/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Raça"	                                 , 1, 1 )
			/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"	                             , 1, 1 )
			/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtd Negoci"     	                     , 1, 2 )
			/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtd com Pedido"     	                 , 1, 2 )
			/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Tipo Neogciacao" 		                 , 1, 1 )
			/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor"	                                 , 1, 3, .T. )
			/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Total Comissao" 		                 , 1, 3, .T. )//Section 3                                                                                1  1 )
			/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Num Pedido"	                         , 1, 1 )
			/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Item Pedido" 		                     , 1, 1 )
			/* 20 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Prev. Entrega"	                 , 1, 1 )
			/* 21 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Produto"	                             , 1, 1 )
			/* 22 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde"	                                 , 1, 2, .T. )
			/* 23 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Pauta"	                         , 1, 3 )
			/* 24 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Aliq. Pauta"	                         , 1, 2 )
			/* 25 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso"	                                 , 1, 2, .T. )
			/* 26 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Medio"	                         , 1, 2 )
			/* 27 */ oExcel:AddColumn( cWorkSheet, cTitulo, "% Rendim"	                             , 1, 2 )
			/* 28 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Rendimento"	                     , 1, 2 )
			/* 29 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Total Sem IMCS"	                     , 1, 3, .T. )
			/* 30 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Unitario sem ICMS"	                     , 1, 3, )
			/* 31 */ oExcel:AddColumn( cWorkSheet, cTitulo, "ICMS Gado "	                         , 1, 3 )
			/* 32 */ oExcel:AddColumn( cWorkSheet, cTitulo, "IMCS p/ Cabeça "	                         , 1, 3 )
			/* 33 */ oExcel:AddColumn( cWorkSheet, cTitulo, "ICMS Frete "	                         , 1, 3 )
			//Incluir Campo Memo (Observacao)
			
	(cAlias)->(dbGotop())
	
	While !(cAlias)->(Eof())
		oExcel:AddRow( cWorkSheet, cTitulo, ;
						{ (cAlias)->ZCC_CODIGO, ;
						  (cAlias)->ZCC_CODFOR, ;
						  (cAlias)->ZCC_NOMFOR, ;
						  (cAlias)->ZCC_DDD, ;
						  (cAlias)->ZCC_FONE, ;
						  (cAlias)->ZCC_NOMCOR, ;
						  (cAlias)->ZCC_QTDRES, ;
						  (cAlias)->ZCC_PAGFUT, ;
						  (cAlias)->ZCC_DTVCTO, ;
						  (cAlias)->ZIC_SEXO, ;
						  (cAlias)->ZIC_RACA, ;
						  (cAlias)->B1_DESC, ;
						  (cAlias)->ZIC_QUANT, ;
						  (cAlias)->ZIC_QTDFEC, ;
						  (cAlias)->ZIC_TPNEG, ;
						  (cAlias)->ZIC_VLAROB, ;
						  (cAlias)->ZIC_TOTVLR, ;
						  (cAlias)->ZBC_PEDIDO, ;
						  (cAlias)->ZBC_ITEMPC, ;
						  (cAlias)->ZBC_DTENTR, ;
						  (cAlias)->ZBC_PRODUT, ;
						  (cAlias)->ZBC_QUANT, ;
						  (cAlias)->ZBC_VLRPTA, ;
						  (cAlias)->ZBC_ALIICM, ;
						  (cAlias)->ZBC_PESO,  ;
						  (cAlias)->ZBC_PESOAN, ;
						  (cAlias)->ZBC_REND, ;
						  (cAlias)->ZBC_RENDP, ;
						  (cAlias)->ZBC_TTSICM, ;
						  (cAlias)->ZBC_VLUSIC, ;
						  (cAlias)->ZBC_TOTICM, ;
						  (cAlias)->ZBC_VLICM, ;
						  (cAlias)->ZBC_ICFRVL } )
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
	
Return


Static Function fQuadro2(cPerg)

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Notas Relacionadas"
Local cTitulo	 := "Detalhes - Base Contratual"
cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry := "  SELECT  D1.D1_FILIAL,   " + CRLF 
	_cQry += "  		D1.D1_FORNECE,   " + CRLF
	_cQry += "  		A2.A2_NOME,   " + CRLF
	_cQry += "  		D1.D1_PEDIDO,   " + CRLF
	_cQry += "  		D1.D1_DOC,   " + CRLF 
	_cQry += "  		D1.D1_EMISSAO,  " + CRLF
	_cQry += "  		D1.D1_COD,  " + CRLF
	_cQry += "  		B1.B1_DESC,  " + CRLF
	_cQry += "  		D1.D1_QUANT,  " + CRLF
	_cQry += "  		D1.D1_LOTECTL,  " + CRLF
	_cQry += "  		D1.D1_CF,  " + CRLF
	_cQry += "  		D1.D1_VUNIT,   " + CRLF
	_cQry += "  		D1.D1_TOTAL,   " + CRLF
	_cQry += "  		D1.D1_CUSTO,  " + CRLF
	_cQry += "  		D1.D1_BASEFUN,  " + CRLF
	_cQry += "  		D1.D1_ALIQFUN,  " + CRLF
	_cQry += "  		D1.D1_VALFUN,  " + CRLF
	_cQry += "  		D1.D1_BASEICM,  " + CRLF
	_cQry += "  		D1.D1_PICM,  " + CRLF
	_cQry += "  		D1.D1_VALICM,  " + CRLF
	_cQry += "  		D1.D1_X_EMBDT,  " + CRLF
	_cQry += "  		D1.D1_X_EMBHR,  " + CRLF
	_cQry += "  		D1.D1_X_CHEDT,  " + CRLF
	_cQry += "  		D1.D1_X_CHEHR,  " + CRLF
	_cQry += "  		D1.D1_X_JEJUM,   " + CRLF
	_cQry += "  		D1.D1_X_PESCH,  " + CRLF
	_cQry += "  		D1.D1_X_QUEKG,  " + CRLF
	_cQry += "  		D1.D1_X_QUECA,  " + CRLF
	_cQry += "  		D1.D1_X_KM,		  " + CRLF
	_cQry += "			D1C.D1_TOTAL	VLRCOMPL	  " + CRLF
	_cQry += "     FROM " + RetSqlName('SD1') + " D1  " + CRLF
	_cQry += "     JOIN " + RetSqlName('SB1') + " B1  " + CRLF
	_cQry += "       ON B1.B1_COD		=		D1.D1_COD  " + CRLF
	_cQry += "     JOIN " + RetSqlName('SA2') + " A2  " + CRLF
	_cQry += "       ON A2.A2_COD 		=		D1.D1_FORNECE  " + CRLF
	_cQry += "      AND A2.A2_LOJA 		=		D1.D1_LOJA  " + CRLF
	_cQry += "      AND A2.D_E_L_E_T_ 	=		' '   " + CRLF
	_cQry += "   LEFT JOIN " + RetSqlName('SD1') + " D1C ON D1C.D1_NFORI = D1.D1_DOC AND D1C.D1_SERIORI = D1.D1_SERIE AND D1C.D1_FORNECE = D1.D1_FORNECE AND D1C.D1_LOJA = D1.D1_LOJA AND D1C.D1_ITEMORI = D1.D1_ITEM AND D1C.D_E_L_E_T_ = ' ' AND D1C.D1_TIPO <> 'N'  " + CRLF
	_cQry += "    WHERE D1.D1_PEDIDO+D1.D1_FORNECE IN (  " + CRLF
	_cQry += "  					  SELECT DISTINCT(ZBC_PEDIDO+ZBC_CODFOR)  " + CRLF
	_cQry += "  					    FROM ZBC010 ZBC  " + CRLF
	_cQry += "  						JOIN ZCC010 ZCC   " + CRLF
	_cQry += "  						  ON ZCC_CODIGO			=		ZBC.ZBC_CODIGO  " + CRLF
	_cQry += "  						 AND ZCC_CODFOR			=		ZBC.ZBC_CODFOR  " + CRLF
	_cQry += "  						 AND ZCC_FILIAL			=		ZBC.ZBC_FILIAL  " + CRLF
	_cQry += "  						 AND ZCC.D_E_L_E_T_		=		' '   " + CRLF
	If !Empty(MV_PAR05)
	_cQry += "  						 AND ZCC_CODCOR			=		'"+ MV_PAR05 +"'  " + CRLF
	EndIf
	If !Empty(MV_PAR06)
	_cQry += "  						 AND ZCC_CODFOR			=		'"+ MV_PAR06 +"'  " + CRLF
	EndIf
	_cQry += "    					   WHERE ZBC.D_E_L_E_T_ = ' ' )  " + CRLF
		
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro2.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "D1_EMISSAO", "D")
	TcSetField(cAlias, "D1_X_EMBDT", "D")
	TcSetField(cAlias, "D1_X_CHEDT", "D")
	//TcSetField(cAlias, "DT_DIGITACAO", "D")
	
			/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial" 		                     , 1, 1 )
			/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cod Forneced"	                     , 1, 1 )
			/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Razao Social"	                     , 1, 1 )
			/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Ped. Compra" 	                     , 1, 1 )
			/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Num NF" 		                     , 1, 1 )
			/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Emissao"     	                     , 1, 1 )
			/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cod."     	                         , 2, 1 )
			/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"     	                 , 1, 1 )
			/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quantidade"     	                 , 1, 2 )
			/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote " 		                     , 1, 1 )
			/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CFOP"	                             , 1, 1 )
			/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Unit."     	                 , 1, 3 )
			/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Total" 		                     , 2, 3, .T. )
			//Section 2                                                                                     )
			/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo"	                             , 1, 3 )
			/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Base Funrural"	                     , 1, 3 )
			/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Aliq. Funrural"	                 , 2, 1 )
			/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Funrural"     	             , 1, 3 )
			/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Base ICMS"     	                 , 1, 3 )
			/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Aliq ICMS" 		                 , 2, 2 )
			/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor ICMS"	                     , 1, 3 )
			/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Embarq."	 		             , 1, 1 )                                     
			/* 16 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Hora Embarque"	                     , 1, 1 )
			/* 17 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Chegada" 		                 , 1, 1 )
			/* 18 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Hora Chegada"	                 	 , 1, 1 )
			/* 19 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Jejum"	                             , 1, 2 )
			/* 20 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Chegada"	                     , 1, 2 )
			/* 21 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quebra"	                         , 1, 2 )
			/* 22 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Quebra / Animal"	                 , 1, 2 )
			/* 23 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Distância"	                         , 1, 2 )
			/* 24 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Complemento"	                         , 1, 2 )
			
	dbGotop()
	
	While !(cAlias)->(Eof())
		oExcel:AddRow( cWorkSheet, cTitulo, ;
						{ (cAlias)->D1_FILIAL, ;
						  (cAlias)->D1_FORNECE, ;
						  (cAlias)->A2_NOME, ;
						  (cAlias)->D1_PEDIDO, ;
						  (cAlias)->D1_DOC, ;
						  (cAlias)->D1_EMISSAO, ;
						  (cAlias)->D1_COD, ;
						  (cAlias)->B1_DESC, ;
						  (cAlias)->D1_QUANT, ;
						  (cAlias)->D1_LOTECTL, ;
						  (cAlias)->D1_CF, ;
						  (cAlias)->D1_VUNIT, ;
						  (cAlias)->D1_TOTAL, ;
						  (cAlias)->D1_CUSTO, ;
						  (cAlias)->D1_BASEFUN, ;
						  (cAlias)->D1_ALIQFUN, ;
						  (cAlias)->D1_VALFUN, ;
						  (cAlias)->D1_BASEICM, ;
						  (cAlias)->D1_PICM, ;
						  (cAlias)->D1_VALICM, ;
						  (cAlias)->D1_X_EMBDT, ;
						  (cAlias)->D1_X_EMBHR, ;
						  (cAlias)->D1_X_CHEDT, ;
						  (cAlias)->D1_X_CHEHR, ;
						  (cAlias)->D1_X_JEJUM, ;
						  (cAlias)->D1_X_PESCH, ;
						  (cAlias)->D1_X_QUEKG, ;
						  (cAlias)->D1_X_QUECA, ;
						  (cAlias)->D1_X_KM, ;
						  (cAlias)->VLRCOMPL } )
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
	
Return


Static Function fQuadro3(cPerg)

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Estoque"
Local cTitulo	 := "Relação dos animais em estoques"
local dDataDigDe := CToD("") 
local dDataDigAt := CToD("")
Local nDiasConf:= ""

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)

dDataDigDe := DtoC(MV_PAR03)
dDataDigAt := DtoC(MV_PAR04)


oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry := "  SELECT B8.B8_FILIAL,   " + CRLF
	_cQry += "  	   B8.B8_PRODUTO,   " + CRLF
	_cQry += "  	   B1.B1_DESC,   " + CRLF
	_cQry += "		   SUBSTRING(B1_XLOTCOM,3,9) LOTE_COMPRA, " + CRLF
	_cQry += "  	   B8.B8_LOTECTL,   " + CRLF
	_cQry += "  	   B8.B8_X_CURRA,   " + CRLF
	_cQry += "  	   B8.B8_XDATACO,   " + CRLF
	//_cQry += " 	   	   B8.B8_DIASCO,  " + CRLF//CALCULAR DATA ATUAL - B8_XDATACO
	_cQry += "  	   B8.B8_XPESOCO,   " + CRLF
	_cQry += "  	   B8.B8_DIASCO,	" + CRLF
	_cQry += "  	   B8.B8_GMD, 		" + CRLF
	_cQry += "  	   B8.B8_XRENESP,  " + CRLF
	_cQry += "  	   B8.B8_SALDO  " + CRLF
	_cQry += "    FROM " + RetSqlName('SB8') + " B8  " + CRLF
	_cQry += "    JOIN " + RetSqlName('SB1') + " B1  " + CRLF
	_cQry += "      ON B8.B8_PRODUTO = B1.B1_COD  " + CRLF
	_cQry += "   WHERE B8.B8_PRODUTO IN (  " + CRLF
	_cQry += "  					  SELECT ZBC.ZBC_PRODUT    " + CRLF
	_cQry += "  						FROM ZBC010 ZBC    " + CRLF
	_cQry += "  						JOIN ZCC010 ZCC   " + CRLF
	_cQry += "  						  ON ZCC_CODIGO			=		ZBC.ZBC_CODIGO  " + CRLF
	_cQry += "  						 AND ZCC_CODFOR			=		ZBC.ZBC_CODFOR  " + CRLF
	_cQry += "  						 AND ZCC_FILIAL			=		ZBC.ZBC_FILIAL  " + CRLF
	_cQry += "  						 AND ZCC.D_E_L_E_T_		=		' '   " + CRLF
	If !Empty(MV_PAR05)
	_cQry += "  						 AND ZCC_CODCOR			=		'"+ MV_PAR05 +"'  " + CRLF
	EndIf
	If !Empty(MV_PAR06)
	_cQry += "  						 AND ZCC_CODFOR			=		'"+ MV_PAR06 +"'  " + CRLF
	EndIf
	_cQry += "    					   WHERE ZBC.D_E_L_E_T_ = ' '  " + CRLF
	_cQry += "    					  )    " + CRLF
	_cQry += "       AND B1.D_E_L_E_T_ = ' '     " + CRLF
	_cQry += "       AND B8.D_E_L_E_T_ = ' '   " + CRLF
	_cQry += "       AND B8.B8_SALDO > 0   " + CRLF
 		
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro3.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "B8_XDATACO", "D")
	//TcSetField(cAlias, "DT_DIGITACAO", "D")
			/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial" 		                     , 1, 1 )
			/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Produto" 		                     , 1, 1 )
			/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"     	                 , 1, 1 )
			/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote Compra"     	                 , 1, 1 )
			/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"     	                         , 1, 1 )
			/* 06*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Curral"     	                 	 , 1, 1 )
			/* 07*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Ini. Conf." 		             , 1, 1 )
			/* 08*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Dias Confinado" 		             , 1, 1 )
			/* 08*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Dias Projetado"                      , 1, 2 )
			/* 09*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Confin."	                     , 1, 2 )
			/* 00*/ oExcel:AddColumn( cWorkSheet, cTitulo, "GMD Esperado"     	                 , 1, 2 )
			/* 10*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Rend Esperado" 		            	 , 1, 2 )
			/* 11*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Projetado" 		             , 1, 2 )
			/* 12*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Peso Rend. Proj." 		             , 1, 2 )
			/* 13*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Saldo"	                             , 1, 2, .T. )
						
	
	dbGotop()
	
	While !(cAlias)->(Eof())
	If !Empty((cAlias)->B8_XDATACO)
	nDiasConf := dDatabase - (cAlias)->B8_XDATACO
	Else 
	nDiasConf := 0
	EndIf 
		oExcel:AddRow( cWorkSheet, cTitulo, ;
						{ (cAlias)->B8_FILIAL, ;
						  (cAlias)->B8_PRODUTO, ;
						  (cAlias)->B1_DESC, ;
						  (cAlias)->LOTE_COMPRA, ;
						  (cAlias)->B8_LOTECTL, ;
						  (cAlias)->B8_X_CURRA, ;
						  (cAlias)->B8_XDATACO, ;
						  nDiasConf, ;
						  (cAlias)->B8_XPESOCO, ;
						  (cAlias)->B8_DIASCO, ;
						  (cAlias)->B8_GMD, ;
						  (cAlias)->B8_XRENESP, ;
						  (cAlias)->B8_XPESOCO + ((cAlias)->B8_DIASCO * (cAlias)->B8_GMD), ;
						  (((cAlias)->B8_XRENESP / 1 / 100) * ((cAlias)->B8_XPESOCO + ((cAlias)->B8_DIASCO * (cAlias)->B8_GMD))), ;
						  (cAlias)->B8_SALDO } )
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
	
Return



Static Function fQuadro4(cPerg)

Local aArea 	 := getArea()
Local _cQryB	 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Trato"
Local cTitulo	 := "Trato Animal"
local dDataDigDe := CToD("") 
local dDataDigAt := CToD("")

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)

dDataDigDe := DtoS(MV_PAR03)
dDataDigAt := DtoS(MV_PAR04)

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

	_cQry := "  SELECT 	   	   D31.D3_FILIAL				AS		FILIAL,  " + CRLF  
	_cQry += "  			   D31.D3_EMISSAO				AS		DATA,  " + CRLF 
	_cQry += "  			   D3.D3_COD					AS		CODIGO,   " + CRLF 
	_cQry += "  			   D3.D3_LOTECTL				AS		LOTE,  " + CRLF 
	_cQry += "  			   D3.D3_QUANT					AS		QTD,  " + CRLF 
	_cQry += "  			   B11.B1_DESC					AS		DESCRICAO,		  " + CRLF  
	_cQry += "  			   D3.D3_TM						AS		TM,  " + CRLF 
	_cQry += "  			   F5.F5_TEXTO					AS		DESC_TM,  " + CRLF 
	_cQry += "  			   D31.D3_COD					AS		COD_INSUMO,  " + CRLF 
	_cQry += "  			   B1.B1_DESC					AS		DESC_INSUMO,  " + CRLF    
	_cQry += "  			   D31.D3_QUANT					AS		QT_INSUMO,  " + CRLF  
	_cQry += "  			   (D31.D3_CUSTO1/D31.D3_QUANT) AS 		CUSTO_UNIT,  " + CRLF  
	_cQry += "  			   D31.D3_CUSTO1				AS		CUSTO,  " + CRLF 
	_cQry += "  			   D3.D3_OP  					AS		OP" + CRLF 
	_cQry += "  		  FROM " + RetSqlName('SD3') + " D3   " + CRLF 
	_cQry += "  	INNER JOIN " + RetSqlName('SD3') + " D31 ON  " + CRLF 
	_cQry += "  			   D31.D3_OP				=				D3.D3_OP  " + CRLF 
	_cQry += "  		   AND D31.D_E_L_E_T_			=				' '   " + CRLF  
	_cQry += "  		   AND D31.D3_GRUPO				=				'03'  " + CRLF  
	_cQry += "  	INNER JOIN " + RetSqlName('SB1') + " B11 ON  " + CRLF 
	_cQry += "  		       B11.B1_COD				=				D3.D3_COD  " + CRLF 
	_cQry += "  		   AND B11.D_E_L_E_T_			=				' '   " + CRLF 
	_cQry += "  	INNER JOIN " + RetSqlName('SF5') + " F5 ON  " + CRLF 
	_cQry += "  			   F5_CODIGO = D3.D3_TM  " + CRLF 
	_cQry += "  		   AND F5.D_E_L_E_T_			=				' '  " + CRLF 
	_cQry += "  	INNER JOIN " + RetSqlName('SB1') + " B1 ON  " + CRLF 
	_cQry += "  			   D31.D3_COD				=				B1.B1_COD  " + CRLF 
	_cQry += "  	     WHERE D3.D3_FILIAL				BETWEEN			'" + MV_PAR01 + "' AND		'" + MV_PAR02 + "'  " + CRLF 
	_cQry += "  		     " + CRLF 
	//_cQry += "  		   AND D3.D3_COD				IN				('BOV000000000751')--('108-12','95-6/')  " + CRLF 
	_cQry += "  		   AND D3.D3_EMISSAO			BETWEEN			'"+ dDataDigDe +"' AND '"+ dDataDigAt +"'  " + CRLF 
	_cQry += "  	       AND D3.D3_CF					=				'PR0'   " + CRLF 
	_cQry += "  	       AND D3.D_E_L_E_T_			=				' '   " + CRLF 
	_cQry += "  		   AND D3.D3_LOTECTL			<> ' '   " + CRLF
	_cQry += "  		   AND D3.D3_COD 	IN (  " + CRLF
	_cQry += "  					  SELECT ZBC.ZBC_PRODUT    " + CRLF
	_cQry += "  						FROM ZBC010 ZBC    " + CRLF
	_cQry += "  						JOIN ZCC010 ZCC   " + CRLF
	_cQry += "  						  ON ZCC_CODIGO			=		ZBC.ZBC_CODIGO  " + CRLF
	_cQry += "  						 AND ZCC_CODFOR			=		ZBC.ZBC_CODFOR  " + CRLF
	_cQry += "  						 AND ZCC_FILIAL			=		ZBC.ZBC_FILIAL  " + CRLF
	_cQry += "  						 AND ZCC.D_E_L_E_T_		=		' '   " + CRLF
	If !Empty(MV_PAR05)
	_cQry += "  						 AND ZCC_CODCOR			=		'"+ MV_PAR05 +"'  " + CRLF
	EndIf
	If !Empty(MV_PAR06)
	_cQry += "  						 AND ZCC_CODFOR			=		'"+ MV_PAR06 +"'  " + CRLF
	EndIf
	_cQry += "    					   WHERE ZBC.D_E_L_E_T_ = ' '  " + CRLF
	_cQry += "    					  )    " + CRLF
	_cQry += "       AND B1.D_E_L_E_T_ = ' '     " + CRLF
	_cQry += "  	  ORDER BY D31.D3_FILIAL,   " + CRLF 
	_cQry += "  			   D3.D3_COD,   " + CRLF 
	_cQry += "  			   D31.D3_EMISSAO  "  
	
		
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro4.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "D3_EMISSAO", "D")
	
			/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial" 		             	, 1, 1 )
			/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data" 		             		, 1, 1 )
			/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Código"     	             	, 1, 1 )
			/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Lote"     	             		, 2, 1 )
			/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde"     	             		, 1, 2 )
			/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao" 		            , 1, 1 )
			/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "TM"	                 		, 1, 1 )
			/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Desc."   	             		, 1, 1 )
			/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cod. Insumo" 		            , 2, 1 )
			/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao Insumo"              , 1, 1 )
			/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtd Insumo"                    , 1, 2 )
			/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo"         	            , 1, 3 )
			/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo Total"                   , 1, 3 )
			/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Ordem Producao"                , 1, 1 )

	dbGotop()
	
	While !(cAlias)->(Eof())
		oExcel:AddRow( cWorkSheet, cTitulo, ;
						{ (cAlias)->FILIAL, ;
						  (cAlias)->DATA, ;
						  (cAlias)->CODIGO, ;
						  (cAlias)->LOTE, ;
						  (cAlias)->QTD, ;
						  (cAlias)->DESCRICAO, ;
						  (cAlias)->TM, ;
						  (cAlias)->DESC_TM, ;
						  (cAlias)->COD_INSUMO, ;
						  (cAlias)->DESC_INSUMO, ;
						  (cAlias)->QT_INSUMO, ;
						  (cAlias)->CUSTO_UNIT, ;
						  (cAlias)->CUSTO, ;
						  (cAlias)->OP } )
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
	
Return
