#include 'TOTVS.CH'
#include 'fileio.ch'
#include 'RWMAKE.CH'
#include 'protheus.ch'
#include 'parmtype.ch'
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
    Local lTemDados := .T.
    Local cPerg     := "VAESTIG1"
    Private cTitulo     := "Relatório - Compra de Gado"
    Private cPath       := "C:\TOTVS_RELATORIOS\"
    Private cArquivo    := cPath + cPerg +;
                                    DToS(dDataBase)+;//converte a data para aaaammdd
                                    "_"+;
                                    StrTran(Subs(Time(),1,5),":","")+;
                                    ".xml"
    Private oExcelApp   := nil
    Private _cAliasG    := GetNextAlias()

    Private nHandle     := 0
    Private nHandAux    := 0

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
    ENDIF

    nHandle := FCREATE(cArquivo)
    IF nHandle = -1
        ConOut("Erro ao criar arquivo - ferror" + Str(FError()))
    ELSE
        cStyle  := U_defStyle()
        // Processar SQL
 		FWMsgRun(, {|| lTemDados := fLoadSql("Geral", @_cAliasG ) },;
					    'Por Favor Aguarde...',; 
						'Processando Banco de Dados - Recebimento')
        IF lTemDados
            cXML    := U_CabXMLExcel(cStyle)

            IF !Empty(cXML)
                FWrite(nHandle, EncodeUTF8(cXML))
                cXML := ""
            ENDIF

            // Gerar primeira planilha
            FWMsgRun(, {|| fQuadro1() }, 'Gerando excel, Por favor, aguarde...')

            // Final - encerramento do arquivo
            FWrite(nHandle, EncodeUTF8('</Workbook>'))

            FClose(nHandle)

            IF ApoLeClient("MSExcel") // Verifica se o excel está instado
                oExcelApp   := MsExcel():New()
                oExcelApp:WorkBooks:Open(cArquivo)
                oExcelApp:SetVisible(.T.)
                oExcelApp:Destroy()
            ELSE
                MsgAlert("O Excel não foi encontrado. Arquivo" + cArquivo + " gerado em " + cPath + ".", "MsExcel não encontrado")
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
		_cQry   += "            ,ZBC.ZBC_CODFOR     COD_FORN" + CRLF
		_cQry   += "            ,ZBC.ZBC_LOJFOR     LOJ_FORN" + CRLF
		_cQry   += "            ,ZCC.ZCC_NOMFOR     FORNECEDOR " + CRLF
		_cQry   += "            ,SA2.A2_MUN         MUNICIPIO" + CRLF
		_cQry   += "            ,SA2.A2_EST         ESTADO" + CRLF
		_cQry   += "            ,ZBC.ZBC_PRODUT     PRODUTO" + CRLF
		_cQry   += "            ,ZBC_PRDDES         DESCRICAO" + CRLF
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
		_cQry   += "                ,ZBC_REND"+ CRLF
		_cQry   += "                ,ZBC.ZBC_ARROV"+ CRLF
		_cQry   += "                ,ZBC_VLFRPG"+ CRLF
		_cQry   += "                ,ZBC_ICFRVL"+ CRLF
		_cQry   += "                ,ZBC_VLRCOM"+ CRLF
		_cQry   += "                ,SD1.D1_COD"+ CRLF
        _cQry   += "                ,ZCC_GORDO"+ CRLF
        _cQry   += " ) " + CRLF
		_cQry   += " SELECT P.*, SUM(ISNULL(SD1C.D1_TOTAL,0)) GADO_COMPLEMENTO " + CRLF
		_cQry   += "        FROM PRINCIPAL P " + CRLF
		_cQry   += "            LEFT JOIN " +RetSqlName("SD1") + " SD1C ON " + CRLF
		_cQry   += "				                               SD1C.D1_FILIAL                      = FILIAL" + CRLF
		_cQry   += "			                                   AND SD1C.D1_FORNECE+SD1C.D1_LOJA    = P.COD_FORN+P.LOJ_FORN " + CRLF
		_cQry   += "			                                   AND SD1C.D1_COD                     = P.PRODUTO" + CRLF
		_cQry   += "			                                   AND SD1C.D1_TIPO IN ('C') " + CRLF
		_cQry   += "			                                   AND P.COD_FORN                      <> ' '" + CRLF
		_cQry   += "			                                   AND SD1C.D_E_L_E_T_                 = ' ' " + CRLF
		_cQry   += "                GROUP BY " + CRLF
		_cQry   += "                P.FILIAL" + CRLF
		_cQry   += "                ,P.CODIGO" + CRLF
        _cQry   += "                ,P.COD_FORN" + CRLF
		_cQry   += "                ,P.LOJ_FORN" + CRLF
		_cQry   += "                ,P.FORNECEDOR" + CRLF
		_cQry   += "                ,P.MUNICIPIO" + CRLF
		_cQry   += "                ,P.ESTADO" + CRLF
		_cQry   += "                ,P.PRODUTO" + CRLF
		_cQry   += "                ,P.DESCRICAO" + CRLF
		_cQry   += "                ,P.NEGOCIACAO" + CRLF
		_cQry   += "                ,P.QTDE" + CRLF
		_cQry   += "                ,P.PESO_COMPRA" + CRLF
		_cQry   += "                ,P.PESO_MEDIO" + CRLF
		_cQry   += "                ,P.RENDIMENTO" + CRLF
		_cQry   += "                ,P.VALOR" + CRLF
		_cQry   += "                ,P.PESO_CHEGADA" + CRLF
		_cQry   += "                ,P.PESOMEDIO" + CRLF
		_cQry   += "                ,P.DATANF" + CRLF
		_cQry   += "                ,P.GADO_TOTAL" + CRLF
		_cQry   += "                ,P.GADO_ICMS_TOTAL" + CRLF
		_cQry   += "                ,P.GADO_SEM_ICMS" + CRLF
		_cQry   += "                ,P.GADO_TOTAL" + CRLF
		_cQry   += "                ,P.VALOR_FRETE" + CRLF
		_cQry   += "                ,P.ICMS_FRETE" + CRLF
		_cQry   += "                ,P.COMISSAO" + CRLF
        _cQry   += "                ,P.BOIGORDO" + CRLF
		_cQry   += "       ORDER BY DATANF" + CRLF
    ENDIF

    IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
	    MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
    ENDIF

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

