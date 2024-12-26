#include "totvs.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "fwmvcdef.ch"
#include "FileIO.ch"

// aParam ::= { { <LOTE>, <Curral> } }
User function VAESTR16(aParam)
	Private lOk			:= .T.  
	Private cZerados	:= "S"
	Private dDataDe		:= cToD("")
	Private dDataAte	:= cToD("")
	Private aLotes 			:= {}
	Private aFornecedores 	:= {}
	Private aContratos		:= {}

	If !(Empty(aParam))
		aLotes := aClone(aParam)
		dDataAte := dDataBase
		dDataDe := DataCocho(aLotes[1][1])
	EndIf

	aHeadLote := {}
	aAdd(aHeadLote,{ "Lote"			, "B8_LOTECTL" 		, "@!"				, 010, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadLote,{ "Curral"		, "B8_X_CURRA"  	, "@!"				, 010, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadLote,{ "Saldo Atual"	, "B8_SALDO"		, "@E 999,999.99"	, 010, 2, "AllwaysTrue()", .t., "N", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadLote,{ "Peso Medio"	, "B8_XPESOCO"	 	, "@E 999,999.99"	, 010, 2, "AllwaysTrue()", .t., "N", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadLote,{ "Data Inicio"	, "B8_XDATACO"		, "@D"				, 008, 0, "AllwaysTrue()", .t., "D", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadLote,{ "Qtd Dias"		, "QTD_DIAS"		, "@E 999,999"		, 007, 0, "AllwaysTrue()", .t., "N", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadLote,{ "Saldo Inicial", "SALDO_INI"		, "@E 999,999.99"	, 010, 2, "AllwaysTrue()", .t., "N", "", "V", "", "", "", "V", "", "", ""})
	
	aHeadProd := {}
	aAdd(aHeadProd,{ "Cod. Produto"	, "B2_COD" 			, "@!"				, 015, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadProd,{ "Descricaoo"	, "B1_DESC"			, "@!"				, 010, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadProd,{ "Armazem"		, "B2_LOCAL"		, "@!"				, 005, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadProd,{ "Saldo"		, "B2_QATU" 		, "@E 999,999.99"	, 010, 2, "AllwaysTrue()", .t., "N", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadProd,{ "Fornecedor"	, "A2_NOME"			, "@!"				, 020, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadProd,{ "Pedido"		, "C7_NUM"			, "@!"				, 010, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	
	aHeadMov := {}
	aAdd(aHeadMov,{ "Data Movto"	, "D3_EMISSAO"		, "@D"				, 008, 0, "AllwaysTrue()", .t., "D", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "Cod. Produto"	, "D3_COD" 			, "@!"				, 015, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "Descricao"		, "B1_DESC"			, "@!"				, 010, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "Quantidade"	, "D3_QUANT" 		, "@E 999,999.99"	, 010, 2, "AllwaysTrue()", .t., "N", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "Lote Origem"	, "D3_LOTEORI"		, "@!"				, 005, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "TM/TES"		, "TM_ORIGEM"		, "@!"				, 005, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "Desc. TM/TES"	, "TM_ORIDESC"		, "@!"				, 005, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "CF Origem"		, "CF_ORI"			, "@!"				, 005, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "Doc. Origem"	, "DOC_ORI"			, "@!"				, 010, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "Lote Destino"	, "D3_LOTEDES"		, "@!"				, 005, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "TM/TES"		, "TM_DESTINO"		, "@!"				, 005, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "Desc. TM/TES"	, "TM_DESDESC"		, "@!"				, 005, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "CF Destino"	, "CF_DES"			, "@!"				, 005, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "Doc. Destino"	, "DOC_DES"			, "@!"				, 010, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "Observacao"	, "DOC_OBS"			, "@!"				, 030, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	aAdd(aHeadMov,{ "Usuario"		, "D3_USUARIO"		, "@!"				, 010, 0, "AllwaysTrue()", .t., "C", "", "V", "", "", "", "V", "", "", ""})
	 
		
	// Se aParam estiver preenchido n�o chama tela de parametros
	if !(Empty(aParam)) .or. callParam(.T.) 
		cQry := defQuery()
		
		Private oDlgTmp
		
		nT	:= 0
		nL	:= 0
		nB	:= 600
		nR	:= 800
		if ( Type( "oMainWnd" ) == "O" )
			aCoors	:= FWGetDialogSize( oMainWnd )
			nT	:= aCoors[1]
			nL	:= aCoors[2]
			nB	:= aCoors[3]-10
			nR	:= aCoors[4]-10
		endIf
		
		oDlgTmp := TExConsulta():New(nT,nL,nB,nR,"Consulta Lotes de Bovinos",,,,/*nOr(WS_VISIBLE,WS_POPUP)*/,CLR_BLACK,CLR_WHITE,,,.T.,,,,.F. /*lTransparent*/, aHeadLote, aHeadProd, aHeadMov)
			oDlgTmp:setPerg("VAEST15")
			
			oFiltrar	:= TButton():New( 003, oDlgTmp:nEsquerda, "Filtros" , oDlgTmp:oPnlTop, {|| callParam() },40,15,,,.F.,.T.,.F.,,.F.,,,.F.)
			
			@ 003,oDlgTmp:nEsquerda + 50  SAY "Data De:" SIZE 55,07 OF oDlgTmp:oPnlTop PIXEL
			@ 003,oDlgTmp:nEsquerda + 80 GET oDataDe VAR dDataDe PICTURE "@D" OF oDlgTmp:oPnlTop PIXEL SIZE 60,10 READONLY
			
			@ 003,oDlgTmp:nEsquerda + 150 SAY "Ate:" SIZE 55,07 OF oDlgTmp:oPnlTop PIXEL
			@ 003,oDlgTmp:nEsquerda + 170 GET oDataAte VAR dDataAte PICTURE "@D" OF oDlgTmp:oPnlTop PIXEL SIZE 60,10 READONLY
	
			oDlgTmp:cSQLOri := cQry
			oDlgTmp:atuSQL()
			
		oDlgTmp:Activate(,,,.T.,{|| /*msgstop('validou!'), */.T.},,{|| updateSQL() /*msgstop('iniciando�')*/ } ) 
	endif
	
return

static function updateSQL(nLinha)
	cQry := defQuery()
	oDlgTmp:cSQLOri := cQry
	oDlgTmp:atuSQL()
	oDlgTmp:changeData(nLinha)
return

static function callParam(lFirst)
	local obj
	local lConfirm := .F.
	default lFirst := .F.
	
	if lFirst
		//obj := TExFilter():New("SX5",{"X5_CHAVE", "X5_DESCRI"}, "Departamentos", "T1", .T.)
		//aAssunto := aClone(obj:aSelect)
		obj := TExFilter():New("SB8",{"B8_LOTECTL", "B8_X_CURRA"}, "Lotes", , .T.)
		aLotes := aClone(obj:aSelect)
		obj := TExFilter():New("SA2",{"A2_COD", "A2_NOME"}, "Fornecedor", , .T.)
		aFornecedores := aClone(obj:aSelect)
		obj := TExFilter():New("ZCC",{"ZCC_CODIGO", "ZCC_NOMFOR"}, "Contratos", , .T.)
		aContratos := aClone(obj:aSelect)
	endIf

	DEFINE FONT oFont NAME "Courier New" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlgWnd TITLE OemToAnsi( "Informe os parametros" ) From 0,0 TO 200,800 OF GetWndDefault() STYLE DS_MODALFRAME STATUS  PIXEL
		
		tSay():New(037, 005/*150*/,{||'Exibe Saldos zerados?' },oDlgWnd,,oFont,,,,.T.,,,200,100)
		aZerados := {"S=Sim","N=Nao"}
		oZerados := TComboBox():New(035,080/*210*/,{|u|if(PCount()>0,cZerados:=u,cZerados)},aZerados,80,20,oDlgWnd,,{|| .T. },,,,.T.,,,,,,,,,'cZerados')
		
		tSay():New(037, 180,{||'Data De: ' },oDlgWnd,,oFont,,,,.T.,,,200,100)
		@ 035,220 MSGET oDataDe VAR dDataDe PICTURE "@D" VALID {|| dDataDe <= date() } SIZE 050,010 OF oDlgWnd PIXEL HASBUTTON
		tSay():New(037, 270,{||'Ate: ' },oDlgWnd,,oFont,,,,.T.,,,200,100)
		@ 035,290 MSGET oDataAte VAR dDataAte PICTURE "@D" VALID {|| dDataAte <= date() .and. dDataAte >= dDataDe } SIZE 050,010 OF oDlgWnd PIXEL HASBUTTON
		
		oBtnAssunto	:= TButton():New( 065, 005, "Lotes" 		, oDlgWnd, {|| obj := TExFilter():New("SB8",{"B8_LOTECTL", "B8_X_CURRA"}, "Lotes", , .F.,iif(cZerados=="N","B8_SALDO > 0",nil) ,aLotes), 			aLotes := aClone(obj:aSelect),  },60,15,,,.F.,.T.,.F.,,.F.,,,.F.)
		oBtnAssunto	:= TButton():New( 065, 070, "Fornecedores"	, oDlgWnd, {|| obj := TExFilter():New("SA2",{"A2_COD", "A2_NOME"}, "Fornecedor", , .F., ,aFornecedores), 		aFornecedores := aClone(obj:aSelect) },60,15,,,.F.,.T.,.F.,,.F.,,,.F.)
		oBtnAssunto	:= TButton():New( 065, 135, "Contratos" 	, oDlgWnd, {|| obj := TExFilter():New("ZCC",{"ZCC_CODIGO", "ZCC_NOMFOR"}, "Contratos", , .F., ,aContratos), 	aContratos := aClone(obj:aSelect) },60,15,,,.F.,.T.,.F.,,.F.,,,.F.)
		
		oDlgWnd:lEscClose := .F.
		bDialogInit := { || EnchoiceBar( oDlgWnd , { || lConfirm := .T. , oDlgWnd:End() } , { || lConfirm := .F. , oDlgWnd:End() } ) }
	ACTIVATE MSDIALOG oDlgWnd CENTERED ON INIT Eval( bDialogInit ) 
	
	if lConfirm .and. !lFirst
		MsgRun ("Atualizando dados...", "Processando", {|| updateSQL() } )
	endIf
return lConfirm

static function defQuery()
	local cQry := ""
	
	cQry := " select B8_LOTECTL, B8_X_CURRA, sum(B8_SALDO) B8_SALDO, avg(B8_XPESOCO) B8_XPESOCO, min(B8_XDATACO) B8_XDATACO, 0 QTD_DIAS, 0 SALDO_INI"+CRLF
	cQry += "   from "+retSQLName("SB8")+" SB8"+CRLF
	cQry += "   "+iif(len(aContratos) = 0,"left","")+" join "+retSQLName("SB1")+" SB1 on (SB1.D_E_L_E_T_=' ' and B1_FILIAL='  ' and B1_COD=B8_PRODUTO"
	cQry += filtroQry("SB1", "B1_XCONTRA", aContratos) +CRLF
	cQry += " )"+CRLF
	cQry += "   "+iif(len(aFornecedores) = 0,"left","")+" join "+retSQLName("SC7")+" SC7 on (SC7.D_E_L_E_T_=' ' and C7_FILIAL='01' and C7_PRODUTO=B1_COD and C7_FILIAL+C7_NUM=B1_XLOTCOM"
	cQry += filtroQry("SC7", "C7_FORNECE", aFornecedores) +CRLF
	cQry += " )"+CRLF
	cQry += "  where SB8.D_E_L_E_T_=' ' and B8_FILIAL='01' "+CRLF
	cQry += filtroQry("SB8", "B8_LOTECTL", aLotes) +CRLF
	if cZerados == "N"
		cQry += "    and SB8.B8_SALDO > 0 "+CRLF
	endIf
	cQry += "  group by B8_LOTECTL, B8_X_CURRA "+CRLF
	cQry += " order by B8_LOTECTL, B8_X_CURRA "+CRLF
	
return cQry

static function filtroQry(cTbl, cCampo, aItens)
	cTxt := " "
	cInObj := deAToC(aItens)
	if !empty(cInObj)
		cTxt += "       and "+cTbl+"."+cCampo+" in ("+cInObj+") "+CRLF
	endIf
return cTxt

static function deAToC(pArray)
	local cInObj := ""
	Local nI := 1
	for nI := 1 to len(pArray)
		if nI == 1
			cInObj := "'"+pArray[nI,1]+"'"
		else
			cInObj += ",'"+pArray[nI,1]+"'"
		endIf
	next
return cInObj


user function TExConsulta()
return

class TExConsulta from MsDialog
	data aCoors
	data nSuperior
	data nEsquerda
	data nInferior
	data nDireita
	data oFont
	data nOpc
	data cLinOk	
	data nMax
	data cDelOk
	data oBtFecha
	data aTFolder
	data oTFolder
	data oPnlTop
	data oPnlBottom
	data oImprime
	data oExcel
	data oPesquisar
	
	data aParSQL
	data aRes
	data aCmpRes
	
	data aHeadDef
	
	data oGetDados
	data aHeader
	data aCols
	data nUsado
	
	data oPnlTopS
	data oPesquiS	
	data oPnlBotS
	data oExcelS
	
	data oGetSint
	data aHeadSin
	data aColsSin
	data nUsadSin
		
	data aHeadF
	data aColsF
	data nUsadF
	
	data oGetRes
	data aHeadRes
	data aColsRes
	data nUsadRes
	
	data oGetMov
	data aHeadMov
	data aColsMov
	data nUsadMov
	
	data oLblTotal
	data oLblTotal2
	
	data aTipos
	data cTipo
	data oTipo
	data cDiretorio
	data cArquivo
	data cPerg
	data cSQL
	data cSQLOri
	
	data oTotLot1
	data oTotLot2
	data oTotProd

	method New(nTop, nLeft, nBottom, nRight, cCaption, uParam6, uParam7, uParam8, uParam9, nClrText, nClrBack, uParam12, oWnd, lPixel, uParam15, uParam16, uParam17, lTransparent, aHeadP, aHeadR) constructor
	method defDados()
	method defSintetico()
	method changeData()
	method atuDados()
	method setPerg(pPerg)
	method GeraSX1()
	method geraExcel( lCabec, aItens, aCabec, cDirServer, cNomeArq, aResumos )
	method FS_GetCell( xVar )
	method Excel()
	method ExcelRes()
	method Imprimir()
	method RelImpr()
	method defAtDet(pCampo, pValor)
	method setSQL(pSQL)
	method setHeader(pTitulo, pCampo, pTipo, pCpTam, pPicture, pAltera)
	method setParam(pCampo, pValor)
	method atuSQL()
	method atuResumos()
endClass                  


method atuSQL() class TExConsulta
	::setSQL(::cSQLOri)
return


method setParam(pCampo, pValor) class TExConsulta
	aAdd(::aParSQL, {pCampo,pValor})
return


method setHeader(pTitulo, pCampo, pTipo, pCpTam, pPicture, pAltera) class TExConsulta
	default pPicture	:= ""
	default pAltera	:= "V"
	default pCpTam		:= pCampo
	aAdd(::aHeadDef,{ pTitulo, pCampo, pPicture, TamSX3(pCpTam)[1]+3, TamSX3(pCpTam)[2], "AllwaysTrue()", .t., pTipo, "", pAltera, "", "", "", "V", "", "", ""})
return


method setSQL(pSQL) class TExConsulta
	Local nI := 1
	
	if !empty(pSQL)
		::cSQL := "with parametros as ( "+chr(13)+chr(10)
		::cSQL += " select "+chr(13)+chr(10)
		::cSQL += "  '"+SM0->M0_CODIGO+"' as cod_empresa "+chr(13)+chr(10)
		::cSQL += " ,'"+SM0->M0_CODFIL+"' as cod_filial "+chr(13)+chr(10)
		if len(::aParSQL) > 0	
			for nI := 1 to len(::aParSQL)
				::cSQL += " ,'"+&(::aParSQL[nI,2])+"' as "+::aParSQL[nI,1]+" "+chr(13)+chr(10)
			next
		endIf
		//::cSQL += " from dual "+chr(13)+chr(10)
		::cSQL += " ) "+chr(13)+chr(10)
		if allTrim(substr(pSQL,1,5)) != "with"
			::cSQL += chr(13)+chr(10)+pSQL
		else
			::cSQL := pSQL
		endIf
	endIf
return


method setPerg(pPerg) class TExConsulta
	::cPerg := pPerg
	::cPerg :=PADR(::cPerg,Len(SX1->X1_GRUPO))
return


method changeData(nLinha) class TExConsulta
	if nLinha == nil
		nLinha := 1
	
		::atuSQL()
		::atuDados()
		
		::oGetDados:setArray(::aCols)
		::oGetDados:oBrowse:Refresh()
	endIf
	
	::atuResumos(nLinha)
	
	::oGetRes:setArray(::aColsRes)
	::oGetRes:oBrowse:Refresh()
	
	::oGetMov:setArray(::aColsMov)
	::oGetMov:oBrowse:Refresh()
	
	ObjectMethod(SELF,"Refresh()")
return .T.




method atuDados() class TExConsulta
	aRes :=	 ::defDados()
	::aHeader	:= aRes[1]
	::aCols		:= aRes[2]
	::nUsado	:= aRes[3]
return




method New(nTop, nLeft, nBottom, nRight, cCaption, uParam6, uParam7, uParam8, uParam9, nClrText, nClrBack, uParam12, oWnd, lPixel, uParam15, uParam16, uParam17, lTransparent, aHeadP, aHeadR, aHeadS) class TExConsulta
	:New(nTop, nLeft, nBottom, nRight, cCaption, uParam6, uParam7, uParam8, uParam9, nClrText, nClrBack, uParam12, oWnd, lPixel, uParam15, uParam16, uParam17, lTransparent)
	if ( Type( "oMainWnd" ) == "O" )
		::aCoors	:= FWGetDialogSize( oMainWnd )
	endIf
	::cDiretorio	:= space(100)
	::cArquivo		:= space(100)
	
	::aHeadDef	:= aHeadP
    ::aHeadRes := aHeadR
    
	::nUsadRes := len(::aHeadRes)
	::aColsRes := {}
	aAdd(::aColsRes,Array(::nUsadRes+1))
	::aColsRes[len(::aColsRes),::nUsadRes+1] := .F.
    
    ::aHeadMov := aHeadS
    
	::nUsadMov := len(::aHeadMov)
	::aColsMov := {}
	aAdd(::aColsMov,Array(::nUsadMov+1))
	::aColsMov[len(::aColsMov),::nUsadMov+1] := .F.
    
	::aParSQL	:= {}
	::aCmpRes	:= {}
	::cSQL		:= ""
	::cSQLOri	:= ""
	
	::nSuperior	:= ::nTop+5
	::nEsquerda	:= ::nLeft+5
	::nInferior	:= ::nBottom/2-5
	::nDireita		:= ::nRight/2-5
	
	::nOpc			:= GD_UPDATE
	::cLinOk		:= "AllwaysTrue"
	::nMax			:= 999
	::cDelOk		:= "AllwaysTrue"
	::oFont		    := TFont():New('Trebuchet MS',,-14,,.T.)
	
	::oBtFecha		:= TButton():New( ::nInferior-30, ::nDireita-45, "Fechar" ,SELF, {|| SELF:End() },40,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	::oBtFecha:SetCss("QPushButton{ background: #D00; color: #FFF; background-repeat: none; margin: 2px; font-weight: bold; }")
	
	::aTFolder		:= {"Consulta - Lotes"}
 	::oTFolder		:= TFolder():New(::nSuperior,::nEsquerda,::aTFolder,,SELF,,,,.T.,,::nDireita-10,::nInferior-40)
	
	::nDireita		:= ::oTFolder:aDialogs[1]:nClientWidth/2-5
 	::nInferior	:= ::oTFolder:aDialogs[1]:nClientHeight/2-25
	
	::oPnlTop		:= TPanel():New(::nSuperior,::nEsquerda,"",::oTFolder:aDialogs[1],,,,CLR_WHITE,CLR_WHITE,::nDireita-5,20)
	`//::oPesquisar	:= TButton():New( 003, ::nDireita-55, "Pesquisar" , ::oPnlTop, {|| MsgRun ("Buscando informa��es...", "Processando", {|| updateSQL() } ) },40,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	
	::aRes 			:= ::defDados()
	::aHeader		:= ::aRes[1]
	::aCols			:= ::aRes[2]
	::nUsado		:= ::aRes[3]
	
	::oGetDados	:= MsNewGetDados():New(::nSuperior+25, ::nEsquerda, ::nInferior/2, ::nDireita/2 /*(2/3)*/, ::nOpc, ::cLinOk,,,,, ::nMax,,, ::cDelOk, ::oTFolder:aDialogs[1], ::aHeader, ::aCols, {|| ::changeData(::oGetDados:oBrowse:nAt)})
	::oGetRes	:= MsNewGetDados():New(::nSuperior+25, ::nDireita/2 /*(2/3)*/ +5, ::nInferior/2, ::nDireita, ::nOpc, ::cLinOk,,,,, ::nMax,,, ::cDelOk, ::oTFolder:aDialogs[1], ::aHeadRes, ::aColsRes)
	::oGetMov	:= MsNewGetDados():New(::nInferior/2 + 2, ::nEsquerda, ::nInferior, ::nDireita, ::nOpc, ::cLinOk,,,,, ::nMax,,, ::cDelOk, ::oTFolder:aDialogs[1], ::aHeadMov, ::aColsMov)
		
	oFont := TFont():New('Arial',,-18,.T.)
	
	::oPnlBottom	:= TPanel():New(::nInferior,::nEsquerda,"",::oTFolder:aDialogs[1],,,,CLR_WHITE,CLR_WHITE,::nDireita-5,20)
	//::oExcel		:= TButton():New( 003, 000, "Excel" 	,::oPnlBottom, {|| ::Excel()    },40,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	
	::oTotLot1 := " "
	::oTotLot2 := " "
	::oTotProd := " "
	@ 003,::nEsquerda GET oSayLot1 VAR ::oTotLot1 OF ::oPnlBottom MEMO PIXEL SIZE 100,10 READONLY 
	@ 003,::nEsquerda+105 GET oSayLot2 VAR ::oTotLot2 OF ::oPnlBottom MEMO PIXEL SIZE 100,10 READONLY
	@ 003,::nDireita/2 + 5 GET oSayProd VAR ::oTotProd OF ::oPnlBottom MEMO PIXEL SIZE 200,10 READONLY 
	
return


static function calcSldIni(cLote, dData)
local nSaldo := 0
default dData  := date()

	/* Resumo por resultado */ 
	beginSQL alias "QRYSLD"
		%noParser%
		select distinct B8_PRODUTO, B8_LOCAL
		  from %table:SB8% SB8
		 where SB8.D_E_L_E_T_=' ' and B8_FILIAL=%xFilial:SB8%
		   and B8_LOTECTL=%exp:cLote%
	endSQL
	
	while !QRYSLD->(Eof())
	 	//Renato
	 	nSaldo += CalcEstL(QRYSLD->B8_PRODUTO/*cProduto*/, QRYSLD->B8_LOCAL/*cAlmox*/, iif(dDataDe<>ctod(""),dDataDe,date())-1 /*dData*/, cLote/*cLote*/, /*cSubLote*/, /*cEnder*/, /*cSerie*/, .F. /*lRastro*/)[1]
		QRYSLD->(dbSkip())
	endDo
	QRYSLD->(dbCloseArea())
return nSaldo


method atuResumos(nLinha) class TExConsulta
local nTotal := 0
Local nI := 1
	if empty(::aCols[1, aScan(::aHeader, { |x| x[2]=="B8_LOTECTL"})])
		return
	endIf
	
	/* Resumo por resultado */
	cSqlTot := "select B2_COD, B1_DESC, B2_LOCAL, A2_NOME, C7_NUM, sum(B8_SALDO) B2_QATU"+CRLF 
	cSqlTot += "  from "+retSQLName("SB2")+" SB2 "+CRLF 
	cSqlTot += "  join "+retSQLName("SB1")+" SB1 on (B1_FILIAL='"+xFilial("SB1")+"' and SB1.D_E_L_E_T_=' ' and B1_COD=B2_COD) "+CRLF 
	cSqlTot += "  join "+retSQLName("SB8")+" SB8 on (B8_FILIAL='"+xFilial("SB8")+"' and SB8.D_E_L_E_T_=' ' and B8_PRODUTO=B1_COD and B8_LOTECTL='"+::aCols[nLinha, aScan(::aHeader, { |x| x[2]=="B8_LOTECTL"})]+"') "+CRLF
	cSqlTot += "  left join "+retSQLName("SC7")+" SC7 on (SC7.D_E_L_E_T_=' ' and C7_FILIAL='"+xFilial("SC7")+"' and C7_PRODUTO=B1_COD and C7_FILIAL+C7_NUM=B1_XLOTCOM)"
	cSqlTot += "  left join "+retSQLName("SA2")+" SA2 on (SA2.D_E_L_E_T_=' ' and A2_FILIAL='"+xFilial("SA2")+"' and A2_COD=C7_FORNECE and A2_LOJA=C7_LOJA)"
	cSqlTot += " where SB2.B2_FILIAL='"+xFilial("SB2")+"' and SB2.D_E_L_E_T_=' ' "+CRLF 
	cSqlTot += " group by B2_COD, B1_DESC, B2_LOCAL, A2_NOME, C7_NUM "
	/*cSqlTot += "   and B1_COD in (
		cSqlTot += "   select B8_PRODUTO from "+retSQLName("SB8")+" SB8 where B8_LOTECTL='"+::aCols[nLinha, aScan(::aHeader, { |x| x[2]=="B8_LOTECTL"})]+"' and SB8.D_E_L_E_T_=' ' and B8_FILIAL='"+XFILIAL("SB8")+"'
	cSqlTot += "   )"*/
	FwMsgRun(,{|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cSqlTot),'QRYTOT', .F., .T.) },,"Carregando produtos.")
	
	cAcaoAtu := " "
	::aColsRes := {}
	QRYTOT->(dbGoTop())
	if !QRYTOT->(Eof())
		While !QRYTOT->(eof())
			
			aAdd(::aColsRes,Array(::nUsadRes+1))
			::aColsRes[Len(::aColsRes),::nUsadRes+1]:=.F.
			
			for nI := 1 to len(::aHeadRes)
				::aColsRes[Len(::aColsRes), nI] := &("QRYTOT->"+ ::aHeadRes[nI, 2])
			endFor
			
			//x := 0
			//x++; ::aColsRes[Len(::aColsRes),x] := QRYTOT->UQ_DESC
			/*x++; ::aColsRes[Len(::aColsRes),x] := QRYTOT->B2_COD
			x++; ::aColsRes[Len(::aColsRes),x] := QRYTOT->B1_DESC
			x++; ::aColsRes[Len(::aColsRes),x] := QRYTOT->B2_LOCAL
			x++; ::aColsRes[Len(::aColsRes),x] := QRYTOT->A2_NOME
			x++; ::aColsRes[Len(::aColsRes),x] := QRYTOT->B2_QATU*/
			
			nTotal += QRYTOT->B2_QATU
			
			QRYTOT->(dbSkip())
		End
	else
		aAdd(::aColsRes,Array(::nUsadRes+1))
		::aColsRes[len(::aColsRes),::nUsadRes+1] := .F.
	endIf
	
	::oTotProd := "Quantidade Total do Lote: " + Transform(nTotal, "@E 99,999,999.99")
	QRYTOT->(dbCloseArea())	
	
	
	//Processamento dos movimentos
	cSqlMov := "with parametros as ( " + CRLF
	cSqlMov += "	select  " + CRLF
	cSqlMov += "		   '"+::aCols[nLinha, aScan(::aHeader, { |x| x[2]=="B8_LOTECTL"})]+"' lote_selecionado " + CRLF
	cSqlMov += ") " + CRLF

	cSqlMov += ", entradas as ( " + CRLF
	cSqlMov += "	select * " + CRLF
	cSqlMov += "	  from "+retSQLName("SD1")+" SD1 " + CRLF
	cSqlMov += "	 cross join parametros x " + CRLF
	cSqlMov += "	 where D1_FILIAL='"+xFilial("SD1")+"' and D_E_L_E_T_=' ' "/*+"and D1_COD like 'BOV%' "*/+"and D1_LOTECTL=lote_selecionado " + CRLF
	cSqlMov += "       and D1_EMISSAO between '"+dToS(dDAtaDe)+"' and '"+dToS(dDAtaAte)+"' "
	cSqlMov += ") " + CRLF

	cSqlMov += ", saidas as ( " + CRLF
	cSqlMov += "	select * " + CRLF
	cSqlMov += "	  from "+retSQLName("SD2")+" SD2 " + CRLF
	cSqlMov += "	 cross join parametros x " + CRLF
	cSqlMov += "	 where D2_FILIAL='"+xFilial("SD2")+"' and D_E_L_E_T_=' ' "/*+"and D2_COD like 'BOV%' "*/+"and D2_LOTECTL=lote_selecionado " + CRLF
	cSqlMov += "       and D2_EMISSAO between '"+dToS(dDAtaDe)+"' and '"+dToS(dDAtaAte)+"' "
	cSqlMov += ") " + CRLF

	cSqlMov += ", movto_lote as ( " + CRLF
	cSqlMov += "	select * " + CRLF
	cSqlMov += "	  from "+retSQLName("SD3")+" SD3 " + CRLF
	cSqlMov += "	 cross join parametros x " + CRLF
	cSqlMov += "	 where D3_FILIAL='"+xFilial("SD3")+"' and D_E_L_E_T_=' ' "/*+"and D3_COD like 'BOV%' "*/+"and D3_LOTECTL=lote_selecionado " + CRLF
	cSqlMov += "       and D3_EMISSAO between '"+dToS(dDAtaDe)+"' and '"+dToS(dDAtaAte)+"' "
	cSqlMov += "       and D3_OP = ' ' and D3_QUANT > 0 "
	cSqlMov += ") " + CRLF

	cSqlMov += ", movto_completo as ( " + CRLF
	cSqlMov += "	select m.R_E_C_N_O_ ORIGEM, SD3.R_E_C_N_O_ REC_DESTINO, m.D3_EMISSAO, m.D3_NUMSEQ, m.D3_DOC, m.D3_COD, m.D3_TM TM_ORI, m.D3_QUANT, m.D3_LOTECTL LOTE_ORI, m.D3_CF CF_ORI, SD3.D3_TM TM_DEST, SD3.D3_LOTECTL LOTE_DEST, SD3.D3_CF CF_DES, m.D3_DOC DOC_ORI, SD3.D3_DOC DOC_DES, m.D3_X_OBS DOC_OBS, m.D3_USUARIO " + CRLF
	cSqlMov += "	  from movto_lote m " + CRLF
	cSqlMov += "	  left join "+retSQLName("SD3")+" SD3 on (SD3.D3_FILIAL='"+xFilial("SD3")+"' and SD3.D_E_L_E_T_=' ' and SD3.D3_COD=m.D3_COD and SD3.D3_DOC=m.D3_DOC and SD3.D3_NUMSEQ=m.D3_NUMSEQ and SD3.R_E_C_N_O_<>m.R_E_C_N_O_ and SD3.D3_LOTECTL<>m.D3_LOTECTL and SD3.D3_TM<>m.D3_TM) " + CRLF
	cSqlMov += ") " + CRLF

	cSqlMov += "select D1_NUMSEQ NUMSEQ, D1_EMISSAO D3_EMISSAO, D1_COD D3_COD, B1_DESC, D1_QUANT D3_QUANT, D1_LOTECTL D3_LOTEORI, D1_TES TM_ORIGEM " + CRLF
	cSqlMov += "     , F4_TEXTO TM_ORIDESC " + CRLF
	cSqlMov += "	 , 'DE0' CF_ORI, D1_DOC DOC_ORI, '      ' D3_LOTEDES, '   ' TM_DESTINO " + CRLF
	cSqlMov += "	 , '      ' TM_DESDESC " + CRLF
	cSqlMov += "	 , '  ' CF_DES, '   ' DOC_DES, '  ' DOC_OBS, ' ' D3_USUARIO " + CRLF 
	cSqlMov += "  from entradas " + CRLF
	cSqlMov += "  left join "+retSQLName("SB1")+" SB1 on (B1_FILIAL='"+xFilial("SB1")+"' and SB1.D_E_L_E_T_=' ' and B1_COD=D1_COD) " + CRLF
	cSqlMov += "  left join "+retSQLName("SF4")+" SF4 on (SF4.F4_FILIAL='"+xFilial("SF4")+"' and SF4.D_E_L_E_T_=' ' and SF4.F4_CODIGO=D1_TES) " + CRLF

	cSqlMov += "union " + CRLF

	cSqlMov += "select D3_NUMSEQ NUMSEQ, D3_EMISSAO, D3_COD, B1_DESC, D3_QUANT, LOTE_ORI D3_LOTEORI, TM_ORI TM_ORIGEM " + CRLF
	cSqlMov += "     , case  " + CRLF
	cSqlMov += "		when TM_ORI = '499' then 'MOVTO DE ENTRADA'  " + CRLF
	cSqlMov += "	    when TM_ORI = '999' then 'MOVTO DE SAIDA' " + CRLF
	cSqlMov += "		when SF5ORI.F5_TEXTO is null then ' ' " + CRLF
	cSqlMov += "		else SF5ORI.F5_TEXTO  " + CRLF
	cSqlMov += "	 end TM_ORIDESC " + CRLF
	cSqlMov += "	 , CF_ORI, DOC_ORI, LOTE_DEST D3_LOTEDES, TM_DEST TM_DESTINO " + CRLF
	cSqlMov += "	 , case  " + CRLF
	cSqlMov += "		when TM_DEST = '499' then 'MOVTO DE ENTRADA' " + CRLF 
	cSqlMov += "	    when TM_DEST = '999' then 'MOVTO DE SAIDA' " + CRLF
	cSqlMov += "		when SF5DES.F5_TEXTO is null then ' ' " + CRLF
	cSqlMov += "		else SF5DES.F5_TEXTO " + CRLF 
	cSqlMov += "	 end TM_DESDESC " + CRLF
	cSqlMov += "	 , CF_DES, DOC_DES, DOC_OBS, D3_USUARIO " + CRLF 
	cSqlMov += "  from movto_completo " + CRLF
	cSqlMov += "  left join "+retSQLName("SB1")+" SB1 on (B1_FILIAL='"+xFilial("SB1")+"' and SB1.D_E_L_E_T_=' ' and B1_COD=D3_COD) " + CRLF
	cSqlMov += "  left join "+retSQLName("SF5")+" SF5ORI on (SF5ORI.F5_FILIAL='"+xFilial("SF5")+"' and SF5ORI.D_E_L_E_T_=' ' and SF5ORI.F5_CODIGO=TM_ORI) " + CRLF
	cSqlMov += "  left join "+retSQLName("SF5")+" SF5DES on (SF5DES.F5_FILIAL='"+xFilial("SF5")+"' and SF5DES.D_E_L_E_T_=' ' and SF5DES.F5_CODIGO=TM_DEST) " + CRLF

	cSqlMov += "union " + CRLF

	cSqlMov += "select D2_NUMSEQ NUMSEQ, D2_EMISSAO D3_EMISSAO, D2_COD D3_COD, B1_DESC, D2_QUANT D3_QUANT, D2_LOTECTL D3_LOTEORI, D2_TES TM_ORIGEM " + CRLF
	cSqlMov += "     , F4_TEXTO TM_ORIDESC " + CRLF
	cSqlMov += "	 , 'RE0' CF_ORI, D2_DOC DOC_ORI, '      ' D3_LOTEDES, '   ' TM_DESTINO " + CRLF
	cSqlMov += "	 , '      ' TM_DESDESC " + CRLF
	cSqlMov += "	 , '  ' CF_DES, '   ' DOC_DES, '  ' DOC_OBS, ' ' D3_USUARIO " + CRLF 
	cSqlMov += "  from saidas " + CRLF
	cSqlMov += "  left join "+retSQLName("SB1")+" SB1 on (B1_FILIAL='"+xFilial("SB1")+"' and SB1.D_E_L_E_T_=' ' and B1_COD=D2_COD) " + CRLF
	cSqlMov += "  left join "+retSQLName("SF4")+" SF4 on (SF4.F4_FILIAL='"+xFilial("SF4")+"' and SF4.D_E_L_E_T_=' ' and SF4.F4_CODIGO=D2_TES) " + CRLF

	cSqlMov += " order by 1 "
	
	FwMsgRun(,{|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cSqlMov),'QRYMOV', .F., .T.) },,"Carregando movimentos.")
	
	nEntradas := 0
	nSaidas := 0
	::aColsMov := {}
	QRYMOV->(dbGoTop())
	if !QRYMOV->(Eof())
		While !QRYMOV->(eof())
			
			aAdd(::aColsMov,Array(::nUsadMov+1))
			::aColsMov[Len(::aColsMov),::nUsadMov+1]:=.F.
			for nI := 1 to len(::aHeadMov)
				if ::aHeadMov[nI, 8]=='D'
					::aColsMov[Len(::aColsMov), nI] := STOD( &("QRYMOV->"+ ::aHeadMov[nI, 2]) )
				else
					::aColsMov[Len(::aColsMov), nI] := &("QRYMOV->"+ ::aHeadMov[nI, 2])
				endIf
			endFor
			
			if (QRYMOV->TM_ORIGEM < '500')
				//Entradas
				nEntradas += QRYMOV->D3_QUANT
			else
				//Saidas
				nSaidas += QRYMOV->D3_QUANT
			endIf
			
			QRYMOV->(dbSkip())
		End
	else
		aAdd(::aColsMov,Array(::nUsadMov+1))
		::aColsMov[len(::aColsMov),::nUsadMov+1] := .F.
	endIf
	
	::oTotLot1 := "Qtde Entradas: " + Transform(nEntradas, "@E 99,999,999.99")
	::oTotLot2 := "Qtde Saidas: " + Transform(nSaidas, "@E 99,999,999.99")
	
	GETDREFRESH()
	QRYMOV->(dbCloseArea())
	
return nil

method defDados() class TExConsulta
	local nTotal := 0
	Local nX := 1
	Local nI := 1

	private aHeadTmp	:= {}
	private aColsTmp	:= {}
	private nUsadTmp	:= 0
	
	private nPosdtAb    := 0
	private nPosHrAb    := 0
	private nPosdtFe    := 0
	private nPosHrFe    := 0
	
	private cDatIn := ' '
	private cDatFi := ' '
	
	aAdd(aHeadTmp,{ "Item"			   		, "R_E_C_N_O_"		, ""						, 6								, 0, "AllwaysTrue()"	, .t., "N", "", "V", "", "", "", "V", "", "", ""})
	if len(::aHeadDef) > 0
		for nX := 1 to len(::aHeadDef)
			aAdd(aHeadTmp, ::aHeadDef[nX])
		next
	endIf
	nUsadTmp := len(aHeadTmp)
	
	if empty(::cSQL)
		cQuery := "select '0' t_m_p_ "
		for nI := 2 to nUsadTmp
			if aHeadTmp[nX,8]=='D'
				cQuery += ", '"+DTOC(Date())+"' "+aHeadTmp[nI, 2]
			elseif aHeadTmp[nX,8]=='N'
				cQuery += ", '0' "+aHeadTmp[nI, 2]
			else
				cQuery += ", '"+CriaVar(aHeadTmp[nI, 2])+"' "+aHeadTmp[nI, 2]
			endIf
		next 
		//cQuery += " from dual where 1=0"
		::cSQL := cQuery
	endIf
	FwMsgRun(,{|| dbUseArea(.T., "TOPCONN", TCGenQry(,,::cSQL),'QRY', .F., .T.) },,"Aguarde... Selecionando Registros.")

	aColsTmp := {}
	nQtdReg := 0
	QRY->(dbGoTop())
	if !QRY->(Eof())
		While !QRY->(eof())
			aAdd(aColsTmp,Array(nUsadTmp+1))
			nQtdReg++
			aColsTmp[Len(aColsTmp),1]:= nQtdReg
			For nX:=2 to nUsadTmp
				if aHeadTmp[nX,8]=='D'
					aColsTmp[Len(aColsTmp),nX]:=STOD( QRY->( FieldGet(FieldPos(aHeadTmp[nX,2])) ) )
				else
					//aColsTmp[Len(aColsTmp),nX]:=QRY->( FieldGet(FieldPos(aHeadTmp[nX,2])) )
					aColsTmp[Len(aColsTmp),nX] := &("QRY->"+ aHeadTmp[nX,2])
					
					if(aHeadTmp[nX,2]=="B8_SALDO")
						if valType(QRY->( FieldGet(FieldPos(aHeadTmp[nX,2])) )) != "N"	
							nTotal += val(QRY->( FieldGet(FieldPos(aHeadTmp[nX,2])) ))
						else
							nTotal += QRY->( FieldGet(FieldPos(aHeadTmp[nX,2])) )
						endIf
					endIf
					
				endIf
			Next		
			aColsTmp[Len(aColsTmp),nUsadTmp+1]:=.F.
			
			//Renato
			nPosSld := aScan(aHeadTmp, {|x| x[2]="SALDO_INI"})
			nPosLote := aScan(aHeadTmp, {|x| x[2]="B8_LOTECTL"})
			aColsTmp[Len(aColsTmp), nPosSld] := calcSldIni(aColsTmp[Len(aColsTmp), nPosLote], date())
			
			nPosDias := aScan(aHeadTmp, {|x| x[2]="QTD_DIAS"})
			nPosDRef := aScan(aHeadTmp, {|x| x[2]="B8_XDATACO"})
			if !empty(aColsTmp[Len(aColsTmp), nPosDRef])
				aColsTmp[Len(aColsTmp), nPosDias] := Date() - aColsTmp[Len(aColsTmp), nPosDRef]
			endIf
			
			QRY->(dbSkip())
		End
	else
		aAdd(aColsTmp,Array(nUsadTmp+1))
		aColsTmp[len(aColsTmp),nUsadTmp+1] := .F.
	endIf
	QRY->(dbCloseArea())
	
	::oTotProd := "Total Lotes: " + Transform(nTotal, "@E 99,999,999.99")
	
return {aHeadTmp, aColsTmp, nUsadTmp}

method ExcelRes() class TExConsulta
	Local nI, nJ, nAux
	
	::cDiretorio	:= space(100)
	::cArquivo	:= space(100)
	
	::cDiretorio  := cGetFile(, 'Escolha o local do arquivo', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
	if right(::cDiretorio,1)!='/' .and. right(::cDiretorio,1)!='\'
		::cDiretorio += "\"
	endIf
	
	::GeraSX1()
	
	if !Pergunte(::cPerg,.T.)
		return
	else
		::cArquivo	:= MV_PAR01
		
		aCabec := {}
		for nI := 1 to len(::aHeadF)
			aAdd(aCabec,::aHeadF[nI,1])
		next
		
		aItens := {}
		for nI := 1 to len(::aColsF)
			aItm := {}
			for nJ := 1 to len(::aHeadF)
				aAdd(aItm,::aColsF[nI,nJ]) 
			next
			aAdd(aItens,aItm)
		next
		
		aResAux := {}
		//aAdd(aResAux, {::aHeadRes, ::aColsRes2})
		
		aResumos := {}
		for nAux := 1 to len(aResAux)
			aCabAux := {}
			for nI := 1 to len(aResAux[nAux][1])
				aAdd(aCabAux,aResAux[nAux][1][nI][1])
			next
			
			aIteAux := {}
			for nI := 1 to len(aResAux[nAux][2])
				aItm := {}
				for nJ := 1 to len(aResAux[nAux][1])
					aAdd(aItm,aResAux[nAux][2][nI][nJ]) 
				next
				aAdd(aIteAux,aItm)
			next
			
			aAdd(aResumos, {aCabAux, aIteAux})
		 next
		
		cArqGer := ::geraExcel( .T., aItens, aCabec, ::cDiretorio, ::cArquivo, aResumos )
		CpyS2T(GetSrvProfString ("STARTPATH","")+cArqGer, Alltrim(::cDiretorio))
		If (CpyS2T(GetSrvProfString ("STARTPATH","")+cArqGer, Alltrim(GetTempPath())))
			fErase(cArqGer)
			// Abre excell
			If !ApOleClient( 'MsExcel' )
				MsgAlert("O excel nao foi encontrado. Arquivo " + cArqGer + " gerado em " + GetTempPath() + ".", "MsExcel nao encontrado" )
			Else
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( GetTempPath()+cArqGer )
				oExcelApp:SetVisible(.T.)
			EndIf
		Else
			MsgAlert("Nao foi possivel criar o arquivo " + cArqGer + " no cliente no diretorio " + GetTempPath() + ". Por favor, contacte o suporte.", "Nao foi possivel criar Planilha." )
		EndIf
		alert('Arquivo '+::cDiretorio+cArqGer+" gerado com sucesso")
	endIf
return


method Excel() class TExConsulta
Local nI, nJ, nAux

	::cDiretorio	:= space(100)
	::cArquivo	:= space(100)
	
	::cDiretorio  := cGetFile(, 'Escolha o local do arquivo', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
	if right(::cDiretorio,1)!='/' .and. right(::cDiretorio,1)!='\'
		::cDiretorio += "\"
	endIf
	
	::GeraSX1()
	
	if !Pergunte(::cPerg,.T.)
		return
	else
		::cArquivo	:= MV_PAR01
		
		aCabec := {}
		for nI := 1 to len(::aHeader)
			aAdd(aCabec,::aHeader[nI,1])
		next
		
		aItens := {}
		for nI := 1 to len(::aCols)
			aItm := {}
			for nJ := 1 to len(::aHeader)
				aAdd(aItm,::aCols[nI,nJ]) 
			next
			aAdd(aItens,aItm)
		next
		
		aResAux := {}
		//aAdd(aResAux, {::aHeadRes, ::aColsRes})
		
		aResumos := {}
		for nAux := 1 to len(aResAux)
			aCabAux := {}
			for nI := 1 to len(aResAux[nAux][1])
				aAdd(aCabAux,aResAux[nAux][1][nI][1])
			next
			
			aIteAux := {}
			for nI := 1 to len(aResAux[nAux][2])
				aItm := {}
				for nJ := 1 to len(aResAux[nAux][1])
					aAdd(aItm,aResAux[nAux][2][nI][nJ]) 
				next
				aAdd(aIteAux,aItm)
			next
			
			aAdd(aResumos, {aCabAux, aIteAux})
		 next
		
		cArqGer := ::geraExcel( .T., aItens, aCabec, ::cDiretorio, ::cArquivo, aResumos )
		CpyS2T(GetSrvProfString ("STARTPATH","")+cArqGer, Alltrim(::cDiretorio))
		If (CpyS2T(GetSrvProfString ("STARTPATH","")+cArqGer, Alltrim(GetTempPath())))
			fErase(cArqGer)
			// Abre excell
			If !ApOleClient( 'MsExcel' )
				MsgAlert("O excel nao foi encontrado. Arquivo " + cArqGer + " gerado em " + GetTempPath() + ".", "MsExcel nao encontrado" )
			Else
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( GetTempPath()+cArqGer )
				oExcelApp:SetVisible(.T.)
			EndIf
		Else
			MsgAlert("Nao foi possivel criar o arquivo " + cArqGer + " no cliente no diretorio " + GetTempPath() + ". Por favor, contacte o suporte.", "Nao foi possivel criar Planilha." )
		EndIf
		alert('Arquivo '+::cDiretorio+cArqGer+" gerado com sucesso")
	endIf
return



method GeraSX1() class TExConsulta
	Local aArea 	:= GetArea()
	Local i	  		:= 0
	Local j     	:= 0
	Local lInclui	:= .F.
	Local aHelpPor	:= {}
	Local aHelpSpa	:= {}
	Local aHelpEng	:= {}
	Local cTexto	:= ''
	
	aRegs := {}

	AADD(aRegs,{::cPerg,"01","Nome do arquivo?" ,"","","mv_ch1","C",20,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","      ","N","","",""})
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 To Len(aRegs)
	 If lInclui := !dbSeek(::cPerg + aRegs[i,2])
		 RecLock("SX1", lInclui)
		  For j := 1 to FCount()
		   If j <= Len(aRegs[i])
		    FieldPut(j,aRegs[i,j])
		   Endif
		  Next
		 MsUnlock()
		EndIf

		aHelpPor := {}; aHelpSpa := {}; aHelpEng := {}
		
		IF i==1
			AADD(aHelpPor,"Informe o nome do arquivo")
			AADD(aHelpPor,"a ser gerado")
			AADD(aHelpPor,"")
		ENDIF
		PutSX1Help("P."+AllTrim(::cPerg)+strzero(i,2)+".",aHelpPor,aHelpEng,aHelpSpa)

	Next
	
	RestArea(aArea)
Return('SX1: ' + cTexto  + CHR(13) + CHR(10))


method Imprimir() class TExConsulta
	cDesc1     := "Imprime as os dados exibidos"
	cDesc2     := "na tela"
	cDesc3     := ""
	cString    := "SB8"
	imprime    := .T.
	cPict      := ""
	aOrd       := {}
	cTexto     := 0
	j          := 0
	tamanho    := "G"
	limite     := 220
	nomeprog   := "R"+allTrim(::cPerg)
	mv_tabpr   := ""
	nTipo      := 0
	aReturn    := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	titulo     := "Relatorio de Resumo de Indicadores (Pendentes)"
	nLastKey   := 0
	lExit      := .F.
	lEnd       := .F.
	
	//Totalizadores
	nValTotal := 0
	nQtdReg := 0
	
	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
	//����������������������������������������������������������������
	cbtxt      := SPACE(10)
	cbcont     := 00
	nLin       := 80
	CONTFL     := 01
	m_pag      := 01
	imprime    := .F.
	
	If nLastKey == 27
		Return
	EndIf
	
	Private aHeadRes := {}
	Private aResumo := {}
	Private nTamTra := 0
	
	wnrel := nomeprog
	wnrel := SetPrint(cString,wnrel,::cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho,,.F.)
	nOrdem     := aReturn[8]
	If nLastKey == 27
		Return
	EndIf
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Set Device to Screen
		Return
	EndIf
	
	RptStatus({|| ::RelImpr()})
return


method defAtDet(pCampo, pValor) class TExConsulta
	local aHeadTmp := {}
	local aColsTmp 	:= {}
	local nUsadoTmp	:= 0
	Local n1, nX, nY
	
	aHeadTmp := aClone(::aHeader)
	nUsadoTmp := len(aHeadTmp)
	
	aColsTmp  := {}
	aDados := {}
	if len(::aCols) > 0
		for n1 := 1 to len(::aCols)
			nPosOp := aScan(::aHeader, {|x| x[2]==pCampo})
			
			if nPosOp > 0
				if ::aCols[n1,nPosOp]==pValor
					aAdd(aDados, ::aCols[n1])
				endIf
			endIf
		next
	endIf
	
	if len(aDados) > 0
		for nX := 1 to len(aDados)
			aAdd(aColsTmp,Array(nUsadoTmp+1))
			For nY:=1 to nUsadoTmp
				aColsTmp[Len(aColsTmp),nY]:= aDados[nX,nY]
			Next		
			aColsTmp[Len(aColsTmp),nUsadoTmp+1]:=.F.
		next
	else
		aAdd(aColsTmp,Array(nUsadoTmp+1))
		aColsTmp[len(aColsTmp),nUsadoTmp+1] := .F.
	endIf
	
return {aHeadTmp, aColsTmp, nUsadoTmp}



method RelImpr() class TExConsulta
local cFileName := ""
local aDados := {}
Local nI, i

cabec1    := ""
cabec2    := ""
nTipo     := 15

for nI := 1 to len(::aHeader)
	if nI==1
		Cabec1 := substr(padr(cValToChar(::aHeader[nI,1]),::aHeader[nI,4]),1,::aHeader[nI,4]-1)+" "
	else
		Cabec1 += substr(padr(cValToChar(::aHeader[nI,1]),::aHeader[nI,4]),1,::aHeader[nI,4]-1)+" "
	endIf
next
//Cabec1       := "Status                   Produto                  Cod.Barras               Descricao                          Quantidade Eleita"

nLin := 80

//aSort(aCols,,,{|x,y| x[1] < y[1]})
for i := 1 to len(::aCols)
		
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If nLin > 67 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 09
	Endif
	
	cLinha := ""
	for nI := 1 to len(::aHeader)
		if nI==1
			cLinha := substr(padr(cValToChar(::aCols[i,nI]),::aHeader[nI,4]),1,::aHeader[nI,4]-1)+" "
		else
			if ::aHeader[nI,8]=="N"
				cLinha += substr(padl(transform(::aCols[i,nI],::aHeader[nI,3]),::aHeader[nI,4]),2,::aHeader[nI,4])+" "
			else
				cLinha += substr(padr(cValToChar(::aCols[i,nI]),::aHeader[nI,4]),1,::aHeader[nI,4]-1)+" "
			endIf
		endIf
	next
	@ nLin,000 PSay cLinha
	nLin ++
next
nLin++
nLin++

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return



method geraExcel( lCabec, aItens, aCabec, cDirServer, cNomeArq, aResumos ) class TExConsulta
	Local cCreate   := AllTrim( Str( Year( dDataBase ) ) ) + "-" + AllTrim( Str( Month( dDataBase ) ) ) + "-" + AllTrim( Str( Day( dDataBase ) ) ) + "T" + SubStr( Time(), 1, 2 ) + ":" + SubStr( Time(), 4, 2 ) + ":" + SubStr( Time(), 7, 2 ) + "Z" // string de data no formato <Ano>-<Mes>-<Dia>T<Hora>:<Minuto>:<Segundo>Z
	Local nFields   := 0 // N� de Colunas  formato string
	Local nRecords  := 0 // Numero de Linhas + Cabe�alho formato string
	Local cFileName :=  trim(cNomeArq)   //CriaTrab( , .F. )
	Local i, j, k
	
	Default aResumos := {}
	
    //cFileName := "c:\teste.txt" //Lower(GetClientDir( ) + cFileName + ".XML")
    if upper(right(trim(cNomeArq),3)) != "XLS"
	    cFileName := trim(cNomeArq) + ".xls" // "TESTE.XML"
	else
		cFileName := trim(cNomeArq)
	endif
	
	If Empty( aItens )
		aItens := aClone( ::aCols )
	End
	
	If Empty(aCabec) .AND. lCabec
		For i := 1 To Len( ::aHeader )
			AAdd( aCabec, ::aHeader[i][1] )
		Next
	EndIf
	
	If lCabec == Nil
		lCabec := .T.
	EndIf
	
	nRecords := Len( aItens)
			
	If lCabec
		nFields := Len( aCabec )
	Else
		nFields := Len( aItens[1] )
	EndIf
			
		
	If ( nHandle := FCreate( cFileName , FC_NORMAL ) ) != -1
		ConOut("Arquivo criado com sucesso.")
	Else
		MsgAlert("Nao foi possivel criar a planilha. Por favor, verifique se existe espaco em disco ou voce possui permissao de escrita no diretorio", "Erro de criacao de arquivo")
		ConOut("Nao foi possivel criar a planilha no diretorio")
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
	//cFile += "		<Table ss:ExpandedColumnCount=" + Chr(34) + AllTrim( Str( nFields ) ) + Chr(34) + " ss:ExpandedRowCount=" + Chr(34) + AllTrim( Str( Iif( lCabec, 1 + nRecords, nRecords ) ) ) + Chr(34) + " x:FullColumns=" + Chr(34) + "1" + Chr(34) + " x:FullRows=" + Chr(34) + "1" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "		<Table x:FullColumns=" + Chr(34) + "1" + Chr(34) + " x:FullRows=" + Chr(34) + "1" + Chr(34) + ">" + Chr(13) + Chr(10)
							
	/* Linha de Cabe�alho */
	If lCabec
		cFile += "			<Row>" + Chr(13) + Chr(10)
		For i := 1 To nFields
			cFile += "				<Cell><Data ss:Type=" + Chr(34) + "String" + Chr(34) + ">" + AllTrim(aCabec[i]) + "</Data></Cell>" + Chr(13) + Chr(10)
		Next
		cFile += "			</Row>" + Chr(13) + Chr(10)
	EndIf
			
	If nHandle >=0
	 FWrite(nHandle, cFile)
	 cFile := ""
	Endif
				
	For i := 1 To nRecords
		cFile += "			<Row>" + Chr(13) + Chr(10)
		For j := 1 To nFields
			cFile += "				" + ::FS_GetCell(aItens[i][j]) + Chr(13) + Chr(10)
		Next
		cFile += "			</Row>" + Chr(13) + Chr(10)
	 If (i % 100) == 0
	  If nHandle >=0
	   FWrite(nHandle, cFile)
		  cFile := ""
	  Endif
	 Endif
	Next
    
    if len(aResumos) > 0
		For i := 1 To len(aResumos)
			// Pula 1 linha
	    	cFile += "			<Row>" + Chr(13) + Chr(10)
			For j := 1 To nFields
				cFile += "				" + ::FS_GetCell(" ") + Chr(13) + Chr(10)
			Next
			cFile += "			</Row>" + Chr(13) + Chr(10)
			
			/* Cabecalho - Resumo */
			cFile += "			<Row>" + Chr(13) + Chr(10)
			For j := 1 To len(aResumos[i][1])
				cFile += "				<Cell><Data ss:Type=" + Chr(34) + "String" + Chr(34) + ">" + AllTrim(aResumos[i][1][j]) + "</Data></Cell>" + Chr(13) + Chr(10)
			Next
		    cFile += "			</Row>" + Chr(13) + Chr(10)
		    
			/* Item - Resumo */
			For j := 1 To len(aResumos[i][2])
				cFile += "			<Row>" + Chr(13) + Chr(10)				
				For k := 1 To len(aResumos[i][1])
					cFile += "				" + ::FS_GetCell(aResumos[i][2][j][k]) + Chr(13) + Chr(10)
				Next
			    cFile += "			</Row>" + Chr(13) + Chr(10)
				If (i % 100) == 0
					If nHandle >=0
						FWrite(nHandle, cFile)
						cFile := ""
					Endif
				Endif
			Next
		Next
	endIf
  
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
		MsgAlert("Nao foi possivel criar a planilha. Por favor, verifique se existe espaco em disco ou voce possui permissao de escrita no diretorio \system\", "Erro de criacao de arquivo")
		ConOut("Nao foi possivel criar a planilha no diretorio \system\")
	EndIf
	
Return cFileName


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GetCell�Autor  �     Microsiga      � Data �  18/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera arquivo no SX1                                        ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������	
*/

method FS_GetCell( xVar ) class TExConsulta
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
	           //<Cell ss:StyleID=              "s21"              ><Data ss:Type=              "DateTime"              >    2006                  -    12                    -    27                    T00:00:00.000</Data></Cell>
	 	if empty(xVar)
			cRet := "<Cell ss:StyleID=" + Chr(34) + "s21" + Chr(34) + " />"
	 	else
			cRet := "<Cell ss:StyleID=" + Chr(34) + "s21" + Chr(34) + "><Data ss:Type=" + Chr(34) + "DateTime" + Chr(34) + ">" + SubStr(xVar, 1, 4) + "-" + SubStr(xVar, 5, 2) + "-" + SubStr(xVar, 7, 2) + "T00:00:00.000</Data></Cell>"
		endIf
	Else
		cRet := "<Cell><Data ss:Type=" + Chr(34) + "Boolean" + Chr(34) + ">" + Iif ( xVar , "=VERDADEIRO" ,  "=FALSO" ) + "</Data></Cell>"
	EndIf

Return cRet

static function DataCocho(cLote)
local aArea := GetArea()
local dDataCo := SToD("")
DbUseArea(.t., "TOPCONN", TcGenQry(,,;
                          " select distinct min(B8_XDATACO) B8_XDATACO " +;
                            " from " + RetSqlName("SB8") +;
                           " where B8_LOTECTL = '" + cLote + "'" +; 
                             " and D_E_L_E_T_ = ' '";
                                     ), "TMPTBL", .f., .f.)
    dDataCo := SToD(TMPTBL->B8_XDATACO)
TMPTBL->(DbCloseArea())
RestArea(aArea)
return dDataCo
