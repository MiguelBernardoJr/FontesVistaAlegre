#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include 'TOPCONN.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} VAFINR11
Relatorio de Posicao de Cheques

@author Heimdall Castro
@since 28/04/2019
@version 1.0
@param
@return ( Nil )
@Project
@obs
/*/
//-------------------------------------------------------------------
User Function VAFINR11()

Local oReport := Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= ReportDef()
oReport:PrintDialog()

Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definicoes do relatorio

@author Heimdall Castro
@since 28/04/2019
@version 1.0
@param
@return ( Nil )
@Project
@obs
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport    := Nil
Local oSection1  := Nil
//Local oSection2  := Nil
//Local oSection3  := Nil
Local aParBox    := {}
Local aParRet    := {}
Local cAliasQry  := GetNextAlias()  

aAdd(aParBox,{1,"Data Emissao Cheque De  ",CTOD(Space(	8))   ,"","",""      ,"",50,.F.}) // Tipo data  //aParRet[01]
aAdd(aParBox,{1,"Data Emissao Cheque Ate ",CTOD(Space(8))   ,"","",""      ,"",50,.F.}) // Tipo data  //aParRet[02]
aAdd(aParBox,{1,"Banco De                ",Space(3)         ,"","","SA6"   ,"",50,.F.}) // Tipo Texto //aParRet[03]
aAdd(aParBox,{1,"Agencia De              ",Space(5)         ,"","",""      ,"",50,.F.}) // Tipo Texto //aParRet[04]
aAdd(aParBox,{1,"Conta De                ",Space(10)        ,"","",""      ,"",50,.F.}) // Tipo Texto //aParRet[05]
aAdd(aParBox,{1,"Banco Ate               ",Replicate("Z",3) ,"","","SA6"   ,"",50,.F.}) // Tipo Texto //aParRet[06]
aAdd(aParBox,{1,"Agencia Ate             ",Replicate("Z",5) ,"","",""      ,"",50,.F.}) // Tipo Texto //aParRet[07]
aAdd(aParBox,{1,"Conta Ate               ",Replicate("Z",10),"","",""      ,"",50,.F.}) // Tipo Texto //aParRet[08]

ParamBox(aParBox,"Posicao de Cheques",@aParRet)           

oReport := TReport():New("VAFINR11","Posicao de Cheques",, {|oReport| ReportPrint(@oReport,@cAliasQry, aParRet)},"Posicao de Cheques")
//oReport:SetPortrait()
     
oSection1 := TRSection():New(oReport,"Posicao de Cheques",{"SE5","SEF","SA6"},,.F.,.F.,,.F.,.T.,.F.,.F.,.F.)
oSection1:SetHeaderPage(.T.)
oSection1:SetHeaderBreak(.F.)
oSection1:SetHeaderSection(.F.)

//oCell := TRCell():New(oSection1,"LOCDSC","QRYSQL","Desc. Local"       ,,30,,,"LEFT",,"LEFT")
TRCell():New( oSection1,"BANCO"    , cAliasQry, "Banco"            ,/*Picture*/,/*nTam*/,/*lPixel*/,)
TRCell():New( oSection1,"DescBco"  ,          , ""                 ,/*Picture*/,/*nTam*/,/*lPixel*/, { || DescBco := POSICIONE("SA6",1,xFilial("SA6")+(cAliasQry)->BANCO,"A6_NOME") })
TRCell():New( oSection1,"AGENCIA"  , cAliasQry, "Agencia"          ,/*Picture*/,/*nTam*/,/*lPixel*/,)
TRCell():New( oSection1,"CONTA"    , cAliasQry, "Conta"            ,/*Picture*/,/*nTam*/,/*lPixel*/,)
TRCell():New( oSection1,"DATACH"   ,          , "Data Cheque"      ,/*Picture*/,/*nTam*/,/*lPixel*/, { || STOD((cAliasQry)->DATACH) })
TRCell():New( oSection1,"NUM"      , cAliasQry, "Numero do Cheque" ,/*Picture*/,/*nTam*/,/*lPixel*/,)
TRCell():New( oSection1,"VALOR"    , cAliasQry, "Valor"            ,/*Picture*/,/*nTam*/,/*lPixel*/,)

