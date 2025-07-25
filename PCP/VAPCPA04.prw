// #########################################################################################
// Projeto: JRModelos
// Fonte  : JRMOD2
// ---------+------------------------------+------------------------------------------------
// Data     | Autor: JRScatolon            | Descricao: Nota de Manejo de Cocho 
// ---------+------------------------------+------------------------------------------------
// aaaammdd | <email>                      | <Descricao da rotina>
//          |                              |  
//          |                              |  
// ---------+------------------------------+------------------------------------------------

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

Static cCpoCabc	:= "Z0I_FILIAL|Z0I_DATA|Z0I_PERIOD|Z0I_CURLOT|Z0I_NOTTMP|"
//Static cCpoGrid := "Z0I_CODIGO|Z0I_CURRAL|Z0I_LOTE|Z0I_TOTPRE|Z0I_TOTREA||Z0I_NOTTD1|Z0I_NOTND1|Z0I_NOTMAN|Z0I_NOTTAR|Z0I_NOTNOI|Z0I_DIETD1|Z0I_KGMSD1|Z0I_CMSPV1|Z0I_NOTTD2|Z0I_NOTND2|Z0I_NOTMD1|Z0I_DIETD2|Z0I_KGMSD2|Z0I_CMSPV2|Z0I_NOTTD3|Z0I_NOTND3|Z0I_NOTMD2|Z0I_DIETD3|Z0I_KGMSD3|Z0I_CMSPV3|Z0I_NOTTD4|Z0I_NOTND4|Z0I_NOTMD3|Z0I_DIETD4|Z0I_KGMSD4|Z0I_CMSPV4|Z0I_NOTTD5|Z0I_NOTND5|Z0I_NOTMD4|Z0I_DIETD5|Z0I_KGMSD5|Z0I_CMSPV5|Z0I_NOTMD5|"
Static cCpoGrid := "Z0I_CODIGO|Z0I_CURRAL|SZ0I_LOTE|Z0I_DIASCO|Z0I_TOTPRE|Z0I_TOTREA|Z0I_NOTTD1|Z0I_NOTNOI|Z0I_AJUSTE|Z0I_NOTMAN|Z0I_NOTTAR|Z0I_DIETD1|Z0I_KGMSD1|Z0I_CMSPV1|Z0I_NOTTD2|Z0I_NOTND1|Z0I_NOTMD1|Z0I_DIETD2|Z0I_KGMSD2|Z0I_CMSPV2|Z0I_NOTTD3|Z0I_NOTND2|Z0I_NOTMD2|Z0I_DIETD3|Z0I_KGMSD3|Z0I_CMSPV3|Z0I_NOTTD4|Z0I_NOTND3|Z0I_NOTMD3|Z0I_DIETD4|Z0I_KGMSD4|Z0I_CMSPV4|Z0I_NOTTD5|Z0I_NOTND4|Z0I_NOTMD4|Z0I_DIETD5|Z0I_KGMSD5|Z0I_CMSPV5|Z0I_NOTTD6|Z0I_NOTND5|Z0I_NOTMD5|"
User Function VAPCPA04()


Local aArea := GetArea()
Local oBrowse
Local aParBox := {}
Local cPrg    := "VAPCPA04"

Local aEnButt := {{.F., NIL},{.F., NIL},{.F., NIL},{.F., NIL},{.F., NIL},{.F., NIL},{.T., "Salvar"},{.T., "Sair"},{.F., NIL},{.F., NIL},{.F., NIL},{.T., NIL},{.F., NIL},{.F., NIL}}

Private aRotina	:= MenuDef()
Private cAlias  := "Z0I"
Private cDescri := Posicione("SX2", 1, cAlias, "X2_NOME")
Private aParRet := {}
Private aLinAlt := {0, 1, 7} //{[ultima linha preenchida automaticamente], [linha posicionada], [quantidade para pular folha]}

//oBrowse := FwBrowse():New()
//oBrowse:SetAlias(cAlias)
//oBrowse:SetDescription(	cDescri)
//oBrowse:SetQuery("SELECT DISTINCT(Z0I.Z0I_DATA) FROM " + RetSqlName("Z0I") + " Z0I WHERE Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0I.D_E_L_E_T_ <> '*' ")
//oBrowse:Activate()

//AAdd(aParBox,{1,"Data      ",CTOD(Space(8)),"","",""   ,"",50,.F.}) // aParRet[1]
//aAdd(aParBox,{2,"Periodo   ","1",{"1=Manha","2=Tarde"},50,"",.F.})  // aParRet[2]
//AAdd(aParBox,{1,"Curral De ",Space(15),"","","Z08","",50,.F.})      // aParRet[3]
//AAdd(aParBox,{1,"Curral Ate",Space(15),"","","Z08","",50,.F.})      // aParRet[4]
//AAdd(aParBox,{1,"Lote De   ",Space(10),"","","SB8","",50,.F.})      // aParRet[5]
//AAdd(aParBox,{1,"Lote Ate  ",Space(10),"","","SB8","",50,.F.})      // aParRet[6]

