#include 'FILEIO.CH'
#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"


/*---------------------------------------------------------------------------------,
 | Analista : Igor Gomes Oliveira                                                  |
 | Data		: 05.05.2023                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatorio TAF.                                                       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_VAGPER03()                                                         |
 '---------------------------------------------------------------------------------*/
User Function VAGPER03()
    Local cTimeIni	 	:= Time()
    Local cStyle		:= ""
    Local cXML	   		:= ""
    Local lTemDados		:= .T.

    Private cPerg		:= SubS(ProcName(),3)
    Private cTitulo  	:= "Relatorio de Apuração da Folha de Pagamento"

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

Static Function fQuadro1()

    Local nRegistros	:= 0
    Local cXML 			:= "", cPanes := ""
    Local cWorkSheet 	:= "Tabela Agrupada"
    Local nBasFer, nDescFer, nDifBMes
    //Local cCorFun2 
    
    (_cAliasG)->(DbEval({|| nRegistros++ }))

    (_cAliasG)->(DbGoTop()) 
    If !(_cAliasG)->(Eof())
        
        cXML += U_prtCellXML( 'Worksheet', cWorkSheet )
        cXML += U_prtCellXML( 'Table' )
        cXML += '   <Column ss:Width="42"/> ' + CRLF
        cXML += '   <Column ss:Index="3" ss:Width="190.5"/> ' + CRLF
        cXML += '   <Column ss:Width="71.25"/> ' + CRLF
        cXML += '   <Column ss:Width="36.75"/> ' + CRLF
        cXML += '   <Column ss:Width="161.25"/> ' + CRLF
        cXML += '   <Column ss:AutoFitWidth="0" ss:Width="54"/> ' + CRLF
        cXML += '   <Column ss:Width="51.75" ss:Span="1"/> ' + CRLF
        cXML += '   <Column ss:Index="10" ss:Width="72"/> ' + CRLF
        cXML += '   <Column ss:AutoFitWidth="0" ss:Width="77.25"/> ' + CRLF
        cXML += '   <Column ss:Width="70.5"/> ' + CRLF
        cXML += '   <Column ss:Width="72"/> ' + CRLF
        cXML += '   <Column ss:AutoFitWidth="0" ss:Width="77.25"/> ' + CRLF
        cXML += '   <Column ss:Width="78.75"/> ' + CRLF
        cXML += '   <Column ss:Width="70.5"/> ' + CRLF
        cXML += '   <Column ss:Width="69.75"/> ' + CRLF
        cXML += '   <Column ss:Width="64.5"/> ' + CRLF
        cXML += '   <Column ss:Width="54" ss:Span="1"/> ' + CRLF
        cXML += '   <Column ss:Index="21" ss:Width="40.5"/> ' + CRLF
        cXML += '   <Column ss:Width="48.75"/> ' + CRLF
        cXML += '   <Column ss:Width="54"/> ' + CRLF
        cXML += '   <Column ss:Width="48.75" ss:Span="2"/> ' + CRLF
        cXML += '   <Column ss:Index="27" ss:Width="54"/> ' + CRLF
        cXML += '   <Column ss:Width="48.75"/> ' + CRLF
        cXML += '   <Column ss:Width="54"/> ' + CRLF
        cXML += '   <Column ss:Width="48.75"/> ' + CRLF
        cXML += '   <Column ss:Width="54"/> ' + CRLF
        cXML += '   <Column ss:Width="48.75"/> ' + CRLF
        cXML += '   <Column ss:Width="54"/> ' + CRLF
        cXML += '   <Column ss:Width="48.75"/> ' + CRLF
        cXML += '   <Column ss:Width="61.5"/> ' + CRLF
        cXML += '   <Column ss:Width="48.75"/> ' + CRLF
        cXML += '   <Column ss:Width="61.5"/> ' + CRLF
        cXML += '   <Column ss:Width="48.75"/> ' + CRLF
        cXML += '   <Column ss:Width="61.5"/> ' + CRLF
        cXML += '   <Column ss:Width="54"/> ' + CRLF
        cXML += '   <Column ss:Width="48.75"/> ' + CRLF
        cXML += '   <Column ss:Width="54" ss:Span="1"/> ' + CRLF
        cXML += '   <Column ss:Index="44" ss:Width="48.75"/> ' + CRLF
        cXML += '   <Column ss:Width="54" ss:Span="3"/> ' + CRLF
        cXML += '   <Column ss:Index="49" ss:Width="61.5"/> ' + CRLF

        cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '33'/* cHeight */, /* cIndex */, '7'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)
        cXML += U_prtCellXML( 'Row',,'50'/* cHeight */ )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Filial' 				                ) // 01
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Matrícula'                           ) // 02
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Nome'                                ) // 03
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CPF' 			                    ) // 04
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'ID TAF' 		                        ) // 05
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Matrícula TAF' 		                ) // 06
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'PIS' 			                    ) // 07
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Situação'    	                    ) // 08
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Admissão' 			                ) // 09
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Demissão' 			                ) // 10

        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'FOL- Base IRRF Mes' 		            ) // 11
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TAF- Base IRRF Mes'                  ) // 12
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dif. Base IRRF Mensal' 		        ) // 13
        
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'FOL- Base IRRF 13 Sal'      	        ) // 14
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TAF- Base IRRF 13 Sal' 		        ) // 15
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dif. Base IRRF 13'     	            ) // 16

        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'FOL-Ret. IRRF Mensal' 	            ) // 17
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TAF-Ret. IRRF Mensal'                ) // 18
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dif. Ret. IRRF Mensal' 	            ) // 19

        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'FOL-Ret. IRRF 13'                    ) // 20
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TAF-Ret. IRRF 13'                    ) // 21
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Dif. Ret. IRRF 13'                   ) // 22
        
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Folha Deduzido'                      ) // 23
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TAF Deduzido'                        ) // 24
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Folha Deduzido 13º'                  ) // 25
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TAF Deduzido 13º'                    ) // 26
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Folha Deduzido IRF'                  ) // 27
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TAF Deduzido IRF'                    ) // 28
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Folha Deduzido Dependentes'          ) // 29
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TAF Deduzido Dependentes'            ) // 30
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Folha 13º Deduzido Dependentes'      ) // 31
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TAF 13º Deduzido Dependentes'        ) // 32
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Folha IRF Deduzido Dependentes'      ) // 33
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'TAF IRF Deduzido Dependentes'        ) // 34
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Total Retido em Folha'               ) // 35
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Total Retido TAF'                    ) // 36
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença Base'                      ) // 37
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença Base 13º'                  ) // 38
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença Base IRF'                  ) // 39
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença Retido'                    ) // 40
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença Retido 13º'                ) // 41
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença IRRF'                      ) // 42
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença Folha Dependentes'         ) // 43
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença 13º Dependentes'           ) // 44
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença Deduzido Dependentes'      ) // 45
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença 13º Deduzido Dependentes'  ) // 46
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença IRF Deduzido Dependentes'  ) // 47
        //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'Diferença Total'                     ) // 48
        cXML += U_prtCellXML( '</Row>' )
        
        //fQuadro1
        While !(_cAliasG)->(Eof())
                
            nBasFer := 0
            nBasFer := fBuscaFer((_cAliasG)->FILIAL,(_cAliasG)->MAT_FOLHA,'1')
            
            nDescFer := fBuscaFer((_cAliasG)->FILIAL,(_cAliasG)->MAT_FOLHA,'2')
            
            cXML += U_prtCellXML( 'Row' )
            
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->FILIAL 	        )//01
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->MAT_FOLHA       )//02
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->NOME            )//03
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, Alltrim(Transform((_cAliasG)->CPF, "@R 999.999.999-99")))//04
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->ID_TAF          )//05
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->MAT_TAF         )//06
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, (_cAliasG)->SITUACAO	    )//08
        if !EMPTY((_cAliasG)->ADMISSAO)
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData'          , 'DateTime', /*cFormula*/, sToD((_cAliasG)->ADMISSAO)  )//09
        else
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData'          , 'DateTime', /*cFormula*/, ''                          )//09
        endif 
        if !EMPTY((_cAliasG)->DEMISSAO)
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sData'          , 'DateTime', /*cFormula*/, sToD((_cAliasG)->DEMISSAO)  )//10
        else
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'         , 'String'  , /*cFormula*/, ''                          )//10
        endif 
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->FOLBASEME + nBasFer	)//11
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->TAFBASEME 	        )//12

            nDifBMes := 0
            nDifBMes :=  ((_cAliasG)->FOLBASEME	+ nBasFer) - (_cAliasG)->TAFBASEME
            if nDifBMes > 0.03 .or. nDifBMes < -0.03
                cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'         , 'Number'  , /*cFormula*/, nDifBMes 	                    )//13
			else 
                cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'       , 'Number'  , /*cFormula*/, nDifBMes 	                    )//13
            endif

            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'         , 'Number'  , /*cFormula*/, (_cAliasG)->FOLBASE13 	    )//14
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'         , 'Number'  , /*cFormula*/, (_cAliasG)->TAFBASE13 	    )//15

            nDifB13 := 0
			nDifB13 :=  (_cAliasG)->FOLBASE13 - (_cAliasG)->TAFBASE13
            if nDifB13 > 0.03 .or. nDifB13 < -0.03
                cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'         , 'Number'  , /*cFormula*/, nDifB13    )//16
            else 
                cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'       , 'Number'  , /*cFormula*/, nDifB13    )//16
            endif 

            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->FOLRETME + nDescFer )//17
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->TAFRETME 	        )//18

            nDifRMes := 0
            nDifRMes :=  ((_cAliasG)->FOLRETME + nDescFer) - (_cAliasG)->TAFRETME
            if nDifRMes > 0.03 .or. nDifRMes < -0.03
                cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, nDifRMes    )//19
            else 
                cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, nDifRMes    )//19
            endif 

            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->FOLRET13 	    )//20
            cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->TAFRET13 	    )//21
    
            nDifR13 := 0
            nDifR13 :=  (_cAliasG)->FOLRET13 - (_cAliasG)->TAFRET13	
            if nDifR13 > 0.03 .or. nDifR13 < -0.03 
                cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, nDifR13   )//22
            else 
                cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'        , 'Number'  , /*cFormula*/, nDifR13   )//22
            endif 

            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->FOLDEDME 	    )//23
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->TAFDEDME 	    )//24
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->FOLDED13 	    )//25
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->TAFDED13 	    )//26
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->FOLDEDFE 	    )//27
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->TAFDEDFE 	    )//28
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->FOLDEDDEME 	    )//29
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->TAFDEDDEME 	    )//30
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->FOLDEDDE13 	    )//31
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->TAFDEDDE13 	    )//32
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->FOLDEDDEFE 	    )//33
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->TAFDEDDEFE 	    )//34
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->FOLRETTOT 	    )//35
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->TAFRETTOT 	    )//36
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->DIFBASEME 	    )//37
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->DIFBASE13 	    )//38
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->DIFBASEFE 	    )//39
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->DIFRETME 	    )//40
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->DIFRET13 	    )//41
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->DIFRETFE 	    )//42
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->DIFDEDME 	    )//43
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->DIFDEDFE 	    )//45
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->DIFDEDDEME 	    )//46
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->DIFDEDDE13 	    )//47
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->DIFDEDDEFE 	    )//48
            //cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sReal'          , 'Number'  , /*cFormula*/, (_cAliasG)->DIFIRTOT 	    )//49
            
            cXML += U_prtCellXML( '</Row>' )

            (_cAliasG)->(DbSkip())
        enddo 

        cPanes += "       <Unsynced/> " + CRLF
        cPanes += "   <Print> " + CRLF
        cPanes += "    <ValidPrinterInfo/> " + CRLF
        cPanes += "    <PaperSizeIndex>9</PaperSizeIndex> " + CRLF
        cPanes += "    <VerticalResolution>0</VerticalResolution> " + CRLF
        cPanes += "   </Print> " + CRLF
        cPanes += "   <Zoom>85</Zoom> " + CRLF
        cPanes += "   <Selected/> " + CRLF
        cPanes += "   <FreezePanes/> " + CRLF
        cPanes += "   <FrozenNoSplit/> " + CRLF
        cPanes += "   <SplitHorizontal>1</SplitHorizontal> " + CRLF
        cPanes += "   <TopRowBottomPane>1</TopRowBottomPane> " + CRLF
        cPanes += "   <SplitVertical>8</SplitVertical> " + CRLF
        cPanes += "   <LeftColumnRightPane>8</LeftColumnRightPane> " + CRLF
        cPanes += "   <ActivePane>0</ActivePane> " + CRLF
        cPanes += "   <Panes> " + CRLF
        cPanes += "    <Pane> " + CRLF
        cPanes += "     <Number>3</Number> " + CRLF
        cPanes += "    </Pane> " + CRLF
        cPanes += "    <Pane> " + CRLF
        cPanes += "     <Number>1</Number> " + CRLF
        cPanes += "    </Pane> " + CRLF
        cPanes += "    <Pane> " + CRLF
        cPanes += "     <Number>2</Number> " + CRLF
        cPanes += "    </Pane> " + CRLF
        cPanes += "    <Pane> " + CRLF
        cPanes += "     <Number>0</Number> " + CRLF
        cPanes += "     <ActiveRow>0</ActiveRow> " + CRLF
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
Static Function fLoadSql(cTipo, _cAliasG)
    Local _cQry 		:= ""

    MV_PAR07 := Upper(MV_PAR07)
    MV_PAR05 := Alltrim(MV_PAR05)
    if Empty(MV_PAR05)
        MV_PAR05 := AllTrim(GetTempPath())
    endif
    if MV_PAR07 == '132' 
        cPerTaf	:= substr(MV_PAR05,1,4)
    else
        cPerTaf	:= MV_PAR05
    endif	

    If cTipo == "Geral"

        _cQry	:= " SELECT " + CRLF
        _cQry	+= "        X.FILIAL, "+ CRLF
        _cQry	+= "        X.MAT_FOLHA, "+ CRLF
        _cQry	+= "        X.NOME, "+ CRLF
        _cQry	+= "        X.CPF, "+ CRLF
        _cQry	+= "        X.ID_TAF, "+ CRLF
        _cQry	+= "        X.MAT_TAF, "+ CRLF
        _cQry	+= "        x.PIS, "+ CRLF
        _cQry	+= "        X.SITUACAO, "+ CRLF
        _cQry	+= "        X.ADMISSAO, "+ CRLF
        _cQry	+= "        X.DEMISSAO, "  + CRLF
        _cQry	+= "        (X.FOL_BASE_IRME + X.FOL_DED_IRME) FOLBASEME, "+ CRLF
        _cQry	+= "        X.TAF_BASE_IRME TAFBASEME, "+ CRLF
        _cQry	+= "        (X.FOL_BASE_IR13 + X.FOL_DED_IR13) FOLBASE13, "+ CRLF
        _cQry	+= "        X.TAF_BASE_IR13 TAFBASE13, "+ CRLF
        _cQry	+= "        (X.FOL_BASE_IRFE + X.FOL_DED_IRFE) FOLBASEFE, "+ CRLF
        _cQry	+= "        X.TAF_BASE_IRFE TAFBASEFE, "+ CRLF
        _cQry	+= "        X.FOL_RET_IRME FOLRETME, "+ CRLF
        _cQry	+= "        X.TAF_RET_IRME TAFRETME, "+ CRLF
        _cQry	+= "        X.FOL_RET_IR13 FOLRET13, "+ CRLF
        _cQry	+= "        X.TAF_RET_IR13 TAFRET13, "+ CRLF
        _cQry	+= "        X.FOL_RET_IRFE FOLRETFE, "+ CRLF
        _cQry	+= "        X.TAF_RET_IRFE TAFRETFE, "+ CRLF
        _cQry	+= "        X.FOL_DED_IRME FOLDEDME, "+ CRLF
        _cQry	+= "        X.TAF_DED_IRME TAFDEDME, "+ CRLF
        _cQry	+= "        X.FOL_DED_IR13 FOLDED13, "+ CRLF
        _cQry	+= "        X.TAF_DED_IR13 TAFDED13, "+ CRLF
        _cQry	+= "        X.FOL_DED_IRFE FOLDEDFE, "+ CRLF
        _cQry	+= "        X.TAF_DED_IRFE TAFDEDFE, "+ CRLF
        _cQry	+= "        X.FOL_DED_DEPIRME FOLDEDDEME, "+ CRLF
        _cQry	+= "        X.TAF_DED_DEPIRME TAFDEDDEME, "+ CRLF
        _cQry	+= "        X.FOL_DED_DEPIR13 FOLDEDDE13, "+ CRLF
        _cQry	+= "        X.TAF_DED_DEPIR13 TAFDEDDE13, "+ CRLF
        _cQry	+= "        X.FOL_DED_DEPIRFE FOLDEDDEFE, "+ CRLF
        _cQry	+= "        X.TAF_DED_DEPIRFE TAFDEDDEFE, "+ CRLF
        _cQry	+= "        X.FOL_RET_IRTOT FOLRETTOT, "+ CRLF
        _cQry	+= "        X.TAF_RET_IRTOT TAFRETTOT, "+ CRLF
        _cQry	+= " 	    (X.FOL_BASE_IRME + X.FOL_DED_IRME) - X.TAF_BASE_IRME DIFBASEME, "+ CRLF
        _cQry	+= " 	    (X.FOL_BASE_IR13 + X.FOL_DED_IR13) - X.TAF_BASE_IR13 DIFBASE13, "+ CRLF
        _cQry	+= " 	    (X.FOL_BASE_IRFE + X.FOL_DED_IRFE) - X.TAF_BASE_IRFE DIFBASEFE, "+ CRLF
        _cQry	+= " 	    X.FOL_RET_IRME - X.TAF_RET_IRME DIFRETME, "+ CRLF
        _cQry	+= " 	    X.FOL_RET_IR13 - X.TAF_RET_IR13 DIFRET13, "+ CRLF
        _cQry	+= " 	    X.FOL_RET_IRFE - X.TAF_RET_IRFE DIFRETFE, "+ CRLF
        _cQry	+= " 	    X.FOL_DED_IRME - X.TAF_DED_IRME DIFDEDME, "+ CRLF
        _cQry	+= " 	    X.FOL_DED_IR13 - X.TAF_DED_IR13 DIFDED13, "+ CRLF
        _cQry	+= " 	    X.FOL_DED_IRFE - X.TAF_DED_IRFE DIFDEDFE, "+ CRLF
        _cQry	+= " 	    X.FOL_DED_DEPIRME - X.TAF_DED_DEPIRME DIFDEDDEME, "+ CRLF
        _cQry	+= " 	    X.FOL_DED_DEPIR13 - X.TAF_DED_DEPIR13 DIFDEDDE13, "+ CRLF
        _cQry	+= " 	    X.FOL_DED_DEPIRFE - X.TAF_DED_DEPIRFE DIFDEDDEFE, "+ CRLF
        _cQry	+= " 	    X.FOL_RET_IRTOT - X.TAF_RET_IRTOT DIFIRTOT "	   + CRLF
        _cQry	+= " FROM ( "+ CRLF
        _cQry	+= " SELECT "     + CRLF
        _cQry	+= "        SRA.RA_FILIAL FILIAL, " + CRLF
        _cQry	+= "        SRA.RA_MAT MAT_FOLHA, "+ CRLF
        _cQry	+= "        SRA.RA_NOME NOME, "+ CRLF
        _cQry	+= "        SRA.RA_CIC CPF, "+ CRLF
        _cQry	+= "        SRA.RA_PIS PIS, "+ CRLF
        _cQry	+= "        (CASE " + CRLF
        _cQry	+= "           WHEN SRA.RA_PROCES = '00003' "+ CRLF
        _cQry	+= "              THEN "   + CRLF
        _cQry	+= "                (select MAX(C9V.C9V_ID) " + CRLF
        _cQry	+= "                 FROM "+RetSqlName("C9V")+"  C9V "+ CRLF
        _cQry	+= "                 WHERE C9V.C9V_FILIAL = SRA.ra_filial "+ CRLF
        _cQry	+= "                  AND C9V.C9V_CPF = SRA.RA_CIC "+ CRLF
        _cQry	+= "                  AND C9V.C9V_ATIVO = '1' "+ CRLF
        _cQry	+= "                  AND C9V.C9V_STATUS = '4' "  + CRLF
        _cQry	+= "                  AND C9V.D_E_L_E_T_ <> '*')  "+ CRLF
        _cQry	+= "           ELSE "+ CRLF
        _cQry	+= "                (select MAX(C9V.C9V_ID) " + CRLF
        _cQry	+= "                 FROM "+RetSqlName("C9V")+"  C9V "+ CRLF
        _cQry	+= "                 WHERE C9V.C9V_FILIAL = SRA.ra_filial "+ CRLF
        _cQry	+= "                  AND C9V.C9V_MATRIC = SRA.RA_CODUNIC "+ CRLF
        _cQry	+= "                  AND C9V.C9V_ATIVO = '1' "+ CRLF
        _cQry	+= "                  AND C9V.C9V_STATUS = '4' "  + CRLF
        _cQry	+= "                  AND C9V.D_E_L_E_T_ <> '*')  "+ CRLF
        _cQry	+= "        END ) ID_TAF, " + CRLF
        _cQry	+= "        SRA.RA_CODUNIC MAT_TAF, "+ CRLF
        _cQry	+= "        (CASE " + CRLF
        _cQry	+= "             WHEN SRA.RA_SITFOLH = '' "+ CRLF
        _cQry	+= "              THEN 'ATIVO' "+ CRLF
        _cQry	+= "             WHEN SRA.RA_SITFOLH = 'D' OR (SRA.RA_DEMISSA <= CONVERT(VARCHAR(8),GETDATE(),112) AND SRA.RA_DEMISSA <> '') "+ CRLF
        _cQry	+= "              THEN 'DEMITIDO' "+ CRLF
        _cQry	+= "             WHEN SRA.RA_SITFOLH = 'A' " + CRLF
        _cQry	+= "              THEN 'AFASTADO' "           + CRLF
        _cQry	+= "             WHEN SRA.RA_SITFOLH = 'F' " + CRLF
        _cQry	+= "              THEN 'FERIAS' " + CRLF
        _cQry	+= "             ELSE SRA.RA_SITFOLH "          + CRLF
        _cQry	+= "         END) SITUACAO, "+ CRLF
        _cQry	+= "         SRA.RA_ADMISSA ADMISSAO, "+ CRLF
        _cQry	+= "         SRA.RA_DEMISSA DEMISSAO, " + CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRC.RC_DATA   BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD "  + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0015','0016') " + CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "         AND SRC.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "        ),0) FOL_BASE_IRME, "   + CRLF
        _cQry	+= "        ISNULL( " + CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) " + CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I "  + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL " + CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO " + CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID "  + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U "  + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '11' "  + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) " + CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
        _cQry	+= "          ),0) TAF_BASE_IRME, " + CRLF
        _cQry	+= "       ISNULL( " + CRLF
        _cQry	+= "       (SELECT SUM(SRC.RC_VALOR) "  + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA "  + CRLF
        _cQry	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL " + CRLF
        _cQry	+= "         AND SRC.RC_MAT = RA.RA_MAT " + CRLF
        _cQry	+= "         AND SRC.RC_DATA   BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' " + CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD "  + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0027') " + CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "         AND SRC.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "        ),0) FOL_BASE_IR13, "   + CRLF
        _cQry	+= "        ISNULL( " + CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) " + CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I "  + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL " + CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO " + CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID "  + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U "  + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '12' "  + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) " + CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
        _cQry	+= "          ),0) TAF_BASE_IR13, " + CRLF
        _cQry	+= "       ISNULL( " + CRLF
        _cQry	+= "       (SELECT SUM(SRC.RC_VALOR) "  + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA "  + CRLF
        _cQry	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL " + CRLF
        _cQry	+= "         AND SRC.RC_MAT = RA.RA_MAT " + CRLF
        _cQry	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' " + CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0016','1562') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_BASE_IRFE, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '13' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_BASE_IRFE, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0066') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_RET_IRME, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '31' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_RET_IRME, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0071') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_RET_IR13, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '32' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_RET_IR13, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD "  + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0067') " + CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "         AND SRC.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "        ),0) FOL_RET_IRFE, "   + CRLF
        _cQry	+= "        ISNULL( " + CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) " + CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I "  + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL " + CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO " + CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID "  + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U "  + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '33' "  + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) " + CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
        _cQry	+= "          ),0) TAF_RET_IRFE, " + CRLF
        _cQry	+= "       ISNULL( " + CRLF
        _cQry	+= "       (SELECT SUM(SRC.RC_VALOR) "  + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA "  + CRLF
        _cQry	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL " + CRLF
        _cQry	+= "         AND SRC.RC_MAT = RA.RA_MAT " + CRLF
        _cQry	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' " + CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0064') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_DED_IRME, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '41' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_DED_IRME, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0070') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_DED_IR13, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '42' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_DED_IR13, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0065') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_DED_IRFE, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '43' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_DED_IRFE, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0059') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_DED_DEPIRME, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '56' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_DED_DEPIRME, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0062') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_DED_DEPIR13, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '57' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_DED_DEPIR13, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0061','0062') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_DED_DEPIRFE, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '58' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_DED_DEPIRFE, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132' 
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' "+ CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                           					  WHERE SRV.RV_CODFOL IN ('0066','0071','0067') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_RET_IRTOT, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2J.T2J_VLDESC) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2J")+"  T2J " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2J.T2J_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2J.T2J_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2J.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2J.T2J_CTPCR IN (SELECT C6R_ID "+ CRLF
        _cQry	+= "                                FROM "+RetSqlName("C6R")+"  C6R " + CRLF
        _cQry	+= "                                WHERE C6R.C6R_CODIGO = '999999' " + CRLF
        _cQry	+= "                                 AND C6R.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_RET_IRTOT "+ CRLF
        _cQry	+= " FROM  "+RetSqlName("SRA")+"  SRA "+ CRLF
        _cQry	+= " WHERE SRA.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "  AND EXISTS "+ CRLF
        _cQry	+= "  (SELECT * "+ CRLF
        _cQry	+= "   FROM  "+RetSqlName("SRC")+"  SRC "+ CRLF
        _cQry	+= "   WHERE SRC.RC_FILIAL = SRA.RA_FILIAL "+ CRLF
        _cQry	+= "    AND SRC.RC_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "    AND SRC.RC_PERIODO = '"+MV_PAR05+"' "+ CRLF
        if MV_PAR07 == '132' 
            _cQry	+= "         AND SRC.RC_ROTEIR  = '132' "+ CRLF
        else
            _cQry	+= "         AND SRC.RC_ROTEIR IN ('AUT','FOL') "+ CRLF
        endif
        _cQry	+= "    AND SRC.D_E_L_E_T_ <> '*' ) " + CRLF
        _cQry	+= " ) X   "+ CRLF

        _cQry	+= "UNION ALL   "+ CRLF

        _cQry	+= " SELECT " + CRLF
        _cQry	+= "        X.FILIAL, " + CRLF
        _cQry	+= "        X.MAT_FOLHA, " + CRLF
        _cQry	+= "        X.NOME, " + CRLF
        _cQry	+= "        X.CPF, " + CRLF
        _cQry	+= "        X.ID_TAF, " + CRLF
        _cQry	+= "        X.MAT_TAF, " + CRLF
        _cQry	+= "        x.PIS, " + CRLF
        _cQry	+= "        X.SITUACAO, " + CRLF
        _cQry	+= "        X.ADMISSAO, " + CRLF
        _cQry	+= "        X.DEMISSAO, "   + CRLF
        _cQry	+= "        (X.FOL_BASE_IRME + X.FOL_DED_IRME) FOLBASEME, " + CRLF
        _cQry	+= "        X.TAF_BASE_IRME TAFBASEME, " + CRLF
        _cQry	+= "        (X.FOL_BASE_IR13 + X.FOL_DED_IR13) FOLBASE13, " + CRLF
        _cQry	+= "        X.TAF_BASE_IR13 TAFBASE13, " + CRLF
        _cQry	+= "        (X.FOL_BASE_IRFE + X.FOL_DED_IRFE) FOLBASEFE, " + CRLF
        _cQry	+= "        X.TAF_BASE_IRFE TAFBASEFE, " + CRLF
        _cQry	+= "        X.FOL_RET_IRME FOLRETME, " + CRLF
        _cQry	+= "        X.TAF_RET_IRME TAFRETME, " + CRLF
        _cQry	+= "        X.FOL_RET_IR13 FOLRET13, " + CRLF
        _cQry	+= "        X.TAF_RET_IR13 TAFRET13, " + CRLF
        _cQry	+= "        X.FOL_RET_IRFE FOLRETFE, " + CRLF
        _cQry	+= "        X.TAF_RET_IRFE TAFRETFE, " + CRLF
        _cQry	+= "        X.FOL_DED_IRME FOLDEDME, "+ CRLF
        _cQry	+= "        X.TAF_DED_IRME TAFDEDME, "+ CRLF
        _cQry	+= "        X.FOL_DED_IR13 FOLDED13, "+ CRLF
        _cQry	+= "        X.TAF_DED_IR13 TAFDED13, "+ CRLF
        _cQry	+= "        X.FOL_DED_IRFE FOLDEDFE, "+ CRLF
        _cQry	+= "        X.TAF_DED_IRFE TAFDEDFE, "+ CRLF
        _cQry	+= "        X.FOL_DED_DEPIRME FOLDEDDEME, "+ CRLF
        _cQry	+= "        X.TAF_DED_DEPIRME TAFDEDDEME, "+ CRLF
        _cQry	+= "        X.FOL_DED_DEPIR13 FOLDEDDE13, "+ CRLF
        _cQry	+= "        X.TAF_DED_DEPIR13 TAFDEDDE13, "+ CRLF
        _cQry	+= "        X.FOL_DED_DEPIRFE FOLDEDDEFE, "+ CRLF
        _cQry	+= "        X.TAF_DED_DEPIRFE TAFDEDDEFE, "+ CRLF
        _cQry	+= "        X.FOL_RET_IRTOT FOLRETTOT, "+ CRLF
        _cQry	+= "        X.TAF_RET_IRTOT TAFRETTOT, "+ CRLF
        _cQry	+= " 	    (X.FOL_BASE_IRME + X.FOL_DED_IRME) - X.TAF_BASE_IRME DIFBASEME, "+ CRLF
        _cQry	+= " 	    (X.FOL_BASE_IR13 + X.FOL_DED_IR13) - X.TAF_BASE_IR13 DIFBASE13, "+ CRLF
        _cQry	+= " 	    (X.FOL_BASE_IRFE + X.FOL_DED_IRFE) - X.TAF_BASE_IRFE DIFBASEFE, "+ CRLF
        _cQry	+= " 	    X.FOL_RET_IRME - X.TAF_RET_IRME DIFRETME, "+ CRLF
        _cQry	+= " 	    X.FOL_RET_IR13 - X.TAF_RET_IR13 DIFRET13, "+ CRLF
        _cQry	+= " 	    X.FOL_RET_IRFE - X.TAF_RET_IRFE DIFRETFE, "+ CRLF
        _cQry	+= " 	    X.FOL_DED_IRME - X.TAF_DED_IRME DIFDEDME, "+ CRLF
        _cQry	+= " 	    X.FOL_DED_IR13 - X.TAF_DED_IR13 DIFDED13, "+ CRLF
        _cQry	+= " 	    X.FOL_DED_IRFE - X.TAF_DED_IRFE DIFDEDFE, "+ CRLF
        _cQry	+= " 	    X.FOL_DED_DEPIRME - X.TAF_DED_DEPIRME DIFDEDDEME, "+ CRLF
        _cQry	+= " 	    X.FOL_DED_DEPIR13 - X.TAF_DED_DEPIR13 DIFDEDDE13, "+ CRLF
        _cQry	+= " 	    X.FOL_DED_DEPIRFE - X.TAF_DED_DEPIRFE DIFDEDDEFE, "+ CRLF
        _cQry	+= " 	    X.FOL_RET_IRTOT - X.TAF_RET_IRTOT DIFIRTOT "	   + CRLF
        _cQry	+= " FROM ( "+ CRLF
        _cQry	+= " SELECT "     + CRLF
        _cQry	+= "        SRA.RA_FILIAL FILIAL, " + CRLF
        _cQry	+= "        SRA.RA_MAT MAT_FOLHA, "+ CRLF
        _cQry	+= "        SRA.RA_NOME NOME, "+ CRLF
        _cQry	+= "        SRA.RA_CIC CPF, "+ CRLF
        _cQry	+= "        SRA.RA_PIS PIS, "+ CRLF
        _cQry	+= "        (CASE " + CRLF
        _cQry	+= "           WHEN SRA.RA_PROCES = '00003' "+ CRLF
        _cQry	+= "              THEN "   + CRLF
        _cQry	+= "                (select MAX(C9V.C9V_ID) " + CRLF
        _cQry	+= "                 FROM "+RetSqlName("C9V")+"  C9V "+ CRLF
        _cQry	+= "                 WHERE C9V.C9V_FILIAL = SRA.ra_filial "+ CRLF
        _cQry	+= "                  AND C9V.C9V_CPF = SRA.RA_CIC "+ CRLF
        _cQry	+= "                  AND C9V.C9V_ATIVO = '1' "+ CRLF
        _cQry	+= "                  AND C9V.C9V_STATUS = '4' "  + CRLF
        _cQry	+= "                  AND C9V.D_E_L_E_T_ <> '*')  "+ CRLF
        _cQry	+= "           ELSE "+ CRLF
        _cQry	+= "                (select MAX(C9V.C9V_ID) " + CRLF
        _cQry	+= "                 FROM "+RetSqlName("C9V")+"  C9V "+ CRLF
        _cQry	+= "                 WHERE C9V.C9V_FILIAL = SRA.ra_filial "+ CRLF
        _cQry	+= "                  AND C9V.C9V_MATRIC = SRA.RA_CODUNIC "+ CRLF
        _cQry	+= "                  AND C9V.C9V_ATIVO = '1' "+ CRLF
        _cQry	+= "                  AND C9V.C9V_STATUS = '4' "  + CRLF
        _cQry	+= "                  AND C9V.D_E_L_E_T_ <> '*')  "+ CRLF
        _cQry	+= "        END ) ID_TAF, " + CRLF
        _cQry	+= "        SRA.RA_CODUNIC MAT_TAF, "+ CRLF
        _cQry	+= "        (CASE " + CRLF
        _cQry	+= "             WHEN SRA.RA_SITFOLH = '' "+ CRLF
        _cQry	+= "              THEN 'ATIVO' "+ CRLF
        _cQry	+= "             WHEN SRA.RA_SITFOLH = 'D' OR (SRA.RA_DEMISSA <= CONVERT(VARCHAR(8),GETDATE(),112) AND SRA.RA_DEMISSA <> '') "+ CRLF
        _cQry	+= "              THEN 'DEMITIDO' "+ CRLF
        _cQry	+= "             WHEN SRA.RA_SITFOLH = 'A' " + CRLF
        _cQry	+= "              THEN 'AFASTADO' "           + CRLF
        _cQry	+= "             WHEN SRA.RA_SITFOLH = 'F' " + CRLF
        _cQry	+= "              THEN 'FERIAS' " + CRLF
        _cQry	+= "             ELSE SRA.RA_SITFOLH "          + CRLF
        _cQry	+= "         END) SITUACAO, "+ CRLF
        _cQry	+= "         SRA.RA_ADMISSA ADMISSAO, "+ CRLF
        _cQry	+= "         SRA.RA_DEMISSA DEMISSAO, " + CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0015','0016') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_BASE_IRME, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '11' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_BASE_IRME, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD "  + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0027') " + CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "         AND SRD.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "        ),0) FOL_BASE_IR13, "   + CRLF
        _cQry	+= "        ISNULL( " + CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) " + CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I "  + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL " + CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO " + CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID "  + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U "  + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '12' "  + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) " + CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
        _cQry	+= "          ),0) TAF_BASE_IR13, " + CRLF
        _cQry	+= "       ISNULL( " + CRLF
        _cQry	+= "       (SELECT SUM(SRD.RD_VALOR) "  + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA "  + CRLF
        _cQry	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL " + CRLF
        _cQry	+= "         AND SRD.RD_MAT = RA.RA_MAT " + CRLF
        _cQry	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' " + CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0016','1562') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_BASE_IRFE, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '13' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_BASE_IRFE, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0066') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_RET_IRME, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '31' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_RET_IRME, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0071') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_RET_IR13, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '32' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_RET_IR13, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD "  + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0067') " + CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "         AND SRD.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "        ),0) FOL_RET_IRFE, "   + CRLF
        _cQry	+= "        ISNULL( " + CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) " + CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I "  + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL " + CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO " + CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID "  + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U "  + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '33' "  + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) " + CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
        _cQry	+= "          ),0) TAF_RET_IRFE, " + CRLF
        _cQry	+= "       ISNULL( " + CRLF
        _cQry	+= "       (SELECT SUM(SRD.RD_VALOR) "  + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA "  + CRLF
        _cQry	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL " + CRLF
        _cQry	+= "         AND SRD.RD_MAT = RA.RA_MAT " + CRLF
        _cQry	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' " + CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' "+ CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD "  + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0064') " + CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "         AND SRD.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "        ),0) FOL_DED_IRME, "   + CRLF
        _cQry	+= "        ISNULL( " + CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) " + CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I "  + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL " + CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO " + CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID "  + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U "  + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '41' "  + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) " + CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
        _cQry	+= "          ),0) TAF_DED_IRME, " + CRLF
        _cQry	+= "       ISNULL( " + CRLF
        _cQry	+= "       (SELECT SUM(SRD.RD_VALOR) "  + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA "  + CRLF
        _cQry	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL " + CRLF
        _cQry	+= "         AND SRD.RD_MAT = RA.RA_MAT " + CRLF
        _cQry	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' " + CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0070') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_DED_IR13, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '42' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_DED_IR13, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0065') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_DED_IRFE, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '43' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_DED_IRFE, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0059') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_DED_DEPIRME, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '56' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_DED_DEPIRME, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0062') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_DED_DEPIR13, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '57' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_DED_DEPIR13, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132'  
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
        _cQry	+= "                          					  WHERE SRV.RV_CODFOL IN ('0061','0062') "+ CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "        ),0) FOL_DED_DEPIRFE, "  + CRLF
        _cQry	+= "        ISNULL( "+ CRLF
        _cQry	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
        _cQry	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
        _cQry	+= "                                 WHERE C8U.C8U_CODIGO = '58' " + CRLF
        _cQry	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "          ),0) TAF_DED_DEPIRFE, "+ CRLF
        _cQry	+= "       ISNULL( "+ CRLF
        _cQry	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
        _cQry	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
        _cQry	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
        _cQry	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
        _cQry	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

        if MV_PAR07 == '132' 
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' "+ CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
        endif

        _cQry	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD "  + CRLF
        _cQry	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
        _cQry	+= "                           					  WHERE SRV.RV_CODFOL IN ('0066','0071','0067') " + CRLF
        _cQry	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
        _cQry	+= "         AND RA.RA_CIC = SRA.RA_CIC "  + CRLF
        _cQry	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
        _cQry	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "         AND SRD.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "        ),0) FOL_RET_IRTOT, "   + CRLF
        _cQry	+= "        ISNULL( " + CRLF
        _cQry	+= "        (SELECT SUM(T2J.T2J_VLDESC) " + CRLF
        _cQry	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2J")+"  T2J "  + CRLF
        _cQry	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
        _cQry	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
        _cQry	+= "          AND T2G.T2G_FILIAL = T2J.T2J_FILIAL " + CRLF
        _cQry	+= "          AND T2G.T2G_VERSAO = T2J.T2J_VERSAO " + CRLF
        _cQry	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
        _cQry	+= "          AND T2J.D_E_L_E_T_ <> '*' " + CRLF
        _cQry	+= "          AND T2J.T2J_CTPCR IN (SELECT C6R_ID " + CRLF
        _cQry	+= "                                FROM "+RetSqlName("C6R")+"  C6R "  + CRLF
        _cQry	+= "                                WHERE C6R.C6R_CODIGO = '999999' "  + CRLF
        _cQry	+= "                                 AND C6R.D_E_L_E_T_ <> '*' ) " + CRLF
        _cQry	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
        _cQry	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
        _cQry	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
        _cQry	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
        _cQry	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
        _cQry	+= "          ),0) TAF_RET_IRTOT " + CRLF
        _cQry	+= " FROM  "+RetSqlName("SRA")+"  SRA " + CRLF
        _cQry	+= " WHERE SRA.D_E_L_E_T_ <> '*' "  + CRLF
        _cQry	+= "  AND EXISTS " + CRLF
        _cQry	+= "  (SELECT * " + CRLF
        _cQry	+= "   FROM  "+RetSqlName("SRD")+"  SRD " + CRLF

        IF !Empty(MV_PAR01)
            _cQry	+= "   WHERE SRD.RD_FILIAL = '"+MV_PAR01+"' "+ CRLF
            _cQry	+= "   	AND SRD.RD_FILIAL = SRA.RA_FILIAL "+ CRLF
        else 
            _cQry	+= "   WHERE SRD.RD_FILIAL = SRA.RA_FILIAL "+ CRLF
        endif 

        if !Empty(MV_PAR03)
            _cQry	+= "    AND SRD.RD_MAT BETWEEN '"+MV_PAR03+"' AND '"+iif(AllTrim(MV_PAR04) != '',MV_PAR04,'ZZZZZZZ')+"' "+ CRLF
            _cQry	+= "    AND SRD.RD_MAT = SRA.RA_MAT "+ CRLF
        else 
            _cQry	+= "    AND SRD.RD_MAT = SRA.RA_MAT "+ CRLF
        endif 

        _cQry	+= "    AND SRD.RD_PERIODO = '"+MV_PAR05+"' "+ CRLF

        if !Empty(MV_PAR06)
            _cQry	+= "    and SRD.RD_CC = '"+MV_PAR06+"' "+ CRLF
        endif

        if MV_PAR07 == '132' 
            _cQry	+= "         AND SRD.RD_ROTEIR  = '132' "+ CRLF
        else
            _cQry	+= "         AND SRD.RD_ROTEIR IN ('AUT','FOL') "+ CRLF
        endif

        _cQry	+= "    AND SRD.D_E_L_E_T_ <> '*' ) " + CRLF
        _cQry	+= " ) X   "+ CRLF

        _cQry	+= "ORDER BY FILIAL,MAT_FOLHA " + CRLF

        _cQry	:= Upper(_cQry)	

    EndIf

    If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador,ioliveira'
        MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
    EndIf

    // dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAliasG),.F.,.F.) 
    MPSysOpenQuery( _cQry , (_cAliasG) )

