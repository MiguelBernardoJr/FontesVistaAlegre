#include "totvs.ch"
#include "topconn.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Class TExFilter
Classe extendida da MsDialog para exibir uma tela de filtro

@author Renato de Bianchi
@since 17/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
user function TExFilter()
	/*obj := TExFilter():New("SZ8",{"Z8_CODIGO", "Z8_DESC"}, "Etapas do Processo")
	for nI := 1 to len(obj:aSelect)
		alert(obj:aSelect[nI,1])
	next
	
	obj := TExFilter():New("SB1",{"B1_COD", "B1_DESC"}, "Produtos")
	for nI := 1 to len(obj:aSelect)
		alert(obj:aSelect[nI,1])
	next
	
	obj := TExFilter():New("SA1",{"A1_COD", "A1_NOME"}, "Clientes")
	for nI := 1 to len(obj:aSelect)
		alert(obj:aSelect[nI,1])
	next*/
return

class TExFilter from TObject
	data sAlias
	data aCampos
	data aSelect
	data sTblSX5
	data sCondicao
	
	method New() constructor
endClass 

method New(sAlias, aCampos, sCaption, sTblSX5, lOnlyRes, sCondicao, aSelect) class TExFilter
local nOpcG	:= GD_UPDATE
local nOpcA	:= 0
Local nI    := 0
Local nX    := 0
Local x     := 0
local cSql		:= ""
Private cBusca   := space(40)
Private aPCampos := aCampos


Private oWnd, oGetEsp
Private aHeadEsp := {}
Private aColsEsp := {}
Private nUsadEsp := 0

Default lOnlyRes := .F.
Default sCondicao := ""
Default aSelect := {}

::sAlias := sAlias
::aCampos := aCampos
::aSelect := {}
::sTblSX5 := sTblSX5
::sCondicao := sCondicao

if len(aSelect) > 0
	::aSelect := aSelect
endIf

if len(::aCampos) < 2
	return
endIf

cSql := "select distinct 'LBNO' STATUS_ "
for nI := 1 to len(::aCampos)
	cSql += ", "+::aCampos[nI]
next
cSql += "  from "+retSqlName(::sAlias)+" where D_E_L_E_T_=' ' and "+iif(substr(::sAlias,1,1)=='S',substr(::sAlias,2),::sAlias)+"_FILIAL='"+xFilial(::sAlias)+"' "
if !empty(::sTblSX5) .and. ::sAlias=="SX5"
	cSql += " and X5_TABELA='"+::sTblSX5+"'"
endIf
if !empty(::sCondicao)
	cSql += " and ("+::sCondicao+")"
endIf

cSql += " order by 3"
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),"QTMP",.F.,.T.)

