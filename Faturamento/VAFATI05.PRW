#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Venda de Gado"
/*/{Protheus.doc} VAFATI05
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
User Function VAFATI05()
    Local aArea		 := FWGetArea()
	Local oBrowse
    Private _cRet    := CriaVar("B8_LOTECTL",.F.)
    Private aLotes   := {}
    Private aBovs    := {}
    Private aPreco   := {}
	Private cE1HIST  := ""
    Private nQtdAnt  := 0
    Private cTimeINI :=  Time()
	Private cArquivo := "C:\TOTVS_RELATORIOS\"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZVA")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 	:= nil
    Local oMaster   := FWFormStruct(1, 'ZVA', {|cCampo| AllTrim(cCampo) $ "ZVA_COD|ZVA_CLI|ZVA_LOJA|ZVA_NOME|ZVA_QTLO|ZVA_QTAT|ZVA_COND|ZVA_FRET|ZVA_DTEMIS|ZVA_MENPAD|ZVA_MENNT" })
    Local oGridZVA   	:= FWFormStruct(1, 'ZVA', {|cCampo| (AllTrim(cCampo) $ "ZVA_ITEM|ZVA_LOTE|ZVA_QUANT|ZVA_TES|ZVA_NUMSC5|ZVA_NF|ZVA_SERINF|ZVA_USER|ZVA_STATUS") })
    Local oGridZVB   	:= FWFormStruct(1, 'ZVB', {|cCampo| (AllTrim(cCampo) $ "ZVB_COD|ZVB_ITEM|ZVB_ITEMZA|ZVB_NUMSC5|ZVB_LOTE|ZVB_BOV|ZVB_DESC|ZVB_QUANT|ZVB_PRECO|ZVB_TOTAL") })
    Local aZVBRel   := {}
    Local aZVARel   := {}
    Local bCommit   := {|| bSaveCom()}

    oGridZVA:SetProperty('ZVA_LOTE'   ,   MODEL_FIELD_VALID, {|| FI05LT()})
    oGridZVA:SetProperty('ZVA_QUANT'  ,   MODEL_FIELD_VALID, {|| FI05QT()})

	oModel := MPFormModel():New("FATI05M", /*Pre-Validacao*/,/*Pos-Validacao*/,{|oModel| bSaveCom(oModel)},/*Cancel*/)

	oModel:AddFields("ZVAMASTER",/*cOwner*/  ,oMaster		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddGrid('ZVADETAIL', 'ZVAMASTER'	, oGridZVA, /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,/* {|| LoadGPrincipal()} */  )
	oModel:AddGrid('ZVBDETAIL', 'ZVADETAIL'	, oGridZVB, /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,/* {|| LoadGRodape()}    */  )

    aAdd(aZVARel, {'ZVA_FILIAL', 'Iif(!INCLUI, ZVA->ZVA_FILIAL, FWxFilial("ZVA"))'} )
	aAdd(aZVARel, {'ZVA_COD'   , 'Iif(!INCLUI, ZVA->ZVA_COD   , ZVA->ZVA_COD)'} )
	//aAdd(aZVARel, {'ZVA_ITEM'  , 'Iif(!INCLUI, ZVA->ZVA_ITEM  , ZVA->ZVA_ITEM)'} )

	oModel:SetRelation('ZVADETAIL', aZVARel, ZVA->(IndexKey(1)))

	aAdd(aZVBRel, {'ZVB_FILIAL', 'ZVA_FILIAL'} )
	aAdd(aZVBRel, {'ZVB_COD'   , 'ZVA_COD'} )
	aAdd(aZVBRel, {'ZVB_ITEMZA', 'ZVA_ITEM'} )

	oModel:SetRelation('ZVBDETAIL', aZVBRel, ZVB->(IndexKey(2)))
	
    oModel:SetPrimaryKey({"ZVA_FILIAL"+"ZVA_COD","ZVA_ITEM"})
	//oModel:GetModel('ZVADETAIL'):SetUniqueLine({ "ZVA_FILIAL","ZVA_COD", "ZVA_ITEM" })
    
	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZVAMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	oModel:GetModel("ZVBDETAIL"):SetDescription("Bovs escolhidos")
	
Return oModel

Static Function ViewDef()
	Local oModel    := FWLoadModel("VAFATI05")
    Local oMaster   := FWFormStruct(2, 'ZVA', {|cCampo| AllTrim(cCampo) $ "ZVA_COD|ZVA_CLI|ZVA_LOJA|ZVA_NOME|ZVA_QTLO|ZVA_QTAT|ZVA_COND|ZVA_FRET|ZVA_DTEMIS|ZVA_MENPAD|ZVA_MENNT" })
    Local oGridZVA  := FWFormStruct(2, 'ZVA', {|cCampo| (AllTrim(cCampo) $ "ZVA_ITEM|ZVA_LOTE|ZVA_QUANT|ZVA_TES|ZVA_NUMSC5|ZVA_NF|ZVA_SERINF|ZVA_USER|ZVA_STATUS") })
    Local oGridZVB  := FWFormStruct(2, 'ZVB', {|cCampo| (AllTrim(cCampo) $ "ZVB_COD|ZVB_ITEM|ZVB_ITEMZA|ZVB_NUMSC5|ZVB_LOTE|ZVB_BOV|ZVB_DESC|ZVB_QUANT|ZVB_PRECO|ZVB_TOTAL") })
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZVA", oMaster, "ZVAMASTER")
	oView:AddGrid('VIEW_IZVA', oGridZVA , 'ZVADETAIL')
	oView:AddGrid('VIEW_IZVB', oGridZVB , 'ZVBDETAIL')
    
	oView:CreateHorizontalBox('CABEC', 30 )
	oView:CreateHorizontalBox('GRIDM', 30 )
	oView:CreateHorizontalBox('GRIDR', 40 )
	
	oView:SetOwnerView("VIEW_ZVA"	 , "CABEC")
	oView:SetOwnerView("VIEW_IZVA"	 , "GRIDM")
	oView:SetOwnerView("VIEW_IZVB"	 , "GRIDR")
	
	oView:EnableTitleView('VIEW_ZVA'  , cTitulo)
    
    oView:AddIncrementField( 'VIEW_IZVA', 'ZVA_ITEM' )
	oView:AddIncrementField( 'VIEW_IZVB', 'ZVB_ITEM' )
	
    oView:AddUserButton( 'Gerar Pedido (F10)' 	,'', {|oView| ProcPed()} )
 	
    SetKey( VK_F10, {|oView| ProcPed()} )
	
	oView:SetCloseOnOk( { |oView| .T. } )
Return oView

Static Function MenuDef()
	Local aRotina := {} 

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAFATI05' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VAFATI05' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VAFATI05' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VAFATI05' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 
Return aRotina
//Pontos de Entrada
User Function FATI05M()
	Local aParam 		:= PARAMIXB
	Local xRet 			:= .T.
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local cIdIXB5		:= ''
	Local cIdIXB4		:= ''
	Local oModel 	 	:= nil
	Local oGridZVA 		:= nil
	Local oGridZVB 		:= nil
    Local nX, nI, nJ, nG
    Local cQry          := ''
    Local aArea 
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
            aLotes   := {}
            aBovs := {} 
            aPreco := {}
            //Buscar Valores para data atual
            cQry := "  select *  " + CRLF 
            cQry += " from "+RetSqlName("ZVC")+" " + CRLF 
            cQry += " WHERE ZVC_DATADE < '"+dToS(Date())+"' " + CRLF 
            cQry += " AND ZVC_DTATE > '"+dToS(Date())+"' " + CRLF 
            cQry += " AND D_E_L_E_T_ = '' " + CRLF

            MpSysOpenQuery(cQry, "TMP")

            while !TMP->(EOF())
                aAdd(aPreco,{ALLTRIM(TMP->ZVC_DESC),TMP->ZVC_PRECO})
                TMP->(DBSKIP())
            END

            TMP->(DBCLOSEAREA(  ))

            if oObj:nOperation == 4
                aArea := GetArea()

                cQry := "select *  " + CRLF
                cQry += " from "+RetSqlName("ZVA")+" ZVA  " + CRLF
                cQry += " where ZVA_NF <> ' '  " + CRLF
                cQry += " AND ZVA_SERINF <> ' '  " + CRLF
                cQry += " AND ZVA_DTEMIS <> ' '  " + CRLF
                cQry += " 	  AND ZVA_STATUS <> 'C'  " + CRLF
                cQry += " AND ZVA.D_E_L_E_T_ = ' '  " + CRLF
                cQry += " AND ZVA.ZVA_FILIAL + ZVA_CLI + ZVA_LOJA + ZVA_NF + ZVA_SERINF + ZVA_NUMSC5 IN ( " + CRLF
                cQry += "     SELECT D2_FILIAL + D2_CLIENTE + D2_LOJA + D2_DOC + D2_SERIE + D2_PEDIDO " + CRLF
                cQry += "         FROM "+RetSqlName("SD2")+" SD2 " + CRLF
                cQry += "     WHERE SD2.D2_FILIAL = ZVA_FILIAL  " + CRLF
                cQry += "         AND SD2.D2_CLIENTE = ZVA_CLI " + CRLF
                cQry += "         AND SD2.D2_LOJA = ZVA_LOJA " + CRLF
                cQry += "         AND SD2.D2_DOC = ZVA_NF " + CRLF
                cQry += "         AND SD2.D2_SERIE = ZVA_SERINF " + CRLF
                cQry += "         AND SD2.D2_PEDIDO = ZVA_NUMSC5 " + CRLF
                cQry += "         AND SD2.D_E_L_E_T_ <> ' ' -- FILTRAR NFS EXCLUIDAS " + CRLF
                cQry += "          ) " + CRLF
                
				MpSysOpenQuery(cQry, "TMP")
                
                while !TMP->(EOF())
					ZVA->(DBSELECTAREA( "ZVA" ))
					ZVA->(DBSETORDER( 2 )) //ZVA_FILIAL+ZVA_NUMSC5
				
					if ZVA->(DbSeek(FwxFilial("ZVA")+TMP->ZVA_NUMSC5))
						
						aCabPV  := {{"C5_NUM"    , TMP->ZVA_NUMSC5   , Nil},;
									{"C5_TIPO"   , "N"         		 , Nil},;
									{"C5_CLIENTE", TMP->ZVA_CLI 	 , Nil},;
									{"C5_LOJACLI", TMP->ZVA_LOJA	 , Nil},;
									{"C5_LOJAENT", TMP->ZVA_LOJA	 , Nil},;
									{"C5_CONDPAG", TMP->ZVA_COND     , NIL}}

                        cQry := " SELECT *  " + CRLF 
                        cQry += " FROM "+RetSqlName("ZVB")+" " + CRLF 
                        cQry += " WHERE ZVB_FILIAL = '"+FWxFilial("ZVB")+"' " + CRLF 
                        cQry += " AND ZVB_COD = '"+TMP->ZVA_COD+"' " + CRLF 
                        cQry += " AND ZVB_ITEMZA = '"+TMP->ZVA_ITEM+"' " + CRLF 
                        cQry += " AND D_E_L_E_T_ = ''  " + CRLF 
                        
                        aItemPV := {}
                        MpSysOpenQuery(cQry, "TMPZVB")

                        while !TMPZVB->(EOF())
                            aAdd(aItemPV,{  {"C6_NUM"    	, TMPZVB->ZVB_NUMSC5   , Nil},;
                                            {"C6_ITEM"   	, TMPZVB->ZVB_ITEM     , Nil},;
                                            {"C6_PRODUTO"	, TMPZVB->ZVB_BOV      , Nil},;
                                            {"C6_LOTECTL"	, TMPZVB->ZVB_LOTE     , Nil},;
                                            {"C6_QTDVEN" 	, TMPZVB->ZVB_QUANT    , Nil},;
                                            {"C6_PRCVEN" 	, TMPZVB->ZVB_PRECO    , Nil},;
                                            {"C6_VALOR"  	, TMPZVB->ZVB_TOTAL    , Nil},;
                                            {"C6_TES"    	, TMP->ZVA_TES	       , Nil}})
                            TMPZVB->(DBSKIP( ))
                        ENDDO
                        TMPZVB->(DBCLOSEAREA())
					
						lMsErroAuto := .F.
							while !LockByName("ExecSC5Auto"+ ZVA->ZVA_NUMSC5, .t., .f.)
								Sleep(500)
							end
								MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItemPV,5)
							UnlockByName("ExecSC5Auto"+ZVA->ZVA_NUMSC5)
							
							If lMSErroAuto
								MostraErro()
								aErroAuto := GetAutoGRLog()
								For nI := 1 To Len(aErroAuto)
									cLogErro += StrTran(StrTran(aErroAuto[nI], "<", ""), "-", "") + " "
									ConOut(cLogErro)
									Alert(cLogErro)
								Next nI
								DisarmTransaction()
							ENDIF 

						RECLOCK( "ZVA", .F. )
                            ZVA->ZVA_STATUS := "C"
						ZVA->(MSUNLOCK())

						MsgAlert( "A linha com o pedido [ "+ZVA->ZVA_NUMSC5+" ] teve o status alterado para [CANCELADO], pois a nota foi excluida.", "Atenção...")
						TMP->(DBSKIP())
					Endif
				ENDDO

				TMP->(DBCLOSEAREA(  ))
				FWRestArea(aArea)
            endif 
		ELSEIF Alltrim(cIdPonto) == "MODELCANCEL"
            RollBackSx8()
		else
			if Alltrim(cIdPonto) == "FORMPRE" .and. cIdModel == 'ZVADETAIL' .AND. cIdIXB5 == 'DELETE'
                oModel := FWModelActive()
                oGridZVA  := oModel:GetModel("ZVADETAIL")
                oGridZVB := oModel:GetModel("ZVBDETAIL")
                oGridZVB:SetNoDeleteLine(.F.)
                IF oGridZVA:GetValue("ZVA_STATUS") != 'F'
                    IF !EMPTY(oGridZVA:GetValue("ZVA_LOTE")) .or. !EMPTY(oGridZVA:GetValue("ZVA_QUANT"))
                        For nI := 1 to Len(aLotes)
                            if aLotes[nI][1] == oGridZVA:GetValue("ZVA_LOTE")
                                For nX := 1 to Len(aBovs)
                                    if aBovs[nX][1] == oGridZVA:GetValue("ZVA_LOTE")
                                        For nJ := 1 to Len(aBovs[nX][2])
                                            if aBovs[nX][2][nJ][1] == oGridZVA:GetValue("ZVA_ITEM")
                                                For nG := 1 to Len(aBovs[nX][2][nJ][2])
                                                    
                                                    //Posiciona Direto no aBov, Posicão [x][2][y][2][z][3] é a Posição do Array aBov
                                                    aLotes[nI][2][aBovs[nX][2][nJ][2][nG][3]][2] += aBovs[nX][2][nJ][2][nG][2] // Devolve valor para o vetor aBov, para ser utilizado novamente
                                                    aLotes[nI][3] += aBovs[nX][2][nJ][2][nG][2] // Devolve valor para o vetor aBov, adiciona no saldo TOTAL

                                                    oGridZVB:GoLine(nG)
                                                    oGridZVB:DeleteLine()
                                                Next nG
                                            endif
                                        Next nJ
                                        aDel(aBovs[nX][2] , nX)
                                        aSize(aBovs[nX][2], Len(aBovs[nX][2])-1) 
                                    EndIf 
                                Next nX
                            endif
                        Next nI
                    endif 
                ELSE 
                    oModel:SetErrorMessage("","","","","Pedido Gerado!", 'Não é possivel alterar quantidade em linhas com pedido gerado.', "") 
                    xRet := .F.
                endif 
                oGridZVB:SetNoDeleteLine(.T.)
                xRet := .T.
 			elseif  Alltrim(cIdPonto) == "FORMPRE" .and. cIdModel == 'ZVADETAIL' .AND. cIdIXB5 == 'UNDELETE'/* !(aParam[5] $ "ISENABLE-ADDLINE") */
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

