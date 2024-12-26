#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Análise das Carretas"
/*/{Protheus.doc} VAUSIN01
    (long_description)
    @type  Function
    @author Igor Oliveira
    @since 16/08/2023
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function VAUSIN01()
    Local aArea		 := FWGetArea()
	Local oBrowse
	Private aCTE 	 := {}
	Private _cPlacaS := CriaVar('ZPB_PLACA'  , .F.)

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZAL")
	oBrowse:SetOnlyFields({'ZAL_CODIGO','ZAL_NF','ZAL_HORA','ZAL_DATA','ZAL_TURNO','ZAL_PLACA','ZAL_FORNEC','ZAL_NOME'})
    oBrowse:SetFilterDefault("ZAL->ZAL_TIPO == '1'")
	oBrowse:AddLegend( "ZAL->ZAL_PROC == 'N'", "GREEN"	,"Pendente" )
	oBrowse:AddLegend( "ZAL->ZAL_PROC == 'S'", "RED"	,"Processado" )
	oBrowse:AddLegend( "ZAL->ZAL_PROC == ''" , "BLACK"	,"Vazio" ) 	
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 		:= nil
    Local oStCab   		:= FWFormStruct(1, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_CODIGO|ZAL_NF|ZAL_HORA|ZAL_TIPO|ZAL_DATA|ZAL_TURNO|ZAL_ZPBCOD|ZAL_PLACA|ZAL_DTPES|ZAL_PESOF|ZAL_FORNEC|ZAL_LOJA|ZAL_NOME|ZAL_MSEC1|ZAL_MSEC2|ZAL_PROC" })
    Local oStVista  	:= FWFormStruct(1, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_KGM3|ZAL_TFERM|ZAL_TALCOL|ZAL_FOLU|ZAL_MATSEX" })
    Local oStFornec 	:= FWFormStruct(1, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_FKGM3|ZAL_FTFERM|ZAL_FTALCO|ZAL_FFOLU|ZAL_FMATSE" })
    Local oStMedia  	:= FWFormStruct(1, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_MKGM3|ZAL_MTFERM|ZAL_MTALCO|ZAL_MFOLU|ZAL_MMATSE" })
    Local bSaveZAL      := {|| SaveZAL()}
	
    oStVista:SetProperty( 'ZAL_KGM3' 	, MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_zTgUs01(1,'ZAL_KGM3'	,'ZAL_FKGM3' ,'ZAL_MKGM3')"		) )
    oStVista:SetProperty( 'ZAL_TFERM' 	, MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_zTgUs01(1,'ZAL_TFERM'	,'ZAL_FTFERM','ZAL_MTFERM')"	) )
    oStVista:SetProperty( 'ZAL_TALCOL' 	, MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_zTgUs01(1,'ZAL_TALCOL','ZAL_FTALCO','ZAL_MTALCO')"	) )
    oStVista:SetProperty( 'ZAL_FOLU' 	, MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_zTgUs01(1,'ZAL_FOLU'	,'ZAL_FFOLU' ,'ZAL_MFOLU')"		) )
    oStVista:SetProperty( 'ZAL_MATSEX' , MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_zTgUs01(1,'ZAL_MATSEX','ZAL_FMATSE' ,'ZAL_MMATSE')"	) )

    oStFornec:SetProperty( 'ZAL_FKGM3' 	, MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_zTgUs01(1,'ZAL_KGM3'	,'ZAL_FKGM3' ,'ZAL_MKGM3')"		) )
    oStFornec:SetProperty( 'ZAL_FTFERM' , MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_zTgUs01(1,'ZAL_TFERM'	,'ZAL_FTFERM','ZAL_MTFERM')"	) )
    oStFornec:SetProperty( 'ZAL_FTALCO' , MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_zTgUs01(1,'ZAL_TALCOL','ZAL_FTALCO','ZAL_MTALCO')"	) )
    oStFornec:SetProperty( 'ZAL_FFOLU' 	, MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_zTgUs01(1,'ZAL_FOLU'	,'ZAL_FFOLU' ,'ZAL_MFOLU')"		) )
    oStFornec:SetProperty( 'ZAL_FMATSE' , MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_zTgUs01(1,'ZAL_MATSEX','ZAL_FMATSE','ZAL_MMATSE')"	) )

	oStCab:SetProperty("ZAL_PESOF", MODEL_FIELD_WHEN, {|| .F.})

	oModel := MPFormModel():New("USIN01M",/*Pre-Validacao*/, /*Pos-Validacao*/, bSaveZAL)

	oModel:AddFields("ZALMASTER",/*cOwner*/  ,oStCab		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddFields("ZALVISTA" ,"ZALMASTER"  ,oStVista		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddFields("ZALFORNEC","ZALMASTER"  ,oStFornec	, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddFields("ZALMEDIA" ,"ZALMASTER"  ,oStMedia		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )

	oModel:SetPrimaryKey({"ZAL_FILIAL"+"ZAL_CODIGO"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZALMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	
Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAUSIN01")
	Local oStCab   		:= FWFormStruct(2, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_CODIGO|ZAL_NF|ZAL_HORA|ZAL_TIPO|ZAL_DATA|ZAL_TURNO|ZAL_ZPBCOD|ZAL_PLACA|ZAL_DTPES|ZAL_PESOF|ZAL_FORNEC|ZAL_LOJA|ZAL_NOME|ZAL_MSEC1|ZAL_MSEC2|ZAL_PROC" })
    Local oStVista  	:= FWFormStruct(2, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_KGM3|ZAL_TFERM|ZAL_TALCOL|ZAL_FOLU|ZAL_MATSEX" })
    Local oStFornec 	:= FWFormStruct(2, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_FKGM3|ZAL_FTFERM|ZAL_FTALCO|ZAL_FFOLU|ZAL_FMATSE" })
    Local oStMedia  	:= FWFormStruct(2, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_MKGM3|ZAL_MTFERM|ZAL_MTALCO|ZAL_MFOLU|ZAL_MMATSE" })
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZAL"	, oStCab  	, "ZALMASTER")
	oView:AddField("VIEW_VISTA"	, oStVista  , "ZALVISTA")
	oView:AddField("VIEW_FORNEC", oStFornec , "ZALFORNEC")
	oView:AddField("VIEW_MEDIA"	, oStMedia  , "ZALMEDIA")
    
	oView:CreateHorizontalBox('CABEC' , 40 )
	oView:CreateHorizontalBox('VISTA' , 20 )
	oView:CreateHorizontalBox('FORNEC', 20 )
	oView:CreateHorizontalBox('MEDIA' , 20 )
	
	oView:SetOwnerView("VIEW_ZAL"	 , "CABEC")
	oView:SetOwnerView("VIEW_VISTA"	 , "VISTA")
	oView:SetOwnerView("VIEW_FORNEC" , "FORNEC")
	oView:SetOwnerView("VIEW_MEDIA"	 , "MEDIA")
	
	oView:EnableTitleView('VIEW_ZAL'   , cTitulo)
	oView:EnableTitleView('VIEW_VISTA' , "Análise V@")
	oView:EnableTitleView('VIEW_FORNEC', "Análise Fornecedor")
	oView:EnableTitleView('VIEW_MEDIA' , "Média")
	
	oView:SetCloseOnOk( { |oView| .T. } )
Return oView

Static Function SaveZAL()
    Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local nOpc      := oModel:GetOperation()
	Local oStCab    := oModel:GetModel('ZALMASTER')/* :SetUniqueLine({'ZAL_CODIGO'}) */
	Local oStVista  := oModel:GetModel('ZALVISTA')/* :SetUniqueLine({'ZAL_CODIGO'}) */
	Local oStFornec := oModel:GetModel('ZALFORNEC')/* :SetUniqueLine({'ZAL_CODIGO'}) */
	Local oStMedia  := oModel:GetModel('ZALMEDIA')/* :SetUniqueLine({'ZAL_CODIGO'}) */

	//Se for Exclusão
	DbSelectArea('ZAL')
	ZAL->(DbSetOrder(1)) // ZAL_FILIAL + ZAL_CODIGO
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE

		RecLock('ZAL', lRecLock := !DbSeek( FWxFilial("ZAL")    +;
									oStCab:GetValue('ZAL_CODIGO') ))

			ZAL_FILIAL := FWxFilial("ZAL")
			ZAL_CODIGO := oStCab:GetValue('ZAL_CODIGO')
			ZAL_TIPO   := oStCab:GetValue('ZAL_TIPO')
			ZAL_DATA   := oStCab:GetValue('ZAL_DATA')
			ZAL_HORA   := oStCab:GetValue('ZAL_HORA')
			ZAL_TURNO  := oStCab:GetValue('ZAL_TURNO')
			ZAL_PLACA  := oStCab:GetValue('ZAL_PLACA')
			ZAL_NF     := oStCab:GetValue('ZAL_NF')
			ZAL_FORNEC := oStCab:GetValue('ZAL_FORNEC')
			ZAL_LOJA   := oStCab:GetValue('ZAL_LOJA')
			ZAL_ZPBCOD := oStCab:GetValue('ZAL_ZPBCOD')
			ZAL_DTPES  := oStCab:GetValue('ZAL_DTPES')
			ZAL_PESOF  := oStCab:GetValue('ZAL_PESOF')
			ZAL_PROC   := oStCab:GetValue('ZAL_PROC')
			ZAL_KGM3   := oStVista:GetValue('ZAL_KGM3')
			ZAL_TFERM  := oStVista:GetValue('ZAL_TFERM')
			ZAL_TALCOL := oStVista:GetValue('ZAL_TALCOL')
			ZAL_FOLU   := oStVista:GetValue('ZAL_FOLU')
			ZAL_MATSEX := oStVista:GetValue('ZAL_MATSEX')
			ZAL_FKGM3  := oStFornec:GetValue('ZAL_FKGM3')
			ZAL_FTFERM := oStFornec:GetValue('ZAL_FTFERM')
			ZAL_FTALCO := oStFornec:GetValue('ZAL_FTALCO')
			ZAL_FFOLU  := oStFornec:GetValue('ZAL_FFOLU')
			ZAL_FMATSE := oStFornec:GetValue('ZAL_FMATSE')
			ZAL_MKGM3  := oStMedia:GetValue('ZAL_MKGM3')
			ZAL_MTFERM := oStMedia:GetValue('ZAL_MTFERM')
			ZAL_MTALCO := oStMedia:GetValue('ZAL_MTALCO')
			ZAL_MFOLU  := oStMedia:GetValue('ZAL_MFOLU')
			ZAL_MMATSE := oStMedia:GetValue('ZAL_MMATSE')

			ZAL->(MsUnlock())
	elseIf nOpc == MODEL_OPERATION_DELETE
		//Se conseguir posicionar, exclui o registro
		If ZAL->(DbSeek( FWxFilial("ZAL") +;
							oStCab:GetValue('ZAL_CODIGO') ))

			RecLock('ZAL', .F.)
				ZAL->(DbDelete())
			ZAL->(MsUnlock())
		EndIf
	EndIf

	//Se não for inclusão, volta o INCLUI para .T. (bug ao utilizar a Exclusão, antes da Inclusão)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

	RestArea(aArea)
Return .T.

User Function USIN01M()
	Local aParam 		:= PARAMIXB
	Local xRet 			:= .T.
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local cIdIXB5		:= ''
	Local cIdIXB4		:= ''
	Local oModel 	 	:= nil
	Local oCab 			:= nil
	Local oMdPrin 		:= nil
	Local oMdSec 		:= nil
	Local oMdDest 		:= nil

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

		if Alltrim(cIdPonto) == "MODELPOS" .and.  Alltrim(cIdModel) == "USIN01M"
			oModel  := FWModelActive()
			oCab    := oModel:GetModel("ZALMASTER" )
			oMdPrin := oModel:GetModel("ZALVISTA"  )
			oMdSec 	:= oModel:GetModel("ZALFORNEC" )
			oMdDest := oModel:GetModel("ZALMEDIA"  )

			if oModel:GetOperation() == 4 .and. oCab:GetValue("ZAL_PROC") == 'S'
				cQry := "select R_E_C_N_O_ RECNO from "+RetSqlName("ZAC")+" WHERE D_E_L_E_T_ = '' AND ZAC_RECZAL = '"+cValToChar(ZAL->(Recno()))+"'"
				
				cAlias := GetNextAlias()
				MpSysOpenQuery(cQry, cAlias)

				if !(cAlias)->(EOF())
					DbSelectArea("ZAC")
						
					ZAC->(DBGoTo((cAlias)->RECNO))
						Reclock("ZAC",.F.)
							ZAC->ZAC_DENSI := oMdPrin:GetValue("ZAL_KGM3")
							ZAC->ZAC_GLVA  := oMdPrin:GetValue("ZAL_TALCOL")
							ZAC->ZAC_MSVA  := oMdPrin:GetValue("ZAL_MATSEX")
							ZAC->ZAC_GLFOR := oMdSec:GetValue("ZAL_FTALCO")
							ZAC->ZAC_MSFOR := oMdSec:GetValue("ZAL_FMATSE")
						ZAC->(MsUnLock())
					ZAC->(DBCloseArea())
				endif

				(cAlias)->(DbCloseArea())
			endif 
			xRet := .T.
		ENDIF
	ENDIF
Return xRet
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VAUSIN01' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VAUSIN01' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAUSIN01' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VAUSIN01' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 
Return aRotina

User Function US01ZPB()
    Local aArea	 := GetArea()
	Local oDlg, oLbx
    Local aCpos  := {}
    Local aRet   := {}
    Local _cQry  := ""
    Local cAlias := GetNextAlias()
    Local lRet   := .F.
    Local cArquivo      := "C:\TOTVS_RELATORIOS\"
    Local cPerg         := FunName()
	Local oView		    := FWViewActive()
	Local oModel  	    := FWModelActive()
	Local oStCab          := oModel:GetModel('ZALMASTER')
	
	_cQry := " Select   ZPB_FILIAL" + CRLF
	_cQry += "		,  ZPB_DATA " 	+ CRLF
	_cQry += "		,  ZPB_HORAF " 	+ CRLF
	_cQry += "		,  ZPB_CODIGO " + CRLF
	_cQry += "		,  ZPB_CODFOR " + CRLF
	_cQry += "		,  ZPB_LOJFOR " + CRLF
	_cQry += "		,  ZPB_NOMFOR " + CRLF
	_cQry += "		,  ZPB_PLACA  " + CRLF
	_cQry += "		,  ZPB_PESOE  " + CRLF
	_cQry += "		,  ZPB_PESOS  " + CRLF
	_cQry += "		,  ZPB_PESOL " 	+ CRLF
	_cQry += "		,  ZPB_NOMMOT " + CRLF
	_cQry += "		,  ZPB_NOTFIS " + CRLF
	_cQry += "	FROM "+RetSqlName("ZPB")+" ZPB " + CRLF
	_cQry += "	WHERE   ZPB_FILIAL = '"+FwxFilial('ZPB')+"'" + CRLF 
	_cQry += "		AND ZPB_DATA BETWEEN  DATEADD(DAY,-30,'"+ DtoS(oStCab:GetValue("ZAL_DATA"))+"') AND DATEADD(DAY,2,'"+ DtoS(oStCab:GetValue("ZAL_DATA"))+"')" + CRLF 
	_cQry += "		AND ZPB_PRODUT IN ('020194','020138')" + CRLF // CREME DE LEVEDURA
	//_cQry += "		AND ZPB_PRODUT IN ('020138')" + CRLF // LEVEDURA
	_cQry += "		AND ZPB_PESOE > 0" + CRLF
	_cQry += "		AND ZPB_PESOS > 0" + CRLF
	_cQry += "				AND ZPB_FILIAL + ZPB_DATA + ZPB_DATAF + ZPB_CODIGO NOT IN (SELECT ZAL_FILIAL + ZAL_DTPES + ZPB_DATAF  + ZAL_ZPBCOD  " + CRLF
	_cQry += "															FROM "+RetSqlName("ZAL")+" ZAL" + CRLF
	_cQry += "															JOIN "+RetSqlName("ZPB")+" ZPB ON ZAL_FILIAL = ZPB_FILIAL" + CRLF
	_cQry += "																AND ZPB_DATA  = ZAL_DTPES " + CRLF
	_cQry += "																AND ZPB_CODIGO = ZAL_ZPBCOD" + CRLF
	_cQry += "																AND ZPB_PLACA  = ZAL_PLACA" + CRLF
	_cQry += "																AND ZPB.D_E_L_E_T_ = ''" + CRLF
	_cQry += "															WHERE ZAL.D_E_L_E_T_ = '' ) " + CRLF
	_cQry += "		AND ZPB.D_E_L_E_T_ = ''" + CRLF
	_cQry += "		ORDER BY 2 DESC " + CRLF

 	If lower(cUserName) $ 'bernardo,ioliveira,atoshio'
		MemoWrite(StrTran(cArquivo,".xml","")+cPerg+".sql" , _cQry)
	EndIf
    // _cQry := ChangeQuery(_cQry)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAlias,.T.,.T.)

    While !(cAlias)->(EOF())
        aAdd(aCpos,{		(cAlias)->ZPB_DATA,;
				    		(cAlias)->ZPB_HORAF,;
					AllTrim((cAlias)->ZPB_CODIGO),;
					AllTrim((cAlias)->ZPB_NOTFIS),;
					AllTrim((cAlias)->ZPB_CODFOR),;
					AllTrim((cAlias)->ZPB_LOJFOR),;
					AllTrim((cAlias)->ZPB_NOMFOR),;
					AllTrim((cAlias)->ZPB_PLACA),;
							(cAlias)->ZPB_PESOE,;
							(cAlias)->ZPB_PESOS,;
							(cAlias)->ZPB_PESOL,;
					AllTrim((cAlias)->ZPB_NOMMOT)})
        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())

    If Len(aCpos) < 1
        aAdd(aCpos,{"","","","","","","","","","","",""})
    EndIf

    DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Listagem das Pesagens" FROM 0,0 TO 325,1250 PIXEL

    @ 0,0 LISTBOX oLbx FIELDS HEADER 'DATA' /*"Produto"*/,;
        'HORA F.',;
		'CODIGO',;
		'NOTA FISCAL',;
		'COD FORNEC',;
		'LOJA FORNEC',;
		'FORNECEDOR',;
		'PLACA',;
		'PESO E.',;
		'PESO S.',;
		'PESO L.',;
		'MOTORISTA' SIZE 630,150 OF oDlg PIXEL

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
                            aCpos[oLbx:nAt,10],;
                            aCpos[oLbx:nAt,11],;
                            aCpos[oLbx:nAt,12]}}
    oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {sToD(oLbx:aArray[oLbx:nAt,1]),;
                            oLbx:aArray[oLbx:nAt,2],;
                            oLbx:aArray[oLbx:nAt,3],;
                            oLbx:aArray[oLbx:nAt,4],;
                            oLbx:aArray[oLbx:nAt,5],;
                            oLbx:aArray[oLbx:nAt,6],;
                            oLbx:aArray[oLbx:nAt,7],;
                            oLbx:aArray[oLbx:nAt,8],;
                            oLbx:aArray[oLbx:nAt,9],;
                            oLbx:aArray[oLbx:nAt,10],;
                            oLbx:aArray[oLbx:nAt,11],;
                            oLbx:aArray[oLbx:nAt,12]}}}
    DEFINE SBUTTON FROM 150,590 TYPE 1 ACTION (oDlg:End(), lRet:=.T.,;
        aRet := {sToD(oLbx:aArray[oLbx:nAt,1]),;
                 oLbx:aArray[oLbx:nAt,2],;
                 oLbx:aArray[oLbx:nAt,3],;
                 oLbx:aArray[oLbx:nAt,4],;
                 oLbx:aArray[oLbx:nAt,5],;
                 oLbx:aArray[oLbx:nAt,6],;
                 oLbx:aArray[oLbx:nAt,7],;
                 oLbx:aArray[oLbx:nAt,8],;
                 oLbx:aArray[oLbx:nAt,9],;
                 oLbx:aArray[oLbx:nAt,10],;
                 oLbx:aArray[oLbx:nAt,11],;
                 oLbx:aArray[oLbx:nAt,12]})  ENABLE OF oDlg
    ACTIVATE MSDIALOG oDlg CENTER

    If Len(aRet) > 0 .And. lRet
        If Empty(aRet[6])
            lRet := .F.
        Else
			 _cPlacaS	:= aRet[8]
			oStCab:SetValue("ZAL_ZPBCOD"  , aRet[3])
			oStCab:SetValue("ZAL_DTPES"   , aRet[1])
			oStCab:SetValue("ZAL_NF"      , aRet[4])
			oStCab:SetValue("ZAL_FORNEC"  , aRet[5])
			oStCab:SetValue("ZAL_LOJA"    , aRet[6])
			oStCab:SetValue("ZAL_NOME"    , aRet[7])
			oStCab:SetValue("ZAL_PESOF"   , aRet[11])
        EndIf
    EndIf
	
	IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
	    MemoWrite(StrTran(cArquivo,".xml","")+"ZPB_"+cPerg + cValToChar(dDataBase)+".sql" , _cQry)
    ENDIF

	oView:Refresh()
	RestArea(aArea)
RETURN lRet

User Function US01TIPO()
    Local cRet := ""

    if FunName() == "VAUSIN01" //1=Analise das Carretas
        cRet := "1"
    elseIf FunName() == "VAUSIN02" //2=Analise Levedo Tanque Circulacao
        cRet := "2"
    elseIf FunName() == "VAUSIN03" //3=Analise Levedo Concentrador
        cRet := "3"
    else // 4=Analise do Tanque Estabilizado
        cRet := "4" 
    EndIF 
Return cRet 

User Function CheckTime(pHora)
	Local lRet := .T.
	Local cH := SubStr(pHora,1,2)
	Local cM := SubStr(pHora,4,2)
	
	If Len(AllTrim(pHora)) < 5
		Return .F.
	EndIf
	
	If (Val(cH) < 0) .or. (Val(cH) > 23)
		Return .F.
	EndIf 
	
	If (Val(cM) < 0) .or. (Val(cM) > 59)
Return .F.
	EndIf
Return lRet
//Gatilho de Hora Para Turno\\\\\\\\\\\\\
User Function USIGHO(cHora)
	Local cRet := ""

	if Val(SubStr(cHora,1,2)) >= 7 .and. Val(SubStr(cHora,1,2)) < 14 
		cRet := 'M'
	elseif Val(SubStr(cHora,1,2)) >= 14 .and. Val(SubStr(cHora,1,2)) < 22
		cRet := 'T'
	elseif Val(SubStr(cHora,1,2)) >= 22 .or. Val(SubStr(cHora,1,2)) < 7
		cRet := 'N'
	endif 
Return cRet 
 
User Function USIMSEC()
	Local nRet 			:= 0
	Local oModel  	    := FWModelActive()
	Local oStCab        := oModel:GetModel('ZALMASTER')
	
	IF oStCab:GetValue("ZAL_MSEC1") != 0 .AND. oStCab:GetValue("ZAL_MSEC2") != 0
		nRet := (oStCab:GetValue("ZAL_MSEC1") + oStCab:GetValue("ZAL_MSEC2")) / 2
	ELSEIF  oStCab:GetValue("ZAL_MSEC1") == 0
		nRet := oStCab:GetValue("ZAL_MSEC2")
	ELSEIF oStCab:GetValue("ZAL_MSEC2") == 0
		nRet := oStCab:GetValue("ZAL_MSEC1") 
	endif 

Return nRet

User Function zTgUs01(nOpc,cField1,cField2,cDest)
	Local oModel 	:= FwModelActive()
	Local oMdPrin 	:= oModel:GetModel("ZALVISTA" )
	Local oMdSec 	:= oModel:GetModel("ZALFORNEC")
	Local oMdDest 	:= oModel:GetModel("ZALMEDIA")
	Local lRet 		:= .T.

	if oMdPrin:GetValue(cField1) > 0 .and. oMdSec:GetValue(cField2) > 0
		oMdDest:SetValue(cDest,(oMdPrin:GetValue(cField1) + oMdSec:GetValue(cField2) )/ 2 )
	else 
		oMdDest:SetValue(cDest, 0 )
	endif 

Return lRet 

User Function USIN1XE()
    Local cRet 		:= ""
    Local aArea 	:= GetArea()
    Local cALias 	:= GetNextAlias()

    MpSysOpenQuery("SELECT MAX(ZAL_CODIGO) + 1 AS MAX FROM "+RetSqlName("ZAL")+" ", cAlias)

    if (cAlias)->(EOF())
        cRet := "000001"
    else
        cRet := StrZero((cAlias)->MAX,TamSX3("ZAL_CODIGO")[1])
    endif

    (cAlias)->(dbCloseArea())
    
    RestArea(aArea)

Return cRet 
