#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTitulo := 'Consulta de Pedidos Alterados'

User Function COM15FW()
    Local aArea     := FwGetArea()
    Local cFunBkp   := FunName()
    
    Private oFontPadrao := TFont():New("TAHOMA", , -16, ,.T.)
    Private aDados  := {}

    DbSelectArea("SCY")
    SCY->(DbSetOrder(1))
    
    if !SCY->(dbSeek(FWXFilial("SCY")+Alltrim(SCR->CR_NUM)))
        MsgAlert("Pedido sem histórico de alterações")
        SCY->(DbCloseArea())
        
        Return
    endif

	SetFunName("VACOMM15")
        FWExecView('Visualização Pedido: '+ALLTRIM(SCR->CR_NUM), 'VACOMM15', MODEL_OPERATION_VIEW,,{||.T.})
	SetFunName(cFunBkp)

    SCY->(DbCloseArea())
    
    FwRestArea(aArea)
Return
User Function VACOMM15()
	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp := FunName()
	
	SetFunName("VACOMM15")
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SCY")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()
	
	SetFunName(cFunBkp)
	RestArea(aArea)
Return Nil

Static Function MenuDef()
	Local aRot := {}
	
	ADD OPTION aRot TITLE 'Visualizar' 		ACTION 'VIEWDEF.VACOMM15' 			OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1

Return aRot

Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStr1   	:= FWFormStruct(1, 'TMPCAB') 
	Local oStr2   	:= FWFormStruct(1, 'SC7')
	Local oStr3   	:= FWFormStruct(1, 'SCY')
	Local oStr4   	:= FWFormStruct(1, 'TMPGRID') 
	Local bLoadC    := { | oModel | zLoadC(oModel) }
	Local bLoadG    := { | oModel | zLoadG(oModel) }
	Local bLdSC7    := { | oModel | zLdSC7(oModel) }
	Local bLdSCY    := { | oModel | zLdSCY(oModel) }

	oStr1 	:= GetMdCabec(oModel, oStr1)
	oStr4 	:= GetMdGrid(oModel, oStr4)

	//Criando o FormModel, adicionando o CabeÃ§alho e Grid
	oModel := MPFormModel():New("M15VACOM",/* bVldPre */, /* bVldPos */ /*Pos-Validacao*/, /* bVldCom */ /*Commit*/,/*Cancel*/)

	oModel:AddFields("TMPCAB",/*cOwner*/,oStr1,/* <bPre > */, /* <bPost > */, bLoadC )
	oModel:AddGrid("TMPGRID" ,"TMPCAB"  ,oStr4,/* [ bLinePre ] */, /* [ bLinePost ] */, /* [ bPre ] */, /* [ bPost ] */, bLoadG)//, , , ,bLoadG )
	oModel:AddGrid("SC7"     ,"TMPGRID" ,oStr2,/* [ bLinePre ] */, /* [ bLinePost ] */, /* [ bPre ] */, /* [ bPost ] */, bLdSC7)
	oModel:AddGrid("SCY"     ,"TMPGRID" ,oStr3,/* [ bLinePre ] */, /* [ bLinePost ] */, /* [ bPre ] */, /* [ bPost ] */, bLdSCY)

	oModel:SetPrimaryKey({ })

	oModel:SetDescription(cTitulo)
	oModel:GetModel("TMPCAB"):SetDescription("Cabeçalho")
	oModel:GetModel("TMPGRID"):SetDescription("Alterações")
	oModel:GetModel("SCY"):SetDescription("Histórico")
	oModel:GetModel("SC7"):SetDescription("Pedido")
    
    oModel:SetOnlyQuery("TMPCAB",.t.)
    oModel:SetOnlyQuery("TMPGRID",.t.)
    oModel:SetOnlyQuery("SC7",.t.)
    oModel:SetOnlyQuery("SCY",.t.)

	oModel:SetOptional("TMPGRID", .T.)
	oModel:SetOptional("SC7", .T.)
	oModel:SetOptional("SCY", .T.)

Return oModel

