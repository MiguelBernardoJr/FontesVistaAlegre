#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "color.ch"
#Include "TryException.ch"

#DEFINE oFBar      TFont():New( "Courier New"/*cName*/, /*uPar2*/, -08/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFTitLabel TFont():New( "Courier New"/*cName*/, /*uPar2*/, -16/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFLabel    TFont():New( "Courier New"/*cName*/, /*uPar2*/, -12/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )

#DEFINE oFLabelRed TFont():New( "Courier New"/*cName*/, /*uPar2*/, -16/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFInfo     TFont():New( "Arial"      /*cName*/, /*uPar2*/, -12/*nHeight*/, /*uPar4*/, .f./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFGrid     TFont():New( "Courier New"/*cName*/, /*uPar2*/, -10/*nHeight*/, /*uPar4*/, .f./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFInfoOBS  TFont():New( "Arial"      /*cName*/, /*uPar2*/, -12/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFheader   TFont():New( "Arial"      /*cName*/, /*uPar2*/, -08/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFontRecor TFont():New( "Tahoma"     /*cName*/, /*uPar2*/, -07/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )

#DEFINE CSSLABEL "QLabel {" +;
	"font-size:12px;" +;
	"font: 12px Arial;" +;
	"}"
/* 
User Function VACOMR15() //U_VACOMR15()
	Local _cQry, cAliasA
	Local aImprimir := {}

	cAliasA      := GetNextAlias() 

	_cQry := " select SC8.C8_PRODUTO " + CRLF
	_cQry += "  , SB1.B1_DESC " + CRLF
	_cQry += "  , ISNULL(CAST(CAST(SC8.C8_OBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS C8_OBS  " + CRLF
	_cQry += "  , SC8.C8_QUANT " + CRLF
	_cQry += "  , SB1.B1_UM " + CRLF
	_cQry += "  , SC8.C8_NUMSC" + CRLF
	_cQry += "  from "+RetSqlName("SC8")+" SC8 " + CRLF
	_cQry += "  LEFT JOIN "+RetSqlName("SB1")+" SB1 ON C8_PRODUTO = B1_COD  " + CRLF
	_cQry += "  AND SB1.D_E_L_E_T_ = ''  " + CRLF
	_cQry += "  where SC8.C8_FILIAL  = '" + FWxFilial("SC8") + "' " + CRLF
	_cQry += "  and SC8.C8_NUM = '007448' "+ CRLF 
	_cQry += "  and SC8.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "  GROUP BY SC8.C8_PRODUTO,SB1.B1_DESC,SC8.C8_OBS,SC8.C8_QUANT,SB1.B1_UM, SC8.C8_NUMSC " + CRLF
	_cQry += "  order by SC8.C8_PRODUTO,SB1.B1_DESC,SC8.C8_OBS,SC8.C8_QUANT,SB1.B1_UM, SC8.C8_NUMSC " + CRLF

	MpSysOpenQuery(_cQry,cAliasA)
	aImprimir := {}
	while !(cAliasA)->(EOF())
		aAdd(aImprimir,{;
						(cAliasA)->C8_PRODUTO,;
						(cAliasA)->B1_DESC,;
						(cAliasA)->C8_OBS,;
						(cAliasA)->C8_QUANT,;
						(cAliasA)->B1_UM,;
						(cAliasA)->C8_NUMSC,;
						(cAliasA)->C8_NUMSC,;
						FWxFilial("SC8");
						})
		(cAliasA)->(DbSkip())
	enddo

	(cAliasA)->(DbCloseArea())
	
	IF Len(aImprimir) > 0 
		U_VACOMR14(aImprimir)
	endif 
Return */

