#include 'TOTVS.CH'
#include 'fileio.ch'
#include 'RWMAKE.CH'
#include 'protheus.ch'
#include 'parmtype.ch'

static oCellHorAlign    := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign   := FwXlsxCellAlignment():Vertical()
static cTitulo          := "Relatório - Compra de Gado"

/*---------------------------------------------------------------------------------,
 | Analista : Igor Gomes Oliveira                                                  |
 | Data		: 11.10.2021                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatório de Compra de Gado                                          |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_VAESTIG1()                                                         |
 '---------------------------------------------------------------------------------*/
 USER FUNCTION VAESTIG1()
    Local cTimeINi  := Time()
    Local cStyle    := ""
    Local cXML      := ""
    Private cPath       := "C:\TOTVS_RELATORIOS\"
    Private cPerg       := "VAESTIG1"
    Private cArquivo    := cPath + cPerg +;
                                    DToS(dDataBase)+;//converte a data para aaaammdd
                                    "_"+;
                                    StrTran(Subs(Time(),1,5),":","")+;
                                    ".xml"
    Private oExcel      := nil
    Private _cAliasG    := GetNextAlias()

    Private nHandle     := 0
    Private nHandAux    := 0
    Private lTemDados   := .F. 

    Private JFontHeader
    Private JFontTitulo
    Private JFontText
    Private JFLeft
    Private JFRight
    Private JFCenter
    Private JFData
    Private jFormatTit
    Private jFormatGD
    Private jFormatTot
    Private jFormatHead
    Private jFM4d
    Private jFMoeda
    Private jFPercent
    Private jFNum
    Private jBorder
    Private jNoBorder
    Private jBHeaderLeft
    Private jBHeaderRight
    Private jBottomLeft
    Private jBorderCenter
    Private jBorderRight

    DefinirFormatacao()
    GeraX1(cPerg)

    IF Pergunte(cPerg, .T.)
        U_PrintSX1(cPerg)

        IF Len(Directory(cPath + "*.*","D")) == 0
            IF Makedir(cPath) == 0 
                ConOut('Diretório criado com sucesso.')
                MsgAlert('Diretorio criado com sucesso: ', + cPath, 'Aviso')
            ELSE
                ConOut("Não foi possivel criar o diretório. Erro: " + CValToChar(FError()))
                MsgAlert('Não foi possível criar o diretório. Erro', CValToChar(FError()),'Aviso')
            ENDIF
        ENDIF

        // Processar SQL
        FWMsgRun(, {|| lTemDados := fLoadSql("Geral", @_cAliasG ) },;
                        'Por Favor Aguarde...',;
                        'Processando Banco de Dados - Recebimento')
        IF lTemDados
            oExcel := FwPrinterXlsx():New()
            oExcel:Activate(cArquivo)

            // Gerar primeira planilha
            FWMsgRun(, {|| fQuadro1() }, 'Gerando excel, Por favor, aguarde...')
            
            lRet := oExcel:toXlsx()

            nRet := ShellExecute("open", SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx", "", "", 1)

            oExcel:EraseBaseFile()

            //Se houver algum erro
            If nRet <= 32
                MsgStop("Não foi possível abrir o arquivo "+SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx"+ "!", "Atenção")
            EndIf 
            
            oExcel:DeActivate()

            IF oExcel <> NIL
                oExcel := Nil
            ENDIF
        ELSE
            MsgAlert("Os parametros informados não retornaram nenhuma informação do banco de dados." + CRLF + ;
            "Por isso o excel não será aberto automaticamente.", "Dados não localizados")
        ENDIF

        (_cAliasG)->(DbCloseArea())

        IF Lower(cUserName) $ 'ioliveira'
            Alert('Tempo de processamento: ' + ElapTime(cTimeINi, Time()))
        ENDIF

        ConOut('Activate: ' + Time())
    ENDIF
RETURN NIL

STATIC FUNCTION GeraX1(cPerg)
    Local _aArea	:= GetArea()
    Local aRegs     := {}
    Local nX		:= 0
    Local nPergs	:= 0

    Local i
    Local j

    //Conta quantas perguntas existem atualmente.
    DbSelectArea('SX1')
    DbSetOrder(1)
    SX1->(DbGoTop())
    IF SX1->(DbSeek(cPerg))
        WHILE !SX1->(Eof()) .And. X1_GRUPO = cPerg
            nPergs++
            SX1->(DbSkip())
        ENDDO
    ENDIF
	
    AADD(aRegs,{cPerg,"01","Data de            ?",Space(20),Space(20),"mv_ch1", 'D'                    ,08                      ,0                       ,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Data ate           ?",Space(20),Space(20),"mv_ch2", 'D'                    ,08                      ,0                       ,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Codigo de          ?",Space(20),Space(20),"mv_ch3", TamSX3("ZCC_CODIGO")[3], TamSX3("ZCC_CODIGO")[1], TamSX3("ZCC_CODIGO")[2],0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Codigo ate         ?",Space(20),Space(20),"mv_ch4", TamSX3("ZCC_CODIGO")[3], TamSX3("ZCC_CODIGO")[1], TamSX3("ZCC_CODIGO")[2],0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"05","Boi Gordo          ?",Space(20),Space(20),"mv_ch5", TamSX3("ZCC_GORDO")[3] , TamSX3("ZCC_GORDO")[1] , TamSX3("ZCC_GORDO")[2] ,0,"C","","mv_par05","Sim","Sim","Sim","","Não","Não","Não","","Ambos","Ambos","Ambos","Ambos","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"06","Quebra de peso:     ",Space(20),Space(20),"mv_ch6", "N"                    , 3                      , 0                      ,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

//Se quantidade de perguntas for diferente, apago todas
    SX1 -> (DbGoTop())
    IF nPergs <> Len(aRegs)
        FOR nX := 1 to nPergs
            IF  SX1 -> (DbSeek(cPerg))
                IF  RecLock('SX1', .F.)
                    SX1 -> (DbDelete())
                    SX1 -> (MsUnlock())
                ENDIF               
            ENDIF
        NEXT nX
    ENDIF

// gravação das perguntas na tabela SX1
    IF nPergs <> Len(aRegs)
        DbSelectArea("SX1")
        DbSetOrder(1)
        FOR i := 1 to Len(aRegs)
            IF !DbSeek(cPerg+aRegs[i,2])
                RecLock("SX1", .T.)
                    FOR j := 1 to FCOUNT()
                        IF j <= Len(aRegs[i])
                            FieldPut(j,aRegs[i,j])
                        ENDIF
                    NEXT j
                MsUnlock()
            ENDIF
        NEXT i 
    ENDIF

    RestArea(_aArea)
RETURN NIL
// FIM: GeraX1

STATIC FUNCTION fLoadSQL(cTipo, _cAlias)
    Local _cQry     := ""

    IF cTipo == "Geral"
        _cQry   := " WITH PRINCIPAL AS ( " + CRLF
        _cQry   += "    SELECT  ZBC.ZBC_FILIAL  FILIAL" + CRLF
        _cQry   += "            ,ZBC.ZBC_CODIGO     CODIGO" + CRLF
        _cQry   += "            ,ZBC.ZBC_VERSAO     VERSAO" + CRLF
		_cQry   += "            ,ZBC.ZBC_CODFOR     COD_FORN" + CRLF
		_cQry   += "            ,ZBC.ZBC_LOJFOR     LOJ_FORN" + CRLF
		_cQry   += "            ,ZCC.ZCC_NOMFOR     FORNECEDOR " + CRLF
		_cQry   += "            ,SA2.A2_MUN         MUNICIPIO" + CRLF
		_cQry   += "            ,SA2.A2_EST         ESTADO" + CRLF
		_cQry   += "            ,ZBC.ZBC_PRODUT     PRODUTO" + CRLF
		_cQry   += "            ,ZBC_PRDDES         DESCRICAO" + CRLF
		_cQry   += "            ,ZBC_PEDIDO         PEDIDO" + CRLF
		_cQry   += "            ,CASE WHEN ZBC.ZBC_TPNEG = 'P'   THEN   'PESO'" + CRLF
 		_cQry   += "                  WHEN ZBC.ZBC_TPNEG = 'K'   THEN   'KG'" + CRLF
    	_cQry   += "                  WHEN ZBC.ZBC_TPNEG = 'Q'   THEN   'CABECA'"   + CRLF
 		_cQry   += "                                             ELSE   'VERIFICAR' END NEGOCIACAO"+ CRLF 
		_cQry   += "            ,ZBC.ZBC_QUANT      QTDE" + CRLF
		_cQry   += "            ,ZBC.ZBC_PESO       PESO_COMPRA" + CRLF
		_cQry   += "            ,ZBC.ZBC_PESO / ZBC.ZBC_QUANT PESO_MEDIO" + CRLF
		_cQry   += "            ,ZBC_REND           RENDIMENTO" + CRLF
		_cQry   += "            ,ZBC.ZBC_ARROV      VALOR" + CRLF
		_cQry   += "            ,CONVERT(DATE, MIN(SD1.D1_EMISSAO), 103) DATANF" + CRLF //?
		_cQry   += "            ,SUM(SD1.D1_X_PESCH) PESO_CHEGADA" + CRLF
		_cQry   += "            ,SUM(SD1.D1_X_PESCH) / ZBC.ZBC_QUANT PESOMEDIO" + CRLF
		_cQry   += "            ,SUM(SD1.D1_TOTAL)   GADO_TOTAL" + CRLF
		_cQry   += "            ,SUM(SD1.D1_CUSTO)   GADO_SEM_ICMS" + CRLF
		_cQry   += "            ,SUM(SD1.D1_VALICM)  GADO_ICMS_TOTAL" + CRLF
		_cQry   += "            ,ZBC_VLFRPG          VALOR_FRETE" + CRLF
		_cQry   += "            ,ZBC_ICFRVL          ICMS_FRETE" + CRLF
		_cQry   += "            ,ZBC_VLRCOM          COMISSAO" + CRLF
        _cQry   += "            ,CASE WHEN ZCC.ZCC_GORDO IN ('S') THEN  'SIM' " + CRLF
        _cQry   += "                 ELSE 'NÃO' END AS BOIGORDO " + CRLF
        _cQry   += "    FROM " + RetSqlName("ZBC") +" ZBC "+ CRLF
        _cQry   += "    JOIN " + RetSqlName("ZCC") + " ZCC ON"+ CRLF
        _cQry   += "                                   ZCC.ZCC_FILIAL = ZBC.ZBC_FILIAL"+ CRLF 
        _cQry   += "                                   AND ZCC.ZCC_CODIGO = ZBC.ZBC_CODIGO "+ CRLF
        _cQry   += "                                   AND ZCC.ZCC_VERSAO = ZBC.ZBC_VERSAO "+ CRLF
        _cQry   += "                                   AND ZCC.ZCC_CODFOR = ZBC.ZBC_CODFOR"+ CRLF
        _cQry   += "                                   AND ZCC.D_E_L_E_T_ = ' '"+ CRLF
	    _cQry   += "    JOIN " + RetSqlName("SA2") +" SA2 ON "+ CRLF
	    _cQry   += "                                       ZCC.ZCC_CODFOR+ZCC.ZCC_LOJFOR = SA2.A2_COD+SA2.A2_LOJA "+ CRLF
		_cQry   += "                                  AND SA2.D_E_L_E_T_ = ' '"+ CRLF
        _cQry   += " LEFT JOIN " + RetSqlName("SD1") + " SD1 ON "+ CRLF
		_cQry   += "	                                 SD1.D1_FILIAL   = ZBC.ZBC_FILIAL "+ CRLF
		_cQry   += "			                         AND SD1.D1_FORNECE+SD1.D1_LOJA  = ZBC.ZBC_CODFOR + ZBC.ZBC_LOJFOR "+ CRLF
		_cQry   += "			                         AND SD1.D1_PEDIDO = ZBC.ZBC_PEDIDO "+ CRLF
		_cQry   += "			                         AND SD1.D1_TIPO IN ('N') AND ZCC_CODFOR <> ' '"+ CRLF
		_cQry   += "			                         AND SD1.D1_COD  = ZBC.ZBC_PRODUT  "+ CRLF
		_cQry   += "			                         AND SD1.D_E_L_E_T_ = ' ' JOIN " + RetSqlName("SF4") + " SF4 ON "+ CRLF
		_cQry   += "		                                 SF4.F4_FILIAL = ' ' "+ CRLF
		_cQry   += "			                         AND SF4.F4_CODIGO = SD1.D1_TES "+ CRLF
		_cQry   += "			                         AND SF4.F4_TRANFIL <> '1' "+ CRLF
		_cQry   += "			                         AND SF4.D_E_L_E_T_ = ' '   "+ CRLF
        _cQry   += "        WHERE ZCC.ZCC_DTCONT BETWEEN '"+ DToS(mv_par01) +"' AND '"+DToS(mv_par02)+"'"+ CRLF // alterei o parametro
        _cQry   += "            AND ZBC.ZBC_PEDIDO <> ' ' "+ CRLF
        _cQry   += "            AND ZBC.D_E_L_E_T_ = ' ' "+ CRLF
        _cQry   += "            AND ZCC.ZCC_CODIGO BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"+ CRLF
        _cQry   += "            AND ZBC_PRODUT LIKE 'BOV%'"
    If MV_PAR05 == 1
        _cQry   += "            AND ZCC_GORDO IN ('S') " +CRLF
    ElseIf MV_PAR05 == 2
        _cQry   += "            AND ZCC_GORDO IN ('N', ' ') " +CRLF
    ElseIf (MV_PAR05 == 3)
        _cQry   += "            AND ZCC_GORDO IN ('S','N', ' ') " +CRLF
    EndIf
        _cQry   += " GROUP BY ZBC.ZBC_FILIAL"+ CRLF
        _cQry   += "                ,ZBC.ZBC_CODIGO"+ CRLF
        _cQry   += "                ,ZBC.ZBC_VERSAO"+ CRLF
		_cQry   += "                ,ZBC.ZBC_CODFOR"+ CRLF
		_cQry   += "                ,ZBC.ZBC_LOJFOR"+ CRLF
        _cQry   += "                ,ZCC.ZCC_NOMFOR"+ CRLF
		_cQry   += "                ,SA2.A2_MUN"+ CRLF
		_cQry   += "                ,SA2.A2_EST"+ CRLF
		_cQry   += "                ,ZBC.ZBC_PRODUT"+ CRLF
		_cQry   += "                ,ZBC.ZBC_PRDDES"+ CRLF
		_cQry   += "                ,ZBC.ZBC_TPNEG"+ CRLF
		_cQry   += "                ,ZBC.ZBC_QUANT"+ CRLF
		_cQry   += "                ,ZBC.ZBC_PESO"+ CRLF
		_cQry   += "                ,ZBC_PEDIDO"+ CRLF
		_cQry   += "                ,ZBC_REND"+ CRLF
		_cQry   += "                ,ZBC.ZBC_ARROV"+ CRLF
		_cQry   += "                ,ZBC_VLFRPG"+ CRLF
		_cQry   += "                ,ZBC_ICFRVL"+ CRLF
		_cQry   += "                ,ZBC_VLRCOM"+ CRLF
		_cQry   += "                ,SD1.D1_COD"+ CRLF
        _cQry   += "                ,ZCC_GORDO"+ CRLF
        _cQry   += " ) " + CRLF
		_cQry   += " SELECT P.*
        _cQry   += "       , SUM(ISNULL(SD1C.D1_TOTAL,0)) GADO_COMPLEMENTO  " + CRLF 
        _cQry   += " 	     , ISNULL(ZAB.ZAB_DTABAT,'') [DATAABATE] " + CRLF 
        _cQry   += " 	     , ISNULL((SUM(ZAB_PESOLQ)),0)/SUM(ZAB_QTABAT) * QTDE [PESOLIQ] " + CRLF 
        _cQry   += " 	     , ISNULL((SUM(ZAB_QTABAT)),0) [CABECA] " + CRLF 
        _cQry   += " 	     , ISNULL((SUM(ZAB_VLRARR)),0) [VLRARR] " + CRLF 
        _cQry   += " 	     , ISNULL((SUM(ZAB_VLRTOT)),0)/SUM(ZAB_QTABAT) * QTDE  [VLRTOTAL] " + CRLF 
        _cQry   += " 	     , ISNULL((SELECT STRING_AGG(D2_DOC,' | ')  " + CRLF 
        _cQry   += " 	              FROM "+RetSqlName("SD2")+" SD2 " + CRLF 
        _cQry   += " 		         WHERE D2_FILIAL = ZAB_FILIAL " + CRLF 
        _cQry   += " 				   AND D2_XCODABT = ZAB_CODIGO " + CRLF 
        _cQry   += " 				   --AND D2_XDTABAT = ZAB_DTABAT " + CRLF 
        _cQry   += " 				   AND SD2.D_E_L_E_T_ =' ' ),'') [NF_V_BET] " + CRLF 
        _cQry   += " 	  , ISNULL((SELECT STRING_AGG(D1_DOC,' | ')  " + CRLF 
        _cQry   += " 	              FROM "+RetSqlName("SD1")+" SD1   " + CRLF 
        _cQry   += " 				 WHERE D1_FILIAL = FILIAL " + CRLF 
        _cQry   += " 				   AND D1_FORNECE = P.COD_FORN " + CRLF 
        _cQry   += " 				   AND D1_LOJA = P.LOJ_FORN  " + CRLF 
        _cQry   += " 				   AND D1_PEDIDO = P.PEDIDO " + CRLF 
        _cQry   += " 				   AND SD1.D_E_L_E_T_ = ' '  " + CRLF 
        _cQry   += " 				   ),'') [NF_V_PEC] " + CRLF 
        _cQry   += "    FROM PRINCIPAL P  " + CRLF 
        _cQry   += "  LEFT JOIN "+RetSqlName("SD1")+" SD1C ON  " + CRLF 
        _cQry   += " 	        SD1C.D1_FILIAL                      = FILIAL " + CRLF 
        _cQry   += " 		AND SD1C.D1_FORNECE+SD1C.D1_LOJA    = P.COD_FORN+P.LOJ_FORN  " + CRLF 
        _cQry   += " 	    AND SD1C.D1_COD                     = P.PRODUTO " + CRLF 
        _cQry   += " 	    AND SD1C.D1_TIPO IN ('C')  " + CRLF 
        _cQry   += " 	    AND P.COD_FORN                      <> ' ' " + CRLF 
        _cQry   += " 	    AND SD1C.D_E_L_E_T_                 = ' '  " + CRLF 
        _cQry   += "   LEFT JOIN "+RetSqlName("ZAB")+" ZAB ON  " + CRLF 
        _cQry   += " 		    ZAB_FILIAL = FILIAL " + CRLF 
        _cQry   += " 		AND ZAB.ZAB_CODZCC = CODIGO " + CRLF 
        _cQry   += " 		AND ZAB.ZAB_VERZCC = VERSAO " + CRLF 
        _cQry   += " 		AND ZAB.ZAB_FORZCC = COD_FORN " + CRLF 
        _cQry   += " 		AND ZAB.ZAB_LOJZCC = LOJ_FORN " + CRLF 
        _cQry   += " 		AND ZAB.D_E_L_E_T_ = ' '   " + CRLF 
        _cQry   += "    GROUP BY  " + CRLF 
        _cQry   += "            P.FILIAL " + CRLF 
        _cQry   += "          , P.CODIGO " + CRLF 
        _cQry   += "          , P.VERSAO " + CRLF 
        _cQry   += "          , P.COD_FORN " + CRLF 
        _cQry   += "          , P.LOJ_FORN " + CRLF 
        _cQry   += "          , P.FORNECEDOR " + CRLF 
        _cQry   += "          , P.MUNICIPIO " + CRLF 
        _cQry   += "          , P.ESTADO " + CRLF 
        _cQry   += "          , P.PRODUTO " + CRLF 
        _cQry   += "          , P.DESCRICAO " + CRLF 
        _cQry   += "          , P.NEGOCIACAO " + CRLF 
        _cQry   += "          , P.QTDE " + CRLF 
        _cQry   += "          , P.PESO_COMPRA " + CRLF 
        _cQry   += "          , P.PESO_MEDIO " + CRLF 
        _cQry   += "          , P.PEDIDO " + CRLF 
        _cQry   += "          , P.RENDIMENTO " + CRLF 
        _cQry   += "          , P.VALOR " + CRLF 
        _cQry   += "          , P.PESO_CHEGADA " + CRLF 
        _cQry   += "          , P.PESOMEDIO " + CRLF 
        _cQry   += "          , P.DATANF " + CRLF 
        _cQry   += "          , P.GADO_TOTAL " + CRLF 
        _cQry   += "          , P.GADO_ICMS_TOTAL " + CRLF 
        _cQry   += "          , P.GADO_SEM_ICMS " + CRLF 
        _cQry   += "          , P.GADO_TOTAL " + CRLF 
        _cQry   += "          , P.VALOR_FRETE " + CRLF 
        _cQry   += "          , P.ICMS_FRETE " + CRLF 
        _cQry   += "          , P.COMISSAO " + CRLF 
        _cQry   += "          , P.BOIGORDO " + CRLF 
        _cQry   += "          , ZAB.ZAB_FILIAL " + CRLF 
        _cQry   += " 		    , ZAB.ZAB_CODIGO " + CRLF 
        _cQry   += " 		    , ZAB.ZAB_QTABAT " + CRLF 
        _cQry   += " 	        , ZAB.ZAB_DTABAT " + CRLF 
        _cQry   += " 	        , ZAB.ZAB_PESOLQ " + CRLF 
        _cQry   += " 	        , ZAB.ZAB_VLRARR " + CRLF 
        _cQry   += " 	        , ZAB.ZAB_DESCON " + CRLF 
        _cQry   += " 	        , ZAB.ZAB_VLRTOT " + CRLF 
        _cQry   += "          ORDER BY DATANF " + CRLF 
    ENDIF

    IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
	    MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
    ENDIF

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

RETURN !(_cAlias)->(Eof())
// FIM floadSQL

Static Function fQuadro1()
    Local cWorkSheet    := " "
    Local nRow          := 1
    Local nCol          := 1
    Local nI
    Local aHeader    := { 'Filial'				    ,;
                            'Código' 			    ,;
                            'Código do Fornecedor' 	,;
                            'Loja' 	                ,;
                            'Fornecedor' 			,;
                            'Município'		        ,;
                            'Estado'			    ,;
                            'Produto'				,;
                            'Descrição'				,;
                            'Negociação'			,;
                            'Quantidade'			,;
                            'Peso de Compra'	    ,;
                            'Peso Médio'	    	,;
                            'Rendimento'		    ,;
                            'Valor'		            ,;
                            'DataNF'				,;
                            'Peso de Chegada'	    ,;
                            'Peso Médio'			,;
                            'R$ Total'		        ,;
                            'Sem ICMS'		        ,;
                            'ICMS Total'		    ,;
                            'Frete'   		        ,;
                            'ICMS Frete'		    ,;
                            'Comissão'		        ,;
                            'Complemento'		    ,;
                            'R$ @'		            ,;
                            'Valor da @ pelo peso chegada + despesas',;
                            'Valor Cabeça'          ,;
                            'Boi Gordo?'		     }
    Local nPosQPeso := 0

    if MV_PAR05 != 2 
        aAdd(aHeader, 'Data Abate'      )
        aAdd(aHeader, 'Peso Liquido'	)
        aAdd(aHeader, 'Qtd Cabeça'	    )
        aAdd(aHeader, 'Valor @'		    )
        aAdd(aHeader, 'Valor Total'		)
        aAdd(aHeader, 'NFS V@ x Better'	)
        aAdd(aHeader, 'NFS V@ x Pec'	)
        
        nPosQPeso := Len(aHeader) - 11
    else
        nPosQPeso := Len(aHeader) - 4
    endif
 
    cWorkSheet := cTitulo

    oExcel:AddSheet(cWorkSheet)

    oExcel:SetCellsFormatConfig(jFormatTit)
    oExcel:SetFontConfig(JFontTitulo)
    oExcel:MergeCells(nRow, nCol, nRow+1, Len(aHeader))
    
    oExcel:SetText(nRow, nCol, cWorkSheet )

    nRow += 2
    nCol := nPosQPeso - 5

    oExcel:MergeCells(nRow, nCol, nRow, nPosQPeso)

    oExcel:SetCellsFormatConfig(jFormatHead)
    oExcel:SetFontConfig(JFontHeader)
    oExcel:SetValue(nRow    , nCol, "Estimativa de quebra de peso do gado")

    nCol := nPosQPeso
    oExcel:SetFontConfig(JFontText)
    oExcel:SetBorderConfig(jBorder)
    oExcel:SetCellsFormatConfig(JFNum)
    oExcel:SetValue(nRow    , ++nCol, MV_PAR06)

    
    nRow += 1
    nCol := 1

    oExcel:SetCellsFormatConfig(jFormatHead)
    oExcel:SetFontConfig(JFontHeader)

    For nI := nCol to Len(aHeader)
        oExcel:SetValue(nRow, nI, aHeader[nI])
    Next nI
    
    oExcel:SetCellsFormatConfig(JFLeft)
    oExcel:SetBorderConfig(jBorder)
    oExcel:SetFontConfig(jFontText)
    While !(_cAliasG)->(Eof())

        nRow += 1
        nCol := 1
        oExcel:SetCellsFormatConfig(JFLeft)
        oExcel:SetValue(nRow, nCol  , AllTrim((_cAliasG)->FILIAL     )   )
        oExcel:SetValue(nRow, ++nCol, AllTrim((_cAliasG)->CODIGO     )   )
        oExcel:SetValue(nRow, ++nCol, AllTrim((_cAliasG)->COD_FORN   )   )
        oExcel:SetValue(nRow, ++nCol, AllTrim((_cAliasG)->LOJ_FORN   )   )
        oExcel:SetValue(nRow, ++nCol, AllTrim((_cAliasG)->FORNECEDOR )   )
        oExcel:SetValue(nRow, ++nCol, AllTrim((_cAliasG)->MUNICIPIO  )   )
        oExcel:SetValue(nRow, ++nCol, AllTrim((_cAliasG)->ESTADO     )   )
        oExcel:SetValue(nRow, ++nCol, AllTrim((_cAliasG)->PRODUTO    )   )
        oExcel:SetValue(nRow, ++nCol, AllTrim((_cAliasG)->DESCRICAO  )   )
        oExcel:SetValue(nRow, ++nCol, AllTrim((_cAliasG)->NEGOCIACAO )   )

        jFNum['custom_format']     := "###,###,##0.00"
        oExcel:SetCellsFormatConfig(jFNum)
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->QTDE          )
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->PESO_COMPRA   )
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->PESO_MEDIO    )
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->RENDIMENTO    )
        
        oExcel:SetCellsFormatConfig(jFMoeda)
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->VALOR     )
        
        oExcel:SetCellsFormatConfig(JFData)
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->DATANF    )

        jFNum['custom_format']     := "###,###,##0.00"
        oExcel:SetCellsFormatConfig(jFNum)
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->PESO_CHEGADA      )
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->PESOMEDIO         )

        oExcel:SetCellsFormatConfig(jFMoeda)
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->GADO_TOTAL        )
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->GADO_SEM_ICMS     )
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->GADO_ICMS_TOTAL   )
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->VALOR_FRETE       )
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ICMS_FRETE		)
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->COMISSAO		    )
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->GADO_COMPLEMENTO  )
        
        cRow := cValToChar(nRow)
        oExcel:SetFormula(nRow, ++nCol, "=IF(L"+cRow+">0, " +;
                                        "(S"+cRow+"+V"+cRow+"+W"+cRow+"+X"+cRow+"+Y"+cRow+")/(L"+cRow+"*(N"+cRow+"/100))*15, " +;
                                        "((S"+cRow+"+V"+cRow+"+W"+cRow+"+X"+cRow+"+Y"+cRow+")    /  ((Q"+cRow+"+($Z$3*K"+cRow+")) *  (IF(N"+cRow+">0,N"+cRow+",50)/100) ))*15) " )  
        
        oExcel:SetFormula(nRow, ++nCol, "=IF(Q"+cRow+"=0,Z"+cRow+",((S"+cRow+"+V"+cRow+"+W"+cRow+"+X"+cRow+"+Y"+cRow+")/K"+cRow+")/R"+cRow+"*30)" )
        
        oExcel:SetFormula(nRow, ++nCol, "=SUM(S"+cRow+"+V"+cRow+"+W"+cRow+"+X"+cRow+"+Y"+cRow+")/K"+cRow+"" )

        oExcel:SetCellsFormatConfig(JFLeft)
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->BOIGORDO		    )
        
        IF MV_PAR05 != 2 
            oExcel:SetCellsFormatConfig(JFData)
            oExcel:SetValue(nRow, ++nCol, iif(AllTRIM((_cAliasG)->DATAABATE) != '',sTod((_cAliasG)->DATAABATE),""))

            oExcel:SetCellsFormatConfig(jFNum)
            oExcel:SetValue(nRow, ++nCol, (_cAliasG)->PESOLIQ  )
            oExcel:SetValue(nRow, ++nCol, (_cAliasG)->CABECA  )

            oExcel:SetCellsFormatConfig(jFMoeda)
            oExcel:SetValue(nRow, ++nCol, (_cAliasG)->VLRARR  )
            oExcel:SetValue(nRow, ++nCol, (_cAliasG)->VLRTOTAL  )
            
            oExcel:SetCellsFormatConfig(JFLeft)
            oExcel:SetValue(nRow, ++nCol, AllTRIM((_cAliasG)->NF_V_BET)  )
            oExcel:SetValue(nRow, ++nCol, AllTRIM((_cAliasG)->NF_V_PEC)  )

        ENDIF

        (_cAliasG)->(DbSkip())
	EndDo

    oExcel:ApplyAutoFilter(4,1,nRow,Len(aHeader))
    
    nRow += 1

    jFormatTot['custom_format']     := "###,##0.00"
    oExcel:SetCellsFormatConfig(jFormatTot)
    oExcel:SetFormula(nRow, 11, "=SUBTOTAL(9,K5:K"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 12, "=SUBTOTAL(9,L5:L"+cValToChar(nRow-1)+")") 
    
    oExcel:SetFormula(nRow, 26, "=SUBTOTAL(1,Z5:Z"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 27, "=SUBTOTAL(1,AA5:AA"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 28, "=SUBTOTAL(1,AB5:AB"+cValToChar(nRow-1)+")") 
