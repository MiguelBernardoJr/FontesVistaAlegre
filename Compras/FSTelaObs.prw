#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"


User Function FSTelaObs(cOrigem, cTitulo, cModelo)

	Local _oForm        := nil
	Local _oFormDesc    := nil
	Local _oTranspCod   := nil
	Local _oTranspDes   := nil
	
	Private _cForm      := Space(3)
	Private _cFormDesc  := Space(30)
	Private _cTranspCod := Space(6)
	Private _cTranspDes := Space(30)

	Private oFont6
	Private oMemo

	Default cTitulo := "Observacoes"
	Default cModelo := 'Default'

	oFont6          := TFont():New("Arial", 0, -13, , .T., 0, , 700, .F., .F., , , , , ,)
	// oMemo:oFont	:= oFont6
	cMemo           := ""

	Do Case
		Case cOrigem=="SF1"
			cMemo := cObsMT103
		Case cOrigem=="SA1"
			// cMemo:= M->A1_X_OBS
		Case cOrigem=="SA2"
			// cMemo:= M->A2_X_OBS
		Case cOrigem=="SA3"
			// cMemo:= M->A3_X_OBS
		Case cOrigem="SRA"
			// cMemo:= M->RA_X_OBS
		Case cOrigem="SC7"
			cMemo := SC7->C7_OBS
		Case cOrigem="TransfAuto"

			/*
			nao estamos usando mais,
			criamos o campo direto na NNS
			*/

			If ValType(__aMATA311) == "A" .AND. Len(__aMATA311) > 0
				If __aMATA311[1] == iIF(INCLUI, M->NNS_COD, NNS->NNS_COD)
					_cTranspCod := __aMATA311[02]
					_cTranspDes := __aMATA311[03]
					_cForm  	:= __aMATA311[04]
					_cFormDesc  := __aMATA311[05]
					cMemo       := __aMATA311[06]
				Else
					_cTranspCod := Space(6)
					_cTranspDes := Space(30)
					_cForm  	:= Space(3)
					_cFormDesc  := Space(30)
					cMemo       := Space(244)
					
					__aMATA311  := {}
				EndIf
			Else
				If ValType(__aMATA311)=="U"
					Public __aMATA311 := {}
				EndIf
			EndIf

			// cMemo := SC7->C7_OBS
		Otherwise 
			return
	EndCase
	
	If cModelo == 'Default'
		
		DEFINE MSDIALOG oDlgObs TITLE cTitulo From 003,000 to 300,450 PIXEL 
		@ 001, 001 GET oMemo var cMemo MEMO Size 210,110
		DEFINE SBUTTON  FROM 130,190 TYPE 1 ACTION Close(oDlgObs) ENABLE OF oDlgObs PIXEL 

	ElseIf cModelo == 'Transferencia'

		DEFINE MSDIALOG oDlgObs TITLE cTitulo From 003,000 to 360,450 PIXEL
		@ 000, 001 SAY "Transportador" 		SIZE 070,001 OF oDlgObs
		@ 001, 001 MSGET _oTranspCod VAR _cTranspCod SIZE 050,010 F3 "SA4" VALID { || fsVldCpo("Transp") }
		@ 001, 008 MSGET _oTranspDes VAR _cTranspDes SIZE 155,010 WHEN .F.

		@ 002, 001 SAY "Formulas" 	 SIZE 070,001 OF oDlgObs
		@ 003, 001 MSGET _oForm 	 VAR _cForm 	 SIZE 050,010 F3 "SM4" VALID { || fsVldCpo("Formulas") }
		@ 003, 008 MSGET _oFormDesc  VAR _cFormDesc  SIZE 155,010 WHEN .F.

		@ 004, 001 SAY "Observações" SIZE 070,001 OF oDlgObs
		@ 005, 001 GET oMemo         VAR cMemo MEMO  SIZE 210,095
		DEFINE SBUTTON FROM 165,192 TYPE 1 ACTION Close(oDlgObs) ENABLE OF oDlgObs PIXEL

	EndIf

	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont     := oFont6

	ACTIVATE MSDIALOG oDlgObs CENTER

	if INCLUI .OR. ALTERA //.OR. "MATA103"$FUNNAME()
		Do Case
			Case cOrigem=="SF1"
				cObsMT103       := AllTrim(cMemo)
			Case cOrigem=="SA1"
				// M->A1_X_OBS:= AllTrim(cMemo)
			Case cOrigem=="SA2"
				// M->A2_X_OBS:= AllTrim(cMemo)
			Case cOrigem=="SA3"
				// M->A3_X_OBS:= AllTrim(cMemo)
			Case cOrigem="SRA"
				// M->RA_X_OBS:= AllTrim(cMemo)
			Case cOrigem="SC7"
				M->C7_OBS       := AllTrim(cMemo)
			Case cOrigem="TransfAuto"
				__aMATA311 := {;
						iIF(INCLUI, M->NNS_COD, NNS->NNS_COD),;
						_cTranspCod,;
						_cTranspDes,;
						_cForm,;
						_cFormDesc,;
						AllTrim(cMemo) }
		EndCase
	endif
Return

Static Function fsVldCpo(cOpc)
	
	If cOpc == "Transp"
		If Empty(&(ReadVar()))
			_cTranspDes := Space(30)
		Else
			_cTranspDes := SA4->A4_NOME
		EndIf

	ElseIf cOpc == "Formulas"
		If Empty(&(ReadVar()))
			_cFormDesc := Space(30)
		Else
			_cFormDesc := SM4->M4_DESCR
		EndIf
	EndIf

Return .T.
