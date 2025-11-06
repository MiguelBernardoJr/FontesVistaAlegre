#include "totvs.ch"
#include "apvt100.ch"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} VAOrdSep
Rotina de execução de separação - ACD
@author Cristiam Rossi
@since 04/09/2025
@type function
/*/
user function VAOrdSep()
local   cCodOpe  := CBRetOpe()
local   cOrdSep
local   cVolume
private cCodEmb  := superGetMV( "FS_ORDSEPE",, "001" )    // CB3->CB3_CODEMB
private cTM      := superGetMV( "FS_ORDSEPT",, "512" )
private cCUSTO   := superGetMV( "FS_ORDSEPC",, "A0240" )
private cArmDest := superGetMV( "FS_ORDSEPA",, "EX" )
private aBipados := {}

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
		aBipados := {}

		vtClear()
		@ 0,0 VtSay "-= Separacao =-"

		@ 2,0 VtSay "Ordem Separacao:"
		@ 3,0 VTGet cOrdSep PICT "@!" F3 "CB7" Valid OrdSepVal( cOrdSep, cCodOpe )
		vtRead
		If VTLastKey() == 27
			exit
		EndIf

		IniProcesso( cCodOpe )

		cCB8Qry :=	" SELECT CB8.R_E_C_N_O_ REG, B1_LOCALI, B1_DESC, B1_COD"
		cCB8Qry +=	" FROM " + RetSqlName('CB8') + " CB8 "
		cCB8Qry +=	" join " + RetSqlName('SB1') + " SB1 "
		cCB8Qry +=  	" on  B1_FILIAL='"+xFilial("SB1")+"'"
		cCB8Qry +=		" and B1_COD = CB8_PROD"
		cCB8Qry +=		" and SB1.D_E_L_E_T_ = ' '"
		cCB8Qry +=	" WHERE CB8_FILIAL = '"+xFilial("CB8")+"'"
		cCB8Qry +=	" AND CB8_ORDSEP = '"+cOrdSep+"'"
		cCB8Qry +=	" AND CB8_SALDOS > 0 "
		cCB8Qry +=	" AND CB8.D_E_L_E_T_ = ' '"
		cCB8Qry +=  " ORDER BY B1_LOCALI, CB8_PROD"
		cAliasCB8 := MpSysOpenQuery(cCB8Qry)

		DbSelectArea("STL")
		STL->(DBSetOrder(15))//TL_FILIAL+TL_NUMSA+TL_ITEMSA

		While ! (cAliasCB8)->( eof() )
			CB8->(dbGoTo((cAliasCB8)->REG))

			If Empty(CB8->CB8_SALDOS) // ja separado
				(cAliasCB8)->(DbSkip())
				Loop
			EndIf

			if empty( cVolume )
				cVolume := geraVol()
			endif

			while CB8->CB8_SALDOS > 0
				cEtiqueta := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
				nQtde     := 1

				vtClear()
					@ 0,0 VtSay "-= Separacao =-"
					@ 1,0 VTsay "ir p/ local:" + (cAliasCB8)->B1_LOCALI
					@ 2,0 VTsay "Cod Prod: " + left( (cAliasCB8)->B1_COD, VTmaxCol() )
					@ 3,0 VTsay left( (cAliasCB8)->B1_DESC, VTmaxCol() )
					@ 4,0 VTsay "Saldo: " + cValToChar( CB8->CB8_SALDOS )
					@ 5,0 VTsay "Qtde:"
					@ 5,6 VTGet nQtde Picture "9999" valid nQtde > 0 .and. nQtde <= CB8->CB8_SALDOS

					@ 6,0 VTsay "Etiqueta:"
					@ 7,0 VTGet cEtiqueta Picture "@!" valid valEtiq(@cEtiqueta)
					VTkeyboard( chr(13) )
				vtRead
				If VTLastKey() == 27
					exit
				EndIf

				IF STL->(DbSeek(CB8->CB8_FILIAL+CB8->CB8_NUMSA+CB8->CB8_ITEMSA))
					aAdd( aBipados, { SB1->B1_COD, SB1->B1_LOCPAD, 0 , alltrim( SB1->B1_DESC ), SB1->B1_UM , STL->TL_ORDEM, CB8->CB8_NUMSA} )
					nPos := len( aBipados )
				ELSE
					if ( nPos := aScan( aBipados, {|it| it[1] == SB1->B1_COD} ) ) == 0
						aAdd( aBipados, { SB1->B1_COD, SB1->B1_LOCPAD, 0 , alltrim( SB1->B1_DESC ), SB1->B1_UM , "" , CB8->CB8_NUMSA} )
						nPos := len( aBipados )
					endif
				endif
				aBipados[nPos,3] := aBipados[nPos,3] + nQtde

				recLock( "CB8", .F. )
					CB8->CB8_SALDOS := CB8->CB8_SALDOS - nQtde
				msUnlock()

				CB9->( dbSetOrder(15) )
				If ! CB9->( dbSeek( xFilial("CB9")+ CB8->(CB8_ORDSEP+CB8_PROD+CB8_NUMSA) ) )
					recLock("CB9",.T.)
						CB9->CB9_FILIAL := xFilial("CB9")
						CB9->CB9_ORDSEP := CB7->CB7_ORDSEP
						CB9->CB9_PROD   := CB8->CB8_PROD
						CB9->CB9_CODSEP := CB7->CB7_CODOPE
						CB9->CB9_ITESEP := CB8->CB8_ITEM
						CB9->CB9_SEQUEN := CB8->CB8_SEQUEN
						CB9->CB9_LOCAL  := CB8->CB8_LOCAL
						CB9->CB9_NSERSU := CB8->CB8_NUMSER
						CB9->CB9_PEDIDO := CB8->CB8_PEDIDO
						CB9->CB9_VOLUME := cVolume
						CB9->CB9_TRT	:= CB8->CB8_TRT
						CB9->CB9_NUMSA  := CB8->CB8_NUMSA
				else
					recLock("CB9",.F.)
				EndIf
				CB9->CB9_QTESEP += nQtde
				CB9->CB9_STATUS := "1"  // separado
				CB9->( msUnlock() )
			endDo

			(cAliasCB8)->( dbSkip() )
		endDo
		(cAliasCB8)->( dbCloseArea() )

		FimProcess()
		movEstoque()
	endDo
	
	STL->( dbCloseArea() )

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

	If CB7->CB7_STATUS  $ "23456789"
		VtAlert("Ordem de Separacao com status "+aStatus[val(CB7->CB7_STATUS)],"Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))
		Return .F.
	EndIf

	If CB7->CB7_STATPA == "1" .AND. CB7->CB7_CODOPE != cCodOpe  // SE ESTIVER EM SEPARACAO E PAUSADO SE DEVE VERIFICAR SE O OPERADOR E" O MESMO
		VtBeep(3)
		If ! VTYesNo("Ordem Separacao iniciada pelo operador "+CB7->CB7_CODOPE+". Deseja continuar ?","Aviso",.T.)
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	EndIf
return .T.


/*/{Protheus.doc} geraVol
    Criação de Volume automática
	@author Cristiam Rossi
	@since 27/08/2025
	@type function
