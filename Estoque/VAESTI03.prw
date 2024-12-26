/* 
	MV_TMNASC PARAMETRO CRIADO PARA TM DE NASCIMENTO
*/
#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "parmtype.ch"
#include "fwmvcdef.ch"
#INCLUDE "TOTVS.CH"

Static cTitulo := "Manejo Sanitario" 

/* Igor Gomes 05/2022 */

User Function VAESTI03()
    Local aArea   		:= GetArea()
    Local oModel  		:= NIL
	Local cFunBkp 		:= FunName()  
	Private cArquivo    := "C:\TOTVS_RELATORIOS\"
	Private _cFunc 		:= CriaVar('ZMS_RESPON'	, .F.)
    Private _cLoteT		:= CriaVar('ZMS_LOTE'  	, .F.)
    Private _cProdT		:= CriaVar('ZMS_PRDBOV' , .F.)
    Private _cCurralT	:= CriaVar('ZMS_CURRAL' , .F.)
    Private _cLocalT	:= CriaVar('ZMS_LOCAL'  , .F.)
    Private _cRacaT		:= CriaVar('ZMS_RACA'  	, .F.)
    Private _cSexoT		:= CriaVar('ZMS_SEXO'  	, .F.)
    Private _cDescT		:= CriaVar('ZMS_DESC'  	, .F.)

    Private _cLoteS		:= CriaVar('ZMS_LOTE'  	, .F.)
    Private _cProd		:= CriaVar('ZMS_PRDBOV' , .F.) 
    Private _cCurral	:= CriaVar('ZMS_CURRAL' , .F.)
    Private _cLocal		:= CriaVar('ZMS_LOCAL'  , .F.)
    Private _cRaca		:= CriaVar('ZMS_RACA'  	, .F.)
    Private _cSexo		:= CriaVar('ZMS_SEXO'  	, .F.)
    Private _cDesc		:= CriaVar('ZMS_DESC'  	, .F.)
	Private dDtVLote    := CriaVar('B8_DTVALID' , .F.)
	Private _cTipo      := CriaVar('ZMS_TIPO' , .F.)
	Private cPath       := "C:\TOTVS_RELATORIOS\"
	Private __cRet
	Private _Copia 		:= .F.

	SetFunName("VAESTI03")
	
    oModel := FWMBrowse():New()
	oModel:SetAlias( "ZMS" )
	oModel:SetDescription( cTitulo )
	oModel:Activate()
	
    SetFunName(cFunBkp)
	RestArea(aArea)
Return NIL  

