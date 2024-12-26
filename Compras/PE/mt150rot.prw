#include 'protheus.ch'
#include 'parmtype.ch'

user function mt150rot()
local aRotina := ParamIXB	

AAdd(aRotina, { "Relatório de Cotação", "u_SendWF", 0 , 4, 0, .f.})
AAdd(aRotina, { "Exporta Excel", "u_vacomr05", 0 , 4, 0, .f.})

return aRotina

user function SendWF(cAlias, nReg, nOpc)
    local lEnvia        := .t.
    Private cTimeIni    := Time()
    
    if !Empty(SC8->C8_WFDT)
        lEnvia := (Aviso("Workflow de cotação", "Já foi enviado o workflow de solicitação de cotação para o fornecedor. Deseja reenviar?", {"Sim", "Não"}) == 1)
    endif

    if lEnvia
        aDados := fGetDados()
        U_VACOMR10(aDados)
        //U_MT131WF({{SC8->C8_NUM, SC8->C8_FORNECE+SC8->C8_LOJA, }})

        aDados := fGetD2()
        if Len(aDados) > 0
            U_VACOMR14(aDados) // NAO envia para o fornecedor
        ENDIF
    endif

return nil

Static Function fGetD2()
    Local cAliasA       := GetNextAlias() 
    Local _cQry
    LOcal aDados     := {}

    _cQry := " select SC8.C8_PRODUTO " + CRLF
    _cQry += "  , SB1.B1_DESC " + CRLF
    _cQry += "  , ISNULL(CAST(CAST(SC8.C8_OBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS C8_OBS  " + CRLF
    _cQry += "  , SC8.C8_QUANT " + CRLF
    _cQry += "  , SB1.B1_UM " + CRLF
    _cQry += "  from "+RetSqlName("SC8")+" SC8 " + CRLF
    _cQry += "  LEFT JOIN "+RetSqlName("SB1")+" SB1 ON C8_PRODUTO = B1_COD  " + CRLF
    _cQry += "  AND SB1.D_E_L_E_T_ = ''  " + CRLF
    _cQry += "  WHERE C8_FILIAL = '"+FWxFilial("SC8")+"' " + CRLF 
    _cQry += "  AND C8_NUM = '"+SC8->C8_NUM+"' " + CRLF 
    _cQry += "  AND C8_FORNECE+C8_LOJA = '"+(SC8->C8_FORNECE+SC8->C8_LOJA)+"' " + CRLF 
    _cQry += "  AND C8_NUMPRO = '"+SC8->C8_NUMPRO+"' " + CRLF 
    _cQry += "  AND SC8.D_E_L_E_T_ = '' "   + CRLF
    _cQry += "  GROUP BY SC8.C8_PRODUTO,SB1.B1_DESC,SC8.C8_OBS,SC8.C8_QUANT,SB1.B1_UM " + CRLF
    _cQry += "  order by SC8.C8_PRODUTO,SB1.B1_DESC,SC8.C8_OBS,SC8.C8_QUANT,SB1.B1_UM " + CRLF

    MpSysOpenQuery(_cQry,cAliasA)
    aDados := {}
    while !(cAliasA)->(EOF())
        aAdd(aDados,{;
                        (cAliasA)->C8_PRODUTO,;
                        (cAliasA)->B1_DESC,;
                        (cAliasA)->C8_OBS,;
                        (cAliasA)->C8_QUANT,;
                        (cAliasA)->B1_UM,;
                        SC8->C8_NUMSC,;
                        SC8->C8_NUMSC,;
                        FWxFilial("SC8");
                        })
        (cAliasA)->(DbSkip())
    enddo

    (cAliasA)->(DbCloseArea())
                        