//While (ParamBox(aParBox, "Nota de Manejo de Cocho", @aParRet))

U_PosSX1({{"VAPCPA04", "01", DTOS(Date())}})

While (Pergunte(cPrg, .T.))
	
	aParRet := {MV_PAR01, ALLTRIM(STR(MV_PAR02)), MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06}
	aLinAlt := {0, 1, 7}
	
	If(aParRet[1] > DaySum(DATE(),1))
		MsgInfo("Data nao pode ser maior que a de hoje. Abortando...", "Data Incorreta")
		Return (Nil)
	EndIf

	FWExecView('Nota de Manejo de Cocho','VAPCPA04', IIf(aParRet[1] <= GETMV("MV_ULMES"), MODEL_OPERATION_VIEW, MODEL_OPERATION_UPDATE), , { || .T. }, , ,aEnButt )
	
EndDo

//&(cAlias)->(DBSeek(xFilial(cAlias)+DTOS(aParRet[1])))
//DBSelectArea(cAlias)
//RegToMemory(cAlias, .F.)

Return (Nil)


Static Function MenuDef()

Local aRotina := {}

//ADD OPTION aRotina TITLE OemToAnsi("Pesquisar")  ACTION "PesqBrw"          	  OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi("Visualizar") ACTION "VIEWDEF.VAPCPA04"    OPERATION 2 ACCESS 0 // "Visualizar"
//ADD OPTION aRotina TITLE OemToAnsi("Incluir")    ACTION "VIEWDEF.VAPCPA04"    OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE OemToAnsi("Alterar")    ACTION "VIEWDEF.VAPCPA04"    OPERATION 4 ACCESS 0 // "Alterar"
//ADD OPTION aRotina TITLE OemToAnsi("Excluir")    ACTION "VIEWDEF.VAPCPA04"    OPERATION 5 ACCESS 0 // "Excluir"
//ADD OPTION aRotina TITLE OemToAnsi("Copiar")     ACTION "VIEWDEF.VAPCPA04"    OPERATION 9 ACCESS 0 // "Copiar"

Return aRotina


Static Function ModelDef()
 
// Cria a estrutura a ser usada no Modelo de Dados
Local oModel
Local oStruCabc	:= FWFormStruct(1,"Z0I", {|cCampo| AllTrim(cCampo)+"|" $ cCpoCabc})
Local oStruGrid := FWFormStruct(1,"Z0I", {|cCampo| AllTrim(cCampo)+"|" $ cCpoGrid})
//Local bLnVldVl  := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| VLDNOT(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
//Local bLnVldFl  := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| VLDFLD(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}

Local oMldAux, oStrAux, aFldAux

oModel := MPFormModel():New('U_VAPCPA04',/*bPreValidacao*/,,{|oMdl| SVDTM(oMdl)},/*bCancel*/)

oModel:AddFields(cAlias + "MASTER",/*cOwner*/,oStruCabc,/*bPreValidacao*/,/*bPosValidacao*/,{|| {xFilial("Z0I"), aParRet[1], aParRet[2],  Space(15), Space(6)}})
oModel:AddGrid( cAlias + "GRID", cAlias + "MASTER",oStruGrid, /*bLnVldVl*/,,,,{|oMdl| VLDDTM(oMdl)})

//oModel:SetRelation(cAlias + "GRID",{{"Z0I_FILIAL",'xFilial("Z0I")'},{"Z0I_DATA","Z0I_DATA"}},&(cAlias)->(IndexKey(1)))
oModel:SetPrimaryKey({"Z0I_FILIAL","Z0I_DATA","Z0I_CODIGO"})

oModel:SetOperation(4)

oModel:getModel(cAlias+"MASTER"):SetDescription("Dados do Lote")
oModel:getModel(cAlias+"GRID"):SetDescription("Notas de Manejo")

oModel:Activate()

Return oModel

	
Static Function ViewDef()
 
Local oModel := ModelDef() 
Local oView 
Local oStrCab := FWFormStruct(2, cAlias, {|cCampo| AllTrim(cCampo)+"|" $ cCpoCabc})
Local oStrDet := FWFormStruct(2, cAlias, {|cCampo| AllTrim(cCampo)+"|" $ cCpoGrid})
//Local oMdlDet := oModel:GetModel(cAlias + 'GRID')													
//Local cCSSGrd := ""

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VwField" + cAlias, oStrCab, cAlias + "MASTER")
oView:AddGrid("VwFieldA" + cAlias, oStrDet, cAlias + "GRID",, {|| FOCFLD()})
//oView:AddIncrementField('VwFieldA' + cAlias, 'Z0I_CODIGO')
	
