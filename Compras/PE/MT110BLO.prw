#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT110BLO
        Após a montagem da dialog de aprovação da Solicitação de compras. 
        É acionado quando o usuário clica nos botões Solicitação Aprovada, 
        Rejeita ou Bloqueada, deve ser utilizado para continuar estas ações 
        retorno .T.' ou interromper  'retorno .F.' , após clicar os botões.
        
        Usado em complemento à rotina u_a110aprv para identificar qual botão foi 
        pressionado.
        
@since 20170328
@author JRScatolon
@return Logico, Sempre .t.  
/*/
user function MT110BLO()
local lRet := .t.
// ParamIXB[1]
//   3 -> "Solicitacäo Bloqueada"
//   1 -> "Solicitacäo Aprovada"
//   2 -> "Solicitacäo Rejeitada"
//   0 -> "Sair"
   nOpcAprv := ParamIXB[1]  

return lRet