#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"
#include "colors.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"  

#Define CLR_VERMELHO  RGB(255,048,048)	//Cor Vermelha
#Define CLR_VERDE     RGB(119,255,083)	//Cor Verde
#Define CLR_BRANCO    RGB(254,254,254)	//Cor Branco
#Define CLR_CINZA     RGB(180,180,180)	//Cor Cinza
#Define CLR_AZUL      RGB(135,206,250) // DeepSkyBlue - (058,074,119)	//Cor Azul

Static cTitulo := "Configuracao Contratual Esterco" 

<<<<<<< Updated upstream
/* Igor Oliveira  05/2022 - COntrato Venda de Adubo */
=======
/* Igor Oliveira  */
>>>>>>> Stashed changes
User Function VAFATI01()
    Local aArea   		:= GetArea()
	Local aAreaZVI		:= ZVI->(GetArea())
    Local oModel  		:= NIL
	Local cFunBkp 		:= FunName()  
<<<<<<< Updated upstream

	Private cPerg     	:= "VAFATI01"
	Private cArquivo    := "C:\TOTVS_RELATORIOS\"
=======
>>>>>>> Stashed changes
	Private cE1HIST 	:= ""
	Private _cPesoS 	:= CriaVar('ZPB_PESOL'  , .F.)
	Private _cChaveZPB 	:= CriaVar('ZVI_CHVZPB' , .F.)
	Private _cDesc 		:= CriaVar('ZVI_DESCT'  , .F.)/*  */
	
<<<<<<< Updated upstream
	GeraSX1(cPerg)

=======
>>>>>>> Stashed changes
    oModel := FWMBrowse():New()
	oModel:SetAlias( "ZVE" )   
	oModel:SetDescription( cTitulo )
	oModel:Activate()
	
    SetFunName(cFunBkp)
	RestArea(aAreaZVI)
	RestArea(aArea)
Return NIL

Static Function MenuDef()
	Local aRot := {}
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' 		ACTION 'VIEWDEF.VAFATI01' 			OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    		ACTION 'VIEWDEF.VAFATI01' 			OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    		ACTION 'VIEWDEF.VAFATI01' 			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    		ACTION 'VIEWDEF.VAFATI01' 			OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
<<<<<<< Updated upstream
	//ADD OPTION aRot TITLE 'Copiar'    		ACTION 'VIEWDEF.VAFATI01' 			OPERATION 9						 ACCESS 0 //OPERATION 5
=======
>>>>>>> Stashed changes
Return aRot

Static Function ModelDef()
	Local oModel        := NIL
    Local oStPai        := FWFormStruct(1, 'ZVE')
    Local oStFilho      := FWFormStruct(1, 'ZVI')
<<<<<<< Updated upstream
/* 	Local bVldPos  		:= {|| zVldModel(oModel) }
	Local bVldCom  		:= {|| zSaveZVEMd2()}  
	Local bVldZVI  		:= {|| zSaveZVI()}   */
	//Local bCOMP021	    := { |oModelGrid, nLine, cAction, cField| U_COMP021LPRE(oModelGrid, nLine, cAction, cField) }
    Local aRelFilho     := {}

    oModel := MPFormModel():New("FATI01",/*Pre-Validacao*/, /* {|| zVldModel(oModel) } */ /*Pos-Validacao*/,/* bVldComCommit*/,/*Cancel*/)
	
    //Criando o FormModel, adicionando o Cabeçalho e Grid
    oModel:AddFields('ZVEMASTER',/*cOwner*/ ,oStPai)

    //Criando as grids dos filhos
    oModel:AddGrid('ZVIFILHO','ZVEMASTER',oStFilho, { |oModelGrid, nLine,cAction, cField| VAFATI01LPRE(oModelGrid, nLine, cAction, cField) } ) // ,;
	//				bCOMP021 /*bPreValidacao*/,;
	//				{ |oModel| FZ0ELok(oModel)}/*bLinePost*/,;
	//				{ |oModel| fBPre(oModel)}/*bPre - Grid Inteiro*/,;
	//				{ |x| FZ0ETok(x)}/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é °ara quem pertence
   
	oStFilho:AddField('Gerar', ' ', 'Gerar', 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, ".F."))


    AAdd(aRelFilho,{'ZVI_FILIAL','ZVE_FILIAL'})
    AAdd(aRelFilho,{'ZVI_CODIGO','ZVE_CODIGO'})

=======
    Local aRelFilho     := {}
    Local aRelNeto      := {}

    oModel := MPFormModel():New("FATI01")///*Pre-Validacao*/, bVldPos /*Pos-Validacao*/, bVldCom /*Commit*/,/*Cancel*/)
	
    //Criando o FormModel, adicionando o Cabeçalho e Grid
    oModel:AddFields('ZVEMASTER',/*cOwner*/ ,oStPai, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)

    //Criando as grids dos filhos
    oModel:AddGrid('ZVIFILHO','ZVEMASTER',oStFilho)
   
	/* AddField ( cTitulo, cTooltip, cIdField, cTipo, nTamanho, nDecimal, bValid, bWhen, aValues, lObrigat, bInit, lKey, lNoUpd, lVirtual, cValid) 
 */
	oStFilho:AddField('Gerar', ' ', 'Gerar', 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, ".F."))

/* 	oStFilho:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4]) */

    AAdd(aRelFilho,{'ZVI_CODIGO','ZVE_CODIGO'})

    AAdd(aRelNeto ,{'ZDE_CODIGO','ZVI_CODIGO'})  
>>>>>>> Stashed changes

	oModel:SetRelation('ZVIFILHO',aRelFilho,ZVI->(IndexKey(3)))
    oModel:GetModel('ZVIFILHO'):SetUniqueLine({'ZVI_FILIAL','ZVI_CODIGO','ZVI_ITEM'})
    
	oModel:SetPrimaryKey({})
	
	//Setando outras informações do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:GetModel('ZVEMASTER'):SetDescription(cTitulo)
	oModel:GetModel('ZVIFILHO'):SetDescription("Itens do Contrato")
Return oModel

Static Function ViewDef()
    Local oView     := FWFormView():New()
    Local oModel    := FWLoadModel('VAFATI01')
    Local oStPai    := FWFormStruct(2,'ZVE')
    Local oStFilho  := FWFormStruct(2,'ZVI')
<<<<<<< Updated upstream
/* 	Local bKeyF10 	:= SetKey( VK_F10 )
	Local bKeyF11 	:= SetKey( VK_F11 )
	 */
/* 
	SetKey( VK_F10,bKeyF10 )
	SetKey( VK_F11,bKeyF11 ) */

=======

	
>>>>>>> Stashed changes
	oStFilho:AddField( 'Gerar','01','Gerar','Gerar',, 'Check')

	oView:SetModel(oModel)

    //ADICIONANDO OS CAMPOS DO CABEÇALHO
	oView:AddField("VIEW_CAB" , oStPai  , "ZVEMASTER")
    
    //GRID DOS FILHOS
    oView:AddGrid('VIEWFILHO', oStFilho , 'ZVIFILHO')
