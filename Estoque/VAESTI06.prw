#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"  

Static cTitulo := "Avaliação de Operadores"

User Function VAESTI06()
	Local aArea     	:= GetArea()
	Local oBrowse
	Local cFunBkp   	:= FunName()
    Private cArquivo    := "C:\TOTVS_RELATORIOS\"
    

	SetFunName("VAESTI06")
	//Cria um browse para a ZAV, filtrando somente a tabela 00 (cabeçalho das tabelas
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZAV")
	//oBrowse:SetFilterDefault("ZAV->ZAV_DATA == '"+DTOS(dDataBase)+"'")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)
Return Nil

Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.VAESTI06' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.VAESTI06' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.VAESTI06' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.VAESTI06' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStPai   	:= FWFormStruct(1, 'ZAV')
	Local oStFilho 	:= FWFormStruct(1, 'ZAV')
	Local bVldPos  	:= {|| u_zVldZAVTab()  }
	Local bVldCom  	:= {|| u_zSaveZAVMd2()  }
	Local aZAVRel  	:= {}
	Local aAux

	aAux := FwStruTrigger(;
				"ZAV_NOTA" ,; // Campo Dominio
				"ZAV_ORIGEM" ,; // Campo de Contradominio
				"'M'",; // Regra de Preenchimento
				.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
				"" ,; // Alias da tabela a ser posicionada
				0 ,; // Ordem da tabela a ser posicionada
				"" ,; // Chave de busca da tabela a ser posicionada
				NIL ,; // Condicao para execucao do gatilho
				"01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)

	oStFilho:AddTrigger(aAux[1], aAux[2], aAux[3], aAux[4])

	//Criando o FormModel, adicionando o Cabeçalho e Grid
	oModel := MPFormModel():New("ESTI06M",/*Pre-Validacao*/, bVldPos /*Pos-Validacao*/, bVldCom /*Commit*/,/*Cancel*/)

	oModel:AddFields("ZAVMASTER",/*cOwner*/ ,oStPai  )
	
    oModel:AddGrid('ZAVDETAIL','ZAVMASTER', oStFilho)//, /* bLinePre */ ,,,, bLoad)
	
    //Adiciona o relacionamento de Filho, Pai
	aAdd(aZAVRel, {'ZAV_FILIAL' , 'Iif(!INCLUI, ZAV->ZAV_FILIAL, FWxFilial("ZAV")    )'} )
	aAdd(aZAVRel, {'ZAV_COD'    , 'Iif(!INCLUI, ZAV->ZAV_COD, ZAV->ZAV_COD			 )'} )
	aAdd(aZAVRel, {'ZAV_MAT'    , 'Iif(!INCLUI, ZAV->ZAV_MAT, ZAV->ZAV_MAT			 )'} )
	aAdd(aZAVRel, {'ZAV_DATA'   , 'Iif(!INCLUI, ZAV->ZAV_DATA  , sToD("")            )'} )
	aAdd(aZAVRel, {'ZAV_ITEM'   , 'Iif(!INCLUI, ZAV->ZAV_ITEM  , ZAV->ZAV_ITEM       )'} )
	
	//Criando o relacionamento
	oModel:SetRelation('ZAVDETAIL', aZAVRel, ZAV->(IndexKey(3)))

	oModel:SetPrimaryKey({ })

	//Setando o campo único da grid para não ter repetição
	oModel:GetModel('ZAVDETAIL'):SetUniqueLine({ "ZAV_FILIAL","ZAV_COD","ZAV_DATA", "ZAV_ITEM" })
	
	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZAVMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)


Return oModel

