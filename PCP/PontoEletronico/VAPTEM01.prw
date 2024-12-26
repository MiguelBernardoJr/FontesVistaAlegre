#include "PROTHEUS.CH"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"
#include "colors.ch"
#INCLUDE "TBICONN.CH"

/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     30.01.2019                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Relatorio para analise de divergencias nas batidas do ponto           |
 |           eletronico;                                                           |
 |---------------------------------------------------------------------------------|
 | Regras:                                                                         |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     U_VAPTEM01()                                                          |
 '---------------------------------------------------------------------------------*/
User Function VAPTEM01()

Local lTemDados		:= .T.

Private cTitulo  	:= "Relatorio de batidas de ponto eletronico"
Private cPerg		:= "VAPTEM01"

Private cPath 	 	:= "C:\totvs_relatorios\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+ "_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()   

Private nRegistros	:= 0

GeraX1(cPerg)

If Pergunte(cPerg, .T.)

	U_PrintSX1(cPerg)
		
	If Len( Directory(cPath + "*.*","D") ) == 0
		If Makedir(cPath) == 0
			ConOut('Diretorio Criado com Sucesso.')
		Else	
			ConOut( "Nao foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
		EndIf
	EndIf

	nHandle := FCreate(cArquivo)
	if nHandle = -1
		conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
		conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	else
		
		cStyle := U_defStyle()
		cStyle += ' <Style ss:ID="s89" ss:Parent="s16">'+CRLF
		cStyle += ' 	<NumberFormat ss:Format="[&lt;2]General\ &quot;Dia&quot;;General\ &quot;Dias&quot;"/>'+CRLF
		cStyle += ' </Style>'+CRLF
		cStyle += ' <Style ss:ID="s92">'+CRLF
		cStyle += ' 	<NumberFormat ss:Format="[&lt;2]General\ &quot;Minuto&quot;;General\ &quot;Minutos&quot;"/>'+CRLF
		cStyle += ' </Style>'+CRLF
		cStyle += ' <Style ss:ID="s93" ss:Parent="s16">'+CRLF
		cStyle += ' 	<NumberFormat ss:Format="[&lt;2]General\ &quot;Hora&quot;;General\ &quot;Horas&quot;"/>'+CRLF
		cStyle += ' </Style>'+CRLF
		cStyle += ' <Style ss:ID="sTitLaranja" ss:Parent="s62">'+CRLF
		cStyle += ' <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF
		cStyle += ' <Borders>'+CRLF
		cStyle += ' 	<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#37752F"/>'+CRLF
		cStyle += ' 	<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#37752F"/>'+CRLF
		cStyle += ' </Borders>'+CRLF
		cStyle += ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>'+CRLF
		cStyle += ' <Interior ss:Color="#FFC000" ss:Pattern="Solid"/>'+CRLF
		cStyle += ' </Style>'+CRLF
		
		// Processar SQL
		FWMsgRun(, {|| lTemDados := processSQL( "Geral" , @_cAliasG) },'Por Favor Aguarde...' , 'Processando Banco de Dados')
		If lTemDados
			cXML := U_CabXMLExcel(cStyle)

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geraçao do quadro de Banco de Horas')
			FWMsgRun(, {|| fQuadro2() },'Gerando excel, Por Favor Aguarde...', 'Geraçao do quadro de Batidas')
			FWMsgRun(, {|| fQuadro3() },'Gerando excel, Por Favor Aguarde...', 'Geraçao do quadro de Resumos')
			
			// Final - encerramento do arquivo
			FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )
			
			FClose(nHandle)

			If ApOleClient("MSExcel")				// U_VAPTEM01()
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( cArquivo )
				oExcelApp:SetVisible(.T.)
				oExcelApp:Destroy()	
				// ou >  ShellExecute( "Open", cNameFile , '', '', 1 ) //Abre o arquivo na tela após salvar 
			Else
				MsgAlert("O Excel nao foi encontrado. Arquivo " + cArquivo + " gerado em " + cPath + ".", "MsExcel nao encontrado" )
			EndIf
			
		Else
			MsgAlert("Os parametros informados nao retornou nenhuma informaçao do banco de dados." + CRLF + ;
					 "Por isso o excel nao sera aberto automaticamente.", "Dados nao localizados")
		EndIf

		(_cAliasG)->(DbCloseArea())
	EndIf
EndIf

Return nil



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAFINM02()                                      |
 | Func:  GeraX1()                                                                |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  01.02.2019                                                              |
 | Desc:                                                                          |
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

aAdd(aRegs,{cPerg, "01", "Data da Batida De?"      , "", "", "MV_CH1", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR01", ""    , "","","","",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Data da Batida Ate?"     , "", "", "MV_CH2", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "NaoVazio", "MV_PAR02", ""    , "","","","",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "03", "Matricula De?"      	   , "", "", "MV_CH3", "C", TamSX3("P8_MAT")[1]    , TamSX3("P8_MAT")[2]    , 0, "G", "        ", "MV_PAR03", ""    , "","","","",""   ,"","","","","","","","","","","","","","","","","","","SRA","","","","",""})
aAdd(aRegs,{cPerg, "04", "Matricula Ate?"      	   , "", "", "MV_CH4", "C", TamSX3("P8_MAT")[1]    , TamSX3("P8_MAT")[2]    , 0, "G", "NaoVazio", "MV_PAR04", ""    , "","","","",""   ,"","","","","","","","","","","","","","","","","","","SRA","","","","",""})
// aAdd(aRegs,{cPerg, "05", "Somente Extraordinarios?", "", "", "MV_CH5", "N", 					  1,					   0, 2, "C", ""        , "MV_PAR05", "Tudo", "","","","","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})

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

// gravaçao das perguntas na tabela SX1
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
 | Principal: 					U_VAPTEM01()                                      |
 | Func:                                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  30.01.2019                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function processSQL(cTipo, _cAlias)
Local _cQry := ""

