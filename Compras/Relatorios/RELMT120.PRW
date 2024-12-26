#INCLUDE "TOTVS.CH"
/* 
    Igor Oliveira 04-2023
    RELMT120 - Relatorio Pedido de compra 
    Usado: MATA120.PRW
*/
User Function RELMT120()

Return alert("Teste")
    cTel := AllTrim(StrTran(aDadosR10[1][15],'-',''))
    cTel := iif(len(cTel)>10,AllTrim(SubStr(cTel,3,10)),cTel)
    cTxtAux := Alltrim(Transform(cTel, iif( len(cTel)==10 ,"@R (99) 9999-9999", "@R 9999-9999")))

    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Fone.........:" ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo, cTxtAux   ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := Alltrim(Transform(SubStr(StrTran(aDadosR10[1][16],'-',''),3), "@R (99) 9999-9999"))
    oPrinter:Say ( nRow         , nColLabel+nCol2, "Fax.........:",oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo+nCol2, iif(AllTrim(cTxtAux)=='','',cTxtAux) ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := DtoC(sToD(aDadosR10[1][19]))
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Data Entrega.:" ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo, cTxtAux      ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    oPrinter:Line( nRow+=nTamLin-10/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, , cBoxPixel/*cPixel*/ )
    
    FimPagina(2)// Verifica se a página está no final
    oPrinter:Say ( nRow+=nTamLin   , nColLabel     , "Valor Total: ",oFInfoOBS /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:box ( nRow - 10       , nBoxRight-115 , nRow, nBoxRight-80 , cBoxPixel:="-4")
    oPrinter:Line( nRow+=nTamLin-10, nBoxCol       , nRow, nBoxRight/*nRight*/, /* cColor */, cBoxPixel/*cPixel*/ )
    
    //FimPagina(2)// Verifica se a página está no final
    FimPagina(3)// Verifica se a página está no final
    oPrinter:Say ( nRow+=nTamLin, nColLabel , "Local de Entrega....:" ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo + 50  , SM0->M0_NOMECOM     ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := AllTrim( SM0->M0_ENDENT )
    oPrinter:Say ( nRow+=nTamLin, nColLabel , "Endereço de Entrega.:" ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo + 50  , cTxtAux     ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := Alltrim(Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"))+' / '+Alltrim(Transform(SM0->M0_INSC, "@R 999.999.999.999"))
    oPrinter:Say ( nRow+=nTamLin, nColLabel,  "CNPJ / IE...........:"   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo + 50, cTxtAux            , oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "OBS: COTAÇÃO"   , oFInfoOBS/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Line( nRow+=nTamLin-10, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /* cColor */, cBoxPixel/*cPixel*/ )
    
    FimPagina(4)// Verifica se a página está no final
    oPrinter:Say ( nRow+=nTamLin, nColLabel         , "Condições de Fornecimentos:"   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow+=nTamLin, nColLabel         , "Pagamento:"   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColLabel+nCol2   , "Frete por conta:  ( ) Emitente  ( ) Destinatário  ( ) A Retirar"   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow+=nTamLin, nColLabel         , "Entrega Local:"   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow+=nTamLin, nColLabel         , "Prazo Entrega:"   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColLabel+nCol2   , "Frete:"   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )

    oPrinter:Say ( nRow+=nTamLin, nColLabel+nCol2+20, "Local de Entrega:"   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    nRow+=nTamLin
    oPrinter:Say ( nRow+=nTamLin,nColLabel+nCol2+20, "Local de Entrega:"   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    
    cTxtAux := "Página " + Alltrim(Str(nNumPag+=1))
    oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-9,nColLabel   , "Agropecuária Vista Alegre LTDA"   , oFInfo/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-9,nBoxRight-50, cTxtAux  , oFInfo/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
