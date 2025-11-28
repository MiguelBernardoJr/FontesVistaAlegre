#include "totvs.ch"
#include "apvt100.ch"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} VATransf
Rotina de execução de separação - ACD
@author Cristiam Rossi
@since 04/09/2025
@type function
/*/
user function VATransf()
local   cCodOpe  := CBRetOpe()
local   cArmOri
local   cArmDes
local   cEtiqueta
local   nI
private cCUSTO   := superGetMV( "FS_ORDSEPC",, "A0240" )
private aBipados := {}

	SB1->( dbSetOrder(1) )
	SB2->( dbSetOrder(1) )

	if empty( cCodOpe )
		VTAlert("Operador nao cadastrado","Sem Cadastro",.T.,4000,3)
		return nil
	endif

	while .T.
		aBipados := {}
		cOrdSep  := Space(TamSX3("CB9_ORDSEP")[1])
		cArmOri  := space(TamSX3("NNR_CODIGO")[1])
		cArmDes  := cArmOri

		vtClear()
		@ 0,0 VtSay "-= Transferencia =-"

		@ 2,0 VtSay "Arm Origem:"
		@ 3,0 VTGet cArmOri PICT "@!" F3 "CB7" Valid valArm( cArmOri )
		@ 4,0 VtSay "Arm Destino:"
		@ 5,0 VTGet cArmDes PICT "@!" F3 "CB7" Valid valArm( cArmDes, cArmOri )
		vtRead
		If VTLastKey() == 27
			exit
		EndIf

		while .T.
			cEtiqueta := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			nQtde     := 1

			vtClear()
			@ 0,0 VtSay "-= Transferencia =-"
			@ 1,0 VTsay cArmOri + " --> " + cArmDes

			@ 3,0 VTsay "Qtde:"
			@ 3,6 VTGet nQtde Picture "9999" valid nQtde > 0

			@ 4,0 VTsay "Etiqueta:"
			@ 5,0 VTGet cEtiqueta Picture "@!" valid valEtiq(@cEtiqueta, nQtde, cArmOri)
			VTkeyboard( chr(13) )
			vtRead
			If VTLastKey() == 27 .or. empty( cEtiqueta )
				if len( aBipados ) > 0 .and. ! VTYesNo( "Terminou a coleta?", "Confirmacao", .T.)
					loop
				endif
				exit
			EndIf

			if ( nPos := aScan( aBipados, {|it| it[1] == SB1->B1_COD} ) ) == 0
				aAdd( aBipados, { SB1->B1_COD, cArmOri, 0 , alltrim( SB1->B1_DESC ), SB1->B1_UM, SB1->B1_LOCALI } )
				nPos := len( aBipados )
			endif
			aBipados[nPos,3] := aBipados[nPos,3] + nQtde
		endDo

		if len( aBipados ) > 0
			aBipados := aSort( aBipados,,,{|a,b| a[6] < b[6]})
			for nI := 1 to len( aBipados )
				vtClear()
				@ 0,0 VtSay "-= Transferencia =-"
				@ 1,0 VTsay "Entregar em " + cArmDes
				if cArmDes == "01"
					@ 2,0 VTsay "Ir p/: " + aBipados[nI,6]
				endif
				@ 3,0 VTsay left( aBipados[nI,4], VtMaxCol() )
				@ 4,0 VTsay "x" + cValToChar( aBipados[nI,3] )

				@ 6,0 VTsay   "  press ENTER p/"
				@ 7,0 VTpause " confirmar entrega"

				If VTLastKey() == 27
					VtAlert("Entrega ignorada","Aviso",.t.,4000,3)
					loop
				EndIf

				movEstoque( nI, cArmDes )
			next
		endif
	endDo
return nil


/*/{Protheus.doc} valEtiq
    Valida leitura da etiqueta de código de barras ou código do produto
	@author Cristiam Rossi
	@since 04/09/2025
	@type function
	@return logical, leitura do produto OK
/*/
static function valEtiq(cEtiqueta, nQtde, cArmOri)
local nSaldo

	if ! empty(cEtiqueta)
		SB1->( dbSetOrder(5) )
		if ! SB1->( dbSeek( xFilial("SB1") + alltrim(cEtiqueta) ) )
			SB1->( dbSetOrder(1) )
			if ! SB1->( dbSeek( xFilial("SB1") + alltrim(cEtiqueta) ) )
				VtAlert("Produto nao localizado","Aviso",.t.,4000,3)
				VtKeyboard(Chr(20))
				return .F.
			endif
		endif

		cEtiqueta := SB1->B1_COD

		SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + cArmOri ))
		nSaldo := SaldoSB2()
		if nSaldo < nQtde
			VtAlert("Saldo insuficiente","Aviso",.t.,4000,3)
			return .F.
		endif
	endif
return .T.


/*/{Protheus.doc} movEstoque()
    realiza movimento de transferência no estoque
	@author Cristiam Rossi
	@since 04/09/2025
	@type function
/*/
Static Function movEstoque( nPosItem, cArmDest )
local aRotAuto   := {}
local cDocumento := Criavar("D3_DOC")
local nI         := nPosItem
local aAux
local cCusto1    := cCUSTO

	vtClear()
	@ 0,0 VtSay "-= Tranferindo =-"
	@ 2,0 VtSay "favor aguarde..."

	lMsHelpAuto := .T.
	lMsErroAuto := .F.

	cDocumento	:= IIf( Empty(cDocumento) , NextNumero("SD3",2,"D3_DOC",.T.) , cDocumento)
	cDocumento	:= A261RetINV(cDocumento)

	aAdd(aRotAuto, {cDocumento, dDataBase})

	aAux := {}

	criaSaldo( aBipados[nI,1], cArmDest )

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
	AADD( aAux , {"D3_OBSERVA", "S.A.: " + CB7->CB7_NUMSA, nil } )
	AADD( aAux , {"D3_CC"     , cCusto1       , nil } )
	aAdd( aRotAuto, aClone( aAux ) )

	MSExecAuto( {|x,y| Mata261(x,y)}, aRotAuto, 3)
	If lMsErroAuto
		MostraErro()
	EndIf
return nil


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


/*/{Protheus.doc} valArm
    validação do armazem
	@author Cristiam Rossi
	@since 13/09/2025
	@type function
/*/
static function valArm( cArmazem, cOutro )
local   lOk    := .F.
default cOutro := "nenhum"

	if cArmazem == cOutro
		VTAlert("Informe outro armazem",cArmazem+" invalido",.T.,4000,3)
		VtKeyboard(Chr(20))
		return .F.
	endif

	NNR->( dbSetOrder(1) )

	if ! empty( cArmazem )
		if ! NNR->( dbSeek( xFilial("NNR") + cArmazem ) )
			VTAlert("Armazem nao encontrado",cArmazem+" inexistente",.T.,4000,3)
			VtKeyboard(Chr(20))
		else
			lOk := .T.
		endif
	endif 

return lOk