Static Function bSaveCom(oModel)
    Local aArea     := GetArea()
	Local oCab      := oModel:GetModel('ZVAMASTER')
	Local oGridZVA  := oModel:GetModel('ZVADETAIL')
	Local oGridZVB  := oModel:GetModel('ZVBDETAIL')
	Local nOpc      := oModel:GetOperation()
	Local nI,nX
    Local nTotZA, nTotZB
    Local lRet      := .T. 

    DbSelectArea('ZVA')
	ZVA->(DbSetOrder(1)) //ZVA_FILIAL+ZVA_COD+ZVA_ITEM

    DbSelectArea('ZVB')
    ZVB->(DbSetOrder(1)) //ZVB_FILIAL + ZVB_COD + ZVB_ITEMZA + ZVB_ITEM

	//Se for Exclusão
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
        nTotZA := oGridZVA:GetQtdLine()
        ConfirmSx8()
        For nI := 1 To nTotZA
            oGridZVA:GoLine(nI)
            If !oGridZVA:isDeleted()
                
                RecLock('ZVA', lRecLock := !ZVA->(DbSeek( FWxFilial("ZVA") +;
                                                          oCab:GetValue('ZVA_COD') +;
                                                          oGridZVA:GetValue('ZVA_ITEM'))))

                ZVA->ZVA_FILIAL    	:= FWxFilial("ZVA")
                ZVA->ZVA_COD 	   	:= oCab:GetValue('ZVA_COD')
                ZVA->ZVA_CLI    	:= oCab:GetValue('ZVA_CLI')
                ZVA->ZVA_LOJA    	:= oCab:GetValue('ZVA_LOJA')
                ZVA->ZVA_COND   	:= oCab:GetValue('ZVA_COND')
                ZVA->ZVA_DTEMIS     := oCab:GetValue('ZVA_DTEMIS')
                ZVA->ZVA_FRET       := oCab:GetValue('ZVA_FRET')
                ZVA->ZVA_ITEM    	:= oGridZVA:GetValue('ZVA_ITEM')
                ZVA->ZVA_LOTE   	:= oGridZVA:GetValue('ZVA_LOTE')
                ZVA->ZVA_QUANT      := oGridZVA:GetValue('ZVA_QUANT')
                ZVA->ZVA_TES   	    := oGridZVA:GetValue('ZVA_TES')
                ZVA->ZVA_NUMSC5   	:= oGridZVA:GetValue('ZVA_NUMSC5')
                ZVA->ZVA_NF     	:= oGridZVA:GetValue('ZVA_NF')
                ZVA->ZVA_SERINF     := oGridZVA:GetValue('ZVA_SERINF')
                ZVA->ZVA_USER     	:= oGridZVA:GetValue('ZVA_USER')
                ZVA->ZVA_STATUS     := oGridZVA:GetValue('ZVA_STATUS')

                nTotZB := oGridZVB:GetQtdLine()

                For nX := 1 to nTotZB
                    oGridZVB:GoLine(nX)
                    If !oGridZVB:isDeleted()
                        
                        RecLock('ZVB', lRecLock := !ZVB->(DbSeek( FWxFilial("ZVB") +;
                                                                  oGridZVB:GetValue('ZVB_COD') +;
                                                                  oGridZVB:GetValue('ZVB_ITEMZA') +;
                                                                  oGridZVB:GetValue('ZVB_ITEM'))))
                        
                        ZVB->ZVB_FILIAL    	:= FWxFilial("ZVB")
                        ZVB->ZVB_COD 	   	:= oGridZVB:GetValue('ZVB_COD')
                        ZVB->ZVB_ITEM    	:= oGridZVB:GetValue('ZVB_ITEM')
                        ZVB->ZVB_ITEMZA    	:= oGridZVB:GetValue('ZVB_ITEMZA')
                        ZVB->ZVB_NUMSC5   	:= oGridZVB:GetValue('ZVB_NUMSC5')
                        ZVB->ZVB_LOTE   	:= oGridZVB:GetValue('ZVB_LOTE')
                        ZVB->ZVB_BOV   	    := oGridZVB:GetValue('ZVB_BOV')
                        ZVB->ZVB_QUANT      := oGridZVB:GetValue('ZVB_QUANT')
                        ZVB->ZVB_PRECO      := oGridZVB:GetValue('ZVB_PRECO')
                        ZVB->ZVB_TOTAL      := oGridZVB:GetValue('ZVB_TOTAL')
                    else 
                        If ZVB->(DbSeek( FWxFilial("ZVB") +;
                            oGridZVB:GetValue('ZVB_COD') +;
                            oGridZVB:GetValue('ZVB_ITEMZA') +;
                            oGridZVB:GetValue('ZVB_ITEM')))

                            RecLock('ZVB', .F.)
                                ZVB->(DbDelete())
                            ZVB->(MsUnlock())
                        EndIf
                    Endif
                Next nX

            Else		
                If ZVA->(DbSeek( FWxFilial("ZVA") +;
                        oCab:GetValue('ZVA_COD') +;
                        oGridZVA:GetValue('ZVA_ITEM')))

                    RecLock('ZVA', .F.)
                        ZVA->(DbDelete())
                    ZVA->(MsUnlock())
                EndIf
            EndIf 
        Next nI 
    elseIf nOpc == MODEL_OPERATION_DELETE
		nTotZA := oGridZVA:GetQtdLine()
        For nI := 1 To nTotZA
			oGridZVA:GoLine(nI)
            if !EMPTY(oGridZVA:GetValue("ZVA_STATUS"))
                oModel:SetErrorMessage("","","","","Atenção!", 'Não é permitido excluir registros com STATUS alterado', "") 
                lRet := .F.
                exit 
            else 
                If ZVA->(DBSEEK(  FWxFilial("ZVA") + oCab:GetValue('ZVA_COD') + oGridZVA:GetValue("ZVA_ITEM")))
                    RecLock('ZVA', .F.)
					    ZVA->(DbDelete())
				    ZVA->(MsUnlock())

                    nTotZB := oGridZVB:GetQtdLine()
                    For nX := 1 to nTotZB
                        oGridZVA:GoLine(nX)
                        If ZVB->(DBSEEK(  FWxFilial("ZVB") + oGridZVB:GetValue('ZVB_COD') + oGridZVB:GetValue("ZVB_ITEMZA") + oGridZVB:GetValue("ZVB_ITEM")))
                            RecLock('ZVB', .F.)
					            ZVB->(DbDelete())
				            ZVB->(MsUnlock())
                        Endif 
                    Next nX 
                Endif 

            ENDIF 
		Next nI
    endif 
    ZVB->(DBCLOSEAREA(  ))
    ZVA->(DBCLOSEAREA(  ))

    //Se não for inclusão, volta o INCLUI para .T. (bug ao utilizar a Exclusão, antes da Inclusão)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

    RestArea(aArea)
