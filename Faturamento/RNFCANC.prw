#include "Totvs.CH"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณRLFSO บAutor ณ FERNANDO FERES บ Data ณ 23/11/11 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc. ณ RELATำRIO DE CLIENTES COMERCIAIS บฑฑ
ฑฑบ ณ FORMATO GRAFICO ( RETRATO ) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCliente ณ Selten Engenharia บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑ Observa็๕es |Data Autor ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static oCellHorAlign    := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign   := FwXlsxCellAlignment():Vertical()

User Function RNFCANC() //U_RNFCANC()
	Local aCA 		:= {OemToAnsi("Confirma"),OemToAnsi("Abandona")}
	Local cCadastro := OemToAnsi("Impressao Fatura")
	Local aSays 	:= {}
	Local aButtons 	:= {}
	Local nOpca 	:= 0

	Private aReturn 	:= {OemToAnsi('Zebrado'), 1,OemToAnsi('Administracao'), 2, 2, 1, '',1 }
	Private nLastKey 	:= 0
	Private Modulo 		:= 11
	Private Moeda 		:= "9"
	Private nValor 		:= 0
	Private cPerg		:= SubS(ProcName(),3)
    Private cNomeEmp  	:= "AGROPECUมRIA VISTA ALEGRE LTDA"
    Private cTitulo  	:= "NOTAS FISCAIS "
    Private cPath 	 	:= "C:\totvs_relatorios\"
    Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
                                DtoS(dDataBase)+; 
                                "_"+;
                                StrTran(SubS(Time(),1,5),":","")+;
                                ".rel"
	
	Private jFontHeader := nil
	Private jFontTitulo := nil
	Private jFontText 	:= nil
	Private JFLeft 		:= nil
	Private jFData 		:= nil
	Private jFormatTit 	:= nil
	Private jFormatTot 	:= nil
	Private jFormatHead := nil
	Private JNOBORDER 	:= nil
	Private jFMoeda 	:= nil
	Private jFNum 		:= nil

	GeraX1(cPerg)

	pergunte("RNFCANC",.F.)

	AAdd(aSays,OemToAnsi( " Este programa ira imprimir o relat๓rio de Notas Fiscais Canceladas e Inutilizadas"))

	AAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	AAdd(aButtons, { 1,.T.,{|| nOpca := 1,FechaBatch() }} )
	AAdd(aButtons, { 2,.T.,{|| nOpca := 0,FechaBatch() }} )

	FormBatch( cCadastro, aSays, aButtons )
	
	If nOpca == 1
		cTitulo += IIF(MV_PAR07 == 3,"CANCELADAS E INUTILIZADAS", IIF(MV_PAR07 == 1,"CANCELADAS","INUTILIZADAS"))
		Processa( { |lEnd| LoadQuery() })
	Endif

Return

