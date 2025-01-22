//**********************************************
//RELATORIO DE TITULOS PAGOS
//**********************************************
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
 
#DEFINE PAD_RIGHT 	1 

#DEFINE COL_1		0000
#DEFINE COL_2		0300
#DEFINE COL_3		0550
#DEFINE COL_4		0700
#DEFINE COL_5		0900
#DEFINE COL_6		1100
#DEFINE COL_7		1700 
#DEFINE COL_8		3000
#DEFINE EXTESAO 	3200
#DEFINE CENTRO  	1500
#DEFINE CDIREITO 	2900

//Função Principal do relatório                             
User Function VAFINR05()
Private cPerg

	nOrdem   :=0
	tamanho  :="P"
	limite   :=80
	titulo   :=PADC("VAFINR05",74)
	cDesc1   :=PADC("Titulos Pagos",74)
	cDesc2   :=""
	cDesc3   :=""
	aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
	nomeprog :="VAFINR05"
	cPerg    :="VAFINR05"
	nLastKey := 0
	wnrel    := "VAFINR05"
	cQuery	 :=""

	ValidPerg(cPerg)
	
	While Pergunte(cPerg, .T.)
		MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
	Enddo
	
Return                        

///**************************************************************************
///PERGUNTAS DO RELATÓRIO
///**************************************************************************
Static Function ValidPerg(cPerg)
Local _sAlias,i,j

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}                                                  

	AADD(aRegs,{cPerg,"01","Filial De             ?",Space(20),Space(20),"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Filial Ate            ?",Space(20),Space(20),"mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Pagos de         	  ?",Space(20),Space(20),"mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Pagos até        	  ?",Space(20),Space(20),"mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Fornecedor De         ?",Space(20),Space(20),"mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	AADD(aRegs,{cPerg,"06","Fornecedor Ate        ?",Space(20),Space(20),"mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	AADD(aRegs,{cPerg,"07","Loja De               ?",Space(20),Space(20),"mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"08","Loja Ate              ?",Space(20),Space(20),"mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})		
	AADD(aRegs,{cPerg,"09","Tipo relatório		  ?",Space(20),Space(20),"mv_ch9","N",01,0,2,"C","","mv_par09","1-Analítico","","","","","2-Sintético","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"10","Natureza (sep. p/ ';')?",Space(20),Space(20),"mv_cha","C",99,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SEDMKB","","","","",""})
	AADD(aRegs,{cPerg,"11","Prefixo  (sep. p/ ';')?",Space(20),Space(20),"mv_chb","C",99,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"12","Imprime Excel         ?",Space(20),Space(20),"mv_chc","N",01,0,2,"C","","mv_par09","1-Sim","","","","","2-Nao","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				FieldPut(j,aRegs[i,j])
			Next
			MsUnlock()
			dbCommit()
		EndIf
	Next
	dbSelectArea(_sAlias)
	
Return

//Imprimindo relatório
Static Function ImprRel(cPerg)
Local nCont:=0
Local nTot1:=0
Local strCliente:=""  
Local xNumCTR:=""   
Local cAba1 	:= "Titulos Pagos - " + iif(MV_PAR09==1,"Analitico ","Sintetico ")
Local cTable1	:= "Titulos Pagos - " + iif(MV_PAR09==1,"Analitico ","Sintetico ") + " ( atualizado até  "+'Periodo de Pagamento: ' + SubStr(DtoS(MV_PAR03),7,2)+'/'+SubStr(DtoS(MV_PAR03),5,2) +'/'+ SubStr(DtoS(MV_PAR03),1,4) + " a: " + SubStr(DtoS(MV_PAR04),7,2)+'/'+SubStr(DtoS(MV_PAR04),5,2) +'/'+ SubStr(DtoS(MV_PAR04),1,4)+")" 

Private strDia, strDiaAtu, strNomeImp, strNatur, strNaturA,strForn, strFornA, mTotalN:=0, mTotalP:=0, mTotal:=0, cNaturs := '', mTotalC:= 0, mTotalF:= 0, mTotalD:= 0
Private nLinha, nLinhaT, cPag   
Private nQuebra:=2215      
// Tratamento para Excel
Private oExcel
Private oExcelApp
Private cArquivo  := GetTempPath()+'vafinr05_'+StrTran(dToC(dDataBase), '/', '-')+'_'+StrTran(Time(), ':', '-')+'.xml'




	cNaturs := alltrim(MV_PAR10)
	If MV_PAR09==1 ////RELATORIO ANALITICO
		strSQL:="SELECT E5_FILIAL, E2_NOMFOR AS E2_NOMFOR, E5_DATA, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_CLIFOR, "
	Else
		strSQL:="SELECT E5_FILIAL, E2_NOMFOR AS E2_NOMFOR, E5_DATA, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_CLIFOR, "
	Endif
	strSQL+="E5_LOJA, E5_BENEF, E2_HIST, E5_VALOR, CASE WHEN E2_NATUREZ = '' THEN '99999' ELSE E2_NATUREZ END AS E2_NATUREZ, E5_TIPO, E5_TIPODOC, E5_KEY, E5_SEQ, E5_HISTOR AS E5HIST FROM " + RetSqlName("SE5") + " AS SE5 WITH (NOLOCK) "
	strSQL+="INNER JOIN " + RetSqlName("SE2") + " AS SE2 WITH (NOLOCK) ON E2_FILIAL = E5_FILIAL "
	strSQL+="	AND E2_FORNECE = E5_CLIFOR "
	strSQL+="	AND E2_LOJA = E5_LOJA "
	strSQL+="	AND E2_NUM = E5_NUMERO "
	strSQL+="	AND E2_PREFIXO = E5_PREFIXO "
	strSQL+="	AND E2_PARCELA = E5_PARCELA AND SE2.D_E_L_E_T_ <> '*' "
	strSQL+="WHERE SE5.D_E_L_E_T_ <> '*' " 
	
	
	If !Empty(ALLTRIM(MV_PAR11))
		cPfxAux := ALLTRIM(MV_PAR11)
		If ";"$cPfxAux
			cPfx := StrTran(ALLTRIM(MV_PAR11), ';', "','")
		Else	
			cPfx := StrTran(cPfxAux+';', ';', "','")
		Endif	
//		cPfx := StrTran(ALLTRIM(MV_PAR11), ';', "','")
		If SubStr(cPfx, Len(cPfx)-1, 2) == ",'"
			cPfx := "'"+SubStr(cPfx, 1, Len(cPfx)-2)
		EndIf
		strSQL+="	AND E5_PREFIXO IN ("+cPfx+") "
	EndIf
	
	If !Empty(MV_PAR10)
		cNaturs := StrTran(cNaturs, ';', "','")
		If SubStr(cNaturs, Len(cNaturs)-1, 2) == ",'"
			cNaturs := "'"+SubStr(cNaturs, 1, Len(cNaturs)-2)
		EndIf
		strSQL+="	AND SE5.E5_NATUREZ IN ('"+cNaturs+"') "
	EndIf
	
	strSQL+="	AND E5_FILIAL 	BETWEEN '"+MV_PAR01+"' 			AND '"+MV_PAR02+"' "
	strSQL+="	AND E5_DATA 	BETWEEN '"+DtOS(MV_PAR03)+"' 	AND '"+DtOS(MV_PAR04)+"' "
	strSQL+="	AND E5_CLIFOR 	BETWEEN '"+MV_PAR05+"' 			AND '"+MV_PAR06+"' "
	strSQL+="	AND E5_LOJA 	BETWEEN '"+MV_PAR07+"' 			AND '"+MV_PAR08+"' "
	strSQL+="	AND E5_RECPAG = 'P' "
	strSQL+="	AND E5_MOTBX IN ('NOR','DEB') "
	strSQL+="	AND (E5_TIPODOC+E5_MOTBX <> 'BANOR')  " // nao considerar baixas que tenham cheque
	strSQL+="	AND E5_TIPODOC NOT IN ('ES') "	// desconsiderar estornos
	strSQL+="	AND E5_VALOR > 0 " // para evitar impressao de linhas nao consideradas no movimento de descontos, etc
	// foi incluido para tratar cancelamento de compensacoes com cheques cancelados
	strSQL+="	AND E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ NOT IN  "
	strSQL+="	(SELECT EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM FROM " + RetSqlName("SEF") + "  SEF WITH (NOLOCK) WHERE EF_NATUR ='NTCHEST'  AND EF_IMPRESS='C'  AND EF_NUM <> ''  AND SEF.D_E_L_E_T_ = '' ) "

	
	
	strSQL+="UNION ALL "             
	
	If MV_PAR09==1 //RELATORIO ANALITICO
		strSQL+="SELECT E5_FILIAL, E1_NOMCLI AS E2_NOMFOR, E5_DATA, E5_PREFIXO, E5_NUMERO, E5_PARCELA,  E5_CLIFOR, "
	Else
		strSQL+="SELECT E5_FILIAL, E1_NOMCLI AS  E2_NOMFOR, E5_DATA, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_CLIFOR, "
	Endif
	strSQL+="E5_LOJA, E5_BENEF, E1_HIST AS E2_HIST, E5_VALOR, CASE WHEN E1_NATUREZ = '' THEN '99999' ELSE E1_NATUREZ END AS E2_NATUREZ, E5_TIPO, E5_TIPODOC, E5_KEY, E5_SEQ, E5_HISTOR AS E5HIST FROM " + RetSqlName("SE5") + " AS SE5 WITH (NOLOCK) "
	strSQL+="INNER JOIN " + RetSqlName("SE1") + " AS SE1 WITH (NOLOCK) ON E1_FILIAL = E5_FILIAL "
	strSQL+="	AND E1_CLIENTE = E5_CLIFOR "
	strSQL+="	AND E1_LOJA = E5_LOJA "
	strSQL+="	AND E1_NUM = E5_NUMERO "
	strSQL+="	AND E1_PREFIXO = E5_PREFIXO "
	strSQL+="	AND E1_PARCELA = E5_PARCELA AND SE1.D_E_L_E_T_ <> '*' "
	strSQL+="WHERE SE5.D_E_L_E_T_ <> '*' "
	
	//Prefixos
	If !Empty(ALLTRIM(MV_PAR11))
		cPfxAux := ALLTRIM(MV_PAR11)
		If ";"$cPfxAux
			cPfx := StrTran(ALLTRIM(MV_PAR11), ';', "','")
		Else	
			cPfx := StrTran(cPfxAux+';', ';', "','")
		Endif	
//		cPfx := StrTran(ALLTRIM(MV_PAR11), ';', "','")
		If SubStr(cPfx, Len(cPfx)-1, 2) == ",'"
			cPfx := "'"+SubStr(cPfx, 1, Len(cPfx)-2)
		EndIf
		strSQL+="	AND E5_PREFIXO IN ("+cPfx+") "
	EndIf

	If !Empty(MV_PAR10)
		cNaturs := StrTran(cNaturs, ';', "','")
		If SubStr(cNaturs, Len(cNaturs)-1, 2) == ",'"
			cNaturs := "'"+SubStr(cNaturs, 1, Len(cNaturs)-2)
		EndIf
		strSQL+="	AND SE5.E5_NATUREZ IN ('"+cNaturs+"') "
	EndIf
	
	strSQL+="	AND E5_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	strSQL+="	AND E5_DATA BETWEEN '"+DtOS(MV_PAR03)+"' AND '"+DtOS(MV_PAR04)+"' "
	strSQL+="	AND E5_CLIFOR 	BETWEEN '"+MV_PAR05+"' 			AND '"+MV_PAR06+"' "
	strSQL+="	AND E5_LOJA 	BETWEEN '"+MV_PAR07+"' 			AND '"+MV_PAR08+"' "
	strSQL+="	AND E5_RECPAG = 'P' "
	strSQL+="	AND E5_MOTBX IN ('NOR','DEB') "
	strSQL+="	AND (E5_TIPODOC+E5_MOTBX <> 'BANOR')  " // nao considerar baixas que tenham cheque
	strSQL+="	AND E5_TIPODOC NOT IN ('ES') "	// desconsiderar estornos
	strSQL+="	AND E5_VALOR > 0 " // para evitar impressao de linhas nao consideradas no movimento de descontos, etc
	// foi incluido para tratar cancelamento de compensacoes com cheques cancelados
	strSQL+="	AND E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ NOT IN  "
	strSQL+="	(SELECT EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM FROM " + RetSqlName("SEF") + "  SEF WITH (NOLOCK) WHERE EF_NATUR ='NTCHEST'  AND EF_IMPRESS='C'  AND EF_NUM <> ''  AND SEF.D_E_L_E_T_ = '' ) "
	

	strSQL+="UNION ALL "             
	
	If MV_PAR09==1 //RELATORIO ANALITICO
		strSQL+="SELECT E5_FILIAL, 'MOV.BANCARIO' AS E2_NOMFOR,  E5_DATA, E5_PREFIXO, E5_NUMERO, E5_PARCELA,  E5_CLIFOR, "
	Else
		strSQL+="SELECT E5_FILIAL, 'MOV.BANCARIO' AS  E2_NOMFOR, E5_DATA, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_CLIFOR, "
	Endif
	strSQL+="E5_LOJA, E5_BENEF, E5_HISTOR AS E2_HIST, E5_VALOR, CASE WHEN E5_NATUREZ = '' THEN '99999' ELSE E5_NATUREZ END AS E2_NATUREZ, E5_TIPO, E5_TIPODOC, E5_KEY, E5_SEQ, E5_HISTOR AS E5HIST FROM " + RetSqlName("SE5") + " AS SE5 WITH (NOLOCK) "
	strSQL+="WHERE SE5.D_E_L_E_T_ <> '*' "
	
	//Prefixos
	If !Empty(ALLTRIM(MV_PAR11))
		cPfxAux := ALLTRIM(MV_PAR11)
		If ";"$cPfxAux
			cPfx := StrTran(ALLTRIM(MV_PAR11), ';', "','")
		Else	
			cPfx := StrTran(cPfxAux+';', ';', "','")
		Endif	
//		cPfx := StrTran(ALLTRIM(MV_PAR11), ';', "','")
		If SubStr(cPfx, Len(cPfx)-1, 2) == ",'"
			cPfx := "'"+SubStr(cPfx, 1, Len(cPfx)-2)
		EndIf
		strSQL+="	AND E5_PREFIXO IN ("+cPfx+") "
	EndIf

	If !Empty(MV_PAR10)
		cNaturs := StrTran(cNaturs, ';', "','")
		If SubStr(cNaturs, Len(cNaturs)-1, 2) == ",'"
			cNaturs := "'"+SubStr(cNaturs, 1, Len(cNaturs)-2)
		EndIf
		strSQL+="	AND SE5.E5_NATUREZ IN ('"+cNaturs+"') "
	EndIf
	
	strSQL+="	AND E5_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	strSQL+="	AND E5_DATA BETWEEN '"+DtOS(MV_PAR03)+"' AND '"+DtOS(MV_PAR04)+"' "
	strSQL+="	AND E5_CLIFOR 	BETWEEN '"+MV_PAR05+"' 			AND '"+MV_PAR06+"' "
	strSQL+="	AND E5_LOJA 	BETWEEN '"+MV_PAR07+"' 			AND '"+MV_PAR08+"' "
	strSQL+="	AND E5_CLIFOR = '' " 
	strSQL+="	AND E5_RECPAG = 'P' "
//	strSQL+="	AND E5_MOTBX IN ('NOR','DEB') "
	strSQL+="	AND (E5_TIPODOC+E5_MOTBX <> 'BANOR')  " // nao considerar baixas que tenham cheque
	strSQL+="	AND E5_TIPODOC NOT IN ('ES','TR','TB') "	// desconsiderar estornos
	strSQL+="	AND E5_VALOR > 0 " // para evitar impressao de linhas nao consideradas no movimento de descontos, etc
	// foi incluido para tratar cancelamento de compensacoes com cheques cancelados
	strSQL+="	AND E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ NOT IN  "
	strSQL+="	(SELECT EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM FROM " + RetSqlName("SEF") + "  SEF WITH (NOLOCK) WHERE EF_NATUR ='NTCHEST'  AND EF_IMPRESS='C'  AND EF_NUM <> ''  AND SEF.D_E_L_E_T_ = '' ) "

		
	strSQL+= " ORDER BY E5_FILIAL ASC, E5_DATA ASC, E2_NATUREZ ASC, E5_CLIFOR ASC, E5_LOJA ASC, E5_TIPO ASC, E5_PREFIXO ASC, E5_NUMERO ASC "
	

	Memowrite("D:\TOTVS\VAFINR05.txt",strSQL)	
	
	
	If Select("ORSSE2") > 0
		ORSSE2->(DbCloseArea())
	EndIf
	TcQuery strSQL New Alias "ORSSE2"
	
	If MV_PAR12==1 // Gera Excel
		//Criando o objeto que irá gerar o conteúdo do Excel
		oExcel := FWMSExcel():New()
		
		//Aba 01 - Relatorio 
		oExcel:AddworkSheet(cAba1)
			//Criando a Tabela
			oExcel:AddTable(cAba1,cTable1)
			oExcel:AddColumn(cAba1,cTable1,"Filial",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
			oExcel:AddColumn(cAba1,cTable1,"Natureza",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
			oExcel:AddColumn(cAba1,cTable1,"Data Pagto",		1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
			oExcel:AddColumn(cAba1,cTable1,"Prefixo",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
			oExcel:AddColumn(cAba1,cTable1,"Titulo",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
			oExcel:AddColumn(cAba1,cTable1,"Parcela",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
			oExcel:AddColumn(cAba1,cTable1,"Fornecedor",		1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
			oExcel:AddColumn(cAba1,cTable1,"Historico",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
			oExcel:AddColumn(cAba1,cTable1,"R$ Valor Pago",		3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
			oExcel:AddColumn(cAba1,cTable1,"",					1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	Endif
	
	If !ORSSE2->(EOF())
				
		oFont07 := TFont():New("Tahoma",,-07,.T.,.F.,5,.T.,5,.T.,.F.) //Texto normal (linhas)
		oFont07n:= TFont():New("Tahoma",,-07,.T.,.T.,5,.T.,5,.T.,.F.) //Total
		oFont09n:= TFont():New("Tahoma",,-09,.T.,.T.,5,.T.,5,.T.,.F.) //Cabeçalho
		oFont12n:= TFont():New("Tahoma",,-12,.T.,.T.,5,.T.,5,.T.,.F.) //Título do cabeçalho 
		oFont14n:= TFont():New("Tahoma",,-14,.T.,.T.,5,.T.,5,.T.,.F.) //Título do cabeçalho 
				
		oPrint:=TMSPrinter():New(cDesc1) 
		oPrint:Setup()
		oPrint:SetLandscape() //SetPortrait()
		oPrint:SetPaperSize(DMPAPER_A4)
		oPrint:StartPage()
		nMargem := 0050
		nTopo   := 0010
		nLinhaT := 0040 //0050
		nColunaT:= 0140
		nLinha  := 0050
		nColuna := 0000
		cPag:=0

		ImpCabe(oPrint,nColuna,nTopo,nMargem,oFont14n,oFont09n,nColunaT)
		
		While !ORSSE2->(EOF()) 
			nCont:=0
			nColuna:=0000
	
			//DESCONSIDERA TITULOS ESTORNADOS
			If Estornado()
				DbSelectArea("ORSSE2")
				ORSSE2->(DbSkip())
				Loop
			EndIf
			
			//DESCONSIDERA DESCONTO/JUROS/MULTA			
			If AllTrim(ORSSE2->E5_TIPODOC)$ "DC,JR,MT"
				DbSelectArea("ORSSE2")
				ORSSE2->(DbSkip())
				Loop
			EndIf  			
			
			//BUSCA O CNPJ DA EMPRESA        
			strNome := U_BuscaSM0(ORSSE2->E5_FILIAL)
			If strNomeImp<>strNome
			
				If mTotalF > 0 .and. MV_PAR09<>1  // somente sinteticos
					If nLinha >= nQuebra              
						ChecaCab()
					Endif
					// tRATAR IMPRESSAO POR FORNECEDOR
					oPrint:Say(nLinha + nTopo, COL_2 + nMargem, strDiaAtu,   oFont07) 
					oPrint:Say(nLinha + nTopo, COL_6 + nMargem, strFornA, oFont07)
					nColuna+=nColunaT + nColunaT + 1000
					oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalF,"@E 9,999,999,999,999.99"), oFont07,,,,PAD_RIGHT) 
					mTotalF:=0
					nLinha+=nLinhaT			                  
				EndIf


				If mTotalN > 0
					If nLinha >= nQuebra              
						ChecaCab()
					Endif
					oPrint:Say(nLinha + nTopo, COL_7 + nMargem, "-------> "+strNaturA+ "-"+ POSICIONE("SED",1,XFILIAL("SED")+strNaturA,"ED_DESCRIC"), oFont07n)
					nColuna+=nColunaT + nColunaT + 1000
					oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalN,"@E 9,999,999,999,999.99"), oFont07n,,,,PAD_RIGHT) 
					mTotalN:=0
					nLinha+=nLinhaT			                  
				EndIf
				

				If mTotalD > 0
					If nLinha >= nQuebra              
						ChecaCab()
					Endif
					oPrint:Say(nLinha + nTopo, COL_2 + nMargem, "-------> sub-total dia "+strDiaAtu, oFont07n)
					nColuna+=nColunaT + nColunaT + 1000
					oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalD,"@E 9,999,999,999,999.99"), oFont07n,,,,PAD_RIGHT) 
					mTotalD:=0
					nLinha+=nLinhaT + (nLinhaT/2)			                  
				EndIf


				If mTotalP > 0
					If nLinha >= nQuebra              
						ChecaCab()
					Endif				
					oPrint:Say(nLinha + nTopo, COL_7 + nMargem, '-------> TOTAL FILIAL ', oFont09n)
					nColuna+=nColunaT + nColunaT + 1000
					oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalP,"@E 9,999,999,999,999.99"), oFont09n,,,,PAD_RIGHT) 
					mTotalP:=0
					nLinha+=nLinhaT + (nLinhaT/2)			                  
				EndIf

				strNomeImp:=strNome								
				If nLinha >= nQuebra              
					ChecaCab()
				Else
					oPrint:Say(nLinha + nTopo, COL_1 + nMargem, strNomeImp, oFont09n)
				EndIf
				nLinha+=nLinhaT
			EndIf			
			
			strNatur:=AllTrim(ORSSE2->E2_NATUREZ)
			If AllTrim(ORSSE2->E5_BENEF)=="" .OR. Alltrim(ORSSE2->E5_BENEF)<>Alltrim(POSICIONE("SA2",1,XFILIAL("SA2")+ORSSE2->(E5_CLIFOR+E5_LOJA),"A2_NOME"))
				strForn:=AllTrim(ORSSE2->E5_CLIFOR+"-"+ORSSE2->E5_LOJA)+"-"+POSICIONE("SA2",1,XFILIAL("SA2")+ORSSE2->(E5_CLIFOR+E5_LOJA),"A2_NOME")				
			Else
				strForn:=AllTrim(ORSSE2->E5_CLIFOR+"-"+ORSSE2->E5_LOJA+"-"+ORSSE2->E5_BENEF)
			EndIf	
			strDia := DTOC(STOD(ORSSE2->E5_DATA))		
			If MV_PAR09==1 //RELATORIO ANALITICO
				If strNatur<>strNaturA    // sub total natureza 
					If mTotalN > 0
						If nLinha >= nQuebra              
							ChecaCab()
						Endif				
						oPrint:Say(nLinha + nTopo, COL_7 + nMargem, "-------> "+strNaturA+ "-"+ POSICIONE("SED",1,XFILIAL("SED")+strNaturA,"ED_DESCRIC"), oFont07n)
						nColuna+=nColunaT + nColunaT + 1000
						oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalN,"@E 9,999,999,999,999.99"), oFont07n,,,,PAD_RIGHT) 
						mTotalN:=0
						nLinha+=nLinhaT			                  
					EndIf
					strNaturA:=strNatur
				EndIf
				
				If strDia<>strDiaAtu  // sub total dia
					If mTotalD > 0
						If nLinha >= nQuebra              
							ChecaCab()
						Endif				
						oPrint:Say(nLinha + nTopo, COL_2 + nMargem, "-------> sub-total dia "+strDiaAtu, oFont07n)
						nColuna+=nColunaT + nColunaT + 1000
						oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalD,"@E 9,999,999,999,999.99"), oFont07n,,,,PAD_RIGHT) 
						mTotalD:=0
						nLinha+=nLinhaT +(nLinhaT/2)			                  
					EndIf
					strDiaAtu:=strDia
				EndIf				
				
			Else //SINTETICO
				If strForn<>strFornA .or. strDia<>strDiaAtu .or. strNatur<>strNaturA
					If mTotalF > 0
						If nLinha >= nQuebra              
							ChecaCab()
						Endif				
						oPrint:Say(nLinha + nTopo, COL_2 + nMargem, strDiaAtu,   oFont07) 
						oPrint:Say(nLinha + nTopo, COL_6 + nMargem, strFornA, oFont07)
						nColuna+=nColunaT + nColunaT + 1000
						oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalF,"@E 9,999,999,999,999.99"), oFont07,,,,PAD_RIGHT) 
						mTotalF:=0
						nLinha+=nLinhaT			                  
					EndIf
					strFornA:=strForn
				EndIf

				If strNatur<>strNaturA  .or. strDia<>strDiaAtu //.or. AllTrim(xNumCTR) <> AllTrim(ORSSE2->E2_X_CONTR)     
					If mTotalN > 0
						If nLinha >= nQuebra              
							ChecaCab()
						Endif				
						oPrint:Say(nLinha + nTopo, COL_7 + nMargem, "-------> "+strNaturA+ "-"+ POSICIONE("SED",1,XFILIAL("SED")+strNaturA,"ED_DESCRIC"), oFont07n)
						nColuna+=nColunaT + nColunaT + 1000
						oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalN,"@E 9,999,999,999,999.99"), oFont07n,,,,PAD_RIGHT) 
						mTotalN:=0
						nLinha+=nLinhaT			                  
					EndIf
					strNaturA:=strNatur
				EndIf
				
				If strDia<>strDiaAtu 
					If mTotalD > 0
						If nLinha >= nQuebra              
							ChecaCab()
						Endif				
						oPrint:Say(nLinha + nTopo, COL_2 + nMargem, "-------> sub-total dia "+strDiaAtu, oFont07n)
						nColuna+=nColunaT + nColunaT + 1000
						oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalD,"@E 9,999,999,999,999.99"), oFont07n,,,,PAD_RIGHT) 
						mTotalD:=0
						nLinha+=nLinhaT +(nLinhaT/2)			                  
					EndIf
					strDiaAtu:=strDia
				EndIf
				
				
			EndIf
			
			If nLinha >= nQuebra              
				ChecaCab()
			Endif
			
			If MV_PAR09==1 //RELATORIO ANALITICO
			
				If AllTrim(ORSSE2->E5_BENEF)=="" .OR. Alltrim(ORSSE2->E5_BENEF)<>Alltrim(POSICIONE("SA2",1,XFILIAL("SA2")+ORSSE2->(E5_CLIFOR+E5_LOJA),"A2_NOME")) 
					strCliente:=AllTrim(ORSSE2->E5_CLIFOR+"-"+ORSSE2->E5_LOJA)+"-"+POSICIONE("SA2",1,XFILIAL("SA2")+ORSSE2->(E5_CLIFOR+E5_LOJA),"A2_NOME")				
				Else
					strCliente:=AllTrim(ORSSE2->E5_CLIFOR+"-"+ORSSE2->E5_LOJA+"-"+ORSSE2->E5_BENEF)
				EndIf
		
