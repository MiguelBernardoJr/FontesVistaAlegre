#include 'FILEIO.CH'
#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"


/*---------------------------------------------------------------------------------,
 | Analista : Igor Gomes Oliveira                                                  |
 | Data		: 05.05.2023                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatorio com Informacoes de Pedido de Compras. 				       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_IGGPER01()                                                         |
 '---------------------------------------------------------------------------------*/
User Function IGGPER01()
    Local cTimeIni	 	:= Time()
    Local cStyle		:= ""
    Local cXML	   		:= ""
    Local lTemDados		:= .T.
    Local aParambox     := {}

    Private cPerg		:= SubS(ProcName(),3) // "MBGPER01"
    Private cTitulo  	:= "Relatorio de Pedido de Compras"

    Private cPath 	 	:= "C:\totvs_relatorios\"
    Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
                                    DtoS(dDataBase)+; 
                                    "_"+;
                                    StrTran(SubS(Time(),1,5),":","")+;
                                    ".xml"
    Private oExcelApp   := nil
    Private _cAliasG	:= GetNextAlias()

    Private nHandle    	:= 0
    Private nHandAux	:= 0

    GeraX1(cPerg)
    
    If Pergunte(cPerg, .T.)
            U_PrintSX1(cPerg)
        If Len( Directory(cPath + "*.*","D") ) == 0
            If Makedir(cPath) == 0
                ConOut('Diretorio Criado com Sucesso.')
                MsgAlert('Diretorio Criado com Sucesso: ' + cPath, 'Aviso')
            Else	
                ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
                MsgAlert( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ), 'Aviso' )
            EndIf
        EndIf
        
        nHandle := FCreate(cArquivo)
        if nHandle = -1
            conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
        else
            
            cStyle := U_defStyle()
            
            // Processar SQL
            FWMsgRun(, {|| lTemDados := fLoadSql("Geral", @_cAliasG ) },'Por Favor Aguarde...' , 'Processando Banco de Dados')
            If lTemDados
            
                cXML := U_CabXMLExcel(cStyle)

                If !Empty(cXML)
                    FWrite(nHandle, EncodeUTF8( cXML ) )
                    cXML := ""
                EndIf
                
                // Gerar primeira planilha
                FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro Tabela Agrupada')
                
                // Final - encerramento do arquivo
                FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )
                
                FClose(nHandle)

                If ApOleClient("MSExcel")				//	 U_VARELM01()
                    oExcelApp := MsExcel():New()
                    oExcelApp:WorkBooks:Open( cArquivo )
                    oExcelApp:SetVisible(.T.) 	
                    oExcelApp:Destroy()	
                    // ou >  ShellExecute( "Open", cNameFile , '', '', 1 ) //Abre o arquivo na tela após salvar 
                Else
                    MsgAlert("O Excel não foi encontrado. Arquivo " + cArquivo + " gerado em " + cPath + ".", "MsExcel não encontrado" )
                EndIf
            Else
                MsgAlert("Os parametros informados não retornou nenhuma informação do banco de dados." + CRLF + ;
                        "Por isso o excel não sera aberto automaticamente.", "Dados não localizados")
            EndIf
            
            (_cAliasG)->(DbCloseArea())
            
            If lower(cUserName) $ 'mbernardo,atoshio,admin, administrador'
                Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
            EndIf
            
            ConOut('Activate: ' + Time())
        EndIf
    EndIf

Return nil