Return lRet
//LOAD GRID ZVA
Static Function LoadGPrincipal()
	Local aArea		:= GetArea()
	Local aRet 		:= {}
	Local cQry 		:= ''

    cQry := " SELECT *  " + CRLF 
    cQry += " FROM "+RetSqlName("ZVA")+"  " + CRLF 
    cQry += " WHERE ZVA_FILIAL = '"+FwXFilial("ZVA")+"' " + CRLF 
    cQry += " AND ZVA_COD = '"+ZVA->ZVA_COD+"' " + CRLF 
    cQry += " AND D_E_L_E_T_ = '' " + CRLF 
    cQry += " ORDER BY ZVA_ITEM " + CRLF 

    MpSysOpenQuery(cQry,"TMP")
	
    While !TMP->(EOF())
        aAdd(aRet,{Val(TMP->ZVA_ITEM),{     TMP->ZVA_ITEM,;
                                            TMP->ZVA_LOTE,;
                                            TMP->ZVA_QUANT,;
                                            TMP->ZVA_TES,;
                                            TMP->ZVA_NUMSC5,;
                                            TMP->ZVA_NF,;
                                            TMP->ZVA_SERINF,;
                                            TMP->ZVA_USER,;
                                            TMP->ZVA_STATUS}})
        TMP->(DBSKIP())
    End

    if Len(aRet) == 0
        aAdd(aRet,{ 1,{ "",;
                        0,;
                        "",;
                        "",;
                        "",;
                        "",;
                        "",;
                        "",;
                        ""}})
    EndIf
    
    TMP->(DbCloseArea())
    RestArea(aArea)
