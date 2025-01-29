#include "protheus.ch"
#include "fileio.ch"
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

/*/{Protheus.doc}u_run130wf
Rotina para teste da funcão MT130WF.
@since 20170404
@author jrscatolon@jrscatolon.com.br
@return Nil, nulo
/*/
user function run130WF()
    u_RunFunc("u_runMT130()")
return nil

/*/{Protheus.doc}u_runMT130
Rotina para teste da funcão MT130WF.
@since 20170404
@author jrscatolon@jrscatolon.com.br
@return Nil, nulo
/*/
user function runMT130()
private ParamIXB := {"000003", {"000003"}}
    u_MT130WF()
return nil

/*/{Protheus.doc}u_MT130WF
    Este ponto de entrada tem o objetivo de permitir a customização de workflow baseado nas informações de cotações que estão sendo geradas pela rotina em execução.
    Cria um formulário com a solicitação de contação e envia por e-mail para o fornecedor.
@since 20170404
@author jrscatolon@jrscatolon.com.br
@param aSolicitacao, Array. Array contendo o código da solicitação e o fornecedor que a receberá. Usado para reenvio/envio do workflow a partir da rotina de atualização de cotações.
@return Nil, nulo
/*/
user function MT130WF(aSolicitac)
local aArea := GetArea()
local aTemplate := {}
local cChave := ""
local i := 0
local cFornece := ""
local cLoja := ""
local cNumPro := ""
local lEnvia := .t.

private cOperacao := "MATA130"
private cWFID := ""
private L110AUTO := .T.

default aSolicitac := ParamIXB[2] // ParamIXB[1] é a mesma coisa que ParamIXB[2][1]

Alert( 'IsInCallStack: ' + cValToChar( IsInCallStack("U_XGERASC7()") ) )

