#include "totvs.ch"
#include "apvt100.ch"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} VAOrdExt
Rotina de estorno de ordem de separação - ACD
@author Cristiam Rossi
@since 13/09/2025
@type function
/*/
user function VAOrdExt()
local   cCodOpe  := CBRetOpe()
local   cOrdSep
local   aRegs
local   nI
local   cMotivo  := ""
private aMotivos := {}
private cCUSTO   := superGetMV( "FS_ORDSEPC",, "A0240" )
private cArmDest := superGetMV( "FS_ORDSEPA",, "EX" )

	SB1->( dbSetOrder(1) )

	if empty( cCodOpe )
		VTAlert("Operador nao cadastrado","Sem Cadastro",.T.,4000,3)
		return nil
	endif

	chkTabela()		// tabela de motivos

	while .T.
		cOrdSep := Space(TamSX3("CB9_ORDSEP")[1])
		aRegs   := {}

		vtClear()
		@ 0,0 VtSay "ESTORNO SEPARACAO"

		@ 2,0 VtSay "Ordem Separacao:"
		@ 3,0 VTGet cOrdSep PICT "@!" F3 "CB7" Valid OrdSepVal( cOrdSep, cCodOpe )
		vtRead
		If VTLastKey() == 27
			exit
		EndIf

		aTela := VTSave()
		VTClear()
		@ 0,0 VTSay "Selecione"
		nPos := VTaBrowse(1,0,VTMaxRow(),VtmaxCol(),{"Motivo","Codigo"},aMotivos,{VtmaxCol(), 6})
	
		If VtLastkey() == 27
			loop
		EndIf
		cMotivo := aMotivos[nPos,2]
		VtRestore(,,,,aTela)

		@ 4,0 VtSay left( cMotivo, VTMaxRow() )

		@ 5,0 VtSay "estornando..."

		cQry :=	" SELECT CB9.R_E_C_N_O_ REG, CB9_PROD, CB9_QTESEP"
		cQry +=	" FROM " + RetSqlName('CB9') + " CB9 "
		cQry +=	" WHERE CB9_FILIAL = '"+xFilial("CB9")+"'"
		cQry +=	" AND CB9_ORDSEP = '"+cOrdSep+"'"
		cQry +=	" AND CB9.D_E_L_E_T_ = ' '"
		cQry +=  " ORDER BY CB9_PROD"
		cAlias := MpSysOpenQuery(cQry)

		While ! (cAlias)->( eof() )
			aAdd( aRegs, { "CB9", (cAlias)->REG, (cAlias)->CB9_PROD, (cAlias)->CB9_QTESEP } )
			(cAlias)->( dbSkip() )
		endDo
		(cAlias)->( dbCloseArea() )

		cQry :=	" SELECT CB8.R_E_C_N_O_ REG"
		cQry +=	" FROM " + RetSqlName('CB8') + " CB8 "
		cQry +=	" WHERE CB8_FILIAL = '"+xFilial("CB8")+"'"
		cQry +=	" AND CB8_ORDSEP = '"+cOrdSep+"'"
		cQry +=	" AND CB8.D_E_L_E_T_ = ' '"
		cQry +=  " ORDER BY CB8_PROD"
		cAlias := MpSysOpenQuery(cQry)

		While ! (cAlias)->( eof() )
			aAdd( aRegs, { "CB8", (cAlias)->REG } )
			(cAlias)->( dbSkip() )
		endDo
		(cAlias)->( dbCloseArea() )

		if movEstoque( aRegs, cMotivo )
			for nI := 1 to len( aRegs )
				dbSelectArea( aRegs[nI,1] )
				dbGoTo( aRegs[nI,2] )

				recLock( aRegs[nI,1], .F. )
				dbDelete()
				msUnlock()
			next

			recLock( "CB7", .F. )
			dbDelete()
			msUnlock()

			SCP->( dbSetOrder(1) )
			SCP->( dbSeek( xFilial("SCP") + CB7->CB7_NUMSA ) )
			while ! SCP->( eof() ) .and. SCP->CP_NUM == CB7->CB7_NUMSA
				recLock( "SCP", .F. )
				SCP->CP_ORDSEP := ""
				msUnlock()
				SCP->( dbSkip() )
			endDo
		endif
	endDo

return nil


/*/{Protheus.doc} OrdSepVal
validação do número da ordem de separação
@author Cristiam Rossi
@since 04/09/2025
@type function
@return logical, Num Sep validado
/*/
static function OrdSepVal( cOrdSep, cCodOpe )
local aStatus := {"em Separacao","Finalizada","Emb. iniciada","Emb. finalizada","com NF","com NF","Etiq Oficiais","Embarcando","Embarcada"}
local cMsg    := "Ord.Sep: " + cOrdSep

	If Empty(cOrdSep)
		VtKeyBoard(chr(23))
		Return .f.
	EndIf

	CB7->(DbSetOrder(1))
	If ! CB7->(DbSeek(xFilial("CB7")+cOrdSep))
		VtAlert("Ordem de separacao nao encontrada.","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))
		Return .F.
	EndIf

	If CB7->CB7_STATUS  $ "123456789"
		cMsg += " status: "+aStatus[val(CB7->CB7_STATUS)]
	EndIf

	If ! VTYesNo( cMsg + ". Deseja continuar ?", "Estorno",.T.)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
return .T.


/*/{Protheus.doc} movEstoque()
    realiza movimento de transferência no estoque
	@author Cristiam Rossi
	@since 04/09/2025
	@type function
