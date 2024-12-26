#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#Include "TryException.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
Static nCorCinza := rgb(230,230,230)
Static nCorRoxo  := rgb(231,204,255)


#DEFINE oFBar      TFont():New( "Courier New"/*cName*/, /*uPar2*/, -08/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFTitLabel TFont():New( "Courier New"/*cName*/, /*uPar2*/, -12/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFLabel    TFont():New( "Courier New"/*cName*/, /*uPar2*/, -10/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFInfo     TFont():New( "Courier New"/*cName*/, /*uPar2*/, -10/*nHeight*/, /*uPar4*/, .f./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFInfoBold TFont():New( "Courier New"/*cName*/, /*uPar2*/, -10/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFGrid     TFont():New( "Courier New"/*cName*/, /*uPar2*/, -10/*nHeight*/, /*uPar4*/, .f./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFGridInfo TFont():New( "Courier New"/*cName*/, /*uPar2*/, -7/*nHeight*/, /*uPar4*/, .f./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFGridInfoB TFont():New( "Courier New"/*cName*/, /*uPar2*/, -7/*nHeight*/, /*uPar4*/, .t./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFInfoOBS  TFont():New( "Arial"      /*cName*/, /*uPar2*/, -16/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFheader   TFont():New( "Arial"      /*cName*/, /*uPar2*/, -08/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFontRecor TFont():New( "Tahoma"     /*cName*/, /*uPar2*/, -07/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )

#DEFINE CSSLABEL "QLabel {" +;
    "font-size:12px;" +;
    "font: 12px Arial;" +;
    "}"

/*----------------------------------------------------------------------------------,
 | Principal: 					     U_VACOMR11()          		                    |
 | Func:    VACOMR11 	            	          	            	                |
 | Autor:   Igor Gomes OLiveira           	            	          	            |
 | Data:    03/2023                   	          	            	                |
 | Ob:      Relatorio;                                                              |
 | Rotina:  MATA131 e MATA150;                                                      |
 | Desc:    Gera Relatorio de cotação para ser enviado aos fornecedores;            |
 '----------------------------------------------------------------------------------|
 | Alter:                                                                           |
 | Obs.:                                                                            |
'----------------------------------------------------------------------------------*/
User Function VACOMR11()
    Private cTimeIni	    := Time()
    Private oPrinter        := nil
    Private aDados
    Private cKey            := ""
    Private cArqName        
    Private cServPath       := "\PEDIDOS\"
    Private cLocalPath      := "C:\TOTVS_RELATORIOS\PEDIDOS\"
    Private cMailFornece    
    Private nTamVerPx       
    Private nTamHorPx       
    Private oBrushCinza    := TBRUSH():New(,nCorCinza)
    Private oBrushRoxo     := TBRUSH():New(,nCorRoxo)

    aDados := fGetDados()

	If Len( Directory(cLocalPath + "*.*","D") ) == 0
		If Makedir(cLocalPath) == 0
			ConOut('Diretorio Criado com Sucesso.')
			MsgAlert('Diretorio Criado com Sucesso: ' + cLocalPath, 'Aviso')
		Else	
			ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
			MsgAlert( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ), 'Aviso' )
		EndIf
	EndIf

    if Empty(aDados)
        RETURN
    endif
    
    cArqName := AllTrim(aDados[01][02]) + "-"+ StrTran(cTimeIni,":","-",,)
    
    oPrinter := FWMSPrinter():New( cArqName, IMP_PDF/*nDevice*/ , .F./*lAdjustToLegacy*/, /*cPathInServer*/, .T./*lDisabeSetup*/,;
        /*lTReport*/, /*@oPrintSetup*/, /*cPrinter*/, /*lServer*/, .F./*lPDFAsPNG*/, /*lRaw*/,;
        .T. /*lViewPDF*/, /*nQtdCopy*/ )
    oPrinter:StartPage()
    oPrinter:SetPortrait()
    oPrinter:SetPaperSize(DMPAPER_A4) // DMPAPER_A4 = A4 210 x 297 mm
    nTamVerPx := oPrinter:nLogPixelX()
    nTamHorPx := oPrinter:nLogPixelY()
    oPrinter:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior
    oPrinter:cPathPDF := cLocalPath // Caso seja utilizada impressão em IMP_PDF

    RptStatus({|lEnd| ImpTicket(@lEnd)}, "Imprimindo relatorio...") //"A imprimir relatório..."

    //__CopyFile(cLocalPath+cArqName+".pdf", cServPath+cArqName+".pdf")

Return
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
    Private nRow        := 30, nColLabel:=30, nColInfo := 100
    Private cTxtAux     := ""
    Private cLogo       := "\system\lgrl" + AllTrim(cEmpAnt) + ".bmp"
    Private cReplc      := 65
    Private nTotLinOBS  := 4
    Private nPosSeq     := nColLabel-15
    Private nPosQtd     := nColLabel+15
    Private nPosUnd     := nColLabel+65
    Private nPosCod     := nColLabel+85.75
    Private nPosProd    := nColLabel+130
    Private nPosUnit    := nColLabel+325
    Private nPosICMS    := nColLabel+375
    Private nPosIPI     := nColLabel+425
    Private nPosVlr     := nColLabel+475
    Private nBoxCol     := nColLabel*0.4
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
    Monta os quadros do relatório
