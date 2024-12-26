#Include "Totvs.ch"
#Include "Rwmake.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "XMLXFUN.CH"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  13.05.2019                                                              |
 | Desc:  Relatorio dados nas notas de cochos.                                    |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VARELM02() // U_VARELM02()                                                    

Local cTimeIni	 	:= Time()
Local lTemDados		:= .T.
Local cStyle		:= ""
Local cXML	   		:= ""

Private cPerg		:= "VARELM02"
Private cTitulo  	:= "Calculo CMS"

Private cPath 	 	:= "C:\totvs_relatorios\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()
Private _cAliasZ0G	:= GetNextAlias()

Private nHandle    	:= 0
Private nHandAux	:= 0

GeraX1(cPerg)
	
If Pergunte(cPerg, .T.)
	U_PrintSX1(cPerg)
	
	If Len( Directory(cPath + "*.*","D") ) == 0
		If Makedir(cPath) == 0
			ConOut('Diretorio Criado com Sucesso.')
		Else	
			ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
		EndIf
	EndIf
	
	nHandle := FCreate(cArquivo)
	if nHandle = -1
		conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	else
		
		fPrintQuadros()
		
		If lower(cUserName) $ 'mbernardo,atoshio,admin, administrador'
			Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
		EndIf
		
		ConOut('Activate: ' + Time())
	EndIf
EndIf
Return nil
// FIM DA FUNCAO: VARELM02



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VARELM02()             	            	      |
 | Func:  GeraX1()	            	            	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  16.05.2019	            	          	            	              |
 | Desc:  Processamento do SQL, salvando em variavel PRIVADA;  	            	  |
 |--------------------------------------------------------------------------------|
 | Regras   :                                                                     |
 |                                                                                |
 |--------------------------------------------------------------------------------|
 | Obs.     :                                                                     |
 '--------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local j         := 0
Local i         := 0
Local aRegs		:= {}

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

aAdd(aRegs,{cPerg, "01", "Data da Batida De?"   , "", "", "MV_CH1", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR01", ""    , "","","","",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Data da Batida Ate?"  , "", "", "MV_CH2", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR02", ""    , "","","","",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "03", "Imprime dia sem Nota?", "", "", "MV_CH3", "C", 01					    , 0						 , 2, "C", ""        , "MV_PAR03", "Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "04", "Imprime Tab. de Qtde?", "", "", "MV_CH4", "C", 01					    , 0						 , 2, "C", ""        , "MV_PAR04", "Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","U","","","",""})

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

Return nil
// FIM: GeraX1


/*--------------------------------------------------------------------------------,
 | Principal: 					U_MBCOMR01()             	            	      |
 | Func:  procesaSQL()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  19.02.2019	            	          	            	              |
 | Desc:  Processamento do SQL, salvando em variavel PRIVADA;  	            	  |
 |--------------------------------------------------------------------------------|
 | Regras   :                                                                     |
 |                                                                                |
 |--------------------------------------------------------------------------------|
 | Obs.     :                                                                     |
 '--------------------------------------------------------------------------------*/
Static Function procesaSQL(cTipo, _cAlias)
Local nI        := 0
Local _cQry 	:= "", cAux := ""

If cTipo=="Z0G"

	_cQry := " SELECT	CASE	Z0G_DISPON" + CRLF
	_cQry += " 			WHEN '1' THEN '1-MANHA'" + CRLF
	_cQry += " 			WHEN '2' THEN '2-TARDE'" + CRLF
	_cQry += " 			WHEN '3' THEN '3-NOITE'" + CRLF
	_cQry += " 					 ELSE '4-TODOS'" + CRLF
	_cQry += " 		END Z0G_DISPON" + CRLF
	_cQry += " 		, Z0G_CODIGO" + CRLF
	_cQry += " FROM	Z0G010" + CRLF
	_cQry += " WHERE	Z0G_MSBLQL<>'1'" + CRLF
	_cQry += " 		AND D_E_L_E_T_=' '" + CRLF
	_cQry += " ORDER BY Z0G_DISPON, CAST(REPLACE( Z0G_CODIGO, ',','.') AS FLOAT)" + CRLF

