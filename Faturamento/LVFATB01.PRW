#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "Fileio.ch"
#INCLUDE "FWMBROWSE.CH"
#Include "TryException.ch"


/*------------------------------------------------------------------------------------------------,
 | Principal: 			            U_LVFATB01()            		                              |
 | Func:  LVFATB01()	            	          	            	          	                  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		                  |
 | Data:  09.09.2019	            	          	            	                              |
 | Desc:  Contrato de Venda - Bovinos                                	                          |
 '------------------------------------------------------------------------------------------------|
 | Obs.:                                                                                          |
 |                                                                                                |
 '------------------------------------------------------------------------------------------------*/
User Function LVFATB01()
	Local aArea   := GetArea()

	Private oBrowse
	Private cCadastro := 'Contrato de Venda - Bovinos'
	Private xQuant := 0
	Private xQtFat := 0
	
	DbSelectArea("ZA5")
	ZA5->(DbSetOrder(1))

	DbSelectArea("ZA6")
	ZA6->(DbSetOrder(1))
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZA5')
	oBrowse:SetDescription( cCadastro )

	// oBrowse:AddLegend( "ZA5_STATUS == '1'", "GREEN"  , "Aberto"       )
	// oBrowse:AddLegend( "ZA5_STATUS == '2'", "BLACK"  , "Cancelado" )

	SetKey( VK_F8, {|| U_fGridFatB01() } ) // nao pode ser VK_F10: esta usada no pedido de venda

	oBrowse:Activate()
	RestArea(aArea)
Return NIL

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"       ACTION "PesqBrw"          OPERATION 1 ACCESS 0 DISABLE MENU
	// ADD OPTION aRotina TITLE 'Visualizar'      ACTION 'axVisual' 		 OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar'      ACTION 'VIEWDEF.LVFATB01' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'         ACTION 'VIEWDEF.LVFATB01' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'         ACTION 'VIEWDEF.LVFATB01' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'         ACTION 'VIEWDEF.LVFATB01' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Gerar Fat. [F8]' ACTION 'U_fGridFatB01()'  OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE 'Legenda'         ACTION 'U_ZA5LEG()'       OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE 'Conhecimento'    ACTION "MsDocument('ZA5',ZA5->(RecNo()), 4)"       OPERATION 4 ACCESS 0
Return aRotina

User Function ZA5LEG()
	Local aLegenda    := {}
	
	aAdd( aLegenda, { "BR_VERDE"	, "Aberto"    })
	aAdd( aLegenda, { "BR_PRETO"	, "Cancelado" })
	aAdd( aLegenda, { "BR_VERMELHO"	, "Efetivado" })

	BrwLegenda( cCadastro, "Legenda", aLegenda )

Return Nil

User Function fCommitDef( oMdl )
	Local aArea := GetArea()
	Local oModelDad := FWModelActive()
	Local nOpc      := oModelDad:GetOperation()
	Local oMGZA5    := oModelDad:GetModel( 'ZA5MASTER' )
	Local oMGZA6    := oModelDad:GetModel( 'ZA6DETAIL' )
	Local nI        := 0, nJ := 0
	Local lRecLock  := .T.
	Local aHeadZA5  := APBuildHeader("ZA5")
	Local aHeadZA6  := oMGZA6:aHeader

	Begin Transaction
		If nOpc == MODEL_OPERATION_INSERT // .OR. 
			For nI := 1 To oMGZA6:GetQtdLine()
				oMGZA6:GoLine(nI)
				If !oMGZA6:isDeleted() 
					If oMGZA6:IsUpdated()
						RecLock('ZA6', lRecLock := !DbSeek( xFilial("ZA6") +;
														oMGZA6:GetValue('ZA6_CODIGO') +;
														StrZero(nI, TamSX3('ZA6_ITEM')[1]) ) )
							for nJ := 1 to len( aHeadZA6 )
								If aHeadZA6[nJ, 10] = 'V'// .OR. aHeadZA6[nJ,  8] = 'M'
									loop
								EndIf
								// If aHeadZA6[nJ,  8] = 'D'
								// 	&(aHeadZA6[nJ,02]) := STOD( oMGZA6:GetValue( aHeadZA6[nJ,02] ) )
								// Else
									&(aHeadZA6[nJ,02]) := oMGZA6:GetValue( aHeadZA6[nJ,02] )
								// EndIf
								ZA6->ZA6_FILIAL := xFilial("ZA6")
								ZA6->ZA6_CODIGO := M->ZA5_CODIGO
							Next nJ
						ZA6->(MsUnlock())
					EndIf
				EndIf
			Next nI
			
			RecLock('ZA5', Iif(nOpc == 3, .T.,;
					lRecLock := !DbSeek( xFilial("ZA5") + oMGZA5:GetValue('ZA5_CODIGO') ) ) )
				for nJ := 1 to len( aHeadZA5 )
					If aHeadZA5[nJ, 10] = 'V' // .OR. aHeadZA5[nJ,  8] = 'M'
						loop
					EndIf
					&(aHeadZA5[nJ,02]) := oMGZA5:GetValue( aHeadZA5[nJ,02] )
				Next nJ
				ZA5->ZA5_FILIAL := xFilial("ZA5")
			ZA5->(MsUnlock())
		
		Else// If nOpc == MODEL_OPERATION_UPDATE
 			FWFormCommit( oModelDad )
		
		EndIf
	End Transaction
	RestArea(aArea)
Return .T.

