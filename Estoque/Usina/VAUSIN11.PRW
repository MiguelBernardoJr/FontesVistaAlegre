#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTitulo := "Apuração de Custo - Compra de Levedura"
User Function VAUSIN11()
    Local aArea		:= FWGetArea()
    Private oBrowse
    Private cPerg		:= SubS(ProcName(),3)
    Private cPath 	 	:= "C:\totvs_relatorios\"
    Private cArquivo   	:= cPath  + cPerg  +; // _cUserID+""+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".txt"
    Private aDados      := {}

    gerax1(cPerg)

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZAC")
	oBrowse:SetDescription(cTitulo)
   // oBrowse:AddFilter(< cFilter>, < cExpAdvPL>, [ lNoCheck], [ lSelected], [ cAlias], [ lFilterAsk], [ aFilParser], [ cID] ) -->
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 		:= nil
	Local oCab   		:= FWFormStruct(1, 'ZAC', {|cCampo| AllTrim(cCampo) $ "ZAC_FILIAL|ZAC_CODIGO|ZAC_FORNEC|ZAC_LOJA|ZAC_NOME|ZAC_DTINI|ZAC_DTFIM|ZAC_VESALQ|ZAC_DTESAL|ZAC_DESALQ|ZAC_STATUS" })
	Local oGrid   		:= FWFormStruct(1, 'ZAC', {|cCampo| !(AllTrim(cCampo) $ "ZAC_FILIAL|ZAC_CODIGO|ZAC_FORNEC|ZAC_LOJA|ZAC_NOME|ZAC_DTINI|ZAC_DTFIM|ZAC_VESALQ|ZAC_DTESAL|ZAC_DESALQ|ZAC_STATUS") })
    Local aZACRel       := {}
    Local aGatilhos     := {}
    Local nI

    aAdd(aGatilhos, FWStruTrigger( "ZAC_LOJA","ZAC_NOME","SA2->A2_NOME",.t.,"SA2",1,"FwxFilial('SA2')+M->ZAC_FORNEC+M->ZAC_LOJA",NIL,"01"))

	For nI := 1 To Len(aGatilhos)
        oCab:AddTrigger(  aGatilhos[nI][01],; //Campo Origema
						    aGatilhos[nI][02],; //Campo Destino
						    aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
						    aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next
    
    aGatilhos := {}
    aAdd(aGatilhos, FWStruTrigger( "ZAC_PESOL","ZAC_DIFPES","ABS(M->ZAC_PESOL - M->ZAC_QTDNF)",.F.,"",NIL,"",NIL,"01"))
    aAdd(aGatilhos, FWStruTrigger( "ZAC_GLVA","ZAC_DIFGL","ABS(M->ZAC_GLVA - M->ZAC_GLFOR)",.F.,"",NIL,"",NIL,"01"))
    aAdd(aGatilhos, FWStruTrigger( "ZAC_MSVA","ZAC_DIFMS","ABS(M->ZAC_MSVA - M->ZAC_MSFOR)",.F.,"",NIL,"",NIL,"01"))
    
	For nI := 1 To Len(aGatilhos)
        oGrid:AddTrigger(  aGatilhos[nI][01],; //Campo Origem
						    aGatilhos[nI][02],; //Campo Destino
						    aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
						    aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next
    
    oCab:SetProperty( 'ZAC_FORNEC', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )

    /* REMOVER DEPOIS */
   //oCab:SetProperty( 'ZAC_FORNEC', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "'000013'" ) )
   //oCab:SetProperty( 'ZAC_LOJA'  , MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "'01'" ) )
   //oCab:SetProperty( 'ZAC_DTINI' , MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "cToD('01/01/2024')" ) )
   //oCab:SetProperty( 'ZAC_DTFIM' , MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "cToD('11/21/2024')" ) )
   //oCab:SetProperty( 'ZAC_VESALQ', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "2.530" ) )
   //oCab:SetProperty( 'ZAC_DESALQ', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "85" ) )
    
    oCab:SetProperty( 'ZAC_VESALQ', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_U11VDES()" ) )
    oCab:SetProperty( 'ZAC_DESALQ', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "U_U11VDES()") )

   
	oModel := MPFormModel():New("USIN11M")

	oModel:AddFields("ZACMASTER",/*cOwner*/  ,oCab		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddGrid('ZACDETAIL', 'ZACMASTER'	, oGrid     , /*bLinePre*/, /*bLinePos*//* {|| VldLinha()} */,{ |oGrid, nLine,cAction, cField| vldLinha(oGrid, nLine, cAction, cField) },/* bPos */, /* {|| LoadGrid()} */ )

	aAdd(aZACRel, {'ZAC_FILIAL', 'Iif(!INCLUI, ZAC->ZAC_FILIAL , FWxFilial("ZAC"))'} )
	aAdd(aZACRel, {'ZAC_CODIGO', 'Iif(!INCLUI, ZAC->ZAC_CODIGO , ZAC->ZAC_CODIGO)'} )
	
	//Criando o relacionamento
	oModel:SetRelation('ZACDETAIL', aZACRel, ZAC->(IndexKey(1)))
	oModel:SetPrimaryKey({"ZAC_FILIAL"+"ZAC_CODIGO"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:GetModel("ZACMASTER"):SetDescription("Formulário: " + cTitulo)
	oModel:GetModel("ZACDETAIL"):SetDescription("Grid: " + cTitulo)

	oModel:GetModel("ZACDETAIL"):SetNoInsertLine(.t.)
	
    oModel:InstallEvent("VLD_MODEL", , cClassCommit():New(oModel))

Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAUSIN11")
    Local oCab   		:= FWFormStruct(2, 'ZAC', {|cCampo| AllTrim(cCampo) $ "ZAC_FILIAL|ZAC_CODIGO|ZAC_FORNEC|ZAC_LOJA|ZAC_NOME|ZAC_DTINI|ZAC_DTFIM|ZAC_VESALQ|ZAC_DTESAL|ZAC_DESALQ|ZAC_STATUS" })
	Local oGrid   		:= FWFormStruct(2, 'ZAC', {|cCampo| !(AllTrim(cCampo) $ "ZAC_FILIAL|ZAC_CODIGO|ZAC_FORNEC|ZAC_LOJA|ZAC_NOME|ZAC_DTINI|ZAC_DTFIM|ZAC_VESALQ|ZAC_DTESAL|ZAC_DESALQ|ZAC_STATUS") })
	Local oView         

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZAC", oCab  , "ZACMASTER")
	oView:AddGrid("GRID_ZAC", oGrid  , "ZACDETAIL")
    
	oView:CreateHorizontalBox('CABEC', 30 )
	oView:CreateHorizontalBox('GRID', 70 )

	oView:SetOwnerView("VIEW_ZAC"	 , "CABEC")
	oView:SetOwnerView("GRID_ZAC"	 , "GRID")
	
	oView:EnableTitleView('VIEW_ZAC'  , "Cabeçalho")
	oView:EnableTitleView('GRID_ZAC'  , "Itens")
	
	oView:AddUserButton( 'Liberar / Bloquear movimentação [F9]','', {|| CloseCab()} )
	oView:AddUserButton( 'Preencher Grid [F10]','', {|| USIN11PG()} )
    
    SetKey( VK_F9 , { || CloseCab() } )
    SetKey( VK_F10, { || USIN11PG() } ) // Preencher Grid
    
    oView:SetCloseOnOk( { |oView| .T. } )
Return oView

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VAUSIN11' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VAUSIN11' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAUSIN11' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VAUSIN11' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 
	ADD OPTION aRotina TITLE 'Relatório'  ACTION 'U_VAUSINR1'       OPERATION 6                      ACCESS 0 //OPERATION 5 
Return aRotina

User Function USIN11M()
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
		
		if cIdPonto == "MODELVLDACTIVE"
			nOper := oModel:nOperation

			//Se for inclusão, define o ini padrão
			If nOper == 3 .or. nOper == 4 .or. nOper == 5
                if !(cUserName $ GetMV("USIN11"))
                    MsgStop("Usuário com permissão apenas para visualizar!","Atenção")
                    lRet := .F.
                endif
			endif
		elseif Alltrim(cIdPonto) == 'MODELPOS'
			
	    endif
	endif
Return lRet

Static Function USIN11PG()
    Local aArea     := GetArea()
    Local oView     := FWViewActive()
    Local oModel    := FWModelActive()
    Local oCab      := oModel:GetModel("ZACMASTER")
    Local oGrid     := oModel:GetModel("ZACDETAIL")
    Local nOpc      := oMOdel:GetOperation()
    Local cQry 		:= ""
    Local cAlias    := GetNextAlias()
    Local cAlias1   := nil
    Local oQryCache := nil 
    Local lStop     := .F.
    Local aPrecoMs  := {}
    Local nPrecoMs  := 0
    Local nMsMedia  := 0
    Local nTotMs    := 0
    Local nTotEt    := 0
    Local nGlMedia  := 0
    Local nTotal    := 0
    Local nTotTon   := 0
    Local cArquivo      := "C:\TOTVS_RELATORIOS\"

    if nOpc != 3
        MsgStop("Essa ação só pode ser executada em uma operação de inclusão!")
        return nil
    endif
    
    cQry := " WITH NotasSeparadas AS ( " + CRLF
    cQry += "     SELECT  " + CRLF
    cQry += "         ZAL.R_E_C_N_O_, " + CRLF
    cQry += "         ZAL.ZAL_FILIAL, " + CRLF
    cQry += "         ZAL.ZAL_DATA, " + CRLF
    cQry += "         value AS NOTA, -- cada nota da lista " + CRLF
    cQry += "         ZAL.ZAL_FORNEC, " + CRLF
    cQry += "         ZAL.ZAL_LOJA, " + CRLF
    cQry += "         ZAL.ZAL_DTPES, " + CRLF
    cQry += "         ZAL.ZAL_ZPBCOD, " + CRLF
    cQry += "         ZAL.ZAL_KGM3, " + CRLF
    cQry += "         ZAL.ZAL_TFERM, " + CRLF
    cQry += "         ZAL.ZAL_TALCOL, " + CRLF
    cQry += "         ZAL.ZAL_DENAPA, " + CRLF
    cQry += "         ZAL.ZAL_FOLU, " + CRLF
    cQry += "         ZAL.ZAL_MATSEX, " + CRLF
    cQry += "         ZAL.ZAL_FMATSE, " + CRLF
    cQry += "         ZAL.ZAL_FTALCO, " + CRLF
    cQry += "         ZAL.ZAL_MKGM3 " + CRLF
    cQry += "     FROM "+RetSqlName("ZAL")+" ZAL " + CRLF
    cQry += "     CROSS APPLY STRING_SPLIT(ZAL.ZAL_NF, ';') " + CRLF
    cQry += "     WHERE ZAL.D_E_L_E_T_ = '' " + CRLF
    cQry += "     AND ZAL.ZAL_FORNEC = '"+oCab:GetValue("ZAC_FORNEC")+"' " + CRLF
    cQry += "     AND ZAL.ZAL_LOJA = '"+oCab:GetValue("ZAC_LOJA")+"' " + CRLF
    cQry += "     AND ZAL.ZAL_DATA BETWEEN '"+dToS(oCab:GetValue("ZAC_DTINI"))+"' AND '"+dToS(oCab:GetValue("ZAC_DTFIM"))+"' " + CRLF
    cQry += "     AND ZAL.ZAL_TIPO = '1' " + CRLF
    cQry += "     AND ZAL.ZAL_PROC <> 'S' " + CRLF
    cQry += " ), " + CRLF
    cQry += " DadosComValores AS ( " + CRLF
    cQry += "     SELECT  " + CRLF
    cQry += "         N.*, " + CRLF
    cQry += "         F1.F1_FILIAL, " + CRLF
    cQry += "         F1.F1_VALBRUT, " + CRLF
    cQry += "         D1.D1_QUANT, " + CRLF
    cQry += "         ZPB.ZPB_PESOL " + CRLF
    cQry += "     FROM NotasSeparadas N " + CRLF
    cQry += "     LEFT JOIN "+RetSqlName("SF1")+" F1 ON F1.F1_DOC = N.NOTA AND F1.F1_FORNECE = N.ZAL_FORNEC AND F1.F1_LOJA = N.ZAL_LOJA AND F1.D_E_L_E_T_ = '' " + CRLF
    cQry += "     LEFT JOIN "+RetSqlName("SD1")+" D1 ON D1.D1_DOC = N.NOTA AND D1.D1_FORNECE = N.ZAL_FORNEC AND D1.D1_LOJA = N.ZAL_LOJA AND D1.D_E_L_E_T_ = '' " + CRLF
    cQry += "     LEFT JOIN "+RetSqlName("ZPB")+" ZPB ON ZPB.ZPB_DATA = N.ZAL_DTPES AND ZPB.ZPB_CODIGO = N.ZAL_ZPBCOD AND ZPB.D_E_L_E_T_ = '' " + CRLF
    cQry += " ) " + CRLF
    cQry += " SELECT  " + CRLF
    cQry += "     ZAL_FILIAL, " + CRLF
    cQry += "     ZAL_DATA, " + CRLF
    cQry += "     STRING_AGG(NOTA, ';') AS ZAL_NF, " + CRLF
    cQry += "     ZAL_FORNEC, " + CRLF
    cQry += "     ZAL_LOJA, " + CRLF
    cQry += "     ZAL_DTPES, " + CRLF
    cQry += "     ZAL_ZPBCOD, " + CRLF
    cQry += "     F1_FILIAL, " + CRLF
    cQry += "     SUM(F1_VALBRUT) AS F1_VALBRUT, " + CRLF
    cQry += "     SUM(D1_QUANT) AS D1_QUANT, " + CRLF
    cQry += "     MAX(ZPB_PESOL) AS ZPB_PESOL, " + CRLF
    cQry += "     ZAL_KGM3, " + CRLF
    cQry += "     ZAL_TFERM, " + CRLF
    cQry += "     ZAL_TALCOL, " + CRLF
    cQry += "     ZAL_DENAPA, " + CRLF
    cQry += "     ZAL_FOLU, " + CRLF
    cQry += "     ZAL_MATSEX, " + CRLF
    cQry += "     ZAL_FMATSE, " + CRLF
    cQry += "     ZAL_FTALCO, " + CRLF
    cQry += "     ZAL_MKGM3, " + CRLF
    cQry += "     R_E_C_N_O_ AS RECNO " + CRLF
    cQry += " FROM DadosComValores " + CRLF
    cQry += " GROUP BY  " + CRLF
    cQry += "     ZAL_FILIAL, ZAL_DATA, ZAL_FORNEC, ZAL_LOJA, ZAL_DTPES, ZAL_ZPBCOD, " + CRLF
    cQry += "     F1_FILIAL,ZAL_KGM3, ZAL_TFERM, ZAL_TALCOL, ZAL_DENAPA, ZAL_FOLU, ZAL_MATSEX, " + CRLF
    cQry += "     ZAL_FMATSE, ZAL_FTALCO, ZAL_MKGM3, R_E_C_N_O_ " + CRLF
    
    If lower(cUserName) $ 'Administrador,bernardo,ioliveira,atoshio'
		MemoWrite(StrTran(cArquivo,".xml","")+cPerg+".sql" , cQry)
	EndIf

    MpSysOpenQuery( cQry , cAlias )

    if (cAlias)->(EOF())
        MsgStop("Não foram encontrados dados com os parâmetros informados!!")
        (cAlias)->(DbCloseArea())
        return nil
    endif
    
    cQry := " SELECT ZML_TONMS FROM "+RetSqlName("ZML")+"" + CRLF
    cQry += " WHERE D_E_L_E_T_ = ''" + CRLF
    cQry += " AND ZML_FILIAL = ?" + CRLF
    cQry += " AND ZML_FORNEC = ?" + CRLF
    cQry += " AND ZML_LOJA = ?" + CRLF
    cQry += " AND ZML_DATAD <= ?" + CRLF
    cQry += " AND ZML_DATAF >= ?" + CRLF
    cQry += " AND ZML_FERM = ?" + CRLF

    oQryCache := FwExecStatement():New(cQry)

    oGrid:SetNoInsertLine(.f.)

    //BUSCANDO PREÇO NA ZML, SE NÃO ENCONTRAR, PARA A OPERAÇÃO
    while !(cAlias)->(EOF())
        oQryCache:SetString (1,FwXFilial("ZAC"))
        oQryCache:SetString (2,oCab:GetValue("ZAC_FORNEC"))
        oQryCache:SetString (3,oCab:GetValue("ZAC_LOJA")  )
        oQryCache:SetDate   (4,oCab:GetValue("ZAC_DTINI") )
        oQryCache:SetDate   (5,oCab:GetValue("ZAC_DTFIM") )
        oQryCache:SetNumeric(6,noRound(((cAlias)->(ZAL_MATSEX+ZAL_FMATSE)) / 2,0) )

        cAlias1 := oQryCache:OpenAlias()

        oQryCache:ExecScalar('ZML_TONMS')
        
        nTotMs   := 0
        nPrecoMs := 0
        if !lStop .and. (cAlias1)->ZML_TONMS == 0
            MsgStop("Não foi encontrado registro de preço para esse fornecedor!" + CRLF +; 
                    "Verifique a Rotina 'Preço M.S da Levedura' se existe registro para: " + CRLF +; 
                    "Fornecedor:    " + oCab:GetValue("ZAC_FORNEC") + CRLF +; 
                    "Loja:          " + oCab:GetValue("ZAC_LOJA") + CRLF +; 
                    "Data Inicial:  " + dToC(oCab:GetValue("ZAC_DTINI")) + CRLF +; 
                    "Data Final:    " + dToC(oCab:GetValue("ZAC_DTFIM")) + CRLF +;
                    "Valor:         " + AllTRIM(Str(Round(((cAlias)->(ZAL_MATSEX+ZAL_FMATSE)) / 2,0)) ))
            lStop := .T.
        else
            aAdd(aPrecoMs, {  (cAlias)->ZAL_NF, (cAlias1)->ZML_TONMS } )
        endif
        (cAlias1)->(DbCloseArea())

        (cAlias)->(DbSkip())
    enddo

    oQryCache:Destroy()
    oQryCache := nil

    if !lStop
        (cAlias)->(DbGoTop())
        while !(cAlias)->(EOF())

            oGrid:AddLine()
            oGrid:SetValue("ZAC_FILNF"  ,Alltrim((cAlias)->F1_FILIAL) )//ok
            oGrid:SetValue("ZAC_NOTFIS" ,AllTrim((cAlias)->ZAL_NF)    )//ok
            oGrid:SetValue("ZAC_VALNFN" ,(cAlias)->F1_VALBRUT)//ok
            oGrid:SetValue("ZAC_QTDNF"  ,(cAlias)->D1_QUANT  )//ok
            oGrid:SetValue("ZAC_PESOL"  ,(cAlias)->ZPB_PESOL )//ok
            
            nPesoMedio := ((cAlias)->(D1_QUANT+ZPB_PESOL)) / 2
            oGrid:SetValue("ZAC_PESOM"  , nPesoMedio )

            oGrid:SetValue("ZAC_DENSI"  ,(cAlias)->ZAL_KGM3   )

            nM3Etanol := (nPesoMedio / 1000) / (cAlias)->ZAL_KGM3
            oGrid:SetValue("ZAC_M3ETAN" , nM3Etanol  )
            oGrid:SetValue("ZAC_GLFOR"  , (cAlias)->ZAL_FTALCO )
            oGrid:SetValue("ZAC_GLVA"   , (cAlias)->ZAL_TALCOL )

            nGlMedia := ((cAlias)->(ZAL_FTALCO+ZAL_TALCOL)) / 2
            oGrid:SetValue("ZAC_GLMED"  , nGlMedia)

            oGrid:SetValue("ZAC_MSFOR"  ,(cAlias)->ZAL_FMATSE )
            oGrid:SetValue("ZAC_MSVA"   ,(cAlias)->ZAL_MATSEX )

            nMsMedia := ((cAlias)->(ZAL_MATSEX+ZAL_FMATSE)) / 2
            oGrid:SetValue("ZAC_MSMEDI" ,nMsMedia)

            nPrecoMs := aPrecoMs[ aScan( aPrecoMs ,{ |x| x[1] == (cAlias)->ZAL_NF } ) , 2 ]
            oGrid:SetValue("ZAC_MSPREC" , nPrecoMs )

            nTotMs := Round(( nPesoMedio / 1000 ) * (nMsMedia / 100) * nPrecoMs,2)
            oGrid:SetValue("ZAC_RTOTMS" , nTotMs)

            nTotEt := Round(nM3Etanol * ( nGlMedia / 100 ) * (( oCab:GetValue("ZAC_VESALQ") * (oCab:GetValue("ZAC_DESALQ")) / 100)) * 1000,4)
            oGrid:SetValue("ZAC_RTOTET" , nTotEt )
            
            nTotal := Round(nTotEt + nTotMs,2)
            oGrid:SetValue("ZAC_RTOTAL" , nTotal)
            
            nTotTon := Round(nTotal / ( nPesoMedio / 1000 ),2)
            oGrid:SetValue("ZAC_RTONEL" , nTotTon)

            // 251,05
            oGrid:SetValue("ZAC_RTOMS"  , Round(nTotTon / ( nMsMedia / 100 ),2)) 
            oGrid:SetValue("ZAC_RTODIF" , Round(nTotal - (cAlias)->F1_VALBRUT,2))
            oGrid:SetValue("ZAC_RECZAL" , (cAlias)->RECNO )

            (cAlias)->(DbSkip())
        enddo

    endif 
    (cAlias)->(DbCloseArea())

    oGrid:GoLine(1)
    oGrid:SetNoInsertLine(.T.)
    
    oView:Refresh()

    RestArea(aArea)
Return 

Static Function GeraX1(cPerg)

    Local _aArea	:= GetArea()
    Local aRegs     := {}
    Local nX		:= 0
    Local nPergs	:= 0
    Local i, j

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

    aAdd(aRegs,{cPerg, "01", "Fornecedor:  " , "", "", "MV_CH1", "C", TamSX3("A2_COD")[1]    , TamSX3("A2_COD")[2]    , 0, "G", "!Vazio() "                                         , "MV_PAR01" , "", "","",""      ,"","","","","","","","","","","","","","","","","","","","","SA2","","","","",""})
    aAdd(aRegs,{cPerg, "02", "Loja:        " , "", "", "MV_CH2", "C", TamSX3("A2_LOJA")[1]   , TamSX3("A2_LOJA")[2]   , 0, "G", "!Vazio() .or. ExistCpo('SA2',MV_PAR01 + MV_PAR02 )", "MV_PAR02" , "", "","",""      ,"","","","","","","","","","","","","","","","","","","","","SA2","","","","",""})
    aAdd(aRegs,{cPerg, "03", "Data de:     " , "", "", "MV_CH3", "D", TamSX3("D2_DTDIGIT")[1], TamSX3("D2_DTDIGIT")[2], 0, "G", "!Vazio()"                                          , "MV_PAR03" , "", "","",""	   ,"","","","","","","","","","","","","","","","","","","","",""   ,"","","","",""})
    aAdd(aRegs,{cPerg, "04", "Data até:    " , "", "", "MV_CH4", "D", TamSX3("D2_DTDIGIT")[1], TamSX3("D2_DTDIGIT")[2], 0, "G", "!Vazio()"                                          , "MV_PAR04" , "", "","",""      ,"","","","","","","","","","","","","","","","","","","","",""   ,"","","","",""})

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

    // gravaÃ§Ã£o das perguntas na tabela SX1
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

Class cClassCommit From FWModelEvent
    Method New() CONSTRUCTOR
    Method After()
EndClass
Method New(oModel) CLASS cClassCommit
Return
Method After(oModel) Class cClassCommit
    Local aArea := GetArea()
    Local cVar  := ""
    Local nOPc  := oModel:GetOperation()
    
    if oModel:cId == 'ZACDETAIL'
        if nOPc == 3 .OR. nOPc == 4
            if Deleted()
                cVar := "N"
            else 
                cVar := "S"
            endif 
        elseif nOPc == 5
            cVar := "N"
        endif

        //Campos de controle, para registrar oq estava registrado na SB1 antes de altera-lá
        DBSELECTAREA( "ZAL" )
        ZAL->(DBSETORDER( 1 ))

        if ZAC->ZAC_RECZAL > 0
            ZAL->(DbGoTo(ZAC->ZAC_RECZAL))
                RecLock("ZAL",.F.)
                    ZAL->ZAL_PROC := cVar
                ZAL->(MsUnlock())
        endif

    endif
    RestArea(aArea)
Return
User Function U11VDES()
    Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local oGrid     := oModel:GetModel('ZACDETAIL')/* :SetUniqueLine({'ZAC_CODIGO'}) */
	Local oCab      := oModel:GetModel('ZACMASTER')/* :SetUniqueLine({'ZAC_CODIGO'}) */
    Local oView     := FWViewActive()
	Local nI        := 0
    Local nLinhas   := oGrid:Length() 
    Local cCampo    := ReadVar()
    Local nValor    := 0
    Local nTotEt, nRTotal, nRTonel, nRToMS,nRtoDif
    if "ZAC_DESALQ" $ cCampo
        nValor    := Round(oCab:GetValue("ZAC_VESALQ") * ( &(ReadVar()) / 100),4)
    else
        nValor    := Round(&(ReadVar()) * ( oCab:GetValue("ZAC_DESALQ") / 100),4)
    endif

    if !oGrid:IsEmpty()
        For nI := 1 to nLinhas
            
            nTotEt := Round(oGrid:GetValue("ZAC_M3ETAN") * (oGrid:GetValue("ZAC_GLMED") / 100 ) *  nValor * 1000,2)
            oGrid:SetValue("ZAC_RTOTET", nTotEt) //TOTAL ETANOL

            nRTotal := Round(oGrid:GetValue("ZAC_RTOTMS") + nTotEt,2)
            oGrid:SetValue("ZAC_RTOTAL", nRTotal)  //TOTAL

            nRTonel := Round(nRTotal / ( oGrid:GetValue("ZAC_PESOM") / 1000),2)
            oGrid:SetValue("ZAC_RTONEL", nRTonel )  // TOTAL TONELADA

            nRToMS :=  Round( nRTonel /  ( oGrid:GetValue("ZAC_MSMEDI") / 100 ),2)
            oGrid:SetValue("ZAC_RTOMS ", nRToMS) // TOTAL TONELADA MATERIA SECA

            nRtoDif := Round(oGrid:GetValue("ZAC_RTOTAL") -  oGrid:GetValue("ZAC_VALNFN"),2)
            oGrid:SetValue("ZAC_RTODIF", nRtoDif ) // DIFERENCA TOTAL
            
        next nI
    endif 

    oView:Refresh()

    RestArea(aArea)
Return .T.

//inicializador do campo código
User Function U11ICpo()
    Local cRet := ""
    Local aArea := GetArea()
    Local cALias := GetNextAlias()

    MpSysOpenQuery("SELECT MAX(ZAC_CODIGO) + 1 AS MAX FROM "+RetSqlName("ZAC")+" ", cAlias)

    if (cAlias)->(EOF())
        cRet := "000001"
    else
        cRet := StrZero((cAlias)->MAX,TamSX3("ZAL_CODIGO")[1])
    endif

    (cAlias)->(dbCloseArea())
    
    RestArea(aArea)

Return cRet 
//Encerra movimentação
Static Function CloseCab()
    Local aArea     := GetArea()
    Local oView     := FWViewActive()
	Local oModel    := FWModelActive()
	Local oCab      := oModel:GetModel('ZACMASTER')/* :SetUniqueLine({'ZAC_CODIGO'}) */
    Local cUsuario  := GetMV("USIN11")

    if cUserName $ cUsuario
        if oCab:GetValue("ZAC_STATUS") == 'A'
            if MsgYesNo("Essa ação bloqueará o cabeçalho e a grid.", "Deseja prosseguir?")
                oCab:SetValue("ZAC_STATUS","F")
            endif
        else
            if MsgYesNo("Essa ação desbloqueará o cabeçalho e a grid.", "Deseja prosseguir?")
                oCab:SetValue("ZAC_STATUS","A")
            endif 
        endif 
    else
        MsgStop("Usuário sem permissão.","Atenção!")
    endif
    
    oView:Refresh()
    
    RestArea(aArea)
Return 

Static Function vldLinha(oGrid, nLine,cAction, cField)
	Local oModel    := FWModelActive()
    Local oCab      := oModel:GetModel('ZACMASTER')/* :SetUniqueLine({'ZAC_CODIGO'}) */
    Local lRet      := .T. 

    if cAction == 'DELETE'
        if oCab:GetValue("ZAC_STATUS") == 'F'
            lRet := .f. 
            oModel:SetErrorMessage("","","","","Operação Inválida", 'Modo de edição não permitido quando o campo Status é igual a [F = Fechado]', "")
        endif 
    endif 
    
Return lRet
