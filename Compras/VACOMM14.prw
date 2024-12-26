//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
 
User Function VACOMM14()
    Local aArea     := FwGetArea()
    Local cVldAlt   := iif(cUserName $ 'ioliveira,ricardo.santana,Administrador',"U_M14VAOK()",".F.")
    Local cVldExc   := iif(cUserName $ 'ioliveira,ricardo.santana,Administrador',"U_M14VAOK()",".F.")
    //Local bPre      := {|| U_M14VPRE()   }//{|| MsgAlert('Chamada antes da função')}
    //Local bOK       := {|| U_M14VOK()   }//{|| MsgAlert('Chamada ao clicar em OK'), .T.}
    //Local bTTS      := {|| U_M14VTTS()   }//{|| MsgAlert('Chamada durante transacao')}
    //Local bNoTTS    := {|| U_M14VNTTS()   }//{|| MsgAlert('Chamada após transacao')}  
   // Local aButtons := { "PRODUTO", {|| MsgAlert("Teste")}, "Teste", "Botão Teste" }//adiciona botões na tela de inclusão, alteração, visualização e exclusao

    DbSelectArea("SX5")
    DbSetOrder(1)

    SX5->(DBSetFilter({|| X5_TABELA = 'Z9'},"X5_TABELA = 'Z9'"))
        //AxCadastro("SA1", "Clientes", "U_DelOk()", "U_COK()", aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , )
        AxCadastro("SX5"  ,"Cadastro de Grupos para solicitações de Compras",  cVldAlt    ,cVldExc  )// ,{}        ,bPre,bOK  ,bTTS, bNoTTS, , , {}      ,,)
    Set Filter To
    FwRestArea(aArea)
Return

/* User Function M14VPRE()    
Return .t.

User Function M14VOK()    
Return .t.
User Function M14VTTS()    
Return .t.
User Function M14VNTTS()    
Return .t.
User Function M14VAOK()    
    MsgAlert("Clicou botao OK") 
Return .t.
   

User Function M14VADE()  
 MsgAlert("Chamada antes do delete") 
Return 
 */
  