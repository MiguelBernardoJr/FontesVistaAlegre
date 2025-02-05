#include "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

//User Function VATST01()
//	Local cPrgRot       := "VAPCPA09"
//    Local cQry          := ""
//    Local cAlias        := ""
//	Local cFunBkp 		:= FunName()  
//
//    Private lShwZer   := .F.
//    Private lShwGer   := .T.
//    Private nOpcRotas := 1
//    Private aDadSel   := {}
//    Private aLinAlf   := {}
//    Private aParRet   := {}
//    Private aTik    := {LoadBitmap( GetResources(), "LBTIK" ), LoadBitmap( GetResources(), "LBNO" )}
//    Private __dDtPergunte := StoD("")
//
//    aDadSel := {"ROTA01", dDataBase, "0001", "03"}
//
//    U_PosSX1({{cPrgRot, "01", DTOS(dDataBase)}})
//
//    While ((nOpcRotas > 0))
//
//        If (Len(aParRet) < 1)
//            If (!Pergunte(cPrgRot, .T.))
//                Return (Nil)
//            EndIf
//            __dDtPergunte := MV_PAR01
//            
//            AAdd(aParRet, MV_PAR01)
//        EndIf
//
//        cQry := " SELECT MAX(Z0R.Z0R_VERSAO) AS DATVER" + CRLF
//        cQry += " FROM " + RetSqlName("Z0R") + " Z0R " + CRLF
//        cQry += " WHERE Z0R.Z0R_FILIAL = '" + xFilial("Z0R") + "' " + CRLF
//        cQry += "   AND Z0R.Z0R_DATA = '" + DTOS(aParRet[1]) + "' "
//        cQry += "   AND Z0R.D_E_L_E_T_ = ' ' " + CRLF
//        
//        cAlias := GetNextAlias()
//        MpSysOpenQry(cQry, cAlias)
//        
//        If !((cAlias)->(EOF()))
//            If (!Empty((cAlias)->DATVER))
//                aDadSel[3] := (cAlias)->DATVER
//            EndIf
//        EndIf
//        
//        (cAlias)->(DBCloseArea())
//        
//        If (Len(aParRet) > 0)
//            aDadSel[2] := aParRet[1]
//
//            SetFunName("VATRT01")
//                FWExecView("Produtos x Acessórios","VATRT01",3,,{|| .T.})
//            SetFunName(cFunBkp) 
//
//            //VAPCPA09A(lShwZer, lShwGer)
//        Else
//            nOpcRotas := 0
//        EndIf
//    EndDo
//Return nil

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
	Local oStLin   		:= FWFormStruct(1, "TMPLIN")
	Local oStCur   		:= FWFormStruct(1, "TMPCUR")
	Local oStRac   		:= FWFormStruct(1, "TMPRAC")

    oStCab := gMdCab(oModel,oStCab)
    oStLin := gMdLin(oModel,oStLin)
    oStCur := gMdCur(oModel,oStCur)
    oStRac := gMdRac(oModel,oStRac)

	oModel := MPFormModel():New("TRTVA01",/*Pre-Validacao*/, /* bVldPos */ /*Pos-Validacao*/, /* bVldCom */ /*Commit*/,/*Cancel*/)

	oModel:AddFields("TMPCAB",/*cOwner*/  ,oStCab, /*bPreValidacao*/,/*  {|| U_I04PREM()} *//*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddGrid('TMPLIN', 'TMPCAB'	, oStLin, /*bLinePre*/, /* {|| U_I04PREG()} *//*bLinePos*/,/* bPre */,/* bPos */, /* {|| U_I04LOAD()} */)
	oModel:AddGrid('TMPCUR', 'TMPLIN'	, oStCur , /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,/*  {|| U_I04LOAD()} */)
	oModel:AddGrid('TMPRAC', 'TMPLIN'	, oStRac , /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */,/*  {|| U_I04LOAD()} */)

	oModel:SetPrimaryKey({})

	//oModel:GetModel( "ZFFDETAIL" ):SetUniqueLine( { "ZFF_FILIAL","ZFF_CODIGO","ZFF_ITEM" } )
	oModel:GetModel('TMPLIN'):SetOptional(.T.)
	oModel:GetModel('TMPCUR'):SetOptional(.T.)
	oModel:GetModel('TMPRAC'):SetOptional(.T.)

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro")
	oModel:GetModel("TMPCAB"):SetDescription("Roteirização")
	oModel:GetModel("TMPLIN"):SetDescription("Linhas")
	oModel:GetModel("TMPCUR"):SetDescription("Currais")
	oModel:GetModel("TMPRAC"):SetDescription("Rações")

