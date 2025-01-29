#include 'protheus.ch'
#include 'parmtype.ch'

user function Mt121Brw()
	AAdd(aRotina,{"Env PC por email","u_EnvPC", 0, 2, 0, nil})
	//AAdd(aRotina,{"Env Liberacao ","u_EnvSL", 0, 2, 0, nil})
return nil

/*/{Protheus.doc}u_EnvPC
    Envia o pedido de vendas para o fornecedor, caso esteja aprovado.
    
@since 20170404
@author jrscatolon@jrscatolon.com.br
@param cAlias, Character, Alias posicionado pelo browse.
@param nRec, Numeric, Posição do registro no arquivo selecionado no browse.
@param nOpc, Numeric, Posição da rotina chamada no browse.
@param lMostraPed, Logic, Indica se será mostrado o pedido de vendas. 
@return Nil, nulo
/*/
user function EnvPC(cAlias, nRec, nOpc, lMostraPed)
local aArea := GetArea()
local nOpcX := 0
local aForm := {}
local cChave := ""

private nSubTotal := 0 
private nValFrete := 0
private nValIPI := 0
private dDataEntrega := SToD("")

default lMostraPed := .t.

nOpcX := &('StaticCall(MATA121, MENUDEF)')[nOpc][4]

if SC7->C7_CONAPRO == 'L'
    if !lMostraPed .or. A120Pedido(cAlias, nRec, nOpcX) == 1
        aForm := u_LoadTemplate("\workflow\template\form_pedido.htm")
        
        DbSelectArea("SY1")
        DbSetOrder(3) // Y1_FILIAL+Y1_USER
    
        DbSelectArea("SA2")
        DbSetOrder(1) // A2_FILIAL+A2_COD+A2_LOJA
    
        DbSelectArea("SC7")
        DbSetOrder(1) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
        DbGoTo(nRec)
        
        SC7->(DbSeek(xFilial("SC7")+SC7->C7_NUM)) // Posiciona no primeiro registro do pedido de compras
        SA2->(DbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))
        SY1->(DbSeek(xFilial("SY1")+SC7->C7_USER))
        
        cChave := SC7->C7_FILIAL + SC7->C7_NUM
        while !SC7->(Eof()) .and. SC7->C7_FILIAL + SC7->C7_NUM == cChave
            nSubTotal += SC7->C7_TOTAL - SC7->C7_VLDESC
            nValFrete += SC7->C7_SEGURO + SC7->C7_DESPESA + SC7->C7_VALFRE
            nValIPI += SC7->C7_VALIPI
            dDataEntrega := Iif(!Empty(SC7->C7_DATPRF) .and. (Empty(dDataEntrega) .or. SC7->C7_DATPRF < dDataEntrega), SC7->C7_DATPRF, dDataEntrega)
            u_WfProcLin(@aForm)
            SC7->(DbSkip())
        end
        nTotal := nSubTotal + nValIPI + nValFrete 
        if Empty(SA2->A2_EMAIL)
            ShowHelpDlg("WFPROC01", {"O e-mail do fornecedor não está preenchido."}, 1, {"Por favor, preencha o e-mail do fornecedor e use a rotina de o reenvio da cotação em atualização de cotações."}, 1 )
            lEnvia := .f.
        else
            u_WfProc(@aForm, SA2->A2_EMAIL)
	    	if cUsername == "Administrador"
	    		cMailCC := GetMV("MV_RELACNT")
	    	elseif Empty(SY1->Y1_EMAIL)
	    	    PswOrder(1)
                PswSeek(__cUserId)
	    		cMailCC := PswRet(1)[1][14]
	    	else
	    	    cMailCC := AllTrim(SY1->Y1_EMAIL)
	    	endif
            u_UpdForm(@aForm)
            //u_EnvMail(aForm[4], cMailCC, /*_cBCC*/, "Pedido de compras", /*_aAnexo*/, aForm[3], /*_lAudit*/)
            u_WFEnvPC(aForm, cChave)
        endif
        
    endif
else
    ShowHelpDlg("ENVPC", {"O pedido de vendas não está liberado."}, 1, {"Não é possivel enviar o pedido de compras até que ele seja liberado."}, 1)
endif

RestArea(aArea)
return nil

user function WFEnvPC(aForm, cChave)
local i := 0
local aAnexo := {"\workflow\cotacao\pedido_" + cChave + ".htm"} 
local cMessage := MemoRead("\workflow\template\corpo_pc.htm")
    
    MemoWrite(aAnexo[1], aForm[3])
    
    u_EnvMail(aForm[4], /*_cCc*/, /*_cBCC*/, "Pedido de compras V@ " + cFilAnt + SC7->C7_NUM + ".", aAnexo, cMessage, /*_lAudit*/)

    for i := 1 to Len(aAnexo)
        FErase(aAnexo[i])
    next
    
return nil


user function EnvSL()

	if C7_CONAPRO=="B".And.C7_QUJE < C7_QUANT
	    u_mt160wf(SC7->C7_NUMCOT)
    else
        ShowHelpDlg("ENVSL", {"O pedido não está bloquedado"}, 1, {"A solicitação de liberação só pode ser realizada em pedidos bloqueados."}, 1)
	endif

 

return nil
