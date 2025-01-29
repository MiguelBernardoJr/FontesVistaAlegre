#include "topconn.ch"
#include "protheus.ch" 
#include "rwmake.ch"
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Operador Pá Fabrica por dia" 

/* Igor Oliveira 06-2022 
    Cadastrar Operadores de Maquinas por dia
*/

User Function VAESTI07()
    Local aArea   		:= GetArea()
    Local oModel  		:= NIL
	Local cFunBkp 		:= FunName()  
    Private _cFunc  	:= CriaVar('ZOP_MAT', .F.)
    Private cArquivo 	 	:= "C:\totvs_relatorios\"

    SetFunName("VAESTI07")

    oModel := FWMBrowse():New()
	oModel:SetAlias( "ZOP" )   
	oModel:SetDescription( cTitulo )
	oModel:Activate()
	
    SetFunName(cFunBkp)
	RestArea(aArea)
Return NIL  
Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' 		ACTION 'VIEWDEF.VAESTI07' 			OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    		ACTION 'VIEWDEF.VAESTI07' 			OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    		ACTION 'VIEWDEF.VAESTI07' 			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    		ACTION 'VIEWDEF.VAESTI07' 			OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Copiar'    		ACTION 'VIEWDEF.VAESTI07' 			OPERATION 9						 ACCESS 0 //OPERATION 5
Return aRot

Static Function ModelDef()
	Local oStZOP   := FWFormStruct(1, 'ZOP')
	Local bVldPos  := {|| zVldZOPTab()}
	//Criando o FormModel, adicionando o Cabeçalho e Grid
	oModel := MPFormModel():New("ESTI07M",/*Pre-Validacao*/, bVldPos /*Pos-Validacao*/,/* bVldCom Commit*/,/*Cancel*/)

	oModel:AddFields("ZOPMASTER",/*cOwner*/ ,oStZOP, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )

	oModel:SetPrimaryKey({ })

    oModel:GetModel("ZOPMASTER"):SetFldNoCopy({'ZOP_FILIAL', 'ZOP_COD'})
    
	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZOPMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()
	Local oModel     := FWLoadModel("VAESTI07")
    Local oStZOP     := FWFormStruct(2, "ZOP")
	Local oView      := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_ZOP" , oStZOP  , "ZOPMASTER")
	//Habilitando título
    
	
    oView:EnableTitleView('VIEW_ZOP', cTitulo)

    oView:CreateHorizontalBox("SCREEN", 100)
	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk( { |oView| .T. } )
	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZOP","SCREEN")
Return oView

Static Function zVldZOPTab()
	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local nOpc      := oModel:GetOperation()
	Local lRet      := .T.

	//Se for InclusÃ£o
	If nOpc == MODEL_OPERATION_INSERT

/* 		if Empty(oModel:GetValue("ZOPMASTER", "ZOP_COD"))
			VaGetX8('ZOP', 'ZOP_COD')
		ENDIF
		 */
		DbSelectArea('ZOP')
		ZOP->(DbSetOrder(1)) 

		//Se conseguir posicionar, tabela jÃ¡ existe
		If ZOP->(DbSeek( xFilial("ZOP") +;
				oModel:GetValue('ZOPMASTER', 'ZOP_COD')))
               // dToS(oModel:GetValue('ZOPMASTER', 'ZOP_DATA'))))
			Aviso('Atenção', 'Esse código de tabela já existe!', {'OK'}, 02)
			lRet := .F.
		EndIf

	EndIf

	RestArea(aArea)
Return lRet



User Function FunEst7()
    Local aArea			:= GetArea()
	Local oDlg, oLbx
    Local aCpos  		:= {}
    Local aRet   		:= {}
    Local _cQry  		:= ""
    Local cAlias 		:= GetNextAlias()
    Local lRet   		:= .F.
/* 	Local oView		 	:= FWViewActive()
	Local oModel      	:= FWModelActive() */
	//Local oModelDad 	:= oModel:GetModel('ZAVMASTER') 

	_cQry := " SELECT   Z0U_CODIGO, " + CRLF
	_cQry += "          Z0U_NOME " + CRLF
    _cQry += " FROM " + RetSqlName("Z0U") + " " + CRLF
    _cQry += " WHERE Z0U_FILIAL = '" + FWxFilial("Z0U") + "'  " + CRLF
    _cQry += " AND D_E_L_E_T_ = ' ' " + CRLF
    _cQry += " ORDER BY Z0U_CODIGO " + CRLF

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

	@ 0,0 LISTBOX oLbx FIELDS HEADER 'Código',;
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

RETURN lRet
