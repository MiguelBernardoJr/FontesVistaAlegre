#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include "TOPCONN.CH"

static oCellHorAlign    := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign   := FwXlsxCellAlignment():Vertical()
Static cTitulo := "Fechamento de Frete"
/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author Igor Gomes Oliveira 
    @since 02/06/2023
    @version 1.0
    @param 
    @return 
    @example
    (examples)
    @see (links_or_references)
    /*/ 	
User Function VAFATI04()
	Local aArea			:= FWGetArea()
	Local oBrowse
	Private nTotEmb 	:= 0 //Total embarque
	Private nTotDes 	:= 0 //Total desembarque
	Private aCTE 		:= {}
	Private cArquivo 	:= "C:\TOTVS_RELATORIOS\"
	Private aCamZFF, aCamZFI
	Private cBakFil 	:= cFilAnt
	Private __cRet

	Private oFileW      := nil
    Private oExcel      := NIL
    Private jFormatTit,jFormatTot,jFormatHead,jFormatGD,JFLeft,JFRight,jFData,jFNum,jFMoeda //Formato de Celula
    Private jFontHeader,jFontTitulo,jFontText //Fontes
    Private jBHeaderLeft,jBHeaderRight,jBorderLeft,jBorderCenter,jBorderRight,jBottomLeft,jBottomRight,jNoBorder  // Bordas
	Private cFilcont 	:= ""

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZFF")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 		:= nil
	Local oStru   		:= FWFormStruct(1, 'ZFF')
	Local oGrid 		:= FWFormStruct(1, 'ZFF')
	Local oCte 			:= FWFormStruct(1, 'ZFI')
	Local bPos 			:= {|| U_FATI04S()}
	Local nI
	Local aGatilhos		:= {}
	Local aZFFRel		:= {}
	Local aZFIRel		:= {}

	aAdd(aGatilhos, FWStruTriggger( "ZFI_LOJA"	,"ZFI_NFOR","SA2->A2_NOME"		,.T.,"SA2"	,1	,'FWxFilial("SA2")+M->ZFI_FORNEC+M->ZFI_LOJA',NIL,"001"))

    For nI := 1 To Len(aGatilhos)
        oCte:AddTrigger(  aGatilhos[nI][01],; 	//Campo Origem
                            aGatilhos[nI][02],; //Campo Destino
                            aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
                            aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next

	aGatilhos := {}
	aAdd(aGatilhos, FWStruTriggger( "ZFF_FLOJA"	,"ZFF_MUN"    ,"SA2->A2_COD_MUN",.T.,"SA2"	,1	,'FWxFilial("SA2")+M->ZFF_FORNEC+M->ZFF_FLOJA',NIL,"002"))
	aAdd(aGatilhos, FWStruTriggger( "ZFF_FLOJA"	,"ZFF_EST"    ,"SA2->A2_EST"	,.T.,"SA2"	,1	,'FWxFilial("SA2")+M->ZFF_FORNEC+M->ZFF_FLOJA',NIL,"003"))
	aAdd(aGatilhos, FWStruTriggger( "ZFF_PLCVL"	,"ZFF_CODIGO"  ,"u_I04PLC()"		,.F.,""		,nil,NIL,"002"))
	aAdd(aGatilhos, FWStruTriggger( "ZFF_CONTRA","ZFF_FILCON"  ,"u_I04CTN()"		,.F.,""		,nil,NIL,"001"))

	For nI := 1 To Len(aGatilhos)
        oStru:AddTrigger(  aGatilhos[nI][01],;  //Campo Origem
                            aGatilhos[nI][02],; //Campo Destino
                            aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
                            aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next

	aGatilhos := {}
	aAdd(aGatilhos, FWStruTriggger( "ZFF_KM"	,"ZFF_VFRETE" ,"U_I04KMG()"	 	,.F.,""		,NIL,NIL,"01"))
	For nI := 1 To Len(aGatilhos)
        oGrid:AddTrigger(  aGatilhos[nI][01],;  //Campo Origem
                            aGatilhos[nI][02],; //Campo Destino
                            aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
                            aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next

    //oStru:SetProperty('ZFF_CONTRA'	, MODEL_FIELD_VALID	,   FwBuildFeature(STRUCT_FEATURE_VALID , 'ExistCpo("ZCC", &(ReadVar())) .and. M->ZFF_COMBO != "T"'))//Iniciador de Campo
    oStru:SetProperty('ZFF_CONTRA'	, MODEL_FIELD_VALID	,   FwBuildFeature(STRUCT_FEATURE_VALID , 'U_I04VCON()'))//Iniciador de Campo
    oStru:SetProperty('ZFF_NMUN'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'Iif(!Inclui,Posicione("CC2",1,FWxFilial("CC2")+ZFF->ZFF_EST+ZFF->ZFF_MUN,"CC2_MUN"),"")'))//Iniciador de Campo
    
    oGrid:SetProperty('ZFF_KM'		, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_VFRETE'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_VLKM'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_ADICIO'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_PEDAGI'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_ICMSF'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_VCOMP'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_DOC'		, MODEL_FIELD_VALID	,   FwBuildFeature(STRUCT_FEATURE_VALID , 'U_I04ZDOC()'))//Iniciador de Campo
    
	oCte:SetProperty('ZFI_FORNEC'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
	oCte:SetProperty('ZFI_LOJA'		, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
	oCte:SetProperty('ZFI_CODIGO'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
	oCte:SetProperty('ZFI_PLACA'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
	oCte:SetProperty('ZFI_ZFFITE'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oCte:SetProperty('ZFI_DOC'		, MODEL_FIELD_VALID	,   FwBuildFeature(STRUCT_FEATURE_VALID	, 'U_I04DOC()'))//Validação de Campo
    oCte:SetProperty('ZFI_VALOR'	, MODEL_FIELD_VALID	,   FwBuildFeature(STRUCT_FEATURE_VALID	, 'U_I04VAL()'))//Validação de Campo
    oCte:SetProperty('ZFI_FILDOC'	, MODEL_FIELD_VALID	,   FwBuildFeature(STRUCT_FEATURE_VALID	, 'U_I04FIL()'))//Validação de Campo

	oModel := MPFormModel():New("FATI04M",,,bPos)

	oModel:AddFields("ZFFMASTER",/*cOwner*/  ,oStru, /*bPreValidacao*/, {|| U_I04PREM()}/*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddGrid('ZFFDETAIL', 'ZFFMASTER'	, oGrid, /*bLinePre*/, {|| U_I04PREG()}/*bLinePos*/,/* bPre */,/* bPos */, /* {|| U_I04LOAD()} */)
	oModel:AddGrid('ZFIDETAIL', 'ZFFDETAIL'	, oCte , /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,/*  {|| U_I04LOAD()} */)

	aAdd(aZFFRel, {'ZFF_FILIAL'	, 'Iif(!INCLUI, ZFF->ZFF_FILIAL	 , FWxFilial("ZFF"))'})
	aAdd(aZFFRel, {'ZFF_CODIGO' , 'Iif(!INCLUI, ZFF->ZFF_CODIGO	 , ZFF->ZFF_CODIGO)'})

	//Relacionamento entre 2 grids tem q pegar o campo do MODEL

	aAdd(aZFIRel, {'ZFI_FILIAL'	, 'Iif(!INCLUI, ZFF->ZFF_FILIAL	 , FWxFilial("ZFF"))'})
	aAdd(aZFIRel, {'ZFI_CODIGO' , 'Iif(!INCLUI, oModel:GetModel("ZFFDETAIL"):GetValue("ZFF_CODIGO") , ZFF->ZFF_CODIGO)'})
	aAdd(aZFIRel, {'ZFI_ZFFITE'	, 'Iif(!INCLUI, oModel:GetModel("ZFFDETAIL"):GetValue("ZFF_ITEM") 	, ZFF->ZFF_ITEM) '})

	oModel:SetRelation('ZFFDETAIL', aZFFRel, ZFF->(IndexKey(1)))
	oModel:SetRelation('ZFIDETAIL', aZFIRel, ZFI->(IndexKey(3)))

	oModel:SetPrimaryKey({})

	oModel:GetModel( "ZFFDETAIL" ):SetUniqueLine( { "ZFF_FILIAL","ZFF_CODIGO","ZFF_ITEM" } )

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZFFMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	oModel:GetModel("ZFFDETAIL"):SetDescription("Grid do Cadastro "+cTitulo)
	oModel:GetModel("ZFIDETAIL"):SetDescription("Grid do CTE ")
	oModel:GetModel('ZFIDETAIL'):SetOptional(.T.)
Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAFATI04")
    Local oStru     	:= FWFormStruct(2, "ZFF" /* , {|cCampo| (AllTrim(cCampo) $ "ZFF_FILIAL|ZFF_CODIGO|ZFF_CONTRA|ZFF_FILCON|ZFF_FORNEC|ZFF_FLOJA|ZFF_FNOME|ZFF_DESTIN|ZFF_DLOJA|ZFF_NDEST|ZFF_MUN|ZFF_EST|ZFF_NMUN")} */ )
    Local oGrid     	:= FWFormStruct(2, "ZFF" /* , {|cCampo| !(AllTrim(cCampo) $ "ZFF_FILIAL|ZFF_CODIGO|ZFF_CONTRA|ZFF_FILCON|ZFF_FORNEC|ZFF_FLOJA|ZFF_FNOME|ZFF_DESTIN|ZFF_DLOJA|ZFF_NDEST|ZFF_MUN|ZFF_EST|ZFF_NMUN" )} */)
	Local oCte 			:= FWFormStruct(2, 'ZFI')
	Local oView
	Local nI 
	Local cStru 		:= "ZFF_FILIAL|ZFF_CODIGO|ZFF_COMBO|ZFF_CONTRA|ZFF_FILCON|ZFF_FORNEC|ZFF_FLOJA|ZFF_FNOME|ZFF_DESTIN|ZFF_DLOJA|ZFF_NDEST|ZFF_MUN|ZFF_EST|ZFF_NMUN"
	//oCte := GetVGridCte(oModel, oCte)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZFF"	, oStru 		, "ZFFMASTER")
	oView:AddGrid("VIEW_GRID"	, oGrid 		, "ZFFDETAIL")
	oView:AddGrid("GRID_CTE" 	, oCte 			, "ZFIDETAIL")
	
	oView:CreateHorizontalBox('CABEC', 35)
	oView:CreateHorizontalBox('GRID' , 45)
	oView:CreateHorizontalBox('RODAP', 20)
	
	oView:CreateFolder('ABA01','CABEC')
	oView:CreateFolder('ABA02','GRID')
	oView:CreateFolder('ABA03','RODAP')

	oView:SetOwnerView("VIEW_ZFF"	 , "CABEC")
	oView:SetOwnerView("VIEW_GRID"	 , "GRID")
	oView:SetOwnerView("GRID_CTE"	 , "RODAP")
	
	oView:EnableTitleView('VIEW_ZFF' , cTitulo)
	oView:EnableTitleView('GRID_CTE' , "CTE")
	oView:EnableTitleView('VIEW_GRID', "Dados")
 	
	aFields   	:= OSTRU:AFIELDS
	aCamZFF 	:= aClone(aFields)
	
	For nI := 1 to Len(aCamZFF)
		if !(aCamZFF[nI][1] $ cStru)
			oStru:RemoveField(aCamZFF[nI][1])
		endif
	Next nI
	For nI := 1 to Len(aCamZFF)
		if aCamZFF[nI][1] $ cStru /* .and. (aCamZFF[nI][1] != "ZFF_CODIGO") */
			oGrid:RemoveField(aCamZFF[nI][1])
		endif
	next nI
	
	oView:AddIncrementField( 'VIEW_GRID', 'ZFF_ITEM')
	oView:AddIncrementField( 'GRID_CTE' , 'ZFI_ITEM')
	
	oView:AddUserButton( 'Salvar Frete (F8)','', {|oView| SlvCont()} )

	oView:SetCloseOnOk( { |oView| .F. } )
