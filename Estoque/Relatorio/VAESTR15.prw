#include "TOTVS.CH"
#include "TOPCONN.CH"

#IFNDEF _ENTER_
	#DEFINE _ENTER_ (Chr(13)+Chr(10))
	// Alert("miguel")
#ENDIF 

/*/{Protheus.doc} VaEstR15
Imprime o termo de retirada de material do almoxarifado.
@author jr.andre
@since 16/02/2018
@param lValida, logical, Indica se termo só pode ser impresso para requisições baixadas.
@type function
/*/
user function VaEstR15(lValida)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
local wnrel
local cDesc1		:= "Impressão do Termo de Retirada de Material"
local cTitulo		:= "Termo de Retirada de Material"
local aSays     	:= {}, aButtons := {}, nOpca := 0

private nLastKey 	:= 0
private cPerg

private oPrint

default lValida := .F.

// MB : 14.04.2020 - Toshio pediu para tirar esta validacao, apos o ricardinho chorar pra ele.
// if lValida
// 	if Empty(SCP->CP_STATUS) .or. SCP->CP_PREREQU != "S"
// 		msgAlert("O termo só pode ser impresso para Requisições baixadas.")
// 		return
// 	endIf
// endIf

cString := "SF2"
wnrel   := "VAESTR15"
cPerg   := "VAER15"

AAdd(aSays,cDesc1) 