Static Function MenuDef()
	Local aRot := {}
	
	ADD OPTION aRot TITLE 'Visualizar' 		ACTION 'VIEWDEF.VAESTI03' 			OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    		ACTION 'VIEWDEF.VAESTI03' 			OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    		ACTION 'VIEWDEF.VAESTI03' 			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    		ACTION 'VIEWDEF.VAESTI03' 			OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStPai   	:= FWFormStruct(1, 'ZMS') 
	Local oStFilho 	:= FWFormStruct(1, 'ZMS')
	Local bVldPos  	:= {|| u_I03GPRE()    }
	Local bVldCom  	:= {|| u_zSaveZMSMd2()}
	Local bVldPre 	:= {|| u_LockUnlock() }	
	Local aZMSRel  	:= {}

	//Criando o FormModel, adicionando o CabeÃ§alho e Grid
	oModel := MPFormModel():New("ESTI03M",bVldPre, bVldPos /*Pos-Validacao*/, bVldCom /*Commit*/,/*Cancel*/)

	oModel:AddFields("ZMSMASTER",/*cOwner*/ ,oStPai  )

	//oModel:AddGrid('ZMSDETAIL','ZMSMASTER',oStFilho/* , bZMSLinePr */)
	oModel:AddGrid('ZMSDETAIL','ZMSMASTER',oStFilho, { |oGridM, nLine,cAction, cField| I03GPRE(oGridM, nLine, cAction, cField) })

	oStFilho:AddField('Gerar', ' ', 'Gerar', 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, ".F."))

	//Adiciona o relacionamento de Filho, Pai
	aAdd(aZMSRel, {'ZMS_FILIAL', 'Iif(!INCLUI, ZMS->ZMS_FILIAL, FWxFilial("ZMS"))'} )
	aAdd(aZMSRel, {'ZMS_COD'   , 'Iif(!INCLUI, ZMS->ZMS_COD   , "")'} )
	aAdd(aZMSRel, {'ZMS_RESPON', 'Iif(!INCLUI, ZMS->ZMS_RESPON   , "")'} )
	aAdd(aZMSRel, {'ZMS_DATA'  , 'Iif(!INCLUI, ZMS->ZMS_DATA  , sToD(""))'} )

	/* Não copiar campos a seguir */
	oModel:GetModel("ZMSMASTER"):SetFldNoCopy({'ZMS_FILIAL'	, 'ZMS_COD', 'ZMS_DATA'})

	//Criando o relacionamento */
	oModel:SetRelation('ZMSDETAIL', aZMSRel, ZMS->(IndexKey(2)))

	oModel:SetPrimaryKey({ })

	//Setando o campo Ãºnico da grid para nÃ£o ter repetiÃ§Ã£o
	oModel:GetModel('ZMSDETAIL'):SetUniqueLine({ "ZMS_FILIAL","ZMS_COD", "ZMS_ITEM" })

	//Setando outras informaÃ§Ãµes do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZMSMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAESTI03")
	Local oStPai     	:= FWFormStruct(2, 'ZMS') 
	Local oStFilho   	:= FWFormStruct(2, 'ZMS')
	Local oView      	:= FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB" , oStPai  , "ZMSMASTER")
	oView:AddGrid('VIEW_ITENS', oStFilho, 'ZMSDETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 50)
	oView:CreateHorizontalBox('GRID' , 50)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB'  ,'CABEC')
	oView:SetOwnerView('VIEW_ITENS','GRID' )

	//Habilitando tÃ­tulo
	oView:EnableTitleView('VIEW_CAB',"Cabeçalho - "+cTitulo+"")
	oView:EnableTitleView('VIEW_ITENS',"Itens - "+cTitulo+"")

	//Auto incremento para o campo ZMS_ITEM
	oView:AddIncrementField( 'VIEW_ITENS', 'ZMS_ITEM' )

	//Tratativa padrÃ£o para fechar a tela
	oView:SetCloseOnOk( { |oView| .F. } )
	
	oView:AddUserButton( 'Cadastrar Motivo','', {|oView| U_VAESTI04()} )

	oView:AddUserButton( 'Cadastrar Morte','', {|oView| Morte()} )
	
	oView:AddUserButton( 'Cadastrar Nascimento','', {|oView| Nascimento()} )

	oView:AddUserButton( 'Estorno','', {|oView| Estorno()} )

	//Remove os campos de Filial e Tabela da Grid
	oStPai:RemoveField('ZMS_LOTE')
	oStPai:RemoveField('ZMS_PRDBOV')
	oStPai:RemoveField('ZMS_DESC')
	oStPai:RemoveField('ZMS_RACA')
	oStPai:RemoveField('ZMS_SEXO')
	oStPai:RemoveField('ZMS_DMED')
	oStPai:RemoveField('ZMS_MEDIC')
	oStPai:RemoveField('ZMS_DOSE')
	oStPai:RemoveField('ZMS_ITEM')
	oStPai:RemoveField('ZMS_CURRAL')
	oStPai:RemoveField('ZMS_D3DOC')
	oStPai:RemoveField('ZMS_D3REC')
	oStPai:RemoveField('ZMS_LOCAL')
	oStPai:RemoveField('ZMS_QTDE')

    oStFilho:RemoveField('ZMS_FILIAL')

	oStFilho:RemoveField('ZMS_D3EST')
	oStFilho:RemoveField('ZMS_TIPO')
    oStFilho:RemoveField('ZMS_COD')
    oStFilho:RemoveField('ZMS_DATA')
    oStFilho:RemoveField('ZMS_RESPON')
    oStFilho:RemoveField('ZMS_NOME')
    oStFilho:RemoveField('ZMS_MOTIVO')
    oStFilho:RemoveField('ZMS_DMOT')
    oStFilho:RemoveField('ZMS_OBS')

Return oView

User Function ESTI03M()
	Local aParam 		:= PARAMIXB
	Local xRet 			:= .T.
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local cIdIXB5		:= ''
	Local cIdIXB4		:= ''
	Local oModel 	 	:= nil
	Local oCab			:= nil
	Local oGridM 		:= nil
	Local aSaveLines 	:= FWSaveRows()
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

		if Alltrim(cIdPonto) == "FORMPRE" .and. cIdModel == 'ZMSDETAIL' .AND. cIdIXB5 == 'CANSETVALUE' .AND. AllTrim(cIdIXB4) == 'ZMS_QTDE'
			oModel 	 	:= FwModelActivate()
			oGridM 		:= oModel:GetModel("ZMSDETAIL")
/* 			if oGridM:GetValue("ZMS_TIPO") == 'P'  .and. &(ReadVar()) > 1
				oModel:SetErrorMessage("","","","","HELP", 'Quantidade não pode ser maior que 1 no Tipo [P] (Problema)', "Insira outra linha para informar outro medicamento")
				xRet := .f.
			endif */
		elseif Alltrim(cIdPonto) == 'FORMPRE' .AND. cIdModel == 'ZMSDETAIL' .AND. cIdIXB5 == 'ISENABLE'
			oModel 	 	:= FwModelActivate()
			oGridM 		:= oModel:GetModel("ZMSDETAIL")
			oCab 		:= oModel:GetModel("ZMSMASTER")

			if oModel:GetOperation() == 4
				if oGridM:GetValue("ZMS_D3EST") == 'N'
					for nI := 1 to oGridM:GetQtdLine()
						oGridM:GoLine(nI)
						if !Empty(oGridM:GetValue("ZMS_D3DOC"))
							oGridM:SetNoInsertLine(.T.)
							exit
						endif
					next
				endif
			endif
		endif
	endif 
	FWRestRows( aSaveLines )
Return xRet

User Function I03vldQT()
	Local xRet 		:= .T.
	Local oModel 	:= FwModelActivate()
	Local oCab 		:= oModel:GetModel("ZMSMASTER")
	Local oGridM 	:= oModel:GetModel("ZMSDETAIL")
	Local nSaldo	:= 0

/* 	if oCab:GetValue("ZMS_TIPO") $ 'P' .and. &(ReadVar()) > 1
		oModel:SetErrorMessage("","","","","HELP", 'Quantidade não pode ser maior 1 no Tipo [P]', "Verifique o tipo ou informe 1")
		xRet := .F. */
	if oCab:GetValue("ZMS_TIPO") $ 'M|A|P|' .and. &(ReadVar()) > 1
		nSaldo := Posicione("SB8",3,fwXFilial("SB8")+;
									oGridM:GetValue("ZMS_PRDBOV")+;
									oGridM:GetValue("ZMS_LOCAL")+;
									oGridM:GetValue("ZMS_LOTE")+;
									Space(TamSX3('B8_NUMLOTE')[1] )+;
									dToS(dDtVLote),;
									"B8_SALDO")
		if &(ReadVar()) > nSaldo 
			oModel:SetErrorMessage("","","","","HELP", 'Quantidade não pode ser maior que saldo do produto', "Verifique o lote e produto!")
			xRet := .f.
		endif
	endif

return xRet

User Function I03GPRE()
	Local aArea     := GetArea()
	local oView     := FWViewActive()
	Local oModel    := FWModelActive()
	Local nOpc      := oModel:GetOperation()
	Local lRet      := .T.
	Local nLL		:= VldLinsLT()
	Local nI        := 0
	Local oGridM 	:= oModel:GetModel("ZMSDETAIL")
	
	If nOpc == MODEL_OPERATION_INSERT
		if nLL == 0
			if Empty(oModel:GetValue("ZMSMASTER", "ZMS_COD"))
				oModel:LoadValue("ZMSMASTER", "ZMS_COD", VaGetX8('ZMS', 'ZMS_COD'))
			ENDIF
			
			DbSelectArea('ZMS')
			ZMS->(DbSetOrder(1)) //ZDM_FILIAL + ZDM_CODIGO + ZDM_CODIGO
			
			if oModel:GetValue('ZMSDETAIL', 'ZMS_TIPO') == 'P'
				If ZMS->(DbSeek( fwXFilial("ZMS") +;
						oModel:GetValue('ZMSMASTER', 'ZMS_COD')))
						oModel:SetErrorMessage("","","","","HELP", 'Esse código de tabela já existe!','')
					lRet := .F.
				EndIf
			EndIf
		else 
			lRet := .F.
			oModel:SetErrorMessage("","","","","HELP", 'Lote Vazio!', "Informe o Lote em todas as linhas!!" + CRLF ,;
				"Total de " + cValToChar(NLL) + " Linhas sem preencher")
		ENDIF
	elseif nOpc == MODEL_OPERATION_DELETE 
		
		If FwFldGet("ZMS_D3EST") == "S" 
			Help( ,, "HELP","ESTI03Pos", "Não é permitida exclusão de uma movimentação realizada.", 1, 0)
			lRet := .F.
		else
			for nI := 1 to oGridM:GetQtdLine()
				oGridM:GoLIne(nI)
				if !oGridM:isDeleted()
					if !Empty(oGridM:GetValue("ZMS_D3DOC"))
						Help( ,, "HELP","ESTI03Pos", "Não é permitida exclusão de uma movimentação já realizada.", 1, 0)
						
						lRet := .f.
					endif 
				endif 
			next
		EndIf 
	EndIf

	If Empty(oModel:GetValue("ZMSMASTER","ZMS_DATA"))
		oModel:SetValue("ZMSMASTER","ZMS_DATA", dDataBase)
	EndIf
	RestArea(aArea)

    oView:Refresh()

Return lRet

User Function LockUnlock()
	Local oModel	  	:= FWModelActive()
	Local oGridM 		:= oModel:GetModel("ZMSDETAIL")
	Local lRet 			:= .T. 
	Local nOperation 	:= oModel:GetOperation() 
	Local nI         	:= 0
	
	If nOperation == MODEL_OPERATION_UPDATE 
		If FwFldGet("ZMS_D3EST") == "S" 
			Help( ,, "HELP","ESTI03Pos", "Não é permitida alteração de uma movimentação já realizada.", 1, 0)
			lRet := .F.
		else 
			for nI := 1 to oGridM:GetQtdLine()
				oGridM:GoLIne(nI)
				if !oGridM:isDeleted()
					if !Empty(oGridM:GetValue("ZMS_D3DOC"))
						Help( ,, "HELP","ESTI03Pos", "Não é permitida alteração de uma movimentação já realizada.", 1, 0)
						lRet := .f.
					endif 
				endif 
			next
		endif 
	endif

RETURN lRet

Static Function VldLinsLT() 
	Local oModel  	 	:= FWModelActive()
	Local oGridM 		:= oModel:GetModel('ZMSDETAIL')
	Local nLinhas 	 	:= oGridM:GetQtdLine()
	Local nRet 			:= 0
	Local nI
	
	for nI := 1 to nLinhas 
		oGridM:GoLine(nI)
		if Empty(oGridM:GetValue("ZMS_LOTE"))
			nRet++
		ENDIF
	NEXT

return nRet

User Function zSaveZMSMd2()
	Local aArea      	:= GetArea()
	Local lRet       	:= .T.
	Local oModel	  	:= FWModelActive()
	Local oCab 			:= oModel:GetModel('ZMSMASTER')
	Local oGridM 		:= oModel:GetModel('ZMSDETAIL')
	Local nOpc       	:= oModel:GetOperation()
	Local nI         	:= 0
	Local lRecLock   	:= .T.
	Local nLinhas	 	:= oGridM:GetQtdLine()

	DbSelectArea('ZMS')
	ZMS->(DbSetOrder(3))
	
	for nI := 1 to nLinhas
		oGridM:GoLIne(nI)
		if !oGridM:isDeleted()
			if oGridM:GetValue("ZMS_QTDE") == 0
				oModel:SetErrorMessage("","","","","HELP", 'Linha ' + cValToChar(nI) + ' com quantidade zerada', "Verifique a Quantidade ou Apague a linha")
				Return .F.
			endif
		endif
	next

	//Se for InclusÃ£o
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE

		if !Empty(oCab:GetValue("ZMS_DATA"))
			dData := oCab:GetValue("ZMS_DATA")
		else
			dData := dDataBase
		ENDIF
		
		if Empty(oModel:GetValue("ZMSMASTER", "ZMS_COD"))
			oModel:LoadValue("ZMSMASTER", "ZMS_COD", VaGetX8('ZMS', 'ZMS_COD'))
		ENDIF

		//Cria o registro na tabela 00 (CabeÃ§alho de tabelas)
		if !Empty(oCab:GetValue("ZMS_TIPO"))

            For nI := 1 To nLinhas
                oGridM:GoLine(nI)
                If !oGridM:isDeleted()
                    RecLock('ZMS', lRecLock := !DbSeek( fwXFilial("ZMS") +;
                                                oCab:GetValue('ZMS_COD') +;
                                                dToS(oCab:GetValue('ZMS_DATA'))+;
                                                oGridM:GetValue('ZMS_ITEM')))

                        ZMS->ZMS_FILIAL    	:= fwXFilial("ZMS")
                        ZMS->ZMS_COD 	   	:= oCab:GetValue('ZMS_COD') 
                        ZMS->ZMS_DATA   	:= dData
                        ZMS->ZMS_TIPO      	:= oCab:GetValue('ZMS_TIPO')
                        ZMS->ZMS_MOTIVO    	:= oCab:GetValue('ZMS_MOTIVO')
                        ZMS->ZMS_RESPON    	:= oCab:GetValue('ZMS_RESPON')
                        ZMS->ZMS_OBS       	:= oCab:GetValue('ZMS_OBS' )
                        ZMS->ZMS_D3EST      := oCab:GetValue('ZMS_D3EST' )
                        ZMS->ZMS_ITEM   	:= oGridM:GetValue('ZMS_ITEM')
                        ZMS->ZMS_LOTE     	:= oGridM:GetValue('ZMS_LOTE')
                        ZMS->ZMS_CURRAL   	:= oGridM:GetValue('ZMS_CURRAL') 
                        ZMS->ZMS_LOCAL   	:= oGridM:GetValue('ZMS_LOCAL') 
                        ZMS->ZMS_PRDBOV   	:= oGridM:GetValue('ZMS_PRDBOV') 
                        ZMS->ZMS_RACA     	:= oGridM:GetValue('ZMS_RACA')
                        ZMS->ZMS_SEXO     	:= oGridM:GetValue('ZMS_SEXO')
                        ZMS->ZMS_DESC     	:= oGridM:GetValue('ZMS_DESC')
                        ZMS->ZMS_MEDIC     	:= oGridM:GetValue('ZMS_MEDIC')
                        ZMS->ZMS_DOSE      	:= oGridM:GetValue('ZMS_DOSE')
                        ZMS->ZMS_D3DOC     	:= oGridM:GetValue('ZMS_D3DOC')
                        ZMS->ZMS_D3REC     	:= oGridM:GetValue('ZMS_D3REC')
                        ZMS->ZMS_QTDE      	:= oGridM:GetValue('ZMS_QTDE')

                    ZMS->(MsUnlock())
                Else		
                    If ZMS->(DbSeek( fwXFilial("ZMS") +;
                            oCab:GetValue('ZMS_COD') +;
                            dToS(oCab:GetValue('ZMS_DATA'))+;
                            oGridM:GetValue('ZMS_ITEM')))

                        RecLock('ZMS', .F.)
                            ZMS->(DbDelete())
                        ZMS->(MsUnlock())
                    EndIf 
                EndIf
            Next nI
		else 
			lRet := .F. 
			oModel:SetErrorMessage("","","","","HELP", 'CAMPO TIPO VAZIO', "Informe o Tipo!")
		ENDIF 
	//Se for ExclusÃ£o
	ElseIf nOpc == MODEL_OPERATION_DELETE
		IF oCab:GetValue("ZMS_D3EST") == 'S'
			MsgAlert("Registro com estorno realizado, não é permitido a exclusão!", "Atenção")
			lRet  := .F.
		endif 
		For nI := 1 To oGridM:GetQtdLine()
			oGridM:GoLine(nI)
			IF AllTrim(oGridM:GetValue('ZMS_D3DOC')) != ""

                MsgAlert("Registro com movimentações realizadas, não é permitido a exclusão!", "Atenção!!!")
				lRet  := .F.
				exit

			ENDIF 
		next
		if lRet
			For nI := 1 To oGridM:GetQtdLine()
				oGridM:GoLine(nI)

				//Se conseguir posicionar, exclui o regist
				If ZMS->(DbSeek( fwXFilial("ZMS") +;
							oCab:GetValue('ZMS_COD') +;
        	                dToS(oCab:GetValue('ZMS_DATA'))+;
							oGridM:GetValue('ZMS_ITEM')))

					RecLock('ZMS', .F.)
						ZMS->(DbDelete())
					ZMS->(MsUnlock())
				EndIf
			Next nI
		EndIf
	EndIf

	//Se nÃ£o for inclusÃ£o, volta o INCLUI para .T. (bug ao utilizar a ExclusÃ£o, antes da InclusÃ£o)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

	RestArea(aArea)
Return lRet

Static Function I03GPRE(oGridM, nLinha, cAcao, cCampo)
	Local lRet	 	:= .T.

  	If cAcao == 'DELETE' 
  	  if !Empty(oGridM:GetValue("ZMS_D3DOC"))
			lRet := .F.
			Help( ,, 'Help',, 'Não permitido apagar linhas com Movimentações geradas.' + CRLF +; 
					'Você esta na linha ' + Alltrim( Str( nLinha ) ) )
		ENDIF
  	EndIf

Return lRet

User Function FunEst4()
    Local aArea			:= GetArea()
	Local oDlg, oLbx
    Local aCpos  		:= {}
    Local aRet   		:= {}
    Local _cQry  		:= ""
    Local cAlias 		:= GetNextAlias()
    Local lRet   		:= .F.
	Local oView		 	:= FWViewActive()
	Local oCab  	:= FWModelActive()
	Local oGridM 	:= oCab:GetModel('ZMSDETAIL') 

	_cQry := "  SELECT RA_MAT" + CRLF
	_cQry += "   	 ,RA_NOME" + CRLF
	_cQry += "  FROM "+RetSqlName("SRA")+" " + CRLF
	_cQry += "  JOIN "+RetSqlName("SQB")+" SQB ON RA_DEPTO = QB_DEPTO" + CRLF
	_cQry += "  AND RA_DEPTO = '000000004'" + CRLF
	_cQry += "  WHERE RA_DEMISSA = ''" + CRLF
	_cQry += "  AND RA_FILIAL = '"+FWxFilial("SRA")+"'" + CRLF
	_cQry += "  ORDER BY 2" + CRLF

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAlias,.T.,.T.)

	While !(cAlias)->(EOF())
        aAdd(aCpos,{(cAlias)->RA_MAT,;
				    (cAlias)->RA_NOME})
        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())

	If Len(aCpos) < 1
        aAdd(aCpos,{" "," "})
    EndIf

	DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Funcionarios" FROM 0,0 TO 325,1000 PIXEL

	@ 0,0 LISTBOX oLbx FIELDS HEADER 'Matricula.',;
									 'Nome' SIZE 500,150 OF oDlg PIXEL

	oLbx:SetArray( aCpos )
    oLbx:bLine     := {|| { aCpos[oLbx:nAt,1],;
                            aCpos[oLbx:nAt,2]}}

	oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],;
                            oLbx:aArray[oLbx:nAt,2]}}}
	DEFINE SBUTTON FROM 150,474 TYPE 1 ACTION (oDlg:End(), lRet:=.T.,;
        aRet := {oLbx:aArray[oLbx:nAt,1],;
                 oLbx:aArray[oLbx:nAt,2]}) ENABLE OF oDlg
    ACTIVATE MSDIALOG oDlg CENTER

	If Len(aRet) > 0 .And. lRet
		 _cFunc := aRet[1]
		oGridM:LoadValue("ZMS_NOME",   aRet[2])
		lRet := .T.
    EndIf

	IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
	    MemoWrite(StrTran(cArquivo,".xml","")+"SR4_"+cValToChar(dDataBase)+".sql" , _cQry)
    ENDIF

	oView:Refresh()
	RestArea(aArea)

