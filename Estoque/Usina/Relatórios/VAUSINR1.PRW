#include 'FILEIO.CH'
#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"

static oCellHorAlign    := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign   := FwXlsxCellAlignment():Vertical()
static cNameRot         := "FECHAMENTO MENSAL - USINA"
/*---------------------------------------------------------------------------------,
 | Analista : Igor Gomes Oliveira                                                  |
 | Data		: 05.05.2023                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatorio Fechamento Mensal Usina              				       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_VAUSINR1()                                                         |
 '---------------------------------------------------------------------------------*/
User Function VAUSINR1() // U_VAUSINR1()
    Local cTimeIni	 	:= Time()
    Local aArea         := GetArea()
    Local aDados		:= {}
    Local lRet          := .F.
    Local nRet          := 0
    Local nI := 0

    Private oExcel      := nil
    Private cPerg		:= SubS(ProcName(),3)
    Private cTitulo  	:= cNameRot
    Private cPath 	 	:= "C:\totvs_relatorios\"
    Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
                                DtoS(dDataBase)+; 
                                "_"+;
                                StrTran(SubS(Time(),1,5),":","")+;
                                ".rel"

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

    Private nRowsAba1  := 0

    GeraX1(cPerg)

    DefinirFormatacao()

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
        EndIF
            
            FWMsgRun(, {|| aDados := LoadQuery() },;
                            'Por Favor Aguarde...',;
                            'Processando Banco de Dados - Recebimento')

            If Len(aDados) > 0
                
                For nI := 1 to Len(aDados)
                    oExcel := FwPrinterXlsx():New()
                    oExcel:Activate(cArquivo)

                    fQuadro1(aDados[nI]) // PREÇO

                    fQuadro2(aDados[nI]) // VIAGENS
                    
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

                Next nI 
                
            else 
                MsgAlert("Não há dados para os parametros informados!")
            EndIf
    Endif

    If lower(cUserName) $ 'bernardo,ioliveira,atoshio,admin,administrador'
        Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
    EndIf
    
    RestArea(aArea)
    
    ConOut('Activate: ' + Time())
Return 

Static Function fQuadro1(aDados)
    Local cWorkSheet := "Premissas negociação"
    Local nRow       := 1
    Local nCol       := 1
    Local aCopia     := aClone(aDados[3])
    Local aHeader    := { "% MS", "R$ Ton" }
    Local nI
    Local nTamLin
    
    oExcel:AddSheet(cWorkSheet)
    
    oExcel:SetCellsFormatConfig(jFormatTit)
    oExcel:SetFontConfig(JFontTitulo)
    oExcel:MergeCells(nRow, nCol, nRow+1, Len(aHeader))
    
    cNameRot := "CREME LEVEDURA PREÇO - " + cValToChar(Year( MV_PAR01 )) 
    oExcel:SetText(nRow, nCol, cNameRot )

    oExcel:SetCellsFormatConfig(jFormatHead)
    oExcel:SetFontConfig(JFontHeader)
    nRow += 2

    For nI := nCol to Len(aHeader)
        oExcel:SetValue(nRow, nI, aHeader[nI])
    Next nI

    oExcel:SetBorderConfig(jBorder)

    nTamLin := Len(aCopia)
    For nI := 1 to nTamLin
        nRow += 1
        nCol := 1
        oExcel:SetCellsFormatConfig(jFNum)
        oExcel:SetFontConfig(JFontText)
        oExcel:SetValue(nRow, nCol, aCopia[nI,1]) // ADICIONAR DADOS NO DEGUB 

        oExcel:SetCellsFormatConfig(jFMoeda)
        oExcel:SetFontConfig(JFontText)
        oExcel:SetValue(nRow, ++nCol, aCopia[nI,2]) // ADICIONAR DADOS NO DEGUB
    Next nI

    oExcel:ApplyAutoFilter(3,1,nRow,Len(aHeader))

    nRowsAba1 := nRow
Return