Static Function ViewDef()
	Local oModel    := FWLoadModel("VACOMM15")
    Local oStr1   	:= FWFormStruct(2, 'TMPCAB') 
	Local oStr2   	:= FWFormStruct(2, 'SC7')
	Local oStr3   	:= FWFormStruct(2, 'SCY')
	Local oStr4   	:= FWFormStruct(2, 'TMPGRID') 
	Local oView     := NIL

	oStr1 	:= GetVwCab(oModel, oStr1)
	oStr4 	:= GetVWGrid(oModel, oStr4)

	oView     := FWFormView():New()
	oView:SetModel(oModel)

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CAB_1', 20)
	oView:CreateHorizontalBox('CAB_2', 25)
	oView:CreateHorizontalBox('CAB_3', 25)
	//oView:CreateHorizontalBox('CAB_4', 5)
	oView:CreateHorizontalBox('CAB_5', 30)

	//oView:AddOtherObject("LABELUPD",{|o1Panel,o1OtherObject| CriaLabel(o1Panel,o1OtherObject)})

    oView:AddField( 'VIEW_1' , oStr1 , 'TMPCAB')
	oView:AddGrid(  'VIEW_2' , oStr2 , 'SC7')
	oView:AddGrid(  'VIEW_3' , oStr3 , 'SCY')
	oView:AddGrid(  'VIEW_4' , oStr4 , 'TMPGRID')

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_1'  	,'CAB_1'	)
	oView:SetOwnerView('VIEW_2'  	,'CAB_2'	)
	oView:SetOwnerView('VIEW_3'  	,'CAB_3'	)
	//oView:SetOwnerView('LABELUPD'  	,'CAB_4'	)
	oView:SetOwnerView('VIEW_4'  	,'CAB_5'	)

    oView:EnableTitleView('VIEW_1'	, 'Cabeçalho' 		 ) 
    oView:EnableTitleView('VIEW_2'	, 'Pedido'	         ) 
    //oView:EnableTitleView('LABELUPD', 'Campos Alterados' ) 
    oView:EnableTitleView('VIEW_3'	, 'Histórico' 		 ) 
    oView:EnableTitleView('VIEW_4'	, 'Alterações'		 ) 

	//oView:SetContinuousForm(.T.)

	oView:SetCloseOnOk( { |oView| .T. } )

Return oView

User Function M15VACOM()
	Local aParam 		:= PARAMIXB
	Local lRet 			:= .T.
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local cIdIXB5		:= ''
	Local cIdIXB4		:= ''
	Local oModel 	 	:= nil
	
	If aParam <> NIL
		oModel 	 := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		if len(aParam) >= 4
			cIdIXB4  := aParam[4]
		endif 

		if len(aParam) >= 5
			cIdIXB5  := aParam[5]
		endif 
		
		if Alltrim(cIdPonto) == 'BUTTONBAR'

		endif			
	endif
Return lRet

Static Function GetMdCabec(oModel, oStr)
	oStr:AddField('Filial'	 		, 'Filial'		, 'CBC_FILIAL'	, 'C', TAMSX3("C7_FILIAL")[1]   ,TAMSX3("C7_FILIAL")[2]  ,,,{},.F.,,.F.,.F.,.T.)
	oStr:AddField('Pedido'	 		, 'Pedido'		, 'CBC_NUM'	    , 'C', TAMSX3("C7_NUM")[1]      ,TAMSX3("C7_NUM")[2]     ,,,{},.F.,,.F.,.F.,.T.)
	oStr:AddField('Fornecedor'		, 'Fornecedor'	, 'CBC_FORNEC'	, 'C', TAMSX3("C7_FORNECE")[1]  ,TAMSX3("C7_FORNECE")[2] ,,,{},.F.,,.F.,.F.,.T.)
	oStr:AddField('Loja'			, 'Loja'		, 'CBC_LOJA'	, 'C', TAMSX3("C7_LOJA")[1]     ,TAMSX3("C7_LOJA")[2]    ,,,{},.F.,,.F.,.F.,.T.)
	oStr:AddField('Razão Social'	, 'Razão Social', 'CBC_RAZAO'	, 'C', TAMSX3("A2_NOME")[1]     ,TAMSX3("A2_NOME")[2]    ,,,{},.F.,,.F.,.F.,.T.)
