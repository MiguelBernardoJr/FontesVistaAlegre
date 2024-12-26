#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

/* Igor Oliveira
    MATA150 
    Descrição:
    LOCALIZAÇÃO : Function A150Grava() - Responsável por efetuar a atualização das cotações de compra. APOS GRAVACAO DO SC8

    EM QUE PONTO : Apos a atualizacao do SC8 (Cotacoes)
    
 */
User Function MT150END()
    Local aArea     := GetArea()
    Local aDados    := {}
    Private nSeq 
    
    DbSelectArea("SA2")
    DbSetOrder(1)

    IF PARAMIXB[1] == 3
        if SA2->(DBSeek(FWxFilial("SA2")+SC8->C8_FORNECE+SC8->C8_LOJA))
            IF SA2->A2_EMAIL != SC8->C8_FORMAIL
                RecLock("SA2", .f. )
                    SA2->A2_EMAIL := SC8->C8_FORMAIL
                MsUnlock()
            EndIf
        EndIf
    elseif PARAMIXB[1] == 2
        if SA2->(DBSeek(FWxFilial("SA2")+SC8->C8_FORNECE+SC8->C8_LOJA))
            IF SA2->A2_EMAIL != SC8->C8_FORMAIL
                RecLock("SA2", .f. )
                    SA2->A2_EMAIL := SC8->C8_FORMAIL
                MsUnlock()
            EndIf
        EndIf

        aDados := fGetD1()
        if Len(aDados) > 0
            U_VACOMR10(aDados) // envia para o fornecedor
        ENDIF

        aDados := fGetD2()
        if Len(aDados) > 0
            U_VACOMR14(aDados) // NAO envia para o fornecedor
        ENDIF

    ENDIF
    RestArea(aArea)
RETURN 

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

Static Function fGetD1()
    Local aArea     := GetArea()
    Local aDados    := {}
    Local _cQry     := ''
    Local cTime150  := Time()
    Local cAlias    := GetNextAlias()

    _cQry := " select C8_FILENT,C8_ITEM, " + CRLF 
    _cQry += " 		C8_FORNECE, " + CRLF 
    _cQry += " 		C8_LOJA, " + CRLF 
    _cQry += " 		C8_UM, " + CRLF 
    _cQry += " 		C8_PRODUTO, " + CRLF 
    _cQry += " 		C8_QUANT,  " + CRLF 
    _cQry += " 		C8_FILIAL,  " + CRLF 
    _cQry += " 	    C8_EMISSAO, " + CRLF 
    _cQry += " 		C8_NUM, " + CRLF 
    _cQry += " 		C8_NUMSC, " + CRLF 
    _cQry += " 		C8_DATPRF, " + CRLF 
    _cQry += " 		C8_NUMPRO, " + CRLF
    _cQry += " 		C8_ITEMGRD, " + CRLF
    _cQry += " 		C8_FORNOME, " + CRLF
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
    _cQry += " 		A2_COD_MUN, " + CRLF 
    _cQry += " 		A2_CONTATO, " + CRLF 
    _cQry += " 		B1_DESC, " + CRLF 
    _cQry += " 		C1_CODCOMP, " + CRLF
    _cQry += "      C1_ITEM," + CRLF
    _cQry += "      C1_NUM," + CRLF
    _cQry += "      C1_DATPRF," + CRLF
    _cQry += "      C1_EMISSAO," + CRLF
    _cQry += "      C1_UM," + CRLF
    _cQry += "      C1_DESCRI," + CRLF
    _cQry += "      C1_PRODUTO," + CRLF
    _cQry += "      C1_QUANT," + CRLF
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
    
    if lower(cUserName) $ 'mbernardo,ioliveira,Administrador,atoshio'
        MemoWrite("C:\totvs_relatorios\" +"MT150GRV" + ".sql" , _cQry)
    endif 
    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),cAlias,.F.,.F.)

    While !(cAlias)->(Eof())
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
                    (cAlias)->C1_DATPRF,;     //19
                    (cAlias)->A2_EMAIL,;      //20
                    (cAlias)->C8_FILIAL,;     //21
                    (cAlias)->C8_LOJA,;       //22
                    cTime150,;                //23
                    (cAlias)->C8_NUMPRO,;     //24
                    (cAlias)->MSGMAIL,;
                    (cAlias)->C8_ITEM,;      //26
                    (cAlias)->C8_FORNOME,;   //27
                    (cAlias)->C8_OBS})       //28
                    //(cAlias)->C8_ITEMGRD})   //27})       //25
                    
        (cAlias)->(dbSkip())
    enddo
    (cAlias)->(dbCloseArea())
    RestArea(aArea)
Return aDados 