<<<<<<< Updated upstream
//	oView:SetViewProperty("VIEWFILHO", "CHANGELINE", {{ |oView| fTeste(oView) }} )
=======
>>>>>>> Stashed changes

    //Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 40)
	oView:CreateHorizontalBox('GRID' , 60)

    //Criando a folder dos itens(filhos)
 	oView:CreateFolder('PASTAFILHOS','GRID')
    oView:AddSheet('PASTAFILHOS','ABAFILHO1',"Itens")    
	oView:AddOtherObject("PANEL_SEL",{|oPanel,oOtherObject| criaButtonSel(oPanel,oOtherObject)})

    //Cria as caixas onde serão mostradas os dados dos filhos
    oView:CreateHorizontalBox('ITENS_FILHO01', 100,,, 'PASTAFILHOS','ABAFILHO1')
    oView:CreateVerticalBox( "BOX_SEL", 10,'ITENS_FILHO01',, 'PASTAFILHOS','ABAFILHO1')
	
    //Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB' ,'CABEC')
	oView:SetOwnerView('VIEWFILHO','ITENS_FILHO01' )
    oView:SetOwnerView('PANEL_SEL','BOX_SEL')

    oView:EnableTitleView('VIEW_CAB','Cabeçalho - Contrato')
	oView:EnableTitleView('VIEWFILHO','Itens - Contrato')

	oView:AddIncrementField( 'VIEWFILHO', 'ZVI_ITEM' )

<<<<<<< Updated upstream
	oView:AddUserButton( 'Gerar Pedido' ,'', {|oView| ExecSC5Auto()} )
	oView:AddUserButton( 'Processar NPK','', {|oView| ProcessaNPK()} )

/* 	SetKey( VK_F10, {|oView| ExecSC5Auto()} )
	SetKey( VK_F11, {|oView| ProcessaNPK()} ) */
=======
	oView:AddUserButton( 'Gerar Pedido', 'Gerar.PNG', {|oView| ExecSC5Auto()} )
>>>>>>> Stashed changes

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk( { |oView| .T. } )

	oStFilho:RemoveField('ZVI_FILIAL')
	oStFilho:RemoveField('ZVI_CODIGO')
	oStFilho:RemoveField('ZVI_CHVZPB')

Return oView

