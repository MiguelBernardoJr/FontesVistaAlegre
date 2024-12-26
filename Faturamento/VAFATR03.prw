#include 'FILEIO.CH'
#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"

/*---------------------------------------------------------------------------------,
 | Analista : Arthur Toshio Oda Vanzella                                           |
 | Data		: 21.12.2020                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatorio para conferencia de faturamento						       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_VAFATR03()                                                         |
 '---------------------------------------------------------------------------------*/
User Function VAFATR03()
Local cTimeIni	 	:= Time()
Local cStyle		:= ""
Local cXML	   		:= ""
Local lTemDados		:= .T.

Private cPerg		:= SubS(ProcName(),3) // "PCPREL02"
Private cTitulo  	:= "Relatório Controle de Faturamento"

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
		FWMsgRun(, {|| lTemDados := fLoadSql("Geral", @_cAliasG ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Conferencia Faturamento')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geraçãoo do Relatório de Conferência do faturamento')
			
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
		
		If lower(cUserName) $ 'mbernardo,atoshio,admin, administrador'
			Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
		EndIf
		
		ConOut('Activate: ' + Time())
	EndIf
EndIf

Return nil
// FIM: VAFATR03()


/*---------------------------------------------------------------------------------,
 | Analista : Arthur Toshio Oda Vanzella                                           |
 | Data		: 21.12.2020                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatorio para conferencia de faturamento						       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_VAFATR03()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local i, j
Local nLen		:= 0
Local nCount	:= 0
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

aAdd(aRegs,{cPerg, "01", "Emissão De?"    ,  "", "", "MV_CH1", "D", TamSX3("D2_EMISSAO")[1]  , TamSX3("D2_EMISSAO")[2]  , 0, "G", "NaoVazio", "MV_PAR01", ""   , "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Emissão Ate?"   ,  "", "", "MV_CH2", "D", TamSX3("D2_EMISSAO")[1]  , TamSX3("D2_EMISSAO")[2]  , 0, "G", "NaoVazio", "MV_PAR02", ""   , "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "03", "NF De?"         ,  "", "", "MV_CH3", "C", TamSX3("D2_DOC")[1]      , TamSX3("D2_DOC")[2]      , 0, "G", ""		, "MV_PAR03", ""   , "","",""      								 ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "04", "NF  Ate?"       ,  "", "", "MV_CH4", "C", TamSX3("D2_DOC")[1]      , TamSX3("D2_DOC")[2]      , 0, "G", ""        , "MV_PAR04", ""   , "","",""                                    ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "05", "NF Better De?"  ,  "", "", "MV_CH5", "C", TamSX3("D2_DOC")[1]      , TamSX3("D2_DOC")[2]      , 0, "G", ""		, "MV_PAR05", ""   , "","",""      								 ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "06", "NF Better Ate?" ,  "", "", "MV_CH6", "C", TamSX3("D2_DOC")[1]      , TamSX3("D2_DOC")[2]      , 0, "G", ""        , "MV_PAR06", ""   , "","",""                                    ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "07", "Cliente"        ,  "", "", "MV_CH7", "C", TamSX3("D2_CLIENTE")[1]  , TamSX3("D2_CLIENTE")[2]  , 0, "G", ""        , "MV_PAR07", ""   , "","",""                                    ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "08", "Grupo Produto"  ,  "", "", "MV_CH8", "C", TamSX3("D2_GRUPO")[1]    , TamSX3("D2_GRUPO")[2]    , 0, "G", ""        , "MV_PAR08", ""   , "","",""                                    ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})


//Se quantidade de perguntas for diferente, apago todas
SX1->(DbGoTop())
nLen := Len(aRegs)
If nPergs <> nLen 
	For i := 1 To nPergs
		If SX1->(DbSeek(cPerg))
			If RecLock('SX1',.F.)
				SX1->(DbDelete())
				SX1->(MsUnlock())
			EndIf
		EndIf
	Next i
	// gravaï¿½ï¿½o das perguntas na tabela SX1
	dbSelectArea("SX1")
	dbSetOrder(1)
	nCount := FCount()
	For i := 1 to nLen
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1", .T.)
				For j := 1 to nCount
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
 | Data		: 10.07.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                        				       		   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL02()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function fLoadSql(cTipo, _cAlias)
Local _cQry 		:= ""

  
    _cQry := "SELECT DISTINCT SD2.D2_EMISSAO, SUM(SD2.D2_QUANT) QTDE, SB1.B1_DESC, SD2.D2_FILIAL, SA1.A1_NOME, SD2.D2_DOC+'-'+SD2.D2_SERIE D2_DOC, SUM(D2_VALBRUT) VALOR, " + CRLF +;
	         "		       RTRIM(F4_TEXTO) F4_TEXTO, SD2.D2_LOTECTL, " + CRLF +;
	         "			   CASE WHEN SD2.D2_NFORI <> ' '   THEN SD2.D2_NFORI+'-'+SD2.D2_SERIORI ELSE ' ' END D2_NFORI, " + CRLF +;
	         "			   CASE WHEN SF2.F2_X_NFENT <> ' ' THEN SF2.F2_X_NFENT ELSE SF2C.F2_X_NFENT END F2_X_NFENT, " + CRLF +;
	         "			   CASE WHEN SF2.F2_X_DTENT <> ' ' THEN SF2.F2_X_DTENT ELSE SF2C.F2_X_DTENT END F2_X_DTENT " + CRLF +;
	         "		  FROM " + RetSqlName("SD2") + " SD2" + CRLF +;
	         "		  JOIN " + RetSqlName("SF2") + " SF2 ON " + CRLF +;
	         "		       SF2.F2_FILIAL = SD2.D2_FILIAL " + CRLF +;
	         "		   AND SF2.F2_DOC+SF2.F2_SERIE = SD2.D2_DOC+SD2.D2_SERIE" + CRLF +;
	         "		   AND SF2.F2_CLIENTE+SF2.F2_LOJA = SD2.D2_CLIENTE+SD2.D2_LOJA" + CRLF +;
	         "		   AND SF2.F2_EMISSAO = SF2.F2_EMISSAO " + CRLF +;
	         "		   AND SF2.D_E_L_E_T_ = ' ' " + CRLF +;
	         "		  JOIN " + RetSqlName("SB1") + " SB1 ON " + CRLF +;
	         "		       SB1.B1_FILIAL = ' ' " + CRLF +;
	         "		   AND SB1.B1_COD = SD2.D2_COD" + CRLF +;
	         "		   AND SB1.B1_GRUPO = SD2.D2_GRUPO" + CRLF 
        If !Empty(MV_PAR08)
            _cQry +=  "		   AND SB1.B1_GRUPO = '" + MV_PAR08 + "' "+ CRLF 
        EndIf
    _cQry += "		   AND SB1.D_E_L_E_T_ = ' ' " + CRLF +;
	         "		  JOIN " + RetSqlName("SA1") + " SA1 ON " + CRLF +;
	         "			   SA1.A1_FILIAL = ' ' " + CRLF +;
	         "		   AND SA1.A1_COD+SA1.A1_LOJA = SD2.D2_CLIENTE+SD2.D2_LOJA" + CRLF +;
	         "		   AND SA1.D_E_L_E_T_ = ' '" + CRLF +;
	         "		  JOIN " + RetSqlName("SF4") + " SF4 ON" + CRLF +;
	         "		       SF4.F4_FILIAL = ' '" + CRLF +;
	         "		   AND SF4.F4_CODIGO = SD2.D2_TES" + CRLF +;
	         "		   AND SF4.D_E_L_E_T_ = ' ' " + CRLF +;
             "         AND SF4.F4_DUPLIC ='S' " + CRLF +;
	         "	 LEFT JOIN " + RetSqlName("SF2") + " SF2C ON" + CRLF +;
	         "		       SF2C.F2_FILIAL = SD2.D2_FILIAL" + CRLF +;
	         "		   AND SF2C.F2_DOC+SF2C.F2_SERIE = SD2.D2_NFORI+SD2.D2_SERIORI" + CRLF +;
	         "		   AND SF2C.D_E_L_E_T_ = ' ' " + CRLF +;
             "       WHERE SD2.D2_EMISSAO BETWEEN '" + DToS(MV_PAR01) + "' and '" + DToS(MV_PAR02) + "'" + CRLF 
        If !Empty(MV_PAR07)
            _cQry +=  "         AND SD2.D2_CLIENTE = '"+MV_PAR07+"'" + CRLF 
        EndIf
			_cQry += "         AND SD2.D_E_L_E_T_ = ' ' " + CRLF 
        IF !Empty(MV_PAR03)
            _cQry += "    AND SD2.D2_DOC BETWEEN '" + MV_PAR03 + "' and '" + MV_PAR04 + "'" + CRLF 
        EndIf
        IF !Empty(MV_PAR05)
            _cQry +=  "    AND (SF2.F2_X_NFENT BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' or SF2C.F2_X_NFENT BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' )" + CRLF 
        EndIf
     _cQry +="GROUP BY SD2.D2_EMISSAO, SB1.B1_DESC, SD2.D2_FILIAL, SA1.A1_NOME, D2_DOC, D2_SERIE, F4_TEXTO, SD2.D2_LOTECTL, SD2.D2_NFORI, SD2.D2_SERIORI, SF2.F2_X_NFENT, SF2.F2_X_DTENT," + CRLF +;
             "        SF2C.F2_X_NFENT, SF2C.F2_X_DTENT" + CRLF +;
             "ORDER BY 4,1,6" 
    

    If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

Return !(_cAlias)->(Eof())


Static Function fQuadro1()

Local nRegistros	:= 0 // MV_PAR02 - MV_PAR01
Local cXML 			:= ""
Local cWorkSheet 	:= "" // "Diï¿½ria"


(_cAliasG)->(DbEval({|| nRegistros++ }))

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	cWorkSheet := "Geral" // AllTrim((_cAliasG)->Z0W_LOTE)

	cXML += U_prtCellXML( 'Worksheet', cWorkSheet )

	cXML += ' <Names>'+CRLF
	cXML += ' <NamedRange ss:Name="_FilterDatabase" '+CRLF
	cXML += ' 	ss:RefersTo="='+cWorkSheet+'!R3C1:R'+cValToChar(nRegistros+1)+'C13"'+CRLF
	cXML += ' 	ss:Hidden="1"/>'+CRLF
	cXML += ' </Names>'+CRLF

	cXML += U_prtCellXML( 'Table' )

	cXML += '<Column ss:Width="50.5"/>'+CRLF  // DATA
    cXML += '<Column ss:Width="52.75"/>'+CRLF // QTDE
    cXML += '<Column ss:Width="60.75"/>'+CRLF // DESCRICAO
    cXML += '<Column ss:Width="48.75"/>'+CRLF // FILIAL
    cXML += '<Column ss:Width="90.75"/>'+CRLF // CLIENTE
    cXML += '<Column ss:Width="70.75"/>'+CRLF // NUMERO NF
    cXML += '<Column ss:Width="75.75"/>'+CRLF // VALOR
    cXML += '<Column ss:Width="100.75"/>'+CRLF // TES
    cXML += '<Column ss:Width="55.75"/>'+CRLF // LOTE
    cXML += '<Column ss:Width="70.75"/>'+CRLF // NUMERO NF
    cXML += '<Column ss:Width="70.75"/>'+CRLF // NUMERO NF
    cXML += '<Column ss:Width="70.75"/>'+CRLF // NUMERO NF
    
    //cXML += '<Column ss:Index="13" ss:Width="63" ss:Span="8"/>'+CRLF

	cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '11'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)

	// SOMA
	cXML += U_prtCellXML( 'Row' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'2'/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', "=SUBTOTAL(9,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'7'/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', "=SUBTOTAL(9,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	
	
	cXML += U_prtCellXML( '</Row>' )

	// Titulo
	cXML += U_prtCellXML( 'Row',,'33' )
	/*01*/ cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data Emissão'		    ,,.T. )
	/*02*/ cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Quantidade' 			,,.T. )
	/*03*/ cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Descrição' 			,,.T. )
	/*04*/ cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Filial'               ,,.T. )
	/*05*/ cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Cliente' 			    ,,.T. )
	/*06*/ cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Numero NF' 			,,.T. )
	/*07*/ cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Valor' 			    ,,.T. )
	/*08*/ cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Operação'		        ,,.T. )
	/*09*/ cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Lote' 	            ,,.T. )
	/*10*/ cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'NF de Origem V@' 		,,.T. )
	/*11*/ cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'NF Better' 			,,.T. )
	/*12*/ cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data NF Better' 		,,.T. )
	cXML += U_prtCellXML( '</Row>' )

	//fQuadro1
	While !(_cAliasG)->(Eof())

		cXML += U_prtCellXML( 'Row' )
	/*01*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData', 'DateTime', /*cFormula*/, U_FrmtVlrExcel( SToD( (_cAliasG)->D2_EMISSAO ) ) ,,.T. ) // DATA
    /*02*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->QTDE )               ,,.T. ) // LOTE
	/*03*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->B1_DESC )             ,,.T. ) // CURRAL
	/*04*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->D2_FILIAL)            ,,.T. ) // PVI
	/*05*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->A1_NOME )             ,,.T. ) // NRO CABEï¿½AS
	/*06*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->D2_DOC )              ,,.T. )
	/*07*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->VALOR )              ,,.T. )
	/*08*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->F4_TEXTO )            ,,.T. )
	/*09*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->D2_LOTECTL)           ,,.T. )
	/*10*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->D2_NFORI )            ,,.T. )
	/*11*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->F2_X_NFENT)           ,,.T. )
	iF !Empty((_cAliasG)->F2_X_DTENT)
        /*12*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData', 'DateTime', /*cFormula*/, U_FrmtVlrExcel( SToD( (_cAliasG)->F2_X_DTENT ))  ,,.T. )
    Else
        /*12*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, ""           ,,.T. )
    EndIf
       cXML += U_prtCellXML( '</Row>' )
		
		(_cAliasG)->(DbSkip())
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""

	EndDo

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
    cXML += ' <AutoFilter x:Range="R3C1:R'+cValToChar(nRegistros+1)+'C12"'+CRLF
    cXML += '  xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
    cXML += ' </AutoFilter>'+CRLF
    cXML += '</Worksheet>'+CRLF
 
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""
	
EndIf	

Return nil
// FIM: fQuadro1 - U_PCPREL02()
