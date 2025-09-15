#INCLUDE "FILEIO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 10.07.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatorio de Resumo de Carregamento.							       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_PCPREL02()                                                         |
 '---------------------------------------------------------------------------------*/
User Function PCPREL02()
Local cTimeIni	 	:= Time()
Local cStyle		:= ""
Local cXML	   		:= ""
Local lTemDados		:= .T.

Private cPerg		:= SubS(ProcName(),3) // "PCPREL02"
Private cTitulo  	:= "Relatorio de Alimentação Diaria do Lote"

Private cPath 	 	:= "C:\TOTVS_RELATORIOS\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()   
Private _cAliasS	:= GetNextAlias()   
Private _cAliasA    := GetNextAlias()
Private _cAliasF    := GetNextAlias()
//Private _cAliasE    := GetNextAlias()

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
		//Alteração Toshio - 28-12

		// Processar SQL
		FWMsgRun(, {|| lTemDados := fLoadSql("Geral", @_cAliasG ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Alimentação Diaria')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geraçãoo do quadro de Carregamento')
			
			
			If !Empty(MV_PAR03) // imprime demais quadros apenas quando escolher lote
				If MV_PAR03 == MV_PAR04 
					FWMsgRun(, {||  fLoadSql("Saldo", @_cAliasS )}, 'Por Favor Aguarde...' , 'Processando Banco de Dados - Saldo Atual' )

					FWMsgRun(, {||  fLoadSql("Apartacao", @_cAliasA ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Apartacao')

					FWMsgRun(, {|| fLoadSql("Faturamento", @_cAliasF ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Faturamento')

					If lTemDados
						// Gerar segunda planilha
						FWMsgRun(, {|| fQuadro2() },'Gerando excel, Por Favor Aguarde...', 'Geraçãoo do quadro Saldo Atual')
					EndIf
					(_cAliasS)->(DbCloseArea())
					(_cAliasA)->(DbCloseArea())
					(_cAliasF)->(DbCloseArea())
					
					/*FWMsgRun(, {|| lTemDados := fLoadSql("Embarque", @_cAliasE ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Embarque')

					If lTemDados
						// Gerar segunda planilha
						FWMsgRun(, {|| fQuadro3() },'Gerando excel, Por Favor Aguarde...', 'Embarque')
					EndIf	 	
					(_cAliasE)->(DbCloseArea())
					*/
				EndIF
			EndIf
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
				MsgAlert("O Excel Não foi encontrado. Arquivo " + cArquivo + " gerado em " + cPath + ".", "MsExcel Não encontrado" )
			EndIf
		Else		
			MsgAlert("Os parametros informados Não retornou nenhuma informação do banco de dados." + CRLF + ;
					"Por isso o excel Não sera aberto automaticamente.", "Dados Não localizados")
		EndIf
		// alteração Toshio - 28/12
		
		(_cAliasG)->(DbCloseArea())
		
		If lower(cUserName) $ 'mbernardo,atoshio,admin, administrador'
			Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
		EndIf
		
		ConOut('Activate: ' + Time())
	EndIf
EndIf

Return nil
// FIM: PCPREL02()



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

aAdd(aRegs,{cPerg, "02", "Data Ate?"  ,  "", "", "MV_CH2", "D", TamSX3("Z05_DATA")[1]  , TamSX3("Z05_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR02", ""   , "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "01", "Data De?"   ,  "", "", "MV_CH1", "D", TamSX3("Z05_DATA")[1]  , TamSX3("Z05_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR01", ""   , "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "03", "Lote De?"   ,  "", "", "MV_CH3", "C", TamSX3("Z05_LOTE")[1]  , TamSX3("Z05_LOTE")[2]  , 0, "G", ""		   , "MV_PAR03", ""   , "","",""      								 ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "04", "Lote Ate?"  ,  "", "", "MV_CH4", "C", TamSX3("Z05_LOTE")[1]  , TamSX3("Z05_LOTE")[2]  , 0, "G", "NaoVazio",    "MV_PAR04", ""   , "","",Replicate("Z", TamSX3("Z05_LOTE")[1])  ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
//aAdd(aRegs,{cPerg, "05", "Curral De?" ,  "", "", "MV_CH5", "C", TamSX3("Z05_CURRAL")[1], TamSX3("Z05_CURRAL")[2], 0, "G", ""		   , "MV_PAR05", ""   , "","",""      								 ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
//aAdd(aRegs,{cPerg, "06", "Curral Ate?",  "", "", "MV_CH6", "C", TamSX3("Z05_CURRAL")[1], TamSX3("Z05_CURRAL")[2], 0, "G", "NaoVazio",    "MV_PAR06", ""   , "","",Replicate("Z", TamSX3("Z05_CURRAL")[1]),"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "07", "Exibe Custo?", "", "", "MV_CH7", "N",                       1,                       0, 2, "C", "NaoVazio",    "MV_PAR07", "Não", "","",""	  	,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "08", "Considera CMS por ?", "", "", "MV_CH8", "N",                       1,                       0, 2, "C", "NaoVazio",    "MV_PAR08", "Carregamento", "","",""	  	,"","Descarregamento","","","","","","","","","","","","","","","","","","","","U","","","",""})

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
Local cTp           := ""

If cTipo == "Geral" 
		_cQry :=    "with PRODU AS (" + CRLF +;
						"select Z0Y.Z0Y_ORDEM, Z0Y.Z0Y_DATA, Z0Y.Z0Y_TRATO, Z0Y.Z0Y_RECEIT, case when Z0Y_PESDIG > 0 THEN Z0Y_PESDIG ELSE Z0Y_QTDREA  END AS PRD_QTD_REA, Z0Y_QTDPRE PRD_QTD_PRV" + CRLF +;
							"from " + RetSqlName("Z0Y") + " Z0Y" + CRLF +;
							"where Z0Y.Z0Y_FILIAL = '" + FWxFilial("Z0Y") + "'" + CRLF +;
							"and Z0Y.Z0Y_DATINI <> '        ' -- Descarta as linhas que nÃ£o foram efetivadas" + CRLF +;
							"and Z0Y.D_E_L_E_T_ = ' '" + CRLF +;
						") ," + CRLF
		_cQry += 	"QTDPROD as (" + CRLF +;
						"select PRD.Z0Y_ORDEM, PRD.Z0Y_RECEIT, PRD.Z0Y_TRATO, sum(PRD.PRD_QTD_REA) PRD_QTD_REA, sum(PRD.PRD_QTD_PRV) PRD_QTD_PRV" + CRLF +;
							"from PRODU PRD" + CRLF +;
						"group by PRD.Z0Y_ORDEM, PRD.Z0Y_TRATO, PRD.Z0Y_RECEIT" + CRLF +;
						") ," + CRLF
		_cQry += 	"TRATO AS (" + CRLF +;
						"select Z0W.Z0W_ORDEM, Z0W.Z0W_DATA, Z0W.Z0W_LOTE, Z0W_CURRAL, Z0W.Z0W_TRATO, Z0W.Z0W_RECEIT, CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END  TRT_QTD_REA, Z0W.Z0W_QTDPRE TRT_QTD_PRV" + CRLF +;
							"from " + RetSqlName("Z0W") + " Z0W" + CRLF +;
							"where Z0W.Z0W_FILIAL = '" + FWxFilial("Z0W") + "'" + CRLF +; //"and Z0W.Z0W_QTDPRE <> '        '" + CRLF +;//Z0W_DATINI <> '        '
							"and Z0W.D_E_L_E_T_ = ' '" + CRLF +;
						") ," + CRLF
		_cQry += 	"TRATOLOTE as (" + CRLF +;
						"select Z0W_DATA, Z0W_LOTE, Z0W_CURRAL, SUM(TRT_QTD_REA) TRT_QTD_REA,  SUM(TRT_QTD_PRV) TRT_QTD_PRV" + CRLF +;
							"from TRATO " + CRLF +;
						"group by Z0W_DATA, Z0W_LOTE, Z0W_CURRAL" + CRLF +;
						") ," + CRLF
		_cQry += 	"QTDTRATO as (" + CRLF +;
						"select Z0W.Z0W_ORDEM, Z0W.Z0W_TRATO, sum(Z0W.TRT_QTD_REA) TRT_QTD_REA, sum(Z0W.TRT_QTD_PRV) TRT_QTD_PRV" + CRLF +;
							"from TRATO Z0W" + CRLF +;
						"group by Z0W.Z0W_ORDEM, Z0W.Z0W_TRATO     " + CRLF +;
						") ," + CRLF
		_cQry += 	"RECEITA as (" + CRLF +;
						"select Z0Y_ORDEM, Z0Y_TRATO, Z0Y.Z0Y_RECEIT, Z0Y_COMP, CASE WHEN Z0Y_PESDIG > 0 THEN Z0Y_PESDIG ELSE  Z0Y_QTDREA END AS Z0Y_QTDREA, Z0Y_QTDPRE" + CRLF +;
							"from " + RetSqlName("Z0Y") + " Z0Y" + CRLF +;
						"where Z0Y.Z0Y_FILIAL = '" + FWxFilial("Z0Y") + "'" + CRLF +; //"and Z0Y.Z0Y_QTDPRE <> '        ' " + CRLF +; //Z0Y_DATINI <> '        '
							"and Z0Y.D_E_L_E_T_ =  ' '" + CRLF +;
						") ," + CRLF
		_cQry += 	"REALIZADO as (" + CRLF +;
						"select Z0W.Z0W_FILIAL" + CRLF +;
							", Z0W.Z0W_ORDEM -- OP" + CRLF +;
							", Z0W.Z0W_DATA -- Data do trato" + CRLF +;
							", Z0W.Z0W_VERSAO -- versÃ£o do trato" + CRLF +;
							", Z0W.Z0W_ROTA -- Rota a que o curral pertence" + CRLF +;
							", Z0W.Z0W_CURRAL -- Curral" + CRLF +;
							", Z0W.Z0W_LOTE -- Lote" + CRLF +;
							", Z0W.Z0W_TRATO -- Numero do trato" + CRLF +;
							", Z0W.Z0W_RECEIT " + CRLF +;
							", REC.Z0Y_COMP -- Componente da receita do trato" + CRLF +;
							", Z0W.Z0W_QTDPRE" + CRLF +;
							", Z0W.Z0W_QTDREA -- Quantidade distribuida no cocho para a baia" + CRLF +;
							", Z05.Z05_CABECA -- Numero de cabeÃ§as da baia no momento do trato" + CRLF +;
							", PRD.PRD_QTD_PRV -- Qunatidade total produzida prevista" + CRLF +;
							", PRD.PRD_QTD_REA -- Quantidade total produzida aferida na balanÃ§a" + CRLF +;
							", TRT.TRT_QTD_PRV -- Quantidade total distribuida prevista" + CRLF +;
							", TRT.TRT_QTD_REA -- Quantidade total distribuida aferida na balanÃ§a" + CRLF +;
							", REC.Z0Y_QTDREA -- Quantidade do componente usado na fabricaÃ§Ã£o da dieta" + CRLF +;
							", Z0V.Z0V_INDMS -- Indice de materia seca no dia/versao do trato" + CRLF +;
							", Z0W_QTDREA/TRT_QTD_REA*PRD_QTD_REA QTD_MN -- Quantidade total de materia natural distribuida no cocho" + CRLF +;
							", ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*PRD_QTD_REA)/(TRT_QTD_REA*Z05_CABECA) QTD_MN_CABECA -- Quantidade total de materia natural distribuida no cocho por cabeÃ§a" + CRLF +;
							", ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*Z0Y_QTDREA)/TRT_QTD_REA QTD_MN_COMPONENTE -- quantidade de materia natural do componente" + CRLF +;
							", ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*Z0Y_QTDREA)/(TRT_QTD_REA*Z05_CABECA) QTD_MN_COMPONENTE_CABECA -- quantidade de materia natural do componente por cabeÃ§a" + CRLF +;
							", ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*Z0Y_QTDREA*Z0V_INDMS)/(100*TRT_QTD_REA) QTD_MS_COMPONENTE -- quantidade calculada de materia seca do componente de acordo com o indice de materia seca utilizado no trato" + CRLF +;
							", ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*Z0Y_QTDREA*Z0V_INDMS)/(100*TRT_QTD_REA*Z05_CABECA) QTD_MS_COMP_CABECA -- quantidade calculada de materia seca do componente por cabeÃ§a de acordo com o indice de materia seca utilizado no trato" + CRLF +;
						"from " + RetSqlName("Z0W") + " Z0W" + CRLF +;
						"join QTDPROD PRD" + CRLF +;
							"on PRD.Z0Y_ORDEM = Z0W.Z0W_ORDEM" + CRLF +;
						"and PRD.Z0Y_TRATO = Z0W.Z0W_TRATO" + CRLF +;
						"join QTDTRATO TRT" + CRLF +;
							"on TRT.Z0W_ORDEM = Z0W.Z0W_ORDEM" + CRLF +;
						"and TRT.Z0W_TRATO = Z0W.Z0W_TRATO" + CRLF +;
						"join RECEITA REC" + CRLF +;
							"on REC.Z0Y_ORDEM = Z0W.Z0W_ORDEM" + CRLF +;
						"and REC.Z0Y_TRATO = Z0W.Z0W_TRATO" + CRLF +;
						"join " + RetSqlName("Z05") + " Z05" + CRLF +;
							"on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" + CRLF +;
						"and Z05.Z05_DATA   = Z0W.Z0W_DATA" + CRLF +;
						"and Z05.Z05_LOTE   = Z0W.Z0W_LOTE" + CRLF +;
						"and Z05.D_E_L_E_T_ = ' '" + CRLF +;
						"join " + RetSqlName("Z0V") + " Z0V" + CRLF +;
							"on Z0V.Z0V_FILIAL = '" + FWxFilial("Z0V") + "'" + CRLF +;
						"and Z0V.Z0V_DATA   = Z0W.Z0W_DATA" + CRLF +;
						"and Z0V.Z0V_COMP   = REC.Z0Y_COMP" + CRLF +;
						"and Z0V.D_E_L_E_T_ = ' '" + CRLF +;
						"where Z0W.Z0W_FILIAL = '" + FWxFilial("Z0W") + "' " + CRLF +;
						"and Z0W.Z0W_DATINI <> '        '" + CRLF +;
						"and Z0W.D_E_L_E_T_ = ' '" + CRLF +;
						")" + CRLF 
		_cQry +=	", PRINCIPAL as (" + CRLF +;
						"select Z05.Z05_FILIAL" + CRLF +;
						", (Select TOP 1 B1_X_SEXO  " + CRLF +;
						" 	from " + RetSqlName("SB8") + " SB8 " + CRLF +;
						" 	JOIN " + RetSqlName("SB1") + " SB1 ON (B1_COD = B8_PRODUTO AND SB1.D_E_L_E_T_ = ' ') " + CRLF +;
						" 	WHERE B8_FILIAL = '" + FWxFilial("SB8") + "'  " + CRLF +;
						" 	AND B8_LOTECTL = Z06.Z06_LOTE " + CRLF +;
						" 	AND SB8.D_E_L_E_T_ = ' ' " + CRLF +;
						" 	GROUP BY B1_X_SEXO " + CRLF +;
						"   ORDER BY sum(B8_SALDO) DESC ) AS B1_X_SEXO" + CRLF +;
						", ( Select TOP 1 B1_XRACA " + CRLF +;
						" 	from " + RetSqlName("SB8") + " SB8 " + CRLF +;
						" 	JOIN " + RetSqlName("SB1") + " SB1 ON (B1_COD = B8_PRODUTO AND SB1.D_E_L_E_T_ = ' ') " + CRLF +;
						" 	WHERE B8_FILIAL = '" + FWxFilial("SB8") + "'  " + CRLF +;
						" 	AND B8_LOTECTL = Z06.Z06_LOTE " + CRLF +;
						" 	AND SB8.D_E_L_E_T_ = ' ' " + CRLF +;
						" 	GROUP BY B1_XRACA " + CRLF +;
						"   ORDER BY sum(B8_SALDO) DESC ) AS B1_XRACA" + CRLF +;
						", Z05.Z05_DATA" + CRLF +;
						", Z05.Z05_CURRAL" + CRLF +;
						", Z06.Z06_LOTE" + CRLF +;
						", Z05.Z05_PESOCO" + CRLF +;
						", Z05.Z05_CABECA" + CRLF +;
						", Z0O.Z0O_CODPLA" + CRLF +;
						", Z0O.Z0O_GMD" + CRLF +;
						", Z05.Z05_DIASDI" + CRLF +;
						", Z05.Z05_DIETA" + CRLF +;
						", Z05.Z05_NROTRA" + CRLF +;
						", isnull(Z0WT.TRT_QTD_PRV,0) PREVISTO" + CRLF +;
						", isnull(Z0WT.TRT_QTD_REA,0) REALIZADO" + CRLF +;
						", Z05.Z05_KGMSDI" + CRLF +;
						", case when Z05.Z05_KGMSDI > 0 then Z05.Z05_KGMSDI / Z05.Z05_KGMNDI * 100 else 0 end PERC_MS" + CRLF +;
						", isnull(Z05_KGMNDI,0) CMN_PREVISTO" + CRLF +;
						", SUM(QTD_MN_COMPONENTE_CABECA) CMN_REALIZADO --, sum(isnull(Z0W.QTD_MN_CABECA,0)) / Z05.Z05_CABECA CMN_REALIZADO" + CRLF +;
						", SUM(QTD_MS_COMP_CABECA) CMS_REALIZADO--, sum(isnull(Z0W.QTD_MN_CABECA,0)) / Z05.Z05_CABECA CMN_REALIZADO" + CRLF +;
						", Z05_MEGCAL MEGACAL " + CRLF +;
						"from " + RetSqlName("Z05") + " Z05" + CRLF +;
						"join " + RetSqlName("Z06") + " Z06" + CRLF +;
						"on Z06_FILIAL     = '" + FWxFilial("Z06") + "'" + CRLF +;
						"and Z06.Z06_DATA   = Z05.Z05_DATA" + CRLF +;
						"and Z06.Z06_VERSAO = Z05.Z05_VERSAO" + CRLF +;
						"and Z06.Z06_CURRAL = Z05.Z05_CURRAL" + CRLF +;
						"and Z06.Z06_LOTE   = Z05.Z05_LOTE" + CRLF +;
						"and Z06.D_E_L_E_T_ = ' '" + CRLF +;
						"join " + RetSqlName("SB1") + " SB1" + CRLF +;
						"on SB1.B1_FILIAL  = '  '" + CRLF +;
						"and SB1.B1_COD     = Z06.Z06_DIETA" + CRLF +;
						"and SB1.D_E_L_E_T_ = ' '" + CRLF +;
						"left join REALIZADO Z0W" + CRLF +;
						"on Z0W.Z0W_FILIAL = '" + FWxFilial("Z0W") + "'" + CRLF +;
						"and Z0W.Z0W_DATA   = Z06.Z06_DATA" + CRLF +;
						"and Z0W.Z0W_LOTE   = Z06.Z06_LOTE" + CRLF +;
						"AND Z0W.Z0W_CURRAL = Z06.Z06_CURRAL" + CRLF +;
						"and Z0W.Z0W_TRATO  = Z06.Z06_TRATO" + CRLF +;
						"and Z0W.Z0W_RECEIT = Z06.Z06_DIETA" + CRLF +;
						"left join " + RetSqlName("Z0O") + " Z0O" + CRLF +;
						"on Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" + CRLF +;
						"and Z0O.Z0O_LOTE   = Z05_LOTE" + CRLF +;
						"and Z05.Z05_DATA   between Z0O_DATAIN and case when Z0O_DATATR = '        ' then convert(varchar, getdate(), 112) else Z0O_DATATR end" + CRLF +;
						"and Z0O.D_E_L_E_T_ = ' '" + CRLF +;
						"left join TRATOLOTE Z0WT ON " + CRLF +;
						"Z0WT.Z0W_DATA = Z05_DATA" + CRLF +;
						"AND Z0WT.Z0W_LOTE  = Z05_LOTE" + CRLF +;
						"AND Z0WT.Z0W_CURRAL = Z05_CURRAL" + CRLF +;
						"where Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" + CRLF +;
						"and Z05.Z05_DATA   BETWEEN '" + DToS(MV_PAR01) + "' and '" + DToS(MV_PAR02) + "'" + CRLF +;
						"and Z05.Z05_LOTE   BETWEEN '" + MV_PAR03 + "' and '" + MV_PAR04 + "'" + CRLF +;
						"and Z05.D_E_L_E_T_ = ' '" + CRLF +;
						"group by Z05_FILIAL" + CRLF +;
						", Z05_DATA" + CRLF +;
						", Z05_LOTE" + CRLF +;
						", Z05_CURRAL" + CRLF +;
						", Z06_LOTE" + CRLF +;
						",	Z05_KGMNDI" + CRLF +;
						", Z05_PESOCO" + CRLF +;
						", Z0WT.TRT_QTD_PRV " + CRLF +;
						", Z0WT.TRT_QTD_REA" + CRLF +;
						", Z05_MEGCAL" + CRLF +;
						", Z0O_CODPLA" + CRLF +;
						", Z0O_GMD" + CRLF +;
						", Z05_DIASDI" + CRLF +;
						", Z05.Z05_CABECA" + CRLF +;
						", Z05.Z05_DIETA" + CRLF +;
						", Z05.Z05_NROTRA" + CRLF +;
						", Z05.Z05_KGMSDI" + CRLF +;
						", Z05.Z05_KGMNDI" + CRLF +;
						")" + CRLF 
		If MV_PAR07 == 2
			_cQry +=	", ESTOQUE AS ( " + CRLF +;
						"SELECT  D31.D3_FILIAL" + CRLF +;
						", D3.D3_LOTECTL" + CRLF +;
						", D3.D3_QUANT	QUANT_ANIMAIS" + CRLF +;
						", D31.D3_COD" + CRLF +;
						", B1.B1_DESC" + CRLF +;
						", D31.D3_EMISSAO" + CRLF +;
						", D31.D3_QUANT"  + CRLF +;
						",(D31.D3_CUSTO1/D31.D3_QUANT) CUSTO_UNIT" + CRLF +;
						",D31.D3_CUSTO1	CUSTO" + CRLF +;
						",(SUM(D3C.D3_CUSTO1)/SUM(D3C.D3_QUANT)) AS  MEDIO_PROD" + CRLF +;
						",((SUM(D3C.D3_CUSTO1)/SUM(D3C.D3_QUANT))*D31.D3_QUANT) AS     TOTAL_P_PR" + CRLF +;
						",((SUM(D3C.D3_CUSTO1)/SUM(D3C.D3_QUANT))*D31.D3_QUANT) /D3.D3_QUANT CUSTO_ANIM" + CRLF +;
						"FROM " + RetSqlName("SD3") + " D3" + CRLF +;
						"INNER JOIN " + RetSqlName("SD3") + " D31 ON" + CRLF +;
						"D31.D3_OP				=				D3.D3_OP" + CRLF +;
						"AND D31.D_E_L_E_T_			=				' '" + CRLF +;
						"AND D31.D3_GRUPO				=				'03'" + CRLF +;
						"INNER JOIN " + RetSqlName("SD3") + " D3C ON" + CRLF +;
						"D3C.D3_FILIAL			=				D31.D3_FILIAL" + CRLF +;
						"AND D3C.D3_COD				=				D31.D3_COD" + CRLF +;
						"AND D3C.D3_TM				=				'001'" + CRLF +;
						"AND D3C.D3_EMISSAO			=				D3.D3_EMISSAO" + CRLF +;
							"INNER JOIN " + RetSqlName("SB1") + " B11 ON" + CRLF +;
						"B11.B1_COD				=				D3.D3_COD" + CRLF +;
						"AND B11.D_E_L_E_T_			=				' '" + CRLF +;
							"INNER JOIN " + RetSqlName("SB1") + " B1 ON" + CRLF +;
						"D31.D3_COD				=				B1.B1_COD" + CRLF +;
						"WHERE D3.D3_FILIAL		    = '" + FWxFilial("SD3") + "' "+ CRLF +;
						"AND D3.D3_LOTECTL	BETWEEN '" + MV_PAR03 + "' and '" + MV_PAR04 + "'" + CRLF +;  
						"AND D3.D3_EMISSAO	BETWEEN	'" + DToS(MV_PAR01) + "' and '" + DToS(MV_PAR02) + "'" + CRLF +;    
						"AND D3.D3_CF					=				'PR0'" + CRLF +;
						"AND D3.D3_ESTORNO			<>				'S'" + CRLF +;
						"AND D3.D_E_L_E_T_			=				' '" + CRLF +;
						"AND D3.D3_LOTECTL			<>				' '" + CRLF +;
						"GROUP BY D31.D3_FILIAL, D3.D3_COD, B11.B1_DESC, D3.D3_LOTECTL, D3.D3_QUANT, D3.D3_TM, D31.D3_COD, B1.B1_DESC, D31.D3_EMISSAO, D31.D3_QUANT,D31.D3_CUSTO1	" + CRLF +;
						")" + CRLF
		EndIf
			_cQry += " select PRP.Z06_LOTE" + CRLF +;
						", PRP.B1_X_SEXO" + CRLF +;
						", PRP.B1_XRACA" + CRLF +;
						", PRP.Z05_DATA" + CRLF +;
						", PRP.Z05_DATA" + CRLF +;
						", PRP.Z05_CURRAL" + CRLF +;
						", PRP.Z05_PESOCO" + CRLF +;
						", PRP.Z05_CABECA" + CRLF +;
						", PRP.Z0O_GMD" + CRLF +;
						", PRP.Z05_DIASDI" + CRLF +;
						", PRP.Z05_DIETA" + CRLF +;
						", PRP.Z05_NROTRA" + CRLF +;
						", PRP.PREVISTO" + CRLF +;
						", PRP.REALIZADO" + CRLF +;
						", PRP.PERC_MS" + CRLF +;
						", PRP.CMN_PREVISTO" + CRLF +;
						", PRP.CMN_REALIZADO" + CRLF +;
						", PRP.Z05_KGMSDI" + CRLF +;
						", PRP.CMS_REALIZADO" + CRLF+;
						", Z0I.Z0I_NOTTAR" + CRLF+; 
						", Z0I.Z0I_NOTMAN" + CRLF
		If MV_PAR07 == 2
			_cQry += ", SUM(D3_QUANT) QTD_RACAO " + CRLF +;
					", SUM(TOTAL_P_PR) CUSTO_TOTA " + CRLF +;
					", SUM(TOTAL_P_PR) / PRP.Z05_CABECA CUSTO_ANIM " + CRLF +;
					", PRP.MEGACAL MEGACALP " + CRLF +;
					", CASE WHEN PRP.MEGACAL > 0 THEN (PRP.MEGACAL/Z05_KGMSDI) * PRP.CMS_REALIZADO "  + CRLF +;
					"       ELSE 0 END AS MEGACALR " + CRLF
		EndIf
			_cQry += " from PRINCIPAL PRP" + CRLF 
			If MV_PAR07 == 2
				_cQry +=  " left join ESTOQUE E ON" + CRLF +;
						"      E.D3_FILIAL = PRP.Z05_FILIAL AND PRP.Z06_LOTE = E.D3_LOTECTL AND PRP.Z05_DATA = D3_EMISSAO" + CRLF +; 
						"left join " + RetSqlName("Z0I") + " Z0I ON Z0I.Z0I_FILIAL = PRP.Z05_FILIAL AND Z0I.Z0I_DATA = PRP.Z05_DATA AND  Z0I.Z0I_LOTE = PRP.Z06_LOTE AND Z0I.D_E_L_E_T_ = ' ' " + CRLF +; 
						"GROUP BY PRP.Z06_LOTE, PRP.B1_X_SEXO, PRP.B1_XRACA, PRP.Z05_DATA, PRP.Z05_CURRAL, PRP.Z05_PESOCO, PRP.Z05_CABECA, PRP.Z0O_GMD, PRP.Z05_DIASDI" + CRLF +; 
						", PRP.Z05_DIETA, PRP.Z05_NROTRA, PRP.CMS_REALIZADO, PRP.PREVISTO, PRP.REALIZADO, PRP.Z05_KGMSDI--, PRP.Z05_KGMNDI" + CRLF +; 
						", PRP.PERC_MS, PRP.CMN_PREVISTO, PRP.CMN_REALIZADO, PRP.CMS_REALIZADO, Z0I_NOTTAR, Z0I_NOTMAN, PRP.MEGACAL" + CRLF  
			EndIf
			_cQry +=" order by PRP.Z06_LOTE" + CRLF +;
					", PRP.Z05_DATA"

ElseIf  cTipo == "Saldo"
		_cQry :="  SELECT B8_LOTECTL, SUM(B8_SALDO) B8_SALDO, B8_X_CURRA, B8_XPESOCO " +CRLF
		_cQry +="   FROM " + RetSqlName("SB8") + " " +CRLF
		_cQry +="  WHERE B8_LOTECTL = '" + MV_PAR03 + "' " +CRLF
		_cQry +="    AND D_E_L_E_T_ = ' ' " +CRLF
		_cQry +="GROUP BY B8_LOTECTL, B8_X_CURRA, B8_XPESOCO " +CRLF

ElseIf  cTipo == "Apartacao"

	_cQry := "  SELECT DISTINCT Z0F_LOTE, Z0F_CURRAL, SUBSTRING(B1_XLOTCOM,3,6) ZBC_PEDIDO, Z0F_DTPES, " + CRLF
	_cQry += "           COUNT(Z0F_SEQ) QTDE, SUM(Z0F_PESO) Z0F_PESO, SUM(Z0F_PESO)/COUNT(Z0F_SEQ) PESO_MEDIO, " + CRLF
	_cQry += " 		  (ISNULL((SELECT DISTINCT ZCC_NOMCOR  " + CRLF
	_cQry += " 		             FROM "+retSQLName("ZCC")+" ZCC " + CRLF
	_cQry += " 					WHERE ZCC.D_E_L_E_T_ = ' ' AND ZCC_FILIAL+ZCC_CODIGO+ZCC_VERSAO =  " + CRLF
	_cQry += " 					                 (SELECT DISTINCT ZBC_FILIAL+ZBC_CODIGO+ZBC_VERSAO  " + CRLF
	_cQry += " 									    FROM "+retSQLName("ZBC")+" ZBC " + CRLF
	_cQry += " 									   WHERE ZBC.D_E_L_E_T_ = '' AND ZBC_FILIAL + ZBC_PEDIDO = B1_XLOTCOM AND ZBC_PRODUT = Z0F_PRDORI)),'')) ZCC_NOMCOR, " + CRLF
	_cQry += " 		  (ISNULL((SELECT DISTINCT ZCC_CODIGO  " + CRLF
	_cQry += " 		             FROM "+retSQLName("ZCC")+" ZCC " + CRLF
	_cQry += " 					WHERE ZCC.D_E_L_E_T_ = ' ' AND ZCC_FILIAL+ZCC_CODIGO+ZCC_VERSAO =  " + CRLF
	_cQry += " 					                 (SELECT DISTINCT ZBC_FILIAL+ZBC_CODIGO+ZBC_VERSAO  " + CRLF
	_cQry += " 									    FROM "+retSQLName("ZBC")+" ZBC " + CRLF
	_cQry += " 									   WHERE ZBC.D_E_L_E_T_ = '' AND ZBC_FILIAL + ZBC_PEDIDO = B1_XLOTCOM AND ZBC_PRODUT = Z0F_PRDORI)),'')) ZBC_CODIGO, " + CRLF
	_cQry += " 		  (ISNULL((SELECT DISTINCT A2_NOME  " + CRLF
	_cQry += " 		             FROM "+retSQLName("SA2")+" SA2 " + CRLF
	_cQry += " 					WHERE SA2.D_E_L_E_T_ = ' ' AND  A2_COD+A2_LOJA = " + CRLF
	_cQry += " 					                  (SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR " + CRLF
	_cQry += " 									     FROM "+retSQLName("ZBC")+" ZBC " + CRLF
	_cQry += " 									    WHERE ZBC.D_E_L_E_T_ = '' AND ZBC_FILIAL + ZBC_PEDIDO = B1_XLOTCOM AND ZBC_PRODUT = Z0F_PRDORI)),'')) A2_NOME " + CRLF
    _cQry += "      FROM "+retSQLName("Z0F")+" Z0F " + CRLF
    _cQry += " LEFT JOIN "+retSQLName("SB1")+" SB1 ON  " + CRLF
    _cQry += "           B1_COD = Z0F_PRDORI  " + CRLF
	_cQry += "       AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "     WHERE Z0F_LOTE BETWEEN '" + MV_PAR03 + "' and '" + MV_PAR04 + "'" + CRLF   
    _cQry += "  GROUP BY Z0F_LOTE, Z0F_CURRAL, B1_XLOTCOM, Z0F_DTPES, Z0F_PRDORI " + CRLF

ElseIf  cTipo == "Faturamento"
		
		_cQry := "	  SELECT DISTINCT D2_FILIAL, D2_EMISSAO, D2_DOC, D2_LOTECTL, SUM(D2_QUANT) D2_QUANT, ZPB_PESOE, ZPB_HORA, ZPB_PESOS, ZPB_HORAF, ZPB_PESOL PESO, ZPB_NROGTA, ZPB_NOMMOT" +CRLF
		_cQry += "    FROM " + RetSqlName("SD2") + " D2" +CRLF
		_cQry += "	 JOIN " + RetSqlName("ZPB") + " ZPB ON" +CRLF
		_cQry += "	      ZPB_FILIAL = D2_FILIAL " +CRLF
		_cQry += "	  AND ZPB_DATA = D2_EMISSAO " +CRLF
		_cQry += "	  AND ZPB_NOTFIS = D2_DOC" +CRLF
		_cQry += "	  AND ZPB_BAIA = D2_LOTECTL" +CRLF
		_cQry += "	  AND ZPB.D_E_L_E_T_ = ' ' " +CRLF
		_cQry += "	WHERE D2_LOTECTL = '" + MV_PAR03 + "'--'" + MV_PAR03 + "' " +CRLF
		_cQry += "	  AND D2.D_E_L_E_T_ = ' '" +CRLF
		_cQry += " GROUP BY D2_FILIAL, D2_EMISSAO, D2_LOTECTL, D2_DOC, ZPB_PESOL, ZPB_NROGTA, ZPB_NOMMOT, ZPB_PESOE, ZPB_PESOS, ZPB_HORA, ZPB_HORAF" +CRLF

ElseIf  cTipo == "Embarque"

	_cQry :=" with PRODU AS ( " +CRLF
	_cQry +="    select Z0Y.Z0Y_ORDEM, Z0Y.Z0Y_DATA, Z0Y.Z0Y_TRATO, Z0Y.Z0Y_RECEIT, case when Z0Y_PESDIG > 0 THEN Z0Y_PESDIG ELSE Z0Y_QTDREA  END AS PRD_QTD_REA, Z0Y_QTDPRE PRD_QTD_PRV " +CRLF
	_cQry +="      from " + RetSqlName("Z0Y") + " Z0Y " +CRLF
	_cQry +="     where Z0Y.Z0Y_FILIAL = '" + FWxFilial("Z0Y") + "' " +CRLF
	_cQry +="       and Z0Y.Z0Y_DATINI <> '        ' -- Descarta as linhas que não foram efetivadas " +CRLF
	_cQry +="       and Z0Y.D_E_L_E_T_ = ' ' " +CRLF
	_cQry +=" ) , " +CRLF
	_cQry +=" QTDPROD as ( " +CRLF
	_cQry +="    select PRD.Z0Y_ORDEM, PRD.Z0Y_RECEIT, PRD.Z0Y_TRATO, sum(PRD.PRD_QTD_REA) PRD_QTD_REA, sum(PRD.PRD_QTD_PRV) PRD_QTD_PRV " +CRLF
	_cQry +="      from PRODU PRD " +CRLF
	_cQry +="  group by PRD.Z0Y_ORDEM, PRD.Z0Y_TRATO, PRD.Z0Y_RECEIT " +CRLF
	_cQry +=" ) , " +CRLF
	_cQry +=" TRATO AS ( " +CRLF
	_cQry +="    select Z0W.Z0W_ORDEM, Z0W.Z0W_DATA, Z0W.Z0W_LOTE, Z0W_CURRAL, Z0W.Z0W_TRATO, Z0W.Z0W_RECEIT, CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END  TRT_QTD_REA, Z0W.Z0W_QTDPRE TRT_QTD_PRV " +CRLF
	_cQry +="      from " + RetSqlName("Z0W") + " Z0W " +CRLF
	_cQry +="     where Z0W.Z0W_FILIAL = '" + FWxFilial("Z0W") + "' " +CRLF
	_cQry +="       and Z0W.Z0W_QTDPRE <> '        ' " +CRLF
	_cQry +="       and Z0W.D_E_L_E_T_ = ' ' " +CRLF
	_cQry +=" ) , " +CRLF
	_cQry +=" TRATOLOTE as ( " +CRLF
	_cQry +="    select Z0W_DATA, Z0W_LOTE, Z0W_CURRAL, SUM(TRT_QTD_REA) TRT_QTD_REA,  SUM(TRT_QTD_PRV) TRT_QTD_PRV " +CRLF
	_cQry +="      from TRATO  " +CRLF
	_cQry +="  group by Z0W_DATA, Z0W_LOTE, Z0W_CURRAL " +CRLF
	_cQry +=" ) , " +CRLF
	_cQry +=" QTDTRATO as ( " +CRLF
	_cQry +="    select Z0W.Z0W_ORDEM, Z0W.Z0W_TRATO, sum(Z0W.TRT_QTD_REA) TRT_QTD_REA, sum(Z0W.TRT_QTD_PRV) TRT_QTD_PRV " +CRLF
	_cQry +="      from TRATO Z0W " +CRLF
	_cQry +="  group by Z0W.Z0W_ORDEM, Z0W.Z0W_TRATO      " +CRLF
	_cQry +=" ) , " +CRLF
	_cQry +=" RECEITA as ( " +CRLF
	_cQry +="    select Z0Y_ORDEM, Z0Y_TRATO, Z0Y.Z0Y_RECEIT, Z0Y_COMP, CASE WHEN Z0Y_PESDIG > 0 THEN Z0Y_PESDIG ELSE  Z0Y_QTDREA END AS Z0Y_QTDREA, Z0Y_QTDPRE " +CRLF
	_cQry +="      from " + RetSqlName("Z0Y") + " Z0Y " +CRLF
	_cQry +="     where Z0Y.Z0Y_FILIAL = '" + FWxFilial("Z0Y") + "' " +CRLF
	_cQry +="       and Z0Y.Z0Y_QTDPRE <> '        '  " +CRLF
	_cQry +="       and Z0Y.D_E_L_E_T_ = ' ' " +CRLF
	_cQry +=" ) , " +CRLF
	_cQry +=" REALIZADO as ( " +CRLF
	_cQry +="    select Z0W.Z0W_FILIAL " +CRLF
	_cQry +="         , Z0W.Z0W_ORDEM -- OP " +CRLF
	_cQry +="         , Z0W.Z0W_DATA -- Data do trato " +CRLF
	_cQry +="         , Z0W.Z0W_VERSAO -- versão do trato " +CRLF
	_cQry +="         , Z0W.Z0W_ROTA -- Rota a que o curral pertence " +CRLF
	_cQry +="         , Z0W.Z0W_CURRAL -- Curral " +CRLF
	_cQry +="         , Z0W.Z0W_LOTE -- Lote " +CRLF
	_cQry +="         , Z0W.Z0W_TRATO -- Numero do trato " +CRLF
	_cQry +="         , Z0W.Z0W_RECEIT  " +CRLF
	_cQry +="         , REC.Z0Y_COMP -- Componente da receita do trato " +CRLF
	_cQry +="         , Z0W.Z0W_QTDPRE " +CRLF
	_cQry +="         , Z0W.Z0W_QTDREA -- Quantidade distribuida no cocho para a baia " +CRLF
	_cQry +="         , Z05.Z05_CABECA -- Numero de cabeças da baia no momento do trato " +CRLF
	_cQry +="         , PRD.PRD_QTD_PRV -- Qunatidade total produzida prevista " +CRLF
	_cQry +="         , PRD.PRD_QTD_REA -- Quantidade total produzida aferida na balança " +CRLF
	_cQry +="         , TRT.TRT_QTD_PRV -- Quantidade total distribuida prevista " +CRLF
	_cQry +="         , TRT.TRT_QTD_REA -- Quantidade total distribuida aferida na balança " +CRLF
	_cQry +="         , REC.Z0Y_QTDREA -- Quantidade do componente usado na fabricação da dieta " +CRLF
	_cQry +="         , Z0V.Z0V_INDMS -- Indice de materia seca no dia/versao do trato " +CRLF
	_cQry +="         , Z0W_QTDREA/TRT_QTD_REA*PRD_QTD_REA QTD_MN -- Quantidade total de materia natural distribuida no cocho " +CRLF
	_cQry +="         , ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*PRD_QTD_REA)/(TRT_QTD_REA*Z05_CABECA) QTD_MN_CABECA -- Quantidade total de materia natural distribuida no cocho por cabeça " +CRLF
	_cQry +="         , ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*Z0Y_QTDREA)/TRT_QTD_REA QTD_MN_COMPONENTE -- quantidade de materia natural do componente " +CRLF
	_cQry +="         , ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*Z0Y_QTDREA)/(TRT_QTD_REA*Z05_CABECA) QTD_MN_COMPONENTE_CABECA -- quantidade de materia natural do componente por cabeça " +CRLF
	_cQry +="         , ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*Z0Y_QTDREA*Z0V_INDMS)/(100*TRT_QTD_REA) QTD_MS_COMPONENTE -- quantidade calculada de materia seca do componente de acordo com o indice de materia seca utilizado no trato " +CRLF
	_cQry +="         , ((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END )*Z0Y_QTDREA*Z0V_INDMS)/(100*TRT_QTD_REA*Z05_CABECA) QTD_MS_COMP_CABECA -- quantidade calculada de materia seca do componente por cabeça de acordo com o indice de materia seca utilizado no trato " +CRLF
	_cQry +="      from " + RetSqlName("Z0W") + " Z0W " +CRLF
	_cQry +="      join QTDPROD PRD " +CRLF
	_cQry +="        on PRD.Z0Y_ORDEM = Z0W.Z0W_ORDEM " +CRLF
	_cQry +="       and PRD.Z0Y_TRATO = Z0W.Z0W_TRATO " +CRLF
	_cQry +="      join QTDTRATO TRT " +CRLF
	_cQry +="        on TRT.Z0W_ORDEM = Z0W.Z0W_ORDEM " +CRLF
	_cQry +="       and TRT.Z0W_TRATO = Z0W.Z0W_TRATO " +CRLF
	_cQry +="      join RECEITA REC " +CRLF
	_cQry +="        on REC.Z0Y_ORDEM = Z0W.Z0W_ORDEM " +CRLF
	_cQry +="       and REC.Z0Y_TRATO = Z0W.Z0W_TRATO " +CRLF
	_cQry +="      join " + RetSqlName("Z05") + " Z05 " +CRLF
	_cQry +="        on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "' " +CRLF
	_cQry +="       and Z05.Z05_DATA   = Z0W.Z0W_DATA " +CRLF
	_cQry +="       and Z05.Z05_LOTE   = Z0W.Z0W_LOTE " +CRLF
	_cQry +="       and Z05.D_E_L_E_T_ = ' ' " +CRLF
	_cQry +="      join " + RetSqlName("Z0V") + " Z0V " +CRLF
	_cQry +="        on Z0V.Z0V_FILIAL = '" + FWxFilial("Z0V") + "' " +CRLF
	_cQry +="       and Z0V.Z0V_DATA   = Z0W.Z0W_DATA " +CRLF
	_cQry +="       and Z0V.Z0V_COMP   = REC.Z0Y_COMP " +CRLF
	_cQry +="       and Z0V.D_E_L_E_T_ = ' ' " +CRLF
	_cQry +="     where Z0W.Z0W_FILIAL = '" + FWxFilial("Z0W") + "'  " +CRLF
	_cQry +="       and Z0W.Z0W_DATINI <> '        ' " +CRLF
	_cQry +="       and Z0W.D_E_L_E_T_ = ' ' " +CRLF
	_cQry +=" ) " +CRLF
	_cQry +=" , PRINCIPAL as ( " +CRLF
	_cQry +="    select Z05.Z05_FILIAL " +CRLF
	_cQry +=" ,         Z05.Z05_DATA " +CRLF
	_cQry +=" ,         Z05.Z05_CURRAL " +CRLF
	_cQry +=" ,         Z06.Z06_LOTE " +CRLF
	_cQry +=" ,         Z05.Z05_PESOCO " +CRLF
	_cQry +=" ,         Z05.Z05_CABECA " +CRLF
	_cQry +=" ,         Z0O.Z0O_CODPLA " +CRLF
	_cQry +=" ,         Z0O.Z0O_GMD " +CRLF
	_cQry +=" ,         Z05.Z05_DIASDI " +CRLF
	_cQry +=" ,         Z05.Z05_DIETA " +CRLF
	_cQry +=" ,         Z05.Z05_NROTRA " +CRLF
	_cQry +=" ,         isnull(Z0WT.TRT_QTD_PRV,0) PREVISTO " +CRLF
	_cQry +=" ,         isnull(Z0WT.TRT_QTD_REA,0) REALIZADO " +CRLF
	_cQry +=" ,         Z05.Z05_KGMSDI " +CRLF
	_cQry +=" ,         case when Z05.Z05_KGMSDI > 0 then Z05.Z05_KGMSDI / Z05.Z05_KGMNDI * 100 else 0 end PERC_MS " +CRLF
	_cQry +=" ,         isnull(Z05_KGMNDI,0) CMN_PREVISTO " +CRLF
	_cQry +=" ,         SUM(QTD_MN_COMPONENTE_CABECA) CMN_REALIZADO --, sum(isnull(Z0W.QTD_MN_CABECA,0)) / Z05.Z05_CABECA CMN_REALIZADO " +CRLF
	_cQry +=" ,         SUM(QTD_MS_COMP_CABECA) CMS_REALIZADO--, sum(isnull(Z0W.QTD_MN_CABECA,0)) / Z05.Z05_CABECA CMN_REALIZADO " +CRLF
	_cQry +="      from " + RetSqlName("Z05") + " Z05 " +CRLF
	_cQry +="      join " + RetSqlName("Z06") + " Z06 " +CRLF
	_cQry +="        on Z06_FILIAL     = '" + FWxFilial("Z06") + "' " +CRLF
	_cQry +="       and Z06.Z06_DATA   = Z05.Z05_DATA " +CRLF
	_cQry +="       and Z06.Z06_VERSAO = Z05.Z05_VERSAO " +CRLF
	_cQry +="       and Z06.Z06_CURRAL = Z05.Z05_CURRAL " +CRLF
	_cQry +="       and Z06.Z06_LOTE   = Z05.Z05_LOTE " +CRLF
	_cQry +="       and Z06.D_E_L_E_T_ = ' ' " +CRLF
	_cQry +="      join " + RetSqlName("SB1") + " SB1 " +CRLF
	_cQry +="        on SB1.B1_FILIAL  = '  ' " +CRLF
	_cQry +="       and SB1.B1_COD     = Z06.Z06_DIETA " +CRLF
	_cQry +="       and SB1.D_E_L_E_T_ = ' ' " +CRLF
	_cQry +="      left join REALIZADO Z0W " +CRLF
	_cQry +="        on Z0W.Z0W_FILIAL = '" + FWxFilial("Z0W") + "' " +CRLF
	_cQry +="       and Z0W.Z0W_DATA   = Z06.Z06_DATA " +CRLF
	_cQry +="       and Z0W.Z0W_LOTE   = Z06.Z06_LOTE " +CRLF
	_cQry +="       and Z0W.Z0W_CURRAL = Z06.Z06_CURRAL " +CRLF
	_cQry +="       and Z0W.Z0W_TRATO  = Z06.Z06_TRATO " +CRLF
	_cQry +="       and Z0W.Z0W_RECEIT = Z06.Z06_DIETA " +CRLF
	_cQry +=" left join " + RetSqlName("Z0O") + " Z0O " +CRLF
	_cQry +="        on Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "' " +CRLF
	_cQry +="       and Z0O.Z0O_LOTE   = Z05_LOTE " +CRLF
	_cQry +="       and Z05.Z05_DATA   between Z0O_DATAIN and case when Z0O_DATATR = '        ' then convert(varchar, getdate(), 112) else Z0O_DATATR end " +CRLF
	_cQry +="       and Z0O.D_E_L_E_T_ = ' ' " +CRLF
	_cQry +=" left join TRATOLOTE Z0WT ON  " +CRLF
	_cQry +="           Z0WT.Z0W_DATA = Z05_DATA " +CRLF
	_cQry +="       AND Z0WT.Z0W_LOTE  = Z05_LOTE " +CRLF
	_cQry +="       AND Z0WT.Z0W_CURRAL = Z05_CURRAL " +CRLF
	_cQry +="     where Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "' " +CRLF
	_cQry +="       and Z05.Z05_DATA   BETWEEN '" + DToS(MV_PAR01) + "' and '" + DToS(MV_PAR02) + "'" + CRLF 
	_cQry +="       and Z05.Z05_LOTE   BETWEEN '" + MV_PAR03 + "' and '" + MV_PAR04 + "'" + CRLF 
	_cQry +="       and Z05.D_E_L_E_T_ = ' ' " +CRLF
	_cQry +="  group by Z05_FILIAL " +CRLF
	_cQry +="         , Z05_DATA " +CRLF
	_cQry +="         , Z05_LOTE " +CRLF
	_cQry +="         , Z05_CURRAL " +CRLF
	_cQry +="         , Z06_LOTE " +CRLF
	_cQry +="         ,	Z05_KGMNDI " +CRLF
	_cQry +="         , Z05_PESOCO " +CRLF
	_cQry +="         , Z0WT.TRT_QTD_PRV  " +CRLF
	_cQry +="         , Z0WT.TRT_QTD_REA " +CRLF
	_cQry +="         , Z0O_CODPLA " +CRLF
	_cQry +="         , Z0O_GMD " +CRLF
	_cQry +="         , Z05_DIASDI " +CRLF
	_cQry +="         , Z05.Z05_CABECA " +CRLF
	_cQry +="         , Z05.Z05_DIETA " +CRLF
	_cQry +="         , Z05.Z05_NROTRA " +CRLF
	_cQry +="         , Z05.Z05_KGMSDI " +CRLF
	_cQry +="         , Z05.Z05_KGMNDI " +CRLF
	_cQry +=" ) " +CRLF
	_cQry +=" , ESTOQUE AS (  " +CRLF
	_cQry +="    SELECT  D31.D3_FILIAL " +CRLF
	_cQry +="          , D3.D3_LOTECTL " +CRLF
	_cQry +="          , D3.D3_QUANT	QUANT_ANIMAIS " +CRLF
	_cQry +="          , D31.D3_COD " +CRLF
	_cQry +="          , B1.B1_DESC " +CRLF
	_cQry +="          , D31.D3_EMISSAO " +CRLF
	_cQry +="          , D31.D3_QUANT " +CRLF
	_cQry +="          , (D31.D3_CUSTO1/D31.D3_QUANT) CUSTO_UNIT " +CRLF
	_cQry +="          , D31.D3_CUSTO1	CUSTO " +CRLF
	_cQry +="          , (SUM(D3C.D3_CUSTO1)/SUM(D3C.D3_QUANT)) AS  MEDIO_PROD " +CRLF
	_cQry +="          , ((SUM(D3C.D3_CUSTO1)/SUM(D3C.D3_QUANT))*D31.D3_QUANT) AS     TOTAL_P_PR " +CRLF
	_cQry +="          , ((SUM(D3C.D3_CUSTO1)/SUM(D3C.D3_QUANT))*D31.D3_QUANT) /D3.D3_QUANT CUSTO_ANIM " +CRLF
	_cQry +="       FROM " + RetSqlName("SD3") + " D3 " +CRLF
	_cQry +=" INNER JOIN " + RetSqlName("SD3") + " D31 ON " +CRLF
	_cQry +="            D31.D3_OP				=				D3.D3_OP " +CRLF
	_cQry +="        AND D31.D_E_L_E_T_			=				' ' " +CRLF
	_cQry +="        AND D31.D3_GRUPO				=				'03' " +CRLF
	_cQry +=" INNER JOIN " + RetSqlName("SD3") + " D3C ON " +CRLF
	_cQry +="            D3C.D3_FILIAL			=				D31.D3_FILIAL " +CRLF
	_cQry +="            AND D3C.D3_COD				=				D31.D3_COD " +CRLF
	_cQry +="            AND D3C.D3_TM				=				'001' " +CRLF
	_cQry +="            AND D3C.D3_EMISSAO			=				D3.D3_EMISSAO " +CRLF
	_cQry +=" INNER JOIN " + RetSqlName("SB1") + " B11 ON " +CRLF
	_cQry +="            B11.B1_COD				=				D3.D3_COD " +CRLF
	_cQry +="        AND B11.D_E_L_E_T_			=				' ' " +CRLF
	_cQry +=" INNER JOIN " + RetSqlName("SB1") + " B1 ON " +CRLF
	_cQry +="            D31.D3_COD				=				B1.B1_COD " +CRLF
	_cQry +="      WHERE D3.D3_FILIAL		    = '" + FWxFilial("SD3") + "' " +CRLF
	_cQry +="        AND D3.D3_LOTECTL	BETWEEN '" + MV_PAR03 + "' and '" + MV_PAR04 + "'  " +CRLF
	_cQry +="        AND D3.D3_EMISSAO	BETWEEN	'" + DToS(MV_PAR01) + "' and '" + DToS(MV_PAR02) + "'" + CRLF 
	_cQry +="        AND D3.D3_CF					=				'PR0' " +CRLF
	_cQry +="        AND D3.D3_ESTORNO			<>				'S' " +CRLF
	_cQry +="        AND D3.D_E_L_E_T_			=				' ' " +CRLF
	_cQry +="        AND D3.D3_LOTECTL			<>				' ' " +CRLF
	_cQry +="   GROUP BY D31.D3_FILIAL, D3.D3_COD, B11.B1_DESC, D3.D3_LOTECTL, D3.D3_QUANT, D3.D3_TM, D31.D3_COD, B1.B1_DESC, D31.D3_EMISSAO, D31.D3_QUANT,D31.D3_CUSTO1	 " +CRLF
	_cQry +=" ) " +CRLF
	_cQry +=" , GERAL AS ( " +CRLF
	_cQry +="    select PRP.Z06_LOTE " +CRLF
	_cQry +="         , PRP.Z05_DATA " +CRLF
	_cQry +="         , PRP.Z05_CURRAL " +CRLF
	_cQry +="         , PRP.Z05_PESOCO " +CRLF
	_cQry +="         , PRP.Z05_CABECA " +CRLF
	_cQry +="         , PRP.Z0O_GMD " +CRLF
	_cQry +="         , PRP.Z05_DIASDI " +CRLF
	_cQry +="         , PRP.Z05_DIETA " +CRLF
	_cQry +="         , PRP.Z05_NROTRA " +CRLF
	_cQry +="         , PRP.PREVISTO " +CRLF
	_cQry +="         , PRP.REALIZADO " +CRLF
	_cQry +="         , PRP.PERC_MS " +CRLF
	_cQry +="         , PRP.CMN_PREVISTO " +CRLF
	_cQry +="         , PRP.CMN_REALIZADO " +CRLF
	_cQry +="         , PRP.Z05_KGMSDI " +CRLF
	_cQry +="         , PRP.CMS_REALIZADO " +CRLF
	_cQry +="         , Z0I_NOTTAR " +CRLF
	_cQry +="         , Z0I_NOTMAN " +CRLF
	_cQry +="         , SUM(D3_QUANT) QTD_RACAO " +CRLF
	_cQry +="         , SUM(TOTAL_P_PR) CUSTO_TOTA " +CRLF
	_cQry +="         , SUM(TOTAL_P_PR) / PRP.Z05_CABECA CUSTO_ANIM " +CRLF
	_cQry +="      from PRINCIPAL PRP " +CRLF
	_cQry +=" left join ESTOQUE E ON " +CRLF
	_cQry +="           E.D3_FILIAL = PRP.Z05_FILIAL AND PRP.Z06_LOTE = E.D3_LOTECTL AND PRP.Z05_DATA = D3_EMISSAO " +CRLF
	_cQry +=" left join Z0I010 Z0I ON Z0I_FILIAL = PRP.Z05_FILIAL AND Z0I.Z0I_DATA = PRP.Z05_DATA AND  Z0I.Z0I_LOTE = PRP.Z06_LOTE AND Z0I.D_E_L_E_T_ = ' '  " +CRLF
	_cQry +="     WHERE Z05_DATA < (  SELECT MAX(Z0W.Z0W_DATA) Z0W_DATA " +CRLF
	_cQry +=" 				FROM " + RetSqlName("Z0W") + " Z0W " +CRLF
	_cQry +=" 				JOIN " + RetSqlName("SD2") + " ON  " +CRLF
	_cQry +=" 				     D2_FILIAL = '" + FWxFilial("SD2") + "' " +CRLF
	_cQry +=" 				 AND D2_LOTECTL = Z0W_LOTE " +CRLF
	_cQry +=" 			   WHERE Z05_FILIAL= Z0W_FILIAL " +CRLF
	_cQry +=" 				     AND Z0W_LOTE = Z06_LOTE " +CRLF
	_cQry +=" 				     AND Z0W.D_E_L_E_T_ = ' ' ) " +CRLF
	_cQry +=" GROUP BY PRP.Z05_FILIAL,PRP.Z06_LOTE, PRP.Z05_DATA, PRP.Z05_CURRAL, PRP.Z05_PESOCO, PRP.Z05_CABECA, PRP.Z0O_GMD, PRP.Z05_DIASDI " +CRLF
	_cQry +=" , PRP.Z05_DIETA, PRP.Z05_NROTRA, PRP.CMS_REALIZADO, PRP.PREVISTO, PRP.REALIZADO, PRP.Z05_KGMSDI--, PRP.Z05_KGMNDI " +CRLF
	_cQry +=" , PRP.PERC_MS, PRP.CMN_PREVISTO, PRP.CMN_REALIZADO, PRP.CMS_REALIZADO, Z0I_NOTTAR, Z0I_NOTMAN " +CRLF
	_cQry +="  " +CRLF
	_cQry +=" ) " +CRLF
	_cQry +=" , ALIMENTACAO AS ( " +CRLF
	_cQry +="       SELECT Z06_LOTE " +CRLF
	_cQry +=" 	       , SUM(Z05_CABECA) Z05_CABECA " +CRLF
	_cQry +=" 		   , SUM(REALIZADO) REALIZADO " +CRLF
	_cQry +=" 		   , SUM(REALIZADO*(PERC_MS/100)) MAT_SECA " +CRLF
	_cQry +="  " +CRLF
	_cQry +=" 		   , ROUND(SUM(REALIZADO*(PERC_MS/100)) / SUM(Z05_CABECA),2) CMS " +CRLF
	_cQry +=" 	    FROM GERAL " +CRLF
	_cQry +="     GROUP BY Z06_LOTE " +CRLF
	_cQry +=" 	) " +CRLF
	_cQry +="  " +CRLF
	_cQry +=" , FATURAMENTO AS ( " +CRLF
	_cQry +="       SELECT SD2.D2_FILIAL,  SD2.D2_LOTECTL, SD2.D2_EMISSAO, SUM(SD2.D2_QUANT) D2_QUANT " +CRLF
	_cQry +="         FROM " + RetSqlName("SD2") + " SD2  " +CRLF
	_cQry +=" 	   WHERE SD2.D2_FILIAL = '" + FWxFilial("SD2") + "'  " +CRLF
	_cQry +=" 	     AND SD2.D2_LOTECTL = '" + MV_PAR03 + "' " +CRLF
	//_cQry +=" 		 AND SD2.D2_EMISSAO = '20201228'  " +CRLF
	_cQry +=" 		 AND SD2.D_E_L_E_T_ = ' ' " +CRLF
	_cQry +=" 		 AND SD2.D2_CLIENTE = '000001' " +CRLF
	_cQry +=" 		 AND D2_XCODABT NOT IN (SELECT ZAB_CODIGO FROM ZAB010 ZAB WHERE ZAB_FILIAL = '" + FWxFilial("SB8") + "' AND ZAB_BAIA = '" + MV_PAR03 + "' AND ZAB.D_E_L_E_T_ = ' ' AND (ZAB_EMERGE NOT IN ('0','2') OR ZAB_OUTMOV NOT IN ('0','2'))) " +CRLF
	_cQry +=" 	GROUP BY SD2.D2_FILIAL,  SD2.D2_LOTECTL, SD2.D2_EMISSAO " +CRLF
	_cQry +=" 		 ) " +CRLF
	_cQry +=" --SELECT * FROM FATURAMENTO " +CRLF
	_cQry +="  , APARTACAO AS ( " +CRLF
	_cQry +="       SELECT Z0F.Z0F_FILIAL, Z0F.Z0F_LOTE, MIN(Z0F.Z0F_DTPES) Z0F_DTPES, COUNT(Z0F.Z0F_SEQ) QTD, ROUND(AVG(Z0F.Z0F_PESO),2) Z0F_PESO " +CRLF
	_cQry +=" 		FROM " + RetSqlName("Z0F") + " Z0F " +CRLF
	_cQry +=" 		WHERE Z0F.Z0F_FILIAL = '" + FWxFilial("Z0F") + "' " +CRLF
	_cQry +=" 		  AND Z0F.Z0F_LOTE = '" + MV_PAR03 + "' " +CRLF
	_cQry +=" 		  AND Z0F.D_E_L_E_T_ = ' ' " +CRLF
	_cQry +=" 	 GROUP BY Z0F.Z0F_FILIAL, Z0F.Z0F_LOTE " +CRLF
	_cQry +=" 		  ) " +CRLF
	_cQry +="  , PLANEJAMENTO AS ( " +CRLF
	_cQry +="       SELECT Z05.Z05_FILIAL, Z05.Z05_LOTE, SUM(Z05.Z05_CABECA) Z05_CABECAS " +CRLF
	_cQry +=" 	    FROM " + RetSqlName("Z05") + " Z05 " +CRLF
	_cQry +=" 		WHERE Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "' " +CRLF
	_cQry +=" 		  AND Z05.Z05_LOTE = '" + MV_PAR03 + "' " +CRLF
	_cQry +=" 		  AND Z05.D_E_L_E_T_ = ' '  " +CRLF
	_cQry +=" 		  AND Z05_KGMNDI > 0 " +CRLF
	_cQry +=" 	 GROUP BY Z05.Z05_FILIAL, Z05.Z05_LOTE " +CRLF
	_cQry +="  ) " +CRLF
	_cQry +="  " +CRLF
	_cQry +="  , DIAS AS ( " +CRLF
	_cQry +="       SELECT Z0W.Z0W_FILIAL, Z0W.Z0W_LOTE  " +CRLF
	_cQry +=" 		   , CASE WHEN MIN(Z0W.Z0W_DATA) = ISNULL(A.Z0F_DTPES,(SELECT MIN(B8_XDATACO) DIAS FROM " + RetSqlName("SB8") + " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "' AND B8_LOTECTL = '" + MV_PAR03 + "' AND D_E_L_E_T_ = ' 'GROUP BY B8_LOTECTL)) THEN DATEADD(DAY,1,MIN(Z0W.Z0W_DATA)) " +CRLF
	_cQry +=" 		     WHEN MIN(Z0W.Z0W_DATA) > ISNULL(A.Z0F_DTPES,(SELECT MIN(B8_XDATACO) DIAS FROM " + RetSqlName("SB8") + " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "' AND B8_LOTECTL = '" + MV_PAR03 + "' AND D_E_L_E_T_ = ' 'GROUP BY B8_LOTECTL )) THEN ISNULL(A.Z0F_DTPES,(SELECT MIN(B8_XDATACO)+1 DIAS FROM " + RetSqlName("SB8") + " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "' AND B8_LOTECTL = '" + MV_PAR03 + "' AND D_E_L_E_T_ = ' 'GROUP BY B8_LOTECTL )) " +CRLF
	_cQry +=" 			      ELSE MIN(Z0W.Z0W_DATA) END AS DATA_INI " +CRLF
	_cQry +=" 		   , CASE WHEN MAX(Z0W.Z0W_DATA) = F.D2_EMISSAO  THEN MAX(Z0W.Z0W_DATA) " +CRLF
	_cQry +=" 			      ELSE DATEADD(DAY,-1,MAX(Z0W.Z0W_DATA)) END AS DATA_FIM " +CRLF
	_cQry +=" 		   , DATEDIFF(DAY, " +CRLF
	_cQry +=" 					  CASE WHEN MIN(Z0W.Z0W_DATA) = ISNULL(A.Z0F_DTPES,(SELECT MIN(B8_XDATACO) DIAS FROM " + RetSqlName("SB8") + " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "' AND B8_LOTECTL = '" + MV_PAR03 + "' AND D_E_L_E_T_ = ' 'GROUP BY B8_LOTECTL)) THEN DATEADD(DAY,1,MIN(Z0W.Z0W_DATA))" +CRLF
	_cQry +=" 		                   WHEN MIN(Z0W.Z0W_DATA) > ISNULL(A.Z0F_DTPES,(SELECT MIN(B8_XDATACO) DIAS FROM " + RetSqlName("SB8") + " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "' AND B8_LOTECTL = '" + MV_PAR03 + "' AND D_E_L_E_T_ = ' 'GROUP BY B8_LOTECTL )) THEN ISNULL(A.Z0F_DTPES,(SELECT MIN(B8_XDATACO)+1 DIAS FROM " + RetSqlName("SB8") + " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "' AND B8_LOTECTL = '" + MV_PAR03 + "' AND D_E_L_E_T_ = ' ' GROUP BY B8_LOTECTL )) " +CRLF
	_cQry +=" 			               ELSE MIN(Z0W.Z0W_DATA)  " +CRLF
	_cQry +=" 					  END , " +CRLF
	_cQry +=" 					  CASE WHEN MAX(Z0W.Z0W_DATA) = F.D2_EMISSAO  THEN MAX(Z0W.Z0W_DATA) " +CRLF
	_cQry +=" 			               ELSE DATEADD(DAY,-1,MAX(Z0W.Z0W_DATA)) " +CRLF
	_cQry +=" 					  END ) DIAS_COCHO " +CRLF
	_cQry +=" 		   , SUM(CASE WHEN Z0W_PESDIG = 0 THEN Z0W_QTDREA ELSE Z0W_PESDIG END ) CONSUMO " +CRLF
	_cQry +=" 	    FROM " + RetSqlName("Z0W") + " Z0W  " +CRLF
	_cQry +="  LEFT JOIN APARTACAO A ON  " +CRLF
	_cQry +=" 			 A.Z0F_FILIAL = Z0W_FILIAL " +CRLF
	_cQry +=" 		 AND A.Z0F_LOTE = Z0W_LOTE " +CRLF
	_cQry +=" 		JOIN FATURAMENTO F ON " +CRLF
	_cQry +=" 		     F.D2_FILIAL = Z0W.Z0W_FILIAL " +CRLF
	_cQry +=" 		 AND F.D2_LOTECTL = Z0W.Z0W_LOTE " +CRLF
	_cQry +=" 	   WHERE Z0W.Z0W_FILIAL = '" + FWxFilial("Z0W") + "' " +CRLF
	_cQry +=" 	     AND Z0W.Z0W_LOTE = '" + MV_PAR03 + "' " +CRLF
	_cQry +=" 		 AND Z0W.D_E_L_E_T_ = ' '  " +CRLF
	_cQry +=" 		 --AND Z0W.Z0W_DATA <> (SELECT MIN(Z0F_DTPES) Z0F_DTPES FROM " + RetSqlName("Z0F") + " Z0F WHERE Z0F_FILIAL = '" + FWxFilial("Z0F") + "' AND Z0F_LOTE = '" + MV_PAR03 + "' AND Z0F.D_E_L_E_T_ = ' ' ) " +CRLF
	_cQry +=" 		 GROUP BY Z0W.Z0W_FILIAL, Z0W.Z0W_LOTE, Z0F_DTPES, D2_EMISSAO " +CRLF
	_cQry +=" 		 ) " +CRLF
	_cQry +=" --		 SELECT * FROM TRATO " +CRLF
	_cQry +="  " +CRLF
	_cQry +="  " +CRLF
	_cQry +="  " +CRLF
	_cQry +="  , EMBARQUE AS ( " +CRLF
	_cQry +="      SELECT ZPB.ZPB_FILIAL, ZPB.ZPB_DATA, ZPB.ZPB_BAIA, SUM(ZPB.ZPB_PESOL) ZPB_PESOL " +CRLF
	_cQry +=" 	   FROM ZPB010 ZPB " +CRLF
	_cQry +=" 	   JOIN FATURAMENTO F ON " +CRLF
	_cQry +=" 	        ZPB.ZPB_FILIAL = F.D2_FILIAL " +CRLF
	_cQry +=" 	    AND ZPB.ZPB_DATA = F.D2_EMISSAO " +CRLF
	_cQry +=" 		AND ZPB.ZPB_BAIA = F.D2_LOTECTL " +CRLF
	_cQry +=" 	  WHERE ZPB.ZPB_FILIAL = '" + FWxFilial("SB8") + "' " +CRLF
	_cQry +=" 	    AND ZPB.ZPB_BAIA = '" + MV_PAR03 + "' " +CRLF
	_cQry +=" 		AND ZPB.D_E_L_E_T_ = ' '  " +CRLF
	_cQry +="    GROUP BY ZPB_FILIAL, ZPB_DATA, ZPB_BAIA " +CRLF
	_cQry +=" ) " +CRLF
	_cQry +="       SELECT DISTINCT F.D2_LOTECTL " +CRLF
	_cQry +=" 	       , SUM(F.D2_QUANT) D2_QUANT  " +CRLF
	_cQry +=" 		   , SUM(E.ZPB_PESOL) PESO_TOTAL " +CRLF
	_cQry +=" 		   , ISNULL(A.Z0F_PESO, (SELECT AVG(B8_XPESOCO) FROM " + RetSqlName("SB8") + " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "' AND B8_LOTECTL = '" + MV_PAR03 + "' AND D_E_L_E_T_ = ' ')) Z0F_PESO" +CRLF
	_cQry +=" 		   , ROUND(SUM(E.ZPB_PESOL)/SUM(F.D2_QUANT),2) PESO_FINAL " +CRLF
	_cQry +=" 		   , D.DATA_INI " +CRLF
	_cQry +=" 		   , D.DATA_FIM " +CRLF
	_cQry +=" 		   , D.DIAS_COCHO " +CRLF
	_cQry +=" 		   , ROUND(((SUM(E.ZPB_PESOL)/SUM(F.D2_QUANT))-ISNULL(A.Z0F_PESO, (SELECT AVG(B8_XPESOCO) FROM " + RetSqlName("SB8") + " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "' AND B8_LOTECTL = '" + MV_PAR03 + "' AND D_E_L_E_T_ = ' ')))/D.DIAS_COCHO,3) AS GMD " +CRLF
	_cQry +=" 		   , AL.CMS " +CRLF
	_cQry +=" 		   , ROUND(AL.CMS/((ISNULL(A.Z0F_PESO, (SELECT AVG(B8_XPESOCO) FROM " + RetSqlName("SB8") + " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "' AND B8_LOTECTL = '" + MV_PAR03 + "' AND D_E_L_E_T_ = ' '))+SUM(E.ZPB_PESOL)/SUM(F.D2_QUANT))/2)*100,2) CMSPV " +CRLF
	_cQry +=" 		   , ROUND(AL.CMS/ROUND(((SUM(E.ZPB_PESOL)/SUM(F.D2_QUANT))-ISNULL(A.Z0F_PESO, (SELECT AVG(B8_XPESOCO) FROM " + RetSqlName("SB8") + " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "' AND B8_LOTECTL = '" + MV_PAR03 + "' AND D_E_L_E_T_ = ' ')))/D.DIAS_COCHO,3),2) CA " +CRLF
	_cQry +=" 		   , AL.Z05_CABECA " +CRLF
	_cQry +=" 		   , ROUND(AL.REALIZADO / D.DIAS_COCHO,3) CONS_MN " +CRLF
	_cQry +=" 		   , AL.MAT_SECA " +CRLF
	_cQry +=" 		   , ROUND(AL.MAT_SECA / D.DIAS_COCHO,2) KGMSDI " +CRLF
	_cQry +=" 		   , AL.REALIZADO " +CRLF
	_cQry +="         FROM FATURAMENTO F " +CRLF
	_cQry +="    LEFT JOIN APARTACAO A ON  " +CRLF
	_cQry +="              F.D2_FILIAL = A.Z0F_FILIAL " +CRLF
	_cQry +=" 	     AND F.D2_LOTECTL = A.Z0F_LOTE " +CRLF
	_cQry +="    LEFT JOIN EMBARQUE E ON  " +CRLF
	_cQry +="              E.ZPB_FILIAL = F.D2_FILIAL " +CRLF
	_cQry +=" 		 AND E.ZPB_BAIA = F.D2_LOTECTL " +CRLF
	_cQry +=" 		 AND E.ZPB_DATA = F.D2_EMISSAO " +CRLF
	_cQry +="    LEFT JOIN DIAS D ON " +CRLF
	_cQry +=" 		     D.Z0W_FILIAL = F.D2_FILIAL " +CRLF
	_cQry +=" 		 AND D.Z0W_LOTE = F.D2_LOTECTL " +CRLF
	_cQry +="    LEFT JOIN ALIMENTACAO AL ON " +CRLF
	_cQry +=" 			 AL.Z06_LOTE = F.D2_LOTECTL " +CRLF
	_cQry +="     GROUP BY D2_LOTECTL, A.Z0F_PESO , D.DATA_INI, D.DATA_FIM, D.DIAS_COCHO, D.CONSUMO, AL.CMS, AL.MAT_SECA, AL.REALIZADO, AL.Z05_CABECA " +CRLF

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
 | Obs.     : U_PCPREL02()                                                         |
 '---------------------------------------------------------------------------------*/
Static Function fQuadro1()

Local nRegistros	:= 0 // MV_PAR02 - MV_PAR01
Local cXML 			:= ""
Local cWorkSheet 	:= "" // "Diária"

Local cLote  		:= ""

(_cAliasG)->(DbEval({|| nRegistros++ }))

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	cWorkSheet := "Geral" // AllTrim((_cAliasG)->Z0W_LOTE)

	cXML += U_prtCellXML( 'Worksheet', cWorkSheet )

	cXML += ' <Names>'+CRLF
	cXML += ' <NamedRange ss:Name="_FilterDatabase" '+CRLF
	cXML += ' 	ss:RefersTo="='+cWorkSheet+'!R3C1:R'+cValToChar(nRegistros+1)+'C8"'+CRLF
	cXML += ' 	ss:Hidden="1"/>'+CRLF
	cXML += ' </Names>'+CRLF

	cXML += U_prtCellXML( 'Table' )

	cXML += '<Column ss:Width="49.5"/>'+CRLF
    cXML += '<Column ss:Width="51.75"/>'+CRLF
    cXML += '<Column ss:Width="57.75"/>'+CRLF
    cXML += '<Column ss:Width="80.25" ss:Span="4"/>'+CRLF
    cXML += '<Column ss:Index="9" ss:Width="168.75"/>'+CRLF
    cXML += '<Column ss:Width="60.75" ss:Span="2"/>'+CRLF
    cXML += '<Column ss:Index="13" ss:Width="63" ss:Span="8"/>'+CRLF

	cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '25'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)

	// SOMA
	cXML += U_prtCellXML( 'Row' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'13'/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', "=SUBTOTAL(9,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', "=SUBTOTAL(9,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'20'/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	If MV_PAR07 == 2
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(9,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(9,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    /*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[2]C:R["+cValToChar(nRegistros+1)+"]C)" /*cFormula*/, )
	EndIf
	
	cXML += U_prtCellXML( '</Row>' )

	// Titulo
	cXML += U_prtCellXML( 'Row',,'33' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Lote'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Sexo' 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Raça' 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data' 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Curral' 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Vivo Inicial (PVI)',,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'P.V. Total' 			,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Atual' 			,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Cabeças' 			,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dias de Cocho'		,,.T. )
	//cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Plano Nutricional' 	,,.T. )
	//cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Receita' 			,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Desrição' 	,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qt. Trato' 			,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Previsto' 			,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Realizado' 			,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, '% MS' 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CMN Previsto' 		,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CMN Realizado' 		,,.T. )
    cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Nota Noite'  		,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Nota Manhã'  		,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CMS Previsto' 		,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CMS Realizado' 		,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Mega Cal Prev.' 	,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Mega Cal Real.' 	,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CMS % PV Previsto' 	,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CMS % PV Realizado' 	,,.T. )
    
	If MV_PAR07 == 2
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtd Apontada' 	,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Custo Total' 	,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$ Cabeça' 	,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$ KG MN' 	,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'RS KG MS' 	,,.T. )
	EndIf
	cXML += U_prtCellXML( '</Row>' )

	//fQuadro1
	While !(_cAliasG)->(Eof())
0
		cXML += U_prtCellXML( 'Row' )
	/*01*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z06_LOTE ),,.T. ) // LOTE
	/*01*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->B1_X_SEXO ),,.T. ) // LOTE
	/*01*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->B1_XRACA ),,.T. ) // LOTE
	/*02*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData', 'DateTime', /*cFormula*/, U_FrmtVlrExcel( SToD( (_cAliasG)->Z05_DATA ) ),,.T. ) // DATA
	/*03*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_CURRAL ),,.T. ) // CURRAL
	/*04*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_PESOCO),,.T. ) // PVI
	/*05*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/ "=IFERROR(RC[-1]*RC[2],0)",) // PV TOTAL
	/*06*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/ "=IFERROR(RC[-2]+" + AllTrim(Str((_cAliasG)->Z0O_GMD)) + "*RC[2],0)"          ,,.T. ) // PESO ATUAL
	/*07*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_CABECA ),,.T. ) // NRO CABEï¿½AS
	/*08*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_DIASDI ),,.T. )
	///*09*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0M_DESCRI ),,.T. )
	/*10*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_DIETA ),,.T. )
	/*11*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_NROTRA ),,.T. )
	/*12*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->PREVISTO ),,.T. )
	/*13*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->REALIZADO ),,.T. )
	/*14*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->PERC_MS),,.T. )
	/*15*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->CMN_PREVISTO ),,.T. )
	If MV_PAR08 == 1
	/*16*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->CMN_REALIZADO ),,.T. )
	else 
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'	, /*cFormula*/ "=IFERROR(RC[-3]/RC[-8],0)",)
	endIf
	/*16*/	
	/*17*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0I_NOTTAR ),,.T. )
	/*18*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z0I_NOTMAN ),,.T. )
	/*19*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->Z05_KGMSDI ),,.T. )
    If MV_PAR08 == 1
	/*20*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->CMS_REALIZADO ),,.T. )
	ELSE 
	/*20*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'	, /*cFormula*/ "=IFERROR(RC[-4] * (RC[-6]/100),0)",)
	END IF
	/*20*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->MEGACALP ),,.T. )
	/*21*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'	, /*cFormula*/ "=IFERROR(RC[-1]/RC[-10]*RC[-9],0)",)
	///*21*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->MEGACALR ),,.T. )
	/*21*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'	, /*cFormula*/ "=IFERROR(RC[-4]/RC[-16]*100,0)",)
	/*22*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'	, /*cFormula*/ "=IFERROR(RC[-4]/RC[-17]*100,0)",)
	   		If MV_PAR07 == 2
	/*23*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'	, /*cFormula*/ U_FrmtVlrExcel( (_cAliasG)->QTD_RACAO),,.T. )
	/*24*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'	, /*cFormula*/ U_FrmtVlrExcel( (_cAliasG)->CUSTO_TOTA),,.T. )
	/*25*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'	, /*cFormula*/ U_FrmtVlrExcel( (_cAliasG)->CUSTO_ANIM),,.T. )
	/*26*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'	, /*cFormula*/ "=IFERROR(RC[-2]/RC[-3],0)",)
	/*27*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'	, /*cFormula*/ "=IFERROR(RC[-1]/(RC[-15]/100),0)",)
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
    cXML += ' <AutoFilter x:Range="R3C1:R'+cValToChar(nRegistros+1)+'C20"'+CRLF
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

