#include 'FILEIO.CH'
#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 05.07.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatorio de Resumo de Carregamento.							       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL01()                                                         |
 '---------------------------------------------------------------------------------*/
User Function PCPREL01()
Local cTimeIni	 	:= Time()
Local cStyle		:= ""
Local cXML	   		:= ""
Local lTemDados		:= .T.

Private cPerg		:= SubS(ProcName(),3) // "PCPREL01"
Private cTitulo  	:= "Relatorio de Resumo de Carregamento"

Private cPath 	 	:= "C:\TOTVS_RELATORIOS\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()   
Private _cAliasT	:= GetNextAlias()   

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
		FWMsgRun(, {|| lTemDados := fLoadSql("Geral", @_cAliasG ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Carregamento')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Carregamento')
			
			// Planilha 2
			FWMsgRun(, {|| lTemDados := fLoadSql("Trato", @_cAliasT ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Carregamento')
			If lTemDados
				FWMsgRun(, {|| fQuadro2() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Trato')
			EndIf
			(_cAliasT)->(DbCloseArea())
			
			If MV_PAR11==2
				U_CellSX1Excel(cPerg)
			EndIf
			
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
// FIM: PCPREL01()



/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 05.07.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                        				       		   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL01()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local aRegs		:= {}
Local j         := 0
Local i         := 0

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
aAdd(aRegs,{cPerg, "03", "Receita De?"     , "", "", "MV_CH3", "C", TamSX3("Z0Y_RECEIT")[1], TamSX3("Z0Y_RECEIT")[2], 0, "G", ""		   , "MV_PAR03", ""   , "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "04", "Receita Ate?"    , "", "", "MV_CH4", "C", TamSX3("Z0Y_RECEIT")[1], TamSX3("Z0Y_RECEIT")[2], 0, "G", "NaoVazio", "MV_PAR04", ""   , "","",Replicate("Z", TamSX3("Z0Y_RECEIT")[1]),"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "05", "Rota De?"        , "", "", "MV_CH5", "C", TamSX3("Z0Y_ROTA")[1]  , TamSX3("Z0Y_ROTA")[2]  , 0, "G", ""		   , "MV_PAR05", ""   , "","",""      								 ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "06", "Rota Ate?"       , "", "", "MV_CH6", "C", TamSX3("Z0Y_ROTA")[1]  , TamSX3("Z0Y_ROTA")[2]  , 0, "G", "NaoVazio", "MV_PAR06", ""   , "","",Replicate("Z", TamSX3("Z0Y_ROTA")[1])  ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "07", "Trato De?"       , "", "", "MV_CH7", "C", TamSX3("Z0Y_TRATO")[1] , TamSX3("Z0Y_TRATO")[2] , 0, "G", ""		   , "MV_PAR07", ""   , "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "08", "Trato Ate?"      , "", "", "MV_CH8", "C", TamSX3("Z0Y_TRATO")[1] , TamSX3("Z0Y_TRATO")[2] , 0, "G", "NaoVazio", "MV_PAR08", ""   , "","",Replicate("Z", TamSX3("Z0Y_TRATO")[1]) ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "09", "Componente De?"  , "", "", "MV_CH9", "C", TamSX3("Z0Y_COMP")[1]  , TamSX3("Z0Y_COMP")[2]  , 0, "G", ""		   , "MV_PAR09", ""   , "","",""      								 ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "10", "Componente Ate?" , "", "", "MV_CHA", "C", TamSX3("Z0Y_COMP")[1]  , TamSX3("Z0Y_COMP")[2]  , 0, "G", "NaoVazio", "MV_PAR10", ""   , "","",Replicate("Z", TamSX3("Z0Y_COMP")[1])  ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
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


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 05.07.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                        				       		   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL01()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function fLoadSql(cTipo, _cAlias)
Local _cQry 		:= ""

If cTipo == "Geral"

	_cQry := " SELECT  Z0X_OPERAC, Z0X_DATA" + CRLF
	_cQry += " 	, Z0Y_RECEIT" + CRLF
	_cQry += " 	, SB1r.B1_DESC RECEITA" + CRLF
	_cQry += " 	, Z0Y_ROTA" + CRLF
	_cQry += " 	, Z0Y_TRATO" + CRLF
	_cQry += " 	, Z0U_NOME MOTORISTA" + CRLF
	_cQry += " 	, ZV0_DESC EQUIPAMENTO" + CRLF
	_cQry += " 	, Z0Y_COMP" + CRLF
	_cQry += " 	, SB1c.B1_DESC COMPONENTE" + CRLF
	_cQry += " 	, Z0Y_QTDPRE" + CRLF
	_cQry += " 	, Z0Y_QTDREA" + CRLF
	_cQry += "  , Z0Y_KGRECA" + CRLF
	_cQry += "  , ZOY_KGINBA" + CRLF
	_cQry += "  , Z0Y_HORINI" + CRLF
	_cQry += "  , Z0Y_HORFIN" + CRLF
	_cQry += " 	, Z0Y_DIFPES" + CRLF
	_cQry += " 	, Z0Y_PESDIG" + CRLF
	_cQry += " 	, Z0Y_MOTCOR" + CRLF
	_cQry += " 	-- , Z0Y.*" + CRLF
	_cQry += " FROM 	 " + RetSQLName('Z0X') + " Z0X" + CRLF
	_cQry += " 		JOIN " + RetSQLName('Z0Y') + " Z0Y ON Z0X_FILIAL=Z0Y_FILIAL AND Z0X_CODIGO=Z0Y_CODEI AND Z0X_CODIGO = Z0Y_CODEI AND Z0X.D_E_L_E_T_=' ' AND Z0Y.D_E_L_E_T_=' '" + CRLF
	_cQry += " 		JOIN " + RetSQLName('SB1') + " SB1r ON SB1r.B1_FILIAL=' ' AND SB1r.B1_COD=Z0Y_RECEIT " + CRLF
	_cQry += " 								AND SB1r.B1_GRUPO IN ('02','03')" + CRLF
	_cQry += " 								AND SB1r.B1_X_TRATO='1' AND SB1r.D_E_L_E_T_=' '  -- DESCRICAO RECEITA" + CRLF
	_cQry += " LEFT JOIN Z0S010 Z0S ON Z0S_FILIAL=Z0X_FILIAL AND Z0S_DATA=Z0X_DATA AND Z0S_ROTA=Z0Y_ROTA AND Z0S_VERSAO=Z0X_VERSAO AND Z0S.D_E_L_E_T_=' '" + CRLF
	_cQry += " 				AND Z0S_FILIAL+Z0S_DATA+Z0S_ROTA+Z0S_VERSAO IN (" + CRLF
	_cQry += " 						SELECT		Z0S_FILIAL+Z0S_DATA+Z0S_ROTA+MAX(Z0S_VERSAO) " + CRLF
	_cQry += " 						FROM		Z0S010 " + CRLF
	_cQry += " 						WHERE		D_E_L_E_T_=' ' " + CRLF
	_cQry += " 						GROUP BY	Z0S_FILIAL, Z0S_DATA, Z0S_ROTA" + CRLF
	_cQry += " 				)" + CRLF
	_cQry += " LEFT JOIN Z0U010 Z0U ON Z0U_FILIAL=Z0S_FILIAL AND Z0U_CODIGO=Z0S_OPERAD AND Z0U.D_E_L_E_T_=' ' -- MOTORISTA" + CRLF
	_cQry += " LEFT JOIN ZV0010 ZV0 ON ZV0_FILIAL=' ' AND ZV0_CODIGO=Z0S_EQUIP AND ZV0.D_E_L_E_T_=' '  -- EQUIPAMENTO" + CRLF
	_cQry += " LEFT JOIN " + RetSQLName('SB1') + " SB1c ON SB1c.B1_FILIAL=' ' AND SB1c.B1_COD=Z0Y_COMP " + CRLF
	_cQry += " 							AND SB1c.B1_GRUPO IN ('02','03','99')" + CRLF
	_cQry += " 							AND SB1c.D_E_L_E_T_=' ' -- DESCRICAO COMPONENTE" + CRLF
	_cQry += " WHERE Z0X_DATA	BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'" + CRLF
	_cQry += " 	 AND Z0Y_RECEIT	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'" + CRLF
	_cQry += " 	 AND Z0Y_ROTA	BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'" + CRLF
	_cQry += " 	 AND Z0Y_TRATO	BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'" + CRLF
	_cQry += " 	 AND Z0Y_COMP	BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'" + CRLF
	_cQry += " ORDER BY Z0X_OPERAC, Z0Y_ROTA, Z0X_DATA, RECEITA, Z0Y_TRATO, MOTORISTA, EQUIPAMENTO" + CRLF

ElseIf cTipo == "Trato"

	_cQry := " SELECT Z0X_DATA, Z0W_ROTA, Z0W_RECEIT, B1_DESC, Z0W_LOTE, Z0W_CURRAL, Z05_CABECA," + CRLF
	_cQry += " 	   Z0W_TRATO, Z0W_QTDPRE, Z0W_QTDREA, Z0W_DIFPES,  Z0W_MOTCOR, Z0W_KGRECA, Z0W_KGFIM, Z0W_KGINIC, Z0W_HORFIN" + CRLF
	_cQry += " FROM " + RetSQLName('Z0W') + " OW" + CRLF
	_cQry += " JOIN " + RetSQLName('Z0X') + " OX ON Z0W_FILIAL=Z0X_FILIAL AND OW.Z0W_CODEI = OX.Z0X_CODIGO AND OX.Z0X_DATA = Z0W_DATA AND OX.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " JOIN " + RetSQLName('SB1') + " B1 ON B1_FILIAL=' ' AND B1.B1_COD = OW.Z0W_RECEIT " + CRLF
	_cQry += " 				 AND B1.B1_GRUPO IN ('02','03','99')" + CRLF
	_cQry += " 				 AND B1.B1_X_TRATO='1'" + CRLF
	_cQry += " 				 AND B1.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " JOIN " + RetSQLName('Z05') + " P  ON Z05_FILIAL=Z0W_FILIAL AND P.Z05_LOTE = Z0W_LOTE AND Z05_DATA = Z0X_DATA AND P.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " WHERE Z0X_DATA BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'" + CRLF
	_cQry += " 	 AND Z0W_RECEIT	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'" + CRLF
	_cQry += " 	 AND Z0W_ROTA	BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'" + CRLF
	_cQry += " 	 AND Z0W_TRATO	BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'" + CRLF				
	_cQry += " ORDER BY Z0W_ROTA, Z0W_CURRAL, Z0W_LOTE, Z0W_TRATO, Z0W_RECEIT" + CRLF

EndIf

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

Return !(_cAlias)->(Eof())
// FIM: fLoadSql()


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 05.07.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                        				       		   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL01()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function fQuadro1()

Local nRegistros	:= 0
Local cXML 			:= "", cPanes := ""
Local cWorkSheet 	:= "Carregamento"

Local lPrintTit		:= .F.
Local cTrato 		:= "", cRota := "", cRotaOld := ""
Local nQtComp		:= 0
Local cZ0X_OPERAC	:= ""

(_cAliasG)->(DbEval({|| nRegistros++ }))

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	//fQuadro1
	While !(_cAliasG)->(Eof())
		
		cRota := (_cAliasG)->Z0Y_ROTA
		
		if cZ0X_OPERAC<>(_cAliasG)->(Z0X_OPERAC)
			
			cZ0X_OPERAC := (_cAliasG)->(Z0X_OPERAC)
			If cZ0X_OPERAC == "1"
				cWorkSheet += " Trato"
			Else
				cWorkSheet := "Fabrica Ração"
			EndIf
			
			cXML := U_prtCellXML( 'Worksheet', cWorkSheet )
			cXML += U_prtCellXML( 'Table' )
			cXML += '<Column ss:Width="63"/>'+CRLF
			cXML += '<Column ss:Width="71.25"/>'+CRLF
			cXML += '<Column ss:Width="126"/>'+CRLF
			cXML += '<Column ss:Width="158.25"/>'+CRLF
			cXML += '<Column ss:Width="84" ss:Span="3"/>'+CRLF
			cXML += '<Column ss:Index="9" ss:Width="87" ss:Span="3"/>'+CRLF
			cXML += '<Column ss:Index="13" ss:Width="237.75"/>'+CRLF
			cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '33'/* cHeight */, /* cIndex */, '8'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)
		EndIf
		
		If lPrintTit := cTrato<>(_cAliasG)->Z0Y_TRATO
			// Titulo
			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Rota' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Trato' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Equipamento' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Motorista' )
			// cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Receita' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,'1'/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Descrição Receita' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Inicial' )
			cXML += U_prtCellXML( '</Row>' )
		
			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData', 'DateTime', /*cFormula*/, U_FrmtVlrExcel( sToD( (_cAliasG)->Z0X_DATA ) ) )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0Y_ROTA )         )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0Y_TRATO )        )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->EQUIPAMENTO )      )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->MOTORISTA )        )
			// cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0Y_RECEIT )       )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,'1'/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->RECEITA )          )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,'1'/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->ZOY_KGINBA )          )
			cXML += U_prtCellXML( '</Row>' )
		
			// Titulo
			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'3'/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Componente' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Descrição Componente' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtd. Prevista' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtd. Prev. Recalculada' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtd. Real' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença Peso' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Digitado' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Motivo Correção' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Hora Inicio' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Hora Fim' )
			cXML += U_prtCellXML( '</Row>' )
			
			cTrato := (_cAliasG)->Z0Y_TRATO
		EndIf
		
		nQtComp += 1
		cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'3'/*cIndex*/,/*cMergeAcross*/,'sTextoC' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0Y_COMP )         )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->COMPONENTE )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0Y_QTDPRE )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0Y_KGRECA )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0Y_QTDREA )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0Y_DIFPES )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0Y_PESDIG )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0Y_MOTCOR )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0Y_HORINI )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0Y_HORFIN )       )
		cXML += U_prtCellXML( '</Row>' )
		
		cRotaOld := AllTrim(cRota)
		(_cAliasG)->(DbSkip())
		
		If (_cAliasG)->(Eof()) .or. cTrato<>(_cAliasG)->Z0Y_TRATO // U_PCPREL01()
			
			// SOMA
			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTextoSC' , 'String', /*cFormula*/, U_FrmtVlrExcel( cRotaOld )         )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'4'/*cIndex*/,/*cMergeAcross*/,'sTextoN' , 'String', /*cFormula*/, 'TOTAL'       )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sSemDigN', 'Number', "=SUM(R[-"+cValToChar(nQtComp)+"]C:R[-1]C)" /*cFormula*/, )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUM(R[-"+cValToChar(nQtComp)+"]C:R[-1]C)" /*cFormula*/, )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUM(R[-"+cValToChar(nQtComp)+"]C:R[-1]C)" /*cFormula*/, )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUM(R[-"+cValToChar(nQtComp)+"]C:R[-1]C)" /*cFormula*/, )
			cXML += U_prtCellXML( '</Row>' )
			
			nQtComp := 0
			
			If !(_cAliasG)->(Eof())
				cXML += U_prtCellXML( 'pulalinha','1' )
			EndIf
		EndIf
		
		If (_cAliasG)->(Eof()) .or. cRota <> (_cAliasG)->Z0Y_ROTA
			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sTextoSC', 'String', /*cFormula*/, 'TOTAL ROTA' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'4'/*cIndex*/,/*cMergeAcross*/,'sTextoN', 'String', /*cFormula*/, 'TOTAL ' + cRotaOld )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUMIF(R3C1:R[-1]C1,&quot;"+cRotaOld+"&quot;,R3C:R[-1]C)"/*cFormula*/, )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUMIF(R3C1:R[-1]C1,&quot;"+cRotaOld+"&quot;,R3C:R[-1]C)"/*cFormula*/, )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUMIF(R3C1:R[-1]C1,&quot;"+cRotaOld+"&quot;,R3C:R[-1]C)"/*cFormula*/, )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUMIF(R3C1:R[-1]C1,&quot;"+cRotaOld+"&quot;,R3C:R[-1]C)"/*cFormula*/, )
			cXML += U_prtCellXML( '</Row>' )
			cXML += U_prtCellXML( 'pulalinha','2' )
			
			If !Empty(cRota)
				cXML += U_prtCellXML( 'Row' )
				cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'4'/*cIndex*/,/*cMergeAcross*/,'sTextoN' , 'String', /*cFormula*/, 'TOTAL GERAL' )
				cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUMIF(R3C1:R[-1]C1,&quot;TOTAL ROTA&quot;,R3C:R[-1]C)" /*cFormula*/, )
				cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUMIF(R3C1:R[-1]C1,&quot;TOTAL ROTA&quot;,R3C:R[-1]C)" /*cFormula*/, )
				cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUMIF(R3C1:R[-1]C1,&quot;TOTAL ROTA&quot;,R3C:R[-1]C)" /*cFormula*/, )
				cXML += U_prtCellXML( '</Row>' )
			EndIf
		EndIf
		
		if (_cAliasG)->(Eof()) .or. cZ0X_OPERAC<>(_cAliasG)->(Z0X_OPERAC)
			cPanes += '<Unsynced/>'+CRLF
			cPanes += '<Selected/>'+CRLF
			cPanes += '<FreezePanes/>'+CRLF
			cPanes += '<FrozenNoSplit/>'+CRLF
			cPanes += '<SplitHorizontal>2</SplitHorizontal>'+CRLF
			cPanes += '<TopRowBottomPane>2</TopRowBottomPane>'+CRLF
			cPanes += '<SplitVertical>7</SplitVertical>'+CRLF
			cPanes += '<LeftColumnRightPane>8</LeftColumnRightPane>'+CRLF

			cXML += U_prtCellXML( 'WorksheetOptions',,,,,,, cPanes )
			
		// If !Empty(cXML)
		// 	FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""	
	EndDo
	
