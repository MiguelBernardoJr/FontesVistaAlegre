/* 
documentacao WebServices
http://tdn.totvs.com/pages/viewpage.action?pageId=6064937
http://tdn.totvs.com/pages/viewpage.action?pageId=118885851

 */

#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH' 

/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     22.02.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Esta rotina tem como objetivo realizar manutencao nos campos customi-  |
 |         zados da tabela SF2: CabeÃ§alho da Nota Fiscal.                          |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
User Function VAFATB01() // U_VAFATB01()
Private oBrowse
Private cCadastro := "Manutenção de Notas Fiscais de Saida"
Private cAlias    := "SF2"
Private aRotina   := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( cAlias )   
	oBrowse:SetMenuDef("VAFATB01")
	oBrowse:SetDescription( cCadastro )
	// oBrowse:SetFilterDefault( "B8_SALDO > 0" )
	
	// aFields := LoadFields()
	// oBrowse:SetFields(aFields)
	
	oBrowse:Activate()
Return NIL 

/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     22.02.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:                                                                            |
 |                                                                                  |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
Static Function MenuDef()
Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar'  			, 'AxPesqui'   , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar' 			, 'AxVisual'   , 0, 2, 0, NIL } ) // aAdd( aRotina, { 'Incluir'              , 'AxInclui', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Pesagem'              , 'U_FATB01Pes', 0, 3, 0, Nil } )
	// aAdd( aRotina, { 'Alterar'    			, 'U_FATB01Alt', 0, 4, 0, NIL } ) //aAdd( aRotina, { 'Excluir'              , 'AxDeleta', 0, 5, 0, NIL } ) // aAdd( aRotina, { 'Legenda'         		, 'U_VAM07Leg', 0, 7, 0, NIL } )
	aAdd( aRotina, { 'Relacionar NF Entrada', 'U_VAFATB02' , 0, 4, 0, NIL } )

Return aRotina


/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     22.02.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:                                                                            |
 |                                                                                  |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
User Function FATB01Alt(cAlias, nReg, nOpc)
Local oDlg		  := nil
Local aSize		  := {}
Local aObjects    := {}
Local aInfo		  := {}
Local aPObjs      := {}
Local nOpcE		  := aRotina[nOpc, 4]
Local nOpcA		  := 0

Private aGets       := {}
Private aTela       := {}

aSize := MsAdvSize( .T. )
AAdd( aObjects, { 100 , 100, .T. , .T. , .F. } )
// AAdd( aObjects, { 100 ,  80, .T. , .T. , .F. } )
// AAdd( aObjects, { 100 , 120, .T. , .T. , .F. } )
aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T., .F.) 

RegToMemory( cAlias, nOpcE == 3 )
/*
DbSelectArea(cAlias)
(cAlias)->(DbGoTo(nReg))
*/
DEFINE MSDIALOG oDlg TITLE 	OemToAnsi(cCadastro) From 0,0 to aSize[6],aSize[5] PIXEL of oMainWnd
// oDlg:lMaximized := .T.

oMGet  := MsMGet():New( cAlias, nReg, nOpc ,,,,, aPObjs[1], U_LoadCustomCpo(cAlias)/* {"B8_GMD","B8_DIASCO","B8_XRENESP"} */ ,,,,, /* oGrp1 */ )

ACTIVATE MSDIALOG oDlg ;
	  ON INIT EnchoiceBar(oDlg,;
						  { || nOpcA := 1, Iif(/*  VldOk(nOpc) .and. */ Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)},;
						  { || nOpcA := 0, oDlg:End() },, /* aButtons */ )


If nOpcA == 1
	Begin Transaction     
		// DbSelectArea(cAlias)
		// DbSetOrder(3) // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
		RecLock( cAlias, .F.) //  !DbSeek( xFilial('ZCC') + M->ZCC_CODIGO + M->ZCC_VERSAO ))
			U_GrvCpo(cAlias)				
		(cAlias)->(MsUnlock())
	End Transaction	