if Type("oMainWnd") == 'U' .or. Aviso("Email","Deseja Enviar email de cotação para o Fornecedor? ",{"Sim","Não"}) == 1

    /* if FunName()=="MATA150"
        cFornece := SC8->C8_FORNECE
        cLoja := SC8->C8_LOJA
        cNumPro := SC8->C8_NUMPRO
    endif */
    aTemplate := u_LoadTemplate("\workflow\template\form_cotacao.htm")

    DbSelectArea("SY1")
    DbSetOrder(3) // Y1_FILIAL+Y1_USER
    DbSeek(xFilial("SY1")+__cUserID)

    DbSelectArea("SC8")
    DbSetOrder(1) // C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD

    DbSelectArea("SC1")
    DbSetOrder(1) // C1_FILIAL+C1_NUM+C1_ITEM

    DbSelectArea("SA2")
    DbSetOrder(1) // A2_FILIAL+A2_COD+A2_LOJA
    
    DbSelectArea("SB1")
    DbSetorder(1) // B1_FILIAL+B1_COD

    cWFID := u_GetWFID()

    begin transaction

    nLen := Len(aSolicitac) 
    for i := 1 to nLen
        
        cSql:= " select SC8.C8_FILIAL" +;
                    " , SC8.C8_NUM" +;
                    " , SC8.C8_FORNECE" +;
                    " , SC8.C8_LOJA" +;
                    " , SC8.C8_ITEM" +;
                    " , SC8.R_E_C_N_O_ C8_RECNO" +;
                    " , SC1.R_E_C_N_O_ C1_RECNO" +;
                    " , SA2.R_E_C_N_O_ A2_RECNO" +;
                 " from " + RetSqlName("SC8") + " SC8" +;
                 " join " + RetSqlName("SC1") + " SC1" +;
                   " on SC1.C1_FILIAL  = '" + xFilial("SC1") + "'" +;
                  " and SC1.C1_NUM     = SC8.C8_NUMSC" +;
                  " and SC1.C1_ITEM    = SC8.C8_ITEMSC" +;
                  " and SC1.D_E_L_E_T_ = ' '" +;
                 " join " + RetSqlName("SA2") + " SA2" +;
                   " on SA2.A2_FILIAL  = '" + xFilial("SA2") + "'" +;
                  " and SA2.A2_COD     = SC8.C8_FORNECE" +;
                  " and SA2.A2_LOJA    = SC8.C8_LOJA" +;
                  " and SA2.D_E_L_E_T_ = ' '" +;
                " where SC8.C8_FILIAL  = '" + xFilial("SC8") + "'" +;
                  " and " + Iif( ValType(aSolicitac[i]) == 'C', "SC8.C8_NUM = '" + aSolicitac[i] + "'" , " SC8.C8_NUM = '" + aSolicitac[i][1] + "' and SC8.C8_FORNECE+SC8.C8_LOJA = '" + aSolicitac[i][2] + "' and SC8.C8_NUMPRO = '" + aSolicitac[i][3] + "'" ) +;
                  " and SC8.D_E_L_E_T_ = ' '" +;
             " order by SC8.C8_FILIAL, SC8.C8_NUM, SC8.C8_FORNECE, SC8.C8_LOJA, SC8.C8_ITEM"

        DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cSql)), "TMPSC8", .f., .f.)
        while !TMPSC8->(Eof()) 
            if TMPSC8->C8_FILIAL+TMPSC8->C8_NUM+TMPSC8->C8_FORNECE+TMPSC8->C8_LOJA != cChave
                if lEnvia .and. !Empty(cChave)
                    u_UpdForm(@aForm)
                    u_WFEnvCot(aForm, cChave)
                endif
                lEnvia := .t.
                aForm := aClone(aTemplate)
                cChave := TMPSC8->C8_FILIAL+TMPSC8->C8_NUM+TMPSC8->C8_FORNECE+TMPSC8->C8_LOJA
                SC8->(DbGoTo(TMPSC8->C8_RECNO))
                SC1->(DbGoTo(TMPSC8->C1_RECNO))
                SA2->(DbGoTo(TMPSC8->A2_RECNO))
                if Empty(SA2->A2_EMAIL)
                    ShowHelpDlg("WFPROC01", {"O e-mail do fornecedor não está preenchido."}, 1, {"Por favor, preencha o e-mail do fornecedor e use a rotina de o reenvio da cotação em atualização de cotações."}, 1 )
	                lEnvia := .f.
                else
                    u_WfProc(@aForm, SA2->A2_EMAIL)
                endif
            else
                SC8->(DbGoTo(TMPSC8->C8_RECNO))
                SC1->(DbGoTo(TMPSC8->C1_RECNO))
                SA2->(DbGoTo(TMPSC8->A2_RECNO))
            endif

            if lEnvia
                u_WfProcLin(@aForm)
                
			    RecLock('SC8', .f.)
			    SC8->C8_WFCO   := "1"
			    if Empty(SC8->C8_WFDT)
			    	SC8->C8_WFDT   := dDataBase
			    endif
			    
			    if empty(SC8->C8_WFEMAIL)
			    	if cUsername == "Administrador"
			    		SC8->C8_WFEMAIL := GetMV("MV_RELACNT")
			    	else
			    	    PswOrder(1)
                        PswSeek(__cUserId)
			    		SC8->C8_WFEMAIL := Iif(Empty(SY1->Y1_EMAIL), PswRet(1)[1][14], AllTrim(SY1->Y1_EMAIL))
			    	endif
			    endif
			    
			    SC8->C8_WFID := cWFID 
                SC8->C8_XNOMFOR := SA2->A2_NOME
                
                MsUnlock()
            endif
            TMPSC8->(DbSkip())
        end        
        TMPSC8->(DbCloseArea())

        if lEnvia .and. !Empty(cChave)
            u_UpdForm(@aForm)
            u_WFEnvCot(aForm, cChave)
        endif
        
    next
    
    end transaction

endif

RestArea(aArea)
return nil

/*/{Protheus.doc}u_WfProc
    A rotina preenche os detalhes da gerais (não pertencentes aos itens) do formulario.
    
@since 20170404
@author jrscatolon@jrscatolon.com.br
@param aForm, Array, Formulario criado pela rotina u_LoadTemplate contendo os detalhes do template do HTML.
@return Nil, nulo
/*/
user function WfProc(aForm, cEmailPara)
local lRet := .t.
local nPosIni := 0
local nPosFim := 0
local cExpress := "" 
local cContent := ""

    aForm[4] := cEmailPara
    
    while (nPosIni := At("{%", aForm[3])) > 0
        if (nPosFim :=  At("%}", aForm[3])) == 0
            UserException("Não foi identificada a tag de fechamento %} para a " + SubStr(aForm[3], nPosIni, 15) + "...")
        endif
        cExpress := SubStr(aForm[3], nPosIni, (nPosFim-nPosIni)+2)
        cContent := u_ToString(&(SubStr(cExpress, 3, Len(cExpress)-4)))
        aForm[3] := StrTran(aForm[3], cExpress, cContent)
    end  
    