Return 


Static Function DefinirFormatacao()
    Local cCVerde       := '00A75D'
    Local cCCinza       := "D9D9D9"
    Local cCAmarelo     := "FFFF00"

    JFontHeader := FwXlsxPrinterConfig():MakeFont()
    JFontHeader['font'] := FwPrinterFont():Calibri()
    JFontHeader['size'] := 12
    JFontHeader['bold'] := .T.

    JFontTitulo := FwXlsxPrinterConfig():MakeFont()
    JFontTitulo['font'] := FwPrinterFont():Calibri()
    JFontTitulo['size'] := 14
    JFontTitulo['bold'] := .T.
    JFontTitulo['underline'] := .F. 

    JFontText := FwXlsxPrinterConfig():MakeFont()
    JFontText['font'] := FwPrinterFont():Calibri()
    JFontText['size'] := 12
    JFontText['italic'] := .F.

    JFLeft := JsonObject():New()
    JFLeft['hor_align']        := oCellHorAlign:Left()
    JFLeft['vert_align']       := oCellVertAlign:Center()
    JFLeft := FwXlsxPrinterConfig():MakeFormat(JFLeft)

    JFCenter := JsonObject():New()
    JFCenter['hor_align']        := oCellHorAlign:Center()
    JFCenter['vert_align']       := oCellVertAlign:Center()
    JFCenter := FwXlsxPrinterConfig():MakeFormat(JFCenter)

    JFRight := JsonObject():New()
    JFRight := FwXlsxPrinterConfig():MakeFormat()
    JFRight['hor_align']        := oCellHorAlign:RIGHT()
    JFRight['vert_align']       := oCellVertAlign:Center()
    JFRight := FwXlsxPrinterConfig():MakeFormat(JFRight)
    
    JFData := JsonObject():New()
    JFData['custom_format']    := "dd/mm/yyyy"
    JFData['hor_align']        := oCellHorAlign:Left()
    JFData['vert_align']       := oCellVertAlign:Center()
    JFData := FwXlsxPrinterConfig():MakeFormat(JFData)

    jFormatTit := JsonObject():New()
    jFormatTit['hor_align']         := oCellHorAlign:Center()
    jFormatTit['vert_align']        := oCellVertAlign:Center()
    jFormatTit['background_color']  := cCVerde
    jFormatTit := FwXlsxPrinterConfig():MakeFormat(jFormatTit)

    jFormatGD := JsonObject():New()
    jFormatGD['hor_align']         := oCellHorAlign:Center()
    jFormatGD['vert_align']        := oCellVertAlign:Center()
    jFormatGD['background_color']  := cCAmarelo
    jFormatGD := FwXlsxPrinterConfig():MakeFormat(jFormatGD)
    
    jFormatTot := JsonObject():New()
    jFormatTot['custom_format']     := "\R$ ###,##0.00"
    jFormatTot['hor_align']         := oCellHorAlign:Center()
    jFormatTot['vert_align']        := oCellVertAlign:Center()
    jFormatTot['background_color']  := cCCinza
    jFormatTot := FwXlsxPrinterConfig():MakeFormat(jFormatTot)

    jFormatHead := JsonObject():New()
    jFormatHead['hor_align']         := oCellHorAlign:Center()
    jFormatHead['vert_align']        := oCellVertAlign:Center()
    jFormatHead['background_color']  := "000000"
    jFormatHead['text_color']        := "FFFFFF"
    jFormatHead['text_wrap']         := .T. 
    jFormatHead := FwXlsxPrinterConfig():MakeFormat(jFormatHead)

    //MOEDA COM 4 CASAS DECIMAIS
    jFM4d := FwXlsxPrinterConfig():MakeFormat()
    jFM4d['custom_format']    := "\R$ ###,##0.0000"
    jFM4d['hor_align']        := oCellHorAlign:RIGHT()
    jFM4d['vert_align']       := oCellVertAlign:Center()

    jFMoeda := FwXlsxPrinterConfig():MakeFormat()
    jFMoeda['custom_format']    := "\R$ ###,##0.00"
    jFMoeda['hor_align']        := oCellHorAlign:RIGHT()
    jFMoeda['vert_align']       := oCellVertAlign:Center()

    jFPercent := FwXlsxPrinterConfig():MakeFormat()
    jFPercent['custom_format']    := "#0.00%"
    jFPercent['hor_align']        := oCellHorAlign:RIGHT()
    jFPercent['vert_align']       := oCellVertAlign:Center()

    jFNum := FwXlsxPrinterConfig():MakeFormat()
    jFNum['hor_align']        := oCellHorAlign:Left()
    jFNum['vert_align']       := oCellVertAlign:Center()

    // Bordas para o header
    jBorder := FwXlsxPrinterConfig():MakeBorder()
    jBorder['top']    := .T.
    jBorder['bottom'] := .T.
    jBorder['left']   := .T.
    jBorder['right']  := .T.
    jBorder['border_color'] := "000000"
    jBorder['style'] := FwXlsxBorderStyle():Medium()

    jNoBorder := FwXlsxPrinterConfig():MakeBorder()
    jNoBorder['top']    := .F.
    jNoBorder['bottom'] := .F.
    jNoBorder['left']   := .F.
    jNoBorder['right']  := .F.
    jNoBorder['border_color'] := "000000"
    jNoBorder['style'] := FwXlsxBorderStyle():Medium()

    jBHeaderLeft := FwXlsxPrinterConfig():MakeBorder()
    jBHeaderLeft['top']    := .T.
    jBHeaderLeft['bottom'] := .F.
    jBHeaderLeft['left']   := .T.
    jBHeaderLeft['right']  := .F.
    jBHeaderLeft['border_color'] := "000000"
    jBHeaderLeft['style'] := FwXlsxBorderStyle():Medium()

    jBHeaderRight := FwXlsxPrinterConfig():MakeBorder()
    jBHeaderRight['top']    := .T.
    jBHeaderRight['bottom'] := .F.
    jBHeaderRight['left']   := .F.
    jBHeaderRight['right']  := .T.
    jBHeaderRight['border_color'] := "000000"
    jBHeaderRight['style'] := FwXlsxBorderStyle():Medium()
    
    jBottomLeft := FwXlsxPrinterConfig():MakeBorder()
    jBottomLeft['top']    := .F.
    jBottomLeft['bottom'] := .T.
    jBottomLeft['left']   := .T.
    jBottomLeft['right']  := .F.
    jBottomLeft['border_color'] := "000000"
    jBottomLeft['style'] := FwXlsxBorderStyle():Medium()

    jBottomRight := FwXlsxPrinterConfig():MakeBorder()
    jBottomRight['top']    := .F.
    jBottomRight['bottom'] := .T.
    jBottomRight['left']   := .F.
    jBottomRight['right']  := .T.
    jBottomRight['border_color'] := "000000"
    jBottomRight['style'] := FwXlsxBorderStyle():Medium()

    jBorderLeft := FwXlsxPrinterConfig():MakeBorder()
    jBorderLeft['left'] := .T.
    jBorderLeft['border_color'] := "000000"
    jBorderLeft['style'] := FwXlsxBorderStyle():Medium()
    
    jBorderCenter := FwXlsxPrinterConfig():MakeBorder()
    jBorderCenter['left'] := .T.
    jBorderCenter['right'] := .T.
    jBorderCenter['border_color'] := "000000"
    jBorderCenter['style'] := FwXlsxBorderStyle():Medium()
    
    jBorderRight := FwXlsxPrinterConfig():MakeBorder()
    jBorderRight['right'] := .T.
    jBorderRight['border_color'] := "000000"
    jBorderRight['style'] := FwXlsxBorderStyle():Medium()

Return 