oView:CreateHorizontalBox( "CABECALHO", 10)
oView:CreateHorizontalBox( "ITENS"    , 90)

oView:SetOwnerView("VwField"  + cAlias, "CABECALHO")
oView:SetOwnerView("VwFieldA" + cAlias, "ITENS")

oStrDet:SetProperty("*", MVC_VIEW_CANCHANGE , .F.)

If (oView:GetOperation() == MODEL_OPERATION_UPDATE)
	If (aParRet[2] == "1") //Manha
//		oStrDet:RemoveField("Z0I_NOTND2")
//		oStrDet:RemoveField("Z0I_NOTND3")
		oStrDet:SetProperty("Z0I_NOTMAN", MVC_VIEW_CANCHANGE, .T.)
	ElseIf (aParRet[2] == "2") //Tarde
//		oStrDet:RemoveField("Z0I_NOTND3")
//		oStrDet:RemoveField("Z0I_NOTMAN")
		oStrDet:SetProperty("Z0I_NOTTAR", MVC_VIEW_CANCHANGE, .T.)
	ElseIf (aParRet[2] == "3") //Noite
//		oStrDet:RemoveField("Z0I_NOTMAN")
//		oStrDet:RemoveField("Z0I_NOTTAR")
		oStrDet:SetProperty("Z0I_NOTNOI", MVC_VIEW_CANCHANGE, .T.)
	EndIf
Else
	oStrCab:SetProperty("Z0I_NOTTMP", MVC_VIEW_CANCHANGE, .F.)
EndIf

oStrCab:SetProperty("Z0I_DATA", MVC_VIEW_CANCHANGE, .F.)
oStrCab:SetProperty("Z0I_PERIOD", MVC_VIEW_CANCHANGE, .F.)

//oStrDet:SetProperty("*", MVC_VIEW_INSERTLINE, .T.)
oStrDet:SetProperty("*", MVC_VIEW_WIDTH, 80)

oView:SetViewProperty("VwFieldA" + cAlias, "ENABLENEWGRID")
oView:SetNoInsertLine("VwFieldA" + cAlias)
oView:SetNoDeleteLine("VwFieldA" + cAlias)

//cCSSGrd := "QTableView {text-align: right; alternate-background-color: red; background: yellow; selection-background-color: #669966;}" //"QTableView {text-align: justify-all;}"
//cCSSGrd += "QLineEdit {text-align: justify-all;}"

//oView:SetViewProperty("VwFieldA" + cAlias, "SETCSS", {cCSSGrd})	

Return oView


Static Function VLDDTM(oMdl)

Local aArea := GetArea()
Local cQryCur := ""
Local aClsCur := {}
Local aCpoCur := {}
Local cCodTmp := "0000000000"
Local cChvCur := ""
Local cChvLot := ""

DBSelectArea(cAlias)
(cAlias)->(DBSetOrder(1))