Static Function ModelDef()

	// Cria as estruturas a serem usadas no Modelo de Dados
	Local oStruZA5 := FWFormStruct( 1, 'ZA5' )
	Local oStruZA6 := FWFormStruct( 1, 'ZA6' )
	// local bZA6LinePr := {|oGridZA6, nLin, cOperacao, cCampo, xValAtr, xValAnt| ZA6LinPreG(oGridZA6, nLin, cOperacao, cCampo, xValAtr, xValAnt)}
	// Local bVldPos  := {|| .T. }
	Local bVldCom  := {|oMdl| U_fCommitDef( oMdl ) }
	Local oModel   := MPFormModel():New("FATB01LV", /*Pre-Validacao*/, /* bVldPos */ /*Pos-Validacao*/, bVldCom /*Commit*/, /*Cancel*/)
	Local aTrigger := {}
	Local __aRel   := {}

	oStruZA5:SetProperty('ZA5_NOME', MODEL_FIELD_INIT,;
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "U_B001IniCampo()" ))
	
	oStruZA5:SetProperty('ZA5_DESCPG', MODEL_FIELD_INIT,;
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "U_B001IniCampo()" ))
	
	oStruZA6:SetProperty('ZA6_CODIGO', MODEL_FIELD_INIT,;
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "U_B001IniCampo()" ))

	oStruZA6:SetProperty('ZA6_ITEM', MODEL_FIELD_INIT,;
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "U_B001IniCampo()" ))
	
	oStruZA6:SetProperty('ZA6_DESC', MODEL_FIELD_INIT,;
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "U_B001IniCampo()" ))

 	oStruZA6:SetProperty('ZA6_DTES', MODEL_FIELD_INIT,;
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "U_B001IniCampo()" ))

 	aTrigger := aClone(FwStruTrigger(;	// Z0D_PROD -> Z0D_DESC
			"ZA6_DTDE" ,;               // Campo Dominio
			"ZA6_DTATE",;              // Campo de Contradominio
			"FwFldGet('ZA6_DTDE')+7",;  // Regra de Preenchimento
			.F.,;                      // Se posicionara ou nao antes da execucao do gatilhos
			"" ,;                       // Alias da tabela a ser posicionada
			0  ,;                         // Ordem da tabela a ser posicionada
			"" ,;                        //'xFilial("SB8")+FWFldGet("'+pAlias+'_PROD")+'+pAlias+'_LOTE' ,; // Chave de busca da tabela a ser posicionada
			NIL,;                       // Condicao para execucao do gatilho
			"01" ))                     // Sequencia do gatilho (usado para identIficacao no caso de erro)
	oStruZA6:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])

	oModel:AddFields( 'ZA5MASTER', /*cOwner*/ , oStruZA5 ) // , /*bPre*/, /* { |x| FVldTok(oModel, .F.)} *//*bPost*/, /*bLoad*/)
	oModel:AddGrid(   'ZA6DETAIL', 'ZA5MASTER', oStruZA6 ) // , /* bZA6LinePr */ /*bLinePre*/, /* { |oModel| FZA6Lok(oModel)} */ /*bLinePost*/,/*bPre - Grid Inteiro*/, /* { |x| FZA6Tok(x)} */ /*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

	oModel:GetModel('ZA6DETAIL'):SetOptional(.T.)

	//oModel:GetModel( 'ZA5MASTER' ):SetOnlyView( .T. )
	// aAdd( __aRel, { 'ZA6_FILIAL', 'Iif(!INCLUI, ZA5->ZA5_FILIAL, FWxFilial("ZA5"))' } )
	// aAdd( __aRel, { 'ZA6_CODIGO', 'Iif(!INCLUI, ZA5->ZA5_CODIGO,  "")'              } )

	aAdd( __aRel, { 'ZA6_FILIAL', 'ZA5_FILIAL' } )
	aAdd( __aRel, { 'ZA6_CODIGO', 'ZA5_CODIGO'       } )

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'ZA6DETAIL', __aRel, ZA6->( IndexKey( 1 ) ) )
	
	oModel:SetPrimaryKey({ "ZA5_FILIAL","ZA5_CODIGO"})
	//oModel:SetPrimaryKey( { "ZA5_FILIAL", "ZA5_CODIGO" } )
	// oModel:SetPrimaryKey( { "ZA6_FILIAL", "ZA6_CODIGO", "ZA6_ITEM" } )
	
	oModel:GetModel( 'ZA6DETAIL' ):SetUniqueLine( { 'ZA6_CODIGO', 'ZA6_ITEM' } )
	// oModel:GetModel('ZA6DETAIL'):SetNoInsertLine( .T. ) // Não permitir serem inseridas linhas no grid. 
	// oModel:GetModel('ZA6DETAIL'):SetNoUpdateLine( .T. ) // Não permite alterar as linhas do grid.
	// oModel:GetModel('ZA6DETAIL'):SetNoDeleteLine( .T. ) // Não permite apagar linhas do grid. 

	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( cCadastro )

	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( 'ZA5MASTER' ):SetDescription( 'Dados do Cabeçalho' )
	oModel:GetModel( 'ZA6DETAIL' ):SetDescription( 'Dados dos Itens' )

/*
	Atribui o conteúdo a um campo do modelo.
	FWFldPut(<cCampo >, <xConteudo >, [ nLinha ], [ oModel ], [ lShowMsg ], [ lLoad ])-> lRet
	oModel:GetModel( 'Z0EDETAIL' ):FWFldPut(<cCampo >, <xConteudo >)

	Obtem o conteúdo de um campo do modelo
	FWFldGet(<cCampo >, [ nLinha ], [ oModel ], [ lShowMsg ])-> xRet
*/
	// Retorna o Modelo de dados
Return oModel

User Function FATB01LV()
Local aArea      := GetArea()
Local lRet       := .T.
Local aParam     := PARAMIXB
// Local oObj       := aParam[1]
Local cIdPonto   := aParam[2]
// Local cIdModel   := oObj:GetId()
// Local cClasse    := oObj:ClassName()
// Local oModelGrid := oObj:GetModel( 'ZA6DETAIL' )
// Local nI         := 0
// Local lRecLock   := .T.

// Alert('cIdPonto: ' + cIdPonto + ' cIdModel: ' + cIdModel + ' cClasse: ' + cClasse)

If ALTERA .AND. cIdPonto == "MODELVLDACTIVE"
	If !(/* cUserName */ __cUserID $ GetMV('MB_CANUPD',,'atoshio, admin, administrador'))
		lRet := .F.
		MsgAlert("Usuario: ["+cUserName+"] não tem permissão para alterar este registro. Esta operação será cancelada.",;
					"Atenção")
	EndIf

// ElseIf cIdModel == "FATB01LV" .and. cIdPonto == "MODELPRE" .and. cClasse == "FWFORMMODEL"
// 	oModelGrid:LoadValue('ZA6_CODIGO', M->ZA5_CODIGO)
EndIf

// If cIdModel == "FORMLINEPRE"
// 	// oObj:SetValue('ZA6_CODIGO', M->ZA5_CODIGO)
// EndIf
// 	If cIdPonto == 'MODELCOMMITTTS'
// 		Alert('cIdPonto: ' + cIdPonto + ' cIdModel: ' + cIdModel + ' cClasse: ' + cClasse)
// 	/* 
// 		If oObj:nOperation == 3
// 			// For nI := 1 To Len(oModelGrid:aCols)
// 			// 	oModelGrid:GoLine(nI)
// 			// 	//Se a linha não estiver excluída, inclui o registro
// 			// 	If !oModelGrid:aCols[nI, Len(oGridMoModelGridodel:aCols[1]) ]
// 			// 		RecLock('ZA6', lRecLock := !DbSeek( xFilial("ZA6") + oModelGrid:GetValue('ZA6_CODIGO') ) )
// 			// 			// U_GrvCpo( "ZDM", oGridModel:aCols, oGridModel:aHeader, nI )
// 			// 			ZA6->ZA6_CODIGO := oModelGrid:GetValue('ZA6_CODIGO')
// 			// 		ZA6->(MsUnlock())
// 			// 	EndIf
// 			// Next nI
// 		EndIf
//  */
// 	EndIf
RestArea(aArea)
Return lRet

Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'LVFATB01' )
	// Cria a estrutura a ser acrescentada na View
	Local oStruZA5 := FWFormStruct( 2, 'ZA5' )
	Local oStruZA6 := FWFormStruct( 2, 'ZA6' )
	// Inicia a View com uma View ja existente
	Local oView    := nil

	// Altera o Modelo de dados quer será utilizado
	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( 'VIEW_ZA5', oStruZA5, 'ZA5MASTER' )
	oView:AddGrid(  'VIEW_ZA6', oStruZA6, 'ZA6DETAIL' )

	oView:AddIncrementField("VIEW_ZA6", "ZA6_ITEM")

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'EMCIMA'  , 50 )
	oView:CreateHorizontalBox( 'EMBAIXO' , 50 )

	// Liga a identIficacao do componente
	oView:EnableTitleView( 'VIEW_ZA5' , 'Dados do Cabeçalho' )
	oView:EnableTitleView( 'VIEW_ZA6' , 'Dados dos Itens'    )

	oView:SetCloseOnOk( { |oView| .T. } )

	// Relaciona o identIficador (ID) da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZA5' , 'EMCIMA'  )
	oView:SetOwnerView( 'VIEW_ZA6' , 'EMBAIXO' )
	