return lRet

//aForm := {<Gabarito>,{aItem_1, aItem_2},<arquivo processado>,<e-Mail>}
//aItem := {<Código Linha>, <Template da linha>, {<Item1, Item2, Item3>}}
//aItem := {"<WFITEM_" + StrZero(nCntItem, 3)+">", SubStr(aTempl[3], nPosIni, nPosFim-nPosIni), {}}
/*/{Protheus.doc}u_WfProcLin
    A rotina preenche os detalhes dos ítens do formulario.
@since 20170404
@author jrscatolon@jrscatolon.com.br
@param aForm, Array, Formulario criado pela rotina u_LoadTemplate contendo os detalhes do template do HTML.
@return Nil, nulo
/*/
user function WfProcLin(aForm)
local i, nLen 
local nPosIni := 0
local nPosFim := 0
local cExpress := ""
local cContent := ""


nLen := Len(aForm[2])
for i := 1 to nLen
    cForm := aForm[2][i][2]
    
    while (nPosIni := At("{%", cForm)) > 0  
        if (nPosFim :=  At("%}", cForm)) == 0
            UserException("Não foi encontrado o fechamento da tag %} para a " + SubStr(cForm, nPosIni, 15) +  "...")
        endif
        cExpress := SubStr(cForm, nPosIni, (nPosFim-nPosIni)+2)
        cContent := u_ToString(&(SubStr(cExpress, 3, Len(cExpress)-4)))

        cForm := StrTran(cForm, cExpress, cContent)
    end
    
    AAdd(aForm[2][i][3], cForm)
next

return nil

/*/{Protheus.doc}u_UpdForm
    Atualiza o formulario, substuindo os ítens, caso existam.
@since 20170404
@author jrscatolon@jrscatolon.com.br
@param aForm, Array, Formulario criado pela rotina u_LoadTemplate contendo os detalhes do template do HTML.
@param cChave, Chave para o registro usado para identificar a cotação.
@return Nil, nulo
/*/
user function UpdForm(aForm)
local i, j, nLen, nLenJ
local cItens := ""

nLen := Len(aForm[2])
for i := 1 to nLen

    nLenJ := Len(aForm[2][i][3])
    cItens := ""
    for j := 1 to nLenJ
        cItens += aForm[2][i][3][j] + CRLF
    next j
    aForm[3] := StrTran(aForm[3], aForm[2][i][1], cItens)

next i

return nil

/*/{Protheus.doc}u_WFEnvCot
    Dispara o e-mail com o formulário.
@since 20170404
@author jrscatolon@jrscatolon.com.br
@param aForm, Array, Formulario criado pela rotina u_LoadTemplate contendo os detalhes do template do HTML.
@param cChave, Chave para o registro usado para identificar a cotação.
@return Nil, nulo
/*/
user function WFEnvCot(aForm, cChave)

MemoWrite("\workflow\cotacao\cotacao_" + cChave + ".htm", aForm[3])
cMessage := MemoRead("\workflow\template\corpo_email.htm")
cMessage := StrTran(cMessage, "{%NUMCOT%}", SubStr(cChave, TamSX3("C8_FILIAL")[1]+1,TamSX3("C8_NUM")[1]))
u_EnvMail(aForm[4], /*_cCc*/, /*_cBCC*/, "Solicitação de proposta de cotação V@ " + SubStr(cChave, 1, TamSX3("C8_FILIAL")[1] + TamSX3("C8_NUM")[1]) + ".", {"\workflow\cotacao\cotacao_" + cChave + ".htm"}, cMessage, /*_lAudit*/)

return nil