Static Function fQuadro2(aDados)
    Local cWorkSheet    := " "
    Local nRow          := 1
    Local nCol          := 1
    Local aCopia        := aClone(aDados[2])
    Local nI
    Local aHeader    := { "DATA"                  ,;
                            "NF"                    ,;
                            "PESO FORNECEDOR"       ,;
                            "PESO V@"               ,;
                            "MÉDIA PESO"            ,;
                            "DIFERENÇA PESO"        ,;
                            "VALOR NF"              ,;
                            "DENSIDADE"             ,;
                            "M³ ETANOL"             ,;
                            "GL FORNECEDOR"         ,;
                            "GL V@"                 ,;
                            "GL MÉDIA"              ,;
                            "GL DIFERENÇA"          ,;
                            "M.S. FORNECEDOR"       ,;
                            "M.S. V@"               ,;
                            "M.S. MÉDIA"            ,;
                            "M.S. DIFERENÇA"        ,;
                            "PREÇO CREME"           ,;
                            "PREÇO ETANOL"          ,;
                            "R$ TOTAL CREME"        ,;
                            "R$ TOTAL ETANOL"       ,;
                            "R$ TOTAL"              ,;
                            "R$ TONELADA"           ,;
                            "R$ TON. M.S."          ,;
                            "DIF. (COMPL. VALOR)"   }

    cWorkSheet := MesExtenso(MV_PAR01) + " - " + cValToChar(Year( MV_PAR01 )) 

    oExcel:AddSheet(cWorkSheet)

    oExcel:SetCellsFormatConfig(jFormatTit)
    oExcel:SetFontConfig(JFontTitulo)
    oExcel:MergeCells(nRow, nCol, nRow+1, Len(aHeader))
    
    cNameRot := AllTRIM(Posicione("SA2",1,FWxFilial("SA2")+aDados[1][1] + aDados[1][2],"A2_NOME" ))  + " / " + cWorkSheet // adicionar nome fornecedor
    oExcel:SetText(nRow, nCol, cNameRot )

    nRow += 2
    nCol := 15

    oExcel:SetCellsFormatConfig(jFormatHead)
    oExcel:SetFontConfig(JFontHeader)
    oExcel:SetValue(nRow    , nCol, "ESALQ")

    oExcel:SetFontConfig(JFontText)
    oExcel:SetCellsFormatConfig(JFLeft)
    oExcel:SetBorderConfig(jBorder)
    oExcel:SetCellsFormatConfig(jFM4d)
    oExcel:SetValue(nRow    , ++nCol, aCopia[1][aScan(aCopia[1], {|x| Upper(x[1]) == "VESALQ"})][2])

    nRow += 1
    nCol := 15

    oExcel:SetCellsFormatConfig(jFPercent)
    oExcel:SetValue(nRow, nCol, aCopia[1][aScan(aCopia[1], {|x| Upper(x[1]) == "DESCESALQ"})][2] / 100 ) // ADCIONAR % ESALQ
    oExcel:SetCellsFormatConfig(jFM4d)
    oExcel:SetFormula(nRow, ++nCol, "=ROUND(P3*O4,4)") // PEGAR COLUNA E ADICIONAR FORMULA -- PORCENTAGEM DO ESALQ
    
    nRow += 1
    nCol := 1

    oExcel:SetCellsFormatConfig(jFormatHead)
    oExcel:SetFontConfig(JFontHeader)

    For nI := nCol to Len(aHeader)
        oExcel:SetValue(nRow, nI, aHeader[nI])
    Next nI
    
    oExcel:SetCellsFormatConfig(JFLeft)
    oExcel:SetBorderConfig(jBorder)
    For nI := 1 to Len(aCopia)
        nRow += 1
        nCol := 1
        oExcel:SetCellsFormatConfig(JFData)
        oExcel:SetValue(nRow, nCol, aCopia[nI][aScan(aCopia[nI], {|x| Upper(x[1]) == "DATA"})][2] )

        oExcel:SetCellsFormatConfig(JFCenter)
        oExcel:SetValue(nRow, ++nCol, aCopia[nI][aScan(aCopia[nI], {|x| Upper(x[1]) == "NF"})][2] )

        oExcel:SetCellsFormatConfig(JFNum)
        oExcel:SetValue(nRow, ++nCol, aCopia[nI][aScan(aCopia[nI], {|x| Upper(x[1]) == "PESO FORNECEDOR"})][2] )
        oExcel:SetValue(nRow, ++nCol, aCopia[nI][aScan(aCopia[nI], {|x| Upper(x[1]) == "PESO V@"})][2] )
        oExcel:SetFormula(nRow, ++nCol, "=IFERROR(AVERAGE(C"+cValToChar(nRow)+",D"+cValToChar(nRow)+"),0)") 
        oExcel:SetFormula(nRow, ++nCol, "=IFERROR(ABS(C"+cValToChar(nRow)+" - D"+cValToChar(nRow)+"),"+'""'+")")
        
        oExcel:SetCellsFormatConfig(jFMoeda)
        oExcel:SetValue(nRow, ++nCol, aCopia[nI][aScan(aCopia[nI], {|x| Upper(x[1]) == "VALOR NF"})][2]) 

        jFM4d['custom_format']     := "###,##0.00000"
        oExcel:SetCellsFormatConfig(jFM4d) // MUDAR ESALQ PARA ESSA POSICAO
        oExcel:SetValue(nRow, ++nCol, aCopia[nI][aScan(aCopia[nI], {|x| Upper(x[1]) == "DENSIDADE"})][2]) 

        oExcel:SetFormula(nRow, ++nCol, "=IFERROR((E"+cValToChar(nRow)+"/1000)/H"+cValToChar(nRow)+","+'""'+")") 
        jFM4d['custom_format']     := "\R$ ###,###,##0.0000"

        oExcel:SetCellsFormatConfig(jFPercent)
        oExcel:SetValue(nRow, ++nCol, aCopia[nI][aScan(aCopia[nI], {|x| Upper(x[1]) == "GL FORNECEDOR"})][2] / 100 )
        oExcel:SetValue(nRow, ++nCol, aCopia[nI][aScan(aCopia[nI], {|x| Upper(x[1]) == "GL V@"})][2] / 100 )        
        oExcel:SetFormula(nRow, ++nCol, "=IFERROR(AVERAGE(J"+cValToChar(nRow)+",K"+cValToChar(nRow)+"),"+'""'+")")  
        oExcel:SetFormula(nRow, ++nCol, "=IFERROR(ABS(J"+cValToChar(nRow)+" - K"+cValToChar(nRow)+"),"+'""'+")")  

        oExcel:SetValue(nRow, ++nCol, aCopia[nI][aScan(aCopia[nI], {|x| Upper(x[1]) == "M.S. FORNECEDOR"})][2] / 100) 
        oExcel:SetValue(nRow, ++nCol, aCopia[nI][aScan(aCopia[nI], {|x| Upper(x[1]) == "M.S. V@"})][2] / 100 ) 
        oExcel:SetFormula(nRow, ++nCol, "=IFERROR(AVERAGE(N"+cValToChar(nRow)+",O"+cValToChar(nRow)+"),"+'""'+")") 
        oExcel:SetFormula(nRow, ++nCol, "=IFERROR(ABS(N"+cValToChar(nRow)+" - O"+cValToChar(nRow)+"),"+'""'+")") 
        
        oExcel:SetCellsFormatConfig(JFNum)
        oExcel:SetFormula(nRow, ++nCol, "=IFERROR(VLOOKUP(TRUNC(P"+cValToChar(nRow)+"*100),'Premissas Negociação'!A4:B"+cValToChar(nRowsAba1)+",2,FALSE),"+'""'+")") 
        
        oExcel:SetCellsFormatConfig(jFM4d) 
        oExcel:SetFormula(nRow, ++nCol, "=IF(O"+cValToChar(nRow)+"<>"+'""'+",$P$4,"+'""'+")") 

        oExcel:SetCellsFormatConfig(jFMoeda)
        oExcel:SetFormula(nRow, ++nCol, "=IFERROR((E"+cValToChar(nRow)+"/1000)*P"+cValToChar(nRow)+"*R"+cValToChar(nRow)+",0)") 
        
        oExcel:SetFormula(nRow, ++nCol, "=I"+cValToChar(nRow)+"*L"+cValToChar(nRow)+"*S"+cValToChar(nRow)+"*1000") 
        
        oExcel:SetFormula(nRow, ++nCol, "=T"+cValToChar(nRow)+"+U"+cValToChar(nRow)+"") 
        
        oExcel:SetFormula(nRow, ++nCol, "=IFERROR(V"+cValToChar(nRow)+"/(E"+cValToChar(nRow)+"/1000),0)") 
        
        oExcel:SetFormula(nRow, ++nCol, "=IFERROR(W"+cValToChar(nRow)+"/P"+cValToChar(nRow)+",0)") 
        
        oExcel:SetFormula(nRow, ++nCol, "=V"+cValToChar(nRow)+"-G"+cValToChar(nRow)+"")

    Next nI

    oExcel:ApplyAutoFilter(5,1,nRow,Len(aHeader))
    
    nRow += 1 

    jFormatTot['custom_format']     := "###,##0.00"
    oExcel:SetCellsFormatConfig(jFormatTot)
    oExcel:SetFormula(nRow, 3, "=SUBTOTAL(9,C6:C"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 4, "=SUBTOTAL(9,D6:D"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 5, "=SUBTOTAL(9,E6:E"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 16, "=SUBTOTAL(1,P6:P"+cValToChar(nRow-1)+")") 
    
    jFormatTot['custom_format']     := "###,##0.00000"
    oExcel:SetCellsFormatConfig(jFormatTot)
    oExcel:SetFormula(nRow, 9,  "=SUBTOTAL(1,I6:I"+cValToChar(nRow-1)+")") 

    jFormatTot['custom_format']     := "#0.00%"
    oExcel:SetCellsFormatConfig(jFormatTot)
    oExcel:SetFormula(nRow, 10, "=SUBTOTAL(1,J6:J"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 11, "=SUBTOTAL(1,K6:K"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 12, "=SUBTOTAL(1,L6:L"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 13, "=SUBTOTAL(1,M6:M"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 14, "=SUBTOTAL(1,N6:N"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 15, "=SUBTOTAL(1,O6:O"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 17, "=SUBTOTAL(1,Q6:Q"+cValToChar(nRow-1)+")") 
    
    jFormatTot['custom_format']     := "\R$ ###,##0.00""
    oExcel:SetCellsFormatConfig(jFormatTot)
    oExcel:SetFormula(nRow, 20, "=SUBTOTAL(9,T6:T"+cValToChar(nRow-1)+")")
    oExcel:SetFormula(nRow, 21, "=SUBTOTAL(9,U6:U"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 22, "=SUBTOTAL(9,V6:V"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 23, "=SUBTOTAL(1,W6:W"+cValToChar(nRow-1)+")") 
    oExcel:SetFormula(nRow, 24, "=SUBTOTAL(1,X6:X"+cValToChar(nRow-1)+")")
    oExcel:SetFormula(nRow, 25, "=SUBTOTAL(9,Y6:Y"+cValToChar(nRow-1)+")")

