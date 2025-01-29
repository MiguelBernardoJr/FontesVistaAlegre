#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "TopConn.ch"

Static cTitulo := "Histórico Integração API"
User Function VAFINI01()
	local aArea     := GetArea()
	Local cFunBkp   := ""
	Local aParamBox	:= {}
	
	Local cLoad     := ProcName(1) // Nome do perfil se caso for carregar
	Local lCanSave  := .T. // Salvar os dados informados nos parâmetros por perfil
	Local lUserSave := .T. // Configuração por usuário
	Local cQry 		:= ""
	Local nI 		
	Local aFiltro
	Local cFiltro	:= ""

	Private oBtn	:= Array(3)
	Private oTfSay  := TFont():New('ARIAL',,22,,.T.)
	Private oTfTot  := TFont():New('ARIAL',,24,,.T.)
	Private oScTotal 	:= nil
	Private oSnTotal 	:= nil
	Private oScTitulo 	:= nil
	Private oSnTitulo 	:= nil
	Private aParametros	:= {}
	Private cAlias 		:= GetNextAlias()

	aAdd(aParamBox,{1 ,"EMISSAO DE" , dDataBase, "@D","","","",50,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"EMISSAO ATE" , dDataBase, "@D","","","",50,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"STATUS [Separado por vírgula]",Space(100),"","","","",100,.F.}) // Tipo caractere

	if ParamBox(aParamBox,"Parâmetros...",@aParametros, /* [ bOk ] */, /* [ aButtons ] */, /* [ lCentered ] */, /* [ nPosX ] */, /* [ nPosy ] */, /* [ oDlgWizard ] */,  cLoad, lCanSave, lUserSave )
		if Len(aFiltro := StrToKarr(AllTrim(aParametros[3]),',')) > 0
			For nI := 1 to Len(aFiltro)
				cFiltro += "'"+aFiltro[nI]+"'" + iif(nI<Len(aFiltro),',','')
			next 
		endif 

		cQry := " select *" + CRLF
		cQry += " from "+RetSqlName("SE2")+"  " + CRLF
		cQry += " WHERE D_E_L_E_T_ = '' " + CRLF
		cQry += " AND E2_EMISSAO BETWEEN '"+dToS(aParametros[1])+"' AND '"+dToS(aParametros[2])+"' " + CRLF
		
		if cFiltro != "" //.and. aParametros[4] == 1
			cQry += " AND  E2_XSTAPI IN ("+cFiltro+") " + CRLF
		else 
			cQry += " AND  E2_XSTAPI <> '  ' " + CRLF
		endif

		MpSysOpenQry(cQry, cAlias)
		
		if (cAlias)->(EOF())
			MsgInfo("Não há dados com os parâmetros informados!")
		else
			cFunBkp := FunName()
			
			SetFunName("VAFINI01")
				FWExecView('Alterar', 'VAFINI01', MODEL_OPERATION_UPDATE,,{||.T.})
			SetFunName(cFunBkp)

		endif

		(cAlias)->(DbCloseArea())
	endif 

    RestArea(aArea)