// Else
//	Alert('Cancelou')
EndIf

Return nil

User Function FATB01Pes(cAlias, nReg, nOpc)
	Local oDlg, aSize, aInfo, aObjects := {}, aPObjs := {}
	Local nPesBrut
	Local aHSd2 := {}, aCSd2 := {}
	
	Local nStyle := GD_UPDATE //0 // GD_INSERT + GD_UPDATE + GD_DELETE 
	Local nMax   := 99// Numero maximo de linhas permitidas na getdados
	Local aAlter := {"D2_XNRPSAG", "D2_XPESLIQ", "D2_XDTABAT"}
	Private bChangeSd2 := {|| IIf(oGDSd2 == Nil, FSBscSd2(oGDSd2, aHSd2, aCSd2, 1), .T.)} 
	
	Private nPeso := 0
							
	Private oGDSd2
	Private oBtnCabFilt, oBtnCabConf, oBtnCabDesf, oBtnCabSaid
	Private nSf2Doc := ""
	Private cSf2Ser := ""
	Private __lCpoNRec := .T. // Essa variavel deve ser declarada para que a função BDados retorne o recno no aCols
	
	dbSelectArea("SF2")
	SF2->(dbGoto(nReg))
	nSf2Doc := SF2->F2_DOC
	cSf2Ser := SF2->F2_SERIE
	
	FSFilRec(Nil, Nil, aHSd2, aCSd2)
	
	aSize := MsAdvSize(.F.)
 	aAdd(aObjects, {100, 090, .T., .T., .F.})
 	aAdd(aObjects, {100, 010, .T., .T., .T.})
 	 	
 	aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
 	aPObjs := MsObjSize(aInfo, aObjects, .T., .F.)                                                        
    
                          
 	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Digitação de Dados da Pesagem") From aSize[7], 0 TO aSize[6], aSize[5] PIXEL of oMainWnd
		// Executa a função sem a criação dos browser para criar o aHeader e o aCols em branco
		MsgRun("Aguarde, inicializando ambiente", "Digitação de Dados da Pesagem", bChangeSd2)
 		
		oGDSd2 := MsNewGetDados():New (aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nStyle, /*cLinhaOk*/, /*cTudoOk*/, /*cIniCpos*/, aAlter, /*nFreeze*/, nMax, /*cFieldOk*/, /*cSuperDel*/, /*cDelOk*/, oDlg, aHSd2, aCSd2, /*uChange*/, /*cTela*/)
		oGDSd2:oBrowse:Align          := CONTROL_ALIGN_ALLCLIENT
//		oGDSd2:oBrowse:BlDblClick     := {|| FS_DbClk(oGDSd2)}
//		oGDSd2:oBrowse:BrClicked      := {|| FS_DbClk(oGDSd2)}
		oGDSd2:bChange                := bChangeSd2
		// oGDSd2:oBrowse:bCustomEditCol := {| nColPos, cLastKey, nLastKey, oBrowse | U_TSPesqGD(oGDSd2:aCols, {nColPos, cLastKey, nLastKey, oBrowse}), EVal(bChangeSd2)}
  		// oGDSd2:oBrowse:BHeaderClick   := {| oBrw, nCol | U_PDReordGD(oGDSd2, nCol)}
  					                                                                   
  		oPanCabFunc := tPanel():New(aPObjs[2, 1], aPObjs[2, 2], Nil, oDlg,,,, /*CLR_YELLOW*/, /*CLR_BLUE*/, aPObjs[2, 3], aPObjs[2, 4],, .T.)
		//oPanCabFunc:Align := CONTROL_ALIGN_BOTTOM

