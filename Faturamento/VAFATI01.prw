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

/* Igor Oliveira  05/2022 - Contrato Venda de Adubo */
User Function VAFATI01()
    Local aArea   		:= GetArea()
	Local aAreaZVI		:= ZVI->(GetArea())
    Local oModel  		:= NIL
	Local cFunBkp 		:= FunName()

	Private cPerg     	:= "VAFATI01"
	Private cArquivo    := "C:\TOTVS_RELATORIOS\"
	Private cE1HIST 	:= ""
	Private _cPesoS 	:= CriaVar('ZPB_PESOL'  , .F.)
	Private _cChaveZPB 	:= CriaVar('ZVI_CHVZPB' , .F.)
	Private _cDesc 		:= CriaVar('ZVI_DESCT'  , .F.)/*  */
	Private lGeraPed	:= .F.
	
	GeraSX1(cPerg)

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
Return aRot

Static Function ModelDef()
	Local oModel        := NIL
    Local oStPai        := FWFormStruct(1, 'ZVE')
    Local oStFilho      := FWFormStruct(1, 'ZVI')
    Local aRelFilho     := {}

    oModel := MPFormModel():New("FATI01",/*Pre-Validacao*/, /* {|| zVldModel(oModel) } */ /*Pos-Validacao*/,/* bVldCom */,/*Cancel*/)
    //Criando o FormModel, adicionando o Cabeçalho e Grid
    oModel:AddFields('ZVEMASTER',/*cOwner*/ ,oStPai)

    //Criando as grids dos filhos
    oModel:AddGrid('ZVIFILHO','ZVEMASTER',oStFilho, { |oModelGrid, nLine,cAction, cField| VAFATI01LPRE(oModelGrid, nLine, cAction, cField) } ) // ,;
   
	oStFilho:AddField('Gerar', ' ', 'Gerar', 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, ".F."))

    AAdd(aRelFilho,{'ZVI_FILIAL','ZVE_FILIAL'})
    AAdd(aRelFilho,{'ZVI_CODIGO','ZVE_CODIGO'})

	oModel:SetRelation('ZVIFILHO',aRelFilho,ZVI->(IndexKey(1)))
    oModel:GetModel('ZVIFILHO'):SetUniqueLine({'ZVI_FILIAL','ZVI_CODIGO','ZVI_ITEM'})
    
	oModel:SetPrimaryKey({'ZVI_FILIAL'+'ZVI_CODIGO'+'ZVI_ITEM'})
	
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

	Iif(!Inclui,Posicione('SA1',1,FWxFilial("SA1")+ZVE->ZVE_CODCLI+ZVE->ZVE_LOJCLI,'A1_COND'),"")
	
	oStFilho:AddField( 'Gerar','01','Gerar','Gerar',, 'Check')
	
	oView:SetModel(oModel)

    //ADICIONANDO OS CAMPOS DO CABEÇALHO
	oView:AddField("VIEW_CAB" , oStPai  , "ZVEMASTER")
    
	//GRID DOS FILHOS
    oView:AddGrid('VIEWFILHO', oStFilho , 'ZVIFILHO')

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

	oView:AddUserButton( 'Gerar Pedido (F10)' 	,'', {|oView| GeraPed()} )
	oView:AddUserButton( 'Processar NPK'      	,'', {|oView| ProcessaNPK()} )
	
 	SetKey( VK_F10, {|oView| GeraPed()} )

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk( { |oView| .T. } )

	oStFilho:RemoveField('ZVI_FILIAL')
	//oStFilho:RemoveField('ZVI_CODIGO')
	oStFilho:RemoveField('ZVI_CHVZPB')

Return oView