*/
Static Function fQuadro( nQuadro )
    Local aArea     := GetArea()
    Local nCol2     := 180
    Local cQry      := ''
    Private nNumPag     := 0
    Private nRowGray
    Private nSubTot     := 0 
    Private nTotICMS    := 0 
    Private nTotIPI     := 0 
    Private nTotFRETE   := 0 
    Private nTotGeral   := 0 
    Private nTotDesc    := 0 
    Private cAprovador  
    Private cSolitante  := ""
    Default nQuadro     := 0
    nBitMWidth:=150
    
    DBSelectArea("SM0")
    SM0->(DBSetOrder(1))
    SM0->(DbSeek("01"+aDados[01][05]))

    DbSelectArea("SA2")
    SA2->(DbSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA
    SA2->(DbSeek(FWxFilial("SA2")+aDados[01][03]+aDados[01][04]))
    
    cQry := "SELECT * FROM SYS_USR"+CRLF 
    //cQry += "WHERE USR_ID = '"+ALLTRIM(Posicione("SAK",1,FWxFilial("SAK")+aDados[1][13],"AK_USER"))+"'"+CRLF 
    cQry += "WHERE USR_CODIGO = '"+ALLTRIM(Posicione("SC1",1,FWxFilial("SC1")+aDados[1][28]+aDados[1][29]+Space(TamSx3("C1_ITEMGRD")[1]),"C1_SOLICIT"))+"'"+CRLF 

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, cQry ),"TEMPSYS",.F.,.F.)
        //cAprovador := AllTrim(TEMPSYS->USR_CODIGO)
    if !TEMPSYS->(Eof())
        cSolitante := AllTrim(TEMPSYS->USR_NOME)
    endif 
    TEMPSYS->(dbCloseArea())

    oPrinter:SayBitmap ( nRow/* -nColLabel *//*nRow*/, nColLabel/* -nColLabel *//*nCol*/, cLogo/*cBitmap*/, nBitMWidth, int(nBitMWidth/2)/*nHeight*/ )

    cTxtAux := UPPER(AllTrim( SM0->M0_NOMECOM ))
    oPrinter:Say ( nRow         , nColLabel+nCol2, "Faturar para.:"  , oFLabel  , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo+nCol2 , cTxtAux           , oFLabel   , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := AllTrim( SM0->M0_ENDENT )
    oPrinter:Say ( nRow+=nTamLin, nColLabel+nCol2, "Endereço.....:"  , oFLabel  , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo+nCol2 , UPPER(cTxtAux)    , oFInfo   , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := Alltrim(Transform(SM0->M0_CEPENT, "@R 99999-999")) + ' ' + Alltrim(SM0->M0_CIDENT) + ' - ' +  Alltrim(SM0->M0_ESTENT)
    oPrinter:Say ( nRow+=nTamLin, nColLabel+nCol2, "Município....:"  , oFLabel, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo+nCol2 , UPPER(cTxtAux)    , oFInfo , /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    cTxtAux := Alltrim(Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"))+' / '+Alltrim(Transform(SM0->M0_INSC, "@R 999.999.999.999"))
    oPrinter:Say ( nRow+=nTamLin, nColLabel+nCol2, "CNPJ / IE....:"  , oFLabel, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo+nCol2 , cTxtAux           , oFInfo , /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    cTxtAux := Alltrim(Transform(SubStr(StrTran(SM0->M0_TEL,'-',''),3), "@R (99) 9999-9999"))
    oPrinter:Say ( nRow+=nTamLin, nColLabel+nCol2, "Fone.........:"  , oFLabel, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo+nCol2 , cTxtAux           , oFInfo , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    oPrinter:Line( nRow+=nTamLin-10, nBoxCol, nRow, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )
    
    cTxtAux := dToC(sToD(aDados[01][07])) //Emissão
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Emissão:"   , oFInfoOBS, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColLabel + 60, cTxtAux , oFInfoOBS , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := AllTrim(Str(Year(dDataBase)) + ' / ' +  aDados[1][02] )
    oPrinter:Say ( nRow         , nColInfo + nCol2            , "Ordem de Compra:"  , oFInfoOBS, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo + nCol2 + nColInfo + 15, cTxtAux             , oFInfoOBS  , /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    //Dados do fornecedor
    oPrinter:Line( nRow+=nTamLin-10, nBoxCol, nRow, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )
    
    oPrinter:SayAlign ( nRow+=nTamLin -10, nPosSeq, "Fornecedor:"                                               , oFLabel   ,  (nPosUnd - nPosSeq ), 10, , PAD_RIGHT,  )  
    oPrinter:SayAlign ( nRow             , nPosUnd, ALLTRIM(SA2->A2_COD) + " - " + UPPER(ALLTRIM(SA2->A2_NOME)) , oFInfoBold,  (nPosVlr - nPosUnd), 10, , PAD_LEFT, 1 )  

    //oPrinter:SayAlign ( nRow            , nPosUnit-35, "Prazo de entrega:"                                                                     , oFLabel,  (nPosICMS - (nPosUnit-35) ), 10, , PAD_RIGHT,  )  
    //oPrinter:SayAlign ( nRow            , nPosICMS   , Alltrim(Str(DateDiffDay(sToD(aDados[01][07]),sToD(aDados[01][21]))))+ " Dia(s) " + dToC(sToD(aDados[01][21])), oFInfoBold ,  (nBoxRight - nPosICMS ), 10, , PAD_LEFT, 1 )  

    oPrinter:SayAlign ( nRow+=nTamLin   , nPosSeq, "Endereço:"                                                  , oFLabel   ,  (nPosUnd - nPosSeq ), 10, , PAD_RIGHT,  )  
    QuebraTexto(ALLTRIM(SA2->A2_END),nPosUnd,nPosUnit,nPosUnd,oFInfoBold,) // Condições de Pagamento

    if ALLTRIM(aDados[01][12]) == "C"
        cTxtAux := "CIF"
    elseif ALLTRIM(aDados[01][12]) == "F"
        cTxtAux := "FOB"
    elseif ALLTRIM(aDados[01][12]) == "T"
        cTxtAux := "Terceiro"
    elseif ALLTRIM(aDados[01][12]) == "R"
        cTxtAux := "Remetente"
    elseif ALLTRIM(aDados[01][12]) == "D"
        cTxtAux := "Destinatário"
    else
        cTxtAux := "Sem Frete"
    endif

    oPrinter:SayAlign ( nRow            , nPosUnit, "Frete:"                                        , oFLabel, (nPosICMS - nPosUnit ), 10, , PAD_RIGHT,  )  
    oPrinter:SayAlign ( nRow            , nPosICMS , cTxtAux                                        , oFInfoBold , (nPosIPI - nPosICMS )   , 10, , PAD_LEFT, 1 )  

    oPrinter:SayAlign ( nRow            , nPosIPI , "Moeda:"                                         , oFLabel, (nPosVlr - nPosIPI ), 10, , PAD_RIGHT,  )  
    oPrinter:SayAlign ( nRow            , nPosVlr, IIF(aDados[1][22]==1,"REAL","DOLÁR")             , oFInfoBold , (nBoxRight - nPosVlr )   , 10, , PAD_LEFT, 1 )  
    
    cTxtAux := Alltrim(Transform(SA2->A2_CGC, iif( len( AllTrim(SA2->A2_CGC)) == 14,"@R 99.999.999/9999-99", "@R 999.999.999-99")))
    oPrinter:SayAlign ( nRow+=nTamLin   , nPosSeq, "CNPJ:"                                          , oFLabel,  (nPosUnd - nPosSeq ), 10, , PAD_RIGHT,  )  
    oPrinter:SayAlign ( nRow            , nPosUnd , cTxtAux                                         , oFInfoBold ,  (nPosUnit - nPosUnd ), 10, , PAD_LEFT, 1 )  
    
    cTxtAux := Alltrim(Transform(SA2->A2_INSCR, "@R 999.999.999.999"))
    oPrinter:SayAlign ( nRow            , nPosCod      , "I.E:"                                     , oFLabel,  (nPosCod + 20 ), 10, , PAD_RIGHT,  )  
    oPrinter:SayAlign ( nRow            , nPosProd +80 , cTxtAux                                    , oFInfoBold ,  (nPosUnit - (nPosProd +80) ), 10, , PAD_LEFT, 1 )  

    cTxtAux := aDados[1][10] + " - " + ALLTRIM(Posicione("SE4",1,FWxFilial("SE4")+aDados[1][10],"E4_DESCRI"))
    oPrinter:SayAlign ( nRow            , nPosUnit, "Condições de Pagamento:"                       , oFLabel,  (nPosIPI - nPosUnit ), 10, , PAD_RIGHT,  )  
    QuebraTexto(cTxtAux,nPosIPI,nBoxRight,nPosIPI,oFInfoBold) // Condições de Pagamento
    
    cTxtAux := UPPER(AllTrim(SA2->A2_MUN) + ' - ' + AllTrim(SA2->A2_EST))
    oPrinter:SayAlign ( nRow+=nTamLin   , nPosSeq, "Cidade:"                                        , oFLabel,  (nPosUnd - nPosSeq ), 10, , PAD_RIGHT,  )  
    QuebraTexto(cTxtAux,nPosUnd,nPosUnit,nPosUnd,oFInfoBold,25) // Condições de Pagamento
    
    //oPrinter:SayAlign ( nRow            , nPosUnd , cTxtAux                                         , oFInfoBold ,  (nPosUnit - nPosUnd ), 10, , PAD_LEFT, 1 )  
    
    cTxtAux := AllTrim(Transform(SA2->A2_CEP,"@R 99.999-999")) 
    
    oPrinter:SayAlign ( nRow            , nPosCod       , "CEP:"                                    , oFLabel,  (nPosCod + 20 ), 10, , PAD_RIGHT,  )  
    oPrinter:SayAlign ( nRow            , nPosProd +80  , cTxtAux                                   , oFInfoBold ,  (nPosUnit - (nPosProd +80) ), 10, , PAD_LEFT, 1 )  
    
    cTxtAux := ""
    oPrinter:SayAlign ( nRow+=nTamLin   , nPosSeq, "Observação:"                                    , oFLabel,  (nPosUnd - nPosSeq ), 10, , PAD_RIGHT,  )  
    oPrinter:SayAlign ( nRow            , nPosUnd , cTxtAux                                         , oFInfoBold ,  (nPosUnit - nPosUnd ), 10, , PAD_LEFT, 1 )  

    cTxtAux := AllTrim(Str(Year(dDataBase)) + ' / ' +  aDados[1][28] )
    oPrinter:SayAlign ( nRow+=nTamLin   , nPosSeq, "Processo de compra:"                            , oFLabel,  (nPosProd - nPosSeq )            , 10, , PAD_RIGHT,)
    oPrinter:SayAlign ( nRow            , nPosProd , cTxtAux                                         , oFInfoBold ,  ((nPosUnit+nPosProd)/2)-nPosProd, 10, , PAD_LEFT, 1)
    
   //SM0->(DbSeek("01"+aDados[01][05]))
    cTxtAux := UPPER(AllTrim( SM0->M0_NOMECOM ))
    oPrinter:SayAlign ( nRow            , nPosProd, "Local de Entrega:"                             , oFLabel,  (nPosUnit - nPosProd )  , 10, , PAD_RIGHT,  )
    oPrinter:SayAlign ( nRow            , nPosUnit , cTxtAux                                        , oFInfoBold ,  (nBoxRight - nPosUnit ) , 10, , PAD_LEFT, 1 )

    cTxtAux := Alltrim(Transform(SM0->M0_CEPENT, "@R 99999-999"))
    oPrinter:SayAlign ( nRow+=nTamLin   , nPosSeq, "Cep Entrega:"                                   , oFLabel,  (nPosProd - nPosSeq )           , 10, , PAD_RIGHT,  )  
    oPrinter:SayAlign ( nRow            , nPosProd , cTxtAux                                         , oFInfoBold ,  ((nPosUnit+nPosProd)/2)-nPosProd, 10, , PAD_LEFT, 1 )  

    cTxtAux := UPPER(AllTrim( SM0->M0_ENDENT ))
    oPrinter:SayAlign ( nRow            , nPosProd, "Endereço Entrega:"                             , oFLabel,  (nPosUnit - nPosProd )  , 10, , PAD_RIGHT,  )
    oPrinter:SayAlign ( nRow            , nPosUnit , cTxtAux                                        , oFInfoBold ,  (nBoxRight - nPosUnit ) , 10, , PAD_LEFT , 1)
    
    cTxtAux := UPPER(Alltrim(SM0->M0_ESTENT))
    oPrinter:SayAlign ( nRow+=nTamLin   , nPosSeq, "Estado Entrega:"                                , oFLabel,  (nPosProd - nPosSeq )           , 10, , PAD_RIGHT,  )
    oPrinter:SayAlign ( nRow            , nPosProd , cTxtAux                                         , oFInfoBold ,  ((nPosUnit+nPosProd)/2)-nPosProd, 10, , PAD_LEFT , 1)
    
    cTxtAux := UPPER(AllTrim( SM0->M0_CIDENT ))
    oPrinter:SayAlign ( nRow            , nPosProd, "Endereço Entrega:"                             , oFLabel,  (nPosUnit - nPosProd )  , 10, , PAD_RIGHT,  )
    oPrinter:SayAlign ( nRow            , nPosUnit , cTxtAux                                        , oFInfoBold ,  (nBoxRight - nPosUnit ) , 10, , PAD_LEFT, 1 )
    nRow+=nTamLin-10
    
    oPrinter:Line( nRow+=nTamLin-10, nBoxCol, nRow, nBoxRight/*nRight*/, /* cColor */, cBoxPixel/*cPixel*/ )
    oPrinter:FillRect({nRow+1, nBoxCol+1, nRow + (nTamLin * 2)-12, nBoxRight-1}, oBrushRoxo)

    HeaderGrid()

    aColsGrid()

    nTotGeral := (nSubTot /* + nTotICMS */ + nTotIPI + nTotFRETE) - nTotDesc
    
    FimPagina(2)
    oPrinter:SayAlign ( nRow+=nTamLin-10, nPosICMS  , "Sub Total:"                                                      , oFLabel    ,  (nPosIPI - nPosICMS) , 10, , PAD_LEFT,  )  
    oPrinter:SayAlign ( nRow            , nPosVlr   , AllTrim(Transform(nSubTot,"@R 999,999,999.99"))                   , oFInfoBold ,  (nBoxRight - nPosVlr), 10, , PAD_LEFT,  )  
    //oPrinter:SayAlign ( nRow            , nPosSeq, "Ordem de compra aprovada eletronicamente por:"                    , oFLabel    ,  (((nPosUnit+nPosProd)/2)-nPosSeq)                    , 10, , PAD_LEFT,  )  
    //oPrinter:SayAlign ( nRow            , (((nPosUnit+nPosProd+60)/2)-nPosSeq-30) , ALLTRIM(Posicione("SAK",1,FWxFilial("SAK")+aDados[1][13],"AK_NOME")) , oFInfoBold ,  (nBoxRight - (((nPosUnit+nPosProd+60)/2)-nPosSeq) + 10) , 10, , PAD_LEFT,  )//nome aprovador
    oPrinter:SayAlign ( nRow+=nTamLin-10, nPosICMS  , "Frete:"                                                          , oFLabel    ,  (nPosIPI - nPosICMS) , 10, , PAD_LEFT,  )  
    oPrinter:SayAlign ( nRow            , nPosVlr   , AllTrim(Transform(nTotFRETE,"@R 999,999,999.99"))                     , oFInfoBold ,  (nBoxRight - nPosVlr), 10, , PAD_LEFT,  )  
    oPrinter:SayAlign ( nRow+=nTamLin-10, nPosICMS  , "ICMS:"                                                           , oFLabel    ,  (nPosIPI - nPosICMS) , 10, , PAD_LEFT,  )  
    oPrinter:SayAlign ( nRow            , nPosSeq   , "Comprador:"                                                      , oFLabel    ,  (nPosUnd-nPosSeq)    , 10, , PAD_RIGHT,  )  
    oPrinter:SayAlign ( nRow            , nPosUnd+10, iif(EMPTY(aDados[1][27]),"",AllTrim(UsrFullName(aDados[1][27])))  , oFInfoBold ,  (nBoxRight - nPosUnd), 10, , PAD_LEFT,  ) // nome aprovador
    oPrinter:SayAlign ( nRow            , nPosVlr   , AllTrim(Transform(nTotICMS,"@R 999,999,999.99"))                      , oFInfoBold ,  (nBoxRight - nPosVlr), 10, , PAD_LEFT,  )  
    oPrinter:SayAlign ( nRow+=nTamLin-10, nPosICMS  , "IPI:"                                                            , oFLabel    ,  (nPosIPI - nPosICMS) , 10, , PAD_LEFT,  )  
    oPrinter:SayAlign ( nRow            , nPosVlr   , AllTrim(Transform(nTotIPI,"@R 999,999,999.99"))                       , oFInfoBold ,  (nBoxRight - nPosVlr), 10, , PAD_LEFT,  )  
    //oPrinter:SayAlign ( nRow+=nTamLin-10, nPosUnit, "ST:"                                                             , oFLabel    ,  (nPosIPI - nPosICMS) , 10, , PAD_LEFT,  )  
    //oPrinter:SayAlign ( nRow            , nPosVlr , AllTrim(Transform(0,"@R 999,999,999.99"))                             , oFInfoBold ,  (nBoxRight - nPosVlr), 10, , PAD_LEFT,  )  
    oPrinter:SayAlign ( nRow+=nTamLin-10, nPosICMS  , "Descontos:"                                                      , oFLabel    ,  (nPosIPI - nPosICMS) , 10, , PAD_LEFT,  )  
    oPrinter:SayAlign ( nRow            , nPosVlr   , AllTrim(Transform(nTotDesc,"@R 999,999,999.99"))                      , oFInfoBold ,  (nBoxRight - nPosVlr), 10, , PAD_LEFT,  )  
    oPrinter:SayAlign ( nRow+=nTamLin-10, nPosICMS  , "Acréscimos:"                                                     , oFLabel    ,  (nPosIPI - nPosICMS) , 10, , PAD_LEFT,  )  
    oPrinter:SayAlign ( nRow            , nPosVlr   , AllTrim(Transform(0,"@R 999,999,999.99"))                             , oFInfoBold ,  (nBoxRight - nPosVlr), 10, , PAD_LEFT,  )  
    oPrinter:SayAlign ( nRow+=nTamLin-10, nPosICMS  , "Total:"                                                          , oFLabel    ,  (nPosIPI - nPosICMS) , 10, , PAD_LEFT,  )  
    oPrinter:SayAlign ( nRow            , nPosVlr   , AllTrim(Transform(nTotGeral,"@R 999,999,999.99"))                     , oFInfoBold ,  (nBoxRight - nPosVlr), 10, , PAD_LEFT,  )  
    
    cTxtAux := "Página " + Alltrim(Str(nNumPag+=1))
    oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-10,nColLabel   , "Agropecuária Vista Alegre LTDA"   , oFInfo, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-10,nBoxRight-50, cTxtAux  , oFInfo, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )

    RestArea(aArea)
Return
/* Montar Grid */
Static Function aColsGrid()
    Local nI
    for nI := 1 to len(aDados)
        if FimPagina(1) // Verifica se a página está no final
            oPrinter:FillRect({nRow-3, nBoxCol+1, nRow + (nTamLin * 2)-12, nBoxRight-1}, oBrushRoxo)
            HeaderGrid()
        endif
            nSubTot   += aDados[nI][9]
            nTotICMS  += aDados[nI][15]
            nTotIPI   += aDados[nI][16]
            nTotFRETE := aDados[nI][26]
            nTotDesc  += aDados[nI][30]
//oPrinter:SayAlign ( nRow+=nTamLin-10, nPos  + 6.25, "COD"  , oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
            oPrinter:SayAlign ( nRow+=nTamLin-11, nPosSeq, AllTrim(Str(nI))                                     , oFGrid,  (nPosQtd - nPosSeq),    10, , PAD_LEFT,  )   // Sequencia
            oPrinter:SayAlign ( nRow            , nPosQtd, AllTrim(Transform(aDados[nI][6], "@r 999,999,999"))  , oFGrid,  (nPosUnd - nPosQtd),    10, , PAD_LEFT,  )   // Unidade
            oPrinter:SayAlign ( nRow            , nPosUnd, aDados[nI][23]                                       , oFGrid,  (nPosCod - nPosUnd),    10, , PAD_LEFT,  )   // Codigo Interno
            oPrinter:SayAlign ( nRow            , nPosCod, AllTrim(aDados[nI][24])                              , oFGrid,  (nPosProd - nPosCod),    10, , PAD_LEFT ,  )  // Marca

            QuebraTexto(AllTrim(aDados[nI][25]),nPosProd,nPosUnit,nPosProd,oFGrid,45) // NOME DO PRODUTO

            //oPrinter:SayAlign ( nRow, nPosProd , aDados[nI][23], oFGrid,  (nPosCod - nPosUnd),    10, , PAD_LEFT ,  )  
            oPrinter:SayAlign ( nRow, nPosUnit, AllTrim(Transform(aDados[nI][8] , "@r 999,999,999.99")), oFGrid,  (nPosICMS - nPosUnit),    10, , PAD_LEFT ,  )  // ICMS
            oPrinter:SayAlign ( nRow, nPosICMS, AllTrim(Transform(aDados[nI][15], "@r 999,999,999.99")), oFGrid,  (nPosIPI - nPosICMS) ,    10, , PAD_LEFT ,  )  // IPI
            oPrinter:SayAlign ( nRow, nPosIPI , AllTrim(Transform(aDados[nI][16], "@r 999,999,999.99")), oFGrid,  (nPosVlr - nPosIPI)  ,    10, , PAD_LEFT ,  )  // ST
            oPrinter:SayAlign ( nRow, nPosVlr , AllTrim(Transform(aDados[nI][09], "@r 999,999,999.99")), oFGrid,  (nBoxRight - nPosVlr),    10, , PAD_LEFT ,  )  // Valor Total

            nRow := nRowGray

            oPrinter:FillRect({nRow+nTamLin-8, nBoxCol+1, nRow + (nTamLin * 2) - 10, nBoxRight-1}, oBrushCinza)
            
            cTxtAux := "Solicitação:" + AllTrim(Str(Year(dDataBase)) + ' / ' + aDados[1][28] )
            oPrinter:SayAlign ( nRow+=nTamLin-10, nPosSeq , cTxtAux , oFGridInfo, (nPosProd  - nPosSeq), 10,, PAD_LEFT ,)
            
            cTxtAux := "Obj. Custo:" + AllTrim(aDados[nI][17])  +" "+ AllTrim(Posicione("CTT",1,FWxFilial("CTT")+aDados[nI][17],"CTT_DESC01"))
            QuebraTexto(cTxtAux,nPosProd,nPosUnit,nPosProd,oFGridInfo) // CUSTO

            cTxtAux := "Conta Contábil:" + AllTrim(aDados[nI][19]) +" "+ AllTrim(Posicione("CT1",1,FWxFilial("CT1")+aDados[nI][19],"CT1_DESC01"))
            QuebraTexto(cTxtAux,nPosUnit,nBoxRight,nPosUnit,oFGridInfo,55) // CONTA CONTABIL
            
            //PswOrder(1)
            //PswSeek(aDados[nI][20])
            //Posicione("SC1",1,FWxFilial("SC1")+aDados[nI][28]+aDados[nI][29]+Space(TamSx3("C1_ITEMGRD")[1]),"C1_SOLICIT")
            cTxtAux := "Solicitante:" + cSolitante/*+ PswRet(1)[1][14]*/
            nRow+=nTamLin-10
            //QuebraTexto(cTxtAux,nPosSeq,nPosProd,nPosSeq,oFGridInfo)//solicitante
            QuebraTexto(cTxtAux,nPosSeq,nPosProd,nPosSeq,oFGridInfo)//solicitante

            cTxtAux := "Data de Entrega: " + dToC(sToD(aDados[1][21]))
            QuebraTexto(cTxtAux,nPosProd,nPosUnit,nPosProd,oFGridInfoB)//solicitante
            //cTxtAux := "Aprovador: " + cAprovador
            //QuebraTexto(cTxtAux,nPosProd,nPosUnit,nPosProd,oFGridInfo) 
            //oPrinter:SayAlign ( nRow, nPosProd , cTxtAux , oFGridInfo, (nPosUnit - nPosProd), 10,, PAD_LEFT,)

            //cTxtAux := "Observação:" + AllTrim(aDados[nI][18])
            //oPrinter:SayAlign ( nRow+=nTamLin-10, nPosSeq , cTxtAux , oFGridInfo, (nPosProd  - nPosSeq), 10,, PAD_LEFT ,  )
           //nRow+=nTamLin-10
            oPrinter:Line( nRow+=nTamLin-8, nBoxCol, nRow, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )
    Next nI
Return

Static Function QuebraTexto(cText,nInicio,nPosFinal,nPosInicio,oFont,nLen)
    Local nAt, nPos
    Local cDesc
    Local lpula
    Local nGdLine
    
    iif(nLen==nil,nLen:=45,nLen)

    nGdLine := nRow
    lpula := .f.
    cTxtAux := AllTrim(cText)
    if len(AllTrim(cTxtAux)) > nLen
        while AllTrim(cTxtAux) != ''
            nAt     := At(" ",cTxtAux,nLen)
            nPos    := Iif(len(cTxtAux)>nLen,Iif(nAt==0,len(cTxtAux),nAt),len(cTxtAux))
            cDesc   := SubStr(cTxtAux,1,nPos)
            cTxtAux := AllTrim(SubStr(cTxtAux,nPos+1,len(cTxtAux)))

            oPrinter:SayAlign ( iif(lPula,nRow+=nTamLin-10,nRow), nInicio, cDesc, oFont,  (nPosFinal - nPosInicio), 20, , PAD_LEFT ,  )  // Valor Unitario
            lPula := .t.
        enddo
    else
        oPrinter:SayAlign ( nRow, nInicio, AllTrim(cTxtAux), oFont,  (nPosFinal - nPosInicio),    10, , PAD_LEFT ,  )  // Valor Unitario
    endif
    nRowGray := nRow
    nRow := iif(nGdLine < nRow,nGdLine,nRow)
    
Return 
/* Montar cabecalho da grid */
Static Function HeaderGrid()
    //oPrinter:FillRect({nRow+1, nBoxCol+1, nRow + (nTamLin * 2)-12, nBoxRight-1}, oBrushRoxo)

    oPrinter:Say ( nRow+=nTamLin-8 , nPosCod  + 6.25, "COD"     , oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow            , nPosUnit + 5   , "VALOR"   , oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow+=nTamLin-10, nPosSeq        , "SEQ."    , oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow            , nPosQtd        , "QTDE"    , oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow            , nPosUnd        , "UND"     , oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow            , nPosCod        , "INTERNO" , oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    //oPrinter:Say ( nRow            , nPosMrc  , "MARCA"   , oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow            , nPosProd       , "PRODUTO" , oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow            , nPosUnit       , "UNITÁRIO", oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow            , nPosICMS       , "ICMS"    , oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow            , nPosIPI        , "IPI"     , oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    //oPrinter:Say ( nRow            , nPosIPI   , "ST"      , oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow            , nPosVlr        , "TOTAL"   , oFheader , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Line( nRow+=nTamLin-12, nBoxCol, nRow, nBoxRight/*nRight*/, /* cColor */, cBoxPixel/*cPixel*/ )
Return

Static Function FimPagina(nLocal)
    Local nDif
    Local lRet  := .F.

    if nLocal == 1
        nDif := 45
    elseif nLocal == 2
        nDif := 70
    else
        nDif := 130
    endif

    if (nBoxBottom - nRow) < nDif
        cTxtAux := "Página " + Alltrim(Str(nNumPag+=1))
        oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-10,nColLabel   , "Agropecuária Vista Alegre LTDA"   , oFInfo, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
        oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-10,nBoxRight-50, cTxtAux  , oFInfo, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )

        oPrinter:EndPage()
        oPrinter:startpage()
        nRow := 30
        oPrinter:Box( nRow*0.4, nBoxCol:=nColLabel*0.4, nBoxBottom:=(nTamLin*nTotLinha)*0.90, nBoxRight:=int(oPrinter:nPageWidth/4.15), cBoxPixel:="-4" )// ( 130, 10, 600, 900, "-4")
        nRow := 15
        lRet := !lRet
    endif

Return lRet
Static Function fGetDados()
    Local aArea     := GetArea()
    Local aDadosf   := {}
    Local _cQry     := ''

    _cQry := " SELECT	SC7.C7_FILIAL " + CRLF
    _cQry += "	    ,	SC7.C7_NUM " + CRLF
    _cQry += "	    ,	SC7.C7_FORNECE " + CRLF
    _cQry += "	    ,	SC7.C7_LOJA " + CRLF
    _cQry += "	    ,   SC7.C7_FILENT " + CRLF
    _cQry += "	    ,	SC7.C7_QUANT " + CRLF
    _cQry += "	    ,	SC7.C7_EMISSAO " + CRLF
    _cQry += "	    ,	SC7.C7_UM " + CRLF
    _cQry += "	    ,	SC7.C7_PRECO " + CRLF
    _cQry += "	    ,	SC7.C7_TOTAL " + CRLF
    _cQry += "	    ,	SC7.C7_COND " + CRLF
    _cQry += "	    ,	SC7.C7_DESC " + CRLF
    _cQry += "	    ,	SC7.C7_TPFRETE " + CRLF
    _cQry += "	    ,	SC7.C7_APROV " + CRLF
    _cQry += "	    ,	SC7.C7_USER " + CRLF
    _cQry += "	    ,	SC7.C7_VALICM " + CRLF
    _cQry += "	    ,	SC7.C7_VALIPI " + CRLF
    _cQry += "	    ,	SC7.C7_MOEDA " + CRLF
    _cQry += "	    ,	SC7.C7_CC " + CRLF
    _cQry += "	    ,	ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), SC7.C7_OBSM)),'') AS C7_OBSM " + CRLF 
    _cQry += "	    ,	SC7.C7_CONTA " + CRLF
    _cQry += "	    ,	SC7.C7_SOLICIT " + CRLF
    _cQry += "	    ,	SC7.C7_DATPRF " + CRLF
    _cQry += "	    ,	SC7.C7_MOEDA " + CRLF
    _cQry += "	    ,	SC7.C7_PRODUTO " + CRLF
    _cQry += "      ,	SC7.C7_SOLICIT " + CRLF
    _cQry += "      ,	SC7.C7_FRETE " + CRLF
    _cQry += "      ,	SC7.C7_USER " + CRLF
    _cQry += "      ,	SC7.C7_NUMSC " + CRLF
    _cQry += "      ,	SC7.C7_ITEMSC " + CRLF
    _cQry += "      ,	SC7.C7_VLDESC " + CRLF
    _cQry += "	    ,	SB1.B1_DESC " + CRLF
    _cQry += " FROM "+RetSqlName("SC7")+" SC7 " + CRLF 
    _cQry += " JOIN "+RetSqlName("SB1")+" SB1 ON SC7.C7_PRODUTO = SB1.B1_COD
    _cQry += " AND SB1.D_E_L_E_T_ = ''
    _cQry += " WHERE SC7.C7_NUM = '"+SC7->C7_NUM+"' " + CRLF 
    _cQry += " AND SC7.C7_FORNECE = '"+SC7->C7_FORNECE+"' " + CRLF 
    _cQry += " AND SC7.C7_LOJA = '"+SC7->C7_LOJA+"' " + CRLF 
    _cQry += " AND SC7.C7_FILIAL = '"+SC7->C7_FILIAL+"' " + CRLF 
    _cQry += " AND SC7.D_E_L_E_T_ = '' " + CRLF
    _cQry += " ORDER BY SB1.B1_DESC " + CRLF

    if lower(cUserName) $ 'mbernardo,ioliveira,Administrador,atoshio,ioliveira'
        MemoWrite("C:\totvs_relatorios\" +"VACOMR11" + ".sql" , _cQry)
    endif

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)
    While !TEMPSQL->(Eof())
        aAdd(aDadosf,{TEMPSQL->C7_FILIAL,;      //01    
                    TEMPSQL->C7_NUM,;           //02
                    TEMPSQL->C7_FORNECE,;       //03
                    TEMPSQL->C7_LOJA,;          //04
                    TEMPSQL->C7_FILENT,;        //05
                    TEMPSQL->C7_QUANT,;         //06
                    TEMPSQL->C7_EMISSAO,;       //07
                    TEMPSQL->C7_PRECO,;         //08
                    TEMPSQL->C7_TOTAL,;         //09
                    TEMPSQL->C7_COND,;          //10
                    TEMPSQL->C7_DESC,;          //11
                    TEMPSQL->C7_TPFRETE,;       //12
                    TEMPSQL->C7_APROV,;         //13
                    TEMPSQL->C7_USER,;          //14
                    TEMPSQL->C7_VALICM,;        //15
                    TEMPSQL->C7_VALIPI,;        //16
                    TEMPSQL->C7_CC,;            //17
                    TEMPSQL->C7_OBSM,;          //18
                    TEMPSQL->C7_CONTA,;         //19
                    TEMPSQL->C7_SOLICIT,;       //20
                    TEMPSQL->C7_DATPRF,;        //21
                    TEMPSQL->C7_MOEDA,;         //22
                    TEMPSQL->C7_UM,;            //23
                    TEMPSQL->C7_PRODUTO,;       //24
                    TEMPSQL->B1_DESC,;          //25
                    TEMPSQL->C7_FRETE,;         //26
                    TEMPSQL->C7_USER,;          //27
                    TEMPSQL->C7_NUMSC,;         //28
                    TEMPSQL->C7_ITEMSC,;        //29
                    TEMPSQL->C7_VLDESC})        //30
        TEMPSQL->(dbSkip())
    enddo

    TEMPSQL->(dbCloseArea())
    RestArea(aArea)

Return aDadosf
