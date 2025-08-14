#include "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*  IMPORTANTE - 10.12.2020
	* Para o correto funcionamento deste fonte, deve ser compilado o fonte: VACOMM11, 
	nele utilizamos a função: fChvITEM

	Fonte : CFATA00A
*/

#DEFINE	__EndLine	Chr(13) + Chr(10)
/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     27.02.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Preencher campos customizados em um conjunto de notas fiscais de saida.|
 |                                                                                  |
 | Obs.:     -                                                                      |
'----------------------------------------------------------------------------------*/
User Function VAFATB02(cAlias, nReg, nOpc)

	Local oDlg        := nil
	Local nGDOpc      := GD_INSERT + GD_UPDATE + GD_DELETE
	Local aSize       := {}
	Local aObjects    := {}
	Local aInfo       := {}
	Local aPObjs      := {}
	Local nOpcA       := 0
	Local aField      := {}
	Local oPesquisar  := nil
	Local oMGet1b     := nil

	Private oMGet1a   := nil
	Private cCadastro := "Atualização de Notas Fiscais de Saidas"
	Private aGets     := {}
	Private aTela     := {}
	Private oFont     := TFont():New('Trebuchet MS', , -14, , .T.)

	Private oSF2GDad  := nil, aSF2Head :={}, aSF2Cols := {}, nUSF2 := 0

	Private cDocDe    := CriaVar("F2_DOC" , .F. )
	Private cDocAte   := CriaVar("F2_DOC" , .F. )
	Private cDtEmDe   := CriaVar("F2_EMISSAO", .F. )
	Private cDtEmAte  := CriaVar("F2_EMISSAO", .F. )
	Private cDtAbate  := CriaVar("D2_XDTABAT", .F. )

	Private cNfEnt    := CriaVar("F2_X_NFENT", .F. )
	Private cSerEnt   := CriaVar("F2_XSERENT", .F. )
	Private cDtEnt    := CriaVar("F2_X_DTENT", .F. )
	Private nValEntr  := CriaVar("F2_VALMERC", .F. )
	Private nTotSaida := CriaVar("F2_VALMERC", .F. )
	Private nValComp  := CriaVar("F2_VALMERC", .F. )
	Private cMarcado  := "N"

	aSize := MsAdvSize( .T. )
	AAdd( aObjects, { 100 , 100, .T. , .T. , .F. } )
	AAdd( aObjects, { 100 , 100, .T. , .T. , .F. } )
	aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
	aPObjs := MsObjSize(aInfo, aObjects, .T., .F.)

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From 0,0 to aSize[6], aSize[5] PIXEL of oMainWnd
	// oDlg:lMaximized := .T.

	/* #################################################################################################################### */
	nPosAux := Round(aPObjs[1,4]/2,0)
	oGrp1a  := TGroup():New(aPObjs[1,1],aPObjs[1,2],aPObjs[1,3], nPosAux,"Filtro",oDlg,,, .T.,)

	aField := {}
	//              Titulo,        Campo,       Tipo, Tamanho,                 Decimal,                 Pict,                                       Valid,       	                 Obrigat, Nivel, Inic Padr, F3,    When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
	aAdd(aField, { "Doc. De"        , "cDocDe"    , "C", TamSX3("F2_DOC")[1]    , TamSX3("F2_DOC")[2]    , PesqPict("SF2", "F2_DOC")    ,  { || Vldfiltr(2), Valnota("cDocDe" ) }     , .F.,     1,      "",   "SF2",    "",   .F.,    .F.,   "",    ,     .F.,          "",      "N"} )
	aAdd(aField, { "Doc. Ate"       , "cDocAte"   , "C", TamSX3("F2_DOC")[1]    , TamSX3("F2_DOC")[2]    , PesqPict("SF2", "F2_DOC")    ,  { || Vldfiltr(2), Valnota("cDocAte") }     , .F.,     1,      "",   "SF2",    "",   .F.,    .F.,   "",    ,     .F.,          "",      "N"} )
	aAdd(aField, { "Dt. Emissao De" , "cDtEmDe"   , "D", TamSX3("F2_EMISSAO")[1], TamSX3("F2_EMISSAO")[2], PesqPict("SF2", "F2_EMISSAO"),  { || Vldfiltr(1) }                         , .F.,     1,      "",   ""   ,    "",   .F.,    .F.,   "",    ,     .F.,          "",      "N"} )
	aAdd(aField, { "Dt. Emissao Ate", "cDtEmAte"  , "D", TamSX3("F2_EMISSAO")[1], TamSX3("F2_EMISSAO")[2], PesqPict("SF2", "F2_EMISSAO"),  { || Vldfiltr(1) }                         , .F.,     1,      "",   ""   ,    "",   .F.,    .F.,   "",    ,     .F.,          "",      "N"} )
	aAdd(aField, { "Data Abate"     , "cDtAbate"  , "D", TamSX3("D2_XDTABAT")[1], TamSX3("D2_XDTABAT")[2], PesqPict("SD2", "D2_XDTABAT"), /* { || VldCpo(2) } */                      , .F.,     1,      "",   ""   ,    "",   .F.,    .F.,   "",    ,     .F.,          "",      "N"} )
	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador,joao.santos,vbuzaneli'   
		aAdd(aField, { "Mostra Marcados", "cMarcado"  , "C", 1                      , 0                      , "@!"                         ,                                             , .F.,     1,      "",   ""   ,    "",   .F.,    .F.,   "S=Sim;N=Não",    ,     .F.,          "",      "N"} )
	EndIf

	//oPnl1a  	 := tPanel():New(01,01,,oGrp1a,/* oTFont */,.T.,,/* CLR_YELLOW */, CLR_BLUE, 100, 100)
	//oPnl1a:align := CONTROL_ALIGN_ALLCLIENT
	oMGet1a 	 := MsMGet():New(,,nOpc,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,;
		{aPObjs[1,1]+7,aPObjs[1,2],aPObjs[1,3] / 1.2, nPosAux-1}/* {omGrp1a:nTOP,oGrp1a:nLEFT,oGrp1a:nBOTTOM,oGrp1a:nRIGHT} */ /* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, ;
		oGrp1a/* oGrp1a */,/*lF3*/,.T. /*lMemoria*/, .T. /*lColumn*/,/*caTela*/,/*lNoFolder*/,/*lProperty*/, ;
		aField,/* aFolder */,/*lCreate*/, /*lNoMDIStretch*/,/*cTela*/)
	//oMGet1a:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	oPesquisar := TButton():New( (aPObjs[1,3] / 1.2)+5/* aPObjs[1,1]-90 */, nPosAux-150, "Localizar Notas Fiscais" , ;
				oGrp1a , {|| MsgRun("Consultando informacoes...",;
									 "Processando",;
							 		{|| fPesquisar() } ) },70,10,,,.F.,.T.,.F.,,.F.,,,.F.)
	oPesquisar:SetCss("QPushButton{ background: #0B0; color: #FFF; background-repeat: none; margin: 2px; font-weight: bold; }")

	/* #################################################################################################################### */
	oGrp1b := TGroup():New(aPObjs[1,1],nPosAux+2,aPObjs[1,3],aPObjs[1,4],"Dados da Nota Fiscal de Enrada",oDlg,,, .T.,)

	//aField := {}
	////              Titulo,        Campo,       Tipo, Tamanho,                 Decimal,                 Pict,                          Valid,       	       Obrigat, Nivel, Inic Padr, F3, When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
	//aAdd(aField, { "NF. Origem"     , "cNfEnt" , "C", TamSX3("F2_X_NFENT")[1], TamSX3("F2_X_NFENT")[2], PesqPict("SF2", "F2_X_NFENT"), /* { || VldCpo(2) } */, .F.,     1,     "",        "", "",   .F.,    .F.,   "",    ,     .F.,          "",      "N"} )
	//aAdd(aField, { "Serie Origem"   , "cSerEnt", "C", TamSX3("F2_XSERENT")[1], TamSX3("F2_XSERENT")[2], PesqPict("SF2", "F2_XSERENT"), /* { || VldCpo(2) } */, .F.,     1,     "",        "", "",   .F.,    .F.,   "",    ,     .F.,          "",      "N"} )
	//aAdd(aField, { "Data NF Entrada", "cDtEnt" , "D", TamSX3("F2_X_DTENT")[1], TamSX3("F2_X_DTENT")[2], PesqPict("SF2", "F2_X_DTENT"), /* { || VldCpo(2) } */, .F.,     1,     "",        "", "",   .F.,    .F.,   "",    ,     .F.,          "",      "N"} )

	//oPnl1b  	 := tPanel():New(nPosAux+1,nPosAux+1,,oGrp1b,/* oTFont */,.T.,,/* CLR_YELLOW */, /* CLR_RED */, 100, 100)
	//oPnl1b:align := CONTROL_ALIGN_ALLCLIENT
	//oMGet1b 	 := MsMGet():New(,,3,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,;
	//					{aPObjs[1,1]+7,nPosAux+2,aPObjs[1,3]-1,aPObjs[1,4]-1}/* {oGrp1b:nTOP,oGrp1b:nLEFT,oGrp1b:nBOTTOM,oGrp1b:nRIGHT} */ /* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, ;
	//					oGrp1b/* oGrp1b */,/*lF3*/,.T./*lMemoria*/,.T./*lColumn*/,/*caTela*/,/*lNoFolder*/,/*lProperty*/, ;
	//					aField,/* aFolder */,/*lCreate*/, /*lNoMDIStretch*/,/*cTela*/)
	//oMGet1b:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	nSuperior := aPObjs[1,1] + 10
	nEsquerda := nPosAux + 12
	oTit1  := tSay():New(nSuperior, nEsquerda,{||'NF. Origem: ' }, oGrp1b,,oFont,,,,.T.,,,200,100)
	@nSuperior,nEsquerda+65 MSGET oNfEnt VAR cNfEnt PICTURE PesqPict("SF2", "F2_X_NFENT") /* F3 "ZZM" */ SIZE 050,010 OF oGrp1b PIXEL HASBUTTON VALID ValNota("cNfEnt")

	nSuperior += 25
	oTit1  := tSay():New(nSuperior, nEsquerda,{||'Serie Origem: ' }, oGrp1b,,oFont,,,,.T.,,,200,100)
	@nSuperior,nEsquerda+65 MSGET oSerEnt VAR cSerEnt PICTURE PesqPict("SF2", "F2_XSERENT") /* F3 "ZZM" */ SIZE 050,010 OF oGrp1b PIXEL HASBUTTON
	
	nSuperior += 25
	oTit1  := tSay():New(nSuperior, nEsquerda,{||'Data NF Entrada: ' }, oGrp1b,,oFont,,,,.T.,,,200,100)
	@nSuperior,nEsquerda+65 MSGET oDtEnt VAR cDtEnt PICTURE PesqPict("SF2", "F2_X_DTENT") /* F3 "ZZM" */ SIZE 050,010 OF oGrp1b PIXEL HASBUTTON
	
	nSuperior += 25
	oTit1  := tSay():New(nSuperior, nEsquerda,{||'Valor NF Entrada: ' }, oGrp1b,,oFont,,,,.T.,,,200,100)
	@nSuperior,nEsquerda+65 MSGET oValEntr VAR nValEntr PICTURE PesqPict("SF2", "F2_VALMERC") /* F3 "ZZM" */ SIZE 080,010 OF oGrp1b PIXEL HASBUTTON VALID AtuVlrSel()
	
	// nSuperior += 25
	oTit1  := tSay():New(nSuperior, (nEsquerda+65)*2.5,{||'Total NFs Saida Selecionada: ' }, oGrp1b,,oFont,,,,.T.,,,200,100)
	@nSuperior,(nEsquerda+65)*4 MSGET oTotSaida VAR nTotSaida PICTURE PesqPict("SF2", "F2_VALMERC") WHEN .F. /* F3 "ZZM" */ SIZE 080,010 OF oGrp1b PIXEL HASBUTTON
	
	nSuperior += 25
	oTit1  := tSay():New(nSuperior, nEsquerda,{||'Valor Nota Complementar: ' }, oGrp1b,,oFont,,,,.T.,,,200,100)
	@nSuperior,nEsquerda+95 MSGET oValComp VAR nValComp PICTURE PesqPict("SF2", "F2_VALMERC") WHEN .F. /* F3 "ZZM" */ SIZE 080,010 OF oGrp1b PIXEL HASBUTTON

	/* #################################################################################################################### */
	oGrp2  := TGroup():New(aPObjs[2,1],aPObjs[2,2],aPObjs[2,3],aPObjs[2,4],"Notas Fiscais de Saida",oDlg,,, .T.,)

	//AAdd(aSF2Head, { " ", Padr("SF2_MARK", 10), "@BMP", 1, 0, .F., "", "C", "", "V", "", "", "", "V", "", "", "" } )
	CargaDados( "SF2", @aSF2Head, @aSF2Cols, @nUSF2, 1, , nil ) // loadDados, CarregaDados
	nPMrkSF2  := aScan( aSF2Head, { |x| AllTrim(x[2]) == 'SF2_MARK'})
	aSF2Cols[ 1, nPMrkSF2] := "LBNO"
	oSF2GDad := MsNewGetDados():New( aPObjs[2,1]+7,aPObjs[2,2],aPObjs[2,3]-1,aPObjs[2,4]-1, nGDOpc, , , /* "+SF2_ITEM" */ , , , , , , /* "u_SF2DelOk()" */, oGrp2, aClone(aSF2Head), aClone( aSF2Cols ) )
	//oSF2GDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	// oSF2GDad:oBrowse:BlDblClick := { || If( oSF2GDad:oBrowse:nColPos == nPMrkSF2 /* .and. fCanSelIC() */, (U_SetMark(oSF2GDad, , nPMrkSF2, "ALL").and.AtuVlrSel()), oSF2GDad:EditCell() ) }
	oSF2GDad:oBrowse:BlDblClick := { || (U_SetMark(oSF2GDad, , nPMrkSF2, "ALL").and.AtuVlrSel()) }
	oSF2GDad:Disable()

	//oMGet1a:SetFocus()
	ACTIVATE MSDIALOG oDlg ;
		ON INIT EnchoiceBar(oDlg,;
		{ || nOpcA := 1, Iif(Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)},;
		{ || nOpcA := 0, oDlg:End() },, /* aButtons */ )
	If nOpcA == 1
		GravaNota()
	EndIf

