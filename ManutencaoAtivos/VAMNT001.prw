#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

Static nPInicio     := 2
Static nPZADCC 		:= 4 // aScan(aHeader,{|x| AllTrim(x[2])=="ZAD_CC"})
Static nPCODOPERA	:= 6 // aScan(aHeader,{|x| AllTrim(x[2])=="ZAD_OPERAD"})

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  03.03.2017                                                              |
 | Desc:  Relatorio de Entrada e Saidas com ICMS e Frete;                         |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAMNT001() // U_VAMNT001()
Local oBrowse
Local cAlias    	:= "ZAD"
Private cCadastro 	:= "Apontamento de atividades diarias"
Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(cAlias)
oBrowse:SetDescription(cCadastro)

oBrowse:Activate()
Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  03.03.2017                                                              |
 | Desc:  Relatorio de Entrada e Saidas com ICMS e Frete;                         |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRotina := {  { "Pesquisar"                  , "axPesqui"     , 0, 1, 0 },;
						{ "Visualizar"                 , "axVisual"     , 0, 2, 0 },;
						{ "Incluir - Unico"            , "axInclui"     , 0, 3, 0 },;
						{ "Incluir - Tabela"           , "U_MNT001VA"   , 0, 3, 0 },;
						{ "Altera"                     , "axAltera"     , 0, 4, 0 },; 
						{ "Excluir"                    , "axDeleta"     , 0, 5, 0 } }
Return aRotina

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  03.03.2017                                                              |
 | Desc:  Relatorio de Entrada e Saidas com ICMS e Frete;                         |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function MNT001VA(cAlias, nReg, nOpc) // U_VAMNT001()

Local aArea		 := GetArea()
Local oDlg
Local nGDOpc     := GD_INSERT + GD_UPDATE + GD_DELETE
Local nOpcA		 := 0
Local nI         := 0
Local aSize      := {}
Local aObjects   := {}
Local aInfo      := {}
Local aPObjs     := {}
Local aField  	 := {}
Local oGDados	 := nil, oEnch := nil

Local cCpoNao    := "|ZAD_FILIAL|ZAD_CODIGO|ZAD_ITEM  |ZAD_EQUIPA| "
Local cLstCpo    := "|ZAD_DATA  |ZAD_INICIO|ZAD_FINAL |ZAD_CC    |ZAD_CCDESC|ZAD_OPERAD|ZAD_NOMEOP|ZAD_OBSERV"

Local lGrav		 := .F.

Private _aHead   := {}
Private _aCols	 := {}
Private _nQCol   := {}

Private aGets    := {}
Private aTela    := {}

// Private _cFilial := CriaVar('ZAD_FILIAL', .F.)
Private _cCodigo := CriaVar('ZAD_CODIGO', .F.)
Private _cItem   := CriaVar('ZAD_ITEM'  , .F.)
Private _cEquipa := CriaVar('ZAD_EQUIPA', .F.)

Default cAlias   := 'ZAD'
Default nOpc     := 4
Default nReg	 := 0

DbSelectArea('ZAD')	
DbSetOrder(1)

