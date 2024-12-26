#include 'TOTVS.CH'
#include 'fileio.ch'
#include 'RWMAKE.CH'
#include 'protheus.ch'
#include 'parmtype.ch'

 USER FUNCTION VAESTIG2()
    Local cTimeINi  := Time()
    Local cStyle    := ""
    Local cXML      := ""
    Local lTemDados := .T.
    Local cPerg     := "VAESTIG2"
    Private cTitulo     := "Relatório - Premiação dos motoristas"
    Private cPath       := "C:\TOTVS_RELATORIOS\"
    Private cArquivo    := cPath + cPerg +;
                                    DToS(dDataBase)+;//converte a data para aaaammdd
                                    "_"+;
                                    StrTran(Subs(Time(),1,5),":","")+;
                                    ".xml"
    Private oExcelApp   := nil
    Private _cAliasC    := GetNextAlias()  //Carregamento
    Private _cAliasF    := GetNextAlias() // Fornecimento

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
        
        cXML    := U_CabXMLExcel(cStyle)
        IF !Empty(cXML)
            FWrite(nHandle, EncodeUTF8(cXML))
            cXML := ""
        ENDIF
            // Processar SQL
            FWMsgRun(, {|| lTemDados := fLoadSQL("Carregamento", @_cAliasC ) },;
			    'Por Favor Aguarde...',;
				'Processando Banco de Dados - Carregamento')
            IF lTemDados
                FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro 1')       
            ENDIF  
            
            // Processar SQL
            FWMsgRun(, {|| lTemDados := fLoadSQL("Fornecimento", @_cAliasF ) },;
			    'Por Favor Aguarde...',; 
				'Processando Banco de Dados - Fornecimento')           
            IF lTemDados            
                FWMsgRun(, {|| fQuadro2() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro 2')
            
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

        (_cAliasC)->(DbCloseArea())        
        (_cAliasF)->(DbCloseArea())

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
    AADD(aRegs,{cPerg,"03","Codigo Operador    ?",Space(20),Space(20),"mv_ch3", TamSX3("Z0U_CODIGO")[3], TamSX3("Z0U_CODIGO")[1], TamSX3("Z0U_CODIGO")[2],0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
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
    Local _cQry := ""

    IF cTipo == "Carregamento"    
       _cQry := "   SELECT Z0Y.Z0Y_FILIAL"+CRLF        
       _cQry += "       , CONVERT(DATE,Z0Y.Z0Y_DATA,103) Z0Y_DATA"+CRLF
       _cQry += "		, Z0Y.Z0Y_ROTA"+CRLF
       _cQry += "		, Z0Y.Z0Y_ORDEM"+CRLF
       _cQry += "		, Z0Y.Z0Y_TRATO"+CRLF
       _cQry += "		, Z0Y.Z0Y_RECEIT"+CRLF
       _cQry += "		, B1R.B1_DESC DESC_REC"+CRLF
       _cQry += "		, CASE WHEN Z0Y.Z0Y_ORIGEM = 'B' THEN 'BALANCA' "+CRLF
       _cQry += "		       WHEN Z0Y.Z0Y_ORIGEM = 'P' THEN 'PHIBRO'"+CRLF
       _cQry += "			   WHEN Z0Y.Z0Y_ORIGEM = 'V' THEN 'CHUVEIRO'"+CRLF
       _cQry += "			   ELSE ' ' "+CRLF
       _cQry += "			 END AS Z0Y_ORIGEM"+CRLF
       _cQry += "		, Z0Y.Z0Y_COMP"+CRLF
       _cQry += "		, B1C.B1_DESC DESC_COMP"+CRLF
       _cQry += "        , CASE WHEN Z0Y.Z0Y_KGRECA > 0 THEN Z0Y.Z0Y_KGRECA "+CRLF
       _cQry += "		       ELSE Z0Y.Z0Y_QTDPRE "+CRLF
       _cQry += "			 END AS Z0Y_QTDPRE"+CRLF
       _cQry += "		, CASE WHEN Z0Y.Z0Y_PESDIG > 0 THEN Z0Y.Z0Y_PESDIG"+CRLF
       _cQry += "		       ELSE Z0Y.Z0Y_QTDREA"+CRLF
       _cQry += "			 END AS Z0Y_QTDREA"+CRLF
       _cQry += " "+CRLF
       _cQry += "		, ROUND((CASE WHEN Z0Y.Z0Y_PESDIG > 0 THEN Z0Y.Z0Y_PESDIG"+CRLF
       _cQry += "		       ELSE Z0Y.Z0Y_QTDREA"+CRLF
       _cQry += "			 END "+CRLF
       _cQry += "			 -"+CRLF
       _cQry += "			 CASE WHEN Z0Y.Z0Y_KGRECA > 0 THEN Z0Y.Z0Y_KGRECA "+CRLF
       _cQry += "		       ELSE Z0Y.Z0Y_QTDPRE "+CRLF
       _cQry += "			 END ),2) KG_DIF"+CRLF
       _cQry += " "+CRLF
       _cQry += "		, ROUND((CASE WHEN Z0Y.Z0Y_PESDIG > 0 THEN Z0Y.Z0Y_PESDIG"+CRLF
       _cQry += "		       ELSE Z0Y.Z0Y_QTDREA"+CRLF
       _cQry += "			 END "+CRLF
       _cQry += "			 /"+CRLF
       _cQry += "			 CASE WHEN Z0Y.Z0Y_KGRECA > 0 THEN Z0Y.Z0Y_KGRECA "+CRLF
       _cQry += "		       ELSE Z0Y.Z0Y_QTDPRE "+CRLF
       _cQry += "			 END )-1,2)*100 PERC_DIF"+CRLF
       _cQry += "		, ISNULL(ZRF_TOLPER ,0) ZRF_TOLPER"+CRLF
       _cQry += "		, Z0Y_HORINI"+CRLF
       _cQry += "		, Z0Y_HORFIN"+CRLF
    IF !EMPTY(mv_par03)
       _cQry += "		, Z0X_OPERAD"+CRLF
       _cQry += "		, Z0U_NOME"+CRLF
    ENDIF
       _cQry += "    FROM " +RetSqlName("Z0Y")+ " Z0Y"+CRLF
       _cQry += "	 JOIN " +RetSqlName("Z0X")+ " Z0X ON "+CRLF
       _cQry += "	      Z0X.Z0X_FILIAL = Z0Y.Z0Y_FILIAL"+CRLF
       _cQry += "	  AND Z0X.Z0X_CODIGO = Z0Y.Z0Y_CODEI"+CRLF
       _cQry += "	  AND Z0X_OPERAC = '1'"+CRLF
       _cQry += "	 JOIN " +RetSqlName("SB1")+ " B1R ON"+CRLF
       _cQry += "	      B1R.B1_FILIAL = ' ' "+CRLF
       _cQry += "	  AND B1R.B1_COD = Z0Y_RECEIT"+CRLF
       _cQry += "	  AND B1R.B1_X_TRATO = '1'"+CRLF
       _cQry += "	  AND B1R.D_E_L_E_T_ = ' ' "+CRLF
       _cQry += " "+CRLF
       _cQry += "	 JOIN " +RetSqlName("SB1")+ " B1C ON "+CRLF
       _cQry += "	      B1C.B1_FILIAL = ' ' "+CRLF
       _cQry += "	  AND B1C.B1_COD = Z0Y_COMP"+CRLF
       _cQry += "	  AND B1C.D_E_L_E_T_  = ' ' "+CRLF
    IF !EMPTY(mv_par03)
       _cQry += " 	 LEFT JOIN " +RetSqlName("Z0U")+ " Z0U ON " + CRLF
       _cQry += "                                         Z0U.Z0U_FILIAL = '01' " + CRLF
       _cQry += "                                         AND Z0U.Z0U_CODIGO = Z0X_OPERAD" + CRLF
       _cQry += "                                         AND Z0U.D_E_L_E_T_ = ' ' " + CRLF
       _cQry += "" +CRLF
    ENDIF
       _cQry += "	 LEFT JOIN " +RetSqlName("ZRF")+ " ZRF ON  ZRF_DTINI <= '" +DToS(mv_par01)+ "'" + CRLF 
       _cQry += "                                         AND ZRF_DTFIM >= '" +DToS(mv_par02)+ "'" + CRLF
       _cQry += "                                         AND ZRF_OPERAC = '1'  "+CRLF
       _cQry += "                                         AND RTRIM(ZRF_PRODUT) = RTRIM(Z0Y_COMP) "+CRLF
       _cQry += "                                         AND ZRF.D_E_L_E_T_ = ' ' "+CRLF
       _cQry += "    WHERE Z0Y_FILIAL = '01' "+CRLF
       _cQry += "      AND Z0Y_DATA BETWEEN '" +DToS(mv_par01)+ "' AND '" +DToS(mv_par02)+ "'"+CRLF
       _cQry += "	  AND Z0Y.D_E_L_E_T_ = ' ' "+CRLF
       _cQry += "	  AND Z0Y.Z0Y_ORIGEM IN ('P','B','V')"+CRLF
    IF !EMPTY(mv_par03)
       _cQry += " 	    AND Z0U.Z0U_CODIGO = '" + mv_par03 + "'"+CRLF
    ENDIF
       _cQry += "	  ORDER BY 1, 2, 3, 4, 5, 8,15"+CRLF
    ELSE
       _cQry := "  SELECT Z0W.Z0W_FILIAL"+CRLF
       _cQry += "       , Z0W.Z0W_DATA"+CRLF
       _cQry += " 		, Z0W.Z0W_ROTA"+CRLF
       _cQry += " 		, Z0W.Z0W_ORDEM"+CRLF
       _cQry += " 		, Z0W.Z0W_TRATO"+CRLF
       _cQry += " 		, Z0W.Z0W_RECEIT"+CRLF
       _cQry += " 		, B1R.B1_DESC"+CRLF
       _cQry += " 		, Z0W.Z0W_CURRAL"+CRLF
       _cQry += " 		, Z0W.Z0W_LOTE"+CRLF
       _cQry += "       , CASE WHEN Z0W.Z0W_KGRECA > 0 THEN Z0W.Z0W_KGRECA "+CRLF
       _cQry += " 		       ELSE Z0W.Z0W_QTDPRE "+CRLF
       _cQry += "              END AS Z0W_QTDPRE"+CRLF
       _cQry += " 		, CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG"+CRLF
       _cQry += " 		       ELSE Z0W.Z0W_QTDREA"+CRLF
       _cQry += " 			   END AS Z0W_QTDREA"+CRLF
       _cQry += " "+CRLF
       _cQry += " 		, ROUND((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG"+CRLF
       _cQry += " 		       ELSE Z0W.Z0W_QTDREA"+CRLF
       _cQry += " 			  END "+CRLF
       _cQry += " 			 -"+CRLF
       _cQry += " 			 CASE WHEN Z0W.Z0W_KGRECA > 0 THEN Z0W.Z0W_KGRECA "+CRLF
       _cQry += " 		       ELSE Z0W.Z0W_QTDPRE "+CRLF
       _cQry += " 			  END ),2) KG_DIF"+CRLF
       _cQry += " "+CRLF
       _cQry += " 		, ROUND((CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG"+CRLF
       _cQry += " 		       ELSE Z0W.Z0W_QTDREA"+CRLF
       _cQry += " 			 END "+CRLF
       _cQry += " 			 /"+CRLF
       _cQry += " 			 CASE WHEN Z0W.Z0W_KGRECA > 0 THEN Z0W.Z0W_KGRECA "+CRLF
       _cQry += " 		       ELSE Z0W.Z0W_QTDPRE "+CRLF
       _cQry += " 			  END )-1,2)*100 PERC_DIF"+CRLF
       _cQry += " 		, ISNULL(ZRF_TOLPER ,0) ZRF_TOLPER"+CRLF
       _cQry += " "+CRLF
       _cQry += " 		, Z0W_HORINI"+CRLF
       _cQry += " 		, Z0W_HORFIN"+CRLF
       _cQry += " 		, Z0X_OPERAD"+CRLF
       _cQry += " 		, Z0U_NOME"+CRLF
       _cQry += "    FROM " +RetSqlName("Z0W")+ " Z0W"+CRLF
       _cQry += " 	 JOIN " +RetSqlName("Z0X")+ " Z0X ON "+CRLF
       _cQry += " 	      Z0X.Z0X_FILIAL = Z0W.Z0W_FILIAL"+CRLF
       _cQry += " 	  AND Z0X.Z0X_CODIGO = Z0W.Z0W_CODEI"+CRLF
       _cQry += " 	  AND Z0X_OPERAC = '1'"+CRLF
       _cQry += " 	 JOIN " +RetSqlName("SB1")+ " B1R ON"+CRLF
       _cQry += " 	      B1R.B1_FILIAL = ' ' "+CRLF
       _cQry += " 	  AND B1R.B1_COD = Z0W_RECEIT"+CRLF
       _cQry += " 	  AND B1R.B1_X_TRATO = '1'"+CRLF
       _cQry += " 	  AND B1R.D_E_L_E_T_ = ' ' "+CRLF
       _cQry += " LEFT JOIN " +RetSqlName("Z0U")+ " Z0U ON "+CRLF
       _cQry += "           Z0U.Z0U_FILIAL = '01' "+CRLF
       _cQry += "       AND Z0U.Z0U_CODIGO = Z0X_OPERAD"+CRLF
       _cQry += " 	    AND Z0U.D_E_L_E_T_ = ' ' "+CRLF
       _cQry += "  LEFT JOIN " +RetSqlName("ZRF")+ " ZRF ON ZRF_DTINI <= '" +DToS(mv_par01)+ "'"+CRLF 
       _cQry += "                                       AND ZRF_DTFIM >= '" +DToS(mv_par02)+ "'"+CRLF
       _cQry += "                                       AND ZRF_OPERAC = 2 "+CRLF                                     
       _cQry += "                                       AND ZRF.D_E_L_E_T_ = ' ' "+CRLF
       _cQry += " "+CRLF
       _cQry += "     WHERE Z0W_FILIAL = '01' "+CRLF
       _cQry += "       AND Z0W_DATA BETWEEN '" +DTOS(mv_par01)+ "' AND '" +DTOS(mv_par02)+ "'"+CRLF
       _cQry += " 	    AND Z0W.D_E_L_E_T_ = ' ' "+CRLF
       _cQry += " 	    AND Z0W.Z0W_QTDPRE > 0 "+CRLF
    IF !EMPTY(mv_par03)
       _cQry += " 	    AND Z0U.Z0U_CODIGO = '" + mv_par03 + "'"+CRLF
    ENDIF
       _cQry += " 	  ORDER BY 1, 3, 5, 8"+CRLF
    ENDIF

    IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
	    MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
    ENDIF

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

RETURN !(_cAlias)->(Eof())
//fLoadSQL

STATIC FUNCTION fQuadro1()//Quadro de Carregamento
    LOCAL nRegistros    := 0
    LOCAL cXML          := ""
    LOCAL cWorkSheet    := ""

    (_cAliasC)->(DbEval({|| nRegistros++}))

    (_cAliasC) -> (DbGoTop())

    IF  !(_cAliasC)->(DbGoTop())

        cWorkSheet  := "Carregamento"

        cXML += U_prtCellXML( 'Worksheet', cWorkSheet )

	    cXML += ' <Names>'+CRLF
	    cXML += ' <NamedRange ss:Name="_FilterDatabase" '+CRLF
	    cXML += ' 	ss:RefersTo="='+cWorkSheet+'!R2C1:R'+cValToChar(nRegistros+1)+'C17"'+CRLF
	    cXML += ' 	ss:Hidden="1"/>'+CRLF
	    cXML += ' </Names>'+CRLF
        
	    cXML += '<Table>' +CRLF
        cXML += ' <Column ss:Index="2" ss:Width="56.25"/>'+CRLF
        cXML += ' <Column ss:Index="4" ss:AutoFitWidth="0" ss:Width="64.5"/>'+CRLF
        cXML += ' <Column ss:Index="6" ss:AutoFitWidth="0" ss:Width="87"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="123"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="59.25"/>'+CRLF
        cXML += ' <Column ss:Width="87.75"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="205.5"/>'+CRLF
        cXML += ' <Column ss:Width="88.5"/>'+CRLF
        cXML += ' <Column ss:Width="64.5"/>'+CRLF
        cXML += ' <Column ss:Width="79.5"/>'+CRLF
        cXML += ' <Column ss:Width="74.25"/>'+CRLF
        cXML += ' <Column ss:Width="44.25"/>'+CRLF
        cXML += ' <Column ss:Width="75"/>'+CRLF
        cXML += ' <Column ss:Width="67.5"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="81.75"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="109.5"/>'+CRLF

        cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '16'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)

        cXML += U_prtCellXML( 'Row',,'33' )
/*01*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Filial'				    ,,.T. )
/*02*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data' 			        ,,.T. )
/*03*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Rota' 	                ,,.T. )
/*04*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Ordem' 	                ,,.T. )
/*05*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Trato' 			        ,,.T. )
/*06*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Receita'		            ,,.T. )
/*07*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Descrição'			    ,,.T. )
/*08*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Origem'				    ,,.T. )
/*09*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Complemento'			    ,,.T. )
/*10*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Descrição Complemento'   ,,.T. )
/*11*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtde Prevista'		    ,,.T. )
/*12*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtde Real'			    ,,.T. )
/*13*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença KG'	        ,,.T. )
/*14*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença %'	    	    ,,.T. )
/*15*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Tolerancia %'	        ,,.T. )
/*16*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Hora Inicial'		    ,,.T. )
/*17*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Hora Final'				,,.T. )
    IF !EMPTY(mv_par03)
/*18*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Código do Operador'	    ,,.T. )/**/
/*19*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Nome do Operador'		,,.T. )/**/
	ENDIF   
        cXML += U_prtCellXML( '</Row>' )

        While !(_cAliasC)->(Eof())

	    cXML += U_prtCellXML( 'Row' )
/*01*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->Z0Y_FILIAL )          ,,.T. )	
/*02*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/,  U_FrmtVlrExcel( (_cAliasC)->Z0Y_DATA)             ,,.T. )  
/*03*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->Z0Y_ROTA )            ,,.T. )
/*04*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->Z0Y_ORDEM )           ,,.T. )
/*05*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->Z0Y_TRATO )           ,,.T. )	   
/*06*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->Z0Y_RECEIT )          ,,.T. )	   
/*07*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->DESC_REC)             ,,.T. )			
/*08*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->Z0Y_ORIGEM)           ,,.T. )			
/*09*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->Z0Y_COMP )		    ,,.T. )		
/*10*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->DESC_COMP )	        ,,.T. )		
/*11*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->Z0Y_QTDPRE )	        ,,.T. )   
/*12*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->Z0Y_QTDREA )	        ,,.T. ) 	    	
/*13*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->KG_DIF )	            ,,.T. )		       
/*14*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->PERC_DIF )	        ,,.T. )		
/*15*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->ZRF_TOLPER)		    ,,.T. )  
/*16*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/,  U_FrmtVlrExcel( (_cAliasC)->Z0Y_HORINI)  	        ,,.T. )			
/*17*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/,  U_FrmtVlrExcel( (_cAliasC)->Z0Y_HORFIN)  	        ,,.T. )
    IF !EMPTY(mv_par03)
/*18*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->Z0X_OPERAD)  	        ,,.T. )/**/		      
/*19*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)->Z0U_NOME)  			,,.T. )/**/     
    ENDIF
        cXML += U_prtCellXML( '</Row>' )

    	(_cAliasC)->(DbSkip())
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
	    
        cXML := ""
    ENDDO

        //linha média geral
        cXML += ' <Row> ' +CRLF
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'10',/*cMergeAcross*/,'s65',     'String',  /*cFormula*/,"Média Geral"                            ,,.T. )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    ,/*cMergeAcross*/,'sComDig', 'Number', "=AVERAGE(R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)",  ,,.T. )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    ,/*cMergeAcross*/,'sComDig', 'Number', "=AVERAGE(R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)",  ,,.T. )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    ,/*cMergeAcross*/,'sComDig', 'Number', "=AVERAGE(R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)",  ,,.T. )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    ,/*cMergeAcross*/,'sComDig', 'Number', "=AVERAGE(R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)",  ,,.T. )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    ,/*cMergeAcross*/,'sComDig', 'Number', "=AVERAGE(R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)",  ,,.T. )
        cXML += ' </Row> ' +CRLF  

        //fim da tabela 
        cXML += '  </Table> ' + CRLF         
        cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
        cXML += '   <PageSetup>' + CRLF
        cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
        cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
        cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
        cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
        cXML += '   </PageSetup>' + CRLF
        cXML += '   <Print>' + CRLF
        cXML += '    <ValidPrinterInfo/>' + CRLF
        cXML += '    <PaperSizeIndex>9</PaperSizeIndex>' + CRLF
        cXML += '    <HorizontalResolution>600</HorizontalResolution>' + CRLF
        cXML += '    <VerticalResolution>0</VerticalResolution>' + CRLF
        cXML += '   </Print>' + CRLF
        cXML += '   <Selected/>' + CRLF
        cXML += '   <LeftColumnVisible>6</LeftColumnVisible>' + CRLF
        cXML += '   <FreezePanes/>' + CRLF
        cXML += '   <FrozenNoSplit/>' + CRLF
        cXML += '   <SplitHorizontal>2</SplitHorizontal>' + CRLF
        cXML += '   <TopRowBottomPane>5</TopRowBottomPane>' + CRLF
        cXML += '   <ActivePane>2</ActivePane>' + CRLF
        cXML += '   <Panes>' + CRLF
        cXML += '    <Pane>' + CRLF
        cXML += '     <Number>3</Number>' + CRLF
        cXML += '     <ActiveCol>3</ActiveCol>' + CRLF
        cXML += '    </Pane>' + CRLF
        cXML += '    <Pane>' + CRLF
        cXML += '     <Number>2</Number>' + CRLF
        cXML += '     <ActiveRow>0</ActiveRow>' + CRLF
        cXML += '     <RangeSelection>R1C1:R1C19</RangeSelection>' + CRLF
        cXML += '    </Pane>' + CRLF
        cXML += '   </Panes>' + CRLF
        cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
        cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
        cXML += '  </WorksheetOptions>' + CRLF
        cXML += ' </Worksheet>' + CRLF

        If !Empty(cXML)
		    FWrite(nHandle, EncodeUTF8( cXML ) )
	    EndIf
    	cXML := ""
    ENDIF
