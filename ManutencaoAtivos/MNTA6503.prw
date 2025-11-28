#Include 'Protheus.ch'
  

User Function MNTA6503()
  
    Local aButtons := aClone(ParamIXB[1])
  
    aAdd( aButtons, { 'Aplicar Desconto', 'U_xMnt60Desc()', 0, 2, 0 })

Return aButtons

/*/
    {Protheus.doc} xMnt60Desc()
    @type  Function
    @author Igor Oliveira
    @since 24/10/2025
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example Rotina para aplicar desconto em, abastecimentos.
    @see (links_or_references)
/*/
User Function xMnt60Desc()
    
    Local aParamBox := {}
    Local aRet      := {}
    

	aAdd(aParamBox,{1 ,"Valor Desconto:", SC7->C7_VLDESC, "@E 999,999.99","","","",0,.T.}) // Tipo caractere

    If ParamBox(aParamBox,"Parâmetros...",@aRet, /* [ bOk ] */, /* [ aButtons ] */, /* [ lCentered ] */, /* [ nPosX ] */, /* [ nPosy ] */, /* [ oDlgWizard ] */,  /* cLoad */, .f., .f. )
		If aRet[1] > 0
		    FWMsgRun(, {|| AlteraPedido(aRet[1])}, 'Alterando pedido','Aguarde...')
		EndIf
	EndIF

Return .T.

Static Function AlteraPedido(nValorDesconto)
    Local aArea     := FwGetArea()
    Local aCabec    := {}
    Local aItens    := {}
    Local aLinha    := {}
    
    PRIVATE lMsHelpAuto := .T.
    PRIVATE lMsErroAuto := .F.

    aadd(aCabec,{"C7_FILIAL"    ,SC7->C7_FILIAL })
    aadd(aCabec,{"C7_NUM"       ,SC7->C7_NUM    })
    aadd(aCabec,{"C7_EMISSAO"   ,SC7->C7_EMISSAO})
    aadd(aCabec,{"C7_FORNECE"   ,SC7->C7_FORNECE})
    aadd(aCabec,{"C7_LOJA"      ,SC7->C7_LOJA   })
    aadd(aCabec,{"C7_COND"      ,SC7->C7_COND   })
    aadd(aCabec,{"C7_CONTATO"   ,SC7->C7_CONTATO})
    aadd(aCabec,{"C7_FILENT"    ,SC7->C7_FILENT })
        
    aadd(aLinha,{"C7_ITEM"      , SC7->C7_ITEM                              ,Nil})
    aadd(aLinha,{"C7_PRODUTO"   , SC7->C7_PRODUTO                           ,Nil})
    aadd(aLinha,{"C7_QUANT"     , SC7->C7_QUANT                             ,Nil})
    aadd(aLinha,{"C7_PRECO"     , SC7->C7_PRECO                             ,Nil})
    aadd(aLinha,{"C7_TOTAL"     , SC7->C7_TOTAL                             ,Nil})
    aadd(aLinha,{"C7_DESC"      , (nValorDesconto * SC7->C7_PRECO) / 100    ,nil})
    aadd(aLinha,{"C7_VLDESC"    , nValorDesconto                            ,nil})
    aadd(aLinha,{"C7_FRETE"     , "S"                                       ,nil})
    aadd(aLinha,{"C7_CC"        , SC7->C7_CC                                ,nil})
    aadd(aLinha,{"C7_ITEMCTA"   , SC7->C7_ITEMCTA                           ,nil})
    
    aAdd(aItens,aLinha)
    
    lMsErroAuto := .F.
    MSExecAuto({|v,x,y,z,w| MATA120(v,x,y,z,w)}, 1, aCabec, aItens, 4,.F.)
    
    If lMsErroAuto
        MostraErro()
    EndIf

    FwRestArea(aArea)
Return
