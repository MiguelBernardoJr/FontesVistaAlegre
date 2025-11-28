#include "totvs.ch"
#include "apvt100.ch"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} VABxExp
Rotina de baixa dos itens no armazém EX - ACD
@author Cristiam Rossi
@since 14/09/2025
@type function
/*/
user function VABxExp()
local   cCodOpe  := CBRetOpe()
local   cOrdSep
private cTM      := superGetMV( "FS_ORDSEPT",, "512" )
private cCUSTO   := superGetMV( "FS_ORDSEPC",, "A0240" )
private cArmEX   := superGetMV( "FS_ORDSEPA",, "EX" )
private aRegs    := {}

	SB1->( dbSetOrder(1) )

	if empty( cCodOpe )
		VTAlert("Operador nao cadastrado","Sem Cadastro",.T.,4000,3)
		return nil
	endif

	if ! chkArmazem()
		return nil
	endif

	while .T.
		cOrdSep := Space(TamSX3("CB9_ORDSEP")[1])
		cVolume := ""
		aRegs    := {}

		vtClear()
		@ 0,0 VtSay "-= Bx Expedicao =-"

		@ 2,0 VtSay "Ordem Separacao:"
		@ 3,0 VTGet cOrdSep PICT "@!" F3 "CB7" Valid OrdSepVal( cOrdSep )
		vtRead
		If VTLastKey() == 27
			exit
		EndIf

		@ 5,0 VtSay "  favor aguarde"
		@ 6,0 VtSay "realizando baixas"

//		cQry :=	"SELECT CB9_PROD, LEAST(CB9_QTESEP, coalesce(B2_QATU,0)) QTDE"
		cQry :=	"SELECT CB9_PROD, " + CRLF
		cQry +=	"    CB9_NUMSA, " + CRLF
		cQry +=		"CASE WHEN CB9_QTESEP > coalesce(B2_QATU,0) THEN coalesce(B2_QATU,0) ELSE CB9_QTESEP END QTDE" + CRLF
		cQry +=	" FROM " + RetSqlName('CB9') + " CB9 " + CRLF
		cQry +=	" left join " + RetSqlName("SB2") + " SB2 " + CRLF
		cQry += 	" on B2_FILIAL = '"+xFilial("SB2")+"'" + CRLF
		cQry += 	" and B2_COD=CB9_PROD" + CRLF
		cQry += 	" and B2_LOCAL='"+cArmEX+"'" + CRLF
		cQry += 	" and SB2.D_E_L_E_T_=' '" + CRLF
		cQry +=	" WHERE CB9_FILIAL = '"+xFilial("CB9")+"'" + CRLF
		cQry +=	" AND CB9_ORDSEP = '"+cOrdSep+"'" + CRLF
		cQry +=	" AND CB9.D_E_L_E_T_ = ' '" + CRLF
		cQry +=  " ORDER BY CB9_PROD, CB9_NUMSA" + CRLF
		
		cAlias := MpSysOpenQuery(cQry)

		While ! (cAlias)->( eof() )
			if (cAlias)->QTDE > 0
				aAdd( aRegs, { (cAlias)->CB9_PROD, (cAlias)->QTDE, cArmEX,  (cAlias)->CB9_NUMSA} )
			endif
			(cAlias)->( dbSkip() )
		endDo
		(cAlias)->( dbCloseArea() )

		if len( aRegs ) > 0
			bxEstoque( aRegs )
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
static function OrdSepVal( cOrdSep )
local aStatus := {"em Separacao","Finalizada","Emb. iniciada","Emb. finalizada","com NF","com NF","Etiq Oficiais","Embarcando","Embarcada"}

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

	If CB7->CB7_STATUS  $ "1_3456789"
		VtAlert("Ordem de Separacao com status "+aStatus[val(CB7->CB7_STATUS)],"Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))
		Return .F.
	EndIf
return .T.


/*/{Protheus.doc} bxEstoque
    realiza baixa no estoque
	@author Cristiam Rossi
	@since 14/09/2025
	@type function