Return oView


User Function B001IniCampo() // (_cAlias,_cCampo)

	Local oModelDad  := FWModelActive()
	Local oModelGrid := oModelDad:GetModel( "ZA6DETAIL" )
	Local cRetorno   := Space( TamSX3(SubS(ReadVar(),4))[1] )

	If ReadVar() == "M->ZA5_NOME"
		If ALTERA
			cRetorno := POSICIONE("SA1", 1, XFILIAL("SA1")+ZA5->ZA5_CLIENT+ZA5->ZA5_LOJA, "A1_NOME")
		EndIf
	
	ElseIf ReadVar() == "M->ZA5_DESCPG"
		If ALTERA
			cRetorno := POSICIONE("SE4", 1, XFILIAL("SE4")+ZA5->ZA5_CPAG, "E4_DESCRI")
		EndIf
	
	ElseIf ReadVar() == "M->ZA6_CODIGO"
		cRetorno := &(IIF(INCLUI, 'M', 'ZA5') + "->" + "ZA5_CODIGO")

	ElseIf ReadVar() == "M->ZA6_ITEM"
		cRetorno   := StrZero( 1, TamSX3(SubS(ReadVar(),4))[1] )
		If oModelGrid:GetLine() > 0 .and. !Empty(oModelGrid:GetValue('ZA6_ITEM'))
			cRetorno := StrZero( Val(oModelGrid:GetValue('ZA6_ITEM'))+1, TamSX3("ZA6_ITEM")[1] )
		EndIf
	
	ElseIf ReadVar() == "M->ZA6_DESC" /* FwFldGet("ZA6_PROD") */
		// cRetorno := ""
		If ALTERA // &(IIF(INCLUI, 'M', 'ZA6') + "->" + "ZA6_PROD")
			cRetorno := Posicione("SB1", 1, xFilial("SB1") + ZA6->ZA6_PROD, "B1_DESC")
		EndIf
	
	ElseIf ReadVar() == "M->ZA6_DTES" /* FwFldGet("ZA6_PROD") */
		// cRetorno := ""
		If ALTERA // &(IIF(INCLUI, 'M', 'ZA6') + "->" + "ZA6_TES")
			cRetorno := Posicione("SF4", 1, xFilial("SF4") + ZA6->ZA6_TES, "F4_TEXTO")
		EndIf
	
	ElseIf ReadVar() == "M->ZA6_DTDE"
		cRetorno := dDataBase
	
	ElseIf ReadVar() == "M->ZA6_DTATE"
		cRetorno := dDataBase+14

	EndIf

Return cRetorno

/* 
static function ZA6LinPreG( oGrid, nLin, cOperacao, cCampo, xValAtr, xValAnt)
local aArea    := GetArea()
Local oModel   := FWModelActive()
Local oGridZA6 := oModel:GetModel( 'ZA6DETAIL' )
local lRet     := .T.
Local nI       := 0

	if cOperacao == "DELETE"
	// ElseIf cOperacao == "UNDELETE"
	// 	Alert("UNDELETE")
	// elseif cOperacao == "SETVALUE"
	// 	Alert("SETVALUE")
	EndIf

	if !Empty(aArea)
    	RestArea(aArea)
	EndIf
Return lRet
 */



/*------------------------------------------------------------------------------------------------,
 | Principal: 			            U_LVFATB01()            		                              |
 | Func:  LVFATB01()	            	          	            	          	                  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		                  |
 | Data:  09.09.2019	            	          	            	                              |
 | Desc:  Contrato de Venda - Bovinos                                	                          |
 '------------------------------------------------------------------------------------------------|
 | Obs.:                                                                                          |
 |                                                                                                |
 '------------------------------------------------------------------------------------------------*/
User Function fGridFatB01()
Local aArea      := GetArea()
Local nOpcA
Local oDlg       := nil
Local aSize      := {}, aObjects := {}, aInfo := {}   , aPObjs := {}
// Local aAlter		:= U_LoadCustomCpo("ZA6")
Local aHeader    := {}, _aHead1 := {} , _aHead2 := {} , _aCols1 := {}, _aCols2 := {}, cCpoJump := ""
Local aCols      := {}, aColsR := {}  , aCriaCols := {}
Local lErro      := .F.
// Local aButtons := {}
// Local nI         := 0
// Local nGUZA6     := 0

Private oZA6GDad    := nil//  , aZA6Head  := {}, aZA6Cols  := {}, nUZA6 := 1
Private aGets    := {}
Private aTela    := {}
Private INCLUI := .F.
Private ALTERA := .T.
Private N := 0

cCpoJump         := "ZA5_QUANT , ZA5_QTDFAT, ZA5_SLDFAT, ZA5_OBS   , ZA6_FILIAL, ZA6_CODIGO"
_aHead1          := APBuildHeader("ZA5") // Z0E->(dbStruct()) // GeraHeader()
_aCols1          := A610CriaCols( "ZA5", _aHead1, , {|| .F.})

/* 
_aHead2 := APBuildHeader("SC5")
AAdd(_aHead1, _aHead2[ aScan( _aHead2, {|x| AllTrim(x[2]) == 'C5_TRANSP'} ) ] )
*/
DbSelectArea("SX3")
SX3->(DbSetOrder(2)) // Campo	
If SX3->(DbSeek( "C5_TRANSP" ))
/* 01 */ AAdd(_aHead1, { SX3->X3_TITULO ,;
/* 02 */ 			     AllTrim(StrTran(SX3->X3_CAMPO,"C5_","ZA5_")),;
/* 03 */ 			     SX3->X3_PICTURE,;
/* 04 */ 			     SX3->X3_TAMANHO,;
/* 05 */ 			     SX3->X3_DECIMAL,;
/* 06 */ 			     ""/* SX3->X3_VALID */,;
/* 07 */ 			     SX3->X3_USADO  ,;
/* 08 */ 			     SX3->X3_TIPO   ,;
/* 09 */ 			     SX3->X3_F3     ,;
/* 10 */ 				 "R" /* SX3->X3_CONTEXT */ } )
/* 00 */ 			     // SX3->X3_CBOX   ,;
/* 00 */ 			     // SX3->X3_RELACAO,;
/* 00 */ 			     // SX3->X3_WHEN   ,;
/* 00 */ 			     // SX3->X3_VISUAL ,;
/* 00 */ 			     // SX3->X3_VLDUSER,;
/* 00 */ 			     // SX3->X3_PICTVAR,;
/* 00 */ 			     // X3Obrigat(SX3->X3_CAMPO) } )
	_aCols1[1,1, Len(_aCols1[1,1])] := Space( TAMSX3("C5_TRANSP")[1])

