// #########################################################################################
// Projeto: JRModelos
// Fonte  : JRMOD1
// ---------+------------------------------+------------------------------------------------
// Data     | Autor: JRScatolon            | Descricao: Cadastro de Operador
// ---------+------------------------------+------------------------------------------------
// aaaammdd | <email>                      | <Descricao da rotina>
//          |                              |  
//          |                              |  
// ---------+------------------------------+------------------------------------------------

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

User Function VAPCPA12()

Local aArea     := GetArea()
Local oBrowse

Private aRotina	:= MenuDef()
Private cAlias  := "Z0U"
Private cDescri := Posicione("SX2", 1, cAlias, "X2_NOME")
Private __cMat	:= CriaVar('Z0U_MAT', .F.)


oBrowse := FwmBrowse():New()
oBrowse:SetAlias(cAlias)
oBrowse:SetDescription(cDescri)
oBrowse:Activate()

RestArea(aArea)

Return


Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE OemToAnsi("Pesquisar")  ACTION "PesqBrw"       	  OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi("Visualizar") ACTION "VIEWDEF.VAPCPA12"    OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE OemToAnsi("Incluir")    ACTION "VIEWDEF.VAPCPA12"    OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE OemToAnsi("Alterar")    ACTION "VIEWDEF.VAPCPA12"    OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE OemToAnsi("Excluir")    ACTION "VIEWDEF.VAPCPA12"    OPERATION 5 ACCESS 0 // "Excluir"
ADD OPTION aRotina TITLE OemToAnsi("Copiar")     ACTION "VIEWDEF.VAPCPA12"    OPERATION 9 ACCESS 0 // "Copiar"

Return aRotina

Static Function ModelDef()

Local oModel := Nil
Local oField := Nil

oField := FwFormStruct(1,cAlias)
oModel := MpFormModel():New("U_VAPCPA12", /*bPreValid*/,,,/*Cancel*/)

//-- campos
oModel:AddFields("MdField" + cAlias,,oField,/*bPreValid*/, /*bPosValid*/,)
oModel:SetPrimaryKey({cAlias + "_FILIAL",cAlias + "_CODIGO"})

oField:SetProperty("Z0U_CODIGO", MODEL_FIELD_INIT,{|| VaGetX8(/* "Z0U", */ "Z0U_CODIGO")})

Return oModel

Static Function ViewDef()

Local oField := FwFormStruct(2,cAlias)
Local oModel := FwLoadModel("VAPCPA12")

oView := FwFormView():New()
oView:SetModel(oModel)

//View X Model
oView:AddField("VwField" + cAlias, oField, "MdField" + cAlias)

//separaï¿½ï¿½o da tela
oView:CreateHorizontalBox("CABECALHO",100)

//visï¿½es da tela
oView:SetOwnerView("VwField" + cAlias, "CABECALHO")

Return oView

User Function PCPA12FN()
    Local aArea			:= GetArea()
    Local _cQry  		:= ""
    Local lRet   		:= .F. 
	
	if Type("uRetorno") == 'U' 
		public uRetorno
	endif

	uRetorno := ''

	_cQry := " SELECT RA_MAT " + CRLF
	_cQry += "			, RA_NOME " + CRLF
	_cQry += "		    , R_E_C_N_O_ SRARECNO " + CRLF
	_cQry += "	FROM " + RetSqlName("SRA")+ " " + CRLF
	_cQry += "	WHERE RA_FILIAL = '"+FWxFilial("SRA")+"'" + CRLF
	_cQry += "	AND RA_DEMISSA = ''  " + CRLF
	_cQry += "	AND D_E_L_E_T_ = '' " + CRLF
	_cQry += "	ORDER BY 1" + CRLF
	 
    if u_F3Qry( _cQry, 'MATRICULA', 'SRARECNO', @uRetorno,, { "RA_MAT", "RA_NOME" } )
       	SRA->(DbGoto( uRetorno ))
			__cMat 	:= SRA->RA_MAT
		lRet := .t. 
    endif

if aArea[1] <> "SRA"
    RestArea( aArea )
endif
RETURN lRet

Static Function VaGetX8(cCampo)
	Local aArea 	    := GetArea()
	Local cCod 		    := ''
	Local _cQry 	    := ''

	DbSelectArea(cAlias)
	
	_cQry := " select MAX("+ cCampo +") cMAX FROM " + RetSqlName(cAlias) 

 	DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(_cQry)), "__TMP", .T., .F.)

	If !__TMP->(Eof())
		cCod := __TMP->cMAX
	EndIF

	if (cCod == StrZero(0, TamSX3(cCampo)[1]))
		cCod := StrZero(1, TamSX3(cCampo)[1] - 1 ) //-1 pq já tinha alguns cadastros com 5 digitos, e teria que mecher em muitas tabelas.
	else  
		cCod := StrZero(Val(cCod)+1, TamSX3(cCampo)[1] - 1)
	ENDIF

	__TMP->(DbCloseArea())
	RestArea(aArea)

RETURN cCod