Return oModel

Static Function ViewDef()
    Local oView     := nil
	Local oModel    := FWLoadModel("VATRT01")
	Local oStCab    := FWFormStruct(2, "TMPCAB")
	Local oStLin    := FWFormStruct(2, "TMPLIN")
	Local oStCur    := FWFormStruct(2, "TMPCUR")
	Local oStRac    := FWFormStruct(2, "TMPRAC")

    oStCab := gVwCab(oModel,oStCab)
    oStLin := gVwLin(oModel,oStLin)
    oStCur := gVwCur(oModel,oStCur)
    oStRac := gVwRac(oModel,oStRac)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB", oStCab, "TMPCAB")
	oView:AddGrid("VIEW_LIN" , oStLin, "TMPLIN")
	oView:AddGrid("VIEW_CUR" , oStCur, "TMPCUR")
	oView:AddGrid("VIEW_RAC" , oStRac, "TMPRAC")
	
	oView:CreateHorizontalBox('CABEC', 20)
	oView:CreateHorizontalBox('GRID' , 80)

	oView:CreateFolder('FOLDER01','GRID')
    oView:AddSheet('FOLDER01','SHEET01',"Aba 01")

	oView:CreateHorizontalBox('GRID_FILHO' , 100,/* cIdOwner */,/* lFixPixel */, 'FOLDER01','SHEET01')

    oView:CreateVerticalBox('LEFT'  , 50, 'GRID_FILHO',, 'FOLDER01','SHEET01')
    oView:CreateVerticalBox('RIGHT' , 50, 'GRID_FILHO',, 'FOLDER01','SHEET01')
    
    oView:CreateHorizontalBox('R_CIMA'  , 50, 'RIGHT',, 'FOLDER01','SHEET01')
    oView:CreateHorizontalBox('R_BAIXO' , 50, 'RIGHT',, 'FOLDER01','SHEET01')

	oView:SetOwnerView("VIEW_CAB"	 , "CABEC"  )
	oView:SetOwnerView("VIEW_LIN"	 , "LEFT"   )
	oView:SetOwnerView("VIEW_CUR"	 , "R_CIMA" )
	oView:SetOwnerView("VIEW_RAC"	 , "R_BAIXO")
	
	oView:EnableTitleView('VIEW_CAB', "Roteirização")
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
Static Function gMdLin(oModel,oStruct)
	oStruct:AddField('Teste','Teste','TM1_TEST1','C',1,0,/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Teste','Teste','TM1_TEST2','C',1,0,/**/,,{},.F.,/**/,.F.,.F.,.T.)
Return oStruct
Static Function gMdCur(oModel,oStruct)
	oStruct:AddField('Teste','Teste','TM2_TEST1','C',1,0,/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Teste','Teste','TM2_TEST2','C',1,0,/**/,,{},.F.,/**/,.F.,.F.,.T.)
Return oStruct
Static Function gMdRac(oModel,oStruct)
	oStruct:AddField('Teste','Teste','TM3_TEST1','C',1,0,/**/,,{},.F.,/**/,.F.,.F.,.T.)
	oStruct:AddField('Teste','Teste','TM3_TEST2','C',1,0,/**/,,{},.F.,/**/,.F.,.F.,.T.)
Return oStruct

//Campos da View
Static Function gVwCab(oModel,oStruct)
	oStruct:AddField('TMC_TESTE'	,  '1', 'Teste', 'Teste',{},'C',,,,.T.,,,{},1,,.T.,,,)
Return oStruct
Static Function gVwLin(oModel,oStruct)
	oStruct:AddField('TM1_TEST1'	,  '1', 'Teste', 'Teste',{},'C',,,,.T.,,,{},1,,.T.,,,)
	oStruct:AddField('TM1_TEST2'	,  '1', 'Teste', 'Teste',{},'C',,,,.T.,,,{},1,,.T.,,,)
Return oStruct
Static Function gVwCur(oModel,oStruct)
	oStruct:AddField('TM2_TEST1'	,  '1', 'Teste', 'Teste',{},'C',,,,.T.,,,{},1,,.T.,,,)
	oStruct:AddField('TM2_TEST2'	,  '1', 'Teste', 'Teste',{},'C',,,,.T.,,,{},1,,.T.,,,)
Return oStruct
Static Function gVwRac(oModel,oStruct)
	oStruct:AddField('TM3_TEST1'	,  '1', 'Teste', 'Teste',{},'C',,,,.T.,,,{},1,,.T.,,,)
	oStruct:AddField('TM3_TEST2'	,  '1', 'Teste', 'Teste',{},'C',,,,.T.,,,{},1,,.T.,,,)
Return oStruct
