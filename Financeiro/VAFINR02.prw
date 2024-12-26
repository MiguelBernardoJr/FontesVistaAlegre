#include "rwmake.ch"
#include "protheus.ch"     
#include "topconn.ch"    


#define DMPAPER_A4 9



User Function VAFINR02()
	local oReport
	local cPerg := PadR('VAFINR02',10)
 
	ValidPerg(cPerg)

	If !Pergunte(cPerg,.T.)
		Return
	endif
	
	oReport := reportDef()
	oReport:printDialog()
Return
 
static function reportDef()
	Local oReport
	Local oSection1
	Local oSection2
	Local cTitulo := '[VAFINR02] - Posicao de Cheques ja compensados no movimento Bancario'

	oReport := TReport():New('VAFINR02', cTitulo, , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de cheques compensados ate a data definida por parametro")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
 
	oSection1 := TRSection():New(oReport,"Posicao Cheques Compensados",{"QRYCHQ"})
	oSection1:SetTotalInLine(.F.)          
	
	TRCell():New(oSection1, "EF_FILIAL" 	, "QRYCHQ", 'Filial'		,PesqPict('SEF',"EF_FILIAL")	,TamSX3("EF_FILIAL")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Filial"
	TRCell():New(oSection1, "EF_NUM"		, "QRYCHQ", 'Num. Cheque'	,PesqPict('SEF',"EF_NUM")		,TamSX3("EF_NUM")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "EF_BANCO"		, "QRYCHQ", 'Banco'			,PesqPict('SEF',"EF_BANCO")		,TamSX3("EF_BANCO")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "EF_AGENCIA"	, "QRYCHQ", 'Agencia'		,PesqPict('SEF',"EF_AGENCIA")	,TamSX3("EF_AGENCIA")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "EF_CONTA"		, "QRYCHQ", 'Conta'			,PesqPict('SEF',"EF_CONTA")		,TamSX3("EF_CONTA")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "EF_BENEF"		, "QRYCHQ", 'Beneficiario'	,PesqPict('SEF',"EF_BENEF")		,TamSX3("EF_BENEF")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "E5_TIPODOC"	, "QRYCHQ", 'Tp Doc'		,PesqPict('SE5',"E5_TIPODOC")	,TamSX3("E5_TIPODOC")[1]+1	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "EF_DATA"		, "QRYCHQ", 'Dt Emissao'	,PesqPict('SEF',"EF_DATA")		,TamSX3("EF_DATA")[1]+1		,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "E5_DTDISPO"	, "QRYCHQ", "Dt Dispon."	,PesqPict('SE5',"E5_DTDISPO")	,TamSX3("E5_DTDISPO")[1]+1 	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "E5_TIPO"		, "QRYCHQ", "Tipo"			,PesqPict('SE5',"E5_TIPO")		,TamSX3("E5_TIPO")[1]+3 	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "EF_VALOR"		, "QRYCHQ", "Valor"			,PesqPict('SEF',"EF_VALOR")		,TamSX3("EF_VALOR")[1]+1 	,/*lPixel*/,/*{|| code-block de impressao }*/)
 
//	oBreak := TRBreak():New(oSection1,oSection1:Cell("E5_FILIAL"),,.F.)
 
//	TRFunction():New(oSection1:Cell("C7_FILIAL"),"TOTAL FILIAL","COUNT",oBreak,,"@E 999999",,.F.,.F.)
 
	TRFunction():New(oSection1:Cell("EF_FILIAL"),"Qtde de Cheques"	,"COUNT",,,"@E 999999",,.F.,.T.)	
	TRFunction():New(oSection1:Cell("EF_VALOR") ,"Valor Total" 		,"SUM",,,PesqPict('SEF',"EF_VALOR"),,.F.,.T.)	
 
return (oReport)
 
Static Function PrintReport(oReport)
 	Local cQryCHQ := ''
	Local oSection1 := oReport:Section(1)
	Local cCHTipo	
	Local dDtDispo	 
	Local aCheques := {}
	Local lAchouCH := .f.	
	If Select("QRYCHQ") > 0
		QRYCHQ->(DbCloseArea())
	EndIf


/*
 
SELECT EF_FILIAL,  EF_NUM, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_BENEF, SE5CH.E5_TIPODOC, EF_DATA, EF_TIPO,     
SE5CH.E5_DATA, SE5CH.E5_DTDISPO, SE5CH.E5_TIPO, EF_VALOR, SE5CH.E5_VALOR, SE5BA.E5_DTDISPO AS BA_DTDISPO,    
SE5CH.E5_DATA, SE5CH.E5_DTDISPO, SE5CH.E5_TIPO, EF_VALOR, SE5CH.E5_VALOR, SE5BA.E5_DTDISPO AS BA_DTDISPO,    
SE5BA.E5_TIPO AS BA_TIPO, SE2AD.E2_NUM AS TITCHNUM, SE2AD.E2_EMISSAO AS TITCHEMISSAO, SE2AD.E2_VENCTO AS TITCHVENCTO, SE2AD.E2_VENCREA AS TITCHVENCREA, SE2AD.E2_TIPO AS TITCHTIPO  
from SEF010 SEF 
left join SE5010 SE5CH ON (SE5CH.E5_FILIAL=EF_FILIAL AND SE5CH.E5_NUMCHEQ=EF_NUM AND SE5CH.E5_BANCO=EF_BANCO AND SE5CH.E5_AGENCIA=EF_AGENCIA AND SE5CH.E5_CONTA=EF_CONTA AND SE5CH.E5_TIPODOC IN ('CH') AND SE5CH.E5_SITUACA = '' AND SE5CH.E5_DTDISPO BETWEEN '20140522' and '20140831' AND SE5CH.D_E_L_E_T_='' ) 
left join SE5010 SE5BA ON (SE5BA.E5_FILIAL=EF_FILIAL AND SE5BA.E5_NUMCHEQ=EF_NUM AND SE5BA.E5_BANCO=EF_BANCO AND SE5BA.E5_AGENCIA=EF_AGENCIA AND SE5BA.E5_CONTA=EF_CONTA AND SE5BA.E5_TIPODOC IN ('BA') AND SE5BA.E5_SITUACA = '' AND SE5BA.E5_DTDISPO BETWEEN '20140522' and '20140831' AND SE5BA.D_E_L_E_T_='' ) 
left join SE2010 SE2AD ON (SE2AD.E2_FILIAL=EF_FILIAL AND SE2AD.E2_PREFIXO=EF_PREFIXO AND SE2AD.E2_NUM=EF_TITULO AND SE2AD.E2_FORNECE=EF_FORNECE AND SE2AD.E2_LOJA=EF_LOJA AND SE2AD.E2_PARCELA=EF_PARCELA  AND SE2AD.E2_TIPO='PA'  AND EF_LIBER = 'N' AND SE2AD.E2_VENCTO BETWEEN '20140522' and '20140831' AND SE2AD.D_E_L_E_T_='' ) 
where EF_DATA BETWEEN '20140226' and '20140226'   
and ( (SE5CH.E5_DTDISPO BETWEEN '20140522' and '20140831' ) OR  (SE5BA.E5_DTDISPO BETWEEN '20140522' and '20140831' AND SE5CH.E5_DTDISPO IS NULL)   OR (EF_TIPO = 'PA' AND  EF_LIBER='N' AND SE2AD.E2_VENCREA BETWEEN '20140522' and '20140831') )
and  EF_BANCO 		BETWEEN '237' and '237' 
and  EF_AGENCIA 	BETWEEN '1931' and '1931' 
and  EF_CONTA 		BETWEEN '521900' and '521900' 
and  EF_FILIAL 		BETWEEN '' and 'ZZ' 
and  SEF.D_E_L_E_T_ =  ' ' 
and ((EF_TIPO = '' and EF_TITULO = '') or (EF_TIPO = 'PA' ) )
 ORDER BY EF_NUM, SE5CH.E5_BENEF, SE5CH.E5_DATA, SE5CH.E5_DTDISPO, SE5CH.E5_BANCO,  SE5CH.E5_NUMCHEQ   
 
*/ 

	cQryCHQ += 	" SELECT EF_FILIAL,  EF_NUM, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_BENEF, SE5CH.E5_TIPODOC, EF_DATA, EF_TIPO, EF_VENCTO,    " 
	cQryCHQ += 	" SE5CH.E5_DATA, SE5CH.E5_DTDISPO, SE5CH.E5_TIPO, EF_VALOR, SE5CH.E5_VALOR, SE5BA.E5_DTDISPO AS BA_DTDISPO,   " 
	cQryCHQ += 	" SE5CH.E5_DATA, SE5CH.E5_DTDISPO, SE5CH.E5_TIPO, EF_VALOR, SE5CH.E5_VALOR, SE5BA.E5_DTDISPO AS BA_DTDISPO,   " 
	cQryCHQ += 	" SE5BA.E5_TIPO AS BA_TIPO, SE2AD.E2_NUM AS TITCHNUM, SE2AD.E2_EMISSAO AS TITCHEMISSAO, SE2AD.E2_VENCTO AS TITCHVENCTO, SE2AD.E2_VENCREA AS TITCHVENCREA, SE2AD.E2_TIPO AS TITCHTIPO  "
 	cQryCHQ += 	" from " + RetSqlName("SEF") + " SEF "
 	cQryCHQ += 	" left join " + RetSqlName("SE5") + " SE5CH ON (SE5CH.E5_FILIAL=EF_FILIAL AND SE5CH.E5_NUMCHEQ=EF_NUM AND SE5CH.E5_BANCO=EF_BANCO AND SE5CH.E5_AGENCIA=EF_AGENCIA AND SE5CH.E5_CONTA=EF_CONTA AND SE5CH.E5_TIPODOC IN ('CH') AND SE5CH.E5_SITUACA = '' AND SE5CH.E5_DTDISPO BETWEEN '" + dtos(mv_par03) + "' and '" + dtos(mv_par04) + "' AND SE5CH.D_E_L_E_T_='' ) "
 	cQryCHQ += 	" left join " + RetSqlName("SE5") + " SE5BA ON (SE5BA.E5_FILIAL=EF_FILIAL AND SE5BA.E5_NUMCHEQ=EF_NUM AND SE5BA.E5_BANCO=EF_BANCO AND SE5BA.E5_AGENCIA=EF_AGENCIA AND SE5BA.E5_CONTA=EF_CONTA AND SE5BA.E5_TIPODOC IN ('BA') AND SE5BA.E5_SITUACA = '' AND SE5BA.E5_DTDISPO BETWEEN '" + dtos(mv_par03) + "' and '" + dtos(mv_par04) + "' AND SE5BA.D_E_L_E_T_='' ) "
 	cQryCHQ += 	" left join " + RetSqlName("SE2") + " SE2AD ON (SE2AD.E2_FILIAL=EF_FILIAL AND SE2AD.E2_PREFIXO=EF_PREFIXO AND SE2AD.E2_NUM=EF_TITULO AND SE2AD.E2_FORNECE=EF_FORNECE AND SE2AD.E2_LOJA=EF_LOJA AND SE2AD.E2_PARCELA=EF_PARCELA  AND SE2AD.E2_TIPO='PA'  AND EF_LIBER = 'N' AND SE2AD.E2_VENCTO BETWEEN '" + dtos(mv_par03) + "' and '" + dtos(mv_par04) + "'  AND SE2AD.D_E_L_E_T_='' )  "
 	cQryCHQ += 	" where EF_DATA BETWEEN '" + dtos(mv_par01) + "' and '" + dtos(mv_par02) + "' "  
	cQryCHQ += 	"  and ( (SE5CH.E5_DTDISPO BETWEEN '" + dtos(mv_par03) + "' and '" + dtos(mv_par04) + "' ) OR  (SE5BA.E5_DTDISPO BETWEEN '" + dtos(mv_par03) + "' and '" + dtos(mv_par04) + "' AND SE5CH.E5_DTDISPO IS NULL)   OR  (EF_TIPO = 'PA' AND  EF_LIBER='N' AND SE2AD.E2_VENCREA BETWEEN '" + dtos(mv_par03) + "' and '" + dtos(mv_par04) + "' ) ) "
    cQryCHQ += 	"  and  EF_BANCO 	BETWEEN '" + mv_par08 + "' and '" + mv_par09 + "' "
    cQryCHQ += 	"  and  EF_AGENCIA 	BETWEEN '" + mv_par10 + "' and '" + mv_par11 + "' "
    cQryCHQ += 	"  and  EF_CONTA 	BETWEEN '" + mv_par12 + "' and '" + mv_par13 + "' "
    cQryCHQ += 	"  and  EF_FILIAL 	BETWEEN '" + mv_par06 + "' and '" + mv_par07 + "' "
    cQryCHQ += 	"  and SEF.D_E_L_E_T_ =  ' ' "
    cQryCHQ += 	"  and ((EF_TIPO = '' and EF_TITULO = '') or (EF_TIPO = 'PA' ) )  and   EF_NATUR <> 'NTCHEST' "
     
 
	If mv_par05 == 1 // Beneficiario
   		cQryCHQ += 	"  ORDER BY EF_BENEF, EF_DATA, SE5CH.E5_DTDISPO, EF_BANCO,  EF_NUM   "
   	Else
   		If   mv_par05 == 2 // Emissao
			   cQryCHQ += 	"  ORDER BY EF_DATA, SE5CH.E5_DTDISPO, EF_BANCO,  EF_NUM  "   		
   		Else  // mv_par05 == 3 Disponibilidade
			   cQryCHQ += 	"  ORDER BY SE5CH.E5_DTDISPO , EF_DATA, EF_BANCO,  EF_NUM "   		
   		Endif
	
	endif

	TCQUERY cQryCHQ NEW ALIAS "QRYCHQ"    
  	//memowrite("D:\TOTVS\vafinr02.txt", cQryCHQ)
	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
 	aCheques := {}
	DbSelectArea('QRYCHQ')
	QRYCHQ->(dbGoTop())
	oReport:SetMeter(QRYCHQ->(RecCount()))
	While QRYCHQ->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf
                 
        lAchouCH := .f.
 		For i:=1 to len(aCheques)
//			If  aCheques[i,1] == QRYCHQ->(EF_FILIAL + EF_NUM + EF_BANCO + EF_AGENCIA + EF_CONTA + EF_TIPO + EF_BENEF ) .and.  aCheques[i,2] = round(QRYCHQ->EF_VALOR,2)     
//			If  (aCheques[i,1]$QRYCHQ->(EF_FILIAL + EF_NUM + EF_BANCO + EF_AGENCIA + EF_CONTA + EF_TIPO + EF_BENEF )) .and. ( aCheques[i,2] == round(QRYCHQ->EF_VALOR,2))
			If  aCheques[i,1] $ QRYCHQ->EF_FILIAL 	.and.;
			    aCheques[i,2] $ QRYCHQ->EF_NUM 		.and.;
			    aCheques[i,3] $ QRYCHQ->EF_BANCO 	.and.;
			    aCheques[i,4] $ QRYCHQ->EF_AGENCIA 	.and.;
			    aCheques[i,5] $ QRYCHQ->EF_CONTA 	.and.;
			    aCheques[i,6] $ QRYCHQ->EF_TIPO 		     
			 	lAchouCH := .t.
        	Endif
	    Next i                       

		if lAchouCH // caso tenha encontrado cheque no array, faz um loop no while
			QRYCHQ->(dbSkip())
			loop
		endif

		aAdd(aCheques,{ QRYCHQ->EF_FILIAL, QRYCHQ->EF_NUM, QRYCHQ->EF_BANCO, QRYCHQ->EF_AGENCIA, QRYCHQ->EF_CONTA, QRYCHQ->EF_TIPO, QRYCHQ->EF_BENEF, QRYCHQ->EF_VALOR})

		oReport:IncMeter()
 
		oSection1:Cell("EF_FILIAL"):SetValue(QRYCHQ->EF_FILIAL)
		oSection1:Cell("EF_FILIAL"):SetAlign("LEFT")
 
		oSection1:Cell("EF_NUM"):SetValue(QRYCHQ->EF_NUM)
		oSection1:Cell("EF_NUM"):SetAlign("LEFT")
 
		oSection1:Cell("EF_BANCO"):SetValue(QRYCHQ->EF_BANCO)
		oSection1:Cell("EF_BANCO"):SetAlign("LEFT")
 
		oSection1:Cell("EF_AGENCIA"):SetValue(QRYCHQ->EF_AGENCIA)
		oSection1:Cell("EF_AGENCIA"):SetAlign("LEFT")

		oSection1:Cell("EF_CONTA"):SetValue(QRYCHQ->EF_CONTA)
		oSection1:Cell("EF_CONTA"):SetAlign("LEFT")

		oSection1:Cell("EF_BENEF"):SetValue(QRYCHQ->EF_BENEF)
		oSection1:Cell("EF_BENEF"):SetAlign("LEFT")

		
		oSection1:Cell("E5_TIPODOC"):SetValue(QRYCHQ->E5_TIPODOC)
		oSection1:Cell("E5_TIPODOC"):SetAlign("LEFT")

		oSection1:Cell("EF_DATA"):SetValue(STOD(QRYCHQ->EF_DATA))
		oSection1:Cell("EF_DATA"):SetAlign("CENTER")

		if !empty(QRYCHQ->E5_DTDISPO)
			dDtDispo:= StoD(QRYCHQ->E5_DTDISPO)
			//dDtDispo:= StoD(QRYCHQ->EF_DTDISPO)			
		else
			if  !empty(QRYCHQ->BA_DTDISPO) 
				dDtDispo:= StoD(QRYCHQ->BA_DTDISPO)
			else     
				dDtDispo:= StoD(QRYCHQ->TITCHVENCREA)
				//dDtDispo:= sToD(QRYCHQ->EF_VENCTO)
			endif
		Endif
			  
		if !empty(QRYCHQ->E5_TIPO)
			cCHTipo:= QRYCHQ->E5_TIPO			
		else
			if  Alltrim(QRYCHQ->TITCHTIPO) = 'PA' 
				cCHTipo:='#PA'
			else     
				cCHTipo:= '**'
			endif
		Endif

		oSection1:Cell("E5_DTDISPO"):SetValue(dDtDispo)
		oSection1:Cell("E5_DTDISPO"):SetAlign("CENTER")

		oSection1:Cell("E5_TIPO"):SetValue( cCHTipo) 
		oSection1:Cell("E5_TIPO"):SetAlign("LEFT")
 
		oSection1:Cell("EF_VALOR"):SetValue(QRYCHQ->EF_VALOR)
		oSection1:Cell("EF_VALOR"):SetAlign("RIGTH")
  
		oSection1:PrintLine()
 


		dbSelectArea("QRYCHQ")
		QRYCHQ->(dbSkip())
				
//		For i:=1 to len(aCheques)
//			If  aCheques[i,1] = QRYCHQ->(EF_FILIAL + EF_NUM + EF_BANCO + EF_AGENCIA + EF_CONTA + EF_TIPO + EF_BENEF ) .and.  aCheques[i,2] = QRYCHQ->EF_VALOR 
//				QRYCHQ->(dbSkip())
//        	Endif
//	    Next i                       

	EndDo
	oSection1:Finish()
	QRYCHQ->(DbCloseArea())
Return
        


Static Function ValidPerg(cPerg)        
Local _sAlias, i, j

	_sAlias	:=	Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg 	:=	PADR(cPerg,10)
	aRegs	:=	{}
	//                                                                                                      -- 02 03 04 05 -- 07 08 09 10 -- 12 13 14 15 -- 17 18 19 20 -- 22 23 24 F3
	AADD(aRegs,{cPerg,"01","Emissao CH De    ?",Space(20),Space(20),"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Emissao CH Até   ?",Space(20),Space(20),"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Dt Disponib. De  ?",Space(20),Space(20),"mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Dt Disponib. Ate ?",Space(20),Space(20),"mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Ordem Impressao  ?",Space(20),Space(20),"mv_ch5","N",01,0,0,"C","","mv_par05","Beneficiario","","","","","Dt Emissao","","","","","Dt Disponibilidade","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"06","Filial De        ?",Space(20),Space(20),"mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"07","Filial Até       ?",Space(20),Space(20),"mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"08","Banco De         ?",Space(20),Space(20),"mv_ch8","C",TamSX3("E5_BANCO")[1]	,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"09","Banco Até        ?",Space(20),Space(20),"mv_ch9","C",TamSX3("E5_BANCO")[1]	,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"10","Agencia De       ?",Space(20),Space(20),"mv_cha","C",TamSX3("E5_AGENCIA")[1],0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"11","Agencia Até      ?",Space(20),Space(20),"mv_chb","C",TamSX3("E5_AGENCIA")[1],0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"12","Conta De         ?",Space(20),Space(20),"mv_chc","C",TamSX3("E5_CONTA")[1]	,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"13","Conta Até        ?",Space(20),Space(20),"mv_chd","C",TamSX3("E5_CONTA")[1]	,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

