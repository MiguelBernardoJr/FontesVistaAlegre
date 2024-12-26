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
 | Desc:  Relatório de movimentação de animais.	                                  |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/

user function VAEST026()

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
	cPerg      :="VAEST026"
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
	
return

Static Function ValidPerg(cPerg)
Local _sAlias,i,j

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}                                                  

	//AADD(aRegs,{cPerg,"01","Filial De             ?",Space(20),Space(20),"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AADD(aRegs,{cPerg,"02","Filial Ate            ?",Space(20),Space(20),"mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"01","Data de         	   ?",Space(20),Space(20),"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Data até          	   ?",Space(20),Space(20),"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Fornecedor             ?",Space(20),Space(20),"mv_ch3","C",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA2MKB","","","","",""})
	//AADD(aRegs,{cPerg,"04","TM Morte	           ?",Space(20),Space(20),"mv_ch6","C",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AADD(aRegs,{cPerg,"07","Fornecedor De         ?",Space(20),Space(20),"mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	//AADD(aRegs,{cPerg,"08","Fornecedor Ate        ?",Space(20),Space(20),"mv_ch8","C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	//AADD(aRegs,{cPerg,"09","Loja De               ?",Space(20),Space(20),"mv_ch9","C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AADD(aRegs,{cPerg,"10","Loja Ate              ?",Space(20),Space(20),"mv_cha","C",02,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})		
	//AADD(aRegs,{cPerg,"11","Grupo (sep.p/ ';')    ?",Space(20),Space(20),"mv_chb","C",99,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AADD(aRegs,{cPerg,"12","Produto De            ?",Space(20),Space(20),"mv_chc","C",15,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","SB1_X","","","","",""})
	//AADD(aRegs,{cPerg,"13","Produto Até           ?",Space(20),Space(20),"mv_chd","C",15,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","SB1_X","","","","",""})

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
Private cArquivo  := GetTempPath()+'VAEST026_'+StrTran(dToC(dDataBase), '/', '-')+'_'+StrTran(Time(), ':', '-')+'.xml'
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
Local cWorkSheet := "Relação das Movimentações"
Local cTitulo	 := "Relação dos materiais entregues para Terceiros "
cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " - " + DtoC(MV_PAR02)
oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)


	_cQry := "  			SELECT D3_FILIAL,  " + CRLF
	_cQry += "  				   D3.D3_EMISSAO EMISSAO,  " + CRLF
	_cQry += "  				   D3.D3_COD,  " + CRLF
	_cQry += "  				   B1_DESC,  " + CRLF
	_cQry += "  				   D3_UM,  " + CRLF
	_cQry += "  				   D3.D3_QUANT,  " + CRLF
	_cQry += "  				   D3_TM,   " + CRLF
	_cQry += "  				   F5.F5_TEXTO,  " + CRLF
	_cQry += "  				   D3.D3_OBS,  " + CRLF
	_cQry += "  				   D3.D3_OBSERVA,  " + CRLF
	_cQry += "  				   D3.D3_CUSTO1,  " + CRLF
	_cQry += "  				   D3_CC,   " + CRLF
	_cQry += "  				   D3_ITEMCTA,  " + CRLF
	_cQry += "  				   D3_FORNECE+'-'+D3_LOJA COD_FORN, " + CRLF
	_cQry += "  				   A2.A2_NOME  " + CRLF
	_cQry += "  			  FROM "+RetSqlName("SD3")+" D3   " + CRLF
	_cQry += "  			  JOIN "+RetSqlName("SB1")+" B1  " + CRLF
	_cQry += "  			    ON B1.B1_COD				=				D3.D3_COD   " + CRLF
	_cQry += "  			   AND B1.D_E_L_E_T_			=				' '   " + CRLF
	_cQry += "  			  JOIN "+RetSqlName("SF5")+" F5  " + CRLF
	_cQry += "  			    ON F5_CODIGO				=				D3.D3_TM  " + CRLF
	_cQry += "  			   AND F5.D_E_L_E_T_			=				' '   " + CRLF
	_cQry += "  			  JOIN "+RetSqlName("SA2")+" A2  " + CRLF
	_cQry += "  			    ON D3.D3_FORNECE			=				A2.A2_COD  " + CRLF
	_cQry += "  			   AND D3.D3_LOJA				=				A2.A2_LOJA  " + CRLF
	_cQry += "  			   AND A2.D_E_L_E_T_			=				' '   " + CRLF
	_cQry += "  			 WHERE D3_EMISSAO BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'   " + CRLF
	_cQry += "  			   AND D3.D_E_L_E_T_ = ' '   " + CRLF
	_cQry += "  			   AND D3_FORNECE <> ' '   " + CRLF
	If !Empty(MV_PAR03)
	_cQry += "  			   AND D3_FORNECE = '" +MV_PAR03+ "'   " + CRLF
	EndIf

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
		MemoWrite(StrTran(cArquivo,".xml","")+"Quadro1.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "EMISSAO", "D")

	
		/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"		      		 , 1, 1 )
		/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Data"		      		 	 , 1, 1 )
		/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Codigo"		      		 , 1, 1 )
		/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Descricao"		      		 , 1, 1 )
		/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Unidade"		      		 , 1, 1 )
		/* 06 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Qtde"		      		 	 , 1, 2 )
		/* 07 */ oExcel:AddColumn( cWorkSheet, cTitulo, "TM"		      		 	 , 1, 1 )
		/* 08 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Desc. TM"		      		 , 1, 1 )
		/* 09 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Obsevacao"		      		 , 1, 1 )
		/* 10 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Obsevacao1"		      	 , 1, 1 )
		/* 11 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Custo"		      		 	 , 1, 1 )
		/* 12 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Centro de Custo"		     , 1, 1 )
		/* 13 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Item Contabil"		      	 , 1, 1 )
		/* 14 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Cod Forn."		      		 , 1, 1 )
		/* 15 */ oExcel:AddColumn( cWorkSheet, cTitulo, "Fornecedor"		      	 , 1, 1 )
		
			dbGotop()
	
	While !(cAlias)->(Eof())
	                                             
			oExcel:AddRow( cWorkSheet, cTitulo, ;
							{ (cAlias)->D3_FILIAL, ;
							  (cAlias)->EMISSAO, ;
							  (cAlias)->D3_COD, ;
							  (cAlias)->B1_DESC, ;
							  (cAlias)->D3_UM, ;
							  (cAlias)->D3_QUANT, ;
							  (cAlias)->D3_TM, ;
							  (cAlias)->F5_TEXTO, ;
							  (cAlias)->D3_OBS, ;
							  (cAlias)->D3_OBSERVA, ;
							  (cAlias)->D3_CUSTO1, ;
							  (cAlias)->D3_CC, ;
							  (cAlias)->D3_ITEMCTA, ;
							  (cAlias)->COD_FORN, ;
							  (cAlias)->A2_NOME  } )
							  
							  
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea)
	
Return