Return aRet
//LOAD GRID ZVB
Static Function LoadGRodape()
	Local aArea		:= GetArea()
	Local aRet 		:= {}
	Local cQry 		:= ''
    Local cBakItem  := ''

    cQry := " SELECT *  " + CRLF 
    cQry += " FROM "+RetSqlName("ZVB")+" " + CRLF
    cQry += " WHERE ZVB_FILIAL = '"+FwXFilial("ZVA")+"' " + CRLF 
    cQry += " AND ZVB_COD = '"+ZVA->ZVA_COD+"' " + CRLF 
    //cQry += " AND ZVB_ITEMZA = '"+ZVA->ZVA_ITEM+"' " + CRLF
    cQry += " AND D_E_L_E_T_ = '' " + CRLF 
    cQry += " ORDER BY ZVB_ITEMZA, ZVB_ITEM " + CRLF 

    MpSysOpenQuery(cQry,"TMP")
	TMP->(DBGOTOP(  ))
    cBakItem := TMP->ZVB_ITEM
    While !TMP->(EOF())
        
        aAdd(aRet,{Val(TMP->ZVB_ITEM),{     TMP->ZVB_COD,;
                                            TMP->ZVB_ITEM,;
                                            TMP->ZVB_ITEMZA,;
                                            TMP->ZVB_NUMSC5,;
                                            TMP->ZVB_LOTE,;
                                            TMP->ZVB_BOV,;
                                            ALLTRIM(Posicione("SB1",1,FWxFilial("SB1")+TMP->ZVB_BOV,"B1_DESC")),;
                                            TMP->ZVB_QUANT,;
                                            TMP->ZVB_PRECO,;
                                            TMP->ZVB_TOTAL}})
        TMP->(DBSKIP())
    End

    if Len(aRet) == 0
        aAdd(aRet,{ 1,{ "",;
                        "",;
                        "",;
                        "",;
                        "",;
                        "",;
                        "",;
                        0,;
                        0,;
                        0}})
    EndIf
    
    TMP->(DbCloseArea())
    RestArea(aArea)
RETURN aRet