Return oView

Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' 			ACTION 'VIEWDEF.VAFATI04' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    			ACTION 'VIEWDEF.VAFATI04' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    			ACTION 'VIEWDEF.VAFATI04' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    			ACTION 'VIEWDEF.VAFATI04' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Relatório'  			ACTION 'U_VACOMR13'		  OPERATION 6 					   ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Processar Fretes'  	ACTION 'U_FATI04P'		  OPERATION 6 					   ACCESS 0 //OPERATION 5
Return aRot

User Function FATI04M()
	Local aParam 	:= PARAMIXB
	Local xRet 		:= .T.
	Local oModel 	:= nil
	Local oCab		:= nil
	Local oObj 		:= ''
	Local cIdPonto 	:= ''
	Local cIdModel 	:= ''
	Local cIdIXB5	:= ''
	Local cIdIXB4	:= '' 
	Local nI

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		if len(aParam) >= 4
			cIdIXB4  := aParam[4]
		endif 

		if len(aParam) >= 5
			cIdIXB5  := aParam[5]
		endif 

		if cIdPonto == 'MODELVLDACTIVE'
			//if select("ZFI") ==  0
			//	DBSELECTAREA( "ZFI" )
			//endif
		elseif cIdPonto == 'FORMCOMMITTTSPRE'
			if nTotEmb < nTotDes
				MsgAlert("Quantidade total do Embarque menor que o Desembarque.", "Atenção...")
				xRet := .F.
			elseif nTotEmb > nTotDes
				MsgAlert("Quantidade total do Desembarque menor que o Embarque.", "Atenção...")
				xRet := .F.
			endif
		//elseif cIdPonto == 'FORMPRE' .and. cIdModel == 'ZFFDETAIL' .and. cIdIXB5 = 'ADDLINE'
		elseif cIdPonto == 'MODELCOMMITNTTS'
			if cBakFil != cFilAnt
				cFilAnt := cBakFil
			endif 
		endif
	endif
Return xRet

//Validação dos campos ZFF_DATA e ZFF_DTDESE
User Function FAT04DT()
	Local oModel		:= FWModelActive()
	Local oGrid 		:= oModel:GetModel("ZFFDETAIL")
	Local lRet 			:= .T. 
	Local cCampo 		:= SubS( ReadVar(), At(">", ReadVar())+1 )
	Local cDt 			:= &(ReadVar())

	if cCampo == 'ZFF_DATA'
		if cDt > dDataBase
			lRet := .F.
			oModel:SetErrorMessage("","","","","Data Inválida", 'Data de Embarque não pode ser maior que a data atual!', "") 
		elseif !EMPTY(oGrid:GetValue("ZFF_DTDESE"))
			if cDt > oGrid:GetValue("ZFF_DTDESE")
				lRet := .F.
				oModel:SetErrorMessage("","","","","Data Inválida", 'Data de Embarque não pode ser maior que a data de desembarque!', "") 
			endif
		endif
	else
		if cDt > dDataBase
			lRet := .F. 
			oModel:SetErrorMessage("","","","","Data Inválida", 'Data de Desembarque não pode ser maior que a data atual!', "")
		elseif !EMPTY(oGrid:GetValue("ZFF_DATA"))
			if cDt < oGrid:GetValue("ZFF_DATA")
				lRet := .F.
				oModel:SetErrorMessage("","","","","Data Inválida", 'Data de Desembarque não pode ser menor que a data de Embarque!', "") 
			endif
		endif
	endif
Return lRet
//Carga do submodelo ZFIDETAIL
User Function I04LOAD()
	Local oModel	:= FWModelActive()
	Local oStruct 	:= oModel:GetModel("ZFFMASTER")
	Local aArea		:= GetArea()
	Local aRet 		:= {}
	Local cQry 		:= ''
	Local nValor	:= 0
	Local cAlias 	:= GetNextAlias()

	cQry := " SELECT *  " + CRLF 
	cQry += " FROM "+RetSqlName("ZFI")+"  " + CRLF
	cQry += " WHERE ZFI_FILIAL 	= '"+FWxFilial("ZFI")+"' " + CRLF 
	cQry += " AND ZFI_CODIGO	= '"+oStruct:GetValue("ZFF_CODIGO")+"' " + CRLF 
	cQry += " AND D_E_L_E_T_	= '' " + CRLF

	mpSysOpenQuery(cQry,cALias)

	DBSELECTAREA( "SF1" )
	DBSETORDER( 2 )
	
	while !(cALias)->(EOF())

		IF DbSeek((cALias)->ZFI_FILDOC+;
			(cALias)->ZFI_FORNEC+;
			(cALias)->ZFI_LOJA+;
			(cALias)->ZFI_DOC )
			
			nValor := SF1->F1_VALBRUT
		else 
			nValor := 0 
		ENDIF
		aAdd(aRet,{Val((cALias)->ZFI_ITEM),{	(cALias)->ZFI_ITEM,;
										(cALias)->ZFI_FORNEC,;
										(cALias)->ZFI_LOJA,;
										iif(!Empty((cALias)->ZFI_FORNEC),Posicione("SA2",1,FwxFilial("SA2")+(cALias)->ZFI_FORNEC+(cALias)->ZFI_LOJA,"A2_NOME"),"")	,;
										(cALias)->ZFI_FILDOC,;
										(cALias)->ZFI_DOC,;
										(cALias)->ZFI_SERIE,;
										nValor,;
										(cALias)->ZFI_CODIGO,;
										(cALias)->ZFI_ZFFITE}})
		
		(cALias)->(DbSkip())
	end

	if Len(aRet) == 0
		aAdd(aRet,{1,{	'01',;
						oStruct:GetValue("ZFF_FORNEC"),;
						oStruct:GetValue("ZFF_FLOJA"),;
						Posicione("SA2",1,FwxFilial("SA2")+oStruct:GetValue("ZFF_FORNEC")+oStruct:GetValue("ZFF_FLOJA"),"A2_NOME"),;
						,;
						,;
						,;
						0,;
						"000000",;
						'01'}})
	endif
	SF1->(DBCLOSEAREA())
	(cALias)->(DBCLOSEAREA())
	RestArea(aArea)
Return aRet
//Validação dos campos ZFF_HREMB e ZFF_HRDESE
User Function FAT04HR()
	Local oModel		:= FWModelActive()
	Local oGrid 		:= oModel:GetModel("ZFFDETAIL")
	Local lRet 			:= .T.
	Local cCampo 		:= SubStr(ReadVar(),4,len(ReadVar()))
	Local cHora			:= &(ReadVar())
	
	IF Left(cHora,2)>='00' .And. Left(cHora,2)<='24' .And. Right(cHora,2)>='00' .And. Right(cHora,2)<='59'
		if Left(cHora,2)<='24' .and. Right(cHora,2)=='00'
			if cCampo == "ZFF_HRDESE"
				IF oGrid:GetValue("ZFF_DATA") == oGrid:GetValue("ZFF_DTDESE")
					if Left(cHora,2) < Left(oGrid:GetValue("ZFF_HREMB"),2) // hora de Embarque maior que o desembarque com data no mesmo dia
						lRet := .F.
					elseif Left(cHora,2) == Left(oGrid:GetValue("ZFF_HREMB"),2) .and. Right(cHora,2) <= Right(oGrid:GetValue("ZFF_HREMB"),2) // hora de desembarque maior que o Embarque com data no mesmo dia
						lRet := .F.
					ENDIF
				ENDIF
			ELSEIF cCampo == "ZFF_HREMB"
				IF oGrid:GetValue("ZFF_DATA") == oGrid:GetValue("ZFF_DTDESE")
					if Left(cHora,2) > Left(oGrid:GetValue("ZFF_HRDESE"),2) // hora de Embarque maior que o desembarque com data no mesmo dia
						lRet := .F.
					elseif Left(cHora,2) == Left(oGrid:GetValue("ZFF_HRDESE"),2) .and. Right(cHora,2) >= Right(oGrid:GetValue("ZFF_HRDESE"),2) // hora de Embarque maior que o desembarque com data no mesmo dia
						lRet := .F.
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	else
		lRet := .F.
	endif