ElseIf cTipo=="Geral"

	_cQry := " WITH  " + CRLF
	_cQry += " DADOS AS (" + CRLF
	_cQry += " 	SELECT " + CRLF
	_cQry += " 		   Z05_DATA" + CRLF
	_cQry += " 		 , B1_DESC" + CRLF
	
	For nI := 1 to Len(aManha)
		cAux := Iif( aManha[nI] < 0, AllTrim(Str(Abs(aManha[nI])))+"N", AllTrim(Str(aManha[nI])) )
		_cQry += "   ,  CASE WHEN rTrim(M.Z0I_NOTMAN) = '"+ AllTrim(Str(aManha[nI])) +"'  THEN COUNT(M.Z0I_NOTMAN) END 'MANHA"+ cAux +"'" + CRLF
	Next nI
	_cQry += CRLF
	
	For nI := 1 to Len(aTarde)
		cAux := Iif( aTarde[nI] < 0, AllTrim(Str(Abs(aTarde[nI])))+"N", AllTrim(Str(aTarde[nI])) )
		_cQry += " 	 ,  CASE WHEN rTrim(T.Z0I_NOTTAR) = '"+ AllTrim(Str(aTarde[nI])) +"'  THEN COUNT(T.Z0I_NOTTAR) END 'TARDE"+ cAux +"'" + CRLF
	Next nI
	_cQry += CRLF

	For nI := 1 to Len(aNoite)
		cAux := Iif( aNoite[nI] < 0, AllTrim(Str(Abs(aNoite[nI])))+"N", AllTrim(Str(aNoite[nI])) )
		_cQry += " 	 ,  CASE WHEN rTrim(N.Z0I_NOTNOI) = '"+ AllTrim(Str(aNoite[nI])) +"'  THEN COUNT(N.Z0I_NOTNOI) END 'NOITE"+ cAux +"'" + CRLF
	Next nI
	_cQry += " 	FROM Z05010 Z05" + CRLF
	_cQry += " 	LEFT JOIN Z0I010 M ON   Z05_FILIAL = M.Z0I_FILIAL" + CRLF
	_cQry += " 				   AND Z05_DATA	  = M.Z0I_DATA" + CRLF
	_cQry += " 				   -- AND Z05_CURRAL = M.Z0I_CURRAL" + CRLF
	_cQry += " 				   AND Z05_LOTE	  = M.Z0I_LOTE" + CRLF
	_cQry += " 				   AND M.Z0I_NOTMAN<>' '" + CRLF
	_cQry += " 				   AND Z05.D_E_L_E_T_=' '" + CRLF
	_cQry += " 				   AND M.D_E_L_E_T_=' '" + CRLF
	_cQry += " 	LEFT JOIN Z0I010 T ON   Z05_FILIAL = T.Z0I_FILIAL" + CRLF
	_cQry += " 				   AND Z05_DATA	  = T.Z0I_DATA" + CRLF
	_cQry += " 				   -- AND Z05_CURRAL = T.Z0I_CURRAL" + CRLF
	_cQry += " 				   AND Z05_LOTE	  = T.Z0I_LOTE" + CRLF
	_cQry += " 				   AND T.Z0I_NOTTAR<>' '" + CRLF
	_cQry += " 				   AND T.D_E_L_E_T_=' '" + CRLF
	_cQry += " 	LEFT JOIN Z0I010 N ON   Z05_FILIAL = N.Z0I_FILIAL" + CRLF
	_cQry += " 				   AND Z05_DATA	  = N.Z0I_DATA" + CRLF
	_cQry += " 				   -- AND Z05_CURRAL = N.Z0I_CURRAL" + CRLF
	_cQry += " 				   AND Z05_LOTE	  = N.Z0I_LOTE" + CRLF
	_cQry += " 				   AND N.Z0I_NOTNOI<>' '" + CRLF
	_cQry += " 				   AND N.D_E_L_E_T_=' '" + CRLF
	_cQry += " 	JOIN SB1010 SB1 ON B1_FILIAL=' ' AND B1_COD=Z05_DIETA AND SB1.D_E_L_E_T_=' '" + CRLF
	_cQry += CRLF
	_cQry += " 	GROUP BY Z05_DATA" + CRLF
	_cQry += " 		 , B1_DESC" + CRLF
	_cQry += " 		 , M.Z0I_NOTMAN" + CRLF
	_cQry += " 		 , T.Z0I_NOTTAR" + CRLF
	_cQry += " 		 , N.Z0I_NOTNOI" + CRLF
	_cQry += " )" + CRLF
	_cQry += CRLF
	_cQry += " SELECT Z05_DATA" + CRLF
	_cQry += " 	 , B1_DESC " + CRLF
	For nI := 1 to Len(aManha)
		cAux := Iif( aManha[nI] < 0, AllTrim(Str(Abs(aManha[nI])))+"N", AllTrim(Str(aManha[nI])) )
		_cQry += ' 	 , ISNULL(SUM("MANHA'+ cAux +'"),0) "MANHA'+ cAux +'"' + CRLF
	Next nI
	_cQry += CRLF
	
	For nI := 1 to Len(aTarde)
		cAux := Iif( aTarde[nI] < 0, AllTrim(Str(Abs(aTarde[nI])))+"N", AllTrim(Str(aTarde[nI])) )
		_cQry += ' 	 , ISNULL(SUM("TARDE'+ cAux +'"),0) "TARDE'+ cAux +'"' + CRLF
	Next nI
	_cQry += CRLF
	
	For nI := 1 to Len(aNoite)
		cAux := Iif( aNoite[nI] < 0, AllTrim(Str(Abs(aNoite[nI])))+"N", AllTrim(Str(aNoite[nI])) )
		_cQry += ' 	 , ISNULL(SUM("NOITE'+ cAux +'"),0) "NOITE'+ cAux +'"' + CRLF
	Next nI
	_cQry += CRLF
	
	_cQry += " FROM DADOS" + CRLF
	
	_cQry += " WHERE " + CRLF
	_cQry += " 			Z05_DATA BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' " + CRLF
	
	If MV_PAR03 == 2
		_cQry += " AND "
		
		For nI := 1 to Len(aManha)
			cAux := Iif( aManha[nI] < 0, AllTrim(Str(Abs(aManha[nI])))+"N", AllTrim(Str(aManha[nI])) )
			// _cQry += 'OR "MANHA'+ cAux +'" > 0' + CRLF
			_cQry += iIf(nI>1,'+','') + 'ISNULL("MANHA'+ cAux +'", 0)' + CRLF
		Next nI
		_cQry += CRLF
		For nI := 1 to Len(aTarde)
			cAux := Iif( aTarde[nI] < 0, AllTrim(Str(Abs(aTarde[nI])))+"N", AllTrim(Str(aTarde[nI])) )
			// _cQry += 'OR "TARDE'+ cAux +'" > 0' + CRLF
			_cQry += iIf(Len(aManha)>0 .or. nI>1,'+','') + 'ISNULL("TARDE'+ cAux +'", 0)' + CRLF
		Next nI
		_cQry += CRLF
		For nI := 1 to Len(aNoite)
			cAux := Iif( aNoite[nI] < 0, AllTrim(Str(Abs(aNoite[nI])))+"N", AllTrim(Str(aNoite[nI])) )
			// _cQry += 'OR "NOITE'+ cAux +'" > 0' + CRLF
			_cQry += iIf(Len(aTarde) .or. nI>1,'+','') + 'ISNULL("NOITE'+ cAux +'", 0)' + CRLF
		Next nI
		_cQry += " > 0"
	EndIf
	
	_cQry += CRLF
	_cQry += " GROUP BY Z05_DATA" + CRLF
	_cQry += " 		 , B1_DESC" + CRLF
	_cQry += " ORDER BY Z05_DATA" + CRLF