//                      Titulo,     Campo, Tipo,                  Tamanho,                 Decimal,                 Pict,                           Valid, Obrigat, Nivel,                     Inic Padr, F3,   When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
// aAdd(aField, { "Filial"  , "_cFilial" ,  "C",  TamSX3("ZAD_FILIAL")[1], TamSX3("ZAD_FILIAL")[2], PesqPict("ZAD", "ZAD_CODIGO"), /* { || VldCpo(2) } */,     .T.,     1, xFilial('ZAD')               , ""   , "" ,    .F.,   .F.,   "",   1,     .F.,          "",      "N"} )
aAdd(aField, { "Codigo"     , "_cCodigo" ,  "C",  TamSX3("ZAD_CODIGO")[1], TamSX3("ZAD_CODIGO")[2], PesqPict("ZAD", "ZAD_CODIGO"), /* { || VldCpo(2) } */,     .F.,     1, GetSX8Num('ZAD','ZAD_CODIGO'), ""   , "" ,    .T.,   .F.,   "",   1,     .F.,          "",      "N"} )
aAdd(aField, { "Nr. Frota"  , "_cItem"   ,  "C",  TamSX3("ZAD_ITEM"  )[1], TamSX3("ZAD_ITEM")[2]  , PesqPict("ZAD", "ZAD_ITEM")  , { || U_Vd1MNT01() }       ,     .F.,     1,                            "", "CTD", "" ,    .F.,   .F.,   "",   2,     .F.,          "",      "N"} )
aAdd(aField, { "Equipamento", "_cEquipa" ,  "C",  TamSX3("ZAD_EQUIPA")[1], TamSX3("ZAD_EQUIPA")[2], PesqPict("ZAD", "UC_CODCONT"), /* { || VldCpo(2) } */,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",   2,     .F.,          "",      "N"} )

U_BDados( "ZAD", @_aHead, @_aCols, @_nQCol, 1 /* nOrd */, /* lFilial */, /* cCond */, /* lStatus */, /* cCpoLeg */, cLstCpo, /* cElimina */, cCpoNao, /* cStaReg */, /* cCpoMar */, /* cMarDef */, /* lLstCpo */, /* aLeg */, /* lEliSql */, /* lOrderBy */, /* cCposGrpBy */, /* cGroupBy */, /* aCposIni */, /* aJoin */, /* aCposCalc */, /* cOrderBy */, /* aCposVis */, /* aCposAlt */, /* cCpoFilial */, /* nOpcX */ ) // U_VAMNT001()

aSize := MsAdvSize( .T. )
AAdd( aObjects, { 100, 50, .T., .T. } )
AAdd( aObjects, { 100, 50, .T., .T. } )
aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T., .F.)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],0 TO aSize[6], aSize[5] PIXEL of oMainWnd
oDlg:lMaximized := .T.

oPanelTop:= TPanel():New(0,0,"",oDlg,,,,,, 0, 50 )
oPanelTop:align:= CONTROL_ALIGN_TOP
oPanelCab := TPanel():New(0,0,"",oPanelTop,,,,,, 0, 50 )
oPanelCab:align:= CONTROL_ALIGN_ALLCLIENT
oEnch := MsMGet():New(,,nOpc,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,aPObjs[1],/*aAlterEnch*/,/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oPanelCab,/*lF3*/,/*lMemoria*/,/*lColumn*/,/*caTela*/,/*lNoFolder*/,/*lProperty*/,aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,/*cTela*/)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	
oPanelBot:= tPanel():New(0,0,"",oDlg,,,,,, 0, 50 )
oPanelBot:align := CONTROL_ALIGN_ALLCLIENT
oGDados := MsNewGetDados():New( aPObjs[2][1], aPObjs[2][2], aPObjs[2][3], aPObjs[2][4], nGDOpc, /* "U_f18LinhaOk" */, , , , , , , , , oPanelBot, _aHead, _aCols )
// oGDados:oBrowse:BlDblClick := { || SetMark(oGDados)}
oGDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	

// Inicializadores
_cCodigo := GetSX8Num('ZAD','ZAD_CODIGO') // U_VAMNT001()

ACTIVATE MSDIALOG oDlg ;
          ON INIT EnchoiceBar(oDlg,;
                              { || nOpcA := 1, Iif( /* VldOk(nOpcE).and. */ Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)},;
                              { || nOpcA := 0, oDlg:End() },, /*aButtons*/)

If nOpcA == 1 // U_VAMNT001()
	For nI := 1 to Len(oGDados:aCols)
		If  !Empty( oGDados:aCols[nI, 01] ) .and. ;
			!Empty( oGDados:aCols[nI, 02] ) .and. ;
			!Empty( oGDados:aCols[nI, 03] ) .and. ;
			!Empty( oGDados:aCols[nI, nPZADCC] ) .and. ;
			!Empty( oGDados:aCols[nI, nPCODOPERA] ) 
			
			RecLock('ZAD', .T.)
				ZAD->ZAD_FILIAL := xFilial('ZAD')
				ZAD->ZAD_CODIGO := _cCodigo
				ZAD->ZAD_ITEM	:= _cItem
				ZAD->ZAD_EQUIPA	:= _cEquipa
				ZAD->ZAD_DATA	:= oGDados:aCols[nI, 01]
				ZAD->ZAD_INICIO	:= oGDados:aCols[nI, 02]
				ZAD->ZAD_FINAL	:= oGDados:aCols[nI, 03]
				ZAD->ZAD_CC		:= oGDados:aCols[nI, nPZADCC]
				ZAD->ZAD_OPERAD	:= oGDados:aCols[nI, nPCODOPERA]
				ZAD->ZAD_OBSERV := oGDados:aCols[nI, 08]
			ZAD->(MsUnLock())
			
			If !lGrav
				lGrav := .T.
			EndIf
		EndIf
	Next nI
	If lGrav
		ConfirmSx8()
	EndIf