/*/{Protheus.doc}u_ToString
    Converte qualquer valor em string.
@since 20170404
@author jrscatolon@jrscatolon.com.br
@param xVar, Qualquer, Valor a ser convertido para string.
@return String, Valor convertido de xVar
/*/
user function ToString(xVar)
local cRet := ""
local cType := ValType(xVar)

if cType == 'U'
    cRet := "nil"
elseif cType == 'C'
    cRet := AllTrim(xVar)
elseif cType == 'N'
    cRet := AllTrim(Str(xVar))
elseif cType == 'D'
    cRet := DToC(xVar)
elseif cType == 'L'
    cRet := Iif(xVar, "Verdadeiro", "Falso")
elseif cType == 'B'
    cRet := u_ToString(Eval(xVar))
elseif cType == 'A'
    cRet := AToS(xVar)
elseif cType == 'O'
    UserException("Nao é possivel converter objeto para o tipo string.")
endif   
return cRet

/*/{Protheus.doc}u_LoadTemplate
    Carrega o template a partir do arquivo indicado em cFileTempl e retorna o objeto aTempl.
@since 20170404
@author jrscatolon@jrscatolon.com.br
@param cFileTempl, Caminho para o template do formulário HTML.
@return aTempl, nulo
/*/
user function LoadTemplate(cFileTempl)
local aTempl := {}
local nHandle := 0
local cTemplate := ""
local nSizeFile := 0
local nSizeRead := 0
local nCntItem := 0
local nPosIni := 0
local nPosFim := 0

if !File(cFileTempl)
    UserException("Template " + cFileTempl + " não localizado. Por favor entre em contato com o TI.")
endif

nHandle := FOpen(cFileTempl, FO_READ)
if FError() != 0 .and. nHandle == -1
    UserException("Não foi possivel abrir o arquivo " + cFileTempl + ". Erro retornado: " + Str(fError(), 4) + ".")
endif

if (nSizeFile := FSeek(nHandle, 0, FS_END)) == 0 
    UserException("O arquivo " + cFileTempl + " está vazio. Operação inválida.")
endif

FSeek(nHandle, 0, FS_SET)
if (nSizeRead := FRead(nHandle, @cTemplate, nSizeFile)) !=  nSizeFile .or. FError() > 0
    UserException("Não foi possivel carregar o arquivo " + cFileTempl + ". Erro retornado: " + Str(fError(), 4) + ".")
endif

// { Arquivo de gabarito, { {<marcador>, gabarito dos itens, {resgistro processado 1, resgistro processado 1}} }, <Registro Processado>, <e-mail fornecedor> }
aTempl := {cTemplate, {}, cTemplate, ""}

while At("<wf_item>", aTempl[3]) > 0
    nCntItem++
    nPosIni := At("<wf_item>", aTempl[3]) 
    nPosFim := At("</wf_item>", aTempl[3]) + 10 
    aItem := {"<WFITEM_" + StrZero(nCntItem, 3)+">", SubStr(aTempl[3], nPosIni, nPosFim-nPosIni), {}}
    aTempl[3] := StrTran(aTempl[3], aItem[2], aItem[1])
    aItem[2] := StrTran(aItem[2], "<wf_item>", "")
    aItem[2] := StrTran(aItem[2], "</wf_item>", "")
    AAdd(aTempl[2], AClone(aItem))
end

return aTempl

/*/{Protheus.doc}u_CondPgto
    Retorna as condições de pagamento no formato Option do HTML.
@since 20170404
@author jrscatolon@jrscatolon.com.br
@return aTempl, nulo
/*/
user function CondPgto()
local aArea := GetArea()
local cCondicao := ""
local cSql := "select SE4.E4_CODIGO, SE4.E4_DESCRI from " + RetSqlName("SE4") + " SE4 where SE4.E4_FILIAL = '" + xFilial("SE4") + "' and SE4.E4_XUSAWFC = '1' and SE4.D_E_L_E_T_ = ' '"

DbUseArea(.t., "TOPCONN", TCGenQry(,,cSql), "TMPSE4", .f., .f.)
while !TMPSE4->(Eof())
    cCondicao += "<option>" + AllTrim(TMPSE4->E4_CODIGO) + "-" + AllTrim(TMPSE4->E4_DESCRI) + "</option>" 
    TMPSE4->(DbSkip())