RETURN lRet

User Function BovEstI4()
	Local oView 		:= FWViewActive()
    Local aArea			:= GetArea()
	Local aAreaSB1 		:= SB1->(GetArea())
    Local _cQry  		:= ""
    Local lRet   		:= .T.
	Local oModel 		:= FwModelActivate()
	Local oCab 			:= oModel:GetModel("ZMSMASTER")
	Local oGridM 		:= oModel:GetModel('ZMSDETAIL')
	Local cCampo 		:= ''
	Local cConsulta 	:= ''
	Local cCodCon		:= ''
	Local nLine 		:= oGridM:GetLine()
	Local nI 
	Local QryOpc		

	if Type("uRetorno") == 'U' 
		public uRetorno
	endif

	uRetorno := ''
	if oCab:GetValue("ZMS_TIPO") == Space(TamSx3("ZMS_TIPO")[1])
		MsgAlert("Informe o Campo [ Tipo ]", "Atenção!!")
		lRet := .F. 
	else 	
		if Empty(oGridM:GetValue("ZMS_D3DOC"))
			cCampo := ReadVar()

			if cCampo == 'M->ZMS_LOTE'
				IF oCab:GetValue("ZMS_TIPO") == 'N'
					_cQry := "  select B8_LOTECTL " + CRLF
					_cQry += " 					, B8_X_CURRA " + CRLF
					_cQry += " 					, B8_LOCAL " + CRLF
					_cQry += " 					, SB8.R_E_C_N_O_ SB8RECNO " + CRLF
					_cQry += " 	from " +RetSqlName("SB8") + " SB8 " + CRLF
					_cQry += " 	where B8_FILIAL = '" +FwXFilial("SB8") + "'" + CRLF
					_cQry += " 	AND B8_SALDO > 0  " + CRLF
					_cQry += " 	and B8_X_CURRA != ''  " + CRLF
					_cQry += " 	and SB8.D_E_L_E_T_ = '' " + CRLF

					QryOpc := 1

					cCodCon 	:= 'LOTE'
					cConsulta 	:= 'B8_X_CURRA'
				ELSE 
					_cQry := " select B8_PRODUTO " + CRLF
					_cQry += " 				 , B8_LOTECTL " + CRLF
					_cQry += " 				 , B8_X_CURRA " + CRLF
					_cQry += " 				 , B8_LOCAL " + CRLF
					_cQry += " 				 , B1_DESC " + CRLF
					_cQry += " 				 , B1_XRACA " + CRLF
					_cQry += " 				 , B1_X_SEXO " + CRLF
					_cQry += " 				 , B8_SALDO " + CRLF
					_cQry += " 				 , B8_DTVALID " + CRLF
					_cQry += " 				 , SB8.R_E_C_N_O_ SB8RECNO " + CRLF
					_cQry += " 			from " +RetSqlName("SB8") + " SB8 " + CRLF
					_cQry += " 			JOIN " +RetSqlName("SB1") + " SB1 ON B1_COD = B8_PRODUTO " + CRLF
					_cQry += "			where B8_FILIAL = '" +FwXFilial("SB8") + "'" + CRLF
					_cQry += "			AND B8_SALDO > 0  " + CRLF
					_cQry += "			and B8_X_CURRA != ''  " + CRLF
					_cQry += " 			and SB8.D_E_L_E_T_ = '' " + CRLF
					_cQry += " 			and SB1.D_E_L_E_T_ = '' " + CRLF

					QryOpc		:= 2

					cCodCon 	:= 'PRODUTO'
					cConsulta 	:= 'B8_PRODUTO'
					
				endif 
			elseif cCampo == 'M->ZMS_PRDBOV'
				IF oCab:GetValue("ZMS_TIPO") == 'N'
					_cQry := " select B8_PRODUTO " + CRLF
					_cQry += " 				 , B8_LOTECTL " + CRLF
					_cQry += " 				 , B8_X_CURRA " + CRLF
					_cQry += " 				 , B8_LOCAL " + CRLF
					_cQry += " 				 , B1_DESC " + CRLF
					_cQry += " 				 , B1_XRACA " + CRLF
					_cQry += " 				 , B1_X_SEXO " + CRLF
					_cQry += " 				 , B8_SALDO " + CRLF
					_cQry += " 				 , B8_DTVALID " + CRLF
					_cQry += " 				 , SB8.R_E_C_N_O_ SB8RECNO " + CRLF
					_cQry += " 			from " +RetSqlName("SB8") + " SB8 " + CRLF
					_cQry += " 			JOIN " +RetSqlName("SB1") + " SB1 ON B1_COD = B8_PRODUTO " + CRLF
					_cQry += "			where B8_FILIAL = '" +FwXFilial("SB8") + "'" + CRLF
					//if oCab:GetValue("ZMS_TIPO") == 'N'
					//	_cQry += "		AND B1_DESC in ('BOVINO MACHO DE 0 A 3 MESES','BOVINO MACHO DE 0 A 03 MESES','BOVINO MACHO DE 0 A 8 MESES','BOVINO MACHO DE 0 A 08 MESES','BOVINO FEMEA DE 0 A 3 MESES','BOVINO FEMEA DE 0 A 03 MESES','BOVINO FEMEA DE 0 A 8 MESES','BOVINO FEMEA DE 0 A 08 MESES')" + CRLF
					//endif
					//_cQry += "			AND B8_SALDO > 0  " + CRLF
					_cQry += "			and B8_X_CURRA != ''  " + CRLF
					_cQry += " 			and SB8.D_E_L_E_T_ = '' " + CRLF
					
					QryOpc		:= 3
					cCodCon 	:= 'PRODUTO'
					cConsulta 	:= 'B8_PRODUTO'
				endif 
			endif

			If lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
				MemoWrite("C:\totvs_relatorios\SQL_B8_VAESTI03.sql" , _cQry)
			EndIf

			if _cQry != ""
				DbSelectArea("SB8")
				DbSetOrder(1)
				uRetorno := U_PesqLote(_cQry,QryOpc)
				if !Empty(uRetorno)

					SB8->(DbGoto( uRetorno ))
					
					DbSelectArea("SB1")
					DbSetOrder(1)

					if oGridM:GetQtdLine() > 1
						for nI := 1 to oGridM:GetQtdLine()-1
							oGridM:GoLine(nI)
							If !oGridM:isDeleted()
								if  AllTrim(oGridM:GetValue('ZMS_LOTE'))   == AllTrim(SB8->B8_LOTECTL) .and. ;
									AllTrim(oGridM:GetValue('ZMS_PRDBOV')) == AllTrim(SB8->B8_PRODUTO) .and. ;
									AllTrim(oGridM:GetValue('ZMS_CURRAL')) == AllTrim(SB8->B8_X_CURRA);
									
									MsgAlert("Lote já inserido na Grid na linha [" +cValToChar(nI)+ "]." + CRLF +;
											"Insira outro Lote" , "Atenção!")
									lRet := .F.
								endif 
							endif 
						next
					endif 

					if lRet
						oGridM:GoLine(oGridM:GetQtdLine())

						_cLoteT 	:= oGridM:GetValue('ZMS_LOTE')
						_cProdT		:= oGridM:GetValue('ZMS_PRDBOV')
						_cCurralT 	:= oGridM:GetValue('ZMS_CURRAL')
						_cLocalT	:= oGridM:GetValue('ZMS_LOCAL')
						_cRacaT		:= oGridM:GetValue('ZMS_RACA')
						_cSexoT 	:= oGridM:GetValue('ZMS_SEXO')
						_cDescT		:= oGridM:GetValue('ZMS_DESC')
						
						oGridM:GoLine(nLine)
						if cCampo == 'M->ZMS_PRDBOV'
							IF oCab:GetValue("ZMS_TIPO") == 'N'
								dDtVLote	:= SB8->B8_DTVALID 
								__cRet 		:= SB8->B8_PRODUTO
								SB1->(DbSeek(fwXFilial("SB1") + AllTrim(SB8->B8_PRODUTO)))	
									oGridM:SetValue("ZMS_RACA", SB1->B1_XRACA)
									oGridM:SetValue("ZMS_SEXO", SB1->B1_X_SEXO)
									oGridM:SetValue("ZMS_DESC", SB1->B1_DESC)
							endif 
						ElseIf cCampo == 'M->ZMS_LOTE'
							IF oCab:GetValue("ZMS_TIPO") == 'N'
								oGridM:SetValue("ZMS_CURRAL",SB8->B8_X_CURRA)
								oGridM:SetValue("ZMS_LOCAL"	,SB8->B8_LOCAL	)
								__cRet	:= SB8->B8_LOTECTL
							else 
								__cRet		:= SB8->B8_LOTECTL
								oGridM:SetValue("ZMS_CURRAL"	,SB8->B8_X_CURRA)
								oGridM:SetValue("ZMS_LOCAL"		,SB8->B8_LOCAL	)
								oGridM:LoadValue("ZMS_PRDBOV"	,SB8->B8_PRODUTO)
								dDtVLote	:= SB8->B8_DTVALID
							
								SB1->(DbSeek(fwXFilial("SB1") + AllTrim(SB8->B8_PRODUTO)))	
									oGridM:SetValue("ZMS_RACA", SB1->B1_XRACA	)
									oGridM:SetValue("ZMS_SEXO", SB1->B1_X_SEXO	)
									oGridM:SetValue("ZMS_DESC", SB1->B1_DESC	)
							endif 
						endif 
					endif
				else 
					MSGINFO( "Não foi possível filtrar o lote", "Atenção!" )
					__cRet := ""
				endif
			else
				cCampo := Substr( ReadVar(), At('->', ReadVar())+2 )
				__cRet := oGridM:GetValue(cCampo)
			endif

		else
			lRet := .F. 
			MsgAlert("movimentação já realizada para este lote. Não é possível alterar", "Atenção!!!")
		endif
	endif

	if aArea[1] <> "SB8"
		RestArea( aAreaSB1 )
		RestArea( aArea )
	endif

	if  oModel:GetOperation() == 3
		oGridM:SetNoInsertLine(.F.)
	endif

	oView:Refresh()
