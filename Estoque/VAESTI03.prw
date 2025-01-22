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
    Private _cLoteS		:= CriaVar('ZMS_LOTE'  	, .F.)
    Private _cProd		:= CriaVar('ZMS_PRDBOV'  	, .F.)
    Private _cCurral	:= CriaVar('ZMS_CURRAL' , .F.)
    Private _cLocal		:= CriaVar('ZMS_LOCAL'  , .F.)
    Private _cRaca		:= CriaVar('ZMS_RACA'  	, .F.)
    Private _cSexo		:= CriaVar('ZMS_SEXO'  	, .F.)
    Private _cDesc		:= CriaVar('ZMS_DESC'  	, .F.)
	Private cPath       := "C:\TOTVS_RELATORIOS\"

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
	//Adicionando opÃ§Ãµes
	ADD OPTION aRot TITLE 'Visualizar' 		ACTION 'VIEWDEF.VAESTI03' 			OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    		ACTION 'VIEWDEF.VAESTI03' 			OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    		ACTION 'VIEWDEF.VAESTI03' 			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    		ACTION 'VIEWDEF.VAESTI03' 			OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	//ADD OPTION aRot TITLE 'Copiar'    		ACTION 'VIEWDEF.VAFATI01' 			OPERATION 9						 ACCESS 0 //OPERATION 5
Return aRot

Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStPai   	:= FWFormStruct(1, 'ZMS') // FWFormModelStruct():New()
	Local oStFilho 	:= FWFormStruct(1, 'ZMS')
	Local bVldPos  	:= {|| u_zVldZMSTab()}
	Local bVldCom  	:= {|| u_zSaveZMSMd2()  }
	Local aZMSRel  	:= {}

	//Criando o FormModel, adicionando o CabeÃ§alho e Grid
	oModel := MPFormModel():New("ESTI03M",/*Pre-Validacao*/, bVldPos /*Pos-Validacao*/, bVldCom /*Commit*/,/*Cancel*/)

	oModel:AddFields("ZMSMASTER",/*cOwner*/ ,oStPai  )

	//oModel:AddGrid('ZMSDETAIL','ZMSMASTER',oStFilho/* , bZMSLinePr */)
	oModel:AddGrid('ZMSDETAIL','ZMSMASTER',oStFilho)

	//Adiciona o relacionamento de Filho, Pai
	aAdd(aZMSRel, {'ZMS_FILIAL', 'Iif(!INCLUI, ZMS->ZMS_FILIAL, FWxFilial("ZMS"))'} )
	aAdd(aZMSRel, {'ZMS_COD'   , 'Iif(!INCLUI, ZMS->ZMS_COD   , "")'} )
	aAdd(aZMSRel, {'ZMS_RESPON'   , 'Iif(!INCLUI, ZMS->ZMS_RESPON   , "")'} )
	aAdd(aZMSRel, {'ZMS_DATA'  , 'Iif(!INCLUI, ZMS->ZMS_DATA  , sToD(""))'} )
	
	//Criando o relacionamento
	oModel:SetRelation('ZMSDETAIL', aZMSRel, ZMS->(IndexKey(2)))

	oModel:SetPrimaryKey({ })

	//Setando o campo Ãºnico da grid para nÃ£o ter repetiÃ§Ã£o
	oModel:GetModel('ZMSDETAIL'):SetUniqueLine({ "ZMS_FILIAL","ZMS_COD", "ZMS_ITEM" })

//	oStFilho:SetProperty("ZMS_LOTE", MODEL_FIELD_WHEN, 'INCLUI')

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
	oView:CreateHorizontalBox('CABEC', 25)
	oView:CreateHorizontalBox('GRID' , 75)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB'  ,'CABEC')
	oView:SetOwnerView('VIEW_ITENS','GRID' )

	//Habilitando tÃ­tulo
	oView:EnableTitleView('VIEW_CAB',"Cabeçalho - "+cTitulo+"")
	oView:EnableTitleView('VIEW_ITENS',"Itens - "+cTitulo+"")

	//Auto incremento para o campo ZMS_ITEM
	oView:AddIncrementField( 'VIEW_ITENS', 'ZMS_ITEM' )

	//Tratativa padrÃ£o para fechar a tela
	oView:SetCloseOnOk( { |oView| .T. } )
	
	oView:AddUserButton( 'Cadastrar Motivo','', {|oView| U_VAESTI04()} )

	oView:AddUserButton( 'Cadastrar Morte','', {|oView| Morte()} )