If cTipo == "Geral"

	_cQry := " WITH" + CRLF
	_cQry += " SP8 AS (" + CRLF
	_cQry += " SELECT	  row_number() over (PARTITION BY P8_FILIAL, P8_MAT, P8_DATAAPO order by P8_HORA) ID" + CRLF
 	_cQry += " 		, P8_FILIAL " + CRLF
  	_cQry += " 		, P8_MAT" + CRLF
  	_cQry += " 		, P8_ORDEM, P8_DATA, P8_DATAAPO" + CRLF
  	_cQry += " 		, P8_TURNO " + CRLF
  	_cQry += " 		, DATEPART(w, P8_DATAAPO) SEMANA" + CRLF
	_cQry += " 		, CASE WHEN P8_SEMANA=''" + CRLF
	_cQry += " 		  THEN" + CRLF
	_cQry += " 		  (" + CRLF
	_cQry += " 		    	SELECT TOP 1 PF_SEQUEPA" + CRLF
	_cQry += " 		    	FROM SPF010" + CRLF
	_cQry += " 		    	WHERE" + CRLF
	_cQry += " 		    		P8_FILIAL=PF_FILIAL AND P8_MAT=PF_MAT AND PF_DATA <= P8_DATA" + CRLF
	_cQry += " 		    	ORDER BY R_E_C_N_O_ DESC" + CRLF
	_cQry += " 		    )" + CRLF
	_cQry += " 		  ELSE P8_SEMANA END P8_SEMANA" + CRLF
	_cQry += " 		, P8_APONTA" + CRLF
  	_cQry += " 		, P8_HORA" + CRLF
  	_cQry += " 		, P8_MOTIVRG" + CRLF
 	_cQry += " 		, P8.R_E_C_N_O_" + CRLF
 	_cQry += " FROM	  SP8010 P8" + CRLF
	_cQry += " 	WHERE	 P8.P8_FILIAL BETWEEN '  ' AND 'ZZ' " + CRLF
	_cQry += " 	     AND P8.P8_DATA BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' " + CRLF
	_cQry += " 		 AND P8.P8_MAT BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + CRLF
	_cQry += " 		 AND P8_APONTA='S'" + CRLF
	_cQry += " 		 AND P8_TPMCREP<>'D'" + CRLF
 	_cQry += " 		 AND P8.D_E_L_E_T_ = ' '" + CRLF
	_cQry += " )" + CRLF
    _cQry += " " + CRLF
	_cQry += " , SPH_SP8 AS (" + CRLF
	_cQry += " 	SELECT DISTINCT PH_FILIAL, PH_MAT, PH_DATA, PH_SEMANA" + CRLF
	_cQry += " 	FROM SP8" + CRLF
	_cQry += " 	LEFT JOIN SPH010 PH ON PH_FILIAL=P8_FILIAL AND PH_MAT=P8_MAT AND PH_DATA=P8_DATAAPO AND PH.D_E_L_E_T_=' '" + CRLF
	_cQry += " )" + CRLF
    _cQry += " " + CRLF
 	_cQry += " , DADOS_P8 AS (" + CRLF
	_cQry += " 	 SELECT P8.* " + CRLF
  	_cQry += " 		, ISNULL(PJ_ENTRA1,0) PJ_ENTRA1, ISNULL(PJ_SAIDA1,0) PJ_SAIDA1, ISNULL(PJ_ENTRA2,0) PJ_ENTRA2, ISNULL(PJ_SAIDA2,0) PJ_SAIDA2 " + CRLF
    _cQry += " " + CRLF
	_cQry += " 	 FROM SP8 P8" + CRLF
	_cQry += " 	 LEFT JOIN SPH_SP8 PH ON PH_FILIAL=P8_FILIAL AND PH_MAT=P8_MAT AND PH_DATA=P8_DATAAPO" + CRLF
	_cQry += " 	 LEFT JOIN SPJ010 PJ ON PJ_FILIAL=' ' " + CRLF
 	_cQry += " 		AND P8_TURNO				= PJ_TURNO" + CRLF
 	_cQry += " 		-- AND CASE " + CRLF
 	_cQry += " 		-- 		WHEN P8_SEMANA		!= '  '" + CRLF
 	_cQry += " 		-- 			THEN P8_SEMANA" + CRLF
	_cQry += " 		-- 			ELSE PH_SEMANA" + CRLF
	_cQry += " 		-- 			END = PJ_SEMANA -- ='01'" + CRLF
	_cQry += " 		AND P8_SEMANA = PJ_SEMANA" + CRLF
 	_cQry += " 		AND DATEPART(w, P8_DATAAPO)	= PJ_DIA" + CRLF
 	_cQry += " 		AND P8_APONTA				= PJ_TPDIA" + CRLF
 	_cQry += " 		AND PJ.D_E_L_E_T_ = ' '" + CRLF
	_cQry += " )" + CRLF
    _cQry += " " + CRLF
	_cQry += " , SPG AS (" + CRLF
	_cQry += " SELECT	  row_number() over (PARTITION BY PG_FILIAL, PG_MAT, PG_DATAAPO order by PG_HORA) ID" + CRLF
 	_cQry += " 		, PG_FILIAL " + CRLF
  	_cQry += " 		, PG_MAT" + CRLF
  	_cQry += " 		, PG_ORDEM, PG_DATA, PG_DATAAPO" + CRLF
  	_cQry += " 		, PG_TURNO " + CRLF
  	_cQry += " 		, DATEPART(w, PG_DATAAPO) SEMANA" + CRLF
	_cQry += " 		, CASE WHEN PG_SEMANA=''" + CRLF
	_cQry += "		  THEN" + CRLF
	_cQry += "		  (" + CRLF
	_cQry += "		    	SELECT TOP 1 PF_SEQUEPA" + CRLF
	_cQry += "		    	FROM SPF010" + CRLF
	_cQry += "		    	WHERE" + CRLF
	_cQry += "		    		PG_FILIAL=PF_FILIAL AND PG_MAT=PF_MAT AND PF_DATA <= PG_DATA" + CRLF
	_cQry += "		    	ORDER BY R_E_C_N_O_ DESC" + CRLF
	_cQry += "		    )" + CRLF
	_cQry += "		    ELSE PG_SEMANA END PG_SEMANA" + CRLF
	_cQry += " 		, PG_APONTA" + CRLF
  	_cQry += " 		, PG_HORA" + CRLF
  	_cQry += " 		, PG_MOTIVRG" + CRLF
 	_cQry += " 		, PG.R_E_C_N_O_" + CRLF
 	_cQry += " FROM	 SPG010 PG" + CRLF
	_cQry += " 	WHERE	 PG.PG_DATA BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' " + CRLF
	_cQry += " 		 AND PG.PG_MAT BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + CRLF
	_cQry += " 		 AND PG_APONTA='S'" + CRLF
	_cQry += " 		 AND PG_TPMCREP<>'D'" + CRLF
 	_cQry += " 		 AND PG.D_E_L_E_T_ = ' '" + CRLF
	_cQry += " )" + CRLF
    _cQry += " " + CRLF
	_cQry += " , SPH_SPG AS (" + CRLF
	_cQry += " 	SELECT DISTINCT PH_FILIAL, PH_MAT, PH_DATA, PH_SEMANA" + CRLF
	_cQry += " 	FROM SPG" + CRLF
	_cQry += " 	LEFT JOIN SPH010 PH ON PH_FILIAL=PG_FILIAL AND PH_MAT=PG_MAT AND PH_DATA=PG_DATAAPO AND PH.D_E_L_E_T_=' '" + CRLF
	_cQry += " )" + CRLF
    _cQry += " " + CRLF
 	_cQry += " , DADOS_PG AS (" + CRLF
	_cQry += " 	 SELECT PG.* " + CRLF
  	_cQry += " 		, ISNULL(PJ_ENTRA1,0) PJ_ENTRA1, ISNULL(PJ_SAIDA1,0) PJ_SAIDA1, ISNULL(PJ_ENTRA2,0) PJ_ENTRA2, ISNULL(PJ_SAIDA2,0) PJ_SAIDA2 " + CRLF
    _cQry += " " + CRLF
	_cQry += " 	 FROM SPG PG" + CRLF
	_cQry += " 	 LEFT JOIN SPH_SPG PH ON PH_FILIAL=PG_FILIAL AND PH_MAT=PG_MAT AND PH_DATA=PG_DATAAPO" + CRLF
	_cQry += " 	 LEFT JOIN SPJ010 PJ ON PJ_FILIAL=' ' " + CRLF
 	_cQry += " 		AND PG_TURNO				= PJ_TURNO" + CRLF
 	_cQry += " 		-- AND CASE " + CRLF
 	_cQry += " 		-- 		WHEN PG_SEMANA		!= '  '" + CRLF
 	_cQry += " 		-- 			THEN PG_SEMANA" + CRLF
	_cQry += " 		-- 			ELSE PH_SEMANA" + CRLF
	_cQry += " 		-- 			END = PJ_SEMANA -- ='01'" + CRLF
	_cQry += " 		AND PG_SEMANA = PJ_SEMANA" + CRLF
 	_cQry += " 		AND DATEPART(w, PG_DATAAPO)	= PJ_DIA" + CRLF
 	_cQry += " 		AND PG_APONTA				= PJ_TPDIA" + CRLF
 	_cQry += " 		AND PJ.D_E_L_E_T_ = ' '" + CRLF
	_cQry += " )" + CRLF
    _cQry += " " + CRLF
	_cQry += " , DADOS AS (" + CRLF
	_cQry += " 	SELECT * FROM DADOS_P8" + CRLF
	_cQry += " 	UNION" + CRLF
	_cQry += " 	SELECT * FROM DADOS_PG" + CRLF
	_cQry += " )" + CRLF
    _cQry += " " + CRLF
	_cQry += " , E1 AS ( " + CRLF
	_cQry += " 	SELECT * FROM DADOS WHERE ID=1 -- P8_TPMARCA = '1E' " + CRLF
	_cQry += " )" + CRLF
    _cQry += " " + CRLF
	_cQry += " , S1 AS ( " + CRLF
	_cQry += " 	SELECT * FROM DADOS WHERE ID=2 -- P8_TPMARCA = '1S' " + CRLF
	_cQry += " )" + CRLF
    _cQry += " " + CRLF
	_cQry += " , E2 AS ( " + CRLF
	_cQry += " 	SELECT * FROM DADOS WHERE ID=3 -- P8_TPMARCA = '2E' " + CRLF
	_cQry += " )" + CRLF
    _cQry += " " + CRLF
	_cQry += " , S2 AS ( " + CRLF
	_cQry += " 	SELECT * FROM DADOS WHERE ID=4 -- P8_TPMARCA = '2S' " + CRLF
 	_cQry += " )" + CRLF
    _cQry += " " + CRLF
	
    _cQry += " , PONTO AS (" + CRLF
 	_cQry += " 	SELECT DISTINCT E1.P8_FILIAL, E1.P8_MAT, E1.P8_DATA, E1.SEMANA" + CRLF
 	_cQry += " 	-- , PJ_DIA" + CRLF
 	_cQry += " 	, ISNULL(ISNULL(ISNULL(E1.P8_TURNO,S1.P8_TURNO),E2.P8_TURNO),S2.P8_TURNO) P8_TURNO" + CRLF
 	_cQry += " 	, R6_DESC" + CRLF
 	_cQry += " 	, RA_NOME" + CRLF
 	_cQry += " 	-- , RA_CIC" + CRLF
 	_cQry += " 	, RA_CC, CTT_DESC01" + CRLF
 	_cQry += " 	, RJ_DESC" + CRLF
 	_cQry += " 	, CASE " + CRLF
 	_cQry += " 		WHEN RJ_DESC LIKE '%MAQ%' OR RJ_DESC LIKE '%MOT%'" + CRLF
 	_cQry += " 			THEN 4" + CRLF
 	_cQry += " 			ELSE 2" + CRLF
 	_cQry += " 		END MAX_HR_EXTRA" + CRLF
 	_cQry += " 	, CASE " + CRLF
 	_cQry += " 		WHEN P3_MESDIA IS NULL" + CRLF
 	_cQry += " 		THEN -- ISNULL(ISNULL(ISNULL(E2.PJ_ENTRA2,S1.PJ_ENTRA2),E1.PJ_ENTRA2),S2.PJ_ENTRA2) " + CRLF
	_cQry += "		CASE " + CRLF
	_cQry += "			WHEN E1.PJ_ENTRA1 != 0" + CRLF
	_cQry += "				THEN E1.PJ_ENTRA1" + CRLF
	_cQry += "				ELSE CASE" + CRLF
	_cQry += "						WHEN S1.PJ_ENTRA1 != 0" + CRLF
	_cQry += "							THEN S1.PJ_ENTRA1" + CRLF
	_cQry += "							ELSE CASE" + CRLF
	_cQry += "									WHEN E2.PJ_ENTRA1 != 0" + CRLF
	_cQry += "										THEN E2.PJ_ENTRA1" + CRLF
	_cQry += "										ELSE S2.PJ_ENTRA1" + CRLF
	_cQry += "								END" + CRLF
	_cQry += "					END" + CRLF
	_cQry += "		END " + CRLF
	_cQry += "	END PJ_ENTRA1" + CRLF
    _cQry += " " + CRLF
 	_cQry += " 	, ISNULL(E1.P8_HORA, -1) E1	-- , ISNULL(REPLACE(E1.P8_HORA,'.',':'), -1) E1 " + CRLF
 	_cQry += " 	, ISNULL(E1.P8_MOTIVRG,'') MOT_RG_E1" + CRLF
    _cQry += " " + CRLF
 	_cQry += " 	, CASE " + CRLF
 	_cQry += " 		WHEN P3_MESDIA IS NULL" + CRLF
 	_cQry += " 		THEN -- ISNULL(ISNULL(ISNULL(S1.PJ_SAIDA1,E1.PJ_SAIDA1),E2.PJ_SAIDA1),S2.PJ_SAIDA1) " + CRLF
	_cQry += "		CASE " + CRLF
	_cQry += "			WHEN S1.PJ_SAIDA1 != 0" + CRLF
	_cQry += "				THEN S1.PJ_SAIDA1" + CRLF
	_cQry += "				ELSE CASE" + CRLF
	_cQry += "						WHEN E1.PJ_SAIDA1 != 0" + CRLF
	_cQry += "							THEN E1.PJ_SAIDA1" + CRLF
	_cQry += "							ELSE CASE" + CRLF
	_cQry += "									WHEN E2.PJ_SAIDA1 != 0" + CRLF
	_cQry += "										THEN E2.PJ_SAIDA1" + CRLF
	_cQry += "										ELSE S2.PJ_SAIDA1" + CRLF
	_cQry += "								END" + CRLF
	_cQry += "					END" + CRLF
	_cQry += "		END " + CRLF
	_cQry += "	END PJ_SAIDA1" + CRLF
 	_cQry += " 	, ISNULL(S1.P8_HORA, -1) S1	-- , ISNULL(REPLACE(S1.P8_HORA,'.',':'), -1) S1 " + CRLF
 	_cQry += " 	, ISNULL(S1.P8_MOTIVRG,'') MOT_RG_S1" + CRLF
    _cQry += " " + CRLF
	_cQry += " 	, CASE " + CRLF
 	_cQry += " 		WHEN P3_MESDIA IS NULL" + CRLF
 	_cQry += " 		THEN -- ISNULL(ISNULL(ISNULL(E2.PJ_ENTRA2,S1.PJ_ENTRA2),E1.PJ_ENTRA2),S2.PJ_ENTRA2) " + CRLF
	_cQry += " 		CASE " + CRLF
	_cQry += " 			WHEN E2.PJ_ENTRA2 != 0" + CRLF
	_cQry += " 				THEN E2.PJ_ENTRA2" + CRLF
	_cQry += " 				ELSE CASE" + CRLF
	_cQry += " 						WHEN S1.PJ_ENTRA2 != 0" + CRLF
	_cQry += " 							THEN S1.PJ_ENTRA2" + CRLF
	_cQry += " 							ELSE CASE" + CRLF
	_cQry += " 									WHEN E1.PJ_ENTRA2 != 0" + CRLF
	_cQry += " 										THEN E1.PJ_ENTRA2" + CRLF
	_cQry += " 										ELSE S2.PJ_ENTRA2" + CRLF
	_cQry += " 								END" + CRLF
	_cQry += " 					END" + CRLF
	_cQry += " 		END " + CRLF
	_cQry += " 	END PJ_ENTRA2" + CRLF
 	_cQry += " 	, ISNULL(E2.P8_HORA, -1) E2	-- , ISNULL(REPLACE(E2.P8_HORA,'.',':'), -1) E2 " + CRLF
 	_cQry += " 	, ISNULL(E2.P8_MOTIVRG,'') MOT_RG_E2" + CRLF
    _cQry += " " + CRLF
 	_cQry += " 	, CASE " + CRLF
 	_cQry += " 		WHEN P3_MESDIA IS NULL" + CRLF
 	_cQry += " 		THEN -- ISNULL(ISNULL(ISNULL(S2.PJ_SAIDA2,E2.PJ_SAIDA2),S1.PJ_SAIDA2),E1.PJ_SAIDA2) " + CRLF
	_cQry += "		CASE " + CRLF
	_cQry += "			WHEN S2.PJ_SAIDA2 != 0" + CRLF
	_cQry += "				THEN S2.PJ_SAIDA2" + CRLF
	_cQry += "				ELSE CASE" + CRLF
	_cQry += "						WHEN E2.PJ_SAIDA2 != 0" + CRLF
	_cQry += "							THEN E2.PJ_SAIDA2" + CRLF
	_cQry += "							ELSE CASE" + CRLF
	_cQry += "									WHEN S1.PJ_SAIDA2 != 0" + CRLF
	_cQry += "										THEN S1.PJ_SAIDA2" + CRLF
	_cQry += "										ELSE E1.PJ_SAIDA2" + CRLF
	_cQry += "								END" + CRLF
	_cQry += "					END" + CRLF
	_cQry += "		END " + CRLF
	_cQry += "	END PJ_SAIDA2" + CRLF
    _cQry += " " + CRLF
 	_cQry += " 	, ISNULL(S2.P8_HORA, -1) S2	-- , ISNULL(REPLACE(S2.P8_HORA,'.',':'), -1) S2 " + CRLF
 	_cQry += " 	, ISNULL(S2.P8_MOTIVRG,'') MOT_RG_S2" + CRLF
 	_cQry += " 	-- , PJ_HRSINT1" + CRLF
 	_cQry += " 	, ISNULL(P3_MESDIA,'') P3_MESDIA" + CRLF
    _cQry += " " + CRLF
 	_cQry += " 	FROM	  E1 " + CRLF
 	_cQry += " 	LEFT JOIN S1 ON E1.P8_FILIAL	= S1.P8_FILIAL " + CRLF
  	_cQry += " 			AND E1.P8_MAT		= S1.P8_MAT " + CRLF
  	_cQry += " 			AND substring(E1.P8_DATA,1,6) = substring(S1.P8_DATA,1,6)" + CRLF
  	_cQry += " 			AND E1.P8_ORDEM		= S1.P8_ORDEM " + CRLF
 	_cQry += " 	LEFT JOIN E2 ON E1.P8_FILIAL	= E2.P8_FILIAL" + CRLF
  	_cQry += " 			AND E1.P8_MAT		 = E2.P8_MAT " + CRLF
  	_cQry += " 			AND substring(E1.P8_DATA,1,6) = substring(E2.P8_DATA,1,6)" + CRLF
  	_cQry += " 			AND E1.P8_ORDEM		 = E2.P8_ORDEM " + CRLF
 	_cQry += " 	LEFT JOIN S2 ON E1.P8_FILIAL = S2.P8_FILIAL" + CRLF
  	_cQry += " 			AND E1.P8_MAT		= S2.P8_MAT " + CRLF
  	_cQry += " 			AND substring(E1.P8_DATA,1,6) = substring(S2.P8_DATA,1,6)" + CRLF
  	_cQry += " 			AND E1.P8_ORDEM		= S2.P8_ORDEM " + CRLF
 	_cQry += " 	JOIN SRA010 RA  ON RA_FILIAL=E1.P8_FILIAL AND RA_MAT = E1.P8_MAT AND RA.D_E_L_E_T_ = ' ' " + CRLF
 	_cQry += " 	JOIN SRJ010 RJ  ON RJ_FILIAL=' ' AND RJ_FUNCAO=RA_CODFUNC AND RJ.D_E_L_E_T_ = ' ' " + CRLF
 	_cQry += " 	JOIN CTT010 CTT ON CTT_FILIAL='  ' AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ' '" + CRLF
 	_cQry += " 	JOIN SR6010 R6  ON R6_FILIAL=' ' AND ISNULL(ISNULL(ISNULL(E1.P8_TURNO,S1.P8_TURNO),E2.P8_TURNO),S2.P8_TURNO)=R6_TURNO AND R6.D_E_L_E_T_=' '" + CRLF
 	_cQry += " 	LEFT JOIN SP3010 P3  ON P3_FILIAL=E1.P8_FILIAL AND P3_DATA=E1.P8_DATA AND P3_TPEXT='4' AND P3.D_E_L_E_T_=' '" + CRLF
	_cQry += " " + CRLF
	_cQry += " -- ORDER BY P8_FILIAL, RA_NOME, P8_DATA, E1" + CRLF
	_cQry += " ) " + CRLF
	_cQry += "  " + CRLF
	_cQry += " , BANCO_HORAS AS ( " + CRLF
	_cQry += " 	 SELECT  PI_FILIAL, PI_MAT, PI_DATA, PI_PD  " + CRLF
	_cQry += " 	 		, CASE P9_TIPOCOD  " + CRLF
	_cQry += " 	 			WHEN 1 THEN '+' " + CRLF
	_cQry += " 	 			WHEN 1 THEN '+' " + CRLF
	_cQry += " 	 				   ELSE '-' " + CRLF
	_cQry += " 	 		END P9_TIPOCOD " + CRLF
	_cQry += " 	 		, P9_DESC " + CRLF
	_cQry += " 	 		, PI_QUANT " + CRLF
	_cQry += " 	 		-- , A.*	 " + CRLF
	_cQry += " 	 FROM SPI010 A " + CRLF
	_cQry += " 	 JOIN SP9010 B ON A.PI_PD=B.P9_CODIGO AND A.D_E_L_E_T_=' ' AND B.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	 WHERE	PI_FILIAL   BETWEEN '  ' AND 'ZZ' " + CRLF
	_cQry += " 	 	AND PI_MAT		BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + CRLF
	_cQry += " 	 	AND PI_DATA		 " + CRLF
	_cQry += " 	 	--BETWEEN '20190426' AND  " + CRLF
	_cQry += " 	 	<= '"+DtoS(MV_PAR02)+"'  " + CRLF
	_cQry += " 	 	AND PI_STATUS	<> 'B' " + CRLF
	_cQry += " ) " + CRLF
	_cQry += CRLF
	_cQry += "  SELECT DISTINCT " + CRLF
	_cQry += "  			ISNULL(PI_FILIAL,P8_FILIAL) PI_FILIAL, " + CRLF
	_cQry += "  			ISNULL(PI_MAT, P8_MAT) PI_MAT," + CRLF
	_cQry += "  			ISNULL(PI_DATA, P8_DATA) PI_DATA, PI_PD, P9_TIPOCOD, P9_DESC, PI_QUANT," + CRLF
	_cQry += "  			P8_FILIAL, P8_MAT, P8_DATA, SEMANA, P8_TURNO, R6_DESC, RA_NOME, RA_CC, CTT_DESC01, RJ_DESC, MAX_HR_EXTRA, " + CRLF
	_cQry += "  			PJ_ENTRA1, E1, MOT_RG_E1, " + CRLF
	_cQry += "  			PJ_SAIDA1, S1, MOT_RG_S1, " + CRLF
	_cQry += "  			PJ_ENTRA2, E2, MOT_RG_E2, " + CRLF
	_cQry += "  			PJ_SAIDA2, S2, MOT_RG_S2, " + CRLF
	_cQry += "  			P3_MESDIA" + CRLF
	_cQry += "   FROM (" + CRLF
	_cQry += "   			SELECT	" + CRLF
	_cQry += "  			PI_FILIAL, PI_MAT, PI_DATA, PI_PD, P9_TIPOCOD, P9_DESC, PI_QUANT," + CRLF
	_cQry += "  			P8_FILIAL, P8_MAT, P8_DATA, SEMANA, P8_TURNO, R6_DESC, RA_NOME, RA_CC, CTT_DESC01, RJ_DESC, MAX_HR_EXTRA, " + CRLF
	_cQry += "  			PJ_ENTRA1, E1, MOT_RG_E1, " + CRLF
	_cQry += "  			PJ_SAIDA1, S1, MOT_RG_S1, " + CRLF
	_cQry += "  			PJ_ENTRA2, E2, MOT_RG_E2, " + CRLF
	_cQry += "  			PJ_SAIDA2, S2, MOT_RG_S2, " + CRLF
	_cQry += "  			P3_MESDIA" + CRLF
	_cQry += CRLF
	_cQry += "   			FROM BANCO_HORAS A " + CRLF
	_cQry += "   			LEFT JOIN PONTO	 B ON A.PI_FILIAL = B.P8_FILIAL " + CRLF
	_cQry += "   								AND A.PI_MAT	  = B.P8_MAT " + CRLF
	_cQry += "   								AND A.PI_DATA	  = B.P8_DATA " + CRLF
	_cQry += CRLF
	_cQry += "   			UNION " + CRLF
	_cQry += CRLF
	_cQry += "   			SELECT " + CRLF
	_cQry += "  			PI_FILIAL, PI_MAT, PI_DATA, PI_PD, P9_TIPOCOD, P9_DESC, PI_QUANT," + CRLF
	_cQry += "  			P8_FILIAL, P8_MAT, P8_DATA, SEMANA, P8_TURNO, R6_DESC, RA_NOME, RA_CC, CTT_DESC01, RJ_DESC, MAX_HR_EXTRA, " + CRLF
	_cQry += "  			PJ_ENTRA1, E1, MOT_RG_E1, " + CRLF
	_cQry += "  			PJ_SAIDA1, S1, MOT_RG_S1, " + CRLF
	_cQry += "  			PJ_ENTRA2, E2, MOT_RG_E2, " + CRLF
	_cQry += "  			PJ_SAIDA2, S2, MOT_RG_S2, " + CRLF
	_cQry += "  			P3_MESDIA" + CRLF
	_cQry += "  			--A.*, B.*" + CRLF
	_cQry += " 			FROM PONTO	 B " + CRLF
	_cQry += " 			LEFT JOIN BANCO_HORAS A ON A.PI_FILIAL = B.P8_FILIAL " + CRLF
	_cQry += " 								AND A.PI_MAT	  = B.P8_MAT " + CRLF
	_cQry += " 								AND A.PI_DATA	  = B.P8_DATA " + CRLF
	_cQry += ") FINAL" + CRLF
	_cQry += " ORDER BY 1,2,3 "

