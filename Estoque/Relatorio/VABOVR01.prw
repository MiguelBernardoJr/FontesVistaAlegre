#include "TOTVS.CH"
#include 'TOPCONN.CH'
#include "TBICONN.CH"
#include "TBICODE.CH"
#include "FILEIO.CH"


/*/{Protheus.doc} VABOVR01
Rotina responsável por listar o saldo diario de cada era.
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${nil}, ${Sem retorno}

@type function
/*/
user function VABOVR01()
// local aMovtosLote 	:= {}
// local aDias 		:= {}
// local aLinhasExcel 	:= {}
// local aLinha 		:= {}
// local lMostra 		:= .F.

Private dDataDe 	:= MsDate()-360
Private dDataAte 	:= MsDate()
Private aLotes 		:= {}
Private nPosCombo	:= 0 

if !callParam(.T.)
	return
endIf
	// Durante desenvolvimento, para nao precisar ficar selecionando .... apagar depoismbenrrado
	// aLotes := { { "101-12    ", "H01                 " }, { "124-44    ", "H02                 " }, { "154-12    ", "H09                 " }, { "19-19     ", "H14                 " }, { "21-20     ", "H12                 " }, { "47-20     ", "H11                 " }, { "56-20     ", "H13                 " } }
	
	//if (len(aLotes) > 0)
	//	PrintRel()
	//else
	//	msgInfo("Nenhum lote informado. Operação cancelada pelo usuário.")
	//EndIf
return

Static function callParam(lFirst)
	local obj
	local lConfirm 	  := .F.
	Local oCombo1     := nil
	// Local cCombo1     := "", aItems	  := {'Sim','Não'}
	Local oDlgWnd     := nil
	Local bDialogInit := nil	
	Local oBtnLtAtu   := nil
	Local oBtnLtFin   := nil
	default lFirst 	  := .F.
	
	if lFirst
		obj := TExFilter():New("SB8",{"B8_LOTECTL", "B8_X_CURRA"}, "Lotes", , .T.)
		aLotes := aClone(obj:aSelect)
	endIf

	DEFINE FONT oFont NAME "Courier New" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlgWnd TITLE OemToAnsi( "Informe os parametros" ) From 0,0 TO 200,800 OF GetWndDefault() STYLE DS_MODALFRAME STATUS  PIXEL
		
		tSay():New(037, 005,{||'Data De: ' },oDlgWnd,,oFont,,,,.T.,,,200,100)
		@ 035,045 MSGET oDataDe VAR dDataDe PICTURE "@D" VALID {|| dDataDe <= date() } SIZE 050,010 OF oDlgWnd PIXEL HASBUTTON
		tSay():New(037, 100,{||'Até: ' },oDlgWnd,,oFont,,,,.T.,,,200,100)
		@ 035,135 MSGET oDataAte VAR dDataAte PICTURE "@D" VALID {|| dDataAte <= date() .and. dDataAte >= dDataDe } SIZE 050,010 OF oDlgWnd PIXEL HASBUTTON
		
		/*tSay():New(037, 205,{||'Exibe ICMS: ' },oDlgWnd,,oFont,,,,.T.,,,200,100)
		cCombo1 := aItems[2]
		oCombo1 := TComboBox():New(33,250,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},;
											aItems,100,20,oDlgWnd,, /* {||Alert('Posição: ' + cValToChar(oCombo1:nAt))} ;
											,,,,.T.,,,,,,,,,'cCombo1')
		*/
		oBtnLtAtu  := TButton():New( 065, 005, "Lotes Atuais" 		, oDlgWnd, ;
						{|| aLotes := {} ,U_VABOVPESQ(1) },60,15,,,.F.,.T.,.F.,,.F.,,,.F.)
		
		oBtnLtFin  := TButton():New( 065, 130, "Lotes Finalizados" 		, oDlgWnd, ;
						{|| aLotes := {} ,U_VABOVPESQ(2)},60,15,,,.F.,.T.,.F.,,.F.,,,.F.)
		
		oDlgWnd:lEscClose := .F.
		bDialogInit := { || EnchoiceBar( oDlgWnd , ;
										{ || lConfirm := .T., oDlgWnd:End() } , ;
										{ || lConfirm := .F., oDlgWnd:End() } ) }
	ACTIVATE MSDIALOG oDlgWnd CENTERED ON INIT Eval( bDialogInit ) 
	
return lConfirm

User Function bovr01Print()

Local cTimeIni	 	:= Time()
Local lTemDados		:= .T.

Private cTitulo  	:= "Relatorio de Composicao de Lotes"

Private cPath 	 	:= "C:\TOTVS_RELATORIOS\"
Private cArquivo   	:= cPath + "composicao_lotes_"+; // __cUserID+ "_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()   
Private _cAliasI	:= ""
Private _cAliasR	:= ""

Private nHandle    	:= 0

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
	conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
else
	
	cStyle := U_defStyle()	// cStyle := defStyle()
	
	// Processar SQL
	FWMsgRun(, {|| lTemDados := GetSqlRel("Geral", @_cAliasG ) },'Por Favor Aguarde...' , 'Processando Banco de Dados')
	If lTemDados
		
		cXML := U_CabXMLExcel(cStyle) // cXML := CabXMLExcel(cStyle)

		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
			cXML := ""
		EndIf
		
		// Gerar primeira planilha
		FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Lotes Analitico')
		
		// Final - encerramento do arquivo
		FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )
		
		FClose(nHandle)

		//If ApOleClient("MSExcel") // U_VARELM01()
		//	oExcelApp := MsExcel():New()
		//	oExcelApp:WorkBooks:Open( cArquivo )
		//	oExcelApp:SetVisible(.T.)
		//	oExcelApp:Destroy()
		ShellExecute( "Open", cArquivo , '', '', 1 ) //Abre o arquivo na tela após salvar 
		//Else
		//	MsgAlert("O Excel não foi encontrado. Arquivo " + cArquivo + " gerado em " + cPath + ".", "MsExcel não encontrado" )
		//EndIf
		
	Else
		MsgAlert("Os parametros informados não retornou nenhuma informação do banco de dados." + CRLF + ;
				 "Por isso o excel não sera aberto automaticamente.", "Dados não localizados")
	EndIf

	(_cAliasG)->(DbCloseArea())

	If lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
		Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
	EndIf

	ConOut('Activate: ' + Time())
EndIf

Return nil

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM11()                                      |
 | Func:  VASqlM11()	                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  14.05.2018                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function GetSqlRel(cTipo, _cAlias, _cChave, _cPedido )
Local   _cQry 		:= ""
Default _cChave		:= ""