Static Function ViewDef()
	Local oModel     := FWLoadModel("VAESTI06")
	Local oStPai     := FWFormStruct(2, 'ZAV')
	Local oStFilho   := FWFormStruct(2, 'ZAV')
	Local oView      := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB" , oStPai  , "ZAVMASTER")
	oView:AddGrid('VIEW_ITENS', oStFilho, 'ZAVDETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 20)
	oView:CreateHorizontalBox('GRID' , 80)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB'  ,'CABEC')
	oView:SetOwnerView('VIEW_ITENS','GRID' )

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB','Cabeçalho - Avaliação do operador')
	oView:EnableTitleView('VIEW_ITENS','Itens - Avaliação do operador')

	//Auto incremento para o campo ZAV_ITEM
	oView:AddIncrementField( 'VIEW_ITENS', 'ZAV_ITEM' )
	
	oView:AddUserButton( 'Preencher Critérios (F11)','', {|oView| U_VAI06PLn()} )
	
	//oView:SetFieldAction("ZAV_CCOD", {|oView, cIdView, cField, xValue| U_VAI06PLn(oView, cIdView, cField, xValue)})

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk( { |oView| .T. } )

	SetKey(VK_F11, {|| FWMsgRun(, {|| U_VAI06PLn() }, "Processando", "Preenchendo Linhas...") })
	
	//Remove os campos de Filial e Tabela da Grid
	oStPai:RemoveField('ZAV_ITEM')
	oStPai:RemoveField('ZAV_CCOD')
	oStPai:RemoveField('ZAV_CDESC')
	oStPai:RemoveField('ZAV_NOTA')
	oStPai:RemoveField('ZAV_ORIGEM')

	oStFilho:RemoveField('ZAV_FILIAL')
	oStFilho:RemoveField('ZAV_NOME')
	oStFilho:RemoveField('ZAV_COD')
	oStFilho:RemoveField('ZAV_DATA')
	oStFilho:RemoveField('ZAV_MAT')
Return oView

User Function zVldZAVTab()
	Local aArea     := GetArea()
	local oView     := FWViewActive()
	Local oModel    := FWModelActive()
	Local nOpc      := oModel:GetOperation()
	Local lRet      := .T.

	//Se for Inclusão
	If nOpc == MODEL_OPERATION_INSERT
		DbSelectArea('ZAV')
		ZAV->(DbSetOrder(1)) 
		//Se conseguir posicionar, tabela já existe
		If ZAV->(DbSeek( xFilial("ZAV") +;
				oModel:GetValue('ZAVMASTER', 'ZAV_COD') +;
				dToS(oModel:GetValue('ZAVMASTER', 'ZAV_DATA'))))
			Aviso('Atenção', 'Esse código de tabela já existe!', {'OK'}, 02)
			lRet := .F.
		EndIf
	EndIf
	
    If Empty(oModel:GetValue("ZAVMASTER","ZAV_DATA"))
		oModel:SetValue("ZAVMASTER","ZAV_DATA", dDataBase)
	EndIf
	
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf
	RestArea(aArea)
    oView:Refresh()

Return lRet

User Function zSaveZAVMd2()
	Local aArea      := GetArea()
	Local lRet       := .T.
	Local oModelDad  := FWModelActive()
	Local nOpc       := oModelDad:GetOperation()
	Local oModelGrid := oModelDad:GetModel('ZAVDETAIL')

	Local nI         := 0
	Local lRecLock   := .T.

	DbSelectArea('ZAV')
	ZAV->(DbSetOrder(2))
	//Se for Inclusão
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE

	//Percorre as linhas da grid
	if !Empty(oModelDad:GetValue( 'ZAVMASTER', 'ZAV_MAT'))
		//if ValidaNota()
			For nI := 1 To oModelGrid:GetQtdLine()
				
				oModelGrid:GoLine(nI)
				If !oModelGrid:isDeleted()
						if !Empty(oModelGrid:GetValue('ZAV_CCOD'))
							RecLock('ZAV', lRecLock := !DbSeek( xFilial("ZAV") +;
														oModelDad:GetValue('ZAVMASTER', 'ZAV_COD') +;
														dToS(oModelDad:GetValue('ZAVMASTER', 'ZAV_DATA') ) +;
														oModelGrid:GetValue('ZAV_ITEM')))

								ZAV->ZAV_FILIAL     := xFilial("ZAV")
								ZAV->ZAV_COD 	    := oModelDad:GetValue('ZAVMASTER', 'ZAV_COD') 
								ZAV->ZAV_DATA   	:= oModelDad:GetValue('ZAVMASTER', 'ZAV_DATA')	
								ZAV->ZAV_MAT      	:= oModelDad:GetValue('ZAVMASTER', 'ZAV_MAT')	
								ZAV->ZAV_ITEM   	:= oModelGrid:GetValue('ZAV_ITEM')
								ZAV->ZAV_CCOD   	:= oModelGrid:GetValue('ZAV_CCOD')
								ZAV->ZAV_NOTA   	:= oModelGrid:GetValue('ZAV_NOTA')
								ZAV->ZAV_ORIGEM 	:= oModelGrid:GetValue('ZAV_ORIGEM')

							ZAV->(MsUnlock())
						ENDIF
					Else		
						If ZAV->(DbSeek( xFilial("ZAV") +;
								oModelDad:GetValue('ZAVMASTER', 'ZAV_COD') +;
								dToS(oModelDad:GetValue('ZAVMASTER', 'ZAV_DATA') ) +;
								oModelGrid:GetValue('ZAV_ITEM')))

							RecLock('ZAV', .F.)
								ZAV->(DbDelete())
							ZAV->(MsUnlock())
						EndIf
				EndIf
			Next nI
		//else 
		//	lRet := .F.
		//	oModelDad:SetErrorMessage("ZAVDETAIL","ZAV_NOTA","ZAVDETAIL","ZAV_NOTA","Erro",'Campo Nota vazio', 'Informe Todas as Notas!!')
		//ENDIF
	else
		lRet :=  .F.
		//Mensagem de erro 
		oModelDad:SetErrorMessage("ZAVMASTER","ZAV_MAT","ZAVMASTER","ZAV_MAT","Erro",'Campo matrícula vazio', 'Informe a Matrícula')
	EndIf
	//Se for Exclusão
	ElseIf nOpc == MODEL_OPERATION_DELETE
		For nI := 1 To oModelGrid:GetQtdLine()
			oModelGrid:GoLine(nI)
			//Se conseguir posicionar, exclui o registro
			If ZAV->(DbSeek( xFilial("ZAV") +;
						oModelDad:GetValue('ZAVMASTER', 'ZAV_COD') +;
						dToS(oModelDad:GetValue('ZAVMASTER', 'ZAV_DATA') ) +;
						oModelGrid:GetValue('ZAV_ITEM')))

				RecLock('ZAV', .F.)
					ZAV->(DbDelete())
				ZAV->(MsUnlock())
			EndIf
		Next nI
	EndIf

	//Se não for inclusão, volta o INCLUI para .T. (bug ao utilizar a Exclusão, antes da Inclusão)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

	RestArea(aArea)
Return lRet

User Function FunEst6()
    Local aArea			:= GetArea()
	Local oDlg, oLbx
    Local aCpos  		:= {}
    Local aRet   		:= {}
    Local _cQry  		:= ""
    Local cAlias 		:= GetNextAlias()
    Local lRet   		:= .F.
	Private _cFunc  	:= CriaVar('ZAV_MAT', .F.)
/* 	Local oView		 	:= FWViewActive()
	Local oModel      	:= FWModelActive() */
	//Local oModelDad 	:= oModel:GetModel('ZAVMASTER') 

	_cQry := " SELECT Z0U_CODIGO  " + CRLF 
	_cQry += " 		, Z0U_NOME " + CRLF 
	_cQry += " 	FROM "+RetSqlName("Z0U")+"  " + CRLF 
	_cQry += " 	WHERE D_E_L_E_T_ = '' " + CRLF 
			
	/* _cQry := "	SELECT RA_MAT" + CRLF
	_cQry += "	   	 	,RA_NOME" + CRLF
	_cQry += "		  --,RA_CARGO" + CRLF
	_cQry += "		  --,QB_DEPTO" + CRLF
	_cQry += "		  --,QB_DESCRIC" + CRLF
	_cQry += "		  --,RA_DEMISSA" + CRLF
	_cQry += "		  --,Q3_DESCSUM" + CRLF
	_cQry += "	  FROM "+RetSqlName("SRA")+" " + CRLF
	_cQry += "	  LEFT JOIN "+RetSqlName("SQB")+" SQB ON RA_DEPTO = QB_DEPTO" + CRLF
	_cQry += "	  AND QB_DEPTO = RA_DEPTO" + CRLF
	_cQry += "	  JOIN "+RetSqlName("SQ3")+" SQ3 ON RA_CARGO = Q3_CARGO" + CRLF
	_cQry += "	  WHERE RA_FILIAL = '" + FWxFilial("SRA") + "'" + CRLF
	_cQry += "	  AND RA_DEMISSA = ' '" + CRLF
	_cQry += "	  AND RA_DEPTO IN ('000000003','000000011')" + CRLF
	_cQry += "	  AND RA_CARGO IN ('002','018','061','026','034','041','068')" + CRLF
	_cQry += "	  ORDER BY 2" + CRLF */

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAlias,.T.,.T.)

	While !(cAlias)->(EOF())
        aAdd(aCpos,{(cAlias)->Z0U_CODIGO,;
				    (cAlias)->Z0U_NOME})
        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())

	If Len(aCpos) < 1
        aAdd(aCpos,{" "," "})
    EndIf

	DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Funcionarios" FROM 0,0 TO 240,500 PIXEL

	@ 0,0 LISTBOX oLbx FIELDS HEADER 'Matricula.',;
									 'Nome' SIZE 250,120 OF oDlg PIXEL

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
		//oModelDad:LoadValue("ZAV_NOME", aRet[2])
		lRet := .T.
    EndIf

	IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
	    MemoWrite(StrTran(cArquivo,".xml","")+"SRA_"+cValToChar(dDataBase)+".sql" , _cQry)
    ENDIF