Else
	RollbackSX8()
EndIf
	
If !Empty(aArea)
	RestArea(aArea)
EndIf

Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  03.03.2017                                                              |
 | Desc:  Relatorio de Entrada e Saidas com ICMS e Frete;                         |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function Vd1MNT01() // VldCpo(nOpc)
Local aArea      := GetArea()
Local lRet 		 := .F. // ExistCpo("CTD")
Local _cQry      := ""
Local cAlias     := ""
Local _cXItem     := ""

DbSelectArea('CTD')
CTD->(DbSetOrder(1))
If Type('_CITEM') == "U" // cadastro unico
	_cXItem := &( Iif( INCLUI, 'M', 'ZAD') + '->ZAD_ITEM' )
else
	_cXItem := _CITEM
EndIf                          
If !Empty(_cXItem)
	If (lRet := DbSeek( xFilial('CTD')+ _cXItem ))
		If Type('_CITEM') == "U" // If SubS(ReadVar(), AT(">", ReadVar())+1 ) == "_CITEM"
			&( Iif( INCLUI, 'M', 'ZAD') + '->ZAD_EQUIPA' ) := CTD->CTD_DESC01
		Else
			_cEquipa := CTD->CTD_DESC01
		EndIf
		
		cAlias     := GetNextAlias()
			_cQry := " SELECT ISNULL(MAX(ZAD_FINAL),'') FINAL "
			_cQry += " FROM " + RetSqlName('ZAD')
			_cQry += " WHERE "
			_cQry += " 	   ZAD_FILIAL = '"+xFilial('ZAD')+"' "
			_cQry += " AND ZAD_ITEM='" + _cXItem + "' "
			_cQry += " AND D_E_L_E_T_=' ' "
	
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry),(cAlias),.F.,.F.) 
	
			If !(cAlias)->(Eof())
				If Type('_CITEM') == "U"
					&( Iif( INCLUI, 'M', 'ZAD') + '->ZAD_INICIO' ) := (cAlias)->FINAL
				// Else
					// If Len(aCols) == 1
						// aCols[ Len(aCols), nPInicio ] := (cAlias)->FINAL
					// EndIf
				EndIf
			EndIf
		(cAlias)->(	DbCloseArea() )
	EndIf
EndIf
RestArea(aArea)
Return lRet


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  26.09.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function Vd2MNT01()	
Local aArea      := GetArea()
Local lRet 		 := .T.
Local _cQry      := ""
Local cAlias     := ""
Local _cXItem    := ""
Local _cXEquip   := ""
Local _cInicio   := ""

If Type('_CITEM') == "U" // cadastro unico
	_cXItem 	 := &( Iif( INCLUI, 'M', 'ZAD') + '->ZAD_ITEM' )
	_cXEquip	 := &( Iif( INCLUI, 'M', 'ZAD') + '->ZAD_EQUIPA' )
else
	_cXItem   := _CITEM
	_cXEquip  := _cEquipa
EndIf

_cInicio := &( Iif( INCLUI, 'M', 'ZAD') + '->ZAD_INICIO' )
If !Empty( _cInicio )

	cAlias     := GetNextAlias()
	_cQry := " SELECT ISNULL(MAX(ZAD_FINAL),'') FINAL "
	_cQry += " FROM " + RetSqlName('ZAD')
	_cQry += " WHERE "
	_cQry += " 	   ZAD_FILIAL = '"+xFilial('ZAD')+"'"	
	_cQry += " AND ZAD_ITEM='" + _cXItem + "' "
	_cQry += " AND D_E_L_E_T_=' ' "
	
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry),(cAlias),.F.,.F.) 

	If !(cAlias)->(Eof())
		If Val( _cInicio ) < Val((cAlias)->FINAL)
			Alert('Valor inicial invalido para o equipamento: ' + AllTrim( _cXEquip ) + ;
					'. Ultimo valor informado: ' + AllTrim((cAlias)->FINAL) )
					                                          
			// Limpando codigo errado
			&( Iif( INCLUI, 'M', 'ZAD') + '->ZAD_INICIO' ) := Space(TamSX3('ZAD_INICIO')[1])
			lRet := .F.
		EndIf
	EndIf
	(cAlias)->( DbCloseArea() )