Return nil

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  AtuVlrSel 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  08.12.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function AtuVlrSel(  )

	If ReadVar() <> Upper("nValEntr")
		if oSF2GDad:aCols[oSF2GDad:oBrowse:nAt, nPMrkSF2] == 'LBTIK'
			nTotSaida += oSF2GDad:aCols[oSF2GDad:oBrowse:nAt, aScan( oSF2GDad:aHeader, { |x| AllTrim(x[2]) == 'F2_VALMERC'})]
		Else
			//if nTotSaida >= oSF2GDad:aCols[oSF2GDad:oBrowse:nAt, aScan( oSF2GDad:aHeader, { |x| AllTrim(x[2]) == 'F2_VALMERC'})]
				nTotSaida -= oSF2GDad:aCols[oSF2GDad:oBrowse:nAt, aScan( oSF2GDad:aHeader, { |x| AllTrim(x[2]) == 'F2_VALMERC'})]
			//EndIfbernardo
		Endif
		oTotSaida:Refresh()
	EndIf
	nValComp := ABS( nValEntr-nTotSaida )
	oValComp:Refresh()
Return nil

/* MJ : 05.03.2018 */
Static Function VldCpo()
	Local lRet := .T.
	// validar campos
	If !(lRet := !Empty(oNfEnt))
		MsgInfo('Campo NF. Origem nao encontrada. <br>A mesmo é obrigatorio para preenchimentos nas NF. Saidas que foram selecionadas.')
	ElseIf !(lRet := !Empty(cSerEnt))
		MsgInfo('Campo Serie Origem nao encontrada. <br>A mesmo é obrigatorio para preenchimentos nas NF. Saidas que foram selecionadas.')
	ElseIf !(lRet := !Empty(cDtEnt))
		MsgInfo('Campo Data de Entrada nao encontrada. <br>A mesmo é obrigatorio para preenchimentos nas NF. Saidas que foram selecionadas.')
	EndIf