EndIf

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+ "_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

// TcSetField(_cAlias, "P8_DATA", "D")

Return !(_cAlias)->(Eof())


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAPTEM01()                                      |
 | Func:                                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  30.05.2019                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1(cTipo, _cAlias)

Local cXML 			:= ""
Local cWorkSheet 	:= "Banco de Dados"
Local _cMotManual 	:= ""

(_cAliasG)->(DbEval({|| nRegistros++ }))

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())
	// fQuadro1
	
	cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	cXML += ' <Names>' + CRLF
	cXML += ' 	<NamedRange ss:Name="_FilterDatabase" ss:RefersTo="='+cWorkSheet+'!R2C1:R'+cValToChar(nRegistros+2)+'C8" ss:Hidden="1"/>' + CRLF
	cXML += ' </Names>' + CRLF
	cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
	cXML += '   <Column ss:Hidden="1" ss:AutoFitWidth="0"/>' + CRLF
    cXML += '   <Column ss:Index="3" ss:AutoFitWidth="0" ss:Width="58.5"/>' + CRLF
    cXML += '   <Column ss:AutoFitWidth="0" ss:Width="69.75"/>' + CRLF
    cXML += '   <Column ss:Width="49.5"/>' + CRLF
    cXML += '   <Column ss:AutoFitWidth="0" ss:Width="47.25"/>' + CRLF
    cXML += '   <Column ss:AutoFitWidth="0" ss:Width="141.75"/>' + CRLF
    cXML += '   <Column ss:AutoFitWidth="0" ss:Width="66"/>' + CRLF
	cXML += '<Row ss:Height="36">' + CRLF
	cXML += '     <Cell ss:MergeAcross="7" ss:StyleID="s62">' + CRLF
	cXML += '       <Data ss:Type="String">'+cTitulo+'</Data>' + CRLF
	cXML += '     </Cell>' + CRLF
	cXML += '</Row>' + CRLF
	
	  cXML += '<Row ss:AutoFitHeight="0" ss:Height="36">' + CRLF
