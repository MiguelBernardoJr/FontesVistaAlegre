#include 'protheus.ch'
#include 'parmtype.ch'

user function mt160wf(cCotac)
local aArea := GetArea()
local aAreaSC8 := SC8->(GetArea())
local cSql := ""
local cAliasTmp := GetNextAlias()

default cCotac := ParamIXB[1]

	Alert( 'IsInCallStack: ' + cValToChar( IsInCallStack("U_XGERASC7()") ) )

	DbSelectArea("CTD")
	DbSetOrder(1)
	
	DbSelectArea("CTT")
	DbSetOrder(1) 
	
	cSql := " select distinct SC7.C7_NUM, SCR.CR_USER" +;
	          " from " + RetSqlName("SC7") + " SC7" +;
	          " join " + RetSqlName("SCR") + " SCR" +;
	            " on SCR.CR_FILIAL  = SC7.C7_FILIAL" +;
	           " and SCR.CR_NUM     = SC7.C7_NUM" +;
	           " and SCR.CR_STATUS  = '02'" +;
	           " and SCR.D_E_L_E_T_ = ' '" +;
	         " where SC7.C7_FILIAL = '" + xFilial("SC7") + "'" +;
	           " and SC7.C7_NUM in ( " +;
	               " select distinct C8_NUMPED " +;
	                 " from " + RetSqlName("SC8") + " " +;
	                " where C8_FILIAL  =  SC7.C7_FILIAL " +;
	                  " and C8_NUM     =  '" + cCotac + "' " +;
	                  " and C8_NUMPED  <> 'XXXXXX' " +;
	                  " and D_E_L_E_T_ = ' '" +;
	               " )" +;
	           " and SC7.D_E_L_E_T_ = ' '" +;
	      " order by C7_NUM"
	
	DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cSql)), cAliasTmp, .f., .f. )
	
	while (cAliasTmp)->(!Eof())
	    u_SndLib((cAliasTmp)->C7_NUM, (cAliasTmp)->CR_USER)
	    (cAliasTmp)->(DbSkip())
	end
	
	(cAliasTmp)->(DbCloseArea())

SC8->(RestArea(aAreaSC8))
RestArea(aArea)	
return nil

user function SndLib(cNumPed, cUser)
local aArea := GetArea()
local aAreaSC7 := {}
local aTemplate := {}
local cChave := ""
local cFornece := ""
local cLoja := ""
local cNumPro := ""
local lEnvia := .t.
local nQtdRegs := 0
local cEmailTo := ""

private cOperacao := "MATA097"
private cWFID := ""
private nSubTotal := 0
private nValIPI := 0
private nValFrete := 0
private nTotal := 0 

if Type("oMainWnd") == 'U' .or. Aviso("Email", "Deseja enviar email de aprovação para o aprovador?", {"Sim", "Não"}) == 1

    /* if FunName()=="MATA150"
        cFornece := SC8->C8_FORNECE
        cLoja := SC8->C8_LOJA
        cNumPro := SC8->C8_NUMPRO
    endif */
    aForm := u_LoadTemplate("\workflow\template\form_aprovacao.htm")

    cSql := " select count(*) QTDREG" +; 
              " from " + RetSqlName("SC7") + " SC7" +; 
             " where SC7.C7_FILIAL = '" + xFilial("SC7") + "'" +; 
               " and SC7.C7_NUM = '" + cNumPed + "'" +; 
               " and SC7.D_E_L_E_T_ = ' '"
               
    DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cSql)),"QRY", .f., .t.)
        nQtdRegs := QRY->QTDREG
    QRY->(DbCloseArea())

    DbSelectArea("SY1")
    DbSetOrder(3) // Y1_FILIAL+Y1_USER
    DbSeek(xFilial("SY1")+__cUserID)
   
    DbSelectArea("SC7")
    DbSetOrder(1) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
    SC7->(DbSeek(xFilial("SC7")+cNumPed))

    DbSelectArea("SCR")
    DbSetOrder(1) // CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
    SCR->(DbSeek(xFilial("SCR")+"PC"+PadR(cNumPed, TamSX3("CR_NUM")[1])))
    
    DbSelectArea("SAK")
    DbSetOrder(1) // AK_FILIAL + AK_COD
    SAK->(DbSeek(xFilial("SAK")+SCR->CR_APROV))

    DbSelectArea("SA2")
    DbSetOrder(1) // A2_FILIAL+A2_COD+A2_LOJA
    SA2->(DbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))
    
    DbSelectArea("SB1")
    DbSetorder(1) // B1_FILIAL+B1_COD
    SB1->(DbSeek(xFilial("SB1")+SC7->C7_PRODUTO))

    DbSelectArea("SE4")
    DbSetOrder(1) // E4_FILIAL+E4_CODIGO

    cWFID := u_GetWFID()
    
    begin transaction

    aAreaSC7 := SC7->(GetArea())
    
    while !SC7->(Eof()) .and. SC7->C7_FILIAL == xFilial("SC7") .and. SC7->C7_NUM == cNumPed
        
        RecLock("SC7", .f.)

        SC7->C7_WFCO   := "1"
	    if Empty(SC7->C7_WFDT)
	    	SC7->C7_WFDT   := dDataBase
	    endif
	    if empty(SC7->C7_WFEMAIL)
	        if Empty(cEmailTo)
    	        PswOrder(1)
                PswSeek(SAK->AK_USER)
                cEmailTo := PswRet(1)[1][14]
            endif
    		SC7->C7_WFEMAIL := cEmailTo
	    else
	        cEmailTo := SC7->C7_WFEMAIL
	    endif
		    
	    SC7->C7_WFID := cWFID             
        MsUnlock()

        u_WfProcLin(@aForm)
        nSubTotal += SC7->C7_TOTAL
        nValIPI += SC7->C7_VALIPI
        nValFrete += SC7->C7_VALFRE

        SC7->(DbSkip())
    end
    
    SC7->(RestArea(aAreaSC7))

    
    nTotal := nSubTotal + nValIPI + nValFrete
    u_WfProc(@aForm, cEmailTo)
    u_UpdForm(@aForm)
    
    u_WFEnvApr(aForm, StrTran(SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL), " ", "_"), cNumPed)
    
    end transaction
