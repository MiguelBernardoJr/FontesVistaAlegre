#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"


//****************************************************************
// BOTAO PARA INFORMACOES ADICIONAIS NO DOCUMENTO DE ENTRADA / CONHECIMENTO DE FRETE
//****************************************************************
User Function MA116BUT() // MENU ROTINA DE FRETE PRA GRAVAR OBS NO SE2
Local nOpcX:= PARAMIXB[1]
Local aBut := PARAMIXB[2]
Public    cObsMT103        := IIF( Inclui, Space(300), SF1->F1_MENNOTA )

    aAdd(aBut,{ "NOTE"		, {||u_FSTelaObs("SF1")}, "Observacoes", "Obs.NF"}) 
Return( aBut )