RETURN


STATIC FUNCTION fQuadro2()//Quadro de Fornecimento
    LOCAL nRegistros    := 0
    LOCAL cXML          := ""
    LOCAL cWorkSheet    := ""

    (_cAliasF)->(DbEval({|| nRegistros++}))

    (_cAliasF) -> (DbGoTop())

    IF  !(_cAliasF)->(DbGoTop())

        cWorkSheet  := "Fornecimento"

        cXML += U_prtCellXML( 'Worksheet', cWorkSheet )

	    cXML += ' <Names>'+CRLF
	    cXML += ' <NamedRange ss:Name="_FilterDatabase" '+CRLF
	    cXML += ' 	ss:RefersTo="='+cWorkSheet+'!R2C1:R'+cValToChar(nRegistros+1)+'C17"'+CRLF
	    cXML += ' 	ss:Hidden="1"/>'+CRLF
	    cXML += ' </Names>'+CRLF
        
	    cXML += '<Table>' +CRLF
        cXML += ' <Column ss:Index="2" ss:Width="47.25"/>'+CRLF
        cXML += ' <Column ss:Index="7" ss:AutoFitWidth="0" ss:Width="87"/>'+CRLF
        cXML += ' <Column ss:Width="50.25"/>'+CRLF
        cXML += ' <Column ss:Width="55.5"/>'+CRLF
        cXML += ' <Column ss:Width="85.5"/>'+CRLF
        cXML += ' <Column ss:Width="64.5"/>'+CRLF
        cXML += ' <Column ss:Width="79.5"/>'+CRLF
        cXML += ' <Column ss:Width="74.25"/>'+CRLF
        cXML += ' <Column ss:Index="15" ss:Width="75"/>'+CRLF
        cXML += ' <Column ss:Width="67.5"/>'+CRLF
        cXML += ' <Column ss:Width="88.5"/>'+CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="110.25"/>'+CRLF

        cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '16'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)

        cXML += U_prtCellXML( 'Row',,'33' )
