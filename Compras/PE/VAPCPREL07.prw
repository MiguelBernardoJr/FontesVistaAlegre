#include 'TOTVS.CH'
#include 'fileio.ch'
#include 'RWMAKE.CH'
#include 'protheus.ch'
#include 'parmtype.ch'

/*---------------------------------------------------------------------------------,
 | Analista : Arthur Toshio Oda Vanzella   r                                       |
 | Data		: 10.03.2020                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatório de recebimento de insumos                                  |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL07()                                                         |
 '---------------------------------------------------------------------------------*/
user function PCPREL07()
	
Local cTimeIni	 	:= Time()
Local cStyle		:= ""
Local cXML	   		:= ""
Local lTemDados		:= .T.
Local cPerg			:= SubS(ProcName(),3) // "PCPREL03"

Private cTitulo  	:= "Relatório - Recebimento de Insumos"

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
						'Processando Banco de Dados - Recebimento')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Recebimento')
			
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
		
		If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin, administrador'
			Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
		EndIf
		
		ConOut('Activate: ' + Time())
	EndIf
EndIf

Return nil

/*---------------------------------------------------------------------------------,
 | Analista : Arthur Toshio Oda Vanzella                                           |
 | Data		: 10.03.2020                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                        				       		   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL07()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local aRegs		:= {}
Local i         := 0
Local J         := 0
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

aAdd( aRegs, { cPerg, "01", "Data Digit. De?       ", "", "", "MV_CH1", "D", TamSX3("D1_DTDIGIT")[1]  , TamSX3("Z05_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR01", "", "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd( aRegs, { cPerg, "02", "Data Digit. Ate?      ", "", "", "MV_CH2", "D", TamSX3("D1_DTDIGIT")[1]  , TamSX3("Z05_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR02", "", "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd( aRegs, { cPerg, "03", "Produto?   	       ", "", "", "MV_CH3", "C", TamSX3("D1_COD")[1]	  , TamSX3("B8_LOTECTL")[2], 0, "G", ""		   , "MV_PAR03", "", "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})

	
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

	
	_cQry := " SELECT D1_FILIAL, D1_DOC+'-'+D1_SERIE D1_DOC, D1_EMISSAO EMISSAO, D1_DTDIGIT DT_DIGIT,  "+CRLF
	_cQry += " 	          D1_FORNECE, RTRIM(A2_NOME) A2_NOME, A2_MUN, A2_EST, RTRIM(D1_COD) D1_COD, RTRIM(B1_DESC) B1_DESC, D1_UM, D1_QUANT D1_QUANT, D1_X_PESOB , (D1_QUANT-D1_X_PESOB) DIFERENCA, D1_X_UMIDA, "+CRLF
    _cQry += " 			  ISNULL ((SELECT D2_QUANT FROM SD2010 D2 WHERE D2_TIPO = 'D' AND D2_FILIAL = D1_FILIAL AND D2_COD = D1_COD AND D2_ITEM = D1_ITEM AND D2_NFORI = D1_DOC AND D2_SERIORI = D1_SERIE AND D2_CLIENTE+D2_LOJA = D1_FORNECE+D1_LOJA AND D2.D_E_L_E_T_ =  ' '), 0) AS QT_DEV, "+CRLF
    _cQry += " 			  ISNULL ((SELECT D3_QUANT FROM SD3010 D3 WHERE D1_FILIAL = D3_FILIAL AND D3_COD = D1_COD AND D3_TM = '301' AND D3_EMISSAO = D1_DTDIGIT AND D3_FORNECE = D1_FORNECE AND D3.D_E_L_E_T_ = ' ' AND D3_ESTORNO = ' ' AND SUBSTRING(D3_X_OBS,9,9) = RTRIM(D1_DOC) AND ROUND(ABS(D1_X_PESOB - D1_QUANT),2) = ROUND(D3_QUANT,2)),0) D3_QUANT "+CRLF			
    _cQry += "          FROM " + RetSqlName("SD1") + " D1 "+CRLF
    _cQry += " 		 JOIN " + RetSqlName("SB1") + " B1 ON "+CRLF
    _cQry += " 		      B1.B1_COD = D1.D1_COD  "+CRLF
    _cQry += " 		  AND B1.D_E_L_E_T_ = ' '  "+CRLF
    _cQry += " 		 JOIN " + RetSqlName("SA2") + " A2 ON "+CRLF
    _cQry += " 		      A2_COD+A2_LOJA = D1_FORNECE+D1_LOJA "+CRLF
    _cQry += " 		  AND A2.D_E_L_E_T_ = ' '  "+CRLF
    _cQry += " 		WHERE D1_GRUPO = '02'  "+CRLF
    _cQry += " 		  AND D1_DTDIGIT BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'"+CRLF
    _cQry += " 		  AND D1.D_E_L_E_T_ = ' ' "+CRLF
    _cQry += " 		  AND D1_TIPO = 'N' "+CRLF
    If !Empty(MV_PAR03)
    	_cQry += " 		  AND D1_COD = '" + MV_PAR03 + ""+CRLF
    EndIf
    _cQry += " 		  AND A2_NOME NOT LIKE 'AGROPECUARIA%VISTA%ALEGRE%' "+CRLF
    _cQry += "      ORDER BY D1_DTDIGIT "+CRLF


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
 | Obs.     : U_PCPREL07()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function fQuadro1()

Local nRegistros	:= 0 // MV_PAR02 - MV_PAR01
Local cXML 			:= ""
Local cWorkSheet 	:= ""

Local cLote  		:= ""

(_cAliasG)->(DbEval({|| nRegistros++ }))

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	cWorkSheet := "Recebimento"

	cXML += U_prtCellXML( 'Worksheet', cWorkSheet )

	cXML += ' <Names>'+CRLF
	cXML += ' <NamedRange ss:Name="_FilterDatabase" '+CRLF
	cXML += ' 	ss:RefersTo="='+cWorkSheet+'!R2C1:R'+cValToChar(nRegistros+1)+'C17"'+CRLF
	cXML += ' 	ss:Hidden="1"/>'+CRLF
	cXML += ' </Names>'+CRLF

	cXML += U_prtCellXML( 'Table' )

	cXML += '<Column ss:Width="52.5"/>'+CRLF
	cXML += '<Column ss:Width="84"/>'+CRLF
    cXML += '<Column ss:Width="67.5" ss:Span="2"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="207.75"/>'+CRLF
    cXML += '<Column ss:Width="84"/>'+CRLF
    cXML += '<Column ss:Width="50"/>'+CRLF
    cXML += '<Column ss:Width="64"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="189"/>'+CRLF
    cXML += '<Column ss:Width="50"/>'+CRLF
    cXML += '<Column ss:Width="53.25"/>'+CRLF
    cXML += '<Column ss:Width="60"/>'+CRLF
    cXML += '<Column ss:Width="68.25"/>'+CRLF
    
	cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '16'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)

	// Titulo
	  cXML += U_prtCellXML( 'Row',,'33' )
/*01*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Filial'				,,.T. )
/*02*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Nota Fiscal' 			,,.T. )
/*03*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dt Emissao' 			,,.T. )
/*04*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dt Digitação' 			,,.T. )
/*05*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Cod Fornecedor'		,,.T. )
/*06*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Razão Social'			,,.T. )
/*07*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Cidade'				,,.T. )
/*08*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Estado'				,,.T. )
/*09*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Produto'				,,.T. )
/*10*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Descrição'				,,.T. )
/*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'UM'					,,.T. )
/*12*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso NF'				,,.T. )
/*13*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Balança'			,,.T. )
/*14*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença'				,,.T. )
/*15*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Úmidade'				,,.T. )
/*16*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtd Devolvida'			,,.T. )
/*17*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtd TM Entrada'		,,.T. )

	  cXML += U_prtCellXML( '</Row>' )

	//fQuadro1
	While !(_cAliasG)->(Eof())

	  cXML += U_prtCellXML( 'Row' )
/*01*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->D1_FILIAL )           ,,.T. )
/*02*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->D1_DOC )         	  ,,.T. )
/*03*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData', 'DateTime', /*cFormula*/, U_FrmtVlrExcel( sToD( (_cAliasG)->EMISSAO ) )     ,,.T. )
/*04*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData', 'DateTime', /*cFormula*/, U_FrmtVlrExcel( sToD( (_cAliasG)->DT_DIGIT ) )    ,,.T. )
/*05*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->D1_FORNECE )          ,,.T. )
/*06*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->A2_NOME )        	  ,,.T. )
/*07*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->A2_MUN )         	  ,,.T. )
/*08*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->A2_EST )        	  ,,.T. )
/*09*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->D1_COD )			  ,,.T. )
/*10*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->B1_DESC )			  ,,.T. )
/*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->D1_UM )				  ,,.T. )
/*12*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->D1_QUANT )			  ,,.T. )
/*13*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->D1_X_PESOB )		  ,,.T. )
/*14*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->DIFERENCA )			  ,,.T. )
/*15*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->D1_X_UMIDA )		  ,,.T. )
/*16*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->QT_DEV )			  ,,.T. )
/*16*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->D3_QUANT  )			  ,,.T. )
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
    cXML += '  <SplitHorizontal>2</SplitHorizontal>'+CRLF
    cXML += '  <TopRowBottomPane>2</TopRowBottomPane>'+CRLF
    cXML += '  <ActivePane>2</ActivePane>'+CRLF
    cXML += '  <Panes>'+CRLF
    cXML += '   <Pane>'+CRLF
    cXML += '    <Number>3</Number>'+CRLF
    cXML += '   </Pane>'+CRLF
    cXML += '   <Pane>'+CRLF
    cXML += '    <Number>2</Number>'+CRLF
    cXML += '    <RangeSelection>R3</RangeSelection>'+CRLF
    cXML += '   </Pane>'+CRLF
    cXML += '  </Panes>'+CRLF
    cXML += '  <ProtectObjects>False</ProtectObjects>'+CRLF
    cXML += '  <ProtectScenarios>False</ProtectScenarios>'+CRLF
    cXML += ' </WorksheetOptions>'+CRLF
    cXML += ' <AutoFilter x:Range="R2C1:R'+cValToChar(nRegistros+3)+'C17"'+CRLF
    cXML += '  xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
    cXML += ' </AutoFilter>'+CRLF
    cXML += '</Worksheet>'+CRLF
 
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""
	
EndIf	

Return nil