Static Function LoadQuery()
	Local oPrn		:= Nil
    Local aArea     := FWGetArea()
	Local cQry 		:= " "
	Private cALias 	:= GetNextAlias()

	IF MV_PAR07 == 1 //CANCELADAS
		cQry := "SELECT * " + CRLF
		cQry += "FROM "+RetSqlName("SF3")+" SF3 " + CRLF
		cQry += "WHERE SF3.F3_FILIAL = '"+FWxFilial("SF3")+"' AND " + CRLF
		cQry += "SF3.F3_SERIE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND " + CRLF
		cQry += "SF3.F3_EMISSAO BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND " + CRLF
		cQry += "SF3.F3_DTCANC BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"' AND " + CRLF
		cQry += "SF3.F3_CODRSEF <> '102' AND " + CRLF
		cQry += "SF3.D_E_L_E_T_ <> '*' " + CRLF
		cQry += "ORDER BY SF3.F3_SERIE, SF3.F3_NFISCAL " + CRLF
	ENDIF

	IF MV_PAR07 == 2 //INUTILIZADAS
		cQry := "SELECT * " + CRLF
		cQry += "FROM "+RetSqlName("SF3")+" SF3 "  + CRLF
		cQry += "WHERE SF3.F3_FILIAL = '"+FWxFilial("SF3")+"' AND " + CRLF
		cQry += "SF3.F3_SERIE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND " + CRLF
		cQry += "SF3.F3_EMISSAO BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND " + CRLF
		cQry += "SF3.F3_DTCANC BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"' AND " + CRLF
		cQry += "SF3.F3_CODRSEF = '102' AND " + CRLF
		cQry += "SF3.D_E_L_E_T_ <> '*' " + CRLF
		cQry += "ORDER BY SF3.F3_SERIE, SF3.F3_NFISCAL " + CRLF
	ENDIF

	IF MV_PAR07 == 3 //TODAS
		cQry := "SELECT * " + CRLF
		cQry += "FROM "+RetSqlName("SF3")+" SF3 "  + CRLF
		cQry += "WHERE SF3.F3_FILIAL = '"+FWxFilial("SF3")+"' AND " + CRLF
		cQry += "SF3.F3_SERIE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND " + CRLF
		cQry += "SF3.F3_EMISSAO BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND " + CRLF
		cQry += "SF3.F3_DTCANC BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"' AND " + CRLF
		cQry += "SF3.D_E_L_E_T_ <> '*' " + CRLF
		cQry += "ORDER BY SF3.F3_SERIE, SF3.F3_NFISCAL " + CRLF
	ENDIF

	MpSysOpenQry(cQry, cAlias)
	(cAlias)->(DbGotop())

	If (cAlias)->(Eof())
		MsgInfo("Nao existem registros com o filtro escolhido!")
		set filter to
		dbGotop()
		(cAlias)->(DbCloseArea())
	else
		IF MV_PAR08 == 1
			Processa( { |lEnd| ImpPDF(oPrn) })
		ELSE
			Processa( { |lEnd| ImpExcel(oPrn) })
		ENDIF
	EndIf
	
	FwRestArea(aArea)
Return

/* Imprime relat๓rio em PDF */
Static Function ImpPDF(oPrn)

	nPag := 1

	oPrn:= TMSPrinter():New()
	oPrn:SetPortrait()
	oPrn:SetPaperSize(9) // A4
	oPrn:Setup()
	oPrn:StartPage()

	oFont1:= TFont():New( "Courier New",,10,,.F.,,,,,.F. )
	oFont2:= TFont():New( "Courier New",,10,,.T.,,,,,.F. ) // NEGRITO
	oFont3:= TFont():New( "Courier New",,09,,.F.,,,,,.F. )
	oFont4:= TFont():New( "Courier New",,21,,.T.,,,,,.F. ) // NEGRITO
	oFont5:= TFont():New( "Courier New",,28,,.F.,,,,,.F. )
	oFont6:= TFont():New( "Courier New",,16,,.T.,,,,,.F. ) // NEGRITO
	oFont7:= TFont():New( "Courier New",,18,,.T.,,,,,.F. ) // NEGRITO

	oFont8:= TFont():New( "Times New Roman",,10,,.T.,,,,.T.,.F. ) // NEGRITO
	oFont9:= TFont():New( "Times New Roman",,16,,.T.,,,,.T.,.F. ) // NEGRITO
	oFont10:= TFont():New( "Times New Roman",,11,,.F.,,,,,.F. )

	cBitMap:= "LGRL01.BMP"
	cBitIso:= ""
	cBitSel:= "LOGO_TOPFIVE.BMP"
	oPrn:Say(040,0750,"AGROPECUมRIA VISTA ALEGRE LTDA",oFont7,100)
	oPrn:Say(120,0400,"NOTAS FISCAIS "+IIF(MV_PAR07 == 3,"CANCELADAS E INUTILIZADAS", IIF(MV_PAR07 == 1,"CANCELADAS","INUTILIZADAS"))+" ",oFont7,100)
	oPrn:SayBitmap(040,040,cBitMap,307,150 ) //700,300
	oPrn:Say(040,2000,"Emissใo .: "+ DtoC(Date()),oFont8,100)
	oPrn:Say(080,2000,"Hora .: "+ Time(),oFont8,100)
	oPrn:Say(120,2000,"Pแgina .: "+ "01" ,oFont8,100)
	oPrn:Box(040+0000,0040,185+0000,2370)
	oPrn:Box(040+0000,0345,185+0000,1990)

	Impress(oPrn)

	If !Eof()
		oPrn:EndPage()
		oPrn:StartPage()
	Endif

	Set Filter to

	oPrn:EndPage()
	oPrn:Preview()
	MS_FLUSH()
Return