/*01*/cXML += '  <Cell ss:StyleID="s65" ss:Index="2"><Data ss:Type="String">Filial</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*02*/cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Matricula</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*03*/cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Data</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*04*/cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Operação</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*05*/cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Evento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*06*/cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Descr. do Evento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*07*/cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Saldo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	  cXML += '</Row>' + CRLF
 
	While !(_cAliasG)->(Eof())
      	
		If StoD( (_cAliasG)->PI_DATA ) < MV_PAR01 .AND. Empty( (_cAliasG)->P8_MAT )
		
			cXML += '<Row>' + CRLF
/*01*/		cXML += '  <Cell ss:Formula="=CONCATENATE(RC[1],RC[2])"><Data ss:Type="String"></Data></Cell>' + CRLF
/*02*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->PI_FILIAL  ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*03*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->PI_MAT     ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*04*/		cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sToD((_cAliasG)->PI_DATA) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*05*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->P9_TIPOCOD ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*06*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->PI_PD      ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*07*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->P9_DESC    ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*08*/		cXML += '  <Cell ss:StyleID="sHoraCurtaH"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->PI_QUANT ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '</Row>' + CRLF
			
			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
		
		EndIf
		
		(_cAliasG)->(DbSkip())   // U_VAPTEM01()
	EndDo
	
	// Final da Planilha
	cXML += '</Table>' + CRLF
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <PageSetup>' + CRLF
	cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
	cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += '   </PageSetup>' + CRLF
	cXML += '   <Unsynced/>' + CRLF
	cXML += '   <Selected/>' + CRLF
	cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += '  </WorksheetOptions>' + CRLF
	cXML += '  <AutoFilter x:Range="R2C1:R'+cValToChar(nRegistros+2)+'C8" xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '  </AutoFilter>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	

EndIf

Return nil
// fQuadro1


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAPTEM01()                                      |
 | Func:                                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  30.01.2019                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro2(cTipo, _cAlias)

Local cXML 			:= ""
Local cWorkSheet 	:= "Batidas"
Local _cMotManual 	:= ""
// MJ : 30.05.2019
// Local _dDtControl	:= MV_PAR01 // sToD('')
Local _cMat			:= ""
// Local cAux			:= ""
// Local lAux			:= .T.