User Function FATI01()
	Local aParam 	:= PARAMIXB
	Local xRet 		:= .T.
	Local oObj 		:= ''
	Local cIdPonto 	:= ''
	Local lUser		:= lower(cUserName) $ GETMV("MV_FATI01A")
	Local cIdModel	:= ''
    Local nOper     := 0
    Local cCampo    := ''
    Local cTipo     := ''
	Local cQry 		:= ""
	Local aArea
	Local nCount

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		
		if cIdPonto == 'MODELVLDACTIVE'
			lGeraPed := .F.

			if  oObj:nOperation == 3 .and. !lUser	// Usuários nesse parametro tem permissão de incluir
				Aviso('Atenção', 'Usuário sem permissão para incluir contrato', {'OK'}, 03)
				xRet := .F.							// Novos Registros
			elseif  oObj:nOperation == 4
				aArea := GetArea()

				cQry := "select *  " + CRLF 
				cQry += "     from "+RetSqlName("ZVI")+" ZVI  " + CRLF 
				cQry += "	 join "+RetSqlName("ZVE")+" ZVE ON " + CRLF 
				cQry += "	      ZVE_FILIAL = ZVI_FILIAL " + CRLF 
				cQry += "	  AND ZVE_CODIGO = ZVI_CODIGO " + CRLF 
				cQry += "	  AND ZVE.D_E_L_E_T_ =' ' " + CRLF
				cQry += "	where ZVI_NF <> ' '  " + CRLF
				cQry += "	  AND ZVI_CODIGO = '"+ZVE->ZVE_CODIGO+"' " + CRLF 
				cQry += "	  AND ZVI_SERINF <> ' '  " + CRLF 
				cQry += "	  AND ZVI_DTEMIS <> ' '  " + CRLF 
				cQry += "	  AND ZVI.D_E_L_E_T_ = ' '  " + CRLF 
				cQry += "      AND ZVI.D_E_L_E_T_ =' '  " + CRLF 
				cQry += "	  AND ZVI.ZVI_FILIAL + ZVE_CODCLI + ZVE_LOJCLI + ZVI_NF + ZVI_SERINF + ZVI_NUMSC5 IN ( " + CRLF 
				cQry += "	      SELECT D2_FILIAL + D2_CLIENTE + D2_LOJA + D2_DOC + D2_SERIE + D2_PEDIDO " + CRLF 
				cQry += "		    FROM "+RetSqlName("SD2")+" SD2 " + CRLF 
				cQry += "		   WHERE SD2.D2_FILIAL = ZVI_FILIAL  " + CRLF 
				cQry += "		     AND SD2.D2_CLIENTE = ZVE_CODCLI " + CRLF 
				cQry += "			 AND SD2.D2_LOJA = ZVE_LOJCLI " + CRLF 
				cQry += "			 AND SD2.D2_DOC = ZVI.ZVI_NF " + CRLF 
				cQry += "			 AND SD2.D2_SERIE = ZVI_SERINF " + CRLF 
				cQry += "			 AND SD2.D2_PEDIDO = ZVI_NUMSC5 " + CRLF 
				cQry += "			 AND SD2.D_E_L_E_T_ <> ' ' -- FILTRAR NFS EXCLUIDAS " + CRLF 
				cQry += "			 ) " + CRLF 

				MpSysOpenQuery(cQry, "TMP")

				while !TMP->(EOF())
					ZVI->(DBSELECTAREA( "ZVI" ))
					ZVI->(DBSETORDER( 3 ))
					//ZVI_FILIAL+ZVI_CODIGO+ZVI_ITEM
				
					if ZVI->(DbSeek(FwxFilial("ZVI")+TMP->ZVI_CODIGO+TMP->ZVI_ITEM))
						
						aCabPV  := {{"C5_NUM"    , ZVI->ZVI_NUMSC5   , Nil},;
									{"C5_TIPO"   , "N"         		 , Nil},;
									{"C5_CLIENTE", TMP->ZVE_CODCLI 	 , Nil},;
									{"C5_LOJACLI", TMP->ZVE_LOJCLI	 , Nil},;
									{"C5_LOJAENT", TMP->ZVE_LOJCLI	 , Nil},;
									{"C5_CONDPAG"  , ZVI->ZVI_CONPAD , NIL}}

						aItemPV :=  { {"C6_NUM"    	, ZVI->ZVI_NUMSC5           , Nil},;
										{"C6_ITEM"   	, '01'						, Nil},;
										{"C6_PRODUTO"	, ZVI->ZVI_PRODUT        	, Nil},;
										{"C6_QTDVEN" 	, ZVI->ZVI_QUANT         	, Nil},;
										{"C6_PRCVEN" 	, ZVI->ZVI_VLRPTA / 1000    , Nil},;
										{"C6_VALOR"  	, ZVI->ZVI_VALOR			, Nil},;
										{"C6_TES"    	, ZVI->ZVI_TES				, Nil}}
										
						lMsErroAuto := .F.
							while !LockByName("ExecSC5Auto"+ ZVI->ZVI_NUMSC5, .t., .f.)
								Sleep(500)
							end
								MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItemPV,5)
							UnlockByName("ExecSC5Auto"+ZVI->ZVI_NUMSC5)
							
							If lMSErroAuto
								MostraErro()
								aErroAuto := GetAutoGRLog()
								For nCount := 1 To Len(aErroAuto)
									cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
									ConOut(cLogErro)
									Alert(cLogErro)
								Next nCount
								DisarmTransaction()
							ENDIF 


						RECLOCK( "ZVI", .F. )
							ZVI->(DBDELETE())
						ZVI->(MSUNLOCK())

						MsgAlert( "A linha com o pedido [ "+ZVI->ZVI_NUMSC5+" ] foi excluida, pois a nota foi cancelada.", "Atenção...")
						TMP->(DBSKIP())
					Endif
				ENDDO

				TMP->(DBCLOSEAREA(  ))
				FWRestArea(aArea)
			endif
			
		elseif cIdPonto == 'MODELCANCEL'
			if lGeraPed
				Aviso('Atenção', 'Pedido de venda gerado. Possível sair apenas salvando', {'OK'}, 03)
				xRet := .F.
			endif
 		elseif cIdPonto == 'MODELPRE'
            nOper  := oObj:nOperation
			if nOper == 3
				if !lUser
					xRet := .F.
				endif
			endif 
				
		ElseIf cIdPonto == "FORMPRE"
            nOper  := oObj:GetModel(cIdModel):nOperation
            cTipo  := aParam[4]
            cCampo := aParam[5]

			if cIdModel == 'ZVEMASTER'
				If nOper == 4
					If cTipo == "SETVALUE" .And. SubStr(Alltrim(cCampo),1,3) == "ZVE" .And. !lUser 
						Aviso('Atenção', 'Usuário sem permissão para alterar cabeçalho.', {'OK'}, 03)
						xRet := .F.
					EndIf
				EndIf
            EndIf
		elseif cIdPonto == ''			
		endif
	endif