//	oStFilho:SetProperty("ZMS_LOTE", MVC_VIEW_CANCHANGE, {|oView, oModel| X3VI3LP()})
//	SetKey(K_CTRL_DOWN, {|oModel, oView|  CpyLine()})

	//Remove os campos de Filial e Tabela da Grid
	oStPai:RemoveField('ZMS_LOTE')
	oStPai:RemoveField('ZMS_PRDBOV')
	oStPai:RemoveField('ZMS_DESC')
	oStPai:RemoveField('ZMS_RACA')
	oStPai:RemoveField('ZMS_SEXO')
//	oStPai:RemoveField('ZMS_DMOT')
	oStPai:RemoveField('ZMS_DMED')
	oStPai:RemoveField('ZMS_MEDIC')
	oStPai:RemoveField('ZMS_DOSE')
	//oStPai:RemoveField('ZMS_OBS')
	//oStPai:RemoveField('ZMS_RESPON')
	//oStPai:RemoveField('ZMS_MOTIVO')
	oStPai:RemoveField('ZMS_ITEM')
	oStPai:RemoveField('ZMS_CURRAL')
	//oStPai:RemoveField('ZMS_NOME')
	oStPai:RemoveField('ZMS_D3DOC')
	oStPai:RemoveField('ZMS_D3REC')
	oStPai:RemoveField('ZMS_LOCAL')

    oStFilho:RemoveField('ZMS_FILIAL')

	oStFilho:RemoveField('ZMS_TIPO')
    oStFilho:RemoveField('ZMS_COD')
    oStFilho:RemoveField('ZMS_DATA')
    oStFilho:RemoveField('ZMS_RESPON')
    oStFilho:RemoveField('ZMS_NOME')
    oStFilho:RemoveField('ZMS_MOTIVO')
    oStFilho:RemoveField('ZMS_DMOT')
    oStFilho:RemoveField('ZMS_OBS')
	

Return oView

User Function zVldZMSTab()
	Local aArea     := GetArea()
	local oView     := FWViewActive()
	Local oModel    := FWModelActive()
	Local nOpc      := oModel:GetOperation()
	Local lRet      := .T.

	//Se for InclusÃ£o
	If nOpc == MODEL_OPERATION_INSERT
		if Empty(oModel:GetValue("ZMSMASTER", "ZMS_COD"))
			VaGetX8('ZMS', 'ZMS_COD')
		ENDIF
		
		DbSelectArea('ZMS')
		ZMS->(DbSetOrder(1)) //ZDM_FILIAL + ZDM_CODIGO + ZDM_CODIGO

		//Se conseguir posicionar, tabela jÃ¡ existe
		If ZMS->(DbSeek( xFilial("ZMS") +;
				oModel:GetValue('ZMSMASTER', 'ZMS_COD')))
               // dToS(oModelDad:GetValue('ZMSMASTER', 'ZMS_DATA'))))
			Aviso('AtenÃ§Ã£o', 'Esse código de tabela já existe!', {'OK'}, 02)
			lRet := .F.
		EndIf

	EndIf

	If Empty(oModel:GetValue("ZMSMASTER","ZMS_DATA"))
		oModel:SetValue("ZMSMASTER","ZMS_DATA", dDataBase)
	EndIf
	RestArea(aArea)

    oView:Refresh()

Return lRet

