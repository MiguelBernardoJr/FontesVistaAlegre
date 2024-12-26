//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Tabelas Desconto de Milho"

User Function VACOMM13()
	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp := FunName()
	
	SetFunName("VACOMM13")
	
	//Cria um browse para a ZDM, filtrando somente a tabela 00 (cabeçalho das tabelas
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZDM")
	oBrowse:SetDescription(cTitulo)
	// oBrowse:SetFilterDefault("ZDM->ZDM_CODIGO == '00'")
	oBrowse:Activate()
	
	SetFunName(cFunBkp)
	RestArea(aArea)
Return Nil
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  14/01/2017                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRot := {}
	
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.VACOMM13' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.VACOMM13' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.VACOMM13' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.VACOMM13' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  14/01/2017                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
	Local oModel   := Nil
	Local oStPai   := FWFormStruct(1, 'ZDM') // FWFormModelStruct():New()
	Local oStFilho := FWFormStruct(1, 'ZDM')
	Local bVldPos  := {|| u_zVldZDMTab()}
	Local bVldCom  := {|| u_zSaveZDMMd2()  }
	Local aZDMRel  := {}
/*
	//Adiciona a tabela na estrutura temporária
	oStPai:AddTable('ZDM', {'ZDM_FILIAL', 'ZDM_CODIGO', 'ZDM_DATA', 'ZDM_DESCRIC'}, "Cabecalho Tabela Desconto")
	
	//Adiciona o campo de Filial
	oStPai:AddField(;
		"Filial",;                                                                                  // [01]  C   Titulo do campo
		"Filial",;                                                                                  // [02]  C   ToolTip do campo
		"ZDM_FILIAL",;                                                                               // [03]  C   Id do Field
		"C",;                                                                                       // [04]  C   Tipo do campo
		TamSX3("ZDM_FILIAL")[1],;                                                                    // [05]  N   Tamanho do campo
		0,;                                                                                         // [06]  N   Decimal do campo
		Nil,;                                                                                       // [07]  B   Code-block de validação do campo
		Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
		{},;                                                                                        // [09]  A   Lista de valores permitido do campo
		.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZDM->ZDM_FILIAL,FWxFilial('ZDM'))" ),;   // [11]  B   Code-block de inicializacao do campo
		.T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                                        // [14]  L   Indica se o campo é virtual
	
	oStPai:AddField(;
		"Código",;                                                                    // [01]  C   Titulo do campo
		"Código",;                                                                    // [02]  C   ToolTip do campo
		"ZDM_CODIGO",;                                                                  // [03]  C   Id do Field
		"C",;                                                                         // [04]  C   Tipo do campo
		TamSX3("ZDM_CODIGO")[1],;                                                      // [05]  N   Tamanho do campo
		0,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZDM->ZDM_CODIGO,'')" ),;    // [11]  B   Code-block de inicializacao do campo
		.T.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                          // [14]  L   Indica se o campo é virtual

	oStPai:AddField(;
		"Data",;                                                                    // [01]  C   Titulo do campo
		"Data",;                                                                    // [02]  C   ToolTip do campo
		"ZDM_DATA",;                                                                  // [03]  C   Id do Field
		"D",;                                                                         // [04]  C   Tipo do campo
		TamSX3("ZDM_DATA")[1],;                                                      // [05]  N   Tamanho do campo
		0,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZDM->ZDM_DATA,'')" ),;    // [11]  B   Code-block de inicializacao do campo
		.T.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                          // [14]  L   Indica se o campo é virtual
	
	//Adiciona o campo de Descrição
	oStPai:AddField(;
		"Descricao",;                                                                 // [01]  C   Titulo do campo
		"Descricao",;                                                                 // [02]  C   ToolTip do campo
		"ZDM_DESCRI",;                                                                 // [03]  C   Id do Field
		"C",;                                                                         // [04]  C   Tipo do campo
		TamSX3("ZDM_DESCRI")[1],;                                                      // [05]  N   Tamanho do campo
		0,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZDM->ZDM_DESCRI,'')" ),;   // [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                          // [14]  L   Indica se o campo é virtual
	
	//Setando as propriedades na grid, o inicializador da Filial e Tabela, para não dar mensagem de coluna vazia
	oStFilho:SetProperty('ZDM_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
	oStFilho:SetProperty('ZDM_CODIGO', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
*/
	//Criando o FormModel, adicionando o Cabeçalho e Grid
	oModel := MPFormModel():New("COMM13M",/*Pre-Validacao*/, bVldPos /*Pos-Validacao*/, bVldCom /*Commit*/,/*Cancel*/)

	oModel:AddFields("ZDMMASTER",/*cOwner*/ ,oStPai  )
	oModel:AddGrid  ('ZDMDETAIL','ZDMMASTER',oStFilho)
	
	//Adiciona o relacionamento de Filho, Pai
	aAdd(aZDMRel, {'ZDM_FILIAL', 'Iif(!INCLUI, ZDM->ZDM_FILIAL, FWxFilial("ZDM"))'} )
	aAdd(aZDMRel, {'ZDM_CODIGO', 'Iif(!INCLUI, ZDM->ZDM_CODIGO,  "")'             } ) 
	aAdd(aZDMRel, {'ZDM_DATA'  , 'Iif(!INCLUI, ZDM->ZDM_DATA  ,  sToD(""))'		  } ) 
	// aAdd(aZDMRel, {'ZDM_UMIDAD', 'Iif(!INCLUI, ZDM->ZDM_UMIDAD,  0)'			  } ) 
	
	//Criando o relacionamento
	oModel:SetRelation('ZDMDETAIL', aZDMRel, ZDM->(IndexKey(1)))
	
	// oModel:SetPrimaryKey({"ZDM_FILIAL","ZDM_CODIGO","ZDM_DATA"})
	oModel:SetPrimaryKey({})
	
	//Setando o campo único da grid para não ter repetição
	oModel:GetModel('ZDMDETAIL'):SetUniqueLine({ "ZDM_FILIAL","ZDM_CODIGO","ZDM_DATA","ZDM_UMIDAD" })
	
	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZDMMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  14/01/2017                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
	Local oModel     := FWLoadModel("VACOMM13")
	Local oStPai     := FWFormStruct(2, 'ZDM') // FWFormViewStruct():New()
	Local oStFilho   := FWFormStruct(2, 'ZDM')
	//Criando a view que será o retorno da função e setando o modelo da rotina
	Local oView      := FWFormView():New()