//				oPrint:Say(nLinha + nTopo, COL_1 + nMargem, AllTrim(ORSSE2->E2_X_CONTR), oFont07) 
				oPrint:Say(nLinha + nTopo, COL_2 + nMargem, substr(ORSSE2->E5_DATA,7,2)+"/"+substr(ORSSE2->E5_DATA,5,2)+"/"+substr(ORSSE2->E5_DATA,1,4), oFont07) 
				oPrint:Say(nLinha + nTopo, COL_3 + nMargem, AllTrim(ORSSE2->E5_PREFIXO), oFont07) 
				oPrint:Say(nLinha + nTopo, COL_4 + nMargem, AllTrim(ORSSE2->E5_NUMERO), oFont07) 
				oPrint:Say(nLinha + nTopo, COL_5 + nMargem, AllTrim(ORSSE2->E5_PARCELA), oFont07) 
				oPrint:Say(nLinha + nTopo, COL_6 + nMargem, SubStr(AllTrim(strCliente),1,30), oFont07)

				IF AllTrim(ORSSE2->E5_TIPO)=="RA"
					oPrint:Say(nLinha + nTopo, COL_7 + nMargem, "DEV.RECEB.ANTECIPADO", oFont07)					
				Else
					oPrint:Say(nLinha + nTopo, COL_7 + nMargem, Alltrim(ORSSE2->E5HIST), oFont07)			
				EndIf
				oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(ORSSE2->E5_VALOR,"@E 9,999,999,999,999.99"), oFont07,,,,PAD_RIGHT) 


				If MV_PAR12==1 // Gera Excel
		            // para gerar dados em excel
					oExcel:AddRow(cAba1,cTable1,{			U_BuscaSM0(ORSSE2->E5_FILIAL),;
															ORSSE2->E2_NATUREZ + " - " + Alltrim(POSICIONE("SED",1,XFILIAL("SED")+ORSSE2->E2_NATUREZ,"ED_DESCRIC")) ,;
															dToC(Stod(ORSSE2->E5_DATA)),;
															AllTrim(ORSSE2->E5_PREFIXO),;	
															AllTrim(ORSSE2->E5_NUMERO),;
															AllTrim(ORSSE2->E5_PARCELA),;
															strCliente,;
															iif(AllTrim(ORSSE2->E5_TIPO)=="RA","DEV.RECEB.ANTECIPADO",Alltrim(ORSSE2->E5HIST) ),;
															ORSSE2->E5_VALOR,;
															""})			
				Endif

			
			Else //RELATORIO SINTETICO

				/* comentado por Henrique para tratamento de relatorio conforme layout solicitado pelo Sr Aurio e Jonas em 25/05/2015

				If AllTrim(ORSSE2->E2_X_CONTR)=="" //SENÃO EXISTIR NUMERO DE CONTRATO, O RELATORIO SINTETICO IMPRIME COM O ANALITICO
					If AllTrim(ORSSE2->E5_BENEF)=="" .OR. Alltrim(ORSSE2->E5_BENEF)<>Alltrim(POSICIONE("SA2",1,XFILIAL("SA2")+ORSSE2->(E5_CLIFOR+E5_LOJA),"A2_NOME"))
						strCliente:=AllTrim(ORSSE2->E5_CLIFOR+"-"+ORSSE2->E5_LOJA)+"-"+POSICIONE("SA2",1,XFILIAL("SA2")+ORSSE2->(E5_CLIFOR+E5_LOJA),"A2_NOME")				
					Else
						strCliente:=AllTrim(ORSSE2->E5_CLIFOR+"-"+ORSSE2->E5_LOJA+"-"+ORSSE2->E5_BENEF)
					EndIf
			
					//oPrint:Say(nLinha + nTopo, COL_1 + nMargem, AllTrim(ORSSE2->E2_X_CONTR), oFont07) 
					oPrint:Say(nLinha + nTopo, COL_2 + nMargem, substr(ORSSE2->E5_DATA,7,2)+"/"+substr(ORSSE2->E5_DATA,5,2)+"/"+substr(ORSSE2->E5_DATA,1,4), oFont07) 
					oPrint:Say(nLinha + nTopo, COL_3 + nMargem, AllTrim(ORSSE2->E5_PREFIXO), oFont07) 
					oPrint:Say(nLinha + nTopo, COL_4 + nMargem, AllTrim(ORSSE2->E5_NUMERO), oFont07) 
					oPrint:Say(nLinha + nTopo, COL_5 + nMargem, AllTrim(ORSSE2->E5_PARCELA + If(AllTrim(ORSSE2->E2_X_PCATE)<> "", " / " + ORSSE2->E2_X_PCATE,"")), oFont07) 
					oPrint:Say(nLinha + nTopo, COL_6 + nMargem, SubStr(AllTrim(strCliente),1,30), oFont07)
					IF AllTrim(ORSSE2->E5_TIPO)=="RA"
						oPrint:Say(nLinha + nTopo, COL_7 + nMargem, "DEV.RECEB.ANTECIPADO", oFont07)					
					Else
						//Luciano-30/04/2015-Alteração para imprimir o campo historico da Baixa e não mais o historico do titulo 
//						If AllTrim(ORSSE2->E2_HIST)==""			 
//							oPrint:Say(nLinha + nTopo, COL_7 + nMargem, If(Alltrim(ORSSE2->E2_X_CONTR)<>"","VL.PAGO REF.CTR.:" + ORSSE2->E2_X_CONTR,ORSSE2->E2_HIST), oFont07)
//						Else
//							oPrint:Say(nLinha + nTopo, COL_7 + nMargem, Alltrim(ORSSE2->E2_HIST), oFont07)			
//						EndIf
						If AllTrim(ORSSE2->E5HIST)==""			 
							oPrint:Say(nLinha + nTopo, COL_7 + nMargem, If(Alltrim(ORSSE2->E2_X_CONTR)<>"","VL.PAGO REF.CTR.:" + ORSSE2->E2_X_CONTR,ORSSE2->E5HIST), oFont07)
						Else
							oPrint:Say(nLinha + nTopo, COL_7 + nMargem, Alltrim(ORSSE2->E5HIST), oFont07)			
						EndIf 
					EndIf
					oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalC,"@E 9,999,999,999,999.99"), oFont07n,,,,PAD_RIGHT) 
				Else
					If AllTrim(xNumCTR) <> AllTrim(ORSSE2->E2_X_CONTR) //O RELATÓRIO SÓ SERÁ SINTETICO PARA TITULOS COM CONTRATO
						strCliente:=AllTrim(ORSSE2->E5_CLIFOR+"-"+ORSSE2->E5_LOJA)+"-"+POSICIONE("SA2",1,XFILIAL("SA2")+ORSSE2->(E5_CLIFOR+E5_LOJA),"A2_NOME")								
						//oPrint:Say(nLinha + nTopo, COL_1 + nMargem, AllTrim(ORSSE2->E2_X_CONTR), oFont07)
						oPrint:Say(nLinha + nTopo, COL_6 + nMargem, SubStr(AllTrim(strCliente),1,30), oFont07)
						//Luciano-30/04/2015-Alteração para imprimir o campo historico da Baixa e não mais o historico do titulo
//						oPrint:Say(nLinha + nTopo, COL_7 + nMargem, If(Alltrim(ORSSE2->E2_X_CONTR)<>"","VL.PAGO REF.CTR.:" + ORSSE2->E2_X_CONTR,ORSSE2->E2_HIST), oFont07)
						oPrint:Say(nLinha + nTopo, COL_7 + nMargem, If(Alltrim(ORSSE2->E2_X_CONTR)<>"","VL.PAGO REF.CTR.:" + ORSSE2->E2_X_CONTR,ORSSE2->E5HIST), oFont07)
						xNumCTR:=  AllTrim(ORSSE2->E2_X_CONTR)
						nLinha+=nLinhaT
						oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalC,"@E 9,999,999,999,999.99"), oFont07n,,,,PAD_RIGHT) 
								
						mTotalC:=0
					
					EndIf
					nLinha+=-nLinhaT	
				EndIf
				
				//comentado por Henrique para tratamento de relatorio conforme layout solicitado pelo Sr Aurio e Jonas em 25/05/2015
				*/
			EndIf
			                               
			mTotalD:=mTotalD+ORSSE2->E5_VALOR
			mTotalF:=mTotalF+ORSSE2->E5_VALOR
			mTotalN:=mTotalN+ORSSE2->E5_VALOR
			mTotalP:=mTotalP+ORSSE2->E5_VALOR	
			mTotal:=mTotal+ORSSE2->E5_VALOR
				
			ORSSE2->(DbSkip())
			                  
			If ORSSE2->(EOF())
				cPag:=cPag+1
				Exit			
			ElseIf nLinha >= nQuebra              
				ChecaCab()
			Endif
			
			If MV_PAR09==1 
				nLinha+=nLinhaT
			Endif
			
		Enddo        
                     		
		If nLinha >= nQuebra              
			ChecaCab()
		Endif
		
		//IMPRIME TOTAL POR FORNECEDOR
		If mTotalF > 0 .and. MV_PAR09<>1 // SOMENTE SE FOR SINTETICO
			If nLinha >= nQuebra              
				ChecaCab()
			Endif				
			oPrint:Say(nLinha + nTopo, COL_2 + nMargem, strDiaAtu,   oFont07) 
			oPrint:Say(nLinha + nTopo, COL_6 + nMargem, strFornA, oFont07)
			nColuna+=nColunaT + nColunaT + 1000
			oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalF,"@E 9,999,999,999,999.99"), oFont07,,,,PAD_RIGHT) 
			mTotalF:=0
			nLinha+=nLinhaT 			                  
		EndIf
		If nLinha >= nQuebra              
			ChecaCab()
		Endif

		//IMPRIME TOTAL POR NATUREZA
		If mTotalN > 0
			nLinha+=nLinhaT
			oPrint:Say(nLinha + nTopo, COL_7 + nMargem, "-------> "+strNaturA+ "-"+ POSICIONE("SED",1,XFILIAL("SED")+strNaturA,"ED_DESCRIC"), oFont07n)
			nColuna+=nColunaT + nColunaT + 1000
			oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalN,"@E 9,999,999,999,999.99"), oFont07n,,,,PAD_RIGHT) 
			mTotalN:=0
			nLinha+=nLinhaT			                  
		EndIf		                
		If nLinha >= nQuebra              
			ChecaCab()
		Endif

		// TOTAL POR DIA
		If mTotalD > 0
			If nLinha >= nQuebra              
				ChecaCab()
			Endif
			oPrint:Say(nLinha + nTopo, COL_2 + nMargem, "-------> sub-total dia "+strDiaAtu, oFont07n)
			nColuna+=nColunaT + nColunaT + 1000
			oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalD,"@E 9,999,999,999,999.99"), oFont07n,,,,PAD_RIGHT) 
			mTotalD:=0
			nLinha+=nLinhaT +(nLinhaT/2)			                  
		EndIf
		If nLinha >= nQuebra              
			ChecaCab()
		Endif

		//IMPRIME TOTAL PARCIAL
		If mTotalP > 0     
			nLinha+=nLinhaT
			oPrint:Say(nLinha + nTopo, COL_7 + nMargem, '-------> TOTAL FILIAL ', oFont09n)
			oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotalP,"@E 9,999,999,999,999.99"), oFont09n,,,,PAD_RIGHT) 
			mTotalP:=0
			nLinha+=nLinhaT + (nLinhaT/2)			                  
		EndIf		                
		
		strNomeImp:=""
		If nLinha >= nQuebra              
			ChecaCab()
		Endif

		//IMPRIME TOTAL DO GERAL
		nLinha+=nLinhaT
		oPrint:Say(nLinha + nTopo, COL_7 + nMargem, '-------> TOTAL GERAL ', oFont12n)
		oPrint:Say(nLinha + nTopo, COL_8 + nMargem, Transform(mTotal,"@E 9,999,999,999,999.99"), oFont12n,,,,PAD_RIGHT) 
		ImpRodape()
			
	 	ORSSE2->(dbclosearea())


		If MV_PAR12==1 // Gera Excel
			//Ativando o arquivo e gerando o xml
			oExcel:Activate()
			oExcel:GetXMLFile(cArquivo)
			
			//Abrindo o excel e abrindo o arquivo xml
			oExcelApp := MsExcel():New() 			//Abre uma nova conexão com Excel
			oExcelApp:WorkBooks:Open(cArquivo) 		//Abre uma planilha
			oExcelApp:SetVisible(.T.) 				//Visualiza a planilha
			oExcelApp:Destroy()						//Encerra o processo do gerenciador de tarefas
		Endif

		oPrint:Preview()
		oPrint:EndPage()	 	



	Else
		MsgInfo("Não foram encontrados dados a serem selecionados!")
	End                        