// /* 01 */ AAdd(_aHead1, { SX3->X3_TITULO ,;
// /* 02 */ 			     "ZA5_VEICUL",;
// /* 03 */ 			     SX3->X3_PICTURE,;
// /* 04 */ 			     SX3->X3_TAMANHO,;
// /* 05 */ 			     SX3->X3_DECIMAL,;
// /* 06 */ 			     "" /* SX3->X3_VALID */,;
// /* 07 */ 			     SX3->X3_USADO  ,;
// /* 08 */ 			     SX3->X3_TIPO   ,;
// /* 09 */ 			     "DA3" /* SX3->X3_F3 */     ,;
// /* 10 */ 				 "R" /* SX3->X3_CONTEXT */ } )
// /* 00 */ 			     // SX3->X3_CBOX   ,;
// /* 00 */ 			     // SX3->X3_RELACAO,;
// /* 00 */ 			     // SX3->X3_WHEN   ,;
// /* 00 */ 			     // SX3->X3_VISUAL ,;
// /* 00 */ 			     // SX3->X3_VLDUSER,;
// /* 00 */ 			     // SX3->X3_PICTVAR,;
// /* 00 */ 			     // X3Obrigat(SX3->X3_CAMPO) } )
// 	_aCols1[1,1, Len(_aCols1[1,1])] := CriaVar("C5_TRANSP", .F.)
EndIf
// SX3->(DbSetOrder(2)) // Campo	
// If SX3->(DbSeek( "C5_VEICULO" ))
// 	AAdd(_aHead1, { SX3->X3_TITULO ,;
// 					StrTran(SX3->X3_CAMPO,"C5_","ZA5_"),;
// 					SX3->X3_PICTURE,;
// 					SX3->X3_TAMANHO,;
// 					SX3->X3_DECIMAL,;
// 					"" /* SX3->X3_VALID */,;
// 					SX3->X3_USADO  ,;
// 					SX3->X3_TIPO   ,;
// 					SX3->X3_F3     ,;
// 					"R" /* SX3->X3_CONTEXT */ } )
// 					// SX3->X3_CBOX   ,;
// 					// SX3->X3_RELACAO,;
// 					// SX3->X3_WHEN   ,;
// 					// SX3->X3_VISUAL ,;
// 					// SX3->X3_VLDUSER,;
// 					// SX3->X3_PICTVAR,;
// 					// X3Obrigat(SX3->X3_CAMPO) } )
// 	aAdd( _aCols1[1,1], CriaVar("C5_VEICULO", .F.) )
// EndIf
SX3->(DbSetOrder(2)) // Campo	
If SX3->(DbSeek( "C5_PLACA1" ))
	AAdd(_aHead1, { SX3->X3_TITULO ,;
					AllTrim(StrTran(SX3->X3_CAMPO,"C5_","ZA5_")),;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					"" /* SX3->X3_VALID */,;
					SX3->X3_USADO  ,;
					SX3->X3_TIPO   ,;
					SX3->X3_F3     ,;
					"R" /* SX3->X3_CONTEXT */ } )
					// SX3->X3_CBOX   ,;
					// SX3->X3_RELACAO,;
					// SX3->X3_WHEN   ,;
					// SX3->X3_VISUAL ,;
					// SX3->X3_VLDUSER,;
					// SX3->X3_PICTVAR,;
					// X3Obrigat(SX3->X3_CAMPO) } )
	aAdd( _aCols1[1,1], Space( TAMSX3("C5_PLACA1")[1]) )
EndIf
SX3->(DbSetOrder(2)) // Campo	
If SX3->(DbSeek( "C5_PLACA2" ))
	AAdd(_aHead1, { SX3->X3_TITULO ,;
					AllTrim(StrTran(SX3->X3_CAMPO,"C5_","ZA5_")),;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					"" /* SX3->X3_VALID */,;
					SX3->X3_USADO  ,;
					SX3->X3_TIPO   ,;
					SX3->X3_F3     ,;
					"R" /* SX3->X3_CONTEXT */ } )
					// SX3->X3_CBOX   ,;
					// SX3->X3_RELACAO,;
					// SX3->X3_WHEN   ,;
					// SX3->X3_VISUAL ,;
					// SX3->X3_VLDUSER,;
					// SX3->X3_PICTVAR,;
					// X3Obrigat(SX3->X3_CAMPO) } )
	aAdd( _aCols1[1,1], Space( TAMSX3("C5_PLACA2")[1]) )
EndIf
aAdd( _aCols1[1,1], .F. )

_aHead2 := APBuildHeader("ZA6") // A610CriaHeader("ZA6",,,.T.) // Z0E->(dbStruct()) // GeraHeader()
_aCols2 := A610CriaCols( "ZA6", _aHead2, , {|| .F. })

// //       cAlias, aHDados,   aCDados, nUDados, nOrd, 
// U_BDados( "ZA6", @_aHead2, @_aCols2, @nGUZA6,    1, /* lFilial */, /* cCond */, /* lStatus */,;
// 			/* cCpoLeg */, /* cLstCpo */, /* cElimina */, /* cCpoNao */, /* cStaReg */, /* cCpoMar */, /* cMarDef */,;
// 			/* lLstCpo */, /* aLeg */, /* lEliSql */, /* lOrderBy */, /* cCposGrpBy */, /* cGroupBy */, /* aCposIni */,;
// 			/* aJoin */, /* aCposCalc */, /* cOrderBy */, /* aCposVis */, /* aCposAlt */, /* cCpoFilial */, /* nOpcX */,;
// 			.F. /* lMostRecNo */, /* lLinMax */)
MbMergeArray( _aHead1, _aHead2, @aHeader, _aCols1, _aCols2, @aCriaCols, cCpoJump )

// Atualizando algumas definições 
// TAMANHO
aHeader[aScan(aHeader, {|X| X[2] == "ZA5_NOME  "}), 04] -= 15
aHeader[aScan(aHeader, {|X| X[2] == "ZA5_DESCPG"}), 04] -= 15
aHeader[aScan(aHeader, {|X| X[2] == "ZA5_MSGNF "}), 04] := 50 
aHeader[aScan(aHeader, {|X| X[2] == "ZA6_PROD  "}), 04] -= 10
aHeader[aScan(aHeader, {|X| X[2] == "ZA6_DESC  "}), 04] -= 15
aHeader[aScan(aHeader, {|X| X[2] == "ZA6_DTES  "}), 04] -= 15

aSize := MsAdvSize( .T. ) 
AAdd( aObjects, { 100 , 100, .T. , .T. , .F. } )
aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T., .F.) 

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro += " - Gerar Nota Fiscal") From 0,0 to aSize[6]*0.40, aSize[5]*0.90 PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |

// FWMsgRun(, {|| U_LoadDadosMJ( "ZA6", @aZA6Head, @aZA6Cols, StrToKarr(cLstCpo,","), aAlter, StrToKarr(cNotCpo,","), StrToKarr(cJoin, ","), StrToKarr(cWhere,",") ) }, 'Pesquisando, Por favor aguarde', 'Consultando o Banco de dados ...')
aCols           := fLoadGrid( aHeader ) // aCriaCols[1]
aColsR          := _aCols1[2] // aColsR := aCriaCols[2]

oZA6GDad := MsNewGetDados():New( 0, 0, 0, 0, GD_UPDATE, /* "U_VA6LinOK" */, , ,;
							{"ZA5_OBS   ", "ZA5_TRANSP", "ZA5_PLACA1", "ZA5_PLACA2", "__QTDFAT"/* , "__QTFATNF" */}, , , , , ,;
							oDlg, aClone(aHeader), aClone(aCols) )
	// MsNewGetDados():New( 0, 0, 0, 0, GD_UPDATE, , , /* "+ZA6_ITEM" */, , , , , , /* "u_ZA6DelOk()" */, oDlg, aClone(aZA6Head), aClone( aZA6Cols ) )
oZA6GDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oZA6GDad:oBrowse:BlDblClick := { || If( oZA6GDad:oBrowse:nColPos == 1 .and. fCanSel(),;
										SetMark(oZA6GDad, , 01),;
										oZA6GDad:EditCell() );
							   }