RETURN lRet
/* Validação no Campo Lote */
User Function I03VPRDM()
	Local aArea      	:= GetArea()
	Local lRet       	:= .T.
	Local oModel	  	:= FWModelActive()
	Local oView		 	:= FWViewActive()
	Local oCab 			:= oModel:GetModel('ZMSMASTER')
	Local oGridM 		:= oModel:GetModel('ZMSDETAIL')
	Local _cAlias 		:= GetNextAlias()
	Local nLine 		:= oGridM:GetLine()
	
	if oCab:GetValue("ZMS_TIPO") == Space(TamSx3("ZMS_TIPO")[1])
		oModel:SetErrorMessage("","","","","HELP", 'Tipo Vazio', "Informe o tipo da operação")
		lRet := .F. 
	ELSE
		IF oCab:GetValue("ZMS_TIPO") $ 'N|M|A' /* .and. lRet */

			oGridM:GoLine(nLine)

			_cQry := " select * from "+RetSqlName("ZMS")+" " + CRLF
			_cQry += " where ZMS_FILIAL = '"+fwXFilial("ZMS")+"'" + CRLF
			_cQry += " AND ZMS_TIPO IN ('N','M','A') " + CRLF
			_cQry += " AND ZMS_PRDBOV = '"+oGridM:GetValue('ZMS_PRDBOV')+"'" + CRLF
			_cQry += " AND ZMS_LOTE = '"+oGridM:GetValue('ZMS_LOTE')+"'" + CRLF
			_cQry += " AND ZMS_CURRAL = '"+oGridM:GetValue('ZMS_CURRAL')+"' " + CRLF
			_cQry += " AND ZMS_DATA >= DATEADD(dd,-7, '"+dToS(dDataBase)+"')" + CRLF
			_cQry += " AND D_E_L_E_T_ = '' " + CRLF

			If lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
				MemoWrite(StrTran("C:\totvs_relatorios\",".xml","")+"VERIFICATIPO.sql" , _cQry)
			EndIf

			dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

			if !(_cAlias)->(EOF())
				if !MsgYesNo("Movimentação para este lote [ "+AllTrim(oGridM:GetValue('ZMS_LOTE'))+" ] realizada no dia: " + dToC(sToD((_cAlias)->ZMS_DATA)) + " " + CRLF +;
							"Produto: [ "+AllTrim(oGridM:GetValue('ZMS_PRDBOV'))+" ]" + CRLF +;
							"Quantidade: [ " + cValToChar((_cAlias)->ZMS_QTDE) + " ]" + CRLF +;
							"Curral: [ "+AllTrim(oGridM:GetValue('ZMS_CURRAL'))+" ]" + CRLF +;
							"Inserir outra movimentação???", "Atenção!!!")

					oGridM:LoadValue("ZMS_LOTE"	, 	Space(TamSx3("B8_LOTECTL")[1])) //)SB8->B8_LOTECTL
					oGridM:SetValue("ZMS_CURRAL", 	Space(TamSx3("B8_X_CURRA")[1]) )//)SB8->B8_X_CURRA
					oGridM:SetValue("ZMS_LOCAL"	, 	Space(TamSx3("B8_LOCAL")[1]) )	//SB8->B8_LOCAL
					oGridM:LoadValue("ZMS_PRDBOV", 	Space(TamSx3("B8_PRODUTO")[1]) )//)SB8->B8_PRODUTO
					oGridM:SetValue("ZMS_RACA"	, 	Space(TamSx3("B1_XRACA")[1]) )	//SB1->B1_XRACA
					oGridM:SetValue("ZMS_SEXO"	, 	Space(TamSx3("B1_X_SEXO")[1]) )	//SB1->B1_X_SEXO
					oGridM:SetValue("ZMS_DESC"	, 	Space(TamSx3("B1_DESC")[1])) 	//SB1->B1_DESC
					dDtVLote := Space(TamSx3("B8_DTVALID")[1]) //)SB8->B8_DTVALID
					lRet := .f.

				endif 
			ENDIF  	
		ENDIF  
	endif 
	RestArea( aArea )
	oView:Refresh()
Return lRet 
/* 	Igor Oliveira - 05/2022
	Deu B.O no SX8Num pq mudou o tamanho do campo 
	Função incremental para ZMS_COD */
Static Function VaGetX8(cAlias, cCampo)
	Local aArea 	:= GetArea() 
	Local oModel  	:= FWModelActive()
	Local cCod 		:= ''
	Local lRet		:= .F.
	Local _cQry 	:= ''

	DbSelectArea(cAlias)
	
	_cQry := " select MAX(ZMS_COD) cMAX FROM " + RetSqlName("ZMS") + ""

 	DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(_cQry)), "__TMP", .t., .f.)

	If !__TMP->(Eof())
		cCod := __TMP->cMAX
	EndIF

	if (cCod == StrZero(0, TamSX3(cCampo)[1]))
		cCod := StrZero(1, TamSX3(cCampo)[1])
	else 
		cCod := StrZero(Val(cCod)+1, TamSX3(cCampo)[1])
	ENDIF

	if oModel:SetValue("ZMSMASTER", "ZMS_COD", cCod)
		lRet := .T.
	ENDIF

	__TMP->(DbCloseArea())
	RestArea(aArea)