/* Função para criar Botão Select - "MarkBrowse MVC" */
Static Function criaButtonSel(oPanel,oOtherObject)
    TButton():New( 01, 10, "Selecionar Todos",oPanel,{|| SelGrid(oOtherObject)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
Return

<<<<<<< Updated upstream
/* 05-2022 Igor Oliveira 
	Nao permite apagar linhas com pedido de venda gerado */
Static Function VAFATI01LPRE(oModelGrid, nLinha, cAcao, cCampo)
	Local lRet	 	:= .T.
	Local oModel 	:= oModelGrid:GetModel()
	Local nOpc 		:= oModel:GetOperation()

  // Valida se pode ou não apagar uma linha do Grid
  If cAcao == 'DELETE' .AND. nOpc == MODEL_OPERATION_UPDATE
    if !Empty(oModelGrid:GetValue("ZVI_NUMSC5"))
		lRet := .F.
		Help( ,, 'Help',, 'Não permitido apagar linhas com pedido de venda gerado.' + CRLF +; 
				'Você esta na linha ' + Alltrim( Str( nLinha ) ) + CRLF +;
				'No Item ' + cValtoChar(oModelGrid:GetValue("ZVI_ITEM")) , 1, 0 )
	ENDIF
  EndIf

Return lRet
=======
>>>>>>> Stashed changes

User Function zQtdGat()
	Local aArea      := GetArea()
	Local oModelDad  := FWModelActive()
	Local oModelGrid := oModelDad:GetModel('ZVIFILHO')

	DbSelectArea('ZPB')
	ZPB->(DbSetOrder(1))

	If ZPB->( DbSeek( FWxFilial("ZPB") + Left(_cChaveZPB,8) + Right(_cChaveZPB,6)))
		oModelGrid:SetValue('ZVI_DTPES',ZPB->ZPB_DATAF)
		oModelGrid:SetValue('ZVI_CODZPB',ZPB->ZPB_CODIGO)
	EndIf
	RestArea(aArea)
RETURN

<<<<<<< Updated upstream
=======
User Function zVldZVETab()
	Local aArea  := GetArea()
	Local oModel := FWModelActive()
	Local nOpc   := oModel:GetOperation()
	Local lRet   := .T.

	//Se for Inclusão
	If nOpc == MODEL_OPERATION_INSERT
		DbSelectArea('ZVE')
		ZVE->(DbSetOrder(1)) //ZDM_FILIAL + ZDM_CODIGO + ZDM_CODIGO

		//Se conseguir posicionar, tabela já existe
		If ZVE->(DbSeek( xFilial("ZVE") +;
				oModel:GetValue('ZVEMASTER', 'ZVE_CODIGO')))
				//dToS(oModel:GetValue('ZVEMASTER', 'ZVE_DATA'))))
			Aviso('Atenção', 'Esse código de tabela já existe!', {'OK'}, 02)
			lRet := .F.
		EndIf

	EndIf
	//
	RestArea(aArea)
Return lRet

User Function zSaveZVEMd2()
	Local aArea      := GetArea()
	Local aAreaZVI	 := ZVI->(GetArea())
	Local lRet       := .T.
	Local oModelDad  := FWModelActive()
	Local nOpc       := oModelDad:GetOperation()
	Local oModelGrid := oModelDad:GetModel('ZVIFILHO')/* :SetUniqueLine({'ZVE_CODIGO'}) */
	Local nI         := 0//, nJ := 0
	Local lRecLock   := .T.

	DbSelectArea('ZVE')
	ZVE->(DbSetOrder(1))
	DbSelectArea('ZVI')
	ZVI->(DbSetOrder(1))
	//Se for Inclusão
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
		//Cria o registro na tabela 00 (Cabeçalho de tabelas)
        RecLock('ZVE', lRecLock := !DbSeek( xFilial("ZVE") +;
									oModelDad:GetValue('ZVEMASTER', 'ZVE_CODIGO')))	

        ZVE->ZVE_FILIAL     := oModelDad:GetValue("ZVEMASTER", "ZVE_FILIAL")
        ZVE->ZVE_CODIGO     := oModelDad:GetValue("ZVEMASTER", "ZVE_CODIGO")
        ZVE->ZVE_CODCLI     := oModelDad:GetValue("ZVEMASTER", "ZVE_CODCLI")
        ZVE->ZVE_LOJCLI     := oModelDad:GetValue("ZVEMASTER", "ZVE_LOJCLI")
        ZVE->ZVE_CLINOM     := oModelDad:GetValue("ZVEMASTER", "ZVE_CLINOM")
        ZVE->ZVE_QTDE       := oModelDad:GetValue("ZVEMASTER", "ZVE_QTDE"  )
        ZVE->ZVE_STATUS	    := oModelDad:GetValue("ZVEMASTER", "ZVE_STATUS")
        ZVE->ZVE_VALCA 	    := oModelDad:GetValue("ZVEMASTER", "ZVE_VALCA ")
        ZVE->ZVE_VALCLI	    := oModelDad:GetValue("ZVEMASTER", "ZVE_VALCLI")
        ZVE->ZVE_MENPAD	    := oModelDad:GetValue("ZVEMASTER", "ZVE_MENPAD")
        ZVE->ZVE_CTRANC	    := oModelDad:GetValue("ZVEMASTER", "ZVE_CTRANC")
        ZVE->ZVE_CTRANV	    := oModelDad:GetValue("ZVEMASTER", "ZVE_CTRANV")

		//Percorre as linhas da grid
		For nI := 1 To oModelGrid:GetQtdLine()
			
			oModelGrid:GoLine(nI)
			If !oModelGrid:isDeleted()
				RecLock('ZVI', lRecLock := !DbSeek( xFilial("ZVI") +;
											oModelGrid:GetValue('ZVIFILHO', 'ZVI_CODIGO')+;
                                            cValToChar(oModelGrid:GetValue('ZVI_ITEM'))))											

                ZVI->ZVI_FILIAL     := xFilial("ZVI")  
                ZVI->ZVI_CODIGO     := oModelDad:GetValue( "ZVEMASTER",  "ZVE_CODIGO")	 
                ZVI->ZVI_ITEM       := oModelGrid:GetValue("ZVI_ITEM") 
                ZVI->ZVI_NUMSC5     := oModelGrid:GetValue("ZVI_NUMSC5")
                ZVI->ZVI_PRODUT     := oModelGrid:GetValue("ZVI_PRODUT")
                ZVI->ZVI_QUANT      := oModelGrid:GetValue("ZVI_QUANT")	
                ZVI->ZVI_VLRPTA     := oModelGrid:GetValue("ZVI_VLRPTA") 
                ZVI->ZVI_VALOR      := oModelGrid:GetValue("ZVI_VALOR")		
                ZVI->ZVI_CONPAD     := oModelGrid:GetValue("ZVI_CONPAD")  	
                ZVI->ZVI_TES        := oModelGrid:GetValue("ZVI_TES")	
                ZVI->ZVI_TDESMI     := oModelGrid:GetValue("ZVI_TDESMI")	
                ZVI->ZVI_DESNPK     := oModelGrid:GetValue("ZVI_DESNPK")	
                ZVI->ZVI_NF         := oModelGrid:GetValue("ZVI_NF")	
                ZVI->ZVI_SERINF     := oModelGrid:GetValue("ZVI_SERINF")	
                ZVI->ZVI_DTEMIS     := oModelGrid:GetValue("ZVI_DTEMIS")	
                ZVI->ZVI_PERUMI     := oModelGrid:GetValue("ZVI_PERUMI")	
                ZVI->ZVI_PESLU      := oModelGrid:GetValue("ZVI_PESLU")	
                ZVI->ZVI_PERNPK     := oModelGrid:GetValue("ZVI_PERNPK")	
                ZVI->ZVI_PESLQF     := oModelGrid:GetValue("ZVI_PESLQF")	
                ZVI->ZVI_PESTOT     := oModelGrid:GetValue("ZVI_PESTOT")	
				ZVI->ZVI_DTPES		:= oModelGrid:GetValue("ZVI_DTPES")	
				ZVI->ZVI_CODZPB		:= oModelGrid:GetValue("ZVI_CODZPB")	
				ZVI->ZVI_PLACA		:= oModelGrid:GetValue("ZVI_PLACA")	
				ZVI->ZVI_TRANSP		:= oModelGrid:GetValue("ZVI_TRANSP")	

				ZVI->(MsUnlock())
			Else		
 				If ZVI->(DbSeek( xFilial("ZVI") +;
						oModelGrid:GetValue('ZVIFILHO', 'ZVI_CODIGO')+;				
						cValToChar(oModelGrid:GetValue('ZVI_ITEM'))))			
					
					RecLock('ZVI', .F.)
						ZVI->(DbDelete())
					ZVI->(MsUnlock())
				EndIf 
			EndIf
			
		Next nI

	//Se for Exclusão
 	ElseIf nOpc == MODEL_OPERATION_DELETE

	 	ZVE->(DbSeek( xFilial("ZVE") +;
						oModelDad:GetValue('ZVEMASTER', 'ZVE_CODIGO')))
		
		RecLock('ZVI', .F.)
		ZVE->(DbDelete())
		ZVE->(MsUnlock())

		For nI := 1 To oModelGrid:GetQtdLine()
			oModelGrid:GoLine(nI)
			//Se conseguir posicionar, exclui o registro
			If ZVI->(DbSeek( xFilial("ZVI") +;
						oModelGrid:GetValue('ZVIFILHO', 'ZVI_CODIGO') +;//oModelDad:GetValue('ZVIFILHO', 'ZVI_CODIGO') +;
						cValToChar(oModelGrid:GetValue('ZVI_ITEM'))))

				RecLock('ZVI', .F.)
					ZVI->(DbDelete())
				ZVI->(MsUnlock())
			EndIf
		Next nI 
	EndIf

	//Se não for inclusão, volta o INCLUI para .T. (bug ao utilizar a Exclusão, antes da Inclusão)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

	RestArea(aArea)
	RestArea(aAreaZVI)
Return lRet

>>>>>>> Stashed changes
Static Function SelGrid(oOtherObject)
	Local oGrid := oOtherObject:GetModel():GetModel("ZVIFILHO")
	Local nX
	Local lValue
	Local nLine := oGrid:GetLine()

    For nX:=1 to oGrid:Length()
        oGrid:GoLine(nX)
        If !oGrid:isDeleted()
            lValue := oGrid:GetValue("Gerar")
            oGrid:LoadValue("Gerar", !lValue)
        EndIf
    Next nX

    oGrid:GoLine(nLine)
    oOtherObject:oControl:Refresh('FORM_NOTA')
Return

Static Function ExecSC5Auto()
	Local aArea            := GetArea()
	Local aAreaZVI		   := ZVI->(GetArea())
<<<<<<< Updated upstream
	Local aAreaZPB		   := ZPB->(GetArea())
=======
>>>>>>> Stashed changes
	Local aErroAuto        := {}
	Local aCabPV           := {}
	Local aItemPV          := {}
	Local oView 		   := FWViewActive()
	Local oModelDad  	   := FWModelActive()
	Local oModelGrid 	   := oModelDad:GetModel('ZVIFILHO')
<<<<<<< Updated upstream
	Local nOpc  		   := oModelDad:GetOperation()
=======
>>>>>>> Stashed changes
	Local nI               := 0
	Local lErro            := .F.
	Local nCount           := 0
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .F.

	DbSelectArea('ZVI')
	ZVI->(DbSetOrder(1))
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
	
	SA1->( DbSetOrder(1) )
	If SA1->( DbSeek( xFilial("SA1") + oModelDad:GetValue("ZVEMASTER", "ZVE_CODCLI") + oModelDad:GetValue("ZVEMASTER", "ZVE_LOJCLI")) )
		
		IF	oModelGrid:GetValue("ZVI_TRANSP") == "1"
			cFrete := "R"
			cTransp := oModelDad:GetValue("ZVEMASTER", "ZVE_CTRANV")
		else
			cFrete := "F"
			cTransp := oModelDad:GetValue("ZVEMASTER", "ZVE_CTRANC")
		ENDIF
		
		If !Empty(oModelGrid:GetValue("ZVI_CODZPB"))
<<<<<<< Updated upstream

			DbSelectArea('ZPB')
			ZPB->(DbSetOrder(2))
=======
			cPlaca := "PLACA: " + oModelGrid:GetValue("ZVI_PLACA") + " PESAGEM: " +  AllTrim(DToS(oModelGrid:GetValue("ZVI_DTPES"))) + "-" + oModelGrid:GetValue("ZVI_CODZPB") + ""
>>>>>>> Stashed changes
			
			For nI := 1 To oModelGrid:GetQtdLine()
				oModelGrid:GoLine(nI)				
				If !oModelGrid:isDeleted()
					lValue := oModelGrid:GetValue("Gerar")
					If lValue
						If Empty(oModelGrid:GetValue("ZVI_NUMSC5"))
<<<<<<< Updated upstream
							
							ZPB->( DbSeek( FWxFilial("ZPB") + oModelGrid:GetValue("ZVI_PLACA") +;
								  AllTrim(DToS(oModelGrid:GetValue("ZVI_DTPES"))) + oModelGrid:GetValue("ZVI_CODZPB")))

							cPlaca := "PLACA: " + oModelGrid:GetValue("ZVI_PLACA") +;
									  " PESAGEM: " +  AllTrim(DToS(oModelGrid:GetValue("ZVI_DTPES"))) +;
									  "-" + oModelGrid:GetValue("ZVI_CODZPB") +;
									  " MOTORISTA: " + ZPB->ZPB_NOMMOT + ""
							
							aCabPV  := {}
							aItemPV := {}

=======
>>>>>>> Stashed changes
							cNumPed := U_fChvITEM( "SC5", , "C5_NUM" )
							aCabPV  := {{ "C5_FILIAL", xFilial("SC5")					 				, Nil},; 
										{"C5_NUM"    , cNumPed     						 				, Nil},;
										{"C5_TIPO"   , "N"         						 				, Nil},;
										{"C5_MENPAD" , oModelDad:GetValue("ZVEMASTER", "ZVE_MENPAD") 	, Nil},;
										{"C5_CLIENTE", SA1->A1_COD 						 				, Nil},;
										{"C5_LOJACLI", SA1->A1_LOJA						 				, Nil},;
										{"C5_CLIENT" , SA1->A1_COD 						 				, Nil},;
										{"C5_LOJAENT", SA1->A1_LOJA						 				, Nil},;
										{"C5_TIPOCLI", "F"								 				, Nil},;
										{"C5_NATUREZ", SA1->A1_NATUREZ					 				, Nil},;
										{"C5_TPFRETE", cFrete							 				, Nil},;
										{"C5_TRANSP" , cTransp							 				, Nil},;
										{"C5_MENNOTA", cPlaca							 				, Nil},;
										{"C5_PESOL"  , oModelGrid:GetValue("ZVI_QUANT")	 				, Nil},;
										{"C5_CONDPAG", oModelGrid:GetValue("ZVI_CONPAD") 				, Nil},;
										{"C5_PESOL"  , oModelGrid:GetValue("ZVI_QUANT") 				, NIL}}

							
								nPrcVen	:= oModelGrid:GetValue("ZVI_VLRPTA") / 1000
									AADD(aItemPV, { {"C6_FILIAL" 	, xFilial("SC6")          														 , Nil},;
											{"C6_NUM"    	, cNumPed                    													 , Nil},;
											{"C6_ITEM"   	, oModelGrid:GetValue("ZVI_ITEM")          										 , Nil},;
											{"C6_PRODUTO"	, oModelGrid:GetValue("ZVI_PRODUT")        										 , Nil},;
											{"C6_QTDVEN" 	, oModelGrid:GetValue("ZVI_QUANT")         										 , Nil},;
											{"C6_UM" 	    , Posicione("SB1",1,xFilial("SB1") + oModelGrid:GetValue("ZVI_PRODUT"), "B1_UM") , Nil},;
											{"C6_PRCVEN" 	, nPrcVen        																 , Nil},;
											{"C6_VALOR"  	, oModelGrid:GetValue("ZVI_VALOR")												 , Nil},;
											{"C6_DESCONTO"  , oModelGrid:GetValue("ZVI_DESCT")												 , Nil},;
											{"C6_TES"    	, oModelGrid:GetValue("ZVI_TES")												 , Nil}})

								lMsErroAuto := .F.
								
								while !LockByName("ExecSC5Auto"+ cNumPed, .t., .f.)
									Sleep(500)
								end
									MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItemPV,3)
								UnlockByName("ExecSC5Auto"+cNumPed)
							
								If lMSErroAuto
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
											"Nota Fiscal [" + SF2->F2_FILIAL+"-"+ AllTrim(SF2->F2_DOC)+"-"+AllTrim(SF2->F2_SERIE) + "] faturada com sucesso" )
								
											oModelGrid:SetValue('ZVI_NUMSC5'  , StrZero(Val(cPedVen),TamSX3('ZVI_NUMSC5')[1]))
											oModelGrid:SetValue('ZVI_NF'	  , SF2->F2_DOC)
											oModelGrid:SetValue('ZVI_SERINF'  , SF2->F2_SERIE)
											oModelGrid:SetValue('ZVI_DTEMIS'  , dDataBase)
										
										oView:Refresh()
									EndIf
								Endif
						else
							MsgAlert( "Pedido de Venda no Item [ " + cValtoChar(oModelGrid:GetValue("ZVI_ITEM")) + " ] não pode ser gerado duas vezes" + CRLF +;
					 			"Pedido [ "+oModelGrid:GetValue("ZVI_NUMSC5")+" ] Gerado anteriormente!!! ", "Atenção...")
						ENDIF						
					ENDIF	
				else				
					if ZVI->(DbSeek( xFilial("ZVI") +;
<<<<<<< Updated upstream
								oModelGrid:GetValue('ZVI_CODIGO')+;				
								oModelGrid:GetValue('ZVI_ITEM')))