Return lRet
User Function FATI04S()
	Local aArea 		:= GetArea()
	Local oModel		:= FWModelActive()
	Local oStruct		:= oModel:GetModel("ZFFMASTER")
	Local oGrid			:= oModel:GetModel("ZFFDETAIL")
	Local oCte			:= oModel:GetModel("ZFIDETAIL")
	Local nOpc			:= oModel:GetOperation()
	Local lRecLock		:= .T.
	Local lRet 			:= .T.
	Local nI,nX

	if nOpc == 3 .or. nOpc == 4 // ALTERAÇÃO E INCLUSÃO

		For nI := 1 to oGrid:GetQtdLine()
			oGrid:GoLine(nI)
			if oGrid:GetValue("ZFF_EMPE") +;
				oGrid:GetValue("ZFF_CAIDOS") +;
				oGrid:GetValue("ZFF_EMERGE") +;
				oGrid:GetValue("ZFF_MORTO") != oGrid:GetValue("ZFF_QTDE")
				
				oModel:SetErrorMessage("","","","","Quantidade Inválida", 'Quantidade de desembarque na linha '+oGrid:GetValue("ZFF_ITEM")+' não corresponde a quantidade total do embarque.', "") 
				lRet := .F.
			endif
		Next nI

		IF lRet
			ZFF->(DBSETORDER(2))
			//DBSELECTAREA( "ZFI" )
			ZFI->(DBSETORDER( 4 ))
		
			For nX := 1 to oGrid:GetQtdLine()
				oGrid:GoLine(nX)
				
				IF oGrid:IsDeleted()
					if ZFF->(DBSeek(FWxFilial("ZFF") + oStruct:GetValue("ZFF_CODIGO") +  oGrid:GetValue("ZFF_ITEM")))
						ZFF->(RECLOCK('ZFF',.F.))
							ZFF->(DbDelete())
						ZFF->(MSUNLOCK())
					endif
				ELSE
					RECLOCK( "ZFF", lReclock := !(ZFF->(DBSEEK(FwxFilial("ZFF")+oStruct:GetValue("ZFF_CODIGO")+oGrid:GetValue("ZFF_ITEM")))))
						ZFF->ZFF_FILIAL := FwxFilial("ZFF")
						ZFF->ZFF_COMBO  := oStruct:GetValue("ZFF_COMBO")
						ZFF->ZFF_CODIGO := oStruct:GetValue("ZFF_CODIGO")
						ZFF->ZFF_CONTRA := oStruct:GetValue("ZFF_CONTRA")
						ZFF->ZFF_FILCON := oStruct:GetValue("ZFF_FILCON")
						ZFF->ZFF_FORNEC := oStruct:GetValue("ZFF_FORNEC")
						ZFF->ZFF_FLOJA 	:= oStruct:GetValue("ZFF_FLOJA")
						ZFF->ZFF_DESTIN := oStruct:GetValue("ZFF_DESTIN")
						ZFF->ZFF_DLOJA 	:= oStruct:GetValue("ZFF_DLOJA")
						ZFF->ZFF_MUN 	:= oStruct:GetValue("ZFF_MUN")
						ZFF->ZFF_EST 	:= oStruct:GetValue("ZFF_EST")
						ZFF->ZFF_ITEM 	:= oGrid:GetValue("ZFF_ITEM")
						ZFF->ZFF_PLCVL 	:= oGrid:GetValue("ZFF_PLCVL")
						ZFF->ZFF_ITEM 	:= oGrid:GetValue("ZFF_ITEM")
						ZFF->ZFF_ICTA1 	:= oGrid:GetValue("ZFF_ICTA1")
						ZFF->ZFF_PLCC1 	:= oGrid:GetValue("ZFF_PLCC1")
						ZFF->ZFF_ICTA2 	:= oGrid:GetValue("ZFF_ICTA2")
						ZFF->ZFF_PLCC2 	:= oGrid:GetValue("ZFF_PLCC2")
						ZFF->ZFF_ICTA3 	:= oGrid:GetValue("ZFF_ICTA3")
						ZFF->ZFF_NUMMIN := oGrid:GetValue("ZFF_NUMMIN")
						ZFF->ZFF_TIPVEI := oGrid:GetValue("ZFF_TIPVEI")
						ZFF->ZFF_MOTOR 	:= oGrid:GetValue("ZFF_MOTOR")
						ZFF->ZFF_ORIGEM := oGrid:GetValue("ZFF_ORIGEM")
						ZFF->ZFF_RLOJA 	:= oGrid:GetValue("ZFF_RLOJA")
						ZFF->ZFF_KM 	:= oGrid:GetValue("ZFF_KM")
						ZFF->ZFF_VFRETE := oGrid:GetValue("ZFF_VFRETE")
						ZFF->ZFF_VLKM 	:= oGrid:GetValue("ZFF_VLKM")
						ZFF->ZFF_ADICIO := oGrid:GetValue("ZFF_ADICIO")
						ZFF->ZFF_PEDAGI := oGrid:GetValue("ZFF_PEDAGI")
						ZFF->ZFF_ICMSF 	:= oGrid:GetValue("ZFF_ICMSF")
						ZFF->ZFF_VCOMP 	:= oGrid:GetValue("ZFF_VCOMP")
						ZFF->ZFF_QTDE 	:= oGrid:GetValue("ZFF_QTDE")
						ZFF->ZFF_DATA 	:= oGrid:GetValue("ZFF_DATA")
						ZFF->ZFF_ITEM 	:= oGrid:GetValue("ZFF_ITEM")
						ZFF->ZFF_HREMB 	:= oGrid:GetValue("ZFF_HREMB")
						ZFF->ZFF_BOIS 	:= oGrid:GetValue("ZFF_BOIS")
						ZFF->ZFF_VACAS 	:= oGrid:GetValue("ZFF_VACAS")
						ZFF->ZFF_BUFALO := oGrid:GetValue("ZFF_BUFALO")
						ZFF->ZFF_TOURO 	:= oGrid:GetValue("ZFF_TOURO")
						ZFF->ZFF_NOVILH := oGrid:GetValue("ZFF_NOVILH")
						ZFF->ZFF_DTDESE := oGrid:GetValue("ZFF_DTDESE")
						ZFF->ZFF_ITEM 	:= oGrid:GetValue("ZFF_ITEM")
						ZFF->ZFF_HRDESE := oGrid:GetValue("ZFF_HRDESE")
						ZFF->ZFF_EMPE 	:= oGrid:GetValue("ZFF_EMPE")
						ZFF->ZFF_CAIDOS := oGrid:GetValue("ZFF_CAIDOS")
						ZFF->ZFF_EMERGE := oGrid:GetValue("ZFF_EMERGE")
						ZFF->ZFF_MORTO 	:= oGrid:GetValue("ZFF_MORTO")
						ZFF->ZFF_DOC 	:= oGrid:GetValue("ZFF_DOC")
						ZFF->ZFF_SERIE 	:= oGrid:GetValue("ZFF_SERIE")
					ZFF->(MSUNLOCK())

					For nI := 1 to oCte:GetQtdLine()
						oCte:GoLine(nI)

						IF oCte:IsDeleted()
							if ZFI->(DBSeek(FWxFilial("ZFI") + oStruct:GetValue("ZFF_CODIGO") +  oCte:GetValue("ZFI_ZFFITE") +oCte:GetValue("ZFI_ITEM")))
								ZFI->(RECLOCK('ZFI',.F.))
									ZFI->(DbDelete())
								ZFI->(MSUNLOCK())
							endif
						elseif !EMPTY(oCte:GetValue("ZFI_DOC"))
							RecLock("ZFI", lRecLock := !(ZFI->(DBSeek(FWxFilial("ZFI") + oStruct:GetValue("ZFF_CODIGO") +  oCte:GetValue("ZFI_ZFFITE") + oCte:GetValue("ZFI_ITEM")))))
								ZFI->ZFI_FILIAL := FwXFilial("ZFI")
								ZFI->ZFI_CODIGO := oStruct:GetValue("ZFF_CODIGO")
								ZFI->ZFI_ITEM   := oCte:GetValue("ZFI_ITEM")
								ZFI->ZFI_ZFFITE := oCte:GetValue("ZFI_ZFFITE")
								ZFI->ZFI_DOC 	:= oCte:GetValue("ZFI_DOC")
								ZFI->ZFI_SERIE  := oCte:GetValue("ZFI_SERIE")
								ZFI->ZFI_FILDOC := oCte:GetValue("ZFI_FILDOC")
								ZFI->ZFI_PLACA  := oCte:GetValue("ZFI_PLACA")
								ZFI->ZFI_FORNEC := oCte:GetValue("ZFI_FORNEC")
								ZFI->ZFI_LOJA  	:= oCte:GetValue("ZFI_LOJA")
								ZFI->ZFI_VALOR 	:= oCte:GetValue("ZFI_VALOR")
							ZFI->( MsUnlock())
						endif
						
					Next nI
				endif
			Next nX
		ENDIF
		
	elseif nOpc == 5 //DELETE

		ZFF->(DBSETORDER( 2 ))
		
		ZFI->(DBSETORDER( 4 ))

		For nI := 1 to oGrid:GetQtdLine()
			oGrid:GoLine(nI)
			if ZFF->(DBSeek(FWxFilial("ZFF") + oStruct:GetValue("ZFF_CODIGO") +  oGrid:GetValue("ZFF_ITEM")))
				ZFF->(RECLOCK('ZFF',.F.))
					ZFF->(DbDelete())
				ZFF->(MSUNLOCK())
			endif

			For nX := 1 to oCte:GetQtdLine()
				oCte:GoLine(nI)
				if ZFI->(DBSeek(FWxFilial("ZFI") + oStruct:GetValue("ZFF_CODIGO") +  oCte:GetValue("ZFI_ZFFITE") + oCte:GetValue("ZFI_ITEM")))
					ZFI->(RECLOCK('ZFI',.F.))
						ZFI->(DbDelete())
					ZFI->(MSUNLOCK())
				endif
			Next nX
		Next nI
	endif
		//Se nÃ£o for inclusÃ£o, volta o INCLUI para .T. (bug ao utilizar a ExclusÃ£o, antes da InclusÃ£o)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

	RestArea(aArea)
Return lRet
//Quantidade Embarque
User Function ATI04QT()
	Local oModel		:= FWModelActive()
	Local oGrid			:= oModel:GetModel("ZFFDETAIL")
	Local lRet 			:= .T.

	if &(ReadVar()) >= 0
		oGrid:SetValue("ZFF_QTDE",;
			oGrid:GetValue("ZFF_BOIS")  +;
			oGrid:GetValue("ZFF_VACAS") +;
			oGrid:GetValue("ZFF_BUFALO")+;
			oGrid:GetValue("ZFF_TOURO") +;
			oGrid:GetValue("ZFF_NOVILH"))
	else
		lRet := .F.
	endif
Return lRet

User Function I04DKM()

	Local aArea 	:= GetArea()
	Local oModel	:= FWModelActive()
	Local oStruct	:= oModel:GetModel("ZFFMASTER")
	Local nRet 		:= 0
	Local cAlias 	:= GetNextAlias()

	cQry := " SELECT TOP 1 " +CRLF
	cQry += " * FROM "+RetSqlName("ZFF")+"" +CRLF
	cQry += " WHERE ZFF_FORNEC = '"+ALLTRIM(oStruct:GetValue("ZFF_FORNEC"))+"' " +CRLF
	cQry += " AND ZFF_FLOJA = '"+ALLTRIM(oStruct:GetValue("ZFF_FLOJA"))+"' " +CRLF
	cQry += " AND ZFF_DESTIN = '"+ALLTRIM(oStruct:GetValue("ZFF_DESTIN"))+"' " +CRLF
	cQry += " AND ZFF_DLOJA = '"+ALLTRIM(oStruct:GetValue("ZFF_DLOJA"))+"' " +CRLF
	cQry += " AND D_E_L_E_T_ = '' " +CRLF
	cQry += " ORDER BY ZFF_PLCVL DESC  " +CRLF

	mpSysOpenQuery(cQry,cALias)
	if !(cALias)->(EOF())
		nRet := (cALias)->ZFF_KM
	endif

	(cALias)->(DBCLOSEAREA())
	RestArea(aArea)
Return nRet
/* Iniciador para o campo ZFI_FORNEC, ZFI_LOJA E ZFI_NFOR na estrutura da GRID */
User Function I04IFOR()
	Local oModel		:= FWModelActive()
	Local oStruct 		:= oModel:GetModel("ZFFMASTER")
	Local oGrid 		:= oModel:GetModel("ZFFDETAIL")
	Local cRet 			:= ""
	Local cCampo 		:= Substr( ReadVar(), At('->', ReadVar())+2 )
	
	if oGrid:GetQtdLine() == 0
		if !EMPTY(oStruct:GetValue("ZFF_FORNEC"))
			IF cCampo == 'ZFI_FORNEC'	
				cRet := oStruct:GetValue("ZFF_FORNEC")
			elseif cCampo == 'ZFI_LOJA'
				cRet := oStruct:GetValue("ZFF_FLOJA")
			else
				cRet := POSICIONE("SA2",1, FwXFilial("SA2")+oStruct:GetValue("ZFF_FORNEC")+oStruct:GetValue("ZFF_FLOJA "),"A2_NOME")
			endif
		endif
	else
		IF cCampo == 'ZFI_FORNEC'
			cRet := oGrid:GetValue("ZFF_ORIGEM")
		elseif cCampo == 'ZFI_LOJA'
			cRet := oGrid:GetValue("ZFF_RLOJA")
		else
			cRet := POSICIONE("SA2",1, FwXFilial("SA2")+oGrid:GetValue("ZFF_ORIGEM")+oGrid:GetValue("ZFF_RLOJA"),"A2_NOME")
		endif
	endif
Return cRet
/* Incrementador para o campo item na grid */
User Function I04INC()
	Local oModel	 := FWModelActive()
	Local oCte 	 	 := oModel:GetModel("ZFIDETAIL")
	Local cRet 		 := ""
	Local aSaveLines := FWSaveRows()	

	if oCte:GetQtdLine() == 0
		cRet := StrZero(oCte:GetQtdLine() + 1,2)
	else 
		cRet := StrZero(Val(oCte:GetValue("ZFI_ITEM"))+1,2)
	endif 
	FWRestRows( aSaveLines )
Return cRet := StrZero(oCte:GetQtdLine() + 1,2)

/* Remover zeros a esquerda */
User Function zTiraZeros(cTexto)
    Local aArea     := GetArea()
    Local cRetorno  := ""
    Local lContinua := .T.
    Default cTexto  := ""
 
    //Pegando o texto atual
    cRetorno := Alltrim(cTexto)
 
    //Enquanto existir zeros a esquerda
    While lContinua
        //Se a priemira posição for diferente de 0 ou não existir mais texto de retorno, encerra o laço
        If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0
            lContinua := .f.
        EndIf
         
        //Se for continuar o processo, pega da próxima posição até o fim
        If lContinua
            cRetorno := Substr(cRetorno, 2, Len(cRetorno))
        EndIf
    EndDo
     
    RestArea(aArea)
Return cRetorno

User Function I04VMIN()
	Local aArea 	:= GetArea()
	Local oModel	:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZFFDETAIL")
	Local cQry 		:= ""
	Local lRet 		:= .T.
	Local cAlias 	:= GetNextAlias()
	
	if ProcName(3) != "U_I04CTN"
		cQry := "SELECT *  " + CRLF
		cQry += " FROM "+RetSqlName("ZFF")+" " + CRLF
		cQry += " WHERE ZFF_FILIAL = '"+FWxFilial("ZFF")+"' " + CRLF
		cQry += " AND ZFF_NUMMIN = '"+oGrid:GetValue("ZFF_NUMMIN")+"' " + CRLF
		cQry += " AND D_E_L_E_T_ = '' " + CRLF

		mpSysOpenQuery(cQry,cALias)

		IF !(cALias)->(EOF())
			lRet := .F.
			oModel:SetErrorMessage("","","","","Valor Inválido", 'Minuta já está cadastrada no código: ' + (cALias)->ZFF_CODIGO + ', Para a placa: ' + (cALias)->ZFF_PLCVL, "") 
		ENDIF

		(cALias)->(DBCLOSEAREA())
	ENDIF
	RestArea(aArea)
