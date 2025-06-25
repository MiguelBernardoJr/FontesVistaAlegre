//Bibliotecas
#Include "Protheus.ch"
#Include "TOTVS.ch"
 
/*/{Protheus.doc} CADZH2
Cadatro dos PROCESSOS ETANOL
@type function
@author Rodrigo Franco
@since 03/02/2025
@version 1.0

Função AxCadastro
    Parâmetros
        + cAlias      , Caractere       , Alias da tabela 
        + cTitle      , Caractere       , Título da janela
        + cDel        , Caractere       , Função executada ao confirmar uma exclusão
        + cOk         , Caractere       , Função executada ao clicar no confirmar
        + aRotAdic    , Array           , Rotinas adicionais para serem acrescentadas no menu
        + bPre        , Bloco de Código , Bloco de código executado antes de abrir a tela de manutenção do cadastro
        + bOK         , Bloco de Código , Bloco de código executado ao clicar no botão Confirmar na tela de manutenção do cadastro
        + bTTS        , Bloco de Código , Bloco de código executado durante a transação após clicar no Confirmar na tela de manutenção do cadastro
        + bNoTTS      , Bloco de Código , Bloco de código executado fora da transação após clicar no Confirmar na tela de manutenção do cadastro
        + aAuto       , Array           , Array com nome dos campos a serem considerados nas rotinas automáticas
        + nOpcAuto    , Numérico        , Número da opção selecionada em caso de rotinas automáticas
        + aButtons    , Array           , Array com os botões dentro da rotina de manutenção do cadastro
        + aACS        , Array           , Array com os controles de acessos das funções
        + cTela       , Caractere       , Nome da variável que será utilizada no lugar da aTela
        + lMenuDef    , Lógico          , Indica se usará um MenuDef com funções padronizadas

/*/
User Function CADZH2()
    Local aArea      := FWGetArea()
    Local cDelOk   := ".T."
    Local cFunTOk  := ".T."
 
    //Chamando a tela de cadastros
    AxCadastro('ZH2', 'PROCESSOS ETANOL', cDelOk, cFunTOk)
 
    FWRestArea(aArea)
Return