User Function zSaveZMSMd2()
	Local aArea      	:= GetArea()
	Local lRet       	:= .T.
	Local oModel	  	:= FWModelActive()
	Local oModelDad 	:= oModel:GetModel('ZMSMASTER')
	Local oModelGrid 	:= oModel:GetModel('ZMSDETAIL')
	Local nOpc       	:= oModel:GetOperation()
	Local nI         	:= 0
	Local lRecLock   	:= .T.
	Local nLinhas	 	:= oModelGrid:GetQtdLine()

	DbSelectArea('ZMS')
	ZMS->(DbSetOrder(2))
	

	//Se for InclusÃ£o
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE

		//Cria o registro na tabela 00 (CabeÃ§alho de tabelas)
		if !Empty(oModelDad:GetValue("ZMS_TIPO")) 

			if oModelDad:GetValue("ZMS_TIPO") == "P" .or. ValLinMt()
				//Percorre as linhas da grid
				For nI := 1 To nLinhas
					
					oModelGrid:GoLine(nI)
					If !oModelGrid:isDeleted()
						RecLock('ZMS', lRecLock := !DbSeek( xFilial("ZMS") +;
													oModelDad:GetValue('ZMS_COD') +;
													dToS(oModelDad:GetValue('ZMS_DATA'))+;
													oModelGrid:GetValue('ZMS_ITEM')))

							ZMS->ZMS_FILIAL     := xFilial("ZMS")
							ZMS->ZMS_COD 	    := oModelDad:GetValue('ZMS_COD') 
							ZMS->ZMS_DATA   	:= oModelDad:GetValue('ZMS_DATA')	
							ZMS->ZMS_TIPO       := oModelDad:GetValue('ZMS_TIPO')
							ZMS->ZMS_MOTIVO     := oModelDad:GetValue('ZMS_MOTIVO')
							ZMS->ZMS_RESPON     := oModelDad:GetValue('ZMS_RESPON')
							ZMS->ZMS_OBS        := oModelDad:GetValue('ZMS_OBS' )
							ZMS->ZMS_ITEM   	:= oModelGrid:GetValue('ZMS_ITEM')
							ZMS->ZMS_LOTE     	:= oModelGrid:GetValue('ZMS_LOTE')
							ZMS->ZMS_CURRAL   	:= oModelGrid:GetValue('ZMS_CURRAL') 
							ZMS->ZMS_LOCAL   	:= oModelGrid:GetValue('ZMS_LOCAL') 
							ZMS->ZMS_PRDBOV   	:= oModelGrid:GetValue('ZMS_PRDBOV') 
							ZMS->ZMS_RACA     	:= oModelGrid:GetValue('ZMS_RACA')
							ZMS->ZMS_SEXO     	:= oModelGrid:GetValue('ZMS_SEXO')
							ZMS->ZMS_DESC     	:= oModelGrid:GetValue('ZMS_DESC')
							ZMS->ZMS_MEDIC      := oModelGrid:GetValue('ZMS_MEDIC')
							ZMS->ZMS_DOSE       := oModelGrid:GetValue('ZMS_DOSE')
							ZMS->ZMS_D3DOC      := oModelGrid:GetValue('ZMS_D3DOC')
							ZMS->ZMS_D3REC      := oModelGrid:GetValue('ZMS_D3REC')

						ZMS->(MsUnlock())
					Else		
						If ZMS->(DbSeek( xFilial("ZMS") +;
								oModelDad:GetValue('ZMS_COD') +;
								dToS(oModelDad:GetValue('ZMS_DATA'))+;
								oModelGrid:GetValue('ZMS_ITEM')))

							RecLock('ZMS', .F.)
								ZMS->(DbDelete())
							ZMS->(MsUnlock())
						EndIf 
					EndIf
				Next nI
			else
				lRet := .F. 
				if oModelDad:GetValue("ZMS_TIPO") $ "MA"
					oModel:SetErrorMessage("","","","","HELP", 'Tipo invalido!', "Para os Tipos [M] e [A] informe apenas 1 (Uma) linha!")
				ENDIF
			ENDIF
		else 
			lRet := .F. 
			oModel:SetErrorMessage("","","","","HELP", 'CAMPO TIPO VAZIO', "Informe o Tipo!")
		ENDIF 
	//Se for ExclusÃ£o
	ElseIf nOpc == MODEL_OPERATION_DELETE	
		For nI := 1 To oModelGrid:GetQtdLine()
			oModelGrid:GoLine(nI)
			//Se conseguir posicionar, exclui o registro
			If ZMS->(DbSeek( xFilial("ZMS") +;
						oModelDad:GetValue('ZMS_COD') +;
                        dToS(oModelDad:GetValue('ZMS_DATA'))+;
						oModelGrid:GetValue('ZMS_ITEM')))

				RecLock('ZMS', .F.)
					ZMS->(DbDelete())
				ZMS->(MsUnlock())
			EndIf
		Next nI
	EndIf

	//Se nÃ£o for inclusÃ£o, volta o INCLUI para .T. (bug ao utilizar a ExclusÃ£o, antes da InclusÃ£o)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

	RestArea(aArea)
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
	Local oModelDad  	:= FWModelActive()
	Local oModelGrid 	:= oModelDad:GetModel('ZMSDETAIL') 

	_cQry := "  SELECT RA_MAT" + CRLF
	_cQry += "   	 ,RA_NOME" + CRLF
	_cQry += "  FROM SRA010 " + CRLF
	_cQry += "  JOIN SQB010 SQB ON RA_DEPTO = QB_DEPTO" + CRLF
	_cQry += "  AND RA_DEPTO = '000000004'" + CRLF
	_cQry += "  WHERE RA_DEMISSA = ''" + CRLF
	_cQry += "  AND RA_FILIAL = '01'" + CRLF
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
		 _cFunc := aRet[1]// oModelGrid:LoadValue("ZMS_RESPON", aRet[1])
		oModelGrid:LoadValue("ZMS_NOME",   aRet[2])
		lRet := .T.
    EndIf

	IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
	    MemoWrite(StrTran(cArquivo,".xml","")+"SR4_"+cValToChar(dDataBase)+".sql" , _cQry)
    ENDIF

	oView:Refresh()
	RestArea(aArea)

