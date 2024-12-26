/*
Relatório:

- Parametros
	- Fornecedor de até
	- Data do Fechamento de/Até: (Filtrar campo novo de data de fechamento na TQN)
	- Data Abastecimento (TQN_DTABAS)
	- Cod. Combustível
	- Veículo (TQN Frota)
	
	
	Sessão por Fornecedor 
	1º Sessão informações dos abastecimentos
	
	2ºSessão dados do título financeiro (SE2) SE HOUVER
*/

#include "fileio.ch"
#Include "Protheus.ch"
#include "Tbiconn.ch"
#include "TopConn.ch"
#include "Totvs.ch"
// ###############################################################################################
// Projeto: 
// Fonte  : VAMNTR02.prw
// ---------+------------------------------------+------------------------------------------------
// Data     | Autor                              | Descricao
// ---------+------------------------------------+------------------------------------------------
//  11/03/22|  Manoel Filho                      | Relatório dos Abastecimentos
// ---------+------------------------------------+------------------------------------------------
User Function VAMNTR02()

Local j  , i
Private aReturn   := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cTitulo   := "Relacao de Abastecimentos"
Private cPerg	  := "VAMNTR02"

aRegs := {}

Aadd(aRegs,{cPerg,"01","Forcecedor de" ,"","","mv_ch1"  ,"C", 06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA2",""})
Aadd(aRegs,{cPerg,"02","Loja de"        ,"","","mv_ch2" ,"C", 02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03","Forcecedor até" ,"","","mv_ch3" ,"C", 06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA2",""})
Aadd(aRegs,{cPerg,"04","Loja de"        ,"","","mv_ch4" ,"C", 02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"05","Data Abast de"  ,"","","mv_ch5" ,"D", 08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"06","Data Abast até" ,"","","mv_ch6" ,"D", 08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"07","Data Fechamento","","","mv_ch7" ,"D", 08,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"08","Combustivel"    ,"","","mv_ch8" ,"C", 03,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","TQM",""})
Aadd(aRegs,{cPerg,"09","Veiculo(Frota)" ,"","","mv_ch9" ,"C", 18,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","ST9",""})
Aadd(aRegs,{cPerg,"10","Tipo"           ,"","","mv_cha","C", 1 ,0,0,"C","","mv_par10","1-Prest. Serviço","1-Prest. Serviço","1-Prest. Serviço","3","2-Boiadeiro","2-Boiadeiro","2-Boiadeiro","","3-Todos","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !SX1->(dbSeek(cPerg+"  "+aRegs[i,2]))
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

PERGUNTE(cPerg,.F.) 

set century on  // Seta ano com 4 digitos

VAMNTR02_ImprimeTReport()

Return                                              

/*/{Protheus.doc} VAMNTR02_ImprimeTReport
Chamada do TReport
@author Manoel Filho
@since 11/03/2022
@version undefined
@param 
@type function
/*/
Static Function VAMNTR02_ImprimeTReport()
	Local oReport

	oReport := ReportDef() // Nesta função nós definimos a estrutura do relatório, por exemplo as seções, campos, totalizadores e etc.
	//oReport:SetPortrait()  // Define orientação de página do relatório como retrato.
	oReport:SetLandScape()  // Define orientação de página do relatório como paisagem.
	oReport:PrintDialog()  // Essa função serve para disparar a impressão do TReport, ela que faz com que seja exibida a tela de configuração de impressora e os botões de parâmetros.
Return


/*/{Protheus.doc} ReportDef
TReport
@author Manoel Filho
@since 11/03/2022
@version undefined
@param 
@type function
/*/
Static Function ReportDef()
	Local cDesc := ""
	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3
	Local oSection4
	Local oSection5
	Local oSection6
	Local oSection7

	dDataAb := cTod('')
	cTransp := ""
	cNrAbas := ""
	cCombus := ""
	nQtdLit := 0
	nPreCom := 0
	nTotAba := 0
	cPlaca  := ""
	cMotori := ""
	cNroTit := ""
	cPrefix := ""
	cTipTit := ""
	dEmissa := cTod('')
	nValTit := 0
	dDatFec := cTod('')

	cQuebra := ""
	
	// Descrição
	cDesc := cTitulo

	// TReport
	oReport := TReport():New(           ;
		"VAMNTR02",                     ;
		cTitulo,                        ;
		cPerg,                          ;
		{|oReport| U_I_VAMNTR02(oReport)},;
		cDesc)


	// Cabeçalho
	oSection1 := TRSection():New(oReport, "oQuebra")
	oReport:Section(1):SetLineStyle() // Define se imprime as células da seção em linhas
	oSection1:SetLinesBefore(1)       // Define a quantidade de linhas que serão saltadas antes da impressão da seção
	TRCell():New(oSection1, "oQuebra",, "Transportadora", "@!", 30,, {|| cQuebra },,,,,,,,, .t.) // Transportadora

	// Abastecimentos
	oSection2 := TRSection():New(oReport, "oAbastecimentos")
	oSection2:SetLinesBefore(1) // Define a quantidade de linhas que serão saltadas antes da impressão da seção
	TRCell():New(oSection2, "oDataAb",, OEmToAnsi("Data Abastec")  , "@D"               ,  16,, {|| dDataAb },,,,,,,,,) 
	TRCell():New(oSection2, "oTransp",, OEmToAnsi("veículo")       , "@!"               ,  40,, {|| cVeiculo },,,,,,,,,)
	TRCell():New(oSection2, "oPlaca" ,, OEmToAnsi("Placa")         , "@!"               ,  12,, {|| cPlaca  },,,,,,,,,)  
	TRCell():New(oSection2, "oNrAbas",, OEmToAnsi("Nro Abast")     , "@!"               ,  15,, {|| cNrAbas },,,,,,,,,) 
	TRCell():New(oSection2, "oCombus",, OEmToAnsi("Combustivel")   , "@!"               ,  20,, {|| cCombus },,,,,,,,,) 
	TRCell():New(oSection2, "oQtdLit",, OEmToAnsi("Qtd Litros")    , "@E 99,999.999"    ,  20,, {|| nQtdLit },,,,,,,,,) 
	TRCell():New(oSection2, "oPreCom",, OEmToAnsi("Preço Litro")   , "@E 99,999.9999"   ,  20,, {|| nPreCom },,,,,,,,,) 
	TRCell():New(oSection2, "oTotAba",, OEmToAnsi("Total Abastec") , "@E 9,999,999.999" ,  20,, {|| nTotAba },,,,,,,,,) 
	TRCell():New(oSection2, "oMotori",, OEmToAnsi("Motorista")     , "@!"               ,  30,, {|| cMotori },,,,,,,,,) 
	TRCell():New(oSection2, "oDatFec",, OEmToAnsi("DataFechamento"), "@D"               ,  30,, {|| dDatFec },,,,,,,,,) 

	TRFunction():New(oSection2:Cell("oQtdLit"),,"SUM")
	TRFunction():New(oSection2:Cell("oTotAba"),,"SUM")

	// Dados Financeiros
	oSection3 := TRSection():New(oReport, "oFinanceiro")
	//oReport:Section(3):SetLineStyle() // Define se imprime as células da seção em linhas
	oSection3:SetLinesBefore(2) // Define a quantidade de linhas que serão saltadas antes da impressão da seção
	TRCell():New(oSection3, "oNroTit",, OEmToAnsi("Nro Titulo")  , "@!"                , 30,, {|| cNroTit },,,,,,,,,)
	TRCell():New(oSection3, "oPrefix",, OEmToAnsi("Prefixo")     , "@!"                , 20,, {|| cPrefix },,,,,,,,,)
	TRCell():New(oSection3, "oTipTit",, OEmToAnsi("Tipo")        , "@!"                , 20,, {|| cTipTit },,,,,,,,,)
	TRCell():New(oSection3, "oValTit",, OEmToAnsi("Valor Título"), "@E 99,999,999.9999", 40,, {|| nValTit },,,,,,,,,)
	TRCell():New(oSection3, "oEmissa",, OEmToAnsi("Emissao")     , "@D"                , 30,, {|| dEmissa },,,,,,,,,)

	// Titulo Combustiveis com Preços Definidos
	oSection4 := TRSection():New(oReport, "oCombDefinido")
	//oReport:Section(4):SetLineStyle() // Define se imprime as células da seção em linhas
	oSection4:SetLinesBefore(1) // Define a quantidade de linhas que serão saltadas antes da impressão da seção
	TRCell():New(oSection4, "oTitCad",, ""                        , "@!"               ,100,, {|| cTitCad },,,,,,,,,)
	// Combustiveis com Preços Definidos
	oSection5 := TRSection():New(oReport, "oCombDefinido")
	TRCell():New(oSection5, "oCmbCad",, OEmToAnsi("Combustível")  , "@!"               , 50,, {|| cCmbCad },,,,,,,,,)
	TRCell():New(oSection5, "oDatCad",, OEmToAnsi("Data")         , "@D"               , 30,, {|| dDatCad },,,,,,,,,)
	TRCell():New(oSection5, "oPreCad",, OEmToAnsi("Valor Litro")  , "@E 999.999"       , 40,, {|| nPreCad },,,,,,,,,)

	// Titulo Combustiveis (últimas Compras)
	oSection6 := TRSection():New(oReport, "oCombUltCpa")
	//oReport:Section(5):SetLineStyle() // Define se imprime as células da seção em linhas
	oSection6:SetLinesBefore(1) // Define a quantidade de linhas que serão saltadas antes da impressão da seção
	TRCell():New(oSection6, "oTitCpa",, ""                       , "@!"                ,100,, {|| cTitCpa },,,,,,,,,)
	// Combustiveis (últimas Compras)
	oSection7 := TRSection():New(oReport, "oCombUltCpa")
	TRCell():New(oSection7, "oCmbCpa",, OEmToAnsi("Combustível") , "@!"               , 20,, {|| cCmbCpa },,,,,,,,,)
	TRCell():New(oSection7, "oDatCpa",, OEmToAnsi("Data")        , "@D"               , 20,, {|| dDatCpa },,,,,,,,,)
	TRCell():New(oSection7, "oCmbCpa",, OEmToAnsi("Cod Forn.") , "@!"                 , 15,, {|| cCodFor },,,,,,,,,)
	TRCell():New(oSection7, "oCmbCpa",, OEmToAnsi("Fornecedor") , "@!"                , 50,, {|| cNome },,,,,,,,,)
	TRCell():New(oSection7, "oPreCpa",, OEmToAnsi("Valor Litro") , "@E 999.999"       , 15,, {|| nPreCpa },,,,,,,,,)
	TRCell():New(oSection7, "oNumDoc",, OEmToAnsi("Nota Fiscal") , "@999999999"       , 15,, {|| cNumDoc },,,,,,,,,)
	TRCell():New(oSection7, "oSerDoc",, OEmToAnsi("Série")       , "@!"               , 5,, {|| cSerDoc },,,,,,,,,)

Return(oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³I_VAMNTR02ºAutor  ³Manoel Filho        º Data ³  11/13/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function I_VAMNTR02(oReport)
  
Local cQuery      := ""
Local oSection1   := oReport:Section(1)
Local oSection2   := oReport:Section(2)
Local oSection3   := oReport:Section(3)
Local oSection4   := oReport:Section(4)
Local oSection5   := oReport:Section(5)
Local oSection6   := oReport:Section(6)
Local oSection7   := oReport:Section(7)
Local aRecCombs   := {}
Local nPosVet     := 0
Local nCntFor     := 0
Local nIntCntFor  := 0
Local aVetImprime := {}
    	/*
    	FILIAL                   1
    	NOME FORNECEDOR          2
    	DATA ABASTECIMENTO       3
    	DESCRICAO VEICULO        4
    	PLACA VEICULO            5
    	NUMERO ABASTECI          6
    	CODIGO COMBUST           7
    	NOME COMBUST             8
    	QUANTIDADE ABASTEC       9
    	VALOR UNIT LITRO        10
    	VALOR TOTAL ABAST       11
    	NOME MOTORISTA          12
    	DATA FECHAMENTO         13
    	NUMERO TITULO SE2       14
    	PREFIXO SE2             15
    	TIPO TIT SE2            16
    	VENCIMENTO TIT SE2      17
    	VALOR TIT SE2           18
    	TIPO DE TERCEITO        19
    	CÓDIGO DO VEICULO       20
    	CODIGO FORNEC (TRANSP)  21
    	*/

static cPath      := "C:\totvs_relatorios\"
dDataAb := cTod("")
cTransp := ""
cNrAbas := ""
cCombus := ""
nQtdLit := 0
nPreCom := 0
nTotAba := 0
cPlaca  := ""
cMotori := ""
dDatFec := cTod("")
cNroTit := ""
cPrefix := ""
cTipTit := ""
dEmissa := cTod("")
nValTit := 0

Private oSqlHlp := DMS_SqlHelper():New()


// Le Abastecimentos do Periodo
If Select("TMPTQN") > 0
	TMPTQN->(dbCloseArea())
EndIf
	
cQuery := "SELECT TQN.TQN_FILIAL, TQN.TQN_FROTA, ST9.T9_NOME, TQN.TQN_DTABAS, TQN.TQN_FORST9, TQN.TQN_LOJST9, SA2.A2_NOME, TQN.TQN_CODCOM, TQM.TQM_NOMCOM, TQN.TQN_QUANT, TQN.TQN_NRABAS, TQN.TQN_VUNABA, TQN.TQN_VTTABA, TQN.TQN_DTFABA, ISNULL(TQN.TQN_PLACA, ST9.T9_PLACA) TQN_PLACA, ST9.T9_XTPTER, DA4.DA4_NOME, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_TIPO, SE2.E2_VENCTO, SE2.E2_VALOR "
cQuery += "  FROM "+RetSqlName("TQN")+" TQN "
cQuery += "  JOIN "+RetSqlName('ST9')+" ST9 ON ( ST9.T9_FILIAL = '"+xFilial("ST9")+ "' "
cQuery += "      AND ST9.T9_CODBEM = TQN.TQN_FROTA "
cQuery += "      AND ST9.D_E_L_E_T_ = ' ' )"
cQuery += "  JOIN "+RetSqlName("TQM")+" TQM ON ( TQM.TQM_FILIAL = '"+xFilial("TQM")+ "' "
cQuery += "      AND TQM.TQM_CODCOM = TQN.TQN_CODCOM "
cQuery += "  	 AND TQM.D_E_L_E_T_ = ' ' )"
cQuery += "  JOIN "+RetSqlName("DA4")+" DA4 ON ( DA4.DA4_FILIAL = '"+xFilial("DA4")+ "' "
cQuery += "      AND DA4.DA4_COD = TQN.TQN_CODMOT "
cQuery += "  	 AND DA4.D_E_L_E_T_ = ' ' )"
cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" SA2 ON ( SA2.A2_FILIAL = '"+xFilial("SA2")+ "' "
cQuery += "     AND SA2.A2_COD+SA2.A2_LOJA = TQN.TQN_FORST9+TQN.TQN_LOJST9 "
cQuery += "  	AND SA2.D_E_L_E_T_= ' ' ) "
cQuery += "  LEFT JOIN "+RetSqlName("SE2")+" SE2 ON ( SE2.E2_FILIAL = '"+xFilial("SE2")+ "' "
cQuery += "     AND SE2.E2_FORNECE+SE2.E2_LOJA = TQN.TQN_FORST9+TQN.TQN_LOJST9 "
cQuery += "     AND SE2.E2_FILIAL+SE2.E2_PREFIXO+SE2.E2_NUM+SE2.E2_PARCELA+SE2.E2_TIPO = TQN.TQN_TITABA "
cQuery += "  	AND SE2.D_E_L_E_T_= ' ' ) "
cQuery += "    WHERE TQN.TQN_FILIAL='"+xFilial("TQN")+"' AND ST9.T9_PROPRIE='2'" 
cQuery += "      AND TQN.TQN_COBABA = '1' "
cQuery += "      AND TQN.D_E_L_E_T_ = ' ' "

If !Empty(Mv_Par01) .and. !Empty(Mv_Par02)
	cQuery += "      AND TQN.TQN_FORST9 >= '"+Mv_Par01+"'"
	cQuery += "      AND TQN.TQN_LOJST9 >= '"+Mv_Par02+"'"
Endif

If !Empty(Mv_Par03) .and. !Empty(Mv_Par04)
	cQuery += "      AND TQN.TQN_FORST9 <= '"+Mv_Par03+"'"
	cQuery += "      AND TQN.TQN_LOJST9 <= '"+Mv_Par04+"'"
Endif

If !Empty(Mv_Par05) .and. !Empty(Mv_Par06)
	cQuery += "      AND TQN.TQN_DTABAS BETWEEN '"+Dtos(Mv_Par05)+"' AND '"+dTos(Mv_Par06) +"'" + CRLF
Endif

If !Empty(Mv_Par07)
	cQuery += "      AND TQN.TQN_DTFABA = '"+Dtos(Mv_Par07)+"'" + CRLF
Endif

If !Empty(Mv_Par08)
	cQuery += "      AND TQN.TQN_CODCOM = '"+Mv_Par08+"'" + CRLF
Endif

If !Empty(Mv_Par09)
	cQuery += "      AND TQN.TQN_FROTA = '"+Mv_Par09+"'" + CRLF
Endif

If !Mv_Par10==3
	cQuery += "      AND ST9.T9_XTPTER = '"+CValToChar(Mv_Par10)+"'"
Endif

cQuery += " ORDER BY 1, 5, 4"

if lower(cUserName) $ 'mbernardo,atoshio,admin,administrador'
	MemoWrite(cPath + "Rel_Abast_Terceiros" + DtoS(dDataBase) + "_" + StrTran(SubS(Time(),1,5),":","") + ".sql", cQuery)
EndIf
DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPTQN", .f., .f.)

//////////////////////////////////////////////////////////////////////////qq
While TMPTQN->( !Eof() )

	aadd(aVetImprime,{ ;
	TMPTQN->TQN_FILIAL,;
	TMPTQN->A2_NOME,;
	TMPTQN->TQN_DTABAS,;
	TMPTQN->T9_NOME,;
	TMPTQN->TQN_PLACA,;
	TMPTQN->TQN_NRABAS,;
	TMPTQN->TQN_CODCOM,;
	TMPTQN->TQM_NOMCOM,;
	TMPTQN->TQN_QUANT,;
	TMPTQN->TQN_VUNABA,;
	TMPTQN->TQN_VTTABA,;
	TMPTQN->DA4_NOME,;
	TMPTQN->TQN_DTFABA,;
	TMPTQN->E2_NUM,;
	TMPTQN->E2_PREFIXO,;
	TMPTQN->E2_TIPO,;
	TMPTQN->E2_VENCTO,;
	TMPTQN->E2_VALOR,;
	TMPTQN->T9_XTPTER,;
	TMPTQN->TQN_FROTA,;
	TMPTQN->TQN_FORST9,;
	})

	TMPTQN->(DbSkip())
	
EndDo	
TMPTQN->( DbCloseArea() )

// Le Lançamentos do ARLA do Periodo
If Select("TMPSTL") > 0
	TMPTQN->(dbCloseArea())
EndIf
	
//cQuery := "SELECT STL.TL_FILIAL, STL.TL_CODBEM, ST9.T9_NOME, STJ.TJ_DTORIGI, STL.TL_FORST9, STL.TL_LOJST9, SA2.A2_NOME, STL.TL_QUANTID, STL.TL_NRABAS, STL.TL_VUNABA, STL.TL_VTTABA, STL.TL_DTFABA, ISNULL(STL.TL_PLACA, ST9.T9_PLACA) TL_PLACA, ST9.T9_XTPTER, DA4.DA4_NOME, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_TIPO, SE2.E2_VENCTO, SE2.E2_VALOR "
cQuery := "SELECT STL.TL_FILIAL, STJ.TJ_CODBEM, ST9.T9_NOME, STJ.TJ_DTORIGI, STL.TL_FORST9, STL.TL_LOJST9, SA2.A2_NOME, STL.TL_QUANTID, STL.TL_NRABAS, STL.TL_VUNABA, STL.TL_VTTABA, STL.TL_DTFABA, ST9.T9_PLACA, ST9.T9_XTPTER,  SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_TIPO, SE2.E2_VENCTO, SE2.E2_VALOR "
cQuery += "  FROM "+RetSqlName("STL")+" STL "
cQuery += "	 JOIN "+RetSqlName("STJ")+" STJ ON "
cQuery += "	     STJ.TJ_FILIAL = '"+xFilial("STJ")+ "' "
cQuery += "	 AND STJ.TJ_ORDEM = STL.TL_ORDEM "
cQuery += "	 AND STJ.TJ_PLANO = STL.TL_PLANO AND STJ.D_E_L_E_T_ = ' '"
cQuery += "  JOIN "+RetSqlName('ST9')+" ST9 ON ( ST9.T9_FILIAL = '"+xFilial("ST9")+ "' "
cQuery += "      AND ST9.T9_CODBEM = STJ.TJ_CODBEM "
cQuery += "      AND ST9.D_E_L_E_T_ = ' ' )"
//cQuery += "  JOIN "+RetSqlName("DA4")+" DA4 ON ( DA4.DA4_FILIAL = '"+xFilial("DA4")+ "' "
//cQuery += "      AND DA4.DA4_COD = STL.TL_CODMOT "
//cQuery += "  	 AND DA4.D_E_L_E_T_ = ' ' )"
cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" SA2 ON ( SA2.A2_FILIAL = '"+xFilial("SA2")+ "' "
cQuery += "     AND SA2.A2_COD+SA2.A2_LOJA = STL.TL_FORST9+STL.TL_LOJST9 "
cQuery += "  	AND SA2.D_E_L_E_T_= ' ' ) "
cQuery += "  LEFT JOIN "+RetSqlName("SE2")+" SE2 ON ( SE2.E2_FILIAL = '"+xFilial("SE2")+ "' "
cQuery += "     AND SE2.E2_FORNECE+SE2.E2_LOJA = STL.TL_FORST9+STL.TL_LOJST9 "
cQuery += "     AND SE2.E2_FILIAL+SE2.E2_PREFIXO+SE2.E2_NUM+SE2.E2_PARCELA+SE2.E2_TIPO = STL.TL_TITABA "
cQuery += "  	AND SE2.D_E_L_E_T_= ' ' ) "
cQuery += "    WHERE STL.TL_FILIAL='"+xFilial("STL")+"' AND ST9.T9_PROPRIE='2'" 
cQuery += " AND STL.TL_CODIGO = '130011' "
cQuery += " AND STJ.D_E_L_E_T_ = ' ' "
cQuery += " AND STJ.TJ_SERVICO = 'C00014' "
cQuery += " AND STL.TL_COBABA = '1' "

If !Empty(Mv_Par01) .and. !Empty(Mv_Par02)
	cQuery += "      AND STL.TL_FORST9 >= '"+Mv_Par01+"'"
	cQuery += "      AND STL.TL_LOJST9 >= '"+Mv_Par02+"'"
Endif

If !Empty(Mv_Par03) .and. !Empty(Mv_Par04)
	cQuery += "      AND STL.TL_FORST9 <= '"+Mv_Par03+"'"
	cQuery += "      AND STL.TL_LOJST9 <= '"+Mv_Par04+"'"
Endif

If !Empty(Mv_Par05) .and. !Empty(Mv_Par06)
	cQuery += "      AND STJ.TJ_DTORIGI BETWEEN '"+Dtos(Mv_Par05)+"' AND '"+dTos(Mv_Par06) +"'"
Endif

If !Empty(Mv_Par07)
	cQuery += "      AND STL.TL_DTFABA = '"+Dtos(Mv_Par07)+"'"
Endif

If !Empty(Mv_Par08) .and. MV_Par08 == "007"
	cQuery += "      AND STL.TL_CODIGO = '130011'"
Endif

If !Empty(Mv_Par09)
	cQuery += "      AND STJ.TJ_CODBEM = '"+Mv_Par09+"'"
Endif

cQuery += " ORDER BY 1, 5, 4"

if lower(cUserName) $ 'mbernardo,atoshio,admin,administrador'
	MemoWrite(cPath + "Rel_Abast_Terceiros_ARLA" + DtoS(dDataBase) + "_" + StrTran(SubS(Time(),1,5),":","") + ".sql", cQuery)
EndIf

DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPSTL", .f., .f.)

While TMPSTL->( !Eof() )

	aadd(aVetImprime,{ ;
	TMPSTL->TL_FILIAL,;
	TMPSTL->A2_NOME,;
	TMPSTL->TJ_DTORIGI,;
	TMPSTL->T9_NOME,;
	TMPSTL->T9_PLACA,;
	TMPSTL->TL_NRABAS,;
	"007",;
	"ARLA",;
	TMPSTL->TL_QUANTID,;
	TMPSTL->TL_VUNABA,;
	TMPSTL->TL_VTTABA,;
	" ",;
	TMPSTL->TL_DTFABA,;
	TMPSTL->E2_NUM,;
	TMPSTL->E2_PREFIXO,;
	TMPSTL->E2_TIPO,;
	TMPSTL->E2_VENCTO,;
	TMPSTL->E2_VALOR,;
	TMPSTL->T9_XTPTER,;
	TMPSTL->TJ_CODBEM,;
	TMPSTL->TL_FORST9,;
	})

	TMPSTL->(DbSkip())
	
EndDo	
TMPSTL->( DbCloseArea() )

aSort( aVetImprime , , , { |x,y| x[1]+x[21]+x[3] < y[1]+y[21]+y[3] } )

cQuebra := ""

For nCntFor := 1 to Len(aVetImprime)

	// Quebra
	if cQuebra <> aVetImprime[nCntFor,2]
		oSection1:Init()
		cQuebra := aVetImprime[nCntFor,2]
		oSection1:PrintLine()
		oSection1:Finish()
	Endif

	// Abastecimentos
	oSection2:Init()

	For nIntCntFor := nCntFor to Len(aVetImprime)
	
		If cQuebra == aVetImprime[nIntCntFor,2] .and. nIntCntFor <= Len(aVetImprime)

			dDataAb := Stod(aVetImprime[nIntCntFor,3])
			cVeiculo:= aVetImprime[nIntCntFor,4]
			cPlaca  := aVetImprime[nIntCntFor,5]
			cNrAbas := aVetImprime[nIntCntFor,6]
			cCombus := aVetImprime[nIntCntFor,8]
			nQtdLit := aVetImprime[nIntCntFor,9]
			nPreCom := aVetImprime[nIntCntFor,10]
			nTotAba := aVetImprime[nIntCntFor,11]
			cMotori := aVetImprime[nIntCntFor,12]
			dDatFec := Stod(aVetImprime[nIntCntFor,13])

			// Dados Financeiros
			cNroTit := aVetImprime[nIntCntFor,14]
			cPrefix := aVetImprime[nIntCntFor,15]
			cTipTit := aVetImprime[nIntCntFor,16]
			dEmissa := Stod(aVetImprime[nIntCntFor,17])
			nValTit := aVetImprime[nIntCntFor,18]

			oSection2:PrintLine()

			if aVetImprime[nIntCntFor,19] == "1" // Prestador de Serviço
				cQuery := "SELECT ZAU.R_E_C_N_O_ FROM "+RetSqlName("ZAU")+" ZAU WHERE ZAU.D_E_L_E_T_ = ' ' AND ZAU.ZAU_CODCOM = '"+aVetImprime[nIntCntFor,7]+"' AND ZAU.ZAU_DATCPA = (SELECT Max(ZAU_DATCPA) FROM "+RetSqlName("ZAU")+" WHERE D_E_L_E_T_ = ' ' AND ZAU_DATCPA <= '"+aVetImprime[nIntCntFor,3]+"' AND ZAU_CODCOM = '"+aVetImprime[nIntCntFor,7]+"')"
			Else // If aVetImprime[nIntCntFor,19] == "2" // Transportadora
				cQuery := "SELECT ZAT.R_E_C_N_O_ FROM "+RetSqlName("ZAT")+" ZAT WHERE ZAT.D_E_L_E_T_ = ' ' AND ZAT.ZAT_CODCOM = '"+aVetImprime[nIntCntFor,7]+"' AND ZAT.ZAT_DATCAD = (SELECT Max(ZAT_DATCAD) FROM "+RetSqlName("ZAT")+" WHERE D_E_L_E_T_ = ' ' AND ZAT_DATCAD <= '"+aVetImprime[nIntCntFor,3]+"' AND ZAT_CODCOM = '"+aVetImprime[nIntCntFor,7]+"')"
			Endif
			nRecComb := FM_Sql(cQuery)
			nPosVet  := aScan(aRecCombs,{|x| x[1]+Str(x[2]) == aVetImprime[nIntCntFor,19]+Str(nRecComb) })
			If nPosVet == 0
				aadd(aRecCombs,{ aVetImprime[nIntCntFor,19] , nRecComb, aVetImprime[nIntCntFor,8] })
			Endif

		Else

			exit

		Endif

		nCntFor := nIntCntFor

	Next

	// Dados Financeiros
	oSection3:Init()
	oSection3:PrintLine()
	oSection3:Finish()
	
	oSection2:Finish()
	//oReport:ThinLine() // linha
	oReport:EndPage()
	
Next

// Imprime Preços de Combustíves Utilizados

// (Preços de Combustiveis )

// Titulo Preços de Combustíveis (Valor Definido)
oSection4:Init()
cTitCad := "Preços de Combustíveis (Valor Definido)"
oSection4:PrintLine()
//oReport:ThinLine() // linha
oSection4:Finish()

oSection5:Init()
For nCntFor := 1 To Len(aRecCombs)

	If aRecCombs[nCntFor,1] == "2" // Transportadora

		ZAT->(DbGoTo(aRecCombs[nCntFor,2]))

		cCmbCad := aRecCombs[nCntFor,3]
		dDatCad := ZAT->ZAT_DATCAD
		nPreCad := ZAT->ZAT_VALCOM
		oSection5:PrintLine()

	Endif

Next
oSection5:Finish()

// Titulo Preços de Combustiveis (últimas Compras)
oSection6:Init()
cTitCpa := "Preços de Combustíveis (Últimas Compras)"
oSection6:PrintLine()
//oReport:ThinLine() // linha
oSection6:Finish()

//  Preços de Combustiveis (últimas Compras)
oSection7:Init()
For nCntFor := 1 To Len(aRecCombs)

	If aRecCombs[nCntFor,1] == "1"  // Prestador de Serviço

		ZAU->(DbGoTo(aRecCombs[nCntFor,2]))

		cCmbCpa := aRecCombs[nCntFor,3]
		dDatCpa := ZAU->ZAU_DATCPA
		cCodFor := ZAU->ZAU_FORNEC
		cCodLoj := ZAU->ZAU_LOJA
		cNome   := Posicione("SA2",1,xFilial("SA2")+ZAU->ZAU_FORNECE+ZAU->ZAU_LOJA, "A2_NOME")
		nPreCpa := ZAU->ZAU_VALCOM	
		cNumDoc := ZAU->ZAU_DOC
		cSerDoc := ZAU->ZAU_SERIE

		oSection7:PrintLine()

	Endif

Next
oSection7:Finish()


oReport:Finish()

Return

