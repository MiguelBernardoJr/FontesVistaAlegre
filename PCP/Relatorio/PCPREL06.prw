#include 'TOTVS.CH'
#include 'fileio.ch'
#include 'RWMAKE.CH'
#include 'protheus.ch'
#include 'parmtype.ch'

/*---------------------------------------------------------------------------------,
 | Analista : Arthur Toshio Oda Vanzella   r                                       |
 | Data		: 01.02.2020                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatorio de análise de desempenho do trato      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL06()                                                         |
 '---------------------------------------------------------------------------------*/

user function PCPREL06()
Local cTimeIni	 	:= Time()
Local cStyle		:= ""
Local cXML	   		:= ""
Local lTemDados		:= .T.

Private cPerg		:= SubS(ProcName(),3) // "PCPREL06"
Private cTitulo  	:= " "

Private cPath 	 	:= "C:\TOTVS_RELATORIOS\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasT	:= GetNextAlias()   

//Private _cAliasT	:= GetNextAlias()   

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
		FWMsgRun(, {|| lTemDados := fLoadSql("CARREGAMENTO", @_cAliasT ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Carregamento')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Carregamento')
			(_cAliasT)->(DbCloseArea())
			
			// Planilha 2
			FWMsgRun(, {|| lTemDados := fLoadSql("PRODUTO", @_cAliasT ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - PRODUTOS')
			If lTemDados
				FWMsgRun(, {|| fQuadro2() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Trato')
			EndIf
			(_cAliasT)->(DbCloseArea())
			
			// Planilha 3
			FWMsgRun(, {|| lTemDados := fLoadSql("LOTES", @_cAliasT ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - LOTES')
			If lTemDados
				FWMsgRun(, {|| fQuadro3() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Trato')
			EndIf
			(_cAliasT)->(DbCloseArea())
			
			If MV_PAR11==2
				U_CellSX1Excel(cPerg)
			EndIf
			
			// Final - encerramento do arquivo
			FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )
			
			FClose(nHandle)

			If ApOleClient("MSExcel")				//	 U_PCPREL06()
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
		
		//(_cAliasT)->(DbCloseArea())
		
		If lower(cUserName) $ 'mbernardo,atoshio,admin, administrador'
			Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
		EndIf
		
		ConOut('Activate: ' + Time())
	EndIf
EndIf

Return nil
// FIM: PCPREL06()

/*---------------------------------------------------------------------------------,
 | Analista : Arthur Toshio Oda Vanzella                                           |
 | Data		: 02.01.2020                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                        				       		   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL06()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
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

aAdd(aRegs,{cPerg, "01", "Data De?"        , "", "", "MV_CH1", "D", TamSX3("Z0X_DATA")[1]  , TamSX3("Z0X_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR01", ""   , "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Data Ate?"       , "", "", "MV_CH2", "D", TamSX3("Z0X_DATA")[1]  , TamSX3("Z0X_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR02", ""   , "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "11", "Exibe Perguntas?", "", "", "MV_CHB", "N", 					     1,					      0, 2, "C", "NaoVazio", "MV_PAR11", "Não","","","","","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})

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




Static Function fLoadSql(cTipo, _cAlias)
Local _cQry 		:= ""

If cTipo == "CARREGAMENTO"

	_cQry := "  WITH DADOSA AS (  " +CRLF
	_cQry += "    SELECT Z0Y_FILIAL  " +CRLF
	_cQry += "  	   , Z0Y_ROTA  " +CRLF
	_cQry += "  	   , ZV0_IDENT  " +CRLF
	_cQry += "  	   , Z0U_NOME  " +CRLF
	_cQry += "         , Z0Y_DATA  " +CRLF
	_cQry += "  	   , Z0Y_RECEIT  " +CRLF
	_cQry += "         , Z0Y_COMP  " +CRLF
	_cQry += "  	   , B1_DESC  " +CRLF
	_cQry += "  	   , Z0Y_TRATO   " +CRLF
	_cQry += "         , SUM(Z0Y_QTDPRE) Z0Y_QTDPRE  --Z0Y_QTDPRE" +CRLF
	_cQry += "  	   , SUM(CASE WHEN Z0Y_PESDIG <> 0 THEN Z0Y_PESDIG ELSE Z0Y_QTDREA END ) Z0Y_QTDREA  " +CRLF
	_cQry += "         , ABS(SUM(CASE WHEN Z0Y_PESDIG <> 0 THEN Z0Y_PESDIG ELSE Z0Y_QTDREA END )-SUM(Z0Y_QTDPRE)) DIFERENCA   " +CRLF
	_cQry += "    FROM " + RetSqlName("Z0Y") + " Z0Y  " +CRLF
	_cQry += "    JOIN " + RetSqlName("Z0X") + " Z0X ON Z0Y_FILIAL = Z0X_FILIAL AND Z0Y_CODEI = Z0X_CODIGO AND Z0Y_DATA = Z0X_DATA AND Z0X.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "    JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = Z0Y_COMP AND SB1.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "    JOIN " + RetSqlName("ZV0") + " ZV0 ON ZV0_CODIGO = Z0X_EQUIP AND ZV0.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "    JOIN " + RetSqlName("Z0U") + " Z0U ON Z0U_CODIGO = Z0X_OPERAD AND Z0U.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "    WHERE Z0Y_DATA BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' AND Z0Y.D_E_L_E_T_ = ' '    " +CRLF
	_cQry += "    " +CRLF
	_cQry += "  GROUP BY Z0Y_FILIAL, Z0Y_ROTA, Z0Y_RECEIT, Z0Y_COMP, B1_DESC, Z0Y_DATA, ZV0_IDENT, Z0U_NOME, Z0Y_TRATO  " +CRLF
	_cQry += "  --ORDER BY 7 DESC  " +CRLF
	_cQry += "  )  " +CRLF
	_cQry += "  select TOP(10) DIFERENCA, Z0Y_DATA, Z0Y_ROTA, ZV0_IDENT, Z0U_NOME, Z0Y_RECEIT, Z0Y_COMP, B1_DESC, Z0Y_TRATO, Z0Y_QTDPRE, Z0Y_QTDREA  " +CRLF
	_cQry += "    from DADOSA  " +CRLF
	_cQry += "  ORDER BY DIFERENCA DESC  " +CRLF
	
ElseIf cTipo == "PRODUTO"
	
	_cQry := "  WITH DIFPROD AS (  " +CRLF
	_cQry += "      SELECT Z0Y_FILIAL  " +CRLF
	_cQry += "  	     , Z0Y_DATA  " +CRLF
	_cQry += "  		 , Z0Y_COMP  " +CRLF
	_cQry += "  	     , B1_DESC  " +CRLF
	_cQry += "  		 , COUNT(Z0Y_TRATO) QTD_TRATO  " +CRLF
	_cQry += "  	     , SUM(Z0Y_QTDPRE) Z0Y_QTDPRE  -- Z0Y_QTDPRE" +CRLF
	_cQry += "  	     , SUM(CASE WHEN Z0Y_PESDIG <> 0 THEN Z0Y_PESDIG ELSE Z0Y_QTDREA END ) Z0Y_QTDREA  " +CRLF
	_cQry += "           , ABS(SUM(CASE WHEN Z0Y_PESDIG <> 0 THEN Z0Y_PESDIG ELSE Z0Y_QTDREA END )-SUM(Z0Y_QTDPRE)) DIFERENCA   " +CRLF	
	_cQry += "        FROM " + RetSqlName("Z0Y") + " Z0Y  " +CRLF
	_cQry += "  	  JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = Z0Y_COMP AND SB1.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "  	  JOIN " + RetSqlName("Z0X") + " Z0X ON Z0Y_FILIAL = Z0X_FILIAL AND Z0Y_CODEI = Z0X_CODIGO AND Z0Y_DATA = Z0X_DATA AND Z0X.D_E_L_E_T_ = ' ' AND Z0X_OPERAC = '1'  " +CRLF
	_cQry += "       WHERE Z0Y_DATA BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'  " +CRLF
	_cQry += "  	   AND Z0Y.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "  	   GROUP BY Z0Y_FILIAL, Z0Y_DATA, Z0Y_COMP, B1_DESC  " +CRLF
	_cQry += "  )  " +CRLF
	_cQry += "      SELECT TOP(10) DIFERENCA  " +CRLF
	_cQry += "  	     , Z0Y_FILIAL  " +CRLF
	_cQry += "  	     , Z0Y_DATA  " +CRLF
	_cQry += "  		 , Z0Y_COMP  " +CRLF
	_cQry += "  	     , B1_DESC  " +CRLF
	_cQry += "  		 , QTD_TRATO  " +CRLF
	_cQry += "  	     , Z0Y_QTDPRE  " +CRLF
	_cQry += "  	     , Z0Y_QTDREA   " +CRLF
	_cQry += "        FROM DIFPROD   " +CRLF
	_cQry += "      ORDER BY DIFERENCA DESC   " +CRLF
	
ElseIf cTipo == "LOTES"

	_cQry := "   WITH DADOS AS (  " +CRLF
	_cQry += "    SELECT Z0W_FILIAL  " +CRLF
	_cQry += "  	   , ZV0_IDENT  " +CRLF
	_cQry += "  	   , Z0U_NOME  " +CRLF
	_cQry += "         , Z0W_DATA  " +CRLF
	_cQry += "         , Z0W_CURRAL  " +CRLF
	_cQry += "         , Z0W_LOTE  " +CRLF
	_cQry += "  	   , COUNT(Z0W_TRATO) QTD_TRATO  " +CRLF
	_cQry += "         , SUM(Z0W_QTDPRE) Z0W_QTDPRE  " +CRLF
	_cQry += "  	   , SUM(CASE WHEN Z0W_PESDIG <> 0 THEN Z0W_PESDIG ELSE Z0W_QTDREA END ) Z0W_QTDREA  " +CRLF
	_cQry += "         , ABS(SUM(CASE WHEN Z0W_PESDIG <> 0 THEN Z0W_PESDIG ELSE Z0W_QTDREA END )-SUM(Z0W_QTDPRE)) DIFERENCA  " +CRLF
	_cQry += "  	   --, Z0I_NOTMAN    " +CRLF
	_cQry += "    FROM Z0W010 Z0W  " +CRLF
	_cQry += "    JOIN " + RetSqlName("Z0X") + " Z0X ON Z0W_FILIAL = Z0X_FILIAL AND Z0W_CODEI = Z0X_CODIGO AND Z0W_DATA = Z0X_DATA AND Z0X.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "    JOIN " + RetSqlName("ZV0") + " ZV0 ON ZV0_CODIGO = Z0X_EQUIP AND ZV0.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "    --LEFT JOIN " + RetSqlName("Z0I") + " Z0I ON Z0I_FILIAL = Z0W_FILIAL AND Z0I_CURRAL = Z0W_CURRAL AND Z0I_LOTE = Z0W_LOTE AND Z0I_LOTE = Z0W_LOTE AND Z0I_DATA = '20200202' AND Z0I.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "    JOIN " + RetSqlName("Z0U") + " Z0U ON Z0U_CODIGO = Z0X_OPERAD AND Z0U.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "    WHERE Z0W_DATA BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"' AND Z0W.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "    " +CRLF
	_cQry += "  GROUP BY Z0W_FILIAL, Z0W_CURRAL, Z0W_LOTE, Z0W_DATA, ZV0_IDENT, Z0U_NOME  " +CRLF
	_cQry += "  --ORDER BY 7 DESC  " +CRLF
	_cQry += "    " +CRLF
	_cQry += "  )  " +CRLF
	_cQry += "    " +CRLF
	_cQry += "  SELECT top(10) DIFERENCA, ZV0_IDENT, Z0U_NOME, Z0W_DATA, Z0W_CURRAL, Z0W_LOTE, QTD_TRATO,  Z0W_QTDPRE, Z0W_QTDREA  " +CRLF
	_cQry += "  FROM DADOS  " +CRLF
	_cQry += "  ORDER BY DIFERENCA DESC  " +CRLF

EndIf

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

Return !(_cAlias)->(Eof())
// FIM: fLoadSql()		
	
/*---------------------------------------------------------------------------------,
 | Analista : Arthur Toshio Oda Vanzella                                           |
 | Data		: 03.02.2020                                                           |
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
Local cTitulo 		:= "Top 10 Carregamentos de produtos com diferença por Equipamento / Operador "
(_cAliasT)->(DbEval({|| nRegistros++ }))

(_cAliasT)->(DbGoTop()) 
If !(_cAliasT)->(Eof())

	cWorkSheet := "CARREGAMENTO"

	cXML += U_prtCellXML( 'Worksheet', cWorkSheet )

	cXML += ' <Names>'+CRLF
	cXML += ' <NamedRange ss:Name="_FilterDatabase" '+CRLF
	cXML += ' 	ss:RefersTo="='+cWorkSheet+'!R3C1:R'+cValToChar(nRegistros+3)+'C11"'+CRLF
	cXML += ' 	ss:Hidden="1"/>'+CRLF
	cXML += ' </Names>'+CRLF

	cXML += U_prtCellXML( 'Table' )

	cXML += '<Column ss:Width="63.75"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="60"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="77.25"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="54"/>'+CRLF
    cXML += '<Column ss:Width="89.25"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="63.75"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="119.25"/>'+CRLF
    cXML += '<Column ss:StyleID="s77" ss:Width="66.75"/>'+CRLF
    cXML += '<Column ss:Width="68.25"/>'+CRLF
    cXML += '<Column ss:Width="55.5"/>'+CRLF
    cXML += '<Column ss:Width="53.25"/>'+CRLF
    cXML += '<Column ss:Width="60"/>'+CRLF
    cXML += '<Column ss:Width="68.25"/>'+CRLF


	cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '10'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)

	// Titulo
	cXML += U_prtCellXML( 'Row',,'33' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data'			,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Rota' 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Equip.' 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Operador' 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Receita'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Componente'		,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Descrição'			,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Trato'			,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Previsto'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Realizado'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença'				,,.T. )
	cXML += U_prtCellXML( '</Row>' )

	//fQuadro1
	While !(_cAliasT)->(Eof())

		cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData',   'DateTime', /*cFormula*/, U_FrmtVlrExcel( sToD( (_cAliasT)->Z0Y_DATA ) )  ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0Y_ROTA )        	,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->ZV0_IDENT )        	,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0U_NOME )          	,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0Y_RECEIT )          ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0Y_COMP )         	,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->B1_DESC )      	  	,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0Y_TRATO )			,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0Y_QTDPRE )			,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0Y_QTDREA )      	,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', "=RC[-1]-RC[-2]" /*cFormula*/, 									,,.T. )

		cXML += U_prtCellXML( '</Row>' )
		
		(_cAliasT)->(DbSkip())
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""

	EndDo
	

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
    cXML += ' <AutoFilter x:Range="R2C1:R'+cValToChar(nRegistros+2)+'C11"'+CRLF
    cXML += '  xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
    cXML += ' </AutoFilter>'+CRLF
    cXML += '</Worksheet>'+CRLF
 
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""
	
EndIf	

Return nil
// FIM: fQuadro1 - U_PCPREL06()

Static Function fQuadro2()
// TOP 10 PRODUTOS DO CARREGAMENTO COM DIFERENÇA
Local nRegistros	:= 0 // MV_PAR02 - MV_PAR01
Local cXML 			:= ""
Local cWorkSheet 	:= ""
Local cTitulo		:= "Top do Produtos com diferença no Carregamento no dia "
(_cAliasT)->(DbEval({|| nRegistros++ }))

(_cAliasT)->(DbGoTop()) 
If !(_cAliasT)->(Eof())

	cWorkSheet := "PRODUTO"

	cXML += U_prtCellXML( 'Worksheet', cWorkSheet )

	cXML += ' <Names>'+CRLF
	cXML += ' <NamedRange ss:Name="_FilterDatabase" '+CRLF
	cXML += ' 	ss:RefersTo="='+cWorkSheet+'!R3C1:R'+cValToChar(nRegistros+3)+'C11"'+CRLF
	cXML += ' 	ss:Hidden="1"/>'+CRLF
	cXML += ' </Names>'+CRLF

	cXML += U_prtCellXML( 'Table' )

	cXML += '<Column ss:Width="63.75"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="60"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="140.25"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="54"/>'+CRLF
    cXML += '<Column ss:Width="89.25"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="63.75"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="80.25"/>'+CRLF
    cXML += '<Column ss:StyleID="s77" ss:Width="66.75"/>'+CRLF
    cXML += '<Column ss:Width="68.25"/>'+CRLF
    cXML += '<Column ss:Width="55.5"/>'+CRLF
    cXML += '<Column ss:Width="53.25"/>'+CRLF
    cXML += '<Column ss:Width="60"/>'+CRLF
    cXML += '<Column ss:Width="68.25"/>'+CRLF


	cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '10'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)

	// Titulo
	cXML += U_prtCellXML( 'Row',,'33' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data'					,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Componente'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Descrição'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtde. Carregamentos'		,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Previsto'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Realizado'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença'				,,.T. )
	cXML += U_prtCellXML( '</Row>' )

	//fQuadro1
	While !(_cAliasT)->(Eof())

		cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData',   'DateTime', /*cFormula*/, U_FrmtVlrExcel( sToD( (_cAliasT)->Z0Y_DATA ) )  ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0Y_COMP )         	,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->B1_DESC )        		,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->QTD_TRATO )			,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0Y_QTDPRE )			,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0Y_QTDREA )        	,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', "=RC[-1]-RC[-2]" /*cFormula*/, 									,,.T. )
		cXML += U_prtCellXML( '</Row>' )
		
		(_cAliasT)->(DbSkip())
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""

	EndDo
	
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
    cXML += ' <AutoFilter x:Range="R2C1:R'+cValToChar(nRegistros+2)+'C7"'+CRLF
    cXML += '  xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
    cXML += ' </AutoFilter>'+CRLF
    cXML += '</Worksheet>'+CRLF
 
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""
	
EndIf	

Return nil
// FIM: fQuadro2 - U_PCPREL06()

Static Function fQuadro3()
// TOP 10 LOTES COM DIFERENÇA
Local nRegistros	:= 0 // MV_PAR02 - MV_PAR01
Local cXML 			:= ""
Local cWorkSheet 	:= ""
Local cTitulo 		:= "Top 10 Lotes com diferença nos apontamentos do trato"

(_cAliasT)->(DbEval({|| nRegistros++ }))

(_cAliasT)->(DbGoTop()) 
If !(_cAliasT)->(Eof())

	cWorkSheet := "LOTES"

	cXML += U_prtCellXML( 'Worksheet', cWorkSheet )

	cXML += ' <Names>'+CRLF
	cXML += ' <NamedRange ss:Name="_FilterDatabase" '+CRLF
	cXML += ' 	ss:RefersTo="='+cWorkSheet+'!R3C1:R'+cValToChar(nRegistros+3)+'C11"'+CRLF
	cXML += ' 	ss:Hidden="1"/>'+CRLF
	cXML += ' </Names>'+CRLF

	cXML += U_prtCellXML( 'Table' )

	cXML += '<Column ss:Width="63.75"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="60"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="77.25"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="54"/>'+CRLF
    cXML += '<Column ss:Width="89.25"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="75.75"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="75.75"/>'+CRLF
    cXML += '<Column ss:StyleID="s77" ss:Width="75.75"/>'+CRLF
    cXML += '<Column ss:Width="68.25"/>'+CRLF
    cXML += '<Column ss:Width="55.5"/>'+CRLF
    cXML += '<Column ss:Width="53.25"/>'+CRLF
    cXML += '<Column ss:Width="60"/>'+CRLF
    cXML += '<Column ss:Width="68.25"/>'+CRLF


	cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '10'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)

	// Titulo
	cXML += U_prtCellXML( 'Row',,'33' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data'					,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Equip.'					,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Operador'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Curral'					,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Lote'					,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Trato'	 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Previsto'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Realizado'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença'				,,.T. )
	cXML += U_prtCellXML( '</Row>' )

	//fQuadro1
	While !(_cAliasT)->(Eof())

		cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData',   'DateTime', /*cFormula*/, U_FrmtVlrExcel( sToD( (_cAliasT)->Z0W_DATA ) )  ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->ZV0_IDENT )         	,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0U_NOME )        	,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_CURRAL )        	,,.T. )		
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_LOTE )        	,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto',  'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->QTD_TRATO )			,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0w_QTDPRE )			,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_QTDREA )        	,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', "=RC[-1]-RC[-2]" /*cFormula*/, 									,,.T. )
		cXML += U_prtCellXML( '</Row>' )
		
		(_cAliasT)->(DbSkip())
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""

	EndDo
	
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
    cXML += ' <AutoFilter x:Range="R2C1:R'+cValToChar(nRegistros+2)+'C10"'+CRLF
    cXML += '  xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
    cXML += ' </AutoFilter>'+CRLF
    cXML += '</Worksheet>'+CRLF
 
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""
	
EndIf	

Return nil
// FIM: fQuadro3 - U_PCPREL06()