RETURN lRet

User Function BovEstI4()
    Local aArea			:= GetArea()
	Local aAreaSB1 		:= SB1->(GetArea())
    Local _cQry  		:= ""
    Local lRet   		:= .F.
	/* Local oView		 	:= FWViewActive()
	Local oModelDad  	:= FWModelActive()
	Local oModelGrid 	:= oModelDad:GetModel('ZMSDETAIL')  */

	if Type("uRetorno") == 'U' 
		public uRetorno
	endif
	uRetorno := ''

	_cQry := " select B8_PRODUTO " + CRLF
	_cQry += " 				 , B8_LOTECTL " + CRLF
	_cQry += " 				 , B8_X_CURRA " + CRLF
	_cQry += " 				 , B8_LOCAL " + CRLF
	_cQry += " 				 , B1_DESC " + CRLF
	_cQry += " 				 , B1_XRACA " + CRLF
	_cQry += " 				 , B1_X_SEXO " + CRLF
	_cQry += " 				 , B8_SALDO " + CRLF
	_cQry += " 				 , SB8.R_E_C_N_O_ SB8RECNO " + CRLF
	_cQry += " 			from " +RetSqlName("SB8") + " SB8 " + CRLF
	_cQry += " 			LEFT JOIN " +RetSqlName("SB1") + " SB1 ON B1_COD = B8_PRODUTO " + CRLF
	//_cQry += " 			where B8_DATA >= DATEADD(DAY, -120, '20220424')  " + CRLF
	_cQry += "			where B8_FILIAL = '" +FwXFilial("SB8") + "'" + CRLF
	_cQry += "			AND B8_SALDO > 0  " + CRLF
	_cQry += " 			and SB8.D_E_L_E_T_ = '' " + CRLF
	_cQry += " 			ORDER BY B8_DATA  " + CRLF

    if u_F3Qry( _cQry, 'PRODUTO', 'SB8RECNO', @uRetorno,, { "B8_LOTECTL", "B8_PRODUTO" } )
        SB8->(DbGoto( uRetorno ))
		_cLoteS 	:= SB8->B8_LOTECTL
		_cCurral 	:= SB8->B8_X_CURRA
		_cLocal		:= SB8->B8_LOCAL
		_cProd		:= SB8->B8_PRODUTO
		_cRaca		:= SB1->B1_XRACA
		_cSexo 		:= SB1->B1_X_SEXO
		_cDesc		:= SB1->B1_DESC
	
        lRet := .t.
    endif