=======
								oModelGrid:GetValue('ZVIFILHO', 'ZVI_CODIGO')+;				
								cValToChar(oModelGrid:GetValue('ZVI_ITEM'))))
>>>>>>> Stashed changes
						
							RecLock('ZVI', .F.)
								ZVI->(DbDelete())
							ZVI->(MsUnlock())
						EndIf 	
					EndIf
			Next nI
		else
			MsgAlert( "Pedido de Venda no Item [ " + cValtoChar(oModelGrid:GetValue("ZVI_ITEM")) + " ] não pode ser gerado !!!" + CRLF +;
					"Preencha os campos [ Cod. Pesagem, Placa e Transporte ]", "Atenção...")
		ENDIF
	EndIf
<<<<<<< Updated upstream
	
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf
	
	RestArea(aAreaZPB)
	RestArea(aAreaZVI)
	RestArea(aArea)
Return lMSErroAuto
=======
	RestArea(aAreaZVI)
	RestArea(aArea)
Return lMSErroAuto

/* I.O 04-05-2022
	Gatilho para atualizar Desconto A partir da ZDE */
User Function GetUmiD()//(_cAlias, _cCampo)
	Local aArea		 	:= GetArea()
	Local oModelDad  	:= FWModelActive()
	Local oModelGrid 	:= oModelDad:GetModel('ZVIFILHO')
	
	DbSelectArea('ZDE')
	ZDE->(DbSetOrder(4))
	
		lUmi := .T.
		nUmidade := oModelGrid:GetValue('ZVI_PERUMI')
		IF ZDE->(DbSeek(xFilial("ZDE") + oModelGrid:GetValue("ZVI_TDESMI") + "1"))
			
			While !ZDE -> (EOF()) 
				IF (nUmidade >= ZDE->ZDE_TOLDE .and. nUmidade <= ZDE->ZDE_TOLATE .and. lUmi)
					nPerc := ZDE->ZDE_PERCE
					exit
				ENDIF
				ZDE->(DBSkip())
			ENDDO
		ENDIF
	RestArea(aArea)