Return lRet
/* Gatilho para o campo loja do Transportadora */  
User Function I04FORN()
	Local oModel	:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZFFDETAIL")
	Local oCTE 		:= oModel:GetModel("ZFIDETAIL")
	Local cRet 		:= ''

	cRet := Posicione("SA2",1,FwXFilial("SA2")+oGrid:GetValue("ZFF_ORIGEM")+oGrid:GetValue("ZFF_RLOJA"),"A2_NOME")

	if oCTE:GetQtdLine() == 1
		if EMPTY(oCTE:GetValue("ZFI_DOC"))
			oCTE:SetValue("ZFI_ZFFITE"	,oGrid:GetValue("ZFF_ITEM"))
			oCTE:SetValue("ZFI_PLACA"	,oGrid:GetValue("ZFF_PLCVL"))
			oCTE:SetValue("ZFI_FORNEC"	,oGrid:GetValue("ZFF_ORIGEM"))
			oCTE:SetValue("ZFI_LOJA"	,oGrid:GetValue("ZFF_RLOJA"))
			oCTE:SetValue("ZFI_NFOR"	,cRet)
		endif
	endif
Return cRet
//Somar Valor de COmplemento
User Function I04VCOMP()
	Local oModel	:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZFFDETAIL")
	Local oCte 		:= oModel:GetModel("ZFIDETAIL")
	Local nI 		:= 0
	Local nSomaCte  := nSomaF := nRet := 0
	
	if oGrid:GetValue("ZFF_ORIGEM") != '000025'
		For nI := 1 to oCte:GetQtdLine()
			if !oCte:IsDeleted()
				if oCte:GetValue("ZFI_ZFFITE") == oGrid:GetValue("ZFF_ITEM")
					nSomaCte += oCte:GetValue("ZFI_VALOR")
				endif
			endif
		Next nI

		nSomaF := oGrid:GetValue("ZFF_VFRETE") +;
				oGrid:GetValue("ZFF_PEDAGI") +;
				oGrid:GetValue("ZFF_ADICIO") +;
				oGrid:GetValue("ZFF_ICMSF")
	endif 

Return nRet := nSomaF - nSomaCte
//Gatilho para pegar valor do frete
User Function I04KMG()

	Local oModel	:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZFFDETAIL")
	Local aArea 	:= GetArea()
	Local nRet 		:= 0
	Local cQry 		:= ""
	Local cALias 	:= GetNextAlias()

	if ProcName(6) != 'U_I04CTN'
		cQry := " SELECT * " + CRLF
		cQry += " FROM "+RetSqlName("ZFV")+" " + CRLF
		cQry += " WHERE ZFV_TIPVEI = '"+oGrid:GetValue("ZFF_TIPVEI")+"'" + CRLF
		cQry += " AND ZFV_DE <=  '"+iif(Empty(dToS(oGrid:GetValue("ZFF_DTDESE"))),dToS(dDataBase),dToS(oGrid:GetValue("ZFF_DTDESE")))+"'" + CRLF
		cQry += " AND ZFV_ATE >= '"+iif(Empty(dToS(oGrid:GetValue("ZFF_DTDESE"))),dToS(dDataBase),dToS(oGrid:GetValue("ZFF_DTDESE")))+"'" + CRLF
		cQry += " AND ZFV_KMDE <= "+Str(oGrid:GetValue("ZFF_KM"))+"" + CRLF
		cQry += " AND ZFV_KMATE >= "+Str(oGrid:GetValue("ZFF_KM"))+"" + CRLF
		cQry += " AND D_E_L_E_T_ = ''" + CRLF
		
		if cUserName == 'ioliveira'
			memowrite("C:\TOTVS_RELATORIOS\ZFV_ZFF_GATILHO.sql", cQry)
		endif

		MpSysOpenQuery(cQry, cALias)

		IF !(cALias)->(EOF())
			if (cALias)->ZFV_TIPPAG == '2'
				nRet := (cALias)->ZFV_VLKM
			else
				nRet := (cALias)->ZFV_VLKM * oGrid:GetValue("ZFF_KM")
			EndIF
		else
			MSGALERT( "Não foi encontrado intervalo de pagamanto para este tipo de veiculo e data informada! "+ CRLF +;
					"Verifique a rotina U_VAFATI06() - Valores de Frete", "Atenção" )
		ENDIF
	ENDIF

	RestArea(aArea)
Return nRet
User Function XMTA061()
	Local aRotBkp    As Array

	// Avalia se o aRotina existe
	If(Type('aRotina') == 'A')

		// Guarda o conteúdo atual do aRotina
		aRotBkp    := aClone(aRotina)

		// Limpa ou refaz o aRotina
		aRotina    := Nil

	EndIf

	U_VAFATI06()

	// Avalia se foi feito backup do aRotina
	If(ValType(aRotBkp) == 'A')
		aRotina    := aClone(aRotBkp)
	EndIf

Return
User FUnction FATI04P()
	Local aArea 	:= FWGetArea()
	Local cPerg 	:= "FATI04P"
	Local cQry 		:= ''
	Local nVlrUnit  := 0
	Local cALias 	:= GetNextAlias()
	Local _cAliasG 	:= GetNextAlias()

	GeraX1(cPerg)	

	If Pergunte(cPerg, .T.)

		U_PrintSX1(cPerg)
		
		cQry := " select ZFF_CODIGO, "+ CRLF
		cQry += " ZFF_FORNEC, "+ CRLF
		cQry += " ZFF_CONTRA,  "+ CRLF
		cQry += " ZFF_FILCON, "+ CRLF
		cQry += " SUM(ZFF_VFRETE) AS FRETE, "+ CRLF
		cQry += " SUM(ZFF_ADICIO) AS ADICIONAL, "+ CRLF
		cQry += " SUM(ZFF_PEDAGI) AS PEDAGIO "+ CRLF
		cQry += " from "+RetSqlName("ZFF")+" "+ CRLF
		cQry += " WHERE ZFF_FILIAL  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+ CRLF
		cQry += " AND ZFF_FORNEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+ CRLF
		cQry += " AND ZFF_DTDESE BETWEEN '"+dToS(MV_PAR05)+"' AND '"+dToS(MV_PAR06)+"'  "+ CRLF
		if AllTrim(mv_par07) != ""
			cQry += " AND ZFF_CONTRA = '"+mv_par07+"'  "+ CRLF
		else
			cQry += " AND ZFF_CONTRA <> ''  "+ CRLF
		endif
		cQry += " AND D_E_L_E_T_ = ''  "+ CRLF
		cQry += " GROUP BY ZFF_CODIGO, ZFF_FORNEC,ZFF_CONTRA, ZFF_FILCON "+ CRLF
		cQry += " ORDER BY ZFF_FILCON,ZFF_CONTRA "+ CRLF
		
		MpSysOpenQry(cQry,cALias)
		
		_cQry := "" + CRLF
		_cQry += "SELECT * FROM "+RetSqlName("ZBC")+" ZBC WHERE ZBC_CODIGO+ZBC_FILIAL IN ( " + CRLF
		_cQry += "											SELECT DISTINCT ZFF_CONTRA+ZFF_FILCON " + CRLF
		_cQry += "											FROM "+RetSqlName("ZFF")+" ZFF 
		_cQry += " 											WHERE ZFF_FILIAL  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+ CRLF
		_cQry += " 											AND ZFF_FORNEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+ CRLF
		_cQry += " 											AND ZFF_DTDESE BETWEEN '"+dToS(MV_PAR05)+"' AND '"+dToS(MV_PAR06)+"'  "+ CRLF
		if AllTrim(mv_par07) != ""
			_cQry += " 											AND ZFF_CONTRA = '"+mv_par07+"'  "+ CRLF
			else 											
			_cQry += " 											AND ZFF_CONTRA <> ''  "+ CRLF
		endif 
		_cQry += "											AND ZFF.D_E_L_E_T_ = '' " + CRLF
		_cQry += "									) " + CRLF
		_cQry += "									 and ZBC.D_E_L_E_T_ = ''" + CRLF
		_cQry += "									 ORDER BY ZBC_FILIAL,ZBC_CODIGO, ZBC_ITEM "+ CRLF 

		MpSysOpenQry(_cQry,_cAliasG)

	    memowrite("C:\TOTVS_RELATORIOS\Processar Fretes.sql", cQry+_cQry)

		DBSelectArea("ZCC")
		ZCC->(DBSetOrder(2)) // ZCC_FILIAL + ZCC_CODIGO
		
		DBSelectArea("ZBC")
		ZBC->(DBSetOrder(3)) // ZBC_FILIAL+ZBC_CODIGO+ZBC_VERSAO+ZBC_ITEM
		
		FWMsgRun(, {|| GeraRel(@_cAliasG,@cAlias ) },;
                            'Por Favor Aguarde...',; 
                            'Processando Banco de Dados - Recebimento')

		if MSGYESNO("Confira o relatório antes de prosseguir!","Prosseguir?")
			Begin Transaction
				While !(cALias)->(EOF())

					If ZCC->(DBSeek((cALias)->ZFF_FILCON+(cALias)->ZFF_CONTRA))
						nVlrUnit := ( (cALias)->FRETE + (cALias)->ADICIONAL + (cALias)->PEDAGIO ) / ZCC->ZCC_QTTTAN

						WHILE (_cAliasG)->ZBC_FILIAL == (cALias)->ZFF_FILCON .AND. (_cAliasG)->ZBC_CODIGO == (cALias)->ZFF_CONTRA 
							ZBC->(DBSeek((_cAliasG)->ZBC_FILIAL+(_cAliasG)->ZBC_CODIGO+(_cAliasG)->ZBC_VERSAO+(_cAliasG)->ZBC_ITEM))
								RecLock("ZBC",.F.)
									ZBC->ZBC_VLFRPG := Round(nVlrUnit * ZBC->ZBC_QUANT,2)
								ZBC->(MsUnlock())
							(_cAliasG)->(DBSKIP())
						ENDDO
					else
						ConOut( "Contrato: " +(cALias)->ZFF_CONTRA+ " não encontrado" )
					Endif
					(cALias)->(DBSkip())
				EndDo
			End Transaction
			MSGALERT( "Fretes Processados!", "Atenção")
		endif

		ZBC->(DBCloseArea())
		ZCC->(DBCloseArea())
		(_cAliasG)->(DBCLOSEAREA())
		(cALias)->(DBCloseArea())
	EndIf

	FwRestArea(aArea)
Return 

