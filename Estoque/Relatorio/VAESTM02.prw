#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

// #DEFINE DMPAPER_A4 	9
// #DEFINE PAD_RIGHT 	1 

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAESTM02()                                      |
 | Func:  VAESTM02()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  31.10.2018                                                              |
 | Desc:  Impressão Relatorio: Custos da Ração;							          |
 '--------------------------------------------------------------------------------|
 | Alt:                                                                           |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAESTM02()	// U_VAESTM02()
Local cTimeIni	 	:= Time()
Local lTemDados		:= .T.

Private cPerg		:= "VAESTM02"
Private cTitulo  	:= "Relatorio dos Custos da Ração"

Private cPath 	 	:= "C:\totvs_relatorios\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAlias1	:= GetNextAlias()   
Private _cAlias2	:= GetNextAlias()   
Private _cAlias3	:= GetNextAlias()
Private _cAlias4	:= GetNextAlias()
Private _cAlias5	:= GetNextAlias()

Private nHandle    	:= 0

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
		
		cStyle := U_defStyle()
		
		// Processar SQL
		FWMsgRun(, {|| lTemDados := VASqlM02("Geral", @_cAlias1 ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Alias1')
		If lTemDados
		
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// fQuadro1
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de custo de ração')
			
			FWMsgRun(, {|| lTemDados := VASqlM02("Agrupado", @_cAlias2 ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Alias2')
			If lTemDados
				// fQuadro2
				FWMsgRun(, {|| fQuadro2() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de custo de ração - Agrupado')
			EndIf
			
			FWMsgRun(, {|| lTemDados := VASqlM02("Detalhado", @_cAlias3 ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Alias3')
			If lTemDados
				// fQuadro3
				FWMsgRun(, {|| fQuadro3() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro Compras - Detalhado')
			EndIf
			
			FWMsgRun(, {|| lTemDados := VASqlM02("Mensal", @_cAlias4 ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Alias4')
			If lTemDados
				// fQuadro4
				FWMsgRun(, {|| fQuadro4() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro Compras - Detalhado')
			EndIf

			FWMsgRun(, {|| lTemDados := VASqlM02("Total", @_cAlias5 ) },'Por Favor Aguarde...' , 'Processando Banco de Dados - Alias5')
			If lTemDados
				// fQuadro5
				FWMsgRun(, {|| fQuadro5() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro Compras - Total')
			EndIf

			// Final - encerramento do arquivo
			FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )
			
			FClose(nHandle)

			If ApOleClient("MSExcel")			
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
		
		(_cAlias1)->(DbCloseArea())
		(_cAlias2)->(DbCloseArea())
		(_cAlias3)->(DbCloseArea())
		(_cAlias4)->(DbCloseArea())
		(_cAlias5)->(DbCloseArea())
		
		If lower(cUserName) $ 'mbernardo,atoshio,admin, administrador'
			Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
		EndIf
		
		ConOut('Activate: ' + Time())
	EndIf
EndIf

Return nil




/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAESTM02()                                      |
 | Func:  GeraX1()                                                                |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  11.05.2018                                                              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
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

aAdd(aRegs,{cPerg, "01", "Data Fabricação De?"      , "", "", "MV_CH1", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR01", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Data Fabricação Ate?"     , "", "", "MV_CH2", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR02", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "03", "Data Compras de?"		    , "", "", "MV_CH3", "D", TamSX3("D1_DTDIGIT")[1], TamSX3("D1_DTDIGIT")[2], 0, "G", "NaoVazio", "MV_PAR03", ""   , "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "04", "Data Compras Ate?"        , "", "", "MV_CH4", "D", TamSX3("D1_DTDIGIT")[1], TamSX3("D1_DTDIGIT")[2], 0, "G", "NaoVazio", "MV_PAR04", ""   , "","",""  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
// aAdd(aRegs,{cPerg, "05", "Valor?"        		, "", "", "MV_CH5", "C", TamSX3("ZSI_VALOR")[1] , TamSX3("ZSI_VALOR")[2] , 0, "G", "NaoVazio", "MV_PAR05", ""   , "","",""	  	,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
// aAdd(aRegs,{cPerg, "15", "Imprime Outras Movimentacoes?", "", "", "MV_CHF", "N", 					   1,					    0, 2, "C", ""        , "MV_PAR15", "Não", "","",""      ,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})

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
 | Principal: 					U_VAESTM02()                                      |
 | Func:  VASqlM02()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  31.10.2018                                                              |
 | Desc:  Processamento do SQL, salvando em variavel PRIVADA;                     |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function VASqlM02(cTipo, _cAlias)
Local _cQry 		:= ""

If cTipo $ "Geral,Agrupado"

	_cQry := " WITH" + CRLF
	_cQry += " PROD_RACAO AS (		 " + CRLF
	_cQry += " 	SELECT D3.D3_FILIAL					    FILIAL," + CRLF
	_cQry += " 	       D3.D3_COD                        CODIGO," + CRLF
	_cQry += " 	 -- CASE WHEN D3.D3_COD = 'ADAPTACAO01S' THEN 'ADAPTACAO01' " + CRLF
	_cQry += " 	 --      WHEN D3.D3_COD = 'ADAPTACAO02S' THEN 'ADAPTACAO02'" + CRLF
	_cQry += " 	 --      WHEN D3.D3_COD = 'ADAPTACAO03S' THEN 'ADAPTACAO03'" + CRLF
	_cQry += " 	 --      WHEN D3.D3_COD = 'FINALS' THEN 'FINAL'" + CRLF
	_cQry += " 	 --      ELSE D3.D3_COD  END CODIGO, " + CRLF
	_cQry += " 			B1.B1_DESC					    DESCRICAO, 		 " + CRLF
	_cQry += " 			D3.D3_UM						    UM,    					 " + CRLF
	_cQry += " 			D3.D3_OP							OP," + CRLF
	_cQry += " 			D3.D3_EMISSAO					EMISSAO,     		 " + CRLF
	_cQry += " 			SUM(D3.D3_QUANT)					QTD," + CRLF
	_cQry += " 			SUM(D3.D3_CUSTO1)				CUSTO		 " + CRLF
	_cQry += " 		, B1_X_TRATO " + CRLF
	_cQry += " 	FROM SD3010 D3		 " + CRLF
	_cQry += " 	JOIN " + RetSQLName('SB1') + " B1 ON B1_FILIAL=' ' AND D3_COD = B1_COD" + CRLF
	_cQry += " 						AND D3.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' 		 " + CRLF
	_cQry += "  --AND B1_DESC NOT LIKE 'PREMIX%'" +CRLF
	_cQry += " 	WHERE D3.D3_TM = '001'		 " + CRLF
	_cQry += " 	  AND D3.D3_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'" + CRLF
	//_cQry += " 	  AND B1_X_TRATO = '1'		 " + CRLF
	_cQry += " 	GROUP BY D3.D3_FILIAL, D3.D3_COD, B1_DESC, D3.D3_UM, D3.D3_EMISSAO, D3.D3_OP, B1_X_TRATO " + CRLF
	_cQry += " 	) " + CRLF
	_cQry += " 	 " + CRLF
	_cQry += " , INS_CARR AS (		 " + CRLF
	_cQry += " 	SELECT P.FILIAL, P.CODIGO, D3.D3_FILIAL, D3_COD, B1_DESC, B1_UM, D3.D3_EMISSAO, SUM(D3_QUANT) QTD, SUM(D3_CUSTO1) CUSTO, B1_CUSTD, D3.D3_OP FROM SD3010 D3		 " + CRLF
	_cQry += " 		JOIN PROD_RACAO P ON		 " + CRLF
	_cQry += " 			D3.D3_FILIAL				=			P.FILIAL		 " + CRLF
	_cQry += " 		AND D3.D3_OP					=			P.OP		 " + CRLF
	_cQry += " 		AND D3.D3_EMISSAO			=			P.EMISSAO		 " + CRLF
	_cQry += " 		AND D3.D3_COD				<>			P.CODIGO		 " + CRLF
	_cQry += " 		AND D3_CF					LIKE		'RE%'		 " + CRLF
	_cQry += " 		JOIN " + RetSQLName('SB1') + " B1 ON B1_FILIAL=' ' AND B1_COD = D3.D3_COD AND B1.D_E_L_E_T_ = ' '" + CRLF
	_cQry += " 		WHERE D3.D_E_L_E_T_			=			' ' 		 " + CRLF
	_cQry += " 		  AND D3.D3_GRUPO IN ('02','03','99')" + CRLF
	_cQry += " 		GROUP BY P.FILIAL, P.CODIGO, D3.D3_FILIAL, D3.D3_COD, B1_DESC, B1_UM, D3_EMISSAO, B1_CUSTD, D3.D3_OP		 " + CRLF
	_cQry += " 	) " + CRLF
	_cQry += CRLF
	
	If cTipo == "Agrupado"
		_cQry += " , FINAL AS (" + CRLF
	EndIf
	
	_cQry += " 	SELECT  P.FILIAL," + CRLF
	_cQry += " 			P.CODIGO, 		 " + CRLF
	_cQry += " 			P.DESCRICAO," + CRLF
	_cQry += " 			P.UM," + CRLF
	_cQry += " 			SUM(P.QTD) QUANTIDADE," + CRLF
	_cQry += " 			SUM(P.CUSTO) CUSTO_TOTAL, " + CRLF
	_cQry += " 			P.B1_X_TRATO, " + CRLF
	_cQry += " 			P.EMISSAO, " + CRLF
	_cQry += " 			I.D3_COD, " + CRLF
	_cQry += " 			I.B1_DESC, " + CRLF
	_cQry += " 			I.B1_UM, " + CRLF
	_cQry += " 			SUM(I.QTD) INS_QUANT," + CRLF
	_cQry += " 			B1_CUSTD CUSTOPADRAO, " + CRLF
	_cQry += " 			SUM(I.CUSTO) CUSTOTOAL, " + CRLF
	_cQry += "			ISNULL(Z0V_INDMS,0) Z0V_INDMS, " + CRLF
	_cQry += "			SUM(I.QTD)*(Z0V_INDMS/100) QTDE_MS " + CRLF
	_cQry += " 	FROM PROD_RACAO P " + CRLF
	_cQry += " 	JOIN INS_CARR I ON P.FILIAL = I.D3_FILIAL AND P.CODIGO = I.CODIGO" + CRLF
	_cQry += " 						AND P.EMISSAO = I.D3_EMISSAO" + CRLF
	_cQry += " 						AND P.OP = I.D3_OP " + CRLF
	_cQry += "	LEFT JOIN " + RetSQLName('Z0V') + " Z0V ON Z0V_FILIAL = I.D3_FILIAL AND  Z0V_COMP = I.D3_COD AND Z0V_DATA  = I.D3_EMISSAO AND Z0V.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " 	GROUP BY P.B1_X_TRATO, P.FILIAL, P.CODIGO, P.DESCRICAO, P.UM, P.EMISSAO, " + CRLF
	_cQry += " 				I.D3_COD, I.B1_DESC, I.B1_UM, I.B1_CUSTD, Z0V_INDMS " + CRLF
	
	If cTipo == "Agrupado"
		_cQry += " )" + CRLF

		_cQry += " SELECT FILIAL, CODIGO, DESCRICAO, UM, EMISSAO, MIN(QUANTIDADE) QUANTIDADE, SUM(INS_QUANT) INS_QUANT, SUM(CUSTOTOAL) CUSTOTOAL," + CRLF
		_cQry += "sum(QTDE_MS) TOTAL_MS, ROUND(SUM(QTDE_MS)/MIN(QUANTIDADE)*100,2) PERC_MS " + CRLF
		_cQry += "--, ROUND((SUM(CUSTOTOAL)/MIN(QUANTIDADE))/ROUND(SUM(QTDE_MS)/MIN(QUANTIDADE),2),2)*1.04 VAL_KGMS" + CRLF
		_cQry += " FROM FINAL" + CRLF
		_cQry += " GROUP BY FILIAL, CODIGO, DESCRICAO, EMISSAO, UM" + CRLF
		_cQry += CRLF
		_cQry += " ORDER BY FILIAL, CODIGO, DESCRICAO, EMISSAO, UM" + CRLF
	Else
		_cQry += CRLF
		_cQry += " 	ORDER BY P.B1_X_TRATO ASC, P.FILIAL, P.CODIGO, I.B1_DESC, P.EMISSAO " + CRLF
	EndIf
	
EndIf
IF cTipo $ "Compras;Detalhado;Mensal;Total"
	
//_cQry := " set language Brazilian; " + CRLF
_cQry += " WITH COMPRA AS ( " + CRLF
_cQry += "      SELECT CASE WHEN MONTH(D1_DTDIGIT)= 1	THEN CONCAT(MONTH(D1_DTDIGIT),'-',DATENAME(MONTH,D1_DTDIGIT))  " + CRLF
_cQry += " 			     WHEN MONTH(D1_DTDIGIT)= 2	THEN CONCAT(MONTH(D1_DTDIGIT),'-',DATENAME(MONTH,D1_DTDIGIT))  " + CRLF
_cQry += " 			     WHEN MONTH(D1_DTDIGIT)= 3	THEN CONCAT(MONTH(D1_DTDIGIT),'-',DATENAME(MONTH,D1_DTDIGIT))  " + CRLF
_cQry += " 			     WHEN MONTH(D1_DTDIGIT)= 4	THEN CONCAT(MONTH(D1_DTDIGIT),'-',DATENAME(MONTH,D1_DTDIGIT))  " + CRLF
_cQry += " 			     WHEN MONTH(D1_DTDIGIT)= 5	THEN CONCAT(MONTH(D1_DTDIGIT),'-',DATENAME(MONTH,D1_DTDIGIT))  " + CRLF
_cQry += " 			     WHEN MONTH(D1_DTDIGIT)= 6	THEN CONCAT(MONTH(D1_DTDIGIT),'-',DATENAME(MONTH,D1_DTDIGIT))  " + CRLF
_cQry += " 			     WHEN MONTH(D1_DTDIGIT)= 7	THEN CONCAT(MONTH(D1_DTDIGIT),'-',DATENAME(MONTH,D1_DTDIGIT))  " + CRLF
_cQry += " 			     WHEN MONTH(D1_DTDIGIT)= 8	THEN CONCAT(MONTH(D1_DTDIGIT),'-',DATENAME(MONTH,D1_DTDIGIT))  " + CRLF
_cQry += " 			     WHEN MONTH(D1_DTDIGIT)= 9	THEN CONCAT(MONTH(D1_DTDIGIT),'-',DATENAME(MONTH,D1_DTDIGIT))  " + CRLF
_cQry += " 			     WHEN MONTH(D1_DTDIGIT)= 10	THEN CONCAT(MONTH(D1_DTDIGIT),'-',DATENAME(MONTH,D1_DTDIGIT))  " + CRLF
_cQry += " 			     WHEN MONTH(D1_DTDIGIT)= 11	THEN CONCAT(MONTH(D1_DTDIGIT),'-',DATENAME(MONTH,D1_DTDIGIT))  " + CRLF
_cQry += " 			     WHEN MONTH(D1_DTDIGIT)= 12	THEN CONCAT(MONTH(D1_DTDIGIT),'-',DATENAME(MONTH,D1_DTDIGIT))  " + CRLF
_cQry += " 			     ELSE 'VERIFICAR_NF' END AS MES, " + CRLF
_cQry += " 	        D1_DOC+D1_SERIE NOTA, D1_EMISSAO EMISSAO, D1_DTDIGIT D1_DTDIGIT, D1_FORNECE+D1_LOJA COD_FOR, RTRIM(A2_NOME) A2_NOME, D1_COD, RTRIM(B1_DESC) B1_DESC, D1_TOTAL, D1_CUSTO, D1_QUANT, D1_X_PESOB " + CRLF
_cQry += " 	   FROM " + RetSQLName('SD1') + " D1 " + CRLF
_cQry += "        JOIN SF4010 F4 ON  " + CRLF
_cQry += " 	        F4_FILIAL = '"+xFilial("SF4")+"'  " + CRLF
_cQry += " 	    AND F4_CODIGO = D1_TES  " + CRLF
_cQry += " 	    AND F4.D_E_L_E_T_ = ' '   " + CRLF
_cQry += " 		AND F4_ESTOQUE = 'S' " + CRLF
_cQry += " 		AND F4_TRANFIL <> '1' " + CRLF
_cQry += " 		AND F4_DUPLIC = 'S' " + CRLF
_cQry += " 		AND F4.D_E_L_E_T_ = ' '  " + CRLF
_cQry += " 	   JOIN " + RetSQLName('SB1') + " B1 ON  " + CRLF
_cQry += " 		    B1_FILIAL = '" + xFilial("SB1") + "'  " + CRLF
_cQry += " 	    AND B1_COD = D1_COD " + CRLF
_cQry += " 		AND B1.D_E_L_E_T_ = ' '  " + CRLF
_cQry += " 	   JOIN " + RetSQLName('SA2') + " A2 ON "+ CRLF
_cQry += "			A2_FILIAL = '"+ xFilial("SA2") +"' "+ CRLF
_cQry += "		AND A2_COD+A2_LOJA = D1_FORNECE + D1_LOJA " + CRLF
_cQry += "	    AND A2.D_E_L_E_T_ = ' ' " + CRLF
_cQry += " 	  WHERE D1_GRUPO IN ('02','03')  " + CRLF
_cQry += " 	    AND D1_DTDIGIT BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"' " + CRLF
_cQry += " 		--AND D1_COD IN (SELECT DISTINCT ZG1_COMP FROM ZG1010 WHERE ZG1_COD  IN ('ADAPTACAO01', 'ADAPTACAO02', 'ADAPTACAO03', 'FINAL', 'RECEPCAO','030001'))  " + CRLF
_cQry += " 		AND D1.D_E_L_E_T_ = ' '  " + CRLF
_cQry += " 	 ) " + CRLF
_cQry += " , TOTAL_MES AS  ( " + CRLF
_cQry += " 		SELECT D1_COD, B1_DESC, UPPER(MES) MES, SUM(D1_QUANT) QTDE, SUM(D1_TOTAL) VALTOT, SUM(D1_CUSTO) CUSTO,  ROUND(((SUM(D1_TOTAL)/SUM(D1_CUSTO)-1) *100),2) PERCE, SUM(D1_X_PESOB) PESO_BALA " + CRLF
_cQry += " 		,CASE WHEN MONTH(D1_DTDIGIT)= 1	THEN ROUND(SUM(D1_TOTAL)/SUM(CASE D1_QUANT WHEN 0 THEN 1 ELSE D1_QUANT END ),2)   " + CRLF
_cQry += " 		     WHEN MONTH(D1_DTDIGIT)= 2	THEN ROUND(SUM(D1_TOTAL)/SUM(CASE D1_QUANT WHEN 0 THEN 1 ELSE D1_QUANT END ),2)   " + CRLF
_cQry += " 		     WHEN MONTH(D1_DTDIGIT)= 3	THEN ROUND(SUM(D1_TOTAL)/SUM(CASE D1_QUANT WHEN 0 THEN 1 ELSE D1_QUANT END ),2) 	 " + CRLF
_cQry += " 		     WHEN MONTH(D1_DTDIGIT)= 4	THEN ROUND(SUM(D1_TOTAL)/SUM(CASE D1_QUANT WHEN 0 THEN 1 ELSE D1_QUANT END ),2) 	 " + CRLF
_cQry += " 		     WHEN MONTH(D1_DTDIGIT)= 5	THEN ROUND(SUM(D1_TOTAL)/SUM(CASE D1_QUANT WHEN 0 THEN 1 ELSE D1_QUANT END ),2)   " + CRLF
_cQry += " 			 WHEN MONTH(D1_DTDIGIT)= 6	THEN ROUND(SUM(D1_TOTAL)/SUM(CASE D1_QUANT WHEN 0 THEN 1 ELSE D1_QUANT END ),2)   " + CRLF
_cQry += " 			 WHEN MONTH(D1_DTDIGIT)= 7	THEN ROUND(SUM(D1_TOTAL)/SUM(CASE D1_QUANT WHEN 0 THEN 1 ELSE D1_QUANT END ),2)   " + CRLF
_cQry += " 			 WHEN MONTH(D1_DTDIGIT)= 8	THEN ROUND(SUM(D1_TOTAL)/SUM(CASE D1_QUANT WHEN 0 THEN 1 ELSE D1_QUANT END ),2)   " + CRLF
_cQry += " 			 WHEN MONTH(D1_DTDIGIT)= 9	THEN ROUND(SUM(D1_TOTAL)/SUM(CASE D1_QUANT WHEN 0 THEN 1 ELSE D1_QUANT END ),2)   " + CRLF
_cQry += " 			 WHEN MONTH(D1_DTDIGIT)= 10	THEN ROUND(SUM(D1_TOTAL)/SUM(CASE D1_QUANT WHEN 0 THEN 1 ELSE D1_QUANT END ),2)   " + CRLF
_cQry += " 			 WHEN MONTH(D1_DTDIGIT)= 11	THEN ROUND(SUM(D1_TOTAL)/SUM(CASE D1_QUANT WHEN 0 THEN 1 ELSE D1_QUANT END ),2)   " + CRLF
_cQry += " 			 WHEN MONTH(D1_DTDIGIT)= 12	THEN ROUND(SUM(D1_TOTAL)/SUM(CASE D1_QUANT WHEN 0 THEN 1 ELSE D1_QUANT END ),2)   " + CRLF
_cQry += " 			 ELSE 0  " + CRLF
_cQry += " 		 END AS VAL_KG " + CRLF
_cQry += " 		 FROM  COMPRA " + CRLF
_cQry += " 		 WHERE D1_DTDIGIT BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"' --AND D1_COD = '020017'		  " + CRLF
_cQry += "       GROUP BY D1_COD, B1_DESC, MONTH(D1_DTDIGIT), MES " + CRLF
_cQry += " 	) " + CRLF
_cQry += " , TOTAL_GERAL AS  ( " + CRLF
_cQry += " 		SELECT D1_COD, B1_DESC, SUM(D1_QUANT) QTDE, SUM(D1_TOTAL) VALTOT, SUM(D1_CUSTO) CUSTO, sum(D1_X_PESOB) PESO_BALA, ROUND(((SUM(D1_TOTAL)/SUM(D1_CUSTO)-1) *100),2)  PERCE, ROUND(SUM(D1_TOTAL)/ CASE WHEN SUM(D1_QUANT) = 0 THEN 1 ELSE SUM(D1_QUANT) END, 2) KG		 " + CRLF
_cQry += " 		 FROM  COMPRA " + CRLF
_cQry += " 		 WHERE D1_DTDIGIT BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"' --AND D1_COD = '020017' " + CRLF
_cQry += " 		 GROUP BY  D1_COD, B1_DESC " + CRLF
_cQry += " 	) " +CRLF
	If cTipo == "Detalhado"	
		_cQry += " 		 SELECT * FROM COMPRA ORDER BY  D1_COD, EMISSAO " + CRLF
	ElseIf cTipo == "Mensal"
		_cQry += " 		 SELECT * FROM TOTAL_MES ORDER BY D1_COD, MES " + CRLF
	Else 
		_cQry += " 		 SELECT * FROM TOTAL_GERAL ORDER BY D1_COD " + CRLF
	EndIf	
EndIf
If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

//TcSetField(_cAlias, "D3_EMISSAO", "D")

Return !(_cAlias)->(Eof()) // U_VAESTM02()
// FIM: VASqlM02()



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAESTM02()                                      |
 | Func:  fQuadro1()	                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  01.11.2018                                                              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1()	 // U_VAESTM02()

Local cWorkSheet 	:= "Custo da Ração"
Local dDia_nI		:= MV_PAR01
Local dDia_nJ		:= MV_PAR01
Local nQtDias 		:= MV_PAR02 - MV_PAR01
Local nLin 			:= 0
Local cProduto		:= "", cInsumo := ""
Local cXML 			:= "", cPrdItemXML := "", cXMLTmp := ""
Local lTotProd		:= .T. // controlar a impressao do cabeçalho / soma dos insumos por racao/produto

(_cAlias1)->(DbGoTop()) 
If !(_cAlias1)->(Eof())

	// Inicio // fQuadro1 -> "Custo da Ração"
	cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
	
	cXML += ' <Column ss:Width="31.5"/>' + CRLF
	cXML += ' <Column ss:Width="39"/>' + CRLF
	cXML += ' <Column ss:Width="186"/>' + CRLF
	cXML += ' <Column ss:Width="23"/>' + CRLF

	For dDia_nI := MV_PAR01 to MV_PAR02	
		cXML += ' <Column ss:Width="72.5"/>' + CRLF
		cXML += ' <Column ss:Width="64.5"/>' + CRLF
		cXML += ' <Column ss:Width="73.5"/>' + CRLF
		cXML += ' <Column ss:Width="33.5"/>' + CRLF
		cXML += ' <Column ss:Width="33.5"/>' + CRLF
		cXML += ' <Column ss:Width="60.5"/>' + CRLF
		cXML += ' <Column ss:Width="25"/>' + CRLF
	Next dDia_nI	

	cXML += ' <Column ss:Width="72.5"/>' + CRLF
	cXML += ' <Column ss:Width="72.5"/>' + CRLF
	cXML += ' <Column ss:Width="72.5"/>' + CRLF
	cXML += ' <Column ss:Width="72.5"/>' + CRLF
	cXML += ' <Column ss:Width="68.5"/>' + CRLF
	cXML += ' <Column ss:Width="68.5"/>' + CRLF
	cXML += ' <Column ss:Width="100.5"/>' + CRLF
	cXML += ' <Column ss:Width="65.5"/>' + CRLF
	cXML += ' <Column ss:Width="65.5"/>' + CRLF
	cXML += ' <Column ss:Width="65.5"/>' + CRLF

	cXML += ' <Row ss:Height="36">' + CRLF
	cXML += '<Cell ss:MergeAcross="18" ss:StyleID="s62">' + CRLF
	cXML += '     <Data ss:Type="String">RELATÓRIO DE CUSTOS DA RAÇÃO</Data>' + CRLF
	cXML += '   </Cell>' + CRLF
	cXML += ' </Row>' + CRLF
	cXML += ' <Row ss:Height="33">' + CRLF
	cXML += '<Cell ss:StyleID="s16"/>' + CRLF
	cXML += '<Cell ss:StyleID="s16"/>' + CRLF
	cXML += '<Cell ss:StyleID="s16"/>' + CRLF
	cXML += '<Cell ss:StyleID="s16"/>' + CRLF
	For dDia_nI := MV_PAR01 to MV_PAR02
		cXML += '<Cell ss:StyleID="sDataCenter" ss:MergeAcross="5"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( dDia_nI ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="s16"/>' + CRLF
	Next dDia_nI
	cXML += '<Cell ss:StyleID="sDataCenter" ss:MergeAcross="3"><Data ss:Type="String">TOTAL</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s16"/>' + CRLF
	cXML += ' </Row>' + CRLF
	nLin += 1
	
	//fQuadro1
	While !(_cAlias1)->(Eof())	 // U_VAESTM02()
		nLin += 1
		
		if cProduto <> (_cAlias1)->CODIGO
		
			cProduto := (_cAlias1)->CODIGO
			lTotProd := .T.
			
			If nLin > 2
				cXML += '<Row>' + CRLF
				cXML += '<Cell ss:StyleID="s16"/>' + CRLF
				cXML += '</Row>' + CRLF // pular linha
			EndIf
			
			cXML += ' <Row ss:Height="33">' + CRLF
			cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Código</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Produto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">UN</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

			For dDia_nI := MV_PAR01 to MV_PAR02
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Quant.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo Medio</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">R$ MS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">% MS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">KG MS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				//cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">R$ MS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s16"/>' + CRLF
				
			Next dDia_nI

			
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Qtde</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Qtd Média</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo KG</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">% MS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">% Imposto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Imposto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo MN</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo MS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				
			cXML += ' </Row>' + CRLF
			
			cXML += '<Row>' + CRLF
			cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAlias1)->FILIAL    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAlias1)->CODIGO    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAlias1)->DESCRICAO ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAlias1)->UM 	   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			//cXML += '</Row>' + CRLF
			// formula na linha do produto final
			//For dDia_nI := MV_PAR01 to MV_PAR02
			//	cPrdItemXML += '<Cell ss:StyleID="sReal"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias1)->QUANTIDADE ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			//	// cPrdItemXML += '<Cell ss:StyleID="sComDig" ss:Formula="=SUMIF(R[2]C1:R[20]C1,RC2,R[2]C:R[20]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			//	cPrdItemXML += '<Cell ss:StyleID="sReal"   ss:Formula="=IFERROR(RC[1]/RC[-1],0)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			//	cPrdItemXML += '<Cell ss:StyleID="sReal"   ss:Formula="=SUMIF(R[2]C1:R[20]C1,RC2,R[2]C:R[20]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			//	cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
			//	cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
			//	enviado para baixo
			//Next dDia_nI
			
			cXMLTmp += '</Row>' + CRLF //cXML += '</Row>' + CRLF
			
			cXMLTmp += '<Row ss:Height="50">' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">Código</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">Insumo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">UN</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			
			For dDia_nI := MV_PAR01 to MV_PAR02
				cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">Quant.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo Unit.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">% R$</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">% MS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">KG MS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				

			Next dDia_nI
			
			//cXMLTmp += '</Row>' + CRLF

			cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">Quant.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">Qtde Média / Dia</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo Médio</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">% MS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">Imposto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s65"><Data ss:Type="String">R$ KG/Saca</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXMLTmp += '</Row>' + CRLF
			
			cInsumo := ""
			nLinPerc	:= 2
		EndIf 

		if cInsumo <> (_cAlias1)->D3_COD //.and. cProduto <> (_cAlias1)->CODIGO
			cXMLTmp += '<Row>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="sTextoSC"><Data ss:Type="String">'+ U_FrmtVlrExcel( (_cAlias1)->CODIGO  ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXMLTmp += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAlias1)->D3_COD  ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXMLTmp += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAlias1)->B1_DESC ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXMLTmp += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAlias1)->B1_UM   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cInsumo := (_cAlias1)->D3_COD
			dDia_nI := MV_PAR01
		EndIf
		
		While dDia_nI <= sToD( (_cAlias1)->EMISSAO )
			if dDia_nI == sToD( (_cAlias1)->EMISSAO )
				cXMLTmp += '<Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAlias1)->INS_QUANT ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[1]/RC[-1],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="sReal"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAlias1)->CUSTOTOAL   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16" ss:Formula="=IFERROR(RC[-1]/R[-'+AllTrim(Str(nLinPerc))+']C[-1]*100,0)"><Data ss:Type="Number"></Data></Cell>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAlias1)->Z0V_INDMS   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAlias1)->QTDE_MS   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				
				if lTotProd
					cPrdItemXML += '<Cell ss:StyleID="sComDig"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias1)->QUANTIDADE ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[1]/RC[-1],0)"><Data ss:Type="Number"></Data></Cell>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="sReal" ss:Formula="=SUMIF(R[2]C1:R[20]C1,RC2,R[2]C:R[20]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="sComDig" ss:Formula="=IFERROR(RC[-2]/RC[1],0)"><Data ss:Type="Number"></Data></Cell>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="sComDig" ss:Formula="=IFERROR(RC[1]/RC[-4],0)"><Data ss:Type="Number"></Data></Cell>' + CRLF //
					cPrdItemXML += '<Cell ss:StyleID="sComDig" ss:Formula="=SUMIF(R[2]C1:R[20]C1,RC2,R[2]C:R[20]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
				EndIf
			
			Else
				
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				// Cabeçalho 
				if lTotProd
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					//cPrdItemXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					//cPrdItemXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Imposto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					//cPrdItemXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo MN</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
					//cPrdItemXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo MS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
				EndIf
			
			EndIf
			dDia_nI += 1
		EndDo
		
		dDia_nJ := sToD( (_cAlias1)->EMISSAO )+1 // controle para a parte abaixo
		(_cAlias1)->(DbSkip())		// U_VAESTM02()
		
		if cInsumo <> (_cAlias1)->D3_COD .or. (_cAlias1)->(Eof())
			While dDia_nJ <= MV_PAR02 // parte abaixo
				if lTotProd
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
					//cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF


				EndIf
				
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
				
				dDia_nJ += 1
			EndDo
			
			if lTotProd
				cPrdItemXML += '<Cell ss:StyleID="sComDig" ss:Formula="=SUMIF(R5C5:R5C[-2],R5C,RC5:RC[-2])"><Data ss:Type="Number"></Data></Cell>' + CRLF
				cPrdItemXML += '<Cell ss:StyleID="sComDig" ss:Formula="=AVERAGEIF(R5C5:R5C[-3],R5C[-1],RC5:RC[-3])"><Data ss:Type="Number"></Data></Cell>' + CRLF
				cPrdItemXML += '<Cell ss:StyleID="sReal" ss:Formula="=SUMIF(R5C5:R5C[-4],R5C,RC5:RC[-4])"><Data ss:Type="Number"></Data></Cell>' + CRLF
				cPrdItemXML += '<Cell ss:StyleID="sReal" ss:Formula="=RC[-1]/RC[-3]"><Data ss:Type="Number"></Data></Cell>' + CRLF
				cPrdItemXML += '<Cell ss:StyleID="sComDig" ss:Formula="=AVERAGEIF(R5C5:R5C[-6],R5C[0],RC5:RC[-6])"><Data ss:Type="Number"></Data></Cell>' + CRLF
				cPrdItemXML += '<Cell ss:StyleID="s16"/>' + CRLF
				cPrdItemXML += '<Cell ss:StyleID="sReal" ss:Formula="=SUMIF(R[2]C1:R[20]C1,RC2,R[2]C:R[20]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
				cPrdItemXML += '<Cell ss:StyleID="sSemDig" ss:Formula="=RC[-1]/RC[-5]-1"><Data ss:Type="Number"></Data></Cell>' + CRLF
				cPrdItemXML += '<Cell ss:StyleID="sReal" ss:Formula="=RC[-5]+(RC[-5]*RC[-1])"><Data ss:Type="Number"></Data></Cell>' + CRLF
				cPrdItemXML += '<Cell ss:StyleID="sReal" ss:Formula="=RC[-1]/RC[-5]"><Data ss:Type="Number"></Data></Cell>' + CRLF
			EndIf
			
			/*Totalizador Coluna Produto*/
			cXMLTmp += '<Cell ss:StyleID="sComDig" ss:Formula="=SUMIF(R5C5:R5C[-2],R5C,RC5:RC[-2])"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="sComDig" ss:Formula="=AVERAGEIF(R5C5:R5C[-2],R5C[-1],RC5:RC[-2])"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="sReal" ss:Formula="=SUMIF(R5C5:R5C[-2],R5C,RC5:RC[-2])"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="sReal" ss:Formula="=RC[-1]/RC[-3]"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="sComDig" ss:Formula="=IFERROR(VLOOKUP(RC3,'+"'Compras Total'"+'!R5C2:R196C7,6,FALSE),0)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			//cXMLTmp += '<Cell ss:StyleID="sReal" ss:Formula="=RC[-4]+(RC[-4]*RC[-1])"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="sReal" ss:Formula="=RC[-4]/(1-RC[-1])"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="s16"/>' + CRLF
			cXMLTmp += '<Cell ss:StyleID="sReal" ss:Formula="=RC[-3]/RC[-9]*1000"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXMLTmp += '</Row>' + CRLF
			
			cXML += cPrdItemXML + cXMLTmp
			cPrdItemXML := ""
			cXMLTmp		:= ""
			lTotProd	:= .F.
			nLinPerc+=1
			
			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
			EndIf
			cXML := ""	
		EndIf
	EndDo
	
	// Final da Planilha
	cXML += ' </Table>' + CRLF
	cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += ' 	<PageSetup>' + CRLF
	cXML += ' 		<Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += ' 	</PageSetup>' + CRLF
	cXML += ' 	<Unsynced/>' + CRLF
	cXML += ' 	<Selected/>' + CRLF
	cXML += ' 	<FreezePanes/>' + CRLF
	cXML += ' 	<FrozenNoSplit/>' + CRLF
	cXML += ' 	<SplitHorizontal>2</SplitHorizontal>' + CRLF
	cXML += ' 	<TopRowBottomPane>2</TopRowBottomPane>' + CRLF
	cXML += ' 	<SplitVertical>4</SplitVertical>' + CRLF
	cXML += ' 	<LeftColumnRightPane>20</LeftColumnRightPane>' + CRLF
	cXML += ' 	<ActivePane>0</ActivePane>' + CRLF
	cXML += ' 	<Panes>' + CRLF
	cXML += ' 		<Pane>' + CRLF
	cXML += ' 			<Number>3</Number>' + CRLF
	cXML += ' 		</Pane>' + CRLF
	cXML += ' 		<Pane>' + CRLF
	cXML += ' 			<Number>1</Number>' + CRLF
	cXML += ' 			<ActiveCol>4</ActiveCol>' + CRLF
	cXML += ' 		</Pane>' + CRLF
	cXML += ' 		<Pane>' + CRLF
	cXML += ' 			<Number>2</Number>' + CRLF
	cXML += ' 		</Pane>' + CRLF
	cXML += ' 		<Pane>' + CRLF
	cXML += ' 			<Number>0</Number>' + CRLF
	cXML += ' 			<ActiveRow>5</ActiveRow>' + CRLF
	cXML += ' 			<ActiveCol>24</ActiveCol>' + CRLF
	cXML += ' 		</Pane>' + CRLF
	cXML += ' 	</Panes>' + CRLF
	cXML += ' 	<ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += ' 	<ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += ' 	</WorksheetOptions>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
	
EndIf	

Return nil
// FIM: fQuadro1



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAESTM02()                                      |
 | Func:  fQuadro2()	                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  12.04.2019                                                              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |        - Agrupamento                                                           |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro2()	 // U_VAESTM02()

Local cXML 			:= ""
Local cWorkSheet 	:= "Custo Agrupado"
Local cProduto		:= ""
Local dDia_nI		:= MV_PAR01
Local nQtDias 		:= MV_PAR02 - MV_PAR01
Local nLin 			:= 0


(_cAlias2)->(DbGoTop()) 
If !(_cAlias2)->(Eof())

	// Inicio // fQuadro1 -> "Custo da Ração"
	cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
	cXML += '   <Column ss:Width="36"/>' + CRLF
    cXML += '   <Column ss:Index="3" ss:Width="149.25"/>' + CRLF
    cXML += '   <Column ss:Width="40.5"/>' + CRLF
    cXML += '   <Column ss:Width="57"/>' + CRLF
    cXML += '   <Column ss:Width="87.75"/>' + CRLF
    cXML += '   <Column ss:Width="55.5"/>' + CRLF
    cXML += '   <Column ss:Width="86.25"/>' + CRLF
	cXML += '   <Column ss:Width="88.25"/>' + CRLF
	cXML += ' <Row ss:Height="36">' + CRLF
	cXML += '<Cell ss:MergeAcross="07" ss:StyleID="s62">' + CRLF
	cXML += '     <Data ss:Type="String">RELATÓRIO DE CUSTOS DA RAÇÃO - AGRUPADO</Data>' + CRLF
	cXML += '   </Cell>' + CRLF
	cXML += ' </Row>' + CRLF

	cXML += ' <Row ss:Height="33">' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Código</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Produto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">UN</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Emissão</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Quant.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo Unit.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Quant. MS Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">% MS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">R$ KG MS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' </Row>' + CRLF
	
	//fQuadro1
	While !(_cAlias2)->(Eof())	 // U_VAESTM02()
		
		nLin += 1
 
		cXML += '<Row>' + CRLF
		if cProduto <> (_cAlias2)->CODIGO
			cProduto := (_cAlias2)->CODIGO
			
			cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias2)->FILIAL    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias2)->CODIGO    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias2)->DESCRICAO ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
			cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias2)->UM 	   	  ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
			cXML += '<Cell ss:StyleID="s16"/>' + CRLF
			cXML += '<Cell ss:StyleID="s16"/>' + CRLF
			cXML += '<Cell ss:StyleID="s16"/>' + CRLF
			cXML += '<Cell ss:StyleID="s16"/>' + CRLF
		EndIf
		cXML += '<Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sToD((_cAlias2)->EMISSAO)) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAlias2)->QUANTIDADE	   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[1]/RC[-1],0)"><Data ss:Type="Number"></Data></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sReal"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias2)->CUSTOTOAL	   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAlias2)->TOTAL_MS	   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sComDig" ss:Formula="=IFERROR(RC[-1]/RC[-4]*100,0)"><Data ss:Type="Number"></Data></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[-4]/RC[-1]*100,0)"><Data ss:Type="Number"></Data></Cell>' + CRLF
		cXML += ' </Row>' + CRLF
		
		(_cAlias2)->(DbSkip())
		
		if cProduto <> (_cAlias2)->CODIGO .or. (_cAlias2)->(Eof())
			cXML += '<Row>' + CRLF
			cXML += '	<Cell ss:Index="6" ss:StyleID="sComDig" ss:Formula="=SUM(R[-'+cValToChar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXML += '	<Cell ss:Index="7" ss:StyleID="sRealN" ss:Formula="=AVERAGE(R[-'+cValToChar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXML += '	<Cell ss:Index="8" ss:StyleID="sRealN" ss:Formula="=SUM(R[-'+cValToChar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXML += '	<Cell ss:Index="9" ss:StyleID="sComDig" ss:Formula="=SUM(R[-'+cValToChar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXML += '	<Cell ss:Index="10" ss:StyleID="sComDig" ss:Formula="=AVERAGE(R[-'+cValToChar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXML += '	<Cell ss:Index="11" ss:StyleID="sRealN" ss:Formula="=AVERAGE(R[-'+cValToChar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXML += '</Row>' + CRLF
			
			cXML += '<Row><Cell ss:StyleID="s16"/></Row>' + CRLF // pular linha
			cXML += '<Row><Cell ss:StyleID="s16"/></Row>' + CRLF // pular linha
			
			nLin := 0
		EndIf
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""	
	EndDo
	
	// Final da Planilha
	cXML += ' </Table>' + CRLF
	cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += ' 	<PageSetup>' + CRLF
	cXML += ' 		<Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += ' 	</PageSetup>' + CRLF
	cXML += ' 	<Unsynced/>' + CRLF
	cXML += ' 	<Selected/>' + CRLF
	cXML += ' 	<FreezePanes/>' + CRLF
	cXML += ' 	<FrozenNoSplit/>' + CRLF
	cXML += ' 	<SplitHorizontal>2</SplitHorizontal>' + CRLF
	cXML += ' 	<TopRowBottomPane>2</TopRowBottomPane>' + CRLF
	cXML += ' 	<SplitVertical>4</SplitVertical>' + CRLF
	cXML += ' 	<LeftColumnRightPane>20</LeftColumnRightPane>' + CRLF
	cXML += ' 	<ActivePane>0</ActivePane>' + CRLF
	cXML += ' 	<Panes>' + CRLF
	cXML += ' 		<Pane>' + CRLF
	cXML += ' 			<Number>3</Number>' + CRLF
	cXML += ' 		</Pane>' + CRLF
	cXML += ' 		<Pane>' + CRLF
	cXML += ' 			<Number>1</Number>' + CRLF
	cXML += ' 			<ActiveCol>4</ActiveCol>' + CRLF
	cXML += ' 		</Pane>' + CRLF
	cXML += ' 		<Pane>' + CRLF
	cXML += ' 			<Number>2</Number>' + CRLF
	cXML += ' 		</Pane>' + CRLF
	cXML += ' 		<Pane>' + CRLF
	cXML += ' 			<Number>0</Number>' + CRLF
	cXML += ' 			<ActiveRow>5</ActiveRow>' + CRLF
	cXML += ' 			<ActiveCol>24</ActiveCol>' + CRLF
	cXML += ' 		</Pane>' + CRLF
	cXML += ' 	</Panes>' + CRLF
	cXML += ' 	<ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += ' 	<ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += ' 	</WorksheetOptions>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
	
EndIf
Return nil
// FIM: fQuadro2

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAESTM02()                                      |
 | Func:  fQuadro3()	                                                          |
 | Autor: Arthur Toshio Oda Vanzella                                              |
 | Data:  13.07.2020                                                              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |        - Compras Detalhado                                                     |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro3()	 // U_VAESTM02()

Local cXML 			:= ""
Local cWorkSheet 	:= "Compras Detalhado"
Local cProduto		:= ""
Local dDia_nI		:= MV_PAR01
Local nQtDias 		:= MV_PAR02 - MV_PAR01
Local nLin 			:= 0


(_cAlias3)->(DbGoTop()) 
If !(_cAlias3)->(Eof())

	// Inicio // fQuadro1 -> "Custo da Ração"
	cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
	/*01*/cXML += '   <Column ss:Width="70"/>' + CRLF
	/*02*/cXML += '   <Column ss:Width="70"/>' + CRLF
	/*03*/cXML += '   <Column ss:Width="70"/>' + CRLF
	/*04*/cXML += '   <Column ss:Width="70"/>' + CRLF
	/*05*/cXML += '   <Column ss:Width="70"/>' + CRLF
    /*06*/cXML += '   <Column ss:Width="200"/>' + CRLF
    /*07*/cXML += '   <Column ss:Width="70"/>' + CRLF
    /*08*/cXML += '   <Column ss:Width="180"/>' + CRLF
    /*09*/cXML += '   <Column ss:Width="75"/>' + CRLF
    /*10*/cXML += '   <Column ss:Width="75"/>' + CRLF
    /*11*/cXML += '   <Column ss:Width="75"/>' + CRLF
	/*12*/cXML += '   <Column ss:Width="75"/>' + CRLF
	cXML += ' <Row ss:Height="36">' + CRLF
	cXML += '<Cell ss:MergeAcross="11" ss:StyleID="s62">' + CRLF
	cXML += '     <Data ss:Type="String">RELAÇÃO DOS RECEBIMENTOS DAS COMPRAS DE INSUMO</Data>' + CRLF
	cXML += '   </Cell>' + CRLF
	cXML += ' </Row>' + CRLF

	cXML += ' <Row ss:Height="33">' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Data de:</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Data Até:</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' </Row>' + CRLF
	cXML += '<Row>' + CRLF
	cXML += '<Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( MV_PAR03) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( MV_PAR04) +  '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' </Row>' + CRLF
	
	cXML += ' <Row ss:Height="33">' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Mês</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Num NF</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Dt Emissão</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Dt Digitação</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Cod Forn.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Razão Social</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Produto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Descrição</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Peso NF</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">R$ KG</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">R$ Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">% Imposto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Peso Balanção</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' </Row>' + CRLF

	While !(_cAlias3)->(Eof())	 // U_VAESTM02()
	nLin += 1
 
	cXML += '<Row>' + CRLF
		cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias3)->MES    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
		cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias3)->NOTA    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
		cXML += '<Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sToD((_cAlias3)->EMISSAO)) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sToD((_cAlias3)->D1_DTDIGIT)) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias3)->COD_FOR    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
		cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias3)->A2_NOME    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
		cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias3)->D1_COD    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
		cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias3)->B1_DESC    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
		cXML += '<Cell ss:StyleID="sComDig"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias3)->D1_QUANT	   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[1]/RC[-1],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sReal"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias3)->D1_TOTAL	   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sReal"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias3)->D1_CUSTO	   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sComDig" ss:Formula="=IFERROR(RC[-1]/RC[-2]-1,0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sComDig"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias3)->D1_X_PESOB	   ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += ' </Row>' + CRLF
		
		(_cAlias3)->(DbSkip())
	EndDo

// Final da Planilha
	cXML += ' </Table>' + CRLF
	cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += ' 	<PageSetup>' + CRLF
	cXML += ' 		<Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += ' 	</PageSetup>' + CRLF
	cXML += ' 	<Unsynced/>' + CRLF
	cXML += ' 	<Selected/>' + CRLF
	cXML += ' 	<FreezePanes/>' + CRLF
	cXML += ' 	<FrozenNoSplit/>' + CRLF
	cXML += ' 	<SplitHorizontal>4</SplitHorizontal>' + CRLF
	cXML += ' 	<TopRowBottomPane>4</TopRowBottomPane>' + CRLF
	cXML += '   <ActivePane>2</ActivePane>
 	cXML += '     <Panes>
 	cXML += '      <Pane>
 	cXML += '       <Number>3</Number>
 	cXML += '      </Pane>
 	cXML += '      <Pane>
 	cXML += '       <Number>2</Number>
 	cXML += '       <RangeSelection>R5</RangeSelection>
 	cXML += '      </Pane>
 	cXML += '     </Panes>
 	cXML += '     <ProtectObjects>False</ProtectObjects>
 	cXML += '     <ProtectScenarios>False</ProtectScenarios>
 	cXML += '    </WorksheetOptions>
 	cXML += '   </Worksheet>
	
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
	

EndIf
Return nil


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAESTM02()                                      |
 | Func:  fQuadro4()	                                                          |
 | Autor: Arthur Toshio Oda Vanzella                                              |
 | Data:  13.07.2020                                                              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |        - Compras Detalhado                                                     |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro4()	 // U_VAESTM02()

Local cXML 			:= ""
Local cWorkSheet 	:= "Compras Mensal"
Local cProduto		:= ""
Local dDia_nI		:= MV_PAR01
Local nQtDias 		:= MV_PAR02 - MV_PAR01
Local nLin 			:= 0


(_cAlias4)->(DbGoTop()) 
If !(_cAlias4)->(Eof())

	// Inicio // fQuadro1 -> "Custo da Ração"
	cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
	/*01*/cXML += '   <Column ss:Width="70"/>' + CRLF
	/*02*/cXML += '   <Column ss:Width="200"/>' + CRLF
	/*03*/cXML += '   <Column ss:Width="70"/>' + CRLF
	/*04*/cXML += '   <Column ss:Width="70"/>' + CRLF
	/*05*/cXML += '   <Column ss:Width="70"/>' + CRLF
    /*06*/cXML += '   <Column ss:Width="70"/>' + CRLF
    /*07*/cXML += '   <Column ss:Width="70"/>' + CRLF
    /*08*/cXML += '   <Column ss:Width="70"/>' + CRLF
    /*09*/cXML += '   <Column ss:Width="75"/>' + CRLF
    /*10*/cXML += '   <Column ss:Width="75"/>' + CRLF
    /*11*/cXML += '   <Column ss:Width="75"/>' + CRLF
	/*12*/cXML += '   <Column ss:Width="75"/>' + CRLF
	cXML += ' <Row ss:Height="36">' + CRLF
	cXML += '<Cell ss:MergeAcross="11" ss:StyleID="s62">' + CRLF
	cXML += '     <Data ss:Type="String">RELAÇÃO DOS RECEBIMENTOS DAS COMPRAS DE INSUMO</Data>' + CRLF
	cXML += '   </Cell>' + CRLF
	cXML += ' </Row>' + CRLF

	cXML += ' <Row ss:Height="33">' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Data de:</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Data Até:</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' </Row>' + CRLF
	cXML += '<Row>' + CRLF
	cXML += '<Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( MV_PAR03) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( MV_PAR04) +  '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' </Row>' + CRLF
	
	cXML += ' <Row ss:Height="33">' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Produto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Descrição</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Mês</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Peso NF</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">R$ KG</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Valor Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo (Sem Impostos)</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">% Imposto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Peso Balanção</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' </Row>' + CRLF

	While !(_cAlias4)->(Eof())	 // U_VAESTM02()
	nLin += 1
 
	cXML += '<Row>' + CRLF
		cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias4)->D1_COD     ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
		cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias4)->B1_DESC    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
		cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias4)->MES        ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
		cXML += '<Cell ss:StyleID="sComDig"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias4)->QTDE	    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[1]/RC[-1],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sReal"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias4)->VALTOT    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sReal"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias4)->CUSTO	    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sComDig" ss:Formula="=IFERROR(1-(RC[-1]/RC[-2]),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sComDig"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias4)->PESO_BALA ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' </Row>' + CRLF
		
		(_cAlias4)->(DbSkip())
	EndDo

// Final da Planilha
	cXML += ' </Table>' + CRLF
	cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += ' 	<PageSetup>' + CRLF
	cXML += ' 		<Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += ' 	</PageSetup>' + CRLF
	cXML += ' 	<Unsynced/>' + CRLF
	cXML += ' 	<Selected/>' + CRLF
	cXML += ' 	<FreezePanes/>' + CRLF
	cXML += ' 	<FrozenNoSplit/>' + CRLF
	cXML += ' 	<SplitHorizontal>4</SplitHorizontal>' + CRLF
	cXML += ' 	<TopRowBottomPane>4</TopRowBottomPane>' + CRLF
	cXML += '   <ActivePane>2</ActivePane>
 	cXML += '     <Panes>
 	cXML += '      <Pane>
 	cXML += '       <Number>3</Number>
 	cXML += '      </Pane>
 	cXML += '      <Pane>
 	cXML += '       <Number>2</Number>
 	cXML += '       <RangeSelection>R5</RangeSelection>
 	cXML += '      </Pane>
 	cXML += '     </Panes>
 	cXML += '     <ProtectObjects>False</ProtectObjects>
 	cXML += '     <ProtectScenarios>False</ProtectScenarios>
 	cXML += '    </WorksheetOptions>
 	cXML += '   </Worksheet>
		
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
	

EndIf
Return nil

Static Function fQuadro5()	 // U_VAESTM02()

Local cXML 			:= ""
Local cWorkSheet 	:= "Compras Total"
Local cProduto		:= ""
Local dDia_nI		:= MV_PAR01
Local nQtDias 		:= MV_PAR02 - MV_PAR01
Local nLin 			:= 0


(_cAlias5)->(DbGoTop()) 
If !(_cAlias5)->(Eof())

	// Inicio // fQuadro1 -> "Custo da Ração"
	cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
	/*01*/cXML += '   <Column ss:Width="70"/>' + CRLF
	/*02*/cXML += '   <Column ss:Width="200"/>' + CRLF
	/*03*/cXML += '   <Column ss:Width="70"/>' + CRLF
	/*05*/cXML += '   <Column ss:Width="70"/>' + CRLF
    /*06*/cXML += '   <Column ss:Width="70"/>' + CRLF
    /*07*/cXML += '   <Column ss:Width="70"/>' + CRLF
    /*08*/cXML += '   <Column ss:Width="70"/>' + CRLF
    /*09*/cXML += '   <Column ss:Width="75"/>' + CRLF
    /*10*/cXML += '   <Column ss:Width="75"/>' + CRLF
    /*11*/cXML += '   <Column ss:Width="75"/>' + CRLF
	/*12*/cXML += '   <Column ss:Width="75"/>' + CRLF
	cXML += ' <Row ss:Height="36">' + CRLF
	cXML += '<Cell ss:MergeAcross="11" ss:StyleID="s62">' + CRLF
	cXML += '     <Data ss:Type="String">RELAÇÃO DOS RECEBIMENTOS DAS COMPRAS DE INSUMO TOTAL NO PERÍODO</Data>' + CRLF
	cXML += '   </Cell>' + CRLF
	cXML += ' </Row>' + CRLF

	cXML += ' <Row ss:Height="33">' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Data de:</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Data Até:</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' </Row>' + CRLF
	cXML += '<Row>' + CRLF
	cXML += '<Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( MV_PAR03) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( MV_PAR04) +  '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' </Row>' + CRLF
	
	cXML += ' <Row ss:Height="33">' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Produto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Descrição</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Peso NF</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">R$ KG</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Valor Total</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Custo (Sem Impostos)</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">% Imposto</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '<Cell ss:StyleID="s65"><Data ss:Type="String">Peso Balanção</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' </Row>' + CRLF

	While !(_cAlias5)->(Eof())	 // U_VAESTM02()
	nLin += 1
 
	cXML += '<Row>' + CRLF
		cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias5)->D1_COD     ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
		cXML += '<Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAlias5)->B1_DESC    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF	
		cXML += '<Cell ss:StyleID="sComDig"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias5)->QTDE	    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sReal" ss:Formula="=IFERROR(RC[1]/RC[-1],0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sReal"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias5)->VALTOT    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sReal"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias5)->CUSTO	    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sComDig" ss:Formula="=IFERROR(1-(RC[-1]/RC[-2]),0)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '<Cell ss:StyleID="sComDig"><Data ss:Type="Number">'  + U_FrmtVlrExcel( (_cAlias5)->PESO_BALA ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' </Row>' + CRLF
		
		(_cAlias5)->(DbSkip())
	EndDo

// Final da Planilha
	cXML += ' </Table>' + CRLF
	cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += ' 	<PageSetup>' + CRLF
	cXML += ' 		<Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += ' 	</PageSetup>' + CRLF
	cXML += ' 	<Unsynced/>' + CRLF
	cXML += ' 	<Selected/>' + CRLF
	cXML += ' 	<FreezePanes/>' + CRLF
	cXML += ' 	<FrozenNoSplit/>' + CRLF
	cXML += ' 	<SplitHorizontal>4</SplitHorizontal>' + CRLF
	cXML += ' 	<TopRowBottomPane>4</TopRowBottomPane>' + CRLF
	cXML += '   <ActivePane>2</ActivePane>
 	cXML += '     <Panes>
 	cXML += '      <Pane>
 	cXML += '       <Number>3</Number>
 	cXML += '      </Pane>
 	cXML += '      <Pane>
 	cXML += '       <Number>2</Number>
 	cXML += '       <RangeSelection>R5</RangeSelection>
 	cXML += '      </Pane>
 	cXML += '     </Panes>
 	cXML += '     <ProtectObjects>False</ProtectObjects>
 	cXML += '     <ProtectScenarios>False</ProtectScenarios>
 	cXML += '    </WorksheetOptions>
 	cXML += '   </Worksheet>
		
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
	

EndIf
Return nil


// U_VAESTM02()dd

/* 
http://tdn.totvs.com/pages/releaseview.action?pageId=39682606

DlgToExcel
Gerar automaticamente excel, gera excel, gerar excel automaticamente,

MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
		{||DlgToExcel({{"GETDADOS",;
			"POSIÇÃO DE TÍTULOS DE VENDOR NO PERÍODO",;
			aCabExcel,aItensExcel}})})

 */

 	