/*
	//Adicionando o campo Chave para ser exibido
	oStPai:AddField(;
		"ZDM_CODIGO",;                // [01]  C   Nome do Campo
		"01",;                      // [02]  C   Ordem
		"Codigo",;                  // [03]  C   Titulo do campo
		X3Descric('ZDM_CODIGO'),;    // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"C",;                       // [06]  C   Tipo do campo
		X3Picture("ZDM_CODIGO"),;    // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		"Iif(INCLUI,GetSX8Num('ZDM','ZDM_CODIGO'),ZDM->ZDM_CODIGO)",;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo
	
	oStPai:AddField(;
		"ZDM_DATA",;               // [01]  C   Nome do Campo
		"02",;                      // [02]  C   Ordem
		"Data",;              		 // [03]  C   Titulo do campo
		X3Descric('ZDM_DATA'),;    // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"D",;                       // [06]  C   Tipo do campo
		X3Picture("ZDM_DATA"),;    // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.T.,;                       // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		"Iif(INCLUI,dDataBase,ZDM->ZDM_DATA)",;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo
	
    oStPai:AddField(;
		"ZDM_DESCRI",;               // [01]  C   Nome do Campo
		"03",;                      // [02]  C   Ordem
		"Descricao",;               // [03]  C   Titulo do campo
		X3Descric('ZDM_DESCRI'),;    // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"C",;                       // [06]  C   Tipo do campo
		X3Picture("ZDM_DESCRI"),;    // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.T.,;                       // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		"Iif(INCLUI,Space(TamSX3('ZDM_DESCRI')[1]),ZDM->ZDM_DESCRI)",;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo
*/
	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB" , oStPai  , "ZDMMASTER")
	oView:AddGrid('VIEW_ITENS', oStFilho, 'ZDMDETAIL')
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 20)
	oView:CreateHorizontalBox('GRID' , 80)
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB'  ,'CABEC')
	oView:SetOwnerView('VIEW_ITENS','GRID' )
	
	//Habilitando título
	oView:EnableTitleView('VIEW_CAB','Cabeçalho - Desconto Milho')
	oView:EnableTitleView('VIEW_ITENS','Itens - Desconto Milho')
	
	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk( { |oView| .T. } )
	
	//Remove os campos de Filial e Tabela da Grid
	oStPai:RemoveField('ZDM_UMIDAD')
	oStPai:RemoveField('ZDM_DESCON')

	oStFilho:RemoveField('ZDM_FILIAL')
	oStFilho:RemoveField('ZDM_CODIGO')
	oStFilho:RemoveField('ZDM_DATA')
	oStFilho:RemoveField('ZDM_DESCRI')
	oStFilho:RemoveField('ZDM_MSBLQL')