Static Function GeraRel(_cAliasG,cAlias)
		Local cWorkSheet := "Processamento"
		Local nRow := 1
		Local nCol := 1
		Local nRowIni
		Local nRowFim
	    Local cPerg			:= SubS(ProcName(),3)
    	Local cPath 	 	:= "C:\totvs_relatorios\"
    	Local cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
                                DtoS(dDataBase)+; 
                                "_"+;
                                StrTran(SubS(Time(),1,5),":","")+;
                                ".rel"
		DefinirFormatacao()

		oExcel := FwPrinterXlsx():New()
		oExcel:Activate(cArquivo)
		oExcel:AddSheet(cWorkSheet)

		oExcel:SetCellsFormatConfig(jFormatTit)
		oExcel:SetFontConfig(jFontTitulo)
		oExcel:MergeCells(nRow, nCol, nRow, 5)

		oExcel:SetText(nRow, nCol, "Processamento de Fretes")
		
		oExcel:SetCellsFormatConfig(jFormatHead)
		oExcel:SetFontConfig(jFontHeader)
		nRow += 1
		//Printando Cabeçalho
		oExcel:SetValue(nRow, nCol	, "Filial")
		oExcel:SetValue(nRow, ++nCol, "Fornecedor")
		oExcel:SetValue(nRow, ++nCol, "Contrato")
		oExcel:SetValue(nRow, ++nCol, "Quantidade")
		oExcel:SetValue(nRow, ++nCol, "Valor Frete")


		While !(cALias)->(EOF())
			If ZCC->(DBSeek((cALias)->ZFF_FILCON+(cALias)->ZFF_CONTRA))
				nVlrUnit := ( (cALias)->FRETE + (cALias)->ADICIONAL + (cALias)->PEDAGIO ) / ZCC->ZCC_QTTTAN

				nRowIni := nRow + 1
				WHILE (_cAliasG)->ZBC_FILIAL == (cALias)->ZFF_FILCON .AND. (_cAliasG)->ZBC_CODIGO == (cALias)->ZFF_CONTRA 
					nCol := 1
					nRow += 1

					oExcel:SetFontConfig(jFontText)
					oExcel:SetCellsFormatConfig(JFLeft)
					oExcel:SetBorderConfig(jNoBorder)

					oExcel:SetValue(nRow, nCol	, ALLTRIM(ZCC->ZCC_FILIAL))
					oExcel:SetValue(nRow, ++nCol, ALLTRIM(ZCC->ZCC_NOMFOR))
					oExcel:SetValue(nRow, ++nCol, ALLTRIM(ZCC->ZCC_CODIGO))

					oExcel:SetCellsFormatConfig(jFNum)
					oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ZBC_QUANT)
					oExcel:SetValue(nRow, ++nCol, Round((_cAliasG)->ZBC_QUANT * nVlrUnit,2))
					
					(_cAliasG)->(DBSkip())
				ENDDO
				nRowFim := nRow
				
				nRow += 1
				oExcel:SetCellsFormatConfig(jFormatHead)
				oExcel:SetFontConfig(jFontHeader)
				oExcel:SetBorderConfig(jNoBorder)
				oExcel:SetValue(nRow, 3	, "Total")

				oExcel:SetCellsFormatConfig(jFormatTot)
				oExcel:SetFormula(nRow, 4, "=SUBTOTAL(9,D"+AllTrim(cValToChar(nRowIni))+":D"+AllTrim(cValToChar(nRowFim))+")" ) // Frete + Pedagio 
				oExcel:SetFormula(nRow, 5, "=SUBTOTAL(9,E"+AllTrim(cValToChar(nRowIni))+":E"+AllTrim(cValToChar(nRowFim))+")" ) // ICMS
				
			else
				ConOut( "Contrato: " +(cALias)->ZFF_CONTRA+ " não encontrado" )
			Endif
			(cALias)->(DBSkip())
		EndDo

		lRet := oExcel:toXlsx() 

		nRet := ShellExecute("open", SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx", "", "", 1)

		//Se houver algum erro
		If nRet <= 32
			MsgStop("Não foi possível abrir o arquivo "+SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx"+ "!", "Atenção")
		EndIf 

		oExcel:DeActivate()

		(cALias)->(DBGoTop())
		(_cAliasG)->(DBGoTop())
Return 

Static Function DefinirFormatacao()
    Local cCVerde       := '00A85A'
    Local cCCinza       := "A0A0A0"
    Local cCAmarelo     := "FFFF00"

    jFontHeader := FwXlsxPrinterConfig():MakeFont()
    jFontHeader['font'] := FwPrinterFont():Calibri()
    jFontHeader['size'] := 12
    jFontHeader['bold'] := .T.

    jFontTitulo := FwXlsxPrinterConfig():MakeFont()
    jFontTitulo['font'] := FwPrinterFont():Calibri()
    jFontTitulo['size'] := 14
    jFontTitulo['bold'] := .T.
    jFontTitulo['underline'] := .T.

    jFontText := FwXlsxPrinterConfig():MakeFont()
    jFontText['font'] := FwPrinterFont():Calibri()
    jFontText['size'] := 12
    jFontText['italic'] := .F.

    JFLeft := FwXlsxPrinterConfig():MakeFormat()
    JFLeft['hor_align']        := oCellHorAlign:Left()
    JFLeft['vert_align']       := oCellVertAlign:Center()

    JFRight := FwXlsxPrinterConfig():MakeFormat()
    JFRight['hor_align']        := oCellHorAlign:RIGHT()
    JFRight['vert_align']       := oCellVertAlign:Center()
    
    jFData := FwXlsxPrinterConfig():MakeFormat()
    jFData['custom_format']    := "dd/mm/yyyy"
    jFData['hor_align']        := oCellHorAlign:Left()
    jFData['vert_align']       := oCellVertAlign:Center()

    jFormatTit := FwXlsxPrinterConfig():MakeFormat()
    jFormatTit['hor_align']         := oCellHorAlign:Center()
    jFormatTit['vert_align']        := oCellVertAlign:Center()
    jFormatTit['background_color']  := cCVerde

    jFormatGD := FwXlsxPrinterConfig():MakeFormat()
    jFormatGD['hor_align']         := oCellHorAlign:Center()
    jFormatGD['vert_align']        := oCellVertAlign:Center()
    jFormatGD['background_color']  := cCAmarelo
    
    jFormatTot := FwXlsxPrinterConfig():MakeFormat()
    jFormatTot['custom_format']     := "\R$ ###,##0.00"
    jFormatTot['hor_align']         := oCellHorAlign:Center()
    jFormatTot['vert_align']        := oCellVertAlign:Center()
    jFormatTot['background_color']  := cCCinza

    jFormatHead := FwXlsxPrinterConfig():MakeFormat()
    jFormatHead['hor_align']         := oCellHorAlign:LEFT()
    jFormatHead['vert_align']        := oCellVertAlign:Center()
    jFormatHead['background_color']  := "A0A0A0" //amarelo

    jFMoeda := FwXlsxPrinterConfig():MakeFormat()
    jFMoeda['custom_format']    := "\R$ ###,##0.00"
    jFMoeda['hor_align']        := oCellHorAlign:RIGHT()
    jFMoeda['vert_align']       := oCellVertAlign:Center()

    jFNum := FwXlsxPrinterConfig():MakeFormat()
    jFNum['hor_align']        := oCellHorAlign:Left()
    jFNum['vert_align']       := oCellVertAlign:Center()

    // Bordas para o header
    jNoBorder := FwXlsxPrinterConfig():MakeBorder()
    jNoBorder['top']    := .F.
    jNoBorder['bottom'] := .F.
    jNoBorder['left']   := .F.
    jNoBorder['right']  := .F.
    jNoBorder['border_color'] := "000000"
    jNoBorder['style'] := FwXlsxBorderStyle():None()

    jBHeaderLeft := FwXlsxPrinterConfig():MakeBorder()
    jBHeaderLeft['top']    := .T.
    jBHeaderLeft['bottom'] := .F.
    jBHeaderLeft['left']   := .T.
    jBHeaderLeft['right']  := .F.
    jBHeaderLeft['border_color'] := "000000"
    jBHeaderLeft['style'] := FwXlsxBorderStyle():Thick()

    jBHeaderRight := FwXlsxPrinterConfig():MakeBorder()
    jBHeaderRight['top']    := .T.
    jBHeaderRight['bottom'] := .F.
    jBHeaderRight['left']   := .F.
    jBHeaderRight['right']  := .T.
    jBHeaderRight['border_color'] := "000000"
    jBHeaderRight['style'] := FwXlsxBorderStyle():Thick()
    
    jBottomLeft := FwXlsxPrinterConfig():MakeBorder()
    jBottomLeft['top']    := .F.
    jBottomLeft['bottom'] := .T.
    jBottomLeft['left']   := .T.
    jBottomLeft['right']  := .F.
    jBottomLeft['border_color'] := "000000"
    jBottomLeft['style'] := FwXlsxBorderStyle():Thick()

    jBottomRight := FwXlsxPrinterConfig():MakeBorder()
    jBottomRight['top']    := .F.
    jBottomRight['bottom'] := .T.
    jBottomRight['left']   := .F.
    jBottomRight['right']  := .T.
    jBottomRight['border_color'] := "000000"
    jBottomRight['style'] := FwXlsxBorderStyle():Thick()

    jBorderLeft := FwXlsxPrinterConfig():MakeBorder()
    jBorderLeft['left'] := .T.
    jBorderLeft['border_color'] := "000000"
    jBorderLeft['style'] := FwXlsxBorderStyle():Thick()
    
    jBorderCenter := FwXlsxPrinterConfig():MakeBorder()
    jBorderCenter['left'] := .T.
    jBorderCenter['right'] := .T.
    jBorderCenter['border_color'] := "000000"
    jBorderCenter['style'] := FwXlsxBorderStyle():Thick()
    
    jBorderRight := FwXlsxPrinterConfig():MakeBorder()
    jBorderRight['right'] := .T.
    jBorderRight['border_color'] := "000000"
    jBorderRight['style'] := FwXlsxBorderStyle():Thick()

Return 

Static Function GeraX1(cPerg)
	Local _aArea	:= GetArea()
	Local aRegs     := {}
	Local nX		:= 0
	Local nPergs	:= 0
	Local j,i

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

	aAdd(aRegs,{cPerg, "01", "Filial de?  		" , "", "", "MV_CH1", "C", TamSX3("ZFF_FILIAL")[1]  , TamSX3("ZFF_FILIAL")[2]  	, 0, "G", ""		, "MV_PAR01", "","","",""		,"",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "02", "Filial Ate? 		" , "", "", "MV_CH2", "C", TamSX3("ZFF_FILIAL")[1]  , TamSX3("ZFF_FILIAL")[2]  	, 0, "G", "NaoVazio", "MV_PAR02", "","","","ZZZZZZZ","",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "03", "Fornecedor de?  	" , "", "", "MV_CH3", "C", TamSX3("ZFF_FORNEC")[1]	, TamSX3("ZFF_FORNEC")[2]	, 0, "G", ""		, "MV_PAR03", "","","",""		,"",""   ,"","","","","","","","","","","","","","","","","","","SA2","","","","",""})
	aAdd(aRegs,{cPerg, "04", "Fornecedor Ate? 	" , "", "", "MV_CH4", "C", TamSX3("ZFF_FORNEC")[1] 	, TamSX3("ZFF_FORNEC")[2] 	, 0, "G", "NaoVazio", "MV_PAR04", "","","","ZZZZZZ"	,"",""   ,"","","","","","","","","","","","","","","","","","","SA2","","","","",""})
	aAdd(aRegs,{cPerg, "05", "Data De?    	  	" , "", "", "MV_CH5", "D", TamSX3("ZFF_DATA")[1]	, TamSX3("ZFF_DATA")[2]		, 0, "G", "NaoVazio", "MV_PAR05", "","","",""		,"",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "06", "Data Ate?   	  	" , "", "", "MV_CH6", "D", TamSX3("ZFF_DATA")[1]	, TamSX3("ZFF_DATA")[2]		, 0, "G", "NaoVazio", "MV_PAR06", "","","",""		,"",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "07", "Contrato:   	  	" , "", "", "MV_CH7", "C", TamSX3("ZFF_CONTRA")[1]	, TamSX3("ZFF_CONTRA")[2]	, 0, "G", ""		, "MV_PAR07", "","","",""		,"",""   ,"","","","","","","","","","","","","","","","","","","ZCC","","","","",""})

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

User Function I04CTN()
	Local aArea			:= FWGetArea()
	Local oModel		:= FWModelActive()
	Local nOpc			:= oModel:GetOperation()
	Local oStru 		:= oModel:GetModel("ZFFMASTER")
	Local oGrid 		:= oModel:GetModel("ZFFDETAIL")
	Local oCte 			:= oModel:GetModel("ZFIDETAIL")
	Local oView			:= FWViewActive()
	Local cQry 			:= ''
	Local cRet 			:= ""
	Local cAlias 		:= GetNextAlias()

	if nOpc == 3
		IF "ZFF_CONTRA" $ ReadVar()
			if !(oGrid:IsEmpty())
				oGrid:ClearData()
				oView:Refresh()
			endif 
			if !(oCte:IsEmpty())
				oCte:ClearData()
				oView:Refresh()
			endif 
			if AllTrim(&(ReadVar())) != ""
				cQry := " select ISNULL(CAST(CAST(ZFF_OBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS OBS,* from "+RetSqlName("ZFF")+" ZFF " + CRLF 
				cQry += " WHERE ZFF_CONTRA = '"+&(ReadVar())+"' " + CRLF 
				cQry += " AND ZFF_FILCON =  '"+fwxFilial("ZFF")+"' " + CRLF
				cQry += " AND ZFF_CODIGO <>  '' " + CRLF
				cQry += " AND ZFF.D_E_L_E_T_ = '' " + CRLF
				cQry += " order by ZFF_ITEM  " + CRLF

				MpSysOpenQry(cQry, cAlias)

				ZFI->(DBSETORDER(3))
				cRet := cFilcont
				WHILE !(cAlias)->(EOF())
					if (cAlias)->ZFF_FILIAL != cFilAnt
						cFilAnt := (cAlias)->ZFF_FILIAL
					ENDIF
					oStru:SetValue("ZFF_CODIGO"	, (cAlias)->ZFF_CODIGO)
					oStru:SetValue("ZFF_FILCON"	, (cAlias)->ZFF_FILCON)
					oStru:SetValue("ZFF_FORNEC"	, (cAlias)->ZFF_FORNEC)
					oStru:SetValue("ZFF_FLOJA"	, (cAlias)->ZFF_FLOJA)
					oStru:SetValue("ZFF_DESTIN"	, (cAlias)->ZFF_DESTIN)
					oStru:SetValue("ZFF_DLOJA"	, (cAlias)->ZFF_DLOJA)
					oStru:SetValue("ZFF_MUN"	, (cAlias)->ZFF_MUN)
					oStru:SetValue("ZFF_EST"	, (cAlias)->ZFF_EST)

					oGrid:SetValue("ZFF_ITEM"	,(cAlias)->ZFF_ITEM)
					oGrid:SetValue("ZFF_PLCVL"	,(cAlias)->ZFF_PLCVL)
					oGrid:SetValue("ZFF_ICTA1"	,(cAlias)->ZFF_ICTA1)
					oGrid:SetValue("ZFF_PLCC1"	,(cAlias)->ZFF_PLCC1)
					oGrid:SetValue("ZFF_ICTA2"	,(cAlias)->ZFF_ICTA2)
					oGrid:SetValue("ZFF_PLCC2"	,(cAlias)->ZFF_PLCC2)
					oGrid:SetValue("ZFF_ICTA3"	,(cAlias)->ZFF_ICTA3)
					oGrid:SetValue("ZFF_NUMMIN"	,(cAlias)->ZFF_NUMMIN)
					oGrid:SetValue("ZFF_TIPVEI"	,(cAlias)->ZFF_TIPVEI)
					oGrid:SetValue("ZFF_MOTOR"	,(cAlias)->ZFF_MOTOR)
					oGrid:SetValue("ZFF_ORIGEM"	,(cAlias)->ZFF_ORIGEM)
					oGrid:SetValue("ZFF_RLOJA"	,(cAlias)->ZFF_RLOJA)
					oGrid:SetValue("ZFF_DATA"	,sToD((cAlias)->ZFF_DATA))
					oGrid:SetValue("ZFF_HREMB"	,(cAlias)->ZFF_HREMB)
					oGrid:SetValue("ZFF_BOIS"	,(cAlias)->ZFF_BOIS)
					oGrid:SetValue("ZFF_VACAS"	,(cAlias)->ZFF_VACAS)
					oGrid:SetValue("ZFF_BUFALO" ,(cAlias)->ZFF_BUFALO)
					oGrid:SetValue("ZFF_TOURO"	,(cAlias)->ZFF_TOURO)
					oGrid:SetValue("ZFF_NOVILH" ,(cAlias)->ZFF_NOVILH)
					oGrid:SetValue("ZFF_DTDESE" ,sToD((cAlias)->ZFF_DTDESE))
					oGrid:SetValue("ZFF_EMPE"	,(cAlias)->ZFF_EMPE)
					oGrid:SetValue("ZFF_CAIDOS"	,(cAlias)->ZFF_CAIDOS)
					oGrid:SetValue("ZFF_EMERGE"	,(cAlias)->ZFF_EMERGE)
					oGrid:SetValue("ZFF_MORTO"	,(cAlias)->ZFF_MORTO)
					oGrid:SetValue("ZFF_QTDE"	,(cAlias)->ZFF_QTDE)
					oGrid:SetValue("ZFF_KM"		,(cAlias)->ZFF_KM)
					oGrid:SetValue("ZFF_VFRETE"	,(cAlias)->ZFF_VFRETE)
					oGrid:SetValue("ZFF_VLKM"	,(cAlias)->ZFF_VLKM )
					oGrid:SetValue("ZFF_ADICIO"	,(cAlias)->ZFF_ADICIO)
					oGrid:SetValue("ZFF_PEDAGI"	,(cAlias)->ZFF_PEDAGI)
					oGrid:SetValue("ZFF_ICMSF"	,(cAlias)->ZFF_ICMSF)
					oGrid:SetValue("ZFF_VCOMP"	,(cAlias)->ZFF_VCOMP)
					oGrid:SetValue("ZFF_OBS"	,(cAlias)->OBS)
					oGrid:SetValue("ZFF_DOC"	,(cAlias)->ZFF_DOC)
					oGrid:SetValue("ZFF_SERIE"	,(cAlias)->ZFF_SERIE)
					
					IF ZFI->(DBSEEK((cAlias)->ZFF_FILIAL+(cAlias)->ZFF_CODIGO+(cAlias)->ZFF_ITEM))
						WHILE ZFI->ZFI_ZFFITE == (cAlias)->ZFF_ITEM
							oCte:SetValue("ZFI_CODIGO"	,ZFI->ZFI_CODIGO)
							oCte:SetValue("ZFI_ITEM"	,ZFI->ZFI_ITEM)
							oCte:SetValue("ZFI_ZFFITE"	,ZFI->ZFI_ZFFITE)
							oCte:SetValue("ZFI_PLACA"	,ZFI->ZFI_PLACA)
							oCte:SetValue("ZFI_DOC"		,ZFI->ZFI_DOC)
							oCte:SetValue("ZFI_SERIE"	,ZFI->ZFI_SERIE)
							oCte:SetValue("ZFI_FORNEC"	,ZFI->ZFI_FORNEC)
							oCte:SetValue("ZFI_LOJA"	,ZFI->ZFI_LOJA)
							oCte:SetValue("ZFI_NFOR"	,ZFI->ZFI_NFOR)
							oCte:SetValue("ZFI_FILDOC"	,ZFI->ZFI_FILDOC)
							oCte:SetValue("ZFI_VALOR"	,ZFI->ZFI_VALOR)

							ZFI->(DBSKIP())
							IF ZFI->ZFI_ZFFITE == (cAlias)->ZFF_ITEM
								oCte:AddLine()
							ENDIF
						ENDDO

					ENDIF

					(cAlias)->(DBSKIP())
					if !(cAlias)->(eof())
						oGrid:AddLine()
					ENDIF 
				ENDDO
				//ZFI->(DBCLOSEAREA(  ))
				(cAlias)->(DBCLOSEAREA())
			Endif 
		ELSE
			if oStru:GetValue("ZFF_COMBO") == 'T'
				oStru:SetValue("ZFF_CONTRA", '')
				oStru:SetValue("ZFF_FILCON", '')
			endif 
		endif
	else
		oModel:SetErrorMessage("","","","","Campo invalido", 'Campo não pode ser alterado!', "") 
		lRet := .F.
	endif
	oGrid:Goline(1)
	FwRestArea(aArea)
Return cRet
//INICIADOR DE CAMPOS NAS DUAS GRIDS
User Function I04INI()
	Local cCampo  	:= Substr( ReadVar(), At('->', ReadVar())+2 )
	Local oModel 	:= FWModelActive()
	Local oGrid  	:= oModel:GetModel("ZFFDETAIL")
	Local oStru  	:= oModel:GetModel("ZFFMASTER")
	Local ogZFI 	:= oModel:GetModel("ZFIDETAIL")
	Local cRet 		
	Local nLine 	:= oGrid:GetQtdLine()
	Local aSaveRows := FWSaveRows()

	if SubStr(cCampo,1,3) == 'ZFF'
		if nLine > 0
			if cCampo == 'ZFF_VCOMP'
				IF oGrid:GetValue("ZFF_ORIGEM") != '000025'
					cRet := oGrid:GetValue("ZFF_VFRETE") +;
							oGrid:GetValue("ZFF_PEDAGI") +;
							oGrid:GetValue("ZFF_ADICIO") +;
							oGrid:GetValue("ZFF_ICMSF")
				ELSE 
					cRet := 0 
				ENDIF 
			else
				cRet := oGrid:GetValue(cCampo)
			endif 
		else
			if TamSX3(cCampo)[3] == 'C'
				cRet := ""
			elseif TamSX3(cCampo)[3] == 'D'
				cRet := sToD("")
			elseif TamSX3(cCampo)[3] == 'N'
				cRet := 0
			endif
		endif
	else
		if cCampo == 'ZFI_CODIGO'
			cRet := oStru:GetValue("ZFF_CODIGO")
		elseif cCampo == 'ZFI_ZFFITE'
			cRet := oGrid:GetValue("ZFF_ITEM")
		elseif cCampo == 'ZFI_PLACA'
			cRet := oGrid:GetValue("ZFF_PLCVL")
		elseif cCampo == 'ZFI_FORNEC'
			cRet := oGrid:GetValue("ZFF_ORIGEM")
		elseif cCampo == 'ZFI_LOJA'
			cRet := oGrid:GetValue("ZFF_RLOJA")
		//elseif cCampo == 'ZFI_NFOR'
		//	cRet := ogZFI:GetValue("ZFI_FORNEC")
		endif
	endif

	FWRestRows(aSaveRows)
Return cRet
//INICIADOR DO CODIGO
User Function I04CDI()
	Local aArea 	:= FWGetArea()
	Local cQry 		:= ''
	Local cRet 		:= ''
	Local cALias 	:= GetNextAlias()
	Local oModel 	:= NIL
	Local oStru 	:= NIL

	if ProcName(5) != "U_I04CTN"
		cQry := "SELECT MAX(ZFF_CODIGO) as CODIGO FROM "+RetSqlName("ZFF")+""

		MpSysOpenQry(cQry, cALias)
			cRet := StrZero(Val((cALias)->CODIGO) + 1,6) 
		(cALias)->(DBCLOSEAREA())

		FWRestArea(aArea)
	else
		oModel		:= FWModelActive()
		oStru 		:= oModel:GetModel("ZFFMASTER")

		cRet := oStru:GetValue("ZFF_CODIGO")
	endif 
Return cRet
//PRE VALIDACAO DO MODEL
User Function I04PREM()
	Local lRet := .T.
	Local oModel 	 	:= FwModelActivate()
	Local oCab 			:= oModel:GetModel("ZFFMASTER")
	Local aCCab		:= StrTokArr("ZFF_FORNEC|ZFF_FLOJA|ZFF_DESTIN|ZFF_DLOJA|ZFF_MUN|ZFF_EST","|")
	Local nI
	Local cTitulo	:= ''
	
	//DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	for nI := 1 To Len(aCCab)
		if Empty(oCab:GetValue(aCCab[nI]))
			if DbSeek(aCCab[nI])
				cTitulo := AllTrim(X3Titulo())
			endif
			oModel:SetErrorMessage("","","","","Campo vazio", 'Preencha o campo '+cTitulo+'!', "") 
			lRet := .F.
			EXIT
		endif
	next nI
	//SX3->(DBCLOSEAREA(  ))

	if lRet
		if oCab:GetValue("ZFF_COMBO") == "T" .AND. !Empty(oCab:GetValue("ZFF_CONTRA"))
			lRet := .F. 
			oModel:SetErrorMessage("","","","","Combo invalido", 'Contrato não pode ser preenchido no Tipo "T - Transferência"', "") 
		elseif oCab:GetValue("ZFF_COMBO") == "C" .AND. Empty(oCab:GetValue("ZFF_CONTRA"))
			lRet := .F. 
			oModel:SetErrorMessage("","","","","Combo invalido", 'Contrato tem que ser preenchido no Tipo "C - Contrato"', "") 
		endif
	endif

Return lRet
//PRE VALIDACAO DA GRID
User Function I04PREG()
	Local aArea	:= GetArea()
	Local lRet := .T.
	Local oModel 	 	:= FwModelActivate()
	Local oCab 			:= oModel:GetModel("ZFFMASTER")
	Local oGrid 		:= oModel:GetModel("ZFFDETAIL")
	Local aCGrid	:= StrTokArr("ZFF_PLCVL|ZFF_NUMMIN|ZFF_TIPVEI|ZFF_MOTOR|ZFF_ORIGEM|ZFF_RLOJA|ZFF_DATA|ZFF_DTDESE|ZFF_QTDE|ZFF_KM|ZFF_VFRETE|ZFF_VLKM","|")
	Local nI
	Local cTitulo	:= ''
	
	SX3->(DbSetOrder(2)) //X3_CAMPO
	for nI := 1 To Len(aCGrid)
		if Empty(oGrid:GetValue(aCGrid[nI]))
			if DbSeek(aCGrid[nI])
				cTitulo := AllTrim(X3Titulo())
			endif
			oModel:SetErrorMessage("","","","","Campo vazio", 'Preencha o campo '+cTitulo+'!', "") 
			lRet := .F.
			EXIT
		endif
	next nI

	if lRet
		If oCab:GetValue("ZFF_COMBO") == "T"
			if Empty(oGrid:GetValue("ZFF_DOC")) .or. Empty(oGrid:GetValue("ZFF_SERIE"))
				oModel:SetErrorMessage("","","","","Campo vazio", 'Preencha o campo NF e Serie!', "") 
				lRet := .F.
			endif 
		endif
	endif 
	RestArea(aArea)
Return lRet

// VALIDACAO DA CTE
User Function I04FIL()
	Local oModel 	:= FwModelActivate()
	Local oCte 		:= oModel:GetModel("ZFIDETAIL")
	
	oCte:LoadValue("ZFI_DOC"	, "")
	oCte:LoadValue("ZFI_SERIE"	, "")
	oCte:LoadValue("ZFI_VALOR"	, 0 )

Return .T. 
// VALIDACAO DA CTE
User Function I04DOC()
	Local aArea 	:= GetArea()
	Local lRet 		:= .T. 
	Local oModel 	:= FwModelActivate()
	Local oView 	:= FWViewActive()
	Local oCte 		:= oModel:GetModel("ZFIDETAIL")
	Local cCte  	:= StrZero( Val(&(ReadVar())),TamSx3("F1_DOC")[1])
	Local cFil 		:= "" 

	//F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC
	DBSELECTAREA( "SF1" )
	SF1->(DBSETORDER( 2 ))

	if AllTrim(oCte:GetValue("ZFI_FILDOC")) == ''
		cFil := FwXFilial("ZFI")
	else
		cFil := oCte:GetValue("ZFI_FILDOC")
	endif

	if SF1->(DbSeek(cFil+;
					oCte:GetValue("ZFI_FORNEC")+;
					oCte:GetValue("ZFI_LOJA")+;
					cCte ))

		oCte:loadValue("ZFI_DOC" , cCte)
		oCte:SetValue("ZFI_SERIE" , SF1->F1_SERIE)
		oCte:SetValue("ZFI_FILDOC", SF1->F1_FILIAL)
		oCte:SetValue("ZFI_VALOR" , SF1->F1_VALBRUT)
	else
		lRet := .F. 
		oModel:SetErrorMessage("","","","","Valor Invalido", 'CTE não existe para esse fornecedor, Ou Filial está incorreta!', "") 
	EndIf
	SF1->(DBCLOSEAREA())

	oView:Refresh()
	RestArea(aArea)
Return lRet
// VALIDACAO DO VALOR DA CTE
User Function I04VAL()
	Local lRet 		:= .T. 
	Local oModel 	:= FwModelActivate()
	Local oCte 		:= oModel:GetModel("ZFIDETAIL")
	Local oGrid		:= oModel:GetModel("ZFFDETAIL")
	Local nI
	Local nSomaCte	:= 0
	Local nSomaF
	
	For nI := 1 to oCte:GetQtdLine()
		oCte:GoLine(nI)
		if !oCte:IsDeleted()
			if oCte:GetValue("ZFI_ZFFITE") == oGrid:GetValue("ZFF_ITEM")
				nSomaCte += oCte:GetValue("ZFI_VALOR")
			endif
		endif
	Next nI

	nSomaF := oGrid:GetValue("ZFF_VFRETE") +;
			oGrid:GetValue("ZFF_PEDAGI") +;
			oGrid:GetValue("ZFF_ADICIO") +;
			oGrid:GetValue("ZFF_ICMSF")

	oGrid:SetValue("ZFF_VCOMP",nSomaF - nSomaCte)
	
Return lRet
// VALIDACAO DO DOC NA ZFF
User Function I04ZDOC()
	Local lRet 		:= .T. 
	//Local oModel 	:= FwModelActivate()
	//Local oGrid		:= oModel:GetModel("ZFFDETAIL")
	
	//IF SF1->F1_FORNECE != oGrid:GetValue("ZFF_ORIGEM")
	//	lRet := .F.
	//	oModel:SetErrorMessage("","","","","NF inválida", 'Fornecedor da NF não é o mesmo cadastrado na GRID!', "")
	//endif
Return lRet

User Function I04PLC()
	Local oModel	:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZFFDETAIL")
	Local aArea 	:= GetArea()
	Local cQry  	:= ''
	Local cRet 		:= ''
	Local cALias 	:= GetNextAlias()
	Local cALiasG 	:= GetNextAlias()

	cQry := " SELECT TOP 1 " +CRLF
	cQry += " * FROM "+RetSqlName("ZFF")+"" +CRLF
	cQry += " WHERE ZFF_PLCVL = '"+ALLTRIM(oGrid:GetValue("ZFF_PLCVL"))+"' " +CRLF
	cQry += " AND D_E_L_E_T_ = '' " +CRLF
	cQry += " ORDER BY R_E_C_N_O_ DESC " +CRLF

	mpSysOpenQuery(cQry,cALias)

	if !(cALias)->(EOF())
		cRet := (cALias)->ZFF_PLCC1
		oGrid:SetValue("ZFF_ICTA1"  ,IIF( EMPTY((cALias)->ZFF_ICTA1),;
										Posicione("ST9",19,FWXFILIAL("ST9")+ALLTRIM(oGrid:GetValue("ZFF_PLCVL")),"T9_ITEMCTA"),;
										(cALias)->ZFF_ICTA1) )
		if !Empty((cALias)->ZFF_PLCC1)
			oGrid:SetValue("ZFF_ICTA2"  ,IIF( EMPTY((cALias)->ZFF_ICTA2),;
											Posicione("ST9",19,FWXFILIAL("ST9")+ALLTRIM(oGrid:GetValue("ZFF_PLCC1")),"T9_ITEMCTA"),;
											(cALias)->ZFF_ICTA2) )
		elseif  !Empty((cALias)->ZFF_PLCC2)		
			oGrid:SetValue("ZFF_PLCC2"  ,(cALias)->ZFF_PLCC2)
			oGrid:SetValue("ZFF_ICTA3"  ,IIF( EMPTY((cALias)->ZFF_ICTA3),;
											Posicione("ST9",19,FWXFILIAL("ST9")+ALLTRIM(oGrid:GetValue("ZFF_PLCC2")),"T9_ITEMCTA"),;
											(cALias)->ZFF_ICTA3) )
		endif
		oGrid:SetValue("ZFF_MOTOR " ,(cALias)->ZFF_MOTOR)
		oGrid:SetValue("ZFF_ORIGEM" ,(cALias)->ZFF_ORIGEM)
		oGrid:SetValue("ZFF_EST" 	,(cALias)->ZFF_EST)
		oGrid:SetValue("ZFF_RLOJA"  ,(cALias)->ZFF_RLOJA)
		oGrid:SetValue("ZFF_NORIG"  ,Posicione("SA2",1,FWXFILIAL("SA2") + (cALias)->ZFF_ORIGEM + (cALias)->ZFF_RLOJA,ALLTRIM("A2_NOME")))
		oGrid:SetValue("ZFF_TIPVEI" ,(cALias)->ZFF_TIPVEI)
		IF oGrid:GetValue("ZFF_KM") != 0
			cQry := " -- USADO NA FUNÇÃO I04PLC() PARA ALTERAR VALOR DO KM" + CRLF
			cQry := " SELECT * " + CRLF
			cQry += " FROM "+RetSqlName("ZFV")+" " + CRLF
			cQry += " WHERE ZFV_TIPVEI = '"+oGrid:GetValue("ZFF_TIPVEI")+"'" + CRLF
			cQry += " AND ZFV_DE <=  '"+iif(Empty(dToS(oGrid:GetValue("ZFF_DTDESE"))),dToS(dDataBase),dToS(oGrid:GetValue("ZFF_DTDESE")))+"'" + CRLF
			cQry += " AND ZFV_ATE >= '"+iif(Empty(dToS(oGrid:GetValue("ZFF_DTDESE"))),dToS(dDataBase),dToS(oGrid:GetValue("ZFF_DTDESE")))+"'" + CRLF
			cQry += " AND ZFV_KMDE <= "+Str(oGrid:GetValue("ZFF_KM"))+"" + CRLF
			cQry += " AND ZFV_KMATE >= "+Str(oGrid:GetValue("ZFF_KM"))+"" + CRLF
			cQry += " AND D_E_L_E_T_ = ''" + CRLF

			mpSysOpenQuery(cQry,cALiasG)

				if cUserName == 'ioliveira'
					memowrite("C:\TOTVS_RELATORIOS\I04PLC.sql", cQry)
				endif

				if !(cALiasG)->(EOF())
					if (cALiasG)->ZFV_TIPPAG == '2'
						oGrid:SetValue("ZFF_VFRETE", (cALiasG)->ZFV_VLKM)
					else
						oGrid:SetValue("ZFF_VFRETE", (cALiasG)->ZFV_VLKM * oGrid:GetValue("ZFF_KM"))
					EndIF
				ENDIF 

			(cALiasG)->(DBCLOSEAREA())
		endif
	endif
	(cALias)->(DBCLOSEAREA())
	RestArea(aArea)
Return cRet

User Function I04ZCC()
	Local aArea 	:= GetArea()
	Local oModel	:= FWModelActive()
	Local oStruct	:= oModel:GetModel("ZFFMASTER")
	Local oView 	:= FWViewActive()
	Local lRet 		:= .T.
	Local cQry  	:= ''
	Local cCodCon 	:= ''
	Local cConsulta := ''
	Local QryOpc	:= 1

	if Type("uRetorno") == 'U' 
		public uRetorno
	endif

	cQry := "select ZCC_CODFOR " + CRLF
	cQry += "		, ZCC_LOJFOR " + CRLF
	cQry += "		, ZCC_NOMFOR " + CRLF
	cQry += "		, ZCC_DTCONT " + CRLF
	cQry += "		, A2_CGC " + CRLF
	cQry += "		, A2_INSCR " + CRLF
	cQry += "		, ZCC_CODIGO " + CRLF
	cQry += "		, ZCC_FILIAL  " + CRLF
	cQry += "		, ZCC.R_E_C_N_O_ as ZCCRECNO " + CRLF
	cQry += "		from "+RetSqlName("ZCC")+" ZCC " + CRLF
	cQry += " join "+RetSqlName("SA2")+"  A2 on A2_COD = ZCC_CODFOR " + CRLF
	cQry += " and A2_LOJA = ZCC_LOJFOR " + CRLF
	cQry += " and A2.D_E_L_E_T_ = '' " + CRLF
	cQry += " where --ZCC_FILIAL = '"+FwxFilial("ZCC")+"' " + CRLF
	//cQry += " --AND ZCC_DTCONT > DATEADD(DAY, -60, GETDATE()) " + CRLF
	cQry += " ZCC_DTCONT > DATEADD(DAY, -60, GETDATE()) " + CRLF
	cQry += " AND ZCC.D_E_L_E_T_ = '' " + CRLF

	cCodCon 	:= "CODIGO"
	cConsulta 	:= "ZCC_CODFOR"

	DBSelectArea("ZCC")
	ZCC->(DBSETORDER( 2 ))
	uRetorno := ''

	if oStruct:GetValue("ZFF_COMBO") == 'T'
		MsgAlert("Informe o campo [ Combo ] tipo [ C - Contrato]","Atenção")
		lRet := .F. 
	else
		uRetorno := PesqZCC(cQry,QryOpc)
		if !Empty(uRetorno)
			ZCC->(DbGoto( uRetorno ))

			__cRet := ZCC->ZCC_CODIGO
			
			cFilcont := ZCC->ZCC_FILIAL
			oStruct:LoadValue("ZFF_FILCON"	,ZCC->ZCC_FILIAL)
			oStruct:SetValue("ZFF_FORNEC"	,ZCC->ZCC_CODFOR)
			oStruct:SetValue("ZFF_FLOJA"	,ZCC->ZCC_LOJFOR)
		else 
			MSGINFO( "Não foi possível filtrar o contrato", "Atenção!" )
			__cRet := ""
		endif
	endif

	if aArea[1] <> "ZCC"
		RestArea( aArea )
	endif

	oView:Refresh()
Return lRet

Static Function PesqZCC(cQry,nQry)
	Local aArea		:= GetArea()
    Local nI 
	Private lRet    := .F.
	Private nOpcQry := nQry
	Private cQuery1 := cQry
	Private cFiltro := ""
	
	Private oPrinc
	Private aColsPri     := {}
	Private aFields      := {} //Campos que aparecerão na grid principal

	Private oSecund
	Private	aColsSec 
	Private aFields2 := {} //Campos que aparecerão na grid secundária
	
	Private oDlg   
	     
	Private cTxtBusca   := Space(30)
	
	Private cTxtAplic   := Space(30)
	Private cCmbInd     := "Nome"
    Private aCamposGrid := {}
    Private cRetorno 

    aCamposGrid := GetFields()
	
	//dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
    For nI := 1 to len(aCamposGrid)
		SX3->(DbSeek(aCamposGrid[nI]))
        aAdd(aFields,{ iif( UPPER(AllTrim(aCamposGrid[nI])) == 'ZCCRECNO','RECNO ZCC',AllTrim(X3TITULO())), "_QRY1->"+aCamposGrid[nI]})
    Next nI
	//SX3->(DBCLOSEAREA( ))

	DEFINE MSDIALOG oDlg TITLE "Pesquisa - contrato" FROM 000, 000  TO 445, 950 COLORS 0, 16777215 PIXEL

	    @ 004, 005 MSCOMBOBOX oCmbInd VAR cCmbInd ITEMS {"FORNECEDOR","CNPJ","DATA","FILIAL"} SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 004, 065 MSGET oTxtBusca VAR cTxtBusca 			SIZE 155, 010 OF oDlg COLORS 0,16777215 PIXEL //Valid(Filtro(3))
	    
	    @ 004, 228 BUTTON oBtnPesq PROMPT "Filtrar" 		SIZE 040, 012 OF oDlg PIXEL ACTION Processa({|| Filtro(1) }, "Aguarde...") 
	    @ 004, 278 BUTTON oBtnLimp PROMPT "&Limpar (F4)"	SIZE 040, 012 OF oDlg PIXEL ACTION Limpar(1) 	    
		SetKey( VK_F4, {|| Limpar(1)} )
		//@ 004, 328 BUTTON oBtnSelC PROMPT "Selecionar"	    SIZE 040, 012 OF oDlg ACTION (SetRetor(1), lRet := .T.) PIXEL
    	@ 004, 428 BUTTON oBtnSair PROMPT "Sair" 			SIZE 040, 012 OF oDlg ACTION (oDlg:End(), lRet := .F.) PIXEL    	

  		@ 020, 003 SCROLLBOX oScrollB1 HORIZONTAL VERTICAL SIZE 200, 468 OF oDlg BORDER
	    GridPrin()                                                                     
       	    
	ACTIVATE MSDIALOG oDlg CENTERED
	
	SetKey( VK_F4,  Nil )
	RestArea(aArea)
Return cRetorno
/* Limpar grid */
Static Function Limpar()
		cTxtBusca := SPACE(30)
		Processa({|| Filtro(1) }, "Aguarde...") 
		oTxtBusca:SetFocus()		
Return
/* Selecionar Lote */
Static Function SetRetor(cEntidade)
	If aColsPri[oPrinc:nAt][1] <> nil

		cRetorno := aColsPri[oPrinc:nAt][Len(aColsPri[oPrinc:nAt])] // pegar recno

		oDlg:End()
	Else
		cEntidade	:= ""
		Alert("Nao há registros filtrados para seleção!")
	Endif
Return

/* Montagem da grid principal */
Static Function GridPrin()
	Local aCab    := {}
	Local nX      := 0

	for nX := 1 to Len(aFields)
		AADD(aColsPri, {nil})
		AADD(aCab, aFields[nX][1])
	next nX
        
    @ 002, 002 LISTBOX oPrinc Fields HEADER "INIT" SIZE 462, 194 OF oScrollB1 PIXEL ColSizes 50,50,150,100,50,20,60 ON DBLCLICK (SetRetor(1), lRet := .T.)
    oPrinc:aHeaders := aCab

	if nOpcQry == 1
		aColsPri := {{nil,nil,nil,nil,nil,nil,nil,nil,nil}}
		oPrinc:SetArray(aColsPri)
		oPrinc:bLine := {|oPrinc| {;
			aColsPri[oPrinc:nAt,1],;
			aColsPri[oPrinc:nAt,2],;
			aColsPri[oPrinc:nAt,3],;
			aColsPri[oPrinc:nAt,4],;
			aColsPri[oPrinc:nAt,5],;
			aColsPri[oPrinc:nAt,6],;
			aColsPri[oPrinc:nAt,7],;
			aColsPri[oPrinc:nAt,8],;
			aColsPri[oPrinc:nAt,9],;
		}}
	endif

	oPrinc:Refresh()
Return
/* 
	Filtro da Grid
*/
Static Function Filtro(nOPFil)
	Local cTxtLike 	:= Upper(AllTrim(cTxtBusca))
	Local aTxtLike	:= {}
	Local i         := 0
	Local nX        := 0

	If " "$cTxtLike
		aTxtLike := FilWord(cTxtLike)
	Endif

	If !Empty(cTxtBusca)
		If cCmbInd == "FORNECEDOR"
			cFiltro := " AND UPPER(ZCC_NOMFOR) LIKE '%" + Upper(AllTrim(cTxtBusca)) + "%'"
		ElseIf cCmbInd == "FILIAL"
			cFiltro := " AND ZCC_FILIAL = '"+Upper(AllTrim(cTxtBusca))+"' "
		ElseIf cCmbInd == "CNPJ"
			If len(aTxtLike)>=1
			 	for i:=1 to len(aTxtLike)
			 		if !(Upper(AllTrim(aTxtLike[i]))$cFiltro)
			 			cFiltro := " AND UPPER(B8_X_CURRA) LIKE '%" + Upper(AllTrim(aTxtLike[i])) + "%'"
			 		endif
			 	next i
			Else
				If !(Upper(AllTrim(cTxtLike))$cFiltro)
					cFiltro := " AND UPPER(A2_CGC) LIKE '%" + Upper(AllTrim(cTxtLike)) + "%'"
				Endif	
			Endif
		Else
			cFiltro := " AND UPPER(ZCC_DTCONT) LIKE '%" + Upper(AllTrim(cTxtBusca)) + "%'"
		Endif

		if nOpcQry == 1
			cOrdem :=  " ORDER BY ZCC_DTCONT DESC "
		endif

	else 
	    cFiltro := " "
		cOrdem  := " "
	endif

	If select("_QRY1") > 0
		_QRY1->(DbCloseArea())
	endif

	MpSysOpenQry(cQuery1 + cFiltro + cOrdem,"_QRY1")
	//TcQuery cQuery1 + cFiltro + cOrdem NEW Alias "_QRY1"

	Count to nCont
	_QRY1->(DbGoTop())
	ProcRegua(nCont)
	
	aColsPri := {{nil,nil,nil,nil,nil,nil,nil,nil,nil}}
	aColsSec := {{nil,nil,nil,nil,nil,nil,nil,nil,nil}}

	If nOPFil == 2
		cFiltro := ''
	Else
		DbSelectArea("_QRY1")
		_QRY1->(DbGoTop())
		Do While !_QRY1->(Eof())
			IncProc("Carregando registros...")
			aAux := {}
 			for nX := 1 to Len(aFields)
				if 'ZCC_DTCONT' $ aFields[nX][2]
					AADD(aAux, DtoC(sToD(&(aFields[nX][2]))))
				else
					AADD(aAux, &(aFields[nX][2]) )
				endif
			next nX
			Aadd(aColsPri, aAux)	
			
			if aColsPri[1][1] == nil
				ADEL(aColsPri, 1)
				ASIZE(aColsPri, len(aColsPri) - 1)		
			endif
			
			_QRY1->(DbSkip())			
		Enddo		
	Endif
	
	if len(aColsPri) == 0
	   	MsgInfo("Registro não encontrado!")
	  
	    oSecund:SetArray(aColsSec)
	    	  
	   	aAux := {}
		for nX := 1 to Len(aFields2)
	    	AADD(aAux, cValToChar(nX))
		next nX
		Aadd(aColsSec,aAux)	
		
		oPrinc:SetArray(aColsPri)
		oPrinc:Refresh()
	else
		oPrinc:SetArray(aColsPri)
	   
		oPrinc:bLine := {|oPrinc| {;
			aColsPri[oPrinc:nAt,1],;
			aColsPri[oPrinc:nAt,2],;
			aColsPri[oPrinc:nAt,3],;
			aColsPri[oPrinc:nAt,4],;
			aColsPri[oPrinc:nAt,5],;
			aColsPri[oPrinc:nAt,6],;
			aColsPri[oPrinc:nAt,7],;
			aColsPri[oPrinc:nAt,8],;
			aColsPri[oPrinc:nAt,9],;
		}}

		oPrinc:Refresh()
		oPrinc:GoTop()
		oPrinc:SetFocus()		
	endif		
	If nOPFil = 3
 		Return .t.
	Endif
Return
/* 
	Pega os Campos do SQL 
*/
Static Function GetFields()
    Local aCamp := {}
    Local nI

    for nI := 1 to len(AllTrim(cQuery1))
        if SubStr(cQuery1,nI,4) == 'ZCC_' .OR. SubStr(cQuery1,nI,3) == 'A2_'
            aAdd(aCamp, AllTrim( SubStr(cQuery1,nI,At(" ",cQuery1,nI)-nI)))
        elseif SubStr(cQuery1,nI,8) == "ZCCRECNO"
            aAdd(aCamp, AllTrim( SubStr(cQuery1,nI,At(" ",cQuery1,nI)-nI)))
        endif

        if Upper(SubStr(cQuery1,nI,4)) == 'FROM'
            exit 
        EndIf
    Next nI 
Return aCamp

Static Function FilWord(cWord)
	Local cTxtPesq	:= Alltrim(cWord)
	Local i         := 0
	Local cTxtAux 	:= ""
	Local aRetTxt	:= {}
	
	For i:=1 to len(cTxtPesq)
		If !(Substr(cTxtPesq,i,1) == " ")
			cTxtAux := cTxtAux+Substr(cTxtPesq,i,1)
		Else  
			if !Empty(cTxtAux) 
				Aadd(aRetTxt,cTxtAux)
			Endif
			cTxtAux:= ""
		Endif  
	next i
	If !Empty(cTxtAux)
		Aadd(aRetTxt,cTxtAux)
		cTxtAux:= ""
	Endif
              
Return aRetTxt

User Function I04VCON()
	Local aArea		:= GetArea()
	Local oModel	:= FWModelActive()
	Local oStruct 	:= oModel:GetModel("ZFFMASTER")
	Local lRet 		:= .T. 
	Local cQry 		:= ""

	if oStruct:GetValue("ZFF_COMBO") != "T"
		if !Empty(oStruct:GetValue("ZFF_FILCON"))
			cQry := "SELECT * FROM "+RetSqlName("ZCC")+" WHERE ZCC_FILIAL = '"+oStruct:GetValue("ZFF_FILCON")+"' AND ZCC_CODIGO = '"+oStruct:GetValue("ZFF_CONTRA")+"' AND D_E_L_E_T_ = '' "
			mpSysOpenQuery(cQry, cAlias := GetNextAlias())

			if (cALias)->(EOF())
				oModel:SetErrorMessage("","","","","Contrato invalido", 'Contrato não existe para essa filial', "") 
				lRet := .F.
			endif 
			(cALias)->(DbCloseArea())
		else 
			oModel:SetErrorMessage("","","","","Contrato invalido", 'Preencha o contrato pela consulta', "") 
			lRet := .F.
		endif
	endif 

	RestArea(aArea)
Return lRet
