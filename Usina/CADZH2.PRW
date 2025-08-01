//Bibliotecas
#Include "Protheus.ch"
#Include "TOTVS.ch"
 
/*/{Protheus.doc} CADZH2
Cadatro dos PROCESSOS ETANOL
@type function
@author Rodrigo Franco
@since 03/02/2025
@version 1.0

Fun��o AxCadastro
    Par�metros
        + cAlias      , Caractere       , Alias da tabela 
        + cTitle      , Caractere       , T�tulo da janela
        + cDel        , Caractere       , Fun��o executada ao confirmar uma exclus�o
        + cOk         , Caractere       , Fun��o executada ao clicar no confirmar
        + aRotAdic    , Array           , Rotinas adicionais para serem acrescentadas no menu
        + bPre        , Bloco de C�digo , Bloco de c�digo executado antes de abrir a tela de manuten��o do cadastro
        + bOK         , Bloco de C�digo , Bloco de c�digo executado ao clicar no bot�o Confirmar na tela de manuten��o do cadastro
        + bTTS        , Bloco de C�digo , Bloco de c�digo executado durante a transa��o ap�s clicar no Confirmar na tela de manuten��o do cadastro
        + bNoTTS      , Bloco de C�digo , Bloco de c�digo executado fora da transa��o ap�s clicar no Confirmar na tela de manuten��o do cadastro
        + aAuto       , Array           , Array com nome dos campos a serem considerados nas rotinas autom�ticas
        + nOpcAuto    , Num�rico        , N�mero da op��o selecionada em caso de rotinas autom�ticas
        + aButtons    , Array           , Array com os bot�es dentro da rotina de manuten��o do cadastro
        + aACS        , Array           , Array com os controles de acessos das fun��es
        + cTela       , Caractere       , Nome da vari�vel que ser� utilizada no lugar da aTela
        + lMenuDef    , L�gico          , Indica se usar� um MenuDef com fun��es padronizadas

/*/
User Function CADZH2()
    Local aArea      := FWGetArea()
    Local cDelOk   := ".T."
    Local cFunTOk  := ".T."
 
    //Chamando a tela de cadastros
    AxCadastro('ZH2', 'PROCESSOS ETANOL', cDelOk, cFunTOk)
 
    FWRestArea(aArea)
Return
