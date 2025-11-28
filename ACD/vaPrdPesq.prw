#include "totvs.ch"
#include "apvt100.ch"

/*/{Protheus.doc} VAPrdPesq
Rotina de pesquisa de produto - ACD
@author Cristiam Rossi
@since 05/09/2025
@type function
/*/
user function VAPrdPesq()
local cEtiqueta

	while .T.
		cEtiqueta := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )

		vtClear()
		@ 0,0 VtSay "Pesquisa PRODUTO"

		@ 1,0 VtSay "Etiqueta:"
		@ 2,0 VTGet cEtiqueta PICT "@!" Valid valEtiq(cEtiqueta)
		vtRead
		If VTLastKey() == 27
			exit
		EndIf
	endDo
return nil


/*/{Protheus.doc} valEtiq
    Valida leitura da etiqueta de código de barras ou código do produto
	@author Cristiam Rossi
	@since 04/09/2025
	@type function
	@return logical, leitura do produto OK
/*/
static function valEtiq(cEtiqueta)
local cCod

	SB1->( dbSetOrder(5) )
	if ! SB1->( dbSeek( xFilial("SB1") + alltrim(cEtiqueta) ) )
		SB1->( dbSetOrder(1) )
		if ! SB1->( dbSeek( xFilial("SB1") + alltrim(cEtiqueta) ) )
			VtAlert("Produto nao localizado","Aviso",.t.,4000,3)
			VtKeyboard(Chr(20))
			return .F.
		endif
	endif

	SB2->( dbSetOrder(1) )
	SB2->( dbSeek(xFilial("SB2")+SB1->( B1_COD + B1_LOCPAD )) )

	if alltrim( cEtiqueta ) != alltrim( SB1->B1_COD )
		cCod := SB1->B1_COD
	else
		cCod := SB1->B1_CODBAR
	endif

	@ 3,0 VTsay left( cCod, VTmaxCol() )
	@ 4,0 VTsay left( SB1->B1_DESC, VTmaxCol() )
	@ 5,0 VtSay "Local: " + SB1->B1_LOCALI
	@ 6,0 VtSay "Saldo " + SB1->B1_LOCPAD+ ": "+alltrim( transform(SaldoSB2(), PesqPict("SB2","B2_QATU") ) )
	@ 7,3 VtPause "tecle Enter"
return .T.