// (_cAliasG)->(DbEval({|| nRegistros++ }))

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())
	// fQuadro2
	cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	cXML += ' <Names>' + CRLF
	cXML += ' 	<NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=Batidas!R2C1:R'+cValToChar(nRegistros+2)+'C33" ss:Hidden="1"/>' + CRLF
	cXML += ' </Names>' + CRLF
	cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="39.75"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="51.75"/>' + CRLF
	cXML += '   <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="51.75"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="137.25"/>' + CRLF
	cXML += '   <Column ss:Width="56.25"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="46.5"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="38.25"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="169.5"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="39"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="150.75"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="105"/>' + CRLF
	cXML += '   <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="84.75"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="94.5"/>' + CRLF
	cXML += '   <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="61.5"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="64.5"/>' + CRLF
	cXML += '   <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="61.5"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="64.5"/>' + CRLF
	cXML += '   <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="61.5"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="64.5"/>' + CRLF
	cXML += '   <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="61.5"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="64.5" ss:Span="1"/>' + CRLF
	cXML += '   <Column ss:Index="23" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="61.5"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="64.5"/>' + CRLF
	cXML += '   <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="61.5"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="64.5" ss:Span="2"/>' + CRLF
	cXML += '   <Column ss:Index="29" ss:AutoFitWidth="0" ss:Width="60.75"/>' + CRLF
    cXML += '   <Column ss:Index="31" ss:AutoFitWidth="0" ss:Width="135.75"/>' + CRLF
    cXML += '   <Column ss:AutoFitWidth="0" ss:Width="72"/>' + CRLF
    cXML += '   <Column ss:AutoFitWidth="0" ss:Width="90.75"/>' + CRLF
	cXML += '<Row ss:Height="36">' + CRLF
	cXML += '     <Cell ss:MergeAcross="14" ss:StyleID="s62">' + CRLF
	cXML += '       <Data ss:Type="String">'+cTitulo+'</Data>' + CRLF
	cXML += '     </Cell>' + CRLF
	cXML += '</Row>' + CRLF
	cXML += '<Row ss:AutoFitHeight="0" ss:Height="36">' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Matricula</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65" ss:Formula="=CONCATENATE(RC[-2],RC[-1])"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Funcionario</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Data</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Dia</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Turno</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Desc. Turno</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Centro Custo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Departamento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Funçao</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Max Hr Extra</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Motivo Registro</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	
	cXML += '  <Cell ss:StyleID="sTitLaranja"><Data ss:Type="String">1a Entrada &#10;V@</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">1a &#10;Entrada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="sTitLaranja"><Data ss:Type="String">1a Saida &#10;V@</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">1a &#10;Saida</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="sTitLaranja"><Data ss:Type="String">2a Entrada &#10;V@</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">2a &#10;Entrada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="sTitLaranja"><Data ss:Type="String">2a Saida &#10;V@</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">2a &#10;Saida</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Tempo de Almoço</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="sTitLaranja"><Data ss:Type="String">Tempo de Almoço &#10;V@</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Horas Trab.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="sTitLaranja"><Data ss:Type="String">Horas Trab. &#10;V@</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Horas Extras</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Absent.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Intrajornada</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Batidas Pendentes</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Tipo Codigo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Evento</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Saldo Horas</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Validação / Diferença</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += '</Row>' + CRLF
	
	// fQuadro2
	_cMat := ""
	While !(_cAliasG)->(Eof())
	
		If Empty( (_cAliasG)->P8_MAT ) .and. !((_cAliasG)->PI_PD $ GetMV('VA_PTEM01A',,'409'))
			(_cAliasG)->(DbSkip())   // U_VAPTEM01()
			Loop
		EndIf
		
		// If (_cAliasG)->PI_PD $ GetMV('VA_PTEM01A',,'409') .AND. sToD((_cAliasG)->PI_DATA) < _dDtControl
		If (_cAliasG)->PI_PD $ GetMV('VA_PTEM01A',,'409') .AND. sToD((_cAliasG)->PI_DATA) < MV_PAR01
			(_cAliasG)->(DbSkip())   // U_VAPTEM01()
			Loop
		EndIf
	
		// 31.05.2019
		/* ########################################################################################################### */
		// imprimir linha de BANCO DE HORAS
		// If Empty((_cAliasG)->PI_MAT)
		// 	lAux := _cMat <> (_cAliasG)->P8_MAT
		// Else
		// 	lAux := _cMat <> (_cAliasG)->PI_MAT
		// EndIf
		// If lAux
		If _cMat <> (_cAliasG)->PI_MAT
			cXML += '<Row>' + CRLF
			
			// cAux := Iif(Empty((_cAliasG)->PI_FILIAL),(_cAliasG)->P8_FILIAL,(_cAliasG)->PI_FILIAL)
/*01*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->PI_FILIAL/* cAux */ ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF // /*01*/	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->P8_FILIAL  ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			// cAux := Iif(Empty((_cAliasG)->PI_MAT),(_cAliasG)->P8_MAT,(_cAliasG)->PI_MAT)
/*02*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->PI_MAT/* cAux */ ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF    // /*02*/	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->P8_MAT 	) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*03*/		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=CONCATENATE(RC[-2],RC[-1])"><Data ss:Type="String"></Data></Cell>' + CRLF
/*04*/		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[-1]C1,R[-1]C2),R[-1]C,IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[1]C1,R[1]C2),R[1]C,&quot;&quot;))"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			// cAux := Iif(Empty((_cAliasG)->PI_DATA),(_cAliasG)->P8_DATA,(_cAliasG)->PI_DATA)
/*05*/		cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sToD((_cAliasG)->PI_DATA/* cAux */) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF // /*05*/	cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sToD((_cAliasG)->P8_DATA) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*06*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( DiaSemana( sToD( (_cAliasG)->PI_DATA/* cAux */ ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF // /*06*/	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( DiaSemana( sToD( (_cAliasG)->P8_DATA ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*07*/		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[-1]C1,R[-1]C2),R[-1]C,IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[1]C1,R[1]C2),R[1]C,&quot;&quot;))"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*08*/		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[-1]C1,R[-1]C2),R[-1]C,IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[1]C1,R[1]C2),R[1]C,&quot;&quot;))"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*09*/		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[-1]C1,R[-1]C2),R[-1]C,IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[1]C1,R[1]C2),R[1]C,&quot;&quot;))"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*10*/		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[-1]C1,R[-1]C2),R[-1]C,IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[1]C1,R[1]C2),R[1]C,&quot;&quot;))"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*11*/		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[-1]C1,R[-1]C2),R[-1]C,IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[1]C1,R[1]C2),R[1]C,&quot;&quot;))"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*13*/	    cXML += '  <Cell ss:StyleID="sTexto" ss:Index="13"><Data ss:Type="String">BANCO DE HORAS</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

/*25*/		cXML += '  <Cell ss:StyleID="sHoraCurta" ss:Index="25" ss:Formula="=IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[-1]C1,R[-1]C2),R[-1]C,IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[1]C1,R[1]C2),R[1]C,&quot;&quot;))"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*26*/		cXML += '  <Cell ss:StyleID="sHoraCurtaH" ss:Formula="=SUMIFS('+"'Banco de Dados'"+'!R3C8:R'+cValToChar(nRegistros+3)+'C8,'+"'Banco de Dados'"+'!R3C1:R'+cValToChar(nRegistros+3)+'C1,RC3,'+"'Banco de Dados'"+'!R3C5:R'+cValToChar(nRegistros+3)+'C5,&quot;+&quot;)"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*27*/		cXML += '  <Cell ss:StyleID="sHoraCurtaH" ss:Formula="=SUMIFS('+"'Banco de Dados'"+'!R3C8:R'+cValToChar(nRegistros+3)+'C8,'+"'Banco de Dados'"+'!R3C1:R'+cValToChar(nRegistros+3)+'C1,RC3,'+"'Banco de Dados'"+'!R3C5:R'+cValToChar(nRegistros+3)+'C5,&quot;-&quot;)"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '</Row>' + CRLF
		EndIf
		_cMat := Iif(Empty((_cAliasG)->PI_MAT),(_cAliasG)->P8_MAT,(_cAliasG)->PI_MAT)
		/* ########################################################################################################### */
		
		
      	cXML += '<Row>' + CRLF
		// cAux := Iif(Empty((_cAliasG)->PI_FILIAL),(_cAliasG)->P8_FILIAL,(_cAliasG)->PI_FILIAL)
/*01*/	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->PI_FILIAL/* cAux */ ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF // /*01*/	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->P8_FILIAL  ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		// cAux := Iif(Empty((_cAliasG)->PI_MAT),(_cAliasG)->P8_MAT,(_cAliasG)->PI_MAT)
/*02*/	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->PI_MAT/* cAux */ ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF    // /*02*/	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->P8_MAT 	) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*03*/	cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=CONCATENATE(RC[-2],RC[-1])"><Data ss:Type="String"></Data></Cell>' + CRLF

		If Empty( (_cAliasG)->P8_MAT )
/*04*/		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[-1]C1,R[-1]C2),R[-1]C,IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[1]C1,R[1]C2),R[1]C,&quot;&quot;))"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
/*04*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->RA_NOME 	) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf

		// cAux := Iif(Empty((_cAliasG)->PI_DATA),(_cAliasG)->P8_DATA,(_cAliasG)->PI_DATA)
/*05*/	cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sToD((_cAliasG)->PI_DATA/* cAux */) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF // /*05*/	cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sToD((_cAliasG)->P8_DATA) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*06*/	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( DiaSemana( sToD( (_cAliasG)->PI_DATA/* cAux */ ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF // /*06*/	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( DiaSemana( sToD( (_cAliasG)->P8_DATA ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF

		If Empty( (_cAliasG)->P8_MAT )
