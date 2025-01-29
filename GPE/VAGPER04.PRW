#include 'FILEIO.CH'
#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"

static oCellHorAlign    := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign   := FwXlsxCellAlignment():Vertical()

/*---------------------------------------------------------------------------------,
 | Analista : Igor Gomes Oliveira                                                  |
 | Data		: 05.05.2023                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatorio com Saldo de Vale Alimentacao por periodo.  		       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_VAGPER04()                                                         |
 '---------------------------------------------------------------------------------*/
User Function VAGPER04()
    Local cTimeIni	 	:= Time()
    Local aArea         := GetArea()
    Local lTemDados     := .T.
    Private cPerg		:= SubS(ProcName(),3)
    Private _cAliasG	:= GetNextAlias()
    Private cTitulo  	:= "Lista_Click_Money"
    Private cPath 	 	:= "C:\totvs_relatorios\"
    Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
                                DtoS(dDataBase)+; 
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
    Local nVlrDia   := MV_PAR04 / 30
    Local lRet      := .T. 
    Local aHeaderRel    := {"Filial",;
                        "Matricula",;
                        "Nome",;
                        "Centro de Custo",;
                        "Departamento",;
                        "CPF",;
                        "Sexo",;
                        "Data Nasc.",;
                        "Dias",;
                        "Valor"}
    
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
        oExcel:SetValue(nRow, nCol  , (_cAliasG)->RD_FILIAL )
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->RD_MAT )
        oExcel:SetValue(nRow, ++nCol, ALLTRIM((_cAliasG)->RA_NOME) )
        oExcel:SetValue(nRow, ++nCol, RTRIM((_cAliasG)->RD_CC) )
        oExcel:SetValue(nRow, ++nCol, RTRIM((_cAliasG)->QB_DESCRIC) )
        oExcel:SetValue(nRow, ++nCol, Transform(Alltrim((_cAliasG)->RA_CIC), "@R 999.999.999-99"))
        oExcel:SetValue(nRow, ++nCol, iif((_cAliasG)->RA_SEXO  == 'M','Masculino','Feminino'))
        
        oExcel:SetCellsFormatConfig(jFData)
        oExcel:SetValue(nRow, ++nCol, sToD((_cAliasG)->RA_NASC))

        oExcel:SetCellsFormatConfig(jFNum)
        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->RD_HORAS)//DIAS
        oExcel:SetValue(nRow, ++nCol, nVlrDia * (_cAliasG)->RD_HORAS  )//VALOR
        
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
    Local cQry      := ""
    Local aVerbas   := StrTokArr(AllTrim(mv_par05),";")
    Local cVerbas   := ''
    Local nI 

    For nI := 1 to nTot := Len(aVerbas)
        cVerbas += "'" + aVerbas[nI] + iif(nI < nTot,"',","'" )
    Next 

    cQry := "select RD_FILIAL, RD_MAT,RD_CC,QB_DESCRIC, RA_NOME, RA_CIC, RA_SEXO,RA_NASC, RD_DATARQ,SUM(RD_HORAS) AS RD_HORAS " + CRLF
    cQry += "  FROM ( " + CRLF
    cQry += " 	 select RD_FILIAL, RD_MAT,RD_CC,QB_DESCRIC, RA_NOME, RA_CIC, RA_SEXO,RA_NASC, RD_HORAS, RD_DATARQ " + CRLF
    cQry += " 	 from "+RetSqlName("SRD")+" RD  " + CRLF
    cQry += " 	 JOIN "+RetSqlName("SRA")+" RA ON RD_FILIAL = RA_FILIAL  " + CRLF
    cQry += " 	 AND RD_MAT = RA_MAT  " + CRLF
    cQry += " 	 AND RA.D_E_L_E_T_ = ''  " + CRLF
    cQry += " 	 JOIN "+RetSqlName("CTT")+" CTT ON RD_CC = CTT_CUSTO  " + CRLF
    cQry += " 	 AND RD_FILIAL = CTT_FILIAL  " + CRLF
    cQry += " 	 AND CTT.D_E_L_E_T_ = ''  " + CRLF
    cQry += " 	 JOIN "+RetSqlName("SQB")+" QB ON RA_DEPTO = QB_DEPTO " + CRLF
	cQry += "    AND QB.D_E_L_E_T_ = ''  " + CRLF
    cQry += " 	 where RD_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+mv_par02+"'   " + CRLF
    cQry += " 	 AND RD_DATARQ = '"+MV_PAR03+"'   " + CRLF
    cQry += " 	 AND RD_PD IN ('101') " + CRLF
    //cQry += " 	 AND RD_TIPO1 = 'D' " + CRLF
    cQry += "  AND RD.D_E_L_E_T_ = ''  " + CRLF
    cQry += "  UNION ALL  " + CRLF
    cQry += " 	 select RD_FILIAL, RD_MAT,RD_CC,QB_DESCRIC, RA_NOME, RA_CIC, RA_SEXO,RA_NASC, RD_HORAS, RD_DATARQ " + CRLF
    cQry += " 	 from "+RetSqlName("SRD")+" RD  " + CRLF
    cQry += " 	 JOIN "+RetSqlName("SRA")+" RA ON RD_FILIAL = RA_FILIAL  " + CRLF
    cQry += " 	 AND RD_MAT = RA_MAT  " + CRLF
    cQry += " 	 AND RA.D_E_L_E_T_ = ''  " + CRLF
    cQry += " 	 JOIN "+RetSqlName("CTT")+" CTT ON RD_CC = CTT_CUSTO  " + CRLF
    cQry += " 	 AND RD_FILIAL = CTT_FILIAL  " + CRLF
    cQry += " 	 AND CTT.D_E_L_E_T_ = ''  " + CRLF
    cQry += " 	 JOIN "+RetSqlName("SQB")+" QB ON RA_DEPTO = QB_DEPTO " + CRLF
	cQry += "    AND QB.D_E_L_E_T_ = ''  " + CRLF
    cQry += " 	 where RD_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+mv_par02+"'   " + CRLF
    cQry += " 	 AND RD_DATARQ = '"+MV_PAR03+"'   " + CRLF
    cQry += " 	 AND RD_PD IN ("+cVerbas+") " + CRLF
    cQry += " 	 AND RD.D_E_L_E_T_ = ''  " + CRLF
    cQry += "  ) TOTAL " + CRLF
    cQry += "  GROUP BY RD_FILIAL, RD_MAT, RD_CC,QB_DESCRIC, RA_NOME, RA_CIC, RA_SEXO,RA_NASC, RD_DATARQ " + CRLF
    cQry += "  ORDER BY RD_FILIAL,QB_DESCRIC, RD_MAT " + CRLF
    
    if cUserName $ 'ioliveira'
        memowrite("C:\TOTVS_RELATORIOS\VAGPER04.sql", cQry)
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

