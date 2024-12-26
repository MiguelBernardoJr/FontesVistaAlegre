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
Public    cObsMT103        := IIF( Inclui, Space(300), SF1->F1_MENNOTA )
Public    aCBrMT103        := {}
    
    // Ponto de chamada ConexãoNF-e sempre como primeira instrução.
    aButtons := U_GTPE014()
    
    aAdd(aBut,{ "NOTE"		, {||u_FSTelaObs("SF1")}, "Observacoes", "Obs.NF"}) 
Return( aBut ) 