/*07*/		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[-1]C1,R[-1]C2),R[-1]C,IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[1]C1,R[1]C2),R[1]C,&quot;&quot;))"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*08*/		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[-1]C1,R[-1]C2),R[-1]C,IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[1]C1,R[1]C2),R[1]C,&quot;&quot;))"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*09*/		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[-1]C1,R[-1]C2),R[-1]C,IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[1]C1,R[1]C2),R[1]C,&quot;&quot;))"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*10*/		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[-1]C1,R[-1]C2),R[-1]C,IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[1]C1,R[1]C2),R[1]C,&quot;&quot;))"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*11*/		cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[-1]C1,R[-1]C2),R[-1]C,IF(CONCATENATE(RC1,RC2)=CONCATENATE(R[1]C1,R[1]C2),R[1]C,&quot;&quot;))"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
/*07*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->P8_TURNO ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*08*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->R6_DESC ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*09*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->RA_CC 		) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*10*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->CTT_DESC01 ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*11*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->RJ_DESC ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf

/*12*/	cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->MAX_HR_EXTRA ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		
		_cMotManual := ""
		_cMotManual += iIf(!Empty(_cMotManual) .and. !Empty((_cAliasG)->MOT_RG_E1) .and. At(AllTrim((_cAliasG)->MOT_RG_E1), _cMotManual)==0,", ","") + Iif(At(AllTrim((_cAliasG)->MOT_RG_E1), _cMotManual) > 0,"",AllTrim((_cAliasG)->MOT_RG_E1) )
		_cMotManual += iIf(!Empty(_cMotManual) .and. !Empty((_cAliasG)->MOT_RG_S1) .and. At(AllTrim((_cAliasG)->MOT_RG_S1), _cMotManual)==0,", ","") + Iif(At(AllTrim((_cAliasG)->MOT_RG_S1), _cMotManual) > 0,"",AllTrim((_cAliasG)->MOT_RG_S1) )
		_cMotManual += iIf(!Empty(_cMotManual) .and. !Empty((_cAliasG)->MOT_RG_E2) .and. At(AllTrim((_cAliasG)->MOT_RG_E2), _cMotManual)==0,", ","") + Iif(At(AllTrim((_cAliasG)->MOT_RG_E2), _cMotManual) > 0,"",AllTrim((_cAliasG)->MOT_RG_E2) )
		_cMotManual += iIf(!Empty(_cMotManual) .and. !Empty((_cAliasG)->MOT_RG_S2) .and. At(AllTrim((_cAliasG)->MOT_RG_S2), _cMotManual)==0,", ","") + Iif(At(AllTrim((_cAliasG)->MOT_RG_S2), _cMotManual) > 0,"",AllTrim((_cAliasG)->MOT_RG_S2) )
/*13*/	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( _cMotManual ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		
		// <Cell ss:StyleID="s69"><Data ss:Type="DateTime">1899-12-31T07:27:00.000</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
/*14*/	cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->PJ_ENTRA1 ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		If (_cAliasG)->E1 == -1
/*15*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
/*15*/		cXML += '  <Cell ss:StyleID="'+iIf(Empty((_cAliasG)->MOT_RG_E1),"sHoraCurta", "sHoraCurtaN")+'"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->E1 ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf

/*16*/	cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->PJ_SAIDA1) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		If (_cAliasG)->S1 == -1
/*17*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
/*17*/		cXML += '  <Cell ss:StyleID="'+iIf(Empty((_cAliasG)->MOT_RG_S1),"sHoraCurta", "sHoraCurtaN")+'"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->S1 ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf

/*18*/	cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->PJ_ENTRA2 ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		If (_cAliasG)->E2 == -1
			// cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*19*/		cXML += ' <Cell ss:StyleID="sTexto" ss:Formula="=IF(RC18=RC20,&quot;Compensado&quot;,&quot;&quot;)"><Data ss:Type="String">Compensado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
/*19*/		cXML += '  <Cell ss:StyleID="'+iIf(Empty((_cAliasG)->MOT_RG_E2),"sHoraCurta", "sHoraCurtaN")+'"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->E2 ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf

/*20*/	cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->PJ_SAIDA2 ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		If (_cAliasG)->S2 == -1
			// cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*21*/		cXML += ' <Cell ss:StyleID="sTexto" ss:Formula="=IF(RC18=RC20,&quot;Compensado&quot;,&quot;&quot;)"><Data ss:Type="String">Compensado</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
			If (_cAliasG)->S2 < (_cAliasG)->E2
/*21*/			cXML += '  <Cell ss:StyleID="'+iIf(Empty((_cAliasG)->MOT_RG_S2),"sHoraCurta", "sHoraCurtaN")+'"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->S2 ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			Else
/*21*/			cXML += '  <Cell ss:StyleID="'+iIf(Empty((_cAliasG)->MOT_RG_S2),"sHoraCurta", "sHoraCurtaN")+'"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->S2 ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			EndIf
		EndIf
		// fQuadro2
		// Tempo de almoço
/*22*/	cXML += '  <Cell ss:StyleID="sHoraCurta" ss:Formula="=IFERROR(RC[-3]-RC[-5],&quot;&quot;)"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*23*/	cXML += '  <Cell ss:StyleID="sHoraCurta" ss:Formula="=IF(RC18&lt;&gt;RC20,RC[-5]-RC[-7],&quot;&quot;)"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		
		// Horas Trabalhadas
		// nHrsTrab 	:= __TimeSum( __TimeSub( (_cAliasG)->S1, (_cAliasG)->E1 ) , __TimeSub( (_cAliasG)->S2, (_cAliasG)->E2 ) )
		// // cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( nHrsTrab ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		If Empty( (_cAliasG)->P3_MESDIA )
/*24*/		cXML += '  <Cell ss:StyleID="sHoraCurta" ss:Formula="=IF(AND(RC18=RC20,RC19=RC21),IFERROR(RC[-7]-RC[-9],),IFERROR(RC[-7]-RC[-9],)+IFERROR(RC[-3]-RC[-5],))"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
/*24*/		cXML += '  <Cell ss:StyleID="sHoraCurta" ss:Formula="=IFERROR(RC[-7]-RC[-9],)+IFERROR(RC[-3]-RC[-5],)"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf
		
/*25*/	cXML += '  <Cell ss:StyleID="sHoraCurta" ss:Formula="=IFERROR(IF(AND(RC[-5]&lt;RC[-11],RC[-5]&lt;&gt;RC[-7]),&quot;24:00&quot;-RC[-7]+RC[-5],RC[-5]-RC[-7])+(RC[-9]-RC[-11]),&quot;&quot;)"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		
		// nTurno 	  	:= __TimeSub( 17.48, 8 ) // fim e inicio
		// nTmpAlmoco 	:= 1
		// nHrsTurno 	:= __TimeSub( nTurno, nTmpAlmoco )
        // 
		// nSldTrab 	:= __TimeSub( nHrsTrab , nHrsTurno )
		
		cPendentes := ""
		cPendentes += Iif(!Empty(cPendentes) .AND. (_cAliasG)->E1==-1,", ", "") + Iif((_cAliasG)->E1==-1,"E1","")
		cPendentes += Iif(!Empty(cPendentes) .AND. (_cAliasG)->S1==-1,", ", "") + Iif((_cAliasG)->S1==-1,"S1","")
		cPendentes += Iif(!Empty(cPendentes) .AND. (_cAliasG)->E2==-1,", ", "") + Iif((_cAliasG)->E2==-1,"E2","")
		cPendentes += Iif(!Empty(cPendentes) .AND. (_cAliasG)->S2==-1,", ", "") + Iif((_cAliasG)->S2==-1,"S2","")
		
		// If !Empty(cPendentes)
		// 	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		// 	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		// ElseIf (nSldTrab>0)
		// 	// cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( ABS(nSldTrab) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF		
		// 	cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_fHraToXML( cValToChar( ABS(nSldTrab) ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		// 	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		// Else
		// 	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		// 	cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_fHraToXML( cValToChar( ABS(nSldTrab) ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		// EndIf

		// Hora Extra e Absent.
		If Empty( (_cAliasG)->P8_MAT )
			If (_cAliasG)->P9_TIPOCOD=='+'
/*26*/			cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->PI_QUANT ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*27*/			cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			Else
/*26*/			cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*27*/			cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->PI_QUANT ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			EndIf
		Else
/*26*/		cXML += '  <Cell ss:StyleID="sHoraCurta" ss:Formula="=IFERROR(IF(RC[-2]&gt;RC[-1],IF(TEXT((RC[-2]-RC[-1]),&quot;h:mm&quot;)&lt;&quot;0:10&quot;,&quot;&quot;,RC[-2]-RC[-1]),&quot;&quot;),)"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*27*/		cXML += '  <Cell ss:StyleID="sHoraCurta" ss:Formula="=IFERROR(IF(RC[-2]&gt;RC[-3],IF(TEXT((RC[-2]-RC[-3]),&quot;h:mm&quot;)&lt;&quot;0:10&quot;,&quot;&quot;,RC[-2]-RC[-3]),&quot;&quot;),)"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf
		
		// Intrajornada
/*28*/	cXML += '  <Cell ss:StyleID="sHoraCurtaH" ss:Formula="=IFERROR(IF(RC[-24]=R[-1]C[-24],(RC[-23]+RC[-13])-(R[-1]C[-23]+R[-1]C[-7]),&quot;&quot;),&quot;&quot;)"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		
		if (_cAliasG)->PJ_ENTRA2 == (_cAliasG)->PJ_SAIDA2 // SE IGUAL ENTAO É 00:00