Return

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE 'Chamar API' 	   ACTION 'U_FI01CAP()'      OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' 	   ACTION 'VIEWDEF.VAFINI01' OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE 'Alterar'	 	   ACTION 'VIEWDEF.VAFINI01' OPERATION 4 ACCESS 0
Return aRotina

Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStField 		:= nil
	Local oStSE2 		:= FWFormStruct(1, 'SE2')
	Local oStZE2 		:= FWFormStruct(1, 'ZE2')
	Local oStSE5 		:= FWFormStruct(1, 'SE5')
 	Local aCpSE5		:= {}
	Local aZE2Rel		:= {}
	Local aSE5Rel		:= {}
	Local nI

    oStField := FWFormModelStruct():New()

    oStField:addTable("", {"XX_TST"}, "Filtro", {|| ""})
	oStField:AddField('TST', ' ', 'XX_TST', 'C', 1, 0, , , {}, .F.)

	oStSE5:AddField('OK' , ' ', 'OK' , 'L', 1, 0,  , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, ".F."))
	oStSE2:AddField('LEG', ' ', 'LEG', 'C', 50, 0,  , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "BR_BRANCO"))
	oStSE2:AddField('SEL', ' ', 'SEL', 'L', 1, 0, {|| VldSel()} , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, ".F."))

	aCpSE5 := oStSE5:aFields
	For nI := 1 to Len(aCpSE5)
		if oStSE5:aFields[nI][03] != 'OK'
			oStSE5:aFields[nI][08] := {|| .F.}
			oStSE5:aFields[nI][10] := .F.
		endif
	next nI
    
    //Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('FINI01')
	
	oModel:AddFields('FAKEM',/*cOwner*/   ,oStField, /* <bPre > */, /* <bPost > */, {|| LoadFake()}/* <bLoad > */)
	oModel:AddGrid('SE2DETAIL',"FAKEM"    ,oStSE2,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,{|oModel| LoadSE2(oModel)}/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	oModel:AddGrid('ZE2DETAIL','SE2DETAIL',oStZE2,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	oModel:AddGrid('SE5DETAIL','SE2DETAIL',oStSE5,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	
	oModel:GetModel('SE2DETAIL'):SetOptional(.T.)
	oModel:GetModel('ZE2DETAIL'):SetOptional(.T.)
	oModel:GetModel('SE5DETAIL'):SetOptional(.T.)

	aadd(aZE2Rel, {'ZE2_FILIAL' ,'E2_FILIAL' })
	aadd(aZE2Rel, {'ZE2_PREFIX' ,'E2_PREFIXO'})
	aadd(aZE2Rel, {'ZE2_NUM'    ,'E2_NUM'    })
	aadd(aZE2Rel, {'ZE2_PARCEL' ,'E2_PARCELA'})
	aadd(aZE2Rel, {'ZE2_TIPO'   ,'E2_TIPO'   })
	aadd(aZE2Rel, {'ZE2_FORNEC' ,'E2_FORNECE'})
	aadd(aZE2Rel, {'ZE2_LOJA'   ,'E2_LOJA'   })

	aadd(aSE5Rel, {'E5_FILIAL'  ,'E2_FILIAL' })
	aadd(aSE5Rel, {'E5_PREFIXO' ,'E2_PREFIXO'})
	aadd(aSE5Rel, {'E5_NUMERO'  ,'E2_NUM'    })
	aadd(aSE5Rel, {'E5_PARCELA' ,'E2_PARCELA'})
	aadd(aSE5Rel, {'E5_TIPO'    ,'E2_TIPO'   })
	aadd(aSE5Rel, {'E5_CLIFOR'  ,'E2_FORNECE'})
	aadd(aSE5Rel, {'E5_LOJA'    ,'E2_LOJA'   })

    oModel:SetRelation('ZE2DETAIL', aZE2Rel, ZE2->(IndexKey(1)))
    
    oModel:SetRelation('SE5DETAIL', aSE5Rel, SE5->(IndexKey(7)))
	
	oModel:SetPrimaryKey( {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"} )

	oModel:SetDescription(cTitulo)
	
	oModel:GetModel('SE2DETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('ZE2DETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('SE5DETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('SE2DETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('ZE2DETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('SE5DETAIL'):SetNoDeleteLine(.T.)

	oModel:GetModel('FAKEM'):SetDescription('Hide')
	oModel:GetModel('SE2DETAIL'):SetDescription('Titulos a Pagar')
	oModel:GetModel('ZE2DETAIL'):SetDescription('Log Integração')
	oModel:GetModel('SE5DETAIL'):SetDescription('Baixa de Titulos')

Return oModel
Static Function ViewDef()
	Local oView		    := Nil
	Local oModel	    := FWLoadModel("VAFINI01")
	Local oStField 		:= nil
	Local oStSE2 	    := FWFormStruct(2, 'SE2')
	Local oStZE2 	    := FWFormStruct(2, 'ZE2')
	Local oStSE5 	    := FWFormStruct(2, 'SE5')
    
	oStField := FWFormViewStruct():New()
    oStField:addField("XX_TST", "01" , "Fornecedor", "",, "C")

	oStSE5:AddField( 'OK' ,'01','OK' ,'OK' ,, 'Check')
	
	oStSE2:AddField( 'LEG','01','','',, 'C','@BMP',,'',.F.)
	oStSE2:AddField( 'SEL','02','','',, 'Check')

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField( 'CAB'       , oStField , 'FAKEM' )
	oView:AddGrid( 'VIEW_SE2'   , oStSE2 , 'SE2DETAIL' )
	oView:AddGrid( 'VIEW_ZE2'   , oStZE2 , 'ZE2DETAIL' )
	oView:AddGrid( 'VIEW_SE5'   , oStSE5 , 'SE5DETAIL' )
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('BOX_HIDE'  , 0 )
	oView:CreateHorizontalBox('BOX_SE2'  , 50 )
	oView:CreateHorizontalBox('BOX_GRID' , 50 )
	
    oView:CreateVerticalBox( 'BOX_ZE2', 50, 'BOX_GRID' )
    oView:CreateVerticalBox( 'BOX_BTN', 5 , 'BOX_GRID' )
    oView:CreateVerticalBox( 'BOX_DIR', 45, 'BOX_GRID' )

	oView:CreateHorizontalBox('BOX_SE5' , 90, 'BOX_DIR' )
	oView:CreateHorizontalBox('BOX_TOT' , 10, 'BOX_DIR' )  

	oView:AddOtherObject("TOTAL" ,{|o1Panel,o1OtherObject| CalcTot(o1Panel,o1OtherObject)})
	oView:AddOtherObject("BUTTON",{|o1Panel,o1OtherObject| CriaBtn(o1Panel,o1OtherObject)})
	
	//Amarrando a view com as box
	oView:SetOwnerView('CAB'	    ,'BOX_HIDE' )
	oView:SetOwnerView('BUTTON'		,'BOX_BTN'  )
	oView:SetOwnerView('VIEW_SE2'	,'BOX_SE2'  )
	oView:SetOwnerView('VIEW_ZE2'	,'BOX_ZE2'  )
	oView:SetOwnerView('VIEW_SE5'	,'BOX_SE5'  )
	oView:SetOwnerView('TOTAL'		,'BOX_TOT'  )

	oView:EnableTitleView('BUTTON'  ,'_________________________')
	oView:EnableTitleView('VIEW_SE2','Titulos a Pagar' )
	oView:EnableTitleView('VIEW_ZE2','Log Integração'  )
	oView:EnableTitleView('VIEW_SE5','Baixa de Titulos')

	oView:SetViewProperty("VIEW_SE2", "GRIDFILTER", {.T.})

	SetKey( VK_F5 , { || InverteSelecao() } )

Return oView

Static Function LoadFake()
Return {""}

Static Function LoadSE2(oModel)
    Local aArea     := FwGetArea()
    Local oStruct   := oModel:GetStruct()
    Local aData     := {}
    Local nI 
    Local aAux		:= oStruct:GetFields()

	While !(cAlias)->(EOF())
		aAdd(aData,{{(cALias)->R_E_C_N_O_},{}})
	
		For nI := 1 to Len(aAux)
			if !(aAux[nI][14])
				if aAux[nI][3] == 'LEG'
					if (cALias)->E2_XSTAPI = 'OK'
						aAdd(aData[Len(aData)][2],"BR_VERDE")
					else
						aAdd(aData[Len(aData)][2],"BR_VERMELHO")
					endif
				elseif aAux[nI][4] == 'C' .OR. aAux[nI][4] == 'N'
					aAdd(aData[Len(aData)][2],(cALias)->&(aAux[nI][3]))
				elseif aAux[nI][4] == 'D'
					aAdd(aData[Len(aData)][2],sToD((cALias)->&(aAux[nI][3])))
				elseif aAux[nI][4] == 'L' .and. aAux[nI][3] == 'SEL'
					aAdd(aData[Len(aData)][2],.F.)
				endif
			else //CAMPO VIRTUAL
				if aAux[nI][4] == 'C'
					aAdd(aData[Len(aData)][2],"")
				elseif aAux[nI][4] == 'D'
					aAdd(aData[Len(aData)][2],cToD("//"))
				elseif aAux[nI][4] == 'N'
					aAdd(aData[Len(aData)][2],0)
				endif
			endif
		Next nI

		(cAlias)->(DbSkip())
	endDo

    FwRestArea(aArea)
Return aData

Static Function CriaBtn(o1Panel,o1OtherObject)
	Local nWidth  := o1Panel:NCLIENTWIDTH / 2
	Local nHeight := o1Panel:NHEIGHT / 2
	
	@(nHeight - 75),nWidth - 10 BTNBMP oBtn[1]  RESOURCE "LBOK"		SIZE 25,25 ACTION InverteSelecao() OF o1Panel
	@(nHeight - 25),nWidth - 10 BTNBMP oBtn[2]  RESOURCE "PESQUISA" SIZE 25,25 ACTION Enviar() OF o1Panel
	@(nHeight + 25),nWidth - 10 BTNBMP oBtn[3]  RESOURCE "ENVIAR" 	SIZE 25,25 ACTION Consultar() OF o1Panel

	oBtn[1]:cToolTip := "Inverter Seleção"
	oBtn[2]:cToolTip := "Consultar"
	oBtn[3]:cToolTip := "Enviar"

Return

Static Function CalcTot(o1Panel,o1OtherObject)
	Local nWidth  := 0
	Local nHeight := 5
	
	oScTotal := TSay():New(nHeight ,nWidth     , {||''},o1Panel,,oTfSay,,,,.T.,CLR_BLACK,CLR_WHITE,200,30)
	oSnTotal := TSay():New(nHeight ,nWidth + 60, {||''},o1Panel,,oTfTot,,,,.T.,CLR_RED,CLR_WHITE,200,30)

	oScTitulo := TSay():New(nHeight ,nWidth + 180    , {||''},o1Panel,,oTfSay,,,,.T.,CLR_BLACK,CLR_WHITE,200,30)
	oSnTitulo := TSay():New(nHeight ,nWidth + 275, {||''},o1Panel,,oTfTot,,,,.T.,CLR_RED,CLR_WHITE,200,30)

Return

Static Function VldSel()
	Local oModel := FwModelActivate()
	Local oMSe2	 := oModel:GetModel("SE2DETAIL")
	Local oView	 := FWViewActive()
	Local lRet 	 := .t.
	Local nSoma  := 0
	Local nTitulos := 0
	Local aSaveLines 	:= FWSaveRows()
	Local cText 

	if oMSe2:GetValue("E2_XSTAPI") == 'OK'
				oModel:SetErrorMessage("","","","","Ação inválida", 'Titulo já foi pago', "É possível selecionar apenas titulos que não foram pagos")

		lRet := .F.
	else
		cText := StrTran(oSnTotal:cCaption,".","")
		cText := StrTran(cText,",",'.')

		if Val(cText) == 0
			if oMSe2:GetValue("SEL")
				oScTotal:SetText("Total a Pagar: ")
				oSnTotal:SetText(AllTrim(Transform(oMSe2:GetValue("E2_VALOR"),Alltrim(X3Picture("E2_VALOR")))))

				oScTitulo:SetText("Titulos selecionados: ")
				oSnTitulo:SetText("1")
			endif
		else
			if oMSe2:GetValue("SEL")
				nSoma := Val(cText) + oMSe2:GetValue("E2_VALOR")
				oScTotal:SetText("Total a Pagar: ")
				oSnTotal:SetText(AllTrim(Transform(nSoma,Alltrim(X3Picture("E2_VALOR")))))

				nTitulos := Val(oSnTitulo:cCaption) + 1
				oScTitulo:SetText("Titulos selecionados: ")
				oSnTitulo:SetText(AllTrim(Str(nTitulos)))
			else 
				nSoma := Val(cText) - oMSe2:GetValue("E2_VALOR") 
				oScTotal:SetText("Total a Pagar: ")
				oSnTotal:SetText(AllTrim(Transform(nSoma,Alltrim(X3Picture("E2_VALOR")))))

				nTitulos := Val(oSnTitulo:cCaption) -1
				oScTitulo:SetText("Titulos selecionados: ")
				oSnTitulo:SetText(AllTrim(Str(nTitulos)))
			endif
		endif
	endif
	FWRestRows(aSaveLines)
	oView:refresh()
Return lRet

Static Function InverteSelecao()
	Local oModel := FwModelActivate()
	Local oMSe2	 := oModel:GetModel("SE2DETAIL")
	Local oView	 := FWViewActive()
	Local nI
	Local aSaveLines 	:= FWSaveRows()
	Local nSoma  		:= 0
	Local nTitulos 		:= 0
	Local nTamGrid		:= oMSe2:Length()
	
	For nI := 1 to nTamGrid
		oMSe2:GoLine(nI)
		if oMSe2:GetValue("E2_XSTAPI") != 'OK'
			oMSe2:LoadValue("SEL",!oMSe2:GetValue("SEL"))
		endif
	next nI
	
	For nI := 1 to nTamGrid
		oMSe2:GoLine(nI)
		if oMSe2:GetValue("SEL")
			nSoma +=  oMSe2:GetValue("E2_VALOR")
			nTitulos++
		endif
	next nI

	if nSoma == 0
		oScTotal:SetText("")
		oSnTotal:SetText("")

		oScTitulo:SetText("")
		oSnTitulo:SetText("")
	else
		oScTotal:SetText("Total a Pagar: ")
		oSnTotal:SetText(AllTrim(Transform(nSoma,Alltrim(X3Picture("E2_VALOR")))))

		oScTitulo:SetText("Titulos selecionados: ")
		oSnTitulo:SetText(AllTrim(Str(nTitulos)))
	endif

	FWRestRows(aSaveLines)
	oView:refresh()
Return 
Static Function Enviar()
	Local oModel 	:= FwModelActivate()
	Local oMdlSE5	:= oModel:GetModel("SE5DETAIL")
	Local nI
	Local cChave 	:= ""

	For nI := 1 To oMdlSE5:Length()
		oMdlSE5:Goline(nI)
		if oMdlSE5:GetValue("OK")
			cChave := FwxFilial("SE5") +;
					oMdlSE5:GetValue("E5_PREFIXO") +;
					oMdlSE5:GetValue("E5_PARCELA") +;
					oMdlSE5:GetValue("E5_TIPO") +;
					oMdlSE5:GetValue("E5_CLIFOR") +;
					oMdlSE5:GetValue("E5_LOJA")
		endif 
	Next nI 

Return

Static Function Consultar()
	Local oModel 	:= FwModelActivate()
	Local oMdlSE5	:= oModel:GetModel("SE5DETAIL")
	Local nI
	Local cChave 	:= ""

	For nI := 1 To oMdlSE5:Length()
		oMdlSE5:Goline(nI)
		if oMdlSE5:GetValue("OK")
			cChave := FwxFilial("SE5") +;
					oMdlSE5:GetValue("E5_PREFIXO") +;
					oMdlSE5:GetValue("E5_PARCELA") +;
					oMdlSE5:GetValue("E5_TIPO") +;
					oMdlSE5:GetValue("E5_CLIFOR") +;
					oMdlSE5:GetValue("E5_LOJA")
		endif 
	Next nI 
Return

Static Function criaButtonSel(oPanel,oOtherObject)
    TButton():New( 01, 10, "OK Todos",oPanel,{|| SelGrid(oOtherObject)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
Return