if !QTMP->(Eof())
	
	aAdd(aHeadEsp,{ " "			, "STATUS_"			,"@BMP"		, 001, 0,""             ,""  , "C", "", "V","","","","V","","",""})
	for nI := 1 to len(::aCampos)
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek( ::aCampos[nI] )
			aAdd(aHeadEsp,{ X3Titulo( ::aCampos[nI] )	, ::aCampos[nI]		, X3Picture( ::aCampos[nI] )		, TamSX3(::aCampos[nI])[1], TamSX3(::aCampos[nI])[2],"AllwaysTrue()", "" , "C", "", "V","","","","V","","",""})
		endIf
	endFor
	//aAdd(aHeadEsp,{ X3Titulo( ::aCampos[2] )	, ::aCampos[2]		, X3Picture( ::aCampos[2] )		, 030, 0,"AllwaysTrue()", "" , "C", "", "V","","","","V","","",""})
	nUsadEsp := len(aHeadEsp)
	
	aColsEsp := {}
	aObj := {}
	while !QTMP->(Eof())
		aAdd(aColsEsp, array(nUsadEsp+1))   
		for nX := 1 to nUsadEsp
			if aHeadEsp[nX,8]=='D'
				aColsEsp[Len(aColsEsp),nX]:=STOD( QTMP->( FieldGet(FieldPos(aHeadEsp[nX,2])) ) )
			else
				aColsEsp[Len(aColsEsp),nX]:=QTMP->( FieldGet(FieldPos(aHeadEsp[nX,2])) )
			endIf
		next		
		aColsEsp[len(aColsEsp), nUsadEsp+1] := .F.
		
		if (aScan(::aSelect, {|x| x[1]==aColsEsp[len(aColsEsp),2]}) > 0)
			aColsEsp[len(aColsEsp), 1] := "LBTIK"
			aAdd(aObj, {aColsEsp[len(aColsEsp),2], aColsEsp[len(aColsEsp),3]})
		endIf
		/*beginSQL alias "MRK"
			%noParser%
			select 1 from %table:szu% 
			 where zu_alias=%exp:sAlias% 
			   and zu_usuario=%exp:__cUserID%
			   and zu_valor=%exp:aColsEsp[len(aColsEsp),2]%
		endSQL
		if !MRK->(Eof())
			aColsEsp[len(aColsEsp), 1] := "LBTIK"
			aAdd(aObj, {aColsEsp[len(aColsEsp),2], aColsEsp[len(aColsEsp),3]})
		endIf
		MRK->(dbCloseArea())*/
		
		QTMP->(dbSkip())
	endDo
	//::aSelect := aClone(aObj)
	
	If Len(aColsEsp) <= 0
		aColsEsp := { Array(nUsadEsp+1) } 
		aColsEsp[1, nUsadEsp+1] := .F.    
	EndIf
	
	oFont := TFont():New ("Century Gothic", 08, 16,,.F.)
	
	nSup := 10
	nEsq := 10
	nDir := 290
	nInf := 175
	
	if !lOnlyRes
		define MsDialog oWnd title "Filtro - "+sCaption from 0,0 to 400,600 pixel
			oLayer := fwLayer():New()
			
			If(Type("oMainWnd") != "O")
				oMainWnd := oWnd
			EndIf
			
			oLayer:Init(oWnd,.F.,.T.)
			oLayer:AddLine("L1",100,.F.)
			oLayer:AddCollumn("C1",100,.F.,"L1")
			oWndL1C1 := oLayer:getColPanel("C1","L1")
			
			oTtu1  := tSay():New(nSup, nEsq,{|| "Seleção de "+sCaption },oWndL1C1,,oFont,,,,.T.,,,200,100)
			
			@ nSup+2,nDir-45-60 MSGET oBusca VAR cBusca PICTURE "@!" SIZE 060,010 OF oWndL1C1 PIXEL
			oSeek2	:= TButton():New( nSup, nDir-45, "Procurar" ,oWndL1C1, {|| SeekVal(cBusca) },45,15,,,.F.,.T.,.F.,,.F.,,,.F.)
			
			nSup += 20
			oGetEsp := MsNewGetDados():New(nSup, nEsq, nInf, nDir, nOpcG,,,,,, 999999,,,,oWndL1C1, aHeadEsp, aColsEsp)
			oGetEsp:oBrowse:bLDblClick := {|| dClickObj() }
			nSup    := nInf + 5
			//oBtnS	:= TButton():New( nSup, nDir-55, "Salvar", oWndL1C1, {|| slvParam(), msgInfo("Parametros salvos com sucesso.") },50,15,,,.F.,.T.,.F.,,.F.,,,.F.)
			oBtnL	:= TButton():New( nSup, nDir-55, "Marc/Des Todos", oWndL1C1, {|| clrParam() },50,15,,,.F.,.T.,.F.,,.F.,,,.F.)
			oBtnE	:= TButton():New( nSup, nEsq, "OK", oWndL1C1, {|| nOpcA := 1, oWnd:End() },50,15,,,.F.,.T.,.F.,,.F.,,,.F.)
			oBtnC	:= TButton():New( nSup, nEsq+55, "Cancelar", oWndL1C1, {|| nOpcA := 0, oWnd:End() },50,15,,,.F.,.T.,.F.,,.F.,,,.F.)
		activate MsDialog oWnd centered
	endIf
