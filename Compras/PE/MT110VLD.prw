#INCLUDE 'PROTHEUS.CH'
/* 

Igor Oliveira

Descrição:
Localizado na Solicitação de Compras, este ponto de entrada é responsável em validar o registro posicionado da Solicitação de Compras antes de executar as operações de inclusão, alteração, exclusão e cópia. Se retornar .T., deve executar as operações de inclusão, alteração, exclusão e cópia ou .F. para interromper o processo.

Programa Fonte
mata110.prx

Sintaxe
MT110VLD - Valida o registro na Solicitação de Compras ( [ ExpN1 ] ) --> ExpL1

*/
User Function MT110VLD()
    Local nOpc  := Paramixb[1]
    Local lRet  := .T.
    Local lBloq := GetMv("MV_BLQSOL")
    
    if Valtype("lBloq") <> 'U' .and. !lBloq // se o parametro MV_BLQSOL == .F., a alteração das solicitaçoes foi liberada por um dos usuários no parametro MV_BLQSLUS
        Return .T.
    endif

    if nOpc == 4
        if SC1->C1_APROV == 'L'
            MSGALERT( "Solicitação não pode ser alterada."+CRLF+;
                    ""+CRLF+;
                    "Razão: Solicitação Aprovada.", "Atenção" )
            lRet := .F.
        endif
    endif
Return lRet
