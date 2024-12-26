#INCLUDE 'TOTVS.CH'

//Variáveis Estáticas
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
	oBrowse:AddLegend( "ZFL->ZFL_STATUS == '2'", "BR_AMARELO" , "Liberado pelo departamento aguardando liberacao da balança" )
	oBrowse:AddLegend( "ZFL->ZFL_STATUS == '3'", "BR_VERDE"   , "Liberado pela balança aguardando pesagem do motorista" )
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
	AADD(aLegenda, { "BR_AMARELO" , "Liberado pelo departamento aguardando liberacao da balança" } )
	AADD(aLegenda, { "BR_VERDE"   , "Liberado pela balança aguardando pesagem do motorista"      } )
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
	//Criação do objeto do modelo de dados
	Local oModel := Nil
	
	//Bloco de Código do Commit do Modelo
	Local b_Commit    := {|oMdl| .T. /* C7Valid(oMdl) */}

	//Bloco de Código do Commit do Modelo
	Local b_Pos    := {|oMdl| .T./* C7Valid(oMdl) */}
	
	//Criação da estrutura de dados utilizada na interface
	Local oStZFL := FWFormStruct(1, "ZFL")
	
	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("ESTZFLMB",/*bPre*/, b_Pos, /*b_Commit*/ ,/*bCancel*/) 
	
	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMZFL",/*cOwner*/,oStZFL)
	
	//Setando a chave primária da rotina
	oModel:SetPrimaryKey( { 'ZFL_FILIAL','ZFL_AGENID' } )
                                                                                                                                        
	//Adicionando descrição ao modelo
	oModel:SetDescription("Cadastro  "+cTitulo)
	
	//Setando a descrição do formulário
	oModel:GetModel("FORMZFL"):SetDescription("Formulário do Cadastro " + cTitulo)
Return oModel

Static Function ViewDef()
	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("MBESTZFL")
	
	//Criação da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStZFL := FWFormStruct(2, "ZFL")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
	
	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formulários para interface
	oView:AddField("VIEW_ZFL", oStZFL, "FORMZFL")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//Colocando título do formulário
	oView:EnableTitleView('VIEW_ZFL', 'Dados de Medicoes de Servicos/Produto' )  
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZFL","TELA")
Return oView
