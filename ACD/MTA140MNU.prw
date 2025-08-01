//Bibliotecas
#Include "totvs.ch"
  
/*------------------------------------------------------------------------------------------------------*
 | P.E.:  MTA140MNU                                                                                     |
 | Desc:  Inclusão de Ações Relacionadas no Pré-Documento de Entrada                                    |
 | Links: https://tdn.totvs.com/pages/releaseview.action?pageId=6085799                                 |
 *------------------------------------------------------------------------------------------------------*/
 
User Function MTA140MNU()
     
    if GetMV("MV_CONFFIS",,) = "S"
        AAdd(aRotina,{'Etiqueta', 'U_VAACOM01', 0, 4, 0, .F.})
        //AAdd(aRotina,{'Gerar de Transf', 'U_MOACOM02', 0, 4, 0, .F.})
    endif
Return Nil