/*/
Static Function bxEstoque( aRegs )
	local cDocumento := Criavar("D3_DOC")
	local nI
	local aAux
	local cCusto1    := cCUSTO
	local aCab241    := {}
	local aItens241  := {}
	Local lOrdemSevico := .F. 

	STL->(DBSetOrder(15))//TL_FILIAL+TL_NUMSA+TL_ITEMSA

	SCP->( dbSetOrder(1) )
	if ! empty( aRegs[1,4] ) .and. SCP->( dbSeek( xFilial("SCP") + aRegs[1,4] ) ) 
		if STL->(DbSeek(SCP->CP_FILIAL+SCP->CP_NUM+SCP->CP_ITEM))
			lOrdemSevico := .T. 
		endif
	endif

	lMsHelpAuto := .T.
	lMsErroAuto := .F.

	IF !lOrdemSevico
		cDocumento	:= IIf( Empty(cDocumento) , NextNumero("SD3",2,"D3_DOC",.T.) , cDocumento)
		cDocumento	:= A261RetINV(cDocumento)

		aCab241 := {{ "D3_DOC"    , cDocumento, NIL },;
					{ "D3_TM"     , cTM       , NIL },;
					{ "D3_CC"     , cCusto1   , Nil },;
					{ "D3_EMISSAO", dDataBase , Nil }}

		for nI := 1 to len( aRegs )
			criaSaldo( aRegs[nI,1], cArmEX )

			if !empty( aRegs[nI,4] ) .and. SCP->( dbSeek( xFilial("SCP") + aRegs[nI,4] ) ) 
				if !empty(SCP->CP_CC)
					cCusto1 := SCP->CP_CC
				Endif
			endif

			aAux := {}
			aAdd( aAux, { "D3_COD"    , aRegs[nI,1], NIL } )
			aAdd( aAux, { "D3_LOCAL"  , aRegs[nI,3], NIL } )
			aAdd( aAux, { "D3_QUANT"  , aRegs[nI,2], NIL } )
			aAdd( aAux, { "D3_CC"     , cCusto1    , NIL } )

			if ! empty( SCP->CP_CONTA )
				aAdd( aAux, { "D3_CONTA"  , SCP->CP_CONTA	, NIL } )
			endif
			if ! empty( SCP->CP_ITEMCTA ) 
				aAdd( aAux, { "D3_ITEMCTA", SCP->CP_ITEMCTA	, NIL } )
			endif

			aAdd( aAux, { "D3_NUMSA"      , SCP->CP_NUM	, NIL } )
			//aAdd( aAux, { "D3_XSEPSA"     , CB7->CB7_ORDSEP	, NIL } )

			aAdd( aItens241, aClone( aAux ) )
		next

		if len( aItens241 ) > 0
			MSExecAuto({|x,y,z| Mata241(x,y,z)},aCab241,aItens241,Nil)
			If lMsErroAuto
				MostraErro()
			else
				SD3->(DbSetOrder(2))
				SD3->(DbSeek(xFilial("SD3")+cDocumento))
				While !SD3->(EOF()) .AND. SD3->D3_FILIAL == xFilial("SD3") .and. cDocumento == SD3->D3_DOC
					RecLock("SD3",.F.)
						SD3->D3_NUMSA := SCP->CP_NUM
					msunlock()
					SD3->(DbSkip())
				EndDo

				reclock("CB7",.F.)
					CB7->CB7_STATUS := "9"
				msunlock()
			EndIf
		EndIf
	else
		for nI := 1 to len( aRegs )
			cDocumento	:= NextNumero("SD3",2,"D3_DOC",.T.)
			cDocumento	:= A261RetINV(cDocumento)

			SCP->( dbSetOrder(1) )
			if SCP->( dbSeek( xFilial("SCP") + aRegs[nI,4] ) ) .and. ! empty( SCP->CP_CC )
				cCusto1 := SCP->CP_CC
			endif

			aCab241 := {{ "D3_DOC"    , cDocumento, NIL },;
						{ "D3_TM"     , cTM       , NIL },;
						{ "D3_CC"     , cCusto1   , Nil },;
						{ "D3_EMISSAO", dDataBase , Nil }}

			criaSaldo( aRegs[nI,1], cArmEX )

			aAux := {}
			aItens241 := {}

			aAdd( aAux, { "D3_COD"    , aRegs[nI,1], NIL } )
			aAdd( aAux, { "D3_LOCAL"  , aRegs[nI,3], NIL } )
			aAdd( aAux, { "D3_QUANT"  , aRegs[nI,2], NIL } )
			aAdd( aAux, { "D3_CC"     , cCusto1    , NIL } )

			if ! empty( SCP->CP_CONTA )
				aAdd( aAux, { "D3_CONTA"  , SCP->CP_CONTA	, NIL } )
			endif
			if ! empty( SCP->CP_ITEMCTA ) 
				aAdd( aAux, { "D3_ITEMCTA", SCP->CP_ITEMCTA	, NIL } )
			endif

			aAdd( aAux, { "D3_NUMSA"      , SCP->CP_NUM	, NIL } )
			//aAdd( aAux, { "D3_XSEPSA"     , CB7->CB7_ORDSEP	, NIL } )

			aAdd( aItens241, aClone( aAux ) )

			if len( aItens241 ) > 0
				MSExecAuto({|x,y,z| Mata241(x,y,z)},aCab241,aItens241,Nil)
				If lMsErroAuto
					MostraErro()
				else
					SD3->(DbSetOrder(2))
					SD3->(DbSeek(xFilial("SD3")+cDocumento))
					While !SD3->(EOF()) .AND. SD3->D3_FILIAL == xFilial("SD3") .and. cDocumento == SD3->D3_DOC
						RecLock("SD3",.F.)
							SD3->D3_NUMSA := SCP->CP_NUM
						msunlock()
						SD3->(DbSkip())
					EndDo
					
					reclock("CB7",.F.)
						CB7->CB7_STATUS := "9"
					msunlock()
				EndIf
			EndIf
		next
	endif

return nil


/*/{Protheus.doc} chkArmazem
Verifica a existencia ou cria o armazém do parâmetro FS_ORDSEPA
@author Cristiam Rossi
@since 11/09/2025
@type function
/*/
static function chkArmazem()
local oModel := FWLoadModel( 'AGRA045' )
local lOk    := .T.

	NNR->( dbSetOrder(1) )
	if ! NNR->( dbSeek( xFilial("NNR") + cArmEX ) )
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()

		oModel:SetValue("NNRMASTER", "NNR_CODIGO", cArmEX )
		oModel:SetValue("NNRMASTER", "NNR_DESCRI", "Expedicao ACD" )

		if oModel:VldData()
			oModel:CommitData()
		else
			autoGrLog( cValToChar(oModel:GetErrorMessage()[6]) )
			mostraErro()
			lOk := .F.
		endif
		oModel:DeActivate()
	endif

	freeobj( oModel )
return lOk


/*/{Protheus.doc} criaSaldo()
    cria movimentação - saldo inicial do produto
	@author Cristiam Rossi
	@since 12/09/2025
	@type function
/*/
static function criaSaldo( cProd, cLocal )
	local aProdSB9 := {}

	SB2->( dbSetOrder(1) )
	if SB2->( dbSeek( xFilial("SB2") + padR(cProd, len(SB2->B2_COD)) + padR(cLocal, len(SB2->B2_LOCAL)) ) )
		return nil
	endif

	aadd(aProdSB9,{"B9_COD"  , cProd ,})
	aadd(aProdSB9,{"B9_LOCAL", cLocal,})
	aadd(aProdSB9,{"B9_CM1"  , 0     ,})	
	MSExecAuto({|x,y| mata220(x,y)},aProdSB9,3)		
	If lMsErroAuto
		mostraErro()
	EndIf

return nil
