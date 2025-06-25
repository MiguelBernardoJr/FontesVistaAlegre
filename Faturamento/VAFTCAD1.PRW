#Include "Totvs.ch"
#Include "Rwmake.ch" 
#Include "Protheus.ch"
#include "fwmvcdef.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  08.08.2018                                                              |
 | Desc:  Dados dos animais por lotes, abatidos no frigorifico;                   |
 |        O relacionamento com a NF Saida sera por LoteCTL x Produto.             |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAFTCAD1()

Local cAlias    	:= "ZAB"

Private cCadastro 	:= "Cadastro de Animais Abatidos"
Private aRotina 	:= MenuDef()
Private cPerg		:= "VAFTCAD1"
Private __lVld		:= .T.

GeraX1(cPerg)

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(cAlias)
oBrowse:SetDescription(cCadastro)

//Verifica se a chamada da funcao eh feita da rotina de Informacoes do Lote
If (FUNNAME() == "VAPCPM01")
	U_FTCAD01VA(cAlias, 0, 3)
Else
	oBrowse:Activate()
EndIf

Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.08.2018                                                              |
 | Desc:  -                                                                       |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRotina := {{ "Pesquisar"                  , "axPesqui"     , 0, 1, 0 },;
					  { "Visualizar"                 , "U_FTCAD01VA"  , 0, 2, 0 },;
					  { "Incluir"			         , "U_FTCAD01VA"  , 0, 3, 0 },;
					  { "Altera"                     , "U_FTCAD01VA"  , 0, 4, 0 },; 
					  { "Excluir"                    , "U_FTCAD01VA"  , 0, 5, 0 } }
Return aRotina


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  08.08.2018                                                              |
 | Desc:  -                                                                       |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function FTCAD01VA(cAlias, nReg, nOpc)

Local aArea		 := GetArea()
Local oDlg
Local nGDOpc     := /* GD_INSERT +  */GD_UPDATE /* + GD_DELETE */
Local nOpcA		 := 0
Local aSize      := {}
Local aObjects   := {}
Local aInfo      := {}
Local aPObjs     := {}
Local aButtons	 := {}, _aField := {}
Local aHead		 := {}
Local nI

Private _nSelec	 := 0
Private oGrp1 := nil, oGrp2 := nil, oGrp3 := nil
Private oSD2GDad := nil, aSD2Head  := {}, aSD2Cols  := {}, nUSD2 := 0
Private oMGet	 := nil, oEnch := nil
Private aGets    := {}
Private aTela    := {}
Private nPosQuant	:= 0

aSize := MsAdvSize( .T. )
AAdd( aObjects, { 100, 45, .T., .T. } )
AAdd( aObjects, { 100, 35, .T., .T. } )
AAdd( aObjects, { 100, 20, .T., .T. } )
aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T., .F.)

RegToMemory( cAlias, nOpc == 3 )

If nOpc == 3
	M->ZAB_CODIGO := GETSXENUM('ZAB', 'ZAB_CODIGO')
	
	If (FUNNAME() == "VAPCPM01")
		M->ZAB_BAIA   := aRotZAB[1]
		M->ZAB_DTABAT := aRotZAB[2]
		M->ZAB_PESOLQ := aRotZAB[3] 
		M->ZAB_QTABAT := aRotZAB[4]
		M->ZAB_QTGRAX := aRotZAB[5]
	EndIf
EndIf	

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],0 TO aSize[6], aSize[5] PIXEL of oMainWnd
oDlg:lMaximized := .T.

/* #################################################################################################################### */
oGrp1  := TGroup():New(aPObjs[1,1],aPObjs[1,2],aPObjs[1,3],aPObjs[1,4],"Dados do abate",oDlg,,, .T.,)
oMGet  := MsMGet():New( cAlias, nReg, Iif(nGDOpc==0,2,nOpc),,,,, {aPObjs[1,1]+7,aPObjs[1,2],aPObjs[1,3],aPObjs[1,4]},,,,,, oGrp1 ) // ,,,.F./* lColumn */,nil /* caTela */,,.T. /* lProperty */)
//oMGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