//	oView:Refresh()
	RestArea(aArea)

RETURN _cFunc

User Function ESTI06P()
    Local aArea      := GetArea()
    Local lRet	 	 := .F.
    Local oView 	 := FWViewActive()
    Local oModelDad  := FWModelActive()
	Local oModelGrid := oModelDad:GetModel('ZAVDETAIL')

    if !Empty(oModelGrid:GetValue("ZAV_CCOD"))
        DbSelectArea("ZCP")
        ZCP->(DbSetOrder(1))

    // nNota := oModelGrid:GetValue('ZAV_NOTA')

        IF ZCP->(DbSeek( xFilial("ZCP") +;
                    oModelGrid:GetValue('ZAV_CCOD') ))
            
            if oModelGrid:GetValue("ZAV_NOTA") >= ZCP->ZCP_NOTMIN .AND. oModelGrid:GetValue("ZAV_NOTA") <= ZCP->ZCP_NOTMAX
                lRet := .T.
            ENDIF
        ENDIF
        
        oView:Refresh()
        RestArea(aArea)
    else
        lRet := .F.
		
        Help( ,, 'Help',, 'Preencha o campo: Código Critério!.' + CRLF +; 
            'ZAV_CCOD ' , 1, 0 )
    ENDIF
RETURN lRet