EndIf
 
If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

// TcSetField(_cAlias, "D1_X_EMBDT", "D")
// TcSetField(_cAlias	, "D1_X_CHEDT", "D")

Return !(_cAlias)->(Eof())
// FIM: procesaSQL()


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  13.05.2019                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fPrintQuadros()

Local lTemDados := .F.

Private aManha := {}
Private aTarde := {}
Private aNoite := {}

	cStyle := U_defStyle()

	// Processar SQL
	FWMsgRun(, {|| lTemDados := procesaSQL("Z0G", @_cAliasZ0G ) },'Por Favor Aguarde...', 'Processando Banco de Dados-Z0G')
	If lTemDados
		fMontVetorNotasZ0G( @aManha, @aTarde, @aNoite )
	Else
		Return nil
	EndIf
	
	FWMsgRun(, {|| lTemDados := procesaSQL("Geral", @_cAliasG ) },'Por Favor Aguarde...', 'Processando Banco de Dados - Geral')
	If lTemDados
		
		cXML := U_CabXMLExcel(cStyle)

		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
			cXML := ""
		EndIf

		// Gerar primeira planilha
		FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geraçao do quadro: Notas por Dieta')

		// Final - encerramento do arquivo
		FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )
		
		FClose(nHandle)

		If ApOleClient("MSExcel")				//	 U_VARELM02()
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
	
