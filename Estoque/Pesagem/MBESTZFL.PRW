#INCLUDE 'TOTVS.CH'

//Vari�veis Est�ticas
Static cTitulo := "Cadastro Agendamento Caminhao APP"

/*--------------------------------------------------------------------------------,
 | Principal: 			            U_MBESTZFL()             		              |
 | Func..:    MBESTZFL()	            	          	            	          |
 | Autor.:    Miguel Martins Bernardo Junior	            	          	  	  |
 | Data..:    18.03.2022	            	          	            	          |
 | Desc..:    Cadastro ZFL = Tabela de integracao APP Portaria x Balancao.        |
 '--------------------------------------------------------------------------------|
 | Regra.:                                                                        |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Obs...:                                                                        |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
User Function MBESTZFL()
Local aArea     := GetArea()
Local oBrowse
Private aRotina := MenuDef()
	
	//Instanciando FWMBrowse - Somente com dicionario de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZFL")

	//Setando a descricao da rotina
	oBrowse:SetDescription(cTitulo)
	
	//Legendas
	oBrowse:AddLegend( "ZFL->ZFL_STATUS == '1'", "BR_AZUL"    , "No patio nao liberado pelo departamento" )
	oBrowse:AddLegend( "ZFL->ZFL_STATUS == '2'", "BR_AMARELO" , "Liberado pelo departamento aguardando liberacao da balan�a" )
	oBrowse:AddLegend( "ZFL->ZFL_STATUS == '3'", "BR_VERDE"   , "Liberado pela balan�a aguardando pesagem do motorista" )
	oBrowse:AddLegend( "ZFL->ZFL_STATUS == '4'", "BR_CINZA"   , "Em Entrega" )
	oBrowse:AddLegend( "ZFL->ZFL_STATUS == '5'", "BR_VERMELHO", "Finalizado" )
	
	// oBrowse:SetFilterDefault("ZFL->ZFL_AGENID == '" + SubS(ZWS->ZWS_RECEIV,1,TamSX3('ZFL_AGENID')[1]) + "'")
	oBrowse:SetFilterDefault("ZFL->ZFL_AGENID == '" + ZWS->ZWS_RECEIV + "'")

	//Ativa a Browse
	oBrowse:Activate()
	
	RestArea(aArea)
Return nil

/* ------------------------------------------------------------------------------------ */
User Function _fLegenda()
	Local aLegenda := {}
	//Monta as cores
	AADD(aLegenda, { "BR_AZUL"    , "No patio nao liberado pelo departamento"                    } )
	AADD(aLegenda, { "BR_AMARELO" , "Liberado pelo departamento aguardando liberacao da balan�a" } )
	AADD(aLegenda, { "BR_VERDE"   , "Liberado pela balan�a aguardando pesagem do motorista"      } )
	AADD(aLegenda, { "BR_CINZA"   , "Em Entrega"                                                 } )
	AADD(aLegenda, { "BR_VERMELHO", "Finalizado"                                                 } )
	BrwLegenda( cTitulo, "Status", aLegenda)
Return

/* ------------------------------------------------------------------------------------ */
Static Function MenuDef()
	// Local aRotina := {}
	// //Adicionando opcoes
	// // ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"          OPERATION  1 ACCESS 0 DISABLE MENU
	// ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.MBESTZFL' OPERATION  2 ACCESS 0
	// ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.MBESTZFL' OPERATION  3 ACCESS 0
	// ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.MBESTZFL' OPERATION  4 ACCESS 0
	// ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.MBESTZFL' OPERATION  5 ACCESS 0
	// ADD OPTION aRotina TITLE 'Legenda'    ACTION 'u__fLegenda'      OPERATION  6 ACCESS 0 //OPERATION X
	Local aRotina := { { 'Visualizar' , 'VIEWDEF.MBESTZFL' , 0 , 2 },; // { 'Incluir'    , 'VIEWDEF.MBESTZFL' , 0 , 3 },; // { 'Alterar'    , 'VIEWDEF.MBESTZFL' , 0 , 4 },; // { 'Excluir'    , 'VIEWDEF.MBESTZFL' , 0 , 5 },;
					   { 'Legenda'    , 'u__fLegenda'      , 0 , 6 } }
Return aRotina

Static Function ModelDef()
	//Cria��o do objeto do modelo de dados
	Local oModel := Nil
	
	//Bloco de C�digo do Commit do Modelo
	Local b_Commit    := {|oMdl| .T. /* C7Valid(oMdl) */}

	//Bloco de C�digo do Commit do Modelo
	Local b_Pos    := {|oMdl| .T./* C7Valid(oMdl) */}
	
	//Cria��o da estrutura de dados utilizada na interface
	Local oStZFL := FWFormStruct(1, "ZFL")
	
	//Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("ESTZFLMB",/*bPre*/, b_Pos, /*b_Commit*/ ,/*bCancel*/) 
	
	//Atribuindo formul�rios para o modelo
	oModel:AddFields("FORMZFL",/*cOwner*/,oStZFL)
	
	//Setando a chave prim�ria da rotina
	oModel:SetPrimaryKey( { 'ZFL_FILIAL','ZFL_AGENID' } )
                                                                                                                                        
	//Adicionando descri��o ao modelo
	oModel:SetDescription("Cadastro  "+cTitulo)
	
	//Setando a descri��o do formul�rio
	oModel:GetModel("FORMZFL"):SetDescription("Formul�rio do Cadastro " + cTitulo)
Return oModel

Static Function ViewDef()
	//Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("MBESTZFL")
	
	//Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStZFL := FWFormStruct(2, "ZFL")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
	
	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formul�rios para interface
	oView:AddField("VIEW_ZFL", oStZFL, "FORMZFL")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//Colocando t�tulo do formul�rio
	oView:EnableTitleView('VIEW_ZFL', 'Dados de Medicoes de Servicos/Produto' )  
	
	//For�a o fechamento da janela na confirma��o
	oView:SetCloseOnOk({||.T.})
	
	//O formul�rio da interface ser� colocado dentro do container
	oView:SetOwnerView("VIEW_ZFL","TELA")
Return oView