endif    
RestArea(aArea)
return nil

user function WFEnvApr(aForm, cChave, cNumPed)
Local i      := 0
local aAnexo := {"\workflow\cotacao\aprovacao_" + cChave + ".htm"} 
    
    MemoWrite(aAnexo[1], aForm[3])
    cMessage := MemoRead("\workflow\template\corpo_aprova.htm")
    
    DbSelectArea("SC7")
    DbSetOrder(1)
    DbSeek(xFilial("SC7")+cNumPed)

    if !Empty(SC7->C7_NUMCOT) .and. File(cPlanCotac := u_SC8Plan(SC7->C7_NUMCOT))
        AAdd(aAnexo, cPlanCotac)
    endif
    
    u_EnvMail(aForm[4], /*_cCc*/, /*_cBCC*/, "Solicitação de Aprovação V@ " + cFilAnt + cNumPed + ".", aAnexo, cMessage, /*_lAudit*/)

    for i := 1 to Len(aAnexo)
        FErase(aAnexo[i])
    next
    
return nil

user function mt097wfr(aBody, cChave)
local cStatus := "Aprovação efetuada com sucesso."
local aUser := {}

    DbSelectArea("SC7")
    DbSetOrder(1) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
    if SC7->(DbSeek(cChave))
        
        DbSelectArea("SCR")
        DbSetOrder(1) // CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL

        if SCR->(DbSeek(xFilial("SCR")+"PC"+PadR(SC7->C7_NUM, TamSX3("CR_NUM")[1])))

            if SCR->CR_STATUS == "02"

                PswOrder(1) // 1 - ID do usuário/grupo
                PswSeek(AllTrim(SCR->CR_USER))
                aUser := PSWRET( 1 )

                __cUserID := aUser[1][1]
                cUserName := aUser[1][2]
                cUsuario  := aUser[1][1]+aUser[1][2] 
                cModulo := "COM"
                nModulo := 2

                cCodLiber := aBody[AScan(aBody, {|aMat| Upper(AllTrim(aMat[1])) == 'APROVACAO'})][2]
                cObs := aBody[AScan(aBody, {|aMat| Upper(AllTrim(aMat[1])) == 'OBS'})][2]
                
                A097ProcLib(SCR->(RecNo()),Iif(cCodLiber=='02', 2, 3),/*nTotal*/,cCodLiber,/*cGrupo*/,cObs,/*dRefer*/)

                MSUnlockAll()

            else
                cStatus := "Documento selecionado já sofreu alteração anterior. Não será possível efetuar a operação. Para alterar o documento utilize o Protheus."
            endif
        else
            cStatus := "Documento de aprovacao nao identificado."
        endif
    else
        cStatus := "Pedido não identificado."
    endif
    
return cStatus