aAdd(aRegs,{cPerg, "01", "Filial de?"   , "", "", "MV_CH1", "C", TamSX3("RA_FILIAL")[1] , TamSX3("RA_FILIAL")[2], 0, "G", ""        , "MV_PAR01","","","","0101001" ,"","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})
aAdd(aRegs,{cPerg, "02", "Filial ate?"  , "", "", "MV_CH2", "C", TamSX3("RA_FILIAL")[1] , TamSX3("RA_FILIAL")[2], 0, "G", ""        , "MV_PAR02","","","","ZZZZZZZ" ,"","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})
aAdd(aRegs,{cPerg, "03", "Periodo?"     , "", "", "MV_CH3", "C", 6                      , 0                     , 0, "G", ""        , "MV_PAR03","","","",""        ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "04", "Valor?"       , "", "", "MV_CH4", "N", 6                      , 2                     , 0, "G", "NaoVazio", "MV_PAR04","","","",""        ,"","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "05", "Verbas?"      , "", "", "MV_CH5", "C", 50                     , 0                     , 0, "G", ""        , "MV_PAR05","","","","176,360" ,"","","","","","","","","","","","","","","","","","","","","SRV","","","","",""})

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
    jFormatHead['background_color']  := "A0A0A0" //amarelo

    jFMoeda := FwXlsxPrinterConfig():MakeFormat()
    jFMoeda['custom_format']    := "\R$ ###,##0.00"
    jFMoeda['hor_align']        := oCellHorAlign:RIGHT()
    jFMoeda['vert_align']       := oCellVertAlign:Center()

    jFNum := FwXlsxPrinterConfig():MakeFormat()
    jFNum['hor_align']        := oCellHorAlign:Left()
    jFNum['vert_align']       := oCellVertAlign:Center()

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
