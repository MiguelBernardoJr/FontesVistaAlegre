#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "TOPCONN.CH"
#include 'FILEIO.CH'

/*--------------------------------------------------------------------------------,
 | Principal: 			            U_PCPREL05()            		              |
 | Func:  PCPREL05()	            	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  09.09.2019	            	          	            	              |
 | Desc:  Relatório de Análise de Consumo                         	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
User Function PCPREL05()
Local cTimeIni	 	:= Time()
Local cStyle		:= ""
Local cXML	   		:= ""
Local lTemDados		:= .T.

Private cPerg		:= SubS(ProcName(),3)
Private cTitulo  	:= "Relatorio de Analise de Consumo"

Private cPath 	 	:= "C:\TOTVS_RELATORIOS\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase) + "_"+; 
								StrTran(SubS(Time(),1,5),":","") + ".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()   

Private nHandle    	:= 0

GeraX1(cPerg)

If Pergunte(cPerg, .T.)
	U_PrintSX1(cPerg)
	
	If Len( Directory(cPath + "*.*","D") ) == 0
		If Makedir(cPath) == 0
			ConOut('Diretorio Criado com Sucesso.')
			MsgAlert('Diretorio Criado com Sucesso: ' + cPath, 'Aviso')
		Else	
			ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
			MsgAlert( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ), 'Aviso' )
		EndIf
	EndIf
	
	nHandle := FCreate(cArquivo)
	if nHandle = -1
		conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	else
		
		cStyle := U_defStyle()
		
		// Processar SQL
		FWMsgRun(, {|| lTemDados := fLoadSql("Geral", @_cAliasG ) },;
										'Por Favor Aguarde...',;
										'Processando Banco de Dados - Analise Consumo')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...',;
										'Geração do quadro de Analise Consumo')
			
			// Final - encerramento do arquivo
			FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )
			
			FClose(nHandle)

			If ApOleClient("MSExcel")				//	 U_VARELM01()
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( cArquivo )
				oExcelApp:SetVisible(.T.) 	
				oExcelApp:Destroy()	
				// ou >  ShellExecute( "Open", cNameFile , '', '', 1 ) //Abre o arquivo na tela após salvar 
			Else
				MsgAlert("O Excel não foi encontrado. Arquivo " + cArquivo + " gerado em " + cPath + ".", "MsExcel não encontrado" )
			EndIf
		Else
			MsgAlert("Os parametros informados não retornou nenhuma informação do banco de dados." + CRLF + ;
					 "Por isso o excel não sera aberto automaticamente.", "Dados não localizados")
		EndIf
		
		(_cAliasG)->(DbCloseArea())
		
		If lower(cUserName) $ 'mbernardo,atoshio,admin, administrador'
			Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
		EndIf
		
		ConOut('Activate: ' + Time())
	EndIf
EndIf

Return nil


/*--------------------------------------------------------------------------------,
 | Principal: 			            U_PCPREL05()            		              |
 | Func:  PCPREL05()	            	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  09.09.2019	            	          	            	              |
 | Desc:  Relatório de Análise de Consumo                         	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

	Local _aArea	:= GetArea()
	Local aRegs     := {}
	Local nX		:= 0
	Local nPergs	:= 0
	Local aRegs		:= {}
	Local i         := 0
	Local j         := 0

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

	aAdd(aRegs,{cPerg, "01", "Data De?"                     , "", "", "MV_CH1", "D", TamSX3("Z05_DATA")[1], TamSX3("Z05_DATA")[2], 0, "G", "NaoVazio"                       , "MV_PAR01", ""   , "","",SubS(DtoS(dDataBase),1,6)+'01',"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
	aAdd(aRegs,{cPerg, "02", "Data Ate?"                    , "", "", "MV_CH2", "D", TamSX3("Z05_DATA")[1], TamSX3("Z05_DATA")[2], 0, "G", "NaoVazio"                       , "MV_PAR02", ""   , "","",DtoS(dDataBase)   ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
	aAdd(aRegs,{cPerg, "03", "Dias de Cocho De?"            , "", "", "MV_CH3", "N", 3                    , 0                    , 0, "G", "U_X1PCPR05()"       	        , "MV_PAR03", ""   , "","","75","","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
	aAdd(aRegs,{cPerg, "04", "Dias de Cocho Ate?"           , "", "", "MV_CH4", "N", 3                    , 0                    , 0, "G", "U_X1PCPR05()"       	        , "MV_PAR04", ""   , "","","100","","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
	aAdd(aRegs,{cPerg, "05", "GMD Estimado 1?"				, "", "", "MV_CH5", "N", 3  				  , 1  					 , 0, "G", "U_X1PCPR05()" 			        , "MV_PAR05", ""   , "","","1.5","","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
	aAdd(aRegs,{cPerg, "06", "GMD Estimado 2?"				, "", "", "MV_CH6", "N", 3  				  , 1  					 , 0, "G", "U_X1PCPR05()" 			        , "MV_PAR06", ""   , "","","1.6","","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
	aAdd(aRegs,{cPerg, "07", "GMD Estimado 3?"				, "", "", "MV_CH7", "N", 3  				  , 1  					 , 0, "G", "U_X1PCPR05()" 			        , "MV_PAR07", ""   , "","","1.7","","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
	aAdd(aRegs,{cPerg, "08", "Analisar qtos dias passados:?", "", "", "MV_CH8", "N", 2  				  , 0  					 , 0, "G", "!Empty(MV_PAR08).AND.MV_PAR08>0", "MV_PAR08", ""   , "","","10" ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})

	//Se quantidade de perguntas for diferente, apago todas
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
					For j := 1 to Count()
						If j <= Len(aRegs[i])
							FieldPut(j,aRegs[i,j])
						Endif
					Next j
				MsUnlock()
			EndIf
		Next i
	EndIf

	RestArea(_aArea)

Return nil
// FIM: GeraX1

/*--------------------------------------------------------------------------------,
 | Principal: 			            U_PCPREL05()            		              |
 | Func:  PCPREL05()	            	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  09.09.2019	            	          	            	              |
 | Desc:  Relatório de Análise de Consumo                         	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
Static Function fLoadSql(cTipo, _cAlias)
Local _cQry 		:= ""
Local nI            := 0

If cTipo == "Geral"

	_cQry := " WITH CONSUMO AS (" + CRLF +;
			 "        SELECT Z05_DATA, Z05_FILIAL, Z05_CURRAL, Z05_LOTE, Z05_CABECA, Z05_DIASDI, Z05_PESOCO, Z05_PESMAT" + CRLF +;
			 "          FROM Z05010 Z05 " + CRLF +;
			 "         WHERE Z05_FILIAL = '"+xFilial('Z05')+"'" + CRLF +;
			 " 		     AND Z05.Z05_DATA BETWEEN '" + DToS(MV_PAR01) + "' and '" + DToS(MV_PAR02) + "'" + CRLF +;
			 " 	         AND Z05.D_E_L_E_T_ = ' '" + CRLF +;
			 " 	  )" + CRLF +;
			 "" + CRLF +;
			 " , LOTES AS (" + CRLF +;
			 "        SELECT DISTINCT B8_LOTECTL, MIN(B8_XDATACO) B8_XDATACO, B8_XPESOCO, DATEDIFF(D,MIN(B8_XDATACO),GETDATE()) Z05_DIASDI" + CRLF +;
			 " 	     FROM SB8010 SB8 " + CRLF +;
			 " 		 JOIN Z08010 Z08 " + CRLF +;
			 " 		   ON Z08_FILIAL = B8_FILIAL " + CRLF +;
			 " 		  AND Z08_CODIGO = B8_X_CURRA " + CRLF +;
			 " 		  AND Z08_TIPO = '1'" + CRLF +;
			 "" + CRLF +;
			 " 		 JOIN CONSUMO C ON" + CRLF +;
			 " 			  SB8.B8_FILIAL = '"+xFilial('SB8')+"' " + CRLF +;
			 " 		  AND SB8.B8_LOTECTL = Z05_LOTE " + CRLF +;
			 " 		  AND SB8.D_E_L_E_T_ = ' ' " + CRLF +;
			 "        AND DATEDIFF(D,B8_XDATACO,GETDATE()) BETWEEN '" + StrZero(MV_PAR03,3) + "' and '" + StrZero(MV_PAR04,3) + "'" + CRLF +;
			 " 	 GROUP BY B8_LOTECTL, B8_XPESOCO " + CRLF +;
			 "" + CRLF +;
			 " 			" + CRLF +;
			 " )" + CRLF +;
			 " SELECT DISTINCT C.Z05_DATA --convert(date, C.Z05_DATA, 103) AS Z05_DATA" + CRLF +;
			 " 		, C.Z05_FILIAL" + CRLF +;
			 " 		, C.Z05_CURRAL" + CRLF +;
			 " 		, C.Z05_LOTE" + CRLF +;
			 " 		, C.Z05_CABECA" + CRLF +;
			 " 		, L.B8_XDATACO DATA_ENTRADA --, CONVERT(DATE, L.B8_XDATACO, 103) DATA_ENTRADA" + CRLF +;
			 " 		, C.Z05_PESOCO" + CRLF +;
			 " 		, L.Z05_DIASDI" + CRLF +;
			 " 		-- CMS KG" + CRLF +;
			 " 		-- CMS %PV INICIAL" + CRLF
			 
	for nI:=0 to MV_PAR08
		_cQry += " 		, (SELECT Z05_KGMSDI FROM Z05010 Z05A WHERE Z05A.Z05_FILIAL = C.Z05_FILIAL AND Z05A.Z05_LOTE = C.Z05_LOTE AND Z05A.Z05_DATA = DATEADD(DAY, -"+cValToChar(nI)+", C.Z05_DATA)) AS KGMSD"+cValToChar(nI) + CRLF
	Next nI
	
	_cQry += "" + CRLF +;
			 " FROM CONSUMO C" + CRLF +;
			 " JOIN LOTES L ON C.Z05_LOTE = L.B8_LOTECTL" + CRLF +;
			 "" + CRLF +;
			 " ORDER BY Z05_DATA DESC, Z05_DIASDI DESC, Z05_CURRAL"
EndIf

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

Return !(_cAlias)->(Eof())
// FIM: fLoadSql()



/*--------------------------------------------------------------------------------,
 | Principal: 			            U_PCPREL05()            		              |
 | Func:  PCPREL05()	            	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  09.09.2019	            	          	            	              |
 | Desc:  Relatório de Análise de Consumo                         	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1()
Local nRegistros	:= 0
Local cXML 			:= ""
Local cWorkSheet 	:= ""
Local nI            := 0
Local cLote  		:= ""

// Controle Quebra/ABA
Local sDataAtual	:= ""//StoD("")

(_cAliasG)->(DbEval({|| nRegistros++ }))

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	cWorkSheet := "Geral"
	
	//fQuadro1
	While !(_cAliasG)->(Eof())
	
		If sDataAtual <> (_cAliasG)->Z05_DATA
			sDataAtual := (_cAliasG)->Z05_DATA

			cXML += U_prtCellXML( 'Worksheet', /* cWorkSheet */ StrTran(dToC(StoD(sDataAtual)),"/","-") )
			cXML += U_prtCellXML( 'Table' )
			cXML += '<Column ss:Width="56.25" ss:Span="2"/> '+CRLF
			cXML += '<Column ss:Index="4" ss:Width="63.75"/>'+CRLF
			cXML += '<Column ss:Width="56.25" ss:Span="19"/>'+CRLF
			cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '25'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)
			
			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTextoN', 'String'  , /*cFormula*/, "Data: " ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData'  , 'DateTime', /*cFormula*/, U_FrmtVlrExcel( SToD( sDataAtual ) ),,.T. ) // DATA
			cXML += U_prtCellXML( '</Row>' )
			
			
			cXML += U_prtCellXML( 'Row' )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'08'/*cIndex*/,/*cMergeAcross*/,'s65'    , 'String', /*cFormula*/, 'GMD Estimado:'			,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( MV_PAR05 ),,.T. )
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'s65'    , 'String', /*cFormula*/, 'GMD Estimado:'			,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( MV_PAR06 ),,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'s65'    , 'String', /*cFormula*/, 'GMD Estimado:'			,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( MV_PAR07 ),,.T. )
			cXML += U_prtCellXML( '</Row>' )
			
			// Titulo
			cXML += U_prtCellXML( 'Row',,'33' )
