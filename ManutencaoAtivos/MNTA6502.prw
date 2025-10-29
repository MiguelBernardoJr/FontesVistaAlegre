#Include 'Protheus.ch'
  

User Function MNTA6502()
  
    Local aButtons := {}
  
    aAdd( aButtons, { 'Botão Teste', 'U_xMnt60Desc()'})
  
Return aButtons

/*/
    {Protheus.doc} xMnt60Desc()
    @type  Function
    @author Igor Oliveira
    @since 24/10/2025
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example Rotina para aplicar desconto em abastecimentos.
    @see (links_or_references)
/*/
User Function xMnt60Desc()
    
    Local aParamBox := {}
    Local aRet      := {}
    
	aAdd(aParamBox,{1 ,"Valor Desconto:", 0, "","","","",0,.T.}) // Tipo caractere

    If ParamBox(aParamBox,"Parâmetros...",@aRet, /* [ bOk ] */, /* [ aButtons ] */, /* [ lCentered ] */, /* [ nPosX ] */, /* [ nPosy ] */, /* [ oDlgWizard ] */,  cLoad, lCanSave, lUserSave )
		If aRet[1] > 0
		    FWMsgRun(, {|| AlteraPedido(aRet[1])}, 'Alterando pedido','Aguarde...')
		EndIf
	EndIF

Return .T.

Static Function AlteraPedido(nValorDesconto)
    Local aArea := FwGetArea()
    Local aCabec    := {}
    Local aItens    := {}
    Local aLinha    := {}
    Local nX        := 0
    Local cDoc      := ""
    Local nOpc      := 3
    
    PRIVATE lMsErroAuto := .F.

    SC7->(dbSetOrder(1))    

    aadd(aCabec,{"C7_NUM"       ,cDoc})
    aadd(aCabec,{"C7_EMISSAO"   ,dDataBase})
    aadd(aCabec,{"C7_FORNECE"   ,"COM002"})
    aadd(aCabec,{"C7_LOJA"      ,"01"})
    aadd(aCabec,{"C7_COND"      ,"000"})
    aadd(aCabec,{"C7_CONTATO"   ,"AUTO"})
    aadd(aCabec,{"C7_FILENT"    ,cFilAnt})
        
    For nX := 1 To 2
        aLinha := {}
        aadd(aLinha,{"C7_ITEM"      , StrZero(nX,TamSX3("C7_ITEM")[1]),Nil})
        aadd(aLinha,{"C7_PRODUTO"   , "01"    ,Nil})
        aadd(aLinha,{"C7_QUANT"     , 1       ,Nil})
        aadd(aLinha,{"C7_PRECO"     , nX*1000 ,Nil})
        aadd(aLinha,{"C7_TOTAL"     , nX*1000 ,Nil})
        
        If nX == 1
            aadd(aLinha,{"C7_VLDESC" ,150 ,Nil})
        Endif
    
        aadd(aItens,aLinha)
    Next nX
    
    MSExecAuto({|a,b,c,d,e,f,g| MATA120(a,b,c,d)},1,aCabec,aItens,nOpc) 
    
    If !lMsErroAuto
        ConOut("Incluido PC: " + cDoc)
    Else
        ConOut("Erro na inclusao!")  
        MostraErro()
    EndIf
    

    FwRestArea(aArea)
Return