endIf
QTMP->(dbCloseArea())

aObj := {}
if nOpcA==1
	for x := 1 to len(oGetEsp:aCols)
		if oGetEsp:aCols[x,1]=="LBTIK"
			aAdd(aObj, {oGetEsp:aCols[x,2], oGetEsp:aCols[x,3]})
		endIf
	next
	//slvParam(sAlias)
	::aSelect := aClone(aObj)
endIf

return



Static Function SeekVal(pBusca)
Local nPos  := 0
Local nX    := 0
Local nPVal := 0 

for nX := 2 to len(aPCampos)+1
	//nPVal := Ascan(aHeadEsp,{|x| trim(x[2])==trim(aPCampos[nX]) })
	//nPos := Ascan(aColsEsp,{|x| trim(substr(x[nX],1,len(trim(pBusca))))==trim(pBusca) })
	//nPos := Ascan(aColsEsp,{|x| trim(substr(x[nX],1,len(trim(pBusca))))==trim(pBusca) })
	if nPos == 0
		nPos := Ascan(aColsEsp,{|x| at(trim(pBusca), trim(upper(x[nX]))) > 0 })
		If nPos = 0 .and. nX==len(aPCampos)+1
			MsgAlert("Valor nao encontrado!","ATENCAO")
		Else
			if nPos > 0
				oGetEsp:oBrowse:nAt := nPos
				//nX := len(aPCampos)+1
			endIf
		EndIf
	endIf
next
oGetEsp:oBrowse:Refresh()

Return



static function clrParam()
Local x := 0

	cMrk := iif(oGetEsp:aCols[1,1]=="LBNO","LBTIK","LBNO")
	for x := 1 to len(oGetEsp:aCols)
		oGetEsp:aCols[x,1] := cMrk
	next
return


/*
//Função para salvar as opções selecionadas
static function slvParam(pAlias)
	cSql := "delete from "+retSQLName("SZU")
	cSql += " where zu_filial='"+xFilial("SZU")+"' "
	cSql += "   and zu_alias='"+pAlias+"' " 
	cSql += "   and zu_usuario='"+__cUserId+"' "
	If (TcSQLExec(cSql) < 0)
		conOut("NAO LIMPOU PERGUNTAS SZU")
	endIf
	for x := 1 to len(oGetEsp:aCols)
		if oGetEsp:aCols[x,1]=="LBTIK"
			dbSelectArea("SZU")
			RecLock("SZU", .T.)
			SZU->ZU_FILIAL	:= xFilial("SZU")			
			SZU->ZU_ALIAS		:= pAlias
			SZU->ZU_USUARIO	:= __cUserID
			SZU->ZU_VALOR		:= oGetEsp:aCols[x,2]
			MsUnlock()
		endIf
	next
return*/


static function dClickObj()
	oGetEsp:aCols[oGetEsp:oBrowse:nAt,1] := iif(oGetEsp:aCols[oGetEsp:oBrowse:nAt,1]=="LBNO","LBTIK","LBNO")
	
	/*nInd := oGetEsp:oBrowse:nAt+1
	while substr( allTrim(oGetEsp:aCols[nInd,2]),1,len(allTrim(oGetEsp:aCols[oGetEsp:oBrowse:nAt,2])) )==allTrim(oGetEsp:aCols[oGetEsp:oBrowse:nAt,2])
		oGetEsp:aCols[nInd,1] := oGetEsp:aCols[oGetEsp:oBrowse:nAt,1]
		nInd++
	endDo*/
	
	oGetEsp:oBrowse:Refresh()
return
