#include "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

User Function VATST01()
	Local cPrgRot       := "VAPCPA09"
    Local cQry          := ""
    Local cAlias        := ""
	Local cFunBkp 		:= FunName()  

    Private lShwZer   := .F.
    Private lShwGer   := .T.
    Private nOpcRotas := 1
    Private aDadSel   := {}
    Private aLinAlf   := {}
    Private aParRet   := {}
    Private aTik    := {LoadBitmap( GetResources(), "LBTIK" ), LoadBitmap( GetResources(), "LBNO" )}
    Private __dDtPergunte := StoD("")
	Private aDados		:= {}
	Private aCurrais	:= {}

	Private cAliaCon  := ""
	Private cAliasLin := ""
	Private cAliasCur := ""
	Private cAliasRac := ""
	Private oTmpCon := nil
	Private oTmpLin := nil
	Private oTmpCur := nil
	Private oTmpRac := nil

    aDadSel := {"ROTA01", dDataBase, "0001", "03"}

    U_PosSX1({{cPrgRot, "01", DTOS(dDataBase)}})

    While ((nOpcRotas > 0))

        If (Len(aParRet) < 1)
            If (!Pergunte(cPrgRot, .T.))
                Return (Nil)
            EndIf
            __dDtPergunte := MV_PAR01
            
            AAdd(aParRet, MV_PAR01)
        EndIf

        cQry := " SELECT MAX(Z0R.Z0R_VERSAO) AS DATVER" + CRLF
        cQry += " FROM " + RetSqlName("Z0R") + " Z0R " + CRLF
        cQry += " WHERE Z0R.Z0R_FILIAL = '" + xFilial("Z0R") + "' " + CRLF
        cQry += "   AND Z0R.Z0R_DATA = '" + DTOS(aParRet[1]) + "' "
        cQry += "   AND Z0R.D_E_L_E_T_ = ' ' " + CRLF
        
        cAlias := GetNextAlias()
        MpSysOpenQry(cQry, cAlias)
        
        If !((cAlias)->(EOF()))
            If (!Empty((cAlias)->DATVER))
                aDadSel[3] := (cAlias)->DATVER
            EndIf
        EndIf
        
        (cAlias)->(DBCloseArea())
        
        If (Len(aParRet) > 0)
            aDadSel[2] := aParRet[1]
			
			DBSelectArea("Z05")
			Z05->(DBSetOrder(1))
			If (!Z05->(DBSeek(xFilial("Z05") + DTOS(aDadSel[2]) + aDadSel[3])))
				
				If (MsgYesNo("Nao foi identificado nenhum trato para a data " + DTOC(aDadSel[2]) + ". Deseja criar?", "Trato nao encontrado."))
						//----------------------------
						//Cria o trato caso necessário
						//----------------------------
						FWMsgRun(, { || U_CriaTrato(aDadSel[2])}, "Geracao de trato", "Gerando trato para o dia " + DTOC(aDadSel[2]) + "...")
						if (!Z05->(DBSeek(xFilial("Z05") + DTOS(aDadSel[2]) + aDadSel[3])))
							nOpcRotas := 0
							Return (Nil)
						endif
				Else
					Help(,,"SELECAO DE TRATO",/**/,"Nao existe trato para o dia " + DTOC(aDadSel[2]) + ". ", 1, 1,,,,,.F.,{"Por favor, crie o trato para prosseguir." })
					nOpcRotas := 0
					Return (Nil)
				EndIf
			EndIf

        Else
            nOpcRotas := 0
        EndIf
		
		SetFunName("VATRT01")

			FWMsgRun(, {|| CriaTab() },'Por Favor Aguarde...' , 'Iniciando tabelas')

			//FWMsgRun(, {|| PopulaTab() },'Por Favor Aguarde...' , 'Carregando tabelas')

				FWExecView("Roteirização","VATRT01",3,,{|| .T.})
			
			oTmpLin:Delete()
			oTmpCur:Delete()
			oTmpRac:Delete()

			nOpcRotas := 0
		SetFunName(cFunBkp) 
    EndDo
Return nil

User Function VATRT01()
    Local aArea   		:= GetArea()
    Local oBrowse  		:= NIL
	Local cFunBkp 		:= FunName()  

    SetFunName("VATRT01")

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "Z05" )   
	oBrowse:SetDescription( "Roteirização" )
    oBrowse:SetMenuDef( "VATRT01" )
	oBrowse:Activate()
	
    SetFunName(cFunBkp)
	RestArea(aArea)
Return NIL