If cTipo=="Geral"
	_cQry := " WITH APARTACAO AS ( " +CRLF
	_cQry += "	  SELECT  DISTINCT Z0E_LOTE, Z0E_CURRAL" +CRLF
	_cQry += "	    			 , ISNULL(ZBC_PEDIDO,' ') ZBC_PEDIDO" +CRLF
	_cQry += "	    			 , Z0E_PROD, ISNULL(A2_NOME,' ') A2_NOME, ISNULL(ZBC_CODIGO,' ') ZBC_CODIGO" +CRLF
	_cQry += "	          	     , ISNULL(ZCC_NOMCOR,' ') ZCC_NOMCOR, ISNULL(Z0C_DTCRIA,' ') Z0C_DTCRIA" +CRLF
	_cQry += "	          	     , Z0E_QUANT, Z0E_PESTOT*Z0E_QUANT Z0E_PESTOT, Z0E_PESTOT Z0E_PESMED, ISNULL(Z0E_QUANT*ZBC_PRECO,0) VALOR_GADO" +CRLF
	_cQry += "	          	     , ISNULL(Z0E_QUANT*ZBC_VLICM,0) ZBC_VLICM, ZBC_QUANT" +CRLF
	_cQry += "	          	     , Z0F_DTPES --, Z0F_HRPES" +CRLF
	_cQry += CRLF
	_cQry += "	    FROM "+retSQLName("Z0E")+" Z0E " +CRLF
	_cQry += "	    JOIN Z0F010 F ON Z0E_FILIAL=Z0F_FILIAL " +CRLF
	_cQry += "	        			 AND Z0E_CODIGO=Z0F_MOVTO " +CRLF
	_cQry += "	        			 -- AND Z0E_PROD=Z0F_PROD" +CRLF
	_cQry += "	        			 -- AND Z0E_SEQ=Z0F_SEQEFE" +CRLF
	_cQry += "	        			 AND Z0E_LOTE=Z0F_LOTE" +CRLF
	_cQry += "	        			 AND Z0E.D_E_L_E_T_=' ' AND F.D_E_L_E_T_=' '" +CRLF
	_cQry += "	    JOIN "+retSQLName("Z0C")+" Z0C on (Z0C_FILIAL=Z0E_FILIAL and Z0C.D_E_L_E_T_=' ' and Z0C_CODIGO=Z0E_CODIGO and Z0C_TPMOV='2' AND Z0C_STATUS>='2') " +CRLF
	_cQry += "	    LEFT JOIN "+retSQLName("ZBC")+" ZBC on (ZBC.ZBC_FILIAL='"+xFilial("ZBC")+"' and ZBC.D_E_L_E_T_=' ' and ZBC_PRODUT=Z0E_PRDORI and ZBC_VERSAO=(select max(ZBC_VERSAO) from "+retSQLName("ZBC")+" Z2 where Z2.ZBC_FILIAL=ZBC.ZBC_FILIAL and Z2.ZBC_CODIGO=ZBC.ZBC_CODIGO and Z2.D_E_L_E_T_=' ')) " +CRLF
	_cQry += "	    LEFT JOIN ZCC010 ZCC on ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO AND ZCC_VERSAO=ZBC_VERSAO AND ZCC.D_E_L_E_T_=' '" +CRLF
	_cQry += "	    LEFT JOIN "+retSQLName("SA2")+" SA2 on (SA2.A2_FILIAL='"+xFilial("SA2")+"' and SA2.D_E_L_E_T_=' ' and A2_COD=ZBC_CODFOR and A2_LOJA=ZBC_LOJFOR) " +CRLF
	_cQry += CRLF
	_cQry += "	   WHERE Z0E_FILIAL='"+xFilial("Z0E")+"' " +CRLF
	_cQry += filtroQry("Z0E", "Z0E_LOTE", aLotes) + CRLF
	_cQry += "	 	AND Z0C_DTCRIA between '"+dToS(dDataDe)+"' and '"+dToS(dDataAte)+"' " +CRLF
	_cQry += " ) " +CRLF
	_cQry += CRLF
	_cQry += " , FRETE AS ( " +CRLF
	_cQry += " 		SELECT D1_COD, sum(D1_VALICM) D1_VALICM, sum(D1_TOTAL) D1_TOTAL " +CRLF
	_cQry += " 		  FROM "+retSQLName("SD1")+" SD1 " +CRLF
	_cQry += " 		  JOIN "+retSQLName("SF1")+" SF1 ON F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE AND F1_LOJA=D1_LOJA AND SF1.D_E_L_E_T_=' ' " +CRLF
	_cQry += " 		  JOIN APARTACAO A on (Z0E_PROD=D1_COD) " +CRLF
	_cQry += " 		 WHERE D1_FILIAL='"+xFilial("SD1")+"' and SD1.D_E_L_E_T_=' ' " +CRLF
	_cQry += " 		   AND F1_TIPO = 'C' " +CRLF
	_cQry += " 		   AND F1_TPCOMPL='3' " +CRLF
	_cQry += " 		   AND D1_QUANT = 0 " +CRLF
	_cQry += " 		 GROUP by D1_COD " +CRLF
	_cQry += " )  " +CRLF
	_cQry += CRLF
  	_cQry += " SELECT Z0E_LOTE, Z0E_CURRAL, ZBC_PEDIDO" +CRLF
	_cQry += "      , Z0C_DTCRIA, ZBC_CODIGO, ZCC_NOMCOR, A2_NOME" +CRLF
	_cQry += "      , SUM(Z0E_QUANT) Z0E_QUANT" +CRLF
	_cQry += "      , SUM(Z0E_PESTOT) Z0E_PESTOT" +CRLF
	_cQry += "      , AVG(Z0E_PESMED) Z0E_PESMED" +CRLF
	_cQry += "      , SUM(VALOR_GADO) VALOR_GADO" +CRLF
	_cQry += "      , SUM(ZBC_VLICM) ZBC_VLICM" +CRLF
	_cQry += "      , ISNULL(SUM(D1_VALICM/ZBC_QUANT)*SUM(Z0E_QUANT), 0) ICM_FRETE " +CRLF
	_cQry += "      , Z0F_DTPES --, Z0F_HRPES" +CRLF
	_cQry += CRLF
	_cQry += " FROM APARTACAO A " +CRLF
	_cQry += " LEFT JOIN FRETE F on (D1_COD=Z0E_PROD) " +CRLF
	_cQry += CRLF
	_cQry += " GROUP BY Z0C_DTCRIA, Z0E_LOTE, Z0E_CURRAL, A2_NOME, ZBC_CODIGO, ZBC_PEDIDO, ZCC_NOMCOR " +CRLF
	_cQry += "		  , Z0F_DTPES --, Z0F_HRPES" +CRLF
	_cQry += CRLF
	_cQry += " ORDER BY Z0E_LOTE, Z0E_CURRAL, ZBC_PEDIDO -- , Z0C_DTCRIA, ZBC_CODIGO "

