#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Preco de Venda do Gado"
/*/{Protheus.doc} VAFATI07
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
User Function VAFATI07()
    Local aArea		 := FWGetArea()
	Local oBrowse
    Private cTimeINI :=  Time()
	Private cArquivo := "C:\TOTVS_RELATORIOS\"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZVC")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 	:= nil
    Local oMaster   := FWFormStruct(1, 'ZVC', {|cCampo| AllTrim(cCampo) $ "ZVC_COD|ZVC_DATADE|ZVC_DTATE" })
    Local oGrid  	:= FWFormStruct(1, 'ZVC', {|cCampo| !(AllTrim(cCampo) $ "ZVC_COD|ZVC_DATADE|ZVC_DTATE") })
    Local aZVCRel   := {}
    
    oMaster:SetProperty('ZVC_DTATE', MODEL_FIELD_VALID, {|| FI07DT()})

	oModel := MPFormModel():New("FATI07M", /*Pre-Validacao*/,/*Pos-Validacao*/,,/*Cancel*/)

	oModel:AddFields("ZVCMASTER",/*cOwner*/  ,oMaster		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddGrid('ZVCDETAIL', 'ZVCMASTER'	, oGrid, /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,/* {|| LoadGrid()}  */ )

    aAdd(aZVCRel, {'ZVC_FILIAL', 'Iif(!INCLUI, ZVC->ZVC_FILIAL, FWxFilial("ZVC"))'} )
	aAdd(aZVCRel, {'ZVC_COD'   , 'Iif(!INCLUI, ZVC->ZVC_COD   , ZVC->ZVC_COD)'} )

	oModel:SetRelation('ZVCDETAIL', aZVCRel, ZVC->(IndexKey(1)))

    oModel:SetPrimaryKey({"ZVC_FILIAL"+"ZVC_COD","ZVC_ITEM"})
    
	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZVCMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	
Return oModel

Static Function ViewDef()
	Local oModel    := FWLoadModel("VAFATI07")
    Local oMaster   := FWFormStruct(2, 'ZVC', {|cCampo| AllTrim(cCampo) $ "ZVC_COD|ZVC_DATADE|ZVC_DTATE" })
    Local oGrid  	:= FWFormStruct(2, 'ZVC', {|cCampo| !(AllTrim(cCampo) $ "ZVC_COD|ZVC_DATADE|ZVC_DTATE") })
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZVC", oMaster, "ZVCMASTER")
	oView:AddGrid('VIEW_IZVC', oGrid , 'ZVCDETAIL')
    
	oView:CreateHorizontalBox('CABEC', 30 )
	oView:CreateHorizontalBox('GRIDM', 70 )
	
	oView:SetOwnerView("VIEW_ZVC"	 , "CABEC")
	oView:SetOwnerView("VIEW_IZVC"	 , "GRIDM")
	
	oView:EnableTitleView('VIEW_ZVC'  , cTitulo)
    
    oView:AddIncrementField( 'VIEW_IZVC', 'ZVC_ITEM' )
	
	oView:SetCloseOnOk( { |oView| .T. } )
Return oView

    Static Function MenuDef()
	Local aRotina := {} 

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAFATI07' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VAFATI07' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VAFATI07' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VAFATI07' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 
Return aRotina
//Load Grid
Static Function FI07DT()
    Local aArea		:= GetArea()
    Local lRet      := .T. 
	Local cQry 		:= ''
    Local oModel    := FWModelActive()
    Local oCab      := oModel:GetModel("ZVCMASTER")
    Local oGrid      := oModel:GetModel("ZVCDETAIL")
    
    if oCab:GetValue("ZVC_DTATE") < oCab:GetValue("ZVC_DATADE")
        oModel:SetErrorMessage("","","","","Data Inválida", 'Data final não pode ser menor do que a inicial', "") 
        lRet := .F.
    else 
        If oGrid:IsEmpty()
            cQry := " SELECT DISTINCT B1_DESC, B1_XIDADE,Z09_IDAFIM " +CRLF 
            cQry += " FROM "+RetSqlName("SB1")+" SB1 " +CRLF 
            cQry += " JOIN "+RetSqlName("Z09")+" Z09 ON  " +CRLF 
            cQry += " CAST(B1_XIDADE AS INT) BETWEEN Z09_IDAINI AND Z09_IDAFIM " +CRLF 
            cQry += " AND B1_X_SEXO = Z09_SEXO " +CRLF 
            cQry += " AND B1_XRACA = Z09_RACA " +CRLF 
            cQry += " AND Z09.D_E_L_E_T_ = ' '  " +CRLF 
            cQry += " WHERE B1_GRUPO IN ('B0V','01','05') AND SB1.D_E_L_E_T_ = ' ' AND B1_MSBLQL <> ' '  " +CRLF 
            cQry += " AND B1_XIDADE NOT LIKE '%/%' " +CRLF 

            MpSysOpenQuery(cQry,"TMP")
            
            While !TMP->(EOF())
                oGrid:AddLine()
                oGrid:SetValue("ZVC_DESC",ALLTRIM(TMP->B1_DESC))
                TMP->(DBSKIP())
            End
            oGrid:GoLine(1)
            TMP->(DbCloseArea())
        endif 
    endif 

    RestArea(aArea)
Return lRet
User Function FATI07M()
	Local aParam 		:= PARAMIXB
	Local xRet 			:= .T.
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local cIdIXB5		:= ''
	Local cIdIXB4		:= ''
	Local oModel 	 	:= nil
	Local oGrid 		:= nil

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

		If Alltrim(cIdPonto) == "MODELVLDACTIVE"
            
		else
			if Alltrim(cIdPonto) == "FORMPRE" .and. cIdModel == 'ZVCDETAIL' .AND. cIdIXB5 == 'ADDLINE'
                oModel := FWModelActive()
                oGrid  := oModel:GetModel("ZVCDETAIL")
                xRet := .T.
 			elseif  Alltrim(cIdPonto) == "FORMPRE" .and. cIdModel == 'ZVCDETAIL' .AND. cIdIXB5 == 'UNDELETE'/* !(aParam[5] $ "ISENABLE-ADDLINE") */
                oModel := FWModelActive()
                oModel:SetErrorMessage("","","","","Atenção!", 'Operação não permitida!', "") 
                xRet := .F.
			elseIf Alltrim(cIdPonto) == 'FORMPRE' .AND. cIdModel == 'FORMRodap1' .and. cIdIXB4 == 'CANSETVALUE'
                xRet := .T.
			elseif Alltrim(cIdPonto) == 'FORMPOS'
                xRet := .T.
			ENDIF
		ENDIF
	ENDIF
Return xRet
