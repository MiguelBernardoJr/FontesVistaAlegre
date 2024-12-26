#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "TOPCONN.CH"
#include 'FILEIO.CH'

/*--------------------------------------------------------------------------------,
 | Principal: 			            U_LVRELT01()            		              |
 | Func:  VAESTR18()	            	          	            	          	  |
 | Autor: Arthur Toshio Oda Vanzella     	            	          	  		  |
 | Data:  22.12.2022	            	          	            	              |
 | Desc:  Dados do Lotes da Recepção                               	              |
 '--------------------------------------------------------------------------------|
 | Obs.: Solicitado pelo patrão Marquinhos em 22/12                               |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
User Function VAESTR18()
Local cTimeIni	 	:= Time()
Local cStyle		:= ""
Local cXML	   		:= ""
Local lTemDados		:= .T.
Private cPerg		:= "VAESTR18"  // SubS(ProcName(),3) // Usando as mesmas perguntas do outro relatório.
Private cTitulo  	:= "LISTA DOS LOTES DA RECEPÇÃO"

Private cPath 	 	:= "C:\TOTVS_RELATORIOS\"
Private cArquivo   	:= cPath + "VAESTR18" +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()   

Private nHandle    	:= 0

&('StaticCall(VAESTR18, GeraX1, cPerg)')
	
If Pergunte(cPerg, .T.)
	//U_PrintSX1(cPerg)
	
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
        cStyle += '  <Style ss:ID="s81">' +CRLF
        cStyle += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>' +CRLF
        cStyle += '   <Borders>' +CRLF
        cStyle += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '   </Borders>' +CRLF
        cStyle += '   <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"' +CRLF
        cStyle += '    ss:Color="#FFFFFF" ss:Bold="1"/>' +CRLF
        cStyle += '   <Interior ss:Color="#37752F" ss:Pattern="Solid"/>' +CRLF
        cStyle += '  </Style>' +CRLF
        cStyle += '  <Style ss:ID="sComBorda">' +CRLF
        cStyle += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>' +CRLF
        cStyle += '   <Borders>' +CRLF
        cStyle += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '   </Borders>' +CRLF
        cStyle += '   <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"' +CRLF
        cStyle += '    ss:Color="#000000"/>' +CRLF
        cStyle += '  </Style>' +CRLF
        cStyle += '  <Style ss:ID="s83" ss:Parent="s16">' +CRLF
        cStyle += '   <Borders>' +CRLF
        cStyle += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '   </Borders>' +CRLF
        cStyle += '   <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"' +CRLF
        cStyle += '    ss:Color="#000000"/>' +CRLF
        cStyle += '   <NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>' +CRLF
        cStyle += '  </Style>' +CRLF
        cStyle += '  <Style ss:ID="s84">' +CRLF
        cStyle += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>' +CRLF
        cStyle += '   <Borders>' +CRLF
        cStyle += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' +CRLF
        cStyle += '   </Borders>' +CRLF
        cStyle += '   <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"' +CRLF
        cStyle += '    ss:Color="#000000"/>' +CRLF
        cStyle += '   <NumberFormat ss:Format="Short Date"/>' +CRLF
        cStyle += '  </Style>' +CRLF
        cStyle += ' <Style ss:ID="s85">' + CRLF
        cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>' + CRLF
        cStyle += '  <Borders>' + CRLF
        cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
        cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
        cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
        cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
        cStyle += '  </Borders>' + CRLF
        cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"' + CRLF
        cStyle += '   ss:Color="#000000" ss:Bold="1"/>' + CRLF
        cStyle += ' </Style>' + CRLF
        cStyle += ' <Style ss:ID="s86sComBorda">' + CRLF
        cStyle += '  <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF
        cStyle += '  <Borders>' + CRLF
        cStyle += '   <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
        cStyle += '   <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
        cStyle += '   <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
        cStyle += '   <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF
        cStyle += '  </Borders>' + CRLF
        cStyle += '  <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"' + CRLF
        cStyle += '   ss:Color="#000000" ss:Bold="1"/>' + CRLF
        cStyle += '  <NumberFormat ss:Format="#,##0_ ;\-#,##0\ "/>' + CRLF
        cStyle += ' </Style>		' + CRLF



		cXML := U_CabXMLExcel(cStyle)
		// IMPRRIMIR TODOS EM UM RELATÓRIO
		FWMsgRun(, {|| lTemDados := fLoadSql("Geral", @_cAliasG ) },'Por Favor Aguarde...',;
									'Processando Banco de Dados - Consumo Projetado x Realizado')
		If lTemDados

			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
				cXML := ""
			EndIf
			
			// Gerar primeira planilha
			FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...',;
										'Geração do quadro de Consumo Projetado x Realizado')
		EndIf 
		
		(_cAliasG)->(DbCloseArea())

	

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
		/*
		Else
			MsgAlert("Os parametros informados não retornou nenhuma informação do banco de dados." + CRLF + ;
					 "Por isso o excel não sera aberto automaticamente.", "Dados não localizados")
		EndIf
		*/
		
		If lower(cUserName) $ 'mbernardo,atoshio,admin, administrador'
			Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
		EndIf
		
		ConOut('Activate: ' + Time())
	EndIf