RETURN cCod

Static Function Morte()
	Local aArea 	 	:= GetArea() 
	Local oModel  	 	:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oCab 			:= oModel:GetModel("ZMSMASTER")
	Local oGridM 		:= oModel:GetModel("ZMSDETAIL")
	local nI 
	Local cTM 			:= GetMV("MV_TMMORTE") // 011
	Local lRet 			:= .T.
	Local dData	
	Local cLocal		:= ''	
	Local _aCab1	 	:= {}
	Local _aItem 		:= {}
	Local _atotitem		:= {}
	Local aMsg			:= {}
	Local cMsg			:= ""
	Local cDoc			:= ''
	
	lMsErroAuto := .F.
	
	DbSelectArea("SD3")
	SD3->(DbSetOrder(1))

	DbSelectArea("ZSM")
	ZSM->(DbSetOrder(1))

	DbSelectArea("SB8")
	SB8->(DbSetOrder(7))
	
	for nI := 1 to oGridM:GetQtdLine()
		oGridM:GoLIne(nI)
		if !oGridM:isDeleted()
			if oGridM:GetValue("ZMS_QTDE") == 0
				oModel:SetErrorMessage("","","","","HELP", 'Linha' + Str(nI) + ' com quantidade zerada', "Verifique a Quantidade ou Apague a linha")
				Return .F. 
			endif 
		endif 
	next
	
	if oCab:GetValue("ZMS_TIPO")  $ 'M|A' 
		if !EMPTY(oCab:GetValue("ZMS_RESPON"))  

			if !Empty(oCab:GetValue("ZMS_DATA"))
				dData := oCab:GetValue("ZMS_DATA")
			else 
				dData := dDataBase
			ENDIF


			For nI := 1 to oGridM:GetQtdLine()
				
				cDoc := NextNumero("SD3",2,"D3_DOC",.T.)
				
				oGridM:GoLine(nI)
				if !oGridM:isDeleted()
					if Empty(oGridM:GetValue("ZMS_D3DOC"))

							ZSM->(DBSeek(FwXFilial("ZMS")+oCab:GetValue("ZMS_MOTIVO")))
								cMtObs := AllTrim(ZSM->ZSM_DESC)

							SB8->(DBSeek(FwXFilial("ZMS")+oGridM:GetValue("ZMS_LOTE")+oGridM:GetValue("ZMS_CURRAL")))
								cLocal := AllTrim(oGridM:GetValue("ZMS_CURRAL"))

							_aCab1 := { {"D3_FILIAL"	, fwXFilial("ZMS"), NIL},;
										{"D3_DOC" 		, cDoc			, NIL},;
										{"D3_TM" 		, cTM	 		, NIL},;
										{"D3_CC" 		, ""			, NIL},;
										{"D3_EMISSAO" 	, dData			, NIL}}

							_aItem := { {"D3_COD" 		, oGridM:GetValue("ZMS_PRDBOV")							,NIL},;
										{"D3_UM" 		, "UN" 													,NIL},; 
										{"D3_X_QTD" 	, 1 													,NIL},;
										{"D3_QUANT" 	, oGridM:GetValue("ZMS_QTDE")	 						,NIL},;
										{"D3_X_CURRA" 	, cLocal												,NIL},;
										{"D3_CUSTO1" 	, 0.01													,NIL},;
										{"D3_LOTECTL" 	, oGridM:GetValue("ZMS_LOTE")							,NIL},;
										{"D3_X_OBS"    	, cMtObs /* + "" + AllTrim(oCab:GetValue("ZMS_OBS")) */	,NIL},;
										{"D3_OBSERVA"	, AllTrim(oCab:GetValue("ZMS_OBS"))				    	,NIL},;
										{"D3_OBS"		, cMtObs + "-" + AllTrim(oCab:GetValue("ZMS_OBS"))     	,NIL}}
							
							aAdd(_atotitem,_aItem)

							if len(_atotitem) >= 1
								MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)
								If lMsErroAuto 
									Mostraerro()
									lRet := .F.
									DisarmTransaction()
								else

									SD3->(DbSetOrder(2))

									IF (SD3->(DBSeek(FWxFilial("ZMS") + cDoc)))

										oGridM:SetValue("ZMS_D3DOC", cDoc)
										oGridM:SetValue("ZMS_D3REC", SD3->(Recno()))
									
										aAdd(aMsg,{"Nº do Doc: [ "+cDoc+" ]",;
												"Linha [ " + StrZero(nI,TamSX3("ZMS_ITEM")[1]) + " ] " +CRLF})
									
										SD3->(DBSkip())
									ENDIF
								ENDIF	
							ENDIF
					else
						MsgAlert("Movimentação já realizada anteriormente!!!" + CRLF +;
							"Nº do Doc: [ "+cDoc+" ]", "Atenção!!!")
					EndIf
				EndIf
			NEXT
			
		else 
			lRet := .F.
			MsgAlert("Campo [ Responsável ] vazio!!", "Atenção")//( ,, 'Help',, '.', 'ZMS_RESPON' , 1, 0 )
		ENDIF 
	else 
		lRet := .F.
				MsgAlert("Campo Tipo inválido para esta operação!!." + CRLF +; 
					'Para prosseguir preencha o campo com o Tipo [ N ]' + CRLF +;
            		'ZMS_TIPO' , "Atenção")
	ENDIF

		if len(aMsg) >= 1
			for nI := 1 to len(aMsg)
				cMsg += aMsg[nI][1] + " | " +aMsg[nI][2]
				cMsg += CRLF
			next
			MsgAlert("Movimentação realizada!!!" + CRLF +;
					cMsg, "Atenção!!")
		endif
	
	ZSM->(DBCloseArea())
	//SD3->(DBCloseArea())
	
	oView:Refresh()

	if lRet
		U_zSaveZMSMd2()
	endif

	RestArea(aArea)
