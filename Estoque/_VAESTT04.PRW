
#include "Protheus.ch"
#include "TopConn.ch"

/*/{Protheus.doc} VAESTT04
FunÁ„o para percorrer a ZCQ - ConfiguraÁ„o de QUebras e executar movimentaÁıes em estoque - Via Schedulle referente a quebras de estoque.

@type function
@version  
@author Arthur Toshio Oda Vamzella
@since 20/09/2022
@return variant, return_description
/*/
User Function VAESTT04()  // U_VAESTT04()
Local _cQry      := ""
Local cTM        := "518"//GetMV("VA_CTMBX",,"518") // CÛdigo de TM utulizada nas movimentaÁıes de baixa de estoque
Local cObs :=    "BAIXA REF. QUEBRA TECNICA DE ESTOQUE "
Local nQtMov     := 0
Local cCC        := ""
Local cItemCta   := ""
Local cClvlr     := ""
//Local aArea   := {}
Local _cAlias   := CriaTrab(,.F.)   

    _cQry += "SELECT ZCQ_FILIAL, ZCQ_DATA, ZCQ_PROD, ZCQ_LOCAL, ZCQ_NUM, ZCQ_ORIGEM, ZCQ_TIPO  " + CRLF
    _cQry += "	   , ISNULL((SELECT SUM(CASE WHEN Z0Y_PESDIG > 0 THEN Z0Y_PESDIG ELSE Z0Y_QTDREA END) FROM "+RetSqlName("Z0Y")+" Z0Y WHERE Z0Y_FILIAL = ZCQ_FILIAL AND Z0Y_COMP = ZCQ_PROD AND Z0Y_DATA = '"+DtoS(dDataBase)+"' AND Z0Y.D_E_L_E_T_ = ' ' ),0)  CONSUMO" + CRLF
    _cQry += "	   , ISNULL((SELECT B2_QATU FROM "+RetSqlName("SB2")+" SB2 WHERE B2_FILIAL = ZCQ_FILIAL AND ZCQ_PROD = B2_COD AND ZCQ_LOCAL = B2_LOCAL AND SB2.D_E_L_E_T_ = ' ' ),0) SALDO " + CRLF
    _cQry += "  FROM "+RetSqlName("ZCQ")+" ZCQ " + CRLF
    _cQry += " WHERE ZCQ.ZCQ_DATA <= '"+DtoS(dDataBase)+"'  " + CRLF
    _cQry += "   AND ZCQ.ZCQ_DATA = (SELECT MAX (ZCQ_DATA) FROM "+RetSqlName("ZCQ")+" ZCQD WHERE ZCQ.ZCQ_FILIAL = ZCQD.ZCQ_FILIAL AND ZCQ.ZCQ_PROD = ZCQD.ZCQ_PROD AND ZCQ.ZCQ_LOCAL = ZCQD.ZCQ_LOCAL AND ZCQD.D_E_L_E_T_ = ' ' ) " + CRLF