If (!(cAlias)->(DBSeek(xFilial(cAlias) + DTOS(aParRet[1]))))

	cQryCur := " SELECT Z08.Z08_LINHA AS LINHA, Z08.Z08_SEQUEN AS SEQ, Z08.Z08_CODIGO AS CURRAL, SB8.B8_LOTECTL AS LOTE " + CRLF
	//cQryCur += "       ,(SELECT SUM(Z04.Z04_TOTREA) FROM " + RetSqlName("Z04") +  " Z04 WHERE Z04.Z04_DTIMP  = DATEADD(dd, -1, cast('" + DTOS(aParRet[1]) + "' as datetime)) AND Z04.Z04_FILIAL = '" + xFilial("Z04") + "' AND Z04.D_E_L_E_T_ <> '*' AND Z04.Z04_LOTE = SB8.B8_LOTECTL) AS TOTREA " + CRLF 
	//cQryCur += "       ,(SELECT SUM(Z04.Z04_TOTAPR) FROM " + RetSqlName("Z04") +  " Z04 WHERE Z04.Z04_DTIMP  = DATEADD(dd, -1, cast('" + DTOS(aParRet[1]) + "' as datetime)) AND Z04.Z04_FILIAL = '" + xFilial("Z04") + "' AND Z04.D_E_L_E_T_ <> '*' AND Z04.Z04_LOTE = SB8.B8_LOTECTL) AS TOTAPR " + CRLF
	cQryCur += "       ,(SELECT SUM(Z0WA.Z0W_QTDPRE) Z0W_QTDPRE  FROM " + RetSqlName("Z0W") +  " Z0WA WHERE Z0WA.Z0W_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z0WA.Z0W_FILIAL = '" + xFilial("Z05") + "' AND Z0WA.D_E_L_E_T_ <> '*' AND Z0WA.Z0W_LOTE = SB8.B8_LOTECTL ) AS  TOTAPR " + CRLF
	cQryCur += "       ,(SELECT SUM(Z0WA.Z0W_QTDREA) Z0W_QTDREA  FROM " + RetSqlName("Z0W") +  " Z0WA WHERE Z0WA.Z0W_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z0WA.Z0W_FILIAL = '" + xFilial("Z05") + "' AND Z0WA.D_E_L_E_T_ <> '*' AND Z0WA.Z0W_LOTE = SB8.B8_LOTECTL ) AS  TOTREA " + CRLF
	cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 5)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS DIETD5 " + CRLF
	cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 5)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  KGMSD5 " + CRLF
	cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 5)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  CMSPV5  " + CRLF
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 5)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTMD5 " + CRLF     
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 5)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTTD5 " + CRLF   
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 5)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTND5 " + CRLF
	cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 4)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS DIETD4 " + CRLF
	cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 4)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  KGMSD4 " + CRLF
	cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 4)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  CMSPV4 " + CRLF
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 4)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTMD4 " + CRLF     
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 4)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTTD4 " + CRLF   
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 4)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTND4 " + CRLF
	cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 3)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS DIETD3 " + CRLF
	cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 3)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  KGMSD3 " + CRLF
	cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 3)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  CMSPV3 " + CRLF
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 3)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTMD3 " + CRLF     
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 3)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTTD3 " + CRLF   
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 3)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTND3 " + CRLF   
	cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 2)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS DIETD2 " + CRLF
	cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 2)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  KGMSD2 " + CRLF
	cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 2)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  CMSPV2 " + CRLF
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 2)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTMD2 " + CRLF   
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 2)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTTD2 " + CRLF   
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 2)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTND2 " + CRLF  
	cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS DIETD1 " + CRLF
	cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  KGMSD1" + CRLF
	cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  CMSPV1" + CRLF
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTMD1 " + CRLF  
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTTD1 " + CRLF  
	cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTND1 " + CRLF
	cQryCur += " FROM " + RetSqlName("SB8") +  " SB8 " + CRLF  
	cQryCur += " RIGHT JOIN " + RetSqlName("Z08") +  " Z08 ON Z08.Z08_CODIGO = SB8.B8_X_CURRA AND Z08.Z08_FILIAL = '" + xFilial("Z08") + "' AND Z08.D_E_L_E_T_ <> '*' " + CRLF   
 	cQryCur += " WHERE SB8.D_E_L_E_T_ <> '*' AND SB8.B8_X_CURRA <> '' AND SB8.B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF    
   	cQryCur += "   AND SB8.B8_SALDO > 0 " + CRLF
	cQryCur += " GROUP BY Z08.Z08_LINHA, Z08.Z08_SEQUEN, SB8.B8_X_CURRA, SB8.B8_LOTECTL, Z08.Z08_CODIGO " + CRLF
	cQryCur += " ORDER BY Z08.Z08_CODIGO--Z08.Z08_LINHA, Z08.Z08_SEQUEN, SB8.B8_LOTECTL " + CRLF 
	
	TCQUERY cQryCur NEW ALIAS "QRYCUR"
	
	MEMOWRITE("C:\TOTVS_RELATORIOS\MANCCHPRE.txt", cQryCur)
	
	DBSelectArea("Z0I")
	Z0I->(DBSetOrder(1))

	While (!(QRYCUR->(EOF())))
	
		cChvCur := QRYCUR->CURRAL  //ALLTRIM(QRYCUR->Z08_LINHA) + ALLTRIM(QRYCUR->Z08_SEQUEN)
		cChvLot := "'" + ALLTRIM(QRYCUR->LOTE) + "', "
		
		cCodTmp := Soma1(cCodTmp)
		
//		If (ALLTRIM(cChvCur) == ALLTRIM(cChvLot))
//		
//			aClsCur := {}
//			cChvLot := cChvLot + "'" + QRYCUR->B8_LOTECTL + "'"
//			
//			MsgInfo("O curral '" + cChvCur + "' possui dois lotes vinculados (" + cChvLot + "). Verifique o cadastro.", "Cadastro Curral x Lote")
//			
//			QRYCUR->(DBCloseArea())
//			RestArea(aArea)
//			Return (aClsCur)
//		EndIf
		
		RecLock("Z0I", .T.)
		
			Z0I->Z0I_FILIAL := xFilial("Z0I")
			Z0I->Z0I_DATA   := aParRet[1]
			Z0I->Z0I_RUA    := QRYCUR->LINHA
			Z0I->Z0I_SEQUEN := QRYCUR->SEQ
			Z0I->Z0I_CURRAL := QRYCUR->CURRAL
			Z0I->Z0I_CODIGO := cCodTmp
			Z0I->Z0I_TOTPRE := QRYCUR->TOTAPR
			Z0I->Z0I_TOTREA := QRYCUR->TOTREA
			Z0I->Z0I_LOTE   := QRYCUR->LOTE
			Z0I->Z0I_NOTMAN := Space(6)
			Z0I->Z0I_NOTTAR := Space(6)
			Z0I->Z0I_NOTNOI := Space(6)
			Z0I->Z0I_ORIGEM := "VAPCPA04"
		
		Z0I->(MsUnlock())
		
		QRYCUR->(DBSkip())		

	EndDo
	
	QRYCUR->(DBCloseArea())

