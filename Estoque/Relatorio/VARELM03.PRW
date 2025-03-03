#include 'FILEIO.CH'
#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"

Static _ENTER_        := (Chr(13)+Chr(10))
static oCellHorAlign  := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign := FwXlsxCellAlignment():Vertical()

/*---------------------------------------------------------------------------------,
 | Analista : MIGUEL MARTINS BERNARDO JUNIOR                                       |
 | Data		: 02.04.2024                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Principal: U_VARELM03()                                                         |
'|---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/
User Function VARELM03() // U_VARELM03()
	Local cTimeIni       := Time()
	Local aArea          := GetArea()
	Local lRet           := .F.
	Local nRet           := 0
	Local nI             := nX := 0
	Local aHeadPrincipal := {;
							"Apartado" ,;
							"Curral" ,;
							"Lote" ,;
							"Cab." ,;
							"Peso" ,;
							"Ra�a" ,;
							"Sexo" ,;
							"Dt. Entrada",;
							"Dias Cocho" ,;
							"GMD Esp." ,;
							"Peso Atual" }
	Local aHeadDetalhes  := {;
							"Animais" ,;
							"Fornecedor",;
							"Corretor" }
	Local aDadosPri      := {}
	Local aDadosDet      := {}
	Local cNameRot       := ""

	Private cPerg        := SubS(ProcName(),3)
	Private cTitulo      := "Relat�rio de Estoque na recep��o"
	Private cPath        := "C:\totvs_relatorios\"
	// Private cPath        := "/private/tmp/" // "/Users/miguelbernardo/tmp/TOTVS_RELATORIOS/" // "C:\totvs_relatorios\"
	Private cArquivo     := cPath + cPerg +; // __cUserID+"_"+;
							DtoS(dDataBase)+;
							"_"+;
							StrTran(SubS(Time(),1,5),":","")+;
							".rel"

	Private oFileW       := nil
	Private oExcel       := NIL
	Private jFormatTit,jFormatTot,jFormatHead,jFormatGD,JFLeft,JFRight,jFData,jFNum,jFMoeda //Formato de Celula
	Private jFontHeader,jFontTitulo,jFontText //Fontes
	Private jBHeaderLeft,jBHeaderRight,jBorderLeft,jBorderCenter,jBorderRight,jBottomLeft,jBottomRight,jNoBorder // Bordas

	If Len( Directory(cPath + "*.*","D") ) == 0
		If Makedir(cPath) == 0
			ConOut('Diretorio Criado com Sucesso.')
			MsgAlert('Diretorio Criado com Sucesso: ' + cPath, 'Aviso')
		Else
			ConOut( "N�o foi possivel criar o diret�rio. Erro: " + cValToChar( FError() ) )
			MsgAlert( "N�o foi possivel criar o diret�rio. Erro: " + cValToChar( FError() ), 'Aviso' )
		EndIf
	EndIF

	FWMsgRun(, {|| aDadosPri := LoadQuery("Principal" ) },;
		'Por Favor Aguarde...',;
		'Processando Banco de Dados - Lotes')

	FWMsgRun(, {|| aDadosDet := LoadQuery("Detalhes" ) },;
		'Por Favor Aguarde...',;
		'Processando Banco de Dados - Detalhes')

	If Len(aDadosPri) > 0 .AND. Len(aDadosDet) > 0

		U_DefFormPrinterXlsx()

		oExcel := FwPrinterXlsx():New()
		oExcel:Activate(cArquivo)

		oExcel:AddSheet( "Baias" )

		nRow := 1
		nCol := 1

		oExcel:SetCellsFormatConfig(jFormatTit)
		oExcel:SetFontConfig(jFontTitulo)
		oExcel:MergeCells(nRow, nCol, nRow, Len(aHeadPrincipal))

		cNameRot := "RELATORIO DE ESTOQUE DAS BAIAS NO RODIZIO"

		oExcel:SetText(nRow, nCol, cNameRot)

		oExcel:SetCellsFormatConfig(jFormatHead)
		oExcel:SetFontConfig(jFontHeader)
		nRow += 1

		// Imprimindo o Cabe�alho
		For nX := nCol to Len(aHeadPrincipal)
			oExcel:SetValue(nRow, nX, aHeadPrincipal[nX])
		Next nX

		For nI := 1 to Len(aDadosPri)

			nRow += 1
			nCol := 1

			oExcel:SetFontConfig(jFontText)
			oExcel:SetCellsFormatConfig(JFLeft)
			oExcel:SetBorderConfig(jNoBorder)

			oExcel:SetValue(nRow,   nCol, aDadosPri[nI][01] ) // "Apartado"
			oExcel:SetValue(nRow, ++nCol, aDadosPri[nI][02] ) // "Curral"
			oExcel:SetValue(nRow, ++nCol, aDadosPri[nI][03] ) // "Lote"
			oExcel:SetValue(nRow, ++nCol, aDadosPri[nI][04] ) // "Cab."
			oExcel:SetValue(nRow, ++nCol, aDadosPri[nI][05] ) // "Peso"
			oExcel:SetValue(nRow, ++nCol, aDadosPri[nI][06] ) // "Ra�a"
			oExcel:SetValue(nRow, ++nCol, aDadosPri[nI][07] ) // "Sexo"
			oExcel:SetValue(nRow, ++nCol, aDadosPri[nI][08] ) // "Dt. Entrada"
			oExcel:SetValue(nRow, ++nCol, aDadosPri[nI][09] ) // "Dias Cocho"
			oExcel:SetValue(nRow, ++nCol, aDadosPri[nI][10] ) // "GMD Esp."
			oExcel:SetValue(nRow, ++nCol, aDadosPri[nI][11] ) // "Peso Atual"

			if (nPosDet := aScan( aDadosDet, { |x| x[1] == aDadosPri[nI][02] .AND. x[2] == aDadosPri[3] } )) > 0
				nCol := 4
				While nPosDet <= LEN(aDadosDet) .AND.;
						aDadosDet[ nPosDet, 01 ] == aDadosPri[nI][02] .AND.;
				        aDadosDet[ nPosDet, 02 ] == aDadosPri[nI][03]

					nRow += 1

					oExcel:SetFontConfig(jFontText)
					oExcel:SetCellsFormatConfig(JFLeft)
					oExcel:SetBorderConfig(jNoBorder)

					oExcel:SetValue(nRow,   nCol, aDadosDet[nPosDet][01] ) // "Animais"
					oExcel:SetValue(nRow, ++nCol, aDadosDet[nPosDet][02] ) // "Fornecedor"
					oExcel:SetValue(nRow, ++nCol, aDadosDet[nPosDet][03] ) // "Corretor"

					nPosDet += 1
				EndDo
			EndIf

		Next nI

		lRet := oExcel:toXlsx()

		nRet := ShellExecute("open", SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx", "", "", 1)

		//Se houver algum erro
		If nRet <= 32
			MsgStop("N�o foi poss�vel abrir o arquivo "+SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx"+ "!", "Aten��o")
		EndIf

		oExcel:DeActivate()
	else
		MsgAlert("N�o h� dados para os parametros informados!")
	EndIf

	If lower(cUserName) $ 'bernardo,ioliveira,atoshio,admin,administrador'
		Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
	EndIf

	RestArea(aArea)

	ConOut('Activate: ' + Time())

Return nil

/*---------------------------------------------------------------------------------,
 | Analista : MIGUEL MARTINS BERNARDO JUNIOR                                       |
 | Data		: 03.04.2024                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Principal: U_VARELM03()                                                         |
'|--------------------------------------------------------------------------------*/
Static Function LoadQuery(cOpc)
	Local cQry    := ""
	Local aDados  := {}
	Local _cAlias := GetNextAlias()

	If cOpc == "Principal"
		cQry := "" + _ENTER_ +;
			" SELECT  " + _ENTER_ +;
			" 	  CASE WHEN QTD_APARTADO > 0 " + _ENTER_ +;
			" 		THEN 'SIM' " + _ENTER_ +;
			" 		ELSE 'N�O' " + _ENTER_ +;
			" 		END APARTADO " + _ENTER_ +;
			" 	, CURRAL " + _ENTER_ +;
			" 	, LOTE " + _ENTER_ +;
			" 	, QTDE " + _ENTER_ +;
			" 	, PESO " + _ENTER_ +;
			" 	, RACA " + _ENTER_ +;
			" 	, SEXO " + _ENTER_ +;
			" 	, DATA_INICIO " + _ENTER_ +;
			" 	, DIAS_DE_COCHO " + _ENTER_ +;
			" 	, GMD_ESPERADO " + _ENTER_ +;
			" 	, PESO " + _ENTER_ +;
			" FROM ( " + _ENTER_ +;
			" 	SELECT  " + _ENTER_ +;
			" 			B8_FILIAL " + _ENTER_ +;
			" 		  , M0_FILIAL  DESC_FILIAL " + _ENTER_ +;
			" 	      , RTRIM(M0_CODFIL)+RTRIM(B8_LOTECTL) FILIALLOTE " + _ENTER_ +;
			" 	      , Z08_LINHA LINHA " + _ENTER_ +;
			" 	      , CASE WHEN Z08_CONFNA = '99' AND B8_X_CURRA BETWEEN 'RP01' AND 'RP10' THEN 'RP01A10' " + _ENTER_ +;
			" 		         WHEN Z08_CONFNA = '99' AND B8_X_CURRA BETWEEN 'RP11' AND 'RP20' THEN 'RP11A20' " + _ENTER_ +;
			" 				 WHEN Z08_CONFNA = '99' AND B8_X_CURRA BETWEEN 'RP21' AND 'RP30' THEN 'RP21A30' " + _ENTER_ +;
			" 				 WHEN Z08_CONFNA = '99' AND B8_X_CURRA BETWEEN 'RP31' AND 'RP40' THEN 'RP31A40' " + _ENTER_ +;
			" 				 WHEN Z08_CONFNA = '99' AND B8_X_CURRA BETWEEN 'RP41' AND 'RP52' THEN 'RP41A52' " + _ENTER_ +;
			" 				 WHEN Z08_CONFNA = '99' AND B8_X_CURRA BETWEEN 'RP53' AND 'RP54' THEN 'RP53A54' " + _ENTER_ +;
			" 				 WHEN Z08_CONFNA = '99' AND B8_X_CURRA BETWEEN 'RP55' AND 'RP62' THEN 'RP55A62' " + _ENTER_ +;
			" 				 WHEN Z08_CONFNA = '99' AND B8_X_CURRA BETWEEN 'RP63' AND 'RP69' THEN 'RP63A69' " + _ENTER_ +;
			" 				 ELSE Z08_LINHA  END BAIA_AGRUP " + _ENTER_ +;
			" 		  , CASE WHEN Z08_CONFNA = '01' THEN 'B. VELHO' " + _ENTER_ +;
			" 		         WHEN Z08_CONFNA = '02' THEN 'B. NOVO'  " + _ENTER_ +;
			" 				 WHEN Z08_CONFNA = '99' THEN 'RECEPCAO' " + _ENTER_ +;
			" 				 ELSE 'CURRAIS' " + _ENTER_ +;
			" 				 END LOCAL " + _ENTER_ +;
			" 		  , B8_LOTECTL LOTE " + _ENTER_ +;
			" 	      , RTRIM(B8_X_CURRA) CURRAL " + _ENTER_ +;
			" 	      , SUM(B8_SALDO) QTDE " + _ENTER_ +;
			" 		  , ( " + _ENTER_ +;
			" 				SELECT COUNT(*) QTD " + _ENTER_ +;
			" 				FROM Z0F010 " + _ENTER_ +;
			" 				WHERE	 " + _ENTER_ +;
			" 					Z0F_FILIAL = B8_FILIAL " + _ENTER_ +;
			" 				AND Z0F_LOTE   = B8_LOTECTL " + _ENTER_ +;
			" 				AND Z0F_CURRAL = B8_X_CURRA " + _ENTER_ +;
			" 				AND D_E_L_E_T_ = ' ' " + _ENTER_ +;
			" 			) " + _ENTER_ +;
			" 			QTD_APARTADO " + _ENTER_ +;
			" 		  , AVG(B8_XPESOCO) PESO " + _ENTER_ +;
			" 		  , ISNULL((CASE WHEN Z0O.Z0O_SEXO = 'M' THEN 'MACHO' " + _ENTER_ +;
			" 		                 WHEN Z0O.Z0O_SEXO = 'F' THEN 'FEMEA' " + _ENTER_ +;
			" 						 WHEN Z0O.Z0O_SEXO = 'C' THEN 'CAP�O' " + _ENTER_ +;
			" 						 ELSE (SELECT A.Z0F_SEXO  " + _ENTER_ +;
			" 		                         FROM ( SELECT Z0F_SEXO, COUNT(Z0F.R_E_C_N_O_) QTD " + _ENTER_ +;
			" 		                                  FROM Z0F010 Z0F  " + _ENTER_ +;
			" 				                         WHERE Z0F.Z0F_LOTE = '128-54' AND Z0F.D_E_L_E_T_ = ' '  " + _ENTER_ +;
			" 				                      GROUP BY Z0F.Z0F_SEXO) A) " + _ENTER_ +;
			" 						 END),'') SEXO " + _ENTER_ +;
			" 		  , ISNULL((Z0O.Z0O_RACA),  " + _ENTER_ +;
			" 		           (SELECT A.Z0F_RACA  " + _ENTER_ +;
			" 		  FROM ( SELECT Z0F_RACA, COUNT(Z0F.R_E_C_N_O_) QTD " + _ENTER_ +;
			" 		           FROM Z0F010 Z0F  " + _ENTER_ +;
			" 				  WHERE Z0F.Z0F_LOTE = '128-54' AND Z0F.D_E_L_E_T_ = ' '  " + _ENTER_ +;
			" 				  GROUP BY Z0F.Z0F_RACA ) A) " + _ENTER_ +;
			" 		  ) RACA " + _ENTER_ +;
			" 	      , CASE WHEN Z0O_DINITR = ' ' THEN CONVERT(DATE,MIN(SB8.B8_XDATACO),103)  " + _ENTER_ +;
			"                  WHEN Z0O_DINITR <> ' ' THEN CONVERT(DATE,Z0O_DINITR ,103) " + _ENTER_ +;
			" 				 ELSE CONVERT(DATE,MIN(SB8.B8_XDATACO), 103) END DATA_INICIO  " + _ENTER_ +;
			" 		  , DATEDIFF(DAY,  " + _ENTER_ +;
			"                  CASE WHEN Z0O_DINITR = ' ' THEN CONVERT(DATE,MIN(SB8.B8_XDATACO),103)  " + _ENTER_ +;
			"                       WHEN Z0O_DINITR <> ' ' THEN CONVERT(DATE,Z0O_DINITR ,103) " + _ENTER_ +;
			" 	            	  ELSE CONVERT(DATE,MIN(SB8.B8_XDATACO), 103)  " + _ENTER_ +;
			" 				 END  " + _ENTER_ +;
			" 	    		 ,  " + _ENTER_ +;
			"    	    		 CONVERT(DATE, GETDATE(), 103) " + _ENTER_ +;
			" 				) DIAS_DE_COCHO " + _ENTER_ +;
			" 		  , ISNULL(Z0O_PESOPR, 0) PESO_PROJETADO " + _ENTER_ +;
			" 		  , ISNULL((Z0O.Z0O_MCALPR),0) MEGA_CAL " + _ENTER_ +;
			" 		  , ISNULL(CASE WHEN Z0O_GMD >= 1.5 THEN Z0O_GMD ELSE 1.5 END ,1.7) GMD_ESPERADO " + _ENTER_ +;
			" 		  , ISNULL((SELECT Z05.Z05_CMSPN  " + _ENTER_ +;
			" 		              FROM Z05010 Z05  " + _ENTER_ +;
			" 					 WHERE Z05.Z05_FILIAL = B8_FILIAL  " + _ENTER_ +;
			" 					   AND Z05.Z05_LOTE = B8_LOTECTL  " + _ENTER_ +;
			" 					   AND Z05.D_E_L_E_T_ =' '   " + _ENTER_ +;
			" 					   AND Z05.Z05_DATA = (SELECT MAX(Z05D.Z05_DATA)  " + _ENTER_ +;
			" 					                     FROM Z05010 Z05D  " + _ENTER_ +;
			" 										WHERE Z05D.Z05_FILIAL = Z05.Z05_FILIAL " + _ENTER_ +;
			" 										  AND Z05D.Z05_LOTE = Z05.Z05_LOTE " + _ENTER_ +;
			" 										  AND Z05D.D_E_L_E_T_ = ' ' )),0) PERCENT_CMS_PV " + _ENTER_ +;
			"           , ISNULL((SELECT Z05.Z05_MEGCAL  " + _ENTER_ +;
			" 		              FROM Z05010 Z05  " + _ENTER_ +;
			" 					 WHERE Z05.Z05_FILIAL = B8_FILIAL  " + _ENTER_ +;
			" 					   AND Z05.Z05_LOTE = B8_LOTECTL  " + _ENTER_ +;
			" 					   AND Z05.D_E_L_E_T_ =' '   " + _ENTER_ +;
			" 					   AND Z05.Z05_DATA = (SELECT MAX(Z05D.Z05_DATA)  " + _ENTER_ +;
			" 					                     FROM Z05010 Z05D  " + _ENTER_ +;
			" 										WHERE Z05D.Z05_FILIAL = Z05.Z05_FILIAL " + _ENTER_ +;
			" 										  AND Z05D.Z05_LOTE = Z05.Z05_LOTE " + _ENTER_ +;
			" 										  AND Z05D.D_E_L_E_T_ = ' ' )),0) MEGA_CAL_ATUAL " + _ENTER_ +;
			" 		  , ROUND(ISNULL((SELECT MIN(SG1.G1_ENERG) " + _ENTER_ +;
			" 			            FROM SG1010 SG1  " + _ENTER_ +;
			" 					   WHERE SG1.G1_FILIAL = SB8.B8_FILIAL " + _ENTER_ +;
			" 					     AND SG1.G1_COD = 'FINAL'  " + _ENTER_ +;
			" 						 AND SG1.D_E_L_E_T_ = ' ' " + _ENTER_ +;
			" 						 ),0)  " + _ENTER_ +;
			" 			  *  " + _ENTER_ +;
			" 		  ISNULL((SELECT Z0O.Z0O_PESO * (Z0O.Z0O_CMSPRE/100)  " + _ENTER_ +;
			" 			 FROM Z0O010 Z0O  " + _ENTER_ +;
			" 			WHERE Z0O.Z0O_FILIAL = SB8.B8_FILIAL " + _ENTER_ +;
			" 			  AND Z0O.Z0O_LOTE = SB8.B8_LOTECTL " + _ENTER_ +;
			" 			  AND Z0O.Z0O_DATATR = ' ' AND Z0O.D_E_L_E_T_ = ' ' ),0),2) MEGA_CAL_PROJETADO " + _ENTER_ +;
			"        FROM SB8010 SB8 " + _ENTER_ +;
			"   LEFT JOIN Z0O010 Z0O ON  " + _ENTER_ +;
			"             Z0O_FILIAL = B8_FILIAL " + _ENTER_ +;
			" 		AND Z0O_LOTE = B8_LOTECTL  " + _ENTER_ +;
			" 		AND (Z0O_DATATR = ' ' AND Z0O_DATATR < GETDATE()) " + _ENTER_ +;
			" 		AND Z0O.D_E_L_E_T_ = ' '  " + _ENTER_ +;
			"        JOIN Z08010 Z08 ON " + _ENTER_ +;
			" 	        Z08_FILIAL = B8_FILIAL " + _ENTER_ +;
			" 		AND Z08_CODIGO = B8_X_CURRA " + _ENTER_ +;
			" 		AND Z08_CONFNA = '99' " + _ENTER_ +;
			" 		AND Z08.D_E_L_E_T_ = ' '  " + _ENTER_ +;
			" 	   JOIN SYS_COMPANY SM0 ON  " + _ENTER_ +;
			" 	        M0_CODIGO = '01' " + _ENTER_ +;
			" 	    AND M0_CODFIL = '0101001' " + _ENTER_ +;
			" 		AND M0_CODFIL = B8_FILIAL " + _ENTER_ +;
			" 		AND SM0.D_E_L_E_T_ = ' '  " + _ENTER_ +;
			"       WHERE  " + _ENTER_ +;
			" 			SB8.B8_SALDO   <> 0 " + _ENTER_ +;
			"         AND SB8.D_E_L_E_T_ = ' ' " + _ENTER_ +;
			"         AND B8_X_CURRA <> ' '  " + _ENTER_ +;
			" 		--AND B8_LOTECTL = '153-27' " + _ENTER_ +;
			"  GROUP BY M0_FILIAL " + _ENTER_ +;
			"         , B8_X_CURRA " + _ENTER_ +;
			"         , M0_CODFIL " + _ENTER_ +;
			"         , B8_FILIAL " + _ENTER_ +;
			" 		, Z08_CONFNA " + _ENTER_ +;
			"         , Z08_LINHA " + _ENTER_ +;
			"         , B8_LOTECTL " + _ENTER_ +;
			" 		, Z0O_SEXO " + _ENTER_ +;
			" 		, Z0O_RACA " + _ENTER_ +;
			"         , Z0O_DINITR " + _ENTER_ +;
			"         , Z0O_PESOPR " + _ENTER_ +;
			"         , Z0O_GMD " + _ENTER_ +;
			" 		, Z0O_MCALPR " + _ENTER_ +;
			" ) BASE " + _ENTER_ +;
			" ORDER BY CURRAL "

	ElseIf cOpc == "Detalhes"
		cQry := "" + _ENTER_ +;
			" 	    SELECT DISTINCT B8_X_CURRA [CURRAL],  B8_PRODUTO, B8_LOTECTL [LOTE], B8_SALDO[SALDO] " + _ENTER_ +;
			" 	        , CONVERT(DATE,B8_XDATACO,103) [DATAA], B8_XPESOCO [PESO], B1_XRACA [RACA], B1_X_SEXO [SEXO] " + _ENTER_ +;
			"     	    , ISNULL(RTRIM(ZCC_NOMFOR),'RECRIA' ) [FORNECEDOR]  " + _ENTER_ +;
			"     	    , ISNULL(RTRIM(A3_NOME), 'V@' ) [CORRETOR]        " + _ENTER_ +;
			" 			, ISNULL((CASE WHEN (SELECT DISTINCT Z0F_LOTE FROM Z0F010 WHERE Z0F_LOTE = B8_LOTECTL AND D_E_L_E_T_ = ' ') <> ' '  THEN 'SIM'END ), 'N�O ') [SITUACAO]  " + _ENTER_ +;
			"       FROM SB8010 SB8  " + _ENTER_ +;
			"       JOIN SB1010 SB1 ON B1_COD = B8_PRODUTO AND SB1.D_E_L_E_T_ = ' '   " + _ENTER_ +;
			"       JOIN Z08010 Z08 ON Z08_CODIGO = B8_X_CURRA and Z08.D_E_L_E_T_ = ' '   " + _ENTER_ +;
			"  LEFT JOIN ZBC010 ZBC ON ZBC_FILIAL+ZBC_PEDIDO = B1_XLOTCOM AND ZBC.D_E_L_E_T_ = ' '    " + _ENTER_ +;
			"  LEFT JOIN ZCC010 ZCC ON ZBC_FILIAL+ZBC_CODIGO = ZCC_FILIAL+ZCC_CODIGO AND ZCC.D_E_L_E_T_ = ' '   " + _ENTER_ +;
			"  LEFT JOIN SA3010 SA3 ON A3_COD = ZCC_CODCOR AND SA3.D_E_L_E_T_ = ' '   " + _ENTER_ +;
			"      WHERE SB8.D_E_L_E_T_ = ' '  " + _ENTER_ +;
			"        AND Z08_CONFNA = '99'  " + _ENTER_ +;
			"        AND B8_SALDO > 0   " + _ENTER_ +;
			" 	   AND SB8.D_E_L_E_T_ = ' ' " + _ENTER_ +;
			" ORDER BY 1 "
	EndIf

	memowrite("C:\TOTVS_RELATORIOS\" + FunName() + cOPC + ".sql", cQry)

	MpSysOpenQuery(cQry, _cAlias)
	While !(_cAlias)->(EOF())

		if cOpc == "Principal"

			aAdd(aDados, {;
				(_cAlias)->APARTADO,;        // 01
				(_cAlias)->CURRAL,;          // 02
				(_cAlias)->LOTE,;            // 03
				(_cAlias)->QTDE,;            // 04
				(_cAlias)->PESO,;            // 05
				(_cAlias)->RACA,;            // 06
				(_cAlias)->SEXO,;            // 07
				(_cAlias)->DATA_INICIO,;     // 08
				(_cAlias)->DIAS_DE_COCHO,;   // 09
				(_cAlias)->GMD_ESPERADO,;    // 10
				(_cAlias)->PESO_PROJETADO }) // 11

		ElseIf cOpc == "Detalhes"

			aAdd(aDados, {;
				(_cAlias)->CURRAL,;          // 01
				(_cAlias)->LOTE,;            // 02
				(_cAlias)->SALDO,;           // 03
				(_cAlias)->FORNECEDOR,;      // 04
				(_cAlias)->CORRETOR })       // 05
		EndIf

		(_cAlias)->(DbSkip())
	EndDo
	(_cAlias)->(DbCloseArea())

Return aDados


/*---------------------------------------------------------------------------------,
 | Analista : MIGUEL MARTINS BERNARDO JUNIOR                                       |
 | Data		: 03.04.2024                                                           |
 | Cliente  : V@                                                                   |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Principal: U_VARELM03()                                                         |
'|---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/


User Function DefFormPrinterXlsx()
	Local cCVerde       := '00A85A'
	Local cCCinza       := "A0A0A0"
	Local cCAmarelo     := "FFFF00"

	jFontHeader := FwXlsxPrinterConfig():MakeFont()
	jFontHeader['font'] := FwPrinterFont():Calibri()
	jFontHeader['size'] := 12
	jFontHeader['bold'] := .T.

	jFontTitulo := FwXlsxPrinterConfig():MakeFont()
	jFontTitulo['font'] := FwPrinterFont():Calibri()
	jFontTitulo['size'] := 14
	jFontTitulo['bold'] := .T.
	jFontTitulo['underline'] := .T.

	jFontText := FwXlsxPrinterConfig():MakeFont()
	jFontText['font'] := FwPrinterFont():Calibri()
	jFontText['size'] := 12
	jFontText['italic'] := .F.

	JFLeft := FwXlsxPrinterConfig():MakeFormat()
	JFLeft['hor_align']        := oCellHorAlign:Left()
	JFLeft['vert_align']       := oCellVertAlign:Center()

	JFRight := FwXlsxPrinterConfig():MakeFormat()
	JFRight['hor_align']        := oCellHorAlign:RIGHT()
	JFRight['vert_align']       := oCellVertAlign:Center()

	jFData := FwXlsxPrinterConfig():MakeFormat()
	jFData['custom_format']    := "dd/mm/yyyy"
	jFData['hor_align']        := oCellHorAlign:Left()
	jFData['vert_align']       := oCellVertAlign:Center()

	jFormatTit := FwXlsxPrinterConfig():MakeFormat()
	jFormatTit['hor_align']         := oCellHorAlign:Center()
	jFormatTit['vert_align']        := oCellVertAlign:Center()
	jFormatTit['background_color']  := cCVerde

	jFormatGD := FwXlsxPrinterConfig():MakeFormat()
	jFormatGD['hor_align']         := oCellHorAlign:Center()
	jFormatGD['vert_align']        := oCellVertAlign:Center()
	jFormatGD['background_color']  := cCAmarelo

	jFormatTot := FwXlsxPrinterConfig():MakeFormat()
	jFormatTot['custom_format']     := "\R$ ###,##0.00"
	jFormatTot['hor_align']         := oCellHorAlign:Center()
	jFormatTot['vert_align']        := oCellVertAlign:Center()
	jFormatTot['background_color']  := cCCinza

	jFormatHead := FwXlsxPrinterConfig():MakeFormat()
	jFormatHead['hor_align']         := oCellHorAlign:LEFT()
	jFormatHead['vert_align']        := oCellVertAlign:Center()
	jFormatHead['background_color']  := "A0A0A0" //amarelo

	jFMoeda := FwXlsxPrinterConfig():MakeFormat()
	jFMoeda['custom_format']    := "\R$ ###,##0.00"
	jFMoeda['hor_align']        := oCellHorAlign:RIGHT()
	jFMoeda['vert_align']       := oCellVertAlign:Center()

	jFNum := FwXlsxPrinterConfig():MakeFormat()
	jFNum['hor_align']        := oCellHorAlign:Left()
	jFNum['vert_align']       := oCellVertAlign:Center()

	// Bordas para o header
	jNoBorder := FwXlsxPrinterConfig():MakeBorder()
	jNoBorder['top']    := .F.
	jNoBorder['bottom'] := .F.
	jNoBorder['left']   := .F.
	jNoBorder['right']  := .F.
	jNoBorder['border_color'] := "000000"
	jNoBorder['style'] := FwXlsxBorderStyle():None()

	jBHeaderLeft := FwXlsxPrinterConfig():MakeBorder()
	jBHeaderLeft['top']    := .T.
	jBHeaderLeft['bottom'] := .F.
	jBHeaderLeft['left']   := .T.
	jBHeaderLeft['right']  := .F.
	jBHeaderLeft['border_color'] := "000000"
	jBHeaderLeft['style'] := FwXlsxBorderStyle():Thick()

	jBHeaderRight := FwXlsxPrinterConfig():MakeBorder()
	jBHeaderRight['top']    := .T.
	jBHeaderRight['bottom'] := .F.
	jBHeaderRight['left']   := .F.
	jBHeaderRight['right']  := .T.
	jBHeaderRight['border_color'] := "000000"
	jBHeaderRight['style'] := FwXlsxBorderStyle():Thick()

	jBottomLeft := FwXlsxPrinterConfig():MakeBorder()
	jBottomLeft['top']    := .F.
	jBottomLeft['bottom'] := .T.
	jBottomLeft['left']   := .T.
	jBottomLeft['right']  := .F.
	jBottomLeft['border_color'] := "000000"
	jBottomLeft['style'] := FwXlsxBorderStyle():Thick()

	jBottomRight := FwXlsxPrinterConfig():MakeBorder()
	jBottomRight['top']    := .F.
	jBottomRight['bottom'] := .T.
	jBottomRight['left']   := .F.
	jBottomRight['right']  := .T.
	jBottomRight['border_color'] := "000000"
	jBottomRight['style'] := FwXlsxBorderStyle():Thick()

	jBorderLeft := FwXlsxPrinterConfig():MakeBorder()
	jBorderLeft['left'] := .T.
	jBorderLeft['border_color'] := "000000"
	jBorderLeft['style'] := FwXlsxBorderStyle():Thick()

	jBorderCenter := FwXlsxPrinterConfig():MakeBorder()
	jBorderCenter['left'] := .T.
	jBorderCenter['right'] := .T.
	jBorderCenter['border_color'] := "000000"
	jBorderCenter['style'] := FwXlsxBorderStyle():Thick()

	jBorderRight := FwXlsxPrinterConfig():MakeBorder()
	jBorderRight['right'] := .T.
	jBorderRight['border_color'] := "000000"
	jBorderRight['style'] := FwXlsxBorderStyle():Thick()

Return
