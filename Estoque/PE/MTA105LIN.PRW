#INCLUDE "TOTVS.CH"

//    SCP 
//    SE  Posicionar NA CT1_CONTA usando B1_X_DEBIT, CT1_CCOBRG = 1 E CP_CC = EMPTY
//    Obrigatório Preenchimento do Campo Centro de Custos

//    Posicionar NA CT1_CONTA usando B1_X_DEBIT, CT1_ITOBRG E CP_ITEMCTA  = EMPTY
//    Obrigatório Preenchimento do Campo Item Contábil

//    Posicionar NA CT1_CONTA usando B1_X_DEBIT, CT1_CLOBRG E E CP_CLVL = EMPTY
//    Obrigatório Preenchimento do Campo Classe de Valor

User Function MTA105LIN()
    local lret      :=	.T.
	Local aArea     := GetArea()
    Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="CP_PRODUTO"})
    Local nCC       := aScan(aHeader,{|x| Trim(x[2])=="CP_CC"})
    Local nItemCta  := aScan(aHeader,{|x| Trim(x[2])=="CP_ITEMCTA"})
    Local nClVl     := aScan(aHeader,{|x| Trim(x[2])=="CP_CLVL"})

    DBSELECTAREA( "SB1" )
    SB1->(DBSETORDER( 1 )) //B1_FILIAL+B1_COD

    DBSELECTAREA( "SBM" )
    SBM->(DBSETORDER( 1 )) //B1_FILIAL+B1_COD

    IF SB1->(DBSEEK( FwxFilial("SB1")+aCols[n][nPProduto]))
        if  !(AllTrim(SB1->B1_GRUPO) $ GETMV("MV_GRPBLQ"))
            IF !EMPTY(SB1->B1_X_DEBIT)
                DBSELECTAREA( "CT1" )
                CT1->(DBSETORDER( 1 )) //CT1_FILIAL+CT1_CONTA

                IF CT1->(DBSEEK( FwxFilial("CT1")+SB1->B1_X_DEBIT))
                    IF CT1->CT1_CCOBRG == '1' .AND. EMPTY(aCols[n][nCC])
                        lRet := .F. 
                        Alert('OBRIGATÓRIO PREENCHIMENTO DO CAMPO CENTRO DE CUSTOS.')
                    ENDIF

                    IF lRet .and. CT1->CT1_ITOBRG == '1' .AND. EMPTY(aCols[n][nItemCta])
                        lRet := .F.
                        Alert('OBRIGATÓRIO PREENCHIMENTO DO CAMPO ITEM CONTÁBIL.')
                    ENDIF

                    IF lRet .and. CT1->CT1_CLOBRG == '1' .AND. EMPTY(aCols[n][nClVl])
                        lRet := .F. 
                        Alert('OBRIGATÓRIO PREENCHIMENTO DO CAMPO CLASSE DE VALOR')
                    ENDIF
                ENDIF
                
                CT1->(DBCLOSEAREA(  ))
            ELSE 
                lRet := .F.
                Alert('OBRIGATÓRIO PREENCHIMENTO DO CAMPO ITEM CONTÁBIL.')
            ENDIF 

            IF lRet 
                SBM->(DBSEEK( FwxFilial("SBM")+SB1->B1_GRUPO))
                
                cMsgPrd := ""
                cMsgGrp := ""

				if Alltrim(SB1->B1_CONTA) != Alltrim(SBM->BM_X_CONTA)
					cMsgPrd := 'Cta Contábil:'   + Alltrim(SB1->B1_CONTA) + CRLF
					cMsgGrp := 'Cta Contábil:'   + Alltrim(SBM->BM_X_CONTA)  +CRLF
				endif 
				if Alltrim(SB1->B1_X_DEBIT) != Alltrim(SBM->BM_X_DEBIT)
					cMsgPrd := 'Cta Deb Cons:'     + Alltrim(SB1->B1_X_DEBIT)  +CRLF
					cMsgGrp := 'Cta Deb Cons:'     + Alltrim(SBM->BM_X_DEBIT)  +CRLF
				endif 
				if Alltrim(SB1->B1_X_CRED)  != Alltrim(SBM->BM_X_CCREV)
					cMsgPrd := 'Conta Cred:'      + Alltrim(SB1->B1_X_CRED)   +CRLF
					cMsgGrp := 'Conta Cred:'      + Alltrim(SBM->BM_X_CCREV)   +CRLF
				endif 
				if Alltrim(SB1->B1_X_CUSTO)  != Alltrim(SBM->BM_X_CCUS)
					cMsgPrd := 'Cta Custo:'   + Alltrim(SB1->B1_X_CUSTO)
					cMsgGrp := 'Cta Custo:'   + Alltrim(SBM->BM_X_CCUS)
				endif

                if cMsgPrd != ""
                    lRet := .F.

                    MsgAlert('Produto: ' + AllTrim(SB1->B1_COD) + '- ' + AllTrim(SB1->B1_DESC) +CRLF +;
                            CRLF +;
                            CRLF +;
                            'Cadastro de Produtos:' +CRLF +;
                            '-----------------------------------------------' +CRLF +;
                            cMsgPrd +;
                            CRLF +;
                            CRLF +;
                            'Cadastro de Grupos:' +CRLF +;
                            '-----------------------------------------------' +CRLF +;
                            cMsgGrp+;
                            CRLF +;
                            CRLF +;
                            "CORRIGIR CADASTRO DE PRODUTO OU GRUPO ANTES DE PROSSEGUIR";
                            ,"Campos divergentes Produto x Grupo")
                endif

            ENDIF 
        ENDIF 
    ENDIF 
    
    SBM->(DBCLOSEAREA(  ))
    SB1->(DBCLOSEAREA(  ))

	RestArea(aArea)
Return lRet 


