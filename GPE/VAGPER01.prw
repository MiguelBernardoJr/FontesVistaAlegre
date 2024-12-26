#include 'protheus.ch'
#include 'parmtype.ch'

user function VAGPER01()


Private cPerg := nil

	nOrdem   := 0
	tamanho  := "P"
	limite   := 80
	titulo   := PADC("VAEST025",74)
	cDesc1   := PADC("Head Count",74)
	cDesc2   := ""
	cDesc3   := ""
	aReturn  :=  { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
	nomeprog := "VAGPER01"
	cPerg    := "VAGPER01"
	nLastKey := 0
	wnrel    := "VAGPER01"
	_cQry	 := ""

	ValidPerg(cPerg)
	
	/* 
	While Pergunte(cPerg, .T.)
		MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
	Enddo
	*/
	If Pergunte(cPerg, .T.)
		MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
	Endif
	
	/*
SELECT RD_FILIAL, SUBSTRING(RD_PERIODO,5,2)+'/'+SUBSTRING(RD_PERIODO,1,4) PERÍODO, RD_CC, CTT_DESC01, COUNT(*) QTD
FROM SRD010 RD
JOIN CTT010 ON
CTT_CUSTO = RD_CC
AND CTT010.D_E_L_E_T_ = ' ' 
WHERE RD_PERIODO ='201802'
AND RD.D_E_L_E_T_ = ' ' 
AND RD_PD = '101'
GROUP BY RD_FILIAL, RD_PERIODO, RD_CC, CTT_DESC01
	*/
return

Static Function ValidPerg(cPerg)
Local _sAlias,i,j

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs :={}                                                  

	aAdd(aRegs,{cPerg, "01", "Filial De   ?", "", "", "MV_CH01", "C", TamSX3("D3_FILIAL") [1], TamSX3("D3_FILIAL") [2], 0, "G", "", "MV_PAR01" , "", "","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "02", "Filial Ate  ?", "", "", "MV_CH02", "C", TamSX3("D3_FILIAL") [1], TamSX3("D3_FILIAL") [2], 0, "G", "", "MV_PAR02" , "", "","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "03", "Data De     ?", "", "", "MV_CH03", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "", "MV_PAR03" , "", "","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "04", "Data Até    ?", "", "", "MV_CH04", "D", TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], 0, "G", "", "MV_PAR04" , "", "","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
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

Static Function ImprRel(cPerg)  
 
// Tratamento para Excel
Private oExcel := FWMSExcel():New()
Private oExcelApp
Private cArquivo  := GetTempPath()+'VAGPER01_'+StrTran(dToC(dDataBase), '/', '-')+'_'+StrTran(Time(), ':', '-')+'.xml'

oExcel:SetFont('Arial Narrow')
oExcel:SetBgColorHeader("#37752F") // cor de fundo linha cabeçalho
oExcel:SetLineBgColor("#FFFFFF")   // cor da linha 1
oExcel:Set2LineBgColor("#FFFFFF")  // cor da linha 2

fQuadro1(cPerg)

oExcel:Activate()
oExcel:GetXMLFile(cArquivo)

//Abrindo o excel e abrindo o arquivo xml
oExcelApp := MsExcel():New() 			//Abre uma nova conexão com Excel
oExcelApp:WorkBooks:Open(cArquivo) 		//Abre uma planilha
oExcelApp:SetVisible(.T.) 				//Visualiza a planilha
oExcelApp:Destroy()						//Encerra o processo do gerenciador de tarefas
	
Return 

Static Function fQuadro1(cPerg)

Local aArea 	 := getArea()
Local _cQry		 := ''
Local cAlias     := CriaTrab(,.F.)
Local cWorkSheet := "Insumos"
Local cTitulo	 := "Quantidade Produzidas"
Local nQtDias    := DateDiffDay(MV_PAR03, MV_PAR04)+1
Local dDia 		 := MV_PAR03
Local aDados	 := {} // Array(4+(3*nQtdias))

cTitulo += " - Dt. Referência: " + DtoC(MV_PAR03) + " - " + DtoC(MV_PAR04)
oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(  cWorkSheet, cTitulo)

_cQry := "    " + CRLF
_cQry += "  SELECT RD_FILIAL, SUBSTRING(RD_PERIODO,5,2)+'/'+SUBSTRING(RD_PERIODO,1,4) PERÍODO, RD_CC, CTT_DESC01, COUNT(*) QTD  " + CRLF
_cQry += "  FROM SRD010 RD  " + CRLF
_cQry += "  JOIN CTT010 ON  " + CRLF
_cQry += "  CTT_CUSTO = RD_CC  " + CRLF
_cQry += "  AND CTT010.D_E_L_E_T_ = ' '   " + CRLF
_cQry += "  WHERE RD_PERIODO = ' '   " + CRLF
_cQry += "  AND RD.D_E_L_E_T_ = ' '   " + CRLF
_cQry += "  AND RD_PD = '101'  " + CRLF
_cQry += "  GROUP BY RD_FILIAL, RD_PERIODO, RD_CC, CTT_DESC01  " + CRLF
_cQry += "  ORDER BY RD_FILIAL, RD_PERIODO, RD_CC  " + CRLF


	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
	MemoWrite(StrTran(cArquivo,".xml","")+"Quadro4.sql" , _cQry)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 
	
	TcSetField(cAlias, "EMISSAO", "D")
	TcSetField(cAlias, "DATA_COMPRA", "D")
	
	/* 01 */ oExcel:AddColumn( cWorkSheet, cTitulo, "FILIAL"		      			, 1, 1 )
	/* 02 */ oExcel:AddColumn( cWorkSheet, cTitulo, "CENTRO CUSTO"		  			, 1, 1 )
	/* 03 */ oExcel:AddColumn( cWorkSheet, cTitulo, "DESCRICAO"		      	  		, 1, 1 )
	
	/* 04 */ oExcel:AddColumn( cWorkSheet, cTitulo, "PERÍODO"			 	 		, 1, 1 )
	/* 05 */ oExcel:AddColumn( cWorkSheet, cTitulo, "QTDE FUNCIONÁRIOS"		      	, 1, 1 )
	
	
	 dbGotop()
	
	
	While !(cAlias)->(Eof())
		oExcel:AddRow(cWorkSheet, cTitulo, { _cQry->RD_FILIAL,;
											 _cQry->RD_CC, ;
											 _cQry->CTT_DESC01, ;
											 _cQry->RD_PERIODO, ;
											 _cQry->QTD } )
											 
						
		_cQry->(dbSkip())
	EndDo
	

	
Return
