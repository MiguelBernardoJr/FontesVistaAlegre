#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#Include "TryException.ch"
/* 
Igor Gomes Oliveira 
P.E     : MT131WF - Customização de WorkFlow
Rotina  : MATA131.PRW
Data    : 22/03/2023  
*/
User Function MT131WF(aSolicitac)
    local aArea         := GetArea()
    Local i,j,x
    Local nI 
    Local _cQry         := ''
    Local cWFID         := ''
    Local cChave        := ''
    Local _cCODCOMP     := Posicione("SY1", 3, xFilial("SY1") + RetCodUsr(), "Y1_COD")
    Local _cGRUPCOM     := SY1->Y1_GRUPCOM
    Local lEnvia        := .f.
    Local lImpObs       := .t.
    //Local aCotacao      := {}//Enviado como chave para VACOMR10
    Local aImprimir     := {}//Array de dados para VACOMR10
    Local aDados        := {} // dados gerais
    Local aArquivos     := {} // dados gerais
    Local cForMail      := ''
    Local cAlias        := GetNextAlias()
    Local cAliasA       := ""
 
    Private cTimeIni	:= Time()
    Private cMessage    := ""
    private cServPath   := "\cotacoes\"
    Private cLocalPath  := "C:\TOTVS_RELATORIOS\COTACOES\"
    private cOperacao   := "MATA131"

    default aSolicitac := ParamIXB[2] // ParamIXB[1] é a mesma coisa que ParamIXB[2][1]

    DbSelectArea("SY1")
    DbSetOrder(3) // Y1_FILIAL+Y1_USER
    DbSeek(xFilial("SY1")+__cUserID)

    DbSelectArea("SC8")
    DbSetOrder(1) // C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD

    DbSelectArea("SC1")
    DbSetOrder(1) // C1_FILIAL+C1_NUM+C1_ITEM

    DbSelectArea("SA2")
    DbSetOrder(1) // A2_FILIAL+A2_COD+A2_LOJA\
    
    DbSelectArea("SB1")
    DbSetorder(1) // B1_FILIAL+B1_COD
    
    cWFID := u_GetWFID()

    begin transaction

        nLen := Len(aSolicitac) 
        for i := 1 to nLen
            lImpObs := .T.

            _cQry := " select SC8.C8_FILIAL" + CRLF
            _cQry += " , SC8.C8_NUM" + CRLF
            _cQry += " , SC8.C8_FORNECE" + CRLF
            _cQry += " , SC8.C8_LOJA" + CRLF
            _cQry += " , SC8.C8_NUMPRO" + CRLF
            _cQry += " , SC8.C8_FILENT" + CRLF
            _cQry += " , SC8.C8_FORMAIL" + CRLF
            _cQry += " , SC8.C8_QUANT" + CRLF
            _cQry += " , SC8.C8_ITEM" + CRLF
            _cQry += " , SC8.C8_ITEMGRD" + CRLF
            _cQry += " , SC8.C8_FORNOME" + CRLF
            _cQry += " , SC8.C8_PRAZO" + CRLF
            _cQry += " , ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), C8_MSGMAIL)),'') AS MSGMAIL" + CRLF
            _cQry += " , SC1.C1_ITEM" + CRLF
            _cQry += " , SC1.C1_NUM" + CRLF
            _cQry += " , SC1.C1_EMISSAO" + CRLF
            _cQry += " , SC1.C1_UM" + CRLF
            _cQry += " , SC1.C1_DESCRI" + CRLF
            _cQry += " , SC1.C1_PRODUTO" + CRLF
            _cQry += " , SC1.C1_ITEM" + CRLF
            _cQry += " , SA2.A2_NOME" + CRLF
            _cQry += " , SA2.A2_EST" + CRLF
            _cQry += " , SA2.A2_COD_MUN" + CRLF
            _cQry += " , SA2.A2_END" + CRLF
            _cQry += " , SA2.A2_TEL" + CRLF
            _cQry += " , SA2.A2_FAX" + CRLF
            _cQry += " , SA2.A2_CONTATO" + CRLF
            _cQry += " , SA2.A2_MUN" + CRLF
            _cQry += " , SA2.A2_CGC" + CRLF
            _cQry += " , SA2.A2_CGC" + CRLF
            _cQry += " , SA2.A2_EMAIL" + CRLF
            _cQry += " , SB1.B1_DESC" + CRLF
            _cQry += " , ISNULL(CAST(CAST(SC8.C8_OBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS C8_OBS " + CRLF
            _cQry += " , SC8.R_E_C_N_O_ C8_RECNO" + CRLF
            _cQry += " , SC1.R_E_C_N_O_ C1_RECNO" + CRLF
            _cQry += " , SA2.R_E_C_N_O_ A2_RECNO" + CRLF
            _cQry += " from " + RetSqlName("SC8") + " SC8" + CRLF 
            _cQry += " join " + RetSqlName("SC1") + " SC1" + CRLF 
            _cQry += " on SC1.C1_FILIAL  = '" + xFilial("SC1") + "'" + CRLF 
            _cQry += " and SC1.C1_NUM     = SC8.C8_NUMSC" + CRLF 
            _cQry += " and SC1.C1_ITEM    = SC8.C8_ITEMSC" + CRLF 
            _cQry += " and SC1.D_E_L_E_T_ = ' '" + CRLF 
            _cQry += " join " + RetSqlName("SA2") + " SA2" + CRLF 
            _cQry += " on SA2.A2_FILIAL  = '" + xFilial("SA2") + "'" + CRLF 
            _cQry += " and SA2.A2_COD     = SC8.C8_FORNECE" + CRLF 
            _cQry += " and SA2.A2_LOJA    = SC8.C8_LOJA" + CRLF 
            _cQry += " and SA2.D_E_L_E_T_ = ' '" + CRLF 
            _cQry += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON C1_PRODUTO = B1_COD " + CRLF 
            _cQry += " AND SB1.D_E_L_E_T_ = '' " + CRLF 
            _cQry += " where SC8.C8_FILIAL  = '" + xFilial("SC8") + "'" + CRLF 
            _cQry += " and " + Iif( ValType(aSolicitac[i]) == 'C', "SC8.C8_NUM = '" + aSolicitac[i] + "'" , " SC8.C8_NUM = '" + aSolicitac[i][1] + "' ")+ CRLF 
            _cQry += " and SC8.D_E_L_E_T_ = ' '" + CRLF
            _cQry += " order by SC8.C8_FILIAL, SC8.C8_NUM, SC8.C8_FORNECE, SC8.C8_LOJA, SC8.C8_ITEM"
            
            if cUserName $ 'Administrador,ioliveira'
                MemoWrite("C:\totvs_relatorios\" +"MT131WF" + ".sql" , _cQry)
            endif

            DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(_cQry)), cAlias, .f., .f.)

            while !(cAlias)->(Eof())
                if (cAlias)->(C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA) != cChave

                    cMessage := iif(Val(SubStr(Time(),1,2))<12,"Bom dia!! <br>",iif(Val(SubStr(Time(),1,2))>18,"Boa Noite!! <br>","Boa Tarde!! <br>")) + CRLF 
                    cMessage += "<br>"  + CRLF
                    cMessage += "Segue em anexo, a solicitação de Orçamento! <br>" + CRLF
                    cMessage += "Por Gentileza informar Preço, Forma de Pagamento, Frete e Prazo de Entrega.<br>" + CRLF
                    cMessage += " <br>" + CRLF
                    if !Empty((cAlias)->MSGMAIL)
                        For x := 1 to len((cAlias)->MSGMAIL)
                            if AllTrim(SubStr((cAlias)->MSGMAIL,x,5)) != "."
                                cMessage += SubStr((cAlias)->MSGMAIL,x,1)
                            else
                                cMessage += ".<br>" + CRLF
                            endif
                            if AllTrim(SubStr((cAlias)->MSGMAIL,x,Len((cAlias)->MSGMAIL))) == ""
                                exit
                            endif
                        next x
                        cMessage += "<br>"  + CRLF
                    endif 
                    cMessage += "Desde já, agradeço.<br>" + CRLF
                    cMessage += "<br>" + CRLF
                    cMessage += "Atenciosamente,<br>" + CRLF
                    cMessage += "<br>" + CRLF
                    cMessage += ALLTRIM(SY1->Y1_NOME) + "<br>" + CRLF
                    cMessage += ALLTRIM(SY1->Y1_TEL) + "<br>" + CRLF
                    cMessage += ALLTRIM(SY1->Y1_EMAIL) + "<br>" + CRLF
                    cMessage += "<br>" + CRLF
                    cMessage += "www.vistaalegre.agr.br" + CRLF

                    if Empty(aDados)
                        while !(cAlias)->(Eof())
                            aAdd(aDados,{(cAlias)->C1_ITEM,;      //01
                                        (cAlias)->B1_DESC,;       //02
                                        (cAlias)->C8_FILENT,;     //03
                                        (cAlias)->C8_FORNECE,;    //04
                                        (cAlias)->A2_NOME,;       //05
                                        (cAlias)->C1_PRODUTO,;    //06
                                        (cAlias)->C1_UM,;         //07
                                        (cAlias)->C8_QUANT,;      //08
                                        (cAlias)->C1_EMISSAO,;    //09
                                        (cAlias)->C8_NUM,;        //10
                                        (cAlias)->C1_NUM,;        //11
                                        (cAlias)->A2_END,;        //12
                                        (cAlias)->A2_MUN,;        //13
                                        (cAlias)->A2_EST,;        //14
                                        (cAlias)->A2_TEL,;        //15
                                        (cAlias)->A2_FAX,;        //16
                                        (cAlias)->A2_CONTATO,;    //17
                                        (cAlias)->A2_CGC,;        //18
                                        (cAlias)->C8_PRAZO,;      //19
                                        (cAlias)->A2_EMAIL,;      //20
                                        (cAlias)->C8_FILIAL,;     //21
                                        (cAlias)->C8_LOJA,;       //22
                                        cTimeIni,;                //23
                                        (cAlias)->C8_NUMPRO,;     //24
                                        (cAlias)->MSGMAIL,;       //25
                                        (cAlias)->C8_ITEM,;       //26
                                        (cAlias)->C8_FORNOME,;    //27
                                        (cAlias)->C8_OBS})        //28
                                        //(cAlias)->C8_ITEMGRD})    //27})
                                    
                            (cAlias)->(DbSkip())
                        end
                        (cAlias)->(DBGoTop())
                    endif

                    lEnvia := .t.
                    cChave    := (cAlias)->(C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA)
                    aImprimir := {}
                    for j := 1 to len(aDados)
                        j:=1
                        if aDados[j] == nil 
                            exit
                        endif
                        if cChave == aDados[j][21]+aDados[j][10]+aDados[j][04]+aDados[j][22]
                            aAdd(aImprimir,{    aDados[j][01],;    //01
                                                aDados[j][02],;    //02
                                                aDados[j][03],;    //03
                                                aDados[j][04],;    //04
                                                aDados[j][05],;    //05
                                                aDados[j][06],;    //06
                                                aDados[j][07],;    //07
                                                aDados[j][08],;    //08
                                                aDados[j][09],;    //09
                                                aDados[j][10],;    //10
                                                aDados[j][11],;    //11
                                                aDados[j][12],;    //12
                                                aDados[j][13],;    //13
                                                aDados[j][14],;    //14
                                                aDados[j][15],;    //15
                                                aDados[j][16],;    //16
                                                aDados[j][17],;    //17
                                                aDados[j][18],;    //18
                                                aDados[j][19],;    //19
                                                aDados[j][20],;    //20
                                                aDados[j][21],;    //21
                                                aDados[j][22],;    //22
                                                aDados[j][23],;    //23
                                                aDados[j][24],;    //24
                                                aDados[j][25],;    //24
                                                aDados[j][26],;    //25
                                                aDados[j][27],;    //25
                                                aDados[j][28]})    //25
                            aDel(aDados,j)
                        else
                            exit
                        endif
                    next j
    
                    SC8->(DbGoTo((cAlias)->C8_RECNO))
                    SC1->(DbGoTo((cAlias)->C1_RECNO))
                    SA2->(DbGoTo((cAlias)->A2_RECNO))

                    if (cAlias)->C8_FORMAIL != SA2->A2_EMAIL
                        RecLock("SA2",.F.)
                            SA2->A2_EMAIL := (cAlias)->C8_FORMAIL
                        SA2->(MsUnlock())
                    endif

                    if Empty(SA2->A2_EMAIL)
                        if Empty((cAlias)->C8_FORMAIL)
                            ShowHelpDlg("WFPROC01", {"O e-mail do fornecedor não está preenchido."}, 1, {"Por favor, preencha o e-mail do fornecedor "+SA2->A2_COD+" e use a rotina de o reenvio da cotação em atualização de cotações."}, 1 )
                            lEnvia := .f.
                        else
                            RecLock("SA2",.F.)
                                SA2->A2_EMAIL := (cAlias)->C8_FORMAIL
                            SA2->(MsUnlock())
                        ENDIF
                    endif
                    
                    cForMail := (cAlias)->C8_FORMAIL
                    //cForMail := "igor.oliveira@vistaalegre.agr.br"

                    if lEnvia   

                        U_VACOMR10(aImprimir)
                        
                        aAdd(aArquivos,{ cChave,cForMail })

                        while cChave == (cAlias)->(C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA)
                            RecLock("SC1", .f.)
                                SC1->C1_CODCOMP := _cCODCOMP
                                SC1->C1_GRUPCOM := _cGRUPCOM
                            SC1->(MsunLock())
                            
                            RecLock('SC8', .f.)
                                SC8->C8_GRUPCOM := _cGRUPCOM
                                SC8->C8_CODCOMP := _cCODCOMP
                            SC8->(MsUnlock())
                            
                            (cAlias)->(DbSkip())
                            
                            SC8->(DbGoTo((cAlias)->C8_RECNO))
                            SC1->(DbGoTo((cAlias)->C1_RECNO))
                            SA2->(DbGoTo((cAlias)->A2_RECNO))
                        enddo 
                    else
                        (cAlias)->(DbSkip())
                        SC8->(DbGoTo((cAlias)->C8_RECNO))
                        SC1->(DbGoTo((cAlias)->C1_RECNO))
                        SA2->(DbGoTo((cAlias)->A2_RECNO))
                    endif
                endif
            end


            if lEnvia .and. !Empty(cChave)
                    cAliasA      := GetNextAlias() 

                    _cQry := " select SC8.C8_PRODUTO " + CRLF
                    _cQry += "  , SB1.B1_DESC " + CRLF
                    _cQry += "  , ISNULL(CAST(CAST(SC8.C8_OBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS C8_OBS  " + CRLF
                    _cQry += "  , SC8.C8_QUANT " + CRLF
                    _cQry += "  , SB1.B1_UM " + CRLF
                    _cQry += "  , SC8.C8_NUMSC" + CRLF
                    _cQry += "  from "+RetSqlName("SC8")+" SC8 " + CRLF
                    _cQry += "  LEFT JOIN "+RetSqlName("SB1")+" SB1 ON C8_PRODUTO = B1_COD  " + CRLF
                    _cQry += "  AND SB1.D_E_L_E_T_ = ''  " + CRLF
                    _cQry += "  where SC8.C8_FILIAL  = '" + FWxFilial("SC8") + "' " + CRLF
                    _cQry += "  and " + Iif( ValType(aSolicitac[i]) == 'C', "SC8.C8_NUM = '" + aSolicitac[i] + "'" , " SC8.C8_NUM = '" + aSolicitac[i][1] + "' ")+ CRLF 
                    _cQry += "  and SC8.D_E_L_E_T_ = ' ' " + CRLF
                    _cQry += "  GROUP BY SC8.C8_PRODUTO,SB1.B1_DESC,SC8.C8_OBS,SC8.C8_QUANT,SB1.B1_UM, SC8.C8_NUMSC " + CRLF
                    _cQry += "  order by SC8.C8_PRODUTO,SB1.B1_DESC,SC8.C8_OBS,SC8.C8_QUANT,SB1.B1_UM, SC8.C8_NUMSC " + CRLF

                    MpSysOpenQuery(_cQry,cAliasA)
                    aImprimir := {}
                    while !(cAliasA)->(EOF())
                        aAdd(aImprimir,{;
                                        (cAliasA)->C8_PRODUTO,;
                                        (cAliasA)->B1_DESC,;
                                        (cAliasA)->C8_OBS,;
                                        (cAliasA)->C8_QUANT,;
                                        (cAliasA)->B1_UM,;
                                        Iif( ValType(aSolicitac[i]) == 'C',aSolicitac[i],aSolicitac[i][1] ),;
                                        (cAliasA)->C8_NUMSC,;
                                        FWxFilial("SC8");
                                        })
                        (cAliasA)->(DbSkip())
                    enddo

                    (cAliasA)->(DbCloseArea())
                    
                    IF Len(aImprimir) > 0 
                        U_VACOMR14(aImprimir)
                    endif 
                    
                    (cAlias)->(DBGoTop())
                    SC8->(DbGoTo((cAlias)->C8_RECNO))

                    while !(cAlias)->(EOF())

                        RecLock('SC8', .f.)
                            SC8->C8_WFCO   := "1"
                            if Empty(SC8->C8_WFDT)
                                SC8->C8_WFDT   := dDataBase
                            endif
                            
                            SC8->C8_WFID    := cWFID
                            
                            if empty(SC8->C8_WFEMAIL)
                                if cUsername == "Administrador"
                                    SC8->C8_WFEMAIL :=  GetMV("MV_RELACNT")
                                else
                                    PswOrder(1)
                                    PswSeek(__cUserId)
                                    SC8->C8_WFEMAIL := Iif(Empty(ALLTRIM( Posicione("SY1",3,xFilial("SY1")+__cUserId,"Y1_EMAIL") )),;
                                                                    PswRet(1)[1][14],;
                                                                    AllTrim(Posicione("SY1",3,xFilial("SY1")+__cUserId,"Y1_EMAIL")))
                                endif
                            endif

                        SC8->(MsUnlock())
                            
                        (cAlias)->(DbSkip())

                        SC8->(DbGoTo((cAlias)->C8_RECNO))
                    ENDDO

                    if Type("oMainWnd") == 'U' .or. Aviso("Email","Deseja Enviar email de cotação para o Fornecedor? ",{"Sim","Não"}) == 1
                        for nI := 1 to len(aArquivos)
                            WFEnvCot(/* aAnexos,  */aArquivos[nI][1] + "_" + StrTran(cTimeIni,":","-",,),aArquivos[nI][2])
                        Next nI 
                    endif
                endif
        next i
    end transaction
    
    (cAlias)->(DbCloseArea())
    RestArea(aArea)
Return nil

Static Function WFEnvCot(/* aForm, */cChave,cForMail)

    cMessage := StrTran(cMessage, "{%NUMCOT%}", SubStr(cChave, TamSX3("C8_FILIAL")[1]+1,TamSX3("C8_NUM")[1]))
    u_EnvMail(cForMail/* "igor.oliveira@vistaalegre.agr.br" */,,, "Solicitação de proposta de cotação V@ " + SubStr(cChave, 1, TamSX3("C8_FILIAL")[1] + TamSX3("C8_NUM")[1]) + ".",;
            {cServPath + cChave + ".pdf"}, cMessage, /*_lAudit*/)

return nil