/*29*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		Else
/*29*/		cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( cPendentes ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		EndIf

/*30*/	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->P9_TIPOCOD) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*31*/	cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( AllTrim((_cAliasG)->PI_PD) + '-' + AllTrim((_cAliasG)->P9_DESC)) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*32*/	cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( cValToChar( (_cAliasG)->PI_QUANT ) ) ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
/*33*/	cXML += '  <Cell ss:StyleID="sHoraCurta" ss:Formula="=IF(RC[-3]=&quot;+&quot;,TEXT((RC[-1]),&quot;h:mm&quot;)-TEXT((RC[-7]),&quot;h:mm&quot;),TEXT((RC[-1]),&quot;h:mm&quot;)-TEXT((RC[-6]),&quot;h:mm&quot;))"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
		cXML += '</Row>' + CRLF

		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
			cXML := ""
		EndIf
		(_cAliasG)->(DbSkip())   // U_VAPTEM01()
		//_dDtControl := sToD((_cAliasG)->PI_DATA)
	EndDo
	
	// fQuadro2
	cXML += '  </Table> ' + CRLF
	cXML += '    <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <PageSetup>' + CRLF
	cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
	cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += '   </PageSetup>' + CRLF
	cXML += '   <Print>' + CRLF
	cXML += '    <ValidPrinterInfo/>' + CRLF
	cXML += '    <PaperSizeIndex>9</PaperSizeIndex>' + CRLF
	cXML += '    <HorizontalResolution>600</HorizontalResolution>' + CRLF
	cXML += '    <VerticalResolution>600</VerticalResolution>' + CRLF
	cXML += '   </Print>' + CRLF
	cXML += '   <Selected/>' + CRLF
	cXML += '   <TopRowVisible>1</TopRowVisible>' + CRLF
	cXML += '   <FreezePanes/>' + CRLF
	cXML += '   <FrozenNoSplit/>' + CRLF
	cXML += '   <SplitHorizontal>1</SplitHorizontal>' + CRLF
	cXML += '   <TopRowBottomPane>2</TopRowBottomPane>' + CRLF
	cXML += '   <SplitVertical>6</SplitVertical>' + CRLF
	cXML += '   <LeftColumnRightPane>13</LeftColumnRightPane>' + CRLF
	cXML += '   <ActivePane>0</ActivePane>' + CRLF
	cXML += '   <Panes>' + CRLF
	cXML += '    <Pane>' + CRLF
	cXML += '     <Number>3</Number>' + CRLF
	cXML += '     <ActiveRow>1</ActiveRow>' + CRLF
	cXML += '    </Pane>' + CRLF
	cXML += '    <Pane>' + CRLF
	cXML += '     <Number>1</Number>' + CRLF
	cXML += '     <ActiveRow>1</ActiveRow>' + CRLF
	cXML += '     <ActiveCol>6</ActiveCol>' + CRLF
	cXML += '    </Pane>' + CRLF
	cXML += '    <Pane>' + CRLF
	cXML += '     <Number>2</Number>' + CRLF
	cXML += '    </Pane>' + CRLF
	cXML += '    <Pane>' + CRLF
	cXML += '     <Number>0</Number>' + CRLF
	cXML += '     <ActiveRow>4</ActiveRow>' + CRLF
	cXML += '     <ActiveCol>24</ActiveCol>' + CRLF
	cXML += '    </Pane>' + CRLF
	cXML += '   </Panes>' + CRLF
	cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += '  </WorksheetOptions>' + CRLF
	cXML += '  <AutoFilter x:Range="R2C1:R'+cValToChar(nRegistros+2)+'C33" xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '  </AutoFilter>' + CRLF
	cXML += '  <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <Range>R38C14:R2446C21</Range>' + CRLF
	cXML += '   <Condition>' + CRLF
	cXML += '    <Qualifier>Equal</Qualifier>' + CRLF
	cXML += '    <Value1>&quot;&quot;</Value1>' + CRLF
	cXML += "    <Format Style='color:#9C0006;background:#FFC7CE'/>" + CRLF
	cXML += '   </Condition>' + CRLF
	cXML += '  </ConditionalFormatting>' + CRLF
	cXML += '  <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <Range>R3C22:R'+cValToChar(nRegistros+2)+'C22</Range>' + CRLF
	cXML += '   <Condition>' + CRLF
	cXML += '    <Qualifier>LessOrEqual</Qualifier>' + CRLF
	cXML += '    <Value1>0.0409722222222222</Value1>' + CRLF
	cXML += "    <Format Style='color:#9C0006;background:#FFC7CE'/>" + CRLF
	cXML += '   </Condition>' + CRLF
	cXML += '  </ConditionalFormatting>' + CRLF
	cXML += '  <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <Range>R3C14:R'+cValToChar(nRegistros+2)+'C21</Range>' + CRLF
	cXML += '   <Condition>' + CRLF
	cXML += '    <Qualifier>Equal</Qualifier>' + CRLF
	cXML += '    <Value1>&quot;&quot;</Value1>' + CRLF
	cXML += "    <Format Style='color:#9C0006;background:#FFC7CE'/>" + CRLF
	cXML += '   </Condition>' + CRLF
	cXML += '  </ConditionalFormatting>' + CRLF
	cXML += '  <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <Range>R3C26:R'+cValToChar(nRegistros+2)+'C26</Range>' + CRLF
	cXML += '   <Condition>' + CRLF
	cXML += '    <Qualifier>Greater</Qualifier>' + CRLF
	cXML += '    <Value1>RC[-14]</Value1>' + CRLF
	cXML += "    <Format Style='color:#9C0006;background:#FFC7CE'/>" + CRLF
	cXML += '   </Condition>' + CRLF
	cXML += '  </ConditionalFormatting>' + CRLF
	cXML += '  <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <Range>R3C26:R'+cValToChar(nRegistros+2)+'C27</Range>' + CRLF
	cXML += '   <Condition>' + CRLF
	cXML += '    <Value1>LEN(TRIM(RC))=0</Value1>' + CRLF
	cXML += "    <Format Style='mso-background-source:auto'/>" + CRLF
	cXML += '   </Condition>' + CRLF
	cXML += '  </ConditionalFormatting>' + CRLF
	cXML += '  <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += '   <Range>R3C28:R'+cValToChar(nRegistros+2)+'C28</Range>' + CRLF
	cXML += '   <Condition>' + CRLF
	cXML += '    <Qualifier>Less</Qualifier>' + CRLF
	cXML += '    <Value1>0.458333333333333</Value1>' + CRLF
	cXML += "    <Format Style='color:#9C0006;background:#FFC7CE'/>" + CRLF
	cXML += '   </Condition>' + CRLF
	cXML += '  </ConditionalFormatting>' + CRLF
	cXML += ' </Worksheet> ' + CRLF
 
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
	
EndIf	

Return nil
// fQuadro2

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAPTEM01()                                      |
 | Func:                                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  06.02.2019                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro3(cTipo, _cAlias)

Local cXML 			:= ""
Local cWorkSheet 	:= "Resumo"
Local nRegistros	:= 0
Local _cCodigo		:= ""