Static Function fQuadro2()

Local nRegistros	:= 0 // MV_PAR02 - MV_PAR01
Local cXML 			:= ""
Local cWorkSheet 	:= "" // "Diária"
Local nQtd     := 0
Local nPesoE   := 0
Local nPesoS   := 0
Local nPesoL   := 0
Local nPeso    := 0
Local nQuant   := 0

Local cLote  		:= ""

(_cAliasS)->(DbEval({|| nRegistros++ }))

//(_cAliasE)->(DbEval({|| nRegistros++ }))
cWorkSheet := "Resumo" // AllTrim((_cAliasG)->Z0W_LOTE)
(_cAliasS)->(DbGoTop()) 
If !(_cAliasS)->(Eof())

	

	cXML += U_prtCellXML( 'Worksheet', cWorkSheet )

	cXML += ' <Names>'+CRLF
	cXML += ' <NamedRange ss:Name="_FilterDatabase" '+CRLF
	cXML += ' 	ss:RefersTo="='+cWorkSheet+'!R3C1:R'+cValToChar(nRegistros+1)+'C21"'+CRLF
	cXML += ' 	ss:Hidden="1"/>'+CRLF
	cXML += ' </Names>'+CRLF

	cXML += U_prtCellXML( 'Table' )

 cXML += '<Column ss:Width="51.75" ss:Span="1"/>'
 cXML += '<Column ss:Index="3" ss:Width="58.5" ss:Span="1"/>'
 cXML += '<Column ss:Index="5" ss:Width="53.25"/>'
 cXML += '<Column ss:Width="72.75"/>'
 cXML += '<Column ss:Width="64.5"/>'
 cXML += '<Column ss:Width="57.75"/>'
 cXML += '<Column ss:Width="54.75"/>'
 cXML += '<Column ss:Width="52.5"/>'
 cXML += '<Column ss:Index="12" ss:AutoFitWidth="0" ss:Width="60"/>'
 cXML += '<Column ss:Width="63" ss:Span="8"/>	'

	cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '3'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, "Saldo Atual do Estoque"/* cInfo */, /* cPanes */)

	// Titulo
	cXML += U_prtCellXML( 'Row',,'33' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Lote'				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Saldo' 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Curral' 				,,.T. )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Médio'          ,,.T. )
	
	cXML += U_prtCellXML( '</Row>' )

	//fQuadro1
	While !(_cAliasS)->(Eof())
