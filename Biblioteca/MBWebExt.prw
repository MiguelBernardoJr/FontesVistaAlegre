#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 11.11.2021                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Rotina para carregar na SX5 Urls de B.I. e abrir no Protheus;        |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function MBWebExt()         // U_MBWebExt()

Local cTitulo  := "Cadastro de Web Pages"
Local cVldDel  := ".T."
Local cVldAlt  := ".T."
Local aRotAdic := {}
// Local aButtons := {} // Adiciona botões na tela de inclusão, alteração, visualização e exclusao
// Local bPre     := {||MsgAlert('Chamada antes da função')     }
// Local bOK      := {||MsgAlert('Chamada ao clicar em OK'), .T.}
// Local bTTS     := {||MsgAlert('Chamada durante transacao')   }
// Local bNoTTS   := {||MsgAlert('Chamada após transacao')      }    

Private cAlias   := "ZWP"

// aAdd( aButtons, {"PRINT", { || fFuncaoAqui() }, "Imprimir Documento" , "Imprimir"}) // dentro do cadastro
// aAdd(aRotAdic, { "Adicional","U_Adic", 0 , 6 })
aAdd(aRotAdic, { "PortalWEB","U_fLoadPage(1)", 0 , 6 })
aAdd(aRotAdic, { "BPortalVA","U_fLoadPage(2)", 0 , 6 })
// aAdd(aRotAdic, { "zConsMark","U_fLoadPage(0)", 0 , 6 })
// aAdd(aRotAdic, { "LoadPage" ,"U_fLoadPage(3)", 0 , 6 })

dbSelectArea( cAlias )
dbSetOrder(1)

AxCadastro( cAlias,;
            cTitulo,;
            cVldDel,;
            cVldAlt, ;
			aRotAdic,;
			/* bPre */, /* bOK */, /* bTTS */, /* bNoTTS */, , , ;
			/* aButtons */, , )
Return nil
// U_MBWebExt()

User Function fLoadPage(nOpc)

    If Empty(Alltrim(ZWP->ZWP_URL1) + Alltrim(ZWP->ZWP_URL2))
        Alert( "Endereço Web nao localizado." )
        Return nil
    EndIf

    //if nOpc == 0
    //    cRet := u_zConsMark( cAlias, {"ZWP_CODIGO","ZWP_TITULO"}, " ", 99, "ZWP_CODIGO", .F., ";")
    //
    //    Alert( cRet )
    //    Alert( __cRetorn )
    //Else
    If nOpc == 1
        U_PortalWEB( Alltrim(ZWP->ZWP_URL1) + Alltrim(ZWP->ZWP_URL2) )
    Elseif nOpc == 2
        U_BPortalVA( Alltrim(ZWP->ZWP_URL1) + Alltrim(ZWP->ZWP_URL2) )
    // Elseif nOpc == 3
    //     U_LoadPage( Alltrim(ZWP->ZWP_URL1) + Alltrim(ZWP->ZWP_URL2)  )
    EndIf
Return nil

// User Function Adic() 	
//     MsgAlert("Rotina adicional") 
// Return

// Static Function fFuncaoAqui()
//     MsgAlert("Botão")
// Return nil
