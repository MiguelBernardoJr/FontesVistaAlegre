// este fonte nao foi terminado. foi iniciado o desenvolvimento desse projeto porem nao terminado, devido a ter sido priorisado outras demandas.

#include 'fileio.ch'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
/*
#IFNDEF _ENTER_
	#DEFINE _ENTER_ (Chr(13)+Chr(10))
	// Alert("miguel")
#ENDIF 
*/

/*--------------------------------------------------------------------------------,
 | Principal: 					U_MBCOMR01()          		            	      |
 | Func:  MBCOMR01()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  11.05.2018	            	          	            	              |
 | Desc:  Função principal, chamada pelo MENU.           	            	      |
 '--------------------------------------------------------------------------------|
 | Alt:   No dia 25.06.2018 converti o relatorio para formulas.	            	  |
 | Obs.:  antigo: U_VACOMR07()                                                    |
 '--------------------------------------------------------------------------------*/
User function MBCOMR01()

Local cTimeIni	 	:= Time()
Local lTemDados		:= .T.
Local cStyle		:= ""
Local cXML	   		:= ""

Private cPerg		:= "MBCOMR01"
Private cTitulo  	:= "Relatorio Lotes de Compra - Analise"

Private cPath 	 	:= "C:\totvs_relatorios\"

Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()
Private _nRegAba1	:= 0

Private _cAliasNF	:= GetNextAlias()   
Private _nRegAba2	:= 0

Private nHandle    	:= 0
Private nHandAux	:= 0

// Private dDIni11F   := sToD("")// := MV_PAR13-7 // (30*1) // 6 Meses, 30 Dias

GeraX1(cPerg)
	