Return 
Static Function LoadQuery()
    Local cQry      := ""
    Local cTransp   := ''
    Local nPosD     := 0
    Local aDados    := {}
    Local cALias    := GetNextAlias()
    Local __oQry    := nil
    Local nI 

    cQry := " SELECT  " + CRLF 
    cQry += " F1_EMISSAO " + CRLF 
    cQry += " ,ZAC.* " + CRLF 
    cQry += " FROM "+RetSqlName("ZAC")+" ZAC " + CRLF 
    cQry += " JOIN "+RetSqlName("SF1")+" SF1 ON " + CRLF 
    cQry += " 	F1_DOC = ZAC_NOTFIS " + CRLF 
    cQry += " AND F1_FORNECE = ZAC_FORNEC " + CRLF 
    cQry += " AND F1_LOJA = ZAC_LOJA " + CRLF 
    cQry += " AND F1_EMISSAO BETWEEN '"+dToS(MV_PAR01)+"' AND '"+dToS(MV_PAR02)+"'  " + CRLF 
    cQry += " AND SF1.D_E_L_E_T_ = '' " + CRLF 
    cQry += " WHERE ZAC.D_E_L_E_T_ = '' " + CRLF 
    cQry += " AND ZAC_FILIAL = '"+FwXFilial("ZAC")+"' " + CRLF 
    cQry += " AND ZAC_FORNEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + CRLF 
    cQry += " ORDER BY ZAC_FORNEC, F1_EMISSAO " + CRLF 

    memowrite("C:\TOTVS_RELATORIOS\VAUSINR1.sql", cQry)
    
    MpSysOpenQuery(cQry, cALias)
    
    While !(cALias)->(EOF())
        if cTransp != (cALias)->ZAC_FORNEC
            nPosD += 1
            cTransp := (cALias)->ZAC_FORNEC
            
            aAdd(aDados,{ { AllTrim((cALias)->ZAC_FORNEC),AllTrim((cALias)->ZAC_LOJA)  },;
                        {   { {"DATA"                   , dToC(sToD((cALias)->F1_EMISSAO)) } ,;
                              {"NF"                     , AllTrim((cALias)->ZAC_NOTFIS) } ,;
                              {"PESO FORNECEDOR"        , (cALias)->ZAC_QTDNF  } ,;
                              {"PESO V@"                , (cALias)->ZAC_PESOL  } ,;
                              {"MÉDIA PESO"             , (cALias)->ZAC_PESOM  } ,;
                              {"VALOR NF"               , (cALias)->ZAC_VALNFN } ,;
                              {"DENSIDADE"              , (cALias)->ZAC_DENSI  } ,;
                              {"M³ ETANOL"              , (cALias)->ZAC_M3ETAN } ,;
                              {"GL FORNECEDOR"          , (cALias)->ZAC_GLFOR  } ,;
                              {"GL V@"                  , (cALias)->ZAC_GLVA  }  ,;
                              {"GL MÉDIA"               , (cALias)->ZAC_GLMED  } ,;
                              {"M.S. FORNECEDOR"        , (cALias)->ZAC_MSFOR  } ,;
                              {"M.S. V@"                , (cALias)->ZAC_MSVA  }  ,;
                              {"M.S. MÉDIA"             , (cALias)->ZAC_MSMEDI  },;
                              {"PREÇO CREME"            , (cALias)->ZAC_MSPREC  },;
                              {"PREÇO ETANOL"           , ( (cALias)->ZAC_VESALQ * ( (cALias)->ZAC_DESALQ / 100 ) ) } ,; // CONFIRMAR
                              {"R$ TOTAL CREME"         , (cALias)->ZAC_RTOTMS } ,;
                              {"R$ TOTAL ETANOL"        , (cALias)->ZAC_RTOTET } ,;
                              {"R$ TOTAL"               , (cALias)->ZAC_RTOTAL } ,;
                              {"R$ TONELADA"            , (cALias)->ZAC_RTONEL } ,;
                              {"R$ TON. M.S."           , (cALias)->ZAC_RTOMS  } ,;
                              {"DIF. (COMPL. VALOR)"    , (cALias)->ZAC_RTODIF } ,;
                              {"VESALQ"                 , (cALias)->ZAC_VESALQ } ,;
                              {"DESCESALQ"              , (cALias)->ZAC_DESALQ } ,;
                              {"DATAESALQ"              , (cALias)->ZAC_DTESAL } ;
                            };
                        },;
                        {}})
        else
            aAdd(aDados[nPosD][2], {   {"DATA"                   , dToC(sToD((cALias)->F1_EMISSAO)) } ,;
                                        {"NF"                     , AllTrim((cALias)->ZAC_NOTFIS) } ,;
                                        {"PESO FORNECEDOR"        , (cALias)->ZAC_QTDNF  } ,;
                                        {"PESO V@"                , (cALias)->ZAC_PESOL  } ,;
                                        {"MÉDIA PESO"             , (cALias)->ZAC_PESOM  } ,;
                                        {"VALOR NF"               , (cALias)->ZAC_VALNFN } ,;
                                        {"DENSIDADE"              , (cALias)->ZAC_DENSI  } ,;
                                        {"M³ ETANOL"              , (cALias)->ZAC_M3ETAN } ,;
                                        {"GL FORNECEDOR"          , (cALias)->ZAC_GLFOR  } ,;
                                        {"GL V@"                  , (cALias)->ZAC_GLVA  } ,;
                                        {"GL MÉDIA"               , (cALias)->ZAC_GLMED  } ,;
                                        {"M.S. FORNECEDOR"        , (cALias)->ZAC_MSFOR  } ,;
                                        {"M.S. V@"                , (cALias)->ZAC_MSVA  } ,;
                                        {"M.S. MÉDIA"             , (cALias)->ZAC_MSMEDI  } ,;
                                        {"PREÇO CREME"            , (cALias)->ZAC_MSPREC  } ,;
                                        {"PREÇO ETANOL"           , ( (cALias)->ZAC_VESALQ * ( (cALias)->ZAC_DESALQ / 100 ) ) } ,; // CONFIRMAR
                                        {"R$ TOTAL CREME"         , (cALias)->ZAC_RTOTMS } ,;
                                        {"R$ TOTAL ETANOL"        , (cALias)->ZAC_RTOTET } ,;
                                        {"R$ TOTAL"               , (cALias)->ZAC_RTOTAL } ,;
                                        {"R$ TONELADA"            , (cALias)->ZAC_RTONEL } ,;
                                        {"R$ TON. M.S."           , (cALias)->ZAC_RTOMS  } ,;
                                        {"DIF. (COMPL. VALOR)"    , (cALias)->ZAC_RTODIF } ,;
                                        {"VESALQ"                 , (cALias)->ZAC_VESALQ } ,;
                                        {"DESCESALQ"              , (cALias)->ZAC_DTESAL } ,;
                                        {"DATAESALQ"              , (cALias)->ZAC_DESALQ } ;
                                    })
        endif
        (cALias)->(DBSKIP(  ))
    ENDDO
    
    (cALias)->(DbCloseArea(  ))
    cAlias := ""

    cQry := " SELECT * " + CRLF
    cQry += " FROM "+RetSqlName("ZML")+" ZML " + CRLF
    cQry += " WHERE ZML.D_E_L_E_T_ = '' " + CRLF
    cQry += " AND ZML_FILIAL = ? " + CRLF
    cQry += " AND ZML_FORNEC = ?  " + CRLF
    cQry += " AND ZML_DATAD <= ? " + CRLF
    cQry += " AND ZML_DATAF >= ? " + CRLF
    cQry += " ORDER BY ZML_FORNEC, ZML_FERM " + CRLF

    __oQry := FwExecStatement():New(cQry)

    For nI := 1 to Len(aDados)
        __oQry:SetString(1, FwXFilial("ZAC"))
        __oQry:SetString(2, aDados[nI][1][1])
        __oQry:SetDate  (3, MV_PAR01)
        __oQry:SetDate  (4, MV_PAR02)
    
        cAlias := __oQry:OpenAlias()
        
        while !(cAlias)->(EOF())
            aAdd(aDados[nI][3], {(cAlias)->ZML_FERM, (cAlias)->ZML_TONMS} )
            (cALias)->(DBSKIP(  ))
        enddo 

        (cALias)->(dbCloseArea())
    Next nI 