//oSection2 := TRSection():New(oSection1)
//oSection2:SetHeaderPage(.F.)
//oSection2:SetHeaderBreak(.T.)
//oSection2:SetHeaderSection(.T.)
//
//TRCell():New( oSection2,"DATACH"    , cAliasQry, "Data Cheque"    ,/*Picture*/,/*nTam*/,/*lPixel*/,)
//	
//oSection3 := TRSection():New(oSection2)
//oSection3:SetHeaderPage(.F.)
//oSection3:SetHeaderBreak(.F.)
//oSection3:SetHeaderSection(.T.)
//
//TRCell():New( oSection3,"NUM"    , cAliasQry, "Numero do Cheque" ,/*Picture*/,/*nTam*/,/*lPixel*/,)
//TRCell():New( oSection3,"VALOR"  , cAliasQry, "Valor"            ,/*Picture*/,/*nTam*/,/*lPixel*/,)
//
//oBrkBco := TRBreak():New(oReport, oSection1:CELL("BANCO"),,.F.,,.F.)
//TRFunction():New(oSection1:Cell("BANCO"),,,oBrkBco,,,,.F.,.F.)
//
//oBrkAge := TRBreak():New(oReport, oSection1:CELL("AGENCIA"),,.F.,,.F.)
//TRFunction():New(oSection1:Cell("AGENCIA"),,,oBrkAge,,,,.F.,.F.)
//
//oBrkCnt := TRBreak():New(oReport, oSection1:CELL("CONTA"),,.F.,,.F.)
//TRFunction():New(oSection1:Cell("CONTA"),,,oBrkCnt,,,,.F.,.F.)

Return(oReport)
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressao do relatorio

@author Heimdall Castro
@since 24/08/2016
@version 1.0
@param
@return ( Nil )
@Project
@obs
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport, cAliasQry, aParRet)
Local oSection1  := oReport:Section(1)
//Local oSection2  := oReport:Section(1):Section(1)
//Local oSection3  := oReport:Section(1):Section(1):Section(1)

BEGIN REPORT QUERY oSection1
BeginSql Alias cAliasQry

    SELECT SEF.EF_BANCO AS BANCO, SEF.EF_AGENCIA AS AGENCIA, SEF.EF_CONTA AS CONTA, SEF.EF_DATA AS DATACH, SEF.EF_NUM AS NUM, SEF.EF_VALOR AS VALOR
    FROM %table:SEF% SEF 
	LEFT JOIN %table:SE5% SE5 ON SE5.E5_NUMCHEQ+SE5.E5_BANCO+SE5.E5_AGENCIA+SE5.E5_CONTA = SEF.EF_NUM+SEF.EF_BANCO+SEF.EF_AGENCIA+SEF.EF_CONTA 
				    AND SE5.D_E_L_E_T_ <> '*' AND (SE5.E5_DTDIGIT BETWEEN %Exp:aParRet[01]% AND %Exp:aParRet[02]% OR SE5.E5_DTDISPO BETWEEN %Exp:aParRet[01]% AND %Exp:aParRet[02]%) 
  					AND (SE5.E5_TIPODOC = 'CH' OR SE5.E5_TIPO = 'CH')
  					AND SE5.E5_TIPODOC != 'TR'
  	WHERE SEF.EF_DATA BETWEEN %Exp:aParRet[01]% AND %Exp:aParRet[02]%
  	  AND SEF.EF_BANCO BETWEEN %Exp:aParRet[03]% AND %Exp:aParRet[06]%
  	  AND SEF.EF_AGENCIA BETWEEN %Exp:aParRet[04]% AND %Exp:aParRet[07]%
  	  AND SEF.EF_CONTA BETWEEN %Exp:aParRet[05]% AND %Exp:aParRet[08]%
  	  AND SEF.D_E_L_E_T_ <> '*'
  	  AND SEF.EF_NUM <> ''
  	GROUP BY SEF.EF_BANCO, SEF.EF_AGENCIA, SEF.EF_CONTA, SEF.EF_DATA, SEF.EF_NUM, SEF.EF_VALOR
	HAVING COUNT(SE5.E5_NUMCHEQ) = 0
	ORDER BY BANCO, AGENCIA, CONTA, DATACH, NUM 

EndSql
END REPORT QUERY oSection1

aQueryExec := GetLastQuery()

//Grava Querys para Debug
cPastaLog := "\DEBUGREL\"
makedir(cPastaLog)

cPastaLog := "\DEBUGREL\" + DTOS(dDataBase) + "\"
makedir(cPastaLog)

cNomeArq := cPastaLog + "VAFINR11-" + cUserName + "-" + StrTran(Time(),":","") + ".log"

MEMOWRITE(cNomeArq,aQueryExec[2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao do Relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea(cAliasQry)
(cAliasQry)->(DbGotop())

oSection1:SetParentQuery()                                                                           
oSection1:SetParentFilter( {|A| (cAliasQry)->BANCO + (cAliasQry)->AGENCIA + (cAliasQry)->CONTA == A}, {|| (cAliasQry)->BANCO + (cAliasQry)->AGENCIA + (cAliasQry)->CONTA })
                                 
//oSection2:SetParentQuery()                                                                           
//oSection2:SetParentFilter( {|E| (cAliasQry)->DATACH == E }, {|| (cAliasQry)->DATACH})
//
//oSection3:SetParentQuery()                                                                           
//oSection3:SetParentFilter( {|F| (cAliasQry)->NUM == F }, {|| (cAliasQry)->NUM})

oSection1:Print()
oReport:SetMeter((cAliasQry)->(LastRec()))

Return (oReport)