//		oBtnCabFilt := TButton():New(005, 005, "Filtrar"     , oPanCabFunc, {|| FSFilRec(oCabFilter, Nil, Nil)						    }, 050, 010,, /*oFont*/,, .T.,,,, /*bWhen*/,,)
		oBtnCabConf := TButton():New(005, 055, "Confirma"    , oPanCabFunc, {|| Processa({|| FSGrava()})                                }, 050, 010,, /*oFont*/,, .T.,,,, /*bWhen*/,,)
		oBtnCabSaid := TButton():New(005, 105, "Sair"        , oPanCabFunc, {|| oDlg:End()                    						    }, 050, 010,, /*oFont*/,, .T.,,,, /*bWhen*/,,)
		
		@ 005,255 SAY "Num da Nota : " 						SIZE 080,010 OF oPanCabFunc PIXEL
		@ 005,355 SAY SF2->F2_DOC 							SIZE 080,010 OF oPanCabFunc PIXEL
		@ 005,400 SAY "Peso Total : " 						SIZE 080,010 OF oPanCabFunc PIXEL
		@ 005,500 SAY Transform(nPeso, "@E 999,999,999.99")	SIZE 080,010 OF oPanCabFunc PIXEL
				
// 		oCabFilter := TSay():New(007, 300, {|| "Filtro: " + __aGDFilter[1][2]}, oPanCabFunc,, /*oFont*/,,,, .T., CLR_RED, CLR_WHITE, 200, 10)

	ACTIVATE MSDIALOG oDlg CENTERED
Return(Nil)

Static Function FSBscSd2(oGDSd2, aHSd2, aCSd2, nOrd)
	Local nUDados    := 0
	Local lMostRecno := .T.
	Local lFilial    := .T.
	Local cLstCpo    := "D2_DOC    /D2_SERIE  /D2_COD    /B1_DESC   /D2_UM     /D2_LOTECTL/D2_QUANT  /D2_TOTAL  /D2_TES    /D2_XNRPSAG/D2_XPESLIQ/D2_XDTABAT"
	Local lLstCpo    := .F.
	Local aCposIni   := {"D2_DOC    ", "D2_SERIE  ", "D2_COD    ", "B1_DESC  ","D2_UM     ", "D2_LOTECTL", "D2_QUANT  ","D2_TOTAL  ", "D2_TES    ", "D2_XNRPSAG", "D2_XPESLIQ", "D2_XDTABAT"}
	Local cCond      := "SD2.D2_DOC = '" + nSf2Doc + "' AND SD2.D2_SERIE = '" + cSf2Ser + "' "
	Local aCposAlt	 := {"D2_XNRPSAG", "D2_XPESLIQ", "D2_XDTABAT"}
    Local aJoin      := {}
    Local cCpoNao    := "D2_CLIENTE/D2_LOJA   /D2_SERIE  /D2_EMISSAO/D2_QTDEFAT/D2_QTDAFAT/D2_TPESTR /D2_DESCZFP/"+;
    					"D2_DESCZFP/D2_TRT    /D2_DESCICM/D2_CODLPRE/D2_ITLPRE /D2_VREINT /D2_BSREIN /D2_09CAT17/"+;
    					"D2_16CAT17/D2_GRPCST /D2_BASECPB/D2_VALCPB /D2_ALIQCPB/D2_ICMSCOM/D2_DIFAL  /D2_PDORI  /"+;
    					"D2_PDDES  /D2_ALFCCMP/D2_ALIQCMP/D2_BASEDES/D2_VFCPDIF/D2_FTRICMS/D2_VRDICMS/D2_VALFUND/"+;
    					"D2_BASFUND/D2_ALIFUND/D2_VALIMA /D2_BASIMA /D2_ALIIMA /D2_VALFASE/D2_BASFASE/D2_ALIFASE/"+;
    					"D2_INDICE /D2_CSOSN  /D2_ALQFECP/D2_VALFECP/D2_VFECPST/D2_ICMSDIF/D2_VOPDIF /D2_BASEPRO/"+;
    					"D2_ALIQPRO/D2_VALPRO /D2_ALFCPST/D2_XDESC  /D2_PRCVEN /"    					
	Default nOrd := 0
			