Return aDados

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

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAUSINR1()             	            	      |
 | Func:  GeraX1()  	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  11.03.2019	            	          	            	              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

    Local _aArea	:= GetArea()
    Local aRegs     := {}
    Local nI		:= 0
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

        aAdd(aRegs,{cPerg,"01", "Data de:               ", "", "", "MV_CH1", "D", 8, 0, 0                                    , "G", "", "MV_PAR01", "", "", "", ""      , "", "","","","","","","","","","","","","","","","","","","","","U","","","",""})
        aAdd(aRegs,{cPerg,"02", "Data até:              ", "", "", "MV_CH2", "D", 8, 0, 0                                    , "G", "", "MV_PAR02", "", "", "", ""      , "", "","","","","","","","","","","","","","","","","","","","","U","","","",""})
        aAdd(aRegs,{cPerg,"03", "Fornecedor de:         ", "", "", "MV_CH3", "C", TAMSX3("A2_COD")[1], TAMSX3("A2_COD")[2], 0, "G", "", "MV_PAR03", "", "", "", ""      , "", "","","","","","","","","","","","","","","","","","","","SA2","U","","","",""})
        aAdd(aRegs,{cPerg,"04", "Fornecedor ate:        ", "", "", "MV_CH4", "C", TAMSX3("A2_COD")[1], TAMSX3("A2_COD")[2], 0, "G", "", "MV_PAR04", "", "", "", "ZZZZZZ", "", "","","","","","","","","","","","","","","","","","","","SA2","U","","","",""})

    //Se quantidade de perguntas for diferente, apago todas
    SX1->(DbGoTop())
    If nPergs <> Len(aRegs)
        For nI:=1 To nPergs
            If SX1->(DbSeek(cPerg))
                If RecLock('SX1',.F.)
                    SX1->(DbDelete())
                    SX1->(MsUnlock())
                EndIf
            EndIf
        Next nI
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