end
TMPSE4->(DbCloseArea())

RestArea(aArea)
return cCondicao

/*/{Protheus.doc}u_Mt130WfR
    Retorna as condições de pagamento no formato Option do HTML.
@since 20170404
@author jrscatolon@jrscatolon.com.br
@return aTempl, nulo
/*/
user function MT130WFR(aBody, cChave)
local aArea := {}
local cStatus := ""
local aItens := {}
local aCabec := {}
local nCont := 0
local cForn := ""
local cMail := ""
local cLoja := ""
local cCotac := ""
//local nItens := 0

local cCodBranch := ""
local cFilCorren := ""

local cPayment := ""
local cBank := ""
local cBranch := ""
local cAccount := ""


if Alias() != ""
    aArea := GetArea()
endif

if cFilAnt != (cCodBranch := u_GetByName(aBody, "CCODFIL"))
	cFilCorren := cFilAnt
	cFilAnt    := cCodBranch
endif

DbSelectArea("SA2")
DbSetOrder(1) // A2_FILIAL+A2_COD+A2_LOJA

DbSelectArea("SB1")
DbSetOrder(1) // B1_FILIAL+B1_COD 

DbSelectArea("SC8")
DbSetOrder(1)  // C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD

if SC8->(DbSeek(cChave))
    
    if AllTrim(cWFID := u_GetByName(aBody, "C8_WFID")) != AllTrim(SC8->C8_WFID)
        cStatus := "Cotação desatualizada. Foi gerado um formulário de cotação mais recente que o utilizado. Por favor, entre em contato com nosso time de compras." 
    else

        SA2->(DbSeek(xFilial("SA2")+SC8->C8_FORNECE+SC8->C8_LOJA))
    
        cCodBranch := u_GetByName(aBody, "CODFIL")
    	cForn := u_GetByName(aBody, "C8_FORNECE")
    	cLoja := u_GetByName(aBody, "C8_LOJA")
    	cCotac := u_GetByName(aBody, "C8_NUM")
    	cMail := u_GetByName(aBody, "A2_EMAIL")

        cPayment := SubStr(u_GetByName(aBody, "A2_XFORMPG"), 1, 3)
        cBank := u_GetByName(aBody, "A2_XBANCO")
        cBranch := u_GetByName(aBody, "A2_XAGENCI")
        cAccount := u_GetByName(aBody, "A2_XCONTA")
    
        RecLock("SA2", .f.)
            A2_XFORMPG := cPayment
            A2_XBANCO := cBank
            A2_XAGENCI := cBranch
            A2_XCONTA := cAccount
        MsUnlock()
        
        AAdd(aCabec, {"C8_FORNECE", cForn, nil})
        AAdd(aCabec, {"C8_LOJA", cLoja, nil})
        AAdd(aCabec, {"C8_COND", SubStr(u_GetByName(aBody,"CCONDICAO"), 1, 3), nil})
        AAdd(aCabec, {"C8_CONTATO", u_GetByName(aBody,"C8_CONTATO"), nil})
        AAdd(aCabec, {"C8_NUM", cCotac, nil})
        AAdd(aCabec, {"C8_MOEDA", 1, nil})
        AAdd(aCabec, {"C8_VALFRE", u_ToNumber(u_GetByName(aBody,"VALFRE")), nil})
        AAdd(aCabec, {"C8_TPFRETE", u_GetByName(aBody,"FRETE"), nil})
    
        while SC8->C8_FILIAL + SC8->C8_NUM + SC8->C8_FORNECE + SC8->C8_LOJA == cChave 
            nCont := Val(SC8->C8_ITEM)
            if !Empty( cItem := u_GetByName(aBody, "IT.C8_ITEM", nCont)) .and. cItem == SC8->C8_ITEM
                SB1->(DbSeek(xFilial("SB1")+SC8->C8_PRODUTO))
                AAdd(aItens,; 
                     { { "C8_ITEM",    cItem, nil },;
                       { "C8_NUMPRO",  u_GetByName(aBody,"IT.C8_NUMPRO", nCont), nil},;
                       { "C8_PRODUTO", SC8->C8_PRODUTO, nil },;
                       { "C8_UM",      SC8->C8_UM, nil },;
                       { "C8_QUANT",   u_ToNumber(u_GetByName(aBody, "IT.QUANT", nCont)), nIL },;
                       { "C8_PRECO",   u_ToNumber(u_GetByName(aBody, "IT.PRECO", nCont)), nil },;
                       { "C8_TOTAL",   u_ToNumber(u_GetByName(aBody, "IT.QUANT", nCont))*u_ToNumber(u_GetByName(aBody, "IT.PRECO", nCont)), nil },;
                       { "C8_DESC",    u_ToNumber(u_GetByName(aBody, "IT.DESCO", nCont)), nil },;
                       { "C8_PRAZO",   u_ToNumber(u_GetByName(aBody, "IT.PRAZO", nCont)), nil },;
                       { "C8_ALIIPI",  u_ToNumber(u_GetByName(aBody, "IT.PRAZO", nCont)), nil },;
                       { "C8_PICM",    0, nil },;
                       { "C8_TAXAFIN", 0, nil },;
                       { "C8_ALIIPI",  u_ToNumber(u_GetByName(aBody, "IT.PRAZO", nCont)), nil },;
                       { "C8_XMARCA",  u_GetByName(aBody, "IT.MARCA", nCont), nil },; 
                       { "C8_OBS",     u_GetByName(aBody, "IT.OBSERV", nCont), nil },; 
                       { "C8_WFCO",    "2", nil };
                       };
                )
            endif
            SC8->(DbSkip())
        end
        cStatus := U_AtuCotac( aClone(aCabec), aClone(aItens) ) 
    endif