/* #################################################################################################################### */
oGrp2  := TGroup():New(aPObjs[2,1],aPObjs[2,2],aPObjs[2,3], aPObjs[2,4],"Itens da Nota para relacionamento",oDlg,,, .T.,)
// If GetMV("MV_RASTRO",,"S") == "S"
	// cWhere := " JOIN SF4010 ON D2_TES = F4_CODIGO AND SF4010.D_E_L_E_T_=' ' AND SD2010.D_E_L_E_T_=' ' "
	// cWhere += " WHERE F4_TRANFIL = '2' AND rTrim(D2_LOTECTL) = '"+Iif(Empty(M->ZAB_BAIA),"NAO_TRAZER_NADA", M->ZAB_BAIA)+"' 
// Else
	cWhere := " JOIN SF4010 ON D2_TES = F4_CODIGO AND SF4010.D_E_L_E_T_=' ' AND SD2010.D_E_L_E_T_=' ' "
	cWhere += " WHERE	D2_XCODABT = '"+M->ZAB_CODIGO+"'
// EndIf

aAdd( aHead, { 'D2_XCODABT','D2_XDTABAT','D2_FILIAL','D2_DOC','D2_SERIE','D2_ITEM','D2_COD',;
		       'D2_DESC','D2_LOTECTL','D2_QUANT','D2_EMISSAO','D2_XNRPSAG','D2_XPESLIQ',;
			   'D2_PRCVEN','D2_TOTAL','D2_CUSTO1' } )
U_CargaDados( "SD2", @aSD2Head, @aSD2Cols, @nUSD2, aHead, cWhere )	
nPMrkSD2   := aScan( aSD2Head, { |x| AllTrim(x[2]) == 'SD2_MARK'   } )
nPosQuant  := aScan( aSD2Head, { |x| AllTrim(x[2]) == "D2_QUANT"   } )
nPosCodAbt := aScan( aSD2Head, { |x| AllTrim(x[2]) == "D2_XCODABT" } )
nPosRecno  := aScan( aSD2Head, { |x| AllTrim(x[2]) == "R_E_C_N_O_" } )
// aSD2Cols[ 1, nPMrkSD2] := "LBNO"
oSD2GDad := MsNewGetDados():New( aPObjs[2][1]+7, aPObjs[2][2], aPObjs[2][3], aPObjs[2][4], nGDOpc, /* "U_f18LinhaOk" */;
						, , , , , , , , , oGrp2, aClone(aSD2Head), aClone( aSD2Cols ) )
//oSD2GDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	
oSD2GDad:oBrowse:BlDblClick := { || iIf(/* oSD2GDad:oBrowse:nColPos == 1 .and. */ fCanSelGrid(nOpc), U_SetMark(oSD2GDad, , nPMrkSD2, "ALL"), oSD2GDad:EditCell() ) }