if aArea[1] <> "SB8"
	RestArea( aAreaSB1 )
    RestArea( aArea )
endif

RETURN lRet

/* 	Igor Oliveira - 05/2022
	Deu B.O no SX8Num pq mudou o tamanho do campo 
	Função incremental para ZMS_COD */
Static Function VaGetX8(cAlias, cCampo)
	Local aArea 	:= GetArea() 
	Local oView		:= FWViewActive()
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

	oView:Refresh()

	__TMP->(DbCloseArea())
	RestArea(aArea)

RETURN lRet

Static Function Morte()
	Local aArea 	 	:= GetArea() 
	Local oModel  	 	:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelDad 	:= oModel:GetModel("ZMSMASTER")
	Local oModelGrid 	:= oModel:GetModel("ZMSDETAIL")
	local nI 
	Local cTM 			:= GetMV("MV_TMMORTE")
	Local lRet 			:= .T.
	Local dData	
	Local cLocal		:= ''	
	Local _aCab1	 	:= {}
	Local _aItem 		:= {}
	Local _atotitem		:= {}
	Local cDoc			:= ''
	Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
	Private lMsErroAuto := .f. //necessario a criacao

	DbSelectArea("SD3")
	SD3->(DbSetOrder(1))

	DbSelectArea("ZSM")
	ZSM->(DbSetOrder(1))

	DbSelectArea("SB8")
	SB8->(DbSetOrder(7))
	
	if oModelDad:GetValue("ZMS_TIPO")  != 'P' .and. ValLinMt()

		if !Empty(oModelDad:GetValue("ZMS_DATA"))
			dData := oModelDad:GetValue("ZMS_DATA")
		else 
			dData := dDataBase
		ENDIF

		cDoc := NextNumero("SD3",2,"D3_DOC",.T.)

		For nI := 1 to oModelGrid:GetQtdLine()

			oModelGrid:GoLine(nI)
			if Empty(oModelGrid:GetValue("ZMS_D3DOC"))  
				
					//cObs :=  MSMM(, TamSx3("ZMS_OBS")[1],, &(ZMS->ZMS_OBS), 3, /* TamSize */,/* Wrap */, "SD3","D3_OBSERVA")

					ZSM->(DBSeek(FwXFilial("ZMS")+oModelGrid:GetValue("ZMS_MOTIVO")))
						cMtObs := ZSM->ZSM_DESC

					SB8->(DBSeek(FwXFilial("ZMS")+oModelGrid:GetValue("ZMS_LOTE")+oModelGrid:GetValue("ZMS_CURRAL")))
						cLocal := oModelGrid:GetValue("ZMS_CURRAL")

					_aCab1 := { {"D3_FILIAL"	, xFilial("ZMS"), NIL},;
								{"D3_DOC" 		, cDoc			, NIL},;
								{"D3_TM" 		, cTM	 		, NIL},;
								{"D3_CC" 		, ""			, NIL},;
								{"D3_EMISSAO" 	, ddatabase		, NIL}}

					_aItem := { {"D3_COD" 		, oModelGrid:GetValue("ZMS_PRDBOV")								 	,NIL},;
								{"D3_UM" 		, "UN" 															 	,NIL},; 
								{"D3_X_QTD" 	, 1 															 	,NIL},;
								{"D3_QUANT" 	, 1 															 	,NIL},;
								{"D3_CUSTO1" 	, 0.01															 	,NIL},;
								{"D3_LOTECTL" 	, oModelGrid:GetValue("ZMS_LOTE")								 	,NIL},;
								{"D3_X_OBS"    	, AllTrim(cMtObs) + " " + AllTrim(oModelGrid:GetValue("ZMS_OBS"))  	,NIL},;
								{"D3_OBSERVA"	, cMtObs      													 	,NIL}}
					
					aAdd(_atotitem,_aItem)		
				
			else
				MsgAlert("Movimentação já realizada anteriormente!!!" + CRLF +;
					"Nº do Doc: [ "+cDoc+" ]", "Atenção!!!")
			EndIf
		NEXT
		
		if len(_atotitem) >= 1
			MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)
			
			If lMsErroAuto 
				Mostraerro()
				DisarmTransaction()
			else 
			
			SD3->(DbSetOrder(2))
				nI := 1 
				IF (SD3->(DBSeek(FWxFilial("ZMS") + cDoc)))
					while (SD3->D3_DOC == cDoc)
						oModelGrid:GoLine(nI)
						oModelGrid:SetValue("ZMS_D3DOC", cDoc)
						oModelGrid:SetValue("ZMS_D3REC", SD3->(Recno()))
					
						MsgAlert("Movimentação realizada!!!" + CRLF +;
								"Nº do Doc: [ "+cDoc+" ]" + CRLF +;
								"Linha [ "+StrZero(nI,TamSX3("ZMS_ITEM")[1])+" ]", "Atenção!!")
						
						SD3->(DBSkip())
						nI++
					END
				ENDIF
			ENDIF	
		else
			MsgAlert("Não será gerado nenhuma movimentação, pois não foram informadas linhas válidas", "Atenção!!!")	
		ENDIF
	else 
		lRet := .F.
		Help( ,, 'Help',, 'Campo Tipo inválido para esta operação!!.' + CRLF +; 
			'Para prosseguir preencha o campo com o Tipo [ M ]' + CRLF +;
            'ZMS_TIPO' , 1, 0 )
	ENDIF

	ZSM->(DBCloseArea())
	SD3->(DBCloseArea())
	
	oView:Refresh()

	RestArea(aArea)