EndIf

cQryCur := " SELECT Z0I.Z0I_CODIGO, Z0I.Z0I_RUA, Z0I.Z0I_SEQUEN, Z0I.Z0I_LOTE, Z0I.Z0I_CURRAL, Z0I.Z0I_NOTMAN, Z0I.Z0I_NOTTAR, Z0I.Z0I_NOTNOI, Z0I.Z0I_AJUSTE " + CRLF
//cQryCur += " ,ISNULL((SELECT cast(convert(datetime, '"+DtoS(ddatabase)+"', 103) - convert(datetime, MIN(Z0O.Z0O_DATAIN), 103) as numeric) +1  FROM Z0O010 Z0O WHERE Z0O_FILIAL = '01' AND Z0I.Z0I_LOTE = Z0O_LOTE AND Z0O.D_E_L_E_T_ = ' ' ),0) AS Z0I_DIASCO" + CRLF
cQryCur += " ,ISNULL((SELECT cast(convert(datetime, '"+DtoS(ddatabase)+"', 103) - convert(datetime, MIN(SB8.B8_XDATACO), 103) as numeric) +1  FROM " + RetSqlName("SB8") + " SB8 WHERE B8_FILIAL = '" + xFilial("SB8") + "' AND B8_LOTECTL = Z0I.Z0I_LOTE AND SB8.D_E_L_E_T_ = ' ' ),0) AS Z0I_DIASCO
cQryCur += "       ,(SELECT SUM(Z0WA.Z0W_QTDPRE) Z0W_QTDPRE  FROM " + RetSqlName("Z0W") +  " Z0WA WHERE Z0WA.Z0W_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z0WA.Z0W_FILIAL = '" + xFilial("Z05") + "' AND Z0WA.D_E_L_E_T_ <> '*' AND Z0WA.Z0W_LOTE = Z0I.Z0I_LOTE ) AS  Z0I_TOTPRE " + CRLF
cQryCur += "       ,(SELECT SUM(Z0WA.Z0W_QTDREA) Z0W_QTDREA  FROM " + RetSqlName("Z0W") +  " Z0WA WHERE Z0WA.Z0W_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z0WA.Z0W_FILIAL = '" + xFilial("Z05") + "' AND Z0WA.D_E_L_E_T_ <> '*' AND Z0WA.Z0W_LOTE = Z0I.Z0I_LOTE ) AS  Z0I_TOTREA " + CRLF
//cQryCur += "       ,(SELECT SUM(Z04.Z04_TOTREA) FROM Z04010 Z04 WHERE Z04.Z04_DTIMP  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z04.Z04_FILIAL = '" + xFilial("Z04") + "' AND Z04.D_E_L_E_T_ <> '*' AND Z04.Z04_LOTE = Z0I.Z0I_LOTE) AS Z0I_TOTPRE " + CRLF 
//cQryCur += "       ,(SELECT SUM(Z04.Z04_TOTAPR) FROM Z04010 Z04 WHERE Z04.Z04_DTIMP  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z04.Z04_FILIAL = '" + xFilial("Z04") + "' AND Z04.D_E_L_E_T_ <> '*' AND Z04.Z04_LOTE = Z0I.Z0I_LOTE) AS Z0I_TOTREA " + CRLF
cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 5)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS Z0I_DIETD5 " + CRLF
cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 5)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS  Z0I_KGMSD5 " + CRLF
cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 5)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS  Z0I_CMSPV5  " + CRLF
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 5)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTMD5 " + CRLF     
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 5)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTTD5 " + CRLF   
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 5)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTND5 " + CRLF
cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 4)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS Z0I_DIETD4 " + CRLF
cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 4)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS  Z0I_KGMSD4 " + CRLF
cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 4)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS  Z0I_CMSPV4 " + CRLF
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 4)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTMD4 " + CRLF     
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 4)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTTD4 " + CRLF   
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 4)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTND4 " + CRLF
cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 3)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS Z0I_DIETD3 " + CRLF
cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 3)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS  Z0I_KGMSD3 " + CRLF
cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 3)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS  Z0I_CMSPV3 " + CRLF     
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 3)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTMD3 " + CRLF
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 3)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTTD3 " + CRLF   
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 3)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTND3 " + CRLF   
cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 2)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS Z0I_DIETD2 " + CRLF
cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 2)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS  Z0I_KGMSD2 " + CRLF
cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 2)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS  Z0I_CMSPV2 " + CRLF   
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 2)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTMD2 " + CRLF
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 2)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTTD2 " + CRLF   
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 2)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTND2 " + CRLF  
cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS Z0I_DIETD1 " + CRLF
cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS  Z0I_KGMSD1" + CRLF
cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = Z0I.Z0I_LOTE AND Z05A.Z05_CURRAL = Z0I.Z0I_CURRAL) AS  Z0I_CMSPV1" + CRLF
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTMD1 " + CRLF  
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTTD1 " + CRLF  
cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(aParRet[1], 1)) + "' AND Z0IA.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE) AS Z0I_NOTND1 " + CRLF
cQryCur += " FROM " + RetSqlName("Z0I") +  " Z0I " + CRLF
cQryCur += " WHERE Z0I.D_E_L_E_T_ <> '*' AND Z0I.Z0I_FILIAL = '" + xFilial("Z0I") + "' AND Z0I.Z0I_DATA = '" + DTOS(aParRet[1]) + "' " + CRLF
cQryCur += "   AND Z0I.Z0I_RUA BETWEEN '" + aParRet[3] + "' AND '" + aParRet[4] + "' " + CRLF
cQryCur += "   AND Z0I.Z0I_LOTE BETWEEN '" + aParRet[5] + "' AND '" + aParRet[6] + "' " + CRLF    
cQryCur += " ORDER BY Z0I.Z0I_CURRAL--Z0I.Z0I_RUA, Z0I.Z0I_SEQUEN, Z0I.Z0I_LOTE, Z0I.Z0I_AJUSTE " + CRLF


