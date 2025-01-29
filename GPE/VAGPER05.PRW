#include 'FILEIO.CH'
#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"

static oCellHorAlign    := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign   := FwXlsxCellAlignment():Vertical()

/*---------------------------------------------------------------------------------,
 | Analista : Igor Gomes Oliveira                                                  |
 | Data		: 27.11.2023                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatorio de Banco de Horas.                            		       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_VAGPER05()                                                         |
 '---------------------------------------------------------------------------------*/
User Function VAGPER05()
    Local cTimeIni	 	:= Time()
    Local aArea         := GetArea()
    Local lTemDados     := .T. 
    Private cPerg		:= SubS(ProcName(),3)
    Private _cAliasG	:= GetNextAlias()
    Private cTitulo  	:= "Banco de Horas"
    Private cPath 	 	:= "C:\totvs_relatorios\"
    Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
                                dToS(dDataBase)+; 
                                "_"+;
                                StrTran(SubS(Time(),1,5),":","")+;
                                ".rel"

    Private oFileW      := nil
    Private oExcel      := NIL
    Private jFormatTit,jFormatTot,jFormatHead,jFormatGD,JFLeft,JFRight,jFData,jFNum,jFMoeda //Formato de Celula
    Private jFontHeader,jFontTitulo,jFontText //Fontes
    Private jBHeaderLeft,jBHeaderRight,jBorderLeft,jBorderCenter,jBorderRight,jBottomLeft,jBottomRight,jNoBorder  // Bordas

    GeraX1(cPerg)
    DefinirFormatacao()

    If Pergunte(cPerg, .T.)
        U_PrintSX1(cPerg)

        If Len( Directory(cPath + "*.*","D") ) == 0
            If Makedir(cPath) == 0
                ConOut('Diretorio Criado com Sucesso.')
            Else	
                ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
            EndIf
	    EndIf

            FWMsgRun(, {|| lTemDados := LoadQuery(@_cAliasG ) },;
                        'Por Favor Aguarde...',; 
                        'Processando Banco de Dados - Recebimento')

        IF lTemDados
            FWMsgRun(, {|| fQuadro1() },'Por Favor Aguarde...','Gerando Excel')
        ELSE 
            MsgALert("Não foram encontrados dados com os parâmetros informados!")
        ENDIF 

    endif 

    If lower(cUserName) $ 'bernardo,ioliveira,atoshio,admin,administrador'
        Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
    EndIf

    RestArea(aArea)
Return 