/*----------------------------------------------------------------------------------,
 | Principal: 					     U_VACOMR10()          		                    |
 | Func:    VACOMR10 	            	          	            	                |
 | Autor:   Igor Gomes OLiveira           	            	          	            |
 | Data:    03/2023                   	          	            	                |
 | Ob:      Relatorio;                                                              |
 | Rotina:  MATA131 e MATA150;                                                      |
 | Desc:    Gera Relatorio de cotação para ser enviado aos fornecedores;            |
 '----------------------------------------------------------------------------------|
 | Alter:                                                                           |
 | Obs.:                                                                            |
'----------------------------------------------------------------------------------*/
User Function VACOMR14(aDados/* aCotacao,cTempo,aConteudo */)
    Local aAreaSM0          := SM0->(GetArea())
    Local cTimeIni	        := Time()
    Local cArqName          := ""
    Local cServPath         := "\COTACOES_OBS\"
    Local cLocalPath        := "C:\TOTVS_RELATORIOS\COTACOES_OBS\"
    Private oPrinter        := nil
    Private aDadosR14       := aClone(aDados)

    If Len( Directory(cLocalPath + "*.*","D") ) == 0
        If Makedir(cLocalPath) == 0
            ConOut('Diretorio Criado com Sucesso.')
        Else	
            ConOut( "não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
            MsgAlert( "não foi possivel criar o diretório. Erro: " + cValToChar( FError() ), 'Aviso' )
        EndIf
    EndIF

    cArqName := FWxFilial("SC8") + aDadosR14[1][06] + "_" + StrTran(cTimeIni,":","-",,)

    DBSelectArea("SM0")
    SM0->(DBSetOrder(1))
    SM0->(DbSeek("01"+aDadosR14[01][08]))
    
    oPrinter := FWMSPrinter():New( cArqName, IMP_PDF/*nDevice*/ , .F./*lAdjustToLegacy*/, /*cPathInServer*/, .T./*lDisabeSetup*/,;
        /*lTReport*/, /*@oPrintSetup*/, /*cPrinter*/, /*lServer*/, .F./*lPDFAsPNG*/, /*lRaw*/,;
        .T. /*lViewPDF*/, /*nQtdCopy*/ )
    oPrinter:StartPage()
    oPrinter:SetPortrait()
    oPrinter:SetPaperSize(DMPAPER_A4) // DMPAPER_A4 = A4 210 x 297 mm
    oPrinter:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior
    oPrinter:cPathPDF := cLocalPath // Caso seja utilizada impressÃ£o em IMP_PDF

    RptStatus({|lEnd| ImpTicket(@lEnd)}, "Imprimindo relatorio...") //"A imprimir relatÃ³rio..."
    
    __CopyFile(cLocalPath+cArqName+".pdf", cServPath+cArqName+".pdf")

    RestArea(aAreaSM0)
Return nil

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  ImpTicket 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  29.09.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function ImpTicket( lEnd )
    Local nTotLinOBS    := 4
    Private nRow        := 30, nColLabel:=30, nColInfo :=110

    nTotLinha := (40/* linhas de textos */+3 /* linhas graficas de separacao */+nTotLinOBS/*linhas do campo de observacao*/)+2
    nTamLin   := /* 20 */ /* 19 */ 18.5
    
    oPrinter:Box( nRow*0.4, nBoxCol:=nColLabel*0.4, nBoxBottom:=(nTamLin*nTotLinha)*0.90, nBoxRight:=int(oPrinter:nPageWidth/4.15), cBoxPixel:="-4" )// ( 130, 10, 600, 900, "-4")
    fQuadro(1)

    oPrinter:EndPage()
    oPrinter:Preview()
    FreeObj(oPrinter)
    oPrinter := Nil

Return
/* 
    Igor Oliveira 
    Monta os quadros do relatÃ³rio
*/
Static Function fQuadro( nQuadro )
	Local nI        := 0
	Local nCol2     := 180
	Local nLineProd
	Local nLineObs
    Local cTxtAux
    Local cReplc    := 65
	Private nNumPag := 0

	Default nQuadro := 0

	nBitMWidth:=150

    oPrinter:Say ( nRow         , nColLabel, PADC(AllTrim(SM0->M0_NOMECOM), cReplc*1.1 )/*cText>*/, oFTitLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
	oPrinter:Line( nRow+=nTamLin-10/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )

	cTxtAux := AllTrim( aDadosR14[1][06] )
	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Cotação......:"/*cText>*/   , oFLabel/*oFont*/  , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo , cTxtAux/*cText>*/            , oFInfo/*oFont*/   , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	
    cTxtAux := AllTrim( aDadosR14[1][07] )
	oPrinter:Say ( nRow         , nColLabel+nCol2, "Solicitação..:"/*cText>*/   , oFLabel/*oFont*/  , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo+nCol2 , cTxtAux/*cText>*/             , oFInfo/*oFont*/   , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Line( nRow+=nTamLin-10/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )
   
	oPrinter:Say ( nRow+=nTamLin, nColLabel+nCol2, "NÃO ENVIAR PARA O FORNECEDOR!"/*cText>*/   , oFLabelRed/*oFont*/  , /*nWidth*/, CLR_RED, /*nAngle*/ )
	oPrinter:Line( nRow+=nTamLin-10/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )
   
    HeaderGrid()
	for nI := 1 to len(aDadosR14)
		if FimPagina(1) // Verifica se a Página está no final
			HeaderGrid()
			nI := nI - 1
		else
			oPrinter:Say ( nRow+=nTamLin - 6, nColLabel      , aDadosR14[nI][1]/*cText>*/,oFGrid /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
			nBakLine := nRow
			lpula := .f.
			if len(AllTrim(aDadosR14[nI][2])) > 45 
				cTxtAux := AllTrim(aDadosR14[nI][2])
				while AllTrim(cTxtAux) != ''
					nAt     := At(" ",cTxtAux,40)
					nPos    := Iif(len(cTxtAux)>40,Iif(nAt==0,len(cTxtAux),nAt),len(cTxtAux))
					cDesc   := SubStr(cTxtAux,1,nPos)
					cTxtAux := AllTrim(SubStr(cTxtAux,nPos+1,len(cTxtAux)))

					oPrinter:Say ( iif(lPula,nRow+=nTamLin-8,nRow)   , nColLabel+50      , cDesc/*cText>*/,oFGrid /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
					lPula := .t.
				enddo
			else
				oPrinter:Say ( nRow   , nColLabel+50      , aDadosR14[nI][2]/*cText>*/,oFGrid /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
			endif
            nLineProd := nRow
			nRow := nBakLine
			
            //nBakLine := nRow
			lpula := .f.
			if len(AllTrim(aDadosR14[nI][3])) > 35
				cTxtAux := AllTrim(aDadosR14[nI][3])
				while AllTrim(cTxtAux) != ''
					nAt     := At(" ",cTxtAux,40)
					nPos    := Iif(len(cTxtAux)>40,Iif(nAt==0,len(cTxtAux),nAt),len(cTxtAux))
					cDesc   := SubStr(cTxtAux,1,nPos)
					cTxtAux := AllTrim(SubStr(cTxtAux,nPos+1,len(cTxtAux)))

					oPrinter:Say ( iif(lPula,nRow+=nTamLin-8,nRow)   , nBoxRight-275      , cDesc/*cText>*/,oFGrid /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
					lPula := .t.
				enddo
			else
				oPrinter:Say ( nRow   , nBoxRight-275      , aDadosR14[nI][3]/*cText>*/,oFGrid /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
			endif
			nLineObs := nRow
			
			nRow := nBakLine //iif(nLineObs >= nRow,nLineObs,nRow)

            //qtde
			cTxtAux := lTrim(Str(aDadosR14[nI][4]))
			cTxtAux := AllTrim(Transform(aDadosR14[nI][4], "@r 999,999.999"))
			cTxtAux := StrTran(cTxtAux,",","|")
			cTxtAux := StrTran(cTxtAux,".",",")
			cTxtAux := StrTran(cTxtAux,"|",".")
			cTxtAux := iif(SubStr(cTxtAux,At(",",cTxtAux)+1,2) == '00',SubStr(cTxtAux,1,At(",",cTxtAux)-1),cTxtAux)
			oPrinter:box ( nRow - 10, nBoxRight-75  , nRow , nBoxRight-40, cBoxPixel)
			oPrinter:Say ( nRow - 2 , nBoxRight-73 , cTxtAux /*cText>*/,oFBar /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

			cTxtAux := aDadosR14[nI][05]
			//oPrinter:box ( nRow - 10, nBoxRight-215 , nRow , nBoxRight-200, cBoxPixel)
			oPrinter:box ( nRow - 10, nBoxRight-35  , nRow, nBoxRight-5  , cBoxPixel:="-4")
			oPrinter:Say ( nRow - 2 , nBoxRight-33 , cTxtAux/*cText>*/,oFBar /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

            nRow := iif(iif(nLineProd > nLineObs,nLineProd,nLineObs) < nRow , nRow, iif(nLineProd > nLineObs,nLineProd,nLineObs))
			oPrinter:Line( nRow+=nTamLin-15 /*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /* cColor */, cBoxPixel/*cPixel*/ )
		endif
	next nI

	cTxtAux := "Página " + Alltrim(Str(nNumPag+=1))
	oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-9,nColLabel   , "Agropecuária Vista Alegre LTDA"/*cText>*/   , oFInfo/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-9,nBoxRight-50, cTxtAux/*cText>*/  , oFInfo/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
Return

Static Function HeaderGrid()
	oPrinter:Say ( nRow+=nTamLin, nColLabel     , "CÓDIGO"/*cText>*/    ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	oPrinter:Say ( nRow+=nTamLin - 6, nBoxRight-275 , "OBSERVAÇÃO"/*cText>*/      ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow             , nColLabel+50  , "PRODUTO"/*cText>*/   ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow             , nColLabel     , "INTERNO"/*cText>*/   ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow             , nBoxRight-75  , "QTDE"/*cText>*/      ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow             , nBoxRight-35  , "UND"/*cText>*/       ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Line( nRow+=nTamLin-10/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /* cColor */, cBoxPixel/*cPixel*/ )
Return

Static Function FimPagina(nLocal)
	Local nDif
	Local lRet  := .F.
    Local cTxtAux := ""

	if nLocal == 1
		nDif := 20
	elseif nLocal == 2
		nDif := 10
		//nDif := 260
	elseif nLocal == 3
		nDif := 85
	else
		nDif := 130
	endif

	if (nBoxBottom - nRow) < nDif
		cTxtAux := "Página " + Alltrim(Str(nNumPag+=1))
		oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-10,nColLabel   , "Agropecuária Vista Alegre LTDA"/*cText>*/   , oFInfo/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
		oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-10,nBoxRight-50, cTxtAux/*cText>*/  , oFInfo/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )

		oPrinter:EndPage()
		oPrinter:startpage()
		nRow := 30
		oPrinter:Box( nRow*0.4, nBoxCol:=nColLabel*0.4, nBoxBottom:=(nTamLin*nTotLinha)*0.90, nBoxRight:=int(oPrinter:nPageWidth/4.15), cBoxPixel:="-4" )// ( 130, 10, 600, 900, "-4")
		nRow := 15
		lRet := !lRet
	endif

Return lRet

