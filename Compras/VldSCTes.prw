
#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} VldSCTes
    Rotina no campo X3_VLDUSER do D1_TES
    Responsável por validar Solicitação de Compras X Documento de entrada
    Caso C1_XAPLICA == E
        F4_ESTOQUE == S
    Caso C1_XAPLICA == D
        F4_ESTOQUE == N
    @type function
    @version  
    @author igor.oliveira
    @since 9/23/2025
    @return lRet, Logical
/*/
User Function VldSCTes()
    Local aArea       := FwGetArea()
    Local lRet        := .T.
    Local nPosPedido  := 0 //aScan(aHeader,{|x| Alltrim(x[2])=="D1_PEDIDO"})
    Local nPosItem    := 0 //aScan(aHeader,{|x| Alltrim(x[2])=="D1_ITEMPC"})
    Local nPosProduto := 0 //aScan(aHeader,{|x| Alltrim(x[2])=="D1_COD"})
    
    if !IsInCallStack("MATA910")
        
        nPosPedido  :=  aScan(aHeader,{|x| Alltrim(x[2])=="D1_PEDIDO"})
        nPosItem    :=  aScan(aHeader,{|x| Alltrim(x[2])=="D1_ITEMPC"})
        nPosProduto :=  aScan(aHeader,{|x| Alltrim(x[2])=="D1_COD"})
        
        if !Empty(aCols[N,nPosPedido])
            if SC7->(DbSeek(FWxFilial("SC7")+aCols[N,nPosProduto]+aCols[N,nPosPedido]+aCols[N,nPosItem]))
                //C1_FILIAL+C1_PEDIDO+C1_ITEMPED+C1_PRODUTO
                SC1->(DbSetOrder(6))
                IF SC1->(DbSeek(FWxFilial("SC1")+SC7->C7_NUM+SC7->C7_ITEM+SC7->C7_PRODUTO))
                    //if SC1->C1_FILIAL != '0101033' .and. SC1->C1_NUM != "000020"
                        if SC1->C1_XAPLICA == "E"
                            if !(lRet := SF4->F4_ESTOQUE == "S")
                                FWAlertWarning("Solitação de compras foi feita com Aplicação para ESTOQUE!" + CRLF+;
                                                "TES utilizada precisa obrigatoriamente ser destinada a estoque!",;
                                                "TES NÃO PERMITIDA")
                            endif
                        elseif SC1->C1_XAPLICA == "D"
                            if !(lRet := SF4->F4_ESTOQUE == "N")
                                FWAlertWarning("Solitação de compras foi feita com Aplicação Direta!" + CRLF+;
                                                "TES utilizada precisa obrigatoriamente NÂO ser destinada a estoque!",;
                                                "TES NÃO PERMITIDA")
                            endif
                        endif
                    //endif
                endif
            endif
        endif
    endif

    FwRestArea(aArea)
Return lRet