/*/
static function geraVol()
local cCodVol := CB6->(GetSX8Num("CB6","CB6_VOLUME"))

    ConfirmSX8()
    RecLock("CB6",.T.)
		CB6->CB6_FILIAL := xFilial("CB6")
		CB6->CB6_VOLUME := cCodVol
		CB6->CB6_PEDIDO := CB7->CB7_PEDIDO
		CB6->CB6_NOTA   := CB7->CB7_NOTA
		CB6->CB6_SERIE  := CB7->CB7_SERIE
		CB6->CB6_TIPVOL := cCodEmb  //"001"    // CB3->CB3_CODEMB
		CB6->CB6_STATUS := "1"   // ABERTO
    CB6->(MsUnlock())
return cCodVol


/*/{Protheus.doc} valEtiq
    Valida leitura da etiqueta de código de barras ou código do produto
	@author Cristiam Rossi
	@since 04/09/2025
	@type function
	@return logical, leitura do produto OK
/*/
static function valEtiq(cEtiqueta)
//	if alltrim( cEtiqueta ) != alltrim( CB8->CB8_PROD )
		SB1->( dbSetOrder(5) )
		if ! SB1->( dbSeek( xFilial("SB1") + alltrim(cEtiqueta) ) )
			SB1->( dbSetOrder(1) )
			if ! SB1->( dbSeek( xFilial("SB1") + alltrim(cEtiqueta) ) )
				VtAlert("Produto nao localizado","Aviso",.t.,4000,3)
				VtKeyboard(Chr(20))
				return .F.
			endif
		endif

		if SB1->B1_COD != CB8->CB8_PROD
			VtAlert("Produto incorreto","Aviso",.t.,4000,3)
			VtKeyboard(Chr(20))
			return .F.
		endif
		cEtiqueta := SB1->B1_COD
//	endif
return .T.


/*/{Protheus.doc} IniProcesso
    ajusta status da separação para Iniciada
	@author Cristiam Rossi
	@since 04/09/2025
	@type function