RETURN !(_cAlias)->(Eof())
// FIM floadSQL

STATIC FUNCTION fQuadro1()
    LOCAL nRegistros    := 0
    LOCAL cXML          := ""
    LOCAL cWorkSheet    := ""


    (_cAliasG)->(DbEval({|| nRegistros++}))

    (_cAliasG) -> (DbGoTop())

    IF  !(_cAliasG)->(DbGoTop())

        cWorkSheet  := "Relatório - Compra de Gado"

        cXML += U_prtCellXML( 'Worksheet', cWorkSheet)

        cXML += ' <Names>' + CRLF
        cXML += ' <NamedRange ss:Name="_FilterDatabase"'+ CRLF
        cXML += ' ss:RefersTo="='+cWorkSheet+'!R1C1:R'+CValToChar(nRegistros+1)+'C25"'+CRLF
        cXML += 'ss:Hidden="1"/>' + CRLF
        cXML += '</Names>'+CRLF
        
        cXML += '<Table>'+CRLF
        cXML += ' <Column ss:Index="3" ss:AutoFitWidth="0" ss:Width="60"/>'+CRLF
        cXML += ' <Column ss:Width="52.5"/>'+CRLF
        cXML += ' <Column ss:Width="184.5"/>'+CRLF
        cXML += ' <Column ss:Width="160.5"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="39"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="90"/>'+CRLF
        cXML += ' <Column ss:Width="74.25"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="63.75"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="58.5"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="52.5"/>'+CRLF
        cXML += ' <Column ss:Width="44.25"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="61.5"/>'+CRLF
        cXML += ' <Column ss:Width="52.5"/>'+CRLF
        cXML += ' <Column ss:Width="51.75"/>'+CRLF
        cXML += ' <Column ss:Width="57.75"/>'+CRLF
        cXML += ' <Column ss:Width="47.25"/>'+CRLF
        cXML += ' <Column ss:Width="65.25" ss:Span="1"/>'+CRLF
        cXML += ' <Column ss:Index="21" ss:AutoFitWidth="0" ss:Width="62.25"/>'+CRLF
        cXML += ' <Column ss:Width="57.75"/>'+CRLF
        cXML += ' <Column ss:Width="52.5"/>'+CRLF
        cXML += ' <Column ss:Width="57.75"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="70.5"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="68.25"/>'+CRLF

        cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '16'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)
	    // Titulo
	    cXML += U_prtCellXML( 'Row',,'33' )