/*/
Static Function movEstoque( aRegs, cMotivo )
local aRotAuto  := {}
local cDocumento := Criavar("D3_DOC")
local nI
local aAux
local nItem     := 0
local cCusto1   := cCUSTO

	SCP->( dbSetOrder(1) )
	if ! empty( CB7->CB7_NUMSA ) .and. SCP->( dbSeek( xFilial("SCP") + CB7->CB7_NUMSA ) ) .and. ! empty( SCP->CP_CC )
		cCusto1 := SCP->CP_CC 
	endif

	lMsHelpAuto := .T.
	lMsErroAuto := .F.

	cDocumento	:= IIf( Empty(cDocumento) , NextNumero("SD3",2,"D3_DOC",.T.) , cDocumento)
	cDocumento	:= A261RetINV(cDocumento)

	aAdd(aRotAuto, {cDocumento, dDataBase})

	for nI := 1 to len( aRegs )
		if aRegs[nI,1] != "CB9"
			loop
		endif

		aAux := {}
		AADD( aAux , { "ITEM", strZero( ++nItem, len( SD3->D3_ITEM ) ), nil } )

		SB1->( dbSeek( xFilial("SB1") + aRegs[nI,3] ))

		// Produto Origem
		AADD( aAux , {"D3_COD"    , SB1->B1_COD   , nil } )
		AADD( aAux , {"D3_DESCRI" , SB1->B1_DESC  , nil } )
		AADD( aAux , {"D3_UM"     , SB1->B1_UM    , nil } )
		AADD( aAux , {"D3_LOCAL"  , cArmDest      , nil } )
		AADD( aAux , {"D3_LOCALIZ", ""            , nil } )
		// Produto Destino
		AADD( aAux , {"D3_COD"    , SB1->B1_COD   , nil } )
		AADD( aAux , {"D3_UM"     , SB1->B1_UM    , nil } )
		AADD( aAux , {"D3_LOCAL"  , SB1->B1_LOCPAD, nil } )
		AADD( aAux , {"D3_LOCALIZ", ""            , nil } )
		//
		AADD( aAux , {"D3_NUMSERI", ""            , nil } )
		AADD( aAux , {"D3_LOTECTL", ""            , nil } )
		AADD( aAux , {"D3_NUMLOTE", ""            , nil } )
		AADD( aAux , {"D3_DTVALID", CtoD("  /  /  ")     , nil } )
		AADD( aAux , {"D3_POTENCI", CriaVar("D3_POTENCI"), nil } )
		AADD( aAux , {"D3_QUANT"  , aRegs[nI,4]   , nil } )	// Qtde
		AADD( aAux , {"D3_QTSEGUM", CriaVar("D3_QTSEGUM"), nil } )
		AADD( aAux , {"D3_ESTORNO", CriaVar("D3_ESTORNO"), nil } )
		AADD( aAux , {"D3_NUMSEQ" , CriaVar("D3_NUMSEQ") , nil } )
		AADD( aAux , {"D3_LOTECTL", ""            , nil } )
		AADD( aAux , {"D3_NUMLOTE", ""            , nil } )
		AADD( aAux , {"D3_DTVALID", CtoD("  /  /  ")     , nil } )
		AADD( aAux , {"D3_ITEMGRD", ""            , nil } )
		AADD( aAux , {"D3_OBSERVA", "Ext S.A.: " + CB7->CB7_NUMSA, nil } )
		AADD( aAux , {"D3_CC"     , cCusto1       , nil } )
		aAdd( aRotAuto, aClone( aAux ) )
	next

	if len( aRotAuto ) > 1
		MSExecAuto( {|x,y| Mata261(x,y)}, aRotAuto, 3)
		If lMsErroAuto
			MostraErro()
		else
			SD3->(DbSetOrder(2))
			SD3->(DbSeek(xFilial("SD3")+cDocumento))
			while ! SD3->( eof() ) .and. SD3->D3_FILIAL == xFilial("SD3") .and. SD3->D3_DOC == cDocumento
				recLock("SD3",.F.)
				SD3->D3_XMOTIV := cMotivo
				SD3->D3_NUMSA    := CB7->CB7_NUMSA
				SD3->D3_XSEPSA    := CB7->CB7_ORDSEP
				msUnlock()
				SD3->( dbSkip() )
			endDo
		EndIf
	EndIf

return ! lMsErroAuto


/*/{Protheus.doc} chkTabela()
    Verifica tabela de motivos de cancelamento/estorno
	carrega motivos no array aMotivos
	@author Cristiam Rossi
	@since 13/09/2025
	@type function
/*/
static function chkTabela()
local cTabela := "E-"

	if ! SX5->( dbSeek( xFilial("SX5") + "00" + cTabela ))
		recLock("SX5",.T.)
		SX5->X5_FILIAL := xFilial("SX5")
		SX5->X5_TABELA := "00"
		SX5->X5_CHAVE  := cTabela
		SX5->X5_DESCRI := "Motivos estorno Ord.Separacao"
		msUnlock()

		recLock("SX5",.T.)
		SX5->X5_FILIAL := xFilial("SX5")
		SX5->X5_TABELA := cTabela
		SX5->X5_CHAVE  := "001"
		SX5->X5_DESCRI := "Solicitado errado"
		msUnlock()

		recLock("SX5",.T.)
		SX5->X5_FILIAL := xFilial("SX5")
		SX5->X5_TABELA := cTabela
		SX5->X5_CHAVE  := "002"
		SX5->X5_DESCRI := "Manutencao cancelada"
		msUnlock()
	endif

	SX5->( dbSeek( xFilial("SX5") + cTabela ))
	while ! SX5->( eof() ) .and. SX5->X5_TABELA == cTabela
		aAdd( aMotivos, { left( SX5->X5_DESCRI, 30 ), SX5->X5_CHAVE } )
		SX5->( dbSkip() )
	endDo
return nil