/*
    _cQry += "SELECT ZCQ_FILIAL, ZCQ_DATA, ZCQ_PROD, ZCQ_LOCAL, ZCQ_NUM, ZCQ_ORIGEM, ZCQ_TIPO  " + CRLF
    _cQry += "	 , CASE WHEN ZCQ_ORIGEM = 'T' AND ZCQ_TIPO = 'P'  " + CRLF
    _cQry += "                 --THEN ISNULL((SELECT SUM(D3_QUANT) FROM "+RetSqlName("SD3")+" SD3 WHERE D3_FILIAL = ZCQ_FILIAL AND D3_COD = ZCQ_PROD AND D3_LOCAL = ZCQ_LOCAL AND SD3.D_E_L_E_T_ =' ' AND SD3.D3_OP <> ' ' AND SD3.D3_EMISSAO = '"+DtoS(dDataBase)+"' AND D3_OP IN (SELECT D3.D3_OP FROM "+RetSqlName("SD3")+" D3 WHERE D3.D3_FILIAL = SD3.D3_FILIAL AND SD3.D3_OP = D3.D3_OP AND D3.D_E_L_E_T_ =' ' AND D3_TM = '001')),0) * (ZCQ_NUM / 100) " + CRLF
    _cQry += "				 THEN ISNULL((SELECT SUM(CASE WHEN Z0Y_PESDIG > 0 THEN Z0Y_PESDIG ELSE Z0Y_QTDREA END) FROM "+RetSqlName("Z0Y")+" Z0Y WHERE Z0Y_FILIAL = ZCQ_FILIAL AND Z0Y_COMP = ZCQ_PROD AND Z0Y_DATA = '"+DtoS(dDataBase)+"' AND Z0Y.D_E_L_E_T_ = ' ' ),0)  " + CRLF
    _cQry += " 			  WHEN ZCQ_ORIGEM IN ('T','S') AND ZCQ_TIPO = 'K' " + CRLF
    _cQry += "			     THEN ZCQ_NUM " + CRLF
    _cQry += "			  WHEN ZCQ_ORIGEM = 'S' AND ZCQ_TIPO = 'P' " + CRLF
    _cQry += "			     THEN ISNULL((SELECT B2_QATU FROM "+RetSqlName("SB2")+" SB2 WHERE SB2.B2_FILIAL = ZCQ.ZCQ_FILIAL AND SB2.B2_COD = ZCQ.ZCQ_PROD AND SB2.B2_LOCAL = ZCQ.ZCQ_LOCAL AND SB2.D_E_L_E_T_ = ' ' ),0)  " + CRLF
    _cQry += "			  ELSE 0 END AJUSTE " + CRLF
    _cQry += "	   , ISNULL((SELECT B2_QATU FROM "+RetSqlName("SB2")+" SB2 WHERE B2_FILIAL = ZCQ_FILIAL AND ZCQ_PROD = B2_COD AND ZCQ_LOCAL = B2_LOCAL AND SB2.D_E_L_E_T_ = ' ' ),0) SALDO " + CRLF
    _cQry += "  FROM "+RetSqlName("ZCQ")+" ZCQ " + CRLF
    _cQry += " WHERE ZCQ.ZCQ_DATA <= '"+DtoS(dDataBase)+"'  " + CRLF
    _cQry += "   AND ZCQ.ZCQ_DATA = (SELECT MAX (ZCQ_DATA) FROM ZCQ010 ZCQD WHERE ZCQ.ZCQ_FILIAL = ZCQD.ZCQ_FILIAL AND ZCQ.ZCQ_PROD = ZCQD.ZCQ_PROD AND ZCQ.ZCQ_LOCAL = ZCQD.ZCQ_LOCAL AND ZCQD.D_E_L_E_T_ = ' ' ) " + CRLF
*/
    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 	 


    while !((_cAlias)->(EoF()))
        
        DbSelectArea("ZLQ")
        DbSetOrder(1) // 
        //MsgInfo("FILIAL: "+(_cAlias)->ZCQ_FILIAL+ " DATA: "+DToC(SToD((_cAlias)->ZCQ_DATA))+ " PRODUTO : " +(_cAlias)->ZCQ_PROD, "TESTE ")
        nQtMov :=0

        If (_cAlias)->ZCQ_ORIGEM == 'T' .and. (_cAlias)->ZCQ_TIPO = 'P'
            nQtMov := (_cAlias)->CONSUMO * ((_cAlias)->ZCQ_NUM / 100) 
        ElseIf (_cAlias)->ZCQ_ORIGEM == 'S' .and. (_cAlias)->ZCQ_TIPO = 'P'
            nQtMov  := (_cAlias)->SALDO * ((_cAlias)->ZCQ_NUM / 100) 
        ElseIf (_cAlias)->ZCQ_TIPO = 'K'
            nQtMov  := (_cAlias)->ZCQ_NUM
        EndIf


        nSaldo := (aEstAux := Calcest( (_cAlias)->ZCQ_PROD, (_cAlias)->ZCQ_LOCAL, dDataBase ))[1]
        //nQuant := (aAuxPrd := CalcEstL( (cAliaQTD)->B1_COD, (cAliaQTD)->B2_LOCAL, MV_PAR01+1, (cAliaQTD)->B8_LOTECTL))[1]
        If nSaldo > nQtMov .AND. nSaldo > 0
            Begin Transaction

                Reclock("ZLQ",.T.)
                    ZLQ->ZLQ_FILIAL  := (_cAlias)->ZCQ_FILIAL
                    ZLQ->ZLQ_DATA    := dDataBase
                    ZLQ->ZLQ_PRODUT  := (_cAlias)->ZCQ_PROD
                    ZLQ->ZLQ_LOCAL   := (_cAlias)->ZCQ_LOCAL
                    ZLQ->ZLQ_QBASE   := (_cAlias)->CONSUMO  
                    ZLQ->ZLQ_ORIGEM  := (_cAlias)->ZCQ_ORIGEM
                    ZLQ->ZLQ_TIPO    := (_cAlias)->ZCQ_TIPO
                    ZLQ->ZLQ_NUMBS   := (_cAlias)->ZCQ_NUM
                    ZLQ->ZLQ_QTMOV   := nQtMov
                    ZLQ->ZLQ_MOVEFE  := IF((_cAlias)->SALDO > 0,"S","N")

                ZLQ->(MsUnlock())
                If((_cAlias)->SALDO > 0 .and. nQtMov > 0 )            
                    // Fazer MovimentaÁ„o na SD3.
                    U_LanClassif( FwXFilial("ZCQ"), "E", cTM, (_cAlias)->ZCQ_PROD, (_cAlias)->ZCQ_LOCAL, nQtMov, 0.01, dDataBase, cObs, cCC, cItemCta, cClvlr )
                EndIf
            End Transaction 
        EndIf
        (_cAlias)->(DbSkip())
    end
    
    (_cAlias)->(DBCloseArea())