AAdd(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
AAdd(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )  

FormBatch( cTitulo, aSays, aButtons,, 160 )

if nOpca == 0
   return
endIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracoes para impressao grafica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint := TMSPrinter():New(cTitulo)		
oPrint:SetPortrait()					// Modo retrato
oPrint:SetPaperSize(9)					// Papel A4

// Inserido por Michel A. Sander (Fictor) em 07.02.12 para tratar o codigo de barras
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracoes para codigo de barras ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFontes := "Arial"//"Courier New"

if nLastKey = 27
	dbClearFilter()
	return
endif

RptStatus({|lEnd| PrintRel(@lEnd,wnRel,cString)}, cTitulo)

oPrint:Preview()  		// Visualiza impressao grafica antes de imprimir

return

static function PrintRel(lEnd,wnRel,cString)
local nCopias    := 1
local i          := 1
local nLin       := 0
local nDiv       := 0
Local cNome      := ""
Local cSql       := ""

private cAlias := CriaTrab(, .f.)

private nPag       := 0
private cLogo      := "\system\lgrl" + AllTrim(cEmpAnt) + ".bmp"
private nLinIni    := 100  
//private nLinFim    := 3250
private nTamLim    := 70
private nLinha     := 0

private nColIni    := 80 // 225
private nColFim    := 2350 // 2225
private nEspaco    := nTamLim/4

nDiv := Int((nColFim - nColIni) / 9) - 10

private nColDiv1   := nColIni
private nColDiv2   := nColDiv1+nDiv
private nColDiv3   := nColDiv2+nDiv-5
private nColDiv4   := nColDiv3+nDiv+50

private nColDiv5   := nColDiv1+nDiv // private nColDiv5   := nColDiv4+nDiv-15
private nColDiv6   := nColDiv5+(3*nDiv)+180
private nColDiv7   := nColDiv6+nDiv-110
private nColDiv8   := nColDiv7+nDiv-70
private nColDiv9   := nColFim

//private oFont8     := TFont():New(aFontes,  6,  6,, .f.,,,, .t., .f.)
private oFont10n   := TFont():New(aFontes,  8,  8,, .t.,,,, .t., .f.) //Negrito
private oFont10    := TFont():New(aFontes,  8,  8,, .f.,,,, .t., .f.) //Normal s/negrito
//private oFont11    := TFont():New(aFontes,  9,  9,, .f.,,,, .t., .f.) //Normal s/negrito
private oFont14n   := TFont():New(aFontes, 14, 14,, .t.,,,, .t., .f.) //Negrito
private oFont12n   := TFont():New(aFontes, 10, 10,, .t.,,,, .t., .f.) //Negrito
private oFont12    := TFont():New(aFontes,  8,  8,, .f.,,,, .t., .f.) //Normal s/negrito

dbSelectArea("SA2")
dbSetOrder(1)

DbSelectArea("SB1")
DbSetOrder(1)

DbSelectArea("SCP")
DbSetOrder(1)
	
	cSql := " select SCP.CP_FORNECE " +_ENTER_+;
     "        , SCP.CP_LOJA " +_ENTER_+;
     "        , SA2.A2_NOME " +_ENTER_+;
     "        , SCP.CP_NUM " +_ENTER_+;
     "        , CP_MATRI " +_ENTER_+;
     "        , RA_NOME " +_ENTER_+;
     "        , SCP.CP_EMISSAO " +_ENTER_+;
     "        , SCP.CP_SOLICIT " +_ENTER_+;
     "        , SCP.CP_PRODUTO " +_ENTER_+;
     "        , CP_DESCRI         " +_ENTER_+;
     "        -- , SB1.B1_DESC " +_ENTER_+;
     "        , SCP.CP_UM " +_ENTER_+;
     "        , SCP.CP_QUANT " +_ENTER_+;
     "        , CP_CC, CTT_DESC01 " +_ENTER_+;
     "     from " + RetSqlName('SCP') + " SCP " +_ENTER_+;
     "     LEFT JOIN " + RetSqlName('SRA') + " SRA on SRA.RA_FILIAL= '" + xFilial('SRA') + "'" +_ENTER_+;
     "       and RA_MAT=CP_MATRI " +_ENTER_+;
     "       and SRA.D_E_L_E_T_=' ' " +_ENTER_+;
     "     left join " + RetSqlName('SA2') + " SA2 " +_ENTER_+;
     "               on SA2.A2_FILIAL  = '" + xFilial('SA2') + "'" +_ENTER_+;
     "      and SA2.A2_COD     = SCP.CP_FORNECE " +_ENTER_+;
     "      and SA2.A2_LOJA    = SCP.CP_LOJA " +_ENTER_+;
     "      and SA2.D_E_L_E_T_=' ' " +_ENTER_+;
     "   -- join " + RetSqlName('SB1') + " SB1 " +_ENTER_+;
     "   --   on SB1.B1_FILIAL  = '" + xFilial('SB1') + "'" +_ENTER_+;
     "   --  and SB1.B1_COD     = SCP.CP_PRODUTO " +_ENTER_+;
     "   --  and SB1.D_E_L_E_T_=' ' " +_ENTER_+;
     "   LEFT JOIN " + RetSqlName('CTT') + " TT ON " +_ENTER_+;
     "        CTT_FILIAL= "+FWxFilial("CTT")+"  " +_ENTER_+;
     "       AND CTT_CUSTO=CP_CC  " +_ENTER_+;
     "       AND TT.D_E_L_E_T_=' ' " +_ENTER_+;
     "    where SCP.CP_FILIAL  = '" + xFilial('SCP') + "'" +_ENTER_+;
     "      and CP_FILIAL+SCP.CP_NUM = '" + SCP->CP_FILIAL+SCP->CP_NUM + "'" +_ENTER_+;
     "      and SCP.D_E_L_E_T_=' ' " +_ENTER_+;
     " order by SCP.CP_NUM, CP_DESCRI -- SB1.B1_DESC, SCP.CP_ITEM "

    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),(cAlias),.T.,.T.)

    MemoWrite( GetTempPath()+"\VAESTR15.SQL", cSql )
    // MemoWrite( GetTempPath()+"\VAESTR15_GET.SQL", GETLastQuery()[2] )
    
    if (cAlias)->(!Eof())

	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³Relatorio Grafico:                                                                                      ³
	    //³* Todas as coordenadas sao em pixels	                                                                   ³
	    //³* oPrint:Line - (linha inicial, coluna inicial, linha final, coluna final)Imprime linha nas coordenadas ³
	    //³* oPrint:Say(Linha,Coluna,Valor,Picture,Objeto com a fonte escolhida)		                           ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
    	for i := 1 to nCopias
    	    (cAlias)->(DbGoTop())
            nPag := 0 
    		nLin := 1
    
            cNome := iIf(!Empty((cAlias)->CP_FORNECE),(cAlias)->A2_NOME,iIF(!Empty((cAlias)->CP_MATRI),(cAlias)->RA_NOME,(cAlias)->CP_SOLICIT))

            If !(cAlias)->(Eof())
            
                ImpCabecalho(nPag+=1)
                while !(cAlias)->(Eof())
                    
                    ImpLinha()
                                       
                    (cAlias)->(DbSkip()) 

                    If nLinha >= 2700 .and. !(cAlias)->(Eof())
                        ImpRodape( cNome )
                        oPrint:EndPage()
                        ImpCabecalho(nPag+=1)
                    EndIf

                EndDo
                
                // while !(cAlias)->(Eof())
                //     if (nLin%10) == 1
                //         if nLin <> 1
                //             ImpRodape( cNome )
                //         endif
                //         ImpCabecalho()
                //         nLin++
                //     endif
                //     ImpLinha(nQtProd+=1)
                //     (cAlias)->(DbSkip()) 
                // endDo
            EndIf
            ImpRodape( cNome )
        next 
    endif                 

    (cAlias)->(dbCloseArea())