/*01*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Filial'				    ,,.T. )
/*02*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Código' 			        ,,.T. )
/*03*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Código do Fornecedor' 	,,.T. )
/*04*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Loja' 	                ,,.T. )
/*05*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Fornecedor' 			    ,,.T. )
/*06*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Município'		        ,,.T. )
/*07*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Estado'			        ,,.T. )
/*08*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Produto'				    ,,.T. )
/*09*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Descrição'				,,.T. )
/*10*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Negociação'			    ,,.T. )
/*11*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Quantidade'			    ,,.T. )
/*12*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso de Compra'	        ,,.T. )
/*13*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Médio'	    	    ,,.T. )
/*14*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Rendimento'		        ,,.T. )
/*14*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Valor'		            ,,.T. )
/*15*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'DataNF'				    ,,.T. )
/*16*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso de Chegada'	        ,,.T. )
/*17*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Peso Médio'			    ,,.T. )
/*18*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$ Total'		        ,,.T. )
/*19*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Sem ICMS'		        ,,.T. )
/*20*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'ICMS Total'		        ,,.T. )
/*21*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Frete'   		        ,,.T. )
/*22*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'ICMS Frete'		        ,,.T. )
/*23*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Comissão'		        ,,.T. )
/*24*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Complemento'		        ,,.T. )
/*25*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$ @'		            ,,.T. )
/*26*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Boi Gordo?'		        ,,.T. )
	    cXML += U_prtCellXML( '</Row>' )

    	//fQuadro1
	While !(_cAliasG)->(Eof())

	  cXML += U_prtCellXML( 'Row' )
/*01*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->FILIAL )                                            ,,.T. )//Filial'		
/*02*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->CODIGO)                                             ,,.T. )//'Código   
/*03*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->COD_FORN )                                           ,,.T. )//'Código do Fornecedor'
/*04*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->LOJ_FORN )                                           ,,.T. )//'Loja'		
/*05*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->FORNECEDOR )                                        ,,.T. )//'Fornecedor'	   
/*06*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->MUNICIPIO )                                         ,,.T. )//'Município'	   
/*07*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->ESTADO)                                             ,,.T. )//'Estado'			
/*08*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->PRODUTO)                                            ,,.T. )//'Produto'			
/*09*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->DESCRICAO )		                                    ,,.T. )//'Descrição'		
/*10*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->NEGOCIACAO )	                                    ,,.T. )//'Negociação'			
/*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->QTDE )			                                    ,,.T. )//'Quantidade'	    
/*12*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->PESO_COMPRA )	                                    ,,.T. )//'Peso de Compra'	    	
/*13*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->PESO_MEDIO )	                                    ,,.T. )//'Peso Médio'		       
/*14*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->RENDIMENTO )	                                    ,,.T. )//'Rendimento'			
/*15*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->VALOR)		                                        ,,.T. )//'Valor'   
/*16*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData', 'DateTime', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->DATANF)  		                                    ,,.T. )//'DataNF'			
/*17*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->PESO_CHEGADA)	                                    ,,.T. )//'Peso de Chegada'		   
/*18*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->PESOMEDIO)		                                    ,,.T. )//'Peso Médio'	       
/*19*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->GADO_TOTAL	)	                                    ,,.T. )//'R$ Total'		   	
/*20*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->GADO_SEM_ICMS)	                                    ,,.T. )//'Sem ICMS'		   
/*21*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->GADO_ICMS_TOTAL)                                    ,,.T. )//'ICMS Total'		     
/*22*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->VALOR_FRETE)	                                    ,,.T. )//'Frete'		   
/*23*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->ICMS_FRETE)		                                    ,,.T. )//'ICMS Frete'	       
/*24*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->COMISSAO)		                                    ,,.T. )//'Comissão'		       
/*25*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->GADO_COMPLEMENTO)                                   ,,.T. )//'Complemento'
/*26*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/ "=IF(RC[-14]&gt;0,&#10;       (RC[-7]+RC[-4]+RC[-3]+RC[-2]+RC[-1])/(RC[-14]*(RC[-12]/100))*15,&#10;       (  (RC[-7]+RC[-4]+RC[-3]+RC[-2]+RC[-1])    /  ((RC[-9]+(R1C26*RC[-15])) *  (IF(RC[-12]&gt;0,RC[-12],50)/100) ))*15)",   ,,.T. )
///*26*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/ "=IFERROR((RC[-7]+RC[-4]+RC[-3]+RC[-2]+RC[-1])/(RC[-14]*(RC[-12]/100))*15,0)",   ,,.T. )
/*27*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasG)->BOIGORDO )	                                    ,,.T. )//'Boi Gordo'			
      cXML += U_prtCellXML( '</Row>' )		
    
		(_cAliasG)->(DbSkip())
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
		cXML := ""

	EndDo
    //Linha média Geral 
    cXML += ' <Row> ' +CRLF
    cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'25',/*cMergeAcross*/,'s65',     'String',  /*cFormula*/,"Média Geral"                               ,,.T. )
    cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'26',/*cMergeAcross*/,'sComDig', 'Number', "=SUBTOTAL(1,R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)",  ,,.T. )
    cXML += ' </Row> ' +CRLF    

    //fim da tabela
    cXML += '</Table>'+CRLF
    cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
    cXML += '  <PageSetup>'+CRLF
    cXML += '   <Header x:Margin="0.31496062000000002"/>'+CRLF
    cXML += '   <Footer x:Margin="0.31496062000000002"/>'+CRLF
    cXML += '   <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"'+CRLF
    cXML += '    x:Right="0.511811024" x:Top="0.78740157499999996"/>'+CRLF
    cXML += '  </PageSetup>'+CRLF
    cXML += '  <Unsynced/>'+CRLF
    cXML += '  <Print>'+CRLF
    cXML += '   <ValidPrinterInfo/>'+CRLF
    cXML += '   <PaperSizeIndex>9</PaperSizeIndex>'+CRLF
    cXML += '   <VerticalResolution>0</VerticalResolution>'+CRLF
    cXML += '  </Print>'+CRLF
    cXML += '  <Selected/>'+CRLF
    cXML += '  <FreezePanes/>'+CRLF
    cXML += '  <FrozenNoSplit/>'+CRLF
    cXML += '  <SplitHorizontal>2</SplitHorizontal>'+CRLF
    cXML += '  <TopRowBottomPane>2</TopRowBottomPane>'+CRLF
    cXML += '  <ActivePane>2</ActivePane>'+CRLF
    cXML += '  <Panes>'+CRLF
    cXML += '   <Pane>'+CRLF
    cXML += '    <Number>3</Number>'+CRLF
    cXML += '   </Pane>'+CRLF
    cXML += '   <Pane>'+CRLF
    cXML += '    <Number>2</Number>'+CRLF
    cXML += '    <ActiveRow>1</ActiveRow>'+CRLF
    cXML += '   </Pane>'+CRLF
    cXML += '  </Panes>'+CRLF
    cXML += '  <ProtectObjects>False</ProtectObjects>'+CRLF
    cXML += '  <ProtectScenarios>False</ProtectScenarios>'+CRLF
    cXML += ' </WorksheetOptions>'+CRLF
    cXML += '</Worksheet>'+CRLF

    If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""
    
    ENDIF
RETURN