RETURN lRet
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
		cRet := Iif(Empty(ZMS->ZMS_MEDIC),"", Posicione("SB1", 1, xFilial('SB1')+ZMS->ZMS_MEDIC, 'B1_DESC'))
	ENDIF
	RestArea(aArea)
return cRet
	
User Function INIMEDV3()
//User Function RelMeV3()
return Iif(Empty(ZMS->ZMS_MEDIC),"", Posicione("SB1", 1, xFilial('SB1')+ZMS->ZMS_MEDIC, 'B1_DESC'))

User Function VMdMV3()
	Local oModel  	 	:= FWModelActive()
	Local oModelDad 	:= oModel:GetModel("ZMSMASTER")
	Local lRet 			:= .F.

	if oModelDad:GetValue("ZMS_TIPO") == 'P'
		lRet := .T.
	else
		oModel:SetErrorMessage("","","","","HELP", 'Tipo invalido!', "Informe o tipo [ P ]")
	ENDIF

return lRet

User Function VLDTPV3()
	Local oModel  	 	:= FWModelActive()
	Local oModelDad 	:= oModel:GetModel("ZMSMASTER")
	Local oModelGrid 	:= oModel:GetModel("ZMSDETAIL")
	Local lRet 			:= .T.
	Local nLinhas		:= oModelGrid:GetQtdLine()
	Local nLDel			:= 0
	Local nI 

	for nI := 1 to nLinhas 
		oModelGrid:GoLine(nI)
		if oModelGrid:isDeleted()
			nLDel++
		ENDIF
	NEXT
	if oModelDad:GetValue("ZMS_TIPO") == "M" .OR. oModelDad:GetValue("ZMS_TIPO") == "A"
		if (nLinhas - nLDel )> 1
			lRet := .F.
			oModel:SetErrorMessage("","","","","HELP", 'Tipo invalido!', "Para os Tipos [M] e [A] informe apenas 1 (Uma) linha!")
		else
			if !Empty(oModelGrid:GetValue("ZMS_MEDIC"))
				lRet := .F.
				oModel:SetErrorMessage("","","","","HELP", 'Tipo invalido!', "Tipo não pode ser [M] ou [A] se houver algum medicamento preenchido!")
			endIf
		ENDIF 
	ENDIF 
RETURN lRet
/* Igor Oliveira 06-2022
	Copiar campo Real para linha de baixo */