EndIf

Return nil



/*--------------------------------------------------------------------------------,
 | Principal: 			            U_PCPREL04()            		              |
 | Func:  PCPREL04()	            	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  09.09.2019	            	          	            	              |
 | Desc:  Gestão do Trato                                          	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
Static Function fLoadSql(cTipo, _cAlias)
Local _cQry 		:= ""

If cTipo   == "Geral"


    _cQry += "     WITH LOTES AS ( " + CRLF
    _cQry += "    SELECT DISTINCT B8_X_CURRA,  B8_PRODUTO, B8_LOTECTL, B8_SALDO, B8_XDATACO, B8_XPESOCO, B1_XRACA, B1_X_SEXO  " + CRLF
    _cQry += "    	    , ISNULL(RTRIM(ZCC_NOMFOR),'RECRIA' ) [FORNECEDOR] " + CRLF
    _cQry += "    	    , ISNULL(RTRIM(A3_NOME), 'V@' ) [CORRETOR]       " + CRLF
	_cQry += ", CASE WHEN Z08_CODIGO BETWEEN 'RP41' AND 'RP53' THEN 10 " + CRLF
    _cQry += "       WHEN Z08_CODIGO BETWEEN 'RP31' AND 'RP40' THEN 9 " + CRLF
    _cQry += "	     WHEN Z08_CODIGO BETWEEN 'RP21' AND 'RP30' THEN 8 " + CRLF
    _cQry += "	     WHEN Z08_CODIGO BETWEEN 'RP11' AND 'RP20' THEN 7 " + CRLF
    _cQry += "	     WHEN Z08_CODIGO BETWEEN 'RP01' AND 'RP10' THEN 6 " + CRLF
    _cQry += "	     WHEN Z08_CODIGO BETWEEN 'RP54' AND 'RP61' THEN 5 " + CRLF
    _cQry += "	     WHEN Z08_CODIGO BETWEEN 'RP68' AND 'RP62' THEN 4 " + CRLF
    _cQry += "	     WHEN Z08_CODIGO LIKE 'RZ%' OR  Z08_CODIGO LIKE 'PS%' THEN '0' " + CRLF
    _cQry += "	     ELSE 1  " + CRLF
    _cQry += "	     END SEQUEN " + CRLF
    _cQry += "      FROM SB8010 SB8 " + CRLF 
    _cQry += "      JOIN SB1010 SB1 ON B1_COD = B8_PRODUTO AND SB1.D_E_L_E_T_ = ' '  " + CRLF
    _cQry += "      JOIN Z08010 Z08 ON Z08_CODIGO = B8_X_CURRA and Z08.D_E_L_E_T_ = ' '  " + CRLF
    _cQry += " LEFT JOIN ZBC010 ZBC ON ZBC_FILIAL+ZBC_PEDIDO = B1_XLOTCOM AND ZBC.D_E_L_E_T_ = ' '   " + CRLF
    _cQry += " LEFT JOIN ZCC010 ZCC ON ZBC_FILIAL+ZBC_CODIGO = ZCC_FILIAL+ZCC_CODIGO AND ZCC.D_E_L_E_T_ = ' '  " + CRLF
    _cQry += " LEFT JOIN SA3010 SA3 ON A3_COD = ZCC_CODCOR AND SA3.D_E_L_E_T_ = ' '  " + CRLF
    _cQry += "     WHERE SB8.D_E_L_E_T_ = ' ' " + CRLF
    _cQry += "       AND Z08_CONFNA = '99' " + CRLF
    _cQry += "       AND B8_SALDO > 0  " + CRLF
    _cQry += "       --AND B8_LOTECTL= '293-24'--'309-80    ' " + CRLF
    _cQry += "  --GROUP BY B8_X_CURRA,  B8_LOTECTL, B8_XDATACO, B8_XPESOCO, B1_XRACA, B1_X_SEXO, A3_NOME, ZCC_NOMFOR  " + CRLF
    _cQry += "    ) " + CRLF
    _cQry += " , CORRETORES AS (    " + CRLF
    _cQry += "    SELECT B8.B8_X_CURRA " + CRLF
    _cQry += "         , B8.B8_LOTECTL  " + CRLF
    _cQry += "         , ISNULL(( SELECT CASE  " + CRLF
    _cQry += " 		                  WHEN COUNT(CORRETOR) > 3 THEN 'PICADEIRA'  " + CRLF
    _cQry += " 						  ELSE STRING_AGG(  CORRETOR,' / ') WITHIN GROUP (ORDER BY CORRETOR ASC)  " + CRLF
    _cQry += " 						  END  " + CRLF
    _cQry += " 		             FROM (SELECT DISTINCT L.CORRETOR FROM LOTES L WHERE L.B8_LOTECTL = B8.B8_LOTECTL) X ) ,'')  CORRETOR " + CRLF
    _cQry += " 		, ISNULL(( SELECT CASE  " + CRLF
    _cQry += " 		                  WHEN COUNT(FORNECEDOR) > 4 THEN 'PICADEIRA'  " + CRLF
    _cQry += " 						  ELSE STRING_AGG(FORNECEDOR,' / ') WITHIN GROUP (ORDER BY FORNECEDOR ASC)  " + CRLF
    _cQry += " 						  END  " + CRLF
    _cQry += " 		             FROM (SELECT DISTINCT L.FORNECEDOR FROM LOTES L WHERE L.B8_LOTECTL = B8.B8_LOTECTL) X ) ,'')  FORNECEDOR " + CRLF
    _cQry += " 		, ISNULL((CASE WHEN (SELECT DISTINCT Z0F_LOTE FROM Z0F010 WHERE Z0F_LOTE = B8_LOTECTL AND D_E_L_E_T_ = ' ') <> ' '  THEN 'SIM'END ), 'NÃO ') PROCESSADO " + CRLF
    _cQry += "      FROM LOTES B8 " + CRLF
    _cQry += " 	 GROUP BY B8.B8_X_CURRA, B8.B8_LOTECTL " + CRLF
    _cQry += " 	) " + CRLF
    _cQry += " 	/*SELECT * FROM CORRETORES " + CRLF
    _cQry += " 	order by 1*/ " + CRLF
    _cQry += " 	 " + CRLF
    _cQry += "    SELECT L.B8_X_CURRA [CURRAL] " + CRLF
    _cQry += "         , SEQUEN SEQUENCIA " + CRLF
    _cQry += "         , L.B8_LOTECTL [LOTE] " + CRLF
    _cQry += " 		, SUM(B8_SALDO) [SALDO] " + CRLF
    _cQry += " 		, B8_XDATACO [DATAA] " + CRLF
    _cQry += " 		, B8_XPESOCO [PESO] " + CRLF
    _cQry += " 		,B1_X_SEXO [SEXO] " + CRLF
    _cQry += " 		, PROCESSADO [SITUACAO]--CASE WHEN COUNT(CORRETOR) > 5 THEN 'PICADEIRA' ELSE CORRETOR END CORRETOR, STRING_AGG(FORNECEDOR, ' / ')           " + CRLF
    _cQry += "         , C.CORRETOR, C.FORNECEDOR " + CRLF
    _cQry += "      FROM LOTES L " + CRLF
    _cQry += " 	 JOIN CORRETORES C ON L.B8_LOTECTL = C.B8_LOTECTL " + CRLF
    _cQry += " 	 GROUP BY L.B8_X_CURRA, L.B8_LOTECTL, B8_XDATACO, B1_X_SEXO, C.CORRETOR, PROCESSADO, B8_XPESOCO, C.FORNECEDOR, SEQUEN " + CRLF
    _cQry += " 	 ORDER BY SEQUEN DESC, L.B8_X_CURRA  DESC " + CRLF



