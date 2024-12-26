//#include "Protheus.ch"
//#include "TryException.ch"
//#include "TopConn.ch"
//
//#define greater(ax, bx) Iif(ax > bx, ax, bx)
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  29.12.2016                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
User Function VAEST007()
//Local oBrowse
//Local cAlias    	:= "Z05"
//
//Private cCadastro 	:= "Processamento do manejo"
//Private aRotina 	:= MenuDef()
//
//	oBrowse := FWMBrowse():New()
//	oBrowse:SetAlias(cAlias)
//	oBrowse:SetDescription(cCadastro)
//	oBrowse:SetFilterDefault("Z05_TIPO=='1'")
//
//	oBrowse:AddLegend( "Z05_STATUS == '0'", "RED"    , "Incompleto" )
//	oBrowse:AddLegend( "Z05_STATUS == '1'", "YELLOW" , "Aberto" )
//	oBrowse:AddLegend( "Z05_STATUS == '2'", "GREEN"  , "Fechado" )
//	oBrowse:AddLegend( "Z05_STATUS == '3'", "BLACK"  , "Processado" )
//
//	oBrowse:Activate()
Return nil
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  29.12.2016                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//Static Function MenuDef()
//	Local aRotina := {  { "Pesquisar"                  , "axPesqui"     , 0, 1, 0 },;
//						{ "Visualizar"                 , "U_fEst007"    , 0, 2, 0 },;
//						{ "Recepção"                   , "U_fEst007"    , 0, 3, 0 },;
//						{ "Finaliza Recepção"          , "U_fEst007"    , 0, 4, 0 },;
//						{ "Encerra Recepção"           , "U_fEncRes"    , 0, 4, 0 },; 
//						{ "Reabre Recepção"            , "U_fReaRes"    , 0, 4, 0 },; 
//						{ "Excluir"                    , "U_fEst007"    , 0, 5, 0 },;
//						{ "Legenda"   				   , "U_fLegenda"   , 0, 6, 0 } }
//Return aRotina
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  02.01.2017                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//User Function fEst007(cAlias, nReg, nOpc) // TELA
//Local  nOpcE		:= aRotina[nOpc][4] 
//local lContinua 	:= .t.
//
//	if nOpc == 3
//		RecLock('Z05', .T.)
//			Z05->Z05_FILIAL := xFilial('Z05')
//			Z05->Z05_SEQUEN := u_fChaveSX8('Z05','Z05_SEQUEN')
//			Z05->Z05_TIPO   := '1'
//			Z05->Z05_DATA	:= dDataBase
//			Z05->Z05_STATUS := "0"
//		Z05->(MsUnLock())
//		
//		DbSelectArea('Z06')
//		DbSetOrder(1)
//		DbSeek(xFilial('Z06')+Z05->Z05_SEQUEN)
//				
//		DbSelectArea('Z07')
//		DbSetOrder(1)
//		DbSeek(xFilial('Z07')+Z05->Z05_SEQUEN)
//				
//	ElseIf Z05->Z05_STATUS >= '2' .and. nOpc <> 2
//		lContinua := .f.
//		ShowHelpDlg("FEST00701", {"Não é possivel " + Iif(nOpc == 5, "Excluir", "Alterar") + " um manejo Fechado ou com Nota Fiscal emitida."}, 1, {"Por favor, retorne o estado do manejo para Aberto antes de exclui-lo."}, 1)
//	
//	Elseif nOpc == 4
//		DbSelectArea('Z06')
//		DbSetOrder(1)
//		DbSeek(xFilial('Z06')+Z05->Z05_SEQUEN)
//		
//		DbSelectArea('Z07')
//		DbSetOrder(1)
//		DbSeek(xFilial('Z07')+Z05->Z05_SEQUEN)
//	EndIf
//
//    if lContinua
//    	MsUnLockAll()
//    	fManejo(cAlias, nReg, iif(nOpc==3, 4, nOpc), nOpcE )
//    endif
//
//Return nil
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  29.12.2016                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//Static Function fManejo(cAlias, nReg, nOpc, nOpcE) // TELA)
//
//Local aArea 	    := GetArea()  
//Local aButtons	    := {}
//Local nOpca			:= 0
//Local aSize 		:= {}
//Local aObjects 		:= {}
//Local aInfo			:= {}
//Local aPObjs 		:= {}
//Local oDlg
//Local nQtApont		:= 0
//Local nQtPedCom		:= 0
//Local nI			:= 0
//
//Private cSequencia  := CriaVar('Z05_SEQUEN', .F.)
//Private cLote		:= CriaVar('Z05_LOTE'  , .F.)
//Private cCurral		:= CriaVar('Z05_CURRAL', .F.)
//Private cPedido     := CriaVar('Z05_PEDIDO', .F.)
//Private dData   	:= CriaVar('Z05_DATA'  , .F.)
//Private cContRF		:= CriaVar('Z05_CONTRF', .F.)
//Private nPesoTT 	:= CriaVar('Z05_PESOTT', .F.)
//Private nQtdePC		:= CriaVar('Z05_QTDEPC', .F.)
//Private nQApont		:= CriaVar('Z05_QTAPON', .F.)
//Private nFalta      := CriaVar('Z05_FALTA' , .F.)
///* ------------------------------------------------ */
//Private cZ07RFID    := CriaVar('Z07_RFID'  , .F.)
//Private cItemZ07	:= CriaVar('Z07_ITEM'  , .F.)
//private nZ07Peso	:= CriaVar('Z07_PESO'  , .F.)
//private cZ07ItemPC  := CriaVar('Z07_ITEMPC', .F.)
//private cZ07Produt  := CriaVar('Z07_PRODUT', .F.)
//private cZ07DescB1  := CriaVar('Z07_DESCB1', .F.)
//private nZ07Idade   := CriaVar('Z07_IDADE' , .F.)
//private dZ07DtNas   := CriaVar('Z07_DTNASC', .F.)
//
//Private aGets       := {}
//Private aTela       := {}
//
//Private oEncZ05
//Private oZ06, aHZ06 := {}, aCZ06 := {}
//Private oZ07, aHZ07 := {}, aCZ07 := {}
//
//Private aFieldPES   := {}
//
////                       Titulo,        Campo,     Tipo,                 Tamanho,                 Decimal,                          Pict,                          Valid,  Obrigat, Nivel,  Inic Padr,    F3,                  When, Visual,  Chave,                                CBox, Folder, N Alteravel, PictVar, Gatilho
//aAdd(aFieldPES, { "Sequencia"     , "cSequencia",   "C", TamSX3("Z07_SEQUEN")[1], TamSX3("Z07_SEQUEN")[2], PesqPict("Z07", "Z07_SEQUEN"), { || U_VdCpoZ07('Z07_SEQUEN') },      .F.,     1, "" 		,    "",                    "",    .T.,    .T.,                                   "",      1,         .F.,      "",     "N"} )
//aAdd(aFieldPES, { "Item"          , "cItemZ07"  ,   "C", TamSX3("Z07_ITEM")[1]  , TamSX3("Z07_ITEM")[2]  , PesqPict("Z07", "Z07_ITEM")  , { || U_VdCpoZ07('Z07_ITEM'  ) },      .F.,     1, "" 		,    "",                    "",    .T.,    .T.,                                   "",      1,         .F.,      "",     "N"} )
//aAdd(aFieldPES, { "RF ID"         , "cZ07RFID"  ,   "C", TamSX3("Z07_RFID")[1]  , TamSX3("Z07_RFID")[2]  , PesqPict("Z07", "Z07_RFID")  , { || U_VdCpoZ07('Z07_RFID'  ) },      .F.,     1, "" 		,    "", {||cContRF == 'S'}   ,    .F.,    .T.,                                   "",      1,         .F.,      "",     "N"} )
//aAdd(aFieldPES, { "Peso"          , "nZ07Peso"  ,   "C", TamSX3("Z07_PESO")[1]  , TamSX3("Z07_PESO")[2]  , PesqPict("Z07", "Z07_PESO")  , { || U_VdCpoZ07('Z07_PESO'  ) },      .T.,     1, "" 		,    "",                    "",    .F.,    .F.,                                   "",      1,         .F.,      "",     "N"} )
//aAdd(aFieldPES, { "Item P.Compra" , "cZ07ItemPC",   "C", TamSX3("Z07_ITEMPC")[1], TamSX3("Z07_ITEMPC")[2], PesqPict("Z07", "Z07_ITEMPC"), { || U_VdCpoZ07('Z07_ITEMPC') },      .T.,     1, "" 		,    "",                    "",    .F.,    .F.,                                   "",      1,         .F.,      "",     "N"} )
//aAdd(aFieldPES, { "Produto"       , "cZ07Produt",   "C", TamSX3("Z07_PRODUT")[1], TamSX3("Z07_PRODUT")[2], PesqPict("Z07", "Z07_PRODUT"), { || U_VdCpoZ07('Z07_PRODUT') },      .T.,     1, "" 		,    "",                    "",    .T.,    .F.,                                   "",      1,         .F.,      "",     "N"} )
//aAdd(aFieldPES, { "Descricao"     , "cZ07DescB1",   "C", TamSX3("Z07_DESCB1")[1], TamSX3("Z07_DESCB1")[2], PesqPict("Z07", "Z07_DESCB1"), { || U_VdCpoZ07('Z07_DESCB1') },      .F.,     1, "" 		,    "",                    "",    .T.,    .F.,                                   "",      1,         .F.,      "",     "N"} )
//aAdd(aFieldPES, { "Lote"		  , "cLote"     ,   "C", TamSX3("Z07_LOTE")[1]  , TamSX3("Z07_LOTE")[2]  , PesqPict("Z07", "Z07_LOTE")  , { || U_VdCpoZ07('Z07_LOTE'  ) },      .F.,     1, "" 		,    "",                    "",    .T.,    .F.,                                   "",      1,         .F.,      "",     "N"} )
//aAdd(aFieldPES, { "Curral"        , "cCurral"   ,   "C", TamSX3("Z07_CURRAL")[1], TamSX3("Z07_CURRAL")[2], PesqPict("Z07", "Z07_CURRAL"), { || U_VdCpoZ07('Z07_CURRAL') },      .T.,     1, ""      ,    "",                    "",    .T.,    .F.,                                   "",      1,         .F.,      "",     "N"} )
//aAdd(aFieldPES, { "Idade"         , "nZ07Idade" ,   "C", TamSX3("Z07_IDADE")[1] , TamSX3("Z07_IDADE")[2] , PesqPict("Z07", "Z07_IDADE") , { || U_VdCpoZ07('Z07_IDADE' ) },      .T.,     1, ""      ,    "",                    "",    .F.,    .F.,                                   "",      1,         .F.,      "",     "N"} )
//aAdd(aFieldPES, { "Dt. Nasc."     , "dZ07DtNas" ,   "C", TamSX3("Z07_DTNASC")[1], TamSX3("Z07_DTNASC")[2], PesqPict("Z07", "Z07_DTNASC"), { || U_VdCpoZ07('Z07_DTNASC') },      .T.,     1, ""      ,    "",                    "",    .T.,    .F.,                                   "",      1,         .F.,      "",     "N"} )	
//
//
////ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
////³ FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
////ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
//cSeek  := xFilial("Z06")+Z06->Z06_SEQUEN+Z06->Z06_ITEMPC
//cWhile := "Z06->Z06_FILIAL+Z06->Z06_SEQUEN+Z06->Z06_ITEMPC"
//FillGetDados( 3,"Z06",1,cSeek,{|| &cWhile },,,,,,,.T.,aHZ06,aCZ06)
//
////ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
////³ FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
////ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
//cSeek  := xFilial("Z07")+Z07->Z07_SEQUEN+Z07->Z07_ITEM
//cWhile := "Z07->Z07_FILIAL+Z07->Z07_SEQUEN+Z07->Z07_ITEM"
//FillGetDados( 3,"Z07",1,cSeek,{|| &cWhile },,,,,,,.T.,aHZ07,aCZ07)
//
//RegToMemory( "Z05", INCLUI )
//RegToMemory( "Z06", ALTERA )
//RegToMemory( "Z07", ALTERA )
//
//aAdd( aButtons , {'Pesagem (Alt+P)' , { || Iif(nOpc==4,CadPessagem(),nil) }, 'Pesagem (Alt+P)' , 'Pesagem (Alt+P)' } )
//SetKey( K_ALT_P,   {|| Iif(nOpc==4,CadPessagem(),nil) } )
//
//aSize := MsAdvSize( .T. )
//AAdd( aObjects, { 100, 25, .T., .T. } )
//AAdd( aObjects, { 100, 25, .T., .T. } ) //grid 1
//AAdd( aObjects, { 100, 50, .T., .T. } ) //grid 2
//aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
//aPObjs := MsObjSize(aInfo, aObjects, .T., .F.)
//
//DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd
//
//oEncZ05:= MsMGet():New("Z05", nReg ,nOpc,,,,,aPObjs[1],,,,,,oDlg,,,.F.,)    
// 
//oFont := TFont():New('Arial Black',,-16,.T.)
//oSay1:= TSay():New(aPObjs[2][1]+3,01,{||'Itens do Pedido'},oDlg,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
//// TDN = http://tdn.totvs.com/display/public/mp/MsNewGetDados
//oZ06 := MsNewGetDados():New( aPObjs[2][1]+15, aPObjs[2][2], aPObjs[2][3], aPObjs[2][4], GD_UPDATE , ;
//							/* "u_VldSZHLin()" */, , /* "+ZH_ITEM" */, { "Z06_QTDROM" }, , , , , , oDlg, ;
//							aClone(aHZ06), aClone(aCZ06) )
//oZ06:Disable()
//
//oSay1:= TSay():New(aPObjs[3][1]+3,01,{||'Itens do Apontamento'},oDlg,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
//oZ07 := MsNewGetDados():New( aPObjs[3][1]+15, aPObjs[3][2], aPObjs[3][3], aPObjs[3][4], GD_DELETE , ;
//							/* "u_x7VldZ07Lin()" */, , "+Z07_ITEM", {"Z07_RFID","Z07_PESO","Z07_ITEMPC","Z07_IDADE"} , , , ;
//							/* "U_x7Vld7CPOs()" */ , , , oDlg, aClone(aHZ07), aClone(aCZ07) )
//oZ07:oBrowse:BlDblClick := { || Iif(nOpc==4,CadPessagem(oZ07),nil) }
//oZ07:Disable()
//
//InicX007(nOpcE)
//
//ACTIVATE MSDIALOG oDlg ;
//          ON INIT EnchoiceBar(oDlg,;
//                              { || nOpcA := 2, Iif( Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)},;
//                              { || nOpcA := 1, oDlg:End() },, aButtons )
//If nOpcA > 0
//	If nOpcE == 5 // exlcuir
//		u_fX007Delete(Z05->Z05_SEQUEN)
//	Else
//		If nOpcA == 1 
//			If Empty(Z05->Z05_CURRAL) .AND. Empty(Z05->Z05_PEDIDO) .AND. Empty(Z05->Z05_CONTRF)
//				Z06->(DbSetOrder(1))
//				If !Z06->(DbSeek(xFilial('Z06')+Z05->Z05_SEQUEN))
//					Z07->(DbSetOrder(1))
//					If !Z07->(DbSeek(xFilial('Z07')+Z05->Z05_SEQUEN))
//						nI := 1
//						u_fX007Delete(Z05->Z05_SEQUEN)
//					EndIf
//				EndIf
//			EndIf
//		EndIf
//		If nI == 0  .and. nOpc == 4
//			GrvGrids(.T.)		
//			
//			RecLock('Z05',.F.)	
//				If M->Z05_QTAPON >= M->Z05_QTDEPC
//					Z05->Z05_STATUS := "2"
//				ElseIf Z05->Z05_STATUS == "0"
//					Z05->Z05_STATUS := "1"
//				EndIf
//			Z05->(MsUnLock())
//		EndIf
//	EndIf
//EndIf
//MsUnLockAll()
//RestArea(aArea)
//Return nil
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  02.01.2017                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//User Function fX007Delete(cSequen)
//Local cUpd := ""
//
////cUpd := "delete from " + retSQLName("Z07") +" "+CRLF
//cUpd := "update " + retSQLName("Z07") +" "+CRLF
//cUpd += "   set D_E_L_E_T_='*'"+CRLF
//cUpd += " where Z07_FILIAL='"+xFilial('Z07')+"' " + CRLF
//cUpd += "   and Z07_SEQUEN='"+cSequen+"' "+CRLF
//cUpd += "   and D_E_L_E_T_=' ' "+CRLF
//TCSqlExec(cUpd)
//
//// cUpd := "delete from " + retSQLName("Z06") +" "+CRLF
//cUpd := "update " + retSQLName("Z06") +" "+CRLF
//cUpd += "   set D_E_L_E_T_='*'"+CRLF
//cUpd += " where Z06_FILIAL='"+xFilial('Z06')+"' " + CRLF
//cUpd += "   and Z06_SEQUEN='"+cSequen+"' "+CRLF
//cUpd += "   and D_E_L_E_T_=' ' "+CRLF
//TCSqlExec(cUpd)
//
//// cUpd := "delete from " + retSQLName("Z05") +" "+CRLF
//cUpd := "update " + retSQLName("Z05") +" "+CRLF
//cUpd += "   set D_E_L_E_T_='*'"+CRLF
//cUpd += " where Z05_FILIAL='"+xFilial('Z05')+"' " + CRLF
//cUpd += "   and Z05_SEQUEN='"+cSequen+"' "+CRLF
//cUpd += "   and D_E_L_E_T_=' ' "+CRLF
//TCSqlExec(cUpd)
//
//Return nil
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  30.12.2016                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//Static Function InicX007(nOpcE)
//Local aCQry := {}
//
//	M->Z05_SEQUEN 	 := Z05->Z05_SEQUEN	
//	M->Z05_CURRAL    := Z05->Z05_CURRAL
//	M->Z05_PEDIDO    := Z05->Z05_PEDIDO
//	M->Z05_LOTE      := Z05->Z05_LOTE
//	M->Z05_DATA      := Z05->Z05_DATA
//	M->Z05_CONTRF    := Z05->Z05_CONTRF
//	M->Z05_PESOTT    := Z05->Z05_PESOTT
//	M->Z05_QTDEPC    := Z05->Z05_QTDEPC
//	M->Z05_QTAPON    := Z05->Z05_QTAPON
//	M->Z05_FALTA     := Z05->Z05_FALTA  
//	
//	Z06->(DbSetOrder(1))
//	If Z06->(DbSeek(xFilial('Z06')+M->Z05_SEQUEN))
//		aCQry := {}
//		
//		While !Z06->(Eof()) .and. Z06->Z06_SEQUEN == M->Z05_SEQUEN
//			aAdd( aCQry, {} )
//			aAdd( aTail(aCQry), { "Z06_SEQUEN" , Z06->Z06_SEQUEN	} )
//			aAdd( aTail(aCQry), { "Z06_ITEMPC" , Z06->Z06_ITEMPC	} )
//			aAdd( aTail(aCQry), { "Z06_PRODUT" , Z06->Z06_PRODUT	} )
//			aAdd( aTail(aCQry), { "Z06_DESCB1" , Posicione('SB1', 1, xFilial('SB1')+Z06->Z06_PRODUT, 'B1_DESC') } )
//			aAdd( aTail(aCQry), { "Z06_LOTE"   , Z06->Z06_LOTE  	} )
//			aAdd( aTail(aCQry), { "Z06_PEDIDO" , Z06->Z06_PEDIDO	} )
//			aAdd( aTail(aCQry), { "Z06_QUANT"  , Z06->Z06_QUANT		} )
//			aAdd( aTail(aCQry), { "Z06_CONFER" , Z06->Z06_CONFER	} )
//			aAdd( aTail(aCQry), { "Z06_FALTA"  , Z06->Z06_FALTA		} )
//			aAdd( aTail(aCQry), { "Z06_SDPEDA" , Z06->Z06_SDPEDA	} )
//			aAdd( aTail(aCQry), { "Z06_QTDROM" , Z06->Z06_QTDROM	} )
//			aAdd( aTail(aCQry), { "Z06_CONFAT" , Z06->Z06_CONFAT	} )
//			aAdd( aTail(aCQry), { "Z06_FALROM" , Z06->Z06_FALROM	} )
//			aAdd( aTail(aCQry), { "Z06_PESO"   , Z06->Z06_PESO 		} )
//			aAdd( aTail(aCQry), { "Z06_REC_WT" , Z06->(Recno())  	} )
//		
//			Z06->(DbSkip())
//		EndDo
//		RecargGrid(oZ06, aHZ06, aCZ06, aCQry, .F. )
//		
//		oZ06:Enable()
//		oZ06:Refresh()
//		
//	EndIf
//	
//	Z07->(DbSetOrder(1))
//	If Z07->(DbSeek(xFilial('Z07')+M->Z05_SEQUEN))
//		aCQry := {}
//		While !Z07->(Eof()) .and. Z07->Z07_SEQUEN == M->Z05_SEQUEN
//			aAdd( aCQry, {} )
//			aAdd( aTail(aCQry), { "Z07_SEQUEN" , Z07->Z07_SEQUEN } )
//			aAdd( aTail(aCQry), { "Z07_ITEM"   , Z07->Z07_ITEM   } )
//			aAdd( aTail(aCQry), { "Z07_RFID"   , Z07->Z07_RFID   } )
//			aAdd( aTail(aCQry), { "Z07_PESO"   , Z07->Z07_PESO   } )
//			aAdd( aTail(aCQry), { "Z07_ITEMPC" , Z07->Z07_ITEMPC } )
//			aAdd( aTail(aCQry), { "Z07_PRODUT" , Z07->Z07_PRODUT } )
//			aAdd( aTail(aCQry), { "Z07_DESCB1" , Posicione('SB1', 1, xFilial('SB1')+Z07->Z07_PRODUT, 'B1_DESC') } )
//			aAdd( aTail(aCQry), { "Z07_LOTE"   , Z07->Z07_LOTE   } )
//			aAdd( aTail(aCQry), { "Z07_CURRAL" , Z07->Z07_CURRAL } )
//			aAdd( aTail(aCQry), { "Z07_IDADE"  , Z07->Z07_IDADE  } )
//			aAdd( aTail(aCQry), { "Z07_DTNASC" , Z07->Z07_DTNASC } )
//			aAdd( aTail(aCQry), { "Z07_PEDIDO" , Z07->Z07_PEDIDO } )
//			aAdd( aTail(aCQry), { "Z07_REC_WT" , Z07->(Recno())  } )			
//			Z07->(DbSkip())
//		EndDo
//		RecargGrid(oZ07, aHZ07, aCZ07, aCQry, .F. )
//		
//		oZ07:Enable()
//		oZ07:Refresh()
//		
//	Else	
//		oZ07:aCols[ 1, aScan( oZ07:aHeader, { |x| AllTrim(x[2]) == 'Z07_SEQUEN' } ) ] := M->Z05_SEQUEN
//		oZ07:aCols[ 1, aScan( oZ07:aHeader, { |x| AllTrim(x[2]) == 'Z07_ITEM'   } ) ] := StrZero(1, TamSX3('Z07_ITEM')[1])
//	EndIf
//	
//Return nil
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  31.12.2016                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//Static Function fX7VldRFID(_cX7CodPC, cRFID, cSequencia, cItem )
//Local lRet  	   := .T.
//Local aArea 	   := GetArea()
//Local _cQry 	   := ""
//Local _TMP         := GetNextAlias()
//
//	_cQry := " select Z07_SEQUEN, Z07_ITEM, R_E_C_N_O_ recno " + CRLF
//	_cQry += " from "+ RetSqlName('Z07') + CRLF
//	_cQry += " where " + CRLF
//	_cQry += " 		Z07_FILIAL='"+xFilial('Z07')+"' " + CRLF
//	_cQry += " 	and Z07_PEDIDO='"+_cX7CodPC+"' " + CRLF
//	_cQry += " 	and Z07_RFID='"+cRFID+"' " + CRLF
//	_cQry += " 	and D_E_L_E_T_=' ' "
//	
//	DbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_TMP),.F.,.F.)
//	
// 	if !(_TMP)->(Eof())	
//		If (_TMP)->Z07_SEQUEN+(_TMP)->Z07_ITEM <> cSequencia+cItem
//			lRet := .F.
//			ShowHelpDlg("VAEST007-01", 	{'O RF_ID: ' + AllTrim(cRFID) + ' ja se encontra cadastrado para o Pedido: ' + AllTrim(_cX7CodPC) + ' no apontamento: ' + AllTrim((_TMP)->Z07_SEQUEN) }, ,;
//										{"Por verifique o item informado !!!"}, )			
//		EndIf
//	EndIf	
//	(_TMP)->(DbCloseArea())
//	RestArea(aArea)
//Return lRet
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  29.12.2016                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//Static Function GrvGrids(lZ05)
//Local lIncluir 	:= .T.
//Local nI		:= 0, nJ := 0
//Default lZ05 	:= .F.
//
//if lZ05
//	fGrvCpo('Z05_QTDEPC' , M->Z05_QTDEPC)
//	fGrvCpo('Z05_QTAPON' , M->Z05_QTAPON)
//	fGrvCpo('Z05_FALTA'  , M->Z05_FALTA)
//	fGrvCpo('Z05_PESOTT' , M->Z05_PESOTT)
//	fGrvCpo('Z05_QTDROM' , M->Z05_QTDROM)
//	fGrvCpo('Z05_FALROM' , M->Z05_FALROM)
//EndIf
//	
//// Gravar Z06
//For nI := 1 to Len(oZ06:aCols) // linhas
//	If !Empty(oZ06:ACOLS[nI,1]) .and. !Empty(oZ06:ACOLS[nI,2] ) .and. ;
//		oZ06:aCols[ nI, aScan( oZ06:aHeader, { |x| AllTrim(x[2]) == 'Z06_REC_WT' } ) ] == 0
//		
//		lIncluir := .T.
//		Z06->(DbSetOrder(1))
//		If Z06->(DbSeek(xFilial('Z06') + oZ06:ACOLS[nI,1] + oZ06:ACOLS[nI,2] ))
//			lIncluir := .F.
//		EndIf
//		RecLock('Z06', lIncluir)
//			For nJ := 1 to Len(oZ06:aHeader)-2 // colunas
//				Z06->&(oZ06:AHEADER[nJ,2]) := oZ06:ACOLS[nI,nJ]
//			Next nJ                                                     
//			Z06->Z06_FILIAL := xFilial('Z06')
//		Z06->(MsUnLock())
//		If oZ06:aCols[ nI, aScan( oZ06:aHeader, { |x| AllTrim(x[2]) == 'Z06_REC_WT' } ) ] == 0
//			oZ06:aCols[ nI, aScan( oZ06:aHeader, { |x| AllTrim(x[2]) == 'Z06_REC_WT' } ) ] := Z06->(Recno())
//		EndIf
//	EndIf
//Next nI
//
///* ------------------------------------------------------------------ */
//For nI := 1 to Len(oZ07:aCols) // linhas  
//	If !oZ07:aCols[nI, Len(oZ07:aCols[nI]) ]
//		If  !Empty(oZ07:ACOLS[nI, aScan( oZ07:aHeader, { |x| AllTrim(x[2]) == 'Z07_SEQUEN' } ) ] ) .and. ;
//			!Empty(oZ07:ACOLS[nI, aScan( oZ07:aHeader, { |x| AllTrim(x[2]) == 'Z07_ITEM'   } ) ] ) .and. ;
//			!Empty(oZ07:ACOLS[nI, aScan( oZ07:aHeader, { |x| AllTrim(x[2]) == 'Z07_PRODUT' } ) ] ) .and. ;
//			oZ07:aCols[ nI, aScan( oZ07:aHeader, { |x| AllTrim(x[2]) == 'Z07_REC_WT' } ) ] == 0
//			
//			if M->Z05_CONTRF=='S' .and. Empty(oZ07:ACOLS[nI,3])
//				Loop
//			EndIf
//			lIncluir := .T.
//			Z07->(DbSetOrder(1))
//			If Z07->(DbSeek(xFilial('Z07') + oZ07:ACOLS[nI, aScan( oZ07:aHeader, { |x| AllTrim(x[2]) == 'Z07_SEQUEN' } ) ] + oZ07:ACOLS[nI, aScan( oZ07:aHeader, { |x| AllTrim(x[2]) == 'Z07_ITEM'   } ) ] ))
//				lIncluir := .F.
//			EndIf
//			RecLock('Z07', lIncluir)
//				For nJ := 1 to Len(oZ07:aHeader)-2 // colunas
//					Z07->&(oZ07:AHEADER[nJ,2]) := oZ07:ACOLS[nI,nJ]
//				Next nJ                                                     
//				Z07->Z07_FILIAL := xFilial('Z07')
//			Z07->(MsUnLock())
//			
//			If oZ07:aCols[ nI, aScan( oZ07:aHeader, { |x| AllTrim(x[2]) == 'Z07_REC_WT' } ) ] == 0
//				oZ07:aCols[ nI, aScan( oZ07:aHeader, { |x| AllTrim(x[2]) == 'Z07_REC_WT' } ) ] := Z07->(Recno())
//			EndIf
//		EndIf
//	Else
//		If Z07->(DbSeek(xFilial('Z07') + oZ07:ACOLS[nI,1] + oZ07:ACOLS[nI,2] ))
//			RecLock("Z07")
//				Z07->(DbDelete())
//			Z07->(MsUnLock())
//		EndIf
//	EndIf	
//Next nI
//
//Return nil
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  29.12.2016                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//User Function VdCpoZ05()
//Local cCampo	:= SubS(ReadVar(), AT(">", ReadVar())+1 )
//Local lRet  	:= .T.
//Local aCQry		:= {}
//Local xInfo 
//
//If cCampo == 'Z05_PEDIDO' 
//	If !Empty(&(ReadVar())) .and. (lRet:=Obrigatorio(aGets, aTela))
//	
//		SC7->(DbSetOrder(1))
//		If SC7->(DbSeek(xFilial('SC7') + M->Z05_PEDIDO + StrZero( 1, TamSX3('C7_ITEM')[1] ) ))
//			While !SC7->(Eof()) .and. SC7->C7_NUM == M->Z05_PEDIDO
//				lRet := .F.                                                         
//				
//				if Empty(SC7->C7_RESIDUO) .and. SC7->C7_QUJE==0 .And. SC7->C7_QTDACLA==0 // Verde: 
//					lRet := .T.
//				elseIf Empty(SC7->C7_RESIDUO) .and. SC7->C7_QUJE <> 0 .And. SC7->C7_QUJE < SC7->C7_QUANT // Amarelo: 
//					lRet := .T.
//				elseIf Empty(SC7->C7_RESIDUO) .and. SC7->C7_QTDACLA > 0 // Laranja: 
//					lRet := .T.
//				endIf 
//				
//				If lRet
//					If Empty(Posicione('SB1', 1, xFilial('SB1')+SC7->C7_PRODUTO, 'B1_XGRPIND' ) )
//						ShowHelpDlg("VAEST007-02", 	{'O Campo [Grp Individu] no cadastro de produto nao se encontra preenchido.' }, ,;
//													{"Por Favor preencher o campo [Grp Individu] para continuar !!!"}, )
//						lRet := .F.
//						exit
//					EndIf
//					
//					If lRet					
//						If ( AtuSaldo( &(ReadVar()), SC7->C7_ITEM, SC7->C7_PRODUTO, M->Z05_SEQUEN, .F., @M->Z06_QUANT, @M->Z06_CONFER, @M->Z06_FALTA, @M->Z06_SDPEDA, @M->Z06_QTDROM, @M->Z06_CONFAT, @M->Z06_FALROM, @M->Z06_PESO, @M->Z05_QTDEPC, @M->Z05_QTAPON, @M->Z05_FALTA, @M->Z05_PESOTT, @M->Z05_QTDROM, @M->Z05_FALROM ) )
//							aAdd( aCQry, {} )
//							aAdd( aTail(aCQry), { "Z06_SEQUEN" , M->Z05_SEQUEN 		} )
//							aAdd( aTail(aCQry), { "Z06_ITEMPC" , SC7->C7_ITEM  		} )
//							aAdd( aTail(aCQry), { "Z06_PRODUT" , SC7->C7_PRODUTO	} )
//							aAdd( aTail(aCQry), { "Z06_DESCB1" , Posicione('SB1', 1, xFilial('SB1')+SC7->C7_PRODUTO, 'B1_DESC') } )
//							aAdd( aTail(aCQry), { "Z06_LOTE"   , M->Z05_LOTE        } )
//							aAdd( aTail(aCQry), { "Z06_PEDIDO" , M->Z05_PEDIDO		} )
//							aAdd( aTail(aCQry), { "Z06_QUANT"  , M->Z06_QUANT		} )
//							aAdd( aTail(aCQry), { "Z06_CONFER" , M->Z06_CONFER		} )
//							aAdd( aTail(aCQry), { "Z06_FALTA"  , M->Z06_FALTA		} )
//							aAdd( aTail(aCQry), { "Z06_SDPEDA" , M->Z06_SDPEDA		} )
//							aAdd( aTail(aCQry), { "Z06_QTDROM" , M->Z06_QTDROM		} )
//							aAdd( aTail(aCQry), { "Z06_CONFAT" , M->Z06_CONFAT		} )
//							aAdd( aTail(aCQry), { "Z06_FALROM" , M->Z06_FALROM		} )
//							aAdd( aTail(aCQry), { "Z06_PESO"   , M->Z06_PESO		} )
//						EndIf	
//					EndIf
//				Else
//					ShowHelpDlg("VAEST007-03", 	{'O produto: '+  AllTrim(SC7->C7_PRODUTO) + ' no Pedido: ' + AllTrim(M->Z05_PEDIDO) + ' não possue SALDO disponivel para lançamento do manejo.'}, ,;
//												{"Por favor confirme o Pedido selecionado !!!"}, )
//				EndIf
//				
//				SC7->(DbSkip())
//			EndDo
//			
//			If Len(aCQry) > 0
//			
//				oZ06:Enable()
//				oZ06:Refresh()
//			
//				RecargGrid(oZ06, aHZ06, aCZ06, aCQry )
//				
//				xInfo := M->Z05_PEDIDO // Informacao a ser gravada pela funcao: fGrvCpo
//				
//				aCQry := {}
//				aAdd( aCQry, {} )
//				aAdd( aTail(aCQry), { "Z07_SEQUEN" , M->Z05_SEQUEN 						 } )
//				aAdd( aTail(aCQry), { "Z07_ITEM"   , StrZero( 1 , TamSX3('C7_ITEM')[1] ) } )
//				aAdd( aTail(aCQry), { "Z07_RFID"   , Space(TamSX3('Z07_RFID')[1])		 } )
//				aAdd( aTail(aCQry), { "Z07_PESO"   , 0									 } )
//				aAdd( aTail(aCQry), { "Z07_ITEMPC" , Space(TamSX3('Z07_ITEMPC')[1])		 } )
//				aAdd( aTail(aCQry), { "Z07_PRODUT" , Space(TamSX3('Z07_PRODUT')[1])		 } )
//				aAdd( aTail(aCQry), { "Z07_DESCB1" , Space(TamSX3('Z07_DESCB1')[1])		 } )
//				aAdd( aTail(aCQry), { "Z07_LOTE"   , M->Z05_LOTE						 } )
//				aAdd( aTail(aCQry), { "Z07_CURRAL" , M->Z05_CURRAL						 } )
//				aAdd( aTail(aCQry), { "Z07_IDADE"  , 0									 } )
//				aAdd( aTail(aCQry), { "Z07_DTNASC" , stoD('')							 } )
//				aAdd( aTail(aCQry), { "Z07_PEDIDO" , M->Z05_PEDIDO						 } )
//				
//				RecargGrid(oZ07, aHZ07, aCZ07, aCQry )
//			
//			EndIf
//			
//			oEncZ05:ENCHREFRESHALL()
//			GrvGrids(.T.)
//		Else
//			ShowHelpDlg("VAEST007-04", {'O Pedido de compra [' + AllTrim(M->Z05_PEDIDO) + '] não foi localizado no sistema.'}, ,;
//									   {"Por favor digite ou selecione novamente para continuar !!!"}, )
//			lRet := .F.
//		EndIf
//	Else
//		&(ReadVar()) := CriaVar('Z05_PEDIDO', .F. )     
//	EndIf
//	
//ElseIf cCampo == 'Z05_LOTE'
//	xInfo := M->Z05_LOTE // Informacao a ser gravada pela funcao: fGrvCpo
//ElseIf cCampo == 'Z05_CURRAL'
//	xInfo := M->Z05_CURRAL // Informacao a ser gravada pela funcao: fGrvCpo
//ElseIf cCampo == 'Z05_CONTRF'
//	xInfo := M->Z05_CONTRF // Informacao a ser gravada pela funcao: fGrvCpo
//ElseIf cCampo == 'Z05_PESCHE'
//	xInfo := M->Z05_PESCHE // Informacao a ser gravada pela funcao: fGrvCpo
//EndIf
//If lRet .and. !Empty(xInfo)
//	fGrvCpo(cCampo, xInfo)
//EndIf
//
//Return lRet
//
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  17.01.2017                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//Static Function RecargGrid(oObj, aHeader, aModel, aCQry, lGrv, lTela, lInc, nLinha )
//Local nI         := 0
//Local nJ         := 0
//Local lVai		 := .T.
//
//Default lGrv     := .T.
//Default lTela    := .F.
//Default lInc	 := .T.
//Default nLinha 	 := Len(oObj:aCols)
//
//	For nI := 1 to Len(aCQry)    
//		If (nI > nLinha) .or. lTela
//			If lTela .and. SubS( aCQry[nI, 1, 1], 1, At("_",aCQry[nI, 1, 1])-1) == 'Z07'
//				If lInc        
//					nLinha 	 := Len(oObj:aCols)
//					lVai := !Empty( oObj:aCols[ nLinha, aScan( oObj:aHeader, { |x| AllTrim(x[2]) == 'Z07_ITEMPC' } ) ] ) 
//				Else
//					lVai := .F.
//				EndIf
//			EndIf
//			If lVai
//				aAdd( oObj:aCols, aClone(aModel[1]) )
//				nLinha 	 := Len(oObj:aCols)
//			EndIf
//		EndIf
//		For nJ := 1 to Len(aCQry[nI])
//			oObj:aCols[ nLinha, aScan( aHeader, { |x| AllTrim(x[2]) == aCQry[nI, nJ, 1] } ) ] := aCQry[nI,nJ,2]
//		Next nJ
//	Next nI
//	
//	oObj:Refresh()
//	
//	If lGrv
//		GrvGrids(.T.)
//	EndIf
//Return oObj
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  29.12.2016                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//Static Function fGrvCpo(cCampo, xInfo, cItem)
//Local lRet       := .F.
//Local cTab       := ""
//
//Default cItem:= '9999'
//
//	If !Empty(xInfo)
//		cTab   := SubS( cCampo, 1,  --At("_", cCampo) )
//	
//		if cTab == 'Z05'
//			Z05->(DbSetOrder(1))
//			If Z05->(DbSeek(xFilial('Z05')+M->Z05_SEQUEN)) 
//				lRet := .T.
//			EndIf
//
//		Elseif cTab == 'Z06'
//			If !Empty(cItem) .and. cItem <> '9999'
//				Z06->(DbSetOrder(1))
//				If Z06->(DbSeek(xFilial('Z06')+M->Z05_SEQUEN+cItem))
//					lRet := .T.
//				EndIf
//			EndIf
//		ElseIf cTab == 'Z07'
//			Z06->(DbSetOrder(1))
//			If !(lRet := Z06->(DbSeek(xFilial('Z06') + M->Z05_SEQUEN + StrZero(1, TamSX3('Z06_ITEMPC')[1]) )))
//				ShowHelpDlg("VAEST007-05", 	{'Não foi localizado Itens do Pedido para a Sequencia: ' + M->Z05_SEQUEN }, ,;
//								  			{"Por Favor verifique o Pedido de Compra Informado !!!"}, )
//            Else       
//            	If !Empty(cItem) .and. cItem <> '9999'
//	            	Z07->(DbSetOrder(1))
//					If !(Z07->(DbSeek(xFilial('Z07') + M->Z05_SEQUEN + cItem)))
//						RecLock('Z07', .T.)
//							Z07->Z07_FILIAL := xFilial('Z07')
//							Z07->Z07_SEQUEN := M->Z05_SEQUEN
//							Z07->Z07_ITEM 	:= cItem
//							Z07->Z07_LOTE   := M->Z05_LOTE
//							Z07->Z07_CURRAL := M->Z05_CURRAL
//							Z07->Z07_PEDIDO := M->Z05_PEDIDO
//						Z07->(MsUnLock())
//					EndIf                
//					lRet := .T.
//				EndIf
//			EndIf
//			
//		EndIf
//		
//		If lRet 
//			RecLock( cTab, .F.)
//				&((cTab)->(cCampo)) := xInfo
//			(cTab)->(MsUnLock())
//		EndIf
//	EndIf    
//Return lRet
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  02.01.2017                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//Static Function CadPessagem(oObj)
//Local nI		  := 0
//Local lOk 		  := .T.
//Local nLinhaZ06   := 0
//Local nQtApont    :=0    
//Local nQtPedCom   :=0
//
//Default oObj 	:= nil
//
//	Z06->(DbSetOrder(1))
//	If !(Z06->(DbSeek(xFilial('Z06') + M->Z05_SEQUEN + StrZero(1, TamSX3('Z06_ITEMPC')[1]) )))
//		ShowHelpDlg("VAEST007-06", 	{'Não foi localizado Itens do Pedido para a Sequencia: ' + M->Z05_SEQUEN }, ,;
//									{"Por Favor verifique o Pedido de Compra Informado !!!"}, )
//	Else
//		If Obrigatorio(aGets, aTela)
//			
//			If fExitQtEntrega()
//				If oZ07:lActive .or. oObj==nil
//				
//					if oObj <> nil
//						nLinhaZ07  := oObj:nAt      
//						cItemZ07   := StrZero( nLinhaZ07 , TamSX3('Z07_ITEM')[1] )
//						cZ07RFID   := oObj:aCols[ nLinhaZ07, aScan( oObj:aHeader, { |x| AllTrim(x[2]) == 'Z07_RFID'   } ) ]
//						nZ07Peso   := oObj:aCols[ nLinhaZ07, aScan( oObj:aHeader, { |x| AllTrim(x[2]) == 'Z07_PESO'   } ) ]
//						cZ07ItemPC := oObj:aCols[ nLinhaZ07, aScan( oObj:aHeader, { |x| AllTrim(x[2]) == 'Z07_ITEMPC' } ) ]
//						cZ07Produt := oObj:aCols[ nLinhaZ07, aScan( oObj:aHeader, { |x| AllTrim(x[2]) == 'Z07_PRODUT' } ) ]
//						cZ07DescB1 := oObj:aCols[ nLinhaZ07, aScan( oObj:aHeader, { |x| AllTrim(x[2]) == 'Z07_DESCB1' } ) ]
//						nZ07Idade  := oObj:aCols[ nLinhaZ07, aScan( oObj:aHeader, { |x| AllTrim(x[2]) == 'Z07_IDADE'  } ) ]
//						dZ07DtNas  := oObj:aCols[ nLinhaZ07, aScan( oObj:aHeader, { |x| AllTrim(x[2]) == 'Z07_DTNASC' } ) ]
//						
//						FrmPessagem(.F.)
//						nI := 1
//					Else
//						nI := 0
//						While (FrmPessagem(.T.))
//							nI++       		
//						EndDo
//						ApMsgInfo('Foram incluidas: ' + StrZero(nI, 3) + ' linhas.')
//					EndIf
//					
//					If nI > 0
//						GrvGrids(.T.)
//						
//						If !oZ07:lActive
//							oZ07:Enable()
//							oZ07:Refresh()
//						EndIf
//					EndIf
//				Else
//					ShowHelpDlg("VAEST007-07", 	{'Não existe apontamento de Pesagem para Alteracao.'}, ,;
//										{"Para incluir, por favor ir ate Ações Relacionadas > Pessagem ou pelo Atalho ALT+P !!!"}, )
//				EndIf
//			EndIf
//		EndIf
//	EndIf
//Return nil 
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  31.12.2016                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//Static Function FrmPessagem(lInc)
//Local aArea			:= GetArea()
//Local lRet 			:= .T.
//Local oDlgP
//Local aSize 		:= {}
//Local aObjects 		:= {}
//Local aInfo			:= {}
//Local aPObjs 		:= {}
//Local nOpca			:= 0
//Local aCQry 		:= {}
//Local oEncZ07		:= nil
//Local nLinha		:= 0
//Local nZ6CONFER     := 0 
//Local nZ6FALTA      := 0 
//Local nZ6SDPEDA     := 0 
//Local nZ6QTDROM     := 0 
//Local nZ6CONFAT     := 0 
//Local nZ6FALROM     := 0 
//Local nZ6PESO       := 0 
//
//Private lVarMagica  := .T.
//Private oEncZ07		:= nil
//Private aGets       := {}
//Private aTela       := {}
//Private cCadPes 	:= "Cadastro de Pesagem" + " - " + Iif( lInc , "(Inclusão)", "(Alteração)" )
//
//cSequencia          := M->Z05_SEQUEN
//cLote	            := M->Z05_LOTE
//cCurral	            := M->Z05_CURRAL
//cContRF	            := M->Z05_CONTRF
//
//If (lVarMagica := lInc)
//	cItemZ07 		:= U_FCHAVESX8('Z07','Z07_ITEM','Z07_SEQUEN', cSequencia, "and Z07_PRODUT<>' '")
//EndIf
//
//aSize := MsAdvSize( .T. )         
//aSize[6]*=0.5  // altura
//aSize[5]*=0.6  // largura
//AAdd( aObjects, { 100, 100, .T., .T. } )
//aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], aSize[5], aSize[6]}
//aPObjs := MsObjSize(aInfo, aObjects, .T., .F.)
//
//DEFINE MSDIALOG oDlgP TITLE OemToAnsi(cCadPes) From 0,0 to aSize[6],aSize[5] of oMainWnd PIXEL 
//
//oEncZ07 := MsMGet():New(,,3,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,aPObjs[1], /*aAlterEnch*/,/*nModelo*/,;
//				/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oDlgP /* oPanelF1 */,/*lF3*/,/*lMemoria*/, .T. /*lColumn*/,;
//				/*caTela*/,/*lNoFolder*/, /*lProperty*/,aFieldPES,/* aFolder */,/*lCreate*/, /*lNoMDIStretch*/,/*cTela*/)
//oEncZ07:oBox:Align := CONTROL_ALIGN_ALLCLIENT
//
//ACTIVATE MSDIALOG oDlgP ;
//          ON INIT EnchoiceBar(oDlgP,;
//                              { || nOpcA := 2, Iif( U_fZ07TudoOK(lInc, lVarMagica) .and. Obrigatorio(aGets, aTela), oDlgP:End(), nOpcA := 0)},;
//                              { || nOpcA := 1, oDlgP:End() },, /* aButtons */ )
//If nOpcA == 2
//	aCQry := {}
//	aAdd( aCQry, {} )
//	aAdd( aTail(aCQry), { "Z07_SEQUEN" , cSequencia    } )
//	aAdd( aTail(aCQry), { "Z07_ITEM"   , cItemZ07      } )
//	aAdd( aTail(aCQry), { "Z07_RFID"   , cZ07RFID      } )
//	aAdd( aTail(aCQry), { "Z07_PESO"   , nZ07Peso      } )
//	aAdd( aTail(aCQry), { "Z07_ITEMPC" , cZ07ItemPC    } )
//	aAdd( aTail(aCQry), { "Z07_PRODUT" , cZ07ProdutT   } )
//	aAdd( aTail(aCQry), { "Z07_DESCB1" , cZ07DescB1    } )
//	aAdd( aTail(aCQry), { "Z07_LOTE"   , cLote         } )
//	aAdd( aTail(aCQry), { "Z07_CURRAL" , cCurral       } )
//	aAdd( aTail(aCQry), { "Z07_IDADE"  , nZ07Idade     } )
//	aAdd( aTail(aCQry), { "Z07_DTNASC" , dZ07DtNas     } )
//	aAdd( aTail(aCQry), { "Z07_PEDIDO" , M->Z05_PEDIDO } )
//	aAdd( aTail(aCQry), { "Z07_REC_WT" , 0			   } )	
//	
//	RecargGrid(oZ07, aHZ07, aCZ07, aCQry, .T. , .T. , lInc, Val(cItemZ07) )
//	cZ07RFID    := CriaVar('Z07_RFID'  , .F.)	
//	
//	// neste ponto nao esta sendo feito validacao, se pode ou nao inserir. isso ja foi descido na funcao fZ07TudoOK;
//	// agora é só para pegar os campos que ja foram gravados, e atualizar os campos de CONTADORES;
//	AtuSaldo( M->Z05_PEDIDO, AllTrim(cZ07ItemPC), AllTrim(cZ07Produt), M->Z05_SEQUEN, .F., @M->Z06_QUANT, @nZ6CONFER, @nZ6FALTA, @nZ6SDPEDA, @nZ6QTDROM, @nZ6CONFAT, @nZ6FALROM, @nZ6PESO, @M->Z05_QTDEPC, @M->Z05_QTAPON, @M->Z05_FALTA, @M->Z05_PESOTT, @M->Z05_QTDROM, @M->Z05_FALROM/* , IIf( lInc, .T., lInc<>lVarMagica  */)
//
//	// Atualizando grid do Pedido = Z06
//	If ( nPosAux := aScan( oZ06:aCols , { |x| AllTrim(x[2])+AllTrim(x[3]) == AllTrim(cZ07ItemPC)+AllTrim(cZ07Produt) } )  ) > 0
//		oZ06:aCols[ nPosAux , aScan( oZ06:aHeader, { |x| AllTrim(x[2]) == 'Z06_CONFER' } )  ] := nZ6CONFER
//		oZ06:aCols[ nPosAux , aScan( oZ06:aHeader, { |x| AllTrim(x[2]) == 'Z06_FALTA'  } )  ] := nZ6FALTA
//		oZ06:aCols[ nPosAux , aScan( oZ06:aHeader, { |x| AllTrim(x[2]) == 'Z06_SDPEDA'  } ) ] := nZ6SDPEDA 
//		oZ06:aCols[ nPosAux , aScan( oZ06:aHeader, { |x| AllTrim(x[2]) == 'Z06_QTDROM'  } ) ] := nZ6QTDROM 
//		oZ06:aCols[ nPosAux , aScan( oZ06:aHeader, { |x| AllTrim(x[2]) == 'Z06_CONFAT'  } ) ] := nZ6CONFAT
//		oZ06:aCols[ nPosAux , aScan( oZ06:aHeader, { |x| AllTrim(x[2]) == 'Z06_FALROM'  } ) ] := nZ6FALROM
//		oZ06:aCols[ nPosAux , aScan( oZ06:aHeader, { |x| AllTrim(x[2]) == 'Z06_PESO'    } ) ] := nZ6PESO
//		oZ06:aCols[ nPosAux , aScan( oZ06:aHeader, { |x| AllTrim(x[2]) == 'Z06_REC_WT'  } ) ] := 0
//		oZ06:Refresh()
//		oEncZ05:ENCHREFRESHALL()		
//	EndIf
//	GrvGrids(.T.)
//Else
// 	lRet := .F.
//EndIf
//RestArea(aArea)
//Return lRet
//
//
///*/{Protheus.doc}fEncRes
//    Altera o status do Manejo posicionado para permitr a entrada da nota fiscal.
///*/
//user function fEncRes()
//if Z05->Z05_STATUS $ "01"
//    RecLock("Z05", .f.)
//        Z05->Z05_STATUS := "2"
//    MsUnlock()
//else
//    ShowHelpDlg("FENCRES01", {"Não é possivel encerrar um manejo encerrado ou em nota fiscal."}, 1, {"Somente encerre manejos abertos ou incompletos."}, 1)
//endif
//return nil
//
///*/{Protheus.doc}fReaRes
//    Altera o status do Manejo posicionado permitir alteração.
///*/
//user function fReaRes()
//if Z05->Z05_STATUS == "2"
//    RecLock("Z05", .f.)
//        Z05->Z05_STATUS := "1"
//    MsUnlock()
//else
//    ShowHelpDlg("FREARES01", {"Não é possivel reabrir um manejo que não possua status fechado."}, 1, {"Por favor verifique."}, 1)
//endif
//return nil
//
//static function AtuRomane()
//local i, nLen
//
//nQtdRom := 0
//
//nLen := Len(oZ06:aCols)
//for i := 1 to nLen
//    nQtdRom += oZ06:aCols[i][nPosQtdRom]
//next
//
//nFltRom := greater(nQtdRom - M->Z05_QTAPON, 0)
//
//oEncZ05:EnchRefreshAll()
//
//return nil
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  17.01.2017                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//User Function VdCpoZ06()
//Local lRet  	:= .T.
//Local cCampo	:= SubS(ReadVar(), AT(">", ReadVar())+1 )
//Local xInfo 	:= &(ReadVar()) 
//
//If (xInfo-GdFieldGet('Z06_CONFAT')) < 0
//    lRet := .F.
//    ShowHelpDlg("VAEST007-08", 	{'O Valor informado: '+  AllTrim(&(ReadVar())) + ' nao é permitido.' }, ,;
//													{"Por verifique o valor informado !!!"}, )	
//Else
//	If cCampo == 'Z06_QTDROM' .and.  xInfo > 0 // .and. GdFieldGet('Z06_CONFAT') > 0
//		GdFieldPut('Z06_FALROM', xInfo-GdFieldGet('Z06_CONFAT'))
//		fGrvCpo('Z06_FALROM', xInfo-GdFieldGet('Z06_CONFAT'), GdFieldGet('Z06_ITEMPC'))
//	EndIf	
//	If lRet .and. !Empty(xInfo)         
//		fGrvCpo(cCampo, xInfo, GdFieldGet('Z06_ITEMPC'))
//		GdFieldPut('Z06_REC_WT',Z06->(Recno()))
//	EndIf
//EndIf
//	
//Return lRet
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  21.01.2017                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//User Function fPodeEditar()
//Return Empty(Posicione('Z07',1,xFilial('Z07')+Z05->Z05_SEQUEN,"Z07_SEQUEN"))
//
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  18.01.2017 															  |
// | Desc:                                                                          |
// |																				  |
// | Obs.:  - 2 Versao do : fX7VldSaldo                                             |
// '--------------------------------------------------------------------------------*/
//Static Function AtuSaldo( cPedCom, cItem, cProduto, cSequencia, lMsg, nZ6QUANT, nZ6CONFER, nZ6FALTA, nZ6SDPEDA, nZ6QTDROM, nZ6CONFAT, nZ6FALROM, nZ6PESO, nZ5QTDEPC, nZ5QTAPON, nZ5FALTA, nZ5PESOTT, nZ5QTDROM, nZ5FALROM, lControl )
//
//Local lRet  	 := .T.
//Local aArea 	 := GetArea()
//Local _cQry 	 := ""
//Local _TMP       := GetNextAlias()
//
//Default lMsg 	 := .T.
//Default lControl := .T.
//
//_cQry := ""
//_cQry += " With  " + CRLF
//_cQry += " QtdProdutoPorPedido as (    " + CRLF
//_cQry += "  	SELECT C7_FILIAL, C7_PRODUTO, C7_NUM, C7_ITEM, C7_QUANT Z06_QUANT    " + CRLF
//_cQry += "  	FROM " + RetSqlName('SC7') + " " + CRLF
//_cQry += " 	WHERE C7_FILIAL='"+xFilial('SC7')+"' " + CRLF
//_cQry += " 	AND C7_NUM='"+cPedCom+"' " + CRLF
//_cQry += " 	AND C7_PRODUTO='"+cProduto+"' " + CRLF
//_cQry += " ), " + CRLF
//_cQry += "  " + CRLF
//_cQry += " ConfAntPorProduto as (   " + CRLF
//_cQry += " 	SELECT Z07_FILIAL, Z07_PRODUT, Z07_PEDIDO, Z07_ITEMPC, COUNT(Z07_SEQUEN) Z06_CONFER   " + CRLF
//_cQry += "  	FROM " + RetSqlName('Z07') + "   " + CRLF
//_cQry += "  	WHERE Z07_FILIAL='"+xFilial('Z07')+"'      " + CRLF
//_cQry += "  		AND Z07_PEDIDO='"+cPedCom+"'  " + CRLF
//_cQry += " 		AND Z07_PRODUT ='"+cProduto+"' " + CRLF
//_cQry += "  		AND D_E_L_E_T_=' '  " + CRLF
//_cQry += " 	GROUP BY Z07_FILIAL, Z07_PRODUT, Z07_PEDIDO, Z07_ITEMPC   " + CRLF
//_cQry += " ), " + CRLF
//_cQry += "  " + CRLF
//_cQry += " RecpAtualPorProdXSeq as ( " + CRLF
//_cQry += " 	select Z06_PEDIDO, Z06_ITEMPC, Z06_PRODUT, Z06_QTDROM " + CRLF
//_cQry += " 	FROM " + RetSqlName('Z06') + " " + CRLF
//_cQry += " 	where Z06_FILIAL='"+xFilial('Z06')+"'  " + CRLF
//_cQry += " 	and Z06_PEDIDO='"+cPedCom+"'  " + CRLF
//_cQry += " 	AND Z06_ITEMPC='"+cItem+"'  " + CRLF
//_cQry += " 	AND Z06_PRODUT='"+cProduto+"'   " + CRLF
//_cQry += " 	and Z06_SEQUEN = '"+cSequencia+"' and D_E_L_E_T_=' '  " + CRLF
//_cQry += "  " + CRLF
//_cQry += " ), " + CRLF
//_cQry += "  " + CRLF
//_cQry += " ApontadosPorProdXSeq as (   " + CRLF
//_cQry += "  	select Z07_PRODUT, Z07_PEDIDO, Z07_ITEMPC, count(*) Z06_CONFAT, SUM(Z07_PESO) Z06_PESO   " + CRLF
//_cQry += "  	FROM " + RetSqlName('Z07') + " " + CRLF
//_cQry += "  	where Z07_FILIAL='"+xFilial('Z07')+"'    " + CRLF
//_cQry += "  		and Z07_PEDIDO='"+cPedCom+"'   " + CRLF
//_cQry += "  		AND Z07_ITEMPC='"+cItem+"'  " + CRLF
//_cQry += "  		AND Z07_PRODUT='"+cProduto+"      '  " + CRLF
//_cQry += " 		and Z07_SEQUEN = '"+cSequencia+"' " + CRLF
//_cQry += "  		and D_E_L_E_T_=' '  " + CRLF
//_cQry += "  	group by Z07_FILIAL, Z07_PRODUT, Z07_PEDIDO, Z07_ITEMPC  " + CRLF
//_cQry += " ), " + CRLF
//_cQry += "  " + CRLF
//_cQry += " TotalProduto as (  " + CRLF
//_cQry += " 	select C7_NUM, Sum(C7_QUANT) Z05_QTDEPC  " + CRLF
//_cQry += "  	FROM " + RetSqlName('SC7') + " c  " + CRLF
//_cQry += " 	where  " + CRLF
//_cQry += " 		C7_FILIAL='"+xFilial('SC7')+"'  " + CRLF
//_cQry += " 		and C7_NUM='"+cPedCom+"'  " + CRLF
//_cQry += " 		and D_E_L_E_T_=' '   " + CRLF
//_cQry += " 	GROUP BY C7_NUM " + CRLF
//_cQry += " ), " + CRLF
//_cQry += "  " + CRLF
//_cQry += " TotalApontado as (  " + CRLF
//_cQry += " 	select Z07_PEDIDO, Count(Z07_SEQUEN) Z05_QTAPON, sum(Z07_PESO) Z05_PESOTT " + CRLF
//_cQry += "  	FROM " + RetSqlName('Z07') + " " + CRLF
//_cQry += "  	where Z07_FILIAL='"+xFilial('Z07')+"'     " + CRLF
//_cQry += "  		and Z07_PEDIDO='"+cPedCom+"' and Z07_PRODUT <> ' '  " + CRLF
//_cQry += "  		and D_E_L_E_T_=' '   " + CRLF
//_cQry += " 	GROUP BY Z07_PEDIDO " + CRLF
//_cQry += " ), " + CRLF
//_cQry += "  " + CRLF
//_cQry += " RecebidoGeral as ( " + CRLF
//_cQry += " 	select Z06_PEDIDO, SUM(Z06_QTDROM) Z05_QTDROM " + CRLF
//_cQry += " 	from " + RetSqlName('Z06') + " " + CRLF
//_cQry += " 	where Z06_FILIAL='"+xFilial('Z06')+"'  " + CRLF
//_cQry += " 	and Z06_PEDIDO='"+cPedCom+"'  " + CRLF
//_cQry += " 	and D_E_L_E_T_=' '  " + CRLF
//_cQry += " 	group by Z06_PEDIDO " + CRLF
//_cQry += " ) " + CRLF
//_cQry += "  " + CRLF
//_cQry += " SELECT C7_FILIAL, C7_PRODUTO, Q.C7_NUM, C7_ITEM,  " + CRLF
//_cQry += " Z06_QUANT,  " + CRLF
//_cQry += " ISNULL(Z06_CONFER,0)-ISNULL(Z06_CONFAT,0) Z06_CONFER,  " + CRLF
//_cQry += " Z06_QUANT-ISNULL(Z06_CONFER,0)+ISNULL(Z06_CONFAT,0) Z06_FALTA,  " + CRLF
//_cQry += " Z06_QUANT-ISNULL(Z06_CONFER,0) Z06_SDPEDA,  " + CRLF
//_cQry += " ISNULL(Z06_QTDROM,0) Z06_QTDROM, ISNULL(Z06_CONFAT,0) Z06_CONFAT, ISNULL(Z06_QTDROM,0)-ISNULL(Z06_CONFAT,0) Z06_FALROM, ISNULL(Z06_PESO,0) Z06_PESO, " + CRLF
//_cQry += " Z05_QTDEPC, ISNULL(Z05_QTAPON,0) Z05_QTAPON, " + CRLF
//_cQry += " Z05_QTDEPC-ISNULL(Z05_QTAPON,0) Z05_FALTA, ISNULL(Z05_PESOTT,0) Z05_PESOTT, ISNULL(Z05_QTDROM,0) Z05_QTDROM,  ISNULL(Z05_QTDROM,0)-ISNULL(Z05_QTAPON,0) Z05_FALROM " + CRLF
//_cQry += " FROM QtdProdutoPorPedido Q " + CRLF
//_cQry += " LEFT JOIN ConfAntPorProduto CP ON CP.Z07_ITEMPC=C7_ITEM AND CP.Z07_PRODUT=C7_PRODUTO and CP.Z07_PEDIDO=Q.C7_NUM " + CRLF
//_cQry += " LEFT JOIN RecpAtualPorProdXSeq ON C7_PRODUTO=Z06_PRODUT and C7_ITEM=Z06_ITEMPC and C7_NUM=Z06_PEDIDO " + CRLF
//_cQry += " LEFT JOIN ApontadosPorProdXSeq ON C7_PRODUTO=Z06_PRODUT and C7_ITEM=Z06_ITEMPC and C7_NUM=Z06_PEDIDO " + CRLF
//_cQry += " LEFT JOIN TotalProduto T ON T.C7_NUM=Q.C7_NUM " + CRLF
//_cQry += " LEFT JOIN TotalApontado TA ON TA.Z07_PEDIDO=Q.C7_NUM " + CRLF
//_cQry += " LEFT JOIN RecebidoGeral RG on Q.C7_NUM=RG.Z06_PEDIDO "
//
//DbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_TMP),.F.,.F.)
//	
//if !(_TMP)->(Eof())
//	nZ6QUANT	:= (_TMP)->Z06_QUANT   // 01
//	nZ6CONFER	:= (_TMP)->Z06_CONFER  // 02
//	nZ6FALTA	:= (_TMP)->Z06_FALTA   // 03
//	nZ6SDPEDA	:= (_TMP)->Z06_SDPEDA  // 04 
//	nZ6QTDROM	:= (_TMP)->Z06_QTDROM  // 05 
//	nZ6CONFAT	:= (_TMP)->Z06_CONFAT  // 06 
//	nZ6FALROM	:= (_TMP)->Z06_FALROM  // 07 
//	nZ6PESO		:= (_TMP)->Z06_PESO    // 08 
//	nZ5QTDEPC	:= (_TMP)->Z05_QTDEPC  // 09 
//	nZ5QTAPON	:= (_TMP)->Z05_QTAPON  // 10 
//	nZ5FALTA	:= (_TMP)->Z05_FALTA   // 11
//	nZ5PESOTT	:= (_TMP)->Z05_PESOTT  // 12 
//	nZ5QTDROM	:= (_TMP)->Z05_QTDROM  // 13
//	nZ5FALROM	:= (_TMP)->Z05_FALROM  // 14
//	
//	If lControl // AtuSaldo:  lInc<>lVarMagica
//		If  nZ6QTDROM > 0 .and. nZ6CONFAT >= nZ6QTDROM 
//			lRet := .F.
//			if lMsg        
//				Help( ,, 'Help',, 'O Produto: ' + AllTrim((_TMP)->C7_PRODUTO) + "-" + AllTrim(Posicione('SB1',1,xFilial('SB1')+AllTrim((_TMP)->C7_PRODUTO),'B1_DESC')) + ' no pedido: ' + AllTrim(cPedCom) + ' ja foram todos apontados de acordo com a Qt. de recebimento informada.', 1, 0 ) 
//			EndIf
//		ElseIf nZ6CONFER >= nZ6QUANT
//			lRet := .F.
//			if lMsg        
//				Help( ,, 'Help',, 'O Produto: ' + AllTrim((_TMP)->C7_PRODUTO) + "-" + AllTrim(Posicione('SB1',1,xFilial('SB1')+AllTrim((_TMP)->C7_PRODUTO),'B1_DESC')) + ' no pedido: ' + AllTrim(cPedCom) + ' ja foram todos apontados na rotina de Manejo.', 1, 0 ) 
//			EndIf
//		EndIf
//	Else
//		If  nZ6QTDROM > 0 .and. nZ6CONFAT > nZ6QTDROM 
//			lRet := .F.
//			if lMsg        
//				Help( ,, 'Help',, 'O Produto: ' + AllTrim((_TMP)->C7_PRODUTO) + "-" + AllTrim(Posicione('SB1',1,xFilial('SB1')+AllTrim((_TMP)->C7_PRODUTO),'B1_DESC')) + ' no pedido: ' + AllTrim(cPedCom) + ' ja foram todos apontados de acordo com a Qt. de recebimento informada.', 1, 0 ) 
//			EndIf
//		ElseIf nZ6CONFER > nZ6QUANT
//			lRet := .F.
//			if lMsg        
//				Help( ,, 'Help',, 'O Produto: ' + AllTrim((_TMP)->C7_PRODUTO) + "-" + AllTrim(Posicione('SB1',1,xFilial('SB1')+AllTrim((_TMP)->C7_PRODUTO),'B1_DESC')) + ' no pedido: ' + AllTrim(cPedCom) + ' ja foram todos apontados na rotina de Manejo.', 1, 0 ) 
//			EndIf
//		EndIf
//	EndIf
//	
//EndIf	
//(_TMP)->(DbCloseArea())
//RestArea(aArea)
//
//Return lRet
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  01.01.2017                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//User Function fZ07TudoOK(lInc, lVarMagica)
//Local lRet	  := .T.
//Local nPosAux := 0
//	If M->Z05_CONTRF == 'S' .and. Empty(cZ07RFID)
//		ShowHelpDlg("VAEST007-09", 	{'O Campo RF_ID é Obrigatorio quando controle RF ID for igual a SIM.' }, ,;
//									{"Por Favor preencher o campo RF ID para continuar !!!"}, )
//		lRet := .F.
//	EndIf
//	If lRet
//		// aqui vou fazer a conferencia para saber se esta tudo ok;
//		// cado nao estiver, o processo é interrompido;
//		// no confirmar da TELINHA, onde acontece a gravacao dos campos, vou chamar a funcao novamente, 
//		// mas nao para validar, e sim, somente, para atualizar os contadores;
//		lRet:= AtuSaldo( M->Z05_PEDIDO, AllTrim(cZ07ItemPC), AllTrim(cZ07Produt), M->Z05_SEQUEN, .T., @M->Z06_QUANT, @M->Z06_CONFER, @M->Z06_FALTA, @M->Z06_SDPEDA, @M->Z06_QTDROM, @M->Z06_CONFAT, @M->Z06_FALROM, @M->Z06_PESO, @M->Z05_QTDEPC, @M->Z05_QTAPON, @M->Z05_FALTA, @M->Z05_PESOTT, @M->Z05_QTDROM, @M->Z05_FALROM, IIf( lInc, .T., lInc<>lVarMagica ) )
//	EndIf
//Return lRet
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  01.01.2017                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//User Function VdCpoZ07(cCampo)
//
//Local xInfo 	:= &(ReadVar()) 
//Local lRet  	:= .T.
//
//	Z06->(DbSetOrder(1))
//	If !(lRet := Z06->(DbSeek(xFilial('Z06') + M->Z05_SEQUEN + StrZero(1, TamSX3('Z06_ITEMPC')[1]) )))
//		ShowHelpDlg("VAEST007-10", 	{'Não foi localizado Itens do Pedido para a Sequencia: ' + M->Z05_SEQUEN }, ,;
//									{"Por Favor verifique o Pedido de Compra Informado !!!"}, )
//	Else
//
//		If ValType(xInfo) == 'C'
//			xInfo := AllTrim(xInfo) 
//		EndIf
//		If cCampo == 'Z07_RFID'     
//			
//			lRet := fX7VldRFID(M->Z05_PEDIDO, xInfo, cSequencia, cItemZ07  )
//			
//		ElseIf cCampo == 'Z07_ITEMPC'
//		
//			If !Empty(xInfo)  	
//				If Len(xInfo) < TamSX3(cCampo)[1]
//					xInfo := StrZero( Val(xInfo), TamSX3(cCampo)[1] )
//				EndIf    
//				If Empty(Posicione('SC7', 1, xFilial('SC7')+ M->Z05_PEDIDO + xInfo, 'C7_PRODUTO') ) // 'Z07_PRODUT'
//					lRet := .F.
//					ShowHelpDlg("VAEST007-11", 	{'O Item informado: '+  AllTrim(&(ReadVar())) + ' nao corresponde a nenhum produto no Pedido: ' + AllTrim(M->Z05_PEDIDO) }, ,;
//												{"Por verifique o item informado !!!"}, )
//					cZ07ItemPC  := CriaVar('Z07_ITEMPC', .F.)
//				Else
//					
//					cZ07ItemPC := xInfo
//				
//					nI := aScan( oZ06:aCols , { |x| AllTrim(x[2])+AllTrim(x[3]) == AllTrim(SC7->C7_ITEM+SC7->C7_PRODUTO) } )
//					nJ := aScan( oZ06:aHeader, { |x| AllTrim(x[2]) == 'Z06_QTDROM'  } )
//					If nI>0 .and. nJ>0 .and. oZ06:aCols[ nI , nJ ] == 0
//						lRet := .F.
//						ShowHelpDlg("VAEST007-12", 	{'A quantidade de entrega nao foi localizada no apontamento: ' + ;
//								M->Z05_SEQUEN + ' para o produto: ' + AllTrim(SC7->C7_PRODUTO) + '-' + Posicione('SB1', 1, xFilial('SB1')+SC7->C7_PRODUTO, 'B1_DESC') }, ,;
//													{"Por verifique o item informado !!!"}, )
//						cZ07ItemPC  := CriaVar('Z07_ITEMPC', .F.)
//					Else
//						
//						lVarMagica  := !lVarMagica // // AtuSaldo:  lInc<>lVarMagica
//						
//						cZ07Produt := SC7->C7_PRODUTO
//						cZ07DescB1 := Posicione('SB1', 1, xFilial('SB1')+SC7->C7_PRODUTO, 'B1_DESC') // 'Z07_DESCB1'
//						
//						If SB1->B1_XIDADE > 0 
//							nZ07Idade  := SB1->B1_XIDADE
//							dZ07DtNas  := MonthSub( DDATABASE, SB1->B1_XIDADE )
//						Else
//							nZ07Idade := 0
//							dZ07DtNas := StoD("")
//						EndIf
//
//					EndIf
//				EndIf
//			EndIf
//
//		ElseIf cCampo == 'Z07_IDADE'
//			If xInfo <= 0
//				ShowHelpDlg("VAEST007-13", 	{'A Idade informada esta incorreta.' }, ,;
//											{"Por digitar novamente !!!"}, )
//				lRet := .F.
//				nZ07Idade   := CriaVar('Z07_IDADE' , .F.)
//			Else
//				dZ07DtNas := MonthSub( DDATABASE, xInfo )
//			EndIf
//		EndIf
//
//	EndIf
//
//Return lRet
//
//
///*--------------------------------------------------------------------------------,
// | Func:  			                                                              |
// | Autor: Miguel Martins Bernardo Junior                                          |
// | Data:  22.01.2017                                                              |
// | Desc:                                                                          |
// |                                                                                |
// | Obs.:  -                                                                       |
// '--------------------------------------------------------------------------------*/
//Static Function fExitQtEntrega()
//Local lRet  := .F.
//Local nI	:= 1
//
//While !lRet .and. nI <= Len(oZ06:aCols)
//	If oZ06:aCols[ nI , aScan( oZ06:aHeader, { |x| AllTrim(x[2]) == 'Z06_QTDROM'  } ) ] > 0
//		lRet := .T.
//	EndIf
//	nI+=1
//EndDo
//
//if !lRet
//	ShowHelpDlg("VAEST007-01", 	{'A quantidade de entrega não foi localizada no apontamento: ' + ;
//								M->Z05_SEQUEN + ' para os produtos do pedido: ' + AllTrim(M->Z05_PEDIDO) }, ,;
//								{"Por verifique o item informado !!!"}, )
//EndIf
//
//Return lRet