Static Function ModelDef()
	Local oModel 		:= nil
	Local oStCab   		:= FWFormStruct(1, "TMPCAB")
	//Local oStCon   		:= FWFormStruct(1, "TMPCON")
	Local oStLin   		:= FWFormStruct(1, "TMPLIN")
	Local oStCur   		:= FWFormStruct(1, "TMPCUR")
	Local oStRac   		:= FWFormStruct(1, "TMPRAC")
	Local bLoad 		:= {|oModel| fLoadGrid(oModel)}

    oStCab := gMdCab(oModel,oStCab)
    //oStCon := gMdCon(oModel,oStCon)
    oStLin := gMdLin(oModel,oStLin)
    oStCur := gMdCur(oModel,oStCur)
    oStRac := gMdRac(oModel,oStRac)

	oModel := MPFormModel():New("TRTVA01",/*Pre-Validacao*/, /* bVldPos */ /*Pos-Validacao*/, /* bVldCom */ /*Commit*/,/*Cancel*/)

	oModel:AddFields("TMPCAB",/*cOwner*/  ,oStCab, /*bPreValidacao*/,/*  {|| U_I04PREM()} *//*bPosValidacao*/,bLoad /* {|| CABLOAD()} *//*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	//oModel:AddGrid('TMPCON', 'TMPCAB'	, oStCon , /*bLinePre*/, /* {|| U_I04PREG()} *//*bLinePos*/,/* bPre */,/* bPos */,bLoad /* {|| LINLOAD()} */)
	oModel:AddGrid('TMPLIN', 'TMPCAB'	, oStLin , /*bLinePre*/, /* {|| U_I04PREG()} *//*bLinePos*/,/* bPre */,/* bPos */,bLoad /* {|| LINLOAD()} */)
	oModel:AddGrid('TMPCUR', 'TMPLIN'	, oStCur , /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,bLoad/* {|| CURLOAD()} *//*  {|| U_I04LOAD()} */)
	oModel:AddGrid('TMPRAC', 'TMPCAB'	, oStRac , /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,bLoad/* {|| RACLOAD()} *//*  {|| U_I04LOAD()} */)

	//oModel:SetRelation('TMPLIN', {{"CONF" , "CONF"}})
	oModel:SetRelation('TMPCUR', {{"LINHA", "LINHA"}})
//	oModel:SetRelation('TMPLIN', {{cAliaCon+"_CONF"  , cAliasLin+"_CONF"}})
//	oModel:SetRelation('TMPCUR', {{cAliasLin+"_LINHA", cAliasCur+"_CONF"}})
	//oModel:SetRelation('TMPRAC', {{cAliasRac+"_LINHA", cAliasCur+"_CONF"}})

	oModel:SetPrimaryKey({})

	//oModel:GetModel( "ZFFDETAIL" ):SetUniqueLine( { "ZFF_FILIAL","ZFF_CODIGO","ZFF_ITEM" } )
	oModel:GetModel('TMPLIN'):SetOptional(.T.)
	//oModel:GetModel('TMPCON'):SetOptional(.T.)
	oModel:GetModel('TMPCUR'):SetOptional(.T.)
	oModel:GetModel('TMPRAC'):SetOptional(.T.)

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro")
	oModel:GetModel("TMPCAB"):SetDescription("Roteirização")
	//oModel:GetModel("TMPCON"):SetDescription("Confinamento")
	oModel:GetModel("TMPLIN"):SetDescription("Linhas")
	oModel:GetModel("TMPCUR"):SetDescription("Currais")
	oModel:GetModel("TMPRAC"):SetDescription("Rações")

	//oModel:GetModel("TMPCON"):SetNoDeleteLine(.T.)
	oModel:GetModel("TMPLIN"):SetNoDeleteLine(.T.)
	oModel:GetModel("TMPCUR"):SetNoDeleteLine(.T.)
	oModel:GetModel("TMPRAC"):SetNoDeleteLine(.T.)

	//oModel:GetModel("TMPCON"):SetNoInsertLine(.T.)
	oModel:GetModel("TMPLIN"):SetNoInsertLine(.T.)
	oModel:GetModel("TMPCUR"):SetNoInsertLine(.T.)
	oModel:GetModel("TMPRAC"):SetNoInsertLine(.T.)
Return oModel

Static Function ViewDef()
    Local oView     := nil
	Local oModel    := FWLoadModel("VATRT01")
	Local oStCab    := FWFormStruct(2, "TMPCAB")
	//Local oStCon    := FWFormStruct(2, "TMPCON")
	Local oStLin    := FWFormStruct(2, "TMPLIN")
	Local oStCur    := FWFormStruct(2, "TMPCUR")
	Local oStRac    := FWFormStruct(2, "TMPRAC")

    oStCab := gVwCab(oModel,oStCab)
    //oStCon := gVwCon(oModel,oStCon)
    oStLin := gVwLin(oModel,oStLin)
    oStCur := gVwCur(oModel,oStCur)
    oStRac := gVwRac(oModel,oStRac)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB", oStCab, "TMPCAB")
	//oView:AddGrid("VIEW_CON" , oStLin, "TMPCON")
	oView:AddGrid("VIEW_LIN" , oStLin, "TMPLIN")
	oView:AddGrid("VIEW_CUR" , oStCur, "TMPCUR")
	oView:AddGrid("VIEW_RAC" , oStRac, "TMPRAC")
	
	oView:CreateHorizontalBox('CABEC', 20)
	oView:CreateHorizontalBox('GRID' , 80)
	
	//oView:CreateHorizontalBox('C_HIDE', 0	,'CABEC')
	//oView:CreateHorizontalBox('C_SHOW', 100	,'CABEC')

	oView:CreateFolder('FOLDER01','GRID')
    oView:AddSheet('FOLDER01','SHEET01',"Aba 01")

	oView:CreateHorizontalBox('GRID_FILHO' , 100,/* cIdOwner */,/* lFixPixel */, 'FOLDER01','SHEET01')

    oView:CreateVerticalBox('LEFT'  , 30, 'GRID_FILHO',, 'FOLDER01','SHEET01')
    oView:CreateHorizontalBox('L_CIMA'  , 50, 'LEFT',, 'FOLDER01','SHEET01')
    oView:CreateHorizontalBox('L_BAIXO' , 50, 'LEFT',, 'FOLDER01','SHEET01')

	oView:CreateVerticalBox('RIGHT' , 70, 'GRID_FILHO',, 'FOLDER01','SHEET01')
    oView:CreateHorizontalBox('R_CIMA'  , 50, 'RIGHT',, 'FOLDER01','SHEET01')
    oView:CreateHorizontalBox('R_BAIXO' , 50, 'RIGHT',, 'FOLDER01','SHEET01')

	oView:AddOtherObject("OTHER_PANEL_O", {|oPanel| CriaBtn(oPanel)})

	oView:SetOwnerView("VIEW_CAB"	 , "CABEC"  )
	//oView:SetOwnerView("VIEW_CON"	 , "C_SHOW" )
	oView:SetOwnerView("VIEW_LIN"	 , "L_CIMA" )
	oView:SetOwnerView("VIEW_RAC"	 , "L_BAIXO")
	oView:SetOwnerView("VIEW_CUR"	 , "R_CIMA" )
	oView:SetOwnerView("OTHER_PANEL_O"	 , "R_BAIXO" )
	
	oView:EnableTitleView('VIEW_CAB', "Roteirização")
	//oView:EnableTitleView('VIEW_CON', "Confinamento")
	oView:EnableTitleView('VIEW_LIN', "Linhas")
	oView:EnableTitleView('VIEW_CUR', "Currais")
	oView:EnableTitleView('VIEW_RAC', "Rações")