/*01*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Filial'				    ,,.T. )
/*02*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data' 			        ,,.T. )
/*03*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Rota' 	                ,,.T. )
/*04*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Ordem' 	                ,,.T. )
/*05*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Trato' 			        ,,.T. )
/*06*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Receita'		            ,,.T. )
/*07*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Descrição'			    ,,.T. )
/*08*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Curral'				    ,,.T. )
/*09*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Lote'				    ,,.T. )
/*10*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtde Prevista'		    ,,.T. )
/*11*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Qtde Real'			    ,,.T. )
/*12*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença KG'	        ,,.T. )
/*13*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença %'	    	    ,,.T. )
/*14*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Tolerância %'	        ,,.T. )
/*15*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Hora Inicial'		    ,,.T. )
/*16*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Hora Final'				,,.T. )
/*17*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Código do Operador'	    ,,.T. )
/*18*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Nome do Operador'		,,.T. )
	    cXML += U_prtCellXML( '</Row>' )
        
        While !(_cAliasF)->(Eof())

	    cXML += U_prtCellXML( 'Row' )
/*01*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->Z0W_FILIAL )          ,,.T. )	
/*02*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/,  U_FrmtVlrExcel( (_cAliasF)->Z0W_DATA)             ,,.T. )  
/*03*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->Z0W_ROTA )            ,,.T. )
/*04*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->Z0W_ORDEM )           ,,.T. )
/*05*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->Z0W_TRATO )           ,,.T. )	   
/*06*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->Z0W_RECEIT )          ,,.T. )	   
/*07*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->B1_DESC)              ,,.T. )			
/*08*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->Z0W_CURRAL)           ,,.T. )			
/*09*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->Z0W_LOTE )		    ,,.T. )		
/*10*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->Z0W_QTDPRE )	        ,,.T. )		
/*11*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->Z0W_QTDREA )	        ,,.T. ) 	    	
/*12*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->KG_DIF )	            ,,.T. )		       
/*13*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->PERC_DIF )	        ,,.T. )		
/*14*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->ZRF_TOLPER)		    ,,.T. )  
/*15*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/,  U_FrmtVlrExcel( (_cAliasF)->Z0W_HORINI)  	        ,,.T. )			
/*16*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/,  U_FrmtVlrExcel( (_cAliasF)->Z0W_HORFIN)  	        ,,.T. )			      
/*17*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->Z0X_OPERAD)  	        ,,.T. )			      
/*18*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasF)->Z0U_NOME)  	        ,,.T. )			      
        cXML += U_prtCellXML( '</Row>' )

    	(_cAliasF)->(DbSkip())
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
	    
        cXML := ""
    ENDDO
        //linha média geral
        cXML += ' <Row> ' +CRLF
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'9',/*cMergeAcross*/,'s65',     'String',  /*cFormula*/,"Média Geral"                             ,,.T. )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    ,/*cMergeAcross*/,'sComDig', 'Number', "=AVERAGE(R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)",  ,,.T. )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    ,/*cMergeAcross*/,'sComDig', 'Number', "=AVERAGE(R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)",  ,,.T. )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    ,/*cMergeAcross*/,'sComDig', 'Number', "=AVERAGE(R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)",  ,,.T. )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    ,/*cMergeAcross*/,'sComDig', 'Number', "=AVERAGE(R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)",  ,,.T. )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    ,/*cMergeAcross*/,'sComDig', 'Number', "=AVERAGE(R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)",  ,,.T. )
        cXML += ' </Row> ' +CRLF    
    
        //fim da tabela
        cXML += '</Table>' + CRLF          
        cXML += ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">     ' + CRLF
        cXML += '    <PageSetup>' + CRLF
        cXML += '     <Header x:Margin="0.31496062000000002"/>' + CRLF
        cXML += '     <Footer x:Margin="0.31496062000000002"/>' + CRLF
        cXML += '     <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
        cXML += '      x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
        cXML += '    </PageSetup>' + CRLF
        cXML += '    <LeftColumnVisible>1</LeftColumnVisible>' + CRLF
        cXML += '    <FreezePanes/>' + CRLF
        cXML += '    <FrozenNoSplit/>' + CRLF
        cXML += '    <SplitHorizontal>2</SplitHorizontal>' + CRLF
        cXML += '    <TopRowBottomPane>26</TopRowBottomPane>' + CRLF
        cXML += '    <ActivePane>2</ActivePane>' + CRLF
        cXML += '    <Panes>' + CRLF
        cXML += '     <Pane>' + CRLF
        cXML += '      <Number>3</Number>' + CRLF
        cXML += '     </Pane>' + CRLF
        cXML += '     <Pane>' + CRLF
        cXML += '      <Number>2</Number>' + CRLF
        cXML += '      <ActiveCol>17</ActiveCol>' + CRLF
        cXML += '     </Pane>' + CRLF
        cXML += '    </Panes>' + CRLF
        cXML += '    <ProtectObjects>False</ProtectObjects>' + CRLF
        cXML += '    <ProtectScenarios>False</ProtectScenarios>' + CRLF
        cXML += '   </WorksheetOptions>' + CRLF
        cXML += '  </Worksheet>' + CRLF
        
        If !Empty(cXML)
		    FWrite(nHandle, EncodeUTF8( cXML ) )
	    EndIf
    	cXML := ""
    ENDIF
RETURN