//Gatilho do campo ZVA_LOTE -> ZVA_QTLO
Static Function FI05LT()
    Local oModel    := FWModelActive()
    Local oView     := FWViewActive()
    Local oCab      := oModel:GetModel("ZVAMASTER")
    Local oGridZVA     := oModel:GetModel("ZVADETAIL")
    Local aArea     := GetArea()
    Local cQry      := ''
    Local nI        := 0
    Local nJ        := 0
    Local aBvLote   := {}
    Local cLote     := ''
    Local nSoma     := 0
    Local lRet      := .T. 

    if EMPTY(oGridZVA:GetValue("ZVA_NUMSC5")) .OR. EMPTY(oGridZVA:GetValue("ZVA_NF")) .or. EMPTY(oGridZVA:GetValue("ZVA_SERINF")) 

        if oGridZVA:GetQtdLine() == 1 
            aLotes := {}
        endif

        for nI := 1 to Len(aLotes)
            if oGridZVA:GetValue("ZVA_LOTE") == aLotes[nI][1]
                if aLotes[nI][3] == 0 
                    oModel:SetErrorMessage("","","","","Lote Inválido", 'Quantidade máxima do lote já foi atingida!', "") 
                else
                    For nJ := 1 to Len(aBovs)
                        if aBovs[nJ][1] == oGridZVA:GetValue("ZVA_LOTE")
                            oCab:SetValue("ZVA_QTLO",aBovs[nI][3])
                            oCab:SetValue("ZVA_QTAT",aLotes[nI][3])
                        endif 
                    Next nJ 
                    return lRet
                endif
            endif
        Next nI

        cQry := " SELECT B8_LOTECTL, SUM(B8_SALDO) AS SALDO " + CRLF
        cQry += " FROM "+RetSqlName("SB8")+"  " + CRLF
        cQry += " WHERE B8_PRODUTO LIKE 'BOV%' " + CRLF
        cQry += " and B8_LOTECTL = '"+oGridZVA:GetValue("ZVA_LOTE")+"' " + CRLF
        cQry += " AND B8_SALDO > 0 " + CRLF
        cQry += " AND D_E_L_E_T_ = ' '  " + CRLF
        cQry += " GROUP BY B8_LOTECTL "+ CRLF 
        
        If lower(cUserName) $ 'administrador,admin,ioliveira'
            MemoWrite(StrTran(cArquivo,".xml","")+"SALDO DO LOTE-VAFATI05.sql" , cQry)
        EndIf

        MpSysOpenQuery(cQry,"TMP")
        
        IF !TMP->(EOF())
            //Montar Array dos BOVS 
            cQry := " SELECT B8_LOTECTL, B8_PRODUTO, B8_SALDO " + CRLF
            cQry += " FROM "+RetSqlName("SB8")+"  " + CRLF
            cQry += " WHERE B8_PRODUTO LIKE 'BOV%' " + CRLF
            cQry += " and B8_LOTECTL = '"+oGridZVA:GetValue("ZVA_LOTE")+"' " + CRLF
            cQry += " AND B8_SALDO > 0 " + CRLF
            cQry += " AND D_E_L_E_T_ = ' '  " + CRLF
            cQry += " ORDER BY B8_LOTECTL, B8_SALDO " + CRLF

            If lower(cUserName) $ 'administrador,admin,ioliveira'
                MemoWrite(StrTran(cArquivo,".xml","")+"SALDO POR PRODUTO-VAFATI05.sql" , cQry)
            EndIf

            MpSysOpenQuery(cQry,"TMPBOV")
            
            While !TMPBOV->(EOF())
                cLote := TMPBOV->B8_LOTECTL
                while cLote == TMPBOV->B8_LOTECTL
                
                    aAdd(aBvLote,{TMPBOV->B8_PRODUTO,;
                                    TMPBOV->B8_SALDO})

                    nSoma += TMPBOV->B8_SALDO
                    TMPBOV->(dbSkip())
                enddo 
                        //LOTE //SALDO POR PRODUTO  //SALDO TOTAL DO LOTE          
                aAdd(aLotes,{cLote, aBvLote             ,nSoma})
                aBvLote := {}
            EndDo

            TMPBOV->(DBCLOSEAREA())

            oCab:SetValue("ZVA_QTAT",nSoma)
            oCab:SetValue("ZVA_QTLO",nSoma)
            nSoma := 0
        else 
            oModel:SetErrorMessage("","","","","Lote Inválido", 'Lote não existe ou está sem saldo!', "") 
            lRet := .F. 
        ENDIF
    else 
        oModel:SetErrorMessage("","","","","Pedido Gerado!", 'Não é possivel alterar lote em linhas com pedido gerado.', "") 
        lRet := .F. 
    ENDIF

    TMP->(DBCLOSEAREA())
    oView:Refresh()
    RestArea(aArea)
Return lRet 