EndIf	
RestArea(aArea)
Return lRet

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  28.09.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       | 
 '--------------------------------------------------------------------------------*/
User Function Vd3MNT01()	
Local lRet  := .T.
Local nIni	:= 0 // Val(&(Iif(INCLUI,'M','ZAD')+'->ZAD_INICIO'))
Local nFim  := Val(StrTran( &(Iif( INCLUI,' M','ZAD')+'->ZAD_FINAL'),",","."))

 If Type('_CITEM') == "U" // cadastro unico
	nIni	:= Val(StrTran(&(Iif(INCLUI,'M','ZAD')+'->ZAD_INICIO'),",","."))
Else
	nIni 	:= Val( StrTran( aCols[ Len(aCols ), nPInicio ]  ,",","."))
EndIf 

If !(lRet := nIni<nFim)  
	Alert('Valor Final não pode ser menor que o valor Inicial.')
EndIf

	Return lRet
// /*--------------------------------------------------------------------------------,
 // | Func:  			                                                              |
 // | Autor: Miguel Martins Bernardo Junior                                          |
 // | Data:  06.03.2017                                                              |
 // | Desc:                                                                          |
 // |                                                                                |
 // | Obs.:  -                                                                       |
 // '--------------------------------------------------------------------------------*/
User Function fMNT01Init(_cCampo)
Local cRet 		:= ""
Local nLen		:= Iif( Type('aCols') == 'U', 0, len(aCols))

// Default _cCampo	:= AllTrim(SubStr( ReadVar(),  At( "M->", ReadVar() ) + 3 ))
	If _cCampo == 'ZAD_INICIO' // U_fMNT01Init("ZAD_INICIO")
	
		cRet := Space(TamSX3('ZAD_INICIO')[1])
		If Type('aCols') == 'A' .and. nLen > 1
			cRet := GdFieldGet('ZAD_FINAL', nLen-1)
		EndIf    	
		
	ElseIf _cCampo == 'ZAD_CC' // U_fMNT01Init("ZAD_CC")
	
		cRet := Space(TamSX3('ZAD_CC')[1])
		If Type('aCols') == 'A' .and. nLen > 1
			If !Empty( cRet := GdFieldGet('ZAD_CC', nLen-1) )
				aCols[ nLen, nPZADCC+1 ] := aCols[ nLen-1, nPZADCC+1 ] // Posicione('CTT',1,xFilial('CTT')+cRet,'CTT_DESC01')
			EndIf
		EndIf

	ElseIf _cCampo == 'ZAD_OPERAD' // U_fMNT01Init("ZAD_OPERAD")
	
		cRet := Space(TamSX3('ZAD_OPERAD')[1])
		If Type('aCols') == 'A' .and. nLen > 1
			If !Empty(cRet := GdFieldGet('ZAD_OPERAD', nLen-1))
				aCols[ nLen, nPCODOPERA+1 ] := aCols[ nLen-1, nPCODOPERA+1 ] // Posicione('SA4',1,xFilial('SA4')+cRet,'A4_NOME')
			EndIf
		EndIf

	EndIf

Return cRet	
// Return Iif(Type('n')=='U',Space(TamSX3('ZAD_INICIO')[1]),Iif(n>0, GdFieldGet('ZAD_FINAL'),Space(TamSX3('ZAD_INICIO')[1])))

	
// /*--------------------------------------------------------------------------------,
 // | Func:  			                                                              |
 // | Autor: Miguel Martins Bernardo Junior                                          |
 // | Data:  06.03.2017                                                              |
 // | Desc:                                                                          |
 // |                                                                                |
 // | Obs.:  -                                                                       |
 // '--------------------------------------------------------------------------------*/
// User Function f18LinhaOk() // U_VAMNT001()
// Local lRet := .T.

// Return lRet