Return Nil


/****************************************************************
Funùùo para lanùamento de movimento interno automatico
****************************************************************/
/*
cTFil		-> D3_FILIAL (Filial) 
cTipo		-> Tipo (E-Entrada, S-Saida) 
cTTM		-> D3_TM (Tipo de Movimentacao) 
cTProd		-> D3_COD (Produto) 
cTLocal		-> D3_LOCAL (Armazem/Local)
nTQtd 		-> D3_QUANT (Quantidade)
nTCusto		-> D3_CUSTO1 (Custo da moeda 1)	
dTData		-> D3_EMISSAO (Data Emissao)
cTObs		-> D3_X_OBS (Observacao)
cTCC		-> D3_CC (Centro de Custo)
cTItemCta	-> D3_ITEMCTA (Item Contabil) 
cTCLVL		-> D3_CLVL (Classe Valor)
*/
User Function LanClassif(cTFil, cTipo, cTTM, cTProd, cTLocal, nTQtd,;
						   nTCusto, dTData, cTObs, cTCC, cTItemCta, cTCLVL,;
						   RECNOSD3 )
Local aMovimento  	:= {}
Private lMsErroAuto := .F.

//Analisa os tipos e monta os dois arrays (Entrada e Saùda)
//	If (cTipo == "E") // Entrada
  	 aMovimento := {{"D3_FILIAL"	, (_cAlias)->ZCQ_FILIAL	, NIL},; 
	   				{"D3_TM"		, cTTM				, NIL},;
	   			    {"D3_COD"		, cTProd			, NIL},; 
					{"D3_LOCAL"		, cTLocal           , NIL},; 
					{"D3_EMISSAO"	, dTData          	, NIL},;
					{"D3_X_QTD"		, nTQtd      		, NIL},;
					{"D3_QUANT"		, nTQtd      		, NIL},;
					{"D3_CUSTO1"	, nTCusto      		, NIL},;
					{"D3_X_OBS"    	, cTObs			    , NIL},;
					{"D3_CC"    	, cTCC			    , NIL},;
					{"D3_ITEMCTA"   , cTItemCta			, NIL},;
					{"D3_CLVL"    	, cTCLVL            , NIL} }
					// Inclui D3_OBSERVA - SE FOR MOR MOVIMENTAùùO PREENCHER COM NUMERO DA NF, SERIE E DATA DE EMISSAO
//	Endif
	                                   	
	// Gerar Movimento Interno 
	If (cTipo == "E") // Entrada				
		MSExecAuto({|x,y| mata240(x,y)}, aMovimento,3)

	ElseIf cTipo == "X" // Exclusùo
		MSExecAuto({|x,y| mata240(x,y)}, aMovimento, 5)				
		
	EndIf

	If lMsErroAuto
		MostraErro()
	Endif
		
Return !lMsErroAuto