Return  nPerc

User Function GetNpkD()
	Local aArea		 	   := GetArea()
	Local oModelDad  	   := FWModelActive()
	Local oModelGrid 	   := oModelDad:GetModel('ZVIFILHO')
		
	DbSelectArea('ZDE')
	ZDE->(DbSetOrder(4))
		lNpk := .T.
		nPerNPK	 := oModelGrid:GetValue('ZVI_PERNPK')
		IF ZDE->(DbSeek(xFilial("ZDE") + oModelGrid:GetValue("ZVI_TDESMI") + "2"))
			While !ZDE -> (EOF()) 
				if (nPerNPK >= ZDE->ZDE_TOLDE .and. nPerNPK <= ZDE->ZDE_TOLATE .and. lNpk )
					nPerc := ZDE->ZDE_PERCE
					exit
				ENDIF
				ZDE->(DBSkip())
			ENDDO
		ENDIF
	RestArea(aArea)
RETURN nPerc
>>>>>>> Stashed changes
/*------------ --------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  LIBeFaturar	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  10.12.2020                                                              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
'--------------------------------------------------------------------------------*/
Static Function LIBeFaturar( cFilEnt, cPedVen, cE1HIST )
	Local lErro	:= .F.	
	//Backup da Filial
	Local nRecSM0  	:= SM0->(RecNo())
	Local cCurFil  	:= SM0->M0_CODFIL 
	Local lFatAuto := GetMV("VA_FATAUTO",, .T. ) // Define o faturamento automatico, executado pela função de leitura webservice das liberacoes do pedido enviada pelo Site.
	
	u_MudaFilial( cFilEnt )	

	cE1HIST += Iif(!Empty(cE1HIST), "," , "") + SubStr(cFilEnt,5) +'-'+ cPedVen //+ ' / ' + xLibPedVen[nPosPedImp][2] 

	IF cPedVen <> SC5->C5_NUM
		SC5->(DbSetOrder(1))
		SC5->(DBSeek( cFilEnt + cPedVen ))
	EndIf

	If !Empty(SC5->C5_NOTA)		// Pedido já faturado, retorna .T. p/ continuar o processo
		Alert('[VAFATI01] Pedido: '+ SC5->C5_NUM + ' ja esta faturado na nota: ' + SC5->C5_FILIAL + '/' + SC5->C5_NOTA + '/' + SC5->C5_SERIE )
		Return .F.
	endif

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
	Endif
	
	// Voltar filial anterior
	SM0->(DbGoTo(nRecSM0))
	cFilAnt := cCurFil
	
Return lErro

<<<<<<< Updated upstream
/* I.O 04-05-2022
	Gatilho para atualizar Desconto A partir da ZDE */
User Function GetUmiD()//(_cAlias, _cCampo)
	Local aArea		 	:= GetArea()
	Local oView 	    := FWViewActive()
	Local oModelDad  	:= FWModelActive()
	Local oModelGrid 	:= oModelDad:GetModel('ZVIFILHO')
	Local nPerc
	
	DbSelectArea('ZDE')
	ZDE->(DbSetOrder(4))
	
		lUmi := .T.
		nUmidade := oModelGrid:GetValue('ZVI_PERUMI')
		IF ZDE->(DbSeek(xFilial("ZDE") + oModelGrid:GetValue("ZVI_TDESMI") + "1"))
			
			While !ZDE -> (EOF()) 
				IF (nUmidade >= ZDE->ZDE_TOLDE .and. nUmidade <= ZDE->ZDE_TOLATE .and. lUmi)
					nPerc := ZDE->ZDE_PERCE
						oModelGrid:SetValue('ZVI_PESLU', oModelGrid:GetValue('ZVI_QUANT') + oModelGrid:GetValue('ZVI_QUANT') * (nPerc / 100))
					exit
				ENDIF
				ZDE->(DBSkip())
			ENDDO
		ENDIF
		oView:Refresh()
	RestArea(aArea)
Return  nPerc

User Function GetNpkD()
	Local aArea		 := GetArea()
	Local oView 	 := FWViewActive()
	Local oModelDad  := FWModelActive()
	Local oModelGrid := oModelDad:GetModel('ZVIFILHO')
		
	DbSelectArea('ZDE')
	ZDE->(DbSetOrder(4))
		lNpk := .T.
		nPerNPK	 := oModelGrid:GetValue('ZVI_PERNPK')
		IF ZDE->(DbSeek(xFilial("ZDE") + oModelGrid:GetValue("ZVI_TDESMI") + "2"))
			While !ZDE -> (EOF())
				if (nPerNPK >= ZDE->ZDE_TOLDE .and. nPerNPK <= ZDE->ZDE_TOLATE .and. lNpk )
					nPerc := ZDE->ZDE_PERCE
					exit
				ENDIF
				ZDE->(DBSkip())
			ENDDO
		ENDIF-
		oView:Refresh()
	RestArea(aArea)
RETURN nPerc