/* 01 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Curral'		    ,,.T. )
/* 02 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Lote'		    ,,.T. )
/* 03 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Cabeças'		    ,,.T. )
/* 04 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dt. Entrada'	    ,,.T. )
/* 05 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Médio'	    ,,.T. )
/* 06 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dias de Cocho'   ,,.T. )
/* 07 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CMS (Kg)'	    ,,.T. )
///* 08 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CMS %PV Inicial' ,,.T. )
/* 09 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Médio Atual',,.T. )
/* 10 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CMS %PV Atual'   ,,.T. )
/* 11 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Médio Atual',,.T. )
/* 12 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CMS %PV Atual'   ,,.T. )
/* 13 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Médio Atual',,.T. )
/* 14 */	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CMS %PV Atual'   ,,.T. )


			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65Data', 'DateTime', /*cFormula*/ "=R2C2",,,.T. )
			for nI:=0 to MV_PAR08-1
				// cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'KGMSD'+cValToChar(nI),,.T. )
				cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65Data', 'DateTime', /*cFormula*/ "=RC[-1]-1",,,.T. )
			Next nI
			cXML += U_prtCellXML( '</Row>' )
			
		EndIf
		
		cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_CURRAL ),,.T. ) /* 01 */
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_LOTE   ),,.T. ) /* 02 */
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_CABECA ),,.T. ) /* 03 */
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData'  , 'DateTime', /*cFormula*/, U_FrmtVlrExcel( sToD( DATA_ENTRADA ) ) )        /* 04 */
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_PESOCO ),,.T. ) /* 05 */
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_DIASDI ),,.T. ) /* 06 */
																																	nPPesMdo  := 05 // Peso Medio
																																	nPDiaCoch := 06 // Dias de Cocho
																																	nPI_KGMSD := 14 // Inicio KG Mat Seca
																																	nPF_KGMSD := nPI_KGMSD + MV_PAR08  // Fim KG Mat Seca
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'  , /*cFormula*/ "=AVERAGE(RC"+cValToChar(nPI_KGMSD)+":RC"+cValToChar(nPF_KGMSD)+")",,,.T. ) /* 07 */
		//cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number' , /*cFormula*/ "=AVERAGE(RC"+cValToChar(nPI_KGMSD)+":RC"+cValToChar(nPF_KGMSD)+")/RC"+cValToChar(nPPesMdo),,,.T. ) /* 08 */
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'  , /*cFormula*/ "=(R3C[1]*RC"+cValToChar(nPDiaCoch)+")+RC"+cValToChar(nPPesMdo),,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number'  , /*cFormula*/ "=AVERAGE(RC"+cValToChar(nPI_KGMSD)+":RC"+cValToChar(nPF_KGMSD)+")/RC[-1]",,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'  , /*cFormula*/ "=(R3C[1]*RC"+cValToChar(nPDiaCoch)+")+RC"+cValToChar(nPPesMdo),,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number'  , /*cFormula*/ "=AVERAGE(RC"+cValToChar(nPI_KGMSD)+":RC"+cValToChar(nPF_KGMSD)+")/RC[-1]",,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'  , /*cFormula*/ "=(R3C[1]*RC"+cValToChar(nPDiaCoch)+")+RC"+cValToChar(nPPesMdo),,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number'  , /*cFormula*/ "=AVERAGE(RC"+cValToChar(nPI_KGMSD)+":RC"+cValToChar(nPF_KGMSD)+")/RC[-1]",,,.T. )
		
		for nI:=0 to MV_PAR08
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->&('KGMSD'+cValToChar(nI))),,.T. )
		Next nI
		cXML += U_prtCellXML( '</Row>' )
		
		(_cAliasG)->(DbSkip())
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
	
		If (_cAliasG)->(Eof()) .or. sDataAtual <> (_cAliasG)->Z05_DATA
			// cXML += U_prtCellXML( 'pulalinha','1' )
		
			// Final da Planilha
			cXML += '  </Table>' + CRLF
			cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
			cXML += '   <PageSetup>' + CRLF
			cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
			cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
			cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
			cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
			cXML += '   </PageSetup>' + CRLF
			cXML += '   <TabColorIndex>13</TabColorIndex>' + CRLF
			cXML += '   <Selected/>' + CRLF
			cXML += '   <Panes>' + CRLF
			cXML += '    <Pane>' + CRLF
			cXML += '     <Number>3</Number>' + CRLF
			cXML += '     <ActiveRow>17</ActiveRow>' + CRLF
			cXML += '     <ActiveCol>9</ActiveCol>' + CRLF
			cXML += '    </Pane>' + CRLF
			cXML += '   </Panes>' + CRLF
			cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
			cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
			cXML += '  </WorksheetOptions>' + CRLF
			cXML += ' </Worksheet>' + CRLF
		 
			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
			EndIf
			cXML := ""
		EndIf
	EndDo
	