Static Function Impress(oPrn)
	_nLin := 0
	nPag := 01

	(cAlias)->(DbGotop())

	While !(cAlias)->(Eof())

		cNF 	:= (cAlias)->F3_SERIE+(cAlias)->F3_NFISCAL
		cValor 	:= transform((cAlias)->F3_VALCONT, "@E 999,999,999.99")
		cNome 	:= ""
		cStatus := ""
		cCont := ""
		cAviso := (cAlias)->F3_NFISCAL
		cClient := ""//(cAlias)->F3_CLIENT
		cEmiss := Substr((cAlias)->F3_EMISSAO,7,2)+ "/" + Substr((cAlias)->F3_EMISSAO,5,2) + "/" + Substr((cAlias)->F3_EMISSAO,1,4)
		cCanc := Substr((cAlias)->F3_DTCANC,7,2)+ "/" + Substr((cAlias)->F3_DTCANC,5,2) + "/" + Substr((cAlias)->F3_DTCANC,1,4)

		If (cAlias)->F3_CLIEFOR == (cAlias)->F3_CLIENT
			cClient := (cAlias)->F3_CLIENT

			dbSelectArea("SA1")
			dbSetOrder(1)
			If dbSeek(FWxFilial()+cClient)
				cNome := SA1->A1_NOME
			Endif
		Endif

		If (cAlias)->F3_CLIEFOR <>(cAlias)->F3_CLIENT
			cClient := (cAlias)->F3_CLIEFOR

			dbSelectArea("SA2")
			dbSetOrder(1)
			If dbSeek(FWxFilial()+cClient)
				cNome := SA2->A2_NOME
			Endif

			dbSelectArea("SA1")
			dbSetOrder(1)
			If dbSeek(FWxFilial()+cClient)
				cNome := SA1->A1_NOME
			Endif
		Endif

		If (cAlias)->F3_CODRSEF == "102"
			cStatus := "NOTA INUTILIZADA"
		Else
			cStatus := "NOTA CANCELADA"
		Endif

		oPrn:Say(_nLin+0215,0320,"SษRIE.: " + (cAlias)->F3_SERIE ,oFont8,100) //0065
		oPrn:Box(_nLin+0210,0040,_nLin+0260,500) //0040

		oPrn:Say(_nLin+0215,0065,"N.F.: " + (cAlias)->F3_NFISCAL ,oFont8,100) //320

		oPrn:Say(_nLin+0215,520,"CLIENTE/FORNECEDOR.: " + Transform(cNome, "@!") ,oFont8,100)
		oPrn:Box(_nLin+0210,500,_nLin+0260,2370)//1700

		oPrn:Say(_nLin+0265,0065,"EMISSรO.: " + cEmiss ,oFont8,100)
		oPrn:Box(_nLin+0260,0040,_nLin+0310,500)

		oPrn:Say(_nLin+0265,520,"CANCELAMENTO.: " + cCanc ,oFont8,100) //cCanc
		oPrn:Box(_nLin+0260,500,_nLin+0310,1150)

		oPrn:Say(_nLin+0265,1170,"VALOR.: R$ " + cValor ,oFont8,100) //cCanc
		oPrn:Box(_nLin+0260,1150,_nLin+0310,1700)

		oPrn:Say(_nLin+0265,1720,"STATUS.: " + cStatus ,oFont8,100) //cCanc
		oPrn:Box(_nLin+0260,1700,_nLin+0310,2370)

		(cAlias)->(DbSkip())

		_nLin += 0150
		If _nLin > 3100 //2700

			oPrn:Say(_nLin+0200,600,"* * * * CONTINUA NA PRำXIMA PมGINA * * * *" ,oFont8,100) //cCanc
			_nLin := 0000
			nPag := nPag+1
			oPrn:EndPage()
			oPrn:StartPage()

			cBitMap:= "LGRL01.BMP"
			cBitIso:= ""
			cBitSel:= "LOGO_TOPFIVE.BMP"
			oPrn:Say(040,0750,"AGROPECUมRIA VISTA ALEGRE LTDA",oFont7,100)
			oPrn:Say(120,0375,"NOTAS FISCAIS "+IIF(MV_PAR07 == 3,"CANCELADAS E INUTILIZADAS", IIF(MV_PAR07 == 1,"CANCELADAS","INUTILIZADAS"))+" ",oFont7,100) // oPrn:Say(120,0775,"RELATำRIO DE NOTAS FISCAIS CANCELADAS E INUTILIZADAS",oFont7,100)
			oPrn:SayBitmap(040,040,cBitMap,307,150 ) //700,300
			oPrn:Say(040,2000,"Emissใo .: "+ DtoC(Date()),oFont8,100)
			oPrn:Say(080,2000,"Hora .: "+ Time(),oFont8,100)
			oPrn:Say(120,2000,"Pแgina .: "+ StrZero(nPag,2),oFont8,100)
			oPrn:Box(040+0000,0040,185+0000,2370)
			oPrn:Box(040+0000,0345,185+0000,1990)

		Endif

	EndDo

	(cAlias)->(DbCloseArea())
	SC5->(DbCloseArea())
	SA1->(DbCloseArea())