If Pergunte(cPerg, .T.)

	If MV_PAR20 == 0
		MV_PAR20 := MV_PAR13-MV_PAR12
	EndIf

	// dDIni11F   := MV_PAR13-MV_PAR20 // (30*1) // 6 Meses, 30 Dias
	
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
		
		cStyle := U_defStyle()
		
		// Processar SQL
		FWMsgRun(, {|| lTemDados := procesaSQL("Geral", @_cAliasG ) },'Por Favor Aguarde...' , 'Processando Banco de Dados-Lotes')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fPrintAba1() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Lotes')
			
			FWMsgRun(, {|| lTemDados := procesaSQL("NFiscal", @_cAliasNF ) },'Por Favor Aguarde...' , 'Processando Banco de Dados-Notas Fiscais')
			If lTemDados
				FWMsgRun(, {|| fPrintAba2() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Notas Fiscais')
			EndIf
			(_cAliasNF)->(DbCloseArea())
			
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

return nil	// U_MBCOMR01()
// FIM MBCOMR01



/*--------------------------------------------------------------------------------,
 | Principal: 					U_MBCOMR01()             	            	      |
 | Func:  GeraX1()  	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  11.05.2018	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local i         := 0
Local j         := 0 
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

aAdd(aRegs,{cPerg, "01", "Data Compra De?"              , "", "", "MV_CH1", "D", TamSX3("D1_EMISSAO")[1], TamSX3("D1_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR01", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Data Compra Ate?"             , "", "", "MV_CH2", "D", TamSX3("D1_EMISSAO")[1], TamSX3("D1_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR02", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "03", "Filial De?"    		        , "", "", "MV_CH3", "C", TamSX3("D1_FILIAL")[1] , TamSX3("D1_FILIAL")[2] , 0, "G", ""		 , "MV_PAR03", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "04", "Filial Ate?"    		        , "", "", "MV_CH4", "C", TamSX3("D1_FILIAL")[1] , TamSX3("D1_FILIAL")[2] , 0, "G", "NaoVazio", "MV_PAR04", ""   , "","","ZZ"	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "05", "Contrato De?"    		        , "", "", "MV_CH5", "C", TamSX3("ZBC_CODIGO")[1], TamSX3("ZBC_CODIGO")[2], 0, "G", ""		 , "MV_PAR05", ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "06", "Contrato Ate?"   		        , "", "", "MV_CH6", "C", TamSX3("ZBC_CODIGO")[1], TamSX3("ZBC_CODIGO")[2], 0, "G", "NaoVazio", "MV_PAR06", ""   , "","","ZZZZZZ","",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "07", "Ped. Compra De?"		        , "", "", "MV_CH7", "C", TamSX3("ZBC_PEDIDO")[1], TamSX3("ZBC_PEDIDO")[2], 0, "G", ""		, "mv_par07" , ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","SC7","","","","",""})
aAdd(aRegs,{cPerg, "08", "Ped. Compra Ate?"		        , "", "", "MV_CH8", "C", TamSX3("ZBC_PEDIDO")[1], TamSX3("ZBC_PEDIDO")[2], 0, "G", "NaoVazio", "mv_par08", ""   , "","","ZZZZZZ","",""   ,"","","","","","","","","","","","","","","","","","","SC7","","","","",""})
aAdd(aRegs,{cPerg, "09", "Fornecedor De?"		        , "", "", "MV_CH9", "C", TamSX3("ZBC_CODFOR")[1], TamSX3("ZBC_CODFOR")[2], 0, "G", ""		, "mv_par09" , ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","SA2","","","","",""})
aAdd(aRegs,{cPerg, "10", "Fornecedor Ate?"		        , "", "", "MV_CHA", "C", TamSX3("ZBC_CODFOR")[1], TamSX3("ZBC_CODFOR")[2], 0, "G", "NaoVazio", "mv_par10", ""   , "","","ZZZZZZ","",""   ,"","","","","","","","","","","","","","","","","","","SA2","","","","",""})
aAdd(aRegs,{cPerg, "11", "Baia: (Separado por virgula)" , "", "", "MV_CHB", "C", 					  99, 					    0, 0, "G", ""		, "mv_par11" , ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "12", "Data Abate De?"               , "", "", "MV_CHC", "D", TamSX3("D2_EMISSAO")[1], TamSX3("D2_EMISSAO")[2], 0, "G", "        ", "MV_PAR12", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "13", "Data Abate Ate?"              , "", "", "MV_CHD", "D", TamSX3("D2_EMISSAO")[1], TamSX3("D2_EMISSAO")[2], 0, "G", "        ", "MV_PAR13", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "14", "Imprime Emergencia?"          , "", "", "MV_CHE", "N", 					   1,					    0, 1, "C", ""        , "MV_PAR14", "Não", "","",""      ,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "15", "Imprime Outras Movimentacoes?", "", "", "MV_CHF", "N", 					   1,					    0, 1, "C", ""        , "MV_PAR15", "Não", "","",""      ,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "16", "Exibe Auxiliares?"			, "", "", "MV_CHG", "N", 					   1,					    0, 1, "C", ""        , "MV_PAR16", "Não", "","",""      ,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "17", "Data Valor?"		    		, "", "", "MV_CHH", "D", TamSX3("ZSI_DATA")[1]  , TamSX3("ZSI_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR17", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","ZSI","","","","",""})
aAdd(aRegs,{cPerg, "18", "Codigo?"        				, "", "", "MV_CHI", "C", TamSX3("ZCI_CODIGO")[1], TamSX3("ZCI_CODIGO")[2], 0, "G", "NaoVazio", "MV_PAR18", ""   , "","",""  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "19", "Valor?"        				, "", "", "MV_CHJ", "N", TamSX3("ZSI_VALOR")[1] , TamSX3("ZSI_VALOR")[2] , 0, "G", "NaoVazio", "MV_PAR19", ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "20", "Qt. Dias Ração x Data ?"      , "", "", "MV_CHK", "N",                       3,                       0, 0, "G", "NaoVazio", "MV_PAR20", ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "21", "ICMS a recuperar? %"			, "", "", "MV_CHL", "N",                       3,                       0, 0, "G", "NaoVazio", "MV_PAR21", ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "22", "Somente os Faturados?"		, "", "", "MV_CHM", "N",                       1,                       0, 2, "C", "NaoVazio", "MV_PAR22", "Não", "","",""	  	,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})

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
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function procesaSQL(cTipo, _cAlias)
Local _cQry 		:= ""

_cQry := " WITH FATURAMENTO AS " + CRLF
_cQry += " (" + CRLF
_cQry += " 	SELECT D2_FILIAL, D2_COD, D2_LOTECTL, D2_EMISSAO " + CRLF
_cQry += "   			, SUM(D2_QUANT) D2_QUANT " + CRLF
_cQry += "   			, ISNULL(SUM(D1_QUANT),0) QUANT_DEVOL " + CRLF
_cQry += " 	FROM      SD2010 D2 " + CRLF
_cQry += " 			JOIN SF4010 F4 ON F4_FILIAL=' ' AND F4_CODIGO=D2_TES AND F4_TRANFIL <> '1' AND F4.D_E_L_E_T_=' ' " + CRLF
_cQry += " 			JOIN ZAB010 AB ON ZAB_FILIAL=D2_FILIAL AND ZAB_CODIGO=D2_XCODABT AND AB.ZAB_EMERGE <> '1' AND AB.ZAB_OUTMOV <> '1' AND D2.D2_LOTECTL <> ' ' AND D2.D_E_L_E_T_=' ' AND AB.D_E_L_E_T_=' ' " + CRLF
_cQry += " 	LEFT JOIN SD1010 D1 ON D2_FILIAL=D1_FILORI AND D2_DOC=D1_NFORI AND D2_SERIE=D1_SERIORI AND D2_EMISSAO=D1_DATORI AND D2_LOTECTL=D1_LOTECTL AND D1_TIPO ='D' AND D1.D_E_L_E_T_	=' ' " + CRLF
_cQry += " 	WHERE   D2_EMISSAO BETWEEN '" + dToS(MV_PAR12) + "' AND '" + dToS(MV_PAR13) + "' " + CRLF
_cQry += "  	AND D2_TIPO='N' " + CRLF
_cQry += " 	GROUP BY D2_FILIAL, D2_COD, D2_LOTECTL, D2_EMISSAO " + CRLF
_cQry += " ), " + CRLF
_cQry += CRLF
_cQry += " CONTRATO AS " + CRLF
_cQry += " ( " + CRLF
_cQry += " 	SELECT  	DISTINCT" + CRLF
_cQry += " 				ZBC_FILIAL					   	   FILIAL, " + CRLF
_cQry += "  			ZBC_CODIGO						   COD_CONTRATO, " + CRLF
_cQry += "  			ZBC_PEDIDO					       NUMERO_LOTE, " + CRLF
_cQry += " 				ZBC_ITEMPC, " + CRLF
_cQry += "  			ZBC_CODFOR					       CODIGO_FORNEC, " + CRLF
_cQry += "  			ZBC_LOJFOR						   LOJA_FORNEC, " + CRLF
_cQry += "  			A2.A2_NOME					       VENDEDOR, " + CRLF
_cQry += "  			A2_MUN						       ORIGEM, " + CRLF
_cQry += "  			A2_EST						       ESTADO, " + CRLF
_cQry += "  			ZBC_X_CORR					       COD_CORRETOR, " + CRLF
_cQry += "  			A3_NOME							   CORRETOR, " + CRLF
_cQry += "  			ZBC_PRODUT					       CODIGO_BOV, " + CRLF
_cQry += "  			ZBC_PRDDES					       DESCRICAO, " + CRLF
_cQry += "  			BC.ZBC_QUANT				       QTD_COMPRA, " + CRLF
_cQry += " 			/* CASE WHEN BC.ZBC_RACA='N'  THEN 'NELORE' " + CRLF
_cQry += "  					WHEN BC.ZBC_RACA='A'  THEN 'ANGUS' " + CRLF
_cQry += "  					WHEN BC.ZBC_RACA='M'  THEN 'MESTICO' " + CRLF
_cQry += "  											ELSE 'VERIFICAR' " + CRLF
_cQry += "  											END AS RACA, " + CRLF
_cQry += "  				CASE WHEN BC.ZBC_SEXO='M'  THEN 'MACHO' " + CRLF
_cQry += "  					WHEN BC.ZBC_SEXO='F'  THEN 'FEMEA' " + CRLF
_cQry += " 					WHEN BC.ZBC_SEXO='C'  THEN 'CAPAO'" + CRLF
_cQry += "  											ELSE 'VERIFICAR' " + CRLF
_cQry += "  											END AS SEXO, " + CRLF
_cQry += " 				CASE WHEN ZCC_PAGFUT='S'   THEN 'SIM' " + CRLF
_cQry += " 	          								ELSE 'NÃO' " + CRLF
_cQry += " 	        								END AS PGTO_FUTURO, 	" + CRLF
_cQry += " 				CASE WHEN BC.ZBC_TPNEG	='P' THEN 'PESO' " + CRLF
_cQry += "  					WHEN BC.ZBC_TPNEG	='K' THEN 'KG' " + CRLF
_cQry += "  					WHEN BC.ZBC_TPNEG	='Q' THEN 'CABECA' " + CRLF
_cQry += "  											ELSE 'VERIFICAR' " + CRLF
_cQry += "  											END AS TIPO_NEGOCIA, " + CRLF
_cQry += " 				CASE WHEN ZBC_PEDPOR='P'   THEN 'PAUTA' " + CRLF
_cQry += "  			 								ELSE 'NEGOCIACAO' " + CRLF
_cQry += "  			 								END AS PEDIDO_POR, " + CRLF
_cQry += "  				CASE WHEN ZBC_TEMFXA='S'   THEN 'SIM' " + CRLF
_cQry += "  			  								ELSE 'NÃO' " + CRLF
_cQry += "  			  								END AS TEM_FAIXA, ZBC_FAIXA, */" + CRLF
_cQry += " 			CASE WHEN IC.ZIC_RACA='N'  THEN 'NELORE' " + CRLF
_cQry += "  					WHEN IC.ZIC_RACA='A'  THEN 'ANGUS' " + CRLF
_cQry += "  					WHEN IC.ZIC_RACA='M'  THEN 'MESTICO' " + CRLF
_cQry += "  										ELSE 'VERIFICAR' " + CRLF
_cQry += "  										END AS RACA, " + CRLF
_cQry += "  			CASE WHEN IC.ZIC_SEXO='M'  THEN 'MACHO' " + CRLF
_cQry += "  					WHEN IC.ZIC_SEXO='F'  THEN 'FEMEA' " + CRLF
_cQry += "  										ELSE 'VERIFICAR' " + CRLF
_cQry += "  										END AS SEXO, " + CRLF
_cQry += " 			CASE WHEN ZCC_PAGFUT='S'   THEN 'SIM' " + CRLF
_cQry += " 			     						ELSE 'NÃO' " + CRLF
_cQry += " 			     						END AS PGTO_FUTURO, " + CRLF
_cQry += "  			CASE WHEN IC.ZIC_TPNEG	='P' THEN 'PESO' " + CRLF
_cQry += "  					WHEN IC.ZIC_TPNEG	='K' THEN 'KG' " + CRLF
_cQry += "  					WHEN IC.ZIC_TPNEG	='Q' THEN 'CABECA' " + CRLF
_cQry += "  											ELSE 'VERIFICAR' " + CRLF
_cQry += "  											END AS TIPO_NEGOCIA, " + CRLF
_cQry += CRLF
_cQry += " 			CASE WHEN ZBC_PEDPOR='P'   THEN 'PAUTA' " + CRLF
_cQry += "  			 							ELSE 'NEGOCIACAO' " + CRLF
_cQry += "  			 							END AS PEDIDO_POR, " + CRLF
// _cQry += "  			CASE WHEN ZBC_TEMFXA='S'   THEN 'SIM' " + CRLF
// _cQry += "  			  							ELSE 'NÃO' " + CRLF
// _cQry += "  			  							END AS TEM_FAIXA, ZBC_FAIXA, " + CRLF
_cQry += "  			ZBC_PESO			                PESO_COMPRA, " + CRLF
_cQry += " 				ZBC_ARROV			                VALOR_ARROB, " + CRLF
_cQry += "  			ZBC_REND			                RENDIMENTO, " + CRLF
_cQry += "  			ZBC_TTSICM			                TOTAL_SEM_ICMS, " + CRLF
_cQry += "  			ZBC_TOTICM			                TOTAL_ICMS, " + CRLF
_cQry += "  			ZBC_TTSICM+ZBC_TOTICM				GADO_ICMS_TOTAL_CONTRATO, " + CRLF
_cQry += "  			ZBC_VLFRPG, ZBC_ICFRVL, " + CRLF
_cQry += "  			ZBC_VLRCOM							VLR_COM, " + CRLF
_cQry += " 				ZBC_STATUS, " + CRLF
_cQry += " 				CASE WHEN ZCC_NEGENC='S' THEN 'SIM' ELSE 'NÃO' END ZCC_NEGENC" + CRLF
_cQry += "         " + CRLF
_cQry += " 		FROM ZBC010 BC " + CRLF
_cQry += " 		JOIN FATURAMENTO F ON F.D2_FILIAL=ZBC_FILIAL AND F.D2_COD=ZBC_PRODUT AND BC.D_E_L_E_T_=' ' " + CRLF
_cQry += " 		JOIN ZCC010 CC ON ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO " + CRLF
_cQry += "  				AND ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO AND ZCC_VERSAO=ZBC_VERSAO " + CRLF
_cQry += " 					AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
_cQry += " 						(   -- PEGAR MAIOR VERSÃO DO CONTRATO " + CRLF
_cQry += " 							SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
_cQry += " 							FROM ZBC010 " + CRLF
_cQry += " 							WHERE ZBC_FILIAL<>' ' AND D_E_L_E_T_=' ' " + CRLF
_cQry += " 							GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
_cQry += " 						) " + CRLF
_cQry += " 					AND CC.D_E_L_E_T_=' ' " + CRLF
_cQry += CRLF
_cQry += " 		-- RETIRAR JOIN DA ZIC NA VERSÃO NOVA DO CONTRATO" + CRLF
_cQry += " 		INNER JOIN ZIC010	IC ON IC.ZIC_FILIAL=ZBC_FILIAL AND IC.ZIC_CODIGO=BC.ZBC_CODIGO AND IC.ZIC_ITEM=BC.ZBC_ITEZIC " + CRLF
_cQry += " 					AND ZIC_FILIAL=ZBC_FILIAL AND ZIC_CODIGO=ZBC_CODIGO AND ZIC_VERSAO=ZBC_VERSAO " + CRLF
_cQry += " 		       				AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
_cQry += " 		       					( " + CRLF
_cQry += " 		       						SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
_cQry += " 		       						FROM ZBC010 " + CRLF
_cQry += " 		       						WHERE ZBC_FILIAL<>' ' AND D_E_L_E_T_=' ' " + CRLF
_cQry += " 		       						GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
_cQry += " 		       					) " + CRLF
_cQry += " 		       			 " + CRLF
_cQry += " 		 				AND IC.D_E_L_E_T_=' ' " + CRLF
_cQry += " 						-- APAGAR ATÉ AQUI" + CRLF
_cQry += CRLF
_cQry += " 				INNER JOIN SA2010 A2 ON A2.A2_FILIAL=' ' AND A2.A2_COD=ZBC_CODFOR AND A2.A2_LOJA=ZBC_LOJFOR AND A2.D_E_L_E_T_=' ' " + CRLF
_cQry += " 				INNER JOIN SA3010 A3 ON A3_FILIAL=' ' AND A3.A3_COD=ZBC_X_CORR AND A3.D_E_L_E_T_=' ' " + CRLF
_cQry += " 				INNER JOIN " + RetSQLName('SB1') + " B1 ON B1_FILIAL=' ' AND B1_COD=ZBC_PRODUT AND B1_RASTRO='L' AND B1.D_E_L_E_T_=' ' " + CRLF
_cQry += " 				WHERE " + CRLF
_cQry += "  						ZBC_FILIAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + CRLF
_cQry += "  					AND ZBC_CODIGO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CRLF
_cQry += "  					AND ZBC_PEDIDO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " + CRLF
_cQry += "  					AND ZBC_CODFOR BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " + CRLF
_cQry += " 					AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " + CRLF
_cQry += " 							( " + CRLF
_cQry += "           					SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " + CRLF
_cQry += "           					FROM ZBC010 " + CRLF
_cQry += "           					WHERE ZBC_FILIAL<>' ' AND D_E_L_E_T_=' ' " + CRLF
_cQry += "           					GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " + CRLF
_cQry += "           				)" + CRLF
_cQry += " )" + CRLF
_cQry += CRLF

If cTipo == "Geral"
	_cQry += " SELECT * FROM CONTRATO" + CRLF

ElseIf cTipo == "NFiscal"
	// _cQry += " , NOTAS_FISCAIS AS" + CRLF
	// _cQry += " ( " + CRLF
	_cQry += " 		SELECT DISTINCT" + CRLF
	_cQry += " 		    CASE WHEN D1_FILIAL=C.FILIAL AND D1_FORNECE+D1_LOJA=C.CODIGO_FORNEC+LOJA_FORNEC AND D1_TIPO='N' AND D1_QUANT <> 0 " + CRLF
	_cQry += "					THEN '1-COMPRA'" + CRLF
	_cQry += "		    	 WHEN D1_FILIAL=C.FILIAL AND D1_FORNECE+D1_LOJA=C.CODIGO_FORNEC+LOJA_FORNEC AND D1_TIPO='C' AND F1_TPCOMPL='1'" + CRLF
	_cQry += "					THEN '2-COMP. PRECO'" + CRLF
	_cQry += "		    	 WHEN D1_FILIAL=C.FILIAL AND D1_FORNECE+D1_LOJA <> C.CODIGO_FORNEC+LOJA_FORNEC AND D1_TIPO='C' AND F1_TPCOMPL='3'" + CRLF
	_cQry += "					THEN '3-FRETE' " + CRLF
	_cQry += "			END AS TIPO," + CRLF
	_cQry += " 			D1.D1_PEDIDO, D1.D1_FILIAL, D1.D1_DOC, D1.D1_SERIE, D1.D1_EMISSAO, D1.D1_, D1.D1_FORNECE, D1.D1_LOJA, A2.A2_NOME, D1.D1_COD, B1.B1_DESC, D1.D1_VALICM, D1.D1_TOTAL," + CRLF
	_cQry += " 			D1.D1_X_PESCH PESO_CHEGADA, " + CRLF
	_cQry += "  		D1.D1_X_EMBDT DATA_EMBARQUE, " + CRLF
	_cQry += "  		D1.D1_X_EMBHR HORA_EMBARQUE, " + CRLF
	_cQry += "  		CASE D1.D1_X_CHEDT " + CRLF
	_cQry += "  					WHEN ' ' " + CRLF
	_cQry += "  					 	THEN D1.D1_EMISSAO " + CRLF
	_cQry += "  					 	ELSE D1.D1_X_CHEDT " + CRLF
	_cQry += "  		END DATA_CHEGADA, " + CRLF
	_cQry += "  		D1.D1_X_CHEHR HORA_CHEGADA, " + CRLF
	_cQry += "  		D1.D1_X_KM    KM_NF_ENTRADA, " + CRLF
	_cQry += "  		D1.D1_QUANT   QTD_NF" + CRLF
	_cQry += " 		FROM	 SF1010  F1 " + CRLF
	_cQry += " 			JOIN SD1010  D1 ON F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE AND F1_LOJA=D1_LOJA AND F1.D_E_L_E_T_=' ' AND D1.D_E_L_E_T_=' ' 	 " + CRLF
	_cQry += " 			JOIN SA2010  A2 ON A2_FILIAL=' ' AND D1.D1_FORNECE=A2.A2_COD AND D1.D1_LOJA=A2.A2_LOJA AND A2.D_E_L_E_T_=' '" + CRLF
	_cQry += " 			JOIN " + RetSQLName('SB1') + "  B1 ON B1_FILIAL=' ' AND D1_COD=B1_COD AND  B1.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 			JOIN CONTRATO C ON D1_FILIAL=C.FILIAL AND D1_COD=C.CODIGO_BOV" + CRLF
	// // _cQry += " 								AND D1_FORNECE=C.CODIGO_FORNEC" + CRLF
	// // _cQry += " 								AND D1_LOJA=C.LOJA_FORNEC" + CRLF
	// _cQry += " )" + CRLF
	// _cQry += " 				" + CRLF
	// _cQry += " SELECT * FROM NOTAS_FISCAIS" + CRLF
	_cQry += " ORDER BY TIPO, D1_FILIAL, D1_SERIE, D1_DOC" + CRLF
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
 | Principal: 					U_MBCOMR01()             	            	      |
 | Func:  fPrintAba1()	            	            	            	          |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  19.02.2019	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function fPrintAba1()	 // U_MBCOMR01()

Local cXML 			:= "", cPanes := ""
Local cWorkSheet 	:= "Lotes"

(_cAliasG)->(DbEval({|| _nRegAba1++ }))

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	cXML := U_prtCellXML( 'Worksheet', cWorkSheet )
	cXML += U_prtCellXML( 'Table' )
	
	cXML += '<Column ss:Width="28.5"/>'+CRLF
	cXML += '<Column ss:Width="45"/>'+CRLF
	cXML += '<Column ss:Width="60"/>'+CRLF
	cXML += '<Column ss:Width="58.5"/>'+CRLF
	cXML += '<Column ss:Width="216"/>'+CRLF
	cXML += '<Column ss:Width="152.25"/>'+CRLF
	cXML += '<Column ss:Width="126"/>'+CRLF
	cXML += '<Column ss:Width="164.25"/>'+CRLF
	cXML += '<Column ss:Width="62.25"/>'+CRLF
	cXML += '<Column ss:Width="43.5"/>'+CRLF
	cXML += '<Column ss:Width="39.75"/>'+CRLF
	cXML += '<Column ss:Width="66.75"/>'+CRLF
	cXML += '<Column ss:Width="83.25"/>'+CRLF
	cXML += '<Column ss:Width="66.75"/>'+CRLF
	cXML += '<Column ss:Width="66"/>'+CRLF
	cXML += '<Column ss:Width="39.75"/>'+CRLF
	cXML += '<Column ss:Width="60.75"/>'+CRLF
	cXML += '<Column ss:Width="80.25"/>'+CRLF
	cXML += '<Column ss:Width="72.75"/>'+CRLF
	cXML += '<Column ss:AutoFitWidth="0" ss:Width="88.5"/>'+CRLF
	cXML += '<Column ss:Width="66.75"/>'+CRLF
	cXML += '<Column ss:Width="61.5"/>'+CRLF
	cXML += '<Column ss:Width="66.75"/>'+CRLF
	cXML += '<Column ss:Width="33.75"/>'+CRLF
	cXML += '<Column ss:Width="39.75"/>'+CRLF
	
	cXML += U_prtCellXML( 'Titulo',,'33',,'24','s62','String', /*cFormula*/, cTitulo )

	cXML += U_prtCellXML( 'Row',,'33' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Filial' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Contrato' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Pedido/Lote' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Fornecedor' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Vendedor' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Origem' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Corretor' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Animal' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtd. Compra' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Raça' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Sexo' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Pagto. Futuro' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Tipo Negociação' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Ped. Por:' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Compra' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Valor @' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Rendimento' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Total S/ ICMS' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Total ICMS' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Total C/ ICMS Contrato' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$ Frete' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'ICMS Frete' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Comissão' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Status' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Negenc' )
	cXML += U_prtCellXML( '</Row>' )
	
	//fPrintAba1
	While !(_cAliasG)->(Eof())	 // U_MBCOMR01()

		cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->FILIAL )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->COD_CONTRATO )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->NUMERO_LOTE+(_cAliasG)->ZBC_ITEMPC )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->CODIGO_FORNEC+(_cAliasG)->LOJA_FORNEC )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->VENDEDOR )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->ESTADO+'-'+(_cAliasG)->ORIGEM )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, AllTrim((_cAliasG)->COD_CORRETOR)+'-'+(_cAliasG)->CORRETOR )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->CODIGO_BOV+'-'+(_cAliasG)->DESCRICAO )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sSemDig' , 'Number', /*cFormula*/, (_cAliasG)->QTD_COMPRA )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->RACA )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->SEXO )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->PGTO_FUTURO )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->TIPO_NEGOCIA )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->PEDIDO_POR )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig' , 'Number', /*cFormula*/, (_cAliasG)->PESO_COMPRA )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig' , 'Number', /*cFormula*/, (_cAliasG)->VALOR_ARROB )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sPorcent', 'Number', /*cFormula*/, (_cAliasG)->RENDIMENTO )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sReal'   , 'Number', /*cFormula*/, (_cAliasG)->TOTAL_SEM_ICMS )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sReal'   , 'Number', /*cFormula*/, (_cAliasG)->TOTAL_ICMS )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sReal'   , 'Number', /*cFormula*/, (_cAliasG)->GADO_ICMS_TOTAL_CONTRATO )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sReal'   , 'Number', /*cFormula*/, (_cAliasG)->ZBC_VLFRPG )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sReal'   , 'Number', /*cFormula*/, (_cAliasG)->ZBC_ICFRVL )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sReal'   , 'Number', /*cFormula*/, (_cAliasG)->VLR_COM )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->ZBC_STATUS )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'  , 'String', /*cFormula*/, (_cAliasG)->ZCC_NEGENC )
		cXML += U_prtCellXML( '</Row>' )
		
		(_cAliasG)->(DbSkip())
	EndDo
	
	// cPanes := '   <Selected/>' + CRLF
	// cPanes += '   <Panes>' + CRLF
	// cPanes += '    <Pane>' + CRLF
	// cPanes += '     <Number>3</Number>' + CRLF
	// cPanes += '     <ActiveRow>5</ActiveRow>' + CRLF
	// cPanes += '    </Pane>' + CRLF
	// cPanes += '   </Panes>' + CRLF
	cXML += U_prtCellXML( 'WorksheetOptions',,,,,,,,, /* cPanes */ )
	
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
	