ElseIf cTipo=="Itens"

	_cQry := " SELECT Z0F_LOTE, Z0F_CURRAL, ISNULL(ZBC_PEDIDO, ' ') ZBC_PEDIDO, Z0F_DTPES, ISNULL(ZCC_NOMFOR, ' ') ZCC_NOMFOR, Z0F_PROD, " +CRLF
 	_cQry += "        Z0F_SEQ, Z0F_PESO, Z0F_RACA, Z0F_HRPES, Z0F_LOTORI, Z0F_DENTIC, Z0F_TAG " +CRLF
	_cQry += " FROM Z0F010 Z0F " +CRLF
	_cQry += " LEFT JOIN ZBC010 ZBC ON ZBC_FILIAL = Z0F_FILIAL AND ( ZBC_PRODUT = Z0F_PROD OR Z0F_PRDORI = ZBC_PRODUT) AND ZBC.D_E_L_E_T_ = ' ' " +CRLF
	_cQry += " LEFT JOIN ZCC010 ZCC ON ZBC_FILIAL+ZBC_CODIGO = ZCC_FILIAL+ZCC_CODIGO AND ZCC.D_E_L_E_T_ = ' ' " +CRLF
	_cQry += " WHERE " +CRLF
	_cQry += "--" + filtroQry("Z0F", "Z0F_LOTE", aLotes, .F.) + CRLF // Z0F_LOTE = '67-15' 
	_cQry += "     RTRIM(Z0F_LOTE) = '"+_cChave+"'" +CRLF
	_cQry += " AND Z0F_DTPES BETWEEN '"+dToS(dDataDe)+"' and '"+dToS(dDataAte)+"' " +CRLF
	_cQry += " AND Z0F.D_E_L_E_T_ = ' ' " +CRLF
	_cQry += " ORDER BY Z0F_LOTE, Z0F_CURRAL, Z0F_DTPES, ZBC_PEDIDO, Z0F_PROD, Z0F_SEQ"

ElseIf cTipo=="Resumo"
	
	_cQry := " SELECT DISTINCT Z0F_LOTE, " +CRLF
    _cQry += "       AVG(Z0F_PESO) Z0F_PESO, Z0F_DENTIC," +CRLF
	_cQry += "       CASE WHEN Z0F_DENTIC = 0 THEN COUNT(Z0F_DENTIC) --ELSE 0 END AS ZERO," +CRLF
	_cQry += "	          WHEN Z0F_DENTIC = 2 THEN COUNT(Z0F_DENTIC) --ELSE 0 END AS DOIS" +CRLF
	_cQry += "	          WHEN Z0F_DENTIC = 4 THEN COUNT(Z0F_DENTIC)" +CRLF
	_cQry += "            WHEN Z0F_DENTIC = 6 THEN COUNT(Z0F_DENTIC) END QTD_ANI" +CRLF
    _cQry += "    FROM Z0F010 Z0F " +CRLF
	_cQry += "   WHERE Z0F_FILIAL = '"+xFilial("Z0F") +"' " +CRLF
	_cQry += "     AND Z0F_LOTE = '"+_cChave+"' " +CRLF
    _cQry += "GROUP BY Z0F_LOTE, Z0F_DENTIC" 
	
EndIf


If lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

Return !(_cAlias)->(Eof())


Static function filtroQry(cTbl, cCampo, aItens, lComAnd)
Default lComAnd := .T.

	cTxt := " "
	cInObj := U_deAToC(aItens)
	if !empty(cInObj)
		If lComAnd
			cTxt += " and "
		EndIf
		cTxt += cTbl+"."+cCampo+" in ("+cInObj+") "+CRLF
	endIf
return cTxt

User function deAToC(pArray)
    local nI     :=0
	local cInObj := ""
	for nI := 1 to len(pArray)
		if nI == 1
			cInObj := "'"+pArray[nI,1]+"'"
		else
			cInObj += ",'"+pArray[nI,1]+"'"
		endIf
	next
return cInObj

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM11()                                      |
 | Func:  fQuadro1()	                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  14.05.2018                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1()

Local cXML 			:= ""
Local cWorkSheet 	:= "Lote"
Local nLin			:= 0
Local cAux		  	:= ""
Local cLote			:= ""
Local aLotes		:= {}, aPedLotes := {}
Local cProduto		:= ""
Local nI			:= 0 
Local _cLotes		:= ""
Local nJ            := 0
Local nTotComp 		:= 0 // Total Composição
Local nTotSequ		:= 0 // Total Sequencia

Local lTemDados		:= .T., lAux := .T.
Local nContIntem	:= 0

(_cAliasG)->(DbGoTop()) 
If !(_cAliasG)->(Eof())

	While !(_cAliasG)->(Eof())
		nPos := aScan(aLotes, {|x| x[1]=(_cAliasG)->Z0E_LOTE /* .and. x[2]=(_cAliasG)->Z0E_CURRAL .and. x[7]=(_cAliasG)->Z0C_DTCRIA */})
		if nPos = 0
			aAdd(aLotes, { (_cAliasG)->Z0E_LOTE,  ;
						   (_cAliasG)->Z0E_CURRAL, ;
						   (_cAliasG)->Z0E_QUANT, ;
						   (_cAliasG)->Z0E_PESMED, ;
						   ( (_cAliasG)->Z0E_PESMED / U_getUA( (_cAliasG)->Z0E_CURRAL) ) * (_cAliasG)->Z0E_QUANT, ;
						   (_cAliasG)->Z0E_PESTOT, ;
						   (_cAliasG)->Z0C_DTCRIA } )
		else
			aLotes[nPos, 3] += (_cAliasG)->Z0E_QUANT
			aLotes[nPos, 6] += (_cAliasG)->Z0E_PESTOT
			aLotes[nPos, 4] := aLotes[nPos, 6]/aLotes[nPos, 3]
			aLotes[nPos, 5] := ( aLotes[nPos, 4]/ U_getUA(aLotes[nPos, 2]) ) * aLotes[nPos, 3]
		endIf
		(_cAliasG)->(DbSkip())
	endDo
	(_cAliasG)->(DbGoTop()) 
	
	(_cAliasG)->(DbEval({|| nLin++ }))
	(_cAliasG)->(DbGoTop()) 

	For nI:=1 to Len(aLotes)

		cLote := (_cAliasG)->Z0E_LOTE // +(_cAliasG)->Z0E_CURRAL+(_cAliasG)->Z0C_DTCRIA
		nPos  := aScan(aLotes, {|x| x[1]=(_cAliasG)->Z0E_LOTE/*  .and. x[2]=(_cAliasG)->Z0E_CURRAL .and. x[7]=(_cAliasG)->Z0C_DTCRIA */} )
		
		lImp	   := .T.
		lPrint 	   := .T.
