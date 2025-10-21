#include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} M241BUT
    P.E. para criação de botões na tela de Movimentações Internas (MATA241).
    @type function
    @author Nathan Quirino
    @since 06/10/2025
    @version 3.0 - Refatorado para modularização
    @description Ponto de Entrada que adiciona o botão "Rateio". A ação do
                 botão chama a função U_SelecionaOSDev() para iniciar o processo.
/*/
//-------------------------------------------------------------------
User Function M241BUT()
Local aButtons := {}
    aAdd(aButtons , {'CARGA',{|| U_SelOSDev() }, 'Sel Ord Sep', 'Sel Ord Sep', .T. })
Return aButtons