/*/
Static Function IniProcesso( cCodOpe )
	recLock("CB7",.F.)
	If CB7->CB7_STATUS == "0" .or. Empty(CB7->CB7_STATUS) // nao iniciado
		CB7->CB7_STATUS := "1"  // em separacao
		CB7->CB7_DTINIS := dDataBase
		CB7->CB7_HRINIS := LEFT(TIME(),5)
	EndIf
	CB7->CB7_STATPA := " "  // se estiver pausado tira o STATUS  de pausa
	CB7->CB7_CODOPE := cCodOpe
	CB7->(MsUnlock())
return nil


/*/{Protheus.doc} FimProcess()
    ajusta status da separação para Finalizada ou Pausada
	@author Cristiam Rossi
	@since 04/09/2025
	@type function
/*/
static function FimProcess()

	cCB8Qry :=	" SELECT count(*) NITENS"
	cCB8Qry +=	" FROM " + RetSqlName('CB8') + " CB8 "
	cCB8Qry +=	" WHERE CB8_FILIAL = '"+xFilial("CB8")+"'"
	cCB8Qry +=	" AND CB8_ORDSEP = '"+CB7->CB7_ORDSEP+"'"
	cCB8Qry +=	" AND CB8_SALDOS > 0 "
	cCB8Qry +=	" AND CB8.D_E_L_E_T_ = ' '"
	cAliasCB8 := MpSysOpenQuery(cCB8Qry)

	recLock("CB7", .F.)
	if ! (cAliasCB8)->( eof() ) .and. (cAliasCB8)->NITENS > 0
		CB7->CB7_STATUS := "1"  // separando
		CB7->CB7_STATPA := "1"  // Em pausa
		CB7->CB7_DTFIMS := Ctod("  /  /  ")
		CB7->CB7_HRFIMS := "     "
	else
		CB7->CB7_STATUS := "2" // separacao finalizada
		CB7->CB7_STATPA := " "
		CB7->CB7_DTFIMS := dDataBase
		CB7->CB7_HRFIMS := LEFT(TIME(),5)
	endif
	msUnlock()
	(cAliasCB8)->( dbCloseArea() )
return nil


/*/{Protheus.doc} movEstoque()
    realiza movimento de transferência no estoque
	@author Cristiam Rossi
	@since 04/09/2025
	@type function