Return                          

//************************************************
//VERIFICA SE NECESSÁRIO A IMPRESSAO DO CABEÇALHO
//************************************************
Static Function ChecaCab()

	cPag:=cPag+1
	nLinha+=nLinhaT
	ImpRodape()
	oPrint:EndPage()
	oPrint:StartPage()
	nLinha  := 0050
	nColuna := 0000
	ImpCabe(oPrint,nColuna,nTopo,nMargem,oFont14n,oFont09n,nColunaT)
	If strNomeImp<>""
		oPrint:Say(nLinha + nTopo, COL_1 + nMargem, strNomeImp, oFont09n) 
	EndIf
	nLinha+=nLinhaT
	
Return()
                                                                                 
//*******************************
//IMPRIME CABECALHO DO RELATORIO
//*******************************
Static Function ImpCabe(oPrint,nColuna,nTopo,nMargem,oFont14n,oFont09n,nColunaT)     
Local cLogoD := ""
	
	cLogoD := GetSrvProfString("Startpath","") + "lgmid.png"
	If File(cLogoD)
		oPrint:SayBitmap(0030,0070,cLogoD,300,200)
	EndIf  

//	oPrint:Say(nLinha + nTopo, COL_3 + nMargem, FWCompanyName(), oFont14n) 
	oPrint:Say(nLinha + nTopo, COL_3 + nMargem, "Agropecuária Vista Alegre", oFont14n) 
	nLinha+=nLinhaT + 10
	If MV_PAR09==1
		oPrint:Say(nLinha + nTopo, COL_3 + nMargem, 'TITULOS PAGOS - ANALITICO', oFont14n) 
	Else
		oPrint:Say(nLinha + nTopo, COL_3 + nMargem, 'TITULOS PAGOS - SINTETICO', oFont14n)	
	EndIf                                                                                   
	nLinha+=nLinhaT + 10
	oPrint:Say(nLinha + nTopo, COL_3 + nMargem, 'PERIODO DE PAGAMENTO: ' + SubStr(DtoS(MV_PAR03),7,2)+'/'+SubStr(DtoS(MV_PAR03),5,2) +'/'+ SubStr(DtoS(MV_PAR03),1,4) + " A: " + SubStr(DtoS(MV_PAR04),7,2)+'/'+SubStr(DtoS(MV_PAR04),5,2) +'/'+ SubStr(DtoS(MV_PAR04),1,4), oFont14n) 
	nLinha+=nLinhaT + 10
	
	oPrint:line(nLinha + nTopo, 0000 + nMargem,nLinha + nTopo,EXTESAO)
	nLinha+=nLinhaT - 0025 + 10
	oPrint:Say(nLinha + nTopo, COL_1 + nMargem, 'CONTRATO', oFont09n) 
	nColuna+=nColunaT + 0100
	oPrint:Say(nLinha + nTopo, COL_2 + nMargem, 'DT.PAGTO.', oFont09n) 
	nColuna+=nColunaT + 1000
	oPrint:Say(nLinha + nTopo, COL_3 + nMargem, 'PREF.', oFont09n) 
	nColuna+=nColunaT + 1000
	oPrint:Say(nLinha + nTopo, COL_4 + nMargem, 'TITULO', oFont09n) 
	nColuna+=nColunaT + 1000
	oPrint:Say(nLinha + nTopo, COL_5 + nMargem, 'PARCELA', oFont09n) 
	nColuna+=nColunaT + 1000
	oPrint:Say(nLinha + nTopo, COL_6 + nMargem, 'FORNECEDOR', oFont09n) 	
	nColuna+=nColunaT + 1000
	oPrint:Say(nLinha + nTopo, COL_7 + nMargem, 'HISTORICO', oFont09n) 	
	nColuna+=nColunaT + 1000
	oPrint:Say(nLinha + nTopo, COL_8-90 + nMargem, 'VALOR', oFont09n) 			
	nLinha+=nLinhaT   + 10                                                     
	oPrint:line(nLinha + nTopo,0000 + nMargem,nLinha + nTopo,EXTESAO)    	
	nLinha+=nLinhaT + 10
	