=======
>>>>>>> Stashed changes
/*  28/04/2022 - CONSULTA ESPECIFICA NO CAMPO ZVI_QUANT */
User Function ceQtEst()
    Local aArea	 := GetArea()
	Local oDlg, oLbx
    Local aCpos  := {}
    Local aRet   := {}
    Local _cQry  := ""
    Local cAlias := GetNextAlias()
    Local lRet   := .F.
	Local oView		 := FWViewActive()
	Local oModelDad  := FWModelActive()
	Local oModelGrid := oModelDad:GetModel('ZVIFILHO')

    _cQry := "  Select ZPB_DATA   " + CRLF
	_cQry += "  	,  ZPB_HORAF  " + CRLF
	_cQry += "  	,  ZPB_CODIGO " + CRLF
	_cQry += "  	,  ZPB_CODFOR " + CRLF
	_cQry += "  	,  ZPB_NOMFOR " + CRLF
	_cQry += "  	,  ZPB_PLACA  " + CRLF
	_cQry += "  	,  ZPB_PESOE  " + CRLF
	_cQry += "  	,  ZPB_PESOS  " + CRLF
	_cQry += "  	,  ZPB_PESOL  " + CRLF
	_cQry += " 		,  CASE WHEN DA3_PLACA IS NOT NULL THEN '1' ELSE '2' END TRANSPORTE" + CRLF
	_cQry += "  FROM ZPB010 ZPB " + CRLF
	_cQry += " 		LEFT JOIN DA3010 DA3 ON DA3_FILIAL = ' ' " + CRLF
<<<<<<< Updated upstream
	//_cQry += " 		AND DA3_PLACA = ZPB_PLACA AND DA3.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " 		AND RTRIM(DA3_COD) = RTRIM(ZPB_PLACA) AND DA3.D_E_L_E_T_ = ' '  " + CRLF
	_cQry += "  WHERE  ZPB_FILIAL = '"+ xFilial('ZPB')+ "'" + CRLF
	_cQry += "  	AND ZPB_DATA  >=  DATEADD(DAY,-5, '"+ DtoS(dDataBase)+"')" + CRLF
	//_cQry += "  	AND ZPB_PRODUT = '640012' " + CRLF
	_cQry += "  	AND ZPB_PRODUT IN ('640012','640054') " + CRLF
=======
	_cQry += " 		AND DA3_PLACA = ZPB_PLACA AND DA3.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "  WHERE  ZPB_FILIAL = '"+ xFilial('ZPB')+ "'" + CRLF
	_cQry += "  	AND ZPB_DATA  >=  DATEADD(DAY,-5, '"+ DtoS(dDataBase)+"')" + CRLF
	_cQry += "  	AND ZPB_PRODUT = '640012' " + CRLF
>>>>>>> Stashed changes
	_cQry += "  	AND ZPB.D_E_L_E_T_ = '' " + CRLF
	_cQry += "  	AND ZPB_FILIAL + ZPB_CODIGO + ZPB_DATA NOT IN (SELECT ZVI_FILIAL + ZVI_CODZPB + ZVI_DTPES FROM ZVI010 WHERE D_E_L_E_T_ = '') " + CRLF
 
    // _cQry := ChangeQuery(_cQry)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAlias,.T.,.T.)

<<<<<<< Updated upstream
    While !(cAlias)->(EOF())
=======
    While (cAlias)->(!Eof())
>>>>>>> Stashed changes
        aAdd(aCpos,{(cAlias)->ZPB_DATA,;
				    (cAlias)->ZPB_HORAF,;
					(cAlias)->ZPB_CODIGO,;
					(cAlias)->ZPB_CODFOR,;
					(cAlias)->ZPB_NOMFOR,;
					(cAlias)->ZPB_PLACA,;
					(cAlias)->ZPB_PESOE,;
					(cAlias)->ZPB_PESOS,;
					(cAlias)->ZPB_PESOL,;
					(cAlias)->TRANSPORTE})
        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())

    If Len(aCpos) < 1
        aAdd(aCpos,{" "," "," "," "," ","","","",""})
    EndIf

    DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Listagem das Pesagens" FROM 0,0 TO 325,1000 PIXEL

    @ 0,0 LISTBOX oLbx FIELDS HEADER 'DATA' /*"Produto"*/,;
        'HORA F.',;
		'CODIGO',;
		'COD FORNEC',;
		'FORNECEDOR',;
		'PLACA',;
		'PESO E.',;
		'PESO S.',;
		'PESO L.',;
		'TRANSPORTE' SIZE 500,150 OF oDlg PIXEL

    oLbx:SetArray( aCpos )
    oLbx:bLine     := {|| { sToD(aCpos[oLbx:nAt,1]),;
                            aCpos[oLbx:nAt,2],;
                            aCpos[oLbx:nAt,3],;
                            aCpos[oLbx:nAt,4],;
                            aCpos[oLbx:nAt,5],;
                            aCpos[oLbx:nAt,6],;
                            aCpos[oLbx:nAt,7],;
                            aCpos[oLbx:nAt,8],;
                            aCpos[oLbx:nAt,9],;
                            aCpos[oLbx:nAt,10]}}
    oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {sToD(oLbx:aArray[oLbx:nAt,1]),;
                            oLbx:aArray[oLbx:nAt,2],;
                            oLbx:aArray[oLbx:nAt,3],;
                            oLbx:aArray[oLbx:nAt,4],;
                            oLbx:aArray[oLbx:nAt,5],;
                            oLbx:aArray[oLbx:nAt,6],;
                            oLbx:aArray[oLbx:nAt,7],;
                            oLbx:aArray[oLbx:nAt,8],;
                            oLbx:aArray[oLbx:nAt,9],;
                            oLbx:aArray[oLbx:nAt,10]}}}
    DEFINE SBUTTON FROM 150,474 TYPE 1 ACTION (oDlg:End(), lRet:=.T.,;
        aRet := {sToD(oLbx:aArray[oLbx:nAt,1]),;
                 oLbx:aArray[oLbx:nAt,2],;
                 oLbx:aArray[oLbx:nAt,3],;
                 oLbx:aArray[oLbx:nAt,4],;
                 oLbx:aArray[oLbx:nAt,5],;
                 oLbx:aArray[oLbx:nAt,6],;
                 oLbx:aArray[oLbx:nAt,7],;
                 oLbx:aArray[oLbx:nAt,8],;
                 oLbx:aArray[oLbx:nAt,9],;
                 oLbx:aArray[oLbx:nAt,10]})  ENABLE OF oDlg
    ACTIVATE MSDIALOG oDlg CENTER

    If Len(aRet) > 0 .And. lRet
        If Empty(aRet[9])
            lRet := .F.
        Else
			 _cPesoS	:= aRet[9]
            _cChaveZPB 	:= dToS(aRet[1]) + aRet[3] 
			oModelGrid:SetValue("ZVI_TRANSP", aRet[10])
			oModelGrid:SetValue("ZVI_PLACA",  aRet[6])
        EndIf
    EndIf
