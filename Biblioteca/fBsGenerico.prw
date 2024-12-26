#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"
#Include "ApWizard.ch"
#INCLUDE "RPTDef.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"

User Function fBsGenerico(cTitulo,cQuery,cTopo,cTabela,cChave2,aTamanho)
	Local aArea := GetArea()
	Local aux   := 0
	Private cChave := If(Empty(cChave2),Space(50),cChave2)
	Private oGetDados, aHeadAux2:={},aColsAux2:={},aAlterFields2:={}, cRet := {}
	Private cCadastro
	Default aTamanho := {}
	

	oDlgGen := MSDialog():New( 200,400,630,1500,cTitulo,,,.F.,,,,,,.T.,,,.T. )
	
	oSay2		:= TSay():New( 005,005,{||"Chave:"},oDlgGen,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)		
	oChave    := TGet():New( 015,005,{|u| If(PCount()>0,cChave:=u,cChave)},oDlgGen,200,010,'',{|| MsgRun("Carregando dados...","Consulta",{|| fBsPes(cQuery) })},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cChave",,)
	
	If SELECT("QRYGEN")>0
		QRYGEN->(DbCloseArea())
	Endif				
	
	TCQuery cQuery New Alias QRYGEN
	
	QRYGEN->(DbGoTop())	
	For aux := 1 To Len(cTopo)
		aAdd(aHeadAux2,	{cTopo[aux],cTopo[aux],"@!", If( Len(aTamanho)>0,aTamanho[aux],Len(cTopo[aux])+005), 0,	".F.",	".F.",	"C", "", "",})
	Next aux	
	
	If !(QRYGEN->(EoF()))
		While !(QRYGEN->(EoF()))
			colunas := {}
			aCampos := StrTokArr(QRYGEN->Resultado,";")
			For aux := 1 To Len(aCampos)
				aAdd(colunas,aCampos[aux])
			Next aux
			aAdd(colunas,.F.)
			aAdd(aColsAux2,colunas)
			QRYGEN->(dbSkip())
		EndDo	
	Else
		colunas := {}
		For aux := 1 To Len(aHeadAux2)
			aAdd(colunas,"")
		Next aux
		aAdd(colunas,.F.)
		aAdd(aColsAux2,colunas)
	EndIf
	
	QRYGEN->(DbCloseArea())
	
	oGetDados := MsNewGetDados():New( 035, 005, 210, 543, , "AllwaysTrue", "AllwaysTrue", "", aAlterFields2,, 4, "AllwaysTrue", "", "AllwaysTrue", oDlgGen, aHeadAux2, aColsAux2)
    oGetDados:oBrowse:bLDblClick := {||fBsSel(oGetDados:nAt)}
	
	If !Empty(cTabela) 
		cCadastro:= OemToAnsi("Incluir")
		oIncluir := TButton():New( 015,403,"Incluir",oDlgGen	,{||AxInclui(cTabela,"Incluir"),fBsPes(cQuery) },040,012,,,,.T.,,"",,,,.F. )
	EndIf	
	//oSelecionar := TButton():New( 168,263,"Selecionar",oDlgGen	,{ || fBsSel(oGetDados:nAt)},040,012,,,,.T.,,"",,,,.F. )
	oSair := TButton():New( 015,503,"Sair",oDlgGen	,{ || fBsSair()},040,012,,,,.T.,,"",,,,.F. )
	
	If !Empty(cChave2)
		fBsPes(cQuery)
		oGetDados:oBrowse:SetFocus()
	EndIf 
			
	oDlgGen:Activate(,,,.T.)

	RestArea(aArea)
Return cRet

Static Function fBsPes(cQuery)
    Local aux := 0

	aColsAux2 := {}
	cQuery := Replace(cQuery,"%%","%"+AllTrim(cChave)+"%")	
	If SELECT("QRYGEN")>0
		QRYGEN->(DbCloseArea())
	Endif					
	TCQuery cQuery New Alias QRYGEN
	If !(QRYGEN->(EoF()))
		While !(QRYGEN->(EoF()))
			colunas := {}
			aCampos := StrTokArr(QRYGEN->Resultado,";")
			For aux := 1 To Len(aCampos)
				aAdd(colunas,aCampos[aux])
			Next aux
			aAdd(colunas,.F.)
			aAdd(aColsAux2,colunas)
			QRYGEN->(dbSkip())
		EndDo	
	Else
		colunas := {}
		For aux := 1 To Len(oGetDados:aHeader)
			aAdd(colunas,"")
		Next aux
		aAdd(colunas,.F.)
		aAdd(aColsAux2,colunas)
	EndIf
	QRYGEN->(DbCloseArea())
	
	oGetDados:aCols := aColsAux2
	oGetDados:Refresh()
	oGetDados:GoTop()
Return Nil

Static Function fBsSel(nPosicao)
local nCampo :=0
	If Len(oGetDados:aCols) > 0
		For nCampo:= 1 To Len(oGetDados:aHeader)
			Aadd(cRet,oGetDados:aCols[nPosicao,nCampo])
		Next nCampo
		oDlgGen:End()
	EndIf
Return Nil

Static Function fBsSair()
	oDlgGen:End()
Return Nil
                                  


///////////////////////////////////////////////////////////////////////
//	cRet := U_fBsGenerico("Naturezas",cQuery,{"Natureza","Descricao","Porc.IR","Calc.IR","Calc.Pis","Calc.Cofins","Calc.CSLL","Calc.ISS","Calc.INSS","R_E_C_N_O_"},,,{010,040,010,010,010,010,010,010,010,010})

// consulta NATUREZAS
User  Function CONSEDX()
	Local lRet 			:= .T.
	Local cRet 			:= {}
	Local nRecnoCon 
	Local cCodCon		:= ""
	Public __retSEDX 	:= ""
	cQuery := " SELECT TOP 100 ED_CODIGO+';'+ED_DESCRIC+';'+CAST(CAST(ED_PERCIRF AS NUMERIC(18,2)) AS VARCHAR(18))+';'+ED_CALCIRF+';'+ED_CALCPIS+';'+ED_CALCCOF+';'+ED_CALCCSL+';'+ED_CALCISS+';'+ED_CALCINS+';'+ cast(R_E_C_N_O_  as varchar) AS RESULTADO FROM "+RetSqlName("SED")+" WHERE D_E_L_E_T_ = '' AND (ED_DESCRIC LIKE '%%' OR ED_CODIGO LIKE '%%' ) "
	cRet := U_fBsGenerico("Naturezas",cQuery,{"Natureza","Descricao","Porc.IR","Calc.IR","Calc.Pis","Calc.Cofins","Calc.CSLL","Calc.ISS","Calc.INSS","R_E_C_N_O_"},,,{010,040,010,010,010,010,010,010,010,010})
	If Len(cRet) > 0
		__retSEDX 	:= cRet[1]   
		cCodCon  	:= cRet[1]
		nRecnoCon 	:= val(cRet[10])
	EndIf
Return lRet    


// consulta Centro de Custos
User  Function CONCTTX()
//SELECT CTT_CUSTO, CTT_DESC01, CTT_CCSUP FROM CTT010 WHERE D_E_L_E_T_ = '' AND CTT_CLASSE ='2' AND CTT_BLOQ <> '1'
	Local lRet 			:= .T.
	Local cRet 			:= {}
	Local nRecnoCon 
	Local cCodCon		:= ""
	Public __retCTTX 	:= ""
	cQuery := " SELECT TOP 100 CTT_CUSTO+';'+CTT_DESC01+';'+CTT_CCSUP+';'+ cast(R_E_C_N_O_  as varchar) AS RESULTADO FROM "+RetSqlName("CTT")+" WHERE D_E_L_E_T_ = '' AND (CTT_DESC01 LIKE '%%' OR CTT_CUSTO LIKE '%%' ) AND CTT_CLASSE ='2' AND CTT_BLOQ <> '1' "
	cRet := U_fBsGenerico("Centro de Custos",cQuery,{"Centro de Custo","Descricao","CC Superior","R_E_C_N_O_"},,,{020,080,015,010})
	If Len(cRet) > 0
		__retCTTX 	:= cRet[1]   
		cCodCon  	:= cRet[1]
		nRecnoCon 	:= val(cRet[4])
	EndIf
Return lRet    



// consulta MUNICIPIOS X5 = TABELA S1
User  Function CONX5S1X()
// SELECT X5_CHAVE, X5_DESCRI FROM SX5010 WHERE X5_TABELA = 'S1' AND D_E_L_E_T_ = '' 
	Local lRet 			:= .T.
	Local cRet 			:= {}
	Local nRecnoCon 
	Local cCodCon		:= ""
	Public __retS1X 	:= ""
	cQuery := " SELECT TOP 100 X5_CHAVE+';'+X5_DESCRI+';'+ cast(R_E_C_N_O_  as varchar) AS RESULTADO FROM "+RetSqlName("SX5")+" WHERE X5_TABELA = 'S1' AND D_E_L_E_T_ = ''  AND (X5_DESCRI LIKE '%%' OR X5_CHAVE LIKE '%%' ) "

	cRet := U_fBsGenerico("Municipios ZF",cQuery,{"Codigo","Municipio","R_E_C_N_O_"},,,{020,080,010})
	If Len(cRet) > 0
		__retS1X 	:= cRet[1]   
		cCodCon  	:= cRet[1]
		nRecnoCon 	:= val(cRet[3])
	EndIf
Return lRet    




// consulta Pedido de Compras para Diaria
User  Function CONC7DI()
	Local lRet 			:= .T.
	Local cRet 			:= {}
	Local nRecnoCon 
	Local cCodCon		:= ""
	Public __retDIC7 	:= ""
	Public __retDI2C7 	:= ""
	Public __retDI3C7 	:= ""
	Public __retDI4C7 	:= ""
	Public __retDI5C7 	:= ""

	cQuery := " SELECT C7_NUM+';'+C7_FORNECE+';'+C7_LOJA+';'+A2_NOME+';'+C7_PRODUTO+';'+B1_DESC+';'+CAST(CAST(C7_PRECO AS NUMERIC(18,6)) AS VARCHAR(18))+';'+CAST(CAST(C7_QUANT AS NUMERIC(18,6)) AS VARCHAR(18))+';'+CAST(CAST(C7_QUJE AS NUMERIC(18,6)) AS VARCHAR(18))+';'+C7_OBS+';'+ cast(SC7.R_E_C_N_O_  as varchar) AS RESULTADO "
	cQuery += " FROM " + RetSqlName("SC7") +" SC7 "
	cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON (B1_FILIAL='" + Xfilial("SB1") + "' AND B1_COD=C7_PRODUTO AND SB1.D_E_L_E_T_='') "
	cQuery += " LEFT JOIN "+RetSqlName("SA2")+" SA2 ON (A2_FILIAL='" + Xfilial("SA2") + "' AND A2_COD=C7_FORNECE AND A2_LOJA=C7_LOJA AND SA2.D_E_L_E_T_='') "
	cQuery += " WHERE SC7.D_E_L_E_T_ = '' "
	cQuery += " AND B1_X_DIARI='S'  AND C7_CONAPRO = 'L' AND C7_QUANT-C7_QUJE>0  "
	cQuery += " AND (C7_PRODUTO LIKE '%%' OR C7_OBS LIKE '%%'  OR C7_FORNECE LIKE '%%' OR B1_DESC LIKE '%%' OR A2_NOME LIKE '%%' ) "

	cRet := U_fBsGenerico("Pedido x Diárias",cQuery,{"Pedido","Fornecedor","Loja","R.Social/Nome","Cod.Prod.","Descricao Produto","Preço Unit.","Quant.Orig.","Quant.Entreg.","Observacoes","R_E_C_N_O_"},,,{008,007,003,045,010,055,010,010,010,060,010})



	If Len(cRet) > 0
		__retDIC7 	:= cRet[1]   
		__retDI2C7 	:= cRet[2]   
		__retDI3C7 	:= cRet[3]   
		__retDI4C7 	:= cRet[5]   
		__retDI5C7 	:= cRet[7]   
		cCodCon  	:= cRet[1]
		nRecnoCon 	:= val(cRet[11])
	EndIf
Return lRet    