// Gerar a NF ao clicar em confirmar
// AAdd( aButtons, { "AUTOM", { || fGerPedNf() }, "Gerar Pedido (F8)"   } )
// SetKey( VK_F8, {|| fGerPedNf() } )

ACTIVATE MSDIALOG oDlg ;
          ON INIT EnchoiceBar(oDlg,;
				  { || nOpcA := 1, Iif( /* VldOk(nOpc) .and. */ Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)},;
				  { || nOpcA := 0, oDlg:End() },, /* aButtons */ )

If nOpcA == 1
	
	Begin Transaction     
		FWMsgRun(, {|| lErro := ExecSC5Auto( oZA6GDad/* oZA6GDad:aHeader, oZA6GDad:aCols */ ) },;
						'Por Favor Aguarde...',;
						'Gerando Pedido de Vendas e Nota Fiscal')
		If lErro
			DisarmTransaction()
		EndIf
	End Transaction
	// Rotina Padrao, salvar Grid
	// 	  A610GravaCol(oGetDados:aCols, aHeader, aColsR, "ZA6",{|| .T. } )
EndIf

RestArea(aArea)
Return nil

Static Function ExecSC5Auto( __NewGDados /* aHeader, aCols */ )
	Local aArea            := GetArea()
	Local aAreaZA6         := ZA6->(GetArea())
	Local aErroAuto        := {}
	Local aCabPV           := {}
	Local aItemPV          := {}
	Local nI               := 0
	Local lErro            := .F.
	Local nCount           := 0
	Local aHeader          := __NewGDados:aHeader
	Local aCols            := __NewGDados:aCols

	// Local _ZA5FILIAL       := aScan( aHeader, { |x| x[2] == "ZA5_FILIAL" } )
	Local _ZA5CODIGO       := aScan( aHeader, { |x| x[2] == "ZA5_CODIGO" } )
	// Local _ZA5NOME         := aScan( aHeader, { |x| x[2] == "ZA5_NOME  " } )
	// Local _ZA5DESCPG       := aScan( aHeader, { |x| x[2] == "ZA5_DESCPG" } )
	// Local _ZA5MSGNF        := aScan( aHeader, { |x| x[2] == "ZA5_MSGNF " } )
	// Local _ZA5DTCONT       := aScan( aHeader, { |x| x[2] == "ZA5_DTCONT" } )
	// Local _ZA5USER         := aScan( aHeader, { |x| x[2] == "ZA5_USER  " } )
	// Local _ZA5OBS          := aScan( aHeader, { |x| x[2] == "ZA5_OBS   " } )
	// Local _ZA5TPFRE        := aScan( aHeader, { |x| x[2] == "ZA5_TPFRE " } )
	// Local _ZA5ARROB        := aScan( aHeader, { |x| x[2] == "ZA5_ARROB " } )
	
	Local _ZA5CLIENT    := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA5_CLIENT" } )
	Local _ZA5LOJA      := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA5_LOJA"   } )
	Local _ZA5CPAG      := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA5_CPAG"   } )
	
	Local _ZA5TRANSP    := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA5_TRANSP"  } )
	// Local _ZA5VEICUL    := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA5_VEICUL" } )
	Local _ZA5PLACA1    := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA5_PLACA1"  } )
	Local _ZA5PLACA2    := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA5_PLACA2"  } )
	
	// Local _ZA6FILIAL       := aScan( aHeader, { |x| x[2] == "ZA6_FILIAL" } )
	// Local _ZA6CODIGO       := aScan( aHeader, { |x| x[2] == "ZA6_CODIGO" } )
	// Local _ZA6DESC         := aScan( aHeader, { |x| x[2] == "ZA6_DESC  " } )
	Local _ZA6ITEM      := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA6_ITEM"  } )
	Local _ZA6PROD      := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA6_PROD"  } )
	// Local _ZA6QUANT     := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA6_QUANT" } )
	// Local __QTFATNF         := aScan( aHeader, { |x| AllTrim(x[2]) == "__QTFATNF" } )
	Local __QTDFAT         := aScan( aHeader, { |x| AllTrim(x[2]) == "__QTDFAT" } )
	Local _ZA6PRECO        := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA6_PRECO" } )
	Local _ZA6TES          := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA6_TES" } )
	Local _ZA6DTDE         := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA6_DTDE" } )
	Local _ZA6DTATE        := aScan( aHeader, { |x| AllTrim(x[2]) == "ZA6_DTATE" } )
	Local nTotal           := 0
	Local cE1HIST          := ""
	Local _cNatureza       := ""
	
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .F.

	SA1->( DbSetOrder(1) )
	// If SA1->( DbSeek( xFilial("SA1") + oMGZA5:GetValue("ZA5_CLIENT") + oMGZA5:GetValue("ZA5_LOJA")) )
	If SA1->( DbSeek( xFilial("SA1") + aCols[ 01, _ZA5CLIENT] + aCols[ 01, _ZA5LOJA] ) )
		
		cNumPed := U_fChvITEM( "SC5", , "C5_NUM" )	//cNumPed := GetSxeNum("SC5", "C5_NUM")

		For nI := 1 To Len( aCols )
			If lValue := (aCols[nI, 01] == 'LBTIK')

				If dDataBase < aCols[nI, _ZA6DTDE ] .OR. dDataBase > aCols[nI, _ZA6DTATE ]
					MsgAlert("O produto: " + AllTrim(aCols[nI, _ZA6PROD ]) + " na linha " + cValToChar(nI) + " nao pode ser faturado porque esta fora do periodo permitido.", "Atenção")
					Return .F.
					// Exit
				EndIf

				If aCols[nI, __QTDFAT ] <= 0
					MsgAlert("Quantidade nao informada. Esta operacao sera cancelada", "Atenção")
					Return .F.
				EndIf
				
				AADD(aItemPV, { {"C6_FILIAL" , xFilial("ZA6")          		         , Nil},;
								{"C6_NUM"    , cNumPed                    	         , Nil},;
								{"C6_ITEM"   , aCols[nI, _ZA6ITEM ] /* ZA6_ITEM   */ , Nil},;
								{"C6_PRODUTO", aCols[nI, _ZA6PROD ] /* ZA6_PRODUT */ , Nil},; 
								{"C6_DESCRI" , POSICIONE("SB1", 1, xFilial("SB1")+aCols[nI, _ZA6PROD ], "B1_DESC"), Nil},;
								{"C6_LOCAL  ", SB1->B1_LOCPAD                        , Nil},;
								{"C6_QTDVEN" , aCols[nI, __QTDFAT] /* ZA6_QUANT   */ , Nil},; // {"C6_QTDLIB" , aCols[nI, __QTDFAT] /* ZA6_QUANT   */ , Nil},; 
								{"C6_PRCVEN" , aCols[nI, _ZA6PRECO] /* ZA6_VLRPTA */ , Nil},;
								{"C6_VALOR"  , aCols[nI, __QTDFAT]*aCols[nI, _ZA6PRECO] /* ZA6_VALOR  */ , Nil},;
								{"C6_TES"    , aCols[nI, _ZA6TES ] /* ZA6_TES	  */ , Nil},;
								{"C6_NUMZA5" , aCols[nI, _ZA5CODIGO ] + aCols[nI, _ZA6ITEM ] /* ZA6_TES	  */ , Nil}})
				nTotal += (aCols[nI, __QTDFAT]*aCols[nI, _ZA6PRECO])
			EndIf
		Next nI

		If AllTrim(SA1->A1_PESSOA) == 'J'
			_cNatureza := SB1->B1_XNATURE // B1_XNATURE	C	10	0	Natureza PJ 
		ElseIf AllTrim(SA1->A1_PESSOA) == 'F'
			_cNatureza := SB1->B1_XNATUR1 // B1_XNATUR1	C	10	0	Natureza PF 
		EndIf

		aCabPV  := {{ "C5_FILIAL", xFilial("SC5")	      , Nil },; 
					{ "C5_NUM"    , cNumPed     		  , Nil },;
					{ "C5_TIPO"   , "N"         		  , Nil },;
					{ "C5_CLIENTE", SA1->A1_COD 		  , Nil },;
					{ "C5_LOJACLI", SA1->A1_LOJA		  , Nil },;
					{ "C5_NATUREZ", _cNatureza            , Nil },;
					{ "C5_XTES"   , acols[ 01, _ZA6TES ]  , nil },;
					{ "C5_XTOTAL" , nTotal                , Nil },;
					{ "C5_CONDPAG", aCols[ 01, _ZA5CPAG]  , Nil },;
					{ "C5_TRANSP" , aCols[ 01, _ZA5TRANSP], Nil },;// { "C5_VEICULO", aCols[ 01, _ZA5VEICUL], Nil },;
					{ "C5_PLACA1" , aCols[ 01, _ZA5PLACA1], Nil },;
					{ "C5_PLACA2" , aCols[ 01, _ZA5PLACA2], Nil } }
	
		lMsErroAuto := .F.
		// https://tdn.totvs.com/pages/releaseview.action?pageId=6784012
		
		while !LockByName("ExecSC5Auto"+cNumPed, .t., .f.)
			Sleep(500)
		end
			MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItemPV,3)
		UnlockByName("ExecSC5Auto"+cNumPed)
	
		If lMSErroAuto
			// aErro := oModel:GetErrorMessage()
			// AutoGrLog( "Id do formulário de origem: " + ' [' + AllToChar( aErro[1] ) + ']' )
			// AutoGrLog( "Id do campo de origem: "	  + ' [' + AllToChar( aErro[2] ) + ']' )
			// AutoGrLog( "Id do formulário de erro: "   + ' [' + AllToChar( aErro[3] ) + ']' )
			// AutoGrLog( "Id do campo de erro: "	      + ' [' + AllToChar( aErro[4] ) + ']' )
			// AutoGrLog( "Id do erro: "	     		  + ' [' + AllToChar( aErro[5] ) + ']' )
			// AutoGrLog( "Mensagem do erro: "    		  + ' [' + AllToChar( aErro[6] ) + ']' )
			// AutoGrLog( "Mensagem da solução: " 		  + ' [' + AllToChar( aErro[7] ) + ']' )
			// AutoGrLog( "Valor atribuído: "     		  + ' [' + AllToChar( aErro[8] ) + ']' )
			// AutoGrLog( "Valor anterior: "	   		  + ' [' + AllToChar( aErro[9] ) + ']' )

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

			If lErro := LIBeFaturar( cFilEnt,  @cPedVen, @cE1HIST )
				DisarmTransaction()
			Else
				MsgInfo( "Pedido de Venda [" + cNumPed + "] gerado com sucesso !!!" + CRLF +;
						 "Nota Fiscal [" + SF2->F2_FILIAL+"-"+AllTrim(SF2->F2_DOC)+"-"+AllTrim(SF2->F2_SERIE) + "] faturada com sucesso" )

				For nI := 1 to Len(aCols)
					// ConOut("Atualizar num pedido no ZA6")
					SC6->(DbSetOrder(1))
					If SC6->(DbSeek( xFilial("SC6") + cNumPed + aCols[nI, _ZA6ITEM] ))
						If Empty(SC6->C6_NUMZA5)
							RecLock("SC6", .F.)
								SC6->C6_NUMZA5 := aCols[nI, _ZA5CODIGO] + aCols[nI, _ZA6ITEM]
							SC6->(MsUnLock())
						EndIf
					EndIf
				Next nI
			EndIf
			// While __lSX8
			 	// ConfirmSX8()    
			// EndDo
		EndIf
	EndIf