Return !(_cAliasG)->(Eof())

Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
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

aAdd(aRegs,{cPerg, "01", "Filial de"        , "", "", "MV_CH1", "C" , 7, 0, 0 , "G", "", "MV_PAR01", "", "", "", ""         , "", "","","","","","","","","","","","","","","","","","","","SM0","S","","","","",{"Informe o código da filial desejada ou deixe em branco."     , "<F3 Disponivel>"}})
aAdd(aRegs,{cPerg, "02", "Filial até"       , "", "", "MV_CH2", "C" , 7, 0, 0 , "G", "", "MV_PAR02", "", "", "", "ZZZZZZZ"  , "", "","","","","","","","","","","","","","","","","","","","SM0","S","","","","",{"Informe o código da filial desejada ou deixe em branco."     , "<F3 Disponivel>"}})
aAdd(aRegs,{cPerg, "03", "Matrícula de"     , "", "", "MV_CH3", "C" , 6, 0, 0 , "G", "", "MV_PAR03", "", "", "", ""         , "", "","","","","","","","","","","","","","","","","","","","SRA","S","","","","",{"Informe a mátricula desejada ou deixe em branco."            , "<F3 Disponivel>"}})
aAdd(aRegs,{cPerg, "04", "Matrícula até"    , "", "", "MV_CH4", "C" , 6, 0, 0 , "G", "", "MV_PAR04", "", "", "", "ZZZZZZ"   , "", "","","","","","","","","","","","","","","","","","","","SRA","S","","","","",{"Informe a mátricula desejada ou deixe em branco."            , "<F3 Disponivel>"}})
aAdd(aRegs,{cPerg, "05", "Periodo (AAAAMM)" , "", "", "MV_CH5", "C" , 6, 0, 0 , "G", "", "MV_PAR05", "", "", "", ""         , "", "","","","","","","","","","","","","","","","","","","",""   ,"S","","","","",{"Informe a data desejada ou deixe em branco."                 , "<F3 Disponivel>"}})
aAdd(aRegs,{cPerg, "06", "Centro de Custo"  , "", "", "MV_CH6", "C" , 60, 0, 0, "G", "", "MV_PAR06", "", "", "", ""         , "", "","","","","","","","","","","","","","","","","","","","C1P","S","","","","",{"Informe o centro de custo desejada ou deixe em branco."      , "<F3 Disponivel>"}})
aAdd(aRegs,{cPerg, "07", "Roteiro"  		, "", "", "MV_CH7", "C" , 3, 0, 0 , "G", "", "MV_PAR07", "", "", "", ""         , "", "","","","","","","","","","","","","","","","","","","",""	,"s","","","","",{"Informe o centro de custo desejada ou deixe em branco."      , "<F3 Disponivel>"}})
//aAdd(aRegs,{cPerg, "08", "Situação"         , "", "", "MV_CH8", "C" , 60, 0, 0, "K", "", "MV_PAR08", "ATIVO", "", "", "", "", "DEMITIDO","","","","","AFASTADO","","","","","FERIAS","","","","","","","","","","U","","","",""})

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
STATIC FUNCTION FBUSCAFER(cFil,cMat,cTipo)