endif

if !Empty(cFilCorren)
	cFilAnt := cFilCorren
endif

return cStatus

user function AtuCotac( aCabec, aItens )
local cStatus        := ""
local nPosC8_NUM     := aScan( aCabec,    { | aVet | aVet[1] == "C8_NUM"     } )
local nPosC8_FORNECE := aScan( aCabec,    { | aVet | aVet[1] == "C8_FORNECE" } )
local nPosC8_LOJA    := aScan( aCabec,    { | aVet | aVet[1] == "C8_LOJA"    } )
local nPosC8_ITEM    := aScan( aItens[1], { | aVet | aVet[1] == "C8_ITEM"    } )
local nPosC8_NPRO    := aScan( aItens[1], { | aVet | aVet[1] == "C8_NUMPRO"  } )

/* Mudança de usuário necessária para identificação de comprador pelo execauto */
local __cUserIDOld := __cUserID
local cUserNameOld := cUserName
local cUsuarioOld  := cUsuario

private lMsErroAuto := .F.

PswOrder( 2 ) // indice por Nome
PswSeek("defcomp", .T.)  // Pesquisa o Nome no cadastro de usuario
aUser := PSWRET( 1 )

__cUserID := aUser[1][1]
cUserName := aUser[1][2]
cUsuario  := aUser[1][1]+aUser[1][2] 

DbSelectArea( "SC8" )
DbSetOrder( 1 )