RETURN lRet

Static Function Estorno()
	Local oModel  	 	:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oCab 			:= oModel:GetModel("ZMSMASTER")
	Local oGridM 		:= oModel:GetModel("ZMSDETAIL")
	Local lRet			:= .T.
	Local lEst 			:= .F.
	Local _aCab1	 	:= {}
	Local _aItem 		:= {}
	Local _atotitem		:= {}
	local nI

	Private l241Auto := .t.
	
	lMsErroAuto := .F.

	DbSelectArea("SD3")
	SD3->(DbSetOrder(2))
	
	if oCab:GetValue("ZMS_D3EST") != 'S'
		if MsgYesNo("Não será possivel alterar/incluir registros nesse cadastro após movimentação, Confirma?", "Atenção!")
			if !oGridM:IsEmpty()
				for nI := 1 to oGridM:GetQtdLine()
					oGridM:GoLIne(nI)
					if !oGridM:isDeleted()
						if !Empty(oGridM:GetValue("ZMS_D3REC"))
							//IF 
								SD3->(DBGoTo(oGridM:GetValue("ZMS_D3REC")))
								
								aCab := { {"D3_DOC" , oGridM:GetValue("ZMS_D3DOC"),Nil}}

								aItem := {	{"D3_COD"		,oGridM:GetValue("ZMS_PRDBOV")								,	NIL},;
										  	{"D3_UM"		,"UN"														,	NIL},;
										  	{"D3_QUANT"		,oGridM:GetValue("ZMS_QTDE")								,	NIL},;
										  	{"D3_LOCAL"		,"01"														,	NIL},;
										  	{"D3_X_CURRA" 	, oGridM:GetValue("ZMS_LOCAL")								,	NIL},;
											{"D3_CUSTO1" 	, 0.01														,	NIL},;
											{"D3_LOTECTL" 	, oGridM:GetValue("ZMS_LOTE")								,	NIL},;
											{"D3_X_OBS"    	, SD3->D3_X_OBS												,	NIL},;	
											{"D3_OBSERVA"	, AllTrim(oCab:GetValue("ZMS_OBS"))				    		,	NIL},;
											{"D3_OBS"		, SD3->D3_X_OBS + "-" + AllTrim(oCab:GetValue("ZMS_OBS"))   ,	NIL},;
										  	{"D3_ESTORNO"	,"S"														,	NIL}}

								aAdd(_atotitem,_aItem)

								if len(_atotitem) >= 1

									MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,6)
								
									If lMsErroAuto 
										conout("Erro")
										Mostraerro()
										lRet := .F.
										DisarmTransaction()
									else
										conout("Ok")
										oCab:LoadValue("ZMS_D3EST", 'S')
										oGridM:LoadValue("ZMS_D3REC", 0)
										lRet := .T.
										lEst := .T. 
									ENDIF	
								ENDIF
							//ENDIF 
						endif 
					endif 
				next
				if lEst 
					oView:Refresh()

					U_zSaveZMSMd2()

					MsgAlert("Movimentação Estornada!", "Atenção!")
				endif 
			else 
				MsgAlert("Grid Vazia!", "Atenção!")
			endif 
		endif
	else 
		MsgAlert("Cadastro já foi estornado!", "Atenção!")
	endif 

	//SD3->(DBCloseArea())
	