RestArea(aAreaZA6)
RestArea(aArea)
Return lMSErroAuto

Static Function LIBeFaturar( cFilEnt, cPedVen, cE1HIST )
	Local lErro	:= .F.	
	//Backup da Filial
	Local nRecSM0  	:= SM0->(RecNo())
	Local cCurFil  	:= SM0->M0_CODFIL 
	Local lFatAuto := GetMV("VA_FATAUTO",, .T. ) // Define o faturamento automatico, executado pela função de leitura webservice das liberacoes do pedido enviada pelo Site.
	
	u_fMudaFilial( cFilEnt )	

	cE1HIST += Iif(!Empty(cE1HIST), "," , "") + SubStr(cFilEnt,5) +'-'+ cPedVen //+ ' / ' + xLibPedVen[nPosPedImp][2] 

	IF cPedVen <> SC5->C5_NUM
		SC5->(DbSetOrder(1))
		SC5->(DBSeek( cFilEnt + cPedVen ))
	EndIf

	If !Empty(SC5->C5_NOTA)		// Pedido já faturado, retorna .T. p/ continuar o processo
		Alert('[VAFATI01] Pedido: '+ SC5->C5_NUM + ' ja esta faturado na nota: ' + SC5->C5_FILIAL + '/' + SC5->C5_NOTA + '/' + SC5->C5_SERIE )
		Return .F.
	EndIf

	// Validar Risco do Cliente
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek( xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI )) .and. SA1->A1_RISCO <> 'A'
		RecLock('SA1' , .F. )
			SA1->A1_RISCO := 'A'
		SA1->( MsUnLock() )
	EndIf
	
	lErro := !U_EstLibPV( cPedVen /* SC5->C5_NUM */ ) // lIBERACAO DE ESTOQUE
	If !lErro
		u_cFatA00D( cPedVen ) // Liberacao Financeira
		
		// MJ 08.07
		SC9->( DbSetOrder(1) ) // Atualizacao da liberacao financeira
		If SC9->( DbSeek( cFilEnt + cPedVen ) ) 
			If lFatAuto 
				lErro := !u_cFatA00A( cPedVen ) // Faturamento Automatico - Inverte a logica pois a funcao retorna se a operacao foi bem sucedida
			EndIf 
		EndIf 
	EndIf
	
	// Voltar filial anterior
	SM0->(DbGoTo(nRecSM0))
	cFilAnt := cCurFil
	
