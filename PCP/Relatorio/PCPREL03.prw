#include 'FILEIO.CH'
#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 22.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatï¿½rio de Desempenho Trato.       						           |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL03()                                                         |
 '---------------------------------------------------------------------------------*/
User Function PCPREL03()
Local cTimeIni	 	:= Time()
Local cStyle		:= ""
Local cXML	   		:= ""
Local lTemDados		:= .T.
Local cPerg			:= SubS(ProcName(),3) // "PCPREL03"

Private cTitulo  	:= "Relatï¿½rio de Desempenho Trato."

Private cPath 	 	:= "C:\TOTVS_RELATORIOS\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()   

Private nHandle    	:= 0
Private nHandAux	:= 0

GeraX1(cPerg)
	
If Pergunte(cPerg, .T.)
	U_PrintSX1(cPerg)
	
	If Len( Directory(cPath + "*.*","D") ) == 0
		If Makedir(cPath) == 0
			ConOut('Diretorio Criado com Sucesso.')
			MsgAlert('Diretorio Criado com Sucesso: ' + cPath, 'Aviso')
		Else	
			ConOut( "Nï¿½o foi possivel criar o diretï¿½rio. Erro: " + cValToChar( FError() ) )
			MsgAlert( "Nï¿½o foi possivel criar o diretï¿½rio. Erro: " + cValToChar( FError() ), 'Aviso' )
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
						'Processando Banco de Dados - Alimentaï¿½ï¿½o Diï¿½ria')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geraï¿½ï¿½o do quadro de Carregamento')
			
			// Final - encerramento do arquivo
			FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )
			
			FClose(nHandle)

			If ApOleClient("MSExcel")				//	 U_VARELM01()
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( cArquivo )
				oExcelApp:SetVisible(.T.) 	
				oExcelApp:Destroy()	
				// ou >  ShellExecute( "Open", cNameFile , '', '', 1 ) //Abre o arquivo na tela apï¿½s salvar 
			Else
				MsgAlert("O Excel nï¿½o foi encontrado. Arquivo " + cArquivo + " gerado em " + cPath + ".", "MsExcel nï¿½o encontrado" )
			EndIf
		Else
			MsgAlert("Os parametros informados nï¿½o retornou nenhuma informaï¿½ï¿½o do banco de dados." + CRLF + ;
					 "Por isso o excel nï¿½o sera aberto automaticamente.", "Dados nï¿½o localizados")
		EndIf
		
		(_cAliasG)->(DbCloseArea())
		
		If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin, administrador'
			Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
		EndIf
		
		ConOut('Activate: ' + Time())
	EndIf
EndIf

Return nil
// FIM: PCPREL03()



/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 22.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                        				       		   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL03()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local i         := 0
Local j         := 0
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

