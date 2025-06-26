#include "totvs.ch"
 
/*/{Protheus.doc} User Function MPADDCPO
   Permite adicionar campos na interface Ver Mais do app Meu Protheus.
   @type User Function
   @since 01/01/2024
   @author user
/*/
User Function MPADDCPO()
    Local cCampos := ""//  A separação dos campos devem ser feitos com uma barra vertical ( | )
    Local cAlias := PARAMIXB[1] // Alias do documento posicionado
     
    Do case
        //case cAlias == "SC7"
        //    cCampos := "C7_DINICQ|C7_QUJE|C7_IPIBRUT|C7_VALICM|C7_OBS|C7_OBRIGA"
         
        case cAlias == "SC1"   
            cCampos := "C1_OBS|C1_XAPLICA"
 
       
    EndCase
 
Return (cCampos)