EndIf

Return nil
// FIM: fPrintAba1


/*--------------------------------------------------------------------------------,
 | Principal: 					U_MBCOMR01()               						  |
 | Func:  fPrintAba2()                											  |
 | Autor: Miguel Martins Bernardo Junior                 						  |
 | Data:  19.02.2019	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |                                                         						  |
 | Obs.:  -  																	  |
 '--------------------------------------------------------------------------------*/
Static Function fPrintAba2()	 // U_MBCOMR01()

Local cXML 			:= "", cPanes := ""
Local cWorkSheet 	:= "Notas Fiscais de Entrada"


(_cAliasNF)->(DbEval({|| _nRegAba2++ }))

(_cAliasNF)->(DbGoTop()) 
If !(_cAliasNF)->(Eof())

	cXML := U_prtCellXML( 'Worksheet', cWorkSheet )
	cXML += U_prtCellXML( 'Table' )
	
	cXML += '<Column ss:Width="80.25"/>' + CRLF
	cXML += '<Column ss:AutoFitWidth="0" ss:Width="52.5"/>' + CRLF
	cXML += '<Column ss:Width="69"/>' + CRLF
	cXML += '<Column ss:Width="58.5"/>' + CRLF
	cXML += '<Column ss:Width="262.5"/>' + CRLF
	cXML += '<Column ss:Width="164.25"/>' + CRLF
	cXML += '<Column ss:Width="72.75"/>' + CRLF
	cXML += '<Column ss:Width="80.25"/>' + CRLF
	cXML += '<Column ss:Width="71.25"/>' + CRLF
	cXML += '<Column ss:AutoFitWidth="0" ss:Width="82.5" ss:Span="1"/>' + CRLF
	cXML += '<Column ss:Index="12" ss:Width="73.5"/>' + CRLF
	cXML += '<Column ss:Width="41.25"/>' + CRLF

	cXML += U_prtCellXML( 'Titulo',,'33',,'14','s62','String', /*cFormula*/, cTitulo )
	
	cXML += U_prtCellXML( 'Row',,'33' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Tipo' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Pedido' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Doc. Fiscal' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dt. Emissão' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Fornecedor' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Animal' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$ ICMS' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$ Total' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Chegada' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data Embarque' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Hora Embarque' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data Chegada' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Hora Chegada' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'KM NF Entrada' )
	cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtd. NF.' )
	cXML += U_prtCellXML( '</Row>' )
	
	//fPrintAba2
	While !(_cAliasNF)->(Eof())	 // U_MBCOMR01()

		cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto' , 'String'  , /*cFormula*/, (_cAliasNF)->TIPO )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto' , 'String'  , /*cFormula*/, (_cAliasNF)->D1_PEDIDO )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto' , 'String'  , /*cFormula*/, (_cAliasNF)->D1_FILIAL+(_cAliasNF)->D1_DOC+(_cAliasNF)->D1_SERIE )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sData'  , 'DateTime', /*cFormula*/, StoD((_cAliasNF)->D1_EMISSAO) )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto' , 'String'  , /*cFormula*/, (_cAliasNF)->D1_FORNECE+(_cAliasNF)->D1_LOJA+'-'+(_cAliasNF)->A2_NOME )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto' , 'String'  , /*cFormula*/, AllTrim((_cAliasNF)->D1_COD)+'-'+(_cAliasNF)->B1_DESC )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sReal'  , 'Number'  , /*cFormula*/, (_cAliasNF)->D1_VALICM )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sReal'  , 'Number'  , /*cFormula*/, (_cAliasNF)->D1_TOTAL )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sComDig', 'Number'  , /*cFormula*/, (_cAliasNF)->PESO_CHEGADA )
		If Empty((_cAliasNF)->DATA_EMBARQUE)
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'      , 'String'  , /*cFormula*/, "" )
		Else
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sData'	   , 'DateTime', /*cFormula*/, StoD((_cAliasNF)->DATA_EMBARQUE))
		EndIf
		If Empty((_cAliasNF)->HORA_EMBARQUE)
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'      , 'String'  , /*cFormula*/, "" )
		Else
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sHoraCurta'  , 'DateTime', /*cFormula*/, U_HoraToExcel((_cAliasNF)->HORA_EMBARQUE) )
		EndIf
		If Empty((_cAliasNF)->DATA_CHEGADA)
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'      , 'String'  , /*cFormula*/, "" )
		Else
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sData'	   , 'DateTime', /*cFormula*/, StoD((_cAliasNF)->DATA_CHEGADA ))
		EndIf
		If Empty((_cAliasNF)->HORA_CHEGADA)
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'      , 'String'  , /*cFormula*/, "" )		
		Else
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sHoraCurta'  , 'DateTime', /*cFormula*/, U_HoraToExcel((_cAliasNF)->HORA_CHEGADA ) )
		EndIf
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sTexto'      , 'String'  , /*cFormula*/, (_cAliasNF)->KM_NF_ENTRADA )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/, 'sSemDig'     , 'Number'  , /*cFormula*/, (_cAliasNF)->QTD_NF)
		cXML += U_prtCellXML( '</Row>' )
		
		(_cAliasNF)->(DbSkip())
	EndDo
	
	cXML += U_prtCellXML( 'WorksheetOptions',,,,,,,,, /* cPanes */ )
	
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
	
EndIf

Return nil
// FIM: fPrintAba2