0
		cXML += U_prtCellXML( 'Row' )
	/*01*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/,  U_FrmtVlrExcel( (_cAliasS)->B8_LOTECTL  ),,.T. ) // LOTE
	/*02*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/,  U_FrmtVlrExcel( (_cAliasS)->B8_SALDO    ),,.T. ) // CURRAL
	/*03*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/,  U_FrmtVlrExcel( (_cAliasS)->B8_X_CURRA  ),,.T. ) // LOTE
	/*04*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/,  U_FrmtVlrExcel( (_cAliasS)->B8_XPESOCO  ),,.T. ) // PVI	
	    cXML += U_prtCellXML( '</Row>' )
		
		(_cAliasS)->(DbSkip())
	
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""

	EndDo
	
	cXML += U_prtCellXML( 'pulalinha','3' )
	(_cAliasA)->(DbEval({|| nRegistros++ }))		
	
	(_cAliasA)->(DbGoTop()) 

	If !(_cAliasA)->(Eof())
	    cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '12'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, "Apartação" /* cInfo */, /* cPanes */)
		cXML += U_prtCellXML( 'Row',,'33' )
		
		
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,'2'/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Fornecedor'           ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,'1'/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Nome Corretor'        ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Contrato'             ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Pedido' 				,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Lote' 				,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Curral' 				,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data'				    ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtde'     	        ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Total'           ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Médio' 			,,.T. )
		
		
		
		
		
		cXML += U_prtCellXML( '</Row>' )
	
	 //cXML += U_prtCellXML( 'pulalinha','1' )
    nPeso := 0
	nQuant := 0
		While !(_cAliasA)->(Eof())

		cXML += U_prtCellXML( 'Row' )
		/*03*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,'2'/*cMergeAcross*/,'sTexto'  , 'String'   , /*cFormula*/, U_FrmtVlrExcel( (_cAliasA)->A2_NOME      	   ),,.T. ) // LOTE
		/*03*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,'1'/*cMergeAcross*/,'sTexto'  , 'String'   , /*cFormula*/, U_FrmtVlrExcel( (_cAliasA)->ZCC_NOMCOR  	   ),,.T. ) // LOTE
		/*03*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'sTexto'  , 'String'   , /*cFormula*/, U_FrmtVlrExcel( (_cAliasA)->ZBC_CODIGO  	   ),,.T. ) // LOTE
		/*03*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'sTexto'  , 'String'   , /*cFormula*/, U_FrmtVlrExcel( (_cAliasA)->ZBC_PEDIDO  	   ),,.T. ) // LOTE
		/*01*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'sTexto'  , 'String'   , /*cFormula*/, U_FrmtVlrExcel( (_cAliasA)->Z0F_LOTE          ),,.T. ) // DATA
		/*02*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'sTexto'  , 'String'   , /*cFormula*/, U_FrmtVlrExcel( (_cAliasA)->Z0F_CURRAL  	   ),,.T. ) // CURRAL
		/*04*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'sData'   , 'DateTime' , /*cFormula*/, U_FrmtVlrExcel( SToD((_cAliasA)->Z0F_DTPES )  ),,.T. ) // PVI	
		/*04*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'sComDig' , 'Number'   , /*cFormula*/, U_FrmtVlrExcel( (_cAliasA)->QTDE 	           ),,.T. ) // PVI	
		/*02*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'sComDig' , 'Number'   , /*cFormula*/, U_FrmtVlrExcel( (_cAliasA)->Z0F_PESO  	       ),,.T. ) // CURRAL
		/*02*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,   /*cMergeAcross*/,'sComDig' , 'Number'   , /*cFormula*/, U_FrmtVlrExcel( (_cAliasA)->PESO_MEDIO        ),,.T. ) // CURRAL
		cXML += U_prtCellXML( '</Row>' )
		nPeso +=  (_cAliasA)->Z0F_PESO
		nQuant += (_cAliasA)->QTDE
		
			(_cAliasA)->(DbSkip())
		
		EndDo
		
			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'11',/*cMergeAcross*/, 'sComDig' , 'Number'   , /*cFormula*/,  U_FrmtVlrExcel(nQuant       ),,.T. ) // CURRAL
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'12',/*cMergeAcross*/, 'sComDig' , 'Number'   , /*cFormula*/,  U_FrmtVlrExcel(nPeso        ),,.T. ) // CURRAL
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'13',/*cMergeAcross*/, 'sComDig' , 'Number'   , /*cFormula*/,  U_FrmtVlrExcel(nPeso/nQuant ),,.T. ) // CURRAL
		cXML += U_prtCellXML( '</Row>' )
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
	EndIf

	cXML += U_prtCellXML( 'pulalinha','3' )
	(_cAliasF)->(DbEval({|| nRegistros++ }))		
	
	(_cAliasF)->(DbGoTop()) 

	If !(_cAliasF)->(Eof())
	    cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '11'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, "Resumo Faturamento" /* cInfo */, /* cPanes */)
		cXML += U_prtCellXML( 'Row',,'33' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Filial'				   ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Emissao NF' 			   ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Nota Fiscal' 		   ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Lote' 			       ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtde'     	           ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Entrada'           ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Hora Entrada'           ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Saida'             ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Hora Saida'             ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Liquido'           ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Numero GTA'             ,,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,'2'/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Motorista'           ,,.T. )


		cXML += U_prtCellXML( '</Row>' )
	
	 //cXML += U_prtCellXML( 'pulalinha','1' )
		nQtd     := 0
		nPesoE   := 0
		nPesoS   := 0
		nPesoL   := 0
		While !(_cAliasF)->(Eof())

			cXML += U_prtCellXML( 'Row' )
		
		/*02*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->D2_FILIAL  	               ),,.T. ) // CURRAL
		/*01*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData'  , 'DateTime', /*cFormula*/, U_FrmtVlrExcel( SToD( (_cAliasF)->D2_EMISSAO )         ),,.T. ) // DATA
		/*02*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->D2_DOC  	               ),,.T. ) // CURRAL	
		/*02*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->D2_LOTECTL  	           ),,.T. ) // CURRAL	
		/*03*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->D2_QUANT  	               ),,.T. ) // LOTE
		/*04*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->ZPB_PESOE 		           ),,.T. ) // PVI	
		/*02*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->ZPB_HORA  	               ),,.T. ) // CURRA
		/*04*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->ZPB_PESOS 	               ),,.T. ) // PVI	
		/*02*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->ZPB_HORAF    	           ),,.T. ) // CURRA
		/*04*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->PESO 		               ),,.T. ) // PVI	
		/*02*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->ZPB_NROGTA  	           ),,.T. ) // CURRAL	
		/*02*/	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,'2'/*cMergeAcross*/,'sTexto' , 'String'  , /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->ZPB_NOMMOT  	           ),,.T. ) // CURRAL	
			cXML += U_prtCellXML( '</Row>' )
			nQtd   += (_cAliasF)->D2_QUANT
			nPesoE += (_cAliasF)->ZPB_PESOE
			nPesoS += (_cAliasF)->ZPB_PESOS
			nPesoL += (_cAliasF)->PESO

			(_cAliasF)->(DbSkip())
		
			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
			EndIf
			cXML := ""

		EndDo
	
	//IMPRIMIR TOTAIS
	cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'5',/*cMergeAcross*/, 'sComDig' , 'Number'   , /*cFormula*/,  U_FrmtVlrExcel(nQtd   ),,.T. ) // CURRAL
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'6',/*cMergeAcross*/, 'sComDig' , 'Number'   , /*cFormula*/,  U_FrmtVlrExcel(nPesoE ),,.T. ) // CURRAL
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'8',/*cMergeAcross*/, 'sComDig' , 'Number'   , /*cFormula*/,  U_FrmtVlrExcel(nPesoS ),,.T. ) // CURRAL
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'10',/*cMergeAcross*/,'sComDig' , 'Number'   , /*cFormula*/,  U_FrmtVlrExcel(nPesoL ),,.T. ) // CURRAL
	cXML += U_prtCellXML( '</Row>' )

	EndIf

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
    //cXML += ' <AutoFilter x:Range="R3C1:R'+cValToChar(nRegistros+1)+'C20"'+CRLF
    //cXML += '  xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
    //cXML += ' </AutoFilter>'+CRLF
    cXML += '</Worksheet>'+CRLF
 
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""
	