/* 		cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet+' '+AllTrim(aLotes[nPos, 1]))+ '">' + CRLF
		cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
		cXML += '   <Column ss:AutoFitWidth="0" ss:Width="69" ss:Span="2"/>' + CRLF
		cXML += '   <Column ss:Index="4" ss:Width="76"/>' + CRLF
		cXML += '   <Column ss:Width="66"/>' + CRLF
		cXML += '   <Column ss:Width="76"/>' + CRLF
		cXML += '   <Column ss:Width="76"/>' + CRLF
		cXML += '   <Column ss:Width="54"/>' + CRLF
		cXML += '   <Column ss:Width="66"/>' + CRLF
		cXML += '   <Column ss:Width="49"/>' + CRLF
		cXML += '   <Column ss:Width="58"/>' + CRLF
		cXML += '   <Column ss:Width="53"/>' + CRLF
		cXML += '   <Column ss:Width="49"/>' + CRLF
		cXML += '   <Column ss:Width="58"/>' + CRLF
		cXML += '   <Column ss:Width="58" ss:Span="3"/>' + CRLF
		cXML += '   <Column ss:Index="19" ss:Hidden="1" ss:AutoFitWidth="0"/>' + CRLF */

		cXML := ' <Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet+' '+AllTrim(aLotes[nPos, 1]))+ '">' + CRLF
		cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
		cXML += ' <Column ss:AutoFitWidth="0" ss:Width="69" ss:Span="1"/>' + CRLF
		cXML += ' <Column ss:Index="3" ss:AutoFitWidth="0" ss:Width="102.75"/>' + CRLF
		cXML += ' <Column ss:AutoFitWidth="0" ss:Width="76.5"/>' + CRLF
		cXML += ' <Column ss:Width="67"/>' + CRLF
		cXML += ' <Column ss:Width="77" ss:Span="1"/>' + CRLF
		cXML += ' <Column ss:Index="8" ss:AutoFitWidth="0" ss:Width="87"/>' + CRLF
		cXML += ' <Column ss:Width="67"/>' + CRLF
		cXML += ' <Column ss:Width="52"/>' + CRLF
		cXML += ' <Column ss:Width="59"/>' + CRLF
		cXML += ' <Column ss:AutoFitWidth="0" ss:Width="85.5"/>' + CRLF
		cXML += ' <Column ss:Width="49"/>' + CRLF
		cXML += ' <Column ss:Width="58"/>' + CRLF
		cXML += ' <Column ss:Width="59"/>' + CRLF
		cXML += ' <Column ss:Width="58" ss:Span="2"/>' + CRLF
		cXML += ' <Column ss:Index="19" ss:Hidden="1" ss:AutoFitWidth="0"/>' + CRLF

		aPedLotes := {}
		cLote := ""
		// (_cAliasG)->(DbEval({|| nLin++ }))
		// (_cAliasG)->(DbGoTop())
		
		While !(_cAliasG)->(Eof())
	
			if cLote != (_cAliasG)->Z0E_LOTE// +(_cAliasG)->Z0E_CURRAL+(_cAliasG)->Z0C_DTCRIA
				
				if cLote != ""
					Exit
					// cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF // PULAR LINHA
					// cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF // PULAR LINHA
				EndIf

				cLote := (_cAliasG)->Z0E_LOTE // +(_cAliasG)->Z0E_CURRAL+(_cAliasG)->Z0C_DTCRIA
				nPos  := aScan(aLotes, {|x| x[1]=(_cAliasG)->Z0E_LOTE /* .and. x[2]=(_cAliasG)->Z0E_CURRAL .and. x[7]=(_cAliasG)->Z0C_DTCRIA */} )

				// cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF // PULAR LINHA
				cXML += '<Row ss:AutoFitHeight="0">' + CRLF
				cXML += '	<Cell ss:MergeAcross="5" ss:StyleID="s65"><Data ss:Type="String">LOTE '+aLotes[nPos, 1]+'</Data></Cell>
				cXML += '</Row>' + CRLF

				cXML += '<Row ss:AutoFitHeight="0" ss:Height="36">' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">BAIA</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">CURRAL</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">DATA</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">QTDE ANIMAIS</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">PESO MEDIO</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">QTDE UA</Data></Cell>' + CRLF
				cXML += '</Row>' + CRLF

				cXML += '<Row>' + CRLF
				cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( aLotes[nPos, 1] ) + '</Data></Cell>' + CRLF	
				cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( aLotes[nPos, 2] ) + '</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sToD(aLotes[nPos, 7]) ) + '</Data></Cell>' + CRLF

				cXML += '  <Cell ss:StyleID="sSemDig" ss:Formula="=SUMIF(R[4]C[15]:R['+cValToChar(4+nLin-1)+']C[15],RC[-3],R[4]C[3]:R['+cValToChar(4+nLin-1)+']C[3])"><Data ss:Type="Number"></Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="sComDig" ss:Formula="=SUMIF(R[4]C[14]:R['+cValToChar(4+nLin-1)+']C[14],RC[-4],R[4]C[3]:R['+cValToChar(4+nLin-1)+']C[3])/SUMIF(R[4]C[14]:R['+cValToChar(4+nLin-1)+']C[14],RC[-4],R[4]C[2]:R['+cValToChar(4+nLin-1)+']C[2])"><Data ss:Type="Number"></Data></Cell>' + CRLF

				cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( aLotes[nPos, 5] ) + '</Data></Cell>' + CRLF
				cXML += '</Row>' + CRLF
 
				cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF // PULAR LINHA

				cXML += '<Row ss:AutoFitHeight="0">' + CRLF
				cXML += '	<Cell ss:MergeAcross="'+Iif(nPosCombo==1,'15','8')+'" ss:StyleID="s65"><Data ss:Type="String">Composição</Data></Cell>' + CRLF
				cXML += '</Row>' + CRLF

				cXML += '<Row ss:AutoFitHeight="0" ss:Height="36">' + CRLF
				// cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Lote Origem</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65" ss:MergeAcross="2"><Data ss:Type="String">FORNECEDOR</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">CONTRATO</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">PEDIDO</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">CORRETOR</Data></Cell>' + CRLF		
				
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">QTDE ANIMAIS</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">PESO TOTAL</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">PESO MEDIO</Data></Cell>' + CRLF

				If nPosCombo==1
					cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">VALOR GADO</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">VALOR ICMS</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">VALOR ICMS FRETE</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">VALOR TOTAL</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">VALOR POR CABEÇA</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">VALOR POR KG</Data></Cell>' + CRLF
				EndIf
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Pesagem</Data></Cell>' + CRLF
				// cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Hr. Pesagem</Data></Cell>' + CRLF
				cXML += '</Row>' + CRLF
				
			endIf

			nValTot := (_cAliasG)->VALOR_GADO+(_cAliasG)->ZBC_VLICM+(_cAliasG)->ICM_FRETE

			nTotComp += 1
			cXML += '<Row>' + CRLF
			// cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->Z0F_LOTORI ) + '</Data></Cell>' + CRLF	
			cXML += '  <Cell ss:StyleID="sTexto" ss:MergeAcross="2"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->A2_NOME ) + '</Data></Cell>' + CRLF	
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->ZBC_CODIGO ) + '</Data></Cell>' + CRLF	
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->ZBC_PEDIDO ) + '</Data></Cell>' + CRLF	
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->ZCC_NOMCOR ) + '</Data></Cell>' + CRLF	
			cXML += '  <Cell ss:StyleID="sSemDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->Z0E_QUANT ) + '</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->Z0E_PESTOT ) + '</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->Z0E_PESMED ) + '</Data></Cell>' + CRLF

			If nPosCombo==1
				cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->VALOR_GADO ) + '</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->ZBC_VLICM ) + '</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->ICM_FRETE ) + '</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( nValTot ) + '</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( nValTot/(_cAliasG)->Z0E_QUANT ) + '</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( nValTot/(_cAliasG)->Z0E_PESTOT ) + '</Data></Cell>' + CRLF
			EndIf
			cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sToD( (_cAliasG)->Z0F_DTPES ) ) + '</Data></Cell>' + CRLF
			// cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( SubS( (_cAliasG)->Z0F_HRPES,1,5 ) ) ) + '</Data></Cell>' + CRLF
			cXML += '  <Cell ss:Index="19" ss:StyleID="sTextoSC"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasG)->Z0E_LOTE ) + '</Data></Cell>' + CRLF
			cXML += '</Row>' + CRLF
			
			__cLote   := AllTrim( (_cAliasG)->Z0E_LOTE   )
			__cPedido := AllTrim( (_cAliasG)->ZBC_PEDIDO )
			
			(_cAliasG)->(DbSkip())

			if aScan( aPedLotes, { |x| x[1] == __cLote .and. x[2] == __cPedido } ) == 0
				aAdd( aPedLotes, { __cLote, __cPedido } )
			EndIf
			
		EndDo
		
		cXML += '<Row ss:AutoFitHeight="0">' + CRLF
		cXML += '	<Cell ss:Index="7" ss:StyleID="sSemDig" ss:Formula="=SUM(R[-'+cValToChar(nTotComp)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
		cXML += '</Row>' + CRLF
		nTotComp := 0
		

		nContIntem := 0
		lAux 	   := .T.
		
		
		/* QUadro de Dentição */
		_cAliasR	:= GetNextAlias()
		FWMsgRun(, {|| Sleep(300),;
					lTemDados := GetSqlRel("Resumo", @_cAliasR, __cLote ) },;
											'Por Favor Aguarde...',;
											'Processando Banco de Dados: ['+StrZero( nContIntem+=1, 6)+']')
		If lTemDados .and. lImp
			cXML += '<Row ss:AutoFitHeight="0">' + CRLF
			cXML += '  <Cell ss:StyleID="s65" ss:MergeAcross="2"><Data ss:Type="String">Composição - Dentição do Lote</Data></Cell>' + CRLF
			cXML += '</Row>' + CRLF

			cXML += '<Row ss:AutoFitHeight="0">' + CRLF
				//cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Lote</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Peso</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Denticao</Data></Cell>' + CRLF
				cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Qtde de Animais</Data></Cell>' + CRLF
			cXML += '</Row>' + CRLF

			While !(_cAliasR)->(Eof())					
				cXML += '<Row ss:AutoFitHeight="0">' + CRLF
					//cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasR)->Z0F_LOTE )  + '</Data></Cell>' + CRLF	
					cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasR)->Z0F_PESO ) + '</Data></Cell>' + CRLF
					cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasR)->Z0F_DENTIC ) + '</Data></Cell>' + CRLF	
					cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasR)->QTD_ANI ) + '</Data></Cell>' + CRLF	
				cXML += '</Row>' + CRLF
				
				If !Empty(cXML)
					FWrite(nHandle, EncodeUTF8( cXML ) )
				EndIf
				cXML := ""	
			(_cAliasR)->(DbSkip())					
			EndDo
			lImp := .F.
			(_cAliasR)->(DbCloseArea())
		EndIf 	

		cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF
		
