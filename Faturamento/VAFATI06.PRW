#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Valores do Frete"
//Tela para cadastro de Valores do Frete
/* 
Igor Oliveira 

08/08/2023

Usado para cadastrar Valores do frete que será usado na Rotina U_VAFATI04() - Fechamento de Fretes

*/
User Function VAFATI06()
	Local aArea		:= FWGetArea()
	Local oBrowse
	Private aCTE 	:= {}

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZFV")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 		:= nil
	Local oCab   		:= FWFormStruct(1, 'ZFV', {|cCampo| AllTrim(cCampo) $ "ZFV_FILIAL|ZFV_CODIGO|ZFV_DE|ZFV_ATE" })
	Local oGrid   		:= FWFormStruct(1, 'ZFV', {|cCampo| !(AllTrim(cCampo) $ "ZFV_FILIAL|ZFV_CODIGO|ZFV_DE|ZFV_ATE" )})
    Local bSaveZFV      := {|| I06COMMIT()}

	oModel := MPFormModel():New("FATI06M",,bSaveZFV)

	oModel:AddFields("ZFVMASTER",/*cOwner*/  ,oCab		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddGrid('ZFVDETAIL', 'ZFVMASTER'	, oGrid, /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,{|| I06LOAD()})

	oModel:SetPrimaryKey({"ZFV_FILIAL"+"ZFV_CODIGO"+"ZFV_ITEM"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZFVMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	oModel:GetModel("ZFVDETAIL"):SetDescription("Itens do Cadastro ")
	
Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAFATI06")
	Local oCab   		:= FWFormStruct(2, 'ZFV', {|cCampo| AllTrim(cCampo) $ "ZFV_FILIAL|ZFV_CODIGO|ZFV_DE|ZFV_ATE" })
	Local oGrid   		:= FWFormStruct(2, 'ZFV', {|cCampo| !(AllTrim(cCampo) $ "ZFV_FILIAL|ZFV_CODIGO|ZFV_DE|ZFV_ATE" )})
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZFV", oCab  , "ZFVMASTER")
	oView:AddGrid("VIEW_GRID", oGrid , "ZFVDETAIL")
    
	oView:CreateHorizontalBox('CABEC', 20 )
	oView:CreateHorizontalBox('RODAP', 80 )
	
	oView:SetOwnerView("VIEW_ZFV"	 , "CABEC")
	oView:SetOwnerView("VIEW_GRID"	 , "RODAP")
	
	oView:EnableTitleView('VIEW_ZFV'  , cTitulo)
	
    oView:AddUserButton( 'Definir Intervalo (F10)','', {|oView| DefInt()} )
	SetKey( VK_F10, {|| DefInt()} )
    
    oView:AddIncrementField( 'VIEW_GRID', 'ZFV_ITEM')

	oView:SetCloseOnOk( { |oView| .T. } )
Return oView

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAFATI06' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VAFATI06' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VAFATI06' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VAFATI06' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 
Return aRotina
//Definir Intervalo
Static Function DefInt()
    Local oView     := FWViewActive()
    Local oModel    := FWModelActive()
    Local oGrid     := oModel:GetModel('ZFVDETAIL')
    Local nI,nJ
    Local nLastIt   := ""
    //Pegar opcões do Combo na X3, para n ficar adicionando na mão
    Local aCombo    := Separa(AllTrim(GetSX3Cache("ZFV_TIPVEI", "X3_CBOX")),";",.f.)
    Local aRet      := {}

    If MsgYesNo("Deseja definir o intervalo de KM na grid para todos os Tipos?")
        //Inicia na 2º Posição pq a 1º opção do combo já está na grid
            For nI := 1 to oGrid:GetQtdLine()
                oGrid:Goline(nI)
                if !oGrid:IsDeleted()
                    aAdd(aRet,{ oGrid:GetValue("ZFV_KMDE"),;
                                oGrid:GetValue("ZFV_KMATE"),;
                                oGrid:GetValue("ZFV_TIPPAG")})
                Endif 
                if nI == oGrid:GetQtdLine()
                    nLastIt := Val(oGrid:GetValue("ZFV_ITEM"))
                Endif
            Next nI 

        For nJ := 2 to Len(aCombo)
            For nI := 1 to Len(aRet)
                oGrid:AddLine()

                oGrid:SetValue("ZFV_TIPVEI" ,SubStr(aCombo[nJ],1,1))
                oGrid:SetValue("ZFV_KMDE"   ,aRet[nI][1])
                oGrid:SetValue("ZFV_KMATE"  ,aRet[nI][2])
                oGrid:SetValue("ZFV_TIPPAG" ,aRet[nI][3])
            Next nI 
        Next nJ
    EndIf 
    oView:Refresh()
Return
//Load Grid
Static Function I06LOAD()
	Local aArea		:= GetArea()
	Local aRet 		:= {}
	Local cQry 		:= ''

    cQry := " SELECT * " + CRLF 
    cQry += " FROM "+RetSqlName("ZFV")+"" + CRLF 
    cQry += " WHERE ZFV_FILIAL = '"+ZFV->ZFV_FILIAL+"'" + CRLF 
    cQry += " AND ZFV_CODIGO = '"+ZFV->ZFV_CODIGO+"'" + CRLF 
    cQry += " AND D_E_L_E_T_ = '' " + CRLF
    cQry += " ORDER BY ZFV_ITEM " + CRLF

    MpSysOpenQuery(cQry,"TMP")
	While !TMP->(EOF())
        aAdd(aRet,{Val(TMP->ZFV_ITEM),{     TMP->ZFV_ITEM,;
                                            TMP->ZFV_KMDE,;
                                            TMP->ZFV_KMATE,;
                                            TMP->ZFV_VLKM,;
                                            TMP->ZFV_TIPPAG,;
                                            TMP->ZFV_TIPVEI}})
        TMP->(DBSKIP())
    End
    
    if Len(aRet) == 0
        aAdd(aRet,{ 1,{ "",;
                        0,;
                        0,;
                        0,;
                        "2",;
                        "01"}})
    EndIf

    TMP->(DbCloseArea())
    RestArea(aArea)
Return aRet 
//Commit
Static Function I06COMMIT()
    Local oModel    := FWModelActive()
    Local oCab      := oModel:GetModel('ZFVMASTER')
    Local oGrid     := oModel:GetModel('ZFVDETAIL')
    Local nOpc      := oModel:GetOperation()
    Local lRet      := .T.
    Local nI 

    //if nOpc == 3 .or. nOpc == 4 // ALTERAÇÃO E EXCLUSÃO
    //    if !(Empty(oCab:GetValue("ZFV_DE"))) .or. !(Empty(oCab:GetValue("ZFV_ATE")))
    //        DBSELECTAREA( "ZFV" )
    //        DBSETORDER( 2 )
    //        //ZFV_FILIAL+ZFV_CODIGO+ZFV_ITEM
    //        For nI := 1 to oGrid:GetQtdLine()
    //            oGrid:GoLine(nI)
//
    //            IF oGrid:IsDeleted()
    //                if ZFV->(DBSeek(FWxFilial("ZFV") + oCab:GetValue("ZFV_CODIGO") + oGrid:GetValue("ZFV_ITEM")))
    //                    ZFV->(RECLOCK('ZFV',.F.))
    //                        ZFV->(DbDelete())
    //                    ZFV->(MSUNLOCK())
    //                endif
    //            else
    //                RecLock("ZFV", lRecLock := !DBSeek(FWxFilial("ZFV") + oCab:GetValue("ZFV_CODIGO") + oGrid:GetValue("ZFV_ITEM") ))
    //                    ZFV->ZFV_FILIAL := FwXFilial("ZFV")
    //                    ZFV->ZFV_CODIGO := oCab:GetValue("ZFV_CODIGO")
    //                    ZFV->ZFV_ITEM   := oGrid:GetValue("ZFV_ITEM")
    //                    ZFV->ZFV_DE 	:= oCab:GetValue("ZFV_DE")
    //                    ZFV->ZFV_ATE    := oCab:GetValue("ZFV_ATE")
    //                    ZFV->ZFV_KMDE   := oGrid:GetValue("ZFV_KMDE")
    //                    ZFV->ZFV_KMATE  := oGrid:GetValue("ZFV_KMATE")
    //                    ZFV->ZFV_VLKM   := oGrid:GetValue("ZFV_VLKM")
    //                    ZFV->ZFV_TIPVEI := oGrid:GetValue("ZFV_TIPVEI")
    //                    ZFV->ZFV_TIPPAG := oGrid:GetValue("ZFV_TIPPAG")
    //                ZFV->( MsUnlock() )
    //            endif
    //        Next nI
    //        
    //        ZFV->(DBCLOSEAREA(  ))
    //    else
    //        MSGALERT( "Preencha os Campos de Data", "Atenção" )
    //    ENDIF
    //elseif nOpc == 5 //DELETE
/*     if !(oCab:IsUpdate())
        lRet := .F. */
    if nOpc == 5 //DELETE
        DBSELECTAREA( "ZFV" )
        DBSETORDER( 2 )
        For nI := 1 to oGrid:GetQtdLine()
            oGrid:GoLine(nI)
            if ZFV->(DBSeek(FWxFilial("ZFV") + oCab:GetValue("ZFV_CODIGO") + oGrid:GetValue("ZFV_ITEM")))
                ZFV->(RECLOCK('ZFV',.F.))
                    ZFV->(DbDelete())
                ZFV->(MSUNLOCK())
            endif
        Next nI
        ZFV->(DBCLOSEAREA())
    endif
        
Return lRet
//Validação dos Campos ZFV_KMDE e ZFV_KMATE
User Function I06KM()
    Local lRet      := .T.
    Local oModel    := FWModelActive()
    Local oGrid     := oModel:GetModel('ZFVDETAIL')
    Local nVarKM    := &(ReadVar())
    Local cVarTp    := oGrid:GetValue("ZFV_TIPVEI")
    Local cCampo    := SubS( ReadVar(), At(">", ReadVar())+1 )
    Local aSaveLines := FWSaveRows()
    
    if cCampo == 'ZFV_KMDE'
        if iif( oGrid:GetValue("ZFV_KMATE") == 0, .F.,oGrid:GetValue("ZFV_KMDE") >= oGrid:GetValue("ZFV_KMATE"))
            lRet := .F.
            oModel:SetErrorMessage("","","","","HELP", 'Valor Invalido!', "Valor deve ser menor que KM Final!!" )

        Elseif oGrid:GetLine() > 1
            oGrid:GoLine(oGrid:GetLine()-1)
            if cVarTp == oGrid:GetValue("ZFV_TIPVEI")

                if nVarKM <= oGrid:GetValue("ZFV_KMATE")
                    lRet := .F. 
                    oModel:SetErrorMessage("","","","","HELP", 'Valor Invalido!', "Valor deve ser maior que a linha anterior!!" )
                Endif
            Endif
        endif 
    Else
        if oGrid:GetValue("ZFV_KMDE") >= oGrid:GetValue("ZFV_KMATE")
            lRet := .F.
            oModel:SetErrorMessage("","","","","HELP", 'Valor Invalido!', "Valor deve ser maior que KM Inicial!!" )

        Elseif oGrid:GetLine() > 1
                oGrid:GoLine(oGrid:GetLine()-1)
                if cVarTp == oGrid:GetValue("ZFV_TIPVEI")
                    if nVarKM <= oGrid:GetValue("ZFV_KMDE")
                        lRet := .F.
                        oModel:SetErrorMessage("","","","","HELP", 'Valor Invalido!', "Valor deve ser maior que a linha anterior!!" )
                    Endif 
                Endif
        endif 
    EndIf

    FWRestRows(aSaveLines)
Return lRet

User Function I06VEI()
    Local cRet      := .T.
    Local oModel    := FWModelActive()
    Local oGrid     := oModel:GetModel('ZFVDETAIL')
    Local aSaveLines := FWSaveRows()
    
    if oGrid:GetQtdLine() == 0
        cRet := '1'
    Else
        cRet := oGrid:GetValue("ZFV_TIPVEI") 
    Endif

    FWRestRows(aSaveLines)
Return cRet