if DbSeek( xFilial( "SC8" ) + aCabec[nPosC8_NUM][2] + aCabec[nPosC8_FORNECE][2] + aCabec[nPosC8_LOJA][2] + aItens[1][nPosC8_ITEM][2] + aItens[1][nPosC8_NPRO][2] )
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ PARAMETROS PARA ROTINA AUTOMATICA :                          ³
    //³ ExpA1 : Array contendo os dados do cabecalho da Cotacao      ³
    //³ ExpA2 : Array contendo os dados dos itens                    ³
    //³ ExpN3 : Indica qual a operacao  a ser executada  -           ³
    //³         2 : Inclui novo participante                         ³
    //³         3 : Atualiza os dados de uma cotacao ja existente    ³
    //³         4 : Inclui uma nova proposta em uma cotacao ja exis. ³
    //³         5 : Exclui toda a cotacao                            ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  
    FG_X3ORD("C",,aCabec)
    FG_X3ORD("I",,aItens)

    MemoWrite("\http\mata150.txt", "aCabec := " + U_AToS(aCabec) + CRLF + "aItens" + U_AToS(aItens) + CRLF + "MSExecAuto( { |v,x,y| MATA150( v, x, y ) }, aCabec, aItens, 3)" )

    MSExecAuto( { |v,x,y| MATA150( v, x, y ) }, aCabec, aItens, 3) // ExecAuto para atualização
    
    if !lMsErroAuto
        cStatus := " Cotação " + aCabec[nPosC8_NUM][2] + " de " + aCabec[nPosC8_FORNECE][2] + aCabec[nPosC8_LOJA][2] + " atualizado com sucesso! "
    else
        cStatus := " Erro na atualização da cotação " + aCabec[nPosC8_NUM][2] + " de " + aCabec[nPosC8_FORNECE][2] + aCabec[nPosC8_LOJA][2] + "." + Chr(10) + Chr(13)
        MemoWrite("\workflow\error\" + aCabec[nPosC8_NUM][2] + aCabec[nPosC8_FORNECE][2] + aCabec[nPosC8_LOJA][2] + ".txt", MemoRead(NomeAutoLog()))
        UpdateStatus(aCabec[nPosC8_NUM][2], aCabec[nPosC8_FORNECE][2], aCabec[nPosC8_LOJA][2], aItens[1][nPosC8_NPRO][2], '3')
    endif
    
else
    
    cStatus := "Registro ['" + xFilial( "SC8" ) + aCabec[nPosC8_NUM][2] + aCabec[nPosC8_FORNECE][2] + aCabec[nPosC8_LOJA][2] + aItens[1][nPosC8_ITEM][2] + aItens[1][nPosC8_NPRO][2] + "'] não encontrado."
    
endif

/* Retornando usuário anterior */
__cUserID := __cUserIDOld
cUserName := cUserNameOld
cUsuario  := cUsuarioOld

return cStatus


/*/{Protheus.doc}u_ToNumber
    Converte a string passada em formato brasileiro em numero.
@since 20170404
@author jrscatolon@jrscatolon.com.br
@param cValue, String, Numero em formato brasileiro.
@return Numeric, Valor convertido.
/*/
user function ToNumber(cValue)
local cVal := "0"
local i    := 0

for i := 1 To Len( cValue )
    if ( ( SubStr( cValue, i, 1 ) >= '0' .AND. SubStr( cValue, i, 1 ) <= '9' ) .OR. SubStr( cValue, i, 1 ) == ',' )
        cVal += Iif( SubStr( cValue, i, 1 ) != ',', SubStr( cValue, i, 1 ), '.' )
    endIf
next

return Val(cVal)

/*/{Protheus.doc}u_ToNumber
    Converte a string passada em formato brasileiro em numero.
@since 20170404
@author jrscatolon@jrscatolon.com.br
@param cValue, String, Numero em formato brasileiro.
@return Numeric, Valor convertido.
/*/
user function GetByName(aRet, cToken, nItem)
local cContent := ""
local cItem := Iif(nItem == nil, "", "." + AllTrim(Str(nItem)))
local nPos := aScan(aRet, {|aMat| AllTrim(aMat[1]) == AllTrim(cToken+cItem)})

    if nPos != 0
        cContent := AllTrim(aRet[nPos][2])
    endif

return cContent


static function UpdateStatus(cCotacao, cFornece, cLoja, cProposta, cStatus)

cSql := " update " + RetSqlName("SC8") +;
           " set C8_WFCO = '" + AllTrim(cStatus) + "'" +;
         " where C8_FILIAL  = '" + xFilial("SC8") + "'" +;
           " and C8_NUM     = '" + cCotacao + "'" +;
           " and C8_FORNCE  = '" + cFornece + "'" +;
           " and C8_LOJA    = '" + cLoja + "'" +;
           " and C8_NUMPRO  = '" + cProposta + "'" +;
           " and D_E_L_E_T_ = ' '"  

    TCSqlExec(cSql) < 0

return nil

user function GetWFID()
local cWFID := ""
    
    while !LockByName("U_GetWFID", .t., .f.)
        Sleep(1000)
    end
    if Empty(cWFID := GetMV("VA_WFID"))
        cWFID := StrZero(1, TamSX3("C8_WFID")[1])
    endif
    PutMV("VA_WFID", Soma1(cWFID))
    UnlockByName("U_GetWFID")

return cWFID