<<<<<<< Updated upstream
	
	IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
	    MemoWrite(StrTran(cArquivo,".xml","")+"ZPB_"+cPerg + cValToChar(dDataBase)+".sql" , _cQry)
    ENDIF

	oView:Refresh()
	RestArea(aArea)
Return lRet
/* BLOQUEIA CONTRATO */
Static Function xAutoZVE()
	Local aArea			:= GetArea()
	Local oView			:= FWViewActive()
	Local oModelDad  	:= FWModelActive()

	if oModelDad:GetValue("ZVEMASTER","ZVE_STATUS")=="2"
		if !msgYesNo("Esta operação bloqueará a edição do cabeçalho e itens, deseja continuar?")
			RestArea(aArea)
			return nil 
		else
			oModelDad:SetValue("ZVE_STATUS", "1")
		endIf
		oView:Refresh()
	endIf
RETURN

Static Function GeraSX1(cPerg)
    Local aArea	:= GetArea()
    Local aRegs     := {}
    Local nX		:= 0
    Local nPergs	:= 0
    Local i
    Local j

	DbSelectArea('SX1')
    DbSetOrder(1)
    SX1->(DbGoTop())
    IF SX1->(DbSeek(cPerg))
        WHILE !SX1->(Eof()) .And. X1_GRUPO = cPerg
            nPergs++
            SX1->(DbSkip())
        ENDDO
    ENDIF
    AADD(aRegs,{cPerg,"01","Processa  ?",Space(20),Space(20),"mv_ch1",'C',01,0,1,"C","","mv_par01","1-Processamento","","","","","2-Reprocessamento","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"02","Data de   ?",Space(20),Space(20),"mv_ch1",'D',08,0,0,"G","","mv_par01",""				,"","","","",""					,"","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Data ate  ?",Space(20),Space(20),"mv_ch2",'D',08,0,0,"G","","mv_par02",""				,"","","","",""					,"","","","","","","","","","","","","","","","","","","","","","","",""})

	//Se quantidade de perguntas for diferente, apago todas
    SX1 -> (DbGoTop())
    IF nPergs <> Len(aRegs)
        FOR nX := 1 to nPergs
            IF  SX1 -> (DbSeek(cPerg))
                IF  RecLock('SX1', .F.)
                    SX1 -> (DbDelete())
                    SX1 -> (MsUnlock())
                ENDIF               
            ENDIF
        NEXT nX
    ENDIF

	// gravação das perguntas na tabela SX1
    IF nPergs <> Len(aRegs)
        DbSelectArea("SX1")
        DbSetOrder(1)
        FOR i := 1 to Len(aRegs)
            IF !DbSeek(cPerg+aRegs[i,2])
                RecLock("SX1", .T.)
                    FOR j := 1 to FCOUNT()
                        IF j <= Len(aRegs[i])
                            FieldPut(j,aRegs[i,j])
                        ENDIF
                    NEXT j
                MsUnlock()
            ENDIF
        NEXT i 
    ENDIF

	RestArea(aArea)
Return nil

Static Function fPrintX1(cPerg)
    Local lRet := .F.
	IF Pergunte(cPerg, .T.)
        U_PrintSX1(cPerg)
		   IF Len(Directory(cArquivo + "*.*","D")) == 0
				IF Makedir(cArquivo) == 0 
					ConOut('Diretório criado com sucesso.')
					MsgAlert('Diretorio criado com sucesso: ', + cArquivo, 'Aviso')
				ELSE
					ConOut("Não foi possivel criar o diretório. Erro: " + CValToChar(FError()))
					MsgAlert('Não foi possível criar o diretório. Erro', CValToChar(FError()),'Aviso')
				ENDIF
        	ENDIF
		lRet := .T.
	ENDIF
RETURN lRet

Static Function ProcessaNPK()
 	Local aArea	 	 	:= GetArea()
	Local aAreaZDE 		:= ZDE->(GetArea())
	Local _cQry		 	:= ""
	Local aCPos  	 	:= {}
	Local nPerc			:= 0
	Local nI			:= 0
	Local cAlias 	 	:= GetNextAlias()
	Local oView			:= FWViewActive()
	Local oModelDad  	:= FWModelActive()
	Local oModelGrid 	:= oModelDad:GetModel('ZVIFILHO')
	
	lPerg := fPrintX1(cPerg)
	if lPerg

/* 		_cQry := " SELECT ZVI_CODIGO = '" + oModelGrid:GetValue("ZVI_CODIGO") +"'" + CRLF
		_cQry += "				, ZVI_ITEM" + CRLF
		_cQry += "				, ZVI_QUANT" + CRLF
		_cQry += "				, ZVI_NF" + CRLF
		_cQry += "				, ZVI_DTEMIS" + CRLF
		_cQry += "				, (ZNP_APUVA+ZNP_APUCLI)/2 PERCENTUAL" + CRLF
		_cQry += "      FROM " + RetSqlName("ZVI") + " ZVI" + CRLF
		_cQry += " LEFT JOIN " + RetSqlName("ZNP") + " ZNP ON" + CRLF
		_cQry += "           ZNP.ZNP_FILIAL = '" + xFilial("ZNP") + "' " + CRLF
		_cQry += "       AND ZVI.ZVI_DTEMIS BETWEEN '" +DToS(mv_par02)+ "' AND '" +DToS(mv_par03)+ "'" + CRLF
		_cQry += " 	  AND ZNP.D_E_L_E_T_ = ' '" + CRLF
		_cQry += " 	WHERE ZVI.ZVI_FILIAL = '" + xFilial("ZVI") + "'" + CRLF
		_cQry += " 	  AND ZVI.ZVI_DTEMIS BETWEEN '" +DToS(mv_par02)+ "' AND '" +DToS(mv_par03)+ "'" + CRLF
		_cQry += " 	  AND ZVI.D_E_L_E_T_ = ' ' " + CRLF */

		_cQry := " SELECT ZVI_CODIGO = '" + oModelGrid:GetValue("ZVI_CODIGO") +"'" + CRLF
		_cQry += "				, ZVI_ITEM" + CRLF
		_cQry += "				, ZVI_QUANT" + CRLF
		_cQry += "				, ZVI_NF" + CRLF
		_cQry += "				, ZVI_DTEMIS" + CRLF
		_cQry += "				, (ZNP_APUVA+ZNP_APUCLI)/2 PERCENTUAL" + CRLF
		_cQry += "      FROM " + RetSqlName("ZVI") + " ZVI" + CRLF
		_cQry += " LEFT JOIN " + RetSqlName("ZNP") + " ZNP ON" + CRLF
		_cQry += "           ZNP.ZNP_FILIAL = '" + xFilial("ZNP") + "' " + CRLF
		_cQry += "       AND ZVI.ZVI_DTEMIS BETWEEN ZNP_DTINI AND ZNP_DTATE" + CRLF
		_cQry += " 	  AND ZNP.D_E_L_E_T_ = ' '" + CRLF
		_cQry += " 	WHERE ZVI.ZVI_FILIAL = '" + xFilial("ZVI") + "'" + CRLF
		_cQry += " 	  AND ZVI.ZVI_DTEMIS BETWEEN ZNP_DTINI AND ZNP_DTATE" + CRLF
		_cQry += " 	  AND ZVI.ZVI_CODIGO = '" + oModelGrid:GetValue("ZVI_CODIGO") +"' " + CRLF
		_cQry += " 	  AND ZVI.ZVI_TDESMI = '" + oModelGrid:GetValue("ZVI_TDESMI") +"' " + CRLF
		IF mv_par01 == 2
			_cQry += " 	  AND ZVI.ZVI_DTEMIS BETWEEN '" + dToS(mv_par02) + "' AND '" + dToS(mv_par03) + "'" + CRLF
		else 
			_cQry += " 	  AND ZVI.ZVI_DTEMIS BETWEEN DATEADD(DAY,-10, '"+ DtoS(dDataBase)+"') AND '" + dToS(dDataBase) + "'" + CRLF
		ENDIF
		_cQry += " 	  AND ZVI.D_E_L_E_T_ = ' ' " + CRLF


		DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAlias,.F.,.F.)

		While (cAlias)->(!EOF())
			aAdd(aCPos, {(cAlias)->ZVI_CODIGO,;
						(cAlias)->ZVI_ITEM,;
						(cAlias)->ZVI_QUANT,;
						(cAlias)->ZVI_NF,;
						(cAlias)->ZVI_DTEMIS,;
						(cAlias)->PERCENTUAL})
			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())



		dbSelectArea("ZVI")
		ZVI->( DbSetOrder(1) )
		
		DbSelectArea('ZDE')
		ZDE->(DbSetOrder(4))
		
		If Len(aCPos) < 1
			aAdd(aCPos,{"","","","","",""})
			MsgAlert("Não há dados disponiveis para processamento", "Atenção...")			
		else			
			for nI := 1 to Len(aCPos)
				lNpk := .T.
				nPerNPK	 := aCPos[nI][6]
				IF ZDE->(DbSeek(xFilial("ZDE") + oModelGrid:GetValue("ZVI_TDESMI") + "2"))
					While !ZDE -> (EOF())
						if (nPerNPK >= ZDE->ZDE_TOLDE .and. nPerNPK <= ZDE->ZDE_TOLATE )
							nPerc := ZDE->ZDE_PERCE
							
							RecLock('ZVI', lRecLock := !DbSeek( xFilial("ZVI") + cValToChar(aCPos[nI][1]) + cValToChar(aCPos[nI][2])))
							
							oModelGrid:SetValue("ZVI_DESCNP", nPerc)
							oModelGrid:SetValue("ZVI_PERNPK", aCPos[nI][6])
							oModelGrid:SetValue("ZVI_PESLQF", aCPos[nI][3] + (aCPos[nI][3] * (nPerc / 100)))
							oModelGrid:SetValue("ZVI_PESTOT", oModelGrid:GetValue('ZVI_QUANT') +;
												( oModelGrid:GetValue('ZVI_PESLQF') - oModelGrid:GetValue('ZVI_QUANT') ) +;
												( oModelGrid:GetValue('ZVI_PESLU')  - oModelGrid:GetValue('ZVI_QUANT') ) ) 
							ZVI->(MsUnlock())
							exit
						ENDIF
						ZDE->(DBSkip())
					ENDDO
				ENDIF
			next 			
			IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
				MemoWrite(StrTran(cArquivo,".xml","")+"ZNP_"+cPerg + cValToChar(dDataBase)+".sql" , _cQry)
			ENDIF
		EndIf
		oView:Refresh()
		
		RestArea(aAreaZDE)
		RestArea(aArea)
	else
		ConOut( "Operação cancelada!!!")
		//MsgAlert("Operação cancelada!!!", "Atenção...")
	ENDIF