Static Function fQuadro1()
    Local nX    
    Local lRet      := .T. 
    Local cHoras, cDecimal, cSaldo
    Local aHeaderRel    := {"Filial",;
                            "Matricula",;
                            "Nome",;
                            "Saldo Anterior",;
                            "Saldo Atual",;
                            "Departamento"}
    
    oExcel := FwPrinterXlsx():New()
    oExcel:Activate(cArquivo)
    oExcel:AddSheet("ABA01")

    nRow := 1
    nCol := 1

    oExcel:SetBorderConfig(jNoBorder)
    oExcel:SetCellsFormatConfig(jFormatHead)
    oExcel:SetFontConfig(jFontHeader)

    For nX := nCol to Len(aHeaderRel)
        oExcel:SetValue(nRow, nX, aHeaderRel[nX])
    Next nX
    
    oExcel:SetBorderConfig(jNoBorder)
    oExcel:SetCellsFormatConfig(JFLeft)
    while !(_cAliasG)->(EOF())
        nRow += 1
        nCol := 1

        oExcel:SetFontConfig(jFontText)
        oExcel:SetValue(nRow, nCol  , (_cAliasG)->FILIAL )
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->MATRICULA )
        oExcel:SetValue(nRow, ++nCol, Alltrim((_cAliasG)->NOME) )
        
        oExcel:SetCellsFormatConfig(jFNum)
        
        
        cHoras := AllTrim(Str(IIF(Round((_cAliasG)->SALDO_ANTERIOR,2)==NIL,0,Round((_cAliasG)->SALDO_ANTERIOR,2))))
        
        if int(Val(cHoras)) - Val(cHoras) == 0
            cDecimal    := "0"
            cSaldo      := cHoras
        else 
            cDecimal    := SubStr(cHoras,At(".",cHoras)+1)

            if LEN(cDecimal) == 1
                cDecimal := cDecimal + "0"
            endif 

            cSexa  := Round(Val(cDecimal) / 1.67,0)
            cSaldo := SubStr(cHoras,1,At(".",cHoras))  + iif(LEN(AllTrim(Str(cSexa)))==1,"0"+AllTrim(Str(cSexa)),AllTrim(Str(cSexa)))
        endif

        oExcel:SetValue(nRow, ++nCol, Val(cSaldo))
        
        cHoras := AllTrim(Str(IIF(Round((_cAliasG)->(SALDO_ATUAL),2)==NIL,0,Round((_cAliasG)->(SALDO_ATUAL),2))))

        if int(Val(cHoras)) - Val(cHoras) == 0
            cDecimal    := "0"
            cSaldo      := cHoras
        else
            cDecimal    := SubStr(cHoras,At(".",cHoras)+1)

            if LEN(cDecimal) == 1
                cDecimal := cDecimal + "0"
            endif

            cSexa  := Round(Val(cDecimal) / 1.67,0)
            cSaldo := SubStr(cHoras,1,At(".",cHoras))  + iif(LEN(AllTrim(Str(cSexa)))==1,"0"+AllTrim(Str(cSexa)),AllTrim(Str(cSexa)))
        endif

        oExcel:SetValue(nRow, ++nCol, Val(cSaldo))
        
        oExcel:SetFontConfig(jFontText)
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->DESCRI )
        
        (_cAliasG)->(DBSKIP())
    enddo
    
    oExcel:ApplyAutoFilter(1,1,nRow,Len(aHeaderRel))

    lRet := oExcel:toXlsx()
    
    nRet := ShellExecute("open", SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx", "", "", 1)

    If nRet <= 32
        MsgStop("Não foi possível abrir o arquivo "+SubStr(cArquivo,1,Len(cArquivo)-3)+ "xlsx"+ "!", "Atenção")
    EndIf

    oExcel:DeActivate()
    ConOut('Activate: ' + Time())
Return 

Static Function LoadQuery(_cAliasG)
    Local cQry  := ""
    
    cQry := " SELECT RA_FILIAL AS FILIAL " + CRLF
    cQry += " 		, RA_MAT AS MATRICULA " + CRLF
    cQry += " 		, RA_NOME AS NOME " + CRLF 
    cQry += " 		, QB_DESCRIC AS DESCRI " + CRLF 
    cQry += " 		, ( SELECT SUM(((CASE WHEN P9_TIPOCOD = '2' THEN -1 ELSE 1 END) * (CAST(PI_QUANT AS INT)+((PI_QUANT-CAST(PI_QUANT AS INT))/60*100)))) 	AS PI_QUANT  " + CRLF 
    cQry += "  					FROM "+RetSqlName("SPI")+" SPI  " + CRLF 
    cQry += "  						LEFT JOIN "+RetSqlName("SP9")+" SP9 ON SP9.P9_FILIAL  = ''  " + CRLF 
    cQry += "  												AND SP9.P9_CODIGO = SPI.PI_PD  " + CRLF 
    cQry += "  												AND SP9.D_E_L_E_T_ = ''  " + CRLF 
    cQry += "  					WHERE SPI.PI_STATUS = ''  " + CRLF 
    cQry += "  					  AND SPI.PI_CC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'  " + CRLF 
    cQry += "  					  AND SPI.PI_DATA <= '"+dToS(MV_PAR06)+"'  " + CRLF 
    //cQry += "  					  AND SPI.PI_DATA BETWEEN '"+dToS(MV_PAR05)+"' AND '"+dToS(MV_PAR06)+"'  " + CRLF 
    cQry += "  					  AND SPI.PI_STATUS <> 'B'  " + CRLF
    cQry += " 					  AND SPI.PI_MAT = SRA.RA_MAT " + CRLF
    cQry += " 					  AND SPI.PI_FILIAL = SRA.RA_FILIAL " + CRLF
    cQry += "  					  AND SPI.D_E_L_E_T_ = '') AS SALDO_ATUAL " + CRLF
    cQry += " 		, ( SELECT SUM(((CASE WHEN P9_TIPOCOD = '2' THEN -1 ELSE 1 END) * (CAST(PI_QUANT AS INT)+((PI_QUANT-CAST(PI_QUANT AS INT))/60*100)))) 	AS PI_QUANT  " + CRLF 
    cQry += "  					FROM "+RetSqlName("SPI")+" SPI  " + CRLF 
    cQry += "  						LEFT JOIN "+RetSqlName("SP9")+" SP9 ON SP9.P9_FILIAL  = ''  " + CRLF 
    cQry += "  												AND SP9.P9_CODIGO = SPI.PI_PD  " + CRLF 
    cQry += "  												AND SP9.D_E_L_E_T_ = ''  " + CRLF 
    cQry += "  					WHERE SPI.PI_STATUS = ''  " + CRLF
    cQry += "  					  AND SPI.PI_CC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'  " + CRLF 
    cQry += "  					  AND SPI.PI_DATA < '"+dToS(MV_PAR05)+"' " + CRLF 
    cQry += "  					  AND SPI.PI_STATUS <> 'B'  " + CRLF
    cQry += " 					  AND SPI.PI_MAT = SRA.RA_MAT " + CRLF
    cQry += " 					  AND SPI.PI_FILIAL = SRA.RA_FILIAL " + CRLF
    cQry += "  					  AND SPI.D_E_L_E_T_ = '') AS SALDO_ANTERIOR " + CRLF 
    cQry += " FROM "+RetSqlName("SRA")+" SRA " + CRLF
    cQry += " JOIN "+RetSqlName("SQB")+" SQB ON SQB.QB_DEPTO = SRA.RA_DEPTO  " + CRLF 
    cQry += "  						AND SQB.D_E_L_E_T_ = ''  " + CRLF 
    cQry += " WHERE RA_DEMISSA = ''  " + CRLF 
    cQry += " AND SRA.RA_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  " + CRLF 
    cQry += " AND SRA.D_E_L_E_T_ = ''  " + CRLF
    cQry += " ORDER BY RA_FILIAL, QB_DESCRIC , RA_NOME " + CRLF

    if cUserName $ 'ioliveira,Administrador'
        memowrite("C:\TOTVS_RELATORIOS\VAGPER05.sql", cQry)
    endif

    MpSysOpenQuery(cQry,(_cAliasG))
    
Return !(_cAliasG)->(EOF())

Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local i,j
Local nPergs	:= 0

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

aAdd(aRegs,{cPerg, "01", "Filial de?"            , "", "", "MV_CH1", "C", TamSX3("RA_FILIAL")[1] , TamSX3("RA_FILIAL")[2], 0, "G", ""           , "MV_PAR01","","","","0101001"     ,"","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})
aAdd(aRegs,{cPerg, "02", "Filial ate?"           , "", "", "MV_CH2", "C", TamSX3("RA_FILIAL")[1] , TamSX3("RA_FILIAL")[2], 0, "G", "NAOVAZIO()" , "MV_PAR02","","","","ZZZZZZZ"     ,"","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})
aAdd(aRegs,{cPerg, "03", "Do Centro de Custo?"   , "", "", "MV_CH3", "C", TamSX3("RA_CC")[1]     , TamSX3("RA_CC")[2]    , 0, "G", ""           , "MV_PAR03","","","",""            ,"","","","","","","","","","","","","","","","","","","","","CTT","","","","",""})
aAdd(aRegs,{cPerg, "04", "Ao Centro de Custo?"   , "", "", "MV_CH4", "C", TamSX3("RA_CC")[1]     , TamSX3("RA_CC")[2]    , 0, "G", "NAOVAZIO()" , "MV_PAR04","","","","ZZZZZZZZZ"   ,"","","","","","","","","","","","","","","","","","","","","CTT","","","","",""})
aAdd(aRegs,{cPerg, "05", "Data de?"              , "", "", "MV_CH5", "D", 8                      , 0                     , 0, "G", ""           , "MV_PAR05","","","",""            ,"","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg, "06", "Data ate?"             , "", "", "MV_CH6", "D", 8                      , 0                     , 0, "G", "NAOVAZIO()" , "MV_PAR06","","","",""            ,"","","","","","","","","","","","","","","","","","","","","","","","","",""})
//aAdd(aRegs,{cPerg, "07", "Data ate?"             , "", "", "MV_CH7", "D", 8                      , 0                     , 0, "G", "NAOVAZIO()" , "MV_PAR07","","","",""            ,"","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

Static Function DefinirFormatacao()
    Local cCVerde       := '00A85A'
    Local cCCinza       := "A0A0A0"
    Local cCAmarelo     := "FFFF00"

    jFontHeader := FwXlsxPrinterConfig():MakeFont()
    jFontHeader['font'] := FwPrinterFont():Calibri()
    jFontHeader['size'] := 12
    jFontHeader['bold'] := .T.

    jFontTitulo := FwXlsxPrinterConfig():MakeFont()
    jFontTitulo['font'] := FwPrinterFont():Calibri()
    jFontTitulo['size'] := 14
    jFontTitulo['bold'] := .T.
    jFontTitulo['underline'] := .T.

    jFontText := FwXlsxPrinterConfig():MakeFont()
    jFontText['font'] := FwPrinterFont():Calibri()
    jFontText['size'] := 12
    jFontText['italic'] := .F.

    JFLeft := FwXlsxPrinterConfig():MakeFormat()
    JFLeft['hor_align']        := oCellHorAlign:Left()
    JFLeft['vert_align']       := oCellVertAlign:Center()

    JFRight := FwXlsxPrinterConfig():MakeFormat()
    JFRight['hor_align']        := oCellHorAlign:RIGHT()
    JFRight['vert_align']       := oCellVertAlign:Center()
    
    jFData := FwXlsxPrinterConfig():MakeFormat()
    jFData['custom_format']    := "dd/mm/yyyy"
    jFData['hor_align']        := oCellHorAlign:Left()
    jFData['vert_align']       := oCellVertAlign:Center()

    jFormatTit := FwXlsxPrinterConfig():MakeFormat()
    jFormatTit['hor_align']         := oCellHorAlign:Center()
    jFormatTit['vert_align']        := oCellVertAlign:Center()
    jFormatTit['background_color']  := cCVerde

    jFormatGD := FwXlsxPrinterConfig():MakeFormat()
    jFormatGD['hor_align']         := oCellHorAlign:Center()
    jFormatGD['vert_align']        := oCellVertAlign:Center()
    jFormatGD['background_color']  := cCAmarelo
    
    jFormatTot := FwXlsxPrinterConfig():MakeFormat()
    jFormatTot['custom_format']     := "\R$ ###,##0.00"
    jFormatTot['hor_align']         := oCellHorAlign:Center()
    jFormatTot['vert_align']        := oCellVertAlign:Center()
    jFormatTot['background_color']  := cCCinza

    jFormatHead := FwXlsxPrinterConfig():MakeFormat()
    jFormatHead['hor_align']         := oCellHorAlign:LEFT()
    jFormatHead['vert_align']        := oCellVertAlign:Center()
    jFormatHead['background_color']  := cCVerde //amarelo

    jFMoeda := FwXlsxPrinterConfig():MakeFormat()
    jFMoeda['custom_format']    := "\R$ ###,##0.00"
    jFMoeda['hor_align']        := oCellHorAlign:RIGHT()
    jFMoeda['vert_align']       := oCellVertAlign:Center()

    jFNum := FwXlsxPrinterConfig():MakeFormat()
    jFNum['hor_align']        := oCellHorAlign:Left()
    jFNum['vert_align']       := oCellVertAlign:Center()
    //jFNum['custom_format'] := "##:##"

    // Bordas para o header
    jNoBorder := FwXlsxPrinterConfig():MakeBorder()
    jNoBorder['top']    := .F.
    jNoBorder['bottom'] := .F.
    jNoBorder['left']   := .F.
    jNoBorder['right']  := .F.
    jNoBorder['border_color'] := "000000"
    jNoBorder['style'] := FwXlsxBorderStyle():None()

    jBHeaderLeft := FwXlsxPrinterConfig():MakeBorder()
    jBHeaderLeft['top']    := .T.
    jBHeaderLeft['bottom'] := .F.
    jBHeaderLeft['left']   := .T.
    jBHeaderLeft['right']  := .F.
    jBHeaderLeft['border_color'] := "000000"
    jBHeaderLeft['style'] := FwXlsxBorderStyle():Thick()

    jBHeaderRight := FwXlsxPrinterConfig():MakeBorder()
    jBHeaderRight['top']    := .T.
    jBHeaderRight['bottom'] := .F.
    jBHeaderRight['left']   := .F.
    jBHeaderRight['right']  := .T.
    jBHeaderRight['border_color'] := "000000"
    jBHeaderRight['style'] := FwXlsxBorderStyle():Thick()
    
    jBottomLeft := FwXlsxPrinterConfig():MakeBorder()
    jBottomLeft['top']    := .F.
    jBottomLeft['bottom'] := .T.
    jBottomLeft['left']   := .T.
    jBottomLeft['right']  := .F.
    jBottomLeft['border_color'] := "000000"
    jBottomLeft['style'] := FwXlsxBorderStyle():Thick()

    jBottomRight := FwXlsxPrinterConfig():MakeBorder()
    jBottomRight['top']    := .F.
    jBottomRight['bottom'] := .T.
    jBottomRight['left']   := .F.
    jBottomRight['right']  := .T.
    jBottomRight['border_color'] := "000000"
    jBottomRight['style'] := FwXlsxBorderStyle():Thick()

    jBorderLeft := FwXlsxPrinterConfig():MakeBorder()
    jBorderLeft['left'] := .T.
    jBorderLeft['border_color'] := "000000"
    jBorderLeft['style'] := FwXlsxBorderStyle():Thick()
    
    jBorderCenter := FwXlsxPrinterConfig():MakeBorder()
    jBorderCenter['left'] := .T.
    jBorderCenter['right'] := .T.
    jBorderCenter['border_color'] := "000000"
    jBorderCenter['style'] := FwXlsxBorderStyle():Thick()
    
    jBorderRight := FwXlsxPrinterConfig():MakeBorder()
    jBorderRight['right'] := .T.
    jBorderRight['border_color'] := "000000"
    jBorderRight['style'] := FwXlsxBorderStyle():Thick()

Return 