/* #################################################################################################################### */
oGrp3 := TGroup():New(aPObjs[3,1],aPObjs[3,2],aPObjs[3,3], aPObjs[3,4],"Totalizadores" ,oDlg,,, .T.,)
//                            Titulo,     Campo, Tipo, Tamanho,  Decimal,       Pict,                  Valid, Obrigat, Nivel,                           Inic Padr, F3, When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
aAdd(_aField, { "Total Selecionado: ", "_nSelec",  "N",   	 4,        0, "@E 9,999", /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
oEnch := MsMGet():New(,,2,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{aPObjs[3,1]+7,aPObjs[3,2],aPObjs[3,3], aPObjs[3,4]},/*aAlterEnch*/,/*nModelo*/,;
						/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oGrp3,/*lF3*/,/*lMemoria*/,.F./*lColumn*/,;
						nil/* caTela */,/*lNoFolder*/,.T./*lProperty*/,_aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,/* cTela */)
//oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
If nOpc <> 3
	For nI := 1 to Len( oSD2GDad:aCols )
		_nSelec += oSD2GDad:aCols[ nI, nPosQuant ]
	Next nI
	oEnch:ENCHREFRESHALL()
EndIf

/* #################################################################################################################### */
aAdd( aButtons , {'Mark All (Alt+A)' , { || fMarkAll() }, 'Mark All (Alt+A)' , 'Mark All (Alt+A)' } )
SetKey( K_ALT_A,   {|| fMarkAll() } )
aAdd( aButtons , {'Inverte Mark (Alt+I)' , { || fInverteMark() }, 'Inverte Mark (Alt+I)' , 'Inverte Mark (Alt+I)' } )
SetKey( K_ALT_I,   {|| fInverteMark() } )

aAdd( aButtons , {'Parametros (F12)' , { || LoadGrid() }, 'Parametros (F12)' , 'Parametros (F12)' } )
SetKey( VK_F12,   {|| LoadGrid() } )

ACTIVATE MSDIALOG oDlg ;
          ON INIT EnchoiceBar(oDlg,;
				  { || nOpcA := 1, Iif( VldOk(nOpc) .and. Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)},;
				  { || nOpcA := 0, oDlg:End() },, aButtons )

If nOpcA == 1

	If nOpc == 3 .or. nOpc == 4

		Begin Transaction     
			DbSelectArea(cAlias)
			DbSetOrder(1) // Z2_FILIAL+Z2_ASSUNTO+Z2_OCORREN+Z2_SOLUCAO+Z2_RESULTA
			RecLock( cAlias, !DbSeek( xFilial('ZAB') + M->ZAB_CODIGO ))
				U_GrvCpo(cAlias)
			(cAlias)->(MsUnlock())
			
			// Atualizacao SD2
			For nI := 1 to Len(oSD2GDad:aCols)
				If oSD2GDad:aCols[ nI, nPMrkSD2 ] == "LBTIK" .and. oSD2GDad:aCols[ nI, nPosRecno ] > 0
					SD2->( DbGoTo(oSD2GDad:aCols[ nI, nPosRecno ]) )
					RecLock('SD2', .F.)
						If !oSD2GDad:aCols[nI][ Len(oSD2GDad:aCols[1]) ]
							if !Empty(SD2->D2_XCODABT) .and. SD2->D2_XCODABT <> M->ZAB_CODIGO
								if MsgYesNo("Item ja esta preenchido com o codigo: <b>"+SD2->D2_XCODABT+"</b>, deseja atualizar para: <b>" + M->ZAB_CODIGO + "</b>?")
									SD2->D2_XCODABT := M->ZAB_CODIGO
								EndIf
							Else
								SD2->D2_XCODABT := M->ZAB_CODIGO
							EndIf	
						EndIf
					SD2->(MsUnLock())
				EndIf
			Next nI
			
			If nOpc == 3
				While __lSX8
					ConfirmSX8()
				EndDo
			EndIf
			
		End Transaction

	ElseIf nOpc == 5
		Begin Transaction   
			ValC1Del()
				
			RecLock('ZAB', .F.)
				ZAB->( DbDelete() )
			ZAB->(MsUnLock())
		End Transaction
	EndIf
Else
	If nOpc == 3
		While __lSX8
			RollBackSX8()
		EndDo
	EndIf
EndIf

Return nil


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  08.08.2018                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function VldOk(nOpc)
Local lRet 		:= .T.
Local cAlias	:= ""
Local _cQry 	:= ""

Default nOpc		:= 0

If GetMV("MV_RASTRO",,"S") == "S" .and. ( nOpc == 3 .or. nOpc == 4 ) .and. __lVld
	cAlias	:= GetNextAlias()
	_cQry := " WITH " + CRLF
	_cQry += " 	FATURAMENTO AS ( " + CRLF
	_cQry += " 		SELECT D2_LOTECTL, SUM(D2_QUANT) D2_QUANT " + CRLF
	_cQry += " 		FROM SD2010 " + CRLF
	// _cQry += " 		WHERE D_E_L_E_T_=' ' AND D2_LOTECTL = '"+AllTrim( M->ZAB_BAIA )+"' " + CRLF
	_cQry += " 		WHERE D_E_L_E_T_=' '" + CRLF
	_cQry += " 			 AND ( D2_XCODABT = '"+AllTrim( M->ZAB_CODIGO )+"' " + CRLF
	_cQry += " 			 	  OR D2_LOTECTL = '"+AllTrim( M->ZAB_BAIA )+"' ) " + CRLF
	_cQry += " 		GROUP BY D2_LOTECTL " + CRLF
	_cQry += " 	), " + CRLF
	_cQry += "" + CRLF
	_cQry += " 	ABATE AS ( " + CRLF
	_cQry += " 		SELECT ZAB_BAIA, SUM(ZAB_QTABAT) ZAB_QTABAT " + CRLF
	_cQry += " 		FROM ZAB010 " + CRLF
	// _cQry += " 		WHERE D_E_L_E_T_=' ' AND ZAB_BAIA = '"+AllTrim( M->ZAB_BAIA )+"' " + CRLF
	_cQry += " 		WHERE D_E_L_E_T_=' '" + CRLF
	_cQry += " 			AND ( ZAB_CODIGO = '"+AllTrim( M->ZAB_CODIGO )+"' " + CRLF
	_cQry += " 			     OR ZAB_BAIA = '"+AllTrim( M->ZAB_BAIA )+"' )" + CRLF
	_cQry += " 		GROUP BY ZAB_BAIA " + CRLF
	_cQry += " 	) " + CRLF
	_cQry += "" + CRLF
	// _cQry += " 	SELECT D2_LOTECTL, D2_QUANT, ISNULL(ZAB_QTABAT,0) ZAB_QTABAT " + CRLF
	_cQry += "  SELECT SUM(D2_QUANT) D2_QUANT, SUM(ISNULL(ZAB_QTABAT,0)) ZAB_QTABAT " + CRLF
	_cQry += " 	FROM FATURAMENTO " + CRLF
	_cQry += " 	LEFT JOIN ABATE ON D2_LOTECTL=ZAB_BAIA " + CRLF

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry),(cAlias),.F.,.F.) 

	If lRet := !(cAlias)->(Eof())
		/* 
		D2_LOTECTL	D2_QUANT	ZAB_QTABAT
		60-15     	116			115
		*/
		
		if (cAlias)->D2_QUANT < ( (cAlias)->ZAB_QTABAT + Iif(nOpc==3, M->ZAB_QTABAT, 0) )
			cMSG := 'Nao foram localizadas Notas Faturadas em quant. suficiente ao informado no valor abatido: <b>'+ ;
						AllTrim(Str( ( (cAlias)->ZAB_QTABAT + Iif(nOpc==3, M->ZAB_QTABAT, 0) ) )) +'</b>'
			MsgInfo( cMSG , 'Aviso')
			lRet := .F.
		EndIf
	EndIf

	(cAlias)->( DbCloseArea() )