RETURN aCPos

/*	
User Function COMP021LPRE(_oModelGrid, nLine, cAction, cField)

TENTATIVAS DE ATUALIZAR A GRID APENAS QUANDO FOR ADICIONAR A LINHA

Return .T.
Local lRetorno := MsgYesNo("Deseja continuar ???", "COMP021LPRE")
Return lRetorno


Static Function  FZ0ELok(oModel)
// MsgAlert("FZ0ELok")
Local lRetorno := MsgYesNo("Deseja continuar ???", "FZ0ELok")
Return lRetorno

Static Function  fBPre(oModel)
// MsgAlert("FZ0ELok")
Local lRetorno := MsgYesNo("Deseja continuar ???", "fBPre")
Return lRetorno


Static Function  FZ0ETok(xVar)
Local lRetorno := MsgYesNo("Deseja continuar ???", "FZ0ETok")
Return lRetorno
*/

User Function fX3RELI01()
	Local oModelDad  := FWModelActive()
	Local oModelGrid := oModelDad:GetModel('ZVIFILHO')
	//Local cAcao 	 := oModelGrid:GetOperation()
	Local nLinha 	 := 0
	Local cTabDesc   := ""
/* 	ReadVar() -> Variavel em q está posicionado 
	&(ReadVar()) -> VAlor da Variavel*/
	Local cCampo 	 := SubS( ReadVar(), At(">", ReadVar())+1 )
	// Local _cInfo := &(ReadVar())

	If cCampo == "ZVI_TDESMI"
		nLinha := oModelGrid:GetQtdLine()
		if nLinha > 1 
			oModelGrid:Goline(nLinha-1)
			cTabDesc :=	oModelGrid:GetValue("ZVI_TDESMI")
		else 
			cTabDesc := ""
		ENDIf
	EndIf

Return cTabDesc

/* Igor OLiveira 10/05/2022 
	Gatilho para atualizar Peso Total */
/* User Function zPesoTI01()
	Local nPeso := 0
	Local oModelDad  	   := FWModelActive()
	Local oModelGrid 	   := oModelDad:GetModel('ZVIFILHO')

	nPeso := oModelGrid:GetValue('ZVI_QUANT') + ( oModelGrid:GetValue('ZVI_PESLQF') - oModelGrid:GetValue('ZVI_QUANT') ) +;
			 (ModelGrid:GetValue('ZVI_PESLU') - oModelGrid:GetValue('ZVI_QUANT') ) 

RETURN nPeso */
=======
	oView:Refresh()
	RestArea(aArea)
Return lRet

Static Function xAutoZVE()
Local aArea			:= GetArea()
Local oView			:= FWViewActive()
Local oModelDad  	:= FWModelActive()

if oModelDad:GetValue("ZVEMASTER","ZVE_STATUS")=="2"
	if !msgYesNo("Esta operação bloqueará a edição do cabeçalho e itens, deseja continuar?")
		RestArea(aArea)
		return nil 
	else
		oModelDad:SetValue("ZVE_STATUS", "1")
	endIf
	oView:Refresh()
endIf
>>>>>>> Stashed changes