//Gatilho do campo ZVA_QUANT -> ZVA_QTAT
Static Function FI05QT()
    Local aArea                     := GetArea()
    Local oModel                    := FWModelActive()
    Local oView                     := FWViewActive()
    Local oCab                      := oModel:GetModel("ZVAMASTER")
    Local oGridZVA                  := oModel:GetModel("ZVADETAIL")
    Local oGridZVB                  := oModel:GetModel("ZVBDETAIL")
    Local nQtDigit                  := oGridZVA:GetValue("ZVA_QUANT")
    Local nI,nJ,nX
    Local nInicial, nFinal, nMeio
    Local nTotBov                   := Len(aLotes)
    Local nTotSep                   := Len(aBovs)
    Local lRet                      := .T. 
    Local lAdd                      := .T.
    Local nQtSoma                   := 0
    Local nPosBLot                  := 1
    Local nPosBItem                 := 1
    Local nPosBov                   := 1
    Local lExist                    := .f. // Valida se Lote e Item ZVA já existe no aBovs
    Local nRedimensionaArray        := 0
    Local nSaldoRestante            := 0 
    Local nPosPreco                 := 0

    oGridZVB:SetNoInsertLine(.F.)
    oGridZVB:SetNoDeleteLine(.F.)
    
    if !EMPTY(oGridZVA:GetValue("ZVA_LOTE"))
        if EMPTY(oGridZVA:GetValue("ZVA_NUMSC5")) .OR. EMPTY(oGridZVA:GetValue("ZVA_NF")) .or. EMPTY(oGridZVA:GetValue("ZVA_SERINF")) 
            //// Valida se Lote e Item ZVA já existe no aBovs
            For nI := 1 To nTotSep
                if oGridZVA:GetValue("ZVA_LOTE") == aBovs[nI][1] 
                    For nJ := 1 to Len(aBovs[nI][2])
                        if oGridZVA:GetValue("ZVA_ITEM") == aBovs[nI][2][nJ][1]
                            nPosBLot  := nI
                            nPosBItem := nJ
                            lExist := .T. 
                            exit
                        Endif
                    Next nJ
                endif
            Next nI

            For nI := 1 To nTotBov
                if oGridZVA:GetValue("ZVA_LOTE") == aLotes[nI][1]
                    nPosBov := nI
                    nSaldoRestante := aLotes[nI][3] 
                    For nX := 1 to nTotSep
                        For nJ := 1 to Len(aBovs[nX][2])
                            if aBovs[nX][2][nJ][1] == oGridZVA:GetValue("ZVA_ITEM")
                                nSaldoRestante := aLotes[nI][3] + aBovs[nX][2][nJ][3]
                                exit 
                            endif 
                        Next nJ
                    Next nX 

                    if nQtDigit > nSaldoRestante
                        oModel:SetErrorMessage("","","","","Quantidade inválida", 'Quantidade digitada maior que o saldo restante do Lote!', "") 
                        return .F.
                    endif
                    exit
                endif
            Next nI

            //SE ALTERAR A QUANTIDADE DIGITADA ANTERIORMENTE, EXCLUI OS BOVS ARMAZENADOS NO ARRAY
            if nTotSep > 0
                if aBovs[nPosBLot][1] == oGridZVA:GetValue("ZVA_LOTE") 
                    IF len(aBovs[nPosBLot][2]) > 0 
                        if aBovs[nPosBLot][2][nPosBItem][1] == oGridZVA:GetValue("ZVA_ITEM")// FAZER VALIDACAO SE O ITEM JA ESTA NO aBovs E EXCLUIR A QUANTIDADE E A LINHA DO ARRAY
                            For nX := 1 to Len(aBovs[nPosBLot][2][nPosBItem][2])
                                //Posiciona Direto no aBov, Posicão [x][x][3][3] é a Posição do Array aBov
                                aLotes[nPosBov][2][aBovs[nPosBLot][2][nPosBItem][2][nX][3]][2] += aBovs[nPosBLot][2][nPosBItem][2][nX][2] // Devolve valor para o vetor aBov, para ser utilizado novamente
                                aLotes[nPosBov][3] += aBovs[nPosBLot][2][nPosBItem][2][nX][2] // Devolve valor para o vetor aBov, adiciona no saldo TOTAL
                            Next nX
                            aDel(aBovs[nPosBLot][2],nPosBItem)
                            aSize(aBovs[nPosBLot][2], Len(aBovs[nPosBLot][2])-1)
                        endif
                    endif
                endif
            endif
            nRedimensionaArray := 0

            //Adiciona Novo Item no Array, Sempre vai adicionar, se é linha nova, irá adicionar uma nova, se é alteração de uma linha, irá apagar a posição do array e criar outra no lugar dela
            lAdd := .T. 
            For nI := 1 to Len(aBovs)
                if aBovs[nI][1] == oGridZVA:GetValue("ZVA_LOTE")
                    lAdd := .F.
                endif
            Next nI

            if lAdd
                aAdd(aBovs,{  oGridZVA:GetValue("ZVA_LOTE"),;
                                {{oGridZVA:GetValue("ZVA_ITEM"),;
                                {},;
                                nQtDigit}},; // Array com os BOVS
                                0}) //Saldo do Lote
            else
                For nI := 1 to Len(aBovs)
                    if aBovs[nI][1] == oGridZVA:GetValue("ZVA_LOTE")

                        aAdd(aBovs[nI][2],{oGridZVA:GetValue("ZVA_ITEM"),; //ITEM DA GRID PRINCIPAL
                                            {},; //Saldo do Lote
                                            nQtDigit}) //QUANTIDADE DIGITADA
                        
                    endif 
                Next nI 
            endif 
            nPosBLot := Len(aBovs)
            nTotSep := Len(aBovs)
            nPosBItem := Len(aBovs[Len(aBovs)][2])

            lAdd := .T. 
            // SE ENCONTRAR ALGUM BOV JÁ COM A QUANTIDADE DIGITADA
            nFinal := Len(aLotes[nPosBov][2])
            nMeio := Round((nFinal / 2),0)
            For nInicial := 1 to nFinal
                if aLotes[nPosBov][2][nInicial][2] == nQtDigit
                    
                    aAdd(aBovs[nPosBLot][2][nPosBItem][2], {aLotes[nPosBov][2][nInicial][1],; // BOV
                                                                        nQtDigit                      ,; // QUANTIDADE
                                                                        nInicial                       }) // Posicão do aLotes
                    
                    aLotes[nPosBov][2][nInicial][2] := aLotes[nPosBov][2][nMeio][2] - nQtDigit
                    aLotes[nPosBov][3] := aLotes[nPosBov][3] - nQtDigit
                    lAdd := .F.
                    exit
                elseif aLotes[nPosBov][2][nMeio][2] == nQtDigit
                    
                    aAdd(aBovs[nPosBLot][2][nPosBItem][2], {aLotes[nPosBov][2][nMeio][1],; // BOV
                                                                        nQtDigit                      ,; // QUANTIDADE
                                                                        nMeio                       }) // Posicão do aLotes
                    
                    aLotes[nPosBov][2][nMeio][2] := aLotes[nPosBov][2][nMeio][2] - nQtDigit
                    aLotes[nPosBov][3] := aLotes[nPosBov][3] - nQtDigit
                    lAdd := .F.
                    exit
                elseif aLotes[nPosBov][2][nFInal][2] == nQtDigit
                    
                    aAdd(aBovs[nPosBLot][2][nPosBItem][2], {aLotes[nPosBov][2][nFInal][1],; // BOV
                                                                        nQtDigit                      ,; // QUANTIDADE
                                                                        nFInal                       }) // Posicão do aLotes
                    
                    aLotes[nPosBov][2][nFInal][2] := aLotes[nPosBov][2][nFInal][2] - nQtDigit
                    aLotes[nPosBov][3] := aLotes[nPosBov][3] - nQtDigit
                    lAdd := .F.
                    exit
                endif 
                
                if (nMeio + 1) == nFinal .and. (nMeio - 1) == nInicial
                    exit
                elseif nMeio == nFinal .or. nMeio == nInicial
                    exit
                endif 

                if nQtDigit > aLotes[nPosBov][2][nMeio][2]
                    nInicial := nMeio
                    nMeio    := Round(nFinal - ((nFinal - nInicial) / 2),0)
                elseif nQtDigit < aLotes[nPosBov][2][nMeio][2]
                    nFinal   := nMeio
                    nMeio    := Round(nFinal - ((nFinal - nInicial) / 2),0)
                endif

                nInicial := nInicial-1
            Next nInicial
            
            IF lAdd // se não encontrou BOV com quantidade igual a digitada, separa bovs para fazer a soma.
                if aLotes[nPosBov][1] == oGridZVA:GetValue("ZVA_LOTE")
                    iif(aBovs[nPosBLot][3]==0,aBovs[nPosBLot][3] := aLotes[nPosBov][3],)
                    
                    For nJ := 1 to Len(aLotes[nPosBov][2])
                        if aLotes[nPosBov][2][nJ][2] != 0
                            if (nQtSoma + aLotes[nPosBov][2][nJ][2]) <= nQtDigit
                                

                                aAdd(aBovs[nPosBLot][2][nPosBItem][2], {aLotes[nPosBov][2][nJ][1]  ,; // BOV
                                                                                    aLotes[nPosBov][2][nJ][2]   ,; // Quantidade
                                                                                    nJ                         })
                                
                                nQtSoma += aLotes[nPosBov][2][nJ][2]
                                
                                aLotes[nPosBov][2][nJ][2] := 0
                            
                            elseif (nQtSoma + aLotes[nPosBov][2][nJ][2]) >= nQtDigit

                                aAdd(aBovs[nPosBLot][2][nPosBItem][2],{ aLotes[nPosBov][2][nJ][1]  ,; // BOV
                                                                                    nQtDigit - nQtSoma         ,; // Quantidade
                                                                                    nJ                         })

                                aLotes[nPosBov][2][nJ][2] := aLotes[nPosBov][2][nJ][2] - (nQtDigit - nQtSoma)
                                
                                nQtSoma += nQtDigit - nQtSoma
                                exit 
                            EndIf
                        EndIf

                    Next nJ
                    aLotes[nPosBov][3] := aLotes[nPosBov][3] - nQtSoma
                endif
            endif

            if !(oGridZVB:IsEmpty())
                oGridZVB:ClearData()
            ENDIF

            for nI := 1 to Len(aLotes)
                if oGridZVA:GetValue("ZVA_LOTE") == aLotes[nPosBov][1]
                    if aBovs[nPosBLot][1] == oGridZVA:GetValue("ZVA_LOTE")
                        oCab:SetValue("ZVA_QTLO",aBovs[nPosBLot][3])
                        oCab:SetValue("ZVA_QTAT",aLotes[nPosBov][3])
                    endif 
                endif
            Next nI

            DBSELECTAREA(("SB1"))
            DBSETORDER(1)

            nTamTot := Len(aBovs[nPosBLot][2][nPosBItem][2])
            For nI := 1 to nTamTot
                    oGridZVB:AddLine()
                    oGridZVB:SetValue("ZVB_COD"   ,oCab:GetValue("ZVA_COD"))
                    oGridZVB:SetValue("ZVB_ITEMZA",aBovs[nPosBLot][2][nPosBItem][1])
                    oGridZVB:SetValue("ZVB_LOTE"  ,aBovs[nPosBLot][1])
                    oGridZVB:SetValue("ZVB_BOV"   ,aBovs[nPosBLot][2][nPosBItem][2][nI][1])
                if  SB1->(DbSeek(xFilial("SA1")+aBovs[nPosBLot][2][nPosBItem][2][nI][1]))
                    oGridZVB:SetValue("ZVB_DESC"  ,ALLTRIM(SB1->B1_DESC) )
                    if (nPosPreco := aScan(aPreco, {|x| Upper(x[1]) == ALLTRIM(SB1->B1_DESC)})) > 0
                        oGridZVB:SetValue("ZVB_PRECO" ,aPreco[nPosPreco][2]) // VER O PREÇO
                    endif
                endif
                    oGridZVB:SetValue("ZVB_QUANT" ,aBovs[nPosBLot][2][nPosBItem][2][nI][2])
                    
                    //oGridZVB:SetValue("ZVB_TOTAL" ,nPreco * aBovs[nPosBLot][2][nPosBItem][2][nI][2])
            Next 

            SB1->(DBCLOSEAREA(  ))
        else 
            oModel:SetErrorMessage("","","","","Pedido Gerado!", 'Não é possivel alterar quantidade em linhas com pedido gerado.', "") 
            lRet := .F.
        Endif
    else 
        oModel:SetErrorMessage("","","","","Campo Lote vazio!", 'Digite o Lote', "") 
        lRet := .F.
    endif 

    oGridZVB:SetNoInsertLine(.T.)
    oGridZVB:SetNoDeleteLine(.T.)

    oView:Refresh()
    nQtSoma := 0
    RestArea(aArea)