Return lErro

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 26.07.2022                                                           |
 | Cliente  : Tucano                                                               |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
 Static Function fLoadGrid( aHeader )
	// Local oModelDad := FWModelActive()
	// Local oMGZA5    := oModelDad:GetModel( 'ZA5MASTER' )
	Local aArea    := GetArea()
	Local _cQry    := ""
	Local nJ       := ""
	Local nUsadDet := Len( aHeader )
	Local aColsDet := {}
	// Local nLinha := 0

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))

	DbSelectArea("SE4")
	SE4->(DbSetOrder(1))

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, ;
						_cQry := ;
							" SELECT	* " + CRLF +;
							" FROM	    " + RetSqlName('ZA5') + " ZA5 " + CRLF +;
							" LEFT JOIN " + RetSqlName('ZA6') + " ZA6 ON ZA5_FILIAL=ZA6_FILIAL AND ZA5_CODIGO=ZA6_CODIGO " + CRLF +;
							" 			          AND ZA6.D_E_L_E_T_ = ' ' " + CRLF +;
							" WHERE ZA5_FILIAL = '" + ZA5->ZA5_FILIAL /* oMGZA5:GetValue('ZA5_CODIGO') */ + "' " + CRLF +;
							" 	AND ZA5_CODIGO = '" + ZA5->ZA5_CODIGO /* oMGZA5:GetValue('ZA5_CODIGO') */ + "' " + CRLF +;
							"   AND ZA5.D_E_L_E_T_ = ' ' ";
					), "_TMP", .F., .F.) 
	while !_TMP->(Eof())
		aAdd(aColsDet, Array(nUsadDet+1))
		aColsDet[len(aColsDet),  1] := "LBTIK" // "LBNO"
		aColsDet[len(aColsDet), nUsadDet+1] := .F.
		for nJ := 1 to len(aHeader)
			If aHeader[nJ,  8] == 'M'
				loop
			EndIf

			If aHeader[nJ, 10] == 'V'
				ConOut("Carregando campos virtuais;")
				If aHeader[nJ, 2] == "ZA5_NOME  " // Nome do Cliente
					aColsDet[len(aColsDet), nJ] := Posicione("SA1", 1, xFilial("SA1")+aColsDet[len(aColsDet), nJ-2]+aColsDet[len(aColsDet), nJ-1], "A1_NOME")
				ElseIf aHeader[nJ, 2] == "ZA5_DESCPG"
					aColsDet[len(aColsDet), nJ] := POSICIONE("SE4", 1, xFilial("SE4")+aColsDet[len(aColsDet), nJ-1], "E4_DESCRI")
				ElseIf aHeader[nJ, 2] == "ZA6_DESC  "
					aColsDet[len(aColsDet), nJ] := POSICIONE("SB1", 1, xFilial("SB1")+aColsDet[len(aColsDet), nJ-1], "B1_DESC")
				EndIf
			Else
				If aHeader[nJ,  8] == 'D'
					aColsDet[len(aColsDet), nJ] := STOD( &("_TMP->" + aHeader[nJ, 2]) )
				else
					// If At("_CODIGO", aHeader[nJ, 2]) > 0
					// 	aColsDet[len(aColsDet), nJ] := _TMP->ZA5_CODIGO
					// Else
					If     AllTrim(aHeader[nJ, 2]) $ ("ZA5_TRANSP")
						aColsDet[len(aColsDet), nJ] := Space( TAMSX3("C5_TRANSP")[1])
					ElseIf AllTrim(aHeader[nJ, 2]) $ ("ZA5_PLACA1")
						aColsDet[len(aColsDet), nJ] := Space( TAMSX3("C5_PLACA1")[1])
					ElseIf AllTrim(aHeader[nJ, 2]) $ ("ZA5_PLACA2")
						aColsDet[len(aColsDet), nJ] := Space( TAMSX3("C5_PLACA2")[1])
					ElseIf AllTrim(aHeader[nJ, 2]) $ ("__QTFATNF")
						aColsDet[len(aColsDet), nJ] := fPegaQtdFat( _TMP->ZA6_FILIAL, _TMP->ZA6_CODIGO, _TMP->ZA6_ITEM )
					ElseIf AllTrim(aHeader[nJ, 2]) $ ("__QTDFAT")
						aColsDet[len(aColsDet), nJ] := aColsDet[len(aColsDet), nJ-2] - aColsDet[len(aColsDet), nJ-1] // 0 // (++nLinha)*10// 0
					Else
						aColsDet[len(aColsDet), nJ] := &("_TMP->" + aHeader[nJ, 2])
					EndIf
				EndIf
			EndIf
		Next nJ

		_TMP->(DbSkip())
	EndDo
	_TMP->(DbCloseArea())
	
	RestArea(aArea)
Return aClone(aColsDet) // aCols

Static Function fPegaQtdFat( __cFilial, __cCodigo, __cItem )
	Local nRet      := 0
	Local _cQry     := ""
	Default __cItem := ""

	_cQry := " WITH " + CRLF +;
				" CONTRATO AS ( " + CRLF +;
				" 	SELECT	  ZA5_FILIAL, ZA5_CODIGO, ZA6_ITEM, SUM(ZA6_QUANT) QTD_ZA6_QUANT " + CRLF +;
				" 	FROM      " + RetSqlName('ZA5') + " ZA5 " + CRLF +;
				" 		 JOIN " + RetSqlName('ZA6') + " ZA6 ON ZA5_FILIAL=ZA6_FILIAL AND ZA5_CODIGO=ZA6_CODIGO AND ZA5.D_E_L_E_T_=' ' " + CRLF +;
				" 	GROUP BY  ZA5_FILIAL, ZA5_CODIGO, ZA6_ITEM " + CRLF +;
				" ) " + CRLF +;
				"  " + CRLF +;
				" , PEDIDO_VENDA AS ( " + CRLF +;
				" 	SELECT    C6_FILIAL, C6_NUM, C6_ITEM, C6_NUMZA5, C6_QTDVEN " + CRLF +;
				" 	FROM      " + RetSqlName('SC6') + " " + CRLF +;
				" 	WHERE	  C6_NUMZA5 <> ' ' " + CRLF +;
				" 	      AND D_E_L_E_T_=' ' " + CRLF +;
				" ) " + CRLF +;
				"  " + CRLF +;
				" SELECT	ZA5_FILIAL, ZA5_CODIGO, -- C6_NUM,  " + CRLF +;
				" 		QTD_ZA6_QUANT, " + CRLF +;
				" 		SUM(C6_QTDVEN) QTD_C6_QTDVEN " + CRLF +;
				" FROM	CONTRATO C " + CRLF +;
				" JOIN    PEDIDO_VENDA ON ZA5_FILIAL=C6_FILIAL " + CRLF +;
				" 					AND ZA5_CODIGO+ZA6_ITEM=C6_NUMZA5 " + CRLF +;
				" WHERE ZA5_FILIAL = '" + __cFilial + "'" + CRLF +;
				" 	AND ZA5_CODIGO = '" + __cCodigo + "'" + CRLF
				
	If !Empty( __cItem )
		_cQry += " 	AND ZA6_ITEM = '" + __cItem + "'" + CRLF
	EndIf

	_cQry += " GROUP BY ZA5_FILIAL, ZA5_CODIGO, -- C6_NUM,  " + CRLF +;
			 " 		    QTD_ZA6_QUANT "

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ), "_TMPQTFAT", .F., .F.) 
	If !_TMPQTFAT->(Eof())
		nRet := _TMPQTFAT->QTD_C6_QTDVEN
	EndIf
	_TMPQTFAT->(DbCloseArea())

Return nRet


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 26.07.2022                                                           |
 | Cliente  : Tucano                                                               |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