Return nil



/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  14.05.2019                                                              |
 | Desc:                                                                          |
 |                                                                                |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fMontVetorNotasZ0G( aManha, aTarde, aNoite )

	While !(_cAliasZ0G)->(Eof())
	
		If (_cAliasZ0G)->Z0G_DISPON == '1-MANHA'
			If aScan( aManha, { |x| x == Val( (_cAliasZ0G)->Z0G_CODIGO ) } ) == 0
				aAdd(aManha, Val( (_cAliasZ0G)->Z0G_CODIGO ) )
			EndIf
			
		ElseIf (_cAliasZ0G)->Z0G_DISPON == '2-TARDE'
			If aScan( aTarde, { |x| x == Val( (_cAliasZ0G)->Z0G_CODIGO ) } ) == 0
				aAdd(aTarde, Val( (_cAliasZ0G)->Z0G_CODIGO ) )
			EndIf
			
		ElseIf (_cAliasZ0G)->Z0G_DISPON == '3-NOITE'
			If aScan( aNoite, { |x| x == Val( (_cAliasZ0G)->Z0G_CODIGO ) } ) == 0
				aAdd(aNoite, Val( (_cAliasZ0G)->Z0G_CODIGO ) )
			EndIf
		ElseIf (_cAliasZ0G)->Z0G_DISPON == '4-TODOS'
			If aScan( aManha, { |x| x == Val( (_cAliasZ0G)->Z0G_CODIGO ) } ) == 0
				aAdd(aManha, Val( (_cAliasZ0G)->Z0G_CODIGO ) )
			EndIf
			If aScan( aTarde, { |x| x == Val( (_cAliasZ0G)->Z0G_CODIGO ) } ) == 0
				aAdd(aTarde, Val( (_cAliasZ0G)->Z0G_CODIGO ) )
			EndIf
			If aScan( aNoite, { |x| x == Val( (_cAliasZ0G)->Z0G_CODIGO ) } ) == 0
				aAdd(aNoite, Val( (_cAliasZ0G)->Z0G_CODIGO ) )
			EndIf
		EndIf
		
		(_cAliasZ0G)->(DbSkip())
	EndDo
	
	aSort( aManha, , , { |x,y| x > y } )
	aSort( aTarde, , , { |x,y| x > y } )
	aSort( aNoite, , , { |x,y| x > y } )

Return nil


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 14.05.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Construção do quadro de Notas por Dieta;            			       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_VARELM02()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function fQuadro1()

Local nRegG			:= 0, nI := 0
Local nRegZ0G		:= Len(aManha)+Len(aTarde)+Len(aNoite)
Local cXML 			:= "", cAux := ""
Local cWorkSheet 	:= "Notas por Dieta"
Local nIniTarde		:= 0
Local cTotTarde		:= 0

(_cAliasG)->(DbEval({|| nRegG++ }))
(_cAliasG)->(DbGoTop()) 