Return
/* Imprime em Excel */
Static Function ImpExcel(oPrn)
    Local aArea         := FWGetArea()
    Local lRet          := .F.
    Local nRet          := 0
    Local nX := 0
    Local aHeaderRel    := {"CำDIGO",;
                            "LOJA",;
                            "CLIENTE / FORNECEDOR",;
                            "TIPO",;
                            "NF",;
                            "SษRIE",;
                            "STATUS",;
                            "EMISSรO",;
                            "CANCELAMENTO",;
                            "VALOR" }
	Local cClient 	:= ""
	Local cLoja 	:= ""
	Local cTipo		:= ""
	Local cNome		:= ""

	DefinirFormatacao()

	SA1->(dbSelectArea("SA1"))
	SA1->(dbSetOrder(1))

	SA2->(dbSelectArea("SA2"))
	SA2->(dbSetOrder(1))

	if !(cAlias)->(EOF())
		oPrn := FwPrinterXlsx():New()
		oPrn:Activate(cArquivo)
		
		oPrn:AddSheet("Aba 1")

		nRow := 1
		nCol := 1
		
		oPrn:SetCellsFormatConfig(jFormatTit)
		oPrn:SetFontConfig(jFontTitulo)
		oPrn:MergeCells(nRow, nCol, nRow, Len(aHeaderRel))
		oPrn:SetText(nRow, nCol, cTitulo)

		//Printando Cabe็alho
		oPrn:SetCellsFormatConfig(jFormatHead)
		oPrn:SetFontConfig(jFontHeader)
		nRow += 1
		For nX := nCol to Len(aHeaderRel)
			oPrn:SetValue(nRow, nX, aHeaderRel[nX])
		Next nX

		While !(cAlias)->(EOF())
			nRow += 1
			nCol := 1
			
			cClient := (cAlias)->F3_CLIEFOR
			cLoja 	:= (cAlias)->F3_LOJA

			If SA2->(dbSeek(FWxFilial("SA2")+cClient))
				cNome := SA2->A2_NOME
				cTIpo := "FORNECEDOR"
			Endif

			If SA1->(dbSeek(FWxFilial("SA1")+cClient))
				cNome := SA1->A1_NOME
				cTIpo := "CLIENTE"
			Endif

			oPrn:SetFontConfig(jFontText)
			oPrn:SetCellsFormatConfig(JFLeft)
			oPrn:SetBorderConfig(jNoBorder)
			
			oPrn:SetValue(nRow, nCol  ,   cClient)
			oPrn:SetValue(nRow, ++nCol,   cLoja)
			oPrn:SetValue(nRow, ++nCol,   Alltrim(cNome))
			oPrn:SetValue(nRow, ++nCol,   cTIpo)
			
			If (cAlias)->F3_CODRSEF == "102"
				oPrn:SetValue(nRow, ++nCol, "NOTA INUTILIZADA")
			Else
				oPrn:SetValue(nRow, ++nCol, "NOTA CANCELADA")
			Endif

			oPrn:SetValue(nRow, ++nCol, AllTrim((cAlias)->F3_NFISCAL))
			oPrn:SetValue(nRow, ++nCol, AllTrim((cAlias)->F3_SERIE))
			
			oPrn:SetValue(nRow, ++nCol, dToC(sToD((cAlias)->F3_EMISSAO)) )
			oPrn:SetValue(nRow, ++nCol, dToC(sToD((cAlias)->F3_DTCANC )) )

			oPrn:SetCellsFormatConfig(jFMoeda)
			oPrn:SetValue(nRow, ++nCol, (cAlias)->F3_VALCONT)
			
			(cAlias)->(DbSkip())
		enddo

		oPrn:ApplyAutoFilter(2,1,nRow,Len(aHeaderRel))
		nRowTotal := nRow
		nRow += 1
		oPrn:SetFormula(nRow, 10, "=SUBTOTAL(9,J3:J"+AllTrim(cValToChar(nRowTotal))+")" )
		
		oPrn:toXlsx()

		nRet := ShellExecute("open", SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx", "", "", 1)

		//Se houver algum erro
		If nRet <= 32
			MsgStop("Nใo foi possํvel abrir o arquivo "+SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx"+ "!", "Aten็ใo")
		EndIf 

		oPrn:DeActivate()
	endif
	
	SA1->(DbCloseArea())
	SA2->(DbCloseArea())

	FwRestArea(aArea)
Return

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

Static Function GeraX1(cPerg)
	Local _aArea	:= GetArea()
	Local nX		:= 0
	Local nPergs	:= 0
	Local i         := 0
	Local j         := 0
	Local aRegs		:= {}

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

	AADD( aRegs, { cPerg, "01", "S้rie de:          ", "", "", "mv_ch1", TamSX3("F3_SERIE")[3]  , TamSX3("F3_SERIE")[1]  , TamSX3("F3_SERIE")[2]  , 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0", "S", "" ,"" ,"", "", {"Informe o c๓digo da filial desejada ou deixe em branco."  , "<F3 Disponivel>"}, {""}, {""} } )
	AADD( aRegs, { cPerg, "02", "S้rie Ate:         ", "", "", "mv_ch2", TamSX3("F3_SERIE")[3]  , TamSX3("F3_SERIE")[1]  , TamSX3("F3_SERIE")[2]  , 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0", "S", "" ,"" ,"", "", {"Informe o c๓digo da filial desejada ou deixe em branco."  , "<F3 Disponivel>"}, {""}, {""} } )
	AADD( aRegs, { cPerg, "03", "Emissao De:     	", "", "", "mv_ch3", TamSX3("F3_EMISSAO")[3], TamSX3("F3_EMISSAO")[1], TamSX3("E3_EMISSAO")[2], 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", "S", "" ,"" ,"", "", {"Informe a Dt. de Emissao Inicial                       "  , "<F3 Disponivel>"}, {""}, {""} } )
	AADD( aRegs, { cPerg, "04", "Emissao Ate:    	", "", "", "mv_ch4", TamSX3("F3_EMISSAO")[3], TamSX3("F3_EMISSAO")[1], TamSX3("E3_EMISSAO")[2], 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", "S", "" ,"" ,"", "", {"Informe a Dt. de Emissao Final                         "  , "<F3 Disponivel>"}, {""}, {""} } )
	AADD( aRegs, { cPerg, "05", "Cancelamento de:  	", "", "", "mv_ch5", TamSX3("F3_EMISSAO")[3], TamSX3("F3_EMISSAO")[1], TamSX3("F3_EMISSAO")[2], 0, "G", "", "mv_par05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA3", "S", "" ,"" ,"", "", {"Informe o c๓digo do Vendedor desejada ou deixe em branco.", "<F3 Disponivel>"}, {""}, {""} } )
	AADD( aRegs, { cPerg, "06", "Cancelamento  Ate:	", "", "", "mv_ch6", TamSX3("F3_EMISSAO")[3], TamSX3("F3_EMISSAO")[1], TamSX3("F3_EMISSAO")[2], 0, "G", "", "mv_par06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA3", "S", "" ,"" ,"", "", {"Informe o c๓digo do Vendedor desejada ou deixe em branco.", "<F3 Disponivel>"}, {""}, {""} } )
	aAdd( aRegs, { cPerg ,"07", "Status				", "", "", "mv_ch7", "C"					, 1						 , 0					  , 2, "C", "", "mv_par07","Cancelado","","","","","Inutilizado","","","","","Ambos","","","","","","","","","","","","","","","U","","","",""})
	aAdd( aRegs, { cPerg ,"08", "Tipo de arquivo:	", "", "", "mv_ch8", "C"					, 1						 , 0					  , 2, "C", "", "mv_par08","PDF","","","","","Excel","","","","",""     ,"","","","","","","","","","","","","","","U","","","",""})

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

	// grava็ใo das perguntas na tabela SX1
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
Return 