EndIf	

Return nil
// FIM: fQuadro1 - U_PCPREL01()


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 08.07.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                        				       		   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL01()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function fQuadro2()

Local nRegistros	:= 0
Local cXML 			:= "", cPanes := ""
Local cWorkSheet 	:= "Trato"

Local lPrintTit		:= .F.
Local cCurral 		:= "", cRota := "", cRotaOld := ""
Local nQtTrato		:= 0

(_cAliasT)->(DbEval({|| nRegistros++ }))

(_cAliasT)->(DbGoTop()) 
If !(_cAliasT)->(Eof())

	cXML += U_prtCellXML( 'Worksheet', cWorkSheet )
	cXML += U_prtCellXML( 'Table' )
	cXML += '<Column ss:Width="51.75"/>'+CRLF
    cXML += '<Column ss:Width="42"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="66.75"/>'+CRLF
    cXML += '<Column ss:Width="34.5"/>'+CRLF
    cXML += '<Column ss:Width="49.5"/>'+CRLF
    cXML += '<Column ss:Width="39"/>'+CRLF
    cXML += '<Column ss:Width="78"/>'+CRLF
    cXML += '<Column ss:AutoFitWidth="0" ss:Width="83.25" ss:Span="2"/>'+CRLF
    cXML += '<Column ss:Index="11" ss:Width="81.75"/>'+CRLF
    cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '33'/* cHeight */, /* cIndex */, '10'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)

	//fQuadro2
	While !(_cAliasT)->(Eof())
	
		cRota := (_cAliasT)->Z0W_ROTA
		If lPrintTit := cCurral<>(_cAliasT)->Z0W_CURRAL
	
			// Titulo
			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Rota' )
			cXML += U_prtCellXML( '</Row>' )
			
			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData', 'DateTime', /*cFormula*/, U_FrmtVlrExcel( sToD( (_cAliasT)->Z0X_DATA ) ) )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_ROTA )         )
			cXML += U_prtCellXML( '</Row>' )
			
			cXML += U_prtCellXML( 'Row' )
			// cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Receita' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'2'/*cIndex*/,'1'/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Descrição da Receita' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Lote' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Curral' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Cabeça' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Trato' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtd Prevista' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtd Prev. Recalc.' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtd Real' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dif Peso' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Inic.' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Final' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Motivo Correção' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Horario do Trato' )
			cXML += U_prtCellXML( '</Row>' )
			
			cCurral := (_cAliasT)->Z0W_CURRAL
			
		EndIf
		
		nQtTrato += 1
		
		// dados
		cXML += U_prtCellXML( 'Row' )
		//cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_RECEIT )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'2'/*cIndex*/,'1'/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->B1_DESC )          )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_LOTE )         )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_CURRAL )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z05_CABECA )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_TRATO )        )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_QTDPRE )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_KGRECA )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_QTDREA )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_DIFPES )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_KGINIC )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_KGFIM )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_MOTCOR )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasT)->Z0W_HORFIN )       )
		cXML += U_prtCellXML( '</Row>' )
		
		cRotaOld := AllTrim(cRota)
		(_cAliasT)->(DbSkip())
		
		If (_cAliasT)->(Eof()) .or. cCurral<>(_cAliasT)->Z0W_CURRAL // U_PCPREL01()
			
			// SOMA
			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sTextoSC', 'String', /*cFormula*/, U_FrmtVlrExcel( cRotaOld )       )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'7'/*cIndex*/,/*cMergeAcross*/,'sTextoN' , 'String', /*cFormula*/, 'TOTAL' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUM(R[-"+cValToChar(nQtTrato)+"]C:R[-1]C)" /*cFormula*/, )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUM(R[-"+cValToChar(nQtTrato)+"]C:R[-1]C)" /*cFormula*/, )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUM(R[-"+cValToChar(nQtTrato)+"]C:R[-1]C)" /*cFormula*/, )
			cXML += U_prtCellXML( '</Row>' )
			
			nQtTrato := 0
			
			cXML += U_prtCellXML( 'pulalinha','1' )
		EndIf
		
		If (_cAliasT)->(Eof()) .or. cRota <> (_cAliasT)->Z0W_ROTA
			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sTextoSC', 'String', /*cFormula*/, 'TOTAL ROTA' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'7'/*cIndex*/,/*cMergeAcross*/,'sTextoN', 'String', /*cFormula*/, 'TOTAL ' + cRotaOld )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUMIF(R3C1:R[-1]C1,&quot;"+cRotaOld+"&quot;,R3C:R[-1]C)"/*cFormula*/, )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUMIF(R3C1:R[-1]C1,&quot;"+cRotaOld+"&quot;,R3C:R[-1]C)"/*cFormula*/, )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUMIF(R3C1:R[-1]C1,&quot;"+cRotaOld+"&quot;,R3C:R[-1]C)"/*cFormula*/, )
			cXML += U_prtCellXML( '</Row>' )
			cXML += U_prtCellXML( 'pulalinha','2' )
			
			If !Empty(cRota)
				cXML += U_prtCellXML( 'Row' )
				cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'7'/*cIndex*/,/*cMergeAcross*/,'sTextoN' , 'String', /*cFormula*/, 'TOTAL GERAL' )
				cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUMIF(R3C1:R[-1]C1,&quot;TOTAL ROTA&quot;,R3C:R[-1]C)" /*cFormula*/, )
				cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUMIF(R3C1:R[-1]C1,&quot;TOTAL ROTA&quot;,R3C:R[-1]C)" /*cFormula*/, )
				cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,   /*cIndex*/,/*cMergeAcross*/,'sComDigN', 'Number', "=SUMIF(R3C1:R[-1]C1,&quot;TOTAL ROTA&quot;,R3C:R[-1]C)" /*cFormula*/, )
				cXML += U_prtCellXML( '</Row>' )
			EndIf
		
		EndIf
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""	
	EndDo

    cPanes += '<Unsynced/>'+CRLF
    cPanes += '<Selected/>'+CRLF
    cPanes += '<FreezePanes/>'+CRLF
    cPanes += '<FrozenNoSplit/>'+CRLF
    cPanes += '<SplitHorizontal>2</SplitHorizontal>'+CRLF
    cPanes += '<TopRowBottomPane>2</TopRowBottomPane>'+CRLF
    cPanes += '<SplitVertical>7</SplitVertical>'+CRLF
    cPanes += '<LeftColumnRightPane>8</LeftColumnRightPane>'+CRLF
    /* 
	cPanes += '<ActivePane>0</ActivePane>'+CRLF
    cPanes += '<Panes>'+CRLF
    cPanes += ' <Pane>'+CRLF
    cPanes += '  <Number>3</Number>'+CRLF
    cPanes += ' </Pane>'+CRLF
    cPanes += ' <Pane>'+CRLF
    cPanes += '  <Number>1</Number>'+CRLF
    cPanes += '  <ActiveCol>7</ActiveCol>'+CRLF
    cPanes += ' </Pane>'+CRLF
    cPanes += ' <Pane>'+CRLF
    cPanes += '  <Number>2</Number>'+CRLF
    cPanes += ' </Pane>'+CRLF
    cPanes += ' <Pane>'+CRLF
    cPanes += '  <Number>0</Number>'+CRLF
    cPanes += ' </Pane>'+CRLF
    cPanes += '</Panes>'+CRLF
	*/
	cXML += U_prtCellXML( 'WorksheetOptions',,,,,,, cPanes )
	
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
	