Return 

//*******************************
//IMPRIME RODAPE DO RELATORIO
//*******************************
Static Function ImpRodape()
Local cDate:=DATE()
Local cTime:=TIME()      

	oPrint:line(2250, 0000 + nMargem,2250,EXTESAO)
	nLinha+=nLinhaT - 0025  
	oPrint:Say(2270, COL_1 + nMargem, dtoc(cDate)+" - "+AllTrim(cTime), oFont09n) 
	oPrint:Say(2270, CENTRO + nMargem, "TOTVS", oFont09n)
	oPrint:Say(2270, CDIREITO + nMargem, "PAGINA:" +StrZero(cPag,3), oFont09n)
	nColuna+=nColunaT + 0100	

Return            

//Verifica se movimento foi estornado
Static Function Estornado()
Local lRet := .f.

	cSql := "SELECT E5_NUMERO "
	cSql += "FROM " + RetSqlName("SE5") + " "
	cSql += "WHERE E5_FILIAL = '" + ORSSE2->E5_FILIAL + "' AND E5_PREFIXO = '" + ORSSE2->E5_PREFIXO + "' AND "
	cSql += "E5_NUMERO = '" + ORSSE2->E5_NUMERO + "' AND E5_PARCELA = '" + ORSSE2->E5_PARCELA + "' AND "
	cSql += "E5_TIPO = '" + ORSSE2->E5_TIPO + "' AND E5_CLIFOR = '" + ORSSE2->E5_CLIFOR + "' AND "
	cSql += "E5_LOJA = '" + ORSSE2->E5_LOJA + "' AND E5_SEQ = '" + ORSSE2->E5_SEQ + "' AND "
	If ORSSE2->E5_TIPODOC == "PA"
		cSql += "E5_KEY = '" + ORSSE2->E5_KEY + "' AND "
	EndIf
	cSql += "E5_RECPAG = 'R' AND E5_TIPODOC = 'ES' AND D_E_L_E_T_ <> '*' "
	
	TcQuery cSql NEW ALIAS "QEST"
	If !Eof()
		lRet := .t.
	EndIf          
	
	QEST->(DbCloseArea())

Return lRet