User Function VAI06PLn()
	Local aArea 		:= GetArea()
	Local oView    		:= FWViewActive()
	Local oModel	 	:= oView:GetModel()
	Local oModelDad 	:= oModel:GetModel("ZAVMASTER")
	Local oModelGrid 	:= oModel:GetModel("ZAVDETAIL")
	Local nOpc     	 	:= oModel:GetOperation()
	Local _cQry  		:= ""
    Local cAlias 		:= GetNextAlias()
	Local cCriterio 	:= ''
	
	oModelGrid:ClearData()
	oModelGrid:SetNoInsertLine(.F.)
	oModelGrid:SetNoDeleteLine(.F.)

	If nOpc == MODEL_OPERATION_INSERT 

		cCriterio := Posicione("Z0U",1,FWxFilial("Z0U")+oModelDad:GetValue("ZAV_MAT"),"Z0U_TIPO")
		
		_cQry := " select ZCP_CODIGO" + CRLF
		_cQry += "		  ,ZCP_DESC" + CRLF
		_cQry += "		  from " + RetSqlName("ZCP") + "" + CRLF
		_cQry += "		  where ZCP_FILIAL = '" + FWxFilial("ZCP") + "'" + CRLF
		_cQry += "		  and ZCP_TIPOCR IN ('"+IIF(cCriterio=='P','C','T')+"','A') " + CRLF
		_cQry += "		  and D_E_L_E_T_ = ' ' " + CRLF

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAlias,.T.,.T.)

		While !(cAlias)->(EOF())
/* 			aAdd(aCpos,{(cAlias)->ZCP_CODIGO,;
						(cAlias)->ZCP_DESC}) */
			oModelGrid:AddLine()
			oModelGrid:SetValue("ZAV_CCOD" , (cAlias)->ZCP_CODIGO)
			oModelGrid:SetValue("ZAV_CDESC", (cAlias)->ZCP_DESC)
			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())

/* 		If Len(aCpos) < 1
			aAdd(aCpos,{"",""})
		EndIf */

/* 		for nI := 1 to Len(aCpos)
			oModelGrid:AddLine()
			oModelGrid:SetValue("ZAV_CCOD" , aCpos[nI][1])
			oModelGrid:SetValue("ZAV_CDESC", aCpos[nI][2])
		NEXT nI */
		oModelGrid:SetNoInsertLine(.T.)
		oModelGrid:SetNoDeleteLine(.T.)
	EndIf

	oModelGrid:GoLine(1)	
	oView:Refresh()
	RestArea(aArea)
RETURN 

Static Function ValidaNota()
	Local lRet	:= .t.
	Local oView    		:= FWViewActive()
	Local oModel	 	:= oView:GetModel()
	Local oModelGrid 	:= oModel:GetModel("ZAVDETAIL")
	Local nL
	Local nI

	nL := oModelGrid:GetQtdLine()   	

	for nI := 1 to nL
		oModelGrid:GoLine(nI)
			If(Empty(oModelGrid:GetValue('ZAV_NOTA')))
				lRet := .F.
				exit 
			ENDIF
	next nI

return lRet
