#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"

//****************************************************************
// BOTAO PARA INFORMACOES ADICIONAIS
//****************************************************************
User Function MA103BUT() //DOCUMENTO DE ENTRADA
    Local aBut := {}
    Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.) 

    Public    cObsMT103        := IIF( Inclui, Space(300), SF1->F1_MENNOTA )

    if lAtivo
        aBut := U_GTPE014()
    endif 
    
    aAdd(aBut,{ "NOTE"		, {||u_FSTelaObs("SF1")}, "Observacoes", "Obs.NF"}) 
Return( aBut ) 