return nil


static function ImpCabecalho(nPag)
    Local xBkp  := nColIni

    nColIni += 175
    //-----------------------------------------
    // Dados da empresa emitente do documento
    //-----------------------------------------
    nLinha := nLinIni+nTamLim
    oPrint:StartPage() 		
    oPrint:SayBitmap(nLinha-15,nColIni+25,cLogo,240,150)
    oPrint:Say(nLinha,nColIni+300,Alltrim(SM0->M0_NOMECOM),oFont12n)
    oPrint:Say(nLinha+=nTamLim,nColIni+300,Alltrim(SM0->M0_ENDENT)+" - "+Alltrim("Fone:") + Alltrim(SM0->M0_TEL) + " - " + Alltrim(SM0->M0_CIDENT) + " - " + Alltrim(SM0->M0_ESTENT),oFont10n)
    nLinha += nTamLim
    oPrint:Line(nLinha,nColIni+300,nLinha,nColFim-240)
    nLinha += nTamLim/4
    oPrint:Say(nLinha,nColIni+300,"C.N.P.J. " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") + space(30) + "Inscrição Estadual " + Alltrim(SM0->M0_INSC),oFont10)
    
    oPrint:Line(nLinIni,nColFim-240,nLinha+nTamLim,nColFim-240)
    
    nLinha += nTamLim
    oPrint:Line(nLinha,nColIni,nLinha,nColFim-240)
    
    nColIni := xBkp
    
    //-----------------------------------------
    // Título do documento
    //-----------------------------------------
    nLinha += nTamLim+20
    oPrint:Say(nLinha, nColIni+550, "TERMO DE RETIRADA DE MATERIAL - ALMOXARIFADO", oFont14n)

    nLinha += nTamLim+30
    oPrint:Say(nLinha+=nTamLim,nColIni+10,"Eu, ______________________________________________________________________________, portador do CPF: ____________________________________________,",oFont12)
    oPrint:Say(nLinha+=nTamLim,nColIni+10,"confirmo o recebimento dos itens discriminados abaixo na presenta data e em condições adequadas oara utilização.",oFont12)
    
    nLinha += nTamLim+30
    
    //-----------------------------------------
    // Cabeçalho da tabela
    //-----------------------------------------
    oPrint:Line(nLinha,nColDiv1,nLinha,nColDiv4) // oPrint:Line(nLinha,nColDiv1,nLinha,nColDiv9)
    
    oPrint:Line(nLinha, nColDiv1, nLinha+nTamLim, nColDiv1)
    oPrint:Line(nLinha, nColDiv2, nLinha+nTamLim, nColDiv2)
    oPrint:Line(nLinha, nColDiv3, nLinha+nTamLim, nColDiv3)
    oPrint:Line(nLinha, nColDiv4, nLinha+nTamLim, nColDiv4)
    
    oPrint:Say(nLinha+nEspaco, nColDiv1+15, Alltrim("S.A."),         oFont12n)
    oPrint:Say(nLinha+nEspaco, nColDiv2+15, Alltrim("EMISSAO"),      oFont12n)
    oPrint:Say(nLinha+nEspaco, nColDiv3+15, Alltrim("SOLICITANTE"),  oFont12n)
    oPrint:Line(nLinha+nTamLim,nColDiv1,nLinha+nTamLim,nColDiv4) // oPrint:Line(nLinha+nTamLim*2,nColDiv1,nLinha+nTamLim*2,nColDiv9)
    
    nLinha += nTamLim

    oPrint:Line(nLinha, nColDiv1, nLinha+nTamLim, nColDiv1)
    oPrint:Line(nLinha, nColDiv2, nLinha+nTamLim, nColDiv2)
    oPrint:Line(nLinha, nColDiv3, nLinha+nTamLim, nColDiv3)
    oPrint:Line(nLinha, nColDiv4, nLinha+nTamLim, nColDiv4)

    oPrint:Say(nLinha+nEspaco, nColDiv1+15, Alltrim((cAlias)->CP_NUM),                 oFont12)
    oPrint:Say(nLinha+nEspaco, nColDiv2+15, Alltrim(DToC(SToD((cAlias)->CP_EMISSAO))), oFont12)
    oPrint:Say(nLinha+nEspaco, nColDiv3+15, Alltrim((cAlias)->CP_SOLICIT),             oFont12)
    oPrint:Say(nLinha+nEspaco, nColDiv8+15, "Pagina: " + StrZero(nPag,2),              oFont12)
    oPrint:Line(nLinha+nTamLim,nColDiv1,nLinha+nTamLim,nColDiv4)
    nLinha += nTamLim*2

    oPrint:Line(nLinha,nColDiv1,nLinha,nColDiv9)
    oPrint:Line(nLinha, nColDiv1, nLinha+nTamLim, nColDiv1)
    oPrint:Line(nLinha, nColDiv6, nLinha+nTamLim, nColDiv6)
    oPrint:Line(nLinha, nColDiv7, nLinha+nTamLim, nColDiv7)
    oPrint:Line(nLinha, nColDiv8, nLinha+nTamLim, nColDiv8)
    oPrint:Line(nLinha, nColDiv9, nLinha+nTamLim, nColDiv9)

    oPrint:Say(nLinha+nEspaco, nColDiv1+15, Alltrim("PRODUTO"),      oFont12n)
    oPrint:Say(nLinha+nEspaco, nColDiv6+15, Alltrim("UM"),           oFont12n)
    oPrint:Say(nLinha+nEspaco, nColDiv7+15, Alltrim("QTDE"),         oFont12n)
    oPrint:Say(nLinha+nEspaco, nColDiv8+15, Alltrim("CENTRO CUSTO"), oFont12n)
    oPrint:Line(nLinha+nTamLim,nColDiv1,nLinha+nTamLim,nColDiv9)

    nLinha += nTamLim
   
return nil


static function ImpLinha( )
Local cAuxP      := ""
Local cAuxC      := ""
Local nQtdCar   := 0
    
    oPrint:Say(nLinha+nEspaco, nColDiv6+15, Alltrim((cAlias)->CP_UM), oFont12)
    oPrint:Say(nLinha+nEspaco, nColDiv7+15, StrTran(Transform((cAlias)->CP_QUANT, "@R 9,999,999"),",","."),  oFont12)
    
    cAuxP := Alltrim((cAlias)->CP_PRODUTO)+'-'+UPPER(Alltrim((cAlias)->CP_DESCRI))
    cAuxC := AllTrim((cAlias)->CP_CC)+'-'+UPPER(AllTrim((cAlias)->CTT_DESC01))
    While !Empty(cAuxP) .or. !Empty(cAuxC)
        
        oPrint:Line(nLinha, nColDiv1, nLinha+nTamLim, nColDiv1)
        oPrint:Line(nLinha, nColDiv6, nLinha+nTamLim, nColDiv6)
        oPrint:Line(nLinha, nColDiv7, nLinha+nTamLim, nColDiv7)
        oPrint:Line(nLinha, nColDiv8, nLinha+nTamLim, nColDiv8)
        oPrint:Line(nLinha, nColDiv9, nLinha+nTamLim, nColDiv9)

        If !Empty(cAuxP)
            nQtdCar := 68
            oPrint:Say( nLinha+nEspaco, nColDiv1+15, SubS(cAuxP,1,nQtdCar), oFont12)
            cAuxP := SubS(cAuxP, nQtdCar+1)
        EndIf

        If !Empty(cAuxC)
            nQtdCar := 45
            oPrint:Say(nLinha+nEspaco, nColDiv8+15, SubS(cAuxC,1,nQtdCar), oFont12)
            cAuxC := SubS(cAuxC, nQtdCar+1)
        EndIf

        nLinha += nTamLim
    EndDo

	oPrint:Line(nLinha, nColDiv1, nLinha, nColDiv9)
	   
return(nLinha)


static function ImpRodape( cNome )
local Recorte := Int((nColFim-nColIni)/3)
local nCol1 := nColIni + Int(Recorte/2)
local nCol2 := nColIni + 2*Recorte //+ Int(Recorte/2)

    // nLinha := 2100
    nLinha += nTamLim*2

    oPrint:Say(nLinha, nCol2, PadC(DExtenso(),50), oFont12n)

    // nLinha := 2400
    nLinha += nTamLim*3

	oPrint:Say(nLinha, nCol1, Alltrim(Replicate("_", 35)), oFont12n)
	oPrint:Say(nLinha+nTamLim, nCol1, PadC("Responsável pela Retirada", 40), oFont12n)
    oPrint:Say(nLinha+nTamLim*2, nCol1, PadC( cNome, 50),  oFont12n)

	oPrint:Say(nLinha, nCol2, Alltrim(Replicate("_", 35)), oFont12n)
	oPrint:Say(nLinha+nTamLim, nCol2, PadC("Responsável pela Entrega", 50),  oFont12n)

	oPrint:EndPage()
return nil


static function DExtenso(dData)
default dData := dDataBase
return cValToChar(Day(dData)) + " de " + MesExtenso(dData) +  " de " + cValToChar(Year(dData))