Static Function fLoadSql(cTipo, _cAlias)
    Local _cQry 		:= ""

    If cTipo == "Geral"

        _cQry := " select C1_FILIAL, CONVERT(date,C1_EMISSAO,103) C1_EMISSAO, C1_FILENT, C1_NUM, C1_ITEM, C1_PRODUTO, C1_DESCRI, C1_UM, C1_QUANT, C1_OBS, C1_SOLICIT,  C1_QUJE, C1_PEDIDO, C1_COTACAO, C1_PEDIDO, C1_FORNECE, C1_OS" + CRLF
        _cQry += "     , CASE WHEN C1_XURGENT = 'S' THEN 'SIM' ELSE 'NÃO' END URGENTE" + CRLF
        _cQry += "	 , CONVERT(DATE,C1_DATPRF,103) DATA_NECES" + CRLF
        _cQry += "	 , CASE WHEN C1_APROV = 'L' AND C1_COTACAO = ' ' AND C1_PEDIDO = ' ' THEN 'PENDENTE COTAR E COMPRAR'" + CRLF
        _cQry += "	        WHEN C1_APROV = 'L' AND C1_COTACAO <> ' ' AND C1_PEDIDO = ' ' THEN 'EM COTAÇÃO'" + CRLF
        _cQry += "			WHEN C1_APROV = 'L' AND C1_COTACAO <> ' ' AND C1_PEDIDO <> ' '  AND C1_QUJE = 0 THEN 'COM PEDIDO'" + CRLF
        _cQry += "			WHEN C1_APROV = 'B' THEN 'EM APROVAÇÃO' " + CRLF
        _cQry += "			WHEN C1_RESIDUO <> ' ' THEN 'ELIM. RESÍDUO'" + CRLF
        _cQry += "			WHEN C1_QUJE < C1_QUANT THEN 'ATENDIDO PARCIALMENTE'" + CRLF
        _cQry += "			WHEN C1_QUJE = C1_QUANT THEN 'COMPRADO'" + CRLF
        _cQry += "			END SITUACAO" + CRLF
        _cQry += "	, Y1_NOME" + CRLF
        _cQry += "    from "+RetSqlName("SC1")+" SC1" + CRLF
        _cQry += "left join "+RetSqlName("SY1")+" SY1 ON " + CRLF
        _cQry += "	     Y1_COD = C1_CODCOMP" + CRLF
        _cQry += "	 AND SY1.D_E_L_E_T_ = ' '" + CRLF
        _cQry += "   where C1_RESIDUO = ' ' and" + CRLF
        _cQry += "   C1_EMISSAO BETWEEN '"+dToS(MV_PAR01)+"' AND  '"+dToS(MV_PAR02)+"' AND " + CRLF
        _cQry += "         SC1.D_E_L_E_T_ = ' ' " + CRLF

    EndIf

    If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
        MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
    EndIf

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

Return !(_cAlias)->(Eof())