/*/
Static Function movEstoque()
local aRotAuto  := {}
local cDocumento := Criavar("D3_DOC")
local nI
local aAux
local cCusto1   := cCUSTO

	vtClear()
	@ 0,0 VtSay "-= Separacao =-"
	@ 2,0 VtSay "favor aguarde"
	@ 3,0 VtSay "transf estoque"
	@ 4,0 VtSay "p/ " + cArmDest


	lMsHelpAuto := .T.
	lMsErroAuto := .F.
	
	SCP->( dbSetOrder(1) )
	IF empty(aBipados[1,6])
		cDocumento	:= IIf( Empty(cDocumento) , NextNumero("SD3",2,"D3_DOC",.T.) , cDocumento)
		cDocumento	:= A261RetINV(cDocumento)
		aAdd(aRotAuto, {cDocumento, dDataBase})

		for nI := 1 to len( aBipados )
			aAux := {}

			criaSaldo( aBipados[nI,1], cArmDest )

			if ! empty( aBipados[nI,7] ) .and. SCP->( dbSeek( xFilial("SCP") + aBipados[nI,7] ) ) .and. ! empty( SCP->CP_CC )
				cCusto1 := SCP->CP_CC 
			endif

			AADD( aAux , { "ITEM", strZero( nI, len( SD3->D3_ITEM ) ), nil } )

			// Produto Origem
			AADD( aAux , {"D3_COD"    , aBipados[nI,1], nil } )
			AADD( aAux , {"D3_DESCRI" , aBipados[nI,4], nil } )
			AADD( aAux , {"D3_UM"     , aBipados[nI,5], nil } )
			AADD( aAux , {"D3_LOCAL"  , aBipados[nI,2], nil } )
			AADD( aAux , {"D3_LOCALIZ", ""            , nil } )
			// Produto Destino
			AADD( aAux , {"D3_COD"    , aBipados[nI,1], nil } )
			AADD( aAux , {"D3_UM"     , aBipados[nI,5], nil } )
			AADD( aAux , {"D3_LOCAL"  , cArmDest      , nil } )
			AADD( aAux , {"D3_LOCALIZ", ""            , nil } )
			//
			AADD( aAux , {"D3_NUMSERI", ""            , nil } )
			AADD( aAux , {"D3_LOTECTL", ""            , nil } )
			AADD( aAux , {"D3_NUMLOTE", ""            , nil } )
			AADD( aAux , {"D3_DTVALID", CtoD("  /  /  ")     , nil } )
			AADD( aAux , {"D3_POTENCI", CriaVar("D3_POTENCI"), nil } )
			AADD( aAux , {"D3_QUANT"  , aBipados[nI,3]       , nil } )	// Qtde
			AADD( aAux , {"D3_QTSEGUM", CriaVar("D3_QTSEGUM"), nil } )
			AADD( aAux , {"D3_ESTORNO", CriaVar("D3_ESTORNO"), nil } )
			AADD( aAux , {"D3_NUMSEQ" , CriaVar("D3_NUMSEQ") , nil } )
			AADD( aAux , {"D3_LOTECTL", ""            , nil } )
			AADD( aAux , {"D3_NUMLOTE", ""            , nil } )
			AADD( aAux , {"D3_DTVALID", CtoD("  /  /  ")     , nil } )
			AADD( aAux , {"D3_ITEMGRD", ""            , nil } )
			AADD( aAux , {"D3_OBSERVA", "S.A.: " + aBipados[nI,7], nil } )
			AADD( aAux , {"D3_CC"     , cCusto1       , nil } )
			aAdd( aRotAuto, aClone( aAux ) )
		next

		if len( aRotAuto ) > 1
			MSExecAuto( {|x,y| Mata261(x,y)}, aRotAuto, 3)
			If lMsErroAuto
				cMsgErro := MostraErro()
				conout( "Erro" + cMsgErro )
			else
				SD3->(DbSetOrder(2))
				SD3->(DbSeek(xFilial("SD3")+cDocumento))
				while ! SD3->( eof() ) .and. SD3->D3_FILIAL == xFilial("SD3") .and. SD3->D3_DOC == cDocumento
					recLock("SD3",.F.)
						SD3->D3_NUMSA    := aBipados[1,7]
						//SD3->D3_XSEPSA    := CB7->CB7_ORDSEP
					msUnlock()
					SD3->( dbSkip() )
				endDo
			EndIf
		EndIf
	Else
		for nI := 1 to len( aBipados )
			cDocumento	:= NextNumero("SD3",2,"D3_DOC",.T.)
			cDocumento	:= A261RetINV(cDocumento)
			
			aRotAuto := {}
			
			aAdd(aRotAuto, {cDocumento, dDataBase})

			aAux := {}

			criaSaldo( aBipados[nI,1], cArmDest )

			if ! empty( aBipados[nI,7] ) .and. SCP->( dbSeek( xFilial("SCP") + aBipados[nI,7] ) ) .and. ! empty( SCP->CP_CC )
				cCusto1 := SCP->CP_CC 
			endif

			AADD( aAux , { "ITEM", strZero( 1, len( SD3->D3_ITEM ) ), nil } )

			// Produto Origem
			AADD( aAux , {"D3_COD"    , aBipados[nI,1]				, nil } )
			AADD( aAux , {"D3_DESCRI" , aBipados[nI,4]				, nil } )
			AADD( aAux , {"D3_UM"     , aBipados[nI,5]				, nil } )
			AADD( aAux , {"D3_LOCAL"  , aBipados[nI,2]				, nil } )
			AADD( aAux , {"D3_LOCALIZ", ""            				, nil } )
			// Produto Destino
			AADD( aAux , {"D3_COD"    , aBipados[nI,1]				, nil } )
			AADD( aAux , {"D3_UM"     , aBipados[nI,5]				, nil } )
			AADD( aAux , {"D3_LOCAL"  , cArmDest      				, nil } )
			AADD( aAux , {"D3_LOCALIZ", ""            				, nil } )
			//
			AADD( aAux , {"D3_NUMSERI", ""            				, nil } )
			AADD( aAux , {"D3_LOTECTL", ""            				, nil } )
			AADD( aAux , {"D3_NUMLOTE", ""            				, nil } )
			AADD( aAux , {"D3_DTVALID", CtoD("  /  /  ")     		, nil } )
			AADD( aAux , {"D3_POTENCI", CriaVar("D3_POTENCI")		, nil } )
			AADD( aAux , {"D3_QUANT"  , aBipados[nI,3]       		, nil } )	// Qtde
			AADD( aAux , {"D3_QTSEGUM", CriaVar("D3_QTSEGUM")		, nil } )
			AADD( aAux , {"D3_ESTORNO", CriaVar("D3_ESTORNO")		, nil } )
			AADD( aAux , {"D3_NUMSEQ" , CriaVar("D3_NUMSEQ") 		, nil } )
			AADD( aAux , {"D3_LOTECTL", ""            				, nil } )
			AADD( aAux , {"D3_NUMLOTE", ""            				, nil } )
			AADD( aAux , {"D3_DTVALID", CtoD("  /  /  ")     		, nil } )
			AADD( aAux , {"D3_ITEMGRD", ""            				, nil } )
			AADD( aAux , {"D3_OBSERVA", "S.A.: " + aBipados[nI,7]	, nil } )
			AADD( aAux , {"D3_CC"     , cCusto1       				, nil } )
			aAdd( aRotAuto, aClone( aAux ) )

			MSExecAuto( {|x,y| Mata261(x,y)}, aRotAuto, 3)
			if len( aRotAuto ) > 1
				If lMsErroAuto
					cMsgErro := MostraErro()
					conout( "Erro" + cMsgErro )
				else
					SD3->(DbSetOrder(2))
					SD3->(DbSeek(xFilial("SD3")+cDocumento))
					while ! SD3->( eof() ) .and. SD3->D3_FILIAL == xFilial("SD3") .and. SD3->D3_DOC == cDocumento
						recLock("SD3",.F.)
							SD3->D3_NUMSA    := aBipados[nI,7]
							//SD3->D3_XSEPSA    := CB7->CB7_ORDSEP
						msUnlock()
						SD3->( dbSkip() )
					endDo
				EndIf
			EndIf
		next
	Endif
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
	if ! NNR->( dbSeek( xFilial("NNR") + cArmDest ) )
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()

		oModel:SetValue("NNRMASTER", "NNR_CODIGO", cArmDest )
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