(_cAliasG)->(DbEval({|| nRegistros++ }))

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	cXML += ' <Names>' + CRLF
	cXML += ' 	<NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=Resumo!R2C1:R'+cValToChar(nRegistros+2)+'C13" ss:Hidden="1"/>' + CRLF
	cXML += ' </Names>' + CRLF
	cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
	cXML += '   <Column ss:Index="3" ss:AutoFitWidth="0" ss:Width="198.75"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="98.25"/>' + CRLF
	cXML += '   <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Span="1"/>' + CRLF
	cXML += '   <Column ss:Index="7" ss:AutoFitWidth="0" ss:Width="82.5"/>' + CRLF
	cXML += '   <Column ss:StyleID="s16" ss:Hidden="1" ss:AutoFitWidth="0"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="82.5"/>' + CRLF
	cXML += '   <Column ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="81"/>' + CRLF
	cXML += '   <Column ss:AutoFitWidth="0" ss:Width="82.5" ss:Span="1"/>' + CRLF
	cXML += '   <Column ss:Index="13" ss:AutoFitWidth="0" ss:Width="63"/>' + CRLF
	cXML += ' <Row ss:AutoFitHeight="0" ss:Height="44.25">' + CRLF
	cXML += ' 	<Cell ss:MergeAcross="12" ss:StyleID="s62">' + CRLF
	cXML += '		<Data ss:Type="String">Banco de Horas - Resumo</Data>' + CRLF
	cXML += '	</Cell>' + CRLF
	cXML += ' </Row>' + CRLF
	cXML += ' <Row ss:Height="33">' + CRLF
	cXML += ' 	<Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' 	<Cell ss:StyleID="s65"><Data ss:Type="String">Matricula</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' 	<Cell ss:StyleID="s65"><Data ss:Type="String">Funcionario</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' 	<Cell ss:StyleID="s65"><Data ss:Type="String">Status</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' 	<Cell ss:StyleID="s65"><Data ss:Type="String">Horas Extras</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' 	<Cell ss:StyleID="s65"><Data ss:Type="String">Absent.</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' 	<Cell ss:StyleID="s65"><Data ss:Type="String">Quant. de Horas Periodo</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' 	<Cell ss:StyleID="s65"><Data ss:Type="String">Decimal</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' 	<Cell ss:StyleID="s65"><Data ss:Type="String">Dias</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' 	<Cell ss:StyleID="s65"><Data ss:Type="String">Horas/Minutos</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' 	<Cell ss:StyleID="s65"><Data ss:Type="String">Horas</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' 	<Cell ss:StyleID="s65"><Data ss:Type="String">Minutos</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' 	<Cell ss:StyleID="s65"><Data ss:Type="String">Horas Trab. &#10;V@</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
	cXML += ' </Row>' + CRLF
	// fQuadro3
	While !(_cAliasG)->(Eof())
	
		If Empty( (_cAliasG)->P8_MAT )
			(_cAliasG)->(DbSkip())   // U_VAPTEM01()
			Loop
		EndIf
	
		If _cCodigo <> (_cAliasG)->P8_FILIAL+(_cAliasG)->P8_MAT
	
			cXML += '<Row>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->P8_FILIAL ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->P8_MAT 	  ) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->RA_NOME 	) + '</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto" ss:Formula="=IF(RC[1]=RC[2],&quot;&quot;,IF(RC[1]&gt;RC[2],&quot;A Compensar&quot;,&quot;Devendo Horas&quot;))"><Data ss:Type="String">A Compensar</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF		
			cXML += '  <Cell ss:StyleID="sHoraCurtaH" ss:Formula="=SUMIF(Batidas!R3C3:R'+cValToChar(nRegistros+2)+'C3,CONCATENATE(RC1,RC2),Batidas!R3C[21]:R'+cValToChar(nRegistros+2)+'C[21])"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sHoraCurtaH" ss:Formula="=SUMIF(Batidas!R3C3:R'+cValToChar(nRegistros+2)+'C3,CONCATENATE(RC1,RC2),Batidas!R3C[21]:R'+cValToChar(nRegistros+2)+'C[21])"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sHoraCurtaH" ss:Formula="=IF(RC[-2]=RC[-1],&quot;&quot;,IF(RC[-2]&gt;RC[-1],RC[-2]-RC[-1],RC[-1]-RC[-2]))"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:Formula="=IFERROR((RC[-1]/RC[5]),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s89" ss:Formula="=IFERROR(IF(TRUNC(RC[-1],0)=0,&quot;&quot;,TRUNC(RC[-1],0)),&quot;&quot;)"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sHoraCurta" ss:Formula="=IF(RC[-3]&gt;RC[3],RC[-3]-(RC[-1]*RC[3]),RC[-3])"><Data ss:Type="DateTime"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF		
			cXML += '  <Cell ss:StyleID="s93" ss:Formula="=IFERROR(IF(HOUR(RC[-1])=0,&quot;&quot;,HOUR(RC[-1])),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s92" ss:Formula="=IFERROR(IF(MINUTE(RC[-2])=0,&quot;&quot;,MINUTE(RC[-2])),&quot;&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			// cXML += '  <Cell ss:StyleID="sHoraCurta" ss:Formula="=TEXT(VLOOKUP(CONCATENATE(RC[-12],RC[-11]),Batidas!R3C3:R'+cValToChar(nRegistros+2)+'C25,23,0),&quot;h:mm&quot;)"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sHoraCurta" ss:Formula="=VLOOKUP(CONCATENATE(RC[-12],RC[-11]),Batidas!R3C3:R'+cValToChar(nRegistros+2)+'C25,23,0)"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			// cXML += '  <Cell ss:StyleID="sHoraCurta" ss:Formula="=MAX(IF(Batidas!R3C3:R'+cValToChar(nRegistros+2)+'C3=CONCATENATE(RC[-12],RC[-11]),Batidas!R3C25:R'+cValToChar(nRegistros+2)+'C25,&quot;&quot;))"><Data ss:Type="String"></Data><NamedCell ss:Name="_FilterDatabase"/></Cell>' + CRLF
			cXML += '</Row>' + CRLF
			
		EndIf
		
		_cCodigo := (_cAliasG)->P8_FILIAL+(_cAliasG)->P8_MAT
		
		(_cAliasG)->(DbSkip())   // U_VAPTEM01()
	EndDo
	// fQuadro3
	cXML += ' </Table>' + CRLF
	cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += ' 	<PageSetup>' + CRLF
	cXML += ' 		<Header x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<Footer x:Margin="0.31496062000000002"/>' + CRLF
	cXML += ' 		<PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
	cXML += ' 	</PageSetup>' + CRLF
	cXML += ' 	<Print>' + CRLF
	cXML += ' 		<ValidPrinterInfo/>' + CRLF
	cXML += ' 		<PaperSizeIndex>9</PaperSizeIndex>' + CRLF
	cXML += ' 		<HorizontalResolution>600</HorizontalResolution>' + CRLF
	cXML += ' 		<VerticalResolution>600</VerticalResolution>' + CRLF
	cXML += ' 	</Print>' + CRLF
	cXML += ' 	<FreezePanes/>' + CRLF
	cXML += '   <FrozenNoSplit/>' + CRLF
	cXML += '   <SplitHorizontal>2</SplitHorizontal>' + CRLF
	cXML += '   <TopRowBottomPane>23</TopRowBottomPane>' + CRLF
	cXML += '   <SplitVertical>6</SplitVertical>' + CRLF
	cXML += '   <LeftColumnRightPane>6</LeftColumnRightPane>' + CRLF
	cXML += '   <ActivePane>0</ActivePane>' + CRLF
	cXML += '   <Panes>' + CRLF
	cXML += '    <Pane>' + CRLF
	cXML += '     <Number>3</Number>' + CRLF
	cXML += '    </Pane>' + CRLF
	cXML += '    <Pane>' + CRLF
	cXML += '     <Number>1</Number>' + CRLF
	cXML += '    </Pane>' + CRLF
	cXML += '    <Pane>' + CRLF
	cXML += '     <Number>2</Number>' + CRLF
	cXML += '     <ActiveRow>2</ActiveRow>' + CRLF
	cXML += '    </Pane>' + CRLF
	cXML += '    <Pane>' + CRLF
	cXML += '     <Number>0</Number>' + CRLF
	cXML += '     <ActiveRow>50</ActiveRow>' + CRLF
	cXML += '     <ActiveCol>3</ActiveCol>' + CRLF
	cXML += '    </Pane>' + CRLF
	cXML += '   </Panes>' + CRLF
	cXML += ' 	<ProtectObjects>False</ProtectObjects>' + CRLF
	cXML += ' 	<ProtectScenarios>False</ProtectScenarios>' + CRLF
	cXML += ' </WorksheetOptions>' + CRLF
	cXML += ' <AutoFilter x:Range="R2C1:R'+cValToChar(nRegistros+2)+'C13" xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
	cXML += ' </AutoFilter>' + CRLF
	cXML += ' </Worksheet>' + CRLF
	// fQuadro3
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
EndIf

Return nil
// fQuadro3


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAPTEM01()                                      |
 | Func:                                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  30.01.2019                                                              |
 | Desc:                                                                          |
 '--------------------------------------------------------------------------------*
 | Param: lIsHora: Define se a hora vem no formato com . no meio;                 |
 |                                                                                |
 '--------------------------------------------------------------------------------*
 | Obs.:  -                                                                       |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
// User Function fHraToXML( cHora ) // , /*lMadrugada,*/ cPad, lIsHora)
User Function HoraToExcel( cHora ) // , /*lMadrugada,*/ cPad, lIsHora)
Local cAux 			:= ""
Local nPosVir   	:= 0 // At(".", cHora )
Local nDias         := 0
Local nRest         := 0
Local dDtHora       := sToD('18991231')
Local cDtHora		:= ""
Local lIsHora       := At(".", cHora ) > 0 // .T.

// Default lMadrugada  := .F.
// Default cPad 		:= "C" // C=Curto => HH:MM

If !lIsHora .and. At(":", cHora ) == 0
	cHora := SubS( cHora, 1,2 ) + ":" + SubS( cHora, 3,2 )
EndIf
If At(":", cHora ) > 0
	cHora := cValToChar( SomaHoras( cHora, "0") )
EndIf
If ValType( cHora ) == "N" 
	cHora := cValToChar( cHora )
EndIf

nDias 	:= Val(cHora) / 24
If nDias > 1
	dDtHora += Int(nDias)

	nRest   := Val(cHora) - (24*Int(nDias))
	
	cHora	:= cValToChar(nRest) 
EndIf

cDtHora := DtoS(dDtHora)
cDtHora := SubS(cDtHora,1,4) + "-" + SubS(cDtHora,5,2) + "-" + SubS(cDtHora,7,2) + "T"


cAux 	:= Iif( ValType( cHora ) == "C", StrTran( cHora, ".", ":"), IntToHora( cHora )  )
if (nPosVir := At(":", cAux )) > 0
	cAux := PadL( SubS(cHora,1,nPosVir-1), 2, "0") + ":" + PadR( SubS(cHora,nPosVir+1,2), 2, "0")
Else
	If ValType( cHora ) == "N"
		cAux := IntToHora( cAux )
	Else
		cAux := IntToHora( Val(cHora) )
	EndIf
EndIf

// If lIsHora .or. At(".", cHora ) > 0
// 	If (nPosVir := At(".", cHora )) == 0
// 		cAux := PadL( cHora, 2, "0") + ":00"
// 	Else
// 		cAux := PadL( SubS(cHora,1,nPosVir-1), 2, "0" ) +;
// 				":" +;
// 				PadR( SubS(cHora,nPosVir+1), 2, "0" )
// 	EndIf
// Else
// 	If (nPosVir := At(":", cHora )) == 0
// 		cAux := SubS(cHora,1,2) + ":" + SubS(cHora,3,2)
// 	Else
// 		cAux := SubS(cHora,1,nPosVir-1) + ":" + SubS(cHora,nPosVir+1,2)
// 	EndIf
// EndIf
	
// If lMadrugada
// 	cAux := "1900-01-01T" + cAux + ":00.000"
// Else
// 	cAux := "1899-12-31T" + cAux + ":00.000"
// EndIf

// If nDias <= 0
// 	cAux := "1899-12-31T" + cAux + ":00.000"
// Else
	cAux := cDtHora + cAux + ":00.000"
// EndIf
	
Return cAux

/* 
https://advplconsulting.wordpress.com/2016/11/03/funcoes-de-datas/

fConvHr(aCodAbono[nX,2],'D')
DescPDPon(aTotSpc[nPass,1], cFilSP9 )
__TimeSum(nEfetAbono, aJustifica[nX,2] ) 
__TimeSub(nQUANTC,nEfetAbono)
DiaSemana(aImp[nX,1],8)
CDOW(CTOD("02/06/12"))               // Resulta: Sábado
 */