Return oStr

Static Function GetVwCab(oModel,oStr)
	oStr:AddField('CBC_FILIAL'	,  '1', 'Filial'		, 'Filial'	    ,{}, 'C',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('CBC_NUM'	    ,  '1', 'Pedido'		, 'Pedido'	    ,{}, 'C',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('CBC_FORNEC'	,  '2', 'Fornecedor'	, 'Fornecedor'	,{}, 'C',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('CBC_LOJA' 	,  '3', 'Loja'			, 'Loja'		,{}, 'C',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('CBC_RAZAO'	,  '4', 'Razão Social'	, 'Razão Social',{}, 'C',,,,.F.,,,{},,,.T.,,,)
Return oStr

Static Function GetMdGrid(oModel, oStr)
    oStr:AddField('Item'		, 'Item'		, 'GD_ITEM'	, 'C', TAMSX3("C7_ITEM")[1]     ,TAMSX3("C7_ITEM")[2]    ,,,{},.F.,,.F.,.F.,.T.)
    oStr:AddField('Produto'		, 'Produto'		, 'GD_PROD'	, 'C', TAMSX3("C7_PRODUTO")[1]  ,TAMSX3("C7_PRODUTO")[2] ,,,{},.F.,,.F.,.F.,.T.)
    oStr:AddField('Descrição'   , 'Descrição'   , 'GD_DESC'	, 'C', TAMSX3("B1_DESC")[1]     ,TAMSX3("B1_DESC")[2]    ,,,{},.F.,,.F.,.F.,.T.)
    oStr:AddField('Unid. Ant.'	, 'Unid. Ant.'	, 'GD_UNDAT', 'C', TAMSX3("B1_UM")[1]       ,TAMSX3("B1_UM")[2]      ,,,{},.F.,,.F.,.F.,.T.)
    oStr:AddField('Unid. Atual'	, 'Unid. Atual'	, 'GD_UNDAU', 'C', TAMSX3("B1_UM")[1]       ,TAMSX3("B1_UM")[2]      ,,,{},.F.,,.F.,.F.,.T.)
    oStr:AddField('Quant. Ant.'	, 'Quant. Ant.'	, 'GD_QTANT', 'N', TAMSX3("C7_QUANT")[1]    ,TAMSX3("C7_QUANT")[2]   ,,,{},.F.,,.F.,.F.,.T.)
    oStr:AddField('Quant. Atual', 'Quant. Atual', 'GD_QTATU', 'N', TAMSX3("C7_QUANT")[1]    ,TAMSX3("C7_QUANT")[2]   ,,,{},.F.,,.F.,.F.,.T.)
    oStr:AddField('Preço Ant.'  , 'Preço Ant.'  , 'GD_PRANT', 'N', TAMSX3("C7_PRECO")[1]    ,TAMSX3("C7_PRECO")[2]   ,,,{},.F.,,.F.,.F.,.T.)
    oStr:AddField('Preço Atual' , 'Preço Atual' , 'GD_PRATU', 'N', TAMSX3("C7_PRECO")[1]    ,TAMSX3("C7_PRECO")[2]   ,,,{},.F.,,.F.,.F.,.T.)
    oStr:AddField('Total Ant.'  , 'Total Ant.'  , 'GD_TOANT', 'N', TAMSX3("C7_TOTAL")[1]    ,4                       ,,,{},.F.,,.F.,.F.,.T.)
    oStr:AddField('Total Atual' , 'Total Atual' , 'GD_TOATU', 'N', TAMSX3("C7_TOTAL")[1]    ,4                       ,,,{},.F.,,.F.,.F.,.T.)
Return oStr

Static Function GetVWGrid(oModel,oStr)
	oStr:AddField('GD_ITEM'	,'1' , 'Item'		 , 'Item'		 ,{}, 'C',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('GD_PROD'	,'10', 'Produto'	 , 'Produto'	 ,{}, 'C',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('GD_DESC'	,'11', 'Descrição'   , 'Descrição'   ,{}, 'C',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('GD_UNDAT','2' , 'Unid. Ant.'	 , 'Unid. Ant.'	 ,{}, 'C',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('GD_UNDAU','3' , 'Unid. Atual' , 'Unid. Atual' ,{}, 'C',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('GD_QTANT','4' , 'Quant. Ant.' , 'Quant. Ant.' ,{}, 'N',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('GD_QTATU','5' , 'Quant. Atual', 'Quant. Atual',{}, 'N',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('GD_PRANT','6' , 'Preço Ant.'  , 'Preço Ant.'  ,{}, 'N',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('GD_PRATU','7' , 'Preço Atual' , 'Preço Atual' ,{}, 'N',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('GD_TOANT','8' , 'Total Ant.'  , 'Total Ant.'  ,{}, 'N',,,,.F.,,,{},,,.T.,,,)
	oStr:AddField('GD_TOATU','9' , 'Total Atual' , 'Total Atual' ,{}, 'N',,,,.F.,,,{},,,.T.,,,)
Return oStr

Static Function zLoadC(oModel)
    Local aRet := {}

    aAdd(aRet, {SCY->CY_FILIAL  ,;
                SCY->CY_NUM     ,;
                SCY->CY_FORNECE ,;
                SCY->CY_LOJA    ,;
                Posicione("SA2",1,FWXFilial("SA2")+SCY->CY_FORNECE+SCY->CY_LOJA,"A2_NOME")} )
    aAdd(aRet,1)
Return aRet

Static Function zLoadG(oModel)
    Local aArea := FwGetArea()
    Local aRet  := {}
    Local cQry  := ""
    Local cAlias := ""
    
    cQry := "WITH Historico AS ( " + CRLF
    cQry += "     SELECT 'HISTÓRICO' ORIGEM, CY_FILIAL, CY_NUM, CY_ITEM,  " + CRLF
    cQry += "            CY_FORNECE, CY_LOJA, CY_PRODUTO, CY_UM,  " + CRLF
    cQry += "            CY_QUANT, CY_TOTAL, CY_PRECO, CY_VERSAO, D_E_L_E_T_ " + CRLF
    cQry += "     FROM "+RetSqlName("SCY")+" " + CRLF
    cQry += "     WHERE CY_NUM = '"+SCR->CR_NUM+"' AND D_E_L_E_T_ = '' " + CRLF
    cQry += "     AND CY_FILIAL = '"+SCR->CR_FILIAL+"' " + CRLF
    cQry += "     AND CY_VERSAO = (SELECT MAX(CY_VERSAO) FROM "+RetSqlName("SCY")+" WHERE CY_NUM = '"+SCY->CY_NUM+"' AND D_E_L_E_T_ = '') " + CRLF
    cQry += " ), " + CRLF
    cQry += " Atual AS ( " + CRLF
    cQry += "     SELECT 'ATUAL' ORIGEM, C7_FILIAL, C7_NUM, C7_ITEM,  " + CRLF
    cQry += "            C7_FORNECE, C7_LOJA, C7_PRODUTO, C7_UM,  " + CRLF
    cQry += "            C7_QUANT, C7_TOTAL, C7_PRECO, D_E_L_E_T_ " + CRLF
    cQry += "     FROM "+RetSqlName("SC7")+"  " + CRLF
    cQry += "     WHERE C7_NUM = '"+SCR->CR_NUM+"' AND D_E_L_E_T_ = '' " + CRLF
    cQry += "     AND C7_FILIAL = '"+SCR->CR_FILIAL+"' " + CRLF
    cQry += " ) " + CRLF
    cQry += " , FINAL AS ( " + CRLF
    cQry += " SELECT  " + CRLF
    cQry += "     COALESCE(A.ORIGEM, H.ORIGEM, '') AS ORIGEM, " + CRLF
    cQry += "     COALESCE(A.C7_FILIAL, H.CY_FILIAL, '') AS FILIAL, " + CRLF
    cQry += "     COALESCE(A.C7_NUM, H.CY_NUM, '') AS NUMERO, " + CRLF
    cQry += "     COALESCE(A.C7_ITEM, H.CY_ITEM, '') AS ITEM, " + CRLF
    cQry += "      " + CRLF
    cQry += "     -- Produto " + CRLF
    cQry += "     COALESCE(H.CY_PRODUTO, '') AS PRODUTO_HISTORICO, " + CRLF
    cQry += "     COALESCE(A.C7_PRODUTO, '') AS PROD_ATUAL, " + CRLF
    cQry += "      " + CRLF
    cQry += "     -- Unidade de Medida " + CRLF
    cQry += "     COALESCE(H.CY_UM, '') AS UND_HISTORICO, " + CRLF
    cQry += "     COALESCE(A.C7_UM, '') AS UND_ATUAL, " + CRLF
    cQry += "      " + CRLF
    cQry += "     -- Quantidade (substitui NULL por 0) " + CRLF
    cQry += "     COALESCE(H.CY_QUANT, 0) AS QTD_HISTORICO, " + CRLF
    cQry += "     COALESCE(A.C7_QUANT, 0) AS QTD_ATUAL, " + CRLF
    cQry += "      " + CRLF
    cQry += "     -- Unitario (substitui NULL por 0) " + CRLF
    cQry += "     COALESCE(H.CY_PRECO, 0) AS UNIT_HISTORICO, " + CRLF
    cQry += "     COALESCE(A.C7_PRECO, 0) AS UNIT_ATUAL, " + CRLF
    cQry += "  " + CRLF
    cQry += "     -- Total (substitui NULL por 0) " + CRLF
    cQry += "     COALESCE(H.CY_TOTAL, 0) AS TOT_HISTORICO, " + CRLF
    cQry += "     COALESCE(A.C7_TOTAL, 0) AS TOT_ATUAL, " + CRLF
    cQry += "      " + CRLF
    cQry += "     -- Versão do Histórico " + CRLF
    cQry += "     COALESCE(H.CY_VERSAO, '') AS VERSAO_HISTORICO, " + CRLF
    cQry += "      " + CRLF
    cQry += "     -- Se o item for novo, exibe 'SIM' " + CRLF
    cQry += "     CASE  " + CRLF
    cQry += "         WHEN H.CY_ITEM IS NULL AND A.C7_ITEM IS NOT NULL THEN 'SIM'  " + CRLF
    cQry += "         ELSE 'NAO' " + CRLF
    cQry += "     END AS NOVO_ITEM, " + CRLF
    cQry += "  " + CRLF
    cQry += "     -- Flag para indicar alteração " + CRLF
    cQry += "     CASE  " + CRLF
    cQry += "         WHEN (H.CY_PRODUTO <> A.C7_PRODUTO OR H.CY_UM <> A.C7_UM OR H.CY_QUANT <> A.C7_QUANT  " + CRLF
    cQry += "             OR H.CY_TOTAL <> A.C7_TOTAL OR H.CY_PRECO <> A.C7_PRECO  " + CRLF
    cQry += "             OR H.CY_FORNECE <> A.C7_FORNECE OR H.CY_LOJA <> A.C7_LOJA)  " + CRLF
    cQry += "         THEN 'SIM' " + CRLF
    cQry += "         ELSE 'NAO' " + CRLF
    cQry += "     END AS ALTERADO, " + CRLF
    cQry += "  " + CRLF
    cQry += "     -- Lista os campos alterados separados por '|'' " + CRLF
    cQry += "     isnull(STUFF( " + CRLF
    cQry += "         (CASE WHEN H.CY_PRODUTO <> A.C7_PRODUTO THEN '|C7_PRODUTO' ELSE '' END) + " + CRLF
    cQry += "         (CASE WHEN H.CY_UM <> A.C7_UM THEN '|C7_UM' ELSE '' END) + " + CRLF
    cQry += "         (CASE WHEN H.CY_QUANT <> A.C7_QUANT THEN '|C7_QUANT' ELSE '' END) + " + CRLF
    cQry += "         (CASE WHEN H.CY_TOTAL <> A.C7_TOTAL THEN '|C7_TOTAL' ELSE '' END) + " + CRLF
    cQry += "         (CASE WHEN H.CY_PRECO <> A.C7_PRECO THEN '|C7_PRECO' ELSE '' END) + " + CRLF
    cQry += "         (CASE WHEN H.CY_FORNECE <> A.C7_FORNECE THEN '|C7_FORNECE' ELSE '' END) + " + CRLF
    cQry += "         (CASE WHEN H.CY_LOJA <> A.C7_LOJA THEN '|C7_LOJA' ELSE '' END), " + CRLF
    cQry += "     1, 1, ''),'') AS CAMPOS_ALTERADOS " + CRLF
    cQry += "  " + CRLF
    cQry += " FROM Atual A " + CRLF
    cQry += " FULL OUTER JOIN Historico H " + CRLF
    cQry += " ON A.C7_NUM = H.CY_NUM AND A.C7_ITEM = H.CY_ITEM " + CRLF
    cQry += " ) " + CRLF
    cQry += " SELECT * FROM FINAL WHERE ALTERADO = 'SIM' OR NOVO_ITEM = 'SIM' " + CRLF

    cAlias := MpSysOpenQuery(cQry)

    nCount := 0
    While !(cALias)->(EOF())
        aAdd(aRet, { ++nCount ,;
                    { (cAlias)->ITEM ,;
                    Alltrim((cAlias)->PROD_ATUAL),;
                    Posicione("SB1",1,FWXFilial("SB1")+(cAlias)->PROD_ATUAL,"B1_DESC"),;
                    (cAlias)->UND_HISTORICO,;
                    (cAlias)->UND_ATUAL,;
                    (cAlias)->QTD_HISTORICO,;
                    (cAlias)->QTD_ATUAL,;
                    (cAlias)->UNIT_HISTORICO,;
                    (cAlias)->UNIT_ATUAL,;
                    (cAlias)->TOT_HISTORICO,;
                    (cAlias)->TOT_ATUAL }} )
        (cALias)->(DbSkip())
    EndDo
    (cALias)->(dbCloseArea())
    
    FwRestArea(aArea)
Return aRet

Static Function zLdSC7(oModel)
    Local aArea     := FwGetArea()
    Local cQry      := ""
    Local cAlias    := ""
    Local aRet      := {}
    Local nCount    := 0
    Local nI        := 0
    Local aMdStruct := oModel:GetModel("SC7"):aModelStruct[1,4,1,4,1,3]:aHeader

    cQry += " SELECT * FROM "+RetSqlName("SC7")+"" + CRLF
    cQry += " WHERE C7_FILIAL = '"+SCR->CR_FILIAL+"'" + CRLF
    cQry += " AND C7_NUM = '"+Alltrim(SCR->CR_NUM)+"'" + CRLF
    cQry += " AND D_E_L_E_T_ = ''" + CRLF

    cAlias := MpSysOpenQuery(cQry)

    While !(cALias)->(EOF())
        aAdd(aRet,{++nCount , {} } )

        For nI := 1 to Len(aMdStruct)
            if aMdStruct[nI][10] $ 'V'
                IF aMdStruct[nI][2] == "C7_DESCRI"
                    aAdd(aRet[Len(aRet)][2],Posicione("SB1",1,FWXFilial("SB1")+(cAlias)->C7_PRODUTO,"B1_DESC"))
                ELSEIF aMdStruct[nI][2] == "C7_X_FORNE"
                    aAdd(aRet[Len(aRet)][2],Posicione("SA2",1,FWXFilial("SA2")+(cAlias)->C7_FORNECE,"A2_NOME"))
                else
                    IF aMdStruct[nI][8] == "N"
                        aAdd(aRet[Len(aRet)][2],0)
                    else
                        aAdd(aRet[Len(aRet)][2],"")
                    endif
                Endif
            else
                if aMdStruct[nI][8] == "M"
                    aAdd(aRet[Len(aRet)][2],"")
                elseif aMdStruct[nI][8] == "D"
                    aAdd(aRet[Len(aRet)][2],sToD((cAlias)->&(aMdStruct[nI][2])))
                else
                    aAdd(aRet[Len(aRet)][2],(cAlias)->&(aMdStruct[nI][2]))
                Endif
            endif
        next nI

        (cALias)->(DbSkip())
    enddo 
    (cALias)->(dbCloseArea())

    FwRestArea(aArea)
Return aRet
Static Function zLdSCY(oModel)
    Local aArea     := FwGetArea()
    Local cQry      := ""
    Local cAlias    := ""
    Local aRet      := {}
    Local nCount    := 0
    Local nI        := 0
    Local aMdStruct := oModel:GetModel("SCY"):aModelStruct[1,4,1,4,2,3]:aHeader

    cQry += " SELECT * FROM "+RetSqlName("SCY")+" " + CRLF
    cQry += " WHERE CY_NUM = '"+Alltrim(SCR->CR_NUM)+"' AND D_E_L_E_T_ = '' " + CRLF
    cQry += " AND CY_VERSAO = (SELECT MAX(CY_VERSAO) FROM "+RetSqlName("SCY")+"  " + CRLF
    cQry += "                   WHERE CY_NUM = '"+Alltrim(SCR->CR_NUM)+"' " + CRLF
    cQry += "                   AND CY_FILIAL = '"+SCR->CR_FILIAL+"' " + CRLF
    cQry += "                   AND D_E_L_E_T_ = '' ) " + CRLF
    cQry += " AND CY_FILIAL = '"+SCR->CR_FILIAL+"' " + CRLF

    cAlias := MpSysOpenQuery(cQry)

    While !(cALias)->(EOF())
        aAdd(aRet,{++nCount , {} } )

        For nI := 1 to Len(aMdStruct)
            if aMdStruct[nI][10] $ 'V'
                IF aMdStruct[nI][2] == "CY_DESCRI"
                    aAdd(aRet[Len(aRet)][2],Posicione("SB1",1,FWXFilial("SB1")+(cAlias)->C7_PRODUTO,"B1_DESC"))
                else
                    IF aMdStruct[nI][8] == "N"
                        aAdd(aRet[Len(aRet)][2],0)
                    else
                        aAdd(aRet[Len(aRet)][2],"")
                    endif
                Endif
            else
                if aMdStruct[nI][8] == "M"
                    aAdd(aRet[Len(aRet)][2],"")
                elseif aMdStruct[nI][8] == "D"
                    aAdd(aRet[Len(aRet)][2],sToD((cAlias)->&(aMdStruct[nI][2])))
                else
                    aAdd(aRet[Len(aRet)][2],(cAlias)->&(aMdStruct[nI][2]))
                Endif
            endif
        next nI

        (cALias)->(DbSkip())
    enddo
    (cALias)->(dbCloseArea())

    FwRestArea(aArea)
Return aRet

//Inicializador do campo CR_ALTERAD NA SCR
User Function C15INIT()
    Local aArea := FwGetArea()
    Local cRet  := "Não" //S=SIM;N=NAO

    DbSelectArea("SCY")
    SCY->(DbSetOrder(1))
    
    if SCY->(dbSeek(FWXFilial("SCY")+Alltrim(SCR->CR_NUM)))
        cRet := "Sim"
    endif

    SCY->(DbCloseArea())
    
    FwRestArea(aArea)
Return cRet

Static Function CriaLabel(o1Panel,o1OtherObject)
    Local aTamanho  := MsAdvSize()
    Local nObjLinha := 10
    Local nObjColun := 5
    Local nObjLargu := aTamanho[5]
    Local nObjAltur := 15
    Local cSayObj1  := "Campos Alterados"

    oSayObj2  := TSay():New(nObjLinha, nObjColun, {|| cSayObj1}, o1Panel, /*cPicture*/, oFontPadrao, , , , .t., RGB(255, 0, 0), /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)
Return