TCQUERY cQryCur NEW ALIAS "QRYCUR"

MEMOWRITE("C:\TOTVS_RELATORIOS\MANCCH.txt", cQryCur)

DBSelectArea("Z0I")
Z0I->(DBSetOrder(1))

SX3->(DbSetOrder(1))
While (!(QRYCUR->(EOF())))
	SX3->(DbSeek("Z0I"))
	aCpoCur := {}
	While !SX3->(EoF()) .and. SX3->X3_ARQUIVO == "Z0I"
	    If alltrim(SX3->X3_CAMPO)+ "|" $ cCpoGrid
	        AAdd(aCpoCur, &("QRYCUR->"+SX3->X3_CAMPO))
	    EndIf 
	    SX3->(DbSkip())
	End
	AAdd(aClsCur, {0, aCpoCur})
	QRYCUR->(DBSkip())
EndDo

QRYCUR->(DBCloseArea())

RestArea(aArea)

Return (aClsCur)

//	AAdd(aClsCur, {0, {QRYCUR->CODIGO, QRYCUR->LINHA, QRYCUR->SEQ, QRYCUR->CURRAL, QRYCUR->TOTREA, QRYCUR->TOTAPR, QRYCUR->LOTE,; 
//	                   QRYCUR->Z0I_NOTTAR, QRYCUR->Z0I_NOTNOI, QRYCUR->Z0I_NOTMAN, ;
//	                   QRYCUR->DIETD1, QRYCUR->KGMSD1, QRYCUR->CMSPV1, QRYCUR->NOTTD1, QRYCUR->NOTND1, QRYCUR->NOTMD1, ; 
//	                   QRYCUR->DIETD2, QRYCUR->KGMSD2, QRYCUR->CMSPV2, QRYCUR->NOTTD2, QRYCUR->NOTND2, QRYCUR->NOTMD2, ; 
//	                   QRYCUR->DIETD3, QRYCUR->KGMSD3, QRYCUR->CMSPV3, QRYCUR->NOTTD3, QRYCUR->NOTND3, QRYCUR->NOTMD3, ; 
//	                   QRYCUR->DIETD4, QRYCUR->KGMSD4, QRYCUR->CMSPV4, QRYCUR->NOTTD4, QRYCUR->NOTND4, QRYCUR->NOTMD4, ; 
//	                   QRYCUR->DIETD5, QRYCUR->KGMSD5, QRYCUR->CMSPV5, QRYCUR->NOTTD5, QRYCUR->NOTND5, QRYCUR->NOTMD5 }})
	                   
	

Static Function SVDTM(oMdl)

Local aArea  := GetArea()
Local lVldSv := .T.
Local nCntLin := 1
Local cCmp    := ""

If(aParRet[2] == "1")
	cCmp := "Z0I_NOTMAN"
ElseIf(aParRet[2] == "2")
	cCmp := "Z0I_NOTTAR"