/* 		For nJ := 1 to Len(aPedLotes)  
	 	If !Empty( _cChave := aPedLotes[nJ,1] + aPedLotes[nJ,2] ) */
				/* 
				11/05/2020 - Arthur Toshio
				inclusÃ£o de resumo por dentiÃ§Ã£o do lote
				*/

				/*QUADRO DE RESUMO*/
			
				_cAliasI	:= GetNextAlias()
				FWMsgRun(, {|| Sleep(300),;
							   lTemDados := GetSqlRel("Itens", @_cAliasI, __cLote ) },;
													'Por Favor Aguarde...',;
													'Processando Banco de Dados: ['+StrZero( nContIntem+=1, 6)+']')
				If lTemDados
					
					if lPrint == .T.
						cXML += '<Row ss:AutoFitHeight="0">' + CRLF
						cXML += '  <Cell ss:StyleID="s65" ss:MergeAcross="1"><Data ss:Type="String">Código</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">PEDIDO</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s65" ss:MergeAcross="1"><Data ss:Type="String">FORNECEDOR</Data></Cell>' + CRLF
					/*  lAux
							lAux := .F.
							cXML += '  <Cell ss:Index="14" ss:StyleID="sSemDig" ss:Formula="=SUM(R[1]C:R[2000]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
						EndIf */
						cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Sequencia</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Peso</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Raca</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Lote Origem</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Dt. Peso</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Hr. Peso</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Num. Brinco</Data></Cell>' + CRLF
						cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Denticao</Data></Cell>' + CRLF
						cXML += '</Row>' + CRLF
						lPrint := .F.
					EndIf
					cProduto := ""
					While !(_cAliasI)->(Eof())
						// imprimir cabeçalho produto e pedido
						
						 if cProduto <> (_cAliasI)->Z0F_PROD
							cProduto := (_cAliasI)->Z0F_PROD
							If nTotSequ > 0
								If nTotSequ == 1
									cXML += '<Row ss:AutoFitHeight="0">' + CRLF
									cXML += '<Cell ss:Index="14" ss:StyleID="s65" ss:Formula="=COUNTA(R[-1]C[-6])"><Data ss:Type="Number"></Data></Cell>' + CRLF
									cXML += '</Row>' + CRLF
								Else
									cXML += '<Row ss:AutoFitHeight="0">' + CRLF
									cXML += ' <Cell ss:Index="14" ss:StyleID="s65" ss:Formula="=COUNTA(R[-'+cValToChar(nTotSequ)+']C[-6]:R[-1]C[-6])"><Data ss:Type="Number"></Data></Cell>' + CRLF
									cXML += '</Row>' + CRLF
								EndIf
								nTotSequ := 0
							EndIf
					 	 EndIf

							cXML += '<Row ss:AutoFitHeight="0">' + CRLF
							cXML += '  <Cell ss:StyleID="sTexto" ss:MergeAcross="1"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasI)->Z0F_PROD ) + '</Data></Cell>' + CRLF	
							cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasI)->ZBC_PEDIDO ) + '</Data></Cell>' + CRLF	
							cXML += '  <Cell ss:StyleID="sTexto" ss:MergeAcross="1"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasI)->ZCC_NOMFOR ) + '</Data></Cell>' + CRLF	
							cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasI)->Z0F_SEQ )  + '</Data></Cell>' + CRLF	
							cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasI)->Z0F_PESO ) + '</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasI)->Z0F_RACA ) + '</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasI)->Z0F_LOTORI ) + '</Data></Cell>' + CRLF	
							cXML += '  <Cell ss:StyleID="sData"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( sToD( (_cAliasI)->Z0F_DTPES) ) + '</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="sHoraCurta"><Data ss:Type="DateTime">' + U_FrmtVlrExcel( U_HoraToExcel( (_cAliasI)->Z0F_HRPES),,.F. ) + '</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasI)->Z0F_TAG ) + '</Data></Cell>' + CRLF
							cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( (_cAliasI)->Z0F_DENTIC ) + '</Data></Cell>' + CRLF
							cXML += '</Row>' + CRLF
					
						nTotSequ += 1

						If !Empty(cXML)
							FWrite(nHandle, EncodeUTF8( cXML ) )
						EndIf
						cXML := ""	
						(_cAliasI)->(DbSkip())
					EndDo
					
					If nTotSequ == 1
						cXML += '<Row ss:AutoFitHeight="0">' + CRLF					
						cXML += '<Cell ss:Index="14" ss:StyleID="s65" ss:Formula="=COUNTA(R[-1]C[-6])"><Data ss:Type="Number"></Data></Cell>' + CRLF
						cXML += '</Row>' + CRLF
					Else
						cXML += '<Row ss:AutoFitHeight="0">' + CRLF
						cXML += ' <Cell ss:Index="14" ss:StyleID="s65" ss:Formula="=COUNTA(R[-'+cValToChar(nTotSequ)+']C[-6]:R[-1]C[-6])"><Data ss:Type="Number"></Data></Cell>' + CRLF
						cXML += '</Row>' + CRLF
					EndIf	
						nTotSequ := 0
					(_cAliasI)->(DbCloseArea())
				EndIf
			