Return lRet

Static Function Nascimento()
	Local aArea 	 	:= SX3->(GetArea() )
	Local oModel  	 	:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oCab 			:= oModel:GetModel("ZMSMASTER")
	Local oGridM 		:= oModel:GetModel("ZMSDETAIL")
	local nI
	Local cTM 			:= GetMV("MV_TMNASC")
	Local nPeso			:= GetMV("MV_PESNASC") // peso nascimento 
	Local lRet 			:= .T.
	Local dData			
	Local cLocal		:= ''	
	Local _cQry,cUpd	:= ''	
	Local _aCab1	 	:= {}
	Local _aItem 		:= {}
	Local _atotitem		:= {}
	Local cDoc			:= ''
	Local cMsg			:= ""
	Local aMsg			:= {}
	Local nRecno
	
	lMsErroAuto := .F.

	for nI := 1 to oGridM:GetQtdLine()
		oGridM:GoLIne(nI)
		if !oGridM:isDeleted()
			if oGridM:GetValue("ZMS_QTDE") == 0
				MsgAlert('Linha' + Str(nI) + ' com quantidade zerada' + CRLF+;
						'Verifique a Quantidade ou Apague a linha', "Atenção!!!")
						//oModel:SetErrorMessage("","","","","HELP", , )
				Return .F.
			endif 
		endif
	next

	if oCab:GetValue("ZMS_TIPO") == 'N'
		if !EMPTY(oCab:GetValue("ZMS_RESPON"))
			
			if !Empty(oCab:GetValue("ZMS_DATA"))
				dData := oCab:GetValue("ZMS_DATA")
			else 
				oCab:SetValue("ZMS_DATA", dDataBase)
				dData := dDataBase
			ENDIF

			For nI := 1 to oGridM:GetQtdLine()
				
				oGridM:GoLine(nI)
				if !oGridM:isDeleted()
						if Empty(oGridM:GetValue("ZMS_D3DOC"))  
							cMtObs := "Nascimento"
							
							DbSelectArea("SD3")
							SD3->(DbSetOrder(1))
							
							DbSelectArea("SB8")
							SB8->(DbSetOrder(7))
							SB8->(DBSeek(FwXFilial("ZMS")+oGridM:GetValue("ZMS_LOTE")+oGridM:GetValue("ZMS_CURRAL")))

							cLocal := AllTrim(oGridM:GetValue("ZMS_CURRAL"))

							_atotitem := {}
							cDoc := NextNumero("SD3",2,"D3_DOC",.T.)
							
							_aCab1 := { {"D3_FILIAL"	, fwXFilial("ZMS"), NIL},;
										{"D3_DOC" 		, cDoc			, NIL},;
										{"D3_TM" 		, cTM	 		, NIL},;
										{"D3_CC" 		, ""			, NIL},;
										{"D3_EMISSAO" 	, dData			, NIL}}

							_aItem := { {"D3_COD" 		, oGridM:GetValue("ZMS_PRDBOV")							,NIL},;
										{"D3_UM" 		, "UN" 													,NIL},; 
										{"D3_X_QTD" 	, 1 													,NIL},;
										{"D3_QUANT" 	, oGridM:GetValue("ZMS_QTDE")	 						,NIL},;
										{"D3_X_CURRA" 	, cLocal												,NIL},;
										{"D3_CUSTO1" 	, 0.01													,NIL},;
										{"D3_LOTECTL" 	, oGridM:GetValue("ZMS_LOTE")							,NIL},;
										{"D3_X_OBS"    	, cMtObs /* + "" + AllTrim(oCab:GetValue("ZMS_OBS")) */	,NIL},;
										{"D3_OBSERVA"	, AllTrim(oCab:GetValue("ZMS_OBS"))				    	,NIL},;
										{"D3_OBS"		, cMtObs + "-" + AllTrim(oCab:GetValue("ZMS_OBS"))     	,NIL}}
							
							aAdd(_atotitem,_aItem)
									
							if len(_atotitem) >= 1

								MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)
							
								If lMsErroAuto
									Mostraerro()
									lRet := .F.
									DisarmTransaction()
								else

									SD3->(DbSetOrder(2))
										IF (SD3->(DBSeek(FWxFilial("ZMS") + cDoc)))
											oGridM:SetValue("ZMS_D3DOC", cDoc)
											oGridM:SetValue("ZMS_D3REC", SD3->(Recno()))
											
											aAdd(aMsg,{"Nº do Doc: [ "+cDoc+" ]",;
													"Linha [ " + StrZero(nI,TamSX3("ZMS_ITEM")[1]) + " ] " +CRLF})
												SD3->(DBSkip())
										ENDIF
									
										_cQry := " select * " + CRLF 
										_cQry += " from "+RetSqlName("SB8")+"" + CRLF 
										_cQry += " WHERE B8_FILIAL = '"+fwXFilial("SB8")+"'" + CRLF 
										_cQry += " AND B8_LOTECTL = '"+oGridM:GetValue("ZMS_LOTE")+"'" + CRLF 
										_cQry += " AND B8_PRODUTO = '"+oGridM:GetValue("ZMS_PRDBOV")+"'" + CRLF 
										_cQry += " AND D_E_L_E_T_ = '' " + CRLF 

										DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(_cQry)), "__TB8", .t., .f.)

										If !__TB8->(Eof())
											
											nRecno := __TB8->R_E_C_N_O_

											if Empty(__TB8->B8_XDATACO) .or. Empty(__TB8->B8_X_CURRA) .or. Empty(__TB8->B8_XPESOCO)

												cUpd := " UPDATE " + retSQLName("SB8") + " " + CRLF 
												cUpd += " 		SET B8_X_CURRA = '" + oGridM:GetValue("ZMS_CURRAL") + "' " + CRLF 
												cUpd += " 		, B8_XDATACO = '"+dToS(dData)+"' " + CRLF 
												cUpd += " 		, B8_XPESOCO = "+cValToChar(nPeso)+" " + CRLF // CRIAR PARAMETRO EM PRODUCAO PARA ALTERAR PESO INICIAL  
												cUpd += " 		WHERE R_E_C_N_O_ = "+cValToChar(nRecno)+" " 
												
												if Lower(cUserName) $ "ioliveira,bernardo,atoshio,admin"
													MemoWrite("C:\totvs_relatorios\SQL_UPDSB8__VAESTI03.sql" , cUpd)
												endif 
												
												If (TCSqlExec(cUpd) < 0)
													conout("TCSQLError() " + TCSQLError())
												else
													ConOut("Update SB8 realizado!")
												EndIf

											endif 
										ENDIF
										__TB8->(DbCloseArea())
									ENDIF
								ENDIF
						else
							MsgAlert("Movimentação já realizada anteriormente!!!" + CRLF +;
								"Nº do Doc: [ "+cDoc+" ]", "Atenção!!!")
						EndIf
				EndIf
			NEXT
		else 
			lRet := .F.
			MsgAlert("Campo [ Responsável ] vazio!!", "Atenção")//( ,, 'Help',, '.', 'ZMS_RESPON' , 1, 0 )
		ENDIF 
	else 
		lRet := .F.
		MsgAlert("Campo Tipo inválido para esta operação!!." + CRLF +; 
					'Para prosseguir preencha o campo com o Tipo [ N ]' + CRLF +;
            		'ZMS_TIPO' , "Atenção")
	endif
	
	if len(aMsg) >= 1
		for nI := 1 to len(aMsg)
			cMsg += aMsg[nI][1] + " | " +aMsg[nI][2]
			cMsg += CRLF
		next 
		MsgAlert("Movimentação realizada!!!" + CRLF +;
				cMsg, "Atenção!!")
	endif

	oView:Refresh()

	if lRet
		U_zSaveZMSMd2()
	endif

	RestArea(aArea)
