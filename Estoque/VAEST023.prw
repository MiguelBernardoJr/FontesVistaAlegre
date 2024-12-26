#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH' 

/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     10.01.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Esta rotina tem como objetivo realizar manutencao nos campos customi-  |
 |         zados para o Lote-SB8.                                                   |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
User Function VAEST023() 
Private oBrowse 
Private cCadastro  := "Manutenção de Lotes"
Private cAlias     := "SB8" 
Private aRotina    := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( cAlias )   
	oBrowse:SetMenuDef("VAEST023")
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetFilterDefault( "B8_SALDO > 0" )
	
	// aFields := LoadFields()
	// oBrowse:SetFields(aFields)
	
	oBrowse:Activate()
Return NIL 

/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     10.01.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:                                                                            |
 |                                                                                  |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
Static Function MenuDef()
Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar'  , 'AxPesqui'  , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar' , 'AxVisual'  , 0, 2, 0, NIL } ) // aAdd( aRotina, { 'Incluir'              , 'AxInclui', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'    , 'U_EST23Alt', 0, 4, 0, NIL } ) // aAdd( aRotina, { 'Excluir'              , 'AxDeleta', 0, 5, 0, NIL } ) // aAdd( aRotina, { 'Legenda'         		, 'U_VAM07Leg', 0, 7, 0, NIL } )
Return aRotina


/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     10.01.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:                                                                            |
 |                                                                                  |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
User Function LoadCustomCpo(cAlias)
Local aArea		:= GetArea()
Local aCampos	:= {}

DbSelectArea("SX3")
SX3->(DbSetOrder(1))
If SX3->( dbSeek( cAlias ) )
	While !(SX3->(eof())) .and. SX3->X3_ARQUIVO == cAlias
		If SX3->X3_PROPRI == "U" .AND. SX3->X3_CONTEXT<>'V' .AND. X3USO(SX3->X3_USADO) // SX3->X3_VISUAL
			aAdd ( aCampos, SX3->X3_CAMPO )
		EndIf
		
		SX3->(DbSkip())
	EndDo
Endif

RestArea(aArea)
Return aCampos

 
/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     10.01.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:                                                                            |
 |                                                                                  |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
User Function EST23Alt(cAlias, nReg, nOpc)
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
DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From 0,0 to aSize[6],aSize[5] PIXEL of oMainWnd
// oDlg:lMaximized := .T.

// oGrp1  := TGroup():New(aPObjs[1,1],aPObjs[1,2],aPObjs[1,3],aPObjs[1,4],"Dados Gerais do Contrato",oDlg,,, .T.,)
oMGet  := MsMGet():New( cAlias, nReg, nOpc ,,,,, aPObjs[1], U_LoadCustomCpo(cAlias)/* {"B8_GMD","B8_DIASCO","B8_XRENESP"} */ ,,,,, /* oGrp1 */ )

ACTIVATE MSDIALOG oDlg ;
	  ON INIT EnchoiceBar(oDlg,;
						  { || nOpcA := 1, Iif( VldOk(nOpc) .and. Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)},;
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



/*--------------------------------------------------------------------------------,
 | Principal: 					                         	            	      |
 | Func:  VldOk(nOpc)	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  22.05.2019	            	          	            	              |
 | Desc:  validacao para nao permitir DIFERENTES lotes para IGUAIS currais;		  |
 |--------------------------------------------------------------------------------|
 | Regras   :                                                                     |
 |                                                                                |
 |--------------------------------------------------------------------------------|
 | Obs.     :                                                                     |
 '--------------------------------------------------------------------------------*/
Static Function VldOk(nOpc)
Local lRet  	:= .T.
Local cMsg		:= ""
Local cNovoCur	:= M->B8_X_CURRA

	// MJ: 22.05.2019 - validacao para nao permitir DIFERENTES lotes para IGUAIS currais;
	If SB8->B8_X_CURRA<>M->B8_X_CURRA .AND. !Empty(cNovoCur)	
		beginSQL alias "cAliasVld"
			%noParser%
			SELECT  B8_LOTECTL, COUNT(B8_LOTECTL) QTDREG
			FROM	%table:SB8% SB8
			WHERE	B8_FILIAL  =  %xFilial:SB8%
				AND B8_LOTECTL <> %exp:SB8->B8_LOTECTL%
				AND B8_X_CURRA =  %exp:cNovoCur%
				AND B8_SALDO   >  0
				AND SB8.%notDel%
			GROUP BY B8_LOTECTL
			ORDER BY B8_LOTECTL
		endSQL
		if !cAliasVld->(Eof())
			cMsg := ""
			While !cAliasVld->(Eof())
				cMsg += iIf(Empty(cMsg),"",", ") + cAliasVld->B8_LOTECTL
				cAliasVld->(DbSkip())
			endDo
			
			msgAlert("O novo Curral: " + cNovoCur + ' já esta sendo usado para o(s) lote(s):' +CRLF+ ;
					  cMsg +CRLF+;
					  'Esta operação será cancelada.')
			lRet := .F.
		endIf
		cAliasVld->(dbCloseArea())	
	EndIf		

Return lRet

/* 
Static Function LoadFields()
Local aArea		:= GetArea()
Local aColsAux 	:=`{}
Local aColsSX3	:= {}
Local aCampos  	:= {"B8_PRODUTO","B8_LOCAL","B8_DATA","B8_SALDO","B8_EMPENHO"}
Local nX		:= 0

DbSelectArea("SX3")
DbSetOrder(2)
For nX := 1 to Len(aCampos)
	If SX3->( dbSeek(aCampos[nX]) )
		// Alert(X3Titulo())
	    aColsSX3 := {	X3Titulo(), ;
						{|| &(SX3->X3_ARQUIVO+"->"+SX3->X3_CAMPO) }, ;
						SX3->X3_TIPO, ;
						SX3->X3_PICTURE, ;
						1, ;
						SX3->X3_TAMANHO, ;
						SX3->X3_DECIMAL, ;
						.F. ;
						,,,,,,,,1}
	    aAdd(aColsAux,aColsSX3)
	    aColsSX3 := {}
	EndIf
Next nX

// Com permissao para alteracao
aCampos  	:= {"B8_GMD","B8_DIASCO","B8_XRENESP"}
DbSetOrder(2)
For nX := 1 to Len(aCampos)
	If SX3->( dbSeek(aCampos[nX]) )
	    aColsSX3 := {	X3Titulo(), ;
						{|| &(SX3->X3_ARQUIVO+"->"+SX3->X3_CAMPO) }, ;
						SX3->X3_TIPO, ;
						SX3->X3_PICTURE, ;
						1, ;
						SX3->X3_TAMANHO, ;
						SX3->X3_DECIMAL, ;
						.T. ;
						,,,,,,,,1}
	    aAdd(aColsAux,aColsSX3)
	    aColsSX3 := {}
	EndIf
Next nX

RestArea(aArea)

Return aColsAux 
*/