EndIf

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

Return !(_cAlias)->(Eof())
// FIM: fLoadSql()




/*--------------------------------------------------------------------------------,
 | Principal: 			            U_PCPREL04()            		              |
 | Func:  PCPREL04()	            	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  09.09.2019	            	          	            	              |
 | Desc:  Gestão do Trato                                          	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1()

Local nRegistros	:= 0
Local cXML 			:= ""
Local cWorkSheet 	:= ""
Local nI            :=0 
// Controle Quebra/ABA
//Local s84Atual	:= ""//StoD("")
Local lCab   := .f.
Local cLote := ""
(_cAliasG)->(DbEval({|| nRegistros++ }))

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	cWorkSheet := "Geral"
	
	//fQuadro1
	While !(_cAliasG)->(Eof())
	
		If !lCab

			cXML += U_prtCellXML( 'Worksheet', /* cWorkSheet */ "Geral" )
			cXML += U_prtCellXML( 'Table' )
			
			/*
            cXML += '<Column ss:Width="54" ss:Span="2"/>'+CRLF
			cXML += '<Column ss:Index="4" ss:Width="104.25" ss:Span="2"/>'+CRLF
			cXML += '<Column ss:Index="7" ss:Width="54" ss:Span="4"/>'+CRLF
            */
            
   			cXML += '<Column ss:AutoFitWidth="0" ss:Width="38.25"/> ' + CRLF
   			cXML += '<Column ss:AutoFitWidth="0" ss:Width="44.25"/> ' + CRLF
   			cXML += '<Column ss:AutoFitWidth="0" ss:Width="47.25"/> ' + CRLF
   			cXML += '<Column ss:AutoFitWidth="0" ss:Width="60.75" /> ' + CRLF
   			cXML += '<Column ss:Width="32.25"/> ' + CRLF
   			cXML += '<Column ss:Width="39"/> ' + CRLF
   			cXML += '<Column ss:AutoFitWidth="0" ss:Width="39.75"/> ' + CRLF
   			cXML += '<Column ss:Width="42.75"/> ' + CRLF
   			cXML += '<Column ss:Width="147"/> ' + CRLF
   			cXML += '<Column ss:AutoFitWidth="0" ss:Width="315"/> ' + CRLF

			cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '9'/* cMergeAcross */, 's65'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo , /* cInfo */, /* cPanes */)

			cXML += U_prtCellXML( 'Row' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data ' ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, U_FrmtVlrExcel( DtoC( dDatabase ) ),,.T. ) // DATA
			cXML += U_prtCellXML( '</Row>' )
		
			cXML += U_prtCellXML( 'pulalinha','1' )

			// Titulo
			cXML += U_prtCellXML( 'Row',,'33' )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s81', 'String', /*cFormula*/, 'Curral'		    ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s81', 'String', /*cFormula*/, 'Lote'		    ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s81', 'String', /*cFormula*/, 'Cabeças'         ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s81', 'String', /*cFormula*/, 'Data Início'     ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s81', 'String', /*cFormula*/, 'Dias'            ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s81', 'String', /*cFormula*/, 'Peso'	        ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s81', 'String', /*cFormula*/, 'Sexo'	        ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s81', 'String', /*cFormula*/, 'Apartado'        ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s81', 'String', /*cFormula*/, 'Corretor'	    ,,.T. )
			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s81', 'String', /*cFormula*/, 'Fornecedor'      ,,.T. )
			cXML += U_prtCellXML( '</Row>' )
			
            lCab := .T. 
			cLote := (_cAliasG)->LOTE	
		EndIf
		If !cLote == (_cAliasG)->LOTE	
            cXML += U_prtCellXML( 'Row',,'33' )
				cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,'1'/*cMergeAcross*/,'s85'     , 'String', /*cFormula*/, 'Total Lote ' + cLote  ,,.T. )
				cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s86sComBorda'     , 'Number', /*cFormula*/ "=SUBTOTAL(9,R[-"+cValtoChar(nI)+"]C:R[-1]C)",)// FS
    			cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/'6', 'sComBorda' , 'String'  , /*cFormula*/''  ,,.T. )
			
			cXML += U_prtCellXML( '</Row>' )

			cXML += U_prtCellXML( 'pulalinha','1' )
			cLote := (_cAliasG)->LOTE	
			nI := 0
		EndIf 
		
		cXML += U_prtCellXML( 'Row' )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s85'    , 'String', /*cFormula*/,   U_FrmtVlrExcel( (_cAliasG)->CURRAL           ),,.T. ) // LOTE
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComBorda'    , 'String', /*cFormula*/,   U_FrmtVlrExcel( (_cAliasG)->LOTE             ),,.T. ) // CURRAL
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s83',    'Number', /*cFormula*/,   U_FrmtVlrExcel( (_cAliasG)->SALDO            ),,.T. ) // NRO CABEÇAS
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s84',    'DateTime', /*cFormula*/, U_FrmtVlrExcel( sToD((_cAliasG)->DATAA )     ),,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s83',    'Number', /*cFormula*/ "=DATEDIF(RC[-1],TODAY(),&quot;d&quot;)",)// FS
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComBorda',     'String', /*cFormula*/,   U_FrmtVlrExcel( (_cAliasG)->PESO             ),,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComBorda',     'String', /*cFormula*/,   U_FrmtVlrExcel( (_cAliasG)->SEXO             ),,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComBorda',     'String', /*cFormula*/,   U_FrmtVlrExcel( (_cAliasG)->SITUACAO         ),,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComBorda',     'String', /*cFormula*/,   U_FrmtVlrExcel( (_cAliasG)->CORRETOR         ),,.T. )
		cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComBorda',     'String', /*cFormula*/,   U_FrmtVlrExcel( (_cAliasG)->FORNECEDOR       ),,.T. )        
		cXML += U_prtCellXML( '</Row>' )
		nI ++
		(_cAliasG)->(DbSkip())
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
	
		If (_cAliasG)->(Eof()) 
			// cXML += U_prtCellXML( 'pulalinha','1' )
		
			// Final da Planilha
			cXML += '  </Table>' + CRLF
			cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
			cXML += '   <PageSetup>' + CRLF
			cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
			cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
			cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
			cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
			cXML += '   </PageSetup>' + CRLF
			cXML += '   <TabColorIndex>13</TabColorIndex>' + CRLF
			cXML += '   <Selected/>' + CRLF
			cXML += '   <Panes>' + CRLF
			cXML += '    <Pane>' + CRLF
			cXML += '     <Number>3</Number>' + CRLF
			cXML += '     <ActiveRow>17</ActiveRow>' + CRLF
			cXML += '     <ActiveCol>9</ActiveCol>' + CRLF
			cXML += '    </Pane>' + CRLF
			cXML += '   </Panes>' + CRLF
			cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
			cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
			cXML += '  </WorksheetOptions>' + CRLF
			cXML += ' </Worksheet>' + CRLF
		 
			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
			EndIf
			cXML := ""
		EndIf
	EndDo

	
EndIf	

Return nil
// FIM: fQuadro1



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
Local i         := 0 
Local j         := 0 

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

aAdd(aRegs,{cPerg, "01", "Data ?"        , "", "", "MV_CH1", "D", TamSX3("Z05_DATA")[1]  , TamSX3("Z05_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR01", ""   , "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
//aAdd(aRegs,{cPerg, "02", "Data Ate?"       , "", "", "MV_CH2", "D", TamSX3("Z0X_DATA")[1]  , TamSX3("Z0X_DATA")[2]  , 0, "G", "NaoVazio", "MV_PAR02", ""   , "","",""      							     ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
//aAdd(aRegs,{cPerg, "11", "Exibe Perguntas?", "", "", "MV_CHB", "N", 					     1,					      0, 2, "C", "NaoVazio", "MV_PAR11", "Não","","","","","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})

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