AAdd(aJoin, {RetSqlName("SB1") + " SB1", "SB1.B1_DESC" , "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = SD2.D2_COD", "B1_DESC"})
//           Arquivo e Alias           , Campo origem  , Condição de relacionamento entre os arquivos                                                    , Campo destino


 	aCSd2 := {}
 	aHSd2 := {}
//   BDados(cAlias, aHDados, aCDados, nUDados, nOrd, lFilial, cCond, lStatus, cCpoLeg, cLstCpo, cElimina, cCpoNao, cStaReg    , cCpoMar, cMarDef, lLstCpo, aLeg, lEliSql, lOrderBy, cCposGrpBy, cGroupBy, aCposIni, aJoin, aCposCalc, cOrderBy, aCposVis, aCposAlt, cCpoFilial, nOpcX, lMostRecNo, lLinMax)
 	U_BDados("SD2", aHSd2  , aCSd2  , nUDados, nOrd, lFilial, cCond,        ,        ,        ,         , cCpoNao,            ,        ,        , lLstCpo,     ,        ,         ,           ,         , aCposIni, aJoin,          ,         ,         , aCposAlt,           ,      , lMostRecNo,)
 	
 
 	If oGDSd2 <> Nil
		oGDSd2:SetArray(aCSd2, .T.)
		oGDSd2:oBrowse:Refresh()
	EndIf	
	nPeso := CountPeso()
//oPanCabFunc:Refresh()
Return(Nil)

Static Function FSFilRec(oSayFilter, nAliasAtu, aHFilt, aCFilt)
	Local cAlias, oWnd, cFilter := "", lTopFilter := .T., bOk, oDlg, aUsado, cDesc := "Filtro", nRow, nCol, aCampo, lVisibleTopFilter := .T., lExpBtn := .T., cTopFilter := ""
	
	FSLoadFilter()

	If oGDSd2 <> Nil
		cFilter    := __aGDFilter[nAliasAtu][2]
		cTopFilter := __aGDFilter[nAliasAtu][2]	
		
		__aGDFilter[nAliasAtu][2] := BuildExpr(__aGDFilter[nAliasAtu][1], oWnd, @cFilter, lTopFilter, bOk, oDlg, aUsado, cDesc, nRow, nCol, aCampo, lVisibleTopFilter, lExpBtn, @cTopFilter)
		
		FSUpdtFilter()
		
		If oSayFilter <> Nil
			oSayFilter:SetText("Filtro: " + __aGDFilter[nAliasAtu][2])
			oSayFilter:CtrlRefresh()
		EndIf
		
		If 		nAliasAtu == Nil .And. oGDSd2 <> Nil
			FSBscSd2(,oGDSd2:aHeader, oGDSd2:aCols)
			
		ElseIf 	nAliasAtu == Nil .And. oGDSd2 == Nil
			FSBscSd2(,aHFilt, aCFilt)
			
		EndIf
	EndIf	
	
	EVal(bChangeSd2)
Return(Nil)

Static Function FSLoadFilter()
	Local cAliasOld  := Alias()
	Local cBrwFilter := ""
	Local nForFilter := 0
	Local cFltAlias  := ""
	Local cFltWhere  := ""
	Local nPosAlias  := 0
	
	cBrwFilter := RetProfDef(__cUserID + cEmpAnt + cFilAnt, "TSPANCTR", "BRWFILTER", "SCP")
	
	For nForFilter := 1 To MLCount(cBrwFilter)
		cFltWhere := MemoLine(cBrwFilter,, nForFilter)
		
		cFltAlias := SubStr(cFltWhere, 1, At(";", cFltWhere)-1)
		cFltWhere := AllTrim(SubStr(cFltWhere, At(";", cFltWhere)+1))
		
		If (nPosAlias := aScan(__aGDFilter, {| aVet | aVet[1] == cFltAlias})) > 0
		
			__aGDFilter[nPosAlias][2] := cFltWhere
			
		EndIf
	Next
	
	DBSelectArea(cAliasOld)