Static Function fQuadro1()

    Local nRegistros	:= 0
    Local cXML 			:= "", cPanes := ""
    Local cWorkSheet 	:= "Tabela Agrupada"

    (_cAliasG)->(DbEval({|| nRegistros++ }))

    (_cAliasG)->(DbGoTop()) 
    If !(_cAliasG)->(Eof())
        
        cXML += U_prtCellXML( 'Worksheet', cWorkSheet )
        cXML += U_prtCellXML( 'Table' )
        cXML += '    <Column ss:Width="28.5"/> '+ CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="82.5"/> '+ CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="111"/> '+ CRLF
        cXML += ' <Column ss:Width="76.5"/> '+ CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="92.25"/> '+ CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="294.75"/> '+ CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="54"/> '+ CRLF
        cXML += ' <Column ss:Width="80.25"/> '+ CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="666"/> '+ CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="77.25" ss:Span="6"/> '+ CRLF
        cXML += ' <Column ss:Index="17" ss:AutoFitWidth="0" ss:Width="71.25"/> '+ CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="84.75"/> '+ CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="59.25"/> '+ CRLF
        cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '33'/* cHeight */, /* cIndex */, '16'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)
                                
        cXML += U_prtCellXML( 'Row',,'50'/* cHeight */ )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Filial' 				) // 01
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data'                ) // 02
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Código Solicitação'  ) // 03
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Item' 			    ) // 04
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Código Produto' 		) // 05
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Descrição' 			) // 06
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Unidade' 			) // 07
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Quantidade' 			) // 08
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Observação' 			) // 09
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Solicitante' 		) // 10
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Quantidade em Pedido') // 11
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Código Pedido' 		) // 12
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Cotação'      		) // 13
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Fornecedor' 			) // 14
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Nome'     			) // 15
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Ordem de Serviço' 	) // 16
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Data Necessidade'    ) // 17
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Situação' 	        ) // 18
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Comprador'           ) // 19
        cXML += U_prtCellXML( '</Row>' )
        
        //fQuadro1
        While !(_cAliasG)->(Eof())
            
        nContLin  += 1
            cXML += U_prtCellXML( 'Row' )
            
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->C1_FILENT 	)//01
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData'          , 'DateTime', /*cFormula*/, (_cAliasG)->C1_EMISSAO  )//02
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->C1_NUM      )//03
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->C1_ITEM     )//04
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->C1_PRODUTO  )//05
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->C1_DESCRI	)//06
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->C1_UM       )//07
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->C1_QUANT	)//08
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->C1_OBS      )//09
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->C1_SOLICIT  )//10
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->C1_QUJE 	)//11
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->C1_PEDIDO 	)//12
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->C1_COTACAO 	)//13
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->C1_FORNECE 	)//14
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, Posicione("SA2",1,FWxFilial("SA2")+(_cAliasG)->C1_FORNECE,"A2_NOME" ))//15
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->C1_OS 		)//16
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData'          , 'DateTime', /*cFormula*/, (_cAliasG)->DATA_NECES 	)//17
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->SITUACAO 	)//18
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->Y1_NOME 	)//19
            
            cXML += U_prtCellXML( '</Row>' )

            (_cAliasG)->(DbSkip())
        enddo 

        cPanes += "       <Unsynced/> " + CRLF
        cPanes += "   <Print> " + CRLF
        cPanes += "    <ValidPrinterInfo/> " + CRLF
        cPanes += "    <PaperSizeIndex>9</PaperSizeIndex> " + CRLF
        cPanes += "    <VerticalResolution>0</VerticalResolution> " + CRLF
        cPanes += "   </Print> " + CRLF
        cPanes += "   <Selected/> " + CRLF
        cPanes += "   <TopRowVisible>68</TopRowVisible> " + CRLF
        cPanes += "   <Panes> " + CRLF
        cPanes += "    <Pane> " + CRLF
        cPanes += "     <Number>3</Number> " + CRLF
        cPanes += "     <ActiveRow>80</ActiveRow> " + CRLF
        cPanes += "     <ActiveCol>8</ActiveCol> " + CRLF
        cPanes += "    </Pane> " + CRLF
        cPanes += "   </Panes> " + CRLF

        cXML += U_prtCellXML( 'WorksheetOptions'/* cTag */, /* cName */, /* cHeight */, /* cIndex */, /* cMergeAcross */, ;
                    /* cStyleID */, /* cType */, /* cFormula */, /* cInfo */, /* cPanes */ cPanes )
        
        If !Empty(cXML)
            FWrite(nHandle, EncodeUTF8( cXML ) )
        EndIf
        cXML := ""
        
    EndIf	

Return nil
// fQuadro1

Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local aRegs		:= {}
Local i, j

//Conta quantas perguntas existem ualmente.
DbSelectArea('SX1')
DbSetOrder(1)
SX1->(DbGoTop())
If SX1->(DbSeek(cPerg))
	While !SX1->(Eof()) .And. X1_GRUPO = cPerg
		nPergs++
		SX1->(DbSkip())
	EndDo
EndIf

aAdd(aRegs,{cPerg, "01", "Data de" , "", "", "MV_CH1", "D", 8, 0, 0, "G", "", "MV_PAR01", "", "", "", "", "", "","","","","","","","","","","","","","","","","","","","","U","","","",""})
aAdd(aRegs,{cPerg, "02", "Data até", "", "", "MV_CH2", "D", 8, 0, 0, "G", "", "MV_PAR02", "", "", "", "", "", "","","","","","","","","","","","","","","","","","","","","U","","","",""})

//Se quantidade de perguntas for diferente, apago todas
SX1->(DbGoTop())
If nPergs <> Len(aRegs)
	For nX:=1 To nPergs
		If SX1->(DbSeek(cPerg))
			If RecLock('SX1',.F.)
				SX1->(DbDelete())
				SX1->(MsUnlock())
			EndIf
		EndIf
	Next nX
EndIf

// gravação das perguntas na tabela SX1
If nPergs <> Len(aRegs)
	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
				For j := 1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next j
			MsUnlock()
		EndIf
	Next i
EndIf

RestArea(_aArea)

Return nil