Return oView


/*/{Protheus.doc} zVldZDMTab
Função chamada na validação do botão Confirmar, para verificar se já existe a tabela digitada
@type function
@author Atilio
@since 14/01/2017
@version 1.0
	@return lRet, .T. se pode prosseguir e .F. se deve barrar
/*/
User Function zVldZDMTab()
	Local aArea  := GetArea()
	Local oModel := FWModelActive()
	Local nOpc   := oModel:GetOperation()
	Local lRet   := .T.
	
	//Se for Inclusão
	If nOpc == MODEL_OPERATION_INSERT
		DbSelectArea('ZDM')
		ZDM->(DbSetOrder(1)) //ZDM_FILIAL + ZDM_CODIGO + ZDM_CODIGO
		
		//Se conseguir posicionar, tabela já existe
		If ZDM->(DbSeek( xFilial("ZDM") +;
						oModel:GetValue('ZDMMASTER', 'ZDM_CODIGO') +;
						dToS(oModel:GetValue('ZDMMASTER', 'ZDM_DATA'))))
			Aviso('Atenção', 'Esse código de tabela já existe!', {'OK'}, 02)
			lRet := .F.
		EndIf
	EndIf
	
	RestArea(aArea)
Return lRet
/*/{Protheus.doc} zSaveZDMMd2
Função desenvolvida para salvar os dados do Modelo 2
@type function
@author Atilio
@since 14/01/2017
@version 1.0
/*/
User Function zSaveZDMMd2()
	Local aArea      := GetArea()
	Local lRet       := .T.
	Local oModelDad  := FWModelActive()
	Local nOpc       := oModelDad:GetOperation()
	Local oModelGrid := oModelDad:GetModel('ZDMDETAIL')
	Local aHeadAux   := oModelGrid:aHeader
	Local nI         := 0, nJ := 0
	Local lRecLock   := .T.

	DbSelectArea('ZDM')
	ZDM->(DbSetOrder(1)) //ZDM_FILIAL + ZDM_CODIGO + ZDM_CODIGO
	
	//Se for Inclusão
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
		//Cria o registro na tabela 00 (Cabeçalho de tabelas)

		//Percorre as linhas da grid
		For nI := 1 To oModelGrid:GetQtdLine()
			
			oModelGrid:GoLine(nI)

			//Se a linha não estiver excluída, inclui o registro
			If !oModelGrid:isDeleted() 
				If oModelGrid:IsUpdated() .OR.; // esta linha nao pode ser junto com o teste acima
					oModelDad:GetValue('ZDMMASTER', 'ZDM_MSBLQL') <> oModelDad:GetValue('ZDMDETAIL', 'ZDM_MSBLQL') // Tabela marcada como DELETADA

					RecLock('ZDM', lRecLock := !DbSeek( xFilial("ZDM") +;
												oModelDad:GetValue('ZDMMASTER', 'ZDM_CODIGO') +;
												dToS(oModelDad:GetValue('ZDMMASTER', 'ZDM_DATA') ) +;
												cValToChar(oModelGrid:GetValue('ZDM_UMIDAD')) ) )
						
						For nJ := 1 to Len(aHeadAux)
							If aHeadAux[nJ, 2] $ ("ZDM_USERGI","ZDM_USERGA","ZDM_MSBLQL")
								loop
							EndIf
							&(aHeadAux[nJ, 2]) := oModelGrid:GetValue(aHeadAux[nJ, 2])
						Next nJ

						ZDM->ZDM_FILIAL := oModelDad:GetValue('ZDMMASTER', 'ZDM_FILIAL')
						ZDM->ZDM_CODIGO := oModelDad:GetValue('ZDMMASTER', 'ZDM_CODIGO')
						ZDM->ZDM_DATA   := oModelDad:GetValue('ZDMMASTER', 'ZDM_DATA')
						ZDM->ZDM_DESCRI := oModelDad:GetValue('ZDMMASTER', 'ZDM_DESCRI')
						ZDM->ZDM_MSBLQL := oModelDad:GetValue('ZDMMASTER', 'ZDM_MSBLQL')

					ZDM->(MsUnlock())

				EndIf
			Else

				If ZDM->(DbSeek( xFilial("ZDM") +;
								oModelDad:GetValue('ZDMMASTER', 'ZDM_CODIGO') +;
								dToS(oModelDad:GetValue('ZDMMASTER', 'ZDM_DATA') ) +;
								cValToChar(oModelGrid:GetValue('ZDM_UMIDAD')) ) )
					RecLock('ZDM', .F.)
						ZDM->(DbDelete())
					ZDM->(MsUnlock())
				EndIf

			EndIf
		Next nI

	//Se for Exclusão
	ElseIf nOpc == MODEL_OPERATION_DELETE

		BeginSQL alias "QTEMP"
			%noParser%
			SELECT ZBC_CODIGO
			FROM %table:ZBC%
			WHERE ZBC_FILIAL = %xFilial:ZBC%	
			  AND ZBC_PRODUT = %exp:GetMV("MB_COMM12B",,"020017")%
			  AND ZBC_TPNEGM = '1'
			  AND ZBC_TABDES = %exp:oModelDad:GetValue('ZDMMASTER', 'ZDM_CODIGO')%
			  AND %notDel%
		EndSQL
		if QTEMP->(Eof())
			//Percorre as linhas da grid
			For nI := 1 To oModelGrid:GetQtdLine()
				oModelGrid:GoLine(nI)
				//Se conseguir posicionar, exclui o registro
				If ZDM->(DbSeek( xFilial("ZDM") +;
									oModelDad:GetValue('ZDMMASTER', 'ZDM_CODIGO') +;
									dToS(oModelDad:GetValue('ZDMMASTER', 'ZDM_DATA')) +;
									cValToChar(oModelGrid:GetValue('ZDM_UMIDAD')) ) )
					RecLock('ZDM', .F.)
						ZDM->(DbDelete())
					ZDM->(MsUnlock())
				EndIf
			Next nI
		Else
			ShowHelpDlg("VACOMM1301",;
					 {"A tabela: " + oModelDad:GetValue('ZDMMASTER', 'ZDM_CODIGO') + ": " + AllTrim(oModelDad:GetValue('ZDMMASTER', 'ZDM_DESCRI')) +;
					 " não pode ser excluida por estar em uso no contrato: " + QTEMP->ZBC_CODIGO + "."}, 1,;
					 {"Esta operação sera cancelada !"}, 1)
		EndIf
		QTEMP->(dbCloseArea())
	EndIf
	
	//Se não for inclusão, volta o INCLUI para .T. (bug ao utilizar a Exclusão, antes da Inclusão)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf
	
	RestArea(aArea)