Return lRet

User Function FAT05LT()
    Local aArea := GetArea()
    Local cQry  := ''

    cQry := " SELECT B8_LOTECTL, SUM(B8_SALDO) AS SALDO " + CRLF
    cQry += " FROM SB8010  " + CRLF
    cQry += " WHERE B8_PRODUTO LIKE 'BOV%' " + CRLF
    cQry += " AND B8_SALDO > 0 " + CRLF
    cQry += " AND D_E_L_E_T_ = ' '  " + CRLF
    cQry += " GROUP BY B8_LOTECTL  " + CRLF
    cQry += " ORDER BY B8_LOTECTL  " + CRLF

    if F5Qry( cQry, 'VAFATI05', 'Z08RECNO', @uRetorno,, { "Z08_LINHA" } )
        TMP->(DBCLOSEAREA())
    endif

    RestArea(aArea)
Return cRet

Static Function ProcPed()
    Local aArea     := GetArea()
    Local oModel    := FWModelActive()
    Local oView     := FWViewActive()
    Local oCab      := oModel:GetModel("ZVAMASTER")
    Local oGridZVA  := oModel:GetModel("ZVADETAIL")
    Local oGridZVB  := oModel:GetModel("ZVBDETAIL")
    Local lRet      := .T. 
    Local nI,nX

    Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .F.
    
    If MSGYESNO( "Verifique todos os itens antes de gerar os pedidos! Continua?", "Atenção!" )
        
        DBSELECTAREA("SA1")
        DBSETORDER(1)

        if EMPTY(oCab:GetValue("ZVA_CLI")) .or. EMPTY(oCab:GetValue("ZVA_LOJA")) .or. EMPTY(oCab:GetValue("ZVA_COND"))
            alert( "Campos obrigatórios no cabeçalho não foram preenchidos!")
            lRet := .F.
        else
            For nI := 1 to oGridZVA:GetQtdLine()
                oGridZVA:GoLine(nI)
                if !(oGridZVA:isDeleted())
                    if EMPTY(oGridZVA:GetValue("ZVA_TES")) .or. EMPTY(oGridZVA:GetValue("ZVA_LOTE")) .OR. EMPTY(oGridZVA:GetValue("ZVA_QUANT"))
                        alert('Campos obrigatórios na grid principal não foram preenchidos!' + CRLF +;
                            'Lote:           ' + ALLTRIM(oGridZVB:GetValue("ZVB_LOTE")) + CRLF +;
                            'Item principal: ' + ALLTRIM(oGridZVA:GetValue("ZVA_ITEM")) + CRLF )
                        return
                    else 
                        For nX := 1 to oGridZVB:GetQtdLine()
                            oGridZVB:GoLine(nX)
                            if !(oGridZVB:isDeleted())
                                if oGridZVB:GetValue("ZVB_QUANT") == 0 .or. oGridZVB:GetValue("ZVB_PRECO") == 0
                                    alert( 'Campos obrigatórios na grid do rodapé não foram preenchidos!' + CRLF +;
                                            'Lote:           ' + ALLTRIM(oGridZVB:GetValue("ZVB_LOTE")) + CRLF +;
                                            'Item principal: ' + ALLTRIM(oGridZVA:GetValue("ZVA_ITEM")) + CRLF +;
                                            'Item rodapé:    ' + ALLTRIM(oGridZVB:GetValue("ZVB_ITEM")) + CRLF )
                                    return .F.
                                endif 
                            endif
                        Next nX
                    EndIf 
                EndIf 
            Next nI 

            if SA1->(DBSEEK(FWxFilial("SA1")+oCab:GetVAlue("ZVA_CLI")+oCab:GetVAlue("ZVA_LOJA")))
                For nI := 1 to oGridZVA:GetQtdLine()
                    
                    oGridZVA:GoLine(nI)
                    FWMsgRun(, {|| ExecSC5Auto(oModel,oCab,oGridZVA,oGridZVB) },'Por Favor Aguarde...' , 'Gerando pedido linha: '+ oGridZVA:GetVALue("ZVA_ITEM"))
                    
                Next nI
            else 
                oModel:SetErrorMessage("","","","","Formulário inválido", 'Cliente não encontrado!', "") 
                lRet := .F.
            Endif
        endif

        SA1->(DBCLOSEAREA())
    endif

    If lower(cUserName) $ 'ioliveira,atoshio,admin, administrador'
        Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
    EndIf

    oView:Refresh()
    RestArea(aArea)
Return lRet

