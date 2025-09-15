#include "PROTHEUS.CH"


//
/* 
Igor Oliveira
12/08/2025
Validação na Solicitação de Compras.
Apenas o grupo Almoxarifado e Fabrica tem permissão para incluir produtos com B1_X_PRDES = 'E'
*/
User Function vldc1Prd()
    Local lRet      := .T.
    //Local aGrupos   := {}
    //Local aGrpPer   := "000002|000032"
    //Local nI        := 0
    
    //if IsInCallStack("MATA110") .and. SB1->B1_X_PRDES == 'E'
    //    aGrupos := FWSFUsrGrps(__cUserID)

    //    For nI := 1 to Len(aGrupos)
    //        if aGrupos[nI] $ aGrpPer
    //            lRet := .T.
    //            exit
    //        endif
    //    Next nI
    //endif

    //if !lRet
    //    FwAlertError("Você não tem permissão para incluir produtos destinados a ESTOQUE, verifique com o almoxarifado!","ATENÇÃO")
    //endif

Return lRet