Return lRet

/* MJ: 01.03.2018
Transformado em User Function */
User Function SetMark(oGD, nLinha, nColuna, cTipo)
	Local lMark
	Local i
	Local nLen  	:= Len(oGD:aCols)

	Default nLinha  := oGD:nAt
	Default cTipo	:= "ONE" // "ALL"
	//Default nColuna	:= 0

	lMark := oGD:aCols[nLinha, nColuna] == 'LBNO'

	If cTipo == "ONE"
		oGD:aCols[nLinha, nColuna] := Iif(lMark, 'LBTIK', 'LBNO')
		If lMark
			For i := 1 To nLen
				If i != nLinha .and. oGD:aCols[i, nColuna] == 'LBTIK'
					oGD:aCols[i, nColuna] := 'LBNO'
				EndIf
			Next
		EndIf
	Else
		oGD:aCols[nLinha, nColuna] := Iif(lMark, 'LBTIK', 'LBNO')
	EndIf

	oGD:Refresh()

Return .T.


/* MJ : 02.03.2018
# Procesa filtro e atualiza Grid. */
Static Function fPesquisar()
	Local cCond    := ""
	Local aSF2     := {"F2_DOC    ", "F2_SERIE  ", "F2_EMISSAO", "F2_CLIENTE", "F2_LOJA   "}
	Local nSf2     := 0
	Local cSql     := ""
	Local nUsado   := 0
	Local nPMrkSF2 := 1
	Local aItem    := {}
	Local cCondD2  := ""
	Local nI       := 0
	// Zerar ao atualizar
	nTotSaida := 0

	If !Empty(cDocDe) .or. !Empty(cDocAte)
		cCond += Iif(Empty(cCond),""," AND ") + " F2_DOC BETWEEN '"+cDocDe+"' AND '"+cDocAte+"'
	EndIf
	If !Empty(cDtEmDe) .or. !Empty(cDtEmAte)
		cCond += Iif(Empty(cCond),""," AND ") + " F2_EMISSAO BETWEEN '"+dToS(cDtEmDe)+"' AND '"+dToS(cDtEmAte)+"'
	EndIf
	If !Empty(cDtAbate)
		cCondd2 := Iif(Empty(cCondd2),""," AND ") + " D2_XDTABAT = '"+dToS(cDtAbate)+"'
	EndIf

	aSF2Cols := {}//
	aSF2Head := {}

	cSql := "WITH PRINCIPAL AS(" + __EndLine
	cSql += " SELECT DISTINCT F2_TIPO TIPO, " + RetSqlName("SF2")+".R_E_C_N_O_ " + __EndLine
	cSql += "  FROM " + RetSqlName("SF2") + " " + __EndLine
	If Empty(cCondd2)
		cSql += " JOIN " + RetSqlName("SD2")+ " ON "  + __EndLine
		cSql += "		"+ RetSqlName("SD2")+".D_E_L_E_T_ <> '*' "  + __EndLine
		cSql += "	AND D2_FILIAL = F2_FILIAL "  + __EndLine
		cSql += "	AND D2_DOC = F2_DOC "  + __EndLine
		cSql += "	AND F2_SERIE = F2_SERIE "  + __EndLine
		cSql += "  " + cCondd2  + " " + __EndLine
	EndIf
	cSql += "  WHERE   F2_FILIAL='" + xFilial("SF2") +"' " + __EndLine
	If !Empty(cCond)
		cSql += "   AND " + cCond + " " + __EndLine
	EndIf
	cSql += "   AND F2_TIPO = 'N' " + __EndLine
	
	If Type("cMarcado") <> "U" .and. cMarcado=="N"
		cSql += "   AND F2_X_NFENT=' ' " + __EndLine
	EndIf

	cSql += "   AND "+RetSqlName("SF2")+".D_E_L_E_T_=' ' " + __EndLine
	cSql += " ), " + __EndLine

	cSql += " COMPLEMENTO AS " + __EndLine
	cSql += " ( " + __EndLine
	cSql += "  SELECT DISTINCT F2_TIPO TIPO, F.R_E_C_N_O_ " + __EndLine
	cSql += "  FROM "+RetSqlName("SF2")+" F " + __EndLine
	cSql += "  JOIN "+RetSqlName("SD2")+" D ON F2_FILIAL=D2_FILIAL AND F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE AND F2_CLIENTE=D2_CLIENTE AND F2_SERIE=D2_SERIE AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' ' " + __EndLine
	cSql += "  WHERE F2_TIPO = 'C' " + __EndLine
	cSql += "    AND D2_FILIAL+D2_NFORI+D2_SERIORI+D2_CLIENTE+D2_LOJA IN " + __EndLine
	cSql += "     ( " + __EndLine
	cSql += "          SELECT F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA " + __EndLine
	cSql += "      FROM "+RetSqlName("SF2")+" F " + __EndLine
	cSql += "      JOIN PRINCIPAL P ON F.R_E_C_N_O_=P.R_E_C_N_O_ AND F.D_E_L_E_T_=' ' " + __EndLine
	cSql += "     ) " + __EndLine
	cSql += " ), " + __EndLine

	cSql += " TODOS AS " + __EndLine
	cSql += " ( " + __EndLine
	cSql += "  SELECT * FROM PRINCIPAL " + __EndLine
	cSql += "  UNION " + __EndLine
	cSql += "  SELECT * FROM COMPLEMENTO " + __EndLine
	cSql += " ) " + __EndLine

	cSql += " SELECT TIPO, * " + __EndLine
	cSql += " FROM "+RetSqlName("SF2")+" F2 " + __EndLine
	cSql += " JOIN TODOS   T ON T.R_E_C_N_O_ = F2.R_E_C_N_O_ " + __EndLine
	cSql += " ORDER BY 3 " + __EndLine

	If Select("TMPSF2") > 0
		TMPSF2->(dbCloseArea())
	EndIf
	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
		MEMOWRITE("C:\TOTVS_RELATORIOS\VAFATB02 - fPesquisar.SQL", cSql)
	EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TMPSF2",.T.,.T.)

	TCSetField("TMPSF2", "F2_EMISSAO", "D", 08, 00)
	TCSetField("TMPSF2", "F2_X_DTENT", "D", 08, 00)
	TCSetField("TMPSF2", "F2_EMINFE ", "D", 08, 00)
	TCSetField("TMPSF2", "F2_DTDIGIT", "D", 08, 00)
	TCSetField("TMPSF2", "F2_DTTXREF", "D", 08, 00)
	TCSetField("TMPSF2", "F2_DTESERV", "D", 08, 00)
	TCSetField("TMPSF2", "F2_XDTABAT", "D", 08, 00)
	TCSetField("TMPSF2", "F2_DAUTNFE", "D", 08, 00)

	If !TMPSF2->(EOF())
		//Monta o aHeader do grid conforme os campos definidos no array aSF2 (apenas os campos que deseja)
		//Caso contrário, se quiser todos os campos é necessário trocar o "For" por While, para que este faça a leitura de toda a tabela
		DbSelectArea("SX3")
		SX3->(DbSetOrder(1))
		SX3->(dbSeek("SF2"))

		aSF2Head:={}
		AAdd(aSF2Head, { " ", Padr("SF2_MARK", 10), "@BMP", 1, 0, .F., "", "C", "", "V", "", "", "", "V", "", "", "" } )
		While SX3->X3_ARQUIVO == "SF2" .AND. !SX3->(EOF())
			If (X3USO(SX3->X3_USADO)  .AND. CNIVEL >= SX3->X3_NIVEL .AND. SX3->X3_CONTEXT # "V") .OR.;
					(SX3->X3_PROPRI == "U" .AND. SX3->X3_CONTEXT!="V" .AND. SX3->X3_TIPO <> 'M')
				nUsado:=nUsado+1
				Aadd(aSF2Head, {TRIM(X3_TITULO), X3_CAMPO , X3_PICTURE, X3_TAMANHO, X3_DECIMAL,X3_VALID, X3_USADO  , X3_TIPO   , X3_ARQUIVO, X3_CONTEXT})
			Endif
			SX3->(dbSkip())
		EndDo
		While !TMPSF2->(EOF())
			aItem := {}
			For nSf2 := 1 to Len(aSF2Head)
				If aSf2Head[nSf2][2] == "SF2_MARK  "
					AAdd(aItem,"LBNO")
				Else
					AAdd(aItem,&("TMPSF2->"+aSf2Head[nSf2][2]))
				EndIf
			Next nSf2
			AAdd(aItem,.F.)
			AAdd(aSF2Cols,aItem)
			TMPSF2->(dbSkip())
		EndDo
	EndIf
	TMPSF2->(DBCloseArea()) // essa linha precisa validar a necessidade dela MB : 10/12/2020

	//	U_BDados( "SF2", @aSF2Head, @aSF2Cols, @nUSF2, 1, , cCond )
	For nI := 1 to Len(aSF2Cols)
		If Empty( aSF2Cols[ nI, nPMrkSF2] )
			aSF2Cols[ nI, nPMrkSF2] := "LBNO"
		EndIf
	Next nI
	oSF2GDad:Enable()
	//oSF2GDad:aCols := {}
	oSF2GDad:aHeader := aClone(aSF2Head)
	oSF2GDad:aCols := aClone(aSF2Cols)
	oSF2GDad:Refresh()

Return nil

Static Function Valnota(cCampo)
	If cCampo == "cNfEnt"
		cNfEnt := StrZero(Val(cNfEnt),TamSX3('F2_DOC')[1])
		oNfEnt:Refresh()
	ElseIf cCampo == "cDocDe"
		cDocDe := StrZero(Val(cDocDe),TamSX3('F2_DOC')[1])
		oMGet1a:Refresh()
	ElseIf cCampo == "cDocAte"
		cDocAte := StrZero(Val(cDocAte),TamSX3('F2_DOC')[1])
		oMGet1a:Refresh()		
	EndIf
Return .T.

Static Function Vldfiltr(nOpt)

	If nOpt == 1	//Documento de e até
		If !Empty(cDocDe) .OR. !Empty(cDocAte)
			If !Empty(cDtEmDe) .OR. !Empty(cDtEmAte)
				cDtEmDe := CTOD("//")
				cDtEmAte := CTOD("//")
				MsgInfo("Voce não pode preencher Documento De/Ate e Data de emissão!", "Atenção!" )
			EndIf
		Endif
	ElseIf nOpt == 2
		If !Empty(cDtEmDe) .OR. !Empty(cDtEmAte)
			If !Empty(cDocDe) .OR. !Empty(cDocAte)
				cDocDe := ""
				cDocAte := ""
				MsgInfo("Voce não pode preencher Documento De/Ate e Data de emissão!", "Atenção!" )
			EndIf
		Endif
	EndIf

Return .T.

Static Function CargaDados( cArqTemp, aSF2Head, aSF2Cols)
	local nUsado := 0
	Local nI     := 0
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(dbSeek("SF2"))

	aSF2Head:={}
	AAdd(aSF2Head, { " ", Padr("SF2_MARK", 10), "@BMP", 1, 0, .F., "", "C", "", "V", "", "", "", "V", "", "", "" } )
	While SX3->X3_ARQUIVO == "SF2" .AND. !SX3->(EOF())
		If (X3USO(SX3->X3_USADO)  .AND. CNIVEL >= SX3->X3_NIVEL .AND. SX3->X3_CONTEXT # "V") .OR.;
				(SX3->X3_PROPRI == "U" .AND. SX3->X3_CONTEXT!="V" .AND. SX3->X3_TIPO <> 'M')
			nUsado:=nUsado+1
			Aadd(aSF2Head, {TRIM(X3_TITULO), X3_CAMPO , X3_PICTURE, X3_TAMANHO, X3_DECIMAL,X3_VALID, X3_USADO  , X3_TIPO   , X3_ARQUIVO, X3_CONTEXT})
		Endif
		SX3->(dbSkip())
	EndDo

	aAdd( aSF2Cols, Array( Len( aSf2Head ) + 1 ) )
	For nI := 1 To Len( aSF2Head )
		If aSf2Head[nI][2] == "SF2_MARK  "
			aSF2Cols[1, nI] := "LBNO"
		Else
			aSF2Cols[1, nI] := CriaVar( aSF2Head[nI, 2], .T. )
		EndIf
	Next nI

Return Nil

Static Function GravaNota()
	Local nSf2Mark  :=  aScan( oSF2GDad:aHeader, { |x| AllTrim(x[2]) == 'SF2_MARK'})
	Local nSf2Doc   :=  aScan( oSF2GDad:aHeader, { |x| AllTrim(x[2]) == 'F2_DOC'})
	Local nSf2Serie :=  aScan( oSF2GDad:aHeader, { |x| AllTrim(x[2]) == 'F2_SERIE'})
	Local nSf2      := 0

	If !Empty(cNfEnt) .AND. !Empty(cSerEnt) .AND. !Empty(cDtEnt)

		For nSf2 := 1 to Len(oSF2GDad:aCols)
			If oSf2GDad:aCols[nSf2][nSf2Mark] == "LBTIK"
				dbSelectArea("SF2")
				dbSetOrder(1)

				If dbSeek(xFilial("SF2")+ oSf2GDad:aCols[nSf2][nSf2Doc]+oSf2GDad:aCols[nSf2][nSf2Serie])
					If Empty(SF2->F2_X_NFENT) .AND. Empty(SF2->F2_XSERENT) .AND. Empty(SF2->F2_X_DTENT)
						RecLock("SF2",.F.)
							SF2->F2_X_NFENT := cNfEnt
							SF2->F2_XSERENT := cSerEnt
							SF2->F2_X_DTENT := cDtEnt
						SF2->(msUnlock())
					Else
						If SF2->F2_X_NFENT <> cNfEnt  .OR. SF2->F2_XSERENT <> cSerEnt .OR. SF2->F2_X_DTENT <> cDtEnt
							If MsgYesNo("Nota: "+SF2->F2_DOC+" já relacionada anteriormente."+CRLF+"Relacionar novamente?", "Atenção !!")
								RecLock("SF2",.F.)
									SF2->F2_X_NFENT := cNfEnt
									SF2->F2_XSERENT := cSerEnt
									SF2->F2_X_DTENT := cDtEnt
								SF2->(msUnlock())
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Next

		If nValEntr > nTotSaida .and.;
				 MsgYesNo("Deseja gerar Pedido de Venda para complementar o valor de: " +;
				 			AllTrim(Transform( nValEntr-nTotSaida, X3Picture("C6_VALOR") )),;
							"Atenção !!")
			Begin Transaction
				SC5ExecAuto( nValEntr-nTotSaida )
			End Transaction
		EndIf

	Else
		MsgStop("Preencher os 3 Campos da nota de entrada a serem Gravados !", "ATENÇÃO !!!")
	EndIf

Return(.T.)

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  SC5ExecAuto	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  08.12.2020                                                              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function SC5ExecAuto( nComplemento )
	Local aArea        := GetArea()
	Local cDoc         := ""
	Local aProdutos    := {}
	Local lErro        := .F.

	Local nRegistros   := 0
	Local nI           := 0
	Local nSomaValores := 0

	Private cE1HIST    := ""

	_cQry := " WITH " + CRLF
	_cQry += " TIPO_N AS ( " + CRLF
	_cQry += " 	SELECT	  D2_FILIAL " + CRLF
	_cQry += " 			, D2_DOC " + CRLF
	_cQry += " 	        , D2_SERIE " + CRLF
	_cQry += " 			, D2_EMISSAO " + CRLF
	_cQry += " 			, D2_CLIENTE " + CRLF
	_cQry += " 			, D2_LOJA " + CRLF
	_cQry += " 			, D2_PEDIDO " + CRLF
	_cQry += " 			, F2_X_NFENT " + CRLF
	_cQry += " 			, F2_TIPO " + CRLF
	_cQry += " 			, D2_ITEM " + CRLF
	_cQry += " 			, D2_COD " + CRLF
	_cQry += " 			, D2_LOCAL " + CRLF
	_cQry += " 			, D2_LOTECTL " + CRLF
	_cQry += " 			, D2_QUANT " + CRLF
	_cQry += " 			, D2_TOTAL " + CRLF
	_cQry += " 	FROM	SF2010 F " + CRLF
	_cQry += " 	   JOIN SD2010 D ON F2_FILIAL = D2_FILIAL AND F2_CLIENTE = D2_CLIENTE  AND F2_LOJA = D2_LOJA AND F2_DOC = D2_DOC  " + CRLF
	_cQry += " 				    AND F2_SERIE = D2_SERIE   AND F2_EMISSAO = D2_EMISSAO  AND F.D_E_L_E_T_ = ' ' AND D.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	WHERE	F2_TIPO='N' " + CRLF
	_cQry += " 		AND F2_X_NFENT = '" + cNfEnt       + "' " + CRLF
    _cQry += " 		AND F2_XSERENT = '" + cSerEnt      + "' " + CRLF
    _cQry += " 		AND F2_X_DTENT = '" + dToS(cDtEnt) + "' " + CRLF
	_cQry += " )" + CRLF
	_cQry += CRLF
	_cQry += " , TIPO_C AS ( " + CRLF
	_cQry += " 	SELECT	F2_X_NFENT " + CRLF
	_cQry += " 			, F2_TIPO " + CRLF
	_cQry += " 			, D2_EMISSAO " + CRLF
	_cQry += " 			, D2_TOTAL " + CRLF
	_cQry += " 	FROM	SF2010 F " + CRLF
	_cQry += " 	   JOIN SD2010 D ON F2_FILIAL = D2_FILIAL AND F2_CLIENTE = D2_CLIENTE  AND F2_LOJA = D2_LOJA AND F2_DOC = D2_DOC  " + CRLF
	_cQry += " 					AND F2_SERIE = D2_SERIE   AND F2_EMISSAO = D2_EMISSAO  AND F.D_E_L_E_T_ = ' ' AND D.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 	WHERE	F2_TIPO='C' " + CRLF
	_cQry += " 		AND F2_X_NFENT = '" + cNfEnt       + "' " + CRLF
    _cQry += " 		AND F2_XSERENT = '" + cSerEnt      + "' " + CRLF
    _cQry += " 		AND F2_X_DTENT = '" + dToS(cDtEnt) + "' " + CRLF
	_cQry += " ) " + CRLF
	_cQry += CRLF
	_cQry += " , DADOS AS ( " + CRLF
	_cQry += "      SELECT    N.D2_FILIAL " + CRLF
	_cQry += "      		, N.D2_DOC " + CRLF
	_cQry += "      	    , N.D2_SERIE " + CRLF
	_cQry += "      		, N.D2_CLIENTE " + CRLF
	_cQry += "      		, N.D2_LOJA " + CRLF
	_cQry += "              , N.F2_X_NFENT " + CRLF
	_cQry += "      		, N.F2_TIPO F2_TIPON " + CRLF
	_cQry += "      		, N.D2_EMISSAO D2_EMISSAON " + CRLF
	_cQry += "      		, N.D2_PEDIDO " + CRLF
	_cQry += "      		, N.D2_ITEM " + CRLF
	_cQry += "      		, N.D2_COD " + CRLF
	_cQry += "      		, N.D2_LOCAL " + CRLF
	_cQry += "      		, D2_LOTECTL " + CRLF
	_cQry += "      		, N.D2_QUANT " + CRLF
	_cQry += "      		, N.D2_TOTAL D2_TOTALN " + CRLF
	_cQry += "      		, C.F2_TIPO F2_TIPOC " + CRLF
	_cQry += "      		, C.D2_EMISSAO D2_EMISSAOC " + CRLF
	_cQry += "      		, ISNULL(C.D2_TOTAL,0) D2_TOTALC " + CRLF
	_cQry += "      		, N.D2_TOTAL+ISNULL(C.D2_TOTAL,0) TOTAL_NF " + CRLF  // _cQry += " 		, " + cValToChar(TMPSQL->GERAR_COMPL) + "-(N.D2_TOTAL+ISNULL(C.D2_TOTAL,0)) GERAR_COMPL " + CRLF
	_cQry += "		FROM	  TIPO_N N " + CRLF
	_cQry += "			LEFT JOIN TIPO_C C ON N.F2_X_NFENT=C.F2_X_NFENT " + CRLF
    _cQry += " ) " + CRLF
    _cQry += CRLF
    _cQry += " , TOTAL_NF_GERAL AS ( " + CRLF
    _cQry += "	 	SELECT  -- COUNT(*) QTD_REGISTRO,  " + CRLF
    _cQry += "	 			SUM(TOTAL_NF) TOTAL_NF_GERAL " + CRLF
    _cQry += "	 	FROM DADOS " + CRLF
    _cQry += " ) " + CRLF
    _cQry += CRLF
    // _cQry += " SELECT  *, ROUND('" + cValToChar(nValEntr-nTotSaida) + "'*(( TOTAL_NF*100)/TOTAL_NF_GERAL/100), 2) GERAR_COMPL " + CRLF
    _cQry += " SELECT  *, ROUND('" + cValToChar(nValEntr-nTotSaida) + "'*(( TOTAL_NF*100)/TOTAL_NF_GERAL/100), " + cValToChar(TamSx3("C6_VALOR")[2]) + ") GERAR_COMPL " + CRLF
    _cQry += " FROM	   DADOS " + CRLF
    _cQry += " CROSS JOIN TOTAL_NF_GERAL " + CRLF
    _cQry += CRLF
    _cQry += " ORDER BY 1, 2, 3, 4, 11 " + CRLF

	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
		MEMOWRITE("C:\TOTVS_RELATORIOS\VAFATB02 - gerar pedido de vendas - SC5.SQL", _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TMPSQL",.F.,.F.)
	TMPSQL->(DbEval({|| nRegistros++ }))
	TMPSQL->( DbGoTop() )

	cDoc := TMPSQL->D2_DOC
	While (!TMPSQL->(EOF())) .AND. !lErro
		If TMPSQL->GERAR_COMPL > 0

			nI += 1

			aAdd( aProdutos, {} )
			aAdd( aTail(aProdutos), TMPSQL->D2_FILIAL  ) // 01
			aAdd( aTail(aProdutos), TMPSQL->D2_ITEM    ) // 02
			aAdd( aTail(aProdutos), TMPSQL->D2_COD     ) // 03

			If nI < nRegistros
				aAdd( aTail(aProdutos), TMPSQL->GERAR_COMPL) // 04
			Else
				aAdd( aTail(aProdutos), Round(nComplemento - nSomaValores, TamSx3("C6_VALOR")[2]) ) // 04
			EndIf

			aAdd( aTail(aProdutos), TMPSQL->D2_DOC     ) // 05
			aAdd( aTail(aProdutos), TMPSQL->D2_SERIE   ) // 06
			aAdd( aTail(aProdutos), TMPSQL->D2_LOTECTL ) // 07
			aAdd( aTail(aProdutos), TMPSQL->D2_CLIENTE ) // 08
			aAdd( aTail(aProdutos), TMPSQL->D2_LOJA    ) // 09
			aAdd( aTail(aProdutos), TMPSQL->D2_LOCAL   ) // 10
			
			nSomaValores += TMPSQL->GERAR_COMPL
		EndIf

		cDoc := TMPSQL->D2_DOC
		TMPSQL->(DbSkip())
		If Len(aProdutos)>0
			If cDoc <> TMPSQL->D2_DOC .or. TMPSQL->(EOF())
				// ConOut( cText := SC5->C5_NUM )
				MsgRun("Gerando Pedido de Venda, Aguarde...","",;
						{|| CursorWait(), lErro := ExecSC5Auto( aProdutos ),CursorArrow()})
				// ConOut( cText := SC5->C5_NUM )
				aProdutos := {}
			EndIf
		EndIf
	EndDo
	TMPSQL->(DBCloseArea())

RestArea(aArea)
Return nil

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  SC5ExecAuto	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  08.12.2020                                                              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function ExecSC5Auto( aProdutos )
Local aArea            := GetArea()
Local aErroAuto        := {}
Local aCabPV           := {}
Local aItemPV          := {}
Local nI               := 0
Local lErro            := .F.
Local nCount           := 0
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .F.

	SA1->( DbSetOrder(1) )
	If SA1->( DbSeek( xFilial("SA1") + aProdutos[01, 08] + aProdutos[01, 09] ) )
		
		cNumPed := U_fChvITEM( "SC5", , "C5_NUM" )	//cNumPed := GetSxeNum("SC5", "C5_NUM")

		aCabPV  := {{ "C5_FILIAL", aProdutos[01, 01], Nil },; 
					{"C5_NUM"    , cNumPed     , Nil},;
					{"C5_TIPO"   , "C"         , Nil},;
					{"C5_CLIENTE", SA1->A1_COD , Nil},;
					{"C5_LOJACLI", SA1->A1_LOJA, Nil},;
					{"C5_TPFRETE", "S"         , Nil},;
					{"C5_MENPAD" , "001"       , Nil},;
					{"C5_CONDPAG", "001"       , Nil }}
	
		For nI := 1 to len(aProdutos)
			aProdutos[nI, 02] := strZero(nI,TamSx3("C6_ITEM")[1])
			AADD(aItemPV, { { "C6_FILIAL", aProdutos[nI, 01]          , Nil},;
							{"C6_NUM"    , cNumPed                    , Nil},;
							{"C6_ITEM"   , aProdutos[nI, 02]          , Nil},;
							{"C6_PRODUTO", aProdutos[nI, 03]          , Nil},;
							{"C6_QTDVEN" , 0                          , Nil},;
						 	{"C6_PRCVEN" , aProdutos[nI, 04]          , Nil},;
							{"C6_VALOR"  , aProdutos[nI, 04]          , Nil},;
							{"C6_TES"    , GetMV( "MB_FATB02A",,"501"), Nil},;
							{"C6_NFORI"  , aProdutos[nI, 05]          , Nil},;
							{"C6_SERIORI", aProdutos[nI, 06]          , Nil},;
							{"C6_LOTECTL", aProdutos[nI, 07]          , Nil},;
							{"C6_LOCAL"  , aProdutos[nI, 10]          , Nil}} )
		Next nI

		lMsErroAuto := .F.
		// https://tdn.totvs.com/pages/releaseview.action?pageId=6784012
		
		while !LockByName("ExecSC5Auto"+cNumPed, .t., .f.)
			Sleep(500)
		end
			MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItemPV,3)
		UnlockByName("ExecSC5Auto"+cNumPed)
	
		If lMSErroAuto
			MostraErro() 
			aErroAuto := GetAutoGRLog()
			For nCount := 1 To Len(aErroAuto)
				cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
				ConOut(cLogErro)
				Alert(cLogErro)
			Next nCount
			DisarmTransaction()
		Else

			cFilEnt	:= SC5->C5_FILIAL
			cPedVen	:= SC5->C5_NUM
			If lErro := U_LIBeFaturar( cFilEnt,  @cPedVen, @cE1HIST )
				DisarmTransaction()
			Else
				MsgInfo( "Pedido de Venda [" + cNumPed + "] gerado com sucesso !!!" + CRLF +;
						 "Nota Fiscal [" + SF2->F2_FILIAL+"-"+AllTrim(SF2->F2_DOC)+"-"+AllTrim(SF2->F2_SERIE) + "] faturada com sucesso" )
			EndIf

			// While __lSX8
			 	// ConfirmSX8()    
			// EndDo
		Endif
	EndIf
RestArea(aArea)
Return lMSErroAuto

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  LIBeFaturar	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  10.12.2020                                                              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
User Function LIBeFaturar( cFilEnt, cPedVen, cE1HIST )
	Local lErro	:= .F.	
	//Backup da Filial
	Local nRecSM0  	:= SM0->(RecNo())
	Local cCurFil  	:= SM0->M0_CODFIL 
	Local lFatAuto := GetMV("VA_FATAUTO",, .T. ) // Define o faturamento automatico, executado pela função de leitura webservice das liberacoes do pedido enviada pelo Site.
	
	u_MudaFilial( cFilEnt )	

	cE1HIST += Iif(!Empty(cE1HIST), "," , "") + SubStr(cFilEnt,5) +'-'+ cPedVen //+ ' / ' + xLibPedVen[nPosPedImp][2] 

	IF cPedVen <> SC5->C5_NUM
		SC5->(DbSetOrder(1))
		SC5->(DBSeek( cFilEnt + cPedVen ))
	EndIf

	If !Empty(SC5->C5_NOTA)		// Pedido já faturado, retorna .T. p/ continuar o processo
		Alert('[vaFatB02] Pedido: '+ SC5->C5_NUM + ' ja esta faturado na nota: ' + SC5->C5_FILIAL + '/' + SC5->C5_NOTA + '/' + SC5->C5_SERIE )
		Return .F.
	endif

	// Validar Risco do Cliente
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek( xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI )) .and. SA1->A1_RISCO <> 'A'
		RecLock('SA1' , .F. )
			SA1->A1_RISCO := 'A'
		SA1->( MsUnLock() )
	EndIf
	
	// lErro := !U_EstLibPV( cPedVen /* SC5->C5_NUM */ ) // lIBERACAO DE ESTOQUE
	If ! lErro
		// u_cFatA00D( cPedVen ) // Liberacao Financeira
		// 
		// // MJ 08.07
		// SC9->( DbSetOrder(1) ) // Atualizacao da liberacao financeira
		// SC9->( DbSeek( cFilEnt + cPedVen ) ) 
		
		// Parametro: VA_FATAUTO, define Faturamento Automatico
		If lFatAuto 
			lErro := !u_cFatA00A( cPedVen ) // Faturamento Automatico - Inverte a logica pois a funcao retorna se a operacao foi bem sucedida
		EndIf 
	Endif
	
	// Voltar filial anterior
	SM0->(DbGoTo(nRecSM0))
	cFilAnt := cCurFil
	
Return lErro


/* MJ. 24.07.2014 */
User Function MudaFilial(cFilialX)

If AllTrim(SM0->M0_CODFIL) <> AllTrim(cFilialX)
	ConOut('Mudando Filial para: ' + cFilialX )
	cFilAnt :=  cFilialX
	SM0->( dbSetOrder(1) )
	SM0->( dbSeek(cEmpAnt + cFilialX ) )
EndIf

Return nil