Return lRet

/*
User Function COMM13M()
Local aArea      := GetArea()
Local lRet       := .T.
Local lRecLock   := .T.
Local aParam     := PARAMIXB
Local oObj       := aParam[1]
Local cIdPonto   := aParam[2]
Local cIdModel   := oObj:GetId()
Local cClasse    := oObj:ClassName()
Local oZDMDados  := oObj:GetModel('ZDMDETAIL')

Local nLinha     := 0
Local nQtdLinhas := 0

If cClasse == 'FWFORMGRID'
	nQtdLinhas := oObj:GetQtdLine()
	nLinha     := oObj:nLine
EndIf

If cIdPonto ==  'MODELCOMMITTTS'		
 	If  oObj:NOPERATION == 3
		For nI := 1 To Len(oZDMDados:aCols)
			//Se a linha não estiver excluída, inclui o registro
			If !oZDMDados:aCols[nI, Len(oZDMDados:aCols[1]) ]
				RecLock('ZDM', lRecLock := !DbSeek( xFilial("ZDM") +;
											 oZDMDados:GetValue('ZDM_CODIGO') +;
											 oZDMDados:GetValue('ZDM_DATA') +;
											 oZDMDados:GetValue('ZDM_UMIDAD') ) )
					U_GrvCpo( "ZDM", oZDMDados:aCols, oZDMDados:aHeader, nI )
					ZDM->ZDM_FILIAL   := oZDMDados:GetValue('ZDM_FILIAL')
					ZDM->ZDM_CODIGO   := oZDMDados:GetValue('ZDM_CODIGO')
				ZDM->(MsUnlock())
			Else // If oZDMDados:aCols[nI, Len(oZDMDados:aCols[1]) ]
				If ZDM->(DbSeek( xFilial("ZDM") +;
								oZDMDados:GetValue('ZDM_CODIGO') +;
								oZDMDados:GetValue('ZDM_DATA') +;
								oZDMDados:GetValue('ZDM_UMIDAD') ) )
					RecLock('ZDM', .F.)
						ZDM->(DbDelete())
					ZDM->(MsUnlock())
				EndIf
			EndIf
		Next
	EndIf
EndIf

RestArea(aArea)
Return lRet
*/
