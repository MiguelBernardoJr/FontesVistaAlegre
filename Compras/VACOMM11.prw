#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"
#include "colors.ch"
#INCLUDE "TBICONN.CH"

//Constantes // http://erikasarti.com/html/tabela-cores/
#Define CLR_VERMELHO  RGB(255,048,048)	//Cor Vermelha
#Define CLR_VERDE     RGB(119,255,083)	//Cor Verde
#Define CLR_BRANCO    RGB(254,254,254)	//Cor Branco
#Define CLR_CINZA     RGB(180,180,180)	//Cor Cinza
#Define CLR_AZUL      RGB(135,206,250) // DeepSkyBlue - (058,074,119)	//Cor Azul

//Variaveis
Static _M11Codigo := ""

/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     07.12.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Rotina de Contrato - Utilizado atualmente pela Luana;                 |
 |           Esta rotina ANTES estava implementada no fonte VACOMM11;              |
 |           Agora ela foi redesenhada sobre um novo layout neste fonte;		   |
 |           - Remodelagem da rotina de contrato;								   |
 |           		-> ANTIGO: VACOMM11()										   |
 |           		-> NOVO:   VACOMM11() 										   |
 |---------------------------------------------------------------------------------|
 | Regras:   1- O campo ZBC_VERSAO possue funcao para contagem automatica;         |
 |           2- Preenchimento de campos a partir da selecao do pedido;             |
 |---------------------------------------------------------------------------------|
 | Obs.:     U_VACOMM11()                                                          |
 '---------------------------------------------------------------------------------*/
User Function VACOMM11()
	Private cCadastro  := "Configuracao Contratual" //"Configuracao Contratual - NOVO"
	Private cAlias     := "ZCC"
	Private aRotina    := MenuDef()
	Private lRastro	   := GetMV('MV_RASTRO') == 'S'
	Private oMBSaveLog	:= MBSaveLog():New() as object

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( cAlias )
	oBrowse:SetMenuDef("VACOMM11")
	oBrowse:SetDescription( cCadastro )
	/* Coloquei diferente de M para contemplar os VAZIOS */
	oBrowse:SetFilterDefault("ZCC->ZCC_TPCONT <> 'M'") // A=Animais;M=Milho

	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'C'", "BLACK" , "Cancelado" )
	oBrowse:AddLegend( "!Empty(U_fVldVersao(ZCC->ZCC_CODIGO, ZCC->ZCC_VERSAO))", "YELLOW", "Versao Anterior" )
	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'A'", "GREEN" , "Aberto" )
	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'N'", "WHITE" , "Negociação Apta p/ Pedido" )
	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'P'", "ORANGE", "Finalizado Parcialmente" )
	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'F'", "RED"   , "Finalizado Totalmente" )

	GeraX1("COMM11VA")
	GeraX1("BGCOMM11")

	oBrowse:Activate()
Return nil

/* MJ: 07.12.2017 */
user function VAM11Leg()
local aLegenda := {}

//Monta as cores
AAdd(aLegenda, {"BR_PRETO"		, "Cancelado"})
AAdd(aLegenda, {"BR_AMARELO"	, "Versao Anterior"})
AAdd(aLegenda, {"BR_VERDE"		, "Aberto"  })
AAdd(aLegenda, {"BR_BRANCO"		, "Negociação Apta p/ Pedido"  })
AAdd(aLegenda, {"BR_LARANJA"	, "Finalizado Parcialmente"})
AAdd(aLegenda, {"BR_VERMELHO"	, "Finalizado Totalmente"})
//AAdd(aLegenda, {"BR_VERMELHO"	, "Finalizado Totalmente"})

BrwLegenda("Transferências", "Procedencia", aLegenda, 30)

Return nil

/* ------------------------------------------------------------------------------ */
Static Function MenuDef()
Local aRotina := {}
aAdd( aRotina, { 'Pesquisar'            , 'AxPesqui'  			, 0, 1, 0, nil  } )
aAdd( aRotina, { 'Visualizar'           , 'U_COMM11VA'			, 0, 2, 0, nil  } )
aAdd( aRotina, { 'Incluir'              , 'U_COMM11VA'			, 0, 3, 0, nil  } )
aAdd( aRotina, { 'Alterar'              , 'U_COMM11VA'			, 0, 4, 0, nil  } )
aAdd( aRotina, { 'Excluir'              , 'U_COMM11VA'			, 0, 5, 0, nil  } )
aAdd( aRotina, { 'Gerar Versão'         , 'U_COMM11VA'			, 0, 6, 0, nil  } )
aAdd( aRotina, { 'Legenda'         		, 'U_VAM11Leg'			, 0, 7, 0, nil  } )
aAdd( aRotina, { 'Inf. Complementares'  , 'U_COMM11VA'			, 0, 4, 0, nil  } )
aAdd( aRotina, { 'Encerrar contrato'	, 'U_xAltStatus("F")'	, 0, 4, 0, nil  } )
aAdd( aRotina, { 'Cancelar contrato'	, 'U_xAltStatus("C")'	, 0, 4, 0, nil  } )
aAdd( aRotina, { 'Localiza Pedido'	    , 'U_xFiltroConsulta'	, 0, 4, 0, nil  } )
Return aRotina

/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     27.07.2017                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Funcao: X3_VLDUSER, chamada no campo ZBC_PEDIDO, ZBC_ITEMPC, responsa- |
 |         vel por validar o pedido e preenchiar alguns campos automaticamente;     |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
User Function fChvITEM(cTab, cCpoSlc, cCpoMAX, cWhreCpo, cInfo, cNotNull, __cFilial )
	Local cCod        := StrZero( 1, TamSX3(cCpoMAX)[1] )
	Local _cQry       := ""
	Local cAlias      := Iif( Left(cTab,1)=="S", SubS(cTab,2), cTab )
	Default cCpoSlc   := ""
	Default cWhreCpo  := ""
	Default cInfo     := ""
	Default cNotNull  := ""
	Default __cFilial := xFilial(cTab)

	MBSaveLog():FULLWrite(, .F., "Inicio: U_fChvITEM('"+cTab+"', '"+cCpoSlc+"', '"+cCpoMAX+"', '"+cWhreCpo+"', '"+cInfo+"', '"+cNotNull+"', '"+__cFilial+"')")

	_cQry := " SELECT " + cAlias + "_FILIAL, "

	If !Empty(cCpoSlc)
		_cQry += cCpoSlc + ", "
	EndIf

	_cQry += " MAX("+cCpoMAX+ ") SEQUEN " + CRLF
	_cQry += " FROM " + RetSQLName(cTab) + CRLF
	_cQry += " WHERE " + cAlias + "_FILIAL='"+ __cFilial + "' " + CRLF

	If !Empty(cWhreCpo)
		_cQry += " AND " + cWhreCpo + "='" + cInfo + "'" + CRLF
	EndIf            
	If !Empty(cNotNull)
		_cQry += cNotNull + CRLF
	EndIf
	// cQry += " and  D_E_L_E_T = ' ' " + CRLF
	_cQry += " GROUP BY " + cAlias + "_FILIAL "

	If !Empty(cCpoSlc)
		_cQry += ", " + cCpoSlc + CRLF
	EndIf

	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(_cQry)), "TMPQRY", .F., .F.)

	If !TMPQRY->(Eof())
		cCod := Soma1( TMPQRY->SEQUEN )
	EndIf

	TMPQRY->(DbCloseArea())

	MBSaveLog():FULLWrite(, .F., "Fim: U_fChvITEM('"+cTab+"', '"+cCpoSlc+"', '"+cCpoMAX+"', '"+cWhreCpo+"', '"+cInfo+"', '"+cNotNull+"', '"+__cFilial+"')")

Return cCod

/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     31.07.2017                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Processar a inicializacao do campo ZFX_CODIGO; Configurado do campo:   |
 |          X3_RELACAO;                                                             |
 |----------------------------------------------------------------------------------|
 | Obs.:     Esta Funcao esta desativada por uma alteracao de definicao do processo.|
 |         o mesmo passará a ser definido a partir do Duplo-Clique;                 |
 '----------------------------------------------------------------------------------*/
User Function M11nit() // U_M11nit()
	MBSaveLog():FULLWrite(, .F., "U_M11nit(), "+_M11Codigo+"")
	Local  cRet	:= _M11Codigo
Return cRet


/* MJ : 27.10.2017 */
User Function BaseConh()
	Private cCadastro 	:= "Base de Conhecimento"
	MBSaveLog():FULLWrite(, .F., "U_BaseConh(), "+cValToChar(ZCC->(RecNo()))+"")

	MsDocument("ZCC", ZCC->(RecNo()) , 1 )
Return nil


/* ------------------------------------------------------------------
	MJ : 27.10.2017
   ----------------------------------------------------------------- */
Static Function fMenuAux(nOpc)
	MBSaveLog():FULLWrite(, .F., "Inicio: U_fMenuAux()")

	Local nAt 		  := o1ZBCGDad:oBrowse:nAt
	Local cContrat    := M->ZCC_CODIGO
	Local cItem       := StrZero(nAt ,TamSX3('ZBC_ITEM')[01])
	Local cFornec	  := M->ZCC_CODFOR
	Local cLojFor     := M->ZCC_LOJFOR

	
	If nOpc == 1
		u_VAFINA02("P", FWxFilial('ZCC'), cContrat+cItem, cFornec, cLojFor)
	Else
		u_VAFINA03("P", FWxFilial('ZCC'), cContrat+cItem, cFornec, cLojFor)
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: U_fMenuAux()")
Return nil


/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     30.10.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Validar Ultima REVISAO para o CONTRATO                                |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras:                                                                         |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     -                                                                     |
 '---------------------------------------------------------------------------------*/
User Function fVldVersao(cContrato, cVersao)
	MBSaveLog():FULLWrite(, .F., "Inicio: U_fVldVersao('"+cContrato+"', '"+cVersao+"')")

	Local cRet := U_fChvITEM( "ZCC", "ZCC_CODIGO", "ZCC_VERSAO", "ZCC_CODIGO", cContrato)


	If ( Val(cVersao) < Val(cRet)-1 )
		cRet := StrZero( Val(cRet)-1, TamSX3('ZCC_VERSAO')[1] )
	Else
		cRet := ""
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: U_fVldVersao('"+cContrato+"', '"+cVersao+"')")

Return cRet



/* ######################################################################### */
/* MJ: 03.11.2017 */
/* ######################################################################### */
User Function fCanDel(cContrato, cVersao)
	MBSaveLog():FULLWrite(, .F., "Inicio: U_fCanDel('"+cContrato+"', '"+cVersao+"')")
	Local lRet 	 := .T.
	Local _cQry  := ""
	Local cAlias := GetNextAlias()


	_cQry := " SELECT ZBC_FILIAL, ZBC_CODIGO, MAX(ZBC_VERSAO) ZBC_VERSAO, ZBC_PEDIDO, ZBC_ITEMPC, MAX(ZBC_VERPED) ZBC_VERPED " + CRLF
	_cQry += " FROM " + RetSQLName("ZBC") + CRLF
	_cQry += " WHERE" + CRLF
	_cQry += " 	   ZBC_FILIAL='"+FWxFilial('ZBC')+ "' " + CRLF
	_cQry += " AND ZBC_CODIGO='"+cContrato+ "' " + CRLF
	_cQry += " AND ZBC_VERSAO='"+cVersao+ "' " + CRLF
	_cQry += " AND ZBC_PEDIDO<>' ' " + CRLF
	_cQry += " AND D_E_L_E_T_=' '" + CRLF
	_cQry += " GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_PEDIDO, ZBC_ITEMPC "

	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(_cQry)),(cAlias), .F., .F.)

	If !(cAlias)->(Eof())
		lRet := .F.
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: U_fCanDel('"+cContrato+"', '"+cVersao+"')")
Return lRet


/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     06.11.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Esta Funcão foi criada para validar se todos os campos do contrato    |
 |  estao preenchidos, caso estejam, entao a tabela ZCC sera gravada, liberando    |
 |  assim os quadros ZIC e ZBC;                                                    |
 |---------------------------------------------------------------------------------|
 | Regras:   1- Passar na Funcao: Obrigatorio;                                     |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     -                                                                     |
 '---------------------------------------------------------------------------------*/
Static Function M7SlvCrt()
	MBSaveLog():FULLWrite(, .F., "Inicio: U_M7SlvCrt()")

	If Obrigatorio(aGets, aTela)
		DbSelectArea("ZCC")
		ZCC->( DbSetOrder(1) )
		If ZCC->( DbSeek( FWxFilial('ZCC') + M->ZCC_CODIGO + M->ZCC_VERSAO ))
			Aviso("Aviso", 'O Contrato/Versao: ' + M->ZCC_CODIGO +'/' + M->ZCC_VERSAO + ' já se encontra salvo no sistema.', {"Sair"} )
		Else
			// Salvar contrato
			RecLock( "ZCC", .T. )
				U_GrvCpo("ZCC")
				ZCC->ZCC_TPCONT := "A"
			ZCC->(MsUnlock())
			
			// While __lSX8
				ZCC->( ConfirmSX8() )
		
			// EndDo

			// o1ZBCGDad:Enable()
			oGrpF1Q2:Enable()

			// Aviso("Aviso", 'O Contrato/Versao: ' + M->ZCC_CODIGO +'/' + M->ZCC_VERSAO + ' foi gravado com sucesso.', {"Ok"} )
			MsgInfo('O Contrato/Versao: <b>' + M->ZCC_CODIGO +'/' + M->ZCC_VERSAO + '</b> foi gravado com sucesso.', 'Aviso')
		EndIf
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: U_M7SlvCrt()")
Return nil

// /* MJ : 20.11.2017 */
// Static Function findMark(oGD, nColuna)
// Local cRet 	:= ""
// Local nI	:= 0
// 	For nI := 1 to Len(oGD:aCols)
// 		If oGD:aCols[nI, nColuna] == 'LBTIK'
// 			cRet := oGD:aCols[ nI, nPZICITE ]
// 			Exit
// 		EndIf
// 	Next nI
// Return cRet


/* MJ : 20.11.2017 */
User Function CanEdit(lCanEdit, lSupremo)
	Local cCampo 		:= Substr( ReadVar(), At('->', ReadVar())+2 )
	Local lRet 			
	Default lCanEdit 	:= .T.
	Default lSupremo 	:= .F.

	MBSaveLog():FULLWrite(, .F., "Inicio: U_CanEdit( "+iif(lCanEdit,".T.",".F.")+", "+iif(lSupremo,".T.",".F.")+" ), Campo: "+cCampo+"")

	if cCampo == "ZBC_QUANT" .or. cCampo == "ZBC_VLRPTA" .or. cCampo == "ZBC_MARK" .or. cCampo == "ZBC_ALIICM"
		lRet := .T.
	else
		lRet := Iif( Empty(o1ZBCGDad:aCols[o1ZBCGDad:nAt,nPZBCPed]),;
						.T.,;
						lSupremo .or. (lCanEdit .and. iif(FwIsInCallStack("U_VACOMM12"),.t.,o1ZBCGDad:aCols[o1ZBCGDad:nAt,nPZBCPdP]=="P" )) ) // GERA PEDIDO POR 
	endif 

	MBSaveLog():FULLWrite(, .F., "Fim: U_CanEdit( "+iif(lCanEdit,".T.",".F.")+", "+iif(lSupremo,".T.",".F.")+" )")
Return lRet 

/* MJ : 08.11.2017 */
Static Function SetMark(oGD, nLinha, nColuna)
	Local lMark
	Local nLen	:= Len(oGD:aCols)
	Default nLinha  := oGD:nAt

	MBSaveLog():FULLWrite(, .F., "Inicio: U_SetMark( oGD, "+cValToChar(nLinha)+", "+cValToChar(nColuna)+" )")

	lMark := oGD:aCols[nLinha, nColuna] == 'LBNO'

	// If SubS( oGd:aHeader[2,2], 1, 3 ) == "ZBC"
	// 	if Empty( oGD:aCols[nLinha, nPZBCPed] )
	// 		oGD:aCols[nLinha, nColuna] := Iif(lMark, 'LBTIK', 'LBNO')
	// 	EndIf
	// Else
		oGD:aCols[nLinha, nColuna] := Iif(lMark, 'LBTIK', 'LBNO')
	// EndIf

	oGD:Refresh()
	
	MBSaveLog():FULLWrite(, .F., "Fim: U_SetMark( oGD, "+cValToChar(nLinha)+", "+cValToChar(nColuna)+" )")

Return .T.



/*--------------------------------------------------------------------------------,
 | Principal: 					U_MBCOMR01()             	            	      |
 | Func:  GeraX1()  	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  11.03.2019	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

	Local _aArea	:= GetArea()
	Local aRegs     := {}
	Local nX		:= 0
	Local nPergs	:= 0
	Local aRegs		:= {}
	Local i, j

	MBSaveLog():FULLWrite(, .F., "Inicio: U_GeraX1( '"+cPerg+"' )")

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

	if cPerg == 'COMM11VA'
		aAdd(aRegs,{cPerg, "01", "Executa Validacoes e Gatilhos?", "", "", "MV_CH1", "N", 1, 0, 2, "C", "", "MV_PAR01", "Não", "", "", "", "", "Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})
	else 
		aAdd(aRegs,{cPerg,"01", "Data abate de:			", "", "", "MV_CH1", "D", 8, 0, 0, "G", "", "MV_PAR01", "", "", "", "", "", "","","","","","","","","","","","","","","","","","","","","U","","","",""})
		aAdd(aRegs,{cPerg,"02", "Data abate até:		", "", "", "MV_CH2", "D", 8, 0, 0, "G", "", "MV_PAR02", "", "", "", "", "", "","","","","","","","","","","","","","","","","","","","","U","","","",""})
		aAdd(aRegs,{cPerg,"03", "Lote:					", "", "", "MV_CH3", "C", TAMSX3("B8_LOTECTL")[1], TAMSX3("B8_LOTECTL")[2], 0, "G", "", "MV_PAR03", "", "", "", "", "", "","","","","","","","","","","","","","","","","","","","","U","","","",""})
		aAdd(aRegs,{cPerg,"04", "Exibe gravados?		", "", "", "MV_CH4", "C", 1, 0, 0, "C", "", "MV_PAR04", "Não", "", "", "", "", "Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})
	endif 
	//aAdd(aRegs,{cPergBG,"04", "Exibe abates vinculados?" , "", "", "MV_CH4", "C", 1, 0, 1, "G", "", "MV_PAR04", "Não", "", "", "", "", "Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})


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

	MBSaveLog():FULLWrite(, .F., "Fim: U_GeraX1( '"+cPerg+"' )")

	RestArea(_aArea)

Return nil
// FIM: GeraX1


/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     07.12.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Esta rotina é responsavel por realizar as operações basicas de cadas- |
 |         tros;                                                                   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras:                                                                         |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     -                                                                     |
 '---------------------------------------------------------------------------------*/
User Function COMM11VA(cAlias, nReg, nOpc)
Local nGDOpc        := Iif( nOpc == 2, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
Local nOpcA		    := 0
Local oDlg		    := nil
Local aSize		    := {}
Local aObjects      := {}
Local aInfo		    := {}
Local aPObjs        := {}
Local lRecLock	    := .T.
Local nPosAux	    := 0
Local aButtons      := {}
Local cVersao	    := ""
Local nI		    := 0
Local nF		    := 0
Local lPauta 	    := .F.
Local _aCpos 		:= nil
Local aStruct
Local nX, nZ 


Private cUserAlt	:= StrTokArr(AllTrim(GetMV("MV_MT103AL")),";")
Private oEnchF2Q3 	:= nil
Private aHeadEsp    := {}
Private aColsEsp    := {}
Private nUsadEsp    := 0

Private _cOrden 	:= "T", _nQtdNF := 0, _nTotNF := 0, _nQtdCpl := 0, _nTotCpl := 0, _nQtdFre := 0, _nTotFre := 0, _nQtdTotNF := 0, _nVlrTotNF := 0, _nMedXKM := 0, _nCstXKM := 0
Private _nQtdCon := 0, _nTotCom := 0, _nQtdReb := 0

Private /* aFldF2Q1 	:= {},  *//* aFldF3Q1 	:= {}, */ aFldF2Q3  := {}
Private oTFoldeP    := nil, aFolderP := {}
Private oTFoldeG    := nil, aFolderG := {}, nFldOldG := 1

Private oMGet		:= nil
// Private xMatZBC		:= {}
Private oGZBCGDad   := nil, aGZBCHead  := {}, aGZBCCols  := {}, nGUZBC := 1
Private o1ZBCGDad   := nil, a1ZBCHead  := {}, a1ZBCCols  := {}// , n1UZBC := 1
Private o2ZBCGDad   := nil, a2ZBCHead  := {}, a2ZBCCols  := {}// , n2UZBC := 1
Private o3ZBCGDad   := nil, a3ZBCHead  := {}, a3ZBCCols  := {}// , n3UZBC := 1
Private o4ZBCGDad   := nil, a4ZBCHead  := {}, a4ZBCCols  := {}// , n4UZBC := 1
Private o5ZBCGDad   := nil, a5ZBCHead  := {}, a5ZBCCols  := {}// , n5UZBC := 1
Private o6ZBCGDad   := nil, a6ZBCHead  := {}, a6ZBCCols  := {}// , n6UZBC := 1
Private o7ZBCGDad   := nil, a7ZBCHead  := {}, a7ZBCCols  := {}// , n7UZBC := 1
Private o8ZBCGDad   := nil, a1ZBDHead  := {}, a1ZBDCols  := {}// , n7UZBC := 1
Private oZBDGDad    := nil, aZBDHead   := {}, a1ZBDCols  := {}, nGUZBD := 1//, nGUZBC := 1

Private nPZBCITE  := 0, cPFoBCITE := 0
Private nPZBCZIC  := 0, cPFoBCZIC := 0
Private nPZBCPed  := 0, cPFoBCPed := 0
Private nPZBCPIt  := 0, cPFoBCPIt := 0
Private nPZBCPVs  := 0, cPFoBCPVs := 0
Private nPZBCPRD  := 0, cPFoBCPRD := 0
Private nPZBCDES  := 0, cPFoBCDES := 0
Private nPZBCPdP  := 0, cPFoBCPdP := 0
Private nPZBCQtd  := 0, cPFoBCQtd := 0
Private nPZBCPrc  := 0, cPFoBCPrc := 0
Private nPZBCTot  := 0, cPFoBCTot := 0
Private nPZBCPes  := 0, cPFoBCPes := 0
Private nPZBCPeA  := 0, cPFoBCPeA := 0
Private nPZBCPeR  := 0, cPFoBCPeR := 0
Private nPZBCRen  := 0, cPFoBCRen := 0
//Private nPZBCReP  := 0, cPFoBCReP := 0
Private nPZBCArv  := 0, cPFoBCArv := 0
// Private nPZBCArQ  := 0, cPFoBCArQ := 0
Private nPZBCToI  := 0, cPFoBCToI := 0
Private nPZBCCor  := 0, cPFoBCCor := 0
Private nPZBCToP  := 0, cPFoBCToP := 0
Private nPZBCVlU  := 0, cPFoBCVlU := 0
Private nPZBCXTT  := 0, cPFoBCXTT := 0
Private nPZBCVLI  := 0, cPFoBCVLI := 0
Private nPZBCVPT  := 0, cPFoBCVPT := 0
Private nPZBCAIC  := 0, cPFoBCAIC := 0
Private nPZBCICP  := 0, cPFoBCICP := 0
Private nPZBCVCM  := 0, cPFoBCVCM := 0
Private nPZBCDTE  := 0, cPFoBCDTE := 0
Private nPZBCTFX  := 0, cPFoBCTFX := 0
Private nPZBCOBS  := 0, cPFoBCOBS := 0
Private nPZBCSxo  := 0, cPFoBCSxo := 0
Private nPZBCRca  := 0, cPFoBCRca := 0
Private nPZBCDvc  := 0, cPFoBCDvc := 0
Private nPZBC1IC  := 0, cPFoBC1IC := 0
Private nPZBCTPN  := 0, cPFoBCTPN := 0
Private nPZBCCDP  := 0, cPFoBCCDP := 0
Private nPZBCPNG  := 0, cPFoBCPNG := 0
Private nPZBCTNG  := 0, cPFoBCTNG := 0
Private nPZBCROB  := 0, cPFoBCROB := 0
Private nPZBCOTS  := 0, cPFoBCOTS := 0
Private nPZBCTES  := 0, cPFoBCTES := 0
Private nPZBCTPS  := 0, cPFoBCTPS := 0
Private nPZBCAQS  := 0, cPFoBCAQS := 0
Private nPZBCVLS  := 0, cPFoBCVLS := 0
Private nPZBCOMU  := 0, cPFoBCOMU := 0
Private nPZBCOMT  := 0, cPFoBCOMT := 0
Private nPZBCOTA  := 0, cPFoBCOTA := 0
Private nPZBCOFM  := 0, cPFoBCOFM := 0
Private nPZBCJur  := 0, cPFoBCJur := 0

Private nPMrkZBC  := 0

Private aGets       := {}
Private aTela       := {}

Private aZBD		:= {}

Private nFldPant	:= 0
// Private nF2Q2Ant	:= 0, lF2Q2Cresc := .T. // , lF2Q2Ord := .F.
// Private nF2Q2Cont   := 0

MBSaveLog():FULLWrite(, .F., "Inicio: U_COMM11VA( '"+cAlias+"',"+cValToChar(nReg)+","+cValToChar(nOPc)+" )")

MBSaveLog():FULLWrite(, .F., "RegToMemory( '"+cAlias+"',"+iif(nOpc == 3,".T.",".F.")+")")
RegToMemory( cAlias, nOpc == 3 )

// Carregar em memoria parametro
Pergunte("COMM11VA", .F.)

MBSaveLog():FULLWrite(, .F., "Inicio validações iniciais U_COMM11VA()")

If nOpc == 4 .and. !Empty(cVersao:= U_fVldVersao(ZCC->ZCC_CODIGO, ZCC->ZCC_VERSAO))
	// Se retornou CODIGO de versao, entao nao posso continuar
	Aviso("Aviso", 'A Versao selecionada: ' + ZCC->ZCC_VERSAO + ' nao pode ser alterada.' + CRLF+;
				   ' O contrato No.: ' + ZCC->ZCC_CODIGO + ' encontra-se autalmente na versao: ' + cVersao, ;
				   {"Sair"})
	Return nil

ElseIf (nOpc == 4 .or. nOpc == 5 .or. nOpc == 6) .and. ZCC->ZCC_STATUS == "C"
	// Se retornou CODIGO de versao, entao nao posso continuar
	Aviso("Aviso", 'O contrato selecionado encontra-se cancelado e não pode ser alterado.', {"Sair"})
	Return nil

// MJ : 21.06.2018 => alterado para permitir alteracao, depois da reuniao com CAmila, solicit. por Luana
ElseIf (nOpc == 4 .or. nOpc == 5/*  .or. nOpc == 6 */) .and. ZCC->ZCC_STATUS$"FP"

	If !(lPauta := U_TemPauta())
		// Se retornou CODIGO de versao, entao nao posso continuar
		Aviso("Aviso", 'O contrato selecionado encontra-se finalizado e não pode ser alterado.', {"Sair"})
		Return nil
	EndIf

// // MJ : 21.06.2018 => alterado para permitir alteracao, depois da reuniao com CAmila, solicit. por Luana
// ElseIf ( nOpc == 6 .and. ZCC->ZCC_STATUS$"FP" )
	// Alert( 'Agora pode alterar' )

ElseIf nOpc == 5 .and. !Empty(cVersao:= U_fVldVersao(ZCC->ZCC_CODIGO, ZCC->ZCC_VERSAO))
	// Se retornou CODIGO de versao, entao nao posso continuar
	Aviso("Aviso", 'A Versao selecionada: ' + ZCC->ZCC_VERSAO + ' nao pode ser excluida.' + CRLF+;
				   ' O contrato No.: ' + ZCC->ZCC_CODIGO + ' encontra-se autalmente na versao: ' + cVersao, ;
				   {"Sair"})
	Return nil

ElseIf nOpc == 5 .and. !U_fCanDel(ZCC->ZCC_CODIGO, ZCC->ZCC_VERSAO)
	Aviso("Aviso", 'O contrato No.: ' + ZCC->ZCC_CODIGO + ' na versao selecionada: ' + ZCC->ZCC_VERSAO + ' nao pode ser excluida.' + CRLF+;
				   'Existem pedidos de compra vinculados ja a este contrato.' , ;
				   {"Sair"})
	Return nil
EndIf

MBSaveLog():FULLWrite(, .F., "Fim validações iniciais U_COMM11VA()")

aSize := MsAdvSize( .T. )
AAdd( aObjects, { 100 , 50, .T. , .T. , .F. } )
AAdd( aObjects, { 100 , 50, .T. , .T. , .F. } )
aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T., .F.)

// os REGISTROS só poderam ser alterados se o STATUS estiver com status aberto;
If nOpc < 6 .and. !M->ZCC_STATUS$"AN" .and.  nGDOpc <> 0
	If !lPauta
		nGDOpc := 0
	EndIf
EndIf

MBSaveLog():FULLWrite(, .F., "Inicio configuração dos campos da tela")

// Configuração da Base Contratual
// a1ZBCHead  := APBuildHeader("ZBC") // a1ZBCCols  := A610CriaCols( "ZBC", a1ZBCHead, , {|| .F.})
AAdd(aGZBCHead, { " ", Padr("ZBC_MARK", 10), "@BMP", 1, 0, .F., "", "C", "", "V", "", "", "", "V", "", "", "" } )
U_BDados( "ZBC", @aGZBCHead, @aGZBCCols, @nGUZBC, 1, , IIf( nOpc != 3, "'" + M->ZCC_CODIGO + M->ZCC_VERSAO + "' == ZBC->ZBC_CODIGO + ZBC->ZBC_VERSAO", nil  ) )

// 1 = Valor Pedido / Pauta
a1ZBCHead := aClone(aGZBCHead)
a1ZBCCols := aClone(aGZBCCols)
U_TiraDoGrp( @a1ZBCHead, @a1ZBCCols, "!Empty(SX3->X3_FOLDER) .AND. SX3->X3_FOLDER <> '1'")

// 2 = Peso
a2ZBCHead := aClone(aGZBCHead)
a2ZBCCols := aClone(aGZBCCols)
U_TiraDoGrp( @a2ZBCHead, @a2ZBCCols, "!Empty(SX3->X3_FOLDER) .AND. SX3->X3_FOLDER <> '2'")

// 3 = ICMS
a3ZBCHead := aClone(aGZBCHead)
a3ZBCCols := aClone(aGZBCCols)
U_TiraDoGrp( @a3ZBCHead, @a3ZBCCols, "!Empty(SX3->X3_FOLDER) .AND. SX3->X3_FOLDER <> '3'")

// 4 = Senar
a4ZBCHead := aClone(aGZBCHead)
a4ZBCCols := aClone(aGZBCCols)
U_TiraDoGrp( @a4ZBCHead, @a4ZBCCols, "!Empty(SX3->X3_FOLDER) .AND. SX3->X3_FOLDER <> '4'")

// 5 = Frete
a5ZBCHead := aClone(aGZBCHead)
a5ZBCCols := aClone(aGZBCCols)
U_TiraDoGrp( @a5ZBCHead, @a5ZBCCols, "!Empty(SX3->X3_FOLDER) .AND. SX3->X3_FOLDER <> '5'")

// 6 = Comissão
a6ZBCHead := aClone(aGZBCHead)
a6ZBCCols := aClone(aGZBCCols)
U_TiraDoGrp( @a6ZBCHead, @a6ZBCCols, "!Empty(SX3->X3_FOLDER) .AND. SX3->X3_FOLDER <> '6'")

// 7 = Valor Final
a7ZBCHead := aClone(aGZBCHead)
a7ZBCCols := aClone(aGZBCCols)
U_TiraDoGrp( @a7ZBCHead, @a7ZBCCols, "!Empty(SX3->X3_FOLDER) .AND. SX3->X3_FOLDER <> '7'")

a8ZBCHead := aClone(a1ZBCHead)
a8ZBCCols := aClone(a1ZBCCols)

aStruct := ZBD->(DbStruct())
 
//Percorre todos os campos da estrutura da tabela
For nI := 1 To Len(aStruct)
    //Chama a função que adiciona ao array via @, conforme o campo atual, e o tipo é 4 que será usado em um MsNewGetDados
	if aStruct[nI][1] $ 'ZBD_ITEM|ZBD_DATA|ZBD_CODPED'
    	u_zX3ToArr(@aZBDHead, aStruct[nI][1], 4)
	endif
Next nI 

a1ZBDHead := aClone(aZBDHead)
GetColZBD()

//U_TiraDoGrp( @a1ZBDHead, @a1ZBDCols, "!Empty(SX3->X3_FOLDER) .AND. SX3->X3_FOLDER <> '1'")

nPMrkZBC  := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == 'ZBC_MARK'})
// Desenhando todos os quadros
For nI := 1 to Len(a1ZBCCols)
	If Empty( a1ZBCCols[ nI, nPMrkZBC] )
		a1ZBCCols[ nI, nPMrkZBC] := "LBNO"
		a2ZBCCols[ nI, nPMrkZBC] := "LBNO"
		a3ZBCCols[ nI, nPMrkZBC] := "LBNO"
		a4ZBCCols[ nI, nPMrkZBC] := "LBNO"
		a5ZBCCols[ nI, nPMrkZBC] := "LBNO"
		a6ZBCCols[ nI, nPMrkZBC] := "LBNO"
		a7ZBCCols[ nI, nPMrkZBC] := "LBNO"
	EndIf
Next nI

// nPZBCFaxa  := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_FAIXA"  })
nPZBCITE     := RetPosCpoAba( "ZBC_ITEM"  , @cPFoBCITE ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_ITEM"   } )
nPZBCZIC     := RetPosCpoAba( "ZBC_ITEZIC", @cPFoBCZIC ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_ITEZIC" } )
nPZBCPed     := RetPosCpoAba( "ZBC_PEDIDO", @cPFoBCPed ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_PEDIDO" } )
nPZBCPIt     := RetPosCpoAba( "ZBC_ITEMPC", @cPFoBCPIt ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_ITEMPC" } )
nPZBCPVs     := RetPosCpoAba( "ZBC_VERPED", @cPFoBCPVs ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_VERPED" } )
nPZBCPRD     := RetPosCpoAba( "ZBC_PRODUT", @cPFoBCPRD ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_PRODUT" } )
nPZBCDES     := RetPosCpoAba( "ZBC_PRDDES", @cPFoBCDES ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_PRDDES" } )
nPZBCPdP     := RetPosCpoAba( "ZBC_PEDPOR", @cPFoBCPdP ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_PEDPOR" } )
nPZBCQtd     := RetPosCpoAba( "ZBC_QUANT" , @cPFoBCQtd ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_QUANT"  } )
nPZBCPrc     := RetPosCpoAba( "ZBC_PRECO" , @cPFoBCPrc ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_PRECO"  } )
nPZBCTot     := RetPosCpoAba( "ZBC_TOTAL" , @cPFoBCTot ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_TOTAL"  } )
nPZBCPeR     := RetPosCpoAba( "ZBC_PESREA", @cPFoBCPeR )
nPZBCPes     := RetPosCpoAba( "ZBC_PESO"  , @cPFoBCPes ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_PESO"   } )
nPZBCPeA     := RetPosCpoAba( "ZBC_PESOAN", @cPFoBCPeA ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_PESOAN" } )
nPZBCRen     := RetPosCpoAba( "ZBC_REND"  , @cPFoBCRen ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_REND"   } )
//nPZBCReP   := RetPosCpoAba( "ZBC_RENDP" , @cPFoBCReP ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_RENDP"  } )
// nPZBCArQ  := RetPosCpoAba( "ZBC_ARROQ" , @cPFoBCArQ ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_ARROQ"  } )

nPZBCArv     := RetPosCpoAba( "ZBC_ARROV" , @cPFoBCArv ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_ARROV"  } )
nPZBCROB     := RetPosCpoAba( "ZBC_VLAROB", @cPFoBCROB )
nPZBCDvc     := RetPosCpoAba( "ZBC_DTVCTO", @cPFoBCDvc )
nPZBCToI     := RetPosCpoAba( "ZBC_TOTICM", @cPFoBCToI ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_TOTICM" } )
nPZBCCor     := RetPosCpoAba( "ZBC_X_CORR", @cPFoBCCor ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_X_CORR" } )
nPZBCToP     := RetPosCpoAba( "ZBC_ICMSVL", @cPFoBCToP ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_ICMSVL" } )
nPZBCVlU     := RetPosCpoAba( "ZBC_VLUSIC", @cPFoBCVlU ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_VLUSIC" } )
nPZBCXTT     := RetPosCpoAba( "ZBC_TTSICM", @cPFoBCXTT ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_TTSICM" } )
nPZBCVLI     := RetPosCpoAba( "ZBC_VLICM" , @cPFoBCVLI ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_VLICM"  } )
nPZBCVPT     := RetPosCpoAba( "ZBC_VLRPTA", @cPFoBCVPT ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_VLRPTA" } )
nPZBCAIC     := RetPosCpoAba( "ZBC_ALIICM", @cPFoBCAIC ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_ALIICM" } )
nPZBCICP     := RetPosCpoAba( "ZBC_VICMPA", @cPFoBCICP ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_VICMPA" } )
nPZBCVCM     := RetPosCpoAba( "ZBC_VLRCOM", @cPFoBCVCM ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_VLRCOM" } )
nPZBCDTE     := RetPosCpoAba( "ZBC_DTENTR", @cPFoBCDTE ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_DTENTR" } )
nPZBCTFX     := RetPosCpoAba( "ZBC_TEMFXA", @cPFoBCTFX ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_TEMFXA" } )
nPZBCOBS     := RetPosCpoAba( "ZBC_OBS"   , @cPFoBCOBS ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_OBS"    } )
nPZBCSxo     := RetPosCpoAba( "ZBC_SEXO"  , @cPFoBCSxo ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_SEXO"   } )
nPZBCRca     := RetPosCpoAba( "ZBC_RACA"  , @cPFoBCRca ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_RACA"   } )
nPZBC1IC     := RetPosCpoAba( "ZBC_SB1ZIC", @cPFoBC1IC ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_SB1ZIC" } )
nPZBC1IC     := RetPosCpoAba( "ZBC_SB1ZIC", @cPFoBC1IC ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_SB1ZIC" } )
// nPZBCDEi  := RetPosCpoAba( "ZBC_DESPRD", @cPFoBCDEi )
nPZBCTPN     := RetPosCpoAba( "ZBC_TPNEG" , @cPFoBCTPN ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_TPNEG"  } )
nPZBCCDP     := RetPosCpoAba( "ZBC_CONDPA", @cPFoBCCDP ) // aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_CONDPA"  } )
nPZBCPNG     := RetPosCpoAba( "ZBC_PRENEG", @cPFoBCPNG )
nPZBCTNG     := RetPosCpoAba( "ZBC_TOTNEG", @cPFoBCTNG )
nPZBCOTS     := RetPosCpoAba( "ZBC_OUTDES", @cPFoBCOTS )
nPZBCTES     := RetPosCpoAba( "ZBC_TES"   , @cPFoBCTES )
nPZBCTPS     := RetPosCpoAba( "ZBC_TPSENA", @cPFoBCTPS ) // Tipo da Negociacao Senar
nPZBCOMU     := RetPosCpoAba( "ZBC_COMUNI", @cPFoBCOMU ) // Comissão Unitário
nPZBCOMT     := RetPosCpoAba( "ZBC_VLRCOM", @cPFoBCOMT ) // Comissão Total
nPZBCAQS     := RetPosCpoAba( "ZBC_ALIQSE", @cPFoBCAQS ) // Aliquota Senar
nPZBCVLS     := RetPosCpoAba( "ZBC_VLRSEN", @cPFoBCVLS ) // Valor Senar

// MJ: 29.04.2019
nPZBCOTA     := RetPosCpoAba( "ZBC_OUTACR", @cPFoBCOTA )	// Outros Acrescimos
nPZBCOFM     := RetPosCpoAba( "ZBC_VLRFIM", @cPFoBCOFM )	// Acrescenta Valor de Comissão no valor final

// MJ: 21.05.2019
nPZBCJur     := RetPosCpoAba( "ZBC_JUROS", @cPFoBCJur )	// Acrescenta Juros

MBSaveLog():FULLWrite(, .F., "Fim configuração dos campos da tela")
// a1ZBCCols := aClone( a1ZBCCols[1] )

If nOpc == 3
	M->ZCC_CODIGO	:= GETSX8NUM('ZCC','ZCC_CODIGO')
	M->ZCC_VERSAO   := StrZero( 1, TamSX3('ZCC_VERSAO')[1])
Else

	// Processa/Atualiza campo Versao
	If nOpc == 6 // NOVA VERSAO

		M->ZCC_VERSAO := U_fChvITEM( "ZCC", "ZCC_CODIGO", "ZCC_VERSAO", "ZCC_CODIGO", ZCC->ZCC_CODIGO)
		M->ZCC_STATUS := "A"
		// Base Contratual
		nI := 1
		nPosAux := aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_VERPED"} )
		For nI := 1 to Len(a1ZBCCols)
			cChave := ZCC->ZCC_CODIGO + ZCC->ZCC_VERSAO + a1ZBCCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_PEDIDO"})] + a1ZBCCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEMPC"})]
			a1ZBCCols[ nI, nPosAux ] := U_fChvITEM('ZBC','ZBC_CODIGO, ZBC_VERSAO, ZBC_PEDIDO, ZBC_ITEMPC', 'ZBC_VERPED', 'ZBC_CODIGO+ZBC_VERSAO+ZBC_PEDIDO+ZBC_ITEMPC', cChave )
		Next nI
	EndIf

EndIf

MBSaveLog():FULLWrite(, .F., "Inicio Montagem Dialog")

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From 0,0 to aSize[6],aSize[5] PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |
oDlg:lMaximized := .T.

nDist := 3
aFolderP := {"Contrato", "Entrada", "Financeiro", "Estoque"} // Principal
// TFolder():New( [ nTop ], [ nLeft ], [ aPrompts ], [ aDialogs ], [ oWnd ], [ nOption ], [ nClrFore ], [ uParam8 ], [ lPixel ], [ uParam10 ],
//                [ nWidth ], [ nHeight ], [ cMsg ], [ uParam14 ] )
oTFoldeP := TFolder():New( 0, 0, aFolderP,,oDlg,,,,.T.,, 0, 0)
oTFoldeP:Align := CONTROL_ALIGN_ALLCLIENT
oTFoldeP:bChange   := { || FldChang(nOpc) }

// Contrato
nCut := 45
// TGroup():New( [ nTop ], [ nLeft ], [ nBottom ], [ nRight ], [ cCaption ], [ oWnd ], [ nClrText ], [ nClrPane ], [ lPixel ], [ uParam10 ] )
oGrpF1Q1  := TGroup():New( nDist, aPObjs[1,2]+nDist, aPObjs[1,3]-nDist-nCut, aPObjs[1,4]-nDist,;
						"Dados Gerais do Contrato",oTFoldeP:aDialogs[1],,, .T.,)
// MsmGet(): New ( [ cAlias], [ uPar2], < nOpc>, [ uPar4], [ uPar5], [ uPar6], [ aAcho], ;
//				   [ aPos]/*{"TOP","LEFT","BOTTOM","RIGHT"}*/, [ aCpos], [ nModelo], [ uPar11], [ uPar12], [ uPar13], [ oWnd], [ lF3], [ lMemoria], [ lColumn], [ caTela], [ lNoFolder], [ lProperty], [ aField], [ aFolder], [ lCreate], [ lNoMDIStretch], [ uPar25] )

If (nOpc == 8)
	_aCpos := {}
	aAdd( _aCpos, "ZCC_CODCOR" )
	aAdd( _aCpos, "ZCC_QTTTAN" )

EndIf

oMGet  := MsMGet():New( cAlias, nReg, Iif(nGDOpc==0, 2, Iif(nOpc==8, 3, nOpc) ),,,,, ;
				/* { aPObjs[1,1]-nDist, aPObjs[1,2], aPObjs[1,3], aPObjs[1,4] } */ aPObjs[1] ;
				, _aCpos,,,,, oGrpF1Q1,/*lF3*/,/*lMemoria*/,/*lColumn*/,/*caTela*/,/*lNoFolder*/,/*lProperty*/,/* aField */,;
			/* aFolder */,/*lCreate*/, .T./*lNoMDIStretch*/,/*cTela*/)
oMGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT


if M->ZCC_STATUS == 'N' .and. nOpc <> 8
	oMGet:Disable()
//elseif /* M->ZCC_STATUS == 'N' .and.  */nOpc == 4 .and. ( __cUserID != cUserAlt[1]  .or. __cUserID != cUserAlt[2] )
//	oMGet:Disable()
endIf


// TGroup():New( [ nTop ], [ nLeft ], [ nBottom ], [ nRight ], [ cCaption ], [ oWnd ], [ nClrText ], [ nClrPane ], [ lPixel ], [ uParam10 ] )
oGrpF1Q2  := TGroup():New( aPObjs[2,1]-nCut, aPObjs[2,2]+nDist, aPObjs[2,3]-nDist-(nCut+10), aPObjs[2,4]-nDist, ;
						"Configuração da Base Contratual", oTFoldeP:aDialogs[1],,, .T.,)
// TFolder():New( [ nTop ], [ nLeft ], [ aPrompts ], [ aDialogs ], [ oWnd ], [ nOption ], [ nClrFore ], [ uParam8 ]
// 				, [ lPixel ], [ uParam10 ], [ nWidth ], [ nHeight ], [ cMsg ], [ uParam14 ] )

// aFolderG := {"Valores Pedido/Pauta", "Peso", "ICMS", "Senar", "Frete", "Comissão", "Valor Final"} // Grid - MsNewGetDados
SXA->(DbSetOrder(1))
If SXA->(DbSeek( "ZBC" ))
	While !SXA->(Eof()) .and. SXA->XA_ALIAS == "ZBC"
		aAdd( aFolderG, SXA->XA_DESCRIC )
		SXA->(DbSkip())
	EndDo
EndIf

oTFoldeG := TFolder():New( 0, 0, aFolderG,, oGrpF1Q2,,,,.T.,,0, 0 )
oTFoldeG:Align   := CONTROL_ALIGN_ALLCLIENT
// oTFoldeG:bChange := {|| Processa({ || ProcessMessages(), ;
// 									  ReLoadFolder( oTFoldeG:nOption ) }, ;
// 									  "Atualizando Tabela da Aba: " + cValToChar(oTFoldeG:nOption) ) }

/* if nOpc == 4 .and. ( __cUserID != cUserAlt[1]  .or. __cUserID != cUserAlt[2] )
	oTFoldeG:Disable()
endif  */


oGZBCGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZBC_ITEM" , , , , , , "u_ZBCDelOk(oGZBCGDad)", ;
				oDlg, aClone(aGZBCHead), aClone( aGZBCCols ) )

nTamFold := (aPObjs[1,4] / 2)

// 1 = Valores Pedido/Pauta
o1ZBCGDad := MsNewGetDados():New( 0, 0, 0, (nTamFold + (aPObjs[1,4] / 3.5))- nDist, nGDOpc, , , "+ZBC_ITEM" , , , , , , "u_ZBCDelOk(o1ZBCGDad)", ;
				oTFoldeG:aDialogs[1], aClone(a1ZBCHead), aClone( a1ZBCCols ), "U_ZBCbChan(o1ZBCGDad)" )
o1ZBCGDad:oBrowse:Align := CONTROL_ALIGN_LEFT
o1ZBCGDad:cFieldOK := "U_ZBCFieldOK()"

o8ZBCGDad := MsNewGetDados():New( 0, 0, 0, (nTamFold -  (aPObjs[1,4] / 3.5)) - 10, nGDOpc, , , "+ZBC_ITEM" , , , , , , "U_VldDZBD(o8ZBCGDad)", ;
				oTFoldeG:aDialogs[1], aClone(a1ZBDHead), aClone( a1ZBDCols ) )
o8ZBCGDad:oBrowse:Align := CONTROL_ALIGN_RIGHT

// o1ZBCGDad:bChange  := {|| ZBCbChange() }
// o1ZBCGDad:bLinhaOK := {|| ZBCLinOK() }
// o1ZBCGDad:cDelOK := "u_ZBCDelOk()"
o1ZBCGDad:oBrowse:BlDblClick := { || If( o1ZBCGDad:oBrowse:nColPos == 1 .and. fCanSelBC(), SetMark(o1ZBCGDad, , nPMrkZBC), o1ZBCGDad:EditCell() ) }
// o1ZBCGDad:oBrowse:BlDblClick := {|| DbClickZBC() }  // no campo X3_VLDUSER
// xVarM := ClassMethArr( o1ZBCGDad , .T. ) // Magica
// xVarD := ClassDataArr( o1ZBCGDad , .T. ) // Magica

// // 2 = Peso
o2ZBCGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZBC_ITEM" , , , , , , "u_ZBCDelOk(o2ZBCGDad)", ;
				oTFoldeG:aDialogs[2], aClone(a2ZBCHead), aClone( a2ZBCCols ) )
o2ZBCGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
o2ZBCGDad:cFieldOK    := "U_ZBCFieldOK()"

// 3 = ICMS
o3ZBCGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZBC_ITEM" , , , , , , "u_ZBCDelOk(o3ZBCGDad)", ;
				oTFoldeG:aDialogs[3], aClone(a3ZBCHead), aClone( a3ZBCCols ) )
o3ZBCGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
o3ZBCGDad:cFieldOK    := "U_ZBCFieldOK()"

// 4 = Senar
o4ZBCGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZBC_ITEM" , , , , , , "u_ZBCDelOk(o4ZBCGDad)", ;
				oTFoldeG:aDialogs[4], aClone(a4ZBCHead), aClone( a4ZBCCols ) )
o4ZBCGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
o4ZBCGDad:cFieldOK    := "U_ZBCFieldOK()"

// 5 = Frete
o5ZBCGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZBC_ITEM" , , , , , , "u_ZBCDelOk(o5ZBCGDad)", ;
				oTFoldeG:aDialogs[5], aClone(a5ZBCHead), aClone( a5ZBCCols ) )
o5ZBCGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
o5ZBCGDad:cFieldOK    := "U_ZBCFieldOK()"

// 6 = Comissão
o6ZBCGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZBC_ITEM" , , , , , , "u_ZBCDelOk(o6ZBCGDad)", ;
				oTFoldeG:aDialogs[6], aClone(a6ZBCHead), aClone( a6ZBCCols ) )
o6ZBCGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
o6ZBCGDad:cFieldOK    := "U_ZBCFieldOK()"

// 7 = Valor Final
o7ZBCGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZBC_ITEM" , , , , , , "u_ZBCDelOk(o7ZBCGDad)", ;
				oTFoldeG:aDialogs[7], aClone(a7ZBCHead), aClone( a7ZBCCols ) )
o7ZBCGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
o7ZBCGDad:cFieldOK    := "U_ZBCFieldOK()"

// folder: ENTRADA ##########################################################################################

nF2_3x	  := aPObjs[2,3] / 3
// TGroup():New( [ nTop ], [ nLeft ], [ nBottom ], [ nRight ], [ cCaption ], [ oWnd ], [ nClrText ], [ nClrPane ], [ lPixel ], [ uParam10 ] )
// oGrpF2Q1  := TGroup():New( nDist, aPObjs[1,2]+nDist, nF2_3x*0.5, aPObjs[1,4]-nDist,;
//							"Parametros:",oTFoldeP:aDialogs[2],,, .T.,)

//                Titulo,      Campo,      Tipo, Tamanho, Decimal, Pict, Valid, Obrigat,  Nivel, Inic Padr,    F3, When, Visual, Chave,            CBox, Folder, N Alteravel, PictVar, Gatilho
// aAdd(aFldF2Q1, { "Ordenacao",  "_cOrden",   "C",       1,       0, "@!",      ,     .F.,     1,         "", "   ",   "",    .F.,   .F., "T=Tipo;D=Data",      1,         .F.,      "",      "N"} )
// oEnchF2Q1 := MsMGet():New(,, 3,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/, aPObjs[1],/*aAlterEnch*/,/*nModelo*/,;
// 					/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oGrpF2Q1,/*lF3*/,/*lMemoria*/, .F./*lColumn*/,;
// 					nil /*caTela*/,/*lNoFolder*/, .T./*lProperty*/,aFldF2Q1,/*aFolder*/,/*lCreate*/,/*lNoMDIStretch*/,/*cTela*/)
// oEnchF2Q1:oBox:Align := CONTROL_ALIGN_ALLCLIENT
//
// //SButton():New( [ nTop ], [ nLeft ], [ nType ], [ bAction ], [ oWnd ], [ lEnable ], [ cMsg ], [ bWhen ] )
// oSButton := SButton():New( nF2_3x*0.5-20, aPObjs[1,4]-60-nDist, 9, {|| LoadF2Q2() }, oGrpF2Q1/* oDlg */, .T.,"Ordenação",)


oGrpF2Q2  := TGroup():New( /* nF2_3x*0.5+ */nDist, aPObjs[1,2]+nDist, nF2_3x*1.6, aPObjs[1,4]-nDist,;
							"Notas Fiscais de Entrada:",oTFoldeP:aDialogs[2],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
/*01*/ aAdd(aHeadEsp,{ "Tipo"			, "TIPO"		, "@!"		                   , 020, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*02*/ aAdd(aHeadEsp,{ "Nota Fiscal" 	, "NOTA_FISCAL"	, "@!"		                   , 015, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*02*/ aAdd(aHeadEsp,{ "Cod Fornecedor" , "COD_FORNECE"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*03*/ aAdd(aHeadEsp,{ "Fornecedor"     , "A2_NOME"	    , "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*04*/ aAdd(aHeadEsp,{ "Dt Emissao"		, "D1_EMISSAO"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
/*05*/ aAdd(aHeadEsp,{ "Cod. Produto"   , "D1_COD"	    , "@!"		                   , 015, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*06*/ aAdd(aHeadEsp,{ "Armazém"        , "D1_LOCAL"    , "@!"		                   , 002, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*06*/ aAdd(aHeadEsp,{ "Unid. Med."     , "D1_UM"	    , "@!"		                   , 005, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*07*/ aAdd(aHeadEsp,{ "Quant."	    	, "D1_QUANT"	, PesqPict("SD1", "D1_QUANT")  , TamSX3("D1_QUANT")[1]  , TamSX3("D1_QUANT")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
/*08*/ aAdd(aHeadEsp,{ "R$ Unit."	    , "D1_VUNIT"	, PesqPict("SD1", "D1_VUNIT")  , TamSX3("D1_VUNIT")[1]  , TamSX3("D1_VUNIT")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
/*09*/ aAdd(aHeadEsp,{ "R$ Total"	    , "D1_TOTAL"	, PesqPict("SD1", "D1_TOTAL")  , TamSX3("D1_TOTAL")[1]  , TamSX3("D1_TOTAL")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
/*10*/ aAdd(aHeadEsp,{ "R$ ICMS"	    , "D1_VALICM"	, PesqPict("SD1", "D1_VALICM") , TamSX3("D1_VALICM")[1] , TamSX3("D1_VALICM")[2],"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
/*11*/ aAdd(aHeadEsp,{ "Cod. Fiscal"    , "D1_CF"		, "@!"		                   , 004, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*12*/ aAdd(aHeadEsp,{ "Km"   			, "D1_X_KM"		, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*13*/ aAdd(aHeadEsp,{ "Peso Chegada"	, "D1_X_PESCH"	, PesqPict("SD1", "D1_X_PESCH"), TamSX3("D1_X_PESCH")[1], TamSX3("D1_X_PESCH")[2],"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
/*14*/ aAdd(aHeadEsp,{ "Dt Embarque"	, "D1_X_EMBDT"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
/*15*/ aAdd(aHeadEsp,{ "Hr Embarque"    , "D1_X_EMBHR"	, "@!"		                   , 004, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*16*/ aAdd(aHeadEsp,{ "Dt Chegada"		, "D1_X_CHEDT"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
/*17*/ aAdd(aHeadEsp,{ "Hr Chegada"     , "D1_X_CHEHR"	, "@!"		                   , 004, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*12*/ aAdd(aHeadEsp,{ "Tes"            , "D1_TES"	    , "@!"		                   , 003, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*13*/ aAdd(aHeadEsp,{ "Estoque ?"     , "F4_ESTOQUE"	, "@!"		                   , 003, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// 										   GD_INSERT + GD_UPDATE + GD_DELETE
oGetF2Q2:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,,oGrpF2Q2, aHeadEsp, aColsEsp)
oGetF2Q2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetF2Q2:oBrowse:lUseDefaultColors := .F.
oGetF2Q2:oBrowse:SetBlkBackColor({|| GETDCLR( oGetF2Q2 )})
// oGetF2Q2:lCanEditLine := .F.
// {|oBrw,nCol,aDim| If( Self:lCanEditLine, (oBrw:nColPos := nCol,GetCellRect(oBrw,@aDim),GetDEditMenu(Self,aDim)),)} // original
oGetF2Q2:oBrowse:bHeaderClick := { |oGetF2Q2,nCol| OrdenaF2Q2(nCol) }

oGrpF2Q3  := TGroup():New( nF2_3x*1.6+nDist, aPObjs[1,2]+nDist, aPObjs[2,3]-nDist-(nCut+10), aPObjs[1,4]-nDist,;
							"Resumos:",oTFoldeP:aDialogs[2],,, .T.,)
aAdd(aFldF2Q3, { "Qtd Notas: "       		, "_nQtdNF"   , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Total Notas: "     		, "_nTotNF"   , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Qtd NF Compl:"     		, "_nQtdCpl"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Total Complemento:"		, "_nTotCpl"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Qtd NF Frete:"     		, "_nQtdFre"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Total Frete:"      		, "_nTotFre"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Média KM:"	 	 		, "_nMedXKM"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Custo por KM:"	 		, "_nCstXKM"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Quant Total Notas:"		, "_nQtdTotNF", "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "R$ Total Notas:"	 		, "_nVlrTotNF", "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Total Comissão:"	 		, "_nTotCom"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Qtd Animais no Contrato:"	, "_nQtdCon"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Qtd Animais Receb. em NF:", "_nQtdReb"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )

oEnchF2Q3 := MsMGet():New(,, 3,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/, aPObjs[1],/*aAlterEnch*/,/*nModelo*/,;
					/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oGrpF2Q3,/*lF3*/,/*lMemoria*/, .F./*lColumn*/,;
					nil /*caTela*/,/*lNoFolder*/, .T./*lProperty*/,aFldF2Q3,/*aFolder*/,/*lCreate*/,/*lNoMDIStretch*/,/*cTela*/)
oEnchF2Q3:oBox:Align := CONTROL_ALIGN_ALLCLIENT

// folder: ENTRADA ##########################################################################################


// folder: FINANCEIRO ##########################################################################################

nF3_3x	  := aPObjs[2,3] / 3
// TGroup():New( [ nTop ], [ nLeft ], [ nBottom ], [ nRight ], [ cCaption ], [ oWnd ], [ nClrText ], [ nClrPane ], [ lPixel ], [ uParam10 ] )
// oGrpF3Q1  := TGroup():New( nDist, aPObjs[1,2]+nDist, nF3_3x*0.5, aPObjs[1,4]-nDist,;
// 							"Parametros:",oTFoldeP:aDialogs[3],,, .T.,)
//
// //                Titulo,      Campo,      Tipo, Tamanho, Decimal, Pict, Valid, Obrigat,  Nivel, Inic Padr,    F3, When, Visual, Chave,            CBox, Folder, N Alteravel, PictVar, Gatilho
// aAdd(aFldF3Q1, { "Ordenacao",  "_cOrden",   "C",       1,       0, "@!",      ,     .F.,     1,         "", "   ",   "",    .F.,   .F., "T=Tipo;D=Data",      1,         .F.,      "",      "N"} )
// oEnchF3Q1 := MsMGet():New(,, 3,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/, aPObjs[1],/*aAlterEnch*/,/*nModelo*/,;
// 					/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oGrpF3Q1,/*lF3*/,/*lMemoria*/, .F./*lColumn*/,;
// 					nil /*caTela*/,/*lNoFolder*/, .T./*lProperty*/,aFldF3Q1,/*aFolder*/,/*lCreate*/,/*lNoMDIStretch*/,/*cTela*/)
// oEnchF3Q1:oBox:Align := CONTROL_ALIGN_ALLCLIENT
//
// //SButton():New( [ nTop ], [ nLeft ], [ nType ], [ bAction ], [ oWnd ], [ lEnable ], [ cMsg ], [ bWhen ] )
// oSButton := SButton():New( nF3_3x*0.5-20, aPObjs[1,4]-60-nDist, 9, {|| Iif(_cOrden=="T",aSort( oGetF3aQ2:aCols ,,, {|x,y| x[3] < y[3] } ),aSort( oGetF3aQ2:aCols ,,, {|x,y| x[7] < y[7] } )), oGetF3aQ2:Refresh() }, oGrpF3Q1/* oDlg */, .T.,"Ordenação",)


oGrpF3Q2  := TGroup():New( /* nF3_3x*0.5+ */nDist, aPObjs[1,2]+nDist, nF3_3x*1.6, aPObjs[1,4]-nDist,;
							"Titulos Financeiros:",oTFoldeP:aDialogs[3],,, .T.,)
oTFldF3Q2 := TFolder():New( 0, 0, {"Contas a Pagar", "Movimentação Bancária"},, oGrpF3Q2,,,,.T.,,0, 0 )
oTFldF3Q2:Align   := CONTROL_ALIGN_ALLCLIENT

aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Fornecedor"	, "FORNECEDOR"	, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Numero"   	 	, "E2_NUM"	    , "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Prefixo" 		, "E2_PREFIXO"	, "@!"		                   , 003, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Tipo"			, "E2_TIPO"		, "@!"		                   , 003, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Parcela"    	, "E2_PARCELA"	, "@!"		                   , 002, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Dt Emissao"	, "E2_EMISSAO"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Dt Vcto Real"	, "E2_VENCREA"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "R$ Titulo"		, "E2_VALOR"	, PesqPict("SE2", "E2_VALOR")  , TamSX3("E2_VALOR")[1]  , TamSX3("E2_VALOR")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "R$ Saldo"		, "E2_SALDO"	, PesqPict("SE2", "E2_SALDO")  , TamSX3("E2_SALDO")[1]  , TamSX3("E2_SALDO")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Histórico"    	, "E2_HIST"		, "@!"		                   , 255, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Natureza"    	, "NATUREZA"	, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF3aQ2", aHeadEsp, @aColsEsp, nUsadEsp) => LoadGrids()

oGetF3aQ2:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,,oTFldF3Q2:aDialogs[1], aHeadEsp, aColsEsp)
oGetF3aQ2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetF3aQ2:oBrowse:bHeaderClick := { |oGetF3aQ2,nCol| OrdenaF3aQ2(nCol) }

// oGetF3aQ2:oBrowse:lUseDefaultColors := .F.
// oGetF3aQ2:oBrowse:SetBlkBackColor({|| GETDCLR( oGetF3aQ2 )})

// ABA 2 - Quadro 2

aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Filial"		, "E5_FILIAL"	, "@!"		                   , 002, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Tipo"   	 	, "E5_TIPO"	    , "@!"		                   , 002, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Prefixo"		, "E5_PREFIXO"	, "@!"		                   , 003, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Mot. Baixa" 	, "E5_MOTBX"	, "@!"		                   , 003, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Natureza"    	, "E5_NATUREZ"	, "@!"		                   , 002, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Beneficiado"   , "E5_BENEF"	, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Histórico"   	, "E5_HISTOR"	, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "R$ Titulo"		, "E5_VALOR"	, PesqPict("SE5", "E5_VALOR")  , TamSX3("E5_VALOR")[1]  , TamSX3("E5_VALOR")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Documento"   	, "E5_DOCUMEN"	, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Banco"   		, "BANCO"		, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF3bQ2", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF3bQ2:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,,oTFldF3Q2:aDialogs[2], aHeadEsp, aColsEsp)
oGetF3bQ2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetF3bQ2:oBrowse:bHeaderClick := { |oGetF3bQ2,nCol| OrdenaF3bQ2(nCol) }

oGrpF3Q3  := TGroup():New( nF3_3x*1.6+nDist, aPObjs[1,2]+nDist, aPObjs[2,3]-nDist-(nCut+10), aPObjs[1,4]-nDist,;
							"Resumos Financeiros:",oTFoldeP:aDialogs[3],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Fornecedor"    , "FORNECEDOR"		, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Prefixo"   	, "E2_PREFIXO"		, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Tipo"   		, "E2_TIPO"			, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "R$ Valor"		, "E2_VALOR"		, PesqPict("SE2", "E2_VALOR")  , TamSX3("E2_VALOR")[1]  , TamSX3("E2_VALOR")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "R$ Saldo"		, "SALDO"			, PesqPict("SE2", "E2_SALDO")  , TamSX3("E2_SALDO")[1]  , TamSX3("E2_SALDO")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Natureza"   	, "NATUREZA"		, "@!"		                   , 050, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF3Q3", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF3Q3:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,,oGrpF3Q3, aHeadEsp, aColsEsp)
oGetF3Q3:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetF3Q3:oBrowse:bHeaderClick := { |oGetF3Q3,nCol| OrdenaF3Q3(nCol) }

// folder: FINANCEIRO ##########################################################################################


// folder: ESTOQUE ##########################################################################################
nF4_3x	  := (aPObjs[2,3]-65) / 3
nF4C2 	  := aPObjs[1,4] / 2

oGrpF4Q4E := TGroup():New( nDist, aPObjs[1,2]+nDist, nF4_3x, nF4C2-nDist,;
							"Estoque:",oTFoldeP:aDialogs[4],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Cod. Prod.", "B8_PRODUTO"	, "@!"		                   , 17                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Descrição" , "B1_DESC"		, "@!"		                   , 15                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Saldo" 	, "B8_SALDO"	, PesqPict("SB8", "B8_SALDO")  , TamSX3("B8_SALDO")[1]  , TamSX3("B8_SALDO")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Lote" 		, "B8_LOTECTL"	, "@!"		                   , TamSX3("B8_LOTECTL")[1], TamSX3("B8_LOTECTL")[2], "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Curral" 	, "B8_X_CURRA"	, "@!"		                   , TamSX3("B8_X_CURRA")[1], TamSX3("B8_X_CURRA")[2], "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Dt Confina", "B8_XDATACO"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Peso Conf" , "B8_XPESOCO"	, PesqPict("SB8", "B8_XPESOCO"), TamSX3("B8_XPESOCO")[1], TamSX3("B8_XPESOCO")[2], "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF4Q4E", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF4Q4E:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,, oGrpF4Q4E, aHeadEsp, aColsEsp)
oGetF4Q4E:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGrpF4Q5D := TGroup():New( nDist, nF4C2+nDist, nF4_3x, aPObjs[1,4]-nDist,;
							"Faturamento:",oTFoldeP:aDialogs[4],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Cod. Prod.", "D2_COD"	    , "@!"		                   , 17                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Descrição" , "B1_DESC"		, "@!"		                   , 15                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Quant" 	, "D2_QUANT"	, PesqPict("SD2", "D2_QUANT")  , TamSX3("D2_QUANT")[1]  , TamSX3("D2_QUANT")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Lote" 		, "D2_LOTECTL"	, "@!"		                   , TamSX3("D2_LOTECTL")[1], TamSX3("D2_LOTECTL")[2], "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Dt Emissao", "D2_EMISSAO"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF4Q5D", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF4Q5D:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,, oGrpF4Q5D, aHeadEsp, aColsEsp)
oGetF4Q5D:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGrpF4Q2E := TGroup():New( nF4_3x+nDist, aPObjs[1,2]+nDist, nF4_3x*2+nDist, nF4C2-nDist,;
							"Morte:",oTFoldeP:aDialogs[4],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Cod. Prod.", "D3_COD"		, "@!"		                 , 17                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Descrição" , "B1_DESC"		, "@!"		                 , 15                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Quant."	, "D3_QUANT"	, PesqPict("SD3", "D3_QUANT"), TamSX3("D3_QUANT")[1]  , TamSX3("D3_QUANT")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Dt Emissao", "D3_EMISSAO"	, "@!"		                 , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
// aAdd(aHeadEsp,{ "Observação", "D3_OBSERVA"	, "@!"		                 , TamSX3("D3_OBSERVA")[1], TamSX3("D3_OBSERVA")[2], "AllwaysTrue()", "" , "M", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Observação", "D3_X_OBS"	, "@!"		                 , TamSX3("D3_X_OBS")[1]  , TamSX3("D3_X_OBS")[2]  , "AllwaysTrue()", "" , "M", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Usuario"   , "D3_USUARIO"	, "@!"		                 , TamSX3("D3_USUARIO")[1], TamSX3("D3_USUARIO")[2], "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF4Q2E", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF4Q2E:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,, oGrpF4Q2E, aHeadEsp, aColsEsp)
oGetF4Q2E:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGrpF4Q3D := TGroup():New( nF4_3x+nDist, nF4C2+nDist, nF4_3x*2+nDist, aPObjs[1,4]-nDist,;
							"Nascimento:",oTFoldeP:aDialogs[4],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Cod. Prod.", "D3_COD"		, "@!"		                 , 17                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Descrição" , "B1_DESC"		, "@!"		                 , 15                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Quant."	, "D3_QUANT"	, PesqPict("SD3", "D3_QUANT"), TamSX3("D3_QUANT")[1]  , TamSX3("D3_QUANT")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Dt Emissao", "D3_EMISSAO"	, "@!"		                 , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
// aAdd(aHeadEsp,{ "Observação", "D3_OBSERVA"	, "@!"		                 , TamSX3("D3_OBSERVA")[1], TamSX3("D3_OBSERVA")[2], "AllwaysTrue()", "" , "M", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Observação", "D3_X_OBS"	, "@!"		                 , TamSX3("D3_X_OBS")[1]  , TamSX3("D3_X_OBS")[2]  , "AllwaysTrue()", "" , "M", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Usuario"   , "D3_USUARIO"	, "@!"		                 , TamSX3("D3_USUARIO")[1], TamSX3("D3_USUARIO")[2], "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF4Q3D", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF4Q3D:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,, oGrpF4Q3D, aHeadEsp, aColsEsp)
oGetF4Q3D:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGrpF4Q1  := TGroup():New( nF4_3x*2+nDist, aPObjs[1,2]+nDist, nF4_3x*3+nDist, aPObjs[1,4]-nDist,;
							"Resumo:",oTFoldeP:aDialogs[4],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Nro Lote"	, "NUMERO_LOTE"	, "@!"		                 , 012				  , 					 0, "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Compra"	, "ZBC_COMPRA"	, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Sld Lote"	, "SALDO_B8"	, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Faturado"	, "FATURADO"	, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Morte"		, "MORTE"		, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Nascimento", "NASCIMENTO"	, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Total"		, "TOTAL"		, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Diferença"	, "DIFERE"		, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF4Q1", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF4Q1:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,, oGrpF4Q1, aHeadEsp, aColsEsp)
oGetF4Q1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

// folder: ESTOQUE ##########################################################################################

If nOpc == 3
// 	o1ZBCGDad:Disable()
	oGrpF1Q2:Disable()
EndIf

Aadd( aButtons, { "AUTOM", { || u_BaseConh()  }, "Base de Conhecimento" } )
AAdd( aButtons, { "AUTOM", { || fMenuAux(1)  }, "Antecipacao"  		   	} )
AAdd( aButtons, { "AUTOM", { || fMenuAux(2)  }, "Gerar Titulo" 	   		} )
//AAdd( aButtons, { "AUTOM", { ||  ZBDRepli()   }, "Replicar Datas (F4)" } )
AAdd( aButtons, { "AUTOM", { || U_COMM11JR( &( "o" + cValToChar( oTFoldeG:nOption ) + "ZBCGDad"):oBrowse:nAt) }, "Informar Juros (F6)" } )
AAdd( aButtons, { "AUTOM", { || U_COMM11PE( &( "o" + cValToChar( oTFoldeG:nOption ) + "ZBCGDad"):oBrowse:nAt) }, "Informar Peso (F7)" } )
AAdd( aButtons, { "AUTOM", { || M7SlvCrt( )  }, "Salvar Contrato (F8)" 	} )
// AAdd( aButtons, { "AUTOM", { ||  M7GerarPrd() }, "Gerar Produto"    	} )
AAdd( aButtons, { "AUTOM", { || xAltSC7()   } , "Alterar Pedido (F9)"   } )
AAdd( aButtons, { "AUTOM", { || xAutoSC7()   }, "Gerar Pedido (F10)"   	} )
AAdd( aButtons, { "AUTOM", { || fGerarCompl() }, "Gerar ComplementoPedido (F11)"  } )
AAdd( aButtons, { "AUTOM", { || Pergunte("COMM11VA", .T.) }, "Configuração (F12)"  } )

//Set Key VK_F4  To ZBDRepli()
Set Key VK_F5  To F5FldChang(nOpc)
Set Key VK_F6  To U_COMM11JR()
Set Key VK_F7  To U_COMM11PE()
Set Key VK_F8  To M7SlvCrt()
Set Key VK_F9  To xAltSC7()
Set Key VK_F10 To xAutoSC7()
Set Key VK_F11 To fGerarCompl()
Set Key VK_F12 To ConfigPergunte()

MBSaveLog():FULLWrite(, .F., "Fim Montagem Dialog")

ACTIVATE MSDIALOG oDlg ;
          ON INIT EnchoiceBar(oDlg,;
                              { || nOpcA := 1, Iif( VldOk(nOpc) .and. Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)},;
                              { || nOpcA := 0, oDlg:End() },, aButtons )

If nOpc == 3 .or. nOpc == 4 .or. nOpc == 6 .or. nOpc == 7 .or. nOpc == 8
 	If nOpcA == 1
		Begin Transaction

			MBSaveLog():FULLWrite(, .F., "Inicio da Transação: nOpc := "+cValToChar(nOpc)+"")

			DbSelectArea(cAlias)
			DbSetOrder(1) // Z2_FILIAL+Z2_ASSUNTO+Z2_OCORREN+Z2_SOLUCAO+Z2_RESULTA
			
			MBSaveLog():FULLWrite(, .F., "Inicio U_GrvCpo("+cAlias+")")
				RecLock( cAlias, !DbSeek( FWxFilial('ZCC') + M->ZCC_CODIGO + M->ZCC_VERSAO ))
						U_GrvCpo(cAlias)
					ZCC->ZCC_TPCONT := "A"
				(cAlias)->(MsUnlock())
			MBSaveLog():FULLWrite(, .F., "Fim U_GrvCpo("+cAlias+")")

			IF !Empty(M->ZCC_NOMFAZ)
				IF SELECT("SA2") == 0
					DbSelectArea( "SA2" )
				ENDIF

				SA2->( DbSetOrder( 1 ) )
				IF DbSeek( FWxFilial('SA2') + M->ZCC_CODFOR + M->ZCC_LOJFOR )
					RecLock("SA2",.F.)
						SA2->A2_X_ZCCFA := Upper(M->ZCC_NOMFAZ)
					SA2->( MSUNLOCK() )
				ENDIF
			ENDIF
			
			DbSelectArea( "ZBC" )
			ZBC->( DbSetOrder( 3 ) )

			MBSaveLog():FULLWrite(, .F., "Inicio: Percorrendo Grid: o1ZBCGDad")
			/// Tabela 2 - Rodapé
			For nI := 1 to Len(o1ZBCGDad:aCols)
				If !o1ZBCGDad:aCols[ nI, Len(o1ZBCGDad:aCols[nI]) ] ; // .AND. !Empty( oGZBCGDad:aCols[ nI, 3] )
						.AND. !Empty( o1ZBCGDad:aCols[ nI, nPZBCITE ] ) // ;

					ZBC->( DbSetOrder( 3 ) )
					RecLock( "ZBC", lRecLock := !(ZBC->(DbSeek( FWxFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + &( "o" + cPFoBCITE + "ZBCGDad"):aCols[ nI, nPZBCITE ] /* + oGZBCGDad:aCols[nI, nPZBCZIC] + oGZBCGDad:aCols[nI, nPZBCPed] + oGZBCGDad:aCols[nI, nPZBCPIt] + oGZBCGDad:aCols[nI, nPZBCPVs] */ ) )))

						For nF := 1 to len(aFolderG)
							
							if nOpc == 4 /* .and. M->ZCC_STATUS == 'N' */ .and. !Empty(ZBC->ZBC_PEDIDO) .and. ( &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ] != ZBC->ZBC_QUANT .or. ;
																												&( "o" + cPFoBCPrc + "ZBCGDad"):aCols[ nI, nPZBCPrc ] != ZBC->ZBC_VLRPTA .or.;
																												&( "o" + cPFoBC1IC + "ZBCGDad"):aCols[ nI, nPZBC1IC ] != ZBC->ZBC_SB1ZIC )
								Alert("Grid foi alterada. Altere o Pedido de Compra (F9) antes de salvar!", "Atenção!")
								
								_M11Codigo := ""

								if Select("QTMP") > 0
									QTMP->( dbCloseArea() )
								endif
								
								ZBC->( MsUnlock() )
								return nil
							endif
							
							U_GrvCpo( "ZBC", ;
									&( "o" + cValToChar(nF) + "ZBCGDad" ):aCols,;
									&( "o" + cValToChar(nF) + "ZBCGDad" ):aHeader, nI)
						Next nF
					
						If lRecLock
							ZBC->ZBC_FILIAL := FWxFilial("ZBC")
							ZBC->ZBC_CODIGO := M->ZCC_CODIGO
							ZBC->ZBC_VERSAO := M->ZCC_VERSAO
							ZBC->ZBC_CODFOR := M->ZCC_CODFOR
							ZBC->ZBC_LOJFOR := M->ZCC_LOJFOR
							ZBC->ZBC_USUARI := cUserName
							ZBC->ZBC_DTALT  := MsDate()
						EndIf
					ZBC->( MsUnlock() )
				Else // Se o registro foi excluido e existe no banco apaga
					DbSelectArea( "ZBC" )
					ZBC->( DbSetOrder( 3 ) )
					If ZBC->( DbSeek( FWxFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + oGZBCGDad:aCols[nI, nPZBCITE] ) )
						RecLock( "ZBC", .F.)
							ZBC->( dbDelete() )
						ZBC->( MsUnLock() )
					EndIf
				EndIf
			Next nI

			MBSaveLog():FULLWrite(, .F., "Fim: Percorrendo Grid: o1ZBCGDad")

			MBSaveLog():FULLWrite(, .F., "Inicio: Percorrendo Grid: ZBD")
			DbSelectArea( "ZBD" )
			ZBD->( DbSetOrder(1) )
			For nX := 1 to Len(aZBD)
				if !aZBD[nX][2][1][4]
					For nZ := 1 to Len(aZBD[nX][2])
						RecLock("ZBD", lRecLock := !(ZBD->(DbSeek( FWxFilial("ZBD") + M->ZCC_CODIGO + M->ZCC_VERSAO + aZBD[nX][3] + aZBD[nX][2][nZ][1] ) )))
							ZBD->ZBD_FILIAL	:= FWxFilial("ZBD")
							//ZBD->ZBD_RECZBC	:= o1ZBCGDad:aCols[nI,Len(o1ZBCGDad:aHeader)]
							ZBD->ZBD_ITEM	:= aZBD[nX][2][nZ][1]
							ZBD->ZBD_DATA	:= aZBD[nX][2][nZ][2]
							ZBD->ZBD_FOR	:= M->ZCC_CODFOR
							ZBD->ZBD_LOJA	:= M->ZCC_LOJFOR
							ZBD->ZBD_CODZCC	:= M->ZCC_CODIGO
							ZBD->ZBD_ZCCVER	:= M->ZCC_VERSAO
							ZBD->ZBD_CODPED	:= aZBD[nX][1]
						ZBD->(MsUnlock())
						aZBD[nX][3] := aZBD[nX][1]
					next nZ
				endif 
			next nX
			
			MBSaveLog():FULLWrite(, .F., "Fim: Percorrendo Grid: ZBD")
			
			// If lAtuX8
				While __lSX8
					ConfirmSX8()
				EndDo
			/* Else
				While __lSX8
					RollBackSX8()
				EndDo
			EndIf
			*/
			If nOpc == 6 // Compia
				// Fechar STATUS de contratros em versao anterior
				FechaContrato(ZCC->ZCC_CODIGO, ZCC->ZCC_VERSAO, nOpc )
			EndIf

			MBSaveLog():FULLWrite(, .F., "Fim da Transação")
		End Transaction

	Else
		While __lSX8
			MBSaveLog():FULLWrite(, .F., "RollBackSX8")
			RollBackSX8()
		EndDo
	EndIf

ElseIf nOpc == 5

	MBSaveLog():FULLWrite(, .F., "Inicio Exclusão da linha")

	DbSelectArea(cAlias)
	DbSetOrder(1) // Z2_FILIAL+Z2_ASSUNTO+Z2_OCORREN+Z2_SOLUCAO+Z2_RESULTA
	If DbSeek( FWxFilial('ZCC') + M->ZCC_CODIGO + M->ZCC_VERSAO )
		RecLock( cAlias, .F.)
			ZCC->( DbDelete() )
		(cAlias)->(MsUnlock())
	EndIf

	For nI := 1 to Len(o1ZBCGDad:aCols)
		DbSelectArea( "ZBC" )
		ZBC->( DbSetOrder( 3 ) )
		// If DbSeek( FWxFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + oGZBCGDad:aCols[nI, nPZBCITE] + oGZBCGDad:aCols[nI, nPZBCZIC] + oGZBCGDad:aCols[nI, nPZBCPed] + oGZBCGDad:aCols[nI, nPZBCPIt] + oGZBCGDad:aCols[nI, nPZBCPVs] )
		If ZBD->(DbSeek( FWxFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + o1ZBCGDad:aCols[nI, nPZBCITE] + "XX" /* oGZBCGDad:aCols[nI, nPZBCZIC] */ + o1ZBCGDad:aCols[nI, nPZBCPed] + o1ZBCGDad:aCols[nI, nPZBCPIt] /* + o1ZBCGDad:aCols[nI, nPZBCPVs] */ ))
			RecLock( "ZBC", .F.)
				ZBC->( DbDelete() )
			MsUnlock()
		EndIf
	Next i

	DbSelectArea( "ZBD" )
	ZBD->( DbSetOrder(1) )
	For nX := 1 to Len(aZBD)
		For nZ := 1 to Len(aZBD[nX][2])
			RecLock("ZBD", lRecLock := !(ZBD->(DbSeek( FWxFilial("ZBD") + M->ZCC_CODIGO + M->ZCC_VERSAO + aZBD[nX][3] + aZBD[nX][2][nZ][1] ) )))
				ZBD->( DbDelete() )
			ZBD->(MsUnlock())
		next nZ
	next nX

	MBSaveLog():FULLWrite(, .F., "Fim Exclusão da linha")
EndIf

_M11Codigo := ""

if Select("QTMP") > 0
	QTMP->( dbCloseArea() )
endif

MBSaveLog():FULLWrite(, .F., "Fim: U_COMM11VA( '"+cAlias+"',"+cValToChar(nReg)+","+cValToChar(nOPc)+" )")

Return nil


/* MJ : 25.01.2019
	-> chamar atualizacao das grids, pelo atalho F5;
*/
Static Function F5FldChang(nOpc)
	MBSaveLog():FULLWrite(, .F., "Inicio: F5FldChang("+cValToChar(nOpc)+")")

		FWMsgRun(, {|| FldChang(nOpc, .F.) }, 'Realizando consulta ao banco de dados','Atualizando tabelas, Por Favor Aguarde...')
	
	MBSaveLog():FULLWrite(, .F., "Fim: F5FldChang("+cValToChar(nOpc)+")")
Return nil

/* MJ : 18.01.2019
	-> Ao Trocar a ABA, carregar Grids.
*/
Static Function FldChang(nOpc, lVld)

Default lVld := .T.
Default nOpc := 3

	// Alert( 'nOpc: ' + cValToChar(nOpc) + ', tamanho: ' + cValToChar(Len( oGetF2Q2:aCols)) )

	MBSaveLog():FULLWrite(, .F., "Inicio: FldChang("+cValToChar(nOpc)+", "+iif(lVld,".T.",".F.")+")")

	// If nOpc <> 3
	If Len( oGetF2Q2:aCols ) > 0

		If lVld
			lVld := Empty( oGetF2Q2:aCols[ 1, 1] )
		Else
			nFldPant := 0
			lVld 	 := .T.
			If oTFoldeP:nOption == 2
				oGetF2Q2:aCols[ 1, 1] := ""
			ElseIf oTFoldeP:nOption == 3
				If Len(oGetF3aQ2:aCols)>0
					oGetF3aQ2:aCols[ 1, 1] := ""
				EndIf
				If Len(oGetF3bQ2:aCols)>0
					oGetF3bQ2:aCols[ 1, 1] := ""
				EndIf
				If Len(oGetF3Q3:aCols)>0
					oGetF3Q3:aCols[ 1, 1] := ""
				EndIf
			ElseIf oTFoldeP:nOption == 4
				if Len(oGetF4Q4E:aCols)>0
					oGetF4Q4E:aCols[ 1, 1] := ""
				EndIf
				if Len(oGetF4Q5D:aCols)>0
					oGetF4Q5D:aCols[ 1, 1] := ""
				EndIf
				If Len(oGetF4Q2E:aCols)>0
					oGetF4Q2E:aCols[ 1, 1] := ""
				EndIf
				If Len(oGetF4Q3D:aCols)>0
					oGetF4Q3D:aCols[ 1, 1] := ""
				EndIf
				If Len(oGetF4Q1:aCols)>0
					oGetF4Q1:aCols [ 1, 1] := ""
				EndIf
			EndIf
		EndIf

		If nFldPant <> oTFoldeP:nOption
			If oTFoldeP:nOption == 2 .and. lVld
				LoadGrids('fld2') 	// LoadF2Q2('F2Q2')
				// Alert('carregou abas 2')

			ElseIf oTFoldeP:nOption == 3
				LoadGrids('fld3')

			ElseIf oTFoldeP:nOption == 4
				LoadGrids('fld4')

			EndIf
		EndIf

	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: FldChang("+cValToChar(nOpc)+", "+iif(lVld,".T.",".F.")+")")

	nFldPant := oTFoldeP:nOption
	// Alert('nFolder: ' + cValToChar(oTFoldeP:nOption))
Return .T.

/* MJ : 18.01.2019
	-> Ordena Notas de Entrada - Aba 2;*/
Static Function LoadGrids(cTipo) // LoadF2Q2()
Local nI        := 0

	MBSaveLog():FULLWrite(, .F., "Inicio: LoadGrids("+cTipo+")")

	If cTipo == 'fld2'
		If Len(oGetF2Q2:aCols)>0 .and. Empty( oGetF2Q2:aCols[ 1, 1] )

			LoadNewGDados( "NFEntrada", oGetF2Q2:aHeader, @oGetF2Q2:aCols, Len(oGetF2Q2:aHeader) )
			oGetF2Q2:Refresh()
			/*
			aColsEsp := {}
			_nMedXKM := 0
			while !QTMP->(Eof())
				aAdd(aColsEsp, array(nUsadEsp+1))
				for nX := 1 to nUsadEsp
					if aHeadEsp[nX,8]=='D'
						aColsEsp[Len(aColsEsp),nX]:=STOD( QTMP->( FieldGet(FieldPos(aHeadEsp[nX,2])) ) )
					else
						aColsEsp[Len(aColsEsp),nX]:=QTMP->( FieldGet(FieldPos(aHeadEsp[nX,2])) )
					endIf
				next
				do case
					case AllTrim( QTMP->( FieldGet(FieldPos( aHeadEsp[ 1, 2] )) ) ) == "1-NF ENTRADA"
						_nQtdNF += 1
						_nTotNF += QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )

						_nMedXKM += QTMP->( FieldGet(FieldPos( "D1_X_KM" )) )

					case AllTrim( QTMP->( FieldGet(FieldPos( aHeadEsp[ 1, 2] )) ) ) == "2-NF COMPLEMENTO"
						_nQtdCpl += 1
						_nTotCpl += QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )
					case AllTrim( QTMP->( FieldGet(FieldPos( aHeadEsp[ 1, 2] )) ) ) == "3-NF FRETE"
						_nQtdFre += 1
						_nTotFre += QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )
				endCase
				_nVlrTotNF += QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )
				aColsEsp[len(aColsEsp), nUsadEsp+1] := .F.

				QTMP->(dbSkip())
			EndDo */
			For nI := 1 to Len( oGetF2Q2:aCols )

				do case
					case AllTrim(oGetF2Q2:aCols[ nI, 01]) == "1-NF ENTRADA"
						_nQtdNF += 1
						_nTotNF += oGetF2Q2:aCols[ nI, aScan( oGetF2Q2:aHeader, { |x| x[2] == "D1_TOTAL"} )]  // QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )

						if ValType(oGetF2Q2:aCols[ nI, aScan( oGetF2Q2:aHeader, { |x| x[2] == "D1_X_KM"} )])=="C"
							_nMedXKM += Val(oGetF2Q2:aCols[ nI, aScan( oGetF2Q2:aHeader, { |x| x[2] == "D1_X_KM"} )]) // QTMP->( FieldGet(FieldPos( "D1_X_KM" )) )
						Else
							_nMedXKM += oGetF2Q2:aCols[ nI, aScan( oGetF2Q2:aHeader, { |x| x[2] == "D1_X_KM"} )] // QTMP->( FieldGet(FieldPos( "D1_X_KM" )) )
						EndIf
					case AllTrim(oGetF2Q2:aCols[ nI, 1]) == "2-NF COMPLEMENTO"
						_nQtdCpl += 1
						_nTotCpl += oGetF2Q2:aCols[ nI, aScan( oGetF2Q2:aHeader, { |x| x[2] == "D1_TOTAL"} )]  // QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )

					case AllTrim(oGetF2Q2:aCols[ nI, 1]) == "3-NF FRETE"
						_nQtdFre += 1
						_nTotFre += oGetF2Q2:aCols[ nI, aScan( oGetF2Q2:aHeader, { |x| x[2] == "D1_TOTAL"} )]  // QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )
				endCase

				_nVlrTotNF += oGetF2Q2:aCols[ nI, aScan( oGetF2Q2:aHeader, { |x| x[2] == "D1_TOTAL"} )]  // QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )
				If nI <= Len(&( "o" + cPFoBCVCM + "ZBCGDad"):aCols) .and. !Empty(&( "o" + cPFoBCVCM + "ZBCGDad"):aCols[ nI, nPZBCVCM ])
					_nTotCom   += &( "o" + cPFoBCVCM + "ZBCGDad"):aCols[ nI, nPZBCVCM ] // total comissao
				EndIf
				If nI <= Len(&( "o" + cPFoBCVCM + "ZBCGDad"):aCols) .and. !Empty(&( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ])
					_nQtdCon   += &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ] // qtde total contrato
				EndIf
				_nQtdReb   += oGetF2Q2:aCols[ nI, 09] // D1_QUANT
			Next nI
			_nQtdTotNF := Len(oGetF2Q2:aCols)
			_nMedXKM   := _nMedXKM / _nQtdNF
			_nCstXKM   := _nTotFre / _nMedXKM / _nQtdFre
			oEnchF2Q3:EnchRefreshAll()
		EndIf

	ElseIf cTipo == 'fld3'

		If Len(oGetF3aQ2:aCols)>0 .and. Empty( oGetF3aQ2:aCols[ 1, 1] )
			LoadNewGDados("oGetF3aQ2", oGetF3aQ2:aHeader, @oGetF3aQ2:aCols, Len(oGetF3aQ2:aHeader) )
			oGetF3aQ2:Refresh()
		EndIf

		If Len(oGetF3bQ2:aCols)>0 .and. Empty( oGetF3bQ2:aCols[ 1, 1] )
			LoadNewGDados("oGetF3bQ2", oGetF3bQ2:aHeader, @oGetF3bQ2:aCols, Len(oGetF3bQ2:aHeader) )
			oGetF3bQ2:Refresh()
		EndIf

		If Len(oGetF3Q3:aCols)>0 .and. Empty( oGetF3Q3:aCols[ 1, 1] )
			LoadNewGDados("oGetF3Q3", oGetF3Q3:aHeader, @oGetF3Q3:aCols, Len(oGetF3Q3:aHeader) )
			oGetF3Q3:Refresh()
		EndIf

	ElseIf cTipo == 'fld4'

		If Len(oGetF4Q4E:aCols)>0 .and. Empty( oGetF4Q4E:aCols[ 1, 1] )
			LoadNewGDados("oGetF4Q4E", oGetF4Q4E:aHeader, @oGetF4Q4E:aCols, Len(oGetF4Q4E:aHeader) )
			oGetF4Q4E:Refresh()
		EndIf

		If Len(oGetF4Q5D:aCols)>0 .and. Empty( oGetF4Q5D:aCols[ 1, 1] )
			LoadNewGDados("oGetF4Q5D", oGetF4Q5D:aHeader, @oGetF4Q5D:aCols, Len(oGetF4Q5D:aHeader) )
			oGetF4Q5D:Refresh()
		EndIf

		If Len(oGetF4Q2E:aCols)>0 .and. Empty( oGetF4Q2E:aCols[ 1, 1] )
			LoadNewGDados("oGetF4Q2E", oGetF4Q2E:aHeader, @oGetF4Q2E:aCols, Len(oGetF4Q2E:aHeader) )
			oGetF4Q2E:Refresh()
		EndIf

		If Len(oGetF4Q3D:aCols)>0 .and. Empty( oGetF4Q3D:aCols[ 1, 1] )
			LoadNewGDados("oGetF4Q3D", oGetF4Q3D:aHeader, @oGetF4Q3D:aCols, Len(oGetF4Q3D:aHeader) )
			oGetF4Q3D:Refresh()
		EndIf

		If Len(oGetF4Q1:aCols)>0 .and. Empty( oGetF4Q1:aCols[ 1, 1] )
			LoadNewGDados("oGetF4Q1", oGetF4Q1:aHeader, @oGetF4Q1:aCols, Len(oGetF4Q1:aHeader) )
			oGetF4Q1:Refresh()
		EndIf

	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: LoadGrids("+cTipo+")")

	// Iif(_cOrden=="T", aSort( oGetF2Q2:aCols ,,, {|x,y| x[1] < y[1] } ), aSort( oGetF2Q2:aCols ,,, {|x,y| x[4] < y[4] } ))
	// aSort( oGetF2Q2:aCols ,,, {|x,y| x[1] < y[1] } )
	// oGetF2Q2:Refresh()
	// Alert('Load Aba 2')
Return


Static Function OrdenaF2Q2( nCol )
// Local aCoBrw1    := {}
// Local xVar 		 := ClassMethArr( oGetF2Q2, .T. ) // Mágica
// Local xVar2 	 := ClassDataArr( oGetF2Q2, .T. ) // Magica

// Alert('nF2Q2Cont: ' + cValToChar(+nF2Q2Cont))
MBSaveLog():FULLWrite(, .F., "Inicio: OrdenaF2Q2( "+cValToChar(nCol)+" )")

	If Len( oGetF2Q2:aCols ) > 1
		// .and. nF2Q2Cont%2==0
		// .and. !lF2Q2Ord

		// Alert('nF2Q2Ant: ' + cValToChar(nF2Q2Ant) + ' - nCol: ' + cValToChar(nCol) )
		//
		// If nF2Q2Ant == nCol // .and. ( oGetF2Q2:aCols[1,nCol] < oGetF2Q2:aCols[ Len(oGetF2Q2:aCols),nCol] )
		// 	lF2Q2Cresc := !lF2Q2Cresc
		// Else
		// 	lF2Q2Cresc := .T.
		// EndIf

		// If lF2Q2Cresc
			// aCoBrw1 :=
			aSort( oGetF2Q2:aCols,,,{|x,y| x[nCol] < y[nCol]})
			// Alert('Crescente')
		// Else
		// 	// aCoBrw1 :=
		// 	aSort( oGetF2Q2:aCols,,,{|x,y| x[nCol] > y[nCol]})
		// 	Alert('De-Crescente')
		// EndIf

		// oGetF2Q2:setArray(aCoBrw1)
		// oGetF2Q2:aCols := aCoBrw1
		// nF2Q2Ant := nCol
		// lF2Q2Ord := .T.
		// oGetF2Q2:oBrowse:Refresh()
		oGetF2Q2:Refresh()
	EndIf
MBSaveLog():FULLWrite(, .F., "Fim: OrdenaF2Q2( "+cValToChar(nCol)+" )")

Return Nil

/* MJ : 22.01.2019 */
Static Function OrdenaF3aQ2( nCol )
	MBSaveLog():FULLWrite(, .F., "Inicio: OrdenaF3aQ2( "+cValToChar(nCol)+" )")

	If Len( oGetF3aQ2:aCols ) > 1
		aSort( oGetF3aQ2:aCols,,,{|x,y| x[nCol] < y[nCol]})
		oGetF3aQ2:Refresh()
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: OrdenaF3aQ2( "+cValToChar(nCol)+" )")
Return Nil

/* MJ : 22.01.2019 */
Static Function OrdenaF3bQ2( nCol )
	MBSaveLog():FULLWrite(, .F., "Inicio: OrdenaF3bQ2( "+cValToChar(nCol)+" )")

	If Len( oGetF3bQ2:aCols ) > 1
		aSort( oGetF3bQ2:aCols,,,{|x,y| x[nCol] < y[nCol]})
		oGetF3bQ2:Refresh()
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: OrdenaF3bQ2( "+cValToChar(nCol)+" )")
Return Nil

/* MJ : 22.01.2019 */
Static Function OrdenaF3Q3( nCol )
	MBSaveLog():FULLWrite(, .F., "Inicio: OrdenaF3Q3( "+cValToChar(nCol)+" )")

	If Len( oGetF3Q3:aCols ) > 1
		aSort( oGetF3Q3:aCols,,,{|x,y| x[nCol] < y[nCol]})
		oGetF3Q3:Refresh()
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: OrdenaF3Q3( "+cValToChar(nCol)+" )")

Return Nil



/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     27.12.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:                                                                            |
 |                                                                                  |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
// Static Function ZBCLinOK()
// Local lRet := .T.
// Alert("Linha OK")
// Return lRet

/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     19.12.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Função utilizada para atualizar os campos comuns em todas as abas;     |
 |                                                                                  |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
Static Function RepeatFolder( cCampo, _cInfo, nFolder, nAt  )
	Local nI		:= 0
	// Local nPosOrig  := 0
	Local nPosDest  := 0

	MBSaveLog():FULLWrite(, .F., "Inicio: RepeatFolder( '"+cCampo+"', _cInfo, "+cValToChar(nFolder)+", "+cValToChar(nAt)+"  )")

	For nI := 1 to Len(aFolderG)
		if nI <> nFolder
			// nPosOrig := aScan( &( "o" + cValToChar( nFolder ) + "ZBCGDad"):aHeader, { |x| AllTrim(x[2]) == AllTrim(SX3->X3_CAMPO) } )
			nPosDest := aScan( &( "o" + cValToChar( nI ) + "ZBCGDad"):aHeader, { |x| AllTrim(x[2]) == AllTrim( cCampo ) } )
			If nPosDest > 0
				If Len( &( "o" + cValToChar( nFolder ) + "ZBCGDad"):aCols ) > Len( &( "o" + cValToChar( nI ) + "ZBCGDad"):aCols )
					&( "o" + cValToChar( nI ) + "ZBCGDad"):AddLine(.T., .T.)
					&( "o" + cValToChar( nI ) + "ZBCGDad"):ForceRefresh()
				EndIf
				&( "o" + cValToChar( nI ) + "ZBCGDad"):aCols[ nAt, nPosDest ] := _cInfo // &( "o" + cValToChar( nFolder ) + "ZBCGDad"):aCols[ nAt, nPosOrig]
				&( "o" + cValToChar( nI ) + "ZBCGDad"):Refresh()
			EndIf
		EndIf
	Next nI

	MBSaveLog():FULLWrite(, .F., "Fim: RepeatFolder( '"+cCampo+"', _cInfo, "+cValToChar(nFolder)+", "+cValToChar(nAt)+"  )")

Return nil


/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     18.12.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Função utilizada para atualizar os campos comuns em todas as abas;     |
 |                                                                                  |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
Static Function ReLoadFolder( nFolder )
// Alert( "Folder: " + cValToChar(nFolder) )

/* por hora nao estou mais usando a funcao ao dar reload na aba,
mas na alteracao individual de cada campo */
	Local nPosCpo := 0
	Local nI	  := 1
	Local nL      := 0

	MBSaveLog():FULLWrite(, .F., "Inicio: ReLoadFolder(  "+cValToChar(nFolder)+"  )")

	If nFolder > 0
		dbSelectArea("SX3")
		SX3->( dbSetOrder( 4 ) )

		// While nI <= Len( &( "o" + cValToChar(nFolder) + "ZBCGDad"):aHeader )
		While nI <= Len( &( "o" + cValToChar(nFolder) + "ZBCGDad"):aHeader )

			If SX3->(DbSeek( "ZBC" + cValToChar( nFolder ) + &( "o" + cValToChar(nFolder) + "ZBCGDad"):aHeader[ 1, 2 ] ))

				If X3Uso(SX3->X3_USADO) .and. Empty(X3_FOLDER) // VAZIO então TODAS as grid

					// nPosCpo := aScan( &( "o" + cValToChar(nFolder) + "ZBCGDad"):aHeader, { |x| AllTrim(x[2]) == SX3->X3_CAMPO } )
					nPosCpo := aScan( &( "o" + cValToChar( 1 ) + "ZBCGDad"):aHeader, { |x| AllTrim(x[2]) == SX3->X3_CAMPO } )

					// linha do aCols
					For nL := 1 to Len(&( "o" + cValToChar( 1 ) + "ZBCGDad"):aCols)
						&( "o" + cValToChar(nFolder) + "ZBCGDad"):aCols[ nL, nI ] := ;
							&( "o" + cValToChar( 1 ) + "ZBCGDad"):aCols[ nL, nPosCpo]
					Next nL

					/*
					// Abas
					For nF := 1 to Len(aFolderG)

						// linha do aCols
						For nL := 1 to Len()

							nPosCpo := aScan( &( "o" + cValToChar(nF) + "ZBCGDad"):aHeader, { |x| AllTrim(x[2]) == SX3->X3_CAMPO } )

							&( "o" + cValToChar(nF) + "ZBCGDad"):aCols[ nL, nPosCpo ]

						Next nL

					Next nF
					*/

				EndIf
			EndIf

			nI++
		EndDo

		nFldOldG := nFolder
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: ReLoadFolder(  "+cValToChar(nFolder)+"  )")

Return nil


/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     11.12.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Função utilizada para separar a NewGetDados de acordo com o campo SX3  |
 |         X3_FOLDER; Se o FOLDER tiver ' ' entao o campo sera aplicado em todas as |
 |         abas;                                                                    |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
User Function TiraDoGrp( _aHeader, _aCols, _cCond, _aCampos )
Local nI         := 1
Local nD         := 1

	MBSaveLog():FULLWrite(, .F., "Inicio: TiraDoGrp()")

	Default _aCampos := {}

	dbSelectArea("SX3")
	SX3->( dbSetOrder(2) )
	While nI <= Len(_aHeader)
		If SX3->(DbSeek( _aHeader[ nI, 2] ))
			If X3Uso(SX3->X3_USADO)
				If &(_cCond) .OR. aScan( _aCampos , { |x| x == AllTrim(_aHeader[ nI, 2]) } ) > 0

					aDel ( _aHeader, nI)
					aSize( _aHeader, Len(_aHeader)-1)

					For nD := 1 to Len(_aCols)
						aDel ( _aCols[nD], nI )
						aSize( _aCols[nD], Len(_aCols[nD])-1 )
					Next nD
					nI -= 1
				EndIf
			Endif
		Endif
		nI+=1
	EndDo

	MBSaveLog():FULLWrite(, .F., "Fim: TiraDoGrp()")
Return nil
/* TiraDoGrp -> MJ : 11.12.2018 */


Static Function GETDCLR(oObj) // aLinha,nLinha,aHeader)
	Local nCor		:= CLR_BRANCO
	Local aHeadAux	:= oObj:aHeader
	Local aColsAux  := oObj:aCols
	Local nAt		:= oObj:nAt

	MBSaveLog():FULLWrite(, .F., "Inicio: GETDCLR()")

	do case
		// case AllTrim( QTMP->( FieldGet(FieldPos( aHeadEsp[ 1, 2] )) ) ) == "1-NF ENTRADA"
			// _nTotNF += QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )
		case AllTrim( aColsAux[ nAt, 1] ) == "2-NF COMPLEMENTO"
			nCor := CLR_AZUL
		case AllTrim( aColsAux[ nAt, 1] ) == "3-NF FRETE"
			nCor := CLR_VERDE
	endCase

	MBSaveLog():FULLWrite(, .F., "Fim: GETDCLR()")

Return nCor


/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     27.07.2017                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Funcao: X3_VLDUSER, chamada no campo ZBC_PEDIDO, ZBC_ITEMPC, responsa- |
 |         vel por validar o pedido e preenchiar alguns campos automaticamente;     |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
User Function M7LoadCpo()
	Local aArea   := GetArea()
	Local lRet    := .F.

	Local cCampo  := ""
	Local cPedido := ""
	Local cItemPC := ""

	Local nDist	  := 0

	MBSaveLog():FULLWrite(, .F., "Inicio: M7LoadCpo()")

	If Empty( M->ZCC_CODFOR ) .or. Empty( M->ZCC_LOJFOR )
		Alert('Fornecedor/Loja não informado, portanto, o Pedido de Compras não pode ser validado.')
	ElseIf Empty( M->ZCC_CODCOR )
		Alert('Corretor não informado, portanto, o Pedido de Compras não pode ser validado.')
	Else

		lRet 	:= .T.
		cCampo  := Substr( ReadVar(), At('->', ReadVar())+2 )

		If cCampo == "ZBC_PEDIDO"
			cPedido := &(ReadVar())
			cItemPC := GdFieldGet('ZBC_ITEMPC')

		Else // ZBC_ITEMPC
			cPedido := GdFieldGet('ZBC_PEDIDO')
			cItemPC := &(ReadVar())

		EndIf

		If !Empty(cPedido) .and. !Empty(cItemPC)

			If SC7->C7_NUM+SC7->C7_ITEM <> cPedido + cItemPC
				SC7->(DbSetOrder(1))
				SC7->(DbSeek( FWxFilial('SC7')+ cPedido + cItemPC))
			EndIf

			If (lRet := ExistCpo( "SC7", cPedido + cItemPC ))
				If SC7->C7_FORNECE + SC7->C7_LOJA == M->ZCC_CODFOR + M->ZCC_LOJFOR
					cChave := M->ZCC_CODIGO+M->ZCC_VERSAO+cPedido+cItemPC
					cAux := U_fChvITEM('ZBC','ZBC_CODIGO, ZBC_VERSAO, ZBC_PEDIDO, ZBC_ITEMPC', 'ZBC_VERPED', 'ZBC_CODIGO+ZBC_VERSAO+ZBC_PEDIDO+ZBC_ITEMPC', cChave )
					GdFieldPut( 'ZBC_VERPED' , cAux )

					GdFieldPut( 'ZBC_CONDPA' , SC7->C7_COND    )
					GdFieldPut( 'ZBC_PRODUT' , SC7->C7_PRODUTO )
					GdFieldPut( 'ZBC_PRDDES' , Posicione('SB1',1, FWxFilial('SB1') + SC7->C7_PRODUTO, 'B1_DESC' ) )
					GdFieldPut( 'ZBC_QUANT'  , SC7->C7_QUANT   )
					GdFieldPut( 'ZBC_PESO'   , SC7->C7_X_PESO  )
					GdFieldPut( 'ZBC_REND'   , SC7->C7_X_REND  )
					GdFieldPut( 'ZBC_RENDP'  , SC7->C7_X_RENDP )
					GdFieldPut( 'ZBC_ARROV'  , SC7->C7_X_ARROV )
					GdFieldPut( 'ZBC_ARROQ'  , SC7->C7_X_ARROQ )
					GdFieldPut( 'ZBC_VLICM'  , SC7->C7_X_VLICM )
					GdFieldPut( 'ZBC_VLUSIC' , SC7->C7_X_VLUNI )
					GdFieldPut( 'ZBC_TOTICM' , SC7->C7_X_TOICM )
					GdFieldPut( 'ZBC_X_CORR' , SC7->C7_X_CORRE )
					GdFieldPut( 'ZBC_TTSICM' , SC7->C7_X_TOTAL )
					GdFieldPut( 'ZBC_PRECO'  , SC7->C7_PRECO   )
					GdFieldPut( 'ZBC_TOTAL'  , SC7->C7_TOTAL   )


				Else
					Alert('Pedido selecionado não pertence ao fornecedor informado no contrato.')
					lRet := .F.
				EndIf
			Else
				Alert('Pedido de Compra: ' + cPedido + '-' + cItemPC + ' não localizado.')
			EndIf
		EndIf
	EndIf
	MBSaveLog():FULLWrite(, .F., "Fim: M7LoadCpo()")

	RestArea(aArea)
Return lRet


/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     30.10.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Validar Ultima REVISAO para o CONTRATO                                |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras:                                                                         |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     -                                                                     |
 '---------------------------------------------------------------------------------*/
// Static Function ZBCbChange()
// 	Local nAt 		:= o1ZBCGDad:oBrowse:nAt
//
// 	If Empty( o1ZBCGDad:aCols[ nAt, 1] )
// 		o1ZBCGDad:aCols[ nAt, 1] := "LBNO"
// 		o1ZBCGDad:Refresh()
// 	EndIf
//
// 	_M11Codigo := o1ZBCGDad:aCols[ nAt, nPZBCFaxa ]
//
// 	// Alert('ZBCbChange: ' + AllTrim(Str( nAt )))
// Return .T.


/* MJ : 11.03.2019*/
Static Function ConfigPergunte()
	MBSaveLog():FULLWrite(, .F., "Inicio: ConfigPergunte()")

		Pergunte("COMM11VA", .T.)

	MBSaveLog():FULLWrite(, .F., "Fim: ConfigPergunte()")
Return .T.


/* MJ : 11.03.2019
	-> funcao auxiliar para ajudar no processo de validacao dos campos;
*/
Static Function AUX_ZBCFieldOK(nOpc, cCampo, _cInfo, nAt, /* lVld, */ nFolder )
	Local lRet      := .T.
	Local nI        := 0

	Default nFolder := 1

	MBSaveLog():FULLWrite(, .F., "Inicio: AUX_ZBCFieldOK("+cValToChar(nOpc)+", '"+cCampo+"', _cInfo, "+cValToChar(nAt)+", /* lVld, */ "+cValToChar(nFolder)+")")

	if nOpc == 1
		If nAt <= 0 .or. nAt > Len( &( "o" + cValToChar(nFolder) + "ZBCGDad"):aCols)
			// Erro de posicionamento da Grid. Fechar Validacao para nao dar erro.
			Return .F.
		EndIf

		If Empty( &( "o" + cValToChar(nFolder) + "ZBCGDad"):aCols[nAt, 1] )
			&( "o" + cValToChar(nFolder) + "ZBCGDad"):aCols[nAt, 1] := "LBNO"
		EndIf

		If !ISINCALLSTACK("U_VACOMM12") .AND. AllTrim(cCampo)<>'ZBC_SEXO' .and. Empty( &( "o" + cPFoBCSxo  + "ZBCGDad"):aCols[ nAt, nPZBCSxo ] )
			Alert('Favor preencher o campo: <b>Sexo</b> do pedido/contrato na linha: <b>' + cValToChar(nAt) + '</b>.' )
			// lRet   := .F.
			Return .F.
		EndIf

		If Empty( &( "o" + cValToChar(nFolder) + "ZBCGDad"):aCols[ nAt, nPZBCITE ] ) // ZBC_ITEM
			&( "o" + cValToChar(nFolder) + "ZBCGDad"):aCols[ nAt, nPZBCITE ] := StrZero( nAt, TamSX3('ZBC_ITEM')[1] )
			RepeatFolder( 'ZBC_ITEM', StrZero( nAt, TamSX3('ZBC_ITEM')[1] ), nFolder, nAt )
		EndIf

		If !Empty( cCampo ) .and. Empty( Posicione('SX3', 2, cCampo, 'X3_FOLDER') )
			RepeatFolder( cCampo, _cInfo, nFolder, nAt )
		EndIf

	ElseIf nOpc == 2
		nTotQtde 	:= 0
		nQtdTotal	:= 0

		For nI := 1 to len(o1ZBCGDad:aCols) //nAt
			If !o1ZBCGDad:aCols[ nI, Len( o1ZBCGDad:aCols[ 1 ] ) ]
				nQtdTotal += Iif(nI==nAt /* .and. lVld */, &(ReadVar()), &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ] )
			EndIf
		Next nI

		if nQtdTotal > M->ZCC_QTTTAN
			Alert('Quantidade de animais ultrapassou o configurado no Cabeçalho do Contrato.')
			Return .F.
		EndIf

		M->ZCC_QTDRES := M->ZCC_QTTTAN - nQtdTotal
		oMGet:Refresh()
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: AUX_ZBCFieldOK("+cValToChar(nOpc)+", '"+cCampo+"', _cInfo, "+cValToChar(nAt)+", /* lVld, */ "+cValToChar(nFolder)+")")

Return lRet

/* ####################################################################### */
/* MJ : 06.11.2017

	Alt. 13.11.18
		Param : lVLd : Define se ir realizar a validacao ou nao;
   ####################################################################### */
User Function ZBCFieldOK(cCampo, _cInfo, nAt, /* lVld, */ nFolder )

	Local lRet        := .T.
	Local nI          := 0
	Local nF          := 0
	Local nTotQtde    := 0
	Local cItemZIC    := ""
	Local lTodos      := .F.
	Local nPZIC       := 0
	Local nAux        := 0
	Local lMark       := .T.

	Local _ZBC_QUANT  := 0
	Local _ZBC_PEDPOR := 0
	Local _ZBC_PRECO  := 0
	Local _ZBC_TOTAL  := 0
	Local _ZBC_TPNEG  := 0
	Local _ZBC_PESO   := 0
	Local _ZBC_REND   := 0
	Local _ZBC_TTSICM := 0
	Local _ZBC_TOTICM := 0
	Local _ZBC_ALIICM := 0
	Local _ZBC_VLAROB := 0
	Local _ZBC_OUTDES := 0
	Local _ZBC_VLUSIC := 0
	Local _ZBC_TES    := 0
	Local _ZBC_TPSENA := 0
	Local _ZBC_VLRPTA := 0
	Local _ZBC_PRENEG := 0
	Local _ZBC_TOTNEG := 0

	Default cCampo    := Substr( ReadVar(), At('->', ReadVar())+2 )
	Default _cInfo    := &( ReadVar() )
	Default nFolder   := oTFoldeG:nOption
	Default nAt       := &("o" + cValToChar(nFolder) + "ZBCGDad"):oBrowse:nAt // o1ZBCGDad:oBrowse:nAt
	// Default lVld   := .T.

	MBSaveLog():FULLWrite(, .F., "Inicio: ZBCFieldOK("+cCampo+"")

	If MV_PAR01 == 1 // NAO
		// Alert('Não')
		Return .T.
	EndIf

	if !AUX_ZBCFieldOK(1, cCampo, _cInfo, nAt, /* lVld, */ nFolder )
		// Alert('Gatilhos cancelados. Erro durante execução da funcao: [AUX_ZBCFieldOK-1 ]')
		Return .F.
	EndIf

	/* ------------------------------------ _P_A_R_A_M_E_T_R_O_S_ ------------------------------------ */
	// 1 = PRINCIPAL
	// ## nPZBCQtd > "ZBC_QUANT" < cPFoBCQtd  ## Qtde Pedido
	_ZBC_QUANT  := Iif(ReadVar()=='M->ZBC_QUANT', &(ReadVar()), &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nAt, nPZBCQtd ] )
	// ## nPZBCPdP > ZBC_PEDPOR < cPFoBCPdP ## Pedido Por
	_ZBC_PEDPOR := Iif(ReadVar()=='M->ZBC_PEDPOR', &(ReadVar()), &( "o" + cPFoBCPdP + "ZBCGDad"):aCols[ nAt, nPZBCPdP ] )
	// ## nPZBCVPT > ZBC_VLRPTA < cPFoBCVPT ## R$ Pauta
	_ZBC_VLRPTA := Iif(ReadVar()=='M->ZBC_VLRPTA', &(ReadVar()), &( "o" + cPFoBCVPT + "ZBCGDad"):aCols[ nAt, nPZBCVPT ] )
	// ## nPZBCPrc > ZBC_PRECO < cPFoBCPrc ## R$ Unit Ped 		// _ZBC_PRECO  := &( "o" + cPFoBCPrc + "ZBCGDad"):aCols[ nAt, nPZBCPrc ]
	_ZBC_PRECO  := Iif(ReadVar()=='M->ZBC_PRECO', &(ReadVar()), &( "o" + cPFoBCPrc + "ZBCGDad"):aCols[ nAt, nPZBCPrc ] )
	// ## nPZBCTot > ZBC_TOTAL < cPFoBCTot ## R$ Total Ped
	_ZBC_TOTAL  := Iif(ReadVar()=='M->ZBC_TOTAL', &(ReadVar()), &( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nAt, nPZBCTot ] )
	// ## nPZBCArv > ZBC_ARROV < cPFoBCArv ## R$/Arroba => Valor Neg
	_ZBC_ARROV  := Iif(ReadVar()=='M->ZBC_ARROV', &(ReadVar()), &( "o" + cPFoBCArv + "ZBCGDad"):aCols[ nAt, nPZBCArv ] )

	/*-------------------------------------------------------------------------------------------------*/
	// 2 = PESO
	// ## nPZBCTPN > ZBC_TPNEG < cPFoBCTPN ## Tp Negoc
	_ZBC_TPNEG := Iif(ReadVar()=='M->ZBC_TPNEG', &(ReadVar()), &( "o" + cPFoBCTPN + "ZBCGDad"):aCols[ nAt, nPZBCTPN ] )
	// ## nPZBCPes > ZBC_PESO < cPFoBCPes ## Peso Tot Neg
	_ZBC_PESO := Iif(ReadVar()=="M->ZBC_PESO", &(ReadVar()), &( "o" +cPFoBCPes+ "ZBCGDad"):aCols[ nAt, nPZBCPes] )
	// ## nPZBCRen > ZBC_REND < cPFoBCRen ## Rendimento
	_ZBC_REND := Iif(ReadVar()=='M->ZBC_REND', &(ReadVar()), &( "o" + cPFoBCRen + "ZBCGDad"):aCols[ nAt, nPZBCRen ] )
	// ## nPZBCPeA > ZBC_PESOAN < cPFoBCPeA ## Peso x Animal
	_ZBC_PESOAN := Iif(ReadVar()=='M->ZBC_PESOAN', &(ReadVar()), &( "o" + cPFoBCPeA + "ZBCGDad"):aCols[ nAt, nPZBCPeA ] )

	/*-------------------------------------------------------------------------------------------------*/
	// 3 = ICMS
	// ## nPZBCToI > ZBC_TOTICM < cPFoBCToI ## Total ICMS
	_ZBC_TOTICM := Iif(ReadVar()=='M->ZBC_TOTICM', &(ReadVar()), &( "o" + cPFoBCToI + "ZBCGDad"):aCols[ nAt, nPZBCToI ] )
	// ## nPZBCAIC > ZBC_ALIICM < cPFoBCAIC ## Aliq. ICMS
	_ZBC_ALIICM := Iif(ReadVar()=='M->ZBC_ALIICM', &(ReadVar()), &( "o" + cPFoBCAIC + "ZBCGDad"):aCols[ nAt, nPZBCAIC ] )
	// ## nPZBCROB > ZBC_VLAROB < cPFoBCROB ## Vlr R$ Neg => R$ Neg Final
	_ZBC_VLAROB := Iif(ReadVar()=='M->ZBC_VLAROB', &(ReadVar()), &( "o" + cPFoBCROB + "ZBCGDad"):aCols[ nAt, nPZBCROB ] )

	/*-------------------------------------------------------------------------------------------------*/
	// 4 = Senar
	// ## nPZBCTES > ZBC_TES < cPFoBCTES ## Tipo Ent/Sai
	_ZBC_TES := Iif(ReadVar()=='M->ZBC_TES', &(ReadVar()), &( "o" + cPFoBCTES + "ZBCGDad"):aCols[ nAt, nPZBCTES ] )
	// ## nPZBCTPS > ZBC_TPSENA < cPFoBCTPS ## Tipo Senar
	_ZBC_TPSENA := Iif(ReadVar()=='M->ZBC_TPSENA', &(ReadVar()), &( "o" + cPFoBCTPS + "ZBCGDad"):aCols[ nAt, nPZBCTPS ] )
	// ## nPZBCAQS > ZBC_ALIQSE < cPFoBCAQS ## Aliq. Senar
	_ZBC_ALIQSE := Iif(ReadVar()=='M->ZBC_ALIQSE', &(ReadVar()), &( "o" + cPFoBCAQS + "ZBCGDad"):aCols[ nAt, nPZBCAQS ] )
	// ## nPZBCVLS > ZBC_VLRSEN < cPFoBCVLS ## Valor Senar
	_ZBC_VLRSEN := Iif(ReadVar()=='M->ZBC_VLRSEN', &(ReadVar()), &( "o" + cPFoBCVLS + "ZBCGDad"):aCols[ nAt, nPZBCVLS ] )

	/*-------------------------------------------------------------------------------------------------*/
	// 6 = Comissão
	// ## nPZBCOMU > ZBC_COMUNI < cPFoBCOMU ## Comissão Unitário
	_ZBC_COMUNI := Iif(ReadVar()=='M->ZBC_COMUNI', &(ReadVar()), &( "o" + cPFoBCOMU + "ZBCGDad"):aCols[ nAt, nPZBCOMU ] )
	// ## nPZBCOMT > ZBC_VLRCOM < cPFoBCOMT ## Comissão Total
	_ZBC_VLRCOM := Iif(ReadVar()=='M->ZBC_VLRCOM', &(ReadVar()), &( "o" + cPFoBCOMT + "ZBCGDad"):aCols[ nAt, nPZBCOMT ] )

	// ## nPZBCOFM > ZBC_VLRFIM < cPFoBCOFM ## Acrescenta o valor da comissao no valor final da negociação
	_ZBC_VLRFIM := Iif(ReadVar()=='M->ZBC_VLRFIM', &(ReadVar()), &( "o" + cPFoBCOFM + "ZBCGDad"):aCols[ nAt, nPZBCOFM ] )

	/*-------------------------------------------------------------------------------------------------*/
	// 7 = DESCONTO
	// ## nPZBCXTT > ZBC_TTSICM < cPFoBCXTT ## Tot S/ ICMS
	_ZBC_TTSICM := Iif(ReadVar()=='M->ZBC_TTSICM', &(ReadVar()), &( "o" + cPFoBCXTT + "ZBCGDad"):aCols[ nAt, nPZBCXTT ] )
	// ## nPZBCOTS > ZBC_OUTDES < cPFoBCOTS ## Outros Desc
	_ZBC_OUTDES := Iif(ReadVar()=='M->ZBC_OUTDES', &(ReadVar()), &( "o" + cPFoBCOTS + "ZBCGDad"):aCols[ nAt, nPZBCOTS ] )
	// ## nPZBCOTA > ZBC_OUTACR < cPFoBCOTA ## Outros Acrescimos
	_ZBC_OUTACR := Iif(ReadVar()=='M->ZBC_OUTACR', &(ReadVar()), &( "o" + cPFoBCOTA + "ZBCGDad"):aCols[ nAt, nPZBCOTA ] )

	// ## nPZBCJur > ZBC_JUROS < cPFoBCJur ## Acrescenta Juros
	_ZBC_JUROS := Iif(ReadVar()=='M->ZBC_JUROS', &(ReadVar()), &( "o" + cPFoBCJur + "ZBCGDad"):aCols[ nAt, nPZBCJur ] )

    // ## nPZBCVlU > ZBC_VLUSIC < cPFoBCVlU ## Vl Un Sem IC
	_ZBC_VLUSIC := Iif(ReadVar()=='M->ZBC_VLUSIC', &(ReadVar()), &( "o" + cPFoBCVlU + "ZBCGDad"):aCols[ nAt, nPZBCVlU ] )
	// ## nPZBCPNG > ZBC_PRENEG < cPFoBCPNG ## R$ Unit Neg
	_ZBC_PRENEG := Iif(ReadVar()=='M->ZBC_PRENEG', &(ReadVar()), &( "o" + cPFoBCPNG + "ZBCGDad"):aCols[ nAt, nPZBCPNG ] )
	// ## nPZBCTNG > ZBC_TOTNEG < cPFoBCTNG ## R$ Total Neg
	_ZBC_TOTNEG := Iif(ReadVar()=='M->ZBC_TOTNEG', &(ReadVar()), &( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nAt, nPZBCTNG ] )

	
	MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 1")
	/* ------------------------------------ _P_A_R_A_M_E_T_R_O_S_ ------------------------------------ */
	If nFolder == 1 // entao valores pedido/pauta
		If Empty( _ZBC_PEDPOR )
			Aviso("Aviso", ;
				  "O campo [Pedido Por], localizado na ABA 1, não foi informado." + CRLF +;
				  "Esta Operação sera cancelada.", ;
				  {"Sair"} )
			Return .F.
		EndIf
	Else // demais abas
		If Empty( _ZBC_TPNEG )
			Aviso("Aviso", ;
				  "O campo [Tipo Negociação], localizado na ABA 2, não foi informado." + CRLF +;
				  "Esta Operação sera cancelada.", ;
				  {"Sair"} )
			Return .F.
		EndIf
	EndIf

	// ## ZBC_SB1ZIC  ##
	If cCampo == 'ZBC_SB1ZIC'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 2")
		RepeatFolder( "ZBC_PRDDES", Posicione( "SB1", 1, FWxFilial("SB1")+_cInfo, "B1_DESC"), nFolder, nAt )

		&( "o" + cPFoBCDES + "ZBCGDad"):aCols[ nAt, nPZBCDES ] := SB1->B1_DESC

	/*
		processa	mento baseado em informacao de VALOR DE PAUTA
	*/
	ElseIf cCampo == 'ZBC_QUANT'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 3")
		// ## nPZBCQtd > "ZBC_QUANT" < cPFoBCQtd  ## Qtde Pedido

		if !AUX_ZBCFieldOK(2, cCampo, _cInfo, nAt, /* lVld, */ nFolder )
			// Alert('Gatilhos cancelados. Erro durante execução da funcao: [AUX_ZBCFieldOK-2]')
			Return .F.
		EndIf

		// ## nPZBCQtd > "ZBC_QUANT" < cPFoBCQtd  ## Qtde Pedido
		&( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nAt, nPZBCQtd ] := _cInfo

		U_ZBCFieldOK('ZBC_VLRPTA', &( "o" + cPFoBCVPT + "ZBCGDad"):aCols[ nAt, nPZBCVPT ] )



	ElseIf cCampo == 'ZBC_PRECO'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 4")


	/* ============================================================================================================== */
		// ## nPZBCVPT > ZBC_VLRPTA < cPFoBCVPT ## R$ Pauta
	ElseIf cCampo == 'ZBC_VLRPTA'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 5")
		_ZBC_VLRPTA := _cInfo

		// ## nPZBCICP > ZBC_VICMPA < cPFoBCICP ## R$ ICMS Paut
		&( "o" + cPFoBCICP + "ZBCGDad"):aCols[ nAt, nPZBCICP ] := _cInfo * _ZBC_ALIICM / 100

		// ## nPZBCQtd > "ZBC_QUANT" < cPFoBCQtd  ## Qtde Pedido
		If !Empty( _ZBC_QUANT )

			// ## nPZBCPdP > ZBC_PEDPOR < cPFoBCPdP ## Pedido Por
			If &( "o" + cPFoBCPdP + "ZBCGDad"):aCols[ nAt, nPZBCPdP ] == "P" .OR. ;
				M->ZCC_PAGFUT == "S"

				// ## nPZBCROB > ZBC_VLAROB < cPFoBCROB ## Vlr R$ Neg => R$ Neg Final
				_ZBC_VLAROB := _ZBC_VLRPTA
				&( "o" + cPFoBCROB + "ZBCGDad"):aCols[ nAt, nPZBCROB ] := _ZBC_VLAROB

				If U_CanEdit(.F.)
					// ## nPZBCPrc > ZBC_PRECO < cPFoBCPrc ## R$ Unit Ped
					&( "o" + cPFoBCPrc + "ZBCGDad"):aCols[ nAt, nPZBCPrc ] := _ZBC_VLAROB

					// ## nPZBCTot > ZBC_TOTAL < cPFoBCTot ## R$ Total Ped
					&( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nAt, nPZBCTot ] := _ZBC_QUANT * _ZBC_VLAROB
				EndIf

				// // ## nPZBCPNG > ZBC_PRENEG < cPFoBCPNG ## R$ Unit Neg
				// &( "o" + cPFoBCPNG + "ZBCGDad"):aCols[ nAt, nPZBCPNG ] := _ZBC_VLAROB

				// // ## nPZBCTNG > ZBC_TOTNEG < cPFoBCTNG ## R$ Total Neg
				// &( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nAt, nPZBCTNG ] := _ZBC_QUANT * _ZBC_VLAROB

				// // ## nPZBCXTT > ZBC_TTSICM < cPFoBCXTT ## Tot S/ ICMS
				// &( "o" + cPFoBCXTT + "ZBCGDad"):aCols[ nAt, nPZBCXTT ] := _ZBC_QUANT * _ZBC_VLAROB

				// // ## nPZBCVlU > ZBC_VLUSIC < cPFoBCVlU ## Vl Un Sem IC
				// &( "o" + cPFoBCVlU + "ZBCGDad"):aCols[ nAt, nPZBCVlU ] := _ZBC_VLAROB // _cInfo + &( "o" + cPFoBCICP + "ZBCGDad"):aCols[ nAt, nPZBCICP ]

				// ## nPZBCXTT > ZBC_TTSICM < cPFoBCXTT ## Tot S/ ICMS
				U_ZBCFieldOK('ZBC_TTSICM', _ZBC_TTSICM )

			EndIf
		EndIf

	/* ============================================================================================================== */
	ElseIf cCampo == 'ZBC_ALIICM'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 6")
		// ## nPZBCAIC > ZBC_ALIICM < cPFoBCAIC ## Aliq. ICMS
		&( "o" + cPFoBCAIC + "ZBCGDad"):aCols[ nAt, nPZBCAIC ] := _cInfo

		// ## nPZBCICP > ZBC_VICMPA < cPFoBCICP ## R$ ICMS Paut
		_ZBC_VICMPA := _cInfo * &( "o" + cPFoBCVPT + "ZBCGDad"):aCols[ nAt, nPZBCVPT ] / 100
		&( "o" + cPFoBCICP + "ZBCGDad"):aCols[ nAt, nPZBCICP ] := _ZBC_VICMPA

		// U_ZBCFieldOK('ZBC_VLRPTA', &( "o" + cPFoBCVPT + "ZBCGDad"):aCols[ nAt, nPZBCVPT ] )

	/* ============================================================================================================== */
	ElseIf cCampo == 'ZBC_PESREA' // nPZBCPeR > ZBC_PESREA < cPFoBCPeR ## Peso Real
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 7")

		&( "o" + cPFoBCPes + "ZBCGDad"):aCols[ nAt, nPZBCPes ] := _cInfo
		U_ZBCFieldOK('ZBC_PESO', _cInfo )

	/*
		processamento baseado em informacao de PESO
												*/
	/* ============================================================================================================== */
	ElseIf cCampo == 'ZBC_PESO'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 8")
		// ## nPZBCPes > ZBC_PESO < cPFoBCPes ## Peso Tot Neg
		&( "o" + cPFoBCPes + "ZBCGDad"):aCols[ nAt, nPZBCPes ] := _cInfo

		// ## nPZBCPeA > ZBC_PESOAN < cPFoBCPeA ## Peso x Anima
		_ZBC_PESOAN := _cInfo / &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nAt, nPZBCQtd ]
		&( "o" + cPFoBCPeA + "ZBCGDad"):aCols[ nAt, nPZBCPeA ] := _ZBC_PESOAN

		// ## nPZBCTPN > ZBC_TPNEG < cPFoBCTPN ## Tp Negoc
		If &( "o" + cPFoBCTPN + "ZBCGDad"):aCols[ nAt, nPZBCTPN ] == "K"
			_ZBC_VLAROB := NoRound( ((_cInfo * _ZBC_ARROV) / _ZBC_QUANT ) / ( _cInfo / _ZBC_QUANT) * 30 , TamSX3("ZBC_ARROV")[2])
			// ## nPZBCROB > ZBC_VLAROB < cPFoBCROB ## Vlr R$ Neg => R$ Neg Final
		&( "o" + cPFoBCROB + "ZBCGDad"):aCols[ nAt, nPZBCROB ] := _ZBC_ARROV
		EndIf

									// ## nPZBCRen > ZBC_REND < cPFoBCRen ## Rendimento
		If _cInfo > 0 .and. Empty( &( "o" + cPFoBCRen + "ZBCGDad"):aCols[ nAt, nPZBCRen ] )
		// ## nPZBCRen > ZBC_REND < cPFoBCRen ## Rendimento
			&( "o" + cPFoBCRen + "ZBCGDad"):aCols[ nAt, nPZBCRen ] := 50
		EndIf

		/*
		If M->ZCC_PAGFUT == "N"
			lTodos := _ZBC_QUANT > 0 .OR. _ZBC_TPNEG $ ("KQ")

			If lTodos
				U_ZBCFieldOK('ZBC_ARROV', &( "o" + cPFoBCArv + "ZBCGDad"):aCols[ nAt, nPZBCArv ] )
			EndIf
		EndIf
		*/
		// ## nPZBCXTT > ZBC_TTSICM < cPFoBCXTT ## Tot S/ ICMS
		U_ZBCFieldOK('ZBC_TTSICM', _ZBC_TTSICM )

	/* ============================================================================================================== */
	ElseIf cCampo == 'ZBC_REND'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 9")
		// ## nPZBCRen > ZBC_REND < cPFoBCRen ## Rendimento
		&( "o" + cPFoBCRen + "ZBCGDad"):aCols[ nAt, nPZBCRen ] := _cInfo

		// ## nPZBCXTT > ZBC_TTSICM < cPFoBCXTT ## Tot S/ ICMS
		U_ZBCFieldOK('ZBC_TTSICM', _ZBC_TTSICM )


	/* ============================================================================================================== */
	ElseIf cCampo == 'ZBC_ARROV'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 10")
		// ## nPZBCArv > ZBC_ARROV < cPFoBCArv ## R$/Arroba => Valor Neg
		&( "o" + cPFoBCArv + "ZBCGDad"):aCols[ nAt, nPZBCArv ] := _cInfo
		// ## nPZBCROB > ZBC_VLAROB < cPFoBCROB ## Vlr R$ Neg => R$ Neg Final
		&( "o" + cPFoBCROB + "ZBCGDad"):aCols[ nAt, nPZBCROB ] := _cInfo

		U_ZBCFieldOK('ZBC_TTSICM', _ZBC_TTSICM )

	// ## nPZBCXTT > ZBC_TTSICM < cPFoBCXTT ## Tot S/ ICMS
	/* ============================================================================================================== */
	ElseIf cCampo == 'ZBC_TTSICM'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 11")
		_ZBC_TTSICM := _cInfo

		// ## nPZBCQtd > "ZBC_QUANT" < cPFoBCQtd  ## Qtde Pedido
		_ZBC_QUANT := Iif(ReadVar()=='M->ZBC_QUANT', &(ReadVar()), &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nAt, nPZBCQtd ])

		// 01.04 // a variavel ZBC_TOTAL precisa ser utilizada aqui e embaixo tbm;
		// // ## nPZBCTot > ZBC_TOTAL < cPFoBCTot ## R$ Total Ped
		// _ZBC_TOTAL := NoRound( _ZBC_TTSICM + _ZBC_TOTICM - _ZBC_OUTDES + Iif(_ZBC_TPSENA=="V",_ZBC_VLRSEN,0), TamSX3("ZBC_TOTAL")[2])

		If _ZBC_TPNEG == "P"

			// ## nPZBCXTT > ZBC_TTSICM < cPFoBCXTT ## Tot S/ ICMS
			_ZBC_TTSICM := ((_ZBC_PESOAN*(_ZBC_REND/100))*_ZBC_ARROV/15) * _ZBC_QUANT
			&( "o" + cPFoBCXTT + "ZBCGDad"):aCols[ nAt, nPZBCXTT ] := _ZBC_TTSICM

		ElseIf _ZBC_TPNEG == "K" // kilo

			// ## nPZBCXTT > ZBC_TTSICM < cPFoBCXTT ## Tot S/ ICMS
			_ZBC_TTSICM := _ZBC_PESO * _ZBC_ARROV //  (_ZBC_PESOAN*_ZBC_ARROV) * _ZBC_QUANT
			&( "o" + cPFoBCXTT + "ZBCGDad"):aCols[ nAt, nPZBCXTT ] := _ZBC_TTSICM

		Else// If _ZBC_TPNEG == "Q" // Quant. / Pé

			// ## nPZBCXTT > ZBC_TTSICM < cPFoBCXTT ## Tot S/ ICMS
			_ZBC_TTSICM := _ZBC_ARROV * _ZBC_QUANT
			&( "o" + cPFoBCXTT + "ZBCGDad"):aCols[ nAt, nPZBCXTT ] := _ZBC_TTSICM

		EndIf

		// ## nPZBCVlU > ZBC_VLUSIC < cPFoBCVlU ## Vl Un Sem IC
		_ZBC_VLUSIC := NoRound( _ZBC_TTSICM / _ZBC_QUANT, TamSX3("ZBC_VLUSIC")[2])
		&( "o" + cPFoBCVlU + "ZBCGDad"):aCols[ nAt, nPZBCVlU ] := _ZBC_VLUSIC

		// o campo _ZBC_TTSICM foi atualizado a cima; portanto precisa ser repetido
		// ## nPZBCTot > ZBC_TOTAL < cPFoBCTot ## R$ Total Ped
		_ZBC_TOTAL := NoRound( _ZBC_TTSICM + _ZBC_TOTICM - _ZBC_OUTDES + _ZBC_OUTACR + _ZBC_JUROS + _ZBC_VLRFIM + ;
				Iif(_ZBC_TPSENA=="V",_ZBC_VLRSEN,0), TamSX3("ZBC_TOTAL")[2])
				// Iif(_ZBC_TPSENA=="V",_ZBC_VLRSEN,iIf(_ZBC_TPSENA=="D",-1*_ZBC_VLRSEN,0)), TamSX3("ZBC_TOTAL")[2])
		If &( "o" + cPFoBCPdP + "ZBCGDad"):aCols[ nAt, nPZBCPdP ] <> "P" .AND. U_CanEdit(.F.)
			// ## nPZBCTot > ZBC_TOTAL < cPFoBCTot ## R$ Total Ped
			&( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nAt, nPZBCTot ] := _ZBC_TOTAL

			// ## nPZBCPrc > ZBC_PRECO < cPFoBCPrc ## R$ Unit Ped
			&( "o" + cPFoBCPrc + "ZBCGDad"):aCols[ nAt, nPZBCPrc ] := NoRound( _ZBC_TOTAL / _ZBC_QUANT , TamSX3("ZBC_PRECO")[2])
		EndIf

		nVlrUniNeg := NoRound( _ZBC_TOTAL / _ZBC_QUANT , TamSX3("ZBC_PRECO")[2])
		If ((_ZBC_TOTAL-_ZBC_OUTDES + _ZBC_OUTACR + _ZBC_VLRFIM + Iif(_ZBC_TPSENA=="V",_ZBC_VLRSEN,0))/_ZBC_QUANT) <> nVlrUniNeg
			// ## nPZBCTNG > ZBC_TOTNEG < cPFoBCTNG ## R$ Total Neg
			&( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nAt, nPZBCTNG ] := _ZBC_TOTAL
			// ## nPZBCPNG > ZBC_PRENEG < cPFoBCPNG ## R$ Unit Neg
			&( "o" + cPFoBCPNG + "ZBCGDad"):aCols[ nAt, nPZBCPNG ] := _ZBC_TOTAL/_ZBC_QUANT
		Else
			// ## nPZBCTNG > ZBC_TOTNEG < cPFoBCTNG ## R$ Total Neg
			&( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nAt, nPZBCTNG ] := _ZBC_TOTAL
			// ## nPZBCPNG > ZBC_PRENEG < cPFoBCPNG ## R$ Unit Neg
			&( "o" + cPFoBCPNG + "ZBCGDad"):aCols[ nAt, nPZBCPNG ] := nVlrUniNeg
		EndIf

		// ## nPZBCROB > ZBC_VLAROB < cPFoBCROB ## Vlr R$ Neg => R$ Neg Final
		_ZBC_VLAROB := _ZBC_TOTAL/(_ZBC_PESO*_ZBC_REND/100)*15
		&( "o" + cPFoBCROB + "ZBCGDad"):aCols[ nAt, nPZBCROB ] := _ZBC_VLAROB


	/* ============================================================================================================== */
	// ## nPZBCToI > ZBC_TOTICM < cPFoBCToI ## Total ICMS
	ElseIf cCampo == 'ZBC_TOTICM'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 12")

		_ZBC_TOTICM := _cInfo
		&( "o" + cPFoBCToI + "ZBCGDad"):aCols[ nAt, nPZBCToI ] := _ZBC_TOTICM

		// ## nPZBCVLI > ZBC_VLICM < cPFoBCVLI ## ICMS p/ Cabe
		_ZBC_VLICM := NoRound( _ZBC_TOTICM / _ZBC_QUANT, TamSX3("ZBC_VLICM")[2])
		&( "o" + cPFoBCVLI + "ZBCGDad"):aCols[ nAt, nPZBCVLI ] := _ZBC_VLICM

		// ## nPZBCToP > ZBC_ICMSVL < cPFoBCToP ## R$ ICMS V@
		&( "o" + cPFoBCToP + "ZBCGDad"):aCols[ nAt, nPZBCToP ] := _ZBC_TOTICM

		U_ZBCFieldOK('ZBC_TTSICM', _ZBC_TTSICM )

	// ## nPZBCVLI > ZBC_VLICM < cPFoBCVLI ## ICMS p/ Cabe
	/* ============================================================================================================== */
	ElseIf cCampo == 'ZBC_VLICM'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 13")

		// ## nPZBCQtd > "ZBC_QUANT" < cPFoBCQtd  ## Qtde Pedido
		_ZBC_QUANT := Iif(ReadVar()=='M->ZBC_QUANT', &(ReadVar()), &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nAt, nPZBCQtd ])

		// ## nPZBCToI > ZBC_TOTICM < cPFoBCToI ## Total ICMS
		_ZBC_TOTICM := NoRound( _cInfo * _ZBC_QUANT, TamSX3("ZBC_TOTICM")[2])
		&( "o" + cPFoBCToI + "ZBCGDad"):aCols[ nAt, nPZBCToI ] := _ZBC_TOTICM

		// ## nPZBCToP > ZBC_ICMSVL < cPFoBCToP ## R$ ICMS V@
		&( "o" + cPFoBCToP + "ZBCGDad"):aCols[ nAt, nPZBCToP ] := _ZBC_TOTICM // &( "o" + cPFoBCToI + "ZBCGDad"):aCols[ nAt, nPZBCToI ]

		U_ZBCFieldOK('ZBC_TTSICM', _ZBC_TTSICM )

	// ## nPZBCOTS > ZBC_OUTDES < cPFoBCOTS ## Outros Desc
	/* ============================================================================================================== */
	ElseIf cCampo == 'ZBC_OUTDES'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 14")

		If _cInfo <> &( "o" + cPFoBCOTS + "ZBCGDad"):aCols[ nAt, nPZBCOTS ]

			// ## nPZBCOTS > ZBC_OUTDES < cPFoBCOTS ## Outros Desc
			&( "o" + cPFoBCOTS + "ZBCGDad"):aCols[ nAt, nPZBCOTS ] := _cInfo

			U_ZBCFieldOK('ZBC_TTSICM', _ZBC_TTSICM )
		EndIf

	// ## nPZBCOTA > ZBC_OUTACR < cPFoBCOTA ## Outros Acrescimos
	ElseIf cCampo == 'ZBC_OUTACR'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 15")

		If _cInfo <> &( "o" + cPFoBCOTA + "ZBCGDad"):aCols[ nAt, nPZBCOTA ]

			// ## nPZBCOTA > ZBC_OUTACR < cPFoBCOTA ## Outros Acrescimos
			&( "o" + cPFoBCOTA + "ZBCGDad"):aCols[ nAt, nPZBCOTA ] := _cInfo

			U_ZBCFieldOK('ZBC_TTSICM', _ZBC_TTSICM )
		EndIf

	// ## nPZBCOFM > ZBC_VLRFIM < cPFoBCOFM ## Acrescenta o valor da comissao no valor final da negociação
	ElseIf cCampo == 'ZBC_VLRFIM'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 16")

		If _cInfo <> &( "o" + cPFoBCOFM + "ZBCGDad"):aCols[ nAt, nPZBCOFM ]

			// ## nPZBCOFM > ZBC_VLRFIM < cPFoBCOFM ## Acrescenta o valor da comissao no valor final da negociação
			&( "o" + cPFoBCOFM + "ZBCGDad"):aCols[ nAt, nPZBCOFM ] := _cInfo

			U_ZBCFieldOK('ZBC_TTSICM', _ZBC_TTSICM )
		EndIf

	// ## nPZBCJur > ZBC_JUROS < cPFoBCJur ## Acrescenta Juros
	ElseIf cCampo == 'ZBC_JUROS'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 17")

		If _cInfo <> &( "o" + cPFoBCJur + "ZBCGDad"):aCols[ nAt, nPZBCJur ]

			// ## nPZBCJur > ZBC_JUROS < cPFoBCJur ## Acrescenta Juros
			&( "o" + cPFoBCJur + "ZBCGDad"):aCols[ nAt, nPZBCJur ] := _cInfo

			U_ZBCFieldOK('ZBC_TTSICM', _ZBC_TTSICM )

		EndIf

	// ## nPZBCTES > ZBC_TES < cPFoBCTES ## Tipo Ent/Sai
	/* ============================================================================================================== */
	ElseIf cCampo == 'ZBC_TES'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 18")
		&( "o" + cPFoBCTES + "ZBCGDad"):aCols[ nAt, nPZBCTES ] := _cInfo

		U_ZBCFieldOK('ZBC_TPSENA', _ZBC_TPSENA )

		// If _cInfo <> SF4->F4_CODIGO
		// 	SF4->(DbSetOrder(1))
		// 	SF4->(DbSeek( FWxFilial('SF4') + _cInfo ))
		// EndIf
		//
		// // Sim							// S = Sem Senar
		// If SF4->F4_CSENAR == '1'
		//
		// 	// ## nPZBCAQS > ZBC_ALIQSE < cPFoBCAQS ## Aliq. Senar
		// 	&( "o" + cPFoBCAQS + "ZBCGDad"):aCols[ nAt, nPZBCAQS ] := _ZBC_ALIQSE := SF4->F4_ALSENAR
		//
		// 	If _ZBC_TPSENA == "F"
		//
		// 		&( "o" + cPFoBCTES + "ZBCGDad"):aCols[ nAt, nPZBCTES ] := Space(TamSX3("F4_CODIGO")[1])
		// 		MsgInfo("Foi selecionado o tipo FOLHA, porém a TES selecionada indica incidencia de imposto senar. Favor confirmar o TIPO de configuração do imposto SENAR selecionada.")
		//
		// 	Else
		//
		// 		If _ZBC_TPSENA == "D" // Desconta
		//
		// 			&( "o" + cPFoBCVLS + "ZBCGDad"):aCols[ nAt, nPZBCVLS ] := _ZBC_TOTNEG * (_ZBC_ALIQSE/100)
		//
		// 		ElseIf _ZBC_TPSENA == "V" // V@ Paga
		//
		// 			_nAUX := _ZBC_TOTNEG * (_ZBC_ALIQSE/100) // 40,00
		// 			_nAUX := _nAUX + _ZBC_TOTNEG // 20000+40,00
		// 			_nAUX := _nAUX * (_ZBC_ALIQSE/100)
        //
		// 			&( "o" + cPFoBCVLS + "ZBCGDad"):aCols[ nAt, nPZBCVLS ] := _nAUX
		//
		// 		EndIf
		// 	EndIf
		// EndIf

	/* ============================================================================================================== */
	// ## nPZBCTPS > ZBC_TPSENA < cPFoBCTPS ## Tipo Senar
	ElseIf cCampo == 'ZBC_TPSENA'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 19")

		If Empty(&( "o" + cPFoBCTES + "ZBCGDad"):aCols[ nAt, nPZBCTES ])
			MsgInfo('TES não localizada. Esta operação sera cancelada!!!', 'Atenção')
			Return .F.
		EndIf

		If &( "o" + cPFoBCTES + "ZBCGDad"):aCols[ nAt, nPZBCTES ] <> SF4->F4_CODIGO
			SF4->(DbSetOrder(1))
			SF4->(DbSeek( FWxFilial('SF4') + &( "o" + cPFoBCTES + "ZBCGDad"):aCols[ nAt, nPZBCTES ] ))
		EndIf

		If _cInfo == "F" // .and. _cInfo<>_ZBC_TPSENA// Folha = Sem Senar

			// Sim
			If SF4->F4_CSENAR == '1'
				_cInfo := &(ReadVar()) := _ZBC_TPSENA
				MsgInfo("Foi selecionado o tipo FOLHA, porém a TES selecionada indica incidencia de imposto senar. Favor confirmar o TIPO de configuração do imposto SENAR selecionada.")
				Return .F.
			Else
				&( "o" + cPFoBCAQS + "ZBCGDad"):aCols[ nAt, nPZBCAQS ] := 0
				&( "o" + cPFoBCVLS + "ZBCGDad"):aCols[ nAt, nPZBCVLS ] := 0
			EndIf

		Else

			// comentado no dia 01.04.19
			// If _cInfo == "D" // .and. _cInfo<> _ZBC_TPSENA // Desconta
			//
			// 	_nAUX := _ZBC_TOTNEG * (_ZBC_ALIQSE/100)
			// 	&( "o" + cPFoBCVLS + "ZBCGDad"):aCols[ nAt, nPZBCVLS ] := _nAUX
			//
			// ElseIf _cInfo == "V" // .and. _cInfo<>_ZBC_TPSENA// V@ Paga
			//
			// 	_nAUX := _ZBC_TOTNEG * (_ZBC_ALIQSE/100) // 40,00
			// 	_nAUX := _nAUX + _ZBC_TOTNEG // 20000+40,00
			// 	_nAUX := _nAUX * (_ZBC_ALIQSE/100)
            //
			// 	&( "o" + cPFoBCVLS + "ZBCGDad"):aCols[ nAt, nPZBCVLS ] := _nAUX
			//
			// EndIf

			// Sim
			If SF4->F4_CSENAR == '1'
				// ## nPZBCAQS > ZBC_ALIQSE < cPFoBCAQS ## Aliq. Senar
			    &( "o" + cPFoBCAQS + "ZBCGDad"):aCols[ nAt, nPZBCAQS ] := _ZBC_ALIQSE := SF4->F4_ALSENAR

				_nAUX := (_ZBC_TTSICM+_ZBC_TOTICM) * (_ZBC_ALIQSE/100)
				&( "o" + cPFoBCVLS + "ZBCGDad"):aCols[ nAt, nPZBCVLS ] := _nAUX
			Else
				MsgInfo("Foi selecionado uma TES selecionada não indica incidencia de imposto senar. Favor confirmar o TIPO de configuração do imposto SENAR selecionada.")
				Return .F.
			EndIf

			U_ZBCFieldOK('ZBC_TTSICM', _ZBC_TTSICM )

		EndIf

	/* ============================================================================================================== */
	// ## nPZBCOMU > ZBC_COMUNI < cPFoBCOMU ## Comissão Unitário
	ElseIf cCampo == 'ZBC_COMUNI'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 20")

		&( "o" + cValToChar(cPFoBCCor) + "ZBCGDad"):aCols[ nAt, nPZBCCor ] := M->ZCC_CODCOR


		&( "o" + cValToChar(cPFoBCOMT) + "ZBCGDad"):aCols[ nAt, nPZBCOMT ] := _ZBC_QUANT * _ZBC_COMUNI


	/* ============================================================================================================== */
	// ## nPZBCOMT > ZBC_VLRCOM < cPFoBCOMT ## Comissão Total
	ElseIf cCampo == 'ZBC_VLRCOM'
		MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 21")

		&( "o" + cValToChar(cPFoBCCor) + "ZBCGDad"):aCols[ nAt, nPZBCCor ] := M->ZCC_CODCOR


		&( "o" + cValToChar(cPFoBCOMU) + "ZBCGDad"):aCols[ nAt, nPZBCOMU ] := _ZBC_VLRCOM / _ZBC_QUANT

	EndIf

	// If M->ZCC_PAGFUT == "N" .AND. &( "o" + cPFoBCTPN + "ZBCGDad"):aCols[ nAt, nPZBCTPN ] == "P"
	// 	// GdFieldPut( 'ZBC_ARROV', oZICGDad:aCols[ aScan( oZICGDad:aCols, {|x| AllTrim(x[nPZICIte])== cItemZIC }), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_VLAROB"}) ] )
	// 	&( "o" + cPFoBCArv + "ZBCGDad"):aCols[ nAt, nPZBCArv ] := &( "o" + cPFoBCROB + "ZBCGDad"):aCols[ nAt, nPZBCROB ]
	// EndIf

	MBSaveLog():FULLWrite(, .F., "ZBCFieldOK() - 22")
	// REFRESH ABAS - ATUALIZA ABAS
	For nF := 1 to len(aFolderG)
		&( "o" + cValToChar(nF) + "ZBCGDad" ):Refresh()
	Next nF

	MBSaveLog():FULLWrite(, .F., "Fim: ZBCFieldOK("+cCampo+"")

Return lRet
// Fim: ZBCFieldOK



/* MJ : 17.12.2018 */
Static Function RetPosCpoAba( cCampo, cAba )
	Local nRet := 1

	MBSaveLog():FULLWrite(, .F., "Inicio: RetPosCpoAba(  )")

		cAba      := Posicione( 'SX3', 2, cCampo, "X3_FOLDER" )
		If Empty(cAba)
			cAba := "1"
		EndIf
		nRet := aScan( &("a" + cAba + "ZBCHead"), { |x| AllTrim(x[2]) == cCampo } )

	MBSaveLog():FULLWrite(, .F., "FIm: RetPosCpoAba(  )")

Return nRet


/* MJ : 09.11.2017 */
Static Function VldOk(nOpc)
Local lRet 	:= .T.
Local nI	:= 0

	MBSaveLog():FULLWrite(, .F., "Inicio: VldOk()")

	If M->ZCC_PAGFUT == "N"
		// For nI:=1 to Len(oZICGDad:aCols)
		// 	If Empty( oZICGDad:aCols[ nI, aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_VLAROB"}) ] ) .and. ;
		// 		!Empty( oZICGDad:aCols[ nI, aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_QUANT"}) ] )
		// 			Exit
		// 	EndIf
		// Next nI
		// If nI <= Len(oZICGDad:aCols)
		// 	Aviso("Aviso", ;
		// 		  "Valor de @ nao informado na linha: " + AllTrim(Str(nI)) + ;
		// 		  " na tabela dos ITENS DO CONTRATO / COMISSÃO.", ;
		// 		  {"Sair"} )
		// 	lRet 	:= .F.
		// EndIf

		If lRet
			For nI:=1 to Len(o1ZBCGDad:aCols)
				If !Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
					If ;// !oZICGDad:aCols[ Val( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEZIC"}) ] ), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] $ ("KQ") .and. ;
						Empty( &( "o" + cPFoBCArv + "ZBCGDad"):aCols[ nI, nPZBCArv ] ) .and. ;
						!Empty( &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ] ) .and. ;
						o1ZBCGDad:aCols[ nI, nPZBCPdP ] <> "P"

							Exit
					EndIf
				EndIf
			Next nI
			If nI <= Len(o1ZBCGDad:aCols)
				Aviso("Aviso", ;
					  "Valor de @ nao informado na linha: " + AllTrim(Str(nI)) + ;
					  " na tabela da CONFIGURAÇÃO DA BASE CONTRATUAL.", ;
					  {"Sair"} )
				lRet 	:= .F.
			EndIf
		EndIf
	EndIf

	If lRet
		For nI:=1 to Len(o1ZBCGDad:aCols)
			If !Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
				If ; // !oZICGDad:aCols[ Val( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEZIC"}) ] ), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] $ ("KQ") .and. ;
					!Empty( &( "o" + cPFoBCOTS + "ZBCGDad"):aCols[ nI, nPZBCOTS ] ) .and. ;
					Empty( &( "o" + cPFoBCOBS + "ZBCGDad"):aCols[ nI, nPZBCOBS ] )

						Exit
				EndIf
			EndIf
		Next nI
		If nI <= Len(o1ZBCGDad:aCols)
			Aviso("Aviso", ;
				  "Campo OBSERVAÇÃO não informado na linha: " + AllTrim(Str(nI)) + ;
				  " na tabela da CONFIGURAÇÃO DA BASE CONTRATUAL." + CRLF + "Esta Operação sera cancelada.", ;
				  {"Sair"} )

			lRet 	:= .F.
		EndIf
	EndIf
	MBSaveLog():FULLWrite(, .F., "Fim: VldOk()")
Return lRet

/* MJ : 13.11.2017 */
Static Function xAutoSC7()
	MBSaveLog():FULLWrite(, .F., "Inicio: xAutoSC7()")
	Local aArea			:= GetArea()
	Local nI            := 0
	Local lOk
	Local cCondP		:= ''
	Local cCondPB		:= ''

	MBSaveLog():FULLWrite(, .F., "xAutoSC7() - 1")

	if M->ZCC_STATUS=="A"
		if !msgYesNo("Esta operação bloqueará a edição do cabeçalho e itens, deseja continuar?")
			RestArea(aArea)
			return nil
		else
			M->ZCC_STATUS := "N"

			recLock("ZCC")
				ZCC->ZCC_STATUS := "N"
			msUnlock()

			oMGet:Disable()
		endIf
	endIf

	If M->ZCC_VERSAO != ZCC->ZCC_VERSAO // NOVA VERSAO
		Aviso("Aviso", "Não é permitido gerar pedidos durante o processo de geração de nova versão. Salve a edição e clique em Alterar para gerar pedidos.", {"Sair"} )
		RestArea(aArea)
		return nil
	EndIf

		MBSaveLog():FULLWrite(, .F., "xAutoSC7() - 2")
	lOk := .T.
	For nI := 1 to Len(o1ZBCGDad:aCols)
		If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
			if &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ] == 0 .or. &( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nI, nPZBCTot ] == 0  .or. empty( &( "o" + cPFoBCCDP + "ZBCGDad"):aCols[ nI, nPZBCCDP ] )
				Alert("Existem campos obrigatórios não informados. Preencha-os antes de gerar o pedido.")
				RestArea(aArea)
				return nil
			endIf
		EndIf
	Next nI

		MBSaveLog():FULLWrite(, .F., "xAutoSC7() - 3")
	// A parte abaixo foi copiada da funcao VldOk, foi retirado a parte que valida o tipo do Item na ZIC
	For nI:=1 to Len(o1ZBCGDad:aCols)
		If !Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
			If ; // !oZICGDad:aCols[ Val( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEZIC"}) ] ), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] $ ("KQ") .and. ;
				o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK' .and. ;
				Empty( o2ZBCGDad:aCols[ nI, aScan( a2ZBCHead, {|x| AllTrim(x[2])=="ZBC_ARROV"}) ] ) .and. ;
				!Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_QUANT"}) ] ) .and. ;
				o1ZBCGDad:aCols[ nI, nPZBCPdP ] <> "P"

					Exit
			EndIf
		EndIf
	Next nI
		MBSaveLog():FULLWrite(, .F., "xAutoSC7() - 4")
	If nI <= Len(o1ZBCGDad:aCols)
		Aviso("Aviso", ;
			"Valor de @ nao informado na linha: " + AllTrim(Str(nI)) + ;
			" na tabela da CONFIGURAÇÃO DA BASE CONTRATUAL." + CRLF + "Esta Operação sera cancelada.", ;
			{"Sair"} )

		RestArea(aArea)
		return nil
	EndIf

	// ================================================================================================

		MBSaveLog():FULLWrite(, .F., "xAutoSC7() - 5")
	// Validar campo desconto, se preenchido obrigar preenchimento do campo OBS na ZBC
	For nI:=1 to Len(o1ZBCGDad:aCols)
		If !Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
			If ; // !oZICGDad:aCols[ Val( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEZIC"}) ] ), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] $ ("KQ") .and. ;
				o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK' .and. ;
				!Empty( &( "o" + cPFoBCOTS + "ZBCGDad"):aCols[ nI, nPZBCOTS ] ) .and. ;
				Empty( &( "o" + cPFoBCOBS + "ZBCGDad"):aCols[ nI, nPZBCOBS ] )

					Exit
			EndIf
		EndIf
	Next nI
		MBSaveLog():FULLWrite(, .F., "xAutoSC7() - 6")
	If nI <= Len(o1ZBCGDad:aCols)
		Aviso("Aviso", ;
			"Campo OBSERVAÇÃO não informado na linha: " + AllTrim(Str(nI)) + ;
			" na tabela da CONFIGURAÇÃO DA BASE CONTRATUAL." + CRLF + "Esta Operação sera cancelada.", ;
			{"Sair"} )

		RestArea(aArea)
		return nil
	EndIf

	// ================================================================================================

	// Validar campo vencimento ,Deiar obrigatório na tabela ZBC conforme solicitação da Camila via WhatsApp em 23/02/2022
	// Retirada a validação, pois as datas de vencimento serão controladas pela tabela ZBD - 07/02/2024
	//For nI:=1 to Len(o1ZBCGDad:aCols)
	//	If !Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
	//		If ; // !oZICGDad:aCols[ Val( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEZIC"}) ] ), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] $ ("KQ") .and. ;
	//		    o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK' .and. ;
	//			Empty( &( "o" + cPFoBCDvc + "ZBCGDad"):aCols[ nI, nPZBCDvc ] )
	//
	//				Exit
	//		EndIf
	//	EndIf
	//Next nI
		MBSaveLog():FULLWrite(, .F., "xAutoSC7() - 7")
	If nI <= Len(o1ZBCGDad:aCols)
		Aviso("Aviso", ;
			"Campo Data de Vencimento não informado na linha: " + AllTrim(Str(nI)) + ;
			" na tabela da CONFIGURAÇÃO DA BASE CONTRATUAL." + CRLF + "Esta Operação sera cancelada.", ;
			{"Sair"} )

		RestArea(aArea)
		return nil
	EndIf

		MBSaveLog():FULLWrite(, .F., "xAutoSC7() - 8")
	// validar se existe pedido de compra ja existente na linha selecionada;
	For nI:=1 to Len(o1ZBCGDad:aCols)
		If !Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
			If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK' .and. ;
				!Empty( &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ] )

					Exit
			EndIf
		EndIf
	Next nI
		MBSaveLog():FULLWrite(, .F., "xAutoSC7() - 9")
	If nI <= Len(o1ZBCGDad:aCols)
		MsgInfo( "O Pedido de Compra: <b>" + AllTrim( o1ZBCGDad:aCols[ nI, nPZBCPed]) + ;
			"</b> ja se encontra vinculada na linha: <b>" + AllTrim(Str( nI )) + "</b>." + CRLF + "Esta operação será cancelada.", "Atenção")

		RestArea(aArea)
		return nil
	EndIf

		MBSaveLog():FULLWrite(, .F., "xAutoSC7() - 10")
	For nI := 1 to Len(o1ZBCGDad:aCols)
		If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
			if Empty(cCondP)
				cCondP := o1ZBCGDad:aCols[ nI, nPZBCCDP]
			else
				if cCondP != o1ZBCGDad:aCols[ nI, nPZBCCDP]
					MsgAlert("Não é possivel gerar pedido. A condição de pagamento tem que ser igual em todas as linhas selecionadas!")
					Return nil
				endif
			endif 
		endif
	Next nI

	Processa( { || xGeraSC7() }, 'Gerando Pedido de Compras', 'Aguarde ...', .F. )

	MBSaveLog():FULLWrite(, .F., "Fim: xAutoSC7()")

	RestArea(aArea)
Return nil


/* MJ : 08.11.2017 */
Static Function M7GerarPrd( /* nPZIC, */ nPZBC)
	MBSaveLog():FULLWrite(, .F., "Inicio: M7GerarPrd()")
	Local aProd 		:= {}
	Local lRet			:= .T.
	Local nI			:= nPZBC

	Private lMsHelpAuto := .F.
	Private lMsErroAuto := .F.

//Adicionado por Renato de Bianchi para identificar se deve gerar o BOV ou usar o produto da ZIC
if !(cFilAnt $ SuperGetMv("VA_FILGBOV",,"01"))
	dbSelectArea("SB1")
	dbSetOrder(1)
	// dbSeek(FWxFilial("SB1")+oZICGDad:aCols[ nPZIC, nPZICPrd])
	dbSeek(FWxFilial("SB1")+ o1ZBCGDad:aCols[ nI/* nPZIC */, nPZBC1IC/* nPZICPrd */])

	return .T.
endIf

	If Empty( o1ZBCGDad:aCols[ nI/* nPZIC */, nPZBC1IC/* nPZICPrd */] )
		MsgAlert('Nao foi encontrado o codigo do animal de modelo.' + CRLF + 'Este processo sera cancelado. ')
		Return .F.
	EndIf

	aAdd( aProd, {"B1_FILIAL"	, FWxFilial("SB1")	, nil })
	aAdd( aProd, {"B1_GRUPO"	, "BOV"				, nil })

	_cCodPrd	:= U_PROXSB1( "BOV" )
	aAdd( aProd, {"B1_COD"		, _cCodPrd			, nil })

	// _cPrdto := RetField('SB1',1,FWxFilial('SB1')+oZICGDad:aCols[ nPZIC, nPZBC1IC/* nPZICPrd */],'B1_DESC')
	_cPrdto := RetField('SB1',1,FWxFilial('SB1')+o1ZBCGDad:aCols[ nI, nPZBC1IC/* nPZICPrd */],'B1_DESC')
	aAdd( aProd, {"B1_DESC"		, _cPrdto			, nil })
	aAdd( aProd, {"B1_TIPO"		, "PA"				, nil })
	aAdd( aProd, {"B1_UM"		, "UN"				, nil })
	aAdd( aProd, {"B1_LOCPAD"	, "01"				, nil })
	aAdd( aProd, {"B1_CONTA"	, "1140200001"      , nil })
	aAdd( aProd, {"B1_POSIPI"	, GetMV("JR_POSIPI",,"01022919"), nil })
	aAdd( aProd, {"B1_ORIGEM"	, "0"				, nil })
	aAdd( aProd, {"B1_X_TRATO"	, "2"				, nil })
	aAdd( aProd, {"B1_X_PRDES"	, "1"				, nil })
	aAdd( aProd, {"B1_PICM"		, 0					, nil })
	aAdd( aProd, {"B1_IPI"		, 0					, nil })
	aAdd( aProd, {"B1_CONTRAT"	, "N"				, nil })
	aAdd( aProd, {"B1_LOCALIZ"	, "N"				, nil })
	aAdd( aProd, {"B1_TE"		, GetMV("JR_M11TESC",,"005"), nil })
	// aAdd( aProd, {"B1_APROPRI"	, "D"				, nil })
	aAdd( aProd, {"B1_GRTRIB"	, "001"				, nil })
	aAdd( aProd, {"B1_CODBAR"	, "SEM GTIN" /* oZICGDad:aCols[ nPZIC, nPZICPrd] */, nil }) // SEM GTIN => layout 4.0
	aAdd( aProd, {"B1_TIPCAR"	, "005"				, nil })
	aAdd( aProd, {"B1_TPREG"	, "2"				, nil })

	If !ISINCALLSTACK("U_VACOMM12")
		//Encontra o B1_XANIMAL
		xAnimal := SB1->B1_XANIMAL

		aSexoX := { {"M", "MACHO"}, {"F", "FEMEA"}, {"C", "CAPAO"} }
		aRacaX := { {"N", "NELORE"}, {"C", "CRUZAMENTO"}, {"M", "MESTICO"}, {"A", "ANGUS"} }

		nPSexo := aScan( o1ZBCGDad:aHeader,  {|x| AllTrim(x[2])=="ZBC_SEXO"}) 	// nPSexo   := aScan( aZICHead,  {|x| AllTrim(x[2])=="ZIC_SEXO"})
		nPRaca := aScan( o1ZBCGDad:aHeader,  {|x| AllTrim(x[2])=="ZBC_RACA"})  // nPRaca   := aScan( aZICHead,  {|x| AllTrim(x[2])=="ZIC_RACA"})
		cSexoX := AllTrim(aSexoX[aScan(aSexoX, {|x| x[1]==o1ZBCGDad:aCols[ nI /*nPZIC*/, nPSexo]}),2])	// cSexoX := AllTrim(aSexoX[aScan(aSexoX, {|x| x[1]==oZICGDad:aCols[ nI /*nPZIC*/, nPSexo]}),2])
		cRacaX := AllTrim(aRacaX[aScan(aRacaX, {|x| x[1]==o1ZBCGDad:aCols[ nI /*nPZIC*/, nPRaca]}),2])	// cRacaX := AllTrim(aRacaX[aScan(aRacaX, {|x| x[1]==oZICGDad:aCols[ nI /*nPZIC*/, nPRaca]}),2])
		cIdadX := AllTrim(SB1->B1_XIDADE)

		//A=Angus;C=Cruzamento;M=Mestico;N=Nelore
		beginSQL alias "QRYA"
			%noParser%
			select Z09_CODIGO
			from %table:Z09% Z09
			where Z09_FILIAL=%xFilial:Z09% and Z09.%notDel%
			and Z09_SEXO=%exp:cSexoX%
			and Z09_RACA=%exp:cRacaX%
			and %exp:cIdadX% between Z09_IDAINI and Z09_IDAFIM
		endSQL
		if !QRYA->(Eof())
			xAnimal := QRYA->Z09_CODIGO
		endIf
		QRYA->(dbCloseArea())
	EndIf

	// adicionais
	aAdd( aProd, {"B1_XPARCER"	, M->ZCC_PARCER					, nil })
	aAdd( aProd, {"B1_X_PESOC"	, &( "o" + cPFoBCPes + "ZBCGDad"):aCols[ nI, nPZBCPes ], nil })
	// aAdd( aProd, {"B1_X_RENDP"	, o1ZBCGDad:aCols[ nI, nPZBCReP ], nil })
	aAdd( aProd, {"B1_X_ARRON"	, &( "o" + cPFoBCArv + "ZBCGDad"):aCols[ nI, nPZBCArv ], nil })
	aAdd( aProd, {"B1_X_TOICM"	, &( "o" + cPFoBCToI + "ZBCGDad"):aCols[ nI, nPZBCToI ], nil })
	aAdd( aProd, {"B1_X_VLICM"	, &( "o" + cPFoBCVLI + "ZBCGDad"):aCols[ nI, nPZBCVLI ], nil })
	aAdd( aProd, {"B1_XIDADE"	, SB1->B1_XIDADE 			    , nil })
	aAdd( aProd, {"B1_CUSTD"	, SB1->B1_CUSTD 			    , nil })
	aAdd( aProd, {"B1_MCUSTD"	, "1"						    , nil })
	// MJ : 08.03.18
	aAdd( aProd, {"B1_X_CRED"	, SB1->B1_X_CRED 			    , nil })
	aAdd( aProd, {"B1_X_CUSTO"	, SB1->B1_X_CUSTO 			    , nil })
	aAdd( aProd, {"B1_X_DEBIT"	, SB1->B1_X_DEBIT 			    , nil })
	// -------------------------------------------------------------------------------------
	aAdd( aProd, {"B1_XANIMAL"	, xAnimal						, nil })
	aAdd( aProd, {"B1_X_COMIS"	, &( "o" + cPFoBCVCM + "ZBCGDad"):aCols[ nI, nPZBCVCM ], nil })
	aAdd( aProd, {"B1_XVLRPTA"	, &( "o" + cPFoBCVPT + "ZBCGDad"):aCols[ nI, nPZBCVPT ], nil })
	aAdd( aProd, {"B1_XALIICM"	, &( "o" + cPFoBCAIC + "ZBCGDad"):aCols[ nI, nPZBCAIC ], nil })
	aAdd( aProd, {"B1_XVICMPA"	, &( "o" + cPFoBCICP + "ZBCGDad"):aCols[ nI, nPZBCICP ], nil })
	aAdd( aProd, {"B1_XCONTRA"	, M->ZCC_CODIGO					, nil })
	/*
		-> B1_CONTSOC alterado para N no dia 08.03.2019
			Sol. Por Rodrigo Martins - Fiscal;
	*/
	aAdd( aProd, {"B1_CONTSOC"	, 'N'							, nil })
	aAdd( aProd, {"B1_MSBLQL"	, "2"							, nil })
	aAdd( aProd, {"B1_X_TRATO"	, "2"							, nil })

	if lRastro
		aAdd( aProd, {"B1_RASTRO"	, 'L'						, nil })
	endIf

	// FG_X3ORD("C", , aProd )

	lMsErroAuto := .F.
	MBSaveLog():FULLWrite(, .F., "Inicio: MATA010() - Inclusao")
	
		MSExecAuto({|x, y| MATA010(x, y)}, aProd, 3)

	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
		lRet := .F.
		MBSaveLog():FULLWrite(, .F., "Fim: MATA010() - Inclusao - Erro ")
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: MATA010() - Inclusao")

	MBSaveLog():FULLWrite(, .F., "Fim: M7GerarPrd()")

// EndIf
Return lRet

/* MJ : 08.11.2017
	Alt. 31.01.2018
		* Alterado formato do processamento do ExecAuto;
		* Permissão para varios produtos por pedido;
	*/
Static Function xGeraSC7()
	Local aArea			:= GetArea()

	Local aCab          := {}
	Local aItem         := {}
	Local aItens        := {}
	Local cNumPc 		:= ""
	Local lErro			:= .F.
	Local dDtEntrega	:= sToD("")
	Local nI, nItem		:= 0
	Local ZBCCONDPA		:= ""
	Local cErro			:= ""
	Local nJ			:= 0
	Local nF            := 0
	Local nX 

	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.

	MBSaveLog():FULLWrite(, .F., "Inicio: xGeraSC7()")

	If SM0->M0_CODFIL <> FWxFilial('SC7')
		SM0->(DbSeek(SM0->M0_CODIGO +  FWxFilial('SC7') ))
	EndIf

	/* For nI := 1 to Len(o1ZBCGDad:aCols)
		If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
			if Empty(cCondP)
				cCondP := o1ZBCGDad:aCols[ nI, nPZBCCDP]
			else
				if cCondP != o1ZBCGDad:aCols[ nI, nPZBCCDP]
					MsgAlert("Não é possivel gerar pedido. A condição de pagamento tem que ser igual em todas as linhas selecionadas!")
					Return nil
				endif
			endif 
		endif
	Next nI */

	Begin Transaction
		MBSaveLog():FULLWrite(, .F., "xGeraSC7: Inicio da Transação")

		For nI := 1 to Len(o1ZBCGDad:aCols)
			If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'

				If Empty(ZBCCONDPA)
					// ZBCCONDPA := o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_CONDPA"}) ]
					ZBCCONDPA := &( "o" + cPFoBCCDP + "ZBCGDad"):aCols[ nI, nPZBCCDP ]
				EndIf

				// Criar Produto
				// nPZIC := aScan( oZICGDad:aCols, {|x| AllTrim(x[nPZICIte])== o1ZBCGDad:aCols[ nI, nPZBCZIC] })
				If M7GerarPrd(/* nPZIC, */ nI)
					aItem := {}
					aAdd( aItem, { "C7_ITEM"   		, StrZero(Len(aItens)+1,TamSX3('C7_ITEM')[1]), nil } )

					aAdd( aItem, { "C7_PRODUTO"		, SB1->B1_COD				                 , nil } ) // aAdd( aItem, {	"C7_DESCRI"		, cDescrPrd		 			, nil  } )
					&( "o" + cPFoBCPRD + "ZBCGDad"):aCols[ nI, nPZBCPRD ] := SB1->B1_COD
					RepeatFolder( 'ZBC_PRODUT', SB1->B1_COD, Val(cPFoBCPRD), nI)
					//&( "o" + cPFoBCDES + "ZBCGDad"):aCols[ nI, nPZBCDES ] := SB1->B1_DESC
					//RepeatFolder( 'ZBC_PRDDES', SB1->B1_DESC, Val(cPFoBCDES), nI)

					aAdd( aItem, { "C7_UM"			, "UN" 						                 , nil } )
					aAdd( aItem, { "C7_LOCAL" 		, "01"   					                 , nil } )
					aAdd( aItem, { "C7_QUANT" 		, &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ], nil } )

					/*
						* decido fazer a programacao para calcular na digitacao e atualizar o campo Preco Unit e Preco Total
						If o1ZBCGDad:aCols[ nI, nPZBCPdP ] == "P" // PESO
						aAdd( aItem, { "C7_PRECO" 		, o1ZBCGDad:aCols[ nI, nPZBCVPT ]             , nil } )
						aAdd( aItem, { "C7_TOTAL" 		, NoRound( o1ZBCGDad:aCols[ nI, nPZBCQtd ]*o1ZBCGDad:aCols[ nI, nPZBCVPT ], TamSX3("C7_TOTAL")[2] ), nil } )
					Else // NEGOCIAÇÃO */
						aAdd( aItem, { "C7_PRECO" 	, &( "o" + cPFoBCPrc + "ZBCGDad"):aCols[ nI, nPZBCPrc ], nil } )
						aAdd( aItem, { "C7_TOTAL" 	, &( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nI, nPZBCTot ], nil } )
					// EndIf

					If Empty( &( "o" + cPFoBCTES + "ZBCGDad"):aCols[ nI, nPZBCTES ] )
						_cC7TES	:= GetMV("JR_M11TESC",,"005")
					Else
						_cC7TES := &( "o" + cPFoBCTES + "ZBCGDad"):aCols[ nI, nPZBCTES ]
					EndIf
					aAdd( aItem, { "C7_TES" 		, _cC7TES					                 			, nil } )
					aAdd( aItem, { "C7_IPI" 		, 0  	   					                 			, nil } )
					aAdd( aItem, { "C7_CC"   		, "" 						                 			, nil } )
					aAdd( aItem, { "C7_OBS" 		, &( "o" + cPFoBCOBS + "ZBCGDad"):aCols[ nI, nPZBCOBS ]	, nil } )
					aAdd( aItem, { "C7_OBSM" 		, &( "o" + cPFoBCOBS + "ZBCGDad"):aCols[ nI, nPZBCOBS ]	, nil } )
					aAdd( aItem, { "C7_CONTATO" 	, ""   						                 			, nil } )
					aAdd( aItem, { "C7_EMISSAO"		, dDataBase              	                 			, nil } )
					aAdd( aItem, { "C7_CONTA" 		, GetMV("JR_M11CNTA",,"1140200001")	         			, nil } )
					aAdd( aItem, { "C7_MSG"   		, ""						                 			, nil } )
					aAdd( aItem, { "C7_PICM"   		, 0							                 			, nil } )
					aAdd( aItem, { "C7_SEGURO"   	, 0							                 			, nil } )
					aAdd( aItem, { "C7_DESPESA"   	, 0							                 			, nil } )
					aAdd( aItem, { "C7_TXMOEDA"   	, 0							                 			, nil } )
					aAdd( aItem, { "C7_VALFRE"   	, 0							                 			, nil } )
					aAdd( aItem, { "C7_BASESOL"   	, 0							                 			, nil } )
					aAdd( aItem, { "C7_MOEDA"    	, 1							                 			, nil } )
					//aAdd( aItem, { "C7_TPFRETE"    	, "F" 						                 		, nil } )

					// adicionais
					If !Empty(&( "o" + cPFoBCPes + "ZBCGDad"):aCols[ nI, nPZBCPes ])
						aAdd( aItem, { "C7_X_PESO"    	, &( "o" + cPFoBCPes + "ZBCGDad"):aCols[ nI, nPZBCPes ], nil  } )
					EndIf
					If !Empty(&( "o" + cPFoBCRen + "ZBCGDad"):aCols[ nI, nPZBCRen ])

						aAdd( aItem, { "C7_X_REND"    	, &( "o" + cPFoBCRen + "ZBCGDad"):aCols[ nI, nPZBCRen ], nil  } )
					EndIf
					If !Empty(&( "o" + cPFoBCArv + "ZBCGDad"):aCols[ nI, nPZBCArv ])
						aAdd( aItem, { "C7_X_ARROV"     , &( "o" + cPFoBCArv + "ZBCGDad"):aCols[ nI, nPZBCArv ], nil  } )
					EndIf
					If !Empty(&( "o" + cPFoBCToI + "ZBCGDad"):aCols[ nI, nPZBCToI ])
						aAdd( aItem, { "C7_X_TOICM"     , &( "o" + cPFoBCToI + "ZBCGDad"):aCols[ nI, nPZBCToI ], nil  } )
					EndIf
					If !Empty(&( "o" + cPFoBCCor + "ZBCGDad"):aCols[ nI, nPZBCCor ])
						aAdd( aItem, { "C7_X_CORRE"     , &( "o" + cPFoBCCor + "ZBCGDad"):aCols[ nI, nPZBCCor ], nil  } )
					EndIf
					If !Empty(&( "o" + cPFoBCVCM + "ZBCGDad"):aCols[ nI, nPZBCVCM ])
						aAdd( aItem, { "C7_X_COMIS"     , &( "o" + cPFoBCVCM + "ZBCGDad"):aCols[ nI, nPZBCVCM ], nil  } )
					EndIf
					If !Empty(&( "o" + cPFoBCXTT + "ZBCGDad"):aCols[ nI, nPZBCXTT ])
						aAdd( aItem, { "C7_X_TOTAL"    	, &( "o" + cPFoBCXTT + "ZBCGDad"):aCols[ nI, nPZBCXTT ], nil  } )
					EndIf

					If Empty( dDtEntrega := &( "o" + cPFoBCDTE + "ZBCGDad"):aCols[ nI, nPZBCDTE ] )
						dDtEntrega := dDataBase
					EndIf
					aAdd( aItem, { "C7_DATPRF"      , dDtEntrega, nil  } )

					aAdd( aItens, aItem)
				Else
					aItens := {}
					Exit
				EndIf
			EndIf
		Next nI

		If Len(aItens) == 0
			Alert('Não foi localizado Item selecionado na Base Contratual.')

		Else

			cNumPc := GetSxeNum("SC7", "C7_NUM") // U_ProxSC7_SC8()
			aAdd( aCab, { "C7_FILIAL"       , FWxFilial('SC7') 			, nil  } )
			aAdd( aCab, { "C7_NUM"          , cNumPc					, nil  } )
			aAdd( aCab, { "C7_EMISSAO"      , dDataBase					, nil  } )
			aAdd( aCab, { "C7_FORNECE"      , M->ZCC_CODFOR				, nil  } )
			aAdd( aCab, { "C7_LOJA"         , M->ZCC_LOJFOR				, nil  } )
			aAdd( aCab, { "C7_COND"         , ZBCCONDPA 				, nil  } )
			//aAdd( aCab, { "C7_FILENT"       , FWxFilial('SC7') 			, nil  } )
			aAdd( aCab, { "C7_TXMOEDA"      , 0		   					, nil  } )
			aAdd( aCab, { "C7_CONTATO"      , " "    					, nil  } )
			aAdd( aCab, { "C7_MOEDA"        , 1   						, nil  } )

			// FG_X3ORD("C", , aCab   )
			// FG_X3ORD("I", , aItens )

			lMsErroAuto := .F.
			MBSaveLog():FULLWrite(, .F., "Inicio: MATA120() - Inclusão")
			
			MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)}, 1, aCab, aItens, 3)

			If lErro := lMsErroAuto

				cErro := MostraErro()
				If lErro := !At("Deseja enviar email de aprovação para o aprovador?", cErro) > 0

					// lErro := .T.
					RollbackSX8()
					DisarmTransaction()

					MBSaveLog():FULLWrite(, .F., "MATA120() - Inclusão - Erro")

					For nI := 1 to Len(o1ZBCGDad:aCols)
						If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
							&( "o" + cPFoBCPRD + "ZBCGDad"):aCols[ nI, nPZBCPRD ] := CriaVar('ZBC_PRODUT', .F.)
							// oZBCGDad:aCols[ nI, nPZBCDES ] := CriaVar('ZBC_PRDDES', .F.)
						EndIf
					Next nI
				EndIf
			Else
				RecLock('SC7', .F.)
					SC7->C7_TPFRETE := "F"
				SC7->(MsUnLock())
			EndIf

			MBSaveLog():FULLWrite(, .F., "Fim: MATA120() - Inclusão")

			If !lErro

				MBSaveLog():FULLWrite(, .F., "Inicio: xGeraSC7: Preenchendo campos na grid")

				For nI := 1 to Len(o1ZBCGDad:aCols)
					If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
						For nX := 1 to Len(aZBD)
							if aZBD[nX][1] == o1ZBCGDad:aCols[nI][nPZBCPed]
								aZBD[nX][1] := SC7->C7_NUM
								For nJ := 1 to Len(aZBD[nX][2])
									aZBD[nX][2][nJ][3] := SC7->C7_NUM
								Next nJ 
							endif 
						Next nX 
					endif 
				next nI

				o8ZBCGDad:Refresh()

				For nI := 1 to Len(o1ZBCGDad:aCols)
					If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
						// nPZIC := aScan( oZICGDad:aCols, {|x| AllTrim(x[nPZICIte])== o1ZBCGDad:aCols[ nI, nPZBCZIC] })
						nPZIC := nI

						SB1->( DbSetOrder(1) )
						If SB1->( DbSeek( FWxFilial('SB1')+ &( "o" + cPFoBCPRD + "ZBCGDad"):aCols[ nI, nPZBCPRD ] ) )
							RecLock('SB1', .F.)
								SB1->B1_XLOTCOM := FWxFilial('SC7')+SC7->C7_NUM
							SB1->( MsUnlock() )
						EndIf

						//Atualizando ZIC
						// oZICGDad:aCols[ nPZIC, nPZICQFc ] += o1ZBCGDad:aCols[ nI, nPZBCQtd ]

						// Atualizando ZBC
						&( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ] := SC7->C7_NUM
						RepeatFolder( 'ZBC_PEDIDO', SC7->C7_NUM, 1, nI)

						nItem++
						&( "o" + cPFoBCPIt + "ZBCGDad"):aCols[ nI, nPZBCPIt ] := StrZero( nItem, TamSX3('C7_ITEM')[1] ) // SC7->C7_ITEM
						RepeatFolder( 'ZBC_ITEMPC', StrZero( nItem, TamSX3('C7_ITEM')[1] ), 1, nI)
						// &( "o" + cPFoBCPVs + "ZBCGDad"):aCols[ nI, nPZBCPVs ] := "01"

						o1ZBCGDad:aCols[ nI, nPMrkZBC] := "LBNO"
					EndIf
				Next nI

				MBSaveLog():FULLWrite(, .F., "Fim: xGeraSC7: Preenchendo campos na grid")
				
				MBSaveLog():FULLWrite(, .F., "Inicio: xGeraSC7: Envio de email para aprovador")
					// Enviar Email somente qdo executado do ambiente de PRODUÇÃO
					If GetServerIP() == GetMV("MB_IP_PROD",,"192.168.0.242")
						U_ExecAutoOK( FWxFilial('SC7') + SC7->C7_NUM )
					EndIf
				MBSaveLog():FULLWrite(, .F., "Fim: xGeraSC7: Envio de email para aprovador")

				//Adicionado por Renato de Bianchi
				//Verifica se já atendeu ao contrato completamente

				MBSaveLog():FULLWrite(, .F., "Inicio: xGeraSC7: Verificando se contrato foi completamente atendido")

				if M->ZCC_QTDRES == 0
					nQtdAberto := 0
					For nJ := 1 to Len(o1ZBCGDad:aCols)
						If !o1ZBCGDad:aCols[nJ, Len(o1ZBCGDad:aCols[1]) ] .and. Empty( &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ &( "o" + cPFoBCPed + "ZBCGDad"):nAt, nPZBCPed ])
							nQtdAberto++
						EndIf
					Next i
					if nQtdAberto == 0
						if msgYesNo("A quantidade de animais foi atendida totalmente, deseja encerrar este contrato?")
							cTxt := " "
							if !empty(AllTrim(M->ZCC_OBS))
								cTxt += AllTrim(M->ZCC_OBS) +chr(10)+chr(13)+chr(10)+chr(13)
							endIf
							cTxt += "***** FECHAMENTO DO CONTRATO *****" +chr(10)+chr(13)
							cTxt += "*DATA: "+dToC(date()) +chr(10)+chr(13)
							cTxt += "*OPERADOR: "+AllTrim(__cUserId) + " - " + AllTrim(UsrRetName(__cUserId)) +chr(10)+chr(13)
							cTxt += padr('*',50,'*')+chr(10)+chr(13)
							cTxt += " FECHAMENTO POR ATENDIMENTO A QUANTIDADE DE ANIMAIS"

							M->ZCC_STATUS := "F"
							M->ZCC_OBS := cTxt

							RecLock('ZCC', .F.)
								ZCC->ZCC_STATUS := "F"
								ZCC->ZCC_OBS := cTxt
							ZCC->( MsUnLock() )
						endIf
					endIf
				endIf
				MBSaveLog():FULLWrite(, .F., "Fim: ZBCFieldOK: Verificando se contrato foi completamente atendido")

				// Fim das alterações
				MBSaveLog():FULLWrite(, .F., "ZBCFieldOK: GrvTable")
				GrvTable()

				MBSaveLog():FULLWrite(, .F., "ZBCFieldOK: ConfirmSX8")
				ConfirmSX8()
				// DisarmTransaction() // esta funcao precisa ser retirada daqui, somente para DESENVOLVIMENTO;
									// ambiente de desenvolvimento INOPERANTE;

				For nF := 1 to len(aFolderG) // REFRESH ABAS - ATUALIZA ABAS
					&( "o" + cValToChar(nF) + "ZBCGDad" ):Refresh()
				Next nF

			EndIf
		EndIf
		MBSaveLog():FULLWrite(, .F., "xGeraSC7: Fim da Transação")
	End Transaction

	MBSaveLog():FULLWrite(, .F., "Fim: xGeraSC7()")


RestArea(aArea)

Return lErro

/* MJ : 17.11.2017
	# Separei em Funcao, para chamar para gravar as tabelas após oBrowse
		ExecAuto
	*/
Static Function GrvTable()
	Local nI 		:= 0
	Local nF 		:= 0
	Local nX 		:= 0 
	Local nZ 		:= 0
	Local lRecLock	:= .T.

	MBSaveLog():FULLWrite(, .F., "Inicio: GrvTable()")
	// Salvar contrato
	RecLock( "ZCC", .F. )
		U_GrvCpo("ZCC")
		ZCC->ZCC_TPCONT := "A"
	ZCC->(MsUnlock())

	/// Tabela 2 - Rodapé
	For nI := 1 to Len(o1ZBCGDad:aCols)
		If !o1ZBCGDad:aCols[nI, Len(o1ZBCGDad:aCols[1]) ] ;
				.AND. !Empty( &( "o" + cPFoBCITE + "ZBCGDad"):aCols[ nI, nPZBCITE ] ) // ;
				// .AND. !Empty( &( "o" + cPFoBCZIC + "ZBCGDad"):aCols[ nI, nPZBCZIC ] )

			DbSelectArea( "ZBC" )
			ZBC->( DbSetOrder( 3 ) )
			RecLock( "ZBC", lRecLock := !(ZBC->(DbSeek( FWxFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + &( "o" + cPFoBCITE + "ZBCGDad"):aCols[nI, nPZBCITE] /* + o1ZBCGDad:aCols[nI, nPZBCZIC] + o1ZBCGDad:aCols[nI, nPZBCPed] + o1ZBCGDad:aCols[nI, nPZBCPIt] + o1ZBCGDad:aCols[nI, nPZBCPVs] */ ) )))
				For nF := 1 to len(aFolderG)
					U_GrvCpo( "ZBC", ;
							&( "o" + cValToChar(nF) + "ZBCGDad" ):aCols, ;
							&( "o" + cValToChar(nF) + "ZBCGDad" ):aHeader, nI )
				Next nF

				If lRecLock
					ZBC->ZBC_FILIAL := FWxFilial("ZBC")
					ZBC->ZBC_CODIGO := M->ZCC_CODIGO
					ZBC->ZBC_VERSAO := M->ZCC_VERSAO
					ZBC->ZBC_CODFOR := M->ZCC_CODFOR
					ZBC->ZBC_LOJFOR := M->ZCC_LOJFOR
					ZBC->ZBC_VERPED := '01'
					ZBC->ZBC_USUARI := cUserName
					ZBC->ZBC_DTALT  := Date()
				EndIf
			ZBC->( MsUnlock() )
		EndIf
	Next nI

	DbSelectArea( "ZBD" )
	ZBD->( DbSetOrder(1) )
	For nX := 1 to Len(aZBD)
		if !aZBD[nX][2][1][4] 
			For nZ := 1 to Len(aZBD[nX][2])
				RecLock("ZBD", lRecLock := !(ZBD->(DbSeek( FWxFilial("ZBD") + M->ZCC_CODIGO + M->ZCC_VERSAO + aZBD[nX][3] + aZBD[nX][2][nZ][1] ) )))
					ZBD->ZBD_FILIAL	:= FWxFilial("ZBD")
					//SAZBD->ZBD_RECZBC	:= o1ZBCGDad:aCols[nI,Len(o1ZBCGDad:aHeader)]
					ZBD->ZBD_ITEM	:= aZBD[nX][2][nZ][1]
					ZBD->ZBD_DATA	:= aZBD[nX][2][nZ][2]
					ZBD->ZBD_FOR	:= M->ZCC_CODFOR
					ZBD->ZBD_LOJA	:= M->ZCC_LOJFOR
					ZBD->ZBD_CODZCC	:= M->ZCC_CODIGO
					ZBD->ZBD_ZCCVER	:= M->ZCC_VERSAO
					ZBD->ZBD_CODPED	:= aZBD[nX][1]
				ZBD->(MsUnlock())
				aZBD[nX][3] := aZBD[nX][1]
			next nZ
		endif
	Next nX
	o1ZBCGDad:Refresh()

	MBSaveLog():FULLWrite(, .F., "Fim: GrvTable()")

Return nil

/* MJ : 17.11.2017
	Funcao para Fechar Contrato em Versoes anteriores
 */
Static Function FechaContrato( cContrato, cVersao, nOpc )
	Local aArea 	:= GetArea()
	Local nI 		:= 1
	Default nOpc	:= 4

	MBSaveLog():FULLWrite(, .F., "Inicio: FechaContrato( '"+cContrato+"', '"+cVersao+"', "+cValToChar(nOpc)+" )")
	
	ZCC->(DbSetOrder(1))
	for nI := 1 to Val(cVersao)-1
		If ZCC->(DbSeek( FWxFilial('ZCC')+cContrato+StrZero( nI, TamSX3('ZCC_VERSAO')[1] )  ))
			RecLock('ZCC',.F.)
				ZCC->ZCC_STATUS := iif(nOpc == 6, "V", "F")
			ZCC->(MsUnlock())
		EndIf
	next nI
	
	MBSaveLog():FULLWrite(, .F., "Fim: FechaContrato( '"+cContrato+"', '"+cVersao+"', "+cValToChar(nOpc)+" )")
	
	RestArea(aArea)
Return nil


/* MJ : 20.11.2017
	Validar Sexo informado x selecionado na tabela ZIC;
	*/
User Function icProdVld()
	Local lRet  := .F.
	Local cSexo := ""

	MBSaveLog():FULLWrite(, .F., "Inicio: icProdVld()")

	If ISINCALLSTACK("U_VACOMM12")
		Return .T.
	EndIf

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek( FWxFilial('SB1')+ &(ReadVar()) ))
		cSexo := Iif(o1ZBCGDad:aCols[ o1ZBCGDad:nAt, nPZBCSxo]=="C","M", o1ZBCGDad:aCols[ o1ZBCGDad:nAt, nPZBCSxo] )
		If SubS(SB1->B1_X_SEXO,1,1) == cSexo
			lRet := .T.
		Else
			Aviso("Aviso", ;
				"O Produto informado: " + AllTrim(&(ReadVar())) + ": "+ AllTrim(SB1->B1_DESC)+ ;
				" não é do sexo informado nesta configuração.", ;
				{"Sair"} )
		EndIf
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: icProdVld()")

Return lRet

User Function fSXB_SB1G02()
	Local lRet  := .T.
	Local cSexo := Iif(o1ZBCGDad:aCols[ o1ZBCGDad:nAt, nPZBCSxo] == "C", "M", o1ZBCGDad:aCols[ o1ZBCGDad:nAt, nPZBCSxo] )

	MBSaveLog():FULLWrite(, .F., "Inicio: fSXB_SB1G02()")


	lRet := AllTrim( SB1->B1_GRUPO ) == "01" .AND. SUBS(SB1->B1_X_SEXO,1,1) == cSexo // o1ZBCGDad:aCols[o1ZBCGDad:nAt, nPZBCSxo]

	MBSaveLog():FULLWrite(, .F., "Fim: fSXB_SB1G02()")

Return lRet


/* ===================================================================== */
/* MJ : 27.11.2017 */
/* ===================================================================== */
User Function ExecAutoOK( cChave )
	Local aAnexo    := {}
	Local aPara	    := {}
	Local cPara     := ""
	Local cQuery	:= ""
	Local xHTM 	  	:= ""
	Local cTelEmp 	:= "("+Substr(SM0->M0_TEL,4,2)  +;
					") "+Substr(SM0->M0_TEL,7,4) +;
					"-"+Substr(SM0->M0_TEL,11,4)

	Local cJobChv	:= 'JOB03' 	// codigo da chave na tabela da sx5, pra incluir emails para envio do job
	Local cJobSX5	:= 'Z2'		// tabela da SX5 onde serao selecionados os emails para envio

	Local C7XCOMIS  := 0
	Local C7QUANT   := 0
	Local C7XPESO   := 0
	Local C7XTOTAL  := 0
	Local C7XTOICM  := 0
	Local C7TOTGERAL := 0

	Local JOBMAIL   := CriaTrab(,.F.)

	MBSaveLog():FULLWrite(, .F., "Inicio: ExecAutoOK( '"+cChave+"' )")

	DbSelectArea('SC7')
	SC7->(DbSetOrder(1))

	if FWxFilial('SC7')+SC7->C7_NUM+SC7->C7_ITEM <> cChave + StrZero( 1, TamSX3('C7_ITEM')[1] )
		SC7->(DbSeek(cChave))
	Endif

	xHTM := '<HTML><BODY>' + CRLF
	xHTM += '<hr>' + CRLF
	xHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">' + CRLF
	xHTM += '<b><font face="Verdana" SIZE=3>' + SM0->M0_NOMECOM + '</b></p>' + CRLF
	xHTM += '<br>' + CRLF
	xHTM += '<font face="Verdana" SIZE=3>' + AllTrim( SM0->M0_ENDENT )+ " - "+AllTrim(SM0->M0_BAIRENT)+ " - CEP: "+AllTrim(SM0->M0_CEPENT)+ " - Fone/Fax: "+ cTelEmp + '</p>' + CRLF
	xHTM += '<hr>' + CRLF
	xHTM += '<b><font face="Verdana" SIZE=3>Inclusao de Pedido de Compra: ' + SC7->C7_FILIAL+ "-"+SC7->C7_NUM +'</b></p>' + CRLF
	xHTM += '<hr>' + CRLF
	xHTM += '<font face="Verdana" SIZE=1>* * *  com base no campo data de entrega no item do pedido de compras (somente liberados) * * * [VAJOB11]</p>' + CRLF
	xHTM += '<br>' + CRLF
	xHTM += '<font face="Verdana" SIZE=3>Data: ' + dtoc(date()) + ' Hora: ' + time() + '</p>' + CRLF
	xHTM += '<br>' + CRLF
	xHTM += '<br>' + CRLF
	xHTM += '<b><font face="Verdana" SIZE=1>' + CRLF
	// Cabecalho Pedido
	xHTM += '<table BORDER=1>' + CRLF
	xHTM += '<tr BGCOLOR=#2F4F4F >' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Filial</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Pedido</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Emissao</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Fornecedor</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Municipio/UF</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Corretor</b></font></td>' + CRLF
	xHTM += '</tr>'	 + CRLF

	xHTM += '<tr>' + CRLF
	xHTM += '<td>' + SC7->C7_FILIAL+'</td>' + CRLF
	xHTM += '<td>' + SC7->C7_NUM+'</td>' + CRLF
	xHTM += '<td>' + DtoC(SC7->C7_EMISSAO)+'</td>' + CRLF
	xHTM += '<td align=left>' + SC7->C7_FORNECE+ "-"+SC7->C7_LOJA+ ": "+AllTrim(Posicione('SA2',1, FWxFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA, 'A2_NOME' )) + '</td>' + CRLF
	xHTM += '<td align=left>' + AllTrim(SA2->A2_MUN) + "-" + SA2->A2_EST + '</td>' + CRLF
	xHTM += '<td align=left>' + AllTrim(Posicione('SA3',1, FWxFilial('SA3')+SC7->C7_X_CORRE, 'A3_NOME' )) + '</td>' + CRLF
	xHTM += '</tr>'	 + CRLF
	// cC7Obs		:= 	u_SC7OBS(SC7->C7_FILIAL, SC7->C7_NUM)

	cC7Obs		:= 	M->ZCC_OBS
	If !Empty(cC7Obs)
		xHTM += '<tr>' + CRLF
		xHTM += '<font face="Arial" SIZE=3> <td colspan=6><br>' + cC7Obs+'<br><br> </td>' + CRLF
		xHTM += '</tr>'	 + CRLF
	Endif

	xHTM += '</table>' + CRLF

	xHTM += '<b><font face="Verdana" SIZE=1>' + CRLF
	xHTM += '<table BORDER=1>' + CRLF
	xHTM += '<tr BGCOLOR=#778899 >' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Item/Produto</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Valor Comissao</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Quantidade</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Peso Negociação</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Peso Médio</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>R$ / @</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>% Rendimento</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Total sem Icms</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Total ICMS</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Total com ICMS + Comissao</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Previsao Entrega</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Dias</b></font></td>' + CRLF
	xHTM += '<td><b><font color=#F5F5F5>Obs</b></font></td>' + CRLF
	xHTM += '</tr>'	 + CRLF


	While !SC7->(Eof()) .and. FWxFilial('SC7')+SC7->C7_NUM == cChave

		xHTM += '<tr>' + CRLF
		xHTM += '<td>' + AllTrim(SC7->C7_DESCRI)+'</td>' + CRLF
		C7XCOMIS 	+= SC7->C7_X_COMIS
		xHTM += '<td align=right>' + Transform(SC7->C7_X_COMIS,"@E 999,999,999.999")+'</td>' + CRLF
		C7QUANT		+= SC7->C7_QUANT
		xHTM += '<td align=right>' + Transform(SC7->C7_QUANT,"@E 999,999,999.999")+'</td>' + CRLF
		C7XPESO		+= SC7->C7_X_PESO
		xHTM += '<td align=right>' + Transform(SC7->C7_X_PESO,"@E 999,999,999.999")+'</td>' + CRLF
		xHTM += '<td align=right>' + Transform(Round( SC7->C7_X_PESO/SC7->C7_QUANT, TamSX3("C7_X_PESO")[2]),"@E 999,999.999")+'</td>' + CRLF
		xHTM += '<td align=right>' + Transform(SC7->C7_X_ARROV,"@E 999,999,999.999")+'</td>' + CRLF
		xHTM += '<td align=right>' + Transform(SC7->C7_X_REND,"@E 999,999,999.999")+'</td>' + CRLF
		C7XTOTAL 	+= SC7->C7_X_TOTAL
		xHTM += '<td align=right>' + Transform(SC7->C7_X_TOTAL,"@E 999,999,999.99")+'</td>' + CRLF
		C7XTOICM	+= SC7->C7_X_TOICM
		xHTM += '<td align=right>' + Transform(SC7->C7_X_TOICM,"@E 999,999,999.99")+'</td>' + CRLF
		C7TOTGERAL	+= SC7->C7_X_TOTAL + SC7->C7_X_TOICM + SC7->C7_X_COMIS
		xHTM += '<td  align=right>' + Transform(SC7->C7_X_TOTAL+SC7->C7_X_TOICM+SC7->C7_X_COMIS,"@E 999,999,999.99")+'</td>'	 + CRLF
		xHTM += '<td>' + dToC(SC7->C7_DATPRF)+'</td>' + CRLF
		xHTM += '<td align=right>' + Transform((SC7->C7_DATPRF - DATE()) ,"@E 999,999")+'</td>' + CRLF
		xHTM += '<td align=right>' + SC7->C7_OBS +'</td>' + CRLF
		xHTM += '</tr>'	 + CRLF

		SC7->( DbSkip())
	EndDo

	xHTM += '<tr BGCOLOR=#CFCFCF >' + CRLF // gray 81
	xHTM += '<td><b>Sub-Total Pedido: ' + cChave +'</b></td>' + CRLF
	xHTM += '<td align=right><b>' + Transform( C7XCOMIS, "@E 999,999,999.99")+'</b></td>' + CRLF
	xHTM += '<td align=right><b>' + Transform( C7QUANT , "@E 999,999,999.99")+'</b></td>' + CRLF
	xHTM += '<td align=right><b>' + Transform( C7XPESO , "@E 999,999,999")+'</b></td>' + CRLF
	xHTM += '<td align=right><b> </b></td>' + CRLF
	xHTM += '<td align=right><b> </b></td>' + CRLF
	xHTM += '<td align=right><b> </b></td>' + CRLF
	xHTM += '<td align=right><b>' + Transform( C7XTOTAL, "@E 999,999,999.99")+'</b></td>' + CRLF
	xHTM += '<td align=right><b>' + Transform( C7XTOICM,"@E 999,999,999.99")+'</b></td>' + CRLF
	xHTM += '<td align=right><b>' + Transform( C7TOTGERAL,"@E 999,999,999.99")+'</b></td>' + CRLF
	xHTM += '<td colspan="3" align=left>_</td>' + CRLF
	xHTM += '</tr>'	 + CRLF

	xHTM += '</table>' + CRLF// fim da tabela de pedidos
	xHTM += '<br>' + CRLF
	xHTM += '<br>' + CRLF
	xHTM += '<br>' + CRLF
	xHTM += '</BODY></HTML>' + CRLF

	MemoWrite( "C:\totvs_relatorios\VACOMM11_" + cChave + ".html", xHTM )

	cAssunto := "Contrato: " + M->ZCC_CODIGO + " - Pedido de compra: " + cChave
	aAdd( aAnexo, { "LogoTipo", "\workflow\images\logoM.jpg" } )

	// cCopia  := "financeiro@vistaalegre.agr.br"
	cQuery := " SELECT X5_CHAVE, X5_DESCRI "
	cQuery += " FROM "+RetSqlName('SX5')+ " SX5 "
	cQuery += " WHERE X5_TABELA = '"+cJobSX5+ "' "
	cQuery += " AND SUBSTRING(X5_CHAVE,1,5)  = '"+cJobChv+ "'  "
	cQuery += " AND D_E_L_E_T_<>'*' "
	cQuery += " ORDER BY X5_CHAVE "

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, cQuery ),(JOBMAIL),.F.,.F.)

	xEmail := ""
	While !(JOBMAIL)->(Eof())

		xEmail  += Iif(Empty(xEmail),"",", ") + alltrim(lower( (JOBMAIL)->X5_DESCRI))

		(JOBMAIL)->(dbSkip())
	EndDo

	If !Empty(xEmail)
		ConOut("VACOMM11: Para: "+ xEmail )
		Processa({ || u_EnvMail( Lower(xEmail)	   ,;
						/* cCopia */ 	           ,;
						""				           ,;
						cAssunto			       ,;
						aAnexo 		           ,;
						xHTM			           ,;
						.T.)},"Enviando e-mail...")
	EndIf

	(JOBMAIL)->(dbCloseArea())

	MBSaveLog():FULLWrite(, .F., "Fim: ExecAutoOK( '"+cChave+"' )")

Return nil


/*
Função adicionada por Renato de Bianchi
Valida a quantidade de animais para não permitir reduzir seu valor abaixo da somatória de pedidos gerados
*/
/*
user function vlZCCQtA()
local lRet := .T.
local nQtdUsada := 0

	//Valida a quantidade em relacao aos itens
	For nI := 1 to Len(oZICGDad:aCols)
		If !oZICGDad:aCols[nI][ Len(oZICGDad:aCols[1]) ] .AND. !Empty( oZICGDad:aCols[ 1,2] )
			nQtdUsada += oZICGDad:aCols[nI, nPZICQtd]
		EndIf
	Next i
	if M->ZCC_QTTTAN < nQtdUsada
		lRet := .F.
		Alert("Quantidade informada é menor que a quantidade dos itens.")
	endIf

	//Define a quantidade restante (ZCC_QTDRES)
	if lRet
		nQtdUsada := 0
		For nI := 1 to Len(o1ZBCGDad:aCols)
			If !o1ZBCGDad:aCols[nI][ Len(o1ZBCGDad:aCols[1]) ]
				nQtdUsada += o1ZBCGDad:aCols[nI, nPZBCQtd]
			EndIf
		Next i
		M->ZCC_QTDRES := M->ZCC_QTTTAN - nQtdUsada
	endIf

return lRet
*/

// -------------------------------------------------------------------------------------------
User Function xAltStatus(cStatus)
	Local lRet := .T.
	Local oDlgTmp	:= nil
	Local oMonoAs 	:= TFont():New( "Courier New",6,0) 	// Fonte para o campo Memo
	Local nI := 0

	Default cStatus := "F"

	Private cMotivo := " "
	Private cTitDlg := iif(cStatus=="F", "Fechamento do contrato", "Cancelamento do contrato")
	Private aPeds := {}

	MBSaveLog():FULLWrite(, .F., "Inicio: xAltStatus( '"+cStatus+"' )")

	If cStatus == "F"
		if !ZCC->ZCC_STATUS$'AN'
			Alert('Não é possível alterar contratos cancelados ou fechados.')
			return .F.
		endIf
	endIf

	//Valida se tem pedido atendido
	beginSQL alias "QRYTMP"
		%noParser%
		select *
		from %table:ZBC% ZBC
		join %table:SC7% SC7 on (C7_FILIAL=%xFilial:SC7% and SC7.%notDel% and C7_NUM=ZBC_PEDIDO and C7_ITEM=ZBC_ITEMPC and C7_RESIDUO=' ')
		where ZBC_FILIAL=%xFilial:ZBC% and ZBC.%notDel%
		and ZBC_CODIGO=%exp:ZCC->ZCC_CODIGO% and ZBC_VERSAO=%exp:ZCC->ZCC_VERSAO%
		and ZBC_PEDIDO <> '      '
	endSQL
	if !QRYTMP->(Eof())
		while !QRYTMP->(Eof())
			nSldPed := QRYTMP->C7_QUANT - QRYTMP->C7_QUJE
			if nSldPed > 0
				aAdd(aPeds, QRYTMP->C7_NUM)
			endIf

			QRYTMP->(dbSkip())
		endDo
	endIf
	QRYTMP->(dbCloseArea())

	lConfExc := .F.

	if len(aPeds) > 0
		if !msgYesNo("O contrato atual possui pedidos de compra gerados em aberto, deseja continuar?")
			return .F.
		else
			lConfExc := .T.
		endIf
	endIf

		DEFINE MSDIALOG oDlgTmp TITLE OemToAnsi(cTitDlg) From 05,10 TO 262,620	PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )
			oDlgTmp:lEscClose := .F.

			@  2,4 TO 25,302 LABEL "Informações do Contrato" OF oDlgTmp PIXEL

			@ 10,07 SAY "Contrato: "+ZCC->ZCC_CODIGO  SIZE  150,8 OF oDlgTmp PIXEL
			@ 10,90 SAY "Versão: "+ZCC->ZCC_VERSAO  SIZE  150,8 OF oDlgTmp PIXEL
			@ 16,07 SAY "Fornecedor: "+ZCC->ZCC_CODFOR+ "/"+ZCC->ZCC_LOJFOR+ " - "+ZCC->ZCC_NOMFOR SIZE  250,8 OF oDlgTmp PIXEL

			@ 26,4 TO 111,302 LABEL "Motivo do " + cTitDlg OF oDlgTmp PIXEL //"Descri‡ao do Encerramento"
			@ 35,8 GET oMotivo VAR cMotivo OF oDlgTmp MEMO SIZE 290,70 PIXEL //When lHabil
			oMotivo:oFont := oMonoAs

		DEFINE SBUTTON FROM 115,230 TYPE 2 ACTION (lRet:=.F., oDlgTmp:End()) ENABLE OF oDlgTmp
		DEFINE SBUTTON FROM 115,270 TYPE 1 ACTION (lRet:=.T., oDlgTmp:End()) ENABLE OF oDlgTmp

		ACTIVATE MSDIALOG oDlgTmp CENTER

		if lRet
			if msgYesNo("O contrato não poderá ser alterado após esta operação, deseja continuar?")
				cTxt := " "
				if !empty(AllTrim(ZCC->ZCC_OBS))
					cTxt += AllTrim(ZCC->ZCC_OBS) +chr(10)+chr(13)+chr(10)+chr(13)
				endIf
				cTxt += "**********"+upper(cTitDlg)+ "**********" +chr(10)+chr(13)
				cTxt += "*DATA: "+dToC(date()) +chr(10)+chr(13)
				cTxt += "*OPERADOR: "+AllTrim(__cUserId) + " - " + AllTrim(UsrRetName(__cUserId)) +chr(10)+chr(13)
				if lConfExc .and. cStatus="C"
					cTxt += "**EXCLUSAO DE PEDIDOS - Usuario confirmou a exclusao dos pedidos em aberto**" +chr(10)+chr(13)
				endIf
				if lConfExc .and. cStatus="F"
					cTxt += "**Usuario confirmou o encerramento parcial do contrato que possui pedidos em aberto**" +chr(10)+chr(13)
				endIf
				cTxt += padr('*',60,'*')+chr(10)+chr(13)
				cTxt += cMotivo

				if cStatus="F" .and. (lConfExc .or. ZCC->ZCC_QTDRES > 0)
					cStatus := "P"
				endIf

				RecLock('ZCC', .F.)
					ZCC->ZCC_STATUS := cStatus
					ZCC->ZCC_OBS := cTxt
				msUnLock()

				if cStatus="C" .and. len(aPeds) > 0 .and. lConfExc
					for nI := 1 to len(aPeds)
					// 	u_xElResPC(aPeds[nI])
						ReajusteResiduo( aPeds[nI] )
					next
				endIf
			endIf
		endIf

	MBSaveLog():FULLWrite(, .F., "Fim: xAltStatus( '"+cStatus+"' )")

Return nil

/* MB : 02.06.2022 */
Static Function ReajusteResiduo( cPedido )
	Local aArea      := GetArea()
	Local lRet       := .T.
	Local aRecSC7    := {}
	Local aNumSC7    := {}
	Local lIntegDef  := .F.
	Local n1Cnt      := 0
	Local nI         := 0
	Local aRet       := {}
	Local cMsgRet    := ""
	Local lConsEIC   := SuperGetMV("MV_ELREIC",.F.,.T.)
	Local cPerg      := "MTA235"
	// Local nUltimo    := len(o1ZBCGDad:aCols)
	// Local cPedido	 := o1ZBCGDad:aCols[ nUltimo, aScan( o1ZBCGDad:aHeader, { |x| x[2] == "ZBC_PEDIDO"} ) ]
	Local _cQry	     := ""
	Local _cAlias	 := GetNextAlias()
	Local xNovo		 := .F.

	PRIVATE lMT235G1 := existblock("MT235G1")

		MBSaveLog():FULLWrite(, .F., "Inicio: ReajusteResiduo( '"+cPedido+"' )")

		If Empty(cPedido)
			ShowHelpDlg("VACOMM1201",;
						{"Pedido " + cPedido + " não localizado, por isso não sera possivel continuar com a rotina: ELIMINIAR RESIDUO."}, 1,;
						{"Esta operação sera cancelada !"}, 1)
		Else

			If msgYesNo("Esta operação ira fechar o pedido: "+FWxFilial('ZCC') + "-" + cPedido +;
						". Deseja continuar?")

				pergunte(cPerg, .F.) // pergunte("MTA235",.F.)

				/*
				U_PosSX1({ { cPerg, "01", 100 },; // 01-Percentual Maximo ?
						{ cPerg, "02", ZCC->ZCC_DTCONT },; //02-Data de Emissao de ?
						{ cPerg, "03", dDataBase },; // 03-Data de Emissao ate ?
						{ cPerg, "04", cPedido },; // 04-Solic/Pedido de ?
						{ cPerg, "05", cPedido },; // 05-Solic/Pedido ate' ?
						{ cPerg, "11", ZCC->ZCC_DTCONT },; // 11-Data de Entrega de ?
						{ cPerg, "12", dDataBase } } ) // 12-Data de entrega ate ?
				*/
				MV_PAR01 := 100
				MV_PAR02 := ZCC->ZCC_DTCONT
				MV_PAR03 := dDataBase
				MV_PAR04 := cPedido
				MV_PAR05 := cPedido
				MV_PAR06 := "                                                            "
				MV_PAR07 := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
				MV_PAR08 := 1
				MV_PAR09 := "                                                            "
				MV_PAR10 := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
				MV_PAR11 := ZCC->ZCC_DTCONT
				MV_PAR12 := dDataBase
				MV_PAR13 := "                                                            "
				MV_PAR14 := "                                                            "
				MV_PAR15 := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
				MV_PAR16 := "                                                            "
				MV_PAR17 := "                                                            "

				//Verifica se existe bloqueio contábil
				If lRet
					lRet := CtbValiDt(Nil,dDataBase,/*.T.*/ ,Nil ,Nil ,{"COM001"}/*,"Data de apuração bloqueada pelo calendário contábil."*/)
				EndIf

				If lRet
					Begin Transaction

						Processa({|lEnd| MA235PC(mv_par01,mv_par08,mv_par02,mv_par03,mv_par04,mv_par05,;
													mv_par06,mv_par07,mv_par09,mv_par10,mv_par11,mv_par12,;
													mv_par14,mv_par15,lConsEIC,aRecSC7)})
						/*If mv_par08 == 1 //Pedido de compra
							lIntegDef	:=  FWHasEAI("MATA120",.T.,,.T.)
							If	lIntegDef
								If Len(aRecSC7) > 0
									//-- Somente PC processada pela funcao MA235PC
									For n1Cnt := 1 To Len(aRecSC7)
										SC7->(DbGoTo(aRecSC7[n1Cnt]))

										lIntReg := INTREG("SC7",SC7->C7_NUM)
										If Ascan(aNumSC7,SC7->C7_NUM) == 0 .And. lIntReg
											AAdd(aNumSC7,SC7->C7_NUM)
											Inclui := .T.
											Altera := .T.
											aRet := FwIntegDef( 'MATA120' )

											If Valtype(aRet) == "A"
												If Len(aRet) == 2
													If !aRet[1]
														If Empty(AllTrim(aRet[2]))
															cMsgRet := STR0011
														Else
															cMsgRet := AllTrim(aRet[2])
														Endif
														Aviso(STR0010,cMsgRet,{STR0013},3)
														DisarmTransaction()
														Return .F.
													Endif
												Endif
											Endif
										EndIf
									Next n1Cnt
								Endif
							EndIf
						Endif*/

						// _cQry := " SELECT  SUM(D1_QUANT) QUANT" + CRLF
						// _cQry += " FROM    SD1010" + CRLF
						// _cQry += " WHERE	D1_FILIAL+D1_PEDIDO+D1_ITEMPC = '" + FWxFilial('ZBC')+&( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nUltimo, nPZBCPed ]+&( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nUltimo, nPZBCPIt ] + "'" + CRLF
						// _cQry += " 	AND D_E_L_E_T_=' '"
	//
						// If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
						// 	MemoWrite("C:\totvs_relatorios\ReajusteResiduo1.sql" , _cQry)
						// EndIf
	//
						// dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)
						// // _D1QUANT := 0
						// If !(_cAlias)->(Eof())
						// 	// _D1QUANT := Posicione('SD1', 22, "010284590001", "D1_QUANT")
						// 	&( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nUltimo, nPZBCQtd ] := (_cAlias)->QUANT //_D1QUANT
						// 	U_miZBCFieldOK('ZBC_QUANT', (_cAlias)->QUANT, nUltimo )
						// EndIf
						// (_cAlias)->(DbCloseArea())
	//
						_cQry := " WITH " + CRLF
						_cQry += " CONTRATO AS (" + CRLF
						_cQry += " 	SELECT  ZBC_FILIAL+ZBC_PEDIDO+ZBC_ITEMPC CHAVE, ZCC_QTTTAN, SUM(ZBC_QUANT) TOTAL" + CRLF
						_cQry += " 	FROM    ZCC010 CC" + CRLF
						_cQry += " 	JOIN ZBC010 BC ON ZCC_FILIAL+ZCC_CODIGO=ZBC_FILIAL+ZBC_CODIGO" + CRLF
						_cQry += " 					AND CC.D_E_L_E_T_=' ' AND BC.D_E_L_E_T_=' '" + CRLF
						_cQry += " 	WHERE	ZBC_FILIAL+ZBC_CODIGO='" + FWxFilial('ZCC') + ZCC->ZCC_CODIGO + "'" + CRLF
						_cQry += " 	GROUP BY ZBC_FILIAL+ZBC_PEDIDO+ZBC_ITEMPC, ZCC_QTTTAN" + CRLF
						_cQry += " )," + CRLF
						_cQry += " " + CRLF
						_cQry += " PEDIDOS AS (" + CRLF
						_cQry += " 	SELECT  C7_FILIAL+C7_NUM+C7_ITEM CHAVE," + CRLF
						_cQry += " 			SUM(CASE C7_ENCER" + CRLF
						_cQry += " 				WHEN 'E'" + CRLF
						_cQry += " 					THEN C7_QUJE" + CRLF
						_cQry += " 					ELSE C7_QUANT" + CRLF
						_cQry += " 			END) TOTAL" + CRLF
						_cQry += " 	FROM	SC7010" + CRLF
						_cQry += " 	WHERE	C7_FILIAL+C7_NUM+C7_ITEM IN (" + CRLF
						_cQry += " 		SELECT ZBC_FILIAL+ZBC_PEDIDO+ZBC_ITEMPC" + CRLF
						_cQry += " 		FROM    ZBC010" + CRLF
						_cQry += " 		WHERE	ZBC_FILIAL+ZBC_CODIGO='" + FWxFilial('ZCC') + ZCC->ZCC_CODIGO + "'" + CRLF
						_cQry += " 			AND D_E_L_E_T_=' '" + CRLF
						_cQry += " 		)" + CRLF
						_cQry += " 		AND D_E_L_E_T_=' '" + CRLF
						_cQry += " 	GROUP BY C7_FILIAL+C7_NUM+C7_ITEM" + CRLF
						_cQry += " )" + CRLF
						_cQry += " " + CRLF
						_cQry += " SELECT  -- C.CHAVE, " + CRLF
						_cQry += " 		ZCC_QTTTAN - " + CRLF
						_cQry += " 		-- , C.TOTAL" + CRLF
						_cQry += " 		sum(P.TOTAL) RESTANTE" + CRLF
						_cQry += " FROM	CONTRATO C" + CRLF
						_cQry += " JOIN PEDIDOS  P ON C.CHAVE=P.CHAVE" + CRLF
						_cQry += " GROUP BY ZCC_QTTTAN" + CRLF

						If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
							MemoWrite("C:\totvs_relatorios\ReajusteResiduo2.sql" , _cQry)
						EndIf

						dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

						// If (xNovo := o1ZBCGDad:AddLine())
						// 	For nI := 1 to Len(o1ZBCGDad:aHeader)
						// 		If AllTrim(o1ZBCGDad:aHeader[ nI, 2 ]) == 'ZBC_QUANT'
						// 			If !(_cAlias)->(Eof())
						// 				o1ZBCGDad:aCols[ nUltimo+1, nI] := (_cAlias)->RESTANTE
						// 			EndIf
						// 		ElseIf !AllTrim(o1ZBCGDad:aHeader[ nI, 2 ]) $ ('ZBC_PEDIDO,ZBC_ITEMPC')
						// 			o1ZBCGDad:aCols[ nUltimo+1, nI] := o1ZBCGDad:aCols[ nUltimo, nI]
						// 		EndIf
						// 	Next nI
						// 	o1ZBCGDad:ForceRefresh()

						RecLock('ZCC', .F.)
							ZCC->ZCC_QTDRES := (_cAlias)->RESTANTE
						ZCC->(MsUnLock())

						// 	oMGet:Refresh()
						// 	U_miZBCFieldOK('ZBC_QUANT', (_cAlias)->RESTANTE, nUltimo+1 )
						// EndIf
						(_cAlias)->(DbCloseArea())

						Aviso("Aviso", ;
							"Eliminação realizada com sucesso !!!", ;
							{"Sair"} )

					End Transaction

					// If xNovo
					// 	GrvTable()
					// EndIf
				EndIf
			// Else
			EndIf
		EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: ReajusteResiduo( '"+cPedido+"' )")

	RestArea(aArea)
Return nil


//Validação da exclusão da linha da base contratual (Pedido)
user function ZBCDelOk(oObj)
	Local lRet     	:= .T.
	Local nI 	   	:=  0
	Local nX 	   	:=  0
	Local nAt      	:= oObj:oBrowse:nAt
	Local nPedido	:= oObj:aCols[nAt][Len(oObj:aHeader)]

	MBSaveLog():FULLWrite(, .F., "Inicio: ZBCDelOk()")

	if !empty(oObj:aCols[ nAt, nPZBCPed])
		Alert("Não é possível deletar um registro com pedido já gerado")
		return .F.
	else
		//for nI := 1 to len(aZBD)
		//	if nPedido == aZBD[nI][1]
		//		For nX := 1 to Len(aZBD[nI][2])
		//			aZBD[nI][2][nX][5] := !(aZBD[nI][2][nX][5])
		//		Next nX
		//		o8ZBCGDad:setArray(aZBD[nI][2])		
		//		exit
		//	endif
		//Next nI
		//o8ZBCGDad:Refresh()
	endIf

	MBSaveLog():FULLWrite(, .F., "Fim: ZBCDelOk()")
return lRet

/* MJ : 24.01.2018 */
// Static Function fCanSelIC()
// Local lRet := .T.
//
// 	If !( lRet := !Empty( oZICGDad:aCols[ oZICGDad:oBrowse:nAt, nPZICSxo] ) )
// 		Alert('O campo sexo não informado, por isso o item nao poderá ser selecionado.')
//
// 	ElseIf !( lRet := !Empty( oZICGDad:aCols[ oZICGDad:oBrowse:nAt, nPZBC1IC/* nPZICPrd */] ) )
// 		Alert('Produto não informada, por isso o item nao poderá ser selecionado.')
//
// 	ElseIf !( lRet := !Empty( oZICGDad:aCols[ oZICGDad:oBrowse:nAt, nPZICQtd] ) )
// 		Alert('Quantidade não informada, por isso o item nao poderá ser selecionado.')
//
// 	EndIf
//
// return lRet

/* MJ : 24.01.2018 */
Static Function fCanSelBC()
	Local lRet := .T.

	MBSaveLog():FULLWrite(, .F., "Inicio: fCanSelBC()")


	If !( lRet := !Empty( &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ o1ZBCGDad:oBrowse:nAt, nPZBCQtd ] ) )
		Alert('Quantidade não informada, por isso o item nao poderá ser selecionado.')

	// Esta validacao foi retirada no dia 02/04; sera permitido selecionar pois tbm sera utilizado para gerar o complemento duplo,
	// esta validacao de pedido existente esta agora na geracao do pedido.

	//		ElseIf !( lRet := Empty( o1ZBCGDad:aCols[ o1ZBCGDad:oBrowse:nAt, nPZBCPed ] ) )
	//			MsgInfo("O Pedido de Compra: <b>" + AllTrim( o1ZBCGDad:aCols[ o1ZBCGDad:oBrowse:nAt, nPZBCPed]) + ;
	//				  "</b> ja se encontra vinculada na linha: <b>" + AllTrim(Str( o1ZBCGDad:oBrowse:nAt)) + "</b>", 'Aviso')
	EndIf
	MBSaveLog():FULLWrite(, .F., "Fim: fCanSelBC()")

return lRet


/*
	MJ : 06.02.2018
		# Processar codigo do pedido de compra.

	* // http://www.blacktdn.com.br/2012/05/para-quem-precisar-desenvolver-uma.html
*/
User Function xFiltroConsulta() // U_xFiltroConsulta()
	Local lRet 		:= .F.
	Local cLoad     := ProcName(1) // Nome do perfil se caso for carregar
	Local lCanSave  := .T. // Salvar os dados informados nos parâmetros por perfil
	Local lUserSave := .T. // Configuração por usuário
	Local aParamBox := {}
	Local aRet 		:= {}
	Local nOpc		:= 4

	MBSaveLog():FULLWrite(, .F., "Inicio: xFiltroConsulta()")

	aAdd(aParamBox,{9 , "Informe o número do pedido de compras: ",150,7,.T.})
	aAdd(aParamBox,{1 , "Pedido de Compra", Space(TamSX3("C7_NUM")[1]), "","","SC7","",0,.T.}) // Tipo caractere

	If ParamBox(aParamBox,"Parâmetros...",@aRet, /* [ bOk ] */, /* [ aButtons ] */, /* [ lCentered ] */, /* [ nPosX ] */, /* [ nPosy ] */, /* [ oDlgWizard ] */,  cLoad, lCanSave, lUserSave )
		if !Empty(aRet[2])

			ZCC->(DbSetOrder(1))
			If ZCC->(DbSeek( FWxFilial('ZCC') + Posicione('ZBC',2,FWxFilial('ZBC')+aRet[2], 'ZBC_CODIGO') ))

				If ZCC->ZCC_STATUS == "C"
					Aviso("Aviso", 'O contrato encontra-se cancelado e por esse motivo sera aberto como visualização.', {"Sair"})
					nOpc := 2
				ElseIf ZCC->ZCC_STATUS$"FP"
					Aviso("Aviso", 'O contrato encontra-se finalizado e por esse motivo sera aberto como visualização.', {"Sair"})
					nOpc := 2
				EndIf

				FWMsgRun(, {|| U_COMM11VA( 'ZCC', ZCC->(Recno()), nOpc) }, 'Processando Filtro','Abrindo contrato, Por Favor Aguarde...')
			EndIf

		EndIf
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: xFiltroConsulta()")

Return lRet

/*
Desenver Tela para levantar Nro do pedido;
e retornar para o filtro;
Filtro customizado, por Funcao customizada

ZCC_CODIGO == POSICIONE('ZBC', 2, FWxFilial('ZBC')+ '%ZBC_PEDIDO0%', 'ZBC_CODIGO')
POSICIONE('ZBC', 2, FWxFilial('ZBC')+'%ZBC_PEDIDO0%', 'ZBC_CODIGO') $ ZCC->ZCC_CODIGO
*/


// MJ : 16.02.2018
User Function TemPauta()
	Local aArea  := GetArea()
	Local lPauta := .F.

	MBSaveLog():FULLWrite(, .F., "Inicio: TemPauta()")

	ZBC->( DbSetOrder(1) )
	If ZBC->( DBSeek( FWxFilial('ZBC') + M->ZCC_CODIGO + M->ZCC_VERSAO ))
		While !ZBC->(Eof()) .and. ( ZBC->( ZBC_CODIGO + ZBC_VERSAO ) == M->ZCC_CODIGO + M->ZCC_VERSAO )
			if ZBC->ZBC_PEDPOR == "P"
				lPauta := .T.
				Exit
			EndIf
			ZBC->(DbSkip())
		EndDo
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim: TemPauta()")

	RestArea(aArea)
Return lPauta


/* MJ : 16.05.2018 */
User Function ProxSC7_SC8() // U_ProxSC7_SC8()
	Local cNumPc    := ""
	Local cQry 	    := ""
	Local cAliasQry := GetNextAlias()

	MBSaveLog():FULLWrite(, .F., "Inicio: TemPauta()")

	cQry := " SELECT C7_FILIAL, MAX(C7_NUM) C7_NUM" + CRLF
	cQry += " FROM " + RetSQLName('SC7') + CRLF
	cQry += " WHERE C7_FILIAL = '"+ FWxFilial('SC7') + "'" + CRLF
	cQry += " GROUP BY C7_FILIAL" + CRLF

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, cQry ),(cAliasQry),.F.,.F.)
	if !(cAliasQry)->(Eof())
		cNumPc := Soma1( (cAliasQry)->C7_NUM )
	Else
		cNumPc := StrZero( 1, TamSX3('C7_NUM')[1])
	EndIf
	(cAliasQry)->(DbCloseArea())

	MBSaveLog():FULLWrite(, .F., "FIm: TemPauta()")

Return cNumPc

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM11()                                      |
 | Func:  COMM11PE()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  12.11.2018                                                              |
 | Desc:  Tela para cadastro dos Pesos individualmente dos animais;               |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function COMM11PE(nLZBC)

Local aArea		  := GetArea()
Local nOpcA
Local nI          := 0
Local nGDOpc	  := GD_INSERT + GD_UPDATE + GD_DELETE
Local oDlgP		  := nil
Local oGrpP1 	  := nil
Local aZPEHead 	  := {}, aZPECols := {}, nUZPE := 1, oGrpP2 := nil
Local oGrpP3 	  := nil
Local aField  	  := {}
Local aButtons    := {}
Local cTitulo	  := "Cadastro de Pesos Individualmente - Linha: "
Local oObj		  := &( "o" + cValToChar( oTFoldeG:nOption ) + "ZBCGDad")

Private oMGetP	  := nil
Private oZPEGDad  := nil, oMGetE	  := nil

// Local cCpoNao    := "|ZAD_FILIAL|ZAD_CODIGO|ZAD_ITEM  |ZAD_EQUIPA| "
// Local cLstCpo    := "|ZAD_DATA  |ZAD_INICIO|ZAD_FINAL |ZAD_CC    |ZAD_CCDESC|ZAD_OPERAD|ZAD_NOMEOP| "

Private aGets     := {}
Private aTela     := {}

Private _cCodSB1  := CriaVar('ZBC_PRODUT', .F.)
Private _cDesSB1  := CriaVar('ZBC_PRDDES', .F.)
Private _cQuaZBC  := CriaVar('ZBC_QUANT' , .F.)
Private _cTotZBC  := CriaVar('ZBC_TOTAL' , .F.)
Private _cPesoZPE := CriaVar('ZPE_PESO'  , .F.)

// Grupo 3
Private _cQuaZPE  := CriaVar('ZBC_QUANT' , .F.)
Private _cTotZPE  := CriaVar('ZBC_QUANT' , .F.)
Private _cMedZPE  := CriaVar('ZBC_QUANT' , .F.)

Default nLZBC	  := oObj:oBrowse:nAt

MBSaveLog():FULLWrite(, .F., "Inicio: COMM11PE()")

cTitulo	+= cValToChar(nLZBC)

_cCodSB1  := oObj:aCols[ nLZBC, aScan( oObj:aHeader, { |x| AllTrim(x[2]) == "ZBC_PRODUT" }) ]
_cDesSB1  := AllTrim(_cCodSB1) + '-' + oObj:aCols[ nLZBC, aScan( oObj:aHeader, { |x| AllTrim(x[2]) == "ZBC_PRDDES" }) ]
_cQuaZBC  := o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_QUANT"  }) ]
_cTotZBC  := o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_TOTAL"  }) ]

DEFINE MSDIALOG oDlgP TITLE OemToAnsi(cTitulo) From 0,0 to 600,500 PIXEL STYLE ; // 565,360
				nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |

//                       Titulo,     Campo  , Tipo,                 Tamanho,                 Decimal,                 Pict,                                Valid, Obrigat, Nivel,                     Inic Padr, F3,   When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
//aAdd(aField, { "Cod. Produto" , "_cCodSB1", "C", TamSX3("ZBC_PRODUT")[1], TamSX3("ZBC_PRODUT")[2], PesqPict("ZBC", "ZBC_PRODUT"), /* { || VldCpo(2) } */	,     .F.,     1, GetSX8Num('ZAD','ZBC_PRODUT'), ""   , "" ,    .F.,   .F.,   "",      2,     .F.,          "",      "N"} )
aAdd(aField, { "Produto"        , "_cDesSB1" , "C", TamSX3("ZBC_PRDDES")[1], TamSX3("ZBC_PRDDES")[2], PesqPict("ZBC", "ZBC_PRDDES"), /* { || U_Vd1MNT01() } */   ,     .F.,     1,                            "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
aAdd(aField, { "Quant."	       , "_cQuaZBC" , "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) }    */   ,     .F.,     1,                            "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
aAdd(aField, { "Total"	       , "_cTotZBC" , "N", TamSX3("ZBC_TOTAL" )[1], TamSX3("ZBC_TOTAL")[2] , PesqPict("ZBC", "ZBC_TOTAL" ), /* { || VldCpo(2) }    */   ,     .F.,     1,                            "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
aAdd(aField, { "Digite o Peso:", "_cPesoZPE", "N", TamSX3("ZPE_PESO" )[1] , TamSX3("ZPE_PESO")[2]  , PesqPict("ZPE", "ZPE_PESO" ) , { || VldCpo(4) }            ,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",      1,         .F.,      "",      "N"} )

nDist := 2
nL1 := 32; nC1 := nDist
nL2 := nL1 + 78 /* 110 */; nC2 := 250 /* 180 */
oGrpP1 := TGroup():New( nL1, nC1, nL2, nC2, "Dados Gerais do Contrato",oDlgP,,, .T.,)
	oMGetP := MsMGet():New(,, 3/* nOpc */,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{0,0,0,0}/* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,;
						/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oGrpP1,/*lF3*/,/*lMemoria*/, .F. /*lColumn*/,;
						nil /*caTela*/,/*lNoFolder*/, .T. /*lProperty*/,aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,;
						/*cTela*/)
oMGetP:oBox:Align := CONTROL_ALIGN_ALLCLIENT

U_BDados( "ZPE", @aZPEHead, @aZPECols, @nUZPE, 1 /* nOrd */, /* lFilial */, ;
					"ZPE->ZPE_FILIAL + ZPE->ZPE_CODIGO + ZPE->ZPE_VERSAO + ZPE->ZPE_ITEZBC == '" + FWxFilial("ZPE") + M->ZCC_CODIGO + M->ZCC_VERSAO + StrZero(nLZBC ,TamSX3('ZBC_ITEM')[1]) + "'", ;
					/* lStatus */, /* cCpoLeg */, /* cLstCpo */, /* cElimina */, /* cCpoNao */, /* cStaReg */, ;
					/* cCpoMar */, /* cMarDef */, /* lLstCpo */, /* aLeg */, /* lEliSql */, /* lOrderBy */, ;
					/* cCposGrpBy */, /* cGroupBy */, /* aCposIni */, /* aJoin */, /* aCposCalc */, /* cOrderBy */, ;
					/* aCposVis */, /* aCposAlt */, /* cCpoFilial */, /* nOpcX */ )

If Len(aZPECols) == 1 .and. Empty(aZPECols[1,4])
	aZPECols[ 1, /* nPZPEIt:= */aScan( aZPEHead, { |x| AllTrim(x[2]) == "ZPE_ITEM" })] :=  StrZero( 1, TamSX3('ZPE_ITEM')[1])
Else
	For nI:=1 to _cQuaZPE:=len(aZPECols)
		_cTotZPE += aZPECols[ nI, 2]
	Next nI
	_cMedZPE := Round(_cTotZPE / _cQuaZPE,2)
EndIf

nL3 := nL2 + 135 // 245
oGrpP2 := TGroup():New( nL2+nDist, nC1, nL3,nC2, "Tabela de Pesos",oDlgP,,, .T.,)
oZPEGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZPE_ITEM", , , 99999, , , "u_ZPEDelOk()" , oGrpP2, ;
									aClone(aZPEHead), aClone( aZPECols ) )
oZPEGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oZPEGDad:cFieldOK      := "U_ZPEFieldOK()"
oZPEGDad:bChange       := {|| U_ZPEbChange() }
// oZPEGDad:bLinhaOK      := {|| U_ZPELinOK() }
// oZPEGDad:bBeforeEdit   := {|| U_ZPEbBeforeEdit() }
oZPEGDad:oBrowse:nColPos := 2
oZPEGDad:Refresh()
oZPEGDad:oBrowse:SetFocus()
// 0	Nenhum			CONTORL_ALIGN_NONE
// 1	Esquerda		CONTROL_ALIGN_LEFT
// 2	Direita			CONTROL_ALIGN_RIGHT
// 3	Topo			CONTROL_ALIGN_TOP
// 4	Abaixo			CONTROL_ALIGN_BOTTOM
// 5	Todo o espaço	CONTROL_ALIGN_ALLCLIENT
// 6	Centro			CONTROL_ALIGN_CENTER

nL4 := nL3 + 50 // 295
oGrpP3 := TGroup():New( nL3+nDist, nC1, nL4,nC2, "Totalizadores",oDlgP,,, .T.,)
aField := {}

//                   Titulo,     Campo, Tipo,                 Tamanho,                 Decimal,                 Pict,                           Valid, Obrigat, Nivel,                     Inic Padr, F3,   When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
aAdd(aField, { "Qtd Cad."  , "_cQuaZPE", "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) } */	,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",   2,     .F.,          "",      "N"} )
aAdd(aField, { "Total Peso", "_cTotZPE", "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) } */	,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",   2,     .F.,          "",      "N"} )
aAdd(aField, { "Média Peso", "_cMedZPE", "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) } */	,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",   2,     .F.,          "",      "N"} )
oMGetE := MsMGet():New(,, 2/* nOpc */,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{0,0,0,0}/* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,;
						/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oGrpP3,/*lF3*/,/*lMemoria*/, .F. /*lColumn*/,;
						nil /*caTela*/,/*lNoFolder*/, .T. /*lProperty*/,aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,;
						/*cTela*/)
oMGetE:oBox:Align := CONTROL_ALIGN_ALLCLIENT

AAdd( aButtons, { "AUTOM", { || ZPEPrint(nLZBC)  }, "Imprimir" } )
Set Key K_CTRL_P To ZPEPrint(nLZBC)

ACTIVATE MSDIALOG oDlgP ;
          ON INIT EnchoiceBar(oDlgP,;
                              { || nOpcA := 1, Iif( VldCpo(5) .and. Obrigatorio(aGets, aTela), oDlgP:End(), nOpcA := 0)},;
                              { || nOpcA := 0, oDlgP:End() },, aButtons)

If nOpcA == 1
	Begin Transaction

	MBSaveLog():FULLWrite(, .F., "COMM11PE() - Inicio da Transação")

		For nI := 1 to Len(oZPEGDad:aCols)
			If !oZPEGDad:aCols[nI][ Len(oZPEGDad:aCols[1]) ] .AND. !Empty( oZPEGDad:aCols[ nI, 2] )
				DbSelectArea( "ZPE" )
				ZPE->( DbSetOrder( 1 ) )
				RecLock( "ZPE", lRecLock := !DbSeek( FWxFilial("ZPE") + M->ZCC_CODIGO + M->ZCC_VERSAO + StrZero(nLZBC ,TamSX3('ZBC_ITEM')[1]) + oZPEGDad:aCols[ nI, 1 ]  ) )
					U_GrvCpo( "ZPE", oZPEGDad:aCols, oZPEGDad:aHeader, nI )
					If lRecLock
						ZPE->ZPE_FILIAL := FWxFilial("ZPE")
						ZPE->ZPE_CODIGO := M->ZCC_CODIGO
						ZPE->ZPE_VERSAO := M->ZCC_VERSAO
						ZPE->ZPE_ITEZBC := StrZero(nLZBC ,TamSX3('ZPE_ITEZBC')[1])
					EndIf
				ZPE->( MsUnlock() )
				// lAtuX8 := .T.
			Else // Se o registro foi excluido e existe no banco apaga
				DbSelectArea( "ZPE" )
				ZPE->( DbSetOrder( 1 ) )
				If ZPE->( DbSeek( FWxFilial("ZPE") + M->ZCC_CODIGO + M->ZCC_VERSAO + StrZero(nLZBC ,TamSX3('ZBC_ITEM')[1]) + oZPEGDad:aCols[ nI, 1 ] ) )
					RecLock("ZPE", .F.)
						ZPE->( DbDelete() )
					ZPE->( MsUnlock() )
				EndIf
			EndIf
		Next i

		&( "o" + cPFoBCPeR + "ZBCGDad"):aCols[ nLZBC, nPZBCPeR ] := _cTotZPE
		If Empty( &( "o" + cPFoBCPes + "ZBCGDad"):aCols[ nLZBC, nPZBCPes ])
			&( "o" + cPFoBCPes + "ZBCGDad"):aCols[ nLZBC, nPZBCPes ] := _cTotZPE
			U_ZBCFieldOK('ZBC_PESO', _cTotZPE, nLZBC, oTFoldeG:nOption )
		EndIf
		MBSaveLog():FULLWrite(, .F., "COMM11PE() - Fim da Transação")
	End Transaction
EndIf

MBSaveLog():FULLWrite(, .F., "Fim: COMM11PE()")

RestArea(aArea)
Return nil



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM11()                                      |
 | Func:  COMM11PE()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  17.05.2019                                                              |
 | Desc:  Tela para cadastro dos Juros;                                           |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function COMM11JR(nLZJC) // Juros

Local aArea		  := GetArea()
Local nOpcA
Local nI          := 0
Local nGDOpc	  := GD_INSERT + GD_UPDATE + GD_DELETE
Local oDlgJ		  := nil
Local aZJCHead 	  := {}, aZJCCols := {}, nUZJC := 1
Local cTitulo	  := "Cadastro de Juros - Linha: "
Local oObj		  := &( "o" + cValToChar( oTFoldeG:nOption ) + "ZBCGDad")
Local oGrpP1 	  := nil, oGrpP2 := nil
Local aField	  := {}
Private aGets     := {}
Private aTela     := {}

Private _cTotZJC  := CriaVar('ZJC_VLRBAS', .F.)

Default nLZJC	  := oObj:oBrowse:nAt

MBSaveLog():FULLWrite(, .F., "Fim: COMM11JR()")

cTitulo	+= cValToChar(nLZJC)

DEFINE MSDIALOG oDlgJ TITLE OemToAnsi(cTitulo) From 0,0 to 400,700 PIXEL STYLE ; // 565,360
										nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |

U_BDados( "ZJC", @aZJCHead, @aZJCCols, @nUZJC, 1 /* nOrd */, /* lFilial */, ;
					"ZJC->ZJC_FILIAL + ZJC->ZJC_CODIGO + ZJC->ZJC_VERSAO + ZJC->ZJC_ITEM == '" + FWxFilial("ZJC") + M->ZCC_CODIGO + M->ZCC_VERSAO + StrZero(nLZJC ,TamSX3('ZJC_ITEM')[1]) + "'", ;
					/* lStatus */, /* cCpoLeg */, /* cLstCpo */, /* cElimina */, /* cCpoNao */, /* cStaReg */, ;
					/* cCpoMar */, /* cMarDef */, /* lLstCpo */, /* aLeg */, /* lEliSql */, /* lOrderBy */, ;
					/* cCposGrpBy */, /* cGroupBy */, /* aCposIni */, /* aJoin */, /* aCposCalc */, /* cOrderBy */, ;
					/* aCposVis */, /* aCposAlt */, /* cCpoFilial */, /* nOpcX */ )
If Len(aZJCCols) == 1 .and. Empty(aZJCCols[1,aScan( aZJCHead, { |x| AllTrim(x[2]) == "ZJC_VLRBAS" })])
	aZJCCols[ 1, /* nPZJCIt:= */aScan( aZJCHead, { |x| AllTrim(x[2]) == "ZJC_SEQUEN" })] :=  StrZero( 1, TamSX3('ZJC_SEQUEN')[1])
EndIf

oGrpP1 := TGroup():New( 32, nDist:=3, LFa:=150, CFa:=350, "Tabela de Juros", oDlgJ,,, .T.,)
oZJCGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZJC_SEQUEN" , , , 99999, , , "u_ZJCDelOk()", oGrpP1, ;
									aClone(aZJCHead), aClone( aZJCCols ) )
oZJCGDad:cFieldOK      := "U_M11JRTot()"
oZJCGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGrpP2 := TGroup():New( LIb:=LFa+nDist, nDist, LIb+45, CFa, "Totalizadores", oDlgJ,,, .T.,)
aAdd(aField, { "Total"	       , "_cTotZJC" , "N", TamSX3("ZJC_VLRBAS" )[1], TamSX3("ZJC_VLRBAS")[2] , PesqPict("ZJC", "ZJC_VLRBAS" ), /* { || VldCpo(2) }    */   ,     .F.,     1,                            "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
oMGetP := MsMGet():New(,, 3/* nOpc */,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{0,0,0,0}/* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,;
						/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oGrpP2,/*lF3*/,/*lMemoria*/, .F. /*lColumn*/,;
						nil /*caTela*/,/*lNoFolder*/, .T. /*lProperty*/,aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,;
						/*cTela*/)
oMGetP:oBox:Align := CONTROL_ALIGN_ALLCLIENT

// Atualizando Campo Total
For nI:=1 to len(oZJCGDad:aCols)
	_cTotZJC += oZJCGDad:aCols[nI,aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_VLRJUR" })]
Next nI
// oMGetP:Refresh()

ACTIVATE MSDIALOG oDlgJ ;
          ON INIT EnchoiceBar(oDlgJ,;
                              { || nOpcA := 1, Iif( /*VldCpo(5) .and.*/Obrigatorio(aGets, aTela), oDlgJ:End(), nOpcA := 0)},;
                              { || nOpcA := 0, oDlgJ:End() },, /* aButtons */ )

If nOpcA == 1

	Begin Transaction
		MBSaveLog():FULLWrite(, .F., "COMM11JR() - Inicio da Transação")

		For nI := 1 to Len(oZJCGDad:aCols)
			If !oZJCGDad:aCols[nI][ Len(oZJCGDad:aCols[1]) ] .AND. !Empty( oZJCGDad:aCols[ nI, 2] )
				DbSelectArea( "ZJC" )
				ZJC->( DbSetOrder( 1 ) )
				RecLock( "ZJC", lRecLock := !DbSeek( FWxFilial("ZJC") + M->ZCC_CODIGO + M->ZCC_VERSAO + StrZero(nLZJC ,TamSX3('ZBC_ITEM')[1]) + oZJCGDad:aCols[ nI, 1 ] ) )
					U_GrvCpo( "ZJC", oZJCGDad:aCols, oZJCGDad:aHeader, nI )
					If lRecLock
						ZJC->ZJC_FILIAL := FWxFilial("ZJC")
						ZJC->ZJC_CODIGO := M->ZCC_CODIGO
						ZJC->ZJC_VERSAO := M->ZCC_VERSAO
						ZJC->ZJC_ITEM   := StrZero(nLZJC ,TamSX3('ZJC_ITEM')[1])
					EndIf
				ZJC->( MsUnlock() )
				// lAtuX8 := .T.
			Else // Se o registro foi excluido e existe no banco apaga
				DbSelectArea( "ZJC" )
				ZJC->( DbSetOrder( 1 ) )
				If ZJC->( DbSeek( FWxFilial("ZJC") + M->ZCC_CODIGO + M->ZCC_VERSAO + StrZero(nLZJC ,TamSX3('ZJC_ITEM')[1]) + oZJCGDad:aCols[ nI, 1 ] ) )
					RecLock("ZJC", .F.)
						ZJC->( DbDelete() )
					ZJC->( MsUnlock() )
				EndIf
			EndIf
		Next i

		If _cTotZJC > 0
			// &( "o" + cPFoBCJur + "ZBCGDad"):aCols[ nLZJC, nPZBCJur ] := _cTotZJC

			U_ZBCFieldOK('ZBC_JUROS', _cTotZJC, nLZJC /* , oTFoldeG:nOption */ )
		EndIf
		MBSaveLog():FULLWrite(, .F., "COMM11JR() - Fim da Transação")
	End Transaction

EndIf

MBSaveLog():FULLWrite(, .F., "Fim: COMM11JR()")

RestArea(aArea)

Return nil


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM11()                                      |
 | Func:  VldCpo()		                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  28.12.2018                                                              |
 | Desc:  Validação dos Campos MsMGet;                                            |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function M11JRTot(_cCampo)
Local nI		:= 0
Local nAt		:= oZJCGDad:oBrowse:nAt
Local _nAux		:= 0

Default _cCampo	:= ReadVar()

MBSaveLog():FULLWrite(, .F., "Inicio: M11JRTot('"+_cCampo+"')")

If _cCampo=='M->ZJC_VLRBAS'

	If Len(oZJCGDad:aCols) > 1 .and. nAt == Len(oZJCGDad:aCols)
		oZJCGDad:aCols[ len(oZJCGDad:aCols), aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })] := oZJCGDad:aCols[ len(oZJCGDad:aCols)-1, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })]
	EndIf

ElseIf _cCampo=='M->ZJC_DTINIC'

	// If !Empty(oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })]) .and. !Empty(oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })])
	If !Empty(&(ReadVar())) .and. !Empty(oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })])
		// oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_QTDIAS" })] := oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })] - oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })]
		oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_QTDIAS" })] := oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })] - &(ReadVar())
	EndIf

ElseIf _cCampo=='M->ZJC_DTFINA'

	// If !Empty(oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })]) .and. !Empty(oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })])
	If !Empty(oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })]) .and. !Empty(&(ReadVar()))
		// oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_QTDIAS" })] := oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })] - oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })]
		oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_QTDIAS" })] := &(ReadVar()) - oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })]
	EndIf

ElseIf _cCampo=='M->ZJC_TXMENS'

	// oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_VLRJUR" })] := oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_VLRBAS" })]*oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_TXMENS" })]/100

	_nAux := oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_VLRBAS" })]*&(ReadVar())/100
	oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_VLRJUR" })] := _nAux

	_cTotZJC := 0
	For nI:=1 to len(oZJCGDad:aCols)
		If !oZJCGDad:aCols[ nI, Len(oZJCGDad:aCols[nI]) ]
			If nI==nAt
				_cTotZJC += _nAux
			Else
				_cTotZJC += oZJCGDad:aCols[nI,aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_VLRJUR" })]
			EndIf
		EndIf
	Next nI
	oMGetP:Refresh()
EndIf

MBSaveLog():FULLWrite(, .F., "Fim: M11JRTot('"+_cCampo+"')")

Return .T.


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM11()                                      |
 | Func:                                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  20.05.2019                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function ZJCDelOk()
	Local nI        := 0
	Local nAt		:= oZJCGDad:oBrowse:nAt

	MBSaveLog():FULLWrite(, .F., "Inicio: ZJCDelOk()")

	_cTotZJC  := 0 // variavel privada
	For nI:=1 to len(oZJCGDad:aCols)
		//If !oZJCGDad:aCols[ nI, Len(oZJCGDad:aCols[nI]) ]
		If (nI==nAt .and. !oZJCGDad:aCols[ nI, Len(oZJCGDad:aCols[nI]) ]) .or. (nI<>nAt .and. oZJCGDad:aCols[ nI, Len(oZJCGDad:aCols[nI])])
			Loop
		EndIf
				// _cTotZJC += _nAux
			// Else
			_cTotZJC += oZJCGDad:aCols[nI,aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_VLRJUR" })]
			// EndIf
		// EndIf
	Next nI
	oMGetP:Refresh()

	MBSaveLog():FULLWrite(, .F., "Fim: ZJCDelOk()")

Return .T.


Static nPosPESO	:= 2
/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM11()                                      |
 | Func:  VldCpo()		                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  28.12.2018                                                              |
 | Desc:  Validação dos Campos MsMGet;                                            |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function VldCpo(nOpc)
Local lRet := .T.
Local nAux := 0
Local lVld := .F.

	MBSaveLog():FULLWrite(, .F., "Inicio:  VldCpo("+cValToChar(nOpc)+")")

	If nOpc == 4
		If !Empty(_cPesoZPE)
			lVld := .T.
		EndIf
	ElseIf nOpc == 5 // ZPE_PESO''
		lVld := .T.
		nAux := -1
		// oZPEGDad:ForceRefresh()
	EndIf
	If lVld
		If ( lRet := (_cQuaZPE+nAux) < _cQuaZBC )
			If nOpc == 4
				If (oZPEGDad:aCols[ Len(oZPEGDad:aCols) , Len(oZPEGDad:aCols[ Len(oZPEGDad:aCols) ]) ] .OR. ;
					!Empty( oZPEGDad:aCols[ Len(oZPEGDad:aCols) , nPosPESO ] ))

						oZPEGDad:AddLine(.T., .T.)
						oZPEGDad:ForceRefresh()
				EndIf

				oZPEGDad:aCols[ Len(oZPEGDad:aCols) , nPosPESO ] := _cPesoZPE

				//oMGetP:aGets[4]:SetFocus() // ZPE_PESO
				oMGetP:SetFocus()
				oZPEGDad:Refresh()
			EndIf
			U_ZPEFieldOK()
		Else
			MsgInfo( "O limite de " + cValToChar(_cQuaZBC) + " registros foi alcançado.", "Aviso" )
		EndIf
		_cPesoZPE := CriaVar('ZPE_PESO'  , .F.)
		oMGetP:Refresh()
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim:  VldCpo()")
Return lRet

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()                                      |
 | Func:  VldPesoM7()	                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  14.05.2018                                                              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
/*
// -> Esta funcao estava no campo X3_VALID do campo ZPE_PESO
User Function VldPesoM7()

tentando reposionar a posicao do cursor,
ir pra linha de baixo sozinho, sem precisar apertar o botao SETA para BAIXO;

// ClassMethArr( oZPEGDad, .T. )
 oZPEGDad:AddLine(.F., .F.)
//oZPEGDad:GoBottom()

//oZPEGDad:oBrowse:nColPos := 2
oZPEGDad:oBrowse:nAt 	 := Len(oZPEGDad:aCols)
// oZPEGDad:GoTo( Len(oZPEGDad:aCols) )
//oZPEGDad:ForceRefresh()
oZPEGDad:Refresh()

Alert('nColPos: ' + cValTochar(oZPEGDad:oBrowse:nColPos ) )
Alert('nAt: ' + cValToChar(oZPEGDad:oBrowse:nAt))
Return .T.
*/

/*
	MJ : 13.11.2018
		-> Preencher linha de baixo, com copia da de cima * ctrl c + ctrl v;
		-> Setar focus no campo PESO;
*/
User Function ZPEFieldOK()
Local nI
Local nValor := 0

	MBSaveLog():FULLWrite(, .F., "Inicio: ZPEFieldOK()")

	// Alert('ZPEFieldOK - Linha: ' + AllTrim(Str(oZPEGDad:oBrowse:nAt)))
	// oZPEGDad:oBrowse:SetFocus()

	// nao da pra separar em funcao, tem particularidadeds
	_cQuaZPE := 0
	_cTotZPE := 0

	For nI := 1 to Len(oZPEGDad:aCols)
		If !oZPEGDad:aCols[ nI, Len(oZPEGDad:aCols[nI]) ] // .and. nValor > 0 // oZPEGDad:aCols[ nI, 02 ] > 0
			nValor := iIf(nI == oZPEGDad:oBrowse:nAt .and. !(ProcName(1) == "VLDCPO"), ;
							&(ReadVar()), ;
							oZPEGDad:aCols[ nI, 02 ])

			If nValor > 0
				_cQuaZPE += 1
				_cTotZPE += nValor
			EndIf
		EndIf
	Next nI
	_cMedZPE := Round(_cTotZPE / _cQuaZPE,2)

	// oZPEGDad:oBrowse:nColPos := 2
	// oZPEGDad:Refresh()
	oMGetE:Refresh()

	MBSaveLog():FULLWrite(, .F., "Fim: ZPEFieldOK()")
Return .T.

// #########################################################################################################
User Function ZPEDelOk()
Local nI
Local lSoma	 := .F.

	// Alert('ZPEDelOk - Linha: ' + AllTrim(Str(oZPEGDad:oBrowse:nAt)))
	// oZPEGDad:oBrowse:SetFocus()

	MBSaveLog():FULLWrite(, .F., "Inicio: ZPEDelOk()")
	// nao da pra separar em funcao, tem particularidadeds
	_cQuaZPE := 0
	_cTotZPE := 0
	For nI := 1 to Len(oZPEGDad:aCols)

		If nI == oZPEGDad:oBrowse:nAt
			lSoma := oZPEGDad:aCols[ nI, Len(oZPEGDad:aCols[nI]) ]
		Else
			lSoma := !oZPEGDad:aCols[ nI, Len(oZPEGDad:aCols[nI]) ]
		EndIf


		If lSoma
		// If !(oZPEGDad:oBrowse:nAt == nI .and. !oZPEGDad:aCols[ nI, Len(oZPEGDad:aCols[nI]) ]) ;
		//
		// 	.and. !oZPEGDad:aCols[ nI, Len(oZPEGDad:aCols[nI]) ] .and. oZPEGDad:aCols[ nI, 02 ] > 0

			_cQuaZPE += 1

			// If nI == oZPEGDad:oBrowse:nAt
			// 	_cTotZPE += &(ReadVar())
			// Else
				_cTotZPE += oZPEGDad:aCols[ nI, 02 ]
			// EndIf
		EndIf
	Next nI

	_cMedZPE := Round(_cTotZPE / _cQuaZPE,2)
	// oZPEGDad:oBrowse:nColPos := 2
	// oZPEGDad:Refresh()
	oMGetE:Refresh()

	MBSaveLog():FULLWrite(, .F., "Fim: ZPEDelOk()")

Return .T.


User Function ZPEbChange()
	Local lRet	:= .T.
	
	MBSaveLog():FULLWrite(, .F., "Inicio: ZPEbChange()")

	// Alert('ZPEbChange - Linha: ' + AllTrim(Str(oZPEGDad:oBrowse:nAt)))
	// oZPEGDad:oBrowse:SetFocus()
	oZPEGDad:oBrowse:nColPos := 2
	oZPEGDad:Refresh()
	oMGetE:Refresh()

	MBSaveLog():FULLWrite(, .F., "Fim: ZPEbChange()")
Return lRet
/*
User Function ZPELinOK()
Local lRet	:= .T.
	Alert('ZPELinOK - Linha: ' + AllTrim(Str(oZPEGDad:oBrowse:nAt)))
	// oZPEGDad:oBrowse:SetFocus()
	oZPEGDad:oBrowse:nColPos := 2
	oZPEGDad:Refresh()
Return lRet


User Function ZPEbBeforeEdit()
Local lRet	:= .T.
	Alert('ZPEbBeforeEdit - Linha: ' + AllTrim(Str(oZPEGDad:oBrowse:nAt)))
	// oZPEGDad:oBrowse:SetFocus()
	ReLoadTotalizadores()
Return lRet
*/


Static Function ZPEPrint(nLZBC)

Local cTimeIni	 	:= Time()
Local lTemDados		:= .T.

Private cPerg		:= "COMM11ZPE"
Private cTitulo  	:= "Relatorio Lotes de Compra"

Private cPath 	 	:= "C:\totvs_relatorios\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+ "_"+;
								DtoS(dDataBase)+;
								"_"+;
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()

Private nHandle    	:= 0

	MBSaveLog():FULLWrite(, .F., "Inicio: ZPEPrint()")

Default nLZBC	    := &( "o" + cValToChar( oTFoldeG:nOption ) + "ZBCGDad"):oBrowse:nAt  // Default nLZBC := o1ZBCGDad:oBrowse:nAt

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

	cStyle := U_defStyle()

	// Processar SQL
	FWMsgRun(, {|| lTemDados := VASqlM11("Geral", @_cAliasG, nLZBC ) },'Por Favor Aguarde...' , 'Processando Banco de Dados')
	If lTemDados
		cXML := U_CabXMLExcel(cStyle)

		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
			cXML := ""
		EndIf

		// Gerar primeira planilha
		FWMsgRun(, {|| fQuadro1(nLZBC) },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Lotes Analitico')

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

	Else
		MsgAlert("Os parametros informados não retornou nenhuma informação do banco de dados." + CRLF + ;
				 "Por isso o excel não sera aberto automaticamente.", "Dados não localizados")
	EndIf

	(_cAliasG)->(DbCloseArea())

	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
		Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
	EndIf

	ConOut('Activate: ' + Time())
EndIf

MBSaveLog():FULLWrite(, .F., "Fim: ZPEPrint()")
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
Static Function VASqlM11(cTipo, _cAlias, nLZBC)
	MBSaveLog():FULLWrite(, .F., "Inicio:  VASqlM11("+cTipo+", "+_cAlias+", )")

	Local _cQry 		:= ""

	Default nLZBC	    := o1ZBCGDad:oBrowse:nAt


	If cTipo == "Geral"

		_cQry := " SELECT ZPE_ITEM, ZPE_PESO " + CRLF
		_cQry += " FROM ZPE010" + CRLF
		_cQry += " WHERE" + CRLF
		_cQry += " 	    ZPE_FILIAL='"+ FWxFilial("ZPE") + "' " + CRLF
		_cQry += " 	AND ZPE_CODIGO='"+ M->ZCC_CODIGO + "' " + CRLF
		_cQry += " 	AND ZPE_VERSAO='"+ M->ZCC_VERSAO + "' " + CRLF
		_cQry += " 	AND ZPE_ITEZBC='"+ StrZero(nLZBC ,TamSX3('ZBC_ITEM')[1]) + "' " + CRLF
		_cQry += " 	AND D_E_L_E_T_=' '" + CRLF
		_cQry += " ORDER BY ZPE_ITEM " + CRLF

	EndIf

	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
		MemoWrite(StrTran(cArquivo,".xml","")+ "_Quadro_" + cTipo + ".sql" , _cQry)
	EndIf

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

	// TcSetField(_cAlias, "ZBC_DTENTR", "D")
	MBSaveLog():FULLWrite(, .F., "Fim:  VASqlM11("+cTipo+", "+_cAlias+", nLZBC")

Return !(_cAlias)->(Eof())


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM11()                                      |
 | Func:  fQuadro1()	                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  14.05.2018                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1(nLZBC)
	MBSaveLog():FULLWrite(, .F., "Inicio:  fQuadro1(nLZBC)")

	Local cXML 			:= ""
	Local cWorkSheet 	:= "Pesos"
	Local nLin			:= 0
	Local cAux		  	:= ""

	(_cAliasG)->(DbGoTop())
	If !(_cAliasG)->(Eof())

			cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
			cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
			cXML += '   <Column ss:Width="61.5"/>   ' + CRLF
			cXML += '   <Column ss:Width="113.25"/> ' + CRLF
			cXML += '   <Column ss:Width="105"/>    ' + CRLF
			cXML += '   <Column ss:Width="96"/>     ' + CRLF
			cXML += '   <Column ss:Width="63.75"/>  ' + CRLF
			cXML += '   <Column ss:Width="146.25"/> ' + CRLF
			cXML += '   <Column ss:Width="48.75"/>  ' + CRLF
			cXML += '   <Column ss:Width="72.75"/>  ' + CRLF
			cXML += '   <Column ss:Width="62.75"/>  ' + CRLF
			cXML += ' <Row ss:AutoFitHeight="0" ss:Height="36">' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Numero Contrato:</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Fornecedor:</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Municipio/Est</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Corretor:</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Numero do Pedido:</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Produto:</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Quant.</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Preço Total</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Média Preço</Data></Cell>' + CRLF
			cXML += '</Row>' + CRLF
			cXML += '<Row>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( M->ZCC_CODIGO ) + '</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( M->ZCC_CODFOR + "-" + M->ZCC_NOMFOR ) + '</Data></Cell>' + CRLF
			cAux := Posicione("SA2", 1, FWxFilial("SA2")+M->ZCC_CODFOR+M->ZCC_LOJFOR, "A2_MUN") + "/" + SA2->A2_EST
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'+U_FrmtVlrExcel( cAux )+'</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( AllTrim(M->ZCC_CODCOR) + "-" + M->ZCC_NOMCOR ) + '</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PEDIDO" })] + "-" + o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_ITEMPC" })] ) + '</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( AllTrim(o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PRODUT" })]) + "-" + AllTrim(o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PRDDES" })]) ) + '</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_QUANT" })] ) + '</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">' + U_FrmtVlrExcel( o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_TOTAL" })] ) + '</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>' + CRLF
			cXML += '</Row>' + CRLF

			cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF // PULAR LINHA

			cXML += '<Row ss:AutoFitHeight="0">
			cXML += '	<Cell ss:StyleID="s65"><Data ss:Type="String">Negociação</Data></Cell>
			cXML += '</Row>

			// P=Peso/Rend;K=Kilo;Q=Qtde
			cXML += '<Row ss:AutoFitHeight="0">
			// cAux := oZICGDad:aCols[ Val(o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_ITEZIC" })]), ;
			// 						 aScan( oZICGDad:aHeader, { |x| AllTrim(x[2]) == "ZIC_TPNEG" })]
			cAux := o1ZBCGDad:aCols[ nLZBC, nPZBCTPN ]
			if cAux=="P"
				cAux:="Peso/Rendimento"
			ElseIf cAux=="K"
				cAux:="Kilo"
			ElseIf cAux=="Q"
				cAux:="Quantidade"
			Else
				cAux := "Não Identificado"
			EndIf
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( cAux ) + '</Data></Cell>' + CRLF
			cXML += '</Row>

			cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF // PULAR LINHA

			cXML += ' <Row>' + CRLF
			cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Item</Data></Cell>' + CRLF
			cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Peso</Data></Cell>' + CRLF
			cXML += ' </Row>' + CRLF

		//fQuadro1
		While !(_cAliasG)->(Eof())	 // U_VACOMR07()
			nLin += 1

			cXML += '<Row>' + CRLF
			cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAliasG)->ZPE_ITEM ) + '</Data></Cell>' + CRLF
			cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->ZPE_PESO ) + '</Data></Cell>' + CRLF
			cXML += '</Row>' + CRLF

			(_cAliasG)->(DbSkip())
		EndDo

		cXML += ' <Row>' + CRLF
		cXML += ' 	<Cell ss:StyleID="sTextoN"><Data ss:Type="String">Total Peso</Data></Cell>' + CRLF
		cXML += ' 	<Cell ss:Index="2" ss:StyleID="sComDigN" ss:Formula="=SUM(R[-'+cValToChar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
		cXML += ' </Row>' + CRLF

		cXML += ' <Row>' + CRLF
		cXML += ' 	<Cell ss:StyleID="sTextoN"><Data ss:Type="String">Média Peso</Data></Cell>' + CRLF
		cXML += ' 	<Cell ss:Index="2" ss:StyleID="sComDigN" ss:Formula="=AVERAGE(R[-'+cValToChar(nLin+1)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
		cXML += ' </Row>' + CRLF

		cXML += '  </Table> ' + CRLF
		cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel"> ' + CRLF
		cXML += '   <PageSetup> ' + CRLF
		cXML += '    <Header x:Margin="0.31496062000000002"/> ' + CRLF
		cXML += '    <Footer x:Margin="0.31496062000000002"/> ' + CRLF
		cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" ' + CRLF
		cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/> ' + CRLF
		cXML += '   </PageSetup> ' + CRLF
		cXML += '   <TabColorIndex>13</TabColorIndex> ' + CRLF
		cXML += '   <Selected/> ' + CRLF
		cXML += '   <Panes> ' + CRLF
		cXML += '    <Pane> ' + CRLF
		cXML += '     <Number>3</Number> ' + CRLF
		cXML += '     <ActiveRow>17</ActiveRow> ' + CRLF
		cXML += '     <ActiveCol>9</ActiveCol> ' + CRLF
		cXML += '    </Pane> ' + CRLF
		cXML += '   </Panes> ' + CRLF
		cXML += '   <ProtectObjects>False</ProtectObjects> ' + CRLF
		cXML += '   <ProtectScenarios>False</ProtectScenarios> ' + CRLF
		cXML += '  </WorksheetOptions> ' + CRLF
		cXML += ' </Worksheet> ' + CRLF

		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""

	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim:  fQuadro1(nLZBC)")
Return nil
// fQuadro1

/* MJ : 16.01.2019
	-> Gerar Pré Notas de Entrada, como complemento;

	-> Inicialmente sera gerado uma tela com informacoes necessarias para a geracao da pré nota de entrada.
*/
Static Function fGerarCompl()
	MBSaveLog():FULLWrite(, .F., "Inicio:  fGerarCompl(nLZBC)")

	Local oDlgC		    := nil
	Local aSize		    := {}
	Local aObjects      := {}
	Local aInfo		    := {}
	Local aPObjs        := {}
	Local nDist 		:= 3
	Local nOpcA			:= 0
	Local nI			:= 0
	Local aField		:= {}
	Local aColsEsp := {}, nUsadEsp := 0

	Local nContTIK		:= 0, nTotQtdTIK := 0, nI := 0
	Local lErro			:= .F.
	Local lTemTIK		:= .F.
	Local _cDoc			:= ""
	Local aButtons		:= {}
	Local lContinua		:= .T.
	Local nSB1TTComp	:= 0
	Local cCodigo		:= ""

	// posicao grids
	Private aHeadEsp 	:= {}
	Private oGDQ2		:= nil
	Private nPMrkNFC	:= 0

	Private aGets       := {}
	Private aTela       := {}

	Private nAtZBC		:= &( "o" + cValToChar( oTFoldeG:nOption ) + "ZBCGDad"):oBrowse:nAt
	// ==============================================
	Private _cPedido    := &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nAtZBC, nPZBCPed ] // CriaVar('ZBC_PEDIDO', .F.)
	Private _cFornec    := M->ZCC_CODFOR+M->ZCC_LOJFOR+"-"+M->ZCC_NOMFOR // Space(20)
	Private _cQuaZBC    := 0	// &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nAtZBC, nPZBCQtd ] // CriaVar('ZBC_QUANT' , .F.)
	Private _cTotalNeg  := 0 	// Iif( Empty( &( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nAtZBC, nPZBCTNG ] ), &( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nAtZBC, nPZBCTot ], &( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nAtZBC, nPZBCTNG ] ) // CriaVar('ZBC_TOTAL' , .F.)
	Private _cMENPAD    := Space(3)
	Private _cCndPag    := Space(3)
	// Private _cTotalNeg     := &( "o" + cPFoBCXTT + "ZBCGDad"):aCols[ nAtZBC, nPZBCXTT ] + ;
	// 					   &( "o" + cPFoBCToI + "ZBCGDad"):aCols[ nAtZBC, nPZBCToI ]
	Private _cProdut	:= ""
	Private _cTpSenar	:= ""
	// ==============================================
	Private _cQuaNF     := CriaVar('ZBC_QUANT', .F.)
	Private _cVlrNF     := CriaVar('ZBC_TOTAL', .F.)
	Private _cSohNF     := CriaVar('ZBC_TOTAL', .F.)
	Private _cTotNF     := CriaVar('ZBC_TOTAL', .F.)
	// ==============================================
	Private _TES        := Space(15)
	//Private _cMENPAD    := Space(15)
	Private _cMENNOTA   := Space(100)
	// ==============================================

	Private aTitSE2		:= {}

	// _cProdut  := AllTrim(oGDQ2:aCols[ 1, nPCodSB1 ]) + "-" + Posicione('SB1', 1, FWxFilial('SB1')+oGDQ2:aCols[ 1, nPCodSB1 ], 'B1_DESC')
	_cTpSenar := &( "o" + cPFoBCTPS + "ZBCGDad"):aCols[ nAtZBC, nPZBCTPS ]
	if _cTpSenar=="F"
		_cTpSenar:="Folha"
	ElseIf _cTpSenar=="D"
		_cTpSenar:="Desconta"
	Else // If _cTpSenar=="V"
		_cTpSenar:="V@ Paga"
	EndIf

	// _V_A_L_I_D_A_Ç_Ã_O_
	_cPedido := ""
	For nI := 1 to Len(o1ZBCGDad:aCols)
		If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
			lTemTIK := .T.

			/*If !Empty(_cPedido) .and. _cPedido <> &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ]
				Aviso("Aviso", "Não é permitido criar complemento para diferentes pedidos. O pedido da linha: " + AllTrim(Str(nI)) +;
								", pedido: " + &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ] + ;
								", difere do pedido: " + _cPedido + ". Esta Operação sera cancelada.", {"Sair"} )
				lContinua := .F.
				Exit

			Else*/

				_cPedido := &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ]

				If Empty( &( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nI, nPZBCTNG ] )

					Aviso("Aviso", "Dados da negociação final não foram preenchidos na linha: " + AllTrim(Str(nI)) +;
								", pedido: " + &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ] + ;
								". Esta Operação sera cancelada.", {"Sair"} )
					lContinua := .F.
					Exit

				Else

					_cDoc := Posicione('SD1', 22, FWxFilial('SD1')+;
												&( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI /*nAtZBC*/, nPZBCPed ]+;
												&( "o" + cPFoBCPIt + "ZBCGDad"):aCols[ nI /*nAtZBC*/, nPZBCPIt ], 'D1_DOC' )
					If Empty(_cPedido) .or. Empty( _cDoc )
						Aviso("Aviso", ;
								'Não é possivel gerar complemento para este item. Nota Fiscal não localizada.' + CRLF + 'Este processo sera cancelado. ', ;
								{"Sair"} )
						lContinua := .F.  // Return nil
						Exit
						// Else
						// 	MsgInfo('NF: ' + SD1->D1_FILIAL + '-' + SD1->D1_DOC + '-' + SD1->D1_SERIE )
					EndIf

					// _T_O_T_A_L_I_Z_A_D_O_R_E_S_
					_cQuaZBC  += &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ]
					_cTotalNeg+= Iif( Empty( &( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nI, nPZBCTNG ] ), ;
												&( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nI, nPZBCTot ], ;
										&( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nI, nPZBCTNG ] )
					_cProdut += iIf(Empty(_cProdut),"",",") + &( "o" + cPFoBCPRD + "ZBCGDad"):aCols[ nI, nPZBCPRD ]
				EndIf
			//EndIf
		EndIf
	Next nI
	If !lContinua // nI <= Len(o1ZBCGDad:aCols)
		return nil
	EndIf

	// Validar se Tem algum item Tikado;
	If !lTemTIK
		Aviso("Aviso", "Não foi localizado nenhum pedido marcado para complemento.", {"Sair"} )
		Return nil
	EndIf

	aSize := MsAdvSize( .T. )
	For nI := 1 to Len(aSize)
		aSize[nI] := Iif( aSize[nI]==0, 0, aSize[nI]*0.75)
	Next nI

	AAdd( aObjects, { 100 , 070, .T. , .T. , .F. } )
	AAdd( aObjects, { 100 , 100, .T. , .T. , .F. } )
	AAdd( aObjects, { 100 , 060, .T. , .T. , .F. } )
	aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
	aPObjs := MsObjSize(aInfo, aObjects, .T., .F.)

	DEFINE MSDIALOG oDlgC TITLE OemToAnsi("Geração da Nota de Complemento de Entrada") From 0,0 to aSize[6],aSize[5] PIXEL // STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |
	// oDlgC:lMaximized := .T.

	// ================================================================================================================
	oGrpQ1 := TGroup():New( aPObjs[1,1]+nDist*3+nDist, aPObjs[1,2]+nDist, aPObjs[1,3]-nDist, aPObjs[1,4]-nDist,;
							"Dados da Negociação", oDlgC,,, .T.,)
	//                   Titulo,       Campo, Tipo,                 Tamanho,                 Decimal,                          Pict,                     Valid, Obrigat, Nivel, Inic Padr, F3,   When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
	aAdd(aField, { "Pedido"    , "_cPedido"  ,  "C", TamSX3("ZBC_PEDIDO")[1], TamSX3("ZBC_PEDIDO")[2], PesqPict("ZBC", "ZBC_PEDIDO"), /* { || U_Vd1MNT01() } */,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
	aAdd(aField, { "Fornecedor", "_cFornec"  ,  "C",                      20,                       0,                          "@!", /* { || U_Vd1MNT01() } */,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
	aAdd(aField, { "Quant."	   , "_cQuaZBC"  ,  "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) }    */,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
	aAdd(aField, { "R$ Negoc." , "_cTotalNeg",  "N", TamSX3("D1_TOTAL" )[1] , TamSX3("D1_TOTAL")[2]  , PesqPict("SD1", "D1_TOTAL" ) , /* { || VldCpo(2) }    */,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
	aAdd(aField, { "Tipo Senar", "_cTpSenar" ,  "C",                      08,                       0,                          "@!", /* { || U_Vd1MNT01() } */,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )

	aAdd(aField, { "Msg Padrao"  , "_cMENPAD"  ,  "C",                      03,                       0,                          "@!", /* { || U_Vd1MNT01() } */,     .F.,     1,        "", "SM4", "" ,    .F.,   .F.,   "",      1,         .F.,      "",      "N"} )
	aAdd(aField, { "Condição Pag", "_cCndPag"  ,  "C",                      03,                       0,                          "@!", { || ExistCpo("SE4") },     .F.,     1,        "", "SE4", "" ,    .F.,   .F.,   "",      1,         .F.,      "",      "N"} )
									// aTitSE2

	oMGetQ1 := MsMGet():New(,, 3/* nOpc */,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{0,0,0,0}/* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,;
							/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oGrpQ1,/*lF3*/,/*lMemoria*/, .F. /*lColumn*/,;
							nil /*caTela*/,/*lNoFolder*/, .T. /*lProperty*/,aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,;
							/*cTela*/)
	oMGetQ1:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	// ================================================================================================================
	oGrpQ2 := TGroup():New( aPObjs[1,3]+nDist, aPObjs[2,2]+nDist, aPObjs[2,3]-nDist, aPObjs[2,4]-nDist,;
							"Notas para Complementar", oDlgC,,, .T.,)
	aHeadEsp := {}
	aColsEsp := {}
	/*01*/ aAdd(aHeadEsp,{ " "                , "MARK"	 	    , "@BMP"	                   , 1                      , 0                      , "AllwaysTrue()", "" , "C", "", "V","","","","V","","",""})
	/*02*/ aAdd(aHeadEsp,{ "Tipo"  	          , "TIPO"	   	    , "@!"		                   , 15                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
	/*03*/ aAdd(aHeadEsp,{ "Filial"  	      , "D1_FILIAL"  	, PesqPict("SD1", "D1_FILIAL") , TamSX3("D1_FILIAL")[1] , TamSX3("D1_FILIAL")[2] , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
	/*04*/ aAdd(aHeadEsp,{ "Documento"        , "D1_DOC"  		, PesqPict("SD1", "D1_DOC")	   , TamSX3("D1_DOC")[1]    , TamSX3("D1_DOC")[2]    , "AllwaysTrue()", "" , "C", "", "R","","","","V","","",""})
	/*05*/ aAdd(aHeadEsp,{ "Serie"  	      , "D1_SERIE"  	, PesqPict("SD1", "D1_SERIE")  , TamSX3("D1_SERIE" )[1] , TamSX3("D1_SERIE")[2]  , "AllwaysTrue()", "" , "C", "", "R","","","","V","","",""})
	/*06*/ aAdd(aHeadEsp,{ "Item"  		      , "D1_ITEM"  	    , PesqPict("SD1", "D1_ITEM")   , TamSX3("D1_ITEM" )[1]  , TamSX3("D1_ITEM")[2]   , "AllwaysTrue()", "" , "C", "", "R","","","","V","","",""})
	/*07*/ aAdd(aHeadEsp,{ "Produto"          , "D1_COD"	    , "@!"		                   , 15                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
	/*08*/ aAdd(aHeadEsp,{ "Emissao"          , "D1_EMISSAO" 	, "@!"                         , 10                     , 0                      , "AllwaysTrue()", "" , "D", "", "R","","","","A","","",""})
	/*09*/ aAdd(aHeadEsp,{ "Quant."	          , "QUANT"   		, PesqPict("SD1", "D1_QUANT")  , TamSX3("D1_QUANT" )[1] , TamSX3("D1_QUANT")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
	/*10*/ aAdd(aHeadEsp,{ "R$ Tot NF Entrada", "D1_TOTAL"   	, PesqPict("SD1", "D1_TOTAL")  , TamSX3("D1_TOTAL" )[1] , TamSX3("D1_TOTAL")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
	/*11*/ aAdd(aHeadEsp,{ "R$ À Complementar", "VlrCompl"   	, PesqPict("SD1", "D1_TOTAL")  , TamSX3("D1_TOTAL" )[1] , TamSX3("D1_TOTAL")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
	/*12*/ aAdd(aHeadEsp,{ "R$ ICMS"          , "D1_VALICM"     , PesqPict("SD1", "D1_VALICM") , TamSX3("D1_VALICM")[1] , TamSX3("D1_VALICM")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
	/*13*/ aAdd(aHeadEsp,{ "R$ S/ ICMS"       , "VLR_S_ICMS"    , PesqPict("SD1", "D1_TOTAL")  , TamSX3("D1_TOTAL" )[1] , TamSX3("D1_TOTAL")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","V","","",""})
	/*14*/ aAdd(aHeadEsp,{ "R$ Senar"         , "D1_VLSENAR" 	, PesqPict("SD1", "D1_VLSENAR"), TamSX3("D1_VLSENAR")[1], TamSX3("D1_VLSENAR")[2], "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
	/*15*/ aAdd(aHeadEsp,{ "TES"  	          , "_TES"	   		, "@!"		                   , 15                     , 0                      , "U_fFindCustom('SF4', 15)", "" , "C", "", "R","","","","A","","",""})
	/*17*/ aAdd(aHeadEsp,{ "Msg Nota"         , "_cMENNOTA"	    , PesqPict("SF1", "F1_MENNOTA"), 100                    , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
	/*18*/ aAdd(aHeadEsp,{ "Tot Complementos" , "TOT_COMPL"  	, PesqPict("SD1", "D1_TOTAL")  , TamSX3("D1_TOTAL" )[1] , TamSX3("D1_TOTAL")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
	/*19*/ aAdd(aHeadEsp,{ "Tot Neg Contrato" , "TotNegZBC"  	, PesqPict("SD1", "D1_TOTAL")  , TamSX3("D1_TOTAL" )[1] , TamSX3("D1_TOTAL")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
	// /*16*/ aAdd(aHeadEsp,{ "Msg Padrao"       , "_cMENPAD"		, "@!"                         , 15                     , 0                      , "U_fFindCustom('SM4', 16)", "" , "C", "", "R","","","","A","","",""})
	nUsadEsp := len(aHeadEsp)

	nPCodSB1 := aScan( aHeadEsp, { |x|x[2]=="D1_COD" } )

	LoadNewGDados("PreNF", aHeadEsp, @aColsEsp, nUsadEsp, _cProdut)

	nPMrkNFC  := aScan( aHeadEsp, { |x| AllTrim(x[2]) == 'MARK'})
	oGDQ2:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE ,,,,,,,,,, oGrpQ2, aHeadEsp, aColsEsp)
	oGDQ2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGDQ2:oBrowse:BlDblClick := { || If( oGDQ2:oBrowse:nColPos == 1 .and. fCanSelNFC(), SetMark(oGDQ2, , nPMrkNFC), oGDQ2:EditCell() ) }

	// ================================================================================================================
	oGrpQ3 := TGroup():New( aPObjs[2,3]+nDist, aPObjs[3,2]+nDist, aPObjs[3,3]-nDist, aPObjs[3,4]-nDist,;
							"Valor Final da Nota Fiscal", oDlgC,,, .T.,)
	aField := {}
	//                       Titulo,     Campo, Tipo,                Tamanho,                Decimal,                          Pict,                         Valid, Obrigat, Nivel, Inic Padr, F3,   When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
	aAdd(aField, { "Quant. NF"     , "_cQuaNF",  "N", TamSX3("ZBC_QUANT")[1], TamSX3("ZBC_QUANT")[2], PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) }    */ ,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
	aAdd(aField, { "R$ NF Total"   , "_cVlrNF",  "N", TamSX3("ZBC_TOTAL")[1], TamSX3("ZBC_TOTAL")[2], PesqPict("ZBC", "ZBC_TOTAL" ), /* { || VldCpo(2) }    */ ,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
	aAdd(aField, { "Total Compl NF", "_cTotNF",  "N", TamSX3("ZBC_TOTAL")[1], TamSX3("ZBC_TOTAL")[2], PesqPict("ZBC", "ZBC_TOTAL" ), /* { || VldCpo(2) }    */ ,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )

	oMGetQ3 := MsMGet():New(,, 3/* nOpc */,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{0,0,0,0}/* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,;
							/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oGrpQ3,/*lF3*/,/*lMemoria*/, .F. /*lColumn*/,;
							nil /*caTela*/,/*lNoFolder*/, .T. /*lProperty*/,aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,;
							/*cTela*/)
	oMGetQ3:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	// ================================================================================================================

	_cTotNF := 0
	// _cTotNF := _cTotalNeg // - _cVlrNF
	// Desenhando todos os quadros e somando os campos
	For nI := 1 to Len(oGDQ2:aCols)
		// If Empty( oGDQ2:aCols[ nI, nPMrkNFC] )
			oGDQ2:aCols[ nI, nPMrkNFC] := "LBNO"
		// EndIf

		// Colocar Descricao do BOV
		_cCodBOV := AllTrim( oGDQ2:aCols[ nI, nPCodSB1 ] )
		oGDQ2:aCols[ nI, nPCodSB1 ] := AllTrim(_cCodBOV) + "-" + Posicione('SB1', 1, FWxFilial('SB1')+_cCodBOV, 'B1_DESC')

		// _P_R_E_E_N_C_H_E_R_
		If AllTrim( oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="TIPO" } ) ] ) == '1-NF ENTRADA'
			_cQuaNF += oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="QUANT" } ) ] // D1_QUANT
			// _cVlrNF += oGDQ2:aCols[ nI, 12 ] // VLR_S_ICMS // Luana no dia 28.03.19-> pediu para nao incluir o ICMS
			_cVlrNF += oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="D1_TOTAL" } ) ] // R$ NF

			//	nSB1TTComp := 0
			//	For nJ := 1 to Len(oGDQ2:aCols)
			//
			//		If AllTrim( oGDQ2:aCols[ nJ, aScan( aHeadEsp, { |x|x[2]=="TIPO" } ) ] ) <> '1-NF ENTRADA' .or. ;
			//			AllTrim(_cCodBOV) <> SubStr(oGDQ2:aCols[ nJ, nPCodSB1 ], 1, Len(_cCodBOV))
			//			Loop
			//		EndIf
			//
			//	 	nSB1TTComp += oGDQ2:aCols[ nJ, aScan( aHeadEsp, { |x|x[2]=="D1_TOTAL" } ) ]
			//	Next nJ

			nPos 	 := aScan( &( "o" + cPFoBCPRD + "ZBCGDad"):aCols, { |x| AllTrim(x[nPZBCPRD])== AllTrim(_cCodBOV)} )
			_nVlrNeg := Iif( Empty( &( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nPos, nPZBCTNG ] ), ;
												&( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nPos, nPZBCTot ], ;
										&( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nPos, nPZBCTNG ] )

			// Tot Neg Contrato
			oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="TotNegZBC" } ) ] := _nVlrNeg

			_cTotNF += oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="VlrCompl" } ) ]

			// oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="VlrCompl" } ) ] := ; /*oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="D1_TOTAL" } ) ]*/
			// 																	nSB1TTComp - _nVlrNeg

		EndIf

		//	If AllTrim( oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="TIPO" } ) ] ) == '1-NF ENTRADA' ;
		//		.AND. &( "o" + cPFoBCTPS + "ZBCGDad"):aCols[ nAtZBC, nPZBCTPS ] == "V"
		//		_cSohNF += oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="D1_TOTAL" } ) ]
		//	EndIf
	Next nI

	// Calcular Senar no complemento
	// If &( "o" + cPFoBCTPS + "ZBCGDad"):aCols[ nAtZBC, nPZBCTPS ] == "V"
	//	_cTotNF := _cTotalNeg - _cVlrNF +( _cSohNF / ((100-&( "o" + cPFoBCAQS + "ZBCGDad"):aCols[ nAtZBC, nPZBCAQS ])/100) )
	//Else
	// 	_cTotNF := _cTotalNeg - _cVlrNF
	//EndIf

	AAdd( aButtons, { "AUTOM", { || fTitPagar() }, "Alterar Vencimentos (F11)" } )
	//AAdd( aButtons, { "AUTOM", { || fTitPagar() }, "Alterar Vencimentos (F11)" } )
	SetKey( VK_F11, { || fTitPagar() })

	ACTIVATE MSDIALOG oDlgC ;
			ON INIT EnchoiceBar(oDlgC,;
								{ || nOpcA := 1, Iif( VldOkNFE() .AND. Obrigatorio(aGets, aTela),;
															oDlgC:End(),;
															nOpcA := 0)},;
								{ || nOpcA := 0, oDlgC:End() },, aButtons )
	//alert("TESTE 1") 
	If nOpcA == 1
	//alert("TESTE 2") 

		For nI := 1 to Len(oGDQ2:aCols)
			If oGDQ2:aCols[ nI, nPMrkNFC] == 'LBTIK'
				nContTIK   += 1
				// nTotQtdTIK += oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="QUANT" } ) ] // D1_QUANT
			EndIf
		Next nI

		If nContTIK == 0
			MsgInfo("Não foi selecionada nenhuma Nota Fiscal de Entrada.", "Aviso")
		Else

			lErro := ExecAutoCompl(@cCodigo)
			If !lErro
				// Atualizar contador na SX5
				cUpd := " UPDATE " + RetSqlName('SX5') + CRLF
				cUpd += " 	SET X5_DESCRI ='"+cCodigo+"', " + CRLF
				cUpd += " 		X5_DESCSPA='"+cCodigo+"', " + CRLF
				cUpd += " 		X5_DESCENG='"+cCodigo+"'" + CRLF
				cUpd += " WHERE X5_FILIAL='"+ M->ZCC_FILIAL +"'" + CRLF
				cUpd += "   AND X5_TABELA='01'" + CRLF

				cUpd += "   AND X5_CHAVE='2'" + CRLF
				cUpd += "   AND D_E_L_E_T_=' '" + CRLF

				if (TCSqlExec(cUpd) < 0)
					conout("TCSQLError() " + TCSQLError())
				//else
					// MsgInfo("Codigo de chave atualizado com sucesso! ", "Aviso")
				EndIf
			EndIf
		EndIf

	Else
		Alert('A Geração da Nota Complementar de Entrada será cancelada.')
	EndIf

	// Voltar Atalho, pois esta sendo finalizado a tela;
	Set Key VK_F11 To fGerarCompl()
	
	MBSaveLog():FULLWrite(, .F., "Fim:  fGerarCompl(nLZBC)")
Return nil

/* MJ : 25.01.2019
	-> Pode salvar  - gerar pedido ????*/
Static Function VldOkNFE()
	MBSaveLog():FULLWrite(, .F., "Inicio:  VldOkNFE()")

	Local lRet	:= .T.
	Local nI	:= 0
	For nI := 1 to Len(oGDQ2:aCols)
		If oGDQ2:aCols[ nI, nPMrkNFC] == 'LBTIK'
			If Empty( oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="_TES" } ) ] )
				MsgInfo("TES nao preenchida na linha: " + cValToChar(nI), "Aviso")
				lRet := .F.
				exit
			EndIf
		EndIf
	Next nI

	If lRet
		If (_cTotNF + _cVlrNF) > _cTotalNeg
			lRet := MsgYesNo("O valor Informado para nota complementar: ["+AllTrim(Transform(_cTotNF+_cVlrNF,X3Picture("D1_TOTAL")))+"] ultrapassa o configurado no contrato: ["+AllTrim(Transform(_cTotalNeg,X3Picture("D1_TOTAL")))+"]."+CRLF+"Deseja continuar ?")
		EndIf
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim:  VldOkNFE()")

Return lRet


/* MJ : 23.04.2019 */
Static Function fTitPagar()
	MBSaveLog():FULLWrite(, .F., "Inicio:  fTitPagar()")

	Local nGDOpc        := GD_UPDATE // GD_INSERT + GD_DELETE
	Local oDlgSE2		:= nil
	Local nOpcA			:= 0
	Local oGrp			:= nil, oGdDad := nil
	Local nI            := 0
	Local _aHead 		:= {}
	Local _aCols 		:= {}
	Local VlrTotal		:= 0
	Local lModif		:= .F.
	Private aGets		:= {}
	Private aTela		:= {}

	DEFINE MSDIALOG oDlgSE2 TITLE OemToAnsi("Titulos a Pagar") From 0,0 to 250, 350 PIXEL // STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |

	For nI := 1 to Len(oGDQ2:aCols)
		If oGDQ2:aCols[ nI, nPMrkNFC] == 'LBTIK'
			VlrTotal += oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="VlrCompl" } ) ]
		EndIf
	Next nI

	If Empty( VlrTotal )
		MsgInfo( "Valor a complementar não localizado, ou nao foi informado, ou nenhuma NF Entrada foi selecionada." + CRLF + ;
				"Esta Operação será cancelada.", "Aviso" )
		Return nil
	ElseIf Empty( _cCndPag )
		MsgInfo( "Condição de pagamento nao informada nas tela anterior." + CRLF + ;
				"Esta Operação será cancelada.", "Aviso" )
		Return nil
	EndIf

	aAdd(_aHead,{ "Parcela"   , "E2_PARCELA", PesqPict("SE2", "E2_PARCELA"), TamSX3("E2_PARCELA")[1], TamSX3("E2_PARCELA")[2], "AllwaysTrue()", "" , "C", "", "R","","","","V","","",""})
	aAdd(_aHead,{ "Valor Tit.", "E2_VALOR"  , PesqPict("SE2", "E2_VALOR")  , TamSX3("E2_VALOR" )[1] , TamSX3("E2_VALOR")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","V","","",""})
	aAdd(_aHead,{ "Vencimento", "E2_VENCREA", "@!"                         , 10                     , 0                      , "AllwaysTrue()", "" , "D", "", "R","","","","A","","",""})

	aTitSE2 := Condicao( VlrTotal, _cCndPag )

	// Carregar vetor
	_aCols := {}
	For nI := 1 to Len(aTitSE2)
		aAdd( _aCols , { StrZero( nI, 2), aTitSE2[nI, 2], aTitSE2[nI, 1], .F. } )
	Next nI

	oGrp := TGroup():New( 0, 0, 0, 0, "Parcelas", oDlgSE2,,, .T.,)
	oGrp:Align   := CONTROL_ALIGN_ALLCLIENT
	oGdDad:= MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , /* "+ZPE_ITEM" */, , , 99, , , /* "u_ZPEDelOk()" */, oGrp, ;
										aClone(_aHead), aClone( _aCols ) )
	oGdDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgSE2 ;
			ON INIT EnchoiceBar(oDlgSE2,;
								{ || nOpcA := 1, Iif(/*  VldOkNFE() .and. */ Obrigatorio(aGets, aTela),;
															oDlgSE2:End(),;
															nOpcA := 0)},;
								{ || nOpcA := 0, oDlgSE2:End() },, /* aButtons */ )
	If nOpcA == 1

		If lModif := oGdDad:lModified
			For nI:=1 to Len( oGdDad:aCols )
				if lModif := oGdDad:aCols[nI, 3] <> _aCols[nI, 3]
					Exit
				EndIf
			Next nI
		EndIf

		If lModif
			// Alert('Foi Modificado')
			aTitSE2 := oGdDad:aCols
		Else
			// Alert('NÃO Modificado')
			aTitSE2 := {}
		EndIf

	EndIf
	MBSaveLog():FULLWrite(, .F., "Fim:  fTitPagar()")
	
Return nil


/* MJ : 25.01.2019
	-> Customizacao para pesquisa (consulta padrao);
	MJ: 28.03.2019
	-> Inclusao da Formulas
*/
User Function fFindCustom(cTab, nPos)
	MBSaveLog():FULLWrite(, .F., "Inicio:  fFindCustom("+cTab+", "+cValToChar(nPos)+")")

	Local aArea		:= GetArea()
	Local lRet		:= .F.
	// Alert('Coluna: ' + cValToChar(oGDQ2:oBrowse:nColPos))

	If oGDQ2:oBrowse:nColPos == nPos // 15 == TES - SF4 .or. 16 == "Msg Padrao" , "F1_MENPAD" - SM4
	    lRet := Conpad1( /*[ uPar1 ]*/,;
						 /*[ uPar2 ]*/,;
						 /*[ uPar3 ]*/,;
						 cTab /*[ cAlias ]*/,;
						 /*[ cCampoRet ]*/,;
						 /*[ uPar6 ]*/,;
						 .F. /*[ lOnlyView ]*/,;
						 /*[ cVar ]*/,;
						 /*[ uPar9 ]*/,;
						 /*[ uContent ]*/,;
						 /*[ Interno ]*/,;
						 /*[ Interno ]*/,;
						 iIf(cTab=="SF4","F4_TIPO=='E'","") /*[ cFilterDefault ]*/ )
		If lRet
			If AllTrim( oGDQ2:aCols[ oGDQ2:oBrowse:nAt, aScan( oGDQ2:aHeader, { |x|x[2]=="TIPO" } ) ] ) == '1-NF ENTRADA'
				If nPos==15 // 15 == TES - SF4
					oGDQ2:aCols[ oGDQ2:oBrowse:nAt, aScan( oGDQ2:aHeader, { |x|x[2]=="_TES" } ) ] := SF4->F4_CODIGO + "-" + SF4->F4_TEXTO
				// ElseIf nPos==16 // 16 == "Msg Padrao" , "F1_MENPAD" - SM4
				// 	oGDQ2:aCols[ oGDQ2:oBrowse:nAt, aScan( oGDQ2:aHeader, { |x|x[2]=="_cMENPAD" } ) ]  := SM4->M4_CODIGO + "-" + SM4->M4_DESCR
				EndIf
				oGDQ2:aCols[ oGDQ2:oBrowse:nAt, nPMrkNFC] := 'LBTIK'
			Else
				Alert("Somente Notas Fiscais de entrada podem ser selecionada")
				oGDQ2:aCols[ oGDQ2:oBrowse:nAt, aScan( oGDQ2:aHeader, { |x|x[2]=="_TES" } ) ] 	  := Space(15)
				// oGDQ2:aCols[ oGDQ2:oBrowse:nAt, aScan( oGDQ2:aHeader, { |x|x[2]=="_cMENPAD" } ) ] := Space(15)
				&(ReadVar()) := Space(15)
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
	
	MBSaveLog():FULLWrite(, .F., "Fim:  fFindCustom()")

Return .T.

/* MJ : 23.01.2019
	-> Criar Pré Nota de Entrada;
*/
// Static Function ExecAutoCompl(nI, cCodigo, nTotQtdTIK)
Static Function ExecAutoCompl(cCodigo)
	MBSaveLog():FULLWrite(, .F., "Fim:  ExecAutoCompl("+cCodigo+")")

	Local aArea			:= GetArea()
	Local aAreaSF1		:= SF1->(GetArea())
	Local aAreaSE2		:= SE2->(GetArea())
	//Local aAreaSD1 		:= SD1->(GetArea())
	Local nOpc 			:= 3
	Local nI            := 0
	Local aCabec      	:= {}
	Local aItens      	:= {}
	Local aLinha      	:= {}
	Loca _cMSG			:= ""

	Private lMsHelpAuto := .F.
	Private lMsErroAuto := .F.

	BeginSQL alias "TMP"
		%noParser%
		SELECT X5_DESCRI
		FROM %table:SX5% SX5
		WHERE X5_FILIAL		= %exp:M->ZCC_FILIAL%
		AND X5_TABELA		= '01'
		AND X5_CHAVE		= '2'
		AND SX5.%NotDel%
	EndSQL

	If !TMP->(Eof())
		cCodigo := TMP->X5_DESCRI
	EndIf
	TMP->( DbCloseArea() )

	aAdd( aCabec, { 'F1_TIPO'		, 'C'								 , Nil } ) // C = COMPLEMENTO
	aAdd( aCabec, { 'F1_TPCOMPL'	, '1'								 , Nil } ) // 1 = PRECO
	aAdd( aCabec, { 'F1_FORMUL'		, 'S'								 , Nil } )
	aAdd( aCabec, { 'F1_DOC'		, cCodigo							 , Nil } )
	aAdd( aCabec, { "F1_SERIE"		, "2"								 , Nil } ) // PARA COMPLEMENTO DE PRECO = SERIE 2
	aAdd( aCabec, { "F1_EMISSAO"	, dDataBase							 , Nil } )
	aAdd( aCabec, { "F1_X_DTINC"	, dDataBase							 , Nil } ) 
	aAdd( aCabec, { 'F1_FORNECE'	, M->ZCC_CODFOR						 , Nil } )
	aAdd( aCabec, { 'F1_LOJA'		, M->ZCC_LOJFOR						 , Nil } )
	aAdd( aCabec, { "F1_ESPECIE"	, "SPED"							 , Nil } )
	aAdd( aCabec, { "F1_STATUS"		, 'A'								 , Nil } )
	// aAdd( aCabec, { "F1_MENPAD"		, SubS(oGDQ2:aCols[ 1, aScan( oGDQ2:aHeader, { |x|x[2]=="_cMENPAD" } ) ],1,3)	 , Nil } )
	// aAdd( aCabec, { "F1_COND"		, '001'								 , Nil } )
	aAdd( aCabec, { "F1_MENPAD"		, _cMENPAD 							 , Nil } )
	aAdd( aCabec, { "F1_COND"		, _cCndPag							 , Nil } )

	For nI := 1 to Len(oGDQ2:aCols)
		If oGDQ2:aCols[ nI, nPMrkNFC] == 'LBTIK'
			
			_cMSG += Iif(Empty(_cMSG),"",CRLF) + AllTrim(oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="_cMENNOTA" } ) ])

			aLinha := {}
			aAdd( aLinha, { 'D1_COD'	 , SubS(oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="D1_COD" } ) ],1,15)	     , Nil } ) // aAdd( aItens, { "D1_QUANT"		, 1				, Nil } )
			aAdd( aLinha, { "D1_VUNIT"	 , oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="VlrCompl" } ) ]     , Nil } )
			aAdd( aLinha, { "D1_TOTAL"	 , oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="VlrCompl" } ) ]     , Nil } )
			aAdd( aLinha, { "D1_TES"	 , SubS(oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="_TES" } ) ],1,3), Nil } )
			aAdd( aLinha, { "D1_NFORI"	 , oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="D1_DOC" } ) ]       , Nil } ) // 000005890
			aAdd( aLinha, { "D1_SERIORI" , oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="D1_SERIE" } ) ]     , Nil } ) // 2
			aAdd( aLinha, { "D1_ITEMORI" , oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="D1_ITEM" } ) ]      , Nil } ) // 0001

			aAdd(aItens,aLinha)
		EndIf
	Next nI
	aAdd( aCabec, { "F1_MENNOTA"	, _cMSG			 , Nil } )

		MsgRun("Aguarde, gerando Pré-Nota de Entrada..." + AllTrim(cCodigo),, ;
				{|| MSExecAuto ( {|x,y,z| MATA103(x,y,z) }, aCabec, aItens, nOpc )})

	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
	Else

		MsgRun("Aguarde, atualizando Titulos a Pagar." + AllTrim(cCodigo),, ;  
				{|| MT100GE3() })

	/* 	If SD1->(DbSeek(FWxFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)) )
				RecLock("SE2", .F.)
					SE2->E2_X_CAMPO := SD1->D1_X_CAMPO
				SE2->(MsUnLock())
			EndIf */

		cCodigo := Soma1(AllTrim(cCodigo))
	EndIf

	//RestArea(aAreaSD1)
	RestArea(aAreaSE2)
	RestArea(aAreaSF1)
	RestArea(aArea)

	MBSaveLog():FULLWrite(, .F., "Fim:  ExecAutoCompl("+cCodigo+")")

Return lMsErroAuto
/* 
----	Igor Oliveira 
----	12.01.2023 
----	Complementa gravação de Títulos a Pagar
----	MT100GE2()
 */
STATIC Function MT100GE3()
	MBSaveLog():FULLWrite(, .F., "Inicio:   MT100GE3()")
/* 	Local aTitAtual := PARAMIXB[1]
	Local nOpc := PARAMIXB[2]
	Local aHeadSE2:= PARAMIXB[3]
	Local aParcelas := ParamIXB[5]
	Local nX := ParamIXB[4] */
	//.....Exemplo de customização
/* 	If nOpc == 1 //.. inclusao
		SE2->E2_VENCTO := aTitSE2[1][3]
	Endif */
	Local nI,nJ         := 0

	SE2->(DbSetOrder(6)) // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	For nI := 1 to Len(oGDQ2:aCols)
		If oGDQ2:aCols[ nI, nPMrkNFC] == 'LBTIK'
			for nJ := 1 to Len(aTitSE2)
				If SE2->( DbSeek( FWxFilial("SE2") +;
									M->ZCC_CODFOR +;
									M->ZCC_LOJFOR +;
									PADR("2",Len(Space(TamSx3("E2_PREFIXO")[1])))+;
									oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="D1_DOC" } ) ]+;
									aTitSE2[1][1]+;
									PADR("NF",Len(Space(TamSx3("E2_TIPO")[1])) )))
					
					IF 	SE2->E2_VENCTO != aTitSE2[1][3] .OR. SE2->E2_VENCREA != aTitSE2[1][3] 
						RecLock("SE2", .F.)
							SE2->E2_VENCREA  := aTitSE2[1][3]
							SE2->E2_VENCTO 	 := aTitSE2[1][3]
							SE2->E2_VENCORI  := aTitSE2[1][3]
						SE2->(MsUnLock())	
					EndIf
				EndIf
			Next nJ
		EndIf
	Next nI

	//aTitSE2 := {}
	MBSaveLog():FULLWrite(, .F., "Fim:   MT100GE3()")

Return NIL
/* MJ : 24.01.2019 */
Static Function fCanSelNFC()
	MBSaveLog():FULLWrite(, .F., "Inicio:   fCanSelNFC()")

	Local lRet	:= .T.
	Local nAt 	:= oGDQ2:oBrowse:nAt
	If AllTrim( oGDQ2:aCols[ nAt, 02 ] ) <> '1-NF ENTRADA'
		lRet := .F.
		Alert("Somente Notas Fiscais de entrada podem ser selecionada")
	EndIf

	MBSaveLog():FULLWrite(, .F., "Fim:   fCanSelNFC()")

Return lRet

/* MJ : 18.01.2019
	-> Processamento/Carregamento da NewGetDados;

	ex: LoadNewGDados("NFEntrada", aHeadEsp, @aColsEsp, nUsadEsp)
*/
Static Function LoadNewGDados(cTipo, aHeadEsp, aColsEsp, nUsadEsp, _cProdut )
	MBSaveLog():FULLWrite(, .F., "Inicio: LoadNewGDados("+cTipo+", aHeadEsp, aColsEsp, nUsadEsp, _cProdut )")

	Local cSql			:= ""
	Local nX			:= 0

	Default _cProdut	:= ""

	If cTipo == "NFEntrada"

		cSql := " WITH ENTRADA AS ( " + CRLF
		cSql += " 		SELECT '1-NF ENTRADA' AS TIPO, " + RetSQLName('SD1') + ".R_E_C_N_O_, D1_FILIAL+'-'+D1_DOC+'-'+D1_SERIE NOTA_FISCAL, D1_FORNECE+'-'+D1_LOJA COD_FORNECE, RTRIM(" + RetSQLName('SA2') + ".A2_NOME) A2_NOME, D1_EMISSAO, D1_COD, D1_UM, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_VALICM, D1_CF, D1_X_KM, D1_X_PESCH, D1_X_EMBDT, D1_X_EMBHR, D1_X_CHEDT, D1_X_CHEHR, D1_TES, F4.F4_ESTOQUE, D1_LOCAL " + CRLF
		cSql += " 		  FROM " + RetSQLName('SD1') + "" + CRLF
		cSql += " 		  JOIN " + RetSQLName('SA2') + " ON " + CRLF
		cSql += " 			   D1_FORNECE = A2_COD " + CRLF
		cSql += " 		   AND D1_LOJA = A2_LOJA " + CRLF
		cSql += " 		   AND " + RetSQLName('SA2') + ".D_E_L_E_T_ = ' '" + CRLF
		cSql += " 		  JOIN " + RetSQLName('SF4') + " F4 ON " + CRLF
		cSql += " 		       F4_FILIAL = '" + FWxFilial('SF4') + "' " + CRLF
		cSql += " 		   AND F4_CODIGO = D1_TES " + CRLF
		cSql += " 		   AND F4.D_E_L_E_T_ = ' '  " + CRLF
		cSql += " 		  WHERE D1_QUANT > 0" + CRLF
		cSql += " 				AND " + RetSQLName('SD1') + ".D_E_L_E_T_ = ' '" + CRLF
		cSql += " 				AND D1_TIPO = 'N' " + CRLF
		cSql += " 		        AND D1_FILIAL+RTRIM(D1_COD)+D1_FORNECE+D1_LOJA+D1_PEDIDO IN" + CRLF
		cSql += " 					(" + CRLF
		cSql += " 						SELECT DISTINCT ZBC_FILIAL+RTRIM(ZBC_PRODUT)+ZBC_CODFOR+ZBC_LOJFOR+ZBC_PEDIDO" + CRLF
		cSql += " 						  FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += " 						 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
		cSql += " 						   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += " 					) " + CRLF
		cSql += " 		), " + CRLF
		cSql += " COMPLEMENTO AS ( " + CRLF
		cSql += " 		SELECT '2-NF COMPLEMENTO' AS TIPO, D.R_E_C_N_O_, D1_FILIAL+'-'+D1_DOC+'-'+D1_SERIE NOTA_FISCAL, D1_FORNECE+'-'+D1_LOJA COD_FORNECE, RTRIM(" + RetSQLName('SA2') + ".A2_NOME) A2_NOME, D.D1_EMISSAO, D.D1_COD, D.D1_UM, D.D1_QUANT, D.D1_VUNIT, D.D1_TOTAL, D.D1_VALICM, D.D1_CF, D.D1_X_KM, D.D1_X_PESCH, D.D1_X_EMBDT, D.D1_X_EMBHR, D.D1_X_CHEDT, D.D1_X_CHEHR,D.D1_TES, F4.F4_ESTOQUE, D.D1_LOCAL " + CRLF
		cSql += "  FROM SF1010 F" + CRLF
		cSql += " 	  JOIN " + RetSQLName('SD1') + " D	 ON F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE " + CRLF
		cSql += " 							AND F1_LOJA=D1_LOJA AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' '" + CRLF
		cSql += " 	  JOIN " + RetSQLName('SA2') + "	 ON A2_FILIAL=' ' AND D.D1_FORNECE = A2_COD AND D.D1_LOJA = A2_LOJA AND " + RetSQLName('SA2') + ".D_E_L_E_T_ = ' '  " + CRLF
		cSql += " 	  JOIN ENTRADA E ON E.D1_COD = D.D1_COD " + CRLF
		cSql += " 	  JOIN " + RetSQLName('SF4') + " F4 ON " + CRLF
		cSql += " 		   F4_FILIAL = '" + FWxFilial('SF4') + "' " + CRLF
		cSql += " 	  AND F4_CODIGO = D.D1_TES " + CRLF
		cSql += " 	   AND F4.D_E_L_E_T_ = ' '  " + CRLF
		cSql += " 	 WHERE F.F1_TIPO = 'C'" + CRLF
		cSql += " 	   AND F.F1_TPCOMPL='1'" + CRLF
		cSql += " 	   AND D.D1_QUANT = 0  " + CRLF
		cSql += "    	      AND D.D1_FILIAL+RTRIM(D.D1_COD)+D.D1_FORNECE+D.D1_LOJA IN" + CRLF
		cSql += "    				(" + CRLF
		cSql += "    					SELECT DISTINCT ZBC_FILIAL+RTRIM(ZBC_PRODUT)+ZBC_CODFOR+ZBC_LOJFOR" + CRLF
		cSql += "    					  FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += "    					 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
		cSql += "    					   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += " 				) " + CRLF
		cSql += " 		), " + CRLF
		cSql += " FRETE AS ( " + CRLF
		cSql += " 		SELECT '3-NF FRETE' AS TIPO, D.R_E_C_N_O_, D1_FILIAL+'-'+D1_DOC+'-'+D1_SERIE NOTA_FISCAL, D1_FORNECE+'-'+D1_LOJA COD_FORNECE, RTRIM(" + RetSQLName('SA2') + ".A2_NOME) A2_NOME, D.D1_EMISSAO, D.D1_COD, D.D1_UM, D.D1_QUANT, D.D1_VUNIT, D.D1_TOTAL, D.D1_VALICM, D.D1_CF, D.D1_X_KM, D.D1_X_PESCH, D.D1_X_EMBDT, D.D1_X_EMBHR, D.D1_X_CHEDT, D.D1_X_CHEHR,  D.D1_TES, F4.F4_ESTOQUE, D.D1_LOCAL" + CRLF
		cSql += "  FROM SF1010 F" + CRLF
		cSql += " 	  JOIN " + RetSQLName('SD1') + " D	 ON F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE " + CRLF
		cSql += " 							AND F1_LOJA=D1_LOJA AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' '" + CRLF
		cSql += " 	  JOIN " + RetSQLName('SA2') + "	 ON A2_FILIAL=' ' AND D.D1_FORNECE = A2_COD AND D.D1_LOJA = A2_LOJA AND " + RetSQLName('SA2') + ".D_E_L_E_T_ = ' '  " + CRLF
		cSql += " 	  JOIN ENTRADA E ON E.D1_COD = D.D1_COD " + CRLF
		cSql += " 	  JOIN " + RetSQLName('SF4') + " F4 ON " + CRLF
		cSql += " 		   F4_FILIAL = '" + FWxFilial('SF4') + "' " + CRLF
		cSql += " 	   AND F4_CODIGO = D.D1_TES" + CRLF
		cSql += " 	   AND F4.D_E_L_E_T_ = ' '  " + CRLF
		// cSql += " 	   -- AND E.COD_FORNECE <> F.D1_FORNECE+F.D1_LOJA
		cSql += " 	 WHERE F.F1_TIPO = 'C'" + CRLF
		cSql += " 	   AND F.F1_TPCOMPL='3'" + CRLF
		cSql += " 	   AND D.D1_QUANT = 0  " + CRLF
		cSql += " 	   AND D.D1_FILIAL+RTRIM(D.D1_COD) IN (" + CRLF
		cSql += " 				SELECT DISTINCT ZBC_FILIAL+RTRIM(ZBC_PRODUT) " + CRLF
		cSql += " 				  FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += " 				 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
		cSql += " 				   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += " 				) " + CRLF
		cSql += " 		) " + CRLF
		cSql += "" + CRLF
		cSql += " SELECT * FROM ENTRADA " + CRLF
		cSql += " UNION " + CRLF
		cSql += " SELECT * FROM COMPLEMENTO " + CRLF
		cSql += " UNION " + CRLF
		cSql += " SELECT * FROM FRETE " + CRLF
		cSql += "" + CRLF
		cSql += " ORDER BY TIPO, D1_COD, D1_EMISSAO, 2" + CRLF

		MBSaveLog():FULLWrite(, .F., "LoadNewGDados() - "+cTipo+" - Fim")

	ElseIf cTipo == "oGetF3aQ2"

		cSql := " SELECT E2_FORNECE+E2_LOJA+' - '+E2_NOMFOR FORNECEDOR,E2_NUM, E2_TIPO, E2_PREFIXO, E2_PARCELA, E2_EMISSAO, E2_VENCREA, E2_VALOR, E2_SALDO, E2_HIST, RTRIM(E2_NATUREZ)+' - '+ED.ED_DESCRIC NATUREZA, E2.R_E_C_N_O_ " + CRLF
		cSql += " FROM " + RetSQLName('SE2') + " E2 " + CRLF
		cSql += " JOIN " + RetSQLName('SED') + " ED ON " + CRLF
		cSql += " 	 ED_FILIAL = ' '" + CRLF
		cSql += "  AND ED_CODIGO = E2_NATUREZ" + CRLF
		cSql += "  AND ED.D_E_L_E_T_ = ' '" + CRLF
		cSql += "   WHERE ( " + CRLF
		cSql += " 	  E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
		cSql += " 		  						    SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_CODIGO)" + CRLF
		cSql += " 		  						      FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += " 		  							 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
		cSql += " 									   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += " 									) " + CRLF
		cSql += " 	 OR " + CRLF
		cSql += " 	 E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
		cSql += " 		  						    SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PEDIDO)" + CRLF
		cSql += " 		  						      FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += " 		  							 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
		cSql += " 									   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += " 									) " + CRLF
		cSql += " 	OR " + CRLF
		cSql += " 	E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
		cSql += " 								  SELECT D1_FORNECE+D1_LOJA+RTRIM(D1_DOC)" + CRLF
		cSql += " 								    FROM " + RetSQLName('SD1') + "" + CRLF
		cSql += " 									WHERE D1_FORNECE+D1_LOJA+D1_PEDIDO  IN ( " + CRLF
		cSql += " 																		 SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PEDIDO)" + CRLF
		cSql += " 		  																   FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += " 		  																  WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
		cSql += " 																		    AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += " 																		  ) " + CRLF
		cSql += " 								 " + CRLF
		cSql += " 								) " + CRLF
		cSql += " 	OR " + CRLF
		cSql += " 	E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
		cSql += " 								  SELECT D1_FORNECE+D1_LOJA+RTRIM(D1_DOC)" + CRLF
		cSql += " 								    FROM " + RetSQLName('SD1') + "" + CRLF
		cSql += " 									WHERE D1_FORNECE+D1_LOJA+D1_COD IN ( " + CRLF
		cSql += " 																		 SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PRODUT)" + CRLF
		cSql += " 		  																   FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += " 		  																  WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
		cSql += " 																		    AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += " 																		  ) " + CRLF
		cSql += " 								 " + CRLF
		cSql += " 								) " + CRLF
		cSql += "" + CRLF
		cSql += " ) " + CRLF
		cSql += " AND E2.D_E_L_E_T_ = ' '" + CRLF
		//cSql += " ORDER BY E2_EMISSAO, E2_TIPO, E2.R_E_C_N_O_ " + CRLF
		MBSaveLog():FULLWrite(, .F., "LoadNewGDados() - "+cTipo+" - Fim")
	ElseIf cTipo == "oGetF3bQ2"

		cSql := " SELECT E5_FILIAL, E5_TIPO, E5_PREFIXO, E5_MOTBX,  E5_NATUREZ, E5_BENEF, E5_HISTOR, E5_VALOR, E5_DOCUMEN, E5_BANCO+ ' - '+E5_AGENCIA+' - '+E5_CONTA BANCO " + CRLF
		cSql += " FROM SE5010 WHERE E5_FILIAL+E5_NUMERO+E5_FORNECE+E5_LOJA IN ( " + CRLF
		cSql += " SELECT E2_FILIAL+E2_NUM+E2_FORNECE+E2_LOJA  -- E2_FORNECE+E2_LOJA+' - '+E2_NOMFOR FORNECEDOR,E2_NUM, E2_TIPO, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_EMISSAO, E2_VENCREA, E2_VALOR, E2_SALDO, E2_HIST, RTRIM(E2_NATUREZ)+' - '+ED.ED_DESCRIC NATUREZA " + CRLF
		cSql += " FROM " + RetSQLName('SE2') + " E2 " + CRLF
		cSql += " JOIN " + RetSQLName('SED') + " ED ON " + CRLF
		cSql += " 	 ED_FILIAL = ' '" + CRLF
		cSql += "  AND ED_CODIGO = E2_NATUREZ" + CRLF
		cSql += "  AND ED.D_E_L_E_T_ = ' '" + CRLF
		cSql += "   WHERE ( " + CRLF
		cSql += " 	  E2_FILIAL+E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
		cSql += " 		  						    SELECT ZBC_FILIAL+ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_CODIGO)" + CRLF
		cSql += " 		  						      FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += " 		  							 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
		cSql += " 									   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += "     								   AND D_E_L_E_T_ = ' '" + CRLF
		cSql += " 									) " + CRLF
		cSql += " 	 OR " + CRLF
		cSql += " 	 E2_FILIAL+E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
		cSql += " 		  						    SELECT ZBC_FILIAL+ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PEDIDO)" + CRLF
		cSql += " 		  						      FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += " 		  							 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
		cSql += " 									   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += "     								   AND D_E_L_E_T_ = ' '" + CRLF
		cSql += " 									) " + CRLF
		cSql += " 	OR " + CRLF
		cSql += " 	E2_FILIAL+E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
		cSql += " 								  SELECT D1_FILIAL+D1_FORNECE+D1_LOJA+RTRIM(D1_DOC)" + CRLF
		cSql += " 								    FROM " + RetSQLName('SD1') + "" + CRLF
		cSql += " 									WHERE D1_FORNECE+D1_LOJA+D1_PEDIDO  IN ( " + CRLF
		cSql += " 																		 SELECT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PEDIDO)" + CRLF
		cSql += " 		  																   FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += " 		  																  WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
		cSql += " 																		    AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += "     								   										AND D_E_L_E_T_ = ' '" + CRLF
		cSql += " 																		  ) " + CRLF
		cSql += " 								      AND D_E_L_E_T_ = ' '" + CRLF
		cSql += " 								) " + CRLF
		cSql += "" + CRLF
		cSql += " ) " + CRLF
		cSql += " AND E2.D_E_L_E_T_ = ' '" + CRLF
		cSql += " ) " + CRLF
		MBSaveLog():FULLWrite(, .F., "LoadNewGDados() - "+cTipo+" - Fim")
	ElseIf cTipo == "oGetF3Q3"

		cSql := " SELECT E2_FORNECE+E2_LOJA+' - '+E2_NOMFOR FORNECEDOR, E2_PREFIXO, E2_TIPO, SUM(E2_VALOR) E2_VALOR, SUM (E2_SALDO) SALDO, RTRIM(E2_NATUREZ)+' - '+ED.ED_DESCRIC NATUREZA " + CRLF
		cSql += " FROM " + RetSQLName('SE2') + " E2 " + CRLF
		cSql += " JOIN " + RetSQLName('SED') + " ED ON " + CRLF
		cSql += " 	 ED_FILIAL = ' '" + CRLF
		cSql += "  AND ED_CODIGO = E2_NATUREZ" + CRLF
		cSql += "  AND ED.D_E_L_E_T_ = ' '" + CRLF
		cSql += "   WHERE ( " + CRLF
		cSql += " 	  E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
		cSql += " 		  						    SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_CODIGO)" + CRLF
		cSql += " 		  						      FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += " 		  							 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
		cSql += " 									   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += " 									) " + CRLF
		cSql += " 	 OR " + CRLF
		cSql += " 	 E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
		cSql += " 		  						    SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PEDIDO)" + CRLF
		cSql += " 		  						      FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += " 		  							 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
		cSql += " 									   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += " 									) " + CRLF
		cSql += " 	OR " + CRLF
		cSql += " 	E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
		cSql += " 								  SELECT D1_FORNECE+D1_LOJA+RTRIM(D1_DOC)" + CRLF
		cSql += " 								    FROM " + RetSQLName('SD1') + "" + CRLF
		cSql += " 									WHERE D1_FORNECE+D1_LOJA+RTRIM(D1_PEDIDO)  IN ( " + CRLF
		cSql += " 																		 SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PEDIDO)" + CRLF
		cSql += " 		  																   FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += " 		  																  WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
		cSql += " 																		    AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += " 																		  ) " + CRLF
		cSql += " 								 " + CRLF
		cSql += " 								) " + CRLF
		cSql += " 	OR " + CRLF
		cSql += " 	E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
		cSql += " 								  SELECT D1_FORNECE+D1_LOJA+RTRIM(D1_DOC)" + CRLF
		cSql += " 								    FROM " + RetSQLName('SD1') + "" + CRLF
		cSql += " 									WHERE D1_FORNECE+D1_LOJA+RTRIM(D1_COD) IN ( " + CRLF
		cSql += " 																		 SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PRODUT)" + CRLF
		cSql += " 		  																   FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += " 		  																  WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
		cSql += " 																		    AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += " 																		  ) " + CRLF
		cSql += " 								 " + CRLF
		cSql += " 								) " + CRLF
		cSql += "" + CRLF
		cSql += " ) " + CRLF
		cSql += " AND E2.D_E_L_E_T_ = ' '" + CRLF
		cSql += " GROUP BY E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_PREFIXO, E2_TIPO, E2_NATUREZ, ED_DESCRIC " + CRLF
		//cSql += " ORDER BY E2_PREFIXO " + CRLF
		MBSaveLog():FULLWrite(, .F., "LoadNewGDados() - "+cTipo+" - Fim")
	ElseIf cTipo == "oGetF4Q4E"

		cSql := " SELECT B8_PRODUTO, B1_DESC, B8_SALDO, B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO " + CRLF
		cSql += " FROM " + RetSQLName('SB8') + " B8 " + CRLF
		cSql += " JOIN " + RetSQLName('SB1') + " B1 ON  B1_FILIAL=' ' AND B8_FILIAL='" + M->ZCC_FILIAL + "' AND B1.B1_COD = B8.B8_PRODUTO AND B1.D_E_L_E_T_ = ' ' AND B8.D_E_L_E_T_ = ' '" + CRLF
		cSql += " WHERE B8_PRODUTO IN ( " + CRLF
		cSql += " 	SELECT DISTINCT ZBC_PRODUT FROM " + RetSQLName('ZBC') + " WHERE ZBC_FILIAL='" + M->ZCC_FILIAL + "' AND ZBC_CODIGO='" + M->ZCC_CODIGO + "' AND D_E_L_E_T_ = ' ' " + CRLF
		cSql += " ) " + CRLF
		cSql += " AND B8_SALDO > 0 " + CRLF
		MBSaveLog():FULLWrite(, .F., "LoadNewGDados() - "+cTipo+" - Fim")
	ElseIf cTipo == "oGetF4Q5D"

		cSql := " SELECT D2_COD, B1_DESC, SUM(D2_QUANT) D2_QUANT, D2_LOTECTL, D2_EMISSAO " + CRLF
		cSql += " FROM " + RetSQLName('SD2') + " D2 " + CRLF
		cSql += " JOIN " + RetSQLName('SB1') + " B1 ON B1_FILIAL=' ' AND D2_FILIAL='" + M->ZCC_FILIAL + "' AND B1_COD = D2_COD AND B1.D_E_L_E_T_ = ' ' AND D2.D_E_L_E_T_ = ' ' " + CRLF
		cSql += " WHERE D2_COD IN ( " + CRLF
		cSql += " 	SELECT DISTINCT ZBC_PRODUT FROM " + RetSQLName('ZBC') + " WHERE ZBC_FILIAL='" + M->ZCC_FILIAL + "' AND ZBC_CODIGO='" + M->ZCC_CODIGO + "' AND D_E_L_E_T_ = ' ' " + CRLF
		cSql += " ) " + CRLF
		cSql += " AND D2_QUANT > 0 " + CRLF
		cSql += " GROUP BY D2_EMISSAO, D2_COD, B1_DESC, D2_LOTECTL " + CRLF
		MBSaveLog():FULLWrite(, .F., "LoadNewGDados() - "+cTipo+" - Fim")
	ElseIf cTipo == "oGetF4Q2E"

		cSql := " SELECT D3_COD, B1_DESC, D3_QUANT, D3_EMISSAO, D3_OBSERVA, D3_X_OBS, D3_USUARIO " + CRLF
		cSql += "  FROM " + RetSQLName('SD3') + " D3 " + CRLF
		cSql += "  JOIN " + RetSQLName('SB1') + " B1 ON B1_FILIAL=' ' AND D3_FILIAL='" + M->ZCC_FILIAL + "' AND B1_COD = D3_COD AND " + CRLF
		cSql += " 	  B1.D_E_L_E_T_ = ' ' AND" + CRLF
		cSql += " 	  D3.D_E_L_E_T_ = ' ' " + CRLF
		cSql += " WHERE D3_COD IN (" + CRLF
		cSql += " 	SELECT DISTINCT ZBC_PRODUT FROM " + RetSQLName('ZBC') + " WHERE ZBC_FILIAL='" + M->ZCC_FILIAL + "' AND ZBC_CODIGO='" + M->ZCC_CODIGO + "' AND D_E_L_E_T_ = ' ' " + CRLF
		cSql += "   ) " + CRLF
		cSql += "   AND D3_TM = '511' " + CRLF
		cSql += "   AND D3_ESTORNO = ' ' " + CRLF
		MBSaveLog():FULLWrite(, .F., "LoadNewGDados() - "+cTipo+" - Fim")
	ElseIf cTipo == "oGetF4Q3D"

		cSql := " SELECT D3_COD, B1_DESC, D3_QUANT, D3_EMISSAO, D3_OBSERVA, D3_X_OBS, D3_USUARIO " + CRLF
		cSql += "  FROM " + RetSQLName('SD3') + " D3 " + CRLF
		cSql += "  JOIN " + RetSQLName('SB1') + " B1 ON B1_FILIAL=' ' AND D3_FILIAL='" + M->ZCC_FILIAL + "' AND B1_COD = D3_COD AND " + CRLF
		cSql += " 	  B1.D_E_L_E_T_ = ' ' AND" + CRLF
		cSql += " 	  D3.D_E_L_E_T_ = ' ' " + CRLF
		cSql += " WHERE D3_COD IN (" + CRLF
		cSql += " 	SELECT DISTINCT ZBC_PRODUT FROM " + RetSQLName('ZBC') + " WHERE ZBC_FILIAL='" + M->ZCC_FILIAL + "' AND ZBC_CODIGO='" + M->ZCC_CODIGO + "' AND D_E_L_E_T_ = ' ' " + CRLF
		cSql += "   ) " + CRLF
		cSql += "   AND D3_TM = '011' " + CRLF
		cSql += "   AND D3_ESTORNO = ' ' " + CRLF
		MBSaveLog():FULLWrite(, .F., "LoadNewGDados() - "+cTipo+" - Fim")
	ElseIf cTipo == "oGetF4Q1"

		cSql := " WITH CONTRATO AS" + CRLF
		cSql += " (" + CRLF
		cSql += "       SELECT ZBC_FILIAL					   FILIAL," + CRLF
		cSql += " 			 ZBC_CODIGO						   COD_CONTRATO," + CRLF
		cSql += " 			 ZBC_PEDIDO					       NUMERO_LOTE," + CRLF
		cSql += "			 ZBC_ITEMPC," + CRLF
		cSql += " 			 ZBC_CODFOR					       CODIGO_FORNEC," + CRLF
		cSql += " 			 ZBC_LOJFOR						   LOJA_FORNEC," + CRLF
		cSql += " 			 A2.A2_NOME					       VENDEDOR," + CRLF
		cSql += " 			 A2_MUN						       ORIGEM," + CRLF
		cSql += " 			 A2_EST						       ESTADO," + CRLF
		cSql += " 			 ZBC_X_CORR					       COD_CORRETOR," + CRLF
		cSql += " 			 A3_NOME					       CORRETOR," + CRLF
		cSql += " 			 ZBC_PRODUT					       CODIGO_BOV," + CRLF
		cSql += " 			 ZBC_PRDDES					       DESCRICAO," + CRLF
		cSql += " 			 BC.ZBC_QUANT				       QTD_COMPRA," + CRLF
		cSql += " 			 CASE WHEN BC.ZBC_RACA = 'N' THEN 'NELORE'" + CRLF
		cSql += " 				  WHEN BC.ZBC_RACA = 'A' THEN 'ANGUS'" + CRLF
		cSql += " 				  WHEN BC.ZBC_RACA = 'M' THEN 'MESTICO'" + CRLF
		cSql += " 										 ELSE 'VERIFICAR'" + CRLF
		cSql += " 									     END AS RACA," + CRLF
		cSql += " 			 CASE WHEN BC.ZBC_SEXO = 'M' THEN 'MACHO'" + CRLF
		cSql += " 				  WHEN BC.ZBC_SEXO = 'F' THEN 'FEMEA'" + CRLF
		cSql += " 									     ELSE 'VERIFICAR'" + CRLF
		cSql += " 										 END AS SEXO," + CRLF
		cSql += "			CASE WHEN ZCC_PAGFUT = 'S'   THEN 'SIM'" + CRLF
		cSql += "										 ELSE 'NÃO'" + CRLF
		cSql += "										 END AS PGTO_FUTURO," + CRLF
		cSql += " 			 CASE WHEN BC.ZBC_TPNEG	= 'P' THEN 'PESO'" + CRLF
		cSql += " 				  WHEN BC.ZBC_TPNEG	= 'K' THEN 'KG'" + CRLF
		cSql += " 				  WHEN BC.ZBC_TPNEG	= 'Q' THEN 'CABECA'" + CRLF
		cSql += " 										  ELSE 'VERIFICAR'" + CRLF
		cSql += " 									      END AS TIPO_NEGOCIA," + CRLF
		cSql += " 			 CASE WHEN ZBC_PEDPOR = 'P'   THEN 'PAUTA'" + CRLF
		cSql += " 			 							  ELSE 'NEGOCIACAO'" + CRLF
		cSql += " 			 							  END AS PEDIDO_POR," + CRLF
		cSql += " 			 CASE WHEN ZBC_TEMFXA = 'S'   THEN 'SIM'" + CRLF
		cSql += " 			  						      ELSE 'NÁO'" + CRLF
		cSql += " 			  						      END AS TEM_FAIXA, ZBC_FAIXA," + CRLF
		cSql += " 			 ZBC_PESO			                PESO_COMPRA," + CRLF
		cSql += " 			 ZBC_ARROV			                VALOR_ARROB," + CRLF
		cSql += " 			 ZBC_REND			                RENDIMENTO," + CRLF
		cSql += " 			 ZBC_TTSICM			                TOTAL_SEM_ICMS," + CRLF
		cSql += " 			 ZBC_TOTICM			                TOTAL_ICMS," + CRLF
		cSql += " 			 ZBC_TTSICM+ZBC_TOTICM				GADO_ICMS_TOTAL_CONTRATO," + CRLF
		cSql += " 			 ZBC_VLFRPG, ZBC_ICFRVL," + CRLF
		cSql += " 			 ZBC_VLRCOM							VLR_COM" + CRLF
		cSql += "         FROM " + RetSQLName('ZBC') + " BC" + CRLF
		cSql += "         JOIN " + RetSQLName('ZCC') + " CC ON ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO" + CRLF
		cSql += " " + CRLF
		cSql += "AND ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO AND ZCC_VERSAO=ZBC_VERSAO" + CRLF
		cSql += "			AND ( ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN (" + CRLF
		cSql += "					SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED)" + CRLF
		cSql += "					FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += "					WHERE D_E_L_E_T_=' '" + CRLF
		cSql += "					GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC" + CRLF
		cSql += "				)" + CRLF
		cSql += "		AND CC.D_E_L_E_T_=' '" + CRLF
		cSql += "		AND BC.D_E_L_E_T_=' '" + CRLF
		cSql += "	" + CRLF
		cSql += "   INNER JOIN " + RetSQLName('SA2') + " A2 ON" + CRLF
		cSql += "   		 A2.A2_FILIAL =	' '" + CRLF
		cSql += " 		 AND A2.A2_COD					=		ZBC_CODFOR" + CRLF
		cSql += " 		 AND A2.A2_LOJA					=		ZBC_LOJFOR" + CRLF
		cSql += " 		 AND A2.D_E_L_E_T_ = ' '" + CRLF
		// cSql += "   INNER JOIN ZIC010	IC ON" + CRLF
		// cSql += " 			 IC.ZIC_FILIAL				=		ZBC_FILIAL" + CRLF
		// cSql += " 		 AND IC.ZIC_CODIGO				=		BC.ZBC_CODIGO" + CRLF
		// cSql += " 		 AND IC.ZIC_ITEM				=		BC.ZBC_ITEZIC" + CRLF
		// cSql += " " + CRLF
		//cSql += "       AND ZIC_FILIAL=ZBC_FILIAL AND ZIC_CODIGO=ZBC_CODIGO AND ZIC_VERSAO=ZBC_VERSAO" + CRLF
		cSql += "       			AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN" + CRLF
		cSql += "       				(" + CRLF
		cSql += "       					SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED)" + CRLF
		cSql += "       					FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += "       					WHERE D_E_L_E_T_=' '" + CRLF
		cSql += "       					GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC" + CRLF
		cSql += "       				)" + CRLF
		cSql += "       			" + CRLF
		// cSql += " 	     AND IC.D_E_L_E_T_ = ' '" + CRLF
		cSql += " " + CRLF
		cSql += "    INNER JOIN SA3010 A3 ON" + CRLF
		cSql += "			 A3_FILIAL=' '" + CRLF
		cSql += " 		 AND A3.A3_COD					=		ZBC_X_CORR" + CRLF
		cSql += " 		 AND A3.D_E_L_E_T_=' '" + CRLF
		cSql += "	-- ALTERADO" + CRLF
		cSql += "	INNER JOIN " + RetSQLName('SB1') + " B1 ON" + CRLF
		cSql += "					B1_FILIAL					= ' '" + CRLF
		cSql += "				AND B1_COD 						= ZBC_PRODUT" + CRLF
		cSql += "				AND B1_RASTRO = 'L'" + CRLF
		cSql += "				AND B1.D_E_L_E_T_ = ' '" + CRLF
		cSql += "        WHERE" + CRLF
		// cSql += " 			 ZBC_FILIAL BETWEEN '  ' AND 'ZZ'" + CRLF
		// cSql += " 		 AND ZBC_CODIGO BETWEEN '      ' AND 'ZZZZZZ'" + CRLF
		// cSql += " 		 AND ZBC_PEDIDO BETWEEN '      ' AND 'ZZZZZZ'" + CRLF
		// cSql += " AND ZBC_PEDIDO IN (" + CRLF
		// cSql += "		SELECT DISTINCT ZBC_PEDIDO FROM " + RetSQLName('ZBC') + "" + CRLF
		// cSql += "      WHERE ZBC_PRODUT IN (" + CRLF
		// cSql += " 		       SELECT DISTINCT D2_COD FROM " + RetSQLName('SD2') + " D2 " + CRLF
		// cSql += "				JOIN SF4010 F4 ON D2_TES = F4.F4_CODIGO AND F4.D_E_L_E_T_ = ' ' AND D2.D_E_L_E_T_=' '" + CRLF
		// cSql += "		   								AND F4_TRANFIL <> '1'" + CRLF
		// cSql += " 		       WHERE 	D2_TIPO='N'" + CRLF
		// cSql += " 	 		-- AND D2_EMISSAO BETWEEN '20190102' AND '20190110'" + CRLF
		// cSql += "				AND D2_LOTECTL <> ' '" + CRLF
		// cSql += " 	 ) )" + CRLF
		// cSql += " 		 AND ZBC_CODFOR BETWEEN '      ' AND 'ZZZZZZ'" + CRLF
		// cSql += "       AND
		cSql += " (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN" + CRLF
		cSql += "              (" + CRLF
		cSql += "           		SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED)" + CRLF
		cSql += "           		FROM " + RetSQLName('ZBC') + "" + CRLF
		cSql += "           		WHERE D_E_L_E_T_=' '" + CRLF
		cSql += "           		GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC" + CRLF
		cSql += "              )" + CRLF
		cSql += " 		 AND A2.D_E_L_E_T_				=		' '" + CRLF
		cSql += " " + CRLF
		cSql += " 		 AND A3.D_E_L_E_T_				=		' '" + CRLF
		cSql += "  GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_PEDIDO, ZBC_ITEMPC, ZBC_CODFOR, ZBC_LOJFOR, A2.A2_NOME, A2_MUN, A2_EST, ZBC_X_CORR, A3_NOME, ZBC_PRODUT," + CRLF
		cSql += "   			 ZBC_PRDDES, ZBC_QUANT, BC.ZBC_RACA, BC.ZBC_SEXO, ZCC_PAGFUT, BC.ZBC_TPNEG, ZBC_PEDPOR, ZBC_TEMFXA, ZBC_FAIXA, ZBC_PESO," + CRLF
		cSql += "   			 ZBC_ARROV, ZBC_PESO, ZBC_REND, ZBC_TTSICM, ZBC_TOTICM, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM," + CRLF
		cSql += "  			 A2.A2_NOME" + CRLF
		cSql += " 		)" + CRLF
		cSql += " " + CRLF
		cSql += " , CONTRATO_DISTINCT AS (" + CRLF
		cSql += " 		SELECT FILIAL, COD_CONTRATO, CODIGO_BOV, NUMERO_LOTE, SUM(QTD_COMPRA) QTD_COMPRA" + CRLF
		cSql += " 		FROM CONTRATO" + CRLF
		cSql += " 		GROUP BY FILIAL, COD_CONTRATO, CODIGO_BOV, NUMERO_LOTE" + CRLF
		cSql += " )" + CRLF
		cSql += " " + CRLF
		cSql += ", ESTOQUE AS (" + CRLF
		cSql += " 	SELECT DISTINCT B8_FILIAL, B8.B8_PRODUTO, SUM(B8.B8_SALDO) SALDO" + CRLF
		cSql += " 	FROM " + RetSQLName('SB8') + " B8" + CRLF
		cSql += " 	JOIN CONTRATO_DISTINCT C ON C.FILIAL=B8_FILIAL AND C.CODIGO_BOV = B8_PRODUTO AND B8.D_E_L_E_T_ = ' '" + CRLF
		cSql += " 	GROUP BY B8_FILIAL, B8.B8_PRODUTO" + CRLF
		cSql += "	HAVING SUM(B8.B8_SALDO) > 0" + CRLF
		cSql += " )," + CRLF
		cSql += " " + CRLF
		cSql += " " + CRLF
		cSql += " FATURAMENTO AS (" + CRLF
		cSql += " 	SELECT D2_FILIAL, D2_COD, SUM(D2_QUANT) SALDO" + CRLF
		cSql += " 	  FROM " + RetSQLName('SD2') + " D2" + CRLF
		cSql += " 	  JOIN CONTRATO_DISTINCT C ON D2_FILIAL=C.FILIAL AND D2_COD = C.CODIGO_BOV AND  D2.D_E_L_E_T_ = ' '" + CRLF
		cSql += " 	  WHERE  D2_QUANT > 0" + CRLF
		cSql += "		 AND D2_TIPO='N'" + CRLF
		// cSql += "		 AND SUBSTRING(D2_LOTECTL,1,4) <> 'AUTO'" + CRLF
		cSql += " 	  GROUP BY D2_FILIAL, D2_COD" + CRLF
		cSql += " )," + CRLF
		cSql += " " + CRLF
		cSql += " MORTE AS (" + CRLF
		cSql += " 	SELECT D3M.D3_FILIAL, D3M.D3_COD, SUM(D3M.D3_QUANT) MORTE" + CRLF
		cSql += " 	FROM " + RetSQLName('SD3') + " D3M" + CRLF
		cSql += " 	JOIN CONTRATO_DISTINCT C ON	C.FILIAL=D3_FILIAL AND C.CODIGO_BOV = D3_COD AND D3M.D_E_L_E_T_ = ' '" + CRLF
		cSql += " 	WHERE D3M.D3_ESTORNO <> 'S'" + CRLF
		cSql += " 	  AND D3M.D3_TM IN ('511')" + CRLF
		cSql += " 	GROUP BY D3M.D3_FILIAL, D3M.D3_COD" + CRLF
		cSql += " )," + CRLF
		cSql += " " + CRLF
		cSql += " NASCIMENTO AS (" + CRLF
		cSql += " 	SELECT D3M.D3_FILIAL, D3M.D3_COD, SUM(D3M.D3_QUANT) NASCIMENTO" + CRLF
		cSql += " 	FROM " + RetSQLName('SD3') + " D3M" + CRLF
		cSql += " 	JOIN CONTRATO_DISTINCT C ON FILIAL=D3_FILIAL AND C.CODIGO_BOV = D3_COD AND D3M.D_E_L_E_T_ = ' '" + CRLF
		cSql += " 	WHERE D3M.D3_ESTORNO <> 'S'" + CRLF
		cSql += " 	  AND D3M.D3_TM IN ('011')" + CRLF
		cSql += " 	GROUP BY D3M.D3_FILIAL, D3M.D3_COD" + CRLF
		cSql += " )," + CRLF
		cSql += " " + CRLF
		cSql += " MOVBOIA AS ( " + CRLF
		cSql += " 	SELECT D3_FILIAL, D3_COD, SUM(D3.D3_QUANT) QTD_TRANSF " + CRLF
		cSql += " 	FROM " + RetSQLName('SD3') + " D3 " + CRLF
		cSql += " 	JOIN CONTRATO C ON FILIAL = D3.D3_FILIAL AND CODIGO_BOV = D3.D3_COD " + CRLF
		cSql += " 	WHERE  D3_TM IN ('499') -- D3_FILIAL = '01' " + CRLF
		cSql += " 		AND D3_CF = 'DE4' " + CRLF
		cSql += " 		AND D3_GRUPO = 'BOV' " + CRLF
		cSql += " 		AND D3_NUMSEQ IN (SELECT D3_NUMSEQ FROM " + RetSQLName('SD3') + " X WHERE D3_CF = 'RE4' AND D3_COD <> D3.D3_COD AND X.D_E_L_E_T_= ' ') " + CRLF
		cSql += " 		AND D_E_L_E_T_ = ' ' " + CRLF
		cSql += " 	 GROUP BY D3_FILIAL, D3_COD " + CRLF
		cSql += "  ), " + CRLF
		cSql += "" + CRLF
		cSql += " MOVBOIB AS ( " + CRLF
		cSql += " 	SELECT D3_FILIAL, D3_COD, SUM(D3.D3_QUANT) QTD_TRANSF " + CRLF
		cSql += " 	FROM " + RetSQLName('SD3') + " D3 " + CRLF
		cSql += " 	JOIN CONTRATO C ON FILIAL = D3.D3_FILIAL AND CODIGO_BOV = D3.D3_COD " + CRLF
		cSql += " 	WHERE  D3_TM IN ('999') -- D3_FILIAL = '01' " + CRLF
		cSql += " 	   AND D3_CF = 'RE4' " + CRLF
		cSql += " 	   AND D3_GRUPO = 'BOV' " + CRLF
		cSql += " 	   AND D3_NUMSEQ IN (SELECT D3_NUMSEQ FROM " + RetSQLName('SD3') + " X WHERE FILIAL=X.D3_FILIAL AND D3_CF = 'DE4' AND D3_COD <> D3.D3_COD AND X.D_E_L_E_T_= ' ') " + CRLF
		cSql += " 	   AND D_E_L_E_T_ = ' ' " + CRLF
		cSql += " 	 GROUP BY D3_FILIAL, D3_COD " + CRLF
		cSql += "  )," + CRLF
		cSql += "" + CRLF
		cSql += " MOVBOI AS ( " + CRLF
		cSql += "  SELECT A.D3_FILIAL, A.D3_COD, ISNULL(A.QTD_TRANSF,0)-ISNULL(B.QTD_TRANSF,0) QTD_TRANSF" + CRLF
		cSql += " 	FROM MOVBOIA A" + CRLF
		cSql += "	LEFT JOIN MOVBOIB B ON " + CRLF
		cSql += "		A.D3_FILIAL = B.D3_FILIAL AND " + CRLF
		cSql += "		A.D3_COD = B.D3_COD " + CRLF
		cSql += "	WHERE (ISNULL(A.QTD_TRANSF,0)-ISNULL(B.QTD_TRANSF,0)) <> 0" + CRLF
		cSql += "" + CRLF
		cSql += "), " + CRLF
		cSql += " DADOS AS (" + CRLF
		cSql += "	 	SELECT  C.FILIAL, COD_CONTRATO, C.NUMERO_LOTE
		cSql += "	 		  , C.CODIGO_BOV
		cSql += "	 		  , ISNULL(QTD_COMPRA,0) ZBC_COMPRA, ISNULL(E.SALDO,0) SALDO_B8," + CRLF
		cSql += "				CASE WHEN ISNULL(SUM(MOV.QTD_TRANSF),0)> 0" + CRLF
		cSql += "					THEN ISNULL(F.SALDO,0)-ISNULL(SUM(MOV.QTD_TRANSF),0)" + CRLF
		cSql += "					ELSE ISNULL(F.SALDO,0)" + CRLF
		cSql += "				END AS FATURADO," + CRLF
		cSql += "				ISNULL(M.MORTE,0) MORTE, ISNULL(N.NASCIMENTO,0) NASCIMENTO," + CRLF
		cSql += "				ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0) TOTAL," + CRLF
		cSql += "				CASE WHEN SUM(MOV.QTD_TRANSF) > 0 AND ISNULL(QTD_COMPRA,0)-(ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0)) < 0" + CRLF
		cSql += "					THEN ISNULL(QTD_COMPRA,0)-(ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0))+ISNULL(SUM(MOV.QTD_TRANSF),0)" + CRLF
		cSql += "							ELSE ISNULL(QTD_COMPRA,0)-(ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0))" + CRLF
		cSql += "				END AS DIFERE" + CRLF
		cSql += "		FROM CONTRATO_DISTINCT C" + CRLF
		cSql += "		LEFT JOIN ESTOQUE 	  E	  ON C.FILIAL=E.B8_FILIAL AND C.CODIGO_BOV = E.B8_PRODUTO" + CRLF
		cSql += "		LEFT JOIN FATURAMENTO F	  ON C.FILIAL=D2_FILIAL   AND C.CODIGO_BOV = D2_COD" + CRLF
		cSql += "		LEFT JOIN MORTE 	  M	  ON C.FILIAL=M.D3_FILIAL AND C.CODIGO_BOV = M.D3_COD" + CRLF
		cSql += "		LEFT JOIN NASCIMENTO  N	  ON C.FILIAL=N.D3_FILIAL AND C.CODIGO_BOV = N.D3_COD" + CRLF
		cSql += "		LEFT JOIN MOVBOI      MOV ON C.FILIAL=MOV.D3_FILIAL AND C.CODIGO_BOV = MOV.D3_COD" + CRLF
		cSql += "		GROUP BY C.FILIAL, COD_CONTRATO, C.NUMERO_LOTE
		cSql += "				, C.CODIGO_BOV
		cSql += "				, QTD_COMPRA, E.SALDO, F.SALDO, M.MORTE, N.NASCIMENTO" + CRLF
		cSql += "		-- HAVING ISNULL(QTD_COMPRA,0)-(ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0)) <> 0" + CRLF
		cSql += " )" + CRLF
		cSql += " " + CRLF
		cSql += " " + CRLF
		cSql += " SELECT		FILIAL, " + CRLF
		cSql += "			CASE WHEN NUMERO_LOTE IS NULL THEN 'SEM CONTRATO' ELSE NUMERO_LOTE END NUMERO_LOTE," + CRLF
		cSql += " 			SUM(ZBC_COMPRA) ZBC_COMPRA," + CRLF
		cSql += " 			SUM(SALDO_B8) SALDO_B8," + CRLF
		cSql += " 			SUM(FATURADO) FATURADO," + CRLF
		cSql += " 			SUM(MORTE) MORTE," + CRLF
		cSql += " 			SUM(NASCIMENTO) NASCIMENTO," + CRLF
		cSql += " 			SUM(TOTAL) TOTAL," + CRLF
		cSql += " 			SUM(DIFERE) DIFERE" + CRLF
		cSql += " FROM		DADOS" + CRLF
		cSql += " WHERE COD_CONTRATO = '" + M->ZCC_CODIGO + "' " + CRLF
		cSql += " GROUP BY	FILIAL, NUMERO_LOTE " + CRLF
		cSql += " ORDER BY	FILIAL, NUMERO_LOTE " + CRLF
		MBSaveLog():FULLWrite(, .F., "LoadNewGDados() - "+cTipo+" - Fim")
	ElseIf cTipo == "PreNF"

		cSql := " WITH ENTRADA AS (" + CRLF
		cSql += "  		SELECT '1-NF ENTRADA' AS TIPO, D.R_E_C_N_O_, " + CRLF
		cSQl += "       		D.D1_FILIAL, D.D1_DOC, D.D1_SERIE, D.D1_ITEM, " + CRLF
		cSQl += "       		D.D1_FORNECE+D.D1_LOJA COD_FORNECE, RTRIM(" + RetSQLName('SA2') + ".A2_NOME) A2_NOME, D.D1_EMISSAO, D.D1_COD, D.D1_UM, D.D1_QUANT, D.D1_VUNIT," + CRLF
		cSQl += "       		D.D1_TOTAL, D.D1_VALICM, D.D1_CF, D.D1_X_KM, D.D1_X_PESCH, D.D1_X_EMBDT, D.D1_X_EMBHR, D.D1_X_CHEDT, D.D1_X_CHEHR, D.D1_VLSENAR " + CRLF
		cSQl += "       		, CP.D1_TOTAL TOT_COMPL" + CRLF
		cSQl += "       		, ZBC_CODIGO" + CRLF
		cSQl += "       		, ZBC_TOTNEG" + CRLF
		cSql += "  		  FROM " + RetSQLName('SD1') + " D " + CRLF
		cSql += "  		  JOIN " + RetSQLName('SA2') + " ON" + CRLF
		cSql += "  			   D1_FORNECE = A2_COD" + CRLF
		cSql += "  		   AND D1_LOJA = A2_LOJA" + CRLF
		cSql += "  		   AND " + RetSQLName('SA2') + ".D_E_L_E_T_ = ' ' AND D.D_E_L_E_T_=' '" + CRLF
		cSql += "    LEFT JOIN " + RetSQLName('SD1') + " CP ON D.D1_FILIAL=CP.D1_FILIAL AND D.D1_DOC=CP.D1_NFORI AND D.D1_SERIE=CP.D1_SERIORI AND D.D1_ITEM=CP.D1_ITEMORI AND D.D_E_L_E_T_=' ' AND CP.D_E_L_E_T_=' '" + CRLF
		cSQl += " 	 JOIN " + RetSQLName('ZBC') + " C ON ZBC_FILIAL=D.D1_FILIAL" + CRLF
		cSQl += " 	 				   AND RTRIM(ZBC_PRODUT)=RTRIM(D.D1_COD)" + CRLF
		cSQl += " 	 				   AND ZBC_CODFOR=D.D1_FORNECE" + CRLF
		cSQl += " 	 				   AND ZBC_LOJFOR=D.D1_LOJA" + CRLF
		cSQl += " 	 				   AND ZBC_PEDIDO=D.D1_PEDIDO" + CRLF
		cSQl += " 	 				   AND C.D_E_L_E_T_=' '" + CRLF
		cSql += "    	  WHERE D.D1_QUANT > 0 " + CRLF
		cSql += "  				AND D.D1_TIPO = 'N'" + CRLF
		cSql += "  		        AND D.D1_FILIAL+RTRIM(D.D1_COD)+D.D1_FORNECE+D.D1_LOJA+D.D1_PEDIDO IN " + CRLF
		cSql += "  					( " + CRLF
		cSql += "  						SELECT DISTINCT ZBC_FILIAL+RTRIM(ZBC_PRODUT)+ZBC_CODFOR+ZBC_LOJFOR+ZBC_PEDIDO " + CRLF
		cSql += "  						  FROM " + RetSQLName('ZBC') + " " + CRLF
		cSql += "  						 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
		cSql += "  						   AND ZBC_CODIGO = '"+M->ZCC_CODIGO+"'" + CRLF
		// cSql += "     					   AND ZBC_PRODUT = '" + &( "o" + cPFoBCPRD + "ZBCGDad"):aCols[ nAtZBC, nPZBCPRD ] + "' " + CRLF
		cSql += "     					   AND ZBC_PRODUT IN (" + U_cValToSQL(_cProdut,",") + ") " + CRLF
		cSql += "  					)" + CRLF
		cSql += "  		)," + CRLF
		cSql += "  COMPLEMENTO AS (" + CRLF
		cSql += "  		SELECT '2-NF COMPLEMENTO' AS TIPO, D.R_E_C_N_O_, " + CRLF
		cSql += " 		D.D1_FILIAL, D.D1_DOC, D.D1_SERIE, D.D1_ITEM, " + CRLF
		cSql += " 		D.D1_FORNECE+'-'+D.D1_LOJA COD_FORNECE, RTRIM(" + RetSQLName('SA2') + ".A2_NOME) A2_NOME, D.D1_EMISSAO, D.D1_COD, D.D1_UM," + CRLF
		cSql += " 		D.D1_QUANT, D.D1_VUNIT, D.D1_TOTAL, D.D1_VALICM, D.D1_CF, D.D1_X_KM, D.D1_X_PESCH, D.D1_X_EMBDT, D.D1_X_EMBHR," + CRLF
		cSql += " 		D.D1_X_CHEDT, D.D1_X_CHEHR, D.D1_VLSENAR" + CRLF
		cSql += "  FROM SF1010 F" + CRLF
		cSql += " 	  JOIN " + RetSQLName('SD1') + " D	 ON F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE " + CRLF
		cSql += " 							AND F1_LOJA=D1_LOJA AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' '" + CRLF
		cSql += " 	  JOIN " + RetSQLName('SA2') + "	 ON A2_FILIAL=' ' AND D.D1_FORNECE = A2_COD AND D.D1_LOJA = A2_LOJA AND " + RetSQLName('SA2') + ".D_E_L_E_T_ = ' '  " + CRLF
		cSql += " 	  JOIN ENTRADA E ON E.D1_COD = D.D1_COD " + CRLF
		// cSql += " 	   -- AND E.COD_FORNECE <> F.D1_FORNECE+F.D1_LOJA
		cSql += " 	 WHERE F.F1_TIPO = 'C'" + CRLF
		cSql += " 	   		  AND F.F1_TPCOMPL='1'" + CRLF
		cSql += " 	   		  AND D.D1_QUANT = 0  " + CRLF
		cSql += "    	      AND D.D1_FILIAL+RTRIM(D.D1_COD)+D.D1_FORNECE+D.D1_LOJA IN" + CRLF
		cSql += "     				( " + CRLF
		cSql += "     					SELECT DISTINCT ZBC_FILIAL+RTRIM(ZBC_PRODUT)+ZBC_CODFOR+ZBC_LOJFOR " + CRLF
		cSql += "     					  FROM " + RetSQLName('ZBC') + " " + CRLF
		cSql += "     					 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
		cSql += "     					   AND ZBC_CODIGO = '"+M->ZCC_CODIGO+"'" + CRLF
		cSql += "     					   AND ZBC_PRODUT IN (" + U_cValToSQL(_cProdut,",") + ") " + CRLF
		cSql += "  				)" + CRLF
		cSql += " ) " + CRLF
		cSql += "" + CRLF
		cSql += ", DADOS AS ( " + CRLF
		cSql += " 	SELECT TIPO, R_E_C_N_O_, D1_FILIAL, D1_DOC, D1_SERIE, D1_ITEM, D1_EMISSAO, D1_COD, D1_QUANT, D1_TOTAL, D1_VALICM, D1_VLSENAR, ISNULL(TOT_COMPL,0) TOT_COMPL " + CRLF
		cSQl += " 			, ZBC_TOTNEG" + CRLF
		cSQl += " 			, ZBC_CODIGO" + CRLF
		cSql += " 	FROM ENTRADA" + CRLF
		cSql += "" + CRLF
		cSql += " 	UNION" + CRLF
		cSql += "" + CRLF
		cSql += " 	SELECT TIPO, R_E_C_N_O_, D1_FILIAL, D1_DOC, D1_SERIE, D1_ITEM, D1_EMISSAO, D1_COD, D1_QUANT, D1_TOTAL, D1_VALICM, D1_VLSENAR, 0 " + CRLF
		cSQl += " 			, 0" + CRLF
		cSQl += " 			,''" + CRLF
		cSql += " 	FROM COMPLEMENTO" + CRLF
		cSql += " ) " + CRLF
		cSql += "" + CRLF
		cSql += " , TOTAIS_TIPO_BOV AS (" + CRLF
		cSql += "	SELECT TIPO, D1_COD, SUM(D1_TOTAL) D1_TOTAL1" + CRLF
		cSql += "	FROM DADOS" + CRLF
		cSql += "	GROUP BY TIPO, D1_COD" + CRLF
		cSql += " )" + CRLF
		cSql += " " + CRLF
		cSql += " , TOTAIS_BOV AS (" + CRLF
		cSql += "	 SELECT D1_COD, SUM(D1_TOTAL1) D1_TOTAL2" + CRLF
		cSql += "	 FROM TOTAIS_TIPO_BOV" + CRLF
		cSql += "	 GROUP BY D1_COD" + CRLF
		cSql += " )" + CRLF
		cSql += " " + CRLF
		cSql += " , TOTAIS_FINAIS AS (" + CRLF
		cSql += "	 SELECT A.*, B.D1_TOTAL2" + CRLF
		cSql += "	 FROM TOTAIS_TIPO_BOV A" + CRLF
		cSql += "	 JOIN TOTAIS_BOV	  B ON A.D1_COD=B.D1_COD" + CRLF
		cSql += " )" + CRLF
		cSql += " SELECT 'LBNO' MARK, A.D1_COD, D1_FILIAL, D1_DOC, D1_SERIE, D1_ITEM, D1_EMISSAO, A.TIPO, '   ' TES, " + CRLF
		cSql += "	 	  SUM(D1_QUANT) QUANT, SUM(D1_TOTAL) D1_TOTAL, SUM(D1_VALICM) D1_VALICM, SUM(D1_TOTAL) - SUM(D1_VALICM) VLR_S_ICMS, D1_VLSENAR " + CRLF
		cSql += "	 	  , SUM(TOT_COMPL) TOT_COMPL " + CRLF
		cSql += "	 	  , D1_TOTAL1" + CRLF
		cSql += "	 	  , D1_TOTAL2" + CRLF
		cSql += "	 	  , ZBC_CODIGO" + CRLF
		cSql += "	 	  , ZBC_TOTNEG" + CRLF
		cSql += "	 	  , CASE WHEN (ZBC_TOTNEG - D1_TOTAL2 - SUM(TOT_COMPL)) < 0" + CRLF
		cSql += "	 	  		THEN 0" + CRLF
		cSql += "	 	  		ELSE ZBC_TOTNEG - D1_TOTAL2 - SUM(TOT_COMPL) " + CRLF
		cSql += "	 	    END VlrCompl" + CRLF
		cSql += "	 	  -- , CASE WHEN A.TIPO='1-NF ENTRADA' THEN ZBC_TOTNEG - D1_TOTAL2 ELSE 0 END VlrCompl2" + CRLF
		cSql += " FROM DADOS A" + CRLF
		cSQl += " JOIN TOTAIS_FINAIS B ON A.TIPO=B.TIPO AND A.D1_COD=B.D1_COD" + CRLF
		cSQl += " GROUP BY A.D1_COD, D1_FILIAL, D1_DOC, D1_SERIE, D1_ITEM, D1_EMISSAO, A.TIPO, R_E_C_N_O_, D1_VLSENAR " + CRLF
		cSQl += " , D1_TOTAL1, D1_TOTAL2, ZBC_CODIGO, ZBC_TOTNEG" + CRLF
		cSQl += " ORDER BY D1_COD, D1_FILIAL, D1_DOC, D1_SERIE, D1_ITEM, D1_EMISSAO, A.TIPO, R_E_C_N_O_ " + CRLF
		MBSaveLog():FULLWrite(, .F., "LoadNewGDados() - "+cTipo+" - Fim")
	EndIf

	if Select("QTMP") > 0
		QTMP->( dbCloseArea() )
	endif

	MemoWrite( "C:\totvs_relatorios\VACOMM11_" + cTipo + ".sql", cSql )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),"QTMP",.F.,.T.)

	aColsEsp := {}
	while !QTMP->(Eof())
		aAdd(aColsEsp, array(nUsadEsp+1))
		for nX := 1 to nUsadEsp
			if aHeadEsp[nX,8]=='D'
				aColsEsp[Len(aColsEsp),nX]:=STOD( QTMP->( FieldGet(FieldPos(aHeadEsp[nX,2])) ) )
			else
				aColsEsp[Len(aColsEsp),nX]:=QTMP->( FieldGet(FieldPos(aHeadEsp[nX,2])) )
			endIf
		next
		aColsEsp[len(aColsEsp), nUsadEsp+1] := .F.

		// Preencher com Zero, qdo nao tiver no SQL o campo
		For nX := 1 to nUsadEsp
			if Empty( aColsEsp[ Len(aColsEsp), nX ] )
				If aHeadEsp[nX,8]=='C'
					aColsEsp[ Len(aColsEsp), nX ] := Space( aHeadEsp[ nX, 4] )
				ElseIf aHeadEsp[nX,8]=='N'
					aColsEsp[ Len(aColsEsp), nX ] := 0
				ElseIf aHeadEsp[nX,8]=='N'
					aColsEsp[ Len(aColsEsp), nX ] := sToD("")
				EndIf

			EndIf
		Next nX

		QTMP->(dbSkip())
	endDo

	MBSaveLog():FULLWrite(, .F., "Fim: LoadNewGDados("+cTipo+", aHeadEsp, aColsEsp, nUsadEsp, _cProdut )")
Return nil
/* 
----	Igor Oliveira 
----	11.01.2023
----	Alteração do Pedido de Venda 
 */
Static Function xAltSC7()
	MBSaveLog():FULLWrite(, .F., "Inicio: xAltSC7()")

	Local aArea			:= GetArea()
	Local aAreaSD1 		:= SD1->(GetArea())
	Local nI            := 0
	Local lOk
	Local lPermiss 		:= .F. 

	for nI := 1 to len(cUserAlt)
		if __cUserID == cUserAlt[nI]
			lPermiss := .T.
		endif
	next nI

	if !lPermiss
		Aviso("Aviso", "Usuário sem permissão para esta operação!", {"Sair"} )
		RestArea(aAreaSD1)
		RestArea(aArea)
		return nil
	endif
	
	If M->ZCC_VERSAO != ZCC->ZCC_VERSAO // NOVA VERSAO
		Aviso("Aviso", "Não é permitido alterar pedidos durante o processo de geração de nova versão. Salve a edição e clique em Alterar para gerar pedidos.", {"Sair"} )
		RestArea(aAreaSD1)
		RestArea(aArea)
		return nil
	EndIf

	lOk := .T.
	For nI := 1 to Len(o1ZBCGDad:aCols)
		If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
			if &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ] == 0 .or. &( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nI, nPZBCTot ] == 0  .or. empty( &( "o" + cPFoBCCDP + "ZBCGDad"):aCols[ nI, nPZBCCDP ] )
				Alert("Existem campos obrigatórios não informados. Preencha-os antes de alterar o pedido.")
				RestArea(aAreaSD1)
				RestArea(aArea)
				return nil
			endIf
		EndIf
	Next nI

	// A parte abaixo foi copiada da funcao VldOk, foi retirado a parte que valida o tipo do Item na ZIC
	For nI:=1 to Len(o1ZBCGDad:aCols)
		If !Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
			If ; // !oZICGDad:aCols[ Val( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEZIC"}) ] ), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] $ ("KQ") .and. ;
				o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK' .and. ;
				Empty( o2ZBCGDad:aCols[ nI, aScan( a2ZBCHead, {|x| AllTrim(x[2])=="ZBC_ARROV"}) ] ) .and. ;
				!Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_QUANT"}) ] ) .and. ;
				o1ZBCGDad:aCols[ nI, nPZBCPdP ] <> "P"

					Exit
			EndIf
		EndIf
	Next nI
	If nI <= Len(o1ZBCGDad:aCols)
		Aviso("Aviso", ;
			"Valor de @ nao informado na linha: " + AllTrim(Str(nI)) + ;
			" na tabela da CONFIGURAÇÃO DA BASE CONTRATUAL." + CRLF + "Esta Operação sera cancelada.", ;
			{"Sair"} )
		RestArea(aAreaSD1)
		RestArea(aArea)
		return nil
	EndIf

	// ================================================================================================

	// Validar campo desconto, se preenchido obrigar preenchimento do campo OBS na ZBC
	For nI:=1 to Len(o1ZBCGDad:aCols)
		If !Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
			If ; // !oZICGDad:aCols[ Val( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEZIC"}) ] ), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] $ ("KQ") .and. ;
				o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK' .and. ;
				!Empty( &( "o" + cPFoBCOTS + "ZBCGDad"):aCols[ nI, nPZBCOTS ] ) .and. ;
				Empty( &( "o" + cPFoBCOBS + "ZBCGDad"):aCols[ nI, nPZBCOBS ] )

					Exit
			EndIf
		EndIf
	Next nI
	If nI <= Len(o1ZBCGDad:aCols)
		Aviso("Aviso", ;
			"Campo OBSERVAÇÃO não informado na linha: " + AllTrim(Str(nI)) + ;
			" na tabela da CONFIGURAÇÃO DA BASE CONTRATUAL." + CRLF + "Esta Operação sera cancelada.", ;
			{"Sair"} )
		RestArea(aAreaSD1)
		RestArea(aArea)
		return nil
	EndIf
	// ================================================================================================

	// Validar campo vencimento ,Deiar obrigatório na tabela ZBC conforme solicitação da Camila via WhatsApp em 23/02/2022
	// Retirada a validação, pois as datas de vencimento serão controladas pela tabela ZBD - 07/02/2024
	//For nI:=1 to Len(o1ZBCGDad:aCols)
	//	If !Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
	//		If ; // !oZICGDad:aCols[ Val( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEZIC"}) ] ), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] $ ("KQ") .and. ;
	//			o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK' .and. ;
	//			Empty( &( "o" + cPFoBCDvc + "ZBCGDad"):aCols[ nI, nPZBCDvc ] )
//
	//				Exit
	//		EndIf
	//	EndIf
	//Next nI
	If nI <= Len(o1ZBCGDad:aCols)
		Aviso("Aviso", ;
			"Campo Data de Vencimento não informado na linha: " + AllTrim(Str(nI)) + ;
			" na tabela da CONFIGURAÇÃO DA BASE CONTRATUAL." + CRLF + "Esta Operação sera cancelada.", ;
			{"Sair"} )
		RestArea(aAreaSD1)
		RestArea(aArea)
		return nil
	EndIf
	// validar se existe pedido de compra ja existente na linha selecionada;
	For nI:=1 to Len(o1ZBCGDad:aCols)
		If !Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
			If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK' .and. ;
				!Empty( &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ] )

				Exit
			EndIf
		EndIf
	Next nI

	DbSelectArea("SD1")
	SD1->(DbSetOrder(22))
	
	For nI:=1 to Len(o1ZBCGDad:aCols)
		If !Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_PEDIDO"}) ] )
			if SD1->(DbSeek(FWxFilial("SD1")+;
							&( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ]+;
							StrZero( Val(&( "o" + cPFoBCPIt + "ZBCGDad"):aCols[ nI, nPZBCPIt ]),TamSx3("D1_ITEMPC")[1])))
				Alert("Pedido na linha "+StrZero(nI,2)+" já possui uma NF vinculada", "Operação será cancelada!")
				RestArea(aAreaSD1)
				RestArea(aArea)
				RETURN NIL
			EndIf
		EndIf
	Next nI
	
	// If Obrigatorio(aGets, aTela)
		Processa( { || MSAutSC7() }, 'Alterando Pedido de Compras', 'Aguarde ...', .F. )
	// EndIf

	/* EndIf */
	RestArea(aAreaSD1)
	RestArea(aArea)

	MBSaveLog():FULLWrite(, .F., "Fim: xAltSC7()")

Return nil

Static Function MSAutSC7()
	MBSaveLog():FULLWrite(, .F., "Inicio: MSAutSC7()")
	Local aArea			:= GetArea()
	Local aCabec        := {}
	Local aItem         := {}
	Local aItens        := {}
	Local lErro			:= .F.
	Local dDtEntrega	:= sToD("")
	Local nI, nItem		:= 0
	Local ZBCCONDPA		:= ""
	Local cErro			:= ""
	Local nJ			:= 0
	Local nF            := 0
	Local cPed			:= ''

	lMsHelpAuto := .T.
	lMsErroAuto := .F.

	DbSelectArea( "SC7" )
	SC7->( DbSetOrder( 1 ) )

	If SM0->M0_CODFIL <> FWxFilial('SC7')
		SM0->(DbSeek(SM0->M0_CODIGO +  FWxFilial('SC7') ))
	EndIf

	Begin Transaction
		MBSaveLog():FULLWrite(, .F., "MSAutSC7() - Inicio da transação")

		For nI := 1 to Len(o1ZBCGDad:aCols)
			If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
				
				cPed := IIF(cPed == '',&( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ],cPed)

				if SC7->(DbSeek(FWxFilial('SC7')+cPed+&( "o" + cPFoBCPIt + "ZBCGDad"):aCols[ nI, nPZBCPIt ]))
					nRecC7 := SC7->(Recno())
				else
					MsgAlert("Registro não encontrado, operação será cancelada.", "Atenção...")
					return nil
				endif
				
				aItem := {}

				aAdd( aItem, { "C7_ITEM"   		, StrZero(Val(&( "o" + cPFoBCITE + "ZBCGDad"):aCols[nI, nPZBCITE]), TamSx3("C7_ITEM")[1])	, nil } )

				aAdd( aItem, { "C7_PRODUTO"		, &( "o" + cPFoBCPRD + "ZBCGDad"):aCols[ nI, nPZBCPRD ], nil } ) // aAdd( aItem, {	"C7_DESCRI"		, cDescrPrd		 			, nil  } )

				aAdd( aItem, { "C7_QUANT" 		, &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ], nil } )

				aAdd( aItem, { "C7_PRECO" 	, &( "o" + cPFoBCPrc + "ZBCGDad"):aCols[ nI, nPZBCPrc ], nil } )
				aAdd( aItem, { "C7_TOTAL" 	, &( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nI, nPZBCTot ], nil } )

				If Empty( dDtEntrega := &( "o" + cPFoBCDTE + "ZBCGDad"):aCols[ nI, nPZBCDTE ] )
					dDtEntrega := dDataBase
				EndIf

				aAdd( aItem, { "C7_DATPRF"      , dDtEntrega		, nil  	} ) 
				aAdd( aItem, { "C7_REC_WT"      , nRecC7			, nil  	} )
				aAdd( aItem, { "C7_DATPRF"      , dDtEntrega		, nil  	} )
				aAdd( aItem, { "C7_TPFRETE"    	, "F"				, nil 	} )

				aAdd( aItens, aItem)

			EndIf
		Next nI

		If Len(aItens) == 0
			Alert('Não foi localizado Item selecionado na Base Contratual.')
		else 
			aadd(aCabec,{"C7_FILIAL" 	, FWxFilial('SC7')})
			aadd(aCabec,{"C7_NUM" 		, cPed			})
			aadd(aCabec,{"C7_EMISSAO" 	, dDataBase		})
			aadd(aCabec,{"C7_FORNECE" 	, M->ZCC_CODFOR	})
			aadd(aCabec,{"C7_LOJA" 		, M->ZCC_LOJFOR	})
			aadd(aCabec,{"C7_COND" 		, ZBCCONDPA		})
			aadd(aCabec,{"C7_CONTATO" 	, ""			})
			aAdd(aCabec,{"C7_MOEDA"    	, 1   			})
			aAdd(aCabec,{"C7_TXMOEDA"  	, 0	  			})

			lMsErroAuto := .F.
			MBSaveLog():FULLWrite(, .F., "MSAutSC7() - Inicio MATA120")

			MSExecAuto({|v,x,y,z,w| MATA120(v,x,y,z,w)}, 1, aCabec, aItens, 4,.F.)

			If lErro := lMsErroAuto
				cErro := MostraErro()
				If lErro := !At("Deseja enviar email de aprovação para o aprovador?", cErro) > 0

					DisarmTransaction()
					
					MBSaveLog():FULLWrite(, .F., "MSAutSC7() - MATA120 - Erro")

					For nI := 1 to Len(o1ZBCGDad:aCols)
						If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
							&( "o" + cPFoBCPRD + "ZBCGDad"):aCols[ nI, nPZBCPRD ] := CriaVar('ZBC_PRODUT', .F.)
						EndIf
					Next nI
				EndIf
			Else
				RecLock('SC7', .F.)
					SC7->C7_TPFRETE := "F"
				SC7->(MsUnLock())
			EndIf
			MBSaveLog():FULLWrite(, .F., "MSAutSC7() - Fim MATA120")

			If !lErro

				For nI := 1 to Len(o1ZBCGDad:aCols)
					If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
						nPZIC := nI

						SB1->( DbSetOrder(1) )
						If SB1->( DbSeek( FWxFilial('SB1')+ &( "o" + cPFoBCPRD + "ZBCGDad"):aCols[ nI, nPZBCPRD ] ) )
							RecLock('SB1', .F.)
								SB1->B1_XLOTCOM := FWxFilial('SC7')+SC7->C7_NUM
							SB1->( MsUnlock() )
						EndIf

						nItem++
						&( "o" + cPFoBCPIt + "ZBCGDad"):aCols[ nI, nPZBCPIt ] := StrZero( nItem, TamSX3('C7_ITEM')[1] ) // SC7->C7_ITEM
						RepeatFolder( 'ZBC_ITEMPC', StrZero( nItem, TamSX3('C7_ITEM')[1] ), 1, nI)

						o1ZBCGDad:aCols[ nI, nPMrkZBC] := "LBNO"
					EndIf
				Next nI
				// Enviar Email somente qdo executado do ambiente de PRODUÇÃO
				/* 				
				If GetServerIP() == GetMV("MB_IP_PROD",,"192.168.0.242")
					U_ExecAutoOK( FWxFilial('SC7') + SC7->C7_NUM )
				EndIf 
				*/

				//Adicionado por Renato de Bianchi
				//Verifica se já atendeu ao contrato completamente
				if M->ZCC_QTDRES == 0
					nQtdAberto := 0
					For nJ := 1 to Len(o1ZBCGDad:aCols)
						If !o1ZBCGDad:aCols[nJ, Len(o1ZBCGDad:aCols[1]) ] .and. Empty( &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ &( "o" + cPFoBCPed + "ZBCGDad"):nAt, nPZBCPed ])
							nQtdAberto++
						EndIf
					Next i
					if nQtdAberto == 0
						if msgYesNo("A quantidade de animais foi atendida totalmente, deseja encerrar este contrato?")
							cTxt := " "
							if !empty(AllTrim(M->ZCC_OBS))
								cTxt += AllTrim(M->ZCC_OBS) +chr(10)+chr(13)+chr(10)+chr(13)
							endIf
							cTxt += "***** FECHAMENTO DO CONTRATO *****" +chr(10)+chr(13)
							cTxt += "*DATA: "+dToC(date()) +chr(10)+chr(13)
							cTxt += "*OPERADOR: "+AllTrim(__cUserId) + " - " + AllTrim(UsrRetName(__cUserId)) +chr(10)+chr(13)
							cTxt += padr('*',50,'*')+chr(10)+chr(13)
							cTxt += " FECHAMENTO POR ATENDIMENTO A QUANTIDADE DE ANIMAIS"

							M->ZCC_STATUS := "F"
							M->ZCC_OBS := cTxt

							RecLock('ZCC', .F.)
								ZCC->ZCC_STATUS := "F"
								ZCC->ZCC_OBS := cTxt
							ZCC->( MsUnLock() )
						endIf
					endIf
				endIf
				// Fim das alterações
				GrvTable()

				For nF := 1 to len(aFolderG) // REFRESH ABAS - ATUALIZA ABAS
					&( "o" + cValToChar(nF) + "ZBCGDad" ):Refresh()
				Next nF
			EndIf
		EndIf
		MBSaveLog():FULLWrite(, .F., "MSAutSC7() - Fim da transação")
	End Transaction
	
	RestArea(aArea)
	MBSaveLog():FULLWrite(, .F., "Fim: MSAutSC7()")
Return lErro

/*
https://advplconsulting.wordpress.com/2016/11/03/funcoes-de-datas/

fConvHr(aCodAbono[nX,2],'D')
DescPDPon(aTotSpc[nPass,1], cFilSP9 )
__TimeSum(nEfetAbono, aJustifica[nX,2] )
__TimeSub(nQUANTC,nEfetAbono)
DiaSemana(aImp[nX,1],8)
CDOW(CTOD("02/06/12"))               // Resulta: Sábado
 */

User Function zX3ToArr(aArray, cCampo, nTipo, cTituloDef, cCampoDef, cBlocoDef, cAliasDef)
	MBSaveLog():FULLWrite(, .F., "Inicio: zX3ToArr()")

    Local aArea        := GetArea()
    Local cFieldX3     := ""
    Local cTipoX3      := ""
    Local cTitX3       := ""
    Local cPictX3      := ""
    Local cCBoxX3      := ""
    Local cF3X3        := ""
    Local cValidX3     := ""
    Local cUsadoX3     := ""
    Local cRelacaoX3   := ""
    Local aTamX3       := {}
    Local nTamArr      := 0
    Local cAliasTab    := ""
    Default aArray     := {}
    Default cCampo     := ""
    Default nTipo      := 0
    Default cTituloDef := ""
    Default cCampoDef  := ""
    Default cBlocoDef  := ""
    Default cAliasDef  := ""
 
    //Se tiver campo preenchido
    If ! Empty(cCampo)
        cFieldX3 := GetSX3Cache(cCampo, "X3_CAMPO")
 
        //Se o campo for encontrado na SX3
        If ! Empty(cFieldX3)
            nTamArr    := Len(aArray) + 1
            cAliasTab  := AliasCPO(cFieldX3)
            cTipoX3    := GetSX3Cache(cFieldX3, "X3_TIPO")
            aTamX3     := TamSX3(cFieldX3)
            cTitX3     := Iif(Empty(cTituloDef), GetSX3Cache(cFieldX3, "X3_TITULO"), cTituloDef)
            cPictX3    := PesqPict(cAliasTab, cFieldX3)
            cCBoxX3    := GetSX3Cache(cFieldX3, "X3_CBOX")
            cF3X3      := GetSX3Cache(cFieldX3, "X3_F3")
            cValidX3   := GetSX3Cache(cFieldX3, "X3_VALID")
            cUsadoX3   := GetSX3Cache(cFieldX3, "X3_USADO")
            cRelacaoX3 := GetSX3Cache(cFieldX3, "X3_RELACAO")
 
            //Para montar a Struct de uma FWTemporaryTable
            If nTipo == 1
                aAdd(aArray, {;
                    Iif(Empty(cCampoDef), cCampo, cCampoDef),;
                    cTipoX3,;
                    aTamX3[1],;
                    aTamX3[2];
                })
 
            //Para montar o aHeader de telas com Browse (FWMarkBrowse)
            ElseIf nTipo == 2
                aAdd(aArray, {;
                    Iif(Empty(cCampoDef), cCampo, cCampoDef),; 
                    cTitX3,;
                    nTamArr,;
                    cPictX3,;
                    1,;
                    aTamX3[1],;
                    aTamX3[2],;
                    cCBoxX3;
                })
 
            //Para montar o aSeek em telas com Pesquisa no Browse
            ElseIf nTipo == 3
                aAdd(aArray, { cTitX3, ;
                    { { "",;
                        cTipoX3,;
                        aTamX3[1],;
                        aTamX3[2],;
                        cTitX3,;
                        cPictX3;
                    } };
                })
 
            //Para montar o aHeader de telas com Browse (MsNewGetDados)
            ElseIf nTipo == 4
				aAdd(aArray, {;
					cTitX3,;
					Iif(Empty(cCampoDef), cCampo, cCampoDef),;
					cPictX3,;
					aTamX3[1],;
					aTamX3[2],;
					cValidX3,;
					cUsadoX3,;
					cTipoX3,;
					cF3X3,;
					cRelacaoX3,;
					cCBoxX3;
				})

            //Para montar o aHeader de telas com FWBrwColumn (FWFormBrowse)
            ElseIf nTipo == 5
                aAdd(aArray, FWBrwColumn():New())
                nTamArr := Len(aArray)
 
                aArray[nTamArr]:SetType(cTipoX3)
                aArray[nTamArr]:SetTitle(cTitX3)
                aArray[nTamArr]:SetSize(aTamX3[1])
                aArray[nTamArr]:SetPicture(cPictX3)
                aArray[nTamArr]:SetDecimal(aTamX3[2])
                aArray[nTamArr]:SetData(&(cBlocoDef))
 
            //Para utilizar o método SetFieldFilter (FWFormBrowse)
            ElseIf nTipo == 6
                aAdd(aArray, {;
                    cCampo,;
                    cTitX3,;
                    cTipoX3,;
                    aTamX3[1],;
                    aTamX3[2],;
                    cPictX3;
                })
 
            //Para utilizar o método SetFields (FWMarkBrowse)
            ElseIf nTipo == 7
                aAdd(aArray, {;
                    cTitX3,;
                    &("{|| " + Iif(! Empty(cAliasDef), "(" + cAliasDef + ")->", "") + cCampo + "}"),;
                    cTipoX3,;
                    cPictX3,;
                    1,;
                    aTamX3[1],;
                    aTamX3[2],;
                    .F.,;
                    ,;
                    ,;
                    ,;
                    ,;
                    ,;
                    ,;
                    ,;
                    1;
                })
            EndIf
 
        EndIf
    EndIf
 
    RestArea(aArea)

	MBSaveLog():FULLWrite(, .F., "Fim: zX3ToArr()")
Return

User Function ConZBD(cCondicao)
	MBSaveLog():FULLWrite(, .F., "Inicio: ConZBD("+cCondicao+")")
	Local aArea     := FWGetArea()
	Local nAt  		:= o1ZBCGDad:nAt
    Local nValor    := o1ZBCGDad:aCols[nAt, nPZBCTot]
	Local cCond		:= o1ZBCGDad:aCols[nAt, nPZBCCDP]
    Local dDataIni  := Date()
    Local aDupl     := {}
    Local nI 
	Local aDados 	:= {}
	Local cRet 		:= "01"
	Local nPedido 	:= o1ZBCGDad:aCols[nAt][nPZBCPed]
	Local lRet 		:= .T. 
    //Aciona a função condição, para buscar as duplicatas com os vencimentos e valores
    aDupl := Condicao(nValor, cCondicao, , dDataIni, )
    //FWAlertInfo("Existe(m) " + cValToChar(Len(aDupl)) + " parcela(s)", "Teste Condicao")
	
	o8ZBCGDad:setArray(aDados)
	
	if len(aZBD) > 0
		For nI := 1 to Len(aZBD)
			if aZBD[nI][1] == nPedido // .and. cCond != aZBD[nI][4]
				lRet := .F.
				if cCond != aZBD[nI][4] 
					aDel(aZBD, nI)
					aSize(aZBD,Len(aZBD)-1)
					lRet := .T. 
				endif
				exit
			endif
		Next nI
	endif

	if lRet 
		For nI := 1 to len(aDupl)
			aAdd(aDados,{StrZero(nI,2),aDupl[nI][1],nPedido,.F.})
		Next nI

		aAdd(aZBD,{nPedido,aDados,nPedido,cCond})
	endif 

	For nI := 1 to Len(aZBD)
		if aZBD[nI][1] == nPedido // .and. cCond != aZBD[nI][4]
			o8ZBCGDad:setArray(aZBD[nI][2])
			exit
		endif
	Next nI 

	o8ZBCGDad:Refresh()

    FWRestArea(aArea)
	MBSaveLog():FULLWrite(, .F., "Fim: ConZBD()")
Return cRet

User Function ZBCbChan(o1ZBCGDad)
	MBSaveLog():FULLWrite(, .F., "Inicio: ZBCbChan(o1ZBCGDad)")
	Local lRet 		:= .T.
	Local nAt  		:= o1ZBCGDad:nAt
	Local nPedido 	:= o1ZBCGDad:aCols[nAt][nPZBCPed]
	Local nI 		
	Local lSetArray := .F. 

	for nI := 1 to len(aZBD)
		if aZBD[nI][1] == nPedido
			o8ZBCGDad:setArray(aZBD[nI][2])
			lSetArray := .T.
			exit
		endif
	Next nI

	if !lSetArray
		o8ZBCGDad:setArray({})
	endif

	o8ZBCGDad:Refresh()
	MBSaveLog():FULLWrite(, .F., "Inicio: ZBCbChan(o1ZBCGDad)")
Return lRet 

Static Function GetColZBD()
	MBSaveLog():FULLWrite(, .F., "Inicio: GetColZBD()")

	Local aDados 	:= {}
	Local cQry 		:= ''
	Local nBakPed	

	cQry := " select DISTINCT ZBD_CODZCC,ZBD_ZCCVER,ZBD_CODPED,ZBD_ITEM,ZBD_DATA, ZBC_CONDPA from "+RetSqlName("ZBD")+" BD " + CRLF 
	cQry += " LEFT JOIN "+RetSqlName("ZBC")+" BC ON ZBD_FILIAL = ZBC_FILIAL " + CRLF 
    cQry += " AND ZBD_CODPED = ZBC_PEDIDO" + CRLF 
    cQry += " AND BC.D_E_L_E_T_ = ''" + CRLF 
	cQry += " where ZBD_FILIAL = '"+M->ZCC_FILIAL+"' " + CRLF 
	cQry += " AND ZBD_CODZCC = '"+M->ZCC_CODIGO+"' " + CRLF 
	cQry += " AND ZBD_ZCCVER = '"+M->ZCC_VERSAO+"'  " + CRLF
	cQry += " AND BD.D_E_L_E_T_ = '' " + CRLF 
	cQry += " ORDER BY ZBD_CODZCC,ZBD_ZCCVER,ZBD_CODPED,ZBD_ITEM,ZBD_DATA " + CRLF 

	MpSysOpenQry(cQry, "TMP")

	while !TMP->(EOF())
		if nBakPed != TMP->ZBD_CODPED .and. Len(aDados) > 0 
			aAdd(aZBD,{nBakPed,aDados,nBakPed,TMP->ZBC_CONDPA})
			aDados := {}
		endif

		aAdd(aDados,{TMP->ZBD_ITEM,sToD(TMP->ZBD_DATA),TMP->ZBD_CODPED,.f.})
		
		nBakPed := TMP->ZBD_CODPED
		TMP->(DBSkip())
	Enddo

	if Len(aDados) > 0
		aAdd(aZBD,{nBakPed,aDados,nBakPed,TMP->ZBC_CONDPA})
		aDados := {}
	endif
	MBSaveLog():FULLWrite(, .F., "Fim: GetColZBD()")
Return 

User Function VldDZBD(o8ZBCGDad)
Return .F.

User Function GrvDtZBD()
	MBSaveLog():FULLWrite(, .F., "Inicio: GrvDtZBD()")

	Local nI 
	Local nPedido 	:= o8ZBCGDad:aCols[1][3]
	Local nAt 		:= o8ZBCGDad:nAt

	For nI := 1 to Len(aZBD)
		if nPedido == aZBD[nI][1]
			aZBD[nI][2][nAt][2] := &(ReadVar())
			exit
		endif
	Next

	MBSaveLog():FULLWrite(, .F., "Fim: GrvDtZBD()")
Return .T.
/* Igor Oliveir 01/2024
	Replicar Datas para as outras linhas.
	 */
/* Static Function ZBDRepli()
	Local nI,nX,nJ
	Local nAt  		:= o1ZBCGDad:nAt
	Local nAtZBD 	
	Local nPedido 	:= o1ZBCGDad:aCols[nAt][nPZBCPed]
	Local aRepli 	:= {}
	Local aPedidos 	:= {}

	IF MsgYesNo("Deseja replicar as datas informadas para todas as linhas selecionadas com a mesma condição de pagamento?")
		For nI := 1 to Len(aZBD)
			If nPedido == aZBD[nI][1]
				aRepli := aClone(aZBD[nI][2])
				nAtZBD := nI
				For nX := 1 to Len(aRepli)
					aRepli[nX][3] := ''
				Next nX
				exit
			endif
		Next nI

		For nI := 1 to Len(o1ZBCGDad:aCols)
			if o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
				aAdd(aPedidos,{o1ZBCGDad:aCols[ nI, nPZBCPed],o1ZBCGDad:aCols[nI][nPZBCCDP]})
			endif
		Next nI 
		
		For nX := 1 to Len(aZBD)
			if  nAtZBD != nX 
				For nI := 1 to Len(aPedidos)
					if ( aPedidos[nI][1] == aZBD[nX][1] .or. Empty(aZBD[nX][1]) ).and. aPedidos[nI][2] == aZBD[nX][4]
						For nJ := 1 to Len(aZBD[nX][2])
							aZBD[nX][2][nJ][2] := aRepli[nJ][2]
						Next nJ
					endif 
				Next nI
			endif
		Next nX
		o8ZBCGDad:Refresh()
	endif
Return */

User Function zBGordo()
	MBSaveLog():FULLWrite(, .F., "Inicio: zBGordo()")

	Local aArea	:= FWGetArea()
	Local cRet 	:= &(ReadVar())
	Local _cQry	:= ""
	Local cPergBG := "BGCOMM11"
	Local oDlgZ
    Local aCpos  := {}
    Local aRet   := {}
    Local cMsg   := ''
	Local cRetorno := ''
    Local lRet   := .F.
	Local _stru	:={}
	Local nI 
	Local cArq 
	Local cBakParam := MV_PAR01
	Private lInverte := .F.
	Private cMark   := GetMark()   
	Private oMark

	if cRet == 'S'
		If Pergunte(cPergBG,.T.)

			AADD(_stru,{"OK"        	,"C"     ,2          ,0          })
			AADD(_stru,{"FILIAL"    	,"C"     ,7          ,0          })
			AADD(_stru,{"DTABATE"   	,"D"     ,8          ,0          })
			AADD(_stru,{"LOTE"   		,"C"     ,10         ,0          })
			AADD(_stru,{"PESO"   		,"N"     ,12         ,2          })
			AADD(_stru,{"QUANT"	 		,"N"     ,5          ,0          })
			AADD(_stru,{"VALORARR"  	,"N"     ,12         ,2          })
			AADD(_stru,{"VALORTOT" 		,"N"     ,12         ,2          })
			AADD(_stru,{"OBS" 			,"C"     ,40         ,0          })
			AADD(_stru,{"RECNO" 		,"N"     ,7          ,0          })

			cArq:=Criatrab(_stru,.T.)

			If Select("TTRB") > 0
				TTRB->( dBCloseArea( ) )
			EndIf

			DbUseArea(.T.,,cArq,"TTRB",.F.,.F.)

			_cQry := " Select R_E_C_N_O_ AS RECNO,ISNULL( CONVERT( VARCHAR(4096), CONVERT(VARBINARY(4096), ZAB_OBS)),'') AS MEMO , * " + CRLF
			_cQry += " from "+RetSqlName("ZAB")+" ZAB " + CRLF
			_cQry += " WHERE ZAB_DTABAT BETWEEN '"+dToS(mv_par01)+"' AND '"+dToS(mv_par02)+"' " + CRLF
			if !Empty(mv_par03)
				_cQry += " AND ZAB_BAIA = '"+mv_par03+"'" + CRLF
			endif
			if mv_par04 == 1
				_cQry += "	 AND ZAB_CODZCC + ZAB_VERZCC + ZAB_FORZCC + ZAB_LOJZCC NOT IN (SELECT ZCC_CODIGO + ZCC_VERSAO + ZCC_CODFOR + ZCC_LOJFOR " + CRLF 
				_cQry += "														FROM "+RetSqlName("ZCC")+" ZCC " + CRLF 
				_cQry += "														WHERE ZCC_CODIGO = ZAB_CODZCC" + CRLF 
				_cQry += "														AND ZCC_VERSAO = ZAB_VERZCC " + CRLF 
				_cQry += "														AND ZCC_CODFOR = ZAB_FORZCC " + CRLF 
				_cQry += "														AND ZCC_LOJFOR = ZAB_LOJZCC " + CRLF 
				_cQry += "														AND ZCC.D_E_L_E_T_ = '' " + CRLF 
				_cQry += "														) " + CRLF 
			endif 
			_cQry += " AND ZAB.D_E_L_E_T_ = '' " + CRLF
			_cQry += " order by ZAB_DTABAT" + CRLF

			If lower(cUserName) $ 'bernardo,ioliveira,atoshio'
				MemoWrite("C:\totvs_relatorios\"+"_bgcomm11_.sql" , _cQry)
			EndIf

			MpSysOpenQry(_cQry,"TMP")

			DbSelectArea("TTRB")     
			While !TMP->(EOF())
				RecLock("TTRB",.T.)
					TTRB->FILIAL 		:= TMP->ZAB_FILIAL
					TTRB->DTABATE 		:= sToD(TMP->ZAB_DTABAT)
					TTRB->LOTE 			:= TMP->ZAB_BAIA
					TTRB->PESO 			:= TMP->ZAB_PESOLQ
					TTRB->QUANT 		:= TMP->ZAB_QTABAT
					TTRB->VALORARR 		:= TMP->ZAB_VLRARR //VAL(Transform( TMP->ZAB_VLRARR, "@E 999,999,999.99"))
					TTRB->VALORTOT 		:= TMP->ZAB_VLRTOT //VAL(Transform( TMP->ZAB_VLRTOT, "@E 999,999,999.99"))
					TTRB->OBS 			:= AllTrim(TMP->MEMO)
					TTRB->RECNO 		:= TMP->RECNO
				TTRB->(MSUNLOCK())
				TMP->(dbSkip())
			End
			TMP->(dbCloseArea())

			aCpos := {{ "OK"        ,, "Mark"           ,"@!"},;
					{ "FILIAL"      ,, "Filial"         ,"@!"},;
					{ "DTABATE"     ,, "Data"           ,"@!"},;
					{ "LOTE"        ,, "Lote"           ,"@!"},;
					{ "PESO"       	,, "Peso"   	    ,"@E 999,999,999.99"},;
					{ "QUANT"       ,, "Quantidade"   	,"@E 99999"},;
					{ "VALORARR"  	,, "Valor @"      	,"@E 999,999,999.99"},;
					{ "VALORTOT"  	,, "Valor Total"    ,"@E 999,999,999.99"},;
					{ "OBS"       	,, "Observação"    	,"@!"},;
					{ "RECNO"       ,, "Recno"        	,"@!"}}
			
			DEFINE MSDIALOG oDlgZ TITLE /*STR0083*/ "Listagem dos Abates" FROM 0,0 TO 310,1200 PIXEL
					
				DbSelectArea("TTRB")
				DbGotop()
				
				oMark := MsSelect():New("TTRB","OK","",aCpos,@lInverte,@cMark,{0,0,140,600},,,,,/* aCores */)
				oMark:bMark := {| | Disp()}

				DEFINE SBUTTON FROM 142,574 TYPE 1 ACTION (oDlgZ:End(), lRet:=.T.,;
				aRet := u_GetZABM11() )  ENABLE OF oDlgZ
				
				ACTIVATE MSDIALOG oDlgZ CENTER

				If Len(aRet) > 0
					DBSelectArea("ZAB")
					For nI := 1 to Len(aRet)
						ZAB->(DBGOTO( aRet[nI][1] ))

							cRetorno += ZAB->ZAB_CODIGO  + " - "  + DToC(ZAB->ZAB_DTABAT) + CRLF

							RecLock("ZAB",.F.)
								ZAB->ZAB_OUTMOV := '1'
								ZAB->ZAB_CODZCC := M->ZCC_CODIGO
								ZAB->ZAB_VERZCC := M->ZCC_VERSAO
								ZAB->ZAB_FORZCC := M->ZCC_CODFOR
								ZAB->ZAB_LOJZCC := M->ZCC_LOJFOR
						ZAB->(MSUNLOCK())
					Next nI
					ZAB->(DBCLOSEAREA())
					lRet := .T. 
				EndIf

				if lRet
					cMsg := "O contrato foi vinculado ao[s] seguinte[s] abate[s] : " + CRLF 
					cMsg += "Código - Data " + CRLF
					cMsg +=  cRetorno

					MSGALERT( cMsg , "Atenção" )
					cRetorno := ''
				endif
		endif 
	endif
	MV_PAR01 := cBakParam
	FwRestArea(aArea)

	MBSaveLog():FULLWrite(, .F., "Fim: zBGordo()")

Return cRet

User Function GetZABM11()
	MBSaveLog():FULLWrite(, .F., "Inicio: GetZABM11()")

	Local aRet := {}
	
	DbSelectArea("TTRB")
	DbGotop()
	While TTRB->(!Eof())
		If !Empty(TTRB->OK) //campos selecionados
			aAdd(aRet,{TTRB->RECNO})
		Endif
		TTRB->(DbSkip())
	Enddo
	TTRB->(DbCloseArea())

	MBSaveLog():FULLWrite(, .F., "Fim: GetZABM11()")
Return aRet

//Funcao executada ao Marcar/Desmarcar um registro.   
Static Function Disp()
	MBSaveLog():FULLWrite(, .F., "Inicio: Disp()")

	RecLock("TTRB",.F.)
		If Marked("OK")
			TTRB->OK := cMark
		Else
			TTRB->OK := ""
		Endif
	MSUNLOCK()

	oMark:oBrowse:Refresh()
	MBSaveLog():FULLWrite(, .F., "Fim: Disp()")
Return 
