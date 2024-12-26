#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"


//Constantes
#Define PAD_LEFT		0
#Define PAD_RIGHT		1
#Define PAD_CENTER		2

#Define NCOLFILI		0100
#Define NCOLNATU		0200
#Define NCOLCONT		0340
#Define NCOLVENC		0410
#Define NCOLNUME		0550//0900//0700
#Define NCOLPREF		0750//0600
#Define NCOLPARC		0820//1120//0820
#Define NCOLFORN		0940//0910
#Define NCOLHIST		1550//1300
#Define NCOLSALD		2950

		
User Function VAFINR07

	Local cPerg := PADR("VAFINR07",10)
	
	ValidPerg(cPerg) 
	
	While Pergunte(cPerg, .T.)
		RptStatus({|| RunReport() })
	EndDo

Return

Static Function RunReport()
	Local nOrdem
	Local nCount
	Local nSalEmp  		:= 0
	Local nSalBco  		:= 0
	Local nSalEmpF 		:= 0
	Local nSalBcoF 		:= 0
	Local nLimCre  		:= 0
	Local nLimCreF 		:= 0
	Local nLimX    		:= 0
	Local cQRYPAG		:= ""
	
	Private cTitulo		:= "[VAFINR07] - Titulo a Pagar por Periodo"
	Private cHoraEx		:= Time()
	Private nPagAtu 	:= 0
	Private nLinCab		:= 0030
	Private nLinIni		:= 0200
	Private nLinFin		:= 2500//3250
	Private nLinAtu		:= 0
	Private nColIni		:= 0050
	Private nColFin		:= 3500//2900//2750//3300
	Private nColfinHist := 1850
	Private nColMeio	:= nColIni+((nColFin-nColIni)/2)
	Private nEspPula	:= 0025//0060
	Private nEspNorm	:= 0030//0035
	
	//Variáveis referente ao objeto de Impressão
	Private oPrintPvt	:= TMSPrinter():New()
	Private cFontPvt	:= "Tahoma"
	Private oFontCab	:= TFont():New(cFontPvt,,-12,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFontSubN	:= TFont():New(cFontPvt,,-07,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFontSub	:= TFont():New(cFontPvt,,-07,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFontDadN	:= TFont():New(cFontPvt,,-07,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFontDad	:= TFont():New(cFontPvt,,-07,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFontRod	:= TFont():New(cFontPvt,,-07,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFontRod2	:= TFont():New(cFontPvt,,-06,.T.,.F.,5,.T.,5,.T.,.F.)
	Private nAuxSldT	:= 0 
	Private cNatuIn 	:= ''
	Private cTipoIn 	:= ''
	Private cNatuEx 	:= ''
	Private cTipoCtr 	:= ''
	Private cFornOut	:= ''
	
	cNatuEx 	:= alltrim(MV_PAR10)
	cTipoEx 	:= alltrim(MV_PAR11)
	cPrefEx 	:= alltrim(MV_PAR17)

	cNatuIn 	:= alltrim(MV_PAR19)
	cTipoIn 	:= alltrim(MV_PAR20)
	cFornOut	:= alltrim(MV_PAR21)
	
	//Configurando o tipo de impressão
	//oPrintPvt:Setup()
	oPrintPvt:SetPaperSize(DMPAPER_A4)
	//oPrintPvt:SetPage(DMPAPER_A4)

	oPrintPvt:SetLandscape()
	//oPrintPvt:SetPortrait()// Retrato
	
	If MV_PAR18==1
		cTitulo		:= "Titulo a Pagar (Analítico)   "
	Else
		cTitulo		:= "Titulo a Pagar (Sintético)   "
	Endif
	
	cQRYPAG += 	" SELECT "	+ CRLF
	cQRYPAG += 	" SE2.E2_FILIAL	                AS E2_FILIAL, "		+ CRLF
	cQRYPAG += 	" SE2.E2_PREFIXO	            AS E2_PREFIXO, "    + CRLF
	cQRYPAG += 	" SE2.E2_TIPO		            AS E2_TIPO, "       + CRLF
	cQRYPAG += 	" SE2.E2_NUM		            AS E2_NUM, "        + CRLF
	cQRYPAG += 	" SE2.E2_PARCELA	            AS E2_PARCELA, "    + CRLF
	cQRYPAG += 	" SE2.E2_FORNECE 	            AS E2_FORNECE, "    + CRLF
	cQRYPAG += 	" SE2.E2_LOJA 		            AS E2_LOJA, "       + CRLF
	cQRYPAG += 	" SE2.E2_NOMFOR		            AS E2_NOMFOR, "     + CRLF
	cQRYPAG += 	" SE2.E2_NATUREZ	            AS E2_NATUREZ, "    + CRLF
	cQRYPAG += 	" SED.ED_DESCRIC	            AS ED_DESCRIC, "    + CRLF
	cQRYPAG += 	" SE2.E2_EMISSAO	            AS E2_EMISSAO, "    + CRLF
	cQRYPAG += 	" SE2.E2_VENCTO		            AS E2_VENCTO, "     + CRLF
	cQRYPAG += 	" SE2.E2_VENCREA	            AS E2_VENCREA, "    + CRLF
	cQRYPAG += 	" SE2.E2_BAIXA		            AS E2_BAIXA, "      + CRLF
	cQRYPAG += 	" SE2.E2_VALOR		            AS E2_VALOR, "      + CRLF
	//cQRYPAG += 	" SE2.E2_SALDO+E2_ACRESC		AS E2_SALDO, "      + CRLF
	cQRYPAG +=  " CASE WHEN SE2.E2_BAIXA > '"+dtos(MV_PAR15)+"'  THEN E2_VALLIQ "     + CRLF
	cQRYPAG +=  " 	  WHEN SE2.E2_SALDO > 0 THEN SE2.E2_SALDO+E2_ACRESC"     + CRLF
	cQRYPAG +=  " 	  ELSE 0		END AS E2_SALDO, "     + CRLF
	cQRYPAG += 	"  SE2.E2_VALLIQ		            AS E2_VALLIQ, "     + CRLF
	cQRYPAG += 	" SE2.E2_ACRESC		            AS E2_ACRESC, "     + CRLF
	cQRYPAG += 	" SE2.E2_HIST		            AS E2_HIST, "       + CRLF
	cQRYPAG += 	" SE2.E2_XXDTDIG	            AS E2_XXDTDIG, "    + CRLF
	cQRYPAG += 	" SE2.E2_EMIS1		            AS E2_EMIS1 "       + CRLF
	cQRYPAG += 	" FROM " + RetSqlName("SE2") + " AS SE2 "       + CRLF 
	cQRYPAG += 	" LEFT JOIN " + RetSqlName("SED") + " SED ON (ED_FILIAL = '' AND ED_CODIGO = E2_NATUREZ AND SED.D_E_L_E_T_ = '') "       + CRLF   
	cQRYPAG += 	" WHERE SE2.D_E_L_E_T_ <> '*' "       + CRLF

	If mv_par07 == 1 		// digitacao E2_XXDTDIG
		cQRYPAG += 	" AND SE2.E2_XXDTDIG	BETWEEN '"+dtos(MV_PAR08)+"' AND '"+dtos(MV_PAR09)+"' "       + CRLF
	Elseif mv_par07 == 2 	// emissao E2_EMISSAO
		cQRYPAG += 	" AND SE2.E2_EMISSAO 	BETWEEN '"+dtos(MV_PAR08)+"' AND '"+dtos(MV_PAR09)+"' "       + CRLF   
    Else 					// data base sistema  E2_EMIS1
		cQRYPAG += 	" AND SE2.E2_EMIS1 		BETWEEN '"+dtos(MV_PAR08)+"' AND '"+dtos(MV_PAR09)+"' "       + CRLF
    Endif

	If mv_par12 == 1 		// filtra data da baixa
		cQRYPAG += 	" AND SE2.E2_BAIXA	BETWEEN '"+dtos(MV_PAR13)+"' AND '"+dtos(MV_PAR14)+"' "       + CRLF
    Endif

	cQRYPAG += 	" AND SE2.E2_VENCREA	BETWEEN '"+dtos(MV_PAR15)+"' AND '"+dtos(MV_PAR16)+"' "       + CRLF
	cQRYPAG += 	" AND SE2.E2_FILIAL		BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "       + CRLF
	cQRYPAG += 	" AND SE2.E2_FORNECE	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' "       + CRLF
	cQRYPAG += 	" AND SE2.E2_LOJA		BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' "       + CRLF
	cQRYPAG += 	" AND SE2.E2_FILIAL	NOT IN ('70') "        + CRLF
	//cQRYPAG += 	" AND SE2.E2_SALDO >	0 "       + CRLF


	cNatOut := ""
	If !Empty(MV_PAR10)
		aNatOut := StrTokArr(AllTrim(MV_PAR10),";")	
		For nCont := 1 To Len(aNatOut)
			cNatOut += If(Empty(cNatOut),"'",",'") + aNatOut[nCont] + "'"
		Next		
		cQRYPAG += 	" AND SE2.E2_NATUREZ NOT IN ("+cNatOut+") "       + CRLF
	EndIf

	cTipoOut := ""
	If !Empty(MV_PAR11)
		aTipoOut := StrTokArr(AllTrim(MV_PAR11),";")	
		For nCont := 1 To Len(aTipoOut)
			cTipoOut += If(Empty(cTipoOut),"'",",'") + aTipoOut[nCont] + "'"
		Next		
		cQRYPAG += 	" AND SE2.E2_TIPO NOT IN ("+cTipoOut+") "       + CRLF
	EndIf

	cPrefOut := ""
	If !Empty(MV_PAR17)
		aPrefOut := StrTokArr(AllTrim(MV_PAR17),";")	
		For nCont := 1 To Len(aPrefOut)
			cPrefOut += If(Empty(cPrefOut),"'",",'") + aPrefOut[nCont] + "'"
		Next		
		cQRYPAG += 	" AND SE2.E2_PREFIXO NOT IN ("+cPrefOut+") "       + CRLF
	EndIf

	cNatIn := ""
	If !Empty(MV_PAR19)
		aNatIn := StrTokArr(AllTrim(MV_PAR19),";")	
		For nCont := 1 To Len(aNatIn)
			cNatIn += If(Empty(cNatIn),"'",",'") + aNatIn[nCont] + "'"
		Next		
		cQRYPAG += 	" AND SE2.E2_NATUREZ IN ("+cNatIn+") "       + CRLF
	EndIf

	cTipoIn := ""
	If !Empty(MV_PAR20)
		aTipoIn := StrTokArr(AllTrim(MV_PAR20),";")	
		For nCont := 1 To Len(aTipoIn)
			cTipoIn += If(Empty(cTipoIn),"'",",'") + aTipoIn[nCont] + "'"
		Next		
		cQRYPAG += 	" AND SE2.E2_TIPO IN ("+cTipoIn+") "       + CRLF
	EndIf
	
	cFornOut := ""
	If !Empty(MV_PAR21)
		aFornOut := strTokArr(AllTrim(MV_PAR21),";")
		For nCont := 1 To Len(aFornOut)
			cFornOut += If(Empty(cFornOut),"'",",'") + aFornOut[nCont] + "'"
		Next		
		cQRYPAG += 	" AND SE2.E2_FORNECE NOT IN ("+cFornOut+") "       + CRLF
	EndIf

	If mv_par07 == 1 		// digitacao E2_XXDTDIG
		cQRYPAG += 	" ORDER BY SE2.E2_FILIAL, SE2.E2_NATUREZ, SE2.E2_XXDTDIG, SE2.E2_EMIS1, SE2.E2_EMISSAO, SE2.E2_NOMFOR, SE2.E2_TIPO, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA "       + CRLF
	Elseif mv_par07 == 2 	// emissao E2_EMISSAO
		cQRYPAG += 	" ORDER BY SE2.E2_FILIAL, SE2.E2_NATUREZ, SE2.E2_EMISSAO, SE2.E2_NOMFOR, SE2.E2_TIPO, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA "       + CRLF
    Else 					// data base sistema  E2_EMIS1
		cQRYPAG += 	" ORDER BY SE2.E2_FILIAL, SE2.E2_NATUREZ, SE2.E2_EMIS1, SE2.E2_NOMFOR, SE2.E2_TIPO, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA "       + CRLF
    Endif
 
	If select("QRYPAG") > 0
		QRYPAG->(DbCloseArea())
	EndIf

  	memowrite("C:\TOTVS\vafinr07.txt", cQRYPAG)
	TCQUERY cQRYPAG NEW ALIAS "QRYPAG"    	
	TcSetField("QRYPAG","E2_EMISSAO","D")		
	TcSetField("QRYPAG","E2_VENCTO","D")		
	TcSetField("QRYPAG","E2_VENCREA","D")		
	TcSetField("QRYPAG","E2_BAIXA","D")		
	
	QRYPAG->(DbGotop())
	
	//Gerando o cabeçalho
	fImpCab(cTitulo)
	
	cCondicao 	:= ""
	cTipoTit 	:= ""
	cVencto		:= ""
	cNatureza 	:= ""
	cFil	 	:= ""
	nSubCond	:= 0
	nSubPref	:= 0
	nSubVenc 	:= 0
	nSubNatu 	:= 0
	nSubFili 	:= 0
	nTotal		:= 0
	
	Do While !QRYPAG->(Eof())	
	 	cAuxNatu := AllTrim(QRYPAG->E2_NATUREZ) + ' - ' + AllTrim(QRYPAG->ED_DESCRIC)  		
		
		//Se a linha atual for menor
		If nLinAtu+0100 > nLinFin
			fImpRod()
			fImpCab(cTitulo)
		EndIf
		
					
		//Se a linha atual for menor
		If nLinAtu+0100 > nLinFin
			fImpRod()
			fImpCab(cTitulo)
		EndIf
			
		If /*AllTrim(cVencto) != AllTrim(Dtoc(QRYPAG->E2_VENCTO))  .OR.*/ AllTrim(cFil) != AllTrim(QRYPAG->E2_FILIAL) .OR. AllTrim(cNatureza) != Alltrim(cAuxNatu)  //(AllTrim(QRYPAG->E2_NATUREZ) + ' - ' + AllTrim(ED_DESCRIC))
			// para nao duplicar ultima natureza do dia			
			If AllTrim(cNatureza) != Alltrim(cAuxNatu)  .or. AllTrim(cVencto) != AllTrim(Dtoc(QRYPAG->E2_VENCTO)) //(AllTrim(QRYPAG->E2_NATUREZ) + ' - ' + AllTrim(ED_DESCRIC))  
				If nSubNatu <> 0
					oPrintPvt:Say(nLinAtu,NCOLNATU,">>> sub-total  "+cNatureza,oFontSubN,,,,PAD_LEFT)
					oPrintPvt:Say(nLinAtu,NCOLSALD,"R$ "+AllTrim(Transform(nSubNatu,"@E 9,999,999,999,999.99")),oFontSubN,,,,PAD_RIGHT)
					nSubNatu := 0
					nLinAtu += 055 //40 //100
				EndIf	
			Endif
			
			/*If nSubVenc <> 0 .and. AllTrim(cVencto) != AllTrim(Dtoc(QRYPAG->E2_VENCTO)) 
				oPrintPvt:Say(nLinAtu,NCOLVENC,">>> sub-total do dia " + cVencto,oFontSubN,,,,PAD_LEFT)
				oPrintPvt:Say(nLinAtu,NCOLSALD,"R$ "+AllTrim(Transform(nSubVenc,"@E 9,999,999,999,999.99")),oFontSubN,,,,PAD_RIGHT)
				nSubVenc := 0
				//nLinAtu += 50 //100
				//Linha de separação
				nLinAtu += 030
				LD(oPrintPvt,nLinAtu,nColIni,nColFin) // oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)
				nLinAtu += 025 // 010
				
				If AllTrim(cNatureza) == Alltrim(cAuxNatu) //(AllTrim(QRYPAG->E2_NATUREZ) + ' - ' + AllTrim(QRYPAG->ED_DESCRIC)) // mesma natureza Natureza ao mudar a data vencimento 		
					cNatureza := AllTrim(QRYPAG->E2_NATUREZ) + ' - ' + AllTrim(QRYPAG->ED_DESCRIC)  
					oPrintPvt:Say(nLinAtu,NCOLNATU,cNatureza ,oFontSubN,,,,PAD_LEFT)
					//oPrintPvt:Say(nLinAtu,NCOLNATU,AllTrim(QRYPAG->E2_NATUREZ) + ' - ' + ED_DESCRIC,oFontSubN,,,,PAD_LEFT)
					nLinAtu += 040 //100
				EndIf				
				
			EndIf
						
			cVencto := Dtoc(QRYPAG->E2_VENCTO)
			*/
		EndIf		
					
		//Se a linha atual for menor
		If nLinAtu+0100 > nLinFin
			fImpRod()
			fImpCab(cTitulo)
		EndIf
							
		If AllTrim(cNatureza) != Alltrim(cAuxNatu)   .OR. AllTrim(cFil) != AllTrim(QRYPAG->E2_FILIAL) //(AllTrim(QRYPAG->E2_NATUREZ) + ' - ' + AllTrim(QRYPAG->ED_DESCRIC)) .OR. AllTrim(cFil) != AllTrim(QRYPAG->E2_FILIAL)
			If nSubNatu <> 0
				oPrintPvt:Say(nLinAtu,NCOLNATU,">>> sub-total  "+cNatureza,oFontSubN,,,,PAD_LEFT)
				oPrintPvt:Say(nLinAtu,NCOLSALD,"R$ "+AllTrim(Transform(nSubNatu,"@E 9,999,999,999,999.99")),oFontSubN,,,,PAD_RIGHT)
				nSubNatu := 0
				nLinAtu += 055 //040 //100
			EndIf	
			
			If AllTrim(cFil) != AllTrim(QRYPAG->E2_FILIAL)
				If nSubFili <> 0
					oPrintPvt:Say(nLinAtu,NCOLFILI,cFil + " - " + AllTrim(POSICIONE("SM0",1,SM0->M0_CODIGO+cFil,'M0_NOMECOM'))	+ " (" + AllTrim(POSICIONE("SM0",1,SM0->M0_CODIGO+cFil,'M0_CIDENT')) + "-" + AllTrim(POSICIONE("SM0",1,SM0->M0_CODIGO+cFil,'M0_ESTENT')) + ")",oFontSubN,,,,PAD_LEFT)
					oPrintPvt:Say(nLinAtu,NCOLSALD,"R$ "+AllTrim(Transform(nSubFili,"@E 9,999,999,999,999.99")),oFontSubN,,,,PAD_RIGHT)
					nSubFili := 0
					nLinAtu += 070 //040 //100
				EndIf
				
				cFil := AllTrim(QRYPAG->E2_FILIAL)
				oPrintPvt:Say(nLinAtu,NCOLFILI,cFil + " - " + AllTrim(POSICIONE("SM0",1,SM0->M0_CODIGO+cFil,'M0_NOMECOM'))	+ " (" + AllTrim(POSICIONE("SM0",1,SM0->M0_CODIGO+cFil,'M0_CIDENT')) + "-" + AllTrim(POSICIONE("SM0",1,SM0->M0_CODIGO+cFil,'M0_ESTENT')) + ")",oFontSubN,,,,PAD_LEFT)
				nLinAtu += 040 //100
			EndIf
			
			If AllTrim(cNatureza) != Alltrim(cAuxNatu) .or. AllTrim(cVencto) != AllTrim(Dtoc(QRYPAG->E2_VENCTO)) 	 //(AllTrim(QRYPAG->E2_NATUREZ) + ' - ' + AllTrim(QRYPAG->ED_DESCRIC))		
				cNatureza := AllTrim(QRYPAG->E2_NATUREZ) + ' - ' + AllTrim(QRYPAG->ED_DESCRIC)  
				oPrintPvt:Say(nLinAtu,NCOLNATU,cNatureza,oFontSubN,,,,PAD_LEFT)
				nLinAtu += 040 //100
			EndIf
		EndIf	
					
		//Se a linha atual for menor
		If nLinAtu+0100 > nLinFin
			fImpRod()
			fImpCab(cTitulo)
		EndIf	
		
		nAuxSldT := QRYPAG->E2_SALDO
		If Alltrim(QRYPAG->E2_TIPO)  $ 'NCC;NDF;CL-;DE-;AB-;PA;RA;'
			nAuxSldT := - (nAuxSldT)
		Endif
		
		if QRYPAG->E2_SALDO > 0
			
	//		oPrintPvt:Say(nLinAtu,NCOLCONT,QRYPAG->E2_X_CONTR,oFontRod,,,,PAD_LEFT)
			oPrintPvt:Say(nLinAtu,NCOLVENC,Dtoc(QRYPAG->E2_VENCTO),oFontRod,,,,PAD_LEFT)
			oPrintPvt:Say(nLinAtu,NCOLPREF,QRYPAG->E2_TIPO,oFontRod,,,,PAD_LEFT)
			oPrintPvt:Say(nLinAtu,NCOLNUME,QRYPAG->E2_NUM,oFontRod,,,,PAD_LEFT)
			oPrintPvt:Say(nLinAtu,NCOLPARC,QRYPAG->E2_PARCELA,oFontRod,,,,PAD_LEFT)
			oPrintPvt:Say(nLinAtu,NCOLFORN,QRYPAG->E2_FORNECE+"-"+QRYPAG->E2_LOJA+"-"+QRYPAG->E2_NOMFOR,oFontRod,,,,PAD_LEFT)
	//		oPrintPvt:Say(nLinAtu,NCOLHIST,QRYPAG->E2_HIST,oFontRod,,,,PAD_LEFT)
			oPrintPvt:Say(nLinAtu,NCOLHIST,SUBSTR(QRYPAG->E2_HIST,1,80),oFontRod,,,,PAD_LEFT)
			oPrintPvt:Say(nLinAtu,NCOLSALD,"R$"+AllTrim(Transform(nAuxSldT,"@E 9,999,999,999,999.99")),oFontRod,,,,PAD_RIGHT)
	//		If !Empty(QRYPAG->E2_X_CONTR)
	//			oPrintPvt:Say(nLinAtu,NCOLCORR,ZMVend(QRYPAG->E2_X_CONTR),oFontRod2,,,,PAD_LEFT)			
	//		Endif		
			nLinAtu += 036
			
		Endif
		//nSubCond	+= iif(!Empty(QRYPAG->E2_X_CONTR),nAuxSldT,0) //+= QRYPAG->E2_SALDO //iif(!Empty(AllTrim(QRYPAG->E4_DESCRI)),QRYPAG->E2_SALDO,0)
		nSubPref 	+= nAuxSldT
		nSubVenc 	+= nAuxSldT //iif(!Empty(QRYPAG->E2_X_CONTR),nAuxSldT,0)
		nSubNatu 	+= nAuxSldT
		nSubFili 	+= nAuxSldT
		nTotal 		+= nAuxSldT
		
		//Se a linha atual for menor
		If nLinAtu+0100 > nLinFin
			fImpRod()
			fImpCab(cTitulo)
		EndIf
		
		QRYPAG->(DbSkip())
		
	End Do
	QRYPAG->(DbCloseArea())
	
	If nSubNatu > 0
		oPrintPvt:Say(nLinAtu,NCOLNATU,cNatureza,oFontSubN,,,,PAD_LEFT)
		oPrintPvt:Say(nLinAtu,NCOLSALD,"R$ "+AllTrim(Transform(nSubNatu,"@E 9,999,999,999,999.99")),oFontSubN,,,,PAD_RIGHT)
		nSubNatu := 0
		nLinAtu += 055 // 040 //100
	EndIf

	/*If nSubVenc > 0
		oPrintPvt:Say(nLinAtu,NCOLVENC,">>> sub-total do dia " + cVencto,oFontSubN,,,,PAD_LEFT)
		oPrintPvt:Say(nLinAtu,NCOLSALD,"R$ "+AllTrim(Transform(nSubVenc,"@E 9,999,999,999,999.99")),oFontSubN,,,,PAD_RIGHT)
		nSubVenc := 0
		nLinAtu += 030
		LD(oPrintPvt,nLinAtu,nColIni,nColFin) // oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)
		nLinAtu += 025 //010
	EndIf
	*/
	If nSubFili > 0
		oPrintPvt:Say(nLinAtu,NCOLFILI,cFil+ " - " + AllTrim(POSICIONE("SM0",1,SM0->M0_CODIGO+cFil,'M0_NOMECOM'))	+ " (" + AllTrim(POSICIONE("SM0",1,SM0->M0_CODIGO+cFil,'M0_CIDENT')) + "-" + AllTrim(POSICIONE("SM0",1,SM0->M0_CODIGO+cFil,'M0_ESTENT')) + ")",oFontSubN,,,,PAD_LEFT)
		oPrintPvt:Say(nLinAtu,NCOLSALD,"R$ "+AllTrim(Transform(nSubFili,"@E 9,999,999,999,999.99")),oFontSubN,,,,PAD_RIGHT)
		nSubNatu := 0
		nLinAtu += 070 //040 //100
	EndIf
		
	//Se a linha atual for menor
	If nLinAtu+0100 > nLinFin
		fImpRod()
		fImpCab(cTitulo)
	EndIf
		
	nLinAtu += 100
	oPrintPvt:Say( nLinAtu,NCOLFILI,"SUBTOTAL POR NATUREZA",oFontSubN,,,,PAD_LEFT)
	nLinAtu += 050
	SubTotal("RTRIM(LTRIM(E2_NATUREZ)) + ' - ' + ED_DESCRIC")
	LD(oPrintPvt,nLinAtu-010,nColIni,NCOLPREF+550) // oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)
		
	//Se a linha atual for menor
	If nLinAtu+0100 > nLinFin
		fImpRod()
		fImpCab(cTitulo)
	EndIf
	
	nLinAtu += 100
	oPrintPvt:Say(nLinAtu,NCOLFILI,"SUBTOTAL POR TIPO TITULO",oFontSubN,,,,PAD_LEFT)
				
	nLinAtu += 050
	
	SubTotal("E2_TIPO")
	LD(oPrintPvt,nLinAtu-010,nColIni,NCOLPREF+550)	
	//Se a linha atual for menor
	If nLinAtu+0100 > nLinFin
		fImpRod()
		fImpCab(cTitulo)
	EndIf
		
	nLinAtu += 0100 
	//Se a linha atual for menor
	If nLinAtu+0100 > nLinFin
		fImpRod()
		fImpCab(cTitulo)
	EndIf
	
	oPrintPvt:Say(nLinAtu,NCOLFILI,"TOTAL GERAL",oFontSubN,,,,PAD_LEFT)
	oPrintPvt:Say(nLinAtu,NCOLPREF+550,"R$ " + AllTrim(Transform(nTotal,"@E 9,999,999,999,999.99")),oFontSubN,,,,PAD_RIGHT)
	
	fImpRod()
						
	//Mostrando o relatório
	oPrintPvt:Preview()

Return


Static Function SubTotal(campo)
	Local cSql := ""
		
	cSql := " SELECT "+campo+" DESCR, 
	cSql += "  SUM(CASE WHEN E2_TIPO IN ('NCC','NDF','CL-','DE-','AB-','PA','RA') THEN -SE2.E2_SALDO "
	cSql += "  WHEN E2_TIPO NOT IN ('NCC','NDF','CL-','DE-','AB-','PA','RA') AND E2_SALDO = 0 AND E2_BAIXA > '20170727' THEN  SE2.E2_VALLIQ"
	cSql += "  WHEN E2_TIPO NOT IN ('NCC','NDF','CL-','DE-','AB-','PA','RA') AND E2_SALDO > 0 THEN SE2.E2_SALDO+SE2.E2_ACRESC"
	cSql += "  ELSE 0 END) AS SALDO   " 
	cSql += " FROM SE2010 SE2 "
	cSql += " LEFT JOIN SED010 SED ON SED.D_E_L_E_T_ = '' AND SE2.E2_NATUREZ = SED.ED_CODIGO"
	cSql += " WHERE SE2.D_E_L_E_T_ = '' "
	If mv_par07 == 1 		// digitacao E2_XXDTDIG
		cSql += 	" AND SE2.E2_XXDTDIG	BETWEEN '"+dtos(MV_PAR08)+"' AND '"+dtos(MV_PAR09)+"' "
	Elseif mv_par07 == 2 	// emissao E2_EMISSAO
		cSql += 	" AND SE2.E2_EMISSAO 	BETWEEN '"+dtos(MV_PAR08)+"' AND '"+dtos(MV_PAR09)+"' "    
    Else 					// data base sistema  E2_EMIS1
		cSql += 	" AND SE2.E2_EMIS1 		BETWEEN '"+dtos(MV_PAR08)+"' AND '"+dtos(MV_PAR09)+"' "    
    Endif

	If mv_par12 == 1 		// filtra data da baixa
		cSql += 	" AND SE2.E2_BAIXA	BETWEEN '"+dtos(MV_PAR13)+"' AND '"+dtos(MV_PAR14)+"' "
    Endif

	cSql += 	" AND SE2.E2_VENCREA	BETWEEN '"+dtos(MV_PAR15)+"' AND '"+dtos(MV_PAR16)+"' "
	cSql += 	" AND SE2.E2_FILIAL		BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cSql += 	" AND SE2.E2_FORNECE	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' "
	cSql += 	" AND SE2.E2_LOJA		BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' "
	cSql += 	" AND SE2.E2_FILIAL	NOT IN ('70') " 

	cNatOut := ""
	If !Empty(MV_PAR10)
		aNatOut := StrTokArr(AllTrim(MV_PAR10),";")	
		For nCont := 1 To Len(aNatOut)
			cNatOut += If(Empty(cNatOut),"'",",'") + aNatOut[nCont] + "'"
		Next		
		cSql += 	" AND SE2.E2_NATUREZ NOT IN ("+cNatOut+") "
	EndIf

	cTipoOut := ""
	If !Empty(MV_PAR11)
		aTipoOut := StrTokArr(AllTrim(MV_PAR11),";")	
		For nCont := 1 To Len(aTipoOut)
			cTipoOut += If(Empty(cTipoOut),"'",",'") + aTipoOut[nCont] + "'"
		Next		
		cSql += 	" AND SE2.E2_TIPO NOT IN ("+cTipoOut+") "
	EndIf

	cPrefOut := ""
	If !Empty(MV_PAR17)
		aPrefOut := StrTokArr(AllTrim(MV_PAR17),";")	
		For nCont := 1 To Len(aPrefOut)
			cPrefOut += If(Empty(cPrefOut),"'",",'") + aPrefOut[nCont] + "'"
		Next		
		cSql += 	" AND SE2.E2_PREFIXO NOT IN ("+cPrefOut+") "
	EndIf

	cNatIn := ""
	If !Empty(MV_PAR19)
		aNatIn := StrTokArr(AllTrim(MV_PAR19),";")	
		For nCont := 1 To Len(aNatIn)
			cNatIn += If(Empty(cNatIn),"'",",'") + aNatIn[nCont] + "'"
		Next		
		cSql += 	" AND SE2.E2_NATUREZ IN ("+cNatIn+") "
	EndIf

	cTipoIn := ""
	If !Empty(MV_PAR20)
		aTipoIn := StrTokArr(AllTrim(MV_PAR20),";")	
		For nCont := 1 To Len(aTipoIn)
			cTipoIn += If(Empty(cTipoIn),"'",",'") + aTipoIn[nCont] + "'"
		Next		
		cSql += 	" AND SE2.E2_TIPO IN ("+cTipoIn+") "
	EndIf
	
	cFornOut := ""
	If !Empty(MV_PAR21)
		aFornOut := strTokArr(AllTrim(MV_PAR21),";")
		For nCont := 1 To Len(aFornOut)
			cFornOut += If(Empty(cFornOut),"'",",'") + aFornOut[nCont] + "'"
		Next		
		cSql += 	" AND SE2.E2_FORNECE NOT IN ("+cFornOut+") "
	EndIf
			
	cSql += " GROUP BY "+campo

	If select("QR1") > 0
		cSql->(DbCloseArea())
	EndIf
		
	TcQuery cSql new Alias "QR1"  
	MemoWrite("C:\totvs_relatorios\VAFINR07_1.sql" , cSql)
	Do While !QR1->(Eof())	
		nAuxSldT := QR1->SALDO			
		If campo == 'E2_TIPO'
			oPrintPvt:Say(nLinAtu,NCOLFILI,QR1->DESCR + "  (" + UPPER(Alltrim(Posicione("SX5", 1, xFilial("SX5")+"05"+QR1->DESCR, "X5_DESCRI"))) + " )",oFontSub,,,,PAD_LEFT)			
		Else
			oPrintPvt:Say(nLinAtu,NCOLFILI,IIF(!EMPTY(QR1->DESCR),Alltrim(QR1->DESCR),'** Nao especificado **'),oFontSub,,,,PAD_LEFT)
		Endif		
		oPrintPvt:Say(nLinAtu,NCOLPREF+550,"R$ "+AllTrim(Transform(nAuxSldT,"@E 9,999,999,999,999.99")),oFontSub,,,,PAD_RIGHT)
		nLinAtu += 050
		
		//Se a linha atual for menor
		If nLinAtu+0100 > nLinFin
			fImpRod()
			fImpCab(cTitulo)
		EndIf
		
		
		QR1->(DbSkip())
	End Do
		
	QR1->(DbCloseArea())
Return Nil


Static Function ValidPerg(cPerg)        
Local _sAlias, i, j

	_sAlias	:=	Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg 	:=	PADR(cPerg,10)
	aRegs	:=	{}
	//                                                                                                      -- 02 03 04 05 -- 07 08 09 10 -- 12 13 14 15 -- 17 18 19 20 -- 22 23 24 F3
	AADD(aRegs,{cPerg,"01","Filial De        ?",Space(20),Space(20),"mv_ch1","C",02							,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","","",""})
	AADD(aRegs,{cPerg,"02","Filial Até       ?",Space(20),Space(20),"mv_ch2","C",02							,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","","",""})
	AADD(aRegs,{cPerg,"03","Fornecedor De    ?",Space(20),Space(20),"mv_ch3","C",TamSX3("E2_FORNECE")[1]	,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","","","","",""})
	AADD(aRegs,{cPerg,"04","Loja De          ?",Space(20),Space(20),"mv_ch4","C",TamSX3("E2_LOJA")[1]		,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Fornecedor Até   ?",Space(20),Space(20),"mv_ch5","C",TamSX3("E2_FORNECE")[1]	,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","","","","",""})
	AADD(aRegs,{cPerg,"06","Loja Até         ?",Space(20),Space(20),"mv_ch6","C",TamSX3("E2_LOJA")[1]		,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"07","Qual Data        ?",Space(20),Space(20),"mv_ch7","N",01							,0,0,"C","","mv_par07","Digitacao NF","","","","","Dt Emissao","","","","","Dt Base Sistema","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"08","Emissao De       ?",Space(20),Space(20),"mv_ch8","D",08							,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"09","Emissao Até      ?",Space(20),Space(20),"mv_ch9","D",08							,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"10","Desconsid. Natur.?",Space(20),Space(20),"mv_cha","C",99							,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SEDMKB","","","","","",""})
	AADD(aRegs,{cPerg,"11","Desconsid. Tipo  ?",Space(20),Space(20),"mv_chb","C",99							,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","TIPOMB","","","","","",""})
	AADD(aRegs,{cPerg,"12","Filtra Dt Baixa  ?",Space(20),Space(20),"mv_chc","N",01							,0,0,"C","","mv_par12","Filtra Dt Baixa","","","","","Nao Filtrar Baixa","","","","","Dt Base Sistema","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"13","Dt Baixa De      ?",Space(20),Space(20),"mv_chd","D",08							,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"14","Dt Baixa Até     ?",Space(20),Space(20),"mv_che","D",08							,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"15","Dt Vencto De     ?",Space(20),Space(20),"mv_chf","D",08							,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"16","Dt Vencto Até    ?",Space(20),Space(20),"mv_chg","D",08							,0,0,"G","","mv_par16","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"17","Desconsid.Prefixo?",Space(20),Space(20),"mv_chh","C",99							,0,0,"G","","mv_par17","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"18","Tipo Relatorio?   ",Space(20),Space(20),"mv_chi","N",01							,0,0,"C","","mv_par18","Analitico","","","","","Sintetico","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"19","Considera Natur. ?",Space(20),Space(20),"mv_chj","C",99							,0,0,"G","","mv_par19","","","","","","","","","","","","","","","","","","","","","","","","","SEDMKB","","","","","",""})
	AADD(aRegs,{cPerg,"20","Considera Tipo   ?",Space(20),Space(20),"mv_chk","C",99							,0,0,"G","","mv_par20","","","","","","","","","","","","","","","","","","","","","","","","","TIPOMB","","","","","",""})
	AADD(aRegs,{cPerg,"21","Desconsid. Forne ?",Space(20),Space(20),"mv_chl","C",99							,0,0,"G","","mv_par21","","","","","","","","","","","","","","","","","","","","","","","","","SA2MKB","","","","","",""})
	

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				FieldPut(j,aRegs[i,j])
			Next
			MsUnlock()
			dbCommit()
		Endif
	Next
	
	dbSelectArea(_sAlias)
	
Return

/*---------------------------------------------------------------------*
 | Func:  fImpCab                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  06/01/2014                                                   |
 | Desc:  Função para imprimir o cabeçalho                             |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function fImpCab(cTitulo)
	Local cLogoRel	:= "\system\lgmid.png"
	Local nColEspCab	:= 200
	Local nColCab		:= nColIni + 300
	nLinCab	:= 0035
	nPagAtu++
	
	oPrintPvt:StartPage()
	
	//Imprimindo título
	//oPrintPvt:Say(nLinCab, nColMeio, "Extrato de Contrato de "+cTipoCont+" ("+Alltrim(SZA->ZA_CONTRAT)+")",	oFontCab,,,, PAD_CENTER)
	oPrintPvt:Say(nLinCab, nColCab, SM0->M0_NOMECOM, oFontCab)
//	oPrintPvt:Say(nLinCab, nColCab, FWCompanyName(), oFontCab)
	nLinCab += nEspPula + 15

	//Imprimindo logo da afg
	If File(cLogoRel)
		oPrintPvt:SayBitmap(0030,0030,cLogoRel,240,160)
	EndIf  

	//Imprimindo o CNPJ, I.E.
	oPrintPvt:Say(nLinCab, nColCab+0000, "CNPJ: ",	oFontSubN,,,, PAD_LEFT)
	oPrintPvt:Say(nLinCab, nColCab+0000+nColEspCab, Alltrim(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")),	oFontSub,,,, PAD_LEFT)
	oPrintPvt:Say(nLinCab, nColCab+0700, "Insc.Estad.: ",	oFontSubN,,,, PAD_LEFT)
	oPrintPvt:Say(nLinCab, nColCab+0700+nColEspCab, Alltrim(SM0->M0_INSC),	oFontSub,,,, PAD_LEFT)
	nLinCab += nEspPula 
	
	//Imprimindo o Telefone, Fax, Cidade
	oPrintPvt:Say(nLinCab, nColCab+0000, 				"Telefone: ",						oFontSubN,,,, PAD_LEFT)
	oPrintPvt:Say(nLinCab, nColCab+0000+nColEspCab, 	Alltrim(SM0->M0_TEL),				oFontSub,,,, PAD_LEFT)
	oPrintPvt:Say(nLinCab, nColCab+0700, 				"Fax: ",							oFontSubN,,,, PAD_LEFT)
	oPrintPvt:Say(nLinCab, nColCab+0700+nColEspCab, 	Alltrim(SM0->M0_FAX),				oFontSub,,,, PAD_LEFT)
	oPrintPvt:Say(nLinCab, nColCab+1400, 				"Cidade: ",							oFontSubN,,,, PAD_LEFT)
	oPrintPvt:Say(nLinCab, nColCab+1400+nColEspCab, 	Capital(Alltrim(SM0->M0_CIDENT))+" - "+Alltrim(SM0->M0_ESTENT),				oFontSub,,,, PAD_LEFT)
	nLinCab += nEspPula 

	//Título do Relatório
	oPrintPvt:Say(nLinCab, nColCab+0000, 				cTitulo + Iif(Empty(MV_PAR15) .AND. Empty(MV_PAR16),'',' - Venc.: '+Dtoc(MV_PAR15)+' a '+Dtoc(MV_PAR16)),	oFontCab,,,, PAD_LEFT)
	nLinCab += nEspPula+35

	//Fazendo linha de separação
	oPrintPvt:Line(nLinCab-10, nColIni, nLinCab-10, nColFin)
	oPrintPvt:Line(nLinCab-09, nColIni, nLinCab-09, nColFin)
	oPrintPvt:Line(nLinCab-08, nColIni, nLinCab-08, nColFin)
	
	//Imprimindo títulos das colunas
	nLinCab += 10//20
	oPrintPvt:Say(nLinCab,NCOLFILI,"Filial",oFontDadN,,,,PAD_LEFT)
	oPrintPvt:Say(nLinCab,NCOLNATU,"Natureza",oFontDadN,,,,PAD_LEFT)
//	oPrintPvt:Say(nLinCab,NCOLCONT,"Contrato",oFontDadN,,,,PAD_LEFT)
	oPrintPvt:Say(nLinCab,NCOLVENC,"Vencto",oFontDadN,,,,PAD_LEFT)
	oPrintPvt:Say(nLinCab,NCOLPREF,"Pref.",oFontDadN,,,,PAD_LEFT)
	oPrintPvt:Say(nLinCab,NCOLNUME,"Número",oFontDadN,,,,PAD_LEFT)
	oPrintPvt:Say(nLinCab,NCOLPARC,"Parc.",oFontDadN,,,,PAD_LEFT)
	oPrintPvt:Say(nLinCab,NCOLFORN,"Fornecedor",oFontDadN,,,,PAD_LEFT)
	oPrintPvt:Say(nLinCab,NCOLHIST,"Histórico",oFontDadN,,,,PAD_LEFT)
	oPrintPvt:Say(nLinCab,NCOLSALD,"Valor",oFontDadN,,,,PAD_RIGHT)
//	oPrintPvt:Say(nLinCab,NCOLCORR,"Corretor",oFontDadN,,,,PAD_LEFT)
	
	nLinCab += nEspPula + 15
			
	//Fazendo linha de separação
	oPrintPvt:Line(nLinCab-10, nColIni, nLinCab-10, nColFin)
	oPrintPvt:Line(nLinCab-09, nColIni, nLinCab-09, nColFin)
	oPrintPvt:Line(nLinCab-08, nColIni, nLinCab-08, nColfin)
	
	//definindo o valor da linha atual
	nLinAtu := nLinCab
Return

/*-------------------------------------------------------------------------------*
 | Func:  fImpRod                                                                |
 | Autor: Daniel Atilio                                                          |
 | Data:  06/01/2014                                                             |
 | Desc:  Função para impressão do rodapé do relatório                           |
 *-------------------------------------------------------------------------------*/

Static Function fImpRod()
	Local nLinRod	:= nLinFin+30
	Local cTexto	:= dToC(dDataBase)+"     "+cHoraEx+"     "+FunName()+"     "+cUserName

	//Linha de separação
	oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin)
	
	//Dados da Esquerda
	oPrintPvt:Say(nLinRod+20,nColIni,cTexto,oFontRod,,,,PAD_LEFT)
	
	//Dados do centro
	oPrintPvt:Say(nLinRod+20,nColMeio,"TOTVS",oFontRod,,,,PAD_CENTER)
	
	//Número de página
	oPrintPvt:Say(nLinRod+20, nColFin-450,"Página "+	cValToChar(nPagAtu), oFontRod,,,, PAD_RIGHT)
	
	oPrintPvt:EndPage()
Return

//Linha Horizontal
//1.oPrn
//2.Row 
//3.Col 
//4.End
Static Function LH(o,r,c,e)
    o:Line(r,c,r,e)
    //o:Line(r+2,c,r+2,e) //Dupla
Return Nil   
//Linha Vertical
//1.oPrn
//2.Row 
//3.Col 
//4.End
Static Function LV(o,r,c,e)
    o:Line(r,c,e,c)
    //o:Line(r,c+2,e,c+2) //Dupla
Return Nil    
//Cut Line
//1.oPrn
//2.Row 
//3.Col 
//4.End
Static Function LD(o,r,c,e)
     Local i:=0
     For i:=c to e step 40
            LH(o,r,i,i+20) 
     Next     
Return Nil