EndIf	

Return nil
// FIM: fQuadro1


User Function X1pcpR05() // U_X1PCPR05()
Local lRet 		:= .T.
Local cCampo	:= ReadVar()
Local cInfo		:= &(ReadVar())


	If cCampo == 'MV_PAR03'
		lRet := !Empty(cInfo) .AND. !Empty(MV_PAR04) .AND.;
				MV_PAR03<MV_PAR04

ElseIf cCampo == 'MV_PAR04'
		lRet := !Empty(cInfo) .AND. !Empty(MV_PAR03) .AND.;
				MV_PAR04>MV_PAR03 

ElseIf cCampo == 'MV_PAR05'
		lRet := !Empty(cInfo) .AND. !Empty(MV_PAR06) .AND. !Empty(MV_PAR07) .AND.;
				MV_PAR05<MV_PAR06 .and. MV_PAR05<MV_PAR07

ElseIf cCampo == 'MV_PAR06'
		lRet := !Empty(cInfo) .AND. !Empty(MV_PAR05) .AND. !Empty(MV_PAR07) .AND.;
				MV_PAR06>MV_PAR05 .and. MV_PAR06<MV_PAR07

ElseIf cCampo == 'MV_PAR07'
		lRet := !Empty(cInfo) .AND. !Empty(MV_PAR06) .AND. !Empty(MV_PAR05) .AND.;
				MV_PAR07>MV_PAR06 .and. MV_PAR07>MV_PAR05

// ElseIf cCampo == 'MV_PAR08'
// 		lRet := !Empty(cInfo)
EndIf

Return lRet