aAdd( aRegs, { cPerg, "01", "Data De?       ", "", "", "MV_CH1", "D", TamSX3("Z05_DATA")[1]  , TamSX3("Z05_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR01", "", "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd( aRegs, { cPerg, "02", "Data Ate?      ", "", "", "MV_CH2", "D", TamSX3("Z05_DATA")[1]  , TamSX3("Z05_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR02", "", "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd( aRegs, { cPerg, "03", "Lote De?       ", "", "", "MV_CH3", "C", TamSX3("B8_LOTECTL")[1], TamSX3("B8_LOTECTL")[2], 0, "G", ""		  , "MV_PAR03", "", "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd( aRegs, { cPerg, "04", "Lote Ate?      ", "", "", "MV_CH4", "C", TamSX3("B8_LOTECTL")[1], TamSX3("B8_LOTECTL")[2], 0, "G", "NaoVazio", "MV_PAR04", "", "","",Replicate("Z", TamSX3("B8_LOTECTL")[1])  ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd( aRegs, { cPerg, "05", "Curral De?     ", "", "", "MV_CH5", "C", TamSX3("B8_X_CURRA")[1], TamSX3("B8_X_CURRA")[2], 0, "G", ""		  , "MV_PAR05", "", "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd( aRegs, { cPerg, "06", "Curral Ate?    ", "", "", "MV_CH6", "C", TamSX3("B8_X_CURRA")[1], TamSX3("B8_X_CURRA")[2], 0, "G", "NaoVazio", "MV_PAR06", "", "","",Replicate("Z", TamSX3("B8_X_CURRA")[1]),"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
	
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

// gravaï¿½ï¿½o das perguntas na tabela SX1
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


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 22.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                        				       		   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL03()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function fLoadSql(cTipo, _cAlias)
Local _cQry 		:= ""

If cTipo == "Geral"

	_cQry := " SELECT Z05_FILIAL"+CRLF
	_cQry += " 	    , Z05_DATA"+CRLF
	_cQry += " 	    , Z06_CURRAL"+CRLF
	_cQry += " 	    , Z06_LOTE"+CRLF
	_cQry += " 	    , COUNT(Z06_TRATO) QTD_TRATO"+CRLF
	_cQry += " 	    , Z06_DIETA -- Z05_DIETA"+CRLF
	_cQry += " 	    , Z05_DIASDI DIAS_COCHO"+CRLF
	_cQry += " 	    , SUM(ISNULL(Z0W_QTDPRE,0)) PREVISTO"+CRLF
	_cQry += " 	    , SUM(ISNULL(Z0W_QTDREA,0)) REALIZADO"+CRLF
	_cQry += " 	    , ISNULL(ONTEM.Z0I_NOTTAR,'') NOTA_TARDE"+CRLF
	_cQry += " 		, ISNULL(DIA.Z0I_NOTNOI,'') NOTA_NOITE"+CRLF
	_cQry += " 	    , ISNULL(DIA.Z0I_NOTMAN,'') NOTA_MANHA"+CRLF
	_cQry += " 	    , ISNULL(Z0U_NOME,'') Z0U_NOME"+CRLF
	_cQry += CRLF
	_cQry += " FROM " + RetSqlName("Z05") + " Z05"+CRLF
	_cQry += "      JOIN " + RetSqlName("Z06") + " Z06 ON Z06_FILIAL='01'"+CRLF
	_cQry += " 				    AND Z05_FILIAL=Z06_FILIAL"+CRLF
	_cQry += " 				    AND Z05_DATA  =Z06_DATA"+CRLF
	_cQry += " 				    AND Z05_VERSAO=Z06_VERSAO"+CRLF
	_cQry += " 				    AND Z05_CURRAL=Z06_CURRAL"+CRLF
	_cQry += "  				    AND Z05_LOTE	= Z06_LOTE "+CRLF
	_cQry += "  				    AND Z05.D_E_L_E_T_=' '"+CRLF
	_cQry += " 				    AND Z06.D_E_L_E_T_=' '"+CRLF
	_cQry += CRLF
	_cQry += " LEFT JOIN " + RetSqlName("Z0W") + " Z0W ON Z0W.Z0W_FILIAL='01'"+CRLF
	_cQry += " 				    AND Z05.Z05_FILIAL=Z0W.Z0W_FILIAL"+CRLF
	_cQry += " 				    AND Z05_DATA = Z0W_DATA "+CRLF
	_cQry += " 				    AND Z05.Z05_LOTE = Z0W_LOTE "+CRLF
	_cQry += "  	    		    AND Z06_TRATO=Z0W_TRATO"+CRLF
	_cQry += "  	    		    AND Z06_DIETA=Z0W_RECEIT"+CRLF
	_cQry += "  	    		    AND Z0W.D_E_L_E_T_ = ' '	-- cabeï¿½alho de programacao do Trato"+CRLF
	_cQry += CRLF
	_cQry += " LEFT JOIN " + RetSqlName("Z0I") + " DIA ON DIA.Z0I_FILIAL='01'"+CRLF
	_cQry += " 				    AND Z0I_DATA=Z0W_DATA"+CRLF
	_cQry += " 				    AND Z0I_CURRAL=Z0W_CURRAL"+CRLF
	_cQry += " 				    AND Z0I_LOTE=Z0W_LOTE"+CRLF
	_cQry += " 				    AND DIA.D_E_L_E_T_=' '"+CRLF
	_cQry += CRLF
	_cQry += " LEFT JOIN " + RetSqlName("Z0I") + " ONTEM ON ONTEM.Z0I_FILIAL='01'"+CRLF
	_cQry += " 				    AND ONTEM.Z0I_DATA+1=Z0W_DATA"+CRLF
	_cQry += " 				    AND ONTEM.Z0I_CURRAL=Z0W_CURRAL"+CRLF
	_cQry += " 				    AND ONTEM.Z0I_LOTE=Z0W_LOTE"+CRLF
	_cQry += " 				    AND ONTEM.D_E_L_E_T_=' '"+CRLF
	_cQry += CRLF
	_cQry += " 	 JOIN " + RetSqlName("Z0X") + " Z0X ON Z0W_FILIAL='01'"+CRLF
	_cQry += " 				    AND Z0W.Z0W_FILIAL=Z0X.Z0X_FILIAL"+CRLF
	_cQry += " 				    AND Z0W.Z0W_CODEI = Z0X.Z0X_CODIGO"+CRLF
	_cQry += " 				    AND Z0X.D_E_L_E_T_ = ' '	-- cabeï¿½alho TRATO"+CRLF
	_cQry += CRLF
	_cQry += " LEFT JOIN " + RetSqlName("Z0U") + " Z0U ON Z0U_FILIAL='01'"+CRLF
	_cQry += " 				    AND Z0U_CODIGO=Z0X_OPERAD"+CRLF
	_cQry += " 				    AND Z0U.D_E_L_E_T_=' '"+CRLF
	_cQry += CRLF
	_cQry += " WHERE Z05_FILIAL='"+xFilial('Z05')+"'"+CRLF
	_cQry += " 	 AND Z05_DATA   BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'"+CRLF
	_cQry += " 	 AND Z06_LOTE   BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"+CRLF
	_cQry += "   AND Z06_CURRAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"+CRLF
	_cQry += CRLF
	_cQry += " GROUP BY Z05_FILIAL"+CRLF
	_cQry += " 	   , Z05_DATA"+CRLF
	_cQry += " 	   , Z06_CURRAL"+CRLF
	_cQry += " 	   , Z06_LOTE"+CRLF
	_cQry += " 	   , Z06_DIETA -- Z05_DIETA"+CRLF
	_cQry += " 	   , Z05_DIASDI"+CRLF
	_cQry += " 	   , ONTEM.Z0I_NOTTAR"+CRLF
	_cQry += " 	   , DIA.Z0I_NOTNOI"+CRLF
	_cQry += " 	   , DIA.Z0I_NOTMAN"+CRLF
	_cQry += " 	   , Z0U_NOME"+CRLF
	_cQry += CRLF
	_cQry += " ORDER BY 1, 2, 3, CAST(REPLACE(SUBSTRING(Z06_LOTE, 1, CHARINDEX('-',Z06_LOTE)),'-','') AS INT)"

ElseIf cTipo == "Top 10 Diferença"
	_cQry := "  "+CRLF
	_cQry += "    WITH DADOS AS ("+CRLF
	_cQry += "    SELECT DISTINCT Z0W_FILIAL"+CRLF
	_cQry += "  	   , ZV0_IDENT"+CRLF
	_cQry += "  	   , Z0U_NOME"+CRLF
	_cQry += "         , Z0W_DATA"+CRLF
	_cQry += "         , Z0W_CURRAL"+CRLF
	_cQry += "         , Z0W_LOTE"+CRLF
	_cQry += "  	   , Z05_DIASDI"+CRLF
	_cQry += "  	   , Z0W_RECEIT"+CRLF
	_cQry += "  	   , COUNT(Z0W_TRATO) QTD_TRATO"+CRLF
	_cQry += "         , SUM(Z0W_QTDPRE) Z0W_QTDPRE"+CRLF
	_cQry += "  	   , SUM(CASE WHEN Z0W_PESDIG > 0 THEN Z0W_PESDIG ELSE Z0W_QTDREA END ) Z0W_QTDREA"+CRLF
	_cQry += "         , ABS(SUM(CASE WHEN Z0W_PESDIG > 0 THEN Z0W_PESDIG ELSE Z0W_QTDREA END )-SUM(Z0W_QTDPRE)) DIFERENCA"+CRLF
	_cQry += "  	   , Z0I_NOTMAN	     "+CRLF
	_cQry += "    FROM " + RetSqlName("Z0W") + " Z0W"+CRLF
	_cQry += "    JOIN " + RetSqlName("Z0X") + " Z0X ON Z0W_FILIAL = Z0X_FILIAL AND Z0W_CODEI = Z0X_CODIGO AND Z0W_DATA = Z0X_DATA AND Z0X.D_E_L_E_T_ = ' ' "+CRLF
	_cQry += "    JOIN " + RetSqlName("ZV0") + " ZV0 ON ZV0_CODIGO = Z0X_EQUIP AND ZV0.D_E_L_E_T_ = ' ' "+CRLF
	_cQry += "    LEFT JOIN " + RetSqlName("Z0I") + " Z0I ON Z0I_FILIAL = Z0W_FILIAL AND Z0I_CURRAL = Z0W_CURRAL AND Z0I_LOTE = Z0W_LOTE AND Z0I_LOTE = Z0W_LOTE AND Z0I_DATA = '"+dToS(MV_PAR02 + 1)+"' AND Z0I.D_E_L_E_T_ = ' ' "+CRLF
	_cQry += "    JOIN " + RetSqlName("Z0U") + " Z0U ON Z0U_CODIGO = Z0X_OPERAD AND Z0U.D_E_L_E_T_ = ' ' "+CRLF
	_cQry += "    JOIN " + RetSqlName("Z05") + " Z05 ON Z05_FILIAL = Z0X_FILIAL AND Z05_DATA = Z0X_DATA AND Z05_LOTE = Z0W_LOTE AND Z05.D_E_L_E_T_ = ' ' "+CRLF
	_cQry += "    WHERE Z0X_FILIAL = '" + FWxFilial("Z0X") + " AND Z0W_DATA BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' AND Z0W.D_E_L_E_T_ = ' ' "+CRLF
	_cQry += "  "+CRLF
	_cQry += "  GROUP BY Z0W_FILIAL, Z0W_CURRAL, Z0W_LOTE, Z05_DIASDI, Z0W_DATA, ZV0_IDENT, Z0U_NOME, Z0I_NOTMAN, Z0W_RECEIT"+CRLF
	_cQry += "  )"+CRLF
	_cQry += "  SELECT top(10) DIFERENCA, ZV0_IDENT, Z0U_NOME, Z0W_DATA, Z0W_CURRAL, Z0W_LOTE, Z05_DIASDI, QTD_TRATO, Z0W_QTDPRE, Z0W_QTDREA, Z0I_NOTMAN,  Z0W_RECEIT"+CRLF
	_cQry += "  FROM DADOS"+CRLF
	_cQry += "  ORDER BY DIFERENCA DESC"+CRLF
	
EndIf

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

Return !(_cAlias)->(Eof())
// FIM: fLoadSql()



/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 16.07.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Quadro com impressao geral dos lotes. Analise sera feita por filtro. |
 |          :                                                                       |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL03()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function fQuadro1()

Local nRegistros	:= 0 // MV_PAR02 - MV_PAR01
Local cXML 			:= ""
Local cWorkSheet 	:= ""

Local cLote  		:= ""

(_cAliasG)->(DbEval({|| nRegistros++ }))

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	cWorkSheet := "Desempenho"

	cXML += U_prtCellXML( 'Worksheet', cWorkSheet )

	cXML += ' <Names>'+CRLF
	cXML += ' <NamedRange ss:Name="_FilterDatabase" '+CRLF
	cXML += ' 	ss:RefersTo="='+cWorkSheet+'!R3C1:R'+cValToChar(nRegistros+3)+'C15"'+CRLF
	cXML += ' 	ss:Hidden="1"/>'+CRLF
	cXML += ' </Names>'+CRLF

	cXML += U_prtCellXML( 'Table' )

	cXML += '<Column ss:Width="52.5"/>'+CRLF
    cXML += '<Column ss:Width="67.5" ss:Span="2"/>'+CRLF
    cXML += '<Column ss:Index="5" ss:Width="53.25"/>'+CRLF
    cXML += '<Column ss:Width="99.75"/>'+CRLF
    cXML += '<Column ss:Width="63"/>'+CRLF
    cXML += '<Column ss:Width="66.75"/>'+CRLF
    cXML += '<Column ss:Width="68.25"/>'+CRLF
    cXML += '<Column ss:Width="55.5"/>'+CRLF
    cXML += '<Column ss:Width="53.25"/>'+CRLF
    cXML += '<Column ss:Width="60"/>'+CRLF
    cXML += '<Column ss:Width="68.25"/>'+CRLF

	cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '14'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)

	// Titulo
	cXML += U_prtCellXML( 'Row' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/, '6'/*cIndex*/,'1'/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dieta Atual'		,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'12'/*cIndex*/,'2'/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Manejo de Cocho'	,,.T. )
	cXML += U_prtCellXML( '</Row>' )
	cXML += U_prtCellXML( 'Row',,'33' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Filial'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data' 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Curral' 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Lote' 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtd. Trato'			,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dieta'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dias de Cocho'		,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Previsto'			,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Realizado'			,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dif. Kg'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dif. %'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Tarde'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Noite'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Manhï¿½'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Tratador'			,,.T. )
	cXML += U_prtCellXML( '</Row>' )

	//fQuadro1
	While !(_cAliasG)->(Eof())

		cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_FILIAL )        ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData', 'DateTime', /*cFormula*/, U_FrmtVlrExcel( sToD( (_cAliasG)->Z05_DATA ) )  ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z06_CURRAL )        ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z06_LOTE )          ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->QTD_TRATO )         ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z06_DIETA )         ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->DIAS_COCHO )        ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->PREVISTO )			,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->REALIZADO )			,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=RC[-1]-RC[-2]" /*cFormula*/, 								,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=RC[-1]/RC[-2]*100" /*cFormula*/, 							,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->NOTA_TARDE )        ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->NOTA_NOITE )        ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->NOTA_MANHA )        ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0U_NOME )          ,,.T. )
		cXML += U_prtCellXML( '</Row>' )
		
		(_cAliasG)->(DbSkip())
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""

	EndDo
	
	// // SOMA
	// cXML += U_prtCellXML( 'Row' )
	// cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[2]C:R["+cValToChar(nRegistros+3)+"]C)" /*cFormula*/, )
	// cXML += U_prtCellXML( '</Row>' )

	// cXML += U_prtCellXML( 'pulalinha','1' )
	
	// Final da Planilha
	cXML += '</Table>'+CRLF
    cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
    cXML += '  <PageSetup>'+CRLF
    cXML += '   <Header x:Margin="0.31496062000000002"/>'+CRLF
    cXML += '   <Footer x:Margin="0.31496062000000002"/>'+CRLF
    cXML += '   <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"'+CRLF
    cXML += '    x:Right="0.511811024" x:Top="0.78740157499999996"/>'+CRLF
    cXML += '  </PageSetup>'+CRLF
    cXML += '  <Unsynced/>'+CRLF
    cXML += '  <Selected/>'+CRLF
    cXML += '  <FreezePanes/>'+CRLF
    cXML += '  <FrozenNoSplit/>'+CRLF
    cXML += '  <SplitHorizontal>3</SplitHorizontal>'+CRLF
    cXML += '  <TopRowBottomPane>3</TopRowBottomPane>'+CRLF
    cXML += '  <ActivePane>2</ActivePane>'+CRLF
    cXML += '  <Panes>'+CRLF
    cXML += '   <Pane>'+CRLF
    cXML += '    <Number>3</Number>'+CRLF
    cXML += '   </Pane>'+CRLF
    cXML += '   <Pane>'+CRLF
    cXML += '    <Number>2</Number>'+CRLF
    cXML += '   </Pane>'+CRLF
    cXML += '  </Panes>'+CRLF
    cXML += '  <ProtectObjects>False</ProtectObjects>'+CRLF
    cXML += '  <ProtectScenarios>False</ProtectScenarios>'+CRLF
    cXML += ' </WorksheetOptions>'+CRLF
    cXML += ' <AutoFilter x:Range="R3C1:R'+cValToChar(nRegistros+3)+'C15"'+CRLF
    cXML += '  xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
    cXML += ' </AutoFilter>'+CRLF
    cXML += '</Worksheet>'+CRLF
 
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""
	
EndIf	

Return nil
// FIM: fQuadro1 - U_PCPREL03()