ElseIf(aParRet[2] == "3")
	cCmp := "Z0I_NOTNOI"
EndIf

DBSelectArea("Z0I")
Z0I->(DBSetOrder(1))

For nCntLin := 1 To oMdl:GetModel(cAlias+"GRID"):Length()

 	oMdl:GetModel(cAlias + "GRID"):GoLine(nCntLin)

	If (Z0I->(DBSeek(xFilial("Z0I")+DTOS(oMdl:GetValue(cAlias+"MASTER","Z0I_DATA"))+oMdl:GetValue(cAlias+"GRID","Z0I_CURRAL")+oMdl:GetValue(cAlias+"GRID","Z0I_LOTE"))))
		
		RecLock("Z0I", .F.)
		
			Z0I->Z0I_NOTMAN := oMdl:GetValue(cAlias+"GRID","Z0I_NOTMAN")
			Z0I->Z0I_NOTTAR := oMdl:GetValue(cAlias+"GRID","Z0I_NOTTAR")
			Z0I->Z0I_NOTNOI := oMdl:GetValue(cAlias+"GRID","Z0I_NOTNOI")
			
			If (!Empty(oMdl:GetValue(cAlias+"GRID", cCmp)))
				Z0I->Z0I_DATLOG := Date()
				Z0I->Z0I_HORLOG := SUBSTR(TIME(), 1, 5)
			EndIf
		
		Z0I->(MsUnlock())

	EndIf

Next nCntLin

RestArea(aArea)

Return (lVldSv)


User Function VLDNOT()

//Local aArea  := GetArea()
Local lVldNt := .T.
Local oMdlAt := FWModelActive()
Local oViwAt := FWViewActive()
Local oFld   
Local cCmp   := ""
Local cPrd   := ""
Local nLin   := aLinAlt[1] + 1//oMdlAt:GetModel(cAlias + "GRID"):GetLine()
//local nLin   := oMdlAt:GetModel(cAlias + "GRID"):GetLine()
Local cNot   := ""

If(aParRet[2] == "1")
	cCmp := "Z0I_NOTMAN"
	cPrd := "Manha"
ElseIf(aParRet[2] == "2")
	cCmp := "Z0I_NOTTAR"
	cPrd := "Tarde"
ElseIf(aParRet[2] == "3")
	cCmp := "Z0I_NOTNOI"
	cPrd := "Noite"
EndIf

cNot := &(ReadVar())

If (!Empty(cNot))

	DBSelectArea("Z0G")
	Z0G->(DBSetOrder(1))
	
	If(Z0G->(DBSeek(xFilial("Z0G")+cNot)))
	 	If(Z0G->Z0G_DISPON == "4")
	 		lVldNt := .T.
	 	ElseIf((aParRet[2] != Z0G->Z0G_DISPON))
	 		lVldNt := .F.
	 	EndIf
	Else
		lVldNt := .F.
	EndIf
	
	If !(lVldNt)
		MsgInfo("A Nota " + cNot  + " nao existe ou nao pode ser usada no periodo " + cPrd, "Nota de Cocho")
		ReadVar() := ""
	Else
		If (ReadVar() == "M->Z0I_NOTTMP")
		
			oMdlAt:GetModel(cAlias + "GRID"):GoLine(nLin)
		
			If (oMdlAt:GetModel(cAlias + "GRID"):SetValue(cCmp, M->Z0I_NOTTMP)) //FWFldPut(cCmp, M->Z0I_NOTTMP, nLin, oMdlAt,/* [ lShowMsg ]*/, /*[ lLoad ]*/))
				//if (oMdlAt:GetModel(cAlias + "GRID"):Length() > nLin)
					If (aLinAlt[1] == (aLinAlt[2] + aLinAlt[3]))
						aLinAlt[2] := aLinAlt[2] + aLinAlt[3] - 1
					elseif aLinAlt[1] > (aLinAlt[2] + aLinAlt[3]) .or. aLinAlt[1] < (aLinAlt[2] - aLinAlt[3])
						aLinAlt[2] := aLinAlt[1]
					EndIf
					oMdlAt:GetModel(cAlias + "GRID"):GoLine(aLinAlt[2]) //nLin+1
					aLinAlt[1] := nLin
				//EndIf
			EndIf
		EndIf		
		oViwAt:Refresh()
	EndIF
EndIf

//RestArea(aArea)

lVldNt := .T.

Return (lVldNt)


User Function VLDNOTC()

//Local aArea  := GetArea()
Local lVldNt := .T.
Local oMdlAt := FWModelActive()
Local oViwAt := FWViewActive()
Local oFld   
Local cCmp   := ""
Local cPrd   := ""
Local nLin   := oMdlAt:GetModel(cAlias + "GRID"):GetLine()
Local cNot   := ""