EndIf

Return lRet


Static Function ValC1Del() 	
	// MsgAlert("Chamada antes do delete")
Local cUpd := ""

	cUpd := " update " + retSQLName("SD2")
	cUpd += "   set D2_XCODABT = ' ' "
	cUpd += " where D2_XCODABT = '" + ZAB->ZAB_CODIGO + "'"
	
	if (TCSqlExec(cUpd) < 0)
		conout("TCSQLError() " + TCSQLError())
	else
		MsgInfo("Registros disviculados com sucesso! ", "Aviso")
	endif
Return .T.

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.08.2018                                                              |
 | Desc:  -                                                                       |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function LoteNaD2( cLoteCTL )
Local lRet 		:= .F.
Local aHead		:= {}

__lVld			:= .T.

nUSD2 	 := 0
aSD2Head := {}
aSD2Cols :={}
cWhere := " JOIN SF4010 ON D2_TES = F4_CODIGO AND SF4010.D_E_L_E_T_=' ' AND SD2010.D_E_L_E_T_=' ' "
cWhere += " WHERE	rTrim(D2_LOTECTL) = '"+cLoteCTL+"' AND D2_TIPO = 'N' "

aAdd( aHead, { 'D2_XCODABT','D2_XDTABAT','D2_FILIAL','D2_DOC','D2_SERIE','D2_ITEM','D2_COD',;
		       'D2_DESC','D2_LOTECTL','D2_QUANT','D2_EMISSAO','D2_XNRPSAG','D2_XPESLIQ',;
			   'D2_PRCVEN','D2_TOTAL','D2_CUSTO1' } )
U_CargaDados( "SD2", aSD2Head, @aSD2Cols, @nUSD2, aHead, cWhere )	

oSD2GDad:aCols := aClone( aSD2Cols )
oSD2GDad:Refresh()