/* 			 endif 
		Next nJ */
		aPedLotes := {}
	
		cXML += '  </Table>' + CRLF		
		cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">		' + CRLF
		cXML += ' <PageSetup>' + CRLF
		cXML += ' 	<Header x:Margin="0.31496062000000002"/>' + CRLF
		cXML += ' 	<Footer x:Margin="0.31496062000000002"/>' + CRLF
		cXML += ' 	<PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
		cXML += ' 	x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
		cXML += ' </PageSetup>' + CRLF
		cXML += ' <Unsynced/>' + CRLF
		cXML += ' <TabColorIndex>13</TabColorIndex>' + CRLF
		cXML += ' <Selected/>' + CRLF
		cXML += ' <TopRowVisible>21</TopRowVisible>' + CRLF
		cXML += ' <Panes>' + CRLF
		cXML += ' 	<Pane>' + CRLF
		cXML += ' 	<Number>3</Number>' + CRLF
		cXML += ' 	<ActiveRow>23</ActiveRow>' + CRLF
		cXML += ' 	<ActiveCol>3</ActiveCol>' + CRLF
		cXML += ' 	</Pane>' + CRLF
		cXML += ' </Panes>' + CRLF
		cXML += ' <ProtectObjects>False</ProtectObjects>' + CRLF
		cXML += ' <ProtectScenarios>False</ProtectScenarios>' + CRLF
		cXML += ' </WorksheetOptions>' + CRLF
		cXML += ' </Worksheet>' + CRLF

		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""
	
	Next nI
	
EndIf	

Return nil
// fQuadro1

/*/{Protheus.doc} GetParams
Gera a tela de parametros da rotina.
@author renat
@since 17/05/2018
@version 1.0
@return ${aParams}, ${Vetor com os valores de cada parametro}

@type function
/*/
User function GetParams()
local nI := 0
local aParams := {}
local cPerg := "BOVR01"
local aPerguntas := {}

cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))

/*Formato peguntas: TEXTO, TIPO, TAMANHO, DECIMAL, F3, OPCOES (OPCIONAL)*/
aAdd(aPerguntas, {'Data de?    '			, 'D', TamSX3("D3_EMISSAO")[1] , TamSX3("D3_EMISSAO")[2] , '', {}})
aAdd(aPerguntas, {'Data ate?   '			, 'D', TamSX3("D3_EMISSAO")[1] , TamSX3("D3_EMISSAO")[2] , '', {}})
aAdd(aPerguntas, {'Lote de?   '				, 'C', TamSX3("B8_LOTECTL")[1], TamSX3("B8_LOTECTL")[2], 'SB8MFJ', {}})
aAdd(aPerguntas, {'Lote Ate?   '			, 'C', TamSX3("B8_LOTECTL")[1], TamSX3("B8_LOTECTL")[2], 'SB8MFJ  ', {}})
aAdd(aPerguntas, {'Nome do Arquivo Excel?'	, 'C', 20 					  , 0					   , '   ', {}}) // aAdd(aPerguntas, {'Tipo de Saldo?', 'N', 1, 0, '   ', {'Por Trato', 'CalcEst'} })

GeraSX1(cPerg, aPerguntas)

	if Pergunte(cPerg,.T.)
		for nI := 1 to len(aPerguntas)
			aAdd(aParams, &("mv_par"+StrZero(nI, 2)))
		next
	endIf

return aParams

/*/{Protheus.doc} GeraSX1
Função que gera os parametros na tabela SX1.
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cPerg, characters, Indice da pergunta
@param aPerguntas, array, Vetor com as perguntas no formato: TEXTO, TIPO, TAMANHO, DECIMAL, F3, OPCOES (OPCIONAL)
@type function
/*/
Static Function GeraSX1(cPerg, aPerguntas)
	Local aArea 	:= GetArea()
	Local i	  		:= 0
	Local j     	:= 0
	Local nI        := 0
	Local lInclui	:= .F.
	Local cTexto    := ''
	
	aRegs := {}
	for nI := 1 to len(aPerguntas)
		aAdd(aRegs,{cPerg, StrZero(nI, 2), aPerguntas[nI, 1],"","","mv_ch"+cValToChar(nI), aPerguntas[nI, 2], aPerguntas[nI, 3], aPerguntas[nI, 4],0,iif(len(aPerguntas[nI, 6]) > 0,"C","G"),"","mv_par"+StrZero(nI, 2),iif(len(aPerguntas[nI, 6]) > 0,aPerguntas[nI, 6, 1],""),"","","","",iif(len(aPerguntas[nI, 6]) > 1,aPerguntas[nI, 6, 2],""),"","","","",iif(len(aPerguntas[nI, 6]) > 2,aPerguntas[nI, 6, 3],""),"","","","",iif(len(aPerguntas[nI, 6]) > 3,aPerguntas[nI, 6, 4],""),"","","","",iif(len(aPerguntas[nI, 6]) > 4,aPerguntas[nI, 6, 5],""),"","","", aPerguntas[nI, 5],"N","","",""})
	next
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 To Len(aRegs)
	 If lInclui := !dbSeek(cPerg + aRegs[i,2])
		 RecLock("SX1", lInclui)
		  For j := 1 to FCount()
		   If j <= Len(aRegs[i])
		    FieldPut(j,aRegs[i,j])
		   Endif
		  Next
		 MsUnlock()
		EndIf
	Next
	
	RestArea(aArea)
