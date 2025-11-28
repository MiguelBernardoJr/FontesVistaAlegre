//Bibliotecas
#Include "Totvs.ch"
   
 /*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MT120TEL                                                                                              |
 | Desc:  Ponto de Entrada para adicionar campos no cabeçalho do pedido de compra                               |
 | Link:  http://tdn.totvs.com/display/public/mp/MT120TEL                                                       |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function MT120TEL()
    Local aArea     := GetArea()
    Local oDlg      := PARAMIXB[1] 
    Local aPosGet   := PARAMIXB[2]
    Local nOpcx     := PARAMIXB[4]
    Local nRecPC    := PARAMIXB[5]
    Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  6, .T., .F.) //Somente será editável, na Inclusão, Alteração e Cópia
    Local oXObsAux
    Public cXObsAux := ""
  
    //Define o conteúdo para os campos
    SC7->(DbGoTo(nRecPC))
    If nOpcx == 3
        cXObsAux := Space(254) // CriaVar("C7_OBSFOR",.F.)
    Else
        cXObsAux := SC7->C7_OBSFOR
    EndIf
  
    //Criando na janela o campo OBS
    @ 062, aPosGet[1,08] - 012 SAY Alltrim(RetTitle("C7_OBSFOR")) OF oDlg PIXEL SIZE 050,006
    @ 061, aPosGet[1,09] - 006 MSGET oXObsAux VAR cXObsAux SIZE 100, 006 OF oDlg COLORS 0, 16777215  PIXEL
    oXObsAux:bHelp := {|| ShowHelpCpo( "C7_OBSFOR", {GetHlpSoluc("C7_OBSFOR")[1]}, 5  )}
  
    //Se não houver edição, desabilita os gets
    If !lEdit
        oXObsAux:lActive := .F.
    EndIf
  
    RestArea(aArea)
Return
   
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MTA120G2                                                                                              |
 | Desc:  Ponto de Entrada para gravar informações no pedido de compra a cada item (usado junto com MT120TEL)   |
 | Link:  http://tdn.totvs.com/pages/releaseview.action?pageId=6085572                                          |
 *--------------------------------------------------------------------------------------------------------------*/
   
User Function MTA120G2()
    Local aArea := GetArea()
  
    //Atualiza a descrição, com a variável pública criada no ponto de entrada MT120TEL
    SC7->C7_OBSFOR := Alltrim( cXObsAux )
  
    RestArea(aArea)
Return