Local nRet := 0

cQry := GetnextAlias()

cQuery := "SELECT RR_FILIAL, RR_MAT, SUM(RR_VALOR) AS TOTAL                         "  
cQuery += "FROM " + RetSqlName("SRR") + " SRR, " + RetSqlName("SRV") + " SRV        " 
cQuery += " WHERE     SRR.D_E_L_E_T_ = ' '                                          "
cQuery += "       AND SRV.D_E_L_E_T_ = ' '                                          "
cQuery += "       AND RV_COD = RR_PD                                                "

IF cTipo = '1'
   cQuery += "       AND RV_CODFOL IN ('0016','0168')                               "
ELSE
   cQuery += "       AND RV_CODFOL IN ('0067','0237','0101')                        "
ENDIF

cQuery += "       AND RR_ROTEIR = 'FER'                                             "
cQuery += "       AND RR_DATAPAG BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31'      "
cQuery += "       AND RR_FILIAL = '"+cFil+"'  AND RR_MAT = '"+cMat+"'    "
cQuery += "GROUP BY RR_FILIAL, RR_MAT  " 

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQry, .T., .T.)
DbSelectarea(cQry)

while !(cQry)->(eof())

   nRet  += (cQry)->TOTAL
   dbskip()

end
           
DBCLOSEAREA()


RETURN(nRet)