Return aDados
Static Function fGetDados()
    Local aArea     := GetArea()
    Local aDados    := {}
    Local _cQry     := ''

    _cQry := " select C8_FILENT,C8_ITEM, " + CRLF 
    _cQry += " 		C8_FILIAL, " + CRLF 
    _cQry += " 		C8_FORNECE, " + CRLF 
    _cQry += " 		C8_LOJA, " + CRLF 
    _cQry += " 		C8_UM, " + CRLF 
    _cQry += " 		C8_PRODUTO, " + CRLF 
    _cQry += " 		C8_NUMPRO, " + CRLF 
    _cQry += " 		C8_QUANT,  " + CRLF 
    _cQry += " 		C8_NUM, " + CRLF 
    _cQry += " 		C8_NUMSC, " + CRLF 
    _cQry += " 		C8_FORNOME, " + CRLF 
    _cQry += " 		C8_PRAZO, " + CRLF 
    _cQry += " 		ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), C8_MSGMAIL)),'') AS MSGMAIL , " + CRLF 
    _cQry += " 		C8_WFEMAIL, " + CRLF 
    _cQry += " 		A2_NOME, " + CRLF 
    _cQry += " 		A2_END, " + CRLF
    _cQry += " 		A2_EST, " + CRLF 
    _cQry += " 		A2_TEL, " + CRLF
    _cQry += " 		A2_FAX, " + CRLF
    _cQry += " 		A2_EMAIL, " + CRLF 
    _cQry += " 		A2_MUN, " + CRLF 
    _cQry += " 		A2_CGC, " + CRLF 
    _cQry += " 		A2_CONTATO, " + CRLF 
    _cQry += " 		B1_DESC, " + CRLF 
    _cQry += " 		C1_CODCOMP, " + CRLF 
    _cQry += " 		C1_EMISSAO, " + CRLF 
    _cQry += " 		C1_NUM, " + CRLF 
    _cQry += " 		Y1_EMAIL, " + CRLF 
    _cQry += " 		ISNULL(CAST(CAST(C8_OBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS C8_OBS " + CRLF 
    _cQry += " from "+RetSqlName("SC8")+" C8 " + CRLF 
    _cQry += " LEFT JOIN "+RetSqlName("SB1")+" B1 ON C8_PRODUTO = B1_COD " + CRLF 
    _cQry += " AND B1.D_E_L_E_T_ = '' " + CRLF 
    _cQry += " LEFT JOIN "+RetSqlName("SA2")+" A2 ON C8_FORNECE = A2_COD " + CRLF
    _cQry += " AND C8_LOJA = A2_LOJA" + CRLF 
    _cQry += " AND A2.D_E_L_E_T_ = ''" + CRLF 
    _cQry += " LEFT JOIN "+RetSqlName("SC1")+" C1 ON C8_FILIAL = C1_FILIAL  " + CRLF 
    _cQry += " AND C8_NUMSC = C1_NUM  " + CRLF
    _cQry += " AND C8_ITEMSC = C1_ITEM " + CRLF
    _cQry += " AND C8_PRODUTO = C1_PRODUTO " + CRLF
    _cQry += " AND C1.D_E_L_E_T_ = ''" + CRLF 
    _cQry += " LEFT join "+RetSqlName("SY1")+" Y1 ON Y1_COD = C1_CODCOMP " + CRLF 
    _cQry += " AND Y1.D_E_L_E_T_ = ''" + CRLF 
    _cQry += " WHERE C8_FILIAL = '"+FWxFilial("SC8")+"' " + CRLF 
    _cQry += " AND C8_NUM = '"+SC8->C8_NUM+"' " + CRLF 
    _cQry += " AND C8_FORNECE+C8_LOJA = '"+(SC8->C8_FORNECE+SC8->C8_LOJA)+"' " + CRLF 
    _cQry += " AND C8_NUMPRO = '"+SC8->C8_NUMPRO+"' " + CRLF 
    _cQry += " AND C8.D_E_L_E_T_ = '' "   + CRLF
    _cQry += " ORDER BY C8_FILIAL, C8_NUM, C8_FORNECE, C8_LOJA,C8_ITEM"   + CRLF
    
    MemoWrite("C:\totvs_relatorios\" +"MT150WF" + ".sql" , _cQry)
    
    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)

    While !TEMPSQL->(Eof())
        aAdd(aDados,{TEMPSQL->C8_ITEM,;     //01    
                    TEMPSQL->B1_DESC,;      //02
                    TEMPSQL->C8_FILENT,;    //03
                    TEMPSQL->C8_FORNECE,;   //04
                    TEMPSQL->A2_NOME,;      //05
                    TEMPSQL->C8_PRODUTO,;   //06
                    TEMPSQL->C8_UM,;        //07
                    TEMPSQL->C8_QUANT,;     //08
                    TEMPSQL->C1_EMISSAO,;   //09
                    TEMPSQL->C8_NUM,;       //10
                    TEMPSQL->C1_NUM,;       //11
                    TEMPSQL->A2_END,;       //12
                    TEMPSQL->A2_MUN,;       //13
                    TEMPSQL->A2_EST,;       //14
                    TEMPSQL->A2_TEL,;       //15
                    TEMPSQL->A2_FAX,;       //16
                    TEMPSQL->A2_CONTATO,;   //17
                    TEMPSQL->A2_CGC,;       //18
                    TEMPSQL->C8_PRAZO,;     //19
                    TEMPSQL->A2_EMAIL,;     //20
                    TEMPSQL->C8_FILIAL,;    //21
                    TEMPSQL->C8_LOJA,;      //22
                    cTimeIni,;              //23
                    TEMPSQL->C8_NUMPRO,;    //24
                    TEMPSQL->MSGMAIL,;      //25
                    TEMPSQL->C8_ITEM,;      //26
                    TEMPSQL->C8_FORNOME,;   //27
                    TEMPSQL->C8_OBS})       //28    
        TEMPSQL->(dbSkip())
    enddo
    TEMPSQL->(dbCloseArea())
    RestArea(aArea)
Return aDados 