Static function MbMergeArray( _aHead1, _aHead2, aHeader, _aCols1, _aCols2, aCriaCols, cCpoJump )
	Local nI             := 0
	Local lJump			 := .F.

	// _Mark MVC -- Padrão Harpia
	AAdd( aHeader, { " ", Padr("__MARK", 10), "@BMP", 1, 0, "", "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ", "C", "", "V" } )	
	aAdd( aCriaCols, {} )
	aAdd( aCriaCols[Len(aCriaCols)], {} )
	aAdd( aCriaCols[Len(aCriaCols[Len(aCriaCols)]), Len(aCriaCols)], "LBNO" )
	
	For nI := 1 to Len(_aHead1)
		If lJump := ( At( _aHead1[nI, 02], cCpoJump) > 0 )
			Loop
		EndIf
		aAdd( aHeader, _aHead1[nI] )
		aAdd( aCriaCols[Len(aCriaCols[Len(aCriaCols)]), Len(aCriaCols)], _aCols1[1,1, nI] )
	Next nI

	For nI := 1 to Len(_aHead2)
		If lJump := ( At( _aHead2[nI, 02], cCpoJump) > 0 )
			Loop
		EndIf

		aAdd( aHeader, _aHead2[nI] )
		aAdd( aCriaCols[Len(aCriaCols[Len(aCriaCols)]), Len(aCriaCols)], _aCols2[1,1, nI] )

		If AllTrim(_aHead2[nI, 02]) == 'ZA6_QUANT'
			aAdd( aHeader, aClone(_aHead2[nI]) )
			aAdd( aCriaCols[Len(aCriaCols[Len(aCriaCols)]), Len(aCriaCols)], aClone(_aCols2[1,1, nI]) )
			aHeader[ len(aHeader), 01] := 'Já FATNF'
			aHeader[ len(aHeader), 02] := '__QTFATNF'

			aAdd( aHeader, aClone(_aHead2[nI]) )
			aAdd( aCriaCols[Len(aCriaCols[Len(aCriaCols)]), Len(aCriaCols)], aClone(_aCols2[1,1, nI]) )
			aHeader[ len(aHeader), 01] := 'Qt. à Faturar'
			aHeader[ len(aHeader), 02] := '__QTDFAT'
		EndIf
	Next nI
	aAdd( aCriaCols[Len(aCriaCols[Len(aCriaCols)]), Len(aCriaCols)], .F. )
	aAdd( aCriaCols[Len(aCriaCols)], {} )
Return

User Function fMudaFilial(cFilialX)

	If AllTrim(SM0->M0_CODFIL) <> AllTrim(cFilialX)
		ConOut('Mudando Filial para: ' + cFilialX )
		cFilAnt :=  cFilialX
		SM0->( dbSetOrder(1) )
		SM0->( dbSeek(cEmpAnt + cFilialX ) )
	EndIf

Return nil

/* 
	Static Function GeraHeader(cAliasHead, lOnlyView)
		local aHead := {}
		default lOnlyView := .F.

		DbSelectArea("SX3")
		DbSetOrder(1)
		dbSeek(cAliasHead)

		while !SX3->(Eof()) .and. SX3->X3_ARQUIVO == cAliasHead

			If X3Uso(SX3->X3_USADO); 				// O Campo é µsado.
				.and. cNivel >= SX3->X3_NIVEL      // Nivel do Usuario >= Nivel do Campo.

				AAdd(aHead, {Trim(SX3->X3_Titulo),;
					SX3->X3_Campo       ,;
					SX3->X3_Picture     ,;
					SX3->X3_Tamanho     ,;
					SX3->X3_Decimal     ,;
					SX3->X3_Valid       ,;
					SX3->X3_Usado       ,;
					SX3->X3_Tipo        ,;
					SX3->X3_F3     		,;
					iIf( lOnlyView, "V", SX3->X3_Visual) ,;
					iIf( "staticcall"$lower(SX3->X3_CBOX), &(StrTran(SX3->X3_CBOX,'#','')), SX3->X3_CBOX )		 })

			EndIf

			SX3->(DbSkip())
		EndDo

	Return aHead */



Static Function fCanSel()
Local lRet := .T.
	/* 
		Validar campos que dever ser informados;
	*/

	// If !( lRet := !Empty( &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ o1ZBCGDad:oBrowse:nAt, nPZBCQtd ] ) )
	// 	Alert('Quantidade não informada, por isso o item nao poderá ser selecionado.')
	// EndIf
	
return lRet

Static Function SetMark(oGD, nLinha, nColuna)
	Local lMark                := .T.
	Default nLinha             := oGD:nAt
	
	lMark                      := oGD:aCols[nLinha, nColuna] == 'LBNO'
	oGD:aCols[nLinha, nColuna] := Iif(lMark, 'LBTIK' , 'LBNO' )
	oGD:Refresh()
Return .T.

// User Function initCLoad( cCampo, cTipo )
// Local aArea := GetArea()
// Local nRet  := Space( TamSx3(cCampo)[1] )
// 
// 	If cCampo == "ZA5_NOME"
// 		nRet := POSICIONE("SA1", 1, XFILIAL("SA1")+ZA5->ZA5_CLIENT+ZA5->ZA5_LOJA, "A1_NOME")
// 	ElseIf cCampo == "ZA5_DESCPG"
// 		nRet := POSICIONE("SE4",1, XFILIAL("SE4")+ZA5->ZA5_CPAG,"E4_DESCRI")
// 	ElseIf cCampo == "ZA6_DESC"
// 		// If !IsInCallStack("U_FGRIDFATB01")
// 			nRet := POSICIONE("SB1",1,XFILIAL("SB1")+GdFieldGet("ZA6_PROD"), "B1_DESC")
// 		// EndIf
// 	ElseIf cCampo == "ZA6_DTES"
// 		// If !IsInCallStack("U_FGRIDFATB01")
// 			nRet := POSICIONE("SF4",1,XFILIAL("SF4")+GdFieldGet("ZA6_TES"), "F4_TEXTO")
// 		// EndIf
// 	EndIf
// RestArea(aArea)
// Return nRet

/* MB : 09.09.2022
	-> Processamento Quantidade */
User Function initNLoad( cCampo, cTipo )
Local aArea := GetArea()
Local nRet  := 0
// Default cCampo := Substr( ReadVar(), At( '->' , ReadVar())+2 )

// If cTipo == "B"
// 	ConOut( "Tipo B")
// ElseIf cTipo == "R"
// 	ConOut( "Tipo R")
// EndIf
	If  cCampo == "ZA5_QUANT"
		BeginSQL alias "QRYTMP"
			%noParser%
			SELECT  SUM(ZA6_QUANT) ZA6_QUANT
			FROM    %table:ZA6% ZA6
			WHERE	ZA6_FILIAL = %exp:ZA5->ZA5_FILIAL%
				AND ZA6_CODIGO = %exp:ZA5->ZA5_CODIGO%
				AND ZA6.%notDel%
		EndSQL
		If !QRYTMP->(Eof())
			xQuant := nRet := QRYTMP->ZA6_QUANT
		EndIf
		QRYTMP->(DbCloseArea())
	ElseIf cCampo == "ZA5_QTDFAT"
		xQtFat := nRet := fPegaQtdFat( ZA5->ZA5_FILIAL, ZA5->ZA5_CODIGO )
	ElseIf cCampo == "ZA5_SLDFAT"
		nRet := xQuant - xQtFat
	EndIf
RestArea(aArea)
Return nRet

User Function FB01INC()
	Local cRet := ""
	
	cQry := "SELECT MAX(ZA5_CODIGO) FROM "+RetSqlName("ZA5")+" "

	MpSysOpenQuery(cQry,"TMP")

	IF !TMP->(EOF())
		cRet := StrZero(VAL(TMP->ZA5_CODIGO) + 1,TamSx3("ZA5_CODIGO")[1])
	ENDIF

	TMP->(DBCLOSEAREA( ))
Return cRet