Return xRet
/* Função para criar Botão Select - "MarkBrowse MVC" */
Static Function criaButtonSel(oPanel,oOtherObject)
    TButton():New( 01, 10, "Selecionar Todos",oPanel,{|| SelGrid(oOtherObject)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
Return

/* 05-2022 Igor Oliveira 
	Nao permite apagar linhas com pedido de venda gerado */
Static Function VAFATI01LPRE(oModelGrid, nLinha, cAcao, cCampo)
	Local lRet		:= .T.
	Local cQry 		:= " "
	Local aArea 	:= GetArea()
	Local cAliasQry := ""

	// Valida se pode ou não apagar uma linha do Grid
	If cAcao == 'DELETE' 
		if !Empty(oModelGrid:GetValue("ZVI_NUMSC5"))
			cQry := " select D_E_L_E_T_ as del" + CRLF
			cQry += " from "+RetSqlName("SD2")+" " + CRLF
			cQry += " where D2_DOC = '"+ALLTRIM(oModelGrid:GetValue("ZVI_NF"))+"'" + CRLF
			cQry += " and D2_SERIE = '"+ALLTRIM(oModelGrid:GetValue("ZVI_SERINF"))+"'" + CRLF

			cAliasQry := MpSysOpenQuery(cQry)
			
			If ALLTRIM((cAliasQry)->del) == "*"
				oModelGrid:SetValue("ZVI_STATUS","C")
			ELSE
				lRet := .F.
				Help( ,, 'Help',, 'Para alterar o Status desse item, cancele a NF e o Pedido.' + CRLF +; 
						'Você esta na linha ' + Alltrim( Str( nLinha ) ) + CRLF +;
						'No Item ' + cValtoChar(oModelGrid:GetValue("ZVI_ITEM")) , 1, 0 )
			EndIf
			( cAliasQry )->( dbCloseArea() )
		ENDIF
	EndIf
	RestArea(aArea)

Return lRet

User Function zQtdGat()
	Local aArea      := GetArea()
	Local oModelDad  := FWModelActive()
	Local oModelGrid := oModelDad:GetModel('ZVIFILHO')

	DbSelectArea('ZPB')
	ZPB->(DbSetOrder(1))

	If ZPB->( DbSeek( FWxFilial("ZPB") + Left(_cChaveZPB,8) + Right(_cChaveZPB,6)))
		oModelGrid:SetValue('ZVI_DTPES' , ZPB->ZPB_DATAF)
		oModelGrid:SetValue('ZVI_CODZPB', ZPB->ZPB_CODIGO)
	EndIf
	RestArea(aArea)
RETURN

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
/*
	Gerar Pedido de venda
	04/2023
	Igor Oliveira
*/
Static Function GeraPed()
	Local nOpcX := 3

	FAT01Ped(nOpcX)
Return

Static Function FAT01Ped(nOpcE)
	Local aArea        	:= GetArea()
	Local oView			:= FWViewActive()
	Local oModel  	   	:= FWModelActive()
	Local oModelDad  	:= oModel:GetModel('ZVEMASTER')
	Local oModelGrid 	:= oModel:GetModel('ZVIFILHO')
	Local nOpc  		:= oModel:GetOperation()
	Local nI 
    Local lRet          := .T.
    Local cTimeINI      := Time()
	Local nLine

	SA1->( DbSetOrder(1) )
	If SA1->( DbSeek( FWxFilial("SA1") + oModelDad:GetValue("ZVE_CODCLI") + oModelDad:GetValue("ZVE_LOJCLI")))
		
		if oModelGrid:SeekLine({{"Gerar",  .T.}})
			if oModelGrid:GetLine() < oModelGrid:GetQtdLine()
				for nI := oModelGrid:GetLine() to oModelGrid:GetQtdLine()
					if oModelGrid:GetValue("Gerar")
						nLine := oModelGrid:GetLine()
						ExecSC5Auto(oModel,oModelDad, oModelGrid, oModelGrid:GetLine(),nOpcE)
					endif
				next nI
			else 
				ExecSC5Auto(oModel,oModelDad, oModelGrid, oModelGrid:GetLine(),nOpcE)
			endif
		else
			MsgAlert( "Nenhuma linha selecionada para gerar pedidos!!" ,"Atenção...")
			lRet := .F.
		ENDIF
	ENDIF

	If lower(cUserName) $ 'ioliveira'
		Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
	EndIf

	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf
	
	oView:Refresh()

	RestArea(aArea)
Return lRet

Static Function ExecSC5Auto(oModel,oModelDad, oModelGrid, nLine,nOpc)
    Local aAreaZ            := GetArea()
	Local lErro             := .F.
	Local nCount            := 0
    Local aErroAuto         := {}
	Local aCabPV            := {}
	Local aItemPV           := {}
	Local nValor 
	Local cValor

    Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .F.

    DbSelectArea('ZVI')
	ZVI->(DbSetOrder(1))
    
    oModelGrid:GoLine(nLine)
    
    IF	oModelGrid:GetValue("ZVI_TRANSP") == "1"
        cFrete := "R"
        cTransp := oModelDad:GetValue("ZVE_CTRANV")
    else
        cFrete := "F"
        cTransp := oModelDad:GetValue("ZVE_CTRANC")
    ENDIF
            
    If !Empty(oModelGrid:GetValue("ZVI_CODZPB"))

        DbSelectArea('ZPB')
        ZPB->(DbSetOrder(2))
    
        If  nOpc == 3
            cNumPed := U_fChvITEM( "SC5", , "C5_NUM" )
			IF !Empty(oModelGrid:GetValue("ZVI_NUMSC5"))
				MsgAlert( "Pedido de Venda no Item [ " + cValtoChar(oModelGrid:GetValue("ZVI_ITEM")) + " ] não pode ser gerado duas vezes" + CRLF +;
				"Pedido [ "+oModelGrid:GetValue("ZVI_NUMSC5")+" ] Gerado anteriormente!!! ", "Atenção...")
				Return
			endif 
        ElseIf nOpc == 5
			IF Empty(oModelGrid:GetValue("ZVI_NUMSC5"))
            	MsgAlert( "Pedido de Venda no Item [ " + cValtoChar(oModelGrid:GetValue("ZVI_ITEM")) + " ] ainda não foi gerado." + CRLF ,"Atenção...")
            	Return
        	EndIf

			cNumPed := oModelGrid:GetValue("ZVI_NUMSC5")

        EndIf 
		ZPB->( DbSeek( FWxFilial("ZPB") + oModelGrid:GetValue("ZVI_PLACA") +;
				AllTrim(DToS(oModelGrid:GetValue("ZVI_DTPES"))) + oModelGrid:GetValue("ZVI_CODZPB")))

		cPlaca := "PLACA: " + oModelGrid:GetValue("ZVI_PLACA") +;
					" PESAGEM: " +  AllTrim(DToC(oModelGrid:GetValue("ZVI_DTPES"))) +;
					"-" + oModelGrid:GetValue("ZVI_CODZPB") +;
					" MOTORISTA: " + ZPB->ZPB_NOMMOT + ""
            
		aCabPV  := {}
		aItemPV := {}

		aCabPV  := {{"C5_NUM"    , cNumPed     						 				, Nil},;
					{"C5_TIPO"   , "N"         						 				, Nil},;
					{"C5_MENPAD" , oModelDad:GetValue("ZVE_MENPAD")              	, Nil},;
					{"C5_CLIENTE", SA1->A1_COD 						 				, Nil},;
					{"C5_LOJACLI", SA1->A1_LOJA						 				, Nil},;
					{"C5_CLIENT" , SA1->A1_COD 						 				, Nil},;
					{"C5_LOJAENT", SA1->A1_LOJA						 				, Nil},;
					{"C5_TIPOCLI", "F"								 				, Nil},;
					{"C5_NATUREZ", SA1->A1_NATUREZ					 				, Nil},;
					{"C5_TPFRETE", cFrete							 				, Nil},;
					{"C5_FRETE"	 , oModelGrid:GetValue("ZVI_FRETE") 				, Nil},;
					{"C5_TRANSP" , cTransp							 				, Nil},;
					{"C5_MENNOTA", cPlaca							 				, Nil},;
					{"C5_CONDPAG", oModelGrid:GetValue("ZVI_CONPAD") 				, Nil},;
					{"C5_PESOL"  , oModelGrid:GetValue("ZVI_QUANT") 				, NIL}}

		nDesconto := (100 * oModelGrid:GetValue("ZVI_VALDES")) / oModelGrid:GetValue("ZVI_VALOR")

		nPrcVen	:= (oModelGrid:GetValue("ZVI_VLRPTA") / 1000)

		cValor := lTrim(Str(nPrcVen * oModelGrid:GetValue("ZVI_QUANT")))
		
		if Len((SubStr(cValor,At(".", cValor)+1,9))) > 2
			nValor := ROUND(nPrcVen * oModelGrid:GetValue("ZVI_QUANT"),2)
		else 
			nValor := nPrcVen * oModelGrid:GetValue("ZVI_QUANT")
		endif
		
		AADD(aItemPV, { {"C6_NUM"    	, cNumPed                    													 								, Nil},;
						{"C6_ITEM"   	, '01'							          										 								, Nil},;
						{"C6_PRODUTO"	, oModelGrid:GetValue("ZVI_PRODUT")        										 								, Nil},;
						{"C6_QTDVEN" 	, oModelGrid:GetValue("ZVI_QUANT")         										 								, Nil},;
						{"C6_UM" 	    , Posicione("SB1",1,FWxFilial("SB1") + oModelGrid:GetValue("ZVI_PRODUT"), "B1_UM")  							, Nil},;
						{"C6_PRCVEN" 	, nPrcVen        																 								, Nil},;
						{"C6_VALOR"  	, nValor																										, Nil},;
						{"C6_VALDESC" 	, NOROUND((oModelGrid:GetValue("ZVI_QUANT") * (oModelGrid:GetValue("ZVI_VLRPTA") / 1000)) * (nDesconto/100),2)  , Nil},;
						{"C6_DESCONT" 	, NOROUND(nDesconto,2)   																						, Nil},;
						{"C6_TES"    	, oModelGrid:GetValue("ZVI_TES")												 								, Nil}})
		
		lMsErroAuto := .F.
		while !LockByName("ExecSC5Auto"+ cNumPed, .t., .f.)
			Sleep(500)
		end
			MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItemPV,nOpc)
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

			If lErro := LIBeFaturar( cFilEnt,  @cPedVen, @cE1HIST)
				DisarmTransaction()
			Else
				MsgInfo( "Pedido de Venda [" + cNumPed + "] gerado com sucesso !!!" + CRLF +;
				"Nota Fiscal [" + SF2->F2_FILIAL+"-"+ AllTrim(SF2->F2_DOC)+"-"+AllTrim(SF2->F2_SERIE) + "] faturada com sucesso" )

				oModelGrid:SetValue('ZVI_NUMSC5'  , StrZero(Val(cPedVen),TamSX3('ZVI_NUMSC5')[1]))
				oModelGrid:SetValue('ZVI_NF'	  , SF2->F2_DOC)
				oModelGrid:SetValue('ZVI_SERINF'  , SF2->F2_SERIE)
				oModelGrid:SetValue('ZVI_DTEMIS'  , dDataBase)
				oModelGrid:SetValue('ZVI_STATUS'  , "F")
				oModelDad:LoadValue("ZVE_QTDEA", oModelDad:GetValue("ZVE_QTDEA")+oModelGrid:GetValue("ZVI_QUANT"))

				lGeraPed := .T.
				
				oModel:CommitData()

			EndIf
		EndIf
	else
		MsgAlert( "Pedido de Venda no Item [ " + cValtoChar(oModelGrid:GetValue("ZVI_ITEM")) + " ] não pode ser gerado !!!" + CRLF +;
				"Preencha os campos [ Cod. Pesagem, Placa e Transporte ]", "Atenção...")
	ENDIF
    
	RestArea(aAreaZ)
Return lMSErroAuto
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
	If SA1->(DbSeek( FWxFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI )) .and. SA1->A1_RISCO <> 'A'
		RecLock('SA1' , .F. )
			SA1->A1_RISCO := 'A'
		SA1->( MsUnLock() )
	EndIf
	
	lErro := !U_EstLibPV( cPedVen  ) // lIBERACAO DE ESTOQUE
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

/* I.O 04-05-2022
	Gatilho para atualizar Desconto A partir da ZDE */
User Function GetUmiD()//(_cAlias, _cCampo)
	Local aArea		 	:= GetArea()
	Local oView 	    := FWViewActive()
	Local oModel  		:= FWModelActive()
	Local oModelDad 	:= oModel:GetModel('ZVEMASTER')
	Local oModelGrid 	:= oModel:GetModel('ZVIFILHO')
	Local nPerc
	
	DbSelectArea('ZDE')
	ZDE->(DbSetOrder(4))
	
	lUmi := .T.
	nUmidade := oModelGrid:GetValue('ZVI_PERUMI')
	IF ZDE->(DbSeek(FWxFilial("ZDE") + oModelDad:GetValue("ZVE_TDESMI") + "1"))
		While !ZDE -> (EOF()) 
			IF (nUmidade >= ZDE->ZDE_TOLDE .and. nUmidade <= ZDE->ZDE_TOLATE .and. lUmi)
				nPerc := oModelGrid:GetValue('ZVI_VALOR') + ( (oModelGrid:GetValue('ZVI_VLRPTA') * (ZDE->ZDE_PERCE / 100)) ) * (oModelGrid:GetValue('ZVI_QUANT') / 1000) - oModelGrid:GetValue('ZVI_VALOR')
					oModelGrid:SetValue('ZVI_PESLU', oModelGrid:GetValue('ZVI_QUANT') + oModelGrid:GetValue('ZVI_QUANT') * (ZDE->ZDE_PERCE / 100))
					oModelGrid:SetValue("ZVI_TDESMI",  ZDE->ZDE_PERCE)
				exit
			ENDIF
			ZDE->(DBSkip())
		ENDDO
	ENDIF

	oView:Refresh()
	RestArea(aArea)
Return nPerc

User Function GetNpkD()
	Local aArea		 	:= GetArea()
	Local oView 	 	:= FWViewActive()
	Local oModel  		:= FWModelActive()
	Local oModelDad  	:= oModel:GetModel('ZVEMASTER')
	Local oModelGrid 	:= oModel:GetModel('ZVIFILHO')
		
	DbSelectArea('ZDE')
	ZDE->(DbSetOrder(4))
	lNpk := .T.
	nPerNPK	 := oModelGrid:GetValue('ZVI_PERNPK')
	IF ZDE->(DbSeek(FWxFilial("ZDE") + oModelDad:GetValue("ZVE_TDESMI") + "2"))
		While !ZDE -> (EOF())
			if (nPerNPK >= ZDE->ZDE_TOLDE .and. nPerNPK <= ZDE->ZDE_TOLATE .and. lNpk )
				nPerc := oModelGrid:GetValue('ZVI_VALOR') + (( oModelGrid:GetValue('ZVI_VLRPTA') * (ZDE->ZDE_PERCE / 100))) * (oModelGrid:GetValue('ZVI_QUANT') / 1000) - oModelGrid:GetValue('ZVI_VALOR')
				oModelGrid:SetValue('ZVI_PESLQF', oModelGrid:GetValue('ZVI_QUANT') + oModelGrid:GetValue('ZVI_QUANT') * (ZDE->ZDE_PERCE / 100))
				oModelGrid:SetValue("ZVI_TDESNP",  ZDE->ZDE_PERCE)
				exit
			ENDIF
			ZDE->(DBSkip())
		ENDDO
	ENDIF
	oView:Refresh()
	RestArea(aArea)
RETURN nPerc

User Function FI01Perc()
	Local aArea		 	:= GetArea()
	Local oModel  		:= FWModelActive()
	Local oModelDad  	:= oModel:GetModel('ZVEMASTER')
	Local lRet := .F.
	
	if Empty(oModelDad:GetValue("ZVE_TDESMI"))
		oModel:SetErrorMessage("","","","","HELP", 'Codigo Desconto vazio!', "Informe o Codigo da tabela de desconto no cabeçalho!!" )
		lRet := .F.
	else 
		lRet := .T.
	ENDIF
	RestArea(aArea)
RETURN lRet

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
	Local oModel  	 := FWModelActive()
	Local oModelGrid := oModel:GetModel('ZVIFILHO')

	_cQry := " Select   ZPB_FILIAL" + CRLF 
	_cQry += "		,  ZPB_DATA " + CRLF 
	_cQry += "		,  ZPB_HORAF " + CRLF 
	_cQry += "		,  ZPB_CODIGO " + CRLF 
	_cQry += "		,  ZPB_CODFOR " + CRLF 
	_cQry += "		,  ZPB_NOMFOR " + CRLF 
	_cQry += "		,  ZPB_PLACA  " + CRLF 
	_cQry += "		,  ZPB_PESOE  " + CRLF 
	_cQry += "		,  ZPB_PESOS  " + CRLF 
	_cQry += "		,  ZPB_PESOL " + CRLF 
	_cQry += "		,  CASE WHEN DA3_PLACA IS NOT NULL THEN '1' ELSE '2' END TRANSPORTE" + CRLF 
	_cQry += "	FROM "+RetSqlName("ZPB")+" ZPB " + CRLF 
	_cQry += "		LEFT JOIN "+RetSqlName("DA3")+" DA3 ON DA3_FILIAL = ' ' " + CRLF 
	_cQry += "			AND RTRIM(REPLACE(ZPB_PLACA,'-','')) = IIF(SUBSTRING(DA3_COD,4,1)='-',RTRIM(REPLACE(DA3_COD,'-','')),RTRIM(DA3_COD))" + CRLF 
	_cQry += "			AND DA3.D_E_L_E_T_ = ' '  " + CRLF 
	_cQry += "	WHERE   ZPB_FILIAL = '"+FwxFilial('ZPB')+"'" + CRLF 
	_cQry += "		AND ZPB_DATA >= DATEADD(DAY,-5, '"+ DtoS(dDataBase)+"')" + CRLF
	_cQry += "		AND ZPB_PRODUT IN ('"+AllTrim(oModelGrid:GetValue("ZVI_PRODUT"))+"')" + CRLF
	_cQry += "		AND ZPB_PESOE > 0" + CRLF
	_cQry += "		AND ZPB_PESOS > 0" + CRLF
	_cQry += "		AND ZPB_FILIAL + ZPB_DATA + ZPB_DATAF + ZPB_CODIGO  NOT IN (SELECT ZVI_FILIAL + ZVI_DTPES + ZPB_DATAF + ZVI_CODZPB    " + CRLF 
	_cQry += "																	FROM ZVI010 ZVI  " + CRLF 
	_cQry += "																	LEFT JOIN "+RetSqlName("ZPB")+" ZPB ON ZVI_FILIAL = ZVI_FILIAL" + CRLF 
	_cQry += "																		AND ZPB_DATAF  = ZVI_DTPES" + CRLF 
	_cQry += "																		AND ZPB_CODIGO = ZVI_CODZPB" + CRLF 
	_cQry += "																		AND ZPB_PLACA = ZVI_PLACA" + CRLF 
	_cQry += "																		AND ZPB.D_E_L_E_T_ = ''" + CRLF 
	_cQry += "																	WHERE ZVI_NUMSC5 <> ''" + CRLF 
	_cQry += "																		AND ZVI_STATUS = 'F'" + CRLF 
	_cQry += "																		AND ZVI.D_E_L_E_T_ = '' ) " + CRLF 
	_cQry += "		AND ZPB.D_E_L_E_T_ = ''" + CRLF 
	_cQry += "		ORDER BY 2 DESC " + CRLF 

 	If lower(cUserName) $ 'bernardo,ioliveira,atoshio'
		MemoWrite(StrTran(cArquivo,".xml","")+"_VAFATI01_.sql" , _cQry)
	EndIf
    // _cQry := ChangeQuery(_cQry)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAlias,.T.,.T.)

    While !(cAlias)->(EOF())
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
        aAdd(aCpos,{"","","","","","","","","",""})
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
		_cQry := " SELECT ZVI_CODIGO = '" + oModelGrid:GetValue("ZVI_CODIGO") +"'" + CRLF
		_cQry += "				, ZVI_ITEM" + CRLF
		_cQry += "				, ZVI_QUANT" + CRLF
		_cQry += "				, ZVI_NF" + CRLF
		_cQry += "				, ZVI_DTEMIS" + CRLF
		_cQry += "				, (ZNP_APUVA+ZNP_APUCLI)/2 PERCENTUAL" + CRLF
		_cQry += "      FROM " + RetSqlName("ZVI") + " ZVI" + CRLF
		_cQry += " LEFT JOIN " + RetSqlName("ZNP") + " ZNP ON" + CRLF
		_cQry += "           ZNP.ZNP_FILIAL = '" + FWxFilial("ZNP") + "' " + CRLF
		_cQry += "       AND ZVI.ZVI_DTEMIS BETWEEN ZNP_DTINI AND ZNP_DTATE" + CRLF
		_cQry += " 	  AND ZNP.D_E_L_E_T_ = ' '" + CRLF
		_cQry += " 	WHERE ZVI.ZVI_FILIAL = '" + FWxFilial("ZVI") + "'" + CRLF
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
				IF ZDE->(DbSeek(FWxFilial("ZDE") + oModelGrid:GetValue("ZVI_TDESMI") + "2"))
					While !ZDE -> (EOF())
						if (nPerNPK >= ZDE->ZDE_TOLDE .and. nPerNPK <= ZDE->ZDE_TOLATE )
							nPerc := ZDE->ZDE_PERCE
							
							RecLock('ZVI', lRecLock := !DbSeek( FWxFilial("ZVI") + cValToChar(aCPos[nI][1]) + cValToChar(aCPos[nI][2])))
							
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
	ENDIF
RETURN aCPos

User Function fX3RELI01()
	Local oModelDad  := FWModelActive()
	Local oModelGrid := oModelDad:GetModel('ZVIFILHO')
	Local nLinha 	 := 0
	Local cTabDesc   := ""
	Local cCampo 	 := SubS( ReadVar(), At(">", ReadVar())+1 )

	if oModelDad:GetOperation() == 3
		if TamSX3(cCampo)[3] == 'N'
			cTabDesc := 0
		elseif TamSX3(cCampo)[3] == 'D'
			cTabDesc := cToD("//")
		endif
	else
		nLinha := oModelGrid:GetQtdLine()
		if nLinha > 1
			oModelGrid:Goline(nLinha-1)
			cTabDesc :=	oModelGrid:GetValue(cCampo)
		else
			oModelGrid:Goline(nLinha)
			cTabDesc :=	oModelGrid:GetValue(cCampo)
			//cTabDesc := ""
		ENDIf
	endif
	

Return cTabDesc

//Gatilho para prencher Grid
//Usado no Campo ZVE_PRODUT
User Function I01PROD()
	Local oModelDad  := FWModelActive()
	Local oModelGrid := oModelDad:GetModel('ZVIFILHO')
	Local cProd 	 := ALLTRIM(&(ReadVar()))
	
	oModelGrid:GoLine(1)

	oModelGrid:SetValue("ZVI_CODIGO"   , oModelDad:GetValue("ZVE_COD"))
	oModelGrid:SetValue("ZVI_PRODUT", cProd)
	oModelGrid:SetValue("ZVI_PRODES", ALLTRIM(Posicione("SB1",1,FwxFilial("SB1")+cProd,"B1_DESC")))

Return cProd
//Usado no Campo ZVE_PRODUT
//Validação do Campo
User Function   I01PRVL()
	Local oModelDad  	:= FWModelActive()
	Local oModelGrid 	:= oModelDad:GetModel('ZVIFILHO')
	Local lRet 			:= .T. 

	oModelGrid:Goline(1)

	if !EMPTY(oModelGrid:GetValue("ZVI_NUMSC5"))
		Aviso('Atenção', 'Não permitido alterar o produto após inclusão de itens no contrato', {'OK'}, 03)
		lRet := .F.
	endif

Return lRet 