Return oView

Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' 		ACTION 'VIEWDEF.VATRT01' 			OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    		ACTION 'VIEWDEF.VATRT01' 			OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    		ACTION 'VIEWDEF.VATRT01' 			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    		ACTION 'VIEWDEF.VATRT01' 			OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

//Campos do Model
Static Function gMdCab(oModel,oStruct)
	oStruct:AddField('Teste','Teste','TMC_TESTE','C',1,0,/**/,,{},.F.,/**/,.F.,.F.,.T.)
Return oStruct
Static Function gVwCab(oModel,oStruct)
	oStruct:AddField('TMC_TESTE'	,  '1', 'Teste', 'Teste',{},'C',,,,.T.,,,{},,,.T.,,,)
Return oStruct
//Model
Static Function gMdCon(oModel,oStruct)
	oStruct:AddField('Confinamento'	,'Confinamento'	,'CONF','C',2,0,/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Descrição'	,'Descrição'	,'DESCRI','C',1,0,/**/,,{},.F.,/**/,.F.,.F.,.T.)
Return oStruct
Static Function gVwCon(oModel,oStruct)
	oStruct:AddField('CONF'		,  '1', 'Confinamento'	, 'Confinamento',{},'C',,,,.T.,,,{},,,.T.,,,)
	oStruct:AddField('DESCRI'	,  '2', 'Descrição'		, 'Descrição'	,{},'C',,,,.T.,,,{},,,.T.,,,)
Return oStruct
Static Function gMdLin(oModel,oStruct)
	//oStruct:AddField(''				,'' 			,'XSEL'  ,'L',1						,0						,/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Linha'		,'Linha'		,'LINHA','C',TAMSX3('Z08_LINHA')[1]	,TAMSX3('Z08_LINHA')[2]	,/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Dieta'		,'Dieta'		,'DIETA','C',TAMSX3('Z05_DIETA')[1]	,TAMSX3('Z05_DIETA')[2]	,/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Confinamento'	,'Confinamento'	,'CONF'	,'C',2						,0						,/**/,,{},.F.,/**/,.F.,.F.,.T.)
Return oStruct
//View
Static Function gVwLin(oModel,oStruct)
	//oStruct:AddField('XSEL'	,  '1', '', ''	,{},'L',,,,.T.,,,{},,,.T.,,,)
	oStruct:AddField('LINHA',  '2', 'Linha', 'Linha',{},'C',,,,.T.,,,{},,,.T.,,,)
	oStruct:AddField('DIETA',  '3', 'Dieta', 'Dieta',{},'C',,,,.T.,,,{},,,.T.,,,)
	oStruct:AddField('CONF' ,  '4', 'Confinamento', 'Confinamento',{},'C',,,,.T.,,,{},,,.T.,,,)
Return oStruct
//Model
Static Function gMdCur(oModel,oStruct)
	oStruct:AddField(''			,''			,'XXSEL'	 	,'L',1,0,/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Código'	,'Código'	,'CODIGO'	,'C',TAMSX3('Z08_CODIGO')[1],TAMSX3('Z08_CODIGO')[2],/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Seq.' 	,'Seq.' 	,'SEQUEN'   ,'C',TAMSX3('Z08_SEQUEN')[1],TAMSX3('Z08_SEQUEN')[2] ,/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Lote' 	,'Lote' 	,'LOTE' 	,'C',TAMSX3('B8_LOTECTL')[1],TAMSX3('B8_LOTECTL')[2],/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Quant'	,'Quant'	,'QUANT'	,'N',TAMSX3('B2_QATU')[1]	,TAMSX3('B2_QATU')[2]	,/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Dieta'	,'Dieta'	,'DIETA'	,'C',TAMSX3('Z05_DIETA')[1]	,TAMSX3('Z05_DIETA')[2]	,/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Linha'	,'Linha'	,'LINHA'	,'C',TAMSX3('Z08_LINHA')[1]	,TAMSX3('Z08_LINHA')[2]	,/**/,,{},.F.,/**/,.F.,.F.,.T.)
Return oStruct
//View
Static Function gVwCur(oModel,oStruct)
	oStruct:AddField('XXSEL'		,  '1', ''	, ''	,{},'L',,,,.T.,,,{},,,.T.,,,)
	oStruct:AddField('CODIGO'	,  '2', 'Código', 'Código'	,{},'C',,,,.T.,,,{},,,.T.,,,)
	oStruct:AddField('SEQUEN'	,  '3', 'Seq.'	, 'Seq.'	,{},'C',,,,.T.,,,{},,,.T.,,,)
	oStruct:AddField('LOTE'		,  '4', 'Lote'	, 'Lote'	,{},'C',,,,.T.,,,{},,,.T.,,,)
	oStruct:AddField('QUANT'	,  '5', 'Quant'	, 'Quant'	,{},'N',,,,.T.,,,{},,,.T.,,,)
	oStruct:AddField('DIETA'	,  '6', 'Dieta'	, 'Dieta'	,{},'C',,,,.T.,,,{},,,.T.,,,)
	oStruct:AddField('LINHA'	,  '7', 'Linha'	, 'Linha'	,{},'C',,,,.T.,,,{},,,.T.,,,)
Return oStruct
//Model
Static Function gMdRac(oModel,oStruct)
	oStruct:AddField('Dieta'	,'Dieta'	,'DIETA','C',TAMSX3('Z05_DIETA')[1]	,TAMSX3('Z05_DIETA')[2]	,/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Toneladas','Toneladas','TON'	,'N',TAMSX3('B2_QATU')[1],TAMSX3('B2_QATU')[2]		,/**/,,{},.F.,/**/,.F.,.F.,.T.)
Return oStruct
Static Function gVwRac(oModel,oStruct)
	oStruct:AddField('DIETA',  '1', 'Dieta'		, 'Dieta'		,{},'C',												   ,,,.F.,,,{},,,.T.,,,)
	oStruct:AddField('TON'	,  '2', 'Toneladas'	, 'Toneladas'	,{},'N',Alltrim(FWSX3Util():GetFieldStruct( "B2_QATU" )[5]),,,.F.,,,{},,,.T.,,,)
Return oStruct

Static Function fLoadGrid(oModel)
	Local aRet  := {}
	
	If ( oModel:GetId() == "TMPLIN" )
        aRet := FWLoadByAlias(oModel,oTmpLin:GetAlias(),oTmpLin:GetRealName())
	ElseIf ( oModel:GetId() == "TMPCON" )
        aRet := FWLoadByAlias(oModel,oTmpCon:GetAlias(),oTmpCon:GetRealName())
	ElseIf ( oModel:GetId() == "TMPCUR" )
        aRet := FWLoadByAlias(oModel,oTmpCur:GetAlias(),oTmpCur:GetRealName())
	ElseIf ( oModel:GetId() == "TMPRAC" )
        aRet := FWLoadByAlias(oModel,oTmpRac:GetAlias(),oTmpRac:GetRealName())
    Else
        aRet := {{"01"},0} 
    EndIf

Return aRet

Static Function CriaTab()
	Local aFields := {}

	//cAliaCon := GetNextAlias()
	//oTmpCon :=  FWTemporaryTable():New(cAliaCon)
//
	//aFields:= {}
	//aAdd(aFields, {'CONF'	,'C',TAMSX3('Z08_CONFNA')[1]	,TAMSX3('Z08_CONFNA')[2]	})
	//aAdd(aFields, {'DESCRI'	,'C',50	,0	})
//
	//oTmpCon:SetFields( aFields )
    //oTmpCon:AddIndex("1", {"CONF"} )
    //oTmpCon:Create()

	cAliasLin := GetNextAlias()
	oTmpLin :=  FWTemporaryTable():New(cAliasLin)

	aFields:= {}
	//aAdd(aFields, {'XSEL'  ,'L',1						,0						})
	aAdd(aFields, {'LINHA','C',TAMSX3('Z08_LINHA')[1]	,TAMSX3('Z08_LINHA')[2]	})
	aAdd(aFields, {'DIETA','C',TAMSX3('Z05_DIETA')[1]	,TAMSX3('Z05_DIETA')[2]	})
	aAdd(aFields, {'CONF' ,'C',TAMSX3('Z08_CONFNA')[1]	,TAMSX3('Z08_CONFNA')[2]	})

	oTmpLin:SetFields( aFields )
    oTmpLin:AddIndex("1", {"CONF"} )
    oTmpLin:AddIndex("2", {"LINHA"} )
    oTmpLin:AddIndex("3", {"CONF","LINHA"} )
    oTmpLin:Create()
	
	cAliasCur := GetNextAlias()
	oTmpCur :=  FWTemporaryTable():New(cAliasCur)
	
	aFields:= {}
	aAdd(aFields, {'XXSEL'	,'L',1						,0						})
	aAdd(aFields, {'CODIGO'	,'C',TAMSX3('Z08_CODIGO')[1],TAMSX3('Z08_CODIGO')[2]})
	aAdd(aFields, {'SEQUEN' ,'C',TAMSX3('Z08_SEQUEN')[1],TAMSX3('Z08_SEQUEN')[2]})
	aAdd(aFields, {'LOTE' 	,'C',TAMSX3('B8_LOTECTL')[1],TAMSX3('B8_LOTECTL')[2]})
	aAdd(aFields, {'QUANT'	,'N',TAMSX3('B2_QATU')[1]	,TAMSX3('B2_QATU')[2]	})
	aAdd(aFields, {'DIETA'	,'C',TAMSX3('Z05_DIETA')[1]	,TAMSX3('Z05_DIETA')[2]	})
	aAdd(aFields, {'LINHA'	,'C',TAMSX3('Z08_LINHA')[1]	,TAMSX3('Z08_LINHA')[2]	})

	oTmpCur:SetFields( aFields )
    oTmpCur:AddIndex("1", {"LINHA"} )
    oTmpCur:Create()

	cAliasRac := GetNextAlias()
	oTmpRac :=  FWTemporaryTable():New(cAliasRac)

	aFields:= {}
	aAdd(aFields, {'DIETA'	,'C',TAMSX3('Z05_DIETA')[1]	,TAMSX3('Z05_DIETA')[2]	})
	aAdd(aFields, {'TON'	,'N',TAMSX3('B2_QATU')[1]	,TAMSX3('B2_QATU')[2]	})

	oTmpRac:SetFields( aFields )
    oTmpRac:AddIndex("1", {"DIETA"} )
    oTmpRac:Create()

Return nil

Static Function PopulaTab()
	Local aArea 	:= FwGetArea()
	Local cQry		:= ""
	Local cAlias 	:= ""
	Local cConf 	:= ""
	Local cConfBak  := ""
	Local cLinha 	:= ""
	Local cLinBak 	:= ""

	cQry := " SELECT DISTINCT Z08.Z08_CONFNA AS CONF, Z08.Z08_TIPO AS TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA AS LINHA, Z08.Z08_SEQUEN AS SEQ " + CRLF
	cQry += "      , ISNULL(SB8.B8_LOTECTL, 'SEM LOTE') AS LOTE, Z05.Z05_CABECA AS QUANT, (SELECT MAX(Z0M1.Z0M_VERSAO) FROM " + RetSqlName("Z0M") + " Z0M1 WHERE Z0M1.Z0M_CODIGO = Z0O.Z0O_CODPLA AND Z0M1.D_E_L_E_T_ = ' ') AS PLANO " + CRLF
	cQry += "      , DATEDIFF(day, (SELECT MIN(SB8A.B8_XDATACO) FROM " + RetSqlName("SB8") + " SB8A WHERE SB8A.B8_LOTECTL = SB8.B8_LOTECTL AND SB8A.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8A.B8_SALDO > 0 AND SB8A.D_E_L_E_T_ <> '*'),  GETDATE()) AS DIAS " + CRLF //DATEDIFF(day, SB8.B8_XDATACO,  GETDATE()) AS DIAS, 
	cQry += "      --, Z05.Z05_DIETA AS DIETA " + CRLF
	cQry += "      , Z0R.Z0R_DATA AS DTTRT, Z0R.Z0R_VERSAO AS VERSAO, Z0T.Z0T_ROTA AS ROTA " + CRLF 
	cQry += "      , (SELECT DISTINCT(SB1.B1_DESC) FROM " + RetSqlName("SB1") + " SB1 WHERE SB1.B1_COD = Z05.Z05_DIETA) AS DIEDSC " + CRLF //AND Z06.Z06_CURRAL = Z08.Z08_CODIGO
	cQry += "      , Z05_DIETA DIETA" + CRLF
	cQry += "      , (SELECT COUNT(Z06.Z06_TRATO)  FROM " + RetSqlName("Z06") + " Z06 WHERE Z06.D_E_L_E_T_ <> '*' AND Z06.Z06_FILIAL = '" + xFilial('Z06') + "' AND Z06.Z06_DATA = Z0R.Z0R_DATA AND Z06.Z06_VERSAO = Z0R.Z0R_VERSAO AND Z06.Z06_LOTE = SB8.B8_LOTECTL) AS NRTRT " + CRLF
	cQry += "      , (SELECT SUM(Z04.Z04_TOTREA)   FROM " + RetSqlName("Z04") + " Z04 WHERE Z04.Z04_DTIMP  = DATEADD(dd, -1, cast('" + DTOS(aDadSel[2]) + "' as datetime)) AND Z04.Z04_FILIAL = '" + xFilial('Z04') + "' AND Z04.D_E_L_E_T_ <> '*' AND Z04.Z04_LOTE = SB8.B8_LOTECTL) AS Z04_TOTREA " + CRLF
	cQry += "      , (SELECT Z05A.Z05_KGMNDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMN " + CRLF
	cQry += "      , (SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMS " + CRLF
	cQry += "      , (SELECT Z05A.Z05_KGMNDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMNDIA " + CRLF
	cQry += "      , (SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMSDIA " + CRLF
	cQry += " FROM " + RetSqlName("Z08") + " Z08 " + CRLF
	cQry += " LEFT JOIN " + RetSqlName("SB8") + " SB8 ON SB8.B8_X_CURRA = Z08.Z08_CODIGO AND SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8.D_E_L_E_T_ <> '*' AND SB8.B8_SALDO > 0 " + CRLF
	cQry += " LEFT JOIN " + RetSqlName("Z0O") + " Z0O ON Z0O.Z0O_LOTE = SB8.B8_LOTECTL AND ('" + DTOS(aDadSel[2]) + "' BETWEEN Z0O.Z0O_DATAIN AND Z0O.Z0O_DATATR OR (Z0O.Z0O_DATAIN <= '" + DTOS(aDadSel[2]) + "' AND Z0O.Z0O_DATATR = '        ')) AND Z0O.Z0O_FILIAL = '" + xFilial("Z0O") + "' AND Z0O.D_E_L_E_T_ <> '*' " + CRLF
	cQry += " LEFT JOIN " + RetSqlName("Z0R") + " Z0R ON Z0R.Z0R_DATA = '" + DTOS(aDadSel[2]) + "' AND Z0R.Z0R_VERSAO = '" + aDadSel[3] + "' AND Z0R.Z0R_FILIAL = '" + xFilial("Z0R") + "' AND Z0R.D_E_L_E_T_ <> '*' " + CRLF
	cQry += " LEFT JOIN " + RetSqlName("Z05") + " Z05 ON Z05.Z05_DATA = Z0R.Z0R_DATA AND Z05.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05.Z05_LOTE = SB8.B8_LOTECTL AND Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.D_E_L_E_T_ <> '*' " + CRLF //AND Z05.Z05_CURRAL = SB8.B8_X_CURRA
	cQry += " LEFT JOIN " + RetSqlName("Z0T") + " Z0T ON Z0T.Z0T_DATA = Z0R.Z0R_DATA AND Z0T.Z0T_VERSAO = Z0R.Z0R_VERSAO AND Z0T.Z0T_CURRAL = Z08_CODIGO AND Z0T.Z0T_FILIAL = '" + xFilial("Z0T") + "' AND Z0T.D_E_L_E_T_ <> '*' " + CRLF //Z0T.Z0T_LINHA = Z08.Z08_LINHA AND Z0T.Z0T_SEQUEN = Z08.Z08_SEQUEN
	cQry += " WHERE Z08.D_E_L_E_T_ <> '*' " + CRLF
	cQry += "   AND Z08.Z08_FILIAL = '" + xFilial("Z08") + "' AND Z08.Z08_CONFNA <> '' " + CRLF
	cQry += "   AND Z08.Z08_MSBLQL <> '1' " + CRLF
	cQry += IIf(!lShwZer, " AND SB8.B8_SALDO > 0 ", "") + CRLF
	cQry += " GROUP BY Z08.Z08_CONFNA, Z08.Z08_TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA, Z08.Z08_SEQUEN, SB8.B8_LOTECTL, Z05.Z05_CABECA, Z0O.Z0O_CODPLA, Z05.Z05_DIETA, Z05.Z05_KGMNDI, Z05.Z05_KGMSDI, Z0R.Z0R_DATA, Z0R.Z0R_VERSAO, Z0T.Z0T_ROTA, Z05_FILIAL, Z05_VERSAO, Z05_DATA, Z05_LOTE" + CRLF //SB8.B8_XDATACO,
	cQry += " ORDER BY Z08.Z08_CONFNA, Z08.Z08_TIPO, Z08.Z08_LINHA, Z08.Z08_SEQUEN, Z08.Z08_CODIGO " + CRLF

	if cUserName $ 'Administrador,ioliveira,atoshio,mbernardo,bernardo'
		MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_ROTAMAIN.SQL", cQry)
	endif

	cAlias := MpSysOpenQry(cQry)

	While (cALias)->(!EOF())
		//adicionando primeira grid com CONfinamentos.		
		
		//cConf := (cALias)->CONF
		//if cConf != cConfBak
		//	RecLock(cAliaCon, .T.)
		//		(cAliaCon)->CONF	:= (cALias)->CONF
		//		(cAliaCon)->DESCRI	:= "TESTE"
		//	(cAliaCon)->(MsUnLock())
//
		//	cConfBak := (cALias)->CONF
		//endif

		cLinha := (cALias)->LINHA
		if cLinha != cLinBak

			RecLock(cAliasLin, .T.)
				(cAliasLin)->LINHA := (cALias)->LINHA
				(cAliasLin)->DIETA := (cALias)->DIETA
				(cAliasLin)->CONF  := (cALias)->CONF
			(cAliasLin)->(MsUnLock())

			cLinBak := (cALias)->LINHA
		endif

		RecLock(cAliasCur, .T.)
			(cAliasCur)->CODIGO := (cALias)->Z08_CODIGO
			(cAliasCur)->SEQUEN := (cALias)->SEQ
			(cAliasCur)->LOTE   := (cALias)->LOTE
			(cAliasCur)->QUANT  := (cALias)->QUANT
			(cAliasCur)->DIETA  := (cALias)->DIETA
			(cAliasCur)->LINHA  := (cALias)->LINHA
		(cAliasLin)->(MsUnLock())

		(cALias)->(DbSkip())
	enddo

	FWRestArea(aArea)
Return 

User Function TRTVA01()
    Local aArea 	:= FWGetArea()
    Local aParam 	:= PARAMIXB 
    Local xRet 		:= .T.
    Local oObj 		:= Nil
    Local cIdPonto 	:= ""
    Local cIdModel 	:= ""
    Local nLinha
    Local oModel 	:= nil
    Local oMdCon 	:= nil
    Local oMdLin 	:= nil
    Local oMdCur 	:= nil
    Local oMdRac  	:= nil
    Local oView
	Local cQry		:= ""
	Local cAlias 	:= ""
	Local cConf 	:= ""
	Local cConfBak  := ""
	Local cLinha 	:= ""
	Local cLinBak 	:= ""
     
    //Se tiver parametros
    If aParam != Nil
         
        //Pega informacoes dos parametros
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
         
        //Após carregar toda a tela e estar na adição de botões
        If cIdPonto == "BUTTONBAR"
			oModel 	:= FWModelActive()
            oView   := FWViewActive()
			//oMdCon 	:= oModel:GetModel("TMPCON")
			oMdLin 	:= oModel:GetModel("TMPLIN")
			oMdCur 	:= oModel:GetModel("TMPCUR")
			oMdRac  := oModel:GetModel("TMPRAC")

			cQry := " SELECT DISTINCT Z08.Z08_CONFNA AS CONF, Z08.Z08_TIPO AS TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA AS LINHA, Z08.Z08_SEQUEN AS SEQ " + CRLF
			cQry += "      , ISNULL(SB8.B8_LOTECTL, 'SEM LOTE') AS LOTE, Z05.Z05_CABECA AS QUANT, (SELECT MAX(Z0M1.Z0M_VERSAO) FROM " + RetSqlName("Z0M") + " Z0M1 WHERE Z0M1.Z0M_CODIGO = Z0O.Z0O_CODPLA AND Z0M1.D_E_L_E_T_ = ' ') AS PLANO " + CRLF
			cQry += "      , DATEDIFF(day, (SELECT MIN(SB8A.B8_XDATACO) FROM " + RetSqlName("SB8") + " SB8A WHERE SB8A.B8_LOTECTL = SB8.B8_LOTECTL AND SB8A.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8A.B8_SALDO > 0 AND SB8A.D_E_L_E_T_ <> '*'),  GETDATE()) AS DIAS " + CRLF //DATEDIFF(day, SB8.B8_XDATACO,  GETDATE()) AS DIAS, 
			cQry += "      --, Z05.Z05_DIETA AS DIETA " + CRLF
			cQry += "      , Z0R.Z0R_DATA AS DTTRT, Z0R.Z0R_VERSAO AS VERSAO, Z0T.Z0T_ROTA AS ROTA " + CRLF 
			cQry += "      , (SELECT DISTINCT(SB1.B1_DESC) FROM " + RetSqlName("SB1") + " SB1 WHERE SB1.B1_COD = Z05.Z05_DIETA) AS DIEDSC " + CRLF //AND Z06.Z06_CURRAL = Z08.Z08_CODIGO
			cQry += "      , Z05_DIETA DIETA" + CRLF
			cQry += "      , (SELECT COUNT(Z06.Z06_TRATO)  FROM " + RetSqlName("Z06") + " Z06 WHERE Z06.D_E_L_E_T_ <> '*' AND Z06.Z06_FILIAL = '" + xFilial('Z06') + "' AND Z06.Z06_DATA = Z0R.Z0R_DATA AND Z06.Z06_VERSAO = Z0R.Z0R_VERSAO AND Z06.Z06_LOTE = SB8.B8_LOTECTL) AS NRTRT " + CRLF
			cQry += "      , (SELECT SUM(Z04.Z04_TOTREA)   FROM " + RetSqlName("Z04") + " Z04 WHERE Z04.Z04_DTIMP  = DATEADD(dd, -1, cast('" + DTOS(aDadSel[2]) + "' as datetime)) AND Z04.Z04_FILIAL = '" + xFilial('Z04') + "' AND Z04.D_E_L_E_T_ <> '*' AND Z04.Z04_LOTE = SB8.B8_LOTECTL) AS Z04_TOTREA " + CRLF
			cQry += "      , (SELECT Z05A.Z05_KGMNDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMN " + CRLF
			cQry += "      , (SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMS " + CRLF
			cQry += "      , (SELECT Z05A.Z05_KGMNDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMNDIA " + CRLF
			cQry += "      , (SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMSDIA " + CRLF
			cQry += " FROM " + RetSqlName("Z08") + " Z08 " + CRLF
			cQry += " LEFT JOIN " + RetSqlName("SB8") + " SB8 ON SB8.B8_X_CURRA = Z08.Z08_CODIGO AND SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8.D_E_L_E_T_ <> '*' AND SB8.B8_SALDO > 0 " + CRLF
			cQry += " LEFT JOIN " + RetSqlName("Z0O") + " Z0O ON Z0O.Z0O_LOTE = SB8.B8_LOTECTL AND ('" + DTOS(aDadSel[2]) + "' BETWEEN Z0O.Z0O_DATAIN AND Z0O.Z0O_DATATR OR (Z0O.Z0O_DATAIN <= '" + DTOS(aDadSel[2]) + "' AND Z0O.Z0O_DATATR = '        ')) AND Z0O.Z0O_FILIAL = '" + xFilial("Z0O") + "' AND Z0O.D_E_L_E_T_ <> '*' " + CRLF
			cQry += " LEFT JOIN " + RetSqlName("Z0R") + " Z0R ON Z0R.Z0R_DATA = '" + DTOS(aDadSel[2]) + "' AND Z0R.Z0R_VERSAO = '" + aDadSel[3] + "' AND Z0R.Z0R_FILIAL = '" + xFilial("Z0R") + "' AND Z0R.D_E_L_E_T_ <> '*' " + CRLF
			cQry += " LEFT JOIN " + RetSqlName("Z05") + " Z05 ON Z05.Z05_DATA = Z0R.Z0R_DATA AND Z05.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05.Z05_LOTE = SB8.B8_LOTECTL AND Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.D_E_L_E_T_ <> '*' " + CRLF //AND Z05.Z05_CURRAL = SB8.B8_X_CURRA
			cQry += " LEFT JOIN " + RetSqlName("Z0T") + " Z0T ON Z0T.Z0T_DATA = Z0R.Z0R_DATA AND Z0T.Z0T_VERSAO = Z0R.Z0R_VERSAO AND Z0T.Z0T_CURRAL = Z08_CODIGO AND Z0T.Z0T_FILIAL = '" + xFilial("Z0T") + "' AND Z0T.D_E_L_E_T_ <> '*' " + CRLF //Z0T.Z0T_LINHA = Z08.Z08_LINHA AND Z0T.Z0T_SEQUEN = Z08.Z08_SEQUEN
			cQry += " WHERE Z08.D_E_L_E_T_ <> '*' " + CRLF
			cQry += "   AND Z08.Z08_FILIAL = '" + xFilial("Z08") + "' AND Z08.Z08_CONFNA <> '' " + CRLF
			cQry += "   AND Z08.Z08_MSBLQL <> '1' " + CRLF
			cQry += IIf(!lShwZer, " AND SB8.B8_SALDO > 0 ", "") + CRLF
			cQry += " GROUP BY Z08.Z08_CONFNA, Z08.Z08_TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA, Z08.Z08_SEQUEN, SB8.B8_LOTECTL, Z05.Z05_CABECA, Z0O.Z0O_CODPLA, Z05.Z05_DIETA, Z05.Z05_KGMNDI, Z05.Z05_KGMSDI, Z0R.Z0R_DATA, Z0R.Z0R_VERSAO, Z0T.Z0T_ROTA, Z05_FILIAL, Z05_VERSAO, Z05_DATA, Z05_LOTE" + CRLF //SB8.B8_XDATACO,
			cQry += " ORDER BY Z08.Z08_CONFNA, Z08.Z08_TIPO, Z08.Z08_LINHA, Z08.Z08_SEQUEN, Z08.Z08_CODIGO " + CRLF

			if cUserName $ 'Administrador,ioliveira,atoshio,mbernardo,bernardo'
				MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa09_ROTAMAIN.SQL", cQry)
			endif

			cAlias := MpSysOpenQry(cQry)
			
			oMdLin:SetNoInsertLine(.f.)
			oMdLin:SetNoDeleteLine(.F.)
			oMdCur:SetNoInsertLine(.f.)
			oMdCur:SetNoDeleteLine(.F.)
			oMdRac:SetNoInsertLine(.f.)
			oMdRac:SetNoDeleteLine(.F.)
            //Limpando a grid
           //If oMdCon:CanClearData()
           //    oMdCon:ClearData()
           //EndIf
            If oMdLin:CanClearData()
                oMdLin:ClearData()
            EndIf
            If oMdCur:CanClearData()
                oMdCur:ClearData()
            EndIf
            If oMdRac:CanClearData()
                oMdRac:ClearData()
            EndIf
            
			While (cALias)->(!EOF())

				//cConf := (cALias)->CONF
				//if cConf != cConfBak
				//	oMdCon:AddLine()
				//	oMdCon:LoadValue("CONF"		, (cALias)->CONF)
				//	oMdCon:LoadValue("DESCRI"	, "Teste")
//
				//	cConfBak := (cALias)->CONF
				//endif

				cLinha := (cALias)->LINHA

				if cLinha != cLinBak
					if !oMdLin:IsEmpty()
						oMdLin:AddLine()
					endif 
					//oMdLin:LoadValue("XSEL"		, .F.)
					oMdLin:LoadValue("LINHA"	, (cALias)->LINHA)
					oMdLin:LoadValue("DIETA"	, (cALias)->DIETA)
					oMdLin:LoadValue("CONF"		, (cALias)->CONF)

					cLinBak := (cALias)->LINHA
				endif

				if !oMdCur:IsEmpty()
					oMdCur:AddLine()
				endif

				oMdCur:LoadValue("XXSEL"		, .F.)
				oMdCur:LoadValue("CODIGO",(cALias)->Z08_CODIGO)
				oMdCur:LoadValue("SEQUEN",(cALias)->SEQ)
				oMdCur:LoadValue("LOTE"	 ,(cALias)->LOTE)
				oMdCur:LoadValue("QUANT" ,(cALias)->QUANT)
				oMdCur:LoadValue("DIETA" ,(cALias)->DIETA)
				oMdCur:LoadValue("LINHA" ,(cALias)->LINHA)

				(cALias)->(DbSkip())
			enddo
 
			oMdLin:SetNoInsertLine(.T.)
			oMdLin:SetNoDeleteLine(.T.)
			oMdCur:SetNoInsertLine(.T.)
			oMdCur:SetNoDeleteLine(.T.)
			oMdRac:SetNoInsertLine(.T.)
			oMdRac:SetNoDeleteLine(.T.)
            //Posiciona na linha 1
           // oMdCon:GoLine(1)
            oMdLin:GoLine(1)
            oView:Refresh()
 
        EndIf

         
    EndIf
     
    FWRestArea(aArea)
Return xRet

Static Function CriaBtn(oPanel)
	Local oModel 	:= FWModelActive()
	Local oView  	:= FWViewActive()
	Local oFontMod  := TFont():New("Tahoma", , -38)
	// Local lOk := .F.
	// Ancoramos os objetos no oPanel passado
	oPanel	:= tPanel():New(01,01,"Teste",oPanel,oFontMod,.T.,,CLR_YELLOW,CLR_BLUE,50,50)

Return 
