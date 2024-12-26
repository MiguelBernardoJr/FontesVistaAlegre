#INCLUDE "TOTVS.CH"

/*	MJ : 27.12.2017
		# MOVIMENTACAO SIMPLES
			* Forçar o preenchimento do campo "Lote", "Observação"
			
		-> Parametros:
			* JR_TMMORTE
*/
User Function MT240TOK()

// TM DA MORTE
If &(IIF(INCLUI,"M->","SD3->")+"D3_TM") == GetMV("JR_TMMORTE",,"511") .and. Empty(&(IIF(INCLUI,"M->","SD3->")+"D3_X_OBS"))
	Aviso("Aviso","Por favor informar o campo observação referente a esta movimentação.", {"Sair"} )
	Return .F.
EndIf

// LOTE
 if SB1->B1_RASTRO=="L" .and. Empty(&(IIF(INCLUI,"M->","SD3->")+"D3_LOTECTL"))
	Aviso("Aviso","Por favor informar o campo Lote referente a esta movimentação.", {"Sair"} )
	Return .F.
EndIf

MsgInfo('Esta Rotina sera descontinuada em 04/04/2022. Favor procurar o Arthur Toshio.')

Return .T.