if nUSD2 > 0 .OR. Empty(cLoteCTL)
	lRet := .T.
EndIf

Return lRet



/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  03.08.2018                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fMarkAll()

Local nTotal := 0
Local nI

	For nI := 1 to Len( oSD2GDad:aCols )
		oSD2GDad:aCols[ nI, nPMrkSD2 ] := "LBTIK"
		/* 
		If !fCanSelGrid(.F.)
			oSD2GDad:aCols[ nI, nPMrkSD2 ] := "LBNO"
		EndIf 
		*/
	Next nI
	
For nI := 1 to Len( oSD2GDad:aCols )
	nTotal += oSD2GDad:aCols[ nI, nPosQuant ]
Next nI

_nSelec := nTotal
oEnch:ENCHREFRESHALL()
Return nil


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  03.08.2018                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fInverteMark()
Local nTotal := 0
Local nI
	For nI := 1 to Len( oSD2GDad:aCols )
		oSD2GDad:aCols[ nI, nPMrkSD2 ] := Iif(oSD2GDad:aCols[ nI, nPMrkSD2 ]=="LBTIK", "LBNO", "LBTIK" )

		if oSD2GDad:aCols[ nI, nPMrkSD2 ] == "LBTIK"
			nTotal += oSD2GDad:aCols[ nI, nPosQuant ]
		EndIf
		/* If oSD2GDad:aCols[ nI, nPMrkSD2 ] == "LBTIK" .and. !fCanSelGrid(.F.)
			oSD2GDad:aCols[ nI, nPMrkSD2 ] := "LBNO"
		EndIf 
		*/
	Next nI
		
	_nSelec := nTotal
	oEnch:ENCHREFRESHALL()
	
Return nil


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.08.2018                                                              |
 | Alt.:  08.08.2018                                                              |
 | Desc:  -> Na ultima alteracao, esta funcao, nao mais servira para validar per- |
 |        missão para selecioncar. Apenas atulizará campo totalizador.			  |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fCanSelGrid(/* nOpc, lMostraLin */)
Local lRet 		:= .T.
Local nI
Local nTotal	:= 0
Local cMSG		:= ""
/* 
Default lMostraLin 	:= .T.
Default nOpc		:= 0
 */
For nI := 1 to Len( oSD2GDad:aCols )
	If nI <> oSD2GDad:oBrowse:nAt
		If oSD2GDad:aCols[ nI, nPMrkSD2 ] == "LBTIK"
			nTotal += oSD2GDad:aCols[ nI, nPosQuant ]
		EndIf
	Else
		If oSD2GDad:aCols[ nI, nPMrkSD2 ] == "LBNO" // "LBTIK"
			nTotal += oSD2GDad:aCols[ nI, nPosQuant ]
		//Else // nao precisa fazer nada, pq eu rodo a grid toda novamente, e comeco com o TOTALIZADOR zerado.
			//nTotal -= oSD2GDad:aCols[ nI, nPosQuant ]
		EndIf
	EndIf
Next nI

_nSelec := nTotal
oEnch:ENCHREFRESHALL()
/* 

If nTotal > M->ZAB_QTABAT
	lRet := .F.
	
	If lMostraLin
		cMSG := 'O(s) item(s) selecionado(s): na linha: <b>' + AllTrim(Str(oSD2GDad:oBrowse:nAt)) + '</b> totaliza um valor maior ao abatido: <b>'+ AllTrim(Str(M->ZAB_QTABAT)) +'</b>'
	Else	
		cMSG := 'O(s) item(s) selecionado(s) totaliza um valor maior ao abatido: <b>'+ AllTrim(Str(M->ZAB_QTABAT)) +'</b>'
	EndIf
	MsgInfo( cMSG , 'Aviso')
EndIf 
*/