Return lRet 

/* Igor Oliveira 03/06/2022
	Iniciador Padrao e Browse */
user function RelMeV3()
//user function INIMEDV3()
	Local aArea     := GetArea()
	Local oModel  	 	:= FWModelActive()
	Local nOpc			:= oModel:GetOperation()
	Local cRet

	if nOpc == MODEL_OPERATION_INSERT
		cRet := ""
	else
		cRet := Iif(Empty(ZMS->ZMS_MEDIC),"", Posicione("SB1", 1, fwXFilial('SB1')+ZMS->ZMS_MEDIC, 'B1_DESC'))
	ENDIF
	RestArea(aArea)
return cRet
	
User Function INIMEDV3()
//User Function RelMeV3()
return Iif(Empty(ZMS->ZMS_MEDIC),"", Posicione("SB1", 1, fwXFilial('SB1')+ZMS->ZMS_MEDIC, 'B1_DESC'))

/* Validação Campo ZMS_MEDIC  */
User Function VMdMV3()
	Local oModel  	 	:= FWModelActive()
	Local oCab 			:= oModel:GetModel("ZMSMASTER")
	Local lRet 			:= .F.

	if oCab:GetValue("ZMS_TIPO") == 'P'
		lRet := .T.
	else
		oModel:SetErrorMessage("","","","","HELP", 'Tipo invalido!', "Informe o tipo [ P ]")
	ENDIF

return lRet
/* Validação Campo ZMS_Tipo */
User Function VLDTPV3()
	Local oView 		:= FWViewActive()
	Local oModel  	 	:= FWModelActive()
	Local oCab 			:= oModel:GetModel("ZMSMASTER")
	Local oGridM 		:= oModel:GetModel("ZMSDETAIL")
	Local lRet 			:= .T.

	if !oGridM:IsEmpty()
		if !(AllTrim(oGridM:GetValue("ZMS_LOTE")) == "" .and. oGridM:GetQtdLine() == 1)
			//oModel:SetErrorMessage("","","","","HELP", 'Tipo só pode ser alterado com a lista vazia', "Apague as linhas ou inicie um novo processo")
			if MsgYesNo("Tipo só pode ser alterado com a lista vazia" + CRLF +;
					 "Deseja apagar todas as linhas da grid?", "Atenção!!!")
				oGridM:ClearData()
				oView:Refresh()
				_cTipo := oCab:GetValue("ZMS_TIPO")
			else 
				lRet := .F. 
			endif 
		endif 
	else  
		if oCab:GetValue("ZMS_TIPO") $ "M|A|N"
			if !Empty(oGridM:GetValue("ZMS_MEDIC"))
				lRet := .F.
				oModel:SetErrorMessage("","","","","HELP", 'Tipo invalido!', "Tipo não pode ser [M], [A] ou [N] se houver algum medicamento preenchido!")
			endIf
		ENDIF 
		_cTipo := oCab:GetValue("ZMS_TIPO")
	endif 
RETURN lRet
/* Igor Oliveira 06-2022
	Copiar campo Virtual com posicionamento para linha de baixo */
//USER FUNCTION RVI03BV(cAlias, cIndex,  cCamp, cCampPosi)
USER FUNCTION RVI03BV()
	Local oModel  	:= FWModelActive()
	Local oCab 		:= oModel:GetModel('ZMSMASTER')
	Local oGridM 	:= oModel:GetModel('ZMSDETAIL')
	Local nLinha 	:= oGridM:GetQtdLine()
	Local cRet   		
	Local cCampo 	:= SubS( ReadVar(), At(">", ReadVar())+1 )

	if oCab:GetValue("ZMS_TIPO") == 'P'
		if cCampo $ "ZMS_LOTE-ZMS_PRDBOV-ZMS_CURRAL-ZMS_RACA-ZMS_SEXO-ZMS_DESC-ZMS_NOME-ZMS_LOCAL-ZMS_QTDE"
			if nLinha == 1 .and. Empty(oGridM:GetValue(cCampo)) 
				IF cCampo == 'ZMS_QTDE'
					Return 0
				else 
					cRet := ""
				endif
			elseif nLinha == 1 .and. !Empty(oGridM:GetValue(cCampo))
				oGridM:Goline(nLinha)
				cRet 	:= oGridM:GetValue(cCampo) 
			elseif nLinha > 1 
				oGridM:Goline(nLinha)
				cRet := oGridM:GetValue(cCampo)
			ENDIf
		ENDIF
	ENDIF
RETURN iif(cRet==nil,"",cret)

USER FUNCTION I03VLPRD()
	Local oModel  	:= FWModelActive()
	Local oCab 		:= oModel:GetModel('ZMSMASTER')
	Local lRet		:= .t.   		

	if oCab:GetValue("ZMS_TIPO") != 'N'
		oModel:SetErrorMessage("","","","","HELP", 'Campo só pode ser alterado no Tipo [ N ]', "Informe o tipo correto!")
		lRet := .F. 
	ENDIF
	
RETURN lRet
/* 
User Function Teste( )
Local cTitulo
dbSelectArea(?SX3?)
dbSetOrder(2)
If dbSeek( ?A1_COD? )   
	cTitulo := X3Titulo()
EndIf
Return */