Return('SX1: ' + cTexto  + CHR(13) + CHR(10))



/*/{Protheus.doc} Excel
Função responsavel por gerar um excel a partir de um vetor
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${nil}, ${sem retorno}
@param cArquivo, characters, Nome do arquivo
@param aLinhasExcel, array, Vetor com as linhas do Excel
@type function
/*/
static function Excel(cArquivo, aLinhasExcel)
	cDiretorio	:= space(100)
	
	cDiretorio  := cGetFile(, 'Escolha o local do arquivo', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
	if right(cDiretorio,1)!='/' .and. right(cDiretorio,1)!='\'
		cDiretorio += "\"
	endIf
	
	if !empty(cArquivo)
		aCabec := {}
		aItens := aClone(aLinhasExcel)
		
		cArqGer := geraExcel( .F., aItens, aCabec, cDiretorio, cArquivo )
		CpyS2T(GetSrvProfString ("STARTPATH","")+cArqGer, Alltrim(cDiretorio))
		If (CpyS2T(GetSrvProfString ("STARTPATH","")+cArqGer, Alltrim(GetTempPath())))
			fErase(cArqGer)
			// Abre excell
			If !ApOleClient( 'MsExcel' )
				MsgAlert("O excel não foi encontrado. Arquivo " + cArqGer + " gerado em " + GetTempPath() + ".", "MsExcel não encontrado" )
			Else
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( GetTempPath()+cArqGer )
				oExcelApp:SetVisible(.T.)
			EndIf
		Else
			MsgAlert("Não foi possivel criar o arquivo " + cArqGer + " no cliente no diretório " + GetTempPath() + ". Por favor, contacte o suporte.", "Não foi possivel criar Planilha." )
		EndIf
		msgInfo('Arquivo '+cDiretorio+cArqGer+" gerado com sucesso")
	endIf
return

/*/{Protheus.doc} geraExcel
Função que gera o XML do Excel.
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${cFileName}, ${Caminho completo do arquivo}
@param lCabec, logical, Indica se usa cabeçalho
@param aItens, array, Vetor com itens a serem impressos
@param aCabec, array, Vetor com cabeçalho
@param cDirServer, characters, Caminho do arquivo
@param cNomeArq, characters, Nome do arquivo
@type function
/*/
Static function geraExcel( lCabec, aItens, aCabec, cDirServer, cNomeArq )
	Local cCreate   := AllTrim( Str( Year( dDataBase ) ) ) + "-" + AllTrim( Str( Month( dDataBase ) ) ) + "-" + AllTrim( Str( Day( dDataBase ) ) ) + "T" + SubStr( Time(), 1, 2 ) + ":" + SubStr( Time(), 4, 2 ) + ":" + SubStr( Time(), 7, 2 ) + "Z" // string de data no formato <Ano>-<Mes>-<Dia>T<Hora>:<Minuto>:<Segundo>Z
	Local nRecords  := 0 // Numero de Linhas + Cabeçalho formato string
	Local cFileName :=  trim(cNomeArq)   //CriaTrab( , .F. )
	Local i, j
	
	Default lCabec := .F.
	
    if upper(right(trim(cNomeArq),3)) != "XLS"
	    cFileName := trim(cNomeArq) + ".xls" // "TESTE.XML"
	else
		cFileName := trim(cNomeArq)
	endif
	
	nRecords := Len( aItens)
		
	If ( nHandle := FCreate( cFileName , FC_NORMAL ) ) != -1
		ConOut("Arquivo criado com sucesso.")
	Else
		MsgAlert("Não foi possivel criar a planilha. Por favor, verifique se existe espaço em disco ou você possui pemissão de escrita no diretório", "Erro de criação de arquivo")
		ConOut("Não foi possivel criar a planilha no diretório")
	 Return()
	EndIf
		
	cFile := "<?xml version=" + Chr(34) + "1.0" + Chr(34) + "?>" + Chr(13) + Chr(10)
	cFile += "<?mso-application progid=" + Chr(34) + "Excel.Sheet" + Chr(34) + "?>" + Chr(13) + Chr(10)
	cFile += "<Workbook xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:spreadsheet" + Chr(34) + " " + Chr(13) + Chr(10)
	cFile += "	xmlns:o=" + Chr(34) + "urn:schemas-microsoft-com:office:office" + Chr(34) + " " + Chr(13) + Chr(10)
	cFile += "	xmlns:x=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + " " + Chr(13) + Chr(10)
	cFile += "	xmlns:ss=" + Chr(34) + "urn:schemas-microsoft-com:office:spreadsheet" + Chr(34) + " " + Chr(13) + Chr(10)
	cFile += "	xmlns:html=" + Chr(34) + "http://www.w3.org/TR/REC-html40" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "	<DocumentProperties xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:office" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "		<Author>" + AllTrim(SubStr(cUsuario,7,15)) + "</Author>" + Chr(13) + Chr(10)
	cFile += "		<LastAuthor>" + AllTrim(SubStr(cUsuario,7,15)) + "</LastAuthor>" + Chr(13) + Chr(10)
	cFile += "		<Created>" + cCreate + "</Created>" + Chr(13) + Chr(10)
	cFile += "		<Company>Microsiga Intelligence</Company>" + Chr(13) + Chr(10)
	cFile += "		<Version>11.6568</Version>" + Chr(13) + Chr(10)
	cFile += "	</DocumentProperties>" + Chr(13) + Chr(10)
	cFile += "	<ExcelWorkbook xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "		<WindowHeight>9345</WindowHeight>" + Chr(13) + Chr(10)
	cFile += "		<WindowWidth>11340</WindowWidth>" + Chr(13) + Chr(10)
	cFile += "		<WindowTopX>480</WindowTopX>" + Chr(13) + Chr(10)
	cFile += "		<WindowTopY>60</WindowTopY>" + Chr(13) + Chr(10)
	cFile += "		<ProtectStructure>False</ProtectStructure>" + Chr(13) + Chr(10)
	cFile += "		<ProtectWindows>False</ProtectWindows>" + Chr(13) + Chr(10)
	cFile += "	</ExcelWorkbook>" + Chr(13) + Chr(10)
	cFile += "	<Styles>" + Chr(13) + Chr(10)
	cFile += "		<Style ss:ID=" + Chr(34) + "Default" + Chr(34) + " ss:Name=" + Chr(34) + "Normal" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "			<Alignment ss:Vertical=" + Chr(34) + "Bottom" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "			<Borders/>" + Chr(13) + Chr(10)
	cFile += "			<Font/>" + Chr(13) + Chr(10)
	cFile += "			<Interior/>" + Chr(13) + Chr(10)
	cFile += "			<NumberFormat/>" + Chr(13) + Chr(10)
	cFile += "			<Protection/>" + Chr(13) + Chr(10)
	cFile += "		</Style>" + Chr(13) + Chr(10)
	cFile += "	<Style ss:ID=" + Chr(34) + "s21" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "		<NumberFormat ss:Format=" + Chr(34) + "Short Date" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "	</Style>" + Chr(13) + Chr(10)
	cFile += "	</Styles>" + Chr(13) + Chr(10)
	
 	cFile += " <Worksheet ss:Name=" + Chr(34) + "Fonte de Dados" /*"Plan1"*/ + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "		<Table x:FullColumns=" + Chr(34) + "1" + Chr(34) + " x:FullRows=" + Chr(34) + "1" + Chr(34) + ">" + Chr(13) + Chr(10)
			
	If nHandle >=0
	 FWrite(nHandle, cFile)
	 cFile := ""
	Endif
				
	For i := 1 To nRecords
		cFile += "			<Row>" + Chr(13) + Chr(10)
		For j := 1 To len(aItens[i])
			cFile += "				" + FS_GetCell(aItens[i][j]) + Chr(13) + Chr(10)
		Next
		cFile += "			</Row>" + Chr(13) + Chr(10)
	 If (i % 100) == 0
	  If nHandle >=0
	   FWrite(nHandle, cFile)
		  cFile := ""
	  Endif
	 Endif
	Next
  
 	cFile += "		</Table>" + Chr(13) + Chr(10)
 	cFile += "		<WorksheetOptions xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "			<PageSetup>" + Chr(13) + Chr(10)
	cFile += "				<Header x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "				<Footer x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "				<PageMargins x:Bottom=" + Chr(34) + "0.984251969" + Chr(34) + " x:Left=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Right=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Top=" + Chr(34) + "0.984251969" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "			</PageSetup>" + Chr(13) + Chr(10)
	cFile += "			<Selected/>" + Chr(13) + Chr(10)
	cFile += "			<ProtectObjects>False</ProtectObjects>" + Chr(13) + Chr(10)
	cFile += "			<ProtectScenarios>False</ProtectScenarios>" + Chr(13) + Chr(10)
	cFile += "		</WorksheetOptions>" + Chr(13) + Chr(10)
	cFile += "	</Worksheet>" + Chr(13) + Chr(10)
  
	cFile += "	<Worksheet ss:Name=" + Chr(34) + "Plan2" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "		<WorksheetOptions xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "			<PageSetup>" + Chr(13) + Chr(10)
	cFile += "				<Header x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "				<Footer x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "				<PageMargins x:Bottom=" + Chr(34) + "0.984251969" + Chr(34) + " x:Left=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Right=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Top=" + Chr(34) + "0.984251969" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "			</PageSetup>" + Chr(13) + Chr(10)
	cFile += "			<ProtectObjects>False</ProtectObjects>" + Chr(13) + Chr(10)
	cFile += "			<ProtectScenarios>False</ProtectScenarios>" + Chr(13) + Chr(10)
	cFile += "		</WorksheetOptions>" + Chr(13) + Chr(10)
	cFile += "	</Worksheet>" + Chr(13) + Chr(10)
	cFile += "	<Worksheet ss:Name=" + Chr(34) + "Plan3" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "		<WorksheetOptions xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "			<PageSetup>" + Chr(13) + Chr(10)
	cFile += "				<Header x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "				<Footer x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "				<PageMargins x:Bottom=" + Chr(34) + "0.984251969" + Chr(34) + " x:Left=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Right=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Top=" + Chr(34) + "0.984251969" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "			</PageSetup>" + Chr(13) + Chr(10)
	cFile += "			<ProtectObjects>False</ProtectObjects>" + Chr(13) + Chr(10)
	cFile += "			<ProtectScenarios>False</ProtectScenarios>" + Chr(13) + Chr(10)
	cFile += "		</WorksheetOptions>" + Chr(13) + Chr(10)
	cFile += "	</Worksheet>" + Chr(13) + Chr(10)
	cFile += "</Workbook>" + Chr(13) + Chr(10)
	
	ConOut("Criando o arquivo " + cFileName + ".")
	If nHandle  >= 0
		FWrite(nHandle, cFile)
		FClose(nHandle)
		ConOut("Arquivo criado com sucesso.")
	Else
		MsgAlert("Não foi possivel criar a planilha. Por favor, verifique se existe espaço em disco ou você possui pemissão de escrita no diretório \system\", "Erro de criação de arquivo")
		ConOut("Não foi possivel criar a planilha no diretório \system\")
	EndIf
	
Return cFileName



/*/{Protheus.doc} FS_GetCell
Função que gera celulas do excel.
@author Andre Cruz
@since 17/05/2018
@version 1.0
@return ${cRet}, ${Texto da celula}
@param xVar, , Valor a ser convertido em celula
@type function
/*/
static function FS_GetCell( xVar )
	Local cRet  := ""
	Local cType := ValType(xVar)
	
	If cType == "U"
		cRet := "<Cell><Data ss:Type=" + Chr(34) + "General" + Chr(34) + "></Data></Cell>"
	ElseIf cType == "C"
		cRet := "<Cell><Data ss:Type=" + Chr(34) + "String" + Chr(34) + ">" + AllTrim( xVar ) + "</Data></Cell>"
	ElseIf cType == "N"
		cRet := "<Cell><Data ss:Type=" + Chr(34) + "Number" + Chr(34) + ">" + AllTrim( Str( xVar ) ) + "</Data></Cell>"
	ElseIf cType == "D"
		xVar := DToS( xVar )
	 	if empty(xVar)
			cRet := "<Cell ss:StyleID=" + Chr(34) + "s21" + Chr(34) + " />"
	 	else
			cRet := "<Cell ss:StyleID=" + Chr(34) + "s21" + Chr(34) + "><Data ss:Type=" + Chr(34) + "DateTime" + Chr(34) + ">" + SubStr(xVar, 1, 4) + "-" + SubStr(xVar, 5, 2) + "-" + SubStr(xVar, 7, 2) + "T00:00:00.000</Data></Cell>"
		endIf
	Else
		cRet := "<Cell><Data ss:Type=" + Chr(34) + "Boolean" + Chr(34) + ">" + Iif ( xVar , "=VERDADEIRO" ,  "=FALSO" ) + "</Data></Cell>"
	EndIf

Return cRet