Return lRet

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.08.2018                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function CargaDados( cTemp, aSD2Head, aSD2Cols, nUSD2, aHead, cWhere)
	Local aArea		:= GetArea()
	Local lRet 		:= .F.
	Local cAlias    := GetNextAlias()
	Local _cQry 	:= ""
	Local aSD2AUXCols	:= {}
	
	Local nUsado 	:= 0
	Local cPrefix  	:= Iif(Substr( cTemp, 1, 1) == 'S', SubStr( cTemp, 2, 2), cTemp)
	Local nI		:= 0
	
	Default aHead	:= {}
	
    DbSelectArea("SX3")
    SX3->(DbSetOrder(1))
    SX3->(dbSeek(cTemp))
    
    aSD2Head:={}
    AAdd(aSD2Head, { " ", Padr( cTemp + "_MARK  ", 10), "@BMP", 1, 0, .F., "", "C", "", "V", "", "", "", "V", "", "", "" } )
	If Empty( aHead )
		
		While SX3->X3_ARQUIVO == cTemp .AND. !SX3->(EOF())
		
			if (X3USO(SX3->X3_USADO) .AND. CNIVEL >= SX3->X3_NIVEL .AND. SX3->X3_CONTEXT # "V") .OR.;
			   (SX3->X3_PROPRI == "U" .AND. SX3->X3_CONTEXT!="V" .AND. SX3->X3_TIPO <> 'M')
			   
				nUsado += 1
				Aadd(aSD2Head, {TRIM(X3_TITULO), X3_CAMPO , X3_PICTURE, X3_TAMANHO, X3_DECIMAL,X3_VALID, X3_USADO  , X3_TIPO   , X3_ARQUIVO, X3_CONTEXT})		
			EndIf
			SX3->(dbSkip())
			
		EndDo
		
	Else

		For nI := 1 to Len( aHead[1] )
			SX3->(DbSetOrder(2))
			If SX3->(dbSeek( aHead[1, nI] ))
				
				nUsado += 1
				Aadd(aSD2Head, {TRIM(X3_TITULO), X3_CAMPO , X3_PICTURE, X3_TAMANHO, X3_DECIMAL,X3_VALID, X3_USADO  , X3_TIPO   , X3_ARQUIVO, X3_CONTEXT})		
			EndIf
		Next nI
		
	EndIf
    AAdd(aSD2Head, { "R_E_C_N_O_", "R_E_C_N_O_", "999999999", 9, 0, .F., "", "N", "", "V", "", "", "", "V", "", "", "" } )
	
	if Empty(cWhere)
	
		aSD2AUXCols := Array( Len( aSD2Head ) + 1 )
		For nI := 1 To Len( aSD2Head )
			If aSD2Head[nI][2] == cTemp + "_MARK  "
				aSD2AUXCols[nI] := "LBNO"
			ElseIf aSD2Head[nI][2] == cTemp + "R_E_C_N_O_"
				aSD2AUXCols[nI] := 0
			Else			
				aSD2AUXCols[nI] := CriaVar( aSD2Head[nI, 2], .T. )
			EndIf
		Next nI
	
		aAdd( aSD2Cols , aClone( aSD2AUXCols ) )
	
	Else
		
		_cQry := ""
		_cQry += " SELECT * " + CRLF
		_cQry += " FROM	    " + RetSQLName( cTemp ) + CRLF
		_cQry += cWhere

		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(_cQry)),(cAlias),.F.,.F.)
		
		While !(cAlias)->(Eof())
			
			aSD2AUXCols := Array( Len( aSD2Head ) + 1 )
			For nI := 1 To Len( aSD2Head )
				If aSD2Head[nI][2] == cTemp + "_MARK  "
					If Empty((cAlias)->D2_XCODABT) .OR. (cAlias)->D2_XCODABT <> M->ZAB_CODIGO
						aSD2AUXCols[nI] := "LBNO"
					Else
						aSD2AUXCols[nI] := "LBTIK"
					EndIf
				ElseIf aSD2Head[nI][2] == cTemp + "R_E_C_N_O_"
					aSD2AUXCols[nI] := (cAlias)->R_E_C_N_O_
				Else			
					aSD2AUXCols[nI] := (cAlias)->&( aSD2Head[nI, 2] )
				EndIf
			Next nI
			aAdd( aSD2Cols , aClone( aSD2AUXCols ) )
	
			(cAlias)->(DbSkip())
		EndDo

	EndIf
	
	nUSD2 := len(aSD2Cols)
	
	(cAlias)->(DbCloseArea())
	RestArea(aArea)