Static Function ExecSC5Auto(oModel,oCab,oGridZVA,oGridZVB)
    Local nX,nCount
    Local aCabC5    := {}
    Local aCabC6    := {}
    Local aErroAuto := {}
    
    aCabC5 := {}
    aCabC6 := {}
    if !(oGridZVA:isDeleted())

        cNumPed := U_fChvITEM( "SC5", , "C5_NUM" )
        
        aCabC5 := {{"C5_NUM"    , cNumPed                      , Nil},;
                    {"C5_TIPO"   , "N"         		           , Nil},;
                    {"C5_CLIENTE", SA1->A1_COD	               , Nil},;
                    {"C5_LOJACLI", SA1->A1_LOJA	               , Nil},;
                    {"C5_LOJAENT", SA1->A1_LOJA	               , Nil},;
                    {"C5_TIPOCLI", SA1->A1_TIPO	               , Nil},;
                    {"C5_MENPAD" , oCab:GetValue("ZVA_MENPAD") , Nil},;
                    {"C5_MENNOTA", oCab:GetValue("ZVA_MENNT")  , Nil},;
                    {"C5_NATUREZ", SA1->A1_NATUREZ	           , Nil},;
                    {"C5_TPFRETE", oCab:GetValue("ZVA_FRET")   , Nil}}
        
        For nX := 1 to oGridZVB:GetQtdLine()
            oGridZVB:GoLine(nX)
            if !(oGridZVB:isDeleted())
                aAdd(aCabC6,{{"C6_NUM"    	    , cNumPed                    													, Nil},;
                                {"C6_ITEM"   	, StrZero(nX,2)							          								, Nil},;
                                {"C6_PRODUTO"	, oGridZVB:GetValue("ZVB_BOV")        										 	, Nil},;
                                {"C6_LOTECTL"	, oGridZVB:GetValue("ZVB_LOTE")        										 	, Nil},;
                                {"C6_QTDVEN" 	, oGridZVB:GetValue("ZVB_QUANT")         										, Nil},;
                                {"C6_UM" 	    , Posicione("SB1",1,FWxFilial("SB1") + oGridZVB:GetValue("ZVB_BOV"), "B1_UM")  	, Nil},;
                                {"C6_PRCVEN" 	, oGridZVB:GetValue("ZVB_PRECO")        										, Nil},;
                                {"C6_VALOR"  	, oGridZVB:GetValue("ZVB_TOTAL")												, Nil},;
                                {"C6_TES"    	, oGridZVA:GetValue("ZVA_TES")												 	, Nil}})
            endif
        Next nX

        lMsErroAuto := .F.
        while !LockByName("ProcPedAuto"+ cNumPed, .t., .f.)
            Sleep(500)
        end
            MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabC5,aCabC6,3)
        UnlockByName("ProcPedAuto"+cNumPed)

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
                CONOUT( "Pedido de Venda [" + cNumPed + "] gerado com sucesso !!!" + CRLF +;
                "Nota Fiscal [" + SF2->F2_FILIAL+"-"+ AllTrim(SF2->F2_DOC)+"-"+AllTrim(SF2->F2_SERIE) + "] faturada com sucesso" )

                oGridZVA:SetValue('ZVA_NUMSC5'  , StrZero(Val(cPedVen),TamSX3('ZVA_NUMSC5')[1]))
                oGridZVA:SetValue('ZVA_NF'	    , SF2->F2_DOC)
                oGridZVA:SetValue('ZVA_SERINF'  , SF2->F2_SERIE)
                oGridZVA:SetValue('ZVA_STATUS'  , "F")

                if ( lRet := oModel:VldData() )

                    RecLock('ZVA', lRecLock := !ZVA->(DbSeek( FWxFilial("ZVA") +;
                                                          oCab:GetValue('ZVA_COD') +;
                                                          oGridZVA:GetValue('ZVA_ITEM'))))

                    ZVA->ZVA_FILIAL    	:= FWxFilial("ZVA")
                    ZVA->ZVA_COD 	   	:= oCab:GetValue('ZVA_COD')
                    ZVA->ZVA_CLI    	:= oCab:GetValue('ZVA_CLI')
                    ZVA->ZVA_LOJA    	:= oCab:GetValue('ZVA_LOJA')
                    ZVA->ZVA_COND   	:= oCab:GetValue('ZVA_COND')
                    ZVA->ZVA_DTEMIS     := oCab:GetValue('ZVA_DTEMIS')
                    ZVA->ZVA_FRET       := oCab:GetValue('ZVA_FRET')
                    ZVA->ZVA_ITEM    	:= oGridZVA:GetValue('ZVA_ITEM')
                    ZVA->ZVA_LOTE   	:= oGridZVA:GetValue('ZVA_LOTE')
                    ZVA->ZVA_QUANT      := oGridZVA:GetValue('ZVA_QUANT')
                    ZVA->ZVA_TES   	    := oGridZVA:GetValue('ZVA_TES')
                    ZVA->ZVA_NUMSC5   	:= oGridZVA:GetValue('ZVA_NUMSC5')
                    ZVA->ZVA_NF     	:= oGridZVA:GetValue('ZVA_NF')
                    ZVA->ZVA_SERINF     := oGridZVA:GetValue('ZVA_SERINF')
                    ZVA->ZVA_USER     	:= oGridZVA:GetValue('ZVA_USER')
                    ZVA->ZVA_STATUS     := oGridZVA:GetValue('ZVA_STATUS')

                    For nX := 1 to  oGridZVB:GetQtdLine()
                        oGridZVB:GoLine(nX)
                        If !oGridZVB:isDeleted()
                            
                            oGridZVB:SetValue("ZVB_NUMSC5", StrZero(Val(cPedVen),TamSX3('ZVA_NUMSC5')[1]))

                            RecLock('ZVB', lRecLock := !ZVB->(DbSeek( FWxFilial("ZVB") +;
                                                                    oGridZVB:GetValue('ZVB_COD') +;
                                                                    oGridZVB:GetValue('ZVB_ITEMZA') +;
                                                                    oGridZVB:GetValue('ZVB_ITEM'))))
                            
                            ZVB->ZVB_FILIAL    	:= FWxFilial("ZVB")
                            ZVB->ZVB_COD 	   	:= oGridZVB:GetValue('ZVB_COD')
                            ZVB->ZVB_ITEM    	:= oGridZVB:GetValue('ZVB_ITEM')
                            ZVB->ZVB_ITEMZA    	:= oGridZVB:GetValue('ZVB_ITEMZA')
                            ZVB->ZVB_NUMSC5   	:= oGridZVB:GetValue('ZVB_NUMSC5')
                            ZVB->ZVB_LOTE   	:= oGridZVB:GetValue('ZVB_LOTE')
                            ZVB->ZVB_BOV   	    := oGridZVB:GetValue('ZVB_BOV')
                            ZVB->ZVB_QUANT      := oGridZVB:GetValue('ZVB_QUANT')
                            ZVB->ZVB_PRECO      := oGridZVB:GetValue('ZVB_PRECO')
                            ZVB->ZVB_TOTAL      := oGridZVB:GetValue('ZVB_TOTAL')
                        endif 
                    Next nX 

                Endif 
            EndIf
        EndIf
    endif 
Return 

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
		Alert('[VAFATI05] Pedido: '+ SC5->C5_NUM + ' ja esta faturado na nota: ' + SC5->C5_FILIAL + '/' + SC5->C5_NOTA + '/' + SC5->C5_SERIE )
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