If(aParRet[2] == "1")
	cCmp := "Z0I_NOTMAN"
	cPrd := "Manha"
ElseIf(aParRet[2] == "2")
	cCmp := "Z0I_NOTTAR"
	cPrd := "Tarde"
ElseIf(aParRet[2] == "3")
	cCmp := "Z0I_NOTNOI"
	cPrd := "Noite"
EndIf

cNot := &(ReadVar())

If (!Empty(cNot))

	DBSelectArea("Z0G")
	Z0G->(DBSetOrder(1))
	
	If(Z0G->(DBSeek(xFilial("Z0G")+cNot)))
	 	If(Z0G->Z0G_DISPON == "4") //Todos
	 		lVldNt := .T.
	 	ElseIf(aParRet[2] != Z0G->Z0G_DISPON)
	 		lVldNt := .F.
	 	EndIf
	Else
		lVldNt := .F.
	EndIf
	
	If !(lVldNt)
		MsgInfo("A Nota " + cNot  + " nao existe ou nao pode ser usada no periodo " + cPrd, "Nota de Cocho")
		ReadVar() := ""
	Else
		aLinAlt[1] := nLin
		SVLIN(oMdlAt)
	EndIF
Else
	SVLIN(oMdlAt)
EndIf

//RestArea(aArea)

Return (lVldNt)


Static Function FOCFLD()

//Local aArea   := GetArea()
Local lFocFld := .T.
Local oMdlAt  := FWModelActive()
Local oViwAt  := FWViewActive()
Local nLin    := IIf((aLinAlt[1] + 1) > oMdlAt:GetModel(cAlias + "GRID"):Length(), aLinAlt[1], aLinAlt[1] + 1)

If (!Empty(M->Z0I_NOTTMP))
	oMdlAt:GetModel(cAlias + "MASTER"):SetValue("Z0I_CURLOT", ALLTRIM(oViwAt:GetValue(cAlias + "GRID", "Z0I_CURRAL", nLin)) + " (" + ALLTRIM(oViwAt:GetValue(cAlias + "GRID", "Z0I_LOTE", nLin)) + ")") //ALLTRIM(oMdlAt:GetValue(cAlias+"GRID","Z0I_CURRAL")) + " (" + ALLTRIM(oMdlAt:GetValue(cAlias+"GRID","Z0I_LOTE")) + ")"
	oMdlAt:GetModel(cAlias + "MASTER"):SetValue("Z0I_NOTTMP", "")
	M->Z0I_NOTTMP := ""
	oViwAt:Refresh()
	oViwAt:GetViewObj(cAlias+"MASTER")[3]:getFWEditCtrl("Z0I_NOTTMP"):oCtrl:SetFocus()
EndIf

//RestArea(aArea)

Return (lFocFld)


Static Function SVLIN(oMdl)
Local aArea  := GetArea()
Local aAreaZ0I := Z0I->(GetArea())
Local lVldSv := .T.
Local nCntLin := 1
Local cCmp    := ""

If(aParRet[2] == "1")
    cCmp := "Z0I_NOTMAN"
ElseIf(aParRet[2] == "2")
    cCmp := "Z0I_NOTTAR"
ElseIf(aParRet[2] == "3")
    cCmp := "Z0I_NOTNOI"
EndIf

DBSelectArea("Z0I")
Z0I->(DBSetOrder(1))

if Z0I->(DBSeek(xFilial("Z0I")+DTOS(oMdl:GetValue(cAlias+"MASTER","Z0I_DATA"))+oMdl:GetValue(cAlias+"GRID","Z0I_CURRAL")+oMdl:GetValue(cAlias+"GRID","Z0I_LOTE")))
    RecLock("Z0I", .f.)
    
        Z0I->Z0I_NOTMAN := Iif("Z0I_NOTMAN"$ReadVar(),&(ReadVar()),oMdl:GetValue(cAlias+"GRID","Z0I_NOTMAN"))
        Z0I->Z0I_NOTTAR := Iif("Z0I_NOTTAR"$ReadVar(),&(ReadVar()),oMdl:GetValue(cAlias+"GRID","Z0I_NOTTAR"))
        Z0I->Z0I_NOTNOI := Iif("Z0I_NOTNOI"$ReadVar(),&(ReadVar()),oMdl:GetValue(cAlias+"GRID","Z0I_NOTNOI"))
        
        If (!Empty(oMdl:GetValue(cAlias+"GRID", cCmp)))
            Z0I->Z0I_DATLOG := Date()
            Z0I->Z0I_HORLOG := SUBSTR(TIME(), 1, 5)
        EndIf
    
    Z0I->(MsUnlock())
endif

Z0I->(RestArea(aAreaZ0I))
RestArea(aArea)
Return (lVldSv)
 