EndIf	

Return nil
// FIM: fQuadro2 - U_PCPREL01()




/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 25.07.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                        				       		   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL01()                                                         |
 '---------------------------------------------------------------------------------*/
User Function CellSX1Excel(cPerg)

Local cXML 			:= ""
Local cWorkSheet 	:= "Parametros"

DbSelectArea('SX1')
DbSetOrder(1)
SX1->(DbGoTop())
If SX1->(DbSeek(cPerg))

	cXML := U_prtCellXML( 'Worksheet', cWorkSheet )
	cXML += U_prtCellXML( 'Table' )
	cXML += '<Column ss:Width="105"/>'+CRLF
    cXML += '<Column ss:Width="198"/>'+CRLF
	cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '33'/* cHeight */, /* cIndex */, /* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)
	cXML += U_prtCellXML( 'pulalinha','1' )
	
	cXML += U_prtCellXML( 'Row' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Parametro' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Informação' )
	cXML += U_prtCellXML( '</Row>' )

	While !SX1->(Eof()) .And. X1_GRUPO = cPerg 
		
		cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, U_FrmtVlrExcel( AllTrim(SX1->X1_PERGUNT) )       )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, U_FrmtVlrExcel( cValToChar( &(SX1->X1_VAR01) ) ) )
		cXML += U_prtCellXML( '</Row>' )
		
		SX1->(DbSkip())
	EndDo
	
	cXML += U_prtCellXML( 'WorksheetOptions',,,,,,, /* cPanes */ )
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
EndIf

Return nil
