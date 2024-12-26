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
    oBrowse:SetFilterDefault("ZAL->ZAL_TIPO == '1'")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 		:= nil
    Local oCab   		:= FWFormStruct(1, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_CODIGO|ZAL_NF|ZAL_MATSEX|ZAL_HORA|ZAL_TIPO|ZAL_DATA|ZAL_TURNO|ZAL_ZPBCOD|ZAL_PLACA|ZAL_DTPES|ZAL_KGM3|ZAL_TFERM|ZAL_TALCOL|ZAL_FOLU|ZAL_PESOF|ZAL_FORNEC|ZAL_LOJA|ZAL_NOME" })

	oModel := MPFormModel():New("USIN01M",,/* bSaveZAL */)

	oModel:AddFields("ZALMASTER",/*cOwner*/  ,oCab		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	//oModel:AddGrid('ZALDETAIL', 'ZALMASTER'	, oGrid, /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,{|| I06LOAD()})

	oModel:SetPrimaryKey({"ZAL_FILIAL"+"ZAL_CODIGO"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZALMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	
Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAUSIN01")
	Local oCab   		:= FWFormStruct(2, 'ZAL', {|cCampo| AllTrim(cCampo) $ "ZAL_CODIGO|ZAL_NF|ZAL_MATSEX|ZAL_HORA|ZAL_TIPO|ZAL_DATA|ZAL_TURNO|ZAL_ZPBCOD|ZAL_PLACA|ZAL_DTPES|ZAL_KGM3|ZAL_TFERM|ZAL_TALCOL|ZAL_FOLU|ZAL_PESOF|ZAL_FORNEC|ZAL_LOJA|ZAL_NOME" })
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZAL", oCab  , "ZALMASTER")
    
	oView:CreateHorizontalBox('CABEC', 100 )
	
	oView:SetOwnerView("VIEW_ZAL"	 , "CABEC")
	
	oView:EnableTitleView('VIEW_ZAL'  , cTitulo)
	
	oView:SetCloseOnOk( { |oView| .T. } )
Return oView

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAUSIN01' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VAUSIN01' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VAUSIN01' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
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
	Local oCab          := oModel:GetModel('ZALMASTER')

	_cQry := " Select   ZPB_FILIAL" + CRLF 
	_cQry += "		,  ZPB_DATA " + CRLF 
	_cQry += "		,  ZPB_HORAF " + CRLF 
	_cQry += "		,  ZPB_CODIGO " + CRLF 
	_cQry += "		,  ZPB_CODFOR " + CRLF 
	_cQry += "		,  ZPB_LOJFOR " + CRLF 
	_cQry += "		,  ZPB_NOMFOR " + CRLF 
	_cQry += "		,  ZPB_PLACA  " + CRLF 
	_cQry += "		,  ZPB_PESOE  " + CRLF 
	_cQry += "		,  ZPB_PESOS  " + CRLF 
	_cQry += "		,  ZPB_PESOL " + CRLF 
	_cQry += "		,  ZPB_NOMMOT " + CRLF 
	_cQry += "		,  ZPB_NOTFIS " + CRLF 
	_cQry += "	FROM "+RetSqlName("ZPB")+" ZPB " + CRLF
	_cQry += "	WHERE   ZPB_FILIAL = '"+FwxFilial('ZPB')+"'" + CRLF 
	_cQry += "		AND ZPB_DATA BETWEEN  DATEADD(DAY,-2,'"+ DtoS(oCab:GetValue("ZAL_DATA"))+"') AND DATEADD(DAY,2,'"+ DtoS(oCab:GetValue("ZAL_DATA"))+"')" + CRLF 
	//_cQry += "		AND ZPB_DATA >= DATEADD(DAY,-365, '"+ DtoS(oCab:GetValue("ZAL_DATA"))+"')" + CRLF 
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
			oCab:SetValue("ZAL_ZPBCOD"  , aRet[3])
			oCab:SetValue("ZAL_DTPES"   , aRet[1])
			oCab:SetValue("ZAL_NF"      , aRet[4])
			oCab:SetValue("ZAL_FORNEC"  , aRet[5])
			oCab:SetValue("ZAL_LOJA"    , aRet[6])
			oCab:SetValue("ZAL_NOME"    , aRet[7])
			oCab:SetValue("ZAL_PESOF"   , aRet[11])
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
/* 
User Function VAESTI0()
    Local aParamBox     := {}
    Local aRetParam     := {}
    Local aTipos        := Separa(AllTrim(GetSX3Cache("ZAL_TIPO", "X3_CBOX")),";",.f.)
    Private cCpoRet       := ""
    Private aZALCampos  := {}

    aAdd(aParamBox,{3,"Tipo do Cadastro:",1,aTipos,100,"",.F.})

    if  ParamBox(aParamBox,"Teste Parâmetros...",@aRetParam)
        if aRetParam[1] == aTipos[1] //1=Analise das Carretas
            cCpoRet := "ZAL_TIPO|ZAL_DATA|ZAL_TURNO|ZAL_ZPBCOD|ZAL_PLACA|ZAL_KGM3|ZAL_TFERM|ZAL_TALCOL|ZAL_FOLU|ZAL_MATSEX|ZAL_PESOF"
        elseif aRetParam[1] == aTipos[2] //2=Analise Levedo Tanque Circulacao
            cCpoRet := "ZAL_TIPO|ZAL_DATA|ZAL_TURNO|ZAL_TFERM|ZAL_TALCOL|ZAL_MATSEX|ZAL_PESOF"
        elseif aRetParam[1] == aTipos[3] //3=Analise Levedo Concentrador
            cCpoRet := "ZAL_TIPO|ZAL_DATA|ZAL_TURNO|ZAL_KGM3|ZAL_TFERM|ZAL_TALCOL|ZAL_DENAPA|ZAL_MATSEX|ZAL_PESOF"
        else // 4=Analise do Tanque Estabilizado
            cCpoRet := "ZAL_TIPO|ZAL_DATA|ZAL_TURNO|ZAL_KGM3|ZAL_TFERM|ZAL_TALCOL|ZAL_MATSEX|ZAL_PESOF"
        EndIf
    Endif
Return  */

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