If !(_cAliasG)->(Eof())
	
	cXML += U_prtCellXML( 'Worksheet', cWorkSheet )
	cXML += U_prtCellXML( 'Table' )
	cXML += '<Column ss:AutoFitWidth="0" ss:Width="63"/>' + CRLF
	cXML += '<Column ss:AutoFitWidth="0" ss:Width="83.25"/>' + CRLF
	If MV_PAR04 == 1
		cXML += '<Column ss:AutoFitWidth="0" ss:Width="50" ss:Span="'+ AllTrim(Str((nRegZ0G-1+3)*2)) +'"/>' + CRLF
	Else // NÃO
		cXML += '<Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="50.25" ss:Span="'+ AllTrim(Str(nRegZ0G-1+4)) +'"/>' + CRLF
		cXML += '<Column ss:AutoFitWidth="0" ss:Width="50" ss:Span="'+ AllTrim(Str(nRegZ0G-1+3)) +'"/>' + CRLF
	EndIf
	
	cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '33'/* cHeight */, /* cIndex */, ;
				AllTrim(Str((nRegZ0G+3)*2+2)) /* '16' *//* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)
	
	// 1ª linha	
	cXML += U_prtCellXML( 'Row',,/* cHeight */ )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,'1'/*cMergeAcross*/,'s65', 'String', /*cFormula*/, '' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,AllTrim(Str(Len(aManha)))/*cMergeAcross*/,'s65'		, 'String', /*cFormula*/, 'MANHÃ' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,AllTrim(Str(Len(aTarde)))/*cMergeAcross*/,'sFundoAzul', 'String', /*cFormula*/, 'TARDE' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,AllTrim(Str(Len(aNoite)))/*cMergeAcross*/,'s65'		, 'String', /*cFormula*/, 'NOITE' )
	
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, '' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,AllTrim(Str(Len(aManha)))/*cMergeAcross*/,'s65'		, 'String', /*cFormula*/, 'MANHÃ' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,AllTrim(Str(Len(aTarde)))/*cMergeAcross*/,'sFundoAzul', 'String', /*cFormula*/, 'TARDE' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,AllTrim(Str(Len(aNoite)))/*cMergeAcross*/,'s65'		, 'String', /*cFormula*/, 'NOITE' )
	cXML += U_prtCellXML( '</Row>' )
	
	// 2ª linha
	cXML += U_prtCellXML( 'Row',,/* cHeight */ )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,'1'/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'MÉDIA' )
	For nI := 1 to Len(aManha)
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number', ;
			"=IFERROR(SUBTOTAL(1,R5C:R"+AllTrim(Str(5+nRegG))+"C),0)" /*cFormula*/, /* cInfo */ )
	Next nI
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, '' )
	
	For nI := 1 to Len(aTarde)
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number', ;
			"=IFERROR(SUBTOTAL(1,R5C:R"+AllTrim(Str(5+nRegG))+"C),0)" /*cFormula*/, /* cInfo */ )
	Next nI
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, '' )
	
	For nI := 1 to Len(aNoite)
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number', ;
			"=IFERROR(SUBTOTAL(1,R5C:R"+AllTrim(Str(5+nRegG))+"C),0)" /*cFormula*/, /* cInfo */ )
	Next nI
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, '' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, '' )
	For nI := 1 to Len(aManha)
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number', ;
			"=IFERROR(SUBTOTAL(1,R5C:R"+AllTrim(Str(5+nRegG))+"C),0)" /*cFormula*/, /* cInfo */ )
	Next nI
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, '' )
	
	For nI := 1 to Len(aTarde)
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number', ;
			"=IFERROR(SUBTOTAL(1,R5C:R"+AllTrim(Str(5+nRegG))+"C),0)" /*cFormula*/, /* cInfo */ )
	Next nI
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, '' )
	
	For nI := 1 to Len(aNoite)
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number', ;
			"=IFERROR(SUBTOTAL(1,R5C:R"+AllTrim(Str(5+nRegG))+"C),0)" /*cFormula*/, /* cInfo */ )
	Next nI
	cXML += U_prtCellXML( '</Row>' )
	
	// 3ª linha
	cXML += U_prtCellXML( 'Row',,/* cHeight */ )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'DATA'  )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'DIETA' )
	For nI := 1 to Len(aManha)
		cAux := Iif( aManha[nI] < 0, "-" + AllTrim(Str(Abs(aManha[nI]))), AllTrim(Str(aManha[nI])) )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, cAux )
	Next nI
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TOTAL' )
	
	For nI := 1 to Len(aTarde)
		cAux := Iif( aTarde[nI] < 0, "-" + AllTrim(Str(Abs(aTarde[nI]))), AllTrim(Str(aTarde[nI])) )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sFundoAzul', 'String', /*cFormula*/, cAux )
	Next nI
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sFundoAzul', 'String', /*cFormula*/, 'TOTAL' )
	
	For nI := 1 to Len(aNoite)
		cAux := Iif( aNoite[nI] < 0, "-" + AllTrim(Str(Abs(aNoite[nI]))), AllTrim(Str(aNoite[nI])) )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, cAux )
	Next nI
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TOTAL' )
	
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, '' )
	For nI := 1 to Len(aManha)
		cAux := Iif( aManha[nI] < 0, "-" + AllTrim(Str(Abs(aManha[nI]))), AllTrim(Str(aManha[nI])) )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, cAux )
	Next nI
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TOTAL' )
	
	For nI := 1 to Len(aTarde)
		cAux := Iif( aTarde[nI] < 0, "-" + AllTrim(Str(Abs(aTarde[nI]))), AllTrim(Str(aTarde[nI])) )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sFundoAzul', 'String', /*cFormula*/, cAux )
	Next nI
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sFundoAzul', 'String', /*cFormula*/, 'TOTAL' )
	
	For nI := 1 to Len(aNoite)
		cAux := Iif( aNoite[nI] < 0, "-" + AllTrim(Str(Abs(aNoite[nI]))), AllTrim(Str(aNoite[nI])) )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, cAux )
	Next nI
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TOTAL' )
	
	cXML += U_prtCellXML( '</Row>' )
	
	// 4ª linha em diante ...
	//fQuadro1
	While !(_cAliasG)->(Eof())
		cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData', 'DateTime', /*cFormula*/, sToD((_cAliasG)->Z05_DATA ) )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, (_cAliasG)->B1_DESC  	 )
		
		For nI := 1 to Len(aManha)
			cAux := Iif( aManha[nI] < 0, AllTrim(Str(Abs(aManha[nI])))+"N", AllTrim(Str(aManha[nI])) )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, (_cAliasG)->&("MANHA" + cAux) )
			// cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, (_cAliasG)->( FieldGet(FieldPos( "MANHA  -3" )) ))
		Next nI
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', ;
		"=SUM(RC[-"+AllTrim(Str(Len(aManha)))+"]:RC[-1])" /*cFormula*/, /* cInfo */ )
		
		For nI := 1 to Len(aTarde)
			cAux := Iif( aTarde[nI] < 0, AllTrim(Str(Abs(aTarde[nI])))+"N", AllTrim(Str(aTarde[nI])) )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, (_cAliasG)->&("TARDE" + cAux ) )
		Next nI
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', ;
		"=SUM(RC[-"+AllTrim(Str(Len(aTarde)))+"]:RC[-1])" /*cFormula*/, /* cInfo */ )
		
		For nI := 1 to Len(aNoite)
			cAux := Iif( aNoite[nI] < 0, AllTrim(Str(Abs(aNoite[nI])))+"N", AllTrim(Str(aNoite[nI])) )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, (_cAliasG)->&("NOITE" + cAux ) )
		Next nI
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', ;
		"=SUM(RC[-"+AllTrim(Str(Len(aNoite)))+"]:RC[-1])" /*cFormula*/, /* cInfo */ )

		// --> % porcentagem % <--
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, '' )
		For nI := 1 to Len(aManha)
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number', ;
			"=IFERROR(RC"+AllTrim(Str(nI+2))+"/RC"+AllTrim(Str(Len(aManha)+3))+",&quot;-&quot;)" /*cFormula*/, /* cInfo */ )
		Next nI
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number', ;
		"=SUM(RC[-"+AllTrim(Str(Len(aManha)))+"]:RC[-1])" /*cFormula*/, /* cInfo */ )
		
		nIniTarde := Len(aManha)+3
		cTotTarde := AllTrim(Str( Len(aManha)+Len(aTarde)+4 ))
		For nI := 1 to Len(aTarde)
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number', ;
			"=IFERROR(RC"+AllTrim(Str(nIniTarde+nI))+"/RC"+cTotTarde+",&quot;-&quot;)" /*cFormula*/, /* cInfo */ )
		Next nI
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number', ;
		"=SUM(RC[-"+AllTrim(Str(Len(aTarde)))+"]:RC[-1])" /*cFormula*/, /* cInfo */ )
		
		nIniNoite := Val(cTotTarde)+1
		cTotNoite := AllTrim(Str( nIniNoite+len(aNoite) ))
		For nI := 1 to Len(aNoite)
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number', ;
				"=IFERROR(RC"+AllTrim(Str(nIniNoite-1+nI))+"/RC"+cTotNoite+",&quot;-&quot;)"/*cFormula*/, /* cInfo */ )
		Next nI
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sPorcent', 'Number', ;
		"=SUM(RC[-"+AllTrim(Str(Len(aNoite)))+"]:RC[-1])" /*cFormula*/, /* cInfo */ )
		
		cXML += U_prtCellXML( '</Row>' )

		(_cAliasG)->(DbSkip())
	EndDo
	
	cXML += U_prtCellXML( 'WorksheetOptions'/* cTag */, /* cName */, /* cHeight */, /* cIndex */, /* cMergeAcross */, ;
				 /* cStyleID */, /* cType */, /* cFormula */, /* cInfo */, /* cPanes */ )
	
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
EndIf

Return nil
// fQuadro1
