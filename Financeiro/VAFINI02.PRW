#INCLUDE 'PROTHEUS.CH'

User Function VAFINI02()
    Local lRet := .T. 

    IF MsgYesNo("Número: " + AllTrim(SE2->E2_NUM) + CRLF +; 
                "Parcela: " + AllTrim(SE2->E2_PARCELA) + CRLF +; 
                "Fornecedor: " + AllTrim(SE2->E2_NOMFOR) , "Confirma Exclusão?" )

        If AllTrim(SE2->E2_TIPO) == 'PR' .and. !EMPTY(SE2->E2_MDCONTR) .and. !EMPTY(SE2->E2_MDPLANI) .and. AllTrim(SE2->E2_ORIGEM)=='CNTA100' 
            RecLock("SE2", .F.)
                SE2->(DbDelete())
            SE2->(MsUnLock())
        else
            lRet := .F.
        endif
    endif

    if lRet
        MsgInfo("Registro Excluido!")
    else 
        MsgInfo("Registro não pode ser excluido!")
    endif 

Return