User Function FV3GLOT()
	Local oModel  	 	:= FWModelActive()
	Local oModelGrid 	:= oModel:GetModel('ZMSDETAIL')
	Local nLinha 	 	:= oModelGrid:GetQtdLine()
	Local cRet   		:= ""
	Local cCampo 	  	:= SubS( ReadVar(), At(">", ReadVar())+1 )

	if nLinha == 1 .and. Empty(oModelGrid:GetValue(cCampo)) 
		cRet := ""
	elseif nLinha == 1 .and. !Empty(oModelGrid:GetValue(cCampo)) 
		oModelGrid:Goline(nLinha)
		cRet 	:= oModelGrid:GetValue(cCampo)
	elseif nLinha > 1 
		oModelGrid:Goline(nLinha-1)
		cRet := oModelGrid:GetValue(cCampo)
	ENDIf
	
Return cRet

/* Igor Oliveira 06-2022
	Copiar campo Virtual com posicionamento para linha de baixo */
//USER FUNCTION RVI03BV(cAlias, cIndex,  cCamp, cCampPosi)
USER FUNCTION RVI03BV()
	Local oModel  	 	:= FWModelActive()
	Local oModelGrid 	:= oModel:GetModel('ZMSDETAIL')
	Local nLinha 	 	:= oModelGrid:GetQtdLine()
	Local cRet   		:= ""
	Local cCampo 	  	:= SubS( ReadVar(), At(">", ReadVar())+1 )
	
	if cCampo $ "ZMS_PRDBOV-ZMS_CURRAL-ZMS_RACA-ZMS_SEXO-ZMS_DESC-ZMS_NOME-ZMS_LOCAL"
		if nLinha == 1 .and. Empty(oModelGrid:GetValue(cCampo)) 
			//cRet := IIF(!INCLUI,POSICIONE(cAlias, cIndex, XFILIAL(cAlias)+ZMS->cCamp, cCampPosi),"")
			cRet := ""
		elseif nLinha == 1 .and. !Empty(oModelGrid:GetValue(cCampo)) 
			oModelGrid:Goline(nLinha)
			cRet 	:= oModelGrid:GetValue(cCampo) 
		elseif nLinha > 1 
			oModelGrid:Goline(nLinha-1)
			cRet := oModelGrid:GetValue(cCampo)	
		ENDIf
	ENDIF
RETURN cRet
/* Igor Oliveira 06-2022
	Validae se lote e produto são iguais na grid */
USER Function X3VI3LP()
	Local oModel  	 	:= FWModelActive()
	Local oModelGrid 	:= oModel:GetModel('ZMSDETAIL')
	Local nLinha 	 	:= oModelGrid:GetQtdLine()
	Local cCampo 	  	:= SubS( ReadVar(), At(">", ReadVar())+1 )
	Local lRet 			:= .T.
	Local cBov 			:= ''
	Local cLote 		:= ''

	IF cCampo == "ZMS_PRDBOV"
		if nLinha > 1 
			oModelGrid:GoLine(nLinha - 1 )
			cBov := oModelGrid:GetValue("ZMS_PRDBOV")
			cLote := oModelGrid:GetValue("ZMS_LOTE")
			oModelGrid:GoLine(nLinha)
			if oModelGrid:GetValue("ZMS_PRDBOV") != cBov .or. oModelGrid:GetValue("ZMS_LOTE") != cLote  
				lRet := .F. 
				oModel:SetErrorMessage("","","","","HELP", 'PRODUTO INVÁLIDO!', "Informe apenas um produto por cadastro!!")
			ENDIF
		ENDIF
	ENDIF

Return lRet

Static Function ValLinMt()
	Local oModel  	 	:= FWModelActive()
	Local oModelDad 	:= oModel:GetModel('ZMSMASTER')
	Local oModelGrid 	:= oModel:GetModel('ZMSDETAIL')
	Local nLinhas 	 	:= oModelGrid:GetQtdLine()
	Local lRet 			:= .F.
	Local nLDel			:= 0
	Local nI         	:= 0

	for nI := 1 to nLinhas 
		oModelGrid:GoLine(nI)
		if oModelGrid:isDeleted()
			nLDel++
		ENDIF
	NEXT

	if oModelDad:GetValue("ZMS_TIPO") $ "MA" .and. (nLinhas-nLDel) == 1
		lRet := .T.
	ENDIF

 Return lRet