Return Nil


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  08.08.2018                                                              |
 | Desc:  -                                                                       |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local aRegs		:= {}
Local i, j

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

aAdd(aRegs,{cPerg, "01", "Data Emissao De?"  , "", "", "MV_CH1", "D", TamSX3("D2_EMISSAO")[1], TamSX3("D2_EMISSAO")[2], 0, "G", ""		  , "MV_PAR01" , "", "","",""      ,"","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg, "02", "Data Emissao Ate?" , "", "", "MV_CH2", "D", TamSX3("D2_EMISSAO")[1], TamSX3("D2_EMISSAO")[2], 0, "G", ""        , "MV_PAR02" , "", "","",""      ,"","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg, "03", "Data Abate De?"    , "", "", "MV_CH3", "D", TamSX3("D2_XDTABAT")[1], TamSX3("D2_XDTABAT")[2], 0, "G", ""		  , "MV_PAR03" , "", "","",""      ,"","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg, "04", "Data Abate Ate?"   , "", "", "MV_CH4", "D", TamSX3("D2_XDTABAT")[1], TamSX3("D2_XDTABAT")[2], 0, "G", ""		  , "MV_PAR04" , "", "","",""      ,"","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg, "05", "Nota De?"    		 , "", "", "MV_CH5", "C", TamSX3("D2_DOC")[1]	 , TamSX3("D2_DOC")[2]	  , 0, "G", ""		  , "MV_PAR05" , "", "","",""	   ,"","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg, "06", "Nota Ate?"   		 , "", "", "MV_CH6", "C", TamSX3("D2_DOC")[1]	 , TamSX3("D2_DOC")[2]	  , 0, "G", "NaoVazio", "MV_PAR06" , "", "","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg, "07", "Serie ?"    	     , "", "", "MV_CH7", "C", TamSX3("D2_SERIE")[1]  , TamSX3("D2_SERIE")[2]  , 0, "G", ""		  , "MV_PAR07" , "", "","",""	   ,"","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg, "08", "Cliente De?"		 , "", "", "mv_ch8", "C", TamSX3("D2_CLIENTE")[1], TamSX3("D2_CLIENTE")[2], 0, "G", ""		  , "mv_par08" , "", "","",""	   ,"","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg, "09", "Cliente Ate?"		 , "", "", "mv_ch9", "C", TamSX3("D2_CLIENTE")[1], TamSX3("D2_CLIENTE")[2], 0, "G", "NaoVazio", "mv_par09" , "", "","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  08.08.2018                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function LoadGrid()

Local lRet 		:= .F.
Local aHead		:= {}

	If !Pergunte(cPerg, .T.)
		Return Nil
	EndIf

__lVld			:= .F.

nUSD2 	 := 0
aSD2Head := {}
aSD2Cols :={}
cWhere   := " WHERE	    D2_FILIAL  = '"+xFilial("SD2")+"'
cWhere   += "		AND D2_DOC	   BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
If !Empty(MV_PAR07)
	cWhere   += "		AND D2_SERIE   = '"+MV_PAR07+"'
EndIf
cWhere   += "		AND D2_CLIENTE BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"'
If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
	cWhere   += "		AND D2_EMISSAO BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'
EndIf
If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
	cWhere   += "		AND D2_XDTABAT BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"'
EndIf
cWhere   += "		AND D2_TIPO = 'N' AND D2_GRUPO IN ('01','05','BOV') AND D_E_L_E_T_=' '


aAdd( aHead, { 'D2_XCODABT','D2_XDTABAT','D2_FILIAL','D2_DOC','D2_SERIE','D2_ITEM','D2_COD',;
		       'D2_DESC','D2_LOTECTL','D2_QUANT','D2_EMISSAO','D2_XNRPSAG','D2_XPESLIQ',;
			   'D2_PRCVEN','D2_TOTAL','D2_CUSTO1' } )
U_CargaDados( "SD2", aSD2Head, @aSD2Cols, @nUSD2, aHead, cWhere )	

oSD2GDad:aCols := aClone( aSD2Cols )
oSD2GDad:Refresh()

if nUSD2 > 0 
	lRet := .T.
EndIf

Return lRet
	
Return nil