Return(Nil)

Static Function FSUpdtFilter()
	Local cAliasOld  := Alias()
	Local cBrwFilter := ""
	Local nForFilter := 0
	
	For nForFilter := 1 To Len(__aGDFilter)
		cBrwFilter += __aGDFilter[nForFilter][1] + ";" + __aGDFilter[nForFilter][2] + Chr(13) + Chr(10)
	Next

	If FindProfDef(__cUserID + cEmpAnt + cFilAnt, "TSPANCTR", "BRWFILTER", "SD2")
		WriteProfDef(__cUserID + cEmpAnt + cFilAnt, "TSPANCTR", "BRWFILTER", "SD2", __cUserID + cEmpAnt + cFilAnt, "TSPANCTR", "BRWFILTER", "SD2", cBrwFilter)
		
	Else
		WriteNewProf(__cUserID + cEmpAnt + cFilAnt, "TSPANCTR", "BRWFILTER", "SD2", cBrwFilter)
		
	EndIf
	
	DBSelectArea(cAliasOld)
Return(Nil)    
 

Static Function FSGrava()

	Local nSd2Cod     := aScan(oGDSd2:aHeader, {|x| x[2] == "D2_COD    "})	
	Local nSd2Serie	  := aScan(oGDSd2:aHeader, {|x| x[2] == "D2_SERIE  "})
	Local nSd2Item    := aScan(oGDSd2:aHeader, {|x| x[2] == "D2_ITEM   "})
	Local nSd2XNrpsag := aScan(oGDSd2:aHeader, {|x| x[2] == "D2_XNRPSAG"})	
	Local nSd2XPesliq := aScan(oGDSd2:aHeader, {|x| x[2] == "D2_XPESLIQ"})	
	Local nSd2XDtabat := aScan(oGDSd2:aHeader, {|x| x[2] == "D2_XDTABAT"})
	Local nRecno	  := aScan(oGDSd2:aHeader, {|x| x[2] == "RECNO"})
	
	Local nSd2		  := 0
	
	Begin Transaction
						
		For nSd2 := 1 to Len(oGDSd2:aCols)
			SD2->(dbGoto(oGdSd2:aCols[nSd2][nRecno]))
			RecLock("SD2",.F.)
				SD2->D2_FILIAL 	:= xFilial("SD2")
				SD2->D2_XNRPSAG := oGDSd2:aCols[nSd2][nSd2XNrpsag]	
				SD2->D2_XPESLIQ := oGDSd2:aCols[nSd2][nSd2XPesliq]
				SD2->D2_XDTABAT	:= oGdSd2:aCols[nSd2][nSd2XDtabat]
			MsUnlock()
		Next 

	End Transaction
	
	dbSelectArea("SF2")
	RecLock("SF2",.F.)
		SF2->F2_XPESLIQ := CountPeso()
	SF2->(msUnlock())
	nPeso := CountPeso()
	oPanCabFunc:Refresh() 
	FSBscSd2(oGDSd2, oGDSd2:aHeader, oGDSd2:aCols, 1)

Return(Nil)   
     
Static Function CountPeso()
Local nPesTot := 0
Local nSd2XPesliq  := IIf( oGdSd2 <> Nil, aScan(oGDSd2:aHeader, {|x| x[2] == "D2_XPESLIQ"}),0) 
Local nSd2

	If oGdSd2 <> Nil
		For nSd2 := 1 to Len(oGDSd2:aCols)
			nPesTot += oGdSd2:aCols[nSd2][nSd2XPesliq]
		Next nSd2
		
	EndIf


Return(nPesTot)