EndIf	

Return nil
// FIM: fQuadro2 - U_PCPREL02()


Static Function fQuadro3()

Local nRegistros	:= 0 // MV_PAR02 - MV_PAR01
Local cXML 			:= ""
Local cWorkSheet 	:= "" // "Diária"

Local cLote  		:= ""

(_cAliasE)->(DbEval({|| nRegistros++ }))

(_cAliasE)->(DbGoTop()) 
If !(_cAliasE)->(Eof())

	cWorkSheet := "Embarque" // AllTrim((_cAliasG)->Z0W_LOTE)

	cXML += U_prtCellXML( 'Worksheet', cWorkSheet )

	cXML += ' <Names>'+CRLF
	cXML += ' <NamedRange ss:Name="_FilterDatabase" '+CRLF
	cXML += ' 	ss:RefersTo="='+cWorkSheet+'!R3C1:R'+cValToChar(nRegistros+1)+'C3"'+CRLF
	cXML += ' 	ss:Hidden="1"/>'+CRLF
	cXML += ' </Names>'+CRLF

	cXML += U_prtCellXML( 'Table' )

	cXML += '<Column ss:Width="80"/>'+CRLF
    cXML += '<Column ss:Width="80"/>'+CRLF
    

	cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '1'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, "DADOS EMBARQUE"/* cInfo */, /* cPanes */)

	

	//fQuadro1
	While !(_cAliasE)->(Eof())

		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Lote'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasE)->D2_LOTECTL ),,.T. ) // LOTE
		cXML += U_prtCellXML( '</Row>' )

		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtde'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasE)->D2_QUANT ),,.T. ) // LOTE
		cXML += U_prtCellXML( '</Row>' )
		
		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Total'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasE)->PESO_TOTAL ),,.T. ) // LOTE
		cXML += U_prtCellXML( '</Row>' )
		
		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Inicial'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasE)->Z0F_PESO ),,.T. ) // LOTE
		cXML += U_prtCellXML( '</Row>' )
		
		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Final'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasE)->PESO_FINAL ),,.T. ) // LOTE
		cXML += U_prtCellXML( '</Row>' )
		
		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data Inicio'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData', 'DateTime', /*cFormula*/, U_FrmtVlrExcel(  (_cAliasE)->DATA_INI ),,.T. ) // DATA
		cXML += U_prtCellXML( '</Row>' )
		
		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data Fim'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData', 'DateTime', /*cFormula*/, U_FrmtVlrExcel(  (_cAliasE)->DATA_FIM ),,.T. ) // DATA
		cXML += U_prtCellXML( '</Row>' )
		
		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dias Cocho'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel(  (_cAliasE)->DIAS_COCHO  ),,.T. ) // DATA
		cXML += U_prtCellXML( '</Row>' )
		
		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'GMD'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasE)->GMD  ),,.T. ) // DATA
		cXML += U_prtCellXML( '</Row>' )
		
		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CMS'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel(  (_cAliasE)->CMS  ),,.T. ) // DATA
		cXML += U_prtCellXML( '</Row>' )
		
		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CMS PV%'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel(  (_cAliasE)->CMSPV ),,.T. ) // DATA
		cXML += U_prtCellXML( '</Row>' )
		
		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'C.A.'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel(  (_cAliasE)->CA  ),,.T. ) // DATA
		cXML += U_prtCellXML( '</Row>' )
		
		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Total Diarias'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasE)->Z05_CABECA ),,.T. ) // DATA
		cXML += U_prtCellXML( '</Row>' )

		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Consumo Diario MN'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasE)->CONS_MN ),,.T. ) // DATA
		cXML += U_prtCellXML( '</Row>' )

		cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Consumo Diario MS'				,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasE)->KGMSDI ),,.T. ) // DATA
		cXML += U_prtCellXML( '</Row>' )

		(_cAliasE)->(DbSkip())
		

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
    cXML += '</Worksheet>'+CRLF
 
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""
	
EndIf	

Return nil
// FIM: fQuadro3 - U_PCPREL